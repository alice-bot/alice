defmodule Alice.RouterTest.TestHandler do
  use Alice.Router

  route ~r/pattern/, :my_route
  command ~r/pattern/, :my_route

  def my_route(conn) do
    reply(conn, "received my_route")
  end
end

defmodule Alice.RouterTest do
  use Alice.HandlersCase, handlers: Alice.RouterTest.TestHandler

  alias Alice.RouterTest.TestHandler
  alias Alice.Router
  alias Alice.Conn

  test "it remembers routes" do
    assert TestHandler.routes() == [{~r/pattern/, :my_route}]
  end

  test "it remembers commands" do
    assert TestHandler.commands() == [{~r/pattern/, :my_route}]
  end

  test "starting the router with an array of handlers registers the handlers" do
    assert Router.handlers() == [TestHandler]
  end

  test "you can only register a handler once" do
    Router.register_handler(TestHandler)
    Router.register_handler(TestHandler)
    assert Router.handlers() == [TestHandler]
  end

  test "match_routes calls match_routes on each handler" do
    conn = fake_conn("pattern")
    Router.match_routes(conn)

    assert first_reply() == "received my_route"
  end

  test "match_commands calls match_commands on each handler" do
    conn = fake_conn("pattern")
    Router.match_commands(conn)

    assert first_reply() == "received my_route"
  end

  test "it can put state" do
    conn = Conn.make(:message, :slack)
    conn = TestHandler.put_state(conn, :key, :val)
    assert conn.state == %{{TestHandler, :key} => :val}
  end

  test "it can get state" do
    conn = Conn.make(:message, :slack, %{{TestHandler, :key} => :val})
    assert :val == TestHandler.get_state(conn, :key)
  end
end
