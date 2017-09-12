defmodule Alice.Adapter do
  @moduledoc """
  Alice Adapter Behaviour

  An Adapter is the interface to the service your bot runs on. To implement an
  adapter you will need to translate messages from the service to the
  `Alice.Message` struct and call `Alice.Bot.handle_message(bot, msg)`.
  """

  @type bot   :: pid
  @type state :: term
  @type opts  :: any
  @type msg   :: Alice.Message.t

  @callback reply(bot, msg) :: term

  @doc false
  def start_link(adapter_module, bot_pid, opts) do
    GenServer.start_link(adapter_module, {bot_pid, opts})
  end

  @doc false
  defmacro __using__(_opts) do
    quote do
      use GenServer
      @behaviour Alice.Adapter

      def reply(pid, %Alice.Message{} = msg) do
        GenServer.cast(pid, {:reply, msg})
      end

      @doc false
      def stop(bot, timeout \\ 5000) do
        ref = Process.monitor(bot)
        Process.exit(bot, :normal)
        receive do
          {:DOWN, ^ref, _, _, _} -> :ok
        after
          timeout -> exit(:timeout)
        end
        :ok
      end

      defoverridable [reply: 2]
    end
  end
end
