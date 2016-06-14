defmodule Alice.Bot do
  @moduledoc "Alice Bot"

  alias Alice.Conn
  alias Alice.Router
  alias Alice.Earmuffs
  alias Alice.State

  def start_link(adapter \\ Alice.Adapters.Slack) do
    {:ok, pid, _} = Alice.Adapters.start_link(adapter)
    {:ok, pid}
  end

  # TODO: The state needs to be updated more granularly. This is simply a step
  #       in the direction of decoupling state from the adapter and bot.
  #       Eventually state will no longer need to be a part of Alice.Conn
  def respond_to_message(message, adapter_state) do
    try do
      {message, adapter_state, State.get_state}
      |> Conn.make
      |> Conn.sanitize_message # TODO: possibly move this to Slack adapter?
      |> respond
    rescue
      error -> IO.puts(Exception.format(:error, error))
    end
  end

  defp respond(conn = %Conn{}) do
    conn = cond do
      Earmuffs.blocked?(conn) -> Earmuffs.unblock(conn)
      Conn.command?(conn)     -> Router.match_commands(conn)
      true                    -> Router.match_routes(conn)
    end
    # NOTE: This is only temporary to keep things working for now. This would
    #       not be acceptable for release as it overwrites the state completely
    #       meaning that adapters cannot run concurrently, which is kind of the
    #       whole point
    State.put_state(conn.state)
  end
end
