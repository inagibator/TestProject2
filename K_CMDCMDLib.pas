unit K_CMDCMDLib;

interface

uses Classes, Windows, Types, Controls,
  K_UDT1, K_Script1, K_CM0,
  N_Lib0, N_Gra2;

type TK_CMDCMDMediaIn = packed record
  DDMediaUID  : PAnsiChar; // Info for DICOM attribute SOP Instance UID (0008,0018)
  DDMediaDate : PAnsiChar; // Info for DICOM attribute Acquisition Date (0008,0022) - string format yyymmdd
  DDMediaTime : PAnsiChar; // Info for DICOM attribute Acquisition Time (0008,0032) - string format hhnnss
  DDMediaKVP  : PAnsiChar; // Info for DICOM attribute KVP (0018,0060) - Peak kilo voltage output of the x-ray generator used (string of chars representing an Integer in base 10)
  DDMediaExposureTime : PAnsiChar; // Info for DICOM attribute ExposureTime (0018,1150) - Time of x-ray exposure in msec (string of chars representing an Integer in base 10)
  DDMediaTubeCurrent  : PAnsiChar; // Info for DICOM attribute X-Ray Tube Current (0018,1151) - X-Ray Tube Current in mA (string of chars representing an Integer in base 10)
  DDMediaStationName  : PAnsiChar; // Info for DICOM attribute Station Name (0008,1010) - computer name where image was captured
  DDMediaNum  : LongWord; // Info for DICOM attribute Instance Number (0020,0013) - image series number
end;
type TK_PCMDCMDMediaIn = ^TK_CMDCMDMediaIn;

type TK_PCMDCMDMediaOut = packed record
  DDMediaUID  : AnsiString; // Info for DICOM attribute SOP Instance UID (0008,0018)
  DDMediaDate : AnsiString; // Info for DICOM attribute Acquisition Date (0008,0022) - string format yyymmdd
  DDMediaTime : AnsiString; // Info for DICOM attribute Acquisition Time (0008,0032) - string format hhnnss
  DDMediaKVP  : AnsiString; // Info for DICOM attribute KVP (0018,0060) - Peak kilo voltage output of the x-ray generator used (string of chars representing an Integer in base 10)
  DDMediaExposureTime : AnsiString; // Info for DICOM attribute ExposureTime (0018,1150) - Time of x-ray exposure in msec (string of chars representing an Integer in base 10)
  DDMediaTubeCurrent  : AnsiString; // Info for DICOM attribute X-Ray Tube Current (0018,1151) - X-Ray Tube Current in mA (string of chars representing an Integer in base 10)
  DDMediaStationName  : AnsiString; // Info for DICOM attribute Station Name (0008,1010) - computer name where image was captured
  DDMediaNum  : LongWord; // Info for DICOM attribute Instance Number (0020,0013) - image series number (always 1 from CMS)
end;
type TK_CMDCMDMediaOutArr = array of TK_PCMDCMDMediaOut;

type TK_CMDCMDSeriesIn = packed record
  DDSeriesUID  : PAnsiChar; // Info for DICOM attribute Series Instance UID (0020,000E)
  DDSeriesDate : PAnsiChar; // Info for DICOM attribute Series Date (0008,0021) - string format yyymmdd
  DDSeriesTime : PAnsiChar; // Info for DICOM attribute Series Time (0008,0031) - string format hhnnss
  DDSeriesMod  : PAnsiChar; // Info for DICOM attribute Series Modality (0008,0060) - 2 chars string - possible values in CMS : 'CR', 'PX', 'XC'
  DDSeriesNum  : LongWord;  // Info for DICOM attribute Series Number (0020,0011) - series number in study
  DDPMedia     : TK_PCMDCMDMediaIn; // pointer to image attributes array starting item
  DDMediaCount : Integer; // items number in image attributes array
end;
type TK_PCMDCMDSeriesIn = ^TK_CMDCMDSeriesIn;

type TK_CMDCMDSeriesOut = record
  DDSeriesUID  : AnsiString; // Info for DICOM attribute Series Instance UID (0020,000E)
  DDSeriesDate : AnsiString; // Info for DICOM attribute Series Date (0008,0021) - string format yyymmdd
  DDSeriesTime : AnsiString; // Info for DICOM attribute Series Time (0008,0031) - string format hhnnss
  DDSeriesMod  : AnsiString; // Info for DICOM attribute Series Modality (0008,0060) - 2 chars string - possible values in CMS : 'CR', 'PX', 'XC'
  DDSeriesNum  : LongWord;   // Info for DICOM attribute Series Number (0020,0011) - series number in study (always 1 from CMS)
  DDPMedias    : TK_CMDCMDMediaOutArr; // image attributes array
  DDMediaCount : Integer; // items number in image attributes array (needed for DICOM export DLL)
end;
type TK_CMDCMDSeriesOutArr = array of TK_CMDCMDSeriesOut;

type TK_CMDCMDStudyIn = packed record
// Info for DICOM attribute Referring Physician's Name (0008,0090)
  DDProvSurname   : PWideChar; // Dentist Surname
  DDProvFirstname : PWideChar; // Dentist First name
  DDProvMiddle    : PWideChar; // Dentist Middle
  DDProvTitle     : PWideChar; // Dentist title
  DDStudyUID      : PAnsiChar; // Info for DICOM attribute Study Instance UID (0020,000D)
  DDStudyDate     : PAnsiChar; // Info for DICOM attribute Study Date (0008,0020) - string format yyymmdd
  DDStudyTime     : PAnsiChar; // Info for DICOM attribute Study Time (0008,0030) - string format hhnnss
//  DDStudyID       : LongWord;  // Info for DICOM attribute Study ID (0020,0010)
  DDStudyID       : PAnsiChar; // Info for DICOM attribute Study ID (0020,0010)
  DDPSeries       : TK_PCMDCMDSeriesIn; // pointer to Series attributes array starting item
  DDSeriesCount   : Integer;            // items number in Series attributes array
end;
type TK_PCMDCMDStudyIn = ^TK_CMDCMDStudyIn;

type TK_CMDCMDStudyOut = packed record
// Info for DICOM attribute Referring Physician's Name (0008,0090)
  DDProvSurname   : WideString; // Dentist Surname
  DDProvFirstname : WideString; // Dentist First name
  DDProvMiddle    : WideString; // Dentist Middle
  DDProvTitle     : WideString; // Dentist title
  DDStudyUID      : AnsiString; // Info for DICOM attribute Study Instance UID (0020,000D)
  DDStudyDate     : AnsiString; // Info for DICOM attribute Study Date (0008,0020) - string format yyymmdd
  DDStudyTime     : AnsiString; // Info for DICOM attribute Study Time (0008,0030) - string format hhnnss
//  DDStudyID       : LongWord;   // Info for DICOM attribute Study ID (0020,0010)
  DDStudyID       : AnsiString; // Info for DICOM attribute Study ID (0020,0010)
  DDPSeries       : TK_CMDCMDSeriesOutArr; // Series attributes array
  DDSeriesCount   : Integer;               // items number in Series attributes array (needed for DICOM export DLL)
end;
type TK_CMDCMDStudyOutArr = array of TK_CMDCMDStudyOut;

type TK_CMDCMDPatientIn = packed record
// Info for DICOM attribute Patient's Name (0010,0010)
  DDPatSurname   : PWideChar; // Patient Surname
  DDPatFirstname : PWideChar; // Patient First name
  DDPatMiddle    : PWideChar; // Patient Middle
  DDPatTitle     : PWideChar; // Patient title
  DDPatDOB       : PAnsiChar; // Info for DICOM attribute Patient's Birth Date (0010,0030) - string format yyyymmdd
  DDPatSex       : PAnsiChar; // Info for DICOM attribute Patient's Sex (0010,0040) - single char string: "Ì" - male, "F" - female
//  DDPatID        : LongWord;  // Info for DICOM attribute Patient ID (0010,0020)
  DDPatID        : PAnsiChar; // Info for DICOM attribute Patient ID (0010,0020)
  DDPStudies     : TK_PCMDCMDStudyIn; // pointer to Studies attributes array starting item
  DDStudiesCount : Integer;           // items number in Studies attributes array
end;
type TK_PCMDCMDPatientIn = ^TK_CMDCMDPatientIn;
type TK_PPCMDCMDPatientIn = ^TK_PCMDCMDPatientIn;

type TK_CMDCMDPatientOut = packed record
// Info for DICOM attribute Patient's Name (0010,0010)
  DDPatSurname   : WideString; // Patient Surname
  DDPatFirstname : WideString; // Patient First name
  DDPatMiddle    : WideString; // Patient Middle
  DDPatTitle     : WideString; // Patient title
  DDPatDOB       : AnsiString; // Info for DICOM attribute Patient's Birth Date (0010,0030) - string format yyyymmdd
  DDPatSex       : AnsiString; // Info for DICOM attribute Patient's Sex (0010,0040) - single char string: "Ì" - male, "F" - female
//  DDPatID        : LongWord;   // Info for DICOM attribute Patient ID (0010,0020)
  DDPatID        : AnsiString; // Info for DICOM attribute Patient ID (0010,0020)
  DDPStudies     : TK_CMDCMDStudyOutArr; // Studies attributes array
  DDStudiesCount : Integer;              // Items number in Studies attributes array (needed for DICOM export DLL)
end;
type TK_PCMDCMDPatientOut = ^TK_CMDCMDPatientOut;
type TK_CMDCMDPatientOutArr = array of TK_CMDCMDPatientOut;

type TK_CMDCMQueryPars = packed record
  DQPatNamePattern  : PWideChar; // Patient Name Pattern
  DQPatIDPattern    : PAnsiChar; // Patient ID Pattern
  DQStudyIDPattern  : PAnsiChar; // Study ID Pattern
  DQModalityPattern : PAnsiChar; // Modality Pattern
  DQDateStart       : PAnsiChar; // Start Search Date
  DQDateFin         : PAnsiChar; // Finish Search Date
end;
type TK_PCMDCMQueryPars = ^TK_CMDCMQueryPars;

type TK_CMDCMQPatient = packed record
  DQPatSurname   : PWideChar; // Patient Surname
  DQPatFirstName : PWideChar; // Patient Firstname
  DQPatMiddle    : PWideChar; // Patient Middle Name
  DQPatTitle     : PWideChar; // Patient Title
  DQPatDOB       : PAnsiChar; // Patient DOB
  DQPatGender    : PAnsiChar; // Patient Gender [0] char "M" or "F"
  DQPatID        : PAnsiChar; // Patient ID
end;
type TK_PCMDCMQPatient = ^TK_CMDCMQPatient;
type TK_CMDCMQPatientArr = array of TK_CMDCMQPatient;

type TK_CMDCMDLib = class // DICOMDIR Import base class
  DDLastImageSize : TPoint;
  constructor Create(); virtual;
  function DDStartImport( AFNames : TStrings; out APPatInfo : TK_PCMDCMDPatientIn; out APatCount : Integer ) : Integer; virtual;
  function DDGetDIBInfo( APatInd, AStudyInd, ASeriesInd, AImageInd : Integer;
                         APDIBInfo : TN_PDIBInfo  ) : Integer; virtual;
  function DDGetSelDIBInfo( APDIBInfo : TN_PDIBInfo  ) : Integer; virtual;
  function DDGetDIBPixels( APatInd, AStudyInd, ASeriesInd, AImageInd : Integer;
                           APPixels: Pointer; APixLength : Integer ) : Integer; virtual;
  function DDGetSelDIBPixels( APPixels: Pointer; APixLength : Integer ) : Integer; virtual;
  function DDGetDIB( APatInd, AStudyInd, ASeriesInd, AImageInd : Integer;
                          out ADIBObj : TN_DIBObj ) : Integer; virtual;
  function DDGetThumbDIB( ADIBObj : TN_DIBObj; out AThumbDIB : TN_DIBObj ) : Integer; virtual;
  function DDFinImport() : Integer; virtual;
  function DDStartQR( const ADCMServerName, ADCMServerIP : string;
                      ADCMServerPort : Integer; const AEName : string ) : Integer; virtual;
  function DDFinishQR() : Integer; virtual;
  function DDQuery( var AQueryPars : TK_CMDCMQueryPars; out APQueryPatient : TK_PCMDCMQPatient; out APatCount : Integer ) : Integer; virtual;
  function DDRetrieve( APQPatInd : PInteger; AQPIndsCount : Integer; out APPatInfo : TK_PCMDCMDPatientIn; out APatCount : Integer ) : Integer; virtual;
end;


type TK_CMDCMDLibEmul = class (TK_CMDCMDLib) // DICOMDIR Export/Import Emulator
  DCMDPatDataArr : TK_CMDCMDPatientOutArr;

  function DDStartImport( AFNames : TStrings; out APPatInfo : TK_PCMDCMDPatientIn; out APatCount : Integer ) : Integer; override;
  function DDFinImport() : Integer; override;
  function DDGetDIBInfo( APatInd, AStudyInd, ASeriesInd, AImageInd : Integer;
                         APDIBInfo : TN_PDIBInfo  ) : Integer; override;
  function DDGetDIBPixels( APatInd, AStudyInd, ASeriesInd, AImageInd : Integer;
                           APPixels: Pointer; APixLength : Integer ) : Integer; override;
  function DDGetDIB( APatInd, AStudyInd, ASeriesInd, AImageInd : Integer;
                     out ADIBObj : TN_DIBObj ) : Integer; override;
end;

type TK_CMDCMDPatientCheckProc = function ( const APatSurname, APatFirstName, APatCardNum : string;
                                              APatDOB : TDate ) : Integer of object;

function K_GetDICOMUIDComponentFromGUID( const ASGUID : string ) : string;
function K_CMCreateDCMDPatData( out ADCMDPatDataArr : TK_CMDCMDPatientOutArr;
                                APSlide : TN_PUDCMSlide; ASLidesCount : Integer;
                                APPatDataInds : PInteger = nil ): Integer;
function K_CMCreateDCMDUDTree( var AUDRoot : TN_UDBase; APPats: TK_PCMDCMDPatientIn; APatsCount: Integer;
                               APatCheckProc : TK_CMDCMDPatientCheckProc ): Integer;

implementation

uses SysUtils, IniFiles, Graphics, DateUtils, Math,
  K_CLib0, K_UDConst, K_CMDCM,
  N_Gra1, N_ImLib, N_Types, N_CMMain5F;
{
//****************************************** K_GetDICOMUIDComponentFromGUID ***
// Create DICOM UID component from GUID
//
//     Parameters
// ASGUID - source GUID string
// Result - Returns resulting DICOM UID component string
//
function K_GetDICOMUIDComponentFromGUID( const ASGUID : string ) : string;
  procedure AddGUIDPart( Ind1, Ind2 : Integer );
  var
    WLong : LongWord;
    WStr : string;
  begin
    WStr := '$' + Copy(ASGUID, Ind1, Ind2 );
    WLong := StrToInt(WStr);
    if WLong > 0 then
      Result := Result + IntToStr(WLong);
  end;
begin
  Result := '';
  AddGUIDPart( 2, 4 );
  AddGUIDPart( 6, 4 );
  AddGUIDPart( 11, 4 );
  AddGUIDPart( 16, 4 );
  AddGUIDPart( 21, 4 );
  AddGUIDPart( 26, 4 );
  AddGUIDPart( 30, 4 );
  AddGUIDPart( 34, 4 );
end; // K_GetDICOMUIDComponentFromGUID
}

//****************************************** K_GetDICOMUIDComponentFromGUID ***
// Create DICOM UID component from GUID
//
//     Parameters
// ASGUID - source GUID string
// Result - Returns resulting DICOM UID component string
//
function K_GetDICOMUIDComponentFromGUID( const ASGUID : string ) : string;
var
  WStr : string;
  W64 : Int64;

begin
  Result := '';
  SetLength( WStr, 17 );
  WStr[1] := '$';
  Move( ASGUID[2], WStr[2], 8 * SizeOf(Char) );
  Move( ASGUID[11], WStr[10], 4 * SizeOf(Char) );
  Move( ASGUID[16], WStr[14], 4 * SizeOf(Char) );
  W64 := StrToInt64(WStr);
  Result := format( '%u', [W64] );

  Move( ASGUID[21], WStr[2], 4 * SizeOf(Char) );
  Move( ASGUID[26], WStr[6], 12 * SizeOf(Char) );
  W64 := StrToInt64(WStr);
  Result := format( '%s%u', [Result,W64] );
end; // K_GetDICOMUIDComponentFromGUID

{
//****************************************** K_GetDICOMUIDComponentFromGUID ***
// Create DICOM UID component from GUID not more then 31 chars length
//
//     Parameters
// ASGUID - source GUID string
// Result - Returns resulting DICOM UID component string not more then 31 chars length
//
function K_GetDICOMUIDComponentFromGUID31( const ASGUID : string ) : string;
var
  WStr : string;
  W641 : Int64;
  W642 : Int64;
  W643 : Int64;
  W644 : Int64;
  W645 : Int64;
  CFlag : Boolean;

begin
// Parse GUID
  Result := '';
  SetLength( WStr, 17 );
  WStr[1] := '$';
  Move( ASGUID[2], WStr[2], 8 * SizeOf(Char) );
  Move( ASGUID[11], WStr[10], 4 * SizeOf(Char) );
  Move( ASGUID[16], WStr[14], 4 * SizeOf(Char) );
  W641 := StrToInt64(WStr);
  Move( ASGUID[21], WStr[2], 4 * SizeOf(Char) );
  Move( ASGUID[26], WStr[6], 12 * SizeOf(Char) );
  W642 := StrToInt64(WStr);

// Add 13.14.153 bytes to 13

// Add 13(5) byte to 0-3 bytes
  W643 := 0;
  Move( (TN_BytesPtr(@W642) + 5)^, W643, 1 );
  W644 := 0;
  Move( W641, W644, 4 );
  W645 := W643 + W644;
  CFlag := W645 > $00000000FFFFFFFF;
  Move( W645, W641, 4 );

// Add 14(6) byte to 4-7 bytes
  Move( (TN_BytesPtr(@W642) + 6)^, W643, 1 );
  W644 := 0;
  Move( (TN_BytesPtr(@W641) + 4)^, W644, 4 );
  W645 := W643 + W644;
  if CFlag then
    W645 := W645 + 1;
  CFlag := W645 > $00000000FFFFFFFF;
  Move( W645, (TN_BytesPtr(@W641) + 4)^, 4 );
  W641 := W641 and $7FFFFFFFFFFFFFFF;

// Add 15(7) byte to 8-12(0-5) bytes
  Move( (TN_BytesPtr(@W642) + 7)^, W643, 1 );
  Move( W642, W644, 5 );
  W645 := W643 + W644;
  if CFlag then
    W645 := W645 + 1;
  W645 := W645 and $7FFFFFFFFF;
  Result := format( '%u%u', [W641,W645] );
end; // K_GetDICOMUIDComponentFromGUID31
}

//**************************************************** K_CMCreateDCMDUDTree ***
// Create DICOMDIR Patients Data Array by given Slides
//
//     Parameters
// ADCMDPatDataArr - resulting DICOMDIR Patients Data Array
// APSlide - pointer to slides array start element to export
// ASlidesCount - number of slides to export
// APPatDataInds - pointer to start element of array of integer indexes
// Result       - Returns N - number of slides included to export structure
//
// Studies and Vidoe SLides are skiped from source Slides array.
//
// Parameter APPatDataInds is specified, then indexes array should be
// 3 * ASlidesCount  elements length. First N elements of indexes array will contain
// indexes of slides added to resulting data structure in source slides array
// Next 2 * N elements of indexes array will contain pairs of indexes for each
// slide added to resulting data structure. First index in pair is slide DICOM study
// index. Second index in pair is slide series index in slide DICOM study
//
function K_CMCreateDCMDPatData( out ADCMDPatDataArr : TK_CMDCMDPatientOutArr;
                                APSlide : TN_PUDCMSlide; ASLidesCount : Integer;
                                APPatDataInds : PInteger = nil ): Integer;
var
  PatientDBData : TK_CMSAPatientDBData;
  ProviderDBData : TK_CMSAProviderDBData;
  i, j, StudyInd, SeriesInd : Integer;
  CurStudyInd, IVal : Integer;
  FVal : Float;
  DBGUID, SGUID, CurSDate, CurSTime, Modality, WStr : string;
  Slides : TN_UDCMSArray;
  StudiesSID : TN_SArray;
  StudiesTS : TN_DArray;
  SStudyID : AnsiString;

  procedure AddInds( AStudyInd, ASeriesInd : Integer );
  begin
    if APPatDataInds = nil then Exit;
    APPatDataInds^ := AStudyInd;
    Inc(APPatDataInds);
    if ASeriesInd < 0 then Exit;
    APPatDataInds^ := ASeriesInd;
    Inc(APPatDataInds);
  end;

begin
  Result := 0;
  ADCMDPatDataArr := nil;
//  if not (K_CMEDAccess is TK_CMEDDBAccess) {or (K_CMEDDBVersion < 29)} then Exit;
  SetLength( ADCMDPatDataArr, 1 );
  with ADCMDPatDataArr[0] do
  begin
    with K_CMEDAccess do
    begin

      SGUID := EDAGetDBUID();
//      DBGUID := K_GetDICOMUIDComponentFromGUID( SGUID );
      DBGUID := K_GetDICOMUIDComponentFromGUID31( SGUID );

      EDASAGetOnePatientInfo( IntToStr( CurPatID ), @PatientDBData, [K_cmsagiSkipLock] );
      EDASAGetOneProviderInfo( IntToStr( CurProvID ), @ProviderDBData, [K_cmsagiSkipLock] );
      DDPatSurname   := N_StringToWide(PatientDBData.APSurname);
      DDPatFirstname := N_StringToWide(PatientDBData.APFirstname);
      DDPatMiddle    := N_StringToWide(PatientDBData.APMiddle);
      DDPatTitle     := N_StringToWide(PatientDBData.APTitle);
      DDPatDOB       := N_StringToAnsi( K_DateTimeToStr( PatientDBData.APDOB, 'yyyymmdd' ) );
      DDPatSex       := N_StringToAnsi( Copy( PatientDBData.APGender, 1, 1 ) );
      WStr := PatientDBData.APCardNum;
      if WStr = '' then
        WStr := IntToStr(CurPatID);
      DDPatID        := N_StringToAnsi( WStr );

      SetLength( DDPStudies, ASLidesCount );
      StudyInd  := -1;

      SetLength( Slides, ASLidesCount );
      j := 0;
      for i := 1 to ASLidesCount do
      begin
        Slides[j] := APSlide^;
        Inc(APSlide);
        if (TN_UDCMBSlide(Slides[j]) is TN_UDCMStudy)   or
           (cmsfIsMediaObj in Slides[j].P.CMSDB.SFlags) or
           (cmsfIsImg3DObj in Slides[j].P.CMSDB.SFlags) then
        // Skip Video, 3D and Study Slide
          Continue;
        AddInds( i-1, -1 );
        Inc(j);
      end;
      SetLength( Slides, j );

      K_CMEDAccess.EDAGetDCMStudiesAttrs( TN_PUDCMSlide(Slides), j, StudiesSID, StudiesTS );

      for i := 0 to High(Slides) do
      begin
        with Slides[i], P()^ do
        begin

       // DICOM Study Search
          CurStudyInd := -1;
//          StudyID := StrToInt(StudiesSID[i]);
          SStudyID := N_StringToAnsi(StudiesSID[i]);
          for j := 0 to StudyInd do
          begin
//            if Integer(DDPStudies[j].DDStudyID) <> StudyID then Continue;
            if DDPStudies[j].DDStudyID <> SStudyID then Continue;
            CurStudyInd := j;
            break;
          end;

          if CurStudyInd = -1 then
          begin
          //  Create new DICOM study description
            Inc(StudyInd);
            CurStudyInd := StudyInd;
            EDASAGetOneProviderInfo( IntToStr( CMSProvIDCreated ), @ProviderDBData, [K_cmsagiSkipLock] );
            with DDPStudies[StudyInd] do
            begin
              DDProvSurname   := N_StringToWide(ProviderDBData.AUSurname);
              DDProvFirstname := N_StringToWide(ProviderDBData.AUFirstname);
              DDProvMiddle    := N_StringToWide(ProviderDBData.AUMiddle);
              DDProvTitle     := N_StringToWide(ProviderDBData.AUTitle);
              CurSDate := K_DateTimeToStr( StudiesTS[i], 'yyyymmdd' );
              DDStudyDate    := N_StringToAnsi(CurSDate);
              CurSTime := K_DateTimeToStr( StudiesTS[i], 'hhnnss' );
              DDStudyTime    := N_StringToAnsi(CurSTime);
//              DDStudyID      := StudyID;
//              DDStudyID      := N_StringToAnsi(StudiesSID[i] );
              DDStudyID      := SStudyID;
              DDStudyUID     := N_StringToAnsi( format( '%s.%s.1.%s', [CentaurSoftwareUID,DBGUID,StudiesSID[i]]) );
              if (Length(DDStudyUID) and 1) = 0 then
                DDStudyUID := DDStudyUID + '0';
            end;
          end; // if CurStudyInd = -1 then

          CurSDate := K_DateTimeToStr( CMSDTTaken, 'yyyymmdd' );
          CurSTime := K_DateTimeToStr( CMSDTTaken, 'hhnnss' );
          with DDPStudies[CurStudyInd] do
          begin
            SeriesInd := Length(DDPSeries);
            DDSeriesCount := SeriesInd + 1;
            SetLength( DDPSeries, DDSeriesCount );
            with DDPSeries[SeriesInd] do
            begin
              DDSeriesNum := SeriesInd + 1;
              DDSeriesUID := N_StringToAnsi( format( '%s.%s.2.%s', [CentaurSoftwareUID,DBGUID,ObjName]) );
              if (Length(DDSeriesUID) and 1) = 0 then
                DDSeriesUID := DDSeriesUID + '0';
              DDSeriesDate    := N_StringToAnsi(CurSDate);
              DDSeriesTime    := N_StringToAnsi(CurSTime);
{
              Modality := CMSDB.DCMModality;
              if Modality = '' then
              begin
                if not (cmsfGreyScale in CMSDB.SFlags) then
                  Modality := K_CMSlideDefDCMModColorXC
                else
                begin
                  Modality := K_CMSlideDefDCMModXRayIO;
//                  Modality := K_CMSlideDefDCMModXRay;
                  if CMSMediaType = 4 then
                    Modality := K_CMSlideDefDCMModXRayPan;
                end;
              end;
}
{
              else
              if Modality = K_CMSlideDefDCMModXRayCR then
                Modality := K_CMSlideDefDCMModXRayIO;
}
              Modality := K_CMDCMInitSlideModality( Slides[i], not (cmsfGreyScale in CMSDB.SFlags) );
              DDSeriesMod := N_StringToAnsi(Modality);
              SetLength( DDPMedias, 1 );
              DDMediaCount := 1;
              with DDPMedias[0] do
              begin
                DDMediaDate := N_StringToAnsi(CurSDate);
                DDMediaTime := N_StringToAnsi(CurSTime);
                if Modality <> K_CMSlideDefDCMModColorXC then
                begin
                  FVal := Max( 0, CMSDB.DCMKVP );
//                  if FVal = 0 then
//                    FVal := K_CMSlideDefDCMKVP;
                  DDMediaKVP  := N_StringToAnsi(FloatToStr(FVal));

                  IVal := Max( 0, CMSDB.DCMExpTime );
//                  if IVal = 0 then
//                    IVal := K_CMSlideDefDCMExpTime;
                  DDMediaExposureTime := N_StringToAnsi(IntToStr(IVal));

                  IVal := Max( 0, CMSDB.DCMTubeCur );
//                  if IVal = 0 then
//                    IVal := K_CMSlideDefDCMTubeCur;
                  DDMediaTubeCurrent := N_StringToAnsi(IntToStr(IVal));
                end;
                DDMediaUID  := N_StringToAnsi( format( '%s.%s.3.%s', [CentaurSoftwareUID,DBGUID,ObjName]) );
                if (Length(DDMediaUID) and 1) = 0 then
                  DDMediaUID := DDMediaUID + '0';
                DDMediaStationName := N_StringToAnsi( CMSCompIDCreated );
                DDMediaNum := 1;
                AddInds( CurStudyInd, SeriesInd );
                Inc(Result);
              end; // with DDPMedias[0] do
            end; // with DDPSeries[SeriesInd] do
          end; // with DDPStudies[CurStudyInd] do

        end; // with Slides[i], P()^  do
      end; // for i := 0 to High(Slides) do
      DDStudiesCount := StudyInd + 1;
      SetLength( DDPStudies, DDStudiesCount );
    end; // with K_CMEDAccess do
  end; // with ADCMDPatDataArr[0] do
end; // function K_CMCreateDCMDPatData

//**************************************************** K_CMCreateDCMDUDTree ***
// Create DICOMDIR Viewer UDTree by DICOMDIR Patients Data
//
//     Parameters
// AUDRoot - resulting UDTree Root Node
// APPats  - pointer to DICOMDIR Patients Data Array 1-st Item
// APatsCount - number of DICOMDIR Patients Data Array Items
// Result - Returns resulting code
//
function K_CMCreateDCMDUDTree( var AUDRoot : TN_UDBase; APPats: TK_PCMDCMDPatientIn; APatsCount: Integer;
                             APatCheckProc : TK_CMDCMDPatientCheckProc ): Integer;
var
  i1, i2, i3, i4, PatSInd, PatFInd, AllPatCount, AllSlidesCount, ProcSlidesCount : Integer;
  UDPat, UDStudy, UDSeries, UDMedia : TK_UDStringList;
  Surname, FirstName, Middle, Title,
  SPatDOB, SPatDOBY, SPatDOBM, SPatDOBD,
  SDate, SDateY, SDateM, SDateD, STime, STimeH, STimeN, STimeS,
  SPatSex, SPatID, SeriesMod,
  MediaKVP, MediaExposureTime, MediaTubeCurrent, MediaStationName,
  SUID, SID, SFIO, SDOB, MediaFName: string;
  DOBDate : TDate;
  DDMediaKVP  : PAnsiChar;
  PStudies  : TK_PCMDCMDStudyIn;
  PSeries  : TK_PCMDCMDSeriesIn;
  PMedia  : TK_PCMDCMDMediaIn;
  PatienIsAbsentFlag : Boolean;
  CMSPatID : Integer;
  YY,MM,DD,HH,NN,SS  :Integer;
  WStr : string;
  UseAddDICOMAttrs : Boolean;
  UseSelectInstance : Boolean;
  ResCode : Integer;
  PAttrValue : PWideChar;
  StudyDescr, SeriesDescr : string;
  DIBInfo: TN_DIBInfo;
  CurPPats: TK_PCMDCMDPatientIn;

  procedure ParseDateTime();
  var
    IndT : Integer;
  begin
    SDateY := Copy(SDate, 1, 4);
    SDateM := Copy(SDate, 5, 2);
    SDateD := Copy(SDate, 7, 2);

    YY := StrToIntDef(SDateY,-100);
    MM := StrToIntDef(SDateM,-100);
    DD := StrToIntDef(SDateD,-100);
    SDate := '';
    if (YY <> -100) and (YY >= 1899) and
       (MM <> -100) and (MM >= 1) and (MM <= 12) and
       (DD <> -100) and (DD >= 1) and (DD <= 31) then
      SDate := format( '%s/%s/%s', [SDateD, SDateM, SDateY] );

    STimeH := Copy(STime, 1, 2);
    IndT := 3;
    if (Length(STime) > IndT) and
       ((STime[IndT] < '0') or (STime[IndT] > '9')) then Inc(IndT);
    STimeN := Copy(STime, IndT, 2);
    IndT := IndT + 2;
    if (Length(STime) > IndT) and
       ((STime[IndT] < '0') or (STime[IndT] > '9')) then Inc(IndT);
    STimeS := Copy(STime, IndT, 2);

    HH := StrToIntDef(STimeH,-100);
    NN := StrToIntDef(STimeN,-100);
    SS := StrToIntDef(STimeS,-100);
    STime := '';
    if (HH <> -100) and (HH >= 0) and (HH <= 23) and
       (NN <> -100) and (NN >= 0) and (NN <= 59) and
       (SS <> -100) and (SS >= 0) and (SS <= 59) then
      STime := format( '%s:%s:%s', [STimeH, STimeN, STimeS] );
  end; // ParseDateTime();

begin
  Result := 0;
  if AUDRoot = nil then
    AUDRoot :=  TN_UDBase.Create
  else
    AUDRoot.ClearChilds();

// Calculate All Counts number
  AllSlidesCount := 0;
  CurPPats := APPats;
  for i1 := 0 to APatsCount - 1 do
  begin
    with CurPPats^ do
    begin
      PStudies := DDPStudies;
      for i2 := 0 to DDStudiesCount - 1 do
      begin
        with PStudies^ do
        begin
          PSeries := DDPSeries;
          for i3 := 0 to DDSeriesCount - 1 do
          begin
            with PSeries^ do
              AllSlidesCount := AllSlidesCount + DDMediaCount;
            Inc(PSeries);
          end; // for i3 := 0 to DDSeriesCount - 1 do
        end; // with PStudies^ do
        Inc(PStudies);
      end; // for i2 := 0 to DDStudiesCount - 1 do
    end; // with APPats^ do
    Inc( CurPPats );
  end; // for i1 := 0 to APatsCount - 1 do


  ProcSlidesCount := 0;
  ZeroMemory( @DIBInfo, SizeOf(TN_PDIBInfo) );
  DIBInfo.bmi.biSize := SizeOf(DIBInfo.bmi);

  UseAddDICOMAttrs := Assigned( N_ImageLib.ILDCMSelectInstance );
  UseSelectInstance := FALSE;
  ////////////////////////////////////////
  // Create Patient Nodes Loop
  for i1 := 0 to APatsCount - 1 do
  begin
    with APPats^ do
    begin
      Surname := N_WideToString( DDPatSurname );
      FirstName := N_WideToString( DDPatFirstname );
      Middle := N_WideToString( DDPatMiddle );
      Title := N_WideToString( DDPatTitle );

      SPatDOB := N_AnsiToString( DDPatDOB );
      SPatDOBY := Copy(SPatDOB, 1, 4);
      SPatDOBM := Copy(SPatDOB, 5, 2);
      SPatDOBD := Copy(SPatDOB, 7, 2);
      SPatSex := N_AnsiToString( DDPatSex );
//      SPatID := IntToStr(DDPatID);
      SPatID := N_AnsiToString( DDPatID );

      // Check Patient
      YY := StrToIntDef(SPatDOBY,-100);
      MM := StrToIntDef(SPatDOBM,-100);
      DD := StrToIntDef(SPatDOBD,-100);
      DOBDate := 0;
      if (YY <> -100) and (YY >= 1899) and
         (MM <> -100) and (MM >= 1) and (MM <= 12) and
         (DD <> -100) and (DD >= 1) and (DD <= 31) then
        DOBDate := EncodeDate( YY, MM, DD );
      CMSPatID := APatCheckProc( Surname, FirstName, SPatID, DOBDate );
      PatienIsAbsentFlag := CMSPatID = 0;

      UDPat := TK_UDStringList.Create();
      UDPat.ImgInd := 102;
      if PatienIsAbsentFlag then
      begin
        UDPat.ImgInd := 108;
        UDPat.ObjFlags := UDPat.ObjFlags or K_fpObjTVSpecMark1;
      end;

      UDPat.SL.Add( 'Surname=' + Surname );
      UDPat.SL.Add( 'FirstName=' + FirstName );
      UDPat.SL.Add( 'Middle=' + Middle );
      UDPat.SL.Add( 'Title=' + Title );

      UDPat.SL.Add( 'DOB=' + SPatDOB );
      UDPat.SL.Add( 'DOBY=' + SPatDOBY );
      UDPat.SL.Add( 'DOBM=' + SPatDOBM );
      UDPat.SL.Add( 'DOBD=' + SPatDOBD );

      UDPat.SL.Add( 'Sex=' + SPatSex );
      UDPat.SL.Add( 'ID=' + SPatID );

      UDPat.ObjName := IntToStr( i1 );
      UDPat.ObjAliase := format( '%s, %s %s [%s], DOB', [Surname, Title, FirstName, SPatID] );
      if DOBDate <> 0 then
        UDPat.ObjAliase := format( '%s %s/%s/%s', [UDPat.Objaliase, SPatDOBD, SPatDOBM, SPatDOBY] );
      UDPat.ObjDateTime := DOBDate;
      N_Dump2Str( format('K_CMCreateDCMDUDTree >> Patient [%d]'#13#10'%s', [i1, UDPat.SL.Text] ) );

      AUDRoot.AddOneChild( UDPat );
      PStudies := DDPStudies;

      for i2 := 0 to DDStudiesCount - 1 do
      begin
        if UseAddDICOMAttrs then
          StudyDescr := ''
        else
          StudyDescr := '*';
        with PStudies^ do
        begin
          Surname := N_WideToString( DDProvSurname );
          FirstName := N_WideToString( DDProvFirstname );
          Middle := N_WideToString( DDProvMiddle );
          Title := N_WideToString( DDProvTitle );
          SDate := N_AnsiToString( DDStudyDate );
          STime := N_AnsiToString( DDStudyTime );
          ParseDateTime();
//          SDateY := Copy(SDate, 1, 4);
//          SDateM := Copy(SDate, 5, 2);
//          SDateD := Copy(SDate, 7, 2);

//          STimeH := Copy(STime, 1, 2);
//          STimeN := Copy(STime, 3, 2);
//          STimeS := Copy(STime, 5, 2);

          SUID := N_AnsiToString( DDStudyUID );
//          SID  := IntToStr(DDStudyID);
          SID  := N_AnsiToString( DDStudyID );

          UDStudy := TK_UDStringList.Create();
          UDStudy.ImgInd := 36;

          if PatienIsAbsentFlag then
            UDStudy.ObjFlags := UDStudy.ObjFlags or K_fpObjTVDisabled;
{
          UDStudy.SL.Add( 'ProvSurname=' + Surname );
          UDStudy.SL.Add( 'ProvFirstName=' + FirstName );
          UDStudy.SL.Add( 'ProvMiddle=' + Middle );
          UDStudy.SL.Add( 'ProvTitle=' + Title );

          UDStudy.SL.Add( 'Date=' + SDate );
          UDStudy.SL.Add( 'DateY=' + SDateY );
          UDStudy.SL.Add( 'DateM=' + SDateM );
          UDStudy.SL.Add( 'DateD=' + SDateD );

          UDStudy.SL.Add( 'Time=' + STime );
          UDStudy.SL.Add( 'TimeH' + STimeH );
          UDStudy.SL.Add( 'TimeN' + STimeN );
          UDStudy.SL.Add( 'TimeS' + STimeS );

          UDStudy.SL.Add( 'UID=' + SUID );
          UDStudy.SL.Add( 'ID=' + SID );
}
          UDStudy.ObjName := IntToStr( i2 );
{!!!Initial code
          UDStudy.ObjAliase := format( 'Study %s/%s/%s',
                                        [SDateD, SDateM, SDateY] );
          UDStudy.ObjInfo := format( 'Dentist: %s, %s %s '#13#10+
                                     'Study %s/%s/%s %s:%s:%s'#13#10+
                                     'UID %s',
                   [Surname, Title, FirstName,
                    SDateD, SDateM, SDateY, STimeH, STimeN, STimeS,
                    SUID] );
}
          WStr := SID;
          if SID = '' then
            WStr := 'Study ' + SDate;
          UDStudy.ObjAliase := WStr;

          WStr := '';
          if (SDate <> '') or (STime <> '' ) then
          begin
            WStr := WStr + '%s %s';
            if SUID <> '' then
              WStr := ','#13#10 + WStr;
          end;
          WStr := '%s' + WStr;
          UDStudy.ObjInfo := Trim( format( WStr, [SUID, SDate, STime] ) );
          UDPat.AddOneChild( UDStudy );
          N_Dump2Str( 'K_CMCreateDCMDUDTree >> Study >> ' + UDStudy.ObjInfo );

          PSeries := DDPSeries;

          for i3 := 0 to DDSeriesCount - 1 do
          begin
            if UseAddDICOMAttrs then
              SeriesDescr := ''
            else
              SeriesDescr := '*';

            with PSeries^ do
            begin
              SeriesMod := N_AnsiToString( DDSeriesMod );

              SDate := N_AnsiToString( DDSeriesDate );
              STime := N_AnsiToString( DDSeriesTime );
              if (SDate = '') or (STime = '') then
              begin
                DDSeriesDate := DDStudyDate;
                SDate := N_AnsiToString( DDSeriesDate );
                DDSeriesTime := DDStudyTime;
                STime := N_AnsiToString( DDSeriesTime );
              end;

              ParseDateTime();
//              SDateY := Copy(SDate, 1, 4);
//              SDateM := Copy(SDate, 5, 2);
//              SDateD := Copy(SDate, 7, 2);

//              STimeH := Copy(STime, 1, 2);
//              STimeN := Copy(STime, 3, 2);
//              STimeS := Copy(STime, 5, 2);

              SUID := N_AnsiToString( DDSeriesUID );
              SID  := IntToStr(DDSeriesNum);

              UDSeries := TK_UDStringList.Create();
              UDSeries.ImgInd := 30;
              if PatienIsAbsentFlag then
                UDSeries.ObjFlags := UDSeries.ObjFlags or K_fpObjTVDisabled;
{
              UDSeries.SL.Add( 'Modality=' + SeriesMod );

              UDSeries.SL.Add( 'Date=' + SDate );
              UDSeries.SL.Add( 'DateY=' + SDateY );
              UDSeries.SL.Add( 'DateM=' + SDateM );
              UDSeries.SL.Add( 'DateD=' + SDateD );

              UDSeries.SL.Add( 'Time=' + STime );
              UDSeries.SL.Add( 'TimeH' + STimeH );
              UDSeries.SL.Add( 'TimeN' + STimeN );
              UDSeries.SL.Add( 'TimeS' + STimeS );

              UDSeries.SL.Add( 'UID=' + SUID );
              UDSeries.SL.Add( 'Num=' + SID );
}
              UDSeries.ObjName := IntToStr( i3 );
{!!!Initial code
              UDSeries.ObjAliase := format( 'Series %s (%s)',
                                            [SID, SeriesMod] );
              UDSeries.ObjInfo := format('Series %s/%s/%s %s:%s:%s'#13#10+
                                         'Modality %s'#13#10+
                                         'UID %s',
                       [SDateD, SDateM, SDateY, STimeH, STimeN, STimeS,
                        SeriesMod, SUID] );
}
              UDSeries.ObjAliase := format( 'Series %s (%s)',
                                            [SID, SeriesMod] );
              WStr := '%s';
              if SUID <> '' then
                WStr := WStr + ','#13#10;
              WStr := WStr + 'Series %s %s %s';
              UDSeries.ObjInfo := Trim( format( WStr, [SUID, SID, SDate, STime] ) );
              UDStudy.AddOneChild( UDSeries );
              N_Dump2Str( 'K_CMCreateDCMDUDTree >> Series >> ' + UDSeries.ObjInfo );

              PMedia := DDPMedia;
              for i4 := 0 to DDMediaCount - 1 do
              begin
                Inc(ProcSlidesCount);
                N_CM_MainForm.CMMFShowString( format( '%d of %d is done. Please wait ...', [ProcSlidesCount, AllSlidesCount] ) );
                if UseAddDICOMAttrs then
                begin
                  ResCode := N_ImageLib.ILDCMSelectInstance( i1, i2, i3, i4 );
                  UseSelectInstance := ResCode = 0;
                  if not UseSelectInstance then
                    N_Dump1Str( format( 'K_CMCreateDCMDUDTree >> ILDCMSelectInstance [%d,%d,%d,%d] Res=%d', [i1, i2, i3, i4, ResCode] ) );
{
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $8, $70, @PAttrValue );
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $10, $10, @PAttrValue );
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $28, $4, @PAttrValue );

ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $2, $2, @PAttrValue );
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $8, $70, @PAttrValue );
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $70, $8, @PAttrValue );
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $28, $10, @PAttrValue );
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $28, $11, @PAttrValue );
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $10, $28, @PAttrValue );
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $11, $28, @PAttrValue );

ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $28, $4, @PAttrValue );
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $28, $101, @PAttrValue );
ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $08, $16, @PAttrValue );
{}
                end;

                with PMedia^ do
                begin
                  SDate := '';
                  STime := '';
                  if UseSelectInstance then
                  begin
                  // Try Content Date/Time - Main priority
                    ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $8, $23, @PAttrValue );
                    if ResCode = 0 then
                      SDate := N_WideToString( PAttrValue )
                    else if ResCode <> $F then
                      N_Dump1Str( format( 'K_CMCreateDCMDUDTree >> ILDCMSelGetDICOMAttr (8,23) Ind=%d Res=%d', [i4, ResCode] ) );

                    ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $8, $33, @PAttrValue );
                    if ResCode = 0 then
                      STime := N_WideToString( PAttrValue )
                    else if ResCode <> $F then
                      N_Dump1Str( format( 'K_CMCreateDCMDUDTree >> ILDCMSelGetDICOMAttr (8,33) Ind=%d Res=%d', [i4, ResCode] ) );
                  end;

                  if (SDate = '') or (STime = '') then
                  begin
                  // Acquisition Date Time - Next priority
                    SDate := N_AnsiToString( DDMediaDate );
                    STime := N_AnsiToString( DDMediaTime );
                  end;

                  if (SDate = '') or (STime = '') then
                  begin
                  // Use Series Date Time
                    DDMediaDate := DDSeriesDate;
                    SDate := N_AnsiToString( DDMediaDate );
                    DDMediaTime := DDSeriesTime;
                    STime := N_AnsiToString( DDMediaTime );
                    if (SDate = '') or (STime = '') then
                    begin
                    // Use Series Date Time
                      DDMediaDate := DDStudyDate;
                      SDate := N_AnsiToString( DDMediaDate );
                      DDMediaTime := DDStudyTime;
                      STime := N_AnsiToString( DDMediaTime );
                    end;
                  end;

                  ParseDateTime();
//                  SDateY := Copy(SDate, 1, 4);
//                  SDateM := Copy(SDate, 5, 2);
//                  SDateD := Copy(SDate, 7, 2);

//                  STimeH := Copy(STime, 1, 2);
//                  STimeN := Copy(STime, 3, 2);
//                  STimeS := Copy(STime, 5, 2);

                  SUID := N_AnsiToString( DDMediaUID );
//                  SID  := IntToStr(DDMediaNum);
                  SID  := format('%.6d',[DDMediaNum]);

                  MediaKVP := N_AnsiToString( DDMediaKVP );
                  MediaExposureTime := N_AnsiToString( DDMediaExposureTime );
                  MediaTubeCurrent := N_AnsiToString( DDMediaTubeCurrent );
                  MediaStationName := N_AnsiToString( DDMediaStationName );

                  UDMedia := TK_UDStringList.Create();
                  UDMedia.ImgInd := 103;
                  if not PatienIsAbsentFlag  then
                  begin
                    if UseSelectInstance then
                      ResCode := N_ImageLib.ILDCMSelGetDIBInfo( @DIBInfo )
                    else
                      ResCode := N_ImageLib.ILDCMGetDIBInfo( i1, i2, i3, i4, @DIBInfo );

                    if ResCode = 0 then
                      UDMedia.ObjFlags := UDMedia.ObjFlags or K_fpObjTVAutoCheck
                    else
                      N_Dump1Str( format( 'K_CMCreateDCMDUDTree >> ILDCMGetDIBInfo [%d,%d,%d,%d] Res=%d', [i1,i2,i3,i4, ResCode] ) );
                  end;
//                  if PatienIsAbsentFlag then
//                    UDMedia.ObjFlags := UDMedia.ObjFlags or K_fpObjTVDisabled;
                  UDMedia.SL.Add( 'Modality=' + SeriesMod );
                  UDMedia.SL.Add( 'KVP=' + MediaKVP );
                  UDMedia.SL.Add( 'ExposureTime=' + MediaExposureTime );
                  UDMedia.SL.Add( 'TubeCurrent=' + MediaTubeCurrent );
                  UDMedia.SL.Add( 'StationName=' + MediaStationName );

                  UDMedia.SL.Add( 'Date=' + SDate );
                  UDMedia.SL.Add( 'DateY=' + SDateY );
                  UDMedia.SL.Add( 'DateM=' + SDateM );
                  UDMedia.SL.Add( 'DateD=' + SDateD );

                  UDMedia.SL.Add( 'Time=' + STime );
                  UDMedia.SL.Add( 'TimeH=' + STimeH );
                  UDMedia.SL.Add( 'TimeN=' + STimeN );
                  UDMedia.SL.Add( 'TimeS=' + STimeS );
{
                  YY := StrToIntDef(SDateY,-100);
                  MM := StrToIntDef(SDateM,-100);
                  DD := StrToIntDef(SDateD,-100);
                  HH := StrToIntDef(STimeH,-100);
                  NN := StrToIntDef(STimeN,-100);
                  SS := StrToIntDef(STimeS,-100);
                  if (YY <> -100) and (YY >= 1899) and
                     (MM <> -100) and (MM >= 1) and (MM <= 12) and
                     (DD <> -100) and (DD >= 1) and (DD <= 31) and
                     (HH <> -100) and (HH >= 0) and (HH <= 23) and
                     (NN <> -100) and (NN >= 0) and (NN <= 59) and
                     (SS <> -100) and (SS >= 0) and (SS <= 59) then
}
                   if (SDate <> '') and (STime <> '') then
                    UDMedia.ObjDateTime := EncodeDateTime( StrToInt(SDateY), StrToInt(SDateM), StrToInt(SDateD),
                                                           StrToInt(STimeH), StrToInt(STimeN), StrToInt(STimeS), 0 );

                  UDMedia.SL.Add( 'UID=' + SUID );
                  UDMedia.SL.Add( 'Num=' + SID );
                  UDMedia.Marker := CMSPatID;

                  UDMedia.ObjName := 'M'+IntToStr( i4 );
{!!!Initial code
                  UDMedia.ObjAliase := format( 'Image %s (%s)',
                                                [SID, SeriesMod] );
                  UDMedia.ObjInfo := format( 'Image %s/%s/%s %s:%s:%s'#13#10+
                                            'Station %s',
                           [SDateD, SDateM, SDateY, STimeH, STimeN, STimeS,
                            MediaStationName] );
                  if not SameText( SeriesMod, K_CMSlideDefDCMModColorXC ) then
                    UDMedia.ObjInfo := format( '%s'#13#10+
                       'KVP %s, Tube Current %s, Exposure Time %s',
                       [UDMedia.ObjInfo,
                        MediaKVP,MediaTubeCurrent,MediaExposureTime] );
                  UDMedia.ObjInfo := format( '%s'#13#10'UID %s',
                                            [UDMedia.ObjInfo,SUID] );
}
                  UDMedia.ObjAliase := format( 'Image %s (%s)',
                                                [SID, SeriesMod] );
                  WStr := '';
                  if (SDate <> '') or (STime <> '' ) then
                  begin
                    WStr := '%s %s';
                    if SUID <> '' then
                      WStr := ','#13#10 + WStr;
                  end;
                  WStr := '%s' + WStr;
                  UDMedia.ObjInfo := Trim( format( WStr, [SUID, SDate, STime] ) );
                  UDSeries.AddOneChild( UDMedia );

                  /////////////////////////////
                  // Get Additional Attributes
                  if UseSelectInstance then
                  begin
                    // Get File Name
                    ResCode := N_ImageLib.ILDCMSelGetNamedAttr( @(WideString('FileName')[1]), @PAttrValue );
                    if ResCode = 0 then
                    begin
                      MediaFName := N_WideToString( PAttrValue );
                      UDMedia.SL.Add( 'File=' + MediaFName );
                      UDMedia.ObjInfo := UDMedia.ObjInfo + ','#13#10 + N_WideToString( MediaFName )
                    end
                    else if ResCode <> $F then
                      N_Dump1Str( format( 'K_CMCreateDCMDUDTree >> ILDCMSelGetNamedAttr FileName Ind=%d Res=%d', [i4, ResCode] ) );

                     // Get Series Description
                    if SeriesDescr = '' then
                    begin
                      ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $8, $103E, @PAttrValue );
                      if ResCode = 0 then
                        SeriesDescr := N_WideToString( PAttrValue )
                      else if ResCode <> $F then
                        N_Dump1Str( format( 'K_CMCreateDCMDUDTree >> ILDCMSelGetDICOMAttr (8,103E) Ind=%d Res=%d', [i4, ResCode] ) )
                    end;

                    // Get Study Description
                    if StudyDescr = '' then
                    begin
                      ResCode := N_ImageLib.ILDCMSelGetDICOMAttr( $8, $1030, @PAttrValue );
                      if ResCode = 0 then
                        StudyDescr := N_WideToString( PAttrValue )
                      else if ResCode <> $F then
                        N_Dump1Str( format( 'K_CMCreateDCMDUDTree >> ILDCMSelGetDICOMAttr (8,1030) Ind=%d Res=%d', [i4, ResCode] ) )
                    end;
                  end; // if UseSelectInstance then
                  // end of Additional Attributes
                  /////////////////////////////
                end; // with PMedia^ do
                Inc(PMedia);
              end; // for i4 := 0 to DDMediaCount - 1 do

              if SeriesDescr <> '*' then
              begin
                if SeriesDescr <> '' then
                  UDSeries.ObjAliase := format( '%s (%s)',
                                            [SeriesDescr, SeriesMod] );
              end;
            end; // with PSeries^ do
            Inc(PSeries);
          end; // for i3 := 0 to DDSeriesCount - 1 do

          if StudyDescr <> '*' then
          begin
            if StudyDescr <> '' then
              UDStudy.ObjAliase := StudyDescr;
          end;

        end; // with PStudies^ do
        Inc(PStudies);
      end; // for i2 := 0 to DDStudiesCount - 1 do

    end; // with APPats^ do
    Inc( APPats );
  end; // for i1 := 0 to APatsCount - 1 do


end; // function K_CMCreateDCMDUDTree


{*** TK_CMDCMDLib ***}

//***************************************************** TK_CMDCMDLib.Create ***
// DICOMDIR Read/Write Library class constructor
//
constructor TK_CMDCMDLib.Create;
begin
  N_ImageLib.ILInitAll();
//  N_ImageLib.ILDCMSelectInstance := nil;
end; // constructor TK_CMDCMDLib.Create

//************************************************ TK_CMDCMDLib.DDFinImport ***
// Finish open DICOMDIR Import Instance
//
//    Parameters
// Result  - Returns resulting code:
//#F
// -1 - Image Library is not initialized
//  0 - OK
//  1 - fails
//#/F
//
function TK_CMDCMDLib.DDFinImport: Integer;
begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDFinImport >> ImLib is not initialized' );
    Exit;
  end;
  N_Dump2Str( 'ILDCMFinImport >> Start' );
  Result := N_ImageLib.ILDCMFinImport();
  N_Dump1Str( 'ILDCMFinImport >> ResCode=' + IntToStr(Result) );
end; // function TK_CMDCMDLib.DDFinImport

//********************************************* TK_CMDCMDLib.DDGetDIBInfo ***
// Get Image DIB Info given by current open DICOMDIR Read/Write Instance data Indexes
//
//    Parameters
// APatInd    - patient index in opened Read/Write instance data structure
// AStudyInd  - study index in opened Read/Write instance data structure
// ASeriesInd - series index in opened Read/Write instance data structure
// AImageInd  - image index in opened Read/Write instance data structure
// APDIBInfo  - pointer to DIBInfo with Pixels structure description
// Result     - Returns resulting code:
//#F
// -1 - Image Library is not initialized
//  0 - OK
//  1 - fails
//  2 - wrong patient index
//  3 - wrong study index
//  4 - wrong series index
//  5 - wrong instance index
//#/F
//
function TK_CMDCMDLib.DDGetDIBInfo( APatInd, AStudyInd, ASeriesInd, AImageInd: Integer;
                                      APDIBInfo: TN_PDIBInfo ): Integer;
begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDGetDIBInfo >> ImLib is not initialized' );
    Exit;
  end;
  N_Dump2Str( 'ILDCMGetDIBInfo >> Start' );
  ZeroMemory( APDIBInfo, SizeOf(TN_PDIBInfo) );
  APDIBInfo.bmi.biSize := SizeOf(APDIBInfo.bmi);
  Result := N_ImageLib.ILDCMGetDIBInfo( APatInd, AStudyInd, ASeriesInd, AImageInd, APDIBInfo );
  with APDIBInfo.bmi do
    N_Dump2Str( format( 'ILDCMGetDIBInfo >> PatInd=%d StudyInd=%d SerInd=%d ImgInd=%d'#13#10+
                        '%dx%d PixBits=%d', [APatInd, AStudyInd, ASeriesInd, AImageInd,
                        biWidth, biHeight, biBitCount] ) );
  if Result <> 0 then
    N_Dump1Str( 'ILDCMGetDIBInfo >> ResCode=' + IntToStr(Result) );
end; // function TK_CMDCMDLib.DDGetDIBInfo

//******************************************** TK_CMDCMDLib.DDGetSelDIBInfo ***
// Get Image DIB Info by current open DICOMDIR Read/Write Instance data selected
//
//    Parameters
// APDIBInfo  - pointer to DIBInfo with Pixels structure description
// Result     - Returns resulting code:
//#F
// -1 - Image Library is not initialized
//  0 - OK
//  1 - fails
//#/F
//
function TK_CMDCMDLib.DDGetSelDIBInfo(APDIBInfo: TN_PDIBInfo): Integer;
begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDGetSelDIBInfo >> ImLib is not initialized' );
    Exit;
  end;
  N_Dump2Str( 'DDGetSelDIBInfo >> Start' );
  ZeroMemory( APDIBInfo, SizeOf(TN_PDIBInfo) );
  APDIBInfo.bmi.biSize := SizeOf(APDIBInfo.bmi);
  Result := N_ImageLib.ILDCMSelGetDIBInfo( APDIBInfo );
  if Result <> 0 then
    N_Dump1Str( 'DDGetSelDIBInfo >> ResCode=' + IntToStr(Result) )
  else
    with APDIBInfo.bmi do
      N_Dump2Str( format( 'ILDCMSelGetDIBInfo >> %dx%d PixBits=%d', [biWidth, biHeight, biBitCount] ) );
end; // TK_CMDCMDLib.DDGetSelDIBInfo

//********************************************* TK_CMDCMDLib.DDGetDIBPixels ***
// Get Image DIB pixels by current open DICOMDIR Read/Write Instance data Indexes
//
//    Parameters
// APatInd    - patient index in opened Read/Write instance data structure
// AStudyInd  - study index in opened Read/Write instance data structure
// ASeriesInd - series index in opened Read/Write instance data structure
// AImageInd  - image index in opened Read/Write instance data structure
// APPixels   - pointer to Pixels buffer
// APixLength - pixels buffer length
// Result     - Returns resulting code:
//#F
// -1 - Image Library is not initialized
//  0 - OK
//  1 - fails
//  2 - wrong patient index
//  3 - wrong study index
//  4 - wrong series index
//  5 - wrong instance index
//#/F
//
function TK_CMDCMDLib.DDGetDIBPixels( APatInd, AStudyInd, ASeriesInd, AImageInd: Integer;
                                     APPixels: Pointer; APixLength: Integer ): Integer;
begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDGetDIBPixels >> ImLib is not initialized' );
    Exit;
  end;
  N_Dump2Str( 'ILDCMGetPixels >> Start' );
  Result := N_ImageLib.ILDCMGetPixels( APatInd, AStudyInd, ASeriesInd, AImageInd, APPixels, @APixLength );
  if Result <> 0 then
    N_Dump1Str( 'ILDCMGetPixels >> ResCode=' + IntToStr(Result) );
end; // function TK_CMDCMDLib.DDGetDIBPixels

//****************************************** TK_CMDCMDLib.DDGetSelDIBPixels ***
// Get Image DIB pixels given by current open DICOMDIR Read/Write Instance data Selected
//
//    Parameters
// APPixels   - pointer to Pixels buffer
// APixLength - pixels buffer length
// Result     - Returns resulting code:
//#F
// -1 - Image Library is not initialized
//  0 - OK
//  1 - fails
//#/F
//
function TK_CMDCMDLib.DDGetSelDIBPixels(APPixels: Pointer;
  APixLength: Integer): Integer;
begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDGetSelDIBPixels >> ImLib is not initialized' );
    Exit;
  end;
  N_Dump2Str( 'DDGetSelDIBPixels >> Start' );
  Result := N_ImageLib.ILDCMSelGetPixels( APPixels, @APixLength );
  if Result <> 0 then
    N_Dump1Str( 'ILDCMSelGetPixels >> ResCode=' + IntToStr(Result) );
end; // TK_CMDCMDLib.DDGetSelDIBPixels

//*************************************************** TK_CMDCMDLib.DDGetDIB ***
// Get Image Thumbnail DIB by current open DICOMDIR Read/Write Instance data
//
//    Parameters
// APatInd    - patient index in opened Read/Write instance data structure
// AStudyInd  - study index in opened Read/Write instance data structure
// ASeriesInd - series index in opened Read/Write instance data structure
// AImageInd  - image index in opened Read/Write instance data structure
// ADIBObj    - resulting DIBObj
// Result     - Returns resulting code:
//#F
// -3 - out of memory
// -2 - wrong image size
// -1 - Image Library is not initialized
//  0 - OK
//  1 - fails
//  2 - wrong patient index
//  3 - wrong study index
//  4 - wrong series index
//  5 - wrong instance index
//#/F
//
function TK_CMDCMDLib.DDGetDIB( APatInd, AStudyInd, ASeriesInd, AImageInd : Integer;
                          out ADIBObj : TN_DIBObj ) : Integer;
var
  DIBInfo: TN_DIBInfo;
  NeededSize: TPoint;
  BufSize: Integer;
  WDIBObj: TN_DIBObj;
  XLAT: TN_IArray;
  HMem: THandle;
  UseSelected : Boolean;
begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDGetDIB >> ImLib is not initialized' );
    Exit;
  end;

  N_Dump2Str( 'DDGetDIB >> Start' );
//  ZeroMemory( @DIBInfo, SizeOf(DIBInfo) );
//  DIBInfo.bmi.biSize := SizeOf(DIBInfo.bmi);

  UseSelected := FALSE;
  if Assigned(N_ImageLib.ILDCMSelectInstance) then
  begin
    Result := N_ImageLib.ILDCMSelectInstance( APatInd, AStudyInd, ASeriesInd, AImageInd );
    N_Dump2Str( format( 'ILDCMSelectInstance >> PatInd=%d StudyInd=%d SerInd=%d ImgInd=%d',
                        [APatInd, AStudyInd, ASeriesInd, AImageInd] ) );
    if Result <> 0 then
    begin
      N_Dump1Str( 'ILDCMSelectInstance >> ResCode=' + IntToStr(Result) );
      Exit;
    end;
    UseSelected := TRUE;
    Result := DDGetSelDIBInfo( @DIBInfo );
  end
  else
    Result := DDGetDIBInfo( APatInd, AStudyInd, ASeriesInd, AImageInd, @DIBInfo );

  if Result <> 0 then Exit;

  with DIBInfo.bmi do
  begin
    DDLastImageSize := Point( biWidth, abs(biHeight) );

    if (biWidth <= 0) or (biHeight <= 0) then // bad Width or Height
    begin
      N_SL.Clear;
      N_DIBInfoToStrings( @DIBInfo, 'DDGetDIB', N_SL );
      N_Dump1Strings( N_SL );
      Result := -2;
      Exit;
    end;
  end;

  //***** DIBInfo is OK, create WDIBObj and read pixels to it
  WDIBObj := TN_DIBObj.Create();
  try
    WDIBObj.PrepEmptyDIBObj( @DIBInfo, -1, epfAutoAny, 16 );
  except
    Result := -3;
    WDIBObj.Free;
    N_Dump1Str( 'DDGetDIB >> Out of memory 1'  );
    Exit;
  end; // except

  BufSize := WDIBObj.DIBSize.Y * WDIBObj.RRLineSize;

  // Check if there is enough memory for N_ImageLib.ILReadPixels

  HMem := Windows.GlobalAlloc( GMEM_MOVEABLE, BufSize );
  if HMem = 0 then // not enough memory
  begin
    Result := -3;
    WDIBObj.Free;
    N_Dump1Str( 'DDGetDIB >> Out of memory 2'  );
    Exit;
  end else // all OK
    Windows.GlobalFree( HMem );

  if UseSelected then
    Result := DDGetSelDIBPixels( WDIBObj.PRasterBytes, BufSize )
  else
    Result := DDGetDIBPixels( APatInd, AStudyInd, ASeriesInd, AImageInd, WDIBObj.PRasterBytes, BufSize );

  if Result <> 0 then // error
  begin
//    N_Dump1Str( 'DDGetDIBPixels >> Error=' + IntToStr(Result) );
    WDIBObj.Free;
    Exit;
  end;

  //***** Convert WDIBObj to pf24bit ADIBObj if it is paletted

  if (WDIBObj.DIBPixFmt = pf8bit) and (WDIBObj.DIBExPixFmt = epfBMP) then // conv WDIBObj to pf24bit ADIBObj
  begin
    SetLength( XLAT, 256 );
    move( WDIBObj.DIBInfo.PalEntries[0], XLAT[0], 256*SizeOf(Integer) );
    WDIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 3, pf24bit, epfBMP );
    WDIBObj.Free;
  end else // WDIBObj is OK, return it
  begin
    ADIBObj.Free;
    ADIBObj := WDIBObj;
  end;

  //***** Here: ADIBObj is OK and is not Paletted, reduce it if needed

  NeededSize := N_AdjustSizeByMaxArea( DDLastImageSize, K_CMImgMaxPixelsSize );
  if (NeededSize.X < DDLastImageSize.X) or (NeededSize.Y < DDLastImageSize.Y) then // Resample
  begin
    if ADIBObj.DIBExPixFmt = epfGray16 then // temporary convert to pf24bit for drawing
    begin
      WDIBObj := TN_DIBObj.Create();
      try
        WDIBObj.PrepEmptyDIBObj( DDLastImageSize.X, DDLastImageSize.Y, pf24bit );
      except
        Result := -3;
        WDIBObj.Free;
        N_Dump1Str( 'DDGetDIB >> Out of memory 3'  );
        Exit;
      end; // except

      WDIBObj.CopyRectAuto( Point(0,0), ADIBObj, ADIBObj.DIBRect );
      ADIBObj.Free;
      ADIBObj := WDIBObj;
    end; // if ADIBObj.DIBExPixFmt = epfGray16 then // temporary convert to pf24bit for drawing

    // Reduce ADIBObj Size to NeededSize by drawing (by N_StretchRect)

    WDIBObj := TN_DIBObj.Create();
    try
      WDIBObj.PrepEmptyDIBObj( NeededSize.X, NeededSize.Y, pf24bit );
    except
      Result := -3;
      WDIBObj.Free;
      ADIBObj.Free;
      N_Dump1Str( 'DDGetDIB >> Out of memory 4'  );
      Exit;
    end; // except

    N_StretchRect( WDIBObj.DIBOCanv.HMDC, WDIBObj.DIBRect, ADIBObj.DIBOCanv.HMDC, ADIBObj.DIBRect );
    ADIBObj.Free;
    ADIBObj := WDIBObj;

  end; // if (NeededSize.X < RILastImageSize.X) or (NeededSize.Y < RILastImageSize.Y) then // Resample

  Result := 0;
end; // function TK_CMDCMDLib.DDGetDIB

//********************************************** TK_CMDCMDLib.DDGetThumbDIB ***
// Get Image Thumbnail DIB by current open DICOMDIR Read/Write Instance data
//
//    Parameters
// APatInd    - patient index in opened Read/Write instance data structure
// AStudyInd  - study index in opened Read/Write instance data structure
// ASeriesInd - series index in opened Read/Write instance data structure
// AImageInd  - image index in opened Read/Write instance data structure
// AThumbDIB  - resulting thumbnail DIB
// Result     - Returns resulting code
//#F
//  0 - OK
//  1 - Source DIBObj is not assigned
//#/F
//
function TK_CMDCMDLib.DDGetThumbDIB( ADIBObj : TN_DIBObj;
                                     out AThumbDIB : TN_DIBObj ) : Integer;
{
var
  WDIBObj : TN_DIBObj;
  WDIBObj1 : TN_DIBObj;
  NumBits : Integer;
}
begin
  Result := 0;
  AThumbDIB := K_CMBSlideCreateThumbnailDIBByDIBEx( ADIBObj );
  if AThumbDIB = nil then Result := 1;
{
  Result := 1;
  AThumbDIB := nil;
  if ADIBObj = nil then Exit;
  N_Dump2Str( 'DDGetThumbDIB >> Start' );
  WDIBObj := ADIBObj;
  if ADIBObj.DIBExPixFmt = epfGray16 then // conv to Gray8
  begin
    NumBits := ADIBObj.DIBNumBits;
    if ADIBObj.DIBNumBits > 8 then
      ADIBObj.DIBNumBits := 16;
    WDIBObj1 := nil;
    ADIBObj.CalcMaxContrastDIB( WDIBObj1 );
    ADIBObj.DIBNumBits := NumBits; // Restore ADIBObj fields

    WDIBObj := TN_DIBObj.Create( WDIBObj1, WDIBObj1.DIBRect, pfCustom, epfGray8 );
    WDIBObj1.Free;
  end
  else
  if ADIBObj.DIBExPixFmt = epfColor48 then // conv to Color24
    WDIBObj := TN_DIBObj.Create( ADIBObj, WDIBObj.DIBRect, pf24bit, epfBMP );

  AThumbDIB := K_CMBSlideCreateThumbnailDIBByDIB( WDIBObj );
  if WDIBObj <> ADIBObj then WDIBObj.Free;
  Result := 0;
}
end; // function TK_CMDCMDLib.DDGetThumbDIB

//********************************************** TK_CMDCMDLib.DDStartImport ***
// Start DICOMDIR import
//
//    Parameters
// AImportPath - DICOM import folder path
// APPatInfo   - resulting pointer to 1-st Patients Import Data Array item
// APatCount   - number of items in resulting Patients Import Data Array
// Result      - Returns resulting code
//#F
// -1 - Image Library is not initialized
//  0 - OK
//#/F
//
function TK_CMDCMDLib.DDStartImport( AFNames : TStrings;
       out APPatInfo: TK_PCMDCMDPatientIn; out APatCount: Integer ): Integer;
var
  WFNames : array of WideString;
  i : Integer;

begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDStartImport >> ImLib is not initialized' );
    Exit;
  end;

  SetLength( WFNames, AFNames.Count + 1 );
  for i := 0 to AFNames.Count - 1 do
    WFNames[i] := N_StringToWide( AFNames[i] );

  N_Dump2Str( 'ILDCMStartImport >> Start' );
  APatCount := 0;
  Result := N_ImageLib.ILDCMStartImport( @WFNames[0], @APPatInfo, @APatCount );
  N_Dump1Str( format( 'ILDCMStartImport >> PatCount=%d ResCode=%d', [APatCount, Result] ) );
end; // function TK_CMDCMDLib.DDStartImport

//************************************************* TK_CMDCMDLib.DDFinishQR ***
// Finish Query/Retrieve session
//
//    Parameters
// Result  - Returns resulting code:
//#F
// -1 - Image Library is not initialized
//  0 - OK
//  1 - fails
//#/F
//
function TK_CMDCMDLib.DDFinishQR: Integer;
begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDFinishQR >> ImLib is not initialized' );
    Exit;
  end
  else
  if not Assigned( N_ImageLib.ILDCMFinishQR) then
  begin
    N_Dump1Str( 'DDStartQR >> ILDCMFinishQR is not assigned' );
    Exit;
  end;
  N_Dump2Str( 'ILDCMFinishQR >> Start' );
  Result := N_ImageLib.ILDCMFinishQR();
  N_Dump1Str( 'ILDCMFinishQR >> ResCode=' + IntToStr(Result) );

end; // function TK_CMDCMDLib.DDFinishQR

//**************************************************** TK_CMDCMDLib.DDQuery ***
// Quere Patients
//
//    Parameters
// AQueryPars     - Query parameters
// APQueryPatient - pointer to resulting  1-st Patients Query Data Array item
// APatCount      - resulting number of items in Patients Query Data Array
// Result         - Returns resulting code
//#F
// -1 - Image Library is not initialized
//  0 - OK
//  1 - fails if Query/Retrieve session is not opened
//#/F
//
function TK_CMDCMDLib.DDQuery( var AQueryPars: TK_CMDCMQueryPars;
        out APQueryPatient: TK_PCMDCMQPatient; out APatCount: Integer): Integer;
begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDQuery >> ImLib is not initialized' );
    Exit;
  end
  else
  if not Assigned( N_ImageLib.ILDCMQuery) then
  begin
    N_Dump1Str( 'DDStartQR >> ILDCMQuery is not assigned' );
    Exit;
  end;

  N_Dump2Str( 'ILDCMQuery >> Start' );
  APatCount := 0;
  Result := N_ImageLib.ILDCMQuery( @AQueryPars, @APQueryPatient, @APatCount );
  N_Dump1Str( format( 'ILDCMQuery >> PatCount=%d ResCode=%d', [APatCount, Result] ) );
end; // function TK_CMDCMDLib.DDQuery

//************************************************* TK_CMDCMDLib.DDRetrieve ***
// Retrieve selected from quereid data
//
//    Parameters
// APQPatInd    - pointer to 0 element of array of selected indexes in array of
//                Patients queried by DDQuery
// AQPIndsCount - number of elements in array of selected indexes
// APPatInfo    - pointer to resulting 1-st Patients Retrieve Data Array item
// APatCount    - resulting number of items in Patients Retrieve Data Array
// Result       - Returns resulting code
//#F
// -1 - Image Library is not initialized
//  0 - OK
//  1 - fails if Query/Retrieve session is not opened or no Query was done
//  2 - some of given Query Indexes are out of Query range
//#/F
//
function TK_CMDCMDLib.DDRetrieve( APQPatInd: PInteger; AQPIndsCount: Integer;
   out APPatInfo: TK_PCMDCMDPatientIn; out APatCount: Integer ): Integer;
begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDRetrieve >> ImLib is not initialized' );
    Exit;
  end
  else
  if not Assigned( N_ImageLib.ILDCMRetrieve) then
  begin
    N_Dump1Str( 'DDStartQR >> ILDCMRetrieve is not assigned' );
    Exit;
  end;

  N_Dump2Str( 'ILDCMRetrieve >> Start' );
  APatCount := 0;
  Result := N_ImageLib.ILDCMRetrieve( APQPatInd, AQPIndsCount, @APPatInfo, @APatCount );
  N_Dump1Str( format( 'ILDCMRetrieve >> PatCount=%d ResCode=%d', [APatCount, Result] ) );
end; // function TK_CMDCMDLib.DDRetrieve

//************************************************** TK_CMDCMDLib.DDStartQR ***
// Start DICOM Query/Retrieve session
//
//    Parameters
// ADCMServerName - DICOM SCP Server name
// ADCMServerIP   - DICOM SCP Server IP-address
// ADCMServerPort - DICOM SCP Server port number
// AEName         - Application Entity Name
// Result      - Returns resulting code
//#F
// -1 - Image Library is not initialized
//  0 - OK
//  1 - fails: connection to server is not active
//#/F
//
function TK_CMDCMDLib.DDStartQR( const ADCMServerName, ADCMServerIP: string;
               ADCMServerPort: Integer; const AEName: string ): Integer;

var
  ServerName, ServerIP, ClientAEName : AnsiString;
  PServerName, PServerIP, PClientAEName: PAnsiChar;
begin
  Result := -1;
  if N_ImageLib.ILDllHandle = 0 then
  begin
    N_Dump1Str( 'DDStartQR >> ImLib is not initialized' );
    Exit;
  end
  else
  if not Assigned( N_ImageLib.ILDCMStartQR ) then
  begin
    N_Dump1Str( 'DDStartQR >> ILDCMStartQR is not assigned' );
    Exit;
  end;

  N_Dump2Str( 'ILDCMStartQR >> Start' );
  ServerName := N_StringToAnsi(ADCMServerName);
  PServerName := nil;
  if ServerName <> '' then
   PServerName := @ServerName[1];
  ServerIP   := N_StringToAnsi(ADCMServerIP);
  PServerIP := nil;
  if ServerIP <> '' then
    PServerIP := @ServerIP[1];
  ClientAEName := N_StringToAnsi(AEName);
  PClientAEName := nil;
  if ClientAEName <> '' then
    PClientAEName := @ClientAEName[1];
  Result := N_ImageLib.ILDCMStartQR( PServerName, PServerIP,
                                     ADCMServerPort, PClientAEName );
  N_Dump1Str( format( 'ILDCMStartQR >> ResCode=%d', [Result] ) );

end; // function TK_CMDCMDLib.DDStartQR

{*** end of TK_CMDCMDLib ***}

{*** TK_CMDCMDLibEmul ***}

//******************************************* TK_CMDCMDLibEmul.DDGetDIBInfo ***
// Get Image DIB Info by current open DICOMDIR Read/Write Instance data
//
//    Parameters
// APatInd    - patient index in opened Read/Write instance data structure
// AStudyInd  - study index in opened Read/Write instance data structure
// ASeriesInd - series index in opened Read/Write instance data structure
// AImageInd  - image index in opened Read/Write instance data structure
// APDIBInfo  - pointer to DIBInfo with Pixels structure description
//
function TK_CMDCMDLibEmul.DDGetDIBInfo(APatInd, AStudyInd, ASeriesInd,
  AImageInd: Integer; APDIBInfo: TN_PDIBInfo): Integer;
begin
  Result := 0;
end; // function TK_CMDCMDLibEmul.DDGetDIBInfo

//***************************************** TK_CMDCMDLibEmul.DDGetDIBPixels ***
// Get Image DIB pixels by current open DICOMDIR Read/Write Instance data
//
//    Parameters
// APatInd    - patient index in opened Read/Write instance data structure
// AStudyInd  - study index in opened Read/Write instance data structure
// ASeriesInd - series index in opened Read/Write instance data structure
// AImageInd  - image index in opened Read/Write instance data structure
// APPixels   - pointer to Pixels buffer
// APixLength - pixels buffer length
//
function TK_CMDCMDLibEmul.DDGetDIBPixels( APatInd, AStudyInd, ASeriesInd,
  AImageInd: Integer; APPixels: Pointer; APixLength: Integer): Integer;
begin
  Result := 0;
end; // function TK_CMDCMDLibEmul.DDGetDIBPixels

//*********************************************** TK_CMDCMDLibEmul.DDGetDIB ***
// Get Image Thumbnail DIB by current open DICOMDIR Read/Write Instance data
//
//    Parameters
// APatInd    - patient index in opened Read/Write instance data structure
// AStudyInd  - study index in opened Read/Write instance data structure
// ASeriesInd - series index in opened Read/Write instance data structure
// AImageInd  - image index in opened Read/Write instance data structure
// AThumbDIB  - resulting thumbnail DIB
// Result     - Returns resulting code
//
function TK_CMDCMDLibEmul.DDGetDIB( APatInd, AStudyInd, ASeriesInd, AImageInd : Integer;
                          out ADIBObj : TN_DIBObj ) : Integer;
var
  i : Integer;
  SLideID : string;
begin
  Result := 0;
  ADIBObj := nil;
  with DCMDPatDataArr[APatInd].DDPStudies[AStudyInd].DDPSeries[ASeriesInd].DDPMedias[AImageInd] do
  begin
    SLideID := Copy( ExtractFileExt(N_AnsiToString(DDMediaUID)), 2, 30 );
    for i := 0 to High(K_CMCurVisSlidesArray) do
    begin
      if K_CMCurVisSlidesArray[i].ObjName <> SLideID then Continue;
      ADIBObj := TN_DIBObj.Create( K_CMCurVisSlidesArray[i].GetCurrentImage().DIBObj );
      Exit;
    end
  end;
end; // function TK_CMDCMDLibEmul.DDGetDIB

//****************************************** TK_CMDCMDLibEmul.DDStartImport ***
// Start DICOMDIR import
//
//    Parameters
// AImportPath - DICOM import folder path
// APPatInfo   - resulting pointer to 1-st Patients Import Data Array item
// APatCount   - number of items in resulting Patients Import Data Array
// Result      - Returns resulting code
//
function TK_CMDCMDLibEmul.DDStartImport( AFNames : TStrings;
  out APPatInfo: TK_PCMDCMDPatientIn; out APatCount: Integer ): Integer;
begin
  K_CMCreateDCMDPatData( DCMDPatDataArr, TN_PUDCMSlide(K_CMCurVisSlidesArray), Length(K_CMCurVisSlidesArray) );
//  DCMDPatDataArr[0].DDPatSurname := DCMDPatDataArr[0].DDPatSurname + '123';
  SetLength(DCMDPatDataArr,3);
  DCMDPatDataArr[1] := DCMDPatDataArr[0];
  DCMDPatDataArr[1].DDPatSurname := DCMDPatDataArr[0].DDPatSurname + '123';
  DCMDPatDataArr[2] := DCMDPatDataArr[0];
  DCMDPatDataArr[2].DDPatSurname := DCMDPatDataArr[0].DDPatSurname + '456';
  APPatInfo := TK_PCMDCMDPatientIn(DCMDPatDataArr);
  APatCount := Length(DCMDPatDataArr);
  Result := 0;
end; // function TK_CMDCMDLibEmul.DDStartImport

//******************************************** TK_CMDCMDLibEmul.DDFinExport ***
// Finish open DICOMDIR Import Instance
//
//    Parameters
// Result  - Returns resulting code
//
function TK_CMDCMDLibEmul.DDFinImport: Integer;
begin
  Result := 0;
  SetLength(DCMDPatDataArr,0);
end; // function TK_CMDCMDLibEmul.DDFinImport

{*** end of TK_CMDCMDLibEmul ***}

end.
