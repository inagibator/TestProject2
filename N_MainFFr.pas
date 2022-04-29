unit N_MainFFr;
// frame with ActionList, used in Main Application Form
// (other variants of Main Form can be easily constructed, using this frame)

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ActnList, StdCtrls, ComCtrls, ExtCtrls,
  K_UDConst,
  N_Types, N_BaseF, N_Lib0;

type TN_MainFormFrame = class( TFrame ) //*** frame for Main Map Editor Form
    OpenDialog: TOpenDialog;
    MainFormFrameActList: TActionList;
    SaveDialog: TSaveDialog;
    OthSaveCurState: TAction;
    aFileArchNew: TAction;
    aFileArchOpen: TAction;
    aFileArchClose: TAction;
    aFileArchSave: TAction;
    aFileArchSaveAs: TAction;
    aFileArchSelect: TAction;
    aFileNoSaveExit: TAction;
    ToolsDTreeEd: TAction;
    aFormsNVtree: TAction;
    aFormsImport: TAction;
    DebWrk1: TAction;
    DebWrk2: TAction;
    DebWrk3: TAction;
    DebPlatformInfo: TAction;
    DebSpeedTests: TAction;
    ToolsPlainEditor: TAction;
    ToolsRichEditor: TAction;
    DebShowDebForm: TAction;
    ToolsSPLEnv: TAction;
    aFormsExport: TAction;
    aFormsWebBrowser: TAction;
    ToolsCSEditor: TAction;
    ToolsCSSEditor: TAction;
    aFormsParams1: TAction;
    DebCreateRusRaster: TAction;
    ToolsCSProjEditor: TAction;
    aEditGlobalOptions: TAction;
    ViewProtocol: TAction;
    OthRefreshSclonTable: TAction;
    ToolsRunSPLScript: TAction;
    DebQuitOLEServers: TAction;
    DebViewOLEServer: TAction;
    ToolsCDimEditor: TAction;
    ToolsCSDimEditor: TAction;
    ToolsDataBlockEditor: TAction;
    ToolsCSDimRelEditor: TAction;
    DebSetDefCursor: TAction;
    aFormsDebProcs: TAction;
    DebShowTimers: TAction;

    constructor Create ( AOwner: TComponent ); override;

      //************* File actions ****************************
    procedure aFileArchNewExecute     ( Sender: TObject );
    procedure aFileArchOpenExecute    ( Sender: TObject );
    procedure aFileArchSelectExecute  ( Sender: TObject );
    procedure aFileArchCloseExecute   ( Sender: TObject );
    procedure aFileArchSaveExecute    ( Sender: TObject );
    procedure aFileArchSaveAsExecute  ( Sender: TObject );
    procedure aFileNoSaveExitExecute  ( Sender: TObject );

      //************* Not used now File actions ****************
{
    procedure ArchReopenExecute       ( Sender: TObject );
    procedure ArchAddToCurrentExecute ( Sender: TObject );
    procedure ArchSaveAllExecute      ( Sender: TObject );
    procedure ArchReloadAllExecute    ( Sender: TObject );
    procedure ArchEditOptionsExecute  ( Sender: TObject );
    procedure FileExitAskExecute      ( Sender: TObject );
    procedure FileSaveExitExecute     ( Sender: TObject );
}
      //************* Edit actions ****************************
    procedure aEditGlobalOptionsExecute ( Sender: TObject );

      //************* View actions ****************************
    procedure ViewArchAsDTreeExecute ( Sender: TObject );
    procedure ViewProtocolExecute    ( Sender: TObject );

      //************* Forms actions ****************************
    procedure aFormsImportExecute     ( Sender: TObject );
    procedure aFormsExportExecute     ( Sender: TObject );
    procedure aFormsNVtreeExecute     ( Sender: TObject );
    procedure aFormsParams1Execute    ( Sender: TObject );
    procedure aFormsDebProcsExecute   ( Sender: TObject );
    procedure aFormsWebBrowserExecute ( Sender: TObject );
//    procedure FormsMLEditorExecute   ( Sender: TObject );
//    procedure FormsMetafEditorExecute( Sender: TObject );

      //************* Tools actions ****************************
    procedure ToolsDTreeEdExecute      ( Sender: TObject );
    procedure ToolsPlainEditorExecute  ( Sender: TObject );
    procedure ToolsRichEditorExecute   ( Sender: TObject );
    procedure ToolsSPLEnvExecute       ( Sender: TObject );
    procedure ToolsRunSPLScriptExecute ( Sender: TObject );

    procedure ToolsCDimEditorExecute     ( Sender: TObject );
    procedure ToolsCSDimEditorExecute    ( Sender: TObject );
    procedure ToolsCSDimRelEditorExecute ( Sender: TObject );
    procedure ToolsDataBlockEditorExecute( Sender: TObject );

    procedure ToolsCSEditorExecute     ( Sender: TObject );
    procedure ToolsCSSEditorExecute    ( Sender: TObject );
    procedure ToolsCSProjEditorExecute ( Sender: TObject );

      //************* Options actions **************************

      //************* Others actions ***************************
    procedure OthSaveCurStateExecute      ( Sender: TObject );
    procedure OthRefreshSclonTableExecute ( Sender: TObject );

      //************* Debug actions ****************************
    procedure DebPlatformInfoExecute   ( Sender: TObject );
    procedure DebSpeedTestsExecute     ( Sender: TObject );
    procedure DebShowTimersExecute     ( Sender: TObject );
    procedure DebWrk1Execute           ( Sender: TObject );
    procedure DebWrk2Execute           ( Sender: TObject );
    procedure DebWrk3Execute           ( Sender: TObject );
    procedure DebShowDebFormExecute    ( Sender: TObject );
    procedure DebViewOLEServerExecute  ( Sender: TObject );
    procedure DebQuitOLEServersExecute ( Sender: TObject );
    procedure DebSetDefCursorExecute   ( Sender: TObject );

  private
    ArchLoadTimer: TTimer;
  public
    MainForm:       TN_BaseForm;  // Self Owner
    IsMainAppForm:   boolean;     // should be True if MainForm is main Application form
    ArchiveIsReady:  boolean;     // is used in Main Form MemIniToState
    MainStatusBar:   TStatusBar;  // StatusBar in Parent Form
    SavedPBCParams: TN_PBCParams; // Saved ProgressBar Caller Params
    SaveArchFlags: TK_UDTreeLSFlagSet;
    MFPCInd:          integer;     // Main Form Protocol Chanel Index

    procedure InitMainFormFrame     ();
    procedure InitArchive           ( Sender: TObject );
    procedure ShowStringInStatusBar ( AStr: string );
    procedure ShowCaption       ( Astr: string );
    procedure ShowProgress1     ( MessageLine: string; ProgressStep: Integer );
    function  NoCurArchive      (): boolean;
//    function  GetDataPath       (): string;
    function  ChooseNewFileName (): string;
    procedure OpenArchive       ( ArchName: string; ALoadFlags: TK_UDTreeLSFlagSet );
    procedure CurStateToMemIni  ();
    procedure MemIniToCurState  ();
end; // type TN_MainFormFrame = class( TFrame )

var
  N_MainFormFrame: TN_MainFormFrame;

    //*********** Global Procedures  *****************************

implementation

uses math, IniFiles, Variants, ActiveX, ComObj,
  K_FFName, K_UDC, K_Clib0, K_Clib, K_FSDeb, K_Script1, K_IWatch, // K_FDTE,
  K_Arch, K_FDCSpace, K_FDCSSpace, K_FDCSProj, K_FRunSPLScript,
  K_FSFList, K_FSelectUDB, K_FSFCombo, K_FrRaEdit,
  K_FUDCDim, K_FUDCSDim, K_FUDCDCor, K_FUDCSDBlock,

{$IFDEF N_VRE} // VRE Project
  N_ImpF, N_MLEdF, N_VRMain2F,
{$ENDIF}

  N_Lib1, K_UDT1, N_Lib2, N_ME1, N_MsgDialF, N_FNameF, N_Gra2,
  N_NVTreeF, N_ExpF, N_InfoF, N_MetafEdF, N_RVCTF,
  N_Gra0, N_Gra1, N_PlainEdF, N_RichEdF, N_CompCL, N_UDCMap, N_UDat4,
  N_Rast1Fr, N_VRE3, N_WebBrF, N_ClassRef, N_EdParF,
  N_Comp1, N_UObjFr, N_ButtonsF, N_NVtreeFr,
  N_Deb1, N_VVEdBaseF, N_VScalEd1F, N_VPointEd1F, N_VRectEd1F; // N_Tst1;

{$R *.dfm}

const
  N_NewArchName = 'Untitled';

//****************  TN_MainFormFrame class handlers  ******************

//******************************************** TN_MainFormFrame.Create ***
//
constructor TN_MainFormFrame.Create( AOwner: TComponent );
begin
  Inherited;
{
var
  i: integer;
begin
  Inherited;

  // ShowChildForms array is used only in CurStateToMemIni and MemIniToCurState

  for i := 0 to High(ShowChildForms) do ShowChildForms[i] := nil; // Clear Array

  ShowChildForms[0] := aFormsImportExecute;
  ShowChildForms[1] := aFormsExportExecute;
  ShowChildForms[2] := aFormsNVtreeExecute;
  ShowChildForms[3] := aFormsParams1Execute;
  ShowChildForms[4] := aFormsDebProcsExecute;

//  ShowChildForms[?] := FormsMLEditorExecute;
//  ShowChildForms[?] := nil; // FormsFontEditorExecute;
//  ShowChildForms[?] := nil; // FormCompEditor
//  ShowChildForms[?] := FormsMetafEditorExecute;
}
end; // end_of constructor TN_MainFormFrame.Create


      //************* File actions ****************************

procedure TN_MainFormFrame.aFileArchNewExecute( Sender: TObject );
// Create New empty Archive with predefined N_NewArchName Name and Aliase
var
  TmpArch: TN_UDBase;
begin
  TmpArch := K_ArchsRootObj.DirChildByObjName( N_NewArchName );
//  TmpArch := N_GetUObj( K_ArchsRootObj, N_NewArchName );

  if TmpArch <> nil then // already exists
  begin
    if mrOK = N_MessageDlg( 'Archive  "' + N_NewArchName +
                            '"  already exists, OK to overload it?',
                                           mtWarning, mbOKCancel, 0 ) then
      TmpArch.ClearChilds()
    else // do not change anything
    begin
      N_Show1Str( 'New Archive was not created!' );
      Exit;
    end;
  end else // Here: no such an Archive, create it
  begin
    TmpArch := K_CreateArchiveNode( N_NewArchName );
    TmpArch.ObjName := N_NewArchName; // a precaution
  end;

  K_CurArchive  := TmpArch;

  with N_GetPCurArchAttr()^ do
  begin
    ArchWasChanged := True;
    FNameIsNotDef := True;
  end;

  K_InitArchiveGCont( K_CurArchive ); // // create all needed objects in K_CurArchive
  N_CurArchChanged.ExecActions();
  ShowCaption( N_NewArchName );
  N_Show1Str( 'New "' + N_NewArchName + '" Archive created OK' );
end; // procedure TN_MainFormFrame.aFileArchNewExecute

procedure TN_MainFormFrame.aFileArchOpenExecute( Sender: TObject );
// Open needed Archive
var
  FName: string;
  LoadFlags: TK_UDTreeLSFlagSet;
  ParamsForm: TN_EditParamsForm;
begin
  LoadFlags := [];

  if N_KeyIsDown( VK_Shift ) then // Open Archive with current Name but other format
  begin
    FName := K_CurArchive.ObjAliase;

    if N_GetPCurArchAttr()^.ArchFileFormatBin then
      FName := ChangeFileExt( FName, K_afTxtExt1 )
    else
      FName := ChangeFileExt( FName, K_afBinExt1 );

    N_SetSectionTopString( N_ArchFilesHistName, FName ); // add new FName to History
  end else // choose Archive File to open in dialog
  begin
    ParamsForm := N_CreateEditParamsForm( 500 );
    with ParamsForm do
    begin
      Caption := 'Choose Archive to Open:';
      AddFileNameFrame( '', N_ArchFilesHistName, N_ArchFilesFilter );
      AddCheckBox( 'Load All  "Manual Read"  Sections', False );
      if K_CurArchive <> nil then
        AddCheckBox( 'Only update All Sections from files', False );

      ShowSelfModal();

      if ModalResult <> mrOK then
      begin
        N_Show1Str( '' );
        Release; // Free ParamsForm
        Exit;
      end;

      FName := EPControls[0].CRStr;
      if EPControls[1].CRBool then LoadFlags := LoadFlags + [K_lsfLoadAllSLSR];
      if (K_CurArchive <> nil) and
         (EPControls[2].CRBool) then
      begin
        K_LoadAllCurArchSections();
        Release; // Free ParamsForm
        Exit;
      end;
      Release; // Free ParamsForm
    end; // with ParamsForm do
  end; // else -  choose Archive File to open in dialog

  OpenArchive( FName, LoadFlags );

{
  if N_KeyIsDown( VK_Shift ) then // Open previous Archive version
  begin
    FName := N_ChangeFileName( K_CurArchive.ObjAliase, -1 );
    if (FName = K_CurArchive.ObjAliase) or not FileExists( FName ) then
      FName := ChooseNewFileName(); // no previous version, show FileOpen dialog
  end else // choose Archive File to open in FileOpen dialog
    FName := ChooseNewFileName();

var
  CurExt: string;
begin
  if (K_CurArchive <> nil) and (K_CurArchive.ObjAliase <> '') then
  begin
    OpenDialog.InitialDir := ExtractFilePath( K_CurArchive.ObjAliase );
    OpenDialog.FileName := ExtractFileName( K_CurArchive.ObjAliase );
    CurExt := ExtractFileExt( K_CurArchive.ObjAliase );

    if CurExt = '.sdb' then OpenDialog.FilterIndex := 1
    else if CurExt = '.sdt' then OpenDialog.FilterIndex := 2
    else OpenDialog.FilterIndex := 3; // All files
  end; // if (K_CurArchive <> nil) and (K_CurArchive.ObjAliase <> '') then

  Result := '';

  if OpenDialog.Execute then // file was choosen,
    Result := OpenDialog.FileName; // return new File Name
}
end; // procedure TN_MainFormFrame.aFileArchOpenExecute

procedure TN_MainFormFrame.aFileArchSelectExecute( Sender: TObject );
// Select new current Archive from already opened (loaded to memory) Archives
var
  WUD: TN_UDBase;
begin
  WUD := K_CurArchive;
  if K_SelectFromUDDir( K_ArchsRootObj, WUD, 'Select New Current Archive' ) then
  begin
    K_CurArchive := WUD;
    K_InitArchiveGCont( K_CurArchive ); // create all needed objects in K_CurArchive
    N_CurArchChanged.ExecActions();
    ShowCaption( K_CurArchive.ObjAliase );
    N_SetSectionTopString( N_ArchFilesHistName, K_CurArchive.ObjAliase );
    N_SaveCurStateToMemIni();
    N_Show1Str( 'New Archive Selected OK' );
  end;
end; // procedure TN_MainFormFrame.aFileArchSelectExecute

procedure TN_MainFormFrame.aFileArchCloseExecute( Sender: TObject );
// Close (free memory) current Archive
begin
  if NoCurArchive() then Exit;

  if mrYes = N_MessageDlg( 'Save Archive  "' + K_CurArchive.ObjAliase +
                           '"  before closing it?',
                                         mtWarning, mbYesNo, 0 ) then
  begin
    aFileArchSaveExecute( nil );
  end;

  K_ArchsRootObj.DeleteOneChild( K_CurArchive );

  if K_ArchsRootObj.DirHigh >= 0 then
  begin
    K_CurArchive := K_ArchsRootObj.DirChild( 0 );
    ShowCaption( K_CurArchive.ObjAliase );
    N_SetSectionTopString( N_ArchFilesHistName, K_CurArchive.ObjAliase );
    N_Show1Str( 'Archive Closed OK, New Archive Selected' );
  end else
  begin
    K_CurArchive := nil;
    ShowCaption( 'No Archive Selected!' );
    N_Show1Str( 'Archive Closed OK, No Archive Selected' );
  end;
  N_SaveCurStateToMemIni();
end; // procedure TN_MainFormFrame.aFileArchCloseExecute

procedure TN_MainFormFrame.aFileArchSaveExecute( Sender: TObject );
// Save current Archive without dialog in the same file.
// If Shift is down, toggle Archive Type (sdt <--> sdb).
// (show FileSave dialog if current Archive has predefined N_NewArchName name)
var
  SavedCursor: TCursor;
  FileName: string;
  SavedOK: boolean;
begin
  if NoCurArchive() then Exit;

  if N_GetPCurArchAttr^.FNameIsNotDef then // New Archive (File Name is undefined)
  begin
    aFileArchSaveAsExecute( nil );
    Exit;
  end;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  FileName := K_CurArchive.ObjAliase;

  if N_KeyIsDown( VK_Shift) and      // toggle Archive File Format (.sdt <--> .sdb)
                (Sender <> nil) then // is called not from own Pascal code
  begin
//    K_ArchFileFormat( FileName ) = K_aftTxt then
    if N_GetPCurArchAttr()^.ArchFileFormatBin then
      FileName := ChangeFileExt( FileName, K_afTxtExt1 )
    else
      FileName := ChangeFileExt( FileName, K_afBinExt1 );

    K_SetArchiveName( K_CurArchive, FileName );
    N_SetSectionTopString( N_ArchFilesHistName, FileName );
    Showcaption( FileName );
  end; // if ... then // toggle Archive File Format (.sdt <--> .sdb)

//  N_T1.Start();
  SavedOK := K_SaveArchive( K_CurArchive, SaveArchFlags );
//  N_T1.SS( 'Save Archive' );

  if not SavedOK then // NOT saved
  begin
    N_Show1Str( 'Archive not saved!' );
    Exit;
  end; // if not K_SaveArchive( K_CurArchive ) then // NOT saved

  N_GetPCurArchAttr()^.ArchWasChanged := False;
  N_Show1Str( 'Archive saved OK to ' + ExtractFileName( FileName ) );
  N_SaveCurStateToMemIni();
  Screen.Cursor := SavedCursor;
end; // procedure TN_MainFormFrame.aFileArchSaveExecute

procedure TN_MainFormFrame.aFileArchSaveAsExecute( Sender: TObject );
// Choose new FileName for current Archive in Dialog,
// save Archive in binary or text format and rename current Archive
var
  FullFName: string;
  Overvrite: boolean;
  ParamsForm: TN_EditParamsForm;
begin
  N_Show1Str( '' );
  if NoCurArchive() then Exit;

  if N_KeyIsDown( VK_Shift) and (Sender <> nil) then // autocreate (+1) needed file Name
  begin
    FullFName := N_ChangeFileName( K_CurArchive.ObjAliase, 1 );
    N_SetSectionTopString( N_ArchFilesHistName, FullFName );
  end else //********************** Ask needed file Name in dialog
  begin
    ParamsForm := N_CreateEditParamsForm( 400 );
    with ParamsForm do
    begin
      Caption := 'Choose File Name to Save Archive:';
      AddFileNameFrame( '', N_ArchFilesHistName, N_ArchFilesFilter );
      AddCheckBox( 'Save  "Not Changed"  Sections', False );
      AddCheckBox( 'Disjoin  "Joined to Archive"  Sections', False );
      AddCheckBox( 'Set "Joined" to all  Sections', False );

      ShowSelfModal();

      if ModalResult <> mrOK then
      begin
        N_Show1Str( '' );
        Release; // Free ParamsForm
        Exit;
      end;

      FullFName := EPControls[0].CRStr;

      SaveArchFlags := [];
      if EPControls[1].CRBool then // Save also Sections that were not Changed
        SaveArchFlags := [K_lsfSaveNotChangedSLSR];

      if EPControls[2].CRBool then // Save All Sections that were not Changed
        SaveArchFlags := SaveArchFlags + [K_lsfDisjoinSLSR];

      if EPControls[3].CRBool then // Set Joined flag to All Sections
        SaveArchFlags := SaveArchFlags + [K_lsfSetJoinToAllSLSR];

      Release; // Free ParamsForm
    end; // with ParamsForm do
{
    SaveDialog.FileName := K_CurArchive.ObjAliase;
    SaveDialog.FilterIndex := Ord(K_ArchFileFormat( K_CurArchive.ObjAliase )) + 1;

    if SaveDialog.Execute then
    begin
      FullFName := SaveDialog.FileName;
      if SaveDialog.FilterIndex = 1 then
        FullFName := ChangeFileExt( FullFName, '.sdb' )
      else if SaveDialog.FilterIndex = 2 then
        FullFName := ChangeFileExt( FullFName, '.sdt' );
    end else
      Exit;
}
  end; // else - Ask needed file Name in dialog

  // New Archive Name FullFName is OK, save Archive to it
  // (do not Confirm Overvriting in autocreate mode)

  if N_KeyIsDown( VK_Shift) or
    (FullFName = K_CurArchive.ObjAliase) then
    Overvrite := True
  else
    Overvrite := N_ConfirmOverwriteDlg( FullFName );

  if Overvrite then
  begin
    K_SetArchiveName( K_CurArchive, FullFName );
    N_GetPCurArchAttr()^.FNameIsNotDef := False;

//    if K_CurArchive.ObjInfo = '' then // set default FilesEnvID used for new Archives
//      K_CurArchive.ObjInfo := K_NewArchFilesEnvID;

    aFileArchSaveExecute( nil );
    Showcaption( FullFName );
  end; // if Overvrite then
end; // procedure TN_MainFormFrame.aFileArchSaveAsExecute

procedure TN_MainFormFrame.aFileNoSaveExitExecute( Sender: TObject );
// Exit from Application without any Saving
begin
  MainForm.Close();
end; // procedure TN_MainFormFrame.aFileNoSaveExitExecute


      //************* Not used now File actions ****************
{
procedure TN_MainFormFrame.ArchReopenExecute( Sender: TObject );
// open new Archive in FileName Frame Form (with Arch Names History)
// ( same as ArchOpenExecute but with another FileName dialog)
var
  FName: string;
begin
  with TN_FileNameForm.Create( Application ) do
  begin
    Top  := Mouse.CursorPos.Y + 5;
    Left := Mouse.CursorPos.X;
    FName := SelectFileName( 'ArchNamesHistory' );
  end;

  OpenArchive( FName );
end; // procedure TN_MainFormFrame.ArchReopenExecute

procedure TN_MainFormFrame.ArchAddToCurrentExecute( Sender: TObject );
// Add Selected Archive to current Archive and delete Selected Archive
var
  AddedName: string;
  WUD: TN_UDBase;
begin
  WUD := K_CurArchive;
  if K_SelectFromUDDir( K_ArchsRootObj, WUD, 'Select Archive for adding to current' ) then
  begin
    AddedName := WUD.ObjAliase;
    WUD.MarkSubTree( 1 ); // prepare for K_MergeArchives
    K_MergeArchives( WUD, K_CurArchive, nil );
    N_GetPCurArchAttr()^.ArchWasChanged := True;
    N_Show1Str( AddedName + ' Archive was added to current and deleted' );
  end;
end; // procedure TN_MainFormFrame.ArchAddSelectedExecute

procedure TN_MainFormFrame.ArchSaveAllExecute( Sender: TObject );
// save all Archives without dialog in the same files
// ( show FileSave dialog for Archive with N_NewArchName name)
var
  i, h: Integer;
  SavedCurArchive: TN_UDBase;
begin
  with K_ArchsRootObj do begin
    h := DirHigh;
    SavedCurArchive := K_CurArchive;

    for i := 0 to h do begin
      K_CurArchive := DirChild( i );
      if K_CurArchive <> nil then ArchSaveExecute( Sender );
    end;

    N_SaveCurStateToMemIni();
    K_CurArchive := SavedCurArchive; // restore
  end;
end; // procedure TN_MainFormFrame.ArchSaveAllExecute

procedure TN_MainFormFrame.ArchReloadAllExecute( Sender: TObject );
// Auto Reload All opened Archives and recompile All SPL units
// using flags in N_MEGlobObj.MERecompFlags
begin
  K_RecompileGlobalSPL( N_MEGlobObj.MERecompFlags );
  N_Show1Str( 'All Archives Reloaded, SPL Units Recompiled' );
end; // procedure TN_MainFormFrame.ArchReloadAllExecute

type TN_ArchSaveOptions = packed record // Archive Saving Options
  ASOSkipJoin:     byte;
  ASODisjoin:      byte;
  ASOSkipReadOnly: byte;
  ASOSaveReadOnly: byte;
  ASOSkipEmpty:    byte;
  ASOSaveEmpty:    byte;
//  ASOSkipSaveDlg:  byte;
end; // type TN_ArchSaveOptions = packed record

Флаги управления сохранениме секций в переменной  K_UDGControlFlags
K_gcfSkipJoinChangedSLSR, - блокировка "подклеивания" измененных секций в архив
K_gcfDisjoinSLSR,         - "отклеивание" ранее "подклеенной" секций из архива
K_gcfSkipReadOnlySLSR,    - блокировка сохранения измененных секций только для чтения
K_gcfSaveReadOnlySLSR,    - безусловное сохранение измененных секций только для чтения
K_gcfSkipEmptySLSR,       - блокировка сохранения измененных "пустых" секций
K_gcfSaveEmptySLSR,       - безусловное сохранение измененных "пустых" секций
K_gcfSkipSaveSLSRDialog   - блокировка вызова диалога по сохранению

procedure TN_MainFormFrame.ArchEditOptionsExecute( Sender: TObject );
// Edit Archive Options
var
  ArchSaveOptions: TN_ArchSaveOptions;
begin
  with ArchSaveOptions do
  begin
    //***** fill record to Edit

    ASOSkipJoin     := Byte(K_gcfSkipJoinChangedSLSR  in K_UDGControlFlags);
    ASODisjoin      := Byte(K_gcfDisjoinSLSR in K_UDGControlFlags);
    ASOSkipReadOnly := Byte(K_gcfSkipReadOnlySLSR    in K_UDGControlFlags);
    ASOSaveReadOnly := Byte(K_gcfSaveReadOnlySLSR    in K_UDGControlFlags);
    ASOSkipEmpty    := Byte(K_gcfSkipEmptySLSR       in K_UDGControlFlags);
    ASOSaveEmpty    := Byte(K_gcfSaveEmptySLSR       in K_UDGControlFlags);
//    ASOSkipSaveDlg  := Byte(K_gcfSkipSaveSLSRDialog  in K_UDGControlFlags);

    N_EditRecord( [], ArchSaveOptions, 'TN_ArchSaveOptions', 'Global Settings',
                            'TN_ArchSaveOptionsFormDescr', nil, nil, MainForm, mmfModal );

    if N_MEGlobObj.MEModalResult = mrOK then // ArchSaveOptions fields changed
    begin
      //***** Set new Archive Save Options

      K_UDGControlFlags := K_UDGControlFlags - [K_gcfSkipJoinChangedSLSR,
         K_gcfDisjoinSLSR, K_gcfSkipReadOnlySLSR, K_gcfSaveReadOnlySLSR,
         K_gcfSkipEmptySLSR, K_gcfSaveEmptySLSR];

      if ASOSkipJoin     <> 0 then K_UDGControlFlags := K_UDGControlFlags + [K_gcfSkipJoinChangedSLSR];
      if ASODisjoin      <> 0 then K_UDGControlFlags := K_UDGControlFlags + [K_gcfDisjoinSLSR];
      if ASOSkipReadOnly <> 0 then K_UDGControlFlags := K_UDGControlFlags + [K_gcfSkipReadOnlySLSR];
      if ASOSaveReadOnly <> 0 then K_UDGControlFlags := K_UDGControlFlags + [K_gcfSaveReadOnlySLSR];
      if ASOSkipEmpty    <> 0 then K_UDGControlFlags := K_UDGControlFlags + [K_gcfSkipEmptySLSR];
      if ASOSaveEmpty    <> 0 then K_UDGControlFlags := K_UDGControlFlags + [K_gcfSaveEmptySLSR];
//      if ASOSkipSaveDlg  <> 0 then K_UDGControlFlags := K_UDGControlFlags + [K_gcfSkipSaveSLSRDialog];

    end; // if N_MEGlobObj.MEModalResult = mrOK then

  end; // with ArchSaveOptions do
end; // procedure TN_MainFormFrame.ArchEditOptionsExecute

procedure TN_MainFormFrame.FileExitAskExecute( Sender: TObject );
// Ask if Saving is needed and Exit from Application
begin
// not implemented
end; // procedure TN_MainFormFrame.FileExitAskExecute

procedure TN_MainFormFrame.FileSaveExitExecute( Sender: TObject );
// Save All and Exit from Application
begin
// not implemented
end; // procedure TN_MainFormFrame.FileSaveExitExecute
}

      //************* Edit actions ****************************

procedure TN_MainFormFrame.aEditGlobalOptionsExecute( Sender: TObject );
// Edit Global Options
//( Edit Params in Modal mode in N_MEGlobObj, N_GlobObj and some other fields)
var
  i, NumChannels: integer;
  Params: TN_MEGOParams;
begin
  with Params, N_MEGlobObj, N_GlobObj do // fill record to Edit
  begin
    MemIniToVBAParams(); // Get N_MEGlobObj VBA Params from N_MemIni

    EDebFlags       := MEDebFlags;
    ERecompFlags    := MERecompFlags;
    ESDTUnloadFlags := K_TextModeFlags;

    EWordFlags      := MEWordFlags;
    EWordPSMode     := MEWordPSMode;
    EWordMinVersion := MEWordMinVersion;

    EDefScrResDPI := MEDefScrResDPI;
    EDefPrnResDPI := MEDefPrnResDPI;
    EScrResCoef   := MEScrResCoef;

    EGridStepmm   := GridStepmm;
    EGridStepLSU  := GridStepLSU;
    EGridStepPrc  := GridStepPrc;
    EGridStepUser := GridStepUser;

    EPathFlags := GOPathFlags;

    NumChannels := Length(N_LogChannels);
    ELogChannels := K_RCreateByTypeCode( N_SPLTC_LCInfo, NumChannels );

    for i := 0 to NumChannels-1 do
    with N_LogChannels[i], TN_PLogChannelInfo(ELogChannels.P(i))^ do
    begin
      LCIFlags   := LCFlags;
      LCIFName   := LCFName;
      LCIBufSize := LCBufSize;
    end; // for i := 0 to NumChannels-1 do

    if K_InfoWatch.WatchMax = 0 then EDebFlags := EDebFlags - [medfInfoWatch]
                                else EDebFlags := EDebFlags + [medfInfoWatch];

    N_EditRecord( [], Params, 'TN_MEGOParams', 'Global Settings',
                              'TN_MEGOParamsFormDescr', nil, nil, MainForm, mmfModal );

    MEDebFlags       := EDebFlags;
    MERecompFlags    := ERecompFlags;
    K_TextModeFlags  := ESDTUnloadFlags;

    MEWordFlags      := EWordFlags;
    MEWordPSMode     := EWordPSMode;
    MEWordMinVersion := EWordMinVersion;
    VBAParamsToMemIni(); // Save N_MEGlobObj VBA Params to N_MemIni

    MEDefScrResDPI := EDefScrResDPI;
    N_DblToMemIni( 'User_Interface', 'DefScreenResDPI',  '%.2f', MEDefScrResDPI );

    MEDefPrnResDPI := EDefPrnResDPI;
    N_DblToMemIni( 'User_Interface', 'DefPrinterResDPI', '%.2f', MEDefPrnResDPI );

    MEScrResCoef := EScrResCoef;
    N_DblToMemIni( 'User_Interface', 'ScreenResCoef',    '%.3f', MEScrResCoef );

    GridStepmm   := EGridStepmm;
    GridStepLSU  := EGridStepLSU;
    GridStepPrc  := EGridStepPrc;
    GridStepUser := EGridStepUser;

    GOPathFlags := EPathFlags;

//    if medfProtocolToFile in MEDebFlags then N_DebGroups[0].DSInd := 0
//                                        else N_DebGroups[0].DSInd := -1;

    if medfInfoWatch in MEDebFlags then K_InfoWatch.WatchMax := 200
                                   else K_InfoWatch.WatchMax := 0;

    N_SPLValToMemIni( 'GlobalFlags', 'MEDebFlags',  MEDebFlags,    N_SPLTC_MEDebFlags );
    N_SPLValToMemIni( 'GlobalFlags', 'RecompFlags', MERecompFlags, N_SPLTC_RecompFlags );
    N_SPLValToMemIni( 'GlobalFlags', 'SDTUnloadFlags', K_TextModeFlags, N_SPLTC_SDTUnloadFlags );

    N_LCExecAction( -1, lcaFree ); // Flush and Free all Channels

    NumChannels := ELogChannels.ALength(); // New Number of Channels
    SetLength( N_LogChannels, NumChannels );
    N_CurMemIni.EraseSection( 'LogChannels' );

    if NumChannels > 0 then // some channels are defined
    begin
      FillChar( N_LogChannels[0], NumChannels*SizeOf(TN_LogChannel), 0 );

      for i := 0 to NumChannels-1 do
      with N_LogChannels[i], TN_PLogChannelInfo(ELogChannels.P(i))^ do
      begin
        LCFlags   := LCIFlags;
        LCFName   := LCIFName;
        N_LCExecAction( i, lcaSetBufSize, LCIBufSize );

        N_SPLValToMemIni( 'LogChannels', IntToStr(i),
                                        ELogChannels.P(i)^, N_SPLTC_LCInfo );
      end; // for i := 0 to NumChannels-1 do
    end; // if NumChannels > 0 then // some channels are defined

    ELogChannels.Free;

  end; // with Params, N_MEGlobObj do

end; // procedure TN_MainFormFrame.aEditMEGlobObjExecute


      //************* View actions ****************************

procedure TN_MainFormFrame.ViewArchAsDTreeExecute( Sender: TObject );
// View current Archive as DTree (or all Archives if Shift key is down)
begin
  K_SelectUDB( K_CurArchive, 'MapEditor', nil, nil, 'Archive as DTree' );
end; // procedure TN_MainFormFrame.ViewArchAsDTreeExecute

procedure TN_MainFormFrame.ViewProtocolExecute( Sender: TObject );
// View / Edit Protocol (now only View)
begin
  N_ShowProtocol( 'Application Protocol', MainForm );
end; // procedure TN_MainFormFrame.ViewProtocolExecute


      //************* Forms actions ****************************

procedure TN_MainFormFrame.aFormsImportExecute( Sender: TObject );
// Show Import CObjects Form
begin
  N_i := 1;
{$IFDEF N_VRE} // VRE Project
  N_GetImportForm( MainForm ).Show();
{$ENDIF}
  N_i := 2;
end;

procedure TN_MainFormFrame.aFormsExportExecute( Sender: TObject );
// Show Export CObjects Form
begin
  N_GetExportForm( MainForm ).Show();
end;

procedure TN_MainFormFrame.aFormsNVtreeExecute( Sender: TObject );
// Show TN_NVTreeForm
begin
  N_CreateNVTreeForm( MainForm ).Show();
end;

procedure TN_MainFormFrame.aFormsParams1Execute( Sender: TObject );
// Show TN_Params1Form - Params Setting Form #1
begin
//  N_GetParams1Form( MainForm ).Show();
end;

procedure TN_MainFormFrame.aFormsDebProcsExecute( Sender: TObject );
// Show TN_DebProcsForm
begin
//  N_GetDebProcsForm( MainForm ).Show();
end;

procedure TN_MainFormFrame.aFormsWebBrowserExecute( Sender: TObject );
// Show Web Browser
begin
//  N_WebBrowser.Show();
//  N_WebBrowser.WebBrowser.Navigate('file:///c:/Delphi_prj/N_HTML/Main1.html');
end;

{
procedure TN_MainFormFrame.FormsMLEditorExecute( Sender: TObject );
// Show MapLayers Editor Form
begin
  if NoCurArchive() then Exit;
  N_GetMLEditorForm( MainForm ).Show();
end;

procedure TN_MainFormFrame.FormsMetafEditorExecute( Sender: TObject );
// Show Metafile Editor Form
begin
  N_GetMetafEdForm( MainForm ).Show();
end;
}



      //************* Tools actions ****************************

procedure TN_MainFormFrame.ToolsDTreeEdExecute( Sender: TObject );
// show DTree Editor
begin
//  K_GetFormTreeEdit.Show;
end;

procedure TN_MainFormFrame.ToolsPlainEditorExecute( Sender: TObject );
// Show Plain Editor
begin
  N_CreatePlainEditorForm( MainForm ).Show();
end;

procedure TN_MainFormFrame.ToolsRichEditorExecute( Sender: TObject );
// Show Rich Editor
begin
  N_CreateRichEditorForm().Show();
end;

procedure TN_MainFormFrame.ToolsSPLEnvExecute( Sender: TObject );
// Show SPL environment Form
begin
  K_GetFormMVDeb.Show;
end;

procedure TN_MainFormFrame.ToolsRunSPLScriptExecute( Sender: TObject );
// Run SPL Script
begin
  K_GetFormRunSPLScript( MainForm ).Show;
end;

procedure TN_MainFormFrame.ToolsCDimEditorExecute( Sender: TObject );
// Show Codes Dimension Editor Form
begin
  K_EditUDCDim( nil, MainForm, nil, True );
end; // procedure TN_MainFormFrame.ToolsCDimEditorExecute

procedure TN_MainFormFrame.ToolsCSDimEditorExecute( Sender: TObject );
// Show Codes SubDimension Editor Form
begin
  K_EditUDCSDim( nil, MainForm, nil, True );
end; // procedure TN_MainFormFrame.ToolsCSDimEditorExecute

procedure TN_MainFormFrame.ToolsCSDimRelEditorExecute( Sender: TObject );
// Show Codes SubDimension Relation Editor Form
begin
  K_EditUDCDCor( nil, MainForm, nil, True );
end; // procedure TN_MainFormFrame.ToolsCSDimRelEditorExecute

procedure TN_MainFormFrame.ToolsDataBlockEditorExecute( Sender: TObject );
// Show Data Block Editor Form
begin
  K_EditUDCSDBlock( nil, MainForm, nil, True );
end; // procedure TN_MainFormFrame.ToolsDataBlockEditorExecute

//************** Beg Obsolete Code
procedure TN_MainFormFrame.ToolsCSEditorExecute( Sender: TObject );
// Show Codes Space Editor Form
begin
  K_EditDCSpace( nil, MainForm );
end;

procedure TN_MainFormFrame.ToolsCSSEditorExecute( Sender: TObject );
// Show Codes SubSpace Editor Form
begin
  K_GetFormDCSSpace( MainForm ).ShowModal();
//  K_EditDCSSpace( nil, MainForm );
end;

procedure TN_MainFormFrame.ToolsCSProjEditorExecute( Sender: TObject );
// Show Codes Space Projection Editor Form
begin
  K_GetFormDCSProjection( MainForm ).ShowModal();
end; // procedure TN_MainFormFrame.ToolsCSProjEditorExecute
//************** End Obsolete Code


      //************* Options actions **************************
      //************* Others actions ***************************

procedure TN_MainFormFrame.OthSaveCurStateExecute( Sender: TObject );
// save current state for all currently opened forms
begin
  N_SaveCurStateToMemIni();
end;

procedure TN_MainFormFrame.OthRefreshSclonTableExecute( Sender: TObject );
// Refresh (Recreate) SclonTable
begin
  N_MEGlobObj.CreateSclonTableIndex();
end; // procedure TN_MainFormFrame.OthCreateSclonTableExecute

      //************* Debug actions ****************************

procedure TN_MainFormFrame.DebPlatformInfoExecute( Sender: TObject );
// show Platform Info in N_Info Form
begin
  N_GetInfoForm().Show;
  N_PlatformInfo( N_InfoForm.Memo.Lines, $FFF );
end;

procedure TN_MainFormFrame.DebSpeedTestsExecute( Sender: TObject );
// Call Speed Tests
begin
//  N_Tst1FastTimer();
//  N_TstAllSpeedTest1();
//  N_TstTimers();
//  N_TstValProc();
end;

procedure TN_MainFormFrame.DebShowTimersExecute( Sender: TObject );
// Show N_T2b Timers
begin
  N_T2b.Show( 20 );
  N_T2b.Clear( 20 );
end; // procedure TN_MainFormFrame.DebShowTimersExecute


var af1: Array [0..5] of Float = (1.09,1.001,-2.1,123.45678, -99.123, -0.0013);

procedure TN_MainFormFrame.DebWrk1Execute( Sender: TObject );
// Debug Action #1
//var
//  CMMain2Form:  TN_CMMain2Form;
begin
//  if assigned( N_TstUseDLLProc ) then N_TstUseDLLProc();

//  CMMain2Form := TN_CMMain2Form.Create( Application );
//  CMMain2Form.MFFrame.IsMainAppForm := True; // self is main Application form
//  CMMain2Form.MFFrame.IsMainAppForm := False;
//  CMMain2Form.ShowModal();

//  N_TstRastr1FrConvFunc();
//  N_TstSPLToBinSpeed();
//  N_TstCNKInds();
//  N_TstSpecCharsToHex();
//  N_TstBrackets();
//  N_s := K_GetTextFromClipboard();
//  N_TstWordActDoc1();
//  N_TstMVTATest1();
end; // procedure TN_MainFormFrame.DebWrk1Execute

procedure TN_MainFormFrame.DebWrk2Execute( Sender: TObject );
// Debug Action #2
begin
//  N_TstRectsConvObj();
//  N_TstMatrConvObj();
end; // procedure TN_MainFormFrame.DebWrk2Execute

procedure TN_MainFormFrame.DebWrk3Execute( Sender: TObject );
// Debug Action #3
//*** Different Test Functions
//*** QuoteStr funcs
//*** Format, Round funcs
//*** Drawing Rect on Windows Desktop
//*** TN_RectProgressBar Test

  function ConvToDbl( AF: float ): double;
  begin
    N_d := Power( 10, 6 - Floor(Log10(Abs(AF))) );
    N_d1 := AF*N_d;
    N_d1 := Round(AF*N_d);
    Result := N_d1/N_d;
  end; // function ConvToDbl( AF: float ): double;

begin

   N_f := 1./3;      N_d := N_FToDbl( N_f );
   N_f := 101 / 10;  N_d := N_FToDbl( N_f );
   N_f := -909 / 10; N_d := N_FToDbl( N_f );

   N_d := N_FToDbl( 0.1234567 );
   N_d := N_FToDbl( 1.234567 );
   N_d := N_FToDbl( 123456.7 );

   N_d := N_FToDbl( 0.1234561 );
   N_d := N_FToDbl( 1.234561 );
   N_d := N_FToDbl( 123456.1 );

   N_d := N_FToDbl( 0.9234567 );
   N_d := N_FToDbl( 9.234567 );
   N_d := N_FToDbl( 923456.7 );

   N_d := N_FToDbl( 0.9234561 );
   N_d := N_FToDbl( 9.234561 );
   N_d := N_FToDbl( 923456.1 );

   N_d := N_FToDbl( -0.1234567 );
   N_d := N_FToDbl( -1.234567 );
   N_d := N_FToDbl( -123456.7 );

   N_d := N_FToDbl( -0.1234561 );
   N_d := N_FToDbl( -1.234561 );
   N_d := N_FToDbl( -123456.1 );

   N_d := N_FToDbl( -0.9234567 );
   N_d := N_FToDbl( -9.234567 );
   N_d := N_FToDbl( -923456.7 );

   N_d := N_FToDbl( -0.9234561 );
   N_d := N_FToDbl( -9.234561 );
   N_d := N_FToDbl( -923456.1 );


   N_d := ConvToDbl( 0.1234567 );
   N_d := ConvToDbl( 1.234567 );
   N_d := ConvToDbl( 123456.7 );

   N_d := ConvToDbl( 0.1234561 );
   N_d := ConvToDbl( 1.234561 );
   N_d := ConvToDbl( 123456.1 );

   N_d := ConvToDbl( 0.9234567 );
   N_d := ConvToDbl( 9.234567 );
   N_d := ConvToDbl( 923456.7 );

   N_d := ConvToDbl( 0.9234561 );
   N_d := ConvToDbl( 9.234561 );
   N_d := ConvToDbl( 923456.1 );

   N_d := ConvToDbl( -0.1234567 );
   N_d := ConvToDbl( -1.234567 );
   N_d := ConvToDbl( -123456.7 );

   N_d := ConvToDbl( -0.1234561 );
   N_d := ConvToDbl( -1.234561 );
   N_d := ConvToDbl( -123456.1 );

   N_d := ConvToDbl( -0.9234567 );
   N_d := ConvToDbl( -9.234567 );
   N_d := ConvToDbl( -923456.7 );

   N_d := ConvToDbl( -0.9234561 );
   N_d := ConvToDbl( -9.234561 );
   N_d := ConvToDbl( -923456.1 );

   N_d := ConvToDbl( 0.12345678 );
   N_d := ConvToDbl( 1.2345678 );
   N_d := ConvToDbl( 123456.78 );

   N_d := ConvToDbl( 0.12345671 );
   N_d := ConvToDbl( 1.2345671 );
   N_d := ConvToDbl( 123456.71 );

   N_d := ConvToDbl( 0.92345678 );
   N_d := ConvToDbl( 9.2345678 );
   N_d := ConvToDbl( 923456.78 );

   N_d := ConvToDbl( 0.92345671 );
   N_d := ConvToDbl( 9.2345671 );
   N_d := ConvToDbl( 923456.71 );

   N_d := ConvToDbl( -0.12345678 );
   N_d := ConvToDbl( -1.2345678 );
   N_d := ConvToDbl( -123456.78 );

   N_d := ConvToDbl( -0.12345671 );
   N_d := ConvToDbl( -1.2345671 );
   N_d := ConvToDbl( -123456.71 );

   N_d := ConvToDbl( -0.92345678 );
   N_d := ConvToDbl( -9.2345678 );
   N_d := ConvToDbl( -923456.78 );

   N_d := ConvToDbl( -0.92345671 );
   N_d := ConvToDbl( -9.2345671 );
   N_d := ConvToDbl( -923456.71 );



   N_d1 := 100.1;
   N_d2 := 100.09;
   N_s1 := Format( '%g %g', [N_d1,N_d2] );

   N_d1 := 0.000000101;
   N_d2 := 0.00907;
   N_s2 := Format( '%g %g', [N_d1,N_d2] );

   N_d1 := 0.000000000101;
   N_d2 := 0.00000907;
   N_s2 := Format( '%g %g', [N_d1,N_d2] );

   N_d1 := 101000.01;
   N_d2 := 100.00907;
   N_s2 := Format( '%g %g', [N_d1,N_d2] );

   N_f1 := 1.001;
   N_d1 := N_f1*N_10E6D;

   N_f1 := 10.01;
   N_d1 := N_f1*N_10E6D;

   N_f1 := 100.1;
   N_d1 := N_f1*N_10E6D;

   N_f1 := 1001;
   N_d1 := N_f1*N_10E6D;

   N_f1 := 100.1;
   N_f2 := 100.09;

   N_d1 := N_f1*N_10E6D;
   N_d1 := N_f1;
   N_d2 := N_d1*N_10E6D;
   N_s1 := Format( '%g %g', [N_d1,N_d2] );


   N_d1 := N_10EM6D*Round(N_f1*N_10E6D);
   N_d2 := N_10EM6D*Round(N_f2*N_10E6D);
   N_s1 := Format( '%g %g', [N_d1,N_d2] );

   N_f1 := 0.000000101;
   N_f2 := 0.00907;
   N_d1 := N_10EM6D*Round(N_f1*N_10E6D);
   N_d2 := N_10EM6D*Round(N_f2*N_10E6D);
   N_s2 := Format( '%g %g', [N_d1,N_d2] );

   N_s2 := '';


{
//**************************************************** Different Test Functions
//  N_TstProgressBar( MainForm, MainStatusBar, nil );
//  N_TstCreateOCanv();
//  N_TstRaramsForm();
//  N_Test2DFunc1();
//  N_CreateTestForm().Show();
//  N_TestStrEdit2();
//  N_TstGr1Fnt_1( '' );
//  N_TestSortPointers();
//  N_TstGr1Metafile_5( '' );
//  N_TstGr1GIF_1( '' );
//  N_TstGr1Metafile_5( '' );
//  N_TstGr1GDI_1( edDebParStr.Text );
//  N_TstGr1Raster_1( edDebParStr.Text );
//  N_TstGr1BMP_4( edDebParStr.Text );
//  N_TstGr1GDIRes_1( edDebParStr.Text );
//  N_TstGr1DIBSection_1( '' );
//********************************************* end of Different Test Functions

//************************************************************** QuoteStr funcs
  N_s := '0123';
  N_s := '"01"23"';
  N_s := '01"23456789abcdefghijklmn0123456789abcdefghijklmn0123456789abcdefghijklmn';
  N_s1 := N_QuoteString( N_s, '"' );
  N_pc1 := PChar(N_s1);
  N_s2 := N_DeQuoteChars( N_pc1, 10 );
  N_pc1 := PChar(N_s1);
  N_s2 := N_DeQuoteChars( N_pc1, 3 );
  Exit;

   N_i := 257;
   N_s := N_BytesToHexString( @N_i, 4 );
   N_HexCharsToBytes( @N_s[1], @N_i1, 4 );

   N_s := 'asdf';
   N_s1 := AnsiQuotedStr( 'asdf', '"' );
   N_i := integer(N_s1[1]);
   N_i := integer(N_s1[2]);

   N_s := 'asdf';
   N_s[2] := Char( 39 );
   N_s1 := AnsiQuotedStr( N_s, '"' );

   N_s := 'asdf';
   N_s[2] := Char( 34 );
   N_s1 := AnsiQuotedStr( N_s, '"' );

   N_PC := @N_s1[1];
   N_s2 := AnsiExtractQuotedStr( N_PC, '"' );

   N_s := QuotedStr( 'asdf' );
   N_s := QuotedStr( 'a''sd' );
   N_s := QuotedStr( 'a"sd ' );
   N_s := Format( '%X %X %X', [0, $123, $123aF] );
   Val( '$FF', N_i, N_i1 );
//******************************************************* end of QuoteStr funcs

//********************************************************* Format, Round funcs
   N_f1 := 100.1;
   N_f2 := 100.09;
   N_d1 := Round(N_f1*100000)/100000;
   N_d2 := N_10EM6D*Round(N_f1*N_10E6D);
   N_s1  := Format( '%g %g', [N_d1,N_d2] );

   N_i := Trunc( 1.7 );
   N_i := Trunc( 1.3 );
   N_i := Trunc( 0.5 );
   N_i := Trunc( 0.0 );
   N_i := Trunc( -0.5 );
   N_i := Trunc( -1.3 );
   N_i := Trunc( -1.7 );

   N_i := Round( 1.7 );
   N_i := Round( 1.3 );
   N_i := Round( 0.5 );
   N_i := Round( 0.0 );
   N_i := Round( -0.5 );
   N_i := Round( -1.3 );
   N_i := Round( -1.7 );

   N_f1 := -0.00123456;
   N_T1.Start();
   N_i := Round(Log10(Abs(N_f1))-0.5);
   N_d := Power( 10, 7 - N_i );
   N_d1 := Round(N_f1*N_d)/N_d;
   N_T1.Stop();
   N_s  := Format( '%g', [N_d1] );
   N_T1.Show( '1*Round 1 ' + N_s );

   N_f1 := 0.000012345678;
   N_T1.Start();
   N_i := Round(Log10(Abs(N_f1))-0.5);
   N_d := Power( 10, 7 - N_i );
   N_d1 := Round(N_f1*N_d)/N_d;
   N_T1.Stop();
   N_s  := Format( '%g', [N_d1] );
   N_T1.Show( '1*Round 2 ' + N_s );

   N_f1 := 0.123456;
   N_T1.Start();
   N_d := Floor(Log10(Abs(N_f1)));
   N_d := Power( 10, 7 - N_d );
   N_d1 := Round(N_f1*N_d)/N_d;
   N_T1.Stop();
   N_s  := Format( '%g', [N_d1] );
   N_T1.Show( '1*Floor 1   ' + N_s );

   N_f1 := -0.0000012345678;
   N_T1.Start();
   N_d := Power( 10, 7 - Floor(Log10(Abs(N_f1))) );
   N_d1 := Round(N_f1*N_d)/N_d;
   N_T1.Stop();
   N_s  := Format( '%g', [N_d1] );
   N_T1.Show( '1*Floor 2   ' + N_s );

   N_d1 := N_10EM6D*Round(N_f1*N_10E6D);
   N_d2 := N_10EM6D*Round(N_f2*N_10E6D);

   N_f1 := 100;
   N_i := Round(Log10(N_f1)-0.5);
   N_d := Power( 10, 7 - N_i );
   N_d1 := Round(N_f1*N_d)/N_d;
   N_s  := Format( '%g', [N_d1] );

   N_f1 := 100.1;
   N_i := Round(Log10(N_f1)-0.5);
   N_d := Power( 10, 7 - N_i );
   N_d1 := Round(N_f1*N_d)/N_d;
   N_s  := Format( '%g', [N_d1] );

   N_f1 := 100.1;
   N_i := Round(Log10(N_f1)-0.5);
   N_d := Power( 10, 8 - N_i );
   N_d1 := Round(N_f1*N_d)/N_d;
   N_s  := Format( '%g', [N_d1] );

   N_f1 := 0.00701;
   N_i := Round(Log10(N_f1));
   N_d := Power( 10, 7 - N_i );
   N_d1 := Round(N_f1*N_d)/N_d;
   N_s  := Format( '%g', [N_d1] );

   N_f1 := 0.701;
   N_i := Round(Log10(N_f1));
   N_d := Power( 10, 7 - N_i );
   N_d1 := Round(N_f1*N_d)/N_d;
   N_s  := Format( '%g', [N_d1] );

   N_d1 := 100.1;
   N_d2 := 100.09;
   N_s1  := Format( '%g %g', [N_d1,N_d2] );

   N_d1 := 0.000000101;
   N_d2 := 0.00907;
   N_s2  := Format( '%g %g', [N_d1,N_d2] );

   N_f1 := 100.1;
   N_f2 := 100.09;
   N_d1 := N_10EM6D*Round(N_f1*N_10E6D);
   N_d2 := N_10EM6D*Round(N_f2*N_10E6D);
   N_s1  := Format( '%g %g', [N_d1,N_d2] );

   N_f1 := 0.000000101;
   N_f2 := 0.00907;
   N_d1 := N_10EM6D*Round(N_f1*N_10E6D);
   N_d2 := N_10EM6D*Round(N_f2*N_10E6D);
   N_s2  := Format( '%g %g', [N_d1,N_d2] );

   N_f1 := 10.008;
   N_f2 := 10.0005;

   N_T1.Start();
   N_d1 := N_10EM6D*Round(N_f1*N_10E6D);
   N_d2 := N_10EM6D*Round(N_f2*N_10E6D);
   N_T1.Stop();
   N_T1.Show( '2*Round *d 1' );

   N_T1.Start();
   N_d1 := N_10EM6D*Round(N_f1*N_10E6D);
   N_d2 := N_10EM6D*Round(N_f2*N_10E6D);
   N_T1.Stop();
   N_T1.Show( '2*Round *d 2' );

   N_T1.Show( '2*Round' );
   N_T1.Start();
   N_s1  := Format( '%g %g', [N_d1,N_d2] );
   N_T1.Stop();
   N_T1.Show( 'Format' );

   N_d1 := 13/10;
   N_d2 := 10.01;
   N_s2 := Format( '%g %g %f %f', [N_d1,N_d2,N_d1,N_d2] );

   N_f1 := 1 / 3;
   N_f2 := 101 / 10;
   N_s  := Format( '%g %g %f %f', [N_f1,N_f2,N_f1,N_f2] );
   N_d1 := N_f1;
   N_d2 := N_f2;
   N_s  := Format( '%g %g %f %f', [N_d1,N_d2,N_d1,N_d2] );
   N_d1 := 1 / 3;
   N_d2 := 101 / 10;
   N_s  := Format( '%g %g %f %f', [N_d1,N_d2,N_d1,N_d2] );
   N_d1 := 14.6 / 2;
   N_d2 := 12.5 / 3;
   N_s1 := Format( '%g %g %f %f', [N_d1,N_d2,N_d1,N_d2] );
   N_d1 := 146 / 20;
   N_d2 := 125 / 30;
   N_s2 := Format( '%g %g %f %f', [N_d1,N_d2,N_d1,N_d2] );
   Exit;
//************************************************** end of Format, Round funcs

//********************************************* Drawing Rect on Windows Desktop
var
  HBr: HBrush;
  SUL: TPoint;

  SUL.X := MainForm.Left;
  SUL.Y := MainForm.Top;

  N_FillRectOnWinDesktop( Rect(5, 5, 20, 20), $FFFF00 );
  Application.ProcessMessages;
  N_FillRectOnWinDesktop( Rect(SUL.X, SUL.Y, SUL.X+20, SUL.Y+20), $FFFF00 );
  Application.ProcessMessages;
  MainForm.Invalidate();

  Application.ProcessMessages;
  MainForm.Repaint();
  Application.ProcessMessages;
  MainForm.Refresh();
  Application.ProcessMessages;
  Exit;

  HBr := Windows.CreateSolidBrush( $FF );
  Windows.FillRect( MainForm.Canvas.Handle, Rect( 2, 2, 500, 200 ), HBr );
  MainForm.Invalidate();
//  Application.ProcessMessages;
//  AF := N_ActiveVTreeFrame.OwnerForm;
//  Windows.FillRect( AF.Canvas.Handle, Rect( 2, 2, 500, 200 ), HBr );
//  AF.Invalidate();
  DeleteObject( HBr );
//************************************** end of Drawing Rect on Windows Desktop

//***************************************************** TN_RectProgressBar Test
  RPB := TN_RectProgressBar.Create( MainForm, Rect(0, -30, -5, -27), $BF00 );

  for i := 0 to 100 do
  begin
    RPB.Draw( i );
    MainForm.Invalidate();
//    Application.ProcessMessages;
//    Sleep( 50 );
    N_DelayByLoop( 10 );
  end; // for i := 0 to 100 do

  RPB.Free;
//********************************************** end of TN_RectProgressBar Test

}
end; // procedure TN_MainFormFrame.DebWrk3Execute

procedure TN_MainFormFrame.DebShowDebFormExecute( Sender: TObject );
// Show DebForm
begin
//  N_CreateTestForm().Show();
//  N_GetDebForm( MainForm ).Show;
end; // procedure TN_MainFormFrame.DebShowDebFormExecute

procedure TN_MainFormFrame.DebViewOLEServerExecute( Sender: TObject );
// Make One running OLE Server (one MS Word and one MS Excel) Visible
var
  NumServers: integer;
  HR: HResult;
  Unknown: IUnknown;
  OLEServer: Variant;
begin
  with N_MEGlobObj do
  begin
  NumServers := 0;

  HR := GetActiveObject( ProgIDToClassID( MEWordServerName ), nil, Unknown );

  if HR <> MK_E_UNAVAILABLE then
  begin
    OLEServer := GetActiveOLEObject( MEWordServerName );
    OLEServer.Visible := True;
    Inc( NumServers );
    OLEServer := UnAssigned();
  end; // if HR <> MK_E_UNAVAILABLE then

  HR := GetActiveObject( ProgIDToClassID( MEExcelServerName ), nil, Unknown );

  if HR <> MK_E_UNAVAILABLE then
  begin
    OLEServer := GetActiveOLEObject( MEExcelServerName );
    OLEServer.Visible := True;
    Inc( NumServers );
    OLEServer := UnAssigned();
  end; // if HR <> MK_E_UNAVAILABLE then

  N_Show1Str( Format( ' %d OLE Server(s) shown!', [NumServers] ) );

  end; // with N_MEGlobObj do
end; // procedure TN_MainFormFrame.DebViewOLEServerExecute

procedure TN_MainFormFrame.DebQuitOLEServersExecute( Sender: TObject );
// Quit all MS Word and MS Excel Applications
var
  i, NumClosed, NumDocs: integer;
  HR: HResult;
  Unknown: IUnknown;
  OLEServer: Variant;
  PPrev: PVarData;
  Label CheckMSWord, CheckMSExcel;
begin
  with N_MEGlobObj do
  begin

  NumClosed := 0;
  PPrev := nil;

  CheckMSWord: //********************
               // Several visible MS Word Windows (one Window per Document)
               // are represented by one Process in Windows Task Manager!
               // (unlike MS Excel application)

  HR := GetActiveObject( ProgIDToClassID( MEWordServerName ), nil, Unknown );

  if HR <> MK_E_UNAVAILABLE then
  begin

    OLEServer := GetActiveOLEObject( MEWordServerName );

    if PPrev = FindVarData( OLEServer ) then // Pointers to VarData can be compared
    begin
      OLEServer := UnAssigned(); // a precaution
      N_Show1Str( 'May be MS Word Server is not closed!' );
      // Word will Quit after Exit?
      Exit;
    end;

    NumDocs := OLEServer.Documents.Count;

    for i := 1 to NumDocs do
      OLEServer.Documents.Item(i).Saved := True;

    OLEServer.DisplayAlerts := False;
    OLEServer.Quit;
    PPrev := FindVarData( OLEServer );
    OLEServer := UnAssigned();
    Inc( NumClosed );
    Application.ProcessMessages();
    goto CheckMSWord;
  end; // if HR <> MK_E_UNAVAILABLE then

  PPrev := nil;

  CheckMSExcel: //********************
               // Several visible MS Excel Windows (one Window per WorkBook)
               // are represented by Several Processes in Windows Task Manager!
               // (unlike MS Word application)

  HR := GetActiveObject( ProgIDToClassID( MEExcelServerName ), nil, Unknown );

  if HR <> MK_E_UNAVAILABLE then
  begin
    OLEServer := GetActiveOLEObject( MEExcelServerName );

//    if VarSameValue(PrevOLEServer, OLEServer) then - Delphi can not compare!
    if PPrev = FindVarData( OLEServer ) then // Pointers to VarData can be compared
    begin
      OLEServer := UnAssigned(); // a precaution
      N_Show1Str( 'May be MS Excel Server is not closed!' );
      // Excel will Quit after Exit!
      Exit;
    end;

    NumDocs := OLEServer.WorkBooks.Count;

    for i := 1 to NumDocs do
      OLEServer.WorkBooks.Item[i].Saved := True;

    OLEServer.DisplayAlerts := False;
    OLEServer.Quit; // Really Excel Quits only while returning from this Delhi method!
    PPrev := FindVarData( OLEServer );
    OLEServer := UnAssigned();
    Inc( NumClosed );
    Application.ProcessMessages();
    goto CheckMSExcel;
  end; // if HR <> MK_E_UNAVAILABLE then

  end; // with N_MEGlobObj do

  if NumClosed = 0 then
    N_Show1Str( 'OLE Servers not found!' )
  else
    N_Show1Str( Format( ' %d OLE Server(s) closed!', [NumClosed] ) );

{
begin
  try
    OLEServer := GetActiveOleObject( 'Excel.Application' );
  except
    OLEServer.Visible := True;
    OLEServer := UnAssigned();
    Exit;
  end;


  while True do // Close Excel Applications
  begin
    try
      OLEServer := GetActiveOleObject( 'Excel.Application' );
    except
      Exit;
      System.Break;
    end;

    OLEServer.Visible := True;
    OLEServer.DisplayAlerts := False;
    OLEServer := UnAssigned();
    Exit;
//    OLEServer.Quit;
    Application.ProcessMessages();
    Inc( NumClosed );
  end; // while True

  while True do // Close Word Applications
  begin
    try
      OLEServer := GetActiveOleObject( 'Word.Application' );
    except
      System.Break;
    end;

    OLEServer.Visible := True;
    OLEServer.Quit;
    OLEServer := UnAssigned();
    Inc( NumClosed );
  end; // while True
  N_Show1Str( Format( ' %d Applications closed!', [NumClosed] ) );
}
end; // procedure TN_MainFormFrame.DebQuitOLEServersExecute

procedure TN_MainFormFrame.DebSetDefCursorExecute( Sender: TObject );
// Set Default Cursor
begin
  Screen.Cursor := crDefault;
end; // procedure TN_MainFormFrame.DebSetDefCursorExecute


//****************  TN_MainFormFrame class public methods  ************

procedure TN_MainFormFrame.InitMainFormFrame();
// Initialize Archive if not yet and some Self fields
begin
//  N_T1.SSS( 'Before MainForm BaseFormInit' );
  if MainForm is TN_BaseForm then
//    TN_BaseForm(MainForm).BaseFormInit( nil );
    TN_BaseForm(MainForm).BaseFormInit( nil, '', [], [] );
//  N_T1.SSS( 'After MainForm BaseFormInit' );

  N_StateString.ShowStringProc := ShowStringInStatusBar; // old var, obsolete, remove later
  N_GlobObj.GOStatusBar1 := MainStatusBar;

  with N_PBCaller do
  begin
    SaveParams( @SavedPBCParams ); // is really needed if MainForm is not Application Main Form
    SBPBProgressBarInit( 'Loading ...', MainStatusBar, nil );
    RectProgressBarInit( MainForm, Rect(5,-21,-6, -18), $00AA00 ); // just above MainForm StatusBar
  end;

//  N_Alert( 'IsMainAppForm ' + IntToStr(integer(IsMainAppForm)) );

  if not IsMainAppForm then // MainForm is not NOT main Application Form, Archive should be already OK
  begin
    MemIniToCurState(); // this method should be called after Archive was loaded
    Exit;
  end;

  //***** Load Archive by OnTimer Event to make MainForm visible while loading Archive
  //      (MainForm would be
  ArchLoadTimer := TTimer.Create( nil );
  ArchLoadTimer.Interval := 1;
  ArchLoadTimer.Enabled := True;
  ArchLoadTimer.OnTimer := InitArchive;

  //***** Archive would be loaded in InitArchive,
  //      called as ArchLoadTimer OnTimer Event handler
end; // procedure TN_MainFormFrame.InitMainFormFrame

procedure TN_MainFormFrame.InitArchive( Sender: TObject );
// Initialize Archive if not yet (OnTimer Event Handler)
var
  ArchFName, InitActionStr, Path: string;
  VNode: TN_VNode;
begin
  ArchLoadTimer.Enabled := False;
  ArchLoadTimer.Free;
//  N_T1.SSS( 'Before Load Archive' );

//



  if K_CurArchive = nil then //***** Archive was not opened yet, Open it
  begin
    ArchFName := N_MemIniToString( N_ArchFilesHistName, '0');
    ArchFName := K_ExpandFileName( ArchFName );
    if (ArchFName = '')            or
       (not FileExists(ArchFName)) or
       ( ((GetKeyState(VK_CAPITAL) and     1) <> 0) and    // CapsLock is ON
         ((GetKeyState(VK_SHIFT)   and $8000) <> 0) and    // Shift is ON
         ((GetKeyState(VK_CONTROL) and $8000) <> 0) ) then // Control is ON
    begin
//      N_Alert( 'NewArchive ' );
      aFileArchNewExecute( Self );
      N_LCAdd( MFPCInd, 'New Archive Created OK' );
    end else
    begin
//      N_Alert( '1. Before OpenArchive= ' + ArchFName );
      OpenArchive( ArchFName, [] );
      N_LCAdd( MFPCInd, 'Archive opened: ' + ArchFName );
    end;
  end; // if K_CurArchive = nil then // Archive was not opened yet, Open it

  ArchiveIsReady := True;
  MainForm.MemIniToCurState();

  //  MemIniToCurState(); // this method should be called AFTER Archive was loaded
                     // (otherwise NVTreeFrame state would not be restored)
//  N_T1.SS( 'After Load Archive' );

  // Process InitAction param in N_Debug section:
  //  = 'DebWrk1'  - Execute DebWrk1
  //  = 'ViewUObj' - View UObj (in PathToUObj param of N_Debug section) as Map

  InitActionStr := N_MemIniToString( 'N_Debug', 'InitAction' );

  if InitActionStr = 'DebWrk1' then // Execute DebWrk1
    DebWrk1Execute( nil )
  else if InitActionStr = 'ViewUObj' then // View UObj (in PathToUObj) as Map
  begin
    if N_ActiveVTreeFrame = nil then Exit;
    Path := N_MemIniToString( 'N_Debug', 'PathToUObj' );
    N_ActiveVTreeFrame.VTree.GetVNodeByPath( VNode, Path );
    if VNode <> nil then N_ViewUObjAsMap( VNode.VNUDObj, @N_MEGlobObj.RastVCTForm,
                                                 N_ActiveVTreeFrame.OwnerForm );
  end; // if InitActionStr = 'ViewUObj' then
end; // procedure TN_MainFormFrame.InitArchive

//******************************  TN_MainFormFrame.ShowStringInStatusBar  ***
// Show given String in StatusBar
//
procedure TN_MainFormFrame.ShowStringInStatusBar( AStr: string );
begin
  if MainStatusBar <> nil then
    MainStatusBar.SimpleText := ' ' + AStr;

  if N_MEGlobObj.ScriptMode = 1 then
    N_StateString.Protocol.Add( Astr );
end; // end of procedure TN_MainFormFrame.ShowStringInStatusBar

procedure TN_MainFormFrame.ShowCaption( Astr: string );
// Show MainForm Caption
begin
  TForm(Owner).Caption := 'ME-' + AStr;
end; // procedure TN_MainFormFrame.ShowCaption

procedure TN_MainFormFrame.ShowProgress1( MessageLine: string;
                                           ProgressStep: Integer );
// Show Progress (can be used for any time consuming operations)
begin
  if MainStatusBar = nil then Exit;
  MainStatusBar.SimpleText := MessageLine;
  MainStatusBar.Refresh();
{
  if MainStatusBar <> nil then
    MainStatusBar.SimpleText := MessageLine;
  Application.ProcessMessages;
}
end; // procedure TN_MainFormFrame.ShowProgress

function TN_MainFormFrame.NoCurArchive(): boolean;
// return True and show message if K_CurArchive = nil
begin
  Result := False;
  if K_CurArchive <> nil then Exit;
  Result := True;
  N_Show1Str( 'Archive is not opened!' );
end;

{
function TN_MainFormFrame.GetDataPath(): string;
// get Path to Data directory
begin
  Result := '';
  if N_ImportForm <> nil then // already opened
  with N_ImportForm do
  begin
    Result := ExtractFilePath( frAux.mbFileName.Text );
  end;
  if Result = '' then Result := ExtractFilePath( Application.ExeName );
end;
}

function TN_MainFormFrame.ChooseNewFileName(): string;
// Choose in dialog and return New FileName
var
  CurExt: string;
begin
  if (K_CurArchive <> nil) and (K_CurArchive.ObjAliase <> '') then
  begin
    OpenDialog.InitialDir := ExtractFilePath( K_CurArchive.ObjAliase );
    OpenDialog.FileName := ExtractFileName( K_CurArchive.ObjAliase );
    CurExt := ExtractFileExt( K_CurArchive.ObjAliase );

    if CurExt = '.sdb' then OpenDialog.FilterIndex := 1
    else if CurExt = '.sdt' then OpenDialog.FilterIndex := 2
    else OpenDialog.FilterIndex := 3; // All files
  end; // if (K_CurArchive <> nil) and (K_CurArchive.ObjAliase <> '') then

  Result := '';

  if OpenDialog.Execute then // file was choosen,
    Result := OpenDialog.FileName; // return new File Name
end;

procedure TN_MainFormFrame.OpenArchive( ArchName: string; ALoadFlags: TK_UDTreeLSFlagSet );
// Open Archive with given ArchName and given ALoadFlags
var
  Ind: Integer;
  RedOK: boolean;
  TmpArchName: string;
begin
  N_Show1Str( 'No Arch Name!' );
  if ArchName = '' then Exit;
  N_Show1Str( 'Loading ...' );

  with K_ArchsRootObj do
  begin
    Ind := IndexOfChildObjName( ArchName, K_ontObjUName  );
    if Ind = -1 then // try alternative extension
    begin
      if K_ArchFileFormat( ArchName ) = K_aftTxt then
        TmpArchName := ChangeFileExt( ArchName, '.sdb' )
      else
        TmpArchName := ChangeFileExt( ArchName, '.sdt' );
      Ind := IndexOfChildObjName( TmpArchName, K_ontObjUName );
    end;

    if Ind <> -1 then // Archive with same name exists, ask for overwriting
    begin
      TmpArchName := ChangeFileExt( ExtractFileName(ArchName), '' );
      if N_MessageDlg( 'Archive  "' + TmpArchName +
                       '" already exists.'#$0D#$0A' Reload it ?',
                   mtConfirmation, mbOKCancel, 0 ) = mrOK then
      begin
        K_CurArchive := DirChild( Ind );
      end else
      begin
        N_Show1Str( 'New Archive not opened!' );
        Exit;
      end;
    end else // create New archive with given Name
    begin
      K_CurArchive := K_CreateArchiveNode( ArchName );
    end;

  end; // with K_ArchsRootObj do

  N_MEGlobObj.MEDebFlags := N_MEGlobObj.MEDebFlags + [medfCollectProtocol];
//  N_T1.Start();
  RedOK := K_ReadArchive( K_CurArchive, ArchName, ALoadFlags );
//  N_T1.SS( 'Open Archive' );
//  N_T2a.Show( 30 );

  if RedOK then // Archive Opened OK
  begin
    ShowCaption( ArchName );
    N_Show1Str( 'New Archive opened OK' );
  end else //*************************************** Failed
  begin
    N_Show1Str( 'New Archive not opened!' );
    Exit;
  end;

//  N_Alert( '1.5 After K_ReadArchive= ' + ArchName );

  with N_GetPCurArchAttr()^ do
  begin
    ArchWasChanged := False;
    FNameIsNotDef := False;
  end;

  K_InitArchiveGCont( K_CurArchive ); // create all needed objects in K_CurArchive
  N_CurArchChanged.ExecActions();
end; // procedure TN_MainFormFrame.OpenArchive

//*************************************** TN_MainFormFrame.CurStateToMemIni ***
// Save global MapEditor info
//
procedure TN_MainFormFrame.CurStateToMemIni();
//var
//  Str: string;
begin
  //*** Save current Archive Name
//  if K_CurArchive <> nil then Str := K_CurArchive.ObjAliase
//                         else Str := '';
//  N_StringToMemIni( 'N_VRMain', 'ArchiveFileName', Str );
{
  Str := '';
  //*** save indexes (by ShowChildForms array) of currently opened Forms
  //    (see filling ShowChildForms array in TN_MainFormFrame.Create)
  if N_ImportForm     <> nil then Str := Str + '0';
  if N_ExportForm     <> nil then Str := Str + '1';
  if N_NVTreeForm     <> nil then Str := Str + '2';
  if N_Params1Form    <> nil then Str := Str + '3';
  if N_DebProcsForm   <> nil then Str := Str + '4';
  N_StringToMemIni( 'N_VRMain', 'OpenedForms', Str );

  //*** save UObjFrame customizing Info
  N_CLBToMemIni( 'N_VRMain', 'UObjFrameMenu', N_UObjFrMenuDescr );
}
  //*** Other fields
end; // end of procedure TN_MainFormFrame.CurStateToMemIni

//*************************************** TN_MainFormFrame.MemIniToCurState ***
// Restore global MapEditor info
// Archive should be already opened for reopening Forms in ShowChildForms List
//
procedure TN_MainFormFrame.MemIniToCurState();
begin
{
var
  i: integer;
  Str: string;
  ShowForm: TN_OneObjProcObj;
begin
  //*** restore indexes (by ShowChildForms array) of currently opened Forms
  //    (see filling ShowChildForms array in TN_MainFormFrame.Create)
  Str := N_MemIniToString( 'N_VRMain', 'OpenedForms' );

  for i := 1 to Length(Str) do // open needed forms
  begin
    ShowForm := ShowChildForms[ integer(Str[i])-integer('0') ];
    if Assigned(ShowForm) then ShowForm( nil );
  end; // for i := 1 to Length(Str) do // open needed forms

  //*** restore UObjFrame customizing Info
  N_MemIniToCLB( 'N_VRMain', 'UObjFrameMenu', N_UObjFrMenuDescr );

  //*** Other fields
}
end; // end of procedure TN_MainFormFrame.MemIniToCurState

      //*********** Global Procedures  *****************************

end.
