# Alice [![Hex Version](https://img.shields.io/hexpm/v/alice.svg)](https://hex.pm/packages/alice) [![Hex Downloads](https://img.shields.io/hexpm/dt/alice.svg)](https://hex.pm/packages/alice) [![License: MIT](https://img.shields.io/hexpm/l/alice.svg)](https://hex.pm/packages/alice) [![Coverage Status](https://coveralls.io/repos/github/alice-bot/alice/badge.svg?branch=master)](https://coveralls.io/github/alice-bot/alice?branch=master)

#### A Lita-inspired Slack bot written in Elixir.

<img height="135" src="http://i.imgur.com/UndMkm3.png" align="left" />

_The Caterpillar and Alice looked at each other for some time in silence: at
last the Caterpillar took the hookah out of its mouth, and addressed her in a
languid, sleepy voice._

_"Who are YOU?" said the Caterpillar. This was not an encouraging opening for
conversation. Alice replied, rather shyly, "I—I hardly know, sir, just at
present—at least I know who I WAS when I got up this morning, but I think I must
have been changed several times since then."_

For an example bot, see the [Active Alice] bot. For an example handler, see
[Google Images Handler].

You'll need a Slack API token which can be retrieved from the [Web API page] or
by creating a new [bot integration].

[Active Alice]: https://github.com/adamzaninovich/active-alice
[Google Images Handler]: https://github.com/alice-bot/alice_google_images
[Web API page]: https://api.slack.com/web
[bot integration]: https://my.slack.com/services/new/bot

## Handler Plugins

Alice has a plug in system that allows you to customize the functionality of
your bot instance. See [the docs] for more information about creating your own
handlers.

[the docs]: https://github.com/alice-bot/alice#creating-a-route-handler-plugin

### Known Handlers

* Alice Against Humanity: [hex](https://hex.pm/packages/alice_against_humanity), [code](https://github.com/alice-bot/alice_against_humanity)
* Alice Google Images: [hex](https://hex.pm/packages/alice_google_images), [code](https://github.com/alice-bot/alice_google_images)
* Alice Karma: [hex](https://hex.pm/packages/alice_karma), [code](https://github.com/alice-bot/alice_karma)
* Alice Reddit: [hex](https://hex.pm/packages/alice_reddit), [code](https://github.com/alice-bot/alice_reddit)
* Alice Shizzle: [hex](https://hex.pm/packages/alice_shizzle), [code](https://github.com/notdevinclark/alice_shizzle)
* Alice XKCD: [hex](https://hex.pm/packages/alice_xkcd), [code](https://github.com/notdevinclark/alice_xkcd)
* Alice Doge [hex](https://hex.pm/packages/alice_doge_me), [code](https://github.com/alice-bot/alice_doge_me/)

If you write your own handler, please submit a pull request and update this
list!

## Creating Your Own Bot With Alice

### Create the Project

Create a new mix project.
```sh
mix new my_bot
cd my_bot
rm lib/my_bot.ex test/my_bot_test.exs
```

### Configure the Application

In `mix.exs`, bring in alice and any other handlers you want. You also need to
include the `websocket_client` dependency because it's not a [hex] package.

[hex]: http://hex.pm

```elixir
defp deps do
  [
    {:alice, "~> 0.4.2"},
    {:alice_against_humanity, "~> 0.1.0"},
    {:alice_google_images, "~> 0.1.0"}
  ]
end
```

In the same file, configure the app, registering any handlers you want. You can
add handlers through dependencies, or you can write them directly in your bot
instance. (See [Writing Route Handlers] for information on how to write a
handler. We recommend putting them in `lib/alice/handlers/`.)

[Writing Route Handlers]: https://github.com/alice-bot/alice#writing-route-handlers

```elixir
def application do
  [ applications: [:alice],
    mod: {
      Alice, %{
        handlers: [
          Alice.Handlers.Random,
          Alice.Handlers.AgainstHumanity,
          Alice.Handlers.GoogleImages
        ]
      }
    }
  ]
end
```

In `config/config.exs` add any configuration that your bot needs.
```elixir
use Mix.Config

config :alice,
  api_key: System.get_env("SLACK_API_TOKEN"),
  state_backend: :redis,
  redis: System.get_env("REDIS_URL")

config :alice_google_images,
  cse_id: System.get_env("GOOGLE_CSE_ID"),
  cse_token: System.get_env("GOOGLE_CSE_TOKEN"),
  safe_search_level: :medium
```

With that, you're done! Run your bot with `iex -S mix` or `mix run --no-halt`.

### Deploying to Heroku

Create a new heroku app running Elixir.
```sh
heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
```

Create a file called `elixir_buildpack.config` at the root of your project.
```sh
erlang_version=22.0.3
elixir_version=1.8.2
always_rebuild=false
```

Create a `Procfile` at the root of your project. If you don't create the proc
as a `worker`, Heroku will assume it's a web process and will terminate it for
not binding to port 80.
```ruby
worker: mix run --no-halt
```

You may also need to reconfigure Heroku to run the worker.
```sh
heroku ps:scale web=0 worker=1
```

Add your slack token and any other environment variables to Heroku
```sh
heroku config:set SLACK_API_TOKEN=xoxb-23486423876-HjgF354JHG7k567K4j56Gk3o
```

Push to Heroku
```sh
git add -A
git commit -m "initial commit"
git push heroku master
```

Your bot should be good to go. :metal:

## Creating a Route Handler Plugin

### First Steps

```sh
mix new alice_google_images
cd alice_google_images
rm lib/alice_google_images.ex test/alice_google_images_test.exs
mkdir -p lib/alice/handlers
mkdir -p test/alice/handlers
touch lib/alice/handlers/google_images.ex test/alice/handlers/google_images_test.exs
```

### Configuring the App

In `mix.exs`, update `application` and `deps` to look like the following:

```elixir
def application do
  [applications: []]
end

defp deps do
  [
    {:alice, "~> 0.4.2"}
  ]
end
```

### Writing Route Handlers

In `lib/alice/handlers/google_images.ex`:

```elixir
defmodule Alice.Handlers.GoogleImages do
  use Alice.Router

  command ~r/(image|img)\s+me (?<term>.+)/i, :fetch
  route ~r/(image|img)\s+me (?<term>.+)/i, :fetch

  @doc "`img me alice in wonderland` - gets a random image from Google Images"
  def fetch(conn) do
    conn
    |> Alice.Conn.last_capture
    |> get_images
    |> select_image
    |> reply(conn)
  end

  #...
end
```

### The Elixir Formatter and Alice

If you want the Elixir formatter to omit the parens on `command/2` and
`route/2`, simply [import] the alice config in your `.formatter.exs`:

[import]: https://hexdocs.pm/mix/master/Mix.Tasks.Format.html#module-importing-dependencies-configuration

```elixir
# my_handler/.formatter.exs
[
  # ...

  import_deps: [:alice]
]
```

### Testing Handlers

Alice provides several helpers to make it easy to test your handlers.  First
you'll need to invoke to add `use Alice.HandlerCase, handlers: [YourHandler]`
passing it the handler you're trying to test. Then you can use
`message_received()` within your test, which will simulate a message coming in
from the chat backend and route it through to the handlers appropriately.  If
you're wanting to invoke a command, you'll need to make sure your message
includes `<@alice>` within the string. From there you can use either
`first_reply()` to get the first reply sent out or `all_replies()` which will
return a List of replies that have been received during your test. You can use
either to use normal assertions on to ensure your handler behaves in the manner
you expect.

In `test/alice/handlers/google_images_test.exs`:

```elixir
defmodule Alice.Handlers.GoogleImagesTest do
  use Alice.HandlerCase, handlers: Alice.Handlers.GoogleImages

  test "it fetches an image when asked" do
    send_message("img me example image")

    assert first_reply() == "http://example.com/image_from_google.jpg"
  end
end
```

### Registering Handlers

In the `mix.exs` file of your bot, add your handler to the list of handlers to
register on start

```elixir
def application do
  [ applications: [:alice],
    mod: {Alice, [Alice.Handlers.GoogleImages, ...] } ]
end
```
