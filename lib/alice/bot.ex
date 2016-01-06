defmodule Alice.Bot do
  use Slack

  require IEx

  def init(initial_state, _slack) do
    # pull state out of persistence layer
    {:ok, initial_state}
  end

  def start_link(initial_state) do
    start_link(Application.get_env(:alice, :api_key), initial_state)
  end

  @doc "Ignore my own messages"
  def handle_message(%{user: id}, %{me: %{id: id}}, state), do: {:ok, state}

  @doc "Handle messages from subscribed channels"
  def handle_message(message = %{type: "message"}, slack, state) do

    Router.route(message, slack)


    message.text
    |> String.match?(~r/dark ?souls?/i)
    |> case do
      true ->
        send_message("http://i.imgur.com/JVwRUtw.gif", message.channel, slack)
      false -> nil
    end

    {:ok, state}
  end

  @doc "Ignore all others"
  def handle_message(_message, _slack, state), do: {:ok, state}
end
