defmodule Alice.ChatBackends do
  def start_link(adapter) do
    Agent.start_link(fn -> adapter end, name: __MODULE__)
    adapter.start_link
    {:ok, adapter}
  end

  def selected_adapter do
    Agent.get(__MODULE__, fn(adapter) -> adapter end)
  end
end
