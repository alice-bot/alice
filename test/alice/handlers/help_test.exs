defmodule Alice.Handlers.HelpTest do
  use ExUnit.Case, async: true
  alias Alice.Handlers.Help
  alias Alice.Handlers.TestHandler

  test "help_for_handler generates the correct output" do
    assert Help.help_for_handler(TestHandler, %{slack: %{me: %{name: "alice"}}}) ==
    """
    >*Alice.Handlers.TestHandler*
    >
    > *Routes:*
    >    _command1_
    >        `cmd1`: does some stuff
    >
    > *Commands:*
    >    _command1_
    >        `@alice cmd1`: does some stuff
    >    _command2_
    >        `@alice cmd2`: does some other stuff
    >        also this one is multiline
    >    _command3_
    >        this one doesn't start with an
    >        example so no @alice is added
    >    _no_docs_
    >        _no documentation provided_
    """
  end
end
