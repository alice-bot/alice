use Mix.Config

config :alice, api_key: System.get_env("AWESOME_SLACK_KEY")
config :logger, level: :info, truncate: 512
