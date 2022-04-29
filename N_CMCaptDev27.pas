unit N_CMCaptDev27;
// RayScan device

// 11.07.18 - first version
// 16.08.18 - new statuses, wrk to temp
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added
// 18.12.19 - PatientID updated
// 20.02.15 - ceph and cr modes added

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev27F,
  N_CML2F, N_CMCaptDev27aF;

type TN_CMCDServObj27 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll(AGroupName, AProductName: string ): Integer;
  function CDSFreeAll(): Integer;

  function CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer; override;
  function StartDriver( Path: string; Bit: Boolean ): Boolean;
  procedure SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;

  destructor Destroy; override;
  function   CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function   CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCD ServObj27 = class( TK_CMCDServObj )

var
  N_CMCDServObj27: TN_CMCDServObj27;
  CMCaptDev27Form: TN_CMCaptDev27Form;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, IniFiles, ShellAPI;

//************************************************* TN_CMCDServObj27 **********

//********************************************* TN_CMCDServObj27.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj25 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj27.CDSInitAll(AGroupName, AProductName: string )
                                                                      : Integer;
begin
  //if AProductName = N_CMECD_ClearVision then Device := 1;

  CDSErrorStr := '';
  Result := 0;
end; // procedure N_CMCDServObj26.CDSInitAll

//********************************************** TN_CMCDServObj27.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj27.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj27.CDSFreeAll

//**************************************** N_CMCDServObj27.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj27.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
//var
//  ResCode: Integer;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'RayScan >> CDSCaptureImages begin' );

  SetLength(ASlidesArray, 0);
  CMCaptDev27Form          := TN_CMCaptDev27Form.Create(Application);
  CMCaptDev27Form.CMOFThisForm := CMCaptDev27Form;

  with CMCaptDev27Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'RayScan >> CDSCaptureImages before ShowModal' );

    ShowModal();
    
    CDSFreeAll();
    N_Dump1Str( 'RayScan >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'RayScan >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj27.CDSCaptureImages

//******************************************** TN_CMCDServObj27.StartDriver ***
// Start C++ driver
//
//    Parameters
// FormHandle - CMS Capture or Setup Form's handle
// Result     - True if driver started successfully, else False
//
function TN_CMCDServObj27.StartDriver( Path: string; Bit: Boolean ): Boolean;
var
  WrkDir, LogDir, CurDir, FileName, cmd: String;

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
// Creating RayScan's xmls
//
procedure CreateInputFile();
var
  DOB:       TDateTime;
  DateBirth: string;
  Fmt:       TFormatSettings;
  f:         TextFile;
  WrkDirInput: string;
begin
  WrkDir := K_ExpandFileName( '(#TmpFiles#)' );
  WrkDir := StringReplace( WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase] );
  CreateDir(WrkDir + 'RayScan');
  WrkDirInput := 'C:/Ray/Ainfo.xml';

  AssignFile (f, WrkDirInput);
  Rewrite (f);
  WriteLn (f, '<?xml version="1.0" encoding="utf-8"?>' );
  WriteLn (f, '<RAYSCAN>');
  WriteLn (f, '<PatientInfo>');

  //if IsInteger(K_CMGetPatientDetails( -1, '(#PatientID#)' )) then
  //begin
  //  TempInt := StrToInt(K_CMGetPatientDetails( -1, '(#PatientID#)' ));
  //  TempInt := TempInt + 100;
  //  TempInt := TempInt * (-1);
  //  WriteLn (f, '<ID value="' + IntToStr(TempInt) + '"/>');
 // end
  //else
    WriteLn (f, '<ID value="' + IntToStr(K_CMEDAccess.CurPatID) + '"/>');

  WriteLn (f, '<Name value="' + K_CMGetPatientDetails( -1, '(#PatientFirstName#) (#PatientSurname#)' ) + '"/>' );

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
  DateTimeToString( DateBirth, 'yyyy-mm-dd', DOB);
  WriteLn (f, '<Birthday value="' + DateBirth + '"/>');

  if K_CMGetPatientDetails( -1, '(#PatientGender#)' ) <> '' then
    WriteLn (f, '<Sex value="' + K_CMGetPatientDetails( -1, '(#PatientGender#)' ) + '"/>')
  else
    WriteLn (f, '<Sex value="O"/>'); // default

  WriteLn (f, '</PatientInfo>');
  WriteLn (f, '<AcquisitionInfo>');

  with CMCaptDev27Form do
  begin
  if (CMOFPProfile.CMDPStrPar2 = '0') or (CMOFPProfile.CMDPStrPar2 = '') then
    WriteLn (f, '<Modality value="PANO"/>');
  if CMOFPProfile.CMDPStrPar2 = '1' then
    WriteLn (f, '<Modality value="CEPH"/>');
   if CMOFPProfile.CMDPStrPar2 = '2' then
    WriteLn (f, '<Modality value="CR"/>');
  end;

  WriteLn (f, '<OutPath value="C:\Ray\ImageOutput.xml"/>');
  WriteLn (f, '<ImageFormat value="BMP"/>');
  WriteLn (f, '<VisiblePatientInfo value="True"/>');
  WriteLn (f, '<Shutdown value="True"/>');
  WriteLn (f, '</AcquisitionInfo>');
  WriteLn (f, '</RAYSCAN>');
  CloseFile (f);
end;
begin
  Result := False;
  WrkDir := K_ExpandFileName( '(#TmpFiles#)' );
  LogDir := N_CMV_GetLogDir();
  CurDir := ExtractFilePath( ParamStr( 0 ) );

  FileName  := Path;
  N_Dump1Str( 'RayScan >> Exe directory = ' + FileName );

  CreateInputFile();

  // wait old driver session closing
  N_CMV_WaitProcess( False, FileName, -1 );

  if not FileExists( FileName ) then // find driver
  begin
    Exit;
  end; // if not FileExists( FileName ) then // find driver

  cmd := '"' + 'C:/Ray/Ainfo.xml' + '"' ;
  // start driver executable file with command line parameters
  WinExec( @(N_StringToAnsi('"' + FileName + '" ' + cmd )[1]), SW_Normal);
  Result := True;
end; // function TN_CMCDServObj27.StartDriver

//********************************************* TN_CMCDServObj27.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// Cmd - command for driver
// Param1 - 1st parameter
// Param2 - 2nd parameter
// Param3 - 3rd parameter
//
procedure TN_CMCDServObj27.SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
begin
end; // procedure SendExtMsg

//***************************************** TN_CMCDServObj27.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj27.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev27aForm;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'RayScan >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev27aForm.Create( Application );

  // create a setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;

  Form.ShowModal(); // Show RayScan setup form
  N_Dump1Str( 'RayScan >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj27.CDSSettingsDlg

//************************************* TN_CMCDServObj27.CDSGetGroupDevNames ***
// Get Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj27.CDSGetGroupDevNames( AGroupDevNames: TStrings ):
                                                                        Integer;
begin
  //AGroupDevNames.Add( N_CMECD_ClearVision );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj27.CDSGetGroupDevNames

// destructor N_CMCDServObj27.Destroy
//
destructor TN_CMCDServObj27.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj27.Destroy

//******************************** TN_CMCDServObj27.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj27.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 32;
end; // function TN_CMCDServObj27.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj27.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj27.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'DX';
end; // function TN_CMCDServObj27.CDSGetDefaultDevDCMMod


Initialization

// Create and Register RayScan Service Object
N_CMCDServObj27 := TN_CMCDServObj27.Create( N_CMECD_RayScan_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj27 ) do
begin
  CDSCaption := 'RayScan';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj27 ) do

end.
