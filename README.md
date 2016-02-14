![](http://i.imgur.com/UndMkm3.png)

# Alice

A Lita-inspired Slack bot written in Elixir.

Very much a work in progress, it works well, but there are some major architectural changes coming.

## Writing Route Handlers

### Example

```elixir
defmodule Alice.Handlers.Hello do
  use Alice.Router

  route ~r/\Ahello\z/i, :hello
  route ~r/\Agoodbye\z/i, :goodbye

  def handle(conn, :hello),   do: "Hello, there!" |> reply(conn)
  def handle(conn, :goodbye), do: "Goodbye!" |> reply(conn)
end
```

### Registering Handlers

In `mix.exs`, add your handler to the list of handlers to register on start

```elixir
def application do
  [applications: [:alice],
   mod: {Alice, [Alice.Handlers.Random, Alice.Handlers.Hello]}]
end
```
