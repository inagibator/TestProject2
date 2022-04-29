unit K_CM2;

interface

uses Classes,
N_Types, N_Lib0,
K_Types, K_Clib0;

function  K_CMScanRemoveTask( const ADumpPrfix, ATaskSFileName, ATaskRFileName,
                              ATaskRFolderName : string; AWrkStrings : TStrings;
                              AT1:  TN_CPUTimer1;
                              ADump1, ADump2 : TN_OneStrProcObj ) : Boolean;

function  K_CMScanGetFileCopyReport( const AFName : string; AFSize : Integer;
                                    ACPUTimer : TN_CPUTimer1 ) : string;
{
type TK_DumpObj = class
  DLogFname : string;
  DLogDInd  : Integer;
  DLogBufSL : TStringList;
  constructor Create( const ADumpFName : string );
  destructor  Destroy; override;
  procedure DumpStr0( ADumpStr: string);
  procedure DumpStr( ADumpStr: string);
end; // type TK_DumpObj
}

type TK_SCDScanDataThread = class (TThread)

  SCDPThreadFinResult  : PBoolean; // Pointer to Thread Working Flag

///////////////////////////////////////////////////////
// Download Context - should be set by thread creator
//
  SCDScanTasID : string; // Task Local Folder
  SCDScanTaskLocFolder : string; // Task Local Folder
  SCDScanTaskLocRFile  : string; // Task Local R-file
  SCDScanTaskLocSFile  : string; // Task Local S-file
  SCDScanStateLocFile  : string; // CMScan Local State file
  SCDScanTaskFolder : string; // Exchange Task Folder
  SCDScanTaskRFile  : string; // Exchange Task R-file
  SCDScanTaskSFile  : string; // Exchange Task S-file
  SCDScanStateFile  : string; // CMScan State file
  SCDSkipTaskWrkFName : string; // Wrk File Name on local Disk to transfer SkipTaskState to exhchange S-file
//  SCDScanTaskNameFile: string;
//
// Download Context - should be set by thread creator
///////////////////////////////////////////////////////

  SCDScanRCount        : Integer;
  SCDScanDownloadCount : Integer;
  SCDBreakDownloadFlag : Boolean; // Break Download Loop if "Cancel" is pressed
  SCDTermFlag       : Boolean; // Set Terminated task state if "Cancel" is pressed
  SCDFinActionCode  : Integer;  //!!!old 0 - write STOP to S-file, 1 - write TERM to S-file, 2 - Remove Task
                                //!!!now 0 - write STOP to S-file, 2 - Remove Task
  SCDRFileCont, SCDRFileLocCont, SCDFilesList : TStringList;
  SCDT : TN_CPUTimer1; // Timer for measuring one time interval

  SCDRFileContState : string;

//  SCDLogInd : Integer;
//  SCDLogFName : string;


//  SCDDumpBuffer : TStringList;

  SCDTerminatedInfo : string;

  SCDCurScanDataPath : string;

  SCDDumpObj : TK_DumpObj;


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
//  procedure SCRemovePrevTasks( );
  function  SCDWriteSFileTermState( const ASFileName : string; AMaxRCount : Integer ) : Boolean;
end; // type TK_SCDScanDataThread = class (TThread)

//////////////////////////////////////
//  Check File Path Types
//
type TK_CFPState = (
  cfpsNotDef,  // result is not define
  cfpsOpOK,    // path operation is OK
  cfpsOpFails, // path operation fails
  cfpsOpSlow   // path operation too slow
);
type TK_CFPResult = record
  CFPCheckNum : Integer;     // Check Number
  CFPState    : TK_CFPState; // Path State after Check
  CFPTime     : Int64;       // Path Check time interval in CPU ticks
  CFPPathCode : Integer;     // Check Path CRC code
end;
type TK_PCFPResult = ^TK_CFPResult;

type TK_CFPFilePathCheckThread = class (TThread)
  CFPCheckLoopDelay : Integer;  // Check Loop Delay
  CFPPResult   : TK_PCFPResult; // Pointer to External Check Result (for return to Main Thread )

  CFPCheckStopFlag   : Boolean; // Stop check File Path process

  CFPSingleCheckFlag : Boolean; // Single Check File Path flag
  CFPForcePathFlag   : Boolean; // Force File Path flag

  CFPNewFilePathFlag : Boolean; // Change File Path to check
  CFPNewFilePath : string;      // New File Path
  CFPDump2CheckResultFlag : Boolean; // Dump2 CheckResult Flag

  CFPDumpObj : TK_DumpObj;

  CFPSkipTaskSFName : string;
  CFPSkipTaskSFNameFlag : boolean;
  CFPSkipTaskWrkFName : string; // Wrk File Name on local Disk to transfer SkipTaskState to exhchange S-file

  procedure Execute(); override;
  function  CFPSetNewCheckPath( const APath : string ) : Integer;
  procedure CFPContinue();
  procedure CFPStop();
  procedure CFPSyncDump1( );
  procedure CFPSyncDump2( );
  procedure CFPSyncReturnCheckResult();
  procedure CFPSyncGetCheckContext();
  procedure CFPOnTerminate( Sender: TObject );

  function  CFPScanFilesTreeSelectFile( const APathName, AFileName: string; AScanLevel : Integer ) : TK_ScanTreeResult;
private
  CFPCheckCounter : Int64; // Path Check Counter
  CFPDumpStr : string;              // Dump Str
  CFPUT : TN_CPUTimer1;             // Check File Path Timer
  CFPCurResult : TK_CFPResult;  // Current Check Result
  CFPCurFilePath : string;      // Current File Path
  CFPCurSingleCheckFlag : Boolean; // Single Check File Path flag
  CFPCurForcePathFlag   : Boolean; // Force File Path flag
  CFPNewPathCode : Integer;  // New File Path Code
  CFPFilesList, CFPFileCont : TStringList;
end; // type TK_CFPFilePathCheckThread = class (TThread)

const
  K_CMScanTaskIsStopped  = 'FSTOP';
  K_CMScanTaskIsUploaded = 'FLOAD';
  K_CMScanNetworkMaxDelay = 10;
  K_CMScanNetworkMidDelay = 5;
  K_CMScanNetworkSlowMinTest = 3;
  K_CMScanNetworkRTDelay = 10;

function K_SaveTextToFile( const AText: string; const AFName: string ) : Boolean;
function K_LoadTextFromFile( var AText: string; const AFName: string ) : Integer;


implementation

uses Windows, SysUtils;

const K_SCDScanMaxWANErrCount = 20;
const K_SCDScanMaxLocErrCount = 10;

{
//******************************************************* TK_DumpObj.Create ***
// Dump object constructor
//
constructor TK_DumpObj.Create( const ADumpFName: string );
begin
  DLogFname := ADumpFName;
  DLogBufSL := TStringList.Create;
end; // constructor TK_DumpObj.Create

//******************************************************* TK_DumpObj.Create ***
// Dump object destructor
//
destructor TK_DumpObj.Destroy;
begin
  DLogBufSL.Free;
  inherited;
end; // destructor TK_DumpObj.Destroy

//****************************************************** TK_DumpObj.DumpStr ***
// Dump string to file without timestamp and line index
//
//     Parameters
// ADumpStr - dump info
//
procedure TK_DumpObj.DumpStr0( ADumpStr: string );
var
  F: TextFile;
  BufStr : string;
begin
  if DLogFname = '' then Exit;
  try
    DLogBufSL.Add( ADumpStr );
    Assign( F, DLogFname );
    if not FileExists( DLogFname ) then
      Rewrite( F )
    else
      Append( F );

    Inc(DLogDInd);
    BufStr := DLogBufSL.Text;
    WriteLn( F, Copy( BufStr, 1, Length(BufStr) - 2 ) );
    DLogBufSL.Clear;
    Flush( F );
  finally
    Close( F );
  end;
end; // procedure TK_DumpObj.DumpStr0

//****************************************************** TK_DumpObj.DumpStr ***
// Dump string to file with timestamp and line index
//
//     Parameters
// ADumpStr - dump info
//
procedure TK_DumpObj.DumpStr( ADumpStr: string );
begin
  DumpStr0( format( '%.3d> %s %s', [DLogDInd,
                        FormatDateTime( 'dd-hh":"nn":"ss.zzz', Now() ), ADumpStr] ) );
end; // procedure TK_DumpObj.DumpStr
}

//******************************************************** K_SaveTextToFile ***
// Save text to file with needed BOM
//
//    Parameters
// AText  - text
// AFName - file name to save
// Result - Returns TRUE if OK
//
function K_SaveTextToFile( const AText: string; const AFName: string ) : Boolean;
var
  FStream : TFileStream;
begin
  try
    FStream := TFileStream.Create( AFName, fmCreate );
  except
    FStream := nil;
  end;

  Result := FStream <> nil;
  if not Result then Exit;

  try
    K_SaveTextToStreamWithBOM( AText, FStream );
  except
    Result := FALSE;
  end;

  FStream.Free;
end; // function K_SaveTextToFile

//******************************************************** K_LoadTextFromFile ***
// Save text to file with needed BOM
//
//    Parameters
// AText  - text
// AFName - file name to save
// Result - Returns 0 if OK, 1 - if stream open problems, 2 - file format problems
//
function K_LoadTextFromFile( var AText: string; const AFName: string ) : Integer;
var
  FStream : TFileStream;
begin
  Result := 0;
  try
    FStream := TFileStream.Create( AFName, fmOpenRead );
  except
    FStream := nil;
    Result := 1;
  end;

  if FStream = nil then Exit;

  try
    if not K_LoadTextFromStreamWithBOM( AText, FStream ) then
      Result := 2;
  except
    Result := 1;
  end;

  FStream.Free;

end; // function K_LoadTextFromFile

//****************************************************** K_CMScanRemoveTask ***
// Remove current task files
//
//    Parameters
// ADumpPrfix     - DumpPrefix
// ATaskSFileName - Task S-File Name
// ATaskRFileName - Task R-File Name
// ATaskRFolderName - Task Results Folder Name
// Result - Returns TRUE if all Task Files are removed
//
function K_CMScanRemoveTask( const ADumpPrfix, ATaskSFileName, ATaskRFileName,
                             ATaskRFolderName : string; AWrkStrings : TStrings;
                             AT1:  TN_CPUTimer1;
                             ADump1, ADump2 : TN_OneStrProcObj ) : Boolean;
var
  RemoveRes : string;
begin
  ADump1( ADumpPrfix + ' RemoveTask >> start S-file=' + ExtractFileName(ATaskSFileName) );
  Result := TRUE;
  AT1.Start();
  RemoveRes := '';
  if DirectoryExists( ATaskRFolderName ) then
  begin
    AWrkStrings.Clear;
    K_DeleteFolderFilesEx( ATaskRFolderName, AWrkStrings );
    Result := AWrkStrings.Count = 0;
    if not Result then
      ADump1( ADumpPrfix + ' RemoveTask >> Result Files Delete Errors:'#13#10 + AWrkStrings.Text )
    else
    begin
      Result := RemoveDir( ATaskRFolderName );
      if not Result then
        ADump1( ADumpPrfix + ' RemoveTask >> Results Folder Remove Error >> ' + ATaskRFolderName );
    end;
    if Result then RemoveRes := 'D';
  end;

  if Result then
  begin
    if FileExists( ATaskRFileName ) then
    begin
      Result := K_DeleteFile( ATaskRFileName, [K_dofSkipStoreUndelNames] );
      if Result then RemoveRes := RemoveRes + '+R';
    end;

    if not Result then
      ADump1( ADumpPrfix + ' RemoveTask >> R-file Delete Error ' + ATaskRFileName )
    else
    begin
      if FileExists( ATaskSFileName ) then
      begin
        Result := K_DeleteFile( ATaskSFileName, [K_dofSkipStoreUndelNames] );
        if Result then RemoveRes := RemoveRes + '+S';
      end;
      if not Result then
        ADump1( ADumpPrfix + ' RemoveTask >> S-file Delete Error ' + ATaskSFileName )
    end;
  end;

  AT1.Stop();
  ADump2( format( ADumpPrfix + ' RemoveTask >> "%s" fin Time=%s Errors=%s S-file=%s',
                  [RemoveRes, AT1.ToStr(), N_B2S(not Result),ATaskSFileName] ) );

end; // procedure K_CMScanRemoveTask

//*********************************************** K_CMScanGetFileCopyReport ***
// Get file copy report
//
//     Parameters
// AFName - file name
// AFSize - file size
// ACPUTimer - CPU timer
//
function K_CMScanGetFileCopyReport( const AFName : string; AFSize : Integer;
                                    ACPUTimer : TN_CPUTimer1 ) : string;
begin
  Result :=  format( '%s Size=%d Time=%s Speed=%.3f KB/Sec',
                [AFName, AFSize, ACPUTimer.ToStr(),
                 AFSize / 1024 / ACPUTimer.DeltaCounter * N_CPUFrequency] )
end; // function  K_CMScanGetFileCopyReport

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
//  SL : TStringList;

label UploadSFileStep, LExit;
  //////////////////////
  // Upload Task S-file
  //
  function UploadSFile( const ADumpPref : string ) : Boolean;
  var
    FStream : TFileStream;
    FSize : Integer;
    FSizeCount : Integer;
    DumpFileName : string;

    function GetUploadSFileDumpInfo( ) : string;
    begin
      if DumpFileName = '' then DumpFileName := ExtractFileName(SCDScanTaskLocSFile);
      Result := ADumpPref + ' ' +  DumpFileName;
    end;

  begin
    Result := FALSE;
    FSizeCount := 0;
    while TRUE do // Copy Task S-file Loop
    begin
      if Terminated or SCDBreakDownloadFlag {or ClientScan is finished} then Exit;
      FSize := -1;
      try
        FStream := TFileStream.Create( SCDScanTaskLocSFile, fmOpenRead + fmShareDenyNone );
        FSize := FStream.Seek( 0, soEnd );
        FStream.Free;
      except
      end;

      if FSize <= 10 then
      begin
        if FSize = -1 then
        begin
          SCDDump( 'SCD> Upload S-file %s !!! is absent' );
          Exit;
        end;

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
      if CopySuccessFlag then Break;
//!!!      SCDDump( format( 'SCD> Upload S-file %s Time=%s !!! Error >>',  // mis %s 2017-09-15
      SCDDump( format( 'SCD> Upload S-file %s Time=%s !!! Error >> %s',
                  [GetUploadSFileDumpInfo(), SCDT.ToStr(), SysErrorMessage(GetLastError())] ) );

      if SCDCheckConnection( 200 ) then
        Sleep(200);
    end; // while TRUE do // Copy Task S-file Loop

    SCDDump( format( 'SCD> Upload S-file %s Time=%s',
                             [GetUploadSFileDumpInfo(), SCDT.ToStr()] ) );
    Result := TRUE;
  end; // function UploadSFile

begin

  SCDPThreadFinResult^ := TRUE;
  SCDRFileCont    := TStringList.Create;
  SCDRFileLocCont := TStringList.Create;
  SCDFilesList    := TStringList.Create;
//  SCDDumpBuffer   := TStringList.Create;
  SCDT := TN_CPUTimer1.Create;
  OnTerminate := SCDOnTerminate;
  SCDDump0( #13#10#13#10'****************** Download Session Start ' +
            FormatDateTime( 'yyyy-mm-dd_hh":"nn":"ss.zzz'#13#10, Now() ) +
            '  S-file=' + SCDScanTaskSFile + #13#10 );



  try
    SCDTerminatedInfo := 'Execute >> Copy Task S-file START Loop';
    if not UploadSFile( 'START' ) then goto LExit;

    //////////////////////////////////
    // Wait For Task R-File
    //
    StateFileDate := 0;
    SCDTerminatedInfo := 'Execute >> Wait For Task R-File';
    SCDDump( 'SCD> Execute >> Wait For Task R-File' );
    while K_GetFileAge( SCDScanTaskRFile ) = 0 do
    begin
      if SCDBreakDownloadFlag then
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
    end; // while K_GetFileAge1( SCDScanTaskRFile ) = 0 do

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
          not ForceDirectories( SCDScanTaskLocFolder ) do
  //        not K_ForceDirPath( SCDScanTaskLocFolder ) do
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
      if SCDBreakDownloadFlag then
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
    while not SCDBreakDownloadFlag do Sleep(100);

    if Terminated then goto LExit;

    // Try to write terminated state to task if it is terminated by D4W
    // If task is finished by D4WScan - should do nothing because this task will be removed by CFPFilePathCheckThread
    if SCDFinActionCode = 0 then
    begin
      SCDBreakDownloadFlag := FALSE;
      UploadSFile( 'STOP' );
      if Terminated then goto LExit;
      while not SCDTermFlag do Sleep(100);
      SCDWriteSFileTermState( SCDScanTaskSFile, 100 ); // Write Task Teminated state - Task will be removed by D4WScan
    end;

LExit: //****
  SCDOnTerminate( Self );  // Because OnTerminate not work in DLL

  except
    on E: Exception do
    begin
      SCDTerminatedInfo := SCDTerminatedInfo + #13#10 + ' || SCDScanDataThread exception >> ' + E.Message;
      Exit;
    end;
  end; // try


{
  while TRUE do
  begin
    // Stop Thread
//    Suspended := TRUE;
    while not SCDBreakDownloadFlag do Sleep(100);

    if Terminated then Exit;

    case SCDFinActionCode of
      0: // write S-file terminated state
      begin
        SCDBreakDownloadFlag := FALSE;
        SCDTerminatedInfo := 'Execute >> Mark Task as terminated';
        SCDWriteSFileTermState( SCDScanTaskSFile, 50 ); // Write Task Teminated state - Task will be removed by D4WScan
        Exit;
      end;
      2: // Remove Task Files
      begin
        SCDTerminatedInfo := 'Execute >> Current Task remove';
        SL := TStringList.Create;
        if not K_CMScanRemoveTask( 'Execute >>', SCDScanTaskSFile,
                                   SCDScanTaskRFile, SCDScanTaskFolder,
                                   SL, SCDT, SCDDump, SCDDump ) then
        begin // Task Remove Error >> Try to mark Task as Terminated for future remove by CMScan
          SCDDump( 'Execute >> Task Remove Error >> Set terminated state to S-file=' + SCDScanTaskSFile );
          SCDWriteSFileTermState( SCDScanTaskSFile, 10 ); // Write Task Teminated state - Task will be removed by D4WScan
        end;
        SL.Free;
        Exit;
      end; // Remove Task Files
    end; // case SCDFinActionCode of

  end; // while TRUE do
}
  //
  // Download Final Actions
  ///////////////////////////

end; // TK_SCDScanDataThread.Execute

//************************************* TK_SCDScanDataThread.SCDOnTerminate ***
// Download Thread OnTerminate Handler
//
procedure TK_SCDScanDataThread.SCDOnTerminate(Sender: TObject);
begin
  FreeAndNil( SCDRFileCont );
  FreeAndNil( SCDRFileLocCont );
  FreeAndNil( SCDFilesList );
  FreeAndNil( SCDT );
  if SCDDumpObj <> nil then
  begin
//    N_Dump1Str( 'SCD> Download Data Thread is terminated >> ' + SCDScanTaskSFile );
    SCDDump0(  #13#10'****************** >> ' + SCDTerminatedInfo + #13#10 +
               '****************** Download Session fin ' +
               FormatDateTime( 'yyyy-mm-dd_hh":"nn":"ss.zzz'#13#10, Now() ) +
               '  S-file=' + SCDScanTaskSFile + #13#10 );
  end;
// FreeAndNil( SCDDumpBuffer );
  FreeAndNil( SCDDumpObj );
  SCDPThreadFinResult^ := FALSE;
end; // procedure TK_SCDScanDataThread.SCDOnTerminate

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
    if SCDBreakDownloadFlag then
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
begin
  SCDDumpObj.DumpStr0( ADumpStr );
{
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
    BufStr := SCDDumpBuffer.Text;
    WriteLn( F, Copy( BufStr, 1, Length(BufStr) - 2 ) );
    SCDDumpBuffer.Clear;
    Flush( F );
  finally
    Close( F );
  end;
}
end; // procedure TK_SCDScanDataThread.SCDDump0

//******************************************** TK_SCDScanDataThread.SCUDump ***
// Upload Thread Dump
//
//     Parameters
// ADumpStr - dump info
//
procedure TK_SCDScanDataThread.SCDDump( ADumpStr: string );
begin
  SCDDumpObj.DumpStr( ADumpStr );
{
  SCDDump0( format( '%.3d> %s %s', [SCDLogInd,
                        FormatDateTime( 'dd-hh":"nn":"ss.zzz', Now() ), ADumpStr] ) );
}
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
  BufStr : string;
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
    ErrCode := K_LoadTextFromFile( BufStr, AFileName );
    case ErrCode of
    1: ErrStr := 'Couldn''t read file';
    2: ErrStr := 'Wrong file text format';
    end;

//    ErrStr :=  K_VFLoadStrings1( AFileName, AStrings, ErrCode );
    SCDT.Stop();
    Result := ErrStr = '';
    if Result then
    begin
      AStrings.Text := BufStr;
      Break;
    end;
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

//    if PrevScannedFile = '' then Exit;
  end; // function UpdateDownloadInfo

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
  SCDDump( format( 'SCD> Download Loop for %d images is started from Ind=%d S-file=%s',
              [SCDScanRCount, SCDScanDownloadCount, SCDScanTaskSFile] ) );
  SCDRFileLocCont.Values['IsDone'] := K_CMScanTaskIsUploaded;
  PrevScannedFile := '';
  repeat

    if SCDBreakDownloadFlag then
    begin
      SCDDump( 'SCD> SCDownloadNewTaskFiles Break Download Loop' );
      Result := scdCopyFilesStop;
      goto FinLoop;
    end;

    ScannedFile := SCDScanTaskFolder + F.Name;
//!!!    if ScannedFile[Length(ScannedFile) - 4] = 'A' then
//!!!    begin // Slide Start File
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
//!!!    end; // if ScannedFile[Ind] = 'A' then

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

    if SCDBreakDownloadFlag then
    begin
      SCDDump( 'SCD> SCDownloadNewTaskFiles Break Download Loop' );
      Result := scdCopyFilesStop;
      goto FinLoop;
    end;

    SCDT.Start();
    CopySuccessFlag := CopyFile( PChar(ScannedFile), PChar( SCDScanTaskLocFolder + F.Name ), false );
    SCDT.Stop();
    if not CopySuccessFlag then
    begin
      SCDDump( format( 'SCD> DownloadTaskNewFiles >> File %s copy Error Time=%s >> %s',
                       [F.Name, SCDT.ToStr(), SysErrorMessage(GetLastError())] ) );
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
//***************************** TK_SCDScanDataThread.SCDownloadNewTaskFiles ***
// Upload New Task Files
//
//    Parameters
// Result - Returns 0 if OK, 1 if Task is stoped, 2 if Task is broken
//
procedure TK_SCDScanDataThread.SCRemovePrevTasks( );

var
  i : Integer;
  PrevScannedFile : string;
  TaskFile : string;
  F: TSearchRec;
  CopySuccessFlag : Boolean;
  RFileContState : string;

label RetryLoop, ContLoop, ContRemove, FinLoop;


begin

  i := 0;
  if FindFirst( SCDCurScanDataPath + '*.*', faAnyFile, F ) <> 0 then
  begin
    SCDDump( 'SCD> SCRemovePrevTasks >> FindFirst not found' );
    Exit;
  end;

  repeat // skip fisrt '.'
    if (F.Name[1] <> '.') and ((F.Attr and faDirectory) = 0) then
      goto ContRemove;
  until FindNext( F ) <> 0; // End of Files Upload Loop

  SCDDump( 'SCD> SCRemovePrevTasks >> No Tasks to remove' );
  Exit;

ContRemove:
  // Tasks Remove Loop
  repeat

    if SCDBreakDownloadFlag then
    begin
      SCDDump( 'SCD> SCRemovePrevTasks Break Download Loop' );
      goto FinLoop;
    end;

    i := Length(F.Name);
    if (Length(F.Name) <> 20) or (F.Name[1] <> 'S') goto ContLoop;

    TaskFile := SCDCurScanDataPath + F.Name;
//!!!    if ScannedFile[Length(ScannedFile) - 4] = 'A' then
//!!!    begin // Slide Start File
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
//!!!    end; // if ScannedFile[Ind] = 'A' then

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

    if SCDBreakDownloadFlag then
    begin
      SCDDump( 'SCD> SCDownloadNewTaskFiles Break Download Loop' );
      Result := scdCopyFilesStop;
      goto FinLoop;
    end;

    SCDT.Start();
    CopySuccessFlag := CopyFile( PChar(ScannedFile), PChar( SCDScanTaskLocFolder + F.Name ), false );
    SCDT.Stop();
    if not CopySuccessFlag then
    begin
      SCDDump( format( 'SCD> DownloadTaskNewFiles >> File %s copy Error Time=%s >> %s',
                       [F.Name, SCDT.ToStr(), SysErrorMessage(GetLastError())] ) );
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
}

//****************************** TK_SCDScanDataThread.SCDWriteSFileTermState ***
// Write Task S-files terminated state
//
//    Parameters
// ASFileName - task S-file full name
// AMaxRCount - maximal repeat counter
// Result - Returns TRUE if OK, FALSE if error
//
function TK_SCDScanDataThread.SCDWriteSFileTermState( const ASFileName : string; AMaxRCount : Integer ) : Boolean;
var
  SaveRes : Boolean;
  FName : string;
  ErrCount : Integer;
begin
  ErrCount := 0;
  SaveRes := FALSE;
  FName := ExtractFileName( ASFileName );
  while TRUE do // Copy Task S-file Loop
  begin
{
    SCDT.Start();
    SaveRes := K_SaveTextToFile( 'IsTerm=TRUE', ASFileName );
    SCDT.Stop();
}
    K_SaveTextToFile( 'IsTerm=TRUE', SCDSkipTaskWrkFName );
    SCDT.Start();
    SaveRes := CopyFile( PChar(SCDSkipTaskWrkFName),
                                   PChar(ASFileName), FALSE );
    SCDT.Stop();
    K_DeleteFile( ASFileName );

    Inc(ErrCount);
    if SaveRes or (ErrCount > AMaxRCount) then Break;
    if (ErrCount mod 250) = 1 then
      SCDDump( format( 'SCD> Write S-file=%s terminated state Time=%s !!! Error >> %s',
                [FName, SCDT.ToStr(), SysErrorMessage(GetLastError())] ) );

    if SCDCheckConnection( 200 ) then
      Sleep(200);
  end; // while TRUE do // Copy Task S-file Loop

  Result := SaveRes;
  if Result then
    SCDDump( format( 'Execute >> SCD> Write S-file=%s terminated state >> TryCount = %d',
                     [FName, ErrCount] ) )
  else
    SCDDump( format( 'Execute >> Write S-file=%s terminated state Error >> TryCount = %d',
                     [FName, AMaxRCount] ) );
end; // function TK_SCDScanDataThread.SCDWriteSFileTermState

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
    Res := K_SaveTextToFile( SCDRFileLocCont.Text, SCDScanTaskLocRFile  );
//    Res := K_VFSaveStrings( SCDRFileLocCont, SCDScanTaskLocRFile, K_DFCreatePlain );
    SCDT.Stop();
    if Res then
    begin
      SCDDump( format( 'SCD> Update Download Lock Task IsDone=%s Count=%s  R-file=%s',
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

{*** TK_CFPFilePathCheckThread ***}

//*************************************** TK_CFPFilePathCheckThread.Execute ***
// Check File Path Thread Execute
//
procedure TK_CFPFilePathCheckThread.Execute;
var
  CheckRes : Boolean;
  NewCheckState   : TK_CFPState;
  i, RCount, SCount : Integer;
  CurFName : string;
  TextBuf : string;

  function CFPLoadText( const AFileName : string; var AText : string; ASkipErrCode : Integer) : Boolean;
  var
    ErrStr : string;
    ErrCode : Integer;

  begin
    CFPUT.Start();
    ErrCode := K_LoadTextFromFile( AText, AFileName );
    CFPUT.Stop();
    case ErrCode of
    1: ErrStr := 'Couldn''t read file';
    2: ErrStr := 'Wrong file text format';
    end;
    Result := (ErrStr = '') or ((ASkipErrCode <> 0) and (ASkipErrCode = ErrCode));
    if Result then Exit;
    // Dump file read error info
    CFPDumpStr := format( 'CFP> FilePathCheckThread Load file Error Time=%s >> %s'#13#10'>> %s',
                          [CFPUT.ToStr(),AFileName,ErrStr] );
    CFPSyncDump1( );
  end; // function CFPLoadText

  function CFPWriteSFileTermState( const ASFileName : string ) : Boolean;
  begin
    CFPUT.Start();
    Result := CopyFile( PChar(CFPSkipTaskWrkFName),
                                   PChar(ASFileName), FALSE );
    CFPUT.Stop();
{
    CFPUT.Start();
    Result := K_SaveTextToFile( 'IsTerm=TRUE', ASFileName );
    CFPUT.Stop();
}
    CFPDumpStr := format( 'CFP> Write S-file=%s terminated state Time=%s', [ASFileName, CFPUT.ToStr()] );
    if not Result then
      CFPDumpStr := CFPDumpStr + ' !!! Error >> ' + SysErrorMessage(GetLastError());
    CFPSyncDump1( );
  end; // function CFPWriteSFileTermState

begin
  CFPUT := TN_CPUTimer1.Create;
  CFPFilesList := TStringList.Create;
  CFPFileCont  := TStringList.Create;
  CFPCheckLoopDelay := 1000;
  OnTerminate := CFPOnTerminate;


  CFPDumpStr := #13#10#13#10'****************** Path Check Start ' +
            FormatDateTime( 'yyyy-mm-dd_hh":"nn":"ss.zzz'#13#10, Now() ) +
            '  Path=' + CFPNewFilePath + #13#10;
  CFPSyncDump2( );

  while TRUE do
  begin
    try
      if Terminated then Break; // check Terminated at Loop start
      // Get New Current Context

      if CFPCheckStopFlag then Suspended := TRUE;

      if Terminated then Break; // check Terminated after Thread Resume

//      Synchronize( CFPSyncGetCheckContext );

      if CFPCurFilePath = '' then // precaution
      begin
        Suspended := TRUE;
        Continue;
      end; // if CFPCurFilePath = '' then

      CFPUT.Start;
//if CFPCurResult.CFPCheckNum mod 100 < 10 then
//sleep( 11000 );
      if CFPCurForcePathFlag then
        CheckRes := K_ForceDirPath( CFPCurFilePath )
      else
        CheckRes := DirectoryExists( CFPCurFilePath );
      CFPUT.Stop;

      if CheckRes then
        NewCheckState := cfpsOpOK
      else
        NewCheckState := cfpsOpFails;

      Inc( CFPCurResult.CFPCheckNum );
      CFPDumpStr := '';
      if (CFPCurResult.CFPState <> NewCheckState) or
         ((CFPCurResult.CFPTime >= K_CMScanNetworkMaxDelay * N_CPUFrequency) and
          (CFPUT.DeltaCounter   <  K_CMScanNetworkMidDelay * N_CPUFrequency)) or
         ((CFPCurResult.CFPTime <  K_CMScanNetworkMidDelay * N_CPUFrequency) and
          (CFPUT.DeltaCounter   >= K_CMScanNetworkMaxDelay * N_CPUFrequency)) then
      begin
        CFPDumpStr := format( 'CFP> FilePathCheckThread CN=%d ST=%d>%d DET=%s',
                          [CFPCurResult.CFPCheckNum, Ord(CFPCurResult.CFPState),
                           Ord(NewCheckState), CFPUT.ToStr()] );
        CFPSyncDump1( );
      end;

      CFPCurResult.CFPState := NewCheckState;
      CFPCurResult.CFPTime  := CFPUT.DeltaCounter;

//      CFPSyncReturnCheckResult();
      CFPPResult^.CFPState := CFPCurResult.CFPState;

      if CFPCurSingleCheckFlag or CFPCurForcePathFlag then
      begin
        Suspended := TRUE;
        Continue;
      end; // if CFPCurSingleCheckFlag or CFPCurForcePathFlag then


      // Search for old Tasks and set remove task flag
      if (NewCheckState = cfpsOpOK) and ((CFPCheckCounter mod 10) = 0) then
      begin // clear old tasks
        CFPFilesList.Clear;
        CFPUT.Start;
        K_ScanFilesTree( CFPCurFilePath, CFPScanFilesTreeSelectFile, 'S???????????????.txt' );
        CFPUT.Stop;
        if CFPUT.DeltaCounter >= K_CMScanNetworkRTDelay * N_CPUFrequency then
        begin
          CFPDumpStr := format( 'CFP> FilePathCheckThread Clear old tasks slow ScanFilesTree >> Time=%s',
                                    [CFPUT.ToStr()] );
          CFPSyncDump1( );
        end;

        RCount := 0;

        if CFPFilesList.Count > 0 then
        begin
          K_SaveTextToFile( 'IsTerm=TRUE', CFPSkipTaskWrkFName );
          CFPFilesList.Sort();

          // Is needed if more then one TK_CFPFilePathCheckThread work
          // by errors in D4W - skip last Task s-file
          SCount := CFPFilesList.Count - 1;
          if not CFPSkipTaskSFNameFlag and
             (CFPSkipTaskSFName <> CFPFilesList[CFPFilesList.Count-1]) then
            Dec(SCount);

          for i := 0 to SCount do
          begin
            CurFName := CFPFilesList[i];

            // Check if Task S-file is Term
            if not CFPLoadText( CFPCurFilePath + CurFName, TextBuf, 0 ) then Continue;
            CFPFileCont.Text := TextBuf;
            if CFPFileCont.Values['IsTerm'] = 'TRUE' then Continue;

            //!!! May be this code is not needed - mark as removed all not marked tasks
            { !!!
            if CFPFileCont.Values['IsTerm'] <> K_CMScanTaskIsStopped then
            begin // Check R-file if task is not stoped
              // Check if Task R-file is Done
              CurFName[1] := 'R';
              TextBuf := '';
              if not CFPLoadText( CFPCurFilePath + CurFName, TextBuf, 1 ) then Continue;
              if TextBuf <> '' then
              begin
                CFPFileCont.Text := TextBuf;
                if CFPFileCont.Values['IsDone'] <> 'TRUE' then Continue;
              end;
              CurFName[1] := 'S';
            end;
            }

            // Task is done - mark as Terminated to Remove by D4WScan
            if CFPWriteSFileTermState( CFPCurFilePath + CurFName ) then
              Inc(RCount);
          end; // for i := 0 to CFPFilesList.Count - 1 do

          CFPFilesList.Sorted := FALSE;
        end; // if CFPFilesList.Count > 0 then

        if RCount > 0 then
        begin
          CFPDumpStr := format( 'CFP> FilePathCheckThread Mark as terminated %d old tasks', [RCount] );
          CFPSyncDump1( );
          K_DeleteFile( CFPSkipTaskWrkFName );
        end;

      end; // if (NewCheckState = cfpsOpOK) and ((CFPCheckCounter mod 10) = 0) then

    except
      on E: Exception do
      begin
        CFPDumpStr := 'CFP> FilePathCheckThread exception >> ' + E.Message;
//        Synchronize( CFPSyncDump1 );
        CFPSyncDump1();
      end;
    end; // try

    if Terminated then Break; // check Terminated before Sleep

    Inc(CFPCheckCounter);

    sleep( CFPCheckLoopDelay );

  end; // while TRUE do

  CFPOnTerminate(Self); // // Because OnTerminate not work in DLL
end; // TK_CFPFilePathCheckThread.Execute

//**************************** TK_CFPFilePathCheckThread.CFPSetNewCheckPath ***
// Set new File Path to check
//
//     Parameters
// APath  - new File Path to check
// Result - Returns new File Path CRC
//
function TK_CFPFilePathCheckThread.CFPSetNewCheckPath( const APath : string ) : Integer;
begin
  Result := 0;
  if APath = '' then
    CFPStop()
  else
  begin
    CFPNewPathCode := CFPCurResult.CFPPathCode;
    if CFPCurFilePath <> APath then
    begin
      CFPNewFilePath := APath;
      CFPNewPathCode := N_AdlerChecksum( @CFPNewFilePath[1], Length(CFPNewFilePath) * SizeOf(Char) );
    end;
    Result := CFPNewPathCode;
    // Skip Thread Activate if Same Path and SingleCheck Mode
//    if not CFPSingleCheckFlag or (CFPNewPathCode <> CFPCurResult.CFPPathCode) then
//      CFPContinue();
  end;
end; // TK_CFPFilePathCheckThread.CFPSetNewCheckPath

//*********************************** TK_CFPFilePathCheckThread.CFPContinue ***
// Continue Check File Path Thread
//
procedure TK_CFPFilePathCheckThread.CFPContinue();
begin
  CFPCheckStopFlag := FALSE;
  if Suspended then Suspended := FALSE;
end; // TK_CFPFilePathCheckThread.CFPContinue

//*************************************** TK_CFPFilePathCheckThread.CFPStop ***
// Stop Check File Path Thread
//
procedure TK_CFPFilePathCheckThread.CFPStop;
begin
  if Suspended then Exit;
  CFPCheckStopFlag := TRUE;
end; // TK_CFPFilePathCheckThread.CFPStop

//********************************** TK_CFPFilePathCheckThread.CFPSyncDump1 ***
// Write single string to main Dump1
//
// For call by Thread Synchronize method
//
procedure TK_CFPFilePathCheckThread.CFPSyncDump1(  );
begin
  if CFPDumpObj <> nil then
    CFPDumpObj.DumpStr( CFPDumpStr )
  else
    N_Dump1Str( CFPDumpStr );
end; // TK_CFPFilePathCheckThread.CFPSyncDump1

//********************************** TK_CFPFilePathCheckThread.CFPSyncDump2 ***
// Write single string to main Dump1
//
// For call by Thread Synchronize method
//
procedure TK_CFPFilePathCheckThread.CFPSyncDump2(  );
begin
  if CFPDumpObj <> nil then
    CFPDumpObj.DumpStr0( CFPDumpStr )
  else
    N_Dump2Str( CFPDumpStr );
end; // TK_CFPFilePathCheckThread.CFPSyncDump2

//********************** TK_CFPFilePathCheckThread.CFPSyncReturnCheckResult ***
// Return last check results
//
// For call by Thread Synchronize method
//
procedure TK_CFPFilePathCheckThread.CFPSyncReturnCheckResult();
begin
  if CFPDumpStr <> '' then
  begin
    if CFPDump2CheckResultFlag then
      CFPSyncDump2()
    else
      CFPSyncDump1();
  end;
  if CFPPResult = nil then Exit;
  CFPPResult^ := CFPCurResult;
end; // TK_CFPFilePathCheckThread.CFPSyncReturnCheckResult`

//************************ TK_CFPFilePathCheckThread.CFPSyncGetCheckContext ***
// Get next check context
//
// For call by Thread Synchronize method
//
procedure TK_CFPFilePathCheckThread.CFPSyncGetCheckContext();
begin

  CFPCurSingleCheckFlag := CFPSingleCheckFlag; // Single Check File Path flag
  CFPCurForcePathFlag   := CFPForcePathFlag;   // Force File Path flag

  if CFPNewPathCode <> CFPCurResult.CFPPathCode then
  begin
    CFPCurFilePath := CFPNewFilePath;           // New File Path
    CFPCurResult.CFPPathCode := CFPNewPathCode; // New File Path Code
    CFPCurResult.CFPState := cfpsNotDef;        // Cur Result State
  end;

end; // TK_CFPFilePathCheckThread.CFPSyncGetCheckContext

//******************************** TK_CFPFilePathCheckThread.CFPOnTerminate ***
// OnTerminate handler
//
procedure TK_CFPFilePathCheckThread.CFPOnTerminate(Sender: TObject);
begin
  if CFPDumpObj = nil then Exit;
  FreeAndNil( CFPUT );
  FreeAndNil( CFPFilesList );
  FreeAndNil( CFPFileCont );
  CFPDumpStr := #13#10'****************** >> Fin PathCheckThread ' +
            FormatDateTime( 'yyyy-mm-dd_hh":"nn":"ss.zzz'#13#10, Now() ) + #13#10;
  CFPSyncDump2( );
  FreeAndNil( CFPDumpObj );

end; // procedure TK_CFPFilePathCheckThread.CFPOnTerminate

//******************** TK_CFPFilePathCheckThread.CFPScanFilesTreeSelectFile ***
// Select Emergency Cache Files scan files subtree function
//
//     Parameters
// APathName - testing path
// AFileName - testing file name
//
function TK_CFPFilePathCheckThread.CFPScanFilesTreeSelectFile( const APathName,
  AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
begin
  Result := K_tucSkipSubTree;
  if (AFileName = '') or
     (CFPSkipTaskSFNameFlag and (CFPSkipTaskSFName = AFileName)) then
    Exit;

  CFPFilesList.Add(AFileName);
end; // TK_CFPFilePathCheckThread.CFPScanFilesTreeSelectFile

{*** end of TK_CFPFilePathCheckThread ***}

end.
