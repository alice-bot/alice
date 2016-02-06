defmodule Alice.Handlers.Help do
  use Alice.Router

  command ~r/help/i, :help

  def handle(conn, :help) do
    Enum.map(Alice.Router.handlers, fn(handler) ->
      """
      *#{handler_name(handler)}*
      #{routes(handler.routes)}
      #{commands(handler.commands)}
      """
    end)
    |> Enum.join
    |> format_response
    |> reply(conn)
  end

  defp handler_name(handler) do
    "Elixir." <> name = to_string(handler)
    name
  end

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

  defp format_response(help_text) do
    """
    _Sure thing! Here are all the routes I know about…_

    #{help_text}
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
