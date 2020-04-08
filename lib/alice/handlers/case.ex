defmodule Alice.Handlers.Case do
  def start() do
    Application.ensure_all_started(:mox)
    Mox.defmock(Alice.ChatBackends.OutboundMock, for: Alice.ChatBackends.OutboundClient)
  end

  def fake_conn do
    %Alice.Conn{message: %{channel: :channel}, slack: :slack}
  end

  defmacro __using__(_opts) do
    quote do
      import Mox
      import Alice.Handlers.Case
    end
  end

  defmacro expect_response(response, times_expected \\ 1)
  defmacro expect_response(response, times_expected) when is_list(response) do
    quote do
      Alice.ChatBackends.OutboundMock
      |> expect(:send_message, unquote(times_expected), fn resp, _, _ when resp in unquote(response) -> "" end)
    end
  end
  defmacro expect_response(response, times_expected) do
    quote do
      Alice.ChatBackends.OutboundMock
      |> expect(:send_message, unquote(times_expected), fn unquote(response), _, _ -> "" end)
    end
  end

  defmacro stub_response() do
    quote do
      Alice.ChatBackends.OutboundMock
      |> stub(:send_message, fn _, _, _ -> "" end)
    end
  end
end
