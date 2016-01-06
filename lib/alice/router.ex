require IEx

defmodule Alice.Router do
  @route_handlers []

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Alice.Router
      # import Slack
      # import Slack.Handlers

      @routes []

      @before_compile Alice.Router

      defp reply(conn = %{message: %{channel: channel}, slack: slack}, response) do
        # send_message(response, channel, slack)
        IO.puts response
        conn
      end
    end
  end

  defmacro route(pattern, name) do
    quote do
      @routes [{unquote(pattern), unquote(name)}|@routes]
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def match_routes(message, slack, state \\ []) do
        Enum.each @routes, fn {pattern, name} ->
          if Regex.match?(pattern, message.text) do
            apply(__MODULE__, name, [%{message: message, slack: slack, state: state}])
          end
        end
      end
    end
  end
end

defmodule Alice.Routes.Random do
  use Alice.Router

  route ~r/dark ?souls?/i, :dark_souls

  def dark_souls(conn) do
    reply(conn, "http://i.imgur.com/JVwRUtw.gif")
  end
end
