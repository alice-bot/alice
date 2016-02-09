defmodule Alice.Mixfile do
  use Mix.Project

  def project do
    [app: :alice,
     version: "0.0.2",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "A Slack bot",
     # escript: [main_module: Alice.Cli],
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :slack, :mix],
     mod: {Alice, [Alice.Handlers.Random,
                   Alice.Handlers.OhYouSo,
                   Alice.Handlers.GoogleImages]}]
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
    [{:poison, "~> 2.0"},
     {:slack, "~> 0.4"},
     {:websocket_client, github: "jeremyong/websocket_client"}]
  end

  defp package do
    [files: ["lib", "config", "mix.exs", "README*"],
     maintainers: ["Adam Zaninovich"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/adamzaninovich/alice",
              "Docs"   => "https://github.com/adamzaninovich/alice"}]
  end
end
