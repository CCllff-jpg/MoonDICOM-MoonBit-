///|
/// Convert a data set to DICOMweb-style JSON.
pub fn dataset_to_json(dataset : DataSet) -> Json {
  let object : Map[String, Json] = Map([])
  for element in dataset.elements() {
    let key = element.tag
      .to_string()
      .replace(old="(", new="")
      .replace(old=",", new="")
      .replace(old=")", new="")
    let tag_key = key.to_upper()
    let value = match element.value {
      Text(text) => Json::array([Json::string(text)])
      Integer(number) => Json::array([Json::number(Double::from_int(number))])
      Bytes(bytes) => Json::array([Json::string(bytes_to_hex(bytes))])
    }
    object[tag_key] = Json::object({
      "vr": Json::string(element.vr.to_string()),
      "Value": value,
    })
  }
  Json::object(object)
}

///|
fn bytes_to_hex(bytes : Bytes) -> String {
  let builder = StringBuilder()
  for byte in bytes {
    let hex = byte.to_hex()
    if hex.length() == 1 {
      builder.write_string("0")
    }
    builder.write_string(hex)
  }
  builder.to_string()
}
