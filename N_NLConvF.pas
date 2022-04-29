unit N_NLConvF;
// Non Linear 3Rects Convertion Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Contnrs,
  K_UDT1, K_Script1,
  N_Types, N_Lib1, N_BaseF, N_Rast1Fr, N_CompBase, N_Comp1, N_2DFunc1,
  ActnList, Menus;

type TN_NLConvForm = class( TN_BaseForm )
    StatusBar: TStatusBar;
    PageControl: TPageControl;
    tsMain: TTabSheet;
    tsCoords: TTabSheet;
    rgRectsToChange: TRadioGroup;
    cbFixedCenter: TCheckBox;
    cbHideRects: TCheckBox;
    edNXNY: TLabeledEdit;
    edEnvRect: TLabeledEdit;
    edSrcRect: TLabeledEdit;
    edDstRect: TLabeledEdit;
    cbStayOnTop: TCheckBox;
    cbMatrIsVisible: TCheckBox;
    tsColors: TTabSheet;
    edEnvRectAttr: TLabeledEdit;
    edSrcRectAttr: TLabeledEdit;
    edDstRectAttr: TLabeledEdit;
    edMatrAttr: TLabeledEdit;
    edMatrColor: TEdit;
    edEnvRectColor: TEdit;
    edSrcRectColor: TEdit;
    edDstRectColor: TEdit;
    ActionList1: TActionList;
    aRectsCenterSrcDst: TAction;
    bnConvert: TButton;
    bnShowMenu: TButton;
    NLConvPopupMenu: TPopupMenu;
    CenterSrcDstRects1: TMenuItem;
    tsView: TTabSheet;
    aRectsSameSrcDst: TAction;
    SameSrcDstRects1: TMenuItem;
    aRectsScaleDst: TAction;
    ScaleDstbySrcRect1: TMenuItem;

    //**************** ActionList OnExecute event handlers *************

    //**************** Rects Actions ***********************************
    procedure aRectsCenterSrcDstExecute ( Sender: TObject );
    procedure aRectsSameSrcDstExecute   ( Sender: TObject );
    procedure aRectsScaleDstExecute     ( Sender: TObject );

    //**************** TN_NLConvForm Controls event handlers ***********
    procedure RedrawRectsAndMatr ( Sender: TObject );
    procedure bnConvertClick     ( Sender: TObject );
    procedure bnShowMenuClick    ( Sender: TObject );
    procedure EditColor          ( Sender: TObject );
    procedure cbStayOnTopClick   ( Sender: TObject );
    procedure PageControlChange  ( Sender: TObject );
    procedure edNXNYKeyDown      ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure edRedrawOnKeyDown  ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormClose          ( Sender: TObject; var Action: TCloseAction ); override;
  private
    NLCFOwnerForm:   TN_BaseForm;     // Owner Form, may be nil
    NLCFEd3RectsRFA: TN_RFrameAction; // TN_Ed3RectsRFA RasterFrame Action
  public
    UDActionComp: TN_UDAction; // UDAction with params and UDRArray children
    DstCObjDir: TN_UDBase; // Destination CObjects Dir (with CObjects to Convert)
    SrcCObjDir: TN_UDBase; // Source CObjects Dir, if <> nil Dst CObjects would be
                           // initialized by Source CObjects before convertion
    MapRoot:    TN_UDBase; // MapRoot Component (that shows Dst CObjects)
    ScaleCoef:  float;     // MapRoot.CompUCoords Scale Coef

    RectsConvObj: TN_RectsConvObj; // Three Rects Non Linear Convertion Obj
    MatrConvObj:  TN_MatrConvObj;  // Matr Non Linear Convertion Obj (owned by UDActionComp!)

    procedure ConvertMatrPoints  ();
    procedure FillCoordsTabSheet ();

    procedure CloseSelf ();
    procedure ShowStr   ( AStr: string );
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_NLConvForm = class( TN_BaseForm )

type TN_Ed3RectsRFA = class( TN_RFrameAction ) // Edit 3 Rects RFrame Action
  E3RControlForm: TN_NLConvForm; // Self Control Form
  E3RIndToEdit: integer;         // Rect Index To Edit
  E3RRectsU: Array [0..2] of TFRect; // 0-EnvRect, 1-SrcRect, 2-DstRect User Coords
  E3RFlags: Array [0..2] of integer; // Cursor position relative to Rect Flags
  E3RSavedCC: TPoint;                // Saved Cursor CCBuf coords at MouseDown
  E3RSavedRectsP: Array [0..2] of TRect; // Saved Rects Pixel coords at MouseDown
  Itmp: integer;

//  destructor  Destroy    (); override;
  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure RedrawAction (); override;
end; // type TN_Ed3RectsRFA = class( TN_RFrameAction )


    //*********** Global Procedures  *****************************

function N_CreateNLConvForm ( AOwner: TN_BaseForm; AUDActionComp: TN_UDAction ): TN_NLConvForm;

var
  N_NLConvForm: TN_NLConvForm;


implementation
{$R *.dfm}
uses
  Math,
  K_CLib,
  N_ClassRef, N_Gra0, N_Gra1, N_Lib0, N_Lib2, N_SGComp, N_ME1,
  N_EdParF, N_RVCTF, N_MenuF, N_Color1F;

const
  //***** rgRectsToChange.ItemIndexes:
  N_rgiSrcDst    = 0;
  N_rgiDstSrc    = 1;
  N_rgiSrcAndDst = 2;
  N_rgiAllRects  = 3;

    //**************** ActionList OnExecute event handlers *************

    //**************** Rects Actions ***********************************

procedure TN_NLConvForm.aRectsCenterSrcDstExecute( Sender: TObject );
// Center Src and Dst Rects in EnvRect
// (Shift Src and Dst Rects so that they would have same Center as Env Rect)
var
  EnvCenter, CurCenter: TDPoint;
begin
  with TN_Ed3RectsRFA(NLCFEd3RectsRFA) do
  begin
    EnvCenter := N_RectCenter( E3RRectsU[0] );

    CurCenter := N_RectCenter( E3RRectsU[1] ); // Src Rect
    E3RRectsU[1] := N_RectShift( E3RRectsU[1], EnvCenter.X-CurCenter.X,
                                               EnvCenter.Y-CurCenter.Y );

    CurCenter := N_RectCenter( E3RRectsU[2] ); // Dst Rect
    E3RRectsU[2] := N_RectShift( E3RRectsU[2], EnvCenter.X-CurCenter.X,
                                               EnvCenter.Y-CurCenter.Y );
  end; // with TN_Ed3RectsRFA(NLCFEd3RectsRFA) do

  RedrawRectsAndMatr( nil );
end; // procedure TN_NLConvForm.aRectsCenterSrcDstExecute

procedure TN_NLConvForm.aRectsSameSrcDstExecute( Sender: TObject );
// Make Src and Dst Rects the same and set Src+Dst Edit Rects mode
var
  EnvCenter: TDPoint;
begin
  with TN_Ed3RectsRFA(NLCFEd3RectsRFA) do
  begin
    EnvCenter := N_RectCenter( E3RRectsU[0] );

    E3RRectsU[1] := N_RectScaleR( E3RRectsU[0], 0.5, N_05DPoint );
    E3RRectsU[2] := E3RRectsU[1]
  end; // with TN_Ed3RectsRFA(NLCFEd3RectsRFA) do

  rgRectsToChange.ItemIndex := 2; // Set Src+Dst Edit Rects mode
  RedrawRectsAndMatr( nil );
end; // procedure TN_NLConvForm.aRectsSameSrcDstExecute

procedure TN_NLConvForm.aRectsScaleDstExecute( Sender: TObject );
// Scale Dst Rects by Coefs in %, given in Dialog
var
  Coefs: TFRect;
  Str: string;
begin
  with TN_Ed3RectsRFA(NLCFEd3RectsRFA) do
  begin
    Str := N_GetStrByComboBox ( 'Scale coefs in %', 'Left Top Right Bottom :',
                                                              'NLConvF_Scale' );
    if Str = N_NotAString then Exit;

    Coefs := N_ScanFRect( Str );
    
    with E3RRectsU[1] do
    begin
      E3RRectsU[2].Left   := Right  - (Right - Left)*Coefs.Left/100;
      E3RRectsU[2].Top    := Bottom - (Bottom - Top)*Coefs.Top/100;
      E3RRectsU[2].Right  := Left   + (Right - Left)*Coefs.Right/100;
      E3RRectsU[2].Bottom := Top    + (Bottom - Top)*Coefs.Bottom/100;
    end;

  end; // with TN_Ed3RectsRFA(NLCFEd3RectsRFA) do

  RedrawRectsAndMatr( nil );
end; // procedure TN_NLConvForm.aRectsScaleDstExecute


    //**************** TN_NLConvForm Controls event handlers ***********

procedure TN_NLConvForm.RedrawRectsAndMatr( Sender: TObject );
// Redraw Rects and Matr according to theirs controls
// (also used as OnClick Handler for cbMatrIsVisible and cbHideRects)
begin
  N_ActiveRFrame.OCanv.CopyWholeToMain();
  TN_Ed3RectsRFA(NLCFEd3RectsRFA).RedrawAction();
  N_ActiveRFrame.ShowMainBuf();
end; // procedure TN_NLConvForm.RedrawRectsAndMatr

procedure TN_NLConvForm.bnConvertClick( Sender: TObject );
// Convert CObjects and Redraw
begin
  ConvertMatrPoints();
//  N_ConvUObjects( SrcCObjDir, DstCObjDir, MapRoot,
  N_ConvUObjects( SrcCObjDir, DstCObjDir, nil,
                              MatrConvObj.NLConvDP, nil, ScaleCoef );
  N_ActiveRFrame.RedrawAllAndShow();
end; // procedure TN_NLConvForm.bnConvertClick

procedure TN_NLConvForm.bnShowMenuClick( Sender: TObject );
// Show NLConv PopupMenu
begin
  with Mouse.CursorPos do
    NLConvPopupMenu.Popup( Max( 0, X-40 ), Y );
end; // procedure TN_NLConvForm.bnShowMenuClick

procedure TN_NLConvForm.EditColor( Sender: TObject );
// Edit Back Color
// (used as OnClick Handler for edXXXRectColor controls)
begin
  with TEdit(Sender) do
    Color := N_ModalEditColor( Color );

  N_ActiveRFrame.RedrawAllAndShow();
end; // procedure TN_NLConvForm.EditColor

procedure TN_NLConvForm.cbStayOnTopClick( Sender: TObject );
// Togle StayOnTop Form Style
begin
  if cbStayOnTop.Checked then FormStyle := fsStayOnTop
                         else FormStyle := fsNormal;
end; // procedure TN_NLConvForm.cbStayOnTopClick

procedure TN_NLConvForm.PageControlChange( Sender: TObject );
// Set proper ActiveControl
begin
  if PageControl.ActivePage = tsCoords then
    ActiveControl := edNXNY;
end; // procedure TN_NLConvForm.PageControlChange

procedure TN_NLConvForm.edNXNYKeyDown( Sender: TObject; var Key: Word;
                                                        Shift: TShiftState );
// if Enter pressed, create and initialize new Matr with new NX, NY,
// convert new Matr by current one (preserve current convertion) and Redraw
//
//   if +Shift - set EnvMatrRect (CAFrect) by EnvRect (E3RRectsU[0])
//   if +Ctrl  - skip converting new Matr by current one (clear current convertion)
var
  ErrRes, NX, NY: integer;
  Str: string;
  OldMatrConvObj: TN_MatrConvObj;
  OldMatr: TN_FPArray;
begin
  if Key = VK_RETURN then
  begin

  with TN_Ed3RectsRFA(NLCFEd3RectsRFA), UDActionComp.PISP()^, MatrConvObj do
  begin
    if ssShift in Shift then // Set Matr Envelope Rect by EnvRect (E3RRectsU[0])
      CAFrect := E3RRectsU[0];

    //***** Save Self MatrConvObj and it's Matr in new
    //      temporary OldMatrConvObj and OldMatr Array

    SetLength( OldMatr, MNX*MNY );
    move( PMatr^, OldMatr[0], MNX*MNY*Sizeof(TFPoint) );
    OldMatrConvObj := TN_MatrConvObj.Create;
    OldMatrConvObj.SetParams( MNX, MNY, CAFrect, @OldMatr[0] );
    //***** Now Self MatrConvObj (UDActionComp.UDActObj1) can be changed

    CAParStr1 := edNXNY.Text;
    Str := edNXNY.Text;
    NX := N_ScanInteger( Str ); // New Matr dimensions
    NY := N_ScanInteger( Str );
    ErrRes := SetParams( NX, NY, CAFrect, nil );

    if ErrRes <> 0 then // Error
    begin
      ShowStr( Format( 'MatrConv Error = %d', [ErrRes] ) );
      Exit;
    end; // if ErrRes <> 0 then // Error

    CAFPArray.ASetLength( MNX, MNY );
    PMatr := PFPoint(CAFPArray.P());
    InitMatr();

    if not(ssCtrl in Shift) then // Conv new Self Matr by OldMatrConvObj (preserve convertion)
      ConvMatr( OldMatrConvObj.NLConvDP );

    OldMatrConvObj.Free;

    N_ConvUObjects( SrcCObjDir, DstCObjDir, MapRoot, NLConvDP, nil, ScaleCoef );
    N_ActiveRFrame.RedrawAllAndShow();

  end; // with TN_Ed3RectsRFA(NLCFEd3RectsRFA), UDActionComp.PIDP()^, MatrConvObj do
  end; // if Key = VK_RETURN then
end; // procedure TN_NLConvForm.edNXNYKeyDown

procedure TN_NLConvForm.edRedrawOnKeyDown( Sender: TObject; var Key: Word;
                                                            Shift: TShiftState );
// Redraw Rects And Matr - edXxxAttr OnKeyDown handler
begin
  if Key = VK_RETURN then
    N_ActiveRFrame.RedrawAllAndShow();
end; // procedure TN_NLConvForm.edRedrawOnKeyDown

procedure TN_NLConvForm.FormClose( Sender: TObject; var Action: TCloseAction );
// Clear N_NLConvForm variable and Free N_3RectsEdGName Group from RFSGroups
var
  Ind: integer;
begin
  Inherited;
  N_NLConvForm := nil;

  if N_ActiveRFrame <> nil then
  with N_ActiveRFrame do
  begin
    Ind := GetGroupInd( N_3RectsEdGName );
    RFSGroups.Delete( Ind ); // Delete MoveComp Group
  end; // with N_ActiveRFrame do

  RectsConvObj.Free;
  // MatrConvObj Owner is UDAction
end; // procedure TN_NLConvForm.FormClose

//****************  TN_NLConvForm class public methods  ************

//***************************************** TN_NLConvForm.ConvertMatrPoints ***
// Convert MatrConvObj Control Points Matrix by current RFAction Rects
//
procedure TN_NLConvForm.ConvertMatrPoints();
begin
  with TN_Ed3RectsRFA(NLCFEd3RectsRFA) do
    RectsConvObj.NLConvPrep( E3RRectsU[0], E3RRectsU[1], E3RRectsU[2] );

  MatrConvObj.ConvMatr( RectsConvObj.NLConvDP );
end; // end of procedure TN_NLConvForm.ConvertMatrPoints

//**************************************** TN_NLConvForm.FillCoordsTabSheet ***
// Show MNX, MNY and current E3RRectsU[i] Coords in 'Coords' TabSheet
//
procedure TN_NLConvForm.FillCoordsTabSheet();
begin
  with MatrConvObj do
    EdNXNY.Text := Format( '  %d  %d', [MNX,MNY] );

  with TN_Ed3RectsRFA(NLCFEd3RectsRFA) do
  begin
    EdEnvRect.Text := N_RectToStr( E3RRectsU[0], 1 );
    EdSrcRect.Text := N_RectToStr( E3RRectsU[1], 1 );
    EdDstRect.Text := N_RectToStr( E3RRectsU[2], 1 );
  end;

end; // end of procedure TN_NLConvForm.FillCoordsTabSheet

//************************************************* TN_NLConvForm.CloseSelf ***
// Close Self ProcOfObj
// (used for closing Self in MEVTreeForm and RastVCTForm CloseForm handlers)
//
procedure TN_NLConvForm.CloseSelf();
begin
  Close();
end; // end of procedure TN_NLConvForm.CloseSelf

//*************************************************** TN_NLConvForm.ShowStr ***
// Show given AStr in Owner Form (should be TN_NVTreeForm) StatusBar
//
procedure TN_NLConvForm.ShowStr( AStr: string );
begin
  StatusBar.SimpleText := AStr;
end; // procedure TN_NLConvForm.ShowStr

//****************************************** TN_NLConvForm.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_NLConvForm.CurStateToMemIni();
begin
  Inherited;

  //***** Modes TabSheet
  N_BoolToMemIni( 'N_NLConvF', 'cbStayOnTop', cbStayOnTop.Checked );

  //***** Colors TabSheet
  N_StringToMemIni( 'N_NLConvF', 'edMatrAttr',    edMatrAttr.Text );
  N_StringToMemIni( 'N_NLConvF', 'edEnvRectAttr', edEnvRectAttr.Text );
  N_StringToMemIni( 'N_NLConvF', 'edSrcRectAttr', edSrcRectAttr.Text );
  N_StringToMemIni( 'N_NLConvF', 'edDstRectAttr', edDstRectAttr.Text );

  N_IntToMemIniAsHex( 'N_NLConvF', 'edMatrColor',    edMatrColor.Color,    6 );
  N_IntToMemIniAsHex( 'N_NLConvF', 'edEnvRectColor', edEnvRectColor.Color, 6 );
  N_IntToMemIniAsHex( 'N_NLConvF', 'edSrcRectColor', edSrcRectColor.Color, 6 );
  N_IntToMemIniAsHex( 'N_NLConvF', 'edDstRectColor', edDstRectColor.Color, 6 );
end; // end of procedure TN_NLConvForm.CurStateToMemIni

//****************************************** TN_NLConvForm.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_NLConvForm.MemIniToCurState();
begin
  Inherited;

  //***** Modes TabSheet
  cbStayOnTop.Checked := N_MemIniToBool( 'N_NLConvF', 'cbStayOnTop', True );

  //***** Colors TabSheet
  edMatrAttr.Text    := N_MemIniToString( 'N_NLConvF', 'edMatrAttr',    '1' );
  edEnvRectAttr.Text := N_MemIniToString( 'N_NLConvF', 'edEnvRectAttr', '1' );
  edSrcRectAttr.Text := N_MemIniToString( 'N_NLConvF', 'edSrcRectAttr', '1' );
  edDstRectAttr.Text := N_MemIniToString( 'N_NLConvF', 'edDstRectAttr', '1' );

  edMatrColor.Color    := N_MemIniToIntFromHex( 'N_NLConvF', 'edMatrColor',    0 );
  edEnvRectColor.Color := N_MemIniToIntFromHex( 'N_NLConvF', 'edEnvRectColor', 0 );
  edSrcRectColor.Color := N_MemIniToIntFromHex( 'N_NLConvF', 'edSrcRectColor', 0 );
  edDstRectColor.Color := N_MemIniToIntFromHex( 'N_NLConvF', 'edDstRectColor', 0 );
end; // end of procedure TN_NLConvForm.MemIniToCurState


//****************  TN_Ed3RectsRFA class methods  *****************
{
//************************************************** TN_Ed3RectsRFA.Destroy ***
// Free Self Objects (not needed?)
destructor TN_Ed3RectsRFA.Destroy();
begin
  inherited;
end; // end_of destructor TN_Ed3RectsRFA.Destroy
}

//********************************************* TN_Ed3RectsRFA.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_Ed3RectsRFA.SetActParams();
begin
  ActName := 'Ed3Rects';

  inherited;
end; // procedure TN_Ed3RectsRFA.SetActParams();

//************************************************** TN_Ed3RectsRFA.Execute ***
// Move or resize Self three Rects
//
procedure TN_Ed3RectsRFA.Execute();
var
  i, dx, dy: integer;
  MaxCoord: double;
  NewRect: TRect;
  MaxRect: TFRect;
  TmpRectP: TN_IRArray;
  AffCoefs: TN_AffCoefs4;

  function ChangeOneRect( const AInpRect: TRect; AFlags: integer ): TRect; // local
  // Change given AInpRect by given AFlags and dx, dy
  // Return changed Rect
  var
    FixedCenterMode: boolean;
  begin
    if AFlags = $10 then // move Whole AInpRect (Shift AInpRect)
      Result := N_RectShift( AInpRect, dx, dy )
    else // move one, two or all sides
    begin
      FixedCenterMode := E3RControlForm.cbFixedCenter.Checked;
      Result := AInpRect;

      if (AFlags and $01) <> 0 then // move Top side or Top+Bottom
      begin
        Inc( Result.Top, dy );
        if FixedCenterMode then Dec( Result.Bottom, dy );
      end;

      if (AFlags and $02) <> 0 then // move Right side or Right+Left
      begin
        Inc( Result.Right, dx );
        Result.Right := AInpRect.Right + dx;
        if FixedCenterMode then Dec( Result.Left, dx );
      end;

      if (AFlags and $04) <> 0 then // move Bottom side or Top+Bottom
      begin
        Inc( Result.Bottom, dy );
        if FixedCenterMode then Dec( Result.Top, dy );
      end;

      if (AFlags and $08) <> 0 then // move Left side or Right+Left
      begin
        Inc( Result.Left, dx );
        if FixedCenterMode then Dec( Result.Right, dx );
      end;
    end; // else // move one two or all sides
  end; // function ChangeOneRect - local

begin //************************************ body of TN_Ed3RectsRFA.Execute
  inherited;
  with ActGroup, ActGroup.RFrame, E3RControlForm do
  begin
//  if CHType = htMouseMove then // debug
//    ShowString( $3, Format( 'XY= %d, %d', [CCBuf.X, CCBuf.Y] ) );

  if CHType = htMouseDown then // LeftClick, set E3RSavedCC and E3RSavedRectsP
  begin
    E3RSavedCC := CCBuf;
    for i := 0 to 2 do
      E3RSavedRectsP[i] := N_AffConvF2IRect( E3RRectsU[i], OCanv.U2P );

    Exit;
  end; // if CHType = htMouseDown then

  if (CHType = htMouseMove) and not (ssLeft in CMKShift) then // move with
  begin                     // buttons Up, set E3RFlags and Windows Cursor type
    SetLength( TmpRectP, 1 ); // just for passing Param to N_IPointNearIRects

    for i := 0 to 2 do // Set E3RFlags for all Rects
    begin
      TmpRectP[0] := N_AffConvF2IRect( E3RRectsU[i], OCanv.U2P );
      N_IPointNearIRects( 0, TmpRectP, CCBuf, 2, E3RFlags[i] );
    end;

    if E3RFlags[0] = 0 then // Cursor is out of all Rects
    begin
      N_SetCursorType( E3RFlags[0] );
      E3RIndToEdit := -1; // no Rects to Edit
      ShowStr( '' );
      Exit;
    end;

    if ((E3RFlags[0] and $0F) <> 0) or  // Cursor is on Rect0 (EnvRect) border
       (rgRectsToChange.ItemIndex = N_rgiAllRects) then // or "Change AllRects" mode
    begin
      N_SetCursorType( E3RFlags[0] ); // move or scale Rect0 or All Rects
      E3RIndToEdit := 0;
      ShowStr( 'Env Rect' );
      Exit;
    end;

    //***** Cursor is stricly inside Rect0

    if ((E3RFlags[2] and $01F) <> 0) and  // On or Inside Rect2 (DstRect)
       (rgRectsToChange.ItemIndex = N_rgiDstSrc) then // in "Dst, Src" mode
    begin
      N_SetCursorType( E3RFlags[2] ); // move or scale Rect2 only
      E3RIndToEdit := 2;
      ShowStr( 'Dst Rect' );
      Exit;
    end;

    if ((E3RFlags[1] and $01F) <> 0) then // On or Inside Rect1 (SrcRect)
    begin
      N_SetCursorType( E3RFlags[1] ); // move or scale Rect1 or Rect1+2 in "Src+Dst" mode
      E3RIndToEdit := 1;
      ShowStr( 'Src Rect' );
      Exit;
    end;

    if ((E3RFlags[2] and $01F) <> 0) then // On or Inside Rect2 (DstRect) and outside of Rect1
    begin
      N_SetCursorType( E3RFlags[2] ); // move or scale Rect2 or Rect1+2 in "Src+Dst" mode
      E3RIndToEdit := 2;
      ShowStr( 'Dst Rect' );
      Exit;
    end;

    // Cursor is inside Rect0 but out of both Rect1 and Rect2

    N_SetCursorType( E3RFlags[0] ); // move Rect0 only mode
    E3RIndToEdit := 0;
    ShowStr( 'Env Rect' );
    Exit;
  end; // move with buttons Up

  //***** Drug (change Rects coords)

  if (CHType = htMouseMove) and (ssLeft in CMKShift) then //***** Drug
  begin
    if E3RIndToEdit = -1 then Exit; // nothing to change

    dx := CCBuf.X - E3RSavedCC.X; // X,Y shift values relative to E3RSavedCC
    dy := CCBuf.Y - E3RSavedCC.Y;

    if (dx = 0) and (dy = 0) then Exit; // no change, exit to avoid extra redrawing

    if E3RIndToEdit = 0 then // edit Rect0 only or all Rects in N_rgiAllRects mode
    begin
      if rgRectsToChange.ItemIndex = N_rgiAllRects then // "Change AllRects" mode
      begin
        NewRect := ChangeOneRect( E3RSavedRectsP[0], E3RFlags[0] );
        AffCoefs := N_CalcAffCoefs4( E3RSavedRectsP[0], NewRect ); // how to change all rects

        for i := 0 to 2 do
          E3RRectsU[i] := N_AffConvF2FRect(
                          N_AffConvI2FRect1( E3RSavedRectsP[i], AffCoefs ), OCanv.P2U );
      end else // edit Rect0 only
      begin
        NewRect := ChangeOneRect( E3RSavedRectsP[0], E3RFlags[0] );
        E3RRectsU[0] := N_AffConvI2FRect1( NewRect, OCanv.P2U );
      end; // else // edit Rect0 only
    end; // if E3RIndToEdit = 0 then // edit Rect0 only or all Rects in N_rgiAllRects mode

    if E3RIndToEdit = 1 then // edit Rect1 only or or Rect1+2 in "Src+Dst" mode
    begin
      if rgRectsToChange.ItemIndex = N_rgiSrcAndDst then // "Change Src+Dst Rects" mode
      begin
        NewRect := ChangeOneRect( E3RSavedRectsP[1], E3RFlags[1] );
        AffCoefs := N_CalcAffCoefs4( E3RSavedRectsP[1], NewRect ); // how to change Src and Dst rects

        for i := 1 to 2 do
          E3RRectsU[i] := N_AffConvF2FRect(
                          N_AffConvI2FRect1( E3RSavedRectsP[i], AffCoefs ), OCanv.P2U );
      end else // edit Rect1 only
      begin
        NewRect := ChangeOneRect( E3RSavedRectsP[1], E3RFlags[1] );
        E3RRectsU[1] := N_AffConvI2FRect1( NewRect, OCanv.P2U );
      end; // else // edit Rect1 only
    end; // if E3RIndToEdit = 1 then // edit Rect1 only or or Rect1+2 in "Src+Dst" mode

    if E3RIndToEdit = 2 then // edit Rect2 only or or Rect1+2 in "Src+Dst" mode
    begin
      if rgRectsToChange.ItemIndex = N_rgiSrcAndDst then // "Change Src+Dst Rects" mode
      begin
        NewRect := ChangeOneRect( E3RSavedRectsP[2], E3RFlags[2] );
        AffCoefs := N_CalcAffCoefs4( E3RSavedRectsP[2], NewRect ); // how to change Src and Dst rects

        for i := 1 to 2 do
          E3RRectsU[i] := N_AffConvF2FRect(
                          N_AffConvI2FRect1( E3RSavedRectsP[i], AffCoefs ), OCanv.P2U );
      end else // edit Rect2 only
      begin
        NewRect := ChangeOneRect( E3RSavedRectsP[2], E3RFlags[2] );
        E3RRectsU[2] := N_AffConvI2FRect1( NewRect, OCanv.P2U );
      end; // else // edit Rect2 only
    end; // if E3RIndToEdit = 2 then // edit Rect2 only or or Rect1+2 in "Src+Dst" mode

    //***** Rects are changed, check if they are correct and update if needed

    with E3RRectsU[0] do // EnvRect should have size >= 0.01% of max coord
    begin
      MaxCoord := Max( Abs(Left), Abs(Right) );
      if (Right - Left) < 1.0e-4*MaxCoord then
        Right := Left + 1.0e-4*MaxCoord;

      MaxCoord := Max( Abs(Top), Abs(Bottom) );
      if (Bottom - Top) < 1.0e-4*MaxCoord then
        Bottom := Top + 1.0e-4*MaxCoord;
    end; // with E3RRectsU[0] do // EnvRect should have size >= 0.01% of max coord

    //***** Src and Dst rects should be inside MaxRect

    MaxRect := N_RectScaleR( E3RRectsU[0], 0.99, N_05DPoint );
    E3RRectsU[1] := N_RectAdjustByMaxRect( E3RRectsU[1], MaxRect );
    E3RRectsU[2] := N_RectAdjustByMaxRect( E3RRectsU[2], MaxRect );

    E3RControlForm.FillCoordsTabSheet(); // show Rect Coords on 'Coords' tabSheet
    E3RControlForm.RedrawRectsAndMatr( nil ); // redraw changed rects
    Exit;
  end; // if (CHType = htMouseMove) and (ssLeft in CMKShift) then // Drug (change Rects coords)

{
  if (CHType = htDblClick) then // DblClick, Convert Matr, CObjects and Redraw
  begin
    N_i := 2;
    E3RControlForm.ShowStr( 'DblClik ' + IntToStr(Itmp) );
    Inc( Itmp );
    ConvertMatrPoints();
    N_ConvUObjects( SrcCObjDir, DstCObjDir, MapRoot, MatrConvObj.NLConvDP, nil, 2.0 );
    RedrawAllAndShow();
    SkipMouseDown := True;
    Exit;
  end; // if (CHType = htDblClick) then // DblClick, Convert Matr, CObjects and Redraw
}
  end; // with ActGroup, ActGroup.RFrame, RFAAlignForm do
end; // procedure TN_Ed3RectsRFA.Execute

//********************************************* TN_Ed3RectsRFA.RedrawAction ***
// Redraw Temporary Action objects
// (should be called from RFrame.RedrawAll )
//
procedure TN_Ed3RectsRFA.RedrawAction();
begin
  with N_ActiveRFrame, E3RControlForm do
  begin

    if cbMatrIsVisible.Checked then //***** Draw Lines by Points Matr
    begin
      OCanv.ConWinPolyline := True;
      OCanv.SetPenAttribs( edMatrColor.Color, edMatrAttr.Text );

      with E3RControlForm.MatrConvObj do
        OCanv.DrawUserMatrPoints( PMatr, MNX, MNY );
    end; // if cbMatrIsVisible.Checked then // Draw Points Matr

    if not cbHideRects.Checked then //***** Draw Rects
    begin
      OCanv.SetBrushAttribs( -1 );

      OCanv.SetPenAttribs( edEnvRectColor.Color, edEnvRectAttr.Text );
      OCanv.DrawUserRect( E3RRectsU[0] );

      OCanv.SetPenAttribs( edSrcRectColor.Color, edSrcRectAttr.Text );
      OCanv.DrawUserRect( E3RRectsU[1] );

      OCanv.SetPenAttribs( edDstRectColor.Color, edDstRectAttr.Text );
      OCanv.DrawUserRect( E3RRectsU[2] );
    end; // if not cbHideRects then // Draw Rects

  end; // with N_ActiveRFrame, E3RControlForm do
end; // procedure TN_Ed3RectsRFA.RedrawAction


    //*********** Global Procedures  *****************************

//****************************************************** N_CreateNLConvForm ***
// Create and return new instance of TN_NLConvForm
// return nil if Form cannot be created
//
// AOwner - Owner of created Form
// AUDActionComp - UDAction with needed Params
//
function N_CreateNLConvForm( AOwner: TN_BaseForm; AUDActionComp: TN_UDAction ): TN_NLConvForm;
var
  Str: string;
  Ed3RectsGroup: TN_SGComp;
  PActParams: TN_PCAction;
  TmpMapRoot: TN_UDCompVis;
  FrameParent: TN_BaseForm;
begin
  if N_NLConvForm = nil then
  begin
    PActParams := AUDActionComp.PIDP(); // Pointer to UDAction Dynamic Params

    // Draw Needed MapRoot
    TmpMapRoot := TN_UDCompVis(PActParams.CAUDBase3); // Self MapRoot is not ready yet
    N_ViewCompFull( TN_UDCompVis(TmpMapRoot), @N_MEGlobObj.RastVCTForm, AOwner,
                                               'Non Linear Coords convertor' );
    // Create needed Group in N_ActiveRFrame
    Ed3RectsGroup := TN_SGComp.Create( N_ActiveRFrame );
    Ed3RectsGroup.GName := N_3RectsEdGName;
    SetLength( Ed3RectsGroup.SComps, 1 );
    Ed3RectsGroup.SComps[0].SComp := TmpMapRoot;
    N_ActiveRFrame.RFSGroups.Add( Ed3RectsGroup );

    N_NLConvForm := TN_NLConvForm.Create( Application );
    with N_NLConvForm do // Init NLConvForm
    begin
      BaseFormInit( AOwner );

      NLCFOwnerForm := AOwner;
      FrameParent := K_GetOwnerBaseForm( N_ActiveRFrame.Owner );
      FrameParent.AddProcOfObjAction( CloseSelf, N_NLConvForm,
                                                           'Close NLConvForm' );
      NLCFEd3RectsRFA := Ed3RectsGroup.SetAction( N_ActEd3Rects, 0, -1, 0 );
      with TN_Ed3RectsRFA(NLCFEd3RectsRFA), TmpMapRoot.PCCS()^ do
      begin
        E3RControlForm := N_NLConvForm;

        E3RRectsU[0] := N_RectScaleR( CompUCoords, 0.5, DPoint(0.2,0.2) );
        E3RRectsU[1] := N_RectScaleR( E3RRectsU[0], 0.8, N_05DPoint );
        E3RRectsU[2] := N_RectScaleR( E3RRectsU[0], 0.6, N_05DPoint );
      end; // with TN_Ed3RectsRFA(NLCFEd3RectsRFA), TmpMapRoot.PCCS()^ do

      // Get UDAction Params
      UDActionComp := AUDActionComp;
      SrcCObjDir := PActParams.CAUDBase1;
      DstCObjDir := PActParams.CAUDBase2;
      MapRoot    := PActParams.CAUDBase3; // = TmpMapRoot
      Str        := PActParams.CAParStr2;
      ScaleCoef  := N_ScanFloat( Str );
      MatrConvObj  := TN_MatrConvObj(UDActionComp.UDActObj1); // Owned by UDActionComp

      RectsConvObj := TN_RectsConvObj.Create; // Owned by Self
//      N_ConvUObjects( SrcCObjDir, DstCObjDir, MapRoot,
//                                  MatrConvObj.NLConvDP, nil, ScaleCoef );
      N_ConvUObjects( SrcCObjDir, DstCObjDir, nil,
                                  MatrConvObj.NLConvDP, nil, ScaleCoef );

      FillCoordsTabSheet(); // Show RectCoords and MNX, MNY on 'Coords' TabSheet

      N_ActiveRFrame.OCanv.CreateBackBuf();
      N_ActiveRFrame.RedrawAllAndShow();
      Show();

    end; // with N_NLConvForm do // Init NLConvForm

  end; // if N_NLConvForm <> nil then

  Result := N_NLConvForm;
end; // function N_CreateNLConvForm


Initialization
  N_RFAClassRefs[N_ActEd3Rects] := TN_Ed3RectsRFA;

end.
