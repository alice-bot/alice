defmodule Alice.ChatBackends do
  def start_link(adapter, opts \\ [start_adapter: true]) do
    {:ok, pid} = Agent.start_link(fn -> adapter end, name: __MODULE__)
    if opts[:start_adapter], do: adapter.start_link
    {:ok, pid, adapter}
  end

  def selected_adapter do
    Agent.get(__MODULE__, fn(adapter) -> adapter end)
  end
end
