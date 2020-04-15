defmodule Alice.Console.LogFormatterTest do
  use ExUnit.Case
  import Alice.Console.LogFormatter

  test "It should format a log message to better display in the console" do
    result = format("info", "test log", nil, nil)

    assert result == "logger> info: test log\n"
  end

  test "It should fail gracefully if given something it cannot turn into a string" do
    result = format("warn", %{message: ArgumentError}, "timestamp", %{})

    assert result ==
             "logger-error> could not format message: {\"warn\", %{message: ArgumentError}, \"timestamp\", %{}}\n"
  end
end
