defmodule Alice.Router do
  use GenServer

  defmodule State do
    defstruct handlers: MapSet.new
  end

  # Client

  @doc """
  Starts a Alice.Router process linked to the current process.

  Note that a process started with `start_link/2` is linked to the parent process
  and will exit in case of crashes.

  ## Options

  You can pass in a list of handlers to be registered immediately upon starting
  the Router process.

  For other options, see `GenServer.start_link/3`. Default is to register the
  process with the name `Alice.Router`.

  ## Return values

  If the router is successfully created and initialized, the function returns
  `{:ok, pid}`, where `pid` is the pid of the router.
  """
  def start_link(handlers \\ [], opts \\ [name: Alice.Router]) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %State{}, opts)
    for handler <- handlers, do: register_handler(pid, handler)
    {:ok, pid}
  end

  @doc """
  Returns a list of the currently registered handlers.

  If you started the router with default options, then you don't have to pass in a
  pid. (It will use the default registered name `Alice.Router`.
  """
  def handlers(pid \\ Alice.Router) do
    GenServer.call(pid, :get_handlers)
  end

  @doc """
  Registers a handler. Returns `:ok`
  """
  def register_handler(pid \\ Alice.Router, handler) do
    GenServer.cast(pid, {:register_handler, handler})
  end

  @doc """
  Used internally to match route handlers
  """
  def match_routes(conn) do
    Enum.reduce(handlers, conn, &(&1.match_routes(&2)))
  end

  @doc """
  Used internally to match command handlers
  """
  def match_commands(conn) do
    Enum.reduce(handlers, conn, &(&1.match_commands(&2)))
  end

  # GenServer API

  @doc false
  def handle_call(:get_handlers, _from, state) do
    {:reply, MapSet.to_list(state.handlers), state}
  end

  @doc false
  def handle_cast({:register_handler, handler}, state) do
    {:noreply, %{state | handlers: MapSet.put(state.handlers, handler)}}
  end

  # Macros

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Alice.Router.Helpers
      require Logger
      Module.register_attribute __MODULE__, :routes, accumulate: true
      Module.register_attribute __MODULE__, :commands, accumulate: true
      @before_compile Alice.Router.Helpers

      defp namespace(key), do: {__MODULE__, key}
    end
  end
end
