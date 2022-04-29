unit K_FCMUTSyncPPL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Grids,
  N_Types, N_BaseF,
  K_Types, K_CLib0, K_FPathNameFr, N_FNameFr;

type
  TK_FormCMUTSyncPPL = class(TN_BaseForm)
    BtCancel: TButton;
    PathNameFrame: TK_FPathNameFrame;
    BtSync: TButton;
    SGStateView: TStringGrid;
    LbInfo: TLabel;
    FileNameFrame: TN_FileNameFrame;
    procedure FormShow(Sender: TObject);
    procedure SGStateViewDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SGStateViewExit(Sender: TObject);
    procedure BtSyncClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    CurSyncPath : string;
    CurSyncFile : string;
    DstFilesPath : string;
    FNameDate : string;
    SkipSelectedDraw : Boolean;
    SyncFilesList, PatFilesList : TStringList;

    // Do Synchronize
    SyncState : Integer;
    LinkFileInd  : Integer;

    SavedCursor: TCursor;
    GetPatientPathName : function ( APatId : Integer ) : string of object;
    procedure OnPathChange();
    procedure OnFileChange();
    procedure RebuildSyncInfoView();
    function  TestLinkFile( const APathName, AFileName : string; AScanLevel : Integer ) : TK_ScanTreeResult;
    function  TestPatientFile( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  CopyFolderFiles( ASrcFolder, ADstFolder : string;
                               var AErrCount : Integer ): Integer;
    function  GetPatientPathName1( APatId : Integer ) : string;
    function  GetPatientPathName2( APatId : Integer ) : string;
    function  ExportMediaAndRemoveFromDB( const APathSegm : string; ASkipFilesCopy : Boolean;
                                          AExportDIBs : Boolean = FALSE ) : string;
    procedure DoSynchPPL();
  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMUTSyncPPL: TK_FormCMUTSyncPPL;

procedure K_CMUTSyncPPLDlg( );

implementation

{$R *.dfm}
uses DB, ADODB,
     N_Lib0, N_Lib1, N_CMMain5F, N_GRA2, N_Comp1,
     K_CM0, K_CML1F, K_CLib, K_RImage, K_UDT2;

//******************************************************** K_CMUTSyncPPLDlg ***
// Change Patients, Providers, Locations ID to syncronized it to PMS objects
//
procedure K_CMUTSyncPPLDlg( );
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

  K_FormCMUTSyncPPL := TK_FormCMUTSyncPPL.Create(Application);
  with K_FormCMUTSyncPPL do
  begin
//    BaseFormInit(nil);
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
    SGStateView.DefaultDrawing := FALSE;
{$IFEND CompilerVersion >= 26.0}
    N_Dump1Str( 'SAD>> before K_FormCMUTSyncPPL show' );
    ShowModal();
    N_Dump1Str( 'SAD>> after K_FormCMUTSyncPPL show' );
    K_FormCMUTSyncPPL := nil;
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

end; // K_CMUTSyncPPLDlg

//*********************************************** TK_FormCMSyncPPL.OnPathChange ***
//
procedure TK_FormCMUTSyncPPL.OnPathChange;
begin
  DstFilesPath := '';
  if PathNameFrame.TopName <> '' then
    DstFilesPath := IncludeTrailingPathDelimiter(PathNameFrame.TopName);

  BtSync.Enabled := (DstFilesPath <> '') and
                    ((CurSyncFile <> '') or ((SyncFilesList <> nil) and (SyncFilesList.Count > 0)));
end; // TK_FormCMSyncPPL.OnPathChange

//******************************************* TK_FormCMSyncPPL.OnFileChange ***
//
procedure TK_FormCMUTSyncPPL.OnFileChange;
begin
  CurSyncFile := FileNameFrame.mbFileName.Text;
  CurSyncPath := ExtractFilePath(CurSyncFile);
  if CurSyncPath <> '' then
  begin
    if SyncFilesList = nil then
      SyncFilesList := TStringList.Create
    else
      SyncFilesList.Clear;

    K_ScanFilesTree( CurSyncPath, TestLinkFile, '*_links_????-??-??.xml' );
  end; // if CurSyncPath <> '' then

  BtSync.Enabled := (DstFilesPath <> '') and
                    ((CurSyncFile <> '') or (SyncFilesList.Count > 0));

end; // TK_FormCMSyncPPL.OnFileChange

//*********************************************** TK_FormCMSyncPPL.FormShow ***
//
procedure TK_FormCMUTSyncPPL.FormShow(Sender: TObject);
var
  SelRect: TGridRect;
begin
{
  SGStateView.Cells[0,1] := K_CML1Form.LLLExpImpRowNames.Items[0];// 'Patients';
  SGStateView.Cells[0,2] := K_CML1Form.LLLExpImpRowNames.Items[1];// 'Dentists';
  SGStateView.Cells[0,3] := K_CML1Form.LLLExpImpRowNames.Items[2];// 'Practices';
  SGStateView.Cells[1,0] := K_CML1Form.LLLExpColNames.Items[0];// 'Total';
  SGStateView.Cells[2,0] := 'Linked';// 'Synchronized';
}
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

  RebuildSyncInfoView();

  BtSync.Enabled := FALSE;

  FileNameFrame.OnChange := OnFileChange;
  OnFileChange();

  PathNameFrame.SelectCaption := 'Change new root folder'; // 'Change new files  folder';
  PathNameFrame.OnChange := OnPathChange;
  DstFilesPath := PathNameFrame.mbPathName.Text;
  OnPathChange();

  SelRect.Left := -1;
  SelRect.Right := -1;
  SelRect.Top := -1;
  SelRect.Bottom := -1;
  SGStateView.Selection := SelRect;
end; // TK_FormCMSyncPPL.FormShow

//***********************************  TK_FormCMSyncPPL.CurStateToMemIni  ***
//
procedure TK_FormCMUTSyncPPL.CurStateToMemIni();
begin
  inherited;
  N_ComboBoxToMemIni( 'CMSSyncPPLPathsHistory', PathNameFrame.mbPathName );
  N_ComboBoxToMemIni( 'CMSSyncPPLFilesHistory', FileNameFrame.mbFileName );
end; // end of TK_FormCMSyncPPL.CurStateToMemIni

//***********************************  TK_FormCMSyncPPL.MemIniToCurState  ******
//
procedure TK_FormCMUTSyncPPL.MemIniToCurState();
begin
  inherited;
  N_MemIniToComboBox( 'CMSSyncPPLPathsHistory', PathNameFrame.mbPathName );
  PathNameFrame.AddNameToTop( PathNameFrame.mbPathName.Text );

  N_MemIniToComboBox( 'CMSSyncPPLFilesHistory', FileNameFrame.mbFileName );
  FileNameFrame.AddFileNameToTop( FileNameFrame.mbFileName.Text );
end; // end of TK_FormCMSyncPPL.MemIniToCurState

//***********************************  TK_FormCMSyncPPL.SGStateViewDrawCell  ******
// Info String Grid onDraw handler
//
procedure TK_FormCMUTSyncPPL.SGStateViewDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if SkipSelectedDraw then
  begin
    SkipSelectedDraw := FALSE;
    SGStateView.Canvas.Brush.Color := ColorToRGB(SGStateView.Color);
  end;
  K_CellDrawString( SGStateView.Cells[ACol,ARow], Rect, K_ppCenter, K_ppCenter, SGStateView.Canvas, 5, 0, 0 );
end; // procedure TK_FormCMSyncPPL.SGStateViewDrawCell

//***********************************  TK_FormCMSyncPPL.RebuildSyncInfoView  ******
// Rebuild Export Info View
//
procedure TK_FormCMUTSyncPPL.RebuildSyncInfoView;
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
      ExtDataErrorString := 'TK_FormCMSyncPPL.RebuildSyncInfoView ' + E.Message;
      CurDSet1.Close;
      ExtDataErrorCode := K_eeDBSelect;
      EDAShowErrMessage(TRUE);
    end;
  end;
}
end; // procedure TK_FormCMSyncPPL.RebuildSyncInfoView


//***********************************  TK_FormCMSyncPPL.SGStateViewExit  ******
// Info String Grid onExit handler
//
procedure TK_FormCMUTSyncPPL.SGStateViewExit(Sender: TObject);
begin
  SkipSelectedDraw := TRUE;
end; // procedure TK_FormCMSyncPPL.SGStateViewExit

//*****************************************  TK_FormCMSyncPPL.BtSyncClick ***
// BtSync onClick handler
//
procedure TK_FormCMUTSyncPPL.BtSyncClick(Sender: TObject);
begin
  if SyncState <> 0 then Exit;

  N_Dump1Str( 'SAD>> Synchronization Start ' + CurSyncPath );

  SyncState := 0;
  LinkFileInd := 0;
  if SyncFilesList.Count = 0 then
    LinkFileInd := -1     // single file - patients only
  else
    SyncFilesList.Sort(); // patients providers locations

  BtSync.Enabled := FALSE;
  BtCancel.Enabled := FALSE;
  DoSynchPPL();
  BtCancel.Enabled := TRUE;

end; // procedure TK_FormCMSyncPPL.BtSyncClick

//*********************************************** TK_FormCMSyncPPL.CopyPatientFiles ***
// Copy Patient Files
//
//    Parameters
// ASrcFolder - files source folder
// ADstFolder - files destination folder
// AErrCount  - on result copy errors number,
// Result - Returns number of copied files
//
function  TK_FormCMUTSyncPPL.CopyFolderFiles( ASrcFolder, ADstFolder : string;
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
    if CopyRes = 0 then Inc( Result );
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
  end;
end; // function TK_FormCMSyncPPL.CopyFolderFiles

function TK_FormCMUTSyncPPL.GetPatientPathName1( APatId: Integer): string;
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
end; // function TK_FormCMUTSyncPPL.GetPatientPathName1

function TK_FormCMUTSyncPPL.GetPatientPathName2( APatId: Integer): string;
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
end; // function TK_FormCMUTSyncPPL.GetPatientPathName2

//***************************** TK_FormCMSyncPPL.ExportMediaAndRemoveFromDB ***
//
function TK_FormCMUTSyncPPL.ExportMediaAndRemoveFromDB( const APathSegm : string;
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
        N_Dump1Str( 'Prepare remove info ' );
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
                                      [DstFilesPath,APathSegm,DstPatPath] );
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
// 2020-07-28 add Capt3DDevObjName <> '' if WCMSDB.Capt3DDevObjName = '' then
// 2020-09-25 add new condition for Dev3D objs
                if (WCMSDB.Capt3DDevObjName = '') or (WCMSDB.MediaFExt = '') then
                begin
                  SrcBasePath := SlidesImg3DRootFolder;
                  Img3DFName := K_CMSlideGetImg3DFolderName(SSlideD);
                  SrcFNamePref := SrcBasePath + LocPath + K_CMSlideGetFileDatePathSegm(CrDT);
                  CurSrcFName := SrcFNamePref + Img3DFName;
                  CurDstFName := DstFNamePref + Img3DFName;
                  if Copy3DFiles() then
                    Inc(DoneCount);
                end // if WCMSDB.Capt3DDevObjName = '' ... then
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
        N_Dump1Str( 'Delete from ' + K_CMENDBAllPatientsTable );
        Application.ProcessMessages;

        // Remove Contexts
        CommandText := 'DELETE FROM ' + K_CMENDBContextsTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBContextsTable + '.' + K_CMENDBCTFContID + ' = PAIDs.ID' +
            ' AND ' + K_CMENDBContextsTable + '.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actPatIni)) + ';';
        Execute;
        N_Dump1Str( 'Delete from ' + K_CMENDBContextsTable );
        Application.ProcessMessages;

        // Remove Slides Data
        CommandText := 'DELETE FROM ' + K_CMENDBSlidesTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBSlidesTable + '.' + K_CMENDBSTFPatID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'Delete from ' + K_CMENDBSlidesTable );
        Application.ProcessMessages;

        CommandText := 'DELETE FROM ' + K_CMENDBDelMarkedSlidesTable + ' FROM SLIDs ' +
          ' WHERE ' + K_CMENDBDelMarkedSlidesTable + '.' + K_CMENDMSlideID + ' = SLIDs.ID;';
        Execute;
        N_Dump1Str( 'Delete from ' + K_CMENDBDelMarkedSlidesTable );
        Application.ProcessMessages;

        // Remove Patient Statistics
        CommandText := 'DELETE FROM ' + K_CMENDBSessionsHistTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBSessionsHistTable + '.' + K_CMENDBSessionsHTFPatID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'Delete from ' + K_CMENDBSessionsHTFPatID );
        Application.ProcessMessages;

        CommandText := 'DELETE FROM ' + K_CMENDBAllHistPatientsTable + ' FROM PAIDs ' +
          ' WHERE ' + K_CMENDBAllHistPatientsTable + '.' + K_CMENDAHPatID + ' = PAIDs.ID;';
        Execute;
        N_Dump1Str( 'Delete from  ' + K_CMENDBAllHistPatientsTable );
        Application.ProcessMessages;

        // Remove Slides Statistics
        CommandText := 'DELETE FROM ' + K_CMENDBSlidesHistTable + ' FROM SLIDs ' +
          ' WHERE ' + K_CMENDBSlidesHistTable + '.' + K_CMENDBSlidesHTFSlideID + ' = SLIDs.ID;';
        Execute;
        N_Dump1Str( 'Delete from  ' + K_CMENDBSlidesHistTable );
        Application.ProcessMessages;

        // Remove Sessions Statistics
        CommandText := 'DELETE FROM ' + K_CMENDBSlidesNewHistTable + ' FROM SEIDs ' +
          ' WHERE ' + K_CMENDBSlidesNewHistTable + '.' + K_CMENDBSlidesNHTFSessionID + ' = SEIDs.ID;';
        Execute;
        N_Dump1Str( 'Delete from  ' + K_CMENDBSlidesNewHistTable );
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
        ExtDataErrorString := 'TK_FormCMSyncPPL.BtSyncClick ' + E.Message;
        CurDSet1.Close;
        ExtDataErrorCode := K_eeDBUpdate;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

end; // procedure TK_FormCMSyncPPL.ExportMediaAndRemoveFromDB

//*********************************************** TK_FormCMSyncPPL.DoSynchPPL ***
//
procedure TK_FormCMUTSyncPPL.DoSynchPPL();
var
  TotalProc, TotalOf : Integer;
  SNum : Integer;
  RepStr : string;
  PatCount, AllPatCount, ProvCount, LocCount : Integer;
  SyncStep : Integer;
  LinkDataType : Integer;

  FName : string;
  StoreProcName : string;
  ExportResStr : string;

//  PatFilesCount : Integer;
//  PatLinkCount : Integer;
  OldPatID, NewPatID : Integer;
  CurSrcFName, SrcPathSegm, DstPathSegm : string;
  ErrCount : Integer;
  DelimChar : char;

Label ContinueFilesLoop, ContinuePatCopyLoop;

  function GetPatientsCount() : string;
  begin
    // Show number of old Patients
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
    begin
      Connection := LANDBConnection;
      Filtered := FALSE;

    // Old Patients Total
      SQL.Text := 'select count(*) from PAIDs';
      Open();
      Result := Fields[0].AsString;
      Close();
    end; // with CurDSet1 do
  end; // function GetPatientsCount()

  // New code to prevent erros when existing PatID is meeted in NewID
  function CopyPatientsFileStorage( const SQLText : string ) : Integer;
  var
    NextProcMes : TDateTime;
  label LContinuePatCopyLoop;
  begin
    // Select Pairs
    with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
    begin
      CommandText :=
        'DELETE FROM PAIDs2;'#10 +
        'INSERT PAIDs2 ( ID1, ID2 ) ' + SQLText;
      Execute;
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

      LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[3], [0.0] );
      LbInfo.Refresh();

      //////////////////////////////////////////
      // Copy Corresponding Media Objects Files
      //
      NextProcMes := Now() + 1 / (24 * 3600);
      while not EOF do
      begin // All Patients Loop
        OldPatID := Fields[0].AsInteger;
        NewPatID := Fields[1].AsInteger;
        Next;
        N_Dump2Str( format( 'SAD>> Start PatID %d -> %d', [OldPatID,NewPatID] ) );

        SrcPathSegm := K_CMSlideGetPatientFilesPathSegm(OldPatID);
        DstPathSegm := K_CMSlideGetPatientFilesPathSegm(NewPatID);

        // Add Patient General Image Err Message
        TmpStrings.Add( format( 'Patient ID=%d was not synchronized >> image files errors', [OldPatID]) );
        SNum := CopyFolderFiles( SlidesImgRootFolder + SrcPathSegm,
                           DstFilesPath + K_ImgFolder + DstPathSegm,
                           ErrCount );

        TotalProc := TotalProc + SNum;
        TotalOf := TotalOf + PatFilesList.Count;
        if PatFilesList.Count > 0 then
          N_Dump2Str( format( 'SAD>> Copy image files %d of %d', [SNum, PatFilesList.Count] ) );

        if ErrCount > 0 then
          goto LContinuePatCopyLoop
        else
          TmpStrings.Delete(TmpStrings.Count - 1); // Remove Patient General Image  Err Message

        // Add Patient General Video Err Message
        TmpStrings.Add( format( 'Patient ID=%d was not synchronized >> video files errors', [OldPatID]) );
        SNum := CopyFolderFiles( SlidesMediaRootFolder + SrcPathSegm,
                           DstFilesPath + K_VideoFolder + DstPathSegm,
                           ErrCount );
        TotalProc := TotalProc + SNum;
        TotalOf := TotalOf + PatFilesList.Count;

        if PatFilesList.Count > 0 then
          N_Dump2Str( format( 'SAD>> Copy video files %d of %d', [SNum, PatFilesList.Count] ) );
        if ErrCount > 0 then
          goto LContinuePatCopyLoop
        else
          TmpStrings.Delete(TmpStrings.Count - 1); // Remove Patient General Video Err Message

        // Add Patient General Img3D Err Message
        TmpStrings.Add( format( 'Patient ID=%d was not synchronized >> Img3D files errors', [OldPatID]) );
        SNum := CopyFolderFiles( SlidesImg3DRootFolder + SrcPathSegm,
                           DstFilesPath + K_Img3DFolder + DstPathSegm,
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
        SGStateView.Cells[2,4] := format( '%d of %d', [TotalProc,TotalOf] );

        LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[3], [100 * PatCount / AllPatCount] );
        LbInfo.Refresh();
        if NextProcMes < Now() then
        begin
          Application.ProcessMessages();
          NextProcMes := Now() + 1 / (24 * 3600);
        end;
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
    end;
  end; // function CopyPatientsFileStorage
  

begin
//
  RepStr := '';
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  SyncState := 1;
  PatCount  := 0;
  ProvCount := 0;
  LocCount  := 0;

  LbInfo.Caption := 'Clear new root folder';
  LbInfo.Refresh();
  K_DeleteFolderFiles(DstFilesPath);

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
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

        RepStr := RepStr + #13#10 + FName;
        N_Dump1Str( 'SAD>> Sync by file ' + FName );

        LbInfo.Caption := format( K_CML1Form.LLLExpProcTexts.Items[4], [FName, 1] );
        LbInfo.Refresh();

        K_VFLoadText( StrTextBuf, CurSyncPath + FName );
//        TmpStrings.LoadFromFile( CurSyncPath + FName );
//        StrTextBuf := TmpStrings.Text;
          // Exec Procedure
        if StrTextBuf[1] = '<' then //*** XML link data
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
          end // with CurStoredProc1 do
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
            ////////////////////////////
            // Deleted Patients Processing
            //
            N_Dump1Str( 'Start Deleted Patients processing' );
            CommandText :=
              'INSERT PAIDs ( ID )' +
              ' SELECT ' + K_CMENDAPBridgeID +
              ' FROM ' + K_CMENDBAllPatientsTable +
              ' WHERE ' + K_CMENDAPFlags + ' <> 0;';
            Execute;
            Application.ProcessMessages();
            N_Dump1Str( 'Prep Deleted Patients IDs' );
            // Show number of deleted Patients
            SGStateView.Cells[1,1] := GetPatientsCount();

//            ExportMediaAndRemoveFromDB( '', TRUE );

              ////////////////////
              // Add Files Export
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

            ExportResStr := ExportMediaAndRemoveFromDB( 'Deleted', FALSE );
            SGStateView.Cells[2,1] := ExportResStr;

            CurDSet3.Close();

            if ExportResStr <> '' then
            begin
              LbInfo.Caption := format( '%s Deleted media objects are exported', [ExportResStr] );
              LbInfo.Refresh();
              N_Dump1Str( LbInfo.Caption );
            end;
              //
              // end of Add Files Export
              ///////////////////////////

            N_Dump1Str( 'Fin Deleted Patients processing' );
            //
            // Deleted Patients Processing
            ////////////////////////////

            ////////////////////////////
            // Temporary add absent Patients from AllSlides Table
            // to AllPatients Table
            CommandText :=
              'INSERT PAIDs1 ( ID )' +
              ' SELECT DISTINCT ' + K_CMENDBSTFPatID +
              ' FROM ' + K_CMENDBSlidesTable + ';'#10 +
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
            //
            ////////////////////////////

            ////////////////////////////
            // Old Patients Processing
            //
            N_Dump1Str( 'Start Old Patients processing' );
            CommandText :=
              'DELETE FROM PAIDs;'#10 +
              'INSERT PAIDs ( ID )' +
              ' SELECT DISTINCT ' + K_CMENDBSTFPatID +
              ' FROM ' + K_CMENDBSlidesTable + ';'#10 +
              'DELETE FROM PAIDs FROM ' + K_CMENDBImportLinkIDsTable +
              ' WHERE ' + K_CMENDBImportLinkIDsTable + '.' + K_CMENDILIOldID +
                                                     ' = PAIDs.ID;';
            Execute;

            Application.ProcessMessages();
            N_Dump1Str( 'Prep Old Patients IDs' );

            // Show number of old Patients
            SGStateView.Cells[1,2] := GetPatientsCount();


            if SGStateView.Cells[1,2] <> '0' then
            begin // unload old Patients IDs
              CommandText := 'UNLOAD TABLE PAIDs TO ''' +
                             CurSyncPath + 'OldPatientsIDs.txt''' +
                             ' FORMAT TEXT;';
              Execute;
            end;

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

            ExportResStr := ExportMediaAndRemoveFromDB( 'Old', FALSE );
            SGStateView.Cells[2,2] := ExportResStr;
            CurDSet3.Close();

            if ExportResStr <> '' then
            begin
              LbInfo.Caption := format( '%s old media objects are exported', [ExportResStr] );
              LbInfo.Refresh();
              N_Dump1Str( LbInfo.Caption );
            end;

            N_Dump1Str( 'Fin Old Patients processing' );
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

            CommandText := 'UNLOAD TABLE PAIDs2 to ''D:\Delphi_prj_new\DTmp\ErrLogs\2018\2018-01-15_MergeDB_34_35\ChangePatIDs1101.txt''';
            Execute;

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
            N_Dump1Str( 'Start NA Patients processing' );
            CommandText :=
              'DELETE FROM PAIDs;'#10 +
              'INSERT PAIDs ( ID )' +
              ' SELECT ' + K_CMENDILIOldID +
              ' FROM ' + K_CMENDBImportLinkIDsTable +
              ' WHERE ' + K_CMENDILINewID + ' = -1;';

            Execute;
            Application.ProcessMessages();
            N_Dump1Str( 'Prep NA Patients IDs' );

            // Show number of NA Patients
            SGStateView.Cells[1,3] := GetPatientsCount();

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

            ExportResStr := ExportMediaAndRemoveFromDB( 'NA', FALSE );
            SGStateView.Cells[2,3] := ExportResStr;

            CurDSet3.Close();
            if ExportResStr <> '' then
            begin
              LbInfo.Caption := format( '%s NA media objects are exported', [ExportResStr] );
              LbInfo.Refresh();
              N_Dump1Str( LbInfo.Caption );
            end;
            N_Dump1Str( 'Fin NA Patients processing' );
            //
            // NA Patients Processing
            ////////////////////////////

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
            SGStateView.Cells[1,4] := GetPatientsCount();
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

            // Copy files for all not changing ID patients
{}     // Copy files for all changing ID patients Loop
            while 0 <> CopyPatientsFileStorage(
              'SELECT P.' + K_CMENDILIOldID + ', P.' + K_CMENDILINewID +
              ' FROM ' + K_CMENDBImportLinkIDsTable + ' P' +
              ' JOIN ' + K_CMENDBAllPatientsTable   + ' A' +
              ' ON A.' + K_CMENDAPBridgeID + ' = P.' + K_CMENDILIOldID + ' WHERE ' +
                 ' P.' + K_CMENDILINewID + ' <> -1 AND ' +
                 ' P.' + K_CMENDILIOldID + ' <> P.' + K_CMENDILINewID + ' AND ' +
                 ' NOT EXISTS (SELECT 1 FROM ' + K_CMENDBAllPatientsTable + ' WHERE ' + K_CMENDAPBridgeID + ' = P.'  + K_CMENDILINewID + ') ;' )
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
{}
            N_Dump1Str( format( 'SAD>> Total files %d of %d were copied', [TotalProc,TotalOf]) );


            if TmpStrings.Count > 0 then
            begin
            // Some errors where detected
              CurSrcFName := CurSyncPath + 'CopyMediaFilesErrors_' + FNameDate + '.txt';
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


              ////////////////////////////////////////
              // Change Image and Video Paths
              //
//            if TmpStrings.Count = 0 then Change DB paths even if errors were detected
//            with CurSQLCommand1 do
            begin // Change if no copy files errors where detected
              CommandText := 'UPDATE ' + K_CMENDBGlobAttrsTable +
              ' SET ' + K_CMENDBGTFImgFPath   + ' =  ''>' + K_CMDBFilePathPrepStr(DstFilesPath) + K_ImgFolder   + ''', ' +
                        K_CMENDBGTFMediaFPath + ' =  ''>' + K_CMDBFilePathPrepStr(DstFilesPath) + K_VideoFolder + ''', ' +
                        K_CMENDBGTFImg3DFPath + ' =  ''>' + K_CMDBFilePathPrepStr(DstFilesPath) + K_Img3DFolder + ''';';
              Execute;
              SlidesImgRootFolder   := DstFilesPath + K_ImgFolder;
              SlidesMediaRootFolder := DstFilesPath  + K_VideoFolder;
              SlidesImg3DRootFolder := DstFilesPath  + K_Img3DFolder;
              N_Dump1Str( 'SAD>> Set new Files Storage paths:'#13#10+
               'ImgRootFolder "' + SlidesImgRootFolder + '"'#13#10+
               'VideoRootFolder "' + SlidesMediaRootFolder + '"'#13#10+
               'Img3DRootFolder "' + SlidesImg3DRootFolder + '"' );
            end;
            //
            // Change Image and Video Paths
            ////////////////////////////

            ////////////////////////////
            // Remove Temporary added Patients from AllPatients
            CommandText := 'DELETE FROM ' + K_CMENDBAllPatientsTable + ' FROM PAIDs1 ' +
              ' WHERE ' + K_CMENDBAllPatientsTable + '.' + K_CMENDAPBridgeID +
                                                     ' = PAIDs1.ID;';
            Execute;
            N_Dump1Str( 'SAD>> Remove temporary added patients ' );

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
      end; // while LinkFileInd < SyncFilesList.Count do

      SyncState := 0;

//      K_CMShowMessageDlg1( '  Linking Data from' +
//                           RepStr + #13#10 +
//                           '      is finished.', mtInformation );
      //'     Linking Data from %s'#13#10'        is finished.'
//      K_CMShowMessageDlg1( format(K_CML1Form.LLLSynchFin.Caption, [RepStr]), mtInformation );
      K_CMShowMessageDlg1( format('  Linking Data from %s'#13#10+
                                  '      is finished.'#13#10#13#10+
                                  '  New Files storage at %s'#13#10+
                                  '       is created.', [RepStr,DstFilesPath]), mtInformation );

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

      Screen.Cursor := SavedCursor;

      N_Dump1Str( 'SAD>> Linking data Fin' );
    except
      on E: Exception do
      begin
        Screen.Cursor := SavedCursor;
        ExtDataErrorString := 'TK_FormCMSyncPPL.BtSyncClick ' + E.Message;
        CurDSet1.Close;
        ExtDataErrorCode := K_eeDBUpdate;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end;

end; // procedure TK_FormCMSyncPPL.DoSynchPPL

//***********************************  TK_FormCMSyncPPL.TestLinkFile  ******
// Test File while search Link files
//
function TK_FormCMUTSyncPPL.TestLinkFile( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  if AFileName = '' then
    Result := K_tucSkipSubTree
  else
    SyncFilesList.Add( AFileName );
end; // function TK_FormCMSyncPPL.TestLinkFile

//***********************************  TK_FormCMSyncPPL.TestPatientFile  ******
// Test patient Image or Video files
//
function TK_FormCMUTSyncPPL.TestPatientFile(const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  PatFilesList.Add( APathName + AFileName );
end; // function TK_FormCMSyncPPL.TestLinkFile

//***********************************  TK_FormCMSyncPPL.FormCloseQuery ******
// FormCloseQuery Event Handler
//
procedure TK_FormCMUTSyncPPL.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := SyncState = 0; // to prevent formclose during data export
  if not CanClose then Exit;
  PatFilesList.Free;
  SyncFilesList.Free;
end;// procedure TK_FormCMSyncPPL.FormCloseQuery

end.
