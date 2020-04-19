defmodule Alice.StateBackends.Memory do
  @moduledoc "State backend for Alice using an in-memory map for persistence"

  @behaviour Alice.StateBackends.StateBackend

  defprotocol MemoryValue do
    @fallback_to_any true
    def convert(value)
  end

  defimpl MemoryValue, for: Date do
    def convert(value), do: to_string(value)
  end

  defimpl MemoryValue, for: Any do
    def convert(value), do: value
  end

  def get(map, key, default) do
    Map.get(map, key, default)
  end

  def put(map, key, value) do
    Map.put(map, key, MemoryValue.convert(value))
  end

  def delete(map, key) do
    Map.delete(map, key)
  end
end
