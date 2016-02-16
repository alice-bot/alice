defmodule Alice.Conn do
  defstruct([:message, :slack, :state])

  def make({message, slack, state}) do
    %__MODULE__{message: message, slack: slack, state: state}
  end
  def make(message, slack, state \\ %{}) do
    make({message, slack, state})
  end

  def command?(conn=%__MODULE__{}) do
    String.contains?(conn.message.text, "<@#{conn.slack.me.id}>")
  end

  def user(conn=%__MODULE__{}) do
    user_data(conn).name
  end

  def at_reply_user(conn=%__MODULE__{}) do
    "<@#{user_data(conn).id}>"
  end

  defp user_data(%__MODULE__{message: %{user: user_id}, slack: %{users: users}}) do
    users[user_id]
  end

  def add_captures(conn=%__MODULE__{}, pattern) do
    conn.message
    |> Map.put(:captures, Regex.run(pattern, conn.message.text))
    |> make(conn.slack, conn.state)
  end

  def get_state_for(conn=%__MODULE__{}, namespace, default \\ nil) do
    state_backend.get(conn.state, namespace, default)
  end

  def put_state_for(conn=%__MODULE__{}, namespace, value) do
    new_state = state_backend.put(conn.state, namespace, value)
    make(conn.message, conn.slack, new_state)
  end

  def delete_state_for(conn=%__MODULE__{}, namespace) do
    new_state = state_backend.delete(conn.state, namespace)
    make(conn.message, conn.slack, new_state)
  end

  defp state_backend do
    case Application.get_env(:alice, :state_backend) do
      :redis -> Alice.StateBackends.Redis
      _other -> Map
    end
  end
end
