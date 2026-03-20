//// Build a request to receive incoming updates using long polling.  
//// https://core.telegram.org/bots/api#getupdates

import gleam/bytes_tree
import gleam/dynamic/decode
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import tg.{type Credentials, type TgError}
import tg/internal
import tg/update.{type Update}

/// The update types currently supported by the `update_decoder` in the `update` module.
pub const supported_updates: List(String) = [
  "message",
  "edited_message",
  "callback_query",
]

pub type GetUpdatesRequestBuilder {
  GetUpdatesRequestBuilder(
    offset: Int,
    limit: Int,
    timeout: Int,
    allowed_updates: List(String),
  )
}

fn get_updates_request_builder_to_json(
  get_updates_request_builder: GetUpdatesRequestBuilder,
) -> json.Json {
  let GetUpdatesRequestBuilder(offset:, limit:, timeout:, allowed_updates:) =
    get_updates_request_builder
  json.object([
    #("offset", json.int(offset)),
    #("limit", json.int(limit)),
    #("timeout", json.int(timeout)),
    #("allowed_updates", json.array(allowed_updates, json.string)),
  ])
}

/// By default, no timeout is set (short polling), this should only be done
/// for testing purposes – please set a timeout using `timeout` otherwise.
pub fn request() -> GetUpdatesRequestBuilder {
  GetUpdatesRequestBuilder(
    offset: 0,
    limit: 100,
    timeout: 0,
    allowed_updates: supported_updates,
  )
}

/// Identifier of the first update to be returned. Must be greater by one than the highest among the identifiers of previously received updates.\
/// By default, updates starting with the earliest unconfirmed update are returned. 
/// An update is considered confirmed as soon as getUpdates is called with an offset higher than its update_id. 
/// The negative offset can be specified to retrieve updates starting from -offset update from the end of the updates queue. 
/// All previous updates will be forgotten.
pub fn offset(
  builder: GetUpdatesRequestBuilder,
  offset: Int,
) -> GetUpdatesRequestBuilder {
  GetUpdatesRequestBuilder(..builder, offset:)
}

/// Limits the number of updates to be retrieved. Values between 1-100 are accepted. Defaults to 100.
pub fn limit(
  builder: GetUpdatesRequestBuilder,
  limit: Int,
) -> GetUpdatesRequestBuilder {
  GetUpdatesRequestBuilder(..builder, limit:)
}

/// Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling. 
/// Should be positive, short polling should be used for testing purposes only.
pub fn timeout(
  builder: GetUpdatesRequestBuilder,
  timeout: Int,
) -> GetUpdatesRequestBuilder {
  GetUpdatesRequestBuilder(..builder, timeout:)
}

/// Set the updates you want to receive. By default, this is the `supported_updates` list.
pub fn allowed_updates(
  builder: GetUpdatesRequestBuilder,
  timeout: Int,
) -> GetUpdatesRequestBuilder {
  GetUpdatesRequestBuilder(..builder, timeout:)
}

pub fn build(
  builder: GetUpdatesRequestBuilder,
  credentials: Credentials,
) -> request.Request(bytes_tree.BytesTree) {
  internal.request(
    credentials,
    "getUpdates",
    get_updates_request_builder_to_json(builder),
  )
}

pub fn response(
  response: response.Response(BitArray),
) -> Result(List(Update), TgError) {
  use payload <- result.try(internal.extract_payload(response))

  decode.run(payload, decode.list(update.update_decoder()))
  |> result.map_error(fn(errors) { tg.FailedToDecodePayload(errors, payload:) })
}
