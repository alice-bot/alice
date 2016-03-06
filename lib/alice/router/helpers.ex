defmodule Alice.Router.Helpers do
  @moduledoc """
  Helpers to make replying easier in handlers
  """

  alias Alice.Conn

  @doc """
  Reply to a message in a handler.

  Takes a conn and a response string in any order.
  Sends `response` back to the channel that triggered the handler.

  Adds random tag to end of image urls to break Slack's img cache.
  """
  @spec reply(String.t, Conn.t) :: Conn.t
  @spec reply(Conn.t, String.t) :: Conn.t
  def reply(response, conn) when is_binary(response), do: reply(conn, response)
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
  @spec random_reply(list, Conn.t) :: Conn.t
  @spec random_reply(Conn.t, list) :: Conn.t
  def random_reply(list, conn=%Conn{}), do: random_reply(conn, list)
  def random_reply(conn=%Conn{}, list), do: list |> Enum.random |> reply(conn)

  @doc """
  Reply with random chance.

  Examples

      > chance_reply(conn, 0.5, "sent half the time")
      > chance_reply(conn, 0.25, "sent 25% of the time", "sent 75% of the time")
  """
  @spec chance_reply(Conn.t, float, String.t, String.t) :: Conn.t
  def chance_reply(conn=%Conn{}, chance, positive, negative \\ :noreply) do
    {:rand.uniform <= chance, negative}
    |> do_chance_reply(positive, conn)
  end

  defp do_chance_reply({true, _}, positive, conn),  do: reply(positive, conn)
  defp do_chance_reply({false, :noreply}, _, conn), do: conn
  defp do_chance_reply({false, negative}, _, conn), do: reply(negative, conn)

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
  @spec delayed_reply(Conn.t, String.t, integer) :: Task.t
  @spec delayed_reply(String.t, integer, Conn.t) :: Task.t
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
  @spec indicate_typing(Conn.t) :: Conn.t
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
            "#{__MODULE__} is responding to #{Conn.user(conn)} with #{name}"
            |> Logger.info
            conn = conn |> Conn.add_captures(pattern)
            apply(__MODULE__, name, [conn])
          end
          conn
        end)
      end
    end
  end
end
