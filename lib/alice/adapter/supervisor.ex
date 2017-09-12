defmodule Alice.Adapter.Supervisor do
  @moduledoc """
  Supervises any Alice.Adapter process that are started.
  """

  use Supervisor

  def start_link(_) do
    Supervisor.start_link([
      worker(Alice.Adapter, [], restart: :transient)
    ], strategy: :simple_one_for_one, name: __MODULE__)
  end

  def init(_), do: :ok
end
