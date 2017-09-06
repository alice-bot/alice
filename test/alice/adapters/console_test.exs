defmodule Alice.Adapters.ConsoleTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  alias Alice.Adapters.Console

  test "console handles messages from the connection" do
    capture_io fn ->
      {:ok, adapter} = Alice.Adapter.start_link(Console, name: "alice", user: "testuser")

      handle_connect()
      msg = {:message, %{"text" => "ping", "user" => "testuser"}}

      send(adapter, msg)
      assert_receive {:"$gen_cast", {:handle_in, %Alice.Message{text: "ping", user: "testuser"}}}
    end
  end

  test "sending messages to the connection process" do
    capture_io fn ->
      {:ok, adapter_pid} = Alice.Adapter.start_link(Console, name: "alice", user: "testuser")
      on_exit fn -> Console.stop(adapter_pid, 1) end

      handle_connect()
      test_process = self()
      adapter = :sys.replace_state(adapter_pid, fn state -> %{state | conn: test_process} end)
      msg = %Alice.Message{text: "pong", user: "testuser"}

      Console.reply(adapter.conn, msg)
      assert_receive {:"$gen_cast", {:reply, ^msg}}
    end
  end

  defp handle_connect() do
    receive do
      {:"$gen_call", from, :handle_connect} -> GenServer.reply(from, :ok)
    end
  end
end
