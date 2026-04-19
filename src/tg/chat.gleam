import gleam/dynamic/decode
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string

/// A chat
/// https://core.telegram.org/bots/api#chat
pub type Chat {
  Private(
    id: Int,
    username: Option(String),
    first_name: Option(String),
    last_name: Option(String),
  )
  Group(id: Int, title: Option(String))
  Supergroup(
    id: Int,
    title: Option(String),
    username: Option(String),
    is_forum: Bool,
  )
  Channel(id: Int, title: Option(String), username: Option(String))
}

@internal
pub fn chat_decoder() -> decode.Decoder(Chat) {
  use variant <- decode.field("type", decode.string)
  case variant {
    "private" -> {
      use id <- decode.field("id", decode.int)
      use username <- decode.optional_field(
        "username",
        option.None,
        decode.optional(decode.string),
      )
      use first_name <- decode.optional_field(
        "first_name",
        option.None,
        decode.optional(decode.string),
      )
      use last_name <- decode.optional_field(
        "last_name",
        option.None,
        decode.optional(decode.string),
      )
      decode.success(Private(id:, username:, first_name:, last_name:))
    }
    "group" -> {
      use id <- decode.field("id", decode.int)
      use title <- decode.optional_field(
        "title",
        option.None,
        decode.optional(decode.string),
      )
      decode.success(Group(id:, title:))
    }
    "supergroup" -> {
      use id <- decode.field("id", decode.int)
      use title <- decode.optional_field(
        "title",
        option.None,
        decode.optional(decode.string),
      )
      use username <- decode.optional_field(
        "username",
        option.None,
        decode.optional(decode.string),
      )
      use is_forum <- decode.optional_field("is_forum", False, decode.bool)
      decode.success(Supergroup(id:, title:, username:, is_forum:))
    }
    "channel" -> {
      use id <- decode.field("id", decode.int)
      use title <- decode.optional_field(
        "title",
        option.None,
        decode.optional(decode.string),
      )
      use username <- decode.optional_field(
        "username",
        option.None,
        decode.optional(decode.string),
      )
      decode.success(Channel(id:, title:, username:))
    }
    _ -> decode.failure(Group(0, option.None), "Chat")
  }
}

/// Turn a chat into a human readable string for debugging
pub fn describe(chat: Chat) {
  case chat {
    Private(id:, username:, first_name:, last_name:) ->
      "Private Chat: "
      <> case first_name {
        Some(first_name) -> " " <> first_name
        None -> ""
      }
      <> case last_name {
        Some(last_name) -> " " <> last_name
        None -> ""
      }
      <> {
        case username {
          Some(user) -> " @" <> user
          None -> ""
        }
      }
      <> " (Id: "
      <> int.to_string(id)
      <> ")"
    Group(id:, title:) ->
      "Group Chat: "
      <> option.unwrap(title, "<Unnamed>")
      <> " (Id: "
      <> int.to_string(id)
      <> ")"
    Supergroup(id:, title:, username:, is_forum:) ->
      "Supergroup: "
      <> option.unwrap(title, "<Unnamed>")
      <> {
        case username {
          Some(username) -> " @" <> username
          None -> ""
        }
      }
      <> {
        case is_forum {
          True -> " FORUM"
          False -> ""
        }
      }
      <> " (Id: "
      <> int.to_string(id)
      <> ")"
    Channel(id:, title:, username:) ->
      "Channel: "
      <> option.unwrap(title, "<Unnamed>")
      <> {
        case username {
          Some(username) -> " @" <> username
          None -> ""
        }
      }
      <> " (Id: "
      <> int.to_string(id)
      <> ")"
  }
}
