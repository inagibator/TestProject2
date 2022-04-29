unit N_CMCaptDev15S;
// MediaScan (EzSensor, FireCR) device changed from Dev11 device

// 17.07.14 - added logs specifically for FireCR SDK-functions marked by
// "FireCR - " prefix, also FireCR starts with "Start FireCR" log and
// finishes with "Stop FireCR" log;
// 05.02.15 - added a preview from a buffer functionality
// 03.08.15 - added a proper garbage cleaning for slide objects
// 25.03.16 - added a current date/time setting for slides from buffer
// 04.04.17 - updated after problems with patient names
// 31.05.17 - an icon returned to a button, also anchors
// 15.07.17 - fixed a log, no patient names in a log
// 05.11.18 - settings interface changed
// 2018.11.07 CDSGetDefaultDevIconInd function added
// 12.08.20 - TimerCheck logs cleared

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev15bF;

type TN_ImageIntroStruct = record
  Header:     array[0..3] of AnsiChar; //char header[4]
	Index:      Integer;
	Width:      Cardinal;
	Height:     Cardinal;
 	Resolution: LongInt; // enum EScanResolution
 	IPSize:     LongInt; // enum EIPSize
 	UID:        Int64;
	TimeSaved:  Double;
	TimeServed: Double;
  PID: array[0..63] of AnsiChar;
	Thumbs:     Pointer; // PIXEL_FORMAT*
end;

type TN_ScannerIntroUnion = record
case Byte of
  0: ( SIUQuad: Integer );
  1: ( SIUBytes: array[0..3] of AnsiChar; ); // char	bytes[4];
end;

type TN_ScannerIntro = record
	SINick: array[0..15] of AnsiChar; // char nick[16];
	SIPN: array[0..19] of AnsiChar; // char PN[20];
	SIIPAddress: TN_ScannerIntroUnion;
	SIImageCount: Integer;
end;

type PN_ScannerIntro = ^TN_ScannerIntro;

type TN_ImageIntro = record
case Byte of
  0: ( IIFiller: array[0..511] of AnsiChar ); // char filler[512]
  1: ( IIStruct: TN_ImageIntroStruct; );
end;

type PN_ImageIntro = ^TN_ImageIntro;

type PN_CallBackSet = record
	CBSScannerStatusEvent: Pointer;
  CBSScannerNotifyEvent: Pointer;
  CBSRFIDStatusEvent: Pointer;
	CBSRFIDNotifyEvent: Pointer;
end;

type TN_CMCDServObj15 = class(TK_CMCDServObj)
  CDSDllHandle: THandle; // DLL Windows Handle
  CDSProfile:   TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr: string;  // Error message
  CDSErrorInt: integer; // Error code

  CDSList:   PN_ImageIntro; // list of images in scanner's buffer
  CDSSource: PWord;         // acquired image data
  CDSWidth, CDSHeight: Integer; // width and height of image

  CDSUID: Int64;

  CDSCallBacks: PN_CallBackSet; // set of callbacks for scanner
  CDSPrevProgress: Integer; // previous progress (for capture)
  CDSFlagCapt:     Boolean; // flag if image captured
  CDSNotifyInt:    Integer; // notify status
  CDSPrevStatus:   Integer; // previous status
  CDSScannerConnectionType: Integer; // type of connection for scanner

  CDSImageFilter: Boolean; // is applyied image filter
  CDSImageFilterInd: Integer; // image filter number
  CDSPrevUID:     Int64;   // previous UID
  CDSTimerCount:  Integer; // counting the timer
  CDSPatientName: AnsiString; // patient name (ID)

  CDSCalDataDir: string;
  CDSSetPatientFlag: Boolean;
  CDSCalDataFin: Boolean;
  CDSPrevConnectType: Integer;
  CDSPrevRFID: Integer;

  CDSInit: Boolean;

  CDSIndexArray: array[0..99] of Integer; // needed for sorted array of images to have indexes of images in the buffer

  function CDSInitAll(): Integer;
  function CDSFreeAll(): Integer;

  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;
  procedure CDSCaptureImages    ( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  function  CDSStartCaptureToStudy  ( APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState; override;

  destructor Destroy; override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;

private

  BufSlidesArray: TN_UDCMSArray;
  function  FCapturePrepare( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ) : Integer;
end; // end of type TN_CMCDServObj11 = class( TK_CMCDServObj )

// ***** callbacks for sensor
procedure N_OnScannerNotify( Notify: Integer ); cdecl;
procedure N_OnRFIDNotify   ( Notify: Integer ); cdecl;

var
  N_CMCDServObj15: TN_CMCDServObj15;

  // ***** funcs from DLL
  N_CMECDVDC_OpenScannerSDK:   TN_cdeclIntFuncInt2Ptr;
  N_CMECDVDC_OpenScanner:      TN_cdeclIntFuncVoid;
  N_CMECDVDC_GetProgress:      TN_cdeclIntFuncVoid;
  N_CMECDVDC_GetImageSize:     TN_cdeclProc2Ptr;
  N_CMECDVDC_GetImageBuffer:   TN_cdeclPtrFuncVoid;
  N_CMECDVDC_GetScannerStatus: TN_cdeclIntFuncVoid;
  N_CMECDVDC_CloseScannerSDK:  TN_cdeclProcVoid;
  N_CMECDVDC_CloseScanner:     TN_cdeclProcVoid;
  N_CMECDVDC_SetRFIDListening: TN_cdeclProcInt;
  N_CMECDVDC_GetRFIDListening: TN_cdeclIntFuncVoid;
  N_CMECDVDC_GetUID:           TN_cdeclInt64FuncInt;
  N_CMECDVDC_ClearImages:      TN_cdeclIntFuncVoid;
  N_CMECDVDC_RequestImageList: TN_cdeclPtrFuncVoid;
  N_CMECDVDC_GetResolution:    TN_cdeclIntFuncVoid;
  N_CMECDVDC_RequestImageFromList: TN_cdeclIntFuncInt;
  N_CMECDVDC_RequestScannerList: TN_cdeclPtrFuncPtr;
  N_CMECDVDC_GetScannerConnectionType: TN_cdeclIntFuncVoid;
  N_CMECDVDC_SetPatientID:     TN_cdeclIntFuncPtrInt;
  N_CMECDVDC_GetPatientID:     TN_cdeclPtrFuncInt;

  N_CMECDVDC_ShowCalibrationDialog: TN_cdeclIntFuncInt;
  N_CMECDVDC_ShowScannerControlDialog: TN_cdeclProcInt;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, N_CMCaptDev15SF;

var
  CaptForm: TN_CMCaptDev15Form;

//********************************************************* OnScannerNotify ***
// Callback function for scaner notify event
//
//     Parameters
// Notify - Notify status
//
procedure N_OnScannerNotify( Notify: Integer ); cdecl;
begin
  N_Dump1Str( 'FireCR - Scanner Notify Event = ' + IntToStr(Notify) );
  if Notify = 3 then // then the image is captured
  begin
    N_Dump1Str('FireCR - Notify = 3');
    N_CMCDServObj15.CDSFlagCapt := True;
  end;
  N_CMCDServObj15.CDSNotifyInt := Notify;
end; // procedure N_OnScannerNotify( Notify: Integer ); cdecl;

//********************************************************** N_OnRFIDNotify ***
// Callback function for RFID notify event
//
//     Parameters
// Notify - Notify status
//
procedure N_OnRFIDNotify( Notify: Integer ); cdecl;
begin
  N_Dump1Str( 'FireCR - RFID Notify Event = ' + IntToStr(Notify) );
  N_Dump1Str( 'FireCR - Before GetUID( ' + IntToStr(Notify) + ')' );
  N_CMCDServObj15.CDSUID := N_CMECDVDC_GetUID( Notify );
  N_Dump1Str( Format( 'FireCR - After GetUID( %d ), UID = %x',
                                          [ Notify, N_CMCDServObj15.CDSUID ] ));
end; // procedure N_OnRFIDNotify( Notify: Integer ); cdecl;

//************************************************* TN_CMCDServObj15 **********

//********************************************** TN_CMCDServObj3.CDSInitAll ***
// Initialize Device and needed Soft
//
function TN_CMCDServObj15.CDSInitAll() : Integer;
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
  N_Dump1Str( 'Start CMCDServObj15.CDSInitAll' );

  if CDSDllHandle <> 0 then // CDSDevInd already initialized
  begin
    Result := 0;
    Exit;
  end; // if CDSDllHandle <> 0 then // CDSDevInd already initialized

  DllFName := 'MediaScan\CRSwing.dll';
  CDSErrorStr := '';
  Result := 0;

  N_CMSetNeededCurrentDir ();

  N_Dump1Str( 'Before Windows.LoadLibrary ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );
  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, CDSDllHandle=%X',
                                                    [DllFName,CDSDllHandle] ) );

  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName + ': ' +
                                              SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load EzSensor DLL functions

  FuncAnsiName := '_OpenScannerSDK';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_OpenScannerSDK := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_OpenScannerSDK) then ReportError();

  FuncAnsiName := '_OpenScanner';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_OpenScanner := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_OpenScanner) then ReportError();

  FuncAnsiName := '_GetProgress';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetProgress := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetProgress) then ReportError();

  FuncAnsiName := '_GetImageSize';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetImageSize := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetImageSize) then ReportError();

  FuncAnsiName := '_GetImageBuffer';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetImageBuffer := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetImageBuffer) then ReportError();

  FuncAnsiName := '_GetScannerStatus';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetScannerStatus := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetScannerStatus) then ReportError();

  FuncAnsiName := '_CloseScannerSDK';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_CloseScannerSDK := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_CloseScannerSDK) then ReportError();

  FuncAnsiName := '_CloseScanner';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_CloseScanner := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_CloseScanner) then ReportError();

  FuncAnsiName := '_SetRFIDListening';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_SetRFIDListening := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_SetRFIDListening) then ReportError();

  FuncAnsiName := '_GetRFIDListening';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetRFIDListening := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetRFIDListening) then ReportError();

  FuncAnsiName := '_GetUID';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetUID := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetUID) then ReportError();

  FuncAnsiName := '_ClearImages';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_ClearImages := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_ClearImages) then ReportError();

  FuncAnsiName := '_RequestImageList';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_RequestImageList := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_RequestImageList) then ReportError();

  FuncAnsiName := '_GetResolution';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetResolution := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetResolution) then ReportError();

  FuncAnsiName := '_RequestImageFromList';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_RequestImageFromList := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_RequestImageFromList) then ReportError();

  FuncAnsiName := '_RequestScannerList';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_RequestScannerList := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_RequestScannerList) then ReportError();

  FuncAnsiName := '_GetScannerConnectionType';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetScannerConnectionType := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetScannerConnectionType) then ReportError();

  FuncAnsiName := '_SetPatientID';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_SetPatientID := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_SetPatientID) then ReportError();

  FuncAnsiName := '_GetPatientID';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetPatientID := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetPatientID) then ReportError();

  FuncAnsiName := '_ShowCalibrationDialog';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_ShowCalibrationDialog := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_ShowCalibrationDialog) then ReportError();

  FuncAnsiName := '_ShowScannerControlDialog';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_ShowScannerControlDialog := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_ShowScannerControlDialog) then ReportError();




  if Result <> 0 then // some error while loading DLL Entries
  begin
    K_CMShowMessageDlg( Format( 'Failed to initialise %s Errorcode=%d',
                                           [DllFName, Result] ), mtError );
    CDSFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

  N_Dump1Str( 'FireCR >> CDSInitAll end' );
end; // procedure N_CMCDServObj15.CDSInitAll

//********************************************** TN_CMCDServObj3.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj15.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    N_Dump2Str( 'After DLL FreeLibrary' );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//*************************************** TN_CMCDServObj15.CDSSettingsDlg ***
// Call settings dialog
//
//     Parameters
// APDevProfile - Pointer to Profile
//
procedure TN_CMCDServObj15.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev15bForm; // Settings form
  //raw: Boolean;
begin
  CDSProfile := APDevProfile;
  N_Dump1Str( 'FireCR >> CDSSettingsDlg Begin' );
  Form := TN_CMCaptDev15bForm.Create( Application );
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption
  Form.CMOFPDevProfile := CDSProfile;
  //raw := False;

  //if ( 0 < Length( PProfile.CMDPStrPar1 ) ) then
  //  raw := ( '1' = Copy( PProfile.CMDPStrPar1, 1, 1 )  );

  //frm.cbRaw.Checked := raw;
  Form.ShowModal(); // Show FireCR Setup Form
  N_Dump1Str( 'FireCR >> CDSSettingsDlg End' );
end; // procedure TN_CMCDServObj16.CDSSettingsDlg

//**************************************** N_CMCDServObj15.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj15.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
begin
{
  CDSProfile := APDevProfile;
  N_Dump1Str( 'FireCR >> CDSCaptureImages begin' );
  if CDSInitAll() = 2 then // library error
    Exit;

  SetLength( ASlidesArray, 0 );
  CMCaptDev15Form              := TN_CMCaptDev15SForm.Create( Application );
  with CMCaptDev15Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'FireCR >> CDSCaptureImages before ShowModal' );

    ShowModal();
    CDSFreeAll();
    N_Dump1Str( 'FireCR >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do
}
  N_Dump1Str( 'FireCR >> CDSCaptureImages begin' );
  if FCapturePrepare( APDevProfile, ASlidesArray ) <> 0 then Exit;
  N_Dump1Str( 'FireCR >> CDSCaptureImages before ShowModal' );
  CaptForm.ShowModal();
  N_Dump1Str( 'FireCR >> CDSCaptureImages after ShowModal' );
end; // procedure N_CMCDServObj15.CDSCaptureImages

//********************************* TN_CMCDServObj15.CDSStartCaptureToStudy ***
// Start Capture to study
//
//     Parameters
// APDevProfile - pointer to device profile record
// AStudyDevCaptAttrs - resulting Device Capture Interface
// Result - Returns Study Capture State code (TK_CMStudyCaptState)
//
function TN_CMCDServObj15.CDSStartCaptureToStudy(  APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState;
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
  end; // if FCapturePrepare( APDevProfile, BufSlidesArray ) <> 0 then
  N_Dump1Str( 'FireCR >> CDSStartCaptureToStudy Res=' + IntToStr(Ord(Result)) );

end; // function TN_CMCDServObj15.CDSStartCaptureToStudy

// destructor N_CMCDServObj15.Destroy
//
destructor TN_CMCDServObj15.Destroy();
begin
  N_Dump2Str( 'Before TN_CMCDServObj15.Destroy' );
  //CDSFreeAll();
  inherited;
  N_Dump2Str( 'After TN_CMCDServObj15.Destroy' );
end; // destructor N_CMCDServObj15.Destroy

//******************************** TN_CMCDServObj15.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj15.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 38;
end; // function TN_CMCDServObj15.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj15.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj15.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
    Result := 'IO';
end; // function TN_CMCDServObj15.CDSGetDefaultDevDCMMod

//**************************************** TN_CMCDServObj15.FCapturePrepare ***
// Capture Prepare
//
//     Parameters
// APDevProfile - pointer to profile
// ASlidesArray - resulting Slides Array
//
function TN_CMCDServObj15.FCapturePrepare(  APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ) : Integer;
begin
  Result := 1;
  CDSProfile := APDevProfile;
  if CDSInitAll() = 2 then // library error
    Exit;

  SetLength( ASlidesArray, 0 );
  Result := 0;
  CaptForm := TN_CMCaptDev15Form.Create( Application );

  with CaptForm, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
  end; // with CaptForm, APDevProfile^ do
end; // procedure TN_CMCDServObj15.FCapturePrepare

Initialization

// Create and Register FireCR Service Object
N_CMCDServObj15 := TN_CMCDServObj15.Create( N_CMECD_MediaScan_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj15 ) do
begin
  CDSCaption := 'MediaScan';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj15 ) do

end.
