unit K_FCMUTUnloadDBData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  K_Types, K_FPathNameFr, N_BaseF;

type
  TK_FormCMUTUnloadDBData = class(TN_BaseForm)
    GBAll: TGroupBox;
    ChBUnloadPat: TCheckBox;
    ChBUnloadProv: TCheckBox;
    BtCancel: TButton;
    ChBUnloadLoc: TCheckBox;
    ChBUnloadCont: TCheckBox;
    ChBUnloadStat: TCheckBox;
    PathNameFrame: TK_FPathNameFrame;
    BtUnload: TButton;
    LbPatients: TLabel;
    LbProviders: TLabel;
    LbLocations: TLabel;
    LbServers: TLabel;
    LbClients: TLabel;
    LbAppContexts: TLabel;
    LbStatistics: TLabel;
    LbMedia: TLabel;
    ChBUnloadServ: TCheckBox;
    ChBUnloadClient: TCheckBox;
    ChBUnloadMedia: TCheckBox;
    LbCopyMedia: TLabel;
    ChBCopyMedia: TCheckBox;
    StatusBar: TStatusBar;
    LbFrom: TLabel;
    DTPFrom: TDateTimePicker;
    LbInfo: TLabel;
    procedure BtUnloadClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DTPFromChange(Sender: TObject);
  private
    { Private declarations }
    StrMinDate : string;
    procedure PathChange();
    procedure CopyRootFolderFiles(const ASrcRootFolder, ADstRootFolder : string);
    function  TestFileStorageFolder( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMUTUnloadDBData: TK_FormCMUTUnloadDBData;

procedure K_CMUTUnloadDBDataDlg();

implementation

{$R *.dfm}

uses K_CLib0, K_CM0, K_FCMSupport,
     N_Lib0, N_Lib1, N_Types;

//*************************************************** K_CMUTUnloadDBDataDlg ***
// Unload Data to Load to other DB
//
procedure K_CMUTUnloadDBDataDlg();
begin

  K_FormCMUTUnloadDBData := TK_FormCMUTUnloadDBData.Create(Application);
  with K_FormCMUTUnloadDBData do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    PathNameFrame.OnChange := PathChange;
    K_FormCMSupport.InfoStatusBar := StatusBar;
    ShowModal();
    K_FormCMSupport.InfoStatusBar := K_FormCMSupport.StatusBar;
    K_FormCMUTUnloadDBData := nil;
  end;

end; // K_CMUTUnloadDBDataDlg

procedure TK_FormCMUTUnloadDBData.BtUnloadClick(Sender: TObject);
var
  WRootPath : string;
  DBDataRootPath : string;
  SavedCursor: TCursor;
begin
  with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
  begin
    if not ChBCopyMedia.Enabled then
      WRootPath := ExtractFilePath(ExcludeTrailingPathDelimiter(SlidesImgRootFolder))
    else
      WRootPath := IncludeTrailingPathDelimiter(PathNameFrame.mbPathName.Text);


    DBDataRootPath := WRootPath + 'DBData\';
    if mrYes <> K_CMShowMessageDlg( '      DB data will be unloaded to ' + #13#10 +
                                    DBDataRootPath + #13#10 +
                                    '      Press Yes to Continue',
                                    mtConfirmation ) then
      Exit;

    // Start Utility

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;

    Connection := LANDBConnection;

    K_ForceDirPath( DBDataRootPath );

    BtUnload.Enabled := FALSE;
    BtCancel.Enabled := FALSE;

//    StrMinDate := 'DATETIME(''' + K_DateTimeToStr( DTPFrom.Date, 'yyyy-mm-dd') + ' 00:00:00.000'')';
    StrMinDate := EDADBDateTimeToSQL( DTPFrom.Date, 'yyyy-mm-dd 00:00:00.000' );

    if ChBUnloadMedia.Checked then
    begin
// DTCr > DATETIME( '1998-09-09 12:12:12.000' );
// 'unload select * from ' + K_CMENDBSlidesTable + ' where ' + + ' > DATETIME('+format()+'00:00:00.000) TO ' +....

      K_FormCMSupport.ShowInfo( ' Unload media objects ', 'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );

      if DTPFrom.Checked then
      begin
        CommandText := 'DROP TABLE IF EXISTS SelectedIDs;' + #10 +
                       'CREATE LOCAL TEMPORARY TABLE SelectedIDs (ID int) NOT TRANSACTIONAL;' + #10 +
                       'INSERT SelectedIDs (ID)' +
                       ' SELECT ' + K_CMENDBSTFSlideID + ' FROM ' + K_CMENDBSlidesTable +
                       ' WHERE ' + K_CMENDBSTFSlideDTCr + ' > ' + StrMinDate + ';';
        Execute;
      end;

      CommandText := 'UNLOAD TABLE ' + K_CMENDBMTypesTable +
                     ' TO ''' + DBDataRootPath + K_CMENDBMTypesTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;

      if DTPFrom.Checked then
        CommandText := 'UNLOAD SELECT A.* FROM ' + K_CMENDBSlidesTable +
                       ' A JOIN SelectedIDs B on A.' + K_CMENDBSTFSlideID + ' = B.ID ' +
                       ' TO ''' + DBDataRootPath + K_CMENDBSlidesTable + '.dat''' +
                       ' FORMAT BCP;'
      else
        CommandText := 'UNLOAD TABLE ' + K_CMENDBSlidesTable +
                       ' TO ''' + DBDataRootPath + K_CMENDBSlidesTable + '.dat''' +
                       ' FORMAT BCP;';
      Execute;

      if DTPFrom.Checked then
        CommandText := 'UNLOAD SELECT A.* FROM ' + K_CMENDBDelMarkedSlidesTable +
                       ' A JOIN SelectedIDs B on A.' + K_CMENDMSlideID + ' = B.ID ' +
                       ' TO ''' + DBDataRootPath + K_CMENDBDelMarkedSlidesTable + '.dat''' +
                       ' FORMAT BCP;'
      else
        CommandText := 'UNLOAD TABLE ' + K_CMENDBDelMarkedSlidesTable +
                       ' TO ''' + DBDataRootPath + K_CMENDBDelMarkedSlidesTable + '.dat''' +
                       ' FORMAT BCP;';
      Execute;
      Application.ProcessMessages;
    end; // if ChBUnloadMedia.Checked then

    if ChBUnloadPat.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Unload patients ', 'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );
      CommandText := 'UNLOAD TABLE ' + K_CMENDBAllPatientsTable +
                     ' TO ''' + DBDataRootPath + K_CMENDBAllPatientsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      Application.ProcessMessages;
    end; // if ChBUnloadPat.Checked then

    if ChBUnloadProv.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Unload Providers ', 'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );
      CommandText := 'UNLOAD TABLE ' + K_CMENDBAllProvidersTable +
                     ' TO ''' + DBDataRootPath + K_CMENDBAllProvidersTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      Application.ProcessMessages;
    end; // if ChBUnloadProv.Checked then

    if ChBUnloadLoc.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Unload Locations ', 'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );
      CommandText := 'UNLOAD TABLE ' + K_CMENDBAllLocationsTable +
                     ' TO ''' + DBDataRootPath + K_CMENDBAllLocationsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      Application.ProcessMessages;
    end; // if ChBUnloadLoc.Checked then

    if ChBUnloadServ.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Unload Servers ', 'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );
      CommandText := 'UNLOAD TABLE ' + K_CMENDBAllServersTable +
                     ' TO ''' + DBDataRootPath + K_CMENDBAllServersTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      Application.ProcessMessages;
    end; // if ChBUnloadServ.Checked then

    if ChBUnloadClient.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Unload Clients ', 'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );
      CommandText := 'UNLOAD TABLE ' + K_CMENDBGAInstsTable +
                     ' TO ''' + DBDataRootPath + K_CMENDBGAInstsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      Application.ProcessMessages;
    end; // if ChBUnloadClient.Checked then

    if ChBUnloadCont.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Unload Media Suite contexts ', 'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );
      CommandText := 'UNLOAD TABLE ' + K_CMENDBContextsTable +
                     ' TO ''' + DBDataRootPath + K_CMENDBContextsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      Application.ProcessMessages;
    end; // if ChBUnloadCont.Checked then

    if ChBUnloadStat.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Unload Statistics ', 'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );
      if DTPFrom.Checked then
        CommandText := 'UNLOAD SELECT * FROM ' + K_CMENDBSlidesHistTable +
                       ' WHERE ' + K_CMENDBSlidesHTFActTS + ' > ' + StrMinDate +
                       ' TO ''' + DBDataRootPath + K_CMENDBSlidesHistTable + '.dat''' +
                       ' FORMAT BCP;'
      else
        CommandText := 'UNLOAD TABLE ' + K_CMENDBSlidesHistTable +
                       ' TO ''' + DBDataRootPath + K_CMENDBSlidesHistTable + '.dat''' +
                       ' FORMAT BCP;';
      Execute;

      if DTPFrom.Checked then
      begin
        CommandText := 'DELETE FROM SelectedIDs;' + #10 +
                       'INSERT SelectedIDs (ID)' +
                       ' SELECT DISTINCT ' + K_CMENDBSlidesNHTFSessionID + ' FROM ' + K_CMENDBSlidesNewHistTable +
                       ' WHERE ' + K_CMENDBSlidesNHTFActTS + ' > ' + StrMinDate +
                       ' AND ' + K_CMENDBSlidesNHTFSessionID + '<> 0' +
                       ' ORDER BY ' + K_CMENDBSlidesNHTFSessionID + ' ASC;';
        Execute;

        CommandText := 'UNLOAD SELECT A.* FROM ' + K_CMENDBSlidesNewHistTable +
                       ' A JOIN SelectedIDs B on A.' + K_CMENDBSlidesNHTFSessionID + ' = B.ID ' +
                       ' TO ''' + DBDataRootPath + K_CMENDBSlidesNewHistTable + '.dat''' +
                       ' FORMAT BCP;';
        Execute;
        // Add events with 0 session ID (this events are added to statistics in some cases
        // - close CMS before start session
        // - delete slides utillty in Support
        CommandText := 'UNLOAD SELECT * FROM ' + K_CMENDBSlidesNewHistTable +
                       ' WHERE ' + K_CMENDBSlidesNHTFSessionID + ' = 0' +
                       ' AND ' + K_CMENDBSlidesNHTFActTS + ' > ' + StrMinDate +
                       ' TO ''' + DBDataRootPath + K_CMENDBSlidesNewHistTable + '.dat''' +
                       ' FORMAT BCP APPEND ON;';
      end
      else
        CommandText := 'UNLOAD TABLE ' + K_CMENDBSlidesNewHistTable +
                       ' TO ''' + DBDataRootPath + K_CMENDBSlidesNewHistTable + '.dat''' +
                       ' FORMAT BCP;';
      Execute;
//  SELECT A.* FROM "dba"."AllSessionsHistory" A join allobjhistory B on A.AHSessionID = B.AHSessionID where B.AHActTS > datetime('2015-01-01 00:00:00.000');
      if DTPFrom.Checked then
        CommandText := 'UNLOAD SELECT A.* FROM ' + K_CMENDBSessionsHistTable +
                       ' A JOIN SelectedIDs B on A.' + K_CMENDBSessionsHTFSessionID + ' = B.ID ' +
                       ' TO ''' + DBDataRootPath + K_CMENDBSessionsHistTable + '.dat''' +
                       ' FORMAT BCP;'
      else
        CommandText := 'UNLOAD TABLE ' + K_CMENDBSessionsHistTable +
                       ' TO ''' + DBDataRootPath + K_CMENDBSessionsHistTable + '.dat''' +
                       ' FORMAT BCP;';
      Execute;

      CommandText := 'UNLOAD TABLE ' + K_CMENDBAllHistPatientsTable +
                     ' TO ''' + DBDataRootPath + K_CMENDBAllHistPatientsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;

      CommandText := 'UNLOAD TABLE ' + K_CMENDBAllHistProvidersTable +
                     ' TO ''' + DBDataRootPath + K_CMENDBAllHistProvidersTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;

      CommandText := 'UNLOAD TABLE ' + K_CMENDBAllHistLocationsTable +
                     ' TO ''' + DBDataRootPath + K_CMENDBAllHistLocationsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      Application.ProcessMessages;
    end; // if ChBUnloadStat.Checked then

    if ChBCopyMedia.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Copy image files, please wait ... ',
                                'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );

      StrMinDate := IncludeTrailingPathDelimiter(K_CMSlideGetFileDatePathSegm( DTPFrom.Date ));

      CopyRootFolderFiles( SlidesImgRootFolder, WRootPath + K_ImgFolder );
//      K_CopyFolderFiles( SlidesImgRootFolder, WRootPath + 'Img\' );
      Application.ProcessMessages;

      K_FormCMSupport.ShowInfo( ' Copy video files, please wait ...  ',
                                'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );

      CopyRootFolderFiles( SlidesMediaRootFolder, WRootPath + K_VideoFolder );
//    K_CopyFolderFiles( SlidesMediaRootFolder, WRootPath + 'Video\' );

      K_FormCMSupport.ShowInfo( ' Copy 3D files, please wait ...  ',
                                'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );
      CopyRootFolderFiles( SlidesImg3DRootFolder, WRootPath + K_Img3DFolder );
//      K_CopyFolderFiles( SlidesImg3DRootFolder, WRootPath + 'Img3D\' );
    end; // if ChBUnloadMedia.Checked then

    K_FormCMSupport.ShowInfo( ' All is done ',
                              'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );

    if DTPFrom.Checked then
    begin
      CommandText := 'DROP TABLE IF EXISTS SelectedIDs;';
      Execute;
    end;

    Screen.Cursor := SavedCursor;
    BtUnload.Enabled := TRUE;
    BtCancel.Enabled := TRUE;
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do

end; // procedure TK_FormCMUTUnloadDBData.BtUnloadClick

procedure TK_FormCMUTUnloadDBData.FormShow(Sender: TObject);
begin
  PathChange();
end; // procedure TK_FormCMUTUnloadDBData.FormShow

procedure TK_FormCMUTUnloadDBData.DTPFromChange(Sender: TObject);
begin
  with DTPFrom do
  if not Checked then
  begin
//    Date := 0;
    Format := ' ';
    Checked := FALSE;
    ChBCopyMedia.Enabled := PathNameFrame.mbPathName.Text <> '';
    LbCopyMedia.Enabled := ChBCopyMedia.Enabled;
  end
  else
  begin
    if Date < 1 then
      Date := Now() - 365;
    Format := 'dd/MM/yyyy';
    if ChBCopyMedia.Enabled then
    begin
      ChBCopyMedia.Checked := TRUE;
      ChBCopyMedia.Enabled := FALSE;
      LbCopyMedia.Enabled := FALSE;
    end;
  end;
end; // procedure TK_FormCMUTUnloadDBData.DTPFromChange

procedure TK_FormCMUTUnloadDBData.PathChange;
begin
  ChBCopyMedia.Enabled := PathNameFrame.mbPathName.Text <> '';
  DTPFrom.Enabled := ChBCopyMedia.Enabled;
  if not ChBCopyMedia.Enabled then
  begin
    DTPFrom.Checked := FALSE;
    DTPFromChange(DTPFrom);
    ChBCopyMedia.Checked := FALSE;
  end;
  LbFrom.Enabled := ChBCopyMedia.Enabled;
  LbCopyMedia.Enabled := ChBCopyMedia.Enabled;
end; // procedure TK_FormCMUTUnloadDBData.PathChange

procedure TK_FormCMUTUnloadDBData.CopyRootFolderFiles(const ASrcRootFolder, ADstRootFolder : string);
var
  i : Integer;
  n : Integer;
  WParh, WPathSegm : string;
begin
//  if not DTPFrom.Checked then
//    K_CopyFolderFiles( ASrcRootFolder, ADstRootFolder )
//  else
  begin
    K_CMEDAccess.TmpStrings.Clear();
    K_ScanFilesTreeMaxLevel := 3; // to test folders build from date
    K_ScanFilesTree( ASrcRootFolder, TestFileStorageFolder, '*.*', FALSE );
    K_ScanFilesTreeMaxLevel := 0;
    n := Length(ASrcRootFolder) + 1;
    for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
    begin
      LbInfo.Caption := format( ' %d of %d folders are copied',
                                [i, K_CMEDAccess.TmpStrings.Count]);
      LbInfo.Refresh();
      WParh := K_CMEDAccess.TmpStrings[i];
      WPathSegm := Copy( WParh, n, Length(WParh) );
      K_CopyFolderFiles( WParh, ADstRootFolder + WPathSegm );
      LbInfo.Refresh();
      Application.ProcessMessages();
    end;

    K_FormCMSupport.ShowInfo( format( ' %d folders are copied', [K_CMEDAccess.TmpStrings.Count] ),
                                'TK_FormCMUTUnloadDBData.BtUnloadClick >>' );
    LbInfo.Caption := '';
  end;

end; // procedure TK_FormCMUTUnloadDBData.CopyRootFolderFiles

function TK_FormCMUTUnloadDBData.TestFileStorageFolder(const APathName,
  AFileName: string; AScanLevel: Integer): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  if (AFileName = '') or (AScanLevel < K_ScanFilesTreeMaxLevel) or
     (Length(AFileName) <> 11 ) or (DTPFrom.Checked and (AFileName < StrMinDate))  then Exit;

  K_CMEDAccess.TmpStrings.Add( APathName + AFileName );
end; // function TK_FormCMUTUnloadDBData.TestFileStorageFolder

procedure TK_FormCMUTUnloadDBData.MemIniToCurState;
var
  WStr : string;
begin
  inherited;
  N_MemIniToComboBox( 'CMSUnloadDBDataPathsHistory', PathNameFrame.mbPathName );
  PathNameFrame.AddNameToTop( PathNameFrame.mbPathName.Text );
  WStr := N_MemIniToString('CMSUnloadDBData', 'DTPFrom', '');
  if WStr = '' then
    DTPFrom.Date := 0.5
  else
    DTPFrom.Date := K_StrToDateTime( WStr );
  DTPFrom.Checked := N_MemIniToBool( 'CMSUnloadDBData', 'DTPFromEnabled', FALSE );
  DTPFromChange(DTPFrom);

end; // procedure TK_FormCMUTUnloadDBData.MemIniToCurState

procedure TK_FormCMUTUnloadDBData.CurStateToMemIni;
begin
  inherited;
  N_ComboBoxToMemIni( 'CMSUnloadDBDataPathsHistory', PathNameFrame.mbPathName );
  N_BoolToMemIni( 'CMSUnloadDBData', 'DTPFromEnabled', DTPFrom.Checked );
  N_StringToMemIni( 'CMSUnloadDBData', 'DTPFrom', K_DateTimeToStr( DTPFrom.Date, 'dd.mm.yyyy' ) );
end; // procedure TK_FormCMUTUnloadDBData.CurStateToMemIni

end.
