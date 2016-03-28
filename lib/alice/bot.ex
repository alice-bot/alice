defmodule Alice.Adapters.TestAdapter do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state), do: {:ok, state}

  def send_message(message, data) do
    GenServer.call(__MODULE__, {:message, {message, data}})
  end

  def handle_call({:message, {message, data}}, _from, state) do
    Alice.Bot.handle_message(message, data, state)
  end
end

defmodule Alice.Bot do
  use GenServer

  alias Alice.Conn
  alias Alice.Router
  alias Alice.Earmuffs

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, adapter_pid} = adapter.start_link(initial_state)
    {:ok, adapter_pid}
  end

  defp initial_state do
    case Application.get_env(:alice, :state_backend) do
      :redis -> Alice.StateBackends.Redis.get_state
      _else  -> %{}
    end
  end

  defp adapter do
    Alice.Adapters.TestAdapter
    # Application.get_env(:alice, :adapter)
  end

  def handle_message(message, adapter_data, state) do
    GenServer.call(__MODULE__, {:message, {message, adapter_data, state}})
  end

  # Server Callbacks

  def handle_call({:message, conn_data = {_, _, state}}, _from, _adapter_pid) do
    try do
      conn_data
      |> Conn.make
      |> Conn.sanitize_message
      |> do_handle_message
    rescue
      error ->
        IO.puts(Exception.format(:error, error))
        {:reply, state}
    end
  end

  defp do_handle_message(conn = %Conn{}) do
    conn = cond do
      Earmuffs.blocked?(conn) -> Earmuffs.unblock(conn)
      Conn.command?(conn)     -> Router.match_commands(conn)
      true                    -> Router.match_routes(conn)
    end
    {:reply, conn.state}
  end
end
