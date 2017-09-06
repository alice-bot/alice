defmodule Alice.HandlerTest do
  use Alice.BotCase
  alias Alice.Handler

  test "builtins/0" do
    assert Handler.builtins() == [
      Alice.Handlers.Help,
      Alice.Handlers.Utils
    ]
  end

  test "respond_pattern" do
    assert Handler.command_pattern(~r/hey there/i, "alice") ==
      ~r/^\s*[@]?alice[:,]?\s*(?:hey there)/i

    assert Handler.command_pattern(~r/this\s*should\s*escape/i, "alice") ==
      ~r/^\s*[@]?alice[:,]?\s*(?:this\s*should\s*escape)/i
  end

  @tag start_bot: true
  test "it responds to routes", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "test route"}}
    assert_receive {:reply, %{text: "route test received"}}
  end

  @tag start_bot: true
  test "it responds to commands", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "alice test command"}}
    assert_receive {:reply, %{text: "command test received"}}
  end

  @tag start_bot: true
  test "it saves captures from the regex", %{adapter: adapter, msg: msg} do
    send adapter, {:message, %{msg | text: "capture some stuff"}}
    text = "captured: #{inspect %{"this" => "some stuff"}}"
    assert_receive {:reply, %{text: ^text}}
  end
end
