defmodule Alice.Bot do
  use Slack

  def init(initial_state, _slack) do
    # pull state out of persistence layer
    {:ok, initial_state}
  end

  def start_link(initial_state) do
    start_link(Application.get_env(:alice, :api_key), initial_state)
  end

  def handle_connect(_slack, state) do
    IO.puts "Connected to Slack"
    {:ok, state}
  end

  # @doc "Ignore my own messages"
  # def handle_message(%{user: id}, %{me: %{id: id}}, state), do: {:ok, state}

  # Handle messages from subscribed channels
  def handle_message(message = %{type: "message"}, slack, state) do
    conn = {message, slack, state}
           |> Alice.Conn.make
           |> Alice.Router.match_routes
    {:ok, conn.state}
  end

  # Ignore all others
  def handle_message(_message, _slack, state), do: {:ok, state}
end

