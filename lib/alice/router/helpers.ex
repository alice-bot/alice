defmodule Alice.Router.Helpers do
  @docmodule """
  Helpers to make replying easier in handlers
  """

  @doc """
  Reply to a message in a handler.

  Sends `response` back to the channel that triggered the handler.

  Adds random tag to end of image urls to break Slack's img cache.
  """
  def reply(response, conn=%{message: %{channel: channel}, slack: slack}) do
    response
    |> uncache_images
    |> slack_api.send_message(channel, slack)
    conn
  end

  defp uncache_images(potential_image) do
    ~w[gif png jpg jpeg]
    |> Enum.any?(&(potential_image |> String.downcase |> String.ends_with?(&1)))
    |> case do
      true -> "#{potential_image}?#{random_tag}"
      _    -> potential_image
    end
  end

  defp random_tag do
    "0." <> tag = to_string(:rand.uniform)
    tag
  end

  defp slack_api do
    case Mix.env do
      :test -> FakeSlack
      _else -> Slack
    end
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

  @doc "Adds a route to the handler"
  defmacro route(pattern, name) do
    quote do
      @routes {unquote(pattern), unquote(name)}
    end
  end

  @doc "Adds a command to the handler"
  defmacro command(pattern, name) do
    quote do
      @commands {unquote(pattern), unquote(name)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle(conn, name) do
        Logger.warn("#{__MODULE__}.handle(conn, :#{name}) is not defined")
        conn
      end

      @doc """
      Get the state from an Alice.Conn struct, namespaced to this module
      """
      def get_state(conn=%Alice.Conn{}, key, default \\ nil) do
        Alice.Conn.get_state_for(conn, namespace(key), default)
      end

      @doc """
      Update the state of an Alice.Conn struct, namespaced to this module
      """
      def put_state(conn=%Alice.Conn{}, key, value) do
        Alice.Conn.put_state_for(conn, namespace(key), value)
      end

      @doc """
      All of the routes handled by this module
      """
      def routes, do: @routes

      @doc """
      All of the commands handled by this module
      """
      def commands, do: @commands

      @doc """
      Match all routes in this module
      """
      def match_routes(conn), do: match(routes, conn)

      @doc """
      Match all commands in this module
      """
      def match_commands(conn), do: match(commands, conn)

      defp match(patterns, connection=%Alice.Conn{message: message}) do
        patterns
        |> Enum.reduce(connection, fn({pattern, name}, conn) ->
          if Regex.match?(pattern, message.text) do
            Logger.info("#{__MODULE__} is responding to #{Alice.Conn.user(conn)} with #{name}")
            conn = conn
                   |> Alice.Conn.add_captures(pattern)
                   |> __MODULE__.handle(name)
          end
          conn
        end)
      end
    end
  end
end
