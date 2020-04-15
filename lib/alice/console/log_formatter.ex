defmodule Alice.Console.LogFormatter do
  def format(level, message, timestamp, metadata) do
    "logger> #{level}: #{message}\n"
  rescue
    _ ->
      "logger-error> could not format message: #{inspect({level, message, timestamp, metadata})}\n"
  end
end
