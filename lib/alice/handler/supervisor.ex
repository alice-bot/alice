defmodule Alice.Handler.Supervisor do
  @moduledoc """
  Supervises any Alice.Handler process that are started.
  """

  use Supervisor

  def start_link(_) do
    Supervisor.start_link([
      worker(Alice.Handler, [], restart: :transient)
    ], strategy: :simple_one_for_one, name: __MODULE__)
  end

  def init(_), do: :ok
end
