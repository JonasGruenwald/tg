import gleam/bit_array
import gleam/bytes_tree
import gleam/dynamic
import gleam/dynamic/decode
import gleam/http
import gleam/http/request.{type Request, Request}
import gleam/http/response
import gleam/json
import gleam/option
import gleam/result
import tg.{type Credentials, type TgError}

/// The response contains a JSON object, which always has a Boolean field 'ok' and may have an optional String field 'description' with a human-readable description of the result. 
/// If 'ok' equals True, the request was successful and the result of the query can be found in the 'result' field. In case of an unsuccessful request, 'ok' equals false and the error is explained in the 'description'.
pub type TelegramResponse {
  SuccessResponse(result: dynamic.Dynamic)
  ErrorResponse(description: String)
}

fn telegram_response_decoder() -> decode.Decoder(TelegramResponse) {
  use ok <- decode.field("ok", decode.bool)
  case ok {
    True -> {
      use result <- decode.field("result", decode.dynamic)
      decode.success(SuccessResponse(result:))
    }
    False -> {
      use description <- decode.field("description", decode.string)
      decode.success(ErrorResponse(description:))
    }
  }
}

pub fn request(
  credentials credentials: Credentials,
  method_name method_name: String,
  body body: json.Json,
) -> Request(bytes_tree.BytesTree) {
  let path = "/bot" <> credentials.token <> "/" <> method_name
  Request(
    method: http.Post,
    headers: [#("content-type", "application/json")],
    body: json.to_string_tree(body) |> bytes_tree.from_string_tree,
    scheme: credentials.api_server_scheme,
    host: credentials.api_server_host,
    port: credentials.api_server_port,
    path:,
    query: option.None,
  )
}

pub fn extract_payload(
  response: response.Response(BitArray),
) -> Result(dynamic.Dynamic, TgError) {
  use response_text <- result.try(
    bit_array.to_string(response.body)
    |> result.replace_error(tg.InvalidResponse(response, "utf-8 string")),
  )
  use telegram_response <- result.try(
    json.parse(response_text, telegram_response_decoder())
    |> result.map_error(fn(decoder_error) {
      tg.FailedToDecodeResponse(error: decoder_error)
    }),
  )
  case telegram_response {
    SuccessResponse(result:) -> Ok(result)
    ErrorResponse(description:) -> Error(tg.TelegramError(description:))
  }
}
