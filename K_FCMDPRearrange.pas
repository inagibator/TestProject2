unit K_FCMDPRearrange;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ToolWin, ComCtrls, StdCtrls,
  N_BaseF, N_Types;

type
  TK_FormCMDPRearrange = class(TN_BaseForm)
    ToolBar1: TToolBar;
    BtOK: TButton;
    BtCancel: TButton;
    DragTimer: TTimer;
    procedure FormShow(Sender: TObject);
    procedure ToolButtonMouseDown(Sender: TObject; Button: TMouseButton;
                                  Shift: TShiftState; X, Y: Integer);
    procedure DragTimerTimer(Sender: TObject);
    procedure ToolButtonDragOver(Sender, Source: TObject; X, Y: Integer;
                                 State: TDragState; var Accept: Boolean);
    procedure ToolButtonEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure ToolBar1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    SInds : TN_IArray;
    ProfilesCount : Integer;
    CurDragTBObject : TToolButton;
    procedure RebuildView();
  public
    { Public declarations }
  end;

var
  K_FormCMDPRearrange: TK_FormCMDPRearrange;

implementation

{$R *.dfm}

uses K_CM0, K_VFunc, K_Script1,
     N_Lib0, N_CMMain5F;

//******************************************* TK_FormCMDPRearrange.FormShow ***
// OnShow event handler
//
//     Parameters
// Sender - Self
//
procedure TK_FormCMDPRearrange.FormShow(Sender: TObject);
{}
var
  i : Integer;
  WTB : TToolButton;
{}
begin
{}
//ProfilesCount := 8;
  ProfilesCount := K_CMEDAccess.ProfilesList.ALength;
  Self.ClientWidth := ProfilesCount * ToolBar1.ButtonWidth + 10 + 10 * Round(Int(ProfilesCount/6));
  ToolBar1.Images := N_CM_MainForm.CMMCurBigIcons;
  SetLength( SInds, ProfilesCount );
  K_FillIntArrayByCounter( @SInds[0], Length(SInds) );
  for i := 0 to ProfilesCount - 1 do
  begin
    if i = ProfilesCount - 6 then
    begin
      WTB := TToolButton.Create(ToolBar1);
      WTB.Style := tbsDivider;
//      WTB.Style := tbsSeparator;
      WTB.Width := 10;
      WTB.Parent := ToolBar1;
      WTB.Tag := -1;
    end;

    WTB := TToolButton.Create(ToolBar1);
//    NewToolButton := TK_ToolButton.Create(Self);
    with WTB do
    begin
      Parent := ToolBar1;
      OnDragOver  := ToolButtonDragOver;
      OnEndDrag   := ToolButtonEndDrag;
      OnMouseDown := ToolButtonMouseDown;
      ShowHint := TRUE;
    end; // with WTB do
  end; // for i := 0 to ProfilesCount - 1 do

  RebuildView();
{}
end; // procedure TK_FormCMDPRearrange.FormShow

//******************************** TK_FormCMDPRearrange.ToolButtonMouseDown ***
// ToolButton OnMouseDown event handler
//
procedure TK_FormCMDPRearrange.ToolButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  inherited;
  if not (ssLeft in Shift) or (TToolButton(Sender).Tag < 0)  then Exit;
  CurDragTBObject := TToolButton(Sender);
  DragTimer.Enabled := TRUE;
end; // procedure TK_FormCMDPRearrange.ToolButtonMouseDown

//************************************ TK_FormCMDPRearrange.CDragTimerTimer ***
// Timer OnTimer event handler
//
procedure TK_FormCMDPRearrange.DragTimerTimer(Sender: TObject);
begin
//  inherited;
  DragTimer.Enabled := false;

  if not N_KeyIsDown(VK_LBUTTON) or (CurDragTBObject = nil) then Exit;

  CurDragTBObject.BeginDrag( TRUE );
end; // procedure TK_FormCMDPRearrange.DragTimerTimer

//********************************* TK_FormCMDPRearrange.ToolButtonDragOver ***
// OnDragOver event handler for ToolButton
//
//     Parameters
// Sender - Dragging over ToolButton
// Source - Dragging Object (ToolButton or Action)
// X,Y    - Cursor coordinates
// State  - Drag State
// Accept - set TRUE if EndDrag is possible
//
procedure TK_FormCMDPRearrange.ToolButtonDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (CurDragTBObject <> Sender);
end; // procedure TK_FormCMDPRearrange.ToolButtonDragOver

//********************************** TK_FormCMDPRearrange.ToolButtonEndDrag ***
// OnEndDrag event handler for existing ToolButton
//
//     Parameters
// Sender - Dragging ToolButton
// Target - Target Object (ToolBar or ToolButton)
// X,Y    - Cursor coordinates
//
procedure TK_FormCMDPRearrange.ToolButtonEndDrag( Sender, Target: TObject; X,
  Y: Integer );
var
  Ind, TInd, VInd : Integer;
begin
  if (CurDragTBObject = nil) or (Target = nil)then Exit;
  Ind := CurDragTBObject.Tag;
  if Target = ToolBar1 then
  begin  // Move to the end of list
    if Ind >= ProfilesCount - 1 then Exit;
    VInd := SInds[Ind];
//    TInd := ProfilesCount - Ind - 1;
//    move( SInds[TInd + 1], SInds[TInd], (ProfilesCount - Ind - 1) * SizeOf(Integer) );
    move( SInds[Ind + 1], SInds[Ind], (ProfilesCount - Ind - 1) * SizeOf(Integer) );
    SInds[ProfilesCount - 1] := VInd;
    RebuildView();
  end
  else
  if (Target is TToolButton) and (TToolButton(Target).Parent = ToolBar1) then
  begin // Switch Target Button and CurDragTBObject
    TInd := TToolButton(Target).Tag;
    VInd := SInds[Ind];
    SInds[Ind]  := SInds[TInd];
    SInds[TInd] := VInd;
    RebuildView();
  end;
end; // procedure TK_FormCMDPRearrange.ToolButtonEndDrag

//********************************* TK_FormCMDPRearrange.ToolButtonDragOver ***
// OnDragOver event handler for ToolBar
//
//     Parameters
// Sender - Dragging over ToolButton
// Source - Dragging Object (ToolButton or Action)
// X,Y    - Cursor coordinates
// State  - Drag State
// Accept - set TRUE if EndDrag is possible
//
procedure TK_FormCMDPRearrange.ToolBar1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (X >= ToolBar1.ButtonWidth * ProfilesCount + 10 * Round(Int(ProfilesCount/6))) and
            (CurDragTBObject <> nil) and
            (CurDragTBObject.Tag < ProfilesCount - 1);
end; // procedure TK_FormCMDPRearrange.ToolBar1DragOver

//**************************************** TK_FormCMDPRearrange.RebuildView ***
//
procedure TK_FormCMDPRearrange.RebuildView;
var
  i, Ind : Integer;
begin
  Ind := 0;
  for i := 0 to ToolBar1.ButtonCount - 1 do
    with ToolBar1.Buttons[i] do
    begin
      if Tag < 0 then Continue;
      Tag := Ind;
      with TK_PCMDevProfListElem((K_CMEDAccess.ProfilesList.PDE(SInds[Tag])))^ do
      begin
        with TK_PCMDeviceProfile(TK_UDRArray(CMDPLEARef).PDE(CMDPLEAInd))^ do
        begin
          ImageIndex := CMDPDelphiAction.ImageIndex;
          Hint := CMDPDelphiAction.Hint;
        end; // with TK_PCMDeviceProfile
      end; // with TK_PCMDevProfListElem
      Inc(Ind);
    end; // with WTB do

  CurDragTBObject := nil;

end; // procedure TK_FormCMDPRearrange.RebuildView

//************************************* TK_FormCMDPRearrange.FormCloseQuery ***
// OnCloseQuery event handler
//
procedure TK_FormCMDPRearrange.FormCloseQuery( Sender: TObject;
  var CanClose: Boolean );
var
  i : Integer;
  BProfilesList : array of TK_CMDevProfListElem;
begin

  if ModalResult <> mrOK then Exit;
  SetLength( BProfilesList, ProfilesCount );
  Move( TK_PCMDevProfListElem((K_CMEDAccess.ProfilesList.PDE(0)))^,
        BProfilesList[0], SizeOf(TK_CMDevProfListElem) * ProfilesCount );
  for i := 0 to ProfilesCount - 1 do
    TK_PCMDevProfListElem((K_CMEDAccess.ProfilesList.PDE(i)))^ := BProfilesList[SInds[i]];

end; // procedure TK_FormCMDPRearrange.FormCloseQuery

end.
