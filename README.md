# tg

[![Package Version](https://img.shields.io/hexpm/v/tg)](https://hex.pm/packages/tg)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/tg/)

A small sans-io Gleam library for the Telegram Bot API.

### Overview

The [Telegram Bot API](https://core.telegram.org/bots/api) has a pretty large API surface.
With this package, I want to provide minmal bindings to only the functionalities I personally have use for, and simplify the things I find difficult about the API.

This library uses the [sans-io pattern](https://gleam.run/documentation/conventions-patterns-and-anti-patterns/#The-sans-io-pattern), and does not depend on a particular HTTP client. It should work on both Erlang and JS.

### Examples

- [Polling for updates and reacting to messages](dev/watch_updates.gleam)

### Alternatives

If you are looking for a Telegram Bot SDK with a wider scope, consider the following alternatives:

- [`telega`](https://hexdocs.pm/telega/) – Telegram bot framework for Gleam, makes some assumptions about IO and depends on the Erlang target, has functionality to integrate with wisp, supports sessions, conversations etc.
- [`telegex`](https://hexdocs.pm/telegex/readme.html) – Telegram bot framework for Elixir, also very fully featured

If you just want to send short messages, I recommend making the request yourself, as the API is quite straightforward for that.

### Installation

```sh
gleam add tg@1
```

Further documentation can be found at <https://hexdocs.pm/tg>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
