defmodule Alice.Handlers.Help do
  @moduledoc "A handler to return helptext for all registered handlers"
  use Alice.Handler

  command ~r/\bhelp$/i, :general_help
  command ~r/\bhelp (?<term>.*)\z/i, :keyword_help

  @pro_tip "_*Pro Tip:* Commands require you mention me by name, routes do not_"

  @doc "`help` - lists all known handlers"
  def general_help(msg, %{bot: bot, name: name}) do
    ["_Here are all the handlers I know about…_",
     handler_list(bot),
     "_Get info about a specific handler with_ `#{name} help <handler name>`",
     "_Get info about all handlers with_ `#{name} help all`"]
    |> Enum.join("\n\n")
    |> reply(msg)
  end

  @doc """
  `help all` - outputs the help text for each route in every handler
  `help <handler name>` - outputs the help text for a single matching handler
  """
  def keyword_help(msg, %{bot: bot} = state) do
    handlers = Alice.Bot.handler_processes(bot)
    do_keyword_help(msg, get_term(msg), handlers, state)
  end

  defp do_keyword_help(msg, "all", handlers, state) do
    [@pro_tip,
     "_Here are all the routes and commands I know about…_"
     | Enum.map(handlers, &help_for_handler(&1, state))]
    |> Enum.each(&reply(msg, &1))
  end
  defp do_keyword_help(msg, term, handlers, state) do
    handlers
    |> Enum.find(fn({mod,_}) -> downcased_handler_name(mod) == term end)
    |> deliver_help(msg, state)
  end

  defp handler_list(bot) do
    Alice.Bot.handlers(bot)
    |> Stream.map(&handler_name/1)
    |> Enum.sort()
    |> Stream.map(&("> *#{&1}*"))
    |> Enum.join("\n")
  end

  defp get_term(%Alice.Message{captures: %{"term" => term}}) do
    term
    |> String.downcase()
    |> String.replace(~r/[_\s]+/, "")
    |> String.trim()
  end

  defp handler_name(handler) do
    handler
    |> to_string()
    |> String.split(".")
    |> Enum.reverse()
    |> hd
  end

  defp downcased_handler_name(handler) do
    handler
    |> handler_name()
    |> String.downcase()
  end

  defp deliver_help(nil, msg, state) do
    reply(msg, ~s(I can't find a handler matching "#{get_term(msg)}"))
    general_help(msg, state)
  end
  defp deliver_help(handler, msg, state) do
    [@pro_tip,
     ~s(_Here are all the routes and commands I know for "#{get_term(msg)}"_),
     help_for_handler(handler, state)]
    |> Enum.join("\n\n")
    |> reply(msg)
  end

  defp help_for_handler({__MODULE__, _}, %{routes: rts, commands: cmds, name: name}) do
    help_for_handler(__MODULE__, rts, cmds, name)
  end
  defp help_for_handler({mod, pid}, %{name: name}) do
    routes = Alice.Handler.routes(pid)
    commands = Alice.Handler.commands(pid)
    help_for_handler(mod, routes, commands, name)
  end

  defp help_for_handler(mod, routes, commands, name) do
    [">*#{path_name(mod)}*",
     format_routes("Routes", routes, mod, name),
     format_routes("Commands", commands, mod, name), ""]
    |> compact()
    |> Enum.join("\n")
  end

  defp path_name("Elixir." <> name), do: name
  defp path_name(handler), do: handler |> to_string() |> path_name()

  defp format_routes(_,[],_,_), do: nil
  defp format_routes(title, routes, handler, botname) do
    routes = Enum.map(routes, fn({_,name}) -> name end)

    docs = handler
           |> Code.get_docs(:docs)
           |> Stream.map(fn({{name,_},_,_,_,text}) -> {title, name, text} end)
           |> Stream.filter(fn({_,name,_}) -> name in routes end)
           |> Enum.map(&format_route(&1, botname))
           |> compact()

    [">", "> *#{title}:*" | docs]
    |> Enum.join("\n")
  end

  defp format_route({_,_,false}, _), do: nil
  defp format_route({title, name, text}, botname) do
    [">    _#{name}_", format_text(text, title, botname)]
    |> Enum.join("\n")
  end

  defp format_text(nil,_,_), do: ">        _no documentation provided_"
  defp format_text(text, title, name) do
    text
    |> String.trim()
    |> String.split("\n")
    |> Stream.map(fn(line) -> ">        #{prefix_command(title, line, name)}" end)
    |> Enum.join("\n")
  end

  defp prefix_command("Commands", "`" <> line, name), do: "`#{name} #{line}"
  defp prefix_command(_, line, _), do: line

  defp compact(list), do: list |> Enum.reject(&is_nil/1)
end
