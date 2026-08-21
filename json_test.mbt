///|
test "dataset json uses dicom tag keys" {
  let dataset = data_set()
  dataset.set(data_element(patient_name(), PN, Text("Doe^John")))
  dataset.set(data_element(rows(), US, Integer(512)))
  dataset.set(data_element(pixel_data(), OB, Bytes([1, 15])))
  let json = dataset_to_json(dataset)
  assert_true(json.stringify().contains("00100010"))
  assert_true(json.stringify().contains("Doe^John"))
  assert_true(json.stringify().contains("512"))
  assert_true(json.stringify().contains("010f"))
}

///|
test "dataset json preserves vr" {
  let dataset = data_set()
  dataset.set(data_element(modality(), CS, Text("CT")))
  let json = dataset_to_json(dataset).stringify()
  assert_true(json.contains("00080060"))
  assert_true(json.contains("CS"))
}
