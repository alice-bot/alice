defmodule Alice.Adapters.Console do
  @moduledoc """
  Alice Console Adapter

  The console adapter is useful for trying out handlers without a remote
  chat service.

      config :my_app, MyApp.Bot,
        adapter: Alice.Adapters.Console,
        ...

  Start your application with `mix run --no-halt` and you will have a console
  interface to your bot.
  """

  use Alice.Adapter
  alias Alice.Adapters.Console.Connection

  @doc false
  def init({bot, opts}) do
    {:ok, conn} = Connection.start(opts)
    send(self(), :connected)
    {:ok, %{conn: conn, opts: opts, bot: bot}}
  end

  @doc false
  def handle_cast({:reply, msg}, %{conn: conn} = state) do
    send(conn, {:reply, msg})
    {:noreply, state}
  end

  @doc false
  def handle_info(:connected, %{bot: bot} = state) do
    :ok = Alice.Bot.handle_connect(bot)
    {:noreply, state}
  end
  def handle_info({:message, msg}, %{bot: bot} = state) do
    Alice.Bot.handle_in(bot, make_msg(bot, msg))
    {:noreply, state}
  end

  defp make_msg(bot, %{"text" => text, "user" => user}) do
    %Alice.Message{
      ref: make_ref(),
      bot: bot,
      text: text,
      type: "chat",
      user: user
    }
  end
end

