defmodule Alice.Cli do
  def main(_args) do
    receive do
      :stop -> :ok
    end
  end
end
