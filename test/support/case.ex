defmodule Alice.Handlers.Case do
  def replies_received() do
    message = receive do
      {:send_message, %{response: message}} -> message
    after
      0 -> nil
    end
    case message do
      nil -> []
      message -> [message | replies_received()]
    end
  end

  def first_reply() do
    case replies_received() do
      [first_message |  _] -> first_message
      _                    -> nil
    end
  end

  def fake_conn do
    %Alice.Conn{message: %{channel: :channel}, slack: :slack}
  end

  def fake_conn_with_text(text) do
    %Alice.Conn{message: %{text: text, channel: :channel, user: 0}, slack: %{users: ["fake_user"], me: %{id: "alice"}}}
  end

  def fake_conn_with_capture(message, capture_regex) do
    fake_conn_with_text(message)
    |> Alice.Conn.add_captures(capture_regex)
  end

  def send_test_message(message) do
    conn = fake_conn_with_text(message)
    case Alice.Conn.command?(conn) do
      true  -> Alice.Router.match_commands(conn)
      false -> Alice.Router.match_routes(conn)
    end
  end

  defmacro __using__(opts \\ []) do
    handlers = opts
               |> Keyword.get(:handlers, [])
               |> List.wrap()

    quote do
      import Alice.Handlers.Case

      setup do
        Alice.Router.start_link(unquote(handlers))

        :ok
      end
    end
  end
end
