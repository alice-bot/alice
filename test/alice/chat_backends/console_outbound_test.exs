defmodule Alice.ChatBackends.ConsoleOutboundTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  test "It should print the message to the console when it receives it" do
    output =
      capture_io(fn ->
        Alice.ChatBackends.ConsoleOutbound.send_message("test message", nil, nil)
      end)

    assert output == "test message\n"
  end

  test "It should alert the console that Alice is typing" do
    output =
      capture_io(fn ->
        Alice.ChatBackends.ConsoleOutbound.indicate_typing("test", nil)
      end)

    assert output == "... Alice is typing in the test channel\n"
  end
end
