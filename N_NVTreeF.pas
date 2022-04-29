unit N_NVTreeF;
// Map Editor VTree Form with UObj Popup Menu (defined in GetUObjFrame)

interface

uses                        
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, StdCtrls, ExtCtrls, ActnList, ImgList, Menus, Contnrs,
  K_UDT1,
  N_Types, N_Lib1, N_BaseF, N_RVCTF, N_PlainEdF, N_RAEditF,
  N_UObjFr, N_NVtreeFr, N_FNameFr;

type TN_NVTreeForm = class( TN_BaseForm )
    ToolBar1: TToolBar;
    StatusBar: TStatusBar;
    MainMenu1: TMainMenu;
    Edit1: TMenuItem;
    Other1: TMenuItem;
    File1: TMenuItem;
    View1: TMenuItem;
    RefreshFrame1: TMenuItem;
    N1: TMenuItem;
    tbSetOnRClickShiftAction: TToolButton;
    tbSetOnRClickCtrlAction: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton9: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    NVTreeFrame: TN_NVTreeFrame;
    FrFormFName: TN_FileNameFrame;
    LoadBellow1: TMenuItem;
    aFileLoadInside1: TMenuItem;
    N4: TMenuItem;
    LoadAndReplace1: TMenuItem;
    SaveSelected1: TMenuItem;
    N5: TMenuItem;
    SaveFields1: TMenuItem;
    CreateNewUObj1: TMenuItem;
    N7: TMenuItem;
    ToolButton1: TToolButton;
    ExportComponent1: TMenuItem;
    ToolButton10: TToolButton;
    ToolButton15: TToolButton;
    ChooseActionPopupMenu: TPopupMenu;
    miNoAction: TMenuItem;
    miViewAsMap: TMenuItem;
    miViewInfo: TMenuItem;
    miEditCompParams: TMenuItem;
    AlignComponents1: TMenuItem;
    Debug1: TMenuItem;
    ViewCompCoords1: TMenuItem;
    ViewUObjectsinClipboard1: TMenuItem;
    ViewMarkedUObjects1: TMenuItem;
    ToolButton2: TToolButton;
    tbToggleEditMark: TToolButton;
    ToolButton3: TToolButton;
    N2: TMenuItem;
    CutCopyPaste1: TMenuItem;
    DeleteMarked1: TMenuItem;
    CutMarked1: TMenuItem;
    CopyMarked1: TMenuItem;
    N9: TMenuItem;
    PasteRefsBefore1: TMenuItem;
    PasteRefsInside1: TMenuItem;
    PasteRefsInstead1: TMenuItem;
    N10: TMenuItem;
    PasteOneLevelClonesBefore1: TMenuItem;
    PasteOneLevelClonesInside1: TMenuItem;
    PasteOneLevelClonesInstead1: TMenuItem;
    N11: TMenuItem;
    PasteSubTreesClonesBefore1: TMenuItem;
    PasteSubTreesClonesInside1: TMenuItem;
    PasteSubTreesClonesInstead1: TMenuItem;
    LoadInsteadofMarked1: TMenuItem;
    ForceSingleOneLevelInstance1: TMenuItem;
    ForceSingleSubTreeInstance1: TMenuItem;
    PasteRefsAfterAllMarked1: TMenuItem;
    PasteOneLevelClonesAfterAllMarked1: TMenuItem;
    PasteSubTreeClonesAfterAllMarekd1: TMenuItem;
    N3: TMenuItem;
    SetNewNamesofMarked1: TMenuItem;
    SetCSCodesinMarkedSubTrees1: TMenuItem;
    CheckArchiveConsistency1: TMenuItem;
    ToolBar2: TToolBar;
    Options1: TMenuItem;
    SetNewOwnerstoMarked1: TMenuItem;
    tbSetOnDoubleClickAction: TToolButton;
    MarkMarkedChildren1: TMenuItem;
    mpAction11: TMenuItem;
    mpAction21: TMenuItem;
    mpAction31: TMenuItem;
    ToolButton4: TToolButton;
    ToolButton14: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ShowStatisticsaboutMarked1: TMenuItem;
    EditUObjInfo1: TMenuItem;
    N6: TMenuItem;
    UnresolveRefsInSelectedSubTree1: TMenuItem;
    ResolveRefsInSelectedSubTree1: TMenuItem;
    ClearUnresolvedRefsinSelectedSubTree1: TMenuItem;
    ViewPathsToUObj1: TMenuItem;
    CloseChildForms1: TMenuItem;
    EditSeparateArchiveFlags1: TMenuItem;
    LoadMarkedArchiveSections1: TMenuItem;
    ToolButton8: TToolButton;
    aEdClearUObjWasChangedBit1: TMenuItem;
    ToolButton13: TToolButton;
    Debug2: TMenuItem;
    RunWordMacro1: TMenuItem;
    ViewRefsBetweenSubtrees1: TMenuItem;
    ViewRefsToSelectedSubTree1: TMenuItem;
    ViewRefsFromSelectedSubTree1: TMenuItem;
    RedirectRefsinSubTree1: TMenuItem;
    ReplaceMarkedUObjects1: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    Spec11: TMenuItem;
    CoordsObjects1: TMenuItem;
    oggleCObjRunTimeFlag2: TMenuItem;
    Components1: TMenuItem;
    oggleCompSkipExecFlag1: TMenuItem;
    ViewCleaRAFields: TMenuItem;
    CheckProjectConsistency1: TMenuItem;
    ShowVideoDevices1: TMenuItem;

    //********* FormActionList actions  ********************************
    procedure aDeb1Execute  ( Sender: TObject );
    procedure aDeb2Execute  ( Sender: TObject );
    procedure aDeb3Execute  ( Sender: TObject );

    //********* Set OnClick  actions  and methods ***********************
    procedure tbnSetOnClickActionClick ( Sender: TObject );
    procedure SetOnClickActionByInd    ( AnActInd: integer );
    procedure miSetOnClickAction       ( Sender: TObject );

    //********* Other handlers  ********************************
    procedure tbToggleEditMarkClick   ( Sender: TObject );

    procedure FormKeyDown  ( Sender: TObject; var Key: Word;
                                                         Shift: TShiftState );
    procedure FormActivate ( Sender: TObject ); override;
    procedure FormShow     ( Sender: TObject );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;

  private
    OnClickTBN: TToolButton; // pressed ToolBar Button (used in SetOnClickActionByInd)
    OnClickActions: array [0..3] of TAction; // array of all OnClick Actions
    OnClickActInds: array [0..2] of Integer; // Action Inds in OnClickActions array,
                                             // ( used in CurStateToMemIni )
  public
    procedure CurArchiveChanged (); override;
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
end; // TN_NVTreeForm = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

function N_CreateNVTreeForm( AOwner: TN_BaseForm ): TN_NVTreeForm;

var
  N_NVTreeForm: TN_NVTreeForm; // used only for saving list of currently
                                 // opened Forms in MainMEFormFrame
implementation
uses Math,
   K_DTE1, K_Arch,
   N_Lib0, N_Lib2, N_UDat4, N_UDCMap, N_ME1, N_EdStrF, N_InfoF, N_NewUObjF,
   N_Rast1Fr, N_CompBase, N_ButtonsF, N_MenuF;

{$R *.dfm}

//****************  TN_NVTreeForm class handlers  ******************

    //********************* FormActionList actions *************************

procedure TN_NVTreeForm.aDeb1Execute( Sender: TObject );
// Debug Action 1
begin
//  StatusBar.SimpleText := 'Debug Action 1';
//  N_EditIniFileSection( 'TempSection' );
//  N_EditIniFileSection( 'Dirs' );

//  N_ud := N_GetUObj( N_MapsDir, 'RusTDBPrint' );
//  N_ViewCompFull( TN_UDCompVis(N_ud), @N_MEGlobObj.RastVCTForm, Self );

end; // procedure TN_NVTreeForm.aDeb1ExecuteDeb1

procedure TN_NVTreeForm.aDeb2Execute( Sender: TObject );
// Debug Action 2
begin
  StatusBar.SimpleText := 'Debug Action 2';
end; // procedure TN_NVTreeForm.aDeb1ExecuteDeb2

procedure TN_NVTreeForm.aDeb3Execute( Sender: TObject );
// Debug Action 3
begin
//  N_ExecuteSetParams( NVTreeFrame.VTree.Selected.Vchild );
  StatusBar.SimpleText := 'Debug Action 3';
end; // procedure TN_NVTreeForm.aDeb1ExecuteDeb3


    //********* Set OnClick  actions  and methods ***********************

procedure TN_NVTreeForm.tbnSetOnClickActionClick( Sender: TObject );
// Save pressed button in OnClickTBN variable and show PopupMenu
// for choosing needed action for pressed ToolBar Button
// ( common OnClick handler for all three ToolBar Buttons:
//   tbSetOnDoubleClickAction, tbSetOnRClickShiftAction, tbSetOnRClickCtrlAction )
begin
  OnClickTBN := TToolButton(Sender); // Save pressed button (it's Tag will be used)
  with Mouse.CursorPos do
    ChooseActionPopupMenu.Popup( Max( 0, X-40 ), Y );
end; // procedure TN_NVTreeForm.tbnSetOnClickActionClick

procedure TN_NVTreeForm.SetOnClickActionByInd( AnActInd: integer );
// Set OnClick Action by given Action Index (in OnClickActions array)
// (used in miSetOnClickAction and in MemIniToCurState)
begin
  AnActInd := min( AnActInd, High(OnClickActions) );

  case OnClickTBN.Tag of
    0: NVTreeFrame.OnDoubleClickAction := OnClickActions[AnActInd].OnExecute;
    1: NVTreeFrame.OnClickShiftAction  := OnClickActions[AnActInd].OnExecute;
    2: NVTreeFrame.OnClickCtrlAction   := OnClickActions[AnActInd].OnExecute;
  end; // case OnClickTBN.Tag of

  OnClickTBN.ImageIndex := OnClickActions[AnActInd].ImageIndex;
  OnClickActInds[OnClickTBN.Tag] := AnActInd; // used in CurStateToMemIni
end; // procedure TN_NVTreeForm.SetOnClickActionByInd

procedure TN_NVTreeForm.miSetOnClickAction( Sender: TObject );
// Set OnClick or OnDoubleClick Action for needed ToolBar Button (saved in OnClickTBN)
// Sender is ChooseActionPopupMenu PopupMenu Item
// (common OnClick handler for all ChooseActionPopupMenu Items)
begin
  // Sender is ChooseActionPopupMenu.Item,
  // Sender.Tag is it's index in PopupMemu and in OnClickActions array
  SetOnClickActionByInd( TControl(Sender).Tag );
end; // procedure TN_NVTreeForm.miSetOnClickAction

    //********* Other handlers  ********************************

procedure TN_NVTreeForm.tbToggleEditMarkClick( Sender: TObject );
// Toggle MarkComp and MoveComp RFrame Actions
var
  Ind: integer;
begin
  if N_ActiveRFrame = nil then Exit;

  with N_ActiveRFrame do
  begin
    if tbToggleEditMark.ImageIndex = 85 then // set Mark Mode
    begin
      Ind := GetGroupInd( N_SMoveCompGName );
      TN_SGBase(RFSGroups.Items[Ind]).SkipActions := True;  // disable RFAMoveCompAction
      Ind := GetGroupInd( N_SMarkCompGName );
      TN_SGBase(RFSGroups.Items[Ind]).SkipActions := False; // enable RFAMarkCompAction
      tbToggleEditMark.ImageIndex := 86
    end else //******************************** set Edit Mode if applicable
    begin
      Ind := GetGroupInd( N_SMoveCompGName );
      if Ind >= 0 then
      begin
        TN_SGBase(RFSGroups.Items[Ind]).SkipActions := False; // enable RFAMoveCompAction
        Ind := GetGroupInd( N_SMarkCompGName );
        TN_SGBase(RFSGroups.Items[Ind]).SkipActions := True;  // disable RFAMarkCompAction
        tbToggleEditMark.ImageIndex := 85
      end;
    end;
  end; // with N_ActiveRFRame do
end; // procedure TN_NVTreeForm.tbToggleEditMarkClick

procedure TN_NVTreeForm.FormKeyDown( Sender: TObject; var Key: Word;
                                                       Shift: TShiftState );
begin
//  StatusBar.SimpleText := IntToStr( Key );
end; // procedure TN_NVTreeForm.FormKeyDown

procedure TN_NVTreeForm.FormActivate( Sender: TObject );
begin
  Inherited;
  N_ActiveVTreeFrame := NVTreeFrame;
  N_NVTreeForm := Self;

  with N_MenuForm.frUObjCommon do
  begin
    OwnerForm     := Self;
    SomeStatusBar := StatusBar;
  end;
end; // procedure TN_NVTreeForm.FormActivate

procedure TN_NVTreeForm.FormShow( Sender: TObject );
// restoring NVtree state is possible only if Form is already shown
begin
  NVTreeFrame.CreateVTree( nil, K_fvSkipCurrent );
  NVTreeFrame.FrMemIniToCurState(); // restore NVTree state
end; // procedure TN_NVTreeForm.FormShow

procedure TN_NVTreeForm.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  inherited;
  N_NVTreeForm := nil;
end; // procedure TN_NVTreeForm.FormClose


//****************  TN_NVTreeForm class public methods  ************

//***********************************  TN_NVTreeForm.CurArchiveChanged  ******
// Update all needed Self fields after current Archive was changed
//
procedure TN_NVTreeForm.CurArchiveChanged();
begin
  NVTreeFrame.CurArchiveChanged();
end; // end of procedure TN_NVTreeForm.CurArchiveChanged

//***********************************  TN_NVTreeForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_NVTreeForm.CurStateToMemIni();
begin
  Inherited;
  N_ComboBoxToMemIni( 'N_NVTreeF_frFormFName', frFormFName.mbFileName );
  N_BoolToMemIni( 'N_NVTreeF', 'FrFormFNameVisible', FrFormFName.Visible );
  N_BoolToMemIni( 'N_NVTreeF', 'AddUObjSysInfo',  N_MEGlobObj.AddUObjSysInfo );
  N_BoolToMemIni( 'N_NVTreeF', 'AutoViewReport',  N_MEGlobObj.AutoViewReport );

  N_IntToMemIni( 'N_NVTreeF', 'tbn0Ind', OnClickActInds[0] );
  N_IntToMemIni( 'N_NVTreeF', 'tbn1Ind', OnClickActInds[1] );
  N_IntToMemIni( 'N_NVTreeF', 'tbn2Ind', OnClickActInds[2] );

  NVTreeFrame.FrCurStateToMemIni(); // save current NVTree state

  if N_KeyIsDown( VK_SHIFT ) then // Save Path to Selected UObj
  begin
    with NVTreeFrame.VTree do
      N_StringToMemIni( 'N_Debug', 'PathToUObj',
                                   GetPathToVNode( Selected, K_ontObjName ) );
  end; // if N_KeyIsDown( VK_SHIFT ) then // Save Path to Selected UObj

end; // end of procedure TN_NVTreeForm.CurStateToMemIni

//***********************************  TN_NVTreeForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_NVTreeForm.MemIniToCurState();
begin
  Inherited;
  N_MemIniToComboBox( 'N_NVTreeF_frFormFName', frFormFName.mbFileName );
  FrFormFName.Visible := N_MemIniToBool( 'N_NVTreeF', 'FrFormFNameVisible' );
  N_MEGlobObj.AddUObjSysInfo := N_MemIniToBool( 'N_NVTreeF', 'AddUObjSysInfo' );
  N_MEGlobObj.AutoViewReport := N_MemIniToBool( 'N_NVTreeF', 'AutoViewReport' );

  OnClickTBN := tbSetOnDoubleClickAction;
  SetOnClickActionByInd( N_MemIniToInt( 'N_NVTreeF', 'tbn0Ind', 0 ) );
  OnClickTBN := tbSetOnRClickShiftAction;
  SetOnClickActionByInd( N_MemIniToInt( 'N_NVTreeF', 'tbn1Ind', 0 ) );
  OnClickTBN := tbSetOnRClickCtrlAction;
  SetOnClickActionByInd( N_MemIniToInt( 'N_NVTreeF', 'tbn2Ind', 0 ) );

  //***** NVTree state is retrieved from MemIni in FormShow handler

end; // end of procedure TN_NVTreeForm.MemIniToCurState


    //*********** Global Procedures  *****************************

//********************************************  N_CreateNVTreeForm  ******
// Create new instance of N_NVTreeForm
//
function N_CreateNVTreeForm( AOwner: TN_BaseForm ): TN_NVTreeForm;
begin
  Result := TN_NVTreeForm.Create( Application );
//  if N_NVTreeForm = nil then N_NVTreeForm := Result; //??
  N_NVTreeForm := Result;

  with Result do
  begin
    with N_MenuForm.frUObjCommon do
    begin
      OnClickActions[0] := NVTreeFrame.aNoOnClickAction;
      OnClickActions[1] := aViewMain;
      OnClickActions[2] := aViewInfo;
//      OnClickActions[3] := aViewSysInfo;
      OnClickActions[3] := aEditParams;
    end;

//    BaseFormInit( AOwner );
    BaseFormInit( AOwner, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    CurArchiveChanged();

    frFormFName.SomeStatusBar := StatusBar;

    with NVTreeFrame do
    begin
      OwnerForm     := Result;
      SomeStatusBar := StatusBar;
      NFNameFr      := frFormFName;
    end;

    with N_MenuForm.frUObjCommon do
    begin
      OwnerForm     := Result;
      SomeStatusBar := StatusBar;
    end;
    
  end; // with Result do
end; // function N_CreateNVTreeForm

end.
