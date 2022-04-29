unit N_CMCaptDev14;
// Hamamatsu device

// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.04.03 Fixed bug and added unplug dialog by Valery Ovechkin
// 2014.04.28 Fixed Multithreading bugs by Valery Ovechkin
// 2014.07.03 Thread Code redesign by Alex Kovalev
// 2014.09.15 Fixed File exceptions processing ( like i/o 32, etc. ) by Valery Ovechkin
// 2014.09.15 Standartizing ( All functions parameters name starts from 'A' ) by Valery Ovechkin
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface

uses
  Windows, Classes, Messages, Forms, Graphics, StdCtrls, ExtCtrls, WinSock, Types,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND}
  K_CM0, K_CMCaptDevReg,
  N_Types, N_CMCaptDev0, N_CMCaptDev14F, N_CMCaptDev14aF;

const
  DEFAULT_START_THRESHOLD = 440;
  DEFAULT_STOP_THRESHOLD  = 437;

  BIG_IMAGE_SIZE     = 4435616;
  BIG_IMAGE_WIDTH    = 1300;
  BIG_IMAGE_HEIGHT   = 1706;
  SMALL_IMAGE_SIZE   = 3012016;
  SMALL_IMAGE_WIDTH  = 1000;
  SMALL_IMAGE_HEIGHT = 1506;

  AUTO_MODE      = 1;
  MANUAL_MODE    = 2;
  FULL_AUTO_MODE = 3;

  UNPLUG_MESSAGE       = 'The system has detected that your sensor is disconnected.'     + #13#10 +
                         'Please connect the sensor to your PC and restart the Capture.' + #13#10 +
                         'Press OK to continue';

  DISCONNECTED_MESSAGE = 'The system has detected that your sensor is disconnected.'   + #13#10 +
                         'Please connect the sensor to your PC and start the Capture.' + #13#10 +
                         'Press OK to continue';

type
THamamatsuState = ( // device states enum
  hsNotInit,    // Initial state
  hsInitError,  // DLL not found or not loaded or some API functions absent
  hsNotFound,   // Devices not found
  hsOpenError,  // Open error
  hsOpened,     // Device opened
  hsArmed,      // Device Armed and ready to take X-Ray
  hsImageReady, // Image Ready
  hsImageCapt   // Image is capturing
);

THamamatsuImageType = ( // image types
  tiBig,   // 1300 * 1706
  tiSmall, // 1000 * 1506
  tiWrong  // wrong
);

UINT_INTEGRATION_PARAMETER = record
  Integration_Start_Threshold: TN_Int2;
  Integration_Stop_Threshold:  TN_Int2;
  Integration_Time:            Double;
end;

PUINT_INTEGRATION_PARAMETER = ^UINT_INTEGRATION_PARAMETER;

UINT_XRAY_IMAGE = record
  Mode: Byte;
  IntegParam: UINT_INTEGRATION_PARAMETER;
end;

UINT_SENSOR_INFORMATION = record
  IntegParam: UINT_INTEGRATION_PARAMETER;
  XXXX: TN_Int2;
  YY:   Byte;
  FW:   Byte;
end;

PUINT_SENSOR_INFORMATION = ^UINT_SENSOR_INFORMATION;

PUINT_XRAY_IMAGE = ^UINT_XRAY_IMAGE;
THANDLE_FUNCTION = function( dh: Integer ): Integer; stdcall;
TIMAGE_FUNCTION  = function( dh: Integer; Buf: TN_BArray; BufLen: PInteger; p: PUINT_XRAY_IMAGE ): Integer; stdcall;
TPARAM_FUNCTION  = function( dh: Integer; Buf: TN_BArray; BufLen: PInteger; p: PUINT_INTEGRATION_PARAMETER ): Integer; stdcall;

type TN_CMCDServObj14 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer
  DevStatus:     THamamatsuState;
  ImgBuf:        TN_BArray;
  CaptForm:      TN_CMCaptDev14Form;
  BufSize:       Integer;
  Device:        Integer;
  Pipe:          Integer;
  Image:         UINT_XRAY_IMAGE;
  IntParam:      UINT_INTEGRATION_PARAMETER;
  SensInfo:      UINT_SENSOR_INFORMATION;
  ThreadCtrl:    TN_CMV_UniThread;
  ImageType:     THamamatsuImageType;
  CaptDlgActive: Boolean;
  USBHandle:     Pointer;

  // User parameters
  Correction:        Boolean;
  IntTime:           Integer;
  FullAutoMode:      Boolean;
  DevSimulator:      Boolean;
  CountBeforeUnplug: Integer;
  SmallSize:         Boolean;
  Timeout:           Integer;
  AC:                Boolean;
  Filter:            Boolean;
  FilterE2V:         Boolean;
  FilterTrident:     Boolean;

  USB_OpenDevice:             function( APid: TN_Int2 ): Integer; stdcall;
  USB_OpenPipe:               THANDLE_FUNCTION;
  USB_OpenTargetDevice:       function( APid, ASerNum: TN_Int2 ): Integer; stdcall;
  USB_CloseDevice:            procedure( AHandle: Integer ); stdcall;
  HPK_GetXrayImage:           TIMAGE_FUNCTION;
  HPK_GetXrayCorrectionImage: TIMAGE_FUNCTION;
  HPK_AbortBulkPipe:          THANDLE_FUNCTION;
  HPK_ForceTrigAndGetDummy:   TIMAGE_FUNCTION;
  HPK_GetTrigPdData:          function( AHandle: Integer; AAt: Double; ABuf: TN_I2Array; APBufLen: PInteger; APIntParam: PUINT_INTEGRATION_PARAMETER ): Integer; stdcall;
  HPK_StopTrigPdData:         TPARAM_FUNCTION;
  HPK_GetSensorInformation:   function( AHandle: Integer; APIntParam: PUINT_INTEGRATION_PARAMETER; APSensorInfo: PUINT_SENSOR_INFORMATION ): Integer; stdcall;  //

  // Thread Syncronized Actions Control
  ThreadSyncFlags:   Integer; // 1 - ShowStatus, 2 - Image processing, 4 - Thread Dump Info
  ThreadSyncDump1:   string; // Thread Dump1 Info
  ThreadSyncDump2:   string; // Thread Dump2 Info

  procedure ThreadSyncActions      ();

  procedure ShowStatusAux          ( ACaptForm: TN_CMCaptDev14Form; ASetupForm:TN_CMCaptDev14aForm; AColor: TColor; AText: String; ABold: Boolean; ADumpText: String = '' );
  procedure ShowStatus             ( ACaptForm: TN_CMCaptDev14Form; ASetupForm:TN_CMCaptDev14aForm );

  procedure ProcessUSB             ( var AMsg: TMessage; ACaptForm: TN_CMCaptDev14Form; ASetupForm:TN_CMCaptDev14aForm );
  procedure CDSFreeAll             ();
  procedure DeviceOpen             ();
  procedure DeviceArm              ();
  procedure DeviceDisarm           ();
  procedure DeviceClose            ();
  function  SetupFormToProfile     ( ASetupForm:TN_CMCaptDev14aForm ): String;
  procedure ApplyProfile           ( ASetupForm:TN_CMCaptDev14aForm );

  function  CDSGetGroupDevNames    ( AGroupDevNames: TStrings): Integer; override;
  function  CDSGetDevCaption       ( ADevName: String ): String; override;
  function  CDSGetDevProfileCaption( ADevName: String ): String; override;
  procedure CDSCaptureImages       ( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg         ( APDevProfile: TK_PCMDeviceProfile ); override;
  function  CDSGetDefaultDevIconInd( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCDServObj14 = class( TK_CMCDServObj )

var
  N_CMCDServObj14: TN_CMCDServObj14;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0;

//************************************** TN_CMCDServObj14.ThreadSyncActions ***
// Done Device Thread Actions Syncronized with Main Application Tread
//
procedure TN_CMCDServObj14.ThreadSyncActions();
begin
  if (ThreadSyncFlags and 1) = 1 then
    ShowStatus( CaptForm, nil );

  if (ThreadSyncFlags and 2) = 2 then
  begin
    if ( BIG_IMAGE_SIZE = BufSize ) then
      CaptForm.CMOFCaptureSlide( BIG_IMAGE_WIDTH, BIG_IMAGE_HEIGHT )
    else if ( SMALL_IMAGE_SIZE = BufSize ) then
      CaptForm.CMOFCaptureSlide( SMALL_IMAGE_WIDTH, SMALL_IMAGE_HEIGHT );
  end;

  if (ThreadSyncFlags and 4) = 4 then
  begin
    if ThreadSyncDump1 <> '' then
      N_Dump1Str( ThreadSyncDump1 );
    if ThreadSyncDump2 <> '' then
      N_Dump2Str( ThreadSyncDump2 );
  end;
end; // procedure TN_CMCDServObj14.ThreadSyncActions

//****************************************** TN_CMCDServObj14.ShowStatusAux ***
// Show device status on form
//
//    Parameters
// ACaptForm      - Capture form or nil
// ASetupForm     - Setup form or nil
// AColor         - indicators color
// AText          - indicators text
// ABold          - if True - indicator shows bold
// ADumpText      - Dump sting label
//
procedure TN_CMCDServObj14.ShowStatusAux( ACaptForm: TN_CMCaptDev14Form;
                                          ASetupForm:TN_CMCaptDev14aForm;
                                          AColor: TColor;
                                          AText: String;
                                          ABold: Boolean;
                                          ADumpText: String = '' );
begin

  if ( nil <> CaptForm ) then // Capture Form
  begin
    CaptForm.StatusShape.Brush.Color := AColor;
    CaptForm.StatusLabel.Font.Color  := AColor;
    CaptForm.StatusLabel.Caption     := AText;

    if ABold then
      CaptForm.StatusLabel.Font.Style  := CaptForm.StatusLabel.Font.Style + [fsBold]
    else
      CaptForm.StatusLabel.Font.Style  := CaptForm.StatusLabel.Font.Style - [fsBold];

    CaptForm.Repaint();
  end; // if ( nil <> CaptForm ) then // Capture Form

  if ( nil <> ASetupForm ) then // Capture Form
  begin
    ASetupForm.StatusShape.Brush.Color := AColor;
    ASetupForm.StatusLabel.Font.Color  := AColor;
    ASetupForm.StatusLabel.Caption     := AText;

    if ABold then
      ASetupForm.StatusLabel.Font.Style  := ASetupForm.StatusLabel.Font.Style + [fsBold]
    else
      ASetupForm.StatusLabel.Font.Style  := ASetupForm.StatusLabel.Font.Style - [fsBold];

    ASetupForm.Repaint();
  end; // if ( nil <> SetupForm ) then // Capture Form

  if ( '' = ADumpText ) then
    N_Dump1Str( 'Hamamatsu >> ' + AText )
  else
    N_Dump1Str( 'Hamamatsu >> ' + ADumpText );

//  Application.ProcessMessages;
end;// procedure TN_CMCDServObj14.ShowStatusAux

//********************************************* TN_CMCDServObj14.ShowStatus ***
// Show Device status
//
//    Parameters
// ACaptForm     - Hamamatsu Capture form pointer
// ASetupForm    - Hamamatsu Setup form pointer
//
procedure TN_CMCDServObj14.ShowStatus( ACaptForm: TN_CMCaptDev14Form; ASetupForm: TN_CMCaptDev14aForm );
begin

  if ( DevStatus = hsNotInit ) then
    ShowStatusAux( CaptForm, ASetupForm, $0090FF, 'Initializing', True )
  else if ( DevStatus = hsInitError ) then
    ShowStatusAux( CaptForm, ASetupForm, $000000, 'Initializing error', True )
  else if ( DevStatus = hsNotFound ) then
    ShowStatusAux( CaptForm, ASetupForm, $0000FF, 'Device disconnected', True )
  else if ( DevStatus = hsOpenError ) then
    ShowStatusAux( CaptForm, ASetupForm, $000000, 'Opening error', True )
  else if ( DevStatus = hsOpened ) then
    ShowStatusAux( CaptForm, ASetupForm, $009000, 'Device opened', True )
  else
  begin

    if ( nil = CaptForm ) then
      ShowStatusAux( CaptForm, ASetupForm, $000000, 'Error: unexpected status', True )
    else
    begin
      if ( DevStatus = hsArmed ) then
        ShowStatusAux( CaptForm, ASetupForm, $009000, 'Ready to take X-Ray', True )
      else if ( DevStatus = hsImageCapt ) then
        ShowStatusAux( CaptForm, ASetupForm, $009000, 'Capturing', True )
      else if ( DevStatus = hsImageReady ) then
        ShowStatusAux( CaptForm, ASetupForm, $900000, 'Processing', True );
    end;

  end;

//  Application.ProcessMessages;
end; // procedure TN_CMCDServObj14.ShowStatus

//********************************************* TN_CMCDServObj14.ProcessUSB ***
// Process USB event
//
//    Parameters
// AMsg       - Windows message
// ACaptForm  - Capture form
// ASetupForm - Setup form
//
procedure TN_CMCDServObj14.ProcessUSB( var AMsg: TMessage;
                                       ACaptForm: TN_CMCaptDev14Form;
                                       ASetupForm:TN_CMCaptDev14aForm );
var
  ev: TN_CMV_USBEvent;
  IsCapture, IsSetup: Boolean;
begin
  N_Dump2Str( 'TN_CMCDServObj14.ProcessUSB start' );
  IsCapture := ( nil <> ACaptForm  );
  IsSetup   := ( nil <> ASetupForm );

  if ( ( not IsCapture ) and ( not IsSetup ) ) then // both forms nil
  begin
    N_CMV_ShowCriticalError( 'Hamamatsu', 'wrong call of ProcessUSB( no forms )' );
    Exit;
  end; // if ( ( not IsCapture ) and ( not IsSetup ) ) then // both forms nil

  if ( IsCapture and IsSetup ) then // both forms not nil
  begin
    N_CMV_ShowCriticalError( 'Hamamatsu', 'wrong call of ProcessUSB( both forms )' );
    Exit;
  end; // if ( IsCapture and IsSetup ) then // both forms not nil

  ev := N_CMV_USBGetInfo( AMsg );

  if ( ( '0661' <> ev.DevVid ) and ( not DevSimulator ) ) then
    Exit;

  if ( ev.EventType = USBPlug ) then  // Plug
  begin

    if ( hsNotFound <> DevStatus ) then
      Exit;

    CDSFreeAll();
    DeviceOpen();

    if ( ( hsOpened = DevStatus ) and IsCapture ) then
      DeviceArm();

    ShowStatus( CaptForm, ASetupForm );
  end
  else if ( ev.EventType = USBUnplug ) then  // Unplug
  begin
    DevStatus := hsNotFound;

    if IsCapture then
    begin
      //Thread.Free();
      ThreadCtrl.N_CMV_Free();
      N_CMV_WaitThreadEnd( ThreadCtrl );
      {CDSFreeAll();
      DevStatus := tsNotFound;}

      CaptForm.Close;
      N_CMV_ShowCriticalError( '', UNPLUG_MESSAGE );
    end;

    ShowStatus( CaptForm, ASetupForm );
  end;

  N_Dump2Str( 'TN_CMCDServObj14.ProcessUSB fin' );
end; // procedure TN_CMCDServObj14.ProcessUSB

//********************************************* TN_CMCDServObj14.CDSFreeAll ***
// Free All device objects
//
procedure TN_CMCDServObj14.CDSFreeAll();
begin
  N_Dump2Str( 'TN_CMCDServObj14.CDSFreeAll start' );
  DeviceDisarm();
  DevStatus := hsNotInit;

  if ( 0 = CDSDllHandle ) then // If DLL already unloaded
  begin
    N_Dump1Str( 'Hamamatsu >> CDSFreeAll error: DLL handle = 0' );
    Exit;
  end;

  DeviceClose();

  if not FreeLibrary( CDSDllHandle ) then
    N_Dump1Str( 'Hamamatsu >> CDSFreeAll error: DLL not unloaded' );

  CDSDllHandle := 0;
  N_Dump2Str( 'TN_CMCDServObj14.CDSFreeAll fin' );
end; // procedure TN_CMCDServObj14.CDSFreeAll

//********************************************* TN_CMCDServObj14.DeviceOpen ***
// Open Device
//
procedure TN_CMCDServObj14.DeviceOpen();
var
  InfoCode: Integer;
  IsFunctionsLoaded: Boolean;
begin

  if ( ( hsNotInit = DevStatus ) or ( hsInitError = DevStatus ) ) then
  begin
    N_Dump1Str( 'Hamamatsu >> Initializing begin' );

    if ( 0 <> CDSDllHandle ) then // If DLL already loaded
    begin
      DevStatus := hsInitError;
      N_CMV_ShowCriticalError( 'Hamamatsu', 'DLL handle <> 0' );
      Exit;
    end; // if ( 0 <> CDSDllHandle ) then // If DLL already loaded

    // Load Hamamatsu DLL
    CDSDllHandle := LoadLibrary( 'CMOS_USB.dll' );

    if ( 0 = CDSDllHandle ) then // DLL not loaded
    begin
      DevStatus := hsInitError;
      N_CMV_ShowCriticalError( 'Hamamatsu', 'DLL not found' );
      Exit;
    end; // if ( 0 = CDSDllHandle ) then // DLL not loaded

    // Load all needed Hamamatsu functions from DLL
    IsFunctionsLoaded :=
    N_CMV_LoadFunc( CDSDllHandle, @USB_OpenDevice,             'USB_OpenDevice'             ) and
    N_CMV_LoadFunc( CDSDllHandle, @USB_OpenPipe,               'USB_OpenPipe'               ) and
    N_CMV_LoadFunc( CDSDllHandle, @USB_OpenTargetDevice,       'USB_OpenTargetDevice'       ) and
    N_CMV_LoadFunc( CDSDllHandle, @USB_CloseDevice,            'USB_CloseDevice'            ) and
    N_CMV_LoadFunc( CDSDllHandle, @HPK_GetXrayImage,           'HPK_GetXrayImage'           ) and
    N_CMV_LoadFunc( CDSDllHandle, @HPK_GetXrayCorrectionImage, 'HPK_GetXrayCorrectionImage' ) and
    N_CMV_LoadFunc( CDSDllHandle, @HPK_AbortBulkPipe,          'HPK_AbortBulkPipe'          ) and
    N_CMV_LoadFunc( CDSDllHandle, @HPK_ForceTrigAndGetDummy,   'HPK_ForceTrigAndGetDummy'   ) and
    N_CMV_LoadFunc( CDSDllHandle, @HPK_GetTrigPdData,          'HPK_GetTrigPdData'          ) and
    N_CMV_LoadFunc( CDSDllHandle, @HPK_StopTrigPdData,         'HPK_StopTrigPdData'         ) and
    N_CMV_LoadFunc( CDSDllHandle, @HPK_GetSensorInformation,   'HPK_GetSensorInformation'   );

    if not IsFunctionsLoaded then // some DLL functions not found
    begin
      DevStatus := hsInitError;

      if not FreeLibrary( CDSDllHandle ) then
        N_Dump1Str( 'Hamamatsu >> error: DLL not unloaded' );

      CDSDllHandle := 0;
      N_CMV_ShowCriticalError( 'Hamamatsu', 'Some functions not loaded from DLL' );
      Exit;
    end; // if not IsFunctionsLoaded then // some DLL functions not found

    DevStatus := hsNotFound;
    N_Dump1Str( 'Hamamatsu >> Initializing end' );
  end; // if ( ( tsNotInit = DevStatus ) or ( tsInitError = DevStatus ) ) then

  if ( hsNotFound <> DevStatus ) then
    Exit;

  ApplyProfile( nil );

  Correction        := N_MemIniToBool( 'CMS_UserDeb', 'HamamatsuCorrection',    True  );
  FullAutoMode      := N_MemIniToBool( 'CMS_UserDeb', 'HamamatsuFullAutoMode',  False );

  FilterE2V         := N_MemIniToBool( 'CMS_UserDeb', 'HamamatsuFilterE2V',     False );
  FilterTrident     := N_MemIniToBool( 'CMS_UserDeb', 'HamamatsuFilterTrident', True  );

  DevSimulator      := N_MemIniToBool( 'CMS_UserDeb', 'HamamatsuSimulator',          False );
  CountBeforeUnplug := N_MemIniToInt ( 'CMS_UserDeb', 'HamamatsuSimulatorAPIUnplug', 0     );
  SmallSize         := N_MemIniToBool( 'CMS_UserDeb', 'HamamatsuSimulatorSmallSize', False );
  Timeout           := N_MemIniToInt ( 'CMS_UserDeb', 'HamamatsuSimulatorTimeout',   500   );

  Image.Mode := 1;
  Image.IntegParam.Integration_Start_Threshold := DEFAULT_START_THRESHOLD;
  Image.IntegParam.Integration_Stop_Threshold  := DEFAULT_STOP_THRESHOLD;
  Image.IntegParam.Integration_Time            := IntTime;

  IntParam.Integration_Start_Threshold         := DEFAULT_START_THRESHOLD;
  IntParam.Integration_Stop_Threshold          := DEFAULT_STOP_THRESHOLD;
  IntParam.Integration_Time                    := IntTime;

  SensInfo.IntegParam.Integration_Start_Threshold := DEFAULT_START_THRESHOLD;
  SensInfo.IntegParam.Integration_Stop_Threshold  := DEFAULT_STOP_THRESHOLD;
  SensInfo.IntegParam.Integration_Time            := IntTime;
  SensInfo.XXXX := 0;
  SensInfo.YY   := 0;
  SensInfo.FW   := 0;

//  ThreadCtrl.Thread := nil;
//  ThreadCtrl.State  := tsIdle;

  ImageType     := tiWrong;

  N_Dump1Str( 'Hamamatsu >> IntTime = ' + IntToStr( IntTime ) );
  N_Dump1Str( 'Hamamatsu >> Timeout = ' + IntToStr( Timeout ) );

  if Correction then
    N_Dump1Str( 'Hamamatsu >> Correction ON' );

  if DevSimulator then // Simulator used
  begin
    N_Dump1Str( 'Hamamatsu >> DevSimulator ON' );

    if FullAutoMode then
      N_Dump1Str( 'Hamamatsu >> FullAutoMode ON' );

    if SmallSize then
      N_Dump1Str( 'Hamamatsu >> SmallSize ON' );

    SensInfo.XXXX := 80;
    SensInfo.YY   := 48;
    SensInfo.FW   := 0;

  end; // if DevSimulator then // Simulator used

  Device   := 0;
  Pipe     := 0;

  if not DevSimulator then // usual mode
  begin
    Device := USB_OpenDevice( $4400 ); // open device
    N_Dump1Str( 'Hamamatsu >> USB_OpenDevice = ' + IntToStr( Device ) );

    if ( 0 > Device ) then
      Exit;

    Pipe := USB_OpenPipe( Device ); // open pipe
    N_Dump1Str( 'Hamamatsu >> USB_OpenPipe = ' + IntToStr( Pipe ) );

    if ( 0 > Pipe ) then
    begin
      N_CMV_ShowCriticalError( 'Hamamatsu', 'Wrong pipe' );
      DevStatus := hsOpenError;
      Exit;
    end; // if ( 0 > Pipe ) then

    InfoCode := HPK_GetSensorInformation( Device, @IntParam, @SensInfo );

    if ( 0 <> InfoCode ) then
    begin
      N_CMV_ShowCriticalError( 'Hamamatsu', 'SensorInformation error' );
      DevStatus := hsOpenError;
      Exit;
    end; // if ( 0 <> InfoCode ) then

    N_Dump1Str( 'Hamamatsu >> HPK_GetSensorInformation = ' +
                IntToStr( InfoCode ) );

    N_Dump1Str( 'Hamamatsu >> IntParam.Integration_Start_Threshold = ' +
                IntToStr  ( IntParam.Integration_Start_Threshold ) );

    N_Dump1Str( 'Hamamatsu >> IntParam.Integration_Stop_Threshold = ' +
                IntToStr  ( IntParam.Integration_Stop_Threshold  ) );

    N_Dump1Str( 'Hamamatsu >> IntParam.Integration_Time = ' +
                FloatToStr( IntParam.Integration_Time            ) );

    N_Dump1Str( 'Hamamatsu >> SensInfo.IntegParam.Integration_Start_Threshold = ' +
                IntToStr  ( SensInfo.IntegParam.Integration_Start_Threshold ) );

    N_Dump1Str( 'Hamamatsu >> SensInfo.IntegParam.Integration_Stop_Threshold = ' +
                IntToStr  ( SensInfo.IntegParam.Integration_Stop_Threshold  ) );

    N_Dump1Str( 'Hamamatsu >> SensInfo.IntegParam.Integration_Time = ' +
                FloatToStr( SensInfo.IntegParam.Integration_Time            ) );

    N_Dump1Str( 'Hamamatsu >> SensInfo.XXXX = ' +
                IntToStr  ( SensInfo.XXXX ) + ' ( ' + IntToHex( SensInfo.XXXX, 16 ) );

    N_Dump1Str( 'Hamamatsu >> SensInfo.YY = ' +
                IntToStr  ( SensInfo.YY ) + ' ( ' + IntToHex( SensInfo.YY, 16 ) );

    N_Dump1Str( 'Hamamatsu >> SensInfo.FW = ' +
                IntToStr  ( SensInfo.FW ) + ' ( ' + IntToHex( SensInfo.FW, 16 ) );

  end; // if not DevSimulator then // usual mode

  DevStatus := hsOpened;
end; // procedure TN_CMCDServObj14.DeviceOpen
{
//********************************************************* SyncCaptureProc ***
// Capture Image in main thread from
//
procedure SyncCaptureProc();
begin

  if ( BIG_IMAGE_SIZE = N_CMCDServObj14.BufSize ) then
    N_CMCDServObj14.CaptForm.CMOFCaptureSlide( BIG_IMAGE_WIDTH, BIG_IMAGE_HEIGHT )
  else if ( SMALL_IMAGE_SIZE = N_CMCDServObj14.BufSize ) then
    N_CMCDServObj14.CaptForm.CMOFCaptureSlide( SMALL_IMAGE_WIDTH, SMALL_IMAGE_HEIGHT );

end; // procedure SyncCaptureProc

//************************************************************* SyncCapture ***
// Capture Image in main thread from
//
procedure SyncCapture();
begin
  N_CMCDServObj14.Thread.Thread.N_CMV_Sync( SyncCaptureProc );
end; // procedure SyncCapture
}

//********************************************************* DeviceArmThread ***
// Arm device in new thread
//
procedure DeviceArmThread();
var
  c, i, ResCode: Integer;
begin
  c := 0;

  with N_CMCDServObj14 do
  begin
    while ( hsArmed = DevStatus ) and
          not ThreadCtrl.Thread.N_CMV_IsTerminated() do
    begin
      //SyncTest();
      inc( c );
      ResCode := 0;

      if ( c = CountBeforeUnplug ) then
        ResCode := 5;

      SetLength( ImgBuf, 4450000 );
      BufSize := 0;

      for i := 0 to 4450000 - 1 do
        ImgBuf[i] := 0;

      if DevSimulator then // Simulator
      begin
        Sleep( Timeout );
        BufSize := BIG_IMAGE_SIZE;

        if SmallSize then
          BufSize := SMALL_IMAGE_SIZE;

      end
      else
      begin
        Image.Mode := AUTO_MODE;

        if AC then
          Image.Mode := MANUAL_MODE;

        if FullAutoMode then
          Image.Mode := FULL_AUTO_MODE;

        Image.IntegParam  := IntParam;
        Image.IntegParam.Integration_Time := IntTime;

        ThreadSyncFlags := 4; // SyncDump
        ThreadSyncDump2 := 'Hamamatsu >> HPK_GetXray start';
        ThreadCtrl.Thread.N_CMV_SyncProcObj( ThreadSyncActions );
        ThreadSyncDump2 := '';

        DevStatus := hsImageCapt;
        if Correction then
          ResCode := HPK_GetXrayCorrectionImage( Device, ImgBuf, @BufSize, @Image )
        else
          ResCode := HPK_GetXrayImage( Device, ImgBuf, @BufSize, @Image );
        DevStatus := hsArmed;
      end;

      if 0 = ResCode then // correct image captured
      begin
        DevStatus := hsImageReady;
        ThreadSyncFlags := 1 + 2 + 4; // ShowStatus + ProcImage + SyncDump
        ThreadSyncDump2 := 'Hamamatsu >> HPK_GetXray Fin';
        ThreadCtrl.Thread.N_CMV_SyncProcObj( ThreadSyncActions );
        ThreadSyncDump2 := '';
        DevStatus := hsArmed;
      end
      else
      begin
        DevStatus := hsNotFound;
        ThreadSyncFlags := 4; // SyncDump
        ThreadSyncDump1 := 'Hamamatsu >> HPK_GetXray Error Code=' + IntToStr( ResCode );
        ThreadCtrl.Thread.N_CMV_SyncProcObj( ThreadSyncActions );
        ThreadSyncDump1 := '';
      end;

      ThreadSyncFlags := 1; // ShowStatus
      ThreadCtrl.Thread.N_CMV_SyncProcObj( ThreadSyncActions );
    end; // while (hsArmed = DevStatus) and not Thread.Terminated
  end; // with N_CMCDServObj14 do

end; // procedure DeviceArmThread

//********************************************** TN_CMCDServObj14.DeviceArm ***
// Arm device
//
procedure TN_CMCDServObj14.DeviceArm();
begin

  N_Dump2Str( 'TN_CMCDServObj14.DeviceArm start' );
  if ( hsOpened <> DevStatus ) then
    Exit;

  DevStatus := hsArmed;
  ApplyProfile( nil );
  ShowStatus( CaptForm, nil );
  ThreadCtrl.N_CMV_Init( DeviceArmThread );
  ThreadCtrl.N_CMV_SetState( N_CMV_ThreadRun );
  N_Dump2Str( 'TN_CMCDServObj14.DeviceArm fin' );
end; // procedure TN_CMCDServObj14.DeviceArm

//******************************************* TN_CMCDServObj14.DeviceDisarm ***
// Disarm device
//
procedure TN_CMCDServObj14.DeviceDisarm();
var
  R : Integer;
begin
  N_Dump2Str( 'TN_CMCDServObj14.DeviceDisarm start' );
  if ThreadCtrl.State = tsIdle then Exit;

  if ThreadCtrl.State <> tsEnd then
  begin
    ThreadCtrl.N_CMV_SetState( N_CMV_ThreadStop ); // Stop Thread for correct check DevStatus = hsImageCapt

    if not DevSimulator and (DevStatus = hsImageCapt) then
    begin
      ThreadCtrl.N_CMV_SetState( N_CMV_ThreadRun ); // Run Thread for fast Termination after HPK_ForceTrigAndGetDummy

      R := HPK_AbortBulkPipe( Device );
      N_Dump2Str( format( 'Hamamatsu >> HPK_Abort... RCode=%d', [R] ) );

      R := HPK_ForceTrigAndGetDummy( Device, ImgBuf, @BufSize, @Image );
      N_Dump2Str( format( 'Hamamatsu >> HPK_...GetDummy RCode=%d', [R] ) );
    end;
  end;

  ThreadCtrl.N_CMV_Free;
  N_CMV_WaitThreadEnd( ThreadCtrl );
  DevStatus  := hsOpened;
  N_Dump2Str( 'TN_CMCDServObj14.DeviceDisarm fin' );
end; // procedure TN_CMCDServObj14.DeviceDisarm

//******************************************** TN_CMCDServObj14.DeviceClose ***
// Close device
//
procedure TN_CMCDServObj14.DeviceClose();
begin
  if ( not DevSimulator ) and ( hsOpened = DevStatus ) then
  begin
    N_Dump2Str( 'TN_CMCDServObj14.DeviceDisarm start' );
    USB_CloseDevice( Device );
    N_Dump2Str( 'TN_CMCDServObj14.DeviceDisarm fin' );
  end;
end; // procedure TN_CMCDServObj14.DeviceClose

//************************************* TN_CMCDServObj14.SetupFormToProfile ***
// Save setup dialog controls states to profile
//
//     Parameters
// ASetupForm - setup form
// Result     - profile string
//
function TN_CMCDServObj14.SetupFormToProfile( ASetupForm: TN_CMCaptDev14aForm ): String;
var
  n: Integer;
begin
  Result := '';

  if ASetupForm.cbAC.Checked then
    Result := '1'
  else
    Result := '0';

  if ASetupForm.cbFilter.Checked then
    Result := Result + '1'
  else
    Result := Result + '0';

  n := ASetupForm.cbIntTime.ItemIndex;

  if ( 0 <= n ) then
    Result := Result + ASetupForm.cbIntTime.Items[n];

  PProfile.CMDPStrPar1 := Result;
end; // function TN_CMCDServObj14.SetupFormToProfile

//******************************************* TN_CMCDServObj14.ApplyProfile ***
// Load setup dialog controls states from profile
//
//     Parameters
// ASetupForm - setup form
//
procedure TN_CMCDServObj14.ApplyProfile( ASetupForm: TN_CMCaptDev14aForm );
var
  s: String;
  i, len, cbCount: Integer;
begin
  AC      := False;
  Filter  := True;
  IntTime := N_MemIniToInt ( 'CMS_UserDeb', 'HamamatsuIntTime', 100 );
  s := PProfile.CMDPStrPar1;
  len := Length( s );

  if ( 1 < len ) then
  begin
    AC     := ( '1' = s[1] );
    Filter := ( '1' = s[2] );

    if AC then
      IntTime := StrToIntDef( Copy( s, 3, len - 2 ), 0 );

  end; // if ( 1 < len ) then

  if ( nil = ASetupForm ) then
    Exit;

  ASetupForm.lbSNValue.Caption := IntToHex( SensInfo.XXXX, 4 ) + '; YY = ' +
                                 IntToHex( SensInfo.YY, 2 ) + '; FW = ' +
                                 IntToHex( SensInfo.FW, 2 );

  ASetupForm.cbAC.Checked        := AC;
  ASetupForm.cbFilter.Checked    := Filter;
  ASetupForm.cbIntTime.Enabled   := AC;
  ASetupForm.cbIntTime.ItemIndex := 0;

  if ( 0 >= IntTime ) then
    Exit;

  cbCount := ASetupForm.cbIntTime.Items.Count;

  for i := 0 to cbCount do
  begin

    if ( IntTime = StrToIntDef( ASetupForm.cbIntTime.Items[i], 0 ) ) then
    begin
      ASetupForm.cbIntTime.ItemIndex := i;
      Exit;
    end; // if ( IntTime = StrToIntDef( SetupForm.cbIntTime.Items[i], 0 ) ) then

  end; // for i := 0 to cbCount do

end; // procedure TN_CMCDServObj14.ApplyProfile

//************************************ TN_CMCDServObj14.CDSGetGroupDevNames ***
// Get Trident Device Name
//
//    Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj14.CDSGetGroupDevNames(AGroupDevNames: TStrings): Integer;
begin
  AGroupDevNames.Add( 'HamamatsuDummy' ); // Dummy Name, because group has only one device
  Result := AGroupDevNames.Count;
end; // procedure TN_CMCDServObj14.CDSGetGroupDevNames

//*************************************** TN_CMCDServObj14.CDSGetDevCaption ***
// Get Capture Device Caption by Name
//
//    Parameters
// ADevName - given Device Name
//
// Result   - Returns Device Caption
//
function TN_CMCDServObj14.CDSGetDevCaption( ADevName: String ): String;
begin
  Result := 'Hamamatsu CMOS';
end; // procedure TN_CMCDServObj14.CDSGetDevCaption

//******************************** TN_CMCDServObj14.CDSGetDevProfileCaption ***
// Get Capture Device Profile Caption by Name
//
//    Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function TN_CMCDServObj14.CDSGetDevProfileCaption( ADevName: String ): String;
begin
  Result := 'Hamamatsu CMOS'; // ADevName is not used because group has only one device
end; // procedure TN_CMCDServObj14.CDSGetDevProfileCaption

//*************************************** TN_CMCDServObj14.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj14.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
var
  CMCaptDev14Form: TN_CMCaptDev14Form;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Hamamatsu >> CDSCaptureImages begin' );
  DevStatus := hsNotInit;
  DeviceOpen();

  if ( DevStatus = hsNotFound ) then // Device not found
  begin
    N_CMV_ShowCriticalError( '', DISCONNECTED_MESSAGE );
    CDSFreeAll();
    Exit;
  end; // if ( DevStatus = tsNotFound ) then // Device not found

  SetLength( ASlidesArray, 0 );
  CMCaptDev14Form          := TN_CMCaptDev14Form.Create(application);
  CaptForm                 := CMCaptDev14Form;

  with CMCaptDev14Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev14Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev14Form methods
    N_Dump1Str( 'Hamamatsu >> CDSCaptureImages before ShowModal' );
    CaptDlgActive := True;
    ShowModal();
    CaptDlgActive := False;

    N_Dump1Str( 'Hamamatsu >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev14Form, APDevProfile^ do

  //CDSFreeAll();
  N_Dump1Str( 'Hamamatsu >> CDSCaptureImages end' );
end; // procedure TN_CMCDServObj14.CDSCaptureImages

//***************************************** TN_CMCDServObj14.CDSSettingsDlg ***
// call settings dialog
//
//    Parameters
// APDevProfile - pointer to profile
//
procedure TN_CMCDServObj14.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  frm: TN_CMCaptDev14aForm; // Trident Settings form
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Hamamatsu >> CDSSettingsDlg begin' );

  if not CaptDlgActive then
    DeviceOpen();

  frm := TN_CMCaptDev14aForm.Create( application );
  // create Hamamatsu setup form
  frm.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
  frm.CMOFPDevProfile := APDevProfile; // link form variable to profile
  frm.Caption := APDevProfile.CMDPCaption; // set form caption

  frm.CMOFPDevProfile := PProfile;
  ApplyProfile( frm );
  ShowStatus( nil, frm );
  frm.ShowModal(); // Show Hamamatsu setup form

  if not CaptDlgActive then
    CDSFreeAll();

  N_Dump1Str( 'Hamamatsu >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj14.CDSSettingsDlg

//******************************** TN_CMCDServObj14.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj14.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 37;
end; // function TN_CMCDServObj14.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj14.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj14.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'IO';
end; // function TN_CMCDServObj14.CDSGetDefaultDevDCMMod

Initialization

// Create and Register Hamamatsu Service Object
N_CMCDServObj14 := TN_CMCDServObj14.Create( N_CMECD_Hamamatsu_Name );

// Ininialize Hamamatsu variables
with N_CMCDServObj14 do
begin
  CDSDllHandle  := 0;
  PProfile      := nil;
  DevStatus     := hsNotInit;

  SetLength( N_CMCDServObj14.ImgBuf, 0 );

  CaptForm := nil;
  BufSize  := 0;
  Device   := 0;
  Pipe     := 0;

  Correction        := True;
  IntTime           := 100;
  FullAutoMode      := False;
  DevSimulator      := False;
  CountBeforeUnplug := 0;
  SmallSize         := False;
  Timeout           := 500;
  AC                := False;
  Filter            := True;
  FilterE2V         := False;
  FilterTrident     := True;
  USBHandle         := nil;

  Image.Mode := 1;
  Image.IntegParam.Integration_Start_Threshold := DEFAULT_START_THRESHOLD;
  Image.IntegParam.Integration_Stop_Threshold  := DEFAULT_STOP_THRESHOLD;
  Image.IntegParam.Integration_Time            := IntTime;

  IntParam.Integration_Start_Threshold         := DEFAULT_START_THRESHOLD;
  IntParam.Integration_Stop_Threshold          := DEFAULT_STOP_THRESHOLD;
  IntParam.Integration_Time                    := IntTime;

  SensInfo.IntegParam.Integration_Start_Threshold := DEFAULT_START_THRESHOLD;
  SensInfo.IntegParam.Integration_Stop_Threshold  := DEFAULT_STOP_THRESHOLD;
  SensInfo.IntegParam.Integration_Time            := IntTime;
  SensInfo.XXXX := 0;
  SensInfo.YY   := 0;
  SensInfo.FW   := 0;
  
  ThreadCtrl := TN_CMV_UniThread.Create();

  ImageType     := tiWrong;
  CaptDlgActive := False;
end; // with N_CMCDServObj14 do

with K_CMCDRegisterDeviceObj( N_CMCDServObj14 ) do
begin
  CDSCaption := 'Hamamatsu';
  IsGroup := True;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj14 ) do

end.
