defmodule Alice.StateBackends.Redis do
  @moduledoc "State backend for Alice using Redis for persistence"

  @behaviour Alice.StateBackends.StateBackend

  alias Alice.StateBackends.RedixPool

  # NOTE: This handles migration of the data in redis from the old stringified
  #       elixir to use the new method of encoding in JSON. Please remove this
  #       after most people have moved to this version.
  @migration_key "Alice.State.Migrated.v0.3.5"

  # NOTE: This handles migration of the data in redis from the old stringified
  #       elixir to use the new method of encoding in JSON. Please remove this
  #       after most people have moved to this version.
  defp migrate_redis do
    ["GET", @migration_key]
    |> RedixPool.command!()
    |> case do
      nil -> migrate_redis!()
      _ -> :ok
    end
  end

  # NOTE: This handles migration of the data in redis from the old stringified
  #       elixir to use the new method of encoding in JSON. Please remove this
  #       after most people have moved to this version.
  defp migrate_redis! do
    state = do_get_state()
    Enum.each(state, fn {key, val} -> put(state, key, val) end)
    RedixPool.command!(["SET", @migration_key, true])
    :ok
  end

  def get(_state, key, default \\ nil) do
    ["GET", encode_key(key)]
    |> RedixPool.command!()
    |> handle_get_result(default)
  end

  defp handle_get_result(nil, default), do: default

  # NOTE: This handles migration of the data in redis from the old stringified
  #       elixir to use the new method of encoding in JSON. Please remove this
  #       after most people have moved to this version.
  @dialyzer {:nowarn_function, handle_get_result: 2}
  defp handle_get_result(encoded_value, _default) do
    case Poison.decode(encoded_value) do
      {:ok, decoded_value} ->
        decoded_value

      _ ->
        {decoded, _} = Code.eval_string(encoded_value)
        decoded
    end
  end

  def put(state, key, value) do
    RedixPool.command!(["SET", encode_key(key), Poison.encode!(value)])
    Map.put(state, key, value)
  end

  def delete(state, key) do
    RedixPool.command!(["DEL", encode_key(key)])
    Map.delete(state, key)
  end

  # NOTE: This handles migration of the data in redis from the old stringified
  #       elixir to use the new method of encoding in JSON. Please remove this
  #       after most people have moved to this version.
  def get_state do
    migrate_redis()
    do_get_state()
  end

  defp do_get_state do
    keys()
    |> Stream.map(fn key -> {key, get(:redis, key)} end)
    |> Enum.into(%{})
  end

  defp keys do
    ["KEYS", "*|Alice.State"]
    |> RedixPool.command!()
    |> Enum.map(&decode_key/1)
  end

  defp encode_key(key) do
    inspect(key) <> "|Alice.State"
  end

  defp decode_key(key) do
    [key | _] = String.split(key, "|Alice.State")
    {key, _} = Code.eval_string(key)
    key
  end
end
