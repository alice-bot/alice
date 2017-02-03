defmodule Alice.Adapters do
  @moduledoc false

  def start_link(opts \\ [start_adapter: true]) do
    if opts[:start_adapter], do: selected_adapter.start_link
    {:ok, selected_adapter}
  end

  @doc """
  Selects adapter, defaults to Slack
  """
  def selected_adapter do
    Application.get_env(:alice, :adapter, Alice.Adapters.Slack)
  end
end
