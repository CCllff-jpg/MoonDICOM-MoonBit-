///|
/// Parse a DICOM Part 10 byte sequence into its data set.
pub fn parse(bytes : Bytes) -> DataSet raise ParseError {
  if bytes.length() < 132 {
    raise ParseError::Truncated(offset=0, needed=132, remaining=bytes.length())
  }
  let reader = byte_reader(bytes)
  reader.skip(128)
  let magic = reader.read_bytes(4)
  if magic != b"DICM" {
    raise ParseError::InvalidMagic(offset=128)
  }
  let meta = parse_elements(reader, true, Some(0x0002))
  let transfer_syntax = match meta.get(transfer_syntax_uid()) {
    Some({ value: Text(value), .. }) => value
    _ => "1.2.840.10008.1.2.1"
  }
  let explicit = transfer_syntax != "1.2.840.10008.1.2"
  let dataset = parse_elements(reader, explicit, None)
  let result = data_set()
  for element in meta.elements() {
    result.set(element)
  }
  for element in dataset.elements() {
    result.set(element)
  }
  result
}

///|
fn parse_elements(
  reader : ByteReader,
  explicit : Bool,
  stop_group : Int?,
) -> DataSet raise ParseError {
  let result = data_set()
  while reader.remaining() > 0 {
    if reader.remaining() < 4 {
      raise ParseError::Truncated(
        offset=reader.position(),
        needed=4,
        remaining=reader.remaining(),
      )
    }
    let group = reader.peek_u16()
    if stop_group is Some(expected) && group != expected {
      break
    }
    let actual_group = reader.read_u16()
    let element = reader.read_u16()
    let tag = tag(actual_group, element)
    let vr = if explicit {
      let code = reader.read_ascii(2)
      value_representation(code, offset=reader.position() - 2)
    } else {
      value_representation(dictionary_vr(tag), offset=reader.position()) catch {
        _ => UN
      }
    }
    let length = if explicit {
      if vr.uses_long_header() {
        reader.skip(2)
        reader.read_u32()
      } else {
        reader.read_u16()
      }
    } else {
      reader.read_u32()
    }
    if length == 0xffffffff {
      raise ParseError::Unsupported(
        offset=reader.position() - 4,
        message="undefined-length elements are not supported yet",
      )
    }
    let value_bytes = reader.read_bytes(length)
    result.set(data_element(tag, vr, decode_value(vr, value_bytes)))
  }
  result
}
