defmodule Alice.StateBackends.RedixPool do
  @moduledoc "Redis connection pool for the `StateBackends.Redis`"

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    pool_opts = [
      name: {:local, :redix_poolboy},
      worker_module: Redix,
      size: 10,
      max_overflow: 5
    ]

    redis_connection_params = Application.get_env(:alice, :redis)

    children = [
      :poolboy.child_spec(:redix_poolboy, pool_opts, redis_connection_params)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def command!(command) do
    :poolboy.transaction(:redix_poolboy, &Redix.command!(&1, command))
  end

  def pipeline!(commands) do
    :poolboy.transaction(:redix_poolboy, &Redix.pipeline!(&1, commands))
  end
end
