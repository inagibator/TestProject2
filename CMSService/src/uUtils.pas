unit uUtils;

interface

uses
  System.SysUtils, System.Classes,
  Winapi.Windows, Winapi.Messages,
  TlHelp32, DSiWin32, ShLwApi, uTypes;

function ProcessRunning(AExeFileName: String) : Boolean;
function KillProcess(AExeFileName: string): Integer;
function RunApp(cmdLine, WorkDir: String): Boolean;
function RelToAbs(const RelPath, BasePath: string): string;
function AbsToRel(const AbsPath, BasePath: string): string;

implementation

uses
  uMain;

function RunApp(cmdLine, WorkDir: String): Boolean;
var
  hToken: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  res: boolean;
  ErrorCode: integer;

  Sessions, Session: PWTS_SESSION_INFO;
  NumSessions, I, NumBytes: DWORD;
begin
   GetStartupInfo(StartupInfo);
   CMSuiteService.WriteLog('RUNAPP START');

   if not WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, Sessions, NumSessions) then
     try
       RaiseLastOSError;
     except on E: Exception do
       CMSuiteService.WriteLog('Failed to enumerate sessions!');
     end;

   try
     if NumSessions > 0 then
     begin
       Session := Sessions;
       for I := 0 to NumSessions-1 do
       begin
         if Session.State = WTSActive then
           Break;
//         begin
//           if WTSQuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, Session.SessionId, WTSUserName, UserName, NumBytes) then
//           begin
//             try
//               // use UserName as needed...
//             finally
//               WTSFreeMemory(UserName);
//             end;
//           end;
//         end;
         Inc(Session);
       end;
     end;
   finally
     WTSFreeMemory(Sessions);
   end;

   if DSiWTSQueryUserToken(Session.SessionId, hToken) then
   begin
     CMSuiteService.WriteLog('USER TOKEN QUERIED');
    { 1. For an application.exe  (exemple : NotePad.exe)

     res := CreateProcessAsUser(hToken,
               PChar(Path_appName),
               PChar(cmdLine),
               nil,
               nil,
               False,
               CREATE_NEW_CONSOLE,
               nil,
               PChar(WorkDir),
               StartupInfo,
               ProcessInfo);
    }



    {2. For a DOS command line   (Example FireBird :
           cmdLine:='gbak.exe -user sysdba -pas masterkey -b -nt "D:\Base.fdb" "D:\toto.fbk" ';
           WorkDir:='C:\Program Files\Firebird\Firebird_2_5\bin';
    }
     Result := CreateProcessAsUser(hToken,
               Nil,
               PChar('cmd.exe /C ' + cmdLine),
               nil,
               nil,
               True,
               CREATE_NO_WINDOW,
               nil,
               PChar(WorkDir),
               StartupInfo,
               ProcessInfo);

     if not Result then
     begin
       ErrorCode := GetLastError;

       try
         RaiseLastOSError(ErrorCode);
       except on E: Exception do
         CMSuiteService.WriteLog('Launch of ' + WorkDir + cmdLine + ' have failed! ERRORCODE: ' + ErrorCode.ToString + ' ERROR:' + e.ClassName +': '+ e.Message);
       end;
     end;
//     if res then WaitForSingleObject(ProcessInfo.hProcess,INFINITE);
   end
   else
   begin
     CMSuiteService.WriteLog('USER TOKEN NOT QUERIED');
   end;

end;

function AbsToRel(const AbsPath, BasePath: string): string;
var
  Path: array[0..MAX_PATH-1] of char;
begin
  PathRelativePathTo(@Path[0], PChar(BasePath), FILE_ATTRIBUTE_DIRECTORY, PChar(AbsPath), 0);
  result := Path;
end;

function RelToAbs(const RelPath, BasePath: string): string;
var
  Dst: array[0..MAX_PATH-1] of char;
begin
  PathCanonicalize(@Dst[0], PChar(IncludeTrailingBackslash(BasePath) + RelPath));
  result := Dst;
end;

function ProcessRunning(AExeFileName: String): Boolean;
var
  hSnapShot: THandle;
  ProcessEntry32: TProcessEntry32;
begin
  Result := False;

  hSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  Win32Check(hSnapShot <> INVALID_HANDLE_VALUE);

  AExeFileName := LowerCase(AExeFileName);

  FillChar(ProcessEntry32, SizeOf(TProcessEntry32), #0);
  ProcessEntry32.dwSize := SizeOf(TProcessEntry32);

  if (Process32First(hSnapShot, ProcessEntry32)) then
    repeat
      if (Pos(AExeFileName, LowerCase(ProcessEntry32.szExeFile)) = 1) then
      begin
        Result := true;
        Break;
      end; { if }
    until (Process32Next(hSnapShot, ProcessEntry32) = False);

  CloseHandle(hSnapShot);
end;

function KillProcess(AExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;

  CMDCMHandle: HWND;
begin
  Result := 0;

  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(AExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(AExeFileName))) then
      Result := Integer(TerminateProcess(
                        OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

end.
