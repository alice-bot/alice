defmodule Alice.Adapters.REPLTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Alice.Adapters.REPL

  test "it outputs some messages" do
    assert capture_io(fn -> REPL.start_link end) == "Starting Alice REPL\n"
  end

  test "it responds to input on the repl" do
    Alice.State.start_link
    Alice.Router.start_link([Alice.Handlers.TestHandler])
    Alice.Adapters.start_link(REPL, start_adapter: false)
    {:ok, state} = REPL.init(:nostate)
    assert capture_io([input: "ping"], fn ->
      REPL.read
      |> REPL.eval
      |> REPL.print(state)
    end) == REPL.prompt <> REPL.response_prompt <> "pong\n"
  end
end
