defmodule Alice.Router.Helpers do
  @docmodule """
  Helpers to make replying easier in handlers
  """

  alias Alice.Conn

  @doc """
  Reply to a message in a handler.

  Takes a conn and a response string in any order.
  Sends `response` back to the channel that triggered the handler.

  Adds random tag to end of image urls to break Slack's img cache.
  """
  def reply(response, conn=%Conn{}), do: reply(conn, response)
  def reply(conn=%Conn{message: %{channel: channel}, slack: slack}, response) do
    response
    |> uncache_images
    |> slack_api.send_message(channel, slack)
    conn
  end

  defp uncache_images(potential_image) do
    ~w[gif png jpg jpeg]
    |> Enum.any?(&(potential_image |> String.downcase |> String.ends_with?(&1)))
    |> case do
      true -> "#{potential_image}##{random_tag}"
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
  Takes a conn and a list of possible response in any order.
  Replies with a random element of the `list` provided.
  """
  def random_reply(list, conn=%Conn{}), do: random_reply(conn, list)
  def random_reply(conn=%Conn{}, list), do: list |> Enum.random |> reply(conn)

  @doc """
  Reply with random chance.

  Examples

      > chance_reply(conn, 0.5, "this will be sent half the time, otherwise nothing will be sent")
      > chance_reply(conn, 0.25, "this will be sent 25% of the time", "sent 75% of the time")
  """
  def chance_reply(conn=%Conn{}, chance, positive, negative \\ :noreply) do
    case {:rand.uniform <= chance, negative} do
      {true,  _}        -> reply(positive, conn)
      {false, :noreply} -> conn
      {false, negative} -> reply(negative, conn)
    end
  end

  @doc """
  Delay a reply. Alice will show to be typing while the message is delayed.

  The conn can be passed in first or last.

  Returns the task, not a conn. If you need to get the conn, you can
  use `Task.await(task)`, but this will block the handle process until the delay
  finishes. If you don't need the updated conn, simply return the conn that was
  passed to delayed_reply.

  Examples

      def hello(conn) do
        "hello" |> delayed_reply(1000, conn)
        conn
      end

      def hello(conn) do
        task = delayed_reply(conn, "hello", 1000)
        # other work...
        Task.await(task)
      end
  """
  def delayed_reply(msg, ms, conn=%Conn{}), do: delayed_reply(conn, msg, ms)
  def delayed_reply(conn=%Conn{}, message, milliseconds) do
    Task.async(fn ->
      conn = indicate_typing(conn)
      :timer.sleep(milliseconds)
      reply(message, conn)
    end)
  end

  @doc """
  Indicate typing.
  """
  def indicate_typing(conn=%Conn{message: %{channel: channel}, slack: slack}) do
    slack_api.indicate_typing(channel, slack)
    conn
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
      @doc """
      Callback. This function gets called when a route with `name` matches

      Must return an `Alice.Conn`.
      """
      def handle(conn, name) do
        Logger.warn("#{__MODULE__}.handle(conn, :#{name}) is not defined")
        conn
      end

      @doc """
      Get the state from an Alice.Conn struct, namespaced to this module
      """
      def get_state(conn=%Conn{}, key, default \\ nil) do
        Conn.get_state_for(conn, namespace(key), default)
      end

      @doc """
      Update the state of an Alice.Conn struct, namespaced to this module
      """
      def put_state(conn=%Conn{}, key, value) do
        Conn.put_state_for(conn, namespace(key), value)
      end

      @doc """
      Deletes the entries in the state for a specific `key`.
      """
      def delete_state(conn=%Conn{}, key) do
        Conn.delete_state_for(conn, namespace(key))
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

      defp match(patterns, connection=%Conn{message: message}) do
        patterns
        |> Enum.reduce(connection, fn({pattern, name}, conn) ->
          if Regex.match?(pattern, message.text) do
            Logger.info("#{__MODULE__} is responding to #{Conn.user(conn)} with #{name}")
            conn = conn |> Conn.add_captures(pattern)
            apply(__MODULE__, name, [conn])
          end
          conn
        end)
      end
    end
  end
end
