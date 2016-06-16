defmodule Alice.Adapters.REPL do
  use GenServer

  @doc "Specifies the user prompt for the REPL"
  def prompt, do: "alice> "

  @doc "Specifies the response prompt for the REPL"
  def response_prompt, do: IO.ANSI.blue <> "alice> " <> IO.ANSI.reset

  @doc "Starts the REPL"
  def start_link do
    IO.puts("Starting Alice REPL")
    {:ok, pid} = GenServer.start_link(__MODULE__, :nostate, name: __MODULE__)
    GenServer.cast(pid, :start_repl)
    {:ok, pid}
  end

  @doc "Creates the initial REPL state"
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
  Handles incoming messages from the REPL

  Incoming text of "exit" will exit the REPL, anything else will be sent to
  Alice.Bot to generate a response
  """
  def handle_message(%{text: "exit"}, repl_state) do
    Alice.Console.stop
    GenServer.stop(__MODULE__)
    {:ok, repl_state}
  end
  def handle_message(message, repl_state) do
    Alice.Bot.respond_to_message(message, repl_state)
    {:ok, repl_state}
  end

  @doc """
  Sends `text` to the repl.
  """
  def send_message(text), do: send_message(text, "repl")
  def send_message(text, "repl", _repl_state \\ :nostate) do
    text
    |> format_text
    |> IO.puts
  end

  @doc """
  Outputs typing notification on repl.
  """
  def indicate_typing("repl", _repl_state) do
    IO.puts("\nAlice is typing...")
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

  defp line_prefix(0), do: response_prompt
  defp line_prefix(_), do: "       "

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
    String.replace(text, ~r/@(\w+)/, "<@\\1>")
  end

  defp username do
    {user, 0} = System.cmd("whoami", [])
    String.strip(user)
  end
end
