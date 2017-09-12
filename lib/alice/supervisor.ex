defmodule Alice.Supervisor do
  @moduledoc """
  The main Supervisor in an Alice bot's hierarchy. Starts
  and supervises the Bot, Handler, and Adapter supervisors.
  """

  use Supervisor

  def start_link do
    Supervisor.start_link([
      Alice.Adapter.Supervisor,
      Alice.Handler.Supervisor,
      Alice.Bot.Supervisor,
    ], strategy: :one_for_one, name: __MODULE__)
  end

  def init(_), do: :ok
end
