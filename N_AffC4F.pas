unit N_AffC4F;
// TN_AffCoefs4Form for editing AffCoefs4 coefs as Strings
// ( for "visual"(by shift, rotatate and so on) editing AffCoefs use N_ACEdF )

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,
  N_Types, N_Gra0, N_Gra1, N_Rast1Fr;

type TN_AffCoefs4Form = class( TForm ) // for editing AffCoefs4 coefs as Strings
    bnApply: TButton;
    bnOK: TButton;
    PageControl: TPageControl;
    edCySy: TEdit;
    Label1: TLabel;
    edCxSx: TEdit;
    Label2: TLabel;
    tsTwoRects: TTabSheet;
    tsStandard: TTabSheet;
    rgConvertionType: TRadioGroup;
    bnCancel: TButton;
    bnRecalc: TButton;
    edInpRect: TLabeledEdit;
    edOutRect: TLabeledEdit;

    procedure bnRecalcClick ( Sender: TObject );
    procedure rgConvertionTypeClick ( Sender: TObject );
    procedure bnApplyClick  ( Sender: TObject );
    procedure bnOKClick     ( Sender: TObject );
    procedure bnCancelClick ( Sender: TObject );
  public
    AffCoefs4:  TN_AffCoefs4;
    PAffCoefs4: TN_PAffCoefs4; // pointer to external coefs to change
    ARFrame:    TN_Rast1Frame; // parametr of ApplyProc procedure
    ApplyProc: procedure( const AAffCoefs4: TN_AffCoefs4; ARFrame: TN_Rast1Frame );
end; // type TN_AffCoefs4Form = class( TForm )

function  N_GetAffCoefs4Form ( var AAffCoefs4: TN_AffCoefs4 ): TN_AffCoefs4Form;

implementation
uses
  N_Lib0, N_Lib1, N_LibF;
{$R *.DFM}

procedure TN_AffCoefs4Form.bnRecalcClick( Sender: TObject );
// Recalculate edCxSx.Text, edCySy.Text fields by PageControl fields
var
  TmpAffCoefs: TN_AffCoefs4;
  InpRect, OutRect: TFRect;
  Str: string;
begin
  case PageControl.ActivePageIndex of

  0: with tsTwoRects do // set edCxSx.Text, edCySy.Text fields by Two Rects
  begin
    Str := edInpRect.Text;
    InpRect := N_ScanFRect( Str );
    Str := edOutRect.Text;
    OutRect := N_ScanFRect( Str );

    TmpAffCoefs := N_CalcAffCoefs4( InpRect, OutRect );
    edCxSx.Text := Format( '%g %g', [ TmpAffCoefs.CX, TmpAffCoefs.SX ] );
    edCySy.Text := Format( '%g %g', [ TmpAffCoefs.CY, TmpAffCoefs.SY ] );
  end; // 0: with tsTwoRects do

  1: with tsStandard do
  begin
    case rgConvertionType.ItemIndex of
    0: begin // Identity convertion
      edCxSx.Text := ' 1.0  0.0';
      edCySy.Text := ' 1.0  0.0';
    end;
    1: begin // Y-reverse convertion
      edCxSx.Text := ' 1.0  0.0';
      edCySy.Text := '-1.0  0.0';
    end;
    end; // case rgConvertionType.ItemIndex of
  end; // 1: with tsStandard do

  end; // case PageControl.ActivePageIndex of
end; // end of procedure TN_AffCoefs4Form.bnRecalcClick

procedure TN_AffCoefs4Form.rgConvertionTypeClick( Sender: TObject );
// Recalc Coefs automatically on each Mouse Click
begin
  bnRecalcClick( nil );
end; // end of procedure TN_AffCoefs4Form.rgConvertionTypeClick

procedure TN_AffCoefs4Form.bnApplyClick( Sender: TObject );
// set AffCoefs4 by edCxSx.Text, edCySy.Text fields
var
  Str: string;
begin
  Str := edCxSx.Text;
  AffCoefs4.CX := N_ScanDouble( Str );
  AffCoefs4.SX := N_ScanDouble( Str );
  Str := edCySy.Text;
  AffCoefs4.CY := N_ScanDouble( Str );
  AffCoefs4.SY := N_ScanDouble( Str );
  PAffCoefs4^ := AffCoefs4; // update external var
  if @ApplyProc <> nil then ApplyProc( AffCoefs4, ARFrame );
end; // end of procedure TN_AffCoefs4Form.bnApplyClick

procedure TN_AffCoefs4Form.bnOKClick( Sender: TObject );
// call Apply event handler and close Form
begin
  bnApplyClick( nil );
  Close;
end; // end of procedure TN_AffCoefs4Form.bnOKClick

procedure TN_AffCoefs4Form.bnCancelClick( Sender: TObject );
// close Form without changing AffCoefs4
begin
  Close;
end; // end of procedure TN_AffCoefs4Form.bnCancelClick


    //*********** Global Procedures  *****************************

//***********************************************  N_GetAffCoefs4Form  ******
// Create N_AffCoefs4Form
//
function N_GetAffCoefs4Form( var AAffCoefs4: TN_AffCoefs4 ): TN_AffCoefs4Form;
begin
  Result := TN_AffCoefs4Form.Create( Application );
  with Result do
  begin
    OnClose := N_LibForm.SetDestroyAfterClose;
    AffCoefs4  := AAffCoefs4;
    PAffCoefs4 := @AAffCoefs4;
    edCxSx.Text := Format( '%g %g', [ AffCoefs4.CX, AffCoefs4.SX ] );
    edCySy.Text := Format( '%g %g', [ AffCoefs4.CY, AffCoefs4.SY ] );
  end;
end; // end of function N_GetAffCoefs4Form

end.
