defmodule Alice.Handlers.Utils do
  use Alice.Router

  route   ~r/\Aping\z/i,        :ping
  command ~r/\bping\z/i,        :ping
  command ~r/\bdebug state\z/i, :debug_state
  command ~r/\bdebug slack\z/i, :debug_slack
  command ~r/\bdebug conn\z/i,  :debug_conn


  @doc "`ping` - responds with signs of life"
  def ping(conn) do
    ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"]
    |> random_reply(conn)
  end

  @doc "`debug state` - the current state data for debugging"
  def debug_state(conn), do: inspect(conn.state)|> format_code |> reply(conn)

  @doc "`debug slack` - the current slack data for debugging"
  def debug_slack(conn), do: inspect(conn.slack)|> format_code |> reply(conn)

  @doc "`debug conn` - the current conn data for debugging"
  def debug_conn(conn),  do: inspect(conn)|> format_code |> reply(conn)

  # Formats code for Slack
  defp format_code(code) do
    """
    ```
    #{code}
    ```
    """
  end
end
