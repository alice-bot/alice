defmodule Alice.ChatBackends.OutboundSpy do
  @moduledoc """
  A Spy to capture messages sent to the OutboundClient during testing.
  """
  @behaviour Alice.ChatBackends.OutboundClient

  @doc "Sends the message back to the process so it can be retrieved later during the test"
  def send_message(response, channel, slack) do
    send(self(), {:send_message, %{response: response, channel: channel, slack: slack}})
  end

  @doc "Sends a message indicating typing back to the process so it can be retrieved later during the test"
  def indicate_typing(channel, slack) do
    send(self(), {:indicate_typing, %{channel: channel, slack: slack}})
  end
end
