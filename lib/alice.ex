defmodule Alice do
  @moduledoc """
  Alice

  ## Starting an Alice instance

      {:ok, pid} = Alice.start_bot(Rebecca.Bot, name: "rebeccaaaaa")

  ## Stopping an Alice instance

      Alice.stop_bot(pid)
  """

  use Application

  @doc false
  def start(_type, _args) do
    Alice.Supervisor.start_link()
  end

  @doc """
  Spawns a new instance of an Alice bot
  """
  def start_bot(bot, opts \\ []) do
    Supervisor.start_child(Alice.Bot.Supervisor, [bot, opts])
  end

  @doc """
  Stops an Alice bot instance
  """
  def stop_bot(pid) do
    Supervisor.terminate_child(Alice.Bot.Supervisor, pid)
  end

  @doc """
  List currently running bots
  """
  def list_bots do
    Supervisor.which_children(Alice.Bot.Supervisor)
  end
end
