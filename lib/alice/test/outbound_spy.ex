defmodule Alice.ChatBackends.OutboundSpy do
  @moduledoc """
  A Spy to capture messages sent to the OutboundClient during testing.
  """
  @behaviour Alice.ChatBackends.OutboundClient

  @doc "Sends the message back to the process so it can be retrieved later during the test"
  @spec send_message(message :: String.t(), channel :: String.t(), slack :: map()) :: :ok
  def send_message(response, channel, slack) do
    send(self(), {:send_message, %{response: response, channel: channel, slack: slack}})
    :ok
  end

  @doc "Sends a message indicating typing back to the process so it can be retrieved later during the test"
  @spec indicate_typing(channel :: String.t(), slack :: map()) :: :ok
  def indicate_typing(channel, slack) do
    send(self(), {:indicate_typing, %{channel: channel, slack: slack}})
    :ok
  end
end
