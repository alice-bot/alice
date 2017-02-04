defmodule Alice.Handlers.Utils do
  @moduledoc "Some utility routes for Alice"
  use Alice.Router

  route   ~r/\Aping\z/i,        :ping
  command ~r/\bping\z/i,        :ping
  command ~r/\binfo\z/i,        :info
  command ~r/\bdebug state\z/i, :debug_state
  command ~r/\bdebug slack\z/i, :debug_slack
  command ~r/\bdebug conn\z/i,  :debug_conn

  @doc "`ping` - responds with signs of life"
  def ping(conn) do
    ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"]
    |> random_reply(conn)
  end

  @doc "`info` - info about Alice and the system"
  def info(conn) do
    mem     = :erlang.memory
    total   = "Total memory: #{bytes_to_megabytes(mem[:total])}MB"
    process = "Allocated to processes: #{bytes_to_megabytes(mem[:processes])}MB"

    conn
    |> reply("Alice #{alice_version()} - https://github.com/alice-bot")
    |> reply("#{total} - #{process}")
  end

  def bytes_to_megabytes(bytes) do
    Float.round(bytes / :math.pow(1024,2), 2)
  end

  defp alice_version, do: alice_version(Application.loaded_applications)
  defp alice_version([{:alice, _desc, version} | _apps]), do: version
  defp alice_version([]), do: "Unknown Version"
  defp alice_version([_app|apps]), do: alice_version(apps)

  @doc "`debug state` - the current state data for debugging"
  def debug_state(conn), do: conn.state |> inspect |> format_code |> reply(conn)

  @doc "`debug slack` - the current slack data for debugging"
  def debug_slack(conn), do: conn.slack |> inspect |> format_code |> reply(conn)

  @doc "`debug conn` - the current conn data for debugging"
  def debug_conn(conn),  do: conn |> inspect |> format_code |> reply(conn)

  # Formats code for Slack
  defp format_code(code) do
    """
    ```
    #{code}
    ```
    """
  end
end
