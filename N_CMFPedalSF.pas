unit N_CMFPedalSF;
// Foot Pedal Setup Form and
// N_FPCBObj Global Object (for Foot Pedals, Camera Buttons and Dental Units)

// 30.07.2014 - also for N_CMVideo3F - QI Optic Camera Button added
// 01.08.2014 - also for N_CMVideo3F, N_CMRes - added N_FlagForm to know which video capture form is used
// 16.07.2015 - Dental Unit code updated
// 17.03.2017 - siucom added
// 29.01.2018 - added second exe file to siucom
// 13.02.2018 - closing opened siucom after restart added
// 05.09.2018 - acteon sopro device added
// 25.09.2018 - mediacam pro added
// 06.04.2021 - du sirona capture modes added

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,
  N_Types, N_Lib1, N_BaseF, mmSystem, USBCam20SDK_TLB, ActiveX;

type TN_CMFPedalSetupForm = class( TN_BaseForm )
    bnCancel: TButton;
    bnOK: TButton;
    cbFootPedals: TComboBox;
    Label1: TLabel;
    cbReverseLR: TCheckBox;
    edComPortNum: TLabeledEdit;

    procedure FormShow       ( Sender: TObject );
    procedure FormCloseQuery ( Sender: TObject; var CanClose: Boolean);
    procedure FormClose      ( Sender: TObject; var Action: TCloseAction ); override;
    procedure cbFootPedalsCloseUp ( Sender: TObject );
  public
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
end; // type TN_CMFPedalSetupForm = class( TN_BaseForm )

const
  //******** FPCB (Foot Pedals, Camera Buttons and Dental Units) device Indexes:
  N_FPCB_None          =  0;
  N_FPCB_TestDevice1   =  1;
  N_FPCB_TestDevice2   =  2;
  N_FPCB_KeyboardF5F6  =  3; // Foot Pedal simulator by F5 F6 keys
  N_FPCB_KeyboardF7F8  =  4; // Foot Pedal simulator by F7 F8 keys
  N_FPCB_Delcom        =  5; // Foot Pedal Delcom
  N_FPCB_Serial        =  6; // Foot Pedal Serial
  N_FPCB_SoproTouch    =  7; // Camera Button Sopro Touch
  N_FPCB_SchickUSB     =  8; // Camera Button Schick USB Cam2
  N_FPCB_SchickUSBCam4 =  9; // Camera Button Schick USB Cam4
  N_FPCB_Winus100D     = 10; // Camera Button Win-100D
  N_FPCB_Win100DBDA    = 11; // Camera Button Win-100D-BDA
  N_FPCB_USBPedal      = 12; // Foot Pedal USB
  N_FPCB_MultiCam      = 13; // Camera Button MultiCam
  N_FPCB_DUPCS         = 14; // Dental Unit Planmeca Compact Serial
  N_FPCB_Keystrokes    = 15; // Camera button Keystrokes (only Name without any code is needed)
  N_FPCB_QI            = 16; // Camera Button QI Optic
  N_FPCB_DUSirona      = 17; // Dental Unit Sirona
  N_FPCB_MediaCamPlus  = 18; // Camera Button MediaCam+
  N_FPCB_DUSiUCOM      = 19; // Dental Unit SiUCOM
  N_FPCB_ActeonSopro   = 20; // Acteon Sopro
  N_FPCB_MediaCamPro   = 21; // MediaCam Pro

  N_FPCB_NumDevices    = 22; // Whole Number of FPCB Devices (Length of FPCBDevices array)

  //***** Dental Unit Planmeca Compact Serial constants:
	N_eSAVE_AND_UNFREEZE_PICTURE      = 1; // N_DU_SAVE_AND_UNFREEZE
	N_eFREEZE_UNFREEZE_PICTURE_TOGGLE = 2; // N_DU_FREEZE_UNFREEZE_TOGGLE
	N_eCAMERA_TAKEN                   = 3; // N_DU_CAMERA_TAKEN
	N_eCAMERA_RETURNED                = 4; // N_DU_CAMERA_RETURNED

  //***** Dental Unit Sirona constants:
  N_DEVICE_STATE_IS_ACTIVATED_TRUE		      =  0;
  N_DEVICE_STATE_IS_ACTIVATED_FALSE	        =  1;
  N_DEVICE_STATE_FOOTCTRL_SAVEPICTURE	      =  2; // N_DU_SAVE_AND_UNFREEZE
  N_DEVICE_STATE_FOOTCTRL_TOGGLEPICTURE	    =  3;
  N_DEVICE_STATE_FOOTCTRL_TOGGLEVIDEOSTREAM	=  4; // N_DU_FREEZE_UNFREEZE_TOGGLE
  N_DEVICE_STATE_ERROR_ACTIVATING_CAMERA	  =  7;
  N_DEVICE_STATE_ERROR_DEACTIVATING_CAMERA	=  8;
  N_DEVICE_STATE_IS_PICKED_UP_TRUE	        = 13; // N_DU_CAMERA_TAKEN
  N_DEVICE_STATE_IS_PICKED_UP_FALSE         = 14; // N_DU_CAMERA_RETURNED

  //***** All Dental Units constants:
	N_DU_NOTHING_TODO           = 0; // Nothing todo
	N_DU_SAVE_AND_UNFREEZE      = 1; // Save Picture and unfreeze video
	N_DU_FREEZE_UNFREEZE_TOGGLE = 2; // Toggle freeze/unfreeze mode
	N_DU_CAMERA_TAKEN           = 3; // Start using camera (Open VideoForm)
	N_DU_CAMERA_RETURNED        = 4; // Finish using camera (Close VideoForm)


type TN_FPCBDevice = record //***** One FPCB Device related data
  FPCBName:      string;  // Name for User interface (for showing in FPCB Devices List)
  FPCBDllFName:  string;  // DLL File Name
  FPCBDllHandle: HMODULE; // DLL Windows Handle
  FPCBPrevState: integer; // Previous Device keys State
  FPCBReverse:   boolean; // Device keys should be Reversed
  FPCBWideDriverName: WideString; // Device Driver Name (needed for SoproTouch and Winus Camera buttons)
  FPCBSavedCPUCounter:     int64; // is needed for Sopro Touch Camera Button
  FPCBUSBPedal:         TJoyInfo; // data needed for USB Pedal (USB JoyStick)
  FPCBQILoadFlag:        Boolean; // is needed for QI Optic
  FPCBQIThreshold:       Integer; // is needed for QI Optic
end; //*** end of type TN_FPCBDevice = record // One FPCB Device related data
type TN_FPCBDevices = array of TN_FPCBDevice;


type TN_FPCBObj = class( TObject ) // FPCB Devices Global Object
  public
  FPCBDevices: TN_FPCBDevices; // Array of FPCB Devices Params
  FPCBErrorStr:   string;      // Error message

  //***** Dental Unit related fields
  FPCBDUInd:         integer;  // Dental Unit Device Index
  FPCBDUProfName:     string;  // Profile Name, controlled by FPCBDUInd
  FPCBDUCOMPort:     integer;  // Dental Unit COM Port Number
  FPCBDUUseKeyboard: Boolean;  // Use keyboard to emulate Dental Unit commands
                               // ("1"-Save, "2"-Toggle, "3"-Start, "4"-Finish)
  FPCBDUActivateMode: Integer;  // 0 - old var (actvate in FPCBInitDU), 1 - new var (actvate in Device FormShow)
  FPCBDUCloseMode:    Integer;  // 0 - old var (close by N_DU_CAMERA_RETURNED), 1 - new var (ignore N_DU_CAMERA_RETURNED)

  FPCBDUGetStateDumpCounter: Integer; // for debug ?
  FPCBDUCameraTaken: Boolean;  // True if Dental Unit camera was taken ( to prevent calling FPCBGetDUState from FPCBIfDUCameraTaken (in K_CM0 timer) )

  //***** Foot Pedal Devices functions
  FPCBDelcomIsButtonPressed:  TN_cdeclIntFuncVoid;      // DelcomDllInterface.dll   IsButtonPressed function
  FPCBSerialOpenSerialPort:   TN_cdeclIntFuncPWCharInt; // SerialPedalInterface.dll OpenSerialPort function
  FPCBSerialCloseSerialPort:  TN_cdeclIntFuncVoid;      // SerialPedalInterface.dll CloseSerialPort function
  FPCBSerialGetPedalsStates:  TN_cdeclIntFuncPIntInt;   // SerialPedalInterface.dll GetPedalsStates function
  FPCBOpenLogFile:            TN_cdeclIntFunc2PAChar1Int; // SerialPedalInterface.dll OpenLogFile function
  FPCBCloseLogFile:           TN_cdeclProcVoid;         // SerialPedalInterface.dll CloseLogFile procedure
  FPCBThrowException:         TN_cdeclProcInt;          // SerialPedalInterface.dll ThrowException procedure

  //***** Camera Button Devices functions
  FPCBSoproTouchIsButtonPressed:    TN_cdeclIntFuncPWChar;  // SoproTouchDLLInterface.dll IsButtonPressed function
  FPCBSchickUSBIsButtonPressed:     TN_cdeclIntFuncVoid;    // SchickDllInterface.dll IsButtonPressed function
  FPCBWinus100DIsButtonPressed:     TN_cdeclIntFuncPWChar;  // WinusDllInterface.dll IsButtonPressed function
  FPCBWinus100DBDAIsButtonPressed:  TN_cdeclIntFuncPWChar;  // WinusDllInterface_BDA.dll IsButtonPressed function

  //***** MultiCam button functions
  FPCBMultiCamOpenLogFile:      TN_cdeclIntFuncPAChar3Int; // EzRegIoInterface.dll OpenLogFile function
  FPCBMultiCamWasButtonPressed: TN_cdeclIntFuncVoid;       // EzRegIoInterface.dll WasButtonPressed function
  FPCBMultiCamResetButtonState: TN_cdeclIntFuncVoid;       // EzRegIoInterface.dll ResetButtonState function
  FPCBMultiCamReleaseButton:    TN_cdeclIntFuncVoid;       // EzRegIoInterface.dll ReleaseButton function

  //***** Planmeca Compact Serial Dental Unit functions
  FPCBPCSOpenLogFile:           TN_cdeclIntFuncPAChar3Int; // ComPortInterface.dll OpenLogFile function
  FPCBPCSOpenSerialPort:        TN_cdeclIntFuncInt;        // ComPortInterface.dll OpenSerialPort function
  FPCBPCSGetState:              TN_cdeclIntFuncInt;        // ComPortInterface.dll GetLastMessageFromSerialPort function

  //***** Sirona Dental Unit functions
  FPCBSironaStartOrFindServer:       TN_cdeclIntFuncVoid;       // SiucomInterface.dll StartOrFindServer function
  FPCBSironaConnectToServer:         TN_cdeclIntFuncVoid;       // SiucomInterface.dll ConnectToServer function
  FPCBSironaDisconnectFromServer:    TN_cdeclIntFuncVoid;       // SiucomInterface.dll DisconnectFromServer function
  FPCBSironaStopServer:              TN_cdeclIntFuncVoid;       // SiucomInterface.dll StopServer function
  FPCBSironaGetDeviceStateInMapView: TN_cdeclIntFuncInt;        // SiucomInterface.dll GetDeviceStateInMapView function
  FPCBSironaActivateCamera:          TN_cdeclProcInt;           // SiucomInterface.dll ActivateCamera function
  FPCBSironaOpenLogFile:             TN_cdeclIntFuncPAChar3Int; // SiucomInterface.dll OpenLogFile function

  //***** QI functions
  FPCBQIStartOrFindServer:                TN_cdeclDWordFuncVoid;
  FPCBQIStopServer:                       TN_cdeclIntFuncVoid;
  FPCBQIReadLastRawInputEvent:            TN_cdeclIntFuncVoid;
  FPCBQIConnectToServer:                  TN_cdeclDWordFuncVoid;
  FPCBQIResetServerStatusData:            TN_cdeclIntFuncVoid;
  FPCBQISetReleaseButtonThreshold:        TN_cdeclProcInt;
  FPCBQIRegisterButton:                   TN_cdeclProc3WordAnsiChar;
  FPCBQIDisconnectFromServer:             TN_cdeclDWordFuncVoid;
  FPCBQIRegisterRawInputDeviceIsFinished: TN_cdeclIntFuncVoid;
  FPCBQIGetRegisterRawInputDeviceResult:  TN_cdeclIntFuncVoid;
  FPCBQIOpenLogFile:                      TN_cdeclIntFuncPAChar3Int;

  //***** MediaCamPlus functions
  FPCBMediaCamSendExtensionUnitCommand:   TN_cdecl4IntFuncInt;

  //***** Acteon Sopro functions
  FPCBSoproTouch:                         TN_cdeclIntFuncAStr;

  //***** MediaCamPro variables
  //FPCBMediaCamProIsButtonPressed:         TN_stdcallIntFuncVoid;
  FPCBMediaCamPrevState: Integer;

  SiucomButtonLastState: Char;
  SiucomLastState: Char;

  constructor Create ();
  destructor  Destroy; override;
  procedure   OnCommand      ( var Msg: TMessage ); message WM_USER + 7;

  function  FPCBBadInd       ( AFPCBInd: integer ): boolean;
  function  FPCBLoadDLL      ( AFPCBInd: integer ): integer;
  procedure FPCBUnloadDLL    ( AFPCBInd: integer );
  function  FPCBGetFPCBState ( AFPCBInd: integer; out ACurState, APrevState: integer ): integer;
  procedure FPCBInitDU          ();
  function  FPCBGetDUState      (): integer;
  function  FPCBIfDUCameraTaken (): Boolean;


end; // type TN_FPCBObj = class( TObject ) // FPCB Devices Global Object


    //*********** Global Procedures  *****************************

function  N_CMConvCBToFPCBInd  ( ACBInd: integer ): integer;
procedure N_CMDecodeFPCBStates ( ACurState, APrevState: integer;
                                 out Pressed1, Released1, Pressed2, Released2: boolean );
function  N_CMSetFootPedal    (): Boolean;
procedure N_CMOpenFPCBLogFile ( ADevInd: integer );

var
  N_FPCBObj: TN_FPCBObj; // Global object for working with FPCB Devices
  N_SchickUSBCam4Camera: ICamera; // Object needed for Schick USB Cam4 Button
  N_FlagForm: Integer; // 0 - Video2F, 1 - Video3F, 2 - Video4F


implementation
uses
  IniFiles,
  K_CLib0, K_CM0,
  N_Lib0, N_CM1, N_CML2F, N_CMVideo4F, N_CMCaptDev0, Tlhelp32, ShellAPI;
{$R *.dfm}
{$OPTIMIZATION OFF}

//**************************************************************** KillTask ***
// Closes an app by exe name
//
//     Parameters
// ExeFileName - exe name
// Result      - if success
//
function KillTask( ExeFileName: string ): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
  FProcessEntry32.dwSize := Sizeof( FProcessEntry32 );
  ContinueLoop := Process32First( FSnapshotHandle, FProcessEntry32 );
  while integer( ContinueLoop ) <> 0 do
  begin
  if (StrIComp(PChar(ExtractFileName(FProcessEntry32.szExeFile)),
                PChar(ExeFileName)) = 0) or (StrIComp(FProcessEntry32.szExeFile,
                                                  PChar(ExeFileName)) = 0)  then
    Result := Integer( TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),
                                           FProcessEntry32.th32ProcessID), 0) );
    ContinueLoop := Process32Next( FSnapshotHandle, FProcessEntry32 );
  end;
  CloseHandle( FSnapshotHandle );
end; // function KillTask( ExeFileName: string )

//****************  TN_CMFPedalSetupForm class handlers  ******************

//******************************************* TN_CMFPedalSetupForm.FormShow ***
// Initialize cbFootPedals.ItemIndex
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMFPedalSetupForm.FormShow( Sender: TObject );
begin
  inherited;
  //***** Not used, may be removed
end; // procedure TN_CMFPedalSetupForm.FormShow

//****************************************** TN_CMFPedalSetupForm.FormClose ***
// Save cbFootPedals.ItemIndex
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TN_CMFPedalSetupForm.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  Inherited;
  //***** Not used, may be removed
end; // procedure TN_CMFPedalSetupForm.FormClose

//************************************* TN_CMFPedalSetupForm.FormCloseQuery ***
// Check if Self can be closed (if COM Port number is OK
// (is empty or in 1-127 range)
//
//     Parameters
// Sender   - Event Sender
// CanClose - should be set to True if Self can be closed now
//
// OnCloseQuery Self handler
//
procedure TN_CMFPedalSetupForm.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
var
  PortNumber, CurFPCBInd, ResCode, DebLocalInt: integer; // , ExceptionType
  Str: string;
begin
  inherited;

  CanClose := True;

  if ModalResult = mrCancel then Exit; // do not save any changes

  CurFPCBInd := N_GetComboBoxObjInt( cbFootPedals );

  if CurFPCBInd <> N_FPCB_Serial then Exit; // NOT Serial foot pedal

  //***** Here: Check that edComPortNum.Text has proper value

  Str := Trim(edComPortNum.Text);
  if Str = '' then Exit; // edComPortNum.Text is OK (Using of COM Port is not needed)

  PortNumber := N_ScanInteger( Str );
  N_IntToMemIni( 'CMS_Main', 'FootPedalCOMPortMode', 0 ); // normal mode
{
  if (PortNumber >= 200) and (PortNumber <= 202)  then // Throw Exception in dll
  begin
    N_IntToMemIni( 'CMS_Main', 'FootPedalCOMPortMode', 1 ); // skip opening COM Port
    N_StringToMemIni( 'CMS_Main', 'FootPedalCOMPort', '1' );

    N_FPCBObj.FPCBLoadDLL( N_FPCB_Serial ); // Load DLL
    ExceptionType := PortNumber - 200;
    N_Dump1Str( Format( 'Before Exception Type=%d', [ExceptionType] ));
    N_FPCBObj.FPCBThrowException( ExceptionType );
    N_Dump1Str( Format( 'After Exception Type=%d', [ExceptionType] ));
    Exit;
  end; // if ... then // Throw Exception in dll

  if PortNumber = 300 then // skip opening COM Port
  begin
    N_IntToMemIni( 'CMS_Main', 'FootPedalCOMPortMode', 1 );
    PortNumber := 1;
  end; // if PortNumber = 300 then // skip opening COM Port

  if PortNumber = 301 then // emulate opening COM Port error
  begin
    N_IntToMemIni( 'CMS_Main', 'FootPedalCOMPortMode', 2 );
    PortNumber := 1;
  end; // if PortNumber = 301 then // emulate opening COM Port error
}

  if (PortNumber < 1) or (PortNumber > 127) then // Wrong COM Port Number
  begin
    // LLLWrongPortNum_c = 'You entered a wrong serial port number. It should be between 1 and 127. Press OK to enter the correct serial port number.'
    K_CMShowMessageDlg( N_CML2Form.LLLWrongPortNum.Caption, mtError );
    CanClose := False;
    Exit;
  end; // if (PortNumber < 1) or (PortNumber > 127) then // Wrong COM Port Number

  //*** Try to open given COM Port
  N_StringToMemIni( 'CMS_Main', 'FootPedalCOMPort', IntToStr(PortNumber) );
  DebLocalInt := 123456;

  N_Dump1Str( Format( 'before FPCBLoadDLL port COM%d, DebLocalInt=%d', [PortNumber,DebLocalInt] ));
  ResCode := N_FPCBObj.FPCBLoadDLL( N_FPCB_Serial ); // Load DLL and Open COM Port
  N_Dump1Str( Format( 'after FPCBLoadDLL port COM%d, DebLocalInt=%d', [PortNumber,DebLocalInt] ));

  if ResCode <> 0 then // loading or Initializing error
  begin
    // LLLCOMPortError1_c = 'Failed to initialise serial port COM%d. Please check your hardware.'
    K_CMShowMessageDlg( Format( N_CML2Form.LLLCOMPortError1.Caption, [PortNumber] ), mtError );
    CanClose := False;
    Exit;
  end else // ResCode = 0, COM Port opened OK. Close it.
    N_FPCBObj.FPCBUnloadDLL( N_FPCB_Serial );

  //***** Here: All is OK, Form can be closed

end; // procedure TN_CMFPedalSetupForm.FormCloseQuery

//******************************** TN_CMFPedalSetupForm.cbFootPedalsCloseUp ***
// Enable or Disable cbReverseLR and edComPortNum controls
//
//     Parameters
// Sender - Event Sender
//
// OnCloseUp cbFootPedals handler
//
procedure TN_CMFPedalSetupForm.cbFootPedalsCloseUp( Sender: TObject );
var
  CurFPCBInd: integer;
begin
  inherited;

  CurFPCBInd := N_GetComboBoxObjInt( cbFootPedals );

  //***** Set prpoer Reverse CheckBox Name

  if (CurFPCBInd = N_FPCB_USBPedal) then
    cbReverseLR.Caption := N_CML2Form.LLLReverseAB.Caption // Reverse A/B
  else
    cbReverseLR.Caption := N_CML2Form.LLLReverseLR.Caption; // Reverse Left/Right

  if (CurFPCBInd = N_FPCB_Serial) or
     (CurFPCBInd = N_FPCB_KeyboardF5F6) or
     (CurFPCBInd = N_FPCB_USBPedal) then // Enable cbReverseLR
     begin
       cbReverseLR.Enabled := True;
     end
  else
    cbReverseLR.Enabled := False;

  if CurFPCBInd = N_FPCB_Serial then // Enable edComPortNum
    edComPortNum.Enabled := True
  else
    edComPortNum.Enabled := False;

end; // procedure TN_CMFPedalSetupForm.cbFootPedalsCloseUp

//*********************************** TN_CMFPedalSetupForm.CurStateToMemIni ***
// Save Current Self State
//
procedure TN_CMFPedalSetupForm.CurStateToMemIni();
var
  FootPedalInd: integer;
begin
  Inherited;

  if ModalResult <> mrOK then Exit; // do not save any changes in N_CurMemIni

  FootPedalInd := N_GetComboBoxObjInt( cbFootPedals );

  N_IntToMemIni(  'CMS_Main', 'FootPedalDevInd',  FootPedalInd );
  N_BoolToMemIni( 'CMS_Main', 'FootPedalReverse', cbReverseLR.Checked ); // save always

  if FootPedalInd = N_FPCB_Serial then // Save FootPedalCOMPort
  begin
    N_StringToMemIni( 'CMS_Main', 'FootPedalCOMPort', Trim(edComPortNum.Text) );
    N_Dump1Str( Format( 'Serial Foot Pedal was choosen, Port=%s, Reverse=%s',
                             [edComPortNum.Text, N_B2S(cbReverseLR.Checked)] ));
  end else // FootPedalInd <> N_FPCB_Serial, all done already, just add Dump String
    N_Dump1Str( Format( ' %s was choosen, Reverse=%s',
                             [N_FPCBObj.FPCBDevices[FootPedalInd].FPCBName,
                              N_B2S(cbReverseLR.Checked)] ));

end; // end of procedure TN_CMFPedalSetupForm.CurStateToMemIni

//*********************************** TN_CMFPedalSetupForm.MemIniToCurState ***
// Load Current Self State
//
procedure TN_CMFPedalSetupForm.MemIniToCurState();
var
  cbInd, SavedFPCBInd, SavedOldInd: integer;

  procedure AddFootPedal( AFPCBInd: integer ); // local
  begin
    with N_FPCBObj.FPCBDevices[AFPCBInd] do
    begin
      cbInd := cbFootPedals.Items.Add( FPCBName );  // AFPCBInd-th Device Name
      cbFootPedals.Items.Objects[cbInd] := TObject(AFPCBInd); // index in FPCBDevices array

      if AFPCBInd = SavedFPCBInd then // Set Item Index
        cbFootPedals.ItemIndex := cbInd;
    end; // with N_FPCBObj.FPCBDevices[AFPCBInd] do
  end; // procedure AddFootPedal - local

begin //***************** main body of TN_CMFPedalSetupForm.MemIniToCurState
  Inherited;

  SavedFPCBInd := N_MemIniToInt( 'CMS_Main', 'FootPedalDevInd', -1 );

  if SavedFPCBInd = -1 then // check if old ComboBox (not Device) index was saved
  begin                     // (for compatability with 2.790 and earlier CMS Builds)
    SavedOldInd := N_MemIniToInt( 'CMS_Main', 'FootPedalIndex', 0 );

    if SavedOldInd = 1 then SavedFPCBInd := N_FPCB_Delcom
                       else SavedFPCBInd := N_FPCB_None;
  end; // if SavedFPCBInd = -1 then // check if old ComboBox index was saved

  AddFootPedal( N_FPCB_None );
  AddFootPedal( N_FPCB_Delcom );
  AddFootPedal( N_FPCB_Serial );
  AddFootPedal( N_FPCB_KeyboardF5F6 );
  AddFootPedal( N_FPCB_USBPedal );

  if cbFootPedals.ItemIndex = -1 then
    cbFootPedals.ItemIndex := 0;

  cbReverseLR.Checked := N_MemIniToBool( 'CMS_Main', 'FootPedalReverse', False );
  edComPortNum.Text := N_MemIniToString( 'CMS_Main', 'FootPedalCOMPort', '' );

  if Length(edComPortNum.Text) > 0 then
  begin
    if edComPortNum.Text[1] <> ' ' then // Add leading space (for looking nicer)
      edComPortNum.Text := ' ' + edComPortNum.Text;
  end;

  cbFootPedalsCloseUp( nil ); // Set cbReverseLR and edComPortNum controls state
end; // end of procedure TN_CMFPedalSetupForm.MemIniToCurState


//****************** TN_FPCBObj class methods  **********************

//******************************************************* TN_FPCBObj.Create ***
// Create TN_FPCBObj Obj and fill FPCBDevices Array by all devices
//
constructor TN_FPCBObj.Create;
begin
  SetLength( FPCBDevices, N_FPCB_NumDevices );

  with FPCBDevices[N_FPCB_None] do begin
    FPCBName      := N_CML2Form.LLLNone.Caption; // None (not choosen)
    FPCBDllFName  := ''; // not needed
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_None] do begin

  with FPCBDevices[N_FPCB_TestDevice1] do begin
    FPCBName      := N_CML2Form.LLLVirtualDevice1.Caption; // 'Virtual Device 1';
    FPCBDllFName  := ''; // not needed
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_TestDevice1] do begin

  with FPCBDevices[N_FPCB_TestDevice2] do begin
    FPCBName      := N_CML2Form.LLLVirtualDevice2.Caption; // 'Virtual Device 2';
    FPCBDllFName  := ''; // not needed
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_TestDevice2] do begin

  with FPCBDevices[N_FPCB_KeyboardF5F6] do begin
    FPCBName      := N_CML2Form.LLLKeyboardF5F6.Caption; // Keyboard F5,F6 foot pedal
    FPCBDllFName  := ''; // not needed
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_KeyboardF5F6] do begin

  with FPCBDevices[N_FPCB_KeyboardF7F8] do begin
    FPCBName      := N_CML2Form.LLLKeyboardF7F8.Caption; // Keyboard F7,F8 foot pedal
    FPCBDllFName  := ''; // not needed
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_KeyboardF7F8] do begin

  with FPCBDevices[N_FPCB_Delcom] do begin //
    FPCBName      := N_CML2Form.LLLDelcomfootpedal.Caption; // Delcom foot pedal
    FPCBDllFName  := 'DelcomDllInterface.dll'; // not needed
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_Delcom] do begin

  with FPCBDevices[N_FPCB_Serial] do begin //
    FPCBName      := N_CML2Form.LLLSerialFootPedal.Caption; // Serial foot pedal
    FPCBDllFName  := 'SerialPedalInterface.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_Serial] do begin

  with FPCBDevices[N_FPCB_SoproTouch] do begin //
    FPCBName      := N_CML2Form.LLLSoproTouch.Caption; // Sopro Touch Camera Button
    FPCBDllFName  := 'SoproTouchDLLInterface.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_SoproTouch] do begin

  with FPCBDevices[N_FPCB_SchickUSB] do begin //
    FPCBName      := N_CML2Form.LLLSchickUSBCam2.Caption; // Schick USB Cam2 Camera Button
    FPCBDllFName  := 'SchickDLLInterface.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_SchickUSB] do begin

   with FPCBDevices[N_FPCB_SchickUSBCam4] do begin
    FPCBName      := N_CML2Form.LLLSchickUSBCam4.Caption; // Schick USB Cam4 Camera Button
    FPCBDllFName  := '';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_SchickUSBCam4] do begin

  with FPCBDevices[N_FPCB_Winus100D] do begin
    FPCBName      := N_CML2Form.LLLWin100D.Caption; // Win-100D Camera Button
    FPCBDllFName  := 'WinusDllInterface.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_Winus100D] do begin

  with FPCBDevices[N_FPCB_Win100DBDA] do begin
    FPCBName      := N_CML2Form.LLLWin100DBDA.Caption; // Win-100D-BDA  Camera Button
    FPCBDllFName  := 'WinusDllInterface_BDA.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_Win100DBDA] do begin

  with FPCBDevices[N_FPCB_USBPedal] do begin
    FPCBName      := N_CML2Form.LLLUSBPedal.Caption; // USB Foot Pedal (Joystick compatible)
    FPCBDllFName  := '';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_USBPedal] do begin

  with FPCBDevices[N_FPCB_MultiCam] do begin
    FPCBName      := N_CML2Form.LLLMultiCam.Caption; // MultiCam Camera Button
    FPCBDllFName  := 'EzRegIoInterface.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_MultiCam] do begin

  with FPCBDevices[N_FPCB_DUPCS] do begin
    FPCBName      := N_CML2Form.LLLDUPCS.Caption; // Planmeca Compact Serial Dental Unit
    FPCBDllFName  := 'ComPortInterface.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_DUPCS] do begin

  with FPCBDevices[N_FPCB_Keystrokes] do begin
    FPCBName      := N_CML2Form.LLLKeystrokes.Caption; // "Keystrokes" Camera button
    FPCBDllFName  := '';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_Keystrokes] do begin

  with FPCBDevices[N_FPCB_QI] do begin
    FPCBName      := N_CML2Form.LLLQI.Caption; // QI Optic Camera button
    FPCBDllFName  := 'QiOpticInterface.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_QI] do begin

  with FPCBDevices[N_FPCB_DUSirona] do begin
    FPCBName      := N_CML2Form.LLLDUSirona.Caption; // Sirona Dental Unit
    FPCBDllFName  := 'SiucomInterface.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_DUPCS] do begin

  with FPCBDevices[N_FPCB_MediaCamPlus] do begin
    FPCBName      := N_CML2Form.LLLMediaCamPlus.Caption; // MediaCam+  Camera button
    FPCBDllFName  := 'UExProc.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_MediaCamPlus] do begin

  with FPCBDevices[N_FPCB_DUSiUCOM] do begin
    FPCBName      := 'SiUCOM';//N_CML2Form.LLLDUSiUCOM.Caption; //
    FPCBDllFName  := '';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_DUSiUCOM] do begin

  with FPCBDevices[N_FPCB_ActeonSopro] do begin
    FPCBName      := 'Acteon Sopro';
    FPCBDllFName  := 'SoproTouch.dll';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_DUSiUCOM] do begin

  with FPCBDevices[N_FPCB_MediaCamPro] do begin
    FPCBName      := 'MediaCam Pro';
    FPCBDllFName  := '';
    FPCBDllHandle := 0;
  end; // with FPCBDevices[N_FPCB_MediaCamPro] do begin

end; //*** end of Constructor TN_FPCBObj.Create

//****************************************************** TN_FPCBObj.Destroy ***
//
destructor TN_FPCBObj.Destroy;
var
  i: integer;
begin
  for i := 0 to High(FPCBDevices) do
    FPCBUnloadDLL( i );

  Inherited;
end; //*** end of destructor TN_FPCBObj.Destroy

procedure TN_FPCBObj.OnCommand( var Msg: TMessage );
begin
  ShowMessage( IntToStr(Msg.WParam) );
end; // end of procedure TN_FPCBObj.OnCommand

//*************************************************** TN_FPCBObj.FPCBBadInd ***
// Check given AFPCBInd
//
//     Parameters
// AFPCBInd - FPCB Device Index (in FPCBDevices array)
// Result   - Return False if OK, True if AFPCBInd is out of bounds
//
function TN_FPCBObj.FPCBBadInd( AFPCBInd: integer ): boolean;
begin
  if (AFPCBInd < 0) or
     (AFPCBInd > High(FPCBDevices)) then
  begin
    N_Dump1Str( 'Error: Bad FPCB Index = ' + IntToStr(AFPCBInd) );
    Result := True; // Error
    Exit;
  end else
    Result := False; // AFPCBInd is OK
end; // function TN_FPCBObj.FPCBBadInd

//************************************************** TN_FPCBObj.FPCBLoadDLL ***
// Load DLL and inititialize given FPCB (Foot Pedals, Camera Buttons, Dental Units) Device
//
//     Parameters
// AFPCBInd - FPCB Device Index (in FPCBevices array)
// Result   - Return 0 if OK
//
function TN_FPCBObj.FPCBLoadDLL( AFPCBInd: integer ): integer;
var
  i, ResCode, OpenMode, LogMaxSize, LogMaxDays, LogDetails: integer;
  AnsiLogDir, FuncAnsiName, LogFullNameA: AnsiString;
  WideCOMPort: WideString;

  WrkDir, CurDir, Filename, cmd: string;

  procedure ReportError(); // local
  // Report that FuncAnsiName function was not loaded
  begin
    FPCBErrorStr := String(FuncAnsiName) + ' not loaded';
    N_Dump1Str( FPCBErrorStr );
    Result := 1;
  end; // procedure ReportError(); // local

begin //****************** main body of TN_FPCBObj.FPCBLoadDLL
  Result := 1;

  if AFPCBInd = N_FPCB_DUSiUCOM then
  begin
    N_FPCBObj.FPCBInitDU();
  end;

  if AFPCBInd = N_FPCB_MediaCamPro then
  begin
    KillTask( 'MediaCamPro.exe' );
    WrkDir := K_ExpandFileName( '(#TmpFiles#)' );
    CurDir := ExtractFilePath( ParamStr( 0 ) );

    FileName  := CurDir + 'MediaCamPro.exe';
    N_Dump1Str( 'MediaCam Pro >> Exe directory = ' + FileName );

    // wait old driver session closing
    N_CMV_WaitProcess( False, FileName, -1 );

    if not FileExists( FileName ) then // find driver
    begin
      Exit;
    end; // if not FileExists( FileName ) then // find driver

    cmd := WrkDir;
    // start driver executable file with command line parameters
    WinExec( @(N_StringToAnsi('"' + FileName + '" ' + cmd )[1]), SW_HIDE);
  end;

  if FPCBBadInd( AFPCBInd ) then Exit;

  FPCBErrorStr := '';
  Result := 0;

  with FPCBDevices[AFPCBInd] do
  begin
    if FPCBDllHandle <> 0 then Exit; // already loaded, nothing to do

    // Temporary use same Reverse Flag for all FPCB Devices
    FPCBReverse := N_MemIniToBool( 'CMS_Main', 'FootPedalReverse', False );

    if (FPCBDllFName = '') then Exit; // all is OK, DLL is not needed

    //*** Path to DLL files are given in DLLFiles [FileGPaths] string
    //    In TN_CMMain5Form.FormShow this Path was added to Windows Path variable:
    //                N_AddDirToPATHVar( K_ExpandFileName( '(#DLLFiles#)' ) );
    N_Dump2Str( 'Loading FPCB DLL ' + FPCBDllFName );
    FPCBDllHandle := Windows.LoadLibrary( @FPCBDllFName[1 ]);

    if (FPCBDllHandle = 0) and (not(AFPCBInd=8)) then // some error
    begin
      FPCBErrorStr := SysErrorMessage( GetLastError() );
      N_Dump1Str( 'Error Loading ' + FPCBDllFName + ': ' + FPCBErrorStr );
      Result := 1;
      Exit;
    end else // if FPCBDllHandle = 0 then // some error
      FPCBSavedCPUCounter := N_CPUCounter(); // save Load DLL time (used for Sopro Touch Camera Buttons DLL)

    if AFPCBInd = N_FPCB_Delcom then //***** Load Delcom Foot Pedal DLL functions
    begin
      // FPCBDelcomIsButtonPressed

      FuncAnsiName := 'IsButtonPressed';
      FPCBDelcomIsButtonPressed := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBDelcomIsButtonPressed) then ReportError();
    end; // if AFPCBInd = N_FPCB_Delcom then - Load Delcom Foot Pedal DLL functions

    if AFPCBInd = N_FPCB_Serial then //***** Load Serial Foot Pedal DLL functions
    begin
      //  FPCBSerialOpenSerialPort
      //  FPCBSerialCloseSerialPort
      //  FPCBSerialGetPedalsStates

      FuncAnsiName := 'OpenSerialPort';
      FPCBSerialOpenSerialPort := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSerialOpenSerialPort) then ReportError();

      FuncAnsiName := 'CloseSerialPort';
      FPCBSerialCloseSerialPort := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSerialCloseSerialPort) then ReportError();

      FuncAnsiName := 'GetPedalsStates';
      FPCBSerialGetPedalsStates := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSerialGetPedalsStates) then ReportError();

      FuncAnsiName := 'OpenLogFile';
      FPCBOpenLogFile := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBOpenLogFile) then ReportError();

      if Assigned(FPCBOpenLogFile) then // Open Log
      begin
        AnsiLogDir := AnsiString(K_GetDirPath( 'CMSLogFiles' ));
        ResCode := FPCBOpenLogFile( @AnsiLogDir[1], 'SerialFootPedal.txt', 1 );
        if ResCode = 0 then
          N_Dump1Str( 'FPCBOpenLogFile Error - ' + String(AnsiLogDir) );
      end; // if Assigned(FPCBOpenLogFile) then // Open Log

      FuncAnsiName := 'CloseLogFile';
      FPCBCloseLogFile := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBCloseLogFile) then ReportError();

      FuncAnsiName := 'ThrowException';
      FPCBThrowException := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBThrowException) then ReportError();

      if Assigned(FPCBSerialOpenSerialPort) then // Try to Open COM Port
      begin
        OpenMode := N_MemIniToInt( 'CMS_Main', 'FootPedalCOMPortMode', 0 );
        WideCOMPort := N_StringToWide( 'COM' + N_MemIniToString( 'CMS_Main', 'FootPedalCOMPort', '' ) );

        if Length(WideCOMPort) = 3 then // "Empty" COM Port means skip Opening Port
          OpenMode := 1;

        ResCode := $012345;
        N_Dump1Str( Format( 'OpenSerialPort before %s, ResCode=%x, OpenMode=%d',
                                       [WideCOMPort,ResCode,OpenMode] ));
        ResCode := FPCBSerialOpenSerialPort( @WideCOMPort[1], OpenMode );
        N_Dump1Str( Format( 'OpenSerialPort after %s, ResCode=%x, OpenMode=%d',
                                       [WideCOMPort,ResCode,OpenMode] ));

        if ResCode <> 0 then // some OpenSerialPort error
        begin
          FPCBErrorStr := SysErrorMessage( GetLastError() );
          N_Dump1Str( Format( 'Error in SerialPedalInterface.dll OpenSerialPort function (%s, ErrCode=%x)', [FPCBErrorStr,ResCode] ));
//            K_CMShowMessageDlg( Format( 'Failed to initialise serial port %s. Please check your hardware.',
//                                                     [WideCOMPort] ), mtError );
          Result := 2;
        end; // if ResCode <> 0 then // some OpenSerialPort error

      end; // if Assigned(FPCBSerialOpenSerialPort) then // Open COM Port

    end; // if AFPCBInd = N_FPCB_Serial then - Load Serial Foot Pedal DLL functions

    if AFPCBInd = N_FPCB_SoproTouch then //***** Load Sopro Touch Camera Buttons DLL functions
    begin
      // FPCBSoproTouchIsButtonPressed

      FuncAnsiName := 'IsButtonPressed';
      FPCBSoproTouchIsButtonPressed := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSoproTouchIsButtonPressed) then ReportError();
    end; // if AFPCBInd = N_FPCB_SoproTouch then //***** Load Sopro Touch Camera Buttons DLL functions

   if AFPCBInd = N_FPCB_SchickUSB then //***** Load Schick USB Cam2 Camera Buttons DLL functions
    begin
      // FPCBSchickUSBIsButtonPressed

      FuncAnsiName := 'IsButtonPressed';
      FPCBSchickUSBIsButtonPressed := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSchickUSBIsButtonPressed) then
      begin
      N_Dump1Str('Error with IsButtonPressed loading');
      ReportError();
      end;
    end; // if AFPCBInd = N_FPCB_SchickUSB then //***** Load Schick USB Cam2 Camera Buttons DLL functions

    if AFPCBInd = N_FPCB_Winus100D then //***** Load Win-100D Camera Buttons DLL functions
    begin
      // FPCBWinus100DIsButtonPressed

      FuncAnsiName := 'IsButtonPressed';
      FPCBWinus100DIsButtonPressed := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBWinus100DIsButtonPressed) then ReportError();
    end; // if AFPCBInd = N_FPCB_Winus100D then //***** Load Win-100D Camera Buttons DLL functions

    if AFPCBInd = N_FPCB_Win100DBDA then //***** Load Win-100D-BDA Camera Buttons DLL functions
    begin
      // FPCBWinus100DBDAIsButtonPressed

      FuncAnsiName := 'IsButtonPressed';
      FPCBWinus100DBDAIsButtonPressed := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBWinus100DBDAIsButtonPressed) then ReportError();
    end; // if AFPCBInd = N_FPCB_Win100DBDA then //***** Load Win-100D-BDA Camera Buttons DLL functions

    if AFPCBInd = N_FPCB_MultiCam then //***** Load MultiCam button DLL functions
    begin
      // FPCBMultiCamOpenLogFile
      // FPCBMultiCamWasButtonPressed
      // FPCBMultiCamResetButtonState
      // FPCBMultiCamReleaseButton

      FuncAnsiName := 'OpenLogFile';
      FPCBMultiCamOpenLogFile := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBMultiCamOpenLogFile) then ReportError();
      N_CMOpenFPCBLogFile( AFPCBInd );
{
      if Assigned(FPCBMultiCamOpenLogFile) then // Open Log
      begin
        LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'MultiCam.txt' );
        LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
        LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
        LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );
        ResCode := N_FPCBObj.FPCBMultiCamOpenLogFile( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

        if ResCode = 0 then
          N_Dump1Str( 'N_FPCBObj.FPCBMultiCamOpenLogFile Error - ' + String(LogFullNameA) );

      end; // if Assigned(FPCBMultiCamOpenLogFile) then // Open Log
}

      FuncAnsiName := 'WasButtonPressed';
      FPCBMultiCamWasButtonPressed := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBMultiCamWasButtonPressed) then ReportError();

      FuncAnsiName := 'ResetButtonState';
      FPCBMultiCamResetButtonState := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBMultiCamResetButtonState) then ReportError();

      FuncAnsiName := 'ReleaseButton';
      FPCBMultiCamReleaseButton := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBMultiCamReleaseButton) then ReportError();

    end; // if AFPCBInd = N_FPCB_MultiCam then //***** Load MultiCam button DLL functions

    if AFPCBInd = N_FPCB_DUPCS then //***** Load 'Planmeca Compact Serial' Dental Unit DLL functions
    begin
      // FPCBPCSOpenLogFile:    TN_cdeclIntFuncPAChar3Int; // ComPortInterface.dll OpenLogFile function
      // FPCBPCSOpenSerialPort: TN_cdeclIntFuncInt;        // ComPortInterface.dll OpenSerialPort function
      // FPCBPCSGetState:       TN_cdeclIntFuncInt;        // ComPortInterface.dll GetLastMessageFromSerialPort function

      FuncAnsiName := 'OpenLogFile';
      FPCBPCSOpenLogFile := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBPCSOpenLogFile) then ReportError();

      if FPCBDUInd <> 0 then
        N_Dump1Str( '************ DU error, FPCBDUInd <> 0 in FPCBLoadDLL' );

      N_CMOpenFPCBLogFile( AFPCBInd );
{
      if Assigned(FPCBPCSOpenLogFile) then // Open Log
      begin
        LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'PlanmecaCompSerial.txt' );
        LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
        LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
        LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );
        ResCode := N_FPCBObj.FPCBPCSOpenLogFile( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

        if ResCode = 0 then
          N_Dump1Str( 'N_FPCBObj.FPCBPCSOpenLogFile Error - ' + String(LogFullNameA) );

      end; // if Assigned(FPCBPCSOpenLogFile) then // Open Log
}
      FuncAnsiName := 'OpenSerialPort';
      FPCBPCSOpenSerialPort := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBPCSOpenSerialPort) then ReportError()
      else // Open COM Port
      begin
        if FPCBDUCOMPort <= 255 then
        begin
          ResCode := FPCBPCSOpenSerialPort( FPCBDUCOMPort );

          if ResCode = 0 then
            N_Dump1Str( 'N_FPCBObj.FPCBPCSOpenSerialPort Error, Port Number = ' + IntToStr(FPCBDUCOMPort) );
        end;
      end; // else // Open COM Port

      FuncAnsiName := 'GetLastMessageFromSerialPort';
      FPCBPCSGetState := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBPCSGetState) then ReportError();

    end; // if AFPCBInd = N_FPCB_DUPCS then //***** Load 'Planmeca Compact Serial' Dental Unit DLL functions

    if AFPCBInd = N_FPCB_QI then //***** Load QI Optic Camera Buttons DLL functions
    begin
      FuncAnsiName := 'StartOrFindServer';
      FPCBQIStartOrFindServer := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQIStartOrFindServer) then ReportError();

      FuncAnsiName := 'StopServer';
      FPCBQIStopServer := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQIStopServer) then ReportError();

      FuncAnsiName := 'ReadLastRawInputEvent';
      FPCBQIReadLastRawInputEvent := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQIReadLastRawInputEvent) then ReportError();

      FuncAnsiName := 'ConnectToServer';
      FPCBQIConnectToServer := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQIConnectToServer) then ReportError();

      FuncAnsiName := 'ResetServerStatusData';
      FPCBQIResetServerStatusData := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQIResetServerStatusData) then ReportError();

      FuncAnsiName := 'SetReleaseButtonThreshold';
      FPCBQISetReleaseButtonThreshold := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQISetReleaseButtonThreshold) then ReportError();

      FuncAnsiName := 'RegisterButton';
      FPCBQIRegisterButton := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQIRegisterButton) then ReportError();

      FuncAnsiName := 'DisconnectFromServer';
      FPCBQIDisconnectFromServer := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQIDisconnectFromServer) then ReportError();

      FuncAnsiName := 'RegisterRawInputDeviceIsFinished';
      FPCBQIRegisterRawInputDeviceIsFinished := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQIRegisterRawInputDeviceIsFinished) then ReportError();

      FuncAnsiName := 'GetRegisterRawInputDeviceResult';
      FPCBQIGetRegisterRawInputDeviceResult := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQIGetRegisterRawInputDeviceResult) then ReportError();

      FuncAnsiName := 'OpenLogFile';
      FPCBQIOpenLogFile := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBQIOpenLogFile) then ReportError();

      FPCBQILoadFlag := False;
      FPCBQIThreshold := 3000;
    end; // if AFPCBInd = N_FPCB_QI then //***** Load QI Optic Camera Buttons DLL functions

    if AFPCBInd = N_FPCB_DUSirona then //***** Load 'Sirona' Dental Unit DLL functions
    begin
      // FPCBSironaStartOrFindServer:       TN_cdeclIntFuncVoid;       // SiucomInterface.dll StartOrFindServer function
      // FPCBSironaConnectToServer:         TN_cdeclIntFuncVoid;       // SiucomInterface.dll ConnectToServer function
      // FPCBSironaDisconnectFromServer:    TN_cdeclIntFuncVoid;       // SiucomInterface.dll DisconnectFromServer function
      // FPCBSironaStopServer:              TN_cdeclIntFuncVoid;       // SiucomInterface.dll StopServer function
      // FPCBSironaGetDeviceStateInMapView: TN_cdeclIntFuncInt;        // SiucomInterface.dll GetDeviceStateInMapView function
      // FPCBSironaActivateCamera:          TN_cdeclProcInt;           // SiucomInterface.dll ActivateCamera function
      // FPCBSironaOpenLogFile:             TN_cdeclIntFuncPAChar3Int; // SiucomInterface.dll OpenLogFile function

      FuncAnsiName := 'StartOrFindServer';
      FPCBSironaStartOrFindServer := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSironaStartOrFindServer) then ReportError();

      FuncAnsiName := 'ConnectToServer';
      FPCBSironaConnectToServer := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSironaConnectToServer) then ReportError();

      FuncAnsiName := 'DisconnectFromServer';
      FPCBSironaDisconnectFromServer := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSironaDisconnectFromServer) then ReportError();

      FuncAnsiName := 'StopServer';
      FPCBSironaStopServer := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSironaStopServer) then ReportError();

      FuncAnsiName := 'GetDeviceStateInMapView';
      FPCBSironaGetDeviceStateInMapView := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSironaGetDeviceStateInMapView) then ReportError();

      FuncAnsiName := 'ActivateCamera';
      FPCBSironaActivateCamera := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSironaActivateCamera) then ReportError();

      FuncAnsiName := 'OpenLogFile';
      FPCBSironaOpenLogFile := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSironaOpenLogFile) then ReportError();

      if FPCBDUInd <> 0 then
        N_Dump1Str( '************ DU error, FPCBDUInd <> 0 in FPCBLoadDLL' );

      if Result <> 0 then // some error while loading DLL Entries
      begin
        FPCBUnloadDLL( AFPCBInd );
        Exit;
      end;

      N_CMSetNeededCurrentDir ();

      //***** Open Log
      LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'Sirona.txt' );
      LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
      LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
      LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );

      ResCode := FPCBSironaOpenLogFile( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

      if ResCode = 0 then
        N_Dump1Str( 'FPCBSironaOpenLogFile Error - ' + String(LogFullNameA) );

      N_Dump1Str( 'Sirona before StartOrFindServer' );
      ResCode := FPCBSironaStartOrFindServer();
      N_Dump1Str( 'Sirona after StartOrFindServer' );
      Sleep( 4300 );
      N_Dump1Str( 'Sirona after Sleep 4300' );

      if ResCode <> 0 then
      begin
        FPCBErrorStr := ' Sirona StartOrFindServer failed ' + SysErrorMessage( GetLastError() );
        N_Dump1Str( FPCBErrorStr );
        Result := 10;
      end else // StartOrFindServer returned OK
      begin
        N_Dump1Str( ' FPCBSironaStartOrFindServer returned OK' );

        for i := 0 to 20 do // wait if needed between calls to StartOrFindServer and ConnectToServer
        begin
          ResCode := FPCBSironaConnectToServer();

          if ResCode = 0 then
          begin
            N_Dump1Str( ' FPCBSironaConnectToServer returned OK' );
            Break;
          end;

          N_Dump1Str( 'FPCBSironaConnectToServer failed, before Sleep 300' );
          Sleep( 300 );
        end;

        if ResCode <> 0 then
        begin
          FPCBErrorStr := ' Sirona ConnectToServer failed ' + SysErrorMessage( GetLastError() );
          N_Dump1Str( FPCBErrorStr );
          ResCode := FPCBSironaStopServer();
          if ResCode <> 0 then
          begin
            FPCBErrorStr := ' Sirona StopServer failed ' + SysErrorMessage( GetLastError() );
            N_Dump1Str( FPCBErrorStr );
          end;
          Result := 11;
        end else // ConnectToServer returned OK
        begin
          if FPCBDUActivateMode = 0 then
            FPCBSironaActivateCamera( 1 );
        end; // else // ConnectToServer returned OK
      end; // else // StartOrFindServer returned OK

    end; // if AFPCBInd = N_FPCB_DUSirona then //***** Load 'Sirona' Dental Unit DLL functions

    if AFPCBInd = N_FPCB_MediaCamPlus then //***** Load MediaCam Optic Camera Buttons DLL functions
    begin
      FuncAnsiName := 'sendExtensionUnitCommand';
      FPCBMediaCamSendExtensionUnitCommand := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBMediaCamSendExtensionUnitCommand) then ReportError();

      CoInitialize( Nil );
    end; // if AFPCBInd = N_FPCB_MediaCamPlus then //***** Load MediaCam Optic Camera Buttons DLL functions

    if AFPCBInd = N_FPCB_ActeonSopro then //***** Load MediaCam Optic Camera Buttons DLL functions
    begin
      FuncAnsiName := 'fnSoproTouch';
      FPCBSoproTouch := GetProcAddress( FPCBDllHandle, @FuncAnsiName[1] );
      if not Assigned(FPCBSoproTouch) then ReportError();
    end; // if AFPCBInd = N_FPCB_ActeonSopro

    if AFPCBInd = N_FPCB_MediaCamPro then //***** Load MediaCam Optic Camera Buttons DLL functions
    begin
    end; // if AFPCBInd = N_FPCB_ActeonSopro

    //*** If any error occure, Unload DLL (it cannot be used)

    if Result <> 0 then // some error while loading DLL Entries or Device initialization
    begin
      FPCBUnloadDLL( AFPCBInd );
    end;

  end; // with FPCBDevices[AFPCBInd] do

end; // function TN_FPCBObj.FPCBLoadDLL

//************************************************ TN_FPCBObj.FPCBUnloadDLL ***
// Unload DLL and free resources for given FPCB (Foot Pedal or Camera Button) Device
//
//     Parameters
// AFPCBInd - FPCB Device Index (in FPCBDevices array)
//
procedure TN_FPCBObj.FPCBUnloadDLL( AFPCBInd: integer );
var
  ResCode: integer;
begin
  if FPCBBadInd( AFPCBInd ) then Exit;

  if AFPCBInd = N_FPCB_QI then
  begin
  if FPCBDevices[AFPCBInd].FPCBQILoadFlag then
    //FPCBQIDisconnectFromServer;
    FPCBQIStopServer;
    FPCBDevices[AFPCBInd].FPCBQILoadFlag := False;
  end;

  if AFPCBInd = N_FPCB_DUSiUCOM then
  begin
    KillTask('SiUCOM_CMS.exe');
    KillTask('siucom.exe');
  end;

  if AFPCBInd = N_FPCB_MediaCamPro then
  begin
    KillTask('MediaCamPro.exe');
  end;

  with FPCBDevices[AFPCBInd] do
  begin
    if FPCBDLLHandle <> 0 then
    begin
      if AFPCBInd = N_FPCB_Serial then // Close Serial Foot Pedal COM Port
      begin
        N_Dump2Str( 'Before FPCBSerialCloseSerialPort' );
        FPCBSerialCloseSerialPort();
      end; // if AFPCBInd = N_FPCB_Serial then // Close Serial Foot Pedal COM Port

      if AFPCBInd = N_FPCB_DUSirona then // Close Sirona Dental Unit
      begin
        FPCBSironaActivateCamera( 0 );
        ResCode := FPCBSironaDisconnectFromServer();
                if ResCode <> 0 then
        begin
          FPCBErrorStr := ' Sirona DisconnectToServer failed ' + SysErrorMessage( GetLastError() );
          N_Dump1Str( FPCBErrorStr );
        end;

        ResCode := FPCBSironaStopServer();
        if ResCode <> 0 then
        begin
          FPCBErrorStr := ' Sirona StopServer failed ' + SysErrorMessage( GetLastError() );
          N_Dump1Str( FPCBErrorStr );
        end;
      end; // if AFPCBInd = N_FPCB_DUSirona then // Close Sirona Dental Unit


      N_Dump2Str( 'Before FreeLibrary ' + FPCBDLLFName );
      ResCode := integer(FreeLibrary( FPCBDLLHandle ));

      if ResCode = 0 then // FreeLibrary error
      begin
        FPCBErrorStr := SysErrorMessage( GetLastError() );
        N_Dump1Str( Format( 'FreeLibrary Error, DLLName=%s (%s, ErrCode=%d)', [FPCBDLLFName,FPCBErrorStr,ResCode] ));
      end else
        N_Dump2Str( 'After FreeLibrary OK' );

      FPCBDLLHandle := 0;

      if AFPCBInd = N_FPCB_MediaCamPlus then
      begin
        CoUninitialize();
      end;
    end;
  end; // with FPCBDevices[AFPCBInd] do
end; // procedure TN_FPCBObj.FPCBUnloadDLL

//********************************************* TN_FPCBObj.FPCBGetFPCBState ***
// Get Current and Previous State for given FPCB (Foot Pedal or Camera Button) Device
//
//     Parameters
// AFPCBInd   - FPCB Device Index (in FPCBDevices array)
// ACurState  - Current State in least two bits (on output)
// APrevState - Previous State in least two bits (on output)
// Result     - Return 0 if OK, <> 0 if some errors, 1 - Device should be closed
//
function TN_FPCBObj.FPCBGetFPCBState( AFPCBInd: integer;
                                  out ACurState, APrevState: integer ): integer;
var
  ResCodeQI: DWord;
  IntTempQI, LogMaxSize, LogMaxDays, LogDetails, ResCode: Integer;
  TempInt: AnsiChar;
  LogFullNameA: AnsiString;
  TimeElapsed: double;

  pdw: TextFile;
  Params, MsgDir: string;

  function ReverseIfNeeded( AState: integer ): integer; // local
  // Reverse given AState is needed
  begin
    Result := AState;

    if FPCBDevices[AFPCBInd].FPCBReverse then
    begin
      if AState = 1 then Result := 2
      else if AState = 2 then Result := 1;
    end; // if FPCBDevices[AFPCBInd].FPCBReverse then
  end; // function ReverseIfNeeded - local

begin
  Result := 0; // OK
  ACurState := 0;
  APrevState := 0;
  if FPCBBadInd( AFPCBInd ) then Exit;
  if AFPCBInd = N_FPCB_None then Exit;

  with FPCBDevices[AFPCBInd] do
  begin

  APrevState := FPCBPrevState; // Return Previous Device State

  case AFPCBInd of

  N_FPCB_TestDevice1: begin
    // not implemented
  end; // N_FPCB_TestDevice1: begin

  N_FPCB_TestDevice2: begin
    // not implemented
  end; // N_FPCB_TestDevice2: begin

  N_FPCB_KeyboardF5F6: begin
    if N_KeyIsDown( VK_F5 ) then ACurState := 1;
    if N_KeyIsDown( VK_F6 ) then ACurState := ACurState + 2;
    ACurState := ReverseIfNeeded( ACurState );
  end; // N_FPCB_KeyboardF5F6: begin

  N_FPCB_KeyboardF7F8: begin
    if N_KeyIsDown( VK_F7 ) then ACurState := 1;
    if N_KeyIsDown( VK_F8 ) then ACurState := ACurState + 2;
    ACurState := ReverseIfNeeded( ACurState );
  end; // N_FPCB_KeyboardF7F8: begin

  N_FPCB_Delcom: begin
    if Assigned(FPCBDelcomIsButtonPressed) then
      ResCode := FPCBDelcomIsButtonPressed()
    else
      ResCode := -3;

    if ResCode >= 0 then // all is OK
      ACurState := ResCode
    else // some error
    begin
      FPCBErrorStr := SysErrorMessage( GetLastError() );
      N_Dump1Str( Format( 'Error in DelcomDllInterface.dll IsButtonPressed function (%s, ErrCode=%d)', [FPCBErrorStr,ResCode] ));
      Result := ResCode;
      ACurState := 0;
    end;
  end; // N_FPCB_Delcom: begin

  N_FPCB_Serial: begin
    if Assigned(FPCBSerialGetPedalsStates) then
      ResCode := FPCBSerialGetPedalsStates( @ACurState, 0 ) // 0 means Enable F5,F6 Keybord keys
    else
      ResCode := -3;

    if ResCode <> 0 then // some error
    begin
      FPCBErrorStr := SysErrorMessage( GetLastError() );
      N_Dump1Str( Format( 'Error in SerialPedalInterface.dll GetPedalsStates function (%s, ErrCode=%d)', [FPCBErrorStr,ResCode] ));
      Result := ResCode;
      ACurState := 0;
    end else // ResCode =0, all is OK
      ACurState := ReverseIfNeeded( ACurState );
  end; // N_FPCB_Serial

  N_FPCB_SoproTouch: begin
    // TimeElapsed is Time in seconds since SoproTouch DLL was loaded
    TimeElapsed := (N_CPUCounter() - FPCBSavedCPUCounter) / N_CPUFrequency;
    if TimeElapsed < 2.0 then Exit; // wait for two seconds after Loading DLL

    if Length(FPCBWideDriverName) = 0 then
      ResCode := -4
    else
    begin
      if Assigned(FPCBSoproTouchIsButtonPressed) then
        ResCode := FPCBSoproTouchIsButtonPressed( @FPCBWideDriverName[1] )
      else
        ResCode := -3;
    end;

    if ResCode >= 0 then // all is OK
      ACurState := ResCode
    else // some error
    begin
      FPCBErrorStr := SysErrorMessage( GetLastError() );
      N_Dump1Str( Format( 'Error in SoproTouchDLLInterface.dll IsButtonPressed function (%s, ErrCode=%d)', [FPCBErrorStr,ResCode] ));
      Result := ResCode;
      ACurState := 0;
    end;
  end; // N_FPCB_SoproTouch: begin

  N_FPCB_SchickUSB: begin
    if Assigned(FPCBSchickUSBIsButtonPressed) then
      ResCode := FPCBSchickUSBIsButtonPressed()
    else
      ResCode := -3;

      N_Dump1Str('ResCode Schick = '+inttostr(ResCode));
    if ResCode >= 0 then // all is OK
      ACurState := ResCode
    else // some error
    begin
      FPCBErrorStr := SysErrorMessage( GetLastError() );
      N_Dump1Str( Format( 'Error in SchickDllInterface.dll IsButtonPressed function (%s, ErrCode=%d)', [FPCBErrorStr,ResCode] ));
      Result := ResCode;
      ACurState := 0;
    end;
  end; // N_FPCB_SchickUSB: begin

  N_FPCB_SchickUSBCam4: begin

    ResCode := -3;

    if N_CMFPedalSF.N_SchickUSBCam4Camera <> Nil then
    begin
      if N_SchickUSBCam4Camera.IsButtonPressed() = True then
      begin
        N_Dump1Str('True - Camera');
        ResCode := 1;
      end
      else
      begin
        ResCode := 0;
        N_Dump1Str('False - Camera');
      end;
    end;

    if ResCode >= 0 then // all is OK
      ACurState := ResCode
    else // some error
    begin
      FPCBErrorStr := SysErrorMessage( GetLastError() );
      N_Dump1Str( Format( 'Error in SchickUSBCam4 tlb IsButtonPressed function (%s, ErrCode=%d)', [FPCBErrorStr,ResCode] ));
      Result := ResCode;
      ACurState := 0;
    end;
  end; // N_FPCB_SchickUSBCam4: begin

  N_FPCB_Winus100D: begin
    if Length(FPCBWideDriverName) = 0 then
      ResCode := -4
    else
    begin
      if Assigned(FPCBWinus100DIsButtonPressed) then
        ResCode := FPCBWinus100DIsButtonPressed( @FPCBWideDriverName[1] )
      else
        ResCode := -3;
    end;

    if ResCode >= 0 then // all is OK
      ACurState := ResCode
    else // some error
    begin
      FPCBErrorStr := SysErrorMessage( GetLastError() );
      N_Dump1Str( Format( 'Error in WinusDllInterface.dll IsButtonPressed function (%s, ErrCode=%d)', [FPCBErrorStr,ResCode] ));
      Result := ResCode;
      ACurState := 0;
    end;
  end; // N_FPCB_Winus100D: begin

  N_FPCB_Win100DBDA: begin
    if Length(FPCBWideDriverName) = 0 then
      ResCode := -4
    else
    begin
      if Assigned(FPCBWinus100DBDAIsButtonPressed) then
        ResCode := FPCBWinus100DBDAIsButtonPressed( @FPCBWideDriverName[1] )
      else
        ResCode := -3;
    end;

    if ResCode >= 0 then // all is OK
      ACurState := ResCode
    else // some error
    begin
      FPCBErrorStr := SysErrorMessage( GetLastError() );
      N_Dump1Str( Format( 'Error in WinusDllInterface_BDA.dll IsButtonPressed function (%s, ErrCode=%d)', [FPCBErrorStr,ResCode] ));
      Result := ResCode;
      ACurState := 0;
    end;
  end; // N_FPCB_Win100DBDA: begin

  N_FPCB_USBPedal: begin
    If (JoyGetPos(JoystickID1, @N_FPCBObj.FPCBDevices[N_FPCB_USBPedal].FPCBUSBPedal) <> JoyErr_NoError) then
    begin
      ResCode := -3;
      FPCBErrorStr := SysErrorMessage( GetLastError() );
      N_Dump1Str( Format( 'Error in MMSystem.pas JoyGetPos function (%s, ErrCode=%d)', [FPCBErrorStr,ResCode] ));
      Result := ResCode;
      ACurState := 0;
    end else
    begin
      If ((N_FPCBObj.FPCBDevices[N_FPCB_USBPedal].FPCBUSBPedal.WButtons and Joy_Button1) > 0) then
        ACurState := 1;
      If ((N_FPCBObj.FPCBDevices[N_FPCB_USBPedal].FPCBUSBPedal.WButtons and Joy_Button2) > 0) then
        ACurState := ACurState + 2;
    end;
    ACurState := ReverseIfNeeded( ACurState );
  end; // N_FPCB_USBPedal: begin

  N_FPCB_MultiCam:
  begin
    ResCode := FPCBMultiCamWasButtonPressed();

    if (ResCode < 0) or (ResCode >= 2) then // error
    begin
      N_Dump1Str( Format( 'Error in MultiCam WasButtonPressed function (ErrCode=%d)', [ResCode] ));
      Result := -5;
    end else // all OK, ResCode = 0 or 1
    begin
      ACurState  := ResCode;
      APrevState := FPCBPrevState;

      if ResCode = 1 then // Button is down, reset it's state
      begin
        ResCode := FPCBMultiCamResetButtonState();

        if ResCode < 0 then // error
        begin
          N_Dump1Str( Format( 'Error in MultiCam ResetButtonState function (ErrCode=%d)', [ResCode] ));
          Result := -6;
        end; // if ResCode < 0 then // error
      end; // if ResCode = 1 then // Button is down, reset it's state

    end; // else // all OK, ResCode = 0 or 1

  end; // N_FPCB_MultiCam: begin

  N_FPCB_QI: begin
    if N_FlagForm = 2 then // mode 3
    begin
      if not FPCBQILoadFlag then
      begin
        LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'QiOptic.txt' );
        LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
        LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
        LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );
        ResCodeQI := FPCBQIOpenLogFile( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

        if( ResCodeQI = 0 ) then
        begin
          N_Dump1Str( 'Qi - FPCBQIOpenLogFile failed' );
          ResCode := -3;
          ACurState := 0;
          Result := ResCode;
          Exit;
  	    end	else
   		    N_Dump1Str( 'Qi - FPCBQIOpenLogFile finished successfully' );

        ResCodeQI := FPCBQIStartOrFindServer();

  	    if ( ResCodeQI <> NO_ERROR ) then
       	begin
          N_Dump1Str( 'Qi - Start Or Find QiOptic Server failed.' );
          ResCode := -3;
          ACurState := 0;
          Result := ResCode;
          Exit;
  	    end	else
   		    N_Dump1Str( 'Qi - Start Or Find QiOptic Server finished successfully.' );

   	    ResCodeQI := FPCBQIConnectToServer();

   	    if ( ResCodeQI <> NO_ERROR ) then
        begin
   	  		N_Dump1Str( 'Qi - ConnectToServer failed.' );
	    	  ResCode := -3;
          ACurState := 0;
          Result := ResCode;
          FPCBQIStopServer;
          Exit;
        end else
	    	  N_Dump1Str( 'Qi - ConnectToServer finished successfully.' );

        FPCBQIResetServerStatusData();
        N_Dump1Str( 'Qi - After ResetServerStatusData' );

        N_Dump1Str( 'Qi - Threshold = ' + IntToStr(FPCBQIThreshold) );
        FPCBQISetReleaseButtonThreshold( FPCBQIThreshold );
        N_Dump1Str( 'Qi - After SetReleaseButtonThreshold = ' + IntToStr(FPCBQIThreshold) );

        TempInt := AnsiChar(N_MemIniToInt( 'CMS_UserDeb', 'QiOpticButtonSimulation', 0 ));
        FPCBQIRegisterButton( 1,  65440,  65440, AnsiChar(TempInt) );
        N_Dump1Str( 'Qi - After RegisterButton, Button Simulation = ' + TempInt );

        while FPCBQIRegisterRawInputDeviceIsFinished <> 1 do
        begin
          N_Dump1Str( 'Qi - Register Raw Input Device' );
        end;
        N_Dump1Str( 'Qi - After FPCBQIRegisterRawInputDeviceIsFinished = 0' );

        if FPCBQIGetRegisterRawInputDeviceResult = 0 then
        begin
          FPCBQILoadFlag := True;
          N_Dump1Str( 'Qi - FPCBQILoadFlag := True' );
        end else
        begin
          N_Dump1Str( 'Qi - FPCBQIGetRegisterRawInputDeviceResult <> 0' );
          ResCode := -3;
          ACurState := 0;
          Result := ResCode;
          FPCBQIDisconnectFromServer;
          FPCBQIStopServer;
          Exit;
        end;
      end; // if not FPCBQILoadFlag then

      if N_CMVideo4F.N_TempThreshold <> FPCBQIThreshold then
      begin
        FPCBQIThreshold := N_CMVideo4F.N_TempThreshold;
        FPCBQISetReleaseButtonThreshold( FPCBQIThreshold );
        N_Dump1Str( 'Qi - After SetReleaseButtonThreshold = ' + IntToStr(FPCBQIThreshold) );
      end;

      IntTempQi := FPCBQIReadLastRawInputEvent;
      N_Dump1Str( 'Qi - After FPCBQIReadLastRawInputEvent = ' + IntToStr(IntTempQi) );

      //if (IntTempQi = 2) then
      //  ACurState := 1
      //else

      case N_CMVideo4F.N_CMVideo4Form.CmBCaptureButton.ItemIndex of
      0: begin
        if (IntTempQi = 1) then
          ACurState := 1
        else
          ACurState := 0;
      end;
      1: begin
        if (IntTempQi = 3) then
          ACurState := 1
        else
          ACurState := 0;
      end;
      end;

      ACurState := ReverseIfNeeded( ACurState );

      N_Dump1Str( 'Qi - ACurState = ' + IntToStr(ACurState) );

      end;
    end; // N_FPCB_QI: begin

    N_FPCB_MediaCamPlus:
    begin
      ResCode := FPCBMediaCamSendExtensionUnitCommand( 13, 0, 0, 4 );
      ACurState := ResCode;
    end; // N_FPCB_MediaCamPlus:

    N_FPCB_ActeonSopro:
    begin
      ResCode := FPCBSoproTouch(N_StringToAnsi('Sopro cameras driver'));
      if ResCode <> 0 then
        ACurState := 0;
      if ResCode = 0 then
      begin
        N_Dump1Str( 'ActeonSopro is pressed' );
        ACurState := 1;
      end;
    end; // N_FPCB_ActeonSopro:

    N_FPCB_MediaCamPro:
    begin
    try

      MsgDir := K_ExpandFileName( '(#TmpFiles#)MediaCamPro_msg.cfg' );
      if FileExists( MsgDir ) then
        AssignFile(pdw, MsgDir)
      else
        Exit;

      FileMode := fmOpenRead; // open file with device states

      Reset( pdw );
      ReadLn( pdw, Params ); // read states
      CloseFile( pdw );

    except
      N_Dump1Str( 'Exception while reading MediaCam Pro file!' );
      Params := '0'; // default
    end;

    if Params <> '' then // if already written
    if ( Params[1] = '1' ) and ( FPCBMediaCamPrevState <> 1 ) then // button pressed
    begin
      N_Dump1Str( 'MediaCamPro button is pressed' );
      ACurState := 1;
      FPCBMediaCamPrevState := 1;
    end
    else
    if ( Params[1] = '0') then
    begin
      ACurState := 0;
      FPCBMediaCamPrevState := 0;
    end
    else
      ACurState := 0;
    end; // N_FPCB_MediaCamPro:

  end; // case AFPCBInd of

  FPCBPrevState := ACurState; // Save Current Device State

  end; // with FPCBDevices[AFPCBInd] do
end; // function TN_FPCBObj.FPCBGetFPCBState

//*************************************************** TN_FPCBObj.FPCBInitDU ***
// Init Dental Unit
//
// If DentalUnitDevInd in [CMS_Main] is not set, DU initialization is not needed
//
procedure TN_FPCBObj.FPCBInitDU();
var
  ResCode, SavedDUInd, OpenInt: integer;
  WrkDir, LogDir, CurDir, FileName, DriverName: String;
  AnsiStringTemp: AnsiString;
  CardRes: Cardinal;
  begin
  //****** Set DU related self fields from ini file
  //       (VideoProfile Editor (N_CMVideoProfileF) may change related ini file items)
  //       (FPCBDUCOMPort,FPCBDUUseKeyboard are used only by Planmeca Compact Serial)

  FPCBDUInd       := N_MemIniToInt(    'CMS_Main',     'DentalUnitDevInd', N_FPCB_None );
  FPCBDUProfName  := N_MemIniToString( 'CMS_Main',     'DentalUnitProfName', 'None' );
  FPCBDUCOMPort   := N_MemIniToInt(    'CMS_UserMain', 'DentalUnitCOMPort', 1 );
//  FPCBDUUseKeyboard := N_MemIniToBool( 'CMS_UserDeb',  'UseKeyboardForDentalUnit', False );
  FPCBDUUseKeyboard := N_MemIniToBool( 'CMS_UserDeb',  'UseKeyboardForDentalUnit', True ); // for debug

  FPCBDUActivateMode := N_MemIniToInt( 'CMS_UserMain', 'SironaActivateMode', 3 );
  if FPCBDUActivateMode = 3 then // no SironaActivateMode variable in file
    FPCBDUActivateMode := N_MemIniToInt( 'CMS_Main', 'SironaActivateModeS', 0 );

  FPCBDUCloseMode    := N_MemIniToInt( 'CMS_UserMain', 'SironaCloseMode',    3 );
  if FPCBDUCloseMode = 3 then // no SironaCloseMode variable in file
    FPCBDUCloseMode := N_MemIniToInt( 'CMS_Main', 'SironaCloseModeS', 0 );

  N_Dump1Str( Format( '     Sirona Mode: %d %d', [FPCBDUActivateMode, FPCBDUCloseMode] ) );

  N_Dump1Str( Format( 'Init Dental Unit: "%s" %d %d %s', [FPCBDUProfName,FPCBDUInd,FPCBDUCOMPort,N_B2S(FPCBDUUseKeyboard)] ) );

  if FPCBDUInd <> N_FPCB_None then // Initialize Dental Unit
  if FPCBDUInd = N_FPCB_DUSiUCOM then
  begin
    KillTask('SiUCOM_CMS.exe'); // if opened
    KillTask('siucom.exe');

    WrkDir       := N_CMV_GetWrkDir();
    LogDir       := N_CMV_GetLogDir();
    CurDir       := ExtractFilePath( ParamStr( 0 ) );
    N_Dump1Str( 'SiUCOM >> Exe directory = "' + CurDir + '"' );
    FileName     := CurDir + 'SiUCOM_CMS.exe';
    DriverName   := CurDir + 'siucom.exe';

    // wait old driver session closing
    N_CMV_WaitProcess( False, FileName, -1 );

    if not FileExists( FileName ) then // find driver
    begin
      N_Dump1Str( 'SiUCOM driver do not exist' );
      Exit;
    end; // if not FileExists( FileName ) then // find driver

    SiucomButtonLastState := '0';
    SiucomLastState := '0';

    OpenInt := N_MemIniToInt( 'CMS_UserDeb', 'SiUCOMOpenType', 0 );

    if OpenInt = 0 then
    begin
      AnsiStringTemp := N_StringToAnsi('"' + DriverName + '"');
      WinExec( @AnsiStringTemp[1], SW_SHOWNORMAL );

      AnsiStringTemp := N_StringToAnsi('"' + FileName + '"');
      CardRes := WinExec( @AnsiStringTemp[1], SW_HIDE );
      N_Dump1Str( 'WinExec returns ' + IntToStr(CardRes) );
    end;

    if OpenInt = 1 then
    begin
{$IF SizeOf(Char) = 2} // Wide Chars (>= Delphi 2010)
      ShellExecute(0, nil, @N_StringToWide(DriverName)[1], nil, nil, SW_SHOWNORMAL);
      ShellExecute(0, nil, @N_StringToWide(FileName)[1],   nil, nil, SW_HIDE);
{$ELSE} //*************** Ansi Chars (Delphi 7)
      // not yet
{$IFEND}
    end;

  end // if FPCBDUInd = N_FPCB_DUSiUCOM then
  else
  begin
    SavedDUInd := FPCBDUInd;
    FPCBDUInd := 0; // to prevent calling DU functions from FPCBGetDUState while initialization

//    N_i := GetCurrentDirectory( 0, nil );
//    SetLength( BufStr, N_i );
//    GetCurrentDirectory( N_i, @BufStr[1] );
//    N_Dump1Str( Format( 'Dental Unit Dir1: "%s"', [BufStr] ) );
//    N_s := ExtractFilePath( ParamStr( 0 ) );
//    SetCurrentDirectory( @N_s[1] );

//    N_i := GetCurrentDirectory( 0, nil );
//    SetLength( BufStr, N_i );
//    GetCurrentDirectory( N_i, @BufStr[1] );
//    N_Dump1Str( Format( 'Dental Unit Dir2: "%s"', [BufStr] ) );

    ResCode := FPCBLoadDLL( SavedDUInd );
    if ResCode <> 0 then // some errors
    begin
      FPCBDUInd := N_FPCB_None;
      FPCBUnloadDLL( SavedDUInd );
    end else // ResCode = 0, all ok
      FPCBDUInd := SavedDUInd; // restore, FPCBGetDUState can be called now

  end; // if FPCBDUInd <> N_FPCB_None then // Initialize Dental Unit

end; // procedure TN_FPCBObj.FPCBInitDU();

//*********************************************** TN_FPCBObj.FPCBGetDUState ***
// Get Current (with FPCBDUInd) Dental Unit State
//
//     Parameters
// Result       - 0 - 4 (see N_DU_xxx constants)
//
function TN_FPCBObj.FPCBGetDUState(): integer;
var
  BlockEmulatorKeys: Integer;
  pdw: TextFile;
  Params, MsgDir: string;
  TwoClicksMode: Boolean;
begin
  Result := N_DU_NOTHING_TODO;

  if FPCBDUInd = N_FPCB_DUPCS then // Planmeca Compact Serial
  begin
      if FPCBDUUseKeyboard then BlockEmulatorKeys := 0
                           else BlockEmulatorKeys := 1;

      Result := FPCBPCSGetState( BlockEmulatorKeys );
  end; // if AFPCBInd = N_FPCB_DUPCS then // Planmeca Compact Serial

  if FPCBDUInd = N_FPCB_DUSirona then // Sirona
  begin
    if N_FlagForm = 2 then // mode 3
    begin

    if ( N_CMVideo4F.N_CMVideo4Form = Nil ) or
               ( N_CMVideo4F.N_CMVideo4Form.rgOneTwoClicks.ItemIndex <> 0 ) then
      TwoClicksMode := True
    else
      TwoClicksMode := False;

    if not TwoClicksMode then
    begin

      if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_FOOTCTRL_SAVEPICTURE ) <> 0 then
        Result := N_DU_SAVE_AND_UNFREEZE
      else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_FOOTCTRL_TOGGLEVIDEOSTREAM ) <> 0 then
        Result := N_DU_FREEZE_UNFREEZE_TOGGLE
      else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_IS_PICKED_UP_TRUE ) <> 0 then
        Result := N_DU_CAMERA_TAKEN
      else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_IS_PICKED_UP_FALSE ) <> 0 then
        Result := N_DU_CAMERA_RETURNED;
    end
    else // one click capture
    begin
      if N_MemIniToInt( 'CMS_UserMain', 'SironaCaptureMode', 1 ) = 1 then
      begin

        if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_FOOTCTRL_SAVEPICTURE ) <> 0 then
          Result := N_DU_SAVE_AND_UNFREEZE
        else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_FOOTCTRL_TOGGLEVIDEOSTREAM ) <> 0 then
          Result := N_DU_FREEZE_UNFREEZE_TOGGLE
        else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_IS_PICKED_UP_TRUE ) <> 0 then
          Result := N_DU_CAMERA_TAKEN
        else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_IS_PICKED_UP_FALSE ) <> 0 then
          Result := N_DU_CAMERA_RETURNED;
      end;

      if N_MemIniToInt( 'CMS_UserMain', 'SironaCaptureMode', 1 ) = 2 then
      begin
        if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_FOOTCTRL_SAVEPICTURE ) <> 0 then
          Result := N_DU_FREEZE_UNFREEZE_TOGGLE
        else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_FOOTCTRL_TOGGLEVIDEOSTREAM ) <> 0 then
          Result := N_DU_SAVE_AND_UNFREEZE
        else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_IS_PICKED_UP_TRUE ) <> 0 then
          Result := N_DU_CAMERA_TAKEN
        else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_IS_PICKED_UP_FALSE ) <> 0 then
          Result := N_DU_CAMERA_RETURNED;
      end;

      if N_MemIniToInt( 'CMS_UserMain', 'SironaCaptureMode', 1 ) = 3 then
      begin
        if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_FOOTCTRL_TOGGLEPICTURE ) <> 0 then
          Result := N_DU_FREEZE_UNFREEZE_TOGGLE
        else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_FOOTCTRL_TOGGLEVIDEOSTREAM ) <> 0 then
          Result := N_DU_SAVE_AND_UNFREEZE
        else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_IS_PICKED_UP_TRUE ) <> 0 then
          Result := N_DU_CAMERA_TAKEN
        else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_IS_PICKED_UP_FALSE ) <> 0 then
          Result := N_DU_CAMERA_RETURNED;
      end;
    end; // one click capture

    end
    else
    begin

      if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_FOOTCTRL_SAVEPICTURE ) <> 0 then
        Result := N_DU_SAVE_AND_UNFREEZE
      else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_FOOTCTRL_TOGGLEVIDEOSTREAM ) <> 0 then
        Result := N_DU_FREEZE_UNFREEZE_TOGGLE
      else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_IS_PICKED_UP_TRUE ) <> 0 then
        Result := N_DU_CAMERA_TAKEN
      else if FPCBSironaGetDeviceStateInMapView( N_DEVICE_STATE_IS_PICKED_UP_FALSE ) <> 0 then
        Result := N_DU_CAMERA_RETURNED;
    end;

  end; // if AFPCBInd = N_FPCB_DUSirona then // Sirona

  if FPCBDUInd = N_FPCB_DUSiUCOM then // SiUCOM
  begin
    try
      MsgDir := K_ExpandFileName( '(#WrkFiles#)/SiUCOM_msg.cfg' );
      if FileExists( MsgDir ) then
        AssignFile(pdw, MsgDir)
      else
        Exit;

      FileMode := fmOpenRead; // open file with device states

      Reset( pdw );
      ReadLn( pdw, Params ); // read states
      CloseFile( pdw );

    except
      N_Dump1Str( 'Exception while reading SiUCOM file!' );
      Params := '00'; // default
    end;

    if Params[2] <> SiucomButtonLastState then // button pressed
    begin
      SiucomButtonLastState := Params[2];
      Result := N_DU_FREEZE_UNFREEZE_TOGGLE;
    end
    else // open or close states
    if (Params[1] = '1') and (Params[1] <> SiucomLastState) // open
    then
    begin
      SiucomLastState := Params[1];
      SiucomButtonLastState := '0';
      Result := N_DU_CAMERA_TAKEN;
    end
    else
    if (Params[1] = '0') and (Params[1] <> SiucomLastState) // close
    then
    begin
      SiucomLastState := Params[1];
      Result := N_DU_CAMERA_RETURNED;
    end;
  end; // if FPCBDUInd = N_FPCB_DUSiUCOM then // SiUCOM

  if Result = N_DU_NOTHING_TODO then // check if Dump is needed
  begin
    Inc( FPCBDUGetStateDumpCounter );

    if FPCBDUGetStateDumpCounter <= 2 then
      N_Dump1Str( 'FPCBGetDUState: Result=0 ' )
    else if FPCBDUGetStateDumpCounter = 3 then
      N_Dump1Str( 'FPCBGetDUState: Result=0 ...' );

  end else // Result <> N_DU_NOTHING_TODO - clear FPCBDUGetStateDumpCounter,
           //                               set FPCBDUCameraTaken and always dump
  begin
    FPCBDUGetStateDumpCounter := 0;

    if Result = N_DU_CAMERA_TAKEN then
      FPCBDUCameraTaken := True
    else if Result = N_DU_CAMERA_RETURNED then
      FPCBDUCameraTaken := False;

    N_Dump1Str( Format( 'FPCBGetDUState: Result=%d', [Result] ) );
  end;

end; // function TN_FPCBObj.FPCBGetDUState

//****************************************** TN_FPCBObj.FPCBIfDUCameraTaken ***
// Return True if Current (with FPCBDUInd) Dental Unit Camera was taken
//
// FPCBIfDUCameraTaken is called by system timer in K_CM0 about each second during hole session,
// but FPCBGetDUState() function is called only if FPCBDUCameraTaken=False
//
function TN_FPCBObj.FPCBIfDUCameraTaken(): Boolean;
var
  CurState: Integer;
begin
  Result := False;
  if FPCBDUCameraTaken then Exit;

  CurState := FPCBGetDUState();

  if CurState = N_DU_CAMERA_TAKEN then
  begin
    N_Dump1Str( 'DU Camera was taken' );
    Result := True;
  end else if CurState <> N_DU_NOTHING_TODO then
  begin
    N_Dump1Str( Format( 'FPCBIfDUCameraTaken: CurState=%d', [CurState] ) );
  end;

end; // function TN_FPCBObj.FPCBIfDUCameraTaken


    //*********** Global Procedures  *****************************

//***************************************************** N_CMConvCBToFPCBInd ***
// Convert given old or new variant of Camera Button Index to new FPCB Index
//
//     Parameters
// ACBInd - given old or new variant of Camera Button Index
//
function N_CMConvCBToFPCBInd( ACBInd: integer ): integer;
begin
  if ACBInd < 100 then // Old variant - EXTDLL Index, not FPCB Index
  begin
    case ACBInd of // convert old EXTDLL Index, to new FPCB Index
      0: Result := N_FPCB_None;
      1: Result := N_FPCB_SoproTouch;
      2: Result := N_FPCB_SchickUSB;
      3: Result := N_FPCB_Winus100D;
      4: Result := N_FPCB_Win100DBDA;
    else
      Result := N_FPCB_None; // a precaution
    end; // case CMVFCameraBtnDevInd of // convert old EXTDLL Index, to new FPCB Index
  end else // new variant - ACBInd is FPCB Index + 100
    Result := ACBInd - 100;
end; // function N_CMConvCBToFPCBInd

//**************************************************** N_CMDecodeFPCBStates ***
// Decode two given FPCB Device States (two least bits in each)
//
//     Parameters
// ACurState  - Current FPCB Device State in two least bits
// APrevState - Previous SFPCB Device tate in two least bits
// Pressed1   - Pedal (or Button) 1 was Pressed
// Released1  - Pedal (or Button) 1 was Released
// Pressed2   - Pedal (or Button) 2 was Pressed
// Released2  - Pedal (or Button) 2 was Released
//
// Least bit (bit 0) means Pedal (or Button) 1,
//   next bit (bit1) means Pedal (or Button) 2
//
procedure N_CMDecodeFPCBStates( ACurState, APrevState: integer;
                                out Pressed1, Released1, Pressed2, Released2: boolean );
begin
  Pressed1  := ((APrevState and $01) =  0) and ((ACurState and $01) <> 0);
  Released1 := ((APrevState and $01) <> 0) and ((ACurState and $01) =  0);
  Pressed2  := ((APrevState and $02) =  0) and ((ACurState and $02) <> 0);
  Released2 := ((APrevState and $02) <> 0) and ((ACurState and $02) =  0);
end; // procedure procedure N_CMDecodeFPCBStates

//******************************************************** N_CMSetFootPedal ***
// Choose needed Foot Pedal and  it's params (if needed) in dialog
//
//     Parameters
// Result - True if Foot Pedal related info was changed in N_CurMemIni
//
function N_CMSetFootPedal(): Boolean;
begin
  with TN_CMFPedalSetupForm.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    Result := ShowModal() = mrOK;
  end; // with TN_CMFPedalSetupForm.Create( Application ) do
end; // function N_CMSetFootPedal

//***************************************************** N_CMOpenFPCBLogFile ***
// Open Log for given Device
//
//     Parameters
// ADevInd   - given Device Index
//
procedure N_CMOpenFPCBLogFile( ADevInd: integer );
var
  ResCode, LogMaxSize, LogMaxDays, LogDetails: integer;
  LogFullNameA: AnsiString;
begin
  LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
  LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
  LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );

  if ADevInd = N_FPCB_None then
  begin

  end else if ADevInd = N_FPCB_MultiCam then // MultiCam
  begin
    LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'MultiCam.txt' );

    if Assigned(N_FPCBObj.FPCBMultiCamOpenLogFile) then
    begin
      ResCode := N_FPCBObj.FPCBMultiCamOpenLogFile( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

      if ResCode = 0 then
        N_Dump1Str( 'N_FPCBObj.FPCBMultiCamOpenLogFile Error - ' + String(LogFullNameA) );
    end;

  end else if ADevInd = N_FPCB_DUPCS then // Planmeca Compact Serial
  begin
    LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'PlanmecaSerial.txt' );

    if Assigned(N_FPCBObj.FPCBPCSOpenLogFile) then
    begin
      ResCode := N_FPCBObj.FPCBPCSOpenLogFile( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

      if ResCode = 0 then
        N_Dump1Str( 'N_FPCBObj.FPCBPCSOpenLogFile Error - ' + String(LogFullNameA) );
    end;
  end;

end; // procedure procedure N_CMOpenFPCBLogFile

//***************************************************** N_CMSInitDentalUnit ***
// Init Dental Unit
//
procedure N_CMSInitDentalUnit();
var
  ResCode: integer;
begin
  with N_FPCBObj do
  begin
    FPCBDUInd      := N_MemIniToInt(     'CMS_Main', 'DentalUnitDevInd', N_FPCB_None );
    FPCBDUProfName := N_MemIniToString(  'CMS_Main', 'DentalUnitProfName', 'None' );
    FPCBDUCOMPort  := N_MemIniToInt( 'CMS_UserMain', 'DentalUnitCOMPort', 1 );
    FPCBDUUseKeyboard := N_MemIniToBool( 'CMS_UserDeb', 'UseKeyboardForDentalUnit', False );
    FPCBDUUseKeyboard := N_MemIniToBool( 'CMS_UserDeb', 'UseKeyboardForDentalUnit', True ); // for debug

    N_Dump1Str( Format( 'Init Dental Unit: "%s" %d %d %s', [FPCBDUProfName,FPCBDUInd,FPCBDUCOMPort,N_B2S(FPCBDUUseKeyboard)] ) );

    if FPCBDUInd <> N_FPCB_None then // Initialize Dental Unit
    begin
      ResCode := FPCBLoadDLL( FPCBDUInd );
      if ResCode <> 0 then // some errors
      begin
        FPCBDUInd := N_FPCB_None;
        FPCBUnloadDLL( FPCBDUInd );
      end; // if ResCode <> 0 then // some errors
    end; // if FPCBDUInd <> N_FPCB_None then // Initialize Dental Unit

  end; // with N_FPCBObj do
end; // procedure N_CMSInitDentalUnit

//******************************************************* N_CMDentUnitState ***
// Get Dental Unit State
//
//     Parameters
// Result - ''     - (Empty String) Dental Unit is used (should be monitored)
//          'None' -  Dental Unit is NOT used
//          ProfileName -  ProfileName should be activated
//
function N_CMDentUnitState(): String;
var
  i, ResCode, BlockEmulatorKeys: integer;
begin
  with N_FPCBObj do
  begin
    Result := 'None';
    if FPCBDUInd = N_FPCB_None then Exit;

    if FPCBDUInd = N_FPCB_DUPCS then // Dental Unit - Planmeca Compact Serial
    begin
      if FPCBDUUseKeyboard then BlockEmulatorKeys := 0
                           else BlockEmulatorKeys := 1;

      // if FPCBDUUseKeyboard=True then numeric keys are used:

      ResCode := FPCBPCSGetState( BlockEmulatorKeys );

      if ResCode = N_eCAMERA_TAKEN then // =3
      begin
        Result := FPCBDUProfName;
        N_Dump1Str( 'Planmeca Compact Serial: eCAMERA_TAKEN ' + Result );
      end else
        Result := '';
    end; // if FPCBDUInd = N_FPCB_DUPCS then // Dental Unit - Planmeca Compact Serial

    if FPCBDUInd = N_FPCB_DUSirona then // Dental Unit - Sirona
    begin
      for i := 0 to 14 do
      begin
        ResCode := N_FPCBObj.FPCBSironaGetDeviceStateInMapView( i );
        if ResCode <> 0 then
          N_Dump1Str( Format( 'Sirona i=%d', [i] ) );
      end;
    end; // if FPCBDUInd = N_FPCB_DUSirona then // Dental Unit - Sirona

  end; // with N_FPCBObj do
end; // function N_CMDentUnitState

//   Emulation mode keys:
// N_FPCB_Delcom     - 4-Error=-1, 5-Error=-2, 6-Key Pressed
// N_FPCB_Serial     - 5-Key0 Pressed, 6-Key1 Pressed
// N_FPCB_SoproTouch - 7-Error=-1, 8-Error=-2, 9-Key Pressed
// N_FPCB_SchickUSB  - 7-Error=-1, 8-Error=-2, 9-Key Pressed
// N_FPCB_Winus100D  - 7-Error=-1, 8-Error=-2, 9-Key Pressed
// N_FPCB_Win100DBDA - 7-Error=-1, 8-Error=-2, 9-Key Pressed
// N_FPCB_DUPCS      - 1-Save_and_Unfreeze, 2-Freeze/Unfreeze_Toggle, 3-Camera_taken, 4-Camera_returned

Initialization
//  N_FPCBObj := TN_FPCBObj.Create;

Finalization
  N_FPCBObj.Free;

{************* Dental Units architecture
Это устройства (зубоврачебные кресла) позволюят включить-выключить видео камеру
и сделать снимок этой камерой, нажав на кнопку. Т.е. они должны отрбатывать
четыре (пока) события:
- N_DU_CAMERA_TAKEN           - включить камеру (показать соответствующую видео форму)
- N_DU_CAMERA_RETURNED        - выключить камеру (закрыть соответствующую видео форму)
- N_DU_FREEZE_UNFREEZE_TOGGLE - заморозить-продолжить живое видео
- N_DU_SAVE_AND_UNFREEZE      - сохранить кадр и продолжить живое видео

В массве объектов FPCBDevices эти устройства могут быть в любом месте и должны
поддерживать все методы TN_FPCBObj.

Эти устройства должны быть полность инициализированы в FPCBLoadDLL (т.е. чтобы
можно было звать N_CMDentUnitState сразу после FPCBLoadDLL)

}//*********** End of Dental Units architecture

end.
