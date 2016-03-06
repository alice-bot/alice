defmodule Alice.Handlers.Help do
  @moduledoc "A handler to return helptext for all registered handlers"
  use Alice.Router

  command ~r/help/i, :help

  @doc "`help` - outputs the help text for each route in every handler"
  def help(conn) do
    [ "_Sure thing!_",
      "_Commands require you @ mention me, routes do not_",
      "_Here are all the routes and commands I know about…_"
      | Enum.map(Alice.Router.handlers, &help_for_handler/1) ]
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
