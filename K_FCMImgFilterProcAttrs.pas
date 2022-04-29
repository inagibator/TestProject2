unit K_FCMImgFilterProcAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_Types, N_BaseF,
  K_CLib0, K_CM0;

type
  TK_FormCMImgFilterProcAttrs = class(TN_BaseForm)
    PnAll: TPanel;
    GBFilters: TGroupBox;
    LbSmoothPower: TLabel;
    LbSmoothBound: TLabel;
    LbSharpPower: TLabel;
    LbSharpBound: TLabel;
    LbMedianBound: TLabel;
    LbDespeckleBound: TLabel;
    LbNoisePower: TLabel;
    ChBNoise: TCheckBox;
    ChBEqualize: TCheckBox;
    ChBNegate: TCheckBox;
    ChBConvToGrey: TCheckBox;
    TBSmoothPower: TTrackBar;
    LbEdSmoothPower: TLabeledEdit;
    TBSmoothBound: TTrackBar;
    LbEdSmoothBound: TLabeledEdit;
    ChBSmoothAuto: TCheckBox;
    ChBMedian: TCheckBox;
    ChBDespeckle: TCheckBox;
    ChBSmooth: TCheckBox;
    ChBSharp: TCheckBox;
    TBSharpPower: TTrackBar;
    LbEdSharpPower: TLabeledEdit;
    TBSharpBound: TTrackBar;
    LbEdSharpBound: TLabeledEdit;
    ChBSharpAuto: TCheckBox;
    TBMedianBound: TTrackBar;
    LbEdMedianBound: TLabeledEdit;
    ChBMedianAuto: TCheckBox;
    TBDespeckleBound: TTrackBar;
    LbEdDespeckleBound: TLabeledEdit;
    ChBDespeckleAuto: TCheckBox;
    TBNoisePower: TTrackBar;
    LbEdNoisePower: TLabeledEdit;
    GBBriCoGam: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LbLL: TLabel;
    LbLU: TLabel;
    BrightnessTrackBar: TTrackBar;
    GammaTrackBar: TTrackBar;
    ContrastTrackBar: TTrackBar;
    EdBriVal: TEdit;
    EdCoVal: TEdit;
    EdGamVal: TEdit;
    ChBBri: TCheckBox;
    ChBCo: TCheckBox;
    ChBGam: TCheckBox;
    TBLL: TTrackBar;
    EdLLVal: TEdit;
    TBLU: TTrackBar;
    EdLUVal: TEdit;
    ChBAutoLLLU: TCheckBox;
    ChBLLLU: TCheckBox;
    GBFlipRotate: TGroupBox;
    RGRotate_4: TRadioGroup;
    ChBHor: TCheckBox;
    ChBVert: TCheckBox;
    BtReset: TButton;
    BtTest: TButton;
    BtTestUndo: TButton;
    BtOK: TButton;
    BtCancel: TButton;
    ChBConvTo8: TCheckBox;
    ChBAutoContrast: TCheckBox;
    LbEqualizePower: TLabel;
    TBEqualizePower: TTrackBar;
    LbEdEqualizePower: TLabeledEdit;
    ChBAutoLLLUPower: TCheckBox;
    LbAutoLLULPower: TLabel;
    TBAutoLLULPower: TTrackBar;
    LbEdAutoLLULPower: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure BrightnessTrackBarChange(Sender: TObject);
    procedure BtResetClick(Sender: TObject);
    procedure EdBriValKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdBriValEnter(Sender: TObject);
    procedure LbEdSharpPowerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtTestClick(Sender: TObject);
    procedure BtTestUndoClick(Sender: TObject);
    procedure ChBSmoothClick(Sender: TObject);
    procedure ChBBriClick(Sender: TObject);
    procedure ChBCoClick(Sender: TObject);
    procedure ChBGamClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure ChBNegateClick(Sender: TObject);
    procedure ChBLLLUClick(Sender: TObject);
    procedure TBSharpPowerChange(Sender: TObject);
    procedure ChBMedianClick(Sender: TObject);
    procedure ChBDespeckleClick(Sender: TObject);
    procedure ChBSharpClick(Sender: TObject);
    procedure ChBNoiseClick(Sender: TObject);
    procedure TBNoisePowerChange(Sender: TObject);
    procedure TBSmoothPowerChange(Sender: TObject);
    procedure TBSmoothBoundChange(Sender: TObject);
    procedure TBMedianBoundChange(Sender: TObject);
    procedure TBSharpBoundChange(Sender: TObject);
    procedure TBDespeckleBoundChange(Sender: TObject);
    procedure ChBSmoothAutoClick(Sender: TObject);
    procedure ChBSharpAutoClick(Sender: TObject);
    procedure ChBMedianAutoClick(Sender: TObject);
    procedure ChBDespeckleAutoClick(Sender: TObject);
    procedure LbEdSmoothPowerKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure LbEdNoisePowerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ChBEqualizeClick(Sender: TObject);
    procedure TBEqualizePowerChange(Sender: TObject);
    procedure LbEdEqualizePowerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TBAutoLLULPowerChange(Sender: TObject);
    procedure LbEdAutoLLULPowerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdBriValExit(Sender: TObject);
  private
    { Private declarations }
    SkipRebuild : Boolean;
    SkipTextRebuild : Boolean;
    SlideSaveStateFlagsAfterUndo : TK_CMSlideSaveStateFlags;
    SlideSizeBeforeUndo: TPoint;
    EditField : TEdit;
    procedure PowerLbEdKeyDown( AKey : word;  ALbEdit: TLabeledEdit;
                           ATrackBar : TTrackBar; var AValue : Float );
    procedure PowerTrackBarChange( ALbEdit: TLabeledEdit;
                           ATrackBar : TTrackBar; var AValue : Float );
    procedure BoundTrackBarChange( ALbEdit: TLabeledEdit; ATrackBar : TTrackBar;
                                   ABoundArray : array of Integer; var AValue : Integer );
    procedure BoundAutoClick( AChBAuto : TCheckBox;
                              ALbEdit: TLabeledEdit;
                              ATrackBar : TTrackBar;
                              var AValue : Integer;
                              ABoundArray : array of Integer;
                              ADefVal : Integer );
  protected
    procedure InitControlsByData(APAutoImgProcAttrs : TK_PCMAutoImgProcAttrs);
  public
    PAutoImgProcAttrs : TK_PCMAutoImgProcAttrs;
    AutoImgProcAttrs : TK_CMAutoImgProcAttrs;
    AutoImgProcAttrsIni : TK_CMAutoImgProcAttrs;
    LSFGamma : TK_LineSegmFunc;
    LSFGamma1 : TK_LineSegmFunc;
    { Public declarations }
    procedure SetAttrsByControlsState();
  end;

var
  K_FormCMImgFilterProcAttrs: TK_FormCMImgFilterProcAttrs;

function K_CMImgFilterProcAttrsDlg( APAutoImgProcAttrs : TK_PCMAutoImgProcAttrs; const ACaption : string;
                                   APAutoImgProcAttrsIni : TK_PCMAutoImgProcAttrs = nil ) : Boolean;

implementation

{$R *.dfm}

uses Math,
  K_VFunc,
  N_Lib1, N_CMMain5F, K_CML1F;

const
  LL_LU_Delta = 4;

var
  SharpSmoothDepthArray : array [0..8] of Integer = (7,9,11,13,17,21,29,37,51);
  MedianDespeckleDepthArray : array [0..5] of Integer = (3,5,7,9,11,13);

//*********************************************** K_CMImgFilterProcAttrsDlg ***
// Change Image Filter Processing Attributes Dialog
//
//     Parameters
// APAutoImgProcAttrs - Pointer to Auto Image Processing Parameters
// APAutoImgProcAttrsIni - Pointer to Auto Image Processing Parameters to Initialize value by reset button
// Result - Return TRUE if Auto Image Processing attributes were changed
//
function K_CMImgFilterProcAttrsDlg( APAutoImgProcAttrs : TK_PCMAutoImgProcAttrs; const ACaption : string;
                                    APAutoImgProcAttrsIni : TK_PCMAutoImgProcAttrs = nil  ) : Boolean;
//var
//  WasChanged : Boolean;
begin

  // Check Memory Space
  with N_CM_MainForm.CMMFActiveEdFrame do
    Result := K_CMSCheckMemForSlideDlg( EdSlide, K_CML1Form.LLLMemory3.Caption,
//                '     There is not enough memory to finish the action.'+#13#10+
//                'Please close some open image(s) or restart Media Suite.',
                                        0, 2 );
  if not Result then Exit;

  K_FormCMImgFilterProcAttrs := TK_FormCMImgFilterProcAttrs.Create(Application);
  with K_FormCMImgFilterProcAttrs do begin
    if ACaption <> '' then
      Caption := ACaption;
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
//    N_PlaceTControl( K_FormCMAutoImgProcAttrs0, nil );
    K_CMInitAutoImgProcAttrs( APAutoImgProcAttrs );
//    K_CMDumpAutoImgProcAttrs( APAutoImgProcAttrs );
    PAutoImgProcAttrs := APAutoImgProcAttrs;
    if APAutoImgProcAttrsIni <> nil then
      AutoImgProcAttrsIni := APAutoImgProcAttrsIni^;


    Result := ShowModal() = mrOK;
    LSFGamma.Free;
    LSFGamma1.Free;
    if Result then
    begin
      SetAttrsByControlsState();
      with AutoImgProcAttrs do
        if (CMAIBriLLFactor = 0) and (CMAIBriULFactor = 100) then
          CMAIBriULFactor := 0;

      Result := not CompareMem( PAutoImgProcAttrs, @AutoImgProcAttrs, SizeOf(TK_CMAutoImgProcAttrs) );

      // Set Modified Attributes Flag if Current State differs from Ini State
      Exclude( AutoImgProcAttrs.CMAIPFlags, K_aipfModified );
      if not CompareMem( @AutoImgProcAttrs, @AutoImgProcAttrsIni, SizeOf(TK_CMAutoImgProcAttrs) ) then
        Include( AutoImgProcAttrs.CMAIPFlags, K_aipfModified );

      PAutoImgProcAttrs^ := AutoImgProcAttrs;

    end;
 end;
 K_FormCMImgFilterProcAttrs := nil;

end; // function K_CMImgFilterProcAttrsDlg

//***************************  TK_FormCMAutoImgProcAttrs.InitControlsByData ***
//
procedure TK_FormCMImgFilterProcAttrs.InitControlsByData(APAutoImgProcAttrs : TK_PCMAutoImgProcAttrs);
var
  WDepth : Integer;
begin
  with APAutoImgProcAttrs^ do
  begin
    SkipRebuild := TRUE;

    ChBEqualize.Checked := K_aipfEqualize in CMAIPFlags;
    ChBAutoContrast.Checked := K_aipfAutoContrast in CMAIPFlags;
    ChBNegate.Checked := K_aipfNegate in CMAIPFlags;
    ChBConvToGrey.Checked   := K_aipfConvToGrey in CMAIPFlags;
    ChBConvTo8.Checked      := K_aipfConvTo8 in CMAIPFlags;
    ChBSmooth.Checked := K_aipfSmooth in CMAIPFlags;
    ChBMedian.Checked := K_aipfMedian in CMAIPFlags;
    ChBDespeckle.Checked := K_aipfDespeckle in CMAIPFlags;
    ChBNoise.Checked  := K_aipfNRSelf in CMAIPFlags;
    ChBSharp.Checked  := K_aipfSharp in CMAIPFlags;

    ChBHor.Checked    := K_aipfFlipHor in CMAIPFlags;
    ChBVert.Checked   := K_aipfFlipVert in CMAIPFlags;

    ChBBri.Checked           := K_aipfBri in CMAIPFlags;
    ChBCo.Checked            := K_aipfCo in CMAIPFlags;
    ChBGam.Checked           := K_aipfGam in CMAIPFlags;
    ChBLLLU.Checked          := K_aipfLLUL in CMAIPFlags;
    ChBAutoLLLU.Checked      := K_aipfAutoLLUL in CMAIPFlags;
    ChBAutoLLLUPower.Checked := K_aipfAutoLLULPower in CMAIPFlags;

    RGRotate_4.ItemIndex := CMAIPAngl and 3;


    BrightnessTrackBar.Position := Round( LSFGamma.Func2Arg( CMAIPBriFactor ) );
    GammaTrackBar.Position      := Round( LSFGamma.Func2Arg( CMAIPGamFactor ) );
    ContrastTrackBar.Position   := Round( LSFGamma.Func2Arg( CMAIPCoFactor ) );

    TBAutoLLULPower.Position := Round( TBAutoLLULPower.Max * CMAIAutoLLULPower );
    TBAutoLLULPowerChange(nil);

    if CMAIEqualizePower = K_CMAIEqualizeSpec then
      CMAIEqualizePower := K_CMAIEqualizeMax;
    TBEqualizePower.Position := Round( TBEqualizePower.Max * CMAIEqualizePower );
    TBEqualizePowerChange(nil);

    TBNoisePower.Position       := Round( TBNoisePower.Max * CMAINRThreshold1 );

    TBSharpPower.Position       := Round( TBSharpPower.Max * CMAISharpPower );
    WDepth := CMAISharpDepth;
    ChBSharpAuto.Checked        := CMAISharpDepth <= 0;
    if ChBSharpAuto.Checked then
      CMAISharpDepth := 17
    else
      CMAISharpDepth := WDepth; // because CMAISharpDepth could be changed while ChBSharpAuto.Checked was changed;
    TBSharpBound.Position := K_IndexOfIntegerInRArray( CMAISharpDepth,
                           @SharpSmoothDepthArray[0], Length(SharpSmoothDepthArray) );
    ChBSharpAutoClick( nil );
    if ChBSharpAuto.Checked then
      CMAISharpDepth := 0;

    TBSmoothPower.Position      := Round( TBSmoothPower.Max * CMAISmoothPower );
    WDepth := CMAISmoothDepth;
    ChBSmoothAuto.Checked       := CMAISmoothDepth <= 0;
    if ChBSmoothAuto.Checked then
      CMAISmoothDepth := 17
    else
      CMAISmoothDepth := WDepth; // because CMAISmoothDepth could be changed while ChBSmoothAuto.Checked was changed;

    TBSmoothBound.Position := K_IndexOfIntegerInRArray( CMAISmoothDepth,
                           @SharpSmoothDepthArray[0], Length(SharpSmoothDepthArray) );
    ChBSmoothAutoClick( nil );
    if ChBSmoothAuto.Checked then
      CMAISmoothDepth := 0;

    WDepth := CMAIMedianDepth;
    ChBMedianAuto.Checked        := CMAIMedianDepth <= 0;
    if ChBMedianAuto.Checked then
      CMAIMedianDepth := 5
    else
      CMAIMedianDepth := WDepth; // because CMAIMedianDepth could be changed while ChBMedianAuto.Checked was changed;
    TBMedianBound.Position := K_IndexOfIntegerInRArray( CMAIMedianDepth,
                           @MedianDespeckleDepthArray[0], Length(MedianDespeckleDepthArray) );
    ChBMedianAutoClick( nil );

    if not ChBMedianAuto.Visible then ChBMedianAuto.Checked := FALSE;
    if ChBMedianAuto.Checked then
      CMAIMedianDepth := 0;

    WDepth := CMAIDespeckleDepth;
    ChBDespeckleAuto.Checked := CMAIDespeckleDepth <= 0;
    if ChBDespeckleAuto.Checked then
      CMAIDespeckleDepth := 5
    else
      CMAIDespeckleDepth := WDepth; // because CMAIDespeckleDepth could be changed while ChBDespeckleAuto.Checked was changed;
    TBDespeckleBound.Position := K_IndexOfIntegerInRArray( CMAIDespeckleDepth,
                           @MedianDespeckleDepthArray[0], Length(MedianDespeckleDepthArray) );
    ChBDespeckleAutoClick( nil );

    if not ChBDespeckleAuto.Visible then ChBDespeckleAuto.Checked := FALSE;
    if ChBDespeckleAuto.Checked then
      CMAIDespeckleDepth := 0;

    if (CMAIBriLLFactor = 0) and (CMAIBriULFactor = 0) then
      CMAIBriULFactor := 100;
    TBLL.Position := Round( LSFGamma1.Func2Arg( CMAIBriLLFactor ) );
    TBLU.Position := Round( LSFGamma1.Func2Arg( CMAIBriULFactor ) );


    //    EdSharpVal.Text := format( '%5.1f', [CMAIPSSFactor * 100] );

    BrightnessTrackBarChange(nil);

    TBSharpPowerChange(nil);
    TBNoisePowerChange(nil);
    TBSmoothPowerChange(nil);

//    TBSmoothBoundChange(nil);
//    TBSharpBoundChange(nil);
//    TBMedianBoundChange(nil);
//    TBDespeckleBoundChange(nil);

    SkipRebuild := FALSE;

    ChBEqualizeClick(nil);
    ChBSharpClick(nil);
    ChBSmoothClick(nil);
    ChBMedianClick(nil);
    ChBDespeckleClick(nil);
    ChBNoiseClick(nil);

    ChBBriClick(nil);
    ChBCoClick(nil);
    ChBGamClick(nil);
    ChBLLLUClick(nil);


  end; // with APAutoImgProcAttrs^ do

end; // TK_FormCMAutoImgProcAttrs.InitControlsByData

//*************************************  TK_FormCMAutoImgProcAttrs.FormShow ***
//
procedure TK_FormCMImgFilterProcAttrs.FormShow(Sender: TObject);
begin
  LSFGamma := TK_LineSegmFunc.Create( [0, -100,  1000, -60,  2500, -20,  7500, 20,  9000, 60,  10000, 100 ] );
  LSFGamma1 := TK_LineSegmFunc.Create( [0, 0,  1000, 100 ] );
  AutoImgProcAttrs := PAutoImgProcAttrs^;
  InitControlsByData( @AutoImgProcAttrs );

  BtTest.Enabled :=  not( uicsSkipActiveSlideEdit in N_CM_MainForm.CMMUICurStateFlags );
  BtTestUndo.Enabled := FALSE;

end; // TK_FormCMAutoImgProcAttrs.FormShow

//********************** TK_FormCMAutoImgProcAttrs.BrightnessTrackBarChange ***
//
procedure TK_FormCMImgFilterProcAttrs.BrightnessTrackBarChange(
  Sender: TObject);
begin
  with AutoImgProcAttrs do begin

    if not SkipRebuild then
    begin
      CMAIPBriFactor := LSFGamma.Arg2Func( BrightnessTrackBar.Position );
      CMAIPGamFactor := LSFGamma.Arg2Func( GammaTrackBar.Position );
      CMAIPCoFactor  := LSFGamma.Arg2Func( ContrastTrackBar.Position );

      if TBLL.Position >= TBLU.Position - LL_LU_Delta then
      begin
        if (Sender = TBLL) then
          TBLL.Position := Max( 0, TBLU.Position - LL_LU_Delta )
        else
        if (Sender = TBLU) then
          TBLU.Position := Min( 1000, TBLL.Position + LL_LU_Delta );
      end;
      CMAIBriLLFactor := LSFGamma1.Arg2Func( TBLL.Position );
      CMAIBriULFactor := LSFGamma1.Arg2Func( TBLU.Position );
    end;

    if not SkipTextRebuild then begin
      EdBriVal.Text := format( '%5.1f', [Round(CMAIPBriFactor*10)/10] );
      EdCoVal.Text  := format( '%5.1f', [Round(CMAIPCoFactor*10)/10] );
      EdGamVal.Text := format( '%5.1f', [Round(CMAIPGamFactor*10)/10] );
      EdLLVal.Text := format( '%5.1f', [Round(CMAIBriLLFactor*10)/10] );
      EdLUVal.Text := format( '%5.1f', [Round(CMAIBriULFactor*10)/10] );
    end;
    TBLL.SelStart := TBLL.Position;
    TBLL.SelEnd   := TBLU.Position;
    TBLU.SelStart := TBLL.Position;
    TBLU.SelEnd   := TBLU.Position;
  end;
end; // TK_FormCMAutoImgProcAttrs.BrightnessTrackBarChange

//*********************  TK_FormCMAutoImgProcAttrs.BrightnessTrackBarChange ***
//
procedure TK_FormCMImgFilterProcAttrs.BtResetClick(Sender: TObject);
begin
  AutoImgProcAttrs := AutoImgProcAttrsIni;
  InitControlsByData( @AutoImgProcAttrsIni );
end;

//******************************* TK_FormCMAutoImgProcAttrs.EdBriValKeyDown ***
//
procedure TK_FormCMImgFilterProcAttrs.EdBriValKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  IVal : Integer;
  function SetNewValue( const ATextVal : string; var AVal : Float ) : Integer;
  begin
    AVal := StrToFloatDef( ATextVal, AVal );
    AVal := Max(-100, AVal);
    AVal := Min( 100, AVal);
    Result := Round( LSFGamma.Func2Arg( AVal ) );
  end;

  function SetNewValue1( const ATextVal : string; var AVal : Float ) : Integer;
  begin
    AVal := StrToFloatDef( ATextVal, AVal );
    AVal := Max(   0, AVal);
    AVal := Min( 100, AVal);
    Result := Round( LSFGamma1.Func2Arg( AVal ) );
  end;

begin
  if Key <> VK_RETURN then Exit;

  SkipRebuild := TRUE;
  with AutoImgProcAttrs do begin
    BrightnessTrackBar.Position := SetNewValue( EdBriVal.Text, CMAIPBriFactor );
    GammaTrackBar.Position      := SetNewValue( EdGamVal.Text, CMAIPGamFactor );
    ContrastTrackBar.Position   := SetNewValue( EdCoVal.Text, CMAIPCoFactor );
    IVal := SetNewValue1( EdLLVal.Text, CMAIBriLLFactor );
    if IVal >= TBLU.Position - LL_LU_Delta then
    begin
      IVal := Max( 0, TBLU.Position - LL_LU_Delta );
      CMAIBriLLFactor := LSFGamma1.Arg2Func( IVal );
    end;
    TBLL.Position := IVal;

    IVal := SetNewValue1( EdLUVal.Text, CMAIBriULFactor );
    if IVal <= TBLL.Position + LL_LU_Delta then
    begin
      IVal := Min( 1000, TBLL.Position + LL_LU_Delta );
      CMAIBriULFactor := LSFGamma1.Arg2Func( IVal );
    end;
    TBLU.Position := IVal;
  end;
  SkipRebuild := FALSE;

end; // TK_FormCMAutoImgProcAttrs.EdBriValKeyDown

//********************************** TK_FormCMAutoImgProcAttrs.EdBriValExit ***
//
procedure TK_FormCMImgFilterProcAttrs.EdBriValExit(Sender: TObject);
var
  WKey: Word;
begin
  WKey := VK_RETURN;
  if (EditField <> nil) and Assigned(EditField.OnKeyDown) then
    EditField.OnKeyDown( EditField, WKey, [] );
  EditField := nil;
end; // procedure TK_FormCMImgFilterProcAttrs.EdBriValExit

//********************************* TK_FormCMAutoImgProcAttrs.EdBriValEnter ***
//
procedure TK_FormCMImgFilterProcAttrs.EdBriValEnter(Sender: TObject);
begin
  TEdit(Sender).SelectAll;
  EditField := TEdit(Sender);

end; // TK_FormCMAutoImgProcAttrs.EdBriValEnter

//************************* TK_FormCMAutoImgProcAttrs.LbEdSharpPowerKeyDown ***
//
procedure TK_FormCMImgFilterProcAttrs.LbEdSharpPowerKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  PowerLbEdKeyDown( Key, LbEdSharpPower, TBSharpPower, AutoImgProcAttrs.CMAISharpPower );
end; // TK_FormCMAutoImgProcAttrs.LbEdSharpPowerKeyDown

//*********************************** TK_FormCMAutoImgProcAttrs.BtTestClick ***
//
procedure TK_FormCMImgFilterProcAttrs.BtTestClick(Sender: TObject);
var
  CMSlideSaveStateFlags : TK_CMSlideSaveStateFlags;
  SavedCursor : TCursor;
  WKey: Word;
  RebuildView : Boolean;
begin

  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourglass;

    RebuildView := BtTestUndo.Enabled;
    if BtTestUndo.Enabled then
    // Undo previous Changes
      BtTestUndoClick( nil );

    N_CM_MainForm.CMMFShowStringByTimer( K_CML1Form.LLLImgFilterProc1.Caption
//      ' Image is processing by custom filter. Please wait ...'
                                       );

    WKey := VK_RETURN;
    EdBriValKeyDown( Sender, WKey, [] );
    LbEdSharpPowerKeyDown( Sender, WKey, [] );

    SetAttrsByControlsState();

    CMSlideSaveStateFlags := K_CMSlideConvByAutoImgProcAttrs( EdSlide,
                                  @AutoImgProcAttrs,  RFrame.RFVectorScale );
    if CMSlideSaveStateFlags <> [] then
    begin

      CMMFFinishImageEditing( K_CML1Form.LLLImgFilterProc2.Caption,
//                     'Image is processed by custom filter',
                     CMSlideSaveStateFlags,
           K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                            Ord(K_shImgActUFilter) ), RebuildView );
      BtTestUndo.Enabled := TRUE;
    end
    else
    begin
    // Undo previous Changes
      if RebuildView then
        CMMFRebuildViewAfterUNDO( SlideSaveStateFlagsAfterUndo, SlideSizeBeforeUndo );
      N_CM_MainForm.CMMFShowString( '' );
    end;
    Screen.Cursor := SavedCursor;
  end; // with N_CM_MainForm do

end; // procedure TK_FormCMAutoImgProcAttrs0.BtTestClick

//*********************************** TK_FormCMAutoImgProcAttrs.BtTestClick ***
//
procedure TK_FormCMImgFilterProcAttrs.BtTestUndoClick(Sender: TObject);
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    // Undo previous Changes
    SlideSizeBeforeUndo := EdSlide.GetMapImage.DIBObj.DIBSize;
    SlideSaveStateFlagsAfterUndo := EdUndoBuf.UBPopSlideState();
    if Sender <> nil then
      CMMFRebuildViewAfterUNDO( SlideSaveStateFlagsAfterUndo, SlideSizeBeforeUndo );
  end;
  BtTestUndo.Enabled := FALSE;
end; // procedure TK_FormCMAutoImgProcAttrs0.BtTestUndoClick

//*********************** TK_FormCMAutoImgProcAttrs.SetAttrsByControlsState ***
//
procedure TK_FormCMImgFilterProcAttrs.SetAttrsByControlsState;
begin
  with AutoImgProcAttrs do
  begin
    CMAIPFlags := [];
    if ChBNoise.Checked then
      Include( CMAIPFlags, K_aipfNRSelf );
    if ChBMedian.Checked then
      Include( CMAIPFlags, K_aipfMedian );
    if ChBDespeckle.Checked then
      Include( CMAIPFlags, K_aipfDespeckle );
    if ChBSmooth.Checked then
      Include( CMAIPFlags, K_aipfSmooth );
    if ChBSharp.Checked then
      Include( CMAIPFlags, K_aipfSharp );

    if ChBEqualize.Checked then
      Include( CMAIPFlags, K_aipfEqualize );
    if ChBAutoContrast.Checked then
      Include( CMAIPFlags, K_aipfAutoContrast );
    if ChBNegate.Checked then
      Include( CMAIPFlags, K_aipfNegate );
    if ChBConvToGrey.Checked then
      Include( CMAIPFlags, K_aipfConvToGrey );
    if ChBConvTo8.Checked then
      Include( CMAIPFlags, K_aipfConvTo8 );

    if ChBHor.Checked then
      Include( CMAIPFlags, K_aipfFlipHor );
    if ChBVert.Checked then
      Include( CMAIPFlags, K_aipfFlipVert );
    if ChBBri.Checked then
      Include( CMAIPFlags, K_aipfBri );
    if ChBCo.Checked then
      Include( CMAIPFlags, K_aipfCo );
    if ChBGam.Checked then
      Include( CMAIPFlags, K_aipfGam );
    if ChBLLLU.Checked then
      Include( CMAIPFlags, K_aipfLLUL );
    if ChBAutoLLLU.Checked then
      Include( CMAIPFlags, K_aipfAutoLLUL );
    if ChBAutoLLLUPower.Checked then
      Include( CMAIPFlags, K_aipfAutoLLULPower );
        ChBAutoLLLUPower.Checked := K_aipfAutoLLULPower in CMAIPFlags;

    CMAIPAngl := RGRotate_4.ItemIndex;

    if CMAIEqualizePower = K_CMAIEqualizeMax then
      CMAIEqualizePower := K_CMAIEqualizeSpec
    else
    if CMAIEqualizePower = K_CMAIEqualizeSpec then
      CMAIEqualizePower := K_CMAIEqualizeMin
  end; // with AutoImgProcAttrs do

end; // procedure TK_FormCMAutoImgProcAttrs0.SetAttrsByControlsState

//********************************* TK_FormCMAutoImgProcAttrs.ChBSharpClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBSharpClick(Sender: TObject);
begin
  TBSharpPower.Enabled := ChBSharp.Checked;
  LbEdSharpPower.Enabled := ChBSharp.Checked;
  TBSharpBound.Enabled := ChBSharp.Checked and not ChBSharpAuto.Checked;
  ChBSharpAuto.Enabled := ChBSharp.Checked;
  LbSharpPower.Enabled := ChBSharp.Checked;
  LbSharpBound.Enabled := ChBSharp.Checked;
end; // procedure TK_FormCMAutoImgProcAttrs0.ChBSharpClick

//******************************** TK_FormCMAutoImgProcAttrs.ChBSmoothClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBSmoothClick(Sender: TObject);
begin
  TBSmoothPower.Enabled := ChBSmooth.Checked;
  LbEdSmoothPower.Enabled := ChBSmooth.Checked;
  TBSmoothBound.Enabled := ChBSmooth.Checked and not ChBSmoothAuto.Checked;
  ChBSmoothAuto.Enabled := ChBSmooth.Checked;
  LbSmoothPower.Enabled := ChBSmooth.Checked;
  LbSmoothBound.Enabled := ChBSmooth.Checked;
end; // procedure TK_FormCMAutoImgProcAttrs0.ChBSmoothClick

//********************************* TK_FormCMAutoImgProcAttrs.ChBNoiseClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBNoiseClick(Sender: TObject);
begin
  TBNoisePower.Enabled := ChBNoise.Checked;
  LbEdNoisePower.Enabled := ChBNoise.Checked;
  LbNoisePower.Enabled := ChBNoise.Checked;
end; // procedure TK_FormCMAutoImgProcAttrs0.ChBNoiseClick

//******************************** TK_FormCMAutoImgProcAttrs.ChBMedianClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBMedianClick(Sender: TObject);
begin
  TBMedianBound.Enabled := ChBMedian.Checked and not ChBMedianAuto.Checked;
  ChBMedianAuto.Enabled := ChBMedian.Checked;
  LbMedianBound.Enabled := ChBMedian.Checked;
end; // procedure TK_FormCMAutoImgProcAttrs0.ChBMedianClick

//***************************** TK_FormCMAutoImgProcAttrs.ChBDespeckleClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBDespeckleClick(Sender: TObject);
begin
  TBDespeckleBound.Enabled := ChBDespeckle.Checked and not ChBDespeckleAuto.Checked;
  ChBDespeckleAuto.Enabled := ChBDespeckle.Checked;
  LbDespeckleBound.Enabled := ChBDespeckle.Checked;
end; // procedure TK_FormCMAutoImgProcAttrs0.ChBDespeckleClick

//*********************************** TK_FormCMAutoImgProcAttrs.ChBBriClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBBriClick(Sender: TObject);
begin
  BrightnessTrackBar.Enabled := ChBBri.Checked;
  EdBriVal.Enabled := ChBBri.Checked;
end; // procedure TK_FormCMAutoImgProcAttrs0.ChBBriClick

//************************************ TK_FormCMAutoImgProcAttrs.ChBCoClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBCoClick(Sender: TObject);
begin
  ContrastTrackBar.Enabled := ChBCo.Checked;
  EdCoVal.Enabled := ChBCo.Checked;
end; // procedure TK_FormCMAutoImgProcAttrs0.ChBCoClick

//*********************************** TK_FormCMAutoImgProcAttrs.ChBGamClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBGamClick(Sender: TObject);
begin
  GammaTrackBar.Enabled := ChBGam.Checked;
  EdGamVal.Enabled := ChBGam.Checked;
end; // procedure TK_FormCMAutoImgProcAttrs0.ChBGamClick

//********************************* TK_FormCMAutoImgProcAttrs.BtCancelClick ***
//
procedure TK_FormCMImgFilterProcAttrs.BtCancelClick(Sender: TObject);
begin
  if BtTestUndo.Enabled then
    BtTestUndoClick(Sender);
end; // procedure TK_FormCMAutoImgProcAttrs0.BtCancelClick

//************************************* TK_FormCMAutoImgProcAttrs.BtOKClick ***
//
procedure TK_FormCMImgFilterProcAttrs.BtOKClick(Sender: TObject);
//var
//  WKey: Word;

begin
//  WKey := VK_RETURN;
//  EdBriValKeyDown( Sender, WKey, [] );
//  LbEdSharpPowerKeyDown( Sender, WKey, [] );
end; // procedure TK_FormCMAutoImgProcAttrs0.BtOKClick

//******************************** TK_FormCMAutoImgProcAttrs.ChBNegateClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBNegateClick(Sender: TObject);
begin
  if not ChBBri.Checked then Exit;
  with AutoImgProcAttrs do begin
    CMAIPBriFactor := -CMAIPBriFactor;
    BrightnessTrackBar.Position := Round( LSFGamma.Func2Arg( CMAIPBriFactor ) );
    EdBriVal.Text := format( '%5.1f', [CMAIPBriFactor] );
  end;
end; // procedure TK_FormCMAutoImgProcAttrs0.ChBNegateClick

//********************************** TK_FormCMAutoImgProcAttrs.ChBLLLUClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBLLLUClick(Sender: TObject);
begin
  TBLL.Enabled := ChBLLLU.Checked and not ChBAutoLLLU.Checked;
  TBLU.Enabled := ChBLLLU.Checked and not ChBAutoLLLU.Checked;
  EdLLVal.Enabled := ChBLLLU.Checked and not ChBAutoLLLU.Checked;
  EdLUVal.Enabled := ChBLLLU.Checked and not ChBAutoLLLU.Checked;
  LbLL.Enabled := ChBLLLU.Checked and not ChBAutoLLLU.Checked;
  LbLU.Enabled := ChBLLLU.Checked and not ChBAutoLLLU.Checked;
  ChBAutoLLLU.Enabled := ChBLLLU.Checked;
  ChBAutoLLLUPower.Enabled := ChBLLLU.Checked and ChBAutoLLLU.Checked;
  TBAutoLLULPower.Enabled := ChBAutoLLLUPower.Enabled and ChBAutoLLLUPower.Checked;
  LbAutoLLULPower.Enabled := TBAutoLLULPower.Enabled;
  LbEdAutoLLULPower.Enabled := TBAutoLLULPower.Enabled;
end; // procedure TK_FormCMAutoImgProcAttrs0.ChBLLLUClick

//************************* TK_FormCMImgFilterProcAttrs.TBSmoothPowerChange ***
//
procedure TK_FormCMImgFilterProcAttrs.TBSmoothPowerChange(Sender: TObject);
begin
  PowerTrackBarChange( LbEdSmoothPower, TBSmoothPower, AutoImgProcAttrs.CMAISmoothPower );
end; // procedure TK_FormCMImgFilterProcAttrs.TBSmoothPowerChange

//************************** TK_FormCMImgFilterProcAttrs.TBSharpPowerChange ***
//
procedure TK_FormCMImgFilterProcAttrs.TBSharpPowerChange(Sender: TObject);
begin
  PowerTrackBarChange( LbEdSharpPower, TBSharpPower, AutoImgProcAttrs.CMAISharpPower );
end; // procedure TK_FormCMImgFilterProcAttrs.TBSharpPowerChange

//************************** TK_FormCMImgFilterProcAttrs.TBNoisePowerChange ***
//
procedure TK_FormCMImgFilterProcAttrs.TBNoisePowerChange(Sender: TObject);
begin
  PowerTrackBarChange( LbEdNoisePower, TBNoisePower, AutoImgProcAttrs.CMAINRThreshold1 );
end; // procedure TK_FormCMImgFilterProcAttrs.TBNoisePowerChange

//************************* TK_FormCMImgFilterProcAttrs.TBSmoothBoundChange ***
//
procedure TK_FormCMImgFilterProcAttrs.TBSmoothBoundChange(Sender: TObject);
begin
  BoundTrackBarChange( LbEdSmoothBound, TBSmoothBound, SharpSmoothDepthArray,
                       AutoImgProcAttrs.CMAISmoothDepth );
end; // procedure TK_FormCMImgFilterProcAttrs.TBSmoothBoundChange

//************************** TK_FormCMImgFilterProcAttrs.TBSharpBoundChange ***
//
procedure TK_FormCMImgFilterProcAttrs.TBSharpBoundChange(Sender: TObject);
begin
  BoundTrackBarChange( LbEdSharpBound, TBSharpBound, SharpSmoothDepthArray,
                       AutoImgProcAttrs.CMAISharpDepth );
end; // procedure TK_FormCMImgFilterProcAttrs.TBSharpBoundChange

//************************* TK_FormCMImgFilterProcAttrs.TBMedianBoundChange ***
//
procedure TK_FormCMImgFilterProcAttrs.TBMedianBoundChange(Sender: TObject);
begin
  BoundTrackBarChange( LbEdMedianBound, TBMedianBound, MedianDespeckleDepthArray,
                       AutoImgProcAttrs.CMAIMedianDepth );
end; // procedure TK_FormCMImgFilterProcAttrs.TBMedianBoundChange

//********************** TK_FormCMImgFilterProcAttrs.TBDespeckleBoundChange ***
//
procedure TK_FormCMImgFilterProcAttrs.TBDespeckleBoundChange( Sender: TObject);
begin
  BoundTrackBarChange( LbEdDespeckleBound, TBDespeckleBound, MedianDespeckleDepthArray,
                       AutoImgProcAttrs.CMAIDespeckleDepth );
end; // procedure TK_FormCMImgFilterProcAttrs.TBDespeckleBoundChange

//************************** TK_FormCMImgFilterProcAttrs.ChBSmoothAutoClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBSmoothAutoClick(Sender: TObject);
begin
  BoundAutoClick( ChBSmoothAuto, LbEdSmoothBound, TBSmoothBound,
                  AutoImgProcAttrs.CMAISmoothDepth, SharpSmoothDepthArray, 17 );
  if not ChBSmoothAuto.Checked then
    BoundTrackBarChange( LbEdSmoothBound, TBSmoothBound, SharpSmoothDepthArray,
                         AutoImgProcAttrs.CMAISmoothDepth );
end; // procedure TK_FormCMImgFilterProcAttrs.ChBSmoothAutoClick

//*************************** TK_FormCMImgFilterProcAttrs.ChBSharpAutoClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBSharpAutoClick(Sender: TObject);
begin
  BoundAutoClick( ChBSharpAuto, LbEdSharpBound, TBSharpBound,
                  AutoImgProcAttrs.CMAISharpDepth, SharpSmoothDepthArray, 17 );
  if not ChBSharpAuto.Checked then
    BoundTrackBarChange( LbEdSharpBound, TBSharpBound, SharpSmoothDepthArray,
                         AutoImgProcAttrs.CMAISharpDepth );
end; // procedure TK_FormCMImgFilterProcAttrs.ChBSharpAutoClick

//************************** TK_FormCMImgFilterProcAttrs.ChBMedianAutoClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBMedianAutoClick(Sender: TObject);
begin
  BoundAutoClick( ChBMedianAuto, LbEdMedianBound, TBMedianBound,
                  AutoImgProcAttrs.CMAIMedianDepth, MedianDespeckleDepthArray, 5 );
  if not ChBMedianAuto.Checked then
    BoundTrackBarChange( LbEdMedianBound, TBMedianBound, MedianDespeckleDepthArray,
                         AutoImgProcAttrs.CMAIMedianDepth );
end; // procedure TK_FormCMImgFilterProcAttrs.ChBMedianAutoClick

//*********************** TK_FormCMImgFilterProcAttrs.ChBDespeckleAutoClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBDespeckleAutoClick( Sender: TObject);
begin
  BoundAutoClick( ChBDespeckleAuto, LbEdDespeckleBound, TBDespeckleBound,
                  AutoImgProcAttrs.CMAIDespeckleDepth, MedianDespeckleDepthArray, 5 );
  if not ChBDespeckleAuto.Checked then
    BoundTrackBarChange( LbEdDespeckleBound, TBDespeckleBound, MedianDespeckleDepthArray,
                         AutoImgProcAttrs.CMAIDespeckleDepth );
end; // procedure TK_FormCMImgFilterProcAttrs.ChBDespeckleAutoClick

//************************* TK_FormCMImgFilterProcAttrs.PowerTrackBarChange ***
//
procedure TK_FormCMImgFilterProcAttrs.PowerTrackBarChange( ALbEdit: TLabeledEdit;
                                                           ATrackBar : TTrackBar;
                                                           var AValue : Float );
begin
  if not SkipRebuild then
    AValue := ATrackBar.Position / ATrackBar.Max;
  if not SkipTextRebuild then
    ALbEdit.Text := format( '%4.2f', [AValue] );
end; // procedure TK_FormCMImgFilterProcAttrs.PowerTrackBarChange

//************************* TK_FormCMImgFilterProcAttrs.BoundTrackBarChange ***
//
procedure TK_FormCMImgFilterProcAttrs.BoundTrackBarChange( ALbEdit: TLabeledEdit;
                                                           ATrackBar : TTrackBar;
                                                           ABoundArray : array of Integer;
                                                           var AValue : Integer );
begin
//  if not SkipRebuild then
    AValue := ABoundArray[ATrackBar.Position];
  if not SkipTextRebuild then
    ALbEdit.Text := format( '%2d', [AValue] );
end; // procedure TK_FormCMImgFilterProcAttrs.BoundTrackBarChange

//**************************** TK_FormCMImgFilterProcAttrs.PowerLbEdKeyDown ***
//
procedure TK_FormCMImgFilterProcAttrs.PowerLbEdKeyDown( AKey : word; ALbEdit: TLabeledEdit;
                           ATrackBar : TTrackBar; var AValue : Float );
var
  VConvFactor : Double;
begin
  if AKey <> VK_RETURN then Exit;
  SkipRebuild := TRUE;
  VConvFactor := AValue;
  VConvFactor := StrToFloatDef( Trim(ALbEdit.Text), VConvFactor);
  VConvFactor := Max(0, VConvFactor);
  VConvFactor := Min( 1, VConvFactor);
  AValue := VConvFactor;
  ATrackBar.Position := Round( ATrackBar.Max * VConvFactor );
  if VConvFactor = 0 then
    ALbEdit.Text := '  0.0';
  SkipRebuild := FALSE;
end; // procedure TK_FormCMImgFilterProcAttrs.PowerLbEdKeyDown

//****************************** TK_FormCMImgFilterProcAttrs.BoundAutoClick ***
//
procedure TK_FormCMImgFilterProcAttrs.BoundAutoClick( AChBAuto : TCheckBox;
                                ALbEdit: TLabeledEdit;
                                ATrackBar : TTrackBar;
                                var AValue : Integer;
                                ABoundArray : array of Integer;
                                ADefVal : Integer );
begin
  ATrackBar.Enabled := not AChBAuto.Checked;
  if not AChBAuto.Checked then
  begin
//    AValue := ADefVal;
//    ATrackBar.Position := K_IndexOfIntegerInRArray( ADefVal,
//                                        @ABoundArray[0], Length(ABoundArray) );
//    ALbEdit.Text := format( '%2d', [AValue] );
  end
  else
  begin
    ALbEdit.Text := '';
//    ATrackBar.Position := ATrackBar.Min;
    AValue := 0;
  end;
end; // procedure TK_FormCMImgFilterProcAttrs.BoundAutoClick

//********************** TK_FormCMImgFilterProcAttrs.LbEdSmoothPowerKeyDown ***
//
procedure TK_FormCMImgFilterProcAttrs.LbEdSmoothPowerKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  PowerLbEdKeyDown( Key, LbEdSmoothPower, TBSmoothPower, AutoImgProcAttrs.CMAISmoothPower );
end; // procedure TK_FormCMImgFilterProcAttrs.LbEdSmoothPowerKeyDown

//*********************** TK_FormCMImgFilterProcAttrs.LbEdNoisePowerKeyDown ***
//
procedure TK_FormCMImgFilterProcAttrs.LbEdNoisePowerKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  PowerLbEdKeyDown( Key, LbEdNoisePower, TBNoisePower, AutoImgProcAttrs.CMAINRThreshold1 );
end; // procedure TK_FormCMImgFilterProcAttrs.LbEdNoisePowerKeyDown


//**************************** TK_FormCMImgFilterProcAttrs.ChBEqualizeClick ***
//
procedure TK_FormCMImgFilterProcAttrs.ChBEqualizeClick(Sender: TObject);
begin
  TBEqualizePower.Enabled := ChBEqualize.Checked;
  LbEdEqualizePower.Enabled := ChBEqualize.Checked;
  LbEqualizePower.Enabled := ChBEqualize.Checked;
end; // procedure TK_FormCMImgFilterProcAttrs.ChBEqualizeClick

//************************* TK_FormCMAutoImgProcAttrs.TBEqualizePowerChange ***
//
procedure TK_FormCMImgFilterProcAttrs.TBEqualizePowerChange(Sender: TObject);
begin
  PowerTrackBarChange( LbEdEqualizePower, TBEqualizePower, AutoImgProcAttrs.CMAIEqualizePower );
end; // procedure TK_FormCMImgFilterProcAttrs.TBEqualizePowerChange

//********************** TK_FormCMAutoImgProcAttrs.LbEdEqualizePowerKeyDown ***
//
procedure TK_FormCMImgFilterProcAttrs.LbEdEqualizePowerKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  PowerLbEdKeyDown( Key, LbEdEqualizePower, TBEqualizePower, AutoImgProcAttrs.CMAIEqualizePower );
end; // procedure TK_FormCMImgFilterProcAttrs.LbEdEqualizePowerKeyDown

//************************* TK_FormCMAutoImgProcAttrs.TBAutoLLULPowerChange ***
//
procedure TK_FormCMImgFilterProcAttrs.TBAutoLLULPowerChange(
  Sender: TObject);
begin
  PowerTrackBarChange( LbEdAutoLLULPower, TBAutoLLULPower, AutoImgProcAttrs.CMAIAutoLLULPower );
end; // procedure TK_FormCMImgFilterProcAttrs.TBAutoLLULPowerChange

//********************** TK_FormCMAutoImgProcAttrs.LbEdAutoLLULPowerKeyDown ***
//
procedure TK_FormCMImgFilterProcAttrs.LbEdAutoLLULPowerKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  PowerLbEdKeyDown( Key, LbEdAutoLLULPower, TBAutoLLULPower, AutoImgProcAttrs.CMAIAutoLLULPower );
end; // procedure TK_FormCMImgFilterProcAttrs.LbEdAutoLLULPowerKeyDown

end.
