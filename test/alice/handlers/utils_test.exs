defmodule Alice.Handlers.UtilsTest do
  use Alice.HandlersCase, handlers: Alice.Handlers.Utils

  test "it responds to a ping route" do
    send_message("ping")

    assert first_reply() in ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"]
  end

  test "it responds to a ping command" do
    send_message("<@alice> ping")

    assert first_reply() in ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"]
  end

  test "it responds with info about the running bot" do
    send_message("<@alice> info")
    [version, memory] = all_replies()

    {:ok, alice_version} = :application.get_key(:alice, :vsn)

    assert version == "Alice #{alice_version} - https://github.com/alice-bot"
    assert memory =~ ~r"Total memory: (.+)MB - Allocated to processes: (.+)MB"
  end

  test "it responds to debug state" do
    conn =
      "<@alice> debug state"
      |> fake_conn(state: %{some: "state"})
      |> send_message()

    assert first_reply() == """
           ```
           #{inspect(conn.state)}
           ```
           """
  end

  test "it responds to debug slack" do
    conn =
      "<@alice> debug slack"
      |> fake_conn()
      |> send_message()

    assert first_reply() == """
           ```
           #{inspect(conn.slack)}
           ```
           """
  end

  test "it responds to debug conn" do
    conn =
      "<@alice> debug conn"
      |> fake_conn()
      |> send_message()

    assert first_reply() == """
           ```
           #{inspect(conn)}
           ```
           """
  end
end
