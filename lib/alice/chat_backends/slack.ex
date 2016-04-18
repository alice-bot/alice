defmodule Alice.ChatBackends.Slack do
  @moduledoc "Adapter for Slack"
  use Slack

  alias Alice.Conn
  alias Alice.Router
  alias Alice.Earmuffs
  alias Alice.StateBackends.Redis

  def start_link do
    :alice
    |> Application.get_env(:api_key)
    |> start_link(init_state)
  end

  defp init_state do
    case Application.get_env(:alice, :state_backend) do
      :redis -> Redis.get_state
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
    try do
      {message, slack, state}
      |> Conn.make
      |> Conn.sanitize_message
      |> do_handle_message
    rescue
      error ->
        IO.puts(Exception.format(:error, error))
        {:ok, state}
    end
  end

  # Ignore all others
  def handle_message(_message, _slack, state), do: {:ok, state}

  defp do_handle_message(conn = %Conn{}) do
    conn = cond do
      Earmuffs.blocked?(conn) -> Earmuffs.unblock(conn)
      Conn.command?(conn)     -> Router.match_commands(conn)
      true                    -> Router.match_routes(conn)
    end
    {:ok, conn.state}
  end
end
