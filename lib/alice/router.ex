defmodule Alice.Router do
  @handlers [
    Alice.Handlers.Random
  ]

  def match_routes(conn) do
    Enum.each(@handlers, &(apply(&1, :match_routes, [conn])))
  end

  def reply(response, conn = %{message: %{channel: channel}, slack: slack}) do
    Slack.send_message(response, channel, slack)
    conn
  end

  def random_reply(list, conn), do: list |> Enum.random |> reply(conn)

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Alice.Router
      import Slack
      import Slack.Handlers

      @routes []
      @before_compile Alice.Router
    end
  end

  @doc "Adds a route to the handler"
  defmacro route(pattern, name) do
    quote do
      @routes [{unquote(pattern), unquote(name)}|@routes]
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def match_routes(conn=%Alice.Conn{message: message}) do
        @routes
        |> Enum.reduce(conn, fn({pattern, name}, conn) ->
          if Regex.match?(pattern, message.text) do
            apply(__MODULE__, name, [conn])
          end
          conn
        end)
      end
    end
  end
end
