defmodule Alice.Handler do
  @moduledoc """
  Lots of information about handlers...
  """

  def builtins() do
    [
      Alice.Handlers.Help,
      Alice.Handlers.Utils
    ]
  end

  def start_link(module, {name, bot}) do
    GenServer.start_link(module, {name, bot})
  end

  def dispatch(msg, handlers) do
    Enum.map(handlers, fn({_, pid, _, _}) ->
      GenServer.cast(pid, {:dispatch, msg})
    end)
  end

  def routes(pid), do: GenServer.call(pid, :routes)

  def commands(pid), do: GenServer.call(pid, :commands)

  defmacro route(regex, name) do
    quote do
      @routes {unquote(regex), unquote(name)}
    end
  end

  defmacro command(regex, name) do
    quote do
      @commands {unquote(regex), unquote(name)}
    end
  end

  @doc false
  def command_pattern(regex, name) do
    regex
    |> Regex.source
    |> rewrite_command_pattern(name)
    |> Regex.compile!(Regex.opts(regex))
  end

  defp rewrite_command_pattern(source, name) do
    "^\\s*[@]?#{name}[:,]?\\s*(?:#{source})"
  end

  defmacro __using__(_opts) do
    quote location: :keep do
      import unquote(__MODULE__)
      import Alice.Handler.Helpers

      Module.register_attribute __MODULE__, :routes, accumulate: true
      Module.register_attribute __MODULE__, :commands, accumulate: true

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      def init({name, bot}) do
        :ok = GenServer.cast(self(), :compile_commands)

        {:ok, %{
          name: name,
          opts: :not_implemented,
          patterns: [],
          routes: [],
          commands: [],
          bot: bot
        }}
      end

      def handle_call(:routes, _from, %{routes: routes} = state) do
        {:reply, routes, state}
      end
      def handle_call(:commands, _from, %{commands: commands} = state) do
        {:reply, commands, state}
      end

      def handle_cast(:compile_commands, %{name: name} = state) do
        {:noreply, %{state | patterns: compile_commands(name),
                             routes: @routes,
                             commands: @commands}}
      end
      def handle_cast({:dispatch, msg}, state) do
        {:noreply, dispatch_routes(msg, state)}
      end

      defp compile_commands(bot_name) do
        commands = for {regex, function_name} <- @commands do
          regex = Alice.Handler.command_pattern(regex, bot_name)
          {regex, function_name}
        end

        List.flatten([commands, @routes])
      end

      defp dispatch_routes(msg, %{patterns: patterns} = state) do
        Enum.reduce(patterns, state, fn(route, new_state) ->
          case dispatch_route(route, msg, new_state) do
            :ok -> new_state
            {:ok, new_state} -> new_state
          end
        end)
      end

      defp dispatch_route({regex, fun}, %{text: text} = msg, state) do
        if Regex.match?(regex, text) do
          msg = %{msg | captures: find_captures(regex, text)}
          apply(__MODULE__, fun, [msg, state])
        else
          :ok
        end
      end

      def find_captures(regex, text) do
        case Regex.names(regex) do
          [] ->
            regex
            |> Regex.run(text)
            |> Enum.with_index()
            |> Enum.reduce(%{}, fn({capture, index}, captures) ->
              Map.put(captures, index, capture)
            end)
          _ -> Regex.named_captures(regex, text)
        end
      end
    end
  end
end
