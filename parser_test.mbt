///|
fn u16_bytes(value : Int) -> Array[Byte] {
  [(value % 256).to_byte(), (value / 256).to_byte()]
}

///|
fn explicit_element(
  group : Int,
  element : Int,
  vr : String,
  value : Array[Byte],
) -> Array[Byte] {
  let result : Array[Byte] = []
  result.push((group % 256).to_byte())
  result.push((group / 256).to_byte())
  result.push((element % 256).to_byte())
  result.push((element / 256).to_byte())
  result.push(vr[0].to_byte())
  result.push(vr[1].to_byte())
  if vr == "OB" || vr == "OW" || vr == "SQ" || vr == "UT" || vr == "UN" {
    result.push(0)
    result.push(0)
    let length = value.length()
    result.push((length % 256).to_byte())
    result.push((length / 256).to_byte())
    result.push(0)
    result.push(0)
  } else {
    let length = value.length()
    result.push((length % 256).to_byte())
    result.push((length / 256).to_byte())
  }
  for byte in value {
    result.push(byte)
  }
  result
}

///|
fn part10(elements : Array[Byte]) -> Bytes {
  let bytes : Array[Byte] = Array::make(128, 0)
  bytes.push(b'D')
  bytes.push(b'I')
  bytes.push(b'C')
  bytes.push(b'M')
  for byte in elements {
    bytes.push(byte)
  }
  Bytes::from_array(bytes)
}

///|
test "parse explicit vr part 10" {
  let patient = explicit_element(0x0010, 0x0010, "PN", [
    b'D', b'o', b'e', b'^', b'J', b'o', b'h', b'n',
  ])
  let rows_value = explicit_element(0x0028, 0x0010, "US", u16_bytes(512))
  let pixel = explicit_element(0x7fe0, 0x0010, "OB", [1, 2, 3, 4])
  let parsed = parse(part10(patient + rows_value + pixel))
  debug_inspect(parsed.get_text(patient_name()), content="Some(\"Doe^John\")")
  debug_inspect(parsed.get_int(rows()), content="Some(512)")
  let raw_pixel = parsed.get_bytes(pixel_data())
  assert_true(
    raw_pixel is Some(value) &&
    value.length() == 4 &&
    value[0] == 1 &&
    value[3] == 4,
  )
}

///|
test "parse implicit vr dataset" {
  let bytes : Array[Byte] = Array::make(128, 0)
  bytes.push(b'D')
  bytes.push(b'I')
  bytes.push(b'C')
  bytes.push(b'M')
  for
    byte in explicit_element(0x0002, 0x0010, "UI", [
      b'1', b'.', b'2', b'.', b'8', b'4', b'0', b'.', b'1', b'0', b'0', b'0', b'8',
      b'.', b'1', b'.', b'2', 0,
    ]) {
    bytes.push(byte)
  }
  bytes.push(0x10)
  bytes.push(0)
  bytes.push(0x10)
  bytes.push(0)
  bytes.push(8)
  bytes.push(0)
  bytes.push(0)
  bytes.push(0)
  for byte in [b'D', b'o', b'e', b'^', b'J', b'o', b'h', b'n'] {
    bytes.push(byte)
  }
  let parsed = parse(Bytes::from_array(bytes))
  debug_inspect(parsed.get_text(patient_name()), content="Some(\"Doe^John\")")
}

///|
test "truncated part 10 reports offset" {
  try parse(b"not a dicom") catch {
    ParseError::Truncated(offset~, needed=_, remaining=_) =>
      inspect(offset, content="0")
    _ => fail("unexpected parse error")
  } noraise {
    _ => fail("expected parse error")
  }
}
