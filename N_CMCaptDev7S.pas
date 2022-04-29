unit N_CMCaptDev7S;
// MediaRay (E2V) device

// 2014.03.20 substituted 'K_CMShowMessageDlg' by 'ShowCriticalError' calls by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface
uses
  Windows, Classes, Forms, Graphics, StdCtrls, ExtCtrls,
  K_CM0, K_CMCaptDevReg,
  N_Types, N_CMCaptDev0, N_CMCaptDev7SF, N_CMCaptDev7aF;

type TE2VDevInfo = record  // type for device info
    pcDeviceName: array[0..259] of AnsiChar;
    pcModelName: array[0..31] of AnsiChar;
    LinkSpeedUsb: AnsiChar;
    cInUse: AnsiChar;
    eSensorType: Integer;
end;

type TE2VEepromInfo = record // auxilliary type for sensor info
    pcUserName: array[0..15] of AnsiChar;
    pcSpare1: array[0..15] of AnsiChar;
    pcSpare2: array[0..31] of AnsiChar;
end;

type TE2VSensorInfo = record // type for sensor info
    usWidth: WORD;
    usHeight: WORD;
    pcChipNumber: array[0..2] of AnsiChar;
    pcChipVersion: array[0..0] of AnsiChar;
    pcClientCode: array[0..1] of AnsiChar;
    pcClientVar: array[0..1] of AnsiChar;
    pcSerialNumber: array[0..3] of AnsiChar;
    pcID: array[0..3] of AnsiChar;
    pcLaserUnicID: array[0..7] of AnsiChar;
    EInfoeprom: TE2VEepromInfo;
end;

type TPE2VSensorInfo = ^TE2VSensorInfo; // pointer to sensor info

type TE2VStatus = record // device status
  ulStatus: DWORD;
end;

type TPE2VStatus = ^TE2VStatus; // pointer to device status

type TE2VParamDemoniac900 = record  // type for parameters
    nIntegerMode: Integer;
    nIntegrationTime: Integer;
    nBiningMode: Integer;
    nTriggerMode: Integer;
    nTriggeringLevel: Integer;
    nChainOffsetSelection: Integer;
    nManualChainOffset: Integer;
    nAutoRearm: Integer;
    nGain: Integer;
	  nReserved1: Integer;
    nReserved2: Integer;
    nReserved3: Integer;
    nReserved4: Integer;
    nReserved5: Integer;
    nReserved6: Integer;
    nReserved7: Integer;
    nReserved8: Integer;
end;

type TPE2vDevInfo = ^TE2VDevInfo; // pointer to device info

type TXrayCallBack = record // type for Plug event
    pcDeviceName: array[0..259] of AnsiChar;
    nState: Integer;
end;

type TPXrayCallBack = ^TXrayCallBack; // pointer to the type for Plug event

type TE2VState = (
  dsError,
  dsNotFound,
  dsFound,
  dsOpened,
  dsArmed,
  dsTakesXray
);

type TN_CMCDServObj7 = class( TK_CMCDServObj )
  CDSDevInd: Integer; // local Device index (synonim of CMDPProductName)
  CDSDllHandle: THandle; // DLL Windows Handle
  CDSErrorStr: String;  // Error message
  CDSErrorInt: Integer; // Error code

  E2VHandle: Pointer;           // device handle
  info: TE2VDevInfo;            // device info
  sens: TE2VSensorInfo;         // sensor info
  status: TE2VStatus;           // device status
  param: TE2VParamDemoniac900;  // device parameters
  ImageArray: TN_BArray;        // array for image bytes
  PixelSizeH: integer;          // pixel size

  PProfile: TK_PCMDeviceProfile; // CMS Profile Pointer
  DevNamesA: AnsiString;         // Device ANSI names (260 chars each)
  DevNamesS: String;             // Device names string
  DeviceStatus: TE2VState;       // Current Device state
  E2VFirst: Boolean;             // E2V first time
  E2VSimulator: Boolean;         // True if in Simulation mode

  // Imported functions from E2V Interface DLL
  LoadDriverLibrary_ext: TN_CMV_cdeclIntFuncPACharInt;
  GetDLLVersion_ext:     TN_CMV_cdeclProcPACharInt;
  SearchDevices_ext:     TN_CMV_cdeclIntFuncPACharPIntDWORD;
  GetDeviceInfo_ext:     TN_CMV_cdeclIntFuncPACharPtr;
  GetLastError_ext:      TN_cdeclIntFuncVoid;
  GetLastErrorText_ext:  TN_CMV_cdeclIntFuncPACharInt;

  IsExceptionDetectedWhileLastFunctionCall_ext: TN_cdeclIntFuncVoid;

  OpenDevice_ext:             TN_CMV_cdeclIntFuncPACharPPtr;
  CloseDevice_ext:            TN_CMV_cdeclIntFuncPtr;
  GetSensorInfo_ext:          TN_cdeclIntFunc2Ptr;
  GetParameters_ext:          TN_CMV_cdeclIntFunc2PtrInt;
  SetParameters_ext:          TN_CMV_cdeclIntFunc2PtrInt;
  GetStatus_ext:              TN_cdeclIntFunc2Ptr;
  AutoTest_ext:               TN_CMV_cdeclIntFuncPtrIntPInt;
  ArmDevice_ext:              TN_CMV_cdeclIntFuncPtrInt;
  DisarmDevice_ext:           TN_CMV_cdeclIntFuncPtr;
  WaitForImage_ext:           TN_CMV_cdeclIntFuncPtrInt;
  GetImageFileSize_ext:       TN_CMV_cdeclIntFuncPtrPInt;
  GetImageFile_ext:           TN_CMV_cdeclIntFuncPtrByteIntPtrInt;
  IsNewXRayEventDetected_ext: TN_cdeclIntFuncVoid;
  GetLastPlugEvent_ext:       TN_CMV_cdeclIntFuncPtrPInt;

  GetSensorPixelSizeInMicrometers_ext: TN_cdeclIntFuncVoid;

  //Calibration
  LoadCorrectionImageFile_ext:   TN_CMV_cdeclIntFuncPtrPAChar;
  LoadCorrectionImageBuffer_ext: TN_CMV_cdeclIntFuncPtrByteInt;
  ApplyCorrectionToImage_ext:    TN_CMV_cdeclIntFuncPtrPACharInt;

  // E2V Emulator functions
  SetSimulationMode_ext:          TN_cdeclIntFuncInt;
  SimulatePlugEvent_ext:          TN_CMV_cdeclProcPtrInt;
  SimulateNewXrayEvent_ext:       TN_cdeclProcVoid;
  SetSimulationSensorType_ext:    TN_cdeclIntFuncInt;
  SetSimulatedStatus_ext:         TN_cdeclProcInt;
  SetSimulatedExceptionFlag_ext:  TN_cdeclProcVoid;
  SetLastErrorSimulationCode_ext: TN_cdeclIntFuncInt;
  OpenLogFile_ext:                TN_cdeclIntFuncPAChar3Int;

  procedure DumpStatus              ();
  procedure ShowDeviceStatus        ( frm: TN_CMCaptDev7Form; comment: String );
  procedure CDSInitAll              ();
  procedure CDSFreeAll              ();
  procedure E2VOpen                 ( frm: TN_CMCaptDev7Form );
  function  CorrectSensId           ( s: String ): String;
  procedure E2VArm                  ( frm: TN_CMCaptDev7Form );
  procedure E2VCapture              ( frm: TN_CMCaptDev7Form );
  procedure E2VOnTimer              ( frm: TN_CMCaptDev7Form );
  procedure E2VDisArm               ( frm: TN_CMCaptDev7Form );
  procedure E2VClose                ( frm: TN_CMCaptDev7Form );
  procedure E2VProfileToForm        ( frm: TN_CMCaptDev7aForm );
  function  CDSGetGroupDevNames     ( AGroupDevNames: TStrings ): Integer; override;
  function  CDSGetDevProfileCaption ( ADevName: string ): string; override;
  function  CDSGetDevCaption        ( ADevName: string ): string; override;
  procedure CDSCaptureImages        ( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ); override;
  function  CDSStartCaptureToStudy  ( APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState; override;
  procedure CDSSettingsDlg          ( APDevProfile: TK_PCMDeviceProfile ); override;

  destructor  Destroy; override;
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;

private

  BufSlidesArray: TN_UDCMSArray;
  UIDisabledFlag : Boolean;
  PrevDeviceStatus: TE2VState;   // Prev Timer Event Device state
  PrevAutoTakeState: Boolean;    // Prev Timer Event AutoTake State
  PrevUIDisabledFlag: Boolean;   // Prev Timer Event UIDisabledFlag State
  procedure FCapturePrepare( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray );
  procedure FCaptureDisableSetFlag();
  procedure FCaptureEnableSetFlag();
  procedure FCaptureDisable();
  procedure FCaptureEnable();
  function  FAutoTakeStateGet() : Boolean; // Device CMS Capture Dlg AutoTake get state (should be set to nil if AutoTake is device built-in or is absent)
  procedure FAutoTakeStateSet( AState : Integer ); // Device CMS Capture Dlg AutoTake set state (should be set to nil if AutoTake is device built-in or is absent)
end; // end of type TN_CMCDServObj7 = class( TK_CMCDServObj )

var
  N_CMCDServObj7: TN_CMCDServObj7;
  CaptForm: TN_CMCaptDev7Form;


const
    // IO_Xray Usb devices
  N_E2V_XRAY_FLAGS_SENSOR_IO_900 = $0001;
  N_E2V_XRAY_FLAGS_SENSOR_IO_750 = $0002;
  N_E2V_XRAY_FLAGS_SENSOR_IO_600 = $0004;
  N_E2V_XRAY_FLAGS_ALL_SENSORS   = $00FF;
  N_E2V_XRAY_FLAGS_FREE_DEVICES  = $0100;
  N_E2V_XRAY_FLAGS_USED_DEVICES  = $0200;
  N_E2V_XRAY_FLAGS_ALL_DEVICES   = $0F00;

  N_E2V_MAX_DEVICE_NAME = 260;


implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0;

//**************************************** TN_CMCDServObj7 **********

//********************************************** TN_CMCDServObj7.DumpStatus ***
// Log device status
//
procedure TN_CMCDServObj7.DumpStatus();
var
  DevStatusStr: String;
begin
  DevStatusStr := 'Unknown';

  if ( DeviceStatus = dsError ) then
    DevStatusStr := 'DeviceError'
  else
    if ( DeviceStatus = dsNotFound ) then
      DevStatusStr := 'DeviceNotFound'
  else
    if ( DeviceStatus = dsFound ) then
      DevStatusStr := 'DeviceFound'
  else
    if ( DeviceStatus = dsOpened ) then
      DevStatusStr := 'DeviceOpened'
  else
    if ( DeviceStatus = dsArmed ) then
      DevStatusStr := 'DeviceArmed'
  else
    if ( DeviceStatus = dsTakesXray ) then
      DevStatusStr := 'DeviceTakesXray';

  N_Dump1Str( 'E2V >> device status = ' + DevStatusStr );
end; // procedure TN_CMCDServObj7.DumpStatus


//**************************************** TN_CMCDServObj7.ShowDeviceStatus ***
// Show Device status on form
//
//    Parameters
// frm     - E2V Capture form pointer
// comment - comment, e.g step name, function name etc.
//
procedure TN_CMCDServObj7.ShowDeviceStatus( frm: TN_CMCaptDev7Form;
                                            comment: String );
var
  ErrorText: String;
  ErrorTextArray: array[0..89] of AnsiChar;
  ErrorCode: Integer;
  ResCode: Integer;
  DevInfosCount: Integer;
  LabelColor: TColor;
  LabelText: String;
  DumpText: String;
  XrayCallBack: TXrayCallBack;
begin
  // Initialize variables
  ErrorText := '';
  LabelColor := $000000;
  LabelText  := 'Unknown error';
  DumpText   := '';

  DumpStatus(); // log device status

  XrayCallBack.pcDeviceName := '';
  XrayCallBack.nState := 0;
  DevInfosCount := 0;

  // Check Unplug event
  ResCode := N_CMCDServObj7.GetLastPlugEvent_ext( @XrayCallBack, @DevInfosCount );
  if (0 <> ResCode) then // if Plug or Unplug event detected
  begin
    N_Dump1Str( 'E2V >> Plug event: ResCode = ' + IntToStr( ResCode ) +
//                ' device name = ' + N_AnsiToString( StrPas( XrayCallBack.pcDeviceName ) ) +
                ' device name = ' + N_AnsiToString( AnsiString( XrayCallBack.pcDeviceName ) ) +
                ' nState = ' + IntToStr( XrayCallBack.nState ) +
                ' count = ' + IntToStr( DevInfosCount ) );

    if ( 1 = XrayCallBack.nState ) then // if Unplug event detected
    begin
       DeviceStatus := dsNotFound;
       N_Dump1Str( 'E2V >> Unplug event detected' );
    end;

  end; // if (0 <> ResCode) then // if Plug or Unplug event detected

  if ( DeviceStatus = dsError ) then  // any E2V Error
  begin
    // Disable controls
    frm.cbAutoTake.Enabled := False;
    frm.bnCapture.Enabled := False;
    ErrorText := 'Unknown E2V error';
    // get e2v error code
    ErrorCode := N_CMCDServObj7.GetLastError_ext();

    // if this code <> 0 and error text has obtained
    if (0 <> ErrorCode) then
      if (1 = N_CMCDServObj7.GetLastErrorText_ext( ErrorTextArray, 90 )) then
        ErrorText := 'Error code = ' + IntToStr( ErrorCode ) +
        ' "' + N_AnsiToString( AnsiString( ErrorTextArray ) ) + '"';

    LabelText := ErrorText;  // text for E2V form indicator
    // text for dump
    DumpText := 'ERROR : code = ' + IntToStr( ErrorCode ) +
                   '; text = ' + ErrorText;
  end
  else if ( DeviceStatus = dsNotFound ) then  // not any device found
  begin
    LabelColor := $0000D0;
    LabelText := 'Sensor disconnected';
    DumpText  := 'Device not found';
  end
  else if ( DeviceStatus = dsFound ) then     // found at least 1 E2V device
  begin
    LabelColor := $0000D0;
    LabelText := 'Device found...';
    DumpText  := 'Device found';
  end
  else if ( DeviceStatus = dsOpened ) then    // device opened
  begin
    if frm.cbAutoTake.Checked then                  // if auto mode
    begin
      LabelColor := $009000;
      LabelText := 'Ready to take X-Ray';
      DumpText  := 'Device opened in auto mode';
    end
    else                                            // if manual mode
    begin
      LabelColor := $0090FF;
      LabelText := 'Press Capture button to take an X-Ray';
      DumpText  := 'Device opened in manual mode';
    end;
  end
  else if ( DeviceStatus = dsArmed ) then     // device armed
  begin
    LabelColor := $009000;
    LabelText := 'Ready to take X-Rays';
    DumpText  := 'Device armed';
  end
  else if ( DeviceStatus = dsTakesXray ) then  // device takes X-Ray
  begin
    LabelColor := $900000;
    LabelText := 'Processing';
    DumpText  := 'Device process XRay';
  end;

  N_Dump1Str( 'E2V >> ' + DumpText + '; step = ' + comment );

  // Set indicator Shape and Lable
  frm.StatusShape.Brush.Color := LabelColor;
  frm.StatusLabel.Font.Color  := LabelColor;
  frm.StatusLabel.Caption     := LabelText;

end; // procedure TN_CMCDServObj7.ShowDeviceStatus

//********************************************** TN_CMCDServObj7.CDSInitAll ***
// Load all e2v DLL functions
//
procedure TN_CMCDServObj7.CDSInitAll();
var
  ResCode, BufferSize: Integer;
  buffer:              TN_C1Array;
  IsFunctionsLoaded:   Boolean;
begin

  if ( 0 <> CDSDllHandle ) then  // If DLL already loaded
    Exit;
  // Load e2v DLL
  CDSDllHandle := LoadLibrary( 'EV71JUInterface.dll' );

  // Load all needed e2v functions from DLL
  IsFunctionsLoaded :=
  N_CMV_LoadFunc( CDSDllHandle, @LoadDriverLibrary_ext, 'LoadDriverLibrary'     ) and
  N_CMV_LoadFunc( CDSDllHandle, @LoadDriverLibrary_ext, 'LoadDriverLibrary'     ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetDLLVersion_ext,     'GetDLLVersion'         ) and
  N_CMV_LoadFunc( CDSDllHandle, @SearchDevices_ext,     'XRay_SearchDevices'    ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetDeviceInfo_ext,     'XRay_GetDeviceInfo'    ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetLastError_ext,      'XRay_GetLastError'     ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetLastErrorText_ext,  'XRay_GetLastErrorText' ) and
  N_CMV_LoadFunc( CDSDllHandle, @IsExceptionDetectedWhileLastFunctionCall_ext, 'IsExceptionDetectedWhileLastFunctionCall' ) and
  N_CMV_LoadFunc( CDSDllHandle, @OpenDevice_ext,             'XRay_OpenDevice'        ) and
  N_CMV_LoadFunc( CDSDllHandle, @CloseDevice_ext,            'XRay_CloseDevice'       ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetSensorInfo_ext,          'XRay_GetSensorInfo'     ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetParameters_ext,          'XRay_GetParameters'     ) and
  N_CMV_LoadFunc( CDSDllHandle, @SetParameters_ext,          'XRay_SetParameters'     ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetStatus_ext,              'XRay_GetStatus'         ) and
  N_CMV_LoadFunc( CDSDllHandle, @AutoTest_ext,               'XRay_AutoTest'          ) and
  N_CMV_LoadFunc( CDSDllHandle, @ArmDevice_ext,              'XRay_ArmDevice'         ) and
  N_CMV_LoadFunc( CDSDllHandle, @DisarmDevice_ext,           'XRay_DisarmDevice'      ) and
  N_CMV_LoadFunc( CDSDllHandle, @WaitForImage_ext,           'XRay_WaitForImage'      ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetImageFileSize_ext,       'XRay_GetImageFileSize'  ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetImageFile_ext,           'XRay_GetImageFile'      ) and
  N_CMV_LoadFunc( CDSDllHandle, @IsNewXRayEventDetected_ext, 'IsNewXRayEventDetected' ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetLastPlugEvent_ext,       'GetLastPlugEvent'       ) and
  N_CMV_LoadFunc( CDSDllHandle, @GetSensorPixelSizeInMicrometers_ext, 'GetSensorPixelSizeInMicrometers' ) and

  N_CMV_LoadFunc( CDSDllHandle, @SetSimulationMode_ext,          'SetSimulationMode'          ) and
  N_CMV_LoadFunc( CDSDllHandle, @SimulatePlugEvent_ext,          'SimulatePlugEvent'          ) and
  N_CMV_LoadFunc( CDSDllHandle, @SimulateNewXrayEvent_ext,       'SimulateNewXrayEvent'       ) and
  N_CMV_LoadFunc( CDSDllHandle, @SetSimulationSensorType_ext,    'SetSimulationSensorType'    ) and
  N_CMV_LoadFunc( CDSDllHandle, @SetSimulatedStatus_ext,         'SetSimulatedStatus'         ) and
  N_CMV_LoadFunc( CDSDllHandle, @SetSimulatedExceptionFlag_ext,  'SetSimulatedExceptionFlag'  ) and
  N_CMV_LoadFunc( CDSDllHandle, @SetLastErrorSimulationCode_ext, 'SetLastErrorSimulationCode' ) and
  N_CMV_LoadFunc( CDSDllHandle, @OpenLogFile_ext,                'OpenLogFile'                ) and

  N_CMV_LoadFunc( CDSDllHandle, @LoadCorrectionImageFile_ext,    'XRay_LoadCorrectionImageFile'   ) and
  N_CMV_LoadFunc( CDSDllHandle, @LoadCorrectionImageBuffer_ext,  'XRay_LoadCorrectionImageBuffer' ) and
  N_CMV_LoadFunc( CDSDllHandle, @ApplyCorrectionToImage_ext,     'XRay_ApplyCorrectionToImage'    );

  if not IsFunctionsLoaded then
  begin
    N_CMV_ShowCriticalError( 'E2V', 'Some functions not loaded from DLL' );
    exit;
  end; // if not IsFunctionsLoaded then

  BufferSize := 100;
  SetLength( buffer, BufferSize);

  ResCode := LoadDriverLibrary_ext( @buffer[0], BufferSize );

  if (0 <> ResCode) then
  begin
    N_CMV_ShowCriticalError( 'E2V', 'LoadDriverLibrary error; ' +
                             'code = ' + IntTostr( ResCode ) + '; ' +
                             'list = ' + N_AnsiToString( AnsiString( @buffer[0] ) ) );
    exit;
  end; // if (0 <> ResCode) then

  N_Dump1Str( 'E2V >> LoadDriverLibrary ok' );

  SetLength( buffer, BufferSize);

  GetDLLVersion_ext( @buffer[0], BufferSize );

  N_Dump1Str( 'E2V >> GetDLLVersion = ' + N_AnsiToString( AnsiString( @buffer[0] ) ) );

end; // function TN_CMCDServObj7.CDSInitAll

//********************************************** TN_CMCDServObj7.CDSFreeAll ***
// Unload all e2v DLL functions
//
procedure TN_CMCDServObj7.CDSFreeAll();
begin
  N_Dump1Str( 'Start TN_CMCDServObj7.CDSFreeAll' );

  if CDSDLLHandle <> 0 then // If e2v DLL loaded
  begin
    N_Dump1Str( 'Before EV71JUInterface.dll FreeLibrary' );
    N_b := FreeLibrary( CDSDLLHandle ); /// Free e2v DLL

    if not N_b then
      N_Dump1Str( ' From CDSFreeAll: ' + SysErrorMessage( GetLastError() ) );

    N_Dump1Str( 'After EV71JUInterface.dll FreeLibrary' );
    CDSDLLHandle := 0; // initialize the handle
  end; // if CDSDLLHandle <> 0 then

end; // procedure TN_CMCDServObj7.CDSFreeAll

// ************* E2V interface begin **************

//************************************************* TN_CMCDServObj7.E2VOpen ***
// Open device
//
//   Parameters
// frm - E2V Capture form
//
procedure TN_CMCDServObj7.E2VOpen( frm: TN_CMCaptDev7Form );
var
  DevCount, ResCode: Integer;
begin
  N_Dump1Str('E2V >> E2VOpen begin');

  // if device already found or opened
  if ( DeviceStatus <> dsNotFound ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'open, DeviceStatus <> eDeviceNotFound' );
    Exit;
  end;

  DevCount := 1;  // Max possible Devices
  SetLength( DevNamesA, DevCount * N_E2V_MAX_DEVICE_NAME ); // Buf for all Dev Names

  // try to search devices
  ResCode := SearchDevices_ext( @DevNamesA[1], @DevCount,
                                N_E2V_XRAY_FLAGS_ALL_SENSORS or
                                N_E2V_XRAY_FLAGS_ALL_DEVICES );

  DevNamesS := N_AnsiToString( DevNamesA );

  if ( 0 = ResCode ) then // if error SearchDevices
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'open, SearchDevices error' );

    N_Dump1Str( 'E2V >> DevNames = ' + DevNamesS );
    Exit;
  end; // if ( 0 = ResCode ) then // if error SearchDevices

  if ( 1 > DevCount ) then // if no devices found
  begin
    DeviceStatus := dsNotFound;
    ShowDeviceStatus( frm, 'open, no devices found' );
    Exit;
  end; // if ( 1 > DevCount ) then // if no devices found

  E2VHandle := nil; // Initialize variable
  N_Dump1Str( 'E2V >> handle before OpenDevice = ' + IntToStr( Integer( E2VHandle ) ) );

  // any error when try to open device
  if ( 0 = OpenDevice_ext( @DevNamesA[1], @E2VHandle ) ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'open, OpenDevice error' );
    N_Dump1Str( 'E2V >> handle after OpenDevice = ' + IntToStr( Integer( E2VHandle ) ) );
    Exit;
  end;

  N_Dump1Str( 'E2V >> handle after OpenDevice = ' + IntToStr( Integer( E2VHandle ) ) );

  // if successfully open
  DeviceStatus := dsOpened;
  ShowDeviceStatus( frm, 'open successfully' );

  if E2VFirst or frm.cbAutoTake.Checked then // 1st E2V Launch
    E2VArm( frm );

  E2VFirst := False;
  N_Dump1Str( 'E2V >> E2VOpen end' );
end; // procedure TN_CMCDServObj7.E2VOpen

//******************************************* TN_CMCDServObj7.CorrectSensId ***
// Format Sensor Id as 8 digital number
//
//   Parameters
// frm - E2V Capture form
//
function TN_CMCDServObj7.CorrectSensId( s: String ): String;
var
  i, sz, v: Integer;
begin
  Result := '';
  sz := Length( s );

  if ( sz > 8 ) then
    Exit;

  v := StrToIntDef( '$' + s, 0 );

  if ( v = 0 ) then
    Exit;

  Result := IntToStr( v );
  sz := Length( Result );

  for i := 1 to ( 8 - sz ) do
    Result := '0' + Result;

end; // function TN_CMCDServObj7.CorrectSensId

//************************************************** TN_CMCDServObj7.E2VArm ***
// arm device
//
//   Parameters
// frm - E2V Capture form
//
procedure TN_CMCDServObj7.E2VArm ( frm: TN_CMCaptDev7Form );
var
  ParamStr: String;
  ParamLength, TestResult, TriggerIndex, ResCode: Integer;
  VirtualDevice, binning: Boolean;
  CorrectionFilePathA: AnsiString;
  CorrectionFilePathS: String;
  Len: Integer;
  DevId: String;
begin
  N_Dump1Str( 'E2V >> E2VArm begin' );

  // if device already found or opened
  if ( DeviceStatus <> dsOpened ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'arm, DeviceStatus <> eDeviceOpened' );
    Exit;
  end;

  // if any error when try to get device info
  if ( 0 = GetDeviceInfo_ext( @DevNamesA[1], @info ) ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'arm, GetDeviceInfo error' );
    Exit;
  end;

  // Log device info
  N_Dump1Str( 'E2V >> device info details: ' );
  N_Dump1Str( 'E2V >> DeviceName = ' + N_AnsiToString( AnsiString( info.pcDeviceName ) ) );
  N_Dump1Str( 'E2V >> ModelName = ' + N_AnsiToString( AnsiString( info.pcModelName ) ) );
  N_Dump1Str( 'E2V >> LinkSpeedUsb = ' + info.LinkSpeedUsb );
  N_Dump1Str( 'E2V >> InUse = ' + info.cInUse );

  N_Dump1Str( 'E2V >> try to get parameters' );

  if ( 0 = info.eSensorType ) then // Log sensor type
    N_Dump1Str( 'E2V >> SensorType = 900' )
  else if ( 1 = info.eSensorType ) then
    N_Dump1Str( 'E2V >> SensorType = 750' )
  else if ( 2 = info.eSensorType ) then
    N_Dump1Str( 'E2V >> SensorType = 600' )
  else
  begin
    N_CMV_ShowCriticalError( 'E2V', 'Unknown SensorType' );
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'arm, Unknown SensorType' );
    Exit;
  end; // if ( 0 = info.eSensorType ) then // Log sensor type

  // try to get device parameters into variable "param"
  if ( 0 = GetParameters_ext( E2VHandle, @param, info.eSensorType ) ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'arm, GetParameters error' );
    Exit;
  end;

  // Log parameters obtained
  N_Dump1Str( 'E2V >> parameters: ' );
  N_Dump1Str( 'E2V >> IntegerMode = ' + IntTostr( param.nIntegerMode ) );
  N_Dump1Str( 'E2V >> IntegrationTime = ' + IntTostr( param.nIntegrationTime ) );
  N_Dump1Str( 'E2V >> BiningMode = ' + IntTostr( param.nBiningMode ) );
  N_Dump1Str( 'E2V >> TriggerMode = ' + IntTostr( param.nTriggerMode ) );
  N_Dump1Str( 'E2V >> TriggeringLevel (by default) = ' + IntTostr( param.nTriggeringLevel ) );
  N_Dump1Str( 'E2V >> ChainOffsetSelection = ' + IntTostr( param.nChainOffsetSelection ) );
  N_Dump1Str( 'E2V >> ManualChainOffset = ' + IntTostr( param.nManualChainOffset ) );
  N_Dump1Str( 'E2V >> AutoRearm = ' + IntTostr( param.nAutoRearm ) );
  N_Dump1Str( 'E2V >> Gain = ' + IntTostr( param.nGain ) );

  // set some "param" members to default values
  param.nTriggeringLevel := 250;
  param.nGain := 2;
  param.nAutoRearm := 0;
  param.nBiningMode := 0;

  ParamStr    := PProfile.CMDPStrPar1; // Profile Parameters String
  ParamLength := Length( ParamStr );   // Parameters String length

  VirtualDevice := False;
  binning       := False;

  if ( 6 <= ParamLength ) then // if Parameter String correct
  begin
    if ( '1' = ParamStr[1] ) then
      VirtualDevice := True;

    if ( '1' = ParamStr[2] ) then
      binning := True;

    param.nGain := strtointdef(ParamStr[4], 2);
    TriggerIndex := StrToIntDef( Copy( ParamStr, 5, 2 ), 6 );

    case TriggerIndex of
      0: param.nTriggeringLevel := 20;
      1: param.nTriggeringLevel := 60;
      2: param.nTriggeringLevel := 100;
      3: param.nTriggeringLevel := 140;
      4: param.nTriggeringLevel := 160;
      5: param.nTriggeringLevel := 200;
      6: param.nTriggeringLevel := 250;
      7: param.nTriggeringLevel := 300;
      8: param.nTriggeringLevel := 400;
      9: param.nTriggeringLevel := 550;
      10: param.nTriggeringLevel := 800;
    end; // case TriggerIndex of

  end; // if ( 6 <= ParamLength ) then // if Parameter String correct

  N_Dump1Str( 'E2V >> try to set parameters' );

  if not VirtualDevice then // this parameters only for real device
  begin
    if frm.cbAutoTake.Checked then
      param.nAutoRearm := 1;

    if binning then
      param.nBiningMode := 1;
  end;

  N_Dump1Str( 'E2V >> TriggeringLevel (actual value) = ' +
              inttostr( param.nTriggeringLevel ) );

  // try to apply parameters
  if ( 0 = SetParameters_ext( E2VHandle, @param, info.eSensorType ) ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'arm, SetParameters error' );
    Exit;
  end;

  N_Dump1Str( 'E2V >> handle before GetSensorInfo = ' + IntTostr( Integer( E2VHandle ) ) );

  // try to get sensor info
  if ( 0 = GetSensorInfo_ext( E2VHandle, @sens ) ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'arm, GetSensorInfo error' );
    N_Dump1Str( 'E2V >> handle after GetSensorInfo = ' + IntTostr( Integer( E2VHandle ) ) );
    Exit;
  end; // if ( 0 = GetSensorInfo_ext( E2VHandle, @sens ) ) then

  N_Dump1Str( 'E2V >> sensor info: ' );
  N_Dump1Str( 'E2V >> pcChipNumber = ' + N_AnsiToString( AnsiString( sens.pcChipNumber ) ) );
  N_Dump1Str( 'E2V >> pcChipVersion = ' + N_AnsiToString( AnsiString( sens.pcChipVersion ) ) );
  N_Dump1Str( 'E2V >> pcClientCode = ' + N_AnsiToString( AnsiString( sens.pcClientCode ) ) );
  N_Dump1Str( 'E2V >> pcClientVar = ' + N_AnsiToString( AnsiString( sens.pcClientVar ) ) );
  N_Dump1Str( 'E2V >> pcSerialNumber = ' + N_AnsiToString( AnsiString( sens.pcSerialNumber ) ) );
  N_Dump1Str( 'E2V >> pcID = ' + N_AnsiToString( AnsiString( sens.pcID ) ) );
  N_Dump1Str( 'E2V >> pcLaserUnicID = ' + N_AnsiToString( AnsiString( sens.pcLaserUnicID ) ) );

  N_Dump1Str( 'E2V >> handle after GetSensorInfo = ' + IntTostr( Integer( E2VHandle ) ) );

  pixelSizeH := GetSensorPixelSizeInMicrometers_ext(); // get pixel size

  if binning then // if binnig mode selected
    pixelSizeH := pixelSizeH * 2; // increase pixel size twice

  N_Dump1Str( 'E2V >> image width = ' + IntTostr( sens.usWidth ) +
              ' height = ' + IntTostr( sens.usHeight ) +
              ' pixel size = ' + IntTostr( pixelSizeH ) );

  N_Dump1Str( 'E2V >> try to arm' );

  if VirtualDevice then  // for virtual device - try autotest
  begin
    N_Dump1Str( 'E2V >> try to autotest' );
    N_Dump1Str( 'E2V >> handle before AutoTest = ' + IntTostr( Integer( E2VHandle ) ) );

    // if AutoTest failed
    if ( 0 = AutoTest_ext( E2VHandle, 1, @TestResult ) ) then
    begin
      DeviceStatus := dsError;
      ShowDeviceStatus( frm, 'arm, AutoTest error' );
      N_Dump1Str( 'E2V >> handle after AutoTest = ' + IntTostr( Integer( E2VHandle ) ) );
      Exit;
    end;

    N_Dump1Str( 'E2V >> handle after AutoTest = ' + IntTostr( Integer( E2VHandle ) ) );
    N_Dump1Str( 'E2V >> autotest ok' );
  end
  else                    // for real device - try armdevice
  begin
    N_Dump1Str( 'E2V >> handle before ArmDevice = ' + IntTostr( Integer( E2VHandle ) ) );
    // Calibration
    CorrectionFilePathS := '';
    DevId := N_AnsiToString( AnsiString( info.pcDeviceName ) );
    Len := Length( DevId );

    if ( Len > 6 ) then // Length of DevId > 6
    begin
      // if DevId starts with 'User_#'
      if ( 'user_#' = LowerCase( Copy( DevId, 1, 6 ) ) ) then
      begin
        DevId := Copy( DevId, 7, Len - 6 );
        DevId := CorrectSensId( DevId );

        if ( DevId <> '' ) then // if DevId is not empty
        begin
          // path to correction file
          CorrectionFilePathS := N_CMV_GetWrkDir() + DevId + '.cal';
          N_Dump1Str( 'E2V >> Calibr File = ' + CorrectionFilePathS );

          // if correction file for currect device exists
          if FileExists( CorrectionFilePathS ) then
          begin
            N_Dump1Str( 'E2V >> Load Calibr File' );
            CorrectionFilePathA := N_StringToAnsi( CorrectionFilePathS );
            // Load correction file
            ResCode := LoadCorrectionImageFile_ext( E2VHandle, @CorrectionFilePathA[1] );
            N_Dump1Str( 'E2V >> LoadCorrectionImageFile = ' + IntToStr( ResCode ) );
          end; // if FileExists( CorrectionFilePathS ) then

        end; // if ( DevId <> '' ) then // if DevId is not empty

      end; // if ( 'user_#' = LowerCase( Copy( DevId, 1, 6 ) ) ) then
    end; // if ( Len > 6 ) then // Length of DevId > 6

    if ( 0 = ArmDevice_ext( E2VHandle, 0 ) ) then // if ArmDevice failed
    begin
      DeviceStatus := dsError;
      ShowDeviceStatus( frm, 'arm, ArmDevice error' );
      N_Dump1Str( 'E2V >> handle after ArmDevice = ' + IntTostr( Integer( E2VHandle ) ) );
      Exit;
    end; // if ( 0 = ArmDevice_ext( E2VHandle, 0 ) ) then // if ArmDevice failed

    N_Dump1Str( 'E2V >> handle after ArmDevice = ' + IntTostr( Integer( E2VHandle ) ) );
    N_Dump1Str( 'E2V >> arm ok' );
  end; // if VirtualDevice then  // for virtual device - try autotest

  // if successfully arm
  DeviceStatus := dsArmed;
  ShowDeviceStatus( frm, 'arm successfully' );
  N_Dump1Str( 'E2V >> E2VArm end' );
end; // procedure TN_CMCDServObj7.E2VArm

//********************************************** TN_CMCDServObj7.E2VCapture ***
// E2V try to get image
//
//   Parameters
// frm - E2V Capture form
//
procedure TN_CMCDServObj7.E2VCapture( frm: TN_CMCaptDev7Form );
var
  ImageSize: Integer;
begin
//  N_Dump1Str( 'E2V >> handle after WaitForImage = ' + inttostr( Integer( E2VHandle ) ) );
  N_Dump1Str( 'E2V >> WaitForImage ok' );
//  DeviceStatus := dsTakesXray;
  ShowDeviceStatus( frm, 'Before get image' );

  ImageSize := 0;

  // Get image size, if failed - log error and exit
  if ( 0 = GetImageFileSize_ext( E2VHandle, @ImageSize ) ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'GetImageFileSize error' );
  end; // if ( 0 = GetImageFileSize_ext( E2VHandle, @ImageSize ) ) then

  N_Dump1Str( format( 'E2V >> after GetImageFileSize handle = %d ImageSize = %d',
                      [Integer(E2VHandle),ImageSize] ) );
  if DeviceStatus = dsError then Exit;

  // if image size is incorrect  - ????? WHAT WE NEED TO DO IN THIS CASE
  if ( ImageSize <> sens.usWidth * sens.usHeight * 2 ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'unexpected image_size' );
    Exit;
  end;

  // allocate memory for image array
  if Length( ImageArray ) < ImageSize then
    SetLength( ImageArray, ImageSize );

  N_Dump1Str( 'E2V >> get image begin' );
  // get image file to array
  if ( 0 = GetImageFile_ext( E2VHandle, @ImageArray[0], ImageSize, nil, 0 ) ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'GetImageFile error' );
    Exit;
  end; // if ( 0 = GetImageFile_ext( E2VHandle, @ImageArray[0], ImageSize, nil, 0 ) ) then

  N_Dump1Str( format( 'E2V >> after GetImageFile handle = %d', [Integer(E2VHandle)] ) );
  if DeviceStatus = dsError then Exit;

  N_Dump1Str( 'E2V >> Capture1Slide begin' );
  frm.CMOFCaptureSlide(); // Capture slide
  N_Dump1Str( 'E2V >> Capture1Slide end' );
  DeviceStatus := dsArmed;
  ShowDeviceStatus( frm, 'After image capture' );

  // if manual mode - disarm device
  if not frm.cbAutoTake.Checked then
    E2VDisArm(frm);

  frm.cbAutoTake.Enabled := True;
end; // TN_CMCDServObj7.E2VCapture

//********************************************** TN_CMCDServObj7.E2VOnTimer ***
// E2V timer handler
//
//   Parameters
// frm - E2V Capture form
//
procedure TN_CMCDServObj7.E2VOnTimer( frm: TN_CMCaptDev7Form );
var
  ResCode: Integer;
  ErrorCode: Integer;
  DevInfoCount: Integer;
  XrayCallBack: TXrayCallBack;
  bnCaptureEnabledPrev : Boolean;

label LExit;
begin
  frm.TimerCheck.Enabled := False;

  // Prevent Auto UI set Disable/Enable while Image receiving is started
  if DeviceStatus < dsTakesXray then
  begin
    if PrevUIDisabledFlag <> UIDisabledFlag then
    begin
      N_Dump1Str( format( 'E2VOnTimer >> UIDisabledFlag is changed to %s', [N_B2S(UIDisabledFlag)] ) );
      PrevUIDisabledFlag := UIDisabledFlag;
      if UIDisabledFlag then
        FCaptureDisable()
      else
        FCaptureEnable();
      goto LExit;
    end
    else
    if UIDisabledFlag then
      goto LExit;
  end; // if DeviceStatus < dsTakesXray then

  // Control DeviceStatus State Dump
  if PrevDeviceStatus <> DeviceStatus then
    N_Dump1Str( format( 'E2VOnTimer >> DeviceStatus is changed %d >> %d', [Ord(PrevDeviceStatus),
                                                                           Ord(DeviceStatus)] ) );
  PrevDeviceStatus := DeviceStatus;

  // Control cbAutoTake.Checked State Dump
  if PrevAutoTakeState <> frm.cbAutoTake.Checked then
    N_Dump1Str( format( 'E2VOnTimer >> cbAutoTake.Checked is changed to %s', [N_B2S(frm.cbAutoTake.Checked)] ) );
  PrevAutoTakeState := frm.cbAutoTake.Checked;

  // Control bnCapture.Enabled State
  bnCaptureEnabledPrev  := frm.bnCapture.Enabled;

  // Enable button "Capture" only if device open but not armed
  frm.bnCapture.Enabled := not UIDisabledFlag and
    ((not frm.cbAutoTake.Checked) and ( DeviceStatus = dsOpened ));

  if bnCaptureEnabledPrev <> frm.bnCapture.Enabled then
    N_Dump1Str( 'E2VOnTimer >> bnCapture.Enabled is changed to ' + N_B2S( frm.bnCapture.Enabled ) );

  // fill CALLBACK Structure with default values
  XrayCallBack.pcDeviceName := '';
  XrayCallBack.nState := 0;
  DevInfoCount := 0;

  // Check Unplug event
  ResCode := N_CMCDServObj7.GetLastPlugEvent_ext(@XrayCallBack, @DevInfoCount);

  if (0 <> ResCode) then // if Plug or Unplug event detected
  begin
    N_Dump1Str( 'E2V >> Plug event: ResCode = ' + IntToStr( ResCode ) +
                ' device name = ' + N_AnsiToString( AnsiString( XrayCallBack.pcDeviceName ) ) +
                ' nState = ' + IntToStr( XrayCallBack.nState ) +
                ' count = ' + IntToStr( DevInfoCount ));

    if ( 1 = XrayCallBack.nState ) then // if Unplug event detected
    begin
       DeviceStatus := dsNotFound;
       N_Dump1Str( 'E2V >> Unplug event detected' );
    end;

  end; // if (0 <> ResCode) then // if Plug or Unplug event detected

  if ( DeviceStatus = dsNotFound ) then    // try to open
  begin
    E2VOpen( frm );
  end // if ( DeviceStatus = dsNotFound ) then
  else
  if ( DeviceStatus = dsArmed ) then  // check X-Ray
  begin
    if E2VSimulator then
      SimulateNewXrayEvent_ext();

    if ( 0 <> IsNewXRayEventDetected_ext() ) then  // if X-Ray detected
    begin
      N_Dump1Str( 'E2V >> X-Ray event detected' );
      DeviceStatus := dsTakesXray;
      frm.cbAutoTake.Enabled := FALSE;
      ShowDeviceStatus( frm, 'Xray');
    end;
   end  // if ( DeviceStatus = dsArmed ) then
  else
  if ( DeviceStatus = dsTakesXray ) then  // try to get image
  begin
    N_Dump1Str( 'E2V >> handle before WaitForImage = ' + IntToStr( Integer( E2VHandle ) ) );
    // Wait image - 200 ms, if failed - log error and exit
    ResCode := WaitForImage_ext( E2VHandle, 200 );
    ErrorCode := 0;

    if ( 0 = ResCode ) then // if Wait image error
      ErrorCode := N_CMCDServObj7.GetLastError_ext(); // get error code

    N_Dump1Str( 'E2V >> WaitForImage = ' + IntToStr( ResCode ) +
                ' ErrorCode = ' + IntToStr( ErrorCode ) +
                ' after WaitForImage handle ' + IntToStr( Integer( E2VHandle ) ) );
    // if success or error code = -13 - Aquisition Timeout
    if (0 <> ResCode) then
    begin
      E2VCapture( frm );
    end
    else
    if (  -1 <> ErrorCode ) and
       (  -9 <> ErrorCode ) and
       ( -13 <> ErrorCode ) then
    begin
      DeviceStatus := dsError;
      ShowDeviceStatus( frm, 'WaitForImage error ');
    end;
  end; // if ( DeviceStatus = dsTakesXray ) then

LExit : //*****
  frm.TimerCheck.Enabled := True;
end; // procedure TN_CMCDServObj7.E2VOnTimer

//*********************************************** TN_CMCDServObj7.E2VDisArm ***
// disarm device
//
//   Parameters
// frm - E2V Capture form
//
procedure TN_CMCDServObj7.E2VDisArm( frm: TN_CMCaptDev7Form );
begin
  N_Dump1Str( 'E2V >> disarm begin' );

  // if device is not armed
  if ( ( DeviceStatus <> dsArmed ) and ( DeviceStatus <> dsTakesXray )) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'disarm, device_status <> eDeviceArmed' );
    Exit;
  end; // if ( ( DeviceStatus <> dsArmed ) and ( DeviceStatus <> dsTakesXray )) then

  N_Dump1Str( 'E2V >> handle before disarm = ' + IntToStr( Integer( E2VHandle ) ) );

  if ( 0 = DisarmDevice_ext( E2VHandle ) ) then // if disarm failed
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'disarm DisarmDevice error' );
    N_Dump1Str( 'E2V >> handle after disarm = ' + IntToStr( Integer( E2VHandle ) ) );
    Exit;
  end; // if ( 0 = DisarmDevice_ext( E2VHandle ) ) then // if disarm failed

  DeviceStatus := dsOpened;
  ShowDeviceStatus( frm, 'disarm ok' );
  N_Dump1Str( 'E2V >> handle after disarm = ' + IntToStr( Integer( E2VHandle ) ) );
  N_Dump1Str( 'E2V >> disarm end' );
end; // procedure TN_CMCDServObj7.E2VDisArm

//************************************************ TN_CMCDServObj7.E2VClose ***
// close device
//
//   Parameters
// frm - E2V Capture form
//
procedure TN_CMCDServObj7.E2VClose( frm: TN_CMCaptDev7Form );
begin
  N_Dump1Str( 'E2V >> close device begin' );

  // if device armed
  if ((DeviceStatus = dsArmed) or (DeviceStatus = dsTakesXray)) then
    E2VDisArm(frm);

  // if device is not open
  if ( DeviceStatus <> dsOpened ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, 'close, device_status <> eDeviceOpened' );
  end;

  N_Dump1Str( 'E2V >> handle before close = ' + IntToStr( Integer( E2VHandle ) ) );

  // if close device failed
  if ( 0 = CloseDevice_ext( E2VHandle ) ) then
  begin
    DeviceStatus := dsError;
    ShowDeviceStatus( frm, ' CloseDevice error' );
    N_Dump1Str( 'E2V >> handle after close = ' + IntToStr( Integer( E2VHandle ) ) );
    Exit;
  end; // if ( 0 = CloseDevice_ext( E2VHandle ) ) then

  DeviceStatus := dsNotFound;
  UIDisabledFlag := FALSE;
  N_Dump1Str( 'E2V >> handle after close = ' + IntToStr( Integer( E2VHandle ) ) );
  N_Dump1Str( 'E2V >> close device end' );
end; // procedure TN_CMCDServObj7.E2VClose

//**************************************** TN_CMCDServObj7.E2VProfileToForm ***
// apply device settings to device settings form
//
//   Parameters
// frm - E2V Device Settings form
//
procedure TN_CMCDServObj7.E2VProfileToForm( frm: TN_CMCaptDev7aForm );
var
  ProfileParamStr: String;
  ProfileParamLength: Integer;
begin
  ProfileParamStr := PProfile.CMDPStrPar1;
  ProfileParamLength := Length( ProfileParamStr );
  frm.cbTrigger.ItemIndex := 6;

  if ( 7 > ProfileParamLength ) then
    Exit;

  if ( '1' = ProfileParamStr[1] ) then
    frm.cbVirtual.Checked := True;

  if ( '1' = ProfileParamStr[2] ) then
    frm.cbBinning.Checked := True;

  if ( '1' <> ProfileParamStr[3] ) then
    frm.cbFilter.Checked := False;

  frm.cbGain.ItemIndex := StrToIntDef( ProfileParamStr[4], 2 );
  frm.cbTrigger.ItemIndex := StrToIntDef( Copy( ProfileParamStr, 5, 2 ), 6 );
  frm.eTime.Text := Copy( ProfileParamStr, 7, ProfileParamLength - 6 );
end; // procedure TN_CMCDServObj7.E2VProfileToForm

// E2V interface end

//************************************* TN_CMCDServObj7.CDSGetGroupDevNames ***
// Get E2V Device Name
//
//     Parameters
// AGroupDevNames - given Strings object to fill
//
// Result         - number of all Devices Names
//
function TN_CMCDServObj7.CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer;
begin
  // Add Dummy Name, because group has only one device. Should not be same as Group Name!
  AGroupDevNames.Add( 'E2V' );
  Result := AGroupDevNames.Count;
end; // procedure TN_CMCDServObj7.CDSGetGroupDevNames

//**************************************** TN_CMCDServObj7.CDSGetDevCaption ***
// Get Capture Device Caption by Name
//
//     Parameters
// ADevName - given Device Name
//
// Result   - Returns Device Caption
//
function  TN_CMCDServObj7.CDSGetDevCaption( ADevName: String ): String;
begin
  Result := 'MediaRay Intraoral';
end; // procedure TN_CMCDServObj7.CDSGetDevCaption

//********************************* TN_CMCDServObj7.CDSGetDevProfileCaption ***
// Get Capture Device Profile Caption by Name
//
//     Parameters
// ADevName - given Device Name
//
// Result   - Returns Device Caption
//
function  TN_CMCDServObj7.CDSGetDevProfileCaption( ADevName: String ): String;
begin
  Result := 'MediaRay Intraoral'; // ADevName is not used because group has only one device
end; // procedure TN_CMCDServObj7.CDSGetDevProfileCaption

//**************************************** TN_CMCDServObj7.CDSCaptureImages ***
// Capture images
//
//     Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj7.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                            var ASlidesArray: TN_UDCMSArray );
{
var
  CMCaptDev7Form: TN_CMCaptDev7Form;
  LogMaxSize, LogMaxDays, LogDetails: Integer;
  LogFullNameA: AnsiString;
//  LogDirA: AnsiString;
//  LogNameA: AnsiString;
//  LogDirS: String;
//  LogNameS: String;
}
begin
{
  PProfile := APDevProfile;

  if ( 7 > Length( PProfile.CMDPStrPar1 ) ) then
    PProfile.CMDPStrPar1 := '0012075';

  CDSInitAll();

//  LogDirS := K_GetDirPath( 'LogFiles' );
//  LogNameS   := 'E2V.txt';
//  LogDirA := N_StringToAnsi( LogDirS );
//  LogNameA := N_StringToAnsi( LogNameS );
//  SetLogRecordingMode_ext( 0 ); // remove redundand logs
//  ResCode := OpenLogFile_ext( @LogDirA[1], @LogNameA[1], 1 );

  LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'Dev_E2V.txt' );
  LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
  LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
  LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );

  OpenLogFile_ext( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

//  if ResCode = 0 then
//    N_Dump1Str( 'E2V OpenLogFile Error - ' + LogDirS + LogNameS );

  E2VSimulator := N_MemIniToBool( 'CMS_UserDeb', 'UseE2VSimulator', False );
  if E2VSimulator then
    SetSimulationMode_ext( 1 ); // Set Simulation mode
  SetLength( ASlidesArray, 0 );
  CMCaptDev7Form := TN_CMCaptDev7Form.Create( Application );

  with CMCaptDev7Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    CMOFPProfile    := TK_PCMOtherProfile( APDevProfile ); // set CMCaptDev7Form.CMOFPProfile field
    CMOFDeviceIndex := CDSDevInd;
    Caption         := CMDPCaption;
    CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDev7Form methods
    DeviceStatus   := dsNotFound;
    E2VFirst       := True;
    ShowModal();
  end; // with CMCaptDev7Form, APDevProfile^ do
//  CloseLogFile_ext();
}
  N_Dump1Str( 'MediaRay >> CDSCaptureImages start' );
  FCapturePrepare( APDevProfile, ASlidesArray );
  CaptForm.ShowModal();
  N_Dump1Str( 'MediaRay >> CDSCaptureImages fin' );

end; // procedure TN_CMCDServObj7.CDSCaptureImages

//********************************** TN_CMCDServObj7.CDSStartCaptureToStudy ***
// Start Capture to study
//
//     Parameters
// APDevProfile - pointer to device profile record
// AStudyDevCaptAttrs - resulting Device Capture Interface
// Result - Returns Study Capture State code (TK_CMStudyCaptState)
//
function TN_CMCDServObj7.CDSStartCaptureToStudy(  APDevProfile: TK_PCMDeviceProfile; var AStudyDevCaptAttrs : TK_CMSDCDAttrs ): TK_CMStudyCaptState;
begin

  inherited CDSStartCaptureToStudy( APDevProfile, AStudyDevCaptAttrs );

  with AStudyDevCaptAttrs do
  begin
    FCapturePrepare( APDevProfile, BufSlidesArray );
    CaptForm.tbRotateImage.Visible := FALSE;
    CMSDCDDlg := CaptForm;
    CMSDCDDlgCPanel := CaptForm.CtrlsPanel;
    CMSDCDCaptureDisableProc := FCaptureDisableSetFlag; // Device CMS Capture Dlg disable procedure of object
    CMSDCDCaptureEnableProc  := FCaptureEnableSetFlag; // Device CMS Capture Dlg enable  procedure of object
    CMSDCDAutoTakeStateGetFunc := FAutoTakeStateGet; // Device CMS Capture Dlg AutoTake get state (should be set to nil if AutoTake is device built-in)
    CMSDCDAutoTakeStateSetProc := FAutoTakeStateSet; // Device CMS Capture Dlg AutoTake set state (should be set to nil if AutoTake is device built-in)
  end;
  Result := K_cmscOK;
  N_Dump1Str( 'MediaRay >> CDSStartCaptureToStudy Res=' + IntToStr(Ord(Result)) );


end; // function TN_CMCDServObj7.CDSStartCaptureToStudy

//****************************************** TN_CMCDServObj7.CDSSettingsDlg ***
// call settings dialog
//
//     Parameters
// APDevProfile - pointer to profile
//
procedure TN_CMCDServObj7.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  frm: TN_CMCaptDev7aForm; // E2V Settings form
  SerialNumber, speed, str: String;
  StrLength: Integer;
begin
  PProfile := APDevProfile;

  if (7 > Length( PProfile.CMDPStrPar1 )) then
    PProfile.CMDPStrPar1 := '0012075';

  CDSInitAll();

  frm := TN_CMCaptDev7aForm.Create( Application ); // create E2V caprure form
  frm.BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
  frm.CMOFPDevProfile := APDevProfile;     // link form variable to profile
  frm.Caption := APDevProfile.CMDPCaption; // set form caption
  E2VProfileToForm( frm ); // apply device settings
  // show Sensor Info
  frm.lbModelNameValue.Caption := N_AnsiToString( AnsiString( info.pcModelName ) );

  case info.eSensorType of
  0:  frm.lbSensTypeValue.Caption := 'IO_900';
  1:  frm.lbSensTypeValue.Caption := 'IO_750';
  2:  frm.lbSensTypeValue.Caption := 'IO_600';
  else frm.lbSensTypeValue.Caption := 'Unknown';
  end;

  SerialNumber := 'Unknown';
  str := N_CMV_TrimNullsRight( DevNamesS );
  StrLength := Length( str );

  if ( 6 < StrLength ) then
    SerialNumber := CorrectSensId( Copy( str, 7, StrLength - 6 ) );

  frm.lbSerialNumberValue.Caption := SerialNumber;
  speed := 'Unknown';

  if ( #0 = info.LinkSpeedUsb ) then
    speed := 'Full Speed'
  else if ( #1 = info.LinkSpeedUsb ) then
    speed := 'High Speed';

  frm.lbUSBSpeedValue.Caption := speed ;
  frm.bnLoadCorrectionFile.Enabled := ( SerialNumber <> 'Unknown' );
  frm.ShowModal();  // Show e2v capture form
end; // procedure TN_CMCDServObj7.CDSSettingsDlg

// destructor TN_CMCDServObj7.Destroy
//
destructor TN_CMCDServObj7.Destroy();
begin
  CDSFreeAll();
end; // destructor TN_CMCDServObj7.Destroy

//********************************* TN_CMCDServObj7.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj7.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 23;
end; // function TN_CMCDServObj7.CDSGetDefaultDevIconInd

//********************************** TN_CMCDServObj7.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj7.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'IO';
end; // function TN_CMCDServObj7.CDSGetDefaultDevDCMMod

//*************************************** TN_CMCDServObj7.FAutoTakeStateSet ***
// Capture enable
//
procedure TN_CMCDServObj7.FAutoTakeStateSet( AState: Integer );
begin
  CaptForm.cbAutoTake.Checked := AState <> 0;
  N_Dump1Str( 'E2V >> UI AutoTake is restored' );
end; // procedure TN_CMCDServObj7.FAutoTakeStateSet

//***************************************** TN_CMCDServObj7.FCapturePrepare ***
// Capture Prepare
//
//     Parameters
// APDevProfile - pointer to profile
// ASlidesArray - resulting Slides Array
//
procedure TN_CMCDServObj7.FCapturePrepare( APDevProfile: TK_PCMDeviceProfile;
                                          var ASlidesArray: TN_UDCMSArray );
var
  LogMaxSize, LogMaxDays, LogDetails: Integer;
  LogFullNameA: AnsiString;

begin
  PProfile := APDevProfile;

  if ( 7 > Length( PProfile.CMDPStrPar1 ) ) then
    PProfile.CMDPStrPar1 := '0012075';

  CDSInitAll();

//  LogDirS := K_GetDirPath( 'LogFiles' );
//  LogNameS   := 'E2V.txt';
//  LogDirA := N_StringToAnsi( LogDirS );
//  LogNameA := N_StringToAnsi( LogNameS );
//  SetLogRecordingMode_ext( 0 ); // remove redundand logs
//  ResCode := OpenLogFile_ext( @LogDirA[1], @LogNameA[1], 1 );

  LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'Dev_E2V.txt' );
  LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
  LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
  LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );

  OpenLogFile_ext( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

//  if ResCode = 0 then
//    N_Dump1Str( 'E2V OpenLogFile Error - ' + LogDirS + LogNameS );

  E2VSimulator := N_MemIniToBool( 'CMS_UserDeb', 'UseE2VSimulator', False );
  if E2VSimulator then
    SetSimulationMode_ext( 1 ); // Set Simulation mode
  SetLength( ASlidesArray, 0 );
  CaptForm := TN_CMCaptDev7Form.Create( Application );

  with CaptForm, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    CMOFPProfile    := TK_PCMOtherProfile( APDevProfile ); // set CMCaptDev7Form.CMOFPProfile field
    CMOFDeviceIndex := CDSDevInd;
    Caption         := CMDPCaption;
    CMOFPNewSlides  := @ASlidesArray; // for using in CMCaptDev7Form methods
    DeviceStatus   := dsNotFound;
    E2VFirst       := True;
  end; // with CMCaptDev7Form, APDevProfile^ do

end; // procedure TN_CMCDServObj7.FCapturePrepare

//********************************** TN_CMCDServObj7.FCaptureDisableSetFlag ***
// Capture disable
//
procedure TN_CMCDServObj7.FCaptureDisableSetFlag;
begin
  if not UIDisabledFlag then
    N_Dump1Str( 'E2V >> Set UI disabled flag' );
  UIDisabledFlag := TRUE;
end; // procedure TN_CMCDServObj7.FCaptureDisableSetFlag

//*********************************** TN_CMCDServObj7.FCaptureEnableSetFlag ***
// Capture enable
//
procedure TN_CMCDServObj7.FCaptureEnableSetFlag;
begin
  if UIDisabledFlag then
    N_Dump1Str( 'E2V >> Set UI enabled flag' );
  UIDisabledFlag := FALSE;
end; // procedure TN_CMCDServObj7.FCaptureEnableSetFlag

//***************************************** TN_CMCDServObj7.FCaptureDisable ***
// Capture disable
//
procedure TN_CMCDServObj7.FCaptureDisable;
begin
  if CaptForm.bnCapture.Enabled or CaptForm.cbAutoTake.Checked then
  begin
    N_Dump2Str( 'E2V >> UI disable start' );
    CaptForm.cbAutoTake.Checked := FALSE;
    CaptForm.cbAutoTake.Enabled := FALSE;
    CaptForm.bnCapture.Enabled  := FALSE;
    CaptForm.StatusLabel.Visible := FALSE;
    N_Dump2Str( 'E2V >> UI disable fin' );
  end;
end; // procedure TN_CMCDServObj7.FCaptureDisable

//****************************************** TN_CMCDServObj7.FCaptureEnable ***
// Capture enable
//
procedure TN_CMCDServObj7.FCaptureEnable;
begin
  N_Dump2Str( 'E2V >> UI enable start' );
  CaptForm.bnCapture.Enabled  := TRUE;
  CaptForm.cbAutoTake.Enabled := TRUE;
//  CaptForm.StatusLabel.Caption := '';
  CaptForm.StatusLabel.Visible := TRUE;
  ShowDeviceStatus( CaptForm, 'UI is enabled' );
  N_Dump2Str( 'E2V >> UI enable fin' );
end; // procedure TN_CMCDServObj7.FCaptureEnable

//*************************************** TN_CMCDServObj7.FAutoTakeStateGet ***
// Capture enable
//
function TN_CMCDServObj7.FAutoTakeStateGet: Boolean;
begin
  Result := CaptForm.cbAutoTake.Checked;
end; // function TN_CMCDServObj7.FAutoTakeStateGet

Initialization

  // Create and Register E2V Service Object
  N_CMCDServObj7 := TN_CMCDServObj7.Create( N_CMECD_E2V_Name );

  // Ininialize E2V variables
  N_CMCDServObj7.CDSDllHandle := 0;
  N_CMCDServObj7.PProfile     := nil;
  N_CMCDServObj7.DeviceStatus := dsNotFound;

  N_CMCDServObj7.info.pcDeviceName   := '';
  N_CMCDServObj7.info.pcModelName    := '';
  N_CMCDServObj7.info.LinkSpeedUsb   := ' ';
  N_CMCDServObj7.info.cInUse         := ' ';
  N_CMCDServObj7.info.eSensorType    := 0;
  N_CMCDServObj7.sens.usWidth        := 0;
  N_CMCDServObj7.sens.usHeight       := 0;
  N_CMCDServObj7.sens.pcChipNumber   := '000';
  N_CMCDServObj7.sens.pcChipVersion  := '0';
  N_CMCDServObj7.sens.pcClientCode   := '00';
  N_CMCDServObj7.sens.pcClientVar    := '00';
  N_CMCDServObj7.sens.pcSerialNumber := '0000';
  N_CMCDServObj7.sens.pcID           := '0000';
  N_CMCDServObj7.sens.pcLaserUnicID  := '00000000';

  with K_CMCDRegisterDeviceObj( N_CMCDServObj7 ) do
  begin
    CDSCaption      := 'MediaRay';
    IsGroup         := True;
    ShowSettingsDlg := True;
  end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj7 ) do

end.
