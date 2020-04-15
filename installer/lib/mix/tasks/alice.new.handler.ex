defmodule Mix.Tasks.Alice.New.Handler do
  @moduledoc ~S"""
  Generates a new Alice handler.

  This is the easiest way to set up a new Alice handler.

  ## Install `alice.new`

  ```bash
  mix archive.install hex alice_new
  ```

  ## Build a Handler

  First, navigate the command-line to the directory where you want to create
  your new Alice handler. Then run the following commands: (change `my_handler`
  to the name of your handler)

  ```bash
  mix alice.new.handler my_handler
  cd alice_my_handler
  mix deps.get
  ```

  ## Writing Route Handlers

  In lib/alice/handlers/my_handler.ex:

  ```elixir
  defmodule Alice.Handlers.MyHandler do
    use Alice.Router

    command ~r/repeat after me: (?<term>.+)/i, :repeat
    route ~r/repeat after me: (?<term>.+)/i, :repeat

    @doc "`repeat after me: thing` - replies you said, 'thing'"
    def repeat(conn) do
      term = Alice.Conn.last_capture(conn)
      response_text = "you said, '#{term}'"

      reply(conn, response_text)
    end
  end
  ```

  ## Testing Handlers

  Alice provides several helpers to make it easy to test your handlers.  First
  you'll need to invoke to add `use Alice.HandlerCase, handlers:
  [YourHandler]` passing it the handler you're trying to test. Then you can use
  `message_received()` within your test, which will simulate a message coming
  in from the chat backend and route it through to the handlers appropriately.
  If you're wanting to invoke a command, you'll need to make sure your message
  includes `<@alice>` within the string. From there you can use either
  `first_reply()` to get the first reply sent out or `all_replies()` which will
  return a List of replies that have been received during your test. You can
  use either to use normal assertions on to ensure your handler behaves in the
  manner you expect.

  In `test/alice/handlers/my_handler_test.exs`:

  ```elixir
  defmodule Alice.Handlers.MyHandlerTest do
    use Alice.HandlerCase, handlers: Alice.Handlers.MyHandler

    test "the repeat command repeats a term" do
      send_message("<@alice> repeat after me: this is a boring handler")
      assert first_reply() == "you said, 'this is a boring handler'"
    end

    test "the repeat route repeats a term" do
      send_message("repeat after me: this is a boring handler")
      assert first_reply() == "you said, 'this is a boring handler'"
    end
  end
  ```

  ## Registering Handlers

  In the `mix.exs` file of your bot, add your handler to the list of handlers
  to register on start

  ```elixir
  def application do
    [ applications: [:alice],
      mod: {Alice, [Alice.Handlers.MyHandler] } ]
  end
  ```
  """
  use Mix.Task

  alias AliceNew.{
    HandlerGenerator,
    Utilities
  }

  @shortdoc "Creates a new Alice v#{Utilities.alice_version()} handler"

  @switches [
    name: :string,
    module: :string
  ]

  def run([version]) when version in ~w[-v --version] do
    Mix.shell().info("Alice v#{Utilities.alice_version()}")
  end

  def run(argv) do
    case parse_opts(argv) do
      {_opts, []} ->
        Mix.Tasks.Help.run(["alice.new.handler"])

      {opts, [path | _]} ->
        Utilities.elixir_version_check!()

        basename = Path.basename(Path.expand(path))
        path = Path.join([Path.dirname(path), "alice_#{basename}"])

        handler_name = opts[:name] || basename
        app = "alice_#{handler_name}"
        Utilities.check_handler_name!(handler_name, !opts[:name])

        module_name = opts[:module] || Macro.camelize(handler_name)
        Utilities.check_mod_name_validity!(module_name)
        module = Utilities.handler_module(module_name)

        unless path == "." do
          Utilities.check_directory_existence!(path)
          File.mkdir_p!(path)
        end

        File.cd!(path, fn ->
          HandlerGenerator.generate(app, handler_name, module, path)
        end)
    end
  end

  defp parse_opts(argv) do
    case OptionParser.parse(argv, strict: @switches) do
      {opts, argv, []} ->
        {opts, argv}

      {_opts, _argv, [{name, _val} | _]} ->
        Mix.raise("Invalid option: #{name}")
    end
  end
end
