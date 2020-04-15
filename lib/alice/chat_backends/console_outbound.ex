defmodule Alice.ChatBackends.ConsoleOutbound do
  @moduledoc """
  Sends responses from Alice to the console rather than to an Outbound API
  """
  @behaviour Alice.ChatBackends.OutboundClient

  def send_message(response, _, _) do
    IO.puts(response)
  end

  def indicate_typing(channel, _) do
    IO.puts("... Alice is typing in the #{channel} channel")
  end
end
