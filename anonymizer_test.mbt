///|
test "default anonymization removes and replaces metadata" {
  let dataset = data_set()
  dataset.set(data_element(patient_name(), PN, Text("Doe^John")))
  dataset.set(data_element(patient_id(), LO, Text("P-001")))
  dataset.set(data_element(institution_name(), LO, Text("Hospital")))
  dataset.set(data_element(study_description(), LO, Text("Head CT")))
  dataset.set(data_element(tag(0x0011, 0x1001), LO, Text("private")))
  let result = anonymize(dataset, default_anonymization_policy())
  assert_true(result.dataset().get(patient_name()) is None)
  assert_true(result.dataset().get(patient_id()) is None)
  assert_eq(result.dataset().get_text(institution_name()), Some("REDACTED"))
  assert_eq(result.dataset().get_text(study_description()), Some("REDACTED"))
  assert_true(result.dataset().get(tag(0x0011, 0x1001)) is None)
  assert_eq(result.audit().length(), 5)
  assert_true(dataset.get_text(patient_name()) is Some("Doe^John"))
}

///|
test "custom policy records replacement and removal" {
  let dataset = data_set()
  dataset.set(data_element(patient_sex(), CS, Text("M")))
  let policy = anonymization_policy()
    .with_replacement(patient_sex(), "O")
    .with_remove(patient_id())
  let result = anonymize(dataset, policy)
  assert_eq(result.dataset().get_text(patient_sex()), Some("O"))
  assert_eq(result.audit().length(), 1)
  assert_eq(result.audit()[0].tag(), patient_sex())
  assert_eq(result.audit()[0].action(), Replaced)
}
