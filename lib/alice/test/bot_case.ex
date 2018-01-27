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
      {:ok, start_test_bot(tags)}
    else
      :ok
    end
  end

  def start_test_bot(options) do
    bot = Map.get(options, :bot, @bot)
    name = Map.get(options, :name, "alice")
    handlers = Map.get(options, :handlers, [TestHandler])
    adapters = Map.get(options, :adapters, [{options.test, TestAdapter}])
    config = [name: name, handlers: handlers, adapters: adapters]
    Application.put_env(:alice, bot, config)
    {:ok, bot_pid} = Alice.start_bot(bot, config)
    adapter_pid = update_bot_adapter(options.test, bot_pid)

    on_exit fn ->
      Alice.stop_bot(bot_pid)
    end

    user = %Alice.User{id: "user_id", name: "user_name"}
    msg = %Alice.Message{bot: bot_pid, adapter: {options.test, adapter_pid}, text: "", user: user}

    %{bot: bot_pid, adapter: adapter_pid, msg: msg}
  end

  @doc """
  Alters the running Adapter process' state setting the test process as the
  Connection
  """
  def update_bot_adapter(adapter_name, bot_pid) do
    test_process = self()
    adapter_pid = Process.whereis(adapter_name)
    :sys.replace_state(adapter_pid, fn
      ({^bot_pid, state}) -> {bot_pid, Map.put(state, :conn, test_process)}
      ({pid, state}) ->
        IO.puts "OOPS"
        {pid, state}
    end)

    adapter_pid
  end
end
