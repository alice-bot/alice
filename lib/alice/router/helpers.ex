defmodule Alice.Router.Helpers do
  @moduledoc """
  Helpers to make replying easier in handlers
  """

  alias Alice.Conn
  require Logger

  @doc """
  Reply to a message in a handler.

  Takes a conn and a response string in any order.
  Sends `response` back to the channel that triggered the handler.

  Adds random tag to end of image urls to break Slack's img cache.
  """
  @spec reply(String.t(), %Conn{}) :: %Conn{}
  @spec reply(%Conn{}, String.t()) :: %Conn{}
  @spec reply([String.t(), ...], %Conn{}) :: %Conn{}
  @spec reply(%Conn{}, [String.t(), ...]) :: %Conn{}
  def reply(resp, conn = %Conn{}), do: reply(conn, resp)
  def reply(conn = %Conn{}, resp) when is_list(resp), do: random_reply(conn, resp)

  def reply(conn = %Conn{message: %{channel: channel, thread_ts: thread}, slack: slack}, resp) do
    resp
    |> Alice.Images.uncache()
    |> outbound_api().send_message(channel, slack, thread)

    conn
  end

  def reply(conn = %Conn{message: %{channel: channel}, slack: slack}, resp) do
    resp
    |> Alice.Images.uncache()
    |> outbound_api().send_message(channel, slack)

    conn
  end

  defp outbound_api do
    Application.get_env(:alice, :outbound_client, Alice.ChatBackends.SlackOutbound)
  end

  @doc """
  Takes a conn and a list of possible response in any order.
  Replies with a random element of the `list` provided.
  """
  @spec random_reply(list(), %Conn{}) :: %Conn{}
  @spec random_reply(%Conn{}, list()) :: %Conn{}
  def random_reply(list, conn = %Conn{}), do: random_reply(conn, list)
  def random_reply(conn = %Conn{}, list), do: list |> Enum.random() |> reply(conn)

  @doc """
  Reply with random chance.

  Examples

      > chance_reply(conn, 0.5, "sent half the time")
      > chance_reply(conn, 0.25, "sent 25% of the time", "sent 75% of the time")
  """
  @spec chance_reply(%Conn{}, float(), String.t(), String.t() | :noreply) :: %Conn{}
  def chance_reply(conn = %Conn{}, chance, positive, negative \\ :noreply) do
    success? = :rand.uniform() <= chance
    chance_reply(conn, {success?, positive, negative})
  end

  defp chance_reply(conn, {false, _, :noreply}), do: conn
  defp chance_reply(conn, {false, _, resp}), do: reply(conn, resp)
  defp chance_reply(conn, {true, resp, _}), do: reply(conn, resp)

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
  @spec delayed_reply(%Conn{}, String.t(), integer()) :: Task.t()
  @spec delayed_reply(String.t(), integer(), %Conn{}) :: Task.t()
  def delayed_reply(msg, ms, conn = %Conn{}), do: delayed_reply(conn, msg, ms)

  def delayed_reply(conn = %Conn{}, message, milliseconds) do
    parent = self()

    Task.async(fn ->
      conn = indicate_typing(conn)
      forward_message(parent, :indicate_typing)

      :timer.sleep(milliseconds)

      conn = reply(conn, message)
      forward_message(parent, :send_message)

      conn
    end)
  end

  defp forward_message(pid, name) do
    receive do
      {^name, payload} -> send(pid, {name, payload})
    after
      0 -> nil
    end
  end

  @doc """
  Indicate typing.
  """
  @spec indicate_typing(%Conn{}) :: %Conn{}
  def indicate_typing(conn = %Conn{message: %{channel: chan}, slack: slack}) do
    outbound_api().indicate_typing(chan, slack)
    conn
  end
end
