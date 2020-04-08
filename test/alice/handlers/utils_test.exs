defmodule Alice.Handlers.UtilsTest do
  use ExUnit.Case
  import Mox
  import Alice.Handlers.Utils

  def conn do
    %Alice.Conn{message: %{channel: :channel}, slack: :slack}
  end

  test "it should respond approriately" do
    Alice.ChatBackends.OutboundMock
    |> expect(:send_message, fn resp, _, _ when resp in ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"] -> "" end)

    ping(conn())
    verify!()
  end
end
