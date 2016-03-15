defmodule Alice.Handlers.Help do
  @moduledoc "A handler to return helptext for all registered handlers"
  use Alice.Router

  command ~r/>:? help\z/i, :help
  command ~r/\bhelp (.*)\z/i, :help_specific

  @doc "`help` - lists all known handlers"
  def help(conn) do
    [ "_Here are all the handlers I know about…_",
      handler_list
    ] ++ [
      "_You can get more information about a specific handler with_",
      "```@alice help <handler name>```",
      "_Or get information about all handlers with_",
      "```@alice help all```" ]
    |> Enum.join("\n\n")
    |> reply(conn)
  end

  @doc """
  `help all` - outputs the help text for each route in every handler
  `help <handler name>` - outputs the help text for a single matching handler
  """
  def help_specific(conn) do
    get_specific_help(conn, get_term(conn))
  end

  defp get_specific_help(conn, "all") do
    [ "_*Pro Tip:* Commands require you @ mention me, routes do not_",
      "_Here are all the routes and commands I know about…_"
      | Enum.map(Alice.Router.handlers, &help_for_handler/1) ]
    |> Enum.reduce(conn, &reply/2)
  end
  defp get_specific_help(conn, term) do
    Router.handlers
    |> Enum.find(&(downcased_handler_name(&1) == term))
    |> deliver_help(conn)
  end

  defp handler_list do
    Router.handlers
    |> Enum.map(&handler_name/1)
    |> Enum.sort
    |> Enum.map(&("> *#{&1}*"))
    |> Enum.join("\n")
  end

  defp get_term(conn) do
    conn
    |> Conn.last_capture
    |> String.downcase
    |> String.replace(~r/[_\s]+/, "")
    |> String.strip
  end

  defp handler_name(handler) do
    handler
    |> Atom.to_string
    |> String.split(".")
    |> Enum.reverse
    |> hd
  end

  defp downcased_handler_name(handler) do
    handler
    |> handler_name
    |> String.downcase
  end

  defp deliver_help(nil, conn) do
    ~s(I can't find a handler matching "#{get_term(conn)}")
    |> reply(conn)
    |> help

  end
  defp deliver_help(handler, conn) do
    [ "_Sure thing!_",
      "_Commands require you @ mention me, routes do not_",
      ~s(_Here are all the routes and commands I know for "#{get_term(conn)}"_),
      help_for_handler(handler) ]
    |> Enum.join("\n\n")
    |> reply(conn)
  end

  def help_for_handler(handler) do
    [ ">*#{name(handler)}*",
      format_routes("Routes", handler.routes, handler),
      format_routes("Commands", handler.commands, handler), "" ]
    |> compact
    |> Enum.join("\n")
  end

  defp name(handler) when is_atom(handler), do: handler |> to_string |> name
  defp name("Elixir." <> name), do: name

  defp format_routes(_,[],_), do: nil
  defp format_routes(title, routes, handler) do
    routes = Enum.map(routes, fn({_,name}) -> name end)

    docs = handler
           |> Code.get_docs(:docs)
           |> Enum.map(fn({{name,_},_,_,_,text}) -> {title, name, text} end)
           |> Enum.filter(fn({_,name,_}) -> name in routes end)
           |> Enum.map(&format_route/1)
           |> compact

    [">", "> *#{title}:*" | docs]
    |> Enum.join("\n")
  end

  defp format_route({_,_,false}), do: nil
  defp format_route({title, name, text}) do
    [">    _#{name}_", format_text(text, title)]
    |> Enum.join("\n")
  end

  defp format_text(nil,_), do: ">        _no documentation provided_"
  defp format_text(text, title) do
    text
    |> String.strip
    |> String.split("\n")
    |> Enum.map(fn(line) -> ">        #{prefix_command(title, line)}" end)
    |> Enum.join("\n")
  end

  defp prefix_command("Commands", "`" <> line), do: "`@alice #{line}"
  defp prefix_command(_, line), do: line

  defp compact(list), do: list |> Enum.reject(&is_nil/1)
end
