defmodule Alice.Handler.Supervisor do
  def start_link do
    import Supervisor.Spec, warn: false

    children = [
      worker(Alice.Handler, [], restart: :transient)
    ]
    Supervisor.start_link(children, strategy: :simple_one_for_one)
  end
end
