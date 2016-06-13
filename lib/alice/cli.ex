defmodule Alice.CLI do
  alias Alice.ChatBackends.REPL

  def main(args) do
    {options, command, _} = OptionParser.parse(args)
    execute(command, options)
    Process.register(self, __MODULE__)
    receive do
      :stop -> IO.puts(REPL.response_prompt <> "Goodbye!")
    end
  end

  def execute([], options),        do: execute("console", options)
  def execute([command], options), do: execute(command, options)
  def execute("c", options),       do: execute("console", options)
  def execute("console", _opts),   do: Alice.start(:normal, %{adapter: REPL})
  def execute(command, _opts) do
    IO.puts("Sorry, I don't know how to execute the command \"#{command}\"")
  end

  def stop, do: send(__MODULE__, :stop)
end
