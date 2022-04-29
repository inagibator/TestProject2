unit K_FCMSCalibrate1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_Types, N_BaseF, N_Comp2,
  K_CM0, K_UDT1;

type
  TK_FormCMSCalibrate1 = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    CmBUnits: TComboBox;
    LbEdit: TEdit;
    procedure FormShow(Sender: TObject);
    procedure LbEditKeyDown( Sender: TObject; var Key: Word;
                             Shift: TShiftState );
    procedure CmBUnitsChange(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
  private
    { Private declarations }
    function GetTextFromSlideResolution( ARes : Double; AResUintsInd : Integer ) : string;
    function BuildSlideResolutionByUnits( ARes : Double; AResUintsInd : Integer ) : double;
    function IfShowWarning( AUInd : Integer; ANVal : Double ) : Boolean;
    function RoundAndCheckMinMax( AUInd : Integer; var ANVal : Double ) : Boolean;
    function GetValueFromTextRoundByUnits( AUInd : Integer; var ANVal : Double ) : Boolean;
  public
    { Public declarations }
    CMMLength   : Double;
    CInchLength : Double;
    PrevUnitsInd : Integer;
    CDUnits : TN_CMSlideResUnits; // Current Resolution Units
    WSlide : TN_UDCMSlide;      // Calibrated Slide
//  CSlide : TN_UDCMSlide;      // Calibrated Slide
//    CUDLine : TN_UDPolyLine;    // Calibrated Line
  end;

var
  K_FormCMSCalibrate1: TK_FormCMSCalibrate1;

function K_CMSlideResolutionDlg( ) : Boolean;

implementation

uses Math,
  N_Lib0, N_Lib1, N_Comp1, N_CompCL, N_CM1, N_CMMain5F, K_CML1F;

{$R *.dfm}


function K_CMSlideResolutionDlg( ) : Boolean;
var
  SPrevRes, SNewRes : string;
begin


  with TK_FormCMSCalibrate1.Create(Application) do
  begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    CDUnits := TN_CMSlideResUnits(N_MemIniToInt( 'CMS_Main', 'ImgResolutionUnits', Ord(cmiDPI) ));
    WSlide := N_CM_MainForm.CMMFActiveEdFrame.EdSlide;
    SPrevRes := GetTextFromSlideResolution( WSlide.P.CMSDB.PixPermm, Ord(CDUnits) );
    PrevUnitsInd := Ord(CDUnits);
    N_Dump2Str( 'Calibrate Image source resolution = ' + SPrevRes  );
    LbEdit.Text := SPrevRes;
//    N_s := CmBUnits.Items.CommaText;
    Result := ShowModal() = mrOK;
    if Result then
    begin
      if CmBUnits.ItemIndex <> Ord(CDUnits) then // Slide Units Were Changed
        N_IntToMemIni( 'CMS_Main', 'ImgResolutionUnits', CmBUnits.ItemIndex );
      CDUnits := TN_CMSlideResUnits(CmBUnits.ItemIndex);
      if cmpfVObjMain in N_CM_LogFlags then
      begin
        SNewRes := GetTextFromSlideResolution( WSlide.P.CMSDB.PixPermm, Ord(CDUnits) );
        N_Dump1Str( 'Calibrate Image by changing resolution from ' + SPrevRes +
                      ' to ' + SNewRes );
      end;
      WSlide.RebuildAllMLineTexts();
      with WSlide.P.CMSDB do
      begin
        SFlags := SFlags + [cmsfUserCalibrated];
        SFlags := SFlags - [cmsfProbablyCalibrated];
      end;
    end
    else
      N_Dump2Str( 'Cancel Calibrate Image by resolution' );
  end;
end;

function TK_FormCMSCalibrate1.GetTextFromSlideResolution( ARes : Double; AResUintsInd : Integer ) : string;
var
  R : Double;
begin
  R := ARes;
  if AResUintsInd = Ord(cmiPSMN) then
    Result := format( '%3.1f', [1000 / R] ) // Size in microns
  else
  begin
    if AResUintsInd = Ord(cmiPPMM) then
      R := Round(R*100)/100                 // Pix per mm
    else
      R := Round( 254 * R ) / 10;           // Pix per inch

    Result := Format( '%g', [R]);
  end;
end;

function TK_FormCMSCalibrate1.BuildSlideResolutionByUnits( ARes : Double; AResUintsInd : Integer ) : double;
begin
  if AResUintsInd = Ord(cmiPSMN) then
    Result := 1000 / ARes
  else
  if AResUintsInd = Ord(cmiPPMM) then
    Result := ARes
  else
    Result := ARes / 25.4;
end;

procedure TK_FormCMSCalibrate1.FormShow(Sender: TObject);
var
 i : Integer;
begin
  inherited;
  CmBUnits.Items.Clear;
//  for i := 0 to High(K_CMSDistUnitsAliase) do
//    CmBUnits.Items.Add( ' ' + K_CMSResolutionUnitsAliase[i] );
  for i := 0 to K_CML1Form.LLLResolutionUnitsAliase.Items.Count -1 do
    CmBUnits.Items.Add( ' ' + K_CML1Form.LLLResolutionUnitsAliase.Items[i] );

  CmBUnits.ItemIndex := Ord(CDUnits);

end;

procedure TK_FormCMSCalibrate1.LbEditKeyDown(Sender: TObject; var Key: Word;
                           Shift: TShiftState);
begin
  if Key = VK_Return then BtOKClick(Sender);
end;

function TK_FormCMSCalibrate1.IfShowWarning( AUInd : Integer; ANVal : Double ) : Boolean;
var
  MinRes : Double;
  MaxRes : Double;
begin
  MaxRes := 10000;
  MinRes := 1;
  if AUInd = Ord(cmiDPI) then
  begin
    MinRes := 0.1;
    MaxRes := 254000;
  end
  else
  if AUInd = Ord(cmiPSMN) then
  begin
    MinRes := 0.1;
    MaxRes := 1000;
  end;
  Result := (ANVal >= MinRes) and (ANVal <= MaxRes);
  if Result then Exit;
  K_CMShowMessageDlg( format( K_CML1Form.LLLCalibrate.Caption,
//     'Resolution should be between %g and %g',
                      [ MinRes, MaxRes ]), mtWarning );
  LbEdit.SelectAll();
  LbEdit.SetFocus();
end;

function TK_FormCMSCalibrate1.RoundAndCheckMinMax( AUInd : Integer; var ANVal : Double ) : Boolean;
var
  CFactor : Double;
begin
  CFactor := 10;
  if AUInd = Ord(cmiPPMM) then
    CFactor := 1000;
  ANVal  := Round( ANVal * CFactor ) / CFactor;
  Result := IfShowWarning( AUInd, ANVal );
end;

function TK_FormCMSCalibrate1.GetValueFromTextRoundByUnits( AUInd : Integer;
                                                       var ANVal : Double ) : Boolean;
var
  R : Extended;
begin
  Result := TextToFloat( PChar(LbEdit.Text), R, fvExtended );
  if not Result then Exit;
  ANVal := R;
  Result := RoundAndCheckMinMax( AUInd, ANVal );
end;

procedure TK_FormCMSCalibrate1.CmBUnitsChange(Sender: TObject);
var
  WResolution : Double;
  UnitsInd : Integer;
begin
  UnitsInd := CmBUnits.ItemIndex;
  if UnitsInd = -1 then Exit;
  if GetValueFromTextRoundByUnits( PrevUnitsInd, WResolution ) then
  begin
    WResolution := BuildSlideResolutionByUnits( WResolution, PrevUnitsInd );
    LbEdit.Text := GetTextFromSlideResolution( WResolution, UnitsInd );
  end;

  PrevUnitsInd := UnitsInd; // Save for Future Use

  LbEdit.SelectAll();
  LbEdit.SetFocus();

end;

procedure TK_FormCMSCalibrate1.BtOKClick(Sender: TObject);
var
  UnitsInd : Integer;
  WRes : Double;
begin
  UnitsInd := CmBUnits.ItemIndex;
  if UnitsInd = -1 then Exit;
{
  if GetValueFromTextRoundByUnits( UnitsInd,  WRes ) then
    ModalResult := mrOK
  else
    WSlide.P.CMSDB.PixPermm := BuildSlideResolutionByUnits( WRes, UnitsInd );
}
  if GetValueFromTextRoundByUnits( UnitsInd,  WRes ) then
  begin
    WSlide.P.CMSDB.PixPermm := BuildSlideResolutionByUnits( WRes, UnitsInd );
    ModalResult := mrOK;
  end;
end;

end.
