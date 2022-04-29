unit K_FCMEFSyncProc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ADODB,
  N_BaseF,
  K_CM0;

type TK_CMFSyncPathState = record
  SPSFolder  : string;  // Files Root Folder
  SPSFDA     : Boolean; // Direct Access to Files from CLient Computer
  SPSEFolder : string;  // Files Root Folder External Path
  SPSCheckTS : TDateTime; // Path Last check timestamp
  SPSSpace   : Int64;     // Path Last Space
  SPSExistFlag : Boolean; // Path Exists Flag
  SPSWriteFlag : Boolean; // Path Write Enable Flag
  SPSFailureCount : Integer; // Path Failure Counter
end;
type TK_CMPFSyncPathState = ^TK_CMFSyncPathState;

type TK_CMFilesAccessContext = record
  LocID          : Integer; // Location ID
//************ Image Files Context
//  ImgRootFolder  : string;  // Slides Image Files Root Folder
//  ImgRootFDA     : Boolean; // Direct Access to Images Files at Root Folder from CLient Computer
//  ImgRootEFolder : string;  // Slides Image Files Root Folder External Path
  ImgRootState  : TK_CMFSyncPathState; // Path State

//************ Video Files Context
//  MediaRootFolder: string;  // Slides Media Files Root Folder
//  MediaRootFDA   : Boolean; // Direct Access to Media Files at Server Root Folder from CLient Computer
//  MediaRootEFolder: string; // Slides Media Files Root Folder External Path
  MediaObjFlag : Boolean; // Meda Object flag
  MediaFSplit    : Boolean; // Split Media Files Flag
  MediaRootState  : TK_CMFSyncPathState; // Path State

//************ File Copy Attrs
  FilePath : string; // File Path
  FDA : Boolean;     // File Direct Access Flag
  FileName : string;
end;
type TK_CMPFilesAccessContext = ^TK_CMFilesAccessContext;
type TK_CMFilesAccessContextArr = array of TK_CMFilesAccessContext;

type
  TK_FormCMEFSyncProc = class(TN_BaseForm)
    Memo: TMemo;
    Timer: TTimer;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
  private
    { Private declarations }
    TestStartFromCMSMode : Boolean;
    TimeDelta : Double; // Self Time Delta for Query Check
    PrevExceptionFlag : Boolean;
    ExceptCount : Integer;
    NotFirstSessionBySyncFrame  : Boolean;
    SkipSyncLog1Flag : Boolean;
    WaitForActivationFlag : Boolean;
    WaitForActivationCount : Integer;
    procedure ShowMesDlg( const AMes : string; ADlgType : TMsgDlgType = mtWarning; const ADlgCapt : string = '' );
  public
    { Public declarations }
    CMEDDBAccess : TK_CMEDDBAccess;
//    SyncSessionCurFinTS  : TDateTime;
    StartSyncMode : Boolean;
    SyncFilesWinAPIFlag : Boolean;
    SyncCentralStorageFlag : Boolean;
    CentralStorageID : Integer;
    QueryDSet : TADOQuery; // Query Data Set
    AppSL : TStringList;
    LocPathInfoArr : TK_CMFilesAccessContextArr;

    function  UpdateSlideFiles( const AQElemID : string; ASlideID, ADstLocID,
                   ASrcLocID, AQuerySyncFlags, AHistFlags : Integer ) : Integer;
    function  PrepLocSlidesFPathContext(): TK_CMEDResult;
    procedure AddInfoLine ( const AInfo : string );
    function  CheckLocPath( APPathState : TK_CMPFSyncPathState;
                            AUCheckFlag : Boolean;
                            var AStateStr, APath : string ) : Boolean;
    function  SearchLocPathInfo( ALocID: Integer ): Integer;
    procedure OnUHException( Sender: TObject; E: Exception );

  end;

var
  K_FormCMEFSyncProc: TK_FormCMEFSyncProc;

const
  K_FSFileCurOrigFlag  = 1;   // Both Current and Original Image Files Transfer
  K_FSQueryUNCFlag     = $80; // Immediately Synchronization Query Element Flag
  K_FSCheckPathPeriod = 3/24; // Check Path period in Delphi DateTime units

  K_FSHistFileOrigFlag     = 1; // Original Image File Transfer
  K_FSHistQueryLastFlag    = 2; // Query Last File Transfer
  K_FSHistQueryFirstFlag   = 4; // Query First File Transfer
  K_FSHistTransSuccessFlag = 8; // File Transfer Success Flag
  K_FSHistTransErrorFlag  = 16; // File Transfer Errors Flag

  K_FSBuildNumber = 0;

implementation

{$R *.dfm}

uses DB, DateUtils, Math,
     N_Types, N_Lib0, N_CM1,
     K_CLib0, K_VFunc;

procedure TK_FormCMEFSyncProc.AddInfoLine ( const AInfo : string );
begin
  if Memo.Lines.Count > 1000 then
      Memo.Lines.Delete(0);
  Memo.Lines.Add( K_DateTimeToStr( CMEDDBAccess.EDAGetSyncTimestamp(),
                                   'yyyy"/"mm"/"dd"/" hh":"nn":"ss  ' ) + AInfo );
end;

//********************************************* TK_FormCMEFSyncProc.FormShow ***
// FormShow handler
//
procedure TK_FormCMEFSyncProc.FormShow(Sender: TObject);
begin
  N_Dump1Str( 'CMEFSync >> FormShow start' );
  Timer.Interval := 10;
  Timer.Enabled := TRUE; // Star Timer for Process Init
  AppSL := TStringList.Create();
  TestStartFromCMSMode := StartSyncMode;
  CentralStorageID := -1;
  N_Dump1Str( 'CMEFSync >> FormShow fin' );
end; // TK_FormCMEFSyncProc.FormShow

//********************************************* TK_FormCMEFSyncProc.TimerTimer ***
// Show dialog message
//
procedure TK_FormCMEFSyncProc.ShowMesDlg( const AMes : string; ADlgType : TMsgDlgType = mtWarning; const ADlgCapt : string = '' );
begin
  K_CMShowMessageDlg( AMes, ADlgType, [], false, ADlgCapt, 10 );
end; // TK_FormCMEFSyncProc.ShowMesDlg


//********************************************* TK_FormCMEFSyncProc.TimerTimer ***
// Files Synchronization Process Timer handler
//
procedure TK_FormCMEFSyncProc.TimerTimer(Sender: TObject);
var

//  CR : TK_CMEDResult;
  QID, QSQLText, QSQLText1 : string;
  UNCSyncFlag, BreakQueryFlag, WaitFileHandling, TimeSessionFlag : Boolean;
  QProcessCount, QSlideID, QPatID, QDstLocID, SrcLocID,
  QFlags, QSlideCount, QSlideInd, QSlideFlags, QPriority  : integer;
  QSAppGID, QSProvID : string;
  QTS, QSTS, CurTS : TDateTime;
  SSStartTS  : TDateTime;
  SSFinTS  : TDateTime;

  SavedCursor: TCursor;
  InfoPatText, InfoPatText1 : string;

  DlgType : TMsgDlgType;
  DlgCapt : string;

  TimerInterval : Integer;

  procedure DelQueryElement( const SQID : string );
  begin
    with QueryDSet do
    begin
      Delete();
      UpdateBatch;
    end;
  end;

  procedure SetSQLForAllQueryUnload( );
  begin
    QSQLText := 'select ' + // SQL text for all ready to Sync by time
        K_CMENDBSFQElemID   + ',' + K_CMENDBSFQFlags + ',' +
        K_CMENDBSFQPatID    + ',' + K_CMENDBSFQSlideID + ',' +
        K_CMENDBSFQDstLocID + ',' + K_CMENDBSFQTS + ',' +
        K_CMENDBSFQSTS      + ',' + K_CMENDBSFQAppGID + ',' +
        K_CMENDBSFQProvID   + ',' + K_CMENDBSFQPriority +
        ' from ' + K_CMENDBSyncFilesQueryTable;
  end;

  procedure DumpCurQueryElemAttrs( );
  var
    SrcGID, Ind : Integer;
    SSrcGID : string;
    SrcName : string;
  begin
    with CMEDDBAccess, QueryDSet do
    begin
      SrcGID := FieldList[7].AsInteger;
      Ind := AppSL.IndexOfObject( TObject(SrcGID) );
      if Ind >= 0 then
        SrcName := AppSL[Ind]
      else
      begin
        if SrcGID = -1 then
          SrcName := 'D4W'
        else
          with CurDSet1 do begin
            ExtDataErrorCode := K_eeDBSelect;
            Connection := LANDBConnection;
            SSrcGID := IntToStr( SrcGID );
            SQL.Text := 'select ' +
              K_CMENDBGAInstsTFGlobID + ',' +
              K_CMENDBGAInstsTFCName +
              ' from ' + K_CMENDBGAInstsTable +
              ' where ' + K_CMENDBGAInstsTFGlobID + '=' + IntToStr( SrcGID );
            Open;
            if RecordCount = 0 then
              SrcName := 'AppID=' + SSrcGID
            else
              SrcName := K_CMEDAGetDBStringValue(FieldList[1]);
//              SrcName := N_AnsiToString(FieldList[1].AsString);
//                EDAGetStringFieldValue(FieldList[1]);
            Close;
          end;
        AppSL.AddObject( SrcName, TObject(SrcGID) );
      end;
      N_Dump1Str(
            format( 'CMEFSync >> QuElem Start QuSrc=%s QuID=%s QuSetTime=%s QuPatID=%d QuSlideID=%d QuFlags=%d DstLocID=%d',
            [SrcName, QID, K_DateTimeToStr( TDateTimeField(FieldList[6]).Value ),
             QPatID,QSlideID,QFlags,QDstLocID] ) );
    end;
  end;

  function SyncCurSlide( AHistFlags : Integer ) : Integer;
  var
    UpdateRes : Integer;
  begin
    SrcLocID := -1;
    if (CentralStorageID <> -1) and
       (QDstLocID <> CentralStorageID) then
    begin // Sync to Central Storage
      SkipSyncLog1Flag := TRUE;
      UpdateRes := UpdateSlideFiles( QID, QSlideID, CentralStorageID, -1, QFlags, AHistFlags and not K_FSHistQueryLastFlag );
      SkipSyncLog1Flag := FALSE;
      if UpdateRes < 0 then
      begin
        Result := UpdateRes;
        Exit; // Slide is deleted
      end;
      if UpdateRes > 0 then
        AHistFlags := AHistFlags and not K_FSHistQueryFirstFlag;
      SrcLocID := CentralStorageID;
    end;

    Result := UpdateSlideFiles( QID, QSlideID, QDstLocID, SrcLocID, QFlags, AHistFlags );
  end;

  procedure AddQueryHist(  );
  begin
    with CMEDDBAccess.CurSQLCommand1 do
    begin
      QSQLText := '';
      QSQLText1 := '';
      if QTS > 0 then
      begin
//        QSQLText := 'DATETIME(''' + K_DateTimeToStr( QTS, 'yyyy-mm-dd hh:nn:ss.zzz' ) +  ''')';
        QSQLText := CMEDDBAccess.EDADBDateTimeToSQL( QTS );
        QSQLText1 := ',' + K_CMENDBSFQHTS
      end;
      CommandText := 'BEGIN' + Chr($0A) +
         'IF NOT EXISTS (SELECT 1 FROM '+ K_CMENDBSyncFilesQueryHistTable +
         ' WHERE ' + K_CMENDBSFQHElemID + ' = ' + QID + ') THEN ' + Chr($0A) +
         'INSERT INTO ' + K_CMENDBSyncFilesQueryHistTable +
         ' (' + K_CMENDBSFQHElemID + ',' +
                K_CMENDBSFQHFlags + ',' +
                K_CMENDBSFQHPatID  + ',' +
                K_CMENDBSFQHSlideID + ',' +
                K_CMENDBSFQHDstLocID + ',' +
                K_CMENDBSFQHPriority + ',' +
                K_CMENDBSFQHAppGID + ',' +
                K_CMENDBSFQHProvID + ',' +
                K_CMENDBSFQHSTS +
                QSQLText1 +
         ' ) VALUES ( '+
            QID + ',' +
            IntToStr(QFlags) + ',' +
            IntToStr(QPatID) + ',' +
            IntToStr(QSlideID) + ',' +
            IntToStr(QDstLocID) + ',' +
            IntToStr(QPriority) + ',' +
            QSAppGID + ',' +
            QSProvID + ',' +
            CMEDDBAccess.EDADBDateTimeToSQL( QSTS ) + ',' +
//            'DATETIME(''' + K_DateTimeToStr( QSTS, 'yyyy-mm-dd hh:nn:ss.zzz' ) + '''),' +
            QSQLText + ' ) ' + Chr($0A) +
            'END IF; END;';
//      N_s := CommandText;
      Execute;
    end;
  end;

  function CheckConnectionResult( ) : TK_CMEDResult;
  begin
    with CMEDDBAccess do begin
//      AppLocalID := K_CMFilesSyncProcAppLocalID;
      Result := EDACheckDBConnection(LANDBConnection);
      if Result = K_edOK then
        Result := EDAAppActivate();
      if Result <> K_edOK then
      begin
        if Result = K_edEFSyncProcStarted then
        begin
          WaitForActivationFlag := TRUE;
          Inc(WaitForActivationCount);
          if WaitForActivationCount < 10 then
          begin
            N_Dump1Str( 'CMEFSync >> Wait for closing active CMEFSync on Comp=' + AResStr1 );
            Timer.Interval := Max( Round( AResInt1 / 1.5), 10000 ); // Set Work Timer Step in msec
            Timer.Enabled := TRUE;
            Exit;
          end;
          ShowMesDlg( 'CMS Files Synchronization Process is already launched on computer' + AResStr1 + '.'#13#10 +
                      '                 This Instance will be closed', mtError )
//            K_CMShowMessageDlg( 'CMS Enterprise Files Synchronization Process is already started', mtWarning)
        end
        else
        begin
          DlgType := mtWarning;
          DlgCapt := '';
          if K_CMSAppStartContext.CMASState = K_cmasStop then
          begin
            DlgType := mtError;
            DlgCapt := 'CMS versions mismatch';
          end;
          if K_CMSLiRegWarning = '' then
            K_CMSLiRegWarning := 'CMEFSync: unknown CMS Database connetion error';
//            K_CMShowMessageDlg(K_CMSLiRegWarning, DlgType, [], FALSE, DlgCapt );
          ShowMesDlg( K_CMSLiRegWarning, DlgType, DlgCapt );
        end;
        Close();
        Exit;
      end;
      if not K_CMEnterpriseModeFlag then
      begin
//          K_CMShowMessageDlg( 'CMS Database is not in Enterprise mode', mtWarning);
        ShowMesDlg( 'CMS Database is not in Enterprise mode' );
        Close();
      end;
    end; // end of with CMEDDBAccess do begin
  end;

begin
  Timer.Enabled := FALSE;
  if ExceptCount < 3 then
    TimerInterval := 60000
//    TimerInterval := 10000
  else
  if ExceptCount < 6 then
    TimerInterval := 300000
  else
    TimerInterval := 3600000;

  Timer.Interval := TimerInterval; // Set Work Timer Step in msec
  TimeSessionFlag := FALSE;
  SavedCursor := Screen.Cursor;
  try


    if CMEDDBAccess = nil then
    begin // Process Initialization
      if not PrevExceptionFlag then
      N_Dump1Str( format( 'CMEFSync >> Process Start Ver=%.2d.%.3d.%.2d', [N_CMVerNumber, N_CMBuildNumber,K_FSBuildNumber] ) );
      PrevExceptionFlag := FALSE;
      CMEDDBAccess := TK_CMEDDBAccess.Create;
      AddInfoLine ( 'CMS Enterprise Files Synchronization Process Start' );
      WaitForActivationFlag := FALSE;
      WaitForActivationCount := 0;
      if K_edOK <> CheckConnectionResult( ) then Exit;

      // Activate Locations File Access Cotext
  //    PrepLocSlidesFPathContext();
    end; // end of if CMEDDBAccess = nil then

    if WaitForActivationFlag  then
    begin
      if K_edOK <> CheckConnectionResult( ) then Exit;
    end;

    WaitForActivationFlag := FALSE;
    WaitForActivationCount := 0;

    if QueryDSet = nil then
    begin
      TimeDelta := 60000 / (1000 * 3600 * 24);
      QueryDSet := TADOQuery.Create(Application); // Current Slides Data Set for request to LocFilesInfo Table
    end;

    // Get Sync Timetable
    with CMEDDBAccess do
    begin
      EDAEMGetFSyncSessionAttrs();

      // Build Current Sync Window
      CurTS := EDAEMGetFSyncSessionTime( SSStartTS, SSFinTS );
      EDAEMDumpSFSyncSessionAttrs( ' CMEFSync (cur) ' );
      UNCSyncFlag := StartSyncMode;
      if not StartSyncMode then
      begin // Wait for Sync Mode - not immediately start

        // Check Timetable
        if (SSFinTS = SSStartTS)                           // Fin Time = Start Time
                     or
           (CurTS < SSStartTS)                             // Cur Time is before Fin Time
                     or
           ( (CurTS > SSFinTS) and                         // Cur Time is after Fin Time
             ( NotFirstSessionBySyncFrame or               // not 1-st session by time frame
               (CurTS > SSStartTS + 3 * TimeDelta) ) ) then// Cur Time is not far from Start Time
        begin
        // Start unconditional query files transfer session immediately
          QSQLText := 'select ' + // SQL text for unconditional Sync
              K_CMENDBSFQElemID   + ',' + K_CMENDBSFQFlags + ',' +
              K_CMENDBSFQPatID    + ',' + K_CMENDBSFQSlideID + ',' +
              K_CMENDBSFQDstLocID + ',' + K_CMENDBSFQTS + ',' +
              K_CMENDBSFQSTS      + ',' + K_CMENDBSFQAppGID + ',' +
              K_CMENDBSFQProvID   + ',' + K_CMENDBSFQPriority +
              ' from ' + K_CMENDBSyncFilesQueryTable +
              ' where (' + K_CMENDBSFQFlags + ' & 0x80) <> 0';
          UNCSyncFlag := TRUE;
          if CurTS > SSStartTS + 3 * TimeDelta then
            NotFirstSessionBySyncFrame := FALSE;
          AddInfoLine ( 'Start files transfer session for unconditinal query elements only' );
        end
        else
        begin
          if CurTS > SSFinTS then
          // Enlarge Syncronization window if start is later then Fin Time
            SSFinTS := CurTS + 3 * TimeDelta;

         // Start all query files transfer session by timetable
          SetSQLForAllQueryUnload( );
          TimeSessionFlag := TRUE;
          NotFirstSessionBySyncFrame := TRUE;
          AddInfoLine ( 'Start files transfer session for all query elements by timetable' );
        end;
      end
      else
      begin
      // Start All files transfer session for query elements immediately
        SetSQLForAllQueryUnload( );
        AddInfoLine ( 'Start files transfer session for all query elements immediately' );
      end; // end of if not StartSyncMode then

    /////////////////////////////////////
    // Files Synchronization
    //
      QProcessCount := 0;
      WaitFileHandling := FALSE;
      BreakQueryFlag := FALSE;
      Screen.Cursor := crHourGlass;
      SyncCentralStorageFlag := (SyncSessionFlags and 1) <> 0;
      SyncFilesWinAPIFlag:= (SyncSessionFlags and 2) <> 0;
      with QueryDSet do
      begin
        ExtDataErrorCode := K_eeDBSelect;
        Connection := LANDBConnection;
        SQL.Text := QSQLText;
        Filtered := false;
        Open;
        if RecordCount > 0 then
        begin
        // Activate Locations File Access Cotext
          PrepLocSlidesFPathContext();
          First;
          while not Eof do
          begin
            Application.ProcessMessages();

            if QProcessCount = 0 then
              N_Dump1Str( 'CMEFSync >> Session Start WinAPI=' + IntToStr(Byte(SyncFilesWinAPIFlag)) );

            QID := FieldList.Fields[0].AsString;
            QFlags := FieldList.Fields[1].AsInteger;
            QPatID := FieldList.Fields[2].AsInteger;
            QSlideID := FieldList.Fields[3].AsInteger;
            QDstLocID := FieldList.Fields[4].AsInteger;
            QTS  := TDateTimeField(FieldList[5]).Value;
            QSTS := TDateTimeField(FieldList[6]).Value;
            QSAppGID := FieldList.Fields[7].AsString;
            QSProvID := FieldList.Fields[8].AsString;
            QPriority := FieldList.Fields[9].AsInteger;
            if not UNCSyncFlag  then
            begin
              // Check if Session Time Window is finished
              if EDAGetSyncTimestamp() > SSFinTS  then
              begin
                BreakQueryFlag := TRUE;
                AddInfoLine ( 'Session is broken by time elapse' );
                N_Dump1Str( 'CMEFSync >> Session is broken' );
                break; // Sync Window is Finished
              end;

              // Check if Query Element Start Time is out of Session Time Window
              if QTS > SSFinTS then
              begin
                Next();
                Continue;
              end;
            end;

            // Check Files Handling Activity
            if K_CMEDDBVersion >= 13 then
              with CurDSet1 do
              begin
                SQL.Text := 'select cms_LockSlideEFSync(1)';
                Filtered := FALSE;
                Open;
                WaitFileHandling := FieldList.Fields[0].AsInteger = 0;
                CLose;
                if WaitFileHandling then
                begin
                  AddInfoLine ( 'Session is broken by files handling' );
                  N_Dump1Str( 'CMEFSync >> Session is broken by files handling' );
                  break; // Sync Window is broken
                end;
              end;


            DumpCurQueryElemAttrs( );


            if QSlideID <> 0 then begin
            //////////////////////////////
            // Sync Slide Query
            //
              if K_CMEDDBVersion >= 12 then
                AddQueryHist( );
              InfoPatText := format( ' files transfer for Slide ID=%d to Location ID=%d', [QSlideID,QDstLocID] );
              SyncCurSlide( K_FSHistQueryLastFlag or K_FSHistQueryFirstFlag );
              DelQueryElement( QID );
              N_Dump1Str( 'CMEFSync >> QuElem Finish' );
            //
            // Sync Slide Query
            //////////////////////////////
            end
            else
            begin
            //////////////////////////////
            // Sync Patient Query
            //
              InfoPatText := format ( 'Files transfer for Patient ID=%d to Location ID=%d', [QPatID,QDstLocID] );
              AddInfoLine ( 'Start' + InfoPatText );
              with CurDSet2 do
              begin
                ExtDataErrorCode := K_eeDBSelect;
                Connection := LANDBConnection;
                // Select Patient Slides to Synchronize
                SQL.Text := 'select S.' +  K_CMENDBSTFSlideID +
                ' from ( select '  + K_CMENDBSTFSlideID + ', ' + K_CMENDBSTFSlideDTImg +
                         ' from '  + K_CMENDBSlidesTable +
                         ' where ' + K_CMENDBSTFPatID + ' = ' + IntToStr(QPatID) +
                         ' and (' + K_CMENDBSTFSlideFlags + '<> 2' + ' or ' + K_CMENDBSTFSlideFlags + ' IS NULL) ) S' +
                ' left outer join ' +
                      '( select '  + K_CMENDBLFILocSlideID + ', ' + K_CMENDBLFILocSlideTS +
                         ' from '  + K_CMENDBLocFilesInfoTable +
                         ' where ' + K_CMENDBLFILocID + ' = ' + IntToStr(QDstLocID) +' ) Q' +
                ' on S.' + K_CMENDBSTFSlideID + ' = Q.' + K_CMENDBLFILocSlideID +
                ' where Q.' + K_CMENDBLFILocSlideTS + ' is null' +
                ' or    Q.' + K_CMENDBLFILocSlideTS + ' < S.' + K_CMENDBSTFSlideDTImg;
      //              N_s := SQL.Text;
                Filtered := false;
                Open;
                QSlideCount := RecordCount - 1;
                if (K_CMEDDBVersion >= 12) and
                   (QSlideCount >= 0) then // Query Element to History if it has not Syncronized Slides  
                  AddQueryHist( );
                QSlideInd := 0;
                QSlideFlags := K_FSHistQueryFirstFlag;
                First;
                BreakQueryFlag := FALSE;
                while not Eof do
                begin
                //////////////////////////////
                // Sync Patient Slide
                //
                  if not UNCSyncFlag and
                     (EDAGetSyncTimestamp() > SSFinTS) then
                  begin
                    AddInfoLine ( 'Session is broken by time elapse' );
                    BreakQueryFlag := TRUE;
                    break; // Sync Time Window is Finished by Session Time Window
                  end;

                  // Check Files Handling Activity
                  if K_CMEDDBVersion >= 13 then
                    with CurDSet1 do
                    begin
                      SQL.Text := 'select cms_LockSlideEFSync(1)';
                      Filtered := FALSE;
                      Open;
                      WaitFileHandling := FieldList.Fields[0].AsInteger = 0;
                      CLose;
                      if WaitFileHandling then
                      begin
                        AddInfoLine ( 'Session is broken by files handling' );
                        N_Dump1Str( 'CMEFSync >> Session is broken by files handling' );
                        break; // Sync Window is broken
                      end;
                    end;

                  QSlideID := FieldList.Fields[0].AsInteger;
                  if QSlideInd = QSlideCount then
                    QSlideFlags := QSlideFlags or K_FSHistQueryLastFlag;
                  SyncCurSlide( QSlideFlags );
                  InfoPatText := format( 'Files transfer for Slide ID=%d to Location ID=%d', [QSlideID,QDstLocID] );
                  Next;
                  QSlideFlags := 0;
                  Inc(QSlideInd);

                //
                // Sync Patient Slide
                //////////////////////////////
                end; // end of while not Eof do
                Close();
                InfoPatText1 := ' is broken';
                if not BreakQueryFlag then
                begin
                  DelQueryElement( QID );
                  InfoPatText1 := ' is finished';
                end;
                AddInfoLine ( InfoPatText + InfoPatText1 );
                N_Dump1Str( 'CMEFSync >> QuElem ' + InfoPatText1 );

                if BreakQueryFlag then break;

              end; // end of with CurDSet2 do
            //
            // Sync Patient Query
            //////////////////////////////
            end; // end of Patient Slides Querry
          end; // end of while not EOF
        end; // end of If RecordCont > 0
        Close();
      end; // end of with QueryDSet do

      AddInfoLine ( 'Finish files transfer session' );
      if QProcessCount <> 0 then
        N_Dump1Str( 'CMEFSync >> Session is finished' );

//      if (CentralStorageID = -1) or
//         (QProcessCount = 0) then
//        PrepLocSlidesFPathContext();

      if SyncCentralStorageFlag  and  // Compulsary Sync to Central Storage is needed
         not WaitFileHandling    and  // Files Handling is not in process
         TimeSessionFlag         and  // Sync Session was started by Timetable and was just finished
         not BreakQueryFlag then      // Just finished Session was not break
      begin
      //////////////////////////////
      // Central File Storage Sync
      //
      // Start HeadOffice Sync Session for all unsynchronized files after Timetable Session
        if QProcessCount = 0 then
          PrepLocSlidesFPathContext();

        if (CentralStorageID <> -1) then
        begin // Central Storage Exists

          AddInfoLine ( 'Start files transfer session for Central files storage' );
          with QueryDSet do
          begin
            Connection := LANDBConnection;
            SQL.Text := 'select S.' +  K_CMENDBSTFSlideID +
            ' from ( select '  + K_CMENDBSTFSlideID + ', ' + K_CMENDBSTFSlideDTImg +
                     ' from '  + K_CMENDBSlidesTable +
                     ' where ' + K_CMENDBSTFSlideFlags + '<> 2' + ' or ' + K_CMENDBSTFSlideFlags + ' IS NULL ) S ' +
            ' left outer join ' +
                  '( select '  + K_CMENDBLFILocSlideID + ', ' + K_CMENDBLFILocSlideTS +
                     ' from '  + K_CMENDBLocFilesInfoTable +
                     ' where ' + K_CMENDBLFILocID + ' = ' + IntToStr(CentralStorageID) + ' ) Q' +
            ' on S.' + K_CMENDBSTFSlideID + ' = Q.' + K_CMENDBLFILocSlideID +
            ' where  Q.' + K_CMENDBLFILocSlideTS + ' is null' +
            ' or     Q.' + K_CMENDBLFILocSlideTS + ' < S.' + K_CMENDBSTFSlideDTImg;
            Filtered := FALSE;

            Open;

      //      BreakQueryFlag := FALSE;
            QSlideCount := RecordCount;
            if QSlideCount > 0 then
            begin
              if K_CMEDDBVersion >= 12 then
              begin
              // Add New Query Element to get Uniq QElemID
                with CurDSet1 do
                begin
                  Connection := LANDBConnection;
                  SQL.Text := 'BEGIN ' + Chr($0A) +
                    'INSERT INTO ' + K_CMENDBSyncFilesQueryTable +
                    ' ('+K_CMENDBSFQFlags+','+ K_CMENDBSFQDstLocID +
                    ') VALUES (1,'+IntToStr(CentralStorageID)+');'  + Chr($0A) +
                    'select @@identity;' + Chr($0A) +
                    'END;';
  { // Error to check exception
                  SQL.Text := 'BEGIN ' + Chr($0A) +
                    'INSERT INTO ' + K_CMENDBSyncFilesQueryTable + ' VALUES (DEFAULT);'  + Chr($0A) +
                    'select @@identity;' + Chr($0A) +
                    'END;';
  {}
                  Filtered := false;
                  Open;
                  QID := FieldList.Fields[0].AsString;
                  Close();
                end;

              // Save Statistics for this query element
                QFlags := K_FSFileCurOrigFlag;
                QPatID := 0;
                QSlideID := -1;
                QDstLocID := CentralStorageID;
                QTS  := 0;
                QSTS := Now();
                QSAppGID := IntToStr(ClientAppGlobID);
                QSProvID := '-2';
                QPriority := 0;
                AddQueryHist( );

              // Delete this Query Elevent
                with CurSQLCommand1 do
                begin
                  CommandText := 'DELETE FROM ' + K_CMENDBSyncFilesQueryTable + ' WHERE ' +
                                 K_CMENDBSFQElemID + ' = ' + QID;
                  Execute;
                end;
              end
            end; // end of if QSlideCount > 0 then

            QSlideInd := 0;
            QSlideFlags := K_FSHistQueryFirstFlag;
            First;
            while not Eof do
            begin
              Application.ProcessMessages();
              if QSlideInd = 0 then
                N_Dump1Str( 'CMEFSync >> Session for Central Storage is started WinAPI=' + IntToStr(Byte(SyncFilesWinAPIFlag)) );

              if (EDAGetSyncTimestamp() > SSFinTS) then
              begin
      //          BreakQueryFlag := TRUE;
                AddInfoLine ( 'Session is broken by time elapse' );
                N_Dump1Str( 'CMEFSync >> Session is broken' );
                break; // Sync Window is Finished
              end;

              if K_CMEDDBVersion >= 13 then
                with CurDSet1 do
                begin
                  SQL.Text := 'select cms_LockSlideEFSync(1)';
                  Filtered := FALSE;
                  Open;
                  WaitFileHandling := FieldList.Fields[0].AsInteger = 0;
                  CLose;
                  if WaitFileHandling then
                  begin
                    AddInfoLine ( 'Session is broken by files handling' );
                    N_Dump1Str( 'CMEFSync >> Session is broken by files handling' );
                    break; // Sync Window is broken
                  end;
                end;



              QSlideID := FieldList.Fields[0].AsInteger;
              if QSlideInd = QSlideCount - 1 then
                QSlideFlags := QSlideFlags or K_FSHistQueryLastFlag;
              UpdateSlideFiles( QID, QSlideID, CentralStorageID, -1, 1, QSlideFlags ); // Sync Cur Image and Src Image
              Inc(QSlideInd);
              Next;
            end; // end of while not Eof do
            Close;
          end; // end of with QueryDSet do

          if QSlideInd <> 0 then
            N_Dump1Str( 'CMEFSync >> Session is finished' );
          AddInfoLine ( 'Finish files transfer session for Central files storage' );

        end // if (CentralStorageID <> -1) then
        else // Central Storage is not set
          N_Dump1Str( 'CMEFSync >> Session for Central Storage is not started: no Central Storage' );

      //
      // Central File Storage Sync
      //////////////////////////////
      end
      else
      begin
        QSQLText1 := '';
        if WaitFileHandling then
          QSQLText1 := ' |FilesHandling in process';
        if  not SyncCentralStorageFlag then
          QSQLText1 := QSQLText1 + ' |no Compulsary Flag';
        if not TimeSessionFlag then
          QSQLText1 := QSQLText1 + ' |out of Session time window';
        if BreakQueryFlag then
          QSQLText1 := QSQLText1 + ' |current Query unload was broken';
        N_Dump1Str( format( 'CMEFSync >> Session for Central Storage is not started:%s', [QSQLText1] ) );
      end; // end of Central Location Sync is needed


      // Clear Copy Files State
      if K_CMEDDBVersion >= 13 then
        with CurDSet1 do
        begin
          SQL.Text := 'select cms_LockSlideEFSync(0)';
          Filtered := FALSE;
          Open;
          CLose;
        end;

    end; // end of with CMEDDBAccess do
  //
  // Files Synchronization
  /////////////////////////////////////
    ExceptCount   := 0;
  except
    on E: Exception do begin
      N_Dump1Str( 'CMEFSync >> Exception >> ' + E.Message );
      AddInfoLine ( 'Files transfer Exception ' + E.Message );
      PrevExceptionFlag := TRUE;
      FreeAndNil( CMEDDBAccess );
      FreeAndNil( QueryDSet );
      Inc(ExceptCount);
    end;
  end;
  Screen.Cursor := SavedCursor;
  StartSyncMode := FALSE;
  Timer.Enabled := TRUE;
end; // TK_FormCMEFSyncProc.TimerTimer

//********************************************* TK_FormCMEFSyncProc.UpdateSlideFiles ***
// Update Slide Files
//
//     Parameters
// AQElemID     - Query Element ID
// ASlideID     - Slide ID
// ADstLocID    - Destination Location ID
// ASyncSrcFile - Synchronize Original Image File Flag
// AChangeHLocFlag - change Slide Host Location Flag
// AHistFlags      - Transfer History Flags
// Result - Returns copied files size in Kbytes
//
function TK_FormCMEFSyncProc.UpdateSlideFiles( const AQElemID : string;
                                               ASlideID, ADstLocID, ASrcLocID,
                                               AQuerySyncFlags, AHistFlags : Integer ): Integer;
var
  SSlideID : string;
//  SSrcLocID : string;
  SDstLocID, SSrcLocID, SSrcLocID1  : string;
//  SrcFC, DstFC : TK_CMFilesAccessContext; // Source and Destination Files Context
  PSrcFC, PDstFC : TK_CMPFilesAccessContext;
  DstSyncFlags : Integer; // 1 - Sync CurImg, 2 Sync SrcImg, 4 - add LocFilesInfo
  NewLocSlideFlags, DstLocSlideFlags : Integer;
  SDBF: TN_CMSlideSDBF;
  PatID, CurFSize, SrcFSize, TDelta, WHistFlags : Integer;
  DTCr, DTImg, DstDTFile, WDT : TDateTime;
  CurFName, SrcFName, PathSegm, CopyInfo, PathInfo,
  FilesInfo, DstFPath, SrcFPath, APIInfo, ResInfo : string;
  SQLStr : string;
  SStartTS : string;
  CheckLocMes : string;
  CopySrcImgFlag, ActDone : Boolean;
  PSFS : TK_CMPFSyncPathState;

label AbsPathContext, ErrPathContext, FinTransfer;

  procedure GetFC1( SLocID : string; out PFC : TK_CMPFilesAccessContext );
  var
    LInd : Integer;
    ILocID : Integer;
  begin
    PFC := nil;
    ILocID := StrToInt(SLocID);
    LInd := SearchLocPathInfo( ILocID );
    if LInd < 0 then Exit;
    PFC := @LocPathInfoArr[LInd];
  end;

  function GetFilePathContext( PFC : TK_CMPFilesAccessContext ) : Boolean;
  begin
    with PFC^, SDBF do
    begin
      Result := (cmsfIsMediaObj in SFlags);
      MediaObjFlag := Result;
      if not Result then
      begin
        FilePath := ImgRootState.SPSEFolder;
        if FilePath = '' then
          FilePath := ImgRootState.SPSFolder;
        FDA := ImgRootState.SPSFDA;
        FileName := K_CMSlideGetCurImgFileName( SSlideID );
        PSFS := @PSrcFC.ImgRootState;
      end
      else
      begin
        FilePath := MediaRootState.SPSEFolder;
        if FilePath = '' then
          FilePath := MediaRootState.SPSFolder;
        FDA := MediaRootState.SPSFDA;
        FileName := K_CMSlideGetMediaFileNamePref(SSlideID) + MediaFExt;
        PSFS := @PSrcFC.MediaRootState;
      end;
      Result := not PSFS.SPSExistFlag or
                not PSFS.SPSWriteFlag or
               (PSFS.SPSSpace = 0);
      Result := CheckLocPath( PSFS, Result, CheckLocMes, FilePath );
    end;
  end;

  procedure CheckFilePathContext( PFC : TK_CMPFilesAccessContext;
                                  ASLocID, AInfo : string );
  var
    CheckPathFlag : Boolean;
  begin
    with PFC^ do
    begin
      if not MediaObjFlag then
//        PSFS := @PSrcFC.ImgRootState
        PSFS := @ImgRootState
      else
//        PSFS := @PSrcFC.MediaRootState;
        PSFS := @MediaRootState;
      CheckPathFlag := CheckLocPath( PSFS, TRUE, CheckLocMes, FilePath );
  //    AInfo := format( '%s Location ID=%s folder "%s"',
  //                            [AInfo, SDstLocID, PDstFC.FilePath] );
      AInfo := format( '%s Location ID=%s folder "%s"',
                              [AInfo, LocID, FilePath] );
    end;
    if not CheckPathFlag then
      AddInfoLine ( AInfo + ' access problems' );
    AddInfoLine ( CheckLocMes );
    N_Dump1Str( 'CMEFSync >> ' + AInfo + ' >> ' + CheckLocMes );
  end;

  procedure AddHistRecord( AHFlags, AFSize : Integer; const ASSrcLocID : string );
  begin
    WDT := CMEDDBAccess.EDAGetSyncTimestamp();
//    SStartTS := K_DateTimeToStr( Int( WDT ) + Round( Frac(WDT) * 24*36000 ) / (24 * 36000), 'yyyy-mm-dd hh:nn:ss.zzz' );
    SStartTS := CMEDDBAccess.EDADBDateTimeToSQL( Int( WDT ) + Round( Frac(WDT) * 24*36000 ) / (24 * 36000) );
    with CMEDDBAccess.CurSQLCommand1 do
    begin
      CommandText := 'INSERT INTO ' + K_CMENDBSyncFilesHistTable +
         ' (' + K_CMENDBSFHQElemID + ',' +
                K_CMENDBSFHSlideID + ',' +
                K_CMENDBSFHDstLocID + ',' +
                K_CMENDBSFHSrcLocID + ',' +
                K_CMENDBSFHFlags + ',' +
                K_CMENDBSFHFSize + ',' +
                K_CMENDBSFHSTS +
         ' ) VALUES ( '+
            AQElemID + ',' +
            SSlideID + ',' +
            SDstLocID + ',' +
            ASSrcLocID + ',' +
            IntToStr(AHFlags) + ','+
            IntToStr(AFSize) + ',' +
            SStartTS +
//            'DATETIME(''' + SStartTS + ''')' +
         ' );';
//      N_s := CommandText;
      Execute;
    end;
  end;

  procedure UpdateHistRecord( AFlags : Integer );
  begin
    TDelta := Round( (CMEDDBAccess.EDAGetSyncTimestamp() - WDT) * 24*3600 * 1000 );
    with CMEDDBAccess.CurSQLCommand1 do
    begin
      CommandText := 'UPDATE ' + K_CMENDBSyncFilesHistTable + ' SET ' +
         K_CMENDBSFHFTMSec + ' = ' + IntToStr(TDelta) + ',' +
         K_CMENDBSFHFlags  + ' = ' + IntToStr(AFlags) +
         ' WHERE ' +
         K_CMENDBSFHQElemID + ' = ' + AQElemID + ' AND ' +
         K_CMENDBSFHSlideID + ' = ' + SSlideID + ' AND ' +
         K_CMENDBSFHSTS     + ' = ' + SStartTS + ');';
//         K_CMENDBSFHSTS     + ' = ' + 'DATETIME(''' + SStartTS + ''');';
//      N_s := CommandText;
      Execute;
    end;
  end;

begin
  Result := 0;
  SSlideID := IntTostr(ASlideID);
  SDstLocID := IntTostr(ADstLocID);

  N_Dump2Str( format( 'CMEFSync >> Start File SlidID=%s DLocID=%s SLocID=%d', [SSlideID,SDstLocID,ASrcLocID] ) );
  try
    with CMEDDBAccess, CurSlidesDSet do
    begin
      ExtDataErrorCode := K_eeDBSelect;
      Connection := LANDBConnection;
      EDAWaitForCurSlideRWLock( SSlideID, K_cmlfRead );

    ////////////////////////////////////////////
    // Check Slide File State on DstLoc
    //
    //                      0                1         2           3           4          5
      SQL.Text := 'select I.LocID as RLocID, I.SlideID, I.FileTS, I.FileFlags, S.ImgCrTS, S.ImgChngTS ' +
            ' from (select ' +
             K_CMENDBLFILocID + ' as LocID,' +
             K_CMENDBLFILocSlideID + ' as SlideID,' +
             K_CMENDBLFILocSlideTS + ' as FileTS,' +
             K_CMENDBLFILocSlideFlags + ' as FileFlags' +
             ' from '  + K_CMENDBLocFilesInfoTable +
             ' where ' + K_CMENDBLFILocSlideID + '=' + SSlideID +
             ') I left outer join (select ' +
             K_CMENDBSTFSlideID    + ' as SlideID,' +
             K_CMENDBSTFSlideDTCr  + ' as ImgCrTS,' +
             K_CMENDBSTFSlideDTImg + ' as ImgChngTS' +
//             K_CMENDBSTFSlideFlags + ' as SlideDDFlag' +
             ' from ' + K_CMENDBSlidesTable +
             ' where ' + K_CMENDBSTFSlideFlags + '<> 2' + ' or ' + K_CMENDBSTFSlideFlags + ' IS NULL' +
             ') S  on I.SlideID = S.SlideID';

//      N_s := SQL.Text;
      Filtered := FALSE;
      Open;
  //    N_i := RecordCount;
      // Check Slide Existance
//      if (RecordCount = 0) or
//         ((FieldList.Fields[6].AsInteger and 2) <> 0) then
      if RecordCount = 0 then
      begin
        Close;
        Result := -1;
        CopyInfo := format( 'Object ID=%s transfered to Location ID=%s was already deleted ', [SSlideID, SDstLocID] );
        AddInfoLine ( 'Warning: ' + CopyInfo );
        N_Dump1Str( 'CMEFSync >>  ' + CopyInfo );
        EDAWaitForCurSlideRWLock( SSlideID, K_cmlfFree );
        Exit;
      end;

      // Check if File State in Dst Location
      Filter := 'RLocID = ' + SDstLocID;
      Filtered := TRUE;
      DstSyncFlags := 7; // CurImg and SrcImg and Add record to LocFiles Info
      if RecordCount > 0 then
        DstSyncFlags := 3; // CurImg and SrcImg and Add record to LocFiles Info
      if (AQuerySyncFlags and K_FSFileCurOrigFlag) = 0 then
        DstSyncFlags := DstSyncFlags and not 2; // SrcImg is not needed

      DstLocSlideFlags := 0;
      DstDTFile := 0;
      if (DstSyncFlags and 4) = 0 then
      begin
      // Dst File Exist Check Details
        DstLocSlideFlags := FieldList.Fields[3].AsInteger;

        DstDTFile := TDateTimeField(FieldList.Fields[2]).Value;
        DTImg := TDateTimeField(FieldList.Fields[5]).Value;
        if DstDTFile = DTImg then
          DstSyncFlags := DstSyncFlags and not 1; // CurImg is not needed

        // Correct SyncFlags for Src Image
        if ((DstLocSlideFlags and 1) <> 0) or
           (TDateTimeField(FieldList.Fields[4]).Value = DTImg) then
          DstSyncFlags := DstSyncFlags and not 2; // SrcImg is not needed

      end;
      Filtered := FALSE;
      Close;

      if DstSyncFlags = 0 then
      begin // Slide is already synchronized
        EDAWaitForCurSlideRWLock( SSlideID, K_cmlfFree );
        CopyInfo := format( 'Object ID=%s is already synchronized in Location ID=%s', [SSlideID, SDstLocID] );
        if SkipSyncLog1Flag then
          CopyInfo := ' !!CS >> ' + CopyInfo
        else
          AddInfoLine ( 'Warning: ' + CopyInfo );
        N_Dump1Str( 'CMEFSync >>  ' + CopyInfo );
        Exit;
      end;

    //
    // Check Slide File State on DstLoc
    ////////////////////////////////////////////

    ////////////////////////////////////////////
    // Get Slide Needed Attributes
    //
      ResInfo := 'fails';
      SQLStr :=
            K_CMENDBSTFPatID + ',' +        // 0
            K_CMENDBSTFSlideDTCr + ',' +    // 1
            K_CMENDBSTFSlideDTImg + ',' +   // 2
            K_CMENDBSTFSlideSysInfo;        // 3
      if K_CMEDDBVersion >= 12 then
        SQLStr := SQLStr + ',' +
            K_CMENDBSTFSlideCurFSize + ',' +// 4
            K_CMENDBSTFSlideSrcFSize;       // 5
      SQL.Text := 'select ' + SQLStr +
            ' from ' + K_CMENDBSlidesTable +
            ' where ' + K_CMENDBSTFSlideID + '=' + SSlideID;
      Filtered := FALSE;
      Open;

      PatID := FieldList.Fields[0].AsInteger;
      DTCr  := TDateTimeField(Fields[1]).Value;
      DTImg := TDateTimeField(Fields[2]).Value;
      K_CMEDAGetSlideSysFieldsData( K_CMEDAGetDBStringValue(Fields[3]), @SDBF );

      // Get Current and Original files size
      CurFSize := 0;
      SrcFSize := 0;
      if K_CMEDDBVersion >= 12 then
      begin
        CurFSize := FieldList.Fields[4].AsInteger;
        SrcFSize := FieldList.Fields[5].AsInteger;
      end;

      if CurFSize = 0 then
        CurFSize := Integer(SDBF.BytesSize);
      if SrcFSize = 0 then
        SrcFSize := Integer(SDBF.BytesSize);
      Close;

      if (cmsfIsMediaObj in SDBF.SFlags) or
         not (cmsfHasSrcImg in SDBF.SFlags) then
        DstSyncFlags := DstSyncFlags and not 2; // SrcImg is not needed
    //
    // Get Slide Needed Attributes
    ////////////////////////////////////////////

      NewLocSlideFlags := 0;

    ////////////////////////////////////////////
    // Prepare Src Location AllLocFilesInfo Record
    //
      SQL.Text := 'select ' +
            K_CMENDBLFILocID + ',' +       // 0
            K_CMENDBLFILocSlideID + ',' +  // 1
            K_CMENDBLFILocSlideTS + ',' +  // 2
            K_CMENDBLFILocSlideFlags +     // 3
            ' from ' + K_CMENDBLocFilesInfoTable +
            ' where ' + K_CMENDBLFILocSlideID + '=' + SSlideID;
      Filtered := FALSE;
      Open();
      SSrcLocID1 := '';
      SSrcLocID := '';
      if ASrcLocID <> -1 then
      begin // Use given SrcLoc
        SSrcLocID := IntToStr(ASrcLocID);
        SSrcLocID1 := SSrcLocID;
      end
      else
      begin
      // Search SrcLocs for Current and Original Images
        First();
        while not EOF do
        begin
        // Search for proper source
          if DTImg = TDateTimeField(FieldList.Fields[2]).Value then
            SSrcLocID := FieldList.Fields[0].AsString; // Source for Current
          if (FieldList.Fields[3].AsInteger and 1) <> 0 then
            SSrcLocID1 := FieldList.Fields[0].AsString; // Source for Original
          Next;
        end;
      end;
//      N_Dump2Str( format( 'CMEFSync >> SrcLocIDs Cur=%s Orig=%s, [SSrcLocID,SSrcLocID1] ) );

    ////////////////////////////////////////////
    // Check Src and Dst Paths contexts
    //
      GetFC1( SSrcLocID, PSrcFC );
      if PSrcFC = nil then
      begin
        CopyInfo  := 'Source Location ID=' + SSrcLocID + ' path context is absent';
AbsPathContext:
        Close;
        EDAWaitForCurSlideRWLock( SSlideID, K_cmlfFree );
        raise Exception.Create( CopyInfo );
      end;

//PSrcFC.ImgRootState.SPSExistFlag := FALSE;
//GetFilePathContext( PSrcFC );
      if not GetFilePathContext( PSrcFC ) then
      begin
      // Check
        CopyInfo  := format( 'Source Location ID=%s folder "%s"',
                                    [SSrcLocID, PSrcFC.FilePath] );
ErrPathContext:
        N_Dump1Str( 'CMEFSync >> ' + CopyInfo + ' >> ' + CheckLocMes );
        AddInfoLine ( CopyInfo + ' access problems' );
        AddInfoLine ( CheckLocMes );
        Result := -3;
        goto FinTransfer;
      end;

      GetFC1( SDstLocID, PDstFC );
      if PDstFC = nil then
      begin
        CopyInfo  := 'Destination Location ID=' + SDstLocID + ' path context is absent';
        goto AbsPathContext;
      end;
      if not GetFilePathContext( PDstFC ) then
      begin
        CopyInfo  := format( 'Destination Location ID=%s folder "%s"',
                                    [SDstLocID, PDstFC.FilePath] );
        goto ErrPathContext;
      end;
    //
    // End of Check Src and Dst Paths contexts
    ////////////////////////////////////////////


      ResInfo := 'OK';
      if (DstSyncFlags and 4) <> 0 then
      begin
      // Add file Info Record
        Insert;
        FieldList.Fields[0].AsInteger := ADstLocID;
        FieldList.Fields[1].AsInteger := ASlideID;
      end
      else
      begin
        Filter := K_CMENDBLFILocID + ' = ' + SDstLocID;
        Filtered := TRUE;
        Edit();
      end;
    //
    // Prepare Src Location AllLocFilesInfo Record
    ////////////////////////////////////////////

    ////////////////////////////////////////////
    // Prepare Src and Dst Paths and names
    //
      WDT := 0;        // warning precaution
      WHistFlags := 0; // warning precaution

      PathSegm := K_CMSlideGetPatientFilesPathSegm( PatID ) +
                  K_CMSlideGetFileDatePathSegm(DTCr);
      SrcFPath := PSrcFC.FileName;
      DstFPath := K_CMSlideGetSrcImgFileName( SSlideID );
      CurFName := PathSegm + PSrcFC.FileName;
      SrcFName := PathSegm + DstFPath;
    //
    // Prepare Src and Dst Paths and names
    ////////////////////////////////////////////


    ////////////////////////////////////////////
    // Copy Current Image
    //
      CopySrcImgFlag := ((DstSyncFlags and 2) <> 0) and // Original Image is Needed
                        (SSrcLocID1 <> '');             // Original Image Source Exists
      if (DstSyncFlags and 1) <> 0 then
      begin
      // Synchronize CurImg
        if ((DstSyncFlags and 4) = 0) and // File Exists
           (DstDTFile = DTCr)         and // Dst Existing File is Src
           ((DstLocSlideFlags and 1) = 0) then // Dst Original File doesn't exist
        begin
        // Rename Existing - Move CurImgFile to SrcImgFile
          ActDone := FALSE;
          FilesInfo := format ( 'Renaming %s to %s, base path=%s', [SrcFPath,DstFPath,PDstFC.FilePath + PathSegm] );
          CopyInfo  := format ( 'Rename CurImg File to Original SlideID=%d LocID=%d', [ASlideID,ADstLocID] );
          try
            N_Dump1Str( format ( 'CMEFSync >>  %s', [FilesInfo] ) );
            if K_edOK = EDARenameFileOnServer( PDstFC.FilePath + CurFName,
                                   PDstFC.FilePath + SrcFName,
                                   SyncFilesWinAPIFlag ) then
            begin
              N_Dump1Str( format ( 'CMEFSync >> %s', [CopyInfo] ) );
              NewLocSlideFlags := 1; // Set Src Img Existing Flag
              CopySrcImgFlag := FALSE;
              ActDone := TRUE;
            end else
              N_Dump1Str( format ( 'CMEFSync >> Rename Fails >> %s', [CopyInfo] ) );
          except
            on E: Exception do
            begin
              N_Dump1Str( format ( 'CMEFSync >> Rename Error >> %s', [CopyInfo] ) );
            end;
          end;

          if not ActDone then
          begin
            AddInfoLine ( format ( 'Error: Renaming Last Current Image file to Original fails,  Object ID=%d to Location ID=%d', [ASlideID,ADstLocID] ) );
            AddInfoLine ( format ( 'Error: %s', [FilesInfo] ) );
            if not SyncFilesWinAPIFlag then
              APIInfo := 'sf_file_move'
            else
              APIInfo := 'RenameFile';
            N_Dump1Str( 'CMEFSync >> Error using >> ' + APIInfo );
            AddInfoLine ( format ( 'Error: using %s', [APIInfo] ) );

            // Check Path context
            CheckFilePathContext( PDstFC, SDstLocID, 'Destination' );
          end;
        end;

        if K_CMEDDBVersion >= 12 then
        begin
          WHistFlags := AHistFlags;
          if CopySrcImgFlag then
            WHistFlags := AHistFlags and not K_FSHistQueryLastFlag;
          AddHistRecord( WHistFlags, CurFSize, SSrcLocID );
          AHistFlags := AHistFlags and not K_FSHistQueryFirstFlag;
        end;

        // Copy CurImgFile or MediaFile to Dst Location
        ActDone := FALSE;
        SrcFPath := PSrcFC.FilePath + CurFName;
        DstFPath := PDstFC.FilePath + CurFName;
        FilesInfo := format ( 'Copying %s to %s', [SrcFPath,DstFPath] );
        CopyInfo := format ( 'CurImg File SlideID=%d LocID= from %s to %d', [ASlideID, SSrcLocID, ADstLocID] );
        try
          N_Dump1Str( format ( 'CMEFSync >>  %s', [FilesInfo] ) );
          PathInfo := PDstFC.FilePath + PathSegm;
          if not SyncFilesWinAPIFlag then
            APIInfo := 'sf_file_copy'
          else
            APIInfo := 'CopyFile';
          if K_edOK = EDAForceFilePath( PathInfo, SyncFilesWinAPIFlag, FALSE ) then
          begin
            if K_edOK = EDACopyFileOnServer( SrcFPath, DstFPath,
                                 SyncFilesWinAPIFlag ) then
            begin
            // Update Last Head Office Sync Timestamp
              TDateTimeField(FieldList.Fields[2]).Value := DTImg;
              WHistFlags := WHistFlags + K_FSHistTransSuccessFlag;
              N_Dump1Str( 'CMEFSync >> Copy ' + CopyInfo );
              ActDone := TRUE;
              WDT := CMEDDBAccess.EDAGetSyncTimestamp();
              if PSrcFC.MediaObjFlag then
              begin
                PSrcFC.MediaRootState.SPSCheckTS := WDT;
                PDstFC.MediaRootState.SPSCheckTS := WDT;
              end
              else
              begin
                PSrcFC.ImgRootState.SPSCheckTS := WDT;
                PDstFC.ImgRootState.SPSCheckTS := WDT;
              end;
            end
            else
            begin
              N_Dump1Str( 'CMEFSync >> Copy fails >> ' + CopyInfo );
            end;
          end else
          begin
            N_Dump1Str( format ( 'CMEFSync >> Folder %s ñreation error >> %s', [PathInfo,CopyInfo] ) );
            AddInfoLine ( format ( 'Error creating folder %s ', [PathInfo] ) );
             if not SyncFilesWinAPIFlag then
               APIInfo := 'sf_folder_create'
             else
               APIInfo := 'ForceDirectories';
            if ExtDataErrorCode = K_eePathExists then
            begin
              APIInfo := 'sf_path_exists';
              N_Dump1Str( format ( 'CMEFSync >> Path doesn''t exist >> %s', [ExtDataErrorString] ) );
              AddInfoLine ( format ( 'Error: Path %s doesn''t exist ', [ExtDataErrorString] ) );
            end
            else
            begin
              N_Dump1Str( format ( 'CMEFSync >> Couldn''t ñreate >> %s', [ExtDataErrorString] ) );
              AddInfoLine ( format ( 'Error: Couldn''t create folder %s ', [ExtDataErrorString] ) );
            end;
          end;
        except
          on E: Exception do
          begin
            N_Dump1Str( 'CMEFSync >> Copy Error >> ' + CopyInfo );
          end;
        end;

        if not ActDone then
        begin
          AddInfoLine ( format ( 'Error: Copying File (Current) for Object ID=%d from Location ID=%s  to ID=%d ', [ASlideID,SSrcLocID, ADstLocID] ) );
          AddInfoLine ( format ( 'Error: %s', [FilesInfo] ) );
          N_Dump1Str( 'CMEFSync >> Error using >> ' + APIInfo );
          AddInfoLine ( format ( 'Error: using %s', [APIInfo] ) );
          WHistFlags := WHistFlags + K_FSHistTransErrorFlag;
        end;

        if K_CMEDDBVersion >= 12 then
          UpdateHistRecord( WHistFlags );

        if not ActDone then
        begin
        // Check Path contexts
          CheckFilePathContext( PSrcFC, SSrcLocID, 'Source' );
          CheckFilePathContext( PDstFC, SDstLocID, 'Destination' );
          ResInfo := 'fails';
        end;
      end;
    //
    // Copy Current Image
    ////////////////////////////////////////////

    ////////////////////////////////////////////
    // Copy Original Image
    //
      if CopySrcImgFlag then
      begin
      // Synchronize SrcImg
        if SSrcLocID1 <> SSrcLocID then begin
        // Use new SrcLoc for Original Image Sync
          GetFC1( SSrcLocID1, PSrcFC );
          if PSrcFC = nil then
          begin
            CopyInfo  := 'Destination Location ID=' + SSrcLocID1 + ' path context is absent';
            goto AbsPathContext;
          end;
          if not GetFilePathContext( PSrcFC ) then
          begin
            CopyInfo  := format( 'Location ID=%s folder "%s"',
                                        [SSrcLocID1, PSrcFC.FilePath] );
            goto ErrPathContext;
          end;
        end;

        // Copy SrcImgFile
        if K_CMEDDBVersion >= 12 then
        begin
          WHistFlags := AHistFlags + K_FSHistFileOrigFlag;
          AddHistRecord( WHistFlags, SrcFSize, SSrcLocID1 );
        end;

        ActDone := FALSE;
        SrcFPath := PSrcFC.FilePath + SrcFName;
        DstFPath := PDstFC.FilePath + SrcFName;
        FilesInfo := format ( 'Copying %s to %s', [SrcFPath,DstFPath] );
        CopyInfo := format ( 'SrcImg File SlideID=%d LocID= from %s to %d', [ASlideID, SSrcLocID, ADstLocID] );
        try
          N_Dump1Str( format ( 'CMEFSync >>  %s', [FilesInfo] ) );
          if EDACopyFileOnServer( SrcFPath, DstFPath,
                                  SyncFilesWinAPIFlag ) = K_edOK then
          begin
            NewLocSlideFlags := 1; // Set Src Img Existing Flag
            N_Dump1Str( 'CMEFSync >> Copy ' + CopyInfo );
            WHistFlags := WHistFlags + K_FSHistTransSuccessFlag;
            ActDone := TRUE;
            if SSrcLocID1 <> SSrcLocID then
            begin
              WDT := CMEDDBAccess.EDAGetSyncTimestamp();
              PSrcFC.ImgRootState.SPSCheckTS := WDT;
              PDstFC.ImgRootState.SPSCheckTS := WDT;
            end;
          end else
            N_Dump1Str( 'CMEFSync >> Copy fails >> ' + CopyInfo );
        except
          on E: Exception do
            N_Dump1Str( 'CMEFSync >> Copy Error >> ' + CopyInfo );
        end;

        if not ActDone then
        begin
          AddInfoLine ( format ( 'Error: Copying File (Original) for  Object ID=%d from Location ID=%s  to ID=%d ', [ASlideID,SSrcLocID, ADstLocID] ) );
          AddInfoLine ( format ( 'Error: %s', [FilesInfo] ) );
          if not SyncFilesWinAPIFlag then
            APIInfo := 'sf_file_copy'
          else
            APIInfo := 'CopyFile';
          N_Dump1Str( 'CMEFSync >> Error using >> ' + APIInfo );
          AddInfoLine ( format ( 'Error: using %s', [APIInfo] ) );
          WHistFlags := WHistFlags + K_FSHistTransErrorFlag;
        end;

        if K_CMEDDBVersion >= 12 then
          UpdateHistRecord( WHistFlags );

        if not ActDone then
        begin
        // Check Path contexts
          CheckFilePathContext( PSrcFC, SSrcLocID, 'Source' );
          CheckFilePathContext( PDstFC, SDstLocID, 'Destination' );
          ResInfo := 'fails';
        end;
      end;
    //
    // Copy Original Image
    ////////////////////////////////////////////

      if not FieldList.Fields[2].IsNull then
      begin  // Update Slide File Record
        FieldList.Fields[3].AsInteger := NewLocSlideFlags;
        UpdateBatch;
      end;
      Result := 1;

FinTransfer:
      Close;
      EDAWaitForCurSlideRWLock( SSlideID, K_cmlfFree );
      AddInfoLine ( format ( 'Transfer files for Slide ID=%d to Location ID=%d %s', [ASlideID,ADstLocID,ResInfo] ) );
    end;
  except
    on E: Exception do
    begin
    CMEDDBAccess.EDAWaitForCurSlideRWLock( SSlideID, K_cmlfFree );
    SQLStr := format( '%s while Object ID=%s transfer to Location ID=%s', [E.Message, SSlideID, SDstLocID] );
    AddInfoLine ( 'Exception : ' + SQLStr );
    N_Dump1Str( 'CMEFSync >>  ' + SQLStr );
    Result := -2;
    end;
  end;
end; // TK_FormCMEFSyncProc.UpdateSlideFiles

//********************************************* TK_FormCMEFSyncProc.PrepLocSlidesFPathContext ***
// Prepapare Locations Files Acces Contexts DataSet
//
//     Parameters
// Result - Returns operation resultig code
//
function TK_FormCMEFSyncProc.PrepLocSlidesFPathContext(): TK_CMEDResult;
var
  FLocPathInfoArr : TK_CMFilesAccessContextArr;
  PrevInd, CInd, CLocID : Integer;
  CVal, CPath, LockInfo : string;
  PathChngFlag : Boolean;
  CheckResult : Boolean;

  procedure PathCheck( APPathState : TK_CMPFSyncPathState; AInfo : string );
  begin
    CVal := '';
    CheckResult := CheckLocPath( APPathState, FALSE, CVal, CPath );
    LockInfo := format( 'Location ID=%d %s folder "%s"',
                             [CLocID, AInfo, CPath] );
    if not CheckResult then
    begin
      N_Dump1Str( 'CMEFSync >> ' + LockInfo + ' >> ' + CVal );
      AddInfoLine ( LockInfo );
      AddInfoLine ( CVal );
    end
    else
    if CVal <> '' then
    begin
      N_Dump1Str( 'CMEFSync >> ' + LockInfo + ' >> ' + CVal );
      AddInfoLine ( LockInfo );
      AddInfoLine ( CVal );
    end;
  end;

begin
  try
    Result := K_edOK;
    with CMEDDBAccess, CurDSet3 do
    begin
      if Active then
        Close;
      Connection := LANDBConnection;
      ExtDataErrorCode := K_eeDBSelect;
      // *** Initialize Files Server Paths Context
      N_Dump2Str( 'CMEFSync>> FilesPathsContext from ' + K_CMENDBLocsFAccessTable  );
      SQL.Text := 'select ' +
        K_CMENDBLFALocImgFPath + ',' + K_CMENDBLFALocVideoFPath + ',' +
        K_CMENDBLFALocImgExtFPath + ',' + K_CMENDBLFALocVideoExtFPath + ',' +
        K_CMENDBLFALocFlags + ',' + K_CMENDBLFALocID +
        ' from ' + K_CMENDBLocsFAccessTable;
      Filtered := FALSE;
      Open;
      CentralStorageID := -1;
      // Get Head Office ID
//      Filter := '(' + K_CMENDBLFALocFlags + ' & 0x1) <> 0';
//      Filtered := TRUE;
//      if RecordCount > 0 then
//        HeadOfficeID := FieldList.Fields[5].AsInteger;
//      Filtered := FALSE;
       SetLength( FLocPathInfoArr, RecordCount );
       CInd := 0;
       First();
       while not EOF do
       begin
         CLocID := FieldList.Fields[5].AsInteger;
         if (FieldList.Fields[4].AsInteger and 1) <> 0 then
           CentralStorageID := CLocID;
         PrevInd := SearchLocPathInfo( CLocID );
         if PrevInd <> -1 then
           FLocPathInfoArr[CInd] := LocPathInfoArr[PrevInd];
         with FLocPathInfoArr[CInd] do
         begin
           FLocPathInfoArr[CInd].LocID := CLocID;
           CVal  := K_CMEDAGetDBStringValue( Fields[2] );
//           CVal := N_AnsiToString(Fields[2].AsString);
//             EDAGetStringFieldValue(FieldList.Fields[2]);
           PathChngFlag := CVal <> ImgRootState.SPSEFolder;
           ImgRootState.SPSEFolder := CVal;
           CVal  := K_CMEDAGetDBStringValue( Fields[0] );
//           CVal  := N_AnsiToString(Fields[0].AsString);
//           EDAGetStringFieldValue(FieldList.Fields[0]);
           ImgRootState.SPSFDA := K_CMParseFilesPath(CVal);
           PathChngFlag := PathChngFlag or (CVal <> ImgRootState.SPSFolder);
           ImgRootState.SPSFolder := CVal;
           if PathChngFlag then
           begin
             ImgRootState.SPSCheckTS := 0;
             ImgRootState.SPSSpace := 0;
             ImgRootState.SPSExistFlag := FALSE;
             ImgRootState.SPSWriteFlag := FALSE;
             ImgRootState.SPSFailureCount := 0;
           end;

           PathCheck( @ImgRootState, 'Image' );
{
           CVal := '';
           CheckResult := CheckLocPath( @ImgRootState, FALSE, CVal, CPath );
           LockInfo := format( 'Location ID=%d %s folder "%s"',
                                    [CLocID, 'Image', CPath] );
           if not CheckResult then
           begin
             N_Dump1Str( 'CMEFSync >> ' + LockInfo + ' >> ' + CVal );
             AddInfoLine ( LockInfo );
             AddInfoLine ( CVal );
           end
           else
           if CVal <> '' then
           begin
             N_Dump1Str( 'CMEFSync >> ' + LockInfo + ' >> ' + CVal );
             AddInfoLine ( LockInfo );
             AddInfoLine ( CVal );
           end;
}
           CVal  := K_CMEDAGetDBStringValue( Fields[3] );
//           CVal := N_AnsiToString(Fields[3].AsString);
//           EDAGetStringFieldValue(FieldList.Fields[3]);
           PathChngFlag := CVal <> MediaRootState.SPSEFolder;
           MediaRootState.SPSEFolder := CVal;
           CVal  := K_CMEDAGetDBStringValue( Fields[1] );
//           CVal  := N_AnsiToString(Fields[1].AsString);
//           EDAGetStringFieldValue(FieldList.Fields[1]);
           MediaRootState.SPSFDA := K_CMParseFilesPath(CVal);
           PathChngFlag := PathChngFlag or (CVal <> MediaRootState.SPSFolder);
           MediaRootState.SPSFolder := CVal;
           if MediaRootState.SPSFolder <> '' then
           begin
             MediaFSplit := MediaRootState.SPSFolder[1] = '*';
             if MediaFSplit then
               MediaRootState.SPSFolder := Copy(MediaRootState.SPSFolder, 2,
                 Length(MediaRootState.SPSFolder) - 1);
           end;

           if PathChngFlag then
           begin
             MediaRootState.SPSCheckTS := 0;
             MediaRootState.SPSSpace := 0;
             MediaRootState.SPSExistFlag := FALSE;
             MediaRootState.SPSWriteFlag := FALSE;
             MediaRootState.SPSFailureCount := 0;
           end;
           MediaRootState.SPSFDA := K_CMParseFilesPath( MediaRootState.SPSFolder );

           PathCheck( @MediaRootState, 'Video' );
{
           CVal := '';
           CheckResult := CheckLocPath( @MediaRootState, FALSE, CVal, CPath );
           LockInfo := format( 'Location ID=%d %s folder "%s"',
                                    [CLocID, 'Video', CPath] );
           if not CheckResult then
           begin
             N_Dump1Str( 'CMEFSync >> ' + LockInfo + ' >> ' + CVal );
             AddInfoLine ( LockInfo );
             AddInfoLine ( CVal );
           end
           else
           if CVal <> '' then
           begin
             N_Dump1Str( 'CMEFSync >> ' + LockInfo + ' >> ' + CVal );
             AddInfoLine ( LockInfo );
             AddInfoLine ( CVal );
           end;
}
         end; // end of with FLocPathInfoArr[CInd] do
         Inc(CInd);
         Next();
      end; //  end of while not EOF do
      Close;
      LocPathInfoArr := FLocPathInfoArr;
    end;
  except
    on E: Exception do
    begin
      Close;
      Result := K_edExDataError;
      CMEDDBAccess.ExtDataErrorString := 'FilesPathsContext ' + E.Message;
      CMEDDBAccess.EDAShowErrMessage(TRUE);
      Exit;
    end;
  end;

end; // TK_FormCMEFSyncProc.PrepLocSlidesFPathContext

//********************************************* TK_FormCMEFSyncProc.FormCloseQuery ***
// Form Close Query Handler
//
procedure TK_FormCMEFSyncProc.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//
end; // TK_FormCMEFSyncProc.FormCloseQuery

//********************************************* TK_FormCMEFSyncProc.FormClose ***
// Form Close Handler
//
procedure TK_FormCMEFSyncProc.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  QueryDSet.Free;
  CMEDDBAccess.Free;
  AppSL.Free;


  inherited;

  N_Dump1Str( 'CMEFSync >> Process Fin' );
  if TestStartFromCMSMode then Exit;

  // Flush Dump Channels

//  N_LCAddFinishedOKFlag( N_CMSDump2LCInd );
  N_LCAddFinishedOKFlag( N_Dump1LCInd );
  N_LCExecAction( -1, lcaFlush );
end; // TK_FormCMEFSyncProc.FormClose

//********************************************* TK_FormCMEFSyncProc.SearchLocPathInfo ***
// Search Loc Path Info
//
function TK_FormCMEFSyncProc.SearchLocPathInfo( ALocID: Integer ): Integer;
begin
  Result := -1;
  if Length(LocPathInfoArr) = 0 then Exit;
  Result := K_IndexOfIntegerInRArray( ALocID, @LocPathInfoArr[0].LocID,
               Length(LocPathInfoArr), SizeOf(TK_CMFilesAccessContext));
end; // TK_FormCMEFSyncProc.SearchLocPathInfo

//********************************************* TK_FormCMEFSyncProc.CheckLocPath ***
// Check Location Path
//
//      Parameters
// APPathState - pointer to path context record
// AUCheckFlag - uncondition check flag
// AStateStr   - resulting state string
// APath       - resulting path string
//
function TK_FormCMEFSyncProc.CheckLocPath( APPathState : TK_CMPFSyncPathState;
                                           AUCheckFlag : Boolean;
                                           var AStateStr, APath : string ) : Boolean;
const
  CheckName = '123456789.123';
var
  CurTS : TDateTime;
  Folder, SFolder : string;
  TmpName: string;
  APIInfo : string;

label LExit;
begin

  Result := TRUE;
  try
  with CMEDDBAccess, APPathState^ do
  begin
    CurTS := EDAGetSyncTimestamp();
    if not AUCheckFlag   and
       (SPSCheckTS <> 0) and
       (CurTS - SPSCheckTS < K_FSCheckPathPeriod) then Exit;
    Result := FALSE;
    SPSCheckTS := CurTS;
    SPSExistFlag := FALSE;
    SPSSpace     := 0;
    SPSWriteFlag := FALSE;

    AStateStr := 'Path is not specified';
    Folder := SPSEFolder;
    if Folder = '' then
      Folder := SPSFolder;
    APath := Folder;
    if Folder = '' then goto LExit;

    SFolder := ExcludeTrailingPathDelimiter(Folder);


    APIInfo := 'sf_path_exists';
    if SyncFilesWinAPIFlag then
      APIInfo := 'DirectoryExists';
    SPSExistFlag := EDAPathOrFileExists( SFolder,
                                         SyncFilesWinAPIFlag, TRUE ) = K_edOK;
    AStateStr := 'Path checked by ' + APIInfo + ' doesn''t exist';

    if not SPSExistFlag then goto LExit;

    APIInfo := 'sf_GetPathFreeSpace';
    if SyncFilesWinAPIFlag then
      APIInfo := 'GetDiskFreeSpaceEx';
    EDAGetDirFreeSpace( Folder, SyncFilesWinAPIFlag, SPSSpace );

    AStateStr := 'Path free space ' + N_DataSizeToString( SPSSpace );
    if SPSSpace = 0 then goto LExit;

    TmpName := K_ExpandFileName('(#TmpFiles#)' + CheckName);
    if not FileExists(TmpName) then
      with TFileStream.Create(TmpName, fmCreate) do
      begin
        Write(TmpName[1], 1);
        Free;
      end;
    SPSWriteFlag := FALSE;
    APIInfo := 'xp_write_file';
    if SyncFilesWinAPIFlag then
      APIInfo := 'CopyFile';
    if EDACopyFileOnServer( TmpName, Folder + CheckName, SyncFilesWinAPIFlag ) = K_edOK then
    begin
      APIInfo := 'sf_file_delete';
      if SyncFilesWinAPIFlag then
        APIInfo := 'DeleteFile';
      EDAFileDelete( Folder + CheckName, SyncFilesWinAPIFlag );
      SPSWriteFlag := TRUE;
      Result := TRUE;
    end
    else
      AStateStr := AStateStr + '. Files couldn''t be written by ' + APIInfo;
LExit:
    if not Result then Inc(APPathState^.SPSFailureCount);
  end;
  except
    on E: Exception do begin
      AStateStr := AStateStr + '. Files path check Exception ' + E.Message;
      N_Dump1Str( 'CMEFSync >> Exception >> ' + E.Message );
      N_Dump1Str( 'CMEFSync >> Error using >> ' + APIInfo );
      AddInfoLine ( format ( 'Error: using %s', [APIInfo] ) );
      Inc(APPathState^.SPSFailureCount);
    end;
  end;
end; // TK_FormCMEFSyncProc.CheckLocPath

//******************************************** TK_FormCMEFSyncProc.OnUHException ***
// On Appliction Unhadled Exception Handler
//
procedure TK_FormCMEFSyncProc.OnUHException( Sender: TObject; E: Exception );
var
  ErrStr : string;
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

    ErrStr := ' CMEFSync terminated by exception:'#13#10 + E.Message;
    ShowMesDlg( ErrStr, mtError );
//    N_CMSCreateDumpFiles( $001 );  // new CreateDumpFiles for CMSFSync needed
    N_LCExecAction( -1, lcaFlush );

    CMEDDBAccess.Free;
  finally
//    Application.Terminate();
    ExitProcess( 10 );
  end;
end; // end of procedure TK_FormCMEFSyncProc.OnUHException

end.
