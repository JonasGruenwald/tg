import gleam/dynamic/decode

pub type File {
  File(
    file_id: String,
    file_unique_id: String,
    file_size: Int,
    file_path: String,
  )
}

@internal
pub fn file_decoder() -> decode.Decoder(File) {
  use file_id <- decode.field("file_id", decode.string)
  use file_unique_id <- decode.field("file_unique_id", decode.string)
  use file_size <- decode.field("file_size", decode.int)
  use file_path <- decode.field("file_path", decode.string)
  decode.success(File(file_id:, file_unique_id:, file_size:, file_path:))
}
