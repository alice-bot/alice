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
  Stops an Alice bot instance along with its handlers and adapters
  """
  def stop_bot(pid) do
    if Process.alive?(pid) do
      %{adapters: adapters, handlers: handlers} = :sys.get_state(pid)
      for adapter <- adapters do
        Supervisor.terminate_child(Alice.Adapter.Supervisor, Process.whereis(adapter))
      end
      for handler <- handlers do
        Supervisor.terminate_child(Alice.Handler.Supervisor, Process.whereis(handler))
      end
      Supervisor.terminate_child(Alice.Bot.Supervisor, pid)
    end
  end

  @doc """
  List currently running bots
  """
  def list_bots do
    Supervisor.which_children(Alice.Bot.Supervisor)
  end
end
