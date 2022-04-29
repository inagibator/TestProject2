unit N_CMCaptDev11;
// Trident device interface

// 2014.01.04 Added USB plug / unplug reaction by Valery Ovechkin
// 2014.01.04 Added conditional compiling for UITypes by Valery Ovechkin
// 2014.01.04 Fixed indicators by Valery Ovechkin
// 2014.01.04 Fixed Dump captions for API calls by Valery Ovechkin
// 2014.01.04 Fixed Threshold = 50 for new empty profile by Valery Ovechkin
// 2014.01.04 Fixed default values for delays parameters by Valery Ovechkin
// 2014.01.04 Added integration time profile parameter by Valery Ovechkin
// 2014.01.23 Changed N_CMCDServObj11.Gains array by Valery Ovechkin
// 2014.03.20 Changed Multithreading use by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.07.03 Thread Code redesign by Alex Kovalev
// 2014.09.08 Fixed TRI_GetTrueImageBuffer return value check by Valery Ovechkin
// 2014.09.15 Fixed File exceptions processing ( like i/o 32, etc. ) by Valery Ovechkin
// 2014.09.15 Standartizing ( All functions parameters name starts from 'A' ) by Valery Ovechkin
// 2014.10.20 Fixed for using new SDK by Valery Ovechkin
// 2015.01.15 Profile parameters parsing fixed by Valery Ovechkin
// 2015.06.15 Unplug errors fixed by Valery Ovechkin
// 2015.06.16 Correction Files reading fixed by Valery Ovechkin
// 2015.06.18 Correction Files names fixed by Valery Ovechkin
// 2015.06.19 Correction Mode Profile Parameter added by Valery Ovechkin
// 2015.06.22 Default Correction Mode set to "4" by Valery Ovechkin
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface

uses
  Windows, Classes, Messages, Forms, Graphics, StdCtrls, ExtCtrls, WinSock, Types, SysUtils,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND}
  K_CM0, K_CMCaptDevReg,
  N_Types, N_CMCaptDev0, N_CMCaptDev11F, N_CMCaptDev11aF;

  const DBT_DEVICEARRIVAL         = $8000; // USB device arrival event
  const DBT_DEVICEREMOVECOMPLEATE = $8004; // USB device removal event
  const UNPLUG_MESSAGE = 'The system has detected that your sensor is disconnected.'     + #13#10 +
                         'Please connect the sensor to your PC and restart the Capture.' + #13#10 +
                         'Press OK to continue';

type TStrIniSensor = record
  theInitFile:        PAnsiChar;
  IniSensorCallBack:  Pointer;
  CallBackParameters: Pointer;
end;

type PTStrIniSensor = ^TStrIniSensor;


type TStrImageAcq = record
  theHandle: Integer;
  theImageBuf: PByte;
  theImageBufSizePtr: PInteger;
  theTimeout: PTimeVal;
  ImageStatus: Integer;
  AcqImageCallBack: Pointer;
  CallBackParameters: Pointer;
end;

TPStrImageAcq = ^TStrImageAcq;

type TTridentState = ( // device states enum
  tsError,        // any error
  tsNotInited,    // initial state while dll not initialize device driver yet
  tsParamsChange, // changing device parameter like Threshold, Gain, Timeout, etc.
  tsNotFound,     // there no devices found
  tsAmbiguous,    // there more than 1 device presented
  tsFound,        // there is exactly 1 device
  tsOpening,      // device opening
  tsOpened,       // device opened but not armed yet
  tsArmed,        // device armed
  tsBadImage,     // incorrect image get - not used in current implementation
  tsImageReady    // correct image ready
);

type TN_CMCDServObj11 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer
  DevStatus:     TTridentState;
  DevErrorStr:   String;

  CaptDlgActive: Boolean;
  ExtLogDir:     String;
  ExtLogFile:    String;
  TimeBefore:    String;
  TimeAfter:     String;
  TickBefore:    int64;
  TickAfter:     int64;
  FuncParams:    TN_CMV_FuncParams;
  SensorInfo:    TStrIniSensor;
  TridentHandle: Integer;
  Simulator:     Boolean;

  CaptForm:      TN_CMCaptDev11Form;
  SetupForm:     TN_CMCaptDev11aForm;

  ImageWidth:    TN_Int2;
  ImageHeight:   TN_Int2;
  ImageSize:     Integer;
  ImageBuf:      TN_BArray;
  ImageBufCapt:  Array of TN_Int2;
  AcqTimeOut:    TTimeVal;

  Thresholds:    Array of Byte;
  Gains:         Array of Float;
  Timeouts:      Array of Integer;
  IntegrTimes:   Array of TN_Int2;

  ThresholdPos:  Integer;
  GainPos:       Integer;
  TimeoutPos:    Integer;
  IntegrTimePos: Integer;

  SerialNum:     String;
  DriverVersion: Float;

  offsetCorrFile: String;
  gainCorrFile:   String;
  pixmapCorrFile: String;

  TimerInterval:     Integer;
  TimerCount:        Integer;
  TimerCountCurrent: Integer;
  ProfileTimeout:    Integer;
  Tick:              Int64;

  USBHandle:         Pointer;
  SimulatorTimeOut:  Integer;
  DeviceBusy:        Boolean;
  ImgStruct:         TStrImageAcq;
  CorrectionMode:    Integer;

  // Imported functions from Trident DLL
  TRI_Init_Ori:           procedure ( APChar: PAnsiChar ); cdecl;
  TRI_Open:               function  ( APChar: PAnsiChar ): Integer; cdecl;
  TRI_Enable:             function  ( AInt: Integer ): Integer; cdecl;
  TRI_PrepareSensor:      function  ( APChar: PAnsiChar ): Integer; cdecl;
  TRI_ConfigureRegisters: procedure ( AInt: Integer ); cdecl;

  TRI_GetNumPresent:      function  (): Integer;cdecl;
  TRI_GetSerialNumList:   function  ( ABuf: TN_PAnsiCharArray; ANum1, ANum2: Integer ): Integer;cdecl;
  TRI_GetSerialNum:       function  ( AHandle: Integer; ABuf: PAnsiChar; ABufSize: Integer ): Integer; cdecl;
  TRI_GetVersion:         function  (): Float; cdecl;

  TRI_GetImageDimensions: function  ( AHandle: Integer; AHeight, AWidth: TN_PInt2 ): Integer; cdecl;
  TRI_GetImageSize:       function  ( AHandle: Integer ): Integer; cdecl;
  TRI_GetThresholdLevel:  function  ( AHandle: Integer; APThreshold: PByte ): Integer; cdecl;
  TRI_GetDigitalGain:     function  ( AHandle: Integer; APGain: PFloat ): Integer; cdecl;
  TRI_GetIntegrationTime: function  ( AHandle: Integer; APIntTime: TN_PInt2 ): Integer; cdecl;
  TRI_SetThresholdLevel:  function  ( AHandle: Integer; AThreshold: Byte ): Integer; cdecl;
  TRI_SetDigitalGain:     function  ( AHandle: Integer; AGain: Float ): Integer; cdecl;
  TRI_SetIntegrationTime: function  ( AHandle: Integer; AIntTime: TN_Int2 ): Integer; cdecl;

  TRI_Capture:            function  ( AHandle, AMode: Integer ): Integer; cdecl;
  TRI_AcqImage:           function  ( APImgStruct: TPStrImageAcq ): Integer; cdecl;

  TRI_GetTrueImageBuffer: function  ( APBuf1: TN_PInt2; APBuf2: PByte; ANum1, ANum2: Integer ): Integer; cdecl;
  TRI_WriteBufferInRaw:   function  ( AFileName: PAnsiChar; ABuf: TN_PInt2; AHeight, AWidth: TN_Int2 ): Integer; cdecl;
  TRI_WriteBufferInTiff:  function  ( AFileName: PAnsiChar; ABuf: TN_PInt2; AHeight, AWidth: TN_Int2 ): Integer; cdecl;
  TRI_DoCorrections:      function  ( ABuf: TN_PInt2; AOffsetFile, AGainFile, APixmapFile: PAnsiChar; ATheLineLength, ATheNumLines, ACorrectionMode: TN_Int2 ): Integer; cdecl;

  TRI_CancelImageAcquisition: procedure(); cdecl;

  TRI_Disable:            function ( AHandle: Integer   ): Integer; cdecl;
  TRI_Close:              function ( APHandle: PInteger ): Integer; cdecl;
  TRI_CleanUp:            procedure(); cdecl;

  function  CountDevices(): Integer;
  function  DevStatusToStr( ADevStatus: TTridentState ): String;
  procedure LogDevStatus();
  procedure StartExtLog ();
  procedure FinishExtLog( AFunc, ARes: String; AClearAtTheEnd : Boolean = True );
  procedure ShowError   ();

  function  TridentCheckError( AStage, AFunc: String; ACode: Integer ): Boolean;
  function  TridentCheck     ( AStage, AFunc: String; ACode: Integer ): Boolean;

  procedure ShowDeviceStatus     ( AFrm: TN_CMCaptDev11Form );
  procedure ShowDeviceStatusSetup( AFrm: TN_CMCaptDev11aForm );

  procedure TridentOnTimer( ACaptForm: TN_CMCaptDev11Form; ASetupForm: TN_CMCaptDev11aForm );

  procedure TridentInit     ();
  procedure TridentFree     ();
  procedure TridentOpen     ();
  procedure TridentGetInfo  ();
  procedure TridentSetParams();
  procedure TridentArm      ();
  procedure TridentDisArm   ();
  procedure TridentCapture  ( ACaptForm: TN_CMCaptDev11Form );

  procedure CDSInitAll();
  procedure CDSFreeAll();

  function  CDSGetGroupDevNames    ( AGroupDevNames: TStrings): Integer; override;
  function  CDSGetDevCaption       ( ADevName: String ): String; override;
  function  CDSGetDevProfileCaption( ADevName: String ): String; override;
  procedure CDSCaptureImages       ( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg         ( APDevProfile: TK_PCMDeviceProfile ); override;
  procedure USBProc                ( var AMsg: TMessage );
  function  CDSGetDefaultDevIconInd( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCDServObj11 = class( TK_CMCDServObj )

var
  N_CMCDServObj11: TN_CMCDServObj11;
  v_i: Integer;

implementation

uses
  Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0;

//************************************************************* AcqCallBack ***
// Callback for acquisition
//
//    Parameters
// APtr - Pointer, not used now, can be nil
//
procedure AcqCallBack( APtr: Pointer ); stdcall;
begin
  N_CMCDServObj11.DevStatus := tsImageReady;
  Application.ProcessMessages;
end; // procedure AcqCallBack

//******************************************* TN_CMCDServObj11.CountDevices ***
// Count Devices
//
function TN_CMCDServObj11.CountDevices(): Integer;
begin
  CDSInitAll();
  N_CMCDServObj11.TRI_Init_Ori( nil );
  Result := N_CMCDServObj11.TRI_GetNumPresent();
  N_CMCDServObj11.TRI_CleanUp();
  FreeLibrary( CDSDllHandle );
  CDSDllHandle := 0;
end; // function TN_CMCDServObj11.CountDevices

//***************************************** TN_CMCDServObj11.DevStatusToStr ***
// Device Status to string
//
//    Parameters
// ADevStatus - Device Status
//
function TN_CMCDServObj11.DevStatusToStr( ADevStatus: TTridentState ): String;
begin
  Result := 'Unknown';

  if ( ADevStatus = tsError ) then
    Result := 'Error'
  else if ( ADevStatus = tsNotInited ) then
    Result := 'NotInited'
  else if ( ADevStatus = tsParamsChange ) then
    Result := 'ParamsChange'
  else if ( ADevStatus = tsNotFound ) then
    Result := 'NotFound'
  else if ( ADevStatus = tsAmbiguous ) then
    Result := 'Ambiguous'
  else if ( ADevStatus = tsFound ) then
    Result := 'Found'
  else if ( ADevStatus = tsOpening ) then
    Result := 'Opening ' + IntToStr( TimerCountCurrent ) + ' / ' + IntToStr( TimerCount )
  else if ( ADevStatus = tsOpened ) then
    Result := 'Opened'
  else if ( ADevStatus = tsArmed ) then
    Result := 'Armed'
  else if ( ADevStatus = tsBadImage ) then
    Result := 'BadImage'
  else if ( ADevStatus = tsImageReady ) then
    Result := 'ImageReady';

end; // function TN_CMCDServObj11.DevStatusToStr

//******************************************* TN_CMCDServObj11.LogDevStatus ***
// Log device status
//
procedure TN_CMCDServObj11.LogDevStatus();
begin
  N_Dump1Str( 'Trident >> ' + DevStatusToStr( DevStatus ) );
end; // procedure TN_CMCDServObj11.LogDevStatus

//******************************************** TN_CMCDServObj11.StartExtLog ***
// prepare extended log, set time and tick count before Trident function call
//
procedure TN_CMCDServObj11.StartExtLog();
begin
  SetLength( FuncParams, 0 );
  TimeBefore := N_CMV_dtStr();
  TickBefore := GetTickCount();
end; // procedure TN_CMCDServObj11.StartExtLog

//******************************************* TN_CMCDServObj11.FinishExtLog ***
// Add Last Trident Function Call to Extended log and finalize extended log
//
//    Parameters
// AFunc          - desired function name
// ARes           - function call result
// AClearAtTheEnd - if True - clear log at the end
//
procedure TN_CMCDServObj11.FinishExtLog( AFunc, ARes: String; AClearAtTheEnd : Boolean = True );
begin
  TimeAfter := N_CMV_dtStr();
  TickAfter := GetTickCount();
  N_CMV_DoExtendedLog( AFunc, ARes,
                       TimeBefore, TimeAfter, IntToStr( TickAfter - TickBefore ),
                       FuncParams, ExtLogDir, ExtLogFile, AClearAtTheEnd );

end; // procedure TN_CMCDServObj11.FinishExtLog

//********************************************** TN_CMCDServObj11.ShowError ***
// Show error dialog by DevErrorStr
//
procedure TN_CMCDServObj11.ShowError();
begin
  N_CMV_ShowCriticalError( 'Trident', DevErrorStr );
end; // procedure TN_CMCDServObj11.ShowError

//************************************** TN_CMCDServObj11.TridentCheckError ***
// Log error
//
//    Parameters
// AStage - stage of device work
// AFunc  - function name
// ACode  - numeric error code
// Result - True if no error
//
function TN_CMCDServObj11.TridentCheckError( AStage, AFunc: String; ACode: Integer ): Boolean;
begin
  Result := ( ACode = 0 );

  if not Result then // any error
  begin
    DevStatus   := tsError;
    DevErrorStr := AStage + ' error, code = ' + IntToStr( ACode );
  end; // if not Result then // any error

end; // function TN_CMCDServObj11.TridentCheckError

//******************************************* TN_CMCDServObj11.TridentCheck ***
// Log error and wrong handle
//
//    Parameters
// AStage - stage of device work
// AFunc  - function name
// ACode  - numeric error code
// Result - True if no error
//
function TN_CMCDServObj11.TridentCheck( AStage, AFunc: String; ACode: Integer ): Boolean;
var
  GoodCode: Boolean;
begin
  Result := ( TridentHandle >= 0 );

  if not Result then // wrong handle
    DevStatus   := tsNotFound;

  GoodCode := TridentCheckError( AStage, AFunc, ACode );
  Result := Result and GoodCode;
end; // function TN_CMCDServObj11.TridentCheck

//*************************************** TN_CMCDServObj11.ShowDeviceStatus ***
// Show Device status on capture form
//
//    Parameters
// AFrm     - Trident Capture form pointer
//
procedure TN_CMCDServObj11.ShowDeviceStatus( AFrm: TN_CMCaptDev11Form );
var
  LabelColor: TColor;
  LabelText:  String;
  LabelBold:  Boolean;
  DumpText:   String;
begin
  LabelColor := $000000;
  LabelText  := '';
  DumpText   := '';
  LabelBold  := False;

  if ( DevStatus = tsError ) then // some error
  begin

    if ( 'Wrong device handle' = DevErrorStr ) then
    begin
      LabelColor := $0090FF;
      LabelText  := 'Please wait: powering up the sensor';
    end
    else if ( 'Initialization...' = DevErrorStr ) then
    begin

      if ( 1 = Tri_GetNumPresent() ) then
      begin
        LabelColor := $0090FF;
        LabelText  := 'Please wait: powering up the sensor';
      end
      else
      begin
        LabelColor := $0000FF;
        LabelText  := 'Sensor disconnected';
      end;

      LabelBold := True;
    end
    else
    begin
      LabelColor := $000000;
      LabelText  := 'Error : ' + DevErrorStr;
    end;

    DumpText   := LabelText;
  end
  else if ( DevStatus = tsNotInited ) then // driver not initialized
  begin
    LabelColor := $0090FF;
    LabelText  := 'Please wait: powering up the sensor';
    LabelBold  := True;
    DumpText   := LabelText;
  end
  else if ( DevStatus = tsParamsChange ) then // user changes parameters
  begin
    LabelColor := $0090FF;
    LabelText  := 'Please wait: powering up the sensor';
    LabelBold  := True;
    DumpText   := LabelText;
  end
  else if ( DevStatus = tsNotFound ) then // there are no devices
  begin
    LabelColor := $0000FF;
    LabelText  := 'Sensor disconnected';
    LabelBold  := True;
    DumpText   := LabelText;
  end
  else if ( DevStatus = tsAmbiguous ) then // there are more than one device
  begin
    LabelColor := $0000FF;
    LabelText  := 'There are more than one device';
    DumpText   := LabelText;
  end
  else if ( ( DevStatus = tsFound ) or ( DevStatus = tsOpening ) ) then // there are exactly 1 device
  begin
    LabelColor := $0090FF;
    LabelText  := 'Please wait: powering up the sensor';
    LabelBold  := True;
    DumpText   := LabelText;
  end
  else if ( DevStatus = tsOpened ) then // device opened
  begin
      LabelColor := $0090FF;
      LabelText  := 'Please wait: powering up the sensor';
      LabelBold  := True;
      DumpText   := 'Arming the sensor, auto mode';

      if AFrm.bnCapture.Enabled then
      begin
        LabelColor := $0090FF;
        LabelText  := 'Press Capture button to take an X-Ray';
        DumpText   := 'Device open in manual mode';
      end;

  end
  else if ( DevStatus = tsArmed ) then // device armed and ready to take X-Rays
  begin
    LabelColor := $009000;
    LabelText  := 'Sensor ready';
    DumpText   := 'Device armed';
  end
  else if ( DevStatus = tsBadImage ) then // bad image captured
  begin
    LabelColor := $0090FF;
    LabelText  := 'Wrong Image, rearming...';
    LabelBold  := True;
    DumpText   := 'Wrong Image captured';
  end
  else if ( DevStatus = tsImageReady ) then // good image captured
  begin
    LabelColor := $900000;
    LabelText  := 'Processing';
    DumpText   := 'Image captured';
  end;

  AFrm.cbAutoTake.Enabled := ( ( DevStatus = tsOpened ) or
                               ( DevStatus = tsArmed  ) );

  AFrm.bnCapture.Enabled  := ( ( not AFrm.cbAutoTake.Checked ) and
                               ( DevStatus = tsOpened        ) );

  // Set indicator Shape and Lable
  AFrm.StatusShape.Brush.Color := LabelColor;
  AFrm.StatusLabel.Font.Color  := LabelColor;
  AFrm.StatusLabel.Caption     := LabelText;

  if LabelBold then
    AFrm.StatusLabel.Font.Style  := AFrm.StatusLabel.Font.Style + [fsBold]
  else
    AFrm.StatusLabel.Font.Style  := AFrm.StatusLabel.Font.Style - [fsBold];

  N_Dump1Str( 'Trident >> ' + DumpText );
  AFrm.Repaint();
end; // procedure TN_CMCDServObj11.ShowDeviceStatus

//********************************** TN_CMCDServObj11.ShowDeviceStatusSetup ***
// Show Device status on setup form
//
//    Parameters
// AFrm     - Trident Setup form pointer
//
procedure TN_CMCDServObj11.ShowDeviceStatusSetup( AFrm: TN_CMCaptDev11aForm );
var
  LabelColor: TColor;
  LabelText:  String;
  LabelBold:  Boolean;
  DumpText:   String;
begin
  LabelText  := '';
  DumpText   := '';
  LabelBold  := False;

  AFrm.lbSerNumberValue.Caption     := '';
  AFrm.lbDriverVersionValue.Caption := '';
  AFrm.lbImageSizeValue.Caption     := '';
  AFrm.lbImageDimValue.Caption      := '';

  if ( DevStatus = tsError ) then // some error
  begin

    if ( 'Wrong device handle' = DevErrorStr ) then
    begin
      LabelColor := $0090FF;
      LabelText  := 'Please wait: powering up the sensor';
    end
    else if ( 'Initialization...' = DevErrorStr ) then
    begin

      if ( 1 = Tri_GetNumPresent() ) then
      begin
        LabelColor := $0090FF;
        LabelText  := 'Please wait: powering up the sensor';
      end
      else
      begin
        LabelColor := $0000FF;
        LabelText  := 'Sensor disconnected';
      end;

      LabelBold := True;
    end
    else
    begin
      LabelColor := $000000;
      LabelText  := 'Error : ' + DevErrorStr;
    end;

    DumpText   := LabelText;
  end
  else if ( DevStatus = tsNotInited ) then // driver not initialized
  begin
    LabelColor := $0090FF;
    LabelText  := 'Please wait: powering up the sensor';;
    LabelBold  := True;
    DumpText   := LabelText;
  end
  else if ( DevStatus = tsParamsChange ) then // user changes parameters
  begin
    LabelColor := $0090FF;
    LabelText  := 'Please wait: powering up the sensor';
    LabelBold  := True;
    DumpText   := LabelText;
  end
  else if ( DevStatus = tsNotFound ) then // there are no devices
  begin
    LabelColor := $0000FF;
    LabelText  := 'Sensor disconnected';
    LabelBold  := True;
    DumpText   := LabelText;
  end
  else if ( DevStatus = tsAmbiguous ) then // there are more than one device
  begin
    LabelColor := $0000FF;
    LabelText  := 'There are more than one device ';
    DumpText   := LabelText;
  end
  else if ( ( DevStatus = tsFound ) or ( DevStatus = tsOpening ) ) then // there are exactly 1 device
  begin
    LabelColor := $0090FF;
    LabelText  := 'Please wait: powering up the sensor';
    LabelBold  := True;
    DumpText   := LabelText;
  end
  else if ( DevStatus = tsOpened ) then // device opened
  begin
    LabelColor := $009000;
    LabelText  := 'Device Open';
    DumpText   := 'device found';

    AFrm.lbSerNumberValue.Caption     := SerialNum;
    AFrm.lbDriverVersionValue.Caption := FloatToStr( DriverVersion );
    AFrm.lbImageSizeValue.Caption     := IntToStr( ImageSize ) + ' Bytes';
    AFrm.lbImageDimValue.Caption      := IntToStr( ImageWidth ) + ' * ' +
                                         IntToStr( ImageHeight ) + ' Pixels';

  end
  else // unexpected device status while setup dialog opened
  begin
    LabelColor := $0000FF;
    LabelText  := 'Unexpected status';
    DumpText   := 'Unexpected status in setup';
  end;

  if ( DevStatus = tsNotInited ) then
  begin
    LabelColor := $0090FF;
    LabelText  := 'Please wait: powering up the sensor';
    LabelBold  := True;
  end;

  if ( ( DevStatus = tsFound ) or ( DevStatus = tsOpening ) ) then
  begin
    LabelColor := $0090FF;
    LabelText  := 'Please wait: powering up the sensor';
    LabelBold  := True;
  end;

  // Set indicator Shape and Lable
  AFrm.StatusShape.Brush.Color := LabelColor;
  AFrm.StatusLabel.Font.Color  := LabelColor;
  AFrm.StatusLabel.Caption     := LabelText;

  if LabelBold then
    AFrm.StatusLabel.Font.Style := AFrm.StatusLabel.Font.Style + [fsBold]
  else
    AFrm.StatusLabel.Font.Style := AFrm.StatusLabel.Font.Style - [fsBold];

  AFrm.bnLoadCalibrationFiles.Enabled := ( SerialNum <> '' );
  N_Dump1Str( 'Trident >> ' + DumpText );
  AFrm.Repaint();
//  Application.ProcessMessages;
end; // procedure TN_CMCDServObj11.ShowDeviceStatusSetup

//***************************************** TN_CMCDServObj11.TridentOnTimer ***
// Timer handle for Trident capture form
//
//    Parameters
// ACaptForm  - Trident Capture form pointer
// ASetupForm - Trident Setup Dialog
//
procedure TN_CMCDServObj11.TridentOnTimer( ACaptForm: TN_CMCaptDev11Form;
                                           ASetupForm: TN_CMCaptDev11aForm );
var
  DevCount: Integer;
  CurrentTick: Int64;
begin

  if ( DevStatus = tsOpening ) then
    Inc( TimerCountCurrent );

  LogDevStatus();

  // Stop timer and show device status
  if ( ASetupForm = nil ) then // capture form
  begin
    N_Dump1Str( 'Trident >> Capture.TimerCheck begin' );
    ACaptForm.TimerCheck.Enabled := False;
    ShowDeviceStatus( ACaptForm );
    CurrentTick := GetTickCount();

    // timeout expired
    if ( ( DevStatus = tsArmed ) and
         ( ( CurrentTick < Tick ) or
           ( CurrentTick >= Tick + ( ProfileTimeout * 1000 ) - 1000 ) ) ) then
    begin
//      ShowMessage( 'Timeout expired. The X-Ray Capture interface will be closed. Press OK to continue' );
      K_CMShowMessageDlg( 'Timeout expired. The X-Ray Capture interface will be closed. Press OK to continue', mtWarning );
      ACaptForm.Close();
//      Application.ProcessMessages;
      Exit;
    end;

  end
  else                        // setup dialog
  begin
    N_Dump1Str( 'Trident >> Setup.TimerCheck begin' );
    ASetupForm.TimerCheck.Enabled := False;
    ShowDeviceStatusSetup( ASetupForm );
  end;

  if ( ( DevStatus = tsOpened ) or ( DevStatus = tsArmed ) ) then
  begin
    DevCount := 1;

    if not Simulator then
      DevCount := TRI_GetNumPresent(); // count devices

    if ( DevCount < 1 ) then
      DevStatus := tsNotFound
    else if ( DevCount > 1 ) then
      DevStatus := tsAmbiguous;

  end; // if ( ( DevStatus = tsOpened ) or ( DevStatus = tsArmed ) ) then

  if ( ( DevStatus = tsError        ) or
       ( DevStatus = tsNotInited    ) or
       ( DevStatus = tsParamsChange ) or
       ( DevStatus = tsNotFound     ) or
       ( DevStatus = tsAmbiguous    ) ) then
  begin

    if ( DevStatus = tsError ) then // any error
    begin
      TridentDisarm(); // disarm
      CDSFreeAll();    // uninitilaize drivers and free library
      CDSInitAll();    // load library and initialize drivers
    end
    else
    begin
      CDSInitAll();    // load library and initialize drivers
      TridentInit();
      N_Dump1Str( 'Trident >> Timer.TridentInit' );
    end;

  end
  else if ( ( DevStatus = tsFound ) or ( DevStatus = tsParamsChange ) ) then // exact 1 device presented
  begin

  end
  else if ( DevStatus = tsOpened ) then // device opened
  begin

    if ( ASetupForm = nil ) then // capture form
      if ACaptForm.cbAutoTake.Checked then // auto mode
      begin
        TridentArm();
        N_Dump1Str( 'Trident >> Timer.TridentArm' );
      end; // if ACaptForm.cbAutoTake.Checked then // auto mode

  end
  else if ( DevStatus = tsOpening ) then // exact 1 device presented
  begin

    if ( TimerCountCurrent >= TimerCount ) then // Initialization finished
    begin
      TridentOpen();
      N_Dump1Str( 'Trident >> Timer.TridentOpen' );
    end; // if ( TimerCountCurrent >= TimerCount ) then // Initialization finished

  end;

  if ( ASetupForm = nil ) then // capture form
  begin

    if ( DevStatus = tsBadImage ) then // wrong image
      DevStatus := tsOpened
    else if ( DevStatus = tsImageReady ) then // image captured
      TridentCapture( ACaptForm );

  end; // if ( SetupForm = nil ) then // capture form

  // Start timer and show device status
  if ( ASetupForm = nil ) then // capture form
  begin
    ShowDeviceStatus( ACaptForm );
    ACaptForm.TimerCheck.Enabled := True;
    N_Dump1Str( 'Trident >> Capture.TimerCheck end' );
  end
  else                        // setup dialog
  begin
    ShowDeviceStatusSetup( ASetupForm );
    ASetupForm.TimerCheck.Enabled := True;
    N_Dump1Str( 'Trident >> Setup.TimerCheck end' );
  end;

end; // procedure TN_CMCDServObj11.TridentOnTimer

function SmartInit( prepare: Boolean ): Boolean;
var
  ResCode: Integer;
begin
  Result := False;

  if prepare then
  begin
    N_CMCDServObj11.StartExtLog();
    N_CMCDServObj11.TridentHandle := N_CMCDServObj11.TRI_PrepareSensor( nil );
    N_CMCDServObj11.FinishExtLog( 'TRI_PrepareSensor', '' );

    Result := ( 0 <= N_CMCDServObj11.TridentHandle );
    N_CMCDServObj11.StartExtLog();
    N_CMCDServObj11.TRI_ConfigureRegisters( N_CMCDServObj11.TridentHandle );
    N_CMCDServObj11.FinishExtLog( 'TRI_ConfigureRegisters', '' );
    Exit;
  end;

  N_CMCDServObj11.StartExtLog();
  N_CMCDServObj11.TRI_Init_Ori( nil );
  N_CMCDServObj11.FinishExtLog( 'TRI_Init_Ori', '' );

  N_CMCDServObj11.StartExtLog();
  N_CMCDServObj11.TridentHandle := N_CMCDServObj11.TRI_Open( nil );
  N_CMCDServObj11.FinishExtLog( 'TRI_Open', IntToStr( N_CMCDServObj11.TridentHandle ) );

  if ( 0 > N_CMCDServObj11.TridentHandle ) then
    Exit;

  N_CMCDServObj11.StartExtLog();
  ResCode := N_CMCDServObj11.TRI_Enable( N_CMCDServObj11.TridentHandle );
  N_CMCDServObj11.FinishExtLog( 'TRI_Enable', IntToStr( ResCode ) );

  if ( 0 > ResCode ) then
    Exit;

  N_CMCDServObj11.StartExtLog();
  N_CMCDServObj11.TRI_ConfigureRegisters( N_CMCDServObj11.TridentHandle );
  N_CMCDServObj11.FinishExtLog( 'TRI_ConfigureRegisters', '' );
  Result := True;
end;

//******************************************** TN_CMCDServObj11.TridentInit ***
// Initialize Trident driver
//
procedure TN_CMCDServObj11.TridentInit();
begin
  N_Dump1Str( 'Trident >> TridentInit begin' );
  TridentHandle       := -1;
  DevStatus           := tsError;
  DevErrorStr         := 'Initialization...';
  TimerCountCurrent   := 0;

  if SmartInit( N_MemIniToBool( 'CMS_UserDeb', 'TridentPrepare', False ) ) then
    N_Dump1Str( 'Trident >> SmartInit+' )
  else
    N_Dump1Str( 'Trident >> SmartInit-' );

  if ( TridentHandle < 0 ) then // wrong handle
  begin

    if ( TridentHandle = -2 ) then
      DevStatus := tsNotFound;

    N_Dump1Str( 'Trident >> TridentInit end ( wrong handle )' );
    Exit;
  end; // if ( TridentHandle < 0 ) then // wrong handle

  DevStatus := tsOpening;
  TridentCheckError( 'Initialization', 'TridentInit', TridentHandle );
  N_Dump1Str( 'Trident >> TridentInit end ( right handle )' );
end; // procedure TN_CMCDServObj11.TridentInit

//******************************************** TN_CMCDServObj11.TridentFree ***
// Uninitialize Trident driver
//
procedure TN_CMCDServObj11.TridentFree();
var
  ResCode: Integer;
begin
  N_Dump1Str( 'Trident >> TridentFree begin' );

  if ( TridentHandle >= 0 ) then // try disable
  begin
    StartExtLog();
    SetLength( FuncParams, 1 );
    FuncParams[0].name        := 'Handle';
    FuncParams[0].valueBefore := IntToStr( TridentHandle );
    SetLength( FuncParams[0].pChild, 0 );
    ResCode := 0;

    if ( ( DevStatus <> tsNotFound ) and ( not Simulator ) ) then
      ResCode := TRI_Disable( TridentHandle );

    FuncParams[0].valueAfter := IntToStr( TridentHandle );
    FinishExtLog( 'TRI_Disable', IntToStr( ResCode ) );
    TridentCheck( 'Disable', 'TridentFree', ResCode );
  end; //if ( TridentHandle >= 0 ) then // try disable

  if ( TridentHandle >= 0 ) then // try close
  begin
    StartExtLog();
    SetLength( FuncParams, 1 );
    FuncParams[0].name        := 'Handle';
    FuncParams[0].valueBefore := IntToStr( TridentHandle );
    SetLength( FuncParams[0].pChild, 0 );
    ResCode := 0;

    if not Simulator then
      ResCode := TRI_Close( @TridentHandle );

    FuncParams[0].valueAfter := IntToStr( TridentHandle );
    FinishExtLog( 'TRI_Close', IntToStr( ResCode ) );
    TridentCheckError( 'Close', 'TridentFree', ResCode );
  end; // if ( TridentHandle >= 0 ) then // try close

  StartExtLog();

  if not Simulator then
    TRI_CleanUp();

  FinishExtLog( 'TRI_CleanUp', '' );
  //CDSFreeAll();
  DevStatus := tsNotInited;
  {N_b := FreeLibrary(CDSDllHandle);

  // Free Trident DLL
  if not N_b then
    N_Dump1Str( ' From TridentFree: ' + SysErrorMessage( GetLastError() ) );}

  N_Dump1Str( 'After libtrident.dll FreeLibrary ( TridentFree )' );
  CDSDllHandle := 0; // initialize the handle
  CDSInitAll();
  N_Dump1Str( 'Trident >> TridentFree end' );
end; // procedure TN_CMCDServObj11.TridentFree

//******************************************** TN_CMCDServObj11.TridentOpen ***
// Open and enable device
//
procedure TN_CMCDServObj11.TridentOpen();
var
  DevCount: Integer;
begin
  DeviceBusy := True;
  TridentGetInfo();
  N_Dump1Str( 'Trident >> TridentGetInfo' );
  TridentSetParams();
  N_Dump1Str( 'Trident >> TridentSetParams' );
  DevStatus := tsOpened;

  // count devices
  DevCount := 1;

  if not Simulator then
    DevCount := TRI_GetNumPresent();

  if ( DevCount < 1 ) then // 0 devices
    DevStatus := tsNotFound
  else if ( DevCount > 1 ) then // more than 1 devices
    DevStatus := tsAmbiguous;

  DeviceBusy := False;
end; // procedure TN_CMCDServObj11.TridentOpen

//***************************************** TN_CMCDServObj11.TridentGetInfo ***
// Get device info
//
procedure TN_CMCDServObj11.TridentGetInfo();
var
  ResCode, p:      Integer;
  SerialBuffer: AnsiString;
begin
  // get serial number
  SerialBuffer := '0000000000000000';
  SerialNum := '';

  StartExtLog();
  SetLength( FuncParams, 3 );

  FuncParams[0].name        := 'Handle';
  FuncParams[0].valueBefore := IntToStr( TridentHandle );
  SetLength( FuncParams[0].pChild, 0 );

  FuncParams[1].name        := 'Buffer';
  FuncParams[1].valueBefore := N_AnsiToString( SerialBuffer );
  SetLength( FuncParams[1].pChild, 0 );

  FuncParams[2].name        := 'BufferSize';
  FuncParams[2].valueBefore := '16';
  SetLength( FuncParams[2].pChild, 0 );

  ResCode := 0;
  SerialNum := 'Test SN';

  if not Simulator then
    ResCode := TRI_GetSerialNum( TridentHandle, @SerialBuffer[1], 16 );

  SerialNum := N_AnsiToString( SerialBuffer );
  p := Pos( #0, SerialNum );

  if ( 0 < p ) then
    SerialNum := Copy( SerialNum, 1, p - 1 );


  FuncParams[0].valueAfter := IntToStr( TridentHandle );
  FuncParams[1].valueAfter := SerialNum;
  FuncParams[2].valueAfter := IntToStr( Length( SerialNum ) );
  FinishExtLog( 'TRI_GetSerialNum', IntToStr( ResCode ) );

  if not TridentCheck( 'GetSerialNumber', 'TridentGetInfo', ResCode ) then
    Exit;

  // get driver version
  StartExtLog();
  DriverVersion := 1000;

  if not Simulator then
    DriverVersion := TRI_GetVersion();

  FinishExtLog( 'TRI_GetVersion', FloatToStr( DriverVersion ) );

  // get image dimensions
  ImageWidth := 0;
  ImageHeight := 0;

  StartExtLog();
  SetLength( FuncParams, 3 );

  FuncParams[0].name        := 'Handle';
  FuncParams[0].valueBefore := IntToStr( TridentHandle );
  SetLength( FuncParams[0].pChild, 0 );

  FuncParams[1].name        := 'ImageHeight';
  FuncParams[1].valueBefore := IntToStr( ImageHeight );
  SetLength( FuncParams[1].pChild, 0 );

  FuncParams[2].name        := 'ImageWidth';
  FuncParams[2].valueBefore := IntToStr( ImageWidth );
  SetLength( FuncParams[2].pChild, 0 );

  ResCode     := 0;
  ImageWidth  := 1000;
  ImageHeight := 1000;

  if not Simulator then
    ResCode := TRI_GetImageDimensions( TridentHandle, @ImageHeight, @ImageWidth );

  FuncParams[0].valueAfter := IntToStr( TridentHandle );
  FuncParams[1].valueAfter := IntToStr( ImageHeight );
  FuncParams[2].valueAfter := IntToStr( ImageWidth );
  FinishExtLog( 'TRI_GetImageDimensions', IntToStr( ResCode ) );

  if not TridentCheck( 'TRI_GetImageDimensions', 'TridentGetInfo', ResCode ) then
    Exit;

  // get image size
  StartExtLog();
  SetLength( FuncParams, 1 );

  FuncParams[0].name        := 'Handle';
  FuncParams[0].valueBefore := IntToStr( TridentHandle );
  SetLength( FuncParams[0].pChild, 0 );

  ImageSize := ImageWidth * ImageHeight * 2;

  if not Simulator then
    ImageSize := TRI_GetImageSize( TridentHandle );

  FuncParams[0].valueAfter := IntToStr( TridentHandle );
  FinishExtLog( 'TRI_GetImageSize', IntToStr( ResCode ) );

  if ( ImageSize < ( ImageWidth * ImageHeight * 2 ) ) then
  begin
    DevStatus := tsError;
    DevErrorStr := 'ImageSize < ImageWidth * ImageHeight * 2';
    Exit;
  end; // if ( ImageSize < ( ImageWidth * ImageHeight * 2 ) ) then

end; // procedure TN_CMCDServObj11.TridentGetInfo

//*************************************** TN_CMCDServObj11.TridentSetParams ***
// Open and enable device, set and get parameters
//
procedure TN_CMCDServObj11.TridentSetParams();
var
  ResCode:                             Integer;
  ProfileThreshold, ActualThreshold:   Byte;
  ProfileGain, ActualGain:             Float;
  ProfileIntegrTime, ActualIntegrTime: TN_Int2;
begin
  // Read parameters from Profile
  ThresholdPos   := 5;
  GainPos        := 0;
  TimeoutPos     := 9;
  IntegrTimePos  := 0;
  CorrectionMode := 4;

  if ( PProfile.CMDPStrPar1 <> '' ) then // if profile filled
  begin
    // Read threshold from profile
    ResCode := StrToIntDef( Copy( PProfile.CMDPStrPar1, 1, 2 ), -1 );

    if ( ( ResCode < 0 ) or ( ResCode >= Length( Thresholds ) ) ) then
    begin
      DevStatus   := tsError;
      DevErrorStr := 'Profile corrupted';
      Exit;
    end; // if ( ( ResCode < 0 ) or ( ResCode >= Length( Thresholds ) ) ) then

    ThresholdPos := ResCode;

    // Read gain from profile
    ResCode := StrToIntDef( Copy( PProfile.CMDPStrPar1, 3, 3 ), -1 );

    if ( ( ResCode < 0 ) or ( ResCode >= Length( Gains ) ) ) then
    begin
      DevStatus   := tsError;
      DevErrorStr := 'Profile corrupted';
      Exit;
    end; // if ( ( ResCode < 0 ) or ( ResCode >= Length( Gains ) ) ) then

    GainPos := ResCode;

    // Read timeout from profile
    ResCode := StrToIntDef( Copy( PProfile.CMDPStrPar1, 6, 2 ), -1 );

    if ((ResCode < 0) or (ResCode >= Length(Timeouts))) then
    begin
      DevStatus   := tsError;
      DevErrorStr := 'Profile corrupted';
      Exit;
    end; // if ( ( ResCode < 0 ) or ( ResCode >= Length( Timeouts ) ) ) then

    TimeoutPos := ResCode;

    if ( Length( PProfile.CMDPStrPar1 ) > 9 ) then
    begin

      // Read integration time from profile
      IntegrTimePos := StrToIntDef( Copy( PProfile.CMDPStrPar1, 9, 2 ), 0 );

      if ( Length( PProfile.CMDPStrPar1 ) > 10 ) then
      begin
        CorrectionMode := StrToIntDef( Copy( PProfile.CMDPStrPar1, 11, 1 ), 4 );

        if ( 0 > CorrectionMode ) or ( 4 < CorrectionMode ) then
        begin
          N_CMV_ShowCriticalError( 'Trident', 'Wrong Correction Mode "' +
          IntToStr( CorrectionMode ) + '". It will be set to the default value "4"' );
          CorrectionMode := 4;
        end; // if ( 0 > CorrectionMode ) or ( 4 < CorrectionMode ) then

      end; // if ( Length( PProfile.CMDPStrPar1 ) > 10 ) then

    end; // if ( Length( PProfile.CMDPStrPar1 ) > 9 ) then

  end; // if ( PProfile.CMDPStrPar1 <> '' ) then // if profile filled

  ProfileThreshold  := Thresholds[ThresholdPos];
  ProfileGain       := Gains[GainPos];
  ProfileIntegrTime := IntegrTimes[IntegrTimePos];

  // set parameters

  // set gain
  StartExtLog();
  SetLength( FuncParams, 2 );

  FuncParams[0].name        := 'Handle';
  FuncParams[0].valueBefore := IntToStr( TridentHandle );
  SetLength( FuncParams[0].pChild, 0 );

  FuncParams[1].name        := 'Gain';
  FuncParams[1].valueBefore := FloatToStr( ProfileGain );
  SetLength( FuncParams[1].pChild, 0 );

  ResCode := 0;

  if not Simulator then
    ResCode := TRI_SetDigitalGain( TridentHandle, ProfileGain );

  FuncParams[0].valueAfter := IntToStr( TridentHandle );
  FuncParams[1].valueAfter := FloatToStr( ProfileGain );
  FinishExtLog( 'TRI_SetDigitalGain', IntToStr( ResCode ) );

  if not TridentCheck( 'TRI_SetDigitalGain', 'TridentSetParams', ResCode ) then
    Exit;

  // get gain
  ActualGain := 0;

  StartExtLog();
  SetLength( FuncParams, 2 );

  FuncParams[0].name        := 'Handle';
  FuncParams[0].valueBefore := IntToStr( TridentHandle );
  SetLength( FuncParams[0].pChild, 0 );

  FuncParams[1].name        := 'Gain';
  FuncParams[1].valueBefore := FloatToStr( ActualGain );
  SetLength( FuncParams[1].pChild, 0 );

  ResCode := 0;

  if not Simulator then
    ResCode := TRI_GetDigitalGain( TridentHandle, @ActualGain );

  FuncParams[0].valueAfter := IntToStr( TridentHandle );
  FuncParams[1].valueAfter := FloatToStr( ActualGain );
  FinishExtLog( 'TRI_GetDigitalGain', IntToStr( ResCode ) );

  if not TridentCheck( 'TRI_GetDigitalGain', 'TridentSetParams', ResCode ) then
    Exit;

  // check gain
  if ( Round( ActualGain ) <> Round( ProfileGain ) ) then
  begin
    DevStatus   := tsError;
    DevErrorStr := 'gain not set properly';
    Exit;
  end; // if ( Round( ActualGain ) <> Round( ProfileGain ) ) then

  // set threshold
  StartExtLog();
  SetLength( FuncParams, 2 );

  FuncParams[0].name        := 'Handle';
  FuncParams[0].valueBefore := IntToStr( TridentHandle );
  SetLength( FuncParams[0].pChild, 0 );

  FuncParams[1].name        := 'Threshold';
  FuncParams[1].valueBefore := IntToStr( ProfileThreshold );
  SetLength( FuncParams[1].pChild, 0 );

  ResCode := 0;

  if not Simulator then
    ResCode := TRI_SetThresholdLevel( TridentHandle, ProfileThreshold );

  FuncParams[0].valueAfter := IntToStr( TridentHandle );
  FuncParams[1].valueAfter := IntToStr( ProfileThreshold );
  FinishExtLog( 'TRI_SetThresholdLevel', IntToStr( ResCode ) );

  if not TridentCheck( 'TRI_SetThresholdLevel', 'TridentSetParams', ResCode ) then
    Exit;

  // get threshold
  ActualThreshold := 0;

  StartExtLog();
  SetLength( FuncParams, 2 );

  FuncParams[0].name        := 'Handle';
  FuncParams[0].valueBefore := IntToStr( TridentHandle );
  SetLength( FuncParams[0].pChild, 0 );

  FuncParams[1].name        := 'Threshold';
  FuncParams[1].valueBefore := IntToStr( ActualThreshold );
  SetLength( FuncParams[1].pChild, 0 );

  ResCode := 0;

  if not Simulator then
    ResCode := TRI_GetThresholdLevel( TridentHandle, @ActualThreshold );

  FuncParams[0].valueAfter := IntToStr( TridentHandle );
  FuncParams[1].valueAfter := IntToStr( ActualThreshold );
  FinishExtLog( 'TRI_GetThresholdLevel', IntToStr( ResCode ) );

  if not TridentCheck( 'TRI_GetThresholdLevel', 'TridentSetParams', ResCode ) then
    Exit;

  // check threshold
  if ( ActualThreshold <> ProfileThreshold ) then
  begin
    DevStatus   := tsError;
    DevErrorStr := 'threshold not set properly';
    Exit;
  end; // if ( ActualThreshold <> ProfileThreshold ) then

  // set integretion time
  StartExtLog();
  SetLength( FuncParams, 2 );

  FuncParams[0].name        := 'Handle';
  FuncParams[0].valueBefore := IntToStr( TridentHandle );
  SetLength( FuncParams[0].pChild, 0 );

  FuncParams[1].name        := 'IntegrationTime';
  FuncParams[1].valueBefore := IntToStr( ProfileIntegrTime );
  SetLength( FuncParams[1].pChild, 0 );

  ResCode := 0;

  if not Simulator then
    ResCode := TRI_SetIntegrationTime( TridentHandle, ProfileIntegrTime );

  FuncParams[0].valueAfter := IntToStr( TridentHandle );
  FuncParams[1].valueAfter := IntToStr( ProfileIntegrTime );
  FinishExtLog( 'TRI_SetIntegrationTime', IntToStr( ResCode ) );

  if not TridentCheck( 'TRI_SetIntegrationTime', 'TridentSetParams', ResCode ) then
    Exit;

  // get integretion time
  ActualIntegrTime := 0;

  StartExtLog();
  SetLength( FuncParams, 2 );

  FuncParams[0].name        := 'Handle';
  FuncParams[0].valueBefore := IntToStr( TridentHandle );
  SetLength( FuncParams[0].pChild, 0 );

  FuncParams[1].name        := 'IntegrationTime';
  FuncParams[1].valueBefore := IntToStr( ActualIntegrTime );
  SetLength( FuncParams[1].pChild, 0 );

  ResCode := 0;

  if not Simulator then
    ResCode := TRI_GetIntegrationTime( TridentHandle, @ActualIntegrTime );

  FuncParams[0].valueAfter := IntToStr( TridentHandle );
  FuncParams[1].valueAfter := IntToStr( ActualIntegrTime );
  FinishExtLog( 'TRI_GetIntegrationTime', IntToStr( ResCode ) );

  if not TridentCheck( 'TRI_GetIntegrationTime', 'TridentSetParams', ResCode ) then
    Exit;

  // check integretion time
  if ( ActualIntegrTime <> ProfileIntegrTime ) then
  begin
    DevStatus   := tsError;
    DevErrorStr := 'IntegrTime not set properly';
    Exit;
  end; // if ( ActualIntegrTime <> ProfileIntegrTime ) then

end; // procedure TN_CMCDServObj11.TridentSetParams

//********************************************* TN_CMCDServObj11.TridentArm ***
// Start capturing
//
procedure TN_CMCDServObj11.TridentArm();
var
  ResCode, CaptureMode: Integer;
begin
  N_Dump1Str( 'Trident >> TridentArm begin' );

  if ( DevStatus <> tsOpened ) then
    Exit;

  DevStatus := tsArmed;

  // capture
  CaptureMode := N_MemIniToInt( 'CMS_UserDeb', 'TridentCaptMode', 3 );

  StartExtLog();
  SetLength( FuncParams, 2 );

  FuncParams[0].name        := 'Handle';
  FuncParams[0].valueBefore := IntToStr( TridentHandle );
  SetLength( FuncParams[0].pChild, 0 );

  FuncParams[1].name        := 'CaptureMode';
  FuncParams[1].valueBefore := IntToStr( CaptureMode );
  SetLength( FuncParams[1].pChild, 0 );

  ResCode := 0;

  if not Simulator then
    ResCode := TRI_Capture( TridentHandle, CaptureMode );

  FuncParams[0].valueAfter := IntToStr( TridentHandle );
  FuncParams[1].valueAfter := IntToStr( CaptureMode );
  FinishExtLog( 'TRI_Capture', IntToStr( ResCode ) );

  N_Dump1Str( 'Trident >> TRI_Capture = ' + IntToStr( ResCode ) );

  if not TridentCheck( 'Capture', 'TridentArm', ResCode ) then
    Exit;

  // acquire
  SetLength( ImageBuf, ImageSize );
  SetLength( ImageBufCapt, ImageWidth * ImageHeight );
  N_Dump1Str( 'Trident >> ImageSize = ' + IntToStr( ImageSize ) );
  N_Dump1Str( 'Trident >> ImageWidth = ' + IntToStr( ImageWidth ) );
  N_Dump1Str( 'Trident >> ImageHeight = ' + IntToStr( ImageHeight ) );

  // timeout by default
  ProfileTimeout := N_MemIniToInt( 'CMS_UserDeb', 'TridentDefaultTimeout', 900 );

  // redefine timeout
  if N_MemIniToBool( 'CMS_UserDeb', 'TridentUseTimeout', False ) then
  begin
    ProfileTimeout := Timeouts[TimeoutPos];
  end;

  AcqTimeOut.tv_sec  := ProfileTimeout;
  AcqTimeOut.tv_usec := 0;
  N_Dump1Str( 'Trident >> Timeout = ' + IntToStr( ProfileTimeout ) );
  Tick := GetTickCount();

  ImgStruct.theTimeout         := @AcqTimeOut;
  ImgStruct.theHandle          := TridentHandle;
  ImgStruct.theImageBufSizePtr := @ImageSize;
  ImgStruct.theImageBuf        := @ImageBuf[0];
  ImgStruct.ImageStatus        := 0;
  ImgStruct.AcqImageCallBack   := @AcqCallBack;
  ImgStruct.CallBackParameters := nil;

  ResCode := TRI_AcqImage( TPStrImageAcq( @ImgStruct ) );

  if not TridentCheck( 'AcqImage', 'TridentArm', ResCode ) then
    Exit;

  N_Dump1Str( 'Trident >> TridentArm end' );
end; // procedure TN_CMCDServObj11.TridentArm

//****************************************** TN_CMCDServObj11.TridentDisArm ***
// Cancel capturing
//
procedure TN_CMCDServObj11.TridentDisArm();
begin
  N_Dump2Str( 'Trident >> TridentDisArm Start' );

  while DeviceBusy do
  begin
    //Application.ProcessMessages;
  end;

  if ( DevStatus <> tsArmed ) then
    Exit;

  StartExtLog();

  if not Simulator then
    TRI_CancelImageAcquisition();

  FinishExtLog( 'TRI_AcqImage', '' );
  CDSFreeAll();
  CDSInitAll();
  DevStatus := tsOpened;
  N_Dump2Str( 'Trident >> TridentDisArm Fin' );
end; // procedure TN_CMCDServObj11.TridentDisArm

//***************************************** TN_CMCDServObj11.TridentCapture ***
// Process image
//
//    Parameters
// ACaptForm - Trident Capture form pointer
//
procedure TN_CMCDServObj11.TridentCapture( ACaptForm: TN_CMCaptDev11Form );
var
  ResCode: Integer;
  offsetCorrFileA, gainCorrFileA, pixmapCorrFileA: AnsiString;
  RawImageFileA, TiffImageFileA: AnsiString;
  RawImageFile, TiffImageFile, WrkDir, nImgStr: String;
  FilePrefixes, FilePostfixes: TN_SArray;
begin
  N_Dump1Str( 'Trident >> TridentCapture begin' );
  StartExtLog();
  SetLength( FuncParams, 4 );

  FuncParams[0].name        := 'ImageBuffer2Byte';
  FuncParams[0].valueBefore := 'size( ' + IntToStr( Length( ImageBufCapt ) ) + ')';
  SetLength( FuncParams[0].pChild, 0 );

  FuncParams[1].name        := 'ImageBufferByte';
  FuncParams[1].valueBefore := 'size( ' + IntToStr( Length( ImageBuf ) ) + ')';
  SetLength( FuncParams[1].pChild, 0 );

  FuncParams[2].name        := 'ImageSize';
  FuncParams[2].valueBefore := IntToStr( ImageSize );
  SetLength( FuncParams[2].pChild, 0 );

  FuncParams[3].name        := 'PixelCount';
  FuncParams[3].valueBefore := IntToStr( ImageWidth * ImageHeight );
  SetLength( FuncParams[3].pChild, 0 );

  ResCode := 0;

  if ( N_MemIniToBool( 'CMS_UserDeb', 'TridentGetBuff', True ) and ( not Simulator ) ) then
  begin
    ResCode := TRI_GetTrueImageBuffer( @ImageBufCapt[0], @ImageBuf[0],
                                       ImageSize, ImageWidth * ImageHeight );
  end; // if ( N_MemIniToBool( 'CMS_UserDeb', 'TridentGetBuff', True ) and ( not Simulator ) ) then

  FuncParams[0].valueAfter := 'size( ' + IntToStr( Length( ImageBufCapt ) ) + ')';
  FuncParams[1].valueAfter := 'size( ' + IntToStr( Length( ImageBuf ) ) + ')';
  FuncParams[2].valueAfter := IntToStr( ImageSize );
  FuncParams[3].valueAfter := IntToStr( ImageWidth * ImageHeight );
  FinishExtLog( 'TRI_GetTrueImageBuffer', IntToStr( ResCode ) );
  N_Dump1Str( 'Trident >> TRI_GetTrueImageBuffer = ' + IntToStr( ResCode ) );
  WrkDir         := N_CMV_GetWrkDir();
  offsetCorrFile := WrkDir + SerialNum + '_Offset Image';
  gainCorrFile   := WrkDir + SerialNum + '_Gain Image';
  pixmapCorrFile := WrkDir + SerialNum + '_Pixel Map';

  // if correction files exists
  if ( FileExists( offsetCorrFile ) and FileExists( gainCorrFile ) and
       FileExists( pixmapCorrFile ) ) then
  begin
    N_Dump1Str( 'Trident >> Corrections' );
    offsetCorrFileA := N_StringToAnsi( offsetCorrFile );
    gainCorrFileA   := N_StringToAnsi( gainCorrFile );
    pixmapCorrFileA := N_StringToAnsi( pixmapCorrFile );

    StartExtLog();
    SetLength( FuncParams, 7 );

    FuncParams[0].name        := 'ImageBuffer2Byte';
    FuncParams[0].valueBefore := 'size( ' + IntToStr( Length( ImageBufCapt ) ) + ')';
    SetLength( FuncParams[0].pChild, 0 );

    FuncParams[1].name        := 'OffsetCorrectionFileName';
    FuncParams[1].valueBefore := N_AnsiToString( offsetCorrFileA );
    SetLength( FuncParams[1].pChild, 0 );

    FuncParams[2].name        := 'GainCorrectionFileName';
    FuncParams[2].valueBefore := N_AnsiToString( gainCorrFileA );
    SetLength( FuncParams[2].pChild, 0 );

    FuncParams[3].name        := 'PixmapCorrectionFileName';
    FuncParams[3].valueBefore := N_AnsiToString( pixmapCorrFileA );
    SetLength( FuncParams[3].pChild, 0 );

    FuncParams[4].name        := 'ImageWidth';
    FuncParams[4].valueBefore := IntToStr( ImageWidth );
    SetLength( FuncParams[4].pChild, 0 );

    FuncParams[5].name        := 'ImageHeight';
    FuncParams[5].valueBefore := IntToStr( ImageHeight );
    SetLength( FuncParams[5].pChild, 0 );

    FuncParams[6].name        := 'CorrectionMode';
    FuncParams[6].valueBefore := IntToStr( CorrectionMode );
    SetLength( FuncParams[6].pChild, 0 );

    ResCode := 0;

    if not Simulator then
      ResCode := TRI_DoCorrections( @ImageBufCapt[0], @offsetCorrFileA[1],
                                    @gainCorrFileA[1], @pixmapCorrFileA[1],
                                    ImageWidth, ImageHeight, CorrectionMode );

    FuncParams[0].valueAfter := 'size( ' + IntToStr( Length( ImageBufCapt ) ) + ')';
    FuncParams[1].valueAfter := N_AnsiToString( offsetCorrFileA );
    FuncParams[2].valueAfter := N_AnsiToString( gainCorrFileA );
    FuncParams[3].valueAfter := N_AnsiToString( pixmapCorrFileA );
    FuncParams[4].valueAfter := IntToStr( ImageWidth );
    FuncParams[5].valueAfter := IntToStr( ImageHeight );
    FuncParams[6].valueAfter := IntToStr( CorrectionMode );
    FinishExtLog( 'TRI_DoCorrections', IntToStr( ResCode ) );

    N_Dump1Str( 'Trident >> TRI_DoCorrections = ' + IntToStr( ResCode ) );

    if not TridentCheck( 'TRI_DoCorrections', 'TridentCapture', ResCode ) then
      Exit;

  end;

  // save image on disk in raw and tiff
  if N_MemIniToBool( 'CMS_UserDeb', 'SaveImage', False ) then
  begin
    SetLength(FilePrefixes, 2);
    SetLength(FilePostfixes, 2);
    FilePrefixes[0]  := WrkDir + 'trident_';
    FilePrefixes[1]  := FilePrefixes[0];
    FilePostfixes[0] := '.raw';
    FilePostfixes[1] := '.tiff';

    nImgStr := N_CMV_GetNewNum( FilePrefixes, FilePostfixes, 6 );

    RawImageFile   := FilePrefixes[0] + nImgStr + FilePostfixes[0];
    TiffImageFile  := FilePrefixes[1] + nImgStr + FilePostfixes[1];
    RawImageFileA  := N_StringToAnsi( RawImageFile );
    TiffImageFileA := N_StringToAnsi( TiffImageFile );

    StartExtLog();
    SetLength( FuncParams, 4 );

    FuncParams[0].name        := 'RawImageFileName';
    FuncParams[0].valueBefore := N_AnsiToString( RawImageFileA );
    SetLength( FuncParams[0].pChild, 0 );

    FuncParams[1].name        := 'ImageBuffer2Byte';
    FuncParams[1].valueBefore := 'size( ' + IntToStr( Length( ImageBufCapt ) ) + ')';
    SetLength( FuncParams[1].pChild, 0 );

    FuncParams[2].name        := 'ImageHeight';
    FuncParams[2].valueBefore := IntToStr( ImageHeight );
    SetLength( FuncParams[2].pChild, 0 );

    FuncParams[3].name        := 'ImageWidth';
    FuncParams[3].valueBefore := IntToStr( ImageWidth );
    SetLength( FuncParams[3].pChild, 0 );

    if not Simulator then
      ResCode := TRI_WriteBufferInRaw( @RawImageFileA[1], @ImageBufCapt[0],
                                       ImageHeight, ImageWidth );

    FuncParams[0].valueAfter := N_AnsiToString( RawImageFileA );
    FuncParams[1].valueAfter := 'size( ' + IntToStr( Length( ImageBufCapt ) ) + ')';
    FuncParams[2].valueAfter := IntToStr( ImageHeight );
    FuncParams[3].valueAfter := IntToStr( ImageWidth );
    FinishExtLog( 'TRI_WriteBufferInRaw', IntToStr( ResCode ) );

    N_Dump1Str( 'Trident >> TRI_WriteBufferInRaw = ' + IntToStr(ResCode) +
                ', file: ' + RawImageFile );

    if ( ResCode <> 2 * ImageWidth * ImageHeight ) then
    begin
      DevStatus   := tsError;
      DevErrorStr := 'RawBufferSize <> ImageWidth * ImageHeight';
      Exit;
    end; // if ( ResCode <> 2 * ImageWidth * ImageHeight ) then

    StartExtLog();
    SetLength( FuncParams, 4 );

    FuncParams[0].name        := 'TiffImageFileName';
    FuncParams[0].valueBefore := N_AnsiToString( 'TiffImageFileA' );
    SetLength( FuncParams[0].pChild, 0 );

    FuncParams[1].name        := 'ImageBuffer2Byte';
    FuncParams[1].valueBefore := 'size( ' + IntToStr( Length( ImageBufCapt ) ) + ')';
    SetLength( FuncParams[1].pChild, 0 );

    FuncParams[2].name        := 'ImageHeight';
    FuncParams[2].valueBefore := IntToStr( ImageHeight );
    SetLength( FuncParams[2].pChild, 0 );

    FuncParams[3].name        := 'ImageWidth';
    FuncParams[3].valueBefore := IntToStr( ImageWidth );
    SetLength( FuncParams[3].pChild, 0 );

    ResCode := 0;

    if not Simulator then
      ResCode := TRI_WriteBufferInTiff( @TiffImageFileA[1], @ImageBufCapt[0],
                                        ImageHeight, ImageWidth );

    FuncParams[0].valueAfter := N_AnsiToString( 'TiffImageFileA' );
    FuncParams[1].valueAfter := 'size( ' + IntToStr( Length( ImageBufCapt ) ) + ')';
    FuncParams[2].valueAfter := IntToStr( ImageHeight );
    FuncParams[3].valueAfter := IntToStr( ImageWidth );
    FinishExtLog( 'TRI_WriteBufferInTiff', IntToStr( ResCode ) );

    N_Dump1Str( 'Trident >> TRI_WriteBufferInTiff = ' + IntToStr( ResCode ) +
                ', file: ' + TiffImageFile );

    if ( ResCode <> ImageWidth * ImageHeight ) then
    begin
      DevStatus   := tsError;
      DevErrorStr := 'TiffBufferSize <> ImageWidth * ImageHeight';
      Exit;
    end; // if ( ResCode <> 2 * ImageWidth * ImageHeight ) then

  end; // if N_MemIniToBool( 'CMS_UserDeb', 'SaveTridentImage', False ) then

  ACaptForm.CMOFCaptureSlide();
  DevStatus := tsOpened;
  N_Dump1Str('Trident >> TridentCapture end');
end; // function TN_CMCDServObj11.TridentCapture

//********************************************* TN_CMCDServObj11.CDSInitAll ***
// Load all Trident DLL functions
//
procedure TN_CMCDServObj11.CDSInitAll();
var
  IsFunctionsLoaded: Boolean;
begin
  N_Dump1Str( 'Trident >> CDSInitAll begin' );
  TimerInterval := N_MemIniToInt( 'CMS_UserDeb', 'TridentTimerInterval', 200 );
  TimerCount    := N_MemIniToInt( 'CMS_UserDeb', 'TridentTimerCount', 1 );

  if ( TimerInterval < 55 ) then
    TimerInterval := 55;

  if ( TimerCount < 1 ) then
    TimerCount := 1;

  N_Dump1Str( 'Trident >> TimerInterval = ' + IntToStr( TimerInterval ) );
  N_Dump1Str( 'Trident >> TimerCount = ' + IntToStr( TimerCount ) );

  Simulator         := N_MemIniToBool( 'CMS_UserDeb', 'TridentSimulator', False );
  SimulatorTimeOut  := N_MemIniToInt( 'CMS_UserDeb', 'TridentSimulatorTimeOut', 1000 );

  if ( 0 <> CDSDllHandle ) then // If DLL already loaded
  begin
    Exit;
  end;

  ExtLogDir := K_ExpandFileName( '(#CMSLogFiles#)' );
  // Load trident DLL
  CDSDllHandle := LoadLibrary( 'libtrident.dll' );

  if ( 0 = CDSDllHandle ) then
  begin
    DevErrorStr := 'DLL not loaded';
    ShowError();
    Exit;
  end;

  // Load all needed Trident functions from DLL
  IsFunctionsLoaded :=

  // Initialization functions
  N_CMV_LoadFunc( CDSDllHandle, @TRI_Init_Ori,           'TRI_Init_Ori'           ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_Open,               'TRI_Open'               ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_Enable,             'TRI_Enable'             ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_PrepareSensor,      'TRI_PrepareSensor'      ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_ConfigureRegisters, 'TRI_ConfigureRegisters' ) and

  N_CMV_LoadFunc( CDSDllHandle, @TRI_GetNumPresent,    'TRI_GetNumPresent'    ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_GetSerialNum,     'TRI_GetSerialNum'     ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_GetSerialNumList, 'TRI_GetSerialNumList' ) and

  // get image parameters
  N_CMV_LoadFunc( CDSDllHandle, @TRI_GetImageDimensions, 'TRI_GetImageDimensions' ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_GetImageSize,       'TRI_GetImageSize'       ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_GetVersion,         'TRI_GetVersion'         ) and

  // get device parameters
  N_CMV_LoadFunc( CDSDllHandle, @TRI_GetThresholdLevel,  'TRI_GetThresholdLevel'  ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_GetDigitalGain,     'TRI_GetDigitalGain'     ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_GetIntegrationTime, 'TRI_GetIntegrationTime' ) and

  // set device parameters
  N_CMV_LoadFunc( CDSDllHandle, @TRI_SetThresholdLevel,  'TRI_SetThresholdLevel'  ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_SetDigitalGain,     'TRI_SetDigitalGain'     ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_SetIntegrationTime, 'TRI_SetIntegrationTime' ) and

  // capture image
  N_CMV_LoadFunc( CDSDllHandle, @TRI_Capture,            'TRI_Capture'            ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_AcqImage,           'TRI_AcqImage'           ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_GetTrueImageBuffer, 'TRI_GetTrueImageBuffer' ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_WriteBufferInRaw,   'TRI_WriteBufferInRaw'   ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_WriteBufferInTiff,  'TRI_WriteBufferInTiff'  ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_DoCorrections,      'TRI_DoCorrections'      ) and

  // disarm device
  N_CMV_LoadFunc( CDSDllHandle, @TRI_CancelImageAcquisition, 'TRI_CancelImageAcquisition' ) and

  // close device
  N_CMV_LoadFunc( CDSDllHandle, @TRI_Disable, 'TRI_Disable' ) and
  N_CMV_LoadFunc( CDSDllHandle, @TRI_Close,   'TRI_Close'   ) and

  // uninitialize
  N_CMV_LoadFunc( CDSDllHandle, @TRI_CleanUp, 'TRI_CleanUp' );

  if not IsFunctionsLoaded then // some DLL functions not found
  begin
    DevErrorStr := 'Some functions not loaded from DLL';
    ShowError();
    Exit;
  end; // if not IsFunctionsLoaded then // some DLL functions not found

  N_Dump1Str( 'Trident >> CDSInitAll end' );
end; // procedure TN_CMCDServObj11.CDSInitAll

//********************************************* TN_CMCDServObj11.CDSFreeAll ***
// Unload all Trident DLL functions
//
procedure TN_CMCDServObj11.CDSFreeAll();
begin
  N_Dump1Str( 'Start TN_CMCDServObj11.CDSFreeAll' );

  if CDSDllHandle <> 0 then // If Trident DLL loaded
  begin
    N_Dump1Str( 'Before libtrident.dll FreeLibrary' );
    SetLength( ImageBuf, 0 );

    if ( DevStatus <> tsNotInited ) then
      TridentFree();

    DevStatus := tsNotInited;
    N_Dump1Str( 'After libtrident.dll FreeLibrary' );
    CDSDllHandle := 0; // initialize the handle
  end; // if CDSDllHandle <> 0 then // If Trident DLL loaded

end; // procedure TN_CMCDServObj11.CDSFreeAll

//************************************ TN_CMCDServObj11.CDSGetGroupDevNames ***
// Get Trident Device Name
//
//    Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj11.CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer;
begin
  AGroupDevNames.Add( 'TridentDummy' ); // Dummy Name, because group has only one device
  Result := AGroupDevNames.Count;
end; // procedure TN_CMCDServObj11.CDSGetGroupDevNames

//*************************************** TN_CMCDServObj11.CDSGetDevCaption ***
// Get Capture Device Caption by Name
//
//    Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function TN_CMCDServObj11.CDSGetDevCaption( ADevName: String ): String;
begin
  Result := 'Trident';
end; // procedure TN_CMCDServObj11.CDSGetDevCaption

//******************************** TN_CMCDServObj11.CDSGetDevProfileCaption ***
// Get Capture Device Profile Caption by Name
//
//    Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function TN_CMCDServObj11.CDSGetDevProfileCaption( ADevName: String ): String;
begin
  Result := 'Trident'; // ADevName is not used because group has only one device
end; // procedure TN_CMCDServObj11.CDSGetDevProfileCaption

//*************************************** TN_CMCDServObj11.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj11.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
var
  CMCaptDev11Form: TN_CMCaptDev11Form;
begin

  if ( 1 <> N_CMCDServObj11.CountDevices() ) then // no devices
  begin
    DevStatus := tsNotFound; // set device status
    N_CMV_ShowCriticalError( '', UNPLUG_MESSAGE );
    Exit;
  end; // if ( 1 <> N_CMCDServObj11.CountDevices() ) then // no devices

  PProfile := APDevProfile;
  N_Dump1Str( 'Trident >> CDSCaptureImages begin' );
  CDSInitAll();
  SetLength(ASlidesArray, 0);
  CMCaptDev11Form := TN_CMCaptDev11Form.Create( Application );

  with CMCaptDev11Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile( APDevProfile );
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Trident >> CDSCaptureImages before ShowModal' );
    CaptDlgActive := True;
    TimerCheck.Interval := TimerInterval;
    CaptForm := CMCaptDev11Form;
    ShowModal();
    CaptForm := nil;
    CaptDlgActive := False;
    CDSFreeAll();
    DevStatus := tsNotInited;
    N_Dump1Str( 'Trident >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'Trident >> CDSCaptureImages end' );
end; // procedure TN_CMCDServObj11.CDSCaptureImages

//***************************************** TN_CMCDServObj11.CDSSettingsDlg ***
// call settings dialog
//
//    Parameters
// APDevProfile - pointer to profile
//
procedure TN_CMCDServObj11.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  frm: TN_CMCaptDev11aForm; // Trident Settings form
  i, cnt, len: Integer;
  oldParams: String;
begin

  if ( 1 <> N_CMCDServObj11.CountDevices() ) then // no devices
  begin
    DevStatus := tsNotFound; // set device status
    N_CMV_ShowCriticalError( '', UNPLUG_MESSAGE );
    Exit;
  end; // if ( 1 <> N_CMCDServObj11.CountDevices() ) then // no devices

  PProfile := APDevProfile;
  N_Dump1Str( 'Trident >> CDSSettingsDlg begin' );
  CDSInitAll();
  oldParams := PProfile.CMDPStrPar1;
  len := Length( oldParams );
  N_Dump1Str( 'Trident >> ProfileParamOld = ' + oldParams );

  if ( 10 > len ) then
    oldParams := '0500009100'; // default value

  N_Dump1Str( 'Trident >> ProfileParamNew = ' + oldParams );

  PProfile.CMDPStrPar1 := oldParams;
  frm := TN_CMCaptDev11aForm.Create( application );
  // create Trident setup form
  frm.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
  frm.CMOFPDevProfile := APDevProfile; // link form variable to profile
  frm.Caption := APDevProfile.CMDPCaption; // set form caption

  frm.cbThreshold.Items.Clear;
  cnt := Length( Thresholds );

  for i := 0 to cnt - 1 do
  begin
    frm.cbThreshold.Items.Add( IntToStr( Thresholds[i] ) );
  end;

  frm.cbGain.Items.Clear;
  cnt := Length( Gains );

  for i := 0 to cnt - 1 do
  begin
    frm.cbGain.Items.Add( IntToStr( i + 1 ) );
  end;

  frm.cbTimeout.Items.Clear;
  cnt := Length( Timeouts );

  for i := 0 to cnt - 1 do
  begin
    frm.cbTimeout.Items.Add( IntToStr( Timeouts[i] ) );
  end;

  frm.cbIntegrTime.Items.Clear;
  cnt := Length( IntegrTimes );

  for i := 0 to cnt - 1 do
  begin
    frm.cbIntegrTime.Items.Add( IntToStr( IntegrTimes[i] ) );
  end;

  frm.cbThreshold.ItemIndex := StrToIntDef( Copy( PProfile.CMDPStrPar1, 1, 2 ), 0 );
  frm.cbGain.ItemIndex      := StrToIntDef( Copy( PProfile.CMDPStrPar1, 3, 3 ), 0 );
  frm.cbTimeout.ItemIndex   := StrToIntDef( Copy( PProfile.CMDPStrPar1, 6, 2 ), 0 );
  frm.cbFilter.Checked      := ( PProfile.CMDPStrPar1[8] = '1' );
  frm.cbCorrMode.ItemIndex  := 4;

  if ( Length( PProfile.CMDPStrPar1 ) > 9 ) then
  begin
    frm.cbIntegrTime.ItemIndex := StrToIntDef( Copy( PProfile.CMDPStrPar1, 9, 2 ), 0 );

    if ( Length( PProfile.CMDPStrPar1 ) > 10 ) then
      frm.cbCorrMode.ItemIndex := StrToIntDef( Copy( PProfile.CMDPStrPar1, 11, 1 ), 0 );

  end; // if ( Length( PProfile.CMDPStrPar1 ) > 9 ) then

  oldParams := PProfile.CMDPStrPar1;
  frm.TimerCheck.Interval := TimerInterval;
  frm.lbTimeout.Visible := N_MemIniToBool( 'CMS_UserDeb', 'TridentUseTimeout', False );
  frm.cbTimeout.Visible := frm.lbTimeout.Visible;
  SetupForm := frm;
  frm.ShowModal(); // Show Trident setup form
  SetupForm := nil;

  if CaptDlgActive then // if setup called from capture form
  begin

    if ( oldParams <> PProfile.CMDPStrPar1 ) then
    begin
      TridentFree();
      DevStatus := tsParamsChange;
    end; // if ( oldParams <> PProfile.CMDPStrPar1 ) then

  end
  else // is setup called from the main menu
  begin
    TridentFree();
    DevStatus := tsNotInited;
  end;

  N_Dump1Str( 'Trident >> ProfileParams = ' + PProfile.CMDPStrPar1 );
  N_Dump1Str( 'Trident >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj11.CDSSettingsDlg

//************************************************ TN_CMCDServObj11.USBProc ***
// Process USB Plug / Unplug event
//
//    Parameters
// AMsg - Windows Message
//
procedure TN_CMCDServObj11.USBProc( var AMsg: TMessage );
var
  TridentUSBEvent:  TN_CMV_USBEvent;
  TridentWantedVid: String;
begin
  TridentWantedVid := N_MemIniToString( 'CMS_UserDeb', 'TridentVid', '0403' );

  if ( TridentWantedVid = '' ) then
    Exit;

  TridentUSBEvent := N_CMV_USBGetInfo( AMsg );

  if ( ( TridentUSBEvent.EventType = USBUnplug  ) and
       N_MemIniToBool( 'CMS_UserDeb', 'ShowVid', False ) ) then
  begin
    Showmessage( 'VID = ' + TridentUSBEvent.DevVid +
                 ' PID = ' + TridentUSBEvent.DevPid );
  end;

  if ( ( TridentUSBEvent.DevVid = TridentWantedVid ) or Simulator ) then
  begin

    if ( TridentUSBEvent.EventType = USBUnplug  ) then
    begin

      with N_CMCDServObj11 do
      begin
        //TridentDisArm();
        CDSFreeAll();
        DevStatus := tsNotFound; // set device status
        N_CMV_ShowCriticalError( '', UNPLUG_MESSAGE );

        if ( SetupForm <> nil ) then // Setup Form
        begin
          SetupForm.TimerCheck.Enabled := False;
          SetupForm.Close;
          SetupForm := nil;
        end; // if ( SetupForm <> nil ) then // Setup Form

        if ( CaptForm <> nil ) then // Capture Form
        begin
          CaptForm.TimerCheck.Enabled := False;
          CaptForm.Close;
          CaptForm := nil;
        end; // if ( CaptForm <> nil ) then // Capture Form

      end; // with N_CMCDServObj11 do

    end; // if ( TridentUSBEvent.EventType = USBUnplug  ) then

  end;

end; // procedure TN_CMCDServObj11.USBProc

//******************************** TN_CMCDServObj11.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj11.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 23;
end; // function TN_CMCDServObj11.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj11.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj11.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'IO';
end; // function TN_CMCDServObj11.CDSGetDefaultDevDCMMod

Initialization

// Create and Register Trident Service Object
N_CMCDServObj11 := TN_CMCDServObj11.Create( N_CMECD_Trident_Name );

// Ininialize Trident variables
with N_CMCDServObj11 do
begin
  CDSDllHandle  := 0;
  PProfile      := nil;
  DevStatus     := tsNotInited;
  DevErrorStr   := 'Unknown';
  CaptDlgActive := False;
  ImageWidth    := 0;
  ImageHeight   := 0;
  ImageSize     := 0;
  SetLength( ImageBuf, ImageSize );
  AcqTimeOut.tv_sec  := 0;
  AcqTimeOut.tv_usec := 0;
  TridentHandle      := -1;
  Simulator          := False;

  ExtLogDir  := '';
  ExtLogFile := 'Trident.txt';
  TimeBefore := '';
  TimeAfter  := '';
  TickBefore := 0;
  TickAfter  := 0;

  CaptForm  := nil;
  SetupForm := nil;

  SetLength( FuncParams, 0 );

  SerialNum     := '';
  DriverVersion := 0;

  offsetCorrFile := '';
  gainCorrFile   := '';
  pixmapCorrFile := '';
  TimerInterval     := 200;

  SetLength( Thresholds, 10 );
  Thresholds[0] := 1;
  Thresholds[1] := 2;
  Thresholds[2] := 5;
  Thresholds[3] := 10;
  Thresholds[4] := 20;
  Thresholds[5] := 50;
  Thresholds[6] := 100;
  Thresholds[7] := 150;
  Thresholds[8] := 200;
  Thresholds[9] := 250;

  SetLength( Gains, 255 );

  for v_i := 1 to 255 do
    Gains[v_i - 1] := v_i / 16;

  SetLength( Timeouts, 10 );
  Timeouts[0] := 1;
  Timeouts[1] := 2;
  Timeouts[2] := 5;
  Timeouts[3] := 10;
  Timeouts[4] := 20;
  Timeouts[5] := 30;
  Timeouts[6] := 60;
  Timeouts[7] := 120;
  Timeouts[8] := 300;
  Timeouts[9] := 600;

  SetLength( IntegrTimes, 26 );
  IntegrTimes[0] := 500;
  IntegrTimes[1] := 600;
  IntegrTimes[2] := 700;
  IntegrTimes[3] := 800;
  IntegrTimes[4] := 900;
  IntegrTimes[5] := 1000;
  IntegrTimes[6] := 1100;
  IntegrTimes[7] := 1200;
  IntegrTimes[8] := 1300;
  IntegrTimes[9] := 1400;
  IntegrTimes[10] := 1500;
  IntegrTimes[11] := 1600;
  IntegrTimes[12] := 1700;
  IntegrTimes[13] := 1800;
  IntegrTimes[14] := 1900;
  IntegrTimes[15] := 2000;
  IntegrTimes[16] := 2100;
  IntegrTimes[17] := 2200;
  IntegrTimes[18] := 2300;
  IntegrTimes[19] := 2400;
  IntegrTimes[20] := 2500;
  IntegrTimes[21] := 2600;
  IntegrTimes[22] := 2700;
  IntegrTimes[23] := 2800;
  IntegrTimes[24] := 2900;
  IntegrTimes[25] := 3000;

  USBHandle         := nil;
  SimulatorTimeOut  := 1000;
  DeviceBusy        := False;
  TimerCount        := 0;
  TimerCountCurrent := 0;
  CorrectionMode    := 4;
end; // with N_CMCDServObj11 do

with K_CMCDRegisterDeviceObj( N_CMCDServObj11 ) do
begin
  CDSCaption := 'Trident';
  IsGroup := True;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj11 ) do

end.
