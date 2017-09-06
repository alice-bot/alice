defmodule Alice.Adapters.Test do
  @moduledoc false

  use Alice.Adapter

  def init({bot, opts}) do
    GenServer.cast(self(), :after_init)
    {:ok, %{conn: nil, opts: opts, bot: bot}}
  end

  def handle_cast(:after_init, %{bot: bot} = state) do
    Alice.Bot.handle_connect(bot)
    {:noreply, state}
  end

  def handle_cast({:reply, msg}, %{conn: conn} = state) do
    send(conn, {:reply, msg})
    {:noreply, state}
  end

  def handle_info({:message, msg}, %{bot: bot} = state) do
    msg = %Alice.Message{bot: bot, text: msg.text, user: msg.user}
    Alice.Bot.handle_in(bot, msg)
    {:noreply, state}
  end
  def handle_info(msg, %{bot: bot} = state) do
    Alice.Bot.handle_in(bot, msg)
    {:noreply, state}
  end
end
