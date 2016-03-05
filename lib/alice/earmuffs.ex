defmodule Alice.Earmuffs do
  use Alice.Router
  alias Alice.Conn

  @state_id {Alice.Earmuffs, :earmuffs}

  command ~r/\bearmuffs\b/i, :earmuffs

  @doc """
  `earmuffs` - Alice will ignore your next message in the current channel
  * Scoped to user and channel
  * Lasts for a single message
  """
  def earmuffs(conn), do: reply("#{Conn.at_reply_user(conn)} :mute:", block(conn))

  def block(conn=%Conn{message: %{user: user, channel: channel}}) do
    earmuffs = get_state(conn, :earmuffs, %{})
    channels = [channel | Map.get(earmuffs, user, [])]
    put_state(conn, :earmuffs, Map.put(earmuffs, user, channels))
  end

  def blocked?(conn=%Conn{message: %{user: user, channel: channel}}) do
    conn
    |> get_state(:earmuffs, %{})
    |> case do
      %{^user => channels} -> channel in channels
      _ -> false
    end
  end
  def blocked?(%Conn{}), do: false

  def unblock(conn=%Conn{message: %{user: user, channel: channel}}) do
    earmuffs = get_state(conn, :earmuffs, %{})
    channels = Map.get(earmuffs, user, [])
               |> Enum.reject(&(&1 == channel))
    put_state(conn, :earmuffs, Map.put(earmuffs, user, channels))
  end
end
