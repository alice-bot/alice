defmodule Alice.Earmuffs do
  @moduledoc """
  Allows a user to block Alice from responding to their next message
  """

  use Alice.Router
  alias Alice.Conn

  command ~r/>:? earmuffs\b/i, :earmuffs

  @doc """
  `earmuffs` - Alice will ignore your next message in the current channel
      - Scoped to user and channel
      - Lasts for a single message
  """
  def earmuffs(conn) do
    reply("#{Conn.at_reply_user(conn)} :mute:", block(conn))
  end

  def block(conn = %Conn{message: %{user: user, channel: channel}}) do
    earmuff_data = get_state(conn, :earmuffs, %{})
    channels = [channel | Map.get(earmuff_data, user, [])]
    put_state(conn, :earmuffs, Map.put(earmuff_data, user, channels))
  end

  def blocked?(conn = %Conn{message: %{user: user, channel: channel}}) do
    conn
    |> get_state(:earmuffs, %{})
    |> case do
      %{^user => channels} -> channel in channels
      _ -> false
    end
  end
  def blocked?(%Conn{}), do: false

  def unblock(conn = %Conn{message: %{user: user, channel: channel}}) do
    earmuff_data = get_state(conn, :earmuffs, %{})
    channels = earmuff_data
               |> Map.get(user, [])
               |> Enum.reject(&(&1 == channel))
    put_state(conn, :earmuffs, Map.put(earmuff_data, user, channels))
  end
end
