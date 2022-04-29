unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  IniFiles, ShellApi, TlHelp32, Pipes, System.IOUtils;

type
  TDICOMAppThread = class(TThread)
  private
    FWorkingDir: string;
    FSCPPort: integer;
  protected
    procedure Execute; override;
  public
    constructor Create(const ADirectory: string; ASCPPort: integer); reintroduce;
  end;

  TCMSuiteService = class(TService)
    procedure ServiceExecute(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceDestroy(Sender: TObject);
  private
    FPipeServer: TPipeServer;

    procedure KillCMDCM;
  private
    FLogFile: TFileStream;
    FIniFile: TIniFile;

    FDCMAppPath: string;
    FDCMAPPThread: TDICOMAppThread;
  public
    function GetServiceController: TServiceController; override;
    procedure WriteLog(ALogMessage: string);
    { Public declarations }
  end;

var
  CMSuiteService: TCMSuiteService;

implementation

uses
  uUtils, DSiWin32;

{$R *.DFM}

procedure TCMSuiteService.WriteLog(ALogMessage: string);
begin
  FLogFile := TFile.Open(ExtractFilePath(ParamStr(0)) + 'CMSSVC.log', TFileMode.fmOpenOrCreate);
  FLogFile.Position := FLogFile.Size;  // Will be 0 if file created, end of text if not

  ALogMessage := #13#10 + '[' + DateTimeToStr(Now) + '] ' + ALogMessage;

  FLogFile.Write(ALogMessage[1], Length(ALogMessage) * SizeOf(Char));
  FreeAndNil(FLogFile);
end;

constructor TDICOMAppThread.Create(const ADirectory: string; ASCPPort: integer);
begin
  inherited Create(False);

  FWorkingDir := IncludeTrailingPathDelimiter(ADirectory);
  FSCPPort := ASCPPort;

  CMSuiteService.WriteLog('SCP port: ' + FSCPPort.ToString);
  CMSuiteService.WriteLog('DCMAppThread CREATE');
end;

procedure TDICOMAppThread.Execute;
var
  ErrorCode: Cardinal;
  ProcInfo: TProcessInformation;
begin
  while not Terminated do
  begin
    if not Suspended then
    begin
       if NOT ProcessRunning('CMDCM.exe') then
       begin
         CMSuiteService.WriteLog('Process CMDCM.exe not running! Launch...');
         RunApp('cmdcm.exe ..\WrkFiles', FWorkingDir);
         TThread.Sleep(1000);
       end;
       if NOT ProcessRunning('scp.exe') then
       begin
         CMSuiteService.WriteLog('Process SCP.exe not running! Launch...');
         RunApp('scp.exe -lc scp.log.config -od ..\WrkFiles ' + FSCPPort.ToString, FWorkingDir);
         TThread.Sleep(1000);
       end;
    end;

    TThread.Sleep(5000);
  end;
end;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  CMSuiteService.Controller(CtrlCode);
end;

function TCMSuiteService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TCMSuiteService.KillCMDCM;
var
  cmd: string;
begin
  cmd := 'CLOSE';

  if Assigned(FPipeServer) then
    FPipeServer.Broadcast(PChar(cmd)^, Length(cmd)*2);
end;

procedure TCMSuiteService.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  if Assigned(FDCMAPPThread) then
    FDCMAPPThread.Resume;
end;

procedure TCMSuiteService.ServiceDestroy(Sender: TObject);
begin
  FreeAndNil(FIniFile);
  FreeAndNil(FDCMAPPThread);

  WriteLog('SHUTDOWN!' + #13#10);
end;

procedure TCMSuiteService.ServiceExecute(Sender: TService);
begin
  while not Terminated do
  begin
    ServiceThread.ProcessRequests(false);
    TThread.Sleep(1000);
  end;
end;

procedure TCMSuiteService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  if Assigned(FDCMAPPThread) then
    FDCMAPPThread.Suspend;
end;

procedure TCMSuiteService.ServiceStart(Sender: TService; var Started: Boolean);
  function CheckPathsExist: Boolean;
  begin
    Result := True;

    if FDCMAppPath.IsEmpty OR
       not DirectoryExists(FDCMAppPath) then
    begin
      WriteLog('Path does not exists!');
      Result := False;
    end;

    if not FileExists(IncludeTrailingPathDelimiter(FDCMAppPath) + 'CMDCM.exe') then
    begin
      WriteLog(IncludeTrailingPathDelimiter(FDCMAppPath) + 'CMDCM.exe doest not exist!');
      Result := False;
    end;
    if not FileExists(IncludeTrailingPathDelimiter(FDCMAppPath) + 'scp.exe') then
    begin
      WriteLog(IncludeTrailingPathDelimiter(FDCMAppPath) + 'scp.exe doest not exist!');
      Result := False;
    end;
  end;
var
  IniFileName: string;
begin
  WriteLog('CMSVC START');

  IniFileName := ExtractFilePath(ParamStr(0)) + 'CMSSVC.ini';

  if not FileExists(IniFileName) then
  begin
    WriteLog('Ini CMSSVC.ini is missing. Stopping!');
    Started := False;
    Exit;
  end;

  FPipeServer := TPipeServer.Create(Self);
  FPipeServer.PipeName := 'CMSSvc';
  FPipeServer.Active := True;

  if Assigned(FPipeServer) AND
     FPipeServer.Active then
    WriteLog('Pipe activated');

  FIniFile := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'CMSSVC.ini');

  FDCMAppPath := FIniFile.ReadString('DCMAPP', 'Path', '');

  if TDirectory.IsRelativePath(FDCMAppPath) then
    FDCMAppPath := IncludeTrailingBackslash(RelToAbs(FDCMAppPath, ExtractFilePath(ParamStr(0))));

  WriteLog('WorkingDir: ' + FDCMAppPath);

  if not CheckPathsExist then
  begin
    WriteLog('Path check failed! Check details above');
    Started := False;
    Exit;
  end
  else
    FDCMAPPThread := TDICOMAppThread.Create(FDCMAppPath, FIniFile.ReadInteger('DCMAPP', 'SCPPort', 11112));
end;

procedure TCMSuiteService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  FDCMAPPThread.Terminate;
  //while ProcessRunning('CMDCM.exe') do
  KillCMDCM;

  //while ProcessRunning('scp.exe') do
  KillProcess('scp.exe');
end;

end.
