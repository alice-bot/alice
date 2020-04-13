defmodule Alice.HandlerCaseTest.TestHandler do
  use Alice.Router

  route ~r/type/, :typing_route
  route ~r/message/, :my_route
  command ~r/message/, :my_route

  def typing_route(conn) do
    indicate_typing(conn)
  end

  def my_route(conn) do
    reply(conn, "received message")
  end
end

defmodule Alice.HandlerCaseTest do
  use Alice.HandlerCase, handlers: Alice.HandlerCaseTest.TestHandler
  alias Alice.Conn

  test "fake_conn makes a conn" do
    assert fake_conn() ==
             Conn.make(
               %{channel: :channel, text: "", user: :fake_user},
               %{me: %{id: :alice}, users: %{fake_user: %{id: :fake_user, name: "fake_user"}}},
               nil
             )
  end

  test "fake_conn makes a conn with a message" do
    assert fake_conn("message") ==
             Conn.make(
               %{channel: :channel, text: "message", user: :fake_user},
               %{me: %{id: :alice}, users: %{fake_user: %{id: :fake_user, name: "fake_user"}}},
               nil
             )
  end

  test "fake_conn makes a conn with state" do
    assert fake_conn("message", state: %{some: "state"}) ==
             Conn.make(
               %{channel: :channel, text: "message", user: :fake_user},
               %{me: %{id: :alice}, users: %{fake_user: %{id: :fake_user, name: "fake_user"}}},
               %{some: "state"}
             )
  end

  test "fake_conn makes a conn with captures" do
    assert fake_conn("find this capture", capture: ~r/\Afind this (capture)\z/) ==
             Conn.make(
               %{
                 channel: :channel,
                 text: "find this capture",
                 user: :fake_user,
                 captures: ["find this capture", "capture"]
               },
               %{me: %{id: :alice}, users: %{fake_user: %{id: :fake_user, name: "fake_user"}}},
               nil
             )
  end

  test "send_message sends a message given a conn" do
    conn = fake_conn("test message")
    send_message(conn)

    assert first_reply() == "received message"
  end

  test "send_message sends a message given text" do
    send_message("<@alice> test message")

    assert first_reply() == "received message"
  end

  test "all_replies is empty when there are no replies" do
    assert all_replies() == []
  end

  test "all_replies returns all the replies" do
    send_message("test message")
    send_message("test message")

    assert all_replies() == ["received message", "received message"]
  end

  test "first_reply returns nil when there are no replies" do
    assert is_nil(first_reply())
  end

  test "first_reply returns the first reply" do
    send_message("test message")
    send_message("test message")

    assert first_reply() == "received message"
  end

  test "typing? is false when typing has not been indicated" do
    refute typing?()
  end

  test "typing? is true when typing has been indicated" do
    send_message("type something")

    assert typing?()
  end
end
