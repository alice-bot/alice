defmodule Alice.Handlers.Help do
  use Alice.Router

  command ~r/help/i, :help

  def handle(conn, :help) do
    conn = reply("_Sure thing! Here are all the routes I know about…_", conn)

    Enum.reduce(Alice.Router.handlers, conn, fn(handler, conn) ->
      """
      *#{name(handler)}*
      #{routes(handler.routes)}
      #{commands(handler.commands)}
      """
      |> reply(conn)
    end)
  end

  defp name(handler) when is_atom(handler), do: handler |> to_string |> name
  defp name("Elixir." <> name), do: name

  defp routes([]), do: ""
  defp routes(routes) do
    """
    _Routes:_
    ```
    #{Enum.join(format_routes(routes), "\n")}
    ```
    """
  end

  defp commands([]), do: ""
  defp commands(commands) do
    """
    _Commands:_
    ```
    #{Enum.join(format_routes(commands), "\n")}
    ```
    """
  end

  defp format_routes([]), do: []
  defp format_routes(routes) do
    len = max_length(routes)
    routes
    |> Enum.map(fn({ptn, name}) ->
      [format_handler_name(name, len), format_pattern(ptn)]
      |> Enum.join
    end)
  end

  def max_length(routes) do
    routes
    |> Enum.map(fn({_, name}) -> to_string(name) end)
    |> Enum.sort_by(&byte_size/1)
    |> Enum.reverse
    |> hd
    |> byte_size
    |> + 2
  end

  defp format_handler_name(name, len) do
    name
    |> to_string
    |> String.replace("_", " ")
    |> fn(str) -> "#{str}:" end.()
    |> String.ljust(len)
  end

  defp format_pattern(pattern) do
    "~r" <> ptn = inspect(pattern)
    ptn
  end
end
