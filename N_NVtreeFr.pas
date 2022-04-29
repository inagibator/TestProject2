unit N_NVtreeFr;
// VTreeFrame with Self NActionList and GetUObjFrame's UObjActList
//
// some actions can be called by imbedded PopUp menu,
// some actions can be assigned on RightClick+(Shift,Ctrl) event

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, ImgList, StdCtrls, ComCtrls,
  K_Types, K_UDT1,
  N_Types, N_Lib1, N_BaseF, N_UObjFr, N_FNameFr;

type TN_NVTreeFrame = class( TN_VTreeFrame )
    NVTreeActionList: TActionList;
    aViewRefreshFrame: TAction;
    aEdDeleteMarked: TAction;
    aViewMoveUp: TAction;
    aViewMoveDown: TAction;
    aEdCutMarked: TAction;
    aEdCopyMarked: TAction;
    aEdPasteRefsBefore: TAction;
    aEdPasteRefsInside: TAction;
    aFileSaveUObjects: TAction;
    aFileLoadBefore: TAction;
    aFileLoadInside: TAction;
    aFileLoadFields: TAction;
    aFileSaveFields: TAction;
    aViewRefsToMarked: TAction;
    aEdCreateNewUObj: TAction;
    aOtherExportComp: TAction;
    aEdSetVisualOwnersToMarked: TAction;
    aEdPasteOLCBefore: TAction;
    aEdPasteSubTreesBefore: TAction;
    aEdForceSingleOneLevelInstance: TAction;
    aEdPasteRefsInstead: TAction;
    aOtherSetMarkedCSCodes: TAction;
    aOtherAlign: TAction;
    aDebViewMarked: TAction;
    aDebViewClipboard: TAction;
    aDebViewCompCoords: TAction;
    aOtherSetMarkedObjNames: TAction;
    aEdPasteOLCInside: TAction;
    aEdPasteSubTreesInside: TAction;
    aEdPasteOLCAny: TAction;
    aEdPasteSubTreesAny: TAction;
    aEdPasteRefsAny: TAction;
    aEdPasteOLCInstead: TAction;
    aEdPasteSubTreesInstead: TAction;
    aFileLoadInstead: TAction;
    aEdForceSingleSubTreeInstance: TAction;
    aEdPasteRefsAfter: TAction;
    aEdPasteOLCAfter: TAction;
    aEdPasteSubTreesAfter: TAction;
    aDebViewTwoExtRefsLists: TAction;
    aDebViewRefsToMarked: TAction;
    aDebCheckArchConsistency: TAction;
    aDebViewRefsInSelected: TAction;
    aOtherShowOptionsForm: TAction;
    aEdClearUnresolvedRefs: TAction;
    aOtherMarkChildren: TAction;
    aDebTmpAction1: TAction;
    aDebTmpAction2: TAction;
    aDebTmpAction3: TAction;
    aNoOnClickAction: TAction;
    aOtherShowStatistics: TAction;
    aEdEditUObjInfo: TAction;
    aViewCloseOwnedForms: TAction;
    aEdUnresolveRefsInSelected: TAction;
    aEdResolveRefsInSelected: TAction;
    aViewEntriesInSubTree: TAction;
    aFileEditArchSectionParams: TAction;
    aFileLoadArchSections: TAction;
    aEdClearUObjWasChangedBit: TAction;
    aDeb2RunWMacro: TAction;
    aViewRefsBetween: TAction;
    aViewRefsFromSubTree: TAction;
    aEdRedirectRefs: TAction;
    aEdReplaceUObjects: TAction;
    aSp1ChangeCObjRT: TAction;
    aSp1ChangeCompSkip: TAction;
    aSp1ViewClearRAFields: TAction;
    aDebCheckProject: TAction;
    aOtherShowVideoDevs: TAction;

    constructor Create ( AOwner: TComponent ); override;
    destructor  Destroy(); override;

    //************************ File Actions *************************
    procedure aFileLoadBeforeExecute       ( Sender: TObject );
    procedure aFileLoadInsideExecute       ( Sender: TObject );
    procedure aFileLoadInsteadExecute      ( Sender: TObject );
    procedure aFileLoadFieldsExecute       ( Sender: TObject );

    procedure aFileSaveUObjectsExecute     ( Sender: TObject );
    procedure aFileSaveFieldsExecute       ( Sender: TObject );

    procedure aFileEditArchSectionParamsExecute ( Sender: TObject );
    procedure aFileLoadArchSectionsExecute      ( Sender: TObject );

    //************************ Edit Actions *************************
    procedure aEdCreateNewUObjExecute    ( Sender: TObject );

    procedure aEdCutMarkedExecute        ( Sender: TObject );
    procedure aEdCopyMarkedExecute       ( Sender: TObject );
    procedure aEdDeleteMarkedExecute     ( Sender: TObject );
    procedure aEdEditUObjInfoExecute     ( Sender: TObject );

    procedure aEdPasteRefsBeforeExecute  ( Sender: TObject );
    procedure aEdPasteRefsAfterExecute   ( Sender: TObject );
    procedure aEdPasteRefsInsideExecute  ( Sender: TObject );
    procedure aEdPasteRefsInsteadExecute ( Sender: TObject );
    procedure aEdPasteRefsAnyExecute     ( Sender: TObject );

    procedure aEdPasteOLCBeforeExecute   ( Sender: TObject );
    procedure aEdPasteOLCAfterExecute    ( Sender: TObject );
    procedure aEdPasteOLCInsideExecute   ( Sender: TObject );
    procedure aEdPasteOLCInsteadExecute  ( Sender: TObject );
    procedure aEdPasteOLCAnyExecute      ( Sender: TObject );

    procedure aEdPasteSubTreesBeforeExecute  ( Sender: TObject );
    procedure aEdPasteSubTreesAfterExecute   ( Sender: TObject );
    procedure aEdPasteSubTreesInsideExecute  ( Sender: TObject );
    procedure aEdPasteSubTreesInsteadExecute ( Sender: TObject );
    procedure aEdPasteSubTreesAnyExecute     ( Sender: TObject );

    procedure aEdForceSingleOneLevelInstanceExecute ( Sender: TObject );
    procedure aEdForceSingleSubTreeInstanceExecute  ( Sender: TObject );
    procedure aEdSetVisualOwnersToMarkedExecute     ( Sender: TObject );
    procedure aEdClearUObjWasChangedBitExecute      ( Sender: TObject );

    procedure aEdUnresolveRefsInSelectedExecute ( Sender: TObject );
    procedure aEdResolveRefsInSelectedExecute   ( Sender: TObject );
    procedure aEdClearUnresolvedRefsExecute     ( Sender: TObject );
    procedure aEdRedirectRefsExecute            ( Sender: TObject );
    procedure aEdReplaceUObjectsExecute         ( Sender: TObject );

    //************************ View Actions *************************
    procedure aViewEntriesInSubTreeExecute ( Sender: TObject );
    procedure aViewRefsToMarkedExecute     ( Sender: TObject );
    procedure aViewRefsFromSubTreeExecute  ( Sender: TObject );
    procedure aViewRefsBetweenExecute      ( Sender: TObject );

    procedure aViewRefreshFrameExecute     ( Sender: TObject );
    procedure aViewCloseOwnedFormsExecute  ( Sender: TObject );

    procedure aViewMoveUpExecute   ( Sender: TObject );
    procedure aViewMoveDownExecute ( Sender: TObject );

    //************************ Other Actions *************************
    procedure aOtherExportCompExecute        ( Sender: TObject );
    procedure aOtherAlignExecute             ( Sender: TObject );
    procedure aOtherShowVideoDevsExecute     ( Sender: TObject );
    procedure aOtherSetMarkedCSCodesExecute  ( Sender: TObject );
    procedure aOtherSetMarkedObjNamesExecute ( Sender: TObject );
    procedure aOtherShowStatisticsExecute    ( Sender: TObject );
    procedure aOtherMarkChildrenExecute      ( Sender: TObject );
    procedure aOtherShowOptionsFormExecute   ( Sender: TObject );

    //************************ Special1 Actions *********************
    procedure aSp1ChangeCObjRTExecute ( Sender: TObject );

    procedure aSp1ChangeCompSkipExecute    ( Sender: TObject );
    procedure aSp1ViewClearRAFieldsExecute ( Sender: TObject );

    //************************ Deb1 Actions *************************
    procedure aDebViewMarkedExecute           ( Sender: TObject );
    procedure aDebViewClipboardExecute        ( Sender: TObject );
    procedure aDebViewRefsToMarkedExecute     ( Sender: TObject );
    procedure aDebViewTwoExtRefsListsExecute  ( Sender: TObject );
    procedure aDebViewRefsInSelectedExecute   ( Sender: TObject );
    procedure aDebViewUnresolvedRefsExecute   ( Sender: TObject );
    procedure aDebCheckArchConsistencyExecute ( Sender: TObject );
    procedure aDebViewCompCoordsExecute       ( Sender: TObject );

    procedure aDebTmpAction1Execute ( Sender: TObject );
    procedure aDebTmpAction2Execute ( Sender: TObject );
    procedure aDebTmpAction3Execute ( Sender: TObject );

    //************************ Deb2 Actions *************************
    procedure aDeb2RunWMacroExecute  ( Sender: TObject );
    procedure aDebCheckProjectExecute(Sender: TObject);

    //************************ User Actions *************************
//    procedure aUserCreateTBbyPointsExecute ( Sender: TObject );

  public
//    ClipboardDir: TN_UDBase; // temporary Dir for Copy, Cut, Paste operations (include in DTree later!)
    OwnerForm: TN_BaseForm;     // Owner Form for all Forms, opened in Actions
    SomeStatusBar: TStatusBar;  // used in ShowStr for Action messages
    NFNameFr: TN_FileNameFrame; // for File Actions
    OnDoubleClickAction: TN_OneObjProcObj; // OnDoubleClick Action
    OnClickShiftAction:  TN_OneObjProcObj; // OnRightClick+Shift Action
    OnClickCtrlAction:   TN_OneObjProcObj; // OnRightClick+Control Action
    MarkedChanged: boolean;   // Marked Comps or their Coords changed
    SkipAutoRedraw: boolean;  // prevent redrawing after each change in DTree

    procedure OnMouseProcObj ( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState );
    procedure CurArchiveChanged   ();
    procedure AddVNodesRefs       ( AVNodesList: TList; ADir: TN_UDBase );
    function  SelectedExists      (): boolean;
    procedure SetChangeAndRedraw              ();
    function  CreateSubTreeClone1 ( AUDBase: TN_UDBase;
                                              AIncValue: integer ): TN_UDBase;
    procedure PasteUObjectsBefore ( AUObjType: TN_UObjType;
                                            ADir: TN_UDBase; AMarked: TList );
    procedure PasteUObjectsAfter  ( AUObjType: TN_UObjType;
                                            ADir: TN_UDBase; AMarked: TList );
    procedure PasteUObjectsInside ( AUObjType: TN_UObjType;
                                            ADir: TN_UDBase; AMarked: TList );
    function  PasteUObjectsInstead( AUObjType: TN_UObjType;
                                    ADir: TN_UDBase; AMarked: TList ): boolean;
    function  DeleteVNodes ( AVNodesList: TList ): Integer;
    function  IsMarked     ( AUObj: TN_UDBase ): boolean;
    procedure ShowStr      ( AStr: string );
    procedure ShowStrAdd   ( AStr: string );
    procedure ShowProgress1 ( MessageLine : string; ProgressStep : Integer = -1 );
    procedure ShowWarning  ( MessageLine : string; MesStatus : TK_MesStatus = K_msInfo );
end; // type TN_NVTreeFrame = class(TN_VTreeFrame)

var
  N_ActiveVTreeFrame: TN_NVTreeFrame;
  N_CompressionLevels: array [0..3] of string = ( 'No Compression', 'Low Compression',
                                     'Middle Compression', 'High Compression' );

implementation
uses ZLib, ExtCtrls,
   DirectShow9,
   K_DTE1, K_Arch, K_SBuf, K_STBuf, K_UDC, K_DCSpace, K_UDT2,
   K_CLib, K_UDConst, K_RAEdit, K_Script1,
   K_MVObjs, K_FDCSpace, K_FrRaEdit, K_FMVMSOExp,
   N_Lib0, N_ClassRef, N_Lib2, N_Gra0, N_Gra1, N_UDat4, N_UDCMap, N_ME1, N_MsgDialF,
   N_EdStrF, N_InfoF, N_RichEdF, N_NewUObjF, N_AlignF, N_Deb1,
   N_Rast1Fr, N_NVTreeF, N_NVTreeOpF, N_ME2, N_CompBase, N_ButtonsF,
   N_RVCTF, N_Gra2, N_WebBrF, N_GCont, N_MenuF, N_EdParF, N_Video;
{$R *.dfm}

//*************************** Some global procedures **********************

//************************************************** N_AddToMVDarExportForm ***
// Open TK_FormMVMSOExport Form if not yet and Add WEB Objects to it,
// using given ARootVNode.VNUDObj as WEB Objects Root. If ARootVNode = nil use
// all marked VNodes in N_ActiveVTreeFrame as several WEB Roots
//
procedure N_AddToMVDarExportForm( ARootVNode: TN_VNode; AOwner: TN_BaseForm );
var
  VNodesList: TList;
  NewList: boolean;
begin
  with K_GetFormMVMSOExport( AOwner ) do // create TK_FormMVMSOExport if not yet
  begin
    if ARootVNode <> nil then // ARootVNode is given, create VNodesList with one element
    begin
      NewList := True;
      VNodesList := TList.Create;
      VNodesList.Add( ARootVNode );
    end else // ARootVNode is not given, use marked VNodes in N_ActiveVTreeFrame
    begin
      NewList := False;
      VNodesList := nil;
      if N_ActiveVTreeFrame <> nil then
        VNodesList := N_ActiveVTreeFrame.VTree.MarkedVNodesList;
    end;

    BuildExpObjsList( VNodesList ); // create ExpObjsList
    SetMVListObjects( ExpObjsList, false ); // add WEB Objects in ExpObjsList to Form
    Show();
  end; // with K_GetFormMVMSOExport( AOwner ) do // create TK_FormMVMSOExport if not yet

  if NewList then VNodesList.Free;
end; //*** end of procedure N_AddToMVDarExportForm


//********** TN_NVTreeFrame class methods  **************

//************************************************ TN_NVTreeFrame.Create ***
//
constructor TN_NVTreeFrame.Create( AOwner: TComponent );
begin
  Inherited;
  //***** OnMouseDownProcObj is TN_VTreeFrame field,
  //      OnMouseProcObj is Self method:
  OnMouseDownProcObj := OnMouseProcObj;

//  ClipboardDir := TN_UDBase.Create(); // used for copy/paste
//  ClipboardDir.ObjName := 'ClipboardDir';
end; //*** end of Constructor TN_NVTreeFrame.Create

destructor TN_NVTreeFrame.Destroy();
begin
  Inherited;
end; // destructor TN_NVTreeFrame.Destroy

//****************  TN_NVTreeFrame class handlers  ******************

    //************************ File Actions *************************

procedure TN_NVTreeFrame.aFileLoadBeforeExecute( Sender: TObject );
// Load UObjects from File Before Selected (on the same level as Selected UObj)
var
  TmpUObj: TN_UDBase;
begin
  if not SelectedExists() then Exit;

  K_CurArchive.RefPath := K_ArchiveCursor; // Restore Archive RefPath
  TmpUObj := N_LoadUObjFromAny( NFNameFr.GetFileName() );

  PasteUObjectsBefore( uotReference, TmpUObj, VTree.MarkedVNodesList );

  ShowStr( IntToStr(TmpUObj.DirLength()) + '  UObject(s) Loaded Before' );
  TmpUObj.UDDelete();
end; // procedure TN_NVTreeFrame.aFileLoadBeforeExecute

procedure TN_NVTreeFrame.aFileLoadInsideExecute( Sender: TObject );
// Load UObjects from File Inside Selected (as Selected UObj last Children)
var
  TmpUObj: TN_UDBase;
begin
  if not SelectedExists() then Exit;

  K_CurArchive.RefPath := K_ArchiveCursor; // Restore Archive RefPath
  TmpUObj := N_LoadUObjFromAny( NFNameFr.GetFileName() );

  VTree.Selected.VNUDObj.AddOneChildV(TmpUObj); // debug
  exit;                                        // debug
  
  PasteUObjectsInside( uotReference, TmpUObj, VTree.MarkedVNodesList );

  ShowStr( IntToStr(TmpUObj.DirLength()) + '  UObject(s) Loaded Inside' );
  TmpUObj.UDDelete();
end; //procedure TN_NVTreeFrame.aFileLoadInsideExecute

procedure TN_NVTreeFrame.aFileLoadInsteadExecute( Sender: TObject );
// Load UObjects from File Instead of Marked UObjects:
// if TmpUObj has exactly one Ref, Paste it instead of all Marked UObjects,
// otherwise Paste i-th TmpUObj Child instead of i-th  Marked UObj
var
  TmpUObj: TN_UDBase;
begin
  if not SelectedExists() then Exit;

  K_CurArchive.RefPath := K_ArchiveCursor; // Restore Archive RefPath
  TmpUObj := N_LoadUObjFromAny( NFNameFr.GetFileName() );

  PasteUObjectsInstead( uotReference, TmpUObj, VTree.MarkedVNodesList );

  ShowStr( IntToStr(TmpUObj.DirLength()) + '  UObject(s) Loaded Instead' );
  TmpUObj.UDDelete();
end; // procedure TN_NVTreeFrame.aFileLoadInsteadExecute

procedure TN_NVTreeFrame.aFileLoadFieldsExecute( Sender: TObject );
// Load from File Fields of Selected UObj
begin
  if not SelectedExists() then Exit;

  K_CurArchive.RefPath := K_ArchiveCursor; // Restore Archive RefPath
  K_SerialTextBuf.TextStrings.LoadFromFile( NFNameFr.GetFileName() );
  K_LoadFieldsFromText( VTree.Selected.VNUDObj, K_SerialTextBuf );
  ShowStr( 'UObj fields Loaded OK' );
end; // procedure TN_NVTreeFrame.aFileLoadFieldsExecute

procedure TN_NVTreeFrame.aFileSaveUObjectsExecute( Sender: TObject );
// Save All Marked UObjects To File as children of special UObjectsContainer UObj
var
  i, NumObjects: integer;
  FName: string;
  TmpUObj: TN_UDBase;
  Owners: TN_UDArray;
begin
  if VTree.Selected = nil then Exit;
  NumObjects := VTree.MarkedVNodesList.Count;
  K_CurArchive.RefPath := K_ArchiveCursor; // Restore Archive RefPath
  FName := NFNameFr.GetFileName();

  TmpUObj := TN_UDBase.Create();
  TmpUObj.ObjName := 'UObjectsContainer';
  AddVNodesRefs( VTree.MarkedVNodesList, TmpUObj );

  SetLength( Owners, NumObjects );

  for i := 0 to NumObjects-1 do // save real Owners and temporary set Owner fieled to TmpUObj
  begin
    Owners[i] := TmpUObj.DirChild( i ).Owner;
    TmpUObj.DirChild( i ).Owner := TmpUObj; // temporary, just for unloading
  end;

  N_SaveUObjAsText ( TmpUObj, FName );

  for i := 0 to NumObjects-1 do // restore real Owners
    TmpUObj.DirChild( i ).Owner := Owners[i];

  TmpUObj.UDDelete();
  ShowStr( IntToStr(NumObjects) + '  UObject(s) saved to file ' + FName );
end; // procedure TN_NVTreeFrame.aFileSaveUObjectsExecute

procedure TN_NVTreeFrame.aFileSaveFieldsExecute( Sender: TObject );
// Save Fields of Selected UObj
var
  FName: string;
begin
  if VTree.Selected = nil then Exit;

  K_CurArchive.RefPath := K_ArchiveCursor; // Restore Archive RefPath
  K_SaveFieldsToText( VTree.Selected.VNUDObj, K_SerialTextBuf );
  FName := NFNameFr.GetFileName();
  K_SerialTextBuf.TextStrings.SaveToFile( FName );
  ShowStr( 'UObj fields saved to file  ' + FName );
end; // procedure TN_NVTreeFrame.aFileSaveFieldsExecute

procedure TN_NVTreeFrame.aFileEditArchSectionParamsExecute( Sender: TObject );
// Edit Selected Archive Section Params
begin
  if not SelectedExists() then Exit;
  N_EditArchSectionParams( VTree.Selected.VNUDObj );
end; // procedure TN_NVTreeFrame.aFileEditArchSectionParamsExecute

procedure TN_NVTreeFrame.aFileLoadArchSectionsExecute( Sender: TObject );
// Load Marked Archive Sections
var
  i, NumMarked, NumLoaded: integer;
  CurSection: TN_UDBase;
  SavedMarked: TList;
begin
  with VTree do
  begin
    ChangeTreeViewUpdateMode( True );
    SavedMarked := TList.Create();          // make a copy of MarkedVNodesList, because
    SavedMarked.Assign( MarkedVNodesList ); // K_LoadCurArchiveSection clears it
    NumMarked := SavedMarked.Count;
    NumLoaded := 0;

    for i := 0 to SavedMarked.Count-1 do // along marked sections roots
    begin
      CurSection := TN_VNode(SavedMarked.Items[i]).VNUDObj;
      N_s := CurSection.ObjName; // debug

      if N_LoadArchSection( CurSection ) then
        Inc( NumLoaded );
    end; // for i := 0 to SavedMarked.Count-1 do // along marked sections roots

    ChangeTreeViewUpdateMode( False );
  end; // with VTree do

  aViewRefreshFrameExecute( nil );
  SavedMarked.Free;

  if NumMarked = NumLoaded then
  begin
    ShowStr( IntToStr( NumLoaded ) + '  Section(s) Loaded OK' );
  end else
    ShowStr( IntToStr(NumMarked-NumLoaded) + '  Section(s) was NOT Loaded !' );
end; // procedure TN_NVTreeFrame.aFileLoadArchSectionsExecute


    //************************ Edit Actions *************************

procedure TN_NVTreeFrame.aEdCreateNewUObjExecute( Sender: TObject );
// Create New UObj in Dialog using N_CreateNewUObj
var
  NewUObj: TN_UDBase;
begin
  with VTree do
  begin

  if Selected = nil then
  begin
    ShowStr( 'No Selected UObj!' );
    Exit;
  end;

// Selected and it's Parent are used for adding new UObj in proper place of DTree

  with Selected do
    NewUObj := N_CreateNewUObj( VNParent.VNUDObj, VNUDObj, SomeStatusBar );

  if NewUObj = nil then
    ShowStrAdd( ' UObj NOT Created!' )
  else
  begin
//    SetPath( RootUObj.GetRefPathToObj( NewUObj ) );
    SetPath( K_GetPathToUObj( NewUObj, RootUObj ) );
    ShowStr( NewUObj.ObjName + '  Created OK' );
  end;

  end; // with VTree do
end; // procedure TN_NVTreeFrame.aEdCreateEmptyDirExecute

procedure TN_NVTreeFrame.aEdCutMarkedExecute( Sender: TObject );
// Cut Marked UObjects to Clipboard for subsequent Pasting
// ( Copy Refs to Marked VNode's VChild to N_MEGlobObj.ClbdDir
//   and Delete them from VParent )
var
  NumDeleted: integer;
begin
  if not N_KeyIsDown( VK_Shift ) then
    N_MEGlobObj.ClbdDir.ClearChilds();

  AddVNodesRefs( VTree.MarkedVNodesList, N_MEGlobObj.ClbdDir );
  NumDeleted := DeleteVNodes( VTree.MarkedVNodesList );
  ShowStr( IntToStr(NumDeleted) + '  UObject(s) Cut OK' );
end; // procedure TN_NVTreeFrame.aEdCutMarkedExecute

procedure TN_NVTreeFrame.aEdCopyMarkedExecute( Sender: TObject );
// Copy Marked UObjects to Clipboard for subsequent Pasting
// ( Copy Refs to Marked VNode's VChild to N_MEGlobObj.ClbdDir )
begin
  if not N_KeyIsDown( VK_Shift ) then
    N_MEGlobObj.ClbdDir.ClearChilds();

  AddVNodesRefs( VTree.MarkedVNodesList, N_MEGlobObj.ClbdDir );
  K_PutVNodesListToClipBoard( VTree.MarkedVNodesList ); // Copy to RAFrame Clipboard

  ShowStr( IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + '  UObject(s) Copied OK' );
end; // procedure TN_NVTreeFrame.aEdCopyMarkedExecute

procedure TN_NVTreeFrame.aEdDeleteMarkedExecute( Sender: TObject );
// Delete Marked UObjects (from Theirs VParents)
var
  NumMarked, NumDeleted: integer;
begin
  NumMarked := VTree.MarkedVNodesList.Count;
  NumDeleted := DeleteVNodes( VTree.MarkedVNodesList );

  if NumMarked = NumDeleted then
    ShowStr( IntToStr( NumDeleted ) + '  UObject(s) Deleted OK' )
  else
    ShowStr( IntToStr(NumMarked-NumDeleted) + '  UObject(s) was NOT Deleted !' );
  SetChangeAndRedraw();
end; // procedure TN_NVTreeFrame.aEdDeleteMarkedExecute

procedure TN_NVTreeFrame.aEdEditUObjInfoExecute( Sender: TObject );
// Show/Edit UObj Info
begin
  if not SelectedExists() then Exit;

  if N_EditText( VTree.Selected.VNUDObj.ObjInfo, OwnerForm ) then
  begin
//    VTree.Selected.VNUDObj.SetChangedSubTreeFlag();
    K_SetChangeSubTreeFlags( VTree.Selected.VNUDObj );
    ShowStr( 'UObj Info set OK' );
  end;
end; // procedure TN_NVTreeFrame.aEdEditUObjInfoExecute

procedure TN_NVTreeFrame.aEdPasteRefsBeforeExecute( Sender: TObject );
// Paste Clipboard Refs Before All Marked
begin
  if not SelectedExists() then Exit;

  PasteUObjectsBefore( uotReference, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );
  SetChangeAndRedraw();
  ShowStr( IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + '  Ref(s) Pasted Before' );
end; // procedure TN_NVTreeFrame.aEdPasteRefsBeforeExecute

procedure TN_NVTreeFrame.aEdPasteRefsAfterExecute( Sender: TObject );
// Paste Clipboard Refs After All Marked
begin
  if not SelectedExists() then Exit;

  PasteUObjectsAfter( uotReference, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );
  SetChangeAndRedraw();
  ShowStr( IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + '  Ref(s) Pasted After' );
end; // procedure TN_NVTreeFrame.aEdPasteRefsAfterExecute

procedure TN_NVTreeFrame.aEdPasteRefsInsideExecute( Sender: TObject );
// Paste Clipboard Refs Inside Marked (as last children)
begin
  if not SelectedExists() then Exit;

  PasteUObjectsInside( uotReference, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );

  SetChangeAndRedraw();
  ShowStr( IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + '  Ref(s) Pasted Inside' );
end; // procedure TN_NVTreeFrame.aEdPasteRefsInsteadExecute

procedure TN_NVTreeFrame.aEdPasteRefsInsteadExecute( Sender: TObject );
// Paste Clipboard Refs Instead of Marked UObjects:
// if Clipboard has exactly one Ref, Paste it instead of all Marked UObjects,
// otherwise Paste i-th Clipboard Ref instead of i-th  Marked UObj
begin
  PasteUObjectsInstead( uotReference, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );
  SetChangeAndRedraw();
end; // procedure TN_NVTreeFrame.aEdPasteRefsInsteadExecute

procedure TN_NVTreeFrame.aEdPasteRefsAnyExecute( Sender: TObject );
// Paste Clipboard Refs Before or Inside (if Shift pressed)
// or After (if Control pressed) or Instead of all Marked (if Shift+Control pressed)
begin
  if N_KeyIsDown( VK_Shift ) and N_KeyIsDown( VK_Control ) then
    aEdPasteRefsInsteadExecute( Sender )
  else if N_KeyIsDown( VK_Shift ) then
    aEdPasteRefsInsideExecute( Sender )
  else if N_KeyIsDown( VK_Control ) then
    aEdPasteRefsAfterExecute( Sender )
  else
    aEdPasteRefsBeforeExecute( Sender );
end; // procedure TN_NVTreeFrame.aEdPasteRefsAnyExecute


procedure TN_NVTreeFrame.aEdPasteOLCBeforeExecute( Sender: TObject );
// Paste OneLevel Clones of Clipboard Refs Before All Marked
begin
  if not SelectedExists() then Exit;

  PasteUObjectsBefore( uotOneLevelClone, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );

  SetChangeAndRedraw();
  ShowStr( IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + '  OLCopi(es) Pasted Before' );
end; // procedure TN_NVTreeFrame.aEdPasteOLCBeforeExecute

procedure TN_NVTreeFrame.aEdPasteOLCAfterExecute( Sender: TObject );
// Paste OneLevel Clones of Clipboard Refs After All Marked
begin
  if not SelectedExists() then Exit;

  PasteUObjectsAfter( uotOneLevelClone, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );

  SetChangeAndRedraw();
  ShowStr( IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + '  OLCopi(es) Pasted After' );
end; // procedure TN_NVTreeFrame.aEdPasteOLCAfterExecute

procedure TN_NVTreeFrame.aEdPasteOLCInsideExecute( Sender: TObject );
// Paste OneLevel Clones of Clipboard Refs Inside All Marked
begin
  if not SelectedExists() then Exit;

  PasteUObjectsInside( uotOneLevelClone, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );

  SetChangeAndRedraw();
  ShowStr( IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + '  OLCopi(es) Pasted Inside' );
end; // procedure TN_NVTreeFrame.aEdPasteOLCInsideExecute

procedure TN_NVTreeFrame.aEdPasteOLCInsteadExecute( Sender: TObject );
// Paste OneLevel Clones of Clipboard Refs Instead of All Marked UObjects:
// if Clipboard has exactly one Ref, Paste it instead of all Marked UObjects,
// otherwise Paste i-th Clipboard Ref instead of i-th  Marked UObj
begin
  PasteUObjectsInstead( uotOneLevelClone, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );
  SetChangeAndRedraw();
end; // procedure TN_NVTreeFrame.aEdPasteOLCInsteadExecute

procedure TN_NVTreeFrame.aEdPasteOLCAnyExecute( Sender: TObject );
// Paste OneLevel Clones of Clipboard Refs Before or Inside (if Shift pressed)
// or After (if Control pressed) or Instead of all Marked (if Shift+Control pressed)
begin
  if N_KeyIsDown( VK_Shift ) and N_KeyIsDown( VK_Control ) then
    aEdPasteOLCInsteadExecute( Sender )
  else if N_KeyIsDown( VK_Shift ) then
    aEdPasteOLCInsideExecute( Sender )
  else if N_KeyIsDown( VK_Control ) then
    aEdPasteOLCAfterExecute( Sender )
  else
    aEdPasteOLCBeforeExecute( Sender );
end; // procedure TN_NVTreeFrame.aEdPasteOLCAnyExecute


procedure TN_NVTreeFrame.aEdPasteSubTreesBeforeExecute( Sender: TObject );
// Paste Clones of SubTrees with Clipboard Refs as Roots Before All Marked
begin
  if not SelectedExists() then Exit;

  PasteUObjectsBefore( uotSubTreeClone, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );

  SetChangeAndRedraw();
  ShowStr( IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + '  SubTree(s) Pasted Before' );
end; // procedure TN_NVTreeFrame.aEdPasteSubTreesBeforeExecute

procedure TN_NVTreeFrame.aEdPasteSubTreesAfterExecute( Sender: TObject );
// Paste Clones of SubTrees with Clipboard Refs as Roots After All Marked
begin
  if not SelectedExists() then Exit;

  PasteUObjectsAfter( uotSubTreeClone, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );

  SetChangeAndRedraw();
  ShowStr( IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + '  SubTree(s) Pasted After' );
end; // procedure TN_NVTreeFrame.aEdPasteSubTreesAfterExecute

procedure TN_NVTreeFrame.aEdPasteSubTreesInsideExecute( Sender: TObject );
// Paste Clones of SubTrees with Clipboard Refs as Roots Inside All Marked
begin
  if not SelectedExists() then Exit;

  PasteUObjectsInside( uotSubTreeClone, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );

  SetChangeAndRedraw();
  ShowStr( IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + '  SubTree(s) Pasted Inside' );
end; // procedure TN_NVTreeFrame.aEdPasteSubTreesInsideExecute

procedure TN_NVTreeFrame.aEdPasteSubTreesInsteadExecute( Sender: TObject );
// Paste OneLevel Clones of Clipboard Refs Instead of All Marked UObjects:
// if Clipboard has exactly one Ref, Paste it instead of all Marked UObjects,
// otherwise Paste i-th Clipboard Ref instead of i-th  Marked UObj
begin
  PasteUObjectsInstead( uotSubTreeClone, N_MEGlobObj.ClbdDir, VTree.MarkedVNodesList );
  SetChangeAndRedraw();
end; // procedure TN_NVTreeFrame.aEdPasteSubTreesInsteadExecute

procedure TN_NVTreeFrame.aEdPasteSubTreesAnyExecute( Sender: TObject );
// Paste Clones of SubTrees of Clipboard Refs as Roots Before or Inside (if Shift pressed)
// or After (if Control pressed) or Instead of all Marked (if Shift+Control pressed)
begin
  if N_KeyIsDown( VK_Shift ) and N_KeyIsDown( VK_Control ) then
    aEdPasteSubTreesInsteadExecute( Sender )
  else if N_KeyIsDown( VK_Shift ) then
    aEdPasteSubTreesInsideExecute( Sender )
  else if N_KeyIsDown( VK_Control ) then
    aEdPasteSubTreesAfterExecute( Sender )
  else
    aEdPasteSubTreesBeforeExecute( Sender );
end; // procedure TN_NVTreeFrame.aEdPasteSubTreesAnyExecute


procedure TN_NVTreeFrame.aEdForceSingleOneLevelInstanceExecute( Sender: TObject );
// Force Single OneLevel Instance for all Marked UObjects (see N_ForceSingleInstance)
var
  i: integer;
begin
  with VTree.MarkedVNodesList do
  begin
    VTree.ChangeTreeViewUpdateMode( True );

    for i := 0 to Count-1 do
      N_ForceSingleInstance( uotOneLevelClone, TN_VNode(Items[i]) );

    VTree.ChangeTreeViewUpdateMode( False );
  end; // with AVNodesList do
  ShowStr( IntToStr(VTree.MarkedVNodesList.Count) + '  UObject(s) Processed' );
end; // procedure TN_NVTreeFrame.aEdForceSingleInstanceExecute

procedure TN_NVTreeFrame.aEdForceSingleSubTreeInstanceExecute( Sender: TObject );
// Force Single SubTree Instance for all Marked UObjectes (see N_ForceSingleInstance)
var
  i: integer;
begin
  with VTree.MarkedVNodesList do
  begin
    VTree.ChangeTreeViewUpdateMode( True );

    for i := 0 to Count-1 do
      N_ForceSingleInstance( uotSubTreeClone, TN_VNode(Items[i]) );

    VTree.ChangeTreeViewUpdateMode( False );
  end; // with AVNodesList do
  ShowStr( IntToStr(VTree.MarkedVNodesList.Count) + '  UObject(s) Processed' );
end; // procedure TN_NVTreeFrame.aEdForceSingleSubTreeInstanceExecute

procedure TN_NVTreeFrame.aEdSetVisualOwnersToMarkedExecute( Sender: TObject );
// Set Visual Parent as new Owner (or Clear if Shift is Down) to all Marked UObjects
// (Set Owner field of Marked UObjects to Visual Parents or clear it)
var
  i: integer;
  ParVNode: TN_VNode;
begin
  with VTree.MarkedVNodesList do
  begin
    for i := 0 to Count-1 do
    with TN_VNode(Items[i]) do
    begin
      ParVNode := VNParent;
      if ParVNode = nil then Continue; // a precaution

      if N_KeyIsDown( VK_Shift ) then // Clear Owner
        VNUDObj.Owner := nil
      else
        VNUDObj.Owner := ParVNode.VNUDObj; // Set Owner to Visual Parent

      VNUDObj.SetChangedSubTreeFlag();
      VNUDObj.RebuildVNodes();
    end; // with TN_VNode(Items[i]) do, for i := 0 to Count-1 do
  end; // with VTree.MarkedVNodesList do

  ShowStr( IntToStr(VTree.MarkedVNodesList.Count) + '  new Owners are set' );
end; // procedure TN_NVTreeFrame.aEdSetVisualOwnersToMarkedExecute

procedure TN_NVTreeFrame.aEdClearUObjWasChangedBitExecute( Sender: TObject );
// Clear "UObjWasChanged" Bit in Self SubTree
begin
  if not SelectedExists() then Exit;

  K_ClearChangeSubTreeFlags( VTree.Selected.VNUDObj );
  TreeView.Invalidate;

  ShowStr( '"WasChanged" bit was cleared in SubTree "' +
                         VTree.Selected.VNUDObj.ObjName + '"' );
end; // procedure TN_NVTreeFrame.aEdClearUObjWasChangedBitExecute


procedure TN_NVTreeFrame.aEdUnresolveRefsInSelectedExecute( Sender: TObject );
// Unresolve (Unlink) all not Owner Refs in Selected Subtree
// (in whole Archive if Selected = nil)
// (build temporary TK_UDRef nodes and link all not Owner UDRefs to them
// instead of real nodes)
var
  SubTreeRoot: TN_UDBase;
begin
  if VTree.Selected <> nil then SubTreeRoot := VTree.Selected.VNUDObj
                           else SubTreeRoot := K_CurArchive;

  K_UnlinkDirectReferences( SubTreeRoot ); // Unlink direct references
  ShowStr( 'All Refs are Unresolved!' );
end; // procedure TN_NVTreeFrame.aEdUnresolveRefsInSelectedExecute


procedure TN_NVTreeFrame.aEdResolveRefsInSelectedExecute( Sender: TObject );
// Resolve (restore) all Refs in Selected Subtree (in whole Archive if Selected = nil)
// (replace refs to temporary TK_UDRef nodes by refs to real nodes)
var
  NumUnresolved, NumResolved: integer;
  SubTreeRoot: TN_UDBase;
begin
  if VTree.Selected <> nil then SubTreeRoot := VTree.Selected.VNUDObj
                           else SubTreeRoot := K_CurArchive;

  NumUnresolved := K_BuildDirectReferences( SubTreeRoot );
  NumResolved := K_UDTreeBuildRefControl.RRefCount;

  if NumUnresolved = 0 then
  begin
    if NumResolved = 0 then
      ShowStr( 'All Refs were already Resolved' )
    else
      ShowStr( IntToStr(NumResolved) + ' Refs are Resolved OK' )
  end else // show info about still Unresolved refs
  begin
    with N_GetInfoForm() do
    begin
      N_GetUnresRefsInfo( Memo.Lines, SubTreeRoot, [gifMaxInfo] );
      if not Visible then Show;
      ShowStr( IntToStr(NumResolved) + ' Refs Resolved, ' +
               IntToStr(NumUnresolved) + ' Refs still Unresolved!' );
    end; // with N_GetInfoForm() do
  end; // else // show info about still unresolved refs
end; // procedure TN_NVTreeFrame.aEdResolveRefsInSelectedExecute


procedure TN_NVTreeFrame.aEdClearUnresolvedRefsExecute( Sender: TObject );
// Replace all Unresolved References in Selected SubTree by nil
var
  ScanObj: TN_ScanDTreeObj;
  SubTreeRoot: TN_UDBase;
begin
  if VTree.Selected <> nil then SubTreeRoot := VTree.Selected.VNUDObj
                           else SubTreeRoot := K_CurArchive;

  ScanObj := TN_ScanDTreeObj.Create();

  with ScanObj do
  begin
//**** for Single not Owners Node Scan
//    K_UDUsedScanNodesList := TList.Create;
//    (if K_UDUsedScanNodesList <> nil then all nodes are scanned only once) 

//**** for Owner Childs Scan
//    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];

    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
    SubTreeRoot.ScanSubTree( DelUnresolved );
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];

//**** for Owner Childs Scan
//    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];

//**** for Single not Owners Node Scan
//  K_ClearScanNodesFlag();
//  FreeAndNil(K_UDUsedScanNodesList);

    ShowStr( IntToStr(NumDeleted) + '  Unresolved Ref(s) Cleared' );
    ScanObj.Free();
  end; // with ScanObj do
end; // procedure TN_NVTreeFrame.aDebClearUnresolvedRefsExecute

procedure TN_NVTreeFrame.aEdRedirectRefsExecute( Sender: TObject );
// Redirect all Refs in Marked[2] (SubTreeToChange)
//   from Marked[0] (PrevSubTree) to Marked[1] (NewSubTree)
var
  Str: string;
  SubTreeToChange, PrevSubTree, NewSubTree: TN_UDBase;
begin
  with VTree.MarkedVNodesList do
  begin
    if Count <> 3 then
    begin
      ShowStr( 'Three Roots should be marked!' );
      Exit;
    end;

    PrevSubTree     := TN_VNode(Items[0]).VNUDObj;
    NewSubTree      := TN_VNode(Items[1]).VNUDObj;
    SubTreeToChange := TN_VNode(Items[2]).VNUDObj;
  end; // with VTree.MarkedVNodesList do

  Str := 'Redirect all Refs in '#$D#$A'  "' +
                     N_GetUObjPath( SubTreeToChange, nil, 0, [] ) +
         '"'#$D#$A'  from  "' +
                     N_GetUObjPath( PrevSubTree, nil, 0, [] ) +
         '"'#$D#$A'      to  "' +
                     N_GetUObjPath( NewSubTree, nil, 0, [] ) + '"  ?';

  if N_MessageDlg( Str, mtConfirmation, mbOKCancel, 0 ) <> mrOK then
  begin
    ShowStr( 'Operation Cancelled' );
    Exit;
  end;

  K_ReplaceRefsInSubTree( SubTreeToChange, PrevSubTree, NewSubTree );

  ShowStr( 'Refs Replaced in ' + N_GetUObjPath( SubTreeToChange, nil, 0, [] ) );
end; // procedure TN_NVTreeFrame.aEdRedirectRefsExecute

procedure TN_NVTreeFrame.aEdReplaceUObjectsExecute( Sender: TObject );
// 1) Create full SubTree Clones of Marked UObjects (except two last ones),
// 2) Replace Child UObjects with same names in Marked[-2] Root by
//    newly created UObjects,
// 3) Add New UObjects (which Names are absent in Marked[-2]) as Marked[-2] children
// 4) Replace all refs to Old UObjects by Refs to New UObjects in Marked[-1] SubTree
// ( Marked[-1] means Last Marked UObject, Marked[-2] - one before last)
var
  i, NumUObjects, NumReplaced, NumAdded: integer;
  Str, CurName: string;
  ParentUObj, SubTreeToChange, OldUObj: TN_UDBase;
  NewUObjects: TN_UDArray;
begin
  with VTree.MarkedVNodesList do
  begin
    NumUObjects := Count-2;
    if NumUObjects <= 0 then
    begin
      ShowStr( 'Should be >= 3 Marked UObjects!' );
      Exit;
    end;

    ParentUObj      := TN_VNode(Items[Count-2]).VNUDObj;
    SubTreeToChange := TN_VNode(Items[Count-1]).VNUDObj;

    Str := 'Replace  ' + IntToStr(NumUObjects) +
           ' Child(s) in '#$D#$A'  "' +
                     N_GetUObjPath( ParentUObj, nil, 0, [] ) +
         '"'#$D#$A' Parent and All Refs to them in '#$D#$A'  "' +
                     N_GetUObjPath( SubTreeToChange, nil, 0, [] ) + '"  ?';

    if N_MessageDlg( Str, mtConfirmation, mbOKCancel, 0 ) <> mrOK then
    begin
      ShowStr( 'Operation Cancelled' );
      Exit;
    end;

    SetLength( NewUObjects, NumUObjects );

    for i := 0 to NumUObjects-1 do // Create UObjects Clones
      NewUObjects[i] := N_CreateSubTreeClone( TN_VNode(Items[i]).VNUDObj );

  end; // with VTree.MarkedVNodesList do

  NumReplaced := 0;
  for i := 0 to NumUObjects-1 do // Create UDBase Pairs List
  begin
    CurName := NewUObjects[i].ObjName;
    OldUObj := ParentUObj.DirChildByObjName( CurName );

    if OldUObj <> nil then
    begin
      K_RSTNAddPair( OldUObj, NewUObjects[i] );
      Inc( NumReplaced );
    end else
      ParentUObj.AddOneChildV( NewUObjects[i] );
  end; // for i := 0 to NumUObjects-1 do // Create UDBase Pairs List

  K_RSTNExecute( SubTreeToChange );

  NumAdded := NumUObjects - NumReplaced;
  ShowStr( Format( '%d UObjects Replaced, %d Added', [NumReplaced,NumAdded] ) );
end; // procedure TN_NVTreeFrame.aEdReplaceUObjectsExecute


    //************************ View Actions *************************

procedure TN_NVTreeFrame.aViewEntriesInSubTreeExecute( Sender: TObject );
// View all Entries in SubTree with Selected Root
// (Entries means UObjects, referenced from outside of SubTree)
var
  SubTreeRoot: TN_UDBase;
begin
  if not SelectedExists() then Exit;

  SubTreeRoot := VTree.Selected.VNUDObj;

  with N_GetInfoForm() do
  begin
    N_GetExtUObjects( Memo.Lines, SubTreeRoot, [gifMaxInfo] );
    if not Visible then Show;
    ShowStr( '' );
  end; // with N_GetInfoForm() do
end; // procedure TN_NVTreeFrame.aViewEntriesInSubTreeExecute

procedure TN_NVTreeFrame.aViewRefsToMarkedExecute( Sender: TObject );
// View all Refs to Marked UObjects
var
  i: integer;
begin
  with VTree.MarkedVNodesList, N_GetInfoForm() do
  begin
    for i := 0 to Count-1 do
    with TN_VNode(Items[i]) do
    begin
      N_GetRefsToUObj( Memo.Lines, VNUDObj, K_CurArchive,
                       [K_udtsRAFieldsScan,K_udtsSkipRAFieldsSubTreeScan], [gifMaxInfo,gifOwnerPath] );
    end;

    if not Visible then Show;
    ShowStr( '' );
  end; // with VTree.MarkedVNodesList, N_GetInfoForm() do
end; // procedure TN_NVTreeFrame.aViewRefsToMarkedExecute

procedure TN_NVTreeFrame.aViewRefsFromSubTreeExecute( Sender: TObject );
// View all External Refs from SubTree with Selected Root
var
  SubTreeRoot: TN_UDBase;
begin
  if not SelectedExists() then Exit;

  SubTreeRoot := VTree.Selected.VNUDObj;

  with N_GetInfoForm() do
  begin
    N_GetRefsFromSubTree( Memo.Lines, SubTreeRoot, [gifMaxInfo,gifOwnerPath] );
    if not Visible then Show;
    ShowStr( '' );
  end; // with N_GetInfoForm() do
end; // procedure TN_NVTreeFrame.aViewRefsFromSubTreeExecute

procedure TN_NVTreeFrame.aViewRefsBetweenExecute( Sender: TObject );
// View all Refs from ASrcRoot SubTree (Marked[0]) to inside of ADstRoot SubTree (Marked[1])
begin
  with VTree.MarkedVNodesList do
  begin
    if Count <> 2 then
    begin
      ShowStr( 'Two Roots should be marked!' );
      Exit;
    end;

    with N_GetInfoForm() do
    begin
      N_GetRefsBetween( Memo.Lines, TN_VNode(Items[0]).VNUDObj,
                                    TN_VNode(Items[1]).VNUDObj, [gifMaxInfo] );

      if not Visible then Show;
      ShowStr( '' );
    end; // with N_GetInfoForm() do
  end; // with VTree.MarkedVNodesList do
end; // procedure TN_NVTreeFrame.aViewRefsBetweenExecute

procedure TN_NVTreeFrame.aViewRefreshFrameExecute( Sender: TObject );
// Refresh VTreeFrame preserving all opened VNodes,
// Toggle 'View both names" mode if Shift key is down
// Toggle 'View changed UObjects" mode if Ctrl key is down
var
  s1, s2: string;
begin
  K_TreeViewsUpdateModeSet();

  FrCurStateToMemIni( ); // mainly to prepare for call to MemIniToCurState()
  VTree.VTFlags := VTree.VTFlags or K_fvSkipCurrent; // a precaution

  if N_KeyIsDown( VK_SHIFT ) then // toggle "View both names" mode
  begin
    VTree.VTFlags := VTree.VTFlags xor K_fvTreeViewObjNameAndAliase;
    FrMemIniToCurState( ); // Rebuild VTree
  end; // if N_KeyIsDown( VK_SHIFT ) then // toggle "View both names" mode

  if N_KeyIsDown( VK_CONTROL ) then  // toggle "View changed UObjects" mode
  begin
    if K_vtfsShowChangedSubTree in K_VTreeFrameShowFlags then
      K_VTreeFrameShowFlags := K_VTreeFrameShowFlags - [K_vtfsShowChangedSubTree]
    else
      K_VTreeFrameShowFlags := K_VTreeFrameShowFlags + [K_vtfsShowChangedSubTree];

    TreeView.Invalidate;
  end; // if N_KeyIsDown( VK_CONTROL ) then

  K_TreeViewsUpdateModeClear();

  s1 := '';
  if (VTree.VTFlags and K_fvTreeViewObjNameAndAliase) <> 0 then
    s1 := 'Show Aliase, ';

  s2 := '';
  if K_vtfsShowChangedSubTree in K_VTreeFrameShowFlags then
    s2 := 'Mark Changed ';

  ShowStr( 'Refreshed, ' + s1 + s2 );
end; // procedure TN_NVTreeFrame.aViewRefreshFrameExecute

procedure TN_NVTreeFrame.aViewCloseOwnedFormsExecute( Sender: TObject );
// Close all Forms, Owned by OwnerForm
begin
  OwnerForm.CloseOwnedForms();
end; // procedure TN_NVTreeFrame.aViewCloseOwnedFormsExecute

procedure TN_NVTreeFrame.aViewMoveUpExecute( Sender: TObject );
// Move selected Node Up counting nil children
// (can be used for changing Child Index!)
var
  Ind: integer;
  Path: String;
  VNode: TN_VNode;
  CurTopItem: TTreeNode;
  UDSelected, UDParent: TN_UDBase;
begin
  VNode := VTree.Selected;
  if VNode = nil then Exit;

  UDSelected := VNode.VNUDObj;
  UDParent := VNode.VNParent.VNUDObj;

  with UDParent, VTree do
  begin
    Ind := IndexOfDEField( UDSelected );
    if Ind = 0 then Exit;

    CurTopItem := TreeView.TopItem;
    MoveEntries( Ind, Ind-1 );
//    SetChangedSubTreeFlag( True );
    N_SetChildsWereChanged( UDParent );
    ChangeTreeViewUpdateMode( True );
    RebuildVNodes();
//    Path := RootUObj.GetRefPathToObj( UDSelected );
    Path := K_GetPathToUObj( UDSelected, RootUObj );
    SetPath( Path );
    TreeView.TopItem := CurTopItem;
    ChangeTreeViewUpdateMode( False );
  end; // with UDParent, VTree do
end; // procedure TN_NVTreeFrame.aViewMoveUpExecute

procedure TN_NVTreeFrame.aViewMoveDownExecute( Sender: TObject );
// Move selected Node Down counting nil children
// (can be used for changing Child Index!)
var
  Ind: integer;
  Path: String;
  VNode: TN_VNode;
  CurTopItem: TTreeNode;
  UDSelected, UDParent: TN_UDBase;
begin
  VNode := VTree.Selected;
  if VNode = nil then Exit;

  UDSelected := VNode.VNUDObj;
  UDParent := VNode.VNParent.VNUDObj;

  with UDParent, VTree do
  begin
    CurTopItem := TreeView.TopItem;
    Ind := IndexOfDEField( UDSelected );
    if Ind = DirHigh() then
      AddOneChild( nil );
    MoveEntries( Ind, Ind+1 );
//    SetChangedSubTreeFlag( True );
    N_SetChildsWereChanged( UDParent );
    ChangeTreeViewUpdateMode( True );
    RebuildVNodes();
//    Path := RootUObj.GetRefPathToObj( UDSelected );
    Path := K_GetPathToUObj( UDSelected, RootUObj );
    SetPath( Path );
    TreeView.TopItem := CurTopItem;
    ChangeTreeViewUpdateMode( False );
  end; // with UDParent, VTree do
end; // procedure TN_NVTreeFrame.aViewMoveDownExecute


    //************************ Other Actions *************************

procedure TN_NVTreeFrame.aOtherExportCompExecute( Sender: TObject );
// Open TK_FormMVMSOExport if not yet and Add all WEB Objects Marked SubTrees
begin
  N_AddToMVDarExportForm( nil, OwnerForm );
end; // procedure TN_NVTreeFrame.aOtherExpComponentExecute

procedure TN_NVTreeFrame.aOtherAlignExecute( Sender: TObject );
// Align, Move, Resize Marked Components using N_AlignForm
// now only one AlignForm
begin
  with N_MEGlobObj do
  begin
    if AlignForm = nil then
      AlignForm := N_CreateAlignForm( OwnerForm );

    if AlignForm <> nil then AlignForm.Show()
    else ShowStr( 'Failed!' );
  end; // with N_MEGlobObj do
end; // procedure TN_NVTreeFrame.aOtherAlignExecute

procedure TN_NVTreeFrame.aOtherShowVideoDevsExecute( Sender: TObject );
// Show list of available DirectShow Video Capturing devices and
// Video Compresion filters
var
  i, ErrCode: integer;
  DevNames, wrkSL: TStringList;
begin
  with N_GetMEPlainEditorForm( OwnerForm ) do
  begin
    memo.Lines.Add( '***** Video Capturing Devices:' );

    wrkSL    := TStringList.Create;
    DevNames := TStringList.Create;
    N_DSEnumFilters( CLSID_VideoInputDeviceCategory, '', DevNames, ErrCode );

    if ErrCode = 0 then // DevNames contains Capturing Devices Names
    begin
      for i := 0 to DevNames.Count-1 do // along all devices
      begin
        memo.Lines.Add( '    ' + DevNames[i] );
        N_DSEnumVideoCaps( DevNames[i], wrkSL );
        memo.Lines.AddStrings( wrkSL );
        memo.Lines.Add( '' );
      end; // for i := 0 to DevNames.Count-1 do // along all devices
    end else // error
    begin
      memo.Lines.Add( Format( '  N_DSEnumFilters Error # %d', [ErrCode] ) );
    end;

    memo.Lines.Add( '' );
    memo.Lines.Add( '    Video Compressor Filters:' );
    N_DSEnumFilters( CLSID_VideoCompressorCategory, '', DevNames, ErrCode );

    if ErrCode = 0 then // DevNames contains Video Compressors Names
      memo.Lines.AddStrings( DevNames )
    else // error
      memo.Lines.Add( Format( '  N_DSEnumFilters Error # %d', [ErrCode] ) );

    wrkSL.Free;
    DevNames.Free;

    Show();
  end; // with N_GetMEPlainEditorForm( OwnerForm ) do
end; // procedure TN_NVTreeFrame.aOtherShowVideoDevsExecute

procedure TN_NVTreeFrame.aOtherSetMarkedCSCodesExecute( Sender: TObject );
// Set incrementing CSSCodes all Comps in Marked SubTrees:
// first CS Code (a string) is asked in Dialog, others are incremented by 1 in CSS,
// (inside SubTree with one marked Root all CSCodes are the same)
var
  i: integer;
  CSCode: string;
  CSS: TK_UDDCSSpace;
begin
  CSS := nil;
  CSCode := '?';
  if not SelectedExists() then Exit;
  if not N_EditString( CSCode, 'Enter First CSCode :' ) then Exit;

  with VTree.MarkedVNodesList do
  begin
    for i := 0 to Count-1 do // loop along Marked VNodes
    with TN_VNode(Items[i]) do
    begin

      N_SetCSCodeInSubTree( VNUDObj, CSCode, PPointer(@CSS) );

      if CSS <> nil then
        CSCode := N_IncCSCode( CSS, CSCode, 1 ); // increment CSCode

    end; // with TN_VNode(Items[i]) do, for i := 0 to Count-1 do
  end; // with VTree.MarkedVNodesList do

  SetChangeAndRedraw();
  ShowStr( IntToStr(VTree.MarkedVNodesList.Count) + '  CSCodes are set' );
end; // procedure TN_NVTreeFrame.aOtherSetMarkedCSCodesExecute

procedure TN_NVTreeFrame.aOtherSetMarkedObjNamesExecute( Sender: TObject );
// Set new incrementing ObjNames to all Marked Components
var
  i, Num: integer;
  BaseName, Postfix: string;
begin
  if not SelectedExists() then Exit;
  BaseName := VTree.Selected.VNUDObj.ObjName;
  Postfix  := '1';

  if not N_EditTwoStrings( BaseName, Postfix, 'Base Name :', 'First Num :',
                                              'Enter Names pattern' ) then Exit;
  Num := StrToInt( Postfix );

  with VTree.MarkedVNodesList do
  begin
    for i := 0 to Count-1 do
      with TN_VNode(Items[i]) do
        VNUDObj.ObjName := BaseName + IntToStr( Num + i );

  end; // with VTree.MarkedVNodesList do

  aViewRefreshFrameExecute( nil );
  ShowStr( IntToStr(VTree.MarkedVNodesList.Count) + '  UObject(s) Renamed' );
end; // procedure TN_NVTreeFrame.aOtherSetMarkedObjNamesExecute

procedure TN_NVTreeFrame.aOtherShowStatisticsExecute( Sender: TObject );
// Show Statistics about Marked UObjects
var
  ScanObj: TN_ScanDTreeObj;
  SubTreeRoot: TN_UDBase;
  S: TStrings;
begin
  if VTree.Selected <> nil then SubTreeRoot := VTree.Selected.VNUDObj
                           else SubTreeRoot := K_CurArchive;

  ScanObj := TN_ScanDTreeObj.Create();

  with ScanObj do
  begin
    SubTreeRoot.ScanSubTree( CollectUObjStat );

    Inc( NumNodes ); // SubTreeRoot
    Inc( NumRefs, SubTreeRoot.DirLength() ); // SubTreeRoot children

    S := N_GetInfoForm.Memo.Lines;
    S.Clear;

    S.Add( Format( 'Number of Nodes - %d', [NumNodes] ));
    S.Add( Format( 'Number of Refs  - %d', [NumRefs] ));
    S.Add( Format( 'Number of Nodes without Children - %d', [ResInt1] ));

    ScanObj.Free();
  end; // with ScanObj do

  N_InfoForm.Show;

{
var
  S: TStrings;
  i: integer;
begin
  if not SelectedExists() then Exit;

  S := N_GetInfoForm.Memo.Lines;
  S.Clear;

  with VTree.MarkedVNodesList do
  begin

    for i := 0 to Count-1 do // loop along Marked VNodes
    with TN_VNode(Items[i]) do
      N_CollectStatistics( VChild, $FF ); //, S );

  end; // with VTree.MarkedVNodesList do

  N_InfoForm.Show;
}
end; // procedure TN_NVTreeFrame.aOtherShowStatisticsExecute

procedure TN_NVTreeFrame.aOtherMarkChildrenExecute( Sender: TObject );
// Mark marked children
var
  i, j, NumMarked: integer;
  CompList: TList;
begin
  with VTree do
  begin
    ChangeTreeViewUpdateMode( True );

    CompList := TList.Create;
    CompList.Assign( MarkedVNodesList );
    UnMarkAllVNodes();
    NumMarked := 0;

    for i := 0 to CompList.Count-1 do
    with TN_VNode(CompList.Items[i]) do
    begin
      VNTreeNode.Expand( False );

      for j := 0 to VNUDObj.DirHigh() do
      begin
        VNUDObj.DirChild( j ).LastVNode.Mark();
        Inc(NumMarked);
      end; // for j := 0 to VNUDObj.DirHigh() do

    end; // for i := 0 to CompList.Count-1 do

    CompList.Free();
    ShowStr( IntToStr(NumMarked) + '  UObject(s) Marked' );

    ChangeTreeViewUpdateMode( False );
  end; // with VTree do
end; // procedure TN_NVTreeFrame.aOtherMarkChildrenExecute

procedure TN_NVTreeFrame.aOtherShowOptionsFormExecute( Sender: TObject );
// Show MEVTree Options Form
begin
  N_GetNVTreeOptionsForm( TN_NVTreeForm(OwnerForm), OwnerForm ).Show();
end; // procedure TN_NVTreeFrame.aOtherShowOptionsFormExecute


    //************************ Special1 Actions *********************

var
  N_ClearAndSetNames: Array [0..1] of string = ( ' Clear ', ' Set ' );

procedure TN_NVTreeFrame.aSp1ChangeCObjRTExecute( Sender: TObject );
// Set or Clear "Run Time Content" Flag in Marked CObjects
// ( "Run Time Content" Flag is used for temporary (output) CObjects
//   in Coords convertion Actions )
var
  i, ActInd, NumSet, NumCleared, OldFlag, NewFlag: integer;
begin
  with VTree.MarkedVNodesList do
  begin
    NumSet := 0;
    NumCleared := 0;

    ActInd := N_GetRadioIndex( '"Run Time Content" Flag',
                               ' Action ', 0, 300, N_ClearAndSetNames );
    if ActInd = -1 then Exit; // Operation Cancelled

    for i := 0 to Count-1 do
    with TN_VNode(Items[i]) do
    begin
      if VNUDObj is TN_UCObjLayer then
      with TN_UCObjLayer(VNUDObj) do
      begin
        if VNUDObj is TN_UContours then Continue; // not applicable

        OldFlag := WFlags and N_RunTimeContent;
        NewFlag := ActInd; // 0-Clear, 1-Set,

        if (OldFlag <> 0) and (NewFlag =  0) then Inc( NumCleared );
        if (OldFlag  = 0) and (NewFlag <> 0) then Inc( NumSet );

        WFlags := WFlags and (not N_RunTimeContent); // clear
        if NewFlag <> 0 then WFlags := WFlags or N_RunTimeContent;
      end;
    end; // for i := 0 to Count-1 do

    ShowStr( Format( 'Run Time Content Flag: %d Set, %d Cleared',
                                            [NumSet, NumCleared] ) );
  end; // with VTree.MarkedVNodesList, N_GetInfoForm() do
end; // procedure TN_NVTreeFrame.aSp1ChangeCObjRTExecute

procedure TN_NVTreeFrame.aSp1ChangeCompSkipExecute( Sender: TObject );
// Set or Clear "Skip Execute" Flag in Marked Components
var
  i, ActInd, NumSet, NumCleared, NewFlag: integer;
begin
  with VTree.MarkedVNodesList do
  begin
    NumSet := 0;
    NumCleared := 0;

    ActInd := N_GetRadioIndex( '"Skip Execute" Flag',
                               ' Action ', 0, 300, N_ClearAndSetNames );
    if ActInd = -1 then Exit; // Operation Cancelled

    for i := 0 to Count-1 do
    with TN_VNode(Items[i]) do
    begin
      if VNUDObj is TN_UDCompVis then
      with TN_UDCompVis(VNUDObj).PSP()^.CCompBase do
      begin
        NewFlag := ActInd; // 0-Clear, 1-Set,

        if (CBSkipSelf <> 0) and (NewFlag = 0)  then Inc( NumCleared );
        if (CBSkipSelf = 0)  and (NewFlag <> 0) then Inc( NumSet );

        CBSkipSelf := NewFlag;
      end;
    end; // for i := 0 to Count-1 do

    ShowStr( Format( 'Skip Execute Flag: %d Set, %d Cleared',
                                            [NumSet, NumCleared] ) );
  end; // with VTree.MarkedVNodesList, N_GetInfoForm() do

  if N_ActiveRFrame <> nil then
    N_ActiveRFrame.RedrawAllAndShow();

end; // procedure TN_NVTreeFrame.aSp1ChangeCompSkipExecute

var
  N_FieldActNames: array [0..1] of string = ( 'View Info', 'Clear fields' );

procedure TN_NVTreeFrame.aSp1ViewClearRAFieldsExecute( Sender: TObject );
// View or Clear Not Empty UDRArray RAFields with given Name
// in Slected SubTree or in whole Archive is Selected = nil
var
  SL: TStrings;
  ScanObj: TN_ScanDTreeObj;
  SubTreeRoot: TN_UDBase;
  ParamsForm: TN_EditParamsForm;
begin
  if VTree.Selected <> nil then SubTreeRoot := VTree.Selected.VNUDObj
                           else SubTreeRoot := K_ArchsRootObj;

  ParamsForm := N_CreateEditParamsForm( 300 );
  with ParamsForm do
  begin
    Caption := ' Field Name and Action:';
    AddHistComboBox( 'Field Name :', 'EdParamsHist' );
    EPControls[0].CRFlags := [ctfActiveControl, ctfExitOnEnter];
    AddRadioGroup( ' Action to perform ', N_FieldActNames, 0 );

    ShowSelfModal();

    if ModalResult <> mrOK then
    begin
      Release; // Free ParamsForm
      Exit;
    end;

    ScanObj := TN_ScanDTreeObj.Create();
    ScanObj.ParStr1 := EPControls[0].CRStr; // Field Name
    ScanObj.ParInt1 := EPControls[1].CRInt; // =0 - View, =1 - Clear

    Release; // Free ParamsForm
  end; // with ParamsForm do

  N_GetTextEditorForm( OwnerForm, SL );

  with ScanObj do
  begin
    ResSL := TStringList.Create;
    ResSL.Add( '   List of "' + ParStr1 + '" fields in "' +
                                       SubTreeRoot.ObjName + '" SubTree:' );
    ResSL.Add( '' );
    ParUObj1 := SubTreeRoot;
    ResInt2 := -1;
    RAFieldFunc := ViewClearRAFields;

    SubTreeRoot.ScanSubTree( ScanUDRArrays );

    SL.AddStrings( ResSL );

    if ScanObj.ParInt1 = 0 then // View Mode
      ShowStr( IntToStr(ResInt1) + ' fields found' )
    else // Clear Mode
      ShowStr( IntToStr(ResInt1) + ' fields cleared' );

    ResSL.Free;
    ScanObj.Free();
  end; // with ScanObj do

end; // procedure TN_NVTreeFrame.aSp1ViewClearRAFieldsExecute


    //************************ Debug Actions *************************

procedure TN_NVTreeFrame.aDebViewMarkedExecute( Sender: TObject );
// View List of Marked UObjects
var
  i: integer;
  Str: string;
  SL: TStrings;
  CompList: TList;
begin
  N_GetTextEditorForm( OwnerForm, SL );
  SL.Clear();

  CompList := VTree.MarkedVNodesList;
  SL.Add( '  ' + IntToStr(CompList.Count) + ' Marked UObjects (ObjName, ObjAliase):' );
  SL.Add( '' );

  for i := 0 to CompList.Count-1 do
  with TN_VNode(CompList.Items[i]) do
  begin
    Str := Format( '%.3d) ', [i] );
    if N_KeyIsDown( VK_SHIFT ) then
      Str := Str + Format( '%8.0n bytes ', [1.0*N_GetOSTSize( VNUDObj )] );

    Str := Str + VNUDObj.ObjName;
    if VNUDObj.ObjAliase <> '' then
      Str := Str + ', ' + VNUDObj.ObjAliase;

    SL.Add( Str );
  end;
end; // procedure TN_NVTreeFrame.aDebViewMarkedExecute

procedure TN_NVTreeFrame.aDebViewClipboardExecute( Sender: TObject );
// View List of UObjects in Clipboard (after Cut or Copy)
var
  i: integer;
  SL: TStrings;
begin
  N_GetTextEditorForm( OwnerForm, SL );
  SL.Clear();
  SL.Add( '  ' + IntToStr(N_MEGlobObj.ClbdDir.DirLength()) + ' UObjects in Clipboard (ObjName, ObjAliase):' );
  SL.Add( '' );

  for i := 0 to N_MEGlobObj.ClbdDir.DirHigh() do
    with N_MEGlobObj.ClbdDir.DirChild(i) do
      SL.Add( Format( '%.3d) %s, %s', [i, ObjName, ObjAliase] ));
end; // procedure TN_NVTreeFrame.aDebViewClipboardExecute

procedure TN_NVTreeFrame.aDebViewRefsToMarkedExecute( Sender: TObject );
// View all Refs (as OwnerPaths) to Marked UObjects:
var
  i: integer;
  SL: TStrings;
  SL2: TStringList;
  CompList: TList;
  NameType: TK_UDObjNameType;
begin
  N_GetTextEditorForm( OwnerForm, SL );
  CompList := VTree.MarkedVNodesList;
  SL2 := TStringList.Create();

  if N_MEGlobObj.AliasesInPaths then NameType := K_ontObjUName
                                else NameType := K_ontObjName;

  N_p := @NameType;
  SL.Clear();
  SL.Add( '*** OwnerPaths of Refs To Marked :' );
  SL.Add( '' );

  for i := 0 to CompList.Count-1 do // along all Marked UObjects
  with TN_VNode(CompList.Items[i]) do
  begin
    SL2.Clear();

//    K_MainRootObj.GetPathsListToObj( [K_plfSorted], VChild, SL2, NameType );

    SL.Add( Format( '%.2d *** Refs to %s :', [SL2.Count, VNUDObj.ObjName] ) );
    SL.AddStrings( SL2 );

    SL.Add( '' );
  end; // for i := 0 to CompList.Count-1 do // along all Marked UObjects

  SL2.Free;
end; // procedure TN_NVTreeFrame.aDebViewRefsToMarkedExecute

procedure TN_NVTreeFrame.aDebViewTwoExtRefsListsExecute( Sender: TObject );
// View two External Refs. Lists for each Marked UObj:
// List of all Refs. from inner UObjects (Child and RArray fields) to outer UObjects
// List of all Refs. from outer UObjects (Child and RArray fields) to inner UObjects
// (inner UOBjects - all UOBjects that have Marked Root as Owner of some level)
// (outer UOBjects - all other UObects)
var
  i, j, k: integer;
  SL: TStrings;
  CompList: TList;
  WrkObj: TK_ScanUDSubTree;
begin
  WrkObj := TK_ScanUDSubTree.Create();
  with WrkObj do
  begin

  N_GetTextEditorForm( OwnerForm, SL );
  CompList := VTree.MarkedVNodesList;

  SL.Clear();
  SL.Add( '  ' + IntToStr(CompList.Count) + ' Marked UObjects' );
  SL.Add( '' );

  for i := 0 to CompList.Count-1 do // along all Marked UObjects
  with TN_VNode(CompList.Items[i]) do
  begin
    BuildEERefNodesLists( VNUDObj ); // build both lists
    SL.Add( Format( '%.2d *** %s ExtRefNodes :', [i, VNUDObj.ObjName] ) );

    for j := 0 to ParentNodes.Count-1 do
      with TN_UDBase(ParentNodes.Items[j]) do begin
        SL.Add( '  ' + ObjName );
        for k := 0 to TStrings(ParentLPaths[j]).Count - 1 do
          SL.Add( '      ' + TStrings(ParentLPaths[j])[k] );
      end;

    SL.Add( '' );
    SL.Add( Format( '%.2d *** %s EntryRefNodes :', [i, VNUDObj.ObjName] ) );

    for j := 0 to ParentNodes.Count-1 do
      with TN_UDBase(EntryNodes.Items[j]) do
        SL.Add( '  ' + ObjName );

    SL.Add( '' );
    SL.Add( '' );
  end; // for i := 0 to CompList.Count-1 do // along all Marked UObjects

  end; // with WrkObj do
  WrkObj.Free();
end; // procedure TN_NVTreeFrame.aDebViewTwoExtRefsListsExecute

procedure TN_NVTreeFrame.aDebViewRefsInSelectedExecute( Sender: TObject );
// View All Refs in Selected SubTree (OST, дерево владения, скелетное дерево):
// for each UObj from OST show all UDRefs from it to any UDBase
// (Selected UObj is OST root)
var
  SL: TStrings;
  ScanObj: TN_ScanDTreeObj;
  SubTreeRoot: TN_UDBase;
begin
  if VTree.Selected <> nil then SubTreeRoot := VTree.Selected.VNUDObj
                           else SubTreeRoot := K_ArchsRootObj;

  ScanObj := TN_ScanDTreeObj.Create();
  N_GetTextEditorForm( OwnerForm, SL );

  with ScanObj do
  begin
    ResSL := TStringList.Create;
    ResSL.Add( '   List of RefPaths to All Owners of ' +
                                 SubTreeRoot.ObjName + ' SubTree UObjects :' );
    ResSL.Add( '(ChildInd, ChildLevel, (FieldName), Reversed RefPath)' );
    ResSL.Add( '' );

    SubTreeRoot.ScanSubTree( ViewOST );
    SL.AddStrings( ResSL );
    ResSL.Free;
    ScanObj.Free();
  end; // with ScanObj do
end; // procedure TN_NVTreeFrame.aDebViewRefsInSelectedExecute

procedure TN_NVTreeFrame.aDebViewUnresolvedRefsExecute( Sender: TObject );
// Try to restore Unresolved Refs, View remaining Unresolved Refs in Selected SubTree
// and Add Refs to UDVectors (in Selected SubTree) from appropriate CSS.Vectors
// if they are absent
var
  SL1: TStrings;
  SL2: TStringList;
  Root: TN_UDBase;
begin
  if VTree.Selected <> nil then
    Root := VTree.Selected.VNUDObj
  else
    Root := K_ArchsRootObj;

  N_GetTextEditorForm( OwnerForm, SL1 );
  SL1.Clear();

  SL2 := TStringList.Create;
  SL2.Sorted := false;

  K_BuildDirectReferences( Root );
//  Root.RefPath := K_udpDelimeter;
//!!!  Root.BuildSubTreeRefObjsList( SL2 );
//  K_ClearSubTreeRefInfo( Root, True );
  K_ClearArchiveRefInfo;

  SL1.Add( IntToStr(SL2.Count) + '  Unresolved References in  ' + Root.ObjName + '  SubTree :' );
  SL1.Add( '' );

  SL2.Sort;
  SL1.AddStrings( SL2 );
  SL2.Free;

{
  UDVCSSRefsBuilder : TK_BuildUDVCSSRefs;

  //***** Add Refs to UDVectors from appropriate CSS.Vectors - not more needed?
  if not (K_gcfRefIndIgnore in K_UDGControlFlags) then
  begin
    UDVCSSRefsBuilder := TK_BuildUDVCSSRefs.Create;
    UDVCSSRefsBuilder.BuildRefs( Root );
    UDVCSSRefsBuilder.Free
  end;
}
end; // procedure TN_NVTreeFrame.aDebViewUnresolvedRefsExecute

procedure TN_NVTreeFrame.aDebCheckArchConsistencyExecute( Sender: TObject );
// Check Archive Consistency:
// - check all UDBase.RefCounter fields
// - show some staistics about Archive
var
  SL: TStrings;
  ScanObj: TN_ScanDTreeObj;
begin
  ScanObj := TN_ScanDTreeObj.Create();

  with ScanObj do
  begin
    ResSL := TStringList.Create;
    ResSL.Add( '   List of UObjNames with bad RefCounter :' );
    ResSL.Add( '(Calculated RefCounter, UObj.RefCounter, Reversed RefPath)' );
    ResSL.Add( '' );
    ResSL.Add( '' );

    //*** Now Refs to Owner some Levels Up are not counted (e.g. in SPL modules)
    //    because of ScanSubTree implementation !

    K_ArchsRootObj.ScanSubTree( PrepareOST );
    K_ArchsRootObj.ScanSubTree( CalcRefsInOST );
    K_ArchsRootObj.ScanSubTree( CheckRefsInOST );

    if NumErrors > 0 then
    begin
      ResSL.Insert( 3, Format( 'NumErrors=%d, NumRefs=%d, NumNodes=%d',
                                             [NumErrors, NumRefs, NumNodes] ));
      N_GetTextEditorForm( OwnerForm, SL );
      SL.AddStrings( ResSL );
      ShowStr( 'Some Errors!' );
    end else
      ShowStr( 'Archive is OK!' );

    K_ArchsRootObj.ScanSubTree( UnmarkOST );
    ResSL.Free;
    ScanObj.Free();
  end; // with ScanObj do
end; // procedure TN_NVTreeFrame.aDebCheckArchConsistencyExecute

procedure TN_NVTreeFrame.aDebCheckProjectExecute( Sender: TObject );
// Check Delphi Project Consistancy
begin
  K_CheckDPRUses();
end; // procedure TN_NVTreeFrame.aDebCheckProjectExecute

procedure TN_NVTreeFrame.aDebViewCompCoordsExecute( Sender: TObject );
// View Selected Component Coords in all units in TextEditor window
// (for finding errors in CompCoords)
var
  ParentWidth, ParentHeight: double;
  PP: TPoint;
  DP: TDPoint;
  PixRect, ScopePixRect: TRect;
  SL: TStrings;
  UObj: TN_UDBase;
  CurComp: TN_UDCompVis;
begin
  UObj := VTree.Selected.VNUDObj;
  if not (UObj is TN_UDCompVis) then Exit;
  if not (UObj.Owner is TN_UDCompVis) then Exit; // not needed for VCTree Root component
  CurComp := TN_UDCompVis(UObj);
  CurComp.SetSizeUnitsCoefs();

  N_GetTextEditorForm( OwnerForm, SL );
  SL.Clear();
  SL.Add( '   ' + CurComp.ObjName + ' Component Coords:' );
  if N_ActiveRFrame = nil then
    SL.Add( '   (No ActiveRFrame!)' );

  PixRect := CurComp.CompIntPixRect;
  SL.Add( ' Self  PixRect = ' + N_RectToStr( PixRect ) );
  SL.Add( ' Self  PixSize = ' + N_PointToStr( N_RectSize(PixRect) ) );
  SL.Add( '' );

  ScopePixRect := CurComp.ScopePixRect;
  if ScopePixRect.Left = N_NotAnInteger then
  begin
    SL.Add( 'Scope Rect is not defined for Root Component' );
    Exit;
  end;

  SL.Add( 'Scope Rect = ' + N_RectToStr( ScopePixRect ) );
  SL.Add( 'Scope Size = ' + N_PointToStr( N_RectSize(ScopePixRect) ) );

  //***** PP and DP means PixelPoint DoublePoint and used as working variables

  //***** Add to SL BasePoint Coords in different units

  PP.X := PixRect.Left - ScopePixRect.Left;
  PP.Y := PixRect.Top  - ScopePixRect.Top;

  SL.Add( 'BP Pix     Coords =   ' + N_PointToStr( PP ) );

  ParentWidth  := N_RectWidth( ScopePixRect );
  ParentHeight := N_RectHeight( ScopePixRect );

  if (ParentWidth = 0) or (ParentHeight = 0) then
  begin
    SL.Add( 'Scope Size = 0 !!!' );
    Exit;
  end;

  DP.X := 100*PP.X / ParentWidth;
  DP.Y := 100*PP.Y / ParentHeight;
  SL.Add( 'BP Percent Coords = ' + N_PointToStr( DP ) );

  with CurComp.NGCont, CurComp.NGCont.DstOcanv do
  begin
    DP.X := PP.X / CurLSUPixSize;
    DP.Y := PP.Y / CurLSUPixSize;
    SL.Add( 'BP  LSU    Coords = ' + N_PointToStr( DP ) );

    DP.X := PP.X / mmPixSize.X;
    DP.Y := PP.Y / mmPixSize.Y;
    SL.Add( 'BP millim. Coords = ' + N_PointToStr( DP ) );
    SL.Add( '' );

    //***** Add to SL Component Size in different units

    PP := N_RectSize( PixRect );
    SL.Add( ' Size in pixels   = ' + N_PointToStr( PP ) );

    DP.X := 100*PP.X / ParentWidth;
    DP.Y := 100*PP.Y / ParentHeight;
    SL.Add( ' Size in Percents = ' + N_PointToStr( DP ) );

    DP.X := PP.X / CurLSUPixSize;
    DP.Y := PP.Y / CurLSUPixSize;
    SL.Add( ' Size in  LSU     = ' + N_PointToStr( DP ) );

    DP.X := PP.X / mmPixSize.X;
    DP.Y := PP.Y / mmPixSize.Y;
    SL.Add( ' Size in millim.  = ' + N_PointToStr( DP ) );
  end; // with CurComp.NGCont do

end; // procedure TN_NVTreeFrame.aDebViewCompCoordsExecute

procedure TN_NVTreeFrame.aDebTmpAction1Execute( Sender: TObject );
// Temporary Action #1
begin
{
var
  RFInitParams: TN_RFInitParams;
  RFCoordsState: TN_RFCoordsState;
  ParamsName: string;
begin
  // View Selected Component
  if not SelectedExists() then Exit;

  RFInitParams  := N_DefRFInitParams;
  RFCoordsState := N_DefRFCoordsState;

  ParamsName := 'a1';
  if N_EditString( ParamsName, 'View Params Name' ) then
    N_MemIniToSPLVal( 'Tmp', ParamsName, RFCoordsState, N_SPLTC_RFCoordsState );

  if N_ActiveRFrame <> nil then
    N_ActiveRFrame.GetCoordsState( @RFCoordsState );

  N_CreateRast1BaseForm( TN_UDCompVis(VTree.Selected.VNUDObj), @RFInitParams,
                         @RFCoordsState, @N_Rast1BaseForm, OwnerForm );

  N_Rast1BaseForm.RFrame.RedrawAllAndShow();
  N_Rast1BaseForm.Show();

}
{
  N_GetStrByComboBox( 'Scale coefs in %', 'Left Top Right Bottom :',
                                                            'NLConvF_Scale' );
  N_b := K_CheckTextPattern( 'CCompBase', 'WD*', False );
  N_b := K_CheckTextPattern( 'CLayout', 'WD*', False );
  N_s := K_SPLValueToString( TK_UDRArray(VTree.Selected.VNUDObj).R.P()^,
                             K_GetTypeCode( 'TN_RMapLayer' ) );

  N_s1 := '***';
  N_s1 := 'Yes 123';

  N_PC := PChar(N_s1);
  N_b := N_CharsToBool( N_PC );
  N_s1[1] := N_PC^;
  N_b := N_StrToBool( '' );
  N_b := N_StrToBool( 'Д' );
  N_b := N_StrToBool( '0' );

var
  WrkSl: TStringList;
  WrkSl := TStringList.Create;
  N_AddHTMLFragm( WrkSl, htmltBeg );
  N_AddHTMLFragm( WrkSl, htmltPara );
  N_AddHTMLFragm( WrkSl, htmltPara );
  N_AddHTMLFragm( WrkSl, htmltEnd );

  N_ViewHTMLStrings( WrkSl, @N_MEGlobObj.WebBrForm, OwnerForm );

  WrkSl.Free;
}
end; // procedure TN_NVTreeFrame.aDebTmpAction1Execute

procedure TN_NVTreeFrame.aDebTmpAction2Execute( Sender: TObject );
// Temporary Action #2
var
  WrkCoordsState: TN_RFCoordsState;
  ParamsName: string;
begin
  // Save current ViewParams
  if N_ActiveRFrame = nil then Exit;
  ParamsName := 'a1';
  if not N_EditString( ParamsName, 'View Params Name' ) then Exit;

  N_ActiveRFrame.GetCoordsState( @WrkCoordsState );
  N_SPLValToMemIni( 'Tmp', ParamsName, WrkCoordsState, N_SPLTC_RFCoordsState );

//  WrkCoordsState := N_DefRFCoordsState;
//  N_MemIniToSPLVal( 'Tmp', ParamsName, WrkCoordsState, N_SPLTC_RFCoordsState );
end; // procedure TN_NVTreeFrame.aDebTmpAction2Execute

procedure TN_NVTreeFrame.aDebTmpAction3Execute( Sender: TObject );
begin
{
// Temporary Action #3
var
  DLeng: Integer;
  VectName: string;
  UObj: TN_UDBase;
//  UDTab: TK_UDMVTable;
  MVQ: TK_MVQRVectors;
  UDVector: TK_UDVector;
  Args, Funcs, MRatings: TN_DArray;
  VInds, TPUnits: TN_IArray;
  ItemNames: TN_SArray;
begin
  if not SelectedExists() then Exit;

  UObj := VTree.Selected.VNUDObj;
  if not (UObj is TK_UDMVTable) then
  begin
    ShowStr( 'Is not a DataTable!' );
    Exit;
  end;

  MVQ := TK_MVQRVectors.Create();

  with MVQ do
  begin
    AddVectors( [], UObj );
    UDVector := TK_UDMVTable(UObj).GetUDVector( 0 );
    SetQCS( UDVector.GetDCSSpace().GetDCSpace() );
    SetCurElem( 49 ); // Mosc. Obl

    VectName := GetIndicatorKey( 0 );

    with UDVector.GetDCSSpace do
    begin
      DLeng := PDRA^.ALength;
      SetLength( ItemNames, DLeng );
            K_MoveSPLVectorBySIndex( ItemNames[0], SizeOf(string),
           (TK_PDCSpace(GetDCSpace.R.P).Names.P)^, SizeOf(string),
           DLeng, Ord(nptString), [], PInteger(DP) );
    end; // with Vectors[0].GetDCSSpace do

    SetLength( Args, QVNum );
    GetVETStamps( @Args[0] );

    SetLength( Funcs, QVNum );
    GetVEValues( @Funcs[0] );

    SetLength( MRatings, QVNum );
    GetVERatings( @MRatings[0] );

    SetLength( VInds, QVNum );
    GetVEVInds( @VInds[0] );

    SetLength( TPUnits, QVNum );
    GetVETTypes( @TPUnits[0] );

    Free;
  end; // with MVQ do
  ShowStr( '*** OK! ***' );
}
end; // procedure TN_NVTreeFrame.aDebTmpAction3Execute


    //************************ Deb2 Actions *************************

procedure TN_NVTreeFrame.aDeb2RunWMacroExecute( Sender: TObject );
// Run Word Macro
var
  ParamsForm: TN_EditParamsForm;
  TmpGC: TN_GlobCont;
begin
  ParamsForm := N_CreateEditParamsForm( 300 );
  with ParamsForm do
  begin
    Caption := 'Choose Word Macro to Run:';
    AddHistComboBox( 'Macro Name', 'WMacro' );
    AddCheckBox( 'Close Word Server', True );

    ShowSelfModal();

    if ModalResult <> mrOK then
    begin
      Release; // Free ParamsForm
      Exit;
    end;

    TmpGC := TN_GlobCont.Create;
    with TmpGC do
    begin
      DefWordServer();

      if not GCProperWordIsAbsent then // Word Server is OK
      begin
        GCMSWordMode := True;
        RunWordMacro( EPControls[0].CRStr );
        if GCWSWasCreated and EPControls[0].CRBool then GCWordServer.Quit;
      end else // if not GCProperWordIsAbsent then // Word Server is OK
        N_ShowInfoDlg( 'Not a proper Word' );

      Free; // free TmpGC
    end; // with TmpGC do

    Release; // Free ParamsForm
  end; // with ParamsForm do
end; // procedure TN_NVTreeFrame.aDeb2RunWMacroExecute


//****************  TN_NVTreeFrame class public methods  ************

//***********************************  TN_NVTreeFrame.OnMouseProcObj  ******
// OnMouseDownProcObj for Self.GetUObjFrame
//
procedure TN_NVTreeFrame.OnMouseProcObj( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState );
begin
  if AVNode = nil then
    AVNode := VTree.Selected;

  if AVNode <> nil then
  with N_MenuForm.frUObjCommon do
  begin
    UObjVNode := AVNode;
    UObj := AVNode.VNUDObj;
    SomeStatusBar := Self.SomeStatusBar;
    ParentUObj := AVNode.VNParent.VNUDObj;
    K_RAFUDRefDefPathObj := UObj; // initially Selected UObj while Editing TN_UDBase field

    if Button = mbRight then // Show PopUp Menu or call needed OnRightClick Action
    begin

      if N_KeyIsDown( N_VKShift ) then // Shift key is Pressed
      begin
        if Assigned(OnClickShiftAction) then OnClickShiftAction( nil );
      end else if N_KeyIsDown( N_VKControl ) then // Control key is Pressed
      begin
        if Assigned(OnClickCtrlAction) then OnClickCtrlAction( nil );
      end else // both Shift and Control keys are Up, Show PopUp Menu
      begin
        N_MenuForm.frUObjCommon.SetPopupMenuCaptionsByUObj();
        SomeStatusBar.SimpleText := 'Choose Action for ' + UObj.ObjName;

        with Mouse.CursorPos do
          N_MenuForm.UObjPopupMenu.Popup( X, Y );
      end;

    end else if Button = mbLeft then // process Mouse Click
    begin
      MarkedChanged := True; // "MarkedList changed" flag

      if N_ActiveRFrame <> nil then
        with N_ActiveRFrame do
          if gcdfShowMarked in NGlobCont.GCDebFlags then
            RedrawAllAndShow();

      if ssDouble in Shift then
        if Assigned(OnDoubleClickAction) then OnDoubleClickAction( nil );
    end; // else if (Button = mbLeft)

  end; // with GetUObjFrame do, if VNode <> nil then
end; // end of procedure TN_NVTreeFrame.OnMouseProcObj

//***********************************  TN_NVTreeFrame.CurArchiveChanged  ******
// Update all needed Self fields after current Archive was changed
//
procedure TN_NVTreeFrame.CurArchiveChanged();
begin
  if VTree <> nil then VTree.Delete();
  VTree := TN_VTree.Create( TreeView, K_CurArchive );

  VTree.SetPath( 'MapEditor' );
end; // end of procedure TN_NVTreeFrame.CurArchiveChanged

//***********************************  TN_NVTreeFrame.AddVNodesRefs  ******
// Add Unique Refs to VChild of given List of VNodes to given ADir
// (if some Ref was previously added. it would be not added again)
//
procedure TN_NVTreeFrame.AddVNodesRefs( AVNodesList: TList; ADir: TN_UDBase );
var
  i: integer;
begin
  with AVNodesList do
  begin

    for i := 0 to Count-1 do
    with TN_VNode(Items[i]) do
    begin
      if ADir.IndexOfDEField( VNUDObj ) = -1 then // VChild is not in ADir
      begin
        ADir.AddOneChild( VNUDObj );
//        ADir.SetChangedSubTreeFlag( True );
        N_SetChildsWereChanged( ADir );
      end;
    end; // with TN_VNode(Items[i]) do, for i := Count-1 downto 0 do,

  end; // with AVNodesList do
end; // end of procedure TN_NVTreeFrame.AddVNodesRefs

//***********************************  TN_NVTreeFrame.SelectedExists  ******
// Check if some VNode is Selected
//
function TN_NVTreeFrame.SelectedExists(): boolean;
begin
  Result := False;
  if VTree.Selected = nil then
  begin
    ShowStr( 'No Selected UObj!' );
    Exit;
  end;
  Result := True;
end; // end of function TN_NVTreeFrame.SelectedExists

//**********************************  TN_NVTreeFrame.SetChangeAndRedraw  ******
// Set "MarkedList changed" flag and Redraw N_ActiveRFrame if needed
//
procedure TN_NVTreeFrame.SetChangeAndRedraw();
begin
  MarkedChanged := True; // set "MarkedList changed" flag

  if not SkipAutoRedraw then
    N_ActiveRFrame.RedrawAllAndShow();
end; // end of procedure TN_NVTreeFrame.SetChangeAndRedraw

//*********************************  TN_NVTreeFrame.CreateSubTreeClone1  ******
// Create and return SubTree Clone and Increment CSCodes by given AIncValue if needed
//
function TN_NVTreeFrame.CreateSubTreeClone1( AUDBase: TN_UDBase;
                                              AIncValue: integer ): TN_UDBase;
begin
  Result := N_CreateSubTreeClone( AUDBase );

  if N_MEGlobObj.AutoIncCSCodes then
    N_IncCSCodesInSubTree( Result, AIncValue );
end; // end of function TN_NVTreeFrame.CreateSubTreeClone1

//*********************************  TN_NVTreeFrame.PasteUObjectsBefore  ******
// Paste given UObjects (all children of given ADir) of given AUObjType
// Before all VChilds of given AMarked List,
// all Pasted UObjects will be the only marked UObjects
//
procedure TN_NVTreeFrame.PasteUObjectsBefore( AUObjType: TN_UObjType;
                                       ADir: TN_UDBase; AMarked: TList );
var
  i, j, iMax, BaseChildInd: integer;
  NewChild, GivenChild, NewParent: TN_UDBase;
  SavedMarked: TList;
begin
  NewChild := nil; // to avoid warning
  SavedMarked := TList.Create(); // make a copy of AMarked, because
  SavedMarked.Assign( AMarked ); // UnMarkAllVNodes() may clear AMarked List

  with VTree do
  begin
    ChangeTreeViewUpdateMode( True );
    UnMarkAllVNodes();
    iMax := ADir.DirHigh();

    for j := 0 to SavedMarked.Count-1 do
    with TN_VNode(SavedMarked.Items[j]) do
    begin
      NewParent := VNParent.VNUDObj;
      BaseChildInd := NewParent.IndexOfDEField( VNUDObj );

      for i := iMax downto 0 do // along ADir Children in reverse order
      begin
        GivenChild := ADir.DirChild( i );

        case AUObjType of
          uotReference:     NewChild := GivenChild;
          uotOneLevelClone: NewChild := N_CreateOneLevelClone( GivenChild );
          uotSubTreeClone:  NewChild := CreateSubTreeClone1( GivenChild, j+1 );
        end; // case AUObjType of

        if NewChild.Owner = ADir then
          NewChild.Owner := NewParent;

        if AUObjType <> uotReference then
//          NewParent.SetUniqObjName( NewChild ); // Name(ind) variant
          NewChild.ObjName := N_CreateUniqueUObjName( NewParent, NewChild.ObjName );

        NewParent.InsOneChild( BaseChildInd, NewChild );
        NewParent.AddChildVnodes( BaseChildInd );
//        NewParent.SetChangedSubTreeFlag( True );
        N_SetChildsWereChanged( NewParent );
        NewChild.LastVNode.Mark();
      end; // for i := iMax down to 0 do

    end; // for j := 0 to SavedMarked.Count-1 do

    ChangeTreeViewUpdateMode( False );
  end; // with VTree do
  SavedMarked.Free;
end; // end of procedure TN_NVTreeFrame.PasteUObjectsBefore

//*********************************  TN_NVTreeFrame.PasteUObjectsAfter  ******
// Paste given UObjects (all children of given ADir) of given AUObjType
// After all VChilds of given AMarked List,
// all Pasted UObjects will be the only marked UObjects
//
procedure TN_NVTreeFrame.PasteUObjectsAfter( AUObjType: TN_UObjType;
                                       ADir: TN_UDBase; AMarked: TList );
var
  i, j, iMax, BaseChildInd, BaseCIMax: integer;
  InsertBefore: boolean;
  NewChild, GivenChild, NewParent: TN_UDBase;
  SavedMarked: TList;
begin
  NewChild := nil; // to avoid warning
  SavedMarked := TList.Create(); // make a copy of AMarked, because
  SavedMarked.Assign( AMarked ); // UnMarkAllVNodes() may clear AMarked List

  with VTree do
  begin
    ChangeTreeViewUpdateMode( True );
    UnMarkAllVNodes();
    iMax := ADir.DirHigh();

    for j := 0 to SavedMarked.Count-1 do
    with TN_VNode(SavedMarked.Items[j]) do
    begin
      NewParent := VNParent.VNUDObj;
      BaseCIMax := NewParent.DirHigh();
      BaseChildInd := NewParent.IndexOfDEField( VNUDObj );
      InsertBefore := BaseChildInd < BaseCIMax;

      for i := 0 to iMax do // along ADir Children
      begin
        GivenChild := ADir.DirChild( i );

        case AUObjType of
          uotReference:     NewChild := GivenChild;
          uotOneLevelClone: NewChild := N_CreateOneLevelClone( GivenChild );
          uotSubTreeClone:  NewChild := CreateSubTreeClone1( GivenChild, j+1 );
        end; // case AUObjType of

        if NewChild.Owner = ADir then
          NewChild.Owner := NewParent;

        if AUObjType <> uotReference then
//          NewParent.SetUniqObjName( NewChild ); // Name(ind) variant
          NewChild.ObjName := N_CreateUniqueUObjName( NewParent, NewChild.ObjName );

        if InsertBefore then // BaseChildInd is not last one
        begin
          Inc( BaseChildInd );
          NewParent.InsOneChild( BaseChildInd, NewChild );
          NewParent.AddChildVnodes( BaseChildInd );
        end else //************ Marked VChild is last UDBase in NewParent
        begin
          NewParent.AddOneChildV( NewChild );
        end;

//        NewParent.SetChangedSubTreeFlag( True );
        N_SetChildsWereChanged( NewParent );
        NewChild.LastVNode.Mark();
      end; // for i := iMax down to 0 do

    end; // for j := 0 to SavedMarked.Count-1 do

    ChangeTreeViewUpdateMode( False );
  end; // with VTree do
  SavedMarked.Free;
end; // end of procedure TN_NVTreeFrame.PasteUObjectsAfter

//*********************************  TN_NVTreeFrame.PasteUObjectsInside  ******
// Paste given UObjects (all children of given ADir) of given AUObjType
// as last children of all VChilds of given AMarked List,
// all Pasted UObjects will be the only marked UObjects
//
procedure TN_NVTreeFrame.PasteUObjectsInside( AUObjType: TN_UObjType;
                                             ADir: TN_UDBase; AMarked: TList );
var
  i, j, iMax: integer;
  NewChild, GivenChild, NewParent: TN_UDBase;
  SavedMarked: TList;
begin
  NewChild := nil; // to avoid warning
  SavedMarked := TList.Create(); // make a copy of AMarked, because
  SavedMarked.Assign( AMarked ); // UnMarkAllVNodes() may clear AMarked List

  with VTree do
  begin
    ChangeTreeViewUpdateMode( True );
    UnMarkAllVNodes();
    iMax := ADir.DirHigh();

    for j := 0 to SavedMarked.Count-1 do
    with TN_VNode(SavedMarked.Items[j]) do
    begin
      NewParent := VNUDObj;

      for i := 0 to iMax do // along ADir Children
      begin
        GivenChild := ADir.DirChild( i );

        case AUObjType of
          uotReference:     NewChild := GivenChild;
          uotOneLevelClone: NewChild := N_CreateOneLevelClone( GivenChild );
          uotSubTreeClone:  NewChild := CreateSubTreeClone1( GivenChild, j+1 );
        end; // case AUObjType of

        if NewChild.Owner = ADir then
          NewChild.Owner := NewParent;

        if AUObjType <> uotReference then
//          NewParent.SetUniqObjName( NewChild ); // Name(ind) variant
          NewChild.ObjName := N_CreateUniqueUObjName( NewParent, NewChild.ObjName );

        NewParent.AddOneChildV( NewChild );
//        NewParent.SetChangedSubTreeFlag( True );
        N_SetChildsWereChanged( NewParent );

        if NewChild.LastVNode = nil then // NewParent is not expanded
        begin
          AllExpandingMode := True; // prevent checking Shift and Control keys
          NewParent.LastVNode.VNTreeNode.Expand( False ); // Expand One Level
          AllExpandingMode := False;
          NewChild.LastVNode.Mark();
        end; // if NewChild.LastVNode = nil then // NewParent is not expanded

      end; // with TN_VNode(Items[i]) do, for i := Count-1 downto 0 do,

    end; // for j := 0 to SavedMarked.Count-1 do

    ChangeTreeViewUpdateMode( False );
  end; // with VTree do
  SavedMarked.Free();
end; // end of procedure TN_NVTreeFrame.PasteUObjectsInside

//*********************************  TN_NVTreeFrame.PasteUObjectsInstead  ******
// Paste given UObjects (all children of given ADir) of given AUObjType
// Instead of All AMarked:
// if Clipboard has exactly one UObj, Paste it instead of all AMarked VChildren,
// otherwise Paste i-th Clipboard UObj instead of i-th  Marked VChild,
// all Pasted UObjects will be the only marked UObjects
//
function TN_NVTreeFrame.PasteUObjectsInstead( AUObjType: TN_UObjType;
                                     ADir: TN_UDBase; AMarked: TList ): boolean;
var
  i, NumClipboard, NumMarked, NumReplaced: integer;
  Str: string;
  ParentUObj, NewChild, GivenChild: TN_UDBase;
  SavedMarked: TList;
begin
  Result := False;
  NewChild := nil; // to avoid warning
  SavedMarked := TList.Create(); // make a copy of AMarked, because
  SavedMarked.Assign( AMarked ); // UnMarkAllVNodes() may clear AMarked List

  with VTree do
  begin
    ChangeTreeViewUpdateMode( True );
    UnMarkAllVNodes();

    NumClipboard := ADir.DirLength();
    if NumClipboard = 0 then
    begin
      ShowStr( 'No UObjects in Clipboard!' );
      Exit;
    end;

    NumMarked := SavedMarked.Count;
    if (NumClipboard > 1) and (NumClipboard <> NumMarked) then
    begin
      ShowStr( 'Num UObjects in Clipboard and Marked should be the same!' );
      Exit;
    end;

    with SavedMarked do
    begin
      GivenChild := ADir.DirChild( 0 );
      NumReplaced := 0;

      for i := 0 to Count-1 do
      with TN_VNode(Items[i]) do
      begin
        ParentUObj := VNParent.VNUDObj;

        if NumClipboard > 1 then
          GivenChild := ADir.DirChild( i );

        if (VNUDObj.Owner = ParentUObj) and (VNUDObj.RefCounter > 1) and
                        not (K_udoUNCDeletion in K_UDOperateFlags)     then
          Continue; // skip replacing VChild

        case AUObjType of
          uotReference:     NewChild := GivenChild;
          uotOneLevelClone: NewChild := N_CreateOneLevelClone( GivenChild );
          uotSubTreeClone:  NewChild := CreateSubTreeClone1( GivenChild, i+1 );
        end; // case AUObjType of

        if NewChild.Owner = ADir then
          NewChild.Owner := ParentUObj;

        if AUObjType <> uotReference then
//          ParentUObj.SetUniqObjName( NewChild ); // Name(ind) variant
          NewChild.ObjName := N_CreateUniqueUObjName( ParentUObj, NewChild.ObjName );

        ParentUObj.PutDirChildV( GetDirIndex(), NewChild ); // Vnode would be updated
//        ParentUObj.SetChangedSubTreeFlag( True );
        N_SetChildsWereChanged( ParentUObj );
        NewChild.LastVNode.Mark();
        Inc( NumReplaced );

      end; // with TN_VNode(Items[i]) do, for i := Count-1 downto 0 do,
    end; // with MarkedVNodesList do

    ChangeTreeViewUpdateMode( False );
  end; // with VTree do

  aViewRefreshFrameExecute( nil );

  Str := '  Ref';
  case AUObjType of
    uotOneLevelClone: Str := '  OLClone';
    uotSubTreeClone:  Str := '  STClone';
  end; // case AUObjType of

  if NumMarked = NumReplaced then
  begin
    ShowStr( IntToStr( NumReplaced ) + Str + '(s) Replaced OK' );
  end else
    ShowStr( IntToStr(NumMarked-NumReplaced) +
                         '  UObject(s) was NOT Replaced (Owner.Child.RefCounter>1) !' );
  SavedMarked.Free();
end; // end of function TN_NVTreeFrame.PasteUObjectsInstead

//***********************************  TN_NVTreeFrame.DeleteVNodes  ******
// Delete given List of VNodes (used in aEdDeleteRefs and aEdCutRefs)
// Return number of deleted Nodes (Nodes with RefCounter > 1 can not be
// deleted from Owner!)
//
//
function TN_NVTreeFrame.DeleteVNodes ( AVNodesList: TList ): Integer;

var
  i, Ind: integer;
  CurVParent: TN_VNode;
  DelRes: TK_DEReplaceResult;

  function SkipDeleting( AVChild: TN_UDBase ): boolean; // local
  // Ask for Deleting given AVChild from Owner with not proper RefCounter
  // Return True if UObj should not be deleted
  var
    Str: string;
  begin
    Str := 'Delete "' + AVChild.ObjName + '" with RefCounter = ' +
                                      IntToStr( AVChild.RefCounter ) + ' ?';
    Result := mrNo = N_MessageDlg( Str, mtConfirmation, mbYesNo );
  end; // function SkipDeleting

begin
  CurVParent := nil;
  Result := 0;
  with VTree do
  begin
    K_TreeViewsUpdateModeSet();

    with AVNodesList do
    begin
      // AVNodesList will be changed by DeleteDirEntry method!
      for i := Count-1 downto 0 do
      with TN_VNode(Items[i]) do
      begin
        CurVParent := VNParent;

        //***** check if deleting from Owner is possible
        if (VNUDObj.Owner = CurVParent.VNUDObj) and
            not (K_udoUNCDeletion in K_UDOperateFlags) then
        begin
          if VNUDObj is TK_UDVector then // TK_UDVector is a special case
          begin

            if VNUDObj.RefCounter = 3 then
            begin
             Ind := N_MEGlobObj.ClbdDir.IndexOfDEField( VNUDObj );
             if Ind >= 0 then
             begin
               N_MEGlobObj.ClbdDir.DeleteDirEntry( Ind );
             end else
               if SkipDeleting( VNUDObj ) then Continue; // skip deleting
            end; // if VNUDObj.RefCounter = 3 then

            if VNUDObj.RefCounter > 2 then
              if SkipDeleting( VNUDObj ) then Continue; // skip deleting
          end else //********************* all other types except TK_UDVector
          begin
            if VNUDObj.RefCounter > 1 then
              if SkipDeleting( VNUDObj ) then Continue; // skip deleting
          end;
        end;

        DelRes := VNParent.VNUDObj.DeleteDirEntry( TN_VNode(Items[i]).GetDirIndex() );
//        VParent.VNUDObj.SetChangedSubTreeFlag( True );
        N_SetChildsWereChanged( CurVParent.VNUDObj );


        if DelRes <> K_DRisOK then // was not deleted
        begin
          if mrYes = N_MessageDlg( 'Delete protected UObj "' + VNUDObj.ObjName + '" ?',
                                   mtConfirmation, mbYesNo ) then
          begin // Delete protected UObj
            K_UDOperateFlags := K_UDOperateFlags + [K_udoUNCDeletion];
            VNParent.VNUDObj.DeleteDirEntry( TN_VNode(Items[i]).GetDirIndex() );
            K_UDOperateFlags := K_UDOperateFlags - [K_udoUNCDeletion];
          end else
            Continue; // Skip deleting

        end; // if DelRes <> K_DRisOK then // was not deleted

        Inc( Result ); // UObj was deleted
      end; // with TN_VNode(Items[i]) do, for i := Count-1 downto 0 do,

      if (CurVParent <> nil) and            // may be if no marked nodes
         (CurVParent.VNTreeNode <> nil) then  // if VParent is VTRee Root
        CurVParent.VNTreeNode.Expanded := True; // DeleteOneChild collapses VParent
    end; // with AVNodesList do

    K_TreeViewsUpdateModeClear();
  end; // with VTree do
end; // end of function TN_NVTreeFrame.DeleteVNodes

//***********************************  TN_NVTreeFrame.IsMarked  ******
// Return True if given AUObj is Marked
//
function TN_NVTreeFrame.IsMarked( AUObj: TN_UDBase ): boolean;
var
  i: integer;
begin
  Result := False;
  if Self = nil then Exit;

  with VTree.MarkedVNodesList do
    for i := 0 to Count-1 do
      with TN_VNode(Items[i]) do
      begin
        if VNUDObj = AUObj then
        begin
          Result := True;
          Exit;
        end;
      end; // with TN_VNode(Items[i]) do, for i := Count-1 downto 0 do,
end; // end of function TN_NVTreeFrame.IsMarked

//**************************************** TN_NVTreeFrame.ShowStr ***
// Show given Astr in SomeStatusBar if it was given
//
procedure TN_NVTreeFrame.ShowStr( AStr: string );
begin
  if SomeStatusBar = nil then Exit;
  SomeStatusBar.SimpleText := Astr;
  SomeStatusBar.Refresh();
end; // procedure TN_NVTreeFrame.ShowStr

//**************************************** TN_NVTreeFrame.ShowStrAdd ***
// Add given Astr to current SomeStatusBar contenet (if any)
//
procedure TN_NVTreeFrame.ShowStrAdd( AStr: string );
begin
  if SomeStatusBar = nil then Exit;
  SomeStatusBar.SimpleText := SomeStatusBar.SimpleText + Astr;
  SomeStatusBar.Refresh();
end; // procedure TN_NVTreeFrame.ShowStrAdd

procedure TN_NVTreeFrame.ShowProgress1( MessageLine: string; ProgressStep: Integer);
// used in aFileLoadDataInsideSelectedExecute method for loading MVDar Table
begin
  ShowStr( MessageLine );
//  Application.ProcessMessages;
end; // procedure TN_NVTreeFrame.ShowProgress

procedure TN_NVTreeFrame.ShowWarning( MessageLine: string; MesStatus: TK_MesStatus );
// was used only in aFileLoadDataInsideSelectedExecute method for loading MVDar Table
begin
  case MesStatus of
    K_msInfo : begin
      ShowStr( MessageLine );
    end;
    K_msError, K_msWarning : begin
      ShowStr( MessageLine );
    end;
  end;
end; // procedure TN_NVTreeFrame.ShowWarning


end.


