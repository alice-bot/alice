defmodule Alice.Bot do
  use Slack

  def handle_connect(_slack, state) do
    IO.puts "Connected to Slack"
    {:ok, state}
  end

  # working sample
  # def handle_message(message = %{type: "message"}, slack, state) do
  #   send_message("http://i.imgur.com/7PAYDm3.gif", message.channel, slack)
  #   {:ok, state}
  # end

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
