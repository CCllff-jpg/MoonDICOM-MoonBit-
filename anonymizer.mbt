///|
/// A conservative metadata anonymization policy.
pub(all) struct AnonymizationPolicy {
  remove : Array[Tag]
  replacements : Array[(Tag, String)]
  remove_private : Bool
} derive(Eq, Debug)

///|
/// One change made during anonymization.
pub(all) enum AnonymizationAction {
  Removed
  Replaced
} derive(Eq, Debug)

///|
/// An audit record for one anonymized tag.
pub(all) struct AnonymizationAudit {
  tag : Tag
  action : AnonymizationAction
} derive(Eq, Debug)

///|
/// The result of applying an anonymization policy.
pub(all) struct AnonymizationResult {
  dataset : DataSet
  audit : Array[AnonymizationAudit]
} derive(Eq, Debug)

///|
/// Create an empty policy.
pub fn anonymization_policy() -> AnonymizationPolicy {
  { remove: [], replacements: [], remove_private: false }
}

///|
/// Return a conservative policy for common identifying metadata.
pub fn default_anonymization_policy() -> AnonymizationPolicy {
  {
    remove: [
      patient_name(),
      patient_id(),
      patient_birth_date(),
      referring_physician_name(),
      accession_number(),
    ],
    replacements: [
      (institution_name(), "REDACTED"),
      (study_description(), "REDACTED"),
      (series_description(), "REDACTED"),
    ],
    remove_private: true,
  }
}

///|
/// Return a policy that removes the given tag.
pub fn AnonymizationPolicy::with_remove(
  self : AnonymizationPolicy,
  tag : Tag,
) -> AnonymizationPolicy {
  self.remove.push(tag)
  self
}

///|
/// Return a policy that replaces a text value for the given tag.
pub fn AnonymizationPolicy::with_replacement(
  self : AnonymizationPolicy,
  tag : Tag,
  value : String,
) -> AnonymizationPolicy {
  self.replacements.push((tag, value))
  self
}

///|
/// Return a policy with private-tag removal enabled.
pub fn AnonymizationPolicy::with_private_removal(
  self : AnonymizationPolicy,
) -> AnonymizationPolicy {
  { remove: self.remove, replacements: self.replacements, remove_private: true }
}

///|
/// Apply a policy without modifying the source data set.
pub fn anonymize(
  dataset : DataSet,
  policy : AnonymizationPolicy,
) -> AnonymizationResult {
  let result = data_set()
  let audit : Array[AnonymizationAudit] = []
  for element in dataset.elements() {
    if policy.remove_private && element.tag.is_private() {
      audit.push({ tag: element.tag, action: Removed })
    } else if policy.remove.contains(element.tag) {
      audit.push({ tag: element.tag, action: Removed })
    } else {
      match replacement_for(policy.replacements, element.tag) {
        Some(value) => {
          result.set(data_element(element.tag, element.vr, Text(value)))
          audit.push({ tag: element.tag, action: Replaced })
        }
        None => result.set(element)
      }
    }
  }
  { dataset: result, audit }
}

///|
/// Return the anonymized data set.
pub fn AnonymizationResult::dataset(self : AnonymizationResult) -> DataSet {
  self.dataset
}

///|
/// Return the audit entries in source order.
pub fn AnonymizationResult::audit(
  self : AnonymizationResult,
) -> Array[AnonymizationAudit] {
  self.audit.copy()
}

///|
/// Return the tag changed by this audit entry.
pub fn AnonymizationAudit::tag(self : AnonymizationAudit) -> Tag {
  self.tag
}

///|
/// Return the action recorded for this audit entry.
pub fn AnonymizationAudit::action(
  self : AnonymizationAudit,
) -> AnonymizationAction {
  self.action
}

///|
fn replacement_for(replacements : Array[(Tag, String)], tag : Tag) -> String? {
  for pair in replacements {
    let replacement_tag = pair.0
    let value = pair.1
    if replacement_tag == tag {
      return Some(value)
    }
  }
  None
}
