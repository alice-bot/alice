## v0.4.3
  * Bugfix: Move HandlersCase to lib and rename to HandlerCase ([#131](https://github.com/alice-bot/alice/pull/131))
    - HandlerCase is actually in the package now and available for use.
  * Feature: adds release script ([#128](https://github.com/alice-bot/alice/pull/128))
  * Chore: updates coverage badge in readme ([#129](https://github.com/alice-bot/alice/pull/129))

## v0.4.2
  * Vastly Improves Testability of Handlers ([#111](https://github.com/alice-bot/alice/pull/111))
  * Includes formatter config in the package so that it can be imported in handlers ([#114](https://github.com/alice-bot/alice/pull/114))
  * Add Test Coverage via CircleCI and Coveralls.io ([#118](https://github.com/alice-bot/alice/pull/118))
  * Increases Test Coverage ([#120](https://github.com/alice-bot/alice/pull/120))
  * Readme updates including formatting and a typo fix ([#117](https://github.com/alice-bot/alice/pull/117))

## v0.4.1
  * Adds `tz_offset/1` and `timestamp/1` functions to `Alice.Conn` ([#109](https://github.com/alice-bot/alice/pull/109))

## v0.4.0
  * Fixes help handler for recent versions of elixir ([#98](https://github.com/alice-bot/alice/pull/98))
  * Minimum Elixir Version 1.7

## v0.3.7
  * Minimum Elixir Version: 1.5

## v0.3.6
  * Fixes warnings for Elixir 1.4-1.5 ([#81](https://github.com/alice-bot/alice/pull/81), [#84](https://github.com/alice-bot/alice/pull/84))
  * Updates Slack backend and websocket client ([#79](https://github.com/alice-bot/alice/pull/79))
  * Extract items from routing helpers ([#75](https://github.com/alice-bot/alice/pull/75), [#77](https://github.com/alice-bot/alice/pull/77))
  * Updates Redis handler to use JSON instead of memoized Elixir code ([#66](https://github.com/alice-bot/alice/pull/66))
  * Make application initialization take a struct ([#65](https://github.com/alice-bot/alice/pull/65))
  * Minimum Elixir Version: 1.2
