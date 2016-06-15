defmodule Alice.Console do
  alias Alice.Adapters.REPL

  def start do
    Application.put_env(:alice, :adapter, REPL)
    Application.ensure_all_started(:alice)
    Process.register(self, Alice.Console)
    receive do
      :stop -> REPL.send_message("Goodbye!")
    end
  end

  def running? do
    Alice.Console
    |> Process.whereis
    |> case do
      nil -> false
      pid -> Process.alive?(pid)
    end
  end

  def stop do
    if Alice.Console.running? do
      send(Alice.Console, :stop)
    end
  end
end
