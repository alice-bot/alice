defmodule Alice.ConsoleTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "the console starts, stops, knows when it's running, says goodbye" do
    bye = capture_io fn ->
      spawn fn -> Alice.Console.start end
      :timer.sleep(1) # this is dumb, is there a better way??
      assert Alice.Console.running?
      Alice.Console.stop
      :timer.sleep(10) # this is dumb, is there a better way??
      refute Alice.Console.running?
    end
    assert String.contains?(bye, "Goodbye!")
  end
end
