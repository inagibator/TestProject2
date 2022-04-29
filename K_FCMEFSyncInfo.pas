unit K_FCMEFSyncInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ComCtrls, ExtCtrls,
  N_Types;

type
  TK_FormCMEFSyncInfo = class(TN_BaseForm)
    PageControl: TPageControl;
    BtCancel: TButton;
    BtOK: TButton;
    TSSetup: TTabSheet;
    TSHistory: TTabSheet;
    ChBHOfficeSync: TCheckBox;
    GBSchedule: TGroupBox;
    DTPStartTime: TDateTimePicker;
    LbStart: TLabel;
    LbEndTime: TLabel;
    DTPEndTime: TDateTimePicker;
    GBDates: TGroupBox;
    DTPFrom: TDateTimePicker;
    DTPTo: TDateTimePicker;
    LbFrom: TLabel;
    LbTo: TLabel;
    BtRequest: TButton;
    BtCopyLog: TButton;
    BtFailures: TButton;
    ChBLastSyncSession: TCheckBox;
    BtSetupApply: TButton;
    BtSuccess: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ChBLastSyncSessionClick(Sender: TObject);
    procedure BtRequestClick(Sender: TObject);
    procedure BtCopyLogClick(Sender: TObject);
    procedure BtFailuresClick(Sender: TObject);
    procedure BtSetupApplyClick(Sender: TObject);
    procedure BtSuccessClick(Sender: TObject);
  private
    { Private declarations }
    ReportDetailes : string;
    ReportPhase : Integer;
    MatrCInd, MatrRInd : Integer;
    RepSL : TStringList;
    procedure DumpError( ARepName : string; ARSMatr: TN_ASArray );
  public
    { Public declarations }
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
  end;

var
  K_FormCMEFSyncInfo: TK_FormCMEFSyncInfo;

function  K_CMCMEFSyncInfoDlg( ) : Boolean;

implementation

{$R *.dfm}

uses DB, DateUtils, Math,
  K_CLib0, K_CM0, K_FCMReportShow, K_FEText,
  N_Lib1, N_Lib0;

function  K_CMCMEFSyncInfoDlg( ) : Boolean;
begin

  with TK_FormCMEFSyncInfo.Create(Application) do
  begin
//    BaseFormInit ( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    Result := ShowModal = mrOK;

    if not Result then Exit;

  end;

end;

//******************************* TK_FormCMEFSyncInfo.FormShow ***
// Form Show Handler
//
procedure TK_FormCMEFSyncInfo.FormShow(Sender: TObject);
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    EDAEMGetFSyncSessionAttrs( );
    EDAEMDumpSFSyncSessionAttrs( ' CMEFSyncInfo Change (cur) ' );
    if SyncSessionStartTS = 0 then
      SyncSessionStartTS := 10000;
    if SyncSessionFinTS = 0 then
      SyncSessionFinTS := 10000;
    DTPStartTime.DateTime := SyncSessionStartTS;
    DTPEndTime.DateTime := SyncSessionFinTS;
    ChBHOfficeSync.Checked := (SyncSessionFlags and 1) <> 0;

    ChBLastSyncSessionClick( Sender );
  end;
end; // TK_FormCMEFSyncInfo.FormShow

//******************************* TK_FormCMEFSyncInfo.BtSetupApplyClick ***
// BtSetupApply Click Handler
//
procedure TK_FormCMEFSyncInfo.BtSetupApplyClick(Sender: TObject);
var
  SSStartTS : TDateTime; // Files Sync Session Start Timesatmp
  SSFinTS   : TDateTime; // Files Sync Session Fin Timesatmp
  SSFlags   : Integer;   // Files Sync Session Flags:
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin

    SSStartTS := TimeOf(DTPStartTime.DateTime);
    SSFinTS := TimeOf(DTPEndTime.DateTime);

    SSFlags := 0;
    if ChBHOfficeSync.Checked then
      SSFlags := SSFlags or 1;

    if (SSStartTS <> SyncSessionStartTS) or
       (SSFinTS <> SyncSessionFinTS)     or
       (((SSFlags xor SyncSessionFlags) and 1) <> 0) then
    begin

      SyncSessionStartTS := SSStartTS;
      SyncSessionFinTS := SSFinTS;

      SyncSessionFlags := (SyncSessionFlags and not 1) or SSFlags;

      EDAEMSaveFSyncSessionAttrs();

      EDAEMDumpSFSyncSessionAttrs( ' CMEFSyncInfo Change (new) ' );
    end;
  end;
end; // TK_FormCMEFSyncInfo.BtSetupApplyClick

//******************************* TK_FormCMEFSyncInfo.FormCloseQuery ***
// Form Close Query Handler
//
procedure TK_FormCMEFSyncInfo.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
    BtSetupApplyClick(Sender);
end; // TK_FormCMEFSyncInfo.FormCloseQuery

//******************************* TK_FormCMEFSyncInfo.ChBLastSyncSessionClick ***
// ChBLastSyncSession Click Handler
//
procedure TK_FormCMEFSyncInfo.ChBLastSyncSessionClick(Sender: TObject);
begin
  DTPFrom.Enabled := not ChBLastSyncSession.Checked;
  DTPTO.Enabled   := not ChBLastSyncSession.Checked;
end; // TK_FormCMEFSyncInfo.ChBLastSyncSessionClick

//******************************* TK_FormCMEFSyncInfo.BtRequestClick ***
// BtRequest Click Handler
//
//  Resulting Strings Matrix according to Params is prepared
//  And Dialog with Rusulting Data is shown
//
procedure TK_FormCMEFSyncInfo.BtRequestClick(Sender: TObject);
var
  i, ID : Integer;
  SQLText, WStr, SQLFields1, SQLFields2, SQLJoin : string;
  WDT : TDateTime;
  SavedCursor: TCursor;
  WDB : TDateTime;
  WDE : TDateTime;
begin

  if K_CMEDDBVersion < 12 then
  begin
    K_CMShowMessageDlg( //sysout
             ' Is not implemented now ', mtInformation );
    Exit;
  end;
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  with TK_CMEDDBAccess(K_CMEDAccess),
       TK_FormCMReportShow.Create(Application) do
  begin
//    BaseFormInit ( nil, 'K_FormCMReportShow' );
    BaseFormInit( nil, 'K_FormCMReportShow', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    try
      ReportPhase := 0;
      MatrCInd := -1;
      MatrRInd := -1;

      WDB := Int(DTPFrom.DateTime);
      WDE := Int(DTPTO.DateTime + 1) - 1/(24*3600*1000);
    ////////////////////////////
    // Prepare Report SQL
    //
      SQLFields1 :=
        'Q.RQID as RQID,Q.RTS as RTS,Q.RLocID as RLocID,Q.RSlideID as RSlideID,' +
        'Q.RPatID as RPatID,Q.RUserID as RUserID,S.PatID as RSPatID,S.HLocID as RHLocID,';

      SQLFields2 :=
        '(select ' + K_CMENDAHLocCapt + ' from ' + K_CMENDBAllHistLocationsTable +
        ' where ' + K_CMENDAHLocID + '=RLocID) as RLocCapt,' +
        '(select ' + K_CMENDAHProvCapt + ' from ' + K_CMENDBAllHistProvidersTable +
        ' where ' + K_CMENDAHProvID + '=RUserID) as RUserCapt,' +
        '(select ' + K_CMENDAHPatCN + ' from ' + K_CMENDBAllHistPatientsTable +
        ' where ' + K_CMENDAHPatID + '=RPatID) as RPatCN,' +
        '(select ' + K_CMENDAHPatCN + ' from ' + K_CMENDBAllHistPatientsTable +
        ' where ' + K_CMENDAHPatID + '=RSPatID) as RSPatCN,' +
        '(select ' + K_CMENDAHLocCapt + ' from ' + K_CMENDBAllHistLocationsTable +
        ' where ' + K_CMENDAHLocID + '=RHLocID) as RHLocCapt';

      SQLJoin := ') Q LEFT OUTER JOIN (SELECT ' +
        K_CMENDBSTFSlideID + ' as SlideID,' + K_CMENDBSTFPatID + ' as PatID,' +
        K_CMENDBSTFSlideLocIDHost + ' as HLocID' +
        ' FROM ' + K_CMENDBSlidesTable + ') S' +
        ' ON Q.RSlideID = S.SlideID';

      SQLText := 'select ' +  // Display the last data available
        SQLFields1 + SQLFields2 +
        ' from (select ' +
        K_CMENDBSFQElemID   + ' as RQID, ' +
        K_CMENDBSFQSTS      + ' as RTS, ' +
        K_CMENDBSFQDstLocID + ' as RLocID, ' +
        K_CMENDBSFQSlideID  + ' as RSlideID, ' +
        K_CMENDBSFQPatID    + ' as RPatID, ' +
        K_CMENDBSFQProvID   + ' as RUserID' +
            ' from ' + K_CMENDBSyncFilesQueryTable +
            ' where RPatID is null or exists (select 1 from (select '
                           + K_CMENDBSTFSlideID + ', ' + K_CMENDBSTFSlideDTImg +
                 ' from '  + K_CMENDBSlidesTable +
                 ' where ' + K_CMENDBSTFPatID + ' = ' + K_CMENDBSFQPatID +
                 ' and (' + K_CMENDBSTFSlideFlags + '<> 2' +
                    ' or ' + K_CMENDBSTFSlideFlags + ' IS NULL) ) S1' +
             ' left outer join ' +
                '(select '  + K_CMENDBLFILocSlideID + ', ' + K_CMENDBLFILocSlideTS +
                 ' from '  + K_CMENDBLocFilesInfoTable +
                 ' where ' + K_CMENDBLFILocID + ' = ' + K_CMENDBSFQDstLocID + ' ) Q1' +
        ' on S1.' + K_CMENDBSTFSlideID + ' = Q1.' + K_CMENDBLFILocSlideID +
        ' where Q1.' + K_CMENDBLFILocSlideTS + ' IS NULL' +
           ' or Q1.' + K_CMENDBLFILocSlideTS + ' < S1.' + K_CMENDBSTFSlideDTImg + ')' + SQLJoin;
//        ' from ' + K_CMENDBSyncFilesQueryTable + SQLJoin;
//K_GetFormTextEdit.EditText(SQLText);
      ReportDetailes := 'Requests query current state';

      if not ChBLastSyncSession.Checked then
      begin // Display by Date Interval
        WStr := ' where ' +
              'RTS >= ' + EDADBDateTimeToSQL( WDB ) + ' AND ' +
              'RTS <= ' + EDADBDateTimeToSQL( WDE );
//            'RTS >= DATETIME(''' + K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss.zzz' ) + ''') and ' +
//            'RTS <= DATETIME(''' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss.zzz' ) + ''')';
        SQLText := SQLText + WStr + ' union ' +
           'select ' +  SQLFields1 + SQLFields2 +
          ' from (select ' +
            K_CMENDBSFQHElemID   + ' as RQID, ' +
            K_CMENDBSFQHSTS      + ' as RTS, ' +
            K_CMENDBSFQHDstLocID + ' as RLocID, ' +
            K_CMENDBSFQHSlideID  + ' as RSlideID, ' +
            K_CMENDBSFQHPatID    + ' as RPatID, ' +
            K_CMENDBSFQHProvID   + ' as RUserID' +
          ' from ' + K_CMENDBSyncFilesQueryHistTable + SQLJoin + WStr;

  //      ReportDetailes := 'Requests state from ' +
  //         K_DateTimeToStr( DTPFrom.DateTime, 'yyyy-mm-dd' ) +
  //         ' to ' + K_DateTimeToStr( DTPTO.DateTime, 'yyyy-mm-dd' );
        ReportDetailes := 'Requests state from ' +
             K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss AM/PM' ) +
             ' to ' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss AM/PM' );
      end;
      SQLText := SQLText + ' order by RTS asc';
    // Debug Code to View and Edit SQL
    //    with TK_FormTextEdit.Create(Application) do
    //      EditText( SQLText );

    //
    // end of Prepare Report SQL
    ////////////////////////////

      with CurDSet1 do
      begin
        ReportPhase := 1;
        Connection := LANDBConnection;
        ExtDataErrorCode := K_eeDBSelect;
        SQL.Text := SQLText;
        Filtered := false;
        Open;
        ReportPhase := 2;
        SetLength( ReportDataSMatr, RecordCount + 1 );
        SetLength( ReportDataSMatr[0], 7 );
        ReportDataSMatr[0][0] := 'Date';
        ReportDataSMatr[0][1] := 'Time';
        ReportDataSMatr[0][2] := 'Location receiver';
        ReportDataSMatr[0][3] := 'Host Location';
        ReportDataSMatr[0][4] := 'Object ID';
        ReportDataSMatr[0][5] := 'Patient Card #/ID';
        ReportDataSMatr[0][6] := 'User';
        First;
  {
     0  RQID,
     1  RTS,
     2  RLocID,
     3  RSlideID
     4  RPatID,
     5  RUserID
     6  RSPatID
     7  RHLocID
     8  RLocCapt,' +
     9  RUserCapt,' +
    10  RPatCN,' +
    11  RSPatCN,' +
    12  RHLocCapt';
  }
      // Get  Selected Data
        i := 1;
        while not EOF do
        begin
          MatrRInd := i;
          MatrCInd := 0;
          SetLength( ReportDataSMatr[i], 7 );
          WDT := TDateTimeField(FieldList.Fields[1]).Value;
          //***** Date
          ReportDataSMatr[i][0] := K_DateTimeToStr( WDT, 'dd.mm.yyyy' );

          //***** Time
          MatrCInd := 1;
          ReportDataSMatr[i][1] := K_DateTimeToStr( WDT, 'hh:nn:ss AM/PM' );

          //***** Location
          MatrCInd := 2;
          if FieldList.Fields[8].IsNull then
          begin
            WStr := K_CMGetLocationDetails( FieldList.Fields[2].AsInteger );
            if K_StrStartsWith( 'LocID=', WStr ) then
            begin
              WStr := Copy( WStr, 4, Length(WStr) );
              WStr[3] := ' ';
            end;
            ReportDataSMatr[i][2] := WStr;
          end
          else
            ReportDataSMatr[i][2] := K_CMEDAGetDBStringValue(Fields[8]);
//            ReportDataSMatr[i][2] := N_AnsiToString(Fields[8].AsString);
//             EDAGetStringFieldValue(FieldList.Fields[8]);

          MatrCInd := 3;
          ID := FieldList.Fields[3].AsInteger;
          if ID = 0 then begin
            ReportDataSMatr[i][3] := '';
            MatrCInd := 4;
            ReportDataSMatr[i][4] := '';
          end else
          begin
          //***** Host Location
            if FieldList.Fields[12].IsNull then
            begin
              if FieldList.Fields[7].IsNull then
                ReportDataSMatr[i][3] := '  (-)'
              else
                ReportDataSMatr[i][3] := 'ID=' + K_CMEDAGetDBStringValue(Fields[7]);
//                ReportDataSMatr[i][3] := 'ID=' + N_AnsiToString(Fields[7].AsString);
//                EDAGetStringFieldValue(FieldList.Fields[7])
            end
            else
              ReportDataSMatr[i][3] := K_CMEDAGetDBStringValue(Fields[12]);
//              ReportDataSMatr[i][3] := N_AnsiToString(Fields[12].AsString);
//              EDAGetStringFieldValue(FieldList.Fields[12]);

          //***** Object ID
            MatrCInd := 4;
            ReportDataSMatr[i][4] := FieldList.Fields[3].AsString;
          end;

          //***** Patient Card #/ID
          MatrCInd := 5;
          if FieldList.Fields[4].AsInteger <> 0 then
          begin
          // Patient Request
            if FieldList.Fields[10].IsNull then
              ReportDataSMatr[i][5] := 'ID ' + FieldList.Fields[4].AsString
            else
              ReportDataSMatr[i][5] := 'Card # ' + K_CMEDAGetDBStringValue(Fields[10]);
//              ReportDataSMatr[i][5] := 'Card # ' + N_AnsiToString(Fields[10].AsString);
//              EDAGetStringFieldValue(FieldList.Fields[10]);
          end else
          begin
          // Slide Request
            if FieldList.Fields[6].AsInteger = 0 then
              ReportDataSMatr[i][5] := '  (-)'
            else begin
              if FieldList.Fields[11].IsNull then
                ReportDataSMatr[i][5] := 'ID ' + FieldList.Fields[6].AsString
              else
                ReportDataSMatr[i][5] := 'Card # ' + K_CMEDAGetDBStringValue(Fields[11]);
//                ReportDataSMatr[i][5] := 'Card # ' + N_AnsiToString(Fields[11].AsString);
//                EDAGetStringFieldValue(FieldList.Fields[11]);
            end;
          end;

          //***** User
          MatrCInd := 6;
          ID := FieldList.Fields[5].AsInteger;
          if ID = -1 then
            ReportDataSMatr[i][6] := 'Appointment book'
          else if ID = -2 then
            ReportDataSMatr[i][6] := 'Central files storage'
          else begin
            if FieldList.Fields[9].IsNull then
              ReportDataSMatr[i][6] := K_CMGetProviderDetails( ID )
            else
              ReportDataSMatr[i][6] := K_CMEDAGetDBStringValue(Fields[9]);
//              ReportDataSMatr[i][6] := N_AnsiToString(Fields[9].AsString);
//              EDAGetStringFieldValue(FieldList.Fields[9]);
          end;
          Inc(i);
          Next;
        end;
        Close;
      end;
      ReportPhase := 3;
      PrepareRAFrameByDataSMatr( ReportDetailes );
      FrRAEdit.RAFCArray[0].TextPos := Ord(K_ppCenter);
      FrRAEdit.RAFCArray[1].TextPos := Ord(K_ppCenter);
      FrRAEdit.RAFCArray[4].TextPos := Ord(K_ppDownRight);

      Screen.Cursor := SavedCursor;

      ReportPhase := 4;
      ShowModal;
      except
        on E: Exception do
        begin
          DumpError( 'Requests', ReportDataSMatr );
          raise Exception.Create('Requests Report  ERROR >> ' + E.Message);
        end;
      end;
    end;

end; // TK_FormCMEFSyncInfo.BtRequestClick

//******************************* TK_FormCMEFSyncInfo.BtCopyLogClick ***
// BtCopyLog Click Handler
//
//  Resulting Strings Matrix according to Params is prepared
//  And Dialog with Rusulting Data is shown
//
procedure TK_FormCMEFSyncInfo.BtCopyLogClick(Sender: TObject);
var
  i, NH, NM : Integer;
  NS : Double;
  SQLText : string;
  WDT : TDateTime;
  WDB : TDateTime;
  WDE : TDateTime;
  SavedCursor: TCursor;
  WStr : string;
begin

  if K_CMEDDBVersion < 12 then
  begin
    K_CMShowMessageDlg( //sysout
           ' Is not implemented now ', mtInformation );
    Exit;
  end;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  with TK_CMEDDBAccess(K_CMEDAccess),
       TK_FormCMReportShow.Create(Application) do
  begin
//    BaseFormInit ( nil, 'K_FormCMReportShow' );
    BaseFormInit( nil, 'K_FormCMReportShow', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    try
      ReportPhase := 0;
      MatrCInd := -1;
      MatrRInd := -1;
//      BaseFormInit ( nil ); //???
    ////////////////////////////
    // Prepare Report SQL
    //
      if not ChBLastSyncSession.Checked then
      begin
      // Use Given Time Interval
        WDB := Int(DTPFrom.DateTime);
        WDE := Int(DTPTO.DateTime + 1) - 1/(24*3600*1000);
      end else
      begin
      // Use Sync Session Interval
        WDT := EDAEMGetFSyncSessionTime( WDB, WDE );
        if WDB > WDT then
          WDB := WDB - 1;
        WDE := WDT;
{
        WDT := EDAGetSyncTimestamp();
        WDB := DateOf(WDT) - 1 + TimeOf(SyncSessionStartTS);
        WDB := Min( DateOf(WDT), WDB );
        WDE := WDT;
}
      end;

      SQLText := 'select ' +  // Display the last data available
        K_CMENDBSFHDstLocID + ' as LocID, ' +
        '(select ' + K_CMENDAHLocCapt + ' from ' + K_CMENDBAllHistLocationsTable +
        ' where ' + K_CMENDAHLocID + '=' + K_CMENDBSFHDstLocID + ') as LocCapt, ' +
        '( CASE WHEN ('+K_CMENDBSFHFlags+' & 0x18)= 8 then ''Success''' +
        ' WHEN ('+K_CMENDBSFHFlags+' & 0x18)= 16 then ''Failure''' +
        ' ELSE ''Copying'' END ) as Status, ' +
        ' SUM(' +K_CMENDBSFHFSize+ '), SUM(' +K_CMENDBSFHFTMSec+ '), COUNT(*) ' +
        ' FROM ' + K_CMENDBSyncFilesHistTable +
        ' WHERE ' +
             K_CMENDBSFHSTS + ' >= ' + EDADBDateTimeToSQL( WDB ) + ' AND '+
             K_CMENDBSFHSTS + ' <= ' + EDADBDateTimeToSQL( WDE ) +
//            K_CMENDBSFHSTS + ' >= DATETIME(''' + K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss.zzz' ) + ''') and ' +
//            K_CMENDBSFHSTS + ' <= DATETIME(''' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss.zzz' ) + ''')' +
        ' GROUP BY Status, LocID ORDER BY LocID ASC';

    //
    // end of Prepare Report SQL
    ////////////////////////////

      with CurDSet1 do
      begin
        ReportPhase := 1;
        Connection := LANDBConnection;
        ExtDataErrorCode := K_eeDBSelect;
        SQL.Text := SQLText;
        Filtered := false;
        Open;
        ReportPhase := 2;
        SetLength( ReportDataSMatr, RecordCount + 1 );
        SetLength( ReportDataSMatr[0], 5 );
        ReportDataSMatr[0][0] := 'Location';
        ReportDataSMatr[0][1] := 'Time taken';
        ReportDataSMatr[0][2] := 'Number of Objects';
        ReportDataSMatr[0][3] := 'Volume of Objects';
        ReportDataSMatr[0][4] := 'Status';
        First;

      // Get  Selected Data
        i := 1;
        while not EOF do
        begin
          MatrRInd := i;
          MatrCInd := 0;
          SetLength( ReportDataSMatr[i], 5 );
         //***** Location
          if FieldList.Fields[1].IsNull then
          begin
            WStr := K_CMGetLocationDetails( FieldList.Fields[0].AsInteger );
            if K_StrStartsWith( 'LocID=', WStr ) then
            begin
              WStr := Copy( WStr, 4, Length(WStr) );
              WStr[3] := ' ';
            end;
            ReportDataSMatr[i][0] := WStr;
          end
          else
            ReportDataSMatr[i][0] := K_CMEDAGetDBStringValue(Fields[1]);
//            ReportDataSMatr[i][0] := N_AnsiToString(Fields[1].AsString);
//            EDAGetStringFieldValue(FieldList.Fields[1]);

         //***** Time taken
          MatrCInd := 1;
          NS := FieldList.Fields[4].AsFloat/1000/3600;
          NH := Round(Int(NS));
          NS := Frac(NS) * 60;
          NM := Round(Int(NS));
          NS := Frac(NS) * 60;
          ReportDataSMatr[i][1] := format('%d:%.2d:%5.3f', [NH,NM,NS] );

         //***** Number of Objects
          MatrCInd := 2;
          ReportDataSMatr[i][2] := FieldList.Fields[5].AsString;

         //***** Volume of Objects
          MatrCInd := 3;
          ReportDataSMatr[i][3] := FieldList.Fields[3].AsString;

         //***** Status
          MatrCInd := 4;
          ReportDataSMatr[i][4] := K_CMEDAGetDBStringValue(Fields[2]);
//          ReportDataSMatr[i][4] := N_AnsiToString(Fields[2].AsString);
//          EDAGetStringFieldValue(FieldList.Fields[2]);
          Inc(i);
          Next;
        end;
        Close;
      end;
      ReportDetailes := 'Objects copying across locations from ' +
           K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss AM/PM' ) +
           ' to ' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss AM/PM' );
  //    ReportDetailes := 'Objects copying across locations from ' +
  //         K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss' ) +
  //         ' to ' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss' );
      ReportPhase := 3;
      PrepareRAFrameByDataSMatr( ReportDetailes );
      FrRAEdit.RAFCArray[1].TextPos := Ord(K_ppDownRight);
      FrRAEdit.RAFCArray[2].TextPos := Ord(K_ppDownRight);
      FrRAEdit.RAFCArray[3].TextPos := Ord(K_ppDownRight);

      Screen.Cursor := SavedCursor;

      ReportPhase := 4;
      ShowModal;
    except
      on E: Exception do
      begin
        DumpError( 'CopyLog', ReportDataSMatr );
        raise Exception.Create('CopyLog Report  ERROR >> ' + E.Message);
      end;
    end;
  end;
end; // TK_FormCMEFSyncInfo.BtCopyLogClick

//******************************* TK_FormCMEFSyncInfo.BtFailuresClick ***
// BtFailures Click Handler
//
//  Resulting Strings Matrix according to Params is prepared
//  And Dialog with Rusulting Data is shown
//
procedure TK_FormCMEFSyncInfo.BtFailuresClick(Sender: TObject);
var
  i, ID : Integer;
  SQLText : string;
  WDT : TDateTime;
  WDB : TDateTime;
  WDE : TDateTime;
  SavedCursor: TCursor;
  WStr : string;
begin

  if K_CMEDDBVersion < 12 then
  begin
    K_CMShowMessageDlg( //sysout
      ' Is not implemented now ', mtInformation );
    Exit;
  end;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  with TK_CMEDDBAccess(K_CMEDAccess),
       TK_FormCMReportShow.Create(Application) do
  begin
//    BaseFormInit ( nil, 'K_FormCMReportShow' );
    BaseFormInit( nil, 'K_FormCMReportShow', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    try
      ReportPhase := 0;
      MatrCInd := -1;
      MatrRInd := -1;
//      BaseFormInit ( nil ); // ???
    ////////////////////////////
    // Prepare Report SQL
    //
      if not ChBLastSyncSession.Checked then
      begin
      // Use Given Time Interval
        WDB := Int(DTPFrom.DateTime);
        WDE := Int(DTPTO.DateTime + 1) - 1/(24*3600*1000);
      end else
      begin
      // Use Sync Session Interval
        WDT := EDAEMGetFSyncSessionTime( WDB, WDE );
        if WDB > WDT then
          WDB := WDB - 1;
        WDE := WDT;
{
        WDT := EDAGetSyncTimestamp();
        WDB := DateOf(WDT) - 1 + TimeOf(SyncSessionStartTS);
        WDB := Min( DateOf(WDT), WDB );
        WDE := WDT;
}
      end;
  {
      SQLText := 'select ' +  // Display the last data available
        K_CMENDBSFHDstLocID + ',' +
        K_CMENDBSFHSrcLocID + ',' +
        K_CMENDBSTFPatID  + ',' +
        K_CMENDBSFHSlideID  + ',' +
        K_CMENDBSFQHProvID  +
        ' FROM ' + K_CMENDBSyncFilesHistTable + ',' + K_CMENDBSlidesTable + ',' + K_CMENDBSyncFilesQueryHistTable +
        ' WHERE ' +
            K_CMENDBSFHSTS + ' >= DATETIME(''' + K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss.zzz' ) + ''') and ' +
            K_CMENDBSFHSTS + ' <= DATETIME(''' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss.zzz' ) + ''') and ' +
            K_CMENDBSFQHElemID + '=' + K_CMENDBSFHQElemID + ' and ' +
            K_CMENDBSTFSlideID + '=' + K_CMENDBSFHSlideID +
        ' ORDER BY ' + K_CMENDBSFHSTS + ' ASC';
  }
      SQLText := 'SELECT ' +  // Display the last data available
        'S.' + K_CMENDBSFHDstLocID + ',' +
        'S.' + K_CMENDBSFHSrcLocID + ',' +
        '(select ' + K_CMENDAHLocCapt + ' from ' + K_CMENDBAllHistLocationsTable +
        ' where ' + K_CMENDAHLocID + '=' + 'S.' + K_CMENDBSFHDstLocID + '),' +
        '(select ' + K_CMENDAHLocCapt + ' from ' + K_CMENDBAllHistLocationsTable +
        ' where ' + K_CMENDAHLocID + '=' + 'S.' + K_CMENDBSFHSrcLocID + '),' +
        'Q.' + K_CMENDBSTFPatID  + ',' +
        'S.' + K_CMENDBSFHSlideID  + ',' +
        'S.' + K_CMENDBSFQHProvID  + ',' +
        '(select ' + K_CMENDAHProvCapt + ' from ' + K_CMENDBAllHistProvidersTable +
        ' where ' + K_CMENDAHProvID + '=' + 'S.' + K_CMENDBSFQHProvID + ') as UserCapt,' +
        '(select ' + K_CMENDAHPatCN + ' from ' + K_CMENDBAllHistPatientsTable +
        ' where ' + K_CMENDAHPatID + '=' + 'Q.' + K_CMENDBSTFPatID + ') as PatCN,' +
        'S.' + K_CMENDBSFHSTS  +
        ' FROM (SELECT ' +
          K_CMENDBSFHDstLocID + ',' +
          K_CMENDBSFHSrcLocID + ',' +
          K_CMENDBSFHSlideID  + ',' +
          K_CMENDBSFQHProvID  + ',' +
          K_CMENDBSFHSTS +
          ' FROM ' + K_CMENDBSyncFilesHistTable + ',' + K_CMENDBSyncFilesQueryHistTable +
          ' WHERE ' +
            K_CMENDBSFHSTS + ' >= ' + EDADBDateTimeToSQL( WDB ) + ' AND ' +
            K_CMENDBSFHSTS + ' <= ' + EDADBDateTimeToSQL( WDE ) + ' AND ' +
//            K_CMENDBSFHSTS + ' >= DATETIME(''' + K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss.zzz' ) + ''') and ' +
//            K_CMENDBSFHSTS + ' <= DATETIME(''' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss.zzz' ) + ''') and ' +
            '('+K_CMENDBSFHFlags+' & 0x18) = 16 and ' +
            K_CMENDBSFQHElemID + '=' + K_CMENDBSFHQElemID +
            ') S LEFT OUTER JOIN (SELECT ' +
            K_CMENDBSTFSlideID + ',' + K_CMENDBSTFPatID +
            ' FROM ' + K_CMENDBSlidesTable + ') Q' +
            ' ON S.' + K_CMENDBSFHSlideID + ' = Q.' + K_CMENDBSTFSlideID;
    //
    // end of Prepare Report SQL
    ////////////////////////////

      with CurDSet1 do
      begin
        ReportPhase := 1;
        Connection := LANDBConnection;
        ExtDataErrorCode := K_eeDBSelect;
        SQL.Text := SQLText;
        Filtered := false;
        Open;
        ReportPhase := 2;
        SetLength( ReportDataSMatr, RecordCount + 1 );
        SetLength( ReportDataSMatr[0], 7 );
        ReportDataSMatr[0][0] := 'Date';
        ReportDataSMatr[0][1] := 'Time';
        ReportDataSMatr[0][2] := 'Location receiver';
        ReportDataSMatr[0][3] := 'Location sender';
        ReportDataSMatr[0][4] := 'Patient Card #/ID';
        ReportDataSMatr[0][5] := 'Object ID';
        ReportDataSMatr[0][6] := 'User';
        First;

      // Get  Selected Data
        i := 1;
        while not EOF do
        begin
          MatrRInd := i;
          MatrCInd := 0;
          SetLength( ReportDataSMatr[i], 7 );

          WDT := TDateTimeField(FieldList.Fields[9]).Value;
          //***** Date
          ReportDataSMatr[i][0] := K_DateTimeToStr( WDT, 'dd.mm.yyyy' );

          //***** Time
          MatrCInd := 1;
          ReportDataSMatr[i][1] := K_DateTimeToStr( WDT, 'hh:nn:ss AM/PM' );

          //***** Location receiver
          MatrCInd := 2;
          if FieldList.Fields[2].IsNull then
          begin
            WStr := K_CMGetLocationDetails( FieldList.Fields[0].AsInteger );
            if K_StrStartsWith( 'LocID=', WStr ) then
            begin
              WStr := Copy( WStr, 4, Length(WStr) );
              WStr[3] := ' ';
            end;
            ReportDataSMatr[i][2] := WStr;
          end
          else
            ReportDataSMatr[i][2] := K_CMEDAGetDBStringValue(Fields[2]);
//            ReportDataSMatr[i][2] := N_AnsiToString(Fields[2].AsString);
//            EDAGetStringFieldValue(FieldList.Fields[2]);

          //***** Location sender
          MatrCInd := 3;
          if FieldList.Fields[3].IsNull then
          begin
            WStr := K_CMGetLocationDetails( FieldList.Fields[1].AsInteger );
            if K_StrStartsWith( 'LocID=', WStr ) then
            begin
              WStr := Copy( WStr, 4, Length(WStr) );
              WStr[3] := ' ';
            end;
            ReportDataSMatr[i][3] := WStr;
          end
          else
            ReportDataSMatr[i][3] := K_CMEDAGetDBStringValue(Fields[3]);
//            ReportDataSMatr[i][3] := N_AnsiToString(Fields[3].AsString);
//            EDAGetStringFieldValue(FieldList.Fields[3]);

          //***** Patient Card #/ID
          MatrCInd := 4;
          if FieldList.Fields[4].IsNull then
            ReportDataSMatr[i][4] := '  (-)'
          else
          begin
            if FieldList.Fields[8].IsNull then
              ReportDataSMatr[i][4] := 'ID ' + FieldList.Fields[4].AsString
            else
              ReportDataSMatr[i][4] := 'Card # ' + K_CMEDAGetDBStringValue(Fields[8]);
//              ReportDataSMatr[i][4] := 'Card # ' + N_AnsiToString(Fields[8].AsString);
//              EDAGetStringFieldValue(FieldList.Fields[8]);
          end;

          //***** Object ID
          MatrCInd := 5;
          ReportDataSMatr[i][5] := FieldList.Fields[5].AsString;

          //***** User
          MatrCInd := 6;
          ID := FieldList.Fields[6].AsInteger;
          if ID = -1 then
            ReportDataSMatr[i][6] := 'Appointment book'
          else if ID = -2 then
            ReportDataSMatr[i][6] := 'Central files storage'
          else begin
            if FieldList.Fields[7].IsNull then
              ReportDataSMatr[i][6] := K_CMGetProviderDetails( ID )
            else
              ReportDataSMatr[i][6] := K_CMEDAGetDBStringValue(Fields[7]);
//              ReportDataSMatr[i][6] := N_AnsiToString(Fields[7].AsString);
//              EDAGetStringFieldValue(FieldList.Fields[7]);
          end;
          Inc(i);
          Next;
        end;
        Close;
      end;
      ReportDetailes := 'Objects copying failure from ' +
           K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss AM/PM' ) +
           ' to ' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss AM/PM' );
  //    ReportDetailes := 'Objects copying failure from ' +
  //         K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss' ) +
  //         ' to ' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss' );
      ReportPhase := 3;
      PrepareRAFrameByDataSMatr( ReportDetailes );
      FrRAEdit.RAFCArray[0].TextPos := Ord(K_ppCenter);
      FrRAEdit.RAFCArray[1].TextPos := Ord(K_ppCenter);
      FrRAEdit.RAFCArray[5].TextPos := Ord(K_ppDownRight);

      Screen.Cursor := SavedCursor;

      ReportPhase := 4;
      ShowModal;
    except
      on E: Exception do
      begin
        DumpError( 'Failures', ReportDataSMatr );
        raise Exception.Create('Failures Report  ERROR >> ' + E.Message);
      end;
    end;
  end;
end; // TK_FormCMEFSyncInfo.BtFailuresClick

//******************************* TK_FormCMEFSyncInfo.BtSuccessClick ***
// BtSuccess Click Handler
//
//  Resulting Strings Matrix according to Params is prepared
//  And Dialog with Rusulting Data is shown
//
procedure TK_FormCMEFSyncInfo.BtSuccessClick(Sender: TObject);
var
  i, ID : Integer;
  SQLText : string;
  WDT : TDateTime;
  WDB : TDateTime;
  WDE : TDateTime;
  SavedCursor: TCursor;
  WStr : string;
begin

  if K_CMEDDBVersion < 12 then
  begin
    K_CMShowMessageDlg( //sysout
        ' Is not implemented now ', mtInformation );
    Exit;
  end;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  with TK_CMEDDBAccess(K_CMEDAccess),
       TK_FormCMReportShow.Create(Application) do
  begin
//    BaseFormInit ( nil, 'K_FormCMReportShow' );
    BaseFormInit( nil, 'K_FormCMReportShow', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    try
      ReportPhase := 0;
      MatrCInd := -1;
      MatrRInd := -1;
//      BaseFormInit ( nil ); // ???
    ////////////////////////////
    // Prepare Report SQL
    //
      if not ChBLastSyncSession.Checked then
      begin
      // Use Given Time Interval
        WDB := Int(DTPFrom.DateTime);
        WDE := Int(DTPTO.DateTime + 1) - 1/(24*3600*1000);
      end else
      begin
      // Use Sync Session Interval
        WDT := EDAEMGetFSyncSessionTime( WDB, WDE );
        if WDB > WDT then
          WDB := WDB - 1;
        WDE := WDT;
{
        WDT := EDAGetSyncTimestamp();
        WDB := DateOf(WDT) - 1 + TimeOf(SyncSessionStartTS);
        WDB := Min( DateOf(WDT), WDB );
        WDE := WDT;
}
      end;

      SQLText := 'SELECT ' +  // Display the last data available
        'S.' + K_CMENDBSFHDstLocID + ',' +
        'S.' + K_CMENDBSFHSrcLocID + ',' +
        '(select ' + K_CMENDAHLocCapt + ' from ' + K_CMENDBAllHistLocationsTable +
        ' where ' + K_CMENDAHLocID + '=' + 'S.' + K_CMENDBSFHDstLocID + '),' +
        '(select ' + K_CMENDAHLocCapt + ' from ' + K_CMENDBAllHistLocationsTable +
        ' where ' + K_CMENDAHLocID + '=' + 'S.' + K_CMENDBSFHSrcLocID + '),' +
        'Q.' + K_CMENDBSTFPatID  + ',' +
        'S.' + K_CMENDBSFHSlideID  + ',' +
        'S.' + K_CMENDBSFQHProvID  + ',' +
        '(select ' + K_CMENDAHProvCapt + ' from ' + K_CMENDBAllHistProvidersTable +
        ' where ' + K_CMENDAHProvID + '=' + 'S.' + K_CMENDBSFQHProvID + ') as UserCapt,' +
        '(select ' + K_CMENDAHPatCN + ' from ' + K_CMENDBAllHistPatientsTable +
        ' where ' + K_CMENDAHPatID + '=' + 'Q.' + K_CMENDBSTFPatID + ') as PatCN,' +
        'S.' + K_CMENDBSFHSTS  +
        ' FROM (SELECT ' +
          K_CMENDBSFHDstLocID + ',' +
          K_CMENDBSFHSrcLocID + ',' +
          K_CMENDBSFHSlideID  + ',' +
          K_CMENDBSFQHProvID  + ',' +
          K_CMENDBSFHSTS +
          ' FROM ' + K_CMENDBSyncFilesHistTable + ',' + K_CMENDBSyncFilesQueryHistTable +
          ' WHERE ' +
            K_CMENDBSFHSTS + ' >= ' + EDADBDateTimeToSQL( WDB ) + ' AND ' +
            K_CMENDBSFHSTS + ' <= ' + EDADBDateTimeToSQL( WDE ) + ' AND ' +
//            K_CMENDBSFHSTS + ' >= DATETIME(''' + K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss.zzz' ) + ''') and ' +
//            K_CMENDBSFHSTS + ' <= DATETIME(''' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss.zzz' ) + ''') and ' +
            '('+K_CMENDBSFHFlags+' & 0x18) = 8 and ' +
            K_CMENDBSFQHElemID + '=' + K_CMENDBSFHQElemID +
            ') S LEFT OUTER JOIN (SELECT ' +
            K_CMENDBSTFSlideID + ',' + K_CMENDBSTFPatID +
            ' FROM ' + K_CMENDBSlidesTable + ') Q' +
            ' ON S.' + K_CMENDBSFHSlideID + ' = Q.' + K_CMENDBSTFSlideID;
    //
    // end of Prepare Report SQL
    ////////////////////////////

      with CurDSet1 do
      begin
        ReportPhase := 1;
        Connection := LANDBConnection;
        ExtDataErrorCode := K_eeDBSelect;
        SQL.Text := SQLText;
        Filtered := false;
        Open;
        ReportPhase := 2;
        SetLength( ReportDataSMatr, RecordCount + 1 );
        SetLength( ReportDataSMatr[0], 7 );
        ReportDataSMatr[0][0] := 'Date';
        ReportDataSMatr[0][1] := 'Time';
        ReportDataSMatr[0][2] := 'Location receiver';
        ReportDataSMatr[0][3] := 'Location sender';
        ReportDataSMatr[0][4] := 'Patient Card #/ID';
        ReportDataSMatr[0][5] := 'Object ID';
        ReportDataSMatr[0][6] := 'User';
        First;

      // Get  Selected Data
        i := 1;
        while not EOF do
        begin
          MatrRInd := i;
          MatrCInd := 0;
          SetLength( ReportDataSMatr[i], 7 );

          WDT := TDateTimeField(FieldList.Fields[9]).Value;
          //***** Date
          ReportDataSMatr[i][0] := K_DateTimeToStr( WDT, 'dd.mm.yyyy' );

          //***** Time
          MatrCInd := 1;
          ReportDataSMatr[i][1] := K_DateTimeToStr( WDT, 'hh:nn:ss AM/PM' );

          //***** Location receiver
          MatrCInd := 2;
          if FieldList.Fields[2].IsNull then
          begin
            WStr := K_CMGetLocationDetails( FieldList.Fields[0].AsInteger );
            if K_StrStartsWith( 'LocID=', WStr ) then
            begin
              WStr := Copy( WStr, 4, Length(WStr) );
              WStr[3] := ' ';
            end;
            ReportDataSMatr[i][2] := WStr;
          end
          else
            ReportDataSMatr[i][2] := K_CMEDAGetDBStringValue(Fields[2]);
//            ReportDataSMatr[i][2] := N_AnsiToString(Fields[2].AsString);
//            EDAGetStringFieldValue(FieldList.Fields[2]);

          //***** Location sender
          MatrCInd := 3;
          if FieldList.Fields[3].IsNull then
          begin
            WStr := K_CMGetLocationDetails( FieldList.Fields[1].AsInteger );
            if K_StrStartsWith( 'LocID=', WStr ) then
            begin
              WStr := Copy( WStr, 4, Length(WStr) );
              WStr[3] := ' ';
            end;
            ReportDataSMatr[i][3] := WStr;
          end
          else
            ReportDataSMatr[i][3] := K_CMEDAGetDBStringValue(Fields[3]);
//            ReportDataSMatr[i][3] := N_AnsiToString(Fields[3].AsString);
//            EDAGetStringFieldValue(FieldList.Fields[3]);

          //***** Patient Card #/ID
          MatrCInd := 4;
          if FieldList.Fields[4].IsNull then
            ReportDataSMatr[i][4] := '  (-)'
          else
          begin
            if FieldList.Fields[8].IsNull then
              ReportDataSMatr[i][4] := 'ID ' + FieldList.Fields[4].AsString
            else
              ReportDataSMatr[i][4] := 'Card # ' + K_CMEDAGetDBStringValue(Fields[8]);
//              ReportDataSMatr[i][4] := 'Card # ' + N_AnsiToString(Fields[8].AsString);
//              EDAGetStringFieldValue(FieldList.Fields[8]);
          end;

          //***** Object ID
          MatrCInd := 5;
          ReportDataSMatr[i][5] := FieldList.Fields[5].AsString;

          //***** User
          MatrCInd := 6;
          ID := FieldList.Fields[6].AsInteger;
          if ID = -1 then
            ReportDataSMatr[i][6] := 'Appointment book'
          else if ID = -2 then
            ReportDataSMatr[i][6] := 'Central files storage'
          else begin
            if FieldList.Fields[7].IsNull then
              ReportDataSMatr[i][6] := K_CMGetProviderDetails( ID )
            else
              ReportDataSMatr[i][6] := K_CMEDAGetDBStringValue(Fields[7]);
//              ReportDataSMatr[i][6] := N_AnsiToString(Fields[7].AsString);
//              EDAGetStringFieldValue(FieldList.Fields[7]);
          end;
          Inc(i);
          Next;
        end;
        Close;
      end;
      ReportDetailes := 'Objects copying success from ' +
           K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss AM/PM' ) +
           ' to ' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss AM/PM' );
  //    ReportDetailes := 'Objects copying success from ' +
  //         K_DateTimeToStr( WDB, 'yyyy-mm-dd hh:nn:ss' ) +
  //         ' to ' + K_DateTimeToStr( WDE, 'yyyy-mm-dd hh:nn:ss' );
      ReportPhase := 3;
      PrepareRAFrameByDataSMatr( ReportDetailes );
      FrRAEdit.RAFCArray[0].TextPos := Ord(K_ppCenter);
      FrRAEdit.RAFCArray[1].TextPos := Ord(K_ppCenter);
      FrRAEdit.RAFCArray[5].TextPos := Ord(K_ppDownRight);

      Screen.Cursor := SavedCursor;

      ReportPhase := 4;
      ShowModal;
    except
      on E: Exception do
      begin
        DumpError( 'Success', ReportDataSMatr );
        raise Exception.Create('Success Report  ERROR >> ' + E.Message);
      end;
    end;
  end;
end; // TK_FormCMEFSyncInfo.BtSuccessClick

//******************************************** TK_FormCMEFSyncInfo.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TK_FormCMEFSyncInfo.CurStateToMemIni;
begin
  inherited;
  N_IntToMemIni( BFSelfName, 'TSInd', PageControl.TabIndex );
  N_BoolToMemIni( BFSelfName, 'LastSyncSession', ChBLastSyncSession.Checked );
  N_DblToMemIni( BFSelfName, 'DTPFrom', '%g', DTPFrom.DateTime );
  N_DblToMemIni( BFSelfName, 'DTPTo', '%g', DTPTo.DateTime );


end; // TK_FormCMEFSyncInfo.CurStateToMemIni

//******************************************** TK_FormCMEFSyncInfo.MemIniToCurState ***
// Load Self Size and Position from N_Forms section, BFSelfName string
//
procedure TK_FormCMEFSyncInfo.MemIniToCurState;
begin
  inherited;
  PageControl.TabIndex := N_MemIniToInt( BFSelfName, 'TSInd', PageControl.TabIndex );
  ChBLastSyncSession.Checked := N_MemIniToBool( BFSelfName, 'LastSyncSession', TRUE );
  DTPFrom.DateTime := N_MemIniToDbl( BFSelfName, 'DTPFrom', Now() - 0.5 );
  DTPTo.DateTime :=   N_MemIniToDbl( BFSelfName, 'DTPTo', Now() + 0.5 );
end; // TK_FormCMEFSyncInfo.MemIniToCurState

//******************************************** TK_FormCMEFSyncInfo.DumpError ***
// Error Dump Routine
//
procedure TK_FormCMEFSyncInfo.DumpError( ARepName: string; ARSMatr: TN_ASArray );
const PhaseName : array [0..4] of string =
  ('SQL Text prepare',
   'SQL Request',
   'ResText prepare',
   'RAFrame prepare',
   'Report show');
begin

  N_Dump1Str( ARepName + ' Report  ERROR' );
  N_Dump1Str( format( '%s ReportPhase=%s Row=%d Col=%d', [ARepName, PhaseName[ReportPhase],MatrRInd,MatrCInd] ) );
  if (ReportPhase >= 2) and (MatrRInd > 0) then begin
    SetLength( ARSMatr, MatrRInd + 1 );
    RepSL := TStringList.Create;
    N_SaveSMatrToStrings2( ARSMatr, RepSL, smfTab );
    N_Dump1Strings ( RepSL, 4 );
    RepSL.Free;
  end
end; // TK_FormCMEFSyncInfo.DumpError

end.
