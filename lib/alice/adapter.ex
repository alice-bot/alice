defmodule Alice.Adapter do
  @moduledoc """
  Alice Adapter Behaviour

  An Adapter is the interface to the service your bot runs on. To implement an
  adapter you will need to translate messages from the service to the
  `Alice.Message` struct and call `Alice.Bot.handle_message(bot, msg)`.
  """

  @typedoc "The pid of the bot process"
  @type bot :: pid

  @typedoc "The state for the adapter. Normally a Map, but can be anything"
  @type state :: any

  @typedoc "Initialization options for the adapter"
  @type options :: keyword

  @typedoc "An Alice.Message struct"
  @type msg :: Alice.Message.t

  @doc """
  Invoked when the adapter starts. Use this callback to connect to
  your service and initialize any state that the adapter needs to
  keep track of.

  In case of successful start, this callback must return a tuple
  where the first element is `:ok` and the second is the state.

  Returning `{:stop, reason}` will cause `start_link/3` to return
  `{:error, reason}` and the process to exit with reason `reason`
  without entering the loop or calling `terminate/2`.
  """
  @callback connect(bot, options) ::
    {:ok, state} |
    {:stop, reason :: any}

  @doc """
  This is an optional callback that may be implemented if you need to
  do any work after a successful connection.
  """
  @callback handle_connected(state) :: {:ok, state}

  @doc """
  This callback is required and handles outgoing messages from the bot
  process to your service. This is the appropriate place to translate
  the `Alice.Message` struct into a message format that your service
  understands and send the message to the external service.
  """
  @callback handle_outgoing(msg, state) :: {:ok, state}

  @doc """
  This callback is required and handles incoming messages from your
  external service to a bot instance. This is the appropriate place
  to translate a message from your service into an `Alice.Message`
  struct.

  Returning `{:ok, msg, state}` will send the message to the bot
  instance to be dispatched to handlers.

  Returning `{:noreply, state}` will effectively ignore the message
  and nothing will be dispatched to the handlers.
  """
  @callback handle_incoming(ext_msg :: any, state) ::
    {:ok, msg, state} |
    {:noreply, state}

  @doc "start an adapter"
  def start_link(adapter_module, bot_pid, opts) do
    GenServer.start_link(adapter_module, {bot_pid, opts})
  end

  @doc "send an outgoing message through an adapter"
  def reply(adapter_pid, %Alice.Message{} = msg) do
    GenServer.cast(adapter_pid, {:outgoing, msg})
  end

  @doc false
  defmacro __using__(_opts) do
    quote do
      use GenServer
      @behaviour Alice.Adapter

      @doc "Default implementation for `handle_connected`"
      def handle_connected(state), do: {:ok, state}

      @doc false
      def stop(adapter, timeout \\ 5000) do
        ref = Process.monitor(adapter)
        Process.exit(adapter, :normal)
        receive do
          {:DOWN, ^ref, _, _, _} -> :ok
        after
          timeout -> exit(:timeout)
        end
        :ok
      end

      @doc false
      def init({bot, opts}) do
        with {:ok, state} <- connect(bot, opts) do
          send(self(), :connected)
          {:ok, {bot, state}}
        else
          {:exit, reason} -> {:exit, reason}
        end
      end

      @doc false
      def handle_cast({:outgoing, %Alice.Message{} = msg}, {bot, state}) do
        {:ok, state} = handle_outgoing(msg, state)
        {:noreply, {bot, state}}
      end

      @doc false
      def handle_info(:connected, {bot, state}) do
        :ok = Alice.Bot.handle_connect(bot)
        {:ok, state} = handle_connected(state)
        {:noreply, {bot, state}}
      end
      def handle_info({:incoming, ext_msg}, {bot, state}) do
        state = case handle_incoming(ext_msg, state) do
          {:ok, %Alice.Message{} = msg, state} ->
            Alice.Bot.handle_in(bot, msg)
            state
          {:noreply, state} -> state
        end
        {:noreply, {bot, state}}
      end

      defoverridable handle_connected: 1
    end
  end
end
