defmodule Alice.Adapters.NoOp do
  @moduledoc """
  Alice No Op Adapter

  The console adapter doesn't do anything.

      config :my_app, MyApp.Bot,
        adapter: Alice.Adapters.NoOp,
        ...

  Start your application with `mix run --no-halt` and you will have a bot with
  no interface.
  """
  use Alice.Adapter

  @doc false
  def init({bot, _opts}) do
    send(self(), :connected)
    {:ok, bot}
  end

  @doc false
  def handle_cast({:reply, msg}, bot) do
    IO.puts "got reply message #{inspect msg} from bot #{inspect bot}"
    {:noreply, bot}
  end

  @doc false
  def handle_info(:connected, bot) do
    :ok = Alice.Bot.handle_connect(bot)
    IO.puts "NoOp connected"
    {:noreply, bot}
  end
  def handle_info({:message, msg}, bot) do
    IO.puts "received message #{inspect msg} for bot #{inspect bot}"
    Alice.Bot.handle_in(bot, make_msg(bot, msg))
    {:noreply, bot}
  end

  defp make_msg(bot, msg) do
    %Alice.Message{
      ref: make_ref(),
      bot: bot,
      text: msg,
      room: "noop",
      adapter: {__MODULE__, self()},
      type: "chat",
      user: %Alice.User{id: "user", name: "user"}
    }
  end
end
