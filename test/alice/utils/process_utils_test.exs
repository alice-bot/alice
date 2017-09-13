defmodule ProcessUtilsTest do
  use ExUnit.Case

  test "register_eventually registers eventually" do
    p1 = make_proc()
    p2 = make_proc()
    p3 = make_proc()
    true = ProcessUtils.register_eventually(p1, My.Proc)
    true = ProcessUtils.register_eventually(p2, My.Proc)
    true = ProcessUtils.register_eventually(p3, My.Proc)
    assert p1 == Process.whereis(My.Proc)
    assert p2 == Process.whereis(My.Proc.Alt1)
    assert p3 == Process.whereis(My.Proc.Alt2)
  end

  test "register_eventually returns true if the process is already registered with the name" do
    p1 = make_proc()
    true = Process.register(p1, My.Proc)
    assert ProcessUtils.register_eventually(p1, My.Proc)
  end

  def make_proc do
    pid = spawn fn ->
      receive do
        :exit -> :ok
      end
    end
    on_exit fn -> send(pid, :exit) end
    pid
  end
end
