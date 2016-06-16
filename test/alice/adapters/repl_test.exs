defmodule Alice.Adapters.REPLTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Alice.Adapters.REPL

  setup do
    adapter = Application.get_env(:alice, :adapter)
    on_exit fn ->
      case adapter do
        nil -> Application.delete_env(:alice, :adapter)
        _   -> Application.put_env(:alice, :adapter, adapter)
      end
    end
  end

  test "it outputs some messages" do
    assert capture_io(fn -> REPL.start_link end) == "Starting Alice Console\n"
  end

  test "it responds to input on the repl" do
    Alice.State.start_link
    Alice.Router.start_link
    Application.put_env(:alice, :adapter, REPL)
    Alice.Adapters.start_link(start_adapter: false)
    {:ok, state} = REPL.init(:nostate)
    prompt = REPL.prompt <> REPL.response_prompt

    assert capture_io([input: "ping"], fn ->
      REPL.read
      |> REPL.eval
      |> REPL.print(state)
    end) == prompt <> "pong\n"
  end
end
