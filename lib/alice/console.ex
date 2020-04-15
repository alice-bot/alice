defmodule Alice.Console do
  @moduledoc """
  Starts up the Console to allow testing of Alice's responses
  """
  def start() do
    setup_alice()
    IO.puts("Starting Alice Console")
    repl()
  end

  defp repl(last_message \\ "")
  defp repl("exit"), do: IO.puts("Goodbye!")

  defp repl(_last_message) do
    message =
      IO.gets("alice> ")
      |> String.trim("\n")
      |> String.replace("@alice", "<@alice>")

    Alice.HandlerCase.send_message(message)
    :timer.sleep(1)
    repl(message)
  end

  defp setup_alice() do
    Application.ensure_all_started(:alice)
    Application.put_env(:alice, :chat_backend, :console)
    Application.put_env(:alice, :outbound_client, Alice.ChatBackends.ConsoleOutbound)
    Alice.start(:normal, %{})
    Logger.configure(level: :error)
  end
end
