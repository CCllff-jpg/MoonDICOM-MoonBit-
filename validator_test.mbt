///|
fn valid_dataset() -> DataSet {
  let dataset = data_set()
  dataset.set(
    data_element(sop_class_uid(), UI, Text("1.2.840.10008.5.1.4.1.1.2")),
  )
  dataset.set(data_element(sop_instance_uid(), UI, Text("1.2.3.4")))
  dataset.set(data_element(study_instance_uid(), UI, Text("1.2.3.5")))
  dataset.set(data_element(series_instance_uid(), UI, Text("1.2.3.6")))
  dataset.set(data_element(modality(), CS, Text("CT")))
  dataset.set(data_element(study_date(), DA, Text("20260821")))
  dataset.set(data_element(rows(), US, Integer(512)))
  dataset.set(data_element(columns(), US, Integer(512)))
  dataset.set(data_element(bits_allocated(), US, Integer(16)))
  dataset.set(data_element(bits_stored(), US, Integer(12)))
  dataset.set(data_element(pixel_representation(), US, Integer(0)))
  dataset.set(data_element(pixel_data(), OB, Bytes(b"pixels")))
  dataset
}

///|
test "valid metadata has no validation errors" {
  let report = validate(valid_dataset())
  assert_eq(report.error_count(), 0)
  assert_eq(report.warning_count(), 0)
}

///|
test "invalid metadata reports stable findings" {
  let dataset = valid_dataset()
  dataset.set(data_element(rows(), US, Integer(0)))
  dataset.set(data_element(bits_stored(), US, Integer(24)))
  dataset.set(data_element(study_instance_uid(), UI, Text("bad uid")))
  dataset.set(data_element(study_date(), DA, Text("2026-08-21")))
  let report = validate(dataset)
  assert_true(report.error_count() >= 3)
  assert_true(report.warning_count() >= 1)
  let codes = report.issues().map(issue => issue.code())
  assert_true(codes.contains("UID003"))
  assert_true(codes.contains("IMAGE001"))
  assert_true(codes.contains("IMAGE004"))
  assert_true(codes.contains("DATE001"))
}
