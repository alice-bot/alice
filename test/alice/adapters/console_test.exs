defmodule Alice.Adapters.ConsoleTest do
  use ExUnit.Case

  # import ExUnit.CaptureIO
  alias Alice.Adapters.Console

  # test "console handles messages from the connection" do
  #   {:ok, adapter} = start_adapter(self(), name: "alice", user: "testuser")
  #
  #   msg = {:message, %{"text" => "ping", "user" => "testuser"}}
  #
  #   send(adapter, msg)
  #   assert_receive {:"$gen_cast", {:handle_in, %Alice.Message{text: "ping", user: %Alice.User{name: "testuser"}}}}
  # end

  # test "sending messages to the connection process" do
  #   capture_io fn ->
  #     {:ok, adapter_pid} = start_adapter(self(), name: "alice", user: "testuser")
  #
  #     test_process = self()
  #     adapter = :sys.replace_state(adapter_pid, fn state -> %{state | conn: test_process} end)
  #     msg = %Alice.Message{text: "pong", user: "testuser"}
  #
  #     Console.reply(adapter.conn, msg)
  #     assert_receive {:"$gen_cast", {:reply, ^msg}}
  #   end
  # end

  defp start_adapter(pid, opts) do
    {:ok, adapter_pid} = Supervisor.start_child(Alice.Adapter.Supervisor, [Console, pid, opts])
    IO.puts "started adapter #{inspect adapter_pid}"
    on_exit fn ->
      IO.puts "stopping adapter #{inspect adapter_pid}"
      Supervisor.terminate_child(Alice.Adapter.Supervisor, adapter_pid)
    end
    handle_connect()
    IO.puts "handled connect #{inspect adapter_pid}"
    {:ok, adapter_pid}
  end

  defp handle_connect() do
    receive do
      {:"$gen_call", from, :handle_connect} -> GenServer.reply(from, :ok)
    end
  end
end
