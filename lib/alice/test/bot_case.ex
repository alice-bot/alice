defmodule Alice.BotCase do
  use ExUnit.CaseTemplate

  @bot Alice.TestBot

  using do
    quote do
      import unquote(__MODULE__)
      @bot Alice.TestBot
    end
  end

  setup tags do
    if tags[:start_bot] do
      bot = Map.get(tags, :bot, @bot)
      name = Map.get(tags, :name, "alice")
      handlers = Map.get(tags, :handlers, [TestHandler])
      config = [name: name, handlers: handlers]
      Application.put_env(:alice, bot, config)
      {:ok, pid} = Alice.start_bot(bot, config)
      adapter = update_bot_adapter(pid)

      on_exit fn -> Alice.stop_bot(pid) end

      user = %Alice.User{id: "user_id", name: "user_name"}
      msg = %Alice.Message{bot: pid, text: "", user: user}

      {:ok, %{bot: pid, adapter: adapter, msg: msg}}
    else
      :ok
    end
  end

  def update_bot_adapter(bot_pid) do
    test_process = self()
    adapter = :sys.get_state(bot_pid).adapter
    :sys.replace_state(adapter, fn state -> %{state | conn: test_process} end)

    adapter
  end
end
