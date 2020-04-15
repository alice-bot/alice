defmodule Alice.ChatBackends.ConsoleOutbound do
  @behaviour Alice.ChatBackends.OutboundClient

  def send_message(response, _, _) do
    IO.puts(response)
  end

  def indicate_typing(channel, _) do
    IO.puts("... Alice is typing in the #{channel} channel")
  end
end
