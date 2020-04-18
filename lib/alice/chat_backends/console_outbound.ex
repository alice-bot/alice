defmodule Alice.ChatBackends.ConsoleOutbound do
  @moduledoc """
  Sends responses from Alice to the console rather than to an Outbound API
  """
  @behaviour Alice.ChatBackends.OutboundClient

  @doc "Sends the message to the the console"
  def send_message(response, _, _) do
    :ok = IO.puts(response)
  end

  @doc "Sends a message to the console to indicate alice is typing"
  def indicate_typing(channel, _) do
    :ok = IO.puts("... Alice is typing in the #{channel} channel")
  end
end
