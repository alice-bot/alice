defmodule AliceTest do
  use Alice.BotCase

  @tag start_bot: true
  test "list started bots", %{bot: bot} do
    bots = Alice.list_bots()
    assert [{_id, ^bot, _type, [Alice.Bot]}] = bots
  end

  @tag start_bot: true, name: "fred"
  test "find a bot by name", %{bot: bot} do
    assert :undefined == :global.whereis_name("alice")
    assert bot == :global.whereis_name("fred")
  end

  @tag start_bot: true
  test "stop_bot/1", %{bot: bot} do
    Alice.stop_bot(bot)
    refute Process.alive?(bot)
  end
end
