defmodule Alice.ChatBackends.SlackOutbound do
  @moduledoc "An Adapter for outbound messages to Slack."
  @behaviour Alice.ChatBackends.OutboundClient

  @doc "Sends a message back to slack"
  @spec send_message(message :: String.t(), channel :: String.t(), slack :: map()) :: String.t()
  def send_message(message, channel, slack) do
    Slack.Sends.send_message(message, channel, slack)
  end

  @doc "Makes Alice indicate she's typing in the appropriate channel"
  @spec indicate_typing(channel :: String.t(), slack :: map()) :: String.t()
  def indicate_typing(channel, slack) do
    Slack.Sends.indicate_typing(channel, slack)
  end
end
