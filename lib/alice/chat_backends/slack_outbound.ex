defmodule Alice.ChatBackends.SlackOutbound do
  @moduledoc "An Adapter for outbound messages to Slack."
  @behaviour Alice.ChatBackends.OutboundClient

  @doc "Sends a message back to slack"
  def send_message(response, channel, slack),
    do: Slack.Sends.send_message(response, channel, slack)

  @doc "Makes Alice indicate she's typing in the appropriate channel"
  def indicate_typing(channel, slack), do: Slack.Sends.indicate_typing(channel, slack)
end
