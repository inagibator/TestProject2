unit N_CMCaptDev23S;
// Owandy device

// 20.12.16 - finished
// 16.10.17 - dll path changed to a full one, couldn't be seen from d4w
// 17.08.18 - wrk to tmp
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CML2F,
  N_CMCaptDev23aF;

type TN_CMCDServObj23 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll(): Integer;
  function CDSFreeAll(): Integer;

  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  function  CDSStartCaptureToStudy( APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState; override;
  procedure CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile ); override;

  destructor Destroy; override;
  function  CDSGetDefaultDevIconInd( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;

private

  BufSlidesArray: TN_UDCMSArray;
  function  FCapturePrepare( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ) : Integer;
end; // end of type TN_CMCDServObj11 = class( TK_CMCDServObj )

var
  N_CMECD_SensorOpen: TN_cdeclIntFuncVoid;
  N_CMECD_SensorClose: TN_cdeclIntFuncVoid;
  N_CMECD_SensorIsImageAvailable: TN_cdeclIntFuncVoid;
  N_CMECD_SensorGetSensorState: TN_cdeclIntFuncVoid;
  N_CMECD_SensorGetDIB: TN_cdeclPtrFuncVoid;
  N_CMECD_SensorGetExpoLevel: TN_cdeclByteFuncVoid;
  N_CMECD_SensorShowConfigDialog: TN_cdeclIntFuncVoid;
  N_CMECD_SensorSaveTiff: TN_cdeclIntFunc2Ptr;
  N_CMECD_SensorSet16BitMode: TN_cdeclIntFuncInt;

  N_CMCDServObj23: TN_CMCDServObj23;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, N_CMCaptDev23SF;

var
  CaptForm: TN_CMCaptDev23Form;

//************************************************* TN_CMCDServObj23 **********

//********************************************* TN_CMCDServObj23.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj3 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj23.CDSInitAll() : Integer;
var
  FuncAnsiName: AnsiString;
  DllFName, CurDir: string;  // DLL File Name

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    CDSErrorStr := String(FuncAnsiName) + ' not loaded';
    N_Dump1Str( CDSErrorStr );
    Result := 2;
  end; // procedure ReportError(); // local

begin
  N_Dump1Str( 'Start CMCDServObj23.CDSInitAll' );

  if CDSDllHandle <> 0 then // CDSDevInd already initialized
  begin
    CDSFreeAll();
  end; // if CDSDllHandle <> 0 then // CDSDevInd already initialized

  CurDir := ExtractFilePath( ParamStr( 0 ) );
  DllFName := CurDir + 'Owandy.dll';

  if not FileExists( DllFName ) then
  begin
    CDSErrorStr := DllFName + ' is absent.';
    Result := 10; // dll is absent
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end;

  CDSErrorStr := '';
  Result := 0;

  N_Dump1Str( 'Before Windows.LoadLibrary ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );
  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, CDSDllHandle=%X : %s',
                [DllFName, CDSDllHandle, SysErrorMessage( GetLastError() )] ) );

  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName;
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load EzSensor DLL functions

  FuncAnsiName := 'SensorOpen';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SensorOpen := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SensorOpen) then ReportError();

  FuncAnsiName := 'SensorClose';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SensorClose := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SensorClose) then ReportError();

  FuncAnsiName := 'SensorIsImageAvailable';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SensorIsImageAvailable := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SensorIsImageAvailable) then ReportError();

  FuncAnsiName := 'SensorGetSensorState';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SensorGetSensorState := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SensorGetSensorState) then ReportError();

  FuncAnsiName := 'SensorGetDIB';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SensorGetDIB := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SensorGetDIB) then ReportError();

  FuncAnsiName := 'SensorGetExpoLevel';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SensorGetExpoLevel := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SensorGetExpoLevel) then ReportError();

  FuncAnsiName := 'SensorShowConfigDialog';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SensorShowConfigDialog := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SensorShowConfigDialog) then ReportError();

  FuncAnsiName := 'SensorSaveTiff';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SensorSaveTiff := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SensorSaveTiff) then ReportError();

  FuncAnsiName := 'SensorSet16BitMode';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECD_SensorSet16BitMode := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECD_SensorSet16BitMode) then ReportError();

  if Result <> 0 then // some error while loading DLL Entries
  begin
    K_CMShowMessageDlg( Format( 'Failed to initialise %s Errorcode=%d',
                                           [DllFName, Result] ), mtError );
    CDSFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

  N_Dump1Str( 'Owandy >> CDSInitAll end' );
end; // procedure N_CMCDServObj23.CDSInitAll

//***************************************** TN_CMCDServObj23.CDSSettingsDlg ***
// call settings dialog
//
//    Parameters
// APDevProfile - pointer to profile
//
procedure TN_CMCDServObj23.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev23aForm; // Settings form
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Owandy >> CDSSettingsDlg begin' );

  Form := TN_CMCaptDev23aForm.Create( Application );
  // create setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;
  Form.ShowModal(); // Show a setup form

  N_Dump1Str( 'Owandy >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj23.CDSSettingsDlg

//********************************************* TN_CMCDServObj23.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj23.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    N_Dump2Str( 'After EzSensor.dll FreeLibrary' );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//**************************************** N_CMCDServObj23.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj23.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
begin

  N_Dump1Str( 'Owandy >> CDSCaptureImages begin' );
  if FCapturePrepare(  APDevProfile, ASlidesArray ) <> 0 then Exit;
  N_Dump1Str( 'Owandy >> CDSCaptureImages before ShowModal' );
  CaptForm.ShowModal();
  N_Dump1Str( 'Owandy >> CDSCaptureImages end' );
{
  PProfile := APDevProfile;
  N_Dump1Str( 'Owandy >> CDSCaptureImages begin' );
  if CDSInitAll() > 0 then // no device driver installed
    Exit;

  SetLength(ASlidesArray, 0);
  CaptForm          := TN_CaptForm.Create(application);

  with CaptForm, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll]
                                                                              );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Owandy >> CDSCaptureImages before ShowModal' );

    ShowModal();

    CDSFreeAll();
    N_Dump1Str( 'Owandy >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do
  N_Dump1Str( 'Owandy >> CDSCaptureImages end' );
}
end; // procedure N_CMCDServObj23.CDSCaptureImages

//********************************* TN_CMCDServObj23.CDSStartCaptureToStudy ***
// Start Capture to study
//
//     Parameters
// APDevProfile - pointer to device profile record
// AStudyDevCaptAttrs - resulting Device Capture Interface
// Result - Returns Study Capture State code (TK_CMStudyCaptState)
//
function TN_CMCDServObj23.CDSStartCaptureToStudy(  APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState;
begin
  Result := inherited CDSStartCaptureToStudy( APDevProfile, AStudyDevCaptAttrs );
  if FCapturePrepare( APDevProfile, BufSlidesArray ) = 0 then
  begin
    CaptForm.tbRotateImage.Visible := FALSE;
    with AStudyDevCaptAttrs do
    begin
      CMSDCDDlg := CaptForm;
      CMSDCDDlgCPanel := CaptForm.CtrlsPanel;
    end;
    Result := K_cmscOK;
  end;
  N_Dump1Str( 'Owandy >> CDSStartCaptureToStudy Res=' + IntToStr(Ord(Result)) );

end; // function TN_CMCDServObj23.CDSStartCaptureToStudy

// destructor N_CMCDServObj23.Destroy
//
destructor TN_CMCDServObj23.Destroy();
begin
  CDSFreeAll();
end; // destructor N_CMCDServObj23.Destroy

//******************************** TN_CMCDServObj23.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj23.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 37;
end; // function TN_CMCDServObj23.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj23.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj23.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'IO';
end; // function TN_CMCDServObj23.CDSGetDefaultDevDCMMod

//**************************************** TN_CMCDServObj23.FCapturePrepare ***
// Capture Prepare
//
//     Parameters
// APDevProfile - pointer to profile
// ASlidesArray - resulting Slides Array
//
function TN_CMCDServObj23.FCapturePrepare(  APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ) : Integer;
begin
  Result := 1;
  CaptForm := nil;
  PProfile := APDevProfile;
  if CDSInitAll() > 0 then // no device driver installed
    Exit;

  Result := 0;
  SetLength(ASlidesArray, 0);
  CaptForm := TN_CMCaptDev23Form.Create(application);

  with CaptForm, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll]
                                                                              );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
  end; // with CaptForm, APDevProfile^ do
end; // procedure TN_CMCDServObj23.FCapturePrepare

Initialization

// Create and Register Service Object
N_CMCDServObj23 := TN_CMCDServObj23.Create( N_CMECD_Owandy_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj23 ) do
begin
  CDSCaption := 'Owandy';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj23 ) do

end.
