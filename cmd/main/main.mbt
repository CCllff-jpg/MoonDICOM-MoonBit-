///|
/// Print command usage.
fn print_usage() -> Unit {
  println("MoonDICOM - DICOM metadata inspection toolkit")
  println("")
  println("Usage:")
  println("  moon run cmd/main -- inspect FILE")
  println("  moon run cmd/main -- validate FILE")
  println("  moon run cmd/main -- convert FILE --format json")
  println("  moon run cmd/main -- anonymize FILE --output REPORT.json")
}

///|
/// Print an error and terminate with a command failure status.
fn fail(message : String) -> Unit {
  println("error: " + message)
  @sys.exit(2)
}

///|
fn read_dataset(path : String) -> @dicom.DataSet? {
  let bytes = @fs.read_file_to_bytes(path) catch { _ => return None }
  Some(@dicom.parse(bytes) catch { _ => return None })
}

///|
fn inspect(path : String) -> Unit {
  match read_dataset(path) {
    None => fail("unable to read or parse " + path)
    Some(dataset) => {
      println("Elements: " + dataset.length().to_string())
      print_text(dataset, @dicom.patient_name(), "PatientName")
      print_text(dataset, @dicom.patient_id(), "PatientID")
      print_text(dataset, @dicom.modality(), "Modality")
      print_int(dataset, @dicom.rows(), "Rows")
      print_int(dataset, @dicom.columns(), "Columns")
    }
  }
}

///|
fn print_text(
  dataset : @dicom.DataSet,
  tag : @dicom.Tag,
  label : String,
) -> Unit {
  match dataset.get_text(tag) {
    Some(value) => println(label + ": " + value)
    None => ()
  }
}

///|
fn print_int(
  dataset : @dicom.DataSet,
  tag : @dicom.Tag,
  label : String,
) -> Unit {
  match dataset.get_int(tag) {
    Some(value) => println(label + ": " + value.to_string())
    None => ()
  }
}

///|
fn validate(path : String) -> Unit {
  match read_dataset(path) {
    None => fail("unable to read or parse " + path)
    Some(dataset) => {
      let report = @dicom.validate(dataset)
      for issue in report.issues() {
        let severity = match issue.severity() {
          @dicom.ValidationSeverity::Error => "ERROR"
          @dicom.ValidationSeverity::Warning => "WARNING"
        }
        println(severity + " " + issue.code() + ": " + issue.message())
      }
      println("Errors: " + report.error_count().to_string())
      println("Warnings: " + report.warning_count().to_string())
      if report.error_count() > 0 {
        @sys.exit(1)
      }
    }
  }
}

///|
fn convert(path : String) -> Unit {
  match read_dataset(path) {
    None => fail("unable to read or parse " + path)
    Some(dataset) =>
      println(@dicom.dataset_to_json(dataset).stringify(indent=2))
  }
}

///|
fn anonymize(path : String, output : String) -> Unit {
  match read_dataset(path) {
    None => fail("unable to read or parse " + path)
    Some(dataset) => {
      let result = @dicom.anonymize(
        dataset,
        @dicom.default_anonymization_policy(),
      )
      let json = @dicom.dataset_to_json(result.dataset()).stringify(indent=2)
      @fs.write_string_to_file(output, json) catch {
        _ => fail("unable to write " + output)
      }
      println("Wrote anonymized metadata JSON: " + output)
      println("Audit entries: " + result.audit().length().to_string())
      println("Note: this command does not write a binary DICOM file.")
    }
  }
}

///|
/// Run the command-line interface.
fn main {
  let args = @env.args()
  if args.length() < 2 {
    print_usage()
    return
  }
  match args[1] {
    "help" | "--help" | "-h" => print_usage()
    "inspect" if args.length() == 3 => inspect(args[2])
    "validate" if args.length() == 3 => validate(args[2])
    "convert" if args.length() == 5 &&
      args[3] == "--format" &&
      args[4] == "json" => convert(args[2])
    "anonymize" if args.length() == 5 && args[3] == "--output" =>
      anonymize(args[2], args[4])
    command => {
      fail("invalid command or arguments: " + command)
      print_usage()
    }
  }
}
