unit N_CMCaptDev25;
// Slida CBCT device

// 16.10.17 - 3d added
// 22.01.18 - final version
// 13.02.18 - order number in shared storage
// 16.08.18 - open auto, wrk to tmp, settings changed
// 05.09.18 - status changed
// 25.09.18 - pathes fixed, interface changed
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev25F,
  N_CML2F, N_CMCaptDev25aF;

type TN_CMCDServObj25 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll(AGroupName, AProductName: string ): Integer;
  function CDSFreeAll(): Integer;

  function CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer; override;
  function StartDriver( FormHandle: Integer ): Boolean;
  procedure SendExtMsg ( Cmd, Param1, Param2, Param3: Integer );
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;

  destructor Destroy; override;
  function   CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function   CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCD ServObj25 = class( TK_CMCDServObj )

var
  N_CMCDServObj25: TN_CMCDServObj25;
  CMCaptDev25Form: TN_CMCaptDev25Form;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0;

//************************************************* TN_CMCDServObj25 **********

//********************************************** TN_CMCDServObj25.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj25 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj25.CDSInitAll(AGroupName, AProductName: string )
                                                                      : Integer;
begin
  //if AProductName = N_CMECD_ClearVision then Device := 1;

  CDSErrorStr := '';
  Result := 0;
end; // procedure N_CMCDServObj25.CDSInitAll

//********************************************** TN_CMCDServObj25.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj25.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//**************************************** N_CMCDServObj25.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj25.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
//var
//  ResCode: Integer;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Slida >> CDSCaptureImages begin' );

  SetLength(ASlidesArray, 0);
  CMCaptDev25Form          := TN_CMCaptDev25Form.Create(Application);
  CMCaptDev25Form.ThisForm := CMCaptDev25Form;

  with CMCaptDev25Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Slida >> CDSCaptureImages before ShowModal' );

    ShowModal();
    
    CDSFreeAll();
    N_Dump1Str( 'Slida >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'Slida >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj25.CDSCaptureImages

//******************************************** TN_CMCDServObj25.StartDriver ***
// Start C++ driver
//
//    Parameters
// FormHandle - CMS Capture or Setup Form's handle
// Result     - True if driver started successfully, else False
//
function TN_CMCDServObj25.StartDriver( FormHandle: Integer ): Boolean;
var
  WrkDir, LogDir, CurDir, FileName, cmd: String;

  PatientName, PatientSurname, DoctorName, PatientCard, PatientDOB,
                                 PatientGender, ImageType, MailslotPath: string;
begin
  Result       := False;
  //WrkDir       := N_CMV_GetWrkDir();
  WrkDir := K_ExpandFileName( '(#TmpFiles#)' );
  LogDir       := N_CMV_GetLogDir();
  CurDir       := ExtractFilePath( ParamStr( 0 ) );
  N_Dump1Str( 'Slida >> Exe directory = "' + CurDir + '"' );
  FileName  := CurDir + 'SLIDA.exe';

  // wait old driver session closing
  N_CMV_WaitProcess( False, FileName, -1 );

  if not FileExists( FileName ) then // find driver
  begin
    Exit;
  end; // if not FileExists( FileName ) then // find driver

  WrkDir  := StringReplace(WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase]);

  PatientName    := K_CMGetPatientDetails( -1, '(#PatientFirstName#)' );
  PatientSurname := K_CMGetPatientDetails( -1, '(#PatientSurname#)' );
  DoctorName     := K_CMGetProviderDetails( -1, '(#ProviderSurname#)' );
  PatientCard    := K_CMGetPatientDetails( -1, '(#PatientCardNumber#)' );
  PatientDOB     := K_CMGetPatientDetails( -1, '(#PatientDOB#)' );
  PatientDOB     := StringReplace(PatientDOB, '/', '.', [rfReplaceAll,
                                                                 rfIgnoreCase]);
  PatientGender  := K_CMGetPatientDetails( -1, '(#PatientGender#)' );

  case CMCaptDev25Form.RadioGroup1.ItemIndex of
  0: ImageType := '01XI';
  1: ImageType := '01XP';
  2: ImageType := 'CBXV'; // 3d conebeams x-ray
  end;

  MailslotPath := CMCaptDev25Form.CMOFMailslotPath;// + CMCaptDev25Form.CMOFMailslotName;
  N_Dump1Str( 'Mailslot = ' + MailslotPath );
  cmd := '"' + PatientName + '" "' + PatientSurname + '" "' + DoctorName + '" "'
                                      + PatientCard + '" "' + PatientDOB + '" "'
              + PatientGender + '" "' + ImageType + '" "' + MailslotPath + '" "'
                         + IntToStr(CMCaptDev25Form.rgSidexis.ItemIndex) + '" "'
                             + IntToStr(CMCaptDev25Form.CMOFOrderNumber) + '"' ;
  // start driver executable file with command line parameters
  WinExec( @(N_StringToAnsi('"' + FileName + '" ' + cmd )[1]), SW_Normal);
end; // function TN_CMCDServObj25.StartDriver

//********************************************* TN_CMCDServObj25.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// Cmd - command for driver
// Param1 - 1st parameter
// Param2 - 2nd parameter
// Param3 - 3rd parameter
//
procedure TN_CMCDServObj25.SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
begin
end; // procedure SendExtMsg

//***************************************** TN_CMCDServObj25.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj25.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev25aForm;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Slida >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev25aForm.Create( Application );

  // create a setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;

  Form.ShowModal(); // Show Slida setup form
  N_Dump1Str( 'Slida >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj25.CDSSettingsDlg

//************************************* TN_CMCDServObj25.CDSGetGroupDevNames ***
// Get Slida Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj25.CDSGetGroupDevNames( AGroupDevNames: TStrings ):
                                                                        Integer;
begin
  //AGroupDevNames.Add( N_CMECD_ClearVision );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj25.CDSGetGroupDevNames

// destructor N_CMCDServObj25.Destroy
//
destructor TN_CMCDServObj25.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj25.Destroy

//******************************** TN_CMCDServObj25.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj25.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 42;
end; // function TN_CMCDServObj25.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj25.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj25.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'CT';
end; // function TN_CMCDServObj25.CDSGetDefaultDevDCMMod


Initialization

// Create and Register Slida Service Object
N_CMCDServObj25 := TN_CMCDServObj25.Create( N_CMECD_SlidaCBCT_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj25 ) do
begin
  CDSCaption := 'Slida CBCT';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj25 ) do

end.
