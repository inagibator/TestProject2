unit K_FCMSCalibrate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_Types, N_BaseF, N_Comp2,
  K_CM0, K_UDT1;

type
  TK_FormCMSCalibrate = class(TN_BaseForm)
    LbEdit: TLabeledEdit;
    BtCancel: TButton;
    BtOK: TButton;
    LbUnit: TLabel;
    CmBUnits: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure LbEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CmBUnitsChange(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
    procedure ShowWarning( AUInd : Integer );
    function RoundAndCheckMinMax( AUInd : Integer; var ANVal : Double ) : Boolean;
    function GetValueFromTextByUnits( AUInd : Integer; var ANVal : Double ) : Boolean;
  public
    { Public declarations }
    CUDMeasure : TN_UDBase;
    CMMLength   : Double;
    CInchLength : Double;
    CDUnits : TN_CMSlideDUnits; // Slide Current Units
    CSlide  : TN_UDCMSlide;      // Calibrated Slide
    CUDLine : TN_UDPolyLine;    // Calibrated Line
  end;

var
  K_FormCMSCalibrate: TK_FormCMSCalibrate;

function K_CMSlideCalibrateDlg( AUDMeasure : TN_UDBase; APolylineFlag : Boolean ) : Boolean;

implementation

uses Math,
  N_Lib0, N_Lib1, N_Comp1, N_CompCL, N_CM1, K_CML1F;

{$R *.dfm}

function K_CMSlideCalibrateDlg( AUDMeasure : TN_UDBase; APolylineFlag : Boolean ) : Boolean;
var
  SLeng1, SLeng2 : string;
  NValue : Double;
  PrevUnits : Integer;
begin
  with TK_FormCMSCalibrate.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    CUDMeasure := AUDMeasure;
    if APolylineFlag then
      Caption := K_CML1Form.LLLCalibrate1.Caption // '   Enter length of the Polyline'
    else
      Caption := K_CML1Form.LLLCalibrate2.Caption; // '   Enter length of the Line';
    N_Dump1Str( 'Calibrate Image by Line before ShowModal' );
    Result := ShowModal() = mrOK;
    if Result then begin
      if CmBUnits.ItemIndex <> Ord(CDUnits) then // Slide Units Were Changed
        N_IntToMemIni( 'VObjAttrs', 'DistanceUnits', CmBUnits.ItemIndex );
      PrevUnits := Ord(CDUnits);
      CDUnits := TN_CMSlideDUnits(CmBUnits.ItemIndex);
      GetValueFromTextByUnits( Ord(CDUnits), NValue );
      if cmpfVObjMain in N_CM_LogFlags then begin
        SLeng1 := CSlide.DistMM2UnitsText( CMMLength );
        SLeng2 := CSlide.DistMM2UnitsText( NValue, PrevUnits );
        N_Dump1Str( 'Calibrate Image by changing MLine length from ' + SLeng1 +
                      ' to ' + SLeng2 );
      end;
      CSlide.CalibrateByLine( CUDLine, NValue, CDUnits )
    end else
      N_Dump1Str( 'Cancel Calibrate Image by Line' );
  end;
end;

procedure TK_FormCMSCalibrate.FormShow(Sender: TObject);
var
 i, j : Integer;
 Str : string;
begin
  inherited;
  CmBUnits.Items.Clear;
//  for i := 0 to High(K_CMSDistUnitsAliase) do
//    CmBUnits.Items.Add( ' ' + K_CMSDistUnitsAliase[i] );
  for i := 0 to K_CML1Form.LLLDistUnitsAliase.Items.Count -1 do
    CmBUnits.Items.Add( ' ' + K_CML1Form.LLLDistUnitsAliase.Items[i] );

  CSlide := TN_UDCMSlide(CUDMeasure.Owner.Owner.Owner);
  CDUnits := CSlide.P().CMSDB.DUnits;
  CmBUnits.ItemIndex := Ord(CDUnits);
//!! Old  CUDLine := TN_UDPolyLine(CUDMeasure.DirChild(0));
  CUDLine := TN_UDPolyLine(CUDMeasure.DirChild(1));
  with CSlide do begin
    CMMLength := CalcMMLineLength( CUDLine );
    CInchLength := DistMM2Units( CMMLength, Ord(cmsduInch) );
  end;

  // Distance Text
  with CUDMeasure, TN_UDParaBox(DirChild(DirHigh)),
       TN_POneTextBlock(PSP.CParaBox.CPBTextBlocks.P())^ do
    Str := OTBMText;

  // Remove Units from Text
  if Str[1] = '=' then
    Str := Copy( Str, 3, Length(Str) );
  j := 0;
  for i := Length(Str) downto 1 do begin
    j := i;
    if (Str[j] >= '0') and (Str[j] <= '9') then Break;
  end;
  LbEdit.Text := Copy( Str, 1, j );

end;

procedure TK_FormCMSCalibrate.LbEditKeyDown(Sender: TObject; var Key: Word;
                           Shift: TShiftState);
begin
  if Key = VK_Return then BtOKClick(Sender);
end;

procedure TK_FormCMSCalibrate.ShowWarning( AUInd : Integer );
var
  MaxLeng : Double;
begin
  MaxLeng := 10000;
  if AUInd = Ord(cmsduInch) then
    MaxLeng := 254000;
  K_CMShowMessageDlg( format( K_CML1Form.LLLObjEdit2.Caption,
//         'Length should be between %g and %s',
              [1/IntPower( 10, K_CMSDistRoundFactor[AUInd] ),
               CSlide.DistMM2UnitsText( MaxLeng, AUInd )]), mtWarning );
  LbEdit.SelectAll();
  LbEdit.SetFocus();
end;

function TK_FormCMSCalibrate.RoundAndCheckMinMax( AUInd : Integer; var ANVal : Double ) : Boolean;
var
  CFactor : Double;
begin
  CFactor := IntPower( 10, K_CMSDistRoundFactor[AUInd] );
  ANVal  := Round( ANVal * CFactor ) / CFactor;
  Result := (ANVal >= 1 / CFactor) and (ANVal <= 10000);
end;

function TK_FormCMSCalibrate.GetValueFromTextByUnits( AUInd : Integer;
                                                var ANVal : Double ) : Boolean;
var
  R : Extended;
begin
  Result := TextToFloat( PChar(LbEdit.Text), R, fvExtended );
  if not Result then Exit;
  ANVal := R;
  Result := RoundAndCheckMinMax( AUInd, ANVal );
end;

procedure TK_FormCMSCalibrate.CmBUnitsChange(Sender: TObject);
var
  WLength : Double;
  UnitsInd : Integer;
  PrevUnitsInd : Integer;
begin
  UnitsInd := CmBUnits.ItemIndex;
  if UnitsInd = -1 then Exit;
  PrevUnitsInd := (UnitsInd + 1) and 1;
  if not GetValueFromTextByUnits( PrevUnitsInd, WLength ) then  // Get by invert units
    ShowWarning( UnitsInd )
  else begin
    case UnitsInd of
      Ord(cmsduMM)  : WLength := WLength * 25.4; // inches => milimeters
      Ord(cmsduInch): WLength := WLength / 25.4; // milimeters => inches
    end;
    LbEdit.Text := Format( '%g', [WLength]);
    if not GetValueFromTextByUnits( UnitsInd,  WLength ) then
      ShowWarning( UnitsInd )
    else
      LbEdit.Text := Format( '%g', [WLength]);
  end;
  LbEdit.SelectAll();
  LbEdit.SetFocus();

end;

procedure TK_FormCMSCalibrate.BtOKClick(Sender: TObject);
var
  UnitsInd : Integer;
  WLength : Double;
begin
  UnitsInd := CmBUnits.ItemIndex;
  if UnitsInd = -1 then Exit;

  if GetValueFromTextByUnits( UnitsInd,  WLength ) then
    ModalResult := mrOK
  else
    ShowWarning( UnitsInd );

end;

end.
