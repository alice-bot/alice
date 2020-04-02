defmodule Alice.ChatBackends.Slack do
  @moduledoc "Adapter for Slack"
  use Slack

  alias Alice.Conn
  alias Alice.Router
  alias Alice.Earmuffs
  alias Alice.StateBackends.Redis

  def start_link do
    Slack.Bot.start_link(
      __MODULE__,
      init_state(),
      get_token(),
      %{name: __MODULE__}
    )
  end

  defp init_state do
    case Application.get_env(:alice, :state_backend) do
      :redis -> Redis.get_state()
      _else -> %{}
    end
  end

  defp get_token do
    Application.get_env(:alice, :api_key)
  end

  def send_message(message, channel) do
    send(__MODULE__, {:message, message, channel})
    {:ok}
  end

  def handle_connect(slack, state) do
    IO.puts("Connected to Slack as @#{slack.me.name}")
    {:ok, state}
  end

  # Ignore my own messages
  def handle_event(%{user: id}, %{me: %{id: id}}, state), do: {:ok, state}

  # Ignore subtypes
  def handle_event(%{subtype: _}, _slack, state), do: {:ok, state}

  # Handle messages from subscribed channels
  def handle_event(message = %{type: "message"}, slack, state) do
    try do
      slack_users = Map.get(Slack.Web.Users.list(%{token: get_token()}), "members")
      slack_data = Map.put(slack, :users, slack_users)

      {message, slack_data, state}
      |> Conn.make()
      |> Conn.sanitize_message()
      |> handle_message
    rescue
      error ->
        IO.puts(Exception.format(:error, error))
        {:ok, state}
    end
  end

  # Ignore all others
  def handle_event(_message, _slack, state), do: {:ok, state}

  # Called when any other message is received in the process mailbox.
  # Used to send message outside handlers
  def handle_info({:message, text, channel}, slack, state) do
    send_message(text, channel, slack)

    {:ok, state}
  end

  def handle_info(_message, _slack, state), do: {:ok, state}

  defp handle_message(conn = %Conn{}) do
    conn =
      cond do
        Earmuffs.blocked?(conn) -> Earmuffs.unblock(conn)
        Conn.command?(conn) -> Router.match_commands(conn)
        true -> Router.match_routes(conn)
      end

    {:ok, conn.state}
  end
end
