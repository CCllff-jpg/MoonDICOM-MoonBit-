///|
/// Severity of a validation issue.
pub(all) enum ValidationSeverity {
  Error
  Warning
} derive(Eq, Debug)

///|
/// One structural or semantic validation finding.
pub(all) struct ValidationIssue {
  severity : ValidationSeverity
  code : String
  tag : Tag?
  message : String
} derive(Eq, Debug)

///|
/// The complete validation result for a data set.
pub(all) struct ValidationReport {
  issues : Array[ValidationIssue]
} derive(Eq, Debug)

///|
/// Validate a DICOM data set without modifying it.
pub fn validate(dataset : DataSet) -> ValidationReport {
  let issues : Array[ValidationIssue] = []
  check_required_text(
    dataset,
    issues,
    sop_class_uid(),
    "META001",
    "SOP Class UID is missing",
  )
  check_required_text(
    dataset,
    issues,
    sop_instance_uid(),
    "META002",
    "SOP Instance UID is missing",
  )
  check_required_text(
    dataset,
    issues,
    study_instance_uid(),
    "META003",
    "Study Instance UID is missing",
  )
  check_required_text(
    dataset,
    issues,
    series_instance_uid(),
    "META004",
    "Series Instance UID is missing",
  )
  check_required_text(
    dataset,
    issues,
    modality(),
    "META005",
    "Modality is missing",
  )
  check_uid(dataset, issues, sop_class_uid(), "UID001")
  check_uid(dataset, issues, sop_instance_uid(), "UID002")
  check_uid(dataset, issues, study_instance_uid(), "UID003")
  check_uid(dataset, issues, series_instance_uid(), "UID004")
  check_date(dataset, issues, study_date(), "DATE001")
  check_positive(dataset, issues, rows(), "IMAGE001", "Rows must be positive")
  check_positive(
    dataset,
    issues,
    columns(),
    "IMAGE002",
    "Columns must be positive",
  )
  check_pixel_representation(dataset, issues)
  check_bits(dataset, issues)
  check_pixel_data(dataset, issues)
  { issues, }
}

///|
/// Return all findings in insertion order.
pub fn ValidationReport::issues(
  self : ValidationReport,
) -> Array[ValidationIssue] {
  self.issues.copy()
}

///|
/// Return the number of errors.
pub fn ValidationReport::error_count(self : ValidationReport) -> Int {
  self.count(Error)
}

///|
/// Return the number of warnings.
pub fn ValidationReport::warning_count(self : ValidationReport) -> Int {
  self.count(Warning)
}

///|
fn ValidationReport::count(
  self : ValidationReport,
  severity : ValidationSeverity,
) -> Int {
  let mut count = 0
  for issue in self.issues {
    if issue.severity == severity {
      count += 1
    }
  }
  count
}

///|
/// Return the severity of an issue.
pub fn ValidationIssue::severity(self : ValidationIssue) -> ValidationSeverity {
  self.severity
}

///|
/// Return the stable machine-readable issue code.
pub fn ValidationIssue::code(self : ValidationIssue) -> String {
  self.code
}

///|
/// Return the related tag, when one exists.
pub fn ValidationIssue::tag(self : ValidationIssue) -> Tag? {
  self.tag
}

///|
/// Return the human-readable issue message.
pub fn ValidationIssue::message(self : ValidationIssue) -> String {
  self.message
}

///|
fn add_issue(
  issues : Array[ValidationIssue],
  severity : ValidationSeverity,
  code : String,
  tag : Tag?,
  message : String,
) -> Unit {
  issues.push({ severity, code, tag, message })
}

///|
fn check_required_text(
  dataset : DataSet,
  issues : Array[ValidationIssue],
  tag : Tag,
  code : String,
  message : String,
) -> Unit {
  match dataset.get_text(tag) {
    Some(value) if value != "" => ()
    _ => add_issue(issues, Error, code, Some(tag), message)
  }
}

///|
fn check_uid(
  dataset : DataSet,
  issues : Array[ValidationIssue],
  tag : Tag,
  code : String,
) -> Unit {
  match dataset.get_text(tag) {
    None => ()
    Some(value) if valid_uid(value) => ()
    Some(_) =>
      add_issue(
        issues,
        Error,
        code,
        Some(tag),
        "UID must contain only digits and dots and must not be empty",
      )
  }
}

///|
fn valid_uid(value : String) -> Bool {
  if value == "" ||
    value.length() > 64 ||
    value.has_prefix(".") ||
    value.has_suffix(".") {
    false
  } else {
    let mut previous_dot = false
    let mut valid = true
    for char in value {
      if char == '.' {
        if previous_dot {
          valid = false
        }
        previous_dot = true
      } else if char >= '0' && char <= '9' {
        previous_dot = false
      } else {
        valid = false
      }
    }
    valid
  }
}

///|
fn check_date(
  dataset : DataSet,
  issues : Array[ValidationIssue],
  tag : Tag,
  code : String,
) -> Unit {
  match dataset.get_text(tag) {
    None => ()
    Some(value) if valid_date(value) => ()
    Some(_) =>
      add_issue(
        issues,
        Warning,
        code,
        Some(tag),
        "Date must use DICOM DA format YYYYMMDD",
      )
  }
}

///|
fn valid_date(value : String) -> Bool {
  if value.length() != 8 {
    false
  } else {
    let mut valid = true
    for char in value {
      if char < '0' || char > '9' {
        valid = false
      }
    }
    valid
  }
}

///|
fn check_positive(
  dataset : DataSet,
  issues : Array[ValidationIssue],
  tag : Tag,
  code : String,
  message : String,
) -> Unit {
  match dataset.get_int(tag) {
    None => add_issue(issues, Warning, code, Some(tag), message)
    Some(value) if value > 0 => ()
    Some(_) => add_issue(issues, Error, code, Some(tag), message)
  }
}

///|
fn check_pixel_representation(
  dataset : DataSet,
  issues : Array[ValidationIssue],
) -> Unit {
  match dataset.get_int(pixel_representation()) {
    None => ()
    Some(0) | Some(1) => ()
    Some(_) =>
      add_issue(
        issues,
        Error,
        "IMAGE003",
        Some(pixel_representation()),
        "Pixel Representation must be 0 or 1",
      )
  }
}

///|
fn check_bits(dataset : DataSet, issues : Array[ValidationIssue]) -> Unit {
  let allocated = dataset.get_int(bits_allocated())
  let stored = dataset.get_int(bits_stored())
  match allocated {
    Some(allocated_value) =>
      match stored {
        Some(stored_value) if stored_value <= allocated_value &&
          stored_value > 0 => ()
        Some(_) =>
          add_issue(
            issues,
            Error,
            "IMAGE004",
            Some(bits_stored()),
            "Bits Stored must be positive and no greater than Bits Allocated",
          )
        None => ()
      }
    None => ()
  }
}

///|
fn check_pixel_data(dataset : DataSet, issues : Array[ValidationIssue]) -> Unit {
  let has_dimensions = dataset.get_int(rows()) is Some(_) ||
    dataset.get_int(columns()) is Some(_)
  if has_dimensions && dataset.get(pixel_data()) is None {
    add_issue(
      issues,
      Warning,
      "PIXEL001",
      Some(pixel_data()),
      "Pixel Data is missing while image dimensions are present",
    )
  }
}
