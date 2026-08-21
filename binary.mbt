///|
/// A bounded little-endian reader for DICOM byte streams.
pub struct ByteReader {
  bytes : Bytes
  mut position : Int
}

///|
/// A parse failure with the byte offset where it was detected.
pub(all) suberror ParseError {
  InvalidMagic(offset~ : Int)
  Truncated(offset~ : Int, needed~ : Int, remaining~ : Int)
  InvalidVr(offset~ : Int, code~ : String)
  InvalidLength(offset~ : Int, length~ : Int)
  Unsupported(offset~ : Int, message~ : String)
}

///|
/// Create a reader positioned at the first byte.
pub fn byte_reader(bytes : Bytes) -> ByteReader {
  { bytes, position: 0 }
}

///|
/// Return the current byte offset.
pub fn ByteReader::position(self : ByteReader) -> Int {
  self.position
}

///|
/// Return the number of unread bytes.
pub fn ByteReader::remaining(self : ByteReader) -> Int {
  self.bytes.length() - self.position
}

///|
fn ByteReader::require(
  self : ByteReader,
  length : Int,
) -> Unit raise ParseError {
  if length < 0 {
    raise ParseError::InvalidLength(offset=self.position, length~)
  }
  let remaining = self.remaining()
  if remaining < length {
    raise ParseError::Truncated(offset=self.position, needed=length, remaining~)
  }
}

///|
fn ByteReader::peek_u16(self : ByteReader) -> Int raise ParseError {
  self.require(2)
  let low = self.bytes[self.position].to_int()
  let high = self.bytes[self.position + 1].to_int()
  low + high * 256
}

///|
fn ByteReader::read_u16(self : ByteReader) -> Int raise ParseError {
  self.require(2)
  let low = self.bytes[self.position].to_int()
  let high = self.bytes[self.position + 1].to_int()
  self.position += 2
  low + high * 256
}

///|
fn ByteReader::read_u32(self : ByteReader) -> Int raise ParseError {
  self.require(4)
  let b0 = self.bytes[self.position].to_int()
  let b1 = self.bytes[self.position + 1].to_int()
  let b2 = self.bytes[self.position + 2].to_int()
  let b3 = self.bytes[self.position + 3].to_int()
  self.position += 4
  b0 + b1 * 256 + b2 * 65536 + b3 * 16777216
}

///|
fn ByteReader::read_bytes(
  self : ByteReader,
  length : Int,
) -> Bytes raise ParseError {
  self.require(length)
  let start = self.position
  self.position += length
  self.bytes[start:self.position].to_owned()
}

///|
fn ByteReader::skip(self : ByteReader, length : Int) -> Unit raise ParseError {
  self.require(length)
  self.position += length
}

///|
fn bytes_to_ascii(bytes : Bytes) -> String {
  let builder = StringBuilder()
  for byte in bytes {
    builder.write_char(byte.to_char())
  }
  builder.to_string()
}

///|
fn ByteReader::read_ascii(
  self : ByteReader,
  length : Int,
) -> String raise ParseError {
  bytes_to_ascii(self.read_bytes(length))
}
