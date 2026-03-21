import gleam/dynamic
import gleam/dynamic/decode
import gleam/http
import gleam/http/response
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

// ------------------------------ CONFIGURATION -----------------------------------------

const default_api_server_scheme = http.Https

const default_api_server_host = "api.telegram.org"

const default_api_server_port = None

/// The credentials used to authenticated with the telegram API
pub type Credentials {
  Credentials(
    token: String,
    api_server_scheme: http.Scheme,
    api_server_host: String,
    api_server_port: Option(Int),
  )
}

/// Create the credentials to authenticate your bot with.
/// Each bot is given a token after [it is created](https://core.telegram.org/bots/features#botfather).
pub fn credentials(token token: String) {
  Credentials(
    token:,
    api_server_scheme: default_api_server_scheme,
    api_server_host: default_api_server_host,
    api_server_port: default_api_server_port,
  )
}

/// Set the bot API server host – use this if you're [running a local bot API server](https://core.telegram.org/bots/api#using-a-local-bot-api-server).
pub fn with_api_server_host(
  credentials credentials: Credentials,
  host host: String,
) {
  Credentials(..credentials, api_server_host: host)
}

pub fn with_api_server_scheme(
  credentials credentials: Credentials,
  scheme scheme: http.Scheme,
) {
  Credentials(..credentials, api_server_scheme: scheme)
}

pub fn with_api_server_port(
  credentials credentials: Credentials,
  port port: Int,
) {
  Credentials(..credentials, api_server_port: Some(port))
}

// ------------------------------ ERRORS ------------------------------------------------

pub type TgError {
  InvalidResponse(response: response.Response(BitArray), expected: String)
  FailedToDecodeResponse(error: json.DecodeError)
  FailedToDecodePayload(
    errors: List(decode.DecodeError),
    payload: dynamic.Dynamic,
  )
  TelegramError(description: String)
}

pub fn describe_error(error: TgError) -> String {
  case error {
    InvalidResponse(response: _, expected:) ->
      "Invalid response, expected: " <> expected
    FailedToDecodeResponse(error:) -> describe_json_decode_error(error)
    FailedToDecodePayload(errors:, payload: _) ->
      "Failed to decode payload, errors: " <> describe_decode_errors(errors)
    TelegramError(description:) -> "Teelgram Error: " <> description
  }
}

fn describe_decode_errors(errors: List(decode.DecodeError)) -> String {
  list.map(errors, fn(issue) {
    issue.path |> string.join("->")
    <> " expected: "
    <> issue.expected
    <> " found: "
    <> issue.found
  })
  |> string.join(", ")
}

fn describe_json_decode_error(error: json.DecodeError) {
  case error {
    json.UnexpectedEndOfInput -> "Unexpected end of input"
    json.UnexpectedByte(byte) -> "Unexpected byte: " <> byte
    json.UnexpectedSequence(sequence) -> "Unexptected sequence: " <> sequence
    json.UnableToDecode(errors) ->
      "Unable to decode, issues: " <> describe_decode_errors(errors)
  }
}
