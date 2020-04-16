defmodule AliceNew.MixProject do
  use Mix.Project

  @alice_version "0.4.3"
  @github_path "alice-bot/alice_new"
  @url "https://github.com/#{@github_path}"

  def project do
    [
      app: :alice_new,
      start_permanent: Mix.env() == :prod,
      version: @alice_version,
      elixir: "~> 1.7",
      deps: deps(),
      package: [
        licenses: ["MIT"],
        links: %{github: @url},
        files: ~w(lib templates mix.exs README.md)
      ],
      source_url: @url,
      docs: docs(),
      homepage_url: "https://www.alice-bot.org",
      aliases: aliases(),
      preferred_cli_env: [
        build: :prod,
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      test_coverage: [tool: ExCoveralls],
      description: """
      Alice project generator.

      Provides a `mix alice.new.handler` task to bootstrap a new Alice handler
      """
    ]
  end

  def application do
    [
      extra_applications: [:eex]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :docs},
      {:excoveralls, "~> 0.12", only: :test},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false, optional: true}
    ]
  end

  defp docs do
    [
      main: "Mix.Tasks.Alice.New.Handler",
      source_url_pattern:
        "https://github.com/#{@github_path}/blob/v#{@alice_version}/installer/%{path}#L%{line}"
    ]
  end

  defp aliases do
    [
      build: [&build_releases/1]
    ]
  end

  defp build_releases(_) do
    Mix.Tasks.Compile.run([])
    Mix.Tasks.Archive.Build.run([])
    Mix.Tasks.Archive.Build.run(["--output=alice_new.ez"])
    File.mkdir_p("./archives")
    File.rename("alice_new.ez", "./archives/alice_new.ez")
    File.rename("alice_new-#{@alice_version}.ez", "./archives/alice_new-#{@alice_version}.ez")
  end
end
