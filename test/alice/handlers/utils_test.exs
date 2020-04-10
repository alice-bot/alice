defmodule Alice.Handlers.UtilsTest do
  use ExUnit.Case
  import Alice.Handlers.Case
  import Alice.Handlers.Utils

  test "it should respond to a ping" do
    ping(fake_conn())

    assert Enum.member?(["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"], first_reply())
  end

  test "it should respond with info about the running bot" do
    info(fake_conn())

    {:ok, version} = :application.get_key(:alice, :vsn)
    assert first_reply() == "Alice #{version} - https://github.com/alice-bot"
  end
end
