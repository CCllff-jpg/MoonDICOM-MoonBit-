# MoonDICOM

MoonDICOM is a pure MoonBit toolkit for reading DICOM Part 10 metadata safely and preparing it for validation, privacy anonymization, and reporting.

Author: CCllff-jpg <347921583@qq.com>

Repository: to be added after the remote repository is created.

## Current status

The first implementation provides an in-memory core for:

- DICOM `Tag`, common tag names, and dictionary VR lookup;
- Part 10 preamble and `DICM` marker validation;
- Explicit VR Little Endian parsing;
- basic Implicit VR Little Endian parsing;
- short and long explicit-VR length headers;
- text, integer, and raw byte values;
- ordered `DataSet` lookup, replacement, and removal;
- byte-offset-aware errors for truncated or malformed input;
- semantic validation reports with stable issue codes;
- conservative, policy-driven metadata anonymization with an audit trail.

```moonbit nocheck
///|
let dataset = @moondicom.parse(file_bytes)

///|
let patient_name = dataset.get_text(@moondicom.patient_name())

///|
let image_rows = dataset.get_int(@moondicom.rows())

///|
let report = @moondicom.validate(dataset)

///|
let public_copy = @moondicom.anonymize(
  dataset,
  @moondicom.default_anonymization_policy(),
)
```

Validation checks required identity metadata, UID and date syntax, image dimensions, bit depth relationships, pixel representation, and missing pixel data warnings. Anonymization can remove common identifying fields, replace configured text values, remove private groups, and record each change without mutating the source data set.

## Command line

The native CLI can inspect and validate a real Part 10 file and export metadata as JSON:

```sh
moon run cmd/main -- inspect sample.dcm
moon run cmd/main -- validate sample.dcm
moon run cmd/main -- convert sample.dcm --format json
moon run cmd/main -- anonymize sample.dcm --output anonymized.json
```

The `anonymize` command writes an anonymized metadata JSON report and an audit count. It does not rewrite a binary `.dcm` file; a DICOM encoder is intentionally not claimed until it can preserve transfer syntax and unsupported data safely.


This is a metadata parser, not a medical diagnostic system. The current version does not decode compressed pixel formats, interpret all DICOM value representations, parse undefined-length sequences, provide DICOM network services, or guarantee regulatory compliance. Pixel data is retained as raw bytes when it has a defined length.

Anonymization only changes represented metadata. It does not inspect burned-in text inside pixels, remove every possible identifying attribute, apply date shifting, remap UIDs, or establish legal compliance. It must be followed by domain review and any applicable institutional privacy process.

## Development

Run these commands from the module directory:

```sh
moon check
moon check --target all
moon test
moon fmt
moon info
```

Tests construct small synthetic DICOM byte sequences in memory; no real patient data is included.
