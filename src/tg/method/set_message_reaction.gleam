//// Use this method to change the chosen reactions on a message. 
//// Service messages of some types can't be reacted to.
////  Automatically forwarded messages from a channel to its discussion group have the same available reactions as messages in the channel. 
//// Bots can't use paid reactions. Returns True on success.

import tg/internal
import gleam/json
import tg

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
) {
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
