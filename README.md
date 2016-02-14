![](http://i.imgur.com/UndMkm3.png)

# Alice

A Lita-inspired Slack bot written in Elixir.

Very much a work in progress, but it works well enough.

For an example bot, see the [awesome_friendz_alice](https://github.com/adamzaninovich/awesome_friendz_alice) bot.
For an example handler, see [alice_google_images](https://github.com/adamzaninovich/alice_google_images).

# Creating a Route Handler Plugin

## First Steps

```sh
mix new alice_google_images
cd alice_google_images
rm lib/alice_google_images.ex
mkdir -p lib/alice/handlers
touch lib/alice/handlers/google_images.ex
```

## Configuring the App

In `mix.exs`, update `application` and `deps` to look like the following:

```elixir
def application do
  [applications: []]
end

defp deps do
  [
    {:websocket_client, github: "jeremyong/websocket_client"},
    {:alice, "~> 0.1.0"}
  ]
end
```

## Writing Route Handlers

In `lib/alice/handlers/google_images.ex`:

```elixir
defmodule Alice.Handlers.GoogleImages do
  use Alice.Router

  command ~r/(image|img)\s+me (?<term>.+)/i, :fetch
  route   ~r/(image|img)\s+me (?<term>.+)/i, :fetch

  def handle(conn, :fetch) do
    conn
    |> extract_term
    |> get_images
    |> select_image
    |> reply(conn)
  end

  #...
end
```

## Registering Handlers

In the `mix.exs` file of your bot, add your handler to the list of handlers to register on start

```elixir
def application do
  [applications: [:alice],
   mod: {Alice, [Alice.Handlers.GoogleImages, ...]}]
end
```
