unit K_FCMDCMExe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ShellAPI, Pipes,
  N_BaseF, Menus,
  K_CMDCMGLibW;

const
  WM_ICONTRAY = WM_USER + 1;

  RetrieveFolder    = 'store\';
  ErrRetrieveFolder = 'storeerr\';
  CommitmentFolder = 'storecomm\';      // commitment results subfolder
  ErrCommitmentFolder = 'storecommerr\'; // commitment results subfolder
  CommitmentPortion = 10; // commitment portion max size
//  ImpObjFolder = 'IOFolder\';
//  ErrObjFolder = 'EOFolder\';
//  StoreFolder  = 'SFolder\';

type TK_CMDCMCheckPACSConnectionThread = class(TThread)
  procedure Execute; override;
  procedure CCTSyncDump1Str(  );
  procedure CCTSyncDump2Str(  );
  procedure CCTSyncGetDCMSettings();
  procedure CCTSyncTestDCMConnection();
private
  CCTDumpStr : string;
  CCTDumpErrStr : string;
  CCTChangeSComm, CCTChangeRD : Boolean;
  CCTExceptCount : Integer;
protected
public
end;

type TK_CMDCMSendCommitmentThread = class(TThread)
  procedure Execute; override;
  procedure SCTOnTerminate(Sender: TObject);
  procedure SCTSyncDump1Str(  );
  procedure SCTSyncDump2Str(  );
  procedure SCTSyncGetFromDBQueue( );
  procedure SCTSyncSetEventStatus( );
  procedure SCTSendCommitment();
private
  SCTDumpStr : string;
  SCTDumpErrStr : string;
  SCTTransUID : string;
  SCTSIDs, SCTInstanceUIDs, SCTClassUIDs :  TStrings;
  SCTSendCommitmentRes : Boolean;
  SCTCheckRebuildQueueCount : Integer;
  SCTQueueCount : Integer;
  SCTHSRV : TK_HSRV;
  SCTExceptCount : Integer;
protected
public
end;

type TK_CMDCMRecieveCommitmentThread = class(TThread)
  procedure Execute; override;
  procedure RCTSyncDump1Str(  );
  procedure RCTSyncDump2Str(  );
  procedure RCTSyncFileProc( );
private
  RCTDumpStr, RCTDumpErrStr : string;
  RCTSrcFName : string;
  RCTPath     : string;
  RCTWBuf     : string;
  RCTExceptCount : Integer;
protected
public
end;

type TK_CMDCMRetrieveDataThread = class(TThread)
  procedure Execute; override;
  procedure RDTOnTerminate(Sender: TObject);
  procedure RDTSyncDump1Str(  );
  procedure RDTSyncDump2Str(  );
  procedure RDTSyncGetFromDBQueue( );
  procedure RDTSyncImportRetrievResults();
  procedure RDTSyncSetEventStatus( );
  procedure RDTRetieveData();
  procedure RDTSyncTryToRemoveUDFiles( );
private
  RDTDumpStr : string;
  RDTDumpErrStr : string;
  RDTErrPath, RDTPath : string;
  RDTSrcFName : string;
  RDTExceptCount : Integer;

  RDTHSRV : TK_HSRV;
  RDTQueueCount : Integer;
  RDTMoveErrCount : Integer;
  RDTMoveErrFlag  : Boolean;
  RDTCheckRebuildQueueCount : Integer;
  RDTDBID, RDTDBCMSPID : Integer;
  RDTWBuf, RDTDBDCMPID, RDTDBSTUID, RDTDBSEUID : WideString;
  RDTSIDs :  TStringList;
  RDTFDENames :  TStringList;

protected
public
end;

type
  TK_FormCMDCMExe = class(TN_BaseForm)
    PopupMenu1: TPopupMenu;
    FinishMediaSuiteDICOM1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure TrayMessage(var Msg: TMessage); message WM_ICONTRAY;
    procedure FinishMediaSuiteDICOM1Click(Sender: TObject);
  private
    { Private declarations }
    SavedCursor: TCursor;
    DCMETestConnectionThread : TK_CMDCMCheckPACSConnectionThread;
    DCMESendCommitmentThread : TK_CMDCMSendCommitmentThread;
    DCMERecieveCommitmentThread : TK_CMDCMRecieveCommitmentThread;
    DCMERetrieveDataTread  : TK_CMDCMRetrieveDataThread;

    DCMEIconMain : TIcon;
    DCMEIconAlt : TIcon;
    DCMETrayIconData: TNotifyIconData;
    procedure DCMEPrepareTrayIcon( const AInfo : string = ''; AFlags : LongWord = 0 );
    procedure DCMECreateTrayIcon( const AInfo : string = '' );
    procedure DCMEChangeTrayIcon(ANewIcon: TIcon; const ANewHint: string);
    procedure DCMEModifyTrayIconTip(const AInfo: string);
  private
    FPipeClient: TPipeClient;
    procedure PipeMessage(Sender: TObject; Pipe: HPIPE; Stream: TStream);
  public
    { Public declarations }
    DCMESkipConnectionCheck : Integer;

    DCMESCommConnectionAttrsFailFlag : Boolean;
    DCMESCommConnectionFailFlag : Boolean;
    DCMESCommSRVIP, DCMESCommSRVAETScp, DCMESCommSRVAETScu : WideString;
    DCMESCommSRVPort : Integer;

    DCMERDConnectionAttrsFailFlag : Boolean;
    DCMERDConnectionFailFlag : Boolean;
    DCMERDSRVIP, DCMERDSRVAETScp, DCMERDSRVAETScu : WideString;
    DCMERDSRVPort : Integer;

    DCMECommonPath : string;
    procedure OnUHException( Sender: TObject; E: Exception );
  end;

var
  K_FormCMDCMExe: TK_FormCMDCMExe;

implementation

uses ADODB, DB,
     K_UDC, K_CM0, K_CML1F, K_CML3F, K_CLib0, K_CLib, K_Arch, K_UDT1, K_UDT2, K_CMDCM, K_FCMDCMSetup,
     N_Types, N_Lib0, N_Lib1, N_CMResF, N_CMMain5F, N_CML2F, N_ME1, N_CM1;

{$R *.dfm}

function WDLGetSrvLastErrorInfo( const APtr, APtr1, Aptr2 : Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
  PWideChar(APtr1)^ := '*';
  PInteger(Aptr2)^ := 1;
end;
function WDLConnectEcho( const APtr1: Pointer; AInt : Integer; const APW1, APW2 : Pointer; ATimeOut : Integer ) : Pointer; cdecl;
begin
  Result := Pointer(1);
end;
function WDLEcho( const APtr1: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLConnectQrScpMove( const APtr1: Pointer; AInt : Integer; const APW1, APW2 : Pointer; AInt1 : Integer ) : Pointer; cdecl;
begin
  Result := Pointer(1);
end;
function WDLMove( APtr1: Pointer; AInt : Integer; const APW1, APW2, APW3, APW4, APW5, APW6, APUS1, APUS2, APUS3, APUS4, APtr2 : Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLDeleteSrvObject( const APtr1: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLCloseConnection( const APtr1: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLConnectStorageCommitmentScp( const APtr1: Pointer; AInt : Integer; const APW1, APW2 : Pointer ) : Pointer; cdecl;
begin
  Result := Pointer(2);
end;
function WDLCreateCommitmentRequest( APtr: Pointer ): Pointer; cdecl;
begin
  Result := Pointer(3);
end;
function WDLAddInstanceToCommit( const APtr, APtr1, Aptr2 : Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLSendStorageCommitmentRequest( const APtr1, APtr2: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;
function WDLDeleteDcmObject( const APtr1: Pointer ) : TN_UInt2; cdecl;
begin
  Result := 0;
end;

//************************************************ TK_FormCMDCMExe.FormShow ***
// FormShow Handler
//
procedure TK_FormCMDCMExe.FormShow( Sender: TObject );
var
  WStr : string;
  DlgType : TMsgDlgType;
  VFile: TK_VFile;
  Stream : TStream;
begin
  N_Dump1Str( 'CMDCM>> FormShow start' );
  if K_CMDParams.Count >= 1 then
    DCMECommonPath := IncludeTrailingPathDelimiter( K_CMDParams[0] );
  N_Dump1Str( 'CMDCM>> CommonPath=' + DCMECommonPath );
  if DCMECommonPath <> '\' then
    DCMECommonPath := ExpandFileName( DCMECommonPath );
  N_Dump1Str( 'CMDCM>> Expanded CommonPath=' + DCMECommonPath );
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  DCMECreateTrayIcon( 'CMSuite-DICOM' );
  K_CMSAppStartContext.CMASState := K_cmasStop;
  N_AddDirToPATHVar( K_ExpandFileName( '(#DLLFiles#)' ) );
{
  if not K_CMEnterConfirmDlg( '', '', K_CMDesignModeFlag,
//                N_MemIniToString('CMS_Main', 'EGALogin', ''),
//                N_MemIniToString('CMS_Main', 'EGAPassword', ''),
                'The Software Support',
                'Wrong user name or password. Press OK to close the software' ) then
  begin
    Close();
    Release();
    Exit;
  end;

  ShowInfo( ' Centaur Media Suite Support is connecting to DB. Please wait ... ' );
  Self.Refresh();
}
  Application.CreateForm(TN_CMResForm, N_CMResForm);

  Application.CreateForm( TN_CMMain5Form1, N_CM_MainForm);
//  N_CM_MainForm.CMMCurFStatusBar := StatusBar;

//  Application.CreateForm(TN_CMResForm, N_CMResForm);

  K_SetFFCompCurLangTexts( N_CMResForm );

  Application.CreateForm(TK_CML1Form, K_CML1Form);
  K_SetFFCompCurLangTexts( K_CML1Form );
  K_PrepLLLCompTexts( K_CML1Form );

  Application.CreateForm(TK_CML3Form, K_CML3Form);
  K_SetFFCompCurLangTexts( K_CML3Form );
  K_PrepLLLCompTexts( K_CML3Form );
  K_CMHistoryEventsInit();

  Application.CreateForm(TN_CML2Form, N_CML2Form);
  K_SetFFCompCurLangTexts( N_CML2Form );
  K_PrepLLLCompTexts( N_CML2Form );


  WStr := N_MemIniToString( 'CMS_Main', 'StartArchive', '');
  WStr := K_ExpandFileName( WStr );
  if not K_OpenCurArchive( WStr ) then
  begin
    K_CMShowMessageDlg( //sysout
      'Fail to load archive ' + WStr, mtError, [], false, 'Media Suite Support' );
    Close();
    Release();
    Exit;
  end;

  K_InitAppArchProc := nil;
  K_InitArchiveGCont( K_CurArchive ); // create all needed objects in K_CurArchive
  N_InitVREArchive( K_CurArchive ); // VRE specific initialization
  N_InitCMSArchive( K_CurArchive ); // CMS specific initialization

  K_CMEDAccess := TK_CMEDDBAccess.Create;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
//    AppLocalID := K_CMFilesSyncProcAppLocalID;
    N_BoolToMemIni( 'CMS_Main', 'OpenAllDBVer', TRUE); // skip DB Version check in DebugMode
    if (EDAInit() <> K_edOK)        or
       (EDAGetSlidesFPathContext() <> K_edOK)  then
    begin
      DlgType := mtWarning;
      if K_CMSAppStartContext.CMASState = K_cmasStop then
      begin
        DlgType := mtError;
      end;
      if K_CMSLiRegWarning = '' then
        K_CMSLiRegWarning := 'Unknown Media Suite Database connetion error';
      K_CMShowMessageDlg( K_CMSLiRegWarning, DlgType, [], false, 'DICOM Assistant' );
      Close();
      Release();
      Exit;
    end;

    if K_CMEnterpriseModeFlag then
    begin
      K_CMShowMessageDlg( //sysout
        'Media DICOMExe shouldn''t be run in DB Enterprise mode',
        mtError, [], false, K_CML1Form.LLLSupport1.Caption ); //'Media Suite Support' );
      Close();
      Release();
      Exit;
    end;

    EDAGlobalMemIniToCurState();
    EDAInstanceMemIniToCurState();
    if K_edOK <>
       EDAOneAppContextToMemIni(Ord(K_actGlobIni2), 0, 0, 'Global2|Load') then
      Exit;
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do

  K_CMSRebuildCommonRImage();

  Screen.Cursor := SavedCursor;
  N_Dump1Str( 'CMDCMExe >> FormShow fin' );

  ////////////////////////////////////
  // Free Main Memory after Application
  // initialization is finished
  //
  if K_CMSReservedSpaceHMem <> 0 then
  begin
    N_Dump1Str( 'MemFreeSpace reserved free' );
    Windows.GlobalFree( K_CMSReservedSpaceHMem );
    K_CMSReservedSpaceHMem := 0;
  end;
  K_GetFreeSpaceProfile();
  N_Dump1Str( '!!!MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr('; ', '%.0n') );
//  N_Dump1Str( 'MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr() );
  //
  ///////////////////////////////////
  K_CMSAppStartContext.CMASState := K_cmasOK;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
//    CurPatID  := -10;
//    CurProvID := -10;
//    CurLocID  := -10;
//    EDAAppActivate();
    EDALockActiveContext1( -10, -10, -10 );
    N_Dump2Str( 'Init History start' );
    EDAAddSessionHistRecord(); // Create CurHistSession if relaunch after HRPreview

    EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                             Ord(K_shNCACMSStart) ) );
    Sleep(30);  // for time shift between CMSStart and SessionStart event
    EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                             Ord(K_shNCAStartSession) ) );
    N_Dump2Str( 'Init History fin' );

  end;

  //////////////////////
  // Init Tray Icons
  WStr := N_MemIniToString( 'CMS_Main', 'ScanIconAltFName', '' );
  N_Dump2Str( 'SC> AltIcon FName=' + WStr );
  if WStr <> '' then
  begin
    K_VFAssignByPath( VFile, K_ExpandFileName(WStr) );
    if K_VFOpen( VFile ) > 0 then
    begin
      Stream := K_VFStreamGetToRead( VFile );
      DCMEIconAlt := TIcon.Create();
      DCMEIconAlt.LoadFromStream(Stream);

      DCMEIconMain := TIcon.Create();
      DCMEIconMain.Assign( Application.Icon );
      N_Dump2Str( 'SC> AltIcon is set' );
    end;
    K_VFStreamFree(VFile);
  end
  else
  begin
    DCMEIconMain := TIcon.Create();
    DCMEIconMain.Assign( Application.Icon );

    DCMEIconAlt := TIcon.Create();
    DCMEIconAlt.Assign( Application.Icon );
  end;

  DCMESCommConnectionAttrsFailFlag := TRUE;
  DCMESCommConnectionFailFlag      := TRUE;

  DCMERDConnectionAttrsFailFlag := TRUE;
  DCMERDConnectionFailFlag      := TRUE;

  ////////////////////////////////
  // Init Threads
  if DCMETestConnectionThread = nil then
  begin
    ////////////////////////////////
    // Init TestConnection Thread
    DCMETestConnectionThread :=  TK_CMDCMCheckPACSConnectionThread.Create( FALSE );
    N_Dump1Str('CMDCM>> DCMETestConnectionThread is created');
  end;

  if DCMESendCommitmentThread = nil then
  begin
    ////////////////////////////////
    // Init SendCommitment Thread
    DCMESendCommitmentThread := TK_CMDCMSendCommitmentThread.Create( FALSE );
    N_Dump1Str('CMDCM>> DCMESendCommitmentThread is created');
  end;

  if DCMERecieveCommitmentThread = nil then
  begin
    ////////////////////////////////
    // Init RecieveCommitment Thread
    DCMERecieveCommitmentThread := TK_CMDCMRecieveCommitmentThread.Create( FALSE );
    N_Dump1Str('CMDCM>> DCMERecieveCommitmentThread is created');
  end;

  if DCMERetrieveDataTread = nil then
  begin
    ////////////////////////////////
    // Init RecieveCommitment Thread
    DCMERetrieveDataTread := TK_CMDCMRetrieveDataThread.Create( FALSE );
    N_Dump1Str('CMDCM>> DCMERetrieveDataTread is created');
  end;

end; // procedure TK_FormCMDCMExe.FormShow

//************************************** TK_FormCMDCMExe.DCMECreateTrayIcon ***
// Prepare Tray Icon
//
procedure TK_FormCMDCMExe.DCMEPrepareTrayIcon( const AInfo : string = ''; AFlags : LongWord = 0 );
var
  TipL : Integer;
  WInfo : string;
begin
  with DCMETrayIconData do
  begin
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
    cbSize:= SizeOf(); // in XE5 SizeOf is also TNotifyIconData method -> SCTrayIconData.SizeOf()
{$ELSE}         // Delphi 7 or Delphi 2010
    cbSize:= System.SizeOf(DCMETrayIconData);
{$IFEND CompilerVersion >= 26.0}
    Wnd := Handle;
    uID:= 0;
    if AFlags = 0 then
      AFlags := NIF_TIP;
    uFlags:= AFlags;
    uCallbackMessage:= WM_USER + 1;
    hIcon:= Application.Icon.Handle;
    WInfo := AInfo;
    if AInfo = '' then
      WInfo := 'DICOM PACS';
    if (szTip[0] = #0) or (WInfo <> '') then
    begin
      TipL := Length(WInfo);
      if TipL >= Length(szTip) then TipL := Length(szTip) - 1;
      FillChar( szTip[TipL], (Length(szTip) - TipL) * System.SizeOf(Char), 0 );
      Move( WInfo[1], szTip[0], TipL * System.SizeOf(Char) );
    end;
//    SCCurTrayTipInfo := string( szTip );
  end; // with SCTrayIconData do
end; // procedure TK_FormCMDCMExe.DCMEPrepareTrayIcon

//************************************** TK_FormCMDCMExe.DCMECreateTrayIcon ***
// Create Tray Icon
//
procedure TK_FormCMDCMExe.DCMECreateTrayIcon( const AInfo : string = '' );
begin
  // Create DCM Tray Icon
  DCMEPrepareTrayIcon( AInfo, NIF_MESSAGE + NIF_ICON + NIF_TIP );
  Shell_NotifyIcon(NIM_ADD, @DCMETrayIconData);
end; // procedure TK_FormCMDCMExe.DCMECreateTrayIcon

//*********************************** TK_FormCMDCMExe.DCMEModifyTrayIconTip ***
// Modify Tray Icon Tip
//
procedure TK_FormCMDCMExe.DCMEModifyTrayIconTip( const AInfo : string );
begin
  // Modify Tray Icon
  DCMEPrepareTrayIcon( AInfo, NIF_TIP );
  Shell_NotifyIcon( NIM_MODIFY, @DCMETrayIconData );
end; // procedure  TK_FormCMDCMExe.DCMEModifyTrayIconTip

//************************************** TK_FormCMDCMExe.DCMEChangeTrayIcon ***
// Change Tray Icon
//
procedure TK_FormCMDCMExe.DCMEChangeTrayIcon( ANewIcon : TIcon; const ANewHint : string );
begin

  if (ANewIcon <> nil) and (Application.Icon <> ANewIcon) then
  begin
    Application.Icon := ANewIcon;
    Shell_NotifyIcon(NIM_DELETE, @DCMETrayIconData);
    DCMECreateTrayIcon( ANewHint );
  end
  else
    DCMEModifyTrayIconTip( ANewHint );

end; // procedure TK_FormCMDCMExe.DCMEChangeTrayIcon

//******************************************* TK_FormCMDCMExe.OnUHException ***
// On Appliction Unhadled Exception Handler
//
procedure TK_FormCMDCMExe.OnUHException( Sender: TObject; E: Exception );
var
  hTaskBar: THandle;
begin
  try
    // Show TaskBar if Exception raised while TaskBar  is hide
    hTaskbar := FindWindow( 'Shell_TrayWnd', nil );
    if hTaskbar <> 0 then
    begin
      EnableWindow( HTaskBar, TRUE );        // Enabled TaskBar
      ShowWindow( hTaskBar, SW_SHOWNORMAL ); // Show TaskBar
    end;

    K_CMShowMessageDlg(
      ' The Software DCMExe terminated by exception:' +
         #13#10 + E.Message, mtError, [], false,
        'Media Suite DCMExe' );
    N_Dump1Str( 'Application CMDCMEx.UHException FlushCounters' + N_GetFlushCountersStr() );
    N_LCExecAction( -1, lcaFlush );

    K_CMEDAccess.Free;
  finally
    ExitProcess( 10 );
  end;
end; // procedure TK_FormCMDCMExe.OnUHException


procedure TK_FormCMDCMExe.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  ////////////////////////////////
  // Finish Threads
  if DCMETestConnectionThread <> nil then
  begin
    DCMETestConnectionThread.Terminate();
    DCMETestConnectionThread := nil;
    N_Dump1Str('CMDCM>> DCMETestConnectionThread is terminated');
  end;
  if DCMESendCommitmentThread <> nil then
  begin
    DCMESendCommitmentThread.Terminate();
    DCMESendCommitmentThread := nil;
    N_Dump1Str('CMDCM>> DCMESendCommitmentThread is terminated');
  end;
  if DCMERecieveCommitmentThread <> nil then
  begin
    DCMERecieveCommitmentThread.Terminate();
    DCMERecieveCommitmentThread := nil;
    N_Dump1Str('CMDCM>> DCMERecieveCommitmentThread is terminated');
  end;
  if DCMERetrieveDataTread <> nil then
  begin
    DCMERetrieveDataTread.Terminate();
    DCMERetrieveDataTread := nil;
    N_Dump1Str('CMDCM>> DCMERetrieveDataTread is terminated');
  end;

  FreeAndNil(DCMEIconMain);
  FreeAndNil(DCMEIconAlt);

  K_CMEDAccess.Free;
end; // procedure TK_FormCMDCMExe.FormClose

//********************************************** TK_FormCMDCMExe.FormCreate ***
// Application Form Create Event Handler
//
procedure TK_FormCMDCMExe.FormCreate(Sender: TObject);
begin
  inherited;

  FPipeClient := TPipeClient.Create(Self);
  FPipeClient.PipeName := 'CMSSvc';
  FPipeClient.OnPipeMessage := PipeMessage;

  FPipeClient.Connect;
end; // procedure TK_FormCMDCMExe.FormCreate

//********************************************* TK_FormCMDCMExe.PipeMessage ***
// Application Pipe Message Event Handler
//
procedure TK_FormCMDCMExe.PipeMessage(Sender: TObject; Pipe: HPIPE; Stream: TStream);
  function RemoveNull(const Input: string): string;
  var
    OutputLen, Index: Integer;
    C: Char;
  begin
    SetLength(Result, Length(Input));
    OutputLen := 0;
    for Index := 1 to Length(Input) do
    begin
      C := Input[Index];
      if C <> #0 then
      begin
        inc(OutputLen);
        Result[OutputLen] := C;
      end;
    end;
    SetLength(Result, OutputLen);
  end;

  function MessageString: string;
  var
    ss: TStringStream;
  begin
{$IFDEF VER150} // Delphi 7  added by Alex Kovalev
    ss := TStringStream.Create('');
{$ELSE}         // Delphi XE5 or Delphi 2010
    ss := TStringStream.Create;
{$ENDIF VER150}

    try
      ss.CopyFrom(Stream, 0);

      Result := ss.DataString;
      Result := RemoveNull(Result);
    finally
      FreeAndNil(ss);
    end;
  end;
begin
  if SameText( MessageString(), 'CLOSE' ) then
    Self.Close;
end; // procedure TK_FormCMDCMExe.PipeMessage

//********************************************* TK_FormCMDCMExe.TrayMessage ***
// Appliction Tray Message Event Handler
//
procedure TK_FormCMDCMExe.TrayMessage(var Msg: TMessage);
var
  P: TPoint;
begin
  case Msg.LParam of
{

    WM_LBUTTONDOWN: begin
      N_Dump2Str( 'SC> Tray Left Button');
      if not Self.Visible and ((SCScanState = K_SCSSWait) or (SCScanState = K_SCSSMoveToNewPath)) then
      begin
        N_Dump1Str( 'SC> Open Setup ' );
        SCScanState := K_SCSSSetup; // SETUP state - before show !!!
        aOfflineMode.Enabled := TRUE;

        if SCUIStayOnTopSetup then
          N_BaseFormStayOnTop := 2;

        Self.Show();
//        Self.FormDeactivate( nil );

//        SCModifyTrayIconTip( Self.Caption + SCTrayAddCaption );
        if SCTrayAddCaption <> '' then
          SCModifyTrayIconTip( SCTrayAddCaption )
        else
          SCModifyTrayIconTip( Self.Caption );

        if K_CMScanDataPath = '' then
          SCScanDataPathIniSet();
//        ActTimer.Enabled := (K_CMScanDataPath <> '');
        SCInitScanPathsContext();

        SCUpdateScanState();

      end
      else
      if Self.Visible then
      begin
        Self.WindowState := wsNormal;
        Self.SetFocus
      end
      else
      if SCScanState <> K_SCSSSetup then
      begin
        N_Dump1Str( 'SC> Tray Left Button State=' + IntToStr(Ord(SCScanState)) );
        SCShowNotReadyMessage();
      end;
    end;
{}
    WM_RBUTTONDOWN:
    begin
      GetCursorPos(P);
//      CreateCMScanexeDistributive1.Visible := (N_CM_IDEMode = 1) or (N_CM_IDEMode = 2);
//      N_Dump2Str( 'SC> Before Popup');
      PopupMenu1.Popup(P.X, P.Y);
   end;
{}
  end;

end; // procedure TK_FormCMScan.TrayMessage

procedure TK_FormCMDCMExe.FinishMediaSuiteDICOM1Click(Sender: TObject);
begin
//  inherited;
  Self.Close;
end;

{*** TK_CMDCMCheckPACSConnectionThread ***}

procedure TK_CMDCMCheckPACSConnectionThread.Execute;
var
  ErrTestCount : Integer;

  function SleepAndWaitForTerm( ASecNum : Integer ) : Boolean;
  var i : Integer;
  begin
    Result := TRUE;
    for i := 1 to ASecNum do
    begin
      sleep ( 1000 );
      if Terminated then
        Exit;
    end;
    Result := Terminated;
  end; // SleepAndWaitForTerm

  procedure LongWait( const AText : string ); // 5 5 5 15 5 15 5 15 5 15 ...
  begin
    if ErrTestCount < 3 then
    begin
      CCTDumpStr := 'CCT> 5 minutes wait ' + AText;
      Synchronize( CCTSyncDump2Str );
      SleepAndWaitForTerm( 5 * 60 );
//      sleep( 5 * 60 * 1000 ); // sleep 5 minutes
//      sleep( 5 * 1000 ); // sleep 5 sec deb
      Inc(ErrTestCount);
    end
    else
    begin
      CCTDumpStr := 'CCT> 15 minutes wait ' + AText;
      Synchronize( CCTSyncDump2Str );
      SleepAndWaitForTerm( 15 * 60 );
//      sleep( 15 * 60 * 1000 ); // sleep 15 minutes
//      sleep( 15 * 1000 ); // sleep 15 sec deb
      ErrTestCount := -2;
    end;
  end; // procedure LongWait();

begin
  ErrTestCount := 0;

  while K_DCMGLibW.DLDllHandle = 0 do // Precaution
  begin
//    sleep(5 * 1000);
    SleepAndWaitForTerm( 5 );
    if Terminated then
    begin
      CCTDumpStr := 'CCT> !!! Thread is terminated by wrapdcm.dll';
      Synchronize( CCTSyncDump1Str );
      Exit;
    end;
  end;

  ErrTestCount := -2;
  while TRUE do
  begin
    try
      if Terminated then Break; // check Terminated at Loop start

      Synchronize(CCTSyncGetDCMSettings);
{}
      if K_FormCMDCMExe.DCMESCommConnectionAttrsFailFlag or
         K_FormCMDCMExe.DCMERDConnectionAttrsFailFlag then
      begin
        LongWait( 'for attrs');
        Continue;
      end
      else
        ErrTestCount := 0;
{}
      if Terminated then Break; // check Terminated before Sleep

      if K_FormCMDCMExe.DCMESkipConnectionCheck > 0 then
      begin
        CCTDumpStr := 'CCT> 1 minute wait for check permission';
        Synchronize( CCTSyncDump2Str );
        SleepAndWaitForTerm( 1 * 60 );
//        sleep(1 * 60 * 1000); // sleep 1 minutes
//        sleep(1 * 1000); // sleep 1 sec deb
        Continue;
      end;

      if CCTChangeSComm or CCTChangeRD or
         K_FormCMDCMExe.DCMESCommConnectionFailFlag or
         K_FormCMDCMExe.DCMERDConnectionFailFlag then
        Synchronize(CCTSyncTestDCMConnection);

      if K_FormCMDCMExe.DCMESCommConnectionFailFlag or
         K_FormCMDCMExe.DCMERDConnectionFailFlag then
      begin
        LongWait( 'for connection' );
        Continue;
      end
      else
        ErrTestCount := 0;
      CCTExceptCount := 0;
    except
      on E: Exception do
      begin
        if CCTDumpErrStr <> '' then
        begin
          CCTDumpStr := 'CCT> ErrInfo ' + CCTDumpErrStr;
          Synchronize( CCTSyncDump1Str );
        end;
        CCTDumpStr := 'CCT> TK_CMDCMCheckPACSConnectionThread  exception >> ' + E.Message;
        Synchronize( CCTSyncDump1Str );

        Inc(CCTExceptCount);
        if CCTExceptCount > 10 then
        begin
          CCTDumpStr := 'CCT> TK_CMDCMCheckPACSConnectionThread terminate by exception';
          Synchronize( CCTSyncDump1Str );
          Exit;
        end;

      end;
    end; // try


    if Terminated then Break; // check Terminated before Sleep

    // Sleep before next Check Loop
    CCTDumpStr := 'CCT> 10 minute wait for next check';
    Synchronize( CCTSyncDump2Str );
    sleep(1 * 60 * 1000); // sleep 1 minutes
//    sleep(10 * 60 * 1000); // sleep 10 minutes
//    sleep(3 * 1000); // sleep 3 sec deb

  end; // while TRUE do

end; // procedure TK_CMDCMCheckPACSConnectionThread.Execute

procedure TK_CMDCMCheckPACSConnectionThread.CCTSyncDump1Str;
begin
  N_Dump1Str( CCTDumpStr );
  CCTDumpStr := '';
end; // procedure TK_CMDCMCheckPACSConnectionThread.CCTSyncDump1Str

procedure TK_CMDCMCheckPACSConnectionThread.CCTSyncDump2Str;
begin
  N_Dump2Str( CCTDumpStr );
  CCTDumpStr := '';
end; // procedure TK_CMDCMCheckPACSConnectionThread.CCTSyncDump2Str

procedure TK_CMDCMCheckPACSConnectionThread.CCTSyncGetDCMSettings;
var
  PrevStateSC, PrevStateRD : Boolean;
  IP, AET1, AET2 : string;
  NP : Integer;

label LExit;
begin

  with K_FormCMDCMExe do
  begin
    PrevStateSC := DCMESCommConnectionAttrsFailFlag;
    PrevStateRD := DCMERDConnectionAttrsFailFlag;

   if K_CMD4WAppFinState then
    begin
      N_Dump1Str( 'CMCDM>> Call CCTSyncGetDCMSettings after K_CMD4WAppFinState was set' );
      goto LExit;
    end;
    if K_edOK <>
       TK_CMEDDBAccess(K_CMEDAccess).EDAOneAppContextToMemIni(Ord(K_actGlobIni2), 0, 0, 'Global2|Load') then
    begin
      N_Dump1Str( 'CMCDM>> CCTSyncGetDCMSettings >> EDAOneAppContextToMemIni error' );
      goto LExit;
    end;

    IP   := N_StringToWide( N_MemIniToString( 'CMS_DCMSCommSettings', 'IP', '' ) );
    AET1 := N_StringToWide( N_MemIniToString( 'CMS_DCMSCommSettings', 'Name', ''  ) );
    AET2 := N_StringToWide( N_MemIniToString( 'CMS_DCMAetScu', 'StoreSCP', ''  ) );
    NP   := StrToIntDef( N_MemIniToString( 'CMS_DCMSCommSettings', 'Port', '' ), 0 );

    CCTChangeSComm := (IP <> DCMESCommSRVIP) or (NP <> DCMESCommSRVPort) or
                      (AET1 <> DCMESCommSRVAETScp) or (AET2 <> DCMESCommSRVAETScu);
    if CCTChangeSComm then
    begin
      DCMESCommSRVIP := IP;
      DCMESCommSRVPort := NP;
      DCMESCommSRVAETScp := AET1;
      DCMESCommSRVAETScu := AET2;
{}
      DCMESCommConnectionAttrsFailFlag :=
        (DCMESCommSRVIP = '')     or
        (DCMESCommSRVPort = 0)    or
        (DCMESCommSRVAETScp = '') or
        (DCMESCommSRVAETScu = '');
    end;

    IP   := N_StringToWide( N_MemIniToString( 'CMS_DCMQRSettings', 'IP', '' ) );
    AET1 := N_StringToWide( N_MemIniToString( 'CMS_DCMQRSettings', 'Name', ''  ) );
    AET2 := N_StringToWide( K_CMDCMSetupCMSuiteAetScu() );
    NP   := StrToIntDef( N_MemIniToString( 'CMS_DCMQRSettings', 'Port', '' ), 0 );

    CCTChangeRD := (IP <> DCMERDSRVIP) or (NP <> DCMERDSRVPort) or
                   (AET1 <> DCMERDSRVAETScp) or (AET2 <> DCMERDSRVAETScu);
    if CCTChangeRD then
    begin
      DCMERDSRVIP := IP;
      DCMERDSRVPort := NP;
      DCMERDSRVAETScp := AET1;
      DCMERDSRVAETScu := AET2;

      DCMERDConnectionAttrsFailFlag :=
        (DCMERDSRVIP = '')     or
        (DCMERDSRVPort = 0)    or
        (DCMERDSRVAETScp = '') or
        (DCMERDSRVAETScu = '');
    end;

LExit:
    if (PrevStateSC <> DCMESCommConnectionAttrsFailFlag) or
       (PrevStateRD <> DCMERDConnectionAttrsFailFlag) then
    begin
      if DCMESCommConnectionAttrsFailFlag then
      begin
        N_Dump1Str( 'CMDCM>> CCTSyncGetDCMSettings Storage Commitment fails' );
        DCMEChangeTrayIcon( DCMEIconAlt, 'PACS Storage Commitment connection attributes fails' );
      end
      else
      begin
        N_Dump1Str( 'CMDCM>> CCTSyncGetDCMSettings Storage Commitment OK' );
        DCMEChangeTrayIcon( DCMEIconMain, 'PACS Storage Commitment connection attributes OK' );
      end;

      if DCMERDConnectionAttrsFailFlag then
      begin
        N_Dump1Str( 'CMDCM>> CCTSyncGetDCMSettings Retrieve Data fails' );
        DCMEChangeTrayIcon( DCMEIconAlt, 'PACS Retrieve Data connection attributes fails' );
      end
      else
      begin
        N_Dump1Str( 'CMDCM>> CCTSyncGetDCMSettings Retrieve Data OK' );
        DCMEChangeTrayIcon( DCMEIconMain, 'PACS Retrieve Data connection attributes OK' );
      end;
    end;
{}
  end; // with K_FormCMDCMExe do
end; // procedure TK_CMDCMCheckPACSConnectionThread.CCTSyncGetDCMSettings;

procedure TK_CMDCMCheckPACSConnectionThread.CCTSyncTestDCMConnection;
var
  PrevState : Boolean;

begin
  with K_FormCMDCMExe do
  begin
    if CCTChangeSComm or DCMESCommConnectionFailFlag then
    begin
      PrevState := DCMESCommConnectionFailFlag;
      DCMESCommConnectionFailFlag := not
      K_CMDCMServerTestConnection( DCMESCommSRVIP, DCMESCommSRVPort,
                                   DCMESCommSRVAETScp, DCMESCommSRVAETScu, 15, TRUE );
      if PrevState <> DCMESCommConnectionFailFlag then
      begin
        if DCMESCommConnectionFailFlag then
        begin
          DCMEChangeTrayIcon( DCMEIconAlt, 'PACS Storage Commitment connection fails' );
          N_Dump1Str( 'CMDCM>> CCTSyncTestDCMConnection Storage Commitment fails' );
        end
        else
        begin
          DCMEChangeTrayIcon( DCMEIconMain, 'PACS Storage Commitment connection OK' );
          N_Dump1Str( 'CMDCM>> CCTSyncTestDCMConnection Storage Commitment OK' );
        end;
      end;
      CCTChangeSComm := FALSE;
    end; // if CCTChangeSComm then

    if CCTChangeRD or DCMERDConnectionFailFlag then
    begin
      if (DCMESCommSRVIP <> DCMERDSRVIP) or
         (DCMESCommSRVPort <> DCMERDSRVPort) or
         (DCMESCommSRVAETScp <> DCMERDSRVAETScp) or
         (DCMESCommSRVAETScu <> DCMERDSRVAETScu) then
      begin // RD attrs are not equal to SComm attrs
        PrevState := DCMERDConnectionFailFlag;

        DCMERDConnectionFailFlag := not
        K_CMDCMServerTestConnection( DCMERDSRVIP, DCMERDSRVPort,
                                     DCMERDSRVAETScp, DCMERDSRVAETScu, 15, TRUE );
        if PrevState <> DCMERDConnectionFailFlag then
        begin
          if DCMERDConnectionFailFlag then
          begin
            DCMEChangeTrayIcon( DCMEIconAlt, 'PACS Retrieve data connection fails' );
            N_Dump1Str( 'CMDCM>> CCTSyncTestDCMConnection Retrieve data fails' );
          end
          else
          begin
            DCMEChangeTrayIcon( DCMEIconMain, 'PACS Retrieve data connection OK' );
            N_Dump1Str( 'CMDCM>> CCTSyncTestDCMConnection Retrieve data OK' );
          end;
        end;
      end
      else // RD attrs are equal to SComm attrs
        DCMERDConnectionFailFlag := DCMESCommConnectionFailFlag;
    end; // if CCTChangeRD then
  end; // with K_FormCMDCMExe do
end; // procedure TK_CMDCMCheckPACSConnectionThread.CCTSyncTestDCMConnection

{*** TK_CMDCMCheckPACSConnectionThread ***}


{*** TK_CMDCMSendCommitmentThread ***}

procedure TK_CMDCMSendCommitmentThread.Execute;
var
  ErrTestCount : Integer;
  SendRepeatCount : Integer;

  function SleepAndWaitForTerm( ASecNum : Integer ) : Boolean;
  var i : Integer;
  begin
    Result := TRUE;
    for i := 1 to ASecNum do
    begin
      sleep ( 1000 );
      if Terminated then
        Exit;
    end;
    Result := Terminated;
  end; // SleepAndWaitForTerm

  procedure LongWait( const AText : string ); // 5 5 5 15 5 15 5 15 5 15 ...
  begin
    if ErrTestCount = -2 then
    begin
      SCTDumpStr := 'SCT> 5 sec wait ' + AText;
      Synchronize( SCTSyncDump2Str );
      SleepAndWaitForTerm( 5 );
//      sleep( 5 * 1000 ); // sleep 5 sec
//      Inc(ErrTestCount);
    end
    else
    if ErrTestCount = -1 then
    begin
      SCTDumpStr := 'SCT> 30 sec wait ' + AText;
      Synchronize( SCTSyncDump2Str );
      SleepAndWaitForTerm( 30 );
//      sleep( 30 * 1000 ); // sleep 30 sec
//      sleep( 5 * 1000 ); // sleep 5 sec deb
      Inc(ErrTestCount);
    end
    else
    if ErrTestCount < 3 then
    begin
      SCTDumpStr := 'SCT> 5 minutes wait ' + AText;
      Synchronize( SCTSyncDump2Str );
      SleepAndWaitForTerm( 5 * 60 );
//      sleep( 5 * 60 * 1000 ); // sleep 5 minutes
//      sleep( 5 * 1000 ); // sleep 5 sec deb
      Inc(ErrTestCount);
    end
    else
    begin
      SCTDumpStr := 'SCT> 15 minutes wait ' + AText;
      Synchronize( SCTSyncDump2Str );
      SleepAndWaitForTerm( 15 * 60 );
//      sleep( 15 * 60 * 1000 ); // sleep 15 minutes
//      sleep( 15 * 1000 ); // sleep 15 sec deb
//      ErrTestCount := 2;
    end;
  end; // procedure LongWait();

begin

  if K_CMEDDBVersion < 45 then
  begin
    SCTDumpStr := 'SCT> !!! Thread is terminated by DB version ' + IntToStr(K_CMEDDBVersion);
    Synchronize( SCTSyncDump1Str );
    Exit;
  end;

  while K_DCMGLibW.DLDllHandle = 0 do // Precaution
  begin
    SleepAndWaitForTerm( 5 );
//    sleep(5 * 1000);
    if Terminated then Exit;
  end;

{deb code
with K_DCMGLibW do
begin
  DLGetSrvLastErrorInfo := WDLGetSrvLastErrorInfo;
  DLConnectEcho := WDLConnectEcho;
  DLEcho := WDLEcho;
  DLConnectQrScpMove := WDLConnectQrScpMove;
  DLMove             := WDLMove;
  DLDeleteSrvObject := WDLDeleteSrvObject;
  DLCloseConnection := WDLCloseConnection;
//  DLConnectStorageCommitmentScp := WDLConnectStorageCommitmentScp;
  DLCreateCommitmentRequest := WDLCreateCommitmentRequest;
  DLAddInstanceToCommit := WDLAddInstanceToCommit;
  DLSendStorageCommitmentRequest := WDLSendStorageCommitmentRequest;
  DLDeleteDcmObject := WDLDeleteDcmObject;
end;
{}

  SCTInstanceUIDs := TStringList.Create;
  SCTClassUIDs := TStringList.Create;
  SCTSIDs := TStringlist.Create;
  OnTerminate := SCTOnTerminate;
  ErrTestCount := -2;

  while TRUE do
  begin
    try
      if Terminated then Break; // check Terminated at Loop start
{DEB}
      with K_FormCMDCMExe do
      begin
        if DCMESCommConnectionAttrsFailFlag then
        begin
          LongWait( 'for work condition');
          Continue;
        end
        else
        if DCMESCommConnectionFailFlag then
        begin
          SCTDumpStr := 'SCT> Connection fails 30 sec wait';
          Synchronize( SCTSyncDump2Str );
          SleepAndWaitForTerm( 30 );
//          sleep(30 * 1000); // sleep 30 sec
          Continue;
        end
        else
        ErrTestCount := -1;
      end;
{}
      if Terminated then Break; // check Terminated before Sleep


      Synchronize( SCTSyncGetFromDBQueue );
{Old COde
      if (SCTQueueCount > 0) and (SCTHSRV = nil) then
      begin
        SCTDumpStr := 'SCT> Connection fails 30 sec wait';
        Synchronize( SCTSyncDump1Str );
        sleep(30 * 1000); // sleep 30 sec
        Continue;
      end;
{}
      if SCTQueueCount = 0 then
      begin
        // Sleep before next Check Loop
        SCTDumpStr := 'SCT> queue is empty 30 sec wait';
        Synchronize( SCTSyncDump2Str );
        SleepAndWaitForTerm( 30 );
//        sleep(30 * 1000); // sleep 30 sec
        Continue;
      end;

      SendRepeatCount := 10;
      repeat
        SCTSendCommitment();
        if not SCTSendCommitmentRes then
        begin
          Synchronize( SCTSyncDump1Str );
          SCTDumpStr := 'SCT> Commitment send error, 30 sec wait';
          Synchronize( SCTSyncDump2Str );
          SleepAndWaitForTerm( 30 );
//          sleep(30 * 1000); // sleep 30 sec
          Dec(SendRepeatCount);
        end;
      until (SendRepeatCount = 0) or SCTSendCommitmentRes;


//SCTSendCommitmentRes := TRUE; // DEB
      Synchronize( SCTSyncSetEventStatus );

      SCTExceptCount := 0;
    except
      on E: Exception do
      begin
        if SCTDumpErrStr <> '' then
        begin
          SCTDumpStr := 'SCT> ErrInfo ' + SCTDumpErrStr + #13#10 + SCTDumpStr;
          Synchronize( SCTSyncDump1Str );
        end;
        SCTDumpStr := 'SCT> TK_CMDCMSendCommitmentThread exception >> ' + E.Message;
        Synchronize( SCTSyncDump1Str );

        Inc(SCTExceptCount);
        if SCTExceptCount > 10 then
        begin
          SCTDumpStr := 'SCT> TK_CMDCMSendCommitmentThread terminate by exception';
          Synchronize( SCTSyncDump1Str );
          Exit;
        end;

      end;
    end; // try

  end; // while TRUE do

end; // procedure TK_CMDCMSendCommitmentThread.Execute;

{
procedure TK_CMDCMSendCommitmentThread.SCTSyncGetFromDBQueue;
var
  WInt : Integer;
begin
// Clear DB Queue if needed
  SCTSIDs.Clear;
  SCTInstanceUIDs.Clear;
  SCTClassUIDs.Clear;

  SCTTransUID := format( '%s.%s', [CentaurSoftwareUID,
                          K_DateTimeToStr( K_CMEDAccess.EDAGetSyncTimestamp(),
                          'yyyymmddhhnnsszzz' )] );


  // GetFromDBQueue
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    SCTDumpErrStr := 'Select from DCMComQueue';
    Connection := LANDBConnection;

    SQL.Text := 'select top ' + IntToStr(CommitmentPortion) + ' ' +
      K_CMENDDCMCQID + ',' +
      K_CMENDDCMCQSID + ',' +  K_CMENDDCMCQIUID + ',' +
      K_CMENDDCMCQCUID + ',' + K_CMENDDCMCQTUID +
      ' from ' + K_CMENDBDCMComQueueTable +
      ' where (' + K_CMENDDCMCQTUID + ' IS NULL) and '+
      '(' + K_CMENDDCMCQDT + '<=' + EDADBDateTimeToSQL( EDAGetSyncTimestamp ) + ')' +
      ' order by ' + K_CMENDDCMCQID;
    Filtered := false;
    Open();
    SCTQueueCount := RecordCount;
    if RecordCount > 0 then
    begin
      // Create commitment connection if needed

      if SCTHSRV = nil then
      begin
        with K_FormCMDCMExe, K_DCMGLibW do
          SCTHSRV := DLConnectStorageCommitmentScp( @DCMESCommSRVIP[1], DCMESCommSRVPort, @DCMESCommSRVAETScp[1], @DCMESCommSRVAETScu[1] );
        if SCTHSRV = nil then
        begin
          Close; // CurDSet1
          Exit;  // Connection fails
        end
        else
        begin
          // skip connection check for DCMETestConnectionThread
          Inc(K_FormCMDCMExe.DCMESkipConnectionCheck);
          N_Dump2Str( 'SCT>> SkipConnectionCheck inc' );
        end;
      end;

      SCTDumpErrStr := 'Set used flag to DCMComQueue';
      First;
      while not Eof do
      begin
        SCTSIDs.Add(FieldList.Fields[1].AsString);
        SCTInstanceUIDs.Add(FieldList.Fields[2].AsString);
        SCTClassUIDs.Add(FieldList.Fields[3].AsString);
        Edit;
        FieldList.Fields[4].AsString := SCTTransUID;
        Next;
      end;
      UpdateBatch;
      Close(); // CurDSet1
      if SCTInstanceUIDs.Count > 0 then
        N_Dump1Str( 'SCT>> Comm list:'+#13#10+
                     SCTInstanceUIDs.Text + #13#10+#13#10+
                     SCTClassUIDs.Text );

    end   // if RecordCount > 0 then
    else
    begin // if RecordCount = 0 then
      Close(); // CurDSet1
      // SkipConnectionCheck
      if SCTHSRV <> nil then
      begin
        // permit connection check for DCMETestConnectionThread
        Dec(K_FormCMDCMExe.DCMESkipConnectionCheck);
        N_Dump2Str( 'SCT>> SkipConnectionCheck dec' );

        with K_DCMGLibW do
        begin
          DLCloseConnection(SCTHSRV);
          DLDeleteSrvObject(SCTHSRV);
          SCTHSRV := nil;
        end;
      end;

      // Try to rebuild queue
      Inc(SCTCheckRebuildQueueCount);
      if SCTCheckRebuildQueueCount >= 10 then
      begin
        SCTDumpErrStr := 'Clear DCMComQueue';
        with TK_CMEDDBAccess(K_CMEDAccess), CurStoredProc1 do
        begin
          // Try to Rebuild DCMComQueue Table
          Connection := LANDBConnection;
          ProcedureName := 'cms_RebuildDCMComQueueTable';
          Parameters.Clear;
          with Parameters.AddParameter do
          begin
            Name := '@RebuildFlag';
            Direction := pdOutput;
            DataType := ftInteger;
            ExecProc;
            WInt := Value;
          end; // with Parameters.AddParameter do

          if WInt = 1 then
            N_Dump1Str('SCT>> Rebuild Table=' + K_CMENDBDCMComQueueTable );
        end; // with TK_CMEDDBAccess(K_CMEDAccess), CurStoredProc1 do
        SCTCheckRebuildQueueCount := 0;
      end; // if (SCTCheckRebuildQueueCount >= 10) and (K_CMEDDBVersion >= 45) then
    end; // if RecordCount = 0 then
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do

end; // procedure TK_CMDCMSendCommitmentThread.SCTSyncGetFromDBQueue
}
procedure TK_CMDCMSendCommitmentThread.SCTSyncGetFromDBQueue;
var
  WInt : Integer;
  BTransUID : string;
begin


// Clear DB Queue if needed
  SCTSIDs.Clear;
  SCTInstanceUIDs.Clear;
  SCTClassUIDs.Clear;

  SCTTransUID := format( '%s.%s', [CentaurSoftwareUID,
                          K_DateTimeToStr( K_CMEDAccess.EDAGetSyncTimestamp(),
                          'yyyymmddhhnnsszzz' )] );


  // GetFromDBQueue
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1, CurSQLCommand1 do
  begin
    Connection := LANDBConnection;
    // Delete Slide ID
    SCTDumpErrStr := 'Select from DCMComQueue 1';
    BTransUID := format( '%s.%s', [CentaurSoftwareUID,
                          K_DateTimeToStr( K_CMEDAccess.EDAGetSyncTimestamp() - 1,
                          'yyyymmdd000000000' )] );
    SQL.Text := 'select ' +
      K_CMENDDCMCQID + ',' +
      K_CMENDDCMCQSID + ',' +  K_CMENDDCMCQIUID + ',' +
      K_CMENDDCMCQCUID + ',' + K_CMENDDCMCQTUID +
      ' from ' + K_CMENDBDCMComQueueTable +
      ' where not (' + K_CMENDDCMCQTUID + ' IS NULL) and ' +
      '(' + K_CMENDDCMCQTUID + ' <= ''' + BTransUID + ''')';
    Filtered := false;
    Open();
    if RecordCount > 0 then
    begin
      while not Eof do
      begin
        SCTSIDs.Add( FieldList.Fields[0].AsString + ' ' +
                     FieldList.Fields[1].AsString + ' ' +
                     FieldList.Fields[4].AsString );
        Next;
      end;
    end;
    Close;

    if SCTSIDs.Count > 0 then
    begin // Dump and delete records
      N_Dump1Str( 'SCT>> Del List:'+#13#10+ SCTSIDs.Text  );
      SCTSIDs.Clear;
     // Remove old records from queue
      SCTDumpErrStr := 'Remove old records from queue';
      CommandText := 'delete from ' + K_CMENDBDCMComQueueTable +
      ' where not (' + K_CMENDDCMCQTUID + ' IS NULL) and ' +
      '(' + K_CMENDDCMCQTUID + ' <= ''' + BTransUID + ''')';
      Execute;
    end; // if SCTSIDs.Count > 0 then


    SCTDumpErrStr := 'Select from DCMComQueue 2';
    SQL.Text := 'select top ' + IntToStr(CommitmentPortion) + ' ' +
      K_CMENDDCMCQID + ',' +
      K_CMENDDCMCQSID + ',' +  K_CMENDDCMCQIUID + ',' +
      K_CMENDDCMCQCUID + ',' + K_CMENDDCMCQTUID +
      ' from ' + K_CMENDBDCMComQueueTable +
      ' where (' + K_CMENDDCMCQTUID + ' IS NULL) and '+
      '(' + K_CMENDDCMCQDT + '<=' + EDADBDateTimeToSQL( EDAGetSyncTimestamp ) + ')' +
      ' order by ' + K_CMENDDCMCQID;
    Filtered := false;
    Open();
    SCTQueueCount := RecordCount;
    if RecordCount > 0 then
    begin
      // Create commitment connection if needed

      SCTDumpErrStr := 'Set used flag to DCMComQueue';
      First;
      while not Eof do
      begin
        SCTSIDs.Add(FieldList.Fields[1].AsString);
        SCTInstanceUIDs.Add(FieldList.Fields[2].AsString);
        SCTClassUIDs.Add(FieldList.Fields[3].AsString);
        Edit;
        FieldList.Fields[4].AsString := SCTTransUID;
        Next;
      end;
      UpdateBatch;
      Close(); // CurDSet1
      if SCTInstanceUIDs.Count > 0 then
        N_Dump1Str( 'SCT>> Comm list:'+ SCTTransUID+ #13#10+
                     SCTSIDs.Text + #13#10+
                     SCTInstanceUIDs.Text + #13#10+
                     SCTClassUIDs.Text );

    end   // if RecordCount > 0 then
    else
    begin // if RecordCount = 0 then
      Close(); // CurDSet1

      // Try to rebuild queue
      Inc(SCTCheckRebuildQueueCount);
      if SCTCheckRebuildQueueCount >= 10 then
      begin
        SCTDumpErrStr := 'Clear DCMComQueue';
        with TK_CMEDDBAccess(K_CMEDAccess), CurStoredProc1 do
        begin
          // Try to Rebuild DCMComQueue Table
          Connection := LANDBConnection;
          ProcedureName := 'cms_RebuildDCMComQueueTable';
          Parameters.Clear;
          with Parameters.AddParameter do
          begin
            Name := '@RebuildFlag';
            Direction := pdOutput;
            DataType := ftInteger;
            ExecProc;
            WInt := Value;
          end; // with Parameters.AddParameter do

          if WInt = 1 then
            N_Dump1Str('SCT>> Rebuild Table=' + K_CMENDBDCMComQueueTable );
        end; // with TK_CMEDDBAccess(K_CMEDAccess), CurStoredProc1 do
        SCTCheckRebuildQueueCount := 0;
      end; // if (SCTCheckRebuildQueueCount >= 10) and (K_CMEDDBVersion >= 45) then
    end; // if RecordCount = 0 then
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do

end; // procedure TK_CMDCMSendCommitmentThread.SCTSyncGetFromDBQueue


procedure TK_CMDCMSendCommitmentThread.SCTOnTerminate(Sender: TObject);
begin
  SCTSIDs.Free();
  SCTInstanceUIDs.Free();
  SCTClassUIDs.Free();
end; // procedure TK_CMDCMSendCommitmentThread.SCTOnTerminate

procedure TK_CMDCMSendCommitmentThread.SCTSyncDump1Str;
begin
  N_Dump1Str( SCTDumpStr );
  SCTDumpStr := '';
end; // procedure TK_CMDCMSendCommitmentThread.SCTSyncDump1Str

procedure TK_CMDCMSendCommitmentThread.SCTSyncDump2Str;
begin
  N_Dump2Str( SCTDumpStr );
  SCTDumpStr := '';
end; // procedure TK_CMDCMSendCommitmentThread.SCTSyncDump2Str

procedure TK_CMDCMSendCommitmentThread.SCTSyncSetEventStatus;
var
  SQLStr : string;
  SFlag : string;
  SCode : Byte;
  IPatID, i : Integer;

begin
  N_Dump1Str( SCTDumpStr );
  SQLStr := '';
  for i := 0 to SCTSIDs.Count - 1 do
  begin
    if i > 0 then
      SQLStr := SQLStr + ' or ';
    SQLStr := SQLStr + K_CMENDBSTFSlideID + '=' + SCTSIDs[i];
  end;

  if SCTSendCommitmentRes then
  begin // Clear Commitment Request and Answer Status flags
    SCode := Ord(K_shNCADCMComm);
    SFlag := ' & 195 | 4'; // [K_bsdcmsComm]  clear [K_bsdcmsComm,K_bsdcmsCommErr,K_bsdcmsCommExists,K_bsdcmsCommAbsent]
  end   // if SCTSendCommitmentRes then
  else
  begin // if not SCTSendCommitmentRes then // Clear only Commitment Request Status flags
    SCode := Ord(K_shNCADCMCommErr);
    SFlag := ' & 243 | 8'; // [K_bsdcmsCommErr] clear [K_bsdcmsComm,K_bsdcmsCommErr]
  end;  // if not SCTSendCommitmentRes then

  SCTDumpErrStr := 'Save DICOM Hitory';
  N_Dump1Str( format('SCT>> %s SCode=%d ', [SCTDumpErrStr,SCode]) );
  with TK_CMEDDBAccess(K_CMEDAccess) do
    EDASaveSlidesHistory( SQLStr, EDABuildHistActionCode( K_shATNotChange,
                             Ord(K_shNCADICOM),
                             SCode ) );

  // Set Slides Processed Flags
  with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1, CurDSet1 do
  begin
    SCTDumpErrStr := 'Save DICOM Status';

    N_Dump1Str( format('SCT>> %s %s ', [SCTDumpErrStr,SFlag]) );
    CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
      K_CMENDBSTFSlideDFlags + ' = ' + K_CMENDBSTFSlideDFlags + SFlag +
      ' where ' + SQLStr;
    Execute;

    if not SCTSendCommitmentRes then
    begin // Remove records from queue because request was failed
      SCTDumpErrStr := 'Remove records from queue';
      N_Dump1Str( format('SCT>> %s with TUID=%s', [SCTDumpErrStr,SCTTransUID]) );
      CommandText := 'delete from ' + K_CMENDBDCMComQueueTable +
      ' where ' + K_CMENDDCMCQTUID + '=''' +  SCTTransUID  + ''';';
      Execute;
    end;

    SCTDumpErrStr := 'Set Patient changed state';
    SQL.Text := 'select distinct ' + K_CMENDBSTFPatID +
                ' from ' +  K_CMENDBSlidesTable  +
                ' where ' + SQLStr;

    Filtered := false;
    Open();
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        IPatID := FieldList.Fields[0].AsInteger;

        SFlag := SlidesImgRootFolder +
                 K_CMSlideGetPatientFilesPathSegm(IPatID) + '!';
        N_Dump1Str( format('SCT>> %s by %s', [SCTDumpErrStr,SFlag]) );
        if not K_DeleteFile( SFlag, [K_dofSkipStoreUndelNames] ) then
          N_Dump1Str( 'SCT>> could not delete ' + SFlag )
        else
          try
            with TFileStream.Create( SFlag, fmCreate ) do
              Free();
          except
            N_Dump1Str( 'SCT>> PatID error while create new ' + SFlag );
          end;

        Next;
      end;
    end;
    Close();
  end;

end; // procedure TK_CMDCMSendCommitmentThread.SCTSyncSetEventStatus

procedure TK_CMDCMSendCommitmentThread.SCTSendCommitment;
var
  DI : TK_HDCMINST;
  i, Ret : Integer;
  WStr1, WStr2 : WideString;
  ErrStr, AddStr : string;
begin
//
  SCTDumpStr := '';
  with K_DCMGLibW do
  begin
    // Prepare Request
    SCTDumpErrStr := 'Prepare Commitment Request ' + SCTTransUID;
    WStr1 := N_StringToWide(SCTTransUID);
    DI := DLCreateCommitmentRequest( @WStr1[1] );
    for i := 0 to SCTSIDs.Count - 1 do
    begin
      WStr1 := N_StringToWide(SCTInstanceUIDs[i]);
      WStr2 := N_StringToWide(SCTClassUIDs[i]);
      DLAddInstanceToCommit( DI, @WStr1[1], @WStr2[1] );
    end;

    SCTDumpErrStr := 'Send Commitment Request';

    with K_FormCMDCMExe do
      SCTHSRV := DLConnectStorageCommitmentScp( @DCMESCommSRVIP[1], DCMESCommSRVPort, @DCMESCommSRVAETScp[1], @DCMESCommSRVAETScu[1] );
    if SCTHSRV = nil then
    begin
      SCTDumpStr := 'SCT>> Connection error';
      SCTSendCommitmentRes := FALSE;
      DLDeleteDcmObject(DI);
      Exit;
    end
    else
    begin
      // skip connection check for DCMETestConnectionThread
      Inc( K_FormCMDCMExe.DCMESkipConnectionCheck );
      AddStr := 'SCT>> SkipConnectionCheck inc';
    end;

    Ret := DLSendStorageCommitmentRequest(SCTHSRV, DI);
    SCTSendCommitmentRes := (Ret = 0);
    if not SCTSendCommitmentRes then
    begin
      // get request error
      SetLength( WStr1, 1024 );
      i := 1024;
      DLGetSrvLastErrorInfo( SCTHSRV, @WStr1[1], @i );

      SetLength( WStr2, i );
      Move( WStr1[1], WStr2[1], i * SizeOf(Char) );
      ErrStr := N_WideToString(WStr2);

      SCTDumpStr := format( 'SCT>> Send CommitmentRequest TUID=%s >> %s',
                             [SCTTransUID, ErrStr] );
    end
    else
      SCTDumpStr := format( 'SCT>> Send CommitmentRequest TUID=%s OK',
                             [SCTTransUID] );
    // SkipConnectionCheck
      // permit connection check for DCMETestConnectionThread
    Dec(K_FormCMDCMExe.DCMESkipConnectionCheck);
    SCTDumpStr := AddStr + #13#10 + SCTDumpStr + #13#10 + 'SCT>> SkipConnectionCheck dec';

    DLCloseConnection(SCTHSRV);
    DLDeleteSrvObject(SCTHSRV);
    SCTHSRV := nil;
    DLDeleteDcmObject(DI);
  end;
end; // procedure TK_CMDCMSendCommitmentThread.SCTSendCommitment

{*** TK_CMDCMSendCommitmentThread ***}

{*** TK_CMDCMRecieveCommitmentThread ***}

procedure TK_CMDCMRecieveCommitmentThread.Execute;
var
  F: TSearchRec;

  function SleepAndWaitForTerm( ASecNum : Integer ) : Boolean;
  var i : Integer;
  begin
    Result := TRUE;
    for i := 1 to ASecNum do
    begin
      sleep ( 1000 );
      if Terminated then
        Exit;
    end;
    Result := Terminated;
  end; // SleepAndWaitForTerm

begin

  if K_CMEDDBVersion < 45 then
  begin
    RCTDumpStr := 'RCT> !!! Thread is terminated by DB version is ' + IntToStr(K_CMEDDBVersion);
    Synchronize( RCTSyncDump1Str );
    Exit;
  end;


  while K_DCMGLibW.DLDllHandle = 0 do // Precaution
  begin
    SleepAndWaitForTerm( 5 );
//    sleep(5000);
    if Terminated then
    begin
      RCTDumpStr := 'RCT> !!! Thread is terminated by wrapdcm.dll';
      Synchronize( RCTSyncDump1Str );
      Exit;
    end;
  end;

  if K_FormCMDCMExe.DCMECommonPath = '' then
  begin
    RCTDumpStr := 'RCT> !!! Thread is terminated by Common Path';
    Synchronize( RCTSyncDump1Str );
    Exit;
  end;

  RCTPath := K_FormCMDCMExe.DCMECommonPath + CommitmentFolder;

  SetLength( RCTWBuf, 1024 );

  while TRUE do
  begin
    try
      if Terminated then Break; // check Terminated at Loop start

      if FindFirst( RCTPath + '*.dcm', faAnyFile, F ) = 0 then
        repeat
          RCTSrcFName := RCTPath + F.Name;
          Synchronize( RCTSyncFileProc );
          K_DeleteFile( RCTSrcFName );
          if Terminated then Break; // check Terminated at Loop start
        until FindNext( F ) <> 0;
      FindClose( F );
      RCTExceptCount := 0;
    except
      on E: Exception do
      begin
        if RCTDumpErrStr <> '' then
        begin
          RCTDumpStr := 'RCT> ErrInfo ' + RCTDumpErrStr;
          Synchronize( RCTSyncDump1Str );
        end;
        RCTDumpStr := 'DCMS> DCMStoreFilesThread exception >> ' + E.Message;
        Synchronize( RCTSyncDump1Str );

        Inc(RCTExceptCount);
        if RCTExceptCount > 10 then
        begin
          RCTDumpStr := 'RCT> TK_CMDCMRecieveCommitmentThread terminate by exception';
          Synchronize( RCTSyncDump1Str );
          Exit;
        end;

      end;
    end; // try

    // Sleep before next Check Loop
    RCTDumpStr := 'RCT> 1 minute wait for next check';
    Synchronize( RCTSyncDump2Str );
    SleepAndWaitForTerm( 1 * 60 );
//    sleep(1 * 60 * 1000); // sleep 1 minutes
//    sleep(1 * 1000); // sleep 1 sec deb

  end; // while TRUE do


end; // procedure TK_CMDCMRecieveCommitmentThread.Execut

procedure TK_CMDCMRecieveCommitmentThread.RCTSyncFileProc( );
var
  DI : TK_HDCMINST;
  ECF : string;
  sz : Integer;
  IsNil, ExistCount, AbsentCount, RequestCount, i : Integer;
  WUInt2 : TN_UInt2;
  ResCode : Integer;
  TUID : string;
  InstanceUID : string;
  WStr : WideString;
  CommitmentRes : Boolean;
  SQLStr : string;


  procedure SetEventStatus( const ASQLSTR : string );
  var
    SFlag : string;
    SCode : Byte;
    IPatID : Integer;

  begin
    if CommitmentRes then
    begin // Clear Commitment Request and Answer Status flags
      SCode := Ord(K_shNCADCMExists);
      SFlag := ' & 207 | 16'; // [K_bsdcmsCommExists]  clear [K_bsdcmsCommExists,K_bsdcmsCommAbsent]
    end   // if SCTSendCommitmentRes then
    else
    begin // if not SCTSendCommitmentRes then // Clear only Commitment Request Status flags
      SCode := Ord(K_shNCADCMAbsent);
      SFlag := ' & 207 | 32'; // [K_bsdcmsCommAbsent] clear [K_bsdcmsCommExists,K_bsdcmsCommAbsent]
    end;  // if not SCTSendCommitmentRes then

    RCTDumpErrStr := 'Save DICOM Hitory';
    N_Dump1Str( format('RCT>> %s SCode=%d ', [RCTDumpErrStr,SCode]) );
    with TK_CMEDDBAccess(K_CMEDAccess) do
      EDASaveSlidesHistory( ASQLStr, EDABuildHistActionCode( K_shATNotChange,
                               Ord(K_shNCADICOM),
                               SCode ) );

    // Set Slides Processed Flags
    with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1, CurDSet2 do
    begin
      RCTDumpErrStr := 'Save DICOM Status';
      N_Dump1Str( format('RCT>> %s %s ', [RCTDumpErrStr,SFlag]) );

      CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
        K_CMENDBSTFSlideDFlags + ' = ' + K_CMENDBSTFSlideDFlags + SFlag +
        ' where ' + ASQLStr;
      Execute;


      RCTDumpErrStr := 'Set Patient changed state';
      SQL.Text := 'select distinct ' + K_CMENDBSTFPatID +
                  ' from ' +  K_CMENDBSlidesTable  +
                  ' where ' + ASQLStr;

      Filtered := false;
      Open();
      if RecordCount > 0 then
      begin
        First;
        while not Eof do
        begin
          IPatID := FieldList.Fields[0].AsInteger;

          SFlag := SlidesImgRootFolder +
                   K_CMSlideGetPatientFilesPathSegm(IPatID) + '!';
          N_Dump1Str( format('RCT>> %s by %s', [RCTDumpErrStr,SFlag]) );
          if not K_DeleteFile( SFlag, [K_dofSkipStoreUndelNames] ) then
            N_Dump1Str( 'RCT>> could not delete ' + SFlag )
          else
            try
              with TFileStream.Create( SFlag, fmCreate ) do
                Free();
            except
              N_Dump1Str( 'RCT>> PatID error while create new ' + SFlag );
            end;

          Next;
        end;
      end;
      Close();
    end;

  end; // procedure SetEventStatus


begin
  with K_DCMGLibW do
  begin
    N_Dump1Str( 'RCT>> Process file ' +  RCTSrcFName );
    ECF := K_FormCMDCMExe.DCMECommonPath + ErrCommitmentFolder + ExtractFileName(RCTSrcFName);

    WStr := N_StringToWide( RCTSrcFName );
    DI :=  DLCreateInstanceFromFile( @WStr[1], 255 );
    if DI = nil then
    begin // wrong request answer file
      if K_CopyFile( RCTSrcFName, ECF ) = 0 then
        RCTDumpStr := 'RCT> !!! CreateInstance error File is copied to '
      else
        RCTDumpStr := 'RCT> !!! CreateInstance error File copy error to ';
      RCTDumpStr := RCTDumpStr + ECF;
      N_Dump1Str( RCTDumpStr );
      Exit;
    end;

    // get transaction UID tag
    sz := 1024;
    ResCode := DLGetValueString( DI, K_CMDCMTTransactionUid, @RCTWBuf[1], @sz, @isNil);
    if ResCode <> 0 then
    begin
      DLDeleteDcmObject(DI);
      N_Dump1Str( 'RCT> !!!  Tag TransactionUid is absent' );
      Exit;
    end;
    TUID := N_WideToString( Copy( RCTWBuf, 1, sz ) );

    // Get DBQueue elments for given transaction
    N_Dump1Str( 'RCT> Process Transaction ' + TUID );
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
    begin
      RCTDumpErrStr := 'Process DCMComQueue';
      Connection := LANDBConnection;
      SQL.Text := 'select '  +
        K_CMENDDCMCQID + ',' +
        K_CMENDDCMCQSID + ',' +  K_CMENDDCMCQIUID + ',' +
        K_CMENDDCMCQCUID +
        ' from ' + K_CMENDBDCMComQueueTable +
        ' where ' + K_CMENDDCMCQTUID + '=''' + TUID + '''';
      Filtered := false;
      Open();
      RequestCount := RecordCount;
      if RequestCount > 0 then
      begin
        // proccess PACS existing
        RCTDumpErrStr := 'Get existed from DCMComQueue';
        ExistCount := DLGetSequenceLength(DI, K_CMDCMTReferencedSopSequence);
        CommitmentRes := TRUE;
        SQLStr := '';
        for i := 0 to ExistCount - 1 do
        begin
          sz := 1024;
          WUInt2 := DLGetSequenceItemTagValue(DI, K_CMDCMTReferencedSopSequence, i, K_CMDCMTReferencedSopInstanceUid, @RCTWBuf[1], @sz, @isNil);
          if WUInt2 <> 0 then
          begin
            N_Dump1Str( format( 'RCT>> Get Existed %d SOPInstance UID fails %d', [i,WUInt2] ) );
            Continue;
          end;

          InstanceUID := N_WideToString( Copy( RCTWBuf, 1, sz ) );
          Filtered := FALSE;
          Filter := K_CMENDDCMCQIUID + '=''' + InstanceUID + '''';
          Filtered := TRUE;
          if RecordCount = 0 then
          begin
            N_Dump1Str('RCT>> Existed SOPInstance UID is not found in queue');
            Continue;
          end;
          if SQLStr <> '' then
            SQLStr := SQLStr + ' or ';
          SQLStr := SQLStr + K_CMENDBSTFSlideID +'=' + FieldList.Fields[1].AsString;
        end; // for i := 0 to ExistCount - 1 do

        N_Dump1Str( 'RCT> Existed ' + SQLStr );

        if SQLStr <> '' then
          SetEventStatus( SQLStr );

        // proccess PACS absent
        RCTDumpErrStr := 'Get absent from DCMComQueue';
        AbsentCount := DLGetSequenceLength(DI, K_CMDCMTFailedSopSequence);
        CommitmentRes := FALSE;
        SQLStr := '';
        for i := 0 to AbsentCount - 1 do
        begin
          sz := 1024;
          WUInt2 := DLGetSequenceItemTagValue(DI, K_CMDCMTFailedSopSequence, i, K_CMDCMTReferencedSopInstanceUid, @RCTWBuf[1], @sz, @isNil);
          if WUInt2 <> 0 then
          begin
            N_Dump1Str( format( 'RCT>> Get Absent %d SOPInstance UID fails %d', [i,WUInt2] ) );
            Continue;
          end;

          InstanceUID := N_WideToString( Copy( RCTWBuf, 1, sz ) );

          Filtered := FALSE;
          Filter := K_CMENDDCMCQIUID + '=''' + InstanceUID + '''';
          Filtered := TRUE;
          if RecordCount = 0 then
          begin
            N_Dump1Str('RCT>> Absent SOPInstance UID is not found in queue');
            Continue;
          end;
          if SQLStr <> '' then
            SQLStr := SQLStr + ' or ';
          SQLStr := SQLStr + K_CMENDBSTFSlideID +'=' + FieldList.Fields[1].AsString;
        end; // for i := 0 to ExistCount - 1 do

        N_Dump1Str( 'RCT> Absent ' + SQLStr );

        if SQLStr <> '' then
          SetEventStatus( SQLStr );

        Close; // CurDSet1

        // Remove records from queue because request answer was processed
        RCTDumpErrStr := 'Remove records from queue';
        with CurSQLCommand1 do
        begin
          CommandText := 'delete from ' + K_CMENDBDCMComQueueTable +
          ' where ' + K_CMENDDCMCQTUID + '=''' +  TUID  + ''';';
          Execute;
        end;
      end   // if RequestCount > 0 then
      else
      begin // if RequestCount = 0 then strange Request
        Close(); // CurDSet1
        N_Dump1Str( 'RCT> !!! strange TransactionUid is absent in DB Queue ' + TUID );
        if K_CopyFile( RCTSrcFName, ECF ) = 0 then
          RCTDumpStr := 'RCT> !!! Strange TransactionUid File is copied to '
        else
          RCTDumpStr := 'RCT> !!! Strange TransactionUid File copy error to ';
        RCTDumpStr := RCTDumpStr + ECF;
        N_Dump1Str( RCTDumpStr );
      end; // if RecordCount = 0 then strange Request
    end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do

    DLDeleteDcmObject(DI);

  end; // with K_DCMGLibW do

end; // function TK_CMDCMRecieveCommitmentThread.RCTSyncFileProc

procedure TK_CMDCMRecieveCommitmentThread.RCTSyncDump1Str;
begin
  N_Dump1Str( RCTDumpStr );
  RCTDumpStr := '';
end;

procedure TK_CMDCMRecieveCommitmentThread.RCTSyncDump2Str;
begin
  N_Dump2Str( RCTDumpStr );
  RCTDumpStr := '';
end;
{*** TK_CMDCMRecieveCommitmentThread ***}

{*** TK_CMDCMRetrieveDataThread ***}

procedure TK_CMDCMRetrieveDataThread.Execute;
var
  F: TSearchRec;
  ErrTestCount : Integer;
  MoveRepeatCount : Integer;

  function SleepAndWaitForTerm( ASecNum : Integer ) : Boolean;
  var i : Integer;
  begin
    Result := TRUE;
    for i := 1 to ASecNum do
    begin
      sleep ( 1000 );
      if Terminated then
        Exit;
    end;
    Result := Terminated;
  end; // SleepAndWaitForTerm

  procedure LongWait( const AText : string ); // 5 5 5 15 5 15 5 15 5 15 ...
  begin
    if ErrTestCount = -2 then
    begin
      RDTDumpStr := 'RDT> 5 sec wait ' + AText;
      Synchronize( RDTSyncDump2Str );
      SleepAndWaitForTerm( 5 );
//      sleep( 5 * 1000 ); // sleep 5 sec
      Inc(ErrTestCount);
    end
    else
    if ErrTestCount = -1 then
    begin
      RDTDumpStr := 'RDT> 30 sec wait ' + AText;
      Synchronize( RDTSyncDump2Str );
      SleepAndWaitForTerm( 30 );
//      sleep( 30 * 1000 ); // sleep 30 sec
//      sleep( 5 * 1000 ); // sleep 5 sec deb
      Inc(ErrTestCount);
    end
    else
    if ErrTestCount < 3 then
    begin
      RDTDumpStr := 'RDT> 5 minutes wait ' + AText;
      Synchronize( RDTSyncDump2Str );
      SleepAndWaitForTerm( 5 * 60 );
//      sleep( 5 * 60 * 1000 ); // sleep 5 minutes
//      sleep( 5 * 1000 ); // sleep 5 sec deb
      Inc(ErrTestCount);
    end
    else
    begin
      RDTDumpStr := 'RDT> 15 minutes wait ' + AText;
      Synchronize( RDTSyncDump2Str );
      SleepAndWaitForTerm( 15 * 60 );
//      sleep( 15 * 60 * 1000 ); // sleep 15 minutes
//      sleep( 15 * 1000 ); // sleep 15 sec deb
      ErrTestCount := 2;
    end;
  end; // procedure LongWait();

begin
  if K_CMEDDBVersion < 46 then
  begin
    RDTDumpStr := 'RDT> !!! Thread is terminated by DB version ' + IntToStr(K_CMEDDBVersion);
    Synchronize( RDTSyncDump1Str );
    Exit;
  end;

  while K_DCMGLibW.DLDllHandle = 0 do // Precaution
  begin
    SleepAndWaitForTerm( 5 );
//    sleep(5 * 1000);
    if Terminated then Exit;
  end;

{deb code
with K_DCMGLibW do
begin
  DLGetSrvLastErrorInfo := WDLGetSrvLastErrorInfo;
  DLConnectEcho := WDLConnectEcho;
  DLEcho := WDLEcho;
  DLConnectQrScpMove := WDLConnectQrScpMove;
  DLMove             := WDLMove;
  DLDeleteSrvObject := WDLDeleteSrvObject;
  DLCloseConnection := WDLCloseConnection;
end;
{}

  RDTSIDs := TStringlist.Create;
  RDTFDENames := TStringlist.Create;
  SetLength( RDTWBuf, 1024 );
  RDTPath := K_FormCMDCMExe.DCMECommonPath + RetrieveFolder;
  RDTErrPath := K_FormCMDCMExe.DCMECommonPath + ErrRetrieveFolder;
  ErrTestCount := -2;

  while TRUE do
  begin
    try
      if Terminated then Break; // check Terminated at Loop start
{DEB}
      with K_FormCMDCMExe do
      begin

        if DCMERDConnectionAttrsFailFlag then
        begin
          LongWait( 'for work condition');
          Continue;
        end
        else
        if DCMERDConnectionFailFlag then
        begin
          RDTDumpStr := 'RDT> Echo Connection fails 30 sec wait';
          Synchronize( RDTSyncDump2Str );
          SleepAndWaitForTerm( 30 );
//          sleep(30 * 1000); // sleep 30 sec
          Continue;
        end
        else
          ErrTestCount := -1;
      end;
{}
      // Try to remove undelete files
      if RDTFDENames.Count > 0 then
      begin
        sleep(3 * 1000); // sleep 3 sec
        Synchronize( RDTSyncTryToRemoveUDFiles );
      end;

      if Terminated then Break; // check Terminated before Sleep

      Synchronize( RDTSyncGetFromDBQueue );

      if RDTQueueCount = 0 then
      begin
        // Sleep before next Check Loop
        RDTDumpStr := 'RDT> queue is empty 15 sec wait';
        Synchronize( RDTSyncDump2Str );
        SleepAndWaitForTerm( 15 );
        sleep(15 * 1000); // sleep 15 sec
        Continue;
      end; // if RDTQueueCount = 0 then

      MoveRepeatCount := 10;
      repeat
        RDTRetieveData();
        Synchronize( RDTSyncDump1Str );
        if RDTMoveErrFlag then
        begin
          RDTDumpStr := format( 'RDT> Move %d error, 30 sec wait', [MoveRepeatCount] );
          Synchronize( RDTSyncDump2Str );
          SleepAndWaitForTerm( 30 );
//          sleep(30 * 1000); // sleep 30 sec
          Dec(MoveRepeatCount);
          if Terminated then Break; // check Terminated
        end;
      until (MoveRepeatCount = 0) or not RDTMoveErrFlag;

      if Terminated then Break; // check Terminated
//      SCTSendCommitment();
//SCTSendCommitmentRes := TRUE; // DEB
      RDTMoveErrCount := 0;
      if FindFirst( RDTPath + '*.dcm', faAnyFile, F ) = 0 then
        repeat
          RDTSrcFName := RDTPath + F.Name;
          if (RDTFDENames.Count = 0) or
             (RDTFDENames.Indexof(RDTSrcFName) < 0) then
          begin
            Synchronize( RDTSyncImportRetrievResults );
            if not K_DeleteFile( RDTSrcFName, [K_dofDeleteReadOnly,K_dofSkipStoreUndelNames] )then
            begin
              RDTFDENames.Add( RDTSrcFName );
              RDTDumpStr := 'RDT> del file error ' + RDTSrcFName;
              Synchronize( RDTSyncDump1Str );
            end;
          end
          else
          begin
            RDTDumpStr := 'RDT> skip undelete file ' + RDTSrcFName;
            Synchronize( RDTSyncDump1Str );
          end;
          if Terminated then Break; // check Terminated at Loop start
        until FindNext( F ) <> 0;
      FindClose( F );

      Synchronize( RDTSyncSetEventStatus );
      RDTExceptCount := 0;
    except
      on E: Exception do
      begin
        if RDTDumpErrStr <> '' then
        begin
          RDTDumpStr := 'RDT> ErrInfo ' + RDTDumpErrStr  + #13#10 + RDTDumpStr;
          Synchronize( RDTSyncDump1Str );
        end;

        RDTDumpStr := 'RDT> TK_CMDCMRetrieveDataThread exception >> ' + E.Message;
        Synchronize( RDTSyncDump1Str );

        Inc(RDTExceptCount);
        if RDTExceptCount > 10 then
        begin
          RDTDumpStr := 'RDT> TK_CMDCMRetrieveDataThread terminate by exception';
          Synchronize( RDTSyncDump1Str );
          Exit;
        end;
      end;
    end; // try

  end; // while TRUE do


end; // procedure TK_CMDCMRetrieveDataThread.Execute

procedure TK_CMDCMRetrieveDataThread.RDTOnTerminate(Sender: TObject);
begin
  RDTSIDs.Free();
  RDTFDENames.Free();
end; // procedure TK_CMDCMRetrieveDataThread.RDTOnTerminate

procedure TK_CMDCMRetrieveDataThread.RDTRetieveData;
var
  AddStr : string;
  WUInt2, NumberOfRemainingSubOperations, NumberOfCompletedSubOperations,
  NumberOfFailedSubOperations, NumberOfWarningSubOperations : TN_UInt2;
  PW : PWideChar;
  SZ : Integer;
const
  WC: WideChar = #0;

begin
// Create commitment connection if needed
{DEB}
  RDTDumpErrStr := 'RetieveData';
  RDTDumpStr := '';
  RDTMoveErrFlag := FALSE;
  with K_DCMGLibW do
  begin
    with K_FormCMDCMExe do
      RDTHSRV := DLConnectQrScpMove( @DCMERDSRVIP[1], DCMERDSRVPort, @DCMERDSRVAETScp[1], @DCMERDSRVAETScu[1], 0 );
    if RDTHSRV = nil then
    begin
      RDTDumpStr := 'RDT>> Connection error';
      RDTMoveErrFlag := TRUE;
      Exit;  // Connection fails
    end
    else
    begin
      // skip connection check for DCMETestConnectionThread
      Inc(K_FormCMDCMExe.DCMESkipConnectionCheck);
      AddStr := 'RDT>> SkipConnectionCheck inc';

      // Move
      PW := @WC;

      RDTDumpStr := format( 'RDT>> Move 2 AET=%s PatID=%s StudyUID=%s SeriesUID=%s',
                      [K_FormCMDCMExe.DCMERDSRVAETScu,RDTDBDCMPID,RDTDBSTUID,RDTDBSEUID] );
      with K_FormCMDCMExe do
//      WUInt2 := DLMove( RDTHSRV, 0, @DCMERDSRVAETScu[1],
      WUInt2 := DLMove( RDTHSRV, 2, @DCMERDSRVAETScu[1],
         @RDTDBDCMPID[1], @RDTDBSTUID[1], @RDTDBSEUID[1], PW, PW,
         @NumberOfRemainingSubOperations, @NumberOfCompletedSubOperations,
         @NumberOfFailedSubOperations, @NumberOfWarningSubOperations, nil );

      RDTDumpStr := RDTDumpStr + #13#10 +
            format( 'RDT>> Move Res=%d Rem=%d Comp=%d, Fails=%d Warn=%d',
                     [WUInt2,NumberOfRemainingSubOperations,NumberOfCompletedSubOperations,
                      NumberOfFailedSubOperations,NumberOfWarningSubOperations ] );
      RDTMoveErrFlag := WUInt2 <> 0;

      if RDTMoveErrFlag then
      begin
        SZ := 1024;
        DLGetSrvLastErrorInfo( RDTHSRV, @RDTWBuf[1], @SZ );
  			RDTDumpStr := RDTDumpStr + #13#10 + N_WideToString( Copy( RDTWBuf, 1, SZ ) );
      end;

      // permit connection check for DCMETestConnectionThread
      Dec(K_FormCMDCMExe.DCMESkipConnectionCheck);
      RDTDumpStr := AddStr + #13#10 + RDTDumpStr + #13#10 + 'RDT>> SkipConnectionCheck dec';

      DLCloseConnection(RDTHSRV);
      DLDeleteSrvObject(RDTHSRV);
      RDTHSRV := nil;
    end;
  end;
end; // procedure TK_CMDCMRetrieveDataThread.RDTRetieveData

procedure TK_CMDCMRetrieveDataThread.RDTSyncDump1Str;
begin
  N_Dump1Str( RDTDumpStr );
  RDTDumpStr := '';
end; // procedure TK_CMDCMRetrieveDataThread.RDTSyncDump1Str

procedure TK_CMDCMRetrieveDataThread.RDTSyncDump2Str;
begin
  N_Dump2Str( RDTDumpStr );
  RDTDumpStr := '';
end; // procedure TK_CMDCMRetrieveDataThread.RDTSyncDump2Str

procedure TK_CMDCMRetrieveDataThread.RDTSyncGetFromDBQueue;
var
  WInt{, i} : Integer;
  {Str : string;}

begin
  // GetFromDBQueue
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    RDTSIDs.Clear;
    RDTMoveErrFlag := FALSE;
    RDTDumpErrStr := 'Select from DCMRQueue';
    Connection := LANDBConnection;

    SQL.Text := 'select top 1 ' +
      K_CMENDDCMRQID + ',' +
      K_CMENDDCMRQSPID + ',' + K_CMENDDCMRQDPID + ',' +
      K_CMENDDCMRQSTUID + ',' + K_CMENDDCMRQSEUID +
      ' from ' + K_CMENDBDCMRQueueTable;
    Filtered := false;
    Open();
    RDTQueueCount := RecordCount;
    if RecordCount > 0 then
    begin
{}
      RDTDumpErrStr := 'Get from DCMRQueue';
      RDTDBID := FieldList.Fields[0].AsInteger;
      RDTDBCMSPID := FieldList.Fields[1].AsInteger;
      RDTDBDCMPID := N_StringToWide( FieldList.Fields[2].AsString );
      RDTDBSTUID  := N_StringToWide( FieldList.Fields[3].AsString );
      RDTDBSEUID  := N_StringToWide( FieldList.Fields[4].AsString );
      Close(); // CurDSet1

      N_Dump1Str( format( 'RDT>> Get from DB RID=%d CMSPAID=%d DCMPID=%s StudyUID=%s SeriesUID=%s',
                      [RDTDBID,RDTDBCMSPID,RDTDBDCMPID,RDTDBSTUID,RDTDBSEUID] ) );
    end   // if RecordCount > 0 then
    else
    begin // if RecordCount = 0 then
      Close(); // CurDSet1

      // Try to rebuild queue
      Inc(RDTCheckRebuildQueueCount);
      if RDTCheckRebuildQueueCount >= 10 then
      begin
        RDTDumpErrStr := 'Clear DCMRQueue';
        with TK_CMEDDBAccess(K_CMEDAccess), CurStoredProc1 do
        begin
          // Try to Rebuild DCMComQueue Table
          Connection := LANDBConnection;
          ProcedureName := 'cms_RebuildDCMRQueueTable';
          Parameters.Clear;
          with Parameters.AddParameter do
          begin
            Name := '@RebuildFlag';
            Direction := pdOutput;
            DataType := ftInteger;
            ExecProc;
            WInt := Value;
          end; // with Parameters.AddParameter do

          if WInt = 1 then
            N_Dump1Str('RDT>> Rebuild Table=' + K_CMENDBDCMRQueueTable );
        end; // with TK_CMEDDBAccess(K_CMEDAccess), CurStoredProc1 do
        RDTCheckRebuildQueueCount := 0;
      end; // if (SCTCheckRebuildQueueCount >= 10) and (K_CMEDDBVersion >= 45) then
    end; // if RecordCount = 0 then
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do


end; // procedure TK_CMDCMRetrieveDataThread.RDTSyncGetFromDBQueue

procedure TK_CMDCMRetrieveDataThread.RDTSyncImportRetrievResults;
var
  DI : TK_HDCMINST;
  WS : WideString;
  WSlide : TN_UDCMSlide;
  ErrFName : string;

  function GetTagValue( ATAG : TN_UInt4; const ATagName : string ) : string;
  var
    sz : Integer;
    isNil : Integer;
  begin
    sz := 1024;
    Result := '';
    if 0 <>	 K_DCMGLibW.DLGetValueString( DI, ATAG, @RDTWBuf[1], @sz, @isNil) then
      N_Dump1Str( 'TK_FormCMDCMQR >> GetTag ' + ATagName  )
    else
    begin
      Result := N_WideToString( Copy( RDTWBuf, 1, sz ) );
      N_Dump2Str( '>>' + ATagName + '=' + Result );
    end;
  end; // function GetTagValue

  procedure CopyErrFile();
  begin
    ErrFName := RDTErrPath + ExtractFileName(RDTSrcFName);
    K_CopyFile( RDTSrcFName, ErrFName, [K_cffOverwriteNewer,K_cffOverwriteReadOnly] );
  end;

  function CompareDBDCM( ATAG : TN_UInt4; const ATagName, ACompValue : string ) : Boolean;
  var Str : string;
  begin
    Str := GetTagValue( ATAG, ATagName );
    Result := SameText( ACompValue, Str );
    if Result then Exit;
    CopyErrFile();
    N_Dump1Str( format( 'RDT>> RDTSyncImportRetrievResults >> Wrong Tag %s "%s" <> "%s"'#13#10 +
                        '%s >> %s' , [ATagName,ACompValue,Str,RDTSrcFName,ErrFName] ) );
    with K_DCMGLibW do
      DLDeleteDcmObject( DI );
  end; // function CompareDBDCM

begin
  with K_DCMGLibW do
  begin
    N_Dump1Str( 'RDT> Start process ' + RDTSrcFName );
    WS := N_StringToWide( RDTSrcFName );
    DI := DLCreateInstanceFromFile( @WS[1], 255 );
    if DI = nil then
    begin
      CopyErrFile();
      N_Dump1Str( format( 'RDT>> DLCreateInstanceFromFile error!!!'#13#10 +
                  '%s >> %s', [RDTSrcFName,ErrFName] ) );
      Exit;
    end;
    if not CompareDBDCM( K_CMDCMTPatientId, 'PatientID', N_WideToString(RDTDBDCMPID)) then Exit;
    if not CompareDBDCM( K_CMDCMTStudyInstanceUid, 'StudyUID', N_WideToString(RDTDBSTUID)) then Exit;
    if not CompareDBDCM( K_CMDCMTSeriesInstanceUid, 'SeriesUID', N_WideToString(RDTDBSEUID)) then Exit;
    WSlide := K_DCMCreateSlideFromInstanceHandle( DI, RDTDBCMSPID, RDTSrcFName );
    DLDeleteDcmObject( DI );

    if WSlide = nil then
    begin
      CopyErrFile();
      N_Dump1Str( format( 'RDT>> RDTSyncImportRetrievResults >> Slide creation error!!!'#13#10 +
                  '%s >> %s', [RDTSrcFName,ErrFName] ) );
      Exit;
    end;
    K_CMDCMStoreAutoSkipFlag := TRUE;
    K_CMEDAccess.EDASaveSlidesArray( @WSlide, 1 );
    K_CMDCMStoreAutoSkipFlag := FALSE;

    RDTSIDs.Add( WSlide.ObjName );
    K_CMEDAccess.CurSlidesList.Clear;
    WSlide.UDDelete();
  end;
end; // procedure TK_CMDCMRetrieveDataThread.RDTSyncImportRetrievResults

procedure TK_CMDCMRetrieveDataThread.RDTSyncSetEventStatus;
var
  SQLStr : string;
  SFName : string;
  i : Integer;

begin
  N_Dump1Str( RDTDumpStr );

  SQLStr := '';
  for i := 0 to RDTSIDs.Count - 1 do
  begin
    if i > 0 then
      SQLStr := SQLStr + ' or ';
    SQLStr := SQLStr + K_CMENDBSTFSlideID + '=' + RDTSIDs[i];
  end;

  // Set Slides Status Flags
  with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
  begin
    if RDTSIDs.Count > 0 then
    begin
      RDTDumpErrStr := 'Save DICOM Status';
      N_Dump1Str( format('RDT>> %s  & 191 | 64 >> %s', [RDTDumpErrStr, SQLStr]) );
      CommandText := 'UPDATE ' + K_CMENDBSlidesTable + ' SET ' +
        K_CMENDBSTFSlideDFlags + ' = ' + K_CMENDBSTFSlideDFlags + ' & 191 | 64' +
        ' where ' + SQLStr;
      Execute;
    end;

    // Remove record from queue
    RDTDumpErrStr := 'Remove records from queue';

    N_Dump1Str( format('RDT>> %s with queue ID=%d', [RDTDumpErrStr,RDTDBID]) );
    CommandText := 'delete from ' + K_CMENDBDCMRQueueTable +
    ' where ' + K_CMENDDCMRQID + '=' +  IntToStr(RDTDBID)  + ';';
    Execute;

    // Set Change Flag to Patient
    if RDTSIDs.Count > 0 then
    begin
      RDTDumpErrStr := 'Set Patient changed state';
      SFName := SlidesImgRootFolder +
               K_CMSlideGetPatientFilesPathSegm(RDTDBCMSPID) + '!';
      N_Dump1Str( format('RDT>> %s by %s', [RDTDumpErrStr,SFName]) );
      if not K_DeleteFile( SFName, [K_dofSkipStoreUndelNames] ) then
        N_Dump1Str( 'RDT>> could not delete ' + SFName );
      try
        with TFileStream.Create( SFName, fmCreate ) do
          Free();
      except
        N_Dump1Str( 'RDT>> PatID error while create new ' + SFName );
      end;
    end;
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do

//  N_Dump1Str( SCTDumpStr );
end; // procedure TK_CMDCMRetrieveDataThread.RDTSyncSetEventStatus

procedure TK_CMDCMRetrieveDataThread.RDTSyncTryToRemoveUDFiles;
var
  SFName : string;
  i : Integer;

begin
  N_Dump1Str( 'RDT>> try to remove undeleted files loop start' );
  for i := RDTFDENames.Count -1 downto 0 do
  begin
    SFName := RDTFDENames[i];
    if not K_DeleteFile( SFName, [K_dofDeleteReadOnly,K_dofSkipStoreUndelNames] )then
      N_Dump1Str( 'RDT> try to delete file error ' + SFName )
    else
    begin
      RDTFDENames.Delete(i);
      N_Dump2Str( 'RDT> try to remove file OK ' + SFName );
    end;
//    if Terminated then Break; // check Terminated at Loop start
  end;
end; // procedure TK_CMDCMRetrieveDataThread.RDTSyncTryToRemoveUDFiles

{*** TK_CMDCMRetrieveDataThread ***}

end.
