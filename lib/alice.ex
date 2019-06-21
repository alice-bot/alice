defmodule Alice do
  @moduledoc """
  Alice is a Slack bot framework for Elixir. For more information, please see
  the [readme](https://github.com/alice-bot/alice/blob/master/README.md).
  """

  use Application

  @doc """
  List of Alice route handlers to register upon startup
  """
  def handlers(extras) do
    case Map.fetch(extras, :handlers) do
      {:ok, additional_handlers} -> default_handlers() ++ additional_handlers
      _ -> default_handlers()
    end
  end

  @doc """
  Starts the application and all subprocesses

  *Note:* does not start children in :test env
  """
  def start(_type, extras) do
    Mix.env()
    |> children(extras)
    |> Supervisor.start_link(strategy: :one_for_one, name: Alice.Supervisor)
  end

  defp children(:test, _), do: []

  defp children(_env, extras) do
    import Supervisor.Spec, warn: false

    state_backend_children() ++
      [
        worker(Alice.Router, [handlers(extras)]),
        worker(Alice.ChatBackends.Slack, [])
      ]
  end

  defp state_backend_children do
    case Application.get_env(:alice, :state_backend) do
      :redis -> [Supervisor.Spec.supervisor(Alice.StateBackends.RedixPool, [])]
      _other -> []
    end
  end

  defp default_handlers do
    [Alice.Earmuffs, Alice.Handlers.Help, Alice.Handlers.Utils]
  end
end
