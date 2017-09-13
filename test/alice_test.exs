defmodule AliceTest do
  use Alice.BotCase

  @tag start_bot: true
  test "list started bots", %{bot: bot} do
    bots = Alice.list_bots()
    assert [{_id, ^bot, _type, [Alice.Bot]}] = bots
  end

  @tag start_bot: true
  test "find a bot by name", %{bot: bot} do
    assert bot == Process.whereis(Alice.TestBot)
  end

  @tag start_bot: true
  test "stop_bot/1", %{bot: bot} do
    Alice.stop_bot(bot)
    refute Process.alive?(bot)
  end
end
