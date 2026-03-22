import birdie
import gleam/bit_array
import gleam/http/response
import gleeunit
import pprint
import simplifile
import tg/method/get_updates

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
  birdie.snap(pprint.format(updates), "Parsed Updates")
}
