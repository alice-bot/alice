defmodule Alice.StateBackends.StateBackend do
  @moduledoc """
  This defines a behavior for modules that serve as a state backend
  """

  @type state :: any()
  @type key :: any()
  @type value :: any()

  @callback get(state(), key(), default :: value()) :: value()
  @callback put(state(), key(), value()) :: state()
  @callback delete(state(), key()) :: state()
end
