defmodule Alice.Conn do
  defstruct message: "", slack: %{}, state: []

  def make(m, sl, st \\ []), do: make({m, sl, st})
  def make({m, sl, st}), do: %__MODULE__{message: m, slack: sl, state: st}
end
