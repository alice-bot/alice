defmodule Alice.BotTest do
  use ExUnit.Case, async: true

  alias Alice.Bot

  setup do
    {:ok, bot} = Bot.start_link
    {:ok, bot: bot}
  end

  test "Bot can be started", %{bot: bot} do
    assert is_pid(bot)
  end

end
