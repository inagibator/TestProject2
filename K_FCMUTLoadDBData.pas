unit K_FCMUTLoadDBData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_BaseF, StdCtrls, ExtCtrls, K_FPathNameFr, ComCtrls;

type
  TK_FormCMUTLoadDBData = class(TN_BaseForm)
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
    procedure FormShow(Sender: TObject);
    procedure BtOpenClick(Sender: TObject);
    procedure BtLoadClick(Sender: TObject);
    procedure ChBLoadMediaClick(Sender: TObject);
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

    AllRootPath : string;
    DBDataRootPath : string;

    procedure RebuildPathSettings;
    procedure PathChange;

  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMUTLoadDBData: TK_FormCMUTLoadDBData;

procedure K_CMUTLoadDBDataDlg();

implementation

uses K_CLib0, K_CM0, K_FCMSupport,
     N_Lib0, N_Lib1, N_Types;
{$R *.dfm}

//***************************************************** K_CMUTLoadDBDataDlg ***
// Load Data from other DB
//
procedure K_CMUTLoadDBDataDlg();
begin

  K_FormCMUTLoadDBData := TK_FormCMUTLoadDBData.Create(Application);
  with K_FormCMUTLoadDBData do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    PathNameFrame.OnChange := PathChange;
    K_FormCMSupport.InfoStatusBar := StatusBar;
    ShowModal();
    K_FormCMSupport.InfoStatusBar := K_FormCMSupport.StatusBar;
    K_FormCMUTLoadDBData := nil;
  end;

end; // K_CMUTLoadDBDataDlg

procedure TK_FormCMUTLoadDBData.PathChange;
begin
  BtOpen.Enabled := PathNameFrame.mbPathName.Text <> '';
  BtLoad.Enabled := FALSE;

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

end;

procedure TK_FormCMUTLoadDBData.RebuildPathSettings;
var
  CorrectPathExists : Boolean;
begin
  AllRootPath := PathNameFrame.mbPathName.Text;

  CorrectPathExists := AllRootPath <> '';
  AllRootPath := IncludeTrailingPathDelimiter(AllRootPath);
  DBDataRootPath := AllRootPath + 'DBData\';

  if CorrectPathExists then
  begin

    MediaDataExists :=
      FileExists( DBDataRootPath + K_CMENDBMTypesTable + '.dat' ) and
      FileExists( DBDataRootPath + K_CMENDBSlidesTable + '.dat' ) and
      FileExists( DBDataRootPath + K_CMENDBDelMarkedSlidesTable + '.dat' );

    PatDataExists  := FileExists( DBDataRootPath + K_CMENDBAllPatientsTable + '.dat' );
    ProvDataExists := FileExists( DBDataRootPath + K_CMENDBAllProvidersTable + '.dat' );
    LocDataExists  := FileExists( DBDataRootPath + K_CMENDBAllLocationsTable + '.dat' );
    ServDataExists := FileExists( DBDataRootPath + K_CMENDBAllServersTable + '.dat' );
    ClientDataExists := FileExists( DBDataRootPath + K_CMENDBGAInstsTable + '.dat' );
    ContDataExists := FileExists( DBDataRootPath + K_CMENDBContextsTable + '.dat' );
    StatDataExists :=
      FileExists( DBDataRootPath + K_CMENDBSlidesHistTable + '.dat' ) and
      FileExists( DBDataRootPath + K_CMENDBSlidesNewHistTable + '.dat' ) and
      FileExists( DBDataRootPath + K_CMENDBSessionsHistTable + '.dat' ) and
      FileExists( DBDataRootPath + K_CMENDBAllHistPatientsTable + '.dat' ) and
      FileExists( DBDataRootPath + K_CMENDBAllHistProvidersTable + '.dat' ) and
      FileExists( DBDataRootPath + K_CMENDBAllHistLocationsTable + '.dat' );

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
  ChBResPat.Checked    := FALSE;
  ChBResProv.Checked   := ProvDataExists;
  ChBResLoc.Checked    := LocDataExists;
  ChBResServ.Checked   := ServDataExists;
  ChBResClient.Checked := ClientDataExists;
  ChBResCont.Checked   := ContDataExists;
  ChBResStat.Checked   := StatDataExists;

  BtLoad.Enabled := ChBLoadMedia.Checked  or
                    ChBLoadPat.Checked    or
                    ChBLoadProv.Checked   or
                    ChBLoadLoc.Checked    or
                    ChBLoadServ.Checked   or
                    ChBLoadClient.Checked or
                    ChBLoadCont.Checked   or
                    ChBLoadStat.Checked;
  if  not CorrectPathExists and (AllRootPath <> '') then
    K_CMShowMessageDlg( 'Path ' +  AllRootPath + ' does not contain data to add!!!', mtWarning );

end; // procedure TK_FormCMUTLoadDBData.RebuildPathSettings

procedure TK_FormCMUTLoadDBData.FormShow(Sender: TObject);
begin
  PathChange();

end; // procedure TK_FormCMUTLoadDBData.FormShow

procedure TK_FormCMUTLoadDBData.BtOpenClick(Sender: TObject);
begin
  RebuildPathSettings();

end; // procedure TK_FormCMUTLoadDBData.BtOpenClick

procedure TK_FormCMUTLoadDBData.ChBLoadMediaClick(Sender: TObject);
begin
  ChBResMedia.Checked := ChBLoadMedia.Checked;
  ChBLoadStat.Enabled := ChBLoadMedia.Checked;
  if not ChBLoadMedia.Checked then
    ChBLoadStat.Checked := FALSE;

  ChBResStat.Checked := ChBLoadStat.Checked;

  ChBResPat.Enabled := ChBLoadPat.Checked;
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

procedure TK_FormCMUTLoadDBData.BtLoadClick(Sender: TObject);
var
  ExtFilePat : string;
  ErrRootPath : string;
  ImgRootPath : string;
  VideoRootPath : string;
  Img3DRootPath : string;
  SavedCursor: TCursor;
  TTabName : string;
  FilesPattern : string;
  N, i, j, OldPatID, NewPatID, IProgCur, IProgLast, ICount, VCount, I3Count, SCount : Integer;
  VideoFile, Img3DFile : Boolean;

  CrDT : TDateTime;
  SysInfo, NewLocPath, OldLocPath, SrcBasePath, DstBasePath, SOldID, SNewID,
  OldFName, NewFName, AddNamePat : string;

  ContType, ContID, ContID1, DelCount : Integer;

  procedure DumpLoadInfo( const ATableName : string  );
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
    begin
      SQL.Text := 'select count(*)' + ' from ' + ATableName;
      Open();
      N_Dump1Str( format( 'Table %s, %d records are loaded', [ATableName,Fields[0].AsInteger] ) );
      Close();
    end;
  end;

  function DumpPrepCrossRefs( const ATableName : string  ) : Integer;
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
    begin
      SQL.Text := 'select count(*)' + ' from ' + K_CMENDBImportLinkIDsTable;
      Open();
      Result := Fields[0].AsInteger;
      N_Dump1Str( format( 'Table %s, %d cross refs are build', [ATableName,Result] ) );
      Close();
    end;
  end;

  procedure DumpAddInfo( const ATableName, ATableName1 : string  );
  var
    N1 : Integer;
  begin
    with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
    begin
      SQL.Text := 'select count(*)' + ' from ' + ATableName;
      Open();
      N1 := Fields[0].AsInteger;
      Close();
      SQL.Text := 'select count(*)' + ' from ' + ATableName1;
      Open();
      N_Dump1Str( format( '%d records from %s are added to %s (%d)', [N1,ATableName,ATableName1,Fields[0].AsInteger] ) );
      Close();
    end;
  end;

begin
  with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do
  begin
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;

    Connection := LANDBConnection;

    BtOpen.Enabled := FALSE;
    BtLoad.Enabled := FALSE;

    //  Start procedure

    CommandText := 'DROP VARIABLE IF EXISTS @MinID;'  + #10 +
                   'CREATE VARIABLE @MinID  integer;';
    Execute;

    ////////////////////////////////////
    // Load data to temporary tables
    //
    if ChBLoadMedia.Checked then
    begin

      K_FormCMSupport.ShowInfo( ' Load Media Objects ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      CommandText := 'CREATE LOCAL TEMPORARY TABLE SlidesCopyMoveInfo ' +
                     '(OldID int, NewID int, OldPatID int) NOT TRANSACTIONAL;';
      Execute;

      TTabName := 'Tmp' + K_CMENDBMTypesTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBMTypesTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + DBDataRootPath + K_CMENDBMTypesTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBSlidesTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBSlidesTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + DBDataRootPath + K_CMENDBSlidesTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBDelMarkedSlidesTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBDelMarkedSlidesTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + DBDataRootPath + K_CMENDBDelMarkedSlidesTable + '.dat''' +
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
                     ' FROM ''' + DBDataRootPath + K_CMENDBAllPatientsTable + '.dat''' +
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
                     ' FROM ''' + DBDataRootPath + K_CMENDBAllProvidersTable + '.dat''' +
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
                     ' FROM ''' + DBDataRootPath + K_CMENDBAllLocationsTable + '.dat''' +
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
                     ' FROM ''' + DBDataRootPath + K_CMENDBAllServersTable + '.dat''' +
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
                     ' FROM ''' + DBDataRootPath + K_CMENDBGAInstsTable + '.dat''' +
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
                     ' FROM ''' + DBDataRootPath + K_CMENDBContextsTable + '.dat''' +
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
                     ' FROM ''' + DBDataRootPath + K_CMENDBSlidesHistTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBSlidesNewHistTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBSlidesNewHistTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + DBDataRootPath + K_CMENDBSlidesNewHistTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBSessionsHistTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBSessionsHistTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + DBDataRootPath + K_CMENDBSessionsHistTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBAllHistPatientsTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBAllHistPatientsTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + DBDataRootPath + K_CMENDBAllHistPatientsTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBAllHistProvidersTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBAllHistProvidersTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + DBDataRootPath + K_CMENDBAllHistProvidersTable + '.dat''' +
                     ' FORMAT BCP;';
      Execute;
      DumpLoadInfo( TTabName );
      Application.ProcessMessages;

      TTabName := 'Tmp' + K_CMENDBAllHistLocationsTable;
      CommandText := 'DROP TABLE IF EXISTS ' + TTabName + ';' + #10 +
                     'SELECT * INTO ' + TTabName +
                     ' FROM ' + K_CMENDBAllHistLocationsTable + ' WHERE 1=0;' + #10 +
                     'LOAD TABLE ' + TTabName +
                     ' FROM ''' + DBDataRootPath + K_CMENDBAllHistLocationsTable + '.dat''' +
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
        TTabName := 'Tmp' + K_CMENDBSlidesTable;
        CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Get Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDBSTFSlideID  + ', 0 ' +
                       ' FROM ' + TTabName + ';' + #10 +

                       // Set new IDs to CrossRefs Table
                       'SELECT MAX(' + K_CMENDBSTFSlideID + ') INTO @MinID FROM ' + K_CMENDBSlidesTable + ';' + #10 +
                       'SET @MinID = @MinID + 1;' + #10 +

                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = @MinID, @MinID = @MinID + 1;' + #10 +

                       // Prepare Copy Files Info
                       'INSERT SlidesCopyMoveInfo (OldID, NewID, OldPatID)' +
                       ' SELECT ' + K_CMENDILIOldID + ', ' + K_CMENDILINewID + ', 0' +
                       ' FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
{
                       // Prepare Copy Files Info
                       // Set Old Slide ID and New Slide ID
                       'UPDATE SlidesCopyMoveInfo (OldID, NewID )' +
                       ' SELECT ' + K_CMENDILIOldID + ', ' + K_CMENDILINewID +
                       ' FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
}
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

    if ChBLoadPat.Checked then
    begin
      if ChBResPat.Checked then
      begin
        K_FormCMSupport.ShowInfo( ' Resolve Patients Collisions ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
        TTabName := 'Tmp' + K_CMENDBAllPatientsTable;
        CommandText := 'DELETE FROM ' + K_CMENDBImportLinkIDsTable + ';' + #10 +
                       // Get Old IDs to CrossRefs Table
                       'INSERT ' + K_CMENDBImportLinkIDsTable +
                       ' (' + K_CMENDILIOldID + ',' + K_CMENDILINewID + ')' +
                       ' SELECT ' + K_CMENDAPBridgeID + ', 0' +
                       ' FROM ' + TTabName + ';' + #10 +

                       // Set new IDs to CrossRefs Table for Identic objects
                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = A.' + K_CMENDAPBridgeID +
                       ' FROM ' + K_CMENDBAllPatientsTable + ' A' +
                       ' JOIN ' + TTabName  + ' P ON' +
                       ' A.' + K_CMENDAPSurname + ' = P.' + K_CMENDAPSurname + ' AND ' +
                       ' A.' + K_CMENDAPFirstname + ' = P.' + K_CMENDAPFirstname + ' AND ' +
                       ' A.' + K_CMENDAPDOB + ' = P.' + K_CMENDAPDOB +
                       ' WHERE ' + K_CMENDILIOldID + '= P.' + K_CMENDAPBridgeID + ';' + #10 +

                       // Set new IDs to CrossRefs Table for not Identic objects
                       'SELECT MAX(' + K_CMENDAPID + ') INTO @MinID FROM ' + K_CMENDBAllPatientsTable + ';' + #10 +
                       'SET @MinID = @MinID + 1;' + #10 +

                       'UPDATE ' + K_CMENDBImportLinkIDsTable +
                       ' SET '  +  K_CMENDILINewID + ' = -100 - @MinID, @MinID = @MinID + 1' +
                       ' FROM (SELECT ' + K_CMENDAPBridgeID + ' FROM ' + TTabName +
                              ' WHERE NOT EXISTS (SELECT 1 ' + K_CMENDAPBridgeID +
                                                 ' FROM ' + K_CMENDBAllPatientsTable  +
                                                 ' WHERE ' +
                       K_CMENDBAllPatientsTable + '.' + K_CMENDAPSurname + ' = ' + TTabName + '.' + K_CMENDAPSurname + ' AND ' +
                       K_CMENDBAllPatientsTable + '.' + K_CMENDAPFirstname + ' = ' + TTabName + '.' + K_CMENDAPFirstname + ' AND ' +
                       K_CMENDBAllPatientsTable + '.' + K_CMENDAPDOB + ' = ' + TTabName + '.' + K_CMENDAPDOB + ')) P' +
                       ' WHERE ' +  K_CMENDILIOldID + '= P.' + K_CMENDAPBridgeID + ';' + #10 +

                       // Delete Identic CrossRefs
                       'DELETE FROM ' + K_CMENDBImportLinkIDsTable +
                       ' WHERE ' + K_CMENDILIOldID + ' = ' + K_CMENDILINewID + ';';
        Execute;
        Application.ProcessMessages;

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
' TO ''' + DBDataRootPath + TTabName + 'LinkIDs1.dat''' +
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
' TO ''' + DBDataRootPath + TTabName + 'LinkIDs2.dat''' +
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
' TO ''' + DBDataRootPath + TTabName + '1.dat''' +
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
' TO ''' + DBDataRootPath + TTabName + '3.dat''' +
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
//' TO ''' + DBDataRootPath + TTabName + 'LD1.dat''' +
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
//' TO ''' + DBDataRootPath + TTabName + 'LD2.dat''' +
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
//' TO ''' + DBDataRootPath + TTabName + 'LD3.dat''' +
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
//' TO ''' + DBDataRootPath + TTabName + 'LD4.dat''' +
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
' TO ''' + DBDataRootPath + TTabName + '1.dat''' +
' FORMAT BCP;';
          Execute;

          CommandText :=
'UNLOAD TABLE ' + TTabName +
' TO ''' + DBDataRootPath + TTabName + '2.dat''' +
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
' TO ''' + DBDataRootPath + TTabName + '3.dat''' +
' FORMAT BCP;';
          Execute;

          CommandText :=
'UNLOAD TABLE ' + TTabName +
' TO ''' + DBDataRootPath + TTabName + '4.dat''' +
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
' TO ''' + DBDataRootPath + TTabName + '5.dat''' +
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
    begin

      K_FormCMSupport.ShowInfo( ' Add Media Objects ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

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

{}
          CommandText :=
'UNLOAD TABLE ' + K_CMENDBContextsTable +
' TO ''' + DBDataRootPath + TTabName + '6.dat''' +
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

    //
    // Add data to DB
    ////////////////////////////////////

    //////////////////////////////////////
    // Copy Media Files
    //
    if ChBLoadMedia.Checked then
    begin

      K_FormCMSupport.ShowInfo( ' Copy Image, Video and 3D Files ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

      ImgRootPath := AllRootPath + 'Img\';
      if not DirectoryExists( ImgRootPath ) then
        ImgRootPath := '';

      VideoRootPath := AllRootPath + 'Video\';
      if not DirectoryExists( VideoRootPath ) then
        VideoRootPath := '';

      Img3DRootPath := AllRootPath + K_Img3DFolder;
      if not DirectoryExists( Img3DRootPath ) then
        Img3DRootPath := '';

      with CurDSet2 do
      begin
        Connection := LANDBConnection;
           //                 0       1          2                      3
        SQL.Text := 'SELECT A.OldID, A.NewID, A.OldPatID, P.' + K_CMENDBSTFPatID +
           //           4                                  5
           ', P.' + K_CMENDBSTFSlideDTCr + ', P.' + K_CMENDBSTFSlideSysInfo +
           ' FROM SlidesCopyMoveInfo A JOIN Tmp' + K_CMENDBSlidesTable +
           ' P ON A.NewID = P.' + K_CMENDBSTFSlideID + ';';
        Filtered := FALSE;
        Open();
        N := RecordCount;
        First();
        IProgLast := 0;
        ICount := 0;
        VCount := 0;
        I3Count := 0;
        SCount := 0;
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
            ErrRootPath := AllRootPath + K_VideoFolder;
          end
          else                                  //
          if Img3DFile then
          begin
// Error!!!            if Pos( 'Capt3DDevObjName', SysInfo ) > 0 then
// 2020-07-28 add Capt3DDevObjName <> '' if Pos( 'Capt3DDevObjName', SysInfo ) > 0 then
// 2020-09-25 add new condition for Dev3D objs
            if (Pos( 'Capt3DDevObjName', SysInfo ) = 0) or (Pos( 'MediaFExt', SysInfo ) = 0) then
            begin
              DstBasePath := SlidesImg3DRootFolder;
              SrcBasePath := ImgRootPath;
              ErrRootPath := AllRootPath + K_Img3DFolder;
            end
            else
            begin
              Next();
              Continue;
            end;
          end
          else
          begin
            DstBasePath := SlidesImgRootFolder;
            SrcBasePath := ImgRootPath;
            ErrRootPath := AllRootPath + K_ImgFolder;
            AddNamePat := '*';
          end;

          if SrcBasePath = '' then
          begin
            K_CMShowMessageDlg( 'Path ' +  ErrRootPath + ' is absent!!!'#13#10+
                                '           Files are not copied!!!'#13#10+
                                '     Please click OK to finish the action', mtError );
            Break;
          end;

          TmpStrings.Clear;
          FilesPattern := '?F_' + K_CMSlideGetFileIDPathSegm( SOldID ) +
                           AddNamePat + '.*';
          K_ScanFilesTree( SrcBasePath + OldLocPath, EDASelectDataFiles,
                           FilesPattern, Img3DFile );
          DstBasePath := DstBasePath + NewLocPath;
          if TmpStrings.Count > 0 then
            for j := 0 to TmpStrings.Count - 1 do
            begin
              OldFName := ExtractFileName( TmpStrings[j] );
              //                         File Name Start Chars    New ID   File Extension
              NewFName := DstBasePath +  Copy( OldFName, 1, 3 ) + SNewID + Copy( OldFName, 12, 8 );

              N_Dump2Str( format('Copy %s >> %s',[TmpStrings[j],NewFName]) );
              if OldFName[1] <> '3' then
              begin // Atrs File(for Image, Video and 3D), Image, Video, Study
                K_CopyFile( TmpStrings[j], NewFName );
  //              K_CopyFile( TmpStrings[j], DstBasePath + NewFName );
                if OldFName[1] <> 'A' then
                begin // Image, Video, Study (studies are count as Image)
                  if VideoFile then
                    Inc(VCount)
                  else
                  if OldFName[1] <> 'S' then
                    Inc(ICount)
                  else
                    Inc(SCount);
                end;
              end   // if OldFName[1] <> '3' then
              else
              begin // if OldFName[1] = '3' then  // 3D Image Folder
                K_CopyFolderFiles( IncludeTrailingPathDelimiter(TmpStrings[j]),
                                   IncludeTrailingPathDelimiter(NewFName) );
  //                                 IncludeTrailingPathDelimiter(DstBasePath + NewFName) );
                Inc(I3Count)
              end;
            end // for j := 0 to TmpStrings.Count - 1 do
          else
            N_Dump1Str( format( 'Files %s are not found',[SrcBasePath + OldLocPath + FilesPattern]) );

          Application.ProcessMessages;

          // Show Progress
          IProgCur := Round(100 * (i + 1) / N);
          if IProgCur > IProgLast then
          begin
            K_FormCMSupport.ShowInfo( format( ' %d%% objects are processed ', [IProgCur]) );
            IProgLast := IProgCur;
          end;

          Next();
        end; // for i := 0 to N - 1 do

        Close();
      end; // with CurDSet2 do
      K_FormCMSupport.ShowInfo( format( ' %d Image, %d Video, %d 3D objects and %d studies files for %d Media Objects are copied ',
                                        [ICount, VCount, I3Count, SCount, N]), 'TK_FormCMUTLoadDBData.BtLoadClick >>' );

    end; // if ChBLoadMedia.Checked then
    //
    // Copy Media Files
    ////////////////////////////////////

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
                   'DROP TABLE IF EXISTS SlidesCopyMoveInfo;';
    Execute;

    Screen.Cursor := SavedCursor;
    BtOpen.Enabled := TRUE;
    BtLoad.Enabled := TRUE;

    K_FormCMSupport.ShowInfo( ' All is done ', 'TK_FormCMUTLoadDBData.BtLoadClick >>' );
    Screen.Cursor := SavedCursor;
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurSQLCommand1 do


end; // procedure TK_FormCMUTLoadDBData.BtLoadClick

procedure TK_FormCMUTLoadDBData.CurStateToMemIni;
begin
  inherited;
  N_ComboBoxToMemIni( 'CMSLoadDBDataPathsHistory', PathNameFrame.mbPathName );
end; // procedure TK_FormCMUTLoadDBData.CurStateToMemIni

procedure TK_FormCMUTLoadDBData.MemIniToCurState;
begin
  inherited;
  N_MemIniToComboBox( 'CMSLoadDBDataPathsHistory', PathNameFrame.mbPathName );
  PathNameFrame.AddNameToTop( PathNameFrame.mbPathName.Text );

end; // procedure TK_FormCMUTLoadDBData.MemIniToCurState

end.
