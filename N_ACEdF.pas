unit N_ACEdF;
// TN_AffCoefs8 Visual Editor Form
//
// add later:
// 1) multilevel Undo capability
// 2) Copy, Paste all coefs from Clipboard (with Date+Time stamp)
// 3) Shift+Cancel just initialize convertion without form closing
// 4) Describe all used AffCoefs
// 5) Undo for current Convertion
// 6) View, edit coefs as text
// 7) Add squeeze (along perpendicular to FixedPoint1-FixedPoint2 line)
// 7a) Нажатый Ctrl означает строго горизонтальное или вертикальное
//     расположение FixedPoint1-FixedPoint2 line
// 8) Common Buttons and one Text field alwas visible
// 9) Show/Edit Shift and Scale as Text (as Alfa and perspective)
// 10) Buttons with names in Rows instead of big Cross
// 11) Сделать Action Mark_Reper  с разными флагами
// 12) При закрытии формы часто вылезает ошибка - OutOfListBounds(-1)
// 13) Показывать Moving Point (текущее положение FixedPoint2 in Perspective Convertion)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Contnrs,
  N_Lib1, N_Gra0, N_Gra1, N_Types, N_BaseF, N_Rast1Fr, N_CompCL;

type TN_AffCoefs8Proc = procedure( Mode: integer; AffCoefs: TN_AffCoefs8 ) of object;

type TN_AffCoefsEditorForm = class( TN_BaseForm )
    PageControl: TPageControl;
    tsShiftScale: TTabSheet;
    tsRotate: TTabSheet;
    bnSetFixedPoint: TButton;
    bnPS6: TButton;
    bnPS2: TButton;
    bnPS0: TButton;
    bnPS4: TButton;
    bnPS1: TButton;
    bnPS5: TButton;
    Label1: TLabel;
    bnPS3: TButton;
    bnPS7: TButton;
    cbMantainAspect: TCheckBox;
    bnPS22: TButton;
    bnPS18: TButton;
    bnPS20: TButton;
    bnPS16: TButton;
    Label2: TLabel;
    bnPS17: TButton;
    bnPS21: TButton;
    bnPS19: TButton;
    bnPS23: TButton;
    PSTimer: TTimer;
    bnOK: TButton;
    bnCancel: TButton;
    edConvAspectCoef: TLabeledEdit;
    edFixedPoint: TLabeledEdit;
    bnPS33: TButton;
    bnPS37: TButton;
    bnPS36: TButton;
    bnPS32: TButton;
    bnPS54: TButton;
    bnPS50: TButton;
    bnPS53: TButton;
    bnPS49: TButton;
    bnPS48: TButton;
    bnPS52: TButton;
    bnPS51: TButton;
    bnPS55: TButton;
    edWXY: TLabeledEdit;
    Label5: TLabel;
    edAlfa: TLabeledEdit;
    tsOther: TTabSheet;
    cbStayOnTop: TCheckBox;

      //******************* Event handlers *************************

    procedure bnSetFixedPointClick ( Sender: TObject );
    procedure SetFixedPoint        ( ANewFixedPoint: TDPoint );

    procedure edAlfaKeyDown   ( Sender: TObject; var Key: Word;
                                                        Shift: TShiftState );
    procedure edWXYKeyDown    ( Sender: TObject; var Key: Word;
                                                        Shift: TShiftState );
    procedure bnPS33MouseDown ( Sender: TObject; Button: TMouseButton;
                                         Shift: TShiftState; X, Y: Integer );
    procedure bnPS33MouseUp   ( Sender: TObject; Button: TMouseButton;
                                         Shift: TShiftState; X, Y: Integer );
    procedure PSTimerTimer     ( Sender: TObject );
    procedure cbStayOnTopClick ( Sender: TObject );
    procedure bnCancelClick    ( Sender: TObject );
    procedure bnOKClick        ( Sender: TObject );

    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
    RFrame: TN_Rast1Frame; // used for OCanv.U2P coefs and for getting and marking  Fixed Point Coords

    BegAffCoefs:      TN_AffCoefs8;      // saved initial Convertion for Cancelling
    CurBaseAffCoefs:  TN_AffCoefs8;
    CurFinalAffCoefs: TN_AffCoefs8;
    POutAffCoefs:     TN_PAffCoefs8;

    UFullX, UFullY: double; // just InpRect Width and Height
    InpRect: TFRect;  // used for creating Shift and Scale Convertions (in UserCoords)
    OutRect: TFRect;  // used for creating Shift and Scale Convertions (in UserCoords)
    ApplyProc: TN_AffCoefs8Proc; // external Redrawing procedure that uses current AffCoefs8
    PSState: integer;   // Timer state (0 - Interval=250 ms, 1 - Interval=35 ms)
    PSTag: integer;          // button's Delphi Tag
    ConvShift: TDPoint;      // moving Point shift in User Coords
    CurFixedPoint1: TDPoint; // Fixed Point for Scale, Rotation and Perspective Convertions
    CurFixedPoint2: TDPoint; // moving Point for Perspective Convertion
    CurAlfa: double;         // Current Rotation Angle
    PrevConvType: integer;   // Previous Convertion Type
    CurConvType: integer;    // Current Convertion Type (see comments in PSChangeAffCoefs)

    procedure Apply            ( Mode: integer );
    procedure DefCurRotation   ();
    procedure PrepForNewConv   ( ANewConvType: integer );
    procedure PSChangeAffCoefs (); // is called from MouseUp,Down all PSbutton's handlers
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_AffCoefsEditorForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

function N_CreateAffCoefsEditorForm( ARFrame: TN_Rast1Frame;
                                     AOwner: TN_BaseForm ): TN_AffCoefsEditorForm;

implementation
{$R *.dfm}
uses math, clipbrd,
  N_Lib0, N_Gra2, N_AffC4F, N_VRE3;

var N_MarkPointsParams: TN_MarkPointsParams = // Marking Fixed Points Attributes
  (MarkPointsFlags:[]; MarkPointsAttr:(SShape:[sshCornerMult]; SPenColor:$00CC00;
                       SSizeXY:(X:13;Y:13); SHotPoint:(X:0.5;Y:0.5)) );

//****************  TN_AffCoefsEditorForm class handlers  ******************

procedure TN_AffCoefsEditorForm.bnSetFixedPointClick( Sender: TObject );
// Add to Zero Group Action (Self.SetFixedPoint method, see just bellow),
// that will set new Fixed Point in RFrame MouseDown event handler
var
  ZeroGroup: TN_SGBase;
begin
  ZeroGroup := TN_SGBase(RFrame.RFSGroups.Items[0]);
  TN_RFAGetUPoint(ZeroGroup.SetAction( N_ActGetUPoint, $00 )).DPProcObj :=
                                                                SetFixedPoint;
end; // procedure TN_AffCoefsEditorForm.bnSetFixedPointClick

procedure TN_AffCoefsEditorForm.SetFixedPoint( ANewFixedPoint: TDPoint );
// Set New FixedPoint1(2) and reset CurBaseAffCoefs
var
  Ind: integer;
  MarkPointsAction: TObject;
begin
  PrevConvType  := $70; // clear current Conv Type
  with ANewFixedPoint do
    edFixedPoint.Text := Format( '%.3f %.3f', [X, Y ] );

  with TN_SGBase(RFrame.RFSGroups.Items[0]) do // Zero (not Edit) Group
  begin
    Ind := GetActionByClass( N_ActGetUPoint );
    if Ind >= 0 then GroupActList.Delete( Ind ); // delete GetUPoint Action
  end; // with TN_SGBase(RFrame.RFSGroups.Items[0]) do

  with TN_SGBase(RFrame.RFSGroups.Items[1]) do // Edit Group
  begin
    Ind := GetActionByClass( N_ActMarkPoints ); // get MarkPoints Action
    if Ind >= 0 then
      MarkPointsAction := GroupActList[Ind] // get exested Action
    else
      MarkPointsAction := SetAction( N_ActMarkPoints, $00 ); // create New Action

    with TN_RFAMarkPoints(MarkPointsAction) do // set MarkPoints Action Params
    begin
      PActParams := @N_MarkPointsParams; // marking Params

      if N_KeyIsDown( VK_Shift ) then // Set CurFixedPoint2 as second Fixed Point
      begin
        NumPoints := 2;
        CurFixedPoint2 := ANewFixedPoint;
        SetLength( DPoints, 2 );
        DPoints[1] := CurFixedPoint2;
      end else // Shift is UP, Set CurFixedPoint1 as the only one Fixed Point
      begin
        NumPoints := 1;
        CurFixedPoint1 := ANewFixedPoint;
        CurFixedPoint2.X := N_NotADouble; // not defined flag
        SetLength( DPoints, 1 );
        DPoints[0] := CurFixedPoint1;
      end;
    end; // with TN_RFAMarkPoints(MarkPointsAction) do // set MarkPoints Action Params

  end; // with TN_SGBase(RFrame.RFSGroups.Items[1]) do

  RFrame.RedrawAllAndShow(); // to show just added Fixed Point

end; // procedure TN_AffCoefsEditorForm.SetFixedPoint

procedure TN_AffCoefsEditorForm.edAlfaKeyDown( Sender: TObject;
                                           var Key: Word; Shift: TShiftState );
// Set Rotation angle and perform Rotation Convertion
var
  Str: string;
begin
  if Key <> VK_RETURN then Exit;

  PrepForNewConv( $20 );
  Str := edAlfa.Text;
  CurAlfa := N_ScanDouble( Str );
  DefCurRotation();
  Apply( 0 );
end; // procedure TN_AffCoefsEditorForm.edAlfaKeyDown

procedure TN_AffCoefsEditorForm.edWXYKeyDown( Sender: TObject;
                                           var Key: Word; Shift: TShiftState );
// Set CurFinalAffCoefs.WX, WY coefs (mainly for debug)
//  and perform Perspective Convertion
var
  Str: string;
begin
  if Key <> VK_RETURN then Exit;

  Str := edWXY.Text;
  CurBaseAffCoefs := CurFinalAffCoefs;
  CurFinalAffCoefs.WX := N_ScanDouble( Str );
  CurFinalAffCoefs.WY := N_ScanDouble( Str );
  Apply( 0 );
end; // procedure TN_AffCoefsEditorForm.edWXYKeyDown

procedure TN_AffCoefsEditorForm.bnPS33MouseDown( Sender: TObject;
                      Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
// setup timer to enable Convertion changing by timer events
// (all bnPSxx Button's handler)
begin
  PSState := 0;
  PSTag := TComponent(Sender).Tag;
  PSTimer.Enabled := True;
  PSTimer.Interval := 250; // wait time before first event
  PSChangeAffCoefs();
end; // procedure TN_AffCoefsEditorForm.bnPSMouseDown

procedure TN_AffCoefsEditorForm.bnPS33MouseUp( Sender: TObject;
                 Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
// stop timer to prevent Convertion changing by timer events
// (all bnPSxx Button's handler)
begin
  PSTimer.Enabled := False;
end; // procedure TN_AffCoefsEditorForm.bnPSMouseUp

procedure TN_AffCoefsEditorForm.PSTimerTimer( Sender: TObject );
// Call PSChangeAffCoefs() method
begin
  if PSState = 0 then
  begin
    PSTimer.Interval := 35; // repeat time
    PSState := 1;
  end;

  PSChangeAffCoefs();
end; // procedure TN_AffCoefsEditorForm.PSTimerTimer

procedure TN_AffCoefsEditorForm.cbStayOnTopClick( Sender: TObject );
// toggle StayOnTop mode
begin
  if cbStayOnTop.Checked then FormStyle := fsStayOnTop
                         else FormStyle := fsNormal;
end; // procedure TN_AffCoefsEditorForm.cbStayOnTopClick

procedure TN_AffCoefsEditorForm.bnCancelClick( Sender: TObject );
// Set CurFinalAffCoefs to BegAffCoords, call Apply Proc and Close Form
begin
  CurFinalAffCoefs := BegAffCoefs;
  Apply( 1 );

  if N_KeyIsDown( VK_SHIFT) then Exit; // do not Close Self

  Close();
end; // procedure TN_AffCoefsEditorForm.bnCancelClick

procedure TN_AffCoefsEditorForm.bnOKClick( Sender: TObject );
// Assume and copy to Clipboard CurFinalAffCoefs, close Form
begin
  with CurFinalAffCoefs do
    Clipboard.AsText := Format(
        'N_AffCoefs8=( %.9g, %.9g, %.9g, %.9g, %.9g, %.9g ), (CXX, CXY, SX, WX, CYX, CYY, SY, WY)',
                      [CXX, CXY, SX, WX, CYX, CYY, SY, WY] );
  Close();
end; // procedure TN_AffCoefsEditorForm.bnOKClick

procedure TN_AffCoefsEditorForm.FormClose( Sender: TObject; var Action: TCloseAction);
var
  Ind: integer;
begin
  with TN_SGBase(RFrame.RFSGroups.Items[1]) do // Edit Group
  begin
    Ind := GetActionByClass( N_ActMarkPoints );
    if Ind >= 0 then GroupActList.Delete( Ind ); // delete MarkPoints Action
  end; // with TN_SGBase(RFrame.RFSGroups.Items[0]) do

  RFrame.RedrawAllAndShow(); // clear Marked Fixed Points
  Inherited;
end; // procedure TN_AffCoefsEditorForm.FormClose


//****************  TN_AffCoefsEditorForm class public methods  ************

procedure TN_AffCoefsEditorForm.Apply( Mode: integer );
// Apply CurFinalAffCoefs (call ApplyProc - external Proc of Obj)
begin
  if POutAffCoefs <> nil then POutAffCoefs^ := CurFinalAffCoefs;
  if @ApplyProc <> nil then ApplyProc( Mode, CurFinalAffCoefs );
end; // procedure TN_AffCoefsEditorForm.Apply

procedure TN_AffCoefsEditorForm.DefCurRotation();
// Define Current Rotation by CurAlfa field (in degree):
// create Rotation AffCoefs6 and set CurFinalAffCoefs
var
  Params: Array [0..2] of double;
  DeltaAffCoefs6: TN_AffCoefs6;
begin
  Params[0] := CurAlfa;
  Params[1] := CurFixedPoint1.X; // FixedPoint.X
  Params[2] := CurFixedPoint1.Y; // FixedPoint.Y
  N_CalcAffCoefs6( 3, DeltaAffCoefs6, @Params[0] ); // create coefs for Rotation
  CurFinalAffCoefs := N_ComposeAffCoefs8( N_AffCoefs8(DeltaAffCoefs6), CurBaseAffCoefs );

  edAlfa.Text := Format( ' %.2f', [CurAlfa] );
end; // procedure TN_AffCoefsEditorForm.DefCurRotation

procedure TN_AffCoefsEditorForm.PrepForNewConv( ANewConvType: integer );
// prepare for new Convertion type: set InpRect, UFullX, UFullY, ConvShift and
// update CurBaseAffCoefs
begin
  CurConvType := ANewConvType;

  if CurConvType = PrevConvType then Exit; // nothing to do

  CurBaseAffCoefs := CurFinalAffCoefs;
  InpRect := N_AffConvI2FRect1( RFrame.RFSrcPRect, RFrame.OCanv.P2U );

  //***** for Scale Convertion OutRect.BottomRight is used as moving point
  //      and InpRect.TopLeft should be set to CurFixedPoint1:
  if (CurConvType and $70) = $10 then
  begin
    InpRect := N_RectShift( InpRect, CurFixedPoint1.X - InpRect.Left,
                                     CurFixedPoint1.Y - InpRect.Top );
    OutRect := InpRect;
  end; // if (CurConvType and $70) = $10 then

  UFullX  := N_RectWidth( InpRect );
  UFullY  := N_RectHeight( InpRect );
  ConvShift := N_ZDPoint;
  CurAlfa := 0;
  edAlfa.Text := ' 0';
  PrevConvType := CurConvType;
end; // procedure TN_AffCoefsEditorForm.PrepForNewConv

procedure TN_AffCoefsEditorForm.PSChangeAffCoefs();
// Change CurFinalAffCoefs according to PSTag bits:
// bit0 ($01) =1 - positive step, =0 - negative step
// bit1 ($02) =1 - Y coord,       =0 - X coord
// bit2 ($04) =1 - Big Step,      =0 - Small Step
// bit3 ($08) - not used
// bits4-6 ($70) =0 - Shift(0), =1 - Scale(16), =2 - Rotate(32), =3 - Perspective(48)
//
//          PSButtons Tag field, same as in Name (bnPSxx):
// Shift_Buttons   Scale_Buttons  Rotate_Buttons Perspective_Buttons
//      +0             +16             +32               +48
//       6              22                                54
//       2              18                                50
//   4 0   1 5     20 16  17 21    36 32  33 37      52 48  49 53
//       3              19                                51
//       7              23                                55
var
  PSize: integer;
  USizeX, USizeY, dx, dy, D: double;
  DeltaAffCoefs4, A1, A2: TN_AffCoefs4;
  DeltaAffCoefs8, A3: TN_AffCoefs8;
  CurConvAspect, AX, AY: double;
  R1, R2: TFRect;
  Label Fin;
begin
  PrepForNewConv( PSTag and $70 ); // prepare for convertion

  if (PSTag and $04) = 0 then PSize := 1  // Set Step Size in Pixels
                         else PSize := 8;

  if (PSTag and $01) = 0 then PSize := -PSize; // Set Step Direction

  //***** USize is PSize in User coords,
  //      for quadraic pixel (P2U.CX=P2U.CY) USizeX is always equal to USizeY

  with RFrame.OCanv do // conv to User Coords
  begin
    USizeX := P2U.CX*PSize;
    USizeY := P2U.CY*PSize;
  end; // with RFrame, RFrame.OCanv do

  if (PSTag and $02) = 0 then // X coord was changed
    ConvShift.X := ConvShift.X + USizeX
  else // (PSTag and $02) = $02 -  Y coord was changed
    ConvShift.Y := ConvShift.Y + USizeY;

  if (PSTag and $70) <= $10 then //****************** Shift or Scale Convertion
  begin
    if (PSTag and $70) = $00 then //***** Shift Convertion
      OutRect := N_RectShift( InpRect, ConvShift.X, ConvShift.Y );

    if (PSTag and $70) = $10 then //***** Scale Convertion
    begin
      //***** for Scale Convertion CurFixedPoint1 is used as Fixed Point,
      //      OutRect.BottomRight is used as moving point
      //      InpRect.TopLeft is same as CurFixedPoint1 and
      //      InpRect=OutRect at the begining

      if cbMantainAspect.Checked then // Mantain Aspect
      begin
        //***** DeltaAffCoefs4 should not change Aspect, i.e.
        //      InpRect Aspect should be equal to OutRect Aspect

        CurConvAspect := N_RectAspect( InpRect );

        if (PSTag and $02) = 0 then // X coord was changed
        begin
          OutRect.Right  := OutRect.Right  + USizeX;
          OutRect.Bottom := OutRect.Bottom + USizeY*CurConvAspect;
        end else // (PSTag and $02) = $02 -  Y coord was changed
        begin
          OutRect.Bottom := OutRect.Bottom + USizeY;
          OutRect.Right  := OutRect.Right  + USizeX/CurConvAspect;
        end;

      end else // cbMantainAspect = False, any aspect is OK
      begin
        OutRect.Right  := OutRect.Right  + ConvShift.X;
        OutRect.Bottom := OutRect.Bottom + ConvShift.Y;

        edConvAspectCoef.Text := Format( ' %.3f', [N_RectAspect(OutRect)/N_RectAspect(InpRect)] );

      end; // if cbMantainAspect.Checked then // Mantain Aspect

    end; // if (PSTag and $70) = $10 then // Scale Convertion

    //***** Common Part for Scale and Shift convertions

    DeltaAffCoefs4 := N_CalcAffCoefs4( InpRect, OutRect );

    if cbMantainAspect.Checked then
      DeltaAffCoefs4.CY := DeltaAffCoefs4.CX; // a precaution

    CurFinalAffCoefs := N_ComposeAffCoefs8( N_AffCoefs8(DeltaAffCoefs4), CurBaseAffCoefs );
    goto Fin;
  end; // if (PSTag and $70) <= $10 then // Shift or Scale Convertion

  if (PSTag and $70) = $20 then //************************** Rotate Convertion
  begin
    //***** (USizeX+USizeY)/2 is used as Arc length, that define angle change;
    //      (1.5*(UFullX+UFullY)*N_PI) - is approximate full circl arc length
    CurAlfa := CurAlfa + 180*(USizeX+USizeY)/(1.5*(UFullX+UFullY)*N_PI);
    DefCurRotation();
    goto Fin;
  end; // if (PSTag and $70) = $20 then // Rotate Convertion

  if (PSTag and $70) = $30 then //********************* Perspective Convertion
  begin
    //***** CurFixedPoint1 (R1.TopLeft) is used as Fixed Point,
    //      CurFixedPoint2 (R1.BottomRight) is used as moving point

    if CurFixedPoint2.X = N_NotADouble then // CurFixedPoint2 is not defined!
    begin
      CurFinalAffCoefs := CurBaseAffCoefs;
      PSTimer.Enabled := False; // to prevent timer events while showing message
      N_WarnByMessage( 'CurFixedPoint2 is not defined!' );
      goto Fin;
    end;

    R1 := FRect( CurFixedPoint1.X, CurFixedPoint1.Y, CurFixedPoint2.X, CurFixedPoint2.Y );
    AX := CurFixedPoint2.X - CurFixedPoint1.X; // Signed Width
    AY := CurFixedPoint2.Y - CurFixedPoint1.Y; // Signed Height

    //***** Create Perspective A3 (move BottomRight corner):
    //      R2=( 0, 0, Abs(AX), Abs(AY) ) -> ( 0, 0, Abs(AX)+ConvShift.X, Abs(AY)+ConvShift.Y )
    //      R2 is used as most simple case for calculating A3

    A3 := N_DefAffCoefs8;
    dx := ConvShift.X / AX;
    dy := ConvShift.Y / AY;

    AX := Abs(AX); // Signed value is not needed more
    AY := Abs(AY);

    D  := 1.0 + dx + dy;
    A3.CXX := 1.0 - dy/D ;
    A3.WX  := -dy / (D*AX);
    A3.CYY := 1.0 - dx/D ;
    A3.WY  := -dx / (D*AY);

    R2 := FRect( 0, 0, AX, AY );

    //****** A1: R1.TopLeft -> (0,0),  R1.BottomRight -> (AX,AY)
    A1 := N_CalcAffCoefs4( R1, R2 );

    //****** A2: R1.TopLeft <- (0,0),  R1.BottomRight <- (AX,AY)
    A2 := N_CalcAffCoefs4( R2, R1 );

    //***** Create Perspective DeltaAffCoefs8: A2( A3 ( A1 ) )

    DeltaAffCoefs8 := N_ComposeAffCoefs8( A3, N_AffCoefs8(A1) );
    DeltaAffCoefs8 := N_ComposeAffCoefs8( N_AffCoefs8(A2), DeltaAffCoefs8 );

    CurFinalAffCoefs := N_ComposeAffCoefs8( DeltaAffCoefs8, CurBaseAffCoefs );
    with CurFinalAffCoefs do
      edWXY.Text := Format( '%.5f  %.5f', [WX, WY] );

    goto Fin;
  end; // if (PSTag and $70) = $30 then // Perspective Convertion

  Fin: //***** common actions for all type convertions

  Apply( 0 );
end; // procedure TN_AffCoefsEditorForm.PSChangeAffCoefs

//***********************************  TN_AffCoefsEditorForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_AffCoefsEditorForm.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_AffCoefsEditorForm.CurStateToMemIni

//***********************************  TN_AffCoefsEditorForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_AffCoefsEditorForm.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_AffCoefsEditorForm.MemIniToCurState


    //*********** Global Procedures  *****************************

//********************************************  N_CreateAffCoefsEditorForm  ******
// Create and return new instance of TN_AffCoefsEditorForm
//
function N_CreateAffCoefsEditorForm( ARFrame: TN_Rast1Frame;
                                  AOwner: TN_BaseForm ): TN_AffCoefsEditorForm;
begin
  Result := TN_AffCoefsEditorForm.Create( Application );
  with Result do
  begin
    BaseFormInit( AOwner );
    RFrame := ARFrame;
    Assert( RFrame <> nil, 'RFrame not given' );
    InpRect := N_AffConvI2FRect1( RFrame.RFSrcPRect, RFrame.OCanv.P2U );
    SetFixedPoint( N_RectCenter( InpRect ) ); // Set CurFixedPoint1
    CurFixedPoint2.X := N_NotADouble; // not defined flag
  end;
end; // function N_CreateAffCoefsEditorForm

end.
