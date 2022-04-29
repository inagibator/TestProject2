unit K_FCMSupport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls,
  N_Gra0, N_Gra1, N_BaseF,
  K_CM0;

type
  TK_FormCMSupport = class(TN_BaseForm)
    GBInfo: TGroupBox;
    MemInfo: TMemo;
    GBUtils: TGroupBox;
    BtDBRecovery: TButton;
    BtSysInfo: TButton;
    StatusBar: TStatusBar;
    Timer: TTimer;
    BtImportChngAttrs: TButton;
    BtCheckFileSize: TButton;
    BtCopyFiles: TButton;
    BtClearFiles: TButton;
    BtChangePPLIDs: TButton;
    BtUloadDBData: TButton;
    BtLoadDBData: TButton;
    BtRepairImageSize: TButton;
    BtDeleteSlides: TButton;
    BtFSAnalysis: TButton;
    BtFSClear: TButton;
    BtFSDump: TButton;
    BtPrepDBData: TButton;
    BtHCFOldFilesList: TButton;
    BtHCFRenameFiles: TButton;
    Button1: TButton;
    BtSetDBContexts: TButton;
    BtPrepDBData1: TButton;
    BtLoadDBData3: TButton;
    BtFSCopy: TButton;
    BtImportExpToDCM: TButton;
    BtFSACopy: TButton;
    btnAnonymizeDB: TButton;
    btnConvertFromD4W: TButton;
    BtExportAll: TButton;
    procedure FormShow(Sender: TObject);
    procedure BtSysInfoClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure BtDBRecoveryClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCanResize( Sender: TObject; var NewWidth,
                               NewHeight: Integer; var Resize: Boolean);
    procedure BtImportChngAttrsClick(Sender: TObject);
    procedure BtCopyFilesClick(Sender: TObject);
    procedure BtClearFilesClick(Sender: TObject);
    procedure BtChangePPLIDsClick(Sender: TObject);
    procedure BtUloadDBDataClick(Sender: TObject);
    procedure BtLoadDBDataClick(Sender: TObject);
    procedure BtDeleteSlidesClick(Sender: TObject);
    procedure BtFSAnalysisClick(Sender: TObject);
    procedure BtFSClearClick(Sender: TObject);
    procedure BtFSDumpClick(Sender: TObject);
    procedure BtPrepDBDataClick(Sender: TObject);
    procedure BtPrepDBData1Click(Sender: TObject);
    procedure BtHCFRenameFilesClick(Sender: TObject);
    procedure BtHCFOldFilesListClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BtSetDBContextsClick(Sender: TObject);
    procedure BtLoadDBData3Click(Sender: TObject);
    procedure BtFSCopyClick(Sender: TObject);
    procedure BtFSACopyClick(Sender: TObject);
    procedure BtImportExpToDCMClick(Sender: TObject);
    procedure btnAnonymizeDBClick(Sender: TObject);
    procedure btnConvertFromD4WClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SavedCursor: TCursor;
    InfoStatusBar: TStatusBar;
    procedure OnUHException    ( Sender: TObject; E: Exception );
    procedure RebuildDBInfo    ();
    procedure ShowInfo( const AInfo : string; const ADumpPrefix: string = '' );
    function  CheckSingleMediaSuitRunning( ) : Boolean;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMSupport: TK_FormCMSupport;


implementation

{$R *.dfm}

uses
  K_FCMGAdmEnter, K_FCMSysInfo, K_UDC, {K_FCMDBRecovery}K_CMUtils, K_Arch, K_UDT1, K_CLib0,
  K_FCMImportChngAttrs, K_CLib, K_CML1F, K_CML3F, K_FCMUTSyncPPL, K_FCMUTUnloadDBData,
  {K_FCMUTLoadDBData1,} K_FCMUTLoadDBData2, K_FCMUTLoadDBData3, K_FCMUTPrepDBData, K_FCMUTPrepDBData1,
  K_FCMIntegrityCheck, K_FCMUTSetDBContexts, K_FCMFSCopy, K_FCMFSACopy, K_FCMImportExpToDCM,
  N_Types, N_Lib0, N_Lib1, {N_CMResF,} N_CM1, N_CMMain5F, N_ME1,
  N_CMResF, N_CML1F, N_CML2F, A_DBAnonymizer, A_DBAnonymizerSettings, A_fConvertFromD4W;


//******************************************** TK_FormCMSupport.FormShow ***
// Form Show Handler
//
procedure TK_FormCMSupport.FormShow(Sender: TObject);
begin
  InfoStatusBar := StatusBar;
  N_InitWAR(); // Initialize N_WholeWAR and N_AppWAR using [Global]ScreenWorkArea in Ini file
  if N_MonWARsChanged() then N_ClearSavedFormCoords(); // clear N_Forms section if needed

  N_AddDirToPATHVar( K_ExpandFileName( '(#DLLFiles#)' ) );

//  BaseFormInit( nil, '', [] );
  BaseFormInit( nil, '', [rspfPrimMonWAR,rspfCenter], [rspfPrimMonWAR,rspfCenter] );

  Timer.Enabled := TRUE;
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  BtCopyFiles.Visible := N_CMSVersion = '03.044.77';
  BtClearFiles.Visible := BtCopyFiles.Visible;
end; // procedure TK_FormCMSupport.FormShow

//******************************************** TK_FormCMSupport.FormCloseQuery ***
// Form Close Query Handler
//
procedure TK_FormCMSupport.FormCloseQuery( Sender: TObject;
  var CanClose: Boolean );
begin
  if K_CMEDAccess <> nil then
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      EDAClearGAMode();
      EDAGlobalCurStateToMemIni();
      EDAInstanceCurStateToMemIni();
      Free;
    end;
end; // procedure TK_FormCMSupport.FormCloseQuery

//******************************************** TK_FormCMSupport.FormDestroy ***
// Form Destroy Handler
//
procedure TK_FormCMSupport.FormDestroy(Sender: TObject);
begin
  K_SaveMemIniToFile(N_CurMemIni);
end; // procedure TK_FormCMSupport.FormDestroy

//***************************************** TK_FormCMSupport.BtSysInfoClick ***
// Button BtSysInfo Click Handler
//
procedure TK_FormCMSupport.BtSysInfoClick(Sender: TObject);
begin
  with TK_FormCMSysInfo.Create( Application) do
  begin
//    BaseFormInit(nil);
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal();
  end;

end; // TK_FormCMSupport.BtSysInfoClick

//****************************************** TK_FormCMSupport.OnUHException ***
// On Appliction Unhadled Exception Handler
//
procedure TK_FormCMSupport.OnUHException( Sender: TObject; E: Exception );
var
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

    K_CMShowMessageDlg( K_CML1Form.LLLSupport2.Caption +
//      ' The Software Support terminated by exception:' +
         #13#10 + E.Message, mtError, [], false,
        K_CML1Form.LLLSupport1.Caption ); //'Media Suite Support' );
    N_Dump1Str( 'Application CMSupport.UHException FlushCounters' + N_GetFlushCountersStr() );
    N_LCExecAction( -1, lcaFlush );

    K_CMEDAccess.Free;
  finally
    ExitProcess( 10 );
  end;
end; // end of procedure TK_FormCMSupport.OnUHException


//******************************************** TK_FormCMSupport.BtDBRecoveryClick ***
// Button BtDBRecovery Click Handler
//
procedure TK_FormCMSupport.BtDBRecoveryClick(Sender: TObject);
begin
  if K_CMDBRecoveryDlg() then RebuildDBInfo();
{
  if K_CMSDBRecoveryMode or K_CMAllPatObjCopyMoveResumeAndWait( 0 ) then
    with TK_FormCMDBRecovery.Create( Application ) do
    begin
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
      ShowModal;
      RebuildDBInfo();
    end;
}
end; // TK_FormCMSupport.BtDBRecoveryClick

//******************************************** TK_FormCMSupport.TimerTimer ***
// Timer Timer Handler
//
procedure TK_FormCMSupport.TimerTimer(Sender: TObject);
var
  DlgType : TMsgDlgType;
  WStr : string;
begin
  N_Dump1Str( 'CMSupport >> Timer start' );

  Timer.Enabled := FALSE;

  if not K_CMEnterConfirmDlg( '', '', K_CMDesignModeFlag,
//                N_MemIniToString('CMS_Main', 'EGALogin', ''),
//                N_MemIniToString('CMS_Main', 'EGAPassword', ''),
                'The Software Support',
                'Wrong user name or password. Press OK to close the software' ) then
  begin
    Close();
    Release();
    Exit;
  end;

  ShowInfo( ' Centaur Media Suite Support is connecting to DB. Please wait ... ' );
  Self.Refresh();

  Application.CreateForm( TN_CMMain5Form1, N_CM_MainForm);
  N_CM_MainForm.CMMCurFStatusBar := StatusBar;

//  Application.CreateForm(TN_CMResForm, N_CMResForm);

  K_SetFFCompCurLangTexts( N_CMResForm );

  Application.CreateForm(TK_CML1Form, K_CML1Form);
  K_SetFFCompCurLangTexts( K_CML1Form );
  K_PrepLLLCompTexts( K_CML1Form );

  Application.CreateForm(TK_CML3Form, K_CML3Form);
  K_SetFFCompCurLangTexts( K_CML3Form );
  K_PrepLLLCompTexts( K_CML3Form );
  K_CMHistoryEventsInit();

  Application.CreateForm(TN_CML2Form, N_CML2Form);
  K_SetFFCompCurLangTexts( N_CML2Form );
  K_PrepLLLCompTexts( N_CML2Form );


  WStr := N_MemIniToString( 'CMS_Main', 'StartArchive', '');
  WStr := K_ExpandFileName( WStr );
  if not K_OpenCurArchive( WStr ) then
  begin
    K_CMShowMessageDlg( //sysout
      'Fail to load archive ' + WStr, mtError, [], false, 'Media Suite Support' );
    Close();
    Release();
    Exit;
  end;
  K_InitAppArchProc := nil;
  K_InitArchiveGCont( K_CurArchive ); // create all needed objects in K_CurArchive
  N_InitVREArchive( K_CurArchive ); // VRE specific initialization
  N_InitCMSArchive( K_CurArchive ); // CMS specific initialization


  K_CMEDAccess := TK_CMEDDBAccess.Create;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin

    // save old 'ExtProperties' - part of connection string
    WStr := N_MemIniToString( 'CMSDB', 'ExtProperties', '' );
    // set new 'ExtProperties' - part of connection string
    N_StringToMemIni( 'CMSDB', 'ExtProperties', 'UID=secadm;PWD=version6:password;DSN=CMSImg' );

    LANDBConnection.ConnectionString := K_CMDBGetConnectionString();
    N_Dump1Str( 'Before connect to DB as secadm' );
    LANDBConnection.Open();
    N_Dump2Str( 'After connect to DB as secadm' );

    with CurSQLCommand1 do
    begin
      Connection := LANDBConnection;
//All these are needed fore ASA12: GRANT LOAD ANY TABLE is actual in ASA16
if not K_CMDesignModeFlag then
begin
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
{}
//      CommandText := 'GRANT LOAD ANY TABLE TO "dba";';
      CommandText := 'GRANT LOAD ANY TABLE TO "dba";' + #10 +
                     'GRANT SELECT ANY TABLE TO "dba";';
      N_Dump2Str( 'Before : "' + CommandText + '"' );
      Execute;
      N_Dump2Str( 'After : "' + CommandText + '"' );
{}
{$IFEND CompilerVersion >= 26.0}
end; // if not K_CMDesignModeFlag then
    end;

    // return saveed 'ExtProperties' - part of connection string
    N_StringToMemIni('CMSDB', 'ExtProperties', WStr);

    N_Dump2Str( 'Before secadm connection close' );
    LANDBConnection.Close();
    N_Dump1Str( 'After secadm connection close' );


//    AppLocalID := K_CMFilesSyncProcAppLocalID;
    N_BoolToMemIni( 'CMS_Main', 'OpenAllDBVer', TRUE); // skip DB Version check in DebugMode
    if (EDAInit() <> K_edOK) or
       (EDAGetSlidesFPathContext() <> K_edOK)  then
    begin
      DlgType := mtWarning;
      if K_CMSAppStartContext.CMASState = K_cmasStop then
      begin
        DlgType := mtError;
      end;
      if K_CMSLiRegWarning = '' then
        K_CMSLiRegWarning := 'Unknown Media Suite Database connetion error';
      K_CMShowMessageDlg( K_CMSLiRegWarning, DlgType, [], false, 'Media Suite Support' );
      Close();
      Release();
      Exit;
    end; // if (EDAInit() <> K_edOK) ...

    if K_CMEnterpriseModeFlag then
    begin
      K_CMShowMessageDlg( //sysout
        'Media Suite Support shouldn''t be run in DB Enterprise mode',
        mtError, [], false, K_CML1Form.LLLSupport1.Caption ); //'Media Suite Support' );
      Close();
      Release();
      Exit;
    end;

    EDAGlobalMemIniToCurState();
    EDAInstanceMemIniToCurState();

    if K_CMDBCurCodePage >= 0 then
    begin

    end;
    RebuildDBInfo();

    K_CMGAModeFlag := EDALockUnlockActMode( [K_iafEGAMode], 1 ) = K_edOK;
    if not K_CMGAModeFlag then
    begin
      K_CMShowMessageDlg( //sysout
        'Global administrator mode was not set', mtError, [], false, 'Media Suite Support' );
      Close();
      Release();
      Exit;
    end;
    K_CMDCMUIDPrefix := CentaurSoftwareUID + '.' + K_GetDICOMUIDComponentFromGUID31( K_CMEDAccess.EDAGetDBUID() );

  end; // with TK_CMEDDBAccess(K_CMEDAccess) do

  K_CMSRebuildCommonRImage();

  Screen.Cursor := SavedCursor;
  N_Dump1Str( 'CMSupport >> Timer fin' );
  ShowInfo( '' );

  ////////////////////////////////////
  // Free Main Memory after Application
  // initialization is finished
  //
  if K_CMSReservedSpaceHMem <> 0 then
  begin
    N_Dump1Str( 'MemFreeSpace reserved free' );
    Windows.GlobalFree( K_CMSReservedSpaceHMem );
    K_CMSReservedSpaceHMem := 0;
  end;
  K_GetFreeSpaceProfile();
  N_Dump1Str( '!!!MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr('; ', '%.0n') );
//  N_Dump1Str( 'MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr() );
  //
  ///////////////////////////////////

//  StatusBar.SimpleText := ''
end; // TK_FormCMSupport.TimerTimer

//******************************************** TK_FormCMSupport.RebuildDBInfo ***
// Rebuild DB Info
//
procedure TK_FormCMSupport.RebuildDBInfo;
var
  AllSlidesCount : Integer;
  SPayedBuild : string;
begin
  AllSlidesCount := 0;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    with CurDSet1 do
    begin
      try
        ExtDataErrorCode := K_eeDBSelect;
        Connection := LANDBConnection;
       //////////////////////////////////////
       // Get DB Slides Count
       //
        Filtered := FALSE;
        SQL.Text := 'select Count(*) from ' + K_CMENDBSlidesTable;
        Open;
        AllSlidesCount := FieldList[0].AsInteger;
        Close;
      except
        on E: Exception do
        begin
          ExtDataErrorString := 'TK_FormCMSupport.RebuildDBInfo ' + E.Message;
          EDAShowErrMessage(TRUE);
        end;
      end;
    end;
    SPayedBuild := 'Trial';
    if K_CMSLiRegState = K_lrsOK then
      SPayedBuild := K_CMSLiRegBuildInfo;

    MemInfo.Lines.Text :=
      format(
      'The Software Support Build %s, Release date %s'#13#10 +
      'CMS payed buid %s, DB MediaObjects number %d '#13#10 +
      'Image files folder %s '#13#10 +
      'Video files folder %s '#13#10 +
      '3D    files folder %s '#13#10 +
      '', [N_CMSVersion, N_CMSReleaseDate,
           SPayedBuild, AllSlidesCount,
           SlidesImgRootFolder, SlidesMediaRootFolder,
           SlidesImg3DRootFolder] );
  end;

end; // procedure TK_FormCMSupport.RebuildDBInfo

procedure TK_FormCMSupport.ShowInfo( const AInfo: string; const ADumpPrefix: string = '' );
begin
  InfoStatusBar.SimpleText := AInfo;
  if (ADumpPrefix <> '') and (AInfo <> '') then
    N_Dump1Str( ADumpPrefix + AInfo )
end; // procedure TK_FormCMSupport.ShowInfo

function TK_FormCMSupport.CheckSingleMediaSuitRunning( ) : Boolean;
var i : Integer;
begin
  with TK_CMEDDBAccess(K_CMEDAccess).CurDSet1 do
  begin // Check if single CMSupport is working
    SQL.Text := 'select count(*) from ' + K_CMENDBAAInstsTable;
    Open();

    i := Fields[0].AsInteger;
    Close();
    Result := i = 1;
    if not Result  then
    begin
      K_CMShowMessageDlg( '         Some Media Suite applications are running now.'#13#10+
                          'To do this action single Media Suite Support should be running'#13#10+
                          '         Please click OK and finish the action if needed', mtError );
      Exit;
    end;
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do
end; // procedure TK_FormCMSupport.CheckSingleMediaSuitRunning

//***************************************** TK_FormCMSupport.CurStateToMemIni ***
// Save Current Self State
//
procedure TK_FormCMSupport.CurStateToMemIni();
begin
  Inherited;

  N_StringToMemIni( 'N_Forms', 'AllMonWARs', N_GetMonWARsAsString() ); // save monitors WARs
end; // end of procedure TK_FormCMSupport.CurStateToMemIni

//***************************************** TK_FormCMSupport.MemIniToCurState ***
// Load Current Self State
//
procedure TK_FormCMSupport.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TK_FormCMSupport.MemIniToCurState

procedure TK_FormCMSupport.FormCanResize( Sender: TObject; var NewWidth,
                                          NewHeight: Integer; var Resize: Boolean);
begin
  N_ProcessMainFormMove( N_GetScreenRectOfControl( Self ) );
end; // procedure TK_FormCMSupport.FormCanResize

procedure TK_FormCMSupport.BtImportChngAttrsClick(Sender: TObject);
begin
  K_CMSlideImportChangeAttrsDlg( );
end; // procedure TK_FormCMSupport.BtImportChngAttrsClick

procedure TK_FormCMSupport.BtCopyFilesClick(Sender: TObject);
begin
  K_CMFSRecovery2Dlg();
end; // procedure TK_FormCMSupport.BtCopyFilesClick

procedure TK_FormCMSupport.BtClearFilesClick(Sender: TObject);
begin
  ShowInfo( ' Please wait ... ' );
//  StatusBar.SimpleText := ' Please wait ... ';
  N_Dump1Str( 'CMSupport >> ClearFiles start' );
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  K_DeleteFolderFiles( TK_CMEDDBAccess(K_CMEDAccess).SlidesImgRootFolder,
                       'AF_????????.cma' );
  Screen.Cursor := SavedCursor;
  N_Dump1Str( 'CMSupport >> ClearFiles fin' );
//  StatusBar.SimpleText := ' All done ';
  ShowInfo( ' All done ' );
end; // procedure TK_FormCMSupport.BtClearFilesClick

procedure TK_FormCMSupport.BtChangePPLIDsClick(Sender: TObject);
begin
  if not CheckSingleMediaSuitRunning( ) then Exit;
  K_CMUTSyncPPLDlg( );
end; // procedure TK_FormCMSupport.BtChangePPLIDsClick


procedure TK_FormCMSupport.BtUloadDBDataClick(Sender: TObject);
begin
  if not CheckSingleMediaSuitRunning( ) then Exit;
  K_CMUTUnloadDBDataDlg();
end; // procedure TK_FormCMSupport.BtUloadDBDataClick

procedure TK_FormCMSupport.BtLoadDBDataClick(Sender: TObject);
begin
  K_CMUTLoadDBData2Dlg();
//  if not CheckSingleMediaSuitRunning( ) then Exit;
//  K_CMUTLoadDBData1Dlg();
end; // procedure TK_FormCMSupport.BtLoadDBDataClick

procedure TK_FormCMSupport.BtDeleteSlidesClick(Sender: TObject);
begin
  K_CMDeleteSlidesDlg();
end; // procedure TK_FormCMSupport.BtDeleteSlidesClick

procedure TK_FormCMSupport.BtFSAnalysisClick(Sender: TObject);
begin
  K_CMFSAnalysisDlg();
end; // procedure TK_FormCMSupport.BtFSAnalysisClick

procedure TK_FormCMSupport.BtFSClearClick(Sender: TObject);
begin
  K_CMFSClearDlg();
end; // procedure TK_FormCMSupport.BtFSClearClick

procedure TK_FormCMSupport.BtFSDumpClick(Sender: TObject);
begin
  K_CMFSDumpDlg();
end; // procedure TK_FormCMSupport.BtFSDumpClick

procedure TK_FormCMSupport.BtPrepDBDataClick(Sender: TObject);
begin
  if not CheckSingleMediaSuitRunning( ) then Exit;
  K_CMUTPrepDBDataDlg();
end; // procedure TK_FormCMSupport.BtPrepDBDataClick

procedure TK_FormCMSupport.BtPrepDBData1Click(Sender: TObject);
begin
  if not CheckSingleMediaSuitRunning( ) then Exit;
  K_CMUTPrepDBData1Dlg();
end; // procedure TK_FormCMSupport.BtPrepDBData1Click

procedure TK_FormCMSupport.BtHCFRenameFilesClick(Sender: TObject);
var
  AllCount, ImgCount, FilesCount, CopyRes : Integer;
  DumpObj : TK_DumpObj;
  FCopyFolder, FPathSegm, FNameSrc1, FNameSrc, FNameDest0, FNameDest : string;
  SSlideInd : string;

  procedure CopyAndRename();
  begin
    CopyRes := K_CopyFile( FNameSrc1, FCopyFolder + FNameSrc, [K_cffOverwriteNewer,K_cffOverwriteReadOnly] );
    if CopyRes = 3 then
      DumpObj.DumpStr0( format( '%s%s to %s not found!!!', [SSlideInd, FNameSrc1, FNameDest0] ) )
    else
    if CopyRes > 3 then
      DumpObj.DumpStr0( format( '%s%s to %s could not copy!!!', [SSlideInd, FNameSrc1, FNameDest0] ) )
    else
    begin
      Inc(FilesCount);
      if RenameFile( FNameSrc1, FNameDest ) then
        DumpObj.DumpStr0( format( '%s%s to %s', [SSlideInd, FNameSrc1, FNameDest0] ) )
      else
        DumpObj.DumpStr0( format( '%s%s to %s could not rename!!!', [SSlideInd, FNameSrc1, FNameDest0] ) )
    end;
  end;

begin
//
  DumpObj := nil;
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    ExtDataErrorCode := K_eeDBSelect;
    Connection := LANDBConnection;
    Filtered := FALSE;

    ImgCount := 0;
    FilesCount := 0;
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;
    ShowInfo( ' Start HCF files rename' );
    try
      FNameSrc := ExtractFilePath( ExcludeTrailingPathDelimiter( ExtractFilePath(Application.ExeName) ) ) +
       'DT00022084_ReportFilesRename.txt';
      DumpObj := TK_DumpObj.Create( FNameSrc );
      DumpObj.DumpStr0( 'Slide#      Path     Rename' );
      if FileExists(FNameSrc) then
        K_DeleteFile(FNameSrc);

//      SQL.Text := 'select SlideID_new, PatID, DTCr, SlideID from AllSlides order by PatID, DTCr, SlideID asc'; // deb Back Rename
//      SQL.Text := 'select SlideID, PatID, DTCr, SlideID_new from AllSlides order by PatID, DTCr, SlideID asc'; // deb Rename
      SQL.Text := 'select SlideID, PatID, DTCr, SlideID_new from AllSlides2 order by PatID, DTCr, SlideID asc'; // Real Rename
      Open;
      AllCount := RecordCount;
      First;
      FCopyFolder := ExtractFilePath( ExcludeTrailingPathDelimiter(SlidesImgRootFolder) ) + 'Img_old\';
      while not EOF do
      begin
        Inc(ImgCount);
        SSlideInd  := format( '%.4d> ', [ImgCount] );
        FPathSegm := K_CMSlideGetPatientFilesPathSegm( Fields[1].AsInteger ) +
                     K_CMSlideGetFileDatePathSegm( Fields[2].AsDateTime );
        FNameSrc   := FPathSegm + K_CMSlideGetCurImgFileName( Fields[0].AsString );
        FNameSrc1  := SlidesImgRootFolder + FNameSrc;
        FNameDest0 := K_CMSlideGetCurImgFileName( Fields[3].AsString );
        FNameDest  := SlidesImgRootFolder + FPathSegm + FNameDest0;

        CopyAndRename();

        // Try original
        FNameSrc1 := ChangeFileExt(FNameSrc1, 'r.cmi');
        if FileExists(FNameSrc1) then
        begin
          FNameSrc   := ChangeFileExt(FNameSrc, 'r.cmi');
          FNameDest0 := ChangeFileExt(FNameDest0, 'r.cmi');
          FNameDest  := ChangeFileExt(FNameDest, 'r.cmi');
          CopyAndRename();
        end; // if FileExists(FNameSrc1) then

        ShowInfo( format( ' %d%% processed', [Round(100 * ImgCount / AllCount)] ) );

        Next;
      end; // while not EOF do

      Close;
    except
      on E: Exception do
      begin
        K_CMShowMessageDlg( //sysout
        'Something is wrong with AllSlides2 table' + #13#10 + E.Message, mtError );
        ExtDataErrorString := 'BtHCFOldFilesListClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end; // except
    Screen.Cursor := SavedCursor;
    DumpObj.DumpStr0( format( '%d slides, %d files are processed', [ImgCount, FilesCount] ) );
    DumpObj.Free;
    ShowInfo( ' Finish HCF files rename' );
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do

end; // procedure TK_FormCMSupport.BtHCFRenameFilesClick

procedure TK_FormCMSupport.BtHCFOldFilesListClick(Sender: TObject);
var
  AllCount, ImgCount : Integer;
  DumpObj : TK_DumpObj;
  FName : string;
  SSlideInd : string;
begin
//
  DumpObj := nil;
  with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do
  begin
    ExtDataErrorCode := K_eeDBSelect;
    Connection := LANDBConnection;
    Filtered := FALSE;

    ImgCount := 0;
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;

    ShowInfo( ' Start HCF files list' );
    try
      FName := ExtractFilePath( ExcludeTrailingPathDelimiter( ExtractFilePath(Application.ExeName) ) ) +
       'DT00022084_ReportFilesBeforeRename.txt';
      DumpObj := TK_DumpObj.Create( FName );
      DumpObj.DumpStr0( 'Slide#      Path' );
      if FileExists(FName) then
        K_DeleteFile(FName);

//      SQL.Text := 'select SlideID_new, PatID, DTCr from AllSlides order by PatID, DTCr, SlideID asc'; // Deb Back List
//      SQL.Text := 'select SlideID, PatID, DTCr from AllSlides order by PatID, DTCr, SlideID asc'; // Deb List
      SQL.Text := 'select SlideID, PatID, DTCr from AllSlides2 order by PatID, DTCr, SlideID asc'; // Real List
      Open;
      AllCount := RecordCount;
      First;
      while not EOF do
      begin
        Inc(ImgCount);
        FName := SlidesImgRootFolder +
          K_CMSlideGetPatientFilesPathSegm( Fields[1].AsInteger ) +
          K_CMSlideGetFileDatePathSegm( Fields[2].AsDateTime ) +
          K_CMSlideGetCurImgFileName( Fields[0].AsString );
        SSlideInd := format( '%.4d> ', [ImgCount] );
        if FileExists(FName) then
          DumpObj.DumpStr0( SSlideInd + FName )
        else
          DumpObj.DumpStr0( SSlideInd + FName + ' not found!!!' );

        // Try original
        FName := ChangeFileExt(FName, 'r.cmi');
        if FileExists(FName) then
          DumpObj.DumpStr0( SSlideInd + FName );
        ShowInfo( format( ' %d%% processed', [Round(100 * ImgCount / AllCount)] ) );
        Next;
      end; // while not EOF do
      Close;
    except
      on E: Exception do
      begin

        K_CMShowMessageDlg( //sysout
        'Something is wrong with AllSlides2 table' + #13#10 + E.Message, mtError );
        ExtDataErrorString := 'BtHCFOldFilesListClick ' + E.Message;
        EDAShowErrMessage(TRUE);
      end;
    end; // except
    ShowInfo( ' Finish HCF files list' );
    Screen.Cursor := SavedCursor;
    DumpObj.Free;
  end; // with TK_CMEDDBAccess(K_CMEDAccess), CurDSet1 do

end; // procedure TK_FormCMSupport.BtHCFOldFilesListClick

procedure TK_FormCMSupport.Button1Click(Sender: TObject);
begin
    if TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafDBMMode], 1 ) <> K_edOK then
      K_CMShowMessageDlg( K_CML1Form.LLLIntegrityCheck1.Caption,
  //         'Integrity check is now selected by another CMS user.'#13#10 +
  //         '              Please try again later.',
               mtWarning )
    else
    begin // if TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafDBMMode], 1 ) = K_edOK
      with TK_FormCMIntegrityCheck.Create( Application) do
      begin
  //      BaseFormInit(nil);
        BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
        ShowModal();
      end;
      TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafDBMMode], 0 );
    end; // if TK_CMEDDBAccess(K_CMEDAccess).EDALockUnlockActMode( [K_iafDBMMode], 1 ) = K_edOK
end;

procedure TK_FormCMSupport.btnConvertFromD4WClick(Sender: TObject);
var
  ConvertFromD4W: TConvertFromD4W;
begin
  inherited;

  ConvertFromD4W := TConvertFromD4W.Create(Self);

  try
    ConvertFromD4W.ShowModal;
  finally
    FreeAndNil(ConvertFromD4W);
  end;
end;

// procedure TK_FormCMSupport.Button1Click

procedure TK_FormCMSupport.BtSetDBContextsClick(Sender: TObject);
begin
  K_CMSetDBContextsDlg( );
end; // TK_FormCMSupport.BtSetDBContextsClick

procedure TK_FormCMSupport.BtLoadDBData3Click(Sender: TObject);
begin
  K_CMUTLoadDBData3Dlg();

end; // procedure TK_FormCMSupport.BtLoadDBData3Click

procedure TK_FormCMSupport.BtFSCopyClick(Sender: TObject);
begin
  K_CMFSCopyDlg();

end; // procedure TK_FormCMSupport.BtFSCopyClick

procedure TK_FormCMSupport.BtFSACopyClick(Sender: TObject);
begin
  K_CMFSACopyDlg();

end; // procedure TK_FormCMSupport.BtFSCopyClick

procedure TK_FormCMSupport.BtImportExpToDCMClick(Sender: TObject);
begin
  K_CMImportExpToDCMDlg( );
end; // procedure TK_FormCMSupport.BtImportExpToDCMClick

procedure TK_FormCMSupport.btnAnonymizeDBClick(Sender: TObject);
var
  DBAnonymizer: TDBAnonymizer;
begin
  inherited;

  DBAnonymizerSettings := TDBAnonymizerSettings.Create(Self);

  try
    if DBAnonymizerSettings.ShowModal = mrOk then
    begin
      DBAnonymizer := TDBAnonymizer.Create;

      if DBAnonymizerSettings.cbPatients.Checked then
        DBAnonymizer.AnonymizePatients;
      if DBAnonymizerSettings.cbProviders.Checked then
        DBAnonymizer.AnonymizeProviders;
      if DBAnonymizerSettings.cbLocations.Checked then
        DBAnonymizer.AnonymizeLocations;
    end;
  finally
    FreeAndNil(DBAnonymizer);
    FreeAndNil(DBAnonymizerSettings);
  end;
end; // procedure TK_FormCMSupport.btnAnonymizeDBClick

end.
