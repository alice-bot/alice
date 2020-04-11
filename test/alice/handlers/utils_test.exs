defmodule Alice.Handlers.UtilsTest do
  use Alice.HandlersCase, handlers: Alice.Handlers.Utils

  test "it should respond to a ping" do
    send_message("ping")

    assert first_reply() in ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"]
  end

  test "it should respond with info about the running bot" do
    send_message("<@alice> info")

    {:ok, version} = :application.get_key(:alice, :vsn)
    assert first_reply() == "Alice #{version} - https://github.com/alice-bot"
  end
end
