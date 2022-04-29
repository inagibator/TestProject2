unit K_CMCaptDevTest;
// TN_CMCDServObj1 (Test Device #1) implementation

interface

uses Classes,
     K_CM0, K_CMCaptDevReg;

type TK_CMCDServObj1 = class (TK_CMCDServObj)
  function  CDSGetGroupDevNames( AGroupDevNames : TStrings ) : Integer; override;
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                              var ASlidesArray : TN_UDCMSArray ); override;
end;

type TK_CMCDServObj2 = class (TK_CMCDServObj)
  function  CDSGetGroupDevNames( AGroupDevNames : TStrings ) : Integer; override;
  function  CDSGetDevCaption( ADevName : string ) : string; override;
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                              var ASlidesArray : TN_UDCMSArray ); override;
end;

type TK_CMCDServObj3 = class (TK_CMCDServObj)
  function  CDSGetGroupDevNames( AGroupDevNames : TStrings ) : Integer; override;
  function  CDSGetDevCaption( ADevName : string ) : string; override;
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                              var ASlidesArray : TN_UDCMSArray ); override;
end;

implementation

uses SysUtils, Dialogs,
  N_Gra2;

{*** TK_CMCDServObj1 ***}

//**************************************** TK_CMCDServObj1.CDSGetGroupDevNames ***
// Get Group Capture Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
//
// Fill given Strings object with Gruop Devices Names.
//
function TK_CMCDServObj1.CDSGetGroupDevNames( AGroupDevNames: TStrings ) : Integer;
begin
  Result := inherited CDSGetGroupDevNames( AGroupDevNames );
  K_CMShowMessageDlg( 'Please close Centaur Media Suite and install device software. Press OK to continue', mtWarning );
{
  Result := 0;
  AGroupDevNames.Add( 'Group Device 1.1' );
  AGroupDevNames.Add( 'Group Device 1.2' );
  AGroupDevNames.Add( 'Group Device 1.3' );
  // Device List Build Delay Emulation
  sleep(5000);
}
end; // procedure TK_CMCDServObj1.CDSGetGroupDevNames

//**************************************** TK_CMCDServObj1.CDSCaptureImages ***
// Get Group Capture Devices Names
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Fill given Strings object with Gruop Devices Names.
//
procedure TK_CMCDServObj1.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                          var ASlidesArray : TN_UDCMSArray );
var
  TestDIBParams: TN_TestDIBParams;
  CurNum : Integer;
  DIB : TN_DIBObj;
begin

  // Device Capturing Process Emulation
  K_CMShowMessageDlg( 'Capturing is in process. Please wait...', mtWarning, [], FALSE, '', 1 );

  N_CreateTestDIB8( 1, @TestDIBParams );
  TestDIBParams.TDPIndsColor  := -1;
  TestDIBParams.TDPWidth      := 500;
  TestDIBParams.TDPHeight     := 500;

  SetLength( ASlidesArray, 3 );

  CurNum := 1;
  TestDIBParams.TDPString := format( 'Captured %d from %s ',
                              [CurNum, APDevProfile.CMDPProductName] );
  DIB := N_CreateTestDIB8( 0, @TestDIBParams );
  ASlidesArray[0] := K_CMSlideCreateFromDeviceDIBObj(
                          DIB, APDevProfile, CurNum, 300 );
  CurNum := 2;
  TestDIBParams.TDPString := format( 'Captured %d from %s ',
                              [CurNum, APDevProfile.CMDPProductName] );
  DIB := N_CreateTestDIB8( 0, @TestDIBParams );
  ASlidesArray[1] := K_CMSlideCreateFromDeviceDIBObj(
                          DIB, APDevProfile, CurNum, 300 );
  CurNum := 3;
  TestDIBParams.TDPString := format( 'Captured %d from %s ',
                              [CurNum, APDevProfile.CMDPProductName] );
  DIB := N_CreateTestDIB8( 0, @TestDIBParams );
  ASlidesArray[2] := K_CMSlideCreateFromDeviceDIBObj(
                          DIB, APDevProfile, CurNum, 300 );
end; // procedure TK_CMCDServObj1.CDSCaptureImages

{*** end of TK_CMCDServObj1 ***}

{*** TK_CMCDServObj2 ***}

//**************************************** TK_CMCDServObj2.CDSCaptureImages ***
// Get Group Capture Devices Names
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Fill given Strings object with Gruop Devices Names.
//
procedure TK_CMCDServObj2.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                          var ASlidesArray : TN_UDCMSArray );
var
  TestDIBParams: TN_TestDIBParams;
  CurNum : Integer;
  DIB : TN_DIBObj;
begin

  // Device Capturing Process Emulation
  K_CMShowMessageDlg( 'Capturing is in process. Please wait...', mtWarning, [], FALSE, '', 1 );

  N_CreateTestDIB8( 1, @TestDIBParams );
  TestDIBParams.TDPIndsColor  := -1;

  SetLength( ASlidesArray, 1 );

  CurNum := 1;
  TestDIBParams.TDPString := format( 'Captured %d from %s ',
                              [CurNum, APDevProfile.CMDPProductName] );
  DIB := N_CreateTestDIB8( 0, @TestDIBParams );
  ASlidesArray[0] := K_CMSlideCreateFromDeviceDIBObj(
                          DIB, APDevProfile, CurNum, 400 );
end; // procedure TK_CMCDServObj2.CDSCaptureImages

//**************************************** TK_CMCDServObj2.CDSGetDevCaption ***
// Get Capture Device Caption by Name
//
//     Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function  TK_CMCDServObj2.CDSGetDevCaption( ADevName : string ) : string;
begin
  Result := 'Product2 Capt';
end; // procedure TK_CMCDServObj2.CDSGetDevCaption

//**************************************** TK_CMCDServObj2.CDSGetGroupDevNames ***
// Get Group Capture Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
//
// Fill given Strings object with Gruop Devices Names.
//
function TK_CMCDServObj2.CDSGetGroupDevNames( AGroupDevNames: TStrings ) : Integer;
begin
  inherited CDSGetGroupDevNames( AGroupDevNames );
  AGroupDevNames.Add( 'Group Device 2.1' );
  Result := AGroupDevNames.Count;
  // Device List Build Delay Emulation
//  sleep(5000);
end; // procedure TK_CMCDServObj2.CDSGetGroupDevNames

{*** end of TK_CMCDServObj2 ***}

{*** TK_CMCDServObj3 ***}

//**************************************** TK_CMCDServObj3.CDSGetGroupDevNames ***
// Get Group Capture Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
//
// Fill given Strings object with Gruop Devices Names.
//
function TK_CMCDServObj3.CDSGetGroupDevNames( AGroupDevNames: TStrings ) : Integer;
begin
  inherited CDSGetGroupDevNames( AGroupDevNames );
  AGroupDevNames.Add( 'Group Device 3.1' );
  AGroupDevNames.Add( 'Group Device 3.2' );
  AGroupDevNames.Add( 'Group Device 3.3' );
  Result := AGroupDevNames.Count;
  // Device List Build Delay Emulation
//  sleep(5000);
end; // procedure TK_CMCDServObj3.CDSGetGroupDevNames

//**************************************** TK_CMCDServObj3.CDSGetDevCaption ***
// Get Capture Device Caption by Name
//
//     Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function  TK_CMCDServObj3.CDSGetDevCaption( ADevName : string ) : string;
begin
  if ADevName = 'Group Device 3.1' then
    Result := 'Group Device 3.1 Capt'
  else
  if ADevName = 'Group Device 3.2' then
    Result := 'Group Device 3.2 Capt'
  else
  if ADevName = 'Group Device 3.3' then
    Result := 'Group Device 3.3 Capt';

end; // procedure TK_CMCDServObj3.CDSGetDevCaption

//**************************************** TK_CMCDServObj3.CDSCaptureImages ***
// Get Group Capture Devices Names
//
//     Parameters
// APDevProfile - pointer to device profile record
// ASlidesArray - captured Slides array
//
// Fill given Strings object with Gruop Devices Names.
//
procedure TK_CMCDServObj3.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                          var ASlidesArray : TN_UDCMSArray );
var
  TestDIBParams: TN_TestDIBParams;
  CurNum : Integer;
  DIB : TN_DIBObj;
begin

  // Device Capturing Process Emulation
  K_CMShowMessageDlg( 'Capturing is in process. Please wait...', mtWarning, [], FALSE, '', 1 );

  N_CreateTestDIB8( 1, @TestDIBParams );
  TestDIBParams.TDPIndsColor  := -1;
  TestDIBParams.TDPWidth      := 500;
  TestDIBParams.TDPHeight     := 400;

  SetLength( ASlidesArray, 2 );

  CurNum := 1;
  TestDIBParams.TDPString := format( 'Captured %d from %s ',
                              [CurNum, APDevProfile.CMDPProductName] );
  DIB := N_CreateTestDIB8( 0, @TestDIBParams );
  ASlidesArray[0] := K_CMSlideCreateFromDeviceDIBObj(
                          DIB, APDevProfile, CurNum, 500 );
  CurNum := 2;
  TestDIBParams.TDPString := format( 'Captured %d from %s ',
                              [CurNum, APDevProfile.CMDPProductName] );
  DIB := N_CreateTestDIB8( 0, @TestDIBParams );
  ASlidesArray[1] := K_CMSlideCreateFromDeviceDIBObj(
                          DIB, APDevProfile, CurNum, 500 );
end; // procedure TK_CMCDServObj3.CDSCaptureImages

{*** end of TK_CMCDServObj3 ***}

Initialization
// Register Product1 Capture Device Object
  with K_CMCDRegisterDeviceObj( TK_CMCDServObj1.Create( 'Product1' ) ) do
  begin
    CDSCaption := CDSCaption + ' devices';
    IsGroup := TRUE;
  end;

// Register Product2 Capture Device Object
  with K_CMCDRegisterDeviceObj( TK_CMCDServObj2.Create( 'Product2' ) ) do
  begin
    CDSCaption := CDSCaption + ' devices';
    IsGroup := TRUE;
  end;

// Register Product3 Capture Device Object
  with K_CMCDRegisterDeviceObj( TK_CMCDServObj3.Create( 'Product3' ) ) do
  begin
    CDSCaption := CDSCaption + ' devices';
    IsGroup := TRUE;
  end;

end.
