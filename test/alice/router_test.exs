defmodule TestHandler do
  use Alice.Router

  route ~r/pattern/, :my_route
  command ~r/pattern/, :my_route

  def my_route(conn) do
    send(self(), {:received, routes()})
    conn
  end
end

defmodule Alice.RouterTest do
  use ExUnit.Case, async: true
  alias Alice.Router
  alias Alice.Conn

  setup do
    Router.start_link([TestHandler])
    :ok
    Logger.configure(level: :warn)
  end

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
    {%{text: "pattern", user: "foo"}, %{users: %{"foo" => %{name: "foo"}}}, :state}
    |> Conn.make()
    |> Router.match_routes()

    assert_received {:received, [{~r/pattern/, :my_route}]}
  end

  test "match_commands calls match_commands on each handler" do
    {%{text: "pattern", user: "foo"}, %{users: %{"foo" => %{name: "foo"}}}, :state}
    |> Conn.make()
    |> Router.match_commands()

    assert_received {:received, [{~r/pattern/, :my_route}]}
  end

  test "it can put state" do
    conn = Alice.Conn.make(:msg, :slk)
    conn = TestHandler.put_state(conn, :key, :val)
    assert conn.state == %{{TestHandler, :key} => :val}
  end

  test "it can get state" do
    conn = Alice.Conn.make(:msg, :slk, %{{TestHandler, :key} => :val})
    assert :val == TestHandler.get_state(conn, :key)
  end
end
