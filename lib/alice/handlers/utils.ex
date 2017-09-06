defmodule Alice.Handlers.Utils do
  use Alice.Handler

  route ~r/ping$/i, :ping
  command ~r/\binfo$/i, :info
  command ~r/\bdebug (msg|message)$/i, :debug_msg
  command ~r/\bdebug state$/i, :debug_state

  @doc "`ping` - responds with signs of life"
  def ping(msg, _state) do
    ["PONG!", "Can I help you?", "Yes...I'm still here.", "I'm alive!"]
    |> random_reply(msg)
  end

  @doc "`info` - info about Alice and the system"
  def info(msg, _state) do
    {total, process} = memory_info()

    reply(msg, "Alice #{alice_version()} - https://github.com/adamzaninovich/a2")
    reply(msg, "Total memory: #{total}MB - Allocated to processes: #{process}MB")
  end

  @doc "`debug msg` - the current `Alice.Message` datastruct for debugging"
  def debug_msg(msg, _state) do
    m = Map.put(msg, :private, %{})
    reply(msg, format_code(m))
  end

  @doc "`debug state` - the current `Alice.Adapter` state for debugging"
  def debug_state(msg, state) do
    reply(msg, format_code(state))
  end

  defp memory_info do
    mem = :erlang.memory
    {bytes_to_megabytes(mem[:total]),
     bytes_to_megabytes(mem[:processes])}
  end

  defp bytes_to_megabytes(bytes) do
    Float.round(bytes / :math.pow(1024,2), 2)
  end

  defp alice_version, do: alice_version(Application.loaded_applications)
  defp alice_version([{:alice, _desc, version} | _apps]), do: version
  defp alice_version([]), do: "Unknown Version"
  defp alice_version([_app|apps]), do: alice_version(apps)

  defp format_code(code) do
    """
    ```
    #{inspect code}
    ```
    """
  end
end
