unit N_CMCaptDev34S;
// MediaScan 2 (EzSensor, FireCR) device changed from Dev11 device

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
// 06.04.20 - sdk updated (n to n)
// 21.04.20 - moved as mediascan 2
// 20.05.20 - optimization
// 08.04.21 - autoconnect added
// 29.04.21 - exception catching added
// 22.04.22 - corner mask added

interface

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev34bF;

//***** for old sdk (before n to n support)

type TN_ImageIntroStructOld = record
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

type TN_ScannerIntroUnionOld = record
case Byte of
  0: ( SIUQuad: Integer );
  1: ( SIUBytes: array[0..3] of AnsiChar; ); // char	bytes[4];
end;

type TN_ScannerIntroOld = record
	SINick: array[0..15] of AnsiChar; // char nick[16];
	SIPN: array[0..19] of AnsiChar; // char PN[20];
	SIIPAddress: TN_ScannerIntroUnionOld;
	SIImageCount: Integer;
end;

type PN_ScannerIntroOld = ^TN_ScannerIntroOld;

type TN_ImageIntroOld = record
case Byte of
  0: ( IIFiller: array[0..511] of AnsiChar ); // char filler[512]
  1: ( IIStruct: TN_ImageIntroStructOld; );
end;

type PN_ImageIntroOld = ^TN_ImageIntroOld;

type PN_CallBackSetOld = record
	CBSScannerStatusEvent: Pointer;
  CBSScannerNotifyEvent: Pointer;
  CBSRFIDStatusEvent: Pointer;
	CBSRFIDNotifyEvent: Pointer;
end;

//***** for new sdk

type TN_ScannerIntroUnion = record
case Byte of
  0: ( SIUQuad: Integer );
  1: ( SIUBytes: array[0..3] of AnsiChar; ); // char	bytes[4];
end;

type TN_ImageIntroStruct = record
  Header:     array[0..3] of AnsiChar; //char header[4]
  SIScannerIP:  TN_ScannerIntroUnion;
	Index:      LongInt;
	Width:      Word;//Cardinal;
	Height:     Word;//Cardinal;
 	Resolution: LongInt; // enum EScanResolution
 	IPSize:     LongInt; // enum EIPSize
 	UID:        Int64;
	TimeSaved:  Double;
	TimeServed: Double;
  PID: array[0..63] of AnsiChar;
	Thumbs:     Pointer; // PIXEL_FORMAT*
end;

type TN_ScannerIntro = record
  SIScannerIP:  TN_ScannerIntroUnion;
  SIHostIP:     TN_ScannerIntroUnion;
  SIUnitStatus: Integer;
	SIScannerName: array[0..19] of AnsiChar; // char nick[16];
	SIHostName:    array[0..19] of AnsiChar; // char PN[20];
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
  CBSRFIDScannerList: Pointer;
	CBSRFIDImageList: Pointer;
end;

type TN_cdeclIntFuncIPAddrInt = function ( IPAddr: TN_ScannerIntroUnion; AInt: Integer ): integer; cdecl;

type TN_CMCDServObj34 = class(TK_CMCDServObj)
  CDSDllHandle: THandle; // DLL Windows Handle

  CDSDllHandleOld: THandle; // DLL Windows Handle

  CDSProfile:   TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr: string;  // Error message
  CDSErrorInt: integer; // Error code

  CDSList:    PN_ImageIntro; // list of images in scanner's buffer
  CDSListOld: PN_ImageIntroOld;
  CDSSource:  PWord;         // acquired image data
  CDSWidth, CDSHeight: Integer; // width and height of image

  CDSUID:           Int64;
  CDSUIDStatus:     Int64;
  CDSScannerStatus: Int64;

  CDSCallBacks:    PN_CallBackSet; // set of callbacks for scanner
  CDSCallBacksOld: PN_CallBackSetOld; // set of callbacks for scanner

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
  CDSSDKOld: Boolean; // if the latest sdk used
  CDSScannerCallback: Boolean;
  CDSScannerAlreadyInit: Boolean;

  CDSScannerCount:  Integer;
  CDSStillProgress: Boolean;

  CDSScannerReboot:   Boolean; // for reboot timer
  CDSSettingsChanges: Integer; // new/old settings change count

  CDSRecover:    Boolean;
  CDSScannerIP:  string;
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

  function CDSInitDll()    : Integer;
  function CDSInitDllOld() : Integer;

private

  BufSlidesArray: TN_UDCMSArray;
  function  FCapturePrepare( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ) : Integer;
end; // end of type TN_CMCDServObj11 = class( TK_CMCDServObj )

// ***** callbacks for sensor
procedure N_OnScannerNotifyOld( Notify: Integer ); cdecl;
procedure N_OnRFIDNotifyOld   ( Notify: Integer ); cdecl;

// ***** callbacks for sensor (new)
procedure N_OnScannerNotify( Notify: Integer ); cdecl;
procedure N_OnRFIDNotify   ( Notify: Integer ); cdecl;
procedure N_OnRFIDStatus   ( Status: Integer ); cdecl;
procedure N_OnScannerStatus( Status: Integer ); cdecl;
procedure N_OnScannerList  ( Count:  Integer ); cdecl;
procedure N_OnImageList    ( Count:  Integer ); cdecl;

var
  N_CMCDServObj34: TN_CMCDServObj34;

  //**** for old sdk
  // ***** funcs from DLL
  N_CMECDVDC_OpenScannerSDKOld:   TN_cdeclIntFuncInt2Ptr;
  N_CMECDVDC_OpenScannerOld:      TN_cdeclIntFuncVoid;
  N_CMECDVDC_GetProgressOld:      TN_cdeclIntFuncVoid;
  N_CMECDVDC_GetImageSizeOld:     TN_cdeclProc2Ptr;
  N_CMECDVDC_GetImageBufferOld:   TN_cdeclPtrFuncVoid;
  N_CMECDVDC_GetScannerStatusOld: TN_cdeclIntFuncVoid;
  N_CMECDVDC_CloseScannerSDKOld:  TN_cdeclProcVoid;
  N_CMECDVDC_CloseScannerOld:     TN_cdeclProcVoid;
  N_CMECDVDC_SetRFIDListeningOld: TN_cdeclProcInt;
  N_CMECDVDC_GetRFIDListeningOld: TN_cdeclIntFuncVoid;
  N_CMECDVDC_GetUIDOld:           TN_cdeclInt64FuncInt;
  N_CMECDVDC_ClearImagesOld:      TN_cdeclIntFuncVoid;
  N_CMECDVDC_RequestImageListOld: TN_cdeclPtrFuncVoid;
  N_CMECDVDC_GetResolutionOld:    TN_cdeclIntFuncVoid;
  N_CMECDVDC_RequestImageFromListOld: TN_cdeclIntFuncInt;
  N_CMECDVDC_RequestScannerListOld: TN_cdeclPtrFuncPtr;
  N_CMECDVDC_GetScannerConnectionTypeOld: TN_cdeclIntFuncVoid;
  N_CMECDVDC_SetPatientIDOld:     TN_cdeclIntFuncPtrInt;
  N_CMECDVDC_GetPatientIDOld:     TN_cdeclPtrFuncInt;

  N_CMECDVDC_ShowCalibrationDialogOld: TN_cdeclIntFuncInt;
  N_CMECDVDC_ShowScannerControlDialogOld: TN_cdeclProcInt;

  //***** for new sdk
  // ***** funcs from DLL
  N_CMECDVDC_OpenScannerSDK:   TN_cdeclIntFuncInt2Ptr;
  N_CMECDVDC_OpenScanner:      TN_cdeclIntFuncVoid;
  N_CMECDVDC_OpenScanner2:      TN_cdeclIntFuncInt;
  N_CMECDVDC_GetProgress:      TN_cdeclIntFuncVoid;
  //N_CMECDVDC_GetImageSize:     TN_cdeclProc2Ptr;
  N_CMECDVDC_GetImageBuffer:   TN_cdeclPtrFuncVoid;
  N_CMECDVDC_GetScannerStatus: TN_cdeclIntFuncVoid;
  N_CMECDVDC_CloseScannerSDK:  TN_cdeclProcVoid;
  N_CMECDVDC_CloseScanner:     TN_cdeclIntFuncVoid;
  N_CMECDVDC_SetRFIDListening: TN_cdeclProcInt;
  N_CMECDVDC_GetRFIDListening: TN_cdeclIntFuncVoid;
  N_CMECDVDC_GetUID:           TN_cdeclInt64FuncInt;
  N_CMECDVDC_ClearImages:      TN_cdeclIntFuncVoid;
  N_CMECDVDC_RequestImageList: TN_cdeclPtrFuncPtr;
  N_CMECDVDC_GetResolution:    TN_cdeclIntFuncVoid;
  N_CMECDVDC_RequestImageFromList: TN_cdeclIntFuncIPAddrInt;
  N_CMECDVDC_RequestScannerList: TN_cdeclPtrFuncPtr;
  N_CMECDVDC_GetScannerConnectionType: TN_cdeclIntFuncVoid;
  N_CMECDVDC_SetPatientID:     TN_cdeclIntFuncPtrInt;
  N_CMECDVDC_GetPatientID:     TN_cdeclPtrFuncInt;

  N_CMECDVDC_ShowCalibrationDialog: TN_cdeclIntFuncInt;
  N_CMECDVDC_ShowScannerControlDialog: TN_cdeclProcInt;

  N_CMECDVDC_GetImageWidth:    TN_cdeclIntFuncVoid;
  N_CMECDVDC_GetImageHeight:   TN_cdeclIntFuncVoid;
  N_CMECDVDC_SleepScanner:     TN_cdeclIntFuncInt;

  N_CMECDVDC_Connect:          TN_cdeclIntFuncPtr;
  N_CMECDVDC_Disconnect:       TN_cdeclPtrFuncVoid;
  N_CMECDVDC_GetErrorCode:     TN_cdeclIntFuncVoid;
  N_CMECDVDC_GetErrorMessage:  TN_cdeclPtrFuncVoid;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, N_CMCaptDev34SF;

var
  CaptForm: TN_CMCaptDev34Form;

//***** callbacks for old sdk
//****************************************************** OnScannerNotifyOld ***
// Callback function for scaner notify event (old sdk)
//
//     Parameters
// Notify - Notify status
//
procedure N_OnScannerNotifyOld( Notify: Integer ); cdecl;
begin
  N_Dump1Str( 'FireCR - Scanner Notify Event = ' + IntToStr(Notify) );
  if Notify = 3 then // then the image is captured
  begin
    N_Dump1Str('FireCR - Notify = 3');
    N_CMCDServObj34.CDSFlagCapt := True;
  end;
  N_CMCDServObj34.CDSNotifyInt := Notify;
end; // procedure N_OnScannerNotifyOld( Notify: Integer ); cdecl;

//******************************************************* N_OnRFIDNotifyOld ***
// Callback function for RFID notify event (old sdk)
//
//     Parameters
// Notify - Notify status
//
procedure N_OnRFIDNotifyOld( Notify: Integer ); cdecl;
begin
  N_Dump1Str( 'FireCR - RFID Notify Event = ' + IntToStr(Notify) );
  N_Dump1Str( 'FireCR - Before GetUID( ' + IntToStr(Notify) + ')' );
  N_CMCDServObj34.CDSUID := N_CMECDVDC_GetUIDOld( Notify );
  N_Dump1Str( Format( 'FireCR - After GetUID( %d ), UID = %x',
                                          [ Notify, N_CMCDServObj34.CDSUID ] ));
end; // procedure N_OnRFIDNotifyOld( Notify: Integer ); cdecl;

//***** callbacks for new sdk
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
    N_CMCDServObj34.CDSFlagCapt := True;
  end;
  N_CMCDServObj34.CDSNotifyInt := Notify;
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
  N_CMCDServObj34.CDSUID := N_CMECDVDC_GetUID( Notify );
  N_Dump1Str( Format( 'FireCR - After GetUID( %d ), UID = %x',
                                          [ Notify, N_CMCDServObj34.CDSUID ] ));
end; // procedure N_OnRFIDNotify( Notify: Integer ); cdecl;

//********************************************************** N_OnRFIDStatus ***
// Callback function for RFID status event
//
//     Parameters
// Status - RFID status
//
procedure N_OnRFIDStatus( Status: Integer ); cdecl;
begin
  N_Dump1Str( 'FireCR - RFID Status Event = ' + IntToStr(Status) );
  N_CMCDServObj34.CDSUIDStatus := Status;
end; // procedure N_OnRFIDStatus( Notify: Integer ); cdecl;

//******************************************************* N_OnScannerStatus ***
// Callback function for RFID status event
//
//     Parameters
// Status - scanner status
//
procedure N_OnScannerStatus( Status: Integer ); cdecl;
begin
  N_Dump1Str( 'FireCR - Scanner Status = ' + IntToStr(Status) );
  N_CMCDServObj34.CDSScannerStatus := Status;
  //if Status = 2 then
  //begin
  //  N_CMCDServObj34.CDSScannerCallback := True;
  //end;
end; // procedure N_OnScannerStatus( Status: Integer ); cdecl;

//********************************************************* N_OnScannerList ***
// Callback function for scanner list (count)
//
//     Parameters
// Count - scanner count
//
procedure N_OnScannerList( Count: Integer ); cdecl;
begin
  N_Dump1Str( 'FireCR - ScannerList Count = ' + IntToStr(Count) );
  N_CMCDServObj34.CDSScannerCount := Count;
  N_CMCDServObj34.CDSScannerCallback := True;
end; // procedure N_OnScannerList( Count: Integer ); cdecl;

//*********************************************************** N_OnImageList ***
// Callback function for image list
//
//     Parameters
// Count - image count
//
procedure N_OnImageList( Count: Integer ); cdecl;
begin
end; // procedure N_OnImageList( Count: Integer ); cdecl;

//************************************************* TN_CMCDServObj34 **********
//*********************************************************** CDSInitDllOld ***
// Initilizing SDK DLLs (old sdk)
//
//     Parameters
// Result - result
//
function TN_CMCDServObj34.CDSInitDllOld() : Integer;
var
  FuncAnsiName: AnsiString;
  DllFName, DllFNameOld: string;  // DLL File Name

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    CDSErrorStr := String(FuncAnsiName) + ' not loaded';
    N_Dump1Str( CDSErrorStr );
    Result := 2;
  end; // procedure ReportError(); // local

begin
  N_Dump1Str( 'Start CMCDServObj15.CDSInitAll' );

  DllFNameOld := ExtractFilePath( ParamStr( 0 ) );
  N_Dump1Str( 'CRSwing Old directory = "' + DllFNameOld + '"' );
  DllFNameOld := DllFNameOld + 'MediaScan\CRSwing.dll';

  N_CMSetNeededCurrentDir ();

  CDSErrorStr := '';
  Result := 0;

  CDSDllHandleOld := Windows.LoadLibrary( @DllFNameOld[1] );

  N_Dump1Str( Format( 'After Windows.LoadLibrary %s, CDSDllHandle=%X',
                                                    [DllFName,CDSDllHandleOld] ) );

  if CDSDllHandleOld = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFNameOld + ': ' +
                                              SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load EzSensor DLL functions (old)

  FuncAnsiName := '_OpenScannerSDK';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_OpenScannerSDKOld := GetProcAddress( CDSDllHandleOld,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_OpenScannerSDKOld) then ReportError();

  FuncAnsiName := '_OpenScanner';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_OpenScannerOld := GetProcAddress( CDSDllHandleOld,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_OpenScannerOld) then ReportError();

  FuncAnsiName := '_GetProgress';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetProgressOld := GetProcAddress( CDSDllHandleOld,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetProgressOld) then ReportError();

  FuncAnsiName := '_GetImageSize';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetImageSizeOld := GetProcAddress( CDSDllHandleOld,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetImageSizeOld) then ReportError();

  FuncAnsiName := '_GetImageBuffer';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetImageBufferOld := GetProcAddress( CDSDllHandleOld,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetImageBufferOld) then ReportError();

  FuncAnsiName := '_GetScannerStatus';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetScannerStatusOld := GetProcAddress( CDSDllHandleOld,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetScannerStatusOld) then ReportError();

  FuncAnsiName := '_CloseScannerSDK';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_CloseScannerSDKOld := GetProcAddress( CDSDllHandleOld,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_CloseScannerSDKOld) then ReportError();

  FuncAnsiName := '_CloseScanner';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_CloseScannerOld := GetProcAddress( CDSDllHandleOld,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_CloseScannerOld) then ReportError();

  FuncAnsiName := '_SetRFIDListening';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_SetRFIDListeningOld := GetProcAddress( CDSDllHandleOld,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_SetRFIDListeningOld) then ReportError();

  FuncAnsiName := '_GetRFIDListening';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetRFIDListeningOld := GetProcAddress( CDSDllHandleOld,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetRFIDListeningOld) then ReportError();

  FuncAnsiName := '_GetUID';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetUIDOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetUIDOld) then ReportError();

  FuncAnsiName := '_ClearImages';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_ClearImagesOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_ClearImagesOld) then ReportError();

  FuncAnsiName := '_RequestImageList';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_RequestImageListOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_RequestImageListOld) then ReportError();

  FuncAnsiName := '_GetResolution';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetResolutionOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetResolutionOld) then ReportError();

  FuncAnsiName := '_RequestImageFromList';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_RequestImageFromListOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_RequestImageFromListOld) then ReportError();

  FuncAnsiName := '_RequestScannerList';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_RequestScannerListOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_RequestScannerListOld) then ReportError();

  FuncAnsiName := '_GetScannerConnectionType';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetScannerConnectionTypeOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetScannerConnectionTypeOld) then ReportError();

  FuncAnsiName := '_SetPatientID';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_SetPatientIDOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_SetPatientIDOld) then ReportError();

  FuncAnsiName := '_GetPatientID';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetPatientIDOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetPatientIDOld) then ReportError();

  FuncAnsiName := '_ShowCalibrationDialog';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_ShowCalibrationDialogOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_ShowCalibrationDialogOld) then ReportError();

  FuncAnsiName := '_ShowScannerControlDialog';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_ShowScannerControlDialogOld := GetProcAddress( CDSDllHandleOld, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_ShowScannerControlDialogOld) then ReportError();

  N_Dump1Str( 'FireCR >> CDSInitAll end' );
end; // function TN_CMCDServObj34.CDSInitDllOld() : Integer;

//************************************************************** CDSInitDll ***
// Initilizing SDK DLLs
//
//     Parameters
// Result - result
//
function TN_CMCDServObj34.CDSInitDll() : Integer;
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

  DllFName := ExtractFilePath( ParamStr( 0 ) );
  N_Dump1Str( 'CRSwing Old directory = "' + DllFName + '"' );
  DllFName := DllFName + 'CRSwing.dll';

  N_CMSetNeededCurrentDir ();

  N_Dump1Str( 'Before Windows.LoadLibrary ' + DllFName );
  CDSDllHandle := Windows.LoadLibrary( @DllFName[1] );

  if CDSDllHandle = 0 then // some error
  begin
    CDSErrorStr := 'Error Loading ' + DllFName + ': ' +
                                              SysErrorMessage( GetLastError() );
    Result := 2; // Windows.LoadLibrary failed
    K_CMShowMessageDlg( CDSErrorStr, mtError );
    Exit;
  end; // if CDSDllHandle = 0 then // some error

  //***** Load EzSensor DLL functions (new)
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

  FuncAnsiName := '_OpenScanner2';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_OpenScanner2 := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_OpenScanner2) then ReportError();
  FuncAnsiName := '_GetProgress';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetProgress := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetProgress) then ReportError();

  FuncAnsiName := '_Connect';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_Connect := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_Connect) then ReportError();

  FuncAnsiName := '_Disconnect';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_Disconnect := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_Disconnect) then ReportError();

 // FuncAnsiName := '_GetImageSize';
 // N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
 // N_CMECDVDC_GetImageSize := GetProcAddress( CDSDllHandle,
 //                                                            @FuncAnsiName[1] );
 // if not Assigned(N_CMECDVDC_GetImageSize) then ReportError();

  FuncAnsiName := '_GetImageHeight';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetImageHeight := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetImageHeight) then ReportError();

  FuncAnsiName := '_GetImageWidth';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetImageWidth := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetImageWidth) then ReportError();

  FuncAnsiName := '_GetImageHeight';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetImageHeight := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetImageHeight) then ReportError();

  FuncAnsiName := '_SleepScanner';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_SleepScanner := GetProcAddress( CDSDllHandle,
                                                             @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_SleepScanner) then ReportError();

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

  //FuncAnsiName := '_GetResolution';
  //N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  //N_CMECDVDC_GetResolution := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  //if not Assigned(N_CMECDVDC_GetResolution) then ReportError();

  FuncAnsiName := '_GetImageResolution';
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

  FuncAnsiName := '_GetErrorCode';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetErrorCode := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetErrorCode) then ReportError();

  FuncAnsiName := '_GetErrorMessage';
  N_Dump1Str( 'GetProcAddress ' + String(FuncAnsiName) );
  N_CMECDVDC_GetErrorMessage := GetProcAddress( CDSDllHandle, @FuncAnsiName[1] );
  if not Assigned(N_CMECDVDC_GetErrorMessage) then ReportError();

  if Result <> 0 then // some error while loading DLL Entries
  begin
    K_CMShowMessageDlg( Format( 'Failed to initialise %s Errorcode=%d',
                                           [DllFName, Result] ), mtError );
    CDSFreeAll();
    N_Dump1Str( DllFName + ' Resources freed' );
  end;

  N_Dump1Str( 'FireCR >> CDSInitAll end' );
end; // procedure N_CMCDServObj34.CDSInitAll

//********************************************** TN_CMCDServObj3.CDSInitAll ***
// Initialize Device and needed Soft
//
function TN_CMCDServObj34.CDSInitAll() : Integer;
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
  N_Dump1Str( 'Start CMCDServObj15.CDSInitAll' );
  N_Dump1Str( 'FireCR >> CDSInitAll end' );
end; // procedure N_CMCDServObj34.CDSInitAll

//********************************************** TN_CMCDServObj3.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj34.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    FreeLibrary( CDSDLLHandleOld );
    N_Dump2Str( 'After DLL FreeLibrary' );
    CDSDLLHandle := 0;
    CDSDLLHandleOld := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj3.CDSFreeAll

//*************************************** TN_CMCDServObj34.CDSSettingsDlg ***
// Call settings dialog
//
//     Parameters
// APDevProfile - Pointer to Profile
//
procedure TN_CMCDServObj34.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev34bForm; // Settings form
  //raw: Boolean;
begin
  N_Dump1Str( 'FireCR >> CDSSettingsDlg Begin' );
  CDSProfile := APDevProfile;
  Form := TN_CMCaptDev34bForm.Create( Application );
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
  Form.CMCDPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption
  //Form.CMCDPDevProfile := CDSProfile;
  //raw := False;

  //if ( 0 < Length( PProfile.CMDPStrPar1 ) ) then
  //  raw := ( '1' = Copy( PProfile.CMDPStrPar1, 1, 1 )  );

  //frm.cbRaw.Checked := raw;

  Form.CMCDFromCaptionForm := False;

  N_Dump1Str('~~~'+APDevProfile.CMDPStrPar1);
  Form.ShowModal(); // Show FireCR Setup Form
  N_Dump1Str('~~~'+APDevProfile.CMDPStrPar1);
  N_Dump1Str( 'FireCR >> CDSSettingsDlg End' );
end; // procedure TN_CMCDServObj16.CDSSettingsDlg

//**************************************** N_CMCDServObj34.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj34.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
begin
  N_Dump1Str( 'FireCR >> CDSCaptureImages begin' );
  if FCapturePrepare( APDevProfile, ASlidesArray ) <> 0 then Exit;
  N_Dump1Str( 'FireCR >> CDSCaptureImages before ShowModal' );
  CaptForm.ShowModal();
  N_Dump1Str( 'FireCR >> CDSCaptureImages after ShowModal' );
end; // procedure N_CMCDServObj34.CDSCaptureImages

//********************************* TN_CMCDServObj34.CDSStartCaptureToStudy ***
// Start Capture to study
//
//     Parameters
// APDevProfile - pointer to device profile record
// AStudyDevCaptAttrs - resulting Device Capture Interface
// Result - Returns Study Capture State code (TK_CMStudyCaptState)
//
function TN_CMCDServObj34.CDSStartCaptureToStudy(  APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState;
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

end; // function TN_CMCDServObj34.CDSStartCaptureToStudy

// destructor N_CMCDServObj34.Destroy
//
destructor TN_CMCDServObj34.Destroy();
begin
  N_Dump2Str( 'Before TN_CMCDServObj34.Destroy' );
  //CDSFreeAll();
  inherited;
  N_Dump2Str( 'After TN_CMCDServObj34.Destroy' );
end; // destructor N_CMCDServObj34.Destroy

//******************************** TN_CMCDServObj34.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj34.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 38;
end; // function TN_CMCDServObj34.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj34.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj34.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'IO';
end; // function TN_CMCDServObj34.CDSGetDefaultDevDCMMod

//**************************************** TN_CMCDServObj34.FCapturePrepare ***
// Capture Prepare
//
//     Parameters
// APDevProfile - pointer to profile
// ASlidesArray - resulting Slides Array
//
function TN_CMCDServObj34.FCapturePrepare(  APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ) : Integer;
begin
  Result := 1;
  CDSProfile := APDevProfile;
  if CDSInitAll() = 2 then // library error
    Exit;

  SetLength( ASlidesArray, 0 );
  Result := 0;
  CaptForm := TN_CMCaptDev34Form.Create( Application );

  with CaptForm, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
  end; // with CaptForm, APDevProfile^ do
end; // procedure TN_CMCDServObj34.FCapturePrepare

Initialization

// Create and Register FireCR Service Object
N_CMCDServObj34 := TN_CMCDServObj34.Create( N_CMECD_MediaScan2_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj34 ) do
begin
  CDSCaption := 'MediaScan 2';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj34 ) do

end.
