import envoy
import gleam/bytes_tree
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import simplifile
import tg
import tg/method/get_file
import tg/method/get_updates
import tg/update

pub fn main() {
  let assert Ok(token) = envoy.get("BOT_TOKEN")
  io.println("Hello! I'll fetch my updates and download any photo messages.")
  let _ = simplifile.create_directory("photos")
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

  let assert Ok(updates) = get_updates.response(response)

  // Download the images from each photo message
  list.each(updates, fn(update) {
    case update {
      update.IncomingMessage(
        message: update.PhotoMessage(
          photo: photo,
          caption: caption,
          from: from,
          ..,
        ),
        ..,
      ) -> {
        let caption = option.unwrap(caption, "No caption")
        io.println(
          "User "
          <> from.first_name
          <> " sent me an image, caption: "
          <> caption,
        )
        let assert Ok(biggest_size) =
          list.sort(photo, fn(size_a, size_b) {
            int.compare(size_b.width, size_a.width)
          })
          |> list.first()

        let assert Ok(file_response) =
          get_file.build_request(file_id: biggest_size.file_id, credentials:)
          |> request.map(bytes_tree.to_bit_array)
          |> httpc.send_bits

        let assert Ok(file) = get_file.response(file_response)

        io.println("Now downloading the file to " <> file.file_path)

        let assert Ok(file_contents) =
          get_file.build_download_request(file:, credentials:)
          |> httpc.send_bits

        // `file_path` is a path that looks like `photos/wobble.jpg`.
        // we created the 'photos' directory on our local file system at the start
        // so we can just write the file there directly
        let assert Ok(_) =
          simplifile.write_bits(file.file_path, file_contents.body)

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
