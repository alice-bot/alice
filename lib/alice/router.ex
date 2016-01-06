require IEx

defmodule Alice.Router do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import Alice.Router
      # import Slack
      # import Slack.Handlers

      @routes []

      @before_compile Alice.Router
    end
  end

  defmacro match(pattern, do: block) do
    function_name = String.to_atom("match" <> pattern)
    quote do
      @routes [unquote(function_name)|@routes]
      def unquote(function_name)(message, slack) do
        unquote(pattern)
        |> Regex.compile!("i")
        |> Regex.match?(message.text)
        |> case do
          true -> unquote(block)
          false -> IO.puts("no match for #{message.text}")
        end
      end
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def route(message, slack) do
        Enum.each @routes, fn name ->
          IO.puts "Routing #{name}"
          apply(__MODULE__, name, [message, slack])
        end
      end
    end
  end
end

defmodule Alice.Routes.Random do
  use Alice.Router

  match "dark ?souls?" do
    # send_message("http://i.imgur.com/JVwRUtw.gif", message.channel, slack)
    # IEx.pry
    IO.puts "OMG #{message.text}"
  end

end
