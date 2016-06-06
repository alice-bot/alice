defmodule AliceTest do
  use ExUnit.Case, async: true

  def default_handlers do
    [Alice.Earmuffs, Alice.Handlers.Help, Alice.Handlers.Utils]
  end

  test "contains a default set of handlers" do
    assert Alice.handlers(%{}) == default_handlers
  end

  test "properly adds handlers to the list when they're provided" do
    assert Alice.handlers(%{handlers: [Alice.Handlers.TestHandler]}) ==
           default_handlers ++ [Alice.Handlers.TestHandler]
  end
end
