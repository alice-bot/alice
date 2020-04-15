defmodule Alice.Console.LogFormatter do
  @moduledoc """
  Formatter for rendering logs in the Console
  """
  def format(level, message, timestamp, metadata) do
    "logger> #{level}: #{message}\n"
  rescue
    _ ->
      "logger-error> could not format message: #{inspect({level, message, timestamp, metadata})}\n"
  end
end
