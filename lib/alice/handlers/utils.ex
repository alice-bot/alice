defmodule Alice.Handlers.Utils do
  use Alice.Router

  route ~r/\Aping\z/i, :ping

  def handle(conn, :ping) do
    ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"]
    |> random_reply(conn)
  end

  route ~r/\Aalice debug state\z/i, :debug_state
  route ~r/\Aalice debug slack\z/i, :debug_slack
  route ~r/\Aalice debug conn\z/i, :debug_conn

  def handle(conn, :debug_state), do: inspect(conn.state)|> format_code |> reply(conn)
  def handle(conn, :debug_slack), do: inspect(conn.slack)|> format_code |> reply(conn)
  def handle(conn, :debug_conn),  do: inspect(conn)|> format_code |> reply(conn)
end
