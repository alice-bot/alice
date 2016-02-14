defmodule FakeSlack do
  def send_message(text, :channel, :slack) do
    send(self, {:msg, text})
  end
end

defmodule Alice.Router.HelpersTest do
  use ExUnit.Case, async: true
  import Alice.Router.Helpers

  def conn do
    %Alice.Conn{message: %{channel: :channel}, slack: :slack}
  end

  test "reply returns the conn" do
    assert reply("yo", conn) == conn
  end

  test "reply sends a message with Slack.send_message" do
    reply("yo", conn)
    assert_received {:msg, "yo"}
  end

  test "random_reply sends a message from a given list" do
    ["element"] |> random_reply(conn)
    assert_received {:msg, "element"}
  end

  test "chance_reply, when chance passes, replies with the given message" do
    chance_reply(1, "always", conn)
    assert_received {:msg, "always"}
  end

  test "chance_reply, when chance does not pass, when not given negative message, does not reply" do
    chance_reply(0, "never", conn)
    refute_received {:msg, _}
  end

  test "chance_reply, when chance does not pass, when given negative message, replies with negative" do
    chance_reply(0, "positive", "negative", conn)
    refute_received {:msg, "positive"}
    assert_received {:msg, "negative"}
  end
end
