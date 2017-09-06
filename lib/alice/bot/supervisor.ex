defmodule Alice.Bot.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    [worker(Alice.Bot, [], restart: :transient)]
    |> supervise(strategy: :simple_one_for_one)
  end
end
