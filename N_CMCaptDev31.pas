unit N_CMCaptDev31;
// Slida device

// 11.07.18 - first version
// 16.08.18 - open auto, wrk to tmp, settings changed
// 05.09.18 - status changed and 3d test removed
// 25.09.18 - pathes fixed, interface changed
// 01.10.18 - multiple images support
// 03.01.18 - sidexis.sdx ignoring added
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev31F,
  N_CML2F, N_CMCaptDev31aF;

const
  N_CMECD_Intraoral = 'Intraoral';
  N_CMECD_Panoramic = 'Panoramic';
  N_CMECD_Ceph      = 'Ceph';

type TN_CMCDServObj31 = class(TK_CMCDServObj)
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
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCD ServObj31 = class( TK_CMCDServObj )

var
  N_CMCDServObj31: TN_CMCDServObj31;
  CMCaptDev31Form: TN_CMCaptDev31Form;
  N_ImageType: string;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0;

//************************************************* TN_CMCDServObj31 **********

//********************************************** TN_CMCDServObj31.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj25 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj31.CDSInitAll(AGroupName, AProductName: string )
                                                                      : Integer;
begin
  if AProductName = N_CMECD_Intraoral then N_ImageType := '01XI';
  if AProductName = N_CMECD_Panoramic then N_ImageType := '01XP';
  if AProductName = N_CMECD_Ceph then N_ImageType := '01XC';

  CDSErrorStr := '';
  Result := 0;
end; // procedure N_CMCDServObj31.CDSInitAll

//********************************************** TN_CMCDServObj31.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj31.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//**************************************** N_CMCDServObj31.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj31.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
//var
//  ResCode: Integer;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Slida >> CDSCaptureImages begin' );

  if CDSInitAll( APDevProfile^.CMDPGroupName, APDevProfile^.CMDPProductName ) > 0 then
    Exit;

  SetLength(ASlidesArray, 0);
  CMCaptDev31Form          := TN_CMCaptDev31Form.Create(Application);
  CMCaptDev31Form.ThisForm := CMCaptDev31Form;

  with CMCaptDev31Form, APDevProfile^ do
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
end; // procedure N_CMCDServObj31.CDSCaptureImages

//******************************************** TN_CMCDServObj31.StartDriver ***
// Start C++ driver
//
//    Parameters
// FormHandle - CMS Capture or Setup Form's handle
// Result     - True if driver started successfully, else False
//
function TN_CMCDServObj31.StartDriver( FormHandle: Integer ): Boolean;
var
  WrkDir, LogDir, CurDir, FileName, cmd: String;

  PatientName, PatientSurname, DoctorName, PatientCard, PatientDOB,
                                 PatientGender, ImageType, MailslotPath: string;
begin
  Result       := False;
  WrkDir       := K_ExpandFileName( '(#TmpFiles#)' );
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

  //case CMCaptDev31Form.RadioGroup1.ItemIndex of
  //0: ImageType := '01XI';
  //1: ImageType := '01XP';
  //2: ImageType := 'CBXV'; // 3d conebeams x-ray
  //end;
  ImageType := N_ImageType;
  N_Dump1Str( 'Image type = ' + ImageType );

  MailslotPath := CMCaptDev31Form.CMOFMailslotPath;// + CMCaptDev25Form.CMOFMailslotName;
  cmd := '"' + PatientName + '" "' + PatientSurname + '" "' + DoctorName + '" "'
                                      + PatientCard + '" "' + PatientDOB + '" "'
              + PatientGender + '" "' + ImageType + '" "' + MailslotPath + '" "'
                         + IntToStr(CMCaptDev31Form.rgSidexis.ItemIndex) + '" "'
                             + IntToStr(CMCaptDev31Form.CMOFOrderNumber) + '"' ;
  // start driver executable file with command line parameters
  WinExec( @(N_StringToAnsi('"' + FileName + '" ' + cmd )[1]), SW_Normal);
end; // function TN_CMCDServObj31.StartDriver

//********************************************* TN_CMCDServObj31.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// Cmd - command for driver
// Param1 - 1st parameter
// Param2 - 2nd parameter
// Param3 - 3rd parameter
//
procedure TN_CMCDServObj31.SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
begin
end; // procedure SendExtMsg

//***************************************** TN_CMCDServObj31.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj31.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev31aForm;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Slida >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev31aForm.Create( Application );

  // create a setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;

  Form.ShowModal(); // Show Slida setup form
  N_Dump1Str( 'Slida >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj31.CDSSettingsDlg

//************************************* TN_CMCDServObj31.CDSGetGroupDevNames ***
// Get Slida Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj31.CDSGetGroupDevNames( AGroupDevNames: TStrings ):
                                                                        Integer;
begin
  AGroupDevNames.Add( N_CMECD_Intraoral );
  AGroupDevNames.Add( N_CMECD_Panoramic );
  AGroupDevNames.Add( N_CMECD_Ceph );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj31.CDSGetGroupDevNames

// destructor N_CMCDServObj31.Destroy
//
destructor TN_CMCDServObj31.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj31.Destroy

//******************************** TN_CMCDServObj30.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj31.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin

  if AProductName = N_CMECD_Intraoral then
    Result := 39
  else if AProductName = N_CMECD_Panoramic then
    Result := 24
  else if AProductName = N_CMECD_Ceph then
    Result := 27;

end; // function TN_CMCDServObj31.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj31.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj31.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin

  if AProductName = N_CMECD_Intraoral then
    Result := 'IO'
  else if AProductName = N_CMECD_Panoramic then
    Result := 'PX'
  else if AProductName = N_CMECD_Ceph then
    Result := 'DX';

end; // function TN_CMCDServObj31.CDSGetDefaultDevDCMMod

Initialization

// Create and Register Slida Service Object
N_CMCDServObj31 := TN_CMCDServObj31.Create( N_CMECD_Slida_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj31 ) do
begin
  CDSCaption := 'Slida';
  IsGroup := True;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj31 ) do

end.
