defmodule Alice.ConnTest do
  use ExUnit.Case, async: true

  alias Alice.Conn

  def conn_with_text(text) do
    Conn.make(%{text: text}, %{})
  end

  test "make makes a conn" do
    assert Conn.make(:m, :sl, :st) == %Conn{message: :m, slack: :sl, state: :st}
  end

  test "make makes a conn with a default state" do
    assert Conn.make(:m, :sl) == %Conn{message: :m, slack: :sl, state: %{}}
  end

  test "make makes a conn with a tuple" do
    assert Conn.make({:m, :sl, :st}) == %Conn{message: :m, slack: :sl, state: :st}
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

  test "tz_offset returns the timezone offset of the user" do
    user = %{tz_offset: "SOME_OFFSET"}
    conn = Conn.make(%{user: "user_id"}, %{users: %{"user_id" => user}})
    assert "SOME_OFFSET" = Conn.tz_offset(conn)
  end

  test "timestamp returns the timestamp of the message" do
    message = %{ts: "SOME_TIMESTAMP"}
    conn = Conn.make(message, :slack)
    assert "SOME_TIMESTAMP" = Conn.timestamp(conn)
  end

  test "add_captures adds regex captures to the conn" do
    conn =
      "hello test world"
      |> conn_with_text
      |> Conn.add_captures(~r/(?:hello) (test) (?<term>.*)/)

    assert conn.message.captures == ["hello test world", "test", "world"]
  end

  test "last_capture returns the last capture in the regex" do
    conn =
      "hello test world"
      |> conn_with_text
      |> Conn.add_captures(~r/(?:hello) (test) (?<term>.*)/)

    assert Conn.last_capture(conn) == "world"
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

  test "sanitize_message removes smart quotes" do
    conn = conn_with_text("“”’")
    assert Conn.sanitize_message(conn).message.text == ~s(""')
  end

  test "sanitize_message removes formatted emails" do
    conn =
      "I email kitten gifs to <mailto:user@example.com|user@example.com>!"
      |> conn_with_text

    clean_string = "I email kitten gifs to user@example.com!"
    assert Conn.sanitize_message(conn).message.text == clean_string
  end

  test "sanitize_message removes formatted urls" do
    conn =
      "I go to <http://cnn.com|cnn.com> for my news!"
      |> conn_with_text

    clean_string = "I go to http://cnn.com for my news!"
    assert Conn.sanitize_message(conn).message.text == clean_string
  end

  test "sanitize_message saves the unaltered text" do
    conn = conn_with_text("“”’")
    assert Conn.sanitize_message(conn).message.original_text == "“”’"
  end

  test "sanitize_message removes formatted emails, links and smart quotes" do
    unsanitized_string = """
    <@U02EGPSD3>’s <http://CNN.com|CNN.com> email address is
    <mailto:user@example.com|user@example.com> and don’t you “forget” it dude!
    Email <@U025Q5H6D> here, at <http://CNN.com|CNN.com>
    """

    sanitized_string = """
    <@U02EGPSD3>'s http://CNN.com email address is
    user@example.com and don't you "forget" it dude!
    Email <@U025Q5H6D> here, at http://CNN.com
    """

    conn = conn_with_text(unsanitized_string)
    assert Conn.sanitize_message(conn).message.text == sanitized_string
  end
end
