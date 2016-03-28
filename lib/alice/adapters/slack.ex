defmodule Alice.Adapters.Slack do
  @moduledoc """
  Alice Adapter for Slack
  """

  use Slack

  def start_link(state), do: start_link(token, state)

  defp token, do: Application.get_env(:alice, :slack_token)

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
    Alice.Bot.handle_message(message, slack, state)
  end

  # Ignore all others
  def handle_message(_message, _slack, state), do: {:ok, state}
end
