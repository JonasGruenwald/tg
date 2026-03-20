import envoy
import gleam/bytes_tree
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/list
import pprint
import tg
import tg/get_updates

pub fn main() {
  let assert Ok(token) = envoy.get("BOT_TOKEN")
  io.println("Hello! I'll fetch my updates and print them.")
  let credentials = tg.credentials(token)

  poll(credentials, 0)
}

fn poll(credentials: tg.Credentials, offset: Int) {
  io.println("Hello! I'll poll my updates and print them.")
  io.println("Fetching updates with offset: " <> int.to_string(offset))
  let assert Ok(response) =
    get_updates.request()
    |> get_updates.timeout(10)
    |> get_updates.offset(offset)
    |> get_updates.limit(100)
    |> get_updates.build(credentials)
    |> echo
    |> request.map(bytes_tree.to_bit_array)
    |> httpc.send_bits

  let assert Ok(updates) = get_updates.response(response)

  io.println(pprint.format(updates))

  let last_update =
    list.sort(updates, fn(update_a, update_b) {
      int.compare(update_a.update_id, update_b.update_id)
    })
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
