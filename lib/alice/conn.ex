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

  defp user_data(conn=%__MODULE__{message: %{user: user_id}, slack: %{users: users}}) do
    users[user_id]
  end


  def add_captures(conn=%__MODULE__{}, pattern) do
    conn.message
    |> Map.put(:captures, Regex.run(pattern, conn.message.text))
    |> make(conn.slack, conn.state)
  end
end
