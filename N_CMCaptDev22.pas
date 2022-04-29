unit N_CMCaptDev22;
// Sirona device

// 17.03.17 - first release
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev22F, N_CML2F,
  N_CMCaptDev22aF;

const
  N_CMECD_Intraoral = 'Intraoral';
  N_CMECD_Panoramic = 'Panoramic';
  N_CMECD_Cephalometr = 'Cephalometr';
  N_CMECD_Transversal = 'Transversal';

type TN_CMCDServObj22 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSDeviceNum: integer;

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll ( AGroupName, AProductName: string ): Integer;
  function CDSFreeAll (): Integer;

  procedure CDSCaptureImages ( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  function  CDSGetGroupDevNames ( AGroupDevNames: TStrings ): Integer;   override;
  procedure CDSSettingsDlg ( APDevProfile: TK_PCMDeviceProfile );       override;

  destructor Destroy; override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCDServObj22 = class( TK_CMCDServObj )


var
  N_CMCDServObj22: TN_CMCDServObj22;
  CMCaptDev22Form: TN_CMCaptDev22Form;

  N_CMECDJWSDX_Initialize:   TN_stdcallIntFuncPtr;
  N_CMECDJWSDX_Uninitialize: TN_stdcallIntFuncPtr;
  N_CMECDJWSDX_Acquire:      TN_stdcallIntFuncInt2Ptr;
  N_CMECDJWSDX_Configure:    TN_stdcallIntFuncInt;

  N_CMECD_Initialize:        TN_cdeclIntFuncVoid;
  N_CMECD_Uninitialize:      TN_cdeclIntFuncVoid;
  N_CMECD_SetType:           TN_cdeclIntFuncInt;
  N_CMECD_Acquire:           TN_cdeclIntFuncIntPtr;
  N_CMECD_SetDoc:            TN_cdeclIntFuncPtr;
  N_CMECD_SetXRayTime:       TN_cdeclIntFuncInt;
  N_CMECD_SetNewPath:        TN_cdeclIntFuncPtr;

  N_CMECD_GetTubeVoltage:    TN_cdeclIntFuncPtr;
  N_CMECD_SetTubeVoltage:    TN_cdeclIntFuncInt;

  N_CMECD_SetPatient:        TN_cdeclIntFunc3Ptr3Int;

  N_ProductName, N_GroupName: string;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0;

//************************************************* TN_CMCDServObj22 **********

//********************************************* TN_CMCDServObj22.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj22 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj22.CDSInitAll( AGroupName, AProductName: string ):
                                                                        Integer;
var
  FuncAnsiName: AnsiString;
  DllFName: string;  // DLL File Name

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    CDSErrorStr := String(FuncAnsiName) + ' not loaded';
    N_Dump1Str( CDSErrorStr );
    Result := 2;
  end; // procedure ReportError(); // local

begin
  N_Dump1Str( 'Start CMCDServObj22.CDSInitAll' );

  if AProductName = N_CMECD_Intraoral  then CDSDeviceNum := 1;
  if AProductName = N_CMECD_Panoramic  then CDSDeviceNum := 2;
  if AProductName = N_CMECD_Cephalometr then CDSDeviceNum := 3;
  if AProductName = N_CMECD_Transversal then CDSDeviceNum := 4;

  if CDSDllHandle <> 0 then // CDSDevInd already initialized
  begin
    CDSFreeAll();
  end; // if CDSDllHandle <> 0 then // CDSDevInd already initialized

  // ***** standart funcs
  //DllFName := 'jwsdx.dll';
  DLLFName := 'Sirona.dll';
  CDSErrorStr := '';
  Result := 0;

  N_Dump1Str( 'Before Windows.LoadLibrary ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );
  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, CDSDllHandle=%X',
                                                    [DllFName,CDSDllHandle] ) );

  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName;
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load EzSensor DLL functions
  FuncAnsiName := 'Initialize';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_Initialize := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_Initialize) then ReportError();

  FuncAnsiName := 'Uninitialize';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_Uninitialize := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_Uninitialize) then ReportError();

  FuncAnsiName := 'SetType';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SetType := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SetType) then ReportError();

  FuncAnsiName := 'Acquire';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_Acquire := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_Acquire) then ReportError();

  FuncAnsiName := 'SetDoc';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SetDoc := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SetDoc) then ReportError();

  FuncAnsiName := 'SetXRayTime';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SetXRayTime := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SetXRayTime) then ReportError();

  FuncAnsiName := 'SetNewPath';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SetNewPath := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SetNewPath) then ReportError();

  FuncAnsiName := 'GetTubeVoltage';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_GetTubeVoltage := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_GetTubeVoltage) then ReportError();

  FuncAnsiName := 'SetTubeVoltage';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SetTubeVoltage := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SetTubeVoltage) then ReportError();

  FuncAnsiName := 'SetPatient';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SetPatient := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SetPatient) then ReportError();


  if Result <> 0 then // some error while loading DLL Entries
  begin
    K_CMShowMessageDlg( Format( 'Failed to initialise %s Errorcode=%d',
                                           [DllFName, Result] ), mtError );
    CDSFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

  N_Dump1Str( 'Sirona >> CDSInitAll end' );
end; // procedure N_CMCDServObj12.CDSInitAll

//********************************************* TN_CMCDServObj22.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj22.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
  //  FreeLibrary( CDSDLLHandle );
    N_Dump2Str( 'After *.dll FreeLibrary' );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//************************************ TN_CMCDServObj22.CDSGetGroupDevNames ***
// Get Sirona Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj22.CDSGetGroupDevNames( AGroupDevNames: TStrings )
                                                                      : Integer;
begin
  AGroupDevNames.Add( N_CMECD_Intraoral );
  AGroupDevNames.Add( N_CMECD_Panoramic );
  AGroupDevNames.Add( N_CMECD_Cephalometr );
  AGroupDevNames.Add( N_CMECD_Transversal );

  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj17.CDSGetGroupDevNames

//**************************************** N_CMCDServObj22.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj22.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Sirona >> CDSCaptureImages begin' );

  N_ProductName := APDevProfile^.CMDPProductName;
  N_GroupName   := APDevProfile^.CMDPGroupName;

  if CDSInitAll( N_GroupName, N_ProductName ) > 0 then // no device driver installed
    Exit;

  SetLength(ASlidesArray, 0);
  CMCaptDev22Form          := TN_CMCaptDev22Form.Create(application);
  CMCaptDev22Form.ThisForm := CMCaptDev22Form;

  with CMCaptDev22Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Sirona >> CDSCaptureImages before ShowModal' );

    CMOFDeviceIndex := CDSDeviceNum;

    ShowModal();

    CDSFreeAll();
    N_Dump1Str( 'Sirona >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'Sirona >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj22.CDSCaptureImages

//***************************************** TN_CMCDServObj22.CDSSettingsDlg ***
// call settings dialog
//
//    Parameters
// APDevProfile - pointer to profile
//
procedure TN_CMCDServObj22.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev22aForm; // Settings form
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Sirona >> CDSSettingsDlg begin' );

  Form := TN_CMCaptDev22aForm.Create( Application );
  // create setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;
  Form.ShowModal(); // Show a setup form

  N_Dump1Str( 'Sirona >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj22.CDSSettingsDlg

//************************************************ TN_CMCDServObj22.Destroy ***
// object destructor
//
//    Parameters
// APDevProfile - pointer to profile
//
destructor TN_CMCDServObj22.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj22.Destroy

//******************************** TN_CMCDServObj22.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj22.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin

  if AProductName = N_CMECD_Intraoral then
    Result := 39
  else if AProductName = N_CMECD_Panoramic then
    Result := 24
  else if AProductName = N_CMECD_Cephalometr then
    Result := 27
  else if AProductName = N_CMECD_Transversal then
    Result := 0;

end; // function TN_CMCDServObj22.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj22.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj22.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'OT';
end; // function TN_CMCDServObj22.CDSGetDefaultDevDCMMod


Initialization

//************************************************* TN_CMCDServObj22.Create ***
// object constructor
//
//    Parameters
// APDevProfile - pointer to profile
//
N_CMCDServObj22 := TN_CMCDServObj22.Create( N_CMECD_Sirona_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj22 ) do
begin
  CDSCaption := 'Sirona';
  IsGroup := True;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj12 ) do

end.
