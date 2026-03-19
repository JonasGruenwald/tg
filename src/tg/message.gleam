import gleam/option.{type Option}

pub type User {
  User(id: String, first_name: String)
}

type MessageEntity {
  Mention
  Hashtag
  Cashtag
  BotCommand
  Url
  Email
  PhoneNumber
  Bold
  Italic
  Underline
  Strikethrough
  Spoiler
  Blockquote
  ExpandableBlockQuote
  Code
  Pre(language: Option(String))
  TextLink(url: String)
  TextMention(user: User)
  CustomEmoji(id: String)
  DateTime(unix_time: Int, format: String)
}

pub opaque type Element {
  ElementNode(entity: MessageEntity, children: List(Element))
  ElementLeaf(text: String)
}

pub fn text(input: String) {
  ElementLeaf(input)
}

pub fn mention(children: List(Element)) {
  ElementNode(entity: Mention, children:)
}

pub fn hashtag(children: List(Element)) {
  ElementNode(entity: Hashtag, children:)
}

pub fn cashtag(children: List(Element)) {
  ElementNode(entity: Cashtag, children:)
}

pub fn bot_command(children: List(Element)) {
  ElementNode(entity: BotCommand, children:)
}

pub fn url(children: List(Element)) {
  ElementNode(entity: Url, children:)
}

pub fn email(children: List(Element)) {
  ElementNode(entity: Email, children:)
}

pub fn phone_number(children: List(Element)) {
  ElementNode(entity: PhoneNumber, children:)
}

pub fn bold(children: List(Element)) {
  ElementNode(entity: Bold, children:)
}

pub fn italic(children: List(Element)) {
  ElementNode(entity: Italic, children:)
}

pub fn underline(children: List(Element)) {
  ElementNode(entity: Underline, children:)
}

pub fn strikethrough(children: List(Element)) {
  ElementNode(entity: Strikethrough, children:)
}

pub fn spoiler(children: List(Element)) {
  ElementNode(entity: Spoiler, children:)
}

pub fn blockquote(children: List(Element)) {
  ElementNode(entity: Blockquote, children:)
}

pub fn expandable_blockquote(children: List(Element)) {
  ElementNode(entity: ExpandableBlockQuote, children:)
}

pub fn code(children: List(Element)) {
  ElementNode(entity: Code, children:)
}

pub fn pre(language: Option(String), children: List(Element)) {
  ElementNode(entity: Pre(language:), children:)
}

pub fn text_link(url url: String, children children: List(Element)) {
  ElementNode(entity: TextLink(url:), children:)
}

pub fn text_mention(user user: User, children children: List(Element)) {
  ElementNode(entity: TextMention(user:), children:)
}

pub fn custom_emoji(id id: String, children children: List(Element)) {
  ElementNode(entity: CustomEmoji(id:), children:)
}

pub fn date_time(
  unix_time unix_time: Int,
  format format: String,
  children children: List(Element),
) {
  ElementNode(entity: DateTime(unix_time:, format:), children:)
}

pub opaque type ResolvedMessageEntity {
  ResolvedMessageEntity(
    utf_16_offset: Int,
    utf_16_length: Int,
    entity: MessageEntity,
  )
}

pub opaque type Message {
  Message(text: String, entities: List(ResolvedMessageEntity))
}

/// Takes in the desired content for a message, and turns it into sendable
/// message items, split based on telegram's message length limit,
/// with message entities attached.
/// 
pub fn compose(elements: List(Element)) -> List(Message) {
  todo as "flattend the tree of elements"
  todo as "turn flat list into messages"
}

type Chunk

fn element_tree_to_chunks(element: List(Element)) {
  todo
}

/// What we must do:
/// 
/// - We need to split messages based on Telegram's character limit which is specified as 4,096 UTF-8 **characters**.
/// - We need to calculate the offset and length of message entities which are specified in UTF-16 **code units**.
/// 
/// This happens here in a single recursive walk of the input text graphemes.
/// We walk the grapheme list instead of the text, because when splitting, we don't want to split in the middle of 
/// a grapheme.
/// 
/// What we must consider:
///
/// - Splitting some entities across messages is completely fine, bold and italic for example can just restart in the next message
/// - Splitting other entities should be avoided at all cost, for example a username tag or URL will break when split
fn do_compose(
  remaining_graphemes: List(String),
  text_buffer: String,
  entity_buffer: List(ResolvedMessageEntity),
  message_length_characters: Int,
  message_accumulator: List(Message),
) -> List(Message) {
  todo
}

pub fn to_request(message: Message) {
  todo
}
