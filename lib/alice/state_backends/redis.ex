defmodule Alice.StateBackends.Redis do
  alias Alice.StateBackends.RedixPool

  def get(_state, key, default \\ nil) do
    RedixPool.command!(["GET", encode_key(key)])
    |> case do
      nil   -> default
      value -> value |> Code.eval_string |> elem(0)
    end
  end

  def put(state, key, value) do
    RedixPool.command!(["SET", encode_key(key), inspect(value)])
    Map.put(state, key, value)
  end

  def get_state do
    keys
    |> Enum.map(fn(key) -> {key, get(nil, key)} end)
    |> Enum.into(%{})
  end

  defp keys do
    RedixPool.command!(["KEYS", "*|Alice.State"])
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
