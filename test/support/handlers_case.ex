defmodule Alice.HandlersCase do
  def all_replies() do
    message = receive do
      {:send_message, %{response: message}} -> message
    after
      0 -> :no_message_received
    end
    case message do
      :no_message_received -> []
      message -> [message | all_replies()]
    end
  end

  def first_reply() do
    case all_replies() do
      [first_message |  _] -> first_message
      _                    -> nil
    end
  end

  def fake_conn(), do: fake_conn("")
  def fake_conn(text) do
    %Alice.Conn{message: %{text: text, channel: :channel, user: :fake_user}, slack: %{users: [fake_user: %{name: "fake_user"}], me: %{id: :alice}}}
  end

  def fake_conn_with_capture(message, capture_regex) do
    message
    |> fake_conn()
    |> Alice.Conn.add_captures(capture_regex)
  end

  def receive_message(message) do
    conn = fake_conn(message)
    case Alice.Conn.command?(conn) do
      true  -> Alice.Router.match_commands(conn)
      false -> Alice.Router.match_routes(conn)
    end
  end

  def typing?() do
    receive do
      {:indicate_typing, _} -> true
    after
      0 -> false
    end
  end

  defmacro __using__(opts \\ []) do
    handlers = opts
               |> Keyword.get(:handlers, [])
               |> List.wrap()

    quote do
      import Alice.HandlersCase

      setup do
        Alice.Router.start_link(unquote(handlers))

        :ok
      end
    end
  end
end
