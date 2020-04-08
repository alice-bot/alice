defmodule Alice.Handlers.UtilsTest do
  use ExUnit.Case
  import Mox
  import Alice.TestHelpers
  import Alice.Handlers.Utils

  test "it should respond approriately" do
    Alice.ChatBackends.OutboundMock
    |> expect(:send_message, fn resp, _, _ when resp in ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"] -> "" end)

    ping(conn())
    verify!()
  end
end
