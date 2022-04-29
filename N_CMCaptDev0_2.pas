Unit N_CMCaptDev0_2;
// Common useful functions
// 2013.01.03 Added USB functions by Valery Ovechkin
// 2014.01.10 Added procedure ShowCriticalError by Valery Ovechkin
// 2014.02.07 Fixed function ProcessExists by Valery Ovechkin
// 2014.02.07 Added function WaitProcess by Valery Ovechkin
// 2014.02.10 Added functions FileToArr, ArrToParams, GetParamValue by Valery Ovechkin
// 2014.02.21 Added function GetBetween and some auxilliary functions for it by Valery Ovechkin
// 2014.02.21 Fixed function ProcessExists by Valery Ovechkin

interface

uses SysUtils, Windows, Messages, Forms, StdCtrls, Dialogs, Graphics, TlHelp32, Registry, ShlObj,
  K_CM0, K_CLib0,
  N_CM1, N_Types, N_Lib0;

// Fnctions parameter types for detailed call log
type TV_FuncParam = record
  name, valueBefore, valueAfter: String;
  pChild: Array of Pointer;
end;

type TPV_FuncParam = ^TV_FuncParam;
type TV_FuncParams = Array of TV_FuncParam;

type TParamPair = record
  name, value: String;
end;

type TParamPairs = Array of TParamPair;

// USB events types
type TUSBEventType = ( USBVoid, USBPlug, USBUnplug ); // USB event type

TUSBEvent = record
  EventType: TUSBEventType; // event type
  DevVid:    String;        // VID
  DevPid:    String;        // PID
end;

PDevBroadcastHdr  = ^DEV_BROADCAST_HDR;

DEV_BROADCAST_HDR = packed record
  dbch_size: DWORD;
  dbch_devicetype: DWORD;
  dbch_reserved: DWORD;
end;

PDevBroadcastDeviceInterface  = ^DEV_BROADCAST_DEVICEINTERFACE;

DEV_BROADCAST_DEVICEINTERFACE = record // whole device info
  dbcc_size: DWORD;
  dbcc_devicetype: DWORD;
  dbcc_reserved: DWORD;
  dbcc_classguid: TGUID;
  dbcc_name: array[0..254] of char;
end;

// types for imported functions

// Planmeca
type TN_stdcallInt2Func3Int2_PACharPInt2 = function ( AInt2_1, AInt2_2, AInt2_3: TN_Int2; APChar: PAnsiChar; APInt2: TN_PInt2 ): TN_Int2; stdcall;
// Duerr
type TN_cdeclIntFunc2Int_2PAChar = function( AInt: Integer; APChar1, APChar2: PAnsiChar ): Integer;cdecl;
// E2V
type TN_cdeclIntFuncPACharInt        = function ( APChar: PAnsiChar; AInt: Integer ): Integer; cdecl;
type TN_cdeclProcPACharInt           = procedure( APChar: PAnsiChar; AInt: Integer ); cdecl;
type TN_cdeclIntFuncPACharPIntDWORD  = function ( APChar: PAnsiChar; APInt: PInteger; ADWORD: DWORD ): Integer; cdecl;
type TN_cdeclIntFuncPACharPtr        = function ( APChar: PAnsiChar; APtr: Pointer ): Integer; cdecl;
type TN_cdeclIntFuncPACharPPtr       = function ( APChar: PAnsiChar; APPtr: TN_PPointer ): Integer; cdecl;
type TN_cdeclIntFuncPtr              = function ( APtr: Pointer ): Integer; cdecl;
type TN_cdeclIntFunc2PtrInt          = function ( APtr1, APtr2: Pointer; AInt: Integer ): Integer; cdecl;
type TN_cdeclIntFuncPtrInt           = function ( APtr: Pointer; AInt: Integer ): Integer; cdecl;
type TN_cdeclIntFuncPtrPInt          = function ( APtr: Pointer; APInt: PInteger ): Integer; cdecl;
type TN_cdeclIntFuncPtrIntPInt       = function ( APtr: Pointer; AInt: Integer; APInt: PInteger ): Integer; cdecl;
type TN_cdeclIntFuncPtrPAChar        = function ( APtr: Pointer; APChar: PAnsiChar ): Integer; cdecl;
type TN_cdeclIntFuncPtrByteInt       = function ( APtr: Pointer; APByte: PByte; AInt: Integer ): Integer; cdecl;
type TN_cdeclIntFuncPtrPACharInt     = function ( APtr: Pointer; APChar: PAnsiChar; AInt: Integer ): Integer; cdecl;
type TN_cdeclIntFuncPtrByteIntPtrInt = function ( APtr1: Pointer; APByte: PByte; AInt: Integer; APtr2: Pointer; AInt2: Integer ): Integer; cdecl;
type TN_cdeclProcPtrInt              = procedure( APtr: Pointer; AInt: Integer ); cdecl;
type TN_cdeclIntFunc2PACharInt       = function ( APAChar1, APAChar2: PAnsiChar; AInt: Integer ): Integer; cdecl;

// Gendex
type TN_cdeclProcInt2            = procedure( AInt2: TN_Int2 ); cdecl;
type TN_cdeclIntFuncPInt         = function ( APInt: PInteger ): Integer; cdecl;
type TN_cdeclIntFuncInt2         = function ( AInt2: TN_Int2 ): Integer; cdecl;
type TN_cdeclPWCharFuncVoid      = function (): PWChar; cdecl;
type TN_cdeclPWCharFuncInt2      = function ( AInt2: TN_Int2 ): PWChar; cdecl;
type TN_cdeclDblFuncVoid         = function (): Double; cdecl;
type TN_cdeclIntFunc2PWChar6PInt = function ( APWChar1, APWChar2: PWChar; APInt1, APInt2, APInt3, APInt4, APInt5, APInt6: PInteger ): Integer; cdecl;
type TN_cdeclIntFunc2PIntPWChar  = function ( APInt1, APInt2: PInteger; APWChar: PWChar ): Integer; cdecl;

// common useful function
function  CheckStrParam( param, value: String; sep: Char = ',' ): Boolean;
function  TrimNullsRight      ( s: String ): String;
procedure TifToBmp            ( tifPath, bmpPath: String );
function  LoadFunc            ( CDSDllHandle: THandle; var PFunc: Pointer; FuncName: AnsiString ): Boolean;
function  CreateProcessSimple ( sExecutableFilePath: String ): Boolean;
function  ProcessExists       ( ProcessName: String ): Boolean;
function  WaitProcess         ( start: Boolean; path: String; timeout: Integer ): Boolean;
function  GetRegistryKey      ( RootKey: DWORD; path: String; name: String ): String;
function  CheckBoxToStr       ( cb: TCheckBox ): String;
function  ComboBoxToStr       ( cb: TComboBox; TwoDigits: Boolean = False ): String;
function  IntToStrNorm        ( value, count: Integer ): String;
function  GetWrkDir           (): String;
function  GetLogDir           (): String;
function  FileExistsFromList  ( FileNames: TN_SArray ): Boolean;
function  GetNewNum           ( Prefixes, PostFixes: TN_SArray; NumSize: Integer ): String;
procedure DoExtendedLog       ( FuncName, Res, TimeBefore, TimeAfter, Duration: String; FuncParams: TV_FuncParams; dir, FileName: String; ClearAtTheEnd : Boolean );
function  dtStr               (): String;
function  GetFolderDialog     ( Handle: Integer; Caption: String; var strFolder: String ): Boolean;
function  N_CopyFile          ( source, target, LogStr: String ): Boolean;
procedure ShowCriticalError   ( DevName, ErrorText: String );
function  FileToArr( var arr: TN_SArray; FileName: String ): Boolean;
procedure ArrToParams( arr: TN_SArray; var par: TParamPairs );
function  GetParamValue( par: TParamPairs; ParName: String; CaseSens: Boolean = False ): String;
function  GetBetween( s: String; begins, ends: TN_SArray; CaseSens: Boolean; AnyEnd: Boolean ): String;

// USB const
const
  GUID_DEVINTERFACE_USB_DEVICE: TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';
  DBT_DEVICEARRIVAL          = $8000;     // arrive
  DBT_DEVICEREMOVECOMPLETE   = $8004;     // remove
  DBT_DEVTYP_DEVICEINTERFACE = $00000005;

// USB functions
  function USBReg     ( h: HWND; var p: Pointer ): Boolean;
  function USBUnreg   ( var p: Pointer          ): Boolean;
  function USBGetInfo ( msg: TMessage           ): TUSBEvent;

implementation

//************************************************************** StrToArray ***
// add not empty string to parameters array
//
//     Parameters
//  arr - parameters arrayt to add
//  s   - parameters string
//
procedure StrToArrayAdd( var arr : TN_SArray; s: String );
var
  c: Integer;
begin

  if ( '' <> s ) then
  begin
    c := length( arr );
    SetLength( arr, c + 1 );
    arr[c] := s;
  end; // if ( '' <> s ) then

end; // procedure StrToArrayAdd

//************************************************************** StrToArray ***
// fill parameters array from string
//
//     Parameters
//  arr - parameters arrayt to fill
//  s   - parameters string
//  sep - parameters separator, ',' by default
//
procedure StrToArray( var arr : TN_SArray; s: String; sep: Char = ',' );
var
  p, len: Integer;
  t: String;
begin
  SetLength( arr, 0 ); // initialize array
  t := s;
  len := length( t );  // string length
  p := Pos( sep, t );  // separator position

  while ( 0 < p ) do // while separator exists
  begin
    // try to add substring to array if it is not empty
    StrToArrayAdd( arr, Trim( Copy( t, 1, p - 1 ) ) );
    len := len - p;
    t := Copy( t, p + 1, len );
    p := Pos( sep, t );
  end; // while ( 0 < p ) do // while separator exists

  StrToArrayAdd( arr, Trim( t ) ); // add the tail to array
end; // procedure StrToArray

//*********************************************************** CheckStrParam ***
// check if value counters in parameters string
//
//     Parameters
//  param  - parameters string
//  value  - string for search in parameters
//  sep    - parameters separator, ',' by default
//  Result - True if at least one parameter item = value, else False
//
function CheckStrParam( param, value: String; sep: Char = ',' ): Boolean;
var
  c, i: Integer;
  arr: TN_SArray;
begin
  Result := True;
  StrToArray( arr, param, sep ); // parse parameters string as array
  c := length( arr );

  for i := 0 to c - 1 do
  begin

    if ( value = arr[i] ) then // if value = parameter[i] - exit with success
      Exit;

  end; // for i := 0 to c - 1 do

  Result := False;
end; // function CheckStrParam

//********************************************************** TrimNullsRight ***
// correct string by triming null charactres
//
//     Parameters
//  s      - string
//  Result - corrected string without trailing '#0' characters
//
function TrimNullsRight( s: String ): String;
var
  p: Integer;
begin
  Result := s;
  p := Pos( #0, s );
  if ( p > 0 ) then
    Result := Copy( s, 1, p - 1 );
end; // function TrimNullsRight

//**************************************************************** TifToBmp ***
// make BMP file from TIF file
//
//    Parameters
// tifPath - path to TIF file
// bmpPath - path to BMP file
//
procedure TifToBmp( tifPath, bmpPath: String );
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

    Tif.LoadFromFile( tifPath );
    Bmp.Assign( Tif );
    bmp.SaveToFile( bmpPath );

    Bmp.Free;
    Tif.Free;
{$ENDIF VER150}
end; // procedure TifToBmp

//**************************************************************** LoadFunc ***
// Common function for loading functions from DLL
//
//    Parameters
// CDSDllHandle - DLL Handle
// PFunc        - function pointer
// FuncName     - function name to import from DLL
// Result       - pointer to imported function (nil if function not found)
//
function LoadFunc( CDSDllHandle: THandle; var PFunc: Pointer; FuncName: AnsiString ): Boolean;
begin
  Result := False;

  if ( CDSDllHandle = 0 ) then // if DLL not found
    exit;

  // get function address
  PFunc := GetProcAddress( CDSDllHandle, @FuncName[1] );

  if ( PFunc = nil ) then // function not found in DLL
  begin
    N_Dump1Str( 'Trident >> Function "' + N_AnsiToString(FuncName ) + '" not loaded from DLL' );
    exit;
  end; // if ( PFunc = nil ) then // function not found in DLL

  Result := True;
end; // function LoadFunc

//***************************************************** CreateProcessSimple ***
// Start executable file by path - sExecutableFilePath
//
//    Parameters
// sExecutableFilePath - full path to executable file with command line
// Result - True if success, else False ( if process did not created )
//
function CreateProcessSimple( sExecutableFilePath: String ): Boolean;
var
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
begin
  FillMemory( @StartupInfo, SizeOf( StartupInfo ), 0 );
  StartupInfo.cb := SizeOf( StartupInfo );

  Result := CreateProcess( nil,
                           PChar( sExecutableFilePath ),
                           nil, nil, False,
                           NORMAL_PRIORITY_CLASS, nil, nil,
                           StartupInfo, ProcessInfo );

  CloseHandle( ProcessInfo.hProcess );
  CloseHandle( ProcessInfo.hThread );
end; // function CreateProcessSimple

//*********************************************************** ProcessExists ***
// Check if process exists
//
//    Parameters
// ProcessName - full path to process executable file
// Result      - True if process exists, else False
//
function ProcessExists( ProcessName: String ): Boolean;
var
  ProcessHandle, ModuleHandle: Cardinal;
  ProcessInfo:   PROCESSENTRY32;
  ModuleInfo:    MODULEENTRY32;
  ModuleExists:  Boolean;
  ProcessNameUp: String;
begin
  Result := False;
  ProcessNameUp := UpperCase( ProcessName );
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
end; // function ProcessExists

//************************************************************* WaitProcess ***
// check process existing during timeout
//
//    Parameters
// start   - if True - wait for starting, else for closing process
// path    - full path to process executable file
// timeout - timeout to check condition, timeout < 0 - means infinity
// Result  - True if process condition is right, else False
//
function WaitProcess( start: Boolean; path: String; timeout: Integer ): Boolean;
var
  t1, t2: Cardinal;
begin
  Result := ( start = ( ProcessExists( path ) ) );

  if Result then
    Exit;

  t1 := GetTickCount();
  t2 := t1;

  // wait for existing condition or timeout exceeded
  while ( ( not Result ) and ( ( 0 > timeout ) or ( t1 + Cardinal( timeout ) >= t2 ) ) ) do
  begin
    t2 := GetTickCount();

    if ( t1 > t2 ) then // Integer overflow
      t1 := 0;

    Result := ( start = ( ProcessExists( path ) ) );
  end; // while ( ( not r ) and ( ( 0 > timeout ) or ( t1 + timeout <= t2 ) ) ) do

end; // function WaitProcess

//********************************************************** GetRegistryKey ***
// Get Registry Key value
//
//    Parameters
// RootKey - Root Key (e.g. HKEY_LOCAL_MACHINE)
// path    - path to Key
// name    - Key name
// Result  - Key value or '' if Key is not exists
//
function GetRegistryKey( RootKey: DWORD; path: String; name: String ): String;
var
  RegObject: TRegistry;
begin
  Result := ''; // default value
  RegObject := TRegistry.Create(); // create Registry object
  RegObject.RootKey := RootKey;    // Set Root Key

  if not RegObject.OpenKey( path, False ) then // try to open
  begin
    RegObject.Free; // free Registry object
    Exit;
  end;

  Result := RegObject.ReadString( name ); // get Key value
  RegObject.CloseKey; // close Key
  RegObject.Free;   // free Registry object
end; // function GetRegistryKey

//*********************************************************** CheckBoxToStr ***
// Convert CheckBox state to string
//
//    Parameters
// cb     - CheckBox pointer
// Result - "1" if Checked, else "0"
//
function CheckBoxToStr( cb: TCheckBox ): String;
begin
   Result := '0'; // default value = 0 (unchecked)

   if cb.Checked then
      Result := '1'; // value = 1 if checked

end; // function CheckBoxToStr

//*********************************************************** ComboBoxToStr ***
// Convert ComboBox state to string
//
//    Parameters
// cb        - ComboBox pointer
// TwoDigits - add "0" before Result
// Result    - String( combobox ItemIndex )
//
function ComboBoxToStr( cb: TComboBox; TwoDigits: Boolean = False ): String;
begin
   Result := IntToStr( cb.ItemIndex );

   if ( TwoDigits and ( 10 > cb.ItemIndex ) ) then
     Result := '0' + Result;

end; // function ComboBoxToStr

//************************************************************ IntToStrNorm ***
// IntToStr + left nulls if needed
//
//    Parameters
// value     - Integer
// count     - size of string
// Result    - String
//
function IntToStrNorm( value, count: Integer ): String;
var
 i, len: Integer;
begin
  Result := IntToStr( value );
  len := Length( Result );

  for i := 1 to ( count - len ) do
  begin
    Result := '0' + Result;
  end;

end; // function IntToStrNorm

//*************************************************************** GetWrkDir ***
// Get Working Directory 'CMSWrkFiles' and create it if not exists
//
//    Parameters
// Result    - Directory path
//
function GetWrkDir(): String;
begin
  Result := K_GetDirPath( 'CMSWrkFiles' );
  K_ForceDirPath( Result );
end; // function GetWrkDir

//*************************************************************** GetLogDir ***
// Get Log Directory 'CMSLogFiles' and create it if not exists
//
//    Parameters
// Result    - Directory path
//
function GetLogDir(): String;
begin
  Result := K_GetDirPath( 'CMSLogFiles' );
  K_ForceDirPath( Result );
end; // function GetLogDir

//****************************************************** FileExistsFromList ***
// Check if any file from list exists
//
//    Parameters
// FileNames - file names lists
// Result    - True if at least 1 file exists
//
function FileExistsFromList( FileNames: TN_SArray ): Boolean;
var
  i, len: Integer;
begin
  Result := True;
  len := Length( FileNames );

  for i := 0 to len - 1 do
  begin

    if FileExists( FileNames[i] ) then
    begin
      Exit;
    end;

  end; // for i := 0 to len - 1 do

  Result := False;
end; // function FileExistsFromList

//*************************************************************** GetNewNum ***
// Generate unique number for writing files
//
//    Parameters
// Prefixes  - file prefixes lists
// PostFixes - file postfixes lists
// NumSize   - length of number, e.g. if NumSize = 6 than '123' -> '000123'
// Result    - desired number normalized by size
//
function GetNewNum( Prefixes, PostFixes: TN_SArray; NumSize: Integer ): String;
var
  i, len, num: Integer;
  FileNames: TN_SArray;
begin
  Result := '';
  num := 1;
  len := Length( Prefixes );

  if ( len <> Length( PostFixes ) ) then
  begin
    K_CMShowMessageDlg( 'GetNewNum error', mtError);
    Exit;
  end;

  SetLength( FileNames, len );

  for i := 0 to len - 1 do
  begin
    FileNames[i] := Prefixes[i] + IntToStrNorm( num, NumSize ) + PostFixes[i];
  end;

  while FileExistsFromList( FileNames ) do
  begin
    Inc( num );

    for i := 0 to len - 1 do
    begin
      FileNames[i] := Prefixes[i] + IntToStrNorm( num, NumSize ) + PostFixes[i];
    end;

  end; // while FileExistsFromList( FileNames ) do

  Result := IntToStrNorm( num, NumSize );
end; // function GetNewNum

//***************************************************** ExtendedLogStrParam ***
// extended log function parameters
//
//    Parameters
// p      - function parameter
// prefix - prefix
// Result - string to log
//
function ExtendedLogStrParam( p: TPV_FuncParam; prefix: String ): String;
var
  i, len: Integer;
begin
  len := Length( p.pChild );
  Result := prefix + p.name;

  if ( len < 1 ) then
  begin
    Result := Result + ' = "' + p.valueBefore + '" => "' + p.valueAfter + '"' + #13#10;
  end
  else
  begin
    Result := Result + '{' + #13#10;

    for i := 0 to len - 1 do
    begin
      Result := Result + ExtendedLogStrParam( p.pChild[i], prefix + '  ' );
    end;

    Result := Result + prefix + '}' + #13#10;
  end;

end; // function ExtendedLogStrParam

//********************************************************** ExtendedLogStr ***
// extended log string
//
//    Parameters
// FuncName   - function name
// Res        - function result
// TimeBefore - datetime before function call
// TimeAfter  - datetime after function call
// Duration   - time taken for function call in milliseconds
// FuncParams - function parameters list
// Result     - string to log
//
function ExtendedLogStr( FuncName, Res, TimeBefore, TimeAfter, Duration: String;
                         FuncParams: TV_FuncParams ): String;
var
  i, len: Integer;
begin
  Result := FuncName + ':' + #13#10 + #13#10 +
  'Time Before = ' + TimeBefore + #13#10 +
  'Time After = ' + TimeAfter + #13#10 +
  'Duration = ' + Duration + #13#10 + #13#10 +
  'Result = ' + Res + #13#10 + #13#10 +
  'Params:' + #13#10;

  len := Length( FuncParams );

  for i := 0 to len - 1 do
  begin
    Result := Result + ExtendedLogStrParam( @FuncParams[i], '    ' );
  end;

  Result := Result + #13#10;

  Result := Result + '------------------------------' + #13#10;

end; // function ExtendedLogStr

//******************************************************** ClearExtendedLog ***
// clear extended log object for current parameter
//
//    Parameters
// p - function parameter
//
procedure ClearExtendedLog( p: TPV_FuncParam );
var
  i, len: Integer;
begin

  if ( p = nil ) then
    Exit;

  len := Length( p.pChild );

  for i := 0 to len - 1 do
  begin
    ClearExtendedLog( p.pChild[i] );
  end;

  Dispose( p );
end; // procedure ClearExtendedLog

//******************************************************* ClearExtendedLogs ***
// clear extended log object
//
//    Parameters
// p - function parameters list
//
procedure ClearExtendedLogs( var params: TV_FuncParams );
var
  i, j, len, len2: Integer;
begin
  len := Length( params );

  for i := 0 to len - 1 do
  begin
    len2 := Length( params[i].pChild );

    for j := 0 to len2 - 1 do
    begin
      ClearExtendedLog( params[i].pChild[j] );
    end;

  end;

  SetLength( params, 0 );
end; // procedure ClearExtendedLogs

//*********************************************************** DoExtendedLog ***
// write extended log string to file
//
//    Parameters
// FuncName   - function name
// Res        - function result
// TimeBefore - datetime before function call
// TimeAfter  - datetime after function call
// Duration   - time taken for function call in milliseconds
// FuncParams - function parameters list
// dir        - log directory
// FileName   - log file name
//
procedure DoExtendedLog( FuncName, Res, TimeBefore, TimeAfter, Duration: String;
                         FuncParams: TV_FuncParams;
                         dir, FileName: String; ClearAtTheEnd : Boolean );
begin

  if not DirectoryExists( dir ) then
  begin
    CreateDir( dir );
  end;

  N_AddStrToFile2( N_StringToAnsi( ExtendedLogStr( FuncName, Res, TimeBefore, TimeAfter, Duration,
                                   FuncParams ) ),
                   N_StringToAnsi( dir + '\' + FileName ) );

  if ClearAtTheEnd then
    ClearExtendedLogs( FuncParams );

end; // procedure DoExtendedLog

//******************************************************************* dtStr ***
// Get current datetime as string in needed format
//
//    Parameters
// Result - Current datetime as string formatted
//
function dtStr(): String;
var
  year, month, day, hour, minute, sec, msec: WORD;
  dt: TDateTime;
begin
  dt := Now();
  DecodeDate( dt, year, month, day );
  DecodeTime( dt, hour, minute, sec, msec );
  Result := IntToStr( year )          + '.' +
            IntToStrNorm( month,  2 ) + '.' +
            IntToStrNorm( day,    2 ) + ' ' +
            IntToStrNorm( hour,   2 ) + ':' +
            IntToStrNorm( minute, 2 ) + ':' +
            IntToStrNorm( sec,    2 ) + '.' +
            IntToStrNorm( msec,   3 );
end; // function dtStr

//****************************************************** BrowseCallbackProc ***
// Callback function for folder browser
//
//    Parameters
// hwnd   - parent window handle
// uMsg   - message type
// lParam - LPARAM
// lpData - LPARAM
// Result - error code
//
function BrowseCallbackProc( hwnd: HWND; uMsg: UINT; lParam: LPARAM; lpData: LPARAM ): Integer; stdcall;
begin
  Result := 0;
end; // function BrowseCallbackProc

//******************************************************** GetCorrectedPath ***
// Get folder path without "\" at the last char
//
//    Parameters
// path   - folder path
// Result - corrected folder path without "\"
//
function GetCorrectedPath( path: String ): String;
var
  len: Integer;
begin
  Result := path;
  len := Length( path );

  if ( len > 0 ) then
    if ( path[len] = '\' ) then
      Result := Copy( path, 1, len - 1 );

end; // function GetCorrectedPath

//********************************************************* GetFolderDialog ***
// Launch folder browser
//
//    Parameters
// Handle    - parent window handle
// Caption   - folder browser caption
// strFolder - folder name
// Result    - True if success
//
function GetFolderDialog( Handle: Integer; Caption: String; var strFolder: String ): Boolean;
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
  SHGetSpecialFolderLocation( Handle, CSIDL_DRIVES, JtemIDList );

  with BrowseInfo do
  begin
    hwndOwner := GetActiveWindow;
    pidlRoot  := JtemIDList;
    SHGetSpecialFolderLocation( hwndOwner, CSIDL_DRIVES, JtemIDList );
    pszDisplayName := StrAlloc( MAX_PATH );
    lpszTitle      := @Caption[1];
    lpfn           := BrowseCallbackProc;
    lParam         := LongInt( strFolder );
  end;

  ItemIDList := SHBrowseForFolder(BrowseInfo);

  if ( ItemIDList <> nil ) then
    if SHGetPathFromIDList( ItemIDList, @Path[1] ) then
    begin
      strFolder := GetCorrectedPath( TrimNullsRight( Path ) );
      Result    := True;
    end;

end; // function GetFolderDialog

//************************************************************** N_CopyFile ***
// Copy file and log if error happened whilst copy
//
//    Parameters
// source - source file name
// target - destination file name
// LogStr - string for log
// Result - True if success
//
function N_CopyFile( source, target, LogStr: String ): Boolean;
begin
  Result := False;

  if not FileExists( source ) then
    Exit;

  if not CopyFile( @source[1], @target[1], False ) then
  begin
    N_Dump1Str( LogStr + ' "' + source + '" not copied' ) ;
    Exit;
  end;

  Result := True;
end; // function N_CopyFile

//******************************************************* ShowCriticalError ***
// Show error dialog by device name and error text
//
//     Parameters
// DevName   - device name
// ErrorText - error description
//
procedure ShowCriticalError( DevName, ErrorText: String );
var
  s: String;
begin
  s := ErrorText;

  if ( '' <> DevName ) then
    s := DevName + '>> Error : ' + s;

  K_CMShowMessageDlg( s, mtError );
end; // procedure ShowCriticalError

//*************************************************************** FileToArr ***
// Fill array from Text File
//
//    Parameters
// arr      - target array to be fullfilled
// FileName - File Name
// Result   - True if success ( file exists and able for reading )
//
function FileToArr( var arr: TN_SArray; FileName: String ): Boolean;
var
  FileHandle: TextFile;
  n: Integer;
begin
  Result := FileExists( FileName );
  n := 0;
  SetLength( arr, n );

  if not Result then // if file not exists
    Exit;

  Result := False;
  AssignFile( FileHandle, FileName );

  try Reset( FileHandle ); // open file for reading
  except
    Exit;
  end;

  while not eof( FileHandle ) do
  begin
    inc( n );
    SetLength( arr, n );
    Readln( FileHandle, arr[n - 1] );
  end; // while not eof( FileHandle ) do

  CloseFile( FileHandle ); // close file
  Result := True;
end; // function FileToArr

//************************************************************* ArrToParams ***
// Fill parameters array ( name, value ) from usual string array
//
//    Parameters
// arr - source string array
// par - destination array of parameters pairs ( name, value )
//
procedure ArrToParams( arr: TN_SArray; var par: TParamPairs );
var
  ArrLen, ParLen, i, SepPos, StrLen : Integer;
  s, ParName, ParValue: String;
begin
  ArrLen := Length( arr );
  ParLen := Length( par );

  for i := 0 to ArrLen - 1 do // parse array line by line
  begin
    s := Trim( arr[i] );
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
        SetLength( par, ParLen );
        par[ParLen - 1].name  := ParName;
        par[ParLen - 1].value := ParValue;
      end; // if ( '' <> ParName ) then // param name is not empty

    end; // if ( 0 < SepPos ) then // separator found

  end; // for i := 0 to ArrLen - 1 do // parse array line by line

end; // procedure ArrToParams

//*********************************************************** GetParamValue ***
// Find parameter's value by it's name
//
//    Parameters
// par      - parameters array
// ParName  - parameters name
// CaseSens - if True - case sensitive search
// Result   - parameters value
//
function GetParamValue( par: TParamPairs; ParName: String; CaseSens: Boolean = False ): String;
var
  i, ParLen: Integer;
  nm: String;
begin
  Result := '';
  ParLen := Length( par );

  for i := 0 to ParLen - 1 do // for each parameters pair
  begin
    nm := par[i].name;

    // if parameter found by name and CaseSens mode
    if ( ( ParName = nm ) or
         ( ( not CaseSens ) and ( UpperCase( ParName ) = UpperCase( nm ) ) ) ) then
    begin
      Result := par[i].value;
      Exit;
    end;

  end; // for i := 0 to ParLen - 1 do // for each parameters pair

end; // function GetParamValue

//*************************************************************** GetStrPos ***
// Find substring, with parameter CaseSens, that differs from standard Pos
//
//     Parameters
// s        - string
// subs     - substring
// CaseSens - If True - usual ( Pos ( subs, s ) ), else - another algorithm
// Result   - substring position in string if found, else - 0
//
function GetStrPos( s: String; subs: String; CaseSens: Boolean ): Integer;
var
  i, StrSz, SubStrSz: integer;
  UppStr, UppSubStr: String;
begin
  Result := 0;

  if CaseSens then
  begin
    Result := Pos( subs, s );
    Exit;
  end;

  StrSz    := Length( s );
  SubStrSz := Length( subs );

  if ( ( StrSz < SubStrSz ) or ( 1 > SubStrSz ) ) then
    Exit;

  UppSubStr := UpperCase( subs );

  for i := 1 to ( StrSz - SubStrSz ) + 1 do
  begin
    UppStr := UpperCase( Copy( s, i, SubStrSz ) );

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
// s        - string
// arr     - substrings array
// CaseSens - case sensitive
// ArrPos - output parameter, position in array
// StrPos - output parameter, position in string
//
procedure GetFirstStrPos( s: String; arr: TN_SArray; CaseSens: Boolean; var ArrPos: Integer; var StrPos: Integer );
var
  i, n, ArrLen: Integer;
begin
  ArrPos := -1;
  StrPos := 0;
  ArrLen := Length( arr );

  for i := 0 to ArrLen - 1 do
  begin
    n := GetStrPos( s, arr[i], CaseSens );

    if ( ( 0 < n ) and ( ( n < StrPos ) or ( 1 > StrPos ) ) ) then
    begin
      ArrPos := i;
      StrPos := n;
    end; // if ( ( 0 < n ) and ( ( n < StrPos ) or ( 1 > StrPos ) ) ) then

  end; //for i := 0 to ArrLen - 1 do

end; // procedure GetFirstStrPos

//************************************************************** GetBetween ***
// Find value in string between one of begins and one of ends
//
//     Parameters
// s        - string
// begins   - array of begins
// ends     - array of ends
// CaseSens - if True - case sensitive
// AnyEnd   - if no ends found - return substr up to the end
// Result   - substring between, by default ''
//
function GetBetween( s: String; begins, ends: TN_SArray; CaseSens: Boolean; AnyEnd: Boolean ): String;
var
  bCnt, eCnt, StrLen, CurStrLen, TmpStrLen, ArrPos, StrPos: Integer;
  CurStr, TmpStr: String;
begin
  Result := '';
  StrLen := Length( s );
  bCnt := Length( begins );
  eCnt := Length( ends );

  if ( ( 1 > StrLen ) or ( 1 > bCnt ) or ( 1 > eCnt ) ) then
    Exit;

  GetFirstStrPos( s, begins,  CaseSens, ArrPos, StrPos );

  if ( ArrPos < 0 ) then
    Exit;

  CurStr    := begins[ArrPos];
  CurStrLen := Length( CurStr );

  if ( 1 > CurStrLen ) then // if begin empty
    Exit;

  TmpStrLen := ( StrLen + 1 ) - ( StrPos + CurStrLen );
  TmpStr := Copy( s, StrPos + CurStrLen, TmpStrLen );

  GetFirstStrPos( TmpStr, ends,  CaseSens, ArrPos, StrPos );

  if ( ArrPos < 0 ) then // not found in array
  begin

    if AnyEnd then
      Result := TmpStr;

    Exit;
  end; // if ( ArrPos < 0 ) then // not found in array

  CurStr    := ends[ArrPos];
  CurStrLen := Length( CurStr );

  if ( 1 > CurStrLen ) then // if end empty
    Exit;

  Result := Copy( TmpStr, 1, StrPos - 1 );
end; // function GetBetween

//****************************************************************** USBReg ***
// Subscribe application's windows on USB events
//
//    Parameters
// h      - window handle
// p      - special event handle
// Result - special event handle if success, else nil
//
function USBReg( h: HWND; var p: Pointer ): Boolean;
var
  dbi:  DEV_BROADCAST_DEVICEINTERFACE;
  Size: Integer;
  RDN:  Pointer;
  i :   Integer;
begin
  Result := USBUnreg( p );

  if not Result then
    Exit;

  Result := False;
  // fill dbi structure to catch USB events
  Size := SizeOf( DEV_BROADCAST_DEVICEINTERFACE );
  ZeroMemory( @dbi, Size );
  dbi.dbcc_size       := Size;
  dbi.dbcc_devicetype := DBT_DEVTYP_DEVICEINTERFACE;
  dbi.dbcc_reserved   := 0;
  dbi.dbcc_classguid  := GUID_DEVINTERFACE_USB_DEVICE;

  // Initialize variable to get device identifier
  for i := 0 to 254 do
    dbi.dbcc_name[i] := '0';

  RDN:= RegisterDeviceNotification( h, @dbi, DEVICE_NOTIFY_WINDOW_HANDLE );

  // is success
  if Assigned( RDN ) then
  begin
    p := RDN;
    Result := True;
  end; // if Assigned( RDN ) then

  if not Result then
    ShowCriticalError( '', 'USB not registered' );

end; // function USBReg

//**************************************************************** USBUnreg ***
// Unsubscribe application's windows from USB events
//
//    Parameters
// p      - special event handle
// Result - True if success, else false
//
function USBUnreg( var p: Pointer ): Boolean;
begin
  Result := True;

  if ( nil = p ) then
    Exit;

  Result := UnRegisterDeviceNotification( p );
  p := nil;

  if not Result then
    ShowCriticalError( '', 'USB not unregistered' );

end; // function USBUnreg

//************************************************************** USBGetData ***
// Get USB interface
//
//    Parameters
// msg      - windows message
// Result   - USB interface if success, else nil
//
function USBGetData( msg: TMessage ): PDevBroadcastDeviceInterface;
var
  devType: Integer;
  Datos:   PDevBroadcastHdr;
begin
  Result := nil;
  Datos   := PDevBroadcastHdr( Msg.lParam ); // USB header
  devType := Datos^.dbch_devicetype;         // device type

  if ( devType <> DBT_DEVTYP_DEVICEINTERFACE ) then // wrong interface
    Exit;

  Result := PDevBroadcastDeviceInterface( Datos );
end; // function USBGetData

//************************************************************** USBGetInfo ***
// Get USB interface
//
//    Parameters
// msg      - windows message
// Result   - USB event structure
//
function USBGetInfo ( msg: TMessage ): TUSBEvent;
var
  pdbi: PDevBroadcastDeviceInterface;
  s:    String;
  b, e: TN_SArray;
begin
  Result.EventType := USBVoid; // default value
  Result.DevVid    := '';      // empty VID by default
  Result.DevPid    := '';      // empty PID by default

  // check USB event type - arrive, remove, any other
  if ( Msg.wParam = DBT_DEVICEARRIVAL ) then             // arrive
    Result.EventType := USBPlug
  else if ( Msg.wParam = DBT_DEVICEREMOVECOMPLETE ) then // remove
    Result.EventType := USBUnplug
  else                                                   // other
    Exit;

  pdbi := USBGetData( msg ); // get USB data

  if not Assigned( pdbi ) then
    Exit;

  if ( nil = pdbi ) then
    Exit;

  s := String( pdbi.dbcc_name ); // get whole USB identifier string
  // fill begins and end array for substring search
  SetLength( b, 1 );
  SetLength( e, 4 );
  e[0] := 'VID_';
  e[1] := 'PID_';
  e[2] := '&';
  e[3] := '#';
  // extract VID from the identifier
  b[0] := e[0];
  Result.DevVid := GetBetween( s, b, e, False, True ); // Get Vid
  // extract PID from the identifier
  b[0] := e[1];
  Result.DevPid := GetBetween( s, b, e, False, True ); // Get Pid
end; // function USBGetInfo

end.
