///|
/// DICOM Value Representation.
pub(all) enum ValueRepresentation {
  AE
  AS
  AT
  CS
  DA
  DS
  DT
  FD
  FL
  IS
  LO
  LT
  OB
  OD
  OF
  OL
  OV
  OW
  PN
  SH
  SL
  SQ
  SS
  ST
  SV
  TM
  UC
  UI
  UL
  UN
  UR
  US
  UT
  UV
} derive(Eq, Debug)

///|
/// Parse a two-byte VR code.
pub fn value_representation(
  code : String,
  offset~ : Int,
) -> ValueRepresentation raise ParseError {
  match code {
    "AE" => AE
    "AS" => AS
    "AT" => AT
    "CS" => CS
    "DA" => DA
    "DS" => DS
    "DT" => DT
    "FD" => FD
    "FL" => FL
    "IS" => IS
    "LO" => LO
    "LT" => LT
    "OB" => OB
    "OD" => OD
    "OF" => OF
    "OL" => OL
    "OV" => OV
    "OW" => OW
    "PN" => PN
    "SH" => SH
    "SL" => SL
    "SQ" => SQ
    "SS" => SS
    "ST" => ST
    "SV" => SV
    "TM" => TM
    "UC" => UC
    "UI" => UI
    "UL" => UL
    "UN" => UN
    "UR" => UR
    "US" => US
    "UT" => UT
    "UV" => UV
    _ => raise ParseError::InvalidVr(offset~, code~)
  }
}

///|
/// Render a VR as its DICOM two-byte code.
pub fn ValueRepresentation::to_string(self : ValueRepresentation) -> String {
  match self {
    AE => "AE"
    AS => "AS"
    AT => "AT"
    CS => "CS"
    DA => "DA"
    DS => "DS"
    DT => "DT"
    FD => "FD"
    FL => "FL"
    IS => "IS"
    LO => "LO"
    LT => "LT"
    OB => "OB"
    OD => "OD"
    OF => "OF"
    OL => "OL"
    OV => "OV"
    OW => "OW"
    PN => "PN"
    SH => "SH"
    SL => "SL"
    SQ => "SQ"
    SS => "SS"
    ST => "ST"
    SV => "SV"
    TM => "TM"
    UC => "UC"
    UI => "UI"
    UL => "UL"
    UN => "UN"
    UR => "UR"
    US => "US"
    UT => "UT"
    UV => "UV"
  }
}

///|
/// Whether a VR uses the explicit VR long-length header form.
pub fn ValueRepresentation::uses_long_header(
  self : ValueRepresentation,
) -> Bool {
  match self {
    OB | OD | OF | OL | OV | OW | SQ | UC | UR | UT => true
    _ => false
  }
}

///|
/// Whether this VR is represented as text in the public value model.
pub fn ValueRepresentation::is_text(self : ValueRepresentation) -> Bool {
  match self {
    AE
    | AS
    | CS
    | DA
    | DS
    | DT
    | IS
    | LO
    | LT
    | PN
    | SH
    | ST
    | TM
    | UC
    | UI
    | UR
    | UT => true
    _ => false
  }
}
