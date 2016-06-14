defmodule Alice do
  @moduledoc """
  Alice is a Slack bot framework for Elixir. For more information, please see
  the [readme](https://github.com/alice-bot/alice/blob/master/README.md).
  """
  use Application

  @doc """
  Starts the application and all subprocesses

  *Note:* does not start children in :test env (yet)
  """
  def start(_type, _args) do
    Mix.env
    |> children
    |> Supervisor.start_link(strategy: :one_for_one, name: Alice.Supervisor)
  end

  defp children(:test), do: []
  defp children(_env) do
    import Supervisor.Spec, warn: false
    state_backend_children ++ [
      worker(Alice.State, []),
      worker(Alice.Router, []),
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
