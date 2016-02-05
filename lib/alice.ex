defmodule Alice do
  use Application

  @doc """
  List of Alice route handlers to register upon startup
  """
  def handlers do
    [
      Alice.Handlers.Help,
      Alice.Handlers.Utils,
      Alice.Handlers.Random
    ]
  end

  @doc """
  Starts the application and all subprocesses

  *Note:* does not start children in :test env
  """
  def start(_type, _args) do
    Mix.env
    |> children
    |> Supervisor.start_link(strategy: :one_for_one, name: Alice.Supervisor)
  end

  defp children(:test), do: []
  defp children(_env) do
    import Supervisor.Spec, warn: false
    [
      worker(Alice.Router, [handlers]),
      worker(Alice.Bot, [slack_token, %{}])
    ]
  end

  defp slack_token do
    Application.get_env(:alice, :api_key)
  end
end
