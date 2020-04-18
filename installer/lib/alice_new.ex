defmodule AliceNew do
  @moduledoc ~S"""
  Provides a mix task that generates a new Alice handler.

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
  mix test
  mix alice.console
  ```
  """

  @alice_version Mix.Project.config()[:version]

  @doc """
  Returns the version of Alice used to build projects
  """
  def alice_version(), do: @alice_version

  @doc """
  Returns the Elixir version formatted with major and minor. Includes the
  pre-release identifier, if present.

  Uses the current Elixir version provided by `System.version/0`

  ## Examples

      iex> elixir_version()
      "1.7"
  """
  def elixir_version(), do: elixir_version(System.version())

  @doc """
  Returns the Elixir version formatted with major and minor. Includes the
  pre-release identifier, if present.

  Uses the version passed in.

  ## Examples

      iex> elixir_version("1.10.5-rc.2")
      "1.10-rc"
  """
  def elixir_version(system_version) do
    {:ok, version} = Version.parse(system_version)

    "#{version.major}.#{version.minor}" <>
      case version.pre do
        [pre_release_identifier | _] -> "-#{pre_release_identifier}"
        [] -> ""
      end
  end
end
