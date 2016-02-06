defmodule Alice.Mixfile do
  use Mix.Project

  def project do
    [app: :alice,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "A Slack bot",
     escript: escript,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :slack, :mix],
     mod: {Alice, [Alice.Handlers.Random, Alice.Handlers.OhYouSo]}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:slack, "~> 0.4.1"},
     {:websocket_client, github: "jeremyong/websocket_client"}]
  end

  defp escript do
    [
      main_module: Alice.Cli
    ]
  end

  defp package do
    [files: ["lib", "config", "mix.exs", "README*"],
     maintainers: ["Adam Zaninovich"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/adamzaninovich/alice",
              "Docs"   => "https://github.com/adamzaninovich/alice"}]
  end
end
