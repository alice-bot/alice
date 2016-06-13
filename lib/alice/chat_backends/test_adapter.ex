defmodule Alice.ChatBackends.TestAdapter do
  @moduledoc """
  This is an adapter for testing handlers
  """
  use GenServer

  @doc """
  Fakes out start_link function
  """
  def start_link do
    {:ok, self}
  end

  @doc """
  Handles an incoming message, passing it off to `Alice.Bot`
  """
  def handle_message(message, _adapter_state) do
    Alice.Bot.respond_to_message(message, state)
    {:ok, state}
  end

  @doc """
  Creates placeholder adapter state
  """
  def state do
    {:ok, %{
      me: %{id: "alice"},
      users: %{
        "test"  => %{id: "test",  name: "test"},
        "alice" => %{id: "alice", name: "alice"}
      }
    } }
  end

  @doc """
  Sends a message to the test.
  """
  def send_message(message, "test", _adapter_state) do
    send(self, {:msg, message})
  end


  @doc """
  Sends typing indication to test
  """
  def indicate_typing("test", _adapter_state) do
    send(self, :typing)
  end
end
