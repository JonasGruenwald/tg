# tg

[![Package Version](https://img.shields.io/hexpm/v/tg)](https://hex.pm/packages/tg)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/tg/)

A small sans-io Gleam library for the Telegram Bot API.

### Goal and Alternatives

The [Telegram Bot API](https://core.telegram.org/bots/api) has a massive API surface. 
With this package I want to provide minmal bindings a tiny fraction of that, only the functionalities I personally have use for.

This library uses the [sans-io pattern](https://gleam.run/documentation/conventions-patterns-and-anti-patterns/#The-sans-io-pattern), and does not depend on a particular HTTP client. It should work on both Erlang and JS.

Consider the following alternatives:

- [`telega`](https://hexdocs.pm/telega/) –  Telegram bot framework for Gleam, makes some assumptions about IO and depends on the Erlang target
- [`telegex`](https://hexdocs.pm/telegex/readme.html) – Telegram bot framework for Elixir
- Just write the requests you need yourself (the Telegram bot API is very simple)

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
