defmodule Alice.ChatBackends.REPL do
  use GenServer

  def prompt, do: "alice> "

  def response_prompt, do: IO.ANSI.blue <> "alice> " <> IO.ANSI.reset

  def start_link do
    IO.puts("Starting Alice REPL")
    {:ok, pid} = GenServer.start_link(__MODULE__, :nostate, name: __MODULE__)
    GenServer.cast(pid, :start_repl)
    {:ok, pid}
  end

  def handle_message(%{text: "exit"}, repl_state) do
    Mix.Tasks.Alice.Console.stop
    GenServer.stop(__MODULE__)
    {:ok, repl_state}
  end
  def handle_message(message, repl_state) do
    Alice.Bot.respond_to_message(message, repl_state)
    {:ok, repl_state}
  end

  def init(:nostate) do
    {:ok, %{
      me: %{id: "alice"},
      users: %{
        username => %{id: username, name: username},
        "alice"  => %{id: "alice", name: "alice"}
      }
    } }
  end

  @doc """
  Sends `text` to the repl.
  """
  def send_message(text, "repl", _repl_state) do
    # go to beginning of current line
    text
    |> format_text
    |> IO.puts
  end

  defp format_text(text) do
    text
    |> String.replace(~r/<@(\w+)>/, "@\\1")
    |> String.split("\n")
    |> Stream.with_index
    |> Enum.map(fn({line, index}) -> "#{line_prefix(index)}#{line}\n" end)
    |> to_string
    |> String.rstrip
  end

  def line_prefix(0), do: response_prompt
  def line_prefix(_), do: "       "

  @doc """
  Outputs typing notification on repl.
  """
  def indicate_typing("repl", _repl_state) do
    # copy text on current line
    # go to beginning of current line
    IO.puts("Alice is typing...")
    # output copied text
  end

  # Server Callbacks

  def handle_cast(:start_repl, repl_state) do
    loop(repl_state)
  end

  defp loop(repl_state) do
    read
    |> eval
    |> print(repl_state)
    |> loop
  end

  def read do
    prompt
    |> IO.gets
    |> String.strip
  end

  def eval(text) do
    %{text: process_text(text), type: "message", channel: "repl", user: username}
  end

  def print(message, repl_state) do
    {:ok, state} = handle_message(message, repl_state)
    state
  end

  defp process_text(text) do
    text
    |> String.replace(~r/@(\w+)/, "<@\\1>")
  end

  defp username do
    System.user_home |> String.split("/") |> Enum.reverse |> hd
  end
end
