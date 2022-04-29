unit K_FCMUTLoadDBData2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls, K_FPathNameFr, ComCtrls;

type
  TK_FormCMUTLoadDBData2 = class(TN_BaseForm)
    GBAll: TGroupBox;
    ChBOpenPat: TCheckBox;
    ChBOpenProv: TCheckBox;
    BtCancel: TButton;
    ChBOpenLoc: TCheckBox;
    ChBOpenCont: TCheckBox;
    ChBOpenStat: TCheckBox;
    PathNameFrame: TK_FPathNameFrame;
    BtLoad: TButton;
    BtOpen: TButton;
    LbPatients: TLabel;
    LbProviders: TLabel;
    LbLocations: TLabel;
    LbServers: TLabel;
    LbOpened: TLabel;
    LbClients: TLabel;
    LbAppContexts: TLabel;
    LbStatistics: TLabel;
    LbCollisions: TLabel;
    LbLoad: TLabel;
    LbMedia: TLabel;
    ChBOpenServ: TCheckBox;
    ChBOpenClient: TCheckBox;
    ChBOpenMedia: TCheckBox;
    ChBLoadMedia: TCheckBox;
    ChBLoadPat: TCheckBox;
    ChBLoadProv: TCheckBox;
    ChBLoadLoc: TCheckBox;
    ChBLoadServ: TCheckBox;
    ChBLoadClient: TCheckBox;
    ChBLoadCont: TCheckBox;
    ChBLoadStat: TCheckBox;
    ChBResMedia: TCheckBox;
    ChBResPat: TCheckBox;
    ChBResProv: TCheckBox;
    ChBResLoc: TCheckBox;
    ChBResServ: TCheckBox;
    ChBResClient: TCheckBox;
    ChBResCont: TCheckBox;
    ChBResStat: TCheckBox;
    StatusBar: TStatusBar;
    LbInfo: TLabel;
    ChBCheckFS: TCheckBox;
    BtCopy: TButton;
    ChBSkipContext: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure BtOpenClick(Sender: TObject);
    procedure ChBLoadMediaClick(Sender: TObject);
    procedure BtLoadClick(Sender: TObject);
    procedure BtCopyClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    MediaDataExists,
    PatDataExists,
    ProvDataExists,
    LocDataExists,
    ServDataExists,
    ClientDataExists,
    ContDataExists,
    StatDataExists : Boolean;

    SlidesSACount : Integer;
    SrcSlidesSACount : Integer;
    MergeRootPath : string; // MergeRootPath
    MergeInfoPath : string;
    MergeReportFName : string;
    MergeDBDataPath : string;
    CorrectPathExists : Boolean;

    MergeCopyFSDataFName, MergeCopyFSDataCurStateFName,
    MergeCheckFSBeforeFName : string;
    MergeCopyFSDataCount, MergeCopyFSDataStart : Integer;
    MergeCopy2Count, MergeCopySCount, MergeCopyVCount, MergeCopy3Count : Integer;

    ImgFList, VideoFList, Img3DFList, AllExistedFList, AllNeededFList,
    AImgFList, AVideoFList, AImg3DFList, AllArchivedFList : TStringList;

    ProgressShow, ProgressShowPrev : Integer;
    ProgressFormat : string;

    FSBeforeExisted, FSBeforeNeeded, FSBeforeExtra, FSBeforeMissing, FSBeforeArchived : Integer;
    FSAfterExisted, FSAfterNeeded, FSAfterExtra, FSAfterMissing, FSAfterArchived : Integer;

    IniBtCopyCaption : string;
    InfoFName : string;
    AllOKResultInd, FinPrepDataInd : Integer;

    procedure DumpFSExisted( const ARelPath : string );
    procedure DumpFSNeeded( const ARelPath : string );
    procedure LoadSlidesCopyFSDataTable();
    function  SaveIntDataToFile( const AFName : string; AData : array of const ) : Boolean;
    function  LoadIntDataFromFile( const AFName : string; APData : array of const ) : Boolean;

    function  SaveCopyFSDataStateToFile( ) : Boolean;
    function  LoadCheckFSBeforeStateFromFile( ) : Boolean;
    function  LoadCopyFSDataStateFromFile( ) : Boolean;
    function  GetTableCount( const ATableName : string ) : Integer;
    procedure CopyLogs();
    procedure RebuildPathSettings;
    procedure PathChange;
    procedure ShowProgress( AllCount, CurCount: Integer);

  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMUTLoadDBData2: TK_FormCMUTLoadDBData2;

procedure K_CMUTLoadDBData2Dlg();

implementation

uses K_CLib0, K_CM0, K_CM1, K_FCMSupport, K_UDT2,
     N_Lib0, N_Lib1, N_Types;
{$R *.dfm}

var MergeCopyFSDataPortion : Integer = 100;
//var MergeCopyFSDataPortion : Integer = 20;

//***************************************************** K_CMUTLoadDBData2Dlg ***
// Load Data from other DB
//
procedure K_CMUTLoadDBData2Dlg();
begin

  K_FormCMUTLoadDBData2 := TK_FormCMUTLoadDBData2.Create(Application);
  with K_FormCMUTLoadDBData2 do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    PathNameFrame.OnChange := PathChange;
    K_FormCMSupport.InfoStatusBar := StatusBar;

    ImgFList   := TStringList.Create;
    VideoFList := TStringList.Create;
    Img3DFList := TStringList.Create;

    AImgFList   := TStringList.Create;
    AVideoFList := TStringList.Create;
    AImg3DFList := TStringList.Create;

    AllExistedFList := TStringList.Create;
    AllNeededFList  := TStringList.Create;
    AllArchivedFList:= TStringList.Create;

    N_Dump1Str( 'DAD>> Before K_FormCMUTLoadDBData2 show' );
    ShowModal();
    N_Dump1Str( 'DAD>> After K_FormCMUTLoadDBData2 show' );

    ImgFList.Free;
    VideoFList.Free;
    Img3DFList.Free;

    AImgFList.Free;
    AVideoFList.Free;
    AImg3DFList.Free;

    AllExistedFList.Free;
    AllNeededFList.Free;
    AllArchivedFList.Free;

    K_FormCMSupport.InfoStatusBar := K_FormCMSupport.StatusBar;
    K_FormCMUTLoadDBData2 := nil;
  end;

end; // K_CMUTLoadDBData2Dlg

procedure TK_FormCMUTLoadDBData2.PathChange;
begin
  BtOpen.Enabled := PathNameFrame.mbPathName.Text <> '';
  BtLoad.Enabled := FALSE;
  BtCopy.Enabled := FALSE;

  ChBOpenMedia.Checked  := FALSE;
  ChBOpenPat.Checked    := FALSE;
  ChBOpenProv.Checked   := FALSE;
  ChBOpenLoc.Checked    := FALSE;
  ChBOpenServ.Checked   := FALSE;
  ChBOpenClient.Checked := FALSE;
  ChBOpenCont.Checked   := FALSE;
  ChBOpenStat.Checked   := FALSE;

  ChBLoadMedia.Enabled  := FALSE;
  ChBLoadPat.Enabled    := FALSE;
  ChBLoadProv.Enabled   := FALSE;
  ChBLoadLoc.Enabled    := FALSE;
  ChBLoadServ.Enabled   := FALSE;
  ChBLoadClient.Enabled := FALSE;
  ChBLoadCont.Enabled   := FALSE;
  ChBLoadStat.Enabled   := FALSE;

  ChBLoadMedia.Checked  := FALSE;
  ChBLoadPat.Checked    := FALSE;
  ChBLoadProv.Checked   := FALSE;
  ChBLoadLoc.Checked    := FALSE;
  ChBLoadServ.Checked   := FALSE;
  ChBLoadClient.Checked := FALSE;
  ChBLoadCont.Checked   := FALSE;
  ChBLoadStat.Checked   := FALSE;

  ChBResMedia.Enabled  := FALSE;
  ChBResPat.Enabled    := FALSE;
  ChBResProv.Enabled   := FALSE;
  ChBResLoc.Enabled    := FALSE;
  ChBResServ.Enabled   := FALSE;
  ChBResClient.Enabled := FALSE;
  ChBResCont.Enabled   := FALSE;
  ChBResStat.Enabled   := FALSE;

  ChBResMedia.Checked  := FALSE;
  ChBResPat.Checked    := FALSE;
  ChBResProv.Checked   := FALSE;
  ChBResLoc.Checked    := FALSE;
  ChBResServ.Checked   := FALSE;
  ChBResClient.Checked := FALSE;
  ChBResCont.Checked   := FALSE;
  ChBResStat.Checked   := FALSE;

  ChBSkipContext.Enabled := TRUE;
  ChBCheckFS.Checked := FALSE;

end;

procedure TK_FormCMUTLoadDBData2.DumpFSExisted( const ARelPath : string );
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
end; // procedure TK_FormCMUTLoadDBData2.DumpFSExisted

procedure TK_FormCMUTLoadDBData2.DumpFSNeeded( const ARelPath : string );
begin
 ProgressShowPrev := -1;
 with TK_CMEDDBAccess(K_CMEDAccess), CurDSet3 do
   Connection := LANDBConnection;

  K_CMFSBuildNeededFLists( ImgFList, VideoFList, Img3DFList,
                           AImgFList, AVideoFList, AImg3DFList, [],
                           TK_CMEDDBAccess(K_CMEDAccess).CurDSet3, ShowProgress  );
  // Needed files list dump
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

  // Archived files list dump
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
end; // procedure TK_FormCMUTLoadDBData2.DumpFSNeeded

procedure TK_FormCMUTLoadDBData2.LoadSlidesCopyFSDataTable();
begin
  if MergeCopyFSDataCount > 0 then Exit;
  with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
  begin
    Connection := LANDBConnection;
    CommandText := 'CREATE LOCAL TEMPORARY TABLE SlidesCopyFSData ' +
                   '(OldID int, NewID int, OldPatID int, NewPatID int, DTCr datetime, SysInfo varchar(1000)) NOT TRANSACTIONAL;' + #10 +
                   ' LOAD TABLE SlidesCopyFSData' +
                   ' FROM ''' + MergeCopyFSDataFName + ''' FORMAT BCP;';
    Execute;
    MergeCopyFSDataCount := GetTableCount(  'SlidesCopyFSData' );
    N_Dump1Str( format( 'DAD>> %d records are in SlidesCopyFSData after load',
                          [MergeCopyFSDataCount] ) );
  end;
end; // procedure TK_FormCMUTLoadDBData2.LoadSlidesCopyFSDataTable

function TK_FormCMUTLoadDBData2.SaveIntDataToFile( const AFName : string; AData : array of const ) : Boolean;
var i : Integer;
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    TmpStrings.Clear();
    for i := 0 to High(AData) do
      with AData[i] do
        if VType = vtInteger then
          TmpStrings.Add( IntToStr(VInteger) );

    Result := K_VFSaveStrings( TmpStrings, AFName, K_DFCreatePlain )
  end;
end; // function TK_FormCMUTLoadDBData2.SaveIntDataToFile

function TK_FormCMUTLoadDBData2.LoadIntDataFromFile( const AFName : string; APData : array of const ) : Boolean;
var i : Integer;
begin
  Result := FALSE;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    N_s := K_VFLoadStrings1( AFName, TmpStrings, N_i );
    if N_s <> '' then
    begin
//      K_FormCMSupport.ShowInfo( format( 'Copy media data state error >> %s',
//                                        [N_s] ), 'TK_FormCMUTLoadDBData.LoadIntDataFromFile >>' );
      Exit;
    end;

    for i := 0 to High(APData) do
      with APData[i] do
        if VType = vtPointer then
          PInteger(VPointer)^ := StrToIntDef( TmpStrings[i], 0 );
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do
  Result := TRUE;
end; // function TK_FormCMUTLoadDBData2.LoadIntDataFromFile

function TK_FormCMUTLoadDBData2.SaveCopyFSDataStateToFile( ) : Boolean;
begin
  Result := SaveIntDataToFile( MergeCopyFSDataCurStateFName,
         [MergeCopyFSDataStart,MergeCopy2Count,
          MergeCopySCount,MergeCopyVCount,MergeCopy3Count] );
{
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    TmpStrings.Clear();
    TmpStrings.Add( IntToStr(MergeCopyFSDataStart) );
    TmpStrings.Add( IntToStr(MergeCopy2Count) );
    TmpStrings.Add( IntToStr(MergeCopySCount) );
    TmpStrings.Add( IntToStr(MergeCopyVCount) );
    TmpStrings.Add( IntToStr(MergeCopy3Count) );

    Result := K_VFSaveStrings( TmpStrings, MergeCopyFSDataCurStateFName, K_DFCreatePlain )
  end;
}
end; // function TK_FormCMUTLoadDBData2.SaveCopyFSDataStateToFile

function TK_FormCMUTLoadDBData2.LoadCheckFSBeforeStateFromFile( ) : Boolean;
begin
  Result := LoadIntDataFromFile(MergeCheckFSBeforeFName,
              [@FSBeforeExisted,@FSBeforeNeeded,
               @FSBeforeExtra,@FSBeforeMissing,@FSBeforeArchived] );
  if not Result then
  begin
    K_FormCMSupport.ShowInfo( format( 'Check media data before state load error >> %s',
                                        [N_s] ), 'TK_FormCMUTLoadDBData.LoadCheckFSBeforeStateFromFile >>' );
    Exit;
  end;
end; // function TK_FormCMUTLoadDBData2.LoadCopyFSDataStateFromFile

function TK_FormCMUTLoadDBData2.LoadCopyFSDataStateFromFile( ) : Boolean;
begin
  Result := LoadIntDataFromFile( MergeCopyFSDataCurStateFName,
                                 [@MergeCopyFSDataStart,@MergeCopy2Count,
                                  @MergeCopySCount,@MergeCopyVCount,@MergeCopy3Count] );
  if not Result then
  begin
    K_FormCMSupport.ShowInfo( format( 'Copy media data state load error >> %s',
                                        [N_s] ), 'TK_FormCMUTLoadDBData.LoadCopyFSDataStateFromFile >>' );
    Exit;
  end;
  N_Dump1Str( format( 'DAD>> Copy state is loaded: %d Image, %d Study, %d Video files and %d 3D folders for %d of %d Media Objects',
                                      [MergeCopy2Count, MergeCopySCount,
                                       MergeCopyVCount, MergeCopy3Count,
                                       MergeCopyFSDataStart - 1,MergeCopyFSDataCount] ) );
end; // function TK_FormCMUTLoadDBData2.LoadCopyFSDataStateFromFile

function TK_FormCMUTLoadDBData2.GetTableCount( const ATableName : string  ) : Integer;
begin
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    SQL.Text := 'select count(*)' + ' from ' + ATableName;
    Open();
    Result := Fields[0].AsInteger;
    Close();
  end;
end; // function TK_FormCMUTLoadDBData2.GetTableCount

procedure TK_FormCMUTLoadDBData2.CopyLogs();
var
  LogFName : string;
  RLogFName : string;
  LocFPath : string;
begin
  LogFName := N_LogChannels[N_Dump1LCInd].LCFullFName;
  LocFPath := 'T2\Logs\' + K_DateTimeToStr( Now(), 'yyyy-mm-dd_hh-nn-ss\' );
  RLogFName := MergeInfoPath + LocFPath + ExtractFileName(LogFName);
  K_CopyFile( LogFName, RLogFName );

  LogFName := N_LogChannels[N_Dump2LCInd].LCFullFName;
  RLogFName := MergeInfoPath + LocFPath + ExtractFileName(LogFName);
  K_CopyFile( LogFName, RLogFName );
end; // procedure TK_FormCMUTLoadDBData2.CopyLogs

procedure TK_FormCMUTLoadDBData2.RebuildPathSettings;
begin

  if CorrectPathExists then
  begin

    MediaDataExists :=
      FileExists( MergeDBDataPath + K_CMENDBMTypesTable + '.dat' ) and
      FileExists( MergeDBDataPath + K_CMENDBSlidesTable + '.dat' ) and
      FileExists( MergeDBDataPath + K_CMENDBDelMarkedSlidesTable + '.dat' );

    PatDataExists  := FileExists( MergeDBDataPath + K_CMENDBAllPatientsTable + '.dat' );
    ProvDataExists := FileExists( MergeDBDataPath + K_CMENDBAllProvidersTable + '.dat' );
    LocDataExists  := FileExists( MergeDBDataPath + K_CMENDBAllLocationsTable + '.dat' );
    ServDataExists := FileExists( MergeDBDataPath + K_CMENDBAllServersTable + '.dat' );
    ClientDataExists := FileExists( MergeDBDataPath + K_CMENDBGAInstsTable + '.dat' );
    ContDataExists := FileExists( MergeDBDataPath + K_CMENDBContextsTable + '.dat' );
    StatDataExists :=
      FileExists( MergeDBDataPath + K_CMENDBSlidesHistTable + '.dat' ) and
      FileExists( MergeDBDataPath + K_CMENDBSlidesNewHistTable + '.dat' ) and
      FileExists( MergeDBDataPath + K_CMENDBSessionsHistTable + '.dat' ) and
      FileExists( MergeDBDataPath + K_CMENDBAllHistPatientsTable + '.dat' ) and
      FileExists( MergeDBDataPath + K_CMENDBAllHistProvidersTable + '.dat' ) and
      FileExists( MergeDBDataPath + K_CMENDBAllHistLocationsTable + '.dat' );

    CorrectPathExists :=  MediaDataExists OR PatDataExists OR ProvDataExists OR
                          LocDataExists OR ServDataExists OR ClientDataExists OR
                          ContDataExists OR StatDataExists;
  end
  else
  begin
    MediaDataExists  := FALSE;
    PatDataExists    := FALSE;
    ProvDataExists   := FALSE;
    LocDataExists    := FALSE;
    ServDataExists   := FALSE;
    ClientDataExists := FALSE;
    ContDataExists   := FALSE;
    StatDataExists   := FALSE;
  end;

  ChBOpenMedia.Checked  := MediaDataExists;
  ChBOpenPat.Checked    := PatDataExists;
  ChBOpenProv.Checked   := ProvDataExists;
  ChBOpenLoc.Checked    := LocDataExists;
  ChBOpenServ.Checked   := ServDataExists;
  ChBOpenClient.Checked := ClientDataExists;
  ChBOpenCont.Checked   := ContDataExists;
  ChBOpenStat.Checked   := StatDataExists;

  ChBLoadMedia.Enabled  := CorrectPathExists and MediaDataExists;
  ChBLoadPat.Enabled    := CorrectPathExists and PatDataExists;
  ChBLoadProv.Enabled   := CorrectPathExists and ProvDataExists;
  ChBLoadLoc.Enabled    := CorrectPathExists and LocDataExists;
  ChBLoadServ.Enabled   := CorrectPathExists and ServDataExists;
  ChBLoadClient.Enabled := CorrectPathExists and ClientDataExists;
  ChBLoadCont.Enabled   := CorrectPathExists and ContDataExists;
  ChBLoadStat.Enabled   := CorrectPathExists and StatDataExists;

  ChBLoadMedia.Checked  := MediaDataExists;
  ChBLoadPat.Checked    := PatDataExists;
  ChBLoadProv.Checked   := ProvDataExists;
  ChBLoadLoc.Checked    := LocDataExists;
  ChBLoadServ.Checked   := ServDataExists;
  ChBLoadClient.Checked := ClientDataExists;
  ChBLoadCont.Checked   := ContDataExists;
  ChBLoadStat.Checked   := StatDataExists;

//  ChBResPat.Enabled := CorrectPathExists;
  ChBResProv.Enabled := CorrectPathExists;
  ChBResLoc.Enabled := CorrectPathExists;
  ChBResServ.Enabled := CorrectPathExists;
  ChBResClient.Enabled := CorrectPathExists;

  ChBResMedia.Checked  := MediaDataExists;
  ChBResPat.Checked    := PatDataExists;
  ChBResProv.Checked   := ProvDataExists;
  ChBResLoc.Checked    := LocDataExists;
  ChBResServ.Checked   := ServDataExists;
  ChBResClient.Checked := ClientDataExists;
  ChBResCont.Checked   := ContDataExists;
  ChBResStat.Checked   := StatDataExists;

  BtLoad.Enabled := not BtCopy.Enabled and
                   (ChBLoadMedia.Checked  or
                    ChBLoadPat.Checked    or
                    ChBLoadProv.Checked   or
                    ChBLoadLoc.Checked    or
                    ChBLoadServ.Checked   or
                    ChBLoadClient.Checked or
                    ChBLoadCont.Checked   or
                    ChBLoadStat.Checked);
  if  not CorrectPathExists and (MergeRootPath <> '') then
    K_CMShowMessageDlg( 'Path ' +  MergeRootPath + ' does not contain data to add!!!', mtWarning );

end; // procedure TK_FormCMUTLoadDBData.RebuildPathSettings

procedure TK_FormCMUTLoadDBData2.FormShow(Sender: TObject);
begin
  IniBtCopyCaption := BtCopy.Caption;

  MergeCopyFSDataStart := 1;

  PathChange();

  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    Connection := LANDBConnection;
    Filtered := FALSE;

  // Slides of SA patients
    SQL.Text := 'select count(*) from ' + K_CMENDBSlidesTable +
        ' where ' + K_CMENDBSTFPatID + ' < -100';
    Open();
    SlidesSACount := Fields[0].AsInteger;
    Close();
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
end; // procedure TK_FormCMUTLoadDBData.FormShow

procedure TK_FormCMUTLoadDBData2.BtOpenClick(Sender: TObject);
begin
  BtOpen.Enabled := FALSE;
  BtLoad.Enabled := FALSE;
  BtCopy.Enabled := FALSE;
  ChBSkipContext.Enabled := FALSE;

  // Parse Report File
  MergeRootPath := PathNameFrame.mbPathName.Text;
  MergeRootPath := IncludeTrailingPathDelimiter(MergeRootPath);
  MergeDBDataPath := MergeRootPath + 'DBData\';
  MergeInfoPath   := MergeRootPath + 'MergeInfo\';
  MergeReportFName := MergeInfoPath + 'Report.txt';
  MergeCopyFSDataFName := MergeDBDataPath + '!!!SlidesCopyFSData.dat';
  MergeCopyFSDataCurStateFName :=  MergeDBDataPath + '!!!SlidesCopyFSDataCurState.dat';
  MergeCheckFSBeforeFName := MergeInfoPath + 'T2\FSDumpsBefore\!!!BeforeCheckCounters.dat';
  CorrectPathExists := MergeRootPath <> '';
  N_Dump2Str( format( 'DAD>> BtOpenClick from %s', [MergeRootPath] ) );

  if not CorrectPathExists then
  begin
    K_CMShowMessageDlg( //sysout
      'Adding data root folder is not set', mtWarning, [], false, 'Media Suite Support' );
    Exit;
  end;
  if not FileExists( MergeReportFName ) then
  begin
    N_Dump1Str( format('DAD>> File "%s" is not found',[MergeReportFName] ) );
    K_CMShowMessageDlg( //sysout
      'Adding data root folder doesn''t contains unload results', mtWarning, [], false, 'Media Suite Support' );
    Exit;
  end;

  AllExistedFList.LoadFromFile( MergeReportFName );
  AllOKResultInd := K_SearchInStrings( AllExistedFList, 'All is OK!!!' );
  if AllOKResultInd < 0 then
  begin
    if mrYes <> K_CMShowMessageDlg(
             'Something is not OK while load data were prepared!!!'#13#10 +
                     'Do you want to continue? (Select No if you want to break the process)',
                     mtConfirmation, [], FALSE, 'MediaSuite Support' ) then
      Exit;
  end;

  if ChBSkipContext.Checked then
  begin
    K_DeleteFile( MergeCopyFSDataFName );
    K_DeleteFile( MergeCopyFSDataCurStateFName );
  end;

  BtCopy.Enabled := FileExists( MergeCopyFSDataCurStateFName );
  if BtCopy.Enabled then
    BtCopy.Enabled := LoadCopyFSDataStateFromFile();

  RebuildPathSettings();
  if BtCopy.Enabled then
  begin
    LoadSlidesCopyFSDataTable();
    BtCopy.Enabled := MergeCopyFSDataCount >= MergeCopyFSDataStart;
    if not BtCopy.Enabled then
      K_CMShowMessageDlg( //sysout
        'All data are already added. Nothing to do!', mtWarning, [], false, 'Media Suite Support' )
    else
    begin
      ProgressFormat := 'Copy media, %d%% done';
      ShowProgress( MergeCopyFSDataCount, MergeCopyFSDataStart - 1 );
    end;

    ChBCheckFS.Checked := DirectoryExists(MergeInfoPath + 'T2\FSDumpsBefore\');
    ChBCheckFS.Enabled := FALSE;
    if ChBCheckFS.Checked then
    begin
      ChBCheckFS.Checked := FileExists( MergeCheckFSBeforeFName );
      if ChBCheckFS.Checked and
         LoadCheckFSBeforeStateFromFile() then
      begin
        FSAfterExisted := FSBeforeExisted;
        FSAfterNeeded  := FSBeforeNeeded;
        FSAfterExtra   := FSBeforeExtra;
        FSAfterMissing := FSBeforeMissing;
        FSAfterArchived:= FSBeforeArchived;
      end
      else
      begin
        ChBCheckFS.Checked := FALSE;
        K_CMShowMessageDlg( //sysout
          'Comprehensive data analysis will be skiped', mtWarning, [], false, 'Media Suite Support' );
      end;
    end; // if ChBCheckFS.Checked then

    // Skip Settings Edit before copy
    ChBLoadMedia.Enabled  := FALSE;
    ChBLoadPat.Enabled    := FALSE;
    ChBLoadProv.Enabled   := FALSE;
    ChBLoadLoc.Enabled    := FALSE;
    ChBLoadServ.Enabled   := FALSE;
    ChBLoadClient.Enabled := FALSE;
    ChBLoadCont.Enabled   := FALSE;
    ChBLoadStat.Enabled   := FALSE;

    ChBResProv.Enabled   := FALSE;
    ChBResLoc.Enabled    := FALSE;
    ChBResServ.Enabled   := FALSE;
    ChBResClient.Enabled := FALSE;

  end // if BtCopy.Enabled then
  else
  if BtLoad.Enabled then
  begin
    BtLoad.Enabled := K_FormCMSupport.CheckSingleMediaSuitRunning();
    ChBCheckFS.Checked := FALSE;
    ChBCheckFS.Enabled := TRUE;
  end;
end; // procedure TK_FormCMUTLoadDBData.BtOpenClick

procedure TK_FormCMUTLoadDBData2.ChBLoadMediaClick(Sender: TObject);
begin
  ChBResMedia.Checked := ChBLoadMedia.Checked;
  ChBLoadStat.Enabled := ChBLoadMedia.Checked;
  if not ChBLoadMedia.Checked then
    ChBLoadStat.Checked := FALSE;

  ChBResStat.Checked := ChBLoadStat.Checked;

//  ChBResPat.Enabled := ChBLoadPat.Checked;
  if not ChBLoadPat.Checked then
    ChBResPat.Checked := FALSE;

  ChBResProv.Enabled := ChBLoadProv.Checked;
  if not ChBLoadProv.Checked then
    ChBResProv.Checked := FALSE;

  ChBResLoc.Enabled := ChBLoadLoc.Checked;
  if not ChBLoadLoc.Checked then
    ChBResLoc.Checked := FALSE;

  ChBResServ.Enabled := ChBLoadServ.Checked;
  if not ChBLoadServ.Checked then
    ChBResServ.Checked := FALSE;

  ChBResClient.Enabled := ChBLoadClient.Checked;
  if not ChBLoadClient.Checked then
    ChBResClient.Checked := FALSE;

  ChBResCont.Checked := ChBLoadCont.Checked;

  BtLoad.Enabled := ChBLoadMedia.Checked  or
                    ChBLoadPat.Checked    or
                    ChBLoadProv.Checked   or
                    ChBLoadLoc.Checked    or
                    ChBLoadServ.Checked   or
                    ChBLoadClient.Checked or
                    ChBLoadCont.Checked   or
                    ChBLoadStat.Checked;

end; // procedure TK_FormCMUTLoadDBData.ChBLoadMediaClick

procedure TK_FormCMUTLoadDBData2.BtLoadClick(Sender: TObject);
var
//  ExtFilePat : string;
//  ErrRootPath : string;
  SavedCursor: TCursor;
  TTabName : string;
//  SQLStr : string;
  i : Integer;

  ContType, ContID, ContID1, DelCount : Integer;

  procedure DumpLoadInfo( const ATableName : string  );
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
    begin
      SQL.Text := 'select count(*)' + ' from ' + ATableName;
      Open();
      N_Dump1Str( format( 'DAD>> Table %s, %d records are loaded', [ATableName,Fields[0].AsInteger] ) );
      Close();
    end;
  end; // procedure DumpLoadInfo(

  function DumpPrepCrossRefs( const ATableName : string  ) : Integer;
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
    begin
      SQL.Text := 'select count(*)' + ' from ' + K_CMENDBImportLinkIDsTable;
      Open();
      Result := Fields[0].AsInteger;
      N_Dump1Str( format( 'DAD>> Table %s, %d cross refs are build', [ATableName,Result] ) );
      Close();
    end;
  end; // function DumpPrepCrossRefs

  procedure DumpAddInfo( const ATableName, ATableName1 : string  );
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
    begin
      N_Dump1Str( format( 'DAD>> %d records from %s are added to %s (%d)',
                          [GetTableCount(ATableName),ATableName,ATableName1,GetTableCount(ATableName1)] ) );
      Close();
    end;
  end; // procedure DumpAddInfo

begin
  N_Dump2Str( 'DAD>> BtLoadClick start' );
  K_NotAddedStrings := TStringList.Create;

  with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
  begin
    K_AddStringToTextFile( MergeReportFName,
      format( #13#10'Merging Load DB data start at %s',
              [ K_DateTimeToStr( Now(), 'yyyy-mm-dd_hh":"nn":"ss' )] ) );

    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;

    Connection := LANDBConnection;

    BtOpen.Enabled := FALSE;
    BtLoad.Enabled := FALSE;
    BtCopy.Enabled := FALSE;

    // Clear all add report info
    if AllOKResultInd < 0 then
      AllOKResultInd := 0;
    FinPrepDataInd := K_SearchInStrings( AllExistedFList, '#####', AllOKResultInd );
    if FinPrepDataInd >= 0 then
    begin
      for i := AllExistedFList.Count - 1 downto FinPrepDataInd + 1 do
        AllExistedFList.Delete( i );

      // Save cleared report to file
      AllExistedFList.SaveToFile( MergeReportFName );
    end; // if AllOKResultInd >= 0 then

    //  Start procedure

    CommandText := 'DROP VARIABLE IF EXISTS @SlidesSEQNewID;'  + #10 +
                   'CREATE VARIABLE @SlidesSEQNewID  integer;' + #10 +
                   'DROP VARIABLE IF EXISTS @MinID;'  + #10 +
                   'CREATE VARIABLE @MinID  integer;' + #10 +
                   'DROP VARIABLE IF EXISTS @MinID1;' + #10 +
                   'CREATE VARIABLE @MinID1 integer;';
    Execute;

    K_DeleteFolderFiles( MergeInfoPath + 'T2\' );

    if ChBCheckFS.Checked then
    begin
      /////////////////////////////////////////////
      // Check and Dump Target DB and Files Storage
      //
      N_Dump1Str( 'DAD>> Dump Target File Storage before' );
      LbInfo.Caption := 'Build Existed ...';
      LbInfo.Refresh();
      DumpFSExisted( 'T2\FSDumpsBefore\' );
      N_Dump1Str( 'DAD>> Existed Files are build' );
      ProgressFormat := 'Build Needed, %d%% done';
      DumpFSNeeded( 'T2\FSDumpsBefore\' );
      N_Dump1Str( 'DAD>> Needed Files are build' );
      FSBeforeExisted := AllExistedFList.Count;
      FSBeforeNeeded  := AllNeededFList.Count;
      FSBeforeArchived:= AllArchivedFList.Count;

      LbInfo.Caption := 'Build Extra/Missing/Archived ...';
      K_CMFSCompNeededExistedFLists( AllExistedFList, AllNeededFList, nil );
      N_Dump1Str( 'DAD>> Extra and Missing Files are build' );
      FSBeforeExtra := AllExistedFList.Count;
      FSBeforeMissing := AllNeededFList.Count;

      // Set Default After Results for correct check
      FSAfterExisted := FSBeforeExisted;
      FSAfterNeeded  := FSBeforeNeeded;
      FSAfterExtra   := FSBeforeExtra;
      FSAfterMissing := FSBeforeMissing;
      FSAfterArchived:= FSBeforeArchived;

      K_AddStringToTextFile( MergeReportFName,
        format( 'Target File Storage before: Existed=%d, Needed=%d, Extra=%d, Missing=%d Archived=%d',
                [FSBeforeExisted, FSBeforeNeeded, FSBeforeExtra, FSBeforeMissing,FSBeforeArchived] ) );
      if AllExistedFList.Count > 0 then
        K_AddStringToTextFile( MergeInfoPath + 'T2\FSDumpsBefore\Extra.txt',
                               AllExistedFList.Text );
      if AllNeededFList.Count > 0 then
        K_AddStringToTextFile( MergeInfoPath + 'T2\FSDumpsBefore\Missing.txt',
                               AllNeededFList.Text );
      if FSBeforeArchived > 0 then
        K_AddStringToTextFile( MergeInfoPath + 'T2\FSDumpsBefore\Archived.txt',
                               AllArchivedFList.Text );

      K_DeleteFile( MergeCheckFSBeforeFName );
      if not SaveIntDataToFile( MergeCheckFSBeforeFName,
              [FSBeforeExisted,FSBeforeNeeded,
               FSBeforeExtra,FSBeforeMissing,FSBeforeArchived] ) then
        K_CMShowMessageDlg( //sysout
          'Future comprehensive data analysis will be skiped.'#13#10+
          '          Click OK to continue.', mtWarning, [], false, 'Media Suite Support' );
      //
      // Check and Dump Target DB
      ////////////////////////////
      LbInfo.Caption := '';
      LbInfo.Refresh();
    end; // if ChBCheckFS then
    ChBCheckFS.Enabled := FALSE;

    ////////////////////////////////////
    // Load data to temporary tables
    //
    if ChBLoadMedia.Checked then
    begin

      K_FormCMSupport.ShowInfo( ' Load Media Objects ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      CommandText := 'CREATE LOCAL TEMPORARY TABLE SlidesCopyMoveInfo ' +
                     '(OldID int, NewID int, OldPatID int) NOT TRANSACTIONAL;';
      Execute;

      CommandText := 'CREATE LOCAL TEMPORARY TABLE PAIDs1 (ID int) NOT TRANSACTIONAL;';
      Execute;


      TTabName := 'Tmp' + K_CMENDBMTypesTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBMTypesTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBMTypesTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBSlidesTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBSlidesTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBSlidesTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );

      with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
      begin
        Connection := LANDBConnection;
        Filtered := FALSE;

      // Slides of SA patients
        SQL.Text := 'select count(*) from ' + TTabName +
        ' where ' + K_CMENDBSTFPatID + ' < -100';
        Open();
        SrcSlidesSACount := Fields[0].AsInteger;
        Close();
      end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
      ChBResPat.Checked := ChBLoadPat.Checked and (SrcSlidesSACount <> 0) and (SlidesSACount <> 0);

      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBDelMarkedSlidesTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBDelMarkedSlidesTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBDelMarkedSlidesTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

    end; // if ChBLoadMedia.Checked then

    if ChBLoadPat.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Load Patients ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
      TTabName := 'Tmp' + K_CMENDBAllPatientsTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBAllPatientsTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBAllPatientsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;
    end; // if ChBLoadPat.Checked then

    if ChBLoadProv.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Load Providers ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
      TTabName := 'Tmp' + K_CMENDBAllProvidersTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBAllProvidersTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBAllProvidersTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

    end; // if ChBLoadProv.Checked then

    if ChBLoadLoc.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Load Locations ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
      TTabName := 'Tmp' + K_CMENDBAllLocationsTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBAllLocationsTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBAllLocationsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

    end; // ChBLoadLoc.Checked then

    if ChBLoadServ.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Load Servers ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
      TTabName := 'Tmp' + K_CMENDBAllServersTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBAllServersTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBAllServersTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;
    end; // if ChBLoadServ.Checked then

    if ChBLoadClient.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Load Clients ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
      TTabName := 'Tmp' + K_CMENDBGAInstsTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBGAInstsTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBGAInstsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;
    end; // if ChBLoadClient.Checked then

    if ChBLoadCont.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Load Media Suite Contexts ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
      TTabName := 'Tmp' + K_CMENDBContextsTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBContextsTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBContextsTable + '.dat''' +
                     ' FORMAT BCP;' + #10 +
                     'DELETE FROM ' + TTabName + ' WHERE ' +
                         K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actGlobIni))  + ' OR ' +
                         K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actGlobUD))   + ' OR ' +
                         K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actGlobIni2)) + ';';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;
    end; // if ChBLoadCont.Checked then

    if ChBLoadStat.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Load Statistics ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      TTabName := 'Tmp' + K_CMENDBSlidesHistTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBSlidesHistTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBSlidesHistTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBSlidesNewHistTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBSlidesNewHistTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBSlidesNewHistTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBSessionsHistTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBSessionsHistTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBSessionsHistTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBAllHistPatientsTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBAllHistPatientsTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBAllHistPatientsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBAllHistProvidersTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBAllHistProvidersTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBAllHistProvidersTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBAllHistLocationsTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBAllHistLocationsTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + MergeDBDataPath + K_CMENDBAllHistLocationsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;
    end; // if ChBLoadStat.Checked then
    //
    // Load data to temporary tables
    ////////////////////////////////////

    ////////////////////////////////////
    // Resolve data collisions
    //
    if ChBLoadMedia.Checked then
    begin
      if ChBResMedia.Checked then
      begin
        K_FormCMSupport.ShowInfo( ' Resolve Media Collisions ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
        ///////////////////////////////
        // Resolve Media Types
        //
        TTabName := 'Tmp' + K_CMENDBMTypesTable;
        CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Get Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDBMTFMTypeID + ', 0 ' +
                       ' FROM ' + TTabName + ';' + #10 +

                       // Set new IDs to CrossRefs Table for Identic objects
                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = A.' + K_CMENDBMTFMTypeID +
                       ' FROM ' + K_CMENDBMTypesTable + ' A' +
                       ' JOIN ' + TTabName  + ' P' +
                       ' ON A.' + K_CMENDBMTFMTypeTitle + ' = P.' + K_CMENDBMTFMTypeTitle +
                       ' WHERE ' + K_CMENDILIOldID + '= P.' + K_CMENDBMTFMTypeID + ';' + #10 +

                       // Set new IDs to CrossRefs Table for not Identic objects
                       'SELECT MAX(' + K_CMENDBMTFMTypeID + ') INTO @MinID FROM ' + K_CMENDBMTypesTable + ';' + #10 +
                       'SET @MinID = @MinID + 1;' + #10 +

                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = @MinID, @MinID = @MinID + 1' +
                       ' FROM (SELECT ' + K_CMENDBMTFMTypeID + ' FROM ' + TTabName +
                              ' WHERE NOT EXISTS (SELECT 1 ' + K_CMENDBMTFMTypeID +
                                                 ' FROM ' + K_CMENDBMTypesTable  +
                                                 ' WHERE ' + K_CMENDBMTypesTable + '.' + K_CMENDBMTFMTypeTitle +
                                                     ' = ' + TTabName + '.' + K_CMENDBMTFMTypeTitle + ')) P' +
                       ' WHERE ' + K_CMENDILIOldID + '= P.' + K_CMENDBMTFMTypeID + ';' + #10 +

                       // Delete Identic CrossRefs
                       'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                       ' WHERE ' + K_CMENDILIOldID + ' = ' + K_CMENDILINewID + ';';
        Execute;
        Application.ProcessMessages;

        if DumpPrepCrossRefs( K_CMENDBMTypesTable ) > 0 then
        begin
          // Update Self
          CommandText := 'UPDATE ' + TTabName +
            ' SET '  + K_CMENDBMTFMTypeID + ' =  P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDBMTFMTypeID + ' = P.' + K_CMENDILIOldID + ';';

          Execute;
          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;

          // Update References in corresponding Tables
          TTabName := 'Tmp' + K_CMENDBSlidesTable;
          CommandText := 'UPDATE ' + TTabName +
            ' SET '  + K_CMENDBSTFSlideMTypeID + ' =  P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDBSTFSlideMTypeID + ' = P.' + K_CMENDILIOldID;
          Execute;
          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;
        end; // if DumpPrepCrossRefs( K_CMENDBMTypesTable ) > 0 then

        ///////////////////////////////
        // Resolve Slides
        //

        // Prepare ALL SA Patient IDs
        TTabName := 'Tmp' + K_CMENDBSlidesTable;
        CommandText := 'DELETE FROM PAIDs1;'#10 +
          'INSERT PAIDs1 ( ID )' +
          ' SELECT DISTINCT ' + K_CMENDBSTFPatID +
          ' FROM ' + TTabName +
          ' WHERE ' + K_CMENDBSTFPatID + ' < -100';
        Execute;

        CommandText  := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Get Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDBSTFSlideID  + ', 0 ' +
                       ' FROM ' + TTabName + ';' + #10 +
               // Set new IDs to CrossRefs Table
                       'SELECT MAX(' + K_CMENDBSTFSlideID + ') INTO @MinID FROM ' + K_CMENDBSlidesTable + ';' + #10 +
                       'IF @MinID IS NULL THEN SET @MinID = 0 END IF;' + #10 +
                       'SET @MinID = @MinID + 1;' + #10 +
                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = @MinID, @MinID = @MinID + 1;' + #10 +
                       ' SET @SlidesSEQNewID = @MinID;' + #10 +
               // Prepare Copy Files Info
                       'INSERT SlidesCopyMoveInfo (OldID, NewID, OldPatID)' +
                       ' SELECT ' + K_CMENDILIOldID + ', ' + K_CMENDILINewID + ', 0' +
                       ' FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
               // Set Old Slide Patient ID
                       'UPDATE SlidesCopyMoveInfo ' +
                       ' SET OldPatID  =  P.' +  K_CMENDBSTFPatID +
                       ' FROM SlidesCopyMoveInfo A' +
                       ' JOIN ' + TTabName  + ' P' +
                       ' ON A.OldID  = P.' + K_CMENDBSTFSlideID + ';' + #10 +
               // Delete Identic CrossRefs
                       'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                       ' WHERE ' + K_CMENDILIOldID + ' = ' + K_CMENDILINewID + ';';
        Execute;
{
        SQLStr :=      'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Get Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDBSTFSlideID  + ', 0 ' +
                       ' FROM ' + TTabName + ';' + #10 +

                       // Set new IDs to CrossRefs Table
                 //      'SELECT MAX(' + K_CMENDBSTFSlideID + ') INTO @MinID FROM ' + K_CMENDBSlidesTable + ';' + #10 +
                       'SELECT IFNULL( MAX(' + K_CMENDBSTFSlideID + '), 0) INTO @MinID FROM ' + K_CMENDBSlidesTable + ';' + #10 +
                 //      'IF @MinID IS NULL THEN SET @MinID = 0 END IF;' + #10 +
                       'SET @MinID = @MinID + 1;' + #10 +

                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = @MinID, @MinID = @MinID + 1;' + #10 +
                       ' SET @SlidesSEQNewID = @MinID;' + #10;
//        if K_CMEDDBVersion >= 40 then // Set ID to NextSlideID sequence
//          SQLStr := SQLStr +
//                       'EXECUTE IMMEDIATE string( ''ALTER SEQUENCE dba.NextSlideID RESTART WITH '', @SlidesSEQNewID );' + #10;

        CommandText := SQLStr +
                       // Prepare Copy Files Info
                       'INSERT SlidesCopyMoveInfo (OldID, NewID, OldPatID)' +
                       ' SELECT ' + K_CMENDILIOldID + ', ' + K_CMENDILINewID + ', 0' +
                       ' FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +

                       // Set Old Slide Patient ID
                       'UPDATE SlidesCopyMoveInfo ' +
                       ' SET OldPatID  =  P.' +  K_CMENDBSTFPatID +
                       ' FROM SlidesCopyMoveInfo A' +
                       ' JOIN ' + TTabName  + ' P' +
                       ' ON A.OldID  = P.' + K_CMENDBSTFSlideID + ';' + #10 +

                       // Delete Identic CrossRefs
                       'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                       ' WHERE ' + K_CMENDILIOldID + ' = ' + K_CMENDILINewID + ';';
        Execute;
}
        Application.ProcessMessages;

        if DumpPrepCrossRefs( K_CMENDBSlidesTable ) > 0 then
        begin
          CommandText :=
            // Update Self IDs
            'UPDATE ' + TTabName +
            ' SET '  + K_CMENDBSTFSlideID + ' =  P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDBSTFSlideID + ' = P.' + K_CMENDILIOldID + ';' + #10 +
            'IF EXISTS (SELECT 1 FROM ' + TTabName +
                 ' WHERE ' + K_CMENDBSTFSlideStudyID +' < 0 ) THEN ' + #10 +
            // Update Studies if Exists
               // Update Self StudyIDs
               ' UPDATE '  + TTabName +
               ' SET '  + K_CMENDBSTFSlideStudyID + ' =  P.' +  K_CMENDILINewID +
               ' FROM ' + TTabName + ' A' +
               ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
               ' ON A.' + K_CMENDBSTFSlideStudyID + ' = P.' + K_CMENDILIOldID + ';' + #10 +
               // Set Flag for Studies Fix Data Dlg for future Studies Files Creation
               ' UPDATE ' + K_CMENDBGlobAttrsTable + ' SET ' + K_CMENDBGTFFixStudyDate +
                        ' = DATE( DATEADD(day,-1,GETDATE()));' + #10 +
            'END IF;';
          Execute;

          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;

          // Update References in corresponding Tables
          TTabName := 'Tmp' + K_CMENDBDelMarkedSlidesTable;
          CommandText := 'UPDATE ' + TTabName +
            ' SET '  + K_CMENDMSlideID + ' =  P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDMSlideID + ' = P.' + K_CMENDILIOldID;
          Execute;
          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;

          if ChBLoadStat.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBSlidesHistTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSlidesHTFSlideID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSlidesHTFSlideID + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;

            TTabName := 'Tmp' + K_CMENDBSlidesNewHistTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSlidesNHTFSlideID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSlidesNHTFSlideID + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end; // if ChBLoadStat.Checked then
        end; // if DumpPrepCrossRefs( K_CMENDBSlidesTable ) > 0 then
      end // if ChBResMedia.Checked then
      else
      begin // if not ChBResMedia.Checked then
       // Prepare Copy Files Info
        TTabName := 'Tmp' + K_CMENDBSlidesTable;
        CommandText := 'INSERT SlidesCopyMoveInfo (OldID, NewID, OldPatID )' +
                       ' SELECT ' + K_CMENDBSTFSlideID + ', ' + K_CMENDBSTFSlideID + ',' +
                                    K_CMENDBSTFPatID +
                       ' FROM ' + TTabName + ';';
      end;
    end; // if ChBLoadMedia.Checked then

{
CommandText := 'UNLOAD TABLE ' + 'Tmp' + K_CMENDBAllPatientsTable +
' TO ''' + MergeDBDataPath + K_CMENDBAllPatientsTable + '_!1.dat''' +
' FORMAT BCP;';
Execute;
CommandText := 'UNLOAD TABLE ' + K_CMENDBAllPatientsTable +
' TO ''' + MergeDBDataPath + K_CMENDBAllPatientsTable + '_!2.dat''' +
' FORMAT BCP;';
Execute;

CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
               'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDAPBridgeID + ', 0' +
                       ' FROM ' + 'Tmp' + K_CMENDBAllPatientsTable +
                       ' WHERE ' + K_CMENDAPBridgeID + ' < -100;';
Execute;
CommandText := 'UNLOAD TABLE ' + K_CMENDBImportLinkIDsTable +
' TO ''' + MergeDBDataPath + K_CMENDBAllPatientsTable + '_!3.dat''' +
' FORMAT BCP;';
Execute;

CommandText := 'UNLOAD SELECT A.' + K_CMENDAPBridgeID +
                       ' FROM ' + K_CMENDBAllPatientsTable + ' A' +
                       ' JOIN ' + TTabName  + ' P ON' +
                       ' A.' + K_CMENDAPSurname + ' = P.' + K_CMENDAPSurname + ' AND ' +
                       ' A.' + K_CMENDAPFirstname + ' = P.' + K_CMENDAPFirstname +
            //           ' A.' + K_CMENDAPDOB + ' = P.' + K_CMENDAPDOB +
//                       ' WHERE A.' + K_CMENDAPFlags + ' = 0 ' +
                       ' TO ''' + MergeDBDataPath + K_CMENDBAllPatientsTable + '_!4.dat''' +
                       ' FORMAT BCP;';
Execute;
{}
    if ChBLoadPat.Checked then
    begin
      if ChBResPat.Checked then
      begin // It should be done for SA patients only
        K_FormCMSupport.ShowInfo( ' Resolve Patients Collisions ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
        TTabName := 'Tmp' + K_CMENDBAllPatientsTable;
        CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Delete Patients from AllPatients Table
                       'DELETE FROM PAIDs1 FROM ' + TTabName +
                       ' WHERE ' + TTabName + '.' + K_CMENDAPBridgeID +
                                                   ' = PAIDs1.ID;'#10 +
                       // Get all needed Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDAPBridgeID + ', 0' +
                       ' FROM ' + TTabName +
                       ' WHERE ' + K_CMENDAPBridgeID + ' < -100;' + #10 +
                       // Set new IDs to CrossRefs Table for Identic objects
                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = A.' + K_CMENDAPBridgeID +
                       ' FROM ' + K_CMENDBAllPatientsTable + ' A' +
                       ' JOIN ' + TTabName  + ' P ON' +
                       ' A.' + K_CMENDAPSurname + ' = P.' + K_CMENDAPSurname + ' AND ' +
                       ' A.' + K_CMENDAPFirstname + ' = P.' + K_CMENDAPFirstname + ' AND ' +
                       ' A.' + K_CMENDAPDOB + ' = P.' + K_CMENDAPDOB +
                       ' WHERE ' + K_CMENDILIOldID + '= P.' + K_CMENDAPBridgeID + ' AND ' +
                               ' A.' + K_CMENDAPFlags + ' = 0;' + #10 +
                       // Add uniq Patient IDs from Source AllSlides Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT  ID, 0 FROM PAIDs1;'#10 +
                       // Set new IDs to CrossRefs Table for not Identic objects
                       // 1) Calc start new ID value
                       'SELECT MIN(' + K_CMENDAPBridgeID + ') INTO @MinID FROM ' + K_CMENDBAllPatientsTable +
                                 ' WHERE ' + K_CMENDAPBridgeID + ' < -100;' + #10 +
                       'SET @MinID = COALESCE(@MinID, -100);' + #10 +
                       'SELECT MIN(' + K_CMENDBSTFPatID + ') INTO @MinID1 FROM ' + K_CMENDBSlidesTable +
                                 ' WHERE ' + K_CMENDBSTFPatID + ' < -100;' + #10 +
                       'SET @MinID1 = COALESCE(@MinID1, -100);' + #10 +
                       'IF @MinID1 < @MinID THEN SET @MinID = @MinID1 END IF;' + #10 +
                       'SET @MinID = @MinID - 1;' + #10 +
                       // 2) set New ID values for not Identic objects
{ //!!! Old version - it seems that next SQL is more effective
                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = @MinID, @MinID = @MinID - 1' +
                       ' FROM (SELECT ' + K_CMENDAPBridgeID + ' FROM ' + TTabName +
                              ' WHERE NOT EXISTS (SELECT 1 ' + K_CMENDAPBridgeID +
                                                 ' FROM ' + K_CMENDBAllPatientsTable  +
                                                 ' WHERE ' +
                       K_CMENDBAllPatientsTable + '.' + K_CMENDAPSurname + ' = ' + TTabName + '.' + K_CMENDAPSurname + ' AND ' +
                       K_CMENDBAllPatientsTable + '.' + K_CMENDAPFirstname + ' = ' + TTabName + '.' + K_CMENDAPFirstname + ' AND ' +
                       K_CMENDBAllPatientsTable + '.' + K_CMENDAPDOB + ' = ' + TTabName + '.' + K_CMENDAPDOB + ')) P' +
                       ' WHERE ' +  K_CMENDILIOldID + '= P.' + K_CMENDAPBridgeID + ';' + #10 +
}
//!!! new version
                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = @MinID, @MinID = @MinID - 1' +
                       ' WHERE ' +  K_CMENDILINewID + '= 0;' + #10 +

                       // Delete Identic CrossRefs
                       'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                       ' WHERE ' + K_CMENDILIOldID + ' = ' + K_CMENDILINewID + ';';
        Execute;
        Application.ProcessMessages;
{
CommandText := 'UNLOAD TABLE ' + K_CMENDBImportLinkIDsTable +
' TO ''' + MergeDBDataPath + TTabName + 'LinkIDs1.dat''' +
' FORMAT BCP;';
Execute;
{}

        if DumpPrepCrossRefs( K_CMENDBAllPatientsTable ) > 0 then
        begin
          // Update Self
          CommandText := 'UPDATE ' + TTabName +
            ' SET '  + K_CMENDAPBridgeID + ' =  P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDAPBridgeID + ' = P.' + K_CMENDILIOldID + ';';

          Execute;
          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;

          // Update References in corresponding Tables
          if ChBLoadMedia.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBSlidesTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSTFPatID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSTFPatID + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end;

          if ChBLoadCont.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBContextsTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBCTFContID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON (A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actPatIni)) + ')'+
                ' AND A.' + K_CMENDBCTFContID     + ' = P.' + K_CMENDILIOldID + ';';

            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end;

          if ChBLoadStat.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBSessionsHistTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSessionsHTFPatID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSessionsHTFPatID + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;

            TTabName := 'Tmp' + K_CMENDBAllHistPatientsTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDAHPatID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDAHPatID + ' = P.' + K_CMENDILIOldID + ';';
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end; // if ChBLoadStat.Checked then
        end; // if DumpPrepCrossRefs( K_CMENDBAllPatientsTable ) > 0 then
      end; // if ChBResPat.Checked then
    end; // if ChBLoadPat.Checked then

    if ChBLoadProv.Checked then
    begin
      if ChBResProv.Checked then
      begin
        K_FormCMSupport.ShowInfo( ' Resolve Providers Collisions ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

        TTabName := 'Tmp' + K_CMENDBAllProvidersTable;
        CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Get Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDAUBridgeID + ', 0 ' +
                       ' FROM ' + TTabName + ';' + #10 +

                       // Set new IDs to CrossRefs Table for Identic objects
                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = A.' + K_CMENDAUBridgeID +
                       ' FROM ' + K_CMENDBAllProvidersTable + ' A' +
                       ' JOIN ' + TTabName  + ' P ON' +
                       ' A.' + K_CMENDAUSurname + ' = P.' + K_CMENDAUSurname + ' AND ' +
                       ' A.' + K_CMENDAUFirstname + ' = P.' + K_CMENDAUFirstname +
                       ' WHERE ' + K_CMENDILIOldID + '= P.' + K_CMENDAUBridgeID + ';' + #10 +
{
'UNLOAD TABLE ' + K_CMENDBImportLinkIDsTable +
' TO ''' + MergeDBDataPath + TTabName + 'LinkIDs1.dat''' +
' FORMAT BCP;' + #10 +
}
                       // Set new IDs to CrossRefs Table for not Identic objects
                       'SELECT MAX(' + K_CMENDAUID + ') INTO @MinID FROM ' + K_CMENDBAllProvidersTable + ';' + #10 +
                       'SET @MinID = @MinID + 1;' + #10 +

                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = -100 - @MinID, @MinID = @MinID + 1' +
                       ' FROM (SELECT ' + K_CMENDAUBridgeID + ' FROM ' + TTabName +
                              ' WHERE NOT EXISTS (SELECT 1 ' + K_CMENDAUBridgeID +
                                                 ' FROM ' + K_CMENDBAllProvidersTable  +
                                                 ' WHERE ' +
                       K_CMENDBAllProvidersTable + '.' + K_CMENDAUSurname + ' = ' + TTabName + '.' + K_CMENDAUSurname + ' AND ' +
                       K_CMENDBAllProvidersTable + '.' + K_CMENDAUFirstname + ' = ' + TTabName + '.' + K_CMENDAUFirstname + ')) P' +
                       ' WHERE ' + K_CMENDILIOldID + '= P.' + K_CMENDAUBridgeID + ';' + #10 +
{
'UNLOAD TABLE ' + K_CMENDBImportLinkIDsTable +
' TO ''' + MergeDBDataPath + TTabName + 'LinkIDs2.dat''' +
' FORMAT BCP;' + #10 +
}
                       // Delete Identic CrossRefs
                       'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                       ' WHERE ' + K_CMENDILIOldID + ' = ' + K_CMENDILINewID + ';';
        Execute;
        Application.ProcessMessages;

        if DumpPrepCrossRefs( K_CMENDBAllProvidersTable ) > 0 then
        begin
          // Update Self
          CommandText :=
{
'UNLOAD TABLE ' + TTabName +
' TO ''' + MergeDBDataPath + TTabName + '1.dat''' +
' FORMAT BCP;' + #10 +
}
            'UPDATE ' + TTabName +
            ' SET '  + K_CMENDAUID + ' = -100 - P.' +  K_CMENDILINewID + ', ' +
                       K_CMENDAUBridgeID + ' =  P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDAUBridgeID + ' = P.' + K_CMENDILIOldID + ';';
          Execute;
{
          CommandText :=
'UNLOAD TABLE ' + TTabName +
' TO ''' + MergeDBDataPath + TTabName + '3.dat''' +
' FORMAT BCP;';
          Execute;
}
          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;

          // Update References in corresponding Tables
          if ChBLoadMedia.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBSlidesTable;

            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSTFSlideProvIDCr + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSTFSlideProvIDCr + ' = P.' + K_CMENDILIOldID + ';' + #10 +

              'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSTFSlideProvIDMod + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSTFSlideProvIDMod + ' = P.' + K_CMENDILIOldID;
            Execute;

            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end; // if ChBLoadMedia.Checked then

          if ChBLoadPat.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBAllPatientsTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDAPProvID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                ' ON A.' + K_CMENDAPProvID     + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end;

          if ChBLoadCont.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBContextsTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBCTFContID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                ' ON (A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actProvIni)) +
                    ' OR A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actProvInstIni)) +
                    ' OR A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actProvUD)) + ')'+
                ' AND A.' + K_CMENDBCTFContID     + ' = P.' + K_CMENDILIOldID+ ';';
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end;

          if ChBLoadStat.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBSlidesHistTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSlidesHTFProvID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSlidesHTFProvID + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;

            TTabName := 'Tmp' + K_CMENDBSessionsHistTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSessionsHTFProvID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSessionsHTFProvID + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;

            TTabName := 'Tmp' + K_CMENDBAllHistProvidersTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDAHProvID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDAHProvID + ' = P.' + K_CMENDILIOldID + ';';
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end; // if ChBLoadStat.Checked then
        end; // if DumpPrepCrossRefs( K_CMENDBAllProviderssTable ) > 0 then
      end; // if ChBResProv.Checked then
    end; // if ChBLoadProv.Checked then

    if ChBLoadLoc.Checked then
    begin
      if ChBResLoc.Checked then
      begin
        K_FormCMSupport.ShowInfo( ' Resolve Locations Collisions ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

        TTabName := 'Tmp' + K_CMENDBAllLocationsTable;
        CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Get Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDALBridgeID + ', 0' +
                       ' FROM ' + TTabName + ';' + #10 +

//'UNLOAD TABLE ' + K_CMENDBImportLinkIDsTable +
//' TO ''' + MergeDBDataPath + TTabName + 'LD1.dat''' +
//' FORMAT BCP;' + #10 +

                       // Set new IDs to CrossRefs Table for Identic objects
                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = A.' + K_CMENDALBridgeID +
                       ' FROM ' + K_CMENDBAllLocationsTable + ' A' +
                       ' JOIN ' + TTabName  + ' P ON' +
                       ' A.' + K_CMENDALName + ' = P.' + K_CMENDALName +
                       ' WHERE ' + K_CMENDILIOldID + '= P.' + K_CMENDALBridgeID + ';' + #10 +
{
//'UNLOAD TABLE ' + K_CMENDBImportLinkIDsTable +
//' TO ''' + MergeDBDataPath + TTabName + 'LD2.dat''' +
//' FORMAT BCP;' + #10 +
}
                       // Set new IDs to CrossRefs Table for not Identic objects
                       'SELECT MAX(' + K_CMENDALID + ') INTO @MinID FROM ' + K_CMENDBAllLocationsTable + ';' + #10 +
                       'SET @MinID = @MinID + 1;' + #10 +

                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = -100 - @MinID, @MinID = @MinID + 1' +
                       ' FROM (SELECT ' + K_CMENDALBridgeID + ' FROM ' + TTabName +
                              ' WHERE NOT EXISTS (SELECT 1 ' + K_CMENDALBridgeID +
                                                 ' FROM ' + K_CMENDBAllLocationsTable  +
                                                 ' WHERE ' +
                       K_CMENDBAllLocationsTable + '.' + K_CMENDALName + ' = ' + TTabName + '.' + K_CMENDALName + ')) P' +
                       ' WHERE ' +  K_CMENDILIOldID + '= P.' + K_CMENDALBridgeID + ';' + #10 +
{
//'UNLOAD TABLE ' + K_CMENDBImportLinkIDsTable +
//' TO ''' + MergeDBDataPath + TTabName + 'LD3.dat''' +
//' FORMAT BCP;' + #10 +
}
                       // Delete Identic CrossRefs
                       'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                       ' WHERE ' + K_CMENDILIOldID + ' = ' + K_CMENDILINewID + ';';
        Execute;
        Application.ProcessMessages;
{
//          CommandText :=
//'UNLOAD TABLE ' + K_CMENDBImportLinkIDsTable +
//' TO ''' + MergeDBDataPath + TTabName + 'LD4.dat''' +
//' FORMAT BCP;';
//          Execute;
}
        if DumpPrepCrossRefs( K_CMENDBAllLocationsTable ) > 0 then
        begin
          // Update Self
          CommandText := 'UPDATE ' + TTabName +
            ' SET '  + K_CMENDALID + ' = -100 - P.' +  K_CMENDILINewID + ', ' +
                       K_CMENDALBridgeID + ' =  P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDALBridgeID + ' = P.' + K_CMENDILIOldID + ';';

          Execute;
          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;

          // Update References in corresponding Tables
          if ChBLoadMedia.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBSlidesTable;

            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSTFSlideLocIDCr + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSTFSlideLocIDCr + ' = P.' + K_CMENDILIOldID + ';' + #10 +
              'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSTFSlideLocIDMod + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSTFSlideLocIDMod + ' = P.' + K_CMENDILIOldID;
            Execute;

            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end;

          if ChBLoadCont.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBContextsTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBCTFContID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                ' ON (A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actLocIni)) +
                    ' OR A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actLocUD)) + ')'+
                ' AND A.' + K_CMENDBCTFContID     + ' = P.' + K_CMENDILIOldID + ';';
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end;

          if ChBLoadStat.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBSessionsHistTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSessionsHTFLocID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSessionsHTFLocID + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;

            TTabName := 'Tmp' + K_CMENDBAllHistLocationsTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDAHLocID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDAHLocID + ' = P.' + K_CMENDILIOldID + ';';
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end; // if ChBLoadStat.Checked then
        end; // if DumpPrepCrossRefs( K_CMENDBAllLocationsTable ) > 0 then
      end; // if ChBResLoc.Checked then
    end; // ChBLoadLoc.Checked then

    if ChBLoadServ.Checked then
    begin
      if ChBResServ.Checked then
      begin
        TTabName := 'Tmp' + K_CMENDBAllServersTable;
        K_FormCMSupport.ShowInfo( ' Resolve Servers Collisions ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

        TTabName := 'Tmp' + K_CMENDBAllServersTable;
        CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Get Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDASServID + ', 0' +
                       ' FROM ' + TTabName + ';' + #10 +

                       // Set new IDs to CrossRefs Table for Identic objects
                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = A.' + K_CMENDASServID +
                       ' FROM ' + K_CMENDBAllServersTable + ' A' +
                       ' JOIN ' + TTabName  + ' P ON' +
                       ' A.' + K_CMENDASServName + ' = P.' + K_CMENDASServName +
                       ' WHERE ' + K_CMENDILIOldID + '= P.' + K_CMENDASServID + ';' + #10 +

                       // Set new IDs to CrossRefs Table for Linked not Identic objects
                       'SELECT MAX(' + K_CMENDASServID + ') INTO @MinID FROM ' + K_CMENDBAllServersTable + ';' + #10 +
                       'SET @MinID = @MinID + 1;' + #10 +

                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = @MinID, @MinID = @MinID + 1' +
                       ' FROM (SELECT ' + K_CMENDASServID + ' FROM ' + TTabName +
                              ' WHERE NOT EXISTS (SELECT 1 ' + K_CMENDASServID +
                                                 ' FROM ' + K_CMENDBAllServersTable  +
                                                 ' WHERE ' +
                       K_CMENDBAllServersTable + '.' + K_CMENDASServName + ' = ' + TTabName + '.' + K_CMENDASServName + ')) P' +
                       ' WHERE ' +  K_CMENDILIOldID + ' > 0 AND ' +
                                    K_CMENDILIOldID + '= P.' + K_CMENDASServID + ';' + #10 +

                       // Delete Identic CrossRefs
                       'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                       ' WHERE ' + K_CMENDILIOldID + ' = ' + K_CMENDILINewID + ';';
        Execute;
        Application.ProcessMessages;

        if DumpPrepCrossRefs( K_CMENDBAllServersTable ) > 0 then
        begin
          // Update Self
          CommandText := 'UPDATE ' + TTabName +
            ' SET '  + K_CMENDASServID + ' =  P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDASServID + ' = P.' + K_CMENDILIOldID + ';';

          Execute;
          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;

          // Update References in corresponding Tables

          if ChBLoadCont.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBContextsTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBCTFContID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                ' ON ( A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actServerUD)) + ')'+
                ' AND A.' + K_CMENDBCTFContID     + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end;

          if ChBLoadStat.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBSessionsHistTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSessionsHTFServID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSessionsHTFServID + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end;
        end; // if DumpPrepCrossRefs( K_CMENDBAllServersTable ) > 0 then
      end; // if ChBResServ.Checked then
    end; // if ChBLoadServ.Checked then

    if ChBLoadClient.Checked then
    begin
      if ChBResClient.Checked then
      begin
        K_FormCMSupport.ShowInfo( ' Resolve Clients Collisions ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

        TTabName := 'Tmp' + K_CMENDBGAInstsTable;
        CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Get Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDBGAInstsTFGlobID + ', 0' +
                       ' FROM ' + TTabName + ';' + #10 +

                       // Set new IDs to CrossRefs Table for Identic objects
                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = A.' + K_CMENDBGAInstsTFGlobID +
                       ' FROM ' + K_CMENDBGAInstsTable + ' A' +
                       ' JOIN ' + TTabName  + ' P ON' +
                       ' A.' + K_CMENDBGAInstsTFCName + ' = P.' + K_CMENDBGAInstsTFCName +
                       ' WHERE ' + K_CMENDILIOldID + '= P.' + K_CMENDBGAInstsTFGlobID + ';' + #10 +

                       // Set new IDs to CrossRefs Table for Linked not Identic objects
                       'SELECT MAX(' + K_CMENDBGAInstsTFGlobID + ') INTO @MinID FROM ' + K_CMENDBGAInstsTable + ';' + #10 +
                       'SET @MinID = @MinID + 1;' + #10 +

                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = @MinID, @MinID = @MinID + 1' +
                       ' FROM (SELECT ' + K_CMENDBGAInstsTFGlobID + ' FROM ' + TTabName +
                              ' WHERE NOT EXISTS (SELECT 1 ' + K_CMENDBGAInstsTFGlobID +
                                                 ' FROM ' + K_CMENDBGAInstsTable  +
                                                 ' WHERE ' +
                       K_CMENDBGAInstsTable + '.' + K_CMENDBGAInstsTFCName + ' = ' + TTabName + '.' + K_CMENDBGAInstsTFCName + ')) P' +
                       ' WHERE ' +  K_CMENDILIOldID + ' > 0 AND ' +
                                    K_CMENDILIOldID + '= P.' + K_CMENDBGAInstsTFGlobID + ';' + #10 +

                       // Delete Identic CrossRefs
                       'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                       ' WHERE ' + K_CMENDILIOldID + ' = ' + K_CMENDILINewID + ';';
        Execute;
        Application.ProcessMessages;

        if DumpPrepCrossRefs( K_CMENDBGAInstsTable ) > 0 then
        begin
          // Update Self
          CommandText := 'UPDATE ' + TTabName +
            ' SET '  + K_CMENDBGAInstsTFGlobID + ' =  P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDBGAInstsTFGlobID + ' = P.' + K_CMENDILIOldID + ';';

          Execute;
          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;

          // Update References in corresponding Tables

          if ChBLoadCont.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBContextsTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBCTFContID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                ' ON ( A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actGInstIni)) + ' OR ' +
                     ' A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actGInstUD)) + ')' +
                ' AND A.' + K_CMENDBCTFContID     + ' = P.' + K_CMENDILIOldID + ';' + #10 +
               'UPDATE ' + TTabName +
               ' SET '  + K_CMENDBCTFContID1 + ' =  P.' +  K_CMENDILINewID +
               ' FROM ' + TTabName + ' A' +
               ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
                 ' ON  A.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actProvInstIni)) +
                 ' AND A.' + K_CMENDBCTFContID1     + ' = P.' + K_CMENDILIOldID + ';';
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end;

          if ChBLoadStat.Checked then
          begin
            TTabName := 'Tmp' + K_CMENDBSessionsHistTable;
            CommandText := 'UPDATE ' + TTabName +
              ' SET '  + K_CMENDBSessionsHTFCompID + ' =  P.' +  K_CMENDILINewID +
              ' FROM ' + TTabName + ' A' +
              ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
              ' ON A.' + K_CMENDBSessionsHTFCompID + ' = P.' + K_CMENDILIOldID;
            Execute;
            N_Dump2Str( 'Update ' + TTabName );
            Application.ProcessMessages;
          end;
        end; // if DumpPrepCrossRefs( K_CMENDBGAInstsTable ) > 0 then
      end; // if ChBResClient.Checked then
    end; // if ChBLoadClient.Checked then

    if ChBLoadCont.Checked then
    begin

      if ChBResCont.Checked then
      begin
        K_FormCMSupport.ShowInfo( ' Resolve Media Suite Contexts Collisions ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

        TTabName := 'Tmp' + K_CMENDBContextsTable;
{
          CommandText :=
'UNLOAD TABLE ' + K_CMENDBContextsTable +
' TO ''' + MergeDBDataPath + TTabName + '1.dat''' +
' FORMAT BCP;';
          Execute;

          CommandText :=
'UNLOAD TABLE ' + TTabName +
' TO ''' + MergeDBDataPath + TTabName + '2.dat''' +
' FORMAT BCP;';
          Execute;
{}
{
        CommandText := // Delete Source Objects Identic to Resulting
              'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBContextsTable + ' WHERE (' +
                 TTabName + '.' + K_CMENDBCTFContTypeID + ' <> ' + IntToStr(Ord(K_actProvInstIni))  +' AND ' +
                 TTabName + '.' + K_CMENDBCTFContID + '=' + K_CMENDBContextsTable +'.' + K_CMENDBCTFContID + ') OR (' +
                 TTabName + '.' + K_CMENDBCTFContTypeID + ' = ' + IntToStr(Ord(K_actProvInstIni))  + ' AND ' +
                 TTabName + '.' + K_CMENDBCTFContID  + '=' + K_CMENDBContextsTable +'.' + K_CMENDBCTFContID  + ' AND ' +
                 TTabName + '.' + K_CMENDBCTFContID1 + '=' + K_CMENDBContextsTable +'.' + K_CMENDBCTFContID1 + ');';
        Execute;
}
      // Delete Added Records with primery keys identic to Target
        CommandText :=
              'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBContextsTable + ' WHERE ' +
                 TTabName + '.' + K_CMENDBCTFContTypeID + '=' + K_CMENDBContextsTable + '.' + K_CMENDBCTFContTypeID + ' AND ' +
                 TTabName + '.' + K_CMENDBCTFContID     + '=' + K_CMENDBContextsTable + '.' + K_CMENDBCTFContID     + ' AND ' +
                 TTabName + '.' + K_CMENDBCTFContID1    + '=' + K_CMENDBContextsTable + '.' + K_CMENDBCTFContID1 + ';';
        Execute;

{
          CommandText :=
'UNLOAD TABLE ' + K_CMENDBContextsTable +
' TO ''' + MergeDBDataPath + TTabName + '3.dat''' +
' FORMAT BCP;';
          Execute;

          CommandText :=
'UNLOAD TABLE ' + TTabName +
' TO ''' + MergeDBDataPath + TTabName + '4.dat''' +
' FORMAT BCP;';
          Execute;
{}

      // Delete Added Records with identic primery keys

        CommandText := // add column with uniq key value
            'ALTER TABLE ' + TTabName +
            ' ADD "UID" INTEGER NULL;' + #10 +
            'SET @MinID = 1;' + #10 +
            'UPDATE ' + TTabName +
               ' SET UID = @MinID, @MinID = @MinID + 1' +
               ' WHERE ' + K_CMENDBCTFContID + ' >= 0;';
        Execute;

        // Delete Records with identic Type and ID and ID1
        with CurDSet1 do
        begin
          SQL.Text := 'select  UID, ' +
                               K_CMENDBCTFContTypeID + ', ' +
                               K_CMENDBCTFContID     + ', ' +
                               K_CMENDBCTFContID1    +
                      ' from ' + TTabName + ' order by ' +
                               K_CMENDBCTFContTypeID + ', ' +
                               K_CMENDBCTFContID     + ', ' +
                               K_CMENDBCTFContID1;
          Open();
          if RecordCount > 1 then
          begin
            ContType := Fields[1].AsInteger;
            ContID   := Fields[2].AsInteger;
            ContID1  := Fields[3].AsInteger;
            DelCount := 0;
            Next;

            while not Eof do
            begin
              if (ContType = Fields[1].AsInteger) and
                 (ContID   = Fields[2].AsInteger) and
                 (ContID1  = Fields[3].AsInteger) then
              begin
                Delete;
                Inc(DelCount);
                Continue;
              end
              else
              begin
                ContType := Fields[1].AsInteger;
                ContID   := Fields[2].AsInteger;
                ContID1  := Fields[3].AsInteger;
                Next;
              end;
            end; // while not Eof do

            if DelCount > 0 then
            begin
              K_FormCMSupport.ShowInfo( format( ' %d added duplicates are removed ', [DelCount] ), 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
              UpdateBatch;
            end;
          end;
          Close();
        end;

        CommandText := // Remove column with uniq key value
            'ALTER TABLE ' + TTabName + ' DELETE "UID";';
        Execute;

{
          CommandText :=
'UNLOAD TABLE ' + TTabName +
' TO ''' + MergeDBDataPath + TTabName + '5.dat''' +
' FORMAT BCP;';
          Execute;
{}
        N_Dump2Str( 'Update ' + TTabName );
        Application.ProcessMessages;
      end; // if ChBResCont.Checked then
    end; // if ChBLoadCont.Checked then

    if ChBLoadStat.Checked then
    begin
      if ChBResStat.Checked then
      begin
        K_FormCMSupport.ShowInfo( ' Resolve Statistics Collisions ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

        TTabName := 'Tmp' + K_CMENDBSessionsHistTable;
        CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Get Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDBSessionsHTFSessionID + ', 0' +
                       ' FROM ' + TTabName + ';' + #10 +

                       // Set new IDs to CrossRefs Table for Linked not Identic objects
                       'SELECT MAX(' + K_CMENDBSessionsHTFSessionID + ') INTO @MinID FROM ' + K_CMENDBSessionsHistTable + ';' + #10 +
                       'SET @MinID = @MinID + 1;' + #10 +

                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = @MinID, @MinID = @MinID + 1;';

        Execute;
        Application.ProcessMessages;

        if DumpPrepCrossRefs( K_CMENDBSessionsHistTable ) > 0 then
        begin
          // Update Self
          CommandText := 'UPDATE ' + TTabName +
            ' SET '  + K_CMENDBSessionsHTFSessionID + ' = P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDBSessionsHTFSessionID + ' = P.' + K_CMENDILIOldID + ';';

          Execute;
          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;

          // Update References in corresponding Tables

          TTabName := 'Tmp' + K_CMENDBSlidesNewHistTable;
          CommandText := 'UPDATE ' + TTabName +
            ' SET '  + K_CMENDBSlidesNHTFSlideID + ' =  P.' +  K_CMENDILINewID +
            ' FROM ' + TTabName + ' A' +
            ' JOIN ' + K_CMENDBImportLinkIDsTable  + ' P' +
            ' ON A.' + K_CMENDBSlidesNHTFSessionID + ' = P.' + K_CMENDILIOldID;
          Execute;
          N_Dump2Str( 'Update ' + TTabName );
          Application.ProcessMessages;
        end; // if DumpPrepCrossRefs( K_CMENDBSessionsHistTable ) > 0 then
      end; // if ChBResStat.Checked then
    end; // if ChBLoadStat.Checked then
    //
    // Resolve data collisions
    ////////////////////////////////////

    //////////////////////////////////////
    // Add data to DB
    //
    if ChBLoadMedia.Checked then
    begin // Save SlidesCopyFSData

      K_FormCMSupport.ShowInfo( ' Prepare media data copy ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      CommandText := 'CREATE LOCAL TEMPORARY TABLE SlidesCopyFSData ' +
                     '(OldID int, NewID int, OldPatID int, NewPatID int, DTCr datetime, SysInfo varchar(1000)) NOT TRANSACTIONAL;' + #10 +
            'INSERT SlidesCopyFSData (OldID, NewID, OldPatID, NewPatID, DTCr, SysInfo)' +
            ' SELECT A.OldID, A.NewID, A.OldPatID, P.' + K_CMENDBSTFPatID +
                 //           4                                  5
                 ', P.' + K_CMENDBSTFSlideDTCr + ', P.' + K_CMENDBSTFSlideSysInfo +
                 ' FROM SlidesCopyMoveInfo A JOIN Tmp' + K_CMENDBSlidesTable +
                 ' P ON A.NewID = P.' + K_CMENDBSTFSlideID + ';';
      Execute;

      MergeCopyFSDataCount := GetTableCount( 'SlidesCopyFSData' );
      N_Dump1Str( format( 'DAD>> %d records are in SlidesCopyFSData',
                          [MergeCopyFSDataCount] ) );

      CommandText := 'UNLOAD TABLE SlidesCopyFSData TO ''' + MergeCopyFSDataFName + ''' FORMAT BCP;';
      Execute;
    end; // if ChBLoadMedia.Checked then

    LANDBConnection.BeginTrans;

    if ChBLoadMedia.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Add Media Objects ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      if K_CMEDDBVersion >= 40 then // Set ID to NextSlideID sequence
      begin
        CommandText := 'begin EXECUTE IMMEDIATE string( ''ALTER SEQUENCE dba.NextSlideID RESTART WITH '', @SlidesSEQNewID ) end;' + #10;
        Execute;
      end;

      TTabName := 'Tmp' + K_CMENDBMTypesTable;
      CommandText :=
        // Delete Source Objects Identic to Resulting
        'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBMTypesTable +
        ' WHERE ' + TTabName +'.' + K_CMENDBMTFMTypeID +
           ' = ' + K_CMENDBMTypesTable + '.' + K_CMENDBMTFMTypeID + ';'#10 +
        'INSERT INTO ' + K_CMENDBMTypesTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName + ';';

      Execute;

      DumpAddInfo( TTabName, K_CMENDBMTypesTable);
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBSlidesTable;
      CommandText := 'INSERT INTO ' + K_CMENDBSlidesTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName + ';';
      Execute;

      DumpAddInfo( TTabName, K_CMENDBSlidesTable );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBDelMarkedSlidesTable;
      CommandText := 'INSERT INTO ' + K_CMENDBDelMarkedSlidesTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName + ';';
      Execute;

      DumpAddInfo( TTabName, K_CMENDBDelMarkedSlidesTable );
      Application.ProcessMessages;
    end; // if ChBLoadMedia.Checked then

    if ChBLoadPat.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Add Patients ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      TTabName := 'Tmp' + K_CMENDBAllPatientsTable;
      CommandText :=
        // Delete Source Objects Identic to Resulting
        'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBAllPatientsTable +
        ' WHERE ' + TTabName + '.' + K_CMENDAPBridgeID +
           ' = ' + K_CMENDBAllPatientsTable + '.' + K_CMENDAPBridgeID + ';'#10 +
        'ALTER TABLE ' + TTabName + ' DROP ' + K_CMENDAPID + ';'#10 +
        'INSERT INTO ' + K_CMENDBAllPatientsTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName + ';';
      Execute;

      DumpAddInfo( TTabName, K_CMENDBAllPatientsTable );
      Application.ProcessMessages;

    end; // if ChBLoadPat.Checked then

    if ChBLoadProv.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Add Providers ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      TTabName := 'Tmp' + K_CMENDBAllProvidersTable;
      CommandText :=
        // Delete Source Objects Identic to Resulting
        'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBAllProvidersTable +
        ' WHERE ' + TTabName +'.' + K_CMENDAUBridgeID +
           ' = ' + K_CMENDBAllProvidersTable + '.' + K_CMENDAUBridgeID + ';'#10 +
        'ALTER TABLE ' + TTabName + ' DROP ' + K_CMENDAUID + ';'#10 +
        'INSERT INTO ' + K_CMENDBAllProvidersTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName + ';';
      Execute;

      DumpAddInfo( TTabName, K_CMENDBAllProvidersTable );
      Application.ProcessMessages;
    end; // if ChBLoadProv.Checked then

    if ChBLoadLoc.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Add Locations ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      TTabName := 'Tmp' + K_CMENDBAllLocationsTable;
      CommandText :=
        // Delete Source Objects Identic to Resulting
        'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBAllLocationsTable +
        ' WHERE ' + TTabName +'.' + K_CMENDALBridgeID +
           ' = ' + K_CMENDBAllLocationsTable + '.' + K_CMENDALBridgeID + ';'#10 +
        'ALTER TABLE ' + TTabName + ' DROP ' + K_CMENDALID + ';'#10 +
        'INSERT INTO ' + K_CMENDBAllLocationsTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName + ';';
      Execute;

      DumpAddInfo( TTabName, K_CMENDBAllLocationsTable );
      Application.ProcessMessages;

    end; // ChBLoadLoc.Checked then

    if ChBLoadServ.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Add Servers ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      TTabName := 'Tmp' + K_CMENDBAllServersTable;
      CommandText :=
          // Delete Source Objects Identic to Resulting
          'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBAllServersTable +
          ' WHERE ' + TTabName +'.' + K_CMENDASServID +
             ' = ' + K_CMENDBAllServersTable + '.' + K_CMENDASServID + ';'#10 +
          'INSERT INTO ' + K_CMENDBAllServersTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName+ ';';
      Execute;

      DumpAddInfo( TTabName, K_CMENDBAllServersTable );
      Application.ProcessMessages;

    end; // if ChBLoadServ.Checked then

    if ChBLoadClient.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Add Clients ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      TTabName := 'Tmp' + K_CMENDBGAInstsTable;
      CommandText :=
              // Delete Source Objects Identic to Resulting
        'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBGAInstsTable +
        ' WHERE ' + TTabName +'.' + K_CMENDBGAInstsTFGlobID +
           ' = ' + K_CMENDBGAInstsTable + '.' + K_CMENDBGAInstsTFGlobID + ';'#10 +

        'INSERT INTO ' + K_CMENDBGAInstsTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName+ ';';
      Execute;

      DumpAddInfo( TTabName, K_CMENDBGAInstsTable );
      Application.ProcessMessages;

    end; // if ChBLoadClient.Checked then

    if ChBLoadCont.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Add Media Suite Contexts ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      TTabName := 'Tmp' + K_CMENDBContextsTable;
      CommandText := 'INSERT INTO ' + K_CMENDBContextsTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName;
      Execute;

{
CommandText :=
'UNLOAD TABLE ' + K_CMENDBContextsTable +
' TO ''' + MergeDBDataPath + TTabName + '6.dat''' +
' FORMAT BCP;';
Execute;
{}
      DumpAddInfo( TTabName, K_CMENDBContextsTable );
      Application.ProcessMessages;

    end; // if ChBLoadCont.Checked then

    if ChBLoadStat.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Add Statistics ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      TTabName := 'Tmp' + K_CMENDBSlidesHistTable;
      CommandText := 'INSERT INTO ' + K_CMENDBSlidesHistTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName;
      Execute;

      DumpAddInfo( TTabName, K_CMENDBSlidesHistTable );
      Application.ProcessMessages;



      TTabName := 'Tmp' + K_CMENDBSlidesNewHistTable;
      CommandText := 'INSERT INTO ' + K_CMENDBSlidesNewHistTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName;
      Execute;

      DumpAddInfo( TTabName, K_CMENDBSlidesNewHistTable );
      Application.ProcessMessages;


      TTabName := 'Tmp' + K_CMENDBSessionsHistTable;
      CommandText := 'INSERT INTO ' + K_CMENDBSessionsHistTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName;
      Execute;

      DumpAddInfo( TTabName, K_CMENDBSessionsHistTable );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBAllHistPatientsTable;
      CommandText :=
        // Delete Source Objects Identic to Resulting
        'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBAllHistPatientsTable +
        ' WHERE ' + TTabName +'.' + K_CMENDAHPatID +
           ' = ' + K_CMENDBAllHistPatientsTable + '.' + K_CMENDAHPatID + ';'#10 +
        'INSERT INTO ' + K_CMENDBAllHistPatientsTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName;
      Execute;

      DumpAddInfo( TTabName, K_CMENDBAllHistPatientsTable );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBAllHistProvidersTable;
      CommandText :=
            // Delete Source Objects Identic to Resulting
        'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBAllHistProvidersTable +
        ' WHERE ' + TTabName +'.' + K_CMENDAHProvID +
           ' = ' + K_CMENDBAllHistProvidersTable + '.' + K_CMENDAHProvID + ';'#10 +
        'INSERT INTO ' + K_CMENDBAllHistProvidersTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName+ ';';
      Execute;

      DumpAddInfo( TTabName, K_CMENDBAllHistProvidersTable );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBAllHistLocationsTable;
      CommandText :=
        // Delete Source Objects Identic to Resulting
        'DELETE FROM ' + TTabName + ' FROM ' + K_CMENDBAllHistLocationsTable +
        ' WHERE ' + TTabName +'.' + K_CMENDAHLocID +
           ' = ' + K_CMENDBAllHistLocationsTable + '.' + K_CMENDAHLocID + ';'#10 +
        'INSERT INTO ' + K_CMENDBAllHistLocationsTable + ' WITH AUTO NAME SELECT * FROM ' + TTabName+ ';';
      Execute;

      DumpAddInfo( TTabName, K_CMENDBAllHistLocationsTable );
      Application.ProcessMessages;
    end; // if ChBLoadStat.Checked then

    LANDBConnection.CommitTrans;
    //
    // Add data to DB
    ////////////////////////////////////

    CopyLogs();


    CommandText := 'DROP TABLE IF EXISTS Tmp' + K_CMENDBMTypesTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBSlidesTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBDelMarkedSlidesTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBAllPatientsTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBAllProvidersTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBAllLocationsTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBAllServersTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBGAInstsTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBContextsTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBSlidesHistTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBSlidesNewHistTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBSessionsHistTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBAllHistPatientsTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBAllHistProvidersTable + ';' + #10 +
                   'DROP TABLE IF EXISTS Tmp' + K_CMENDBAllHistLocationsTable + ';' + #10 +
                   'DROP VARIABLE IF EXISTS @MinID;' + #10 +
                   'DROP VARIABLE IF EXISTS @MinID1;' + #10 +
                   'DROP TABLE IF EXISTS PAIDs1;' + #10 +
                   'DROP TABLE IF EXISTS SlidesCopyMoveInfo;';
    Execute;

    Screen.Cursor := SavedCursor;
//    BtOpen.Enabled := TRUE;
//    BtLoad.Enabled := TRUE;

    K_FormCMSupport.ShowInfo( ' All DB Data is loaded' , 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

    //////////////////////////////////////
    // Copy Media Files Prepare
    //
    if ChBLoadMedia.Checked then
    begin
      K_FormCMSupport.ShowInfo( ' Preparing copy Image, Video and 3D Files is finished ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
      if not SaveCopyFSDataStateToFile( ) then
        N_Dump1Str( 'DAD>> Couldn''t write init cur info file' );

      BtLoad.Enabled := FALSE;
      BtCopy.Enabled := TRUE;

      // Skip Settings Edit before copy files
      ChBLoadMedia.Enabled  := FALSE;
      ChBLoadPat.Enabled    := FALSE;
      ChBLoadProv.Enabled   := FALSE;
      ChBLoadLoc.Enabled    := FALSE;
      ChBLoadServ.Enabled   := FALSE;
      ChBLoadClient.Enabled := FALSE;
      ChBLoadCont.Enabled   := FALSE;
      ChBLoadStat.Enabled   := FALSE;

      ChBResProv.Enabled   := FALSE;
      ChBResLoc.Enabled    := FALSE;
      ChBResServ.Enabled   := FALSE;
      ChBResClient.Enabled := FALSE;
    end; // if ChBLoadMedia.Checked then
    //
    // Copy Media Files
    ////////////////////////////////////

  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do


//  ChBLoadMedia.Checked;
//  K_NotAddedStrings.Free();
//  K_NotAddedStrings := nil;
//  Self.Close;
end; // procedure TK_FormCMUTLoadDBData.BtLoadClick

procedure TK_FormCMUTLoadDBData2.BtCopyClick(Sender: TObject);
var
  ErrRootPath : string;
  ImgRootPath : string;
  VideoRootPath : string;
  Img3DRootPath : string;

  FilesPattern : string;
  N, i, j, OldPatID, NewPatID : Integer;
  VideoFile, Img3DFile : Boolean;

  CrDT : TDateTime;
  SysInfo, NewLocPath, OldLocPath, SrcBasePath, DstBasePath, SOldID, SNewID,
  OldFName, NewFName, AddNamePat : string;

  CopyResCode : Integer;
//  FStream : TFileStream;
  DumpResStr : string;

begin
  K_FormCMSupport.ShowInfo( ' Copy Image, Video and 3D Files ', 'TK_FormCMUTLoadDBData.BtCopyClick >>' );

  ProgressFormat := 'Copy media, %d%% done';

  if BtCopy.Caption = IniBtCopyCaption then
    BtCopy.Caption := 'Copy pause'
  else
  begin
    BtCopy.Enabled := FALSE;
    Exit;
  end;

  if not LoadCopyFSDataStateFromFile( ) then Exit;

  if not FileExists(MergeCopyFSDataFName) then
  begin // precaution
    K_FormCMSupport.ShowInfo( 'Copy media data file is absent',
                              'TK_FormCMUTLoadDBData.BtCopyClick >>' );
    Exit;
  end;

  LoadSlidesCopyFSDataTable();

  ImgRootPath := MergeRootPath + K_ImgFolder;
  if not DirectoryExists( ImgRootPath ) then
    ImgRootPath := '';

  VideoRootPath := MergeRootPath + K_VideoFolder;
  if not DirectoryExists( VideoRootPath ) then
    VideoRootPath := '';

  Img3DRootPath := MergeRootPath + K_Img3DFolder;
  if not DirectoryExists( Img3DRootPath ) then
    Img3DRootPath := '';

  ProgressShowPrev := -1;
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet2 do
  begin
    Connection := LANDBConnection;
    while TRUE do
    begin
      if MergeCopyFSDataStart + MergeCopyFSDataPortion > MergeCopyFSDataCount + 1 then
        MergeCopyFSDataPortion := MergeCopyFSDataCount - MergeCopyFSDataStart + 1;

      if MergeCopyFSDataPortion <= 0 then break; // Break Copy Loop

      SQL.Text := 'SELECT TOP ' + IntToStr(MergeCopyFSDataPortion) + ' START AT ' + IntToStr(MergeCopyFSDataStart) +
                  ' * FROM SlidesCopyFSData;';
      Filtered := FALSE;
      Open();
      N := RecordCount;
      First();
      for i := 0 to N - 1 do
      begin
        SOldID := Fields[0].AsString;
        SNewID := K_CMSlideGetFileIDPathSegm( Fields[1].AsString );
        OldPatID := Fields[2].AsInteger;
        NewPatID := Fields[3].AsInteger;
        CrDT  := Fields[4].AsDateTime;
        SysInfo := EDAGetStringFieldValue( Fields[5] );
        OldLocPath := K_CMSlideGetFileDatePathSegm( CrDT );
        NewLocPath := K_CMSlideGetPatientFilesPathSegm( NewPatID ) +
                      OldLocPath;
        OldLocPath := K_CMSlideGetPatientFilesPathSegm( OldPatID ) +
                      OldLocPath;
        VideoFile := Pos( 'cmsfIsMediaObj', SysInfo ) > 0;
        Img3DFile := Pos( '3D', SysInfo ) > 0;
        AddNamePat := '';
        if VideoFile then
        begin
          DstBasePath := SlidesMediaRootFolder;
          SrcBasePath := VideoRootPath;
          ErrRootPath := K_VideoFolder;
        end
        else                                  //
        if Img3DFile then
        begin
// 2020-07-28 add Capt3DDevObjName <> ''  if Pos( 'Capt3DDevObjName', SysInfo ) = 0 then
// 2020-09-25 add new condition for Dev3D objs
          if (Pos( 'Capt3DDevObjName', SysInfo ) = 0) or (Pos( 'MediaFExt', SysInfo ) = 0) then
          begin // self Img3D object
            DstBasePath := SlidesImg3DRootFolder;
            SrcBasePath := Img3DRootPath;
            ErrRootPath := K_Img3DFolder;
// 2020-07-28 add Capt3DDevObjName <> ''
          end
          else
          begin // Device 3D object
            Next();
            Continue;
          end;
        end
        else
        begin
          DstBasePath := SlidesImgRootFolder;
          SrcBasePath := ImgRootPath;
          ErrRootPath := K_ImgFolder;
          AddNamePat := '*';
        end;

        if SrcBasePath = '' then
        begin
          K_CMShowMessageDlg( 'Path "' +  ErrRootPath + '" is absent!!!'#13#10+
                              '           Files are not copied!!!'#13#10+
                              '     Please click OK to finish the action', mtError );
          Break;
        end;

        TmpStrings.Clear;
        FilesPattern := '?F_' + K_CMSlideGetFileIDPathSegm( SOldID ) +
                         AddNamePat + '.*';
        K_ScanFilesTree( SrcBasePath + OldLocPath, EDASelectDataFiles,
                         FilesPattern, Img3DFile );
        N_Dump2Str( format('Copy %s%s%s',[SrcBasePath,OldLocPath,FilesPattern]) );
        DstBasePath := DstBasePath + NewLocPath;
        if TmpStrings.Count > 0 then
          for j := 0 to TmpStrings.Count - 1 do
          begin
            OldFName := ExtractFileName( ExcludeTrailingPathDelimiter(TmpStrings[j]) );
            //                         File Name Start Chars    New ID   File Extension
            NewFName := DstBasePath +  Copy( OldFName, 1, 3 ) + SNewID + Copy( OldFName, 12, 8 );

            if OldFName[1] <> '3' then
            begin // Atrs File(for Image, Video and 3D), Image, Video, Study
              CopyResCode := K_CopyFile( TmpStrings[j], NewFName );
              if CopyResCode = 0 then
              begin
  //              K_CopyFile( TmpStrings[j], DstBasePath + NewFName );
                if OldFName[1] <> 'A' then
                begin // Image, Video, Study (studies are count as Image)
                  if VideoFile then
                    Inc(MergeCopyVCount)
                  else
                  if OldFName[1] <> 'S' then
                    Inc(MergeCopy2Count)
                  else
                    Inc(MergeCopySCount);
                end;
                N_Dump2Str( format( 'File %s >> %s copy',[TmpStrings[j],NewFName,CopyResCode]) );
              end
              else
                N_Dump1Str( format( 'DAD>> File %s >> %s >> copy error = %d',[TmpStrings[j],NewFName,CopyResCode]) );
            end   // if OldFName[1] <> '3' then
            else
            begin // if OldFName[1] = '3' then  // 3D Image Folder
              if K_CopyFolderFiles( IncludeTrailingPathDelimiter(TmpStrings[j]),
                                    IncludeTrailingPathDelimiter(NewFName) ) then
              begin
                Inc(MergeCopy3Count);
                N_Dump2Str( format( 'Files %s >> %s copy',[TmpStrings[j],NewFName]) );
              end
              else
                N_Dump1Str( format( 'DAD>> Files %s >> %s >> some copy error',[TmpStrings[j],NewFName]) );
            end; // if OldFName[1] = '3' then  // 3D Image Folder
          end // for j := 0 to TmpStrings.Count - 1 do
        else
          N_Dump1Str( format( 'DAD>> Files %s are not found',[SrcBasePath + OldLocPath + FilesPattern]) );

        // Show Progress
        ShowProgress( MergeCopyFSDataCount, MergeCopyFSDataStart );
        Inc(MergeCopyFSDataStart);
        Next();

        if not SaveCopyFSDataStateToFile( ) then
          N_Dump1Str( 'DAD>> Couldn''t rewrite cur info file ' );
//sleep(500);  // debug
        Application.ProcessMessages;
        if not BtCopy.Enabled then Break; // Pause by User
      end; // for i := 0 to N - 1 do
      N_Dump2Str( format( 'DAD>> Current Copy state: %d Image, %d Study, %d Video files and %d 3D folders for %d of %d Media Objects',
                                          [MergeCopy2Count, MergeCopySCount,
                                           MergeCopyVCount, MergeCopy3Count,
                                           MergeCopyFSDataStart - 1,MergeCopyFSDataCount] ) );

      Close();
      if not BtCopy.Enabled then Break;
    end; // while TRUE
  end; // with CurDSet2 do
  K_FormCMSupport.ShowInfo( format( '%d Image, %d Study, %d Video files and %d 3D folders for %d of %d Media Objects are added',
                                    [MergeCopy2Count, MergeCopySCount,
                                     MergeCopyVCount, MergeCopy3Count,
                                     MergeCopyFSDataStart-1,MergeCopyFSDataCount] ), 'TK_FormCMUTLoadDBData.BtCopyClick >>' );
  CopyLogs();


  // Check Pause
  if not BtCopy.Enabled and
     BtCancel.Enabled then
  begin // Pause is set not from CloseQuery
    BtCopy.Caption := IniBtCopyCaption;
    BtCopy.Enabled := TRUE;
    Exit;
  end;

  // All done - Close Merge Dialog
  if MergeCopyFSDataCount < MergeCopyFSDataStart then
    K_AddStringToTextFile( MergeReportFName,
     format( 'Total to Target:'#13#10 +
             '%6d DB media objects,'#13#10 +
             '%6d corresponding Files and 3D folders.',
               [MergeCopyFSDataCount, MergeCopy2Count + MergeCopySCount + MergeCopyVCount + MergeCopy3Count] ) );


  if ChBCheckFS.Checked then
  begin
  /////////////////////////////////////////////
  // Check and Dump Target DB and Files Storage
  //
    N_Dump1Str( 'DAD>> Dump Target File Storage after' );
    LbInfo.Caption := 'Build Existed ...';
    LbInfo.Refresh();
    DumpFSExisted( 'T2\FSDumpsAfter\' );
    N_Dump1Str( 'DAD>> Existed Files are build' );
    ProgressFormat := 'Build Needed, %d%% done';
    DumpFSNeeded( 'T2\FSDumpsAfter\' );
    N_Dump1Str( 'DAD>> Needed Files are build' );
    FSAfterExisted := AllExistedFList.Count;
    FSAfterNeeded  := AllNeededFList.Count;
    FSAfterArchived:= AllArchivedFList.Count;
    LbInfo.Caption := 'Build Extra/Missing ...';
    K_CMFSCompNeededExistedFLists( AllExistedFList, AllNeededFList, nil );
    N_Dump1Str( 'DAD>> Extra and Missing Files are build' );
    FSAfterExtra := AllExistedFList.Count;
    FSAfterMissing  := AllNeededFList.Count;
    LbInfo.Caption := '';
    K_AddStringToTextFile( MergeReportFName,
      format( 'Target File Storage after: Existed=%d, Needed=%d, Extra=%d, Missing=%d Archived=%d',
              [FSAfterExisted, FSAfterNeeded, FSAfterExtra, FSAfterMissing,FSAfterArchived] ) );
    if AllExistedFList.Count > 0 then
      K_AddStringToTextFile( MergeInfoPath + 'T2\FSDumpsAfter\Extra.txt',
                             AllExistedFList.Text );
    if AllNeededFList.Count > 0 then
      K_AddStringToTextFile( MergeInfoPath + 'T2\FSDumpsAfter\Missing.txt',
                             AllNeededFList.Text );
    if AllArchivedFList.Count > 0 then
      K_AddStringToTextFile( MergeInfoPath + 'T2\FSDumpsAfter\Archived.txt',
                             AllArchivedFList.Text );
    LbInfo.Caption := '';
    LbInfo.Refresh();
  //
  // Check and Dump Target DB and Files Storage
  /////////////////////////////////////////////

   if (FSAfterExtra = FSBeforeExtra) and
      (FSAfterMissing = FSBeforeMissing) and
      (FSAfterExisted - FSBeforeExisted =
       MergeCopy2Count + MergeCopySCount + MergeCopyVCount + MergeCopy3Count) then
      DumpResStr := 'All is OK!!!'
    else
    begin
      DumpResStr := 'Something is not OK!!!';
      if FSAfterExtra > FSBeforeExtra then
        DumpResStr := DumpResStr + ' (Extra files are enlarged)';
      if FSAfterMissing > FSBeforeMissing then
        DumpResStr := DumpResStr + ' (Missing files are enlarged)';
      if FSAfterExisted - FSBeforeExisted <>
         MergeCopy2Count + MergeCopySCount + MergeCopyVCount + MergeCopy3Count then
        DumpResStr := DumpResStr + ' (Files copy not OK)';
   end;
  end // if ChBCheckFS then
  else
    DumpResStr := 'Resulting Files Storage detailed control was not done.';

  K_AddStringToTextFile( MergeReportFName, DumpResStr );

  K_CMShowMessageDlg1( format( '  Data loading is finished.'#13#10 +
                               '  %s'#13#10' All details are in %s.',
                              [DumpResStr, MergeInfoPath]) , mtInformation );
  Self.Close;
end; // procedure TK_FormCMUTLoadDBData2.BtCopyClick

procedure TK_FormCMUTLoadDBData2.CurStateToMemIni;
begin
  inherited;
  N_ComboBoxToMemIni( 'CMSLoadDBDataPathsHistory', PathNameFrame.mbPathName );
end; // procedure TK_FormCMUTLoadDBData.CurStateToMemIni

procedure TK_FormCMUTLoadDBData2.MemIniToCurState;
begin
  inherited;
  N_MemIniToComboBox( 'CMSLoadDBDataPathsHistory', PathNameFrame.mbPathName );
  PathNameFrame.AddNameToTop( PathNameFrame.mbPathName.Text );

end; // procedure TK_FormCMUTLoadDBData.MemIniToCurState

procedure TK_FormCMUTLoadDBData2.ShowProgress( AllCount, CurCount: Integer);
begin
  ProgressShow := Round(100 * CurCount / AllCount);
  if ProgressShow > ProgressShowPrev then
  begin
    LbInfo.Caption := format( ProgressFormat, [ProgressShow] );
    ProgressShowPrev := ProgressShow;
//    LbInfo.Refresh();
    Self.Refresh();
  end;
end; // procedure TK_FormCMUTLoadDBData1.ShowProgress

procedure TK_FormCMUTLoadDBData2.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := (MergeCopyFSDataCount < MergeCopyFSDataStart) or
              not BtCancel.Enabled;

  if not CanClose then
  begin
    CanClose := mrYes = K_CMShowMessageDlg(
      'Do you really want to exit while media data copy is not finished?',
                        mtConfirmation );
    if not CanClose then
      Exit;

    N_Dump1Str( 'DAD>> Break by user ' );

    if (BtCopy.Caption <> IniBtCopyCaption) then
    begin // Copy Media Data is in progress
      BtCopyClick( BtCopy ); // Stop Media Data copy
      BtCancel.Enabled := FALSE; // Self Close Flag
      Exit;
    end;
  end; // if not CanClose then


  K_NotAddedStrings.Free();
  K_NotAddedStrings := nil;

  with TK_CMEDDBAccess(K_CMEDAccess).CurSQLCommand1 do
  begin
    CommandText := 'DROP TABLE IF EXISTS SlidesCopyFSData;';
    Execute;
  end;
end; // procedure TK_FormCMUTLoadDBData2.FormCloseQuery

end.
