unit N_CMCaptDev1;
// TN_CMCDServObj1 (Test Device #1) implementation

interface
uses Windows, Classes, Forms,
  K_CM0, K_CMCaptDevReg,
  N_Types;

type TN_CMCDServObj1 = class ( TK_CMCDServObj ) // Test Device #1
  CDSDevInd:    integer; // local Device index (synonim of CMDPProductName)
  CDSDllHandle: HMODULE; // DLL Windows Handle
  CDSErrorStr:   string; // Error message
  CDSErrorInt:  integer; // Error code

  function  CDSInitAll ( AProductName: string ): Integer;
  function  CDSFreeAll (): Integer;

  function  CDSGetGroupDevNames ( AGroupDevNames : TStrings ) : Integer; override;
  procedure CDSCaptureImages    ( APDevProfile: TK_PCMDeviceProfile;
                                  var ASlidesArray : TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;
end; // type TN_CMCDServObj1 = class ( TK_CMCDServObj ) // Test Device #1

var
  N_CMCDServObj1: TN_CMCDServObj1;

implementation

uses SysUtils, Dialogs,
  N_Gra2, N_CM1, N_CMCaptDev6aF;

//**************************************** TN_CMCDServObj1 **********

//********************************************** TN_CMCDServObj1.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj1.CDSInitAll( AProductName: string ) : Integer;
begin

  Result := 0; // initialized OK
end; // procedure TN_CMCDServObj1.CDSInitAll

//********************************************** TN_CMCDServObj1.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj1.CDSFreeAll() : Integer;
begin

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj1.CDSFreeAll

//************************************* TN_CMCDServObj1.CDSGetGroupDevNames ***
// Get Test_Device_1 Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj1.CDSGetGroupDevNames( AGroupDevNames: TStrings ) : Integer;
begin
  AGroupDevNames.Add( 'Test Device 1.1' );
  AGroupDevNames.Add( 'Test Device 1.2' );
  AGroupDevNames.Add( 'Test Device 1.3' );
  Result := AGroupDevNames.Count;
end; // procedure TN_CMCDServObj1.CDSGetGroupDevNames

//**************************************** TN_CMCDServObj1.CDSCaptureImages ***
// Capture Images by Test_Device_1 and fill ASlidesArray by them
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
procedure TN_CMCDServObj1.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                          var ASlidesArray : TN_UDCMSArray );
begin

end; // procedure TN_CMCDServObj1.CDSCaptureImages

//****************************************** TN_CMCDServObj1.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - pointer to device profile record
//
procedure TN_CMCDServObj1.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
begin
  with TN_CMCaptDev6aForm.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    CMOFPDevProfile := APDevProfile;

    ShowModal();
  end; // with TN_CMCaptDev6aForm.Create( Application ) do
end; // procedure TN_CMCDServObj1.CDSSettingsDlg


Initialization
// Create and Register Test Device #1 Service Object
  N_CMCDServObj1 := TN_CMCDServObj1.Create( N_CMECD_TestDev1_Name );
  with K_CMCDRegisterDeviceObj( N_CMCDServObj1 ) do
  begin
    CDSCaption := 'Test device #1';
    IsGroup := TRUE;
    ShowSettingsDlg := True; // Special Settings button is used 
  end;

end.
