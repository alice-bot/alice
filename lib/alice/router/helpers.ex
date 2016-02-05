defmodule Alice.Router.Helpers do
  @docmodule """
  Helpers to make replying easier in handlers
  """

  @doc """
  Reply to a message in a handler.

  Sends `response` back to the channel that triggered the handler.
  """
  def reply(response, conn = %{message: %{channel: channel}, slack: slack}) do
    Slack.send_message(response, channel, slack)
    conn
  end

  @doc """
  Replies with a random element of the `list` provided.
  """
  def random_reply(list, conn), do: list |> Enum.random |> reply(conn)

  @doc """
  Reply with random chance.

  Examples

      > chance_reply(0.5, "this will be sent half the time, otherwise nothing will be sent")
      > chance_reply(0.25, "this will be sent 25% of the time", "sent 75% of the time")
  """
  def chance_reply(chance, positive, negative \\ :noreply, conn=%Alice.Conn{}) do
    case {:rand.uniform <= chance, negative} do
      {true,  _}        -> reply(positive, conn)
      {false, :noreply} -> conn
      {false, negative} -> reply(negative, conn)
    end
  end

  @doc """
  Formats code for Slack
  """
  def format_code(code) do
    """
    ```
    #{code}
    ```
    """
  end

  @doc "Adds a route to the handler"
  defmacro route(pattern, name) do
    quote do
      @routes {unquote(pattern), unquote(name)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle(conn, name) do
        Logger.warn("#{__MODULE__}.handle(conn, :#{name}) is not defined")
        conn
      end

      def routes, do: @routes

      def match_routes(connection=%Alice.Conn{message: message}) do
        routes
        |> Enum.reduce(connection, fn({pattern, name}, conn) ->
          if Regex.match?(pattern, message.text) do
            Logger.info("#{__MODULE__} is responding to #{Alice.Conn.user(conn)} with #{name}")
            conn = __MODULE__.handle(conn, name)
          end
          conn
        end)
      end
    end
  end
end


