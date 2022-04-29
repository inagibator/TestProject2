unit K_CMSComLib;
// CMS Client DLL
interface

procedure CMSShowMessage( AMes: PAnsiChar ); stdcall;
function  CMSGetLibVer() : LongWord; stdcall;
function  CMSRegisterServer( AServerExePath: PAnsiChar ) : LongWord; stdcall;
function  CMSStartServer() : LongWord; stdcall;
function  CMSCloseServerEx( ACloseMode: integer ) : LongWord; stdcall;
procedure CMSCloseServer(); stdcall;
function  CMSSetCodePage( ACodePageID: integer ) : LongWord; stdcall;
function  CMSSetCurContext( APatientID, AProviderID,
                            ALocationID: integer ) : LongWord; stdcall;
function  CMSSetCurContextEx( APatientID, AProviderID, ALocationID,
              ATeethRightSet, ATeethLeftSet: integer ) : LongWord; stdcall;
function  CMSSetLocationsInfo( APLocationsInfo: PAnsiChar ): LongWord; stdcall;
function  CMSSetPatientsInfo ( APPatientsInfo:  PAnsiChar ): LongWord; stdcall;
function  CMSSetProvidersInfo( APProvidersInfo: PAnsiChar ): LongWord; stdcall;
function  CMSSetWindowState( AWinState: Integer ): LongWord; stdcall;
// function  CMSSetAppMode( AppMode: Integer ): LongWord; stdcall;
function  CMSGetPatientMediaCounter( APatID: Integer;
                                     APMediaCounter: PInteger ): LongWord; stdcall;
//function  CMSGetWindowHandle( APWinHandle: PInteger): LongWord; stdcall;
function  CMSGetServerInfo( AInfoCode : Integer; APStrBuf: PAnsiChar;
                            APBufLength : PInteger ): LongWord; stdcall;
function  CMSSetIniInfo( APIniInfo: PAnsiChar ): LongWord; stdcall;
function  CMSExecUICommand( AComCode : Integer; APComInfo: PAnsiChar ): LongWord; stdcall;
function  CMSCopyMovePatSlides( ASrcPatID, APatDstID, ACopyFlag: Integer ): LongWord; stdcall;
function  CMSSetUpdateMode( AUMode: Integer ): LongWord; stdcall;
function  CMSPrepPatSlidesAttrs( APatID : Integer; APAttrsLength  : PInteger ): LongWord; stdcall;
function  CMSGetPatSlidesAttrs( APAttrsBuf: PAnsiChar; ABufLength : Integer ) : LongWord; stdcall;
function  CMSPrepThumbnails( APSrcIDs : PAnsiChar; ASrcIDsCount : Integer;
                             APThumbsSize : PInteger ): LongWord; stdcall;
function  CMSGetThumbnail( AThumbInd : Integer; APBuf : PByte;
                           ABufLength : Integer ): LongWord; stdcall;
function  CMSGetSlideImageFile( ASlideID: integer; APMaxWidth, APMaxHeight : PInteger;
                                AFileFormat, AViewCont: integer; AFileName : PAnsiChar ) : LongWord; stdcall;
function  CMSHPSetCurContext( APatientID, AProviderID,
                              ALocationID: integer ) : LongWord; stdcall;
function  CMSHPSetVisibleIcons( AVisIDs : PAnsiChar; AMode : Integer ): LongWord; stdcall;
function  CMSHPViewMediaObject( AViewID : PAnsiChar ): LongWord; stdcall;
procedure CMSSetTraceInfo( APTraceFName: PAnsiChar; ATraceMode: Integer ); stdcall;

implementation

uses K_CMSCom_TLB, ActiveX, Windows, SysUtils, ShellAPI, Variants, Classes,
     K_SBuf0;

type TN_BArray = array of Byte;
type TN_IArray = array of Integer;
var
//  K_CMSComLibVer : Integer = 23;
  ICMS : ID4WCMServer;
  CMSClose : Boolean;
  LogLNum     : Integer;
  LogFName    : string;
  LogTraceAll : Boolean;
  ErrAddInfo : string;
  CMSCodePage : Integer = 1251;
  D4WCodePage : Integer = 0;
  CMSBuildNumber : string;
  CMSDefAnsiChar : AnsiChar = '?';
  CMSSBuf : TN_SerialBuf0;
  CMSThumbsOffsets : TN_IArray;
  CMSSlidesAttrsStr : AnsiString;


const
//  K_CMSComLibVer = 24;
  K_CMSComLibVer = 25;
  CMS_LogsCtrl = FALSE;
  CMS_CodePage_ID_Wrong1 = $A0000001; // Given value is not proper Code Page ID
  CMS_CodePage_ID_Wrong2 = $A0000002; // Given Code Page ID differs from early defined
  CMS_RemoveClose_Err1   = $A0000003; // CMS has no bufferd Close Command
  CMS_ThumbsCount_Wrong3 = $A0000004; // Wrong Resulting Thumbnails Count
  CMS_ThumbInd_Wrong4    = $A0000005; // Wrong Thumbnail Index
  CMS_ThumbBufSize_Wrong5= $A0000006; // Wrong Thumbnail Buffer Size
  CMS_AttrsBufSize_Wrong6= $A0000007; // Wrong Media Objects Attributes Buffer Size


//************************************************************ CMS_AnsiToWide ***
// Convert given AAnsiString to Unicode WideString using CMSCodePage
//
//     Parameters
// AAnsiString - given ANSI String to convert
// Result      - Return converted Unicode WideString
//
function CMS_AnsiToWide( AAnsiString: AnsiString ): WideString;
var
  NumChars: integer;
  NRes: integer;
begin
  Result := '';
  NumChars := Length(AAnsiString);

  if NumChars = 0 then Exit; // all done

  SetLength( Result, NumChars );
  NRes := MultiByteToWideChar( CMSCodePage, 0, @AAnsiString[1], NumChars,
                                                    @Result[1], NumChars );
  Assert( NRes = NumChars, 'MultiByteToWideChar Error' );
end; // function CMS_AnsiToWide

//************************************************************ CMS_WideToAnsi ***
// Convert given Unicode AWideString to AnsiString using CMSCodePage
//
//     Parameters
// AWideString - given Unicode Wide String to convert
// Result      - Return converted ANSI String
//
function CMS_WideToAnsi( AWideString: WideString ): AnsiString;
var
  WideLeng: integer;
  NRes: integer;
  DefCharWasUsed: LongBool;
begin
  Result := '';
  WideLeng := Length(AWideString);

  if WideLeng = 0 then Exit; // all done

  SetLength( Result, WideLeng );
  NRes := WideCharToMultiByte( CMSCodePage, 0, @AWideString[1], WideLeng,
                               @Result[1], WideLeng, @CMSDefAnsiChar, @DefCharWasUsed );
  Assert( NRes = WideLeng, 'WideCharToMultiByte Error' );
end; // function CMS_WideToAnsi

//********************************************************** CMS_AnsiToString ***
// Convert given AAnsiString to String using N_NeededCodePage if needed
//
//     Parameters
// AAnsiString - given ANSI String to convert
// Result      - Return converted (if needed) String
//
function CMS_AnsiToString( AAnsiString: AnsiString ): String;
begin
  if SizeOf(Char) = 2 then
    Result := String(CMS_AnsiToWide( AAnsiString ))
  else
    Result := String(AAnsiString);
end; // function CMS_AnsiToString

//******************************************************** CMS_StringToAnsi ***
// Convert given AString to Ansi String using N_NeededCodePage (If needed)
//
//     Parameters
// AString - given String to convert if needed
// Result  - Return converted ANSI String
//
function CMS_StringToAnsi( AString: String ): AnsiString;
begin
  if SizeOf(Char) = 2 then
    Result := CMS_WideToAnsi( AString )
  else
    Result := AnsiString(AString);
end; // function CMS_StringToAnsi

//******************************************************** CMS_StringToWide ***
// Convert given AString to Wide String using N_NeededCodePage (If needed)
//
//     Parameters
// AString - given String to convert if needed
// Result  - Return converted Wide String
//
function CMS_StringToWide( AString: String ): WideString;
begin
  if SizeOf(Char) = 2 then
    Result := WideString(AString)
  else
    Result := CMS_AnsiToWide( AnsiString(AString) );
end; // function CMS_StringToWide

//******************************************************** CMS_WideToString ***
// Convert given AString to Wide String using N_NeededCodePage (If needed)
//
//     Parameters
// AString - given String to convert if needed
// Result  - Return converted Wide String
//
function CMS_WideToString( AString: WideString ): String;
begin
  if SizeOf(Char) = 2 then
    Result := String(AString)
  else
    Result := CMS_AnsiToString( AnsiString(AString) );
end; // function CMS_WideToString

//******************************************************* K_GetComputerName ***
// Get Computer Name
//
//     Parameters
// Result - Returns Computer Name
//
function K_GetComputerName( ) : string;
var
  nSize: DWORD;
begin
  nSize := MAX_COMPUTERNAME_LENGTH + 1;
  SetLength( Result, nSize );
  if GetComputerName( PChar(Result), nSize ) then
    Result := Copy( Result, 1, nSize )
  else
    Result := '';
end; //*** end of K_GetComputerName


//////////////////////////////////////////////
// Windows Terminal Service Data Types
//

type TK_WTS_INFO_CLASS = ( // enumeration type contains values that indicate the type of session information to retrieve in a call to the WTSQuerySessionInformation function
  WTSInitialProgram, // A null-terminated string containing the name of the
                     // initial program that Terminal Services runs when the 
                     // user logs on.
  WTSApplicationName, // A null-terminated string containing the published name 
                      // of the application the session is running.
  WTSWorkingDirectory, // A null-terminated string containing the default 
                       // directory used when launching the initial program.
  WTSOEMIdWTSOEMId, // Not used.
  WTSSessionId, // A ULONG value containing the session identifier.
  WTSUserName, // A null-terminated string containing the name of the user 
               // associated with the session.
  WTSWinStationName, // A null-terminated string containing the name of the 
                     // Terminal Services session. Note Despite its name, 
                     // specifying this type does not return the window station 
                     // name. Rather, it returns the name of the Terminal 
                     // Services session. Each Terminal Services session is 
                     // associated with an interactive window station. 
                     // Currently, since the only supported window station name 
                     // for an interactive window station is "WinSta0", each 
                     // session is associated with its own "WinSta0" window 
                     // station. For more information, see Window Stations.
  WTSDomainName, // A null-terminated string containing the name of the domain 
                 // to which the logged-on user belongs.
  WTSConnectState, // The session's current connection state. For more 
                   // information, see WTS_CONNECTSTATE_CLASS.
  WTSClientBuildNumber, // A ULONG value containing the build number of the 
                        // client.
  WTSClientName, // A null-terminated string containing the name of the client.
  WTSClientDirectory, // A null-terminated string containing the directory in 
                      // which the client is installed.
  WTSClientProductId, // A USHORT client-specific product identifier.
  WTSClientHardwareId, // A ULONG value containing a client-specific hardware 
                       // identifier.
  WTSClientAddress, // The network type and network address of the client. For 
                    // more information, see WTS_CLIENT_ADDRESS.,
  WTSClientDisplay, // Information about the display resolution of the client. 
                    // For more information, see WTS_CLIENT_DISPLAY.
  WTSClientProtocolType, // A USHORT value specifying information about the 
                         // protocol type for the session. This is one of the 
                         // following values: WTS_PROTOCOL_TYPE_CONSOLE 
                         // WTS_PROTOCOL_TYPE_ICA WTS_PROTOCOL_TYPE_RDP
  WTSIdleTimeWTSIdleTime,
  WTSLogonTimeWTSLogonTime,
  WTSIncomingBytesWTSIncomingBytes,
  WTSOutgoingBytesWTSOutgoingBytes,
  WTSIncomingFramesWTSIncomingFrames,
  WTSOutgoingFramesWTSOutgoingFrames
);

type TK_WTS_CLIENT_ADDRESS  = record
  AddressFamily : DWORD;
  Address : array [0..19] of Byte;
end;
type TK_PWTS_CLIENT_ADDRESS = ^TK_WTS_CLIENT_ADDRESS;

const
  WTS_PROTOCOL_TYPE_CONSOLE = 0; // console
  WTS_PROTOCOL_TYPE_ICA = 1;     // citrix??
  WTS_PROTOCOL_TYPE_RDP = 2;     // remote desktop
  WTS_CURRENT_SESSION = -1;      // Current Session ID

type TK_WTSSessionInfo = record
  WTSSessionID : Integer;     // Session ID
  WTSClientProtocolType : Integer; // 0 - Console, 1 - ICA (may be Citrix, 2 -
                                   // RDP, Terminal Session)
  WTSServerCompName : string; // Application Server Computer Name
  WTSClientName     : string; // Remote Client (computer) Name
  WTSClientIPStr    : string; // Remote Client IP string
end;
type TK_PWTSSessionInfo = ^TK_WTSSessionInfo;

//
// end of Windows Terminal Service Data Types
//////////////////////////////////////////////

///////////////////////////////////////////////////
// Windows Terminal Service API definitions
//
{$IF SizeOf(Char) = 1}
function  WTSOpenServer( APCompName: PChar ): THandle; stdcall; external 'Wtsapi32.dll' name 'WTSOpenServerA';
function  WTSQuerySessionInformation( HServer : THandle; SessionId : Integer; WTSInfoClass : TK_WTS_INFO_CLASS; var PBuf : PChar; var BufDataLeng : DWORD ): BOOL; stdcall; external 'Wtsapi32.dll' name 'WTSQuerySessionInformationA';
{$ELSE}
function  WTSOpenServer( APCompName: PChar ): THandle; stdcall; external 'Wtsapi32.dll' name 'WTSOpenServerW';
function  WTSQuerySessionInformation( HServer : THandle; SessionId : Integer; WTSInfoClass : TK_WTS_INFO_CLASS; var PBuf : PChar; var BufDataLeng : DWORD ): BOOL; stdcall; external 'Wtsapi32.dll' name 'WTSQuerySessionInformationW';
{$IFEND}
procedure WTSFreeMemory( PMem : Pointer ); stdcall; external 'Wtsapi32.dll' name 'WTSFreeMemory';
//
// end of Windows Terminal Service API definitions
///////////////////////////////////////////////////

//***************************************************** K_WTSGetSessionInfo ***
// Get WTS Session Info
//
//     Parameters
// APWTSSessionInfo - Pointer to Windows Terminal Service Session Info structure
//
procedure K_WTSGetSessionInfo(  APWTSSessionInfo : TK_PWTSSessionInfo );
{$IF SizeOf(Char) = 1}
const
  SM_REMOTESESSION = 1000;
{$IFEND}
var
  HServer : THandle;
  BRes : BOOL;
  PSessionID : PDWORD;
  PClientProtocolType : PWord;
  PClientName : PChar;
  PClientAddress : TK_PWTS_CLIENT_ADDRESS;
  BufDataSize : LongWord;
Label LExit;
begin

  APWTSSessionInfo.WTSServerCompName := K_GetComputerName();
  APWTSSessionInfo.WTSClientProtocolType := WTS_PROTOCOL_TYPE_CONSOLE;
  if Windows.GetSystemMetrics( SM_REMOTESESSION ) <> 0 then
    APWTSSessionInfo.WTSClientProtocolType := WTS_PROTOCOL_TYPE_RDP;
  APWTSSessionInfo.WTSSessionID := 0;

  APWTSSessionInfo.WTSClientName := GetEnvironmentVariable( 'CLIENTNAME' );
  HServer := WTSOpenServer( @APWTSSessionInfo.WTSServerCompName[1] );
  if HServer = 0 then Exit; // WTS API fails

  PSessionID          := nil;
  PClientProtocolType := nil;
  PClientName         := nil;
  PClientAddress      := nil;

  BRes := WTSQuerySessionInformation( HServer,
                                      WTS_CURRENT_SESSION,
                                      WTSSessionId,
                                      PChar(PSessionID), BufDataSize );

  if not BRes then goto LExit;
  APWTSSessionInfo.WTSSessionID := PSessionID^;

  BRes := WTSQuerySessionInformation( HServer,
                                      APWTSSessionInfo.WTSSessionID,
                                      WTSClientProtocolType,
                                      PChar(PClientProtocolType), BufDataSize );
  if not BRes then goto LExit;
  APWTSSessionInfo.WTSClientProtocolType := PClientProtocolType^;

  if APWTSSessionInfo.WTSClientProtocolType > WTS_PROTOCOL_TYPE_CONSOLE then
  begin
    BRes := WTSQuerySessionInformation( HServer,
                                        APWTSSessionInfo.WTSSessionID,
                                        WTSClientName,
                                        PChar(PClientName), BufDataSize );
    if not BRes then goto LExit;
    APWTSSessionInfo.WTSClientName := PClientName;

    BRes := WTSQuerySessionInformation( HServer,
                                        APWTSSessionInfo.WTSSessionID,
                                        WTSClientAddress,
                                        PChar(PClientAddress), BufDataSize );
    if not BRes then goto LExit;
    with PClientAddress^ do
      APWTSSessionInfo.WTSClientIPStr := format( '%d.%d.%d.%d', [Address[2],
                                                                 Address[3],
                                                                 Address[4],
                                                                 Address[5]] );
  end;

LExit:
  WTSFreeMemory( PSessionID );
  WTSFreeMemory( PClientProtocolType );
  WTSFreeMemory( PClientName );
  WTSFreeMemory( PClientAddress );

end; // procedure K_WTSGetSessionInfo

//********************************************************* CMS_NewCapacity ***
// Calculate new array capacity using realy needed array length
//
//     Parameters
// NewLeng  - needed array length
// Capacity - array length (capacity) needed to decrease memory reallocations
// Result   - Returns true if capacity is enlarged
//
function  CMS_NewCapacity( NewLeng : Integer; var Capacity : Integer ) : Boolean;
var Delta : Integer;
begin
  Result := true;
//  Capacity := 0;
  if NewLeng < 0 then Exit;
  if NewLeng > Capacity then begin
    if (NewLeng > 64) then begin
      if      NewLeng <  10000000 then
        Delta := NewLeng div 4
      else if NewLeng <  50000000 then
        Delta := 2000000 + NewLeng div 20
      else if NewLeng < 100000000 then
        Delta := 4000000 + NewLeng div 100
      else
        Delta := 5000000;
    end else if (NewLeng > 8) then
      Delta := 16
    else
      Delta := 4;
    Capacity := NewLeng + Delta;
  end else
    Result := false;
end; // end of CMS_NewCapacity

function  CMSGetDumpErrString( AResCode : HResult ): string;
begin
  Result := '';
  if not Succeeded( AResCode ) then
    Result := SysErrorMessage(AResCode)
  else if AResCode = S_FALSE then
    Result := 'CMS Server is closing'
  else if AResCode = 2 then
    Result := 'CMS Server is waiting';
end;

procedure CMSTraceAddToFile( const AStr : string );
var
  F: TextFile;
begin
  if LogFName = '' then Exit;
  try
    Assign( F, LogFName );
    if not FileExists( LogFName ) then
      Rewrite( F )
    else
      Append( F );
    WriteLn( F, AStr );
    Flush( F );
    Close( F );
  except
  end;
end;

procedure CMSTraceAnsiAddToFile( const AStr : AnsiString );
var
  F: File;
  WInt : Integer;
begin
  if LogFName = '' then Exit;
  try
    Assign( F, LogFName );
    if not FileExists( LogFName ) then
      Rewrite( F, 1 )
    else
    begin
      Reset( F, 1);	{ Record size = 1 }
      WInt := FileSize( F );
      Seek( F, WInt );
    end;
    BlockWrite( F, AStr[1], Length(AStr) );
    WInt := $0A0D;
    BlockWrite( F, WInt, 2 );
    Close( F );
  except
  end;
end;

procedure CMSCheckTraceSize( );
var
  F: File;
  WInt : Integer;
  PrevLogName : string;
begin
  try
    Assign( F, LogFName );
    if FileExists( LogFName ) then
    begin
      Reset( F, 1);
      WInt := FileSize( F );
      Close( F );
      if WInt > 50000000 then
      begin
        PrevLogName := ChangeFileExt(LogFName, '') +
            '_' + FormatDateTime( 'yyyy"_"mm"_"dd"-"hh"_"nn"_"ss', Now() ) +
            ExtractFileExt(LogFName);
        RenameFile( LogFName, PrevLogName );
//        DeleteFile( LogFName );
        CMSTraceAddToFile( '***** File ' + LogFName + ' was renamed to ' );
        CMSTraceAddToFile( '           ' + PrevLogName  );
      end;
    end;
  except
  end;
end;

procedure CMSShowTraceInfo( ATraceInfo : String; AFuncCode : LongWord );
begin
  if (LogFName = '') or
     ( not LogTraceAll and (AFuncCode = 0)) then Exit;
  Inc(LogLNum);
  ATraceInfo := format('%4d> ', [LogLNum]) + FormatDateTime( 'dd-hh":"nn":"ss.zzz', Now() ) + ' CMSLIB >> ' +
                ATraceInfo + ' 0x' + IntToHex( AFuncCode, 8 );
  if AFuncCode <> 0 then
    ATraceInfo := ATraceInfo + ' ' + ErrAddInfo;
  CMSTraceAddToFile( ATraceInfo );

end;


//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSShowMessage
//********************************************************** CMSShowMessage ***
// Add Message to Log
//
//     Parameters
// AMes - message to Log
//
procedure CMSShowMessage( AMes: PAnsiChar ); stdcall;
var
  SMes : string;
begin
//  ShowMessage( AMes );
  if (LogFName = '') then Exit;
  Inc(LogLNum);
  SMes := format('%4d> ', [LogLNum]) + FormatDateTime( 'dd-hh":"nn":"ss.zzz', Now() ) +
                          ' D4W >> ' + CMS_AnsiToString( AMes );

  CMSTraceAddToFile( SMes );
end; //*** end of CMSShowMessage

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSGetLibVer()
//********************************************************** CMSGetLibVer() ***
// Get  Library Version
//
//     Parameters
// Result - Returns resulting operation code:
//
function  CMSGetLibVer() : LongWord; stdcall;
begin
  Result := K_CMSComLibVer;
end; //*** end of CMSGetLibVer

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSRegisterServer
//******************************************************* CMSRegisterServer ***
// Register given EXE file as CMSuite COM server
//
//     Parameters
// AServerExePath - path to CMSuite.EXE file
// Result         - Returns function resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// E_INVALIDARG            (0x80070057) - exe file is absent
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// AServerExePath string is full path to CMSuit.exe file.
//
// Function C prototype:
//#F
// DWORD CMSRegisterServer( LPCSTR AServerExePath );
//#/F
//
function CMSRegisterServer( AServerExePath: PAnsiChar ) : LongWord; stdcall;
var
  RCode : Integer;
  WServerExePath : string;
begin
  CMSShowTraceInfo( 'Start RegisterServer ' + AServerExePath, 0 );
  Result := LongWord(E_INVALIDARG);
  ErrAddInfo := 'File not found';
  try
    if FileExists(String(AServerExePath)) then begin
      Result := S_OK;
      if SizeOf(Char) = 2 then
        WServerExePath := CMS_AnsiToWide(AServerExePath)
      else
        WServerExePath := String(AServerExePath);
      RCode := ShellExecute( Windows.GetForegroundWindow(), 'Open', @WServerExePath[1],
                       ' /regserver', '', SW_SHOWMINNOACTIVE );
      if RCode <= 32 then
      begin
        Result := $FFFFFFFF;
        ErrAddInfo := 'Unknown Exception';
        case RCode of
        0 : ErrAddInfo := ' The operating system is out of memory or resources';
        ERROR_FILE_NOT_FOUND : ErrAddInfo := 'The specified file was not found';
        ERROR_PATH_NOT_FOUND : ErrAddInfo := 'The specified path was not found';
        ERROR_BAD_FORMAT : ErrAddInfo := 'The .EXE file is invalid (non-Win32 .EXE or error in .EXE image)';
        SE_ERR_ACCESSDENIED : ErrAddInfo := 'The operating system denied access to the specified file';
        SE_ERR_ASSOCINCOMPLETE : ErrAddInfo := 'The filename association is incomplete or invalid';
        SE_ERR_DDEBUSY : ErrAddInfo := 'The DDE transaction could not be completed because other DDE transactions were being processed';
        SE_ERR_DDEFAIL : ErrAddInfo := 'The DDE transaction failed';
        SE_ERR_DDETIMEOUT : ErrAddInfo := 'The DDE transaction could not be completed because the request timed out.';
        SE_ERR_DLLNOTFOUND : ErrAddInfo := 'The specified dynamic-link library was not found';
        SE_ERR_NOASSOC : ErrAddInfo := 'There is no application associated with the given filename extension';
        SE_ERR_OOM : ErrAddInfo := 'There was not enough memory to complete the operation';
        SE_ERR_SHARE : ErrAddInfo := 'A sharing violation occurred';
        end;
      end;
    end;
  except
    Result := $FFFFFFFF; // Unknown Exception
    ErrAddInfo := 'Unknown Exception';
  end;
  CMSShowTraceInfo( 'Fin RegisterServer', Result );

end; //*** end of CMSRegisterServer

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSStartServer
//********************************************************** CMSStartServer ***
// Init CMS COM Server
//
//     Parameters
// Result - Returns resulting operation code:
//#F
// S_OK                       (0x0) - Indicates that an instance of the
//                             specified object class was successfully created.
// REGDB_E_CLASSNOTREG (0x80040154) - Indicates that a specified class is not
//                             registered in the registration database.
// CO_E_SERVER_EXEC_FAILURE (0x80080005) - Server execution failed
// E_OUTOFMEMORY       (0x8007000E) - Out of memory.
// E_INVALIDARG        (0x80070057) - Indicates one or more arguments are
//                             invalid.
// E_UNEXPECTED        (0x8000FFFF) - Indicates an unexpected error occurred.
// -1                  (0xFFFFFFFF) - Unknown DLL exception was raised.
// -2                  (0xFFFFFFFE) - Wrong DLL version.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSStartServer( VOID );
//#/F
//
function CMSStartServer() : LongWord; stdcall;
var
  SInfo : OleVariant;
  ServerIsAlive : Boolean;
  ErrInfo1 : string;
label ErrExit;
begin
  CMSShowTraceInfo( 'Start StartServer', 0 );
  Result := 0;

  try
    ErrInfo1 := '';
    ServerIsAlive := (ICMS <> nil) and
                     (ICMS.GetWindowHandle( SInfo ) = S_OK);

    if CMSClose then
    begin
      CMSClose := FALSE;
      if ServerIsAlive then
      begin
        CMSSetWindowState( 0 );
        Exit;
      end;
    end
    else
      if ServerIsAlive then Exit;

    ICMS := nil;
    Result := CoCreateInstance( CLASS_D4WCMServer, nil, CLSCTX_INPROC_SERVER or
                                CLSCTX_LOCAL_SERVER, ID4WCMServer, ICMS );
    if Result = S_OK then
    begin
      Result := ICMS.GetServerInfo( 0, SInfo );
      if Succeeded( Result ) then
      begin
        CMSBuildNumber := SInfo;
        Result := ICMS.GetServerInfo( -1, SInfo );
        if Succeeded( Result ) then
        begin
          CMSTraceAnsiAddToFile( '' );
          CMSTraceAnsiAddToFile( '****** CMS Start New Session BuildNumber=' +
                                 CMS_StringToAnsi(CMSBuildNumber)  );
          if SInfo <> K_CMSComLibVer then
          begin
            Result := $FFFFFFFE;
            ICMS := nil;
            ErrAddInfo := 'Wrong DLL version number ' + IntToStr(K_CMSComLibVer) + '. Needed number is ' + IntToStr(SInfo);
          end;
        end
        else
        begin
          ErrInfo1 := 'GetServerInfo(-1)=';
          goto ErrExit;
        end;
      end
      else
      begin
        ErrInfo1 := 'GetServerInfo(0)=';
        goto ErrExit;
      end;
    end
    else
    begin
ErrExit:
      ICMS := nil;
      ErrAddInfo := ErrInfo1 + SysErrorMessage(Result);
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin StartServer', Result );
end; //*** end of  CMSStartServer

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSCloseServerEx
//******************************************************** CMSCloseServerEx ***
// Close CMS COM Server
//
//     Parameters
// ACloseMode - Close Mode:
//#F
//                            = 0 - close wait for CMS Application real close,
//                            = 1 - unconditional close of CMS Application
//                            =-1 - remove CMS Application close request
//#/F
// Result     - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - CMS server is busy - D4W should wait for CMS closing
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CMS_RemoveClose_Err1    (0xA0000003) - Try to remove absent CMSClose buffered command
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSCloseServerEx( int ACloseMode );
//#/F
//
function CMSCloseServerEx( ACloseMode: integer ) : LongWord;  stdcall;
var
  SInfo : OleVariant;
  SCommand : AnsiString;
  AddDump : string;

begin
  CMSShowTraceInfo( format( 'Start CloseServerEx Mode=%d', [ACloseMode] ), 0 );
//  Result := S_OK;
  try
    CMSBuildNumber := ''; // Clear CMSBuildNumber for future control

    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      if ACloseMode = 1 then
      begin
      // Clear Close State
        Result := S_OK;
        ICMS := nil;
        CMSClose := FALSE;
        CMSShowTraceInfo( 'Unconditional CloseServerEx', 0 );
        Exit;
      end;

      SCommand := 'CMSClose';
      if ACloseMode = -1 then
        SCommand := 'RemoveCMSClose';

      if CMSClose then
      begin
      // Close Command is already Send to Server
        CMSShowTraceInfo( 'CloseServerEx after CloseServer', 0 );
        Result := ICMS.GetWindowHandle( SInfo );
        if Result <> S_OK then
        begin
        // Clear Close State
          ICMS := nil;
          CMSClose := FALSE;
          CMSShowTraceInfo( 'CloseServerEx Ñlear Interface', 0 );
          Exit;
        end;
      end
      else if ACloseMode = -1 then
      begin // Remove CMSClose
        Result := CMS_RemoveClose_Err1;
        ErrAddInfo := 'CMS has no bufferd Close Command';
        CMSShowTraceInfo( 'CloseServerEx RemoveCMSClose', Result );
        Exit;
      end;

      // Exec CMSClose or RemoveCMSClose
      Result := CMSExecUICommand( 2, @SCommand[1] );
      AddDump := '';
      if not Succeeded( Result ) then
        AddDump := 'ExecUICommand Error Clear Interface'
      else if Result = S_OK then
      begin
        if ACloseMode = 0 then // not RemoveCMSClose
          ErrAddInfo := 'ExecUICommand Server closing is start'
      end
      else if Result = S_FALSE then
        AddDump := 'ExecUICommand Server closing return S_FALSE Ñlear Interface';

      CMSClose := TRUE;
      if ACloseMode = -1 then
        CMSClose := FALSE;

      if AddDump <> '' then
      begin // Uncondition Close on error
        ICMS := nil;
        CMSClose := FALSE;
        if Result <> S_FALSE then
          CMSShowTraceInfo( AddDump, 0 )
        else
          ErrAddInfo := AddDump;
      end
      else //
      if Result = 2 then
        ErrAddInfo := 'ExecUICommand Server is busy';

    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin CloseServerEx', Result );
end; //*** end of CMSCloseServerEx

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSCloseServer
//********************************************************** CMSCloseServer ***
// Close CMS COM Server
//
// Function C prototype:
//#F
// VOID CMSCloseServer( VOID );
//#/F
//
procedure CMSCloseServer(); stdcall;
var
  SInfo : OleVariant;
  SInfoStr : string;
  ASTR : AnsiString;
  ResCode : HResult;

  procedure CloseServer;
  begin
    ICMS := nil;
    CMSShowTraceInfo( 'CloseServer', 0 );
  end;

begin
  try
    CMSBuildNumber := ''; // Clear CMSBuildNumber for future control
    if ICMS = nil then Exit;
    if CMSClose then
    begin
    // Close Command is already Send to Server
      if ICMS.GetWindowHandle( SInfo ) <> S_OK then
      begin
      // Clear Close State
        ICMS := nil;
        CMSClose := FALSE;
        CMSShowTraceInfo( 'Clear Send CloseServer Command State', 0 );
      end;
      Exit;
    end;

    ASTR := 'CMSClose';
    ResCode := ICMS.GetServerInfo( 2, SInfo );
    SInfoStr := SInfo;
    if (S_OK = ResCode)    and
       (SInfoStr <> '')    and // Server is live
       (SInfoStr[1] = 'B') and // Server is busy
       Succeeded(CMSExecUICommand( 2, @ASTR[1] )) then
    begin
      CMSClose := TRUE;
      CMSShowTraceInfo( 'Send CloseServer Command', 0 );
    end
    else
    // Server is not live,
    // Server is live and waiting for client commands
    // Server is sleep
      CloseServer();
  except
    CloseServer();
  end;
end; //*** end of CMSCloseServer

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetCodePage
//********************************************************** CMSSetCodePage ***
// Defines current Code Page ID for strings convertion
//
//     Parameters
// ACodePageID - current Code Page ID
// Result      - Returns function COM resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// CMS_CodePage_ID_Wrong1  (0xA0000001) - Given value is not proper Code Page ID
// CMS_CodePage_ID_Wrong2  (0xA0000002) - Given Code Page ID differs from early defined
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSSetCodePage( int ACodePageID );
//#/F
//
function  CMSSetCodePage( ACodePageID: integer ) : LongWord; stdcall;
begin
  CMSShowTraceInfo( format( 'Start SetCodePage %d ', [ACodePageID] ), 0 );
//  Result := S_OK;
  try
    if ICMS = nil then
    begin
    // Server is not started
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
    // Server is started
      if ACodePageID = 0 then
      begin // not proper Code Page ID
        Result := CMS_CodePage_ID_Wrong1;
        ErrAddInfo := 'Given value is not proper Code Page ID'
      end
      else
      begin // proper Code Page ID
        if (D4WCodePage <> 0) and (D4WCodePage <> ACodePageID) then
        begin // New Code Page differs from early defined
          Result := CMS_CodePage_ID_Wrong2;
          ErrAddInfo := 'Code Page ID differs from early defined'
        end
        else
        begin
        // 1-st set code page
          D4WCodePage := ACodePageID;
          CMSCodePage := ACodePageID;
          Result := ICMS.SetCodePage( ACodePageID );
          ErrAddInfo := CMSGetDumpErrString( Result );
        end
      end;
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin SetCodePage', Result );
end; //*** end of CMSSetCodePage

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetCurContext
//******************************************************** CMSSetCurContext ***
// Set current CMS View/Edit context
//
//     Parameters
// APatientID  - current Patient new ID
// AProviderID - current Provider new ID
// ALocationID - current Location new ID
// Result      - Returns function COM resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// If any given ID is equal to -1 then previouse context value should be used. 
// Call to SetCurContext(-1,-1,-1) does not change CMS View/Edit context.
//
// Function C prototype:
//#F
// DWORD CMSSetCurContext( int APatientID, int AProviderID, int ALocationID );
//#/F
//
function CMSSetCurContext( APatientID, AProviderID,
                           ALocationID: integer ) : LongWord; stdcall;
begin
  CMSShowTraceInfo( format( 'Start SetCurContext %d %d %d',
                         [APatientID, AProviderID, ALocationID] ), 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      Result := ICMS.SetCurContext( APatientID, AProviderID, ALocationID );
      ErrAddInfo := CMSGetDumpErrString( Result );
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin SetCurContext', Result );
end; //*** end of  CMSSetCurContext

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetCurContextEx
//****************************************************** CMSSetCurContextEx ***
// Set current CMS View/Edit context
//
//     Parameters
// APatientID     - current Patient new ID
// AProviderID    - current Provider new ID
// ALocationID    - current Location new ID
// ATeethRightSet - current filtering new Right side Teeth set
// ATeethLeftSet  - current filtering new Left side Teeth set
// Result         - Returns function COM resulting code:
//#F
// S_OK                            (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER                (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND  (0x800706BA) - Server is not responded
// -1                       (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// If any given ID is equal to -1 then previouse context value should be used. 
// Call to SetCurContext(-1,-1,-1) does not change CMS View/Edit context.
//
// Function C prototype:
//#F
// DWORD CMSSetCurContextEx( int APatientID, int AProviderID, int ALocationID,
//                           int ATeethRightSet, int ATeethLeftSet );
//#/F
//
function CMSSetCurContextEx( APatientID, AProviderID, ALocationID,
           ATeethRightSet, ATeethLeftSet: integer ) : LongWord; stdcall;
begin
  CMSShowTraceInfo( format( 'Start SetCurContextEx %d %d %d 0x%x 0x%x',
       [APatientID, AProviderID, ALocationID, ATeethRightSet, ATeethLeftSet] ), 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      Result := ICMS.SetCurContextEx( APatientID, AProviderID, ALocationID,
                                    ATeethRightSet, ATeethLeftSet );
      ErrAddInfo := CMSGetDumpErrString( Result );
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin SetCurContextEx', Result );
end; //*** end of  CMSSetCurContext

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetLocationsInfo
//***************************************************** CMSSetLocationsInfo ***
// Set All registered in D4W Locations Info
//
//     Parameters
// APLocationsInfo - All Locations needed info
// Result          - Returns function COM resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// E_INVALIDARG            (0x80070057) - wrong Locations data
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Locations Info string is Tab delimited Table. Each Table Row contains single 
// Location attributes. First Table Row contains Location attributes 
// identifiers:
//#F
//    LocationID  LocationTitle
//#/F
//
// Function C prototype:
//#F
// DWORD CMSSetLocationsInfo( LPCSTR APLocationsInfo );
//#/F
//
function CMSSetLocationsInfo( APLocationsInfo: PAnsiChar ): LongWord; stdcall;
var
  WStr : WideString;
begin
  CMSShowTraceInfo( 'Start SetLocationsInfo', 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      CMSTraceAnsiAddToFile( APLocationsInfo );
      WStr := CMS_AnsiToWide(APLocationsInfo);
      Result := ICMS.SetLocationsInfo( WStr );
      ErrAddInfo := CMSGetDumpErrString( Result );
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin SetLocationsInfo', Result );
end; //*** end of CMSSetLocationsInfo

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetPatientsInfo
//****************************************************** CMSSetPatientsInfo ***
// Set All registered in D4W Patients Info
//
//     Parameters
// APPatientsInfo - All Patients needed info
// Result         - Returns function COM resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// E_INVALIDARG            (0x80070057) - wrong Patients data
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Patients Info string is Tab delimited Table. Each Table Row contains single 
// Patient attributes. First Table Row contains Patient attributes identifiers:
//#F
//    PatientID PatientFirstName PatientSurname PatientGender PatientDOB
//#/F
//
// Function C prototype:
//#F
// DWORD CMSSetPatientsInfo ( LPCSTR APPatientsInfo  );
//#/F
//
function CMSSetPatientsInfo( APPatientsInfo: PAnsiChar ): LongWord; stdcall;
var
  WStr : WideString;
begin
  CMSShowTraceInfo( 'Start SetPatientsInfo', 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      if CMS_LogsCtrl then
        CMSTraceAnsiAddToFile( APPatientsInfo );
      WStr := CMS_AnsiToWide(APPatientsInfo);
      Result := ICMS.SetPatientsInfo( WStr );
      ErrAddInfo := CMSGetDumpErrString( Result );
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin SetPatientsInfo', Result );
end; //*** end of CMSSetPatientsInfo

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetProvidersInfo
//***************************************************** CMSSetProvidersInfo ***
// Set All registered in D4W Providers Info
//
//     Parameters
// APProvidersInfo - All Providers needed info
// Result          - Returns function COM resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// E_INVALIDARG            (0x80070057) - wrong Providers data
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Providers Info string is Tab delimited Table. Each Table Row contains single 
// Provider attributes. First Table Row contains Provider attributes 
// identifiers:
//#F
//    ProviderID ProviderFirstName ProviderSurname ProviderTitle
//#/F
//
// Function C prototype:
//#F
// DWORD CMSSetProvidersInfo( LPCSTR APProvidersInfo );
//#/F
//
function CMSSetProvidersInfo( APProvidersInfo: PAnsiChar ): LongWord; stdcall;
var
  WStr : WideString;
begin
  CMSShowTraceInfo( 'Start SetProvidersInfo', 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      if CMS_LogsCtrl then
        CMSTraceAnsiAddToFile( APProvidersInfo );
      WStr := CMS_AnsiToWide(APProvidersInfo);
      Result := ICMS.SetProvidersInfo( WStr );
      ErrAddInfo := CMSGetDumpErrString( Result );
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin SetProvidersInfo', Result );
end; //*** end of CMSSetProvidersInfo

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetWindowState
//******************************************************* CMSSetWindowState ***
// Set CMS Main Window State
//
//     Parameters
// AWinState - CMS Main Window State:
//#F
// -1 - hide,
//  0 - normal,
//  1 - minimized,
//  2 - maximized,
//  4 - normal (marked as foreground),
//  6 - maximized (marked as foreground).
//#/F
// Result    - Returns function COM resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// E_INVALIDARG            (0x80070057) - wrong Window State Code
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSSetWindowState ( int AWinState );
//#/F
//
function CMSSetWindowState( AWinState: Integer ): LongWord; stdcall;
var
  WinHandle: HWND;
  WinFocused : Boolean;
  OLEWinHandle : OleVariant;
  WinState: Integer;
  Result1 : LongWord;
begin
  CMSShowTraceInfo( format( 'Start SetWindowState %d', [AWinState] ), 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      WinState   := AWinState;
      WinFocused := WinState <> -1;
      if WinFocused then
      begin
        WinFocused := (WinState and 4) = 4;
        WinState := WinState and not 4;
      end;
      Result := ICMS.SetWindowState( WinState );
      ErrAddInfo := CMSGetDumpErrString( Result );
      if Succeeded( Result ) then
      begin
        if ((Result = S_OK) or (Result = 2)) and
           WinFocused then
        begin
          Result1 := ICMS.GetWindowHandle( OLEWinHandle );
          if not Succeeded( Result1 ) then
          begin
            CMSTraceAddToFile( 'Fin SetWindowState (WinFocused) >> ' + SysErrorMessage(Result1) );
            Exit;
          end;
          WinHandle := OLEWinHandle;
          Windows.SetForegroundWindow( WinHandle );
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin SetWindowState', Result );
end; //*** end of CMSSetWindowState

{
//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetAppModes
//********************************************************** CMSSetAppMode ***
// Set CMS Application Modes
//
//     Parameters
// AppModes - new Application Modes (set of bit flags):
//#F
//  bit0($00001)=1 - DEMO mode flag
//#/F
// Result   - Returns function COM resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSSetAppMode ( int AppMode );
//#/F
//
function  CMSSetAppMode( AppMode: Integer ): LongWord; stdcall;

  procedure ShowTraceInfo();
  begin
    CMSShowTraceInfo( 'SetAppMode' + format( '%d', [AppMode] ), Result );
  end;
begin
  try
    if ICMS = nil then
      Result := LongWord(E_POINTER)
    else
      Result := ICMS.SetAppMode( AppMode );
    ShowTraceInfo();
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
    ShowTraceInfo();
  end;
end; //*** end of CMSSetAppMode
}

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSGetPatientMediaCounter
//*********************************************** CMSGetPatientMediaCounter ***
// Get given Patient Media Objects Counter
//
//     Parameters
// APatID       - given patient ID
// APMediaCount - pointer to resulting media objects counter
// Result       - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// E_INVALIDARG            (0x80070057) - pointer to resulting media objects counter is NIL
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// E_PENDING               (0x8000000A) - CMS server is not ready
// E_ABORT                 (0x80004004) - Operation aborted because of CMS data
//                             access error (details in CMS protocol)
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSGetPatientMediaCounter ( int APatID, int * APMediaCount );
//#/F
//
function CMSGetPatientMediaCounter( APatID: Integer;
                                    APMediaCounter: PInteger ): LongWord; stdcall;
var
  MediaCount : OleVariant;

begin
  CMSShowTraceInfo( format( 'Start GetPatientMediaCounter PatID=%d', [APatID] ), 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      Result := LongWord(E_INVALIDARG);
      ErrAddInfo := 'Pointer to result is NULL';
      if APMediaCounter <> nil then begin
        Result := ICMS.GetPatientMediaCounter( APatID, MediaCount );
        APMediaCounter^ := MediaCount;
        ErrAddInfo := CMSGetDumpErrString( Result );
      end;
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( format( 'Fin GetPatientMediaCounter PatID=%d Count=%d', [APatID, APMediaCounter^] ), Result );
//  CMSShowTraceInfo( 'Fin GetPatientMediaCounter', Result );
end; //*** end of CMSGetPatientMediaCounter

{
//************************************************* CMSGetWindowHandle ***
// Get CMS Main Window Handle
//
//     Parameters
// APWinHandle  - pointer to CMS Main Window Handle as Integer
// Result       - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSGetWindowHandle ( int * APWinHandle );
//#/F
//
function  CMSGetWindowHandle( APWinHandle: PInteger): LongWord; stdcall;
var
  WinHandle : OleVariant;
begin
  try
    if ICMS = nil then
      Result := LongWord(E_POINTER)
    else begin
      Result := ICMS.GetWindowHandle( WinHandle );
      APWinHandle^ := WinHandle;
    end;
    CMSShowTraceInfo( 'GetWindowHandle', Result );
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
    CMSShowTraceInfo( 'GetWindowHandle', Result );
  end;
end; //*** end of CMSGetWindowHandle
}


//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSGetServerInfo
//******************************************************** CMSGetServerInfo ***
// Get CMS Server Info string
//
//     Parameters
// AInfoCode   - CMS Server Info Code
//#F
//  0 - CMS Server Build Code
//  2 - get CMS COM-server state
//#/F
// APStrBuf    - pointer to text buffer start byte or NIL just to get resulting
//               Info string length
// APBufLength - pointer to text buffer length, if just get resulting
//               Info string length, then BufLength on input should be 255
// Result      - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// E_INVALIDARG            (0x80070057) - wrong AInfoCode or text buffer length < 2
//                                        or pointer to text buffer length = NULL
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSGetServerInfo ( int AInfoCode, LPCSTR APStrBuf, int * AStrBufLength );
//#/F
//
function  CMSGetServerInfo( AInfoCode : Integer; APStrBuf: PAnsiChar;
                            APBufLength : PInteger ): LongWord; stdcall;
var
  AppInfo : OleVariant;
  AppInfoStr : AnsiString;

  procedure CopyToResult();
  var
    BufLength : Integer;
  begin
    BufLength := 0;
    if APBufLength <> nil then
    begin
      BufLength := APBufLength^;
      if BufLength > Length(AppInfoStr) then
        BufLength := Length(AppInfoStr) + 1;
      APBufLength^ := BufLength;
    end;
    if (APStrBuf <> nil) and (BufLength > 0) then
    begin
      if BufLength > 1 then
        Move( AppInfoStr[1], APStrBuf^, BufLength - 1 );
      (APStrBuf + BufLength - 1)^ := AnsiChar(0);
      CMSShowTraceInfo( 'ServerInfo:' + CMS_AnsiToString(APStrBuf), Result );
    end;
  end; // procedure CopyToResult

begin
  CMSShowTraceInfo( format( 'Start GetServerInfo %d', [AInfoCode] ), 0 );
  try
    if (AInfoCode = 0) and (CMSBuildNumber <> '') then
    begin
      AppInfoStr := CMS_StringToAnsi(CMSBuildNumber);
      Result := S_OK;
      CopyToResult();
    end
    else if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      Result := LongWord(E_INVALIDARG);
      ErrAddInfo := 'Wrong Info Code or Text Buffer Length or Pointer';
      if (APBufLength <> nil) and (AInfoCode >= 0) then
      begin
      // Proper Parameters
        Result := ICMS.GetServerInfo( AInfoCode, AppInfo );
        if Result = S_OK then
        begin
          AppInfoStr := CMS_StringToAnsi(AppInfo);
          CopyToResult();
        end
        else
          ErrAddInfo := CMSGetDumpErrString( Result );
      end;
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin GetServerInfo', Result );
end; //*** end of CMSGetServerInfo

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetIniInfo
//*********************************************************** CMSSetIniInfo ***
// Set CMSuite Application Properties by Info in Ini-File Format
//
//     Parameters
// APIniInfo - pointer to text with CMSuite Application Properties in Ini-File 
//             Format
// Result    - Returns function COM resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// CMSuite Application Modes should be in Ini-File Format:
//#F
//[IniSectionName1]
//<PropertyName1>=<PropertyValue>
//...
//<PropertyNameN>=<PropertyValue>
//
//...
//
//[IniSectionNameK]
//<PropertyName1>=<PropertyValue>
//...
//<PropertyNameN>=<PropertyValue>
//#/F
//
// Function C prototype:
//#F
// DWORD CMSSetIniInfo ( LPCSTR APIniInfo  );
//#/F
//
function CMSSetIniInfo( APIniInfo: PAnsiChar ): LongWord; stdcall;
var
  WStr : WideString;
begin
  CMSShowTraceInfo( 'Start SetIniInfo', 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      WStr := CMS_AnsiToWide(APIniInfo);
      Result := ICMS.SetIniInfo( WStr );
      ErrAddInfo := CMSGetDumpErrString( Result );
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin SetIniInfo', Result );
end; //*** end of CMSSetIniInfo

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSExecUICommand
//******************************************************** CMSExecUICommand ***
// Execute CMSuite Application UI Command
//
//     Parameters
// AComCode - CMS UI Command Code:
//#F
//  0 - Select Media Object in CMSuite Main Window Thumbnailes Frame (add to selected)
//      AComInfo - string with Media Object ID
//  1 - Unselect Media Object in CMS Main Window Thumbnailes Frame (remove from selected)
//      AComInfo - string with Media Object ID
//  2 - Execute UI Action
//      AComInfo - UI Action Name:
//        MediaClearSelection  - Clear Media Objects Selection in CMS Main Window Thumbnailes Frame
//        MediaOpen            - Open Media Object selected in CMS Main Window Thumbnailes Frame
//        CMSClose             - Close CMS Application (needed for close CMS after Modal Window Close)
//        RemoveCMSClose       - Remove Close CMS Application Request (needed to remove buffered CMSClose command)
//  3 - Set Window State UI Action
//      AComInfo - string with Window State Code:
//     -1 - hide,
//      0 - normal,
//      1 - minimized,
//      2 - maximized,
//      4 - normal (marked as foreground),
//      6 - maximized (marked as foreground).
//#/F
// AComInfo - pointer to text with CMSuite UI Command Info
// Result   - Returns function COM resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// E_INVALIDARG            (0x80070057) - wrong AComeCode or wrong UI Action Name
//                                        (=AComInfo) if AComCode = 2 or Media Object to
//                                        select or unselect is absent
// E_UNEXPECTED            (0x8000FFFF) - Server Catastrophic failure while UI Action execute
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSExecUICommand ( int AComCode, LPCSTR AComInfo );
//#/F
//
function  CMSExecUICommand( AComCode : Integer; APComInfo: PAnsiChar ): LongWord; stdcall;
var
 WStr : WideString;
begin
  CMSShowTraceInfo( Format( 'Start ExecUICommand CODE=%d INFO=%s', [AComCode,
                            CMS_AnsiToString(APComInfo)]), 0 );
//  CMSTraceAnsiAddToFile( APComInfo );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      WStr := CMS_AnsiToWide(APComInfo);
      Result := ICMS.ExecUICommand( AComCode, WStr );
      ErrAddInfo := CMSGetDumpErrString( Result );
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin ExecUICommand', Result );
end; //*** end of CMSExecUICommand

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSCopyMovePatSlides
//**************************************************** CMSCopyMovePatSlides ***
// Copy/move all slides from one patient to another
//
//     Parameters
// ASrcPatID - given source patient ID
// ASrcPatID - given destination patient ID
// ACopyFlag - copy/move slides mode (=0 means move mode, <> 0 copy mode
// Result    - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// S_PAT_IN_USE                   (0x3) - CMS works with Source or Destination
//                                        Patient on some computer
// S_DATA_IN_USE                  (0x4) - Source Patient Slides are used by
//                                        some CMS Users
// S_COPY_FAILS                   (0x5) - Copy files error
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// E_PENDING               (0x8000000A) - CMS server is not ready
// E_INVALIDARG            (0x80070057) - ASrcPatID is not number, ADstPatID is not number,
//                                        or ACopyFlag is not number, or
//                                        ASrcPatID is equal to ADstPatID
// E_ABORT                 (0x80004004) - Operation aborted because of CMS data
//                             access error (details in CMS protocol)
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSCopyMovePatSlides( int ASrcPatID, int APatDstID, int ACopyFlag );
//#/F
//
function CMSCopyMovePatSlides( ASrcPatID, APatDstID, ACopyFlag: Integer ): LongWord; stdcall;
var
  ASTR : AnsiString;
begin
  ASTR := CMS_StringToAnsi( format('%d,%d,%d', [ASrcPatID, APatDstID, ACopyFlag]) );
  Result := CMSExecUICommand( 4, @ASTR[1] );
end; //*** end of CMSCopyMovePatSlides

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetUpdateMode
//******************************************************** CMSSetUpdateMode ***
// Set Update CMS DB Providers and Locations Info Mode on CMS start
//
//     Parameters
// AUMode - update mode:
//#F
// 1 - only Providers Data update
// 2 - only Locations Data update
// any othey value means update both
//#/F
// Result - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Indicates that COM Server Application is closing
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// E_PENDING               (0x8000000A) - CMS server is not ready
// E_ABORT                 (0x80004004) - Operation aborted because of CMS data
//                             access error (details in CMS protocol)
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Update CMS DB Providers and Locations Data by info set using 
// CMSSetProvidersInfo and CMSSetLocationsInfo.
//
// The procedure should be called just after CMSSetProvidersInfo and/or 
// CMSSetLocationsInfo call before first call to CMSSetCurContext or 
// CMSSetCurContextEx
//
// Function C prototype:
//#F
// DWORD CMSSetUpdateMode( int AUMode );
//#/F
//
function CMSSetUpdateMode( AUMode: Integer ): LongWord; stdcall;
var
  ASTR : AnsiString;
begin
  ASTR := CMS_StringToAnsi( IntToStr(AUMode) );
  Result := CMSExecUICommand( 5, @ASTR[1] );
end; //*** end of CMSSetUpdateMode

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSPrepPatSlidesAttrs
//*************************************************** CMSPrepPatSlidesAttrs ***
// Prepare Patient Media Objects Attributes
//
//     Parameters
// APatID        - Patient ID
// APAttrsLength - pointer to resulting Media Objects Attributes Size value
// Result        - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_FALSE                        (0x1) - Resulting Data is absent
// E_UNEXPECTED            (0x8000FFFF) - DB Connection Error
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//#F
//            Possible Fileds Info
// Name           Type    Comment
// ObjID	        Integer	Object identifier
// ObjType	      Integer	Object type code: 0 - Image, 1 - Video, 2 - Study
// DateTaken	    string	Object taken date (dd.mm.yyyy)
// TimeTaken	    string	Object taken time (hh:nn:ss)
// TeethLeftSet	  Integer	Object "left" teeth numbering designation (appendix A)
// TeethRightSet	Integer	Object "right" teeth numbering designation (appendix A)
// TeethSetCapt   string  Object teeth numbering caption
// MediaTypeID	  Integer	Object media type identifier
// MediaTypeName  Integer	Object media type name
// Source	        string	Object  source description
// ObjStudyID	    Integer	Bigger than 0 - object study ID for objects linked to studies
//                        Less than 0 - for studies,
//                        0 - for objects not linked to studies,
// PixWidth	      Integer	Image and Video objects width in pixels
// PixHeight	    Integer	Image and Video objects height in pixels
// PixColorDepth	Integer	Image and Video objects color depth (8 - 16 for grey, 24 for color)
// VideoDuration	Float	  Video objects duration in seconds
// ModifyDate	    string	Object modify date (dd.mm.yyyy)
// ModifyTime	    string	Object modify time (hh:nn:ss)
//#/F
//
// Function C prototype:
//#F
// DWORD CMSPrepPatSlidesAttrs ( int APatID, int * APAttrsLength );
//#/F
//
function  CMSPrepPatSlidesAttrs( APatID : Integer; APAttrsLength  : PInteger ): LongWord; stdcall;
var
  AVData : OleVariant;
  VBufer : Variant;
  Buf : TN_BArray;
  ResCount, i, j, IVal : Integer;
  Fields : string;
  SL : TStringList;
  SLBuf : TStringList;
  CurField : string;
  CurStr : string;
  DateTaken : TDateTime;
begin
  CMSShowTraceInfo( 'Start CMSPrepPatSlidesAttrs', 0 );
  Buf := nil;
  SL := nil;
  SLBuf := nil;
  CMSSlidesAttrsStr := '';
  APAttrsLength^ := 0;
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin // if ICMS <> nil then
      SL := TStringList.Create;
      Fields := 'ObjID'#9'ObjType'#9'DateTaken'#9'TimeTaken'#9'TeethLeftSet'#9'TeethRightSet';
      SL.Delimiter := #9;
      SL.DelimitedText := Fields;
      Result := ICMS.GetSlidesAttrs( APatID, 0, CMS_StringToWide(Fields), AVData );
      if Result = S_OK then
      begin
        VBufer := AVData;
        DynArrayFromVariant( Pointer(Buf), VBufer, TypeInfo(TK_BArray));

        if CMSSBuf = nil then
          CMSSBuf := TN_SerialBuf0.Create();

        CMSSBuf.SetDataFromMem( Buf[0], Length(Buf) );
        CMSSBuf.GetRowInt( ResCount );
        SLBuf := TStringList.Create;
        SLBuf.Add( Fields );
        for i := 0 to ResCount - 1 do
        begin
          CMSSBuf.GetRowInt( IVal );
          CurStr := IntTostr( IVal );
          DateTaken := 0;
          for j := 1 to SL.Count - 1 do
          begin
            CurField := SL[j];
            if CurField = 'ObjType' then
            begin
              CMSSBuf.GetRowInt( IVal );
              CurStr := format( '%s'#9'%d', [CurStr,IVal] );
            end
            else
            if CurField = 'DateTaken' then
            begin
              if DateTaken = 0 then
                CMSSBuf.GetRowDouble( Double(DateTaken) );
              CurStr := format( '%s'#9'%s', [CurStr,FormatDateTime( 'dd.mm.yyyy', DateTaken )] );
            end
            else
            if CurField = 'TimeTaken' then
            begin
              if DateTaken = 0 then
                CMSSBuf.GetRowDouble( Double(DateTaken) );
              CurStr := format( '%s'#9'%s', [CurStr,FormatDateTime( 'hh:nn:ss', DateTaken )] );
            end
            else
            if CurField = 'TeethLeftSet' then
            begin
              CMSSBuf.GetRowInt( IVal );
              CurStr := format( '%s'#9'%d', [CurStr,IVal] );
            end
            else
            if CurField = 'TeethRightSet' then
            begin
              CMSSBuf.GetRowInt( IVal );
              CurStr := format( '%s'#9'%d', [CurStr,IVal] );
            end;
          end; // for j := 1 to SL.Count - 1 do
          SLBuf.Add( CurStr );

        end; // for i := 0 to ResCount - 1 do

        CMSSlidesAttrsStr := CMS_StringToAnsi( SLBuf.Text );

        APAttrsLength^ := Length(CMSSlidesAttrsStr) + 1;
      end // if Result = S_OK then
      else
      if Result = S_FALSE then
       ErrAddInfo := 'Patient data is absent'
      else
      if Result = LongWord(E_UNEXPECTED) then
        ErrAddInfo := 'CMS DB Connection Error'
      else
        ErrAddInfo := CMSGetDumpErrString( Result );
      SL.Free;
      SLBuf.Free;
    end; // if ICMS <> nil then
  except
    on E: Exception do
    begin
      SLBuf.Free;
      SL.Free;
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin CMSPrepPatSlidesAttrs', Result );
end; //*** end of CMSPrepPatSlidesAttrs

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSGetPatSlidesAttrs
//**************************************************** CMSGetPatSlidesAttrs ***
// Get Current Patient Media Objects attributes
//
//     Parameters
// APAttrsBuf - pointer to Ansi string buffer start char
// ABufLength - buffer length in chars to control buffer memory size
// Result     - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CMS_AttrsBufSize_Wrong6 (0xA0000007) - Wrong Media Objects Attributes Buffer Size
//#/F
//
// Function C prototype:
//#F
// DWORD CMSGetPatSlidesAttrs (  * APAttrsBuf, int ABufLength );
//#/F
//
function CMSGetPatSlidesAttrs( APAttrsBuf: PAnsiChar; ABufLength : Integer ) : LongWord; stdcall;
var
  NeededSize : Integer;
begin
  CMSShowTraceInfo( 'Start CMSGetPatSlidesAttrs', 0 );

  if ICMS = nil then
  begin
    Result := LongWord(E_POINTER);
    ErrAddInfo := 'CMS server is not started';
  end
  else
  begin
    Result := S_OK;
    NeededSize := Length(CMSSlidesAttrsStr) + 1;
    if NeededSize > ABufLength then
    begin
      ErrAddInfo := format( 'Wrong Media Objects Attributes Buffer Size %d <> %d',
                            [NeededSize,ABufLength] );
      Result := CMS_AttrsBufSize_Wrong6;
    end
    else
      Move( CMSSlidesAttrsStr[1], APAttrsBuf^, NeededSize );
    CMSSlidesAttrsStr := '';
  end;

  CMSShowTraceInfo( 'Fin CMSGetPatSlidesAttrs', Result );
end; // end of CMSGetPatSlidesAttrs

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSPrepThumbnails
//******************************************************* CMSPrepThumbnails ***
// Prepare Thumbnails for Media Objects given by ID
//
//     Parameters
// ASrcIDs      - pointer to Tab (#9) delimited text  with Media Objects IDs
// ASrcIDsCount - number of given Media Objects IDs
// APThumbsSize - pointer to resulting Thumbnails Data Size integer array start 
//                element, Thumbnails Data Size array should have ASrcIDsCount 
//                items
// Result       - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// CMS_ThumbsCount_Wrong3  (0xA0000004) - Wrong Resulting Thumbnails Count
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// If some given Media Objects are absent then corresponding Thumbnail Data size
// is 0.
//
// Function C prototype:
//#F
// DWORD CMSPrepThumbnails ( LPSTR APSrcIDs, int ASrcIDsCount, int * APThumbsSize );
//#/F
//
function  CMSPrepThumbnails( APSrcIDs : PAnsiChar; ASrcIDsCount : Integer;
                             APThumbsSize : PInteger ): LongWord; stdcall;
var
  ASThumbs : OleVariant;
  VBufer : Variant;
  Buf : TN_BArray;
  ResCount, i, CurSize : Integer;
  WStr : WideString;
begin
  CMSShowTraceInfo( 'Start CMSPrepThumbnails >> ' + CMS_AnsiToString(APSrcIDs), 0  );
  Buf := nil;
  CMSThumbsOffsets := nil;
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin // if ICMS <> nil then
      WStr  := CMS_AnsiToWide(APSrcIDs);
      Result := ICMS.GetSlidesThumbnails( WStr, 0, ASThumbs );
      if Result = S_OK then
      begin
        VBufer := ASThumbs;
        DynArrayFromVariant( Pointer(Buf), VBufer, TypeInfo(TK_BArray));
        if CMSSBuf = nil then
          CMSSBuf := TN_SerialBuf0.Create();

        CMSSBuf.SetDataFromMem( Buf[0], Length(Buf) );
        CMSSBuf.GetRowInt( ResCount );
        SetLength( CMSThumbsOffsets, 0 );
        if ResCount <> ASrcIDsCount then
        begin
          ErrAddInfo := format( 'Resulting Thumbnails Count %d <> %d ', [ResCount,ASrcIDsCount] );
          Result := CMS_ThumbsCount_Wrong3;
        end
        else
        begin
          SetLength( CMSThumbsOffsets, ResCount );
          for i := 0 to ResCount - 1 do
          begin
            CMSThumbsOffsets[i] := CMSSBuf.CurOfs;
            CMSSBuf.GetRowInt( CurSize );
            APThumbsSize^ := CurSize;
            Inc(APThumbsSize);
            CMSSBuf.SetCurOffset( CMSSBuf.CurOfs + CurSize );
          end;
        end;
      end // if Result = S_OK then
      else
      if Result = LongWord(E_UNEXPECTED) then
        ErrAddInfo := 'CMS DB Connection Error'
      else
        ErrAddInfo := CMSGetDumpErrString( Result );
    end; // if ICMS <> nil then
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin CMSPrepThumbnails', Result );
end; //*** end of CMSPrepThumbnails

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSGetThumbnail
//********************************************************* CMSGetThumbnail ***
// Get Thumbnail retrieved by CMSPrepThumbnails
//
//     Parameters
// AThumbInd  - Thumbnail index
// APBuf      - pointer to thumbnail buffer array start element
// ABufLength - buffer length in bytes to control buffer memory size
// Result     - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CMS_ThumbInd_Wrong4     (0xA0000005) - Wrong Thumbnail index
// CMS_ThumbBufSize_Wrong5 (0xA0000006) - Wrong Thumbnail buffer length
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSGetThumbnail ( int AThumbInd, byte * APBuf, int ABufSize );
//#/F
//
function  CMSGetThumbnail( AThumbInd : Integer; APBuf : PByte;
                           ABufLength : Integer ): LongWord; stdcall;
var
  CurSize : Integer;

begin
  CMSShowTraceInfo( 'Start CMSGetThumbnail', 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      Result := S_OK;
      if (AThumbInd < 0) or (AThumbInd > High(CMSThumbsOffsets)) then
      begin
        ErrAddInfo := format( 'Wrong Thumbnail Index %d [0-%d] ',
                              [AThumbInd,Length(CMSThumbsOffsets)] );
        Result := CMS_ThumbInd_Wrong4;
      end
      else
      begin
        CMSSBuf.SetCurOffset( CMSThumbsOffsets[AThumbInd] );
        CMSSBuf.GetRowInt( CurSize );
        if CurSize <> ABufLength then
        begin
          ErrAddInfo := format( 'Wrong Thumbnail buffer size %d <> %d',
                                [CurSize,ABufLength] );
          Result := CMS_ThumbBufSize_Wrong5;
        end
        else
          Move( CMSSBuf.PCur()^, APBuf^, CurSize );
      end;
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin CMSGetThumbnail', Result );
end; // end of CMSGetThumbnail

//**************************************************** CMSGetSlideImageFile ***
// Get given slide Image file
//
//     Parameters
// ASlideID   - Source Slide ID
// AMaxWidth  - Media Object image maximal width on input, if =0 then image
//              original width will be used, resulting Image real width will be
//              defined automatically using Media Object image aspect
//              and will be returned on output
// AMaxHeight - Media Object image maximal height on input, if =0 then image
//              original height will be used, resulting Image real height will be
//              defined automatically using Media Object image aspect
//              and will be returned on output
// AFileFormat - resulting Image file format code: low decimal position is format type
//               (1 - bmp, 3 - jpg, 4 - tif, 5 - png), the two next decimal positions
//               coding jpg quality from 01 to 99, if not set then highest quality 100
//               will be used (e.g. 503 means JPEG file format with quality=50)
// AViewCont   - resulting Image file content code:
//#F
//  0 - current image with annotations
//  1 - current image without annotations
//  2 - image original state without annotations
//#/F
// AFileName   - Resulting file full Name including Path
// Result      - Returns function COM resulting code.
//#F
// S_OK                                   (0x0) - Indicates that given media object
//                                                Image File was created
// CMS_Object_Wrong_ID             (0xA0000201) - Given Media Object has wrong ID
// CMS_Object_HasNo_Image          (0xA0000202) - Given Media Object has no Image represantation
// CMS_Create_Image_OutOffMemory   (0xA0000203) - There is not enough memory to create image
// CMS_Create_Image_Internal_Error (0xA0000204) - Create Image internal error
// CO_E_SERVER_NOT_RESPOND         (0x800706BA) - COM Server is not responded
// E_POINTER                       (0x80004003) - Try to use function before CMS server start
// E_UNEXPECTED                    (0x8000FFFF) - Indicates unexpected COM error.
// -1                              (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
function CMSGetSlideImageFile( ASlideID: integer; APMaxWidth, APMaxHeight : PInteger;
                               AFileFormat, AViewCont: integer; AFileName : PAnsiChar ) : LongWord; stdcall;
var
  MaxWidth, MaxHeight, SInfo : OleVariant;
  SInfoStr : string;
  FileName : WideString;
label Fin;
begin
  MaxWidth  := APMaxWidth^;
  MaxHeight := APMaxHeight^;
  CMSShowTraceInfo( format( 'Start CMSGetSlideImageFile %d MWH=%dx%d FF=%d V=%d %s',
                         [ASlideID, APMaxWidth^, APMaxHeight^,AFileFormat,AViewCont,
                         CMS_AnsiToString(AFileName)] ), 0 );

  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      Result := ICMS.GetServerInfo( 2, SInfo );
      SInfoStr := SInfo;
      if (S_OK = Result)  and
         (SInfoStr <> '') then // Server is live
      begin
        //Server is needed to switch to FileAccess mode in 'NOTINIT', 'SLEEP'
        if ((SInfoStr[1] = 'N') and (SInfoStr[4] = 'I')) // Server is NOTINIT
                   or
           (SInfoStr[1] = 'S') then                      // Server is SLEEP
          ICMS.StartSession( 1 ); // StartSession switch server to FileAccess mode

        while (SInfoStr[1] = 'N') do
        begin // Wait while Server is not ready to do GetSlideImageFile
          sleep(10);
          Result := ICMS.GetServerInfo( 2, SInfo );
          if S_OK <> Result then
          begin
            ErrAddInfo := 'Wait CMS server init';
            goto Fin;
          end;
          SInfoStr := SInfo;
        end; // Wait while Server is not ready to do get GetSlideImageFile

        //Server ready to do GetSlideImageFile in 'READY', 'BUSY', 'FSACCESS'
        FileName := CMS_AnsiToWide(AFileName);
        Result := ICMS.GetSlideImageFile( ASlideID, MaxWidth, MaxHeight, AFileFormat, AViewCont, FileName );
        APMaxWidth^ := MaxWidth;
        APMaxHeight^ := MaxHeight;
      end; // if Server is live
Fin: //*****
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin CMSGetSlideImageFile', Result );
end; // function CMSGetSlideImageFile

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSHPSetCurContext
//****************************************************** CMSHPSetCurContext ***
// Set current CMS High Resolution Preview context
//
//     Parameters
// APatientID  - current Patient new ID
// AProviderID - current Provider new ID
// ALocationID - current Location new ID
// Result      - Returns function COM resulting code:
//#F
// S_OK                           (0x0) - Indicates that call was OK
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// Function C prototype:
//#F
// DWORD CMSHPSetCurContext( int APatientID, int AProviderID, int ALocationID );
//#/F
//
function CMSHPSetCurContext( APatientID, AProviderID,
                             ALocationID: integer ) : LongWord; stdcall;
begin
  CMSShowTraceInfo( format( 'Start HPSetCurContext %d %d %d',
                         [APatientID, AProviderID, ALocationID] ), 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin
      Result := ICMS.HPSetCurContext( APatientID, AProviderID, ALocationID );
      ErrAddInfo := CMSGetDumpErrString( Result );
    end;
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin HPSetCurContext', Result );
end; //*** end of  CMSHPSetCurContext

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSHPSetVisibleIcons
//**************************************************** CMSHPSetVisibleIcons ***
// Set Media Objects set visible in High Resolution Preview Film Strip
//
//     Parameters
// AVisIDs - pointer to Tab (#9) delimited text with Media Objects IDs for Film 
//           Strip
// AMode   - open Media Objects Mode while open Media Suite from Hr Preview
//#F
//  0 - only selected Media Object will be open
//  1 - all Media Object from Film Strip will be open
//#/F
// Result  - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// If some given Media Objects are absent then corresponding Thumbnail Data size
// is 0.
//
// Function C prototype:
//#F
// DWORD CMSHPSetVisibleIcons( LPSTR AVisIDs, int AMode );
//#/F
//
function  CMSHPSetVisibleIcons( AVisIDs : PAnsiChar; AMode : Integer ): LongWord; stdcall;
var
  WStr : WideString;
begin
  CMSShowTraceInfo( 'Start CMSHPSetVisibleIcons >> ' + CMS_AnsiToString(AVisIDs), 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin // if ICMS <> nil then
      WStr  := CMS_AnsiToWide(AVisIDs);
      Result := ICMS.HPSetVisibleIcons( WStr, AMode );
      ErrAddInfo := CMSGetDumpErrString( Result );
    end; // if ICMS <> nil then
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin CMSHPSetVisibleIcons', Result );
end; // end of CMSHPSetVisibleIcons

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSHPViewMediaObject
//**************************************************** CMSHPViewMediaObject ***
// View Media Object in High Resolution Preview Mode
//
//     Parameters
// AViewID - pointer to text with Media Object ID to show in High Resolution 
//           Mode
// Result  - Returns function COM resulting code.
//
//#F
// S_OK                           (0x0) - Indicates that call was OK
// S_BUSY                         (0x2) - Indicates that CMS server is busy,
//                                        the action was saved in buffer and
//                                        will be executed later.
// E_POINTER               (0x80004003) - Try to use function before CMS server start
// CO_E_SERVER_NOT_RESPOND (0x800706BA) - Server is not responded
// -1                      (0xFFFFFFFF) - Unknown DLL exception was raised.
//#/F
//
// If some given Media Objects are absent then corresponding Thumbnail Data size
// is 0.
//
// Function C prototype:
//#F
// DWORD CMSHPViewMediaObject( LPSTR AViewID );
//#/F
//
function  CMSHPViewMediaObject( AViewID : PAnsiChar ): LongWord; stdcall;
var
  WStr : WideString;
begin
  CMSShowTraceInfo( 'Start CMSHPViewMediaObject >> ' + CMS_AnsiToString(AViewID), 0 );
  try
    if ICMS = nil then
    begin
      Result := LongWord(E_POINTER);
      ErrAddInfo := 'CMS server is not started';
    end
    else
    begin // if ICMS <> nil then
      WStr  := CMS_AnsiToWide(AViewID);
      Result := ICMS.HPViewMediaObject( WStr );
      ErrAddInfo := CMSGetDumpErrString( Result );
    end; // if ICMS <> nil then
  except
    on E: Exception do
    begin
      Result := $FFFFFFFF; // Unknown Exception
      ErrAddInfo := 'Unknown Exception >> ' + E.Message;
    end;
  end;
  CMSShowTraceInfo( 'Fin CMSHPViewMediaObject', Result );
end; // end of CMSHPViewMediaObject

//##path K_Delphi\SF\K_MVDar\K_CMSComLib.pas\CMSSetTraceInfo
//********************************************************* CMSSetTraceInfo ***
// Set Trace Info
//
//     Parameters
// APTraceFName - Pointer to Trace File Name
// ATraceMode   - Trace Info collection mode:
//#F
// -1 - skip Trace Info collection
//  0 - only Errors Info is added to Trace
//  1 - all  Functions Info is added to Trace
//#/F
//
// Function C prototype:
//#F
// VOID CMSSetTraceInfo ( LPCSTR APTraceFName, int ATraceMode );
//#/F
//
procedure CMSSetTraceInfo( APTraceFName: PAnsiChar; ATraceMode: Integer ); stdcall;
var
//  WBuf : array [0..100] of WideChar;
//  RSize : Integer;
  BPath : string;
  EnvVarVal : string;
  WTSSessionInfo : TK_WTSSessionInfo;

const
  SM_REMOTESESSION = 1000;
  USERNAME = 'USERNAME';

begin
  LogFName := CMS_AnsiToString( APTraceFName );
  if ATraceMode = -1 then
    LogFName := '';
//  LogTraceAll := ATraceMode = 1;
  if LogFName = '' then Exit;

  BPath := '';
  // Add CLIENTNAME Subfolder if TerminalServer Session
  K_WTSGetSessionInfo( @WTSSessionInfo );
  if WTSSessionInfo.WTSClientProtocolType > WTS_PROTOCOL_TYPE_CONSOLE then
    BPath := WTSSessionInfo.WTSClientName + '\';

  // Get USERNAME for Subfolder
//  RSize := GetEnvironmentVariableW( PWideChar(CMS_StringToWide(USERNAME)), @WBuf[0], 100 );
//  if RSize < 100 then
//    BPath := BPath + CMS_WideToString( PWideChar(@WBuf[0]) ) + '\';

  EnvVarVal := GetEnvironmentVariable( USERNAME );
  if EnvVarVal <> ''  then
    BPath := BPath + EnvVarVal + '\';

  EnvVarVal := GetEnvironmentVariable( 'CMS_LOGS' );
  if EnvVarVal <> '' then
    BPath := IncludeTrailingPathDelimiter(EnvVarVal) + 'LogFiles\' + BPath
  else
    BPath := ExtractFilePath(LogFName) + BPath;
  ForceDirectories( BPath );
  LogFName := BPath + ExtractFileName(LogFName);

  LogTraceAll := TRUE;

  CMSCheckTraceSize( );
  CMSTraceAnsiAddToFile( ' ' );
  CMSTraceAnsiAddToFile( ' ' );
  CMSTraceAddToFile( '****** Start at ' + FormatDateTime( 'yyyy-mm-dd-hh":"nn":"ss.zzz', Now() ) +
                     ' CMSLIB Trace in ' + LogFName  );
  if SizeOf(Char) = 2 then

{$IF CompilerVersion >= 26.0} // Delphi >= XE5
    CMSTraceAnsiAddToFile( '****** Compiled by Delphi XE5 ver=' +
                           CMS_StringToAnsi(IntTostr(K_CMSComLibVer)) )
{$ELSE}         // Delphi 2010
    CMSTraceAnsiAddToFile( '****** Compiled by Delphi 2010 ver=' +
                           CMS_StringToAnsi(IntTostr(K_CMSComLibVer)) )
{$IFEND CompilerVersion >= 26.0}
  else
    CMSTraceAnsiAddToFile( '****** Compiled by Delphi 7 ver=' +
                           CMS_StringToAnsi(IntTostr(K_CMSComLibVer)) );
end; // procedure CMSSetTraceInfo

Initialization
  CoInitialize( nil );

  K_S2A := CMS_StringToAnsi;

  K_A2S := CMS_AnsiToString;
  K_S2W := CMS_StringToWide;
  K_CalcNewCapacity := CMS_NewCapacity;

Finalization
  CMSSBuf.Free;

end.
