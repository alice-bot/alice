defmodule Alice do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Seed the random number generator
    :random.seed(:erlang.now)

    children = [
      # Define workers and child supervisors to be supervised
      worker(Alice.Bot, [%{}]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Alice.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
