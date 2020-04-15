defmodule Alice.ConsoleTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup_all do
    Alice.Router.start_link([Alice.Handlers.Utils, Alice.Handlers.Help])

    on_exit fn ->
      Application.put_env(:alice, :outbound_client, Alice.ChatBackends.OutboundSpy)
    end
  end

  test "it should be able to exit gracefully" do
    capture = capture_io("exit", fn -> Alice.Console.start() end)

    assert capture == "Starting Alice Console\nalice> Goodbye!\n"
  end

  test "it should be able to route to a handler" do
    capture = capture_io("ping\nexit", fn -> Alice.Console.start() end)
    possible_responses = [
      "Starting Alice Console\nalice> PONG!\nalice> Goodbye!\n",
      "Starting Alice Console\nalice> Can I help you?\nalice> Goodbye!\n",
      "Starting Alice Console\nalice> Yes...I'm still here.\nalice> Goodbye!\n",
      "Starting Alice Console\nalice> I'm alive!\nalice> Goodbye!\n"
    ]

    assert capture in possible_responses
  end

  test "it should be able to send a command to a handler" do
    capture = capture_io("@alice help\nexit", fn -> Alice.Console.start() end)

    assert capture == "Starting Alice Console\nalice> _Here are all the handlers I know about…_\n\n> *Help*\n> *Utils*\n\n_Get info about a specific handler with_ `@alice help <handler name>`\n\n_Get info about all handlers with_ `@alice help all`\n\n_Feedback on Alice is appreciated. Please submit an issue at https://github.com/alice-bot/alice/issues _\n\nalice> Goodbye!\n"
  end
end
