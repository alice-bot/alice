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
    conn = Alice.Conn.add_captures(conn_with_text("hello test world"), ~r/(?:hello) (test) (?<term>.*)/)
    assert conn.message.captures == ["hello test world", "test", "world"]
  end
end
