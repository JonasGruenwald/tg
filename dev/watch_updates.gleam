import envoy
import gleam/bytes_tree
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import tg
import tg/method/get_updates
import tg/method/set_message_reaction
import tg/update

pub fn main() {
  let assert Ok(token) = envoy.get("BOT_TOKEN")
  io.println("Hello! I'll fetch my updates and print them.")
  let credentials = tg.credentials(token)

  poll(credentials, 0)
}

fn poll(credentials: tg.Credentials, offset: Int) {
  io.println("Fetching updates with offset: " <> int.to_string(offset))
  let assert Ok(response) =
    get_updates.request()
    |> get_updates.timeout(10)
    |> get_updates.offset(offset)
    |> get_updates.limit(100)
    |> get_updates.build(credentials)
    |> request.map(bytes_tree.to_bit_array)
    |> httpc.send_bits

  // Print updates
  let assert Ok(updates) = get_updates.response(response)
  io.println(list.map(updates, update.describe) |> string.join("\n"))

  // React with 👀 to each seen message
  list.each(updates, fn(update) {
    case update {
      update.IncomingMessage(message: message, ..) -> {
        let assert Ok(_) =
          set_message_reaction.build_request(
            chat_id: message.chat.id,
            message_id: message.message_id,
            emoji: "👀",
            credentials: credentials,
          )
          |> request.map(bytes_tree.to_bit_array)
          |> httpc.send_bits
        Nil
      }
      _ -> Nil
    }
  })

  // Continue polling
  let last_update =
    updates
    |> list.reverse
    |> list.first

  case last_update {
    Ok(update) -> poll(credentials, update.update_id + 1)
    Error(_) -> {
      io.println("No updates returned!")
      poll(credentials, offset)
    }
  }
}
