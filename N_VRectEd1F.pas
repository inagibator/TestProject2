unit N_VRectEd1F;
// Visual Rect (as four values) Editor #1 Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Contnrs,
  K_FrRAEdit,
  N_Types, N_BaseF, N_VVEdBaseF;

type TN_VRectEd1Form = class( TN_VVEdBaseForm )
    edValueX1: TEdit;
    mbNumDigits: TComboBox;
    mbValStep: TComboBox;
    mbValMultCoef: TComboBox;
    Label1: TLabel;
    edValueX2: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    gbX1Y1: TGroupBox;
    bnIncBigX: TButton;
    bnIncSmallX: TButton;
    bnDecSmallX: TButton;
    bnDecBigX: TButton;
    bnIncSmallY: TButton;
    bnIncBigY: TButton;
    bnDecSmallY: TButton;
    bnDecBigY: TButton;
    gbX2Y2: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Label6: TLabel;
    Label7: TLabel;
    edValueY2: TEdit;
    edValueY1: TEdit;
    cbShift: TCheckBox;
    cbAspect: TCheckBox;
    edAspect: TEdit;
    bnSetFP: TButton;

    procedure cbShiftClick  ( Sender: TObject );
    procedure cbAspectClick ( Sender: TObject );
    procedure bnSetFPClick  ( Sender: TObject );
    procedure edAspectKeyDown ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
    FixedPoint:     TDPoint; // Fixed Point coords
    FixedPointMode: boolean; // True in Fixed Point Mode
    Aspect:         double;  // Aspect (used in UpdateValuesByAspect)
    SkipUpdateByAspect: boolean; // used in Aspect + Shift mode

    procedure SetFixedPoint     ( ANewFixedPoint: TDPoint );
    procedure AuxChangeValues   ( AVEdInd: integer ); override;
    procedure UpdateValuesByAspect ();
    procedure CalcAndShowAspect ();
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
end; // type TN_VRectEd1Form = class( TN_VVEdBaseForm )

type TN_RAFRectVEditor = class( TK_RAFEditor ) // Any Rect Field Visual Editor
  function Edit( var AData ) : Boolean; override;
end; //*** type TN_RAFRectVEditor = class( TK_RAFEditor )


    //*********** Global Procedures  *****************************


implementation
uses
  N_Gra0, N_Gra1, N_Lib0, N_Lib1, N_EdStrF, N_Rast1Fr, K_Script1;
{$R *.dfm}

//****************  TN_VRectEd1Form class handlers  ******************

procedure TN_VRectEd1Form.cbShiftClick( Sender: TObject );
// Update Controls by changed Shift Mode
begin
  if cbShift.Checked then gbX1Y1.Caption := ' Shift Rect ' // Shift mode is On
//                     else gbX1Y1.Caption := ' X1,Y1 (Upper Left) ';
                     else gbX1Y1.Caption := '  X1,Y1  ';
end; // procedure TN_VRectEd1Form.cbShiftClick

procedure TN_VRectEd1Form.cbAspectClick( Sender: TObject );
// Update Controls by changed Mantain Aspect Mode
begin
  if cbAspect.Checked then // Mantain Aspect Mode is On
  begin
    gbX2Y2.Caption := ' Scale Rect ';
    edAspect.Enabled := False;
  end else //**************** Mantain Aspect Mode is Off
  begin
//    gbX2Y2.Caption := ' X2,Y2 (Lower Right) ';
    gbX2Y2.Caption := '  X2,Y2  ';
    edAspect.Enabled := True;
  end;
end; // procedure TN_VRectEd1Form.cbAspectClick

procedure TN_VRectEd1Form.bnSetFPClick( Sender: TObject );
// OnClick       - Set Fixed Point by Cursor coords
// OnShift+Click - Set FixedPoint coords by String Editor
// OnCtrl+Click  - cancel FixedPoint mode
var
  Str: string;
begin
  FixedPointMode := False; // as if VK_CONTROL is down
  if N_KeyIsDown( VK_SHIFT ) then // Set FixedPoint coords by String Editor
  begin
    FixedPointMode := True;
    Str := N_PointToStr( FixedPoint );
    if N_EditString( Str, 'Enter Fixed Point :' ) then
      FixedPoint := N_ScanDPoint( Str );
  end else // Shift and Ctrl are Up, Set Fixed Point by Cursor coords
  begin
    if N_ActiveRFrame = nil then Exit; // a precaution
    // Create GetUPoint Action in Zero Group and set it's DPProcObj
    TN_RFAGetUPoint(TN_SGBase(N_ActiveRFrame.RFSGroups.Items[0]).
                  SetAction( N_ActGetUPoint, $00 )).DPProcObj := SetFixedPoint;
  end;
end; // procedure TN_VRectEd1Form.bnSetFPClick

procedure TN_VRectEd1Form.edAspectKeyDown( Sender: TObject; var Key: Word;
                                                          Shift: TShiftState );
// Set New Aspect value and update all coords by it
var
  Str: string;
begin
  Str := edAspect.Text;
  Aspect := N_ScanDouble( Str );
  UpdateValuesByAspect();
end; // procedure TN_VRectEd1Form.edAspectKeyDown

procedure TN_VRectEd1Form.FormClose( Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
end; // procedure TN_VRectEd1Form.FormClose

//****************  TN_VRectEd1Form class public methods  ************

procedure TN_VRectEd1Form.SetFixedPoint( ANewFixedPoint: TDPoint );
// Set New Fixed Point and remove GetUPoint Action
// (is called from N_ActiveRFrame ZeroGroup N_ActGetUPoint Action)
// Old var without Components, will not work!
begin
  if N_ActiveRFrame = nil then Exit; // a precaution
  FixedPoint := ANewFixedPoint;
  FixedPointMode := True;
  with TN_SGBase(N_ActiveRFrame.RFSGroups.Items[0]) do // delete GetUPoint Action
    GroupActList.Delete( GetActionByClass( N_ActGetUPoint ) );
end; // procedure TN_VRectEd1Form.SetFixedPoint

//***********************************  TN_VRectEd1Form.AuxChangeValues  ******
// Implementation of Shift and Mantain Aspect modes
//
procedure TN_VRectEd1Form.AuxChangeValues( AVEdInd: integer );
begin
  if cbShift.Checked and (AVEdInd <= 1) then // Shift Mode Aspect is not changed
  begin
    SkipUpdateByAspect := True;
    OVEditors[AVEdInd].SetDataByValue( PData ); // before OVEditors[2,3].UpdateValue !

    if AVEdInd = 0 then // Change X2
      OVEditors[2].UpdateValue( LastStep );

    if AVEdInd = 1 then // Change Y2
      OVEditors[3].UpdateValue( LastStep );

    if AVEdInd <= 1 then
      LastVEdInd := AVEdInd; // for proper OnTimer updating

    SkipUpdateByAspect := False;
    if cbAspect.Checked then
    begin
      SetDataByValues( PData );
      VVEdGlobalAction( OnApplyAction );
    end;
    Exit;
  end; // if cbShift.Checked and (AVEdInd <= 1) then

  if cbAspect.Checked then // Update all coords by current Aspect
    UpdateValuesByAspect()
  else // Mantain Aspect Mode is Off, calc and show changed Aspect
  begin
    CalcAndShowAspect();
    OVEditors[AVEdInd].SetDataByValue( PData );
    VVEdGlobalAction( OnApplyAction );
  end;

end; // end of procedure TN_VRectEd1Form.AuxChangeValues

//***********************************  TN_VRectEd1Form.UpdateValuesByAspect  ******
// Update CurValue fields of all VEditors by current Aspect and FixedPoint
//
procedure TN_VRectEd1Form.UpdateValuesByAspect();
var
  ScaleCoef: double;
  CurDRect, NewDRect: TDRect;
begin
  if not cbAspect.Checked then Exit; // a precaution
  if SkipUpdateByAspect then Exit; // Aspect was not changed

  with OVEditors[LastVEdInd] do
    CurValue := CurValue - LastStep; // restore CurValue to preserve Aspect

  CurDRect := GetRect();

  if not FixedPointMode then // Set Fixed Point to one of corners
  begin
    if LastVEdInd <= 1 then // Last changed was Upperleft corner
      FixedPoint := CurDRect.BottomRight
    else
      FixedPoint := CurDRect.TopLeft;
  end; // if not FixedPointMode then

  // Calc ScaleCoef by LastStep and LastVEdInd

  ScaleCoef := 1; // to avoid warning

  case LastVEdInd of

  0: ScaleCoef := Abs( (OVEditors[2].CurValue - LastStep - OVEditors[0].CurValue) /
                       (OVEditors[2].CurValue - OVEditors[0].CurValue) );
  1: ScaleCoef := Abs( (OVEditors[3].CurValue - LastStep - OVEditors[1].CurValue) /
                       (OVEditors[3].CurValue - OVEditors[1].CurValue) );
  2: ScaleCoef := Abs( (OVEditors[2].CurValue + LastStep - OVEditors[0].CurValue) /
                       (OVEditors[2].CurValue - OVEditors[0].CurValue) );
  3: ScaleCoef := Abs( (OVEditors[3].CurValue + LastStep - OVEditors[1].CurValue) /
                       (OVEditors[3].CurValue - OVEditors[1].CurValue) );
  end; // case LastVEdInd of

  NewDRect := N_RectScaleA( CurDRect, ScaleCoef, FixedPoint );
  SetRect( NewDRect );
end; // end of procedure TN_VRectEd1Form.UpdateValuesByAspect

//***********************************  TN_VRectEd1Form.CalcAndShowAspect  ******
// Calculate and Show Aspect
//
procedure TN_VRectEd1Form.CalcAndShowAspect();
begin
  Aspect := N_RectAspect( GetRect() );
  edAspect.Text := Format( '%.4f', [Aspect] );
end; // end of procedure TN_VRectEd1Form.CalcAndShowAspect

//***********************************  TN_VRectEd1Form.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_VRectEd1Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_VRectEd1Form.CurStateToMemIni

//***********************************  TN_VRectEd1Form.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_VRectEd1Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_VRectEd1Form.MemIniToCurState

//****************  TN_RAFRectVEditor class methods  ******************

//**************************************** TN_RAFRectVEditor.Edit
// Rect External Editor
//
function TN_RAFRectVEditor.Edit( var AData ) : Boolean;
begin
  with TN_VRectEd1Form.Create( Application ) do
  begin
    InitVVEdForm1( @AData, RAFrame, 'VVE' );
    Show();
  end;
  Result := False;
end; //*** procedure TN_RAFRectVEditor.Edit


    //*********** Global Procedures  *****************************
{
Initialization
  K_RegRAFEditor( 'NRectVEditor', TN_RAFRectVEditor );
}

end.
