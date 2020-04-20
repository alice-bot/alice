defmodule Alice.Console do
  @moduledoc """
  Starts up the Console to allow testing of Alice's responses
  """

  alias Alice.{Conn, Earmuffs, Router}

  @doc "Boots up the console and all associated constructs"
  def start() do
    setup_alice()
    IO.puts("Starting Alice Console")
    repl(%{halt: false})
  end

  defp repl(%{halt: true}), do: IO.puts("Goodbye!")

  defp repl(state) do
    message =
      IO.gets("alice> ")
      |> String.trim("\n")
      |> String.replace("@alice", "<@alice>")

    conn = make_conn(message, state)
    {:ok, state} = handle_message(conn)
    :timer.sleep(1)
    repl(state)
  end

  defp handle_message(conn = %Conn{message: %{text: "exit"}}) do
    {:ok, %{conn.state | halt: true}}
  end

  defp handle_message(conn = %Conn{}) do
    conn =
      cond do
        Earmuffs.blocked?(conn) -> Earmuffs.unblock(conn)
        Conn.command?(conn) -> Router.match_commands(conn)
        true -> Router.match_routes(conn)
      end

    {:ok, conn.state}
  end

  defp setup_alice() do
    Application.ensure_all_started(:alice)
    Application.put_env(:alice, :chat_backend, :console)
    Application.put_env(:alice, :outbound_client, Alice.ChatBackends.ConsoleOutbound)
    Alice.start(:normal, %{})
    Logger.configure(level: Application.get_env(:alice, :console_logger_level, :error))
    Logger.configure_backend(:console, format: {Alice.Console.LogFormatter, :format})
  end

  defp make_conn(message, state) do
    user = System.get_env("USER") || "console_user"

    Conn.make(
      %{text: message, channel: :console, user: user, ts: get_timestamp()},
      console_data(user),
      state
    )
  end

  defp console_data(user) do
    %{
      me: %{id: "alice"},
      users: [
        %{"id" => "alice", "name" => "alice"},
        %{"id" => user, "name" => user, "tz_offset" => get_tz_offset()}
      ]
    }
  end

  defp get_timestamp() do
    case System.cmd("date", ["+%s"]) do
      {unix_timestamp, 0} ->
        String.trim(unix_timestamp)

      _ ->
        DateTime.utc_now()
        |> DateTime.to_unix()
        |> to_string()
    end
  end

  defp get_tz_offset() do
    case System.cmd("date", ["+%z"]) do
      {offset, 0} ->
        {parsed, _} = Integer.parse(offset)
        div(parsed, 100) * 60 * 60

      _ ->
        0
    end
  end
end
