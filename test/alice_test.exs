defmodule AliceTest do
  use ExUnit.Case

  setup do
    Application.delete_env(:alice, :handlers)
  end

  test "contains a default set of handlers" do
    assert [Alice.Earmuffs, Alice.Handlers.Help, Alice.Handlers.Utils] == Alice.handlers(%{})
  end

  test "properly adds handlers to the list when they're provided" do
    assert [Alice.Earmuffs, Alice.Handlers.Help, Alice.Handlers.Utils, TestHandler] ==
             Alice.handlers(%{handlers: [TestHandler]})
  end
end
