defmodule Alice.BotTest do
  use Alice.BotCase

  test "new/5" do
    bot = Alice.Bot.new(:name, :adapters, :handlers, :opts)
    assert bot == %Alice.Bot{
      name: :name,
      adapters: :adapters,
      handlers: :handlers,
      opts: :opts
    }
  end

  @tag start_bot: true
  test "reply/2", %{bot: bot, msg: msg} do
    Alice.Bot.reply(bot, msg)
    assert_receive {:reply, ^msg}
  end

  @tag start_bot: true, name: "alice"
  test "name/1 returns the name of the bot", %{bot: bot} do
    assert "alice" == Alice.Bot.name(bot)
  end

  @tag start_bot: true
  test "handlers/1 returns list of handlers", %{bot: bot} do
    assert TestHandler in Alice.Bot.handlers(bot)
  end

  @tag start_bot: true
  test "handler_processes/1 returns list of handlers", %{bot: bot} do
    processes =
      Alice.Handler.Supervisor
      |> Supervisor.which_children()
      |> Enum.map(fn({_,pid,_,_}) ->
        {:dictionary, info} = Process.info(pid, :dictionary)
        {mod, _, _} = Keyword.get(info, :"$initial_call")
        {mod, pid}
      end)
    assert processes == Alice.Bot.handler_processes(bot)
  end

  @tag start_bot: true
  test "handle_in/2", %{bot: bot} do
    Alice.Bot.handle_in(bot, {:ping, self()})
    assert_receive :pong
  end

  @tag start_bot: true
  test "handle_connect/1", %{bot: bot} do
    assert bot == Process.whereis(Alice.TestBot)
  end

  @tag start_bot: true
  test "handle_disconnect/1", %{bot: bot} do
    assert :reconnect == Alice.Bot.handle_disconnect(bot, :reconnect)
    assert {:reconnect, 3000} == Alice.Bot.handle_disconnect(bot, {:reconnect, 3000})
    assert {:disconnect, :normal} == Alice.Bot.handle_disconnect(bot, :error)
  end
end
