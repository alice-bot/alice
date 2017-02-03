defmodule Alice.StateTest do
  use ExUnit.Case, aync: true
  alias Alice.State

  setup do
    State.start_link(:memory)
    :ok
  end

  test "getting initial state" do
    assert State.get_state == %{}
  end

  test "putting and retrieving state" do
    State.put_state(:some_state)
    assert State.get_state == :some_state
  end
end
