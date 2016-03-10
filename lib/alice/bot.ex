defmodule Alice.Bot do
  @moduledoc "Adapter for Slack"
  use Slack

  def start_link do
    :alice
    |> Application.get_env(:api_key)
    |> start_link(init_state)
  end

  defp init_state do
    case Application.get_env(:alice, :state_backend) do
      :redis -> Alice.StateBackends.Redis.get_state
      _else -> %{}
    end
  end

  def handle_connect(_slack, state) do
    IO.puts "Connected to Slack"
    {:ok, state}
  end

  # Ignore my own messages
  def handle_message(%{user: id}, %{me: %{id: id}}, state), do: {:ok, state}

  # Ignore subtypes
  def handle_message(%{subtype: _}, _slack, state), do: {:ok, state}

  # Handle messages from subscribed channels
  def handle_message(message = %{type: "message"}, slack, state) do
    conn = {message, slack, state} |> Alice.Conn.make
                                   |> Alice.Conn.sanitize_message
    conn = cond do
      Alice.Earmuffs.blocked?(conn) -> Alice.Earmuffs.unblock(conn)
      Alice.Conn.command?(conn)     -> Alice.Router.match_commands(conn)
      true                          -> Alice.Router.match_routes(conn)
    end
    {:ok, conn.state}
  end

  # Ignore all others
  def handle_message(_message, _slack, state), do: {:ok, state}
end
