unit N_CMCaptDev30;
// Vatech device

// 29.04.18 - first version
// 16.08.18 - error with form number fixed, wrk to temp
// 05.08.18 - status changed
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added
// 22.12.18 - patient settings fixed
// 03.03.19 - 2d type choosing and 3d implemented
// 27.05.19 - hints fixed
// 20.12.19 - patient id modified
// 24.11.20 - hide the capture form

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev30F,
  N_CML2F, N_CMCaptDev30aF;

type TN_CMCDServObj30 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll(AGroupName, AProductName: string ): Integer;
  function CDSFreeAll(): Integer;

  function CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer; override;
  function StartDriver( Path: string; Bit: Boolean; Mode: Integer ): Boolean;
  procedure SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;
  function CDSOpenDev3DViewer( const A3DPathToObj : string ) : Integer; override;

  destructor Destroy; override;
  function   CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function   CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCD ServObj30 = class( TK_CMCDServObj )

var
  N_CMCDServObj30: TN_CMCDServObj30;
  CMCaptDev30Form: TN_CMCaptDev30Form;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, IniFiles, ShellAPI;

//************************************************* TN_CMCDServObj30 **********

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

//************************************* TN_CMCDServObj30.CDSOpenDev3DViewer ***
// Algorithm for opening slides via natives Viewers
//
//     Parameters
// A3DPathToObj - Info saved to this slide
// Result       - return 0 if OK
//
function  TN_CMCDServObj30.CDSOpenDev3DViewer( const A3DPathToObj : string ) : Integer;
var
  f:         TextFile;
  WrkDir, BinDir: string;
  sr:        TSearchRec;
begin
  Result := 0;
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

//********************************************* TN_CMCDServObj30.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj25 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj30.CDSInitAll(AGroupName, AProductName: string )
                                                                      : Integer;
begin
  //if AProductName = N_CMECD_ClearVision then Device := 1;

  CDSErrorStr := '';
  Result := 0;
end; // procedure N_CMCDServObj26.CDSInitAll

//********************************************** TN_CMCDServObj30.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj30.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj30.CDSFreeAll

//**************************************** N_CMCDServObj30.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj30.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
//var
//  ResCode: Integer;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Vatech >> CDSCaptureImages begin' );

  SetLength(ASlidesArray, 0);
  CMCaptDev30Form          := TN_CMCaptDev30Form.Create(Application);
  CMCaptDev30Form.CMOFThisForm := CMCaptDev30Form;

  with CMCaptDev30Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Vatech >> CDSCaptureImages before ShowModal' );

    ShowModal();
    
    CDSFreeAll();
    N_Dump1Str( 'Vatech >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'Vatech >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj30.CDSCaptureImages

//******************************************** TN_CMCDServObj30.StartDriver ***
// Start C++ driver
//
//    Parameters
// FormHandle - CMS Capture or Setup Form's handle
// Result     - True if driver started successfully, else False
//
function TN_CMCDServObj30.StartDriver( Path: string; Bit: Boolean; Mode: Integer ): Boolean;
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
  //if IsInteger(K_CMGetPatientDetails( -1, '(#PatientID#)' )) then
  //begin
  //  TempInt := StrToInt(K_CMGetPatientDetails( -1, '(#PatientID#)' ));
    //TempInt := TempInt + 100;
    //TempInt := TempInt * (-1);
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
  WrkDir := K_ExpandFileName( '(#TmpFiles#)' );
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

//  ShellExecute(0, 'open', @N_StringToWide(FileName)[1], nil, nil, SW_SHOWNORMAL);
  if Mode = 0 then
    ShellExecute(0, 'open', @FileName[1], '-2', nil, SW_SHOWNORMAL);
  if Mode = 1 then
    ShellExecute(0, 'open', @FileName[1], '-4', nil, SW_SHOWNORMAL);

  Result := True;
end; // function TN_CMCDServObj30.StartDriver

//********************************************* TN_CMCDServObj30.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// Cmd - command for driver
// Param1 - 1st parameter
// Param2 - 2nd parameter
// Param3 - 3rd parameter
//
procedure TN_CMCDServObj30.SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
begin
end; // procedure SendExtMsg

//***************************************** TN_CMCDServObj30.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj30.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev30aForm;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Vatech >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev30aForm.Create( Application );

  // create a setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;

  Form.ShowModal(); // Show Vatech setup form
  N_Dump1Str( 'Vatech >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj30.CDSSettingsDlg

//************************************* TN_CMCDServObj30.CDSGetGroupDevNames ***
// Get Vatech Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj30.CDSGetGroupDevNames( AGroupDevNames: TStrings ):
                                                                        Integer;
begin
  //AGroupDevNames.Add( N_CMECD_ClearVision );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj30.CDSGetGroupDevNames

// destructor N_CMCDServObj30.Destroy
//
destructor TN_CMCDServObj30.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj30.Destroy

//******************************** TN_CMCDServObj30.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj30.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 32;
end; // function TN_CMCDServObj30.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj30.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj30.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'DX';
end; // function TN_CMCDServObj30.CDSGetDefaultDevDCMMod


Initialization

// Create and Register Vatech Service Object
N_CMCDServObj30 := TN_CMCDServObj30.Create( N_CMECD_Vatech_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj30 ) do
begin
  CDSCaption := 'Vatech';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj26 ) do

end.
