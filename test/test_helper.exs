defmodule Mock do
  def setup(name, params), do: setup(name, params, default_return: nil)

  def setup(name, params, default_return: value) do
    send(self(), {name, params})

    receive do
      {:return, {^name, value}} -> value
    after
      0 -> value
    end
  end

  def setup_return(name, value) do
    send(self(), {:return, {name, value}})
  end
end

ExUnit.start()
