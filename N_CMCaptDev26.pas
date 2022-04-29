unit N_CMCaptDev26;
// Morita device

// 29.04.18 - first version
// 27.02.19 - updated closing the device

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev26F,
  N_CML2F, N_CMCaptDev26aF;

type TN_CMCDServObj26 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll(AGroupName, AProductName: string ): Integer;
  function CDSFreeAll(): Integer;

  function CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer; override;
  function StartDriver( FormHandle: Integer; Bit: Boolean ): Boolean;
  procedure SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
  destructor Destroy; override;
end; // end of type TN_CMCD ServObj11 = class( TK_CMCDServObj )

var
  N_CMCDServObj26: TN_CMCDServObj26;
  CMCaptDev26Form: TN_CMCaptDev26Form;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0;

//************************************************* TN_CMCDServObj26 **********

//********************************************** TN_CMCDServObj26.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj25 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj26.CDSInitAll(AGroupName, AProductName: string )
                                                                      : Integer;
begin
  //if AProductName = N_CMECD_ClearVision then Device := 1;

  CDSErrorStr := '';
  Result := 0;
end; // procedure N_CMCDServObj26.CDSInitAll

//********************************************** TN_CMCDServObj26.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj26.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj26.CDSFreeAll

//**************************************** N_CMCDServObj26.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj26.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
//var
//  ResCode: Integer;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Morita >> CDSCaptureImages begin' );

  SetLength(ASlidesArray, 0);
  CMCaptDev26Form          := TN_CMCaptDev26Form.Create(Application);
  CMCaptDev26Form.CMOFThisForm := CMCaptDev26Form;

  with CMCaptDev26Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Morita >> CDSCaptureImages before ShowModal' );

    ShowModal();

    CDSFreeAll();
    N_Dump1Str( 'Morita >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'Morita >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj26.CDSCaptureImages

//******************************************** TN_CMCDServObj26.StartDriver ***
// Start C++ driver
//
//    Parameters
// FormHandle - CMS Capture or Setup Form's handle
// Result     - True if driver started successfully, else False
//
function TN_CMCDServObj26.StartDriver( FormHandle: Integer; Bit: Boolean ): Boolean;
var
  WrkDir, LogDir, CurDir, FileName, cmd: String;
begin
  Result       := False;
  WrkDir       := N_CMV_GetWrkDir();
  LogDir       := N_CMV_GetLogDir();
  CurDir       := ExtractFilePath( ParamStr( 0 ) );
  N_Dump1Str( 'Morita >> Exe directory = "' + CurDir + '"' );
  FileName  := CurDir + 'Morita.exe';

  // wait old driver session closing
  N_CMV_WaitProcess( False, FileName, -1 );

  if not FileExists( FileName ) then // find driver
  begin
    Exit;
  end; // if not FileExists( FileName ) then // find driver

  WrkDir  := StringReplace(WrkDir, '\', '/', [rfReplaceAll, rfIgnoreCase]);

  CreateDir( WrkDir + 'Morita' );

  if not Bit then
    cmd := '"' + WrkDir+'/Morita/Morita_temp.tif' + '" "' + IntToStr( FormHandle ) + '" "' +
                                                       IntToStr( 0 ) + '"'
  else
    cmd := '"' + WrkDir+'/Morita/Morita_temp.bmp' + '" "' + IntToStr( FormHandle ) + '" "' +
                                                       IntToStr( 1 ) + '"';

  // start driver executable file with command line parameters
  Result := N_CMV_CreateProcess( '"' + FileName + '" ' + cmd );

  if not Result then // if driver start fail
  begin
    Exit;
  end; // if not Result then // if driver start fail
end; // function TN_CMCDServObj26.StartDriver

//********************************************* TN_CMCDServObj26.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// Cmd - command for driver
// Param1 - 1st parameter
// Param2 - 2nd parameter
// Param3 - 3rd parameter
//
procedure TN_CMCDServObj26.SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
begin
end; // procedure SendExtMsg

//***************************************** TN_CMCDServObj26.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj26.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev26aForm;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Morita >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev26aForm.Create( Application );

  // create a setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;

  Form.ShowModal(); // Show setup form
  N_Dump1Str( 'Morita >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj26.CDSSettingsDlg

//******************************** TN_CMCDServObj26.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj26.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 17;
end; // function TN_CMCDServObj26.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj26.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj26.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'PX';
end; // function TN_CMCDServObj26.CDSGetDefaultDevDCMMod

//************************************* TN_CMCDServObj26.CDSGetGroupDevNames ***
// Get Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj26.CDSGetGroupDevNames( AGroupDevNames: TStrings ):
                                                                        Integer;
begin
  //AGroupDevNames.Add( N_CMECD_ClearVision );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj26.CDSGetGroupDevNames

// destructor N_CMCDServObj26.Destroy
//
destructor TN_CMCDServObj26.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj26.Destroy

Initialization

// Create and Register Service Object
N_CMCDServObj26 := TN_CMCDServObj26.Create( N_CMECD_Morita_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj26 ) do
begin
  CDSCaption := 'Morita';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj26 ) do

end.
