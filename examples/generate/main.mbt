///|
/// Encode one Explicit VR Little Endian element.
fn element(
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
  let length = value.length()
  if vr == "OB" || vr == "OW" || vr == "SQ" || vr == "UT" || vr == "UN" {
    result.push(0)
    result.push(0)
    result.push((length % 256).to_byte())
    result.push((length / 256).to_byte())
    result.push(0)
    result.push(0)
  } else {
    result.push((length % 256).to_byte())
    result.push((length / 256).to_byte())
  }
  for byte in value {
    result.push(byte)
  }
  result
}

///|
/// Build a synthetic, non-identifying Part 10 file.
fn sample() -> Bytes {
  let bytes : Array[Byte] = Array::make(128, 0)
  bytes.push(b'D')
  bytes.push(b'I')
  bytes.push(b'C')
  bytes.push(b'M')
  for
    byte in element(0x0010, 0x0010, "PN", [
      b'D', b'o', b'e', b'^', b'J', b'o', b'h', b'n',
    ]) {
    bytes.push(byte)
  }
  for
    byte in element(0x0010, 0x0020, "LO", [
      b'D', b'E', b'M', b'O', b'-', b'0', b'0', b'1',
    ]) {
    bytes.push(byte)
  }
  for byte in element(0x0008, 0x0060, "CS", [b'C', b'T']) {
    bytes.push(byte)
  }
  for byte in element(0x0028, 0x0010, "US", [0, 2]) {
    bytes.push(byte)
  }
  for byte in element(0x0028, 0x0011, "US", [0, 2]) {
    bytes.push(byte)
  }
  for byte in element(0x0008, 0x0016, "UI", [b'1', b'.', b'2', b'.', b'3', 0]) {
    bytes.push(byte)
  }
  for byte in element(0x0008, 0x0018, "UI", [b'1', b'.', b'2', b'.', b'4', 0]) {
    bytes.push(byte)
  }
  for byte in element(0x0020, 0x000d, "UI", [b'1', b'.', b'2', b'.', b'5', 0]) {
    bytes.push(byte)
  }
  for byte in element(0x0020, 0x000e, "UI", [b'1', b'.', b'2', b'.', b'6', 0]) {
    bytes.push(byte)
  }
  for byte in element(0x7fe0, 0x0010, "OB", [0, 0]) {
    bytes.push(byte)
  }
  Bytes::from_array(bytes)
}

///|
/// Generate a synthetic sample DICOM file.
fn main {
  let args = @env.args()
  let output = if args.length() == 2 { args[1] } else { "examples/sample.dcm" }
  @fs.write_bytes_to_file(output, sample()) catch {
    _ => println("Unable to write " + output)
  }
  println("Wrote synthetic DICOM sample: " + output)
}
