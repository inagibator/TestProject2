unit K_FCMProfileSetting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_BaseF, N_Types,
  K_CM0;

type
  TK_FormCMProfileSetting = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    BtApply: TButton;
    IconImage: TImage;
    LbProfileName: TLabel;
    RGResType: TRadioGroup;
    EdMicron: TEdit;
    EdPixCM: TEdit;
    EdDPI: TEdit;
    ChBSkipDevRes: TCheckBox;
    GBDICOM: TGroupBox;
    LbVolt: TLabel;
    EdVoltage: TEdit;
    LbCur: TLabel;
    EdCurrent: TEdit;
    LbExpTime: TLabel;
    EdExpTime: TEdit;
    LbMod: TLabel;
    CmBModality: TComboBox;
    procedure RGResTypeClick(Sender: TObject);
    procedure EdMicronKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtApplyClick(Sender: TObject);
    procedure EdMicronExit(Sender: TObject);
    procedure ChBSkipDevResClick(Sender: TObject);
    procedure CmBModalityChange(Sender: TObject);
    procedure EdVoltageChange(Sender: TObject);
  private
    FResolution : Double;
    FPResolution : PFloat;
    FDCMAttrs : TK_CMDCMAttrs;
    FPDCMAttrs : TK_PCMDCMAttrs;
    { Private declarations }
    procedure RebuildValues();
    procedure GetValues(  );
  public
    { Public declarations }
end;

var
  K_FormCMProfileSetting: TK_FormCMProfileSetting;

function  K_CMProfileSettingDlg( var AResolution : Float;
              const AProfileName : string; AIconImage : TImage;
              APDCMAttrs : TK_PCMDCMAttrs  ) : Boolean;

implementation

{$R *.dfm}

//**************************************************** K_CMProfileSettingDlg ***
// Change Profile Calibration Settings Dialog
//
//     Parameters
// AResolution - Profile Device Resolution varaible  in DPI
// AProfileName - Profile Name
// AIconImage   - Profile Icon Image
// Result - Return TRUE if Auto Image Processing attributes were changed
//
function  K_CMProfileSettingDlg( var AResolution : Float;
              const AProfileName : string; AIconImage : TImage;
              APDCMAttrs : TK_PCMDCMAttrs  ) : Boolean;
var
  Ind : Integer;
begin
  with TK_FormCMProfileSetting.Create( Application ) do begin
//    BaseFormInit( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    IconImage.Picture := AIconImage.Picture;
    LbProfileName.Caption := AProfileName;
    FResolution := AResolution;
    RGResType.ItemIndex := 2;
    RGResTypeClick( nil );
    FPResolution := @AResolution;
    RebuildValues();

    // Prepare DICOM Attrs
    FPDCMAttrs := APDCMAttrs;
    K_CMPrepDialogDCMAttrs( FPDCMAttrs, FDCMAttrs );
{
    FDCMAttrs := APDCMAttrs^;
    if FDCMAttrs.CMDCMKVP = 0 then
      FDCMAttrs.CMDCMKVP := K_CMSlideDefDCMKVP;

    if FDCMAttrs.CMDCMTubeCur = 0 then
      FDCMAttrs.CMDCMTubeCur := K_CMSlideDefDCMTubeCur;

    if FDCMAttrs.CMDCMExpTime = 0 then
      FDCMAttrs.CMDCMExpTime := K_CMSlideDefDCMExpTime;
}

{
    CmBModality.Items.Clear;
    CmBModality.Items.Add('');
    CmBModality.Items.Add(K_CMSlideDefDCMModColorXC);
    CmBModality.Items.Add(K_CMSlideDefDCMModXRayIO);
    CmBModality.Items.Add(K_CMSlideDefDCMModXRayPan);

    if K_CMSlideDefDCMModXRayCR = FDCMAttrs.CMDCMModality then
      Ind := 2
    else
    begin
      Ind := CmBModality.Items.IndexOf( FDCMAttrs.CMDCMModality );
      if Ind < 0 then Ind := 0;
    end;
}
    K_FillDICOMModalitiesList( CmBModality.Items );
    Ind := CmBModality.Items.IndexOf( FDCMAttrs.CMDCMModality );
    if Ind < 0 then Ind := 0;

    CmBModality.ItemIndex := Ind;
    CmBModalityChange( CmBModality );
    Result := ShowModal = mrOK;
    if not Result then Exit;

    AResolution := FResolution;

    // Get DICOM Attrs
    K_CMPrepSlideDCMAttrs( @FDCMAttrs, FPDCMAttrs^ );
{
    with FDCMAttrs do
    begin
      EmptyAttrs := (CMDCMModality = '') or (CMDCMModality = K_CMSlideDefDCMModColor);
      if EmptyAttrs or (CMDCMKVP = K_CMSlideDefDCMKVP) then
        CMDCMKVP := 0;
      if EmptyAttrs or (CMDCMTubeCur = K_CMSlideDefDCMTubeCur) then
        CMDCMKVP := 0;
      if EmptyAttrs or (CMDCMExpTime = K_CMSlideDefDCMExpTime) then
        CMDCMKVP := 0;
    end;
    APDCMAttrs^ := FDCMAttrs;
}
  end;
end; // K_CMProfileSettingDlg

//***************************************** TK_FormCMProfileSetting.RebuildValues ***
//
procedure TK_FormCMProfileSetting.RebuildValues();
begin
  ChBSkipDevRes.Checked := FResolution <> 0;
  ChBSkipDevResClick( nil );
  ChBSkipDevRes.Enabled := FResolution <= 0;
  if FResolution <= 0 then begin
    EdMicron.Text := '';
    EdPixCM.Text := '';
    EdDPI.Text := '';
  end else begin
    EdMicron.Text := format( '%3.1f', [25400 / FResolution] );
    EdPixCM.Text := IntToStr( Round(FResolution / 25.4) );
    EdDPI.Text := IntToStr( Round(FResolution) );
  end;

end; // TK_FormCMProfileSetting.RebuildValues

//***************************************** TK_FormCMProfileSetting.RGResTypeClick ***
//
procedure TK_FormCMProfileSetting.RGResTypeClick(Sender: TObject);
begin
  case RGResType.ItemIndex of
  0: begin
    EdMicron.Enabled := TRUE;
    if Visible then
      EdMicron.SetFocus();
    EdPixCM.Enabled  := FALSE;
    EdDPI.Enabled    := FALSE;
  end;
  1: begin
    EdMicron.Enabled := FALSE;
    EdPixCM.Enabled  := TRUE;
    if Visible then
      EdPixCM.SetFocus();
    EdDPI.Enabled    := FALSE;
  end;
  2: begin
    EdMicron.Enabled := FALSE;
    EdPixCM.Enabled  := FALSE;
    EdDPI.Enabled    := TRUE;
    if Visible then
      EdDPI.SetFocus();
  end;
  end;
end; // TK_FormCMProfileSetting.RGResTypeClick

//***************************************** TK_FormCMProfileSetting.GetValues ***
//
procedure TK_FormCMProfileSetting.GetValues( );
var
  WResolution : Double; // in DPI
  WStr : string;
begin
  case RGResType.ItemIndex of
  0: WStr := EdMicron.Text;
  1: WStr := EdPixCM.Text;
  2: WStr := EdDPI.Text;
  end;
  WStr := Trim(WStr);
  if WStr = '' then
    FResolution := 0
  else begin
    WResolution := FResolution;
    if RGResType.ItemIndex = 0 then
    begin
      WResolution := StrToFloatDef( WStr, WResolution );
      if WResolution = 0 then
        FResolution := 0
      else
        FResolution :=  25400 / WResolution;
    end
    else
    begin
      WResolution := StrToIntDef( WStr, Round(WResolution) );
      if WResolution = 0 then
        FResolution := 0
      else if RGResType.ItemIndex = 1 then
        FResolution := WResolution * 25.4
      else  if RGResType.ItemIndex = 2 then
        FResolution := WResolution;
    end;
  end;
  ChBSkipDevRes.Checked := FResolution > 0;
  RebuildValues();
end; // TK_FormCMProfileSetting.GetValues

//***************************************** TK_FormCMProfileSetting.EdMicronKeyDown ***
//
procedure TK_FormCMProfileSetting.EdMicronKeyDown( Sender: TObject;
                                        var Key: Word; Shift: TShiftState );
begin
  if Key <> VK_RETURN then Exit;
  GetValues( );
//  RebuildValues();
end; // TK_FormCMProfileSetting.EdMicronKeyDown

//***************************************** TK_FormCMProfileSetting.BtApplyClick ***
//
procedure TK_FormCMProfileSetting.BtApplyClick(Sender: TObject);
begin
//
  FPResolution^ := FResolution;
  K_CMPrepSlideDCMAttrs( @FDCMAttrs, FPDCMAttrs^ );
end; // TK_FormCMProfileSetting.BtApplyClick

//***************************************** TK_FormCMProfileSetting.EdMicronExit ***
//
procedure TK_FormCMProfileSetting.EdMicronExit(Sender: TObject);
begin
  GetValues( );
//  RebuildValues();
end; // TK_FormCMProfileSetting.EdMicronExit

//***************************************** TK_FormCMProfileSetting.ChBSkipDevResClick ***
//
procedure TK_FormCMProfileSetting.ChBSkipDevResClick(Sender: TObject);
begin
  if ChBSkipDevRes.Checked and (FResolution = 0) then
    FResolution  := -1
  else
  if not ChBSkipDevRes.Checked and (FResolution = -1) then
    FResolution  := 0;
end; // TK_FormCMProfileSetting.ChBSkipDevResClick

//******************************* TK_FormCMProfileSetting.CmBModalityChange ***
// CmBModality Change Handler
//
procedure TK_FormCMProfileSetting.CmBModalityChange(Sender: TObject);
var
  Flag : Boolean;
begin
  FDCMAttrs.CMDCMModality := CmBModality.Text;
  Flag := CmBModality.ItemIndex > 3;
  LbVolt.Enabled := Flag;
  EdVoltage.Enabled := Flag;
  if not Flag then
    EdVoltage.Text := ''
  else
//2020-01-12    EdVoltage.Text := IntToStr( FDCMAttrs.CMDCMKVP );
    EdVoltage.Text := FloatToStr( FDCMAttrs.CMDCMKVP );

  LbCur.Enabled := Flag;
  EdCurrent.Enabled := Flag;
  if not Flag then
    EdCurrent.Text := ''
  else
    EdCurrent.Text := IntToStr( FDCMAttrs.CMDCMTubeCur );

  LbExpTime.Enabled := Flag;
  EdExpTime.Enabled := Flag;
  if not Flag then
    EdExpTime.Text := ''
  else
    EdExpTime.Text := IntToStr( FDCMAttrs.CMDCMExpTime );

end; // TK_FormCMProfileSetting.CmBModalityChange

//********************************* TK_FormCMProfileSetting.EdVoltageChange ***
// EdVoltage Change Handler
//
procedure TK_FormCMProfileSetting.EdVoltageChange(Sender: TObject);
var
  WInt : Integer;
  WStr, WStr1 : string;

  procedure ChangeValue( ED : TEdit; var Val : Integer );
  begin
    if not ED.Enabled then Exit;
    WStr1 := Trim(ED.Text);
    WInt := StrToIntDef( WStr1, Val );
    if WInt < 0 then WInt := -WInt;
    Val := WInt;
    WStr := IntToStr( WInt );
    if WStr <> WStr1 then
      ED.Text := WStr;
  end;

  procedure ChangeFValue( ED : TEdit; var Val : Double );
  var
    WF : Float;
  begin
    if not ED.Enabled then Exit;
    WStr1 := Trim(ED.Text);
    WF := StrToFloatDef( WStr1, Val );
    if WF < 0 then WF := -WF;
    Val := WF;
    WStr := FloatToStr( WF );
    if WStr <> WStr1 then
      ED.Text := WStr;
  end;

begin
  if Sender = EdVoltage then
    ChangeFValue( EdVoltage, FDCMAttrs.CMDCMKVP )
  else
  if Sender = EdCurrent then
    ChangeValue( EdCurrent, FDCMAttrs.CMDCMTubeCur )
  else
  if Sender = EdExpTime then
    ChangeValue( EdExpTime, FDCMAttrs.CMDCMExpTime );

end; // TK_FormCMProfileSetting.EdVoltageChange

end.
