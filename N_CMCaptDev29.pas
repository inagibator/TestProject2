unit N_CMCaptDev29;
// Morita CBCT 3d device

// 09.07.18 - final version
// 16.08.18 - wrk to tmp, creating patient fixed
// 05.09.18 - status changed and i-ixel installed test added
// 25.09.18 - creating patient changed, saving changed
// 03.10.18 - empty settings check added
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added
// 11.12.18 - closing removed. cms 3d check changed, 2d capture added
// 21.01.19 - ct thumbnail import fixed
// 29.01.19 - mixed 2d/3d slides import
// 25.03.19 - final tested, cms 3d with *.ini handler for 2d images added
// 20.12.19 - dob and gender added, patient id modified

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev29F,
  N_CML2F, N_CMCaptDev29aF;

type TN_CMCDServObj29 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll(AGroupName, AProductName: string ): Integer;
  function CDSFreeAll(): Integer;
  function CDSOpenDev3DViewer( const A3DPathToObj : string ) : Integer; override;

  function CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer; override;
  function StartDriver( FormHandle: Integer; Command: string; UIDNum: string ): Boolean;
  procedure SendExtMsg ( Cmd, Param1, Param2, Param3: Integer );
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;

  destructor Destroy; override;
  function   CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function   CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCD ServObj29 = class( TK_CMCDServObj )

var
  N_CMCDServObj29: TN_CMCDServObj29;
  CMCaptDev29Form: TN_CMCaptDev29Form;

  N_UID, N_Thumbnail, N_Login, N_Password: string; // settings
  N_IsNotOpened: Boolean;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, ShellAPI;

//************************************************************ DeleteFolder ***
// Deletes folder
//
//     Parameters
// FolderName - folder name
//
// Folder need not be empty. Returns true unless error or user abort
//
function DeleteFolder( FolderName: string ): boolean;
var
  r: TshFileOpStruct;
  i: integer;
begin
  FolderName := FolderName + #0#0;
  Result := false;
  i := GetFileAttributes(PChar(folderName));
  if (i = -1) or (i and FILE_ATTRIBUTE_DIRECTORY <> FILE_ATTRIBUTE_DIRECTORY)
                                                                      then EXIT;

  FillChar( r, sizeof(r), 0 );
  r.wFunc  := FO_DELETE;
  r.pFrom  := pChar(folderName);
  r.fFlags := FOF_SILENT or FOF_NOCONFIRMATION or FOF_ALLOWUNDO;

  Result := (ShFileOperation(r) = 0) and not r.fAnyOperationsAborted;
end;


//************************************************* TN_CMCDServObj29 **********

function  TN_CMCDServObj29.CDSOpenDev3DViewer( const A3DPathToObj : string ) : Integer;
begin
  StartDriver(0, '1', A3DPathToObj);
  Result := 0;
end;

//********************************************** TN_CMCDServObj29.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj25 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj29.CDSInitAll(AGroupName, AProductName: string )
                                                                      : Integer;
begin

  CDSErrorStr := '';
  Result := 0;
end; // procedure N_CMCDServObj29.CDSInitAll

//********************************************** TN_CMCDServObj29.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj29.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj29.CDSFreeAll

//**************************************** N_CMCDServObj29.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj29.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
//var
//  ResCode: Integer;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Morita CBCT >> CDSCaptureImages begin' );

  SetLength(ASlidesArray, 0);
  CMCaptDev29Form          := TN_CMCaptDev29Form.Create(Application);
  CMCaptDev29Form.ThisForm := CMCaptDev29Form;

  with CMCaptDev29Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Morita CBCT >> CDSCaptureImages before ShowModal' );

    ShowModal();

    CDSFreeAll();
    N_Dump1Str( 'Morita CBCT >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev29Form, APDevProfile^ do

  N_Dump1Str( 'Morita CBCT >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj29.CDSCaptureImages

//******************************************** TN_CMCDServObj29.StartDriver ***
// Start C++ driver
//
//    Parameters
// FormHandle - CMS Capture or Setup Form's handle
// Result     - True if driver started successfully, else False
//
function TN_CMCDServObj29.StartDriver( FormHandle: Integer; Command: string;
                                                      UIDNum: string ): Boolean;
var
  WrkDir, LogDir, CurDir, FileName, cmd: String;

  PatientName, PatientSurname, PatientCard, UIDTemp, LoginPassword, PatientGender: string;
  DOB:        TDateTime;
  DateBirth:  string;
  Fmt:        TFormatSettings;
begin
  Result       := False;
  WrkDir       := K_ExpandFileName( '(#WrkFiles#)' );
  N_Dump1Str( 'WrkFiles are = ' + WrkDir );
  LogDir       := N_CMV_GetLogDir();
  CurDir       := ExtractFilePath( ParamStr( 0 ) );
  N_Dump1Str( 'Morita CBCT >> Exe directory = "' + CurDir + '"' );
  FileName  := CurDir + 'MoritaCBCT.exe';

  if DirectoryExists(WrkDir + 'Morita') then
    DeleteFolder( WrkDir + 'Morita' );
  CreateDir( WrkDir + 'Morita' );
  N_Dump1Str( 'After creating folder' );

  UIDTemp := UIDNum;
  if ( UIDNum <> '0' ) and ( UIDNum <> '' ) then
  begin

    UIDTemp := Copy( UIDNum, 0, Pos( '/#/', UIDNum) - 1 );
    LoginPassword := Copy( UIDNum, Pos( '/#/', UIDNum ) + 3, Length(UIDNum) );

    //***** get login/password
    N_Login := Copy( LoginPassword, 0,
                                  Pos( '/~/',LoginPassword) - 1 );
    N_Password := Copy( LoginPassword,
                                  Pos( '/~/',LoginPassword ) + 3,
                                  Length(LoginPassword) );

  end
  else
  if ( PProfile.CMDPStrPar2 <> '' ) and ( PProfile.CMDPStrPar2 <> '/~/' ) then
  begin
    //***** get login/password
    N_Login := Copy( PProfile.CMDPStrPar2, 0,
                                  Pos( '/~/',PProfile.CMDPStrPar2) - 1 );
    N_Password := Copy( PProfile.CMDPStrPar2,
                                  Pos( '/~/',PProfile.CMDPStrPar2 ) + 3,
                                  Length(PProfile.CMDPStrPar2) );
  end
  else
    Exit;

  // wait old driver session closing
  N_CMV_WaitProcess( False, FileName, -1 );

  if not FileExists( FileName ) then // find driver
  begin
    Exit;
  end; // if not FileExists( FileName ) then // find driver

  WrkDir  := StringReplace(WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase]);

  PatientName    := K_CMGetPatientDetails( -1, '(#PatientFirstName#)' );
  PatientSurname := K_CMGetPatientDetails( -1, '(#PatientSurname#)' );
  PatientCard    := IntToStr(K_CMEDAccess.CurPatID);
  if K_CMGetPatientDetails( -1, '(#PatientGender#)' ) = 'M' then
    PatientGender := 'male'
  else
    if K_CMGetPatientDetails( -1, '(#PatientGender#)' ) = 'F' then
      PatientGender := 'female'
    else
      PatientGender := '';

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
    DOB := StrToDateTime( '01/01/1900 00:00', Fmt ); // default
  end;
  DateTimeToString( DateBirth, 'yyyymmdd', DOB );

  cmd := '"' + '0' + '" "' + Command + '" "' + PatientCard + '" "' +
                PatientName + '" "' + PatientSurname + '" "' + UIDTemp + '" "' +
                        N_Login + '" "' + N_Password + '" "' + DateBirth + '" "'
                                                         + PatientGender + '"' ;

  // start driver executable file with command line parameters
  WinExec( @(N_StringToAnsi('"' + FileName + '" ' + cmd )[1]), SW_Normal);
end; // function TN_CMCDServObj29.StartDriver

//********************************************* TN_CMCDServObj29.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// Cmd - command for driver
// Param1 - 1st parameter
// Param2 - 2nd parameter
// Param3 - 3rd parameter
//
procedure TN_CMCDServObj29.SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
begin
end; // procedure SendExtMsg

//***************************************** TN_CMCDServObj29.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj29.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev29aForm;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Morita CBCT >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev29aForm.Create( Application );

  // create a setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;

  Form.ShowModal(); // Show setup form
  N_Dump1Str( 'Morita CBCT >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj29.CDSSettingsDlg

//************************************* TN_CMCDServObj29.CDSGetGroupDevNames ***
// Get Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj29.CDSGetGroupDevNames( AGroupDevNames: TStrings ):
                                                                        Integer;
begin
  //AGroupDevNames.Add( N_CMECD_ClearVision );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj29.CDSGetGroupDevNames

// destructor N_CMCDServObj29.Destroy
//
destructor TN_CMCDServObj29.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj29.Destroy

//******************************** TN_CMCDServObj29.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj29.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 42;
end; // function TN_CMCDServObj29.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj29.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj29.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'CT';
end; // function TN_CMCDServObj29.CDSGetDefaultDevDCMMod


Initialization

// Create and Register Service Object
N_CMCDServObj29 := TN_CMCDServObj29.Create( N_CMECD_MoritaCBCT_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj29 ) do
begin
  CDSCaption := 'Morita CBCT';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj29 ) do

end.
