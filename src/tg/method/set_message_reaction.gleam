//// Use this method to change the chosen reactions on a message. 
//// Service messages of some types can't be reacted to.
////  Automatically forwarded messages from a channel to its discussion group have the same available reactions as messages in the channel. 
//// Bots can't use paid reactions. Returns True on success.

import gleam/http/request
import gleam/bytes_tree
import gleam/dynamic/decode
import gleam/http/response
import gleam/json
import gleam/result
import tg
import tg/internal

/// Currently supported emojis:
///  "❤", "👍", "👎", "🔥", "🥰", "👏", "😁", "🤔", "🤯", "😱", "🤬", "😢", "🎉", "🤩",
///  "🤮", "💩", "🙏", "👌", "🕊", "🤡", "🥱", "🥴", "😍", "🐳", "❤‍🔥", "🌚", "🌭", "💯",
///  "🤣", "⚡", "🍌", "🏆", "💔", "🤨", "😐", "🍓", "🍾", "💋", "🖕", "😈", "😴", "😭",
///  "🤓", "👻", "👨‍💻", "👀", "🎃", "🙈", "😇", "😨", "🤝", "✍", "🤗", "🫡", "🎅", "🎄",
///  "☃", "💅", "🤪", "🗿", "🆒", "💘", "🙉", "🦄", "😘", "💊", "🙊", "😎", "👾", "🤷‍♂",
///  "🤷", "🤷‍♀", "😡"
/// See: https://core.telegram.org/bots/api#reactiontype
pub fn build_request(
  chat_id chat_id: Int,
  message_id message_id: Int,
  emoji emoji_reaction: String,
  credentials credentials: tg.Credentials,
) -> request.Request(bytes_tree.BytesTree) {
  let payload =
    json.object([
      #("chat_id", json.int(chat_id)),
      #("message_id", json.int(message_id)),
      #(
        "reaction",
        json.preprocessed_array([
          json.object([
            #("type", json.string("emoji")),
            #("emoji", json.string(emoji_reaction)),
          ]),
        ]),
      ),
    ])
  internal.request(credentials, "setMessageReaction", payload)
}

pub fn response(
  response: response.Response(BitArray),
) -> Result(Bool, tg.TgError) {
  use payload <- result.try(internal.extract_payload(response))

  decode.run(payload, decode.bool)
  |> result.map_error(fn(errors) { tg.FailedToDecodePayload(errors, payload:) })
}
