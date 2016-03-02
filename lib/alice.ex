defmodule Alice do
  use Application

  @doc """
  List of Alice route handlers to register upon startup
  """
  def handlers(extras) do
    [ Alice.Earmuffs,
      Alice.Handlers.Help,
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
    state_backend_children ++ [
      worker(Alice.Router, [handlers(extras)]),
      worker(Alice.Bot, [])
    ]
  end

  defp state_backend_children do
    case Application.get_env(:alice, :state_backend) do
      :redis -> [Supervisor.Spec.supervisor(Alice.StateBackends.RedixPool, [])]
      _other -> []
    end
  end
end
