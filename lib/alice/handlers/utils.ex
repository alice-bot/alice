defmodule Alice.Handlers.Utils do
  use Alice.Router

  route ~r/\Aping\z/i, :ping
  command ~r/\bping\z/i, :ping

  def handle(conn, :ping) do
    ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"]
    |> random_reply(conn)
  end

  command ~r/\bdebug state\z/i, :debug_state
  command ~r/\bdebug slack\z/i, :debug_slack
  command ~r/\bdebug conn\z/i, :debug_conn

  def handle(conn, :debug_state), do: inspect(conn.state)|> format_code |> reply(conn)
  def handle(conn, :debug_slack), do: inspect(conn.slack)|> format_code |> reply(conn)
  def handle(conn, :debug_conn),  do: inspect(conn)|> format_code |> reply(conn)

  @doc """
  Formats code for Slack
  """
  defp format_code(code) do
    """
    ```
    #{code}
    ```
    """
  end
end
