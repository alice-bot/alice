defmodule TestHandler do
  use Alice.Handler

  route ~r/test route/i, :test_route
  route ~r/capture (?<this>.+)/i, :test_capture
  command ~r/test command/i, :test_command

  def test_route(msg, _state) do
    reply(msg, "route test received")
  end

  def test_capture(msg, _state) do
    reply(msg, "captured: #{inspect msg.captures}")
  end

  def test_command(msg, _state) do
    reply(msg, "command test received")
  end
end
