//// Use this method to get basic information about a file and prepare it for downloading. 
//// For the moment, bots can download files of up to 20MB in size. 
//// On success, a `File` is returned, which can then be downloaded using `build_download_request`.
//// It is guaranteed that the download link will be valid for at least 1 hour. 
//// When the link expires, a new one can be requested by calling getFile again.
//// 
//// https://core.telegram.org/bots/api#getfile

import gleam/bytes_tree
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/option
import gleam/result
import tg
import tg/file
import tg/internal

pub fn build_request(
  file_id file_id: String,
  credentials credentials: tg.Credentials,
) -> request.Request(bytes_tree.BytesTree) {
  let payload = json.object([#("file_id", json.string(file_id))])
  internal.request(credentials, "getFile", payload)
}

pub fn build_download_request(
  file file: file.File,
  credentials credentials: tg.Credentials,
) -> request.Request(BitArray) {
  let path = "/file/bot" <> credentials.token <> "/" <> file.file_path
  request.Request(
    method: http.Get,
    headers: [],
    body: <<>>,
    scheme: credentials.api_server_scheme,
    host: credentials.api_server_host,
    port: credentials.api_server_port,
    path:,
    query: option.None,
  )
}

pub fn response(
  response: response.Response(BitArray),
) -> Result(file.File, tg.TgError) {
  use payload <- result.try(internal.extract_payload(response))

  decode.run(payload, file.file_decoder())
  |> result.map_error(fn(errors) { tg.FailedToDecodePayload(errors, payload:) })
}
