defmodule Alice.Handlers.UtilsTest do
  use ExUnit.Case
  use Alice.Handlers.Case
  import Alice.Handlers.Utils

  test "it should respond to a ping" do
    expect_response(["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"])

    ping(fake_conn())
    verify!()
  end

  test "it should respond with info about the running bot" do
    expect_response(_, 2)

    info(fake_conn())
    verify!()
  end
end
