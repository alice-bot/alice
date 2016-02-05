defmodule Alice.Handlers.Help do
  use Alice.Router

  route ~r/alice help/, :help

  def handle(conn, :help) do
    Enum.map(Alice.Router.handlers, fn(handler) ->
      [name(handler) | routes(handler)] |> Enum.join("\n")
    end)
    |> Enum.join("\n\n")
    |> format_help_text
    |> reply(conn)
  end

  defp format_help_text(help), do: "```#{help}```"

  defp name(handler) do
    "Elixir." <> name = to_string(handler)
    name
  end

  defp routes(handler) do
    handler.routes
    |> Enum.map(fn({ptn, _}) ->
      "  #{format_pattern(ptn)}"
    end)
  end

  defp format_pattern(pattern) do
    "~r" <> ptn = inspect(pattern)
    ptn
  end
end
