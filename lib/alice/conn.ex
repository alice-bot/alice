defmodule Alice.Conn do
  @moduledoc """
  Alice.Conn defines a struct that is used throughout alice to hold state
  during the lifetime of a message handling.

  An Alice.Conn struct contains 3 things: `message`, the incoming message
  that is currently being handled; `slack`, a data structure from the Slack
  library that holds all the information about the Slack instance; and `state`,
  which is the state of the bot that is persisted between messages. State
  defaults to an in-memory Map, but may be configured to be backed by Redis.

  The Alice.Conn module also contains several helper functions that operate on
  Conn structs.
  """

  defstruct([:message, :slack, :state])

  @doc """
  Convenience function to make a new `Alice.Conn` struct
  """
  def make({message, slack, state}) do
    %__MODULE__{message: message, slack: slack, state: state}
  end
  def make(message, slack, state \\ %{}) do
    make({message, slack, state})
  end

  @doc """
  Returns a boolean depending on whether or
  not the incoming message is a command
  """
  def command?(conn=%__MODULE__{}) do
    String.contains?(conn.message.text, "<@#{conn.slack.me.id}>")
  end

  @doc """
  Returns the name of the user for the incoming message
  """
  def user(conn=%__MODULE__{}) do
    user_data(conn).name
  end

  @doc """
  Builds a string to use as an @reply back to the user who sent the message
  """
  def at_reply_user(conn=%__MODULE__{}) do
    "<@#{user_data(conn).id}>"
  end

  defp user_data(%__MODULE__{message: %{user: id}, slack: %{users: users}}) do
    users[id]
  end

  @doc """
  Used internally to add the regex captures to the `message`
  """
  def add_captures(conn=%__MODULE__{}, pattern) do
    conn.message
    |> Map.put(:captures, Regex.run(pattern, conn.message.text))
    |> make(conn.slack, conn.state)
  end

  @doc """
  Used internally to get namespaced state
  """
  def get_state_for(conn=%__MODULE__{}, namespace, default \\ nil) do
    state_backend.get(conn.state, namespace, default)
  end

  @doc """
  Used internally to put namespaced state
  """
  def put_state_for(conn=%__MODULE__{}, namespace, value) do
    new_state = state_backend.put(conn.state, namespace, value)
    make(conn.message, conn.slack, new_state)
  end

  @doc """
  Used internally to delete namespaced state
  """
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
