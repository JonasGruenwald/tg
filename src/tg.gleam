import gleam/dynamic/decode
import gleam/http
import gleam/http/response
import gleam/json
import gleam/option.{type Option, None, Some}

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
  FailedToDecodePayload(errors: List(decode.DecodeError))
  TelegramError(description: String)
}
