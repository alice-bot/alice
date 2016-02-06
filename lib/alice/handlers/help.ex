defmodule Alice.Handlers.Help do
  use Alice.Router

  route ~r/\Aalice help\z/i, :help

  def handle(conn, :help) do
    Enum.map(Alice.Router.handlers, fn(handler) ->
      """
      *#{name(handler)}*
      ```
      #{Enum.join(routes(handler), "\n")}
      ```
      """
    end)
    |> Enum.join
    |> format_response
    |> reply(conn)
  end

  defp format_response(help_text) do
    """
    _Sure thing! Here are all the routes I know about…_

    #{help_text}
    """
  end

  defp name(handler) do
    "Elixir." <> name = to_string(handler)
    name
  end

  defp routes(handler) do
    len = max_length(handler)
    handler.routes
    |> Enum.map(fn({ptn, name}) ->
      [format_handler_name(name, len), format_pattern(ptn)]
      |> Enum.join
    end)
  end

  def max_length(handler) do
    handler.routes
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
