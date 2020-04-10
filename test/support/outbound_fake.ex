defmodule Alice.ChatBackends.OutboundSpy do
  @behaviour Alice.ChatBackends.OutboundClient

  def send_message(response, channel, slack) do
    send(self(), {:send_message, %{response: response, channel: channel, slack: slack}})
  end

  def indicate_typing(channel, slack) do
    send(self(), {:indicate_typing, %{channel: channel, slack: slack}})
  end
end
