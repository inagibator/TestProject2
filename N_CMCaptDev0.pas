Unit N_CMCaptDev0;
// Common useful functions
// 2013.01.03 Added USB functions by Valery Ovechkin
// 2014.01.10 Added procedure ShowCriticalError by Valery Ovechkin
// 2014.02.07 Fixed function ProcessExists by Valery Ovechkin
// 2014.02.07 Added function WaitProcess by Valery Ovechkin
// 2014.02.10 Added functions FileToArr, ArrToParams, GetParamValue by Valery Ovechkin
// 2014.02.21 Added function GetBetween and some auxilliary functions for it by Valery Ovechkin
// 2014.02.21 Fixed function ProcessExists by Valery Ovechkin
// 2014.03.20 Added Multithreading functions by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.04.28 Changed 'class( TObject )' to 'record' ( line 83 ) by Valery Ovechkin
// 2014.07.03 Thread Code redesign by Alex Kovalev
// 2014.08.21 XML Processing by Valery Ovechkin
// 2014.08.22 Standartization by Valery Ovechkin
// 2014.09.15 N_CMV_GetParamFromSL added by Valery Ovechkin
// 2014.09.15 functions 'N_CMV_SLToFile', 'N_CMV_FileToSL' added by Valery Ovechkin
// 2014.09.15 function 'N_CMV_FileToArr' optimized by Valery Ovechkin
// 2014.09.15 Fixed work with files ( 'i/o 32' erros, etc. ) by Valery Ovechkin

interface

uses
  SysUtils, Windows, Classes, Messages, Forms, StdCtrls, Dialogs, Graphics,
  TlHelp32, Registry, ShlObj, MSXML, ActiveX,
  K_CM0, K_CLib0,
  N_CM1, N_Types, N_Lib0;

// Fnctions parameter types for detailed call log
type TN_CMV_FuncParam = record
  name, valueBefore, valueAfter: String;
  pChild: Array of Pointer;
end;

type TNP_CMV_FuncParam = ^TN_CMV_FuncParam;
type TN_CMV_FuncParams = Array of TN_CMV_FuncParam;

type TN_CMV_ParamPair = record
  name, value: String;
end;

type TN_CMV_ParamPairs = Array of TN_CMV_ParamPair;

// USB events types
type TN_CMV_USBEventType = ( USBVoid, USBPlug, USBUnplug ); // USB event type

TN_CMV_USBEvent = record
  EventType: TN_CMV_USBEventType; // event type
  DevVid:    String;        // VID
  DevPid:    String;        // PID
end;

TNP_CMV_DevBroadcastHdr  = ^TN_CMV_DEV_BROADCAST_HDR;

TN_CMV_DEV_BROADCAST_HDR = packed record
  dbch_size: DWORD;
  dbch_devicetype: DWORD;
  dbch_reserved: DWORD;
end;

TNP_CMV_DevBroadcastDeviceInterface  = ^TN_CMV_DEV_BROADCAST_DEVICEINTERFACE;

TN_CMV_DEV_BROADCAST_DEVICEINTERFACE = record // whole device info
  dbcc_size: DWORD;
  dbcc_devicetype: DWORD;
  dbcc_reserved: DWORD;
  dbcc_classguid: TGUID;
  dbcc_name: array[0..254] of char;
end;

// Threads Types
type
  TN_CMV_ThreadState = (
    tsIdle,
    tsOpen,
    tsPause,
    tsWork,
    tsEnd
  );

  TN_CMV_UniThreadProc = procedure();
  TN_CMV_UniThread = class;

  TN_CMV_UniThreadItem = class( TThread )
  private
  protected
    procedure Execute; override;
  public
    Ctrl:     TN_CMV_UniThread;
    procedure N_CMV_SyncProcObj( APrcObj: TN_ProcObj );
    function  N_CMV_IsTerminated( ) : Boolean;
    procedure N_CMV_OnTerminate ( ASender : TObject );
  end;

//  {$IFDEF VER150} // Delphi 7
//  {$ENDIF VER150}

  TN_CMV_UniThread = class( TObject )
    Thread: TN_CMV_UniThreadItem;
    Proc:   TN_CMV_UniThreadProc;
    State:  TN_CMV_ThreadState;
    constructor Create(); 
    procedure N_CMV_Init    ( UserProc: TN_CMV_UniThreadProc );
    procedure N_CMV_SetState( ResumeWork: Boolean );
    procedure N_CMV_Free    ();
  end;

// types for imported functions

// Planmeca
type TN_CMV_stdcallInt2Func3Int2_PACharPInt2 = function ( AInt2_1, AInt2_2, AInt2_3: TN_Int2; APChar: PAnsiChar; APInt2: TN_PInt2 ): TN_Int2; stdcall;
// Duerr
type TN_CMV_cdeclIntFunc2Int_2PAChar = function( AInt: Integer; APChar1, APChar2: PAnsiChar ): Integer;cdecl;
// E2V
type TN_CMV_cdeclIntFuncPACharInt        = function ( APChar: PAnsiChar; AInt: Integer ): Integer; cdecl;
type TN_CMV_cdeclProcPACharInt           = procedure( APChar: PAnsiChar; AInt: Integer ); cdecl;
type TN_CMV_cdeclIntFuncPACharPIntDWORD  = function ( APChar: PAnsiChar; APInt: PInteger; ADWORD: DWORD ): Integer; cdecl;
type TN_CMV_cdeclIntFuncPACharPtr        = function ( APChar: PAnsiChar; APtr: Pointer ): Integer; cdecl;
type TN_CMV_cdeclIntFuncPACharPPtr       = function ( APChar: PAnsiChar; APPtr: TN_PPointer ): Integer; cdecl;
type TN_CMV_cdeclIntFuncPtr              = function ( APtr: Pointer ): Integer; cdecl;
type TN_CMV_cdeclIntFunc2PtrInt          = function ( APtr1, APtr2: Pointer; AInt: Integer ): Integer; cdecl;
type TN_CMV_cdeclIntFuncPtrInt           = function ( APtr: Pointer; AInt: Integer ): Integer; cdecl;
type TN_CMV_cdeclIntFuncPtrPInt          = function ( APtr: Pointer; APInt: PInteger ): Integer; cdecl;
type TN_CMV_cdeclIntFuncPtrIntPInt       = function ( APtr: Pointer; AInt: Integer; APInt: PInteger ): Integer; cdecl;
type TN_CMV_cdeclIntFuncPtrPAChar        = function ( APtr: Pointer; APChar: PAnsiChar ): Integer; cdecl;
type TN_CMV_cdeclIntFuncPtrByteInt       = function ( APtr: Pointer; APByte: PByte; AInt: Integer ): Integer; cdecl;
type TN_CMV_cdeclIntFuncPtrPACharInt     = function ( APtr: Pointer; APChar: PAnsiChar; AInt: Integer ): Integer; cdecl;
type TN_CMV_cdeclIntFuncPtrByteIntPtrInt = function ( APtr1: Pointer; APByte: PByte; AInt: Integer; APtr2: Pointer; AInt2: Integer ): Integer; cdecl;
type TN_CMV_cdeclProcPtrInt              = procedure( APtr: Pointer; AInt: Integer ); cdecl;
type TN_CMV_cdeclIntFunc2PACharInt       = function ( APAChar1, APAChar2: PAnsiChar; AInt: Integer ): Integer; cdecl;

// Gendex
type TN_CMV_cdeclProcInt2            = procedure( AInt2: TN_Int2 ); cdecl;
type TN_CMV_cdeclIntFuncPInt         = function ( APInt: PInteger ): Integer; cdecl;
type TN_CMV_cdeclIntFuncInt2         = function ( AInt2: TN_Int2 ): Integer; cdecl;
type TN_CMV_cdeclPWCharFuncVoid      = function (): PWChar; cdecl;
type TN_CMV_cdeclPWCharFuncInt2      = function ( AInt2: TN_Int2 ): PWChar; cdecl;
type TN_CMV_cdeclDblFuncVoid         = function (): Double; cdecl;
type TN_CMV_cdeclIntFunc2PWChar6PInt = function ( APWChar1, APWChar2: PWChar; APInt1, APInt2, APInt3, APInt4, APInt5, APInt6: PInteger ): Integer; cdecl;
type TN_CMV_cdeclIntFunc2PIntPWChar  = function ( APInt1, APInt2: PInteger; APWChar: PWChar ): Integer; cdecl;

// CSH
type TN_CMV_cdeclPtrFuncPtr           = function ( APtr: Pointer ): Pointer;cdecl;
type TN_CMV_cdeclPACharPPACharFuncInt = function ( APAChar: PAnsiChar; APPAChar: PPAnsiChar ): Integer;cdecl;
type TN_CMV_cdeclProcPtr              = procedure( APtr: Pointer );cdecl;
type TN_CMV_cdeclPACharFuncPtr        = function ( APtr: Pointer ): PAnsiChar;cdecl;
type TN_CMV_cdeclProcPtrPAChar        = procedure( APtr: Pointer; APAChar: PAnsiChar );cdecl;

// common useful function
function  N_CMV_CheckStrParam       ( AParam, AValue: String; ASep: Char = ',' ): Boolean;
function  N_CMV_TrimNullsRight      ( AStr: String ): String;
procedure N_CMV_TifToBmp            ( ATifPath, ABmpPath: String );
function  N_CMV_LoadFunc            ( ACDSDllHandle: THandle; var APFunc: Pointer; AFuncName: AnsiString ): Boolean;
function  N_CMV_CreateProcess       ( AExecutableFilePath: String ): Boolean;
function  N_CMV_ProcessExists       ( AProcessName: String ): Boolean;
function  N_CMV_WaitProcess         ( AStart: Boolean; APath: String; ATimeout: Integer ): Boolean;
function  N_CMV_GetRegistryKey      ( ARootKey: DWORD; APath: String; AName: String ): String;
function  N_CMV_CheckBoxToStr       ( ACheckBox: TCheckBox ): String;
function  N_CMV_ComboBoxToStr       ( AComboBox: TComboBox; ATwoDigits: Boolean = False ): String;
function  N_CMV_IntToStrNorm        ( AValue, ACount: Integer ): String;
function  N_CMV_GetWrkDir           (): String;
function  N_CMV_GetLogDir           (): String;
function  N_CMV_FileExistsFromList  ( AFileNames: TN_SArray ): Boolean;
function  N_CMV_GetNewNum           ( APrefixes, APostFixes: TN_SArray; ANumSize: Integer ): String;
procedure N_CMV_DoExtendedLog       ( AFuncName, ARes, ATimeBefore, ATimeAfter, ADuration: String; AFuncParams: TN_CMV_FuncParams; ADir, AFileName: String; AClearAtTheEnd: Boolean );
function  N_CMV_dtStr               (): String;
function  N_CMV_GetFolderDialog     ( AHandle: Integer; ACaption: String; var AStrFolder: String ): Boolean;
function  N_CMV_CopyFile            ( ASource, Atarget, ALogStr: String ): Boolean;
procedure N_CMV_ShowCriticalError   ( ADevName, AErrorText: String );
function  N_CMV_SLToFile            ( AList: TStringList; AFileName: String ): Boolean;
function  N_CMV_FileToSL            ( var AList: TStringList; AFileName: String ): Boolean;
function  N_CMV_FileToArr           ( var AArr: TN_SArray; AFileName: String ): Boolean;
procedure N_CMV_ArrToParams         ( AArr: TN_SArray; var APar: TN_CMV_ParamPairs );
function  N_CMV_GetParamValue       ( APar: TN_CMV_ParamPairs; AParName: String; ACaseSens: Boolean = False ): String;
function  N_CMV_GetBetween          ( AStr: String; ABegins, AEnds: TN_SArray; ACaseSens: Boolean; AAnyEnd: Boolean ): String;
function  N_CMV_GetParamFromSL      ( AList: TStringList; AParamName: String; ACaseSens: Boolean = False; ASeparator: String = '=' ): String;

// USB const
const
  N_CMV_GUID_DEVINTERFACE_USB_DEVICE: TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';
  N_CMV_DBT_DEVICEARRIVAL          = $8000;     // arrive
  N_CMV_DBT_DEVICEREMOVECOMPLETE   = $8004;     // remove
  N_CMV_DBT_DEVTYP_DEVICEINTERFACE = $00000005;
  N_CMV_ThreadRun  = TRUE;
  N_CMV_ThreadStop = FALSE;

// USB functions
  function N_CMV_USBReg     ( AHWND: HWND; var APtr: Pointer ): Boolean;
  function N_CMV_USBUnreg   ( var APtr: Pointer ): Boolean;
  function N_CMV_USBGetInfo ( AMsg: TMessage ): TN_CMV_USBEvent;

// Thread functions
procedure N_CMV_WaitThreadEnd( AThread: TN_CMV_UniThread );

// XML API
// XML
type TN_CMV_XML = IXMLDOMDocument;

// XML Node
type TN_CMV_XMLNode = IXMLDOMNode;

// XML Node
type TN_CMV_XMLNodes = IXMLDOMNodeList;

// XML Attributes
type TN_CMV_XMLAttr = IXMLDOMNamedNodeMap;

// XML request tag
type TN_CMV_XMLRequestTag = record
   name: String;
   position: Integer;
end;

// XML request
type TN_CMV_XMLRequest = record
   path: Array of TN_CMV_XMLRequestTag;
   tag:  String;
end;

// XML response attribute
type TN_CMV_XMLResponseAttr = record
   name, value: String;
end;

// XML response tag
type TN_CMV_XMLResponseTag = record
   text: String;
   attr: Array of TN_CMV_XMLResponseAttr;
end;

// XML response
type TN_CMV_XMLResponse = Array of TN_CMV_XMLResponseTag;

function N_CMV_XMLDocToResult ( ADoc : TN_CMV_XML; AReq: TN_CMV_XMLRequest; var ARes: TN_CMV_XMLResponse ): Boolean;
function N_CMV_XMLDocLoad     ( ASource: String; FromFile: Boolean ): TN_CMV_XML;
function N_CMV_XMLGet         ( APos: Integer; Attr: String; ARes: TN_CMV_XMLResponse ): String;

implementation

//************************************************************** StrToArray ***
// add not empty string to parameters array
//
//     Parameters
// AArr - parameters arrayt to add
// AStr - parameters string
//
procedure StrToArrayAdd( var AArr: TN_SArray; AStr: String );
var
  c: Integer;
begin

  if ( '' <> AStr ) then
  begin
    c := length( AArr );
    SetLength( AArr, c + 1 );
    AArr[c] := AStr;
  end; // if ( '' <> AStr ) then

end; // procedure StrToArrayAdd

//************************************************************** StrToArray ***
// fill parameters array from string
//
//     Parameters
//  AArr - parameters arrayt to fill
//  AStr - parameters string
//  ASep - parameters separator, ',' by default
//
procedure StrToArray( var AArr: TN_SArray; AStr: String; ASep: Char = ',' );
var
  p, len: Integer;
  t: String;
begin
  SetLength( AArr, 0 ); // initialize array
  t := AStr;
  len := length( t );  // string length
  p := Pos( ASep, t );  // separator position

  while ( 0 < p ) do // while separator exists
  begin
    // try to add substring to array if it is not empty
    StrToArrayAdd( AArr, Trim( Copy( t, 1, p - 1 ) ) );
    len := len - p;
    t := Copy( t, p + 1, len );
    p := Pos( ASep, t );
  end; // while ( 0 < p ) do // while separator exists

  StrToArrayAdd( AArr, Trim( t ) ); // add the tail to array
end; // procedure StrToArray

//***************************************************** N_CMV_CheckStrParam ***
// check if value counters in parameters string
//
//     Parameters
// AParam - parameters string
// AValue - string for search in parameters
// ASep   - parameters separator, ',' by default
// Result - True if at least one parameter item = value, else False
//
function N_CMV_CheckStrParam( AParam, AValue: String; ASep: Char = ',' ): Boolean;
var
  c, i: Integer;
  arr: TN_SArray;
begin
  Result := True;
  StrToArray( arr, AParam, ASep ); // parse parameters string as array
  c := length( arr );

  for i := 0 to c - 1 do
  begin

    if ( AValue = arr[i] ) then // if value = parameter[i] - exit with success
      Exit;

  end; // for i := 0 to c - 1 do

  Result := False;
end; // function N_CMV_CheckStrParam

//**************************************************** N_CMV_TrimNullsRight ***
// correct string by triming null charactres
//
//     Parameters
//  AStr   - string
//  Result - corrected string without trailing '#0' characters
//
function N_CMV_TrimNullsRight( AStr: String ): String;
var
  p: Integer;
begin
  Result := AStr;
  p := Pos( #0, AStr );

  if ( p > 0 ) then
    Result := Copy( AStr, 1, p - 1 );

end; // function N_CMV_TrimNullsRight

//********************************************************** N_CMV_TifToBmp ***
// make BMP file from TIF file
//
//    Parameters
// ATifPath - path to TIF file
// ABmpPath - path to BMP file
//
procedure N_CMV_TifToBmp( ATifPath, ABmpPath: String );
{$IFDEF VER150} // Delphi 7
begin
  raise Exception.Create( 'No TWICImage in Delphi 7!' );
{$ELSE}         // Delphi 2010 or Higher
var
  Tif: TWICImage;
  Bmp: TBitmap;
begin
    Tif:= TWICImage.Create;
    Bmp:= TBitmap.Create;

    Tif.LoadFromFile( ATifPath );
    Bmp.Assign( Tif );
    bmp.SaveToFile( ABmpPath );

    Bmp.Free;
    Tif.Free;
{$ENDIF VER150}
end; // procedure N_CMV_TifToBmp

//********************************************************** N_CMV_LoadFunc ***
// Common function for loading functions from DLL
//
//    Parameters
// ACDSDllHandle - DLL Handle
// APFunc        - function pointer
// AFuncName     - function name to import from DLL
// Result        - pointer to imported function (nil if function not found)
//
function N_CMV_LoadFunc( ACDSDllHandle: THandle; var APFunc: Pointer; AFuncName: AnsiString ): Boolean;
begin
  Result := False;

  if ( ACDSDllHandle = 0 ) then // if DLL not found
    exit;

  // get function address
  APFunc := GetProcAddress( ACDSDllHandle, @AFuncName[1] );

  if ( APFunc = nil ) then // function not found in DLL
  begin
    N_Dump1Str( 'Trident >> Function "' + N_AnsiToString (AFuncName ) + '" not loaded from DLL' );
    exit;
  end; // if ( APFunc = nil ) then // function not found in DLL

  Result := True;
end; // function N_CMV_LoadFunc

//***************************************************** N_CMV_CreateProcess ***
// Start executable file by path - AExecutableFilePath
//
//    Parameters
// AExecutableFilePath - full path to executable file with command line
// Result - True if success, else False ( if process did not created )
//
function N_CMV_CreateProcess( AExecutableFilePath: String ): Boolean;
var
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
begin
  FillMemory( @StartupInfo, SizeOf( StartupInfo ), 0 );
  StartupInfo.cb := SizeOf( StartupInfo );

  Result := CreateProcess( nil,
                           PChar( AExecutableFilePath ),
                           nil, nil, False,
                           NORMAL_PRIORITY_CLASS, nil, nil,
                           StartupInfo, ProcessInfo );

  CloseHandle( ProcessInfo.hProcess );
  CloseHandle( ProcessInfo.hThread );
end; // function N_CMV_CreateProcess

//***************************************************** N_CMV_ProcessExists ***
// Check if process exists
//
//    Parameters
// ProcessName - full path to process executable file
// Result      - True if process exists, else False
//
function N_CMV_ProcessExists( AProcessName: String ): Boolean;
var
  ProcessHandle, ModuleHandle: Cardinal;
  ProcessInfo:   PROCESSENTRY32;
  ModuleInfo:    MODULEENTRY32;
  ModuleExists:  Boolean;
  ProcessNameUp: String;
begin
  Result := False;
  ProcessNameUp := UpperCase( AProcessName );
  ProcessHandle := CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );

  if ( 0 = ProcessHandle ) then
    Exit;

  ProcessInfo.dwSize := sizeof( TPROCESSENTRY32 );

  if not Process32First( ProcessHandle, ProcessInfo ) then
    Exit;

  repeat
    ModuleHandle := CreateToolhelp32Snapshot( TH32CS_SNAPMODULE, ProcessInfo.th32ProcessID );

    if ( 0 = ModuleHandle ) then
    begin
      CloseHandle( ProcessHandle );
      Exit;
    end; // if ( 0 = ModuleHandle ) then

    ModuleInfo.dwSize := sizeof( TMODULEENTRY32 );
    ModuleExists := Module32First( ModuleHandle, ModuleInfo );

    while ModuleExists do
    begin

      if ( ProcessNameUp = UpperCase( ModuleInfo.szExePath ) ) then
      begin
        Result := True;
        CloseHandle( ModuleHandle );
        CloseHandle( ProcessHandle );
        Exit;
      end; // if ( ProcessNameUp = UpperCase( ModuleInfo.szExePath ) ) then

      ModuleExists := Module32Next( ModuleHandle, ModuleInfo );
    end; // while ModuleExists do

    CloseHandle( ModuleHandle );
  until not Process32Next( ProcessHandle, ProcessInfo );

  CloseHandle( ProcessHandle );
end; // function N_CMV_ProcessExists

//******************************************************* N_CMV_WaitProcess ***
// check process existing during timeout
//
//    Parameters
// AStart   - if True - wait for starting, else for closing process
// APath    - full path to process executable file
// ATimeout - timeout to check condition, timeout < 0 - means infinity
// Result   - True if process condition is right, else False
//
function N_CMV_WaitProcess( AStart: Boolean; APath: String; ATimeout: Integer ): Boolean;
var
  t1, t2: Cardinal;
begin
  Result := ( AStart = ( N_CMV_ProcessExists( APath ) ) );

  if Result then
    Exit;

  t1 := GetTickCount();
  t2 := t1;

  // wait for existing condition or timeout exceeded
  while ( ( not Result ) and ( ( 0 > ATimeout ) or ( t1 + Cardinal( ATimeout ) >= t2 ) ) ) do
  begin
    t2 := GetTickCount();

    if ( t1 > t2 ) then // Integer overflow
      t1 := 0;

    Result := ( AStart = ( N_CMV_ProcessExists( APath ) ) );
  end; // while ( ( not Result ) and ( ( 0 > ATimeout ) or ( t1 + Cardinal( ATimeout ) >= t2 ) ) ) do

end; // function N_CMV_WaitProcess

//**************************************************** N_CMV_GetRegistryKey ***
// Get Registry Key value
//
//    Parameters
// ARootKey - Root Key (e.g. HKEY_LOCAL_MACHINE)
// APath    - path to Key
// AName    - Key name
// Result   - Key value or '' if Key is not exists
//
function N_CMV_GetRegistryKey( ARootKey: DWORD; APath: String; AName: String ): String;
var
  RegObject: TRegistry;
begin
  Result := ''; // default value
  RegObject := TRegistry.Create(KEY_READ); // create Registry object
  RegObject.RootKey := ARootKey;    // Set Root Key

  if not RegObject.OpenKey( APath, False ) then // try to open
  begin
    RegObject.Free; // free Registry object
    Exit;
  end; // if not RegObject.OpenKey( APath, False ) then // try to open

  Result := RegObject.ReadString( AName ); // get Key value
  RegObject.CloseKey; // close Key
  RegObject.Free;   // free Registry object
end; // function N_CMV_GetRegistryKey

//***************************************************** N_CMV_CheckBoxToStr ***
// Convert CheckBox state to string
//
//    Parameters
// ACheckBox - CheckBox pointer
// Result    - "1" if Checked, else "0"
//
function N_CMV_CheckBoxToStr( ACheckBox: TCheckBox ): String;
begin
   Result := '0'; // default value = 0 (unchecked)

   if ACheckBox.Checked then
      Result := '1'; // value = 1 if checked

end; // function N_CMV_CheckBoxToStr

//***************************************************** N_CMV_ComboBoxToStr ***
// Convert ComboBox state to string
//
//    Parameters
// AComboBox  - ComboBox pointer
// ATwoDigits - add "0" before Result
// Result     - String( combobox ItemIndex )
//
function N_CMV_ComboBoxToStr( AComboBox: TComboBox; ATwoDigits: Boolean = False ): String;
begin
   Result := IntToStr( AComboBox.ItemIndex );

   if ( ATwoDigits and ( 10 > AComboBox.ItemIndex ) ) then
     Result := '0' + Result;

end; // function N_CMV_ComboBoxToStr

//****************************************************** N_CMV_IntToStrNorm ***
// IntToStr + left nulls if needed
//
//    Parameters
// AValue - Integer
// ACount - size of string
// Result - String
//
function N_CMV_IntToStrNorm( AValue, ACount: Integer ): String;
var
 i, len: Integer;
begin
  Result := IntToStr( AValue );
  len := Length( Result );

  for i := 1 to ( ACount - len ) do
    Result := '0' + Result;

end; // function N_CMV_IntToStrNorm

//********************************************************* N_CMV_GetWrkDir ***
// Get Working Directory 'CMSWrkFiles' and create it if not exists
//
//    Parameters
// Result    - Directory path
//
function N_CMV_GetWrkDir(): String;
begin
  Result := K_GetDirPath( 'CMSWrkFiles' );
  K_ForceDirPath( Result );
end; // function N_CMV_GetWrkDir

//********************************************************* N_CMV_GetLogDir ***
// Get Log Directory 'CMSLogFiles' and create it if not exists
//
//    Parameters
// Result    - Directory path
//
function N_CMV_GetLogDir(): String;
begin
  Result := K_GetDirPath( 'CMSLogFiles' );
  K_ForceDirPath( Result );
end; // function N_CMV_GetLogDir

//************************************************ N_CMV_FileExistsFromList ***
// Check if any file from list exists
//
//    Parameters
// AFileNames - file names lists
// Result     - True if at least 1 file exists
//
function N_CMV_FileExistsFromList( AFileNames: TN_SArray ): Boolean;
var
  i, len: Integer;
begin
  Result := True;
  len := Length( AFileNames );

  for i := 0 to len - 1 do
  begin

    if FileExists( AFileNames[i] ) then
      Exit;

  end; // for i := 0 to len - 1 do

  Result := False;
end; // function N_CMV_FileExistsFromList

//********************************************************* N_CMV_GetNewNum ***
// Generate unique number for writing files
//
//    Parameters
// APrefixes  - file prefixes lists
// APostFixes - file postfixes lists
// ANumSize   - length of number, e.g. if NumSize = 6 than '123' -> '000123'
// Result     - desired number normalized by size
//
function N_CMV_GetNewNum( APrefixes, APostFixes: TN_SArray; ANumSize: Integer ): String;
var
  i, len, num: Integer;
  FileNames: TN_SArray;
begin
  Result := '';
  num := 1;
  len := Length( APrefixes );

  if ( len <> Length( APostFixes ) ) then // prefix count <> postfix count
  begin
    K_CMShowMessageDlg( 'GetNewNum error', mtError);
    Exit;
  end; // if ( len <> Length( PostFixes ) ) then // prefix count <> postfix count

  SetLength( FileNames, len );

  for i := 0 to len - 1 do
    FileNames[i] := APrefixes[i] + N_CMV_IntToStrNorm( num, ANumSize ) + APostFixes[i];

  while N_CMV_FileExistsFromList( FileNames ) do
  begin
    Inc( num );

    for i := 0 to len - 1 do
      FileNames[i] := APrefixes[i] + N_CMV_IntToStrNorm( num, ANumSize ) + APostFixes[i];

  end; // while N_CMV_FileExistsFromList( FileNames ) do

  Result := N_CMV_IntToStrNorm( num, ANumSize );
end; // function N_CMV_GetNewNum

//***************************************************** ExtendedLogStrParam ***
// extended log function parameters
//
//    Parameters
// AParam  - function parameter
// APrefix - prefix
// Result  - string to log
//
function ExtendedLogStrParam( AParam: TNP_CMV_FuncParam; APrefix: String ): String;
var
  i, len: Integer;
begin
  len := Length( AParam.pChild );
  Result := APrefix + AParam.name;

  if ( len < 1 ) then
  begin
    Result := Result + ' = "' + AParam.valueBefore + '" => "' +
              AParam.valueAfter + '"' + #13#10;
  end
  else
  begin
    Result := Result + '{' + #13#10;

    for i := 0 to len - 1 do
      Result := Result + ExtendedLogStrParam( AParam.pChild[i], APrefix + '  ' );

    Result := Result + APrefix + '}' + #13#10;
  end;

end; // function ExtendedLogStrParam

//********************************************************** ExtendedLogStr ***
// extended log string
//
//    Parameters
// AFuncName   - function name
// ARes        - function result
// ATimeBefore - datetime before function call
// ATimeAfter  - datetime after function call
// ADuration   - time taken for function call in milliseconds
// AFuncParams - function parameters list
// Result      - string to log
//
function ExtendedLogStr( AFuncName, ARes, ATimeBefore, ATimeAfter, ADuration: String;
                         AFuncParams: TN_CMV_FuncParams ): String;
var
  i, len: Integer;
begin
  Result := AFuncName + ':' + #13#10 + #13#10 +
  'Time Before = ' + ATimeBefore + #13#10 +
  'Time After = ' + ATimeAfter + #13#10 +
  'Duration = ' + ADuration + #13#10 + #13#10 +
  'Result = ' + ARes + #13#10 + #13#10 +
  'Params:' + #13#10;

  len := Length( AFuncParams );

  for i := 0 to len - 1 do
  begin
    Result := Result + ExtendedLogStrParam( @AFuncParams[i], '    ' );
  end;

  Result := Result + #13#10;
  Result := Result + '------------------------------' + #13#10;
end; // function ExtendedLogStr

//******************************************************** ClearExtendedLog ***
// clear extended log object for current parameter
//
//    Parameters
// AParam - function parameter
//
procedure ClearExtendedLog( AParam: TNP_CMV_FuncParam );
var
  i, len: Integer;
begin

  if ( AParam = nil ) then
    Exit;

  len := Length( AParam.pChild );

  for i := 0 to len - 1 do
    ClearExtendedLog( AParam.pChild[i] );

  Dispose( AParam );
end; // procedure ClearExtendedLog

//******************************************************* ClearExtendedLogs ***
// clear extended log object
//
//    Parameters
// AParams - function parameters list
//
procedure ClearExtendedLogs( var AParams: TN_CMV_FuncParams );
var
  i, j, len, len2: Integer;
begin
  len := Length( AParams );

  for i := 0 to len - 1 do
  begin
    len2 := Length( AParams[i].pChild );

    for j := 0 to len2 - 1 do
      ClearExtendedLog( AParams[i].pChild[j] );

  end; // for i := 0 to len - 1 do

  SetLength( AParams, 0 );
end; // procedure ClearExtendedLogs

//***************************************************** N_CMV_DoExtendedLog ***
// write extended log string to file
//
//    Parameters
// AFuncName      - function name
// ARes           - function result
// ATimeBefore    - datetime before function call
// ATimeAfter     - datetime after function call
// ADuration      - time taken for function call in milliseconds
// AFuncParams    - function parameters list
// ADir           - log directory
// AFileName      - log file name
// AClearAtTheEnd - clear log at the end
//
procedure N_CMV_DoExtendedLog( AFuncName, ARes, ATimeBefore, ATimeAfter, ADuration: String;
                               AFuncParams: TN_CMV_FuncParams;
                               ADir, AFileName: String; AClearAtTheEnd : Boolean );
begin

  if not DirectoryExists( ADir ) then
    CreateDir( ADir );

  N_AddStrToFile2( N_StringToAnsi( ExtendedLogStr(
                   AFuncName, ARes, ATimeBefore, ATimeAfter, ADuration,
                   AFuncParams ) ),
                   N_StringToAnsi( ADir + '\' + AFileName ) );

  if AClearAtTheEnd then
    ClearExtendedLogs( AFuncParams );

end; // procedure N_CMV_DoExtendedLog

//************************************************************* N_CMV_dtStr ***
// Get current datetime as string in needed format
//
//    Parameters
// Result - Current datetime as string formatted
//
function N_CMV_dtStr(): String;
var
  year, month, day, hour, minute, sec, msec: WORD;
  dt: TDateTime;
begin
  dt := Now();
  DecodeDate( dt, year, month, day );
  DecodeTime( dt, hour, minute, sec, msec );
  Result := IntToStr( year )          + '.' +
            N_CMV_IntToStrNorm( month,  2 ) + '.' +
            N_CMV_IntToStrNorm( day,    2 ) + ' ' +
            N_CMV_IntToStrNorm( hour,   2 ) + ':' +
            N_CMV_IntToStrNorm( minute, 2 ) + ':' +
            N_CMV_IntToStrNorm( sec,    2 ) + '.' +
            N_CMV_IntToStrNorm( msec,   3 );
end; // function N_CMV_dtStr

//****************************************************** BrowseCallbackProc ***
// Callback function for folder browser
//
//    Parameters
// AHWND   - parent window handle
// AMsg    - message type
// ALParam - LPARAM
// ALPData - LPARAM
// Result  - error code
//
function BrowseCallbackProc( AHWND: HWND; AMsg: UINT; ALParam: LPARAM; ALPData: LPARAM ): Integer; stdcall;
begin
  Result := 0;
end; // function BrowseCallbackProc

//******************************************************** GetCorrectedPath ***
// Get folder path without "\" at the last char
//
//    Parameters
// APath  - folder path
// Result - corrected folder path without "\"
//
function GetCorrectedPath( APath: String ): String;
var
  len: Integer;
begin
  Result := APath;
  len := Length( APath );

  if ( len > 0 ) then
    if ( APath[len] = '\' ) then
      Result := Copy( APath, 1, len - 1 );

end; // function GetCorrectedPath

//*************************************************** N_CMV_GetFolderDialog ***
// Launch folder browser
//
//    Parameters
// AHandle    - parent window handle
// ACaption   - folder browser caption
// AStrFolder - folder name
// Result     - True if success
//
function N_CMV_GetFolderDialog( AHandle: Integer; ACaption: String; var AStrFolder: String ): Boolean;
const
  BIF_STATUSTEXT       = $0004;
  BIF_NEWDIALOGSTYLE   = $0040;
  BIF_RETURNONLYFSDIRS = $0080;
  BIF_SHAREABLE        = $0100;
  BIF_USENEWUI         = BIF_EDITBOX or BIF_NEWDIALOGSTYLE;

var
  BrowseInfo: TBrowseInfo;
  ItemIDList: PItemIDList;
  JtemIDList: PItemIDList;
  Path:       String;
begin
  Result:= False;
  SetLength( Path, MAX_PATH );
  SHGetSpecialFolderLocation( AHandle, CSIDL_DRIVES, JtemIDList );

  with BrowseInfo do
  begin
    hwndOwner := GetActiveWindow;
    pidlRoot  := JtemIDList;
    SHGetSpecialFolderLocation( hwndOwner, CSIDL_DRIVES, JtemIDList );
    pszDisplayName := StrAlloc( MAX_PATH );
    lpszTitle      := @ACaption[1];
    lpfn           := BrowseCallbackProc;
    lParam         := LongInt( AStrFolder );
  end; // with BrowseInfo do

  ItemIDList := SHBrowseForFolder(BrowseInfo);

  if ( ItemIDList <> nil ) then
    if SHGetPathFromIDList( ItemIDList, @Path[1] ) then
    begin
      AStrFolder := GetCorrectedPath( N_CMV_TrimNullsRight( Path ) );
      Result    := True;
    end; // if SHGetPathFromIDList( ItemIDList, @Path[1] ) then

end; // function N_CMV_GetFolderDialog

//********************************************************** N_CMV_CopyFile ***
// Copy file and log if error happened whilst copy
//
//    Parameters
// ASource - source file name
// ATarget - destination file name
// ALogStr - string for log
// Result  - True if success
//
function N_CMV_CopyFile( ASource, ATarget, ALogStr: String ): Boolean;
begin
  Result := False;

  if not FileExists( ASource ) then
    Exit;

  if not CopyFile( @ASource[1], @ATarget[1], False ) then
  begin
    N_Dump1Str( ALogStr + ' "' + ASource + '" not copied' ) ;
    Exit;
  end; // if not CopyFile( @source[1], @target[1], False ) then

  Result := True;
end; // function N_CMV_CopyFile

//************************************************* N_CMV_ShowCriticalError ***
// Show error dialog by device name and error text
//
//     Parameters
// ADevName   - device name
// AErrorText - error description
//
procedure N_CMV_ShowCriticalError( ADevName, AErrorText: String );
var
  s: String;
begin
  s := AErrorText;

  if ( '' <> ADevName ) then
    s := ADevName + '>> Error : ' + s;

  K_CMShowMessageDlg( s, mtError );
end; // procedure N_CMV_ShowCriticalError

//********************************************************** N_CMV_SLToFile ***
// Write StringList To Text File
//
//    Parameters
// AList     - Source StringList
// AFileName - Target File Name
// Result    - True if success
//
function N_CMV_SLToFile( AList: TStringList; AFileName: String ): Boolean;
begin
  Result := False;

  if ( ( nil = AList ) ) then
    Exit;

  try
    AList.SaveToFile( AFileName ); // Save StringList to file
  except on e: Exception do
    Exit;
  end;

  Result := True;
end; // function N_CMV_SLToFile

//********************************************************** N_CMV_FileToSL ***
// Fill StringList from Text File
//
//    Parameters
// AList     - target StringList to be fullfilled
// AFileName - File Name
// Result    - True if success ( file exists and able for reading )
//
function N_CMV_FileToSL( var AList: TStringList; AFileName: String ): Boolean;
begin
  Result := False;

  if ( ( nil = AList ) or ( not FileExists( AFileName ) ) ) then
    Exit;

  try
    AList.LoadFromFile( AFileName ); // Load StringList from file
  except on e: Exception do
    Exit;
  end;

  Result := True;
end; // function N_CMV_FileToSL

//********************************************************* N_CMV_FileToArr ***
// Fill array from Text File
//
//    Parameters
// AArr      - target array to be fullfilled
// AFileName - File Name
// Result    - True if success ( file exists and able for reading )
//
function N_CMV_FileToArr( var AArr: TN_SArray; AFileName: String ): Boolean;
var
  SL: TStringList;
  i, cnt: Integer;
begin
  Result := FileExists( AFileName );
  cnt := 0;
  SetLength( AArr, cnt );

  if not Result then // if file not exists
    Exit;

  Result := False;
  SL := TStringList.Create();

  if ( nil = SL ) then
    Exit;

  Result := N_CMV_FileToSL( SL, AFileName );

  if Result then // Successfull file reading to SL
  begin
    cnt := SL.Count;
    SetLength( AArr, cnt );

    for i := 0 to cnt - 1 do // copy each SL item to result array
    begin
      AArr[i] := SL[i];
    end; // for i := 0 to cnt - 1 do // copy each SL item to result array

  end; // if Result then // Successfull file reading to SL

  if ( nil = SL ) then
    SL.Free;

end; // function N_CMV_FileToArr

//******************************************************* N_CMV_ArrToParams ***
// Fill parameters array ( name, value ) from usual string array
//
//    Parameters
// AArr - source string array
// APar - destination array of parameters pairs ( name, value )
//
procedure N_CMV_ArrToParams( AArr: TN_SArray; var APar: TN_CMV_ParamPairs );
var
  ArrLen, ParLen, i, SepPos, StrLen : Integer;
  s, ParName, ParValue: String;
begin
  ArrLen := Length( AArr );
  ParLen := Length( APar );

  for i := 0 to ArrLen - 1 do // parse array line by line
  begin
    s := Trim( AArr[i] );
    ParName  := '';
    ParValue := '';
    SepPos := Pos( '=', s );

    if ( 0 < SepPos ) then // separator found
    begin
      StrLen   := Length( s );
      ParName  := Trim( Copy( s, 1, SepPos - 1 ) );
      ParValue := Trim( Copy( s, SepPos + 1, StrLen - SepPos ) );

      if ( '' <> ParName ) then // param name is not empty
      begin
        inc( ParLen );
        SetLength( APar, ParLen );
        APar[ParLen - 1].name  := ParName;
        APar[ParLen - 1].value := ParValue;
      end; // if ( '' <> ParName ) then // param name is not empty

    end; // if ( 0 < SepPos ) then // separator found

  end; // for i := 0 to ArrLen - 1 do // parse array line by line

end; // procedure N_CMV_ArrToParams

//***************************************************** N_CMV_GetParamValue ***
// Find parameter's value by it's name
//
//    Parameters
// APar      - parameters array
// AParName  - parameters name
// ACaseSens - if True - case sensitive search
// Result    - parameters value
//
function N_CMV_GetParamValue( APar: TN_CMV_ParamPairs; AParName: String; ACaseSens: Boolean = False ): String;
var
  i, ParLen: Integer;
  nm: String;
begin
  Result := '';
  ParLen := Length( APar );

  for i := 0 to ParLen - 1 do // for each parameters pair
  begin
    nm := APar[i].name;

    // if parameter found by name and CaseSens mode
    if ( ( AParName = nm ) or
         ( ( not ACaseSens ) and ( UpperCase( AParName ) = UpperCase( nm ) ) ) ) then
    begin
      Result := APar[i].value;
      Exit;
    end;

  end; // for i := 0 to ParLen - 1 do // for each parameters pair

end; // function N_CMV_GetParamValue

//*************************************************************** GetStrPos ***
// Find substring, with parameter CaseSens, that differs from standard Pos
//
//     Parameters
// AStr       - string
// ASubStr    - substring
// ACaseSens  - If True - usual ( Pos ( subs, s ) ), else - another algorithm
// Result     - substring position in string if found, else - 0
//
function GetStrPos( AStr: String; ASubStr: String; ACaseSens: Boolean ): Integer;
var
  i, StrSz, SubStrSz: integer;
  UppStr, UppSubStr: String;
begin
  Result := 0;

  if ACaseSens then
  begin
    Result := Pos( ASubStr, AStr );
    Exit;
  end; // if CaseSens then

  StrSz    := Length( AStr );
  SubStrSz := Length( ASubStr );

  if ( ( StrSz < SubStrSz ) or ( 1 > SubStrSz ) ) then
    Exit;

  UppSubStr := UpperCase( ASubStr );

  for i := 1 to ( StrSz - SubStrSz ) + 1 do
  begin
    UppStr := UpperCase( Copy( AStr, i, SubStrSz ) );

    if ( UppStr = UppSubStr ) then // if equal
    begin
      Result := i;
      Exit;
    end; // if ( UppStr = UppSubStr ) then // if equal

  end; //for i := 1 to ( StrSz - SubStrSz ) + 1 do

end; // function GetStrPos

//********************************************************** GetFirstStrPos ***
// Find substring, with parameter CaseSens, that differs from standard Pos
//
//     Parameters
// AStr      - string
// AArr       - substrings array
// ACaseSens - case sensitive
// AArrPos   - output parameter, position in array
// AStrPos   - output parameter, position in string
//
procedure GetFirstStrPos( AStr: String; AArr: TN_SArray; ACaseSens: Boolean;
                          var AArrPos: Integer; var AStrPos: Integer );
var
  i, n, ArrLen: Integer;
begin
  AArrPos := -1;
  AStrPos := 0;
  ArrLen := Length( AArr );

  for i := 0 to ArrLen - 1 do
  begin
    n := GetStrPos( AStr, AArr[i], ACaseSens );

    if ( ( 0 < n ) and ( ( n < AStrPos ) or ( 1 > AStrPos ) ) ) then
    begin
      AArrPos := i;
      AStrPos := n;
    end; // if ( ( 0 < n ) and ( ( n < AStrPos ) or ( 1 > AStrPos ) ) ) then

  end; //for i := 0 to ArrLen - 1 do

end; // procedure GetFirstStrPos

//******************************************************** N_CMV_GetBetween ***
// Find value in string between one of begins and one of ends
//
//     Parameters
// AStr      - string
// ABegins   - array of begins
// AEnds     - array of ends
// ACaseSens - if True - case sensitive
// AAnyEnd   - if no ends found - return substr up to the end
// Result    - substring between, by default ''
//
function N_CMV_GetBetween( AStr: String; ABegins, AEnds: TN_SArray;
                           ACaseSens: Boolean; AAnyEnd: Boolean ): String;
var
  bCnt, eCnt, StrLen, CurStrLen, TmpStrLen, ArrPos, StrPos: Integer;
  CurStr, TmpStr: String;
begin
  Result := '';
  StrLen := Length( AStr );
  bCnt := Length( ABegins );
  eCnt := Length( AEnds );

  if ( ( 1 > StrLen ) or ( 1 > bCnt ) or ( 1 > eCnt ) ) then
    Exit;

  GetFirstStrPos( AStr, ABegins, ACaseSens, ArrPos, StrPos );

  if ( ArrPos < 0 ) then
    Exit;

  CurStr    := ABegins[ArrPos];
  CurStrLen := Length( CurStr );

  if ( 1 > CurStrLen ) then // if begin empty
    Exit;

  TmpStrLen := ( StrLen + 1 ) - ( StrPos + CurStrLen );
  TmpStr := Copy( AStr, StrPos + CurStrLen, TmpStrLen );

  GetFirstStrPos( TmpStr, AEnds, ACaseSens, ArrPos, StrPos );

  if ( ArrPos < 0 ) then // not found in array
  begin

    if AAnyEnd then
      Result := TmpStr;

    Exit;
  end; // if ( ArrPos < 0 ) then // not found in array

  CurStr    := AEnds[ArrPos];
  CurStrLen := Length( CurStr );

  if ( 1 > CurStrLen ) then // if end empty
    Exit;

  Result := Copy( TmpStr, 1, StrPos - 1 );
end; // function N_CMV_GetBetween

//**************************************************** N_CMV_GetParamFromSL ***
// Get Parameter value from StringList
//
//    Parameters
// AList      - Target StringList
// AParamName - Parameter name to be found
// ACaseSens  - if True - Case sensitive search, default - False
// ASeparator - Separator between Parameter name and value, default '='
// Result     - Parameter value of '' if not found
//
function N_CMV_GetParamFromSL( AList: TStringList; AParamName: String;
                               ACaseSens: Boolean = False;
                               ASeparator: String = '=' ): String;
var
  i, ListCount, StrLen, SepLen, SepPos, OffSet: Integer;
  s, name, UpperName, value: String;
begin
  Result := ''; // default empty value

  if ( nil = AList ) then
    Exit;

  ListCount := AList.Count;
  SepLen    := Length( ASeparator );
  UpperName := UpperCase( AParamName );

  for i := ( ListCount - 1 ) downto 0 do // for each List item
  begin
    s := Trim( AList[i] );
    StrLen := Length( s );
    SepPos := Pos( ASeparator, s );

    if ( 0 < SepPos ) then // Separator found
    begin
      OffSet := SepPos + SepLen;
      name  := Trim( Copy( s, 1, SepPos - 1 ) );
      value := Trim( Copy( s, OffSet, ( StrLen + 1 ) - OffSet ) );

      if ( ( name = AParamName ) or
           ( ( not ACaseSens ) and ( UpperCase( name ) = UpperName ) ) ) then
      begin
        Result := value;
        Exit;
      end;

    end; // if ( 0 < SepPos ) then // Separator found

  end; // for i := ( ListCount - 1 ) downto 0 do // for each List item

end; // function N_CMV_GetParamFromSL

//************************************************************ N_CMV_USBReg ***
// Subscribe application's windows on USB events
//
//    Parameters
// AHWND  - window handle
// APtr   - special event handle
// Result - special event handle if success, else nil
//
function N_CMV_USBReg( AHWND: HWND; var APtr: Pointer ): Boolean;
var
  dbi:  TN_CMV_DEV_BROADCAST_DEVICEINTERFACE;
  Size: Integer;
  RDN:  Pointer;
  i :   Integer;
begin
  Result := N_CMV_USBUnreg( APtr );

  if not Result then
    Exit;

  Result := False;
  // fill dbi structure to catch USB events
  Size := SizeOf( TN_CMV_DEV_BROADCAST_DEVICEINTERFACE );
  ZeroMemory( @dbi, Size );
  dbi.dbcc_size       := Size;
  dbi.dbcc_devicetype := N_CMV_DBT_DEVTYP_DEVICEINTERFACE;
  dbi.dbcc_reserved   := 0;
  dbi.dbcc_classguid  := N_CMV_GUID_DEVINTERFACE_USB_DEVICE;

  // Initialize variable to get device identifier
  for i := 0 to 254 do
    dbi.dbcc_name[i] := '0';

  RDN:= RegisterDeviceNotification( AHWND, @dbi, DEVICE_NOTIFY_WINDOW_HANDLE );

  // is success
  if Assigned( RDN ) then
  begin
    APtr := RDN;
    Result := True;
  end; // if Assigned( RDN ) then

  if not Result then
    N_CMV_ShowCriticalError( '', 'USB not registered' );

end; // function N_CMV_USBReg

//********************************************************** N_CMV_USBUnreg ***
// Unsubscribe application's windows from USB events
//
//    Parameters
// APtr   - special event handle
// Result - True if success, else false
//
function N_CMV_USBUnreg( var APtr: Pointer ): Boolean;
begin
  Result := True;

  if ( nil = APtr ) then
    Exit;

  Result := UnRegisterDeviceNotification( APtr );
  APtr := nil;

  if not Result then
    N_CMV_ShowCriticalError( '', 'USB not unregistered' );

end; // function N_CMV_USBUnreg

//************************************************************** USBGetData ***
// Get USB interface
//
//    Parameters
// msg      - windows message
// Result   - USB interface if success, else nil
//
function USBGetData( msg: TMessage ): TNP_CMV_DevBroadcastDeviceInterface;
var
  devType: Integer;
  Datos:   TNP_CMV_DevBroadcastHdr;
begin
  Result := nil;
  Datos   := TNP_CMV_DevBroadcastHdr( Msg.lParam ); // USB header
  devType := Datos^.dbch_devicetype;         // device type

  if ( devType <> N_CMV_DBT_DEVTYP_DEVICEINTERFACE ) then // wrong interface
    Exit;

  Result := TNP_CMV_DevBroadcastDeviceInterface( Datos );
end; // function USBGetData

//******************************************************** N_CMV_USBGetInfo ***
// Get USB interface
//
//    Parameters
// AMsg   - windows message
// Result - USB event structure
//
function N_CMV_USBGetInfo( AMsg: TMessage ): TN_CMV_USBEvent;
var
  pdbi: TNP_CMV_DevBroadcastDeviceInterface;
  s:    String;
  b, e: TN_SArray;
begin
  Result.EventType := USBVoid; // default value
  Result.DevVid    := '';      // empty VID by default
  Result.DevPid    := '';      // empty PID by default

  // check USB event type - arrive, remove, any other
  if ( AMsg.wParam = N_CMV_DBT_DEVICEARRIVAL ) then             // arrive
    Result.EventType := USBPlug
  else if ( AMsg.wParam = N_CMV_DBT_DEVICEREMOVECOMPLETE ) then // remove
    Result.EventType := USBUnplug
  else                                                   // other
    Exit;

  pdbi := USBGetData( AMsg ); // get USB data

  if not Assigned( pdbi ) then
    Exit;

  if ( nil = pdbi ) then
    Exit;

  s := String( pdbi.dbcc_name ); // get whole USB identifier string
  // fill begins and end array for substring search
  SetLength( b, 2 );
  SetLength( e, 5 );
  e[0] := 'VID_';
  e[1] := 'VEN_';
  e[2] := 'PID_';
  e[3] := '&';
  e[4] := '#';
  // extract Vendor ID ( VID or VEN ) from the identifier
  b[0] := e[0];
  b[1] := e[1];
  Result.DevVid := N_CMV_GetBetween( s, b, e, False, True ); // Get Vid
  // extract Product ID ( PID ) from the identifier
  SetLength( b, 1 );
  b[0] := e[2];
  Result.DevPid := N_CMV_GetBetween( s, b, e, False, True ); // Get Pid
end; // function N_CMV_USBGetInfo

//***************************************************** N_CMV_WaitThreadEnd ***
// Wait for thread end without application blocking for correct work after it
//
//     Parameters
// AThread - thread
//
procedure N_CMV_WaitThreadEnd( AThread: TN_CMV_UniThread );
var
  WaitCount: Integer;
begin
  WaitCount := 0;

  while ( ( tsIdle <> AThread.State ) and ( tsEnd <> AThread.State ) ) do
  begin
    sleep(50);
    Application.ProcessMessages;
    // Dump if Wait Info
    Inc( WaitCount );

    if ( ( WaitCount mod 20 ) = 0 ) then
      N_Dump2Str( 'CMVThread >> Still Wait Count=' + IntToStr( WaitCount ) );

  end; // while ( ( tsIdle <> AThread.State ) and ( tsEnd <> AThread.State ) ) do

  N_Dump2Str( 'CMVThread >> Wait Count=' + IntToStr( WaitCount ) );
end; // procedure N_CMV_WaitThreadEnd


{*** TN_CMV_UniThreadItem ***}

//******************************************** TN_CMV_UniThreadItem.Execute ***
// Execute procedure in thread
//
procedure TN_CMV_UniThreadItem.Execute();
begin
  if Terminated then Exit;
  Ctrl.Proc; // Call Real Procedure
end; // procedure TN_CMV_UniThreadItem.Execute

//******************************************** TN_CMV_UniThreadItem.Execute ***
// Get Tread Teminated State Flag
//
function TN_CMV_UniThreadItem.N_CMV_IsTerminated: Boolean;
begin
  Result := Terminated;
end; // function TN_CMV_UniThreadItem.N_CMV_IsTerminated

//********************************** TN_CMV_UniThreadItem.N_CMV_SyncProcObj ***
// Execute procedure of object in main thread needed for correct calls from thread to VCL
//
//     Parameters
// APrcObj - procedure of object (method) for synchronous execution
//
procedure TN_CMV_UniThreadItem.N_CMV_SyncProcObj( APrcObj: TN_ProcObj );
begin
  Synchronize( APrcObj );
end; // procedure TN_CMV_UniThreadItem.N_CMV_SyncProcObj

//********************************** TN_CMV_UniThreadItem.N_CMV_OnTerminate ***
// Self OnTerminate Handler
//
//     Parameters
// ASender - Self reference
//
procedure TN_CMV_UniThreadItem.N_CMV_OnTerminate( ASender: TObject );
begin
  if Terminated then
    N_Dump1Str( 'CMVThread >> is terminated' )
  else
    N_Dump1Str( 'CMVThread >> is finished' );
  if (Ctrl.Thread = nil) or (Ctrl.Thread = Self) then
    Ctrl.State := tsEnd;
end; // procedure TN_CMV_UniThreadItem.N_CMV_OnTerminate

{*** end of TN_CMV_UniThreadItem ***}

{*** TN_CMV_UniThread ***}

//************************************************* TN_CMV_UniThread.Create ***
// Thread Control Object C0nstructor
//
//     Parameters
// UserProc - procedure for asynchronous execution in new thread
//
constructor TN_CMV_UniThread.Create;
begin
  inherited;
  Thread := nil;
  State  := tsIdle;
end; // constructor TN_CMV_UniThread.Create

//********************************************* TN_CMV_UniThread.N_CMV_Init ***
// Initialize Thread Object
//
//     Parameters
// UserProc - procedure for asynchronous execution in new thread
//
procedure TN_CMV_UniThread.N_CMV_Init( UserProc: TN_CMV_UniThreadProc );
begin
  Thread := TN_CMV_UniThreadItem.Create( True );
  Proc                   := UserProc;
  Thread.OnTerminate     := Thread.N_CMV_OnTerminate;
  Thread.FreeOnTerminate := True;
  Thread.Ctrl := self;
  State       := tsOpen;
end; // procedure TN_CMV_UniThread.N_CMV_Init

//***************************************** TN_CMV_UniThread.N_CMV_SetState ***
// Pause or Resume Thread
//
//     Parameters
// ResumeWork - if True - Resume, else Pause
//
procedure TN_CMV_UniThread.N_CMV_SetState( ResumeWork: Boolean );
begin

  if ( ResumeWork and ( ( tsOpen = State ) or ( tsPause = State ) ) ) then
  begin
    N_Dump1Str( 'CMVThread >> Run' );
    State            := tsWork;
    Thread.Suspended := False;
  end
  else if ( ( not ResumeWork ) and ( tsWork = State ) ) then
  begin
    N_Dump1Str( 'CMVThread >> Stop' );
    State            := tsPause;
    Thread.Suspended := True;
  end;

end; // procedure TN_CMV_UniThread.N_CMV_SetState

//******************************************** TN_CMV_UniThread.N_CMV_Free ***
// Stop, Free or Clear Thread Object state
//
procedure TN_CMV_UniThread.N_CMV_Free();
begin

  case State of
  tsIdle: Exit; // Thread is not created
  tsPause,// Thread was stopped
  tsWork: // Thread is running
    begin
      N_Dump1Str( 'CMVThread >> Start Termination' );
      Thread.Terminate; // set terminated state
      if Thread.Suspended then
        Thread.Suspended := FALSE; // Activate for termination
      // Thread Object memory will be freed automatically
      // after termination
    end;
  tsOpen: // Thread was not started - free thread object
    begin
      N_Dump1Str( 'CMVThread >> Free before start' );
      Thread.Free();
      State := tsIdle;
    end;
  tsEnd : // Thread was finished or terminated
    begin
      N_Dump1Str( 'CMVThread >> Return Init State' );
      State := tsIdle;  // Return Initial State
    end;
  end; // case State of

  if Thread = nil then Exit;

  Thread := nil;
  Proc  := nil;

end; // procedure TN_CMV_UniThread.N_CMV_Free

{*** end of TN_CMV_UniThread ***}

//*************************************************** N_CMV_XMLResponseInit ***
// Init XML Response
//
//    Parameters
// ARes - XML Response
//
procedure N_CMV_XMLResponseInit( var ARes: TN_CMV_XMLResponse );
begin
  SetLength( ARes, 0 );
end; // procedure N_CMV_XMLResponseInit

//*********************************************** N_CMV_IsXMLRequestCorrect ***
// Check is XML Request correct
//
//    Parameters
// AReq   - XML Request
// Result - True if correct XML Request
//
function N_CMV_IsXMLRequestCorrect( AReq: TN_CMV_XMLRequest ): Boolean;
begin
  Result := ( '' <> AReq.tag );
end; // function N_CMV_IsXMLRequestCorrect

//**************************************************** N_CMV_XMLNodesToNode ***
// Subscribe application's windows on USB events
//
//    Parameters
// ANodes - XML Nodes to be investigated
// ATag   - Needed tag name
// APos   - Needed position ( number by order, from 0 )
// Result - Needed XML Node if success, nil if error
//
function N_CMV_XMLNodesToNode( ANodes: TN_CMV_XMLNodes; ATag: String;
                               APos: Integer = 0 ): TN_CMV_XMLNode;
var
  i, len, cnt: integer;
  n: TN_CMV_XMLNode;
begin
  Result := nil;

  if ( nil = ANodes ) then
    Exit;

  len := ANodes.length;
  cnt := 0; // Initialize position counter

  for i := 0 to len - 1 do // for each node
  begin
    n := ANodes.item[i];

    if ( ATag = n.nodeName ) then // needed tag name found
    begin

      if ( cnt = APos ) then // need position
      begin
        Result := n;
        Exit;
      end; // if ( cnt = APos ) then // need position

      Inc( cnt );
    end; // if ( ATag = n.nodeName ) then

  end; // if ( ATag = n.nodeName ) then // needed tag name found

end; // function N_CMV_XMLNodesToNode

//*************************************************** N_CMV_XMLNodesToNodes ***
// Works as previous function, but returns the child nodes of the result node
//
//    Parameters
// ANodes - XML Nodes to be investigated
// ATag   - Needed tag name
// APos   - Needed position ( number by order, from 0 )
// Result - Needed XML Node child if success, nil if error
//
function N_CMV_XMLNodesToNodes( ANodes: TN_CMV_XMLNodes; ATag: String;
                                APos: Integer = 0) : TN_CMV_XMLNodes;
var
  n: TN_CMV_XMLNode;
begin
  Result := nil;
  n := N_CMV_XMLNodesToNode( ANodes, ATag, APos );

  if ( nil = n ) then
    Exit;

  Result := n.childNodes;
end; // function N_CMV_XMLNodesToNodes

//***************************************************** N_CMV_XMLDocToNodes ***
// Get XML Document ( Root ) child nodes
//
//    Parameters
// ADoc   - XML Document
// Result - Child nodes if success, else nil
//
function N_CMV_XMLDocToNodes( ADoc: TN_CMV_XML ): TN_CMV_XMLNodes;
begin
  Result := nil;

  if ( nil = ADoc ) then
    Exit;

  Result := ADoc.childNodes;
end; // function N_CMV_XMLDocToNodes

//************************************************** N_CMV_XMLDocToNodesReq ***
// Get XML nodes by search path
//
//    Parameters
// ANodes - Initial XML Nodes
// AReq   - XML Request
// Result - Needed XML Nodes if success, else nil
//
function N_CMV_XMLDocToNodesReq( ANodes: TN_CMV_XMLNodes;
                                 AReq: TN_CMV_XMLRequest ): TN_CMV_XMLNodes;
var
  i, len: Integer;
begin
  Result := ANodes;
  len := Length( AReq.path );

  for i := 0 to len - 1 do // for each path item
  begin
    // Jump 1 step deeper into Nodes Array
    Result := N_CMV_XMLNodesToNodes( Result, AReq.path[i].name, AReq.path[i].position );

    if ( nil = Result ) then
      Exit;

  end; // for i := 0 to len - 1 do // for each path item

end; // function N_CMV_XMLDocToNodesReq

//********************************************* N_CMV_XMLDocToNodesResCount ***
// Count needed XML tag with certain name in XML Nodes
//
//    Parameters
// ANodes - XML Nodes
// ATag   - XML tag name ( like filter )
// Result - Count of such nodes
//
function N_CMV_XMLDocToNodesResCount( ANodes: TN_CMV_XMLNodes; ATag: String ): Integer;
var
  i, len: Integer;
begin
  Result := 0;
  len := ANodes.length;

  for i := 0 to len - 1 do // for each node
    if ( ATag = ANodes.item[i].nodeName ) then // if tag name coincide
      Inc( Result ); // Increase the counter

end; // function N_CMV_XMLDocToNodesResCount

//***************************************************** N_CMV_XMLAttrsToRes ***
// Make XML Response from XML Attributes
//
//    Parameters
// AAttrs  - XML Attributes
// AResPos - Needed position in Attributes
// ARes    - XML Response
//
procedure N_CMV_XMLAttrsToRes( AAttrs: TN_CMV_XMLAttr;
                               AResPos: Integer; var ARes: TN_CMV_XMLResponse );
var
  i, len: Integer;
begin
  len := AAttrs.length; // Attributes count
  SetLength( ARes[AResPos].attr, len); // resize XML Response

  for i := 0 to len - 1 do // for each Attribute
  begin
    ARes[AResPos].attr[i].name  := AAttrs.item[i].nodeName;
    ARes[AResPos].attr[i].value := AAttrs.item[i].nodeValue;
  end; // for i := 0 to len - 1 do // for each Attribute

end; // procedure N_CMV_XMLAttrsToRes

//************************************************ N_CMV_XMLDocToNodesToRes ***
// Subscribe application's windows on USB events
//
//    Parameters
// ANodes - XML Nodes Source
// ATag   - XML tag name wanted
// ARes   - XML Response
//
procedure N_CMV_XMLDocToNodesToRes( ANodes: TN_CMV_XMLNodes; ATag: String;
                                    var ARes: TN_CMV_XMLResponse );
var
  i, l, c, p: integer;
begin
  c := N_CMV_XMLDocToNodesResCount( ANodes, ATag ); // count nodes by tag name
  SetLength( ARes, c ); // resize XML Response
  l := ANodes.length;
  p := 0;

  for i := 0 to l - 1 do // for each node
  begin

    if ( ATag = ANodes.item[i].nodeName ) then // tag coincide
    begin
      ARes[p].text := ANodes.item[i].text; // copy text to XML Response item
      N_CMV_XMLAttrsToRes( ANodes.item[i].attributes, p, ARes ); // fill Attributes
      Inc( p );
    end; // if ( ATag = ANodes.item[i].nodeName ) then // tag coincide

  end; // for i := 0 to l - 1 do // for each node

end; // procedure N_CMV_XMLDocToNodesToRes

//**************************************************** N_CMV_XMLDocToResult ***
// Subscribe application's windows on USB events
//
//    Parameters
// ADoc   - XML Document
// AReq   - XML Request
// ARes   - XML Response
// Result - True if success
//
function N_CMV_XMLDocToResult( ADoc : TN_CMV_XML; AReq: TN_CMV_XMLRequest;
                               var ARes: TN_CMV_XMLResponse ): Boolean;
var
  nodes: TN_CMV_XMLNodes;
begin
  Result := False; // Bad result by default
  N_CMV_XMLResponseInit( ARes ); // Initialize XML

  if not N_CMV_IsXMLRequestCorrect( AReq ) then // check request
    Exit;

  if ( nil = ADoc ) then // check XML Document
    Exit;

  nodes := N_CMV_XMLDocToNodes( ADoc ); // get root nodes

  if ( nil = nodes ) then // check root nodes
    Exit;

  nodes := N_CMV_XMLDocToNodesReq( nodes, AReq ); // get needed nodes

  if (nil = nodes) then // check needed nodes
    Exit;

  N_CMV_XMLDocToNodesToRes( nodes, AReq.tag, ARes ); // Fill XML Response
  Result := True; // Success
end; // function N_CMV_XMLDocToResult

//******************************************************** N_CMV_XMLDocLoad ***
// Load XML Document from string or file
//
//    Parameters
// ASource  - XML Source
// FromFile - if True then ASource is file name, else - data string
// Result   - XML Document
//
function N_CMV_XMLDocLoad( ASource: String; FromFile: Boolean ): TN_CMV_XML;
var
  doc: TN_CMV_XML;
begin
  Result := nil;

  if FromFile then // if file mode
    if not FileExists( ASource ) then // if file not exists
      Exit;

  try // Initialize DOMDocument
    CoInitialize( nil );
    doc := CoDOMDocument.Create;
  except
    CoUninitialize;
    Exit;
  end;

  if FromFile then // file mode
  begin

    if not doc.Load( ASource ) then // if XML not loaded
    begin
      CoUninitialize;
      Exit;
    end; // if not doc.Load( AFileName ) then // if XML not loaded

  end
  else // string mode
  begin

    if not doc.loadXML( ASource ) then
    begin
      CoUninitialize;
      Exit;
    end;

  end;

  Result := doc;
  CoUninitialize;
end; // function N_CMV_XMLDocLoad

//************************************************************ N_CMV_XMLGet ***
// Subscribe application's windows on USB events
//
//    Parameters
// APos   - Needed position in XML Response
// Attr   - Attribute's name wanted
// ARes   - XML Response
// Result - Needed string value
//
function N_CMV_XMLGet( APos: Integer; Attr: String; ARes: TN_CMV_XMLResponse ): String;
var
  i, len: Integer;
begin
  Result := ''; // default empty value

  if ( ( APos < 0 ) or ( APos >= Length( ARes ) ) ) then // check position
    Exit;

  len := length( ARes[APos].attr );

  for i := 0 to len - 1 do // for each Attribute
  begin

    if ( Attr = ARes[APos].attr[i].name ) then // names coincide
    begin
      Result := ARes[APos].attr[i].value;
      Exit;
    end; // if ( Attr = ARes[APos].attr[i].name ) then // names coincide

  end; // for i := 0 to len - 1 do // for each Attribute

end; // function N_CMV_XMLGet

end.
