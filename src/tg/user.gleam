import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}

/// A telegram user or bot.
/// https://core.telegram.org/bots/api#user
pub type User {
  User(
    id: Int,
    is_bot: Bool,
    first_name: String,
    last_name: Option(String),
    username: Option(String),
  )
}

@internal
pub fn user_to_json(user: User) -> json.Json {
  let User(id:, is_bot:, first_name:, last_name:, username:) = user
  json.object([
    #("id", json.int(id)),
    #("is_bot", json.bool(is_bot)),
    #("first_name", json.string(first_name)),
    #("last_name", case last_name {
      option.None -> json.null()
      option.Some(value) -> json.string(value)
    }),
    #("username", case username {
      option.None -> json.null()
      option.Some(value) -> json.string(value)
    }),
  ])
}

@internal
pub fn user_decoder() -> decode.Decoder(User) {
  use id <- decode.field("id", decode.int)
  use is_bot <- decode.field("is_bot", decode.bool)
  use first_name <- decode.field("first_name", decode.string)
  use last_name <- decode.optional_field(
    "last_name",
    option.None,
    decode.optional(decode.string),
  )
  use username <- decode.optional_field(
    "username",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(User(id:, is_bot:, first_name:, last_name:, username:))
}
