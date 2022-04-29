unit N_Color1Fr;
// Color Visual Editing Frame (used in TN_Color1Form)

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ToolWin,
  K_FrRaEdit,
  N_Types, N_Lib1, Menus;

type TN_Color1Frame = class( TFrame ) //***** Frame for Visual Editing one Color
    sbRed: TScrollBar;
    Label1: TLabel;
    Label2: TLabel;
    sbGreen: TScrollBar;
    Label3: TLabel;
    sbBlue: TScrollBar;
    Label4: TLabel;
    sbY: TScrollBar;
    Label5: TLabel;
    sbS: TScrollBar;
    edBackColor: TEdit;
    ColorDialog: TColorDialog;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    mbTextColor: TComboBox;
    bnSetEmptyColor: TButton;
    bnCopy: TToolButton;
    bnPaste: TToolButton;
    Button1: TButton;
    bnCancel: TButton;
    bnOK: TButton;
    bnUndo: TButton;
    ToolButton3: TToolButton;
    PopupMenu: TPopupMenu;
    miGetColorbyCursor: TMenuItem;
    N1: TMenuItem;
    miAutoApplyMode: TMenuItem;
    miHighColorMode: TMenuItem;
    ToolButton4: TToolButton;
    bnSetCurrentColor: TButton;

    procedure miHighColorModeClick   ( Sender: TObject);
    procedure bnSetEmptyColorClick   ( Sender: TObject );
    procedure bnSetCurrentColorClick ( Sender: TObject );

    procedure sbRedScroll        ( Sender: TObject; ScrollCode: TScrollCode;
                                                    var ScrollPos: Integer );
    procedure sbGreenScroll      ( Sender: TObject; ScrollCode: TScrollCode;
                                                    var ScrollPos: Integer );
    procedure sbBlueScroll       ( Sender: TObject; ScrollCode: TScrollCode;
                                                    var ScrollPos: Integer );
    procedure sbYScroll          ( Sender: TObject; ScrollCode: TScrollCode;
                                                    var ScrollPos: Integer );
    procedure sbSScroll          ( Sender: TObject; ScrollCode: TScrollCode;
                                                    var ScrollPos: Integer );
    procedure edBackColorClick   ( Sender: TObject );
    procedure mbTextColorCloseUp ( Sender: TObject );
    procedure mbTextColorKeyDown ( Sender: TObject; var Key: Word;
                                                        Shift: TShiftState );
    procedure bnUndoClick        ( Sender: TObject );
    procedure bnApplyClick       ( Sender: TObject );
    procedure bnCancelClick      ( Sender: TObject );
    procedure bnOKClick          ( Sender: TObject );
    procedure edBackColorMouseDown ( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
    procedure edBackColorMouseMove ( Sender: TObject; Shift: TShiftState; X, Y: Integer );
    procedure edBackColorMouseUp   ( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
  private
    DRed, DGreen, DBlue: double;  // double Red, Gree, Blue values
    ChangedByYScrollBar: boolean; // Color was changed by Y ScrollBar
    RedoMode: boolean;            // used for Shift+Undo
    DragMode: boolean;    // used for choosing color by pixel under cursor while dragging
    SavedCursor: TCursor; // used for choosing color by pixel under cursor while dragging
  public
    ParentForm: TForm;         // ParentForm to Close on OK and Cancel
    CurColor: integer;         // current Color
    GAProcOfObj : TK_RAFGlobalActionProc; // to process OKToAll, CancelToAll)
    PData: Pointer;            // Pointer to field with Color to Edit
    UndoColors: TN_IArray;     // Saved Colors for Undo
    UndoFreeInd: integer;      // First free Index in UndoColors array
    UndoMaxInd:  integer;      // Max filled Index in UndoColors array

    function  GetMaxColor      ( AColor: integer ): integer;
    function  GetMinColor      ( AColor: integer ): integer;
    procedure SetFieldsByColor ( AColor: integer );
    procedure ChangeColor      ( AColor: integer );
end; // type TN_Color1Frame = class(TFrame)

implementation
uses Math,
  N_Lib0, N_ButtonsF;
{$R *.dfm}

//**************** TN_Color1Frame Event Hadlers ***********************

procedure TN_Color1Frame.miHighColorModeClick( Sender: TObject );
// round True Color to 16 bit Color (miHighColorMode OnClick event handler)
begin
  if miHighColorMode.Checked then
  begin
    SetFieldsByColor( edBackColor.Color );
  end;
end;

procedure TN_Color1Frame.bnSetEmptyColorClick( Sender: TObject );
// Set Empty Color (N_EmptyColor = -1) and Close
begin
  SetFieldsByColor( N_EmptyColor );
  bnOKClick( Sender );
end; // procedure TN_Color1Frame.bnSetEmptyClick

procedure TN_Color1Frame.bnSetCurrentColorClick( Sender: TObject );
// Set Current Color (N_CurColor = -3)  and Close
begin
  SetFieldsByColor( N_CurColor );
  bnOKClick( Sender );
end; // procedure TN_Color1Frame.bnSetCurrentColorClick

procedure TN_Color1Frame.sbRedScroll( Sender: TObject;
                             ScrollCode: TScrollCode; var ScrollPos: Integer );
// change Color by its new Red component value (sbRedScroll OnScroll event handler)
begin
  SetFieldsByColor( (edBackColor.Color and $FFFF00) or ScrollPos );
end; // procedure TN_Color1Frame.sbRedScroll

procedure TN_Color1Frame.sbGreenScroll( Sender: TObject;
                             ScrollCode: TScrollCode; var ScrollPos: Integer );
// change Color by its new Green component value (OnScroll event handler)
begin
  SetFieldsByColor( (edBackColor.Color and $FF00FF) or (ScrollPos shl 8) );
end; // procedure TN_Color1Frame.sbGreenScroll

procedure TN_Color1Frame.sbBlueScroll( Sender: TObject;
                             ScrollCode: TScrollCode; var ScrollPos: Integer );
// change Color by its new Blue component value (OnScroll event handler)
begin
  SetFieldsByColor( (edBackColor.Color and $00FFFF) or (ScrollPos shl 16) );
end; // procedure TN_Color1Frame.sbBlueScroll

procedure TN_Color1Frame.sbYScroll( Sender: TObject;
                             ScrollCode: TScrollCode; var ScrollPos: Integer );
// change Color by its new Brightnes value (OnScroll event handler)
// (Brightnes is treated as Max(R,G,B) )
var
  MaxComponent, OldRed, OldGreen, OldBlue, NewColor: integer;
  Coef: double;
begin
  MaxComponent := GetMaxColor( edBackColor.Color );
  OldRed   := edBackColor.Color and $FF;
  OldGreen := (edBackColor.Color shr 8) and $FF;
  OldBlue  := (edBackColor.Color shr 16) and $FF;

  // icremental changing is not possible because of unproper rounding
  // use as base values thouse, that were then Y ScrollBar began to change

  if not ChangedByYScrollBar then
  begin
    DRed   := OldRed;
    DGreen := OldGreen;
    DBlue  := OldBlue;
  end;

  NewColor := 0;
  if MaxComponent = 0 then
  begin
    NewColor := 0;
  end else if MaxComponent = OldRed then
  begin
    Coef := ScrollPos / DRed;
    NewColor := (Round(DBlue*Coef) shl 16) or
                (Round(DGreen*Coef) shl 8) or ScrollPos;
  end else if MaxComponent = OldGreen then
  begin
    Coef := ScrollPos / DGreen;
    NewColor := (Round(DBlue*Coef) shl 16) or
                (ScrollPos shl 8) or Round(DRed*Coef);
  end else if MaxComponent = OldBlue then
  begin
    Coef := ScrollPos / DBlue;
    NewColor := (ScrollPos shl 16) or (Round(DGreen*Coef) shl 8) or
                 Round(DRed*Coef);
  end;

  // (by gefault, in SetFieldsByColor proc ChangedByYScrollBar set to False)
  SetFieldsByColor( NewColor );
  ChangedByYScrollBar := True;
end; // end of procedure TN_Color1Frame.sbYScroll

procedure TN_Color1Frame.sbSScroll( Sender: TObject;
                             ScrollCode: TScrollCode; var ScrollPos: Integer );
// change Color by its new Saturation value (OnScroll event handler)
// (Saturation is treated as Min(R,G,B) )
var
  MinComponent, tRed, tGreen, tBlue, NewColor, Delta: integer;
begin
  MinComponent := GetMinColor( edBackColor.Color );
  tRed   := edBackColor.Color and $FF;
  tGreen := (edBackColor.Color shr 8) and $FF;
  tBlue  := (edBackColor.Color shr 16) and $FF;

  if MinComponent = tRed        then Delta := ScrollPos - tRed
  else if MinComponent = tGreen then Delta := ScrollPos - tGreen
  else if MinComponent = tBlue  then Delta := ScrollPos - tBlue
  else                               Delta := 0;

  tRed   := Min( 255, tRed+Delta );
  tGreen := Min( 255, tGreen+Delta );
  tBlue  := Min( 255, tBlue+Delta );

  NewColor := (tBlue shl 16) or (tGreen shl 8) or tRed;
  SetFieldsByColor( NewColor );
end; // end of procedure TN_Color1Frame.sbSScroll

procedure TN_Color1Frame.edBackColorClick( Sender: TObject );
// call Windows Color Dialog (edBackColor OnClick event handler)
begin
  ColorDialog.Color := CurColor;
  if ColorDialog.Execute then // color was choosen in dialog
  begin
    SetFieldsByColor( ColorDialog.Color );
  end;
end; // end of procedure TN_Color1Frame.edBackColorClick

procedure TN_Color1Frame.mbTextColorCloseUp( Sender: TObject );
// update all fields by choosen color
begin
  SetFieldsByColor( N_StrToColor( mbTextColor.Items[mbTextColor.ItemIndex] ) );
end; // procedure TN_Color1Frame.mbTextColorCloseUp

procedure TN_Color1Frame.mbTextColorKeyDown( Sender: TObject; var Key: Word;
                                                          Shift: TShiftState );
// Change Color by its new Hex value,
// add to Items Top by Enter or delete from Items by Ctrl+D (or Shift+Delete?)
begin
  if Key = VK_RETURN then
    SetFieldsByColor( N_StrToColor( mbTextColor.Text ) );

  N_MBKeyDownHandler1( Sender, Key, Shift );
end; // end of TN_Color1Frame.mbTextColorKeyDown

procedure TN_Color1Frame.bnUndoClick( Sender: TObject );
// Undo or Redo Changing Color
begin
  if N_KeyIsDown( VK_SHIFT ) then // Redo Changing Color
  begin
    if UndoFreeInd <= UndoMaxInd then // Color for Redo exists
    begin
      RedoMode := True; // to prevent saving Color in Apply+Shift
      SetFieldsByColor( UndoColors[UndoFreeInd] );
      RedoMode := False;
      Inc( UndoFreeInd );
    end;
  end else if N_KeyIsDown( VK_CONTROL ) then // Undo All - Restore initial Color
  begin
    SetFieldsByColor( UndoColors[0] );
    UndoFreeInd := 1;
  end else //*************** Undo Changing Color (restore last saved Color)
  begin
    SetFieldsByColor( UndoColors[UndoFreeInd-1] );

    if UndoFreeInd = 1 then Exit;
    Dec( UndoFreeInd );
  end;
end; // procedure TN_Color1Frame.bnUndoClick

procedure TN_Color1Frame.bnApplyClick( Sender: TObject );
// Change Color by external Procedure of Object,
// Save in UndoColors is Shift pressed
begin
  ChangeColor( CurColor );
  if Assigned(GAProcOfObj) then GAProcOfObj( Self, K_fgaApplyToAll );
  if N_KeyIsDown( VK_SHIFT ) and not RedoMode then
  begin
    if Length(UndoColors) < (UndoFreeInd+1) then
      SetLength( UndoColors, UndoFreeInd+10 );
    UndoColors[UndoFreeInd] := CurColor;
    UndoMaxInd := UndoFreeInd;
    Inc( UndoFreeInd );
  end;
end; // procedure TN_Color1Frame.bnApplyClick

procedure TN_Color1Frame.bnCancelClick( Sender: TObject );
// Cancel changing Color
begin
  ParentForm.Close();
  if N_KeyIsDown( VK_SHIFT ) then
    if Assigned(GAProcOfObj) then GAProcOfObj( Self, K_fgaCancelToAll );
end; // procedure TN_Color1Frame.bnCancelClick

procedure TN_Color1Frame.bnOKClick( Sender: TObject );
// Apply (ChangeColor) and Close Form
begin
  bnApplyClick( Sender );
  ParentForm.Close();
  if N_KeyIsDown( VK_SHIFT ) then
    if Assigned(GAProcOfObj) then GAProcOfObj( Self, K_fgaOKToAll );
end; // procedure TN_Color1Frame.bnOKClick


procedure TN_Color1Frame.edBackColorMouseDown( Sender: TObject;
                      Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
// begin dragging - choosing color by pixel under cursor while dragging
begin
  DragMode := True;
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHandPoint;
end; // procedure TN_Color1Frame.edBackColorMouseDown

procedure TN_Color1Frame.edBackColorMouseMove( Sender: TObject;
                                          Shift: TShiftState; X, Y: Integer );
// set current color by color of any screen pixel that is under cursor (while dragging)
// (you can DRAG cursor out of self windows with getting MouseMove events!)
var
  ScreenHDC: HDC;
begin
  if not DragMode then Exit;

  ScreenHDC := windows.GetDC( 0 );
  with Mouse.CursorPos do
    SetFieldsByColor( windows.GetPixel( ScreenHDC, X, Y ) );
end; // procedure TN_Color1Frame.edBackColorMouseMove

procedure TN_Color1Frame.edBackColorMouseUp( Sender: TObject;
                      Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
// finish dragging (color was already set in OnMouseMove handler)
begin
  DragMode := False;
  Screen.Cursor := SavedCursor;
end; // procedure TN_Color1Frame.edBackColorMouseUp


//********** TN_Color1Frame Public methods  **************

//******************************************* TN_Color1Frame.GetMaxColor
// get Max of R, G, B Color Components
//
function TN_Color1Frame.GetMaxColor( AColor: integer ): integer;
var
  ColorComponent: integer;
begin
  Result := AColor and $FF;                  //*** Red value
  ColorComponent := (AColor shr 8) and $FF;  //*** Green value
  Result := Max( ColorComponent, Result);
  ColorComponent := (AColor shr 16) and $FF; //*** Blue value
  Result := Max( ColorComponent, Result);
end; // function TN_Color1Frame.GetMaxColor

//******************************************* TN_Color1Frame.GetMinColor
// get Min of R, G, B Color Components
//
function TN_Color1Frame.GetMinColor( AColor: integer ): integer;
var
  ColorComponent: integer;
begin
  Result := AColor and $FF;                  //*** Red value
  ColorComponent := (AColor shr 8) and $FF;  //*** Green value
  Result := Min( ColorComponent, Result);
  ColorComponent := (AColor shr 16) and $FF; //*** Blue value
  Result := Min( ColorComponent, Result);
end; // function TN_Color1Frame.GetMinColor

//******************************************* TN_Color1Frame.SetFieldsByColor
// set all fields and ScrollBars positions by given AColor
// (round AColor to 16 bit accuracy if miHighColorMode is Checked)
//
procedure TN_Color1Frame.SetFieldsByColor( AColor: integer );
begin
  if miHighColorMode.Checked then
    AColor := N_RoundTo16bitColor( AColor );

  CurColor := AColor;

{
  if AColor = N_CurColor then
  begin
    if miAutoApplyMode.Checked then
      bnApplyClick( nil );

    Exit;
  end;
}
  if CurColor >= 0 then // normal Color
  begin
    edBackColor.Color := CurColor;
    mbTextColor.Text  := N_ColorToHTMLHex( CurColor );
    AColor := CurColor; // set all Scrollbars to CurColor
  end else // CurColor < 0, some Special Color (-1 - Transparent, -2 - Current, ...)
  begin
    edBackColor.Color := N_clWhite;

    case CurColor of // set mbTextColor.Text (format should be compatibale with N_StrToColor) 
      -1: mbTextColor.Text  := 'none (-1)';
      -2: mbTextColor.Text  := 'cur. (-2)';
    else
          mbTextColor.Text  := Format( 'spec. %d', [CurColor] );
    end;

    AColor := N_clBlack; // set all Scrollbars to black
  end;

  sbRed.Position   := AColor and $FF;          //*** Red value
  sbGreen.Position := (AColor shr 8) and $FF;  //*** Green value
  sbBlue.Position  := (AColor shr 16) and $FF; //*** Blue value
                                     // (Brightnes is treated as Max(R,G,B) )
  sbY.Position     := GetMaxColor( AColor );   //*** Y value (brightnes)
                                     // (Saturation is treated as Min(R,G,B) )
  sbS.Position     := GetMinColor( AColor );   //*** S value (saturation)

  ChangedByYScrollBar := False; // OK for all controls but Y-ScrollBar

  if miAutoApplyMode.Checked then
    bnApplyClick( nil );

  if ParentForm.Visible then // to avoid ScrollBars blinking
    ParentForm.ActiveControl := bnOK;
end; // end of procedure TN_Color1Frame.SetFieldsByColor

//******************************************* TN_Color1Frame.ChangeColor
// Change field with Color (that is beeing edited)
//
procedure TN_Color1Frame.ChangeColor( AColor: integer );
begin
  move( AColor, PData^, Sizeof(AColor) );
  if Assigned(GAProcOfObj) then GAProcOfObj( Self, K_fgaOK );
end; // end of procedure TN_Color1Frame.ChangeColor


end.
