defmodule Alice.Router.HelpersTest do
  use ExUnit.Case
  use Alice.Handlers.Case
  import Alice.Router.Helpers

  test "reply returns the conn" do
    stub_response()

    assert reply("yo", fake_conn()) == fake_conn()
  end

  test "reply sends a message with Slack.send_message" do
    expect_response("yo")

    reply("yo", fake_conn())
    verify!()
  end

  test "reply calls random_reply when given a list" do
    expect_response("element")

    reply(["element"], fake_conn())
    verify!()
  end

  test "random_reply sends a message from a given list" do
    expect_response(["rabbit", "hole"])

    ~w[rabbit hole] |> random_reply(fake_conn())
    verify!()
  end

  test "chance_reply, when chance passes, \
                      replies with the given message" do
    expect_response("always")

    chance_reply(fake_conn(), 1, "always")
    verify!()
  end

  test "chance_reply, when chance does not pass, \
                      when not given negative message, \
                      does not reply" do
    expect_response("never", 0)

    chance_reply(fake_conn(), 0, "never")
    verify!()
  end

  test "chance_reply, when chance does not pass, \
                      when given negative message, \
                      replies with negative" do
    expect_response("positive", 0)
    expect_response("negative", 1)

    chance_reply(fake_conn(), 0, "positive", "negative")
    verify!()
  end
end
