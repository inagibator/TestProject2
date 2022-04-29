unit K_D4WScanLib;

interface

function  D4WScanAddMessageW( AMes: PWideChar ) : Integer; stdcall;
function  D4WScanAddMessage( AMes: PAnsiChar ) : Integer; stdcall;
function  D4WScanCommonInitW( AExchangeFolder, AWrkFolder, ALogFilesFolder : PWideChar;
                              ACodePage : Integer ) : Integer; stdcall;
function  D4WScanCommonInit( AExchangeFolder, AWrkFolder, ALogFilesFolder : PAnsiChar;
                             ACodePage : Integer ) : Integer; stdcall;
function  D4WScanSetCurPatientW( ACurPatID : Integer; APatSurname, APatFirstName : PWideChar ) : Integer; stdcall;
function  D4WScanSetCurPatient( ACurPatID : Integer; APatSurname, APatFirstName : PAnsiChar ) : Integer; stdcall;
function  D4WScanTaskStartW( AResImgFNameBChars : PWideChar ) : Integer; stdcall;
function  D4WScanTaskStart( AResImgFNameBChars : PAnsiChar ) : Integer; stdcall;
function  D4WScanTaskStop( ) : Integer; stdcall;
function  D4WScanTaskCheckState( APImgCount, APD4WScanState, APPatID : PInteger ) : Integer; stdcall;
function  D4WScanCommonFree( ) : Integer; stdcall;

implementation

uses Windows,Classes, SysUtils,
N_Types, N_Lib0,
K_CLib0, K_CM2;


const
  DScanLibVer = 6;
  K_CMScanClientStateFileName  = 'ScanClientState.txt';
  K_CMScanCommonInfoFileName   = 'ScanCommonInfo.txt';
  K_CMScanCurTaskInfoFileName  = 'ScanCurTaskInfo.txt';
  K_CMSkipTaskWrkFName         = 'SkipTaskWrkFName.txt';

type TK_CMScanState = (
  K_ScanIsNotStarted,        //0
  K_ScanDeviceIsNotStarted,  //1
  K_ScanDeviceIsStarted,     //2
  K_ScanFilesUpload,         //3
  K_ScanTaskIsFinished,      //4
  K_ScanTaskIsBroken         //5
); // type TK_CMScanState

type TK_CMScanSelfState = (
  K_ScanSelfTaskIsNotStarted,
  K_ScanSelfIsNotStarted,
  K_ScanSelfReady,
  K_ScanSelfSetup,
  K_ScanSelfDoOtherTask,
  K_ScanSelfDoCurTask
); // type TK_CMScanSelfState

var
  DSExchangeFolder : string; // Files Exchange folder
  DSClientExchangeFolder : string; // Client Files Exchange folder
  DSWrkFolder      : string; // Local Temp Files folder
  DSClientWrkFolder: string; // Client Local Temp File folder
  DSLogFolder      : string;  // Log Files folder
  DSMainLogFName   : string; // Main Log file name
  DSCheckPathLogFName : string; // Check Client Exchange folder
  DSTransLogFName  : string; // Transfer log file name
  DSCodePage       : Integer; // using code page
  DSClientName     : string; //
  DSServerName     : string; //
  DSUserName       : string; //

// Patient context
  DSPatID    : Integer; // Patient ID
  DSRPatID   : Integer; // Resulting Patient ID
  DSPatSName : string; // Patient Surname
  DSPatFName : string; // Patient Firstname

// Objects
  DSDumpObj : TK_DumpObj;

  DSPathCheckThread : TK_CFPFilePathCheckThread;
  DSPathCheckResult : TK_CFPResult;

// Current Task Context
  DSTransDataThread : TK_SCDScanDataThread;
  DSTransDataThreadWrkFlag : Boolean;
  DSSTask : TStringList;
  DSRTask : TStringList;
  DSScanCount : Integer;    // Scan Slides Counter

  DSInfoState : TK_CMScanState;    // Scan Info State: 0 - waiting for Software Start
                                       //              1 - waiting for scan device start
                                       //              2 - scan device have been started
                                       //              3 - waiting for resulting files upload
                                       //              4 - task is finished
                                       //              5 - task is broken by D4W
  DSScanSelfState : TK_CMScanSelfState;// Client Scanner State: 0 - task is not launched,
                                       //                       1 - Client Scanner is not started,
                                       //                       2 - Client Scanner is waiting for task,
                                       //                       3 - Client Scanner is in setup mode,
                                       //                       4 - Client Scanner is doing other task,
                                       //                       5 - Client Scanner is doing cur task


  DSRFileName : string;      // Task R-file name
  DSSFileName : string;      // Task S-file name
  DSTaskFolder: string;      // Task Folder name
  DSTaskID : string;         // Task ID
  DSStateFileName : string;  // Client Scanner State File Name
  DSRFileDate : TDateTime;   // Task R-file last update timestamp
  DSStateFileDate : TDateTime; // StateFile last update timestamp
  DSResImgFNameBChars : string;
  DSTermTaskFlag : Boolean;  // Task should be terminated Flag
  DSClearOldTaks : Boolean;

//***************************************************** SCGetFileCopyReport ***
// Get file copy report
//
//     Parameters
// AFName -  file name
// AFSize -  file size
//
function  SCGetFileCopyReport( const AFName : string; AFSize : Integer ) : string;
begin
  Result := K_CMScanGetFileCopyReport( ExtractFileName(AFName), AFSize, N_T1 );
end; // function  SCGetFileCopyReport

//******************************************************** SCUpdateTextFile ***
// Update Task RFile
//
//     Parameters
// ASStrings  - S-file current state strings
// ASFileName - S-file name
//
function  SCUpdateTextFile( ASStrings : TStrings; const ASFileName : string ) : string;
var
  BoolRes : Boolean;
begin
  N_T1.Start();
//  BoolRes := K_VFSaveStrings( ASStrings, ASFileName, K_DFCreatePlain );
  BoolRes := K_SaveTextToFile( ASStrings.Text, ASFileName );
  N_T1.Stop();
  Result := '';

  if not BoolRes then
    Result := format( '!!!File Create|Update Time=%s Error >> %s',
                      [N_T1.ToStr(), ASFileName] )
  else
    Result := SCGetFileCopyReport( ExtractFileName(ASFileName),
                                   Length(ASStrings.Text) + 1 );
end; // function  SCUpdateTextFile

//************************************************************** SCLoadText ***
// Load Text File to K_CMEDAccess.TmpStrings
//
//    Parameters
//  AFileName - file name to load
//  AText     - string buffer
//  Result - Returns TRUE if success
//
function SCLoadText( const AFileName : string; var AText : string ) : Boolean;
var
  ErrStr : string;
  ErrCode : Integer;

begin
  N_T1.Start();
  ErrCode := K_LoadTextFromFile( AText, AFileName );
  case ErrCode of
  1: ErrStr := 'Couldn''t read file';
  2: ErrStr := 'Wrong file text format';
  end;
//  ErrStr := K_VFLoadText1( AFileName, AText, ErrCode );
  N_T1.Stop();
  Result := ErrStr = '';
  if Result then Exit;
  N_Dump1Str( format( 'D4WScan Load Error Time=%s >> %s'#13#10'>> %s',
                      [N_T1.ToStr(),AFileName,ErrStr] ) );
end; // function SCLoadText

//******************************************************* SCUpdateTaskRFile ***
// Update R-file State
//
//     Parameters
// Result - Returns TRUE if file Exists
//
function SCUpdateTaskRFile : Boolean;
var
  NewFileDate : TDateTime;
  LoadRes : Boolean;
  StrBuf : string;
begin
  Result := DSRTask.Count > 0;
  N_T1.Start();
  NewFileDate := K_GetFileAge( DSRFileName );
  N_T1.Stop();

  if NewFileDate <= DSRFileDate then Exit;

  N_Dump2Str( format( 'D4WScan.SCUpdateTaskRFile start R%s.txt from %s, AgeTime=%s',
                      [DSTaskID, K_DateTimeToStr(NewFileDate, 'dd-hh:nn:ss.zzz'),
                      N_T1.ToStr()] ) );


  LoadRes := SCLoadText( DSRFileName, StrBuf );

  if LoadRes then
  begin
    DSRTask.Text := StrBuf;
    DSRFileDate := NewFileDate;
    N_Dump2Str( format( 'D4WScan.SCUpdateTaskRFile fin IsDone=%s Count=%s  R-file=%s',
                          [DSRTask.Values['IsDone'],
                           DSRTask.Values['ScanCount'],
                           K_CMScanGetFileCopyReport( 'R'+DSTaskID, Length(StrBuf) + 1, N_T1 )] ) );
  end
  else
    DSRTask.Clear;

  Result := DSRTask.Count > 0;

end; // function SCUpdateTaskRFile

//********************************************* SCUpdateScanSelfStateByFile ***
// Update State file
//
//     Parameters
// Result - Returns CMScan state:
//#F
// 1 - is not launched (K_ScanSelfIsNotStarted),
// 2 - wait (K_ScanSelfReady),
// 3 - setup (K_ScanSelfSetup),
// 4 - do other task (K_ScanSelfDoOtherTask),
// 5 - do cur task (K_ScanSelfDoCurTask)
//#/F
//
function SCUpdateScanSelfStateByFile : TK_CMScanSelfState;
var
  NewFileDate : TDateTime;
  StateStr : string;
  FName: string;
begin
  NewFileDate := K_GetFileAge( DSStateFileName );
  Result := K_ScanSelfIsNotStarted;
  if NewFileDate = 0 then Exit;
  Result := DSScanSelfState;
  if NewFileDate <= DSStateFileDate then Exit;
  DSStateFileDate := NewFileDate;
  FName := ExtractFileName(DSStateFileName);
  N_Dump2Str( 'D4WScan.SCUpdateScanSelfStateByFile start ' + FName );

  if SCLoadText( DSStateFileName, StateStr ) then
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
       (DSTaskID = Copy(StateStr, 4, 15)) then
      Result:= K_ScanSelfDoCurTask;
    DSScanSelfState := Result;
    N_Dump2Str( format( 'D4WScan.SCUpdateScanSelfStateByFile fin State=%d >> %s',
                        [Ord(DSScanSelfState), SCGetFileCopyReport( FName, Length(StateStr)+ 1 )] ) );
  end;

end; // function SCUpdateScanSelfStateByFile

///////////////////////
// DLL API functions
//

//****************************************************** D4WScanAddMessageW ***
// Add message to main log
//
//     Parameters
// AMes - message to add
// Result - Returns 0 - all OK, -1 - initialization was not done
//
function  D4WScanAddMessageW( AMes: PWideChar ) : Integer; stdcall;
begin
  Result := -1;
  if DSDumpObj = nil then Exit;
  Result := 0;
  N_Dump1Str( N_WideToString( AMes ) );
end; // function  D4WScanAddMessageW

//******************************************************* D4WScanAddMessage ***
// Add message to main log
//
//     Parameters
// AMes - message to add
// Result - Returns 0 - all OK, -1 - initialization was not done
//
function  D4WScanAddMessage( AMes: PAnsiChar ) : Integer; stdcall;
begin
  Result := -1;
  if DSDumpObj = nil then Exit;
  Result := 0;
  N_Dump1Str( N_AnsiToString( AMes ) );
end; // function  D4WScanAddMessage

//****************************************************** D4WScanCommonInitW ***
// Initialized D4W Scan Common cotext
//
//     Parameters
// AExchangeFolder - folder for files exchange
// AWrkFolder      - folder for temporary files, will be cleared on D4WScanPathInit
// ALogFilesFolder - folder for 2 log files: D4WScanLogMain.txt and D4WLogScanUploadData.txt
// ACodePage       - code page for string conversion from ANSI to Unicode
// Result - Returns 0 - all OK, -1 - initialization was alredy done, 1 - something is wrong,
//                  99 - unknown exception
//
function  D4WScanCommonInitW( AExchangeFolder, AWrkFolder, ALogFilesFolder : PWideChar;
                              ACodePage : Integer ) : Integer; stdcall;
var
  WStr,EF,WF,LF : string;
  WTSSessionInfo : TK_WTSSessionInfo;
//  var DLLPath : array[0..1000] of char;
label ErrExit;
begin
  try
    DSCodePage := ACodePage;
    N_NeededCodePage := DSCodePage;
    LF := IncludeTrailingPathDelimiter(
               ExpandFileName(N_WideToString(ALogFilesFolder)) ); // Log files folder
    EF := IncludeTrailingPathDelimiter(
               ExpandFileName(N_WideToString(AExchangeFolder)) ); // Files Exchange folder
    WF := IncludeTrailingPathDelimiter(
               ExpandFileName(N_WideToString(AWrkFolder)) ); // Local Temp File folder

    K_WTSGetSessionInfo( @WTSSessionInfo );
    DSUserName   := WTSSessionInfo.WTSUserName;
    DSServerName := WTSSessionInfo.WTSServerCompName;
    if (WTSSessionInfo.WTSClientProtocolType = WTS_PROTOCOL_TYPE_CONSOLE) then
      DSClientName := DSServerName
    else
      DSClientName := WTSSessionInfo.WTSClientName;
//    if DSClientName = '' then // for testing
//      DSClientName := DSServerName;

    Result := 0;
    if DSDumpObj = nil then
    begin

      if LF = '\' then
      begin
        Result := 1;
        DSExchangeFolder := '';
        Exit;
      end;

      WStr := LF + DSClientName + '\';
      if DSUserName <> '' then
        WStr := WStr + DSUserName + '\';
      if not K_ForceDirPath( WStr ) then
      begin
        Result := 1;
        DSExchangeFolder := '';
        Exit;
      end;

      DSLogFolder := LF;
      DSTransLogFName  := WStr + 'D4WScanLogUploadData.txt'; // Transfer log file name
      DSMainLogFName   := WStr + 'D4WScanLogMain.txt'; // Main Log file name
      DSCheckPathLogFName := WStr + 'D4WScanLogCheckPath.txt'; //

      DSDumpObj := TK_DumpObj.Create( DSMainLogFName, format( '#%u ',[GetCurrentThread()] ) );
      N_Dump1Str := DSDumpObj.DumpStr;
      N_Dump2Str := DSDumpObj.DumpStr0;
    end
    else
    if DSExchangeFolder <> '' then
    begin
      Result := -1;
      WStr := format( 'ExchangeFolder="%s"'#13#10+
                      'WrkFolder="%s"'#13#10+
                      'LogFolder="%s"'#13#10+
                      'CodePage=%d',
                      [DSExchangeFolder,DSWrkFolder,
                       DSLogFolder,DSCodePage] );
      N_Dump1Str( 'D4WScanCommonInitW was already called with:'#13#10 + WStr );
      Exit;
    end;

//    GetModuleFileName(HInstance,DLLPath,High(DLLPath));

    N_Dump2Str( #13#10#13#10'****** Start at ' + FormatDateTime( 'yyyy-mm-dd-hh":"nn":"ss.zzz', Now() ) +
                       ' D4WScanLib Trace in ' + DSTransLogFName  );
    if SizeOf(Char) = 2 then
  {$IF CompilerVersion >= 26.0} // Delphi >= XE5
      N_Dump2Str( '****** Compiled by Delphi XE5 ver=' + IntTostr(DScanLibVer) )
  {$ELSE}         // Delphi 2010
      N_Dump2Str( '****** Compiled by Delphi 2010 ver=' + IntTostr(DScanLibVer) )
  {$IFEND CompilerVersion >= 26.0}
    else
      N_Dump2Str( '****** Compiled by Delphi 7 ver=' + IntTostr(DScanLibVer) );

    WStr := format( 'ExchangeFolder="%s"'#13#10+
                    'WrkFolder="%s"'#13#10+
                    'LogFolder="%s"'#13#10+
                    'CodePage=%d',
                    [EF,WF,LF,ACodePage] );
    N_Dump1Str( 'D4WScanCommonInitW start:'#13#10 + WStr );


    if (EF = '\') or (WF = '\') then
    begin
      Result := 1;
      N_Dump1Str( 'D4WScanCommonInitW wrong parameters' );
      Exit;
    end;

    if not DirectoryExists( WF ) then
    begin
      Result := 1;
      N_Dump1Str( 'D4WScanCommonInitW Wrk folder is not exist' );
      Exit;
    end;

    DSWrkFolder := WF;
    DSClientWrkFolder := DSWrkFolder + DSClientName + '\' + DSUserName + '\';
    K_ForceDirPath( DSClientWrkFolder );
//    K_DeleteFolderFilesEx( DSWrkFolder, nil );
    K_DeleteFolderFilesEx( DSClientWrkFolder, nil );


    DSExchangeFolder := EF;
    DSClientExchangeFolder := DSExchangeFolder + DSClientName + '\';
    N_Dump2Str( 'D4WScanCommonInitW set check folder ' + DSClientExchangeFolder );

    DSPathCheckThread := TK_CFPFilePathCheckThread.Create(TRUE);
    DSPathCheckThread.FreeOnTerminate := TRUE;
    DSPathCheckThread.CFPDumpObj := TK_DumpObj.Create(DSCheckPathLogFName, format( '#%u ', [DSPathCheckThread.Handle] ) );
    DSPathCheckThread.CFPSkipTaskWrkFName := DSClientWrkFolder + K_CMSkipTaskWrkFName;

    DSPathCheckThread.CFPPResult := @DSPathCheckResult;
    DSPathCheckResult.CFPState := cfpsNotDef;
    DSPathCheckThread.CFPSetNewCheckPath( DSClientExchangeFolder );
    DSPathCheckThread.CFPSyncGetCheckContext();
    DSPathCheckThread.CFPContinue();
{ // Debug code
while DSPathCheckResult.CFPState = cfpsNotDef do
begin
N_Dump2Str( 'D4WScanCommonInitW wait' );
sleep(5);
end;
}

    DSSTask := TStringList.Create;
    DSRTask := TStringList.Create;

    N_Dump2Str( 'D4WScanCommonInitW fin' );
  except
    on E: Exception do
    begin
      if DSDumpObj <> nil then
        N_Dump1Str( 'D4WScanCommonInitW unknown exception >> ' + E.Message );
      Result := 99;
    end;
  end; // try

end; // function  D4WScanCommonInitW

//******************************************************* D4WScanCommonInit ***
// Initialized D4W Scan Common cotext
//
//     Parameters
// AExchangeFolder - folder for files exchange
// AWrkFolder      - folder for temporary files, will be cleared on D4WScanPathInit
// ALogFilesFolder - folder for 2 log files: D4WScanLogMain.txt and D4WLogScanUploadData.txt
// ACodePage       - code page for string conversion from ANSI to Unicode
// Result - Returns 0 - all OK, -1 - initialization was alredy done, 1 - something is wrong,
//                  99 - unknown exception
//
function  D4WScanCommonInit( AExchangeFolder, AWrkFolder, ALogFilesFolder : PAnsiChar;
                             ACodePage : Integer ) : Integer; stdcall;
var
  WExchangeFolder, WWrkFolder, WLogFilesFolder : WideString;
  PWExchangeFolder, PWWrkFolder, PWLogFilesFolder : PWideChar;
begin
  N_NeededCodePage := ACodePage;
  WExchangeFolder := N_AnsiToWide(AExchangeFolder);
  PWExchangeFolder := nil;
  if WExchangeFolder <> '' then
    PWExchangeFolder := @WExchangeFolder[1];

  WWrkFolder      := N_AnsiToWide(AWrkFolder);
  PWWrkFolder := nil;
  if WWrkFolder <> '' then
    PWWrkFolder := @WWrkFolder[1];

  WLogFilesFolder := N_AnsiToWide(ALogFilesFolder);
  PWLogFilesFolder := nil;
  if WLogFilesFolder <> '' then
    PWLogFilesFolder := @WLogFilesFolder[1];

  Result := D4WScanCommonInitW( PWExchangeFolder, PWWrkFolder,
                      PWLogFilesFolder, ACodePage );
end; // function  D4WScanCommonInit

//*************************************************** D4WScanSetCurPatientW ***
// Initialized D4W Scan Common cotext
//
//     Parameters
// ACurPatID     - Patient ID
// APatSurname   - Patient Surname
// APatFirstName - Patient Firstname
// Result - Returns 0 - all OK, -1 - initialization was not done, 1 - Patient surname is absent
//                  99 - unknown exception
//
function  D4WScanSetCurPatientW( ACurPatID : Integer; APatSurname, APatFirstName : PWideChar ) : Integer; stdcall;
var
  WStr : String;
begin
  try
    DSPatSName := N_WideToString(APatSurname); // Patient Surname
    DSPatFName := N_WideToString(APatFirstName); // Patient Firstname
    WStr := format( 'PatID=%d PatSN=%s PatFN=%s',
                    [ACurPatID,DSPatSName,DSPatFName] );
    Result := -1;
    if DSExchangeFolder = '' then
    begin
      D4WScanAddMessage( PAnsiChar('D4WSetCurPatientW common context was not initialized properly:'#13#10 + N_StringToAnsi(WStr) ));
      Exit;
    end;

    N_Dump1Str( 'D4WSetCurPatientW start: ' + WStr );
    DSPatID    := ACurPatID; // Patient Code
    Result := 0;
    if DSPatID = 0 then
    begin
      N_Dump1Str( 'D4WSetCurPatientW Patient ID was not specified' );
      Result := 1;
      Exit;
    end;

    if DSPatSName = '' then
    begin
      N_Dump1Str( 'D4WSetCurPatientW Patient Surname was not specified' );
      DSPatID := 0;
      Result := 1;
      Exit;
    end;
    N_Dump2Str( 'D4WSetCurPatientW fin' );
  except
    on E: Exception do
    begin
      N_Dump1Str( 'D4WScanSetCurPatientW unknown exception >> ' + E.Message );
      Result := 99;
    end;
  end; // try
end; // function  D4WScanSetCurPatientW

//**************************************************** D4WScanSetCurPatient ***
// Initialized D4W Scan Common cotext
//
//     Parameters
// ACurPatID - folder for files exchange
// APatSurname      - folder for temporary files, will be clear on D4WScanPathInit
// APatFirstName - folder for 2 log files: D4WScanLogMain.txt and D4WLogScanUploadData.txt
// Result - Returns 0 - all OK, -1 - initialization was not done, 1 - Patient surname is absent
//                  99 - unknown exception
//
function  D4WScanSetCurPatient( ACurPatID : Integer; APatSurname, APatFirstName : PAnsiChar ) : Integer; stdcall;
var
  WPatSurname, WPatFirstName : WideString;
  PWPatSurname, PWPatFirstName : PWideChar;
begin
  N_Dump2Str( 'D4WScanSetCurPatient start' );
  WPatSurname   := N_AnsiToWide(APatSurname);
  PWPatSurname := nil;
  if WPatSurname <> '' then
    PWPatSurname := @WPatSurname[1];

  WPatFirstName := N_AnsiToWide(APatFirstName);
  PWPatFirstName := nil;
  if WPatFirstName <> '' then
    PWPatFirstName := @WPatFirstName[1];

  Result := D4WScanSetCurPatientW( ACurPatID, PWPatSurname, PWPatFirstName );
end; // function  D4WScanSetCurPatient

//******************************************************* D4WScanTaskStartW ***
// Start new Scan Task
//
//     Parameters
// AResImgFNameBChars - Image files full name prefix - <ImageNumber>.png will be added to resulting image files
// Result - Returns 0 - all OK,
//    -1 - initialization was not done,
//    -2 - Current Patient Info is not set
//    -3 - Exchange Folder was lost or Client D4WScan was not installed
//     1 - Previouse Scan Task is not finished
//     2 - Pervious Scan Task is doing some final actions (try later, maximal delay 4 minutes)
//     3 - Something went wrong
//    99 - unknown exception
//
function  D4WScanTaskStartW( AResImgFNameBChars : PWideChar ) : Integer; stdcall;
var
//  FSFileName : string;       // Task S-file name
  WStr : string;
  i : Integer;
begin
  try
    DSResImgFNameBChars := ExpandFileName(N_WideToString(AResImgFNameBChars));

    Result := -1;
    if DSExchangeFolder = '' then
    begin
      D4WScanAddMessage( PAnsiChar('D4WScanTaskStartW common context was not initialized properly') );
      Exit;
    end;

    Result := -2;
    if DSPatID = 0 then
    begin
      N_Dump1Str( 'D4WScanTaskStartW current patient was not set' );
      Exit;
    end;

    // Wait for Path Check for 30 sec
    i := 0;
    while (DSPathCheckResult.CFPState = cfpsNotDef) and (i < 200 * 30) do
    begin
      sleep(5);
      Inc(i)
    end;

    Result := -3;
    if DSPathCheckResult.CFPState <> cfpsOpOK then
    begin
      N_Dump1Str( format( 'D4WScanTaskStartW exchange folder problems %d',
                               [Ord(DSPathCheckResult.CFPState)] ) );
      Exit;
    end;

    Result := 1;
    if DSScanSelfState <> K_ScanSelfTaskIsNotStarted then // Task Finish Flag
    begin
      N_Dump1Str( 'D4WScanTaskStartW previous task was not finished' );
      Exit;
    end;

{
    Result := 2;
    if DSTransDataThreadWrkFlag then
    begin
      N_Dump1Str( 'D4WScanTaskStartW previous task thread was not finished' );
      Exit;
    end;
}
    if DSTransDataThreadWrkFlag then
      N_Dump1Str( 'D4WScanTaskStartW previous task thread was not finished' );

    N_Dump1Str( 'D4WScanTaskStartW start :' + DSResImgFNameBChars );

    //  Prepare Task File Names
    DSTaskID := K_DateTimeToStr( Now(), 'yymmddhhnnsszzz' );
    DSTaskFolder := 'F' + DSTaskID;

    Result := 3;
    WStr := DSClientWrkFolder + 'F' + DSTaskID + '\';
    if not K_ForceDirPath( WStr ) then
    begin
      N_Dump1Str( 'D4WScanTaskStartW couldn''t create task folder ' + WStr );
      Exit;
    end;

    Result := 0;
    DSScanCount := 0;
    DSRPatID    := DSPatID;


    // Prepare Task S-file
    DSSTask.Text := format(
      'IsTerm=FALSE'#13#10'CurPatID=%d'#13#10'CurProvID=1'#13#10'CurLocID=1'#13#10+
      'PatientTitle='#13#10'PatientGender='#13#10'PatientCardNumber='#13#10+
      'PatientSurname=%s'#13#10'PatientFirstName=%s'#13#10'PatientMiddle='#13#10+
      'PatientDOB='#13#10'ServCompName=%s',
      [DSPatID,DSPatSName,DSPatFName,DSServerName] );

    DSRTask.Clear; // Clear from previouse task


    DSTransDataThread := TK_SCDScanDataThread.Create(TRUE);
    DSTransDataThread.SCDDumpObj := TK_DumpObj.Create(DSTransLogFName, format( '#%u ', [DSTransDataThread.Handle] ));

    DSTransDataThread.SCDPThreadFinResult := @DSTransDataThreadWrkFlag;
    DSTransDataThread.FreeOnTerminate := TRUE;
    DSTransDataThread.SCDScanTasID:= DSTaskID;
  //  DSTransDataThread.SCDLogFName := DSTransLogFName;

    DSTransDataThread.SCDCurScanDataPath     := DSExchangeFolder;
    DSTransDataThread.SCDScanTaskLocFolder   := 'F' + DSTaskID;
    DSTransDataThread.SCDScanTaskLocRFile    := DSTransDataThread.SCDScanTaskLocFolder + '.txt';
    DSTransDataThread.SCDScanTaskLocRFile[1] := 'R';
    DSTransDataThread.SCDScanTaskLocSFile    := DSTransDataThread.SCDScanTaskLocRFile;
    DSTransDataThread.SCDScanTaskLocSFile[1] := 'S';
  //  FSFileName  := DSTransDataThread.SCDScanTaskLocSFile; // Task file Name without path

    // Set new task name to clear tasks thread
    DSPathCheckThread.Suspended := TRUE;
    DSPathCheckThread.CFPSkipTaskSFName := Copy(DSTransDataThread.SCDScanTaskLocSFile, 1, 20);
    DSPathCheckThread.CFPSkipTaskSFNameFlag := TRUE;
    DSPathCheckThread.Suspended := FALSE;

    DSTransDataThread.SCDScanTaskFolder := DSClientExchangeFolder + DSTransDataThread.SCDScanTaskLocFolder + '\'; // Thread  Task Folder
    DSTransDataThread.SCDScanTaskRFile  := DSClientExchangeFolder + DSTransDataThread.SCDScanTaskLocRFile;  // Thread  Task R-file
    DSTransDataThread.SCDScanTaskSFile  := DSClientExchangeFolder + DSTransDataThread.SCDScanTaskLocSFile;  // Thread  Task S-file

    DSTransDataThread.SCDScanTaskLocFolder := DSClientWrkFolder + DSTransDataThread.SCDScanTaskLocFolder + '\'; // Thread Task Loc Folder
    DSTransDataThread.SCDScanTaskLocRFile  := DSClientWrkFolder + DSTransDataThread.SCDScanTaskLocRFile;        // Thread Task Loc R-file
    DSTransDataThread.SCDScanTaskLocSFile  := DSClientWrkFolder + DSTransDataThread.SCDScanTaskLocSFile;        // Thread Task Loc S-file

    DSTransDataThread.SCDScanStateLocFile  := DSClientWrkFolder + K_CMScanClientStateFileName;      // Thread CMScan Local State file

  //  DSTransDataThread.SCDScanTaskNameFile  := DSClientExchangeFolder + K_CMScanCurTaskInfoFileName; // Thread Task name File to clear
    DSTransDataThread.SCDScanStateFile     := DSClientExchangeFolder + K_CMScanClientStateFileName; // Thread CMScan State file
    DSTransDataThread.SCDSkipTaskWrkFName  := DSClientWrkFolder + K_CMSkipTaskWrkFName;

    // Change D4WScan Exchange Context
    DSTaskFolder    := DSTransDataThread.SCDScanTaskLocFolder;
    DSRFileName     := DSTransDataThread.SCDScanTaskLocRFile;
    DSSFileName     := DSTransDataThread.SCDScanTaskLocSFile;
    DSStateFileName := DSTransDataThread.SCDScanStateLocFile;
    DSScanSelfState := K_ScanSelfIsNotStarted;
    DSInfoState     := K_ScanIsNotStarted;


    N_Dump1Str( 'D4WScan CurTaskName file >> ' + SCUpdateTextFile( DSSTask, DSSFileName ) );
    DSTransDataThread.Suspended := FALSE;


    N_Dump2Str( 'D4WScanTaskStartW fin' );
  except
    on E: Exception do
    begin
      N_Dump1Str( 'D4WScanTaskStartW unknown exception >> ' + E.Message );
      Result := 99;
    end;
  end; // try
end; // function  D4WScanTaskStartW

//******************************************************** D4WScanTaskStart ***
// Start new Scan Task
//
//     Parameters
// AResImgFNameBChars - Image files full name prefix - <ImageNumber>.png will be added to resulting image files
// Result - Returns 0 - all OK,
//    -1 - initialization was not done,
//    -2 - Current Patient Info is not set
//    -3 - Exchange Folder was lost or Client D4WScan was not installed
//     1 - Previouse Scan Task is not finished
//     2 - Pervious Scan Task is doing some final actions (try later, maximal delay 4 minutes)
//     3 - Something went wrong
//    99 - unknown exception
//
function  D4WScanTaskStart( AResImgFNameBChars : PAnsiChar ) : Integer; stdcall;
var
  WResImgFNameBChars : WideString;
  PWResImgFNameBChars : PWideChar;
begin
  N_Dump2Str( 'D4WScanTaskStart start' );
  WResImgFNameBChars := N_AnsiToWide(AResImgFNameBChars);
  PWResImgFNameBChars := nil;
  if WResImgFNameBChars <> '' then
    PWResImgFNameBChars := @WResImgFNameBChars[1];
  Result := D4WScanTaskStartW( PWResImgFNameBChars );
end; // function  D4WScanTaskStart

//********************************************************* D4WScanTaskStop ***
// Finish current Scan Task
//
//     Parameters
// Result - Returns 0 - all OK,
//  -1 - initialization was not done,
//  -2 - Current Patient was not set
//   1 - Task was not started
//  99 - unknown exception
//
function  D4WScanTaskStop( ) : Integer; stdcall;
begin
  try
    Result := -1;
    if DSExchangeFolder = '' then
    begin
      D4WScanAddMessage( PAnsiChar('D4WScanTaskStop common context was not initialized') );
      Exit;
    end;

    N_Dump2Str( 'D4WScanTaskStop Start' );
    Result := -2;
    if DSPatID <= 0 then
    begin
      N_Dump1Str( 'D4WScanTaskStop current patient was not set' );
      Exit;
    end;

    Result := 1;
    if DSScanSelfState = K_ScanSelfTaskIsNotStarted then // Task is not started
    begin
      N_Dump1Str( 'D4WScanTaskStop task was not started' );
      Exit;
    end;

    Result := 0;
    DSTermTaskFlag := TRUE;
    DSTransDataThread.Suspended := TRUE;
    DSSTask.Values['IsTerm'] := K_CMScanTaskIsStopped;
    N_Dump1Str( 'D4WScan Set Stop to CurTaskName file >> ' + SCUpdateTextFile( DSSTask, DSSFileName ) );

    DSTransDataThread.SCDBreakDownloadFlag := TRUE; // Activate DSTransDataThread fin action
    DSTransDataThread.Suspended := FALSE;

    N_Dump2Str( 'D4WScanTaskStop fin' );
  except
    on E: Exception do
    begin
      N_Dump1Str( 'D4WScanTaskStop unknown exception >> ' + E.Message );
      Result := 99;
    end;
  end; // try
end; // function  D4WScanTaskStop

//*************************************************** D4WScanTaskCheckState ***
// Check Current Scan Task state
//
//     Parameters
// APImgCount     - pointer to resulting image counter
// APD4WScanState - pointer to resulting Scan Task state code
//  -1 - Scan Task state is undefined
//   0 - Scan Task was finished by Client D4WScan
//   1 - Scan Task is broken by D4W
//   2 - Client D4WScan was not started to do current Scan Task
//   3 - Client D4WScan scan device was not started
//   4 - Client D4WScan scanning is in process
//   5 - Client D4WScan resulting image files are uploaded
// Result - Returns 0 - all OK,
//  -1 - initialization was not done,
//  -2 - Current Patient was not set
//   1 - there is no launched Scan Task
//  99 - unknown exception
//
function  D4WScanTaskCheckState( APImgCount, APD4WScanState, APPatID : PInteger ) : Integer; stdcall;
var
  RFileExists : Boolean;
  RScan : Integer;
  RTaskState : Integer;  //
  RScanState : Integer;
  RemoveLocalTask : Boolean;
  ExecPhase : string;

  procedure ImgFilesCopy( OldCount, NewCount : Integer );
  var
    F: TSearchRec;
    RInd, CurInd{, WInt, PatID} : Integer;
    SName, DName : string;
  begin
    CurInd := OldCount + 1;
    RInd := 0;
    if FindFirst( DSTaskFolder + '*.*', faAnyFile, F ) = 0 then
    repeat
      if F.Name[1] = '.' then continue;

      Inc(RInd);
{
      WInt := Pos( '_', F.Name );
      if WInt = 0 then
      begin
        N_Dump1Str( format( 'D4WScanTaskCheckState ImgFilesCopy wrong img file name >> %s', [F.Name] ) );
        Inc(CurInd);
        Continue;
      end;

      if CurInd = 1 then
      begin // Detect patient
      // File Name pattern
      //  <PatID>_<FileNum>.png
        PatID := StrToIntDef( Copy( F.Name, 1, WInt - 1 ), -1 );
        if PatID = -1 then
        begin
          N_Dump1Str( format( 'D4WScanTaskCheckState ImgFilesCopy wrong img file name >> %s', [F.Name] ) );
          Inc(CurInd);
          Continue;
        end;
        DSRPatID := PatID;
      end; // if CurInd = 1 then
}
      if RInd < CurInd then Continue; // file is already copied

      SName := DSTaskFolder + F.Name;
//      DName := Copy( F.Name, WInt + 1, 100 );
//      DName := DSResImgFNameBChars + DName;
      DName := DSResImgFNameBChars + F.Name;
      K_CopyFile( SName, DName, [K_cffOverwriteNewer] );
      Inc(CurInd);

      if RInd = NewCount then break;

    until FindNext( F ) <> 0;
    FindClose( F );

  end; // procedure ImgFilesCopy

  procedure CheckUploadedImages();
  begin
    RScan := StrToIntDef( DSRTask.Values['ScanCount'], 0 );
    if RScan <> DSScanCount then
    begin
      ImgFilesCopy( DSScanCount, RScan);
      N_Dump1Str( format( 'D4WScanTaskCheckState images %d are uploaded', [RScan] ) );
    end;
    DSScanCount := RScan;
  end; // procedure CheckUploadedImages

begin
  try
    ExecPhase := 'start';
    APImgCount^     := 0;
    APD4WScanState^ := -1;
    APPatID^        := 0;
    Result := -1;
    if DSExchangeFolder = '' then
    begin
      D4WScanAddMessage( PAnsiChar('D4WScanTaskCheckState common context was not initialized properly') );
      Exit;
    end;

    Result := -2;
    if DSPatID <= 0 then
    begin
      N_Dump1Str( 'D4WScanTaskCheckState current patient was not set' );
      Exit;
    end;

    Result := 1;
    if (DSInfoState = K_ScanIsNotStarted) and
       (DSScanSelfState = K_ScanSelfTaskIsNotStarted) then // Task Finish Flag
    begin
      N_Dump1Str( 'D4WScanTaskCheckState task was not started' );
      Exit;
    end;

    ExecPhase := 'check state';
    if (DSScanSelfState <> K_ScanSelfTaskIsNotStarted) and
       (DSInfoState <> K_ScanTaskIsFinished)           and
       (DSInfoState <> K_ScanTaskIsBroken) then
    begin
      RFileExists := SCUpdateTaskRFile();
      if not RFileExists then
      begin
        SCUpdateScanSelfStateByFile();
        if DSInfoState = K_ScanIsNotStarted then
        begin
          if DSScanSelfState = K_ScanSelfDoCurTask then
            DSInfoState := K_ScanDeviceIsNotStarted;
        end
      end   // if not RFileExists then
      else
      begin // if RFileExists then
        if DSInfoState < K_ScanDeviceIsStarted then
          DSInfoState := K_ScanDeviceIsStarted;

        RTaskState := 0;
        if DSRTask.Values['IsDone'] = K_CMScanTaskIsUploaded then RTaskState := 1
        else
        if DSRTask.Values['IsDone'] = 'TRUE' then RTaskState := 2;

        DSRPatID := StrToIntDef( DSRTask.Values['CurPatID'], DSPatID );

        if RTaskState = 1 then
          DSInfoState := K_ScanFilesUpload;

        CheckUploadedImages();

        if RTaskState = 2 then
        begin
          N_Dump1Str( 'D4WScan Task is finished by ScanClient' );
          DSInfoState := K_ScanTaskIsFinished;
        end;
      end;  // if RFileExists then
    end; // if DSScanSelfState <> K_ScanSelfTaskIsNotStarted then


    if DSTermTaskFlag and (DSInfoState = K_ScanTaskIsFinished) then DSTermTaskFlag := FALSE;

    RemoveLocalTask := FALSE;
    if DSTermTaskFlag then // Scan break is started
    begin
      DSInfoState := K_ScanTaskIsBroken;
      RemoveLocalTask := TRUE;
    end  // if DSTermTaskFlag then
    else
    if (DSInfoState = K_ScanTaskIsFinished) and
       (DSScanSelfState <> K_ScanSelfTaskIsNotStarted) then
    begin // Fin Thread if Task is finished
      RemoveLocalTask := TRUE;
    end; // if (DSInfoState = K_ScanTaskIsFinished) and ...

    if RemoveLocalTask then
    begin
      // Set Breake Download flag to finish tasks upload thread
      ExecPhase := 'set DSTransDataThread attrs';
      DSTransDataThread.Suspended := TRUE;
      DSTransDataThread.SCDBreakDownloadFlag := TRUE; // Activate DSTransDataThread fin action
      DSTransDataThread.SCDTermFlag := TRUE;
      if not DSTermTaskFlag then
        DSTransDataThread.SCDFinActionCode := 2; // For skip remove Task in Exchage folder
      DSTransDataThread.Suspended := FALSE;

      DSTermTaskFlag := FALSE;
      DSScanSelfState := K_ScanSelfTaskIsNotStarted;

      // Remove Local Task Task
      ExecPhase := 'remove loc task';
      DSSTask.Clear; // DSSTask is used for save undelete files names
      K_CMScanRemoveTask( 'D4WScan Loc', DSSFileName, DSRFileName, DSTaskFolder,
                                 DSSTask, N_T1, N_Dump1Str, N_Dump2Str );
      DSSTask.Clear; // Clear undelete files names

      // Remove Local D4WScan state file
      K_DeleteFile( DSStateFileName );

      // Clear current task name in clear tasks thread
      ExecPhase := 'set DSPathCheckThread attrs';
      DSPathCheckThread.Suspended := TRUE;
      DSPathCheckThread.CFPSkipTaskSFNameFlag := FALSE;
      DSPathCheckThread.Suspended := FALSE;

    end; // if RemoveLocalTask then

    ExecPhase := 'return results';
    RScanState := -1;
    case DSInfoState of
    K_ScanTaskIsFinished     : RScanState := 0;
    K_ScanTaskIsBroken       : RScanState := 1;
    K_ScanIsNotStarted       : RScanState := 2;
    K_ScanDeviceIsNotStarted : RScanState := 3;
    K_ScanDeviceIsStarted    : RScanState := 4;
    K_ScanFilesUpload        : RScanState := 5;
    end;

    APD4WScanState^ := RScanState;
    ExecPhase := 'after return ScanState';
    APImgCount^     := DSScanCount;
    ExecPhase := 'after return ImgCount';
    APPatID^        := DSRPatID;
    ExecPhase := 'after return RPatID';
    Result          := 0;
    N_Dump1Str( format('D4WScanTaskCheckState State=%d ImgCount=%d RPatID=%d fin',
                       [RScanState,DSScanCount,DSRPatID]) );
  except
    on E: Exception do
    begin
      N_Dump1Str( format('D4WScanTaskCheckState unknown exception Phase="%s" >> %s',
                  [ExecPhase,E.Message] ) );
      Result := 99;
    end;
  end; // try

end; // function  D4WScanTaskCheckState

//******************************************************* D4WScanCommonFree ***
// Clear D4WScan library context
//
//     Parameters
// Result - Returns
//     0 - all OK,
//    -1 - initialization was not done,
//    99 - unknown exception
//
function  D4WScanCommonFree( ) : Integer; stdcall;
var
  WImgCount, WScanState, WPatID : Integer;
begin
  try
    Result := -1;
    if (DSExchangeFolder = '') or (DSDumpObj = nil) or (DSPathCheckThread = nil) then
    begin
      D4WScanAddMessage( PAnsiChar('D4WScanCommonInitW was not called') );
      Exit;
    end;

    D4WScanAddMessage( PAnsiChar('D4WScanCommonFree start') );

    if DSScanSelfState <> K_ScanSelfTaskIsNotStarted then // Task Finish Flag
    begin
      N_Dump1Str( 'D4WScanCommonFree previous task was not finished' );
      D4WScanTaskStop( );
      sleep(1000);
    end;

    if DSTransDataThreadWrkFlag then
    begin
      N_Dump1Str( 'D4WScanCommonFree previous task thread was not finished' );
      D4WScanTaskCheckState( @WImgCount, @WScanState, @WPatID );
      DSTransDataThread.Terminate();
      sleep(1000);
    end;

    Result := 0;

    N_Dump1Str( 'D4WScanCommonFree fin'#13#10 +
    '****************************' + #13#10#13#10);
    DSExchangeFolder := '';
    FreeAndNil( DSDumpObj );
    DSPathCheckThread.Terminate();
    DSPathCheckThread := nil;
    DSSTask.Free;
    DSRTask.Free;
  except
    on E: Exception do
    begin
      N_Dump1Str( format('D4WScanCommonFree unknown exception >> %s',
                  [E.Message] ) );
      Result := 99;
    end;
  end; // try

end; // function  D4WScanCommonFree

end.
