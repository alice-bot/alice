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

  def connect(bot, opts) do
    {:ok, conn} = Connection.start(opts)
    {:ok, %{conn: conn, opts: opts, bot: bot}}
  end

  def handle_outgoing(%Alice.Message{text: text}, %{conn: conn} = state) do
    send(conn, {:reply, text})
    {:ok, state}
  end

  def handle_incoming(ext_msg, %{bot: bot} = state) do
    msg = make_msg(bot, ext_msg)
    {:ok, msg, state}
  end

  defp make_msg(bot, %{"text" => text, "user" => user}) do
    %Alice.Message{
      ref: make_ref(),
      bot: bot,
      text: text,
      room: "console",
      adapter: {__MODULE__, self()},
      type: "chat",
      user: %Alice.User{id: "console", name: user}
    }
  end
end
