defmodule Alice.Router.HelpersTest do
  use ExUnit.Case, async: true
  import Alice.Router.Helpers

  setup_all do
    Alice.Adapters.start_link(Alice.Adapters.TestAdapter)
    :ok
  end

  def conn do
    %Alice.Conn{message: %{channel: "test"}, slack: :adapter_state}
  end

  test "reply returns the conn" do
    assert reply("yo", conn) == conn
  end

  test "reply sends a message with Slack.send_message" do
    reply("yo", conn)
    assert_received {:msg, "yo"}
  end

  test "reply calls random_reply when given a list" do
    ["element"] |> reply(conn)
    assert_received {:msg, "element"}
  end

  test "random_reply sends a message from a given list" do
    ~w[rabbit hole] |> random_reply(conn)
    assert_received {:msg, resp}
    assert resp in ~w[rabbit hole]
  end

  test "chance_reply, when chance passes, \
                      replies with the given message" do
    chance_reply(conn, 1, "always")
    assert_received {:msg, "always"}
  end

  test "chance_reply, when chance does not pass, \
                      when not given negative message, \
                      does not reply" do
    chance_reply(conn, 0, "never")
    refute_received {:msg, _}
  end

  test "chance_reply, when chance does not pass, \
                      when given negative message, \
                      replies with negative" do
    chance_reply(conn, 0, "positive", "negative")
    refute_received {:msg, "positive"}
    assert_received {:msg, "negative"}
  end
end
