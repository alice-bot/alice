defmodule Alice do
  @moduledoc """
  Alice is a Slack bot framework for Elixir. For more information, please see
  the [readme](https://github.com/alice-bot/alice/blob/master/README.md).
  """

  use Application
  import Supervisor.Spec, warn: false

  @doc """
  List of Alice route handlers to register upon startup
  """
  def handlers(), do: default_handlers() ++ Application.get_env(:alice, :handlers, [])

  def handlers(extras) do
    case Map.fetch(extras, :handlers) do
      {:ok, additional_handlers} -> Application.put_env(:alice, :handlers, additional_handlers)
      _ -> nil
    end

    handlers()
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
    state_backend_children() ++
      router(extras) ++
      chat_backend()
  end

  defp state_backend_children do
    case Application.get_env(:alice, :state_backend) do
      :redis -> [supervisor(Alice.StateBackends.RedixPool, [])]
      _other -> []
    end
  end

  defp default_handlers do
    [Alice.Earmuffs, Alice.Handlers.Help, Alice.Handlers.Utils]
  end

  defp chat_backend do
    case Application.get_env(:alice, :chat_backend, Alice.ChatBackends.Slack) do
      :console -> []
      chat_backend -> [worker(chat_backend, [])]
    end
  end

  defp router(extras) do
    [worker(Alice.Router, [handlers(extras)])]
  end
end
