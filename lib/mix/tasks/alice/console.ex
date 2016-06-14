defmodule Mix.Tasks.Alice.Console do
  use Mix.Task

  @shortdoc "Starts an Alice REPL"
  def run(_) do
    Alice.start(:normal, %{adapter: Alice.Adapters.REPL})
    Process.register(self, __MODULE__)
    receive do
      :stop -> IO.puts(REPL.response_prompt <> "Goodbye!")
    end
  end

  def stop, do: send(__MODULE__, :stop)
end
