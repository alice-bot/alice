defmodule Alice.StateBackends.Redis do
  @moduledoc "State backend for Alice using Redis for persistence"

  alias Alice.StateBackends.RedixPool

  def get(_state, key, default \\ nil) do
    ["GET", encode_key(key)]
    |> RedixPool.command!
    |> case do
      nil   -> default
      value -> value |> Code.eval_string |> elem(0)
    end
  end

  def put(state, key, value) do
    RedixPool.command!(["SET", encode_key(key), inspect(value)])
    Map.put(state, key, value)
  end

  def delete(state, key) do
    RedixPool.command!(["DEL", encode_key(key)])
    Map.delete(state, key)
  end

  def get_state do
    keys
    |> Stream.map(fn(key) -> {key, get(nil, key)} end)
    |> Enum.into(%{})
  end

  defp keys do
    ["KEYS", "*|Alice.State"]
    |> RedixPool.command!
    |> Enum.map(&decode_key/1)
  end

  defp encode_key(key) do
    inspect(key) <> "|Alice.State"
  end

  defp decode_key(key) do
    [key|_] = String.split(key, "|Alice.State")
    {key,_} = Code.eval_string(key)
    key
  end
end
