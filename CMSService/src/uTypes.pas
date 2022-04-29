unit uTypes;

interface

uses
  System.SysUtils, System.Classes, Types,
  Winapi.Windows, Winapi.Messages,
  TlHelp32, DSiWin32, ShLwApi;

type
  WTS_INFO_CLASS = (
    WTSInitialProgram,
    WTSApplicationName,
    WTSWorkingDirectory,
    WTSOEMId,
    WTSSessionId,
    WTSUserName,
    WTSWinStationName,
    WTSDomainName,
    WTSConnectState,
    WTSClientBuildNumber,
    WTSClientName,
    WTSClientDirectory,
    WTSClientProductId,
    WTSClientHardwareId,
    WTSClientAddress,
    WTSClientDisplay,
    WTSClientProtocolType,
    WTSIdleTime,
    WTSLogonTime,
    WTSIncomingBytes,
    WTSOutgoingBytes,
    WTSIncomingFrames,
    WTSOutgoingFrames,
    WTSClientInfo,
    WTSSessionInfo,
    WTSSessionInfoEx,
    WTSConfigInfo,
    WTSValidationInfo,
    WTSSessionAddressV4,
    WTSIsRemoteSession
  );

  WTS_CONNECTSTATE_CLASS = (
    WTSActive,
    WTSConnected,
    WTSConnectQuery,
    WTSShadow,
    WTSDisconnected,
    WTSIdle,
    WTSListen,
    WTSReset,
    WTSDown,
    WTSInit
  );

  PWTS_SESSION_INFO = ^WTS_SESSION_INFO;
  WTS_SESSION_INFO = record
    SessionId: DWORD;
    pWinStationName: LPTSTR;
    State: WTS_CONNECTSTATE_CLASS;
  end;

const
  WTS_CURRENT_SERVER_HANDLE: THandle = 0;

function WTSEnumerateSessions(hServer: THandle; Reserved: DWORD; Version: DWORD; var ppSessionInfo: PWTS_SESSION_INFO; var pCount: DWORD): BOOL; stdcall; external 'Wtsapi32.dll' name {$IFDEF UNICODE}'WTSEnumerateSessionsW'{$ELSE}'WTSEnumerateSessionsA'{$ENDIF};

function WTSQuerySessionInformation(hServer: THandle; SessionId: DWORD; WTSInfoClass: WTS_INFO_CLASS; var ppBuffer: LPTSTR; var pBytesReturned: DWORD): BOOL; stdcall; external 'Wtsapi32.dll' name {$IFDEF UNICODE}'WTSQuerySessionInformationW'{$ELSE}'WTSQuerySessionInformationA'{$ENDIF};

procedure WTSFreeMemory(pMemory: Pointer); stdcall; external 'Wtsapi32.dll';

implementation

end.
