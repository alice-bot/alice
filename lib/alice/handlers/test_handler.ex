defmodule Alice.Handlers.TestHandler do
  use Alice.Router

  route   ~r/cmd1/,     :command1
  route   ~r/hidden/,   :hidden
  command ~r/cmd1/,     :command1
  command ~r/cmd2/i,    :command2
  command ~r/cmd3/i,    :command3
  command ~r/no docs/i, :no_docs

  @doc "`cmd1`: does some stuff"
  def command1(_conn), do: nil

  # This should not show up in the help text at all
  @doc false
  def hidden(_conn), do: nil

  @doc """
  `cmd2`: does some other stuff
  also this one is multiline
  """
  def command2(_conn), do: nil

  @doc """
  this one doesn't start with an
  example so no @alice is added
  """
  def command3(_conn), do: nil

  def no_docs(_conn), do: nil

  @doc """
  this function should not
  appear in help because it's
  not a route or command
  """
  def another_func, do: nil
end
