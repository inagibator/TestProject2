unit N_UObjFr;
// low level UObject Actions,
//
// it can be used in Parent Controls as ComboBox with RightClick Menu
//   and some KeyDown Actions,
// or it can be invisible for using it's UObjActList as additional ActionList
//
// now it is activly used as RightClick Popup Menu container and in
// old (obsolete, but working) forms such as MLEdForm
// see N_UObj2Fr for more recent version

//   to add new PopupMenu Item:
// 1) add New Action (with ImageIndex) to Self.UObjActList
// 2) add Action OnExecute method
// 3) set Action Visibility in proc SetPopupMenuCaptionsByUObj();
// 4) Add new Item in N_MenuF.UObjPopupMenu
// 5) Assign Action to this PopupMenu Item

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls, ComCtrls, ToolWin, Menus, ActnList, ImgList,
  K_UDT1,
  N_Types, N_Lib1, N_ClassRef, N_BaseF, N_UDat4;

type TN_UObjFrame = class( TFrame )
    mb: TComboBox;
    bnBrowse: TButton;
    UObjActList: TActionList;
    aViewMain: TAction;
    aViewInfo: TAction;
    aViewFields: TAction;
    aEdRename: TAction;
    aEdDelete: TAction;
    aEditFields: TAction;
    aEditParams: TAction;
    aEditUDRArray: TAction;
    aEditUDVector: TAction;
    aSpecialEdit1: TAction;
    aSpecialEdit2: TAction;
    aSpecialEdit3: TAction;
    aExecuteComp: TAction;
    aUDMemLoad: TAction;
    aUDMemSave: TAction;
    aUDMemViewAsText: TAction;
    aArchSecLoad: TAction;
    aArchSecSave: TAction;
    aArchSecEditParams: TAction;

    //****************** TN_UObjFrame handlers

    constructor Create      ( AOwner: TComponent ); override;
    procedure bnBrowseClick ( Sender: TObject );
    procedure mbKeyDown     ( Sender: TObject; var Key: Word;
                                                         Shift: TShiftState );
    procedure mbCloseUp        ( Sender: TObject );
    procedure UObjContextPopup ( Sender: TObject; MousePos: TPoint;
                                                       var Handled: Boolean );

    //*********************** UObjActList Actions ****************************

    procedure aArchSecLoadExecute       ( Sender: TObject );
    procedure aArchSecSaveExecute       ( Sender: TObject );
    procedure aArchSecEditParamsExecute ( Sender: TObject );

    procedure aExecuteCompExecute ( Sender: TObject );
    procedure aViewMainExecute    ( Sender: TObject );
    procedure aViewInfoExecute    ( Sender: TObject );
    procedure aViewSysInfoExecute ( Sender: TObject );
    procedure aViewFieldsExecute  ( Sender: TObject );

    procedure aEdRenameExecute ( Sender: TObject );
    procedure aEdDeleteExecute ( Sender: TObject );

    procedure aEditFieldsExecute   ( Sender: TObject );
    procedure aEditParamsExecute   ( Sender: TObject );
    procedure aEditUDRArrayExecute ( Sender: TObject );
    procedure aEditUDVectorExecute ( Sender: TObject );

    procedure aSpecialEdit1Execute ( Sender: TObject );
    procedure aSpecialEdit2Execute ( Sender: TObject );
    procedure aSpecialEdit3Execute ( Sender: TObject );

    procedure aUDMemLoadExecute       ( Sender: TObject );
    procedure aUDMemSaveExecute       ( Sender: TObject );
    procedure aUDMemViewAsTextExecute ( Sender: TObject );
  public
    MaxListSize: integer;   // Max List Size in mbFileName ComboBox
    RootDir:     TN_UDBase; // ParentUObj or Parent of ParentUObj (see SubRootCont)
    SubRootCont: TComboBox; // if nil then RootDir is used as ParentUObj,
                            // otherwise, SubRootCont.Text is ObjName in RootDir
                            // and this Obj is used as ParentUObj
    UObjClass: TN_UDBaseClass; // only ancestors of UObjClass can be choosen
                               // by bnBrowse button
    UseAliase: boolean;  // mb.Text is ObjAliase, not ObjName (in ParenUObj Dir)

    UObj:       TN_UDBase;  // set by mb.Text in SetUObj method or by external proc
                            // all actions are performed with UObj
    UObjVNode:  TN_VNode;   // set if RightClick in NVTReeFrame (UObjVNode.VChild = UObj)
    ParentUObj: TN_UDBase;  // Parent Dir for UObj (used in Delete Action)
    OwnerForm: TN_BaseForm; // Owner Form for all Forms, opened in Actions
    SomeStatusBar: TStatusBar; // used in ShowStr for Action messages

    procedure UOFrInit ( ARootDir: TN_UDBase; AUObjClass: TN_UDBaseClass;
                  ASubRootCont: TComboBox = nil; AUseAliase: boolean = False;
                  AOwner: TN_BaseForm = nil; AStatusBar: TStatusBar = nil );
    procedure ShowStr  ( AStr: string );
    function  SetUObj  (): TN_UDBase;
    function  GetUObjR ( AClassInd: integer ): TN_UDBase;
    function  GetCObjR ( AClassInd: integer ): TN_UCObjLayer;
    function  GetCObjW ( AClassInd: integer; AWLCType: integer = 0 ): TN_UCObjLayer;
    procedure SetPopupMenuCaptionsByUObj ();
    procedure VTreeAction ( AParent: TWinControl; Node: TTreeNode;
                     EventType: integer; Button: TMouseButton; Shift: TShiftState );
end; // TN_UObjFrame = class( TFrame )


    //*********** Global Procedures  *****************************

procedure N_ShowUObjActionsMenu( AUObj: TN_UDBase; AStatusBar: TStatusbar;
                                                         AOwner: TN_BaseForm );

var
  N_GlobUOFrInitOwnerForm: TN_BaseForm; // used in UOFrInit
  N_GlobUOFrInitStatusbar: TStatusBar;  // used in UOFrInit

  //*************** N_UObjFrame RightClick Menu Items visibility:
  N_UObjFrMenuDescr: array [0..3] of TN_CLBItem =
  ((CLBId:'Header';        CLBText: '     Right Click Menu Items'; CLBType:clbHeader ),
   (CLBId:'ViewInfo';      CLBText: 'View Info';            CLBValue:True ),
   (CLBId:'ViewFields';    CLBText: 'View Fields As Text';  CLBValue:True ),
   (CLBId:'EditFields';    CLBText: 'Edit Fields As Text';  CLBValue:True )
  );


implementation

uses
  math,
  K_UDConst, K_CLib0, K_DCSpace, K_FDCSpace, K_FDCSSpace, K_FDCSProj, K_CSpace,
  K_FUDCDim, K_FUDCSDim, K_FUDCDCor, K_MVObjs, K_Arch, K_FUDCSDBlock,
  K_Script1, K_FRaEdit, K_RAEdit, K_FrRaEdit, K_FUDV,
  N_Lib0, N_Gra2, N_UDCMap, N_GetUObjF, N_Lib2, N_EdStrF, N_MsgDialF, N_ME1,
  N_RaEditF, N_CompBase, N_GCont, N_ButtonsF, N_MenuF, N_Rast1Fr, N_RVCTF,
  N_PlainEdF, N_FNameF, N_NVtreeFr, N_FNameFr, N_EdParF, N_Comp1;

{$R *.dfm}

    //***************  TN_UObjFrame class methods  *****************

constructor TN_UObjFrame.Create( AOwner: TComponent );
begin
  Inherited;
  MaxListSize := 20;
  RootDir := K_ArchsRootObj;
  UObjClass := TN_UDBase;
end; // constructor TN_UObjFrame.Create

    //***************  TN_UObjFrame handlers  **********************

procedure TN_UObjFrame.bnBrowseClick( Sender: TObject );
// Choose UObj from DTree using N_GetUObjPathDlg
var
  NewPath: string;
begin
  SetUObj(); // set Self.ParentUObj field
  NewPath := N_GetUObjPathDlg( ParentUObj, mb.Text, Self );

  if NewPath = '' then Exit; // UObj was not choosen

  mb.Text := NewPath;
  SetUObj(); // set Self.UObj field by NewPath (just choosen in N_GetUObjPathDlg)

  N_AddTextToTop( mb, MaxListSize );
end; // procedure TN_UObjFrame.bnBrowseClick

procedure TN_UObjFrame.mbKeyDown( Sender: TObject; var Key: Word;
                                                          Shift: TShiftState );
// Perform Actions on mb.Text UObj by Hot Keys
begin
//  SetUObj(); //???
  if Key = VK_RETURN then           // Enter - add mb.Text to Top of Items List
    N_AddTextToTop( mb, MaxListSize )
  else if ssCtrl in Shift then // Ctrl Key is down
  case Key of
  Word('R'): aEdRenameExecute   ( nil ); // Ctrl+R - Rename
  Word('D'): aEdDeleteExecute   ( nil ); // Ctrl+D - Delete
  Word('M'): aViewMainExecute  ( nil ); // Ctrl+M - Map  (View as Map)
  Word('I'): aViewInfoExecute   ( nil ); // Ctrl+I - Info (View UObj Info)
//  Word('1'): aEdOneLevelCopyExecute  ( nil ); // Ctrl+1 - Make One Level Copy
//  Word('S'): aEdSetRefToOLCopyExecute( nil ); // Ctrl+S - Set Ref to One Level Copy
  Word('F'): aViewFieldsExecute ( nil ); // Ctrl+F - Fields (View Fields as Text)
  end; // case Key of
end; // procedure TN_UObjFrame.mbKeyDown

procedure TN_UObjFrame.mbCloseUp( Sender: TObject );
// just add choosen Items element to Top of Items list
begin
  N_AddTextToTop( mb, MaxListSize );
  SetUObj(); // Set ParentUObj and UObj fields
end; // procedure TN_UObjFrame.mbCloseUp

procedure TN_UObjFrame.UObjContextPopup( Sender: TObject;
                                         MousePos: TPoint; var Handled: Boolean );
// Show Popup Menu On Frame ContextPopup Event
//
// for both: ComboBox mb and Frame N_UObjFr - PopupMenu property should be set!!
// (otherwise standard context menu is shown by Delphi on Right Mouse Button Click)
begin
  SetUObj(); // Set ParentUObj and UObj fields
  if UObj = nil then Exit;

  SetPopupMenuCaptionsByUObj();
  ShowStr( 'Choose Action for ' + UObj.ObjName );

  with Mouse.CursorPos do
    N_MenuForm.UObjPopupMenu.Popup( X, Y );

  Handled := True;
end; // procedure TN_UObjFrame.UObjContextPopup


    //*********************** UObjActList Actions

procedure TN_UObjFrame.aArchSecLoadExecute( Sender: TObject );
// Load Archive Section
begin
  if N_LoadArchSection( Uobj ) then
    ShowStr( 'Section Loaded from ' + Uobj.ObjInfo )
  else
    ShowStr( 'Section NOT Loaded!' )
end; // procedure TN_UObjFrame.aArchSecLoadExecute

procedure TN_UObjFrame.aArchSecSaveExecute( Sender: TObject );
// Save Archive Section
begin
  if K_GetSelfArchive( UObj ) <> K_CurArchive then // UObj is not inside K_CurArchive!
    ShowStr( 'Try to save section "' + Uobj.GetUName + '" which is not in current archive!' )
  else // K_CurArchive is OK
  begin
    if UObj.DirLength() = 0 then // Section is empty (may be not loaded yet)
    begin
      if N_MessageDlg( ' Section ' + Uobj.ObjName + ' is empty.'#$D#$A' ' +
                       'Clear Section file ' + Uobj.ObjInfo + ' ?',
                       mtConfirmation, mbYesNo, 0 ) = mrCancel then
      begin
        ShowStr( 'Empty Section  NOT  Saved to ' + Uobj.ObjInfo );
        Exit;
      end;
    end;

    //***** Section is not empty, or is empty but should be saved, try to save it
    if K_SaveCurArchiveSection( UObj ) then // Saved OK
      ShowStr( 'Section Saved to ' + Uobj.ObjInfo )
    else // failed to save
    begin
      ShowStr( '' );
      N_ShowInfoDlg( 'Section  NOT  Saved to ' + Uobj.ObjInfo );
    end; // else // failed to save
  end; // else // K_CurArchive is OK
end; // procedure TN_UObjFrame.aArchSecSaveExecute

procedure TN_UObjFrame.aArchSecEditParamsExecute( Sender: TObject );
// Edit Archive Section Params
begin
  N_EditArchSectionParams( UObj, OwnerForm );
end; // procedure TN_UObjFrame.aArchSecEditParamsExecute


procedure TN_UObjFrame.aExecuteCompExecute( Sender: TObject );
// Execute UObj
begin
  if UObj is TN_UDCompBase then
    with N_MEGlobObj.NVGlobCont do
    begin
      ShowStr( '' );
      ExecuteRootComp( UObj, [], ShowStr, OwnerForm );
    end;
end; // procedure TN_UObjFrame.aExecuteCompExecute

procedure TN_UObjFrame.aViewMainExecute( Sender: TObject );
// View UObj as Map in Same (for all Maps) or separate Window
begin
  if UObj is TN_UCObjLayer then
  begin
    if N_KeyIsDown( N_VKShift ) then // View in separate Window
      N_ViewUObjAsMap( UObj, nil, OwnerForm )
    else // View in already opened Window (if any) or create new Window
      N_ViewUObjAsMap( UObj, @N_MEGlobObj.RastVCTForm, OwnerForm );
  end else if UObj is TN_UDCompBase then
    N_ViewCompMain( UObj, ShowStr, OwnerForm );
end; // procedure TN_UObjFrame.aViewMainExecute

procedure TN_UObjFrame.aViewInfoExecute( Sender: TObject );
// View Info or SysInfo (+Ctrl) about UObj (SysInfo is UDBase sys fields)
// (+Shift) - view each UObj in separate Window
//            (otherwise, use same Window for all UObjects)
begin
  if N_KeyIsDown( N_VKControl ) then // View SysInfo
  begin
    if N_KeyIsDown( N_VKShift ) and (Sender <> nil) then // View in separate Window
      N_ViewUObjSysFields( UObj, nil, OwnerForm )
    else // View in already opened Window (if any) or create new Window
      N_ViewUObjSysFields( UObj, @N_MEGlobObj.TextEdForm, OwnerForm );
  end else // View Info
  begin
    if N_KeyIsDown( N_VKShift ) and (Sender <> nil) then // View in separate Window
      N_ViewUObjInfo( UObj, nil, OwnerForm )
    else // View in already opened Window (if any) or create new Window
      N_ViewUObjInfo( UObj, @N_MEGlobObj.TextEdForm, OwnerForm );
  end; // else

  ShowStr( '' );
end; // procedure TN_UObjFrame.aViewInfoExecute

procedure TN_UObjFrame.aViewSysInfoExecute( Sender: TObject );
// View system Info - UDBase sys fields in UObj
begin
  if N_KeyIsDown( N_VKShift ) and (Sender <> nil) then // View in separate Window
    N_ViewUObjSysFields( UObj, nil, OwnerForm )
  else // View in already opened Window (if any) or create new Window
    N_ViewUObjSysFields( UObj, @N_MEGlobObj.TextEdForm, OwnerForm );

  ShowStr( '' );
end; // procedure TN_UObjFrame.aViewSysInfoExecute

procedure TN_UObjFrame.aViewFieldsExecute( Sender: TObject );
// View UObj Fields as Text (in DTree Text *.sdt format)
begin
  if N_KeyIsDown( N_VKShift ) then // View in separate Window
    N_ViewUObjFields( UObj, nil, OwnerForm )
  else // View in already opened Window (if any) or create new Window
    N_ViewUObjFields( UObj, @N_MEGlobObj.TextEdForm, OwnerForm );

  ShowStr( '' );
end; // procedure TN_UObjFrame.aViewFieldsExecute


procedure TN_UObjFrame.aEdRenameExecute( Sender: TObject );
// Rename UObj
var
  WrkObjName, OutObjName, OutObjAliase: string;
  ParamsForm: TN_EditParamsForm;
  Label ShowEditForm;
begin
  if UObj = nil then
  begin
    ShowStr( 'Nothing to Rename!' );
    Exit;
  end;
  WrkObjName := UObj.ObjName; // can be changed in ShowEditForm

  ShowEditForm: //*******************************

  ParamsForm := N_CreateEditParamsForm( 200 );
  with ParamsForm do
  begin
    Caption := 'Edit UObj Names :';
    AddLEdit( 'ObjName :',   0, WrkObjName );
    EPControls[0].CRFlags := [ctfActiveControl, ctfExitOnEnter];

    AddLEdit( 'ObjAliase :', 0, UObj.ObjAliase );
    EPControls[1].CRFlags := [ctfExitOnEnter];

    ShowSelfModal();

    N_i := ModalResult; // debug
    if ModalResult <> mrOK then
    begin
      ShowStr( '' );
      Release; // Free ParamsForm
      Exit;
    end;

    OutObjName   := EPControls[0].CRStr; // ObjName on output (changed or not)
    OutObjAliase := EPControls[1].CRStr; // ObjAliase on output (changed or not)

//    if N_GetUObj( ParentUObj, OutObjName ) <> nil then // UObj with this ObjName exists
    if ParentUObj.DirChildByObjName( OutObjName ) <> nil then // UObj with this ObjName exists
    begin
      if OutObjName = UObj.ObjName then // ObjName was not changed
      begin
        if OutObjAliase = UObj.ObjAliase then // ObjAliase was not changed too
          ShowStr( 'UObj was not renamed' )
        else // ObjAliase was changed
        begin
          UObj.ObjAliase := OutObjAliase;
          ShowStr( 'Aliase renamed to  "' + OutObjAliase + '"' );
        end;

        Release; // Free ParamsForm
        Exit;
      end; // if OutObjName = UObj.ObjName then // ObjName was not changed

      ShowStr( 'UObj with ObjName  "' + OutObjName + '" already exists!' );
      WrkObjName := ParentUObj.BuildUniqChildName( OutObjName );

      goto ShowEditForm;

    end; // if N_GetUObj( ParentUObj, Str ) <> nil then // UObj with this ObjName exists

    UObj.ObjName   := OutObjName;
    UObj.ObjAliase := OutObjAliase;
    UObj.RebuildVNodes();
    K_SetChangeSubTreeFlags( UObj );
    ShowStr( 'UObj was renamed OK to "' + OutObjName + ', ' + OutObjAliase + '"' );
    Release; // Free ParamsForm
  end; // with ParamsForm do

end; // procedure TN_UObjFrame.aEdRenameExecute

procedure TN_UObjFrame.aEdDeleteExecute( Sender: TObject );
// Delete UObj
var
  Str: string;
begin
  if UObj = nil then
  begin
    ShowStr( 'Nothing to Delete!' );
    Exit;
  end;

  Str := UObj.ObjName;
  if mrNo = N_MessageDlg( 'Are You sure to delete "' + Str + '" ?',
                                 mtConfirmation, mbYesNo, 0 ) then Exit;

  if (UObj.Owner = ParentUObj) and (UObj.RefCounter > 1) then
    ShowStr( 'UObj "' + Str + '" was NOT deleted (Owner.Child.RefCounter>1) !' )
  else
  begin
    ParentUObj.DeleteOneChild( UObj );
//    ParentUObj.SetChangedSubTreeFlag( True );
    N_SetChildsWereChanged( ParentUObj );
    ParentUObj.RebuildVNodes();
    ShowStr( 'UObj "' + Str + '" was deleted OK' );
    mb.Text := ' ';
  end;
end; // procedure TN_UObjFrame.aEdDeleteExecute

procedure TN_UObjFrame.aEditFieldsExecute( Sender: TObject );
// Edit UObj Fields As Text (in DTree Text *.sdt format)
begin
  if N_KeyIsDown( N_VKShift ) then // View in separate Window
    N_EditUObjFields( UObj, nil, OwnerForm )
  else // View in already opened Window (if any) or create new Window
    N_EditUObjFields( UObj, @N_MEGlobObj.TextEdForm, OwnerForm );

  ShowStr( '' );
end; // procedure TN_UObjFrame.aEditFieldsExecute

procedure TN_UObjFrame.aEditParamsExecute( Sender: TObject );
// If UObj is Component or UDRArray Edit it by N_EditParams,
// if UObj is CoordsObject, edit it by CObjLayer Editor
begin
  if Uobj is TK_UDRArray then
    N_EditParams( TK_UDRArray(UObj), mmfNotModal, OwnerForm );

  if Uobj is TN_UCObjLayer then
    N_EditCObjLayerCoords( TN_UCObjLayer(UObj), OwnerForm );

  ShowStr( '' );
end; // procedure TN_UObjFrame.aEditUobjParamsExecute

procedure TN_UObjFrame.aEditUDRArrayExecute( Sender: TObject );
// Edit UObj as UDRArray using K_RAShowEdit
begin
  K_EditUDRAFunc( UObj, OwnerForm, N_MEGlobObj.RedrawActiveRFrame );
//  UObj.SetChangedSubTreeFlag();
  K_SetChangeSubTreeFlags( UObj );
  ShowStr( '' );
end; // procedure TN_UObjFrame.aEditUDRArrayExecute

procedure TN_UObjFrame.aEditUDVectorExecute( Sender: TObject );
// Edit UObj as UDVector
begin
  if not (Uobj is TK_UDVector) then Exit;

  K_EditUDVector( TK_UDVector(UObj), False, 'Data Vector: ' + UObj.ObjName,
                   'Value', [K_ramColVertical, K_ramShowLRowNumbers],
//                   '', '', OwnerForm );
                   'TK_FormUDVTabUni', 'TK_TypeUDVTabUni', OwnerForm );
{
      Result := K_EditUDVector( TK_UDVector(UDVector), false, '', 'Значение',
                                [K_ramColVertical], FFDClassName, FFTClassName,
                                RAEDFC.FOwner, RAEDFC.FOnGlobalAction, FTargetCSS );
}
//  UObj.SetChangedSubTreeFlag();
  K_SetChangeSubTreeFlags( UObj );
  ShowStr( '' );
end; // procedure TN_UObjFrame.aEditUDVectorExecute

procedure TN_UObjFrame.aSpecialEdit1Execute( Sender: TObject );
// Special Editor 1 (depends upon UObj type)
var
  WasEdited : Boolean;
  FName: string;
begin
  ShowStr( '' );

  if UObj is TN_UCObjLayer then //******************** CoordsObj Layer
  begin
    N_EditCObjLayerCoords( TN_UCObjLayer(UObj), OwnerForm );
  end else if UObj is TN_UDMapLayer then //**************** Map Layer Component
  begin
    N_EditMapLayerCoords( TN_UDMapLayer(UObj), OwnerForm )
  end else if UObj is TK_UDCDim then //************************ Codes Dimension
  begin
//    K_EditUDCDim( TK_UDCDim(UObj), OwnerForm, nil, False );
    with K_GetFormUDCDim( OwnerForm ) do
    begin
      CurUDCDim := TK_UDCDim(UObj);
      InitData();
      Show();
    end;
  end else if UObj is TK_UDCSDim then //******************** Codes SubDimension
  begin
//    K_EditUDCSDim( TK_UDCSDim(UObj), OwnerForm, nil, False );
    with K_GetFormUDCSDim( OwnerForm ) do
    begin
      CurUDCSDim := TK_UDCSDim(UObj);
      Show();
    end;
  end else if UObj is TK_UDCDCor then //************* Codes Dimensions Relation
  begin
//    K_EditUDCDCor( TK_UDCDCor(UObj), OwnerForm, nil, False );
    with K_GetFormUDCDCor( OwnerForm ) do
    begin
      CurUDCDCor := TK_UDCDCor(UObj);
      Show();
    end;
  end else if UObj is TK_UDCSDBlock then //************************* Data Block
  begin
//    K_EditUDCSDBlock( TK_UDCSDBlock(UObj), OwnerForm, nil, False );
    with K_GetFormUDCSDBlock( OwnerForm ) do
    begin
      CurUDCSDBlock := TK_UDCSDBlock(UObj);
      Show();
    end;
  end else if UObj is TK_UDMVWSite then //********************* WEB Publication
  begin
    N_b := K_EditUDByGEFunc( UObj, nil, WasEdited, OwnerForm );

//************** Beg Obsolete Code
  end else if UObj is TK_UDDCSpace then //************ Codes Space
  begin
    K_EditDCSpace( TK_UDDCSpace(UObj), OwnerForm );
  end else if UObj is TK_UDDCSSpace then //*********** Codes SubSpace
  begin
    K_EditDCSSpace( TK_UDDCSSpace(UObj), OwnerForm );
  end else if UObj is TK_UDVector then //************* Data Vector or DCSProjection
  begin
    if TK_UDVector(UObj).IsDCSProjection then //****** Codes Space Projection
      K_EditDCSProj( TK_UDVector(UObj) );
//************** End Obsolete Code

  end else if UObj is TN_UDLogFont then //************ UDLogFont (old Font Format)
  begin
    N_EditUDLogFont( TN_UDLogFont(UObj), OwnerForm );
  end else if UObj is TN_UDNFont then //************* UDNFont (new Font Format)
  begin
    N_EditNFont( TN_PNFont(TN_UDNFont(UObj).R.P()), OwnerForm );
  end else if UObj is TN_UDDIB then //*********** Load TN_UDDIB.DIBObj from file
  begin
    with TN_UDDIB(UObj) do
    begin
      if N_ButtonsForm.CommonOpenPictureDialog.Execute then
      begin
        DIBObj.Free;
        FName := N_ButtonsForm.CommonOpenPictureDialog.FileName;
        DIBObj := TN_DIBObj.Create( FName );
        ShowStr( 'Image Loaded from ' + FName );
      end;
    end; // with TN_UDDIB(UObj) do
  end;

  K_SetChangeSubTreeFlags( UObj );
end; // procedure TN_UObjFrame.aSpecialEdit1Execute

procedure TN_UObjFrame.aSpecialEdit2Execute( Sender: TObject );
// Special Editor 2 (depends upon UObj type)
var
  FName: string;
begin
  ShowStr( '' );

  if UObj is TN_UDDIB then //*********** Save TN_UDDIB.DIBObj to file
  begin
    with TN_UDDIB(UObj) do
    begin
      if N_ButtonsForm.CommonSavePictureDialog.Execute then
      begin
        FName := N_ButtonsForm.CommonSavePictureDialog.FileName;
        DIBObj.SaveToFileByGDIP( FName );
        ShowStr( 'Image Saved to ' + FName );
      end;
    end; // with TN_UDDIB(UObj) do
  end;
end; // procedure TN_UObjFrame.aSpecialEdit2Execute

procedure TN_UObjFrame.aSpecialEdit3Execute( Sender: TObject );
// Special Editor 3 (depends upon UObj type)
begin
  ShowStr( 'Not implemented' );
end; // procedure TN_UObjFrame.aSpecialEdit3Execute


procedure TN_UObjFrame.aUDMemLoadExecute( Sender: TObject );
// Load UDMem from MVFile
var
  FileName: string;
begin
{
  with TN_FileNameForm.Create( Application ) do
  begin
    Top  := Mouse.CursorPos.Y + 5;
    Left := Mouse.CursorPos.X;
    FileName := SelectFileName( 'UDMemFNHistory' );
  end;
}
  if UObj.ObjInfo = '' then // No FileName, set it from FNameFrame
  begin
    if N_ActiveVTreeFrame <> nil then
    begin
      if N_ActiveVTreeFrame.NFNameFr.Visible then
        UObj.ObjInfo := N_ActiveVTreeFrame.NFNameFr.mbFileName.Text;
    end;
  end; // if UObj.ObjInfo = '' then // No FileName, set it from FNameFrame

  FileName := K_ExpandFileName( UObj.ObjInfo );

  if not FileExists( FileName ) then
  begin
    ShowStr( 'No Such File!' );
    Exit;
  end;

  if TN_UDMem(UObj).LoadSelfBDFromDFile( FileName ) then
    ShowStr( 'Loaded OK from ' + FileName )
  else
    ShowStr( 'Not Loaded!' );

//  UObj.SetChangedSubTreeFlag();
  K_SetChangeSubTreeFlags( UObj );
end; // procedure TN_UObjFrame.aUDMemLoadExecute

var N_DFileTypes: array [0..2] of string = ( ' Plain ', ' Protected ', ' Encrypted ' );

procedure TN_UObjFrame.aUDMemSaveExecute( Sender: TObject );
// Save UDMem To DFile
var
  FileName: string;
  ParForm: TN_EditParamsForm;
  CreateParams: TK_DFCreateParams;
begin
  if UObj.ObjInfo = '' then // No FileName, set it from FNameFrame
  begin
    if N_ActiveVTreeFrame <> nil then
    begin
      if N_ActiveVTreeFrame.NFNameFr.Visible then
        UObj.ObjInfo := N_ActiveVTreeFrame.NFNameFr.mbFileName.Text;
    end;
  end; // if UObj.ObjInfo = '' then // No FileName, set it from FNameFrame

  FileName := K_ExpandFileName( UObj.ObjInfo );

  if not N_ConfirmOverwriteDlg( FileName ) then
  begin
    ShowStr( 'Not Saved!' );
    Exit;
  end;

  ParForm := N_CreateEditParamsForm( 250 );
  with ParForm do
  begin
    AddRadioGroup( 'DFile Type:', N_DFileTypes, 0 );
    ShowSelfModal();

    if ModalResult <> mrOK then
    begin
      ShowStr( 'Not Saved!' );
      Release; // Free ParForm
      Exit;
    end;

    case EPControls[0].CRInt of
      0: CreateParams := K_DFCreatePlain;
      1: CreateParams := K_DFCreateProtected;
      2: CreateParams := K_DFCreateEncrypted;
    end; // case EPControls[0].CRInt of

    with UObj as TN_UDMem do
      K_DFWriteAll( FileName, CreateParams, @SelfMem[0], Length(SelfMem) );

    ShowStr( 'Saved OK to ' + FileName );
    Release; // Free ParForm
  end; // with ParForm do

end; // procedure TN_UObjFrame.aUDMemSaveExecute

procedure TN_UObjFrame.aUDMemViewAsTextExecute( Sender: TObject );
// View UDMem as Text in PlainEditorForm
begin
  with N_GetMEPlainEditorForm( OwnerForm ) do
  begin
    TN_UDMem(UObj).GetStringsFromSelfBD( Memo.Lines );
    Caption := UObj.ObjName;
    Show();
  end;

  ShowStr( '' );
end; // procedure TN_UObjFrame.aUDMemViewAsTextExecute


    //***************  TN_UObjFrame public methods  **********************

//*************************************************** TN_UObjFrame.UOFrInit ***
// Set RootDir, UObjClass and SubRootCont fields,
// N_GlobUOFrInitOwnerForm and N_GlobUOFrInitStatusbar are used as default input params to reduce
// source code size for multiple calls to UOFrInit in same environment
//
procedure TN_UObjFrame.UOFrInit( ARootDir: TN_UDBase; AUObjClass: TN_UDBaseClass;
                                ASubRootCont: TComboBox; AUseAliase: boolean;
                                AOwner: TN_BaseForm; AStatusBar: TStatusBar );
begin
  RootDir     := ARootDir;
  UObjClass   := AUObjClass;
  SubRootCont := ASubRootCont;
  UseAliase   := AUseAliase;

  if AOwner = nil then OwnerForm := N_GlobUOFrInitOwnerForm
                  else OwnerForm := AOwner;

  if AStatusBar = nil then SomeStatusBar := N_GlobUOFrInitStatusbar
                      else SomeStatusBar := AStatusBar;

  SetUObj();
  if UObj = nil then mb.Text := '?'; // should not be empty! (otherwise Windows crashed)
end; // procedure TN_UObjFrame.UOFrInit

//**************************************** TN_UObjFrame.ShowStr ***
// Show given Astr in SomeStatusBar if it was given
//
procedure TN_UObjFrame.ShowStr( AStr: string );
begin
  if SomeStatusBar <> nil then
    SomeStatusBar.SimpleText := Astr;
end; // procedure TN_UObjFrame.ShowStr

//**************************************** TN_UObjFrame.SetUObj ***
// Set ParentUObj and UObj fields by mb.Text, return UObj
// ( if mb.Text is not used (as in MEVTreeForm) ParentUObj and UObj fields
//   should be set manualy)
//
function TN_UObjFrame.SetUObj(): TN_UDBase;
begin
 UObjVNode := nil;

 if SubRootCont = nil then
   ParentUObj := RootDir
 else
 begin
   ParentUObj := N_GetUObjByPath( RootDir, SubRootCont.Text );

   if ParentUObj is TK_UDDCSpace then
    ParentUObj := TK_UDDCSpace(ParentUObj).GetSSpacesDir();
 end;

  if UseAliase then
    UObj := N_GetUObjByPath( ParentUObj, mb.Text, K_ontObjAliase )
  else
    UObj := N_GetUObjByPath( ParentUObj, mb.Text, K_ontObjName );

  Result := UObj;
  N_AddTextToTop( mb, MaxListSize );
end; // function TN_UObjFrame.SetUObj

//**************************************** TN_UObjFrame.GetUObjR ***
// find and return UObj by given Name(Path) in Read mode
// raise exception if not found (and AClassInd <> -2) or it's ClassFlags
// are not AClassInd (and AClassInd <> -1)
//
//
function TN_UObjFrame.GetUObjR( AClassInd: integer ): TN_UDBase;
begin
  Result := SetUObj();
  if AClassInd = -2 then Exit; // any Result is OK

  if Result <> nil then
  begin
    if (Result.CI = AClassInd) or (AClassInd  = -1 ) then Exit;

    //*** Cobj exists, but is not of needed type
    raise Exception.Create( 'UObj  "' + mb.Text + '" is not of needed Type!' );
  end else // not found
    raise Exception.Create( 'UObj  "' + mb.Text + '"  not found!' );

end; // function TN_UObjFrame.GetUObjR

//**************************************** TN_UObjFrame.GetCObjR ***
// same as GetUObjR by result is of TN_UCObjLayer type
//
function TN_UObjFrame.GetCObjR( AClassInd: integer ): TN_UCObjLayer;
begin
  Result := TN_UCObjLayer(GetUObjR( AClassInd ));
end; // function TN_UObjFrame.GetUObjR

//**************************************** TN_UObjFrame.GetCObjW ***
// find and return CObj by given Name in Write mode
// create or change Cobj type if needed
// ask if CObj with given Name already exists and return nil if it
// should not be overwritten
//
//
function TN_UObjFrame.GetCObjW( AClassInd: integer;
                                          AWLCType: integer ): TN_UCObjLayer;
begin
  Assert( AClassInd <> -1, 'Bad ClassInd' );
  Result := TN_UCObjLayer(SetUObj());
  if ParentUObj = nil then ParentUObj := N_MapEditorDir;

  if Result <> nil then
  begin
    if mrCancel = N_MessageDlg( 'OBject "' + mb.Text + '" already exists.' +
                        #13#10' Overwrite it? ', mtWarning, mbOKCancel, 0 ) then
    begin
      Result := nil;
      Exit;
    end;

    if AClassInd = N_ULinesCI then
    begin
      if (Result.CI = AClassInd) and (Result.WLCType = AWLCType) then Exit;
    end else // not Lines, WCLType does not matter
      if Result.CI = AClassInd  then Exit;

    //*** Cobj exists, but is not of needed type, delete it
    ParentUObj.DeleteOneChild( Result );
  end;

  //***** Create New CObj with given Name and type

  if AClassInd = K_UDRArrayCI then
    Result := TN_UCObjLayer(K_CreateUDByRTypeName( 'strings', 1 )) // temporary
  else
    Result := TN_UCObjLayer(N_ClassRefArray[AClassInd].Create());

  Result.ObjName := mb.Text;
//  N_CObjectsDir.AddOneChild( Result );
  ParentUObj.AddOneChildV( Result ); // OK??
  if AClassInd = N_ULinesCI then Result.WLCType := AWLCType;
end; // function TN_UObjFrame.GetCObjW

//***************************** TN_UObjFrame.SetPopupMenuCaptionsByUObj ***
// Set PopupMenu Items Captions and visibility by UObj type
//
procedure TN_UObjFrame.SetPopupMenuCaptionsByUObj();
var
  ExpFlags: TN_CompExpFlags;
begin
  with N_MenuForm do
  begin
    N_s := Self.Name; // debug
    // prelimenary settings:

  aArchSecLoad.Visible       := False;
  aArchSecSave.Visible       := False;
  aArchSecEditParams.Visible := False;

  aExecuteComp.Visible  := False;
  aViewMain.Visible     := False;

  aViewInfo.Visible     := True;
//  aViewSysInfo.Visible  := True;
  aViewFields.Visible   := True;

  aEditFields.Visible   := True;
  aEditParams.Visible   := False;
  aEditUDRArray.Visible := False;
  aEditUDVector.Visible := False;

  aSpecialEdit1.Visible := False;
  aSpecialEdit2.Visible := False;
  aSpecialEdit3.Visible := False;

  aSpecialEdit1.ImageIndex := -1;

  aUDMemLoad.Visible      := False;
  aUDMemSave.Visible      := False;
  aUDMemViewAsText.Visible := False;

  //*** set Rename and Deleete Actions visibility

  aEdRename.Visible  := True;
  aEdDelete.Visible  := True;
  if ParentUObj = nil then
  begin
    aEdRename.Visible  := False;
    aEdDelete.Visible  := False;
  end;

  //*** set common editors visibility

  if UObj is TK_UDRArray then // UDRArray or UDComponent
  begin
    aEditParams.Visible   := True;
    aEditUDRArray.Visible := True;

    if UObj is TN_UDCompBase then
      miEditUObj.Caption := 'Edit Component'
    else
      miEditUObj.Caption := 'Edit Params'

  end; // if UObj is TK_UDRArray then // UDRArray or UDComponent

  if UObj is TN_UDCompBase then // Check Component type
  begin
    ExpFlags := TN_UDCompBase(UObj).GetExpFlags();

    if cefExec in ExpFlags then aExecuteComp.Visible := True;

    if cefGDI in ExpFlags then
    begin
      aViewMain.Visible := True;
      aViewMain.ImageIndex := 33;
    end;

    if cefTextFile in ExpFlags then
    begin
      aViewMain.Visible := True;
      aViewMain.ImageIndex := 164;
    end;

    if cefWordDoc in ExpFlags then
    begin
      aViewMain.Visible := True;
      aViewMain.ImageIndex := 165;
    end;

    if cefExcelDoc in ExpFlags then
    begin
      aViewMain.Visible := True;
      aViewMain.ImageIndex := 166;
    end;

  end; // if UObj is TN_UDCompBase then // Check Component type

  if (UObj is TK_UDVector) and not (UObj is TK_UDDCSSpace) then
    aEditUDVector.Visible := True;

  //*** set SpecialEdit 1,2,3 visibility and caption

  if UObj is TN_UCObjLayer then //******************** CoordsObj Layer
  begin
    aViewMain.Visible    := True;
    aViewMain.ImageIndex := 33;
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.ImageIndex := 43;
    aSpecialEdit1.Caption := 'Edit CObj Coords';
  end else if UObj is TN_UDMapLayer then //**************** Map Layer Component
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.ImageIndex := 43;
    aSpecialEdit1.Caption := 'Edit Map Layer Coords';
  end else if UObj is TK_UDCDim then //************************ Codes Dimension
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.ImageIndex := 181;
    aSpecialEdit1.Caption := 'Edit Codes Dimension';
  end else if UObj is TK_UDCSDim then //******************** Codes SubDimension
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.ImageIndex := 182;
    aSpecialEdit1.Caption := 'Edit Codes SubDimension';
  end else if UObj is TK_UDCDCor then //********** Codes SubDimensions Relation
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.Caption := 'Edit CSDim. Realation';
    aSpecialEdit1.ImageIndex := 183;
  end else if UObj is TK_UDCSDBlock then //************************* Data Block
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.Caption := 'Edit Data Block';
    aSpecialEdit1.ImageIndex := 184;
  end else if UObj is TK_UDMVWSite then //********* WEB Publication
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.Caption := 'Edit WEB Site Description';
    aSpecialEdit1.ImageIndex := 167;

       //************* Beg Obsolete
  end else if UObj is TK_UDDCSpace then //********* Codes Space
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.Caption := 'Edit Codes Space';
  end else if UObj is TK_UDDCSSpace then //******** Codes SubSpace
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.Caption := 'Edit Codes SubSpace';
  end else if UObj is TK_UDVector then //********** Data Vector or DCSProjection
  begin
    if TK_UDVector(UObj).IsDCSProjection then //*** Codes Space Projection
    begin
      aSpecialEdit1.Visible := True;
      aSpecialEdit1.Caption := 'Edit CS Projection';
    end;
       //************* End Obsolete

  end else if UObj is TN_UDLogFont then //********* UDLogFont (old Font Format)
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.ImageIndex := 41;
    aSpecialEdit1.Caption := 'Edit LogFont';
  end else if UObj is TN_UDNFont then //*********** UDNFont (new Font Format)
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.ImageIndex := 41;
    aSpecialEdit1.Caption := 'Edit NFont';
  end else if UObj is TN_UDDIB then //*********** TN_UDDIB (Image)
  begin
    aSpecialEdit1.Visible := True;
    aSpecialEdit1.ImageIndex := 4;
    aSpecialEdit1.Caption := 'Load Image';

    aSpecialEdit2.Visible := True;
    aSpecialEdit2.ImageIndex := 5;
    aSpecialEdit2.Caption := 'Save Image';
  end;

  miUObjName.Caption := UObj.ObjName; // to show selected UObjName as Last MenuItem Caption

  aViewInfo.Visible    := aViewInfo.Visible    and N_GetCLBValue( N_UObjFrMenuDescr, 'ViewInfo' );
//  aViewSysInfo.Visible := aViewSysInfo.Visible and N_GetCLBValue( N_UObjFrMenuDescr, 'ViewSysInfo' );
  aViewFields.Visible  := aViewFields.Visible  and N_GetCLBValue( N_UObjFrMenuDescr, 'ViewFields' );
  aEditFields.Visible  := aEditFields.Visible  and N_GetCLBValue( N_UObjFrMenuDescr, 'EditFields' );

//  if ((UObj.ObjFlags and K_fpObjSLSRMMask) <> 0) then //*** Archive Section
  if (UObj.ObjFlags and K_fpObjSLSRFMask) <> 0 then //*** Archive Section
  begin
    aArchSecLoad.Visible       := True;
    aArchSecSave.Visible       := True;
    aArchSecEditParams.Visible := True;
  end; // if ((UObj.ObjFlags and K_fpObjSLSRMMask) <> 0) then //*** Archive Section

  if UObj is TN_UDMem then //********************** TN_UDMem object
  begin
    aUDMemLoad.Visible      := True;
    aUDMemSave.Visible      := True;
    aUDMemViewAsText.Visible := True;
  end; // if UObj is TN_UDMem then //********************** TN_UDMem object



  K_RAFUDRefDefPathObj := UObj;
  end; // with N_MenuForm.UObjPopupMenu do
end; // procedure TN_UObjFrame.SetPopupMenuCaptionsByUObj

//**************************************** TN_UObjFrame.VTreeAction ***
// ExtProcObj VTree procedure
//
procedure TN_UObjFrame.VTreeAction( AParent: TWinControl; Node: TTreeNode;
                EventType: integer; Button: TMouseButton; Shift: TShiftState );

var
  DE: TN_DirEntryPar;
begin
  if ssDouble in Shift then
  begin
    TN_VNode(Node.Data).GetDirEntry( DE );
    if DE.Child is UObjClass then
    begin
      N_ud := DE.Child;
      N_s := DE.Child.ObjName;
//      N_s := ParentUObj.GetPathToObj( DE.Child );
//      N_s := ExcludeTrailingPathDelimiter( N_s );
      N_s := K_GetPathToUObj( DE.Child, ParentUObj );
      mb.Text := N_s;
//      N_s := ExcludeTrailingPathDelimiter(
//                                        ParentUObj.GetPathToObj( DE.Child ) );
//      mb.Text := ExcludeTrailingPathDelimiter(
//                                        ParentUObj.GetPathToObj( DE.Child ) );
      N_AddTextToTop( mb, MaxListSize );
      if AParent is TForm then
        TForm(AParent).Close;
    end;
  end;
end; // procedure TN_UObjFrame.VTreeAction

//*******************************************  N_ShowUObjActionsMenu  ********
// Show UObjFrame.PopupMenu and execute choosen action with given AUObj
//
// AStatusBar - StatusBar, where to show info messages (may be nil)
// AOwner     - Owner of all Forms, that could be opened in choosen action
//
procedure N_ShowUObjActionsMenu( AUObj: TN_UDBase; AStatusBar: TStatusbar;
                                                         AOwner: TN_BaseForm );
begin
  with N_MenuForm.frUObjCommon do
  begin
    SomeStatusBar := AStatusBar;
    OwnerForm := AOwner;
    UObj := AUObj;
    ParentUObj := nil;
    SetPopupMenuCaptionsByUObj();
    ShowStr( 'Choose Action for ' + UObj.ObjName );

    with Mouse.CursorPos do
      N_MenuForm.UObjPopupMenu.Popup( X, Y );
  end; // with N_MenuForm.frUObjCommon do
end; // end of procedure N_ShowUObjActionsMenu


end.
