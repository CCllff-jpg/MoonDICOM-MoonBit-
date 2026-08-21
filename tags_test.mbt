///|
/// Tag formatting and dictionary behavior.
test "tag helpers" {
  inspect(tag(0x0010, 0x0010).to_string(), content="(0010,0010)")
  assert_true(tag(0x0011, 0x0010).is_private())
  assert_false(patient_name().is_private())
  inspect(tag_name(patient_name()), content="Patient Name")
  inspect(dictionary_vr(rows()), content="US")
}
