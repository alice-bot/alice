defmodule Alice.Bot do
  @moduledoc """
  Receives messages from an adapter and route them to matching route handlers.

  ## Creating and configuring a Bot

  Expects `:otp_app` as an option when used. This should be the name of your bot
  app.

      defmodule Rebecca.Bot do
        use Alice.Bot, otp_app: :rebecca
      end

  This bot should then be configured with:

      config :rebecca, Rebecca.Bot,
        adapter: Alice.Adapters.Console,
        name: "rebeccaaaaa"

  ## General Configuration Options

  Check the adapter docs for information on adapter-specific configration options.

  *`adapter` - the adapter module
  *`name` - name the bot will respond to
  *`handers` - list of handlers to register
  """

  defstruct adapter: nil,
            name: nil,
            handlers: [],
            handler_sup: [],
            opts: []

  def new(adapter, name, handlers, handler_sup, opts) do
    %__MODULE__{
      adapter: adapter,
      name: name,
      handlers: handlers,
      handler_sup: handler_sup,
      opts: opts
    }
  end

  @doc false
  def start_link(bot, opts) do
    GenServer.start_link(bot, {bot, opts})
  end

  @doc "Send a message"
  def reply(bot, msg), do: GenServer.cast(bot, {:reply, msg})

  @doc "Get the name of the bot"
  def name(bot), do: GenServer.call(bot, :name)

  @doc "Get the handlers"
  def handlers(bot), do: GenServer.call(bot, :handlers)

  @doc "Get the handler pids"
  def handler_processes(bot), do: GenServer.call(bot, :handler_processes)

  @doc """
  Invokes a user defined `handle_in/2` function, if defined.

  This function should be called by an adapter when a message arrives but
  should be handled by the user module.

  Returning `{:dispatch, msg, state}` will dispatch the message
  to all installed handlers.

  Returning `{:reply, {msg, text}, state}` will reply the message directly to the
  adapter without dispatching to any handlers.

  Returning `{:noreply, state}` will ignore the message.
  """
  def handle_in(bot, msg) do
    GenServer.cast(bot, {:handle_in, msg})
  end

  @doc """
  Invokes a user defined `handle_connect/1` function, if defined.

  If the user has defined an `handle_connect/1` in the bot module, it will be
  called with the bot's state. It is expected that the function return
  `{:ok, state}` or `{:stop, reason, state}`.
  """
  def handle_connect(bot, timeout \\ 5000) do
    GenServer.call(bot, :handle_connect, timeout)
  end

  @doc """
  Invokes a user defined `handle_disconnect/1` function, if defined.

  If the user has defined an `handle_disconnect/1` in the bot module, it will be
  called with the bot's state. It is expected that the function return
  `{:reconnect, state}` `{:reconnect, integer, state}`, or `{:disconnect, reason, state}`.
  """
  def handle_disconnect(bot, reason, timeout \\ 5000) do
    GenServer.call(bot, {:handle_disconnect, reason}, timeout)
  end

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      use GenServer
      require Logger

      config = Alice.Bot.Config.init_config(__MODULE__, opts)

      @adapter config.adapter
      @before_compile config.adapter
      @config config.bot_config
      @log_level config.bot_config[:log_level]
      @otp_app config.otp_app

      def start_link(opts \\ []) do
        Alice.start_bot(__MODULE__, opts)
      end

      def stop(bot), do: Alice.stop_bot(bot)

      def get_config do
        @config
      end

      def get_config(key) do
        Keyword.get(get_config(), key, :not_found)
      end

      def bot_config(opts) do
        Alice.Bot.Config.get_bot_config!(__MODULE__, @otp_app, opts)
      end

      def log(msg) do
        Logger.unquote(@log_level)(fn()-> msg end, [])
      end

      def __adapter__, do: @adapter

      def init({bot_module, opts}) do
        with {handlers, opts}   <- register_handlers(bot_module.bot_config(opts)),
             {:ok, adapter}     <- @adapter.start_link(bot_module, opts),
             {:ok, handler_sup} <- Alice.Handler.Supervisor.start_link(),
             name               <- opts[:name],
             bot                <- Alice.Bot.new(adapter, name, handlers, handler_sup, opts) do
          {:ok, bot}
        else
          _ -> {:stop, :shutdown}
        end
      end

      defp register_handlers(opts) do
        {handlers, opts} = Keyword.pop(opts, :handlers, [])
        GenServer.cast(self(), {:register_handlers, handlers})
        {handlers, opts}
      end

      def handle_connect(state) do
        {:ok, state}
      end

      def handle_disconnect(_reason, state) do
        {:reconnect, state}
      end

      def handle_in(%Alice.Message{} = msg, state) do
        {:dispatch, msg, state}
      end
      def handle_in(_msg, state) do
        {:noreply, state}
      end

      def handle_call(:name, _from, %{name: name} = state) do
        {:reply, name, state}
      end
      def handle_call(:handler_processes, _from, %{handler_sup: sup} = state) do
        handler_processes =
          sup
          |> Supervisor.which_children()
          |> Enum.map(fn({_,pid,_,_}) ->
            {_,[{_,{mod,_,_}}|_]} = Process.info(pid, :dictionary)
            {mod, pid}
          end)
        {:reply, handler_processes, state}
      end
      def handle_call(:handlers, _from, %{handlers: handlers} = state) do
        {:reply, handlers, state}
      end
      def handle_call(:handle_connect, _from, state) do
        case handle_connect(state) do
          {:ok, state}         -> {:reply, :ok, state}
          {:stop, _, _} = stop -> stop
        end
      end
      def handle_call({:handle_disconnect, reason}, _from, state) do
        case handle_disconnect(reason, state) do
          {:reconnect, state}          -> {:reply, :reconnect, state}
          {:reconnect, timer, state}   -> {:reply, {:reconnect, timer}, state}
          {:disconnect, reason, state} -> {:stop, reason, {:disconnect, reason}, state}
        end
      end

      def handle_cast({:reply, msg}, %{adapter: adapter} = state) do
        @adapter.reply(adapter, msg)
        {:noreply, state}
      end
      def handle_cast({:handle_in, msg}, state) do
        case handle_in(msg, state) do
          {:dispatch, %Alice.Message{} = msg, state} ->
            handlers = Supervisor.which_children(state.handler_sup)
            Alice.Handler.dispatch(msg, handlers)
            {:noreply, state}

          {:dispatch, _msg, state} ->
            log_incorrect_return(:dispatch)
            {:noreply, state}

          {:reply, {%Alice.Message{} = msg, text}, state} ->
            Alice.Handler.Helpers.reply(msg, text)
            {:noreply, state}

          {operation, {_msg, _text}, state} ->
            log_incorrect_return(operation)
            {:noreply, state}

          {:noreply, state} -> {:noreply, state}
        end
      end
      def handle_cast({:register_handlers, handlers}, %{name: name, handler_sup: sup} = state) do
        handlers = ensure_builtin_handlers(handlers)
        Enum.each(handlers, fn(handler) ->
          Supervisor.start_child(sup, [handler, {name, self()}])
        end)
        {:noreply, %{state | handlers: handlers}}
      end

      defp ensure_builtin_handlers(handlers) when is_list(handlers) do
        Enum.reduce(Alice.Handler.builtins(), handlers, fn(builtin, acc) ->
          if builtin in acc do
            acc
          else
            [builtin | acc]
          end
        end)
      end

      def handle_info(msg, state), do: {:noreply, state}

      def terminate(_reason, _state), do: :ok

      def code_change(_old, state, _extra), do: {:ok, state}

      defp log_incorrect_return(subject) do
        Logger.warn """
        #{inspect subject} return value from `handle_in/2` only works with `%Alice.Message{}` structs.
        """
      end

      defoverridable [
        {:handle_connect, 1},
        {:handle_disconnect, 2},
        {:handle_in, 2},
        {:terminate, 2},
        {:code_change, 3},
        {:handle_info, 2}
      ]
    end
  end
end
