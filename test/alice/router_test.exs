defmodule TestHandler do
  def match_routes(_conn), do: send(self, :received)
end

defmodule Alice.RouterTest do
  use ExUnit.Case
  alias Alice.Router

  setup do
    Router.start_link([TestHandler])
    :ok
  end

  test "starting the router with an array of handlers registers them immediately" do
    assert Router.handlers == [TestHandler]
  end

  test "you can only register a handler once" do
    Router.register_handler(TestHandler)
    Router.register_handler(TestHandler)
    assert Router.handlers == [TestHandler]
  end

  test "match_routes calls match_routes on each handler" do
    Router.match_routes(:fake_conn)
    assert_received :received
  end
end
