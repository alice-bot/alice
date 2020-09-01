defmodule Alice.Router.HelpersTest do
  use Alice.HandlerCase
  import Alice.Router.Helpers

  test "reply returns the conn" do
    assert reply("yo", fake_conn()) == fake_conn()
  end

  test "reply sends a message with Slack.send_message/3" do
    reply("yo", fake_conn())

    assert first_reply() == "yo"
  end

  test "reply sends a message to a thread with Slack.send_message/4" do
    fake_conn = fake_conn_with_thread("fake thread")

    conn = reply("yo", fake_conn)
    assert conn.message.thread_ts == "fake thread"
  end

  test "multiple replies can be sent in the same handler" do
    reply("first", fake_conn())
    reply("second", fake_conn())

    assert ["first", "second"] == all_replies()
  end

  test "reply calls random_reply when given a list" do
    reply(["element"], fake_conn())

    assert first_reply() == "element"
  end

  test "random_reply sends a message from a given list" do
    ~w[rabbit hole] |> random_reply(fake_conn())

    assert first_reply() in ~w[rabbit hole]
  end

  test "chance_reply, when chance passes, \
                      replies with the given message" do
    chance_reply(fake_conn(), 1, "always")

    assert first_reply() == "always"
  end

  test "chance_reply, when chance does not pass, \
                      when not given negative message, \
                      does not reply" do
    chance_reply(fake_conn(), 0, "never")

    assert first_reply() == nil
  end

  test "chance_reply, when chance does not pass, \
                      when given negative message, \
                      replies with negative" do
    chance_reply(fake_conn(), 0, "positive", "negative")

    assert all_replies() == ["negative"]
  end

  test "delayed_reply replies after a delay" do
    task = delayed_reply("finally", 1, fake_conn())

    assert %Alice.Conn{} = Task.await(task)
    assert typing?()
    assert first_reply() == "finally"
  end

  test "indicate_typing indicates typing" do
    indicate_typing(fake_conn())

    assert typing?()
  end
end
