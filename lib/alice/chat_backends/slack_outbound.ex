defmodule Alice.ChatBackends.SlackOutbound do
  @behaviour Alice.ChatBackends.OutboundClient

  def send_message(response, channel, slack), do: Slack.Sends.send_message(response, channel, slack)

  def indicate_typing(channel, slack), do: Slack.Sends.indicate_typing(channel, slack)
end
