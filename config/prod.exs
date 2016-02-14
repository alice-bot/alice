use Mix.Config

config :alice, api_key: System.get_env("AWESOME_SLACK_KEY")
config :alice, :state_backend, :redis
config :alice, :redis, System.get_env("REDIS_URL")

config :logger, level: :info, truncate: 512
