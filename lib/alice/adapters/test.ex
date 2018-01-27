defmodule Alice.Adapters.Test do
  @moduledoc false

  use Alice.Adapter

  def connect(bot, opts) do
    {:ok, %{conn: nil, opts: opts, bot: bot}}
  end

  def handle_outgoing(%Alice.Message{} = msg, %{conn: conn} = state) do
    send(conn, {:reply, msg})
    {:ok, state}
  end

  def handle_incoming(msg, %{bot: bot} = state) do
    msg = %Alice.Message{bot: bot, adapter: {__MODULE__, self()}, text: msg.text, user: msg.user}
    {:ok, msg, state}
  end

  def handle_info({:message, msg}, {bot, state}) do
    Alice.Bot.handle_in(bot, msg)
    {:noreply, {bot, state}}
  end
end
