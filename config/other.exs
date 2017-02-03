use Mix.Config

config :alice,
  adapter: Alice.Adapters.TestAdapter,
  handlers: [Alice.Handlers.TestHandler]
