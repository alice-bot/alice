defmodule Alice.StateBackends.MemoryTest do
  use ExUnit.Case
  alias Alice.StateBackends.Memory

  test "get returns a value from a map" do
    state = %{key: "value"}
    assert Memory.get(state, :key) == "value"
  end

  test "get returns a default when the key is not found" do
    state = %{}
    assert Memory.get(state, :key, "default") == "default"
  end

  test "put adds an item to state" do
    state = %{}
    assert Memory.put(state, :key, "value") == %{key: "value"}
  end

  test "put converts dates to strings" do
    state = %{}
    assert Memory.put(state, :date, ~D[2020-04-19]) == %{date: "2020-04-19"}
  end

  test "put does not alter other typew" do
    state =
      %{}
      |> Memory.put(:a_map, %{some: :options})
      |> Memory.put(:an_atom, :value)
      |> Memory.put(:a_number, 5)

    assert state == %{
             a_map: %{some: :options},
             an_atom: :value,
             a_number: 5
           }
  end

  test "delete removes an item from the state" do
    state = %{key: "value", another: "thing"}
    assert Memory.delete(state, :another) == %{key: "value"}
  end
end
