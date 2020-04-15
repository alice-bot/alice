# Alice Installer

Provides `alice.new.handler` generator as an archive.

To install from hex, run:

    $ mix archive.install hex alice_new 0.4.3

To build and install it locally, ensure any previous archive versions are
removed:

    $ mix archive.uninstall alice_new

Then run:

    $ cd alice_new
    $ MIX_ENV=prod mix do archive.build, archive.install
