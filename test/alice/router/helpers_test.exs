defmodule Alice.Router.HelpersTest do
  use ExUnit.Case
  import Mox
  import Alice.Router.Helpers

  def conn do
    %Alice.Conn{message: %{channel: :channel}, slack: :slack}
  end

  test "reply returns the conn" do
    Alice.ChatBackends.OutboundMock
    |> stub(:send_message, fn _, _, _ -> "" end)

    assert reply("yo", conn()) == conn()
  end

  test "reply sends a message with Slack.send_message" do
    Alice.ChatBackends.OutboundMock
    |> expect(:send_message, fn "yo", _, _ -> "" end)

    reply("yo", conn())
    verify!()
  end

  test "reply calls random_reply when given a list" do
    Alice.ChatBackends.OutboundMock
    |> expect(:send_message, fn "element", _, _ -> "" end)

    reply(["element"], conn())
    verify!()
  end

  test "random_reply sends a message from a given list" do
    Alice.ChatBackends.OutboundMock
    |> expect(:send_message, fn resp, _, _ when resp in ["rabbit", "hole"] -> "" end)

    ~w[rabbit hole] |> random_reply(conn())
    verify!()
  end

  test "chance_reply, when chance passes, \
                      replies with the given message" do
    Alice.ChatBackends.OutboundMock
    |> expect(:send_message, fn "always", _, _ -> "" end)

    chance_reply(conn(), 1, "always")
    verify!()
  end

  test "chance_reply, when chance does not pass, \
                      when not given negative message, \
                      does not reply" do
    Alice.ChatBackends.OutboundMock
    |> expect(:send_message, 0, fn "never", _, _ -> "" end)

    chance_reply(conn(), 0, "never")
    verify!()
  end

  test "chance_reply, when chance does not pass, \
                      when given negative message, \
                      replies with negative" do
    Alice.ChatBackends.OutboundMock
    |> expect(:send_message, 0, fn "positive", _, _ -> "" end)
    |> expect(:send_message, 1, fn "negative", _, _ -> "" end)

    chance_reply(conn(), 0, "positive", "negative")
    verify!()
  end
end
