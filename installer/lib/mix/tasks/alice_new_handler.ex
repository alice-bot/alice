defmodule Mix.Tasks.Alice.New.Handler do
  @moduledoc """
  Generates a new Alice handler.

  It expects the path of the handler as an argument.

      mix alice.new.handler PATH [--module MODULE] [--app APP]

  An Alice handler at the given PATH will be created.
  The application name and module name will be retrieved
  from the path, unless `--module` or `--app` is given.

  ## Options

    * `--app` - the name of the OTP application

    * `--module` - the name of the handler module

  ## Examples

      mix alice.new.handler hello_world

  Is equivalent to:

      mix alice.new.handler hello_world --module HelloWorld --app hello_world

  To print the Alice installer version, pass `-v` or `--version`, for example:

      mix alice.new.handler -v

  To print this help text, pass `-h` or `--help`, for example:

      mix alice.new.handler -h
  """
  use Mix.Task

  alias AliceNew.{
    FileUtilities,
    HandlerGenerator
  }

  @shortdoc "Creates a new Alice v#{AliceNew.alice_version()} handler"

  @switches [
    app: :string,
    module: :string
  ]

  def run([version]) when version in ~w[-v --version] do
    Mix.shell().info("Alice v#{AliceNew.alice_version()}")
  end

  def run([help]) when help in ~w[-h --help] do
    Mix.Tasks.Help.run(["alice.new.handler"])
  end

  def run(argv) do
    case parse_opts(argv) do
      {_opts, []} ->
        Mix.Tasks.Help.run(["alice.new.handler"])

      {opts, [given_path | _]} ->
        FileUtilities.elixir_version_check!()

        path = FileUtilities.handler_path(given_path)
        name = FileUtilities.handler_name(given_path, opts)
        app = FileUtilities.handler_otp_app(name)
        module = FileUtilities.handler_module(name, opts)

        FileUtilities.create_directory!(path)

        File.cd!(path, fn ->
          HandlerGenerator.generate(path, name, app, module)
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
