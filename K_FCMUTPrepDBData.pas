unit K_FCMUTPrepDBData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Grids,
  N_Types, N_BaseF,
  K_Types, K_CLib0, K_FPathNameFr, N_FNameFr;

type
  TK_FormCMUTPrepDBData = class(TN_BaseForm)
    BtCancel: TButton;
    PathNameFrame: TK_FPathNameFrame;
    BtSync: TButton;
    LbInfo: TLabel;
    FileNameFrame: TN_FileNameFrame;
    GBAll: TGroupBox;
    LbPatients: TLabel;
    LbProviders: TLabel;
    LbLocations: TLabel;
    LbServers: TLabel;
    LbClients: TLabel;
    LbAppContexts: TLabel;
    LbStatistics: TLabel;
    LbMedia: TLabel;
    LbCopyMedia: TLabel;
    ChBUnloadPat: TCheckBox;
    ChBUnloadProv: TCheckBox;
    ChBUnloadLoc: TCheckBox;
    ChBUnloadCont: TCheckBox;
    ChBUnloadStat: TCheckBox;
    ChBUnloadServ: TCheckBox;
    ChBUnloadClient: TCheckBox;
    ChBUnloadMedia: TCheckBox;
    DTPFrom: TDateTimePicker;
    Timer: TTimer;
    procedure FormShow(Sender: TObject);
//    procedure SGStateViewDrawCell(Sender: TObject; ACol, ARow: Integer;
//      Rect: TRect; State: TGridDrawState);
    procedure SGStateViewExit(Sender: TObject);
    procedure BtSyncClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DTPFromChange(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
    CurSyncPath : string;
    CurSyncFile : string;
//    DstFilesPath : string;
    FNameDate : string;
    SkipSelectedDraw : Boolean;
    SyncFilesList, PatFilesList : TStringList;

    ImgFList, VideoFList, Img3DFList,
    AImgFList, AVideoFList, AImg3DFList,
    AllExistedFList, AllNeededFList, AllArchivedFList : TStringList;

    // Do Synchronize
    SyncState : Integer;
    LinkFileInd  : Integer;

    PatD4WCount, PatSANormCount, PatSADelCount, PatAddedBeforeCount,
    PatAddedAfterCount, PatAddedD4WCount{, PatAddedHistCount} : Integer;
    SlidesD4WCount, SlidesSACount, SlidesWPatCount : Integer;
    SlidesD4WArchCount, SlidesSAArchCount : Integer;
    MergeRootPath : string; // MergeRootPath
    MergeInfoPath : string;
    MergeReportFName : string;
    StrMinDate : string;
    PatsOKFlag, SlidesOKFlag, FilesOKFlag : boolean;

    SavedCursor: TCursor;
    GetPatientPathName : function ( APatId : Integer ) : string of object;


    ProgressShow, ProgressShowPrev : Integer;
    ProgressFormat : string;
    FSBeforeExisted, FSBeforeNeeded, FSBeforeExtra, FSBeforeMissing, FSBeforeArchived : Integer;
    FSAfterExisted, FSAfterNeeded, FSAfterExtra, FSAfterMissing, FSAfterArchived : Integer;
    AllPatCount, TotalProc, TotalOf, TotalMedia, TotalFF : Integer;
    DelPatCount, DelMCount, DelFCount : Integer;
    NAPatCount, NAMCount, NAFCount : Integer;
    OldPatCount, OldMCount, OldFCount : Integer;

    SavedMergeRootFolder : string;

    procedure OnPathChange();
    procedure OnFileChange();
    procedure RebuildSyncInfoView();
    function  TestLinkFile( const APathName, AFileName : string; AScanLevel : Integer ) : TK_ScanTreeResult;
    function  TestPatientFile( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  CopyPatientFiles( ASrcFolder, ADstFolder : string;
                               var AErrCount : Integer ): Integer;
    function  GetPatientPathName1( APatId : Integer ) : string;
    function  GetPatientPathName2( APatId : Integer ) : string;
//    function  ExportMediaAndRemoveFromDB( const APathSegm : string; ASkipFilesCopy : Boolean;
//                                          AExportDIBs : Boolean = FALSE ) : string;
    function  DumpPatientsAndRemoveFromDB( const ATitle : string;
                                   out APatCount, AMCount, AFCount : Integer ) : string;
    procedure DoSynchPPL();
    procedure ShowProgress( AllCount, CurCount: Integer);
    procedure CalcDBInfo( ACalcAddInfo : Boolean );
  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMUTPrepDBData: TK_FormCMUTPrepDBData;

procedure K_CMUTPrepDBDataDlg( );
const MergeInfoFolderName = 'MergeInfo\';

implementation

{$R *.dfm}
uses DB, ADODB,
     N_Lib0, N_Lib1, N_CMMain5F, N_GRA2, N_Comp1,
     K_CM0, K_CM1, K_CML1F, K_CLib, K_RImage, K_UDT2, K_FCMSupport;

//***************************************************** K_CMUTPrepDBDataDlg ***
// Change Patients, Providers, Locations ID to syncronized it to PMS objects
//
procedure K_CMUTPrepDBDataDlg( );
begin
  // Add Stored Procedure "cms_ImportLinkPatientsInfo"
  N_Dump1Str( 'SAD>> K_CMUTSyncPPLDlg Start' );
  with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
  begin
    Connection := LANDBConnection;
    CommandText :=
      'DROP PROCEDURE IF EXISTS  "DBA"."cms_ImportLinkPatientsInfo";'#10 +
      'CREATE PROCEDURE "DBA"."cms_ImportLinkPatientsInfo"( in @xml_data xml )'#10 +
      'BEGIN' + Chr($0A) +
        'DELETE FROM "dba"."ImportLinkIDs";'#10 +
        'INSERT INTO "dba"."ImportLinkIDs"'#10 +
          '( "IOldID", "INewID" )' + Chr($0A) +
            'SELECT A.APBridgeID, S.PMSID FROM'#10 +
               '"dba"."AllPatients" A JOIN'#10 +
               '(SELECT CMSID, PMSID FROM OPENXML( @xml_data, ''/links/link'' )'#10 +
               'WITH ( CMSID integer ''@CMSID'', PMSID integer ''@PMSID'' )) S ON A.APID = S.CMSID;'#10 +
      'END;'#10 +
      'CREATE LOCAL TEMPORARY TABLE PAIDs2 (ID1 int, ID2 int) NOT TRANSACTIONAL;'#10 +
      'CREATE LOCAL TEMPORARY TABLE PAIDs  (ID int) NOT TRANSACTIONAL;'#10 +
      'CREATE LOCAL TEMPORARY TABLE PAIDs1 (ID int) NOT TRANSACTIONAL;'#10 +
      'CREATE LOCAL TEMPORARY TABLE PAIDs11(ID int PRIMARY KEY) NOT TRANSACTIONAL;'#10 +
      'CREATE LOCAL TEMPORARY TABLE SLIDs  (ID int) NOT TRANSACTIONAL;'#10 +
      'CREATE LOCAL TEMPORARY TABLE SEIDs  (ID int) NOT TRANSACTIONAL;';
    Execute;
  end;

  K_FormCMUTPrepDBData := TK_FormCMUTPrepDBData.Create(Application);
  with K_FormCMUTPrepDBData do
  begin
//    BaseFormInit(nil);
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
//{$IF CompilerVersion >= 26.0} // Delphi >= XE5
//    SGStateView.DefaultDrawing := FALSE;
//{$IFEND CompilerVersion >= 26.0}

    ImgFList   := TStringList.Create;
    VideoFList := TStringList.Create;
    Img3DFList := TStringList.Create;

    AImgFList   := TStringList.Create;
    AVideoFList := TStringList.Create;
    AImg3DFList := TStringList.Create;

    AllExistedFList := TStringList.Create;
    AllNeededFList  := TStringList.Create;
    AllArchivedFList:= TStringList.Create;

    N_Dump1Str( 'SAD>> before K_FormCMUTPrepDBData show' );
    ShowModal();
    N_Dump1Str( 'SAD>> after K_FormCMUTPrepDBData show' );

    ImgFList.Free;
    VideoFList.Free;
    Img3DFList.Free;

    AImgFList.Free;
    AVideoFList.Free;
    AImg3DFList.Free;

    AllExistedFList.Free;
    AllNeededFList.Free;
    AllArchivedFList.Free;
    K_FormCMUTPrepDBData := nil;
  end;

  // Remove Stored Procedure "cms_ImportLinkPatientsInfo"
  with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
  begin
    CommandText :=
      'DROP PROCEDURE IF EXISTS  "DBA"."cms_ImportLinkPatientsInfo";'#10 +
      'DROP TABLE IF EXISTS PAIDs2;'#10+
      'DROP TABLE IF EXISTS PAIDs1;'#10+
      'DROP TABLE IF EXISTS PAIDs11;'#10+
      'DROP TABLE IF EXISTS PAIDs;'#10+
      'DROP TABLE IF EXISTS SLIDs;'#10+
      'DROP TABLE IF EXISTS SEIDs;';
    Execute;
  end;
  N_Dump1Str( 'SAD>> K_CMUTSyncPPLDlg Fin' );

end; // procedure K_CMUTPrepDBDataDlg

//*********************************************** TK_FormCMUTPrepDBData.OnPathChange ***
//
procedure TK_FormCMUTPrepDBData.OnPathChange;
begin
  MergeRootPath := '';
  if PathNameFrame.TopName <> '' then
    MergeRootPath := IncludeTrailingPathDelimiter(PathNameFrame.TopName);

{
    PatSANormCount, PatSADelCount : Integer;
    SlidesD4WCount : Integer;
    if not PathNameFrame.Enabled and
       (SlidesD4WCount = 0)  and
       (PatSADelCount  = 0) then
    begin
      PathNameFrame.Enabled := TRUE;
      PathNameFrame.mbPathName.Text = SavedMergeRootFolder;
      BtSync.Enabled := (SavedMergeRootFolder <> '');
    end
}
  BtSync.Enabled := (MergeRootPath <> '') and
                    (not FileNameFrame.Enabled or
                    ((CurSyncFile <> '') or ((SyncFilesList <> nil) and (SyncFilesList.Count > 0))));
end; // TK_FormCMUTPrepDBData.OnPathChange

//******************************************* TK_FormCMUTPrepDBData.OnFileChange ***
//
procedure TK_FormCMUTPrepDBData.OnFileChange;
begin
  CurSyncFile := FileNameFrame.mbFileName.Text;
  CurSyncPath := ExtractFilePath(CurSyncFile);
  if SyncFilesList = nil then
    SyncFilesList := TStringList.Create
  else
    SyncFilesList.Clear;
  if CurSyncPath <> '' then
    K_ScanFilesTree( CurSyncPath, TestLinkFile, '*_links_????-??-??.xml' )
  else
    SyncFilesList.Clear;

  BtSync.Enabled := (MergeRootPath <> '') and
                    ((CurSyncFile <> '') or (SyncFilesList.Count > 0));

end; // TK_FormCMUTPrepDBData.OnFileChange

//*********************************************** TK_FormCMUTPrepDBData.FormShow ***
//
procedure TK_FormCMUTPrepDBData.FormShow(Sender: TObject);
//var
//  SelRect: TGridRect;
begin
{
  SGStateView.Cells[0,1] := K_CML1Form.LLLExpImpRowNames.Items[0];// 'Patients';
  SGStateView.Cells[0,2] := K_CML1Form.LLLExpImpRowNames.Items[1];// 'Dentists';
  SGStateView.Cells[0,3] := K_CML1Form.LLLExpImpRowNames.Items[2];// 'Practices';
  SGStateView.Cells[1,0] := K_CML1Form.LLLExpColNames.Items[0];// 'Total';
  SGStateView.Cells[2,0] := 'Linked';// 'Synchronized';

  SGStateView.Cells[0,1] := 'Deleted';
  SGStateView.Cells[0,2] := 'Old';
  SGStateView.Cells[0,3] := 'NA';
  SGStateView.Cells[0,4] := 'Linking';

  SGStateView.Cells[0,0] := 'Process';
  SGStateView.Cells[1,0] := 'Patients';
  SGStateView.Cells[2,0] := 'Media Objects';

  SGStateView.Cells[1,1] := '0';
  SGStateView.Cells[1,2] := '0';
  SGStateView.Cells[1,3] := '0';
  SGStateView.Cells[1,4] := '0';

  SGStateView.Cells[2,1] := '0 of 0';
  SGStateView.Cells[2,2] := '0 of 0';
  SGStateView.Cells[2,3] := '0 of 0';
  SGStateView.Cells[2,4] := '0 of 0';
}
  CalcDBInfo( TRUE );
  Timer.Enabled := (SlidesD4WArchCount > 0) or (SlidesSAArchCount > 0);

{
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    Connection := LANDBConnection;
    Filtered := FALSE;

  // Slides of D4W patients
    SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable +
    ' where ' + K_CMENDBSTFPatID + ' > 0';
    Open();
    SlidesD4WCount := Fields[0].AsInteger;
    Close();

  // Slides of SA patients
    SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable +
    ' where ' + K_CMENDBSTFPatID + ' < -100';
    Open();
    SlidesSACount := Fields[0].AsInteger;
    Close();

    SlidesD4WArchCount := 0;
    SlidesSAArchCount := 0;
    if K_CMEDDBVersion >= 41 then
    begin
      SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable +
      ' where ' + K_CMENDBSTFPatID + ' > 0 and ' + K_CMENDBSTFSlideThumbnail + ' is NULL' ;
      Open();
      SlidesD4WArchCount := Fields[0].AsInteger;
      SlidesD4WCount := SlidesD4WCount - SlidesD4WArchCount;
      Close();

      SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable +
      ' where ' + K_CMENDBSTFPatID + ' < -100 and ' + K_CMENDBSTFSlideThumbnail + ' is NULL' ;
      Open();
      SlidesSAArchCount := Fields[0].AsInteger;
      SlidesSACount := SlidesSACount - SlidesSAArchCount;
      Close();
    end;

  // All SA + D4W patients
    SQL.Text := 'select count(*) from ' + K_CMENDBAllPatientsTable;
    Open();
    PatD4WCount := Fields[0].AsInteger;
    Close();

  // All SA patients
    SQL.Text := 'select count(*) from ' + K_CMENDBAllPatientsTable +
    ' where ' + K_CMENDAPBridgeID + ' < -100';

    Open();
    PatSANormCount := Fields[0].AsInteger;
    PatD4WCount := PatD4WCount - PatSANormCount;
    Close();

  // Del SA patients
    SQL.Text := 'select count(*) from ' + K_CMENDBAllPatientsTable +
    ' where ' + K_CMENDAPFlags + ' > 0';
    Open();
    PatSADelCount := Fields[0].AsInteger;
    PatSANormCount := PatSANormCount - PatSADelCount;
    Close();

  end; // with CurDSet1 do
}
  RebuildSyncInfoView();
{
  SelRect.Left := -1;
  SelRect.Right := -1;
  SelRect.Top := -1;
  SelRect.Bottom := -1;
  SGStateView.Selection := SelRect;
}
  BtSync.Enabled := FALSE;

  if SlidesD4WCount = 0 then  // Clear Link file history value and file select disabled
  begin
    FileNameFrame.Enabled := FALSE;
    FileNameFrame.bnBrowse_1.Enabled := FALSE;
    FileNameFrame.Label1.Enabled := FALSE;
    FileNameFrame.mbFileName.Text := '';
  end
  else
  begin
    FileNameFrame.OnChange := OnFileChange;
    OnFileChange();
  end;

  PathNameFrame.SelectCaption := 'Change new root folder'; // 'Change new files  folder';
  PathNameFrame.OnChange := OnPathChange;
  PathNameFrame.SetEnabledAll( (SlidesD4WCount > 0) or (PatSADelCount > 0) or (DTPFrom.Checked) );
  if PathNameFrame.Enabled then
    OnPathChange()
  else
  begin
    SavedMergeRootFolder := PathNameFrame.mbPathName.Text;
    PathNameFrame.mbPathName.Text := '';
  end;

  DTPFromChange(DTPFrom);

end; // TK_FormCMUTPrepDBData.FormShow

//***********************************  TK_FormCMUTPrepDBData.CurStateToMemIni  ***
//
procedure TK_FormCMUTPrepDBData.CurStateToMemIni();
begin
  inherited;
  N_ComboBoxToMemIni( 'CMSSyncPPLPathsHistory', PathNameFrame.mbPathName );
  N_ComboBoxToMemIni( 'CMSSyncPPLFilesHistory', FileNameFrame.mbFileName );
  N_BoolToMemIni( 'CMSUnloadDBData', 'DTPFromEnabled', DTPFrom.Checked );
  N_StringToMemIni( 'CMSUnloadDBData', 'DTPFrom', K_DateTimeToStr( DTPFrom.Date, 'dd.mm.yyyy' ) );
end; // end of TK_FormCMUTPrepDBData.CurStateToMemIni

//***********************************  TK_FormCMUTPrepDBData.MemIniToCurState  ******
//
procedure TK_FormCMUTPrepDBData.MemIniToCurState();
var
  WStr : string;
begin
  inherited;
  N_MemIniToComboBox( 'CMSSyncPPLPathsHistory', PathNameFrame.mbPathName );
  PathNameFrame.AddNameToTop( PathNameFrame.mbPathName.Text );

  N_MemIniToComboBox( 'CMSSyncPPLFilesHistory', FileNameFrame.mbFileName );
  FileNameFrame.AddFileNameToTop( FileNameFrame.mbFileName.Text );

  WStr := N_MemIniToString('CMSUnloadDBData', 'DTPFrom', '');
  if WStr = '' then
    DTPFrom.Date := 0.5
  else
    DTPFrom.Date := K_StrToDateTime( WStr );
  DTPFrom.Checked := N_MemIniToBool( 'CMSUnloadDBData', 'DTPFromEnabled', FALSE );
//  DTPFromChange(DTPFrom);

end; // end of TK_FormCMUTPrepDBData.MemIniToCurState
{
//***********************************  TK_FormCMUTPrepDBData.SGStateViewDrawCell  ******
// Info String Grid onDraw handler
//
procedure TK_FormCMUTPrepDBData.SGStateViewDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if SkipSelectedDraw then
  begin
    SkipSelectedDraw := FALSE;
    SGStateView.Canvas.Brush.Color := ColorToRGB(SGStateView.Color);
  end;
  K_CellDrawString( SGStateView.Cells[ACol,ARow], Rect, K_ppCenter, K_ppCenter, SGStateView.Canvas, 5, 0, 0 );
end; // procedure TK_FormCMUTPrepDBData.SGStateViewDrawCell
}
//***********************************  TK_FormCMUTPrepDBData.RebuildSyncInfoView  ******
// Rebuild Export Info View
//
procedure TK_FormCMUTPrepDBData.RebuildSyncInfoView;
begin
//
  Exit;
{
  N_Dump2Str( 'SAD>> RebuildSyncInfoView Start' );
  with TK_CMEDDBAccess(K_CMEDAccess) do
  try

    with CurDSet1 do
    begin
      Connection := LANDBConnection;
      Filtered := FALSE;

    // Patients Total
      SQL.Text := 'select count(*) ' +
                  ' from ' + K_CMENDBAllPatientsTable +
                  ' where ' + ' (' + K_CMENDAPFlags + ' & 1) = 0';
      Open();
      SGStateView.Cells[1,1] := Fields[0].AsString;
      Close();

    // Providers Total
      SQL.Text := 'select count(*) ' +
                  ' from ' + K_CMENDBAllProvidersTable +
                  ' where ' + '(' + K_CMENDAUFlags + ' & 1) = 0';
      Open();
      SGStateView.Cells[1,2] := Fields[0].AsString;
      Close();

    // Locations Total
      SQL.Text := 'select count(*) ' +
                  ' from ' + K_CMENDBAllLocationsTable +
                  ' where ' + '(' + K_CMENDALFlags + ' & 1) = 0';
      Open();
      SGStateView.Cells[1,3] := Fields[0].AsString;
      Close();

    end; // with CurDSet1 do


    N_Dump1Str( 'SAD>> RebuildSyncInfoView fin '+
      'Total='+SGStateView.Cells[1,1]+','+SGStateView.Cells[1,2]+','+ SGStateView.Cells[1,3]+','+
      'Sync=' +SGStateView.Cells[2,1]+','+SGStateView.Cells[2,2]+','+ SGStateView.Cells[2,3] );
  except
    on E: Exception do
    begin
      ExtDataErrorString := 'TK_FormCMUTPrepDBData.RebuildSyncInfoView ' + E.Message;
      CurDSet1.Close;
      ExtDataErrorCode := K_eeDBSelect;
      EDAShowErrMessage(TRUE);
    end;
  end;
}
end; // procedure TK_FormCMUTPrepDBData.RebuildSyncInfoView


//***********************************  TK_FormCMUTPrepDBData.SGStateViewExit  ******
// Info String Grid onExit handler
//
procedure TK_FormCMUTPrepDBData.SGStateViewExit(Sender: TObject);
begin
  SkipSelectedDraw := TRUE;
end; // procedure TK_FormCMUTPrepDBData.SGStateViewExit

//*****************************************  TK_FormCMUTPrepDBData.BtSyncClick ***
// BtSync onClick handler
//
procedure TK_FormCMUTPrepDBData.BtSyncClick(Sender: TObject);
begin
  if SyncState <> 0 then Exit;

  N_Dump1Str( 'SAD>> Synchronization Start ' + CurSyncPath );

  SyncState := 0;
  if FileNameFrame.Enabled then
  begin
    LinkFileInd := 0;
    if SyncFilesList.Count = 0 then
      LinkFileInd := -1     // single file - patients only
    else
      SyncFilesList.Sort(); // patients providers locations
  end
  else
    LinkFileInd := -1;

  BtSync.Enabled := FALSE;
  BtCancel.Enabled := FALSE;
  K_NotAddedStrings := TStringList.Create;
  DoSynchPPL();
  K_NotAddedStrings.Free();
  K_NotAddedStrings := nil;
  BtCancel.Enabled := TRUE;
  Self.Close();

end; // procedure TK_FormCMUTPrepDBData.BtSyncClick

//*********************************************** TK_FormCMUTPrepDBData.CopyPatientFiles ***
// Copy Patient Files
//
//    Parameters
// ASrcFolder - files source folder
// ADstFolder - files destination folder
// AErrCount  - on result copy errors number,
// Result - Returns number of copied files
//
function  TK_FormCMUTPrepDBData.CopyPatientFiles( ASrcFolder, ADstFolder : string;
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

  K_ScanFilesTree( ASrcFolder, TestPatientFile, '*.*', FALSE );
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
    if CopyRes = 0 then
    begin
      N_Dump2Str( SrcFName + ' >> ' + DstFName );
      Inc( Result );
    end;

    if CopyRes < 3 then Continue;
    Inc( AErrCount );
    ErrMessage := '';
    case CopyRes of
    3: ErrMessage := format( 'File %s is absent at %s.',
                [ExtractFileName(DstFName),ExtractFilePath(SrcFName)] );
    4: ErrMessage := format( 'Couldn''t copy file %s from %s to %s.',
                [ExtractFileName(DstFName),ExtractFilePath(SrcFName),ExtractFilePath(DstFName)] );
    5: ErrMessage := format( 'Couldn''t create folder %s for file %s from %s .',
                [ExtractFilePath(DstFName),ExtractFileName(DstFName),ExtractFilePath(SrcFName)] );
    end; // case CopyRes of

    if ErrMessage <> '' then
    begin
      K_CMEDAccess.TmpStrings.Add( '     ' + ErrMessage );
//      K_CMShowMessageDlg( ErrMessage, mtError, [], FALSE, '', 10 );
    end;
    Application.ProcessMessages();
    if (BCount > 0) and (AErrCount >= BCount) then Break;
  end; // for i := 0 to PatFilesList.Count - 1 do
end; // function TK_FormCMUTPrepDBData.CopyPatientFiles

function TK_FormCMUTPrepDBData.GetPatientPathName1( APatId: Integer): string;
var
  DOB : TDateTime;
  WStr : string;
begin
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet3 do
  begin
    Filtered := FALSE;
    Filter := K_CMENDAPBridgeID + '=' + IntToStr( APatId );
    Filtered := TRUE;
    Result := '';
    if RecordCount > 0 then
    begin
      WStr := Trim(Fields[1].AsString); // Sirname
      if WStr <> '' then
        Result := WStr;

      WStr := Trim(Fields[2].AsString); // Firstname
      if WStr <> '' then
        Result := Result + ' ' + WStr;

      if Result <> '' then
        Result := 'Name ' + Result;    

      DOB := Fields[3].AsDateTime;      // DOB
      if DOB <> 0 then
        Result := Result + ' DOB ' + K_DateTimeToStr( Fields[3].AsDateTime, 'dd-mm-yyyy');
    end;
  end;
end; // function TK_FormCMUTPrepDBData.GetPatientPathName1

function TK_FormCMUTPrepDBData.GetPatientPathName2( APatId: Integer): string;
begin
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet3 do
  begin
    Filtered := FALSE;
    Filter := K_CMENDAHPatID + '=' + IntToStr( APatId );
    Filtered := TRUE;
    Result := '';
    if RecordCount > 0 then
      Result := Trim(Fields[1].AsString); // Statistic Name
    if Result <> '' then
      Result := 'Name ' + Result;
  end;
end; // function TK_FormCMUTPrepDBData.GetPatientPathName2

{
//************************ TK_FormCMUTPrepDBData.ExportMediaAndRemoveFromDB ***
//
function TK_FormCMUTPrepDBData.ExportMediaAndRemoveFromDB( const APathSegm : string;
                                                        ASkipFilesCopy : Boolean;
                                                        AExportDIBs : Boolean = FALSE ) : string;
var
  ErrCount : Integer;
//  FName : string;

  WPatID, CopyRes : Integer;

  PatID  : Integer;

  CrDT, DTTaken : TDateTime;
  LocPath, SrcBasePath, DstPatPath, SSlideD, SrcFNamePref, CurSrcFName,
  CurDstFName, DstFNamePref, Img3DFName : string;
  WCMSDB : TN_CMSlideSDBF;   // Slide Fields stored as single DB field

  DIBObj : TN_DIBObj;

  SkipPatExport : Boolean;
  AllCount, DoneCount, PrevDoneCount, ProcCount, ProcShow, ProcShowPrev : Integer;

  function CopyFile() : Boolean;
  begin
    N_Dump2Str( format( 'SAD>> Export Data >> Copy %s to %s', [CurSrcFName,CurDstFName] ) );

    CopyRes := K_CopyFile( CurSrcFName, CurDstFName );
    Result := TRUE;
    if CopyRes = 3 then
    begin
      K_CMEDAccess.TmpStrings.Add( format( '     File %s does not exist', [CurSrcFName]) );
      Result := FALSE;
      Inc(ErrCount);
    end
    else
    if CopyRes = 4 then
    begin
      K_CMEDAccess.TmpStrings.Add( format( '     Copy %s to %s error', [CurSrcFName,CurDstFName]) );
      Result := FALSE;
      Inc(ErrCount);
    end;
  end; // function CopyFile

  function Copy3DFiles() : Boolean;
  begin
    N_Dump2Str( format( 'SAD>> Export Data >> Copy 3DFiles %s to %s', [CurSrcFName,CurDstFName] ) );
    Result := K_CopyFolderFiles( CurSrcFName, CurDstFName );
    if not Result then
      K_CMEDAccess.TmpStrings.Add( format( '     Copy 3DFiles %s to %s error', [CurSrcFName,CurDstFName]) );
  end; // function CopyFile

  procedure GetDIBFromFile;
  var
    PData : Pointer;
    FSize, DSize : Integer;
    RCode : TK_CMEDResult;
    UDDIB : TN_UDDIB;
  begin
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      DIBObj := nil;
      N_Dump2Str( 'SAD>> Export Data >> get DIB from ' + CurSrcFName );
      try
        RCode := EDASlideDataFromFile( PData, DSize, CurSrcFName, FSize );
      except
        on E: Exception do
        begin
          N_Dump1Str( 'SAD>> Export Data >> Image File Error >> ' + E.Message );
          RCode := K_edFails;
        end;
      end; // except
      if (RCode = K_edOK) and (DSize > 0) then
      begin
        UDDIB := K_CMCreateUDDIBBySData( PData, DSize, EDAFreeBuffer );
        if UDDIB <> nil then
        begin
          try
            // Check Load Possibility
            TN_UDDIB(UDDIB).LoadDIBObj();
            DIBObj := UDDIB.DIBObj;
            UDDIB.DIBObj := nil;
          except
            on E: Exception do begin
              N_Dump1Str( 'SAD>> Export Data >> LoadDIBObj error >> ' + E.Message );
            end;
          end;
          UDDIB.Free();
        end
        else
          N_Dump1Str( 'SAD >> Export Data >> File data is corrupted.' );
      end;
    end;
  end; // procedure GetDIBFromFile

  function SaveDIBToFile : Boolean;
  var
    RIEncodingInfo : TK_RIFileEncInfo;
  begin
    K_RIObj.RIClearFileEncInfo( @RIEncodingInfo );
    RIEncodingInfo.RIFileEncType := rietPNG;
    N_Dump2Str( 'SAD>> Export Data >> save DIB to ' + CurDstFName );
    Result := K_RIObj.RISaveDIBToFile( DIBObj, CurDstFName, @RIEncodingInfo ) = rirOK;
    if not Result then
    begin
      N_Dump1Str( format( 'SAD >> Export Data >> Image save error >> ErrCode=%d %s',
                          [K_RIObj.RIGetLastNativeErrorCode(), CurDstFName] ) );
      K_DeleteFile( CurDstFName );
      // Try Save to TIF
      RIEncodingInfo.RIFileEncType := rietTIF;
      CurDstFName := ChangeFileExt( CurDstFName, '.tif' );
      Result := K_RIObj.RISaveDIBToFile( DIBObj, CurDstFName, @RIEncodingInfo ) = rirOK;
      if not Result then
        N_Dump1Str( format( 'SAD >> Export Data >> Image save error >> ErrCode=%d %s',
                            [K_RIObj.RIGetLastNativeErrorCode(), CurDstFName] ) );
    end; // if not Result then
    DIBObj.Free;
  end; // function SaveDIBToFile

  function ExportImage() : Boolean;
  begin
    if AExportDIBs then
    begin
      CurDstFName := CurDstFName + '.png';
      GetDIBFromFile();
      Result := DIBObj <> nil;
      if Result then
      begin
        with DIBObj.DIBInfo.bmi do
        begin
          biXPelsPerMeter := Round(WCMSDB.PixPermm * 1000);
          biYPelsPerMeter := biXPelsPerMeter;
        end;

        if not SaveDIBToFile() then
        begin
          K_CMEDAccess.TmpStrings.Add( format( '     Save Image %s from %s error', [CurDstFName,CurSrcFName]) );
          Result := FALSE;
          Inc(ErrCount);
        end
      end
      else
      begin
        K_CMEDAccess.TmpStrings.Add( format( '     Load Image from %s error', [CurSrcFName]) );
        Inc(ErrCount);
      end;
    end // AExportDIBs
    else
    begin // Copy File
      CurDstFName := CurDstFName + '.cmi';
      Result := CopyFile();
    end;

  end; // procedure ExportImage

Label ContinueFilesLoop, ContinuePatCopyLoop, ContinuePatExportLoop;

begin
//
  Result := '';
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
      with CurSQLCommand1 do
      begin

        ////////////////////////////////////////
        // Remove Data for Patients
        //
        CommandText :=
          // Prepare Removed Slides IDs
          'DELETE FROM SLIDs;'#10 +
          'INSERT SLIDs ( ID )' +
          ' SELECT A.' + K_CMENDBSTFSlideID +
          ' FROM ' + K_CMENDBSlidesTable + ' A' +
          ' JOIN PAIDs P ON A.' + K_CMENDBSTFPatID + ' = P.ID;'#10 +
          // Prepare Removed Sessions IDs
          'DELETE FROM SEIDs;'#10 +
          'INSERT SEIDs ( ID )' +
          ' SELECT A.' + K_CMENDBSessionsHTFSessionID +
          ' FROM ' + K_CMENDBSessionsHistTable + ' A' +
          ' JOIN PAIDs P ON A.' + K_CMENDBSessionsHTFPatID + ' = P.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Prepare remove info ' );
        Application.ProcessMessages;

        if not ASkipFilesCopy then
        begin
          ////////////////////////////////////////
          // Export Media Files for Patients
          //
          with CurDSet2 do
          begin
            Connection := LANDBConnection;
            SQL.Text := 'SELECT P.ID, A.' + K_CMENDBSTFPatID +                 // 0 1
            ', A.' + K_CMENDBSTFSlideDTCr + ', A.' + K_CMENDBSTFSlideSysInfo + // 2 3
            ', A.' + K_CMENDBSTFSlideStudyID + ', A.' + K_CMENDBSTFSlideDTTaken + // 4 5
            ' FROM (' + K_CMENDBSlidesTable + ' A' +
            ' JOIN SLIDs P ON A.' + K_CMENDBSTFSlideID  + ' = P.ID)' +
            ' ORDER BY A.' + K_CMENDBSTFPatID + ';';
            Filtered := FALSE;
            Open();
            AllCount := RecordCount;
            First();
            PatID := -1;
            DIBObj := nil;
            TmpStrings.Clear;
            ErrCount := 1;
            ProcCount := 0;
            DoneCount := 0;
            ProcShowPrev := -1;
            SkipPatExport := FALSE;
            while not EOF do
            begin
              if Fields[4].AsInteger < 0 then goto ContinuePatExportLoop; // Object is Study

              WPatID := Fields[1].AsInteger;
              if PatID <> WPatID then
              begin
              // New Patient - get patient details
                if ErrCount = 0 then // Remove Patient General Error Info
                  TmpStrings.Delete( TmpStrings.Count - 1 );
                ErrCount := 0;
                PatID := WPatID;
                DstPatPath := GetPatientPathName(PatID);
                if DstPatPath <> '' then
                  DstPatPath := DstPatPath + ' ';
                DstPatPath := DstPatPath + 'ID ' + IntToSTr(PatID);
                N_Dump2Str( format( 'SAD>> Export Data >> Process Patient "%s"', [DstPatPath] ) );
                LocPath := K_CMSlideGetPatientFilesPathSegm( PatID );
                // Add Patient General Error Info
                TmpStrings.Add( format( 'Patient %s >> Export Files Errors', [DstPatPath]) );
                DstPatPath := format( '%s%s\%s\',
                                      [MergeRootPath,APathSegm,DstPatPath] );
                SkipPatExport := not K_ForceDirPath(DstPatPath);
                if SkipPatExport then
                  TmpStrings.Add( format( '     Couldn''t create folder %s. Patient media objects are skiped.', [DstPatPath] ) );
              end; // if PatID <> WPatID then

              if SkipPatExport then goto ContinuePatExportLoop;

              SSlideD  := Fields[0].AsString;
              CrDT     := Fields[2].AsDateTime;
              DTTaken  := Fields[5].AsDateTime;
              DstFNamePref := format( '%sTaken %s ID %s',
                        [DstPatPath, SSlideD, K_DateTimeToStr(DTTaken, 'yyyy-mm-dd')] );
              K_CMEDAGetSlideSysFieldsData( K_CMEDAGetDBStringValue(Fields[3]), @WCMSDB );

              N_Dump2Str( 'SAD>> Export Data >> Process Slide ID=' + SSlideD );
              if cmsfIsMediaObj in WCMSDB.SFlags then
              begin
                SrcBasePath := SlidesMediaRootFolder;
                SrcFNamePref := SrcBasePath + LocPath + K_CMSlideGetFileDatePathSegm(CrDT) + K_CMSlideGetMediaFileNamePref(SSlideD);
                CurSrcFName := SrcFNamePref + WCMSDB.MediaFExt;
                CurDstFName := DstFNamePref + WCMSDB.MediaFExt;
                if CopyFile() then
                  Inc(DoneCount);
              end   // if cmsfIsMediaObj in WCMSDB.SFlags then
              else
              if cmsfIsImg3DObj in WCMSDB.SFlags then
              begin
                SrcBasePath := SlidesImg3DRootFolder;
                Img3DFName := K_CMSlideGetImg3DFolderName(SSlideD);
                SrcFNamePref := SrcBasePath + LocPath + K_CMSlideGetFileDatePathSegm(CrDT);
                CurSrcFName := SrcFNamePref + Img3DFName;
                CurDstFName := DstFNamePref + Img3DFName;
                if Copy3DFiles() then
                  Inc(DoneCount);
              end  // if cmsfIsImg3DObj in WCMSDB.SFlags then
              else
              begin // if Image then
                // Save Current Image
                SrcBasePath := SlidesImgRootFolder;
                SrcFNamePref := SrcBasePath + LocPath + K_CMSlideGetFileDatePathSegm(CrDT) + 'RF_' + K_CMSlideGetFileIDPathSegm(SSlideD);
                CurSrcFName := SrcFNamePref + '.cmi';
//                CurDstFName := DstFNamePref + '.png';
                CurDstFName := DstFNamePref;
                PrevDoneCount := DoneCount;
                if ExportImage() then Inc(DoneCount);
                if cmsfHasSrcImg in WCMSDB.SFlags then
                begin // Save Original Image
                  CurSrcFName := SrcFNamePref + 'r.cmi';
//                  CurDstFName := DstFNamePref + '_original.png';
                  CurDstFName := DstFNamePref + '_original';
                  if ExportImage() and (PrevDoneCount = DoneCount) then Inc(DoneCount);
                end;
              end; // if Image then

ContinuePatExportLoop:
              Inc(ProcCount);
              ProcShow := Round(100 * ProcCount / AllCount);
              if ProcShow > ProcShowPrev then
              begin
                LbInfo.Caption := format( 'Export ' + APathSegm +  ' media objects, %d%% done', [ProcShow] );
                ProcShowPrev := ProcShow;
              end;
              LbInfo.Refresh();
              Next();
              Application.ProcessMessages();
            end; // while not EOF do

            if ErrCount = 0 then // Remove Patient General Error Info
              TmpStrings.Delete( TmpStrings.Count - 1 );

            Close();

          end; // with CurDSet2 do

          Result := format( '%d of %d', [DoneCount, AllCount] );

          if TmpStrings.Count > 0 then
          begin
          // Some errors where detected
            CurSrcFName := CurSyncPath + 'ExportMedia' + APathSegm + 'FilesErrors_' + FNameDate + '.txt';
            TmpStrings.SaveToFile( CurSrcFName );
            K_CMShowMessageDlg( 'Some media files export errors were detected.' + #13#10 +
                                'All details are in ' + CurSrcFName + #13#10 +
                                'Press OK to continue', mtWarning );
          end; // if TmpStrings.Count > 0 then
          N_Dump1Str( 'SAD>> Export files fin >> ' + Result + ' media objects are exported' );
          //
          // Export Media Files for Patients
          ////////////////////////////////////////
        end; // if not ASkipFilesCopy then

          ////////////////////////////////////////
          // Remove Patients and corresponding Data from DB
          //
        // Remove Patients Data
        CommandText :=
          'DELETE FROM ' + K_CMENDBAllPatientsTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBAllPatientsTable +'.' + K_CMENDAPBridgeID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from ' + K_CMENDBAllPatientsTable );
        Application.ProcessMessages;

        // Remove Contexts
        CommandText := 'DELETE FROM ' + K_CMENDBContextsTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBContextsTable + '.' + K_CMENDBCTFContID + ' = PAIDs.ID' +
            ' AND ' + K_CMENDBContextsTable + '.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actPatIni)) + ';';
        Execute;
        N_Dump1Str( 'SAD>> Delete from ' + K_CMENDBContextsTable );
        Application.ProcessMessages;

        // Remove Slides Data
        CommandText := 'DELETE FROM ' + K_CMENDBSlidesTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBSlidesTable + '.' + K_CMENDBSTFPatID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from ' + K_CMENDBSlidesTable );
        Application.ProcessMessages;

        CommandText := 'DELETE FROM ' + K_CMENDBDelMarkedSlidesTable + ' FROM SLIDs ' +
          ' WHERE ' + K_CMENDBDelMarkedSlidesTable + '.' + K_CMENDMSlideID + ' = SLIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from ' + K_CMENDBDelMarkedSlidesTable );
        Application.ProcessMessages;

        // Remove Patient Statistics
        CommandText := 'DELETE FROM ' + K_CMENDBSessionsHistTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBSessionsHistTable + '.' + K_CMENDBSessionsHTFPatID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from ' + K_CMENDBSessionsHTFPatID );
        Application.ProcessMessages;

        CommandText := 'DELETE FROM ' + K_CMENDBAllHistPatientsTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBAllHistPatientsTable + '.' + K_CMENDAHPatID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from  ' + K_CMENDBAllHistPatientsTable );
        Application.ProcessMessages;

        // Remove Slides Statistics
        CommandText := 'DELETE FROM ' + K_CMENDBSlidesHistTable + ' FROM SLIDs ' +
          ' WHERE ' + K_CMENDBSlidesHistTable + '.' + K_CMENDBSlidesHTFSlideID + ' = SLIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from  ' + K_CMENDBSlidesHistTable );
        Application.ProcessMessages;

        // Remove Sessions Statistics
        CommandText := 'DELETE FROM ' + K_CMENDBSlidesNewHistTable + ' FROM SEIDs ' +
          ' WHERE ' + K_CMENDBSlidesNewHistTable + '.' + K_CMENDBSlidesNHTFSessionID + ' = SEIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from  ' + K_CMENDBSlidesNewHistTable );
        Application.ProcessMessages;
          //
          // Remove Patients and corresponding Data from DB
          ////////////////////////////////////////
        //
        // Remove Data for NA Patients
        ////////////////////////////////////////
      end; // with CurSQLCommand1 do

    except
      on E: Exception do
      begin
        Screen.Cursor := SavedCursor;
        ExtDataErrorString := 'TK_FormCMUTPrepDBData.BtSyncClick ' + E.Message;
        CurDSet1.Close;
        ExtDataErrorCode := K_eeDBUpdate;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

end; // procedure TK_FormCMUTPrepDBData.ExportMediaAndRemoveFromDB
}

//************************ TK_FormCMUTPrepDBData.DumpPatientsAndRemoveFromDB ***
//
function TK_FormCMUTPrepDBData.DumpPatientsAndRemoveFromDB( const ATitle : string;
                                   out APatCount, AMCount, AFCount : Integer ) : string;
var
  WPatID : Integer;
  PatID  : Integer;

  CrDT : TDateTime;
  DstPatPath, SSlideD, DumpInfo : string;
  WCMSDB : TN_CMSlideSDBF;   // Slide Fields stored as single DB field

  AllCount, FCount, ProcCount, PatCount : Integer;



Label ContinueFilesLoop, ContinuePatCopyLoop;

begin
//
  Result := '';
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
      with CurSQLCommand1 do
      begin

        ////////////////////////////////////////
        // Remove Data for Patients
        //
        CommandText :=
          // Prepare Removed Slides IDs
          'DELETE FROM SLIDs;'#10 +
          'INSERT SLIDs ( ID )' +
          ' SELECT A.' + K_CMENDBSTFSlideID +
          ' FROM ' + K_CMENDBSlidesTable + ' A' +
          ' JOIN PAIDs P ON A.' + K_CMENDBSTFPatID + ' = P.ID;'#10 +
          // Prepare Removed Sessions IDs
          'DELETE FROM SEIDs;'#10 +
          'INSERT SEIDs ( ID )' +
          ' SELECT A.' + K_CMENDBSessionsHTFSessionID +
          ' FROM ' + K_CMENDBSessionsHistTable + ' A' +
          ' JOIN PAIDs P ON A.' + K_CMENDBSessionsHTFPatID + ' = P.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Prepare remove info ' );
        Application.ProcessMessages;

        ////////////////////////////////////////
        // Dump Media Files for Patients
        //
        with CurDSet2 do
        begin
          Connection := LANDBConnection;
          Filtered := FALSE;
          SQL.Text := 'select count(*) from PAIDs';
          Open();
          APatCount := Fields[0].AsInteger;
          Close();

          SQL.Text := 'SELECT P.ID, A.' + K_CMENDBSTFPatID +                 // 0 1
          ', A.' + K_CMENDBSTFSlideDTCr + ', A.' + K_CMENDBSTFSlideSysInfo + // 2 3
          ', A.' + K_CMENDBSTFSlideStudyID +                                 // 4
          ' FROM (' + K_CMENDBSlidesTable + ' A' +
          ' JOIN SLIDs P ON A.' + K_CMENDBSTFSlideID  + ' = P.ID)' +
          ' ORDER BY A.' + K_CMENDBSTFPatID + ';';
          Filtered := FALSE;
          Open();
          AllCount := RecordCount;
          First();
          PatID := -1;
          TmpStrings.Clear;
          ProcCount := 0;
          FCount    := 0;
          PatCount  := 0;
          while not EOF do
          begin

            WPatID := Fields[1].AsInteger;
            if PatID <> WPatID then
            begin
            // New Patient - get patient details
              Inc( PatCount );
              if PatID <> -1 then
                N_Dump2Str( 'SAD>> Progressive total file and 3D folders =' + IntToStr(FCount) );
              PatID := WPatID;
              DumpInfo := format( '%s ID %d', [GetPatientPathName(PatID),PatID] );
              TmpStrings.Add( DumpInfo );
              N_Dump2Str( 'SAD>> ' + DumpInfo );
            end;

            Inc(FCount);
            if Fields[4].AsInteger < 0 then
              DstPatPath := 'Study'
            else
            begin // if Fields[4].AsInteger >= 0 then // not study
              K_CMEDAGetSlideSysFieldsData( K_CMEDAGetDBStringValue(Fields[3]), @WCMSDB );
              if cmsfIsMediaObj in WCMSDB.SFlags then
                DstPatPath := 'Video'
              else
              if cmsfIsImg3DObj in WCMSDB.SFlags then
                DstPatPath := 'Img3D'
              else
              begin // if Image then
                DstPatPath := 'Img';
                if cmsfHasSrcImg in WCMSDB.SFlags then
                begin // Save Original Image
                  DstPatPath := 'ImgOrig';
                  Inc(FCount);
                end;
              end; // if Image then
            end; // if Fields[4].AsInteger >= 0 then // not study

            SSlideD  := Fields[0].AsString;
            CrDT     := Fields[2].AsDateTime;
            DumpInfo := format( '%s ID=%s Created %s',
                      [DstPatPath, SSlideD, K_DateTimeToStr(CrDT, 'yyyy-mm-dd')] );

            N_Dump2Str( 'SAD>> ' + DumpInfo );
            TmpStrings.Add( DumpInfo );
            Inc(ProcCount);
//            ProgressFormat := 'Process media objects, %d%% done';
            ShowProgress( AllCount, ProcCount );
            Next();
//            Application.ProcessMessages();
          end; // while not EOF do

          Close();

        end; // with CurDSet2 do

        //
        // Dump Media Files for Patients
        ////////////////////////////////////////

//        APatCount := PatCount;
        AMCount   := ProcCount;
        AFCount   := FCount;
        DumpInfo :=  format( 'Skiped %s Patients=%d >> Media objects=%d, Files and 3D folders=%d',
                             [ATitle, APatCount, ProcCount, FCount] );
        Result := DumpInfo;
        K_AddStringToTextFile( MergeReportFName, DumpInfo );
        if PatCount > 0 then
        begin
          TmpStrings.Insert( 0, DumpInfo );
          TmpStrings.SaveToFile( MergeInfoPath + 'S1\Skiped' + ATitle + 'Patients.txt' );
        end;
          ////////////////////////////////////////
          // Remove Patients and corresponding Data from DB
          //
        // Remove Patients Data
        CommandText :=
          'DELETE FROM ' + K_CMENDBAllPatientsTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBAllPatientsTable +'.' + K_CMENDAPBridgeID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from ' + K_CMENDBAllPatientsTable );
        Application.ProcessMessages;

        // Remove Contexts
        CommandText := 'DELETE FROM ' + K_CMENDBContextsTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBContextsTable + '.' + K_CMENDBCTFContID + ' = PAIDs.ID' +
            ' AND ' + K_CMENDBContextsTable + '.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actPatIni)) + ';';
        Execute;
        N_Dump1Str( 'SAD>> Delete from ' + K_CMENDBContextsTable );
        Application.ProcessMessages;

        // Remove Slides Data
        CommandText := 'DELETE FROM ' + K_CMENDBSlidesTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBSlidesTable + '.' + K_CMENDBSTFPatID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from ' + K_CMENDBSlidesTable );
        Application.ProcessMessages;

        CommandText := 'DELETE FROM ' + K_CMENDBDelMarkedSlidesTable + ' FROM SLIDs ' +
          ' WHERE ' + K_CMENDBDelMarkedSlidesTable + '.' + K_CMENDMSlideID + ' = SLIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from ' + K_CMENDBDelMarkedSlidesTable );
        Application.ProcessMessages;

        // Remove Patient Statistics
        CommandText := 'DELETE FROM ' + K_CMENDBSessionsHistTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBSessionsHistTable + '.' + K_CMENDBSessionsHTFPatID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from ' + K_CMENDBSessionsHTFPatID );
        Application.ProcessMessages;

        CommandText := 'DELETE FROM ' + K_CMENDBAllHistPatientsTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBAllHistPatientsTable + '.' + K_CMENDAHPatID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from  ' + K_CMENDBAllHistPatientsTable );
        Application.ProcessMessages;

        // Remove Slides Statistics
        CommandText := 'DELETE FROM ' + K_CMENDBSlidesHistTable + ' FROM SLIDs ' +
          ' WHERE ' + K_CMENDBSlidesHistTable + '.' + K_CMENDBSlidesHTFSlideID + ' = SLIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from  ' + K_CMENDBSlidesHistTable );
        Application.ProcessMessages;

        // Remove Sessions Statistics
        CommandText := 'DELETE FROM ' + K_CMENDBSlidesNewHistTable + ' FROM SEIDs ' +
          ' WHERE ' + K_CMENDBSlidesNewHistTable + '.' + K_CMENDBSlidesNHTFSessionID + ' = SEIDs.ID;';
        Execute;
        N_Dump1Str( 'SAD>> Delete from  ' + K_CMENDBSlidesNewHistTable );
        Application.ProcessMessages;
          //
          // Remove Patients and corresponding Data from DB
          ////////////////////////////////////////
      end; // with CurSQLCommand1 do

    except
      on E: Exception do
      begin
        Screen.Cursor := SavedCursor;
        ExtDataErrorString := 'TK_FormCMUTPrepDBData.BtSyncClick ' + E.Message;
        CurDSet1.Close;
        ExtDataErrorCode := K_eeDBUpdate;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

end; // procedure TK_FormCMUTPrepDBData.DumpPatientsAndRemoveFromDB

//*********************************************** TK_FormCMUTPrepDBData.DoSynchPPL ***
//
procedure TK_FormCMUTPrepDBData.DoSynchPPL();
var
  SNum : Integer;
  RepStr, CheckResStr : string;
  PatCount, ProvCount, LocCount : Integer;
  SyncStep : Integer;
  LinkDataType : Integer;

  FName : string;
  StoreProcName : string;
  DumpResStr : string;
  UloadDataPath : string;

//  PatFilesCount : Integer;
//  PatLinkCount : Integer;
  OldPatID, NewPatID : Integer;
  CurSrcFName, SrcPathSegm, DstPathSegm : string;
  ErrCount : Integer;
  DelimChar : char;
  BreakPrepareDataFlag : Boolean;
  InfoFName : string;
  ExistedCount : Integer;
  NeededCount : Integer;
  SpecialPatientsProcessFlag : Boolean;

Label ContinueFilesLoop, ContinuePatCopyLoop, FinDataProcessing;

  function GetPatientsCount( const TabName :string ) : string;
  begin
    // Show number of old Patients
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
    begin
      Connection := LANDBConnection;
      Filtered := FALSE;

    // Old Patients Total
      SQL.Text := 'select count(*) from ' + TabName;
      Open();
      Result := Fields[0].AsString;
      Close();
    end; // with CurDSet1 do
  end; // function GetPatientsCount()

  // New code to prevent erros when existing PatID is meeted in NewID
  function CopyPatientsFileStorage( const SQLText : string ) : Integer;
//  var
//    NextProcMes : TDateTime;
  label LContinuePatCopyLoop;
  begin
    // Select Pairs
    with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
    begin
      CommandText :=
        'DELETE FROM PAIDs2;'#10 +
        'INSERT PAIDs2 ( ID1, ID2 ) ' + SQLText;
      Execute;
{// Debug Code
CommandText := 'UNLOAD select ID1, ID2 from PAIDs2 order by ID1 TO ''' + MergeRootPath + 'DBData\'+IntToStr(AllPatCount)+'PAIDs2.dat''' +
' FORMAT BCP;';
Execute;
{}
    end;

    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
    begin
      Connection := LANDBConnection;
// Order of selected pairs is as in K_CMENDBImportLinkIDsTable
//N_Dump2Str( 'SAD>> SQL=' + SQLText );

//      SQL.Text := SQLText;
      SQL.Text := 'select ID1, ID2 from PAIDs2';
      Filtered := FALSE;
      Open();
      Result := RecordCount;
      if Result = 0 then
      begin
        Close();
        N_Dump1Str( 'SAD>> Empty Patients and LinkIDs join' );
        Exit;
      end;

      AllPatCount := AllPatCount + Result;
      Result := 0;
      First();
      TmpStrings.Clear;
      N_Dump1Str( 'SAD>> Start Sync Patients Loop Portion' );

      ProgressShowPrev := -1;
//      LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[3], [0.0] );
//      LbInfo.Refresh();

      //////////////////////////////////////////
      // Copy Corresponding Media Objects Files
      //
//      NextProcMes := Now() + 1 / (24 * 3600);
      while not EOF do
      begin // All Patients Loop
        OldPatID := Fields[0].AsInteger;
        with CurDSet1 do
        begin
          Connection := LANDBConnection;
          SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable +
                      ' where ' + K_CMENDBSTFPatID + ' = ' +  IntToStr(OldPatID);
//          if (SlidesD4WArchCount > 0) or (SlidesSAArchCount > 0) then
//            SQL.Text := SQL.Text + ' AND NOT ' + K_CMENDBSTFSlideThumbnail + ' IS NULL';
          Filtered := FALSE;
          Open();
          TotalMedia := TotalMedia + Fields[0].AsInteger;
          Close();
        end; // with CurDSet1 do

        NewPatID := Fields[1].AsInteger;
        Next;
        N_Dump2Str( format( 'SAD>> Start PatID %d -> %d', [OldPatID,NewPatID] ) );

        SrcPathSegm := K_CMSlideGetPatientFilesPathSegm(OldPatID);
        DstPathSegm := K_CMSlideGetPatientFilesPathSegm(NewPatID);

        // Add Patient General Image Err Message
        TmpStrings.Add( format( 'Patient ID=%d was not synchronized >> image files errors', [OldPatID]) );
        SNum := CopyPatientFiles( SlidesImgRootFolder + SrcPathSegm,
                           MergeRootPath + K_ImgFolder + DstPathSegm,
                           ErrCount );

        TotalProc := TotalProc + SNum;
        TotalFF   := TotalFF + SNum;
        TotalOf := TotalOf + PatFilesList.Count;
        if PatFilesList.Count > 0 then
          N_Dump2Str( format( 'SAD>> Copy image files %d of %d', [SNum, PatFilesList.Count] ) );

        if ErrCount > 0 then
          goto LContinuePatCopyLoop
        else
          TmpStrings.Delete(TmpStrings.Count - 1); // Remove Patient General Image  Err Message

        // Add Patient General Video Err Message
        TmpStrings.Add( format( 'Patient ID=%d was not synchronized >> video files errors', [OldPatID]) );
        SNum := CopyPatientFiles( SlidesMediaRootFolder + SrcPathSegm,
                           MergeRootPath + K_VideoFolder + DstPathSegm,
                           ErrCount );
        TotalProc := TotalProc + SNum;
        TotalFF   := TotalFF + SNum;
        TotalOf := TotalOf + PatFilesList.Count;

        if PatFilesList.Count > 0 then
          N_Dump2Str( format( 'SAD>> Copy video files %d of %d', [SNum, PatFilesList.Count] ) );
        if ErrCount > 0 then
          goto LContinuePatCopyLoop
        else
          TmpStrings.Delete(TmpStrings.Count - 1); // Remove Patient General Video Err Message

        // Calc Patient Img3D Media Objects Folders
        PatFilesList.Clear;
        K_ScanFilesTreeMaxLevel := 2;
        K_ScanFilesTree( SlidesImg3DRootFolder + SrcPathSegm, TestPatientFile, '*.*', FALSE );
        K_ScanFilesTreeMaxLevel := 0;
        N_Dump2Str( format( 'SAD>> Found Img3D obj folders %d', [PatFilesList.Count] ) + #13#10 +
                    PatFilesList.Text );
        TotalFF := TotalFF + PatFilesList.Count;

        // Add Patient General Img3D Err Message
        TmpStrings.Add( format( 'Patient ID=%d was not synchronized >> Img3D files errors', [OldPatID]) );

        SNum := CopyPatientFiles( SlidesImg3DRootFolder + SrcPathSegm,
                           MergeRootPath + K_Img3DFolder + DstPathSegm,
                           ErrCount );
        TotalProc := TotalProc + SNum;
        TotalOf := TotalOf + PatFilesList.Count;

        if PatFilesList.Count > 0 then
          N_Dump2Str( format( 'SAD>> Copy Img3D files %d of %d', [SNum, PatFilesList.Count] ) );
        if ErrCount > 0 then
          goto LContinuePatCopyLoop
        else
          TmpStrings.Delete(TmpStrings.Count - 1); // Remove Patient General Img3D Err Message

        // Change Patient ID
        if OldPatID <> NewPatID then
          with CurSQLCommand1 do
          begin
            LANDBConnection.BeginTrans;
            EDASAChangePatientBridgeID( OldPatID, NewPatID );
            CommandText := 'UPDATE PAIDs1 SET ID = ' + IntToStr(NewPatID) +
                           ' WHERE ID = ' + IntToStr(OldPatID);
            Execute;
            LANDBConnection.CommitTrans;
          end; // with CurSQLCommand1 do

LContinuePatCopyLoop: // ********
        Inc(Result);
        Inc(PatCount);
//        SGStateView.Cells[2,4] := format( '%d of %d', [TotalProc,TotalOf] );

        ProgressFormat := 'Copy patients media objects, %d%% done';
        ShowProgress( AllPatCount, PatCount );
{
        LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[3], [100 * PatCount / AllPatCount] );
        LbInfo.Refresh();
        if NextProcMes < Now() then
        begin
          Application.ProcessMessages();
          NextProcMes := Now() + 1 / (24 * 3600);
        end;
}
      end; // while not EOF do
      // End of patients Loop
      Close();
    end; // with CurDSet2 do

    // Remove Used Pairs
    with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
    begin
      CommandText :=
        'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
              ' FROM PAIDs2 WHERE ' +
               K_CMENDBImportLinkIDsTable + '.' + K_CMENDILINewID + ' = PAIDs2.ID2 AND ' +
               K_CMENDBImportLinkIDsTable + '.' + K_CMENDILIOldID + ' = PAIDs2.ID1;';
      Execute;

{// Debug Code
CommandText := 'UNLOAD select ' + K_CMENDILIOldID + ' from '+K_CMENDBImportLinkIDsTable+' order by ' + K_CMENDILIOldID + ' TO ''' + MergeRootPath + 'DBData\'+IntToStr(AllPatCount)+'ImpTab.dat''' +
' FORMAT BCP;';
Execute;
{}
    end;
  end; // function CopyPatientsFileStorage

  procedure ProcessDeletedPatients();
  begin
   with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
    begin
      ////////////////////////////
      // Deleted Patients Processing
      //
      N_Dump1Str( 'SAD>> Start Deleted Patients processing' );
      CommandText :=
        'INSERT PAIDs ( ID )' +
        ' SELECT ' + K_CMENDAPBridgeID +
        ' FROM ' + K_CMENDBAllPatientsTable +
        ' WHERE ' + K_CMENDAPFlags + ' <> 0;';
      Execute;
      Application.ProcessMessages();
      N_Dump1Str( 'SAD>> Prep Deleted Patients IDs' );
      // Show number of deleted Patients
//      SGStateView.Cells[1,1] := GetPatientsCount('PAIDs');

        ////////////////////
        // Files process
        //
      with CurDSet3 do
      begin
        Connection := LANDBConnection;
        SQL.Text := 'SELECT ' + K_CMENDAPBridgeID  + ',' + K_CMENDAPSurname + ',' + // 0 1
                                K_CMENDAPFirstname + ',' + K_CMENDAPDOB +           // 2 3
        ' FROM ' + K_CMENDBAllPatientsTable + ';';
        Filtered := FALSE;
        Open();
      end;

      GetPatientPathName := GetPatientPathName1; // Use Patient Sirname Name DOB ...

//      DumpResStr := ExportMediaAndRemoveFromDB( 'Deleted', FALSE );
      ProgressFormat := 'Process deleted patients, %d%% done';
      ProgressShowPrev := -1;

      DumpResStr := DumpPatientsAndRemoveFromDB( 'Deleted',
               DelPatCount, DelMCount, DelFCount );
      if DumpResStr <> '' then SpecialPatientsProcessFlag := TRUE;
//      SGStateView.Cells[2,1] := DumpResStr;

      CurDSet3.Close();

      if DumpResStr <> '' then
      begin
//        LbInfo.Caption := format( '%s Deleted media objects are processed', [DumpResStr] );
        LbInfo.Caption := DumpResStr;
        LbInfo.Refresh();
        N_Dump1Str( 'SAD>> ' + LbInfo.Caption );
      end;
        //
        // end of Files process
        ///////////////////////////

      N_Dump1Str( 'SAD>> Fin Deleted Patients processing' );
      //
      // Deleted Patients Processing
      ////////////////////////////
    end;
  end; // procedure ProcessDeletedPatients

{
  procedure SetMediaPathCotext();
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
    begin // Change if no copy files errors where detected
      CommandText := 'UPDATE ' + K_CMENDBGlobAttrsTable +
      ' SET ' + K_CMENDBGTFImgFPath   + ' =  ''>' + MergeRootPath + K_ImgFolder   + ''', ' +
                K_CMENDBGTFMediaFPath + ' =  ''>' + MergeRootPath + K_VideoFolder + ''', ' +
                K_CMENDBGTFImg3DFPath + ' =  ''>' + MergeRootPath + K_Img3DFolder + ''';';
      Execute;
      SlidesImgRootFolder   := MergeRootPath + K_ImgFolder;
      SlidesMediaRootFolder := MergeRootPath + K_VideoFolder;
      SlidesImg3DRootFolder := MergeRootPath + K_Img3DFolder;
      N_Dump1Str( 'SAD>> Set new Files Storage paths:'#13#10+
       'ImgRootFolder "' + SlidesImgRootFolder + '"'#13#10+
       'VideoRootFolder "' + SlidesMediaRootFolder + '"'#13#10+
       'Img3DRootFolder "' + SlidesImg3DRootFolder + '"' );
    end;
  end; // procedure SetMediaPathCotext
}
  procedure CopyLogs();
  var
    LogFName : string;
    RLogFName : string;
  begin
    LogFName := N_LogChannels[N_Dump1LCInd].LCFullFName;
    RLogFName := MergeInfoPath + 'S1\Logs\' + ExtractFileName(LogFName);
    K_CopyFile( LogFName, RLogFName );

    LogFName := N_LogChannels[N_Dump2LCInd].LCFullFName;
    RLogFName := MergeInfoPath + 'S1\Logs\' + ExtractFileName(LogFName);
    K_CopyFile( LogFName, RLogFName );
  end; // procedure CopyLogs

  procedure DumpFSExisted( const ARelPath : string );
  begin
    K_CMFSBuildExistedFLists( ImgFList, VideoFList, Img3DFList, [] );

    InfoFName := MergeInfoPath + ARelPath;
    K_ForceDirPath( InfoFName );
    InfoFName := InfoFName + 'Existed.txt';
    AllExistedFList.Clear;

    K_AddStringToTextFile( InfoFName, format( 'Img Count=%d', [ImgFList.Count] ) );
    K_AddStringToTextFile( InfoFName, ImgFList.Text );
    AllExistedFList.AddStrings( ImgFList );
    ImgFList.Clear;

    K_AddStringToTextFile( InfoFName, format( 'Video Count=%d', [VideoFList.Count] ) );
    K_AddStringToTextFile( InfoFName, VideoFList.Text );
    AllExistedFList.AddStrings( VideoFList );
    VideoFList.Clear;

    K_AddStringToTextFile( InfoFName, format( 'Img3D Count=%d', [Img3DFList.Count] ) );
    K_AddStringToTextFile( InfoFName, Img3DFList.Text );
    AllExistedFList.AddStrings( Img3DFList );
    Img3DFList.Clear;
  end; // procedure DumpFSExisted

  procedure DumpFSNeeded( const ARelPath : string );
  begin
   with TK_CMEDDBAccess(K_CMEDAccess), CurDSet3 do
     Connection := LANDBConnection;

    K_CMFSBuildNeededFLists( ImgFList, VideoFList, Img3DFList,
                             AImgFList, AVideoFList, AImg3DFList,[],
                             TK_CMEDDBAccess(K_CMEDAccess).CurDSet3, ShowProgress  );
    // Prep Needed FilesList
    InfoFName := MergeInfoPath + ARelPath;
    K_ForceDirPath( InfoFName );
    InfoFName := InfoFName + 'Needed.txt';
    AllNeededFList.Clear;

    K_AddStringToTextFile( InfoFName, format( 'Img Count=%d', [ImgFList.Count] ) );
    K_AddStringToTextFile( InfoFName, ImgFList.Text );
    AllNeededFList.AddStrings( ImgFList );
    ImgFList.Clear;

    K_AddStringToTextFile( InfoFName, format( 'Video Count=%d', [VideoFList.Count] ) );
    K_AddStringToTextFile( InfoFName, VideoFList.Text );
    AllNeededFList.AddStrings( VideoFList );
    VideoFList.Clear;

    K_AddStringToTextFile( InfoFName, format( 'Img3D Count=%d', [Img3DFList.Count] ) );
    K_AddStringToTextFile( InfoFName, Img3DFList.Text );
    AllNeededFList.AddStrings( Img3DFList );
    Img3DFList.Clear;

    // Prep Archived FilesList
    InfoFName := MergeInfoPath + ARelPath;
    K_ForceDirPath( InfoFName );
    InfoFName := InfoFName + 'Archived.txt';
    AllArchivedFList.Clear;

    K_AddStringToTextFile( InfoFName, format( 'Img Count=%d', [AImgFList.Count] ) );
    K_AddStringToTextFile( InfoFName, AImgFList.Text );
    AllArchivedFList.AddStrings( AImgFList );
    AImgFList.Clear;

    K_AddStringToTextFile( InfoFName, format( 'Video Count=%d', [AVideoFList.Count] ) );
    K_AddStringToTextFile( InfoFName, AVideoFList.Text );
    AllArchivedFList.AddStrings( AVideoFList );
    AVideoFList.Clear;

    K_AddStringToTextFile( InfoFName, format( 'Img3D Count=%d', [AImg3DFList.Count] ) );
    K_AddStringToTextFile( InfoFName, AImg3DFList.Text );
    AllArchivedFList.AddStrings( AImg3DFList );
    AImg3DFList.Clear;

  end; // procedure DumpFSNeeded

  procedure CheckDeletedOldNAResults();
  begin
    if SpecialPatientsProcessFlag then
      BreakPrepareDataFlag := mrYes <> K_CMShowMessageDlg(
             format( 'Deleted, Old or NA data is found. All needed details are in %s.'#13#10 +
                     'Do you want to continue? (Select No if you want to break the process)',
                     [MergeInfoPath] ), mtConfirmation, [], FALSE, 'MediaSuite Support' );
  end; // procedure CheckDeletedOldNAResults

  procedure DeleteExtraFiles();
  var
    i, ProcCount, ResCode: Integer;
    RFBPath, FName : string;
  begin
    ProcCount := 0;
    ProgressShowPrev := -1;

    with TK_CMEDDBAccess(K_CMEDAccess) do
    for i := 0 to AllExistedFList.Count - 1 do
    begin
      FName := AllExistedFList[i];
      RFBPath := '';
      Inc(ProcCount);
      ResCode := 0;
      if FName[Length(FName)] = '\' then
      begin // Process Folder (3DImg)
        if not DirectoryExists( FName ) then
          Continue;

        K_DeleteFolderFiles( FName, '*.*', [K_dffRecurseSubfolders,K_dffRemoveReadOnly] );
      end   // Delete Folder (3DImg)
      else
      begin // Process File

        if not FileExists( FName ) then
          Continue;

        if K_StrStartsWith( SlidesMediaRootFolder, FName) then
          RFBPath := SlidesMediaRootFolder
        else
          RFBPath := SlidesImgRootFolder;

        K_DeleteFile( FName, [K_dofDeleteReadOnly] );
      end; // Delete File

      if ResCode = 0 then
        EDARemovePathFolders0(FName, RFBPath);
      ProgressFormat := 'Delete extra files, %d%% done';
      ShowProgress( AllExistedFList.Count, ProcCount );

    end; // for i := 0 to AllExistedFList.Count - 1 do
    K_AddStringToTextFile( MergeReportFName, format('All Extra files and 3D folders (%d) are removed from File Storage copy', [AllExistedFList.Count]) );

  end; // procedure DeleteExtraFiles

begin
//
  RepStr := '';
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  SyncState := 1;
  PatCount  := 0;
  ProvCount := 0;
  LocCount  := 0;
  BreakPrepareDataFlag := FALSE;
  SpecialPatientsProcessFlag := FALSE;

  N_Dump1Str( 'SAD>> DoSynchPPL start' );
  LbInfo.Caption := 'Clear new root folder ...';
  LbInfo.Refresh();
//  K_DeleteFolderFiles(DstFilesPath);
  // to skip Files By Date
//  StrMinDate := K_CMSlideGetFileDatePathSegm( DTPFrom.Date );
  StrMinDate := ExcludeTrailingPathDelimiter(K_CMSlideGetFileDatePathSegm( DTPFrom.Date ));

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
      if not PathNameFrame.Enabled then
      begin
        MergeRootPath := ExtractFilePath(ExcludeTrailingPathDelimiter(SlidesImgRootFolder))
      end
      else
      begin
        MergeRootPath := IncludeTrailingPathDelimiter(PathNameFrame.mbPathName.Text);
        K_DeleteFolderFiles( MergeRootPath );
      end;

      MergeInfoPath := MergeRootPath + MergeInfoFolderName;
      K_ForceDirPath( MergeInfoPath );
      K_DeleteFolderFiles( MergeInfoPath );
      MergeReportFName := MergeInfoPath + 'Report.txt';
      K_AddStringToTextFile( MergeReportFName,
        format( 'Merging Prepare DB data start at %s',
                [ K_DateTimeToStr( Now(), 'yyyy-mm-dd_hh":"nn":"ss' )] ) );

      K_AddStringToTextFile( MergeReportFName,
        format( 'Source DB >> Media objects(Archived): D4W=%d(%d), SA=%d(%d) WPat=%d; Patients: D4W=%d, SA=%d MarkAsDel=%d',
                [SlidesD4WCount, SlidesD4WArchCount, SlidesSACount, SlidesSAArchCount, SlidesWPatCount,
                 PatD4WCount, PatSANormCount, PatSADelCount] ) );

      // Save patients reidentification file
      K_CopyFile( FileNameFrame.mbFileName.Text, MergeInfoPath + 'S1\' + ExtractFileName(FileNameFrame.mbFileName.Text) );

      ////////////////////////////
      // Check and Dump Source DB
      //
      N_Dump1Str( 'SAD>> Dump Source File Storage before' );
      LbInfo.Caption := 'Dump Source File Storage Existed ...';
      LbInfo.Refresh();
      DumpFSExisted( 'S1\FSDumpsBefore\' );
      N_Dump1Str( 'SAD>> Existed Files are build' );
      ProgressFormat := 'Dump Source File Storage Needed, %d%% done';
      DumpFSNeeded( 'S1\FSDumpsBefore\' );
      N_Dump1Str( 'SAD>> Needed Files are build' );
      FSBeforeExisted := AllExistedFList.Count;
      FSBeforeNeeded  := AllNeededFList.Count;
      FSBeforeArchived:= AllArchivedFList.Count;
      LbInfo.Caption := 'Dump Source File Storage Extra/Missing ...';
//      AllNeededFList.AddStrings(AllArchivedFList);
      K_CMFSCompNeededExistedFLists( AllExistedFList, AllNeededFList, nil );
      N_Dump1Str( 'SAD>> Extra and Missing Files are build' );
      FSBeforeExtra := AllExistedFList.Count;
      FSBeforeMissing := AllNeededFList.Count;

      // Set Default After Results for correct check
      FSAfterExisted := FSBeforeExisted;
      FSAfterNeeded  := FSBeforeNeeded;
      FSAfterExtra := FSBeforeExtra;
      FSAfterMissing := FSBeforeMissing;
      FSAfterArchived := FSBeforeArchived;

      K_AddStringToTextFile( MergeReportFName,
        format( 'Source File Storage before >> Existed=%d, Needed=%d, Extra=%d, Missing=%d Archived=%d',
                [FSBeforeExisted, FSBeforeNeeded, FSBeforeExtra, FSBeforeMissing, FSBeforeArchived] ) );
      if AllExistedFList.Count > 0 then
        K_AddStringToTextFile( MergeInfoPath + 'S1\FSDumpsBefore\Extra.txt',
                               AllExistedFList.Text );
      if AllNeededFList.Count > 0 then
        K_AddStringToTextFile( MergeInfoPath + 'S1\FSDumpsBefore\Missing.txt',
                               AllNeededFList.Text );
      if AllArchivedFList.Count > 0 then
        K_AddStringToTextFile( MergeInfoPath + 'S1\FSDumpsBefore\Archived.txt',
                               AllArchivedFList.Text );
      //
      // Check and Dump Source DB
      ////////////////////////////
      N_Dump1Str( 'SAD>> Prepare Data start' );

{ //!!! Skip adding to AllPatients from AllHistPatients because correct is
  // Update Surname of Absent Patients added from AllSlides by AllHistPatients.AHPatCapt
      ///////////////////////////
      // Add absent Patients from AllHistPatients Table to AllPatients Table
      //
      with CurSQLCommand1 do
      begin
        Connection := LANDBConnection;
        CommandText :=
          'INSERT PAIDs1 ( ID )' +
          ' SELECT ' + K_CMENDAHPatID +
          ' FROM ' + K_CMENDBAllHistPatientsTable + ';'#10 +
          'DELETE FROM PAIDs1 FROM ' + K_CMENDBAllPatientsTable +
          ' WHERE ' + K_CMENDBAllPatientsTable + '.' + K_CMENDAPBridgeID +
                                                 ' = PAIDs1.ID;'#10 +
          'INSERT ' + K_CMENDBAllPatientsTable +
             ' (' + K_CMENDAPBridgeID  + ',' +
                    K_CMENDAPSurname  + ',' +
                    K_CMENDAPDOB+ ') ' +
          ' SELECT A.ID, P.' + K_CMENDAHPatCapt + ', DATE( ''1900-01-01 00:00:00'' )' +
          ' FROM PAIDs1 A JOIN ' + K_CMENDBAllHistPatientsTable + ' P ' +
          ' ON ' + 'A.ID = ' +
                   'P.' + K_CMENDAHPatID + ';';
        N_S1 := CommandText;
        Execute;
      end; // with CurSQLCommand1 do
      DumpResStr := GetPatientsCount('PAIDs1');
      PatAddedHistCount := StrToInt(DumpResStr);
      N_Dump1Str( 'SAD>> Add Patients from AllHistPatients table : ' + DumpResStr );
      K_AddStringToTextFile( MergeReportFName, 'Absent Patients from History : ' + DumpResStr );
      //
      // Add absent Patients from AllHistPatients Table to AllPatients Table
      ////////////////////////////
{}

      ///////////////////////////////////
      // Clear Archived Restored Slides Field
      if K_CMEDDBVersion >= 41 then
        with CurSQLCommand1 do
        begin
          CommandText := 'UPDATE ' + K_CMENDBSlidesTable  +
                         ' SET ' + K_CMENDBSTFSlideDTArch + ' = Date(' + K_CMENDBSTFSlideDTCr + ')' +
            ' WHERE not ' + K_CMENDBSTFSlideThumbnail + ' IS NULL';
          Execute;
        end;

      ////////////////////////////
      // Remove Archived Slides
      if (SlidesD4WArchCount > 0) or (SlidesSAArchCount > 0) then
      begin
        LbInfo.Caption := 'Remove archived ...';
        LbInfo.Refresh();



        with CurSQLCommand1 do
        begin
          CommandText := 'DELETE FROM ' + K_CMENDBSlidesTable  +
            ' WHERE ' + K_CMENDBSTFSlideThumbnail + ' IS NULL';
          Execute;
        end;
{
        with CurSQLCommand1 do
        begin
          CommandText := 'DELETE FROM ' + K_CMENDBSlidesTable  +
            ' WHERE ' + K_CMENDBSTFSlideThumbnail + ' IS NULL';
          Execute;
        end;
}
        N_Dump1Str( 'SAD>> Remove archived slides' );
        K_AddStringToTextFile( MergeReportFName,
          format('All Archived Media objects=%d are removed', [SlidesD4WArchCount+SlidesSAArchCount]) );
      end;
      // Remove Archived Slides
      ////////////////////////////
{}
      ///////////////////////////
      // Temporary add absent Patients from AllSlides Table to AllPatients Table
      //
      LbInfo.Caption := 'Add absent patients ...';
      LbInfo.Refresh();
      with CurSQLCommand1 do
      begin
        Connection := LANDBConnection;
        CommandText :=
          'DELETE FROM PAIDs1;'#10 +
          'INSERT PAIDs1 ( ID )' +
          ' SELECT DISTINCT ' + K_CMENDBSTFPatID +
          ' FROM ' + K_CMENDBSlidesTable +
          ' WHERE ' + K_CMENDBSTFPatID + ' > 0 OR ' + K_CMENDBSTFPatID + ' < -100;'#10 +
          'DELETE FROM PAIDs1 FROM ' + K_CMENDBAllPatientsTable +
          ' WHERE ' + K_CMENDBAllPatientsTable + '.' + K_CMENDAPBridgeID +
                                                 ' = PAIDs1.ID;'#10 +
          'INSERT ' + K_CMENDBAllPatientsTable +
             ' (' + K_CMENDAPBridgeID  + ',' +
                    K_CMENDAPSurname + ',' +
                    K_CMENDAPFirstname + ',' +
                    K_CMENDAPDOB+ ') ' +
          ' SELECT ID, STRING(''S'', ID), STRING(''N'', ID), DATE( ''1900-01-01 00:00:00'' ) FROM PAIDs1;';
        Execute;
      end; // with CurSQLCommand1 do
{}
      ///////////////////////////
      // Update absent Patients details from AllHistPatients
      //

      with CurSQLCommand1 do
      begin
        Connection := LANDBConnection;
        CommandText :=
          'UPDATE ' + K_CMENDBAllPatientsTable +
                  ' SET '  + K_CMENDAPSurname + ' =  A.' +  K_CMENDAHPatCapt +
                  ' FROM ' + K_CMENDBAllHistPatientsTable + ' A' +
                  ' JOIN PAIDs1' +
                  ' ON A.' + K_CMENDAHPatID + ' = PAIDs1.ID' +
                  ' WHERE ' + K_CMENDBAllPatientsTable + '.' + K_CMENDAPBridgeID + ' = ' + 'PAIDs1.ID';
        N_S1 := CommandText;
        Execute;
{
CommandText := 'UNLOAD TABLE PAIDs1 TO ''' + MergeRootPath + 'DBData\1PAIDs1.dat''' +
' FORMAT BCP;';
Execute;
{}
      end; // with CurSQLCommand1 do

      //
      // Update absent Patients details from AllHistPatients
      ///////////////////////////
{}
      DumpResStr := GetPatientsCount('PAIDs1');
      PatAddedBeforeCount := StrToInt(DumpResStr);
      PatAddedD4WCount := PatAddedBeforeCount;
      if PatAddedBeforeCount > 0 then
      begin
         with CurDSet1 do
        begin
          Connection := LANDBConnection;
          Filtered := FALSE;
          SQL.Text := 'select count(*) from PAIDs1 where ID > 0;';
          Open();
          PatAddedD4WCount := Fields[0].AsInteger;
          Close();
        end; // with CurDSet1 do
        DumpResStr := format( 'D4W=%d SA=%d', [PatAddedD4WCount, PatAddedBeforeCount - PatAddedD4WCount] );
        K_AddStringToTextFile( MergeReportFName, 'Absent Patients from Slides table are added >> ' + DumpResStr );
      end;
      N_Dump1Str( 'SAD>> Temporary Add from Slides table >> ' + DumpResStr );
      //
      // Temporary add absent Patients from AllSlides Table to AllPatients Table
      ////////////////////////////


      if SlidesD4WCount > 0 then
      ///////////////////////
      // Process D4W Data
      //
        while LinkFileInd < SyncFilesList.Count do
        begin // Sync Files Loop
          SyncStep := 1;
          LinkDataType := 0; // Patients Data Type
          if SyncFilesList.Count > 0 then
          begin
            FName := SyncFilesList[LinkFileInd];

        // Current SA Link Code
            // Select Proper Procedure Name
            if FName[1]= 'p' then // patients ...
            begin
              LinkDataType := 0;
              StoreProcName := 'dba.cms_ImportLinkPatientsInfo';
            end
            else
            if FName[1]= 'd' then // dentists ...
              LinkDataType := 1
            else
            if FName[1]= 'l' then // practices ...
              LinkDataType := 2
            else
            begin
              K_CMShowMessageDlg( format(K_CML1Form.LLLExpWrongLinkFName.Caption, [FName]), mtWarning );
              Inc(LinkFileInd);
              Continue;
            end;
            FNameDate := Copy( FName, Length(FName) - 13, 10 );
          end
          else
          begin
            FName := ExtractFileName(CurSyncFile);
            FNameDate := K_DateTimeToStr( K_GetFileAge( CurSyncFile ), 'yyyy-mm-dd' );
            StoreProcName := 'dba.cms_ImportLinkPatientsInfo';
          end;

//          RepStr := RepStr + #13#10 + FName;
          RepStr := RepStr + ' ' + FName;
          N_Dump1Str( 'SAD>> Sync by file ' + FName );

          LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, 1] );
          LbInfo.Refresh();

          K_VFLoadText( StrTextBuf, CurSyncPath + FName );
  //        TmpStrings.LoadFromFile( CurSyncPath + FName );
  //        StrTextBuf := TmpStrings.Text;
            // Exec Procedure
          if StrTextBuf[1] = '<' then //*** XML link data
          begin
            with CurStoredProc1 do
            begin
              Connection := LANDBConnection;
              // Replace NA -> -1
    //          DelPatNum := N_ReplaceEQSSubstr( StrTextBuf, '"NA"', '"-1"' );
              N_ReplaceEQSSubstr( StrTextBuf, '"NA"', '"-1"' );
    //          TmpStrings.Text := StrTextBuf;
              ProcedureName := StoreProcName;
              Parameters.Clear;
              with Parameters.AddParameter do
              begin
                Name := '@xml_data';
                Direction := pdInput;
                DataType := ftString;
                Value := StrTextBuf;
    //            Value := TmpStrings.Text;
              end;
              ExecProc;
            end; // with CurStoredProc1 do
            with CurSQLCommand1 do
            begin // Dump Old\NewID info
              Connection := LANDBConnection;
              CommandText :=
                'UNLOAD TABLE "dba"."ImportLinkIDs" to ''' + MergeInfoPath + 'S1\Patients.txt''';
              Execute;
            end;
          end
          else
          begin                        //*** not XML link data
            DelimChar := ',';
            if Pos( DelimChar, StrTextBuf ) = 0 then
              DelimChar := ';';

            with CurSQLCommand1 do
            begin
              Connection := LANDBConnection;
              CommandText :=
                'BEGIN' + Chr($0A) +
                  'DELETE FROM "dba"."ImportLinkIDs";'#10 +
                  'LOAD TABLE "dba"."ImportLinkIDs"'#10 +
                     ' FROM ''' + CurSyncPath + FName + ''''#10 +
                     ' DELIMITED BY '''+DelimChar+''';'#10 +
  //'UNLOAD TABLE "dba"."ImportLinkIDs" to ''D:\Delphi_prj_new\DTmp\ErrLogs\2018\2018-01-15_MergeDB_34_35\ChangePatIDs100.txt'';'#10 +
               'END;';
              Execute;
            end;
          end;

          with CurSQLCommand1 do
          begin
            Connection := LANDBConnection;
            case LinkDataType of
            //////////////////
            // Patients
            //
            0: begin
              if PatSADelCount > 0 then
                ProcessDeletedPatients();

              ////////////////////////////
              // Old Patients Processing
              //
              N_Dump1Str( 'SAD>> Start Old Patients processing' );
              CommandText :=
                'DELETE FROM PAIDs;'#10 +
                'INSERT PAIDs ( ID )' +
                ' SELECT DISTINCT ' + K_CMENDBSTFPatID +
                ' FROM ' + K_CMENDBSlidesTable +
                ' WHERE ' + K_CMENDBSTFPatID + ' > 0;'#10 +
                'DELETE FROM PAIDs FROM ' + K_CMENDBImportLinkIDsTable +
                ' WHERE ' + K_CMENDBImportLinkIDsTable + '.' + K_CMENDILIOldID +
                                                       ' = PAIDs.ID;';
              Execute;

              Application.ProcessMessages();
              N_Dump1Str( 'SAD>> Prep Old Patients IDs' );

              // Show number of old Patients
{
              SGStateView.Cells[1,2] := GetPatientsCount('PAIDs');
              if SGStateView.Cells[1,2] <> '0' then
              begin // unload old Patients IDs
                CommandText := 'UNLOAD TABLE PAIDs TO ''' +
                               CurSyncPath + 'OldPatientsIDs.txt''' +
                               ' FORMAT TEXT;';
                Execute;
              end;
}
              with CurDSet3 do
              begin
                Connection := LANDBConnection;
                SQL.Text := 'SELECT ' + K_CMENDAHPatID  + ',' + K_CMENDAHPatCapt + // 0 1
                ' FROM ' + K_CMENDBAllHistPatientsTable + ' A JOIN PAIDs P ON A.' +
                    K_CMENDAHPatID + ' = P.ID;';
                Filtered := FALSE;
                Open();
              end;

              GetPatientPathName := GetPatientPathName2; // Use Patient Statistic Name

//              DumpResStr := ExportMediaAndRemoveFromDB( 'Old', FALSE );
              ProgressFormat := 'Process old patients, %d%% done';
              ProgressShowPrev := -1;
              DumpResStr := DumpPatientsAndRemoveFromDB( 'Old',
                                     OldPatCount, OldMCount, OldFCount );
              if OldPatCount <> 0 then SpecialPatientsProcessFlag := TRUE;

//              SGStateView.Cells[2,2] := DumpResStr;
              CurDSet3.Close();

              if DumpResStr <> '' then
              begin
        //        LbInfo.Caption := format( '%s old media objects are processed', [DumpResStr] );
                LbInfo.Caption := DumpResStr;
                LbInfo.Refresh();
                N_Dump1Str( 'SAD>> ' +LbInfo.Caption );
              end;

              N_Dump1Str( 'SAD>> Fin Old Patients processing' );
              //
              // Old Patients Processing
              ////////////////////////////

              ////////////////////////////////////////////////
              // Remove Patient ID Pairs which are not needed
              //
              LbInfo.Caption := 'Media Suite Support is preparing to media files copy. Please wait ...';
              LbInfo.Refresh();
  {}   // This Code works 75 msec while 12500 Pairs decrease to 3900
  //            N_T1.Start();
              CommandText :=
                'DELETE FROM PAIDs2;'#10 +
                'INSERT PAIDs2 ( ID1, ID2 ) ' +
                'SELECT P.' + K_CMENDILIOldID + ', P.' + K_CMENDILINewID +
                ' FROM ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' JOIN ' + K_CMENDBAllPatientsTable   + ' A' +
                ' ON A.' + K_CMENDAPBridgeID + ' = P.' + K_CMENDILIOldID;
              Execute;

{// Debug Code
CommandText := 'UNLOAD select ' + K_CMENDAPBridgeID + ' from ' + K_CMENDBAllPatientsTable   + ' order by ' + K_CMENDAPBridgeID + ' TO ''' + MergeRootPath + 'DBData\AllPatIDs1.dat''' +
' FORMAT BCP;';
Execute;
CommandText := 'UNLOAD select ID1, ID2 from PAIDs2 order by ID1 TO ''' + MergeRootPath + 'DBData\ImpPatIDs1.dat''' +
' FORMAT BCP;';
Execute;
{}
              CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';'#10 +
                'INSERT ' + K_CMENDBImportLinkIDsTable + ' ( ' + K_CMENDILIOldID + ','+ K_CMENDILINewID + ' ) ' +
                'SELECT ID1, ID2 FROM PAIDs2;';
              Execute;

  //            N_T1.Stop();
  //            LbInfo.Caption := N_T1.ToStr();
  //            LbInfo.Refresh();
  //            CommandText := 'UNLOAD TABLE "dba"."ImportLinkIDs" to ''D:\Delphi_prj_new\DTmp\ErrLogs\2018\2018-01-15_MergeDB_34_35\ChangePatIDs1103.txt''';
  //            Execute;
  //            Sleep(10000);
  {}  // End of This Code works 75 msec while 12500 Pairs decrease to 3900

  {  // This Code works 124 sec while 12500 Pairs decrease to 3900
  //            N_T1.Start();
              CommandText :=
                'INSERT PAIDs11 ( ID )' +
                ' SELECT ' + K_CMENDAPBridgeID +
                ' FROM ' + K_CMENDBAllPatientsTable;
              Execute;
  //            N_T1.Stop();
  //            LbInfo.Caption := LbInfo.Caption + ' ' + N_T1.ToStr();
  //            LbInfo.Refresh();
  //            N_T1.Start();
              CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                      ' FROM PAIDs11 WHERE ' +
                      ' NOT EXISTS (SELECT 1 FROM PAIDs11 WHERE ID = ' +
                                    K_CMENDBImportLinkIDsTable + '.' + K_CMENDILIOldID + ');';
              Execute;
  {} // End of This Code works 124 sec while 12500 Pairs decrease to 3900

  {  // This Code works 154 sec while 12500 Pairs decrease to 3900
              CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                      ' FROM ' + K_CMENDBAllPatientsTable + ' WHERE ' +
                      ' NOT EXISTS (SELECT 1 FROM ' + K_CMENDBAllPatientsTable +
                                          ' WHERE ' + K_CMENDAPBridgeID + ' = ' +
                                                      K_CMENDBImportLinkIDsTable + '.' + K_CMENDILIOldID + ');';
              Execute;

              N_T1.Stop();
              LbInfo.Caption := LbInfo.Caption + ' ' + N_T1.ToStr();
              LbInfo.Refresh();

              CommandText := 'UNLOAD TABLE "dba"."ImportLinkIDs" to ''D:\Delphi_prj_new\DTmp\ErrLogs\2018\2018-01-15_MergeDB_34_35\ChangePatIDs1102.txt''';
              Execute;
              Sleep(10000);
  {} // End of This Code works 154 sec while 12500 Pairs decrease to 3900
              //
              // Remove Patient ID Pairs which are not needed
              ////////////////////////////////////////////////

              ////////////////////////////
              // NA Patients Processing
              //
              N_Dump1Str( 'SAD>> Start NA Patients processing' );
              CommandText :=
                'DELETE FROM PAIDs;'#10 +
                'INSERT PAIDs ( ID )' +
                ' SELECT ' + K_CMENDILIOldID +
                ' FROM ' + K_CMENDBImportLinkIDsTable +
                ' WHERE ' + K_CMENDILINewID + ' = -1;';

              Execute;
              Application.ProcessMessages();
              N_Dump1Str( 'SAD>> Prep NA Patients IDs' );

{// Debug Code
CommandText := 'UNLOAD select ID from PAIDs order by ID TO ''' + MergeRootPath + 'DBData\1PatIDs.dat''' +
' FORMAT BCP;';
Execute;
{}
              // Show number of NA Patients
//              SGStateView.Cells[1,3] := GetPatientsCount('PAIDs');

              with CurDSet3 do
              begin
                Connection := LANDBConnection;
                SQL.Text := 'SELECT ' + K_CMENDAPBridgeID  + ',' + K_CMENDAPSurname + ',' + // 0 1
                                        K_CMENDAPFirstname + ',' + K_CMENDAPDOB +           // 2 3
                ' FROM ' + K_CMENDBAllPatientsTable + ';';
                Filtered := FALSE;
                Open();
              end;

              GetPatientPathName := GetPatientPathName1; // Use Patient Sirname Name DOB ...

//              DumpResStr := ExportMediaAndRemoveFromDB( 'NA', FALSE );
              ProgressFormat := 'Process NA patients, %d%% done';
              ProgressShowPrev := -1;
              DumpResStr := DumpPatientsAndRemoveFromDB( 'NA',
                                         NAPatCount, NAMCount, NAFCount );
              if NAPatCount <> 0 then SpecialPatientsProcessFlag := TRUE;
//              SGStateView.Cells[2,3] := DumpResStr;

              CurDSet3.Close();
              if DumpResStr <> '' then
              begin
        //        LbInfo.Caption := format( '%s NA media objects are processed', [DumpResStr] );
                LbInfo.Caption := DumpResStr;
                LbInfo.Refresh();
                N_Dump1Str( 'SAD>> ' + LbInfo.Caption );
              end;
              N_Dump1Str( 'SAD>> Fin NA Patients processing' );
              //
              // NA Patients Processing
              ////////////////////////////

{// Debug Code
CommandText := 'UNLOAD select ' + K_CMENDAPBridgeID + ' from ' + K_CMENDBAllPatientsTable   + ' order by ' + K_CMENDAPBridgeID + ' TO ''' + MergeRootPath + 'DBData\AllPatIDs2.dat''' +
' FORMAT BCP;';
Execute;
{}
              CheckDeletedOldNAResults();
              if BreakPrepareDataFlag then
              begin
                SyncState := 0;
                goto FinDataProcessing;
              end;

              ////////////////////////////
              // Patients Reidentification
              //

              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[3], [0.0] );
              LbInfo.Refresh();
                //////////////////////////////////
                // Show number of Linked Patients
              CommandText :=
                'DELETE FROM PAIDs;'#10 +
                'INSERT PAIDs ( ID )' +
                ' SELECT ' + K_CMENDILIOldID +
                ' FROM ' + K_CMENDBImportLinkIDsTable +
                ' WHERE ' + K_CMENDILINewID + ' <> -1;';

              Execute;

//              SGStateView.Cells[1,4] := GetPatientsCount('PAIDs');
                // Show number of Linked Patients
                //////////////////////////////////

                //////////////////////////////////////////
                // Copy Corresponding Media Objects Files Loop
                //

  { // New code Copy Corresponding Patients Media Objects Files for patients with new IDs exists in DB }
              N_Dump1Str( 'SAD>> Start Sync Patients Loop' );
              TmpStrings.Clear;
              AllPatCount := 0;
              TotalProc := 0;
              TotalOf  := 0;
              TotalMedia := 0;
              TotalFF := 0;

              // Copy files for all not changing ID patients
  {}     // Copy files for all changing ID patients Loop
              while 0 <> CopyPatientsFileStorage(
                'SELECT P.' + K_CMENDILIOldID + ', P.' + K_CMENDILINewID +
                ' FROM ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' JOIN ' + K_CMENDBAllPatientsTable   + ' A' +
                ' ON A.' + K_CMENDAPBridgeID + ' = P.' + K_CMENDILIOldID + ' WHERE ' +
                   ' P.' + K_CMENDILINewID + ' <> -1 AND ' +
                   ' P.' + K_CMENDILIOldID + ' <> P.' + K_CMENDILINewID + ' AND ' +
                   ' NOT EXISTS (SELECT 1 FROM ' + K_CMENDBAllPatientsTable +
                                 ' WHERE ' + K_CMENDAPBridgeID + ' = P.'  + K_CMENDILINewID + ') ;' )
              do
                N_Dump1Str( format( 'SAD>> Syncronized Patients Count = %d', [PatCount]) );

              // Copy files for all not changing ID patients
              if 0 < CopyPatientsFileStorage(
                  'SELECT P.' + K_CMENDILIOldID + ', P.' + K_CMENDILINewID +
                  ' FROM ' + K_CMENDBImportLinkIDsTable + ' P' +
                  ' JOIN ' + K_CMENDBAllPatientsTable   + ' A' +
                  ' ON A.' + K_CMENDAPBridgeID + ' = P.' + K_CMENDILIOldID + ' WHERE ' +
                     ' P.' + K_CMENDILIOldID + ' = P.' + K_CMENDILINewID + ';' ) then
                N_Dump1Str( format( 'SAD>> Same IDs and Syncronized Patients Count = %d', [PatCount]) );


              // Copy files for all SA patients
              if 0 < CopyPatientsFileStorage(
                  'SELECT ' + K_CMENDAPBridgeID + ', ' + K_CMENDAPBridgeID +
                  ' FROM ' + K_CMENDBAllPatientsTable +
                  ' WHERE ' + K_CMENDAPBridgeID + ' < -100' ) then
                N_Dump1Str( format( 'SAD>> SA IDs Patients Count = %d', [PatCount]) );
  {}

              if TmpStrings.Count > 0 then
              begin
              // Some errors where detected
                BreakPrepareDataFlag := TRUE;
                CurSrcFName := MergeInfoPath + 'S1\FSCopyMediaFilesErrors.txt';
                TmpStrings.SaveToFile( CurSrcFName );
                K_CMShowMessageDlg( 'Some media files copy errors were detected.' + #13#10 +
                                    'You should try to synchronized patients again.' + #13#10 +
                                    'All details are in ' + CurSrcFName + #13#10 +
                                    'Press OK to continue', mtWarning );
              end; // if TmpStrings.Count > 0 then
              N_Dump1Str( 'SAD>> Copy New ID files fin ' );
                //
                // Copy Corresponding Media Objects Files
                //////////////////////////////////////////

            end; // Patients
            //
            // Patients
            //////////////////

            //////////////////
            // Providers
            //
            1: begin
              // Start Providers
              with CurDSet2 do
              begin
                Connection := LANDBConnection;
                SQL.Text := 'SELECT count(*)' +
                ' FROM ' + K_CMENDBAllProvidersTable   + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDAUBridgeID + ' = P.' + K_CMENDILIOldID;
                Filtered := FALSE;
                Open();
                ProvCount := Fields[0].AsInteger;
                Close();
              end;

              LANDBConnection.BeginTrans;
              if K_CMSLiRegStatus = K_lrtEnterprise then
              begin // Enterprise Mode

                N_Dump2Str( 'SAD>> Change ' + K_CMENDBSyncFilesQueryTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesQueryTable +
                  ' SET '  + K_CMENDBSFQProvID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesQueryTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFQProvID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SyncStep);

                N_Dump2Str( 'SAD>> Change ' + K_CMENDBSyncFilesQueryHistTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesQueryHistTable +
                  ' SET '  + K_CMENDBSFQHProvID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesQueryHistTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFQHProvID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SyncStep);

                N_Dump2Str( 'SAD>> Change ' + K_CMENDBLocsFAccessTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBLocsFAccessTable +
                  ' SET '  + K_CMENDBLFALocNewFProvID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBLocsFAccessTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBLFALocNewFProvID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SyncStep);

              end; // if K_CMSLiRegStatus = 2 then

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBSessionsHistTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSessionsHistTable +
                ' SET '  + K_CMENDBSessionsHTFProvID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSessionsHistTable  + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSessionsHTFProvID + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SyncStep);

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBAllHistProvidersTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBAllHistProvidersTable +
                ' SET '  + K_CMENDAHProvID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBAllHistProvidersTable + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable   + ' P' +
                ' ON A.' + K_CMENDAHProvID + ' = P.' + K_CMENDILIOldID;
              Execute;

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBSlidesTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable +
                ' SET '  + K_CMENDBSTFSlideProvIDCr + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSlidesTable        + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSTFSlideProvIDCr + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SyncStep);

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBSlidesTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable +
                ' SET '  + K_CMENDBSTFSlideProvIDMod + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSlidesTable        + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSTFSlideProvIDMod + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SyncStep);

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBContextsTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
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
              Inc(SyncStep);

              if (K_CMEDDBVersion >= 22) then
              begin
                N_Dump2Str( 'SAD>> Change ' + K_CMENDBAllPatientsTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBAllPatientsTable +
                  ' SET '  + K_CMENDAPProvID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBAllPatientsTable   + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                  ' ON A.' + K_CMENDAPProvID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SyncStep);
              end;

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBAllProvidersTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBAllProvidersTable +
                ' SET '  + K_CMENDAUBridgeID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBAllProvidersTable   + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDAUBridgeID + ' = P.' + K_CMENDILIOldID;
              Execute;

              LANDBConnection.CommitTrans;

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
              Application.ProcessMessages();
            end; // Providers
            //
            // Providers
            //////////////////

            //////////////////
            // Locations
            //
            2: begin
              if SyncState = 3 then
              begin
                with CurDSet2 do
                begin
                  Connection := LANDBConnection;
                  SQL.Text := 'SELECT count(*)' +
                  ' FROM ' + K_CMENDBAllLocationsTable   + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                  ' ON A.' + K_CMENDALBridgeID + ' = P.' + K_CMENDILIOldID;
                  Filtered := FALSE;
                  Open();
                  LocCount := Fields[0].AsInteger;
                  Close();
                end;

                LANDBConnection.BeginTrans;

                N_Dump2Str( 'SAD>> Change ' + K_CMENDBSyncFilesQueryTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesQueryTable +
                  ' SET '  + K_CMENDBSFQDstLocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesQueryTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFQDstLocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SyncStep);

                N_Dump2Str( 'SAD>> Change ' + K_CMENDBSyncFilesQueryHistTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesQueryHistTable +
                  ' SET '  + K_CMENDBSFQHDstLocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesQueryHistTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFQHDstLocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SyncStep);

                N_Dump2Str( 'SAD>> Change ' + K_CMENDBLocsFAccessTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBLocsFAccessTable +
                  ' SET '  + K_CMENDBLFALocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBLocsFAccessTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBLFALocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SyncStep);

                N_Dump2Str( 'SAD>> Change ' + K_CMENDBLocFilesInfoTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBLocFilesInfoTable +
                  ' SET '  + K_CMENDBLFILocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBLocFilesInfoTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBLFILocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SyncStep);

                N_Dump2Str( 'SAD>> Change ' + K_CMENDBSyncFilesHistTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesHistTable +
                  ' SET '  + K_CMENDBSFHDstLocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesHistTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFHDstLocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SyncStep);

                N_Dump2Str( 'SAD>> Change ' + K_CMENDBSyncFilesHistTable );
                LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
                LbInfo.Refresh();
                CommandText := 'UPDATE ' + K_CMENDBSyncFilesHistTable +
                  ' SET '  + K_CMENDBSFHSrcLocID + ' =  P.' +  K_CMENDILINewID +
                  ' FROM ' + K_CMENDBSyncFilesHistTable + ' A' +
                  ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                  ' ON A.' + K_CMENDBSFHSrcLocID + ' = P.' + K_CMENDILIOldID;
                Execute;
                Inc(SyncStep);
              end; // if K_CMSLiRegStatus = 2 then

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBSessionsHistTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSessionsHistTable +
                ' SET '  + K_CMENDBSessionsHTFLocID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSessionsHistTable  + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSessionsHTFLocID + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SyncStep);

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBAllHistLocationsTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBAllHistLocationsTable +
                ' SET '  + K_CMENDAHLocID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBAllHistLocationsTable + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable   + ' P' +
                ' ON A.' + K_CMENDAHLocID + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SyncStep);

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBSlidesTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable +
                ' SET '  + K_CMENDBSTFSlideLocIDCr + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSlidesTable        + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSTFSlideLocIDCr + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SyncStep);

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBSlidesTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBSlidesTable +
                ' SET '  + K_CMENDBSTFSlideLocIDMod + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBSlidesTable        + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDBSTFSlideLocIDMod + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SyncStep);

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBContextsTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBContextsTable +
                ' SET '   + K_CMENDBCTFContID + ' =  P.' +  K_CMENDILINewID +
                ' FROM '  + K_CMENDBContextsTable      + ' A' +
                ' JOIN '  + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON (A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actLocIni)) +
                    ' OR A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actLocUD)) + ')'+
                  ' AND A.' + K_CMENDBCTFContID     + ' = P.' + K_CMENDILIOldID;
              Execute;
              Inc(SyncStep);

              N_Dump2Str( 'SAD>> Change ' + K_CMENDBAllLocationsTable );
              LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, SyncStep] );
              LbInfo.Refresh();
              CommandText := 'UPDATE ' + K_CMENDBAllLocationsTable +
                ' SET '  + K_CMENDALBridgeID + ' =  P.' +  K_CMENDILINewID +
                ' FROM ' + K_CMENDBAllLocationsTable   + ' A' +
                ' JOIN ' + K_CMENDBImportLinkIDsTable + ' P' +
                ' ON A.' + K_CMENDALBridgeID + ' = P.' + K_CMENDILIOldID;
              Execute;

              LANDBConnection.CommitTrans;

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
            end; // Locations
            //
            // Locations
            //////////////////
            end; // case LinkDataType of
          end; // with CurSQLCommand1 do

  ContinueFilesLoop: //******
          Inc(LinkFileInd);
        end // while LinkFileInd < SyncFilesList.Count do
      //
      // Process D4W Data
      ///////////////////////
      else
      begin // Process Stand Alone only
      ///////////////////////
      // Process SA Data only
      //
        N_Dump1Str( 'SAD>> Start processing SA data' );
        if PatSADelCount > 0 then
        begin
          ProcessDeletedPatients();
          CheckDeletedOldNAResults();
        end;

        if PathNameFrame.Enabled then
        begin // copy SA media files to FS copy
          N_Dump1Str( 'SAD>> Start copy SA media' );
          TmpStrings.Clear;
          AllPatCount := 0;
          TotalProc := 0;
          TotalOf  := 0;
          TotalMedia := 0;
          TotalFF := 0;

          // Copy files for all SA patients
          if 0 < CopyPatientsFileStorage(
              'SELECT ' + K_CMENDAPBridgeID + ', ' + K_CMENDAPBridgeID +
              ' FROM ' + K_CMENDBAllPatientsTable +
              ' WHERE ' + K_CMENDAPBridgeID + ' < -100' ) then
            N_Dump1Str( format( 'SAD>> SA IDs Patients Count = %d', [PatCount]) );
{}

          if TmpStrings.Count > 0 then
          begin
          // Some errors where detected
            BreakPrepareDataFlag := TRUE;
            CurSrcFName := MergeInfoPath + 'S1\FSCopyMediaFilesErrors.txt';
            TmpStrings.SaveToFile( CurSrcFName );
            K_CMShowMessageDlg( 'Some media files copy errors were detected.' + #13#10 +
                                'You should try to prepare DB data again.' + #13#10 +
                                'All details are in ' + CurSrcFName + '.'#13#10 +
                                'Press OK to continue', mtWarning );
          end; // if TmpStrings.Count > 0 then
          N_Dump1Str( 'SAD>> Copy SA media objects files fin ' );

        end; // if not PathNameFrame.Enabled then

      //
      // Process SA Data only
      ///////////////////////
      end; // Process Stand Alone only


      ////////////////////////////////////////////////////
      // Remove Temporary added Patients from AllPatients
      //
      with CurSQLCommand1 do
      begin
{
CommandText := 'UNLOAD TABLE PAIDs1 TO ''' + MergeRootPath + 'DBData\1PAIDs1.dat''' +
' FORMAT BCP;';
Execute;
{}
        CommandText := 'DELETE FROM ' + K_CMENDBAllPatientsTable + ' FROM PAIDs1 ' +
          ' WHERE ' + K_CMENDBAllPatientsTable + '.' + K_CMENDAPBridgeID +
                                                 ' = PAIDs1.ID;';
        Execute;
      end;
      N_Dump1Str( 'SAD>> Remove temporary added patients' );
      //
      // Remove Temporary added Patients from AllPatients
      /////////////////////////////////////////////////////

      /////////////////////////////////////////////////////
      // Remove Media Objects Info from DB by creation date
      //
      if DTPFrom.Checked then
        with CurSQLCommand1 do
        begin
          StrMinDate := EDADBDateTimeToSQL( DTPFrom.Date, 'yyyy-mm-dd 00:00:00.000' );
          CommandText := 'INSERT SLIDs (ID)' +
                       ' SELECT ' + K_CMENDBSTFSlideID + ' FROM ' + K_CMENDBSlidesTable +
                       ' WHERE ' + K_CMENDBSTFSlideDTCr + ' < ' + StrMinDate + ';';
          Execute;

          CommandText := 'DELETE FROM ' + K_CMENDBSlidesTable +
                         ' WHERE ' + K_CMENDBSTFSlideDTCr + ' < ' + StrMinDate + ';';
          Execute;

          CommandText := 'DELETE FROM ' + K_CMENDBDelMarkedSlidesTable + ' FROM SLIDs ' +
            ' WHERE ' + K_CMENDBDelMarkedSlidesTable +'.' + K_CMENDMSlideID + ' = SLIDs.ID;';
          Execute;

          CommandText := 'DELETE FROM ' + K_CMENDBSlidesHistTable +
                         ' WHERE ' + K_CMENDBSlidesHTFActTS + ' < ' + StrMinDate + ';';
          Execute;

          CommandText := 'DELETE FROM SLIDs;' + #10 +
                         'INSERT SLIDs (ID)' +
                         ' SELECT DISTINCT ' + K_CMENDBSlidesNHTFSessionID + ' FROM ' + K_CMENDBSlidesNewHistTable +
                         ' WHERE ' + K_CMENDBSlidesNHTFActTS + ' < ' + StrMinDate +
                         ' AND ' + K_CMENDBSlidesNHTFSessionID + ' <> 0' +
                         ' ORDER BY ' + K_CMENDBSlidesNHTFSessionID + ' ASC;';
          Execute;

          CommandText := 'DELETE FROM ' + K_CMENDBSlidesNewHistTable + ' FROM SLIDs ' +
            ' WHERE ' + K_CMENDBSlidesNewHistTable +'.' + K_CMENDBSlidesNHTFSessionID + ' = SLIDs.ID;';
          Execute;

          CommandText := 'DELETE FROM ' + K_CMENDBSlidesNewHistTable +
                         ' WHERE ' + K_CMENDBSlidesNHTFSessionID + ' = 0 AND ' +
                                     K_CMENDBSlidesNHTFActTS + ' < ' + StrMinDate + ';';
          Execute;

          CommandText := 'DELETE FROM ' + K_CMENDBSessionsHistTable + ' FROM SLIDs ' +
            ' WHERE ' + K_CMENDBSessionsHistTable +'.' + K_CMENDBSessionsHTFSessionID + ' = SLIDs.ID;';
          Execute;
        end; // with CurSQLCommand1 do
      //
      // Remove Media Objects Info from DB by creation date
      /////////////////////////////////////////////////////



      if PathNameFrame.Enabled then
      begin
        ////////////////////////////////////////
        // Change Media Objects Paths
        //
  //      SetMediaPathCotext();
  {}
        with CurSQLCommand1 do
        begin // Change if no copy files errors where detected
          CommandText := 'UPDATE ' + K_CMENDBGlobAttrsTable +
          ' SET ' + K_CMENDBGTFImgFPath   + ' =  ''>' + K_CMDBFilePathPrepStr(MergeRootPath) + K_ImgFolder   + ''', ' +
                    K_CMENDBGTFMediaFPath + ' =  ''>' + K_CMDBFilePathPrepStr(MergeRootPath) + K_VideoFolder + ''', ' +
                    K_CMENDBGTFImg3DFPath + ' =  ''>' + K_CMDBFilePathPrepStr(MergeRootPath) + K_Img3DFolder + ''';';
          Execute;
          SlidesImgRootFolder   := MergeRootPath + K_ImgFolder;
          SlidesMediaRootFolder := MergeRootPath + K_VideoFolder;
          SlidesImg3DRootFolder := MergeRootPath + K_Img3DFolder;
          N_Dump1Str( 'SAD>> Set new Files Storage paths:'#13#10+
           'ImgRootFolder "' + SlidesImgRootFolder + '"'#13#10+
           'VideoRootFolder "' + SlidesMediaRootFolder + '"'#13#10+
           'Img3DRootFolder "' + SlidesImg3DRootFolder + '"' );
        end;
  {}
        //
        // Change Media Objects Paths
        ////////////////////////////
        DumpResStr := 'Copy from Source File Storage';
        if DTPFrom.Checked then
           DumpResStr :=  DumpResStr + K_DateTimeToStr( DTPFrom.Date, '" (from "yyyy-mm-dd")"');
        DumpResStr := format( '%s >> Media objects=%d; Files and 3D folders=%d; Patients=%d to %s',
                              [DumpResStr, TotalMedia, TotalFF, AllPatCount, MergeRootPath] );
        N_Dump1Str( 'SAD>> ' + DumpResStr );

        K_AddStringToTextFile( MergeReportFName, DumpResStr );

      end; // if PathNameFrame.Enabled then


      SyncState := 0;
      if BreakPrepareDataFlag then
      begin
        SyncState := 0;
        goto FinDataProcessing;
      end;

    ////////////////////////////////////////////////////////////
    // Check and Dump Resulting File storage and  Source DB Copy
    //
      if PathNameFrame.Enabled then
      begin
      /////////////////////////////////
      //  Dump Resulting Files Storage
        N_Dump1Str( 'SAD>> Dump Source File Storage after' );
        LbInfo.Caption := 'Dump File Storage copy Existed ...';
        LbInfo.Refresh();
        DumpFSExisted( 'S1\FSDumpsAfter\' );
        N_Dump1Str( 'SAD>> Existed Files are build' );
        ProgressFormat := 'Dump File Storage Copy Needed, %d%% done';
        DumpFSNeeded( 'S1\FSDumpsAfter\' );
        N_Dump1Str( 'SAD>> Needed Files are build' );
        FSAfterExisted := AllExistedFList.Count;
        FSAfterNeeded  := AllNeededFList.Count;
        FSAfterArchived:= AllArchivedFList.Count;
        LbInfo.Caption := 'Dump File Storage Copy Extra/Missing ...';
//        AllNeededFList.AddStrings(AllArchivedFList);
        K_CMFSCompNeededExistedFLists( AllExistedFList, AllNeededFList, nil );
        N_Dump1Str( 'SAD>> Extra and Missing Files are build' );
        FSAfterExtra := AllExistedFList.Count;
        FSAfterMissing  := AllNeededFList.Count;
        LbInfo.Caption := '';
        K_AddStringToTextFile( MergeReportFName,
          format( 'Source File Storage copy after >> Existed=%d, Needed=%d, Extra=%d, Missing=%d Archived=%d',
                  [FSAfterExisted, FSAfterNeeded, FSAfterExtra, FSAfterMissing, FSAfterArchived] ) );

        // AllExistedFList contains Extra Files
        if AllExistedFList.Count > 0 then
        begin
          K_AddStringToTextFile( MergeInfoPath + 'S1\FSDumpsAfter\Extra.txt',
                                 AllExistedFList.Text );
          LbInfo.Caption := 'Remove Extra files from File Storage Copy ...';

          DeleteExtraFiles();

        end;

        // AllNeededFList contains Missing Files
        if AllNeededFList.Count > 0 then
          K_AddStringToTextFile( MergeInfoPath + 'S1\FSDumpsAfter\Missing.txt',
                                 AllNeededFList.Text );
      //  Dump Resulting Files Storage
      /////////////////////////////////

      //////////////////////////////////////////////////////
      // Dump Absent Patients in resulting AllPatients Table
        LbInfo.Caption := 'Dump Absent Patients info ...';
        LbInfo.Refresh();

        with CurSQLCommand1 do
        begin
          Connection := LANDBConnection;
          CommandText :=
            'DELETE FROM PAIDs1;'#10 +
            'INSERT PAIDs1 ( ID )' +
            ' SELECT DISTINCT ' + K_CMENDBSTFPatID +
            ' FROM ' + K_CMENDBSlidesTable + ';'#10 +
            'DELETE FROM PAIDs1 FROM ' + K_CMENDBAllPatientsTable +
            ' WHERE ' + K_CMENDBAllPatientsTable + '.' + K_CMENDAPBridgeID +
                                                   ' = PAIDs1.ID;';
          Execute;
{
CommandText := 'UNLOAD TABLE PAIDs1 TO ''' + MergeRootPath + 'DBData\2PAIDs1.dat''' +
' FORMAT BCP;';
Execute;
{}
        end; // with CurSQLCommand1 do
        DumpResStr := GetPatientsCount('PAIDs1');

        PatAddedAfterCount := StrToInt(DumpResStr);
        PatAddedD4WCount := PatAddedAfterCount;
        if PatAddedAfterCount > 0 then
        begin
           with CurDSet1 do
          begin
            Connection := LANDBConnection;
            Filtered := FALSE;
            SQL.Text := 'select count(*) from PAIDs1 where ID > 0;';
            Open();
            PatAddedD4WCount := Fields[0].AsInteger;
            Close();
          end; // with CurDSet1 do
          DumpResStr := format( 'D4W=%d SA=%d', [PatAddedD4WCount, PatAddedAfterCount - PatAddedD4WCount] );
          K_AddStringToTextFile( MergeReportFName, 'Source DB copy Absent Patients >> ' + DumpResStr );
        end;

      // Dump Absent Patients if resulting AllPatients Table
      //////////////////////////////////////////////////////
      end;
    //
    // Check and Dump Resulting File storage and  Source DB Copy
    ////////////////////////////////////////////////////////////

    /////////////////////////////////
    // Unload DB Data
    //
      LbInfo.Caption := 'Unload DB Data ...';
      LbInfo.Refresh();
      with CurSQLCommand1 do
      begin // Change if no copy files errors where detected
        UloadDataPath := MergeRootPath + 'DBData\';
        K_ForceDirPath(UloadDataPath);

        if ChBUnloadMedia.Checked then
        begin
    // DTCr > DATETIME( '1998-09-09 12:12:12.000' );
    // 'unload select * from ' + K_CMENDBSlidesTable + ' where ' + + ' > DATETIME('+format()+'00:00:00.000) TO ' +....

          K_FormCMSupport.ShowInfo( ' Unload DB data ', 'TK_FormCMUTPrepDBData.DoSynchPPL >>' );


          CommandText := 'UNLOAD TABLE ' + K_CMENDBMTypesTable +
                         ' TO ''' + UloadDataPath + K_CMENDBMTypesTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;

          CommandText := 'UNLOAD TABLE ' + K_CMENDBSlidesTable +
                         ' TO ''' + UloadDataPath + K_CMENDBSlidesTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;

          CommandText := 'UNLOAD TABLE ' + K_CMENDBDelMarkedSlidesTable +
                         ' TO ''' + UloadDataPath + K_CMENDBDelMarkedSlidesTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;
          Application.ProcessMessages;
        end; // if ChBUnloadMedia.Checked then

        if ChBUnloadPat.Checked then
        begin
          K_FormCMSupport.ShowInfo( ' Unload patients ', 'TK_FormCMUTPrepDBData.DoSynchPPL >>' );
          CommandText := 'UNLOAD TABLE ' + K_CMENDBAllPatientsTable +
                         ' TO ''' + UloadDataPath + K_CMENDBAllPatientsTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;
          Application.ProcessMessages;
        end; // if ChBUnloadPat.Checked then

        if ChBUnloadProv.Checked then
        begin
          K_FormCMSupport.ShowInfo( ' Unload Providers ', 'TK_FormCMUTPrepDBData.DoSynchPPL >>' );
          CommandText := 'UNLOAD TABLE ' + K_CMENDBAllProvidersTable +
                         ' TO ''' + UloadDataPath + K_CMENDBAllProvidersTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;
          Application.ProcessMessages;
        end; // if ChBUnloadProv.Checked then

        if ChBUnloadLoc.Checked then
        begin
          K_FormCMSupport.ShowInfo( ' Unload Locations ', 'TK_FormCMUTPrepDBData.DoSynchPPL >>' );
          CommandText := 'UNLOAD TABLE ' + K_CMENDBAllLocationsTable +
                         ' TO ''' + UloadDataPath + K_CMENDBAllLocationsTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;
          Application.ProcessMessages;
        end; // if ChBUnloadLoc.Checked then

        if ChBUnloadServ.Checked then
        begin
          K_FormCMSupport.ShowInfo( ' Unload Servers ', 'TK_FormCMUTPrepDBData.DoSynchPPL >>' );
          CommandText := 'UNLOAD TABLE ' + K_CMENDBAllServersTable +
                         ' TO ''' + UloadDataPath + K_CMENDBAllServersTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;
          Application.ProcessMessages;
        end; // if ChBUnloadServ.Checked then

        if ChBUnloadClient.Checked then
        begin
          K_FormCMSupport.ShowInfo( ' Unload Clients ', 'TK_FormCMUTPrepDBData.DoSynchPPL >>' );
          CommandText := 'UNLOAD TABLE ' + K_CMENDBGAInstsTable +
                         ' TO ''' + UloadDataPath + K_CMENDBGAInstsTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;
          Application.ProcessMessages;
        end; // if ChBUnloadClient.Checked then

        if ChBUnloadCont.Checked then
        begin
          K_FormCMSupport.ShowInfo( ' Unload Media Suite contexts ', 'TK_FormCMUTPrepDBData.DoSynchPPL >>' );
          CommandText := 'UNLOAD TABLE ' + K_CMENDBContextsTable +
                         ' TO ''' + UloadDataPath + K_CMENDBContextsTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;
          Application.ProcessMessages;
        end; // if ChBUnloadCont.Checked then

        if ChBUnloadStat.Checked then
        begin
          K_FormCMSupport.ShowInfo( ' Unload Statistics ', 'TK_FormCMUTPrepDBData.DoSynchPPL >>' );
          CommandText := 'UNLOAD TABLE ' + K_CMENDBSlidesHistTable +
                           ' TO ''' + UloadDataPath + K_CMENDBSlidesHistTable + '.dat''' +
                           ' FORMAT BCP;';
          Execute;

          CommandText := 'UNLOAD TABLE ' + K_CMENDBSlidesNewHistTable +
                           ' TO ''' + UloadDataPath + K_CMENDBSlidesNewHistTable + '.dat''' +
                           ' FORMAT BCP;';
          Execute;
    //  SELECT A.* FROM "dba"."AllSessionsHistory" A join allobjhistory B on A.AHSessionID = B.AHSessionID where B.AHActTS > datetime('2015-01-01 00:00:00.000');

          CommandText := 'UNLOAD TABLE ' + K_CMENDBSessionsHistTable +
                           ' TO ''' + UloadDataPath + K_CMENDBSessionsHistTable + '.dat''' +
                           ' FORMAT BCP;';
          Execute;

          CommandText := 'UNLOAD TABLE ' + K_CMENDBAllHistPatientsTable +
                         ' TO ''' + UloadDataPath + K_CMENDBAllHistPatientsTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;

          CommandText := 'UNLOAD TABLE ' + K_CMENDBAllHistProvidersTable +
                         ' TO ''' + UloadDataPath + K_CMENDBAllHistProvidersTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;

          CommandText := 'UNLOAD TABLE ' + K_CMENDBAllHistLocationsTable +
                         ' TO ''' + UloadDataPath + K_CMENDBAllHistLocationsTable + '.dat''' +
                         ' FORMAT BCP;';
          Execute;
          Application.ProcessMessages;
        end; // if ChBUnloadStat.Checked then
      end; // with CurSQLCommand1 do
    //
    // Unload DB Data
    /////////////////////////////////

//      K_CMShowMessageDlg1( '  Linking Data from' +
//                           RepStr + #13#10 +
//                           '      is finished.', mtInformation );
      //'     Linking Data from %s'#13#10'        is finished.'
//      K_CMShowMessageDlg1( format(K_CML1Form.LLLSynchFin.Caption, [RepStr]), mtInformation );
     // Check Results


{
      if not PathNameFrame.Enabled or
         ((FSAfterExtra <= FSBeforeExtra) and
          (FSAfterMissing <= FSBeforeMissing) and
          (PatD4WCount + PatSANormCount + PatAddedHistCount + PatSADelCount + PatAddedBeforeCount = AllPatCount + DelPatCount + OldPatCount + NAPatCount) and
          (SlidesD4WCount + SlidesSACount = TotalMedia + DelMCount + OldMCount + NAMCount) and
          (DTPFrom.Checked or
           ((FSAfterExisted - FSAfterExtra = FSBeforeExisted - FSBeforeExtra - DelFCount - OldFCount - NAFCount) and
            (FSAfterExisted = TotalFF)))) then
        CheckResStr := 'All is OK!!!'
      else
        CheckResStr := 'Something is not OK!!!';
}
      PatsOKFlag   := PatD4WCount + PatSANormCount + PatSADelCount + PatAddedBeforeCount = AllPatCount + DelPatCount + OldPatCount + NAPatCount;
      SlidesOKFlag := SlidesD4WCount + SlidesSACount = TotalMedia + DelMCount + OldMCount + NAMCount;
      FilesOKFlag  := FSAfterExisted - FSAfterExtra = FSBeforeExisted - FSBeforeExtra - DelFCount - OldFCount - NAFCount;

      if not PathNameFrame.Enabled or
         ( (FSAfterExtra   <= FSBeforeExtra)   and
           (FSAfterMissing <= FSBeforeMissing) and
           PatsOKFlag                          and
           SlidesOKFlag                        and
           ( DTPFrom.Checked or
             (FilesOKFlag and (FSAfterExisted = TotalFF)) )
          ) then
      begin
        CheckResStr := 'All is OK!!!';
        if DTPFrom.Checked then
          CheckResStr := CheckResStr + ' (Boundary date is used).'#13#10;
      end
      else
      begin
        CheckResStr := 'Something is not OK!!!';
        if FSAfterExtra > FSBeforeExtra then
          CheckResStr := CheckResStr + ' (Extra files are enlarged)';
        if FSAfterMissing > FSBeforeMissing then
          CheckResStr := CheckResStr + ' (Missing files are enlarged)';
        if not PatsOKFlag then
          CheckResStr := CheckResStr + ' (Patients copy not OK)';
        if not SlidesOKFlag then
          CheckResStr := CheckResStr + ' (Slides copy not OK)';
        if not DTPFrom.Checked then
        begin
          if not FilesOKFlag then
            CheckResStr := CheckResStr + ' (Files copy not OK)';
          if FSAfterExisted <> TotalFF then
            CheckResStr := CheckResStr + ' (Existed files not OK)';
        end
        else
          CheckResStr := CheckResStr + ' (Boundary date is used)';
        CheckResStr := CheckResStr + #13#10;
      end;

      CalcDBInfo( FALSE );
      K_AddStringToTextFile( MergeReportFName,
        format( 'Source DB copy >> Media objects: D4W=%d, SA=%d WPat=%d; Patients: D4W=%d, SA=%d',
                [SlidesD4WCount, SlidesSACount, SlidesWPatCount,
                 PatD4WCount, PatSANormCount] ) );


      K_AddStringToTextFile( MergeReportFName,
        format( 'Total from Source:'#13#10 +
                '%6d DB media objects,'#13#10 +
                '%6d corresponding Files and 3D folders.'#13#10,
                [SlidesD4WCount + SlidesSACount,
                 FSAfterExisted - FSAfterExtra] ) +
        CheckResStr + '#####' );


      if RepStr <> '' then
        RepStr := 'using ' + RepStr;

      K_CMShowMessageDlg1( format( '  Data preparing %s is finished.'#13#10 +
                                   '  All prepared data are in %s.'#13#10 +
                                   '  %s All details are in %s.',
                                  [RepStr,MergeRootPath,CheckResStr,MergeInfoPath]) , mtInformation );
      LbInfo.Caption := '';
      LbInfo.Refresh();

      // Create Report
      RebuildSyncInfoView();

      TmpStrings.Clear;
      TmpStrings.Add(';Linked');

      TmpStrings.Add( format( 'Patients;%d;', [PatCount] ) );
//      SGStateView.Cells[2,1] := IntToStr(PatCount);

      TmpStrings.Add( format( 'Dentists;%d;', [ProvCount] ) );
//      SGStateView.Cells[4,2] := IntToStr(ProvCount);

      TmpStrings.Add( format( 'Practices;%d', [LocCount] ) );
//      SGStateView.Cells[4,3] := IntToStr(LocCount);

//      TmpStrings.SaveToFile( CurSyncPath + 'Link_' + FNameDate + '.csv' );
//      N_Dump1Str( 'SAD>> Linking data' );
//      N_Dump1Strings( TmpStrings, 0 );

FinDataProcessing: // *******
      CopyLogs();
      Screen.Cursor := SavedCursor;
      if BreakPrepareDataFlag then
      begin
        K_CMShowMessageDlg1( 'Data preparing is finished abnormally.', mtWarning );
        K_AddStringToTextFile( MergeReportFName, 'Data preparing is finished abnormally.' );
      end;
      N_Dump1Str( 'SAD>> Prepare data Fin' );
    except
      on E: Exception do
      begin
        Screen.Cursor := SavedCursor;
        ExtDataErrorString := 'TK_FormCMUTPrepDBData.BtSyncClick ' + E.Message;
        CurDSet1.Close;
        ExtDataErrorCode := K_eeDBUpdate;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

end; // procedure TK_FormCMUTPrepDBData.DoSynchPPL

//***********************************  TK_FormCMUTPrepDBData.TestLinkFile  ******
// Test File while search Link files
//
function TK_FormCMUTPrepDBData.TestLinkFile( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  if AFileName = '' then
    Result := K_tucSkipSubTree
  else
    SyncFilesList.Add( AFileName );
end; // function TK_FormCMUTPrepDBData.TestLinkFile

//***********************************  TK_FormCMUTPrepDBData.TestPatientFile  ******
// Test patient Image or Video files
//
function TK_FormCMUTPrepDBData.TestPatientFile(const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  WSTR : string;
begin
  Result := K_tucOK;
  if DTPFrom.Checked and (AScanLevel = 1) and (AFileName = '') then
  begin
    WSTR := Copy( APathName, Length(APathName) - Length(StrMinDate) + 1, Length(StrMinDate) );
    if (WSTR < StrMinDate) then
    begin
      if K_ScanFilesTreeMaxLevel = 0 then
        N_Dump2Str( format( 'Skip %s < %s', [WSTR, StrMinDate] ) );
      Result := K_tucSkipSubTree;
//      Result := K_tucSkipSibling;
      Exit;
    end;
  end;

  if (AFileName = '') or (AFileName = '!') then Exit;

  PatFilesList.Add( APathName + AFileName );
end; // function TK_FormCMUTPrepDBData.TestLinkFile

//***********************************  TK_FormCMUTPrepDBData.FormCloseQuery ******
// FormCloseQuery Event Handler
//
procedure TK_FormCMUTPrepDBData.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := SyncState = 0; // to prevent formclose during data export
  if not CanClose then Exit;
  PatFilesList.Free;
  SyncFilesList.Free;
end;// procedure TK_FormCMUTPrepDBData.FormCloseQuery

procedure TK_FormCMUTPrepDBData.DTPFromChange(Sender: TObject);
begin
  with DTPFrom do
  if not Checked then
  begin
//    Date := 0;
    Format := ' ';
    Checked := FALSE;
//    ChBCopyMedia.Enabled := PathNameFrame.mbPathName.Text <> '';
//    LbCopyMedia.Enabled := ChBCopyMedia.Enabled;
    if PathNameFrame.Enabled and
       (SlidesD4WCount = 0)  and
       (PatSADelCount  = 0) then
    begin
      SavedMergeRootFolder := PathNameFrame.mbPathName.Text;
      PathNameFrame.mbPathName.Text := '';
      PathNameFrame.SetEnabledAll( FALSE );
      BtSync.Enabled := TRUE;
    end
  end
  else
  begin
    if Date < 1 then
      Date := Now() - 365;
    Format := 'dd/MM/yyyy';
//    if ChBCopyMedia.Enabled then
//    begin
//      ChBCopyMedia.Checked := TRUE;
//      ChBCopyMedia.Enabled := FALSE;
//      LbCopyMedia.Enabled := FALSE;
//    end;
    if not PathNameFrame.Enabled and
       (SlidesD4WCount = 0)  and
       (PatSADelCount  = 0) then
    begin
      PathNameFrame.SetEnabledAll( TRUE );
      PathNameFrame.mbPathName.Text := SavedMergeRootFolder;
      BtSync.Enabled := (SavedMergeRootFolder <> '');
    end
  end;
end; // procedure TK_FormCMUTPrepDBData.DTPFromChange

procedure TK_FormCMUTPrepDBData.ShowProgress( AllCount, CurCount: Integer);

begin
  ProgressShow := Round(100 * CurCount / AllCount);
  if ProgressShow > ProgressShowPrev then
  begin
    LbInfo.Caption := format( ProgressFormat, [ProgressShow] );
    ProgressShowPrev := ProgressShow;
//    LbInfo.Refresh();
    Self.Refresh();
  end;
end; // procedure TK_FormCMUTPrepDBData.ShowProgress

procedure TK_FormCMUTPrepDBData.CalcDBInfo( ACalcAddInfo : Boolean );
begin
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    Connection := LANDBConnection;
    Filtered := FALSE;

    SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable;
    Open();
    SlidesWPatCount := Fields[0].AsInteger;
    Close();

  // Slides of D4W patients
    SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable +
    ' where ' + K_CMENDBSTFPatID + ' > 0';
    Open();
    SlidesD4WCount := Fields[0].AsInteger;
    SlidesWPatCount := SlidesWPatCount - SlidesD4WCount;
    Close();

  // Slides of SA patients
    SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable +
    ' where ' + K_CMENDBSTFPatID + ' < -100';
    Open();
    SlidesSACount := Fields[0].AsInteger;
    SlidesWPatCount := SlidesWPatCount - SlidesSACount;
    Close();

    SlidesD4WArchCount := 0;
    SlidesSAArchCount := 0;
    if (K_CMEDDBVersion >= 41) and ACalcAddInfo then
    begin
      SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable +
      ' where ' + K_CMENDBSTFPatID + ' > 0 and ' + K_CMENDBSTFSlideThumbnail + ' is NULL' ;
      Open();
      SlidesD4WArchCount := Fields[0].AsInteger;
      SlidesD4WCount := SlidesD4WCount - SlidesD4WArchCount;
      Close();

      SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable +
      ' where ' + K_CMENDBSTFPatID + ' < -100 and ' + K_CMENDBSTFSlideThumbnail + ' is NULL' ;
      Open();
      SlidesSAArchCount := Fields[0].AsInteger;
      SlidesSACount := SlidesSACount - SlidesSAArchCount;
      Close();
    end;

  // All SA + D4W patients
    SQL.Text := 'select count(*) from ' + K_CMENDBAllPatientsTable;
    Open();
    PatD4WCount := Fields[0].AsInteger;
    Close();

  // All SA patients
    SQL.Text := 'select count(*) from ' + K_CMENDBAllPatientsTable +
    ' where ' + K_CMENDAPBridgeID + ' < -100';

    Open();
    PatSANormCount := Fields[0].AsInteger;
    PatD4WCount := PatD4WCount - PatSANormCount;
    Close();

    if not ACalcAddInfo then Exit;
    
  // Del SA patients
    SQL.Text := 'select count(*) from ' + K_CMENDBAllPatientsTable +
    ' where ' + K_CMENDAPFlags + ' > 0';
    Open();
    PatSADelCount := Fields[0].AsInteger;
    PatSANormCount := PatSANormCount - PatSADelCount;
    Close();

  end; // with CurDSet1 do

end; // procedure TK_FormCMUTPrepDBData.CalcDBInfo

procedure TK_FormCMUTPrepDBData.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := FALSE;
  if mrOK = K_CMShowMessageDlg(
         'The Source database contains archived objects. These archived objects cannot be unloaded'#13#10 +
         'from the Source Database. If you continue the unload they will not be included.'#13#10 +
         'If you want to include them, you need to restore the archived objects from archive first.'#13#10 +
         'Press OK to proceed without archived objects. Press Cancel to stop.', mtConfirmation,
         [mbOK, mbCancel], FALSE, 'MediaSuite Support' ) then Exit;
  N_Dump1Str( 'TK_FormCMUTPrepDBDat>> Cancel by user because of archived objects' );
  ModalResult := mrCancel;

end; // procedure TK_FormCMUTPrepDBData.TimerTimer

end.
