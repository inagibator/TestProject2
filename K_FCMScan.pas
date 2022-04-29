unit K_FCMScan;

// 09.11.21 - patient details added
// 22.04.22 - windows resizing for patient details added

interface

uses
  Windows, Messages, SysUtils, Forms,
  Dialogs, ShellApi, ToolWin, ImgList, Menus, Controls, Classes,
  ExtCtrls, ComCtrls, Graphics, StdCtrls,
  N_BaseF, N_Lib0,
  K_CM0, K_UDT1, K_Types, ActnList, IdBaseComponent, IdComponent,
  IdTCPServer, IdCustomHTTPServer, IdHTTPServer, System.Actions, Vcl.AppEvnts{, System.Actions, IdTCPConnection,
  IdTCPClient, IdHTTP, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdCustomHTTPServer, IdHTTPServer, IdContext, IdTCPServer};
// for comp in D7
const
  ERROR_SUCCESS = 0;                                   ////Igor 23032020

  PBT_APMSUSPEND = 4;                                  ////Igor 08092019
  PBT_APMRESUMESUSPEND = 7;
  PBT_APMRESUMEAUTOMATIC = 18;

const K_SCUScanMaxWANErrCount = 20;
const K_SCUScanMaxLocErrCount = 10;
{ // for comp in D7
type EVENT_DESCRIPTOR = record                         ////Igor 23032020
  Id: UShort;
  Version, Channel, Level, Opcode: UChar;
  Task: UShort;
  Keyword: ULongLong;
end;
PCEVENT_DESCRIPTOR = ^EVENT_DESCRIPTOR;

type EVENT_DATA_DESCRIPTOR = record
    Ptr: ULongLong;
    Size: ULong;
    Reserved: ULong;
end;
PEVENT_DATA_DESCRIPTOR = ^EVENT_DATA_DESCRIPTOR;        ////Igor 23032020
}
type TK_SCUScanDataThread = class (TThread)
    // True WEB CommandLine Context
    ///////////////////////////////
  SCUUploadTasks, SCURemoveTasks : TStringList;
  SCUUploadQueryLocSFile  : string;  // Local Task S-file from Upload Query
  SCUUploadInProcess : Boolean; // Local Task Upload in process
  SCURemoveSFile     : string;  // Task S-file from Remove Query
  SCURemoveInProcess : Boolean; // Task Remove in process

// Local Scans Folder - K_FormCMScan.SCScanRootLocFolder
  SCUScanTaskLocFolder : string; // Local Task Folder
  SCUScanTaskLocRFile  : string; // Local Task R-file
  SCUScanTaskLocSFile  : string; // Local Task S-file
  SCUScanTaskLocUFile  : string; // Local Task U-file

  SCUScanLocCount      : Integer;
// Exchange Scans Folder  - K_FormCMScan.SCScanRootFolder
  SCUScanTaskFolder : string; // Exchange Task Folder
  SCUScanTaskRFile  : string; // Exchange Task R-file
  SCUScanTaskSFile  : string; // Exchange Task S-file
  SCUScanTaskSFileAge : TDateTime; // Exchange Task S-file Age
  SCUScanUploadCount: Integer;

  SCURFileCont, SCURFileLocCont, SCUSFileCont, SCUFilesList,
  SCUSFileLocCont, SCUDevicePlatesClientUse : TStringList;
  SCUT : TN_CPUTimer1; // Timer for measuring one time interval

  SCURFileContState : string;

  SCULogInd : Integer;
  SCULogFName : string;

  SCUTipInfo : string;

  SCUDumpBuffer : TStringList;

  SCUTerminatedInfo : string;
  SCUExceptionFlag : Boolean;

  SCUTWTaskFlag : Boolean;
  SCUAW1, SCUAW2, SCUAW3, SCUAW4, SCUAW5, SCUAW6, SCUAW7, SCUAW8, SCUAW9, SCUAW10 : WideString;

  procedure Execute(); override;

  procedure SCUAddUploadTask( const ATaskSfile : string );
  procedure SCUGetUploadTask( );

  procedure SCUAddRemoveTask( const ATaskSfile : string );
  procedure SCUGetRemoveTask( );

  procedure SCUChangeTrayTipInfo( );

  procedure SCUOnTerminate( Sender: TObject );

  procedure SCUDump0( ADumpStr : string );
  procedure SCUDump( ADumpStr : string );

  function  SCUCheckConnection() : Boolean;
  function  SCULoadTextFile( const AFileName : string;
                             AStrings : TStrings; ANotSkipError : Boolean = FALSE ) : Boolean;
  function  SCULoadLocTextFile( const AFileName : string;
                                AStrings : TStrings;
                                ANotSkipError : Boolean = FALSE ) : Boolean;
  function  SCUUpdateLocTextFile( const AFileName : string;
                                  AStrings : TStrings;
                                  ANotSkipError : Boolean = FALSE ) : Boolean;
  procedure SCUUpdateTaskRFile();
  function  SCUScanFilesTreeSelectFile( const APathName, AFileName: string ) : TK_ScanTreeResult;
  procedure SCURemoveTaskFiles( const ASFileName: string );
  procedure SCUploadTaskFiles( const ASFileName: string );
  function  SCUploadNewTaskFiles( ATaskWasFinished : Boolean  ) : Integer;
  function  SCUCheckCurTaskState( ) : Integer;

end; // type TK_SCUScanDataThread = class (TThread)

type  TK_SCScanState = (// Client Scanner State:
  K_SCSSUndef,         // -100 - undef state
  K_SCSSMoveToNewPath, // -1 - transp to new path
  K_SCSSWait,          //  0 - wait,
  K_SCSSSetup,         //  1 - setup,
  K_SCSSDoTask,        //  2 - do scan task
  K_SCSSFinTask        //  3 - finish scan task
);
type
  TK_FormCMScan = class(TN_BaseForm)
    ScanCaptToolBar: TToolBar;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton6: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Capture1: TMenuItem;
    SetupAdvanced1: TMenuItem;
    FootPedalSetup1: TMenuItem;
    N1: TMenuItem;
    Devices1: TMenuItem;
    Exit1: TMenuItem;
    StatusBar: TStatusBar;
    ActTimer: TTimer;
    BigIcons: TImageList;
    PopupMenu1: TPopupMenu;
    QuitMediaSuiteScanner1: TMenuItem;
    SetupMediaSuiteScanner1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    About2: TMenuItem;
    N2: TMenuItem;
    CreateCMScanexeDistributive1: TMenuItem;
    ChangeDataPath1: TMenuItem;
    ActionList1: TActionList;
    aPrevCaptResultsRecovery: TAction;
    PreviousCaptureResults1: TMenuItem;
    aExit: TAction;
    aChangeDataPath: TAction;
    aSetupMediaSuiteScanner: TAction;
    aOfflineMode: TAction;
    Offlinemode1: TMenuItem;
//    IdHTTPServer1: TIdHTTPServer; // for comp in D7
    aWEBSettings: TAction;
    WEBSettings1: TMenuItem;
    TimerWEBDav: TTimer;
    tiMain: TTrayIcon;
    eventsMain: TApplicationEvents;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ActTimerTimer(Sender: TObject);
    procedure QuitMediaSuiteScanner1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure aPrevCaptResultsRecoveryExecute(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure aChangeDataPathExecute(Sender: TObject);
    procedure aSetupMediaSuiteScannerExecute(Sender: TObject);
    procedure aOfflineModeExecute(Sender: TObject);
//    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
//      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
// for comp in D7
    procedure aWEBSettingsExecute(Sender: TObject);
    procedure WMPowerBroadcast(var Msg: TMessage); message WM_POWERBROADCAST;
    procedure TimerWEBDavTimer(Sender: TObject);
    procedure eventsMainMinimize(Sender: TObject);
    procedure tiMainDblClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure tiMainMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure eventsMainRestore(Sender: TObject);
  private
    { Private declarations }
    SCIniCaption : string;
//    SCInitTaskIsDone : Boolean; // =TRUE if Start Task Initialization is done
    SCScanTimerWaitCount : Integer;    // Timer Counter
    SCScanRedirectErrCount: Integer;   // Timer Counter
    SCScanPrevState : TK_SCScanState;  // Client Scanner Previouse State: -100 undefined, -1 - transp, 0 - wait, 1 - setup, 2 - do scan task
    SCScanChangePathState : TK_SCScanState;  // Client Scanner State before change path
    SCScanTaskID: string;            // Client Scanner State: WAIT, SETUP, DO <Scan_Task_ID>
    SCScanTaskDate : TDateTime;      // Client Scanner Task Last Date
    SCScanTaskErrCount : Integer;    // Client Scanner Task Err Count

    SCScanStateFile : string;
    SCScanRootFolder : string;
    SCScanRootFolderOld : string;
    SCScanLocalExchangeFolder : string;

    SCCloseByUser : Boolean;
    SCCloseByCMSVersion : Boolean;
    SCDataPathExists : Boolean;

    SCInfoFileDate : TDateTime;      // CMSuite Info File Last Date

    SCScanNewTaskNameFile : string;
    SCScanNewTaskNameFileDate : TDateTime; // CMSuite NewTask Name File Last Date
    SCScanNewTaskNameFileErrCount : Integer;// CMSuite NewTask Name File Err Count

    SCScanDataUploadThread : TK_SCUScanDataThread;
    SCScanDataVersion : Integer;
    SCScanShowBuildWarning : Boolean; // Already Show Build Warning (for single warning show)
    SCCMSScanDataPath : string;

    SCCheckNewTasksListTime : string;
    SCCheckScanDataPathTime : string;
    SCTimerAverageTime      : Double;
    SCTimerAverageCount     : Integer;

    SCTrayAddCaption        : string;

    SCIconMain : TIcon;
    SCIconAlt : TIcon;

    SCOfflineModeFlag : Boolean;

//    SCNetworkState : Integer; // 0 - OK, 1 - Slow, 2 - Very Slow
    SCNetworkSlowBaseCount : Integer; // SCScanTimerWaitCount value when Slow Network was detected
    SCNetworkSlowShift : Integer;  // Number of Timer Events between main actions
    SCNetworkSlowPeriod : Integer; // Number of Timer Events for all Events Loop
    SCNetworkDelay      : Integer; // Current Network delay in seconds

    procedure SCShowAccessWarninig();
    procedure SCShowScanDataVerWarninig( AShowWarning : Boolean );
    procedure SCShowHint         ( Sender : TObject );
    procedure SCShowString       ( AStr : string );

//    procedure SCForceDirPath( const AFolderPath : string );
    function  SCScanFilesTreeSelectFile( const APathName, AFileName: string; AScanLevel : Integer ) : TK_ScanTreeResult;
//    function  SCGetTaskRSFileName( const ASFileName : string; AChar : Char ) : string;
//    function  SCGetTaskFolderName( const ARSFileName : string ): string;
    function  SCLoadTextFile( const AFileName : string ) : Boolean;
    procedure SCCheckScanPathChange();
    procedure SCCheckNewTask();
    function  SCUpdateScanState() : Boolean;
    procedure SCClearScanTasks( AProcessTerminatedOnly : Boolean );
    procedure SCClearScanLocTasks();
    procedure SCGetScanTaskFilesList();
    procedure SCRemoveTask( const ASFileName : string );
    function  SCCheckTaskBrokenState( AUCheck : Boolean ) : Integer;
    procedure SCModifyTrayIconTip( const AInfo : string; ShowBalloon: Boolean = False; BalloonKind: TBalloonFlags = bfInfo);
    procedure SCClearScanRootFolderOld();
    function  SCSelectDataPathDlg( var ASelPath : string  ) : Boolean;
    function  SCCheckVersion () : Boolean;
    procedure SCCheckLocalExchangeFolder();
  public
    { Public declarations }
    SCTrayIconData: TNotifyIconData;
    SavedCursor: TCursor;
    FormMain5 : TForm;

    SCInfoStrings : TStringList;

    SCSL : TStringList;
    SCSTask : TStringList;
    SCRTask : TStringList;
    SCScanCount : Integer; // Scan Counter
    SCScanUpload1Count : Integer;// Scan Upload Counter  - Upload without Thread
    SCScanUpload2Count : Integer;// Scan Upload Counter Reflected in R-file - Upload without Thread
    SCScanState : TK_SCScanState; // Client Scanner State:
    // -1 - transp to new path
    //  0 - wait,
    //  1 - setup,
    //  2 - do scan task
    //  3 - finish scan task
    //  4 - scan task Upload Loop was interrupted - should be continued
    //  5 - scan task should be closed

    SCCaptureIsStarted : Boolean; // =TRUE if Capture was started: substate of SCScanState = K_SCSSDoTask

    SCScanRootLocFolder : string; // Local Scans Folder
    SCScanTaskLocFolder : string; // Local Task Folder
    SCScanTaskLocRFile  : string; // Local Task R-file
    SCScanTaskFolder : string;
    SCCMSScanTaskFolder : string;
    SCScanTaskRFile  : string;
    SCScanTaskSFile  : string;
    SCScanTaskSFilePrev  : string;
    SCScanTaskSFileEmpty : string;
    SCScanTaskSFileEmptyCount : Integer;
    SCTranspFileName : string;
    SCUpdatesExeFileName : string; //
    SCCurDataFileName    : string;

    SCCurTrayTipInfo   : string;
    SCNewTrayTipInfo   : string;

    SCUIHideBeforeCapt,
    SCUIStayOnTopSetup,
    SCUIStayOnTopCapt : Boolean;

    SCIUExeFileName : string;
    SCIUIsNotAvailable : Boolean;

    SCScanTaskPatName : string;      // Client Scanner Task Patient Name

    SCUHExceptionInProcess : Boolean;

    ///////////////////////
    // WEB context
    SCWEBMode : Boolean;
    SCWEBPortNumber : Integer;
    SCWEBWDDriveChar  : string;
    SCWEBWDHost     : string;
    SCWEBWDLogin    : string;
    SCWEBWDPassword : string;
    SCWEBWDCompID  : string;            //SIR#26380   SIR#26381
    SCWEBWDDateOut : string;            //SIR#26380   SIR#26381
    // WEB context
    ///////////////////////

    ////////////////////////////
    // Device Plates Use Context
    SCDevicePlatesTotalUse  : TStringList;
    SCDevicePlatesClientUse : TStringList;
    SCDevicePlatesTotalCount, SCDevicePlatesClientCount,
    SCDevicePlatesClientInd : Integer;
    SCDevicePlateCurID : string;
    // Device Plates Use Context
    ////////////////////////////

    SCTWTaskFlag : Boolean;


    procedure OnUHException    ( Sender: TObject; E: Exception );
    procedure SCScanDataPathIniSet();
    procedure SCInitScanPathsContext();
    function  SCGetInfoFile( AReadIfUpdated : Boolean ) : Integer;
    function  SCCheckCMScanUpdates() : Boolean;
    function  SCUpdateTextFile( AStrings : TStrings; const AFileName : string ): string;
    procedure SCUpdateTaskLocFile( const ALockTaskFile : string;
                                   ALocTaskStrings : TStrings );
    procedure SCUpdateTaskLocRFile();
    function  SCCopyTaskScanFiles() : Boolean;
    procedure SCRemoveTaskLocFolder( AUnconditionalRemove : Boolean = FALSE );
    function  SCSetTaskIsDoneState( ASLidesCount : Integer ) : Boolean;
    procedure SCShowNotReadyMessage();
    function  SCConfirmApplicationTerm( const AMessage : string ) : Boolean;
    procedure SCDumpTaskState( const AMessage : string; ATaskState : Integer );

    ///////////////////////
    // WEB context API
    procedure SCWEBMemIniToCurState();
    procedure SCWEBCurStateToMemIni();
    procedure SCWEBInit();
    function  SCWEBInitDiskZ(): Int64;
    // WEB context API
    ///////////////////////

    procedure SCScanCurSave();
    /////////////////////////
    // Device Plates Use API
    procedure SCDevicePlatesInfoFromMemIni();
    procedure SCDevicePlatesInfoToMemIni();
    procedure SCDevicePlatesInfoToUpload();
    procedure SCDevicePlateResCountGet( const APlateName : string );
    function  SCDevicePlateCurCountGet( const APlateName : string ) : Integer;
    procedure SCDevicePlateCountsGet( const APlateName : string );
    procedure SCDevicePlateCurCountInc( const APlateName : string );
    // Device Plates Use API
    /////////////////////////

  end;

//********************************************************* TK_CMEDCSAccess ***
// External Data Client Scanner Access Class
//
type TK_CMEDCSAccess = class (TK_CMEDAccess)
  UploadWithOneSLideGap : Boolean;
  FullStayOnTop : Boolean;
  function  EDAInit() : TK_CMEDResult; override;
  function  EDAGetAllMediaTypes0 ( ): TStrings; override;
  function  EDASaveContextsData( ASaveFlags : TK_CMEDSaveStateFlags = [] ) : TK_CMEDResult; override;
  function  EDAGetPatientMacroInfo( ADataID : Integer = -1; AInfo : TStrings = nil;
                                AAddToValues : Boolean = false ) : TStrings; override;
  procedure EDASetSlideMediaFileTMPName( ASlide: TN_UDCMSlide; const AMediaFExt: string ); override;
  function  EDAGetMediaFileClientName( ASlide: TN_UDCMSlide ) : string; override;
  function  EDAStartCapture( ACMScanCaptureFlags : TK_CMScanCaptureFlags;
                             APCurDevProfile: TK_PCMDeviceProfile ) : Boolean; override;
  procedure EDAAddSlide( ASlide : TN_UDBase; ASkipECache : Boolean = FALSE;
                         ASlidesCount : Integer = 0 ); override;
  procedure EDAFinCapture(); override;

//*********************************************************************
// Emergency Cache Routines
  procedure EDASaveSlideToECache( AUDSlide: TN_UDCMSlide ); override;
  procedure EDAClearSlideECache( AUDSlide: TN_UDCMSlide ); override;

//*********************************************************************
// Device Plates Routines
  function  EDADevicePlateUseCountGet( const APlateName : string ) : Integer; override;
  function  EDADevicePlateUseCountInc( const APlateName : string ) : Integer; override;
end;
//*** end of CMS External Data Access

var
  K_FormCMScan: TK_FormCMScan;


function  K_SCGetTaskFolderName( const ARSFileName : string ): string;
function  K_SCGetTaskRSFileName( const ASFileName : string; AChar : Char ) : string;
procedure K_CMScanSelfUpdate();
procedure K_CMScanInit();

implementation

{$R *.dfm}

uses SyncObjs, Math, WinSvc,
  K_CLib0, K_CLib, K_UDT2, K_UDC, K_UDConst, K_Arch, K_FCMMain5F,
  K_STBuf, K_Script1, K_CML1F, K_FPathNameFr, K_CM1, K_FCMScanSetPatData,
  K_FCMScanSelectMedia, K_CMCaptDevReg, K_RImage, K_FCMScanWEBSettings,
  N_Types, N_Lib1, N_ME1, N_CMResF, N_CM1, N_Comp1,
  N_CML2F, N_CMMain5F, N_CM2, N_EdParF, N_CMFPedalSF,
  K_FCMGAdmEnter, K_CMDCMGLibW, K_CMDCM,                                                                //SIR #25997
  L_VirtUI;                                                                       //SIR #26380
var
  K_SCLocalFilesStorageThreshold : Double = 14; // number of day to leave files in local storage
//  K_SCLocalFilesStorageThreshold : Double = 0.004; // number of day to leave files in local storage
//  K_SCLocalFilesStorageThreshold : Double = 0; // number of day to leave files in local storage
  K_SCPatDefSurname : string;
  K_SCPatDefFirstname : string;

// Regional Settings
  K_SCRegSuiteProductName : string;
  K_SCRegCompanyDistrName : string;
  K_SCRegEmail : string;
  K_SCRegPhone : string;
  L_InSleep: Boolean = false;        ////Igor 23062020
  L_CountWebDav: Integer;            ////Igor 11092020

////Igor 23032020
{// for comp in D7
function EventRegister(var WebClntGUID: TGUID; EnableCallback: PVOID; CallbackContext: PVOID; var RegHandle: Int64): Long; stdcall; external 'Advapi32.dll';
function EventWrite(RegHandle: Int64; EventDescriptor: PCEVENT_DESCRIPTOR; UserDataCount: ULong; UserData: PEVENT_DATA_DESCRIPTOR): Long; stdcall; external 'Advapi32.dll';
function EventUnregister(var RegHandle: Int64): Long; stdcall; external 'Advapi32.dll';

function ServiceGetStatus(sService: string ): Integer;
var
  theService, scm: SC_Handle;
  m_SERVICE_STATUS: TServiceStatus;
begin
  Result := 1;
  scm := OpenSCManager(nil ,nil, SC_MANAGER_ENUMERATE_SERVICE);
  if scm > 0 then
  begin
    theService := OpenServiceW(scm, PChar(sService), SERVICE_QUERY_STATUS);
    if theService > 0 then
    begin
      if(QueryServiceStatus(theService, m_SERVICE_STATUS)) then
			Result := m_SERVICE_STATUS.dwCurrentState;
      CloseServiceHandle(theService);
    end;
    CloseServiceHandle(scm);
  end;
end;

function StartWebClientService: Boolean;
var
  WebClntGUID: TGUID;
  RegHandle: Int64;
  desc: EVENT_DESCRIPTOR;
begin
  Result := False;
}
//  WebClntGUID := StringToGUID('{22B6D684-FA63-4578-87C9-EFFCBE6643C7}');
{
  if EventRegister(WebClntGUID, nil, nil, RegHandle) = ERROR_SUCCESS then
  begin
	  //EventDescCreate(&desc,1,0,0,4,0,0,0);
    desc.Id := 1;
    desc.Version := 0;
    desc.Channel := 0;
    desc.Level := 4;
    desc.Opcode := 0;
    desc.Task := 0;
    desc.Keyword := 0;

    Result := EventWrite(RegHandle, @desc, 0, nil) = ERROR_SUCCESS;
    EventUnregister(RegHandle);
  end;

end;
////Igor 23032020
}

//*************************************************** K_SCGetTaskFolderName ***
// Get Task Folder name by given by S-file or R-file
//
//    Parameters
//  ASFileName - task S-file or R-file name
//  Result - Returns Task Folder Name
//
function K_SCGetTaskFolderName( const ARSFileName : string ): string;
var
  Ind : Integer;
begin
  Ind := Length(ARSFileName) - 3;
  Result := Copy( ARSFileName, 1, Ind );
  Result[Ind - 16] := 'F';
  Result[Ind] := '\';
end; // function K_SCGetTaskFolderName

//*************************************************** K_SCGetTaskRSFileName ***
// Get Task R-file by Task S-file
//
//    Parameters
//  ASFileName - Task S-file name
//  Result - Returns Task R-file name
//
function K_SCGetTaskRSFileName( const ASFileName : string; AChar : Char ) : string;
begin
  Result := ASFileName;
  Result[Length(ASFileName) - 19] := AChar; // Syymmddhhnnsszzz.txt >> Ryymmddhhnnsszzz.txt
end; // function K_SCGetTaskRSFileName

//****************************************************** K_CMScanSelfUpdate ***
// CMScan Self Update
//
procedure K_CMScanSelfUpdate();
var
  BasePath : string;
  DeleteErrorsFlag : Boolean;

  WaitCount : Integer;
  WaitName : string;
  ErrStr : string;

label ReturnToOld, ReturnToOld1;
begin
  N_Dump1Str( '*!*!* CMScan Self Update is started' );
  WaitName := ExtractFileName(Application.ExeName);
  WaitCount := 0;
  while TRUE do
  begin
    if K_CheckProcess( WaitName, GetCurrentProcessID() ) = -1 then Break;
    if WaitCount > 30 then
    begin
      K_CMShowMessageDlg( 'Media Suite Scanner update problem. Application ' + WaitName + ' is still running.', mtError );
      Exit;
    end;
    N_Dump1Str( '*!*!* CMScan wait for old EXE closing sec=' + IntToStr(WaitCount) );
    Inc(WaitCount);

    sleep(1000);
  end;

  BasePath := ExtractFilePath(
                    ExcludeTrailingPathDelimiter(
                             ExtractFilePath(Application.ExeName)));

  if not K_CopyFolderFiles( BasePath + 'BinFiles\', BasePath + 'OldBinFiles\' ) then
  begin
    K_CMShowMessageDlg( 'Media Suite Scanner update problem. Save old version files error.', mtError );
    Exit;
  end
  else
    N_Dump1Str( '*!*!* CMScan BinFiles are saved to OldBinFiles' );

  K_UnDeletedFileNames := TStringList.Create;
  K_DeleteFolderFiles( BasePath + 'BinFiles\', '*.*',
                       [K_dffRecurseSubfolders,K_dffRemoveReadOnly] ); // Clear place for updates
  DeleteErrorsFlag := K_UnDeletedFileNames.Count > 0;
  FreeAndNil(K_UnDeletedFileNames);

  if DeleteErrorsFlag then
  begin
    K_CMShowMessageDlg( 'Media Suite Scanner update problem. Clear old version files error.', mtError );

ReturnToOld:
    K_CopyFolderFiles( BasePath + 'OldBinFiles\', BasePath + 'BinFiles\' );
    sleep( 100 ); // wait for copy fin
    N_Dump1Str( '*!*!* CMScan return OldBinFiles to BinFiles' );
//    if not K_RunExeByCmdl( BasePath + 'BinFiles\CMScan.exe /ScanSkipSelfCheck' ) then
//      N_Dump1Str( '*!*!* CMScan old launch error >> ' + SysErrorMessage( GetLastError() ) );
    ErrStr := K_RunExe( BasePath + 'BinFiles\CMScan.exe', '/ScanSkipSelfCheck' );
    if ErrStr <> '' then
      N_Dump1Str( '*!*!* CMScan old launch error >> ' + ErrStr );
    Exit;
  end;
  N_Dump1Str( '*!*!* CMScan BinFiles are deleted' );


  if not K_CopyFolderFiles( BasePath + 'NewBinFiles\', BasePath + 'BinFiles\', '*.*',
                            [K_cffOverwriteNewer, K_cffOverwriteReadOnly] ) then
  begin
    K_CMShowMessageDlg( 'Media Suite Scanner update problem. Copy new version files error.', mtError );
ReturnToOld1:
    K_DeleteFolderFiles( BasePath + 'BinFiles\', '*.*',
                       [K_dffRecurseSubfolders,K_dffRemoveReadOnly] ); // Clear place for updates
    N_Dump1Str( '*!*!* CMScan BinFiles are cleared' );
    goto ReturnToOld;
  end
  else
    N_Dump1Str( '*!*!* CMScan NewBinFiles are copied to BinFiles' );

  sleep( 100 ); // wait for copy fin
  ErrStr := K_RunExe(BasePath + 'BinFiles\CMScan.exe', '/ScanSkipSelfCheck' );
  if ErrStr <> '' then
//  if not K_RunExeByCmdl( BasePath + 'BinFiles\CMScan.exe /ScanSkipSelfCheck' ) then
  begin
    N_Dump1Str( '*!*!* Launch new version error >> ' + ErrStr );
    K_CMShowMessageDlg( 'Media Suite Scanner update problem. Launch new version error', mtError );
    goto ReturnToOld1;
  end
  else
    N_Dump1Str( '*!*!* CMScan updated EXE is lanched with /ScanSkipSelfCheck' );

  K_UnDeletedFileNames := TStringList.Create;
  K_DeleteFolderFiles( BasePath + 'OldBinFiles\', '*.*',
                       [K_dffRecurseSubfolders,K_dffRemoveReadOnly] ); // Clear place for updates
  DeleteErrorsFlag := K_UnDeletedFileNames.Count > 0;
  FreeAndNil(K_UnDeletedFileNames);
  if DeleteErrorsFlag then
    K_CMShowMessageDlg( 'Media Suite Scanner update problem. Clear saved old version files error.', mtError )
  else
  if RemoveDir( BasePath + 'OldBinFiles' ) then
    N_Dump1Str( '*!*!* CMScan OldBinFiles are removed' )
  else
    N_Dump1Str( '*!*!* CMScan OldBinFiles remove error' );

end; //procedure K_CMScanSelfUpdate();

function WSDLSendImageTo( const APW1, APW2, APW3, APW4, APW5, APW6, APW7, APW8, APW9, APW10, APW11, APW12, APW13, APW14, APW15 : Pointer; AUI : TN_UInt4; APV1, APV2 : Pointer ) : Integer; cdecl;
begin
  with K_FormCMScan.SCScanDataUploadThread do
  begin
    SCUDump(format( 'SCU SendImageTo >> 1=%s 2=%s 3=%s', [PWideChar(APW1),PWideChar(APW2),PWideChar(APW3)] ) );
    SCUDump(format( 'SCU SendImageTo >> 4=%s 5=%s 6=%s', [PWideChar(APW4),PWideChar(APW5),PWideChar(APW6)] ) );
    SCUDump(format( 'SCU SendImageTo >> 7=%s 8=%s 9=%s', [PWideChar(APW7),PWideChar(APW8),PWideChar(APW9)] ) );
    SCUDump(format( 'SCU SendImageTo >> 10=%s 11=%s 12=%s', [PWideChar(APW10),PWideChar(APW11),PWideChar(APW12)] ) );
    SCUDump(format( 'SCU SendImageTo >> 13=%s 14=%s 15=%s BS=%d', [PWideChar(APW13),PWideChar(APW14),PWideChar(APW15),AUI] ) );
{
  N_Dump1Str(format( '1=%s 2=%s 3=%s', [PWideChar(APW1),PWideChar(APW2),PWideChar(APW3)] ) );
  N_Dump1Str(format( '4=%s 5=%s 6=%s', [PWideChar(APW4),PWideChar(APW5),PWideChar(APW6)] ) );
  N_Dump1Str(format( '7=%s 8=%s 9=%s', [PWideChar(APW7),PWideChar(APW8),PWideChar(APW9)] ) );
  N_Dump1Str(format( '10=%s 11=%s 12=%s', [PWideChar(APW10),PWideChar(APW11),PWideChar(APW12)] ) );
  N_Dump1Str(format( '13=%s 14=%s 15=%s BS=%d', [PWideChar(APW13),PWideChar(APW14),PWideChar(APW15),AUI] ) );
}
    Result := 0;
  end;
end;

//************************************************************ K_CMScanInit ***
// CMScan Launch procedure
//
procedure K_CMScanInit();
var
  WStr{, WStr1, WStr2} : string;
  i : Integer;
  VFile: TK_VFile;
  Stream : TStream;
//  PatientName
  PNL,PSL : TStringList;
  PatSurname, PatFirstname, PatMiddle, PatTitle, PatDOB, TaskFileName, WEBTaskFileName : string;
  CMScanIsRunning : Boolean;
  ResCopyWEBTask : Integer;

Label LExit;

begin
  N_Dump1Str( 'CMScan Build ' + N_CMSVersion + ' from ' + N_CMSReleaseDate );
  with K_FormCMScan do
  begin
    tiMain.Visible := False;

    SCScanState := K_SCSSMoveToNewPath;
    SCModifyTrayIconTip( Caption + #13#10 + 'Initializing, pease wait!');

    SCUpdatesExeFileName := ExtractFileName(Application.ExeName);
    CMScanIsRunning := K_CheckProcess( SCUpdatesExeFileName, GetCurrentProcessID() ) >= 0;
    WEBTaskFileName := '';

    WStr := ParamStr(1);
    if K_StrStartsWith( 'cmsscan:', WStr ) then
    begin
      WStr := Copy( WStr, 9, Length( WStr ) );
      WStr := StringReplace( WStr, '%20', ' ', [rfReplaceAll] );
      WStr := StringReplace( WStr, '%5E', '^', [rfReplaceAll] );
      N_Dump1Str( 'CMScan CMDLine params >> ' + WStr );

      // Pars All params
      PSL := TStringList.Create();
      PSL.Delimiter := '&';
      PSL.DelimitedText := WStr;
      // Parse PatientName
      PNL := TStringList.Create();
      PNL.Delimiter := '^';
      PNL.DelimitedText := PSL.Values['patientName'];
      if PNL.Count > 0 then
        PatSurname := PNL[0];
      if PNL.Count > 1 then
        PatFirstname := PNL[1];
      if PNL.Count > 2 then
        PatMiddle := PNL[2];
      if PNL.Count > 3 then
        PatTitle := PNL[3];

      PNL.Clear;

      // Create Task File. Fill Task
      PatDOB := PSL.Values['patientBirthDate'];
      PatDOB := DateToStr( K_StrToDateTime( Copy(PatDOB,1,4)+'-'+Copy(PatDOB,5,2)+'-'+ Copy(PatDOB,7,2)), N_WinFormatSettings );
      PNL.Text := format(
        'IsTerm=FALSE'#13#10'CurPatID=-101'#13#10'CurProvID=-101'#13#10'CurLocID=-101'#13#10 +
        'ServCompName=%s'#13#10'PatientTitle=%s'#13#10'PatientGender=%s'#13#10'PatientCardNumber=%s'#13#10 +
        'PatientSurname=%s'#13#10'PatientFirstName=%s'#13#10'PatientMiddle=%s'#13#10'PatientDOB=%s'#13#10,
        [K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName,
         PatTitle,PSL.Values['patientSex'][1], PSL.Values['patientId'], PatSurname,
         PatFirstname, PatMiddle, PatDOB ] );

      // Add WebAttrs
      PNL.Add(#13#10'[WebAttrs]');
      PNL.AddStrings( PSL );

      // Init Path Context
      SCScanRootFolder :=  IncludeTrailingPathDelimiter(
                                K_OptimizePath( K_ExpandFileName( '(#BasePath#)Exchange\' ) ) ) +
                                K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName + '\';
      K_ForceFilePath( SCScanRootFolder );
{
      K_CMScanDataPath := N_MemIniToString( 'CMS_Main', 'ScanDataPath', '' );
      if K_CMScanDataPath = '' then
        SCScanDataPathIniSet();
      SCInitScanPathsContext();
}
      // Save Task File
      if CMScanIsRunning then
      begin
        TaskFileName := 'S' + K_DateTimeToStr( Now(), 'yymmddhhnnsszzz' ) + '.txt';
        PSL.Text := TaskFileName;
        TaskFileName := SCScanRootFolder + TaskFileName;

        N_Dump1Str( 'cmsscan: Task ' + SCUpdateTextFile( PNL, TaskFileName ) );
        N_Dump1Str( 'cmsscan: TaskName ' + SCUpdateTextFile( PSL, SCScanRootFolder + K_CMScanCurTaskInfoFileName ) );
      end
      else
      begin
        WEBTaskFileName := SCScanRootFolder + K_CMScanWEBTaskFileName;
        N_Dump1Str( 'cmsscan: Task to WEB ' + SCUpdateTextFile( PNL, WEBTaskFileName ) );
      end;

      PNL.Free;
      PSL.Free;
{
patientId - patient id
token - user login information
patientName - full patient name
patientBirthDay - date of patient birth
patientSex - patient's gender
studyUid - study instance UID
referringPhysician - referring physician name
locationId - hospital/location id
uidPrefix - unique value to genearate UIDs

}
      // Check if CMScan is running
      if CMScanIsRunning then
      begin
        N_Dump1Str( '!!! CMScan is already running' );
        goto LExit;
      end;

    end  // if K_StrStartsWith( 'cmsscan:', WStr )
    else
    if (WStr <> '/ScanSkipSelfCheck') and CMScanIsRunning then
    begin
      K_CMShowMessageDlg( 'Application ' + Application.ExeName + ' is already running',
                           mtWarning );
LExit:
      Release();
      K_FormCMScan := nil;
      Exit;
//      raise Exception.Create( 'Application "' + Application.ExeName + '" is already running' );
    end;

    K_CMEDAExtIniFilesToMemIni( FALSE );

/////////////////////////////////////////
//  Initialise WEB UI visibility needed
    aWEBSettings.Visible := N_MemIniToBool( 'CMS_Main', 'CMScanWEBUIVisible', FALSE );
//  Initialise WEB UI visibility
/////////////////////////////////////////

/////////////////////////////////////////
//  Initialise WEB Context
    if aWEBSettings.Visible then
    begin
      SCWEBMode := N_MemIniToBool( 'ScanWEBSettings', 'WEBMode', FALSE );
      SCWEBMemIniToCurState();
      SCWEBInit();
      TimerWEBDav.Enabled := true;
    end
    else
      SCWEBMode := FALSE;
//  Initialise WEB Context
/////////////////////////////////////////

/////////////////////////////////////////
//  Initialise Device Plate Use Client Context
    SCDevicePlatesTotalUse  := TStringList.Create;
    SCDevicePlatesClientUse := TStringList.Create;
    SCDevicePlatesInfoFromMemIni();
//  Initialise Device Plate Use Client Context
/////////////////////////////////////////

    K_CMMessageDlgDefaultCaption := N_MemIniToString( 'RegionTexts', 'CMScanProductName', 'MediaSiute Scanner' );
    // Customize Application UI by CMScanProductName

    // MainMenu and Application Title
    Caption := K_CMMessageDlgDefaultCaption;
    SCIniCaption := Caption;
    Application.Title := K_CMMessageDlgDefaultCaption;

    // Menu Items
    QuitMediaSuiteScanner1.Caption := 'Quit ' + K_CMMessageDlgDefaultCaption;
    SetupMediaSuiteScanner1.Caption := 'Setup ' + K_CMMessageDlgDefaultCaption + ' ...';
    About1.Caption := 'About ' + K_CMMessageDlgDefaultCaption + ' ...';
    About2.Caption := 'About ' + K_CMMessageDlgDefaultCaption + ' ...';

    K_SCRegSuiteProductName := N_MemIniToString( 'RegionTexts', 'CMSuiteProductName', 'MediaSiute' );
    K_SCRegCompanyDistrName := N_MemIniToString( 'RegionTexts', 'CompanyDistrName', 'Centaur Software Development Company' );
    K_SCRegEmail := N_MemIniToString( 'RegionTexts', 'Email', 'techsupport@centaursoftware.com' );
    K_SCRegPhone := N_MemIniToString( 'RegionTexts', 'Phone', '+61-2-9213-5000' );

    // Get Hide/StayOnTop UI modes
    SCUIHideBeforeCapt := N_MemIniToBool( 'CMS_UserDeb', 'ScanUIHideBeforeCapt', TRUE );
    SCUIStayOnTopSetup := N_MemIniToBool( 'CMS_UserDeb', 'ScanUIStayOnTopSetup', TRUE );
    SCUIStayOnTopCapt  := N_MemIniToBool( 'CMS_UserDeb', 'ScanUIStayOnTopCapt', TRUE );


    SCCheckLocalExchangeFolder( );

    if SCUIStayOnTopSetup and SCUIStayOnTopCapt then
    begin
      SCUIStayOnTopSetup  := FALSE;
      SCUIStayOnTopCapt   := FALSE;
      N_BaseFormStayOnTop := 2;
    end;

    N_Dump1Str( format( 'SC> TopAll=%d TopSetup=%s TopCapt=%s Hide=%s',
                        [N_BaseFormStayOnTop,
                         N_B2S(SCUIStayOnTopSetup),
                         N_B2S(SCUIStayOnTopCapt),
                         N_B2S(SCUIHideBeforeCapt)] ) );



    K_CMScanDataPath := N_MemIniToString( 'CMS_Main', 'ScanDataPath', '' );
    K_CMScanDataPathOld := N_MemIniToString( 'CMS_Main', 'ScanDataPathOld', '' );
    if K_CMScanDataPathOld <> '' then
      SCScanRootFolderOld := K_CMScanDataPathOld + K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName + '\';


    N_CM_IDEMode := N_MemIniToInt( 'CMS_Main', 'IDEMode', 0 );

    // Check ScanDataPath
    if K_CMScanDataPath = '' then
      SCScanDataPathIniSet();

{// This code is not needed now - self designed auto update
    // Prepare Updates Check
    if SCCheckCMScanUpdates() then goto LExit;
{}
    SCInitScanPathsContext();

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;

    N_InitWAR(); // Initialize N_WholeWAR and N_AppWAR using [Global]ScreenWorkArea in Ini file
    if N_MonWARsChanged() then N_ClearSavedFormCoords(); // clear N_Forms section if needed

    N_AddDirToPATHVar( K_ExpandFileName( '(#DLLFiles#)' ) );

    BaseFormInit( nil, '', [rspfPrimMonWAR,rspfCenter], [rspfPrimMonWAR,rspfCenter] );

    Application.OnHint      := SCShowHint;
    Application.CreateForm( TN_CMMain5Form1, N_CM_MainForm);


    N_CM_MainForm.CMMCurFStatusBar  := StatusBar;
    N_CM_MainForm.CMMCurCaptToolBar := ScanCaptToolBar;
    N_CM_MainForm.CMMCurMainMenu    := MainMenu1;
    N_CM_MainForm.CMMCurFMainForm   := K_FormCMScan;

    FormMain5 := TK_FormCMMain5.Create(Application);
    with TK_FormCMMain5(FormMain5) do
    begin
//      ScanCaptToolBar.Images := MainIcons44;
//      N_CM_MainForm.CMMCurBigIcons := MainIcons44;
      BigIcons.Assign(MainIcons44);
      ScanCaptToolBar.Images := BigIcons;
      N_CM_MainForm.CMMCurBigIcons := BigIcons;
      N_CMResForm.MainIcons18.Assign( MainIcons18 );
      N_CM_MainForm.CMMCurMainMenu.Images := N_CMResForm.MainIcons18;
      K_CMDynIconsSInd := N_CMResForm.MainIcons18.Count;
      Release();
    end;

    K_SetFFCompCurLangTexts( N_CMResForm );

    Application.CreateForm(TK_CML1Form, K_CML1Form);
    K_SetFFCompCurLangTexts( K_CML1Form );
    K_PrepLLLCompTexts( K_CML1Form );

    Application.CreateForm(TN_CML2Form, N_CML2Form);
    K_SetFFCompCurLangTexts( N_CML2Form );
    K_PrepLLLCompTexts( N_CML2Form );

    WStr := N_MemIniToString( 'CMS_Main', 'StartArchive', '');
    WStr := K_ExpandFileName( WStr );
    if not K_OpenCurArchive( WStr ) then
    begin
      K_CMShowMessageDlg( //sysout
        'Fail to load archive ' + WStr, mtError );
      goto LExit;
    end;
    K_InitAppArchProc := nil;
    K_InitArchiveGCont( K_CurArchive ); // create all needed objects in K_CurArchive
    N_InitVREArchive( K_CurArchive ); // VRE specific initialization
    N_InitCMSArchive( K_CurArchive ); // CMS specific initialization

    N_FPCBObj.FPCBInitDU();

    K_CMSharpenMax := N_MemIniToDbl( 'CMS_Main', 'SharpenMax', 1.0 );

    // Init Cur Data Arch File Name
    SCCurDataFileName := N_MemIniToString( 'CMS_Main', 'ScanCurDataArch', '');
    if SCCurDataFileName = '' then
    begin
      K_CMShowMessageDlg( 'Media Suite Scanner installation error', mtError );
      goto LExit;
    end
    else
      SCCurDataFileName := K_ExpandFileName( SCCurDataFileName );

    // Initialise Data Access
    K_CMEDAccess := TK_CMEDCSAccess.Create;
    with K_CMEDAccess do
    begin

      if EDAInit() <> K_edOK  then
      begin
        K_CMShowMessageDlg( 'Media Suite Scanner initialization error', mtError );
        goto LExit;
      end;

      // Remove All Slides - precaution: because
      if ArchSlidesRoot <> nil then
      begin
        for i := 0 to ArchSlidesRoot.DirHigh() do
          DelSlidesList.Add(ArchSlidesRoot.DirChild(i));
        EDAClearDeletedSlides( FALSE );
      end;

      EDAGlobalMemIniToCurState();
//      EDAInstanceMemIniToCurState();

    end; // with K_CMEDAccess do

    K_CMSRebuildCommonRImage();

    N_CM_MainForm.CMMUpdateUIMenuItemName := 'Devices1';
    N_CM_MainForm.CMMUpdateUIMenuItemInd1 := 0; // Set UIDevice Update parameter for CMSuite
    N_CM_MainForm.CMMUpdateUIByDeviceProfiles();
    Include( N_CM_MainForm.CMMUICurStateFlags, uicsSkipActiveSlideEdit );
//    K_CMUpdateUIByDeviceProfiles0( MainMenu1.Items[2], 0, -1 );


    SCSTask := TStringList.Create;
    SCRTask := TStringList.Create;

    Screen.Cursor := SavedCursor;
    SCScanPrevState := K_SCSSUndef;
    N_Dump1Str( 'SC> Start' );
    SCTranspFileName := K_CMScanDataPath + K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName + '.~';
    SCScanRootLocFolder := K_ExpandFileName( '(#WrkFiles#)ScanData\' );
    About1.OnClick := N_CMResForm.aHelpAboutExecute;
    About2.OnClick := N_CMResForm.aHelpAboutExecute;

    K_SCLocalFilesStorageThreshold := N_MemIniToInt( 'CMS_UserMain', 'LocalStoragePeriod', Round(K_SCLocalFilesStorageThreshold) );

    SCClearScanLocTasks( );

    // Launch Upload Thread
    SCScanDataUploadThread := TK_SCUScanDataThread.Create(TRUE);
    SCScanDataUploadThread.FreeOnTerminate := TRUE;
    SCScanDataUploadThread.SCULogFName :=
      ChangeFileExt(N_LogChannels[N_Dump1LCInd].LCFullFName, 'SCU.txt' );
    SCScanDataUploadThread.Suspended := FALSE;

    // DT15723 - Check CMScan and CMSuite versions matching by InfoFile
    SCDataPathExists := TRUE;
    if not SCCheckVersion() then goto LExit;

    SCModifyTrayIconTip( SCIniCaption );
    tiMain.Visible := True;

//    SCScanState := K_SCSSWait;
//    SCDataPathExists := TRUE;

    WStr := N_MemIniToString( 'CMS_Main', 'ScanIconAltFName', '' );
    N_Dump2Str( 'SC> AltIcon FName=' + WStr );
    if WStr <> '' then
    begin
      K_VFAssignByPath( VFile, K_ExpandFileName(WStr) );
      if K_VFOpen( VFile ) > 0 then
      begin
        Stream := K_VFStreamGetToRead( VFile );
        SCIconAlt := TIcon.Create();
        SCIconAlt.LoadFromStream(Stream);

        SCIconMain := TIcon.Create();
        SCIconMain.Assign( Application.Icon );
        N_Dump2Str( 'SC> AltIcon is set' );
      end;
      K_VFStreamFree(VFile);
    end
    else
    begin
      SCIconMain := TIcon.Create();
      SCIconMain.Assign( Application.Icon );

      SCIconAlt := TIcon.Create();
      SCIconAlt.Assign( Application.Icon );
    end;

    SCScanState := K_SCSSWait;
    ActTimerTimer( nil );
    if WEBTaskFileName <> '' then
    begin
      TaskFileName := 'S' + K_DateTimeToStr( Now(), 'yymmddhhnnsszzz' ) + '.txt';
      K_CMEDAccess.TmpStrings.Text := TaskFileName;
      TaskFileName := SCScanRootFolder + TaskFileName;
      ResCopyWEBTask := K_CopyFile( WEBTaskFileName, TaskFileName );
      WStr := format( '%s >> %s', [WEBTaskFileName, TaskFileName] );
      if ResCopyWEBTask <> 0 then
        N_Dump1Str( format( 'cmsscan: Task Copy Error=%d %s', [ResCopyWEBTask, WStr] ) )
      else
        N_Dump2Str( 'cmsscan: Task Copy ' + WStr );
      N_Dump1Str( 'cmsscan: TaskName ' + SCUpdateTextFile( K_CMEDAccess.TmpStrings, SCScanRootFolder + K_CMScanCurTaskInfoFileName ) );
      K_DeleteFile( WEBTaskFileName );
    end;
  end; // with K_FormCMScan do
end; // procedure K_CMScanInit();

{*** TK_FormCMScan ***}

procedure TK_FormCMScan.WMPowerBroadcast(var Msg: TMessage);
//var
//  WebDAV: TNetResource;
begin
  case Msg.wParam of
    PBT_APMSUSPEND:           // IN Sleep  mode
      begin
        N_Dump1Str('IN Sleep!!!');
        L_InSleep := true;
        WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), 0, TRUE);
      end;
    PBT_APMRESUMESUSPEND:     // Exit Sleep User Action
      begin
        N_Dump1Str('Exit Sleep User Action !!!');
        if L_InSleep then
        begin
          L_InSleep := false;
          SCWEBInit();
          TimerWEBDav.Enabled := true;
        end;
      end;
    {
    PBT_APMRESUMEAUTOMATIC:  // Exit Sleep automatic
      begin
        N_Dump1Str('Exit Sleep Automatic !!!');
        if L_InSleep then
        begin
          L_InSleep := false;
          SCWEBInit();
        end;
      end;
      }
  end;
end; // procedure TK_FormCMScan.WMPowerBroadcast

//********************************************** TK_FormCMScan.aExitExecute ***
// aExit Event Handler
//
procedure TK_FormCMScan.aExitExecute(Sender: TObject);
begin
//WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), 0, TRUE);
  Close();
end; // end of procedure TK_FormCMScan.aExitExecute

//******************************************** TK_FormCMScan.FormCloseQuery ***
// Form Close Query Event Handler
//
procedure TK_FormCMScan.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
var
  Res, i : Integer;
  UpdateRFileInfo : string;
begin
  N_Dump1Str( 'SC> Form Close' );

  CanClose := SCCloseByUser       or
              SCCloseByCMSVersion or
              (N_KeyIsDown(VK_SHIFT) and N_KeyIsDown(VK_CONTROL));

  if CanClose then
  begin
    tiMain.Visible := False;

    if (SCScanDataUploadThread <> nil) and
       (Integer(SCScanDataUploadThread) <> -1) then
      SCScanDataUploadThread.Terminate();

    CurStateToMemIni();
    K_CMD4WAppFinState := TRUE;
    K_CMEDAccess.Free;
//    FormMain5.Release();
    SCSL.Free;
    SCSTask.Free;
    SCRTask.Free;
    SCInfoStrings.Free;

    SCDevicePlatesInfoToMemIni();

    SCDevicePlatesTotalUse.Free;
    SCDevicePlatesClientUse.Free;

    N_StringToMemIni( 'N_Forms', 'AllMonWARs', N_GetMonWARsAsString() ); // save monitors WARs

    if aWEBSettings.Visible then
      SCWEBCurStateToMemIni();

    K_CMEDAMemIniToExtIniFiles();

    // Remove State file while Application close
    if K_CMScanDataPath <> '' then
      K_DeleteFile( SCScanStateFile );

    if K_CMCaptDevsList <> nil then
    begin
      for i := 0 to K_CMCaptDevsList.Count - 1 do
      begin
        N_Dump2Str( format( 'CMCDServObj Free Start Name=%s',
                            [TK_CMCDServObj(K_CMCaptDevsList.Objects[i]).CDSName] ) );
        K_CMCaptDevsList.Objects[i].Free;
        N_Dump2Str( 'CMCDServObj Free Fin' );
      end;
      K_CMCaptDevsList.Free;
    end;

    WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), 0, TRUE); ////Igor  23062020

    FreeAndNil(N_FPCBObj);

    K_TreeFinGlobals();
    N_Dump1Str( 'SC> Application Close' );
  end   // if CanClose then
  else
  begin // if not CanClose then
    tiMain.Visible := True;
    Self.Caption := SCIniCaption;
//    SCModifyTrayIconTip( SCIniCaption + SCTrayAddCaption );
    if SCTrayAddCaption <> '' then
      SCModifyTrayIconTip( SCTrayAddCaption )
    else
      SCModifyTrayIconTip( SCIniCaption );

    SCRTask.Clear;
    if SCScanState = K_SCSSDoTask then
    begin
    // Close Form before Task Scan is Start
      SCScanCount := 0;
      Res := SCCheckTaskBrokenState( TRUE );
      if Res = 0 then
      begin
        if SCTWTaskFlag then
        begin // True Web Task
          SCRemoveTask( SCScanTaskSFile );
        end   // True Web Task
        else  // not True Web Task
        begin
          // Add DevicePlatesInfo to Upload r-file
          SCDevicePlatesInfoToUpload();

        // Create Task R-file
          SCRTask.Text := 'IsDone=TRUE'#13#10'ScanCount=0';
  //        K_VFSaveStrings( K_CMEDAccess.TmpStrings, SCScanTaskRFile, K_DFCreatePlain );
          UpdateRFileInfo := SCUpdateTextFile( SCRTask, SCScanTaskRFile );
  //!! not needed is done later        SCScanState := K_SCSSWait; // WAIT state
          if UpdateRFileInfo = '' then
          begin // Update R-File Error
  //          SCScanState := 5; // Update R-file is needed
            N_Dump1Str( 'SC> Close Task by R-file create error=' + SCScanTaskRFile );
          end
          else
            N_Dump1Str( 'SC> Close Task by R-file=' + UpdateRFileInfo );
        end // not True Web Task
      end
      else
      if Res = 2 then
        SCRemoveTask( SCScanTaskSFile );
    end // if SCScanState = K_SCSSDoTask then
    else
    begin
//!! not needed is done later      SCScanState := K_SCSSWait; // WAIT state
    end;

    if (N_BaseFormStayOnTop <> 0) and
       ( SCUIStayOnTopSetup or
         SCUIStayOnTopCapt ) then
      N_BaseFormStayOnTop := 0;

    SCScanState := K_SCSSWait; // WAIT state
    SCUpdateScanState();
{!!! 2015-03-16
    if Self.Visible then
    begin
      Hide();
      N_Dump2Str( 'SC> Form Hide on Form Close' );
    end;
}
    try
      Hide();
      N_Dump1Str( 'SC> Form Hide on Form Close' );
    except
      N_Dump1Str( 'SC> Form Hide on Form Close error' );
    end;
  end; // if not CanClose then

end; // procedure TK_FormCMScan.FormCloseQuery

//********************************************* TK_FormCMScan.ActTimerTimer ***
// Timer Event Handler
//
procedure TK_FormCMScan.ActTimerTimer(Sender: TObject);
var
  CloseFlag : Boolean;
  LogInfo : string;
  CurDelta, PathCheckDelay : Double;
  PrevNetworkDelay : Integer;
  PrevNetworkShift : Integer;
  NetworkWarn : string;
  HideFormWarn : string;

label NetworkSpeedIsRevived;

  procedure ChangeTrayIcon( ANewIcon : TIcon; const ANewHint : string; ShowBalloon: Boolean = False; BalloonKind: TBalloonFlags = bfInfo);
  begin
    if Assigned(ANewIcon) then
    begin
      Application.Icon := ANewIcon;
      tiMain.Icon := Application.Icon;
    end;

    SCModifyTrayIconTip( ANewHint, ShowBalloon, BalloonKind);
  end; // procedure ChangeTrayIcon

  // Check if current timer event is proper for action
  function IfDoAction( APeriod, AShift, ASlowShiftFactor : Integer ) : Boolean;
  var
    LPeriod : Integer;
  begin
    if SCNetworkSlowShift = 0 then
      Result := (SCScanTimerWaitCount mod APeriod) = AShift
    else
    begin
//      LPeriod := 3 * APeriod * SCNetworkSlowPeriod;
      //                 for Fast Events    for Slow Events
      LPeriod := Max(SCNetworkSlowPeriod, APeriod * SCNetworkSlowShift);
      Result := ((SCScanTimerWaitCount - SCNetworkSlowBaseCount) mod LPeriod) = ASlowShiftFactor * SCNetworkSlowShift + AShift;
    end;
  end; // function IfDoAction

label LExit;
begin

  ActTimer.Enabled := FALSE;
  N_Dump2Str( format( 'SC>>TCS %d State=%d', [SCScanTimerWaitCount mod 10,Ord(SCScanState)] ) );

// Thread was terminated by exception - terminate Application
  if Integer(SCScanDataUploadThread) = -1 then
  begin // Thread Exception - Terminate CMScan
    raise Exception.Create( 'ScanDataUploadThread exception' );
  end;

  // Close Application by user - if thread is active
  if SCCloseByUser                     and
     ((SCScanDataUploadThread = nil) or
      ((SCScanDataUploadThread <> nil)   and
        not SCScanDataUploadThread.SCUUploadInProcess and
        not SCScanDataUploadThread.SCURemoveInProcess)) then
  begin
    N_Dump1Str( 'SC> Timer Event >> Close by User' );
    Self.Close();
    Exit;
  end;

  if K_CMScanDataPath = '' then
  begin
    ActTimer.Enabled := TRUE; // needed if K_CMScanDataPath = '' on start
    Exit; // Precaution
  end;

  N_T1a.Start(); // Check Timer Event Handler time

{/////////////////////
// Network delay debug
if K_CMDesignModeFlag then
N_i := Round(Random(15*1000));
// Network delay debug
///////////////////////{}

////////////////////////////
// Check ScanDataPath access
//
  if IfDoAction( 1, 0, 0 ) then
  begin
    CloseFlag := SCDataPathExists;
    N_T1.Start();
    SCDataPathExists := DirectoryExists( K_CMScanDataPath );

{/////////////////////
// Network delay debug
if K_CMDesignModeFlag then
begin
sleep(N_i);
N_Dump2Str( 'SC> !Network delay >> ' + IntToStr(N_i) );
end;
// Network delay debug
///////////////////////{}

    N_T1.Stop();
    PathCheckDelay := N_T1.DeltaCounter/N_CPUFrequency;
    SCCheckScanDataPathTime := N_T1.ToStr();

    //////////////////////////
    // Check Path Existance
    //
    if not SCDataPathExists then
    begin
      if CloseFlag then
      begin
        N_Dump1Str( 'SC> !!! ScanDataPath access has been lost >> ' + K_CMScanDataPath );
        SCTrayAddCaption := 'An access to file server has been lost';

        ChangeTrayIcon( SCIconAlt, SCTrayAddCaption, True, bfError);
      end; // if CloseFlag then
      goto LExit;
    end // if not SCDataPathExists then
    else
    if not CloseFlag then
    begin
      N_Dump1Str( 'SC> !!! ScanDataPath access is revived >> ' + K_CMScanDataPath );
      ChangeTrayIcon( SCIconMain, Self.Caption);
      SCTrayAddCaption := '';
    end; // if not CloseFlag then
    //
    // Check Path Existance
    //////////////////////////

    //////////////////////////
    // Check Network Speed
    //
    PrevNetworkDelay := SCNetworkDelay;
    PrevNetworkShift := SCNetworkSlowShift;
    NetworkWarn := '';
    if PathCheckDelay * 3 > 1 then // Slow Access Test
    begin
      SCNetworkDelay := Round(PathCheckDelay);

      SCNetworkSlowShift := Max( 1, SCNetworkDelay);
      if SCNetworkDelay >= K_CMScanNetworkMidDelay then
         SCNetworkSlowShift := K_CMScanNetworkMidDelay + Round( 0.5 * (PathCheckDelay - K_CMScanNetworkMidDelay));

      if SCNetworkDelay >= K_CMScanNetworkMaxDelay then
      begin
        SCNetworkSlowPeriod := Round( SCNetworkSlowShift * 1.1 ) + 1; // stop all activity

        if PrevNetworkDelay < K_CMScanNetworkMaxDelay then // 1-st Delay+
        begin
          NetworkWarn := 'Delay+';
          SCNetworkSlowBaseCount := SCScanTimerWaitCount;
        end;

        Inc(K_CMScanDataPathSlowCheckCount);
        if K_CMScanDataPathSlowCheckCount = K_CMScanNetworkSlowMinTest + 1 then
        begin
          NetworkWarn := 'Stop';
          SCTrayAddCaption := 'Network problems has been detected';
          ChangeTrayIcon( SCIconAlt, SCTrayAddCaption, True, bfWarning);
        end;
      end
      else
      begin // if SCNetworkDelay < K_SCNetworkMaxDelay then
        SCNetworkSlowPeriod := 3 * SCNetworkSlowShift;

        if K_CMScanDataPathSlowCheckCount > K_CMScanNetworkSlowMinTest then
        begin // Fist Delay after Stop
          NetworkWarn := 'Continue';
          SCTrayAddCaption := '';
          ChangeTrayIcon( SCIconMain, Self.Caption );
        end
        else
        if PrevNetworkShift <> SCNetworkSlowShift then
        // Delay Result Attributes changed
          NetworkWarn := 'Delay';

        K_CMScanDataPathSlowCheckCount := 0;

        if PrevNetworkDelay >= K_CMScanNetworkMaxDelay then
        // Fist Delay after Delay+
          SCNetworkSlowBaseCount := SCScanTimerWaitCount;
      end;  // if SCNetworkDelay < K_SCNetworkMaxDelay then

    end  // if PathCheckDelta * 3 > 1 then  // Slow Access Test
    else // if PathCheckDelta * 3 <= 1 then // Fast Access Test
    if PrevNetworkDelay > 0 then
    begin
      SCNetworkDelay         := 0;
      SCNetworkSlowBaseCount := 0;
      SCNetworkSlowShift     := 0;
      SCNetworkSlowPeriod    := 0;
      K_CMScanDataPathSlowCheckCount := 0;
      NetworkWarn := 'Fast';
      SCTrayAddCaption := '';
      ChangeTrayIcon( SCIconMain, Self.Caption );
    end; // if PrevNetworkSlowShift > 0 then // Fast Access Test

    if NetworkWarn <> '' then
      N_Dump1Str( format( 'SC> !!! %s by network speed S=%d P=%d C=%d GC=%d',
           [NetworkWarn, SCNetworkSlowShift, SCNetworkSlowPeriod,
            SCNetworkSlowBaseCount, SCScanTimerWaitCount] ) );

    //
    // Check Network Speed
    //////////////////////////

  end; // if IfDoAction( 1, 0, 0 ) then
//
// Check ScanDataPath access
////////////////////////////

  if K_CMScanDataPathSlowCheckCount > K_CMScanNetworkSlowMinTest then
    goto Lexit; // Too slow network speed - skip all actions

//  if (SCScanTimerWaitCount mod 60) = 0 then  // do at the begining and each minute
  if IfDoAction( 60, 0, 2 ) then
    SCCheckLocalExchangeFolder( );

//  if IfDoAction( 60, 0, 2 ) then
  if (SCTranspFileName <> '') and IfDoAction( 1, 0, 2 ) then
  begin
  // Clear Transp Flag File in new position
    if FileExists( SCTranspFileName ) then
      K_DeleteFile( SCTranspFileName )
    else
      SCTranspFileName := '';
  end;

//  if SCScanRootFolderOld <> '' then
  if (SCScanRootFolderOld <> '') and IfDoAction( 1, 0, 2 ) then
  // Self Root Folder in old postion
    SCClearScanRootFolderOld( );

  if (SCScanRootFolderOld = '') and (SCScanState = K_SCSSMoveToNewPath) then
  // Switch to Previouse State after Change Path
    SCScanState := SCScanChangePathState;

  if SCCaptureIsStarted         and
    (SCScanState >= K_SCSSWait) and
    (SCScanState <> K_SCSSDoTask) then
    SCCaptureIsStarted := FALSE;


  if SCScanState = K_SCSSWait then
  begin
  // Not Check new path in Scan state - only in Wait and Setup

//    if (SCScanTimerWaitCount mod 60) = 1 then
    if IfDoAction( 60, 1, 2 ) then
      SCCheckScanPathChange();

    // Check ScanDataVersion Updates
    SCCloseByCMSVersion :=
//       ((SCScanTimerWaitCount mod 60) = 59) and
       IfDoAction( 60, 59, 2 ) and
       not SCCheckVersion();

    if SCCloseByCMSVersion then
    begin
      N_Dump1Str( 'SC> Timer Event >> Close by CMS version mismatch' );
      Self.Close();
      Exit;
    end;

  // Process Tasks (clear old) in Wait state
//    if not SCInitTaskIsDone or ((SCScanTimerWaitCount mod 60) = 2) then
//    if (not SCInitTaskIsDone and IfDoAction( 1, 2, 2 )) or IfDoAction( 60, 2, 20 ) then
    if (SCScanTimerWaitCount = 0) or IfDoAction( 60, 2, 20 ) then
    begin
      SCClearScanTasks( SCScanTimerWaitCount <> 0 );
//      SCClearScanTasks( SCInitTaskIsDone );
//      SCInitTaskIsDone := TRUE;
    end;

    if IfDoAction( 1, 0, 1 ) then
      SCCheckNewTask();
  end // if SCScanState = K_SCSSWait then
  else
  if (SCScanState = K_SCSSDoTask) and
     not SCCaptureIsStarted       and
     (SCCheckTaskBrokenState( TRUE ) >= 1) then
  begin // If task is stopped or terminated while capturing is not started
  // If stopped then only Self hide and wait for task termination
    if K_FormCMScanSelectMedia <> nil then // Close Recover Dialog - if is opened
      K_FormCMScanSelectMedia.Close();

    if SCCheckTaskBrokenState( FALSE ) = 2 then
    begin // If Task is terminated - remove Task files
      N_Dump2Str( 'SC> Task is terminated >> Remove Task' );
      SCRemoveTask( SCScanTaskSFile );
      SCScanState := K_SCSSWait;
      HideFormWarn := 'Task is terminated';
    end
    else
      HideFormWarn := 'Task is stoped';

    if Visible then
    begin // If Self is visible - Hide it (both if Task is stopped or terminated)
      N_Dump2Str( 'SC> ' + HideFormWarn + ' >> Hide Form before Capture start' );
      Hide();
      Self.Caption := SCIniCaption;
      SCModifyTrayIconTip('');
    end;
  end;
{ !!!OLD CODE 2018-06-29
     (SCCheckTaskBrokenState( TRUE ) = 2) then
  begin
  // Remove Tasks while Task is terminated by CMSuite before Capturing is started
    Hide();
    SCRemoveTask( SCScanTaskSFile );
    SCScanState := K_SCSSWait;
    if K_FormCMScanSelectMedia <> nil then
      K_FormCMScanSelectMedia.Close();
    N_Dump2Str( 'SC> Task is terminated >> Hide Form before Capture start' );
//    aOfflineModeExecute(Sender);
//    N_Dump2Str( 'SC> aOfflineModeExecute in ActTimerTimer' );
    Self.Caption := SCIniCaption;
    SCModifyTrayIconTip( '' );
  end;
}
  CloseFlag := SCScanState = K_SCSSFinTask;
  if CloseFlag then
  begin
    SCScanState := K_SCSSWait;
//    SCModifyTrayIconTip( Self.Caption )
  end;

  // Update Scan State File
  if IfDoAction( 1, 0, 2 ) then
    SCUpdateScanState();

  if (SCNewTrayTipInfo <> '') and (SCCurTrayTipInfo <> SCNewTrayTipInfo) then
    SCModifyTrayIconTip( SCNewTrayTipInfo, True, bfInfo)
  else
  if CloseFlag or ((SCScanTimerWaitCount > 1) and ((SCScanTimerWaitCount mod 30) = 1)) then
  begin
//    SCCreateTrayIcon( Self.Caption + SCTrayAddCaption );
    if SCTrayAddCaption <> '' then
      SCModifyTrayIconTip( SCTrayAddCaption )
    else
      SCModifyTrayIconTip( Self.Caption );
  end;


LExit:

  // Prepare Timer Event Dump
  N_T1a.Stop(); // // Check Timer Event Handler time
  CurDelta := N_T1a.DeltaCounter/N_CPUFrequency;
  LogInfo := '';
  if ((SCTimerAverageCount >= 10) and (CurDelta > 2 * SCTimerAverageTime)) or
     ((SCTimerAverageCount < 10) and (CurDelta > 0.5))  then
    LogInfo := ' Too Long Time=' + N_T1a.ToStr();

  // training period - define SCTimerAverageTime
  if (SCTimerAverageCount < 10) and
     ((SCScanTimerWaitCount mod 10) = 0) then
  begin
    SCTimerAverageTime := (SCTimerAverageTime * SCTimerAverageCount + CurDelta) / (SCTimerAverageCount + 1);
    Inc(SCTimerAverageCount);
  end;

  if (SCTimerAverageCount >= 10) and
     ((LogInfo <> '') or ((SCScanTimerWaitCount mod 60) = 0)) then
    LogInfo := LogInfo + ' AverageTime=' + N_TimeToString( SCTimerAverageTime/N_SecondsInDay, 1 );

  // Timer Event Dump
  if (LogInfo <> '') or ((SCScanTimerWaitCount mod 60) = 0) then
    N_Dump1Str( format( 'SC> Timer Event State=%d PathEx=%s TC=%d %s DET=%s NTT=%s',
                        [Ord(SCScanState), N_B2S(SCDataPathExists), SCScanTimerWaitCount, LogInfo,
                         SCCheckScanDataPathTime, SCCheckNewTasksListTime] ) );

  SCCheckScanDataPathTime := '';
  SCCheckNewTasksListTime := '';
  Inc(SCScanTimerWaitCount);

  ActTimer.Enabled := TRUE;

end; // procedure TK_FormCMScan.ActTimerTimer

//******************************* TK_FormCMScan.QuitMediaSuiteScanner1Click ***
// QuitMediaSuiteScanner1 Click Event Handler
//
procedure TK_FormCMScan.QuitMediaSuiteScanner1Click(Sender: TObject);
begin
  N_Dump1Str( 'SC> QuitMediaSuiteScanner1Click start');
  if (SCScanDataUploadThread <> nil) then
  begin
    if ( SCScanDataUploadThread.SCUUploadInProcess or
         SCScanDataUploadThread.SCURemoveInProcess ) and
       not SCConfirmApplicationTerm( '' ) then
    begin
      N_Dump1Str( format( 'SC> QuitMediaSuiteScanner fails Upload=%s Remove=%s',
                  [N_B2S(SCScanDataUploadThread.SCUUploadInProcess),
                   N_B2S(SCScanDataUploadThread.SCURemoveInProcess)] ) );
      Exit;
    end;
    SCScanDataUploadThread.Terminate();
    SCCloseByUser := TRUE;
    N_Dump1Str( 'SC> QuitMediaSuiteScanner1Click SCCloseByUser');
    Exit;
  end;

  SCCloseByUser := TRUE;
  Self.Close();
end; // procedure TK_FormCMScan.QuitMediaSuiteScanner1Click

//**************************** TK_FormCMScan.aSetupMediaSuiteScannerExecute ***
// SetupMediaSuiteScanner1 Click Event Handler
//
procedure TK_FormCMScan.aSetupMediaSuiteScannerExecute(Sender: TObject);
var
  Msg: TMessage;
begin
  tiMainDblClick(tiMain);
end; // procedure TK_FormCMScan.aSetupMediaSuiteScannerExecute

//*************************************** TK_FormCMScan.aOfflineModeExecute ***
// Offline Mode Switch Event Handler
//
procedure TK_FormCMScan.aOfflineModeExecute(Sender: TObject);
begin
  N_Dump2Str( 'SC> aOfflineModeExecute start');
  SCOfflineModeFlag := aOfflineMode.Checked;
  if SCOfflineModeFlag then
    Self.Caption := '[Offline] ' + SCIniCaption
  else
    Self.Caption := '[Setup] ' + SCIniCaption;

  SCModifyTrayIconTip( Self.Caption );
  N_Dump1Str( format( 'SC> aOfflineMode State=%s',
                      [N_B2S(SCOfflineModeFlag)] ) );
end; // procedure TK_FormCMScan.aOfflineModeExecute

//************************************************** TK_FormCMScan.FormShow ***
// FormShow Event Handler
//
procedure TK_FormCMScan.FormShow(Sender: TObject);
function GetWidthText(const Text:String; Font1:TFont) : Integer;
var
  LBmp: TBitmap;
begin
  LBmp := TBitmap.Create;
  try
   LBmp.Canvas.Font.Assign(Font1);
  // LBmp.Canvas.Font.Name := Font1.Name;
   LBmp.Canvas.Font.Size := Font1.Size+1;

   Result := LBmp.Canvas.TextWidth(Text);
  finally
   LBmp.Free;
  end;
end;

begin
  N_Dump1Str( 'SC> Show StayOnTop=' + IntToStr(N_BaseFormStayOnTop) );
  if N_BaseFormStayOnTop = 0 then // Needed to Clear StayOnTop if prev state was StayOnTop
    SetWindowPos( Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or
                  SWP_NOSIZE )
  else
    FormActivate(Sender);        // Needed to Set StayOnTop if prev state was not StayOnTop

  aPrevCaptResultsRecovery.Enabled := SCScanState <> K_SCSSSetup;
  aPrevCaptResultsRecovery.Visible := K_SCLocalFilesStorageThreshold <> 0;

  if SCScanState = K_SCSSSetup then
    Self.Caption := '[Setup] ' + SCIniCaption
  else
    Self.Caption := '[Online] ' + SCIniCaption + ' - Px:['+SCSTask.Values['PatientCardNumber']+'] '+SCSTask.Values['PatientFirstName']+' '+SCSTask.Values['PatientSurname'];

  Application.Initialize;
  Self.ClientWidth := Round(GetWidthText(Self.Caption, Application.DefaultFont))+20;

  N_CMResForm.aCaptByDentalUnit.Enabled := TRUE; // for 3.059 patch

  N_Dump1Str( 'SC> Show fin >> ' + Self.Caption );

  tiMain.Visible := False;
end; // procedure TK_FormCMScan.FormShow

//************************************************** TK_FormCMScan.FormHide ***
// Form Hide Event Handler
//
procedure TK_FormCMScan.FormHide(Sender: TObject);
begin
  N_Dump2Str( format( 'SC> FormHide State=%d', [Ord(SCScanState)] ) );
  if N_CMResForm.aCaptByDentalUnit <> nil then
    N_CMResForm.aCaptByDentalUnit.Enabled := FALSE; // for 3.059 patch
  aOfflineMode.Enabled := FALSE;
  aOfflineMode.Checked := FALSE;
  SCOfflineModeFlag := FALSE;

  tiMain.Visible := True;
//  aOfflineModeExecute(Sender);
end; // procedure TK_FormCMScan.FormHide

//************************************ TK_FormCMScan.aChangeDataPathExecute ***
// aChangeDataPath Event Handler
//
procedure TK_FormCMScan.aChangeDataPathExecute(Sender: TObject);
var
  WStr : string;
  PrevPath : string;
begin
  // Check if CMScan is not buisy
  N_Dump1Str( 'SC> User Change ScanDataPath start' );
  if (K_CMScanDataPath <> '') and               // Path is not set
     ( (SCScanState >= K_SCSSDoTask) or         // Self is buisy
       ( (SCScanDataUploadThread <> nil) and    // Thread is buisy
         ( SCScanDataUploadThread.SCUUploadInProcess or
           SCScanDataUploadThread.SCURemoveInProcess or
           ( (SCScanDataUploadThread.SCUUploadTasks <> nil) and (SCScanDataUploadThread.SCUUploadTasks.Count > 0) ) or
           ( (SCScanDataUploadThread.SCURemoveTasks <> nil) and (SCScanDataUploadThread.SCURemoveTasks.Count > 0) ) ) ) ) then
  begin
    SCShowNotReadyMessage();
    Exit;
  end;

  PrevPath := K_CMScanDataPath; // save prev path
  if SCSelectDataPathDlg( K_CMScanDataPath ) and
     (K_CMScanDataPath <> '') then
  begin
  // Save K_CMScanDataPath to Cur Context
    K_CMScanDataPath := IncludeTrailingPathDelimiter(
                                K_OptimizePath( K_ExpandFileName(K_CMScanDataPath) ) );
    WStr := ExtractFilePath(ExcludeTrailingPathDelimiter(SCScanLocalExchangeFolder));
    if not K_CMDesignModeFlag and K_StrStartsWith( WStr, K_CMScanDataPath ) then
      K_CMScanDataPath := WStr + 'Exchange\';

    if PrevPath <> K_CMScanDataPath then
    begin
      SCScanNewTaskNameFileDate := 0;
      SCScanNewTaskNameFileErrCount := 0;
    end;

    N_StringToMemIni( 'CMS_Main', 'ScanDataPath', K_CMScanDataPath );
    K_CMEDAMemIniToExtIniFiles();

    SCInitScanPathsContext();
    N_Dump1Str( 'SC> User Change ScanDataPath="' + K_CMScanDataPath + '"' );
  end; // if SCSelectDataPathDlg( K_CMScanDataPath ) ...
end; // procedure TK_FormCMScan.aChangeDataPathExecute

//*************************** TK_FormCMScan.aPrevCaptResultsRecoveryExecute ***
// aPrevCaptResultsRecovery Event Handler
//
procedure TK_FormCMScan.aPrevCaptResultsRecoveryExecute(Sender: TObject);
begin
  N_Dump1Str( 'SC> aPrevCaptResultsRecovery start' );
  K_CMEDAccess.TmpStrings.Clear;
  K_ScanFilesTree( SCScanRootLocFolder, SCScanFilesTreeSelectFile, 'S???????????????.txt' );
  if SCSL = nil then SCSL := TStringList.Create;
  SCSL.Sorted := FALSE;
  SCSL.Assign( K_CMEDAccess.TmpStrings );
  SCSL.Sort();

  if K_CMScanSelectMediaDlg( SCSL  ) then
  begin
//K_CMShowMessageDlg( 'Data transfer is not implemented', mtWarning );
//Close();
//Exit;
    // Add Upload Task to  Upload Thread and Hide Form
    if SCCheckTaskBrokenState( TRUE ) = 0 then
      SCScanDataUploadThread.SCUAddUploadTask( K_SCGetTaskRSFileName( SCScanTaskLocRFile, 'S' ) );

    SCScanState := K_SCSSWait; // Set Wait State
    Hide();
    N_Dump2Str( 'SC> Form Hide after Transfer Start' );
    Self.Caption := SCIniCaption;
    SCModifyTrayIconTip( '' );
//    aOfflineModeExecute(Sender);
//    N_Dump2Str( 'SC> aOfflineModeExecute in aShowPrevCaptResultsExecute' );
  end;
end; // procedure TK_FormCMScan.aPrevCaptResultsRecoveryExecute

//****************************************** TK_FormCMScan.TimerWEBDavTimer ***
// Appliction TimerWEBDav Event Handler
//
procedure TK_FormCMScan.TimerWEBDavTimer(Sender: TObject);
var Res: Int64;
begin
  inherited;
  TimerWEBDav.Enabled := false;
  if not SCWEBMode then Exit;
  L_CountWebDav := L_CountWebDav + 1;

  Res := SCWEBInitDiskZ();
  if Res = NO_ERROR then Exit;

  if Res = ERROR_NOT_AUTHENTICATED then
  begin
    N_Dump1Str('SCWEBInitDiskZ> A logon failure because of an unknown user name or a bad password.');
    K_CMShowMessageDlg('Error connecting a network disk.' + #13#10
        + 'A logon failure because of an unknown user name or a bad password.', mtWarning,[mbOk]);
    Exit;
  end;

  N_Dump1Str('SCWEBInitDiskZ> Network disk connection error! Try-' + IntToStr(L_CountWebDav) + ' #' + IntToStr(Res));

  if L_CountWebDav > 4 then
  begin
    case K_CMShowMessageDlg('Error connecting a network disk after 5 attempts!' + #13#10 + 'Error #' + IntToStr(Res), mtWarning,[mbRetry, mbIgnore, mbAbort]) of
      mrRetry:
        begin
          L_CountWebDav := 0;
          TimerWEBDav.Interval := 1000;
          TimerWEBDav.Enabled := true;
        end;
      mrIgnore: Exit;
      mrAbort: QuitMediaSuiteScanner1Click(nil);      ////Igor 14072020
    end;
    Exit;
  end else
  begin
    TimerWEBDav.Interval := 1000;
    TimerWEBDav.Enabled := true;
  end;

end; // procedure TK_FormCMScan.TimerWEBDavTimer

//*********************************************** TK_FormCMScan.TrayMessage ***
// Appliction Tray Message Event Handler
//
//procedure TK_FormCMScan.TrayMessage(var Msg: TMessage);
//var
//  P: TPoint;
//begin
//  case Msg.LParam of
//    WM_LBUTTONDOWN: begin
//      N_Dump2Str( 'SC> Tray Left Button');
//      if not Self.Visible and ((SCScanState = K_SCSSWait) or (SCScanState = K_SCSSMoveToNewPath)) then
//      begin
//        N_Dump1Str( 'SC> Open Setup ' );
//        SCScanState := K_SCSSSetup; // SETUP state - before show !!!
//        aOfflineMode.Enabled := TRUE;
//
//        if SCUIStayOnTopSetup then
//          N_BaseFormStayOnTop := 2;
//
//        Self.Show();
////        Self.FormDeactivate( nil );
//
////        SCModifyTrayIconTip( Self.Caption + SCTrayAddCaption );
//        if SCTrayAddCaption <> '' then
//          SCModifyTrayIconTip( SCTrayAddCaption )
//        else
//          SCModifyTrayIconTip( Self.Caption );
//
//        if K_CMScanDataPath = '' then
//          SCScanDataPathIniSet();
////        ActTimer.Enabled := (K_CMScanDataPath <> '');
//        SCInitScanPathsContext();
//
//        SCUpdateScanState();
//
//      end
//      else
//      if Self.Visible then
//      begin
//        Self.WindowState := wsNormal;
//        Self.SetFocus
//      end
//      else
//      if SCScanState <> K_SCSSSetup then
//      begin
//        N_Dump1Str( 'SC> Tray Left Button State=' + IntToStr(Ord(SCScanState)) );
//        SCShowNotReadyMessage();
//      end;
//    end;
//{}
//    WM_RBUTTONDOWN:
//    begin
//      N_Dump2Str( 'SC> Tray Right Button');
//      if SCScanState = K_SCSSWait then
//      begin
//        GetCursorPos(P);
//        CreateCMScanexeDistributive1.Visible := (N_CM_IDEMode = 1) or (N_CM_IDEMode = 2);
//        N_Dump2Str( 'SC> Before Popup');
//        PopupMenu1.Popup(P.X, P.Y);
//      end
//      else if Self.Visible then
//      begin
//        Self.WindowState :=  wsNormal;
//        Self.SetFocus
//      end
//      else if SCScanState <> K_SCSSSetup then
//      begin
//        N_Dump1Str( 'SC> Tray Right Button State=' + IntToStr(Ord(SCScanState)) );
//        SCShowNotReadyMessage();
//      end;
//    end;
//{}
//  end;
//end; // procedure TK_FormCMScan.TrayMessage

{ // for comp in D7
//********************************** TK_FormCMScan.IdHTTPServer1CommandGet ***
// IdHTTPServer1 CommandGet Event Handler
//
procedure TK_FormCMScan.IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
var
  ParamStr, Info: String;
  ParamList: TStringList;
begin
  //inherited;
  AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin','*'); // !!!!!!!!!!!!!!!!!!

  if (ARequestInfo.Command = 'GET') then        /// GET
  begin
//    AResponseInfo.ContentStream := TStringStream.Create(GetComputerNetName);
    if ARequestInfo.QueryParams = '' then                                                             //SIR #26380
        //AResponseInfo.ContentStream := TStringStream.Create(K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName);
        AResponseInfo.ContentStream := TStringStream.Create(SCWEBWDCompID);
    if ARequestInfo.QueryParams = 'info' then
    begin
        //Info := 'CompName=' + K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName;
        Info := 'CompName=' + SCWEBWDCompID;
        Info := Info + '&CompID=' + SCWEBWDCompID;
        Info := Info + '&Version=' + N_CMSVersion;
        Info := Info + '&DateOut=' + SCWEBWDDateOut;
        AResponseInfo.ContentStream := TStringStream.Create(Info);
    end;

    if pos('dateout=', ARequestInfo.QueryParams) > 0 then
    begin
      ParamStr := ARequestInfo.QueryParams;
      ParamList := TStringList.Create;
      ParamList.DelimitedText := ParamStr;
      SCWEBWDDateOut := ParamList.Values['dateout'];
      ParamList.Free;
      AResponseInfo.ContentStream := TStringStream.Create('ok ' + ParamStr);
        K_CMEDAccess.TmpStrings.Text := format('WDDateOut="%s"', [SCWEBWDDateOut]);
        SCWEBCurStateToMemIni();
        K_CMEDAMemIniToExtIniFiles();
        K_MVCBFSaveAll();
    end;

    if pos('webdav=', ARequestInfo.QueryParams) > 0 then
      begin
        ParamStr := ARequestInfo.QueryParams;
        Delete(ParamStr, 1, 7);
        ParamStr := DeCodeParamURL(ParamStr, 'cms');
        if pos('port', ParamStr) > 0 then                   //decode is correct
        begin
           ParamList := TStringList.Create;
             ParamList.Delimiter := '&';
             ParamList.DelimitedText := ParamStr;
             //L_VirtUIWebDAVPort := ParamList.Values['port'];           //SIR#26380
             //L_VirtUIWebDAVDrive := ParamList.Values['drive'];
             L_VirtUIWebDAVHost := ParamList.Values['host'];
             L_VirtUIWebDAVUser := ParamList.Values['user'];
             L_VirtUIWebDAVPassword := ParamList.Values['password'];
           ParamList.Free;
           with K_FormCMScan do
            begin
              SCWEBMode := true;
              //SCWEBPortNumber := StrToInt(L_VirtUIWebDAVPort);
              //SCWEBWDDriveChar := L_VirtUIWebDAVDrive;
              SCWEBWDHost := L_VirtUIWebDAVHost;
              SCWEBWDLogin := L_VirtUIWebDAVUser;
              SCWEBWDPassword := L_VirtUIWebDAVPassword;
            end;
        K_CMEDAccess.TmpStrings.Text := format( 'WEBMode=%s'#13#10 +
                                           'PortNumber=%d'#13#10 +
                                           'WDDrive=%s'#13#10 +
                                           'WDHost="%s"'#13#10 +
                                           'WDLogin="%s"'#13#10 +
                                           'WDPassword="%s"',
        [N_B2S(true), SCWEBPortNumber,SCWEBWDDriveChar,SCWEBWDHost,
         SCWEBWDLogin,SCWEBWDPassword] );
        end;
        SCWEBCurStateToMemIni();
        K_CMEDAMemIniToExtIniFiles();
        K_MVCBFSaveAll();
        SCWEBInit();
        TimerWEBDav.Interval := 1000;          ////Igor 11092020
        TimerWEBDav.Enabled := true;
        AResponseInfo.ContentStream := TStringStream.Create('ok ' + L_VirtUIWebDAVHost);
      end;
  end;
end; // procedure TK_FormCMScan.IdHTTPServer1CommandGet
}

//*************************************** TK_FormCMScan.aWEBSettingsExecute ***
// aWEBSettings Execute Event Handler
//
procedure TK_FormCMScan.aWEBSettingsExecute(Sender: TObject);
begin
 if not K_CMEnterConfirmDlg( '', '', K_CMDesignModeFlag,                         //SIR #25997
               'CMScan WEB Settings',
               'Wrong user name or password. Press OK to return' ) then  Exit;
  if K_CMScanWEBSettingsDlg() then
  begin
    K_CMEDAccess.TmpStrings.Text := format( 'WEBMode=%s'#13#10 +
                                       'PortNumber=%d'#13#10 +
                                       'WDDrive=%s'#13#10 +
                                       'WDHost="%s"'#13#10 +
                                       'WDLogin="%s"'#13#10 +
                                       'WDPassword="%s"',
    [N_B2S(SCWEBMode), SCWEBPortNumber,SCWEBWDDriveChar,SCWEBWDHost,
     SCWEBWDLogin,SCWEBWDPassword] );

    K_CMEDAHideLoginPasswordForDump(K_CMEDAccess.TmpStrings);
      N_Dump1Str( '     aWEBSettingsExecute after:'#13#10 + K_CMEDAccess.TmpStrings.Text );

    SCWEBCurStateToMemIni();
    K_CMEDAMemIniToExtIniFiles();
    K_MVCBFSaveAll();
    SCWEBInit();
    TimerWEBDav.Interval := 1000;          ////Igor 11092020
    TimerWEBDav.Enabled := true;
  end;
{  Previouse Version
var
  ParamsForm: TN_EditParamsForm;
begin
  ParamsForm := N_CreateEditParamsForm( 200 );
  with ParamsForm do
  begin
    Caption := 'WEB Settings';
    AddLEdit( 'Port number      :', 0, IntToStr(SCWEBPortNumber) );
    AddLEdit( 'WEB DAV Drive    :', 0, SCWEBWDDriveChar );
    AddLEdit( 'WEB DAV Host     :', 0, SCWEBWDHost );
    AddLEdit( 'WEB DAV Login    :', 0, SCWEBWDLogin );
    AddLEdit( 'WEB DAV Password :', 0, SCWEBWDPassword );
    AddCheckBox( 'WEB Mode :', SCWEBMode );
//    TEdit(EPControls[4].CRContr).PasswordChar := '*';

    N_Dump1Str( format( 'aWEBSettingsExecute before >> %d %s "%s" "%s" "%s"',
               [SCWEBPortNumber,SCWEBWDDriveChar,SCWEBWDHost,SCWEBWDLogin,SCWEBWDPassword] ) );

    ShowSelfModal();

    if ModalResult <> mrOK then  Exit;

    SCWEBPortNumber   := StrToIntDef( EPControls[0].CRStr, SCWEBPortNumber ); // ObjName on output (changed or not)
    with EPControls[1] do
      if (Length(CRStr) > 0) and
         (((CRStr[1] >= 'a') and (CRStr[1] <= 'z')) or ((CRStr[1] >= 'A') and (CRStr[1] <= 'Z'))) then
        SCWEBWDDriveChar := UpperCase( Copy( CRStr, 1, 1) );
    SCWEBWDHost := EPControls[2].CRStr;
    SCWEBWDLogin := EPControls[3].CRStr;
    SCWEBWDPassword := EPControls[4].CRStr;
    SCWEBMode := EPControls[5].CRBool;
    N_Dump1Str( format( 'aWEBSettingsExecute after >> %d %s "%s" "%s" "%s"',
                [SCWEBPortNumber,SCWEBWDDriveChar,SCWEBWDHost,SCWEBWDLogin,SCWEBWDPassword] ) );
  end;
  SCWEBInit();
}
end;

procedure TK_FormCMScan.eventsMainMinimize(Sender: TObject);
begin
  inherited;

  Hide();
  WindowState := wsMinimized;

  tiMain.Visible := True;
end;

procedure TK_FormCMScan.eventsMainRestore(Sender: TObject);
begin
  inherited;

end;

// procedure TK_FormCMScan.aWEBSettingsExecute

//************************************** TK_FormCMScan.SCShowAccessWarninig ***
// Show CMSuite|CMScan common data root folder access error warning
//
procedure TK_FormCMScan.SCShowAccessWarninig();
begin
  K_CMShowMessageDlg(
    'There is no access to CMSuite|CMScan common data root folder'+
     #13#10'"' + K_CMScanDataPath + '"'#13#10 +
    'Please revive access and start Media Suite Client Scanner again.',  mtError );
end; // end of procedure TK_FormCMScan.SCShowAccessWarninig

//********************************* TK_FormCMScan.SCShowScanDataVerWarninig ***
// Show CMSuite|CMScan version warning
//
procedure TK_FormCMScan.SCShowScanDataVerWarninig( AShowWarning : Boolean );
begin
  N_Dump1Str( format( 'SC> ScanDataVersion %d <> %d needed',
              [SCScanDataVersion,K_CMScanDataVersion] ) );

//  if (SCScanDataVersion >= 0) and AShowWarning then
  if (SCScanDataVersion >= 0) or AShowWarning then
    K_CMShowMessageDlg( format( '%s build number %s does not match %s build number %s',
                                [K_SCRegSuiteProductName,SCInfoStrings.Values['CMSBuildNumber'],
                                 K_CMMessageDlgDefaultCaption,N_CMSVersion] ), mtWarning );
end; // end of procedure TK_FormCMScan.SCShowScanDataVerWarninig

//********************************************* TK_FormCMScan.OnUHException ***
// On Appliction Unhadled Exception Handler
//
procedure TK_FormCMScan.OnUHException( Sender: TObject; E: Exception );
var
//  hTaskBar: THandle;
  ErrStr : string;
begin
  try
    // To prevent Unhadled Exception Handler recursive call
    if SCUHExceptionInProcess then
    begin
      TerminateProcess( GetCurrentProcess(), 10 );
      Exit;
    end;
    SCUHExceptionInProcess := TRUE;

    if SCTrayIconData.cbSize <> 0 then
      Shell_NotifyIcon(NIM_DELETE, @SCTrayIconData);

    if SCScanDataUploadThread <> nil then
      SCScanDataUploadThread.Terminate();

    ErrStr := ' Media Suite Client Scanner terminated by exception:' + #13#10 + E.Message;

    ActTimer.Enabled := FALSE; // Stop Timer Activity befor any dialog show

    if (K_CMScanDataPath <> '') and not DirectoryExists( K_CMScanDataPath ) then
    begin
      N_Dump1Str( ErrStr );
      K_CMRemoveOldDump2ExceptFiles();
      N_CMSCreateDumpFiles( $001 );
      N_Dump1Str( 'Application CMScan.UHException 1 FlushCounters' + N_GetFlushCountersStr() );
      N_LCExecAction( -1, lcaFlush );
      K_CMEDAccess.Free;
      SCShowAccessWarninig();
    end
    else
    if N_CM_MainForm <> nil then
      N_CM_MainForm.OnUHException( Sender, E )
    else
    begin
      K_CMShowMessageDlg( ErrStr, mtError );
      N_Dump1Str( 'Application CMScan.UHException 2 FlushCounters' + N_GetFlushCountersStr() );
      N_LCExecAction( -1, lcaFlush );
      K_CMEDAccess.Free;
    end;
    N_Dump1Str( 'CMScan Exception fin processing'  );
  finally
    TerminateProcess( GetCurrentProcess(), 10 );
  end;
end; 

procedure TK_FormCMScan.PopupMenu1Popup(Sender: TObject);
begin
  inherited;
  CreateCMScanexeDistributive1.Visible := (N_CM_IDEMode = 1) or (N_CM_IDEMode = 2);
end;

// end of procedure TK_FormCMScan.OnUHException

//************************************************** TK_FormCMScan.SCShowHint ***
// Form Show Application Hint Event Handler
//
procedure TK_FormCMScan.SCShowHint(Sender: TObject);
begin
  SCShowString( GetLongHint( Application.Hint ) );
end; // procedure TK_FormCMScan.SCShowHint

//********************************************** TK_FormCMScan.SCShowString ***
// Show string in status bar
//
procedure TK_FormCMScan.SCShowString( AStr : string );
begin
//
  StatusBar.SimpleText := ' ' + AStr;
end; // procedure TK_FormCMScan.SCShowString

//************************************** TK_FormCMScan.SCScanDataPathIniSet ***
// Scan Data Path Initial Set
//
procedure TK_FormCMScan.SCScanDataPathIniSet;
var
  FScanDataPath : string;

begin
// Check if ScanDataPath is set by Installer
  FScanDataPath := K_ExpandFileName( '(#BasePath#)ScanDataPath.txt');
  N_Dump1Str( 'SC> InitPath try get from "' + FScanDataPath + '"' );
  if FileExists( FScanDataPath ) then
  begin
    if K_VFLoadText( K_CMScanDataPath, FScanDataPath ) then
      N_Dump1Str( 'SC> InitPath ScanDataPath from file "' + K_CMScanDataPath + '"' )
    else
      N_Dump1Str( 'SC> InitPath file read error' );
  end;

  if K_CMScanDataPath = '' then
  begin
  // Select ScanDataPath
    K_CMScanDataPath := SCScanLocalExchangeFolder;
    if SCSelectDataPathDlg( K_CMScanDataPath ) then
      N_Dump1Str( 'SC> InitPath ScanDataPath Selected "' + K_CMScanDataPath + '"' )
  end; // if K_CMScanDataPath = '' then

  if K_CMScanDataPath <> '' then
  begin
    // Save K_CMScanDataPath to Cur Context if it is set
    FScanDataPath := K_CMScanDataPath;

    // Save to Cur Context
    K_CMScanDataPath := IncludeTrailingPathDelimiter(
                                K_OptimizePath( K_ExpandFileName( Trim(K_CMScanDataPath) ) ) );

    N_StringToMemIni( 'CMS_Main', 'ScanDataPath', K_CMScanDataPath );
    K_CMEDAMemIniToExtIniFiles();

    // Prep Dump Info
    if FScanDataPath = K_CMScanDataPath then
      FScanDataPath := ''
    else
      FScanDataPath := ' "' + K_CMScanDataPath + '"';

    N_Dump1Str( 'SC> InitPath ScanDataPath is saved' + FScanDataPath );
  end; // if K_CMScanDataPath <> '' then

end; // procedure TK_FormCMScan.SCScanDataPathIniSet

//************************************ TK_FormCMScan.SCInitScanPathsContext ***
// Init Scan Paths Context
//
procedure TK_FormCMScan.SCInitScanPathsContext();
begin
  if SCWEBWDCompID <> '' then
  begin
    SCScanRootFolder := K_CMScanDataPath + SCWEBWDCompID + '\';
    N_Dump1Str( 'SC> SCInitScanPathsContext use CompID ' + SCWEBWDCompID );
  end
  else
  begin
    SCScanRootFolder := K_CMScanDataPath + K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName + '\';
    N_Dump1Str( 'SC> SCInitScanPathsContext use CompName ' + K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName );
  end;
  SCScanStateFile := SCScanRootFolder + K_CMScanClientStateFileName;
  SCScanNewTaskNameFile := SCScanRootFolder + K_CMScanCurTaskInfoFileName;
end; // procedure TK_FormCMScan.SCInitScanPathsContext

//********************************************* TK_FormCMScan.SCGetInfoFile ***
// Get CMSuite Info File
//
//     Parameters
// AReadIfUpdated - if TRUE the file will be load to K_CMEDaccess.TmpStrings
//                  only if it was updated
// Result - Returns -1 if file doesn't exist, 0 if file was not changed, 1 -
//          file state was read to SCInfoStrings
//
function TK_FormCMScan.SCGetInfoFile( AReadIfUpdated : Boolean ) : Integer;
var
  FInfoName : string;
  FInfoFileDate : TDateTime;
begin
  Result := -1;
  if (K_CMScanDataPath = '') or
     not SCDataPathExists    or
     (SCNetworkSlowShift >= 10) then Exit;

  if SCInfoStrings = nil then
    SCInfoStrings := TStringList.Create;

  FInfoName := K_CMScanDataPath + K_CMScanCommonInfoFileName;
  N_T1.Start();
  FInfoFileDate := K_GetFileAge(FInfoName);
  N_T1.Stop();
  N_Dump2Str( 'SC> InfoFile GetFileAge Time=' + N_T1.ToStr() );
  if FInfoFileDate = 0 then
  begin
    N_Dump1Str( 'SC> InfoFile absent >> ' + FInfoName );
    Exit;
  end;

  Result := 0;
  if AReadIfUpdated and (SCInfoFileDate >= FInfoFileDate) then Exit;

  N_Dump1Str( format( 'SC> Load InfoFile >> "%s" from %s',
                      [FInfoName, K_DateTimeToStr(FInfoFileDate)] ) );
  if not SCLoadTextFile( FInfoName ) then
    Result := -1
  else
  begin
    SCInfoFileDate := FInfoFileDate;
    SCInfoStrings.Assign( K_CMEDAccess.TmpStrings );
    Result := 1;
    N_Dump1Strings( K_CMEDAccess.TmpStrings, 5 );
  end;

  if SCInfoStrings.Count > 0 then
    SCCMSScanDataPath := SCInfoStrings.Values['ScanDataPath'];

end; // procedure TK_FormCMScan.SCGetInfoFile

//************************************** TK_FormCMScan.SCCheckCMScanUpdates ***
// Check CMScan Updates
//
function TK_FormCMScan.SCCheckCMScanUpdates() : Boolean;
var
  WNewPath : string;
  DeleteNewFolder : Boolean;
begin
  Result := FALSE;

  // Clear files after Update
  WNewPath := ExtractFilePath( ExcludeTrailingPathDelimiter(
                  ExtractFilePath(Application.ExeName) ) ) +
                  'NewBinFiles\';
  DeleteNewFolder := DirectoryExists( WNewPath );
  if DeleteNewFolder then
  begin
    K_DeleteFolderFiles( WNewPath, '*.*',
                         [K_dffRecurseSubfolders,K_dffRemoveReadOnly] ); // Clear place for updates
    N_Dump1Str( '*!*!* CMScan update NewBinfiles are cleared' );
  end;

  if K_CMScanDataPath = '' then Exit; // Precaution

  // Check Updates
  SCUpdatesExeFileName := K_CMScanDataPath +
    ExtractFileName( ExcludeTrailingPathDelimiter(ExtractFilePath( Application.ExeName ))) +
    '\' + SCUpdatesExeFileName;

  if not FileExists( SCUpdatesExeFileName ) or
    (K_GetFileAge(Application.ExeName) >=  K_GetFileAge(SCUpdatesExeFileName)) then
  begin
    if DeleteNewFolder then
      RemoveDir( ExcludeTrailingPathDelimiter(WNewPath) );
    Exit;
  end;


  N_Dump1Str( '*!*!* CMScan new files are found' );
  if not K_CopyFolderFiles( ExtractFilePath(SCUpdatesExeFileName), WNewPath ) then
  begin
    K_CMShowMessageDlg( 'Media Suite Scanner update problem. Copy new version files error.', mtError );
    Exit;
  end
  else
    N_Dump1Str( '*!*!* CMScan new files are copied to NewBinFiles' );

  sleep( 100 ); // wait for copy fin
//  WNewPath := WNewPath + 'CMScan.exe /ScanSelfUpdate';
//  Result := K_RunExeByCmdl( WNewPath );
  WNewPath := K_RunExe(WNewPath + 'CMScan.exe', '/ScanSelfUpdate' );
  Result := WNewPath = '';
  if not Result then
  begin
//    N_Dump1Str( '*!*!* CMScan update launch error >> ' + SysErrorMessage( GetLastError() ) );
    N_Dump1Str( '*!*!* CMScan update launch error >> ' + WNewPath );
    K_CMShowMessageDlg( 'Media Suite Scanner Self Update launching error', mtError );
  end;
  N_Dump1Str( '*!*!* CMScan Self Update in NewBinFiles is launched' );

end; // procedure TK_FormCMScan.SCCheckCMScanUpdates

//****************************************** TK_FormCMScan.SCUpdateTextFile ***
// Update Task Text File
//
//     Parameters
// AStrings - file current state strings
// AFileName - file name
//
function  TK_FormCMScan.SCUpdateTextFile( AStrings : TStrings; const AFileName : string ) : string;
begin
  Result := '';
  N_T1.Start();
  if K_VFSaveStrings( AStrings, AFileName, K_DFCreatePlain ) then
  begin
    N_T1.Stop();

    Result := K_CMScanGetFileCopyReport( ExtractFileName(AFileName), Length(AStrings.Text) + 1, N_T1 );
  end;
end; // function  TK_FormCMScan.SCUpdateTextFile

//*************************************** TK_FormCMScan.SCUpdateTaskLocFile ***
// Update Task Loc File
//
procedure TK_FormCMScan.SCUpdateTaskLocFile( const ALockTaskFile : string;
                                             ALocTaskStrings : TStrings );
var
  ErrCount : Integer;
begin
  ErrCount := 0;
  N_Dump2Str( 'SC> Local SR-file update >> ' + ALockTaskFile );
  while (ErrCount < 10) and
        not K_VFSaveStrings( ALocTaskStrings, ALockTaskFile, K_DFCreatePlain ) do
  begin
    N_Dump2Str( 'SC> Local SR-file write error >>' + ALockTaskFile );
    Inc( ErrCount );
    sleep(100);
  end;
  if ErrCount >= 10 then
    raise Exception.Create( 'CMSCan Local SR-file write error >>' + ALockTaskFile );
end; // function  TK_FormCMScan.SCUpdateTaskLocFile

//************************************** TK_FormCMScan.SCUpdateTaskLocRFile ***
// Update Task Loc RFile
//
procedure TK_FormCMScan.SCUpdateTaskLocRFile();
{
var
  ErrCount : Integer;
begin
  ErrCount := 0;
  while (ErrCount < 10) and
        not K_VFSaveStrings( SCRTask, SCScanTaskLocRFile, K_DFCreatePlain ) do
  begin
    N_Dump2Str( 'SC> Local R-file write error >>' + SCScanTaskLocRFile );
    Inc( ErrCount );
    sleep(100);
  end;
  if ErrCount >= 10 then
    raise Exception.Create( 'CMSCan Local R-file write error >>' + SCScanTaskLocRFile );
}
begin
  SCUpdateTaskLocFile(SCScanTaskLocRFile,SCRTask);
end; // function  TK_FormCMScan.SCUpdateTaskLocRFile

//*************************************** TK_FormCMScan.SCCopyTaskScanFiles ***
// Copy Task Scan Files
//
function TK_FormCMScan.SCCopyTaskScanFiles() : Boolean;
var
  i, Ind : Integer;
  ScannedFile : string;
  F: TSearchRec;
//  CopyFilesFlag : Boolean;
  NoCopyErrFlag : Boolean;
  UpdateRFileInfo : string;
  TaskBrokenState : Integer;
label ContLoop, FinLoop, ContCopy;

begin
  Result := TRUE;
  if not DirectoryExists( K_CMScanDataPath ) then Exit;
  if SCScanCount = 0 then
  begin
    N_Dump1Str( 'SC> CopyTaskScanFiles >> nothing to do' );
    if SCScanUpload1Count = -1 then SCScanUpload1Count := 0; // Clear directory absent flag
    Exit;
  end;
  i := 0;
  if FindFirst( SCScanTaskLocFolder + '*.*', faAnyFile, F ) = 0 then
  begin
    repeat
      if (F.Name[1] <> '.') and ((F.Attr and faDirectory) = 0) then
        goto ContCopy;
    until FindNext( F ) <> 0; // End of Files Upload Loop
    if SCScanUpload1Count = -1 then SCScanUpload1Count := 0; // Clear directory absent flag
    SCScanCount := 0;
    N_Dump1Str( format( 'SC> CopyTaskScanFiles >> Empty LocBufer TaskID=%s',
                [SCScanTaskID] ) );
    Exit;

ContCopy:

    if not DirectoryExists( SCScanTaskFolder ) and
//       not K_ForceFilePath( SCScanTaskFolder ) then Exit;
       not K_ForceDirPath( SCScanTaskFolder ) then Exit;

    if SCScanUpload1Count = -1 then SCScanUpload1Count := 0; // Clear directory absent flag

    // Files Upload Loop
    N_Dump1Str( format( 'SC> CopyTaskScanFiles >> Upload Loop for %d slides is started from Ind=%d TaskID=%s',
                [SCScanCount, SCScanUpload1Count, SCScanTaskID] ) );


    SCRTask.Values['IsDone'] := K_CMScanTaskIsUploaded;
//    CopyFilesFlag := FALSE;
    repeat
//      if (F.Name[1] <> '.') and ((F.Attr and faDirectory) = 0) then Continue;

      ScannedFile := SCScanTaskLocFolder + F.Name;
      Ind := Length(ScannedFile) - 4;

      if ScannedFile[Ind] = 'A' then
      begin


        if SCScanUpload1Count < i then
          SCScanUpload1Count := i;

        SCModifyTrayIconTip( format( '%s'#13#10'Upload data (%d objects done)',
                           [SCIniCaption, SCScanUpload1Count] ), True, bfInfo);

        // Correct R-file for prevoiuse Slide (and if repeat Upload)
        if (i > SCScanUpload2Count) then
        begin
          SCRTask.Values['ScanCount'] := IntToStr( i );
          UpdateRFileInfo := SCUpdateTextFile( SCRTask, SCScanTaskRFile );
          if UpdateRFileInfo = '' then
          begin
            N_Dump1Str( format( 'SC> CopyTaskScanFiles >> CopyCount=%d Update R-File Error >> %s',
                        [i, SCScanTaskRFile] ) );
            goto FinLoop;
          end
          else
          begin
            N_Dump2Str( format( 'SC> CopyTaskScanFiles >> %d slides are copied >> R-file=%s',
                        [i, UpdateRFileInfo] ) );
            SCScanUpload2Count := i;
          end;
        end; // if (i >= AStartInd) then

        // Check if uppload is canceld by user R-file for prevoiuse Slide (and if repeat Upload)
        TaskBrokenState := SCCheckTaskBrokenState( TRUE );
        if TaskBrokenState <> 0 then
        begin
          Result := FALSE;
          N_Dump1Str( format( 'SC> CopyTaskScanFiles >> is stopped by Task BrokenState=%d', [TaskBrokenState] ) );
          goto FinLoop;
        end;

        Inc(i); // New Slide is started - i = New Slide counter

      end;


      if i <= SCScanUpload1Count then
      begin // Real Copy Do
        N_Dump2Str( format( 'SC> CopyTaskScanFiles >> File %s is already copied', [F.Name] ) );
        goto ContLoop;
      end;


      N_T1.Start();
      NoCopyErrFlag := CopyFile( PChar(ScannedFile), PChar( SCScanTaskFolder + F.Name ), false );
      N_T1.Stop();
//      CopyFilesFlag := CopyFilesFlag or NoCopyErrFlag;
      if not NoCopyErrFlag then
      begin
        N_Dump1Str( format( 'SC> CopyTaskScanFiles >> File %s copy Error', [F.Name] ) );
//        Dec(i); // Decrement Slides Counter;
        goto FinLoop;
      end
      else
        N_Dump2Str( 'SC> CopyTaskScanFiles >> ' +
            K_CMScanGetFileCopyReport( F.Name, F.Size, N_T1 ) );

ContLoop:

    until FindNext( F ) <> 0; // End of Files Upload Loop
    SCScanUpload1Count := i; // All Results are copied

  end; // if FindFirst( SCScanTaskLocFolder + '*.*', faAnyFile, F ) = 0 then

FinLoop:
  FindClose( F );
end; // function  TK_FormCMScan.SCCopyTaskScanFiles

//************************************* TK_FormCMScan.SCRemoveTaskLocFolder ***
// Remove Task Local Folder
//
//
// AUnconditionalRemove - =TRUE if unconditional Remove is needed
//
procedure TK_FormCMScan.SCRemoveTaskLocFolder( AUnconditionalRemove : Boolean = FALSE );
begin
// Remove Local Folder
  if (K_SCLocalFilesStorageThreshold > 0) and not AUnconditionalRemove then
    N_Dump2Str( 'SC> Local Scan results are leaved' )
  else
    K_CMScanRemoveTask( 'SC> Local >>', K_SCGetTaskRSFileName( SCScanTaskLocRFile, 'S' ),
                        SCScanTaskLocRFile, SCScanTaskLocFolder, K_CMEDAccess.TmpStrings,
                        N_T1, N_Dump1Str, N_Dump2Str );
end; // procedure TK_FormCMScan.SCRemoveTaskLocFolder;

//************************************** TK_FormCMScan.SCSetTaskIsDoneState ***
// Set Task IsDone State
//
function TK_FormCMScan.SCSetTaskIsDoneState( ASLidesCount : Integer ) : Boolean;
var
  UpdateRFileInfo : string;
begin
// Add DevicePlatesInfo to Upload r-file
  SCDevicePlatesInfoToUpload();

  SCRTask.Values['IsDone'] := 'TRUE';
  SCRTask.Values['ScanCount'] := IntToStr( ASLidesCount );
  UpdateRFileInfo := SCUpdateTextFile( SCRTask, SCScanTaskRFile );
  Result := UpdateRFileInfo <> '';
  if not Result then
    UpdateRFileInfo := ' update error ' + SCScanTaskRFile;
  N_Dump1Str( format( 'SC> Fin Scan Count=%d Task R-file=%s',
                      [SCScanCount, UpdateRFileInfo] ) );
end; // procedure TK_FormCMScan.SCSetTaskIsDoneState

//************************************* TK_FormCMScan.SCShowNotReadyMessage ***
// Show Wait Mesage
//
procedure TK_FormCMScan.SCShowNotReadyMessage();
begin
//  if tiMain.Visible then
//  begin
//    tiMain.BalloonTitle := Caption;
//    tiMain.BalloonHint := 'Application is busy now. Please wait...';
//    tiMain.BalloonFlags := bfWarning;
//    tiMain.ShowBalloonHint;
//  end
//  else
    K_CMShowSoftMessageDlg( SCIniCaption + ' is busy now. Please wait ...', mtInformation, 10 );
end; // procedure TK_FormCMScan.SCShowNotReadyMessage

//********************************** TK_FormCMScan.SCConfirmApplicationTerm ***
// Show Wait Mesage
//
function TK_FormCMScan.SCConfirmApplicationTerm( const AMessage : string ) : Boolean;
begin
  Result :=  mrYes = K_CMShowMessageDlg( SCIniCaption + ' is busy now.'#13#10 +
                      ' Are you sure you want to quit the application?',
                      mtConfirmation );

end; // function TK_FormCMScan.SCConfirmApplicationTerm

//******************************************* TK_FormCMScan.SCDumpTaskState ***
// Dump Task State
//
procedure TK_FormCMScan.SCDumpTaskState( const AMessage : string; ATaskState : Integer );
begin
  if ATaskState = 1 then
    N_Dump1Str( format( AMessage + '%s is stoped', [SCScanTaskID] ) )
  else
    N_Dump1Str( format( AMessage + '%s is broken', [SCScanTaskID] ) );
end; // procedure TK_FormCMScan.SCDumpTaskState

//************************************* TK_FormCMScan.SCCheckScanPathChange ***
// Check Scan Path Change
//
procedure TK_FormCMScan.SCCheckScanPathChange();
var
  FScanRedirect : string;
  WScanDataPath : string;
  WScanDataRootFolder : string;
  WTranspFileName : string;
  Res : Integer;
label LExit;
begin
  FScanRedirect := K_CMScanDataPath + K_CMScanPathRedirectFileName;
  if not FileExists( FScanRedirect ) then Exit;

  try
    N_Dump1Str( format( 'SC> SCCheckScanPathChange Start >> %d', [SCScanTimerWaitCount] ) );
    if not SCLoadTextFile( FScanRedirect ) then Exit;
    WScanDataPath := IncludeTrailingPathDelimiter(K_CMEDAccess.TmpStrings[0]);

//    if (WScanDataPath = K_CMScanDataPath) or
    if K_CMEDAccess.EDACheckFoldersEquality( WScanDataPath, K_CMScanDataPath ) or
       not DirectoryExists( WScanDataPath ) then
    begin
      if SCScanRedirectErrCount = 0 then
        SCScanRedirectErrCount := SCScanTimerWaitCount;
      if ((SCScanRedirectErrCount - SCScanTimerWaitCount) mod 300) = 0 then  // Show each 10 min
        K_CMShowMessageDlg( 'Wrong new data exchange folder '#13#10 + WScanDataPath,
                             mtWarning );
      Exit;
    end;

    SCScanRedirectErrCount := 0;
    N_Dump1Str( 'SC> Try to change ScanDataPath' );
//    SCInitTaskIsDone := TRUE;

    // Clear Scan Data Before Move to new Folder
//    SCClearScanTasks( FALSE );
    SCClearScanTasks( TRUE ); // Remove Terminated Only

    // Set Transp to new folder state
    SCScanChangePathState := SCScanState;
    SCScanState := K_SCSSMoveToNewPath;
    if not SCUpdateScanState() then goto LExit;

    // Create Client Root Folder at new position
    WScanDataRootFolder := WScanDataPath + K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName + '\';
    if not K_ForceDirPath( WScanDataRootFolder ) then
    begin
      N_Dump1Str( format( 'SC> ForceDirPath Error >> %s', [WScanDataRootFolder] ) );
      goto LExit;
    end;

    // Write TranspFlag File to new path
    WTranspFileName := WScanDataPath + K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName + '.~';
    Res := K_CopyFile( WTranspFileName, SCTranspFileName );
    if Res <> 0 then
    begin
      N_Dump1Str( format( 'SC> TranspFile to %s Copy Error=%d', [SCTranspFileName,Res] ) );
      goto LExit;
//      Exit;
    end;
    SCTranspFileName := WTranspFileName;

    // Copy Client Root Folder Files
    if not K_CopyFolderFiles( SCScanRootFolder, WScanDataRootFolder ) then
    begin
      N_Dump1Str( format( 'SC> ScanRootFolder Copy Error >> %s', [WScanDataRootFolder] ) );
      goto LExit;
//      Exit;
    end;
    SCScanRootFolderOld := SCScanRootFolder; // Store Old RootFolder to

    // Store New Path
    WScanDataPath := K_OptimizePath( WScanDataPath );
    N_StringToMemIni( 'CMSMain', 'ScanDataPath', WScanDataPath );
    N_StringToMemIni( 'CMSMain', 'ScanDataPathOld', K_CMScanDataPath );
    K_CMEDAMemIniToExtIniFiles();

    // Swith memory path context to new
    N_Dump1Str( format( 'SC> AutoChange ScanDataPath %s >> %s', [K_CMScanDataPath,WScanDataPath] ) );
    K_CMScanDataPath := WScanDataPath;

    SCInitScanPathsContext();
    SCScanNewTaskNameFileDate := 0;
    SCScanNewTaskNameFileErrCount := 0;

    // Delete Old Path Files
    SCClearScanRootFolderOld( );

LExit: // ******
    SCScanState := SCScanChangePathState;
  except
    on E: Exception do
    begin
      N_Dump1Str( 'SC> Info File Error >> ' + E.Message  );
    end;
  end;

end; // procedure TK_FormCMScan.SCCheckScanPathChange

//***************************************** TK_FormCMScan.SCUpdateScanState ***
// Update Scan State file
//
function TK_FormCMScan.SCUpdateScanState() : Boolean;
var
  WStr : string;
begin
  Result := TRUE;
  if (K_CMScanDataPath = '') or
     not SCDataPathExists    or
     (SCNetworkSlowShift >= 10) then Exit;

  if ( (SCScanPrevState <> SCScanState)    or
       ((SCScanTimerWaitCount mod 60) = 0) or
       not FileExists(SCScanStateFile) ) then
  begin
  // Update Scan State File

    Result := K_ForceDirPath( SCScanRootFolder );
    if not Result then Exit;

    case SCScanState of
    K_SCSSMoveToNewPath : WStr := 'TRANSP';
    K_SCSSWait          : WStr := 'WAIT';
    K_SCSSSetup         : WStr := 'SETUP';
    K_SCSSDoTask        : WStr := 'DO ' + SCScanTaskID;
     else
     WStr := 'WAIT';
    end;

    K_CMEDAccess.TmpStrings.Text := WStr;
    Result := K_VFSaveStrings( K_CMEDAccess.TmpStrings, SCScanStateFile, K_DFCreatePlain );
    if not Result then Exit;
    SCScanPrevState := SCScanState;
    WStr := SCUpdateTextFile( K_CMEDAccess.TmpStrings, SCScanStateFile );
    if WStr <> '' then // OK
    begin
      N_Dump2Str( 'SC> SCUpdateScanState =' + WStr );
      SCScanPrevState := SCScanState;
    end
    else              // Write Error
      N_Dump1Str( 'SC> SCUpdateScanState error' );
  end; // if SCScanPrevState <> SCScanState then


end; // procedure TK_FormCMScan.SCUpdateScanState

//****************************************** TK_FormCMScan.SCClearScanTasks ***
// Clear Scan Tasks
//
procedure TK_FormCMScan.SCClearScanTasks( AProcessTerminatedOnly : Boolean );
var
  i : Integer;
  CurSFile, CurRFile : string;
  ProcTaskDate : TDateTime;
  ScanListReport : string;
  TaskState : string;
begin
  N_Dump1Str( format( 'SC> SCClearScanTasks start TC=%d', [SCScanTimerWaitCount] ) );
  SCGetScanTaskFilesList();
  ScanListReport := N_T1.ToStr();

  for i := 0 to SCSL.Count - 1 do
  begin
  // Scan Tasks Loop
    CurSFile := SCSL[i];
    if not SCLoadTextFile( CurSFile ) then Exit; // If Network porblems then Process Clear Loop next time
    N_Dump2Str( 'Read Task=' + K_CMScanGetFileCopyReport( ExtractFileName( CurSFile ),
                (Length(K_CMEDAccess.TmpStrings.Text) + 1), N_T1 ) );
    ProcTaskDate := K_GetFileAge( CurSFile );
    CurRFile := K_SCGetTaskRSFileName( CurSFile, 'R' );
    TaskState := K_CMEDAccess.TmpStrings.Values['IsTerm'];

    if N_S2B( TaskState ) or
      (K_CMEDAccess.TmpStrings.IndexOf( '[WebAttrs]' ) >= 0) then
    begin // Task is terminated by CMSuite or TrueWeb Task
    // remove task
      SCRemoveTask( CurSFile );
      if ProcTaskDate > SCScanTaskDate then
        SCScanTaskDate := ProcTaskDate;
    end
    else
    if not AProcessTerminatedOnly and
       (SCScanTaskSFilePrev <> CurSFile) then // precaution - skip process last Task
    begin // Close Existing Task
      if TaskState <> K_CMScanTaskIsStopped then  // Skip Stoped Tasks
      begin
        if FileExists( CurRFile ) then
        begin // Set Existing
          if SCLoadTextFile( CurRFile ) and
             (K_CMEDAccess.TmpStrings.Values['IsDone'] <> 'TRUE') then
          begin
//            // Add DevicePlatesInfo to Upload r-file
//            SCDevicePlatesInfoToUpload();

            K_CMEDAccess.TmpStrings.Values['IsDone'] := 'TRUE';
            N_Dump1Str( format( 'SC> Set Task finished state Count=%s to R-file=%s',
                [K_CMEDAccess.TmpStrings.Values['ScanCount'],
                 K_CMScanGetFileCopyReport( ExtractFileName( CurSFile ),
                (Length(K_CMEDAccess.TmpStrings.Text) + 1), N_T1 )] ) );
          end
          else
            CurRFile := '';

        end  // if FileExists( CurRFile ) then
        else
        begin // Create New
//          // Add DevicePlatesInfo to Upload r-file
//          SCDevicePlatesInfoToUpload();

          N_Dump1Str( 'SC> Create Task R-file=' + ExtractFileName(CurRFile) );
          K_CMEDAccess.TmpStrings.Text := 'IsDone=TRUE'#13#10'ScanCount=0';
        end;

        if CurRFile <> '' then
          N_Dump2Str( 'SC> Write R-file=' +
                       SCUpdateTextFile( K_CMEDAccess.TmpStrings, CurRFile ) );
      end; // if TaskState <> K_CMScanTaskIsStoped then

      if ProcTaskDate > SCScanTaskDate then
        SCScanTaskDate := ProcTaskDate;
    end; // if not AOnlyRemove then
  end; // for i := 0 to SCSL.Count - 1 do

  N_Dump2Str( format( 'SC> SCClearScanTasks fin ListCount=%d ListTime=%s NTNTime=%s',
              [SCSL.Count, ScanListReport,
               K_DateTimeToStr( SCScanNewTaskNameFileDate, 'dd-hh:nn:ss.zzz' )] ) );

end; // procedure TK_FormCMScan.SCClearScanTasks

//*************************************** TK_FormCMScan.SCClearScanLocTasks ***
// Clear Scan Local Tasks
//
procedure TK_FormCMScan.SCClearScanLocTasks( );
var
  i, TaskCount, TaskUCount, j : Integer;
  CurSFile, CurRFile, CurAFile : string;
  ScanListReport : string;
  MinName, MinDate, CurDate, CurScanTaskFolder : string;
  RemoveTaskAll, SaveTaskSFile : Boolean;
begin
  N_Dump1Str( 'SC> SCClearScanLocTasks start' );
//  N_Dump1Str( 'SC> SCClearScanLocalTasks start' );
  K_CMEDAccess.TmpStrings.Clear;
  N_T1.Start();
  K_ScanFilesTree( SCScanRootLocFolder, SCScanFilesTreeSelectFile, 'S???????????????.txt' );
  N_T1.Stop();
  ScanListReport := N_T1.ToStr();
  if SCSL = nil then SCSL := TStringList.Create;
  SCSL.Sorted := FALSE;
  SCSL.Assign( K_CMEDAccess.TmpStrings );
  SCSL.Sort();

//  N_Dump1Str( 'SC> SCClearScanLocTasks start' );
  MinName := 'S' + K_DateTimeToStr( Now() - K_SCLocalFilesStorageThreshold, 'yymmddhhnnsszzz' ) + '.txt';
  MinDate := Copy( MinName, 2, 12 );
  for i := 0 to SCSL.Count - 1 do
  begin
  // Scan Tasks Loop
    CurSFile := SCSL[i];

    if not SCLoadTextFile( CurSFile ) then Continue;

    CurScanTaskFolder := K_SCGetTaskFolderName(CurSFile);
    CurRFile := K_SCGetTaskRSFileName( CurSFile, 'R' );
    RemoveTaskAll := (K_SCLocalFilesStorageThreshold = 0) or
                     (K_CMEDAccess.TmpStrings.Values['Remove'] <> '');

    if not RemoveTaskAll then
    begin
      if K_CMEDAccess.TmpStrings.Values['CurPatID'] <> '' then // Online Scans
        RemoveTaskAll := MinName >= ExtractFileName(CurSFile)
      else
      begin // Offline scans - Check Files Remove
        SCSTask.Assign( K_CMEDAccess.TmpStrings );
        if not SCLoadTextFile( CurRFile ) then Continue;
        TaskCount := StrToIntDef( K_CMEDAccess.TmpStrings.Values['ScanCount'], -1 );
        if TaskCount = -1 then N_Dump1Str( 'SC> SCClearScanLocTasks ScanCount=' + K_CMEDAccess.TmpStrings.Values['ScanCount'] );
        // Files Loop
        TaskUCount := 0;
        SaveTaskSFile := FALSE;
        for j := SCSTask.Count - 1 downto  0 do
        begin
          CurAFile := SCSTask[j];
          if CurAFile[1] <> 'F' then break; // End Of Loop

          if (CurAFile[Length(CurAFile)] = '*') and
             (CurAFile[Length(CurAFile)-1] = '*') then
          begin // is marked as removed
            Inc(TaskUCount);
            Continue;
          end;

          CurDate := Copy( SCSTask.ValueFromIndex[j], 1, 12 );
          if MinDate >= CurDate then
          begin // this files should be removed
            K_CMEDAccess.TmpStrings.Clear;
            K_DeleteFolderFilesEx( CurScanTaskFolder, K_CMEDAccess.TmpStrings,
                                   SCSTask.Names[j] + '*', [] );
            if K_CMEDAccess.TmpStrings.Count <> 0 then
            begin
              N_Dump1Str( 'SC> Local >> RemoveTask >> Result Files Delete Errors:'#13#10 + K_CMEDAccess.TmpStrings.Text );
            end
            else
            begin
              SCSTask[j] := CurAFile + '**'; // mark as removed
              SaveTaskSFile := TRUE;
              Inc(TaskUCount);
            end;
          end;
        end; // for j := SCSTask.Count - 1 to  0 do

        if SaveTaskSFile then
          SCUpdateTaskLocFile( CurSFile, SCSTask );

        RemoveTaskAll := TaskCount = TaskUCount; // All Files are removed - remove task
      end; // Offline scans - Check Files Remove
    end; // if not RemoveTaskAll then

    if RemoveTaskAll then  // Local Task should be removed from storage
      K_CMScanRemoveTask( 'SC> Local >>', CurSFile, CurRFile,
                          CurScanTaskFolder, K_CMEDAccess.TmpStrings,
                          N_T1, N_Dump1Str, N_Dump2Str );
{
    if (K_SCLocalFilesStorageThreshold > 0)            and
       (K_CMEDAccess.TmpStrings.Values['Remove'] = '') and
       (MinName < ExtractFileName(CurSFile) ) then
      Continue; // Local Task should be leaved in storage

    // Local Task should be removed from storage
    K_CMScanRemoveTask( 'SC> Local >>', CurSFile,
                        K_SCGetTaskRSFileName( CurSFile, 'R' ),
                        K_SCGetTaskFolderName(CurSFile), K_CMEDAccess.TmpStrings,
                        N_T1, N_Dump1Str, N_Dump2Str );
}
  end; // for i := 0 to SCSL.Count - 1 do

  N_Dump2Str( format( 'SC> SCClearScanLocTasks fin ListCount=%d ListTime=%s',
              [SCSL.Count, ScanListReport] ) );

end; // procedure TK_FormCMScan.SCClearScanLocTasks

//************************************ TK_FormCMScan.SCGetScanTaskFilesList ***
// Get Scan Tasks Files
//
procedure TK_FormCMScan.SCGetScanTaskFilesList();
begin
  K_CMEDAccess.TmpStrings.Clear;
  N_T1.Start();
  K_ScanFilesTree( SCScanRootFolder, SCScanFilesTreeSelectFile, 'S???????????????.txt' );
  N_T1.Stop();
  if SCSL = nil then SCSL := TStringList.Create;
  SCSL.Sorted := FALSE;
  SCSL.Assign( K_CMEDAccess.TmpStrings );
  SCSL.Sort();
end; // procedure TK_FormCMScan.SCGetScanTaskFilesList

//****************************************** TK_FormCMScan.LoadScanTaskFile ***
// Load Text File to K_CMEDAccess.TmpStrings
//
//    Parameters
//  AFileName - file name to load
//  Result - Returns TRUE if success
//
function TK_FormCMScan.SCLoadTextFile( const AFileName : string ) : Boolean;
var
  ErrStr : string;
  ErrCode : Integer;

begin
  N_T1.Start();
  ErrStr := K_VFLoadStrings1( AFileName, K_CMEDAccess.TmpStrings, ErrCode );
  N_T1.Stop();
  Result := ErrStr = '';
  if Result then Exit;
  N_Dump1Str( 'SC> Load Error >> ' + AFileName + #13#10'>>' + ErrStr );
end; // function TK_FormCMScan.SCLoadTextFile

//********************************************** TK_FormCMScan.SCRemoveTask ***
// Remove Task given by S-file
//
//    Parameters
//  ASFileName - task S-file name
//  Result - Returns TRUE on success
//
procedure TK_FormCMScan.SCRemoveTask( const ASFileName : string );
begin
  N_Dump1Str( 'SC> Add Task to Remove List >> ' + ASFileName );
  SCScanDataUploadThread.SCUAddRemoveTask( ASFileName );
end; // procedure TK_FormCMScan.SCRemoveTask

//******************************************** TK_FormCMScan.SCCheckNewTask ***
// Check New Task
//
//    Parameters
//  ASFileName - task S-file name
//
procedure TK_FormCMScan.SCCheckNewTask();
var
  SFile : string;
  NewTaskNameFileDate : TDateTime;
  NewTaskDate : TDateTime;
  UseTasksList : Boolean;
  TaskState : string;
  TaskFileLength : Integer;
  i, Ind, CInd : Integer;
  WStr, WSVal, WSDT : string;
  WSaveFlag : Boolean;
begin

  N_Dump2Str( 'SC> CheckNewTask start' );

  SFile := '';
  N_T1.Start();
//  NewTaskNameFileDate := L_GetFileAge( SCScanNewTaskNameFile );           ////Igor 08092019
  NewTaskNameFileDate := K_GetFileAgeDAV( SCScanNewTaskNameFile );           ////Alex 25012020
  N_T1.Stop();

  SCCheckNewTasksListTime := N_T1.ToStr() + '+';
  if SCScanNewTaskNameFileDate < NewTaskNameFileDate then
  begin // Process New Task Name File
    N_Dump2Str( format( 'SC> NewTaskNameFile=%s Age=%s GetTime=%s',
                     [K_CMScanCurTaskInfoFileName,
                      K_DateTimeToStr( NewTaskNameFileDate, 'dd-hh:nn:ss.zzz' ),
                      N_T1.ToStr()] ) );
    //!!!+++
    DeleteFile(SCScanNewTaskNameFile+'1');
    if RenameFile(SCScanNewTaskNameFile,SCScanNewTaskNameFile+'1') then     ////Igor  08092019
        RenameFile(SCScanNewTaskNameFile+'1',SCScanNewTaskNameFile);
    //!!!---
    // Load New Task Name File
    if not SCLoadTextFile( SCScanNewTaskNameFile ) then
    begin // Load  Error
      Inc(SCScanNewTaskNameFileErrCount);
      if (SCScanNewTaskNameFileErrCount mod K_SCUScanMaxWANErrCount) = 0 then
        N_Dump1Str( 'SC> NewTaskNameFile Load Error >> ' + SCScanNewTaskNameFile );
    end
    else
    begin // Load OK - set new task file name
      SCCheckNewTasksListTime := SCCheckNewTasksListTime + N_T1.ToStr();
      if K_CMEDAccess.TmpStrings.Count = 0 then
      begin // Empty Task File Name detected
        N_Dump2Str( format( 'SC> Load Empty NewTaskNameFile >> %s ',
                     [K_CMScanGetFileCopyReport( K_CMScanCurTaskInfoFileName,
                      0, N_T1 )] ) );
        SCScanNewTaskNameFileDate := NewTaskNameFileDate;
        Exit;
      end;
      SFile := K_CMEDAccess.TmpStrings[0];
      N_Dump2Str( format( 'SC> Load NewTaskNameFile %s >> %s ', [SFile,
                   K_CMScanGetFileCopyReport( K_CMScanCurTaskInfoFileName,
                  (Length(K_CMEDAccess.TmpStrings.Text) + 1), N_T1 )] ) );
      SCScanNewTaskNameFileErrCount := 0;
      SFile := SCScanRootFolder + SFile;
    end;
  end; // if SCScanNewTaskNameFileDate < NewTaskDate then

  UseTasksList := FALSE;
  if SFile = '' then
  begin  // Get File Name From
//    if SCScanNewTaskNameFileDate <> 0 then Exit; // SCScanNewTaskNameFileDate is used for check Tasks List is not needed
    if NewTaskNameFileDate <> 0 then Exit; // if SCScanNewTaskNameFile exists then Tasks List check is not needed
    UseTasksList := TRUE;
    SCGetScanTaskFilesList();
    SCCheckNewTasksListTime := N_T1.ToStr();
    if SCSL.Count = 0 then Exit;
    SFile := SCSL[SCSL.Count-1]; // Use Last S-file from All S-files list
  end;

  N_T1.Start();
  NewTaskDate := K_GetFileAge(SFile);
  N_T1.Stop();

  if SCScanTaskDate >= NewTaskDate then
  begin
    if not UseTasksList then // dump only if ScanCurTaskInfoFile is used
      N_Dump2Str( format( 'SC> !!!Old S-File=%s Age=%s GetTime=%s',
                     [SFile,
                      K_DateTimeToStr( NewTaskDate, 'dd-hh:nn:ss.zzz' ),
                      N_T1.ToStr()] ) );
    SCScanNewTaskNameFileDate := NewTaskNameFileDate;
    Exit; // Too old Task File
  end;

  // Porcess New Task S-file
  N_Dump2Str( format( 'SC> Start S-File=%s Age=%s GetTime=%s',
                     [SFile,
                      K_DateTimeToStr( NewTaskDate, 'dd-hh:nn:ss.zzz' ),
                      N_T1.ToStr()] ) );

  // Load Task S-file
  if not SCLoadTextFile( SFile ) then
  begin  // Load Task S-file Error
    Inc(SCScanTaskErrCount);
    if SCScanTaskErrCount > K_SCUScanMaxWANErrCount then
    begin
      N_Dump1Str( 'SC> Task Load Error >> ' + SFile );
      K_CMShowMessageDlg( 'Current Task Load error. Task will be ignored.'#13#10 +
                          '          Press OK to continue.', mtWarning );
      SCScanTaskDate := NewTaskDate; // Skip Bad Task - Set New Task Date
      SCScanNewTaskNameFileDate := NewTaskNameFileDate;
//      raise Exception.Create( 'Error load task file ' + SFile );
    end;
    Exit;
  end
  else // Dump Load Task S-file Report
  begin
    TaskFileLength := Length(K_CMEDAccess.TmpStrings.Text) + 1;
    N_Dump2Str( 'SC> Load S-File ' + K_CMScanGetFileCopyReport( ExtractFileName( SFile ),
                     TaskFileLength, N_T1 ) );
  end;


  SCScanTaskErrCount := 0;
  SCSTask.Assign(K_CMEDAccess.TmpStrings);
  SCTWTaskFlag := SCSTask.IndexOf( '[WebAttrs]' ) >= 0;
  if SCTWTaskFlag then
  begin
    N_Dump2Str( 'SC> Strat TrueWeb Task >> ' + SFile );
    with K_DCMSCWEBGLib do    // SDLSendImageTo
    begin
      SDLLogFileName := ExtractFilePath(N_LogChannels[N_Dump2LCInd].LCFullFName) + 'cmsscweblog.txt';
// enum LogLevel   OFF_LOG_LEVEL = 60000, FATAL_LOG_LEVEL = 50000, ERROR_LOG_LEVEL = 40000,
//                 WARN_LOG_LEVEL = 30000, INFO_LOG_LEVEL = 20000, DEBUG_LOG_LEVEL = 10000,
//                 TRACE_LOG_LEVEL = 0
      SDLLogLevel    := 20000; //
      SDLInitAll();
{deb code
      SDLSendImageTo := WSDLSendImageTo;
{}
    end;
  end;

  // Check Task
  TaskState := SCSTask.Values['IsTerm'];
  if (SCSTask.Count = 0) or (TaskState = '') then
  begin // Task is Empty
    N_Dump1Str( 'SC> Task is empty !!! >> ' + SFile );
    if SCScanTaskSFileEmpty = SFile then
      Inc(SCScanTaskSFileEmptyCount)
    else
      SCScanTaskSFileEmptyCount := 0;

    if SCScanTaskSFileEmptyCount > 5 then
    begin
      SCScanTaskDate := NewTaskDate; // Shift New Task Date
      SCScanNewTaskNameFileDate := NewTaskNameFileDate;
      SCRemoveTask( SFile );
    end;
    Exit;
  end
  else
  if N_S2B( TaskState ) then
  begin // Task is terminated by CMSuite
    N_Dump1Str( 'SC> Task is terminated !!! >> ' + SFile );
    SCScanTaskDate := NewTaskDate; // Shift New Task Date
    SCScanNewTaskNameFileDate := NewTaskNameFileDate;
    SCRemoveTask( SFile );
    Exit;
  end;

  SCScanTaskDate := NewTaskDate; // Shift New Task Date
  SCScanNewTaskNameFileDate := NewTaskNameFileDate;

  if TaskState = K_CMScanTaskIsStopped then
  begin // Task is stoped by CMSuite
    N_Dump1Str( 'SC> Task is stopped !!! >> ' + SFile );
    Exit;
  end;

  // Get version before New Task start if it was not defined earlier
  if SCScanDataVersion < 0 then
    SCCloseByCMSVersion := not SCCheckVersion();

  // Check ScanDataVersion
  if ((SCScanDataVersion >= 0) and (SCScanDataVersion <> K_CMScanDataVersion)) or
     SCCloseByCMSVersion then
  begin
    N_Dump1Str( 'SC> Wrong ScanDataVersion  or >> Set R-File IsDone Error >> ' + SFile );
    SCShowScanDataVerWarninig( TRUE );
    // Finish Task by R-file and Exit
    SFile[Length(SFile)-19] := 'R';
    if not K_VFSaveText( 'IsDone=TRUE'#13#10'ScanCount=0', SFile, K_DFCreatePlain ) then
      N_Dump1Str( 'SC> Wrong ScanDataVersion >> Set R-File IsDone Error >> ' + SFile );
    Exit;
  end; // if ((SCScanDataVersion >= 0) and (SCScanDataVersion <> K_CMScanDataVersion)) or SCCloseByCMSVersion then

  // Set CMS Current Context by Task Info
  K_CMEDAccess.CurPatID  := StrToIntDef( SCSTask.Values['CurPatID'], -1 );
  K_CMEDAccess.CurProvID := StrToIntDef( SCSTask.Values['CurProvID'], -1 );
  K_CMEDAccess.CurLocID  := StrToIntDef( SCSTask.Values['CurLocID'], -1 );
  SCScanTaskPatName := format( '%s %s',
        [SCSTask.Values['PatientSurname'],SCSTask.Values['PatientFirstName']] );
  if Trim(SCScanTaskPatName) = '' then
    SCScanTaskPatName := format( 'Px. ID %s',[SCSTask.Values['CurPatID']] );

 // Prepare Task Files Names
  SCScanTaskID := Copy( SFile, Length(SFile) - 18, 15 );
  SCScanTaskSFile  := SFile;
  SCScanTaskSFilePrev := SFile;

  SCScanTaskRFile  := SFile;
  SCScanTaskRFile[Length(SFile)-19] := 'R';

  SCScanTaskFolder := SFile;
  SCScanTaskFolder[Length(SFile)-19] := 'F';
  SCScanTaskFolder := Copy( SCScanTaskFolder, 1, Length(SCScanTaskFolder) - 3 );
  SCScanTaskFolder[Length(SCScanTaskFolder)] := '\';
  if SCCMSScanDataPath <> '' then
  begin // Use path from CMSuite for CMS ver >= 3.059.64
    SCCMSScanTaskFolder := SCCMSScanDataPath +
       Copy( SCScanTaskFolder, Length(K_CMScanDataPath) + 1, Length(SCScanTaskFolder) );
  end
  else  // Use path from CMSuite for CMS ver < 3.059.64
    SCCMSScanTaskFolder := SCScanTaskFolder;

/////////////////////////////////////
// Init Task Device Plates Use Context
  SCDevicePlatesTotalCount  := 0;
  SCDevicePlatesClientCount := 0;
  SCDevicePlatesClientInd := -1;
  SCDevicePlateCurID := '';
  SCDevicePlatesTotalUse.Clear;
  Ind := SCSTask.IndexOf( '[DevicePlatesTotal]' );
  if Ind >= 0 then
  begin
  // Fill SCDevicePlatesTotalUse
    for i := Ind + 1 to SCSTask.Count - 1 do
    begin
      WStr := SCSTask[i];
      if WStr = '' then
      begin
        break;
      end;
      SCDevicePlatesTotalUse.Add( WStr );
    end;
    N_Dump2Str('DevicePlatesTotal:');
    N_Dump2Strings( SCDevicePlatesTotalUse, 3 );
  end;

  K_CMEDAccess.TmpStrings.Clear;
  Ind := SCSTask.IndexOf( '[DevicePlatesClient]' );
  if Ind >= 0 then
  begin
  // Load CMSuite DevicePlatesClient to TmpStrings
    for i := Ind + 1 to SCSTask.Count - 1 do
    begin
      WStr := SCSTask[i];
      if WStr = '' then break;
      K_CMEDAccess.TmpStrings.Add( WStr );
    end;
    N_Dump2Str('DevicePlatesClient:');
    N_Dump2Strings( K_CMEDAccess.TmpStrings, 3 );
  end;

  if K_CMEDAccess.TmpStrings.Count > 0 then
  begin
  // Clear Local DevicePlatesClient
    if SCDevicePlatesClientUse.Count > 0 then
    begin
      N_Dump2Str('DevicePlatesClientUse before:');
      N_Dump2Strings( SCDevicePlatesClientUse, 3 );
    end;

    WSaveFlag := FALSE;
    for i := SCDevicePlatesClientUse.Count - 1 downto 0 do
    begin
      WStr := SCDevicePlatesClientUse.Names[i];
      WSVal := SCDevicePlatesClientUse.ValueFromIndex[i];
      Ind := K_CMEDAccess.TmpStrings.IndexOfName( WStr );
      if Ind < 0 then Continue;
      // Check Value
      CInd := Pos( '|', WSVal );
      if CInd = 0 then Continue;
      WSDT := Copy( WSVal, CInd + 1, 14 );
      if WSDT > K_CMEDAccess.TmpStrings.ValueFromIndex[Ind] then Continue;
      SCDevicePlatesClientUse.Delete(i);
      WSaveFlag := TRUE;
    end;

    if WSaveFlag then
    begin
      N_Dump2Str('DevicePlatesClientUse after:');
      if SCDevicePlatesClientUse.Count > 0 then
        N_Dump2Strings( SCDevicePlatesClientUse, 3 );

      SCDevicePlatesInfoToMemIni();
      SCScanCurSave();
    end;
  end; // if K_CMEDAccess.TmpStrings.Count > 0 then

{ // debug code
  SCDevicePlatesClientUse.Text :=
  '4=2|20190918120000'#13#10'3=2|20190901120000';
{}

// Init Task Device Plates Use Context
/////////////////////////////////////

  SCScanState := K_SCSSDoTask;
  SCCaptureIsStarted := FALSE;

  N_Dump1Str( format( 'SC> Start Pat=%d Prov=%d Task=%s TC=%d ServCompName=%s',
                      [K_CMEDAccess.CurPatID,K_CMEDAccess.CurProvID,
                       K_CMScanGetFileCopyReport( SCScanTaskID,
                       TaskFileLength, N_T1 ),
                       SCScanTimerWaitCount,
                       SCSTask.Values['ServCompName']] ) );
//    Self.FormStyle := fsStayOnTop;
  if SCUIStayOnTopCapt then
    N_BaseFormStayOnTop := 2;

//////////////////////////////////////////////////////////////////////////
// new additional code to prevent hide CMScan under RemoteDescktop window
  ShowWindow( Self.Handle, SW_SHOWMINIMIZED );
  ShowWindow( Self.Handle, SW_SHOWNORMAL );
// Self.Show() down is needed for OnShow code run
//////////////////////////////////////////////////////////////////////////
  Self.Show();
//  Self.FormDeactivate( nil ); // for

//  SCModifyTrayIconTip( Self.Caption + SCTrayAddCaption );
  if SCTrayAddCaption <> '' then
    SCModifyTrayIconTip( SCTrayAddCaption )
  else
    SCModifyTrayIconTip( Self.Caption );

end; // procedure TK_FormCMScan.SCCheckNewTask

//************************************ TK_FormCMScan.SCCheckTaskBrokenState ***
// Check Task Broken State
//
//    Parameters
//  AUCheck - if TRUE then unconditional check is done, if FALSE check is done
//            only if Scan results are not buffered in local folder
//  Result  - Returns 0 - is not broken, 1 - is stoped, 2 - is broken now
//
function TK_FormCMScan.SCCheckTaskBrokenState( AUCheck : Boolean ) : Integer;
var
  NewTaskDate : TDateTime;
  TermState : string;
label TryAgain;
begin

TryAgain:
  Result := 2;
  TermState := SCSTask.Values['IsTerm'];
  if N_S2B( TermState ) then Exit;

  Result := 1;
  if not AUCheck and (TermState = K_CMScanTaskIsStopped) then Exit;

  Result := 0;
  if not AUCheck then Exit;

  NewTaskDate := K_GetFileAge(SCScanTaskSFile);
  if NewTaskDate > SCScanTaskDate then
  begin
    // Update by File State
    if SCLoadTextFile( SCScanTaskSFile ) then
    begin
      // Get Task New State and Return
      SCScanTaskDate := NewTaskDate;
      SCSTask[0] := K_CMEDAccess.TmpStrings[0];
    end;
  end; // if NewTaskDate > SCScanTaskDate then

  // goto Set New Results code
  AUCheck := FALSE;
  goto TryAgain;

end; // procedure TK_FormCMScan.SCCheckTaskBrokenState

//*************************************** TK_FormCMScan.SCModifyTrayIconTip ***
// Modify Tray Icon
//
procedure TK_FormCMScan.SCModifyTrayIconTip( const AInfo : string; ShowBalloon: Boolean = False; BalloonKind: TBalloonFlags = bfInfo);
{
var
  TipL : Integer;
}
begin
 // Modify Scanner Tray Icon
  N_T1.Start();

  tiMain.Hint := AInfo;

//  if ShowBalloon and
//     not (SameText(AInfo, Self.Caption)) then
//  begin
//    tiMain.BalloonTitle := Self.Caption;
//    tiMain.BalloonHint := AInfo;
//    tiMain.BalloonFlags := BalloonKind;
//
//    tiMain.ShowBalloonHint;
//  end;

  N_T1.Stop();
  N_Dump2Str( 'SC> Shell_NotifyIcon Mod Time=' + N_T1.ToStr() + #13#10'>>' + AInfo );
end; // procedure TK_FormCMScan.SCModifyTrayIconTip

//********************************** TK_FormCMScan.SCClearScanRootFolderOld ***
// Clear Old Client Root Folder
//
procedure TK_FormCMScan.SCClearScanRootFolderOld( );
begin

  if DirectoryExists( SCScanRootFolderOld ) then
  begin
  // Delete Old Path Files
    K_DeleteFolderFiles( SCScanRootFolderOld );
    if RemoveDir( SCScanRootFolderOld ) then
    begin
      N_Dump1Str( 'SC> Remove old root folder >> ' + SCScanRootFolderOld );
      SCScanRootFolderOld := '';
    end
    else
      N_Dump1Str( 'SC> Remove old root folder error >> ' + SCScanRootFolderOld );
  end
  else
    SCScanRootFolderOld := '';

  if SCScanRootFolderOld = '' then
  begin
    N_StringToMemIni( 'CMSMain', 'ScanDataPathOld', '' );
    K_CMEDAMemIniToExtIniFiles();
  end;

end; // procedure TK_FormCMScan.SCClearScanRootFolderOld

//*************************************** TK_FormCMScan.SCSelectDataPathDlg ***
// Scan Data Path Select Dialog
//
function TK_FormCMScan.SCSelectDataPathDlg( var ASelPath : string  ) : Boolean;
var
  FScanDataPath : string;

begin
  // Select ScanDataPath
  Result := FALSE;
//      K_SelectFolderNewStyle := TRUE;
//    K_SelectFolder( 'Select CMSuite|CMScan common data root folder', '', ASelPath );
//      K_SelectFolderNewStyle := FALSE;
  with N_CreateEditParamsForm( 550 ) do
  begin
    Caption := 'Select TS Bridge Data Exchange Folder';
    AddPathNameFrame( '', '' );
    Position := poDesktopCenter;
//      Left := Self.Left - 10;
//      Top  := Self.Top + 10;

    Width  := ContrWidth + LeftMargin + RightMargin + 8;
//    Height := CurTop + 67;
    Height := CurTop + 75; // Changed for Windows 10

    N_ChangeFormSize( Self, 0, 0 ); // move Self into Desktop

    SetActiveControl();
    TControl(EPControls[0].CRContr).Anchors := [akLeft,akRight,akTop];
    if ASelPath <> '' then
      TK_FPathNameFrame(EPControls[0].CRContr).AddNameToTop( ASelPath );

    ShowModal();

    if ModalResult = mrOK then
    begin
      FScanDataPath := Trim( EPControls[0].CRStr );
      if FScanDataPath <> ASelPath then
      begin
        ASelPath := K_OptimizePath(FScanDataPath);
        Result := TRUE;
      end;
    end;
  end; // with N_CreateEditParamsForm( 250 ) do
end; // function TK_FormCMScan.SCSelectDataPathDlg

//******************************************** TK_FormCMScan.SCCheckVersion ***
// Check CMScan build version
//
//    Parameters
//  Result - Returns TRUE if CMScan must continue, FALSE if CMScan should be terminated
//
function TK_FormCMScan.SCCheckVersion : Boolean;
var
  AddErrText, CMSBuildNumber, ErrStr : string;
  LaunchProblemsFlag : Boolean;

label LaunchIUApplication, ShowRemindedWarning;
begin
  // Prepare IU Application EXE Path
  if not SCIUIsNotAvailable and (SCIUExeFileName = '') then
  begin
    SCIUExeFileName := N_MemIniToString( 'CMS_UserMain', 'IUApplication', '(#BasePath#)IU\CMScan_IU.exe' );
    SCIUExeFileName := K_ExpandFileName( SCIUExeFileName );
    SCIUIsNotAvailable := not DirectoryExists( ExtractFilePath( SCIUExeFileName ) );
    N_Dump1Str( format('IUApplication=%s IUDir=%s', [SCIUExeFileName, N_B2S(not SCIUIsNotAvailable)])  );
  end;

  // Check CMScan and CMSuite versions mismatching by InfoFile
  Result := TRUE;
  SCScanDataVersion := SCGetInfoFile( FALSE );
  if SCScanDataVersion < 0 then Exit;

  SCScanDataVersion := StrToIntDef( SCInfoStrings.Values['ScanDataVersion'], 0 );
  if SCScanDataVersion <> K_CMScanDataVersion then // CMSuite <-> CMScan data transfer is not available
  begin
    if SCIUIsNotAvailable then // Skip Internet Upgrade
      SCShowScanDataVerWarninig( (SCScanTimerWaitCount mod 600) = 0 )
    else  // if SCIUIsNotAvailable then
    begin // if not SCIUIsNotAvailable then
      AddErrText := format( #13#10'You will be unable to use %s until the upgrade has'#13#10'been completed.',
                               [K_CMMessageDlgDefaultCaption] );
      K_CMShowMessageDlg( // specout
        format( 'It has been detected that your version of %s '#13#10+
                'is not compatible with the version of %s on your Server. '#13#10#13#10 +
                '%s will attempt to launch the upgrade application.%s',
                [K_CMMessageDlgDefaultCaption,
                 K_SCRegSuiteProductName,
                 K_CMMessageDlgDefaultCaption,
                 AddErrText] ),
                mtWarning, [], FALSE,
                'Upgrade ' + K_CMMessageDlgDefaultCaption );
      Result := FALSE; // Set FALSE because CMScan should be finished

LaunchIUApplication: //************

      // Launch IUApplication and Exit;
      LaunchProblemsFlag := not FileExists(SCIUExeFileName);
      if not LaunchProblemsFlag then
      begin
//        LaunchProblemsFlag := not K_RunExeByCmdl(SCIUExeFileName);
        ErrStr := K_RunExe(SCIUExeFileName);
        LaunchProblemsFlag := ErrStr <> '';
        if LaunchProblemsFlag then
          N_Dump1Str( 'IUApplication launch fails >> ' + SCIUExeFileName + ' >> ' + ErrStr );
      end
      else
        N_Dump1Str( 'IUApplication file not found >> ' + SCIUExeFileName );

      if LaunchProblemsFlag then
      begin
        K_CMShowMessageDlg( // specout
          format( '%s was unable to launch the upgrade application.%s'#13#10#13#10 +
                  'Please contact %s'#13#10 +
                  '          using %s'#13#10 +
                  '          or call %s for assistance',
                  [K_CMMessageDlgDefaultCaption,
                   AddErrText,
                   K_SCRegCompanyDistrName,
                   K_SCRegEmail,
                   K_SCRegPhone] ),
                  mtError, [], FALSE,
                 'Unable to launch Upgrade Application' );
        SCScanShowBuildWarning := TRUE;
      end // if LaunchProblemsFlag then
      else
        Result := FALSE; // IU application was launched

      Exit;
    end; // if not SCIUIsNotAvailable then
  end   // if SCScanDataVersion <> K_CMScanDataVersion then // CMSuite <-> CMScan data transfer is not available
  else
  begin // if SCScanDataVersion = K_CMScanDataVersion then // CMSuite <-> CMScan data transfer is available
    if not SCIUIsNotAvailable then
    begin // Check Build Versions and Call IUApplication if needed
  //    if SCIUIsNotAvailable or
  //       (SCScanTimerWaitCount <> 0) then Exit; // Nothing to do - continue CMScan
      CMSBuildNumber := SCInfoStrings.Values['CMSBuildNumber'];
      if (CMSBuildNumber <> N_CMSVersion) and
         (CMSBuildNumber <> N_MemIniToString( 'CMScan', 'IUWarnLastCMSVersion', '' ))  then
      begin
//        if SCScanTimerWaitCount = 0 then  // Check Only on CMScan Start
        if not SCScanShowBuildWarning then  // Show Build Warning only if never show
        begin
          AddErrText := format( #13#10'Press OK to continue use of %s.',
                                   [K_CMMessageDlgDefaultCaption] );
          // Show Warning
          if mrYes = K_CMShowMessageDlg( // specout
            format( 'It has been detected that your version of %s '#13#10+
                    'does not match the version of %s on your Server. Would you like to upgrade now?'#13#10#13#10 +
                    'Press Yes to start the upgrade or press No to continue using %s.',
                    [K_CMMessageDlgDefaultCaption,
                     K_SCRegSuiteProductName,
                     K_CMMessageDlgDefaultCaption] ),
                    mtConfirmation, [], FALSE,
                    'Upgrade ' + K_CMMessageDlgDefaultCaption ) then goto LaunchIUApplication;
                     // Upgrade immediately

          // Confirm Skip Warning
          if mrYes <> K_CMShowMessageDlg( // specout
            'Would you like to be reminded about the update again?',
                    mtConfirmation, [], FALSE,
                    'Upgrade ' + K_CMMessageDlgDefaultCaption ) then  // Store New CMSBuild to prevent Update Warning
            N_StringToMemIni( 'CMScan', 'IUWarnLastCMSVersion', CMSBuildNumber );
        end // if  SCScanTimerWaitCount = 0 then - CMScan start
//        else
//          N_Dump1Str( format( 'CMScanVersion=%s <> CMSuiteVersion=%s', [N_CMSVersion,CMSBuildNumber] ) );

      end; // if CMSBuildNumber <> last stored CMSBuildNumber

    end; // if not SCIUIsNotAvailable

  end;  // if SCScanDataVersion = K_CMScanDataVersion then // CMSuite <-> CMScan data transfer is available
end; // function TK_FormCMScan.SCCheckVersion

//******************************** TK_FormCMScan.SCCheckLocalExchangeFolder ***
// Check Local Exchange Folder Existance
//
procedure TK_FormCMScan.SCCheckLocalExchangeFolder();
begin
  if SCScanLocalExchangeFolder = '' then
    SCScanLocalExchangeFolder := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)))
           + 'Exchange\';
  if DirectoryExists( SCScanLocalExchangeFolder ) then Exit;

  if not K_ForceDirPath( SCScanLocalExchangeFolder ) then
    N_Dump1Str( 'SC> Init Local Exchange Error' );
end; // procedure TK_FormCMScan.SCCheckLocalExchangeFolder

//********************************************* TK_FormCMScan.SCScanCurSave ***
// Check Local Exchange Folder Existance
//
procedure TK_FormCMScan.SCScanCurSave;
var
  WStr : string;
begin
  WStr := N_MemIniToString( 'CMSIniFiles', 'CMScanCur', '' );
  if WStr = '' then Exit;
  K_CMEDAMemIniToExtIniFile( WStr, 'CMScanCur' );
end; // procedure TK_FormCMScan.SCScanCurSave

//****************************** TK_FormCMScan.SCDevicePlatesInfoFromMemIni ***
// Get DevicePlatesInfo from MemIni
//
procedure TK_FormCMScan.SCDevicePlatesInfoFromMemIni;
begin
  N_MemIniToStrings ( 'DevicePlatesClientUse', SCDevicePlatesClientUse );
end; // procedure TK_FormCMScan.SCDevicePlatesInfoFromMemIni

//******************************** TK_FormCMScan.SCDevicePlatesInfoToMemIni ***
// Store DevicePlatesInfo to MemIni
//
procedure TK_FormCMScan.SCDevicePlatesInfoToMemIni;
begin
  N_StringsToMemIni( 'DevicePlatesClientUse', SCDevicePlatesClientUse );
end; // procedure TK_FormCMScan.SCDevicePlatesInfoToMemIni

//******************************** TK_FormCMScan.SCDevicePlatesInfoToUpload ***
// Store DevicePlatesInfo to Upload Thread
//
// Should be done before write to IsDone=TRUE to R-file
// because it is done for TK_SCUScanDataThread object
//
procedure TK_FormCMScan.SCDevicePlatesInfoToUpload;
var
  i : Integer;
  WStr, UpdateDT : string;
begin
  with SCScanDataUploadThread do
  begin
//    if SCScanState <> K_SCSSDoTask then
//    begin
//      Exit;
//    end;

    SCUDevicePlatesClientUse.Clear;
    UpdateDT := K_DateTimeToStr( Now(), 'yyyymmddhhnnss' );
    for i := 0 to SCDevicePlatesClientUse.Count - 1 do
    begin
      WStr := SCDevicePlatesClientUse[i];
      if Pos( '|', WStr ) <> 0 then
        SCUDevicePlatesClientUse.Add(WStr)
      else
      begin
        if WStr[Length(WStr)] = '=' then Continue; // Emty Value Precaution
        SCDevicePlatesClientUse[i] := WStr + '|' + UpdateDT;
        SCUDevicePlatesClientUse.Add( SCDevicePlatesClientUse[i] );
      end;
    end; // for i := 0 to SCDevicePlatesClientUse.Count - 1 do
    N_Dump2Str('SCUDevicePlatesClientUse:');
    N_Dump2Strings( SCUDevicePlatesClientUse, 3 );
  end; // with SCScanDataUploadThread do

  SCDevicePlatesInfoToMemIni();
  SCScanCurSave();
end; // procedure TK_FormCMScan.SCDevicePlatesInfoToUpload

//********************************** TK_FormCMScan.SCDevicePlateResCountGet ***
// Get resulting DevicePlate Counter
//
procedure TK_FormCMScan.SCDevicePlateResCountGet( const APlateName : string );
var
  i, Ind, DInd : Integer;
  WStr : string;

  function AddResCount( AInd : Integer ) : Boolean;
  begin
    WStr := SCDevicePlatesClientUse.ValueFromIndex[AInd];
    DInd := Pos( '|', WStr );
    Result := DInd > 0;
    if not Result then Exit;

    SCDevicePlatesTotalCount := SCDevicePlatesTotalCount +
                                  StrToIntDef( Copy( WStr, 1, DInd - 1), 0 );
    N_Dump2Str( 'SC> SCDevicePlateResCountGet Value+ >> ' + IntToStr(SCDevicePlatesTotalCount) );
  end; // function AddResCount

begin
  N_Dump2Str( 'SC> SCDevicePlateResCountGet start >> ' + APlateName );
  if SCDevicePlateCurID = APlateName then Exit;

  SCDevicePlateCurID := APlateName;
  SCDevicePlatesTotalCount := 0;
  Ind := SCDevicePlatesTotalUse.IndexOfName( APlateName );
  if Ind >= 0 then
    SCDevicePlatesTotalCount := StrToIntDef( SCDevicePlatesTotalUse.ValueFromIndex[Ind], SCDevicePlatesTotalCount );


  N_Dump2Str( 'SC> SCDevicePlateResCountGet Value >> ' + IntToStr(SCDevicePlatesTotalCount) );
  Ind := SCDevicePlatesClientUse.IndexOfName( APlateName );
  if Ind < 0 then Exit; // Current Plate record is absent

  if not AddResCount( Ind ) then Exit;

  // Search in last SCDevicePlatesClientUse elements
  for i := Ind + 1 to SCDevicePlatesClientUse.Count - 1 do
  begin
    if SCDevicePlatesClientUse.Names[i] <> APlateName then Continue;
    if not AddResCount( i ) then break;
  end; // for i := Ind + 1 to SCDevicePlatesClientUse.Count - 1 do
  N_Dump2Str( 'SC> SCDevicePlateResCountGet fin' );

end; // procedure TK_FormCMScan.SCDevicePlateResCountGet

//********************************** TK_FormCMScan.SCDevicePlateCurCountGet ***
// Get current DevicePlate Counter
//
function TK_FormCMScan.SCDevicePlateCurCountGet( const APlateName : string ) : Integer;
var
  i, Ind, DInd : Integer;
  WStr : string;

  function AddClientCount( AInd : Integer ) : Boolean;
  begin
    WStr := SCDevicePlatesClientUse.ValueFromIndex[AInd];
    DInd := Pos( '|', WStr );
    Result := DInd = 0;
    if not Result then Exit;
    SCDevicePlatesClientInd := AInd; // Save Current Ind
    SCDevicePlatesClientCount := StrToIntDef( WStr, 0 );
    N_Dump2Str( 'SC> SCDevicePlateCurCountGet Value >> ' + IntToStr(SCDevicePlatesClientCount) );
  end; // function AddClientCount

begin
  N_Dump2Str( 'SC> SCDevicePlateCurCountGet start >> ' + APlateName );
  Result := SCDevicePlatesClientInd;
  if SCDevicePlatesClientInd >= 0 then Exit;

  SCDevicePlatesClientCount := 0;

  Ind := SCDevicePlatesClientUse.IndexOfName( APlateName );
  Result := Ind;
  if Result < 0 then Exit; // Current Plate record is absent
  if AddClientCount( Ind ) then Exit;

  Result := -1;
  // Search in last SCDevicePlatesClientUse elements
  for i := Ind + 1 to SCDevicePlatesClientUse.Count - 1 do
  begin
    if SCDevicePlatesClientUse.Names[i] <> APlateName then Continue;
    if not AddClientCount( i ) then Continue;
    Result := i;
    break;
  end; // for i := Ind + 1 to SCDevicePlatesClientUse.Count - 1 do
  N_Dump2Str( 'SC> SCDevicePlateCurCountGet fin' );

end; // function TK_FormCMScan.SCDevicePlateCurCountGet

//************************************ TK_FormCMScan.SCDevicePlateCountsGet ***
// Get resulting DevicePlate Counter
//
procedure TK_FormCMScan.SCDevicePlateCountsGet( const APlateName : string );
var
  i, Ind, DInd : Integer;
  WStr : string;

label LExit;

  function AddResCount( AInd : Integer ) : Boolean;
  begin
    N_Dump2Str( format( 'SC> SCDevicePlateCountsGet CCount Ind=%d', [AInd] ) );
    WStr := SCDevicePlatesClientUse.ValueFromIndex[AInd];
    DInd := Pos( '|', WStr );
    Result := DInd > 0;
    if not Result then
    begin
      SCDevicePlatesClientInd := AInd; // Save Current Ind
      SCDevicePlatesClientCount := StrToIntDef( WStr, 0 );
      N_Dump2Str( format( 'SC> SCDevicePlateCountsGet CCount=%d', [SCDevicePlatesClientCount] ) );
    end
    else
    begin
      SCDevicePlatesTotalCount := SCDevicePlatesTotalCount +
                                  StrToIntDef( Copy( WStr, 1, DInd - 1), 0 );
      N_Dump2Str( 'SC> SCDevicePlateCountsGet UCount+=' + IntToStr(SCDevicePlatesTotalCount) );
    end;
  end; // function AddResCount

begin
  N_Dump2Str( 'SC> SCDevicePlateCountsGet start >> ' + APlateName );
  if SCDevicePlateCurID = APlateName then
  begin
    N_Dump2Str( format( 'SC> SCDevicePlateCountsGet UCount= %d CCount=%d', [SCDevicePlatesTotalCount,SCDevicePlatesClientCount] ) );
    Exit;
  end;

  SCDevicePlateCurID := APlateName;
  SCDevicePlatesTotalCount  := 0;
  SCDevicePlatesClientCount := 0;
  SCDevicePlatesClientInd   := -1;
  Ind := SCDevicePlatesTotalUse.IndexOfName( APlateName );
  if Ind >= 0 then
    SCDevicePlatesTotalCount := StrToIntDef( SCDevicePlatesTotalUse.ValueFromIndex[Ind], 0 );

  N_Dump2Str( 'SC> SCDevicePlateCountsGet UCount=' + IntToStr(SCDevicePlatesTotalCount) );
  Ind := SCDevicePlatesClientUse.IndexOfName( APlateName );
  if Ind < 0 then goto LExit; // Current Plate record is absent

  if not AddResCount( Ind ) then Exit; // Find Active SCDevicePlatesClientUse element

  for i := Ind + 1 to SCDevicePlatesClientUse.Count - 1 do
  begin
    if SCDevicePlatesClientUse.Names[i] <> APlateName then Continue;
    if not AddResCount( i ) then break;
  end; // for i := Ind + 1 to SCDevicePlatesClientUse.Count - 1 do

LExit: //***** Add New Empty to SCDevicePlatesClientUse
  if SCDevicePlatesClientInd = -1 then
  begin
    SCDevicePlatesClientUse.Add( APlateName + '=' );
    SCDevicePlatesClientInd := SCDevicePlatesClientUse.Count - 1;
    N_Dump2Str( format( 'SC> SCDevicePlateCountsGet Add New CCount Ind=%d', [SCDevicePlatesClientInd] ) );
  end;

  N_Dump2Str( 'SC> SCDevicePlateCountsGet fin' );

end; // procedure TK_FormCMScan.SCDevicePlateCountsGet;

//********************************** TK_FormCMScan.SCDevicePlateCurCountInc ***
// Inc Current DevicePlate Counter
//
procedure TK_FormCMScan.SCDevicePlateCurCountInc(const APlateName: string);
var
  WStr : string;
begin
  SCDevicePlateCountsGet( APlateName );
  Inc(SCDevicePlatesClientCount);
  WStr := IntToStr(SCDevicePlatesClientCount);
  SCDevicePlatesClientUse.ValueFromIndex[SCDevicePlatesClientInd] := WStr;
  N_Dump2Str( 'SC> SCDevicePlateCountInc CCount=' + WStr );
end; // procedure TK_FormCMScan.SCDevicePlateCurCountInc

{
//************************************* TK_FormCMScan.SCGetTaskRSFileName ***
// Get Task R-file by Task S-file
//
//    Parameters
//  ASFileName - Task S-file name
//  Result - Returns Task R-file name
//
function TK_FormCMScan.SCGetTaskRSFileName( const ASFileName : string; AChar : Char ) : string;
begin
  Result := ASFileName;
  Result[Length(ASFileName) - 19] := AChar; // Syymmddhhnnsszzz.txt >> Ryymmddhhnnsszzz.txt
end; // procedure TK_FormCMScan.SCGetTaskRSFileName

//*************************************** TK_FormCMScan.SCGetTaskFolderName ***
// Get Task Folder name by given by S-file or R-file
//
//    Parameters
//  ASFileName - task S-file or R-file name
//  Result - Returns Task Folder Name
//
function TK_FormCMScan.SCGetTaskFolderName( const ARSFileName : string ): string;
var
  Ind : Integer;
begin
  Ind := Length(ARSFileName) - 3;
  Result := Copy( ARSFileName, 1, Ind );
  Result[Ind - 16] := 'F';
  Result[Ind] := '\';
end; // procedure TK_FormCMScan.SCGetTaskFolderName
}
{
//******************************************** TK_FormCMScan.SCForceDirPath ***
// Force Folder Path (exception if fails)
//
//    Parameters
//  AFolderPath - Folder Path
//
procedure TK_FormCMScan.SCForceDirPath( const AFolderPath : string );
begin
  if K_CMEDAccess.EDAForceDirPath( AFolderPath ) then Exit;
  raise Exception.Create( 'Path creation error >> ' + AFolderPath );
end; // procedure TK_FormCMScan.SCForceDirPath
}

//******************************** TK_FormCMScan.SCScanFilesTreeSelectFile ***
// Select Emergency Cache Files scan files subtree function
//
//     Parameters
// APathName - testing path
// AFileName - testing file name
//
function TK_FormCMScan.SCScanFilesTreeSelectFile( const APathName, AFileName: string; AScanLevel : Integer ) : TK_ScanTreeResult;
begin
  Result := K_tucSkipSubTree;
  if AFileName = '' then
    Exit;
  K_CMEDAccess.TmpStrings.Add( APathName + AFileName );
end; // end of TK_FormCMScan.SCScanFilesTreeSelectFile

//********************************** TK_FormCMScan.SCWEBCurStateToMemIni ***
// Put Current WEB cotext to MemIni
//
procedure TK_FormCMScan.SCWEBCurStateToMemIni;
begin
// Because Login and Password should not be shown in dump
//  N_Dump2Str( format( 'SCWEBCurStateToMemIni >> %d %s "%s" "%s" "%s"',
//    [SCWEBPortNumber,SCWEBWDDriveChar,SCWEBWDHost,SCWEBWDLogin,SCWEBWDPassword] ) );
  N_Dump2Str( format( 'SCWEBCurStateToMemIni >> %d %s "%s"',
    [SCWEBPortNumber,SCWEBWDDriveChar,SCWEBWDHost] ) );
  N_BoolToMemIni( 'ScanWEBSettings', 'WEBMode', SCWEBMode );
  N_IntToMemIni( 'ScanWEBSettings', 'PortNumber', SCWEBPortNumber );
  N_StringToMemIni( 'ScanWEBSettings', 'WDDrive', SCWEBWDDriveChar );
  N_StringToMemIni( 'ScanWEBSettings', 'WDHost', SCWEBWDHost );
  N_StringToMemIni( 'ScanWEBSettings', 'WDLogin', SCWEBWDLogin );
  N_StringToMemIni( 'ScanWEBSettings', 'WDPassword', SCWEBWDPassword );
  N_StringToMemIni( 'ScanWEBSettings', 'WDCompID', SCWEBWDCompID );
  N_StringToMemIni( 'ScanWEBSettings', 'WDDateOut', SCWEBWDDateOut );
  N_Dump1Str('SCWEBWDDateOut: ' + SCWEBWDDateOut);
end; // procedure TK_FormCMScan.SCWEBCurStateToMemIni

//********************************** TK_FormCMScan.SCWEBMemIniToCurState ***
// Get Current WEB cotext from MemIni
//
procedure TK_FormCMScan.SCWEBMemIniToCurState;
begin
  SCWEBPortNumber := N_MemIniToInt( 'ScanWEBSettings', 'PortNumber', 81 );
  SCWEBWDDriveChar  := N_MemIniToString( 'ScanWEBSettings', 'WDDrive', 'Z' );
  SCWEBWDHost     := N_MemIniToString( 'ScanWEBSettings', 'WDHost', '' );
  SCWEBWDLogin    := N_MemIniToString( 'ScanWEBSettings', 'WDLogin', '' );
  SCWEBWDPassword := N_MemIniToString( 'ScanWEBSettings', 'WDPassword', '' );
  SCWEBWDCompID := N_MemIniToString( 'ScanWEBSettings', 'WDCompID', '' );         //SIR#26380 SIR#26381
  SCWEBWDDateOut := N_MemIniToString( 'ScanWEBSettings', 'WDDateOut', '' );         //SIR#26380 SIR#26381
  if SCWEBWDCompID = '' then
  begin
    SCWEBWDCompID := CreateCompID();
    N_StringToMemIni( 'ScanWEBSettings', 'WDCompID', SCWEBWDCompID );
  end;
// Because Login and Password should not be shown in dump
//  N_Dump2Str( format( 'SCWEBMemIniToCurState >> %d %s "%s" "%s" "%s"',
//    [SCWEBPortNumber,SCWEBWDDriveChar,SCWEBWDHost,SCWEBWDLogin,SCWEBWDPassword] ) );
  N_Dump2Str( format( 'SCWEBMemIniToCurState >> %d %s "%s"',
    [SCWEBPortNumber,SCWEBWDDriveChar,SCWEBWDHost] ) );
end; // procedure TK_FormCMScan.SCWEBMemIniToCurState

procedure TK_FormCMScan.tiMainDblClick(Sender: TObject);
begin
  inherited;

  if (SCScanState = K_SCSSWait) or (SCScanState = K_SCSSMoveToNewPath) then
  begin
    SCScanState := K_SCSSSetup; // SETUP state - before show !!!
    aOfflineMode.Enabled := TRUE;

    if SCUIStayOnTopSetup then
      N_BaseFormStayOnTop := 2;

    tiMain.Visible := False;
    Show();
    WindowState := wsNormal;
    Application.BringToFront();

    if K_CMScanDataPath = '' then
      SCScanDataPathIniSet();

    SCInitScanPathsContext();
    SCUpdateScanState();
  end
  else
  if SCScanState <> K_SCSSSetup then
  begin
    N_Dump1Str( 'SC> Tray Left Button State=' + IntToStr(Ord(SCScanState)) );
    SCShowNotReadyMessage();
  end;
end;

procedure TK_FormCMScan.tiMainMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  tiMain.PopupMenu := nil;

  if Button = mbRight then
    if SCScanState = K_SCSSWait then
    begin
      tiMain.PopupMenu := PopupMenu1;
    end
    else
    if (SCScanState <> K_SCSSSetup) then
    begin
      N_Dump1Str( 'SC> Tray Right Button State=' + IntToStr(Ord(SCScanState)) );
      SCShowNotReadyMessage();
    end;
end;

// procedure TK_FormCMScan.SCWEBMemIniToCurState

//************************************************* TK_FormCMScan.SCWEBInit ***
// Initialize HTTP server and WEB DAV
//
procedure TK_FormCMScan.SCWEBInit;
{ // for comp in D7
var
  //WebDAV: TNetResource;
  i: Integer;
}
begin
{ // for comp in D7
  L_CountWebDav := 0;
  try
    // Activate HTTP server
    //if SCWEBMode then                                                //SIR#26380 SIR#26381
    if true then
    begin
      //IdHTTPServer1.Bindings.Items[0].Port := SCWEBPortNumber;
      N_Dump1Str('SCWEBInit > run!');
      try                                                                  ////Igor 20062020
        IdHTTPServer1.DefaultPort := SCWEBPortNumber;
        IdHTTPServer1.Active := True;
        IdHTTPServer1.AutoStartSession := True;
      except
        N_Dump1Str('HTTPServer > run error, bad port!');
        K_CMShowMessageDlg('HTTPServer is not running, bad port ' + IntToStr(SCWEBPortNumber), mtError );
      end;

    end else
    begin
      IdHTTPServer1.Active := False;
      IdHTTPServer1.AutoStartSession := False;
    end;

    // Is needed to add WEB DAV initialization using
    // SCWEBWDDriveChar, SCWEBWDHost, SCWEBWDLogin, SCWEBWDPassword

    if SCWEBMode then                                                        ////Igor 08092019
    begin
      if SCWEBWDHost = '' then
      begin
        N_Dump1Str('WebDAV setting is empty!');                              ////Igor 20062020
        K_CMShowMessageDlg('WebDAV setting is empty!', mtError );
        Exit;
      end;
      if ServiceGetStatus('WebClient') <> SERVICE_RUNNING then               ////Igor 23032020
      begin
        N_Dump1Str('SCWEBInit> WebClient service not running! Trying start.');
        if StartWebClientService then
        begin
          N_Dump1Str('SCWEBInit> trigger run successful!');

          for i := 1 to 5 do           // waiting start WebClient service (max 5sec)
          begin
            Sleep(1000);
            if ServiceGetStatus('WebClient') = SERVICE_RUNNING then
            begin
              N_Dump1Str('SCWEBInit> WebClient service run successful! Wait(sec): ' + IntToStr(i));
              Break;
            end;
          end;

          if ServiceGetStatus('WebClient') <> SERVICE_RUNNING then
          begin
            N_Dump1Str('SCWEBInit> WebClient service run Error!');
            K_CMShowMessageDlg('WebClient service is not running!', mtError );
            Exit;
          end;

        end else
        begin
          N_Dump1Str('SCWEBInit> trigger run error!');
          K_CMShowMessageDlg('WebClient service is not running!', mtError );
          Exit;
        end;
      end else
          N_Dump1Str('SCWEBInit> WebClient service is running in Windows!');   ////Igor 23032020
}
      {
      WebDAV.dwType := RESOURCETYPE_DISK;
      WebDAV.lpLocalName := PChar(SCWEBWDDriveChar + ':');
      WebDAV.lpRemoteName := PChar(SCWEBWDHost);
      WebDAV.lpProvider := '';
      }
{ // for comp in D7
      WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), 0, TRUE);
}
      {
      i := 1;
      repeat
        Res := WNetAddConnection2(WebDAV, PChar(SCWEBWDPassword), PChar(SCWEBWDLogin), CONNECT_TEMPORARY);
        if (Res <> NO_ERROR) then           //Igor 30032020
        begin
          N_Dump1Str('SCWEBInit> Network disk connection error! Try-' + IntToStr(i) + ' #' + IntToStr(Res));
          //WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), 0, TRUE);
          i := i + 1;
          if (i > 5) then
          begin
            case K_CMShowMessageDlg('Error connecting a network disk after 5 attempts!' + #13#10 + 'Error #' + IntToStr(Res), mtWarning,[mbRetry, mbIgnore, mbAbort]) of
              mrRetry: i := 1;
              mrIgnore: Break;
              mrAbort: QuitMediaSuiteScanner1Click(nil);      ////Igor 14072020
            end;
          end;
          Sleep(1000);
        end;
      until (Res = NO_ERROR);
      }
{// for comp in D7
    end else
    begin
      //WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), CONNECT_UPDATE_PROFILE, TRUE);
      WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), 0, TRUE);
    end;

  except
    on E: Exception do
    begin
      N_Dump1Str( 'SCWEBInit exception: ' + E.Message );
    end;
  end;
}  
end; // procedure TK_FormCMScan.SCWEBInit

//************************************************* TK_FormCMScan.SCWEBInitDiskZ ***
// Initialize HTTP server and WEB DAV
//
function TK_FormCMScan.SCWEBInitDiskZ: Int64;                                ////Igor 11092020
var
  WebDAV: TNetResource;
  //i: Integer;
  //Res: Int64;
begin
  result := -1;
  try
    if SCWEBMode then                                                        ////Igor 08092019
    begin
      N_Dump1Str( 'SCWEBInitDiskZ is RUN');
      WebDAV.dwType := RESOURCETYPE_DISK;
      WebDAV.lpLocalName := PChar(SCWEBWDDriveChar + ':');
      WebDAV.lpRemoteName := PChar(SCWEBWDHost);
      WebDAV.lpProvider := '';

      WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), 0, TRUE);
      result := WNetAddConnection2(WebDAV, PChar(SCWEBWDPassword), PChar(SCWEBWDLogin), CONNECT_TEMPORARY);
      {
      i := 1;
      repeat
        Res := WNetAddConnection2(WebDAV, PChar(SCWEBWDPassword), PChar(SCWEBWDLogin), CONNECT_TEMPORARY);
        if (Res <> NO_ERROR) then           //Igor 30032020
        begin
          N_Dump1Str('SCWEBInitDiskZ> Network disk connection error! Try-' + IntToStr(i) + ' #' + IntToStr(Res));
          //WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), 0, TRUE);
          i := i + 1;
          if (i > 5) then
          begin
            case K_CMShowMessageDlg('Error connecting a network disk after 5 attempts!' + #13#10 + 'Error #' + IntToStr(Res), mtWarning,[mbRetry, mbIgnore, mbAbort]) of
              mrRetry: i := 1;
              mrIgnore: Break;
              mrAbort: QuitMediaSuiteScanner1Click(nil);      ////Igor 14072020
            end;
          end;
          Sleep(1000);
        end;
      until (Res = NO_ERROR);
      }
    end else
    begin
      //WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), CONNECT_UPDATE_PROFILE, TRUE);
      WNetCancelConnection2(PChar(SCWEBWDDriveChar + ':'), 0, TRUE);
    end;

  except
    on E: Exception do
    begin
      N_Dump1Str( 'SCWEBInitDiskZ exception: ' + E.Message );
    end;
  end;
end; // procedure TK_FormCMScan.SCWEBInitDiskZ


{*** end of TK_FormCMScan ***}


{*** TK_CMEDCSAccess ***}

//************************************************* TK_CMEDCSAccess.EDAInit ***
// Init External Data Access Object when Application is Ready to Initialization
//
//     Parameters
// Result - Returns operation resulting code
//
function TK_CMEDCSAccess.EDAInit(): TK_CMEDResult;
begin
  Result := EDAArchUDCompsInit();
  if Result <> K_edOK then
    Exit;

  UDRootInstanceInfo := TN_UDBase.Create;
  UDRootInstanceInfo.ObjName := 'RootInstanceInfo';
  if K_VFileExists( K_FormCMScan.SCCurDataFileName ) then
  begin
    K_SerialTextBuf.LoadFromFile( K_FormCMScan.SCCurDataFileName );
    K_LoadTreeFromText0(UDRootInstanceInfo, K_SerialTextBuf, TRUE);
  end;
  K_UDCursorGet('AI:').SetRoot(UDRootInstanceInfo);

  // *** Objects for Setting on User Side
  with K_UDCursorForceDir('AI:SysObjects') do
  begin
    N_CM_VideoStat := TK_UDRArray(DirChildByObjName('VideoStat'));
    if N_CM_VideoStat = nil then
    begin
      N_CM_VideoStat := K_CreateUDByRTypeName('TN_CMVideoStatRecord', 0);
      N_CM_VideoStat.ObjName := 'VideoStat';
      AddOneChild(N_CM_VideoStat);
    end; // if N_CM_VideoStat = nil then
  end;

  K_CMSLastVersion := N_MemIniToString('CMS_Main', 'LastRunVersion', '' ); // Get Last Version
  if K_CMCheckNewVersionProcessing() then
  begin

    /////////////////////////////////////////////////
    // Process new CMS Version 1-st run Data Patches
    //

    if K_CMSLastVersion = '03.059.00' then
    begin // Run Clear Flip Flags in Duerr Profiles
      N_Dump1Str('SC>> Duerr Profiles Processing Start' );
      K_CMClearFlipFlagsInOneProfilesSet( UDRootInstanceInfo );
      N_Dump1Str('SC>> Duerr Profiles Processing fin' );
    end; // if K_CMSLastVersion = '03.059.00' then

    // Other Patches ...

    //
    // Process new CMS Version 1-st run Data Patches
    /////////////////////////////////////////////////

    K_CMSLastVersion := N_CMSVersion;
    // Save New Last Version info
    N_StringToMemIni('CMS_Main', 'LastRunVersion', N_CMSVersion );
    EDASaveContextsData( [] );

    N_Dump1Str( '!!!New Version processing fin' );
  end; // if K_CMCheckNewVersionProcessing() then

  K_UDCursorGet('DI:').SetRoot(UDRootInstanceInfo);
  Result := EDADevProfilesUDTreeInit();

// 3.059 patch
  if ATimer = nil then
    ATimer := TTimer.Create(N_CM_MainForm);

  ATimer.Interval := K_CMEDAActivateTimerDeltaMS;
  ATimer.OnTimer := EDATimerAction;
  ATimer.Enabled := TRUE;
// 3.059 patch


end; // end of TK_CMEDCSAccess.EDAInit

//************************************ TK_CMEDCSAccess.EDAGetAllMediaTypes0 ***
// Get all Media Types list
//
//     Parameters
// Result - Self buffer strings list with all media types
//
function TK_CMEDCSAccess.EDAGetAllMediaTypes0(): TStrings;
var
  i: Integer;
  FRebuildFlag : Boolean;
  FileInfoGetResult : Integer;
begin
  ExtResultCode := K_edOK;
  FRebuildFlag := AllMediaTypes = nil;
  if FRebuildFlag then
  begin
    // *** Create and Init Bufferd Media Types List
    AllMediaTypes := TStringList.Create;
    TStringList(AllMediaTypes).CaseSensitive := false;
  end; // if FRebuildFlag then

  Result := AllMediaTypes;

/////////////////////////////
// Try to Load Info File
//
  FileInfoGetResult := K_FormCMScan.SCGetInfoFile( not FRebuildFlag );
  if FileInfoGetResult = -1 then
  begin
    if not FRebuildFlag then Exit;
    // Init Media Types - File Info is absent, use Init Media Types
    ExtResultCode := EDAGetBuildInMediaTypes(AllMediaTypes);
    K_CMEDAccess.TmpStrings.Assign( K_CMSIniMediaTypes );
  end // if FileInfoGetResult = -1 then
  else
  if FileInfoGetResult = 0 then Exit // Return with old Media Types
  else
  begin
    if K_CMEDAccess.TmpStrings[0][1] = '[' then
      K_CMEDAccess.TmpStrings.Delete(0); // Remove [MediaTypes] string

    if not FRebuildFlag then
    // Clear old AllMediaTypes
      AllMediaTypes.Clear;
  end;
//
// Try to Load Info File
/////////////////////////////

  // Add Media Types
  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin
    if K_CMEDAccess.TmpStrings[i] = '' then break; // for case if info file has Ini-file format
    AllMediaTypes.AddObject(K_CMEDAccess.TmpStrings.ValueFromIndex[i],
                            TObject(StrToInt(K_CMEDAccess.TmpStrings.Names[i])));
  end;

  if FileInfoGetResult <> 1 then // Init Texts only if CMSuite Info is absent
    EDAPrepIniMediaTypeTexts();

end; // end of TK_CMEDCSAccess.EDAGetAllMediaTypes0

//************************************* TK_CMEDCSAccess.EDASaveContextsData ***
// Save Current Application Context
//
//     Parameters
// Result - Returns operation resulting code
//
function TK_CMEDCSAccess.EDASaveContextsData( ASaveFlags: TK_CMEDSaveStateFlags ): TK_CMEDResult;
begin
  Result := K_edOK;
//  K_SaveArchive(K_CurArchive, [K_lsfSkipJoinChangedSLSR]);
  K_SaveTreeToText( UDRootInstanceInfo, K_SerialTextBuf, TRUE );
  K_VFSaveStrings( K_SerialTextBuf.TextStrings, K_FormCMScan.SCCurDataFileName,
                                   K_DFCreateProtected );

//  K_SaveMemIniToFile( N_CurMemIni );
  EDAGlobalCurStateToMemIni();

  K_CMEDAMemIniToExtIniFiles();
  K_MVCBFSaveAll();
  N_Dump1Str( 'SC> TK_CMEDCSAccess.EDASaveContextsData' );
end; // function TK_CMEDCSAccess.EDASaveContextsData

//********************************** TK_CMEDCSAccess.EDAGetPatientMacroInfo ***
// Get List of fields values for given Patient
//
//     Parameters
// ADataID - Patient ID (if =-1 then Current Patient ID will be used)
// AInfo   - fileds values list (<Name>=<Value>)
// AAddToValues - add to AFieldValues flag (if =FALSE, then AFieldValues would be clear before adding values)
// Result - Returns AInfo or Self StringsList if AInfo = nil (Self StringsList is always clear before adding new values)
//
function TK_CMEDCSAccess.EDAGetPatientMacroInfo( ADataID : Integer = -1;
                                AInfo : TStrings = nil;
                                AAddToValues : Boolean = false ): TStrings;
begin
  Result := AInfo;
  if Result <> nil then
  begin
    if AAddToValues then
      Result.Clear;
    Result.AddStrings( K_FormCMScan.SCSTask );
  end
  else
    Result := K_FormCMScan.SCSTask;
end; // function TK_CMEDCSAccess.EDAGetPatientMacroInfo`

//***************************** TK_CMEDCSAccess.EDASetSlideMediaFileTMPName ***
// Set given slide Media File Temporary name using file name extension
//
//     Parameters
// ASlide - given Slide
// AMediaFExt - file name extension
//
procedure TK_CMEDCSAccess.EDASetSlideMediaFileTMPName( ASlide: TN_UDCMSlide;
                                                       const AMediaFExt: string );
var
  TMPPath: string;
  PCMSlide : TN_PCMSlide;
  LocFName : string;
begin
  PCMSlide := ASlide.P();
  with PCMSlide^ do
  begin
    CMSDB.MediaFExt := AMediaFExt;

    ASlide.ECacheInitName();
    LocFName := ExtractFileName( ASlide.CMSlideECFName );
    LocFName := copy( LocFName, 1, Length(LocFName) - 4 );
    LocFName[Length(LocFName)] := 'V';

    if K_FormCMScan.SCScanState = K_SCSSSetup then
    begin
{ // 2015-02-03 use same file name in Setup and in Task Scan mode
      LocFName := 'MF_' + IntToStr(CurSlidesList.Count) + 'new';
}
      TMPPath := K_FormCMScan.SCScanTaskLocFolder;
    end
    else
    begin
//      TMPPath := K_FormCMScan.SCScanTaskFolder;
      TMPPath := K_FormCMScan.SCCMSScanTaskFolder; // Use Path Needed in CMSuite
{ // 2015-02-03 use same file name in Setup and in Task Scan mode
      ASlide.ECacheInitName();
      LocFName := ExtractFileName( ASlide.CMSlideECFName );
      LocFName := copy( LocFName, 1, Length(LocFName) - 4 );
      LocFName[Length(LocFName)] := 'V';
}
    end;

    CMSDB.MediaFExt := TMPPath + LocFName + CMSDB.MediaFExt;

    N_Dump1Str( 'SC> TK_CMEDCSAccess.EDASetSlideMediaFileTMPName >> ' + CMSDB.MediaFExt );
  end; // with Result.P()^ do
end; // procedure TK_CMEDCSAccess.EDASetSlideMediaFileTMPName

//******************************* TK_CMEDCSAccess.EDAGetMediaFileClientName ***
// Get given slide Media File Client Name
//
//     Parameters
// ASlide - given Slide
//
function TK_CMEDCSAccess.EDAGetMediaFileClientName( ASlide: TN_UDCMSlide ) : string;
begin
  Result := '';
  // Return TMP MediaFName (before Slide is stored to DB)
  with ASlide.P()^ do
  begin
    if K_FormCMScan.SCScanState <> K_SCSSSetup then
      Result := K_FormCMScan.SCScanTaskLocFolder + ExtractFileName(CMSDB.MediaFExt)
    else
      Result := CMSDB.MediaFExt;
  end;
end; // procedure TK_CMEDCSAccess.EDAGetMediaFileClientName

//***************************************** TK_CMEDCSAccess.EDAStartCapture ***
// Start capture
//
//     Parameters
// ACMScanCaptureFlags - Capture Flags
// APCurDevProfile     - pointer to device profile
//
function TK_CMEDCSAccess.EDAStartCapture( ACMScanCaptureFlags : TK_CMScanCaptureFlags;
                                           APCurDevProfile: TK_PCMDeviceProfile ) : Boolean;
var
  Res : Integer;
  WSkip16bitMode : Boolean;
  WRImageType : Integer;
  ChangeMode : Boolean;
  WScanTaskFolder, WScanTaskRFile, WLocSFile : string;
  UpdateFileInfo : string;
  CMDCMAttrs : TK_CMDCMAttrs;

  procedure PrepScanLocContext( const ATaskFolder, ATaskRFile : string ) ;
  begin
    with K_FormCMScan do
    begin
      SCScanTaskLocFolder := SCScanRootLocFolder + Copy( ATaskFolder, Length(ATaskFolder) - 16, 17 );
      SCScanTaskLocRFile  := SCScanRootLocFolder + Copy( ATaskRFile, Length(ATaskRFile) - 19, 20 );
      K_ForceDirPath( SCScanTaskLocFolder );
//      SCForceDirPath( SCScanTaskLocFolder );
      K_AppFileGPathsList.Values['CMECacheFiles'] := SCScanTaskLocFolder;
    end;
  end;

begin
  Result := inherited EDAStartCapture( ACMScanCaptureFlags, APCurDevProfile );

  with K_FormCMScan do
  begin

    N_Dump1Str( 'SC> EDAStartCapture mode' + IntToStr(Ord(SCScanState)) );
  ///////////////////////////////////////////
  //  Check Raster Image Modes in Common Info
  //
    SCGetInfoFile( TRUE );

    Res := SCInfoStrings.IndexOf('[Common]');
    if Res >= 0 then
    begin
    // Common Info Exists - Check 16bit and RImageType
//      TmpStrings.Add( 'Skip16bitMode=' + N_B2S(K_CMSSkip16bitMode) );
//      TmpStrings.Add( 'RImageType=' + IntToStr(K_CMSRImageType) );

      WSkip16bitMode := N_S2B( SCInfoStrings.Values['Skip16bitMode'] );
      WRImageType    := StrToIntDef( SCInfoStrings.Values['RImageType'], K_CMSRImageType );
//      WSkip16bitMode := N_S2B( SCInfoStrings.ValueFromIndex[Res+1] );
//      WRImageType    := StrToIntDef( SCInfoStrings.ValueFromIndex[Res+2], K_CMSRImageType );
      ChangeMode := WRImageType <> K_CMSRImageType;
      K_CMSRImageType := WRImageType;
      if ChangeMode then // Rebuild
        K_CMSRebuildCommonRImage();

      ChangeMode := ChangeMode or (WSkip16bitMode <> K_CMSSkip16bitMode);
      K_CMSSkip16bitMode := WSkip16bitMode;

      if ChangeMode then // Save Changed Context
        EDASaveContextsData( [] );
    end;
  //
  //  end of Check Raster Image Modes in Common Info
  ///////////////////////////////////////////


    SCShowString( '' );

  // Create Task R-file contents
    CMDCMAttrs.CMDCMModality := '';
    CMDCMAttrs.CMDCMKVP := 0;
    CMDCMAttrs.CMDCMExpTime := 0;
    CMDCMAttrs.CMDCMTubeCur := 0;
    if not (K_scfSkipProfileDICOMDefaults in ACMScanCaptureFlags) then
      CMDCMAttrs :=  TK_PCMDCMAttrs(@APCurDevProfile.CMDPDModality)^;



    SCRTask.Text := format('IsDone=FALSE'#13#10'ScanCount=0'#13#10+
       'MTypeID=%d'#13#10'DModality=%s'#13#10'DKVP=%g'#13#10+
       'DExpTime=%d'#13#10'DTubeCur=%d',
       [APCurDevProfile.CMDPMTypeID,
        CMDCMAttrs.CMDCMModality,
        CMDCMAttrs.CMDCMKVP,
        CMDCMAttrs.CMDCMExpTime,
        CMDCMAttrs.CMDCMTubeCur] );

    FullStayOnTop := K_scfUseFullStayOnTopMode in ACMScanCaptureFlags;
    if not FullStayOnTop and
       (N_BaseFormStayOnTop <> 0) then
      N_BaseFormStayOnTop := 1; // Partial StayOnTop

    SCScanCount := 0;
    if SCScanState <> K_SCSSDoTask then
    begin // Scan in SetUp mode

      if (K_SCLocalFilesStorageThreshold > 0) and SCOfflineModeFlag then
      begin // Use Local Storage
        // Get From Prevoiuse Context

        // Set Patient Details
        Result := K_CMScanPatientDataDlg( K_SCPatDefSurname, K_SCPatDefFirstname );
        if not Result then Exit;
        N_Dump1Str( format( 'SC> PatientDataDlg N=%s S=%s', [K_SCPatDefFirstname,K_SCPatDefSurname] ) );
//!!        if (K_SCPatDefSurname <> SCSTask.Values['PatientSurname']) or
//!!           (K_SCPatDefFirstname <> SCSTask.Values['PatientFirstName']) then
//!!        begin // If Surname or FirstName was changed then clear prevoiuse
        // OffLine S-file doesn't contain IsTerm,CurPatID,CurProvID,CurLocID
          SCSTask.Text :=
      'PatientTitle='#13#10 +
      'PatientGender='#13#10 +
      'PatientCardNumber=1'#13#10 +
      'PatientSurname=' + K_SCPatDefSurname + #13#10 +
      'PatientFirstName=' + K_SCPatDefFirstname + #13#10 +
      'PatientMiddle='#13#10 +
      'PatientDOB=';
          K_CMEDAccess.CurPatID := 1;
          K_CMEDAccess.CurProvID := 1;
          K_CMEDAccess.CurLocID := 1;
//!!        end;
        // Create Task Local S-File
      end   // if K_SCLocalFilesStorageThreshold > 0 then
      else
      begin // if K_SCLocalFilesStorageThreshold = 0 then
      // Without Local Storage
        SCSTask.Text :=
    'PatientTitle=Mr'#13#10 +
    'PatientGender=M'#13#10 +
    'PatientCardNumber=1'#13#10 +
    'PatientSurname=SMITH'#13#10 +
    'PatientFirstName=John'#13#10 +
    'PatientMiddle='#13#10 +
    'PatientDOB=01/01/2000'#13#10 +
    'Remove=TRUE'; // task should be removed from Local Storage
        K_CMEDAccess.CurPatID := 1;
        K_CMEDAccess.CurProvID := 1;
        K_CMEDAccess.CurLocID := 1;
        K_SCPatDefSurname := '';
        K_SCPatDefFirstname := '';
      end;

    // Prepare Local Task Files for Local Storage
      WScanTaskFolder := K_DateTimeToStr( Now(), 'yymmddhhnnsszzz' );
      WScanTaskRFile  := 'R' +  WScanTaskFolder + '.txt';
      WScanTaskFolder := 'F' + WScanTaskFolder + '\';
      PrepScanLocContext( WScanTaskFolder, WScanTaskRFile );

      WLocSFile := K_SCGetTaskRSFileName( SCScanTaskLocRFile, 'S' );
      SCUpdateTaskLocFile( SCScanTaskLocRFile, SCRTask );
      SCUpdateTaskLocFile( WLocSFile, SCSTask );
    end   // if SCScanState <> K_SCSSDoTask then  SetUp Mode
    else
    begin // if SCScanState = K_SCSSDoTask then
    // Scan by Task
      K_SCPatDefSurname := SCSTask.Values['PatientSurname'];
      K_SCPatDefFirstname := SCSTask.Values['PatientFirstName'];
      Res := SCCheckTaskBrokenState( TRUE );
      if Res = 0 then
      begin // Task is Actual (not broken)
    // Set ECache to Task R-folder
        SCCaptureIsStarted := TRUE;
        PrepScanLocContext( SCScanTaskFolder, SCScanTaskRFile );

        UpdateFileInfo := SCUpdateTextFile( SCRTask, SCScanTaskRFile );
        if UpdateFileInfo = '' then
        begin
          SCScanUpload2Count := -1; // R-file is not updated - for Upload without thread
          N_Dump1Str( 'SC> Start Task create R-file Error=' + SCScanTaskRFile );
        end
        else
        begin
          SCScanUpload2Count := 0; // R-file is updated  - for Upload without thread
          N_Dump1Str( 'SC> Start Task create R-file=' + UpdateFileInfo );
        end;

        // Create Local Task S-File for future use
        WLocSFile := K_SCGetTaskRSFileName( SCScanTaskLocRFile, 'S' );
{ !!! 2015-01-29 it will be better to save S-file content from memory than copy from exchange folder
        // Copy Task S-File to Local buffer for future use
        N_T1.Start();
        Res := K_CopyFile( SCScanTaskSFile, WLocSFile );
        N_T1.Stop();
        if Res = 0 then
          N_Dump1Str( 'SC> Start Task Copy S-file to LocBuffer Time=' + N_T1.ToStr() )
        else
          N_Dump1Str( 'SC> Start Task Copy S-file to LocBuffer Error=' + IntToStr(Res) );
}
        SCUpdateTaskLocFile( WLocSFile, SCSTask ); // 2015-01-29


        if SCUIHideBeforeCapt then
        begin
          Hide();
          N_Dump2Str( 'SC> Form Hide on Capture Start' );
        end;

        UploadWithOneSLideGap := not (K_scfSlideUploadWOGap in ACMScanCaptureFlags);
        N_Dump1Str( 'SC> AddUploadTask=' + WLocSFile );

        // Update Task Local R-File
        SCUpdateTaskLocFile( SCScanTaskLocRFile, SCRTask );

        SCScanDataUploadThread.SCUAddUploadTask( WLocSFile );
      end  // if Res = 0 then Task is Actual
      else // Task is not Actual (broken or stoped)
        SCDumpTaskState( 'SC> On Scan Start Task State=', Res );
    end; // if SCScanState = K_SCSSDoTask then Scan by Task

    SCModifyTrayIconTip( Caption + #13#10'Data capture is in proccess', True, bfInfo);
    
  end; // with K_FormCMScan do
end; // procedure TK_CMEDCSAccess.EDAStartCapture

//******************************************* TK_CMEDCSAccess.EDAAddSlide ***
// Add given Slide to Current Slides Set
//
//     Parameters
// ASlide - given Slide
//
procedure TK_CMEDCSAccess.EDAAddSlide( ASlide: TN_UDBase;
                                       ASkipECache: Boolean = false;
                                       ASlidesCount : Integer = 0 );
var
  Res : Integer;

  procedure IncSlidesCount();
  var
    PrevScanCount : Integer;
  begin
    with K_FormCMScan do
    begin
      PrevScanCount := SCScanCount;
      // Calc new Slides Count
      if (ASlidesCount <= 0) or not UploadWithOneSLideGap then
        Inc(SCScanCount)
      else
        SCScanCount := ASlidesCount;

      // Set R-file new 'ScanCount'
      if not UploadWithOneSLideGap or (SCScanState = K_SCSSSetup) then
        SCRTask.Values['ScanCount'] := IntToStr( SCScanCount )
      else // 2015-01-24 - previouse image should be marked as ready
      begin
        if SCScanCount <= 1 then Exit;
        SCRTask.Values['ScanCount'] := IntToStr( SCScanCount - 1 );
      end;

// 2014-08-01 needed for client exchange folder instead of thread
//      if UploadDuringCapture then
//        SCRTask.Values['IsDone'] := K_CMScanTaskIsUploaded;
//      SCUpdateTaskLocRFile();

      // Update R-file if Slides Count is changed
      if PrevScanCount <> SCScanCount then // Update R-file if Slides Count is changed
        SCUpdateTaskLocFile( SCScanTaskLocRFile, SCRTask );
    end; // with K_FormCMScan do
  end; // procedure IncSlidesCount()

begin
  ASlide.ObjName := IntToStr(CurSlidesList.Count) + 'new';

  N_Dump1Str( format( 'EDAAddSlide %s SkipECache=%s SC=%d', [ASlide.ObjName, N_B2S(ASkipECache),ASlidesCount] ) );
  // Set temporary Image ID
  if CurSlidesList.Count > 0 then // !!! Free ECache A-file locked by Stream for previouse Slide it may be needed if slide has been changed after Add
    FreeAndNil(TN_UDCMSlide(CurSlidesList[CurSlidesList.Count-1]).CMSlideECFStream);

  CurSlidesList.Add( ASlide );

  TN_UDCMSlide(ASlide).ECacheSave( -1 );

  FreeAndNil( TN_UDCMSlide(ASlide).CMSlideECFStream ); // !!! Free ECache A-file locked by Stream

  with K_FormCMScan do
  begin
    Res := 0;
    if SCScanState <> K_SCSSSetup then // Scan By Task (not Setup)
      Res := SCCheckTaskBrokenState( FALSE );
    if (K_SCLocalFilesStorageThreshold > 0) or (Res = 0) then
    begin // Increment Local Task
      IncSlidesCount();
      SCShowString( format( '%d Media object(s) are taken', [SCScanCount] ) );
      N_Dump1Str( format( 'SC> Add Slide C=%d U=%s', [SCScanCount, SCRTask.Values['ScanCount']] ) );
    end;
    if Res <> 0 then
      SCDumpTaskState( 'SC> On Image Add Task State=', Res );
  end; // with K_FormCMScan do
end; // end of TK_CMEDCSAccess.EDAAddSlide

//******************************************* TK_CMEDCSAccess.EDAFinCapture ***
// Finish capture
//
procedure TK_CMEDCSAccess.EDAFinCapture();
var
  i, Res : Integer;

Label RetryLoop;
begin

  // Clear New Slides
  for i := CurSlidesList.Count - 1 downto 0 do
  begin
    with TN_UDCMSlide(CurSlidesList[i]) do
    begin
//      FreeAndNil( CMSlideECFStream ); // is done in the destructor
      UDDelete();
    end;
    CurSlidesList.Delete(i);
  end;

  // Check if Profile Settings are changed
//  if (CurDevProfilePar1 <> PCurDevProfile.CMDPStrPar1) or
//     (CurDevProfilePar2 <> PCurDevProfile.CMDPStrPar2) then
//    EDASaveContextsData( [] ); //!!!! Code is moved to then End of routine

  with K_FormCMScan do
  begin
    if SCScanState = K_SCSSSetup then
    begin
   // Setup scanning mode
      SCRemoveTaskLocFolder( (SCScanCount = 0) )
    end
    else
    begin // if SCScanState <> K_SCSSSetup then
   // Real scanning mode
      SCScanState := K_SCSSFinTask;
      Res := SCCheckTaskBrokenState( TRUE );
      if Res = 0 then
      begin
        SCDevicePlatesInfoToUpload();

        //!!! Set IsDone State to Local R-File for Upload Thread
        SCRTask.Values['IsDone'] := 'TRUE';
       // 2015-01-24 - mark all as ready (in not UploadDuringCapture it is equal to SCScanCount - 1)
        SCRTask.Values['ScanCount'] := IntToStr( SCScanCount );
        SCUpdateTaskLocFile( SCScanTaskLocRFile, SCRTask );
      end   // if Res = 0 then
      else
      begin // if Res <> 0 then
        // Task is broken or stoped
        SCDumpTaskState( 'SC> On Scan Stop Task State=', Res );

        // Correct Local Task Real Slides Count if needed
        if UploadWithOneSLideGap           and
           (SCScanCount > 0) then
        begin
          SCRTask.Values['ScanCount'] := IntToStr( SCScanCount );
          SCUpdateTaskLocFile( SCScanTaskLocRFile, SCRTask );
        end;

        if Res = 2 then // Task has been broken
          SCRemoveTask( SCScanTaskSFile );
      end;  // if Res <> 0 then

      SCScanState := K_SCSSWait; // Set Wait State? Tray Tip will be define by UploadThread

      if N_BaseFormStayOnTop <> 0 then
      begin
        if SCUIStayOnTopCapt then
          N_BaseFormStayOnTop := 0
        else
          N_BaseFormStayOnTop := 2; // return Full StayOnTop if N_BaseFormStayOnTop = 1
      end;

      if not SCUIHideBeforeCapt then
      begin
        Hide();
        N_Dump2Str( 'SC> Form Hide on Capture Fin' );
      end;

    end; // // if K_FormCMScan.SCScanState <> 1 then
//    SCModifyTrayIconTip( Caption + SCTrayAddCaption )
    if SCTrayAddCaption <> '' then
      SCModifyTrayIconTip( SCTrayAddCaption )
    else
      SCModifyTrayIconTip( Caption );

    // Save Current Device Plates to MemIni
    SCDevicePlatesInfoToMemIni();
    SCScanCurSave();
  end; // with K_FormCMScan do

// Save Profiles Info always because in Video Profiles
// not only CMDPStrPar1 and CMDPStrPar2 but some other Profile
// Attributes can be changed
  // Save Profiles Only instead EDASaveContextsData
  K_SaveTreeToText( UDRootInstanceInfo, K_SerialTextBuf, TRUE );
  K_VFSaveStrings( K_SerialTextBuf.TextStrings, K_FormCMScan.SCCurDataFileName,
                                   K_DFCreateProtected );
  K_MVCBFSaveAll();

//  EDASaveContextsData( [] ); // Save always because in Video Profiles
//                             // not only CMDPStrPar1 and CMDPStrPar2
//                             // but some other Profile Attributes can be changed

end; // procedure TK_CMEDCSAccess.EDAFinCapture

//************************************ TK_CMEDCSAccess.EDASaveSlideToECache ***
// Save given Slide to Emergency Cache using given State Flags
//
//     Parameters
// AUDSlide - Slide to save
//
procedure TK_CMEDCSAccess.EDASaveSlideToECache(AUDSlide: TN_UDCMSlide);
begin
  AUDSlide.ECacheSave( -1 );
end; // end of TK_CMEDCSAccess.EDASaveSlideToECache

//************************************* TK_CMEDCSAccess.EDAClearSlideECache ***
// Clear given Slide Emergency Cache Files
//
//     Parameters
// AUDSlide - Slide to Save
//
procedure TK_CMEDCSAccess.EDAClearSlideECache(AUDSlide: TN_UDCMSlide);
begin
  AUDSlide.ECacheClear( -1 );
end; // end of TK_CMEDCSAccess.EDAClearSlideECache

//******************************* TK_CMEDCSAccess.EDADevicePlateUseCountGet ***
// Get Device Plate Use Counter
//
//     Parameters
// APlateName - device plate name
// Result - Returns given Device Plate Use Counter
//
function TK_CMEDCSAccess.EDADevicePlateUseCountGet( const APlateName: string): Integer;
begin
  with K_FormCMScan do
  begin
    SCDevicePlateCountsGet( APlateName );
    Result :=  SCDevicePlatesTotalCount + SCDevicePlatesClientCount;
    N_Dump2Str( 'EDADevicePlateUseCountGet RCount=' + IntToStr(Result) );
  end; // with K_FormCMScan do
end; // function TK_CMEDCSAccess.EDADevicePlateUseCountGet

//******************************* TK_CMEDCSAccess.EDADevicePlateUseCountInc ***
// Increment Device Plate Use Counter
//
//     Parameters
// APlateName - device plate name
// Result - Returns given Device Plate new Use Counter
//
function TK_CMEDCSAccess.EDADevicePlateUseCountInc( const APlateName: string): Integer;
begin
  with K_FormCMScan do
  begin
    SCDevicePlateCurCountInc( APlateName );
    Result :=  SCDevicePlatesTotalCount + SCDevicePlatesClientCount;
    N_Dump2Str( 'EDADevicePlateUseCountInc RCount=' + IntToStr(Result) );
  end; // with K_FormCMScan do
end; // function TK_CMEDCSAccess.EDADevicePlateUseCountInc

{*** end of TK_CMEDCSAccess ***}

{*** TK_SCUScanDataThread ***}

const
  scuFileReadError  = -1;
  scuCopyFilesOK    = 0;
  scuCopyFilesStop  = 1;
  scuCopyFilesBreak = 2;

//******************************************** TK_SCUScanDataThread.Execute ***
// Tasks Upload Thread Main loop
//
procedure TK_SCUScanDataThread.Execute;
begin
  SCURFileCont    := TStringList.Create;
  SCURFileLocCont := TStringList.Create;
  SCUSFileLocCont := TStringList.Create;
  SCUSFileCont    := TStringList.Create;
  SCUFilesList    := TStringList.Create;
  SCUDumpBuffer   := TStringList.Create;
  SCUT := TN_CPUTimer1.Create;
  SCUDevicePlatesClientUse := TStringList.Create;

  OnTerminate := SCUOnTerminate;
  SCUDump0( #13#10#13#10'****************** Upload Session Start ' +
            FormatDateTime( 'yyyy-mm-dd_hh":"nn":"ss.zzz'#13#10, Now() ) );

  try

    while TRUE do
    begin
      SCUTerminatedInfo := 'Execute >> before Remove Task';
      if Terminated then Break;
      // Try To Remove Task Files
      if (SCURemoveTasks <> nil) and (SCURemoveTasks.Count > 0) then
      begin
        SCUT.Start();
        Synchronize( SCUGetRemoveTask );
        SCUT.Stop();
        SCUDump( 'SCU> Sync SCUGetRemoveTask Time=' + SCUT.ToStr() );
      end;

      if SCURemoveSFile <> '' then
      begin
        SCUTerminatedInfo := 'Execute >> Remove Task';
        SCURemoveTaskFiles( SCURemoveSFile );
        SCURemoveSFile := '';
        SCURemoveInProcess := FALSE;
        if Terminated then
        begin
          SCUTerminatedInfo := SCUTerminatedInfo + '  || Execute >> after Remove Task';
          Break;
        end;
      end // end of Try To Remove Task Files
      else
      begin // Try To Upload Task Files
        SCUTerminatedInfo := 'Execute >> before Upload Task';
        if (SCUUploadTasks <> nil) and (SCUUploadTasks.Count > 0) then
        begin
          SCUT.Start();
          Synchronize( SCUGetUploadTask );
          SCUT.Stop();
          SCUDump( 'SCU> Sync  Time=' + SCUT.ToStr() );
        end;

        if SCUUploadQueryLocSFile <> '' then
        begin
        // Init Current task Upload Context
          SCUScanUploadCount := 0;
          SCURFileContState := '';
          SCUScanLocCount := -1; // initialized to prevent Local Task Remove on errors
          SCUTerminatedInfo := 'Execute >> Upload Task';
          SCUploadTaskFiles( SCUUploadQueryLocSFile );
          SCUUploadQueryLocSFile := '';
          SCUUploadInProcess := FALSE;

          SCUTerminatedInfo := 'Execute >> after Upload Task';
          if Terminated then
          begin
            SCUTerminatedInfo := SCUTerminatedInfo + '  || Execute >> after Upload Task';
            Break;
          end;
          SCUTipInfo := '';
          SCUT.Start();
          Synchronize( SCUChangeTrayTipInfo );
          SCUT.Stop();
          SCUDump( 'SCU> Sync SCUChangeTrayTipInfo Execute Time=' + SCUT.ToStr()  );
          if SCUTWTaskFlag then
          begin
            SCUDump( 'SCU> Remove TrueWeb Task' );
            SCURemoveTaskFiles( SCUScanTaskSFile );
          end;
          SCUTWTaskFlag := FALSE;
        end
        else
        begin
          SCUTerminatedInfo := 'Execute >> before Sleep';
          if Terminated then Break;
          Sleep(1000);
        end;
      end; // end of Try To Upload Task Files
    end; // while TRUE do

  except
    on E: Exception do
    begin
      SCUDump( 'SCU> Exception >> ' + E.Message  );
      SCUExceptionFlag := TRUE;
    end;
  end;
end; // procedure TK_SCUScanDataThread.Execute

//*********************************** TK_SCUScanDataThread.SCUAddUploadTask ***
// Add new Task to Upload Tasks Querry
//
procedure TK_SCUScanDataThread.SCUAddUploadTask( const ATaskSfile : string );
begin
  if SCUUploadTasks = nil then SCUUploadTasks := TStringList.Create;
  SCUUploadTasks.Add( ATaskSfile );
end; // procedure TK_SCUScanDataThread.SCUAddUploadTask

//*********************************** TK_SCUScanDataThread.SCUGetUploadTask ***
// Get Task from Upload Tasks Querry
//
procedure TK_SCUScanDataThread.SCUGetUploadTask( );
begin
  SCUUploadQueryLocSFile := '';
  SCUUploadInProcess := FALSE;
  if (SCUUploadTasks = nil) or (SCUUploadTasks.Count = 0) then Exit;
  SCUUploadQueryLocSFile := SCUUploadTasks[0];
  SCUUploadInProcess := TRUE;
  SCUUploadTasks.Delete(0);
  N_Dump1Str( 'SCU> New Task from Upload List >> ' + SCUUploadQueryLocSFile );
end; // procedure TK_SCUScanDataThread.SCUGetUploadTask

//*********************************** TK_SCUScanDataThread.SCUAddRemoveTask ***
// Add new Task to Remove Tasks Querry
//
procedure TK_SCUScanDataThread.SCUAddRemoveTask( const ATaskSfile : string );
var
  Ind : Integer;
begin
  if SCURemoveTasks = nil then SCURemoveTasks := TStringList.Create;
  Ind := SCURemoveTasks.IndexOf( ATaskSfile );
// 2015-01-28
//  if Ind >= 0 then
//    SCURemoveTasks.Delete( Ind )
//  else
//    SCURemoveTasks.Add( ATaskSfile );
// -->> replace by next operator
  if Ind < 0 then
    SCURemoveTasks.Add( ATaskSfile );

// Try to Remove this task from Uploads List
  if SCUUploadTasks = nil then Exit;
  Ind := SCUUploadTasks.IndexOf( ATaskSfile );
  if Ind < 0 then Exit;
  SCUUploadTasks.Delete( Ind );
  N_Dump1Str( 'SCU> Remove Task from Upload List >> ' +  ATaskSfile );
end; // procedure TK_SCUScanDataThread.SCUAddRemoveTask

//*********************************** TK_SCUScanDataThread.SCUGetRemoveTask ***
// Get Task from Remove Tasks Querry
//
procedure TK_SCUScanDataThread.SCUGetRemoveTask( );
begin
  SCURemoveSFile := '';
  SCURemoveInProcess := FALSE;
  if (SCURemoveTasks = nil) or (SCURemoveTasks.Count = 0) then Exit;
  SCURemoveSFile := SCURemoveTasks[0];
  SCURemoveInProcess := TRUE;
  SCURemoveTasks.Delete(0);
  N_Dump1Str( 'SCU> New Task from Remove List >> ' + SCURemoveSFile );
end; // procedure TK_SCUScanDataThread.SCUGetRemoveTask

//*********************************** TK_SCUScanDataThread.SCUChangeTrayTipInfo ***
// Get Task from Remove Tasks Querry
//
procedure TK_SCUScanDataThread.SCUChangeTrayTipInfo( );
begin
  if SCUTipInfo <> '' then
    K_FormCMScan.SCNewTrayTipInfo := K_FormCMScan.SCIniCaption + SCUTipInfo
  else
    K_FormCMScan.SCNewTrayTipInfo := K_FormCMScan.Caption;
  N_Dump2Str( 'SCU> TrayTipInfo =' + K_FormCMScan.SCNewTrayTipInfo );
end; // procedure TK_SCUScanDataThread.SCUChangeTrayTipInfo

//************************************* TK_SCUScanDataThread.SCUOnTerminate ***
// Upload Thread OnTerminate Handler
//
procedure TK_SCUScanDataThread.SCUOnTerminate(Sender: TObject);
begin
  FreeAndNil( SCUUploadTasks );
  FreeAndNil( SCURemoveTasks );
  FreeAndNil( SCURFileCont );
  FreeAndNil( SCURFileLocCont );
  FreeAndNil( SCUSFileLocCont );
  FreeAndNil( SCUSFileCont );
  FreeAndNil( SCUFilesList );
  FreeAndNil( SCUT );
  FreeAndNil( SCUDevicePlatesClientUse );

  N_Dump1Str( 'SCU> Upload Data Thread is terminated' );
  SCUDump0(  '****************** >> ' + SCUTerminatedInfo + #13#10 +
             '****************** Upload Session fin ' +
            FormatDateTime( 'yyyy-mm-dd_hh":"nn":"ss.zzz'#13#10, Now() ) );
  FreeAndNil( SCUDumpBuffer );
  K_FormCMScan.SCScanDataUploadThread := nil;
  if SCUExceptionFlag then
    Integer(K_FormCMScan.SCScanDataUploadThread) := -1;

//  K_FormCMScan.SCThreadException
end; // procedure TK_SCUScanDataThread.SCUOnTerminate

//******************************************* TK_SCUScanDataThread.SCUDump0 ***
// Upload Thread Dump
//
//     Parameters
// ADumpStr - dump info
//
procedure TK_SCUScanDataThread.SCUDump0( ADumpStr: string );
var
  F: TextFile;
  BufStr : string;
begin
  if SCULogFName = '' then Exit;
  try
    SCUDumpBuffer.Add( ADumpStr );
    Assign( F, SCULogFName );
    if not FileExists( SCULogFName ) then
      Rewrite( F )
    else
      Append( F );

    Inc(SCULogInd);
    BufStr := SCUDumpBuffer.Text;
    WriteLn( F, Copy( BufStr, 1, Length(BufStr) - 2 ) );
    SCUDumpBuffer.Clear;
    Flush( F );
  finally
    Close( F );
  end;
end; // procedure TK_SCUScanDataThread.SCUDump0

//******************************************** TK_SCUScanDataThread.SCUDump ***
// Upload Thread Dump
//
//     Parameters
// ADumpStr - dump info
//
procedure TK_SCUScanDataThread.SCUDump( ADumpStr: string );
begin
  SCUDump0( format( '%.3d> %s %s', [SCULogInd,
                        FormatDateTime( 'dd-hh":"nn":"ss.zzz', Now() ), ADumpStr] ) );
end; // procedure TK_SCUScanDataThread.SCUDump

//********************************* TK_SCUScanDataThread.SCUCheckConnection ***
// Check Connection to Exchange Folder
//
//    Parameters
// Result - Returns TRUE if Connection is OK, FALSE Connection was revived
//
function TK_SCUScanDataThread.SCUCheckConnection : Boolean;
var
  OnDataPathAccessLost : Boolean;
begin
  OnDataPathAccessLost := FALSE;
  Result := TRUE;
  while not DirectoryExists( K_CMScanDataPath ) do
  begin
    Result := FALSE;
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUCheckConnection >> wait connection';
      Exit;
    end;
    if not OnDataPathAccessLost then
    begin
      SCUDump( 'SCU> !!! ScanDataPath access has been lost' );
      OnDataPathAccessLost := TRUE;
    end;
    Sleep( 1000 );
  end;

  if not Result then
    SCUDump( 'SCU> !!! ScanDataPath access revive' );

end; // procedure TK_SCUScanDataThread.SCUCheckConnection

//************************************ TK_SCUScanDataThread.SCULoadTextFile ***
// Load Text File to given Strings
//
//    Parameters
// AFileName - file name to load
// AStrings  - Strings object to Load
// ANotSkipError - if TRUE then single attempt will be done
// Result - Returns TRUE if success
//
function TK_SCUScanDataThread.SCULoadTextFile( const AFileName : string;
                                               AStrings : TStrings;
                                               ANotSkipError : Boolean = FALSE ) : Boolean;
var
  ErrStr : string;
  ErrCode : Integer;
  ErrCount : Integer;
begin
  Result := FALSE;
  ErrCount := 0;
  while TRUE do
  begin
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCULoadTextFile >> load loop';
      Exit;
    end;
    SCUT.Start();
    ErrStr :=  K_VFLoadStrings1( AFileName, AStrings, ErrCode );
    SCUT.Stop();
    Result := ErrStr = '';
    if Result then Break;
    SCUDump( 'SCU> SCULoadTextFile Load Error >> ' + AFileName + #13#10'>>' + ErrStr );
    if ANotSkipError then Exit;
    Inc(ErrCount);
    if ErrCount >= K_SCUScanMaxWANErrCount then Exit;
    if SCUCheckConnection() then
      Sleep(1000);
  end; // while TRUE do

end; // function TK_SCUScanDataThread.SCULoadTextFile

//********************************* TK_SCUScanDataThread.SCULoadLocTextFile ***
// Load Local Text File to given Strings
//
//    Parameters
// AFileName - file name to load
// AStrings  - Strings object to Load
// ANotSkipError - if TRUE then single attempt will be done
// Result - Returns TRUE if success
//
function TK_SCUScanDataThread.SCULoadLocTextFile( const AFileName : string;
                                                  AStrings : TStrings;
                                                  ANotSkipError : Boolean = FALSE ) : Boolean;
var
  ErrStr : string;
  ErrCode : Integer;
  ErrCount : Integer;
begin
  Result := FALSE;
  ErrCount := 0;
  while TRUE do
  begin
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCULoadLocTextFile >> load loop';
      Exit;
    end;
    SCUT.Start();
    ErrStr :=  K_VFLoadStrings1( AFileName, AStrings, ErrCode );
    SCUT.Stop();
    Result := ErrStr = '';
    if Result then Break;
    SCUDump( 'SCU> SCULoadLocTextFile Load Error >> ' + AFileName + #13#10'>>' + ErrStr );
    if ANotSkipError or (ErrCode = Ord(K_dfrErrFileNotExists)) then Exit;
    Inc(ErrCount);
    if ErrCount >= K_SCUScanMaxLocErrCount then Exit;
    Sleep(1000);
  end; // while TRUE do

end; // function TK_SCUScanDataThread.SCULoadLocTextFile

//******************************* TK_SCUScanDataThread.SCUUpdateLocTextFile ***
// Update Local Text File to given Strings
//
//    Parameters
// AFileName - file name to load
// AStrings  - Strings object to Load
// ANotSkipError - if TRUE then single attempt will be done
// Result - Returns TRUE if success
//
function TK_SCUScanDataThread.SCUUpdateLocTextFile( const AFileName : string;
                                                  AStrings : TStrings;
                                                  ANotSkipError : Boolean = FALSE ) : Boolean;
var
  ErrCount : Integer;
begin
  Result := FALSE;
  ErrCount := 0;
  while TRUE do
  begin
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUUpdateLocTextFile >> save loop';
      Exit;
    end;
    SCUT.Start();
    Result := K_VFSaveStrings( AStrings, AFileName, K_DFCreatePlain );
    SCUT.Stop();
    if Result then Break;
    SCUDump( format( 'SCU> Update Local Task file Error >> %s', [AFileName] ) );
    if ANotSkipError then Exit;
    Inc(ErrCount);
    if ErrCount >= K_SCUScanMaxLocErrCount then Exit;
    Sleep(1000);
  end; // while TRUE do

end; // function TK_SCUScanDataThread.SCUUpdateLocTextFile

//********************************* TK_SCUScanDataThread.SCUUpdateTaskRFile ***
// Update Task RFile
//
procedure TK_SCUScanDataThread.SCUUpdateTaskRFile( );
begin
  if (SCUDevicePlatesClientUse.Count > 0) and
     (SCURFileCont.Values['IsDone'] = 'TRUE') then
  begin
    SCURFileCont.Add( '' );
    SCURFileCont.Add( '[DevicePlatesClient]' );
    SCURFileCont.AddStrings( SCUDevicePlatesClientUse );
    SCUDevicePlatesClientUse.Clear;
  end; // if (SCUDevicePlatesClientUse.Count > 0) and
       //    (SCURFileCont.Values['IsDone'] = 'TRUE') then

  while TRUE do
  begin // Update Task RFile Loop
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUUpdateTaskRFile >> save loop';
      Exit;
    end;

    SCUT.Start();
    if K_VFSaveStrings( SCURFileCont, SCUScanTaskRFile, K_DFCreatePlain ) then
    begin // File save OK
      SCUT.Stop();
      SCURFileContState := SCURFileCont.Values['IsDone'] + ' ' + SCURFileCont.Values['ScanCount'];
      SCUDump( format( 'SCU> Update Upload Task IsDone=%s Count=%s  R-file=%s',
                          [SCURFileCont.Values['IsDone'],
                           SCURFileCont.Values['ScanCount'],
                           K_CMScanGetFileCopyReport( ExtractFileName(SCUScanTaskRFile), Length(SCURFileCont.Text) + 1, SCUT )] ) );
      break;
    end   // File save OK
    else
    begin // File save Error
      SCUDump( format( 'SCU> Update Upload Task R-file Error >> %s',
                        [SCUScanTaskRFile] ) );
      if SCUCheckConnection() then
        Sleep( 1000 ); // Wait before continue
    end;  // File save Error
  end; // while TRUE do // Update Task RFile Loop
end; // function  TK_SCUScanDataThread.SCUUpdateTaskRFile

//************************* TK_SCUScanDataThread.SCUScanFilesTreeSelectFile ***
// Select Emergency Cache Files scan files subtree function
//
//     Parameters
// APathName - testing path
// AFileName - testing file name
//
function TK_SCUScanDataThread.SCUScanFilesTreeSelectFile( const APathName, AFileName: string ) : TK_ScanTreeResult;
begin
  Result := K_tucSkipSubTree;
  if AFileName = '' then
    Exit;
  SCUFilesList.Add(APathName + AFileName);
end; // end of TK_SCUScanDataThread.SCUScanFilesTreeSelectFile

//************************* TK_SCUScanDataThread.SCUScanFilesTreeSelectFile ***
// Remove Task Files given by Task S-file name
//
//     Parameters
// ASFileName - Task S-file name
//
procedure TK_SCUScanDataThread.SCURemoveTaskFiles( const ASFileName : string );
var
  TaskLocSFile : string;
  TaskLocRFile : string;
  LocTaskRemove : Boolean;
  LocTaskCount : Integer;
  TaskFilesCount : Integer;
  TaskFolder : string;
begin

  TaskLocSFile := K_FormCMScan.SCScanRootLocFolder + ExtractFileName(ASFileName);
  TaskLocRFile := K_SCGetTaskRSFileName( TaskLocSFile, 'R' );
//  if FileExists( TaskLocSFile ) then
  LocTaskRemove := FALSE; // should be not 0
  if SCULoadLocTextFile( TaskLocSFile, SCUSFileLocCont ) then
    LocTaskRemove := N_S2B( SCUSFileLocCont.Values['Remove'] );

  if not LocTaskRemove and SCULoadLocTextFile( TaskLocRFile, SCURFileLocCont ) then
  begin

    TaskFolder := K_SCGetTaskFolderName( TaskLocSFile );
    TaskFilesCount := K_CountFolderFiles( TaskFolder, '*.*', [] );

    LocTaskCount := StrToIntDef( SCURFileLocCont.Values['ScanCount'], -1 );
    LocTaskRemove := LocTaskCount < 0;

    if not LocTaskRemove and (TaskFilesCount = 2 * (LocTaskCount + 1) ) then
    begin
      SCURFileLocCont.Values['ScanCount'] := IntToStr(LocTaskCount + 1);
      if SCUUpdateLocTextFile( TaskLocRFile, SCURFileLocCont ) then
        SCUDump( 'SCU> Set Loc Update Info >> ' + SCUScanTaskLocRFile + ' >> ScanCount=' + IntToStr(LocTaskCount + 1) )
      else
      begin
        SCURFileLocCont.Values['ScanCount'] := IntToStr(LocTaskCount);
        SCUDump( 'SCU> !!! Set Loc Update Info Error >> ' + SCUScanTaskLocRFile + ' >> while ScanCount=' + IntToStr(LocTaskCount + 1) )
      end;
      LocTaskRemove := SCURFileLocCont.Values['ScanCount'] = '0';
    end;
  end
  else
    LocTaskRemove := TRUE;
    
  if (K_SCLocalFilesStorageThreshold <= 0) or LocTaskRemove then
  begin  // Remove Task Loc Files
    while not K_CMScanRemoveTask( 'SCU> RemoveTask Local >>', TaskLocSFile,
                               TaskLocRFile,
                               TaskFolder,
                               SCURFileLocCont, SCUT, SCUDump, SCUDump ) do
    begin  // Local Task Remove Error - by some file access conflict
      if Terminated then
      begin
        SCUTerminatedInfo := SCUTerminatedInfo + ' || SCURemoveTaskFiles >> remove loc task loop';
        Exit;
      end;
      SCUDump( 'SCU> Task Local Files Remove Error=' + TaskLocSFile );
      Sleep( 200 ); // Wait
    end; // while not K_CMScanRemoveTask
  end; // if not K_SCUseLocalFilesStorage or LocTaskRemove then

  // Remove Task Files
  while not K_CMScanRemoveTask( 'SCU> RemoveTask Main >>', ASFileName,
                             K_SCGetTaskRSFileName( ASFileName, 'R' ),
                             K_SCGetTaskFolderName( ASFileName ),
                             SCURFileLocCont, SCUT, SCUDump, SCUDump ) do
  begin  // Remove Task Files Error was detected
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCURemoveTaskFiles >> remove task loop';
      Exit;
    end;
    SCUDump( 'SCU> Task Files Remove Error=' + ASFileName );
    if SCUCheckConnection() then
      Sleep(1000);
  end;
end; // procedure TK_SCUScanDataThread.SCURemoveTaskFiles

//************************* TK_SCUScanDataThread.SCUScanFilesTreeSelectFile ***
// Upload Task Files given by Task S-file name
//
//     Parameters
// ASFileName - Task S-file name
//
procedure TK_SCUScanDataThread.SCUploadTaskFiles( const ASFileName: string );
var
  TaskWasFinished : Boolean;
//  TaskWasBroken : Boolean;
  Res : Integer;
  ReadFileRes : Boolean;

  ErrCount : Integer;

  LocTaskRemove : Boolean;
  TaskWasStarted : Boolean;
  WFileAge : TDateTime; // Exchange Task S-file Age

label RemoveLocTask;
begin
  // Prepare Task Local Buffer File Names
  SCUScanTaskLocSFile  := ASFileName;
  SCUScanTaskLocRFile  := K_SCGetTaskRSFileName( SCUScanTaskLocSFile, 'R' );
  SCUScanTaskLocFolder := K_SCGetTaskFolderName( SCUScanTaskLocSFile );
  SCUScanTaskLocUFile  := K_SCGetTaskRSFileName( SCUScanTaskLocSFile, 'U' );

  LocTaskRemove := FALSE;
  TaskWasFinished := FALSE;

  ////////////////////////////////////////////
  // Check Task Local Buffer R-file Existance
  //
  if K_GetFileAge(SCUScanTaskLocRFile) = 0 then
  begin // Upload Task file is not exist - Break Upload Task
    SCUDump( 'SCU> Break Upload Task >> Local Buffer R-file is absent >> ' + SCUScanTaskLocRFile );
    LocTaskRemove := TRUE;
    goto RemoveLocTask; // Clear Task in LocBuffer
  end;
  //
  // Check Task Local Buffer R-file Existance
  ////////////////////////////////////////////

  // Prepare Task Server File Names
  SCUScanTaskSFile  := K_FormCMScan.SCScanRootFolder + ExtractFileName(ASFileName);
  SCUScanTaskRFile  := K_SCGetTaskRSFileName( SCUScanTaskSFile, 'R' );
  SCUScanTaskFolder := K_SCGetTaskFolderName( SCUScanTaskSFile );

  ////////////////////////////////
  // Check Task S-file Existance
  //
  ErrCount := 0;
  while TRUE do // Copy Task S-file Loop
  begin
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadTaskFiles >> Check Task S-file Loop';
      Exit;
    end;
    WFileAge := K_GetFileAge( SCUScanTaskSFile );
    if WFileAge <> 0 then Break;
    SCUDump( 'SCU> Upload Task S-file is absent ' + SCUScanTaskSFile );
    Inc(ErrCount);
    if ErrCount >= 2 then
    begin
      SCUDump( 'SCU> Break Upload Task >> S-file is absent >> ' + SCUScanTaskSFile );
      goto RemoveLocTask; // Clear Task in LocBuffer
    end;
    if SCUCheckConnection() then
      Sleep(1000);
  end; // while ... // Check Task S-file Loop
  //
  // Check Task S-file Existance
  ////////////////////////////////

  ////////////////////////////////////
  // Copy Task S-file to local buffer (may be not used now)
  //
  if not FileExists(SCUScanTaskLocSFile) then
    while TRUE do // Copy Task S-file Loop
    begin
      if Terminated then
      begin
        SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadTaskFiles >> Copy Task S-file Loop';
        Exit;
      end;

      SCUT.Start();
      Res := K_CopyFile( SCUScanTaskSFile, SCUScanTaskLocSFile );
      SCUT.Stop();
      if Res = 0 then
      begin
        SCUDump( 'SCU> Start Upload Task S-file to LocBuffer Time=' + SCUT.ToStr() );
        Break;
      end;
      SCUDump( 'SCU> Start Upload Task S-file to LocBuffer Error=' + IntToStr(Res) );
      if SCUCheckConnection() then
        Sleep(1000);
    end; // while ... // Copy Task S-file Loop
  //
  // Copy Task S-file to local buffer
  ////////////////////////////////////

  //////////////////////////////////
  // Create Task Upload Folder Loop
  //
  while not DirectoryExists( SCUScanTaskFolder ) and
        not K_ForceDirPath( SCUScanTaskFolder ) do
  begin
   // Create Task Folder Loop if Error
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadTaskFiles >> Create Task Upload Folder Loop';
      Exit;
    end;

    SCUDump( 'SCU> Create Upload Task Folder Error ' + SCUScanTaskFolder );
    if SCUCheckConnection() then
      Sleep(1000);
  end; // while ...
  //
  // Create Task Upload Folder Loop
  //////////////////////////////////

  /////////////////////////////////////////////////////////////
  // Init Upload Task Files Counter. Needed if Data Upload is
  // continued after CMScan restart (not used now)
  // SCUScanUploadCount should be set -1 before start SCUploadTaskFiles
  //
  if SCUScanUploadCount < 0 then
  begin
  // Get Upload Task R-file Content
    ReadFileRes := SCULoadTextFile( SCUScanTaskRFile, SCURFileCont );
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadTaskFiles >> Read Task R-File';
      Exit;
    end;

    if not ReadFileRes then
    begin
      SCUDump( format( 'SCU> Break Upload Task >> R-file Error >> %s', [SCUScanTaskRFile] ) );
      Exit;
    end;

    SCUDump( 'SCU> Upload Task R-file ' +
              K_CMScanGetFileCopyReport( ExtractFileName(SCUScanTaskRFile),
                                    Length(SCURFileCont.Text) + 1, SCUT ) );
    SCUScanUploadCount := StrToIntDef( SCURFileCont.Values['ScanCount'], 0 );
  end;
  //  (not used now)
  // Init Upload Task Files Counter
  ///////////////////////////////////////////////


  ///////////////////////////////////////////////
  // Prepare SFileLoc Content to add Upload Info
  //
  if not SCULoadLocTextFile( SCUScanTaskLocSFile, SCUSFileLocCont ) then
  begin // Error Dump and break Upload Loop
    SCUDump( 'SCU> Break Upload Task >> Local S-file Error >> ' + SCUScanTaskLocSFile );
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadTaskFiles >> Prep Loc S-File';
      Exit;
    end;

    LocTaskRemove := TRUE;
    goto RemoveLocTask;
  end   // if not SCULoadLocTextFile( ...
  else
    LocTaskRemove := N_S2B( SCUSFileLocCont.Values['Remove'] );

  SCUTWTaskFlag := SCUSFileLocCont.IndexOf( '[WebAttrs]' ) >= 0;
  if SCUTWTaskFlag then
  begin                                 
    SCUDump( 'SCU> TrueWeb Task' );
    SCUAW1 := N_StringToWide( N_MemIniToString( 'CMS_UserMain', 'TrueWebUri', '' ) );
    SCUAW2 := N_StringToWide( SCUSFileLocCont.Values['token'] );
    SCUAW3 := N_StringToWide( SCUSFileLocCont.Values['patientId'] );
    SCUAW4 := N_StringToWide( SCUSFileLocCont.Values['patientName'] );
    SCUAW5 := N_StringToWide( SCUSFileLocCont.Values['patientSex'] );
    SCUAW6 := N_StringToWide( SCUSFileLocCont.Values['patientBirthDate'] );
    SCUAW7 := N_StringToWide( SCUSFileLocCont.Values['referringPhysician'] );
    SCUAW8 := N_StringToWide( SCUSFileLocCont.Values['locationId'] );
    SCUAW9 := N_StringToWide( SCUSFileLocCont.Values['studyUid'] );
    SCUAW10 := N_StringToWide( SCUSFileLocCont.Values['uidPrefix'] );
  end;
  //
  // Prepare SFileLoc Content to add Upload Info
  ///////////////////////////////////////////////

  ///////////////////////////
  // Upload Task Files Loop
  //
  Res := 0; // Set Upload Result code - OK
  ErrCount := 0;
  TaskWasStarted := TRUE;
  SCUScanTaskSFileAge := 0; // 2015-11-21 Clear S-file age before Loop start for real 1-st ckeck if file break;
  while TRUE do
  begin
    if not SCULoadLocTextFile( SCUScanTaskLocRFile, SCURFileLocCont ) then
    begin // Error Dump and break Upload Loop
      SCUDump( 'SCU> Break Upload Task >> Local R-file Error >> ' + SCUScanTaskLocRFile );
      if Terminated then
      begin
        SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadTaskFiles >> Update Loc R-File';
        Exit;
      end;

      break;
    end   // if not SCULoadLocTextFile( ...
    else
    begin // if SCULoadLocTextFile( ...

      // Check Local Task Updates
      SCURFileCont.Assign( SCURFileLocCont ); // ??? is really needed 2015-01-27
      TaskWasFinished := SCURFileLocCont.Values['IsDone'] = 'TRUE';
      SCUScanLocCount := StrToIntDef( SCURFileLocCont.Values['ScanCount'], 0 );

      if TaskWasStarted and TaskWasFinished and (SCUScanLocCount > 0) and not SCUTWTaskFlag then
      begin // Set R-file init Upload state for File Recovery Task (not Capture)
        SCURFileCont.Values['IsDone'] := 'FALSE';
        SCURFileCont.Values['ScanCount'] := '0';
        SCUUpdateTaskRFile();
      end;
      TaskWasStarted := FALSE;

      if SCUScanLocCount > SCUScanUploadCount then
      begin // Continue Task Files Upload
        Res := SCUploadNewTaskFiles( TaskWasFinished );
        if (Res <> scuCopyFilesOK) or TaskWasFinished then Break;
        if Terminated then
        begin
          SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadTaskFiles >> after SCUploadNewTaskFiles';
          Exit;
        end;
      end  // Continue Task Files Upload
      else
      if not SCUTWTaskFlag then
      begin
        if TaskWasFinished then
        begin // Set Task Finished State only
          SCURFileCont.Values['IsDone'] := 'TRUE';
          SCURFileCont.Values['ScanCount'] := IntToStr( SCUScanLocCount );
          SCUUpdateTaskRFile();
          Break;
        end // if TaskWasFinished then
        else
        begin // Check Task State if waiting for upload continue
          Res := SCUCheckCurTaskState( );
          if (Res = scuCopyFilesStop) or (Res = scuCopyFilesBreak) then Break;
        end;
      end // if not SCUTWTaskFlag then
      else
      if TaskWasFinished then
        Break;
    end; // if SCULoadLocTextFile( ...

    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadTaskFiles >> before wait sleep';
      Exit;
    end;

    Sleep( 500 );
    Inc(ErrCount);
    if (ErrCount mod 120) = 0 then
      SCUDump( format( 'SCU> Wait Task Upload Continue >> LC=%d %s', [ErrCount,SCUScanTaskLocRFile] ) );
  end; // while TRUE do
  //
  // Upload Task Files Loop
  ///////////////////////////

  SCUDump( 'SCU> Task Fin State=' + IntToStr(Res) );
  if Res <> scuCopyFilesStop then // = scuCopyFilesOK or = scuCopyFilesBreak
  begin // Remove Local Task if Task is not stoped (finished or terminated)

RemoveLocTask: //***************************
    if (K_SCLocalFilesStorageThreshold <= 0)       or
       ((SCUScanLocCount = 0) and TaskWasFinished) or
       LocTaskRemove then
    while not K_CMScanRemoveTask( 'SCU> Local on Task fin or break >>', SCUScanTaskLocSFile,
                               SCUScanTaskLocRFile, SCUScanTaskLocFolder,
                               SCURFileLocCont, SCUT, SCUDump, SCUDump ) do
    begin  // Local Task Remove Error - by some file access conflict
      SCUDump( 'SCU> Task Local Files Remove Error=' + SCUScanTaskLocSFile );
      if Terminated then
      begin
        SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadTaskFiles >> after Remove Loc Task Error';
        Exit;
      end;
      Sleep( 200 ); // Wait
    end;
  end;
end; // procedure TK_SCUScanDataThread.SCUploadTaskFiles

//******************************* TK_SCUScanDataThread.SCUploadNewTaskFiles ***
// Upload New Task Files
//
//    Parameters
// Result - Returns 0 if OK, 1 if Task is stoped, 2 if Task is broken
//
function TK_SCUScanDataThread.SCUploadNewTaskFiles( ATaskWasFinished : Boolean ) : Integer;

var
  i : Integer;
  PrevAFile : string;
  ScannedFile : string;
  F: TSearchRec;
  CopySuccessFlag : Boolean;
//  CurDate : TDateTime;
//  TaskState : string;
  RFileContState : string;
  CopyFullName, CopyFName : string;
  FNameCharInd : Integer;
  IsFastNet : Boolean;
  CompressRes : Integer;
  FSizes : array[0..1] of Integer;
  PSDIB : Pointer;
  SDIBSize : Integer;
  UDDIB : TN_UDDIB;
  CMEDResult : TK_CMEDResult;
  RIFileEncInfo : TK_RIFileEncInfo;
  RIResult : TK_RIResult;
  SResPatID : string;

  AW11, AW12, AW13, AW14 : WideString;
  PW1, PW2, PW3, PW4, PW5, PW6, PW7, PW8, PW9, PW10, PW11, PW12, PW13 : PWideChar;
  DFile: TK_DFile;
  DSize : Integer;
  ErrFlag : Boolean;
  ErrStr : string;
  WDbl : Double;
  UDSlide : TN_UDCMSlide;
  SendImageToRes : Integer;

  const WC: WideChar = #0;

label RetryLoop, ContLoop, ContCopy, FinLoop, CompressLoop, SkipFileByD4WMode, TWSkipData;

  //******************************* GetSourceFNameFromLocTask
  function GetSourceFNameFromLocTask( const AFileName : string; PUploadName : PString ) : string;
  begin
    Result := ExtractFileName( AFileName );
    SetLength( Result, Length(Result) - 6 );
    if PUploadName <> nil then
      PUploadName^ := Result;
    Result := SCUSFileLocCont.Values[Result];
  end; // function GetSourceFNameFromLocTask

  //******************************* BuildTaskFNameByAFName
  function BuildTaskFNameByAFName( const AFileName : string ) : string;
  var
    NameLeng : Integer;
  begin
    Result := ExtractFilePath(AFileName);
    NameLeng := Length(Result);
    Result[NameLeng] := '.';
    Result[NameLeng - 16] := 'S';
    Result := Result + 'txt';
  end; // function BuildTaskFNameByAFName

  //******************************* UpdateUploadInfo
  function UpdateUploadInfo( ASLideCount : Integer ) : Boolean;
  var
    UploadTS : string;
    UploadTSName : string;
    SourceFName : string;
//    NameLeng : Integer;
    CurUploadTS : string;
  begin
    SCURFileCont.Values['ScanCount'] := IntToStr( ASLideCount );

    RFileContState := SCURFileCont.Values['IsDone'] + ' ' + SCURFileCont.Values['ScanCount'];

    SCUDump( 'SCU> UpdateUploadInfo RFileContState ' + RFileContState );

    Result := not Terminated;
    if SCURFileContState = RFileContState  then Exit; // nothing to do

    SCUUpdateTaskRFile();
    SCUTerminatedInfo := 'SCUploadNewTaskFiles >> UpdateUploadInfo';
    if not Result then Exit;
    SCUScanUploadCount := ASLideCount;

    SCUTipInfo := format( #13#10'Upload data (%d objects done)', [SCUScanUploadCount] );
    SCUT.Start();
    Synchronize( SCUChangeTrayTipInfo );
    SCUT.Stop();
    SCUDump( 'SCU> Sync SCUChangeTrayTipInfo UpdateUploadInfo Time=' + SCUT.ToStr() +
             SCUTipInfo + #13#10 +
             'Set Update Info about ' + PrevAFile );

    if PrevAFile = '' then Exit;

  // Add Cur Slide Update Info to S-file
//    UploadTSName := ExtractFileName( PrevAFile );
//    SetLength( UploadTSName, Length(UploadTSName) - 6 );
//    SourceFName := SCUSFileLocCont.Values[UploadTSName];
    SourceFName := GetSourceFNameFromLocTask(PrevAFile, @UploadTSName);
    PrevAFile := '';

    UploadTS := K_DateTimeToStr( Now(), 'yymmddhhnnss' );

    if SourceFName = '' then
    begin // Online Task Upload - save Upload Timestamp in Current Task Local S-file
      SCUSFileLocCont.Add( UploadTSName + '=' + UploadTS );
      Result := SCUUpdateLocTextFile( SCUScanTaskLocSFile, SCUSFileLocCont );
      SCUDump( 'SCU> Set Update Info >> ' + SCUScanTaskLocSFile + ' >> ' + SCUSFileLocCont[SCUSFileLocCont.Count-1] );
    end
    else  // if SourceFName <> '' then
    begin // Recovery Task Upload - save Upload Timestamp in Source Task Local S-file
      UploadTSName := ExtractFileName( SourceFName );
      SourceFName := BuildTaskFNameByAFName(SourceFName);
//      SourceFName := ExtractFilePath(SourceFName);
//      NameLeng := Length(SourceFName);
//      SourceFName[NameLeng] := '.';
//      SourceFName[NameLeng - 16] := 'S';
//      SourceFName := SourceFName + 'txt';
      Result := SCULoadLocTextFile( SourceFName, SCUSFileCont );
      if Result then
      begin // Set Upload Info

        if SCUSFileCont.Values['CurPatID'] = '' then
          UploadTS := UploadTS + K_FormCMScan.SCScanTaskPatName;  // Add Patient Info for Offline Capture Results

        CurUploadTS := SCUSFileCont.Values[UploadTSName];
        if CurUploadTS = '' then
          SCUSFileCont.Add( UploadTSName + '=' + UploadTS )
        else // Mark Multi Recovering by *
          SCUSFileCont.Values[UploadTSName] := format( '%s*%s*',
                                         [Copy(CurUploadTS, 1, 12), UploadTS] );
        // SCUSFileCont.Values[UploadTSName] := UploadTS + '*';
        Result := SCUUpdateLocTextFile( SourceFName, SCUSFileCont );
        SCUDump( 'SCU> Set Update Info >> ' + SourceFName + ' >> ' + SCUSFileCont.Values[UploadTSName] );
      end; // if Result then

    end; // if SourceFName <> '' then
    if not Result then // Final Error Dump
      SCUDump( 'SCU> Set Update Info Error!!!' );
  end; // function UpdateUploadInfo( ASLideNum : Integer ) : Boolean;

begin
  Result := scuCopyFilesOK;
  UDSlide := nil;
  ErrFlag := FALSE;
//  if SCUTWTaskFlag then
//  begin
//  end;

  i := 0;
  if FindFirst( SCUScanTaskLocFolder + '*.*', faAnyFile, F ) <> 0 then
  begin
    SCUDump( 'SCU> UploadTaskNewFiles >> FindFirst not found' );
    Exit;
  end;

  IsFastNet := FALSE;
  repeat // skip fisrt '.'
    if (F.Name[1] <> '.') and ((F.Attr and faDirectory) = 0) then
      goto ContCopy;
  until FindNext( F ) <> 0; // End of Files Upload Loop

  SCUDump( format( 'SCU> UploadTaskNewFiles >> Empty LocBufer Task S-file=%s',
                   [SCUScanTaskSFile] ) );
  Exit;

ContCopy:
  // Files Upload Loop
  SCUDump( format( 'SCU> Upload Loop for %d slides is started from Ind=%d S-file=%s',
              [SCUScanLocCount, SCUScanUploadCount, SCUScanTaskSFile] ) );
  SCURFileCont.Values['IsDone'] := K_CMScanTaskIsUploaded;
  PrevAFile := '';
  if K_CMScanDataForD4W then
  begin
    RIFileEncInfo.RIFileEncType   := rietPNG;
    RIFileEncInfo.RIFComprType    := rictPNG;
    RIFileEncInfo.RIFComprQuality := 0;
    // Define Resulting Patient ID
    SResPatID := '';
    CopyFName := GetSourceFNameFromLocTask( SCUScanTaskLocFolder + F.Name, nil );
    if CopyFName <> '' then
    begin // Recovery - get Patient form recovery task
      CopyFName := BuildTaskFNameByAFName( CopyFName );
      SCULoadLocTextFile( CopyFName, SCUSFileCont );
      SResPatID := SCUSFileCont.Values['CurPatID'];
      if SResPatID <> '' then
      begin
        SCURFileCont.Add( 'CurPatID='+SResPatID );
        SCUUpdateTaskRFile();
      end;
    end;

//    if SResPatID = '' then // for recovery offline scanned data or if Online Scaning is done
//      SResPatID := IntToStr(K_CMEDAccess.CurPatID)
  end; // if K_CMScanDataForD4W then

  repeat

    ScannedFile := SCUScanTaskLocFolder + F.Name;
    FNameCharInd := Length(ScannedFile) - 4;

    if ScannedFile[FNameCharInd] = 'A' then
    begin // Slide Start File
      // Correct R-file by Slides Count
      if i > SCUScanUploadCount then
      begin
        SCUDump( 'SCU> before UpdateUploadInfo 1' );
        if not UpdateUploadInfo( i ) then goto FinLoop;
      end; // if i > SCUScanUploadCount then

      // All Ready Slides are copied - copy loop should be broken
      if not ATaskWasFinished and (i = SCUScanLocCount) then Break;

      Inc(i); // New Slide is started - i = New Slide counter

      PrevAFile := ScannedFile; // Store A-file name
    end; // if ScannedFile[Ind] = 'A' then

    if i <= SCUScanUploadCount then
    begin // File was already copied, Try Next File
      PrevAFile := ''; // clear PrevAFile for Files copied early (in previouse call to SCUploadNewTaskFiles)
      SCUDump( format( 'SCU> UploadTaskNewFiles >> File %s is already copied', [F.Name] ) );
      goto ContLoop;
    end;

    if not SCUTWTaskFlag then
    begin
      //  Check Task S-file Content
      case SCUCheckCurTaskState( ) of
        scuFileReadError : begin
          SCUDump( 'SCU> Break Upload Task >> S-file Error >> ' + SCUScanTaskSFile );
          goto FinLoop;
        end;
        scuCopyFilesBreak : Result := scuCopyFilesBreak;
        scuCopyFilesStop  : Result := scuCopyFilesStop;
      end; // case SCUCheckCurTaskState( ) of
      if Result <> scuCopyFilesOK then goto FinLoop; // Task is broken
//    if Terminated then goto FinLoop;
    end; // if not SCUTWTaskFlag then

    ///////////////////////
    // D4W Upload mode
    //
    if K_CMScanDataForD4W or SCUTWTaskFlag then
    begin
      if (ScannedFile[FNameCharInd] = 'A') and SCUTWTaskFlag then
      begin
        if SCUAW1 = '' then
        begin
          ErrFlag := FALSE;
          ErrStr := 'SCU> UploadTaskNewFiles >> empty uri';
          goto TWSkipData;
        end;
        ErrFlag := K_DFOpen( ScannedFile, DFile, [K_dfoProtected] );
        if not ErrFlag then
        begin // open error
          ErrStr := format( 'SCU> UploadTaskNewFiles >> Open error="%s" File=%s',
                          [K_DFGetErrorString(DFile.DFErrorCode), ScannedFile] );
TWSkipData: //*****
          SCUDump( ErrStr );
          goto ContLoop;
        end   // open error
        else
        begin // not open error
          DSize := DFile.DFPlainDataSize;
          if SizeOf(Char) = 2 then
            DSize := DSize shr 1;
          SetLength( K_CMEDAccess.StrTextBuf, DSize );
          ErrFlag := K_DFReadAll( @K_CMEDAccess.StrTextBuf[1], DFile );
          if not ErrFlag then
          begin
            ErrStr := format( 'SCU> UploadTaskNewFiles Read error="%s" File=%s',
                        [K_DFGetErrorString(DFile.DFErrorCode), ScannedFile] );
            goto TWSkipData;
          end;
          K_SerialTextBuf.LoadFromText( K_CMEDAccess.StrTextBuf );
          UDSlide := TN_UDCMSlide( K_LoadTreeFromText( K_SerialTextBuf ) );
          ErrFlag := UDSlide <> nil;
          if not ErrFlag then
          begin // K_LoadTreeFromText error
            ErrStr := format( 'SCU> UploadTaskNewFiles Wrong File Format File=%s',
                        [ScannedFile] );
            goto TWSkipData;
          end; // K_LoadTreeFromText error
        end; // not open error
      end // if (ScannedFile[FNameCharInd] = 'A') and SCUTWTaskFlag then
      else
      if ScannedFile[FNameCharInd] = 'R' then
      begin

        if SCUTWTaskFlag then
        begin // Check A-flie errors or empty uri in TrueWeb mode
          if not ErrFlag then
          begin // if A-flie errors or empty uri in TrueWeb mode
            Dec(i);
            goto ContLoop;
          end; // if SCUTWTaskFlag and not ErrFlag
        end; // Check A-flie errors or empty uri in TrueWeb mode

        CMEDResult := K_CMEDAccess.EDASlideDataFromFile( PSDIB, SDIBSize, ScannedFile, CompressRes );
        if K_edOK <> CMEDResult then
        begin
          SCUDump( format( 'SCU> UploadTaskNewFiles >> D4W or TrueWeb mode >> EDASlideDataFromFile %s Res=%d', [F.Name, Ord(CMEDResult)] ) );
          Dec(i);
        end   // if K_edOK <> CMEDResult then
        else
        begin // if K_edOK = CMEDResult then
          UDDIB := K_CMCreateUDDIBBySData( PSDIB, SDIBSize );
          if UDDIB = nil then
          begin
            SCUDump( format( 'SCU> UploadTaskNewFiles >> D4W or TrueWeb mode >> K_CMCreateUDDIBBySData %s error', [F.Name] ) );
            Dec(i);
          end   // if UDDIB = nil then
          else
          begin // if UDDIB <> nil then
            UDDIB.LoadDIBObj();
//            CopyFName := format( '%s_%d.png', [SResPatID, i] );
            if not SCUTWTaskFlag then
            begin // D4W - save image as *.png
              CopyFName := format( '%d.png', [i] );
              RIResult := K_RIObj.RISaveDIBToFile( UDDIB.DIBObj, SCUScanTaskFolder + CopyFName, @RIFileEncInfo );
              if rirOK <> RIResult then
              begin
                SCUDump( format( 'SCU> UploadTaskNewFiles >> D4W mode >> RISaveDIBToFile %s Res=%d', [CopyFName, Ord(RIResult)] ) );
                Dec(i);
              end
              else
                SCUDump( format( 'SCU> UploadTaskNewFiles >> D4W mode >> RISaveDIBToFile %s', [CopyFName] ) );
            end   // if not SCUTWTaskFlag then
            else
            begin // if SCUTWTaskFlag then
              with UDSlide.P^ do
              begin

                AW11 := N_StringToWide( SCUSFileLocCont.Values['uidPrefix'] + '.' + IntToStr(i) );
                AW12 := N_StringToWide( K_CMDCMDefineSlideSOPClassUID( UDSlide, not (cmsfGreyScale in CMSDB.SFlags) ) );
                AW13 := N_StringToWide( CMSDB.DCMModality );

                WDbl := Round(72 * 100 / 2.54) / 1000;
                if CMSDB.SFlags * [cmsfProbablyCalibrated,cmsfUserCalibrated,cmsfAutoCalibrated] <> [] then
                  WDbl := CMSDB.PixPermm;
                WDbl := Round(1 / WDbl * 10000) / 10000;
                AW14 := N_StringToWide( FloatToStr( WDbl ) );

              end;
              PW1 := @WC; PW2 := @WC; PW3 := @WC; PW4 := @WC; PW5 := @WC;
              PW6 := @WC; PW7 := @WC; PW8 := @WC; PW9 := @WC; PW10 := @WC;
              PW11 := @WC; PW12 := @WC; PW13 := @WC;

              if SCUAW1 <> '' then
                PW1 := @SCUAW1[1];
              if SCUAW2 <> '' then
                PW2 := @SCUAW2[1];
              if SCUAW3 <> '' then
                PW3 := @SCUAW3[1];
              if SCUAW4 <> '' then
                PW4 := @SCUAW4[1];
              if SCUAW5 <> '' then
                PW5 := @SCUAW5[1];
              if SCUAW6 <> '' then
                PW6 := @SCUAW6[1];
              if SCUAW7 <> '' then
                PW7 := @SCUAW7[1];
              if SCUAW8 <> '' then
                PW8 := @SCUAW8[1];
              if SCUAW9 <> '' then
                PW9 := @SCUAW9[1];
              if SCUAW10 <> '' then
                PW10 := @SCUAW10[1];
              if AW11 <> '' then
                PW11 := @AW11[1];
              if AW12 <> '' then
                PW12 := @AW12[1];
              if AW13 <> '' then
                PW13 := @AW13[1];
              SendImageToRes := K_DCMSCWEBGLib.SDLSendImageTo( PW1, PW2, PW3, PW4, PW5, PW6, PW7, PW8, PW9, PW10, PW11, PW12, PW13,
                                             @AW14[1], @AW14[1],
                                             UDDIB.DIBObj.DIBNumBits, @UDDIB.DIBObj.DIBInfo.bmi, UDDIB.DIBObj.PRasterBytes );
              SCUDump( format( 'SCU> TrueWeb mode >> SendImageTo >> Res=%d', [SendImageToRes] ) );
            end;  // if not SCUTWTaskFlag then

            FreeAndNil( UDDIB );
            FreeAndNil( UDSlide );
          end;
        end; // if K_edOK = CMEDResult then
      end  // if ScannedFile[FNameCharInd] = 'R' then
      else
      if ScannedFile[FNameCharInd] = 'V' then
      begin // Skip source image file video file
        Dec(i);
        goto SkipFileByD4WMode;
      end // if ScannedFile[FNameCharInd] = 'V' then
      else
      if ScannedFile[FNameCharInd] = 'S' then
      begin // Skip source image file
SkipFileByD4WMode: //*******
        SCUDump( format( 'SCU> UploadTaskNewFiles >> D4W or TrueWeb mode >> Skip copy %s', [F.Name] ) );
      end; // if ScannedFile[FNameCharInd] = 'S' then

      goto ContLoop;
    end; // if K_CMScanDataForD4W then
    //
    // D4W Upload mode
    ///////////////////////

    ///////////////////////
    // Task File Upload Loop
    //
    FSizes[1] := F.Size;
    if IsFastNet or (ScannedFile[FNameCharInd] <> 'V') then
    begin // skip compression for A-file and Image Files (they are already compressed)
      CopyFullName := ScannedFile;
      CopyFName    := F.Name;
    end
    else
    begin // if not IsFastNet and (ScannedFile[FNameCharInd] = 'V') then
      CopyFName := F.Name  + '.z';
      CopyFullName := K_ExpandFileName( '(#TmpFiles#)'+ CopyFName );
CompressLoop: //***********
      SCUT.Start();
      CompressRes := Ord(K_VFCopyFile1( ScannedFile, CopyFullName,
                           [K_vfcCompressSrc0,K_vfcOverwriteNewer], @FSizes[0] ));
      SCUT.Stop();
      if Ord(K_vfcrOK) <> CompressRes then
      begin
        if Terminated then
        begin
          SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadNewTaskFiles >> CompressLoop';
          goto FinLoop;
        end;
        SCUDump( format( 'SCU> UploadTaskNewFiles >> File %s Compress Error=%d',
                       [F.Name, CompressRes] ) );
        Sleep(1000);
        goto CompressLoop;
      end
      else
        SCUDump( format( 'SCU> UploadTaskNewFiles >> File %s Compress from %d to %d Time=%s',
                       [F.Name, FSizes[0], FSizes[1], SCUT.ToStr()] ) );

    end; // if not IsFastNet and (ScannedFile[FNameCharInd] = 'V') then

RetryLoop: //***********
    if Terminated then
    begin
      SCUTerminatedInfo := SCUTerminatedInfo + ' || SCUploadNewTaskFiles >> RetryLoop';
      goto FinLoop;
    end;
    SCUT.Start();
//    CopySuccessFlag := CopyFile( PChar(ScannedFile), PChar( SCUScanTaskFolder + F.Name ), false );
    CopySuccessFlag := CopyFile( PChar(CopyFullName),
                                 PChar( SCUScanTaskFolder + CopyFName ), false );
    SCUT.Stop();
//      CopyFilesFlag := CopyFilesFlag or NoCopyErrFlag;
    if not CopySuccessFlag then
    begin
      SCUDump( format( 'SCU> UploadTaskNewFiles >> File %s Size=%d copy Error >> %s',
                       [CopyFName, FSizes[1], SysErrorMessage(GetLastError())] ) );
      if SCUCheckConnection() then
        Sleep(1000);
      goto RetryLoop;
    end  // if not CopySuccessFlag then
    else // Copy File Report
    begin
      SCUDump( 'SCU> Upload >> ' +
               K_CMScanGetFileCopyReport( CopyFName, FSizes[1], SCUT ) );
      // if Network Speed >= 4 MB/Sec files precompression is not needed
      IsFastNet := 4 <= FSizes[1] / 1024 / 1024 / SCUT.DeltaCounter * N_CPUFrequency;
    end;
    //
    // Task File Upload Loop
    ///////////////////////

ContLoop: //***********

  until FindNext( F ) <> 0; // End of Files Upload Loop

  SCUScanUploadCount := i; // All Results are copied

//  if not SCUTWTaskFlag then
  begin // Write Fin Results to Exchange Folder
    if ATaskWasFinished then
      SCURFileCont.Values['IsDone'] := 'TRUE';

    SCUDump( 'SCU> before UpdateUploadInfo 2' );
    UpdateUploadInfo( SCUScanUploadCount );
  end; // if not SCUTWTaskFlag then
  
FinLoop:   //***********
//  if (scuCopyFilesOK = 0) and Terminated then Result := scuCopyFilesBreak;
  FindClose( F );
end; // function TK_SCUScanDataThread.SCUploadNewTaskFiles

//******************************* TK_SCUScanDataThread.SCUCheckCurTaskState ***
// Check Current Task State by S-file
//
//    Parameters
// Result - Returns -1 if read S-file error, 0 if OK, 1 if Task is stoped, 2 if Task is broken
//
function TK_SCUScanDataThread.SCUCheckCurTaskState( ) : Integer;

var
  CurDate : TDateTime;
  TaskState : string;

begin
  Result := scuCopyFilesOK;
  // Get Task S-file Content
  CurDate := K_GetFileAge( SCUScanTaskSFile );
  if CurDate = SCUScanTaskSFileAge then Exit;

  if CurDate = 0 then
  begin
    Result := scuFileReadError;
    SCUDump( 'SCU> Task S-file Age=0' );
    Exit;
  end;

  // Check Task State
  SCUScanTaskSFileAge := CurDate;
  if not SCULoadTextFile( SCUScanTaskSFile, SCUSFileCont ) then
  begin
    Result := scuFileReadError;
    Exit;
  end;
  SCUDump( 'SCU> Task S-file ' +
            K_CMScanGetFileCopyReport( ExtractFileName(SCUScanTaskSFile),
                                       Length(SCUSFileCont.Text) + 1, SCUT ) );
  TaskState := SCUSFileCont.Values['IsTerm'];
  if N_S2B( TaskState ) then Result := scuCopyFilesBreak
  else
  if TaskState = K_CMScanTaskIsStopped then Result := scuCopyFilesStop;
end; // function TK_SCUScanDataThread.SCUCheckCurTaskState

{*** end of TK_SCUScanDataThread ***}

end.
