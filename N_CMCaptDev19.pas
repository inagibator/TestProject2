unit N_CMCaptDev19;
// Vatech CBCT device

// 29.04.18 - first version
// 16.08.18 - error with form number fixed, wrk to temp
// 05.09.18 - status change and 3d access test
// 30.11.18 - native viewer added, 3d access test changed
// 04.12.18 - icon for native viewer added
// 11.12.18 - reading the xml error fixed
// 17.12.18 - icons fixed
// 22.12.18 - patient settings fixed
// 03.03.19 - 2d type choosing and 3d implemented
// 20.12.19 - patient id modified
// 01.09.20 - local image saving is implemented
// 18.11.20 - local image saving finilised
// 24.11.20 - hide the capture form
// 10.01.20 - tested saving files to shared folder, implemented hidden capture form

interface

{$IFNDEF VER150} //***** not Delphi 7

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev19F,
  N_CML2F, N_CMCaptDev19aF;

type TN_CMCDServObj19 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll(AGroupName, AProductName: string ): Integer;
  function CDSFreeAll(): Integer;

  function CDSOpenDev3DViewer( const A3DPathToObj : string ) : Integer; override;

  function CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer; override;
  function StartDriver( Path: string; Bit: Boolean ): Boolean;
  procedure SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;

  destructor Destroy; override;
end; // end of type TN_CMCD ServObj11 = class( TK_CMCDServObj )

var
  N_CMCDServObj19: TN_CMCDServObj19;
  CMCaptDev19Form: TN_CMCaptDev19Form;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, IniFiles, ShellAPI;

//************************************************* TN_CMCDServObj19 **********

//*************************************************************** IsInteger ***
// Look if there's an integer value in a string
//
//    Parameters
// S      - String
// Result - True if there's an integer value
//
function IsInteger( const S: String ): Boolean;
var
  X: Double;
  E: Integer;
begin
  Val(S, X, E);
  Result := (E = 0) and (Trunc(X) = X);
end; // function IsInteger( const S: String ): Boolean;

//************************************* TN_CMCDServObj32.CDSOpenDev3DViewer ***
// Algorithm for opening slides via natives Viewers
//
//     Parameters
// A3DPathToObj - Info saved to this slide
// Result       - return 0 if OK
//
function  TN_CMCDServObj19.CDSOpenDev3DViewer( const A3DPathToObj : string ) : Integer;
var
  f:         TextFile;
  WrkDir, BinDir: string; //FPathName: string;
  sr:        TSearchRec;
  //Slide3D: TN_UDCMSlide;
begin
  Result := 0;

  //with K_CMEDAccess do
  //  Slide3D := TN_UDCMSlide( CurSlidesList[CurSlidesList.Count - 1] );
 // FPathName := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( Slide3D ) +
 //                  K_CMSlideGetImg3DFolderName(Slide3D.ObjName );

  N_Dump1Str( 'Opening file with info as = ' + A3DPathToObj );

  WrkDir := K_ExpandFileName( '(#TmpFiles#)' );
  WrkDir := StringReplace( WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase] );
  CreateDir(WrkDir + 'Vatech');
  WrkDir := WrkDir + 'Vatech/open.xml';

  BinDir := K_ExpandFileName( '(#TmpFiles#)' );
  BinDir := StringReplace( WrkDir, 'TmpFiles', 'BinFiles', [rfReplaceAll, rfIgnoreCase] );

  AssignFile (f, WrkDir);
  Rewrite (f);
  WriteLn (f, '<?xml version="1.0" encoding="UTF-8"?>' );
  WriteLn (f, '<E3Protocol version="2.0" locale="en_US">');

  //if IsInteger(K_CMGetPatientDetails( -1, '(#PatientID#)' )) then
  //begin
  //  TempInt := StrToInt(K_CMGetPatientDetails( -1, '(#PatientID#)' ));
  //  TempInt := TempInt + 100;
  //  TempInt := TempInt * (-1);
  //  WriteLn (f, '<Param id="Chart No" value="' + IntToStr(TempInt) + '"/>');
  //end
  //else
    WriteLn (f, '<Param id="Chart No" value="' +
                                       IntToStr(K_CMEDAccess.CurPatID) + '"/>');

  WriteLn (f, '<Caller id="EEEP_0000"/>');
  WriteLn (f, '<Files>' );

  // ***** stating all the files in dir
  N_Dump1Str( 'Total image path is ' + A3DPathToObj );
  if FindFirst(A3DPathToObj + '*.dcm', faAnyFile, sr) = 0 then
  begin
  repeat
    WriteLn (f, '<File path="' + A3DPathToObj + sr.Name + '"/>');
  until FindNext(sr) <> 0;
  FindClose(sr);

  end;

  WriteLn (f, '</Files>');
  WriteLn (f, '<Output path="C:\yourOutputspath\" />');
  WriteLn (f, '</E3Protocol>' );
  CloseFile (f);

  N_Dump1Str( 'Command string is ' + '"' +
              'C:\Program Files\vatech\Ez3D-i\bin\Ez3D-i64.exe' + '" /param:"' +
                                                                  WrkDir + '"');
  // ez3d-i start
  WinExec( @(N_StringToAnsi('"' +
     'C:\Program Files\vatech\Ez3D-i\bin\Ez3D-i64.exe' + '" /param:"' + WrkDir +
                                                       '"')[1]), SW_SHOWNORMAL);
end;

//********************************************* TN_CMCDServObj19.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj25 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj19.CDSInitAll(AGroupName, AProductName: string )
                                                                      : Integer;
begin
  //if AProductName = N_CMECD_ClearVision then Device := 1;

  CDSErrorStr := '';
  Result := 0;
end; // procedure N_CMCDServObj26.CDSInitAll

//********************************************** TN_CMCDServObj19.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj19.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj19.CDSFreeAll

//**************************************** N_CMCDServObj19.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj19.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
//var
//  ResCode: Integer;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Vatech CBCT >> CDSCaptureImages begin' );

  SetLength(ASlidesArray, 0);
  CMCaptDev19Form          := TN_CMCaptDev19Form.Create(Application);
  CMCaptDev19Form.CMOFThisForm := CMCaptDev19Form;

  with CMCaptDev19Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Vatech CBCT >> CDSCaptureImages before ShowModal' );

    ShowModal();

    CDSFreeAll();
    N_Dump1Str( 'Vatech CBCT >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'Vatech CBCT >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj19.CDSCaptureImages

//******************************************** TN_CMCDServObj19.StartDriver ***
// Start C++ driver
//
//    Parameters
// FormHandle - CMS Capture or Setup Form's handle
// Result     - True if driver started successfully, else False
//
function TN_CMCDServObj19.StartDriver( Path: string; Bit: Boolean ): Boolean;
var
  WrkDir, LogDir, CurDir, FileName: String;

//************************************************************ CalculateAge ***
// Calculating age
//
//    Parameters
// Birthday    - Patient's Birthday
// CurrentDate - Today
// Result      - Age
//
function CalculateAge( Birthday, CurrentDate: TDateTime ): Integer;
var
  Month, Day, Year, CurrentYear, CurrentMonth, CurrentDay: Word;
begin
  DecodeDate(Birthday, Year, Month, Day);
  DecodeDate(CurrentDate, CurrentYear, CurrentMonth, CurrentDay);
  if (Year = CurrentYear) and (Month = CurrentMonth) and (Day = CurrentDay) then
  begin
    Result := 0;
  end
  else
  begin
    Result := CurrentYear - Year;
    if (Month > CurrentMonth) then
      Dec(Result)
    else
    begin
      if Month = CurrentMonth then
        if (Day > CurrentDay) then
          Dec(Result);
    end;
  end;
end; // function CalculateAge( Birthday, CurrentDate: TDate ): Integer;

//*************************************************************** IsInteger ***
// Look if there's an integer value in a string
//
//    Parameters
// S      - String
// Result - True if there's an integer value
//
function IsInteger( const S: String ): Boolean;
var
  X: Double;
  E: Integer;
begin
  Val(S, X, E);
  Result := (E = 0) and (Trunc(X) = X);
end; // function IsInteger( const S: String ): Boolean;

//********************************************************* CreateInputFile ***
// Creating Vatech's inis
//
procedure CreateInputFile();
var
  IniFile: TIniFile;
  DOB:     TDateTime;
  DateBirth: string;
  Fmt:     TFormatSettings;
begin
  try

  fmt.ShortDateFormat:='dd/mm/yyyy';
  fmt.DateSeparator  :='/';
  fmt.LongTimeFormat :='hh:nn';
  fmt.TimeSeparator  :=':';

  if K_CMGetPatientDetails( -1, '(#PatientDOB#)' ) <> '' then // if no error in a date
  begin
    DOB := StrToDateTime(K_CMGetPatientDetails( -1, '(#PatientDOB#)' ) +
                                                                ' 00:00', Fmt );
  end
  else
  begin
    DOB := StrToDateTime( '01/01/1980 00:00', Fmt ); // default
  end;
  DateTimeToString( DateBirth, 'yyyymmdd', DOB);

  except
    DOB := StrToDateTime( '01/01/1980 00:00', Fmt ); // just set default
  end;

  IniFile := TIniFile.Create( WrkDir + 'Vatech\PatientInfo.ini' );
  //if K_CMEDAccess.CurPatID < 0 then
  //begin
  //  TempInt := K_CMEDAccess.CurPatID;
  //  TempInt := TempInt + 100;
  //  TempInt := TempInt * (-1);
  //  IniFile.WriteString ( 'PATIENT_INFO', 'CHARTNO', IntToStr(TempInt));
  //end
  //else
    IniFile.WriteString ( 'PATIENT_INFO', 'CHARTNO', IntToStr(K_CMEDAccess.CurPatID) );

  IniFile.WriteString ( 'PATIENT_INFO', 'NAME',
        K_CMGetPatientDetails( -1, '(#PatientFirstName#)^(#PatientSurname#)' ));
  IniFile.WriteString ( 'PATIENT_INFO', 'AGE',
                                            IntToStr(CalculateAge(DOB, Date)) );
  DateTimeToString( DateBirth, 'yyyymmdd', DOB );//Date);

  if K_CMGetPatientDetails( -1, '(#PatientGender#)' ) <> '' then
    IniFile.WriteString ( 'PATIENT_INFO', 'GENDER',
                               K_CMGetPatientDetails( -1, '(#PatientGender#)' ))
  else
    IniFile.WriteString ( 'PATIENT_INFO', 'GENDER', 'O' ); // default

  IniFile.WriteString ( 'PATIENT_INFO', 'BIRTHDAY', DateBirth );

  IniFile.Free;
end;
begin
  Result := False;
  WrkDir := K_ExpandFIleName( '(#TmpFiles#)' );
  LogDir := N_CMV_GetLogDir();
  CurDir := ExtractFilePath( ParamStr( 0 ) );

  FileName  := Path;
  N_Dump1Str( 'Vatech >> Exe directory = ' + FileName );

  CreateDir( WrkDir + 'Vatech' );
  CreateInputFile();

  // wait old driver session closing
  N_CMV_WaitProcess( False, FileName, -1 );

  if not FileExists( FileName ) then // find driver
  begin
    Exit;
  end; // if not FileExists( FileName ) then // find driver

  ShellExecute( 0, 'open', @FileName[1], '-1', nil, SW_SHOWNORMAL );

  Result := True;
end; // function TN_CMCDServObj19.StartDriver

//********************************************* TN_CMCDServObj19.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// Cmd - command for driver
// Param1 - 1st parameter
// Param2 - 2nd parameter
// Param3 - 3rd parameter
//
procedure TN_CMCDServObj19.SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
begin
end; // procedure SendExtMsg

//***************************************** TN_CMCDServObj19.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj19.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev19aForm;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Vatech >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev19aForm.Create( Application );

  // create a setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;

  Form.ShowModal(); // Show Vatech setup form
  N_Dump1Str( 'Vatech >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj19.CDSSettingsDlg

//******************************** TN_CMCDServObj19.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj19.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 42;
end; // function TN_CMCDServObj19.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj19.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj19.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin

  Result := 'CT';

end; // function TN_CMCDServObj19.CDSGetDefaultDevDCMMod

//************************************* TN_CMCDServObj19.CDSGetGroupDevNames ***
// Get Vatech Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj19.CDSGetGroupDevNames( AGroupDevNames: TStrings ):
                                                                        Integer;
begin
  //AGroupDevNames.Add( N_CMECD_ClearVision );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj19.CDSGetGroupDevNames

// destructor N_CMCDServObj19.Destroy
//
destructor TN_CMCDServObj19.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj19.Destroy

Initialization

// Create and Register Vatech Service Object
N_CMCDServObj19 := TN_CMCDServObj19.Create( N_CMECD_VatechCBCT_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj19 ) do
begin
  CDSCaption := 'Vatech CBCT';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj26 ) do

{$ELSE} //************** no code in Delphi 7
implementation
{$ENDIF VER150} //****** no code in Delphi 7

end.
