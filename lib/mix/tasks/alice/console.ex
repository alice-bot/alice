defmodule Mix.Tasks.Alice.Console do
  use Mix.Task

  @shortdoc "Starts an Alice REPL"
  def run(_) do
    Mix.Task.run("compile")
    Alice.Console.start
  end
end
