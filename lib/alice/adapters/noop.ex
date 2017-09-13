defmodule Alice.Adapters.NoOp do
  @moduledoc """
  Alice No Op Adapter

  The NoOp adapter doesn't do anything other than logging. It may be useful
  for testing and debugging. It is also a decent example of the simplest
  possible Alice adapter.

      config :my_app, MyApp.Bot,
        adapter: Alice.Adapters.NoOp,
        ...

  Start your application with `mix run --no-halt` and you will have a bot with
  no interface.
  """
  use Alice.Adapter

  def connect(bot, _opts) do
    {:ok, bot}
  end

  def handle_connect(bot) do
    IO.puts "NoOp connected"
    {:ok, bot}
  end

  def handle_outgoing(msg, bot) do
    IO.puts "got outgoing message #{inspect msg} from bot #{inspect bot}"
    {:ok, bot}
  end

  def handle_incoming(text, bot) do
    IO.puts "received message #{inspect text} for bot #{inspect bot}"
    msg = make_msg(bot, text)
    {:ok, msg, bot}
  end

  defp make_msg(bot, text) do
    %Alice.Message{
      ref: make_ref(),
      bot: bot,
      text: text,
      room: "noop",
      adapter: {__MODULE__, self()},
      type: "chat",
      user: %Alice.User{id: "user", name: "user"}
    }
  end
end
