import gleam/dynamic
import gleam/dynamic/decode
import gleam/option.{type Option, None, Some}
import tg/chat.{type Chat}
import tg/user.{type User}

/// An update event from the Telegram API.
/// https://core.telegram.org/bots/api#update
pub type Update {
  IncomingMessage(update_id: Int, message: Message)
  EditedMessage(update_id: Int, message: Message)
  CallbackQuery(update_id: Int, id: String, from: User, data: String)
  // For future channel support: Let's maybe define a separate ChannelMessage type
  // since there is no user field
  // ChannelPost(chat: Chat, message: ChannelMessage)
  // EditedChannelPost(chat: Chat, message: ChannelMessage)
}

pub fn update_decoder() -> decode.Decoder(Update) {
  use update_id <- decode.field("update_id", decode.int)
  decode.one_of(message_update_decoder(update_id), [
    edited_message_update_decoder(update_id),
    callback_query_update_decoder(update_id),
  ])
}

fn message_update_decoder(update_id: Int) {
  use message <- decode.field("message", message_decoder())
  decode.success(IncomingMessage(update_id:, message:))
}

fn edited_message_update_decoder(update_id: Int) {
  use message <- decode.field("edited_message", message_decoder())
  decode.success(EditedMessage(update_id:, message:))
}

fn callback_query_update_decoder(update_id: Int) {
  use id <- decode.subfield(["callback_query", "id"], decode.string)
  use data <- decode.subfield(["callback_query", "data"], decode.string)
  use from <- decode.subfield(["callback_query", "from"], user.user_decoder())
  decode.success(CallbackQuery(update_id:, id:, data:, from:))
}

pub type Message {
  TextMessage(message_id: Int, date: Int, from: User, chat: Chat, text: String)
  PhotoMessage(
    message_id: Int,
    date: Int,
    from: User,
    chat: Chat,
    caption: Option(String),
    photo: List(PhotoSize),
  )
  DocumentMessage(
    message_id: Int,
    date: Int,
    from: User,
    chat: Chat,
    caption: Option(String),
    document: Document,
  )
  VideoMessage(
    message_id: Int,
    date: Int,
    from: User,
    chat: Chat,
    caption: Option(String),
    video: Video,
  )
  AudioMessage(
    message_id: Int,
    date: Int,
    from: User,
    chat: Chat,
    caption: Option(String),
    audio: Audio,
  )
  VideoNoteMessage(
    message_id: Int,
    date: Int,
    from: User,
    chat: Chat,
    video_note: VideoNote,
  )
  VoiceMessage(
    message_id: Int,
    date: Int,
    from: User,
    chat: Chat,
    caption: Option(String),
    voice: Voice,
  )
  StickerMessage(
    message_id: Int,
    date: Int,
    from: User,
    chat: Chat,
    file_id: String,
    file_unique_id: String,
  )
  /// The telegram API has further message types that may occur in a chat,
  /// which this library currently does not support.
  /// This fallback type is provided so that the update decoder does not fail on 
  /// a valid message, which is not supported at this time.
  UnsupportedMessage(
    message_id: Int,
    date: Int,
    from: User,
    chat: Chat,
    payload: dynamic.Dynamic,
  )
}

fn message_decoder() -> decode.Decoder(Message) {
  use message_id <- decode.field("message_id", decode.int)
  use chat <- decode.field("chat", chat.chat_decoder())
  use from <- decode.field("from", user.user_decoder())
  use date <- decode.field("date", decode.int)

  decode.one_of(text_message_decoder(message_id, date, from, chat), [
    photo_message_decoder(message_id, date, from, chat),
    document_message_decoder(message_id, date, from, chat),
    video_message_decoder(message_id, date, from, chat),
    audio_message_decoder(message_id, date, from, chat),
    video_note_message_decoder(message_id, date, from, chat),
    voice_message_decoder(message_id, date, from, chat),
    sticker_message_decoder(message_id, date, from, chat),
    fallback_message_decoder(message_id, date, from, chat),
  ])
}

fn text_message_decoder(
  message_id: Int,
  date: Int,
  from: User,
  chat: Chat,
) -> decode.Decoder(Message) {
  use text <- decode.field("text", decode.string)
  decode.success(TextMessage(message_id:, date:, from:, chat:, text:))
}

fn photo_message_decoder(
  message_id: Int,
  date: Int,
  from: User,
  chat: Chat,
) -> decode.Decoder(Message) {
  use photo <- decode.field("photo", decode.list(photo_size_decoder()))
  use caption <- decode.optional_field(
    "caption",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(PhotoMessage(
    message_id:,
    date:,
    from:,
    chat:,
    caption:,
    photo:,
  ))
}

fn document_message_decoder(
  message_id: Int,
  date: Int,
  from: User,
  chat: Chat,
) -> decode.Decoder(Message) {
  use document <- decode.field("document", document_decoder())
  use caption <- decode.optional_field(
    "caption",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DocumentMessage(
    message_id:,
    date:,
    from:,
    chat:,
    document:,
    caption:,
  ))
}

fn video_message_decoder(
  message_id: Int,
  date: Int,
  from: User,
  chat: Chat,
) -> decode.Decoder(Message) {
  use video <- decode.field("video", video_decoder())
  use caption <- decode.optional_field(
    "caption",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(VideoMessage(
    message_id:,
    date:,
    from:,
    chat:,
    caption:,
    video:,
  ))
}

fn audio_message_decoder(
  message_id: Int,
  date: Int,
  from: User,
  chat: Chat,
) -> decode.Decoder(Message) {
  use audio <- decode.field("audio", audio_decoder())
  use caption <- decode.optional_field(
    "caption",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(AudioMessage(
    message_id:,
    date:,
    from:,
    chat:,
    caption:,
    audio:,
  ))
}

fn video_note_message_decoder(
  message_id: Int,
  date: Int,
  from: User,
  chat: Chat,
) -> decode.Decoder(Message) {
  use video_note <- decode.field("video_note", video_note_decoder())
  decode.success(VideoNoteMessage(message_id:, date:, from:, chat:, video_note:))
}

fn voice_message_decoder(
  message_id: Int,
  date: Int,
  from: User,
  chat: Chat,
) -> decode.Decoder(Message) {
  use voice <- decode.field("voice", voice_decoder())
  use caption <- decode.optional_field(
    "caption",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(VoiceMessage(
    message_id:,
    date:,
    from:,
    chat:,
    caption:,
    voice:,
  ))
}

fn sticker_message_decoder(
  message_id: Int,
  date: Int,
  from: User,
  chat: Chat,
) -> decode.Decoder(Message) {
  use file_id <- decode.subfield(["sticker", "file_id"], decode.string)
  use file_unique_id <- decode.subfield(
    ["sticker", "file_unique_id"],
    decode.string,
  )
  decode.success(StickerMessage(
    message_id:,
    date:,
    from:,
    chat:,
    file_id:,
    file_unique_id:,
  ))
}

fn fallback_message_decoder(message_id: Int, date: Int, from: User, chat: Chat) {
  use payload <- decode.then(decode.dynamic)
  decode.success(UnsupportedMessage(message_id:, date:, from:, chat:, payload:))
}

/// A video file
/// https://core.telegram.org/bots/api#video
pub type Video {
  Video(
    file_id: String,
    file_unique_id: String,
    width: Int,
    height: Int,
    duration: Int,
    file_size: Option(Int),
  )
}

fn video_decoder() -> decode.Decoder(Video) {
  use file_id <- decode.field("file_id", decode.string)
  use file_unique_id <- decode.field("file_unique_id", decode.string)
  use width <- decode.field("width", decode.int)
  use height <- decode.field("height", decode.int)
  use duration <- decode.field("duration", decode.int)
  use file_size <- decode.field("file_size", decode.optional(decode.int))
  decode.success(Video(
    file_id:,
    file_unique_id:,
    width:,
    height:,
    duration:,
    file_size:,
  ))
}

/// A video note
/// https://core.telegram.org/bots/api#videonote
pub type VideoNote {
  VideoNote(
    file_id: String,
    file_unique_id: String,
    length: Int,
    duration: Int,
    file_size: Option(Int),
  )
}

fn video_note_decoder() -> decode.Decoder(VideoNote) {
  use file_id <- decode.field("file_id", decode.string)
  use file_unique_id <- decode.field("file_unique_id", decode.string)
  use length <- decode.field("length", decode.int)
  use duration <- decode.field("duration", decode.int)
  use file_size <- decode.field("file_size", decode.optional(decode.int))
  decode.success(VideoNote(
    file_id:,
    file_unique_id:,
    length:,
    duration:,
    file_size:,
  ))
}

/// A voice note
/// https://core.telegram.org/bots/api#voice
pub type Voice {
  Voice(
    file_id: String,
    file_unique_id: String,
    duration: Int,
    file_size: Option(Int),
  )
}

fn voice_decoder() -> decode.Decoder(Voice) {
  use file_id <- decode.field("file_id", decode.string)
  use file_unique_id <- decode.field("file_unique_id", decode.string)
  use duration <- decode.field("duration", decode.int)
  use file_size <- decode.field("file_size", decode.optional(decode.int))
  decode.success(Voice(file_id:, file_unique_id:, duration:, file_size:))
}

/// An audio message
/// https://core.telegram.org/bots/api#audio
pub type Audio {
  Audio(
    file_id: String,
    file_unique_id: String,
    duration: Int,
    file_name: Option(String),
    file_size: Option(String),
    mime_type: Option(String),
  )
}

fn audio_decoder() -> decode.Decoder(Audio) {
  use file_id <- decode.field("file_id", decode.string)
  use file_unique_id <- decode.field("file_unique_id", decode.string)
  use duration <- decode.field("duration", decode.int)
  use file_name <- decode.field("file_name", decode.optional(decode.string))
  use file_size <- decode.field("file_size", decode.optional(decode.string))
  use mime_type <- decode.field("mime_type", decode.optional(decode.string))
  decode.success(Audio(
    file_id:,
    file_unique_id:,
    duration:,
    file_name:,
    file_size:,
    mime_type:,
  ))
}

/// Size of a photo
/// https://core.telegram.org/bots/api#photosize
pub type PhotoSize {
  PhotoSize(
    file_id: String,
    file_unique_id: String,
    width: Int,
    height: Int,
    file_size: Option(Int),
  )
}

fn photo_size_decoder() -> decode.Decoder(PhotoSize) {
  use file_id <- decode.field("file_id", decode.string)
  use file_unique_id <- decode.field("file_unique_id", decode.string)
  use width <- decode.field("width", decode.int)
  use height <- decode.field("height", decode.int)
  use file_size <- decode.field("file_size", decode.optional(decode.int))
  decode.success(PhotoSize(
    file_id:,
    file_unique_id:,
    width:,
    height:,
    file_size:,
  ))
}

/// General file (not photo, voice or audio)
/// https://core.telegram.org/bots/api#document
pub type Document {
  Document(
    file_id: String,
    file_unique_id: String,
    file_name: Option(String),
    file_size: Option(String),
    mime_type: Option(String),
  )
}

fn document_decoder() -> decode.Decoder(Document) {
  use file_id <- decode.field("file_id", decode.string)
  use file_unique_id <- decode.field("file_unique_id", decode.string)
  use file_name <- decode.field("file_name", decode.optional(decode.string))
  use file_size <- decode.field("file_size", decode.optional(decode.string))
  use mime_type <- decode.field("mime_type", decode.optional(decode.string))
  decode.success(Document(
    file_id:,
    file_unique_id:,
    file_name:,
    file_size:,
    mime_type:,
  ))
}
