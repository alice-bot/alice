defmodule Alice.Handlers.HelpTest do
  alias Alice.Handlers.{
    Help,
    TestHandler
  }

  use Alice.HandlersCase, handlers: [Help, TestHandler]

  test "general_help lists the handlers as well as some other info" do
    send_message("<@alice> help")

    assert first_reply() == """
           _Here are all the handlers I know about…_

           > *Help*
           > *TestHandler*

           _Get info about a specific handler with_ `@alice help <handler name>`

           _Get info about all handlers with_ `@alice help all`

           _Feedback on Alice is appreciated. Please submit an issue at https://github.com/alice-bot/alice/issues _
           """
  end

  test "keyword_help returns general help when the keyword isn't found" do
    send_message("<@alice> help bogus handler")

    assert all_replies() == [
             ~s(I can't find a handler matching "bogushandler"),
             """
             _Here are all the handlers I know about…_

             > *Help*
             > *TestHandler*

             _Get info about a specific handler with_ `@alice help <handler name>`

             _Get info about all handlers with_ `@alice help all`

             _Feedback on Alice is appreciated. Please submit an issue at https://github.com/alice-bot/alice/issues _
             """
           ]
  end

  test "keyword_help lists help for a single handler" do
    send_message("<@alice> help test handler")

    assert all_replies() == [
             """
             _*Pro Tip:* Commands require you @ mention me, routes do not_

             _Here are all the routes and commands I know for "testhandler"_

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
           ]
  end

  test "keyword_help lists help for all handlers" do
    send_message("<@alice> help all")

    assert all_replies() == [
             "_*Pro Tip:* Commands require you @ mention me, routes do not_",
             ~s(_Here are all the routes and commands I know about…_),
             """
             >*Alice.Handlers.Help*
             >
             > *Commands:*
             >    _general_help_
             >        `@alice help` - lists all known handlers
             >    _keyword_help_
             >        `@alice help all` - outputs the help text for each route in every handler
             >        `@alice help <handler name>` - outputs the help text for a single matching handler
             """,
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
           ]
  end
end
