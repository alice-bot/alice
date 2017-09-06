defmodule Alice.Adapters.Console.Writer do
  @moduledoc false
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, {self(), name})
  end

  def puts(pid, msg) do
    GenServer.cast(pid, {:puts, msg})
  end

  def clear(pid) do
    GenServer.cast(pid, :clear)
  end

  def init({owner, name}) do
    GenServer.cast(self(), :after_init)
    {:ok, {owner, name}}
  end

  def handle_cast(:after_init, {owner, name}) do
    display_banner(name)
    {:noreply, {owner, name}}
  end
  def handle_cast(:clear, state) do
    clear_screen()
    {:noreply, state}
  end
  def handle_cast({:puts, msg}, {owner, name}) do
    handle_result(msg, name)
    {:noreply, {owner, name}}
  end

  defp handle_result(msg, name) do
    print(prompt(name) ++ [:normal, :default_color, msg.text])
  end

  defp print(message) do
    message
    |> IO.ANSI.format()
    |> IO.puts()
  end

  defp prompt(name) do
    [:green, name, "> ", :default_color]
  end

  defp clear_screen() do
    print([:clear, :home])
  end

  defp display_banner(name) do
    print """
    Alice Console

    With this console adapter you can try out handlers and test your bot without configuring and connecting to a remote chat service.

    Special console commands:
    clear - clears the screen
    exit - exit Alice and return to your shell

    Your bot is named: #{name}
    """
  end
end
