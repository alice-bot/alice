defmodule Alice.HandlersCase do
  @moduledoc """
  Helpers for writing tests of Alice Handlers.

  When used it accepts the following options:
  * `:handlers` - The handler (or List of handlers) that you want to test. Defaults to [] (thereby giving you no handlers to test)

  `use`ing this handler automatically brings in `ExUnit.Case` as well.

  ## Examples

      defmodule Alice.Handlers.ExampleHandlerTest do
        use Alice.HandlersCase, handlers: Alice.Handlers.ExampleHandler

        test "it replies" do
          send_message("hello")
          assert first_reply() == "world"
        end
      end
  """

  @doc """
  Generates a fake connection for testing purposes.

  Can be called as `fake_conn/0` to generate a quick connection. Or it can be
  called as `fake_conn/1` to pass a message. Or finally can be called as
  `fake_conn/2` to set options with the message.

  ## Examples

      fake_conn()
      fake_conn("message")
      fake_conn("message", state: %{some: "state"})
      fake_conn("message", capture: ~r/pattern/)

      test "you can directly use the reply function" do
        conn = fake_conn()
        reply(conn, "hello world")
        assert first_reply() == "hello world"
      end

      test "you can set state" do
        conn = fake_conn("message", state: %{some: "state"})
        conn = send_message(conn)
        assert first_reply() == "hello world"
        assert conn.state.some == "state"
      end
  """
  def fake_conn(), do: fake_conn("")

  def fake_conn(text) do
    %Alice.Conn{
      message: %{text: text, channel: :channel, user: :fake_user},
      slack: %{users: %{fake_user: %{id: :fake_user, name: "fake_user"}}, me: %{id: :alice}}
    }
  end

  def fake_conn(text, state: state) do
    %{fake_conn(text) | state: state}
  end

  def fake_conn(text, capture: capture_regex) do
    text
    |> fake_conn()
    |> Alice.Conn.add_captures(capture_regex)
  end

  @doc """
    Sends a message through Alice that can be captured by the handlers.

    Can either be called with a `String` or with an `Alice.Conn`

    ## Examples

        test "it sends a message" do
          send_message("test message")
          assert first_reply() == "reply from handler"
        end
  """
  def send_message(conn = %Alice.Conn{}) do
    case Alice.Conn.command?(conn) do
      true -> Alice.Router.match_commands(conn)
      false -> Alice.Router.match_routes(conn)
    end
  end

  def send_message(message) do
    message
    |> fake_conn()
    |> send_message()
  end

  @doc """
  Retrieves a `List` of all the replies that Alice has sent out since the test began.

  ## Examples

      test "you can send multiple messages" do
        send_message("first")
        send_message("second")
        assert all_replies() == ["first", "second"]
      end
  """
  def all_replies() do
    message =
      receive do
        {:send_message, %{response: message}} -> message
      after
        0 -> :no_message_received
      end

    case message do
      :no_message_received -> []
      message -> [message | all_replies()]
    end
  end

  @doc """
  Retrieves the first reply that Alice sent out since the test began.

  ## Examples

      test "it only brings back the first message" do
        send_message("first")
        send_message("second")
        assert first_reply() == "first"
      end
  """
  def first_reply() do
    case all_replies() do
      [first_message | _] -> first_message
      _ -> nil
    end
  end

  @doc """
  Verifies that typing was indicated during the test.

  ## Examples

      test "the handler indicated typing" do
        send_message("message that causes the handler to indicate typing")
        assert typing?
      end
  """
  def typing?() do
    receive do
      {:indicate_typing, _} -> true
    after
      0 -> false
    end
  end

  defmacro __using__(opts \\ []) do
    handlers =
      opts
      |> Keyword.get(:handlers, [])
      |> List.wrap()

    quote do
      use ExUnit.Case
      import Alice.HandlersCase

      setup do
        Alice.Router.start_link(unquote(handlers))

        :ok
      end
    end
  end
end
