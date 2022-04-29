unit N_CMCaptDev24;
// Acteon device

// 31.05.17 - finished
// 17.08.18 - wrk to tmp
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev24F, N_CML2F,
  N_CMCaptDev24aF;

const
  N_CMECD_PSPIX = 'PSPIX';
  N_CMECD_SOPIX = 'SOPIX';

type TN_CMCDServObj24 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  CDSDeviceNum: Integer;

  function CDSInitAll ( AGroupName, AProductName: string ): Integer;
  function CDSFreeAll (): Integer;

  procedure CDSCaptureImages    ( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  function  CDSGetGroupDevNames ( AGroupDevNames: TStrings ): Integer; override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;

  destructor Destroy; override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCDServObj11 = class( TK_CMCDServObj )

var

  N_CMCDServObj24: TN_CMCDServObj24;
  CMCaptDev24Form: TN_CMCaptDev24Form;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0;

//************************************************* TN_CMCDServObj24 **********

//********************************************* TN_CMCDServObj24.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj3 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj24.CDSInitAll( AGroupName, AProductName: string ):
                                                                        Integer;
var
  FuncAnsiName: AnsiString;

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    CDSErrorStr := String(FuncAnsiName) + ' not loaded';
    N_Dump1Str( CDSErrorStr );
    Result := 2;
  end; // procedure ReportError(); // local

begin
  N_Dump1Str( 'Start CMCDServObj24.CDSInitAll' );

  if AProductName = N_CMECD_PSPIX then CDSDeviceNum := 0;
  if AProductName = N_CMECD_SOPIX then CDSDeviceNum := 1;

  if CDSDllHandle <> 0 then // CDSDevInd already initialized
  begin
    CDSFreeAll();
  end; // if CDSDllHandle <> 0 then // CDSDevInd already initialized

  Result := 0;
  N_Dump1Str( 'Acteon >> CDSInitAll end' );
end; // procedure N_CMCDServObj24.CDSInitAll

//***************************************** TN_CMCDServObj14.CDSSettingsDlg ***
// call settings dialog
//
//    Parameters
// APDevProfile - pointer to profile
//
procedure TN_CMCDServObj24.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev24aForm; // Settings form
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Acteon >> CDSSettingsDlg begin' );

  Form := TN_CMCaptDev24aForm.Create( Application );
  // create setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;
  Form.ShowModal(); // Show a setup form

  N_Dump1Str( 'Acteon >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj14.CDSSettingsDlg

//************************************ TN_CMCDServObj17.CDSGetGroupDevNames ***
// Get Acteon Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj24.CDSGetGroupDevNames( AGroupDevNames: TStrings )
                                                                      : Integer;
begin
  AGroupDevNames.Add( N_CMECD_PSPIX );
  AGroupDevNames.Add( N_CMECD_SOPIX );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj17.CDSGetGroupDevNames

//********************************************** TN_CMCDServObj3.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj24.CDSFreeAll(): Integer;
begin
 { if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    N_Dump2Str( 'After EzSensor.dll FreeLibrary' );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then
  }
  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//**************************************** N_CMCDServObj24.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj24.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Acteon >> CDSCaptureImages begin' );

  if CDSInitAll( APDevProfile^.CMDPGroupName, APDevProfile^.CMDPProductName ) > 0 then // no device driver installed
    Exit;

  SetLength(ASlidesArray, 0);
  CMCaptDev24Form          := TN_CMCaptDev24Form.Create(application);
  CMCaptDev24Form.ThisForm := CMCaptDev24Form;

  with CMCaptDev24Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll]
                                                                              );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Acteon >> CDSCaptureImages before ShowModal' );

    CMOFDeviceIndex := CDSDeviceNum;

    ShowModal();
    
    CDSFreeAll();
    N_Dump1Str( 'Acteon >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'Acteon >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj24.CDSCaptureImages

// destructor N_CMCDServObj24.Destroy
//
destructor TN_CMCDServObj24.Destroy();
begin
  CDSFreeAll();
end; // destructor N_CMCDServObj24.Destroy

//******************************** TN_CMCDServObj24.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj24.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin

  if AProductName = N_CMECD_PSPIX then
    Result := 46
  else if AProductName = N_CMECD_SOPIX then
    Result := 37;

end; // function TN_CMCDServObj24.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj24.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj24.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin

  if AProductName = N_CMECD_PSPIX then
    Result := 'IO'
  else if AProductName = N_CMECD_SOPIX then
    Result := 'IO';

end; // function TN_CMCDServObj24.CDSGetDefaultDevDCMMod


Initialization

// Create and Register Service Object
N_CMCDServObj24 := TN_CMCDServObj24.Create( N_CMECD_Acteon_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj24 ) do
begin
  CDSCaption := 'Acteon';
  IsGroup := True;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj24 ) do

end.
