defmodule Alice.Handlers.HelpTest do
  use ExUnit.Case, async: true
  alias Alice.Handlers.Help
  alias Alice.Handlers.TestHandler

  test "help_for_handler generates the correct output" do
    conn = Alice.Conn.make(%{}, %{me: %{name: "alice"}})
    assert Help.help_for_handler(TestHandler, conn) == test_help_message_output(conn)
  end

  test "help_for_handler generates the correct output with a different bot name" do
    conn = Alice.Conn.make(%{}, %{me: %{name: "mad_hatter"}})
    assert Help.help_for_handler(TestHandler, conn) == test_help_message_output(conn)
  end

  defp test_help_message_output(%Alice.Conn{slack: %{me: %{name: bot_name}}}) do
    """
    >*Alice.Handlers.TestHandler*
    >
    > *Routes:*
    >    _command1_
    >        `cmd1`: does some stuff
    >
    > *Commands:*
    >    _command1_
    >        `@#{bot_name} cmd1`: does some stuff
    >    _command2_
    >        `@#{bot_name} cmd2`: does some other stuff
    >        also this one is multiline
    >    _command3_
    >        this one doesn't start with an
    >        example so no @alice is added
    >    _no_docs_
    >        _no documentation provided_
    """
  end
end
