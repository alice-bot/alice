defmodule AliceTest.TestHandler do
  use Alice.Router
end

defmodule AliceTest do
  use ExUnit.Case

  alias Alice.Handlers.TestHandler

  test "properly adds handlers to the list when they're provided" do
    assert [Alice.Earmuffs, Alice.Handlers.Help, Alice.Handlers.Utils, TestHandler] ==
             Alice.handlers(%{handlers: [TestHandler]})
  end
end
