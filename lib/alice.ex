defmodule Alice do
  use Application

  @doc """
  List of Alice route handlers to register upon startup
  """
  def handlers(extras) do
    [ Alice.Handlers.Help,
      Alice.Handlers.Utils
    ] ++ extras
  end

  @doc """
  Starts the application and all subprocesses

  *Note:* does not start children in :test env
  """
  def start(_type, extras) do
    Mix.env
    |> children(extras)
    |> Supervisor.start_link(strategy: :one_for_one, name: Alice.Supervisor)
  end

  defp children(:test, _), do: []
  defp children(_env, extras) do
    import Supervisor.Spec, warn: false
    [
      worker(Alice.Router, [handlers(extras)]),
      worker(Alice.Bot, [])
    ]
  end
end
