unit N_UObj2Fr;
// low level UObject Actions,
//
// it can be used in Parent Controls as ComboBox with RightClick Menu
// Popup menu is on N_MenuForm to avoid it's duplicating in each Frame instance

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActnList,
  K_UDT1,
  N_Types;

type TN_UObj2Frame = class( TFrame )
    mb: TComboBox;
    UObj2ActList: TActionList;
    aSelectUObj: TAction;
    aSetToVtree: TAction;
    aShowUObjMenu: TAction;

    constructor Create ( AOwner: TComponent ); override;

    //*********************** UObjActList Actions ****************************

    procedure aSelectUObjExecute   ( Sender: TObject );
    procedure aSetToVtreeExecute   ( Sender: TObject );
    procedure aShowUObjMenuExecute ( Sender: TObject );

    //****************** UObj2Frame handlers

    procedure FrameContextPopup ( Sender: TObject; MousePos: TPoint;
                                                   var Handled: Boolean );
    procedure mbDblClick    ( Sender: TObject );
    procedure mbCloseUp     ( Sender: TObject );
    procedure mbKeyDown     ( Sender: TObject; var Key: Word;
                                                     Shift: TShiftState );
  public
    UObj:       TN_UDBase;
    ParentUObj: TN_UDBase;
    RootUObj:   TN_UDBase;
    MaxListSize: integer; // Max List Size in mb ComboBox

  procedure InitByTopPath ();
end; // type TN_UObj2Frame = class( TFrame )

implementation

uses
  K_FSelectUDB, K_RAEdit,
  N_Lib1, N_Lib2, N_NVTreeFr, N_MenuF, N_ME1;

{$R *.dfm}

//****************  TN_UObj2Frame class handlers  ******************

//******************************************** TN_UObj2Frame.Create ***
//
constructor TN_UObj2Frame.Create( AOwner: TComponent );
begin
  Inherited;
//  RootUObj := N_MapEditorDir;
  RootUObj := K_CurArchive;
  MaxListSize := 20;
end; // end_of constructor TN_UObj2Frame.Create


    //*********************** UObjActList Actions ****************************

procedure TN_UObj2Frame.aSelectUObjExecute( Sender: TObject );
// Select UObj in new VTree Form using K_SelectUDB
var
  DE: TN_DirEntryPar;
begin
  with N_MenuForm.CurUObj2Frame do // Self is N_MenuForm.frUObj2Common !!!
  begin
    if K_SelectDEOpen( DE, RootUObj, mb.Text ) then // DE Selected
    begin
//    UObj := K_SelectUDB( RootUObj, mb.Text );
    UObj := DE.Child;
    ParentUObj := DE.Parent;
//    mb.Text := RootUObj.GetRefPathToObj( UObj );
    mb.Text := K_GetPathToUObj( UObj, RootUObj );
    N_AddTextToTop( mb, MaxListSize );
    end;
  end;
end; // procedure TN_UObj2Frame.aSelectUObjExecute

procedure TN_UObj2Frame.aSetToVtreeExecute( Sender: TObject );
// Set UObj by currently Selected UObj in active VTreeFram
begin
//  N_s := Name; // debug
  if N_ActiveVTreeFrame = nil then Exit;

  with N_ActiveVTreeFrame do
  if SelectedExists() then
  with N_MenuForm.CurUObj2Frame do // Self is N_MenuForm.frUObj2Common !!!
  begin
    UObj := VTree.Selected.VNUDObj;
    ParentUObj := VTree.Selected.VNParent.VNUDObj;
//    mb.Text := RootUObj.GetRefPathToObj( UObj );
    mb.Text := K_GetPathToUObj( UObj, RootUObj );
    N_AddTextToTop( mb, MaxListSize );
  end;
end; // procedure TN_UObj2Frame.aSetToVtreeExecute

procedure TN_UObj2Frame.aShowUObjMenuExecute( Sender: TObject );
// Show standard UObj RightClick Menu
begin
  if N_MenuForm.CurUObj2Frame.UObj = nil then Exit;

  N_MenuForm.frUObjCommon.UObj       := N_MenuForm.CurUObj2Frame.UObj;
  N_MenuForm.frUObjCommon.ParentUObj := N_MenuForm.CurUObj2Frame.ParentUObj;

  K_RAFUDRefDefPathObj := N_MenuForm.CurUObj2Frame.UObj; // initially Selected UObj while Editing TN_UDBase field

  with N_MenuForm.frUObjCommon do
  begin
    SetPopupMenuCaptionsByUObj();

    with Mouse.CursorPos do
      N_MenuForm.UObjPopupMenu.Popup( X, Y );

  end; // with N_MenuForm.frUObjCommon do
end; // procedure TN_UObj2Frame.aShowUObjMenuExecute

    //****************** UObj2Frame handlers

procedure TN_UObj2Frame.FrameContextPopup( Sender: TObject;
                                      MousePos: TPoint; var Handled: Boolean );
// RightClick Event handler
begin
 // Save Self for using in N_MenuForm.frUObj2Common UObj2ActList handlers
  N_MenuForm.CurUObj2Frame := Self;

  N_MenuForm.miShowUObjMenu.Visible := (UObj <> nil);

  with Mouse.CursorPos do
    N_MenuForm.UObj2PopupMenu.Popup( X, Y );

  Handled := True;
end; // procedure TN_UObj2Frame.FrameContextPopup

procedure TN_UObj2Frame.mbDblClick( Sender: TObject );
// Set UObj by currently Selected UObj in active VTreeFram by DoubleClich
// (same as in aSetToVtree Action)
begin
  if N_ActiveVTreeFrame = nil then Exit;

  with N_ActiveVTreeFrame do
  if SelectedExists() then
  begin
    UObj := VTree.Selected.VNUDObj;
    ParentUObj := VTree.Selected.VNParent.VNUDObj;
//    mb.Text := RootUObj.GetRefPathToObj( UObj );
    mb.Text := K_GetPathToUObj( UObj, RootUObj );
    N_AddTextToTop( mb, MaxListSize );
  end;
end; // procedure TN_UObj2Frame.mbDblClick

procedure TN_UObj2Frame.mbCloseUp( Sender: TObject );
// just add choosen Items element to Top of Items list
begin
  N_AddTextToTop( mb, MaxListSize );
  InitByTopPath();
end; // procedure TN_UObj2Frame.mbCloseUp

procedure TN_UObj2Frame.mbKeyDown( Sender: TObject; var Key: Word;
                                                    Shift: TShiftState );
begin
  if Key = VK_RETURN then           // Enter - add mb.Text to Top of Items List
  begin
    N_AddTextToTop( mb, MaxListSize );
    InitByTopPath();
  end;
end; // procedure TN_UObj2Frame.mbKeyDown


    //***************  TN_UObj2Frame public methods  **********************

//**************************************** TN_UObj2Frame.InitByTopPath ***
// Init Self (set UObj and ParentUObj) by Path to UObj in Self.mb.Text
//
procedure TN_UObj2Frame.InitByTopPath();
var
  Str: string;
begin
  Str := mb.Items[mb.ItemIndex]; // same as mb.Text except in mb.OnCloseUp handler
  if Str = '' then
  begin
    UObj := nil;
    ParentUObj := nil;
    Exit;
  end;

  UObj := N_GetUObjByPath( RootUObj, Str, K_ontObjName );
  if UObj = nil then
  begin
    ParentUObj := nil;
    mb.Text := '?';
  end;
end; // procedure TN_UObj2Frame.InitByTopPath

end.
