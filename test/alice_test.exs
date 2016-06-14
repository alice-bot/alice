defmodule AliceTest do
  use ExUnit.Case, async: true
  doctest Alice

  alias Alice.Handlers.TestHandler

  test "contains a default set of handlers" do
    assert [Alice.Earmuffs, Alice.Handlers.Help, Alice.Handlers.Utils] == Alice.handlers(%{})
  end

  test "properly adds handlers to the list when they're provided" do
    assert [Alice.Earmuffs,
            Alice.Handlers.Help,
            Alice.Handlers.Utils,
            Alice.Handlers.TestHandler] ==
          Alice.handlers(%{handlers: [TestHandler]})
  end
end
