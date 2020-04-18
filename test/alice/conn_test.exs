defmodule Alice.ConnTest do
  use ExUnit.Case

  alias Alice.Conn

  defp make_conn() do
    make_conn("message")
  end

  defp make_conn(text) do
    make_conn(text, "fake_user")
  end

  defp make_conn(text, user) when is_binary(user) do
    make_conn(text, user, %{})
  end

  defp make_conn(text, opts) when is_map(opts) do
    make_conn(text, "fake_user", opts)
  end

  defp make_conn(text, user, opts) do
    tz_offset = Map.get(opts, :tz_offset, 0)
    ts = Map.get(opts, :ts, 0)

    %Conn{
      message: %{text: text, channel: "channel_id", user: "#{user}_id", ts: ts},
      slack: %{
        me: %{id: "alice_id"},
        users: [
          %{"id" => "alice_id", "name" => "alice"},
          %{"id" => "#{user}_id", "name" => user, "tz_offset" => tz_offset}
        ]
      },
      state: %{}
    }
  end

  defp with_state(conn, state) do
    %{conn | state: state}
  end

  test "you can inspect a conn" do
    conn = Conn.make(:message, :slack, :state)
    assert inspect(conn) == "%Alice.Conn{message: :message, slack: %{...}, state: :state}"
  end

  test "make makes a conn" do
    assert Conn.make(:message, :slack, :state) == %Conn{
             message: :message,
             slack: :slack,
             state: :state
           }
  end

  test "make makes a conn with a default state" do
    assert Conn.make(:message, :slack) == %Conn{
             message: :message,
             slack: :slack,
             state: %{}
           }
  end

  test "make makes a conn with a tuple" do
    assert Conn.make({:message, :slack, :state}) == %Conn{
             message: :message,
             slack: :slack,
             state: :state
           }
  end

  test "command? is true when the bot is @username'd" do
    conn = make_conn("<@alice_id>")
    assert Conn.command?(conn)
  end

  test "command? is false when the bot is not mentioned" do
    conn = make_conn("sup alice")
    refute Conn.command?(conn)
  end

  test "user returns the username of the messaging user" do
    conn = make_conn("", "username")
    assert "username" = Conn.user(conn)
  end

  test "tz_offset returns the timezone offset of the user" do
    conn = make_conn("", %{tz_offset: -25_200})
    assert -25_200 = Conn.tz_offset(conn)
  end

  test "timestamp returns the timestamp of the message" do
    conn = make_conn("", %{ts: "TIMESTAMP"})
    assert "TIMESTAMP" = Conn.timestamp(conn)
  end

  test "at_reply_user formats an at reply that slack will recognize" do
    conn = make_conn("", "user")
    assert Conn.at_reply_user(conn) == "<@user_id>"
  end

  test "add_captures adds regex captures to the conn" do
    conn =
      "hello test world"
      |> make_conn()
      |> Conn.add_captures(~r/(?:hello) (test) (?<term>.*)/)

    assert conn.message.captures == ["hello test world", "test", "world"]
  end

  test "last_capture returns the last capture in the regex" do
    conn =
      "hello test world"
      |> make_conn()
      |> Conn.add_captures(~r/(?:hello) (test) (?<term>.*)/)

    assert Conn.last_capture(conn) == "world"
  end

  test "get_state_for returns the state for a given namespace" do
    conn =
      make_conn()
      |> with_state(%{{:some, :namespace} => :value})

    assert Conn.get_state_for(conn, {:some, :namespace}) == :value
  end

  test "get_state_for returns optional default if key isn't found" do
    assert Conn.get_state_for(make_conn(), :namespace, :default) == :default
  end

  test "put_state_for replaces the state for a given namespace" do
    conn =
      make_conn()
      |> with_state(%{namespace: :value})
      |> Conn.put_state_for(:namespace, :new_value)

    assert Conn.get_state_for(conn, :namespace) == :new_value
  end

  test "put_state_for preserves the rest of the conn" do
    conn = with_state(make_conn(), %{other: :other})

    new_conn = Conn.put_state_for(conn, :namespace, :value)

    assert new_conn.message == conn.message
    assert new_conn.slack == conn.slack
    assert new_conn.state == %{other: :other, namespace: :value}
  end

  test "delete_state_for deletes the state for a given namespace" do
    conn =
      make_conn()
      |> with_state(%{{:some, :namespace} => :value})

    conn = Conn.delete_state_for(conn, {:some, :namespace})

    assert Conn.get_state_for(conn, :namespace) == nil
  end

  test "sanitize_message removes smart quotes" do
    conn = make_conn("“”’")
    assert Conn.sanitize_message(conn).message.text == ~s(""')
  end

  test "sanitize_message removes formatted emails" do
    dirty_message = "I email kitten gifs to <mailto:user@example.com|user@example.com>!"
    conn = make_conn(dirty_message)
    clean_message = "I email kitten gifs to user@example.com!"

    assert Conn.sanitize_message(conn).message.text == clean_message
  end

  test "sanitize_message removes formatted urls" do
    dirty_message = "I go to <https://reddit.com|reddit.com> for my memes!"
    conn = make_conn(dirty_message)
    clean_message = "I go to https://reddit.com for my memes!"

    assert Conn.sanitize_message(conn).message.text == clean_message
  end

  test "sanitize_message saves the unaltered text" do
    conn = make_conn("“”’")
    assert Conn.sanitize_message(conn).message.original_text == "“”’"
  end

  test "sanitize_message removes formatted emails, links and smart quotes" do
    dirty_message = """
    <@U02EGPSD3>’s <http://EXAMPLE.com|EXAMPLE.com> email address is
    <mailto:user@example.com|user@example.com> and don’t you “forget” it dude!
    Email <@U025Q5H6D> here, at <http://EXAMPLE.com|EXAMPLE.com>
    """

    clean_message = """
    <@U02EGPSD3>'s http://EXAMPLE.com email address is
    user@example.com and don't you "forget" it dude!
    Email <@U025Q5H6D> here, at http://EXAMPLE.com
    """

    conn = make_conn(dirty_message)
    assert Conn.sanitize_message(conn).message.text == clean_message
  end
end
