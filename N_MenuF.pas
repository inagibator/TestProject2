unit N_MenuF;
// Form with Popup Menus and common Actions
// (is created by Delphi and should always exists but is nether Shown)
// (having Popup menus in some frame (such as N_UObjFrame) causes many menu instances)

// Contains:
// UObjPopupMenu   with Actions in UObjActList  in TN_UObjFrame
// UObj2PopupMenu  with Actions in UObj2ActList in TN_UObj2Frame

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, N_UObjFr, Menus,
  N_Types, N_Lib1, N_ClassRef, N_UObj2Fr, StdCtrls, ActnList;

type TN_UObjMenuMode = ( ummFull, ummShort );

type TN_MenuForm = class( TForm ) //**************************
    UObjPopupMenu: TPopupMenu;
    miViewAsMap1: TMenuItem;
    miViewInfo1: TMenuItem;
    miViewFields1: TMenuItem;
    N1: TMenuItem;
    EditFields1: TMenuItem;
    miEditUObj: TMenuItem;
    miEditDataSys: TMenuItem;
    miEditUDVector1: TMenuItem;
    miSpecialEdit11: TMenuItem;
    miSpecialEdit21: TMenuItem;
    miSpecialEdit31: TMenuItem;
    N4: TMenuItem;
    miEdRename1: TMenuItem;
    miEdDelete1: TMenuItem;
    N3: TMenuItem;
    miUObjName: TMenuItem;
    frUObjCommon: TN_UObjFrame;
    miExecuteComp: TMenuItem;
    UObj2PopupMenu: TPopupMenu;
    miSelectUObj: TMenuItem;
    miSetToSelected: TMenuItem;
    miShowUObjMenu: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    frUObj2Common: TN_UObj2Frame;
    LoadSelffromMVFile1: TMenuItem;
    SaveSelfToMVFile1: TMenuItem;
    ViewSelfAsHex1: TMenuItem;
    aArchSecLoad1: TMenuItem;
    aArchSecSave1: TMenuItem;
    aArchSecEditParams1: TMenuItem;
    OpenDialog: TOpenDialog;
    CommonActions: TActionList;
    aProtocolView: TAction;
  public
    CurUObj2Frame: TN_UObj2Frame; // Frame that causes UObj2PopupMenu
//    procedure PrepUObjPopupMenu( AMode: TN_UObjMenuMode );
end; // type TN_MenuForm = class( TForm )

var
  N_MenuForm: TN_MenuForm; // always exists and can be used in any handlers

implementation
{$R *.dfm}
uses
  K_DCSpace, K_FDCSpace, K_FDCSSpace, K_FDCSProj,
  K_Script1, K_FRaEdit, K_RAEdit, K_FrRaEdit, K_FUDV,
  N_UDCMap, N_GetUObjF, N_Lib2, N_EdStrF, N_MsgDialF, N_ME1, N_RaEditF,
  N_CompBase, N_ButtonsF, N_Rast1Fr, N_RVCTF, N_PlainEdF, N_UDat4;

//********************  TN_MenuForm  methods ************************
{
//***************************** TN_MenuForm.PrepUObjPopupMenu ***
// Set UObjPopupMenu Items Names and visibility by UObj type
//
procedure TN_MenuForm.PrepUObjPopupMenu( AMode: TN_UObjMenuMode );
begin
  with frUObjCommon do
  begin
  // prelimenary settings:
   aViewAsMap.Visible    := False;
  aViewInfo.Visible     := True;
  aViewSysInfo.Visible  := True;
  aViewFields.Visible   := True;

  aEditFields.Visible   := True;
  aEditParams.Visible   := False;
  aEditUDRArray.Visible := False;
  aEditUDVector.Visible := False;

  aSpecialEdit1.Visible := False;
  aSpecialEdit2.Visible := False;
  aSpecialEdit3.Visible := False;

  //*** set Rename and Deleete Actions visibility

  aEdRename.Visible  := True;
  aEdDelete.Visible  := True;
  if ParentUObj = nil then
  begin
    aEdRename.Visible  := False;
    aEdDelete.Visible  := False;
  end;

  //*** set common editors visibility

  if UObj is TK_UDRArray then
  begin
    aEditParams.Visible   := True;
    aEditUDRArray.Visible := True;

    if UObj is TN_UDCompBase then
      miEditUObj.Caption := 'Edit Component'
    else
      miEditUObj.Caption := 'Edit Params'

  end; // if UObj is TK_UDRArray then


  if UObj is TN_UDCompVis then
    aViewAsMap.Visible := True;

  if (UObj is TK_UDVector) and not (UObj is TK_UDDCSSpace) then
    aEditUDVector.Visible := True;

  //*** set SpecialEdit1 visibility and caption

  if UObj is TN_UCObjLayer then //***************** CoordsObj Layer
  begin
    aSpecialEdit1.Visible := True;
    miSpecialEdit11.Caption := 'Edit CObj Coords';
  end else if UObj is TN_UDMapLayer then //******** Map Layer Component
  begin
    aSpecialEdit1.Visible := True;
    miSpecialEdit11.Caption := 'Edit Map Layer Coords';
  end else if UObj is TK_UDDCSSpace then //******** Codes SubSpace
  begin
    aSpecialEdit1.Visible := True;
    miSpecialEdit11.Caption := 'Edit Codes Space';
  end else if UObj is TK_UDDCSSpace then //******** Codes SubSpace
  begin
    aSpecialEdit1.Visible := True;
    miSpecialEdit11.Caption := 'Edit Codes SubSpace';
  end else if UObj is TK_UDVector then //********** Data Vector or DCSProjection
  begin
    if TK_UDVector(UObj).IsDCSProjection then //*** Codes Space Projection
    begin
      aSpecialEdit1.Visible := True;
      miSpecialEdit11.Caption := 'Edit CS Projection';
    end;
  end else if UObj is TN_UDLogFont then //********* UDLogFont
  begin
    aSpecialEdit1.Visible := True;
    miSpecialEdit11.Caption := 'Edit LogFont';
  end else if UObj is TN_UDText then //********* UDText
  begin
    aSpecialEdit1.Visible := True;
    miSpecialEdit11.Caption := 'Edit UDText';
  end;

  miUObjName.Caption := UObj.ObjName; // to show selected UObjName as Last MenuItem Caption

  aViewInfo.Visible       := aViewInfo.Visible       and N_GetCLBValue( N_UObjFrMenuDescr, 'ViewInfo' );
  aViewSysInfo.Visible    := aViewSysInfo.Visible    and N_GetCLBValue( N_UObjFrMenuDescr, 'ViewSysInfo' );
  aViewFields.Visible     := aViewFields.Visible     and N_GetCLBValue( N_UObjFrMenuDescr, 'ViewFields' );
  aEditFields.Visible     := aEditFields.Visible     and N_GetCLBValue( N_UObjFrMenuDescr, 'EditFields' );

  K_RAFUDRefDefPathObj := UObj;
  end;
end; // procedure TN_MenuForm.PrepUObjPopupMenu
}


end.
