defmodule Alice.ChatBackends.Slack do
  @moduledoc "Adapter for Slack"
  use Slack

  def start_link do
    start_link(Application.get_env(:alice, :api_key), :nostate)
  end

  def handle_connect(_slack, _) do
    IO.puts "Connected to Slack"
    {:ok, :nostate}
  end

  # Ignore my own messages and subtype messages
  def handle_message(%{user: id}, %{me: %{id: id}}, _), do: {:ok, :nostate}
  def handle_message(%{subtype: _}, _slack, _), do: {:ok, :nostate}

  # Respond to messages from subscribed channels
  def handle_message(%{type: "message"} = message, slack, _) do
    Alice.Bot.respond_to_message(message, slack)
    {:ok, :nostate}
  end

  # Ignore all other messages
  def handle_message(_message, _slack, _), do: {:ok, :nostate}
end
