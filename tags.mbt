///|
/// Core DICOM tag identifier.
pub(all) struct Tag {
  group : Int
  element : Int
} derive(Eq, Debug)

///|
/// Construct a DICOM tag from group and element numbers.
pub fn tag(group : Int, element : Int) -> Tag {
  { group, element }
}

///|
/// Pad a lowercase hexadecimal string to four characters.
fn hex4(value : Int) -> String {
  let raw = value.to_string(radix=16)
  if raw.length() >= 4 {
    raw
  } else if raw.length() == 3 {
    "0" + raw
  } else if raw.length() == 2 {
    "00" + raw
  } else if raw.length() == 1 {
    "000" + raw
  } else {
    "0000"
  }
}

///|
/// Render a tag using DICOM notation, for example `(0010,0010)`.
pub fn Tag::to_string(self : Tag) -> String {
  "(" + hex4(self.group) + "," + hex4(self.element) + ")"
}

///|
/// True when the tag is a private creator or private data element.
pub fn Tag::is_private(self : Tag) -> Bool {
  self.group % 2 == 1
}

///|
/// Commonly used DICOM tags.
pub fn file_meta_group_length() -> Tag {
  tag(0x0002, 0x0000)
}

///|
pub fn file_meta_information_version() -> Tag {
  tag(0x0002, 0x0001)
}

///|
pub fn media_storage_sop_class_uid() -> Tag {
  tag(0x0002, 0x0002)
}

///|
pub fn media_storage_sop_instance_uid() -> Tag {
  tag(0x0002, 0x0003)
}

///|
pub fn transfer_syntax_uid() -> Tag {
  tag(0x0002, 0x0010)
}

///|
pub fn implementation_class_uid() -> Tag {
  tag(0x0002, 0x0012)
}

///|
pub fn implementation_version_name() -> Tag {
  tag(0x0002, 0x0013)
}

///|
pub fn specific_character_set() -> Tag {
  tag(0x0008, 0x0005)
}

///|
pub fn sop_class_uid() -> Tag {
  tag(0x0008, 0x0016)
}

///|
pub fn sop_instance_uid() -> Tag {
  tag(0x0008, 0x0018)
}

///|
pub fn study_date() -> Tag {
  tag(0x0008, 0x0020)
}

///|
pub fn study_time() -> Tag {
  tag(0x0008, 0x0030)
}

///|
pub fn accession_number() -> Tag {
  tag(0x0008, 0x0050)
}

///|
pub fn modality() -> Tag {
  tag(0x0008, 0x0060)
}

///|
pub fn institution_name() -> Tag {
  tag(0x0008, 0x0080)
}

///|
pub fn referring_physician_name() -> Tag {
  tag(0x0008, 0x0090)
}

///|
pub fn study_description() -> Tag {
  tag(0x0008, 0x1030)
}

///|
pub fn series_description() -> Tag {
  tag(0x0008, 0x103e)
}

///|
pub fn patient_name() -> Tag {
  tag(0x0010, 0x0010)
}

///|
pub fn patient_id() -> Tag {
  tag(0x0010, 0x0020)
}

///|
pub fn patient_birth_date() -> Tag {
  tag(0x0010, 0x0030)
}

///|
pub fn patient_sex() -> Tag {
  tag(0x0010, 0x0040)
}

///|
pub fn study_instance_uid() -> Tag {
  tag(0x0020, 0x000d)
}

///|
pub fn series_instance_uid() -> Tag {
  tag(0x0020, 0x000e)
}

///|
pub fn samples_per_pixel() -> Tag {
  tag(0x0028, 0x0002)
}

///|
pub fn rows() -> Tag {
  tag(0x0028, 0x0010)
}

///|
pub fn columns() -> Tag {
  tag(0x0028, 0x0011)
}

///|
pub fn pixel_spacing() -> Tag {
  tag(0x0028, 0x0030)
}

///|
pub fn bits_allocated() -> Tag {
  tag(0x0028, 0x0100)
}

///|
pub fn bits_stored() -> Tag {
  tag(0x0028, 0x0101)
}

///|
pub fn high_bit() -> Tag {
  tag(0x0028, 0x0102)
}

///|
pub fn pixel_representation() -> Tag {
  tag(0x0028, 0x0103)
}

///|
pub fn pixel_data() -> Tag {
  tag(0x7fe0, 0x0010)
}

///|
/// Human-readable name for a common tag.
pub fn tag_name(tag : Tag) -> String {
  match tag {
    _ if tag == file_meta_group_length() => "File Meta Information Group Length"
    _ if tag == file_meta_information_version() =>
      "File Meta Information Version"
    _ if tag == media_storage_sop_class_uid() => "Media Storage SOP Class UID"
    _ if tag == media_storage_sop_instance_uid() =>
      "Media Storage SOP Instance UID"
    _ if tag == transfer_syntax_uid() => "Transfer Syntax UID"
    _ if tag == implementation_class_uid() => "Implementation Class UID"
    _ if tag == implementation_version_name() => "Implementation Version Name"
    _ if tag == specific_character_set() => "Specific Character Set"
    _ if tag == sop_class_uid() => "SOP Class UID"
    _ if tag == sop_instance_uid() => "SOP Instance UID"
    _ if tag == study_date() => "Study Date"
    _ if tag == study_time() => "Study Time"
    _ if tag == accession_number() => "Accession Number"
    _ if tag == modality() => "Modality"
    _ if tag == institution_name() => "Institution Name"
    _ if tag == referring_physician_name() => "Referring Physician Name"
    _ if tag == study_description() => "Study Description"
    _ if tag == series_description() => "Series Description"
    _ if tag == patient_name() => "Patient Name"
    _ if tag == patient_id() => "Patient ID"
    _ if tag == patient_birth_date() => "Patient Birth Date"
    _ if tag == patient_sex() => "Patient Sex"
    _ if tag == study_instance_uid() => "Study Instance UID"
    _ if tag == series_instance_uid() => "Series Instance UID"
    _ if tag == samples_per_pixel() => "Samples per Pixel"
    _ if tag == rows() => "Rows"
    _ if tag == columns() => "Columns"
    _ if tag == pixel_spacing() => "Pixel Spacing"
    _ if tag == bits_allocated() => "Bits Allocated"
    _ if tag == bits_stored() => "Bits Stored"
    _ if tag == high_bit() => "High Bit"
    _ if tag == pixel_representation() => "Pixel Representation"
    _ if tag == pixel_data() => "Pixel Data"
    _ => "Unknown"
  }
}

///|
/// Expected VR for common tags. Unknown implicit-VR tags use `UN`.
pub fn dictionary_vr(tag : Tag) -> String {
  match tag {
    _ if tag == file_meta_group_length() => "UL"
    _ if tag == file_meta_information_version() => "OB"
    _ if tag == media_storage_sop_class_uid() => "UI"
    _ if tag == media_storage_sop_instance_uid() => "UI"
    _ if tag == transfer_syntax_uid() => "UI"
    _ if tag == implementation_class_uid() => "UI"
    _ if tag == implementation_version_name() => "SH"
    _ if tag == specific_character_set() => "CS"
    _ if tag == sop_class_uid() => "UI"
    _ if tag == sop_instance_uid() => "UI"
    _ if tag == study_date() => "DA"
    _ if tag == study_time() => "TM"
    _ if tag == accession_number() => "SH"
    _ if tag == modality() => "CS"
    _ if tag == institution_name() => "LO"
    _ if tag == referring_physician_name() => "PN"
    _ if tag == study_description() => "LO"
    _ if tag == series_description() => "LO"
    _ if tag == patient_name() => "PN"
    _ if tag == patient_id() => "LO"
    _ if tag == patient_birth_date() => "DA"
    _ if tag == patient_sex() => "CS"
    _ if tag == study_instance_uid() => "UI"
    _ if tag == series_instance_uid() => "UI"
    _ if tag == samples_per_pixel() => "US"
    _ if tag == rows() => "US"
    _ if tag == columns() => "US"
    _ if tag == pixel_spacing() => "DS"
    _ if tag == bits_allocated() => "US"
    _ if tag == bits_stored() => "US"
    _ if tag == high_bit() => "US"
    _ if tag == pixel_representation() => "US"
    _ if tag == pixel_data() => "OB"
    _ => "UN"
  }
}
