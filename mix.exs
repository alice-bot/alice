defmodule Alice.Mixfile do
  use Mix.Project

  def project do
    [
      app: :alice,
      version: "2.0.0-alpha.1",
      elixir: "~> 1.5",
      docs: docs(),
      deps: deps(),
      package: package(),
      name: "Alice",
      elixirc_paths: elixirc_paths(Mix.env),
      description: "An elixir chat bot framework (now with adapters)",
      source_url: "https://github.com/alice-bot/alice",
      homepage_url: "https://github.com/alice-bot/alice",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
       "coveralls": :test,
       "coveralls.html": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Alice, []}
    ]
  end

  defp docs do
    [extras: ["README.md"],
     main: "readme"]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.7", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Adam Zaninovich"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/alice-bot/alice",
        "Docs" => "https://hexdocs.pm/alice"
      }
    ]
  end
end
