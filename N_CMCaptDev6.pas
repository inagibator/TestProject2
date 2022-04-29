unit N_CMCaptDev6;
// Duerr device

// 2013.12.22 added Dumps by Nikita
// 2014.03.05 Fixed DevNumber = -1 ( not found device name ) by Valery Ovechkin
// 2014.03.20 substituted 'K_CMShowMessageDlg' by 'ShowCriticalError' calls by Valery Ovechkin
// 2014.03.20 Changed native Duerr dialog caption by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.06.05 Changed image capture to use PNG files by Valery Ovechkin
// 2014.06.06 Fixed definition of the pixel size by Valery Ovechkin
// 2014.07.02 Error code for 'N_LoadDIBFromFileByImLib' check added ( line 824 ) by Valery Ovechkin
// 2014.09.15 Image identification by IdentifierString added by Valery Ovechkin
// 2014.09.15 Fixed File exceptions processing ( like i/o 32, etc. ) by Valery Ovechkin
// 2014.09.15 Standartizing ( All functions parameters name starts from 'A' ) by Valery Ovechkin
// 2014.09.16 Fixed images identification by Valery Ovechkin
// 2014.09.22 Vertical flip cancelled ( it was wrong for PNG format, line 964 ) by Valery Ovechkin
// 2015.03.18 CreateSlideFromFile call was modified by Nikita
// 2016.12.12 CreateSlideFromFile call was modified by Kovalev
// 2018.11.07 CDSGetDefaultDevIconInd function added

interface

uses
  Classes, StdCtrls, Windows, SysUtils, ExtCtrls, Variants, Graphics,
  Controls, Forms, Dialogs,
  K_CM0, K_CMCaptDevReg,
  N_CM1, K_Types, N_Types, N_CMCaptDev0, N_CMCaptDev6aF;
const
// ***** values for function DDCGetDir from ddconfig.dll
  DUERR_PATH_IMAGE           = 4;
  DUERR_PATH_JOB             = 8;
  DUERR_PATH_WORK            = 16;
  DUERR_ATTEMPTS_TO_GET_FILE = 50;
  DUERR_JOB_LABEL            = 'CMSJob_';

// Type for Duerr device state
type TDuerrState = (
  dsFree,           // Device Idle
  dsStartCapture,   // Start - the first capture stage
  dsWaitRunFile,    // Wait for running file
  dsWaitStatusFile, // Wait for status file
  dsFinishCapture   // Wait for eventid=5 in status file - the last capture stage
);

// Type for file "running.dat" waiting
type TDuerrRunFile = (
  rfWait,
  rfOK,
  rfFail
);

// Type for device mode
type TDuerrMode = record
  ModeName:   String;
  ModeFlags:  String;
  ImgTypes:   String;
  Resolution: String;
  Number:     String; // Mode number (from mode file)
end;

// Type for device
type TDuerrDevice = record
  DeviceName:       String;
  DeviceType:       String;
  ModeListFileName: String; // file name for mode list of device
  number:           String; // Number of device
  mode:             array of TDuerrMode;
end;

type TN_CMCDServObj6 = class ( TK_CMCDServObj )
  ImageIdentifier:      String;
  CurrentResolution:    Float;
  PSlidesArrayForTimer: TN_UDCMSArray;
  PDevProfile:          TK_PCMDeviceProfile;
  LibraryHandle:        THandle;
  DuerrMode:            Integer;
  DuerrClose:           Boolean;
  DuerrAutoClose:       Boolean;
  DuerrView:            Boolean;
  DuerrHidePat:         Boolean;
  Devices:              array of TDuerrDevice; // Array of available Duerr devices
  DuerrTimer:           TTimer;                // Duerr Timer
  DuerrState:           TDuerrState;           // Duerr State
  DuerrAttempt:         Integer;               // Attempts to get file
  DuerrWaitFileStarted: Boolean;               // Is wait_file1 started
  DuerrFileNum:         String;               // Unique number for Duerr files

  NotFoundAlreadyReported: Boolean;

  Duerr_ext:            TN_CMV_cdeclIntFunc2Int_2PAChar; // Duerr DLL function

  constructor Create              ( const ACDSName: String );
  destructor  Destroy             (); override;

  function  GetNewImageIdentifier (): String;
  function  WaitFile              ( AFileName: String; ATimeOut: Integer = 500; AAttempts: Integer = 50 ): Boolean;
  procedure ProfileToForm         ( AFrm: TN_CMCaptDev6aForm );
  function  GetDuerrPos           ( ADeviceName: String ): Integer;
  function  GetDuerrPath          ( ANumber: Integer ): String;
  function  IsSpecial             ( AStr: String ): Boolean;
  function  DuerrStrToNum         ( AStr: String ): String;
  procedure FillDeviceMode        ( ADevNumber: Integer );
  procedure FillDeviceModes       ();
  procedure FillDevices           ();
  function  IsVistaEasyRunning    (): Boolean;
  function  StartVistaEasy        ( ACloseOnExit: Boolean; ATimeOut: Integer = 500; Aattempts: Integer = 50 ): Boolean;
  function  CheckClose            ( AFileName: String ): Boolean;
  function  WaitClose             ( AClose: Boolean; ATimeOut: Integer = 500 ): Boolean;
  function  CDSGetGroupDevNames   ( AGroupDevNames: TStrings ): Integer; override;
  procedure CDSSettingsDlg        ( APDevProfile: TK_PCMDeviceProfile ); override;
  function  CreateSlideFromFile   ( const AFilePath, AFileName: String; AScanLevel : Integer ): TK_ScanTreeResult;
  procedure CDSStartCaptureImages ( APDevProfile: TK_PCMDeviceProfile ); override;
  procedure StartVista            ();
  function  CheckRunFile          (): TDuerrRunFile;
  procedure UnLockCMS             ();
  procedure OnTimerStartCapture   ();
  procedure OnTimerWaitRunFile    ();
  procedure OnTimerWaitStatusFile ();
  procedure OnTimerFinishCapture  ();
  procedure DuerrOnTimer          ( ASender: TObject );
  procedure DuerrDeleteFiles      ();
  function  CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function  CDSGetDefaultDevDCMMod( const AProductName : string ): string;
end; // end of type TN_CMCDServObj6 = class( TK_CMCDServObj )

var
  DuerrServObj:          TK_CMCDServObj;  // ServObj for Duerr
  DuerrRegisteredDevice: TN_CMCDServObj6; // Duerr registered device

implementation

uses
  K_CLib0,
  N_Gra2, N_Lib0, N_Lib1, N_Gra0, N_Gra1, N_Gra6, N_CMMain5F;

//**************************************** TN_CMCDServObj6 **********

//************************************************** TN_CMCDServObj6.Create ***
// Create Capture Duerr Device Service Object
//
//     Parameters
// ACDSName - Capture Duerr Device Service Object Name
//
// Capture Device Service Object Name is stored in CMS Data Base in Device profile
//
constructor TN_CMCDServObj6.Create( const ACDSName: String );
begin
  inherited;
  CurrentResolution    := 0;  // Default value for Resolution
  PSlidesArrayForTimer := nil;
  PDevProfile          := nil;
  LibraryHandle        := 0;   // Default value for DLL Handle
  @Duerr_ext           := nil; // Default value for DLL function address
end; // constructor TN_CMCDServObj6.Create

//************************************************* TN_CMCDServObj6.Destroy ***
// Destroy Capture Duerr Device Service Object
//
// Destroy Device Service Object and unload duerr DLL
//
destructor TN_CMCDServObj6.Destroy();
begin
  inherited;

  if ( 0 <> LibraryHandle ) then             // if DLL still Loaded
    if not FreeLibrary( LibraryHandle ) then // if DLL not UnLoaded
      N_CMV_ShowCriticalError( 'Duerr', 'Duerr internal error. ' +
                               'DLL ddconfig.dll not free. ' );

end; // destructor TN_CMCDServObj6.Destroy

//*********************************** TN_CMCDServObj6.GetNewImageIdentifier ***
// Generate new unique image identifier
//
//    Parameters
// Result    -  image identifier as string
//
function TN_CMCDServObj6.GetNewImageIdentifier(): String;
var
  PCFreq, PCTime: Int64;
begin
  Result := DUERR_JOB_LABEL + DuerrFileNum + '_' +
            K_CMGetPatientDetails( -1, '(#PatientCardNumber#)' ) + '_' +
            IntToStr( GetTickCount() );

  PCFreq := 0;
  PCTime := 0;

  if QueryPerformanceCounter( PCTime ) then
    Result := Result + '_' + IntToStr( PCTime );

  if QueryPerformanceFrequency( PCFreq ) then
    Result := Result + '_' + IntToStr( PCFreq );

end; // function TN_CMCDServObj6.GetNewImageIdentifier

//************************************************ TN_CMCDServObj6.WaitFile ***
// wait for file or return False if attempts limit exceded
//
//    Parameters
// AFileName - desired file name
// ATimeOut  - interval for file existing check in milliseconds
// AAttempts - maximum count of attempts
// Result    -  True if file exists, else False
//
function TN_CMCDServObj6.WaitFile( AFileName: String; ATimeOut: Integer = 500; AAttempts: Integer = 50 ): Boolean;
var
  AttemptsDone: Integer; // counter of attempts
begin
  Result := False;
  AttemptsDone := 0;      // set counter of attempts to 0

  while not FileExists( AFileName ) do // while file not exists
  begin
    if ( AttemptsDone > AAttempts ) then // if count of attempts is more then maximum
      Exit;                  // error - file not exists too long time

    Sleep( ATimeOut );        // wait timeout
    Application.ProcessMessages;
    Inc( AttemptsDone );     // increase attempts counter by 1
  end; // while not FileExists( FileName ) do // while file not exists

  Result := True;            // success
end; // function TN_CMCDServObj6.WaitFile

//************************************************ TN_CMCDServObj6.WaitFile ***
// set duerr form elements (4 checkbox and 1 modes combobox) by profile
//
//    Parameters
// AFrm - pointer to settings form
//
procedure TN_CMCDServObj6.ProfileToForm( AFrm: TN_CMCaptDev6aForm );
var
  param: String;
  i: Integer;
  ParamLength: Integer;
  DevNumber: Integer;
  ModeCount: Integer;
  CloseOnExit: Boolean;
begin
  param :=  AFrm.CMOFPDevProfile.CMDPStrPar1; // profile special parameter
  ParamLength := Length( param ); // length of parameter in characters

  // close Duerr driver on close scan dialog
  CloseOnExit := ( '1' = Copy( param, 1, 1 ) );

  // if VistaEasy not started and can not start
  if not DuerrRegisteredDevice.StartVistaEasy( CloseOnExit ) then
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'Vista Easy is not installed. ' +
                             'Please close Centaur Media Suite and install ' +
                             'Duerr Vista Easy. Press OK to continue' );
    Exit;
  end;

  // set form elements to default values
  AFrm.cbCloseonexit.Checked         := False;
  AFrm.cbAutoclosePrescan.Checked    := False;
  AFrm.cbActivateView.Checked        := False;
  AFrm.cbDoNotDisplayPatinfo.Checked := False;
  AFrm.cbDeviceMode.Items.Clear; // clear modes combobox
  AFrm.cbDeviceMode.ItemIndex := -1;
  // get number of device by it's caption
  DevNumber := DuerrRegisteredDevice.GetDuerrPos( AFrm.CMOFPDevProfile.CMDPProductName );

  if ( 0 > DevNumber ) then // if device not found in devices array
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'internal error. ' +
                            'Device "' + AFrm.CMOFPDevProfile.CMDPProductName +
                            '" not found' );
    Exit;
  end;

  ModeCount := Length( devices[DevNumber].mode ); // count modes for device

  for i := 0 to ModeCount - 1 do // add each mode name to modes combobox
    AFrm.cbDeviceMode.Items.Add( devices[DevNumber].mode[i].ModeName );

  if ( 0 < ModeCount ) then            // if there is at least 1 mode
    AFrm.cbDeviceMode.ItemIndex := 0; // select 1st combobox item

  if ( 5 > ParamLength ) then // param length must be at least 5
    Exit;

  // set checkboxes values by param string
  AFrm.cbCloseonexit.Checked         := CloseOnExit;                   // 1st character
  AFrm.cbAutoclosePrescan.Checked    := ( '1' = Copy( param, 2, 1 ) ); // 2nd character
  AFrm.cbActivateView.Checked        := ( '1' = Copy( param, 3, 1 ) ); // 3rd character
  AFrm.cbDonotDisplayPatinfo.Checked := ( '1' = Copy( param, 4, 1 ) ); // 4th character
  // device mode = param string except 4 first characters
  AFrm.cbDeviceMode.ItemIndex := StrToInt( Copy( param, 5, ParamLength - 4 ) );

end; // procedure TN_CMCDServObj6.ProfileToForm

//********************************************* TN_CMCDServObj6.GetDuerrPos ***
// Get Duerr Device position in array by name
//
//     Parameters
// ADeviceName - Duerr Device Name
// Result      - Return position in array ( -1 if not found )
//
function TN_CMCDServObj6.GetDuerrPos( ADeviceName: String ): Integer;
var
  i: Integer;
  cnt: Integer;
begin
  Result := -1;
  cnt := Length( devices ); // count of devices

  for i := 0 to cnt - 1 do // for each device
  begin

    if ( ADeviceName = devices[i].DeviceName ) then // check device name
    begin
      Result := i;
      Exit;
    end; // if ( ADeviceName = devices[i].DeviceName ) then // check device name

  end; // for i := 0 to cnt - 1 do // for each device

end; // function TN_CMCDServObj6.GetDuerrPos

//******************************************** TN_CMCDServObj6.GetDuerrPath ***
// Get special Duerr path by number n (function DDCGetDir from ddconfig.dll)
//
//     Parameters
// ANumber - parameter for DDCGetDir, see Duerr constants above
// Result  - Duerr path , or '' in case of error
//
function TN_CMCDServObj6.GetDuerrPath( ANumber: Integer ): String;
var
  Buffer: PAnsiChar;
  FuncResult: Integer;
begin
  Result := '';

  if ( @Duerr_ext = nil ) then
  begin
    LibraryHandle :=LoadLibrary( 'ddconfig.dll' ); // Load ddconfig.dll

    if ( LibraryHandle <> 0 ) then // if DLL loaded
    begin
      // Get address of DDCGetDir
      @Duerr_ext := GetProcAddress( LibraryHandle, 'DDCGetDir' );

      if ( @Duerr_ext = nil ) then // if function DDCGetDir found in DLL
      begin
        N_Dump1Str( 'Duerr >> internal error. Function not found' );
        Exit;
      end;

    end
    else // if DLL NOT loaded
    begin
      N_Dump1Str( 'Duerr >> internal error. DLL ddconfig.dll not found' );
      Exit;
    end; // if ( LibraryHandle <> 0 ) then // if DLL loaded

  end; // if ( @Duerr_ext = nil ) then

  GetMem( Buffer, 2048 ); // Allocate memory for buffer
  FuncResult := Duerr_ext( ANumber, Buffer, nil ); // call DDCGetDir

  if ( 0 <> FuncResult ) then // if DDCGetDir returns error
  begin
    FreeMem( Buffer, 2048 ); // Free buffer memory
    N_Dump1Str( 'Duerr >> internal error. DDCGetDir result code=' +
                IntToStr( FuncResult ) );
    Exit;
  end;

  Result := N_AnsiToString( AnsiString( Buffer ) ); // return buffer converted to string
  FreeMem( Buffer, 2048 ); // Free buffer memory
end; // function TN_CMCDServObj6.GetDuerrPath

//*********************************************** TN_CMCDServObj6.IsSpecial ***
// Check is there special duerr string (like '[Activejob]', etc.)
//
//     Parameters
// AStr   - string for check
// Result - True if s is special string, else False
//
function TN_CMCDServObj6.IsSpecial( AStr: String ): Boolean;
var
  t: String;
begin
  t := LowerCase( AStr ); // s LowerCase
  Result := ( ( 0 < Pos( 'info]', t ) ) or ( 0 < Pos( 'job]', t ) ) );
end; // function TN_CMCDServObj6.IsSpecial

//******************************************* TN_CMCDServObj6.DuerrStrToNum ***
// Convert string to integer (spesial for duerr)
//
//     Parameters
// AStr   - string for convert
// Result - converted string, '' by default (if error)
//
function TN_CMCDServObj6.DuerrStrToNum( AStr: String ): String;
var
  BracePos: Integer;
  StrLen: Integer;
  t: String;
begin
  Result := '';              // default value ""

  if IsSpecial( AStr ) then     // if s - special duerr string
    Exit;

  StrLen := Length( AStr );     // Length of string s

  if ( 3 > StrLen ) then     // if s contains less than 3 chars
    Exit;

  if ( '[' <> AStr[1] ) then    // if there is no "[" in s
    Exit;

  t := Copy( AStr, 2, StrLen - 1 );

  BracePos := Pos( ']', t );    // if there is no "]" in s

  if ( 2 > BracePos ) then
    Exit;

  Result := Copy( t, 1, BracePos - 1 ); // return s without "[" and "]"
end; // function TN_CMCDServObj6.DuerrStrToNum

//****************************************** TN_CMCDServObj6.FillDeviceMode ***
// Fill device modes by device number
//
//     Parameters
// ADevNumber - device number
//
procedure TN_CMCDServObj6.FillDeviceMode( ADevNumber: Integer );
var
  s: String;
  FileName: String;
  ModeNumber: String;
  ModeCount: Integer;
  i, cnt, StrLen: Integer;
  SL: TStringList;
begin
  FileName := devices[ADevNumber].ModeListFileName; // get mode file name

  if not FileExists( FileName ) then // if file not exists
    Exit;

  ModeCount := -1;
  SL := TStringList.Create();

  if ( nil = SL ) then
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'FillDeviceMode, StringList = NULL' );
    Exit;
  end; // if ( nil = SL ) then

  if not N_CMV_FileToSL( SL, FileName ) then
  begin

    if ( nil <> SL ) then
      SL.Free;

    Exit;
  end; // if not N_CMV_FileToSL( SL, FileName ) then


  cnt := SL.Count;

  for i := 0 to cnt - 1 do // for each item of StringList
  begin
    s := SL[i];
    ModeNumber := DuerrStrToNum( s );   // try to get mode number

    if ( '' = ModeNumber ) then         // if string s is NOT like "[0]", "[1]", etc.
    begin

      if ( 0 <= ModeCount ) then        // if array is prepared for new item
      begin
        StrLen := Length( s );
        // fill mode parameters from mode file
        if ( 1 = Pos( 'ModeName=', s ) ) then
          devices[ADevNumber].mode[ModeCount].ModeName   := Copy( s, 10, StrLen - 9 )
        else if ( 1 = Pos( 'ModeFlags=', s ) ) then
          devices[ADevNumber].mode[ModeCount].ModeFlags  := Copy( s, 11, StrLen - 10 )
        else if ( 1 = Pos( 'ImgTypes=', s ) ) then
          devices[ADevNumber].mode[ModeCount].ImgTypes   := Copy( s, 10, StrLen - 9 )
        else if ( 1 = Pos( 'Resolution=', s ) ) then
          devices[ADevNumber].mode[ModeCount].Resolution := Copy( s, 12, StrLen - 11 );
      end;

    end
    else                           // if string s is like "[0]", "[1]", etc.
    begin
      Inc( ModeCount );      // increase mode counter by 1
      // add new element to array
      SetLength( devices[ADevNumber].mode, ModeCount + 1 );
      // fill mode parameters (default values)
      devices[ADevNumber].mode[ModeCount].ModeName   := '';
      devices[ADevNumber].mode[ModeCount].ModeFlags  := '';
      devices[ADevNumber].mode[ModeCount].ImgTypes   := '';
      devices[ADevNumber].mode[ModeCount].Resolution := '';
      devices[ADevNumber].mode[ModeCount].Number     := ModeNumber;
    end;
  end; // for i := 0 to cnt - 1 do // for each item of StringList

  if ( nil <> SL ) then
    SL.Free;

end; // procedure TN_CMCDServObj6.FillDeviceMode

//***************************************** TN_CMCDServObj6.FillDeviceModes ***
// Fill device modes for each Duerr device
//
procedure TN_CMCDServObj6.FillDeviceModes();
var
  i: Integer;
  DeviceCount: Integer;
begin
  DeviceCount := Length( devices ); // count devices

  for i := 0 to DeviceCount - 1 do
    FillDeviceMode( i );
end; // procedure TN_CMCDServObj6.FillDeviceModes

//********************************************* TN_CMCDServObj6.FillDevices ***
// Fill each Duerr device info (names, resoluton, modes, etc.)
//
procedure TN_CMCDServObj6.FillDevices();
var
  s: String;
  FileName: String;
  DeviceId: String;
  DeviceCount: Integer;
  i, cnt, StrLen: Integer;
  SL: TStringList;
begin
  DeviceCount := -1;
  SetLength( devices, DeviceCount + 1 );
  // get path to "running.dat"
  FileName := GetDuerrPath( DUERR_PATH_JOB ) + '\running.dat';

  if not FileExists( FileName ) then // if file "running.dat" not exists
    Exit;

  SL := TStringList.Create();

  if ( nil = SL ) then
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'FillDevices, StringList = NULL' );
    Exit;
  end; // if ( nil = SL ) then

  if not N_CMV_FileToSL( SL, FileName ) then
  begin

    if ( nil <> SL ) then
      SL.Free;

    Exit;
  end; // if not N_CMV_FileToSL( SL, FileName ) then

  cnt := SL.Count;

  for i := 0 to cnt - 1 do // for each item of StringList
  begin
    s := SL[i];
    DeviceId := DuerrStrToNum( s );   // try to get device id

    if ( '' = DeviceId ) then         // if string is not a device id
    begin
      if ( 0 <= DeviceCount ) then    // if array is prepared for new item
      begin
        StrLen := Length( s );

        if ( 1 = Pos( 'DeviceName=', s ) ) then
          devices[DeviceCount].DeviceName := Copy( s, 12, StrLen - 11 )
        else if ( 1 = Pos( 'DeviceType=', s ) ) then
          devices[DeviceCount].DeviceType := Copy( s, 12, StrLen - 11 )
        else if ( 1 = Pos('ModeListFileName=', s ) ) then
          devices[DeviceCount].ModeListFileName := Copy( s, 18, StrLen - 17 );

      end; // if ( 0 <= DeviceCount ) then    // if array is prepared for new item
    end
    else // if string is device id
    begin
      // add new element to array and fill it with default values
      Inc( DeviceCount );
      SetLength( devices, DeviceCount + 1 );
      devices[DeviceCount].DeviceName       := '';
      devices[DeviceCount].DeviceType       := '';
      devices[DeviceCount].ModeListFileName := '';
      devices[DeviceCount].Number           := DeviceId;
      setlength( devices[DeviceCount].mode, 0 );
    end; // if ( '' = DeviceId ) then         // if string is not a device id

  end; // for i := 0 to cnt - 1 do // for each item of StringList

  if ( nil <> SL ) then
    SL.Free;

  FillDeviceModes; // fill modes array for all duerr devices
end; // procedure TN_CMCDServObj6.FillDevices

//************************************** TN_CMCDServObj6.IsVistaEasyRunning ***
// Check is VistaScanConfig.exe running
//
//     Parameters
// Result - true if VistaScanConfig.exe is running, else false
//
function TN_CMCDServObj6.IsVistaEasyRunning(): Boolean;
var
  RunFile: String;
begin
  Result := False;

  // if process is not exist - false
  if not N_CMV_ProcessExists( GetDuerrPath( DUERR_PATH_WORK ) + '\VistaScanConfig.exe' ) then
      Exit;

  RunFile := GetDuerrPath( DUERR_PATH_JOB ) + '\running.dat'; // get path to file "running.dat"
  Result := FileExists( RunFile ); // if file "running.dat" exists - true
end; // function TN_CMCDServObj6.IsVistaEasyRunning

//****************************************** TN_CMCDServObj6.StartVistaEasy ***
// Start duerr driver VistaScanConfig.exe
//
//     Parameters
// ACloseOnExit - comand line parameter ( Close VistaEasy on Exit )
// ATimeOut     - time delay in millisecond between attempts to find "running.dat"
// AAttempts    - maximum attempts to find file "running.dat"
// Result       - True if started or already runs, False if error while starting
//
function TN_CMCDServObj6.StartVistaEasy( ACloseOnExit: Boolean;
                                         ATimeOut: Integer = 500;
                                         AAttempts: Integer = 50 ): Boolean;
var
  StartLine: String;
  RunFile: String;
  SavedCursor: TCursor;
begin
  SavedCursor := Screen.Cursor;   // save current cursor to variable
  Screen.Cursor := crHourGlass;   // set windows cursor to HourGlass
  Result := True;

  if IsVistaEasyRunning() then    // if process is already started
  begin
    FillDevices;                  // fill device array
    Screen.Cursor := SavedCursor; // reset cursor value to initial
    Exit;
  end;

  // start line for launch VistaScanConfig.exe
  StartLine := '"' + GetDuerrPath( DUERR_PATH_WORK ) + '\VistaScanConfig.exe" "/vistascaneasy"';

  if ACloseOnExit then
    StartLine := StartLine + ' "/CloseOnCloseScan"';

  // try to create process by start line
  Result := N_CMV_CreateProcess( StartLine);

  if not Result then // if process not created - return false
  begin
    Screen.Cursor := SavedCursor; // reset cursor value to initial
    Exit;
  end; // if not Result then // if process not created - return false

  // full path to file "running.dat"
  RunFile := GetDuerrPath( DUERR_PATH_JOB ) + '\running.dat';
  // wait for this file
  Result := WaitFile( RunFile, ATimeOut, AAttempts );

  if Result then   // if file "running.dat" exists
    FillDevices;  // fill device array

  Screen.Cursor := SavedCursor; // reset cursor value to initial
end; // function TN_CMCDServObj6.StartVistaEasy

//********************************************** TN_CMCDServObj6.CheckClose ***
// Check is user close Duerr Capture Dialog
//
//     Parameters
// AFileName - path to Duerr status file
// Result    - True if user closed Capture Dialog, else False
//
function TN_CMCDServObj6.CheckClose( AFileName: String ): Boolean;
var
  SL: TStringList;
begin
  Result := False; // default value

  if not FileExists( AFileName ) then
    Exit;

  SL := TStringList.Create();

  if ( nil = SL ) then
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'Error CheckClose StringList = NULL' );
    Exit;
  end; // if ( nil = SL ) then

  if not N_CMV_FileToSL( SL, AFileName ) then
  begin

    if ( nil <> SL ) then
      SL.Free;

    Exit;
  end; // if not N_CMV_FileToSL( SL, FileName ) then

  Result := ( '5' = N_CMV_GetParamFromSL( SL, 'EventId' ) );

  if ( nil <> SL ) then
    SL.Free;

end; // function TN_CMCDServObj6.CheckClose

//*********************************************** TN_CMCDServObj6.WaitClose ***
// Wait until user close Duerr Capture Dialog
//
//     Parameters
// AClose   - parameter for command line
// ATimeOut - delay in milliseconds between user action (dialog close) checks
// Result   - True if Duerr dialog closed, else False
//
function TN_CMCDServObj6.WaitClose( AClose: Boolean; ATimeOut: Integer = 500 ): Boolean;
var
  FileName: String;
  DumpTime: Integer;
begin
  Result := FALSE;

  if not IsVistaEasyRunning then         // if VistaEasy is not running
    if not StartVistaEasy( AClose ) then   // try to start it
      Exit;

  FileName := GetDuerrPath( DUERR_PATH_JOB ) + '\Stat' + DuerrFileNum + '.txt'; // status file name
  DumpTime := 0;

  while not FileExists( FileName ) and not K_CMD4WAppFinState do // wait for status file
  begin
    Sleep( ATimeOut );
    Application.ProcessMessages;
    DumpTime := DumpTime + ATimeOut;

    if DumpTime > 60000 then
    begin
      DumpTime := 0;
      N_Dump2Str( 'Duerr >> Wating for ' + FileName );
    end;

  end;

  // wait until user close scan dialog
  DumpTime := 0;

  while not CheckClose( FileName ) and not K_CMD4WAppFinState do
  begin
    Sleep( ATimeOut );
    Application.ProcessMessages;
    DumpTime := DumpTime + ATimeOut;

    if DumpTime > 60000 then
    begin
      DumpTime := 0;
      N_Dump2Str( 'Duerr >> Wating for ' + FileName );
    end; // if DumpTime > 60000 then

  end;

  Result := not K_CMD4WAppFinState;
end; // procedure TN_CMCDServObj6.WaitClose

//************************************* TN_CMCDServObj6.CDSGetGroupDevNames ***
// Get Duerr Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
//
// Result         - number of all Devices Names
//
function TN_CMCDServObj6.CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer;
var
  i: integer;
begin
  Result := 0; // return device count
  N_Dump1Str( 'Duerr >> Try to Get Group Dev Names' );

  if not StartVistaEasy( False ) then // if VistaEasy not started and can not start
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'Vista Easy is not installed. ' + #13#10 +
                             'Please close Centaur Media Suite and install ' + #13#10 +
                             'Duerr Vista Easy. Press OK to continue.' );
    Exit;
  end;

  N_Dump1Str( 'Duerr >> Successfully Get Group Dev Names' );
  N_Dump1Str( 'Duerr >> Device count = ' + IntToStr(Result) );
  Result := Length( devices );   // count devices

  for i := 0 to Result - 1 do    // for each device
     AGroupDevNames.Add( devices[i].DeviceName );

  if ( 1 > Result ) then
    N_CMV_ShowCriticalError( 'Duerr', 'There is no Duerr Dental device registered on this PC. ' + #13#10 +
                             'Please start Duerr VistaNetConfig and register the device. ' + #13#10 +
                             'Press OK to continue.' );
end; // function TN_CMCDServObj6.CDSGetGroupDevNames

//****************************************** TN_CMCDServObj6.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj6.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var frm: TN_CMCaptDev6aForm;
begin
  frm := TN_CMCaptDev6aForm.Create( Application );
  frm.BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
  frm.CMOFPDevProfile := APDevProfile;
  ProfileToForm( frm );
  frm.Caption := APDevProfile.CMDPCaption;
  frm.ShowModal();
end; // procedure TN_CMCDServObj6.CDSSettingsDlg

//*********************************************** TN_CMCDServObj6.CreateSlideFromFile ***
// wait for file or return False if attempts limit exceded
//
//    Parameters
// AFileName - Full image file path
//
// Result    - K_tucOK if success, else K_tucSkipSubTree
//
function TN_CMCDServObj6.CreateSlideFromFile( const AFilePath, AFileName: String; AScanLevel : Integer ): TK_ScanTreeResult;
var
  ResCode:         Integer;
  ResolutionInt:   Integer;// Resolution in pixel per meter
  SlideCount:      Integer;   // count of slides
  Dib:             TN_DIBObj;        // DIB Object
  DevNumber:       Integer;    // Duerr device number
  FileName:        String;
  PNGFileNameWrk:  String;   // Desirable PNG file name for debug in CMS
  FileNum:         String;   // Unique number for creating image files
  FileDat:         String;
  JobLabel:        String;
  len: Integer;
  FilePrefixes, FilePostfixes: TN_SArray;
  SL: TStringList;
begin
  Result := K_tucSkipSubTree;
  N_Dump2Str( 'Start TN_CMCDServObj6.CreateSlideFromFilel ' + AFileName );

  // get device number by profile
  DevNumber := GetDuerrPos( PDevProfile.CMDPProductName );

  if ( 0 > DevNumber ) then // if device not found
  begin

    if not NotFoundAlreadyReported then // show alert only 1 time for 1st image
    begin
      N_CMV_ShowCriticalError( 'Duerr', 'Device "' + PDevProfile.CMDPProductName +
                               '" not found in the list of registered Duerr devices. ' + #13#10 +
                               '( It happened during capturing )' + #13#10 +
                               'Please register the device in Duerr Vista Config. ' + #13#10 +
                               'Press OK to continue' );
    end; // if not NotFoundAlreadyReported then // show alert only 1 time for 1st image

    NotFoundAlreadyReported := True;
    UnlockCMS();
    Exit;
  end; // if ( 0 > DevNumber ) then // if device not found

  if ( AFileName = '' ) then   // if  AFileName  is a directory
    Exit;

  FileName := AFilePath + AFileName;
  len      := Length( AFileName );
  FileDat  := AFilePath + Copy( AFileName, 1, len - 4 ) + '.dat';

  if not FileExists( FileName ) then // if the file not exists
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'internal error. ' +
                             'File ''' + FileName + ''' not exists' );
    Exit;
  end; // if not FileExists( AFileName ) then // if the file not exists

  ResolutionInt := 0;
  JobLabel      := '';

   // Get Image Resolution and IndentifierString
  if ( FileExists( FileDat ) ) then
  begin
    SL := TStringList.Create;

    if ( nil = SL ) then
    begin
      N_CMV_ShowCriticalError( 'Duerr', 'CreateSlideFromFile StringList = NULL' );
      Exit;
    end; // if ( nil = SL ) then

    if not N_CMV_FileToSL( SL, FileDat ) then
    begin
      N_CMV_ShowCriticalError( 'Duerr', 'CreateSlideFromFile DAT File not loaded: ' + FileDat );

      if ( nil <> SL )  then
        SL.Free;

      Exit;
    end; // if not N_CMV_FileToSL( SL, FileDat ) then

    ResolutionInt := StrToIntDef( N_CMV_GetParamFromSL( SL, 'PixelSize' ), 0 );
    JobLabel      := N_CMV_GetParamFromSL( SL, 'IdentifierString' );

    if ( nil <> SL )  then
      SL.Free;

  end; // Get Image Resolution and IndentifierString

  N_Dump1Str( 'Duerr >> IdentifierString = ' + JobLabel );

  if ( UpperCase( JobLabel ) <> UpperCase( ImageIdentifier ) ) then // foreign image
  begin
    N_Dump1Str( 'Duerr >> Foreign IdentifierString, ignore it' );
    exit;
  end; // if ( UpperCase( JobLabel ) <> UpperCase( ImageIdentifier ) ) then // foreign image

  if N_MemIniToBool( 'CMS_UserDeb', 'SaveImage', False ) then
  begin
    SetLength( FilePrefixes, 1 );
    FilePrefixes[0] := N_CMV_GetWrkDir() + 'duerr_';
    SetLength( FilePostfixes, 1 );
    FilePostfixes[0] := '.png';
    FileNum := N_CMV_GetNewNum( FilePrefixes, FilePostfixes, 6 );
    PNGFileNameWrk := FilePrefixes[0] + FileNum + FilePostfixes[0];
    N_Dump2Str( 'Save to file ' + PNGFileNameWrk );

    if not CopyFile( @FileName[1], @PNGFileNameWrk[1], False ) then
    begin
      N_CMV_ShowCriticalError( 'Duerr', 'File ''' + FileName + ''' did not copied to' +
                               '''' + PNGFileNameWrk + '''' );
    end; // if not CopyFile( @AFileName[1], @PNGFileNameWrk[1], False ) then

  end; // if N_MemIniToBool( 'CMS_UserDeb', 'SaveImage', False ) then

  SlideCount := Length( PSlidesArrayForTimer );    // count of slides
  dib := nil;
  ResCode := N_LoadDIBFromFileByImLib( dib, FileName );

  if ( ResCode <> 0 ) then
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'N_LoadDIBFromFileByImLib = ' + IntToStr( ResCode ) );
    Exit;
  end; // if ( ResCode <> 0 ) then

  if ( dib = nil ) then
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'dib = nil' );
    Exit;
  end; // if ( dib = nil ) then

  // Get Resolution for current device and mode
  if ( 0 < ResolutionInt ) then
  begin
    // set DIBObj resolution
    ResolutionInt := Round( 1000000000 / ResolutionInt );
    Dib.DIBInfo.bmi.biXPelsPerMeter := ResolutionInt;
    Dib.DIBInfo.bmi.biYPelsPerMeter := ResolutionInt;
  end;

  //dib.FlipAndRotate( 2 ); // Flip Vertically
  SetLength( PSlidesArrayForTimer, SlideCount + 1 );   // add slide

  // add image to appropriate slide
  N_Dump1Str( 'Duerr >> Create slide' );
  PSlidesArrayForTimer[SlideCount] :=
  K_CMSlideCreateFromDeviceDIBObj( Dib, PDevProfile, SlideCount + 1, 0 );
//  PSlidesArrayForTimer[SlideCount].SetAutoCalibrated(); !!! is done inside  K_CMSlideCreateFromDeviceDIBObj
  Result := K_tucOK;
end; // procedure TN_CMCDServObj6.CreateSlideFromFile

//**************************************** TN_CMCDServObj6.CDSCaptureImages ***
// Capture Images by Duerr and fill ASlidesArray by them
//
//     Parameters
// APDevProfile - pointer to device profile record
//
procedure TN_CMCDServObj6.CDSStartCaptureImages( APDevProfile: TK_PCMDeviceProfile );
var
  StrLen: Integer;
  ParStr: String;
begin

  // set mode number and 4 duerr dialog flags (checkboxes) by default
  DuerrMode      := 0;
  DuerrClose     := False;
  DuerrAutoClose := False;
  DuerrView      := False;
  DuerrHidePat   := False;

  SetLength( PSlidesArrayForTimer, 0 ); // Initialize ASlidesArray

  PDevProfile := APDevProfile;

  ParStr := DuerrRegisteredDevice.PDevProfile.CMDPStrPar1;   // profile parameters string
  StrLen := Length( ParStr );       // it's length
  N_Dump1Str( 'Duerr >> Capture image, Profile parameter=''' + ParStr + '''' );

  if ( 4 < StrLen ) then // if profile parameters string at least 5 characters
  begin
    // set 4 mode number and 4 duerr flags from profile parameters string
    DuerrMode      := StrToInt( Copy( ParStr, 5, StrLen - 4 ) );
    DuerrClose     := ( '1' = Copy( ParStr, 1, 1 ) );
    DuerrAutoClose := ( '1' = Copy( ParStr, 2, 1 ) );
    DuerrView      := ( '1' = Copy( ParStr, 3, 1 ) );
    DuerrHidePat   := ( '1' = Copy( ParStr, 4, 1 ) );
  end; // if ( 4 < StrLen ) then // if profile parameters string at least 5 characters

  DuerrState := dsStartCapture;
  // try to start VistaEasy if it is not running
  StartVista();

  if ( dsFree = DuerrState ) then // if Vista Easy not started
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'Vista Easy is not installed. ' +
                             'Please close Centaur Media Suite and install ' +
                             'Duerr Vista Easy. Press OK to continue' );
    Exit;
  end;

  N_Dump1Str( 'Duerr >> VistaEasy successfully started' );
  DuerrTimer.Enabled := True;

end; // procedure TN_CMCDServObj6.CDSCaptureImages

//********************************************** TN_CMCDServObj6.StartVista ***
// Start duerr driver VistaScanConfig.exe if it is nesessary
//
procedure TN_CMCDServObj6.StartVista();
var
  StartLine: String;
begin
  DuerrWaitFileStarted := False;
  DuerrAttempt         := 0;

  if IsVistaEasyRunning() then // if process is already started
  begin
    FillDevices; // fill device array
    Exit;
  end; // if IsVistaEasyRunning() then // if process is already started

  // start line for launch VistaScanConfig.exe
  StartLine := '"' + GetDuerrPath( DUERR_PATH_WORK ) + '\VistaScanConfig.exe" "/vistascaneasy"';

  if DuerrClose then
    StartLine := StartLine + ' "/CloseOnCloseScan"';

  // try to create process by start line
  if not N_CMV_CreateProcess( StartLine ) then // if process not created - return false
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'Create Process error' );
    UnlockCMS();
    Exit;
  end; // if not N_CMV_CreateProcess( StartLine ) then // if process not created - return false

  // wait for this file
  DuerrWaitFileStarted := True;
end; // procedure TN_CMCDServObj6.StartVista

//******************************************** TN_CMCDServObj6.CheckRunFile ***
// wait for file or return False if attempts limit exceded
//
// Result - eRunFileOK if file "running.dat" exists
//
function TN_CMCDServObj6.CheckRunFile(): TDuerrRunFile;
begin
  Result := rfWait;
  Inc( DuerrAttempt ); // Increase Attempt counter

  // If File "running.dat" exists
  if FileExists( GetDuerrPath( DUERR_PATH_JOB ) + '\running.dat' ) then
  begin
    FillDevices(); // fill devices structure
    Result := rfOK; // good result
    Exit;
  end; // if FileExists( GetDuerrPath( DUERR_PATH_JOB ) + '\running.dat' ) then

  if ( DuerrAttempt > DUERR_ATTEMPTS_TO_GET_FILE ) then
    Result := rfFail;
end; // function TN_CMCDServObj6.CheckRunFile

//*********************************************** TN_CMCDServObj6.UnlockCMS ***
// "Unlock" CMS interface after capturing
//
procedure TN_CMCDServObj6.UnlockCMS();
begin
  DuerrState         := dsFree;
  DuerrTimer.Enabled := False;
  K_CMSlidesSaveScanned3( PDevProfile, PSlidesArrayForTimer );
end; // procedure TN_CMCDServObj6.UnlockCMS

//************************************* TN_CMCDServObj6.OnTimerStartCapture ***
// Timer event for 1st step - initialize capture
//
procedure TN_CMCDServObj6.OnTimerStartCapture();
var
  ResCode: TDuerrRunFile;
  DevNumber: Integer;
  StringList: TStringList;
  PatName, PatSurname, PatID: String;
  FilePrefixes, FilePostfixes: TN_SArray;
  DuerrJobPath: String;
  DuerrIniFile: String;
begin
  if DuerrWaitFileStarted then
  begin
    ResCode := CheckRunFile();

    if ( ResCode = rfWait ) then
    begin
      DuerrTimer.Enabled := True;
      Exit;
    end;

    if ( ResCode = rfFail ) then
    begin
      N_CMV_ShowCriticalError( 'Duerr', 'File "running.dat" not found' );
      UnlockCMS();
      Exit;
    end;

  end; // if DuerrWaitFileStarted then

  // get device number by profile
  DevNumber := GetDuerrPos( PDevProfile.CMDPProductName );

  if ( 0 > DevNumber ) then // if device not found
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'Device "' + PDevProfile.CMDPProductName +
                             '" not found in the list of registered Duerr devices. ' + #13#10 +
                             '( It happened at capturing start )' + #13#10 +
                             'Please register the device in Duerr Vista Config. ' + #13#10 +
                             'Press OK to continue' );
    UnlockCMS();
    Exit;
  end; // if ( 0 > DevNumber ) then // if device not found

  DuerrJobPath := GetDuerrPath( DUERR_PATH_JOB );

  // get unique number for Duerr job and status files
  SetLength( FilePrefixes,  2 );
  SetLength( FilePostfixes, 2 );
  FilePrefixes[0] := DuerrJobPath + '\VSJob';
  FilePrefixes[1] := DuerrJobPath + '\Stat';
  FilePostfixes[0] := '.ini';
  FilePostfixes[1] := '.txt';

  DuerrFileNum := N_CMV_GetNewNum( FilePrefixes, FilePostfixes, 5 );

  // start duerr job
  N_Dump1Str( 'Duerr >> Start Duerr job' );

  DuerrDeleteFiles();

  // Begin StringList for job file
  StringList := TStringList.Create;
  // Add device type and id
  StringList.Add( '[Parameter]' );
  StringList.Add( 'DeviceType=' + devices[DevNumber].DeviceType );
  StringList.Add( 'DeviceUID=' + devices[DevNumber].Number );

  // Add mode parameters (from forms combobox "Device mode")
  if ( ( Length( devices[DevNumber].mode ) > DuerrMode ) and ( 0 <= DuerrMode ) ) then
  begin
    StringList.Add( 'Scanmode=' + devices[DevNumber].mode[DuerrMode].Number );
    StringList.Add( 'ScanmodeTypes=' + devices[DevNumber].mode[DuerrMode].ImgTypes );
  end;

  ImageIdentifier := GetNewImageIdentifier();
  StringList.Add( 'IdentifierString=' + ImageIdentifier );   // job identifier
  StringList.Add( 'JobName=' + PDevProfile.CMDPProductName );      // job name
  StringList.Add( 'StatusFile=Stat' + DuerrFileNum + '.txt' ); // status file name

  // checkbox "Autoclose the Prescan interface"
  if DuerrAutoClose then
    StringList.Add( 'AutoClose=1' )
  else
    StringList.Add( 'AutoClose=0' );

  // checkbox "Activate Vista Easy View"
  if DuerrView then
    StringList.Add( 'UseVistaEasyView=1' )
  else
    StringList.Add( 'UseVistaEasyView=0' );

  StringList.Add( 'MinimizeScanDialog=0' ); // do not minimize scan dialog
  StringList.Add( 'CPHwnd=0' );
  StringList.Add( 'CreateBMP=0' ); // DO NOT create BMP file
  StringList.Add( 'CreatePNG=1' ); // create PNG file
  StringList.Add( 'CreateXYZ=0' ); // create XYZ file

  // checkbox "Do not display patient details on a scanner"
  if not DuerrHidePat then
  begin
    PatSurname := K_CMGetPatientDetails( -1, '(#PatientSurname#)' );
    PatName    := K_CMGetPatientDetails( -1, '(#PatientFirstName#)' );
    PatID      := K_CMGetPatientDetails( -1, '(#PatientCardNumber#)' );
    StringList.Add( '[AdditionalInformation]' );
    StringList.Add( 'PatientLastName=' + PatSurname );
    StringList.Add( 'PatientFirstName=' + PatName );
    StringList.Add( 'PatientID=' + PatID );
    N_Dump1Str( 'Duerr >> PatientLastName = ' + PatSurname );
    N_Dump1Str( 'Duerr >> PatientFirstName = ' + PatName );
    N_Dump1Str( 'Duerr >> PatientID = ' + PatID );
  end; // if not DuerrHidePat then
  // End StringList for job file

  // Make job file from StringList SL above
  DuerrIniFile := DuerrJobPath + '\VSJob' + DuerrFileNum + '.ini';

  if not N_CMV_SLToFile( StringList, DuerrIniFile ) then
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'Ini File can not be written: ' + DuerrIniFile );

    if ( nil <> StringList ) then
      StringList.Free;

    Exit;
  end; // if not N_CMV_SLToFile( StringList, DuerrIniFile ) then

  StringList.Free;

  DuerrState := dsWaitRunFile;
  // try to start VistaEasy if it is not running
  StartVista();

  if ( dsFree = DuerrState ) then // if Vista Easy not started
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'Vista Easy is not installed. ' +
                             'Please close Centaur Media Suite and install ' +
                             'Duerr Vista Easy. Press OK to continue' );
    Exit;
  end; // if ( dsFree = DuerrState ) then // if Vista Easy not started

  N_Dump1Str( 'Duerr >> VistaEasy successfully started' );
  DuerrTimer.Enabled := True;

end; // procedure TN_CMCDServObj6.OnTimerStartCapture

//************************************** TN_CMCDServObj6.OnTimerWaitRunFile ***
// Timer event for 2nd step - wait for running file
//
procedure TN_CMCDServObj6.OnTimerWaitRunFile();
var
  ResCode: TDuerrRunFile;
begin

  if DuerrWaitFileStarted then
  begin
    ResCode := CheckRunFile();

    if ( ResCode = rfWait ) then
    begin
      DuerrTimer.Enabled := True;
      Exit;
    end;

    if ( ResCode = rfFail ) then
    begin
      N_CMV_ShowCriticalError( 'Duerr', 'File "running.dat" not found' );
      UnlockCMS(); // Unlock CMS Interface
      Exit;
    end;

  end; // if DuerrWaitFileStarted then

  N_Dump1Str( 'Duerr >> start to wait file "Stat' + DuerrFileNum + '.txt"' );
  DuerrState   := dsWaitStatusFile;
  DuerrAttempt := 0;
  DuerrTimer.Enabled := True;
end; // procedure TN_CMCDServObj6.OnTimerWaitRunFile

//*********************************** TN_CMCDServObj6.OnTimerWaitStatusFile ***
// Timer event for 3rd step - wait for status file
//
procedure TN_CMCDServObj6.OnTimerWaitStatusFile();
var
  FileName: String;
begin
  FileName := GetDuerrPath( DUERR_PATH_JOB ) + '\Stat' + DuerrFileNum + '.txt'; // status file name

  if K_CMD4WAppFinState then
  begin
    N_Dump1Str( 'Duerr >> K_CMD4WAppFinState' );
    UnlockCMS();
    Exit;
  end; // if K_CMD4WAppFinState then

  if FileExists( FileName ) then
  begin
    N_Dump1Str( 'Duerr >> file "Stat' + DuerrFileNum + '.txt" found' );
    DuerrState := dsFinishCapture;
    DuerrAttempt := 0;
    DuerrTimer.Enabled := True;
    Exit;
  end; // if FileExists( FileName ) then

  if ( DuerrAttempt > 20 ) then
  begin
    DuerrAttempt := 0;
    N_Dump2Str( 'Duerr >> Wating for ' + FileName );
  end; // if ( DuerrAttempt > 20 ) then

  DuerrTimer.Enabled := True;
end; // procedure TN_CMCDServObj6.OnTimerWaitStatusFile

//************************************ TN_CMCDServObj6.OnTimerFinishCapture ***
// Timer event for 4th step - wait for eventid = 5 in status file, finish capture
//
procedure TN_CMCDServObj6.OnTimerFinishCapture();
var
  FileName: String;
begin
  FileName := GetDuerrPath( DUERR_PATH_JOB ) + '\Stat' + DuerrFileNum + '.txt'; // status file name

  if K_CMD4WAppFinState then
  begin
    N_Dump1Str( 'Duerr >> K_CMD4WAppFinState' );
    UnlockCMS(); // Unlock CMS Interface
    Exit;
  end; // if K_CMD4WAppFinState then

  if CheckClose( FileName ) then
  begin
    N_Dump1Str( 'Duerr >> check_close' );
    NotFoundAlreadyReported := False;
    // Scan Duerr Images directory for PNG files and process each file
    K_ScanFilesTree( GetDuerrPath( DUERR_PATH_IMAGE ) + '\',
                     CreateSlideFromFile, '*.png' );
    N_Dump2Str( 'TN_CMCDServObj6.OnTimerFinishCapture 1' );
    DuerrDeleteFiles();
    N_Dump2Str( 'TN_CMCDServObj6.OnTimerFinishCapture 2' );
    DuerrAttempt := 0;
    UnlockCMS(); // Unlock CMS Interface
    N_Dump2Str( 'TN_CMCDServObj6.OnTimerFinishCapture 3' );
    Exit;
  end; // if CheckClose( FileName ) then

  if ( DuerrAttempt > 20 ) then
  begin
    DuerrAttempt := 0;
    N_Dump2Str( 'Duerr >> Wating for check_close' );
  end; // if ( DuerrAttempt > 20 ) then

  DuerrTimer.Enabled := True;
  N_Dump2Str( 'TN_CMCDServObj6.OnTimerFinishCapture 4' );
end; // procedure TN_CMCDServObj6.OnFinishCapture

//******************************************** TN_CMCDServObj6.DuerrOnTimer ***
// Timer events
//
//    Parameters
// ASender - Timer Object
//
procedure TN_CMCDServObj6.DuerrOnTimer( ASender: TObject );
begin
  DuerrTimer.Enabled := False;

  // call procedure depending on DuerrState
  if ( dsStartCapture = DuerrState ) then
    OnTimerStartCapture()
  else if ( dsWaitRunFile = DuerrState ) then
    OnTimerWaitRunFile()
  else if ( dsWaitStatusFile = DuerrState ) then
    OnTimerWaitStatusFile()
  else if ( dsFinishCapture = DuerrState ) then
    OnTimerFinishCapture();

end; // procedure TN_CMCDServObj6.DuerrOnTimer

//**************************************** TN_CMCDServObj6.DuerrDeleteFiles ***
// Delete Duerr status file and images for current session
//
procedure TN_CMCDServObj6.DuerrDeleteFiles();
var
  ImagesList:   TStringList;
  StatFileName, pref, s: String;
  i, cnt, StrLen, PrefLen: Integer;
begin
  StatFileName := GetDuerrPath( DUERR_PATH_JOB ) + '\Stat' + DuerrFileNum + '.txt';
  pref := 'ImageFilePath=';
  PrefLen := Length( pref );

  if not FileExists( StatFileName ) then
    Exit;

  ImagesList := TStringList.Create;

  if ( nil = ImagesList ) then
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'DuerrDeleteFiles ImagesList = NULL' );
    Exit;
  end; // if ( nil = ImagesList ) then

  ImagesList.Clear;

  if not N_CMV_FileToSL( ImagesList, StatFileName ) then
  begin
    N_CMV_ShowCriticalError( 'Duerr', 'DuerrDeleteFiles ImagesList not loaded from file: ' + StatFileName );

    if ( nil <> ImagesList ) then
      ImagesList.Free;

    Exit;
  end; // if not N_CMV_FileToSL( ImagesList, StatFileName ) then

  K_DeleteFile( StatFileName );
  cnt := ImagesList.Count;

  for i := 0 to cnt - 1 do
  begin
    s := ImagesList[i];
    StrLen := Length( s );

    if ( StrLen > PrefLen + 4 ) then
    begin

      if ( 'ImageFilePath=' = Copy( s, 1, PrefLen ) ) then
      begin
        s := Copy( s, 1 + PrefLen, StrLen - ( PrefLen + 4 ) );
        k_DeleteFile( s + '.xyz' );
        k_DeleteFile( s + '.bmp' );
        k_DeleteFile( s + '.png' );
        k_DeleteFile( s + '.txt' );
        k_DeleteFile( s + '.dat' );
      end; // if ( 'ImageFilePath=' = Copy( s, 1, PrefLen ) ) then

    end; // if ( StrLen > PrefLen + 4 ) then

  end; // for i := 0 to cnt - 1 do

  if ( nil <> ImagesList ) then
    ImagesList.Free;

end; // procedure TN_CMCDServObj6.DuerrDeleteFiles

//********************************* TN_CMCDServObj6.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj6.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 30;
end; // function TN_CMCDServObj6.CDSGetDefaultDevIconInd

//********************************** TN_CMCDServObj6.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj6.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
    Result := 'CR';
end; // function TN_CMCDServObj6.CDSGetDefaultDevDCMMod


Initialization
  // Create and Register Duerr Service Object
  DuerrRegisteredDevice := TN_CMCDServObj6.Create( N_CMECD_Duerr_Name );
  DuerrServObj := K_CMCDRegisterDeviceObj( DuerrRegisteredDevice );
  DuerrServObj.IsGroup         := True;
  DuerrServObj.NotModalCapture := True;
  DuerrServObj.ShowSettingsDlg := True;
  DuerrServObj.CDSCaption      := 'Duerr Dental';

  with DuerrRegisteredDevice do // Initialize Duerr Device Object
  begin
    ImageIdentifier         := '';
    DuerrAttempt            := 0;
    DuerrState              := dsFree;
    DuerrWaitFileStarted    := False;
    DuerrTimer              := TTimer.Create( application );
    DuerrTimer.Enabled      := False;
    DuerrTimer.Interval     := 500;
    DuerrTimer.OnTimer      := DuerrOnTimer;
    DuerrFileNum            := '00001';
    NotFoundAlreadyReported := False;
  end; // with DuerrRegisteredDevice do // Initialize Duerr Device Object

end.
