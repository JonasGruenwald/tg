import birdie
import gleam/bit_array
import gleam/http/response
import gleam/list
import gleam/string
import gleeunit
import simplifile
import tg/method/get_updates
import tg/update

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn get_updates_response_test() {
  let assert Ok(content) = simplifile.read("test/update_payload.json")
  let response =
    response.new(200)
    |> response.set_body(content)
    |> response.map(bit_array.from_string)

  let assert Ok(updates) = get_updates.response(response)
  let pretty_updates =
    list.map(updates, update.describe)
    |> string.join("\n----------------------------------------------\n")
  birdie.snap(pretty_updates, "Parsed Updates")
}
