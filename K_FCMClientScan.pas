unit K_FCMClientScan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  N_BaseF, N_Types, N_Lib0,
  K_Types, K_CM0;

type TK_SCDScanDataThread = class (TThread)

///////////////////////////////////////////////////////
// Download Context - should be set by thread creator
//
  SCDScanTaskLocFolder : string; // Task Local Folder
  SCDScanTaskLocRFile  : string; // Task Local R-file
  SCDScanTaskLocSFile  : string; // Task Local S-file
  SCDScanStateLocFile  : string; // CMScan Local State file
  SCDScanTaskFolder : string; // Exchange Task Folder
  SCDScanTaskRFile  : string; // Exchange Task R-file
  SCDScanTaskSFile  : string; // Exchange Task S-file
  SCDScanStateFile  : string; // CMScan State file
  SCDScanTaskNameFile : string; // CMScan Current Task Name file
//
// Download Context - should be set by thread creator
///////////////////////////////////////////////////////

  SCDScanRCount        : Integer;
  SCDScanDownloadCount : Integer;
//  SCDBreakDownloadFlag : Boolean; // Break Download Loop if "Cancel" is pressed
  SCDBreakDownloadState : Byte; // Break Download Loop if "Cancel" is pressed
                                // 0 - break is not done
                                // 1 - stop is needed
                                // 2 - break is needed
  SCDSetTaskTermFlag   : Boolean; // Set Task Terminated Flag
  SCDFinActionCode  : Integer;  //!!!old 0 - write STOP to S-file, 1 - write TERM to S-file, 2 - Remove Task
                                //!!!now 0 - write STOP to S-file, 2 - Remove Task
  SCDRFileCont, SCDRFileLocCont, SCDFilesList : TStringList;
  SCDT : TN_CPUTimer1; // Timer for measuring one time interval

  SCDRFileContState : string;

  SCDLogInd : Integer;
  SCDLogFName : string;


  SCDDumpBuffer : TStringList;

  SCDTerminatedInfo : string;

  SCDCurScanDataPath : string;

  procedure Execute(); override;

  procedure SCDOnTerminate( Sender: TObject );

  procedure SCDDump0( ADumpStr : string );
  procedure SCDDump( ADumpStr : string );

  function  SCDCheckConnection( ATimout : Integer ) : Boolean;
  function  SCDLoadTextFile( const AFileName : string;
                             AStrings : TStrings; ANotSkipError : Boolean = FALSE ) : Boolean;
  procedure SCDUpdateTaskLocRFile();
//  function  SCDScanFilesTreeSelectFile( const APathName, AFileName: string ) : TK_ScanTreeResult;
  function  SCDownloadNewTaskFiles( ATaskWasFinished : Boolean  ) : Integer;
end; // type TK_SCDScanDataThread = class (TThread)

type TK_CMScanState = (
  K_ScanIsNotStarted,
  K_ScanDeviceIsNotStarted,
  K_ScanDeviceIsStarted,
  K_ScanTaskIsFinished
); // type TK_CMScanState

type TK_CMScanSelfState = (
  K_ScanSelfIsNotStarted,
  K_ScanSelfReady,
  K_ScanSelfSetup,
  K_ScanSelfDoOtherTask,
  K_ScanSelfMoveToNewFolder,
  K_ScanSelfDoCurTask
); // type TK_CMScanSelfState

type
  TK_FormCMClientScan = class(TN_BaseForm)
    BtCancel: TButton;
    PnState: TPanel;
    ActTimer: TTimer;
    procedure ActTimerTimer(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    SCSTask : TStringList;
    SCRTask : TStringList;
    SCScanCount : Integer;    // Scan Slides Counter
    SCInfoState : TK_CMScanState;    // Scan Info State: 0 - waiting for Software Start
                                         //                  1 - waiting for scan begin
                                         //                  2 - waiting for scan finish
                                         //                  3 - scan is finished
    SCScanSelfState : TK_CMScanSelfState;    // Client Scanner State: 0 - is not launched, 1 - wait, 2 - setup, 3 - do other task, 4 - do cur task
    SCRFileName : string;      // Task R-file name
    SCSFileName : string;      // Task S-file name
    SCTaskFolder: string;      // Task Folder name
    SCTaskID : string;         // Task ID
    SCStateFileName : string;  // Client Scanner State File Name
    SCTranspFileName : string; // Client Scanner Transport to new folder File Name
    SCCurTaskFileName: string; // Current Task File Name
    SCScanInfoWateCount : Integer;
    SCRFileDate : TDateTime;
    SCStateFileDate : TDateTime;

    SCTermTaskFlag : Boolean;

    function  SCUpdateTaskRFile() : Boolean;
    function  SCUpdateScanSelfStateByFile() : TK_CMScanSelfState;
    function  SCGetTaskSlides( ACount : Integer; out APatID : Integer ) : TN_UDCMSArray;
    function  SCGetFileCopyReport( const AFName : string; AFSize : Integer ) : string;
    function  SCUpdateTextFile( ASStrings : TStrings; const ASFileName : string ) : string;
    procedure SCClearCurTaskNameFile();
  end; // TK_FormCMClientScan


var
  K_FormCMClientScan: TK_FormCMClientScan;





function K_FCMClientScanDlg() : Integer;

procedure K_AddDevicePlatesTotalInfoToTask( ASL : TStrings );
procedure K_AddDevicePlatesClientInfoToTask( ASL : TStrings );
procedure K_GetDevicePlatesClientInfoFromTaskToDB( ASL : TStrings );


implementation
uses Math, DB,
K_CLib0, K_UDT2, K_UDC, K_Script1, K_STBuf, K_CML1F, K_CM1, K_FCMSetSlidesAttrs2,
N_Lib1, N_CMMain5F, L_VirtUI;                     ////Igor 16092020

{$R *.dfm}

const
K_SCLaunchMes = '   Starting capture software';
K_SCCaptureStartMes = '   Waiting for the capture to start';
K_SCCaptureFin  = '   Transfering capture results (%d objects done)';
K_SCCaptureFin1 = '   Transfering capture results download (%d objects done)';
// Starting capture software, %d s
// Waiting for capture start, %d s
// Waiting for capture results (2 objects done), %d s

const K_SCDScanMaxWANErrCount = 20;
const K_SCDScanMaxLocErrCount = 10;

//**************************************************** K_ClientScanLoadText ***
// Load Text File to K_CMEDAccess.TmpStrings
//
//    Parameters
//  AFileName - file name to load
//  AText     - string buffer
//  Result - Returns TRUE if success
//
function K_ClientScanLoadText( const AFileName : string; var AText : string ) : Boolean;
var
  ErrStr : string;
  ErrCode : Integer;

begin
  N_T1.Start();
  ErrStr := K_VFLoadText1( AFileName, AText, ErrCode );
  N_T1.Stop();
  Result := ErrStr = '';
  if Result then Exit;
  N_Dump1Str( format( 'ClientScan Load Error Time=%s >> %s'#13#10'>> %s',
                      [N_T1.ToStr(),AFileName,ErrStr] ) );
end; // function K_ClientScanLoadText

//************************************************* K_ClientScanLoadStrings ***
// Load Text File to K_CMEDAccess.TmpStrings
//
//    Parameters
//  AFileName - file name to load
//  AStrings  - strings object to load file
//  Result - Returns TRUE if success
//
function K_ClientScanLoadStrings( const AFileName : string; AStrings : Tstrings ) : Boolean;
var
  BufStr : string;
begin
  Result := K_ClientScanLoadText( AFileName, BufStr );
  if Result then
    AStrings.Text := BufStr
  else
    AStrings.Clear;
end; // function K_ClientScanLoadStrings

procedure K_AddDevicePlatesTotalInfoToTask( ASL : TStrings );
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
      with CurDSet1 do
      begin
        // Select from Device
        Connection := LANDBConnection;
        SQL.Text := 'select distinct S.Name, S.Count FROM ' +
        '(SELECT ' + K_CMENDDPTID + ' as ID,' +
                     K_CMENDDPTName + ' as Name,' +
                     K_CMENDDPTCount + ' as Count ' +
        ' FROM ' + K_CMENDBDevicePlatesTotalUseTable + ') S ' +
        ' JOIN ' +
        '(SELECT ' + K_CMENDDPCID + ' as ID,' + K_CMENDDPCUpdateDT  + ' as DT ' +
        ' FROM ' + K_CMENDBDevicePlatesClientUseTable +
        ' WHERE ' + K_CMENDDPCUpdateDT + ' > ' + EDADBDateTimeToSQL(Now() - 365) + ' ) Q ' +
        ' ON S.ID = Q.ID';
        Filtered := false;
        Open;

        ASL.Add( #13#10'[DevicePlatesTotal]');
        N_Dump2Str( ASL[ASL.Count-1] );
        First;
        while not EOF do
        begin
          ASL.Add( Fields[0].AsString + '=' + Fields[1].AsString );
          N_Dump2Str( ASL[ASL.Count-1] );
          Next;
        end;
        Close();
      end
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'K_AddDevicePlatesTotalInfoToTask ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do
end; // procedure K_AddDevicePlatesTotalInfoToTask

procedure K_AddDevicePlatesClientInfoToTask( ASL : TStrings );
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
      with CurDSet1 do
      begin
        // Select from Device
        Connection := LANDBConnection;
        SQL.Text := 'select S.Name, Q.DT FROM ' +
        '(SELECT ' + K_CMENDDPCID + ' as ID,' + K_CMENDDPCUpdateDT  + ' as DT ' +
        ' FROM ' + K_CMENDBDevicePlatesClientUseTable +
        ' WHERE ' + K_CMENDDPCUpdateDT + ' > ' + EDADBDateTimeToSQL(Now() - 365) +
        ' AND ' +  K_CMENDDPCClientID + ' = ' + IntToStr(ClientAppGlobID) + ') Q ' +
        ' JOIN ' +
        '(SELECT ' + K_CMENDDPTID + ' as ID,' +
                     K_CMENDDPTName + ' as Name' +
        ' FROM ' + K_CMENDBDevicePlatesTotalUseTable + ') S ' +
        ' ON S.ID = Q.ID';

        Filtered := false;
        Open;

        ASL.Add( #13#10'[DevicePlatesClient]' );
        N_Dump2Str( ASL[ASL.Count-1] );
        First;
        while not EOF do
        begin
          ASL.Add( Fields[0].AsString + '=' +
            K_DateTimeToStr( TDateTimeField(Fields[1]).Value, 'yyyymmddhhnnss' ) );
          N_Dump2Str( ASL[ASL.Count-1] );
          Next;
        end;
        Close();
      end
    except
      on E: Exception do
      begin
        ExtDataErrorString := 'K_AddDevicePlatesClientInfoToTask ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;
end; // procedure K_AddDevicePlatesClientInfoToTask

procedure K_GetDevicePlatesClientInfoFromTaskToDB( ASL : TStrings );
var
  Ind : Integer;
begin
  N_Dump2Str( 'K_GetDevicePlatesClientInfoFromTaskToDB Start' );

  Ind := ASL.IndexOf( '[DevicePlatesClient]' );
  if Ind < 0 then Exit;
  TK_CMEDDBAccess(K_CMEDAccess).EDADevicePlatesListAdd( ASL, Ind + 1 );

  N_Dump1Str( 'K_GetDevicePlatesClientInfoFromTaskToDB fin' );
end; // procedure K_GetDevicePlatesClientInfoFromTaskToDB

//****************************************************** K_FCMClientScanDlg ***
//  Client scanning dialog
//
//     Parameters
// Result - Returns number of captured slides
//
function K_FCMClientScanDlg() : Integer;
var
  WStr : string;
  FDCMAttrs : TK_CMDCMAttrs;
  FMTypeID : Integer;
  FSlides : TN_UDCMSArray;

  FRFileName : string;       // Task R-file name
  FSFileName : string;       // Task S-file name
  FTaskFolder: string;       // Task Folder
  FRLocFileName : string;    // Task Loc R-file name
  FSLocFileName : string;    // Task Loc S-file name
  FTaskLocFolder: string;    // Task Loc Folder
  FTermTaskFlag : Boolean;
  FPatID : Integer;
  FAllPatSlidesCount : Integer;
  i : Integer;
  PatDetails : string;
  UDSlide : TN_UDCMSlide;
  FCurScanDataPath : string;
  FSCThread : TK_SCDScanDataThread;
  BoolRes : Boolean;
//!!  FSavedCurSessionHistID : Integer;
//!!  FPatientDBData : TK_CMSAPatientDBData;
{
  SavedCursor: TCursor;

  procedure WaitForThreadSuspended();
  begin
    N_Dump2Str( 'ClientScan before Wait for Thread Suspended' );
    SavedCursor := Screen.Cursor;
    while TRUE do
    begin
      if FSCThread.Suspended then break;
      if Screen.Cursor <> crHourglass then
        Screen.Cursor := crHourglass;
      sleep(100);
      Application.ProcessMessages;
    end; // while TRUE do
    if Screen.Cursor <> SavedCursor then
      Screen.Cursor := SavedCursor;
    N_Dump2Str( 'ClientScan after Wait for Thread Suspended' );
  end;
}
begin
  Result := 0;
  FSlides := nil;
  if K_CMVUIMode then
    VirtUI_ScanRun := true;                                            ////Igor 16092020 SIR#25767
  N_Dump1Str( 'ClientScanDlg Start');

//  WStr := K_CMScanDataPath + K_CMScanClientName + '\';
  FCurScanDataPath := K_CMScanGetCurDataPath();
  WStr := FCurScanDataPath + K_CMScanClientName + '\';
  if (FCurScanDataPath = '') or
     not DirectoryExists( WStr ) then
  begin
  // Precaution
    K_CMShowMessageDlg( 'Media Suite Client Scanner is not ready',
                           mtWarning );
    Exit;
  end;
  K_FormCMClientScan := TK_FormCMClientScan.Create( Application );
  with K_FormCMClientScan do
  begin
    PnState.Caption :=  K_SCLaunchMes;
    SCSTask := TStringList.Create;
    SCRTask := TStringList.Create;

    //  Prepare Task File Names
    if K_CMVUIMode then //!!!Ura 27.08.20
      SCTaskID := K_DateTimeToStr( K_CMEDAccess.EDAGetSyncTimestamp(), 'yymmddhhnnsszzz' )
    else
      SCTaskID := K_DateTimeToStr( Now(), 'yymmddhhnnsszzz' );
    SCTaskFolder := 'F' + SCTaskID;
    SCRFileName := SCTaskFolder + '.txt';
    SCRFileName[1] := 'R';
    SCSFileName := SCRFileName;
    SCSFileName[1] := 'S';
    SCStateFileName := WStr + K_CMScanClientStateFileName;
    SCTranspFileName := WStr + K_CMScanClientName + '.~';
    SCCurTaskFileName := WStr + K_CMScanCurTaskInfoFileName;
    SCTaskFolder := WStr + SCTaskFolder + '\';
    SCRFileName := WStr + SCRFileName;
    FSFileName  := SCSFileName; // Task file Name without path
    SCSFileName := WStr + SCSFileName;

    // Prepare Task S-file
    WStr := K_StringMListReplace(
               'PatientTitle=(#PatientTitle#)'#13#10+
               'PatientGender=(#PatientGender#)'#13#10+
               'PatientCardNumber=(#PatientCardNumber#)'#13#10+
               'PatientSurname=(#PatientSurname#)'#13#10+
               'PatientFirstName=(#PatientFirstName#)'#13#10+
               'PatientMiddle=(#PatientMiddle#)'#13#10+
               'PatientDOB=(#PatientDOB#)',
                K_CMEDAccess.EDAGetPatientMacroInfo(), K_ummRemoveMacro);
    SCSTask.Text := format(
      'IsTerm=FALSE'#13#10'CurPatID=%d'#13#10'CurProvID=%d'#13#10'CurLocID=%d'#13#10'%s'+
      #13#10'ServCompName='+K_CMSServerClientInfo.CMSSessionInfo.WTSServerCompName,
      [K_CMEDAccess.CurPatID,K_CMEDAccess.CurProvID,K_CMEDAccess.CurLocID,WStr] );

    if K_CMEDDBVersion >= 42 then
    begin // Add Device Plates Info to current task
       K_AddDevicePlatesTotalInfoToTask( SCSTask );
       K_AddDevicePlatesClientInfoToTask( SCSTask );
    end; // if K_CMEDDBVersion >= 42 then

    // Create file with current task name
    if not K_CMScanDataPathOnClientPC then
    begin
      FSCThread := nil;
      // Save Task S-file and Dump Results
      N_Dump1Str( 'ClientScan Start Task S-file >> ' +
                       SCUpdateTextFile( SCSTask, SCSFileName ) );


      K_CMEDAccess.TmpStrings.Text := FSFileName; // use short file name because CMSuite ExchangeFolder path may differs from CMSCan path
      N_Dump1Str( 'ClientScan CurTaskName file >> ' + SCUpdateTextFile( K_CMEDAccess.TmpStrings, SCCurTaskFileName ) );
    end
    else
//    if K_CMScanDataPathOnClientPC then
    begin
    ///////////////////////////////////////////////////////
    // Client base exchange folder
    //
//!!!      SCCurTaskFileName := ''; // Clear CurTaskFileName
      WStr := K_CMScanDataLocPath + K_CMScanClientName + '\';
      if not K_ForceDirPath( WStr + 'F' + SCTaskID + '\' ) then
      begin
        K_CMShowMessageDlg( 'Media Suite Client Scanner buffer folder creation error'#13#10 +
                             WStr,  mtWarning );
        Exit;
      end;

      // Launch Download Thread
      FSCThread := TK_SCDScanDataThread.Create(TRUE);
      FSCThread.FreeOnTerminate := TRUE;
      FSCThread.SCDLogFName :=
        ChangeFileExt(N_LogChannels[N_Dump1LCInd].LCFullFName, 'SCD.txt' );
      //
      FSCThread.SCDScanTaskLocFolder   := 'F' + SCTaskID;
      FSCThread.SCDScanTaskLocRFile    := FSCThread.SCDScanTaskLocFolder + '.txt';
      FSCThread.SCDScanTaskLocRFile[1] := 'R';
      FSCThread.SCDScanTaskLocSFile    := FSCThread.SCDScanTaskLocRFile;
      FSCThread.SCDScanTaskLocSFile[1] := 'S';
      FSCThread.SCDScanTaskLocFolder := WStr + FSCThread.SCDScanTaskLocFolder + '\'; // Thread Task Loc Folder
      FSCThread.SCDScanTaskLocRFile  := WStr + FSCThread.SCDScanTaskLocRFile;        // Thread Task Loc R-file
      FSCThread.SCDScanTaskLocSFile  := WStr + FSCThread.SCDScanTaskLocSFile;        // Thread Task Loc S-file
      FSCThread.SCDScanStateLocFile  := WStr + K_CMScanClientStateFileName;         // Thread CMScan Local State file
      FSCThread.SCDScanTaskNameFile := SCCurTaskFileName; // Thread Task name File to clear
      SCCurTaskFileName := ''; // Clear CurTaskFileName

      FSCThread.SCDScanTaskFolder := SCTaskFolder; // Thread  Task Folder
      FSCThread.SCDScanTaskRFile  := SCRFileName;  // Thread  Task R-file
      FSCThread.SCDScanTaskSFile  := SCSFileName;  // Thread  Task S-file
      FSCThread.SCDScanStateFile  := SCStateFileName; // Thread CMScan State file

      FSCThread.SCDCurScanDataPath := FCurScanDataPath;

      // Change ClientScan Exchange Context
      SCRFileName     := FSCThread.SCDScanTaskLocRFile;
      SCTaskFolder    := FSCThread.SCDScanTaskLocFolder;
      SCStateFileName := FSCThread.SCDScanStateLocFile;
      SCSFileName     := FSCThread.SCDScanTaskLocSFile;

      // Save Paths Context to Local Vars for use after ClientScan Form close
      FRLocFileName := FSCThread.SCDScanTaskLocRFile;     // Task Loc R-file name
      FSLocFileName := FSCThread.SCDScanTaskLocSFile;     // Task Loc S-file name
      FTaskLocFolder:= FSCThread.SCDScanTaskLocFolder; // Task Loc Folder

//      SCUpdateTextFile( SCSTask, SCSFileName );
      N_Dump1Str( 'ClientScan CurTaskName file >> ' + SCUpdateTextFile( SCSTask, SCSFileName ) );
      // Read SCSFileName to be sure

      FSCThread.Suspended := FALSE;
    end;
    //
    // Client base exchange folder
    ///////////////////////////////////////////////////////

    // Save Paths Context to Local Vars for use after ClientScan Form close
    FRFileName  := SCRFileName;   // Task R-file name
    FSFileName  := SCSFileName;   // Task S-file name
    FTaskFolder := SCTaskFolder;  // Task Folder name

    // Wait for CMScan results
    ActTimer.Enabled := TRUE;

    ShowModal();

    ActTimer.Enabled := FALSE;

    // Remove file with current task name if it has not been removed later
    SCClearCurTaskNameFile();
//    if SCCurTaskFileName <> '' then
//      K_DeleteFile( SCCurTaskFileName );

    FMTypeID := 0;
    FDCMAttrs.CMDCMModality := '';
    FDCMAttrs.CMDCMKVP     := 0;
    FDCMAttrs.CMDCMExpTime := 0;
    FDCMAttrs.CMDCMTubeCur := 0;

    FTermTaskFlag := SCTermTaskFlag;

    SCRFileDate := 0; // for unconditional read in SCUpdateTaskRFile
    //                     <Task is Done>   or <R-file is successfully read>
    if (SCInfoState = K_ScanTaskIsFinished) or SCUpdateTaskRFile() then
    begin
      Result := StrToIntDef( SCRTask.Values['ScanCount'], 0 );
      if Result > 0 then
      begin
        FSlides := SCGetTaskSlides( Result, FPatID );
        FMTypeID := StrToIntDef( SCRTask.Values['MTypeID'], 0 );
        FDCMAttrs.CMDCMModality := SCRTask.Values['DModality'];
        FDCMAttrs.CMDCMKVP      := StrToFloatDef( SCRTask.Values['DKVP'], 0 );
        FDCMAttrs.CMDCMExpTime  := StrToIntDef( SCRTask.Values['DExpTime'], 0 );
        FDCMAttrs.CMDCMTubeCur  := StrToIntDef( SCRTask.Values['DTubeCur'], 0 );
        Result := Length(FSlides);
      end;
      // Clear Terminated Flag if all slides are already uploaded
      FTermTaskFlag := FTermTaskFlag and
                       (SCRTask.Values['IsDone'] <> 'TRUE');

    end; // if (SCInfoState = K_ScanTaskIsFinished) or SCUpdateTaskRFile() then

    N_Dump1Str( 'ClientScan Slides Resulting Count=' + IntToStr(Result) );

    if K_CMEDDBVersion >= 42 then
      K_GetDevicePlatesClientInfoFromTaskToDB( SCRTask );

    if FTermTaskFlag  and (Result > 0) then
    begin // Set Stoped State - Task was terminated and is not empty
    // Stop (not Terminated) State is needed to Stop CMScan Uploading and
    // skip task removing by CMScan
      SCSTask.Values['IsTerm'] := K_CMScanTaskIsStopped;
      N_Dump1Str( 'ClientScan Task is stopped S-file >> ' +
                       SCUpdateTextFile( SCSTask, SCSFileName ) );
      if FTermTaskFlag and (FSCThread <> nil) then
      begin // Break Download Loop and upload Task S-file to Client based exchange folder

//        FSCThread.SCDBreakDownloadFlag := TRUE; // Break Thread Download Loop
        FSCThread.SCDBreakDownloadState := 1; // Stop Thread Download Loop

//!!        WaitForThreadSuspended();
//!!        FSCThread.SCDFinActionCode := 0; // For writing STOP to S-file
//!!        FSCThread.Suspended := FALSE; // start upload S-file to Client based exchange folder
      end;
    end;
    SCSTask.Free;
    SCRTask.Free;

  end; // with TK_FormCMClientScan.Create( Application ) do

  if Result > 0 then // Results Processing Dlg
  begin
//     if Result[Ind].P.CMSPatID <> 77CurPatID then
//     Inc(AOtherPatCount);
    if FPatID = K_CMEDAccess.CurPatID then // Current Patient
    begin
      N_Dump2Str( 'ClientScan Processing Current Patient Slides' );
      K_CMScanSlidesSaveArray( FSlides,
                         'Process Output from client capture software',
                         not K_CMXrayCaptStreamLineMode,
                         FMTypeID,
                         K_CML1Form.LLLCaptHandler14.Caption,
                         @FDCMAttrs );
    end   // if Current Patient Results then
    else
    begin // if Other Patient Results then
      with K_CMEDAccess do
      begin
        PatDetails := K_CMGetPatientName( FPatID );
{ !!! new code for patient details
        PatDetails := K_CMGetPatientName( FPatID );
        EDASAGetOnePatientInfo( IntToStr( FPatID ), @FPatientDBData, [K_cmsagiSkipLock] );
        if FPatientDBData.APCardNum <> '' then
          PatDetails := PatDetails + ' [' + FPatientDBData.APCardNum + ']'
}
        N_Dump2Str( 'ClientScan Processing Slides for ' + PatDetails );
{!!! new code for correct history
        FSavedCurSessionHistID := K_CMEDAccess.CurSessionHistID;
        EDAAddSessionHistRecord( FSlides[0].P.CMSPatID );
        EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                               Ord(K_shNCAStartSession) ) );
{}

        FAllPatSlidesCount := K_CMSetSlidesAttrs( @FSlides[0], Result,
                                @FDCMAttrs,
                                'Process Output from client capture software for Patient ' + PatDetails,
                                [K_ssafSkipProcessDate, K_ssafSkipAutoOpen],
                                FMTypeID );
{!!! new code for correct history
        EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                     Ord(K_shNCAFinishSession) ) );
        CurSessionHistID := FSavedCurSessionHistID;
{}
      end;

     // Remove Other Patient Slides From CurSlidesList
      for i := K_CMEDAccess.CurSlidesList.Count -1 downto K_CMEDAccess.CurSlidesList.Count - FAllPatSlidesCount do
      begin // Remove Other Patient Slides Loop
        UDSlide := TN_UDCMSlide(K_CMEDAccess.CurSlidesList[i]);
        if UDSlide.P.CMSPatID = K_CMEDAccess.CurPatID then Continue; // precaution, needed if Current and Other Patients Objects were processed
        N_Dump2Str( 'ClientScan>> Del from CurSet Slide ID=' + UDSlide.ObjName );
        K_CMDeleteClientMediaFile( UDSlide );
        K_CMEDAccess.CurSlidesList.Delete( i );
        UDSlide.UDDelete;
      end; // for i := CurSlidesList.Count -1 downto CurSlidesList.Count - Result do
      N_CM_MainForm.CMMFShowStringByTimer( format( K_CML1Form.LLLCaptHandler14.Caption,
//                             ' %d media object(s) acquired (patient %s)',
                                      [FAllPatSlidesCount,PatDetails] ) );
    end;  // if Other Patients Results then

  end; // if Result > 0 then // Results Processing Dlg

  if FTermTaskFlag then
  begin // Set Task Terminated State and Task will be removed by CMScan
    N_T1.Start();
    BoolRes := K_VFSaveText( 'IsTerm=TRUE', FSFileName, K_DFCreatePlain );
    N_T1.Stop();
    if not BoolRes then
    // Task S-file Write Error - Task wiil be processed later by CMScan
      N_Dump1Str( format( 'ClientScan Task S-file Write Time=%s Error >> %s',
                          [N_T1.ToStr(), FSFileName] ) )
    else
    begin
      N_Dump1Str( 'ClientScan Task is Terminated S-file=' +
        K_CMScanGetFileCopyReport( ExtractFileName(FSFileName), 14, N_T1 ) );
    end;

    if FSCThread <> nil then
    begin
      FSCThread.SCDBreakDownloadState := 2; // Stop Thread Download Loop
      FSCThread.SCDFinActionCode := 1; // For writing TERM to S-file
      FSCThread.SCDSetTaskTermFlag := TRUE; // For writing TERM to S-file
    end;
  end  // /Set Task Terminated State and Task will be removed by CMScan
  else // Task is finished normally - remove task
  if FSCThread <> nil then // Remove Local Task and Task by Download Thread
  begin
    // Remove Local Task - may be in future some recover actions will be done for Tasks hanged in Local buffer
    if not K_CMScanRemoveTask( 'ClientScan Loc', FSLocFileName, FRLocFileName, FTaskLocFolder,
                               K_CMEDAccess.TmpStrings, N_T1, N_Dump1Str, N_Dump2Str ) then
    // Task Remove Error >> Try to mark Task as Terminated for future remove by CMScan
      N_Dump1Str( 'ClientScan Local Task Remove Error >> Set terminated state S-file=' + FSLocFileName );
    FSCThread.SCDFinActionCode := 2; // For remove Task
  end
  else                    // Remove Task directly
  if not K_CMScanRemoveTask( 'ClientScan', FSFileName, FRFileName, FTaskFolder,
                             K_CMEDAccess.TmpStrings, N_T1, N_Dump1Str, N_Dump2Str ) then
  begin // Task Remove Error >> Try to mark Task as Terminated for future remove by CMScan
    N_Dump1Str( 'ClientScan Task Remove Error >> Set terminated state S-file=' + FSFileName );
    K_CMEDAccess.TmpStrings.Text := 'IsTerm=TRUE';
    if not K_VFSaveStrings( K_CMEDAccess.TmpStrings, FSFileName, K_DFCreatePlain ) then
      N_Dump1Str( 'ClientScan Mark Task as terminated error' );
  end;

  if FSCThread <> nil then
  begin // activate Thread for Final Actions
//    FSCThread.SCDBreakDownloadFlag := TRUE; // needed in case when R-file was not found
    FSCThread.SCDBreakDownloadState := 2; // needed in case when scaning is complete by R-file
//!!    WaitForThreadSuspended();
//!!    FSCThread.Suspended := FALSE;
  end;

  if K_CMVUIMode then
    VirtUI_ScanRun := false;                                            ////Igor 16092020 SIR#25767
  N_Dump1Str( 'ClientScanDlg Stop');

end; // function K_FCMClientScanDlg

//*************************************** TK_FormCMClientScan.ActTimerTimer ***
// Timer Event Handler
//
procedure TK_FormCMClientScan.ActTimerTimer(Sender: TObject);
var
  RFileExists : Boolean;
  RScan : Integer;
  RTaskState : Integer;  //
  WStr : string;
begin
  ActTimer.Enabled := FALSE;

  Inc(SCScanInfoWateCount);

  RFileExists := SCUpdateTaskRFile();
  if not RFileExists then
  begin
    SCUpdateScanSelfStateByFile();
    if SCInfoState = K_ScanIsNotStarted then
    begin
      if SCScanSelfState < K_ScanSelfDoCurTask then
      // Wait Counter show time period from task creation to task detection by CMScan
        PnState.Caption := format( K_SCLaunchMes + ', %d s   ', [SCScanInfoWateCount] )
      else
      begin // if SCScanSelfState = K_ScanSelfDoCurTask then
      // CMScan detect new task - Reset Wait Counter and delete file with current task name
        PnState.Caption := K_SCCaptureStartMes;
        SCScanInfoWateCount := 0;
        SCInfoState := K_ScanDeviceIsNotStarted;
        // Remove file with current task name if exists
        SCClearCurTaskNameFile();
//        if (SCCurTaskFileName <> '') and K_DeleteFile( SCCurTaskFileName ) then
//          SCCurTaskFileName := '';
      end;
    end
    else
    if SCInfoState = K_ScanDeviceIsNotStarted then
      // Wait Counter show time period from task detection by CMScan to capture device starting
      PnState.Caption := format( K_SCCaptureStartMes + ', %d s   ', [SCScanInfoWateCount] )
  end   // if not RFileExists then
  else
  begin // if RFileExists then
    if SCInfoState < K_ScanDeviceIsStarted then
    begin // R-file was created by CMScan - capture device is started
      SCInfoState := K_ScanDeviceIsStarted;

      // Remove file with current task name if it has not been removed later or doesn't exist
      SCClearCurTaskNameFile();
//      if (SCCurTaskFileName <> '') and K_DeleteFile( SCCurTaskFileName ) then
//        SCCurTaskFileName := '';
    end; // if SCInfoState < K_ScanDeviceIsStarted then

    RTaskState := 0;
    if SCRTask.Values['IsDone'] = K_CMScanTaskIsUploaded then RTaskState := 1
    else
    if SCRTask.Values['IsDone'] = 'TRUE' then RTaskState := 2;

    RScan := StrToIntDef( SCRTask.Values['ScanCount'], 0 );
    WStr := K_SCCaptureFin;
    if RTaskState = 1 then
      WStr := K_SCCaptureFin1;
    PnState.Caption := format( WStr + ', %d s   ', [RScan,SCScanInfoWateCount] );

    if RScan <> SCScanCount then // to prevent extra dump
      N_Dump1Str( PnState.Caption );

    SCScanCount := RScan;

    if RTaskState = 2 then
    begin
      N_Dump1Str( 'ClientScan Task is finished by CMScan' );
      SCInfoState := K_ScanTaskIsFinished;
      Self.Close();
      Exit;
    end;
  end;  // if RFileExists then

  PnState.Refresh();
  ActTimer.Enabled := TRUE;

end; // procedure TK_FormCMClientScan.ActTimerTimer

//*************************************** TK_FormCMClientScan.SCUpdateTaskRFile ***
// Update R-file State
//
//     Parameters
// Result - Returns TRUE if file Exists
//
function TK_FormCMClientScan.SCUpdateTaskRFile : Boolean;
var
  NewFileDate : TDateTime;
  LoadRes : Boolean;
begin
  Result := SCRTask.Count > 0;
  N_T1.Start();
  NewFileDate := K_GetFileAge( SCRFileName );
  N_T1.Stop();

  if NewFileDate <= SCRFileDate then Exit;

  N_Dump2Str( format( 'ClientScan.SCUpdateTaskRFile start R%s.txt from %s, AgeTime=%s',
                      [SCTaskID, K_DateTimeToStr(NewFileDate, 'dd-hh:nn:ss.zzz'),
                      N_T1.ToStr()] ) );


//  LoadRes := K_ClientScanLoadStrings( SCRFileName, SCRTask);
  LoadRes := K_ClientScanLoadText( SCRFileName, K_CMEDAccess.StrTextBuf );
  if LoadRes then
    SCRTask.Text := K_CMEDAccess.StrTextBuf
  else
    SCRTask.Clear;

  if LoadRes then
  begin
    SCRFileDate := NewFileDate;
    N_Dump2Str( format( 'ClientScan.SCUpdateTaskRFile fin IsDone=%s Count=%s  R-file=%s',
                          [SCRTask.Values['IsDone'],
                           SCRTask.Values['ScanCount'],
                           K_CMScanGetFileCopyReport( 'R'+SCTaskID, Length(K_CMEDAccess.StrTextBuf) + 1, N_T1 )] ) );
  end;
//  else
//    N_Dump1Str( 'ClientScan.SCUpdateTaskRFile Load Error R' + SCTaskID );

  Result := SCRTask.Count > 0;

end; // function TK_FormCMClientScan.SCUpdateTaskRFile

//************************* TK_FormCMClientScan.SCUpdateScanSelfStateByFile ***
// Update State file
//
//     Parameters
// Result - Returns CMScan state:
//#F
// 0 - is not launched (K_ScanSelfIsNotStarted),
// 1 - wait (K_ScanSelfReady),
// 2 - setup (K_ScanSelfSetup),
// 3 - do other task (K_ScanSelfDoOtherTask),
// 4 - transfer data to new path (K_ScanSelfMoveToNewFolder),
// 5 - do cur task (K_ScanSelfDoCurTask)
//#/F
//
function TK_FormCMClientScan.SCUpdateScanSelfStateByFile : TK_CMScanSelfState;
var
  NewFileDate : TDateTime;
  StateStr : string;
  FName: string;
begin
  Result := K_ScanSelfMoveToNewFolder;
  if (SCTranspFileName <> '') and FileExists( SCTranspFileName ) then Exit;
  SCTranspFileName := '';
  NewFileDate := K_GetFileAge( SCStateFileName );
  Result := K_ScanSelfIsNotStarted;
  if NewFileDate = 0 then Exit;
  Result := SCScanSelfState;
  if NewFileDate <= SCStateFileDate then Exit;
  SCStateFileDate := NewFileDate;
  FName := ExtractFileName(SCStateFileName);
  N_Dump2Str( 'ClientScan.SCUpdateScanSelfStateByFile start ' + FName );

  if K_ClientScanLoadText( SCStateFileName, StateStr ) then
  begin

// !!! it should not be done if Client based exchange folder
//    SCRFileDate := NewFileDate; // Correct R-file date to prevent R-file check just after state file was change
// SCRFileDate is CMSuite based because R-File is changed by SelfThread
// but NewFileDate is CMScan based
// may be is not needed to do - it is error
    case StateStr[1] of
    'W' : Result:= K_ScanSelfReady;
    'S' : Result:= K_ScanSelfSetup;
    'D' : Result:= K_ScanSelfDoOtherTask;
    end;
    if (Result = K_ScanSelfDoOtherTask) and
       (SCTaskID = Copy(StateStr, 4, 15)) then
      Result:= K_ScanSelfDoCurTask;
    SCScanSelfState := Result;
    N_Dump2Str( format( 'ClientScan.SCUpdateScanSelfStateByFile fin State=%d >> %s',
                        [Ord(SCScanSelfState), SCGetFileCopyReport( FName, Length(StateStr)+ 1 )] ) );
  end;

end; // function TK_FormCMClientScan.SCUpdateScanSelfStateByFile

//************************************ TK_FormCMClientScan.SCGetTaskSlides ***
// Get Scanned Slides from Task Folder
//
//     Parameters
// ACount - number of slides in task R-file
// Result - Returns Slides Array
//
function TK_FormCMClientScan.SCGetTaskSlides( ACount: Integer; out APatID : Integer ): TN_UDCMSArray;
var
  i, Ind, WCount : Integer;
  SkipVideoFilesProcessing, VideoSlideFlag : Boolean;
  ErrMax : Integer;
  ErrDelay : Integer;

  procedure ProcessFile( const AFName : string );
  var
    DFile: TK_DFile;
    DSize : Integer;
    RSlide : TK_RArray;
    PCMSlide : TN_PCMSlide;
    WCPat : string;
    ECFName : string;
    NewVideoFName : string;
    DecompressSFName : string;
    CharInd : Integer;
    Erri : Integer;
    ErrStr : string;
    ErrFlag : Boolean;

  label ErrLab;
  begin
    ECFName  := SCTaskFolder + AFName;
    for Erri := 1 to ErrMax do
    begin // Try Loop
      K_DFStreamReadShareFlags := fmShareDenyNone;
      ErrFlag := K_DFOpen( ECFName, DFile, [K_dfoProtected] );
      K_DFStreamReadShareFlags := 0;

      if not ErrFlag then
      begin // Open file Error
        ErrStr := format( 'ClientScan.SCGetTaskSlides Open %d error="%s" File=%s',
                          [Erri, K_DFGetErrorString(DFile.DFErrorCode), ECFName] );
  ErrLab: //*****
        if Erri = ErrMax then
        begin // Finish Try Loop
          N_Dump1Str( ErrStr );
          Exit;
        end
        else
        begin // Continue Try Loop
          if Erri = 1 then
            N_Dump1Str( ErrStr )
          else
            N_Dump2Str( ErrStr );
          sleep( ErrDelay );
          Continue;
        end;
      end; // if not ErrFlag then

      DSize := DFile.DFPlainDataSize;
      if SizeOf(Char) = 2 then
        DSize := DSize shr 1;
      SetLength( K_CMEDAccess.StrTextBuf, DSize );
      if not K_DFReadAll( @K_CMEDAccess.StrTextBuf[1], DFile ) then
      begin
        ErrStr := format( 'ClientScan.SCGetTaskSlides Read %d error="%s" File=%s',
                    [Erri, K_DFGetErrorString(DFile.DFErrorCode), ECFName] );
        goto ErrLab;
      end;
      break;  // Success
    end; // for Erri := 0 to 10 then

    K_SerialTextBuf.LoadFromText( K_CMEDAccess.StrTextBuf );

    Result[Ind] := TN_UDCMSlide( K_LoadTreeFromText( K_SerialTextBuf ) );
    if Result[Ind] = nil then
    begin
      N_Dump1Str( format( 'ClientScan.SCGetTaskSlides Wrong File Format File=%s',
                          [ECFName] ) );
      WCPat := ChangeFileExt( AFName, '' );
      WCPat := Copy( WCPat, 1, Length(WCPat) - 1 ) + '*.*';
      K_DeleteFolderFiles( SCTaskFolder, WCPat, [] ); // Del ECache Main + Image Files
      N_Dump1Str( 'ClientScan.SCGetTaskSlides >> Files ' + SCTaskFolder + WCPat + ' were deleted' );
      Exit;
    end; // if Result[Ind] = nil then

    with Result[Ind] do
    begin
    // Change Slide SPL type structure
      CMSlideECFName := ECFName;
      RSlide := K_RCreateByTypeName( 'TN_CMSlide', 1, [] );
      PCMSlide := P();
      TN_PCMSlide(RSlide.P())^ := PCMSlide^;
      PCMSlide^.CMSHist := nil; // Clear History Before Destroy
      R.ARelease();
      R := RSlide;
      PCMSlide := P();
      VideoSlideFlag := cmsfIsMediaObj in PCMSlide^.CMSDB.SFlags;
      if VideoSlideFlag then
      begin
        ObjAliase := 'Video ';
        if not SkipVideoFilesProcessing then
        begin // Rebuild Video File Name
          with PCMSlide^.CMSDB do
          begin
            NewVideoFName := SCTaskFolder + ExtractFileName( MediaFExt );
            SkipVideoFilesProcessing := NewVideoFName = MediaFExt;
            if not SkipVideoFilesProcessing then
            begin
              N_Dump1Str( 'ClientScan.SCGetTaskSlides >> Process Video Slide start File=' + ECFName  );
              MediaFExt := NewVideoFName;
              // Change A-file content
              K_CMScanChangeVideoFileNameInSlideSerializedAttrs(
                                   K_CMEDAccess.StrTextBuf, DSize, SCTaskFolder,
                                   FALSE );
              // Save A-file
              K_DFWriteAll( ECFName, K_DFCreateProtected,
                                             @K_CMEDAccess.StrTextBuf[1], DSize * SizeOf(Char) );
              N_Dump2Str( 'ClientScan.SCGetTaskSlides >> Process Video Slide fin' );
            end; // if NewVideoFName <> MediaFExt then

          end;
        end; // if not SkipVideoFilesProcessing then

        // Try To Decompress Video
        if not K_CMScanDecompressOrCopyTasksFile( PCMSlide^.CMSDB.MediaFExt,
                                   PCMSlide^.CMSDB.MediaFExt,
                               'ClientScan.SCGetTaskSlides', 'Video' ) then Exit;
      end   // if VideoSlideFlag then
      else
      begin // if not VideoSlideFlag then
        ObjAliase := 'Image ';
        DecompressSFName := ECFName;
        CharInd := Length(DecompressSFName) - 4;

        DecompressSFName[CharInd] := 'R';
        if not K_CMScanDecompressOrCopyTasksFile( DecompressSFName, DecompressSFName,
                            'ClientScan.SCGetTaskSlides', 'CurImg' ) then Exit;

        DecompressSFName[CharInd] := 'S';
        if not K_CMScanDecompressOrCopyTasksFile( DecompressSFName, DecompressSFName,
                            'ClientScan.SCGetTaskSlides', 'SrcImg' ) then Exit;
      end;
      ObjAliase := ObjAliase + IntToStr(Ind + 1);
    end; // with Result[Ind] do
    APatID := Result[Ind].P.CMSPatID;
    K_CMEDAccess.CurSlidesList.Add(Result[Ind]);
    Inc(Ind);
  end; // procedure ProcessFile

begin
  Result := nil;
  N_Dump2Str( 'ClientScan.SCGetTaskSlides start' );
  with K_CMEDAccess do
  begin
    TmpStrings.Clear();
    K_ScanFilesTree( SCTaskFolder, EDAScanFilesTreeSelectFile, 'F*A.ecd' );
    WCount := TmpStrings.Count;
    if WCount > 0 then
    begin
      TmpStrings.Sort();
      if WCount > ACount then
        WCount := ACount;
      SetLength( Result, WCount );
      Ind := 0;
      SkipVideoFilesProcessing := FALSE;
      ErrMax   := N_MemIniToInt( 'CMS_UserMain', 'ClientScanRCount', 50 );
      ErrDelay := N_MemIniToInt( 'CMS_UserMain', 'ClientScanDelay', 300 );
      for i := 0 to WCount - 1 do
        ProcessFile( TmpStrings[i] );

      SetLength( Result, Ind );
    end;
    N_Dump1Str( format( 'ClientScan.SCGetTaskSlides >> Files Count=%d Scan=%d Result=%d PatID=%d',
                              [TmpStrings.Count, ACount, Ind, APatID] ) );
  end; //  with K_CMEDAccess do
end; // function TK_FormCMClientScan.SCGetTaskSlides

//********************************* TK_FormCMClientScan.SCGetFileCopyReport ***
// Get file copy report
//
//     Parameters
// AFName -  file name
// AFSize -  file size
//
function  TK_FormCMClientScan.SCGetFileCopyReport( const AFName : string; AFSize : Integer ) : string;
begin
  Result := K_CMScanGetFileCopyReport( ExtractFileName(AFName), AFSize, N_T1 );
{
  Result :=  format( '%s Size=%d Time=%s Speed=%s per 1MB',
                [AFName, AFSize, N_T1.ToStr(),
                 N_TimeToString( (1024* 1024 * N_T1.DeltaCounter/N_CPUFrequency)/N_SecondsInDay, AFSize )] )
}
end; // function  TK_FormCMClientScan.SCGetFileCopyReport

//*********************************** TK_FormCMClientScan.SCUpdateTextFile ***
// Update Task RFile
//
//     Parameters
// ASStrings  - S-file current state strings
// ASFileName - S-file name
//
function  TK_FormCMClientScan.SCUpdateTextFile( ASStrings : TStrings; const ASFileName : string ) : string;
var
  BoolRes : Boolean;
begin
  N_T1.Start();
  BoolRes := K_VFSaveStrings( ASStrings, ASFileName, K_DFCreatePlain );
  N_T1.Stop();
  Result := '';

  if not BoolRes then
    Result := format( '!!!File Create|Update Time=%s Error >> %s',
                      [N_T1.ToStr(), ASFileName] )
  else
    Result := SCGetFileCopyReport( ExtractFileName(ASFileName),
                                   Length(ASStrings.Text) + 1 );
end; // function  TK_FormCMClientScan.SCUpdateTextFile

//****************************** TK_FormCMClientScan.SCClearCurTaskNameFile ***
// Clear CurTaskNameFile
//
procedure TK_FormCMClientScan.SCClearCurTaskNameFile;
var
  ResStr : string;
begin
  if SCCurTaskFileName <> '' then
  begin
//      K_DeleteFile( SCCurTaskFileName );
    // Create file zero length instead of deletion
    K_CMEDAccess.TmpStrings.Clear;
    ResStr := SCUpdateTextFile( K_CMEDAccess.TmpStrings, SCCurTaskFileName );
    if ResStr[1] <> '!' then
    begin
      SCCurTaskFileName := '';
      N_Dump2Str( 'SC> CurTaskName file clear >> ' + ResStr );
    end
    else
      N_Dump1Str( 'SC> CurTaskName file clear >> ' + ResStr );
  end;
end; // procedure TK_FormCMClientScan.SCClearCurTaskNameFile

//*************************************** TK_FormCMClientScan.BtCancelClick ***
// BtCancel On Click Handler
//
procedure TK_FormCMClientScan.BtCancelClick(Sender: TObject);
begin
//“The image data transfer may be in progress. This data will be lost if the transfer is cancelled.
//“The capture results transfer may be in progress. This data will be lost if the transfer is cancelled.
//Would you like to cancel the data transfer ? Press “Yes” to cancel, “No” to wait until it is finished”
//Yes, No
  if SCRTask.Count > 0 then
  begin
    if mrYes <> K_CMShowMessageDlg( 'The capture results transfer may be in progress. This data will be lost if the transfer is cancelled.' + #13#10 +
                                    'Would you like to cancel the data transfer? Press "Yes" to cancel, "No" to wait until it is finished.',
                        mtConfirmation ) then Exit;
  end
  else
  begin
    if mrYes <> K_CMShowMessageDlg( 'Would you like to cancel the data transfer? Press "Yes" to cancel, "No" to wait until it is finished.',
                        mtConfirmation ) then Exit;
  end;

  ModalResult := mrCancel;
  SCTermTaskFlag := TRUE;
end; // TK_FormCMClientScan.BtCancelClick

procedure TK_FormCMClientScan.FormCloseQuery( Sender: TObject; var CanClose: Boolean);
begin
//  if FSCThread <> nil then FSCThread.Terminate;
end; // TK_FormCMClientScan.FormCloseQuery

{ TK_SCDScanDataThread }

const
  scdFileReadError  = -1;
  scdCopyFilesOK    = 0;
  scdCopyFilesStop  = 1;
  scdCopyFilesBreak = 2;

//******************************************** TK_SCDScanDataThread.Execute ***
// Tasks Download Thread Main loop
//
procedure TK_SCDScanDataThread.Execute;
var
  TaskWasFinished : Boolean;
  Res : Integer;
  ErrCount : Integer;
  TaskWasStarted : Boolean;
  TaskRState : string;
  RFileIsUpdated : Boolean;
  NewStateFileDate, StateFileDate : TDateTime;
  CopySuccessFlag : Boolean;
  SL : TStringList;

label UploadSFileStep, LExit;
  ///////////////////////////////
  // Delete file with CurTaskName
  //
  function DeleteCurTaskNameFile( ) : Boolean;
  var
    FileExistRep : string;
  begin
    Result := SCDScanTaskNameFile = '';
    if Result then Exit;
    while TRUE do // Copy Task S-file Loop
    begin
//      if Terminated or SCDBreakDownloadFlag {or ClientScan is finished} then Exit;
      if Terminated or (SCDBreakDownloadState <> 0) {or ClientScan is finished} then Exit;
      SCDT.Start();
      Result := FileExists( SCDScanTaskNameFile );
      SCDT.Stop();
      FileExistRep := SCDT.ToStr();
      if Result then
      begin
        SCDT.Start();
        Result := K_DeleteFile( SCDScanTaskNameFile );
        SCDT.Stop();
        if Result then
        begin
          SCDDump( format( 'SCD> ScanTaskNameFile "%s" is deleted FETime=%s FDTime=%s',
                           [SCDScanTaskNameFile, FileExistRep, SCDT.ToStr()] ) );
          SCDScanTaskNameFile := '';
          break;
        end
        else
          SCDDump( format( 'SCD> ScanTaskNameFile "%s" delete Error FDTime=%s',
                           [SCDScanTaskNameFile, SCDT.ToStr()] ) );
      end
      else
      begin
        Result := TRUE;
        SCDDump( format( 'SCD> ScanTaskNameFile "%s" is absent FETime=%s',
                         [SCDScanTaskNameFile,FileExistRep] ) );
        SCDScanTaskNameFile := '';
        break;
      end;
      if SCDCheckConnection( 200 ) then
        Sleep(200);
    end; // while ... // Copy Task S-file Loop

  end; // function DeleteCurTaskNameFile

  //////////////////////
  // Upload Task S-file
  //
  function UploadSFile( const ADumpPref : string ) : Boolean;
  var
    FStream : TFileStream;
    FSize : Integer;
    FSizeCount, CopyCount : Integer;
    DumpFileName : string;

    function GetUploadSFileDumpInfo( ) : string;
    begin
      if DumpFileName = '' then DumpFileName := ExtractFileName(SCDScanTaskLocSFile);
      Result := ADumpPref + ' ' +  DumpFileName;
    end;

  begin
    Result := FALSE;
    FSizeCount := 0;
    CopyCount  := 0;
    while TRUE do // Copy Task S-file Loop
    begin
//      if Terminated or SCDBreakDownloadFlag {or ClientScan is finished} then Exit;
      if Terminated then Exit;
      FSize := -1;
      try
        FStream := TFileStream.Create( SCDScanTaskLocSFile, fmOpenRead + fmShareDenyNone );
        FSize := FStream.Seek( 0, soEnd );
        FStream.Free;
      except
      end;

      if FSize <= 10 then
      begin // wait for s-file complete
        if FSizeCount mod 150 = 0 then
          SCDDump( format( 'SCD> Upload S-file %s !!! Size=%d',
                                          [GetUploadSFileDumpInfo(), FSize] ) );
        Inc(FSizeCount);
        Sleep(200);
        Continue;
      end;

      SCDT.Start();
      CopySuccessFlag := CopyFile( PChar(SCDScanTaskLocSFile),
                                   PChar(SCDScanTaskSFile), FALSE );
      SCDT.Stop();
      Inc(CopyCount);
      if CopySuccessFlag then Break;

//!!!      SCDDump( format( 'SCD> Upload S-file %s Time=%s !!! Error >>',  // mis %s 2017-09-15
      SCDDump( format( 'SCD> Upload S-file %s Time=%s !!! Error >> %s',
                  [GetUploadSFileDumpInfo(), SCDT.ToStr(), SysErrorMessage(GetLastError())] ) );

      if (CopyCount mod 50 = 0) and (SCDBreakDownloadState <> 0) then Exit; // Break Copy Loop


      if SCDCheckConnection( 200 ) then
        Sleep(200);
    end; // while TRUE do // Copy Task S-file Loop

    SCDDump( format( 'SCD> Upload S-file %s Time=%s',
                             [GetUploadSFileDumpInfo(), SCDT.ToStr()] ) );
    Result := TRUE;
  end; // function UploadSFile

begin

  SCDRFileCont    := TStringList.Create;
  SCDRFileLocCont := TStringList.Create;
  SCDFilesList    := TStringList.Create;
  SCDDumpBuffer   := TStringList.Create;
  SCDT := TN_CPUTimer1.Create;
  OnTerminate := SCDOnTerminate;
  SCDDump0( #13#10#13#10'****************** Download Session Start ' +
            FormatDateTime( 'yyyy-mm-dd_hh":"nn":"ss.zzz'#13#10, Now() ) +
            '  S-file=' + SCDScanTaskSFile + #13#10 );


//      if SCCurTaskFileName <> '' then
//        K_DeleteFile( SCCurTaskFileName );

  SCDTerminatedInfo := 'Execute >> Copy Task S-file START Loop';
  if not DeleteCurTaskNameFile() then goto LExit;
  if not UploadSFile( 'START' ) then goto LExit;

  //////////////////////////////////
  // Wait For Task R-File
  //
  StateFileDate := 0;
  SCDTerminatedInfo := 'Execute >> Wait For Task R-File';
  SCDDump( 'SCD> Execute >> Wait For Task R-File' );
  while K_GetFileAge( SCDScanTaskRFile ) = 0 do
  begin
//    if SCDBreakDownloadFlag then
    if SCDBreakDownloadState <> 0 then
    begin
      SCDTerminatedInfo := 'Execute >> Break before R-file is found';
      SCDDump( 'SCD> Finish before R-file is found' );
      goto UploadSFileStep;
    end;
    if Terminated then goto LExit;

    NewStateFileDate := K_GetFileAge( SCDScanStateFile );
    if NewStateFileDate > StateFileDate then
    begin
      SCDT.Start();
      CopySuccessFlag := CopyFile( PChar(SCDScanStateFile),
                                   PChar(SCDScanStateLocFile), FALSE );
      SCDT.Stop();
      if not CopySuccessFlag then
        SCDDump( format( 'SCD> Download State File Error Time=%s >> %s',
                      [SCDT.ToStr(),SysErrorMessage(GetLastError())] ) )
      else
      begin // Copy File Report
        StateFileDate := NewStateFileDate;
        SCDDump( 'SCD> Download  State File Time=' + SCDT.ToStr() );
      end;
    end; // if NewStateFileDate > StateFileDate then

    if SCDCheckConnection( 200 ) then
      Sleep(200);
  end; // while K_GetFileAge( SCDScanTaskRFile ) = 0 do

  SCDDump( 'SCD> Task R-file is detected >>' + SCDScanTaskRFile );
  TaskWasStarted := TRUE;
  //
  // Wait For Task RFile
  //////////////////////////////////

  //////////////////////////////////
  // Create Task Download Folder Loop
  //
  SCDTerminatedInfo := 'Execute >> Create Task Dowload Folder Loop';
  while not DirectoryExists( SCDScanTaskLocFolder ) and
        not K_ForceDirPath( SCDScanTaskLocFolder ) do
  begin
   // Create Task Folder Loop if Error
    if Terminated then goto LExit;

    SCDDump( 'SCD> Create Download Task Folder Error ' + SCDScanTaskLocFolder );
    Sleep(200);
  end; // while ...
  //
  // Create Task Download Folder Loop
  //////////////////////////////////

  ///////////////////////////
  // Download Task Files Loop
  //
  ErrCount := 0;
  SCDTerminatedInfo := 'Execute >> Download Task files Loop';
  while TRUE do
  begin
//    if SCDBreakDownloadFlag then
    if SCDBreakDownloadState <> 0 then
    begin
      SCDTerminatedInfo := SCDTerminatedInfo + ' || Execute >> Break before R-file is updated';
      SCDDump( 'SCD> Break before R-file is updated' );
      goto UploadSFileStep;
    end;
    // Check Task Updates
    RFileIsUpdated := SCDLoadTextFile( SCDScanTaskRFile, SCDRFileCont );
    if not RFileIsUpdated then
    begin // Error Dump and break Upload Loop
      if Terminated then
      begin
        SCDTerminatedInfo := SCDTerminatedInfo + ' || Execute >> After R-file is updated';
        goto LExit;
      end
      else
      begin
        SCDDump( 'SCD> Break Download Task >> R-file Error >> ' + SCDScanTaskRFile );
        break;
      end;
    end   // if not SCDLoadTextFile( ...
    else
    begin // if SCDLoadTextFile( ...
      SCDRFileLocCont.Assign( SCDRFileCont ); // ??? is really needed 2015-01-27
      TaskRState := SCDRFileCont.Values['IsDone'];
      TaskWasFinished := TaskRState = 'TRUE';
      SCDScanRCount := StrToIntDef( SCDRFileCont.Values['ScanCount'], 0 );

      if TaskWasStarted and (not TaskWasFinished or (SCDScanRCount > 0)) then
      begin // Set R-file init Download state
        TaskWasStarted := FALSE;
        SCDRFileLocCont.Values['IsDone'] := 'FALSE';
        SCDRFileLocCont.Values['ScanCount'] := '0';
        SCDUpdateTaskLocRFile();
      end;

      if SCDScanRCount > SCDScanDownloadCount then
      begin // Task Files Download is needed
        Res := SCDownloadNewTaskFiles( TaskWasFinished );
        if TaskWasFinished then Break;
        if Res <> scdCopyFilesOK then
        begin
          if Terminated then
          begin
            SCDTerminatedInfo := SCDTerminatedInfo + ' || Execute >> after SCDownloadNewTaskFiles';
            goto LExit;
          end
          else
          begin
            SCDTerminatedInfo := SCDTerminatedInfo + ' || Execute >> after SCDownloadNewTaskFiles';
            goto UploadSFileStep;
          end;
        end;
      end  // Task Files Download is needed
      else
      if TaskWasFinished then
      begin // Set Task Finished State only
        SCDRFileLocCont.Values['IsDone'] := 'TRUE';
        SCDRFileLocCont.Values['ScanCount'] := IntToStr( SCDScanDownloadCount );
        SCDUpdateTaskLocRFile();
        Break;
      end; // if TaskWasFinished then
    end; // if SCULoadLocTextFile( ...

    if Terminated then
    begin
      SCDTerminatedInfo := SCDTerminatedInfo + ' || Execute >> before wait sleep';
      goto LExit;
    end;
    Sleep( 200 );

    Inc(ErrCount);
    if (ErrCount mod 300) = 0 then
      SCDDump( format( 'SCD> Wait Task Download Continue >> LC=%d %s', [ErrCount,SCDScanTaskRFile] ) );
  end; // while TRUE do
  //
  // Download Task Files Loop
  ///////////////////////////

  ///////////////////////////
  // Download Final Actions
  //
  SCDTerminatedInfo := 'Execute >> Finish after Download';

UploadSFileStep: //*******
  while TRUE do
  begin
    // Stop Thread
//    Suspended := TRUE;
//    while not SCDBreakDownloadFlag do Sleep(100);
    while SCDBreakDownloadState = 0 do Sleep(100);

    if Terminated then goto LExit;
    case SCDFinActionCode of
      0: // write STOP to S-file
      begin
        SCDTerminatedInfo := 'Execute >> Copy Task S-file STOP Loop';
        if not UploadSFile( 'STOP' ) then goto LExit; // Thread is Terminated
        while not SCDSetTaskTermFlag do Sleep(100);
        SCDTerminatedInfo := 'Execute >> Copy Task S-file TERM Loop after STOP';
        UploadSFile( 'TERM' );
        goto LExit;
      end; // write STOP to S-file

      1: // write TERM to S-file
      begin
        SCDTerminatedInfo := 'Execute >> Copy Task S-file TERM Loop';
        while not SCDSetTaskTermFlag do Sleep(100);
        UploadSFile( 'TERM' );
        goto LExit;
      end; // write TERM to S-file

      2: // Remove Task Files
      begin
        SCDTerminatedInfo := 'Execute >> Task remove';
        SL := TStringList.Create;
        if not K_CMScanRemoveTask( 'Execute >>', SCDScanTaskSFile,
                                   SCDScanTaskRFile, SCDScanTaskFolder,
                                   SL, SCDT, SCDDump, SCDDump ) then
        begin // Task Remove Error >> Try to mark Task as Terminated for future remove by CMScan
          SCDDump( 'Execute >> Task Remove Error >> Set terminated state S-file=' + SCDScanTaskSFile );
          SL.Text := 'IsTerm=TRUE';
          if not K_VFSaveStrings( SL, SCDScanTaskSFile, K_DFCreatePlain ) then
            SCDDump( 'Execute >> Mark Task as terminated error' );
        end;
        SL.Free;
        goto LExit;
      end; // Remove Task Files
    end; // case SCDFinActionCode of
  end; // while TRUE do

LExit: //******
//  SCDOnTerminate(Self);
  //
  // Download Final Actions
  ///////////////////////////

end; // TK_SCDScanDataThread.Execute

//************************************* TK_SCDScanDataThread.SCDOnTerminate ***
// Download Thread OnTerminate Handler
//
procedure TK_SCDScanDataThread.SCDOnTerminate(Sender: TObject);
begin
  if SCDDumpBuffer = nil then Exit;
  FreeAndNil( SCDRFileCont );
  FreeAndNil( SCDRFileLocCont );
  FreeAndNil( SCDFilesList );
  FreeAndNil( SCDT );
  N_Dump1Str( 'SCD> Download Data Thread is terminated >> ' + SCDScanTaskSFile );
  SCDDump0(  #13#10'****************** >> ' + SCDTerminatedInfo + #13#10 +
             '****************** Download Session fin ' +
             FormatDateTime( 'yyyy-mm-dd_hh":"nn":"ss.zzz'#13#10, Now() ) +
             '  S-file=' + SCDScanTaskSFile + #13#10 );
  FreeAndNil( SCDDumpBuffer );
end;

//********************************* TK_SCDScanDataThread.SCDCheckConnection ***
// Check Connection to Exchange Folder
//
//    Parameters
// ATimout - check timeout
// Result - Returns TRUE if Connection is OK, FALSE Connection was revived
//
function TK_SCDScanDataThread.SCDCheckConnection( ATimout : Integer ): Boolean;

var
  OnDataPathAccessLost : Boolean;
begin
  OnDataPathAccessLost := FALSE;
  Result := TRUE;

//  while not DirectoryExists( K_CMScanDataPath ) do
  while not DirectoryExists( SCDCurScanDataPath ) do
  begin
    Result := FALSE;
    if Terminated then
    begin
      SCDTerminatedInfo := SCDTerminatedInfo + ' || SCDCheckConnection >> wait connection';
      Exit;
    end;
//    if SCDBreakDownloadFlag then
    if SCDBreakDownloadState = 0 then
    begin
      SCDDump( 'SCD> SCDCheckConnection Break Check Loop' );
      Exit;
    end;
    if not OnDataPathAccessLost then
    begin
      SCDDump( 'SCD> !!! ScanDataPath access is lost' );
      OnDataPathAccessLost := TRUE;
    end;
    Sleep( ATimout );
  end;

  if not Result then
    SCDDump( 'SCD> !!! ScanDataPath access is revived' );

end; // procedure TK_SCDScanDataThread.SCDCheckConnection

//******************************************* TK_SCDScanDataThread.SCDDump0 ***
// Downpload Thread Dump
//
//     Parameters
// ADumpStr - dump info
//
procedure TK_SCDScanDataThread.SCDDump0( ADumpStr: string );
var
  F: TextFile;
  BufStr : string;
begin
  if SCDLogFName = '' then Exit;
  try
    SCDDumpBuffer.Add( ADumpStr );
    Assign( F, SCDLogFName );
    if not FileExists( SCDLogFName ) then
      Rewrite( F )
    else
      Append( F );

    Inc(SCdLogInd);
    BufStr := SCdDumpBuffer.Text;
    WriteLn( F, Copy( BufStr, 1, Length(BufStr) - 2 ) );
    SCDDumpBuffer.Clear;
    Flush( F );
  finally
    Close( F );
  end;
end; // procedure TK_SCDScanDataThread.SCDDump0

//******************************************** TK_SCDScanDataThread.SCUDump ***
// Upload Thread Dump
//
//     Parameters
// ADumpStr - dump info
//
procedure TK_SCDScanDataThread.SCDDump( ADumpStr: string );
begin
  SCDDump0( format( '%.3d> %s %s', [SCDLogInd,
                        FormatDateTime( 'dd-hh":"nn":"ss.zzz', Now() ), ADumpStr] ) );
end; // procedure TK_SCDScanDataThread.SCDDump

//************************************ TK_SCDScanDataThread.SCDLoadTextFile ***
// Load Text File to given Strings
//
//    Parameters
// AFileName - file name to load
// AStrings  - Strings object to Load
// ANotSkipError - if TRUE then single attempt will be done
// Result - Returns TRUE if success
//
function TK_SCDScanDataThread.SCDLoadTextFile(const AFileName: string;
             AStrings: TStrings; ANotSkipError : Boolean = FALSE ): Boolean;
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
      SCDTerminatedInfo := SCDTerminatedInfo + ' || SCDLoadTextFile >> load loop';
      Exit;
    end;

    SCDT.Start();
    ErrStr :=  K_VFLoadStrings1( AFileName, AStrings, ErrCode );
    SCDT.Stop();
    Result := ErrStr = '';
    if Result then Break;
    SCDDump( format( 'SCD> SCDLoadTextFile Load Error >> %s Time=%s'#13#10'>>%s',
             [AFileName, SCDT.ToStr(), ErrStr] ) );
    if ANotSkipError then Exit;
    Inc(ErrCount);
    if ErrCount >= K_SCDScanMaxWANErrCount then Exit;
    if SCDCheckConnection( 1000 ) then
      Sleep(1000);
  end; // while TRUE do

end; // function TK_SCDScanDataThread.SCDLoadTextFile

//***************************** TK_SCDScanDataThread.SCDownloadNewTaskFiles ***
// Upload New Task Files
//
//    Parameters
// Result - Returns 0 if OK, 1 if Task is stoped, 2 if Task is broken
//
function TK_SCDScanDataThread.SCDownloadNewTaskFiles( ATaskWasFinished : Boolean ) : Integer;

var
  i : Integer;
  PrevScannedFile : string;
  ScannedFile : string;
  F: TSearchRec;
  CopySuccessFlag : Boolean;
  RFileContState : string;

label RetryLoop, ContLoop, ContCopy, FinLoop;

  //******************************* UpdateUploadInfo
  function UpdateDownloadInfo( ASLideNum : Integer ) : Boolean;
  begin
    SCDRFileLocCont.Values['ScanCount'] := IntToStr( ASLideNum );

    RFileContState := SCDRFileLocCont.Values['IsDone'] + ' ' + SCDRFileLocCont.Values['ScanCount'];

    SCDDump( 'SCD> UpdateDownloadInfo RFileContState ' + RFileContState );
    if Terminated then
      SCDTerminatedInfo := SCDTerminatedInfo + ' || SCDownloadNewTaskFiles >> UpdateDownloadInfo';

    Result := not Terminated;
    if SCDRFileContState = RFileContState  then Exit; // nothing to do

    SCDUpdateTaskLocRFile();

    if not Result then  Exit;

    SCDScanDownloadCount := ASLideNum;

    if PrevScannedFile = '' then Exit;
  end; // function UpdateDownloadInfo( ASLideNum : Integer ) : Boolean;

begin

  Result := scdCopyFilesOK;
  i := 0;
  if FindFirst( SCDScanTaskFolder + '*.*', faAnyFile, F ) <> 0 then
  begin
    SCDDump( 'SCD> DownloadTaskNewFiles >> FindFirst not found' );
    Exit;
  end;

  repeat // skip fisrt '.'
    if (F.Name[1] <> '.') and ((F.Attr and faDirectory) = 0) then
      goto ContCopy;
  until FindNext( F ) <> 0; // End of Files Upload Loop

  SCDDump( format( 'SCD> DownloadTaskNewFiles >> Empty LocBufer Task S-file=%s',
                   [SCDScanTaskSFile] ) );
  Exit;

ContCopy:
  // Files Upload Loop
  SCDDump( format( 'SCD> Download Loop for %d slides is started from Ind=%d S-file=%s',
              [SCDScanRCount, SCDScanDownloadCount, SCDScanTaskSFile] ) );
  SCDRFileLocCont.Values['IsDone'] := K_CMScanTaskIsUploaded;
  PrevScannedFile := '';
  repeat

//    if SCDBreakDownloadFlag then
    if SCDBreakDownloadState <> 0 then
    begin
      SCDDump( 'SCD> SCDownloadNewTaskFiles Break Download Loop' );
      Result := scdCopyFilesStop;
      goto FinLoop;
    end;

    ScannedFile := SCDScanTaskFolder + F.Name;
    if ScannedFile[Length(ScannedFile) - 4] = 'A' then
    begin // Slide Start File
      // Correct R-file by Slides Count
      if i > SCDScanDownloadCount then
      begin
        SCDDump( 'SCD> before UpdateDownloadInfo 1' );
        if not UpdateDownloadInfo( i ) then goto FinLoop;
      end; // if i > SCDScanDownloadCount then

      // All Ready Slides are copied - copy loop should be broken
      if not ATaskWasFinished and (i = SCDScanRCount) then Break;

      PrevScannedFile := ScannedFile;
      Inc(i); // New Slide is started - i = New Slide counter
    end; // if ScannedFile[Ind] = 'A' then

    if i <= SCDScanDownloadCount then
    begin // File was already copied, Try Next File
      SCDDump( format( 'SCD> DownloadTaskNewFiles >> File %s is already copied', [F.Name] ) );
      goto ContLoop;
    end;

    ///////////////////////
    // Task File Download Loop
    //
RetryLoop: //***********
    if Terminated then
    begin
      SCDTerminatedInfo := SCDTerminatedInfo + ' || SCDploadNewTaskFiles >> RetryLoop';
      Result := scdCopyFilesBreak;
      goto FinLoop;
    end;

//    if SCDBreakDownloadFlag then
    if SCDBreakDownloadState <> 0 then
    begin
      SCDDump( 'SCD> SCDownloadNewTaskFiles Break Download Loop' );
      Result := scdCopyFilesStop;
      goto FinLoop;
    end;

    SCDT.Start();
    CopySuccessFlag := CopyFile( PChar(ScannedFile), PChar( SCDScanTaskLocFolder + F.Name ), false );
    SCDT.Stop();
//      CopyFilesFlag := CopyFilesFlag or NoCopyErrFlag;
    if not CopySuccessFlag then
    begin
      SCDDump( format( 'SCD> DownloadTaskNewFiles >> File %s Size=%d copy Error Time=%s >> %s',
                       [F.Name, F.Size, SCDT.ToStr(), SysErrorMessage(GetLastError())] ) );
      if SCDCheckConnection( 200 ) then
        Sleep(200);
      goto RetryLoop;
    end  // if not CopySuccessFlag then
    else // Copy File Report
      SCDDump( 'SCD> DownloadTaskNewFiles >> ' +
               K_CMScanGetFileCopyReport( F.Name, F.Size, SCDT ) );
    //
    // Task File Download Loop
    ///////////////////////

ContLoop: //***********

  until FindNext( F ) <> 0; // End of Files Upload Loop

  SCDScanDownloadCount := i; // All Results are copied

  if ATaskWasFinished then
    SCDRFileLocCont.Values['IsDone'] := 'TRUE';

  SCDDump( 'SCD> before UpdateDownloadInfo 2' );
  UpdateDownloadInfo( SCDScanDownloadCount );

FinLoop:   //***********
  FindClose( F );
end; // function TK_SCDScanDataThread.SCDownloadNewTaskFiles
{
//************************* TK_SCDScanDataThread.SCDScanFilesTreeSelectFile ***
// Select Emergency Cache Files scan files subtree function
//
//     Parameters
// APathName - testing path
// AFileName - testing file name
//
function TK_SCDScanDataThread.SCDScanFilesTreeSelectFile(const APathName,
  AFileName: string): TK_ScanTreeResult;
begin
  Result := K_tucSkipSubTree;
  if AFileName = '' then
    Exit;
  SCDFilesList.Add(APathName + AFileName);
end; // TK_SCDScanDataThread.SCDScanFilesTreeSelectFile
}
//****************************** TK_SCDScanDataThread.SCDUpdateTaskLocRFile ***
// Update Task Local RFile
//
procedure TK_SCDScanDataThread.SCDUpdateTaskLocRFile;
var
  Res : Boolean;
begin

  while TRUE do
  begin
    if Terminated then
    begin
      SCDTerminatedInfo := SCDTerminatedInfo + ' || SCDDpdateTaskLocRFile >> save loop';
      Exit;
    end;
    SCDT.Start();
    Res := K_VFSaveStrings( SCDRFileLocCont, SCDScanTaskLocRFile, K_DFCreatePlain );
    SCDT.Stop();
    if Res then
    begin
      SCDDump( format( 'SCD> Update Download Task IsDone=%s Count=%s  R-file=%s',
                          [SCDRFileLocCont.Values['IsDone'],
                           SCDRFileLocCont.Values['ScanCount'],
                           K_CMScanGetFileCopyReport( ExtractFileName(SCDScanTaskLocRFile), Length(SCDRFileLocCont.Text) + 1, SCDT )] ) );
      Break;
    end
    else
    begin // File save Error
      SCDDump( format( 'SCU> Update Download Task R-file Time=%s Error >> %s',
                        [SCDT.ToStr(), SCDScanTaskLocRFile] ) );
      if SCDCheckConnection( 1000 ) then
        Sleep( 1000 ); // Wait before continue
    end;  // File save Error
  end; // while TRUE do
end; // TK_SCDScanDataThread.SCDUpdateTaskLocRFile

{*** end of  TK_SCDScanDataThread ***}

end.
