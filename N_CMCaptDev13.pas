unit N_CMCaptDev13;
// Apixia device interface

// 2014.02.21 created by Valery Ovechkin
// 2014.03.05 Fixed log strings from 'Trident' to 'Apixia' by Valery Ovechkin
// 2014.03.05 Fixed 'Apixia.exe' location definition by Valery Ovechkin
// 2014.03.20 Changed indicator for Processing by Valery Ovechkin
// 2014.03.20 Fixed USB events listener by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.09.15 Fixed File exceptions processing ( like i/o 32, etc. ) by Valery Ovechkin
// 2014.09.15 Standartizing ( All functions parameters name starts from 'A' ) by Valery Ovechkin
// 2018.11.07 CDSGetDefaultDevIconInd function added
// 2020.07.17 updated for CMScan, driver opening, FormShow modified

interface

uses
  Windows, Classes, Messages, Forms, Graphics, StdCtrls, ExtCtrls, WinSock, Types,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND}
  K_CM0, K_CMCaptDevReg,
  N_Types, N_CMCaptDev0, N_CMCaptDev13F, N_CMCaptDev13aF;

type TApixiaState = ( // device states enum
  tsDriverNotInit,   // Initial state
  tsDriverNotClosed, // C++ driver not closed yet from last session
  tsDriverNotFound,  // C++ driver not found
  tsDriverNotExec,   // C++ driver found, but can not start due to some error
  tsWaitHandle,      // C++ driver started, wait while it send it's handle

  tsGoodHandle,      // Right Handle received from C++ driver
  tsBadHandle,       // Wrong Handle received from C++ driver

  tsOpened,          // Device found and opened successfully
  tsDeviceNotFound,  // There are no devices presented
  tsOpeningError,    // Opening device error

  tsGoodStartScan,   // Scan started successfully, wait for image
  tsBadStartScan,    // Scan not started due to some error

  tsImageReady       // Image received
);

type TN_CMCDServObj13 = class(TK_CMCDServObj)
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer
  DevStatus:     TApixiaState;

  ApixiaHandle: Integer;
  USBHandle:    Pointer;
  CaptForm:     TN_CMCaptDev13Form;

  InfoSize:     Integer;
	InfoWidth:    Integer;
	InfoHeight:   Integer;

  LinesCount:   Integer;
  LinesTotal:   Integer;

  TestMode:     Integer;

  destructor  Destroy; override;

  procedure SetStatus            ( AWP: Integer; ALP: Integer );
  procedure ShowStatusAux        ( ACaptForm: TN_CMCaptDev13Form; ASetupForm:TN_CMCaptDev13aForm; AColor: TColor; AText: String; ABold: Boolean; AShowProgress: Boolean = False; AProgressValue: Integer = 0; ADumpText: String = '' );
  procedure ShowStatus           ( ACaptForm: TN_CMCaptDev13Form; ASetupForm:TN_CMCaptDev13aForm );

  procedure SendExtMsg           ( ACmd, AParam1, AParam2, AParam3: Integer );
  function  StartDriver          ( AFormHandle: Integer ): Boolean;
  function  GetImgName           ( ANumber: Integer ): String;
  function  GetRawName           ( ANumber: Integer ): String;
  function  GetParamName         ( ANumber: Integer ): String;
  function  DeleteImages         (): Boolean;
  procedure ArmDevice            ( ACapture: Boolean; AImageNum: Integer );
  procedure ProcessUSB           ( var AMsg: TMessage; ACaptForm: TN_CMCaptDev13Form; ASetupForm:TN_CMCaptDev13aForm );
  procedure CloseDriver          ();
  function  IsApixiaUSBEvent     ( AEvent: TN_CMV_USBEvent ): Boolean;

  function  CDSGetGroupDevNames    ( AGroupDevNames: TStrings): Integer; override;
  function  CDSGetDevCaption       ( ADevName: String ): String; override;
  function  CDSGetDevProfileCaption( ADevName: String ): String; override;
  procedure CDSCaptureImages       ( APDevProfile: TK_PCMDeviceProfile; var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg         ( APDevProfile: TK_PCMDeviceProfile ); override;
  function  CDSGetDefaultDevIconInd( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCDServObj13 = class( TK_CMCDServObj )

const
  // message types
  PSP_MSG_COMMAND  = WM_USER + 89;
  PSP_MSG_PROGRESS = WM_USER + 90;

  // Apixia DLL error codes
  PSP_ERROR_NO_ERROR			  =  1;
  PSP_ERROR_NO_DEVICE_FOUND	= -1;
  PSP_ERROR_DEVICE_NOT_OPEN	= -2;
  PSP_ERROR_INVALID_PARAM		= -3;
  PSP_ERROR_READING_DATA		= -4;
  PSP_ERROR_WRITING_DATA		= -5;
  PSP_ERROR_NOT_START_SCAN	= -6;
  PSP_ERROR_TIMEOUT			    = -7;
  PSP_ERROR_CAPTURE_RUNNING	= -8;

  // incoming commands - successfull
  DRIVER_HANDLE      = 1;
  DRIVER_ARM         = 2;
  DRIVER_IMAGE       = 3;
  DRIVER_ARM_CONFIRM = -1;

  // incoming commands - fail
  DRIVER_OPEN_ERROR      = -1;
  DRIVER_GET_PARAM_ERROR = -2;
  DRIVER_SET_PARAM_ERROR = -3;
  DRIVER_ARM_ERROR       = -4;

  // outcoming commands
  PSP_OPEN         = 3;
  PSP_OPEN_AND_ARM = 4;
  PSP_REARM        = 5;
  PSP_REARM_WAIT   = 6;
  PSP_REARM_STOP   = 7;
  PSP_CLOSE        = 8;

var
  N_CMCDServObj13: TN_CMCDServObj13;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, ShellAPI, TlHelp32;

destructor TN_CMCDServObj13.Destroy();
begin
  CloseDriver();
  inherited Destroy();
end; // destructor TN_CMCDServObj13.Destroy

//********************************************** TN_CMCDServObj13.SetStatus ***
// Set device status by incoming Windows message
//
//    Parameters
// AWP - WPARAM from message
// ALP - LPARAM from message
//
procedure TN_CMCDServObj13.SetStatus( AWP: Integer; ALP: Integer );
begin

  if ( ( AWP > 3) and ( ALP > 3 ) ) then // WP = width, LP = height
    DevStatus := tsOpened
  else if ( AWP = DRIVER_HANDLE ) then // handle from c++ driver
  begin

    if ( ALP > 0 ) then // check dirver handle
    begin
      ApixiaHandle := ALP;
      DevStatus := tsGoodHandle; // right handle
    end
    else
      DevStatus := tsBadHandle; // wrong handle

  end
  else if ( ( AWP = DRIVER_ARM ) and ( ALP = DRIVER_ARM_CONFIRM ) ) then
    DevStatus := tsGoodStartScan // Scan started successfully
  else if ( AWP = DRIVER_IMAGE ) then
    DevStatus := tsImageReady // image ready
  else if ( AWP = DRIVER_OPEN_ERROR ) then
  begin

    if ( ALP = PSP_ERROR_NO_DEVICE_FOUND ) then
      DevStatus := tsDeviceNotFound // device disconnected
    else
      DevStatus := tsOpeningError;  // drivers error when open

  end
  else if ( AWP = DRIVER_GET_PARAM_ERROR ) then
    DevStatus := tsOpeningError  // drivers error when open
  else if ( ( AWP = DRIVER_SET_PARAM_ERROR ) or ( AWP = DRIVER_ARM_ERROR ) )then
    DevStatus := tsBadStartScan; // Scan not started due to some error

end; // procedure TN_CMCDServObj13.SetStatus

//****************************************** TN_CMCDServObj13.ShowStatusAux ***
// Show device status on form
//
//    Parameters
// ACaptForm      - Capture form or nil
// ASetupForm     - Setup form or nil
// AColor         - indicators color
// AText          - indicators text
// ABold          - if True - indicator shows bold
// AShowProgress  - if True - ProgressBar shows
// AProgressValue - ProgressBar value
// ADumpText      - Dump sting label
//
procedure TN_CMCDServObj13.ShowStatusAux( ACaptForm: TN_CMCaptDev13Form;
                                          ASetupForm:TN_CMCaptDev13aForm;
                                          AColor: TColor; AText: String;
                                          ABold: Boolean;
                                          AShowProgress: Boolean = False;
                                          AProgressValue: Integer = 0;
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

    CaptForm.ProgressBar.Visible := AShowProgress;

    if AShowProgress then
    begin
      CaptForm.ProgressBar.Position := AProgressValue;
    end;

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

  end; // if ( nil <> SetupForm ) then // Capture Form

  if ( '' = ADumpText ) then
    N_Dump1Str( 'Apixia >> ' + AText )
  else
    N_Dump1Str( 'Apixia >> ' + ADumpText );

  Application.ProcessMessages;
end; // procedure TN_CMCDServObj13.ShowStatusAux

//********************************************* TN_CMCDServObj13.ShowStatus ***
// Show Device status
//
//    Parameters
// ACaptForm     - Apixia Capture form pointer
// ASetupForm    - Apixia Setup form pointer
//
procedure TN_CMCDServObj13.ShowStatus( ACaptForm: TN_CMCaptDev13Form; ASetupForm: TN_CMCaptDev13aForm );
begin

  if ( DevStatus = tsDriverNotInit ) then
    ShowStatusAux( CaptForm, ASetupForm, $0000FF, 'Not Initialized', True )
  else if ( DevStatus = tsDriverNotClosed ) then
    ShowStatusAux( CaptForm, ASetupForm, $0090FF, 'Initializing scanner', True )
  else if ( DevStatus = tsDriverNotFound ) then
    ShowStatusAux( CaptForm, ASetupForm, $000000, 'Error: driver not found', True )
  else if ( DevStatus = tsDriverNotExec ) then
    ShowStatusAux( CaptForm, ASetupForm, $000000, 'Error: driver can not start', True )
  else if ( DevStatus = tsWaitHandle ) then
    ShowStatusAux( CaptForm, ASetupForm, $0090FF, 'Wait for driver response', True )
  else if ( DevStatus = tsGoodHandle ) then
    ShowStatusAux( CaptForm, ASetupForm, $0090FF, 'Search device', True )
  else if ( DevStatus = tsBadHandle ) then
    ShowStatusAux( CaptForm, ASetupForm, $000000, 'Error: bad driver handle', True )
  else if ( DevStatus = tsOpened ) then
    ShowStatusAux( CaptForm, ASetupForm, $009000, 'Device opened', True )
  else if ( DevStatus = tsDeviceNotFound ) then
    ShowStatusAux( CaptForm, ASetupForm, $0000FF, 'Device disconnected', True )
  else if ( DevStatus = tsOpeningError ) then
    ShowStatusAux( CaptForm, ASetupForm, $000000, 'Error: device can not open', True )
  else
  begin

    if ( nil = CaptForm ) then
      ShowStatusAux( CaptForm, ASetupForm, $000000, 'Error: unexpected status', True )
    else
    begin

      if ( DevStatus = tsGoodStartScan ) then
        ShowStatusAux( CaptForm, ASetupForm, $009000, 'Ready to take X-Ray', True )
      else if ( DevStatus = tsBadStartScan ) then
        ShowStatusAux( CaptForm, ASetupForm, $000000, 'Error: scan not started', True )
      else if ( DevStatus = tsImageReady ) then
        ShowStatusAux( CaptForm, ASetupForm, $900000, 'Processing', True );

    end;

  end;

  Application.ProcessMessages;
end; // procedure TN_CMCDServObj13.ShowStatus

//********************************************* TN_CMCDServObj13.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// ACmd    - command for driver
// AParam1 - 1st parameter
// AParam2 - 2nd parameter
// AParam3 - 3rd parameter
//
procedure TN_CMCDServObj13.SendExtMsg( ACmd, AParam1, AParam2, AParam3: Integer );
var
  WP, LP: Integer;
  res: Boolean;
  value: String;
begin

  if ( 0 < ApixiaHandle ) then // if right driver handle
  begin
    WP    := ACmd    + ( 256 * AParam1 );
    LP    := AParam2 + ( 256 * AParam3 );
    res   := PostMessage( ApixiaHandle, PSP_MSG_COMMAND, WP, LP );
    value := 'FALSE';

    if res then
      value := 'TRUE';

    N_Dump1Str( 'Apixia >> PostMessage = ' + value +
                '; WP = ' + IntToStr( WP ) + '; LP = ' + IntToStr( LP ) );
  end; // if ( 0 < ApixiaHandle ) then // if right driver handle

end; // procedure SendExtMsg

//******************************************** TN_CMCDServObj13.StartDriver ***
// Start C++ driver
//
//    Parameters
// AFormHandle - CMS Capture or Setup Form's handle
// Result      - True if driver started successfully, else False
//
function TN_CMCDServObj13.StartDriver( AFormHandle: Integer ): Boolean;
var
  WrkDir, LogDir, CurDir, FileName, cmd: String;
  Res: HINST;
begin
  Result       := False;
  ApixiaHandle := 0;
  WrkDir       := N_CMV_GetWrkDir();
  LogDir       := N_CMV_GetLogDir();
  CurDir       := ExtractFilePath( ParamStr( 0 ) );
  N_Dump1Str( 'Apixia >> Exe directory = "' + CurDir + '"' );

  FileName  := CurDir + 'Apixia.exe';

  // wait old driver session closing
  N_CMV_WaitProcess( False, FileName, -1 );

  if not FileExists( FileName ) then // find driver
  begin
    DevStatus := tsDriverNotFound;
    Exit;
  end; // if not FileExists( FileName ) then // find driver

  DevStatus := tsDriverNotInit;
  TestMode  := 0;

  if N_MemIniToBool( 'CMS_UserDeb', 'ApixiaTestMode', False ) then
    TestMode := 1;

  cmd := '"' + WrkDir + '" "' + LogDir + '" "' + IntToStr( AFormHandle ) +
                        '" "' + IntToStr( N_MemIniToInt( 'CMS_UserDeb', 'ApixiaExtMsgMode', 0 ) ) +
                        '" "' + IntToStr( N_MemIniToInt( 'CMS_UserDeb', 'ApixiaIntMsgMode', 1 ) ) +
                        '" "' + IntToStr( TestMode ) + '"';

  // start driver executable file with command line parameters
  //Result := N_CMV_CreateProcess( '"' + FileName + '" ' + cmd ); // failed for CMScan (WinExec also)
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  Res := ShellExecute( 0, 'open', @N_StringToWide( CurDir + 'Apixia.exe' )[1],
                                  @N_StringToWide(cmd)[1], nil, SW_SHOWNORMAL );
{$ELSE}         // Delphi 7 or Delphi 2010
  Res := ShellExecute( 0, 'open', @(CurDir + 'Apixia.exe')[1],
                                  @(cmd)[1], nil, SW_SHOWNORMAL );
{$IFEND CompilerVersion >= 26.0}

  if Res <= 32 then // if driver start fail
  begin
    DevStatus := tsDriverNotExec;
    Exit;
  end; // if not Result then // if driver start fail

  Result    := True;
  DevStatus := tsWaitHandle; // now wait for driver's handle in message
end; // function TN_CMCDServObj13.StartDriver

//********************************************* TN_CMCDServObj13.GetImgName ***
// make cropped image path by number
//
//    Parameters
// ANumber - image number
// Result  - cropped image path
//
function TN_CMCDServObj13.GetImgName( ANumber: Integer ): String;
begin
  Result := N_CMV_GetWrkDir() + 'Image_'    + IntToStr( ANumber ) + '.img';
end; // function TN_CMCDServObj13.GetImgName

//********************************************* TN_CMCDServObj13.GetRawName ***
// make raw image path by number
//
//    Parameters
// ANumber - image number
// Result  - raw image path
//
function TN_CMCDServObj13.GetRawName( ANumber: Integer ): String;
begin
  Result := N_CMV_GetWrkDir() + 'ImageRaw_' + IntToStr( ANumber ) + '.img';
end; // function TN_CMCDServObj13.GetRawName

//******************************************* TN_CMCDServObj13.GetParamName ***
// make image parameters path by number
//
//    Parameters
// ANumber - image number
// Result  - image parameters path
//
function TN_CMCDServObj13.GetParamName( ANumber: Integer ): String;
begin
  Result := N_CMV_GetWrkDir() + 'Param_'    + IntToStr( ANumber ) + '.par';
end; // TN_CMCDServObj13.GetParamName

//******************************************* TN_CMCDServObj13.DeleteImages ***
// Delete temporary image files
//
//    Parameters
// Result - True if images deleted successfully or there are no images
//
function TN_CMCDServObj13.DeleteImages(): Boolean;
var
  n: Integer;
  ImageFile, RawFile, ParamFile: String;
begin
  Result := True;

  if N_MemIniToBool( 'CMS_UserDeb', 'SaveImage', False ) then // save images
    Exit;

  n := 1; // initial image number
  ImageFile := GetImgName  ( n ); // get cropped image path
  RawFile   := GetRawName  ( n ); // get raw image path
  ParamFile := GetParamName( n ); // get image parameters path

  while ( FileExists( ImageFile ) or FileExists( RawFile ) or
          FileExists( ParamFile ) ) do
  begin
    Result := Result and K_DeleteFile( ImageFile ) and
                         K_DeleteFile( RawFile   ) and
                         K_DeleteFile( ParamFile );
    Inc( n ); // get next image number
    ImageFile := GetImgName  ( n ); // get cropped image path
    RawFile   := GetRawName  ( n ); // get raw image path
    ParamFile := GetParamName( n ); // get image parameters path
  end;

end; // function TN_CMCDServObj13.DeleteImages

//********************************************** TN_CMCDServObj13.ArmDevice ***
// Arm device
//
//    Parameters
// ACapture  - if True - process slide
// AImageNum - image number ( for reading image from file )
//
procedure TN_CMCDServObj13.ArmDevice( ACapture: Boolean; AImageNum: Integer );
var
  w, h, offset, ScanMode: Integer;
  s: String;
  ManualRearm: Boolean;
begin
  s      := PProfile.CMDPStrPar1;
  w      := 0;
  h      := 0;
  offset := 0;

  if ( 5 < Length( s ) ) then // correct profile
  begin
    offset := StrToIntDef( Copy( s, 1, 2 ), 0 );
    w      := StrToIntDef( Copy( s, 3, 2 ), 0 );
    h      := StrToIntDef( Copy( s, 5, 2 ), 0 );
  end; // if ( 5 < Length( s ) ) then // correct profile

  if ( 0 > w ) then
    w := 0;

  if ( 0 > h ) then
    h := 0;

  if ( 0 > offset ) then
    offset := 0;

  ScanMode    := PSP_REARM + N_MemIniToInt( 'CMS_UserDeb', 'ApixiaScanMode', 1 );
  ManualRearm := N_MemIniToBool( 'CMS_UserDeb', 'ApixiaManualRearm', False );

  if ( N_CMCDServObj13.DevStatus = tsGoodHandle) then // Arm device
  begin
    N_CMCDServObj13.SendExtMsg( PSP_OPEN_AND_ARM, w, h, offset );
  end
  else if ( N_CMCDServObj13.DevStatus = tsImageReady ) then // Rearm device
  begin

    if ACapture then // need capture processing from message
    begin

      if ( 1 = N_CMCDServObj13.TestMode ) then // test mode
        CaptForm.CMOFCaptureSlide( AImageNum, True ); // raw image

      CaptForm.CMOFCaptureSlide( AImageNum, False ); // cropped image
    end; // if ACapture then // need capture processing from message

    if not ManualRearm then
      N_CMCDServObj13.SendExtMsg( ScanMode, w, h, offset ); // Rearm device

  end;

end; // procedure TN_CMCDServObj13.ArmDevice

//********************************************* TN_CMCDServObj13.ProcessUSB ***
// Process USB event
//
//    Parameters
// AMsg       - Windows message
// ACaptForm  - Capture form
// ASetupForm - Setup form
//
procedure TN_CMCDServObj13.ProcessUSB( var AMsg: TMessage;
                                       ACaptForm: TN_CMCaptDev13Form;
                                       ASetupForm:TN_CMCaptDev13aForm );
var
  ev: TN_CMV_USBEvent;
  IsCapture, IsSetup: Boolean;
  FormHandle: Integer;
begin
  IsCapture := ( nil <> CaptForm  );
  IsSetup   := ( nil <> ASetupForm );

  if ( ( not IsCapture ) and ( not IsSetup ) ) then // both forms nil
  begin
    N_CMV_ShowCriticalError( 'Apixia', 'wrong call of ProcessUSB( no forms )' );
    Exit;
  end; // if ( ( not IsCapture ) and ( not IsSetup ) ) then // both forms nil

  if ( IsCapture and IsSetup ) then // both forms not nil
  begin
    N_CMV_ShowCriticalError( 'Apixia', 'wrong call of ProcessUSB( both forms )' );
    Exit;
  end; // if ( IsCapture and IsSetup ) then // both forms not nil

  if IsCapture then
    FormHandle := CaptForm.Handle
  else
    FormHandle := ASetupForm.Handle;

  ev := N_CMV_USBGetInfo( AMsg );

  if not N_CMCDServObj13.IsApixiaUSBEvent( ev ) then // is it Apixia event
    Exit;

  if ( ev.EventType = USBPlug ) then  // Plug
  begin
    N_CMCDServObj13.CloseDriver();
    N_CMCDServObj13.StartDriver( FormHandle );
    N_CMCDServObj13.ShowStatus( CaptForm, ASetupForm );
  end
  else if ( ev.EventType = USBUnplug ) then  // Unplug
  begin
    N_CMCDServObj13.CloseDriver();
    N_CMCDServObj13.DevStatus := tsDeviceNotFound;
    N_CMCDServObj13.ShowStatus( CaptForm, ASetupForm );
  end;

end; // procedure TN_CMCDServObj13.ProcessUSB

//******************************************** TN_CMCDServObj13.CloseDriver ***
// Close C++ driver
//
procedure TN_CMCDServObj13.CloseDriver();
begin
  SendExtMsg( PSP_CLOSE, 0, 0, 0 );
  ApixiaHandle := 0;
  DevStatus    := tsDriverNotClosed;

  if not DeleteImages() then
  begin
    N_CMV_ShowCriticalError( 'Apixia', 'Some temporary files not deleted' );
  end; // if not DeleteImages() then

end; // procedure TN_CMCDServObj13.CloseDriver

//*************************************** TN_CMCDServObj13.IsApixiaUSBEvent ***
// check is USB event is from Apixia device
//
//    Parameters
// AEventev - USB event
// Result   - True if USB event is from Apixia device
//
function TN_CMCDServObj13.IsApixiaUSBEvent( AEvent: TN_CMV_USBEvent ): Boolean;
begin
  Result := ( '218F' = UpperCase( AEvent.DevVid ) );
end; // TN_CMCDServObj13.IsApixiaUSBEvent

//************************************ TN_CMCDServObj13.CDSGetGroupDevNames ***
// Get Apixia Device Name
//
//    Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj13.CDSGetGroupDevNames(AGroupDevNames: TStrings): Integer;
begin
  AGroupDevNames.Add( 'ApixiaDummy' ); // Dummy Name, because group has only one device
  Result := AGroupDevNames.Count;
end; // procedure TN_CMCDServObj13.CDSGetGroupDevNames

//*************************************** TN_CMCDServObj13.CDSGetDevCaption ***
// Get Capture Device Caption by Name
//
//    Parameters
// ADevName - given Device Name
//
// Result   - Returns Device Caption
//
function TN_CMCDServObj13.CDSGetDevCaption( ADevName: String ): String;
begin
  Result := 'Apixia';
end; // procedure TN_CMCDServObj13.CDSGetDevCaption

//******************************** TN_CMCDServObj13.CDSGetDevProfileCaption ***
// Get Capture Device Profile Caption by Name
//
//    Parameters
// ADevName - given Device Name
// Result   - Returns Device Caption
//
function TN_CMCDServObj13.CDSGetDevProfileCaption( ADevName: String ): String;
begin
  Result := 'Apixia'; // ADevName is not used because group has only one device
end; // procedure TN_CMCDServObj13.CDSGetDevProfileCaption

//*************************************** TN_CMCDServObj13.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj13.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
var
  CMCaptDev13Form: TN_CMCaptDev13Form;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Apixia >> CDSCaptureImages begin' );

  SetLength( ASlidesArray, 0 );
  CloseDriver(); // Close old driver session if it is still alive

  CMCaptDev13Form          := TN_CMCaptDev13Form.Create(application);
  CMCaptDev13Form.ThisForm := CMCaptDev13Form;
  CaptForm                 := CMCaptDev13Form;

  with CMCaptDev13Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev13Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev13Form methods
    N_Dump1Str( 'Apixia >> CDSCaptureImages before ShowModal' );

    ThisForm.brearm.Visible := N_MemIniToBool( 'CMS_UserDeb', 'ApixiaManualRearm', False );
    ShowModal();   // show capture form
    CloseDriver(); // close driver after exit from capture form

    N_Dump1Str( 'Apixia >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev13Form, APDevProfile^ do

  CaptForm := nil;
  N_Dump1Str( 'Apixia >> CDSCaptureImages end' );
end; // procedure TN_CMCDServObj13.CDSCaptureImages

//***************************************** TN_CMCDServObj13.CDSSettingsDlg ***
// call settings dialog
//
//    Parameters
// APDevProfile - pointer to profile
//
procedure TN_CMCDServObj13.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  frm: TN_CMCaptDev13aForm; // Apixia Settings form
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Apixia >> CDSSettingsDlg begin' );
  CloseDriver();

  if ( 6 > Length( PProfile.CMDPStrPar1 ) ) then
  begin
    PProfile.CMDPStrPar1 := '000000'; // default value
  end;

  frm := TN_CMCaptDev13aForm.Create( application );
  // create Apixia setup form
  frm.ThisForm := frm;
  frm.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
  frm.CMOFPDevProfile := APDevProfile; // link form variable to profile
  frm.Caption := APDevProfile.CMDPCaption; // set form caption

  frm.CMOFPDevProfile := PProfile;

  frm.lbWidthValue.Caption  := 'Not defined';
  frm.lbHeightValue.Caption := 'Not defined';

  // set setup controls from the device profile
  frm.cbHorOffset.ItemIndex := StrToIntDef( Copy( PProfile.CMDPStrPar1, 1, 2 ), 0 );
  frm.cbWidth.ItemIndex     := StrToIntDef( Copy( PProfile.CMDPStrPar1, 3, 2 ), 0 );
  frm.cbHeight.ItemIndex    := StrToIntDef( Copy( PProfile.CMDPStrPar1, 5, 2 ), 0 );

  frm.ShowModal(); // Show Apixia setup form
  CloseDriver();   // Close driver

  if ( CaptForm <> nil ) then // started from capture form
    ShowStatus( CaptForm, nil );

  CaptForm := nil;
  N_Dump1Str( 'Apixia >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj13.CDSSettingsDlg

//******************************** TN_CMCDServObj13.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj13.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 44;
end; // function TN_CMCDServObj13.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj13.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj13.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
  Result := 'IO';
end; // function TN_CMCDServObj13.CDSGetDefaultDevDCMMod

Initialization

// Create and Register Apixia Service Object
N_CMCDServObj13 := TN_CMCDServObj13.Create( N_CMECD_Apixia_Name );

// Ininialize Apixia variables
with N_CMCDServObj13 do
begin
  PProfile     := nil;
  DevStatus    := tsDriverNotClosed;
  InfoSize     := 0;
  InfoWidth    := 0;
  InfoHeight   := 0;
  LinesCount   := 0;
  LinesTotal   := 0;
  ApixiaHandle := 0;
  USBHandle    := nil;
  CaptForm     := nil;
  TestMode     := 0;
end; // with N_CMCDServObj13 do

with K_CMCDRegisterDeviceObj( N_CMCDServObj13 ) do
begin
  CDSCaption := 'Apixia';
  IsGroup := True;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj13 ) do

Finalization

// Correct C++ Driver close
//N_CMCDServObj13.CloseDriver();

end.
