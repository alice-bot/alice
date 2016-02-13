defmodule Alice.ConnTest do
  use ExUnit.Case, async: true

  alias Alice.Conn

  def conn_with_text(text) do
    Conn.make(%{text: text}, %{})
  end

  test "make makes a conn" do
    assert Conn.make(:m, :sl, :st)
        == %Conn{message: :m, slack: :sl, state: :st}
  end

  test "make makes a conn with a default state" do
    assert Conn.make(:m, :sl)
        == %Conn{message: :m, slack: :sl, state: %{}}
  end

  test "make makes a conn with a tuple" do
    assert Conn.make({:m, :sl, :st})
        == %Conn{message: :m, slack: :sl, state: :st}
  end

  test "command? is true when the bot is @username'd" do
    conn = Conn.make(%{text: "<@my_id>"}, %{me: %{id: "my_id"}})
    assert Conn.command?(conn)
  end

  test "command? is false when the bot is not mentioned" do
    conn = Conn.make(%{text: "sup alice"}, %{me: %{id: "my_id"}})
    refute Conn.command?(conn)
  end

  test "user returns the username of the messaging user" do
    user = %{name: "username"}
    conn = Conn.make(%{user: "user_id"}, %{users: %{"user_id" => user}})
    assert "username" = Conn.user(conn)
  end

  test "add_captures adds regex captures to the conn" do
    conn = Conn.add_captures(conn_with_text("hello test world"), ~r/(?:hello) (test) (?<term>.*)/)
    assert conn.message.captures == ["hello test world", "test", "world"]
  end

  test "get_state_for returns the state for a given namespace" do
    state = %{{:some, :namespace} => :value}
    conn = Conn.make(:msg, :slk, state)
    assert Conn.get_state_for(conn, {:some, :namespace}) == :value
  end

  test "get_state_for returns optional default if key isn't found" do
    conn = Conn.make(:msg, :slk)
    assert Conn.get_state_for(conn, :namespace, :default) == :default
  end

  test "put_state_for replaces the state for a given namespace" do
    state = %{:namespace => :value}
    conn = Conn.make(:msg, :slk, state)
    conn = Conn.put_state_for(conn, :namespace, :new_value)
    assert Conn.get_state_for(conn, :namespace) == :new_value
  end

  test "put_state_for preserves the rest of the conn" do
    conn = Conn.make(:msg, :slk, %{other: :other})
    conn = Conn.put_state_for(conn, :namespace, :value)
    assert {:msg, :slk, :other} = {conn.message, conn.slack, conn.state.other}
  end
end
