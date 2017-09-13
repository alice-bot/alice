defmodule Alice.BotCase do
  use ExUnit.CaseTemplate
  alias Alice.Adapters.Test, as: TestAdapter

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
      adapters = Map.get(tags, :adapters, [{TestAdapter, TestAdapter}])
      config = [name: name, handlers: handlers, adapters: adapters]
      Application.put_env(:alice, bot, config)
      {:ok, bot_pid} = Alice.start_bot(bot, config)
      Process.register(bot_pid, Alice.TestBot)
      test_adapter = update_bot_adapter(bot_pid)

      on_exit fn -> Alice.stop_bot(bot_pid) end

      user = %Alice.User{id: "user_id", name: "user_name"}
      msg = %Alice.Message{bot: bot_pid, adapter: {TestAdapter, Process.whereis(TestAdapter)}, text: "", user: user}

      {:ok, %{bot: bot_pid, adapter: test_adapter, msg: msg}}
    else
      :ok
    end
  end

  def update_bot_adapter(bot_pid) do
    test_process = self()
    [adapter_mod] = :sys.get_state(bot_pid).adapters
    :sys.replace_state(adapter_mod, fn state -> %{state | conn: test_process} end)

    adapter_mod
  end
end
