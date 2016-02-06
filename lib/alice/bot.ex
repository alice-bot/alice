defmodule Alice.Bot do
  use Slack

  @token Application.get_env(:alice, :api_key)

  def start_link, do: start_link(@token, %{})

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
    conn = {message, slack, state}
           |> Alice.Conn.make
           |> Alice.Router.match_routes
    {:ok, conn.state}
  end

  # Ignore all others
  def handle_message(_message, _slack, state), do: {:ok, state}
end
