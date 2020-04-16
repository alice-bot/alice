# Alice Installer

Provides `alice.new.handler` generator as an archive. This is the easiest way to
set up a new Alice handler.

## Install The Alice Installer

To install from hex, run:

```bash
$ mix archive.install hex alice_new
```

To build and install it locally, ensure any previous archive versions are
removed:

```bash
$ mix archive.uninstall alice_new
```

Then run:

```bash
$ cd alice/installer
$ MIX_ENV=prod mix do archive.build, archive.install
```

## Build a Handler

First, navigate the command-line to the directory where you want to create
your new Alice handler. Then run the following commands: (change `my_handler`
to the name of your handler)

```bash
mix alice.new.handler my_handler
cd alice_my_handler
mix deps.get
```

You can also provide a path to the handler as well as some additional
options:

```bash
mix alice.new.handler path/to/my_handler \
  --name a_different_otp_name \
  --module DifferentHandlerModuleName
```

This will set the OTP `app_name` to `a_different_otp_name` and set the
handler module name to `DifferentHandlerModuleName`

## Next Steps

See the [docs](https://hexdocs.pm/alice) for more info on writing route
handlers, testing your handler routes and commands, and registerring your
handler in an Alice bot.
