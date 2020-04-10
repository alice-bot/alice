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
    %Alice.Conn{message: %{text: text, channel: :channel}, slack: :slack}
  end

  def fake_conn_with_capture(message, capture_regex) do
    fake_conn_with_text(message)
    |> Alice.Conn.add_captures(capture_regex)
  end
end
