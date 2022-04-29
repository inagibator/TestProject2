unit K_FCMExportPPL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Grids,
  N_Types, N_BaseF,
  K_Types, K_CLib0, K_FPathNameFr;

type
  TK_FormCMExportPPL = class(TN_BaseForm)
    BtCancel: TButton;
    BtStart: TButton;
    PathNameFrame: TK_FPathNameFrame;
    BtSync: TButton;
    SGStateView: TStringGrid;
    LbInfo: TLabel;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure BtStartClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SGStateViewDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SGStateViewExit(Sender: TObject);
    procedure BtSyncClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    CurExportPath : string;
    SkipSelectedDraw : Boolean;
    SL, PatFilesList : TStringList;

    PatExp, ProvExp, LocExp : Integer;
    PrevPatExp, PrevProvExp, PrevLocExp : Integer;

    // Do Export Context
    ExportState : Integer;
    FNameDate : string;
    RepStr : string;
    AllCount, ExpCount, RCount : Integer;

    // Do Synchronize
    SynchState : Integer;
    SynchStep : Integer;
    LinkFileInd  : Integer;
    LinkDataType : Integer;
    FName : string;
    PatCount, AllPatCount : Integer;

    SavedCursor: TCursor;


    procedure OnPathChange();
    procedure RebuildExportInfoView();
    function  TestLinkFile( const APathName, AFileName : string; AScanLevel : Integer ) : TK_ScanTreeResult;
    function  TestPatientFile( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    procedure DoExportPPL();
    function  CopyFolderFiles( ASrcFolder, ADstFolder : string;
                               var AErrCount : Integer ): Integer;
    procedure DoSynchPPL();
  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMExportPPL: TK_FormCMExportPPL;

procedure K_CMExportPPLDlg( );

implementation

{$R *.dfm}
uses DB, ADODB,
     N_Lib0, N_Lib1, N_CMMain5F,
     K_CM0, K_CML1F, K_CLib;

//******************************************************** K_CMExportPPLDlg ***
// Files Export Dialog
//
procedure K_CMExportPPLDlg( );
//var
//  i : Integer;
begin
  K_FormCMExportPPL := TK_FormCMExportPPL.Create(Application);
  with K_FormCMExportPPL do
  begin
//    BaseFormInit(nil);
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal();
    K_FormCMExportPPL := nil;
  end;
end; // K_CMExportPPLDlg

//*********************************************** TK_FormCMExportPPL.OnPathChange ***
//
procedure TK_FormCMExportPPL.OnPathChange;
//var
//  Path : string;
begin
  CurExportPath := IncludeTrailingPathDelimiter(PathNameFrame.TopName);
  SL := TStringList.Create;

  K_ScanFilesTree( CurExportPath, TestLinkFile, '*_links_????-??-??.xml' );

  if not BtSync.Enabled and (SL.Count > 0) then
    BtSync.Enabled := TRUE;
              
  SL.Free();
end; // TK_FormCMExportPPL.OnPathChange

//*********************************************** TK_FormCMExportPPL.FormCreate ***
//
procedure TK_FormCMExportPPL.FormCreate(Sender: TObject);
begin
  inherited;
//  PathNameFrame.SelectCaption := K_CML1Form.LLLExpProcTexts.Items[1]; // 'Change Export folder';
//  PathNameFrame.OnChange := OnPathChange;
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  SGStateView.DefaultDrawing := FALSE;
{$IFEND CompilerVersion >= 26.0}

end; // TK_FormCMExportPPL.FormCreate

//*********************************************** TK_FormCMExportPPL.BtOKClick ***
//
procedure TK_FormCMExportPPL.BtStartClick(Sender: TObject);
begin
//
  if (SynchState > 0) or (ExportState > 0)  then Exit;
  if TK_CMEDDBAccess(K_CMEDAccess).EDACheckActiveInstances( K_CMEDAInstanceStandaloneFlag ) > 1 then
  begin
    //'Some users run CMS in alone mode. Press Yes to proceed'
    if (mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLExpImpNotSingleUser.Caption + ' ' +
                                     K_CML1Form.LLLPressYesToProceed.Caption,
                                      mtConfirmation )) then Exit;
  end;
  ExportState := 1;
  DoExportPPL();
end;

//*********************************************** TK_FormCMExportPPL.FormShow ***
//
procedure TK_FormCMExportPPL.FormShow(Sender: TObject);
var
  i, j : Integer;
  SelRect: TGridRect;
begin
// Moved From Form Create
  PathNameFrame.SelectCaption := K_CML1Form.LLLExpProcTexts.Items[1]; // 'Change Export folder';
  PathNameFrame.OnChange := OnPathChange;

  CurExportPath := PathNameFrame.mbPathName.Text;
  if CurExportPath = '' then
    PathNameFrame.AddNameToTop( K_GetDirPath( 'WrkFiles' ) );
//    PathNameFrame.AddNameToTop( K_GetDirPath( 'WrkFiles' ) );
  OnPathChange();
  SGStateView.Cells[0,1] := K_CML1Form.LLLExpImpRowNames.Items[0];// 'Patients';
  SGStateView.Cells[0,2] := K_CML1Form.LLLExpImpRowNames.Items[1];// 'Dentists';
  SGStateView.Cells[0,3] := K_CML1Form.LLLExpImpRowNames.Items[2];// 'Practices';
  SGStateView.Cells[1,0] := K_CML1Form.LLLExpColNames.Items[0];// 'Total';
  SGStateView.Cells[2,0] := K_CML1Form.LLLExpColNames.Items[1];// 'Not exported';
  SGStateView.Cells[3,0] := K_CML1Form.LLLExpColNames.Items[2];// 'Exported';
  SGStateView.Cells[4,0] := K_CML1Form.LLLExpColNames.Items[3];// 'Synchronized';
  for i := 1 to 4 do
    for j := 1 to 3 do
      SGStateView.Cells[i,j] := '0';

  RebuildExportInfoView();

  SelRect.Left := -1;
  SelRect.Right := -1;
  SelRect.Top := -1;
  SelRect.Bottom := -1;
  SGStateView.Selection := SelRect;
end; // TK_FormCMExportPPL.FormShow

//***********************************  TK_FormCMExportPPL.CurStateToMemIni  ***
//
procedure TK_FormCMExportPPL.CurStateToMemIni();
begin
  inherited;
  N_ComboBoxToMemIni( 'CMSExportPPLPathsHistory', PathNameFrame.mbPathName );
end; // end of TK_FormCMExportPPL.CurStateToMemIni

//***********************************  TK_FormCMExportPPL.MemIniToCurState  ******
//
procedure TK_FormCMExportPPL.MemIniToCurState();
begin
  inherited;
  N_MemIniToComboBox( 'CMSExportPPLPathsHistory', PathNameFrame.mbPathName );
end; // end of TK_FormCMExportPPL.MemIniToCurState

//***********************************  TK_FormCMExportPPL.SGStateViewDrawCell  ******
// Info String Grid onDraw handler
//
procedure TK_FormCMExportPPL.SGStateViewDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if SkipSelectedDraw then
  begin
    SkipSelectedDraw := FALSE;
    SGStateView.Canvas.Brush.Color := ColorToRGB(SGStateView.Color);
  end;
  K_CellDrawString( SGStateView.Cells[ACol,ARow], Rect, K_ppCenter, K_ppCenter, SGStateView.Canvas, 5, 0, 0 );
end; // procedure TK_FormCMExportPPL.SGStateViewDrawCell

//***********************************  TK_FormCMExportPPL.RebuildExportInfoView  ******
// Rebuild Export Info View
//
procedure TK_FormCMExportPPL.RebuildExportInfoView;
var
  SQLText : string;
begin
//
  N_Dump2Str( 'SAE>> RebuildExportInfoView Start' );
  with TK_CMEDDBAccess(K_CMEDAccess) do
  try
    PrevPatExp  := PatExp;
    PrevProvExp := ProvExp;
    PrevLocExp  := LocExp;

    with CurDSet1 do
    begin
      Connection := LANDBConnection;
      Filtered := FALSE;

    // Patients Total
      SQLText := 'select count(*) ' +
                  ' from ' + K_CMENDBAllPatientsTable +
                  ' where ' + ' (' + K_CMENDAPFlags + ' & 1) = 0';
      SQL.Text := SQLText;
      Open();
      SGStateView.Cells[1,1] := Fields[0].AsString;
      Close();

    // Patients UnExported
      if K_CMEDDBVersion >= 22 then
        SQL.Text := SQLText +
                 ' and ' + K_CMENDAPBridgeID + ' < 0' +
                 ' and '   + K_CMENDAPExpFlags + ' = 0'
      else
        SQL.Text := SQLText +
                 ' and ' + K_CMENDAPBridgeID + ' = 0';
      Open();
      SGStateView.Cells[2,1] := Fields[0].AsString;
      Close();

    // Patients Exported
      if K_CMEDDBVersion >= 22 then
        SQL.Text := SQLText +
                 ' and ' + K_CMENDAPBridgeID + ' < 0' +
                 ' and '   + K_CMENDAPExpFlags + ' = 1'
      else
        SQL.Text := SQLText +
                 ' and ' + K_CMENDAPBridgeID + ' < 0' ;
      Open();
      PatExp := Fields[0].AsInteger;
      SGStateView.Cells[3,1] := Fields[0].AsString;
      Close();

    // Providers Total
      SQLText := 'select count(*) ' +
                  ' from ' + K_CMENDBAllProvidersTable +
                  ' where ' + '(' + K_CMENDAUFlags + ' & 1) = 0';
      SQL.Text := SQLText;
      Open();
      SGStateView.Cells[1,2] := Fields[0].AsString;
      Close();

    // Providers UnExported
      if K_CMEDDBVersion >= 22 then
        SQL.Text := SQLText +
                 ' and ' + K_CMENDAUBridgeID + ' < 0' +
                 ' and '   + K_CMENDAUExpFlags + ' = 0'
      else
        SQL.Text := SQLText +
                 ' and ' + K_CMENDAUBridgeID + ' = 0';
      Open();
      SGStateView.Cells[2,2] := Fields[0].AsString;
      Close();

    // Providers Exported
      if K_CMEDDBVersion >= 22 then
        SQL.Text := SQLText +
                 ' and ' + K_CMENDAUBridgeID + ' < 0' +
                 ' and '   + K_CMENDAUExpFlags + ' = 1'
      else
        SQL.Text := SQLText +
                 ' and ' + K_CMENDAUBridgeID + ' < 0';
      Open();
      ProvExp := Fields[0].AsInteger;
      SGStateView.Cells[3,2] := Fields[0].AsString;
      Close();

    // Locations Total
      SQLText := 'select count(*) ' +
                  ' from ' + K_CMENDBAllLocationsTable +
                  ' where ' + '(' + K_CMENDALFlags + ' & 1) = 0';
      SQL.Text := SQLText;
      Open();
      SGStateView.Cells[1,3] := Fields[0].AsString;
      Close();

    // Locations UnExported
      if K_CMEDDBVersion >= 22 then
        SQL.Text := SQLText +
                 ' and ' + K_CMENDALBridgeID + ' < 0' +
                 ' and '   + K_CMENDALExpFlags + ' = 0'
      else
        SQL.Text := SQLText +
                 ' and ' + K_CMENDALBridgeID + ' = 0';
      Open();
      SGStateView.Cells[2,3] := Fields[0].AsString;
      Close();

    // Locations Exported
      if K_CMEDDBVersion >= 22 then
        SQL.Text := SQLText +
                 ' and ' + K_CMENDALBridgeID + ' < 0' +
                 ' and '   + K_CMENDALExpFlags + ' = 1'
      else
        SQL.Text := SQLText +
                 ' and ' + K_CMENDALBridgeID + ' < 0';
      Open();
      LocExp := Fields[0].AsInteger;
      SGStateView.Cells[3,3] := Fields[0].AsString;
      Close();
    end;
    BtSync.Enabled := (SGStateView.Cells[3,1] <> '0') or
                      (SGStateView.Cells[3,2] <> '0') or
                      (SGStateView.Cells[3,3] <> '0');

    BtStart.Enabled := BtSync.Enabled or
                       (SGStateView.Cells[2,1] <> '0') or
                       (SGStateView.Cells[2,2] <> '0') or
                       (SGStateView.Cells[2,3] <> '0');

  N_Dump1Str( 'SAE>> RebuildExportInfoView fin '+
    'Unexp='+SGStateView.Cells[2,1]+','+SGStateView.Cells[2,2]+','+ SGStateView.Cells[2,3]+','+
    'Exp='  +SGStateView.Cells[3,1]+','+SGStateView.Cells[3,2]+','+ SGStateView.Cells[3,3] );
  except
    on E: Exception do
    begin
      ExtDataErrorString := 'TK_FormCMExportPPL.RebuildExportInfoView ' + E.Message;
      CurDSet1.Close;
      ExtDataErrorCode := K_eeDBSelect;
      EDAShowErrMessage(TRUE);
    end;
  end;
end; // procedure TK_FormCMExportPPL.RebuildExportInfoView


//***********************************  TK_FormCMExportPPL.SGStateViewExit  ******
// Info String Grid onExit handler
//
procedure TK_FormCMExportPPL.SGStateViewExit(Sender: TObject);
begin
  SkipSelectedDraw := TRUE;
end; // procedure TK_FormCMExportPPL.SGStateViewExit

//*****************************************  TK_FormCMExportPPL.BtSyncClick ***
// BtSync onClick handler
//
procedure TK_FormCMExportPPL.BtSyncClick(Sender: TObject);
begin
  if (SynchState <> 0) or (ExportState <> 0)  then Exit;
  if TK_CMEDDBAccess(K_CMEDAccess).EDACheckActiveInstances( K_CMEDAInstanceStandaloneFlag ) > 1 then
  begin
    //'Some users run CMS in alone mode. Press Yes to proceed'
    if (mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLExpImpNotSingleUser.Caption + ' ' +
                                     K_CML1Form.LLLPressYesToProceed.Caption,
                                      mtConfirmation )) then Exit;
  end;

  N_Dump1Str( 'SAE>> Synchronization Start ' + CurExportPath );
  SL := TStringList.Create;

  K_ScanFilesTree( CurExportPath, TestLinkFile, '*_links_????-??-??.xml' );

  if SL.Count = 0 then
  begin
//    K_CMShowMessageDlg1( 'Nothing to do', mtWarning );
    K_CMShowMessageDlg1( K_CML1Form.LLLNothingToDo.Caption, mtWarning );
    SL.Free;
    Exit;
  end;

  SynchState := 1;
  LinkFileInd := 0;
  DoSynchPPL();

end; // procedure TK_FormCMExportPPL.BtSyncClick

//*********************************************** TK_FormCMExportPPL.CopyPatientFiles ***
// Copy Patient Files
//
//    Parameters
// ASrcFolder - files source folder
// ADstFolder - files destination folder
// AErrCount  - on result copy errors number,
// Result - Returns number of copied files
//
function  TK_FormCMExportPPL.CopyFolderFiles( ASrcFolder, ADstFolder : string;
                                              var AErrCount : Integer ): Integer;
var
 CopyRes : Integer;
 SrcFName, DstFName : string;
 IntFName : string;
 i, IntFPos : Integer;
 ErrMessage : string;
 BCount : Integer;

begin
  Result := 0;
  AErrCount := 0;
  if PatFilesList = nil then
    PatFilesList := TStringList.Create
  else
    PatFilesList.Clear;

  K_ScanFilesTree( ASrcFolder, TestPatientFile, '*.*' );
  if PatFilesList.Count = 0 then Exit;
  IntFPos := Length(ASrcFolder) + 1;
  BCount := AErrCount;
  AErrCount := 0;
  for i := 0 to PatFilesList.Count - 1 do
  begin
    SrcFName := PatFilesList[i];
    IntFName := Copy( SrcFName, IntFPos, Length(SrcFName) );
    DstFName := ADstFolder + IntFName;
    CopyRes := K_CopyFile( SrcFName, DstFName );
    if CopyRes = 0 then Inc( Result );
    if CopyRes < 4 then Continue;
    Inc( AErrCount );
    ErrMessage := '';
    case CopyRes of
    4: ErrMessage := format( 'Couldn''t copy file %s to folder %s. Press OK to proceed.',
                [ExtractFileName(DstFName),ExtractFilePath(DstFName)] );
    5: ErrMessage := format( 'Couldn''t create folder %s for file %s. Press OK to proceed.',
                [ExtractFilePath(DstFName),ExtractFileName(DstFName)] );
    end;
    if ErrMessage <> '' then
      K_CMShowMessageDlg( ErrMessage, mtError, [], FALSE, '', 10 );
    if (BCount > 0) and (AErrCount >= BCount) then Break;
  end;
end; // function TK_FormCMExportPPL.CopyFolderFiles

//*********************************************** TK_FormCMExportPPL.DoSynchPPL ***
//
procedure TK_FormCMExportPPL.DoSynchPPL();
var
  SNum : Integer;
  OldPatID, NewPatID : Integer;
  FPath, SrcPathSegm, DstPathSegm : string;
  ErrCount : Integer;
  PatFilesCount : Integer;
  PatLinkCount : Integer;

Label FilesLoop, TimerLoop, ContinueFilesLoop, ContinuePatLoop, PatLoop;

begin
//
  if ExportState <> 0 then Exit;

  if SynchState = 1 then
  begin
    SL.Sort();
    RepStr := '';
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
    LinkDataType := 0; // needed to prevent warning
    SynchState := 2;
  end;

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
    // Process Link Files
FilesLoop:
      if (LinkFileInd < SL.Count) or (SynchState > 2) then
      begin
        if SynchState = 2 then
        begin
          FName := SL[LinkFileInd];
          RepStr := RepStr + #13#10 + FName;
          Inc(LinkFileInd);
          N_Dump1Str( 'SAE>> Synch by file ' + FName );

        // Current SA Link Code
          with CurStoredProc1 do
          begin
            Connection := LANDBConnection;
            SynchStep := 1;
            // Select Proper Procedure Name
            if FName[1]= 'p' then // patients ...
              LinkDataType := 0
            else
            if FName[1]= 'd' then // dentists ...
              LinkDataType := 1
            else
            if FName[1]= 'l' then // practices ...
              LinkDataType := 2
            else
            begin
              K_CMShowMessageDlg( format(K_CML1Form.LLLExpWrongLinkFName.Caption, [FName]), mtWarning );
              goto FilesLoop;
            end;
            FNameDate := Copy( FName, Length(FName) - 13, 10 );

            LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, 1] );
            LbInfo.Refresh();

            // Exec Procedure
            ProcedureName := 'dba.cms_ImportLinkInfo';
            Parameters.Clear;
            TmpStrings.LoadFromFile( CurExportPath + FName );
            with Parameters.AddParameter do
            begin
              Name := '@xml_data';
              Direction := pdInput;
              DataType := ftString;
              Value := TmpStrings.Text;
            end;
            ExecProc;
          end; // with CurStoredProc1 do

TimerLoop:
          Inc(SynchState);
          Timer.Enabled := TRUE;
          Exit;
        end; // if SynchState = 2 then

        with CurSQLCommand1 do
        begin
          Connection := LANDBConnection;
          case LinkDataType of
          //////////////////
          // Patients
          //
          0: begin
            if SynchState = 3 then
            begin
            // Start Patients Loop
              with CurDSet2 do
              begin
                Connection := LANDBConnection;
                SQL.Text := 'SELECT A.' + K_CMENDAPBridgeID + ', P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBAllPatientsTable   + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDAPBridgeID + ' = P.' + K_CMENDILIOldID;
                Filtered := FALSE;
                Open();
                AllPatCount := RecordCount;
                if AllPatCount = 0 then
                begin
                  Close();
                  N_Dump2Str( 'SAE>> Empty Patients and LinkIDs join' );
                  goto ContinueFilesLoop;
                end;
                First();
              end;
              TmpStrings.Clear;
              SynchState := 4;
              N_Dump2Str( 'SAE>> Start Synch Patients Loop' );
              PatCount := 0;
            end;

            if SynchState = 4 then
            begin
            // Continue Patients Loop after Timer
              PatFilesCount := 0;
              PatLinkCount := 0;
PatLoop:
            // Continue Patients Loop without Timer
              with CurDSet2 do
              begin
                if not EOF then
                begin
                  OldPatID := Fields[0].AsInteger;
                  NewPatID := Fields[1].AsInteger;
                  Next;
                  N_Dump2Str( format( 'SAE>> Start PatID %d to %d', [OldPatID,NewPatID] ) );
                end // if not EOF then
                else
                begin
                  Close;
                  N_Dump2Str( 'SAE>> Finish Synch Patients Loop' );
                  if TmpStrings.Count > 0 then
                  begin
                  // Some errors where detected
                    K_CMShowMessageDlg( 'Some files moving errors were detected.' + #13#10 +
                                        'You should try to synchronized patient again.' + #13#10 +
                                        'Press OK to continue', mtWarning );
                    TmpStrings.SaveToFile( CurExportPath + 'LinkErrors_' + FNameDate + '.txt' );
                  end;

                  goto ContinueFilesLoop;
                end; // if EOF then
              end; // with CurDSet2 do
              SrcPathSegm := K_CMSlideGetPatientFilesPathSegm(OldPatID);
              DstPathSegm := K_CMSlideGetPatientFilesPathSegm(NewPatID);
              ErrCount := 1;

              SNum := CopyFolderFiles( SlidesImgRootFolder + SrcPathSegm,
                                 SlidesImgRootFolder + DstPathSegm,
                                 ErrCount );
              if PatFilesList.Count > 0 then
                N_Dump2Str( format( 'SAE>> Copy image files %d of %d', [SNum, PatFilesList.Count] ) );
              PatFilesCount := PatFilesCount + SNum;
              if ErrCount > 0 then
              begin
                TmpStrings.Add( format( 'Patient ID=%d was not synchronized by image files errors', [OldPatID]) );
                goto ContinuePatLoop;
              end;

              ErrCount := 1;
              SNum := CopyFolderFiles( SlidesMediaRootFolder + SrcPathSegm,
                                 SlidesMediaRootFolder + DstPathSegm,
                                 ErrCount );
              if PatFilesList.Count > 0 then
                N_Dump2Str( format( 'SAE>> Copy image files %d of %d', [SNum, PatFilesList.Count] ) );
              PatFilesCount := PatFilesCount + SNum;
              if ErrCount > 0 then
              begin
                TmpStrings.Add( format( 'Patient ID=%d was not synchronized by video files errors', [OldPatID]) );
                goto ContinuePatLoop;
              end;

              // Correct DB Tables
              with CurSQLCommand1 do
              begin
                LANDBConnection.BeginTrans;
                EDASAChangePatientBridgeID( OldPatID, NewPatID );
         {!!! this code is moved to EDASAChangePatientBridgeID  21-07-2014
                if K_CMSLiRegStatus = 2 then
                begin // Enterprise Mode

                  CommandText := 'UPDATE ' + K_CMENDBSyncFilesQueryTable +
                    ' SET '  + K_CMENDBSFQPatID + ' = ' +  IntToStr(NewPatID) +
                    ' WHERE ' + K_CMENDBSFQPatID + ' = ' +  IntToStr(OldPatID);
                  Execute;

                  CommandText := 'UPDATE ' + K_CMENDBSyncFilesQueryHistTable +
                    ' SET '  + K_CMENDBSFQHPatID + ' = ' +  IntToStr(NewPatID) +
                    ' WHERE ' + K_CMENDBSFQHPatID + ' = ' +  IntToStr(OldPatID);
                  Execute;

                end; // if K_CMSLiRegStatus = 2 then

                CommandText := 'UPDATE ' + K_CMENDBSessionsHistTable +
                  ' SET '  + K_CMENDBSessionsHTFPatID + ' = ' +  IntToStr(NewPatID) +
                  ' WHERE ' + K_CMENDBSessionsHTFPatID + ' = ' +  IntToStr(OldPatID);
                Execute;

                CommandText := 'UPDATE ' + K_CMENDBAllHistPatientsTable +
                  ' SET '  + K_CMENDAHPatID + ' = ' +  IntToStr(NewPatID) +
                  ' WHERE ' + K_CMENDAHPatID + ' = ' +  IntToStr(OldPatID);
                Execute;

                CommandText := 'UPDATE ' + K_CMENDBSlidesTable +
                  ' SET '  + K_CMENDBSTFPatID + ' = ' +  IntToStr(NewPatID) +
                  ' WHERE ' + K_CMENDBSTFPatID + ' = ' +  IntToStr(OldPatID);
                Execute;

                CommandText := 'UPDATE ' + K_CMENDBContextsTable +
                  ' SET '  + K_CMENDBCTFContID + ' = ' +  IntToStr(NewPatID) +
                  ' WHERE ' + K_CMENDBCTFContID     + ' = ' +  IntToStr(OldPatID) +
                  ' AND '   + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actPatIni));
                Execute;

                CommandText := 'UPDATE ' + K_CMENDBAllPatientsTable +
                  ' SET '  + K_CMENDAPBridgeID  + ' = ' +  IntToStr(NewPatID) +
                  ' WHERE ' + K_CMENDAPBridgeID + ' = ' +  IntToStr(OldPatID);
                Execute;
         }
              // Delete Copied Files
                FPath := SlidesImgRootFolder + SrcPathSegm;
                K_DeleteFolderFiles( FPath );
                RemoveDir( FPath );

                FPath := SlidesMediaRootFolder + SrcPathSegm;
                K_DeleteFolderFiles( FPath );
                RemoveDir( FPath );

                LANDBConnection.CommitTrans;
              end; // with CurSQLCommand1 do

            // Change Current Paient ID
              if CurPatID = OldPatID then
                CurPatID := NewPatID;

ContinuePatLoop:
              Inc(PatCount);
              Inc(PatLinkCount);
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[3], [100 * PatCount / AllPatCount] );
              LbInfo.Refresh();
              if (PatFilesCount < 50) and
                 (PatLinkCount / AllPatCount < 0.01) then
                goto PatLoop; // skip Timer if less then 50 files and less then 1% of patients are processed
              Timer.Enabled := TRUE;
              Exit;
            end;
          end;
          //
          // Patients
          //////////////////

          //////////////////
          // Providers
          //
          1: begin
            if SynchState = 3 then
            begin
              if K_CMSLiRegStatus = K_lrtEnterprise then
              begin // Enterprise Mode
                LANDBConnection.BeginTrans;

                N_Dump2Str( 'SAE>> Change ' + K_CMENDBSyncFilesQueryTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesQueryTable +
                  ' SET '  + K_CMENDBSFQProvID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesQueryTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFQProvID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SynchStep);

                N_Dump2Str( 'SAE>> Change ' + K_CMENDBSyncFilesQueryHistTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesQueryHistTable +
                  ' SET '  + K_CMENDBSFQHProvID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesQueryHistTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFQHProvID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SynchStep);

                N_Dump2Str( 'SAE>> Change ' + K_CMENDBLocsFAccessTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBLocsFAccessTable +
                  ' SET '  + K_CMENDBLFALocNewFProvID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBLocsFAccessTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBLFALocNewFProvID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SynchStep);

                goto TimerLoop;
                LANDBConnection.CommitTrans;
              end // if K_CMSLiRegStatus = 2 then
              else
                Inc(SynchState);
            end; // if SynchState = 3 then

            if SynchState = 4 then
            begin
              LANDBConnection.BeginTrans;

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBSessionsHistTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSessionsHistTable +
                ' SET '  + K_CMENDBSessionsHTFProvID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSessionsHistTable  + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSessionsHTFProvID + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBAllHistProvidersTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBAllHistProvidersTable +
                ' SET '  + K_CMENDAHProvID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBAllHistProvidersTable + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable   + ' P' +
                ' ON A.' + K_CMENDAHProvID + ' = P.' + K_CMENDILIOldID;
              Execute;

              LANDBConnection.CommitTrans;
              goto TimerLoop;
            end; // if SynchState = 4 then

            if SynchState = 5 then
            begin
              LANDBConnection.BeginTrans;

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBSlidesTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable +
                ' SET '  + K_CMENDBSTFSlideProvIDCr + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSlidesTable        + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSTFSlideProvIDCr + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBSlidesTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable +
                ' SET '  + K_CMENDBSTFSlideProvIDMod + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSlidesTable        + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSTFSlideProvIDMod + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBContextsTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBContextsTable +
                ' SET '   + K_CMENDBCTFContID + ' =  P.' +  K_CMENDILINewID +
                ' FROM '  + K_CMENDBContextsTable      + ' A' +
                ' JOIN '  + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON (A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actProvIni)) +
                    ' OR A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actProvInstIni)) +
                    ' OR A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actProvUD)) + ')'+
                  ' AND A.' + K_CMENDBCTFContID     + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              if (K_CMEDDBVersion >= 22) then
              begin
                N_Dump2Str( 'SAE>> Change ' + K_CMENDBAllPatientsTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBAllPatientsTable +
                  ' SET '  + K_CMENDAPProvID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBAllPatientsTable   + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                  ' ON A.' + K_CMENDAPProvID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SynchStep);
              end;

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBAllProvidersTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBAllProvidersTable +
                ' SET '  + K_CMENDAUBridgeID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBAllProvidersTable   + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDAUBridgeID + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              LANDBConnection.CommitTrans;
              goto TimerLoop;
            end; // if SynchState = 5 then

            with CurDSet2 do
            begin
            // Change Current Provider ID
              SQL.Text := 'select ' + K_CMENDILINewID +
              ' from ' +  K_CMENDBImportLinkIDsTable +
              ' where ' + K_CMENDILIOldID + ' = ' + IntToStr( CurProvID );
              Filtered := FALSE;
              Open;
              if RecordCount > 0 then
                CurProvID := Fields[0].AsInteger;
              Close;
            end; // with CurDSet2 do
//            LANDBConnection.CommitTrans;
          end; //  1: Providers
          //
          // Providers
          //////////////////

          //////////////////
          // Locations
          //
          2: begin
            if SynchState = 3 then
            begin
              if K_CMSLiRegStatus = K_lrtEnterprise then
              begin // Enterprise Mode
                LANDBConnection.BeginTrans;

                N_Dump2Str( 'SAE>> Change ' + K_CMENDBSyncFilesQueryTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesQueryTable +
                  ' SET '  + K_CMENDBSFQDstLocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesQueryTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFQDstLocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SynchStep);

                N_Dump2Str( 'SAE>> Change ' + K_CMENDBSyncFilesQueryHistTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesQueryHistTable +
                  ' SET '  + K_CMENDBSFQHDstLocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesQueryHistTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFQHDstLocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SynchStep);

                N_Dump2Str( 'SAE>> Change ' + K_CMENDBLocsFAccessTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBLocsFAccessTable +
                  ' SET '  + K_CMENDBLFALocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBLocsFAccessTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBLFALocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SynchStep);

                N_Dump2Str( 'SAE>> Change ' + K_CMENDBLocFilesInfoTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBLocFilesInfoTable +
                  ' SET '  + K_CMENDBLFILocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBLocFilesInfoTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBLFILocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SynchStep);

                N_Dump2Str( 'SAE>> Change ' + K_CMENDBSyncFilesHistTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesHistTable +
                  ' SET '  + K_CMENDBSFHDstLocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesHistTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFHDstLocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SynchStep);

                N_Dump2Str( 'SAE>> Change ' + K_CMENDBSyncFilesHistTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesHistTable +
                  ' SET '  + K_CMENDBSFHSrcLocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesHistTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFHSrcLocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SynchStep);
                LANDBConnection.CommitTrans;
                goto TimerLoop;

              end// if K_CMSLiRegStatus = 2 then
              else
                Inc(SynchState);
            end; // if SynchState = 3 then

            if SynchState = 4 then
            begin
              LANDBConnection.BeginTrans;

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBSessionsHistTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSessionsHistTable +
                ' SET '  + K_CMENDBSessionsHTFLocID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSessionsHistTable  + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSessionsHTFLocID + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBAllHistLocationsTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBAllHistLocationsTable +
                ' SET '  + K_CMENDAHLocID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBAllHistLocationsTable + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable   + ' P' +
                ' ON A.' + K_CMENDAHLocID + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              LANDBConnection.CommitTrans;
              goto TimerLoop;
            end; // if SynchState = 4 then

            if SynchState = 5 then
            begin
              LANDBConnection.BeginTrans;

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBSlidesTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable +
                ' SET '  + K_CMENDBSTFSlideLocIDCr + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSlidesTable        + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSTFSlideLocIDCr + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBSlidesTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable +
                ' SET '  + K_CMENDBSTFSlideLocIDMod + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSlidesTable        + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSTFSlideLocIDMod + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBContextsTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBContextsTable +
                ' SET '   + K_CMENDBCTFContID + ' =  P.' +  K_CMENDILINewID +
                ' FROM '  + K_CMENDBContextsTable      + ' A' +
                ' JOIN '  + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON (A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actLocIni)) +
                    ' OR A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actLocUD)) + ')'+
                  ' AND A.' + K_CMENDBCTFContID     + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              N_Dump2Str( 'SAE>> Change ' + K_CMENDBAllLocationsTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SynchStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBAllLocationsTable +
                ' SET '  + K_CMENDALBridgeID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBAllLocationsTable   + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDALBridgeID + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SynchStep);

              LANDBConnection.CommitTrans;
              goto TimerLoop;
            end; // if SynchState = 5 then

            with CurDSet2 do
            begin
            // Change Current Location ID
              SQL.Text := 'select ' + K_CMENDILINewID +
              ' from ' +  K_CMENDBImportLinkIDsTable +
              ' where ' + K_CMENDILIOldID + ' = ' + IntToStr( CurLocID );
              Filtered := FALSE;
              Open;
              if RecordCount > 0 then
                CurLocID := Fields[0].AsInteger;
              Close;
            end; // with CurDSet2 do
//            LANDBConnection.CommitTrans;
          end; // 2: Locations
          //
          // Locations
          //////////////////
          end; // case LinkDataType of
        end; // with CurSQLCommand1 do

ContinueFilesLoop:
        SynchState := 2;
        goto FilesLoop;
      end; // for i := 0 to SL.Count do

      SynchState := 0;

//      K_CMShowMessageDlg1( '  Linking Data from' +
//                           RepStr + #13#10 +
//                           '      is finished.', mtInformation );
      //'     Linking Data from %s'#13#10'        is finished.'
      K_CMShowMessageDlg1( format(K_CML1Form.LLLSynchFin.Caption, [RepStr]), mtInformation );

      LbInfo.Caption := '';
      LbInfo.Refresh();

      // Create Report
      RebuildExportInfoView();
      TmpStrings.Clear;
      TmpStrings.Add(';Exported;Synchronized');

      SNum := PrevPatExp - PatExp;
      TmpStrings.Add( format( 'Patients;%d;%d', [PrevPatExp, SNum] ) );
      SGStateView.Cells[4,1] := IntToStr(SNum);

      SNum := PrevProvExp - ProvExp;
      TmpStrings.Add( format( 'Dentists;%d;%d', [PrevProvExp, SNum] ) );
      SGStateView.Cells[4,2] := IntToStr(SNum);

      SNum := PrevLocExp - LocExp;
      TmpStrings.Add( format( 'Practices;%d;%d', [PrevLocExp, SNum] ) );
      SGStateView.Cells[4,3] := IntToStr(SNum);

      TmpStrings.SaveToFile( CurExportPath + 'Export_' + FNameDate + '.csv' );
      N_Dump1Str( 'SAE>> ExportSynch' );
      N_Dump1Strings( TmpStrings, 0 );

      Screen.Cursor := SavedCursor;
      SL.Free;
      N_Dump1Str( 'SAE>> Synchronization Fin' );
    except
      on E: Exception do
      begin
        Screen.Cursor := SavedCursor;
        ExtDataErrorString := 'TK_FormCMExportPPL.BtSyncClick ' + E.Message;
        SL.Free;
        CurDSet1.Close;
        ExtDataErrorCode := K_eeDBUpdate;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

end; // procedure TK_FormCMExportPPL.DoSynchPPL

//*********************************** TK_FormCMExportPPL.TimerTimer ******
//  onTimer handler
//
procedure TK_FormCMExportPPL.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := FALSE;
  if ExportState = 2 then DoExportPPL();
  if SynchState >= 2 then DoSynchPPL();

end; // procedure TK_FormCMExportPPL.TimerTimer

//*********************************************** TK_FormCMExportPPL.DoExportPPL ***
//
procedure TK_FormCMExportPPL.DoExportPPL();
var
  SQLText : string;
  ObjStr : string;
  PatProvID : Integer;
begin
//
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    if ExportState = 1 then
    begin
      SavedCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;
      RepStr := '';
      try
        N_Dump1Str( 'SAE>> Export Start ' + CurExportPath );

        Connection := LANDBConnection;
        Filtered := false;

        FNameDate := K_DateTimeToStr( EDAGetSyncTimestamp(), 'yyyy-mm-dd' );

    /////////////////////////////////////
    // Export Patients Data
    //
        ExpCount := 0;
        ExportState := 0;
        if (SGStateView.Cells[1,2] <> '0') or
           (SGStateView.Cells[1,3] <> '0') then
        begin
          ExportState := 2;
          if (SGStateView.Cells[1,2] <> '0') then
          begin
          //  Add Exported Flag
            ExtDataErrorCode := K_eeDBUpdate;
            with CurSQLCommand1 do
            begin
              Connection := LANDBConnection;
  //            CommandText := 'UPDATE ' + K_CMENDBAllPatientsTable +
  //              ' SET ' + K_CMENDAPBridgeID + ' = ' + K_CMENDAPBridgeID + ' - 1' +
  //              ' WHERE ' + K_CMENDAPBridgeID + ' <= 0';
              if K_CMEDDBVersion >= 22 then
                SQLText := ' SET ' + K_CMENDAPExpFlags + ' = 1' +
                           ' WHERE ' +  K_CMENDAPBridgeID + ' < 0' +
                           ' AND (' + K_CMENDAPFlags + ' & 1) = 0'
              else
                SQLText := ' SET ' + K_CMENDAPBridgeID + ' = - 1' +
                           ' WHERE ' + K_CMENDAPBridgeID + ' <= 0' +
                           ' AND (' + K_CMENDAPFlags + ' & 1) = 0';

              CommandText := 'UPDATE ' + K_CMENDBAllPatientsTable + SQLText;
              Execute;
            end;
          end; // if (SGStateView.Cells[1,2] <> '0')
          N_Dump2Str( 'SAE>> Set Exported Patients ExpFlags to 1' );

          if K_CMEDDBVersion >= 22 then
            SQLText := ' WHERE ' +  K_CMENDAPBridgeID + ' < 0' +
                       ' AND ' + K_CMENDAPExpFlags + ' = 1' +
                       ' AND (' + K_CMENDAPFlags + ' & 1) = 0' +
                       ' AND ' + K_CMENDAUBridgeID + ' = ' + K_CMENDAPProvID
          else
            SQLText := ' WHERE ' + K_CMENDAPBridgeID + ' = -1' +
                       ' AND (' + K_CMENDAPFlags + ' & 1) = 0';

          SQL.Text := 'select count(*) from ' + K_CMENDBAllPatientsTable + ',' +
                                                K_CMENDBAllProvidersTable +
                                                SQLText;
          Open;
          AllCount := Fields[0].AsInteger;
          Close;
          N_Dump2Str( 'SAE>> Get All Exported Patients Counter ' + IntToStr(AllCount) );

{
          SQLText := 'SELECT TOP 1000' +
          K_CMENDAPID + ',' +          //0
          K_CMENDAPSurname + ',' +     //1
          K_CMENDAPFirstname  + ',' +  //2
          K_CMENDAPMiddle  + ',' +     //3
          K_CMENDAPTitle  + ',' +      //4
          K_CMENDAPGender  + ',' +     //5
          K_CMENDAPCardNum  + ',' +    //6
          K_CMENDAPDOB  + ',' +        //7
          K_CMENDAPProvID + ',' +      //8
          K_CMENDAPAddr1  + ',' +      //9
          K_CMENDAPAddr2  + ',' +      //10
          K_CMENDAPSuburb  + ',' +     //11
          K_CMENDAPPostCode  + ',' +   //12
          K_CMENDAPState  + ',' +      //13
          K_CMENDAPPhone1  + ',' +     //14
          K_CMENDAPPhone2  + ',' +     //15
          K_CMENDAUBridgeID +',' +     //16
          K_CMENDAPBridgeID +          //17
          ' FROM ' + K_CMENDBAllPatientsTable + ',' + K_CMENDBAllProvidersTable +
          ' WHERE ' + K_CMENDAPBridgeID + ' = -1' +
          ' AND '+ K_CMENDAUID + ' = ' + K_CMENDAPProvID;

//          ' AND '+ K_CMENDAUID + ' = ' + K_CMENDAPProvID +
//          ' ORDER BY ' + K_CMENDAPID;
}
          if AllCount = 0 then
          // No Patients to Export
            ExportState := 4
          else
          begin
          // Prep patients export loop
            if K_CMEDDBVersion >= 22 then
            begin
              SQL.Text := 'SELECT TOP 1000 ' +
              K_CMENDAPID + ',' +          //0
              K_CMENDAPSurname + ',' +     //1
              K_CMENDAPFirstname  + ',' +  //2
              K_CMENDAPMiddle  + ',' +     //3
              K_CMENDAPTitle  + ',' +      //4
              K_CMENDAPGender  + ',' +     //5
              K_CMENDAPCardNum  + ',' +    //6
              K_CMENDAPDOB  + ',' +        //7
              K_CMENDAPProvID + ',' +      //8
              K_CMENDAPAddr1  + ',' +      //9
              K_CMENDAPAddr2  + ',' +      //10
              K_CMENDAPSuburb  + ',' +     //11
              K_CMENDAPPostCode  + ',' +   //12
              K_CMENDAPState  + ',' +      //13
              K_CMENDAPPhone1  + ',' +     //14
              K_CMENDAPPhone2  + ',' +     //15
              K_CMENDAUID +                //16
              ' FROM ' + K_CMENDBAllPatientsTable + ',' + K_CMENDBAllProvidersTable +
              ' WHERE ' + K_CMENDAPBridgeID + ' < 0' +
              ' AND ' + K_CMENDAPExpFlags + ' = 1' +
              ' AND (' + K_CMENDAPFlags + ' & 1) = 0' +
              ' AND ' + K_CMENDAUBridgeID + ' = ' + K_CMENDAPProvID;
            end
            else
            begin
              SQLText := K_CMENDAPBridgeID + ' = -1';
              SQL.Text := 'SELECT TOP 1000 ' +
              K_CMENDAPID + ',' +          //0
              K_CMENDAPSurname + ',' +     //1
              K_CMENDAPFirstname  + ',' +  //2
              K_CMENDAPMiddle  + ',' +     //3
              K_CMENDAPTitle  + ',' +      //4
              K_CMENDAPGender  + ',' +     //5
              K_CMENDAPCardNum  + ',' +    //6
              K_CMENDAPDOB  + ',' +        //7
              K_CMENDAPProvID + ',' +      //8
              K_CMENDAPAddr1  + ',' +      //9
              K_CMENDAPAddr2  + ',' +      //10
              K_CMENDAPSuburb  + ',' +     //11
              K_CMENDAPPostCode  + ',' +   //12
              K_CMENDAPState  + ',' +      //13
              K_CMENDAPPhone1  + ',' +     //14
              K_CMENDAPPhone2  + ',' +     //15
              K_CMENDAUBridgeID +          //16
              ' FROM ' + K_CMENDBAllPatientsTable + ',' + K_CMENDBAllProvidersTable +
              ' WHERE ' + K_CMENDAPBridgeID + ' = -1' +
              ' AND (' + K_CMENDAPFlags + ' & 1) = 0' +
              ' AND '+ K_CMENDAUID + ' = ' + K_CMENDAPProvID;
            end;

            TmpStrings.Clear;
            TmpStrings.Add( '<patients>' );
          end;
        end;
      except
        on E: Exception do
        begin
          Screen.Cursor := SavedCursor;
          ExportState := 0;
          ExtDataErrorString := 'TK_FormCMExportPPL.DoExportPPL 1 ' + E.Message;
          CurDSet1.Close;
          ExtDataErrorCode := K_eeDBSelect;
          EDAShowErrMessage(TRUE);
        end;
      end;
    end; // if ExportState = 1 then

    if ExportState = 2 then
    begin
      try
        while TRUE do
        begin
          Open;
          RCount := RecordCount;
          ExpCount := ExpCount + RCount;
          LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[2], [ExpCount, 100.0 * ExpCount / AllCount] );
          LbInfo.Refresh();
          if RCount = 0 then
          begin
            Close();
            ExportState := 3;
            Break;
          end;
          while not EOF do
          begin

            ObjStr :=
                'PatID="'+ FieldList.Fields[0].AsString + '" '
              + 'PatSurname="'+ K_EncodeXMLChars(K_CMEDAGetDBStringValue(Fields[1])) + '" '
//              + 'PatSurname="'+ K_EncodeXMLChars(N_AnsiToString(Fields[1].AsString)) + '" '
//              EDAGetStringFieldValue(Fields[1])) + '" '
              + 'PatFirstname="'+ K_EncodeXMLChars(EDAGetStringFieldValue(Fields[2])) + '" ';
            if not Fields[3].IsNull then
              ObjStr := ObjStr + 'PatMiddle="'+ K_EncodeXMLChars(EDAGetStringFieldValue(Fields[3])) + '" ';
            if not Fields[4].IsNull then
              ObjStr := ObjStr + 'PatTitle="'+ EDAGetStringFieldValue(Fields[4]) + '" ';
            if not Fields[5].IsNull then
              ObjStr := ObjStr + 'PatGender="'+ K_EncodeXMLChars(EDAGetStringFieldValue(Fields[5])) + '" ';
            if not Fields[6].IsNull then
              ObjStr := ObjStr + 'PatCardNum="'+ EDAGetStringFieldValue(Fields[6]) + '" ';
            if not Fields[7].IsNull then
  //              ObjStr := ObjStr + 'PatDOB="'+ (Fields[7].AsString) + '" ';
              ObjStr := ObjStr + 'PatDOB="'+ K_DateTimeToStr( TDateTimeField(Fields[7]).Value, 'yyyy"-"mm"-"dd' ) + '" ';

//

            if K_CMEDDBVersion >= 22 then
            begin
              PatProvID := Fields[8].AsInteger;
              if PatProvID > 0 then
              begin
                ObjStr := ObjStr + 'ProvID="'+ Fields[16].AsString + '" ' +
                                   'ProvBridgeID="'+ Fields[8].AsString + '" ';
              end
              else
                ObjStr := ObjStr + 'ProvID="'+ IntToStr(-100 - PatProvID) + '" ';
            end
            else
            begin
              ObjStr := ObjStr + 'ProvID="'+ Fields[8].AsString + '" ';
              if Fields[16].AsInteger > 0 then
                ObjStr := ObjStr + 'ProvBridgeID="'+ Fields[16].AsString + '" ';
            end;

            if not Fields[9].IsNull then
              ObjStr := ObjStr + 'PatAddr1="'+ K_EncodeXMLChars(EDAGetStringFieldValue(Fields[9])) + '" ';
            if not Fields[10].IsNull then
              ObjStr := ObjStr + 'PatAddr2="'+ K_EncodeXMLChars(EDAGetStringFieldValue(Fields[10])) + '" ';
            if not Fields[11].IsNull then
              ObjStr := ObjStr + 'PatSuburb="'+ K_EncodeXMLChars(EDAGetStringFieldValue(Fields[11])) + '" ';
            if not Fields[12].IsNull then
              ObjStr := ObjStr + 'PatPostCode="'+ Fields[12].AsString + '" ';
            if not Fields[13].IsNull then
              ObjStr := ObjStr + 'PatState="'+ EDAGetStringFieldValue(Fields[13]) + '" ';
            if not Fields[14].IsNull then
              ObjStr := ObjStr + 'PatPhone1="'+ K_EncodeXMLChars(Fields[14].AsString) + '" ';
            if not Fields[15].IsNull then
              ObjStr := ObjStr + 'PatPhone2="'+ K_EncodeXMLChars(Fields[15].AsString) + '" ';

            TmpStrings.Add( '<patient ' + ObjStr + ' />' );
            Next();
          end;
          UpdateBatch;
          Close();
          if ExpCount < AllCount then
          begin
          // Process Events
            Timer.Enabled := TRUE;
            Exit;
          end
          else
          begin
          // Break Loop
            ExportState := 3;
            Break;
          end;
        end;
      except
        on E: Exception do
        begin
          Screen.Cursor := SavedCursor;
          ExportState := 0;
          ExtDataErrorString := 'TK_FormCMExportPPL.DoExportPPL 2 ' + E.Message;
          CurDSet1.Close;
          ExtDataErrorCode := K_eeDBSelect;
          EDAShowErrMessage(TRUE);
        end;
      end;
    end; // if ExportState = 2 then

    if ExportState = 3 then
    begin
        TmpStrings.Add( '</patients>' );
        TmpStrings.SaveToFile( CurExportPath + 'patients_' + FNameDate + '.xml' );
        RepStr := RepStr + #13#10'patients_' + FNameDate + '.xml'
    end; // if ExportState = 3 then
    //
    // Export Patients Data
    /////////////////////////////////////

    ExportState := 0;
    try
      /////////////////////////////////////
      // Export Providers Data
      //
      if (SGStateView.Cells[3,2] <> '0') or (SGStateView.Cells[2,2] <> '0') then
      begin
        if (SGStateView.Cells[2,2] <> '0') then
        begin
        //  Add Exported Flag
          ExtDataErrorCode := K_eeDBUpdate;
          with CurSQLCommand1 do
          begin
            Connection := LANDBConnection;

            if K_CMEDDBVersion >= 22 then
              SQLText := ' SET ' + K_CMENDAUExpFlags + ' = 1' +
                         ' WHERE ' +  K_CMENDAUBridgeID + ' < 0' +
                         ' AND (' + K_CMENDAUFlags + ' & 1) = 0'
            else
              SQLText := ' SET ' + K_CMENDAUBridgeID + ' = ' + K_CMENDAUBridgeID + ' - 1' +
                         ' WHERE ' + K_CMENDAUBridgeID + ' <= 0' +
                         ' AND (' + K_CMENDAUFlags + ' & 1) = 0';

            CommandText := 'UPDATE ' + K_CMENDBAllProvidersTable + SQLText;

            Execute;
          end;
        end; // if (SGStateView.Cells[2,2] <> '0')

        SQLText := 'SELECT ' +
        K_CMENDAUID + ',' +          //0
        K_CMENDAUSurname + ',' +     //1
        K_CMENDAUFirstname  + ',' +  //2
        K_CMENDAUMiddle  + ',' +     //3
        K_CMENDAUTitle  + ',' +      //4
        K_CMENDAUAuthorities +       //5
        ' FROM ' + K_CMENDBAllProvidersTable +
        ' WHERE ' + K_CMENDAUBridgeID + ' < 0';
        if K_CMEDDBVersion >= 22 then
          SQLText := SQLText + ' AND ' + K_CMENDAUExpFlags + ' = 1';
//        ' WHERE ' + K_CMENDAUBridgeID + ' < 0' +
//        ' ORDER BY ' + K_CMENDAUID;

        SQL.Text := SQLText + ' AND (' + K_CMENDAUFlags + ' & 1) = 0';
        Open;
        if RecordCount > 0 then
        begin
          TmpStrings.Clear;
          TmpStrings.Add( '<providers>' );
          First();
          while not EOF do
          begin
            ObjStr :=
                'ProvID="'+ Fields[0].AsString + '" '
              + 'ProvSurname="'+ K_EncodeXMLChars(EDAGetStringFieldValue(Fields[1])) + '" '
              + 'ProvFirstname="'+ K_EncodeXMLChars(EDAGetStringFieldValue(Fields[2])) + '" ';
            if not Fields[3].IsNull then
              ObjStr := ObjStr + 'ProvMiddle="'+ K_EncodeXMLChars(EDAGetStringFieldValue(Fields[3])) + '" ';
            if not Fields[4].IsNull then
              ObjStr := ObjStr + 'ProvTitle="'+ EDAGetStringFieldValue(Fields[4]) + '" ';
            if not Fields[5].IsNull then
              ObjStr := ObjStr + 'ProvAuthorities="'+ Fields[5].AsString + '" ';

            TmpStrings.Add( '<provider ' + ObjStr + ' />' );
            Next();
          end;

          TmpStrings.Add( '</providers>' );
          TmpStrings.SaveToFile( CurExportPath + 'dentists_' + FNameDate + '.xml' );
          RepStr := RepStr + #13#10'dentists_' + FNameDate + '.xml'
        end;
        LbInfo.Caption := K_CML1Form.LLLExpProcTexts.Items[1];
        LbInfo.Refresh();

        Close();
      end; // if (SGStateView.Cells[2,2] <> '0') or  (SGStateView.Cells[2,3] <> '0')
      //
      // Export Providers Data
      /////////////////////////////////////

      /////////////////////////////////////
      // Export Locations Data
      //
      if (SGStateView.Cells[3,3] <> '0') or (SGStateView.Cells[2,3] <> '0') then
      begin
        if (SGStateView.Cells[2,3] <> '0') then
        begin
        //  Add Exported Flag
          ExtDataErrorCode := K_eeDBUpdate;
          with CurSQLCommand1 do
          begin
            Connection := LANDBConnection;

            if K_CMEDDBVersion >= 22 then
              SQLText := ' SET ' + K_CMENDALExpFlags + ' = 1' +
                         ' WHERE ' +  K_CMENDALBridgeID + ' < 0' +
                         ' AND (' + K_CMENDALFlags + ' & 1) = 0'
            else
              SQLText := ' SET ' + K_CMENDALBridgeID + ' = ' + K_CMENDALBridgeID + ' - 1' +
                         ' WHERE ' + K_CMENDALBridgeID + ' <= 0'+
                         ' AND (' + K_CMENDALFlags + ' & 1) = 0';

            CommandText := 'UPDATE ' + K_CMENDBAllLocationsTable + SQLText;
            Execute;
          end;
        end; // if (SGStateView.Cells[2,3] <> '0')

        SQLText := 'SELECT ' +
        K_CMENDALID + ',' +    //0
        K_CMENDALName +        //1
        ' FROM ' + K_CMENDBAllLocationsTable +
        ' WHERE ' + K_CMENDALBridgeID + ' < 0';
        if K_CMEDDBVersion >= 22 then
          SQLText := SQLText + ' AND ' + K_CMENDALExpFlags + ' = 1';
//        ' WHERE ' + K_CMENDALBridgeID + ' < 0' +
//        ' ORDER BY ' + K_CMENDALID;

        SQL.Text := SQLText + ' AND (' + K_CMENDALFlags + ' & 1) = 0';
        Open;
        if RecordCount > 0 then
        begin
          TmpStrings.Clear;
          TmpStrings.Add( '<locations>' );
          while not EOF do
          begin
            ObjStr :=
                'LocID="'+ FieldList.Fields[0].AsString + '" '
              + 'LocName="'+ K_EncodeXMLChars(EDAGetStringFieldValue(Fields[1])) + '" ';

            TmpStrings.Add( '<location ' + ObjStr + ' />' );
            Next();
          end;

          TmpStrings.Add( '</locations>' );
          TmpStrings.SaveToFile( CurExportPath + 'practices_' + FNameDate + '.xml' );
          RepStr := RepStr + #13#10'practices_' + FNameDate + '.xml'
        end;
        LbInfo.Caption := K_CML1Form.LLLExpProcTexts.Items[0];
        LbInfo.Refresh();

        Close();
      end; // if (SGStateView.Cells[3,2] <> '0') or  (SGStateView.Cells[3,3] <> '0')
      //
      // Export Locations Data
      /////////////////////////////////////

      //'     Exporting Data to %s'#13#10'        is finished.'
      K_CMShowMessageDlg1( format(K_CML1Form.LLLExpFin.Caption, [RepStr]), mtInformation );


      RebuildExportInfoView();
      LbInfo.Caption := '';
      LbInfo.Refresh();

      Screen.Cursor := SavedCursor;
      N_Dump1Str( 'SAE>> Export Fin' );
    except
      on E: Exception do
      begin
        Screen.Cursor := SavedCursor;
        ExportState := 0;
        ExtDataErrorString := 'TK_FormCMExportPPL.DoExportPPL 3 ' + E.Message;
        CurDSet1.Close;
        ExtDataErrorCode := K_eeDBSelect;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
end; // TK_FormCMExportPPL.DoExportPPL

//***********************************  TK_FormCMExportPPL.TestLinkFile  ******
// Test File while search Link files
//
function TK_FormCMExportPPL.TestLinkFile( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  if AFileName = '' then
    Result := K_tucSkipSubTree
  else
    SL.Add( AFileName );
end; // function TK_FormCMExportPPL.TestLinkFile

//***********************************  TK_FormCMExportPPL.TestPatientFile  ******
// Test patient Image or Video files
//
function TK_FormCMExportPPL.TestPatientFile( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  PatFilesList.Add( APathName + AFileName );
end; // function TK_FormCMExportPPL.TestLinkFile

//***********************************  TK_FormCMExportPPL.FormCloseQuery ******
// FormCloseQuery Event Handler
//
procedure TK_FormCMExportPPL.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := (ExportState = 0) and (SynchState = 0); // to prevent formclose during data export
  if not CanClose then Exit;
  PatFilesList.Free;
end;// procedure TK_FormCMExportPPL.FormCloseQuery

end.
