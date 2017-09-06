defmodule Alice.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      supervisor(Alice.Bot.Supervisor, [[name: Alice.Bot.Supervisor]]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
