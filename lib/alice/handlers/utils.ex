defmodule Alice.Handlers.Utils do
  use Alice.Router

  route ~r/\bping\b/i, :ping

  def handle(conn, :ping) do
    ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"]
    |> random_reply(conn)
  end

  route ~r/\balice debug state\b/, :debug_state
  route ~r/\balice debug slack\b/, :debug_slack
  route ~r/\balice debug conn\b/, :debug_conn

  def handle(conn, :debug_state), do: inspect(conn.state)|> format_code |> reply(conn)
  def handle(conn, :debug_slack), do: inspect(conn.slack)|> format_code |> reply(conn)
  def handle(conn, :debug_conn),  do: inspect(conn)|> format_code |> reply(conn)
end
