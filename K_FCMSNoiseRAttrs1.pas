unit K_FCMSNoiseRAttrs1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Comp2, N_Lib2, N_Types, N_Gra2,
  K_CM0, K_UDT1, K_CLib0;

type TK_FormCMSNoiseRAttrs1 = class(TN_BaseForm)
    Timer: TTimer;

    BtCancel: TButton;
    BtOK    : TButton;
    LbTimeInfo: TLabel;
    GBNR: TGroupBox;
    GB1: TGroupBox;
    LbAperture: TLabel;
    ChBMedianUse: TCheckBox;
    CmBMedianAperture: TComboBox;
    GroupBox5: TGroupBox;
    Label6: TLabel;
    Label8: TLabel;
    ChBNR1Use: TCheckBox;
    CmBNR1Aperture: TComboBox;
    TBNR1TS1: TTrackBar;
    EdNR1TS1: TEdit;
    GB2: TGroupBox;
    Label3: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    ChBNR2Use: TCheckBox;
    CmBNR2Aperture: TComboBox;
    TBNR2TS1: TTrackBar;
    EdNR2TS1: TEdit;
    TBNR2Sigma: TTrackBar;
    EdNR2Sigma: TEdit;
    GB3: TGroupBox;
    Label10: TLabel;
    Label12: TLabel;
    ChBNR3Use: TCheckBox;
    CmBNR3Aperture: TComboBox;
    TBNR3TS1: TTrackBar;
    EdNR3TS1: TEdit;
    GroupBox4: TGroupBox;
    Label2: TLabel;
    Label22: TLabel;
    Label27: TLabel;
    Label32: TLabel;
    Label11: TLabel;
    ChBNR0Use: TCheckBox;
    CmBNR0Aperture1: TComboBox;
    TBNR0TS1: TTrackBar;
    EdNR0TS1: TEdit;
    TBNR0TS2: TTrackBar;
    EdNR0TS2: TEdit;
    TBNR0Sigma: TTrackBar;
    EdNR0Sigma: TEdit;
    CmBNR0Aperture2: TComboBox;
    GBSharpening: TGroupBox;
    GBSharpen1: TGroupBox;
    Label15: TLabel;
    LbSH0Sigma: TLabel;
    Label16: TLabel;
    ChBSH0Use: TCheckBox;
    CmBSH0Method: TComboBox;
    CmBSH0Aperture: TComboBox;
    TBSH0Sigma: TTrackBar;
    EdSH0Sigma: TEdit;
    TBSH0TS1: TTrackBar;
    EdSH0TS1: TEdit;
    GBSharpen2: TGroupBox;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ChBSH1Use: TCheckBox;
    CmBSH1Aperture: TComboBox;
    TBSH1Sigma: TTrackBar;
    EdSH1Sigma: TEdit;
    TBSH1TS1: TTrackBar;
    EdSH1TS1: TEdit;
    Label13: TLabel;
    TBSH1TS2: TTrackBar;
    EdSH1TS2: TEdit;
    GBSharpen3: TGroupBox;
    ChBSH2Use: TCheckBox;
    TBSH2TS1: TTrackBar;
    EdSH2TS1: TEdit;
    Label14: TLabel;
    Label17: TLabel;
    TBSH2TS2: TTrackBar;
    EdSH2TS2: TEdit;

    procedure TimerTimer      ( Sender: TObject );
    procedure FormShow(Sender: TObject);
    procedure CmBMedianApertureChange(Sender: TObject);
    procedure ChBMedianUseClick(Sender: TObject);
    procedure TBNR0SigmaChange(Sender: TObject);
    procedure TBNR0TS1Change(Sender: TObject);
    procedure EdNR0TS1KeyPress(Sender: TObject; var Key: Char);
    procedure CmBSH0MethodChange(Sender: TObject);
    procedure FormActivate(Sender: TObject); override;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
  private
    DoOKAfter: Boolean;
    SkipRebuild : Boolean;
    LSFSigma : TK_LineSegmFunc;
    LSFThresh : TK_LineSegmFunc;

    IniBriMinFactor: Float; // Image Brightness Convertion Minimal Value
    IniBriMaxFactor: Float; // Image Brightness Convertion Maximal Value
    WVCAttrs: TK_CMSImgViewConvData;
    HistValues : TN_IArray;

    MedianWidth : Integer;

    NR0Width1 : Integer;
    NR0Width2 : Integer;
    NR0TS1    : Float;
    NR0TS2    : Float;
    NR0Sigma  : Float;
    NR0MeanMatr: TN_BArray;
    NR0DeltaMatr: TN_BArray;
    NR0Coefs1: TN_FArray;
    NR0Coefs2: TN_FArray;

    NR1Width  : Integer;
    NR1TS1    : Float;

    NR2Width  : Integer;
    NR2TS1    : Float;
    NR2Sigma  : Float;
    NR2Coefs1: TN_FArray;

    NR3Width  : Integer;
    NR3TS1    : Float;

    SH0Width  : Integer;
    SH0TS1    : Float;
    SH0Sigma  : Float;
    SH0Coefs1: TN_FArray;

    SH1Width  : Integer;
    SH1TS1    : Float;
    SH1TS2    : Float;
    SH1Sigma  : Float;
    SH1Coefs1: TN_FArray;
    SH1Coefs2: TN_FArray;
    SH1Coefs3: TN_FArray;

    SH2TS1    : Float;
    SH2TS2    : Float;
    SH2Coefs1: TN_FArray;

  public
    SavedDIB : TN_DIBObj;
    NewDIB   : TN_DIBObj;
    NewDIB1  : TN_DIBObj;
    EmbDIB1 : TN_DIBObj;

    FinishImageEditingCaption : string;

  end; // type TK_FormCMSNoiseRAttrs = class(TN_BaseForm)

var
  K_FormCMSNoiseRAttrs1: TK_FormCMSNoiseRAttrs1;

function K_CMSNoiseRedDlg1( ) : Boolean;

implementation

uses Math,
  N_Gra3, N_Lib0, N_CompBase, N_Lib1, N_CMMain5F, N_Gra6, N_CMREd3Fr, N_CMResF;

{$R *.dfm}

var CurCMMFActiveEdFrame: TN_CMREdit3Frame; // Active Editor Frame

//******************************************************** K_CMSNoiseRedDlg ***
// Create and Show Noise Reduction Form in modal mode,
// update Current Image if OK was pressed
//
function K_CMSNoiseRedDlg1( ) : Boolean;
begin
  with N_CM_MainForm, CMMFActiveEdFrame,
       TK_FormCMSNoiseRAttrs1.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    Color := clBtnFace;
    Result := ShowModal() = mrOK;

    with EdSlide.GetCurrentImage do begin
      if Result then begin
       // Set New DIB to Current Image
        DIBObj.Free;
        DIBObj := NewDIB;
      end else begin
       // Cancel Changes
        NewDIB.Free;
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( TRUE );
        EdSlide.RebuildMapImageByDIB( DIBObj, nil, @EmbDIB1 );
        RFrame.RedrawAllAndShow();
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( FALSE );
      end;
    end;

    NewDIB1.Free;
    EmbDIB1.Free;
    LSFSigma.Free;
    LSFThresh.Free;

  end; // with TK_FormCMSNoiseRAttrs.Create(Application), ...



end; // function K_CMSNoiseRedDlg

//**************************************** TK_FormCMSNoiseRAttrs.TimerTimer ***
// Calculate MeanMatr, DeltaMatr and call TBThresh1Change
//
// TTimer OnTimer handler.
// Timer is needed to show Self before all calculations will be finished
//
procedure TK_FormCMSNoiseRAttrs1.TimerTimer( Sender: TObject );
var
  SrcSM, DstSM: TN_SMatrDescr;
  WDIB : TN_DIBObj;
  MatrSize : Integer;
  i, ILL, IUL : Integer;
begin
  Timer.Enabled := FALSE;

  with N_CM_MainForm, CMMFActiveEdFrame do
  begin


    if NewDIB = nil then
    begin
      SavedDIB := EdSlide.GetCurrentImage.DIBObj;
      NewDIB  := TN_DIBObj.Create( SavedDIB );
      NewDIB1 := TN_DIBObj.Create( SavedDIB );
    end;
{
    WSigma := LSFSigma.Arg2Func( TBSigma.Position );
    with CmBDepth do
      WSharpDepth := StrToInt(Items[ItemIndex]);
    if (WSharpDepth <> NRDepth)  or
       (Abs(WSigma-NRSigma) > 0.01 ) or
       (CmBFilterType.ItemIndex = 0) then
    begin
      NRSigma := WSigma;
      NRDepth := WSharpDepth;
      CalcMeanDeltaMatr();
    end;
    EdSigmaVal.Text := format( '%6.2f', [NRSigma] );


    TBThresh1Change( Sender ); // Calc NewDIB by MeanMatr, DeltaMatr
}

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );

    LbTimeInfo.Caption := 'Please wait ...';
    LbTimeInfo.Refresh();

    SavedDIB.PrepSMatrDescr( @SrcSM );
    SavedDIB.PrepSMatrDescrByFlags( @DstSM, 0, @MatrSize );
    DstSM.SMDPBeg := NewDIB.PRasterBytes;

    N_T1.Start;

    if ChBMedianUse.Checked then
    begin
      N_Conv2SMMedianHuang( @SrcSM, @DstSM, MedianWidth );
      SrcSM.SMDPBeg := NewDIB.PRasterBytes;
      DstSM.SMDPBeg := NewDIB1.PRasterBytes;
    end;

    if ChBNR1Use.Checked then
    begin
      N_Conv2SMby2DCleaner( @SrcSM, @DstSM, NR1Width, NR1TS1 );
      if SrcSM.SMDPBeg = NewDIB.PRasterBytes then
      begin
        WDIB := NewDIB;
        NewDIB := NewDIB1;
        NewDIB1 := WDIB;
      end;
      SrcSM.SMDPBeg := NewDIB.PRasterBytes;
      DstSM.SMDPBeg := NewDIB1.PRasterBytes;
    end;

    if ChBNR2Use.Checked then
    begin
      N_CalcGaussMatr( NR2Coefs1, NR2Width, NR2Sigma );
      N_Conv2SMbyMatr2DCleaner( @SrcSM, @DstSM, @NR2Coefs1[0], NR2Width, NR2TS1 );
      if SrcSM.SMDPBeg = NewDIB.PRasterBytes then
      begin
        WDIB := NewDIB;
        NewDIB := NewDIB1;
        NewDIB1 := WDIB;
      end;
      SrcSM.SMDPBeg := NewDIB.PRasterBytes;
      DstSM.SMDPBeg := NewDIB1.PRasterBytes;
    end;

    if ChBNR3Use.Checked then
    begin
      N_Conv2SMbySpatialSmoother( @SrcSM, @DstSM, NR3Width, NR3TS1 );
      if SrcSM.SMDPBeg = NewDIB.PRasterBytes then
      begin
        WDIB := NewDIB;
        NewDIB := NewDIB1;
        NewDIB1 := WDIB;
      end;
      SrcSM.SMDPBeg := NewDIB.PRasterBytes;
      DstSM.SMDPBeg := NewDIB1.PRasterBytes;
    end;

    if ChBNR0Use.Checked then
    begin
      N_CalcGaussMatr( NR0Coefs1, NR0Width1, NR0Sigma, 1 );

      if Length(NR0MeanMatr) < MatrSize then
      begin
        SetLength(NR0MeanMatr, MatrSize);
        SetLength(NR0DeltaMatr, MatrSize);
      end;
      N_Conv3SMPrepNR1(@SrcSM, TN_BytesPtr(@NR0MeanMatr[0]),
          @NR0DeltaMatr[0], @NR0Coefs1[0], NR0Width1);

      N_CalcGaussMatr( NR0Coefs2, NR0Width2, NR0Sigma, 1 );
      N_Conv3SMDoNR1( @SrcSM, @DstSM,
                      @NR0MeanMatr[0],
                      @NR0DeltaMatr[0],
                      @NR0Coefs2[0], NR0Width2, NR0TS1, NR0TS2 );
      if SrcSM.SMDPBeg = NewDIB.PRasterBytes then
      begin
        WDIB := NewDIB;
        NewDIB := NewDIB1;
        NewDIB1 := WDIB;
      end;
      SrcSM.SMDPBeg := NewDIB.PRasterBytes;
      DstSM.SMDPBeg := NewDIB1.PRasterBytes;
    end;

    if ChBSH0Use.Checked then
    begin
//      N_Conv2SMbyMatr2DCleaner( @SrcSM, @DstSM, TN_BytesPtr(@NR2Coefs1[0]), NR2Width, NR2TS1 );
      case CmBSH0Method.ItemIndex of
      0: begin // Gauss
        N_CalcGaussVector( SH0Coefs1, SH0Width, SH0Sigma );
        N_Conv2SMbyVector( @SrcSM, @DstSM, @SH0Coefs1[0], SH0Width );
      end;
      1: begin // Average
        N_Conv2SMAverageFast1( @SrcSM, @DstSM, SH0Width shr 1, fbmNotFill )
      end;
      2: begin // Median
        N_Conv2SMMedianHuang( @SrcSM, @DstSM, SH0Width );
      end;
      end;
      N_Conv3SMLinComb( @SrcSM, DstSM.SMDPBeg, DstSM.SMDPBeg, - SH0TS1 * K_CMSharpenMax );
      if SrcSM.SMDPBeg = NewDIB.PRasterBytes then
      begin
        WDIB := NewDIB;
        NewDIB := NewDIB1;
        NewDIB1 := WDIB;
      end;
      SrcSM.SMDPBeg := NewDIB.PRasterBytes;
      DstSM.SMDPBeg := NewDIB1.PRasterBytes;
    end;

    if ChBSH1Use.Checked then
    begin
{}
      N_CalcGaussMatr( SH1Coefs1, SH1Width + 2, SH1Sigma );
      N_CalcLaplasMatr( SH1Coefs2,  SH1TS1 );
      N_ConvMatrByMatr( SH1Coefs3, SH1Coefs1, SH1Width + 2,
                        SH1Coefs2, 3 );
      N_Conv2SMbyMatrMinMax( @SrcSM, @DstSM, @SH1Coefs3[0], SH1Width, SH1TS2 );
//      K_Conv2SMbyMatrMinMax( @SrcSM, @DstSM, TN_BytesPtr(@SH1Coefs2[0]), 3, SH1TS2 );
      if SrcSM.SMDPBeg = NewDIB.PRasterBytes then
      begin
        WDIB := NewDIB;
        NewDIB := NewDIB1;
        NewDIB1 := WDIB;
      end;
      SrcSM.SMDPBeg := NewDIB.PRasterBytes;
      DstSM.SMDPBeg := NewDIB1.PRasterBytes;
{}
{
      K_CalcGaussMatr( SH1Coefs3, SH1Width, SH1Sigma );
      N_Conv2SMbyMatr( @SrcSM, @DstSM, TN_BytesPtr(@SH1Coefs3[0]), SH1Width );
      if SrcSM.SMDPBeg = NewDIB.PRasterBytes then
      begin
        WDIB := NewDIB;
        NewDIB := NewDIB1;
        NewDIB1 := WDIB;
      end;
      SrcSM.SMDPBeg := NewDIB.PRasterBytes;
      DstSM.SMDPBeg := NewDIB1.PRasterBytes;
{}
{
      K_CalcLaplasMatr( SH1Coefs2,  SH1TS1 );
      K_Conv2SMbyMatrMinMax( @SrcSM, @DstSM, TN_BytesPtr(@SH1Coefs2[0]), 3, SH1TS2 );
      if SrcSM.SMDPBeg = NewDIB.PRasterBytes then
      begin
        WDIB := NewDIB;
        NewDIB := NewDIB1;
        NewDIB1 := WDIB;
      end;
      SrcSM.SMDPBeg := NewDIB.PRasterBytes;
      DstSM.SMDPBeg := NewDIB1.PRasterBytes;
{}
    end;

    if ChBSH2Use.Checked then
    begin
      N_CalcLaplasMatr( SH2Coefs1,  SH2TS1 );
      N_Conv2SMbyMatrMinMax( @SrcSM, @DstSM, @SH2Coefs1[0], 3, SH2TS2 );
      if SrcSM.SMDPBeg = NewDIB.PRasterBytes then
      begin
        WDIB := NewDIB;
        NewDIB := NewDIB1;
        NewDIB1 := WDIB;
      end;
      SrcSM.SMDPBeg := NewDIB.PRasterBytes;
      DstSM.SMDPBeg := NewDIB1.PRasterBytes;
    end;

    N_T1.Stop;
    LbTimeInfo.Caption := 'Whole Time = ' + N_T1.ToStr( ) + #13#10 +
                     N_T1.ToStr( SavedDIB.DIBSize.X * SavedDIB.DIBSize.Y ) +
                            ' per pixel';
    WDIB := NewDIB;
    if SrcSM.SMDPBeg = SavedDIB.PRasterBytes then
    begin
      WDIB := SavedDIB;
       LbTimeInfo.Caption := '';
    end;
    LbTimeInfo.Refresh();

    WVCAttrs.VCBriMinFactor := IniBriMinFactor;
    WVCAttrs.VCBriMaxFactor := IniBriMaxFactor;
    if ChBSH1Use.Checked then
    begin
      WDIB.CalcBrighHistNData( HistValues );
      ILL := 0;
      IUL := High(HistValues);
      for i := 0 to High(HistValues) do
        if HistValues[i] <> 0 then
        begin
          ILL := i;
          break;
        end;

      for i := ILL + 1 to IUL do
        if HistValues[i] = 0 then
        begin
          IUL := i;
          break;
        end;
      WVCAttrs.VCBriMinFactor := ILL / High(HistValues) * 100;
      WVCAttrs.VCBriMaxFactor := IUL / High(HistValues) * 100;
    end;


    EdSlide.RebuildMapImageByDIB( WDIB, @WVCAttrs, @EmbDIB1 );
    RFrame.RedrawAllAndShow();

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( FALSE );

    CMMFRefreshActiveEdFrameHistogram( WDIB );
    SkipRebuild := FALSE;
  end;
//  bnTestClick( Sender ); // debug

end; // procedure TK_FormCMSNoiseRAttrs.TimerTimer


procedure TK_FormCMSNoiseRAttrs1.FormShow(Sender: TObject);
begin
  // Create LineSegmFunctions
  LSFSigma  := TK_LineSegmFunc.Create( [0, 0.1,  2500, 0.5,  5000, 1.5,  7500, 5,  10000, 20] );
//  LSFThresh := TK_LineSegmFunc.Create( [0, 1.1,  10000, 7] ); // same for TBThresh1,2
  LSFThresh := TK_LineSegmFunc.Create( [0, 0,  10000, 10] ); // same for TBThresh1,2

  SkipRebuild := TRUE;

  // Initialize Values

  CmBMedianAperture.ItemIndex := 0;
  CmBMedianApertureChange(CmBMedianAperture);
  CmBNR0Aperture1.ItemIndex := 1;
  CmBMedianApertureChange(CmBNR0Aperture1);
  CmBNR0Aperture2.ItemIndex := 1;
  CmBMedianApertureChange(CmBNR0Aperture2);
  CmBNR1Aperture.ItemIndex := 1;
  CmBMedianApertureChange(CmBNR1Aperture);
  CmBNR2Aperture.ItemIndex := 1;
  CmBMedianApertureChange(CmBNR2Aperture);
  CmBNR3Aperture.ItemIndex := 1;
  CmBMedianApertureChange(CmBNR3Aperture);
  CmBSH0Aperture.ItemIndex := 1;
  CmBMedianApertureChange(CmBSH0Aperture);
  CmBSH1Aperture.ItemIndex := 1;
  CmBMedianApertureChange(CmBSH1Aperture);

  NR0TS1 := 1.1;
  TBNR0TS1.Position := Round( LSFThresh.Func2Arg( NR0TS1 ) );

  NR0TS2 := 1.1;
  TBNR0TS2.Position := Round( LSFThresh.Func2Arg( NR0TS2 ) );

  NR0Sigma := 1.4;
  TBNR0Sigma.Position := Round( LSFSigma.Func2Arg( NR0Sigma ) );

  NR1TS1 := 0.2;
  TBNR1TS1.Position := Round( LSFThresh.Func2Arg( NR1TS1 ) );

  NR2TS1 := 0.2;
  TBNR2TS1.Position := Round( LSFThresh.Func2Arg( NR2TS1 ) );

  NR2Sigma := 1.4;
  TBNR2Sigma.Position := Round( LSFSigma.Func2Arg( NR2Sigma ) );

  NR3TS1 := 1.0;
  TBNR3TS1.Position := Round( LSFThresh.Func2Arg( NR3TS1 ) );

  SH0TS1 := 1.0;
  TBSH0TS1.Position := Round( LSFThresh.Func2Arg( SH0TS1 ) );

  SH0Sigma := 1.4;
  TBSH0Sigma.Position := Round( LSFSigma.Func2Arg( SH0Sigma ) );

  SH1TS1 := 1.0;
  TBSH1TS1.Position := Round( LSFThresh.Func2Arg( SH1TS1 ) );

  SH1TS2 := 0.5;
  TBSH1TS2.Position := Round( LSFThresh.Func2Arg( SH1TS2 ) );

  SH1Sigma := 1.4;
  TBSH1Sigma.Position := Round( LSFSigma.Func2Arg( SH1Sigma ) );

  SH2TS1 := 1.0;
  TBSH2TS1.Position := Round( LSFThresh.Func2Arg( SH2TS1 ) );

  SH2TS2 := 0.5;
  TBSH2TS2.Position := Round( LSFThresh.Func2Arg( SH2TS2 ) );

  CmBSH0Method.ItemIndex := 0;
//  CmBSH0MethodChange(CmBSH0Method);

  Timer.Enabled := TRUE;

  CurCMMFActiveEdFrame := N_CM_MainForm.CMMFActiveEdFrame;
  CurCMMFActiveEdFrame.EdSlide.GetImgViewConvData( @WVCAttrs );
  IniBriMinFactor := WVCAttrs.VCBriMinFactor;
  IniBriMaxFactor := WVCAttrs.VCBriMaxFactor;

end;

procedure TK_FormCMSNoiseRAttrs1.CmBMedianApertureChange(Sender: TObject);

  function GetApertureWidth( AInd : Integer ) : Integer;
  begin
    Result := 3;
    case AInd of
    1 : Result := 5;
    2 : Result := 7;
    3 : Result := 9;
    4 : Result := 11;
    5 : Result := 13;
    6 : Result := 17;
    7 : Result := 21;
    8 : Result := 29;
    9 : Result := 37;
   10 : Result := 51;
    end;
  end;
begin
  if Sender = CmBMedianAperture then
  begin
    MedianWidth := GetApertureWidth( CmBMedianAperture.ItemIndex );
  end
  else
  if Sender = CmBNR0Aperture1 then
  begin
    NR0Width1 := GetApertureWidth( CmBNR0Aperture1.ItemIndex );
  end else
  if Sender = CmBNR0Aperture2 then
  begin
    NR0Width2 := GetApertureWidth( CmBNR0Aperture2.ItemIndex );
  end else
  if Sender = CmBNR1Aperture then
  begin
    NR1Width := GetApertureWidth( CmBNR1Aperture.ItemIndex );
  end else
  if Sender = CmBNR2Aperture then
  begin
    NR2Width := GetApertureWidth( CmBNR2Aperture.ItemIndex );
  end else
  if Sender = CmBNR3Aperture then
  begin
    NR3Width := GetApertureWidth( CmBNR3Aperture.ItemIndex );
  end
  else
  if Sender = CmBSH0Aperture then
  begin
    SH0Width := GetApertureWidth( CmBSH0Aperture.ItemIndex );
  end
  else
  if Sender = CmBSH1Aperture then
  begin
    SH1Width := GetApertureWidth( CmBSH1Aperture.ItemIndex );
  end;

  if SkipRebuild then Exit;

  SkipRebuild := TRUE;
  Timer.Enabled := TRUE;

end;

procedure TK_FormCMSNoiseRAttrs1.ChBMedianUseClick(Sender: TObject);
begin
  if SkipRebuild then Exit;
  SkipRebuild := TRUE;
  Timer.Enabled := TRUE;
end;

procedure TK_FormCMSNoiseRAttrs1.TBNR0SigmaChange(Sender: TObject);
begin
  if (Sender = TBNR0Sigma) then
  begin
    NR0Sigma := LSFSigma.Arg2Func( TBNR0Sigma.Position );
    EdNR0Sigma.Text := format( '%6.2f', [NR0Sigma] );
  end
  else
  if (Sender = TBNR2Sigma) then
  begin
    NR2Sigma := LSFSigma.Arg2Func( TBNR2Sigma.Position );
    EdNR2Sigma.Text := format( '%6.2f', [NR2Sigma] );
  end
  else
  if (Sender = TBSH0Sigma) then
  begin
    SH0Sigma := LSFSigma.Arg2Func( TBSH0Sigma.Position );
    EdSH0Sigma.Text := format( '%6.2f', [SH0Sigma] );
  end
  else
  if (Sender = TBSH1Sigma) then
  begin
    SH1Sigma := LSFSigma.Arg2Func( TBSH1Sigma.Position );
    EdSH1Sigma.Text := format( '%6.2f', [SH1Sigma] );
  end;

  with N_CM_MainForm, CMMFActiveEdFrame do
    if SkipRebuild                          or
      (EdSlide.CMSShowWaitStateFlag and
      (csLButtonDown in TControl(Sender).ControlState)) then Exit;


  SkipRebuild := TRUE;
  Timer.Enabled := TRUE;
end;

procedure TK_FormCMSNoiseRAttrs1.TBNR0TS1Change(Sender: TObject);
begin
  if (Sender = TBNR0TS1) then
  begin
    NR0TS1 := LSFThresh.Arg2Func( TBNR0TS1.Position );
    EdNR0TS1.Text := format( '%6.2f', [NR0TS1] );
  end
  else
  if (Sender = TBNR0TS2) then
  begin
    NR0TS2 := LSFThresh.Arg2Func( TBNR0TS2.Position );
    EdNR0TS2.Text := format( '%6.2f', [NR0TS2] );
  end
  else
  if (Sender = TBNR1TS1) then
  begin
    NR1TS1 := LSFThresh.Arg2Func( TBNR1TS1.Position );
    EdNR1TS1.Text := format( '%6.2f', [NR1TS1] );
  end
  else
  if (Sender = TBNR2TS1) then
  begin
    NR2TS1 := LSFThresh.Arg2Func( TBNR2TS1.Position );
    EdNR2TS1.Text := format( '%6.2f', [NR2TS1] );
  end
  else
  if (Sender = TBNR3TS1) then
  begin
    NR3TS1 := LSFThresh.Arg2Func( TBNR3TS1.Position );
    EdNR3TS1.Text := format( '%6.2f', [NR3TS1] );
  end
  else
  if (Sender = TBSH0TS1) then
  begin
    SH0TS1 := LSFThresh.Arg2Func( TBSH0TS1.Position );
    EdSH0TS1.Text := format( '%6.2f', [SH0TS1] );
  end
  else
  if (Sender = TBSH1TS1) then
  begin
    SH1TS1 := LSFThresh.Arg2Func( TBSH1TS1.Position );
    EdSH1TS1.Text := format( '%6.2f', [SH1TS1] );
  end
  else
  if (Sender = TBSH1TS2) then
  begin
    SH1TS2 := LSFThresh.Arg2Func( TBSH1TS2.Position );
    EdSH1TS2.Text := format( '%6.2f', [SH1TS2] );
  end
  else
  if (Sender = TBSH2TS1) then
  begin
    SH2TS1 := LSFThresh.Arg2Func( TBSH2TS1.Position );
    EdSH2TS1.Text := format( '%6.2f', [SH2TS1] );
  end
  else
  if (Sender = TBSH2TS2) then
  begin
    SH2TS2 := LSFThresh.Arg2Func( TBSH2TS2.Position );
    EdSH2TS2.Text := format( '%6.2f', [SH2TS2] );
  end;


  with N_CM_MainForm, CMMFActiveEdFrame do
    if SkipRebuild                          or
      (EdSlide.CMSShowWaitStateFlag and
      (csLButtonDown in TControl(Sender).ControlState)) then Exit;


  SkipRebuild := TRUE;
  Timer.Enabled := TRUE;
end;

procedure TK_FormCMSNoiseRAttrs1.EdNR0TS1KeyPress(Sender: TObject;
  var Key: Char);
var
  W1 : Double;
begin
  if (Key <> Chr(VK_RETURN)) then Exit;

  if (Sender = EdNR0TS1) then
  begin
    W1 := StrToFloatDef( Trim(EdNR0TS1.Text), NR0TS1 );
    TBNR0TS1.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end
  else
  if (Sender = EdNR0TS2) then
  begin
    W1 := StrToFloatDef( Trim(EdNR0TS2.Text), NR0TS2 );
    TBNR0TS2.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end
  else
  if (Sender = EdNR1TS1) then
  begin
    W1 := StrToFloatDef( Trim(EdNR1TS1.Text), NR1TS1 );
    TBNR1TS1.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end
  else
  if (Sender = EdNR2TS1) then
  begin
    W1 := StrToFloatDef( Trim(EdNR2TS1.Text), NR2TS1 );
    TBNR2TS1.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end
  else
  if (Sender = EdNR3TS1) then
  begin
    W1 := StrToFloatDef( Trim(EdNR2TS1.Text), NR3TS1 );
    TBNR3TS1.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end
  else
  if (Sender = EdSH0TS1) then
  begin
    W1 := StrToFloatDef( Trim(EdSH0TS1.Text), SH0TS1 );
    TBSH0TS1.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end
  else
  if (Sender = EdSH0TS1) then
  begin
    W1 := StrToFloatDef( Trim(EdSH0TS1.Text), SH0TS1 );
    TBSH0TS1.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end
  else
  if (Sender = EdSH1TS1) then
  begin
    W1 := StrToFloatDef( Trim(EdSH1TS1.Text), SH1TS1 );
    TBSH1TS1.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end
  else
  if (Sender = EdSH1TS2) then
  begin
    W1 := StrToFloatDef( Trim(EdSH1TS2.Text), SH1TS2 );
    TBSH1TS2.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end
  else
  if (Sender = EdSH2TS1) then
  begin
    W1 := StrToFloatDef( Trim(EdSH2TS1.Text), SH2TS1 );
    TBSH2TS1.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end
  else
  if (Sender = EdSH2TS2) then
  begin
    W1 := StrToFloatDef( Trim(EdSH2TS2.Text), SH2TS2 );
    TBSH2TS2.Position := Round( LSFThresh.Func2Arg( W1 ) );
  end;

  if SkipRebuild then Exit;
  SkipRebuild := TRUE;
  Timer.Enabled := TRUE;

end;

procedure TK_FormCMSNoiseRAttrs1.CmBSH0MethodChange(Sender: TObject);
begin
  LbSH0Sigma.Enabled := CmBSH0Method.ItemIndex = 0;
  EdSH0Sigma.Enabled := LbSH0Sigma.Enabled;
  TBSH0Sigma.Enabled := LbSH0Sigma.Enabled;
  if SkipRebuild then Exit;
  SkipRebuild := TRUE;
  Timer.Enabled := TRUE;
end;

procedure TK_FormCMSNoiseRAttrs1.FormActivate(Sender: TObject);
var
  CanClose : Boolean;
begin
  inherited;
  if K_CMD4WAppFinState then
  begin
    CanClose := TRUE;
    FormCloseQuery( Sender, CanClose );
    Exit;
  end;
  N_CM_MainForm.CMMFSetActiveEdFrame(CurCMMFActiveEdFrame); // Switch to Form EdFrame
end;

procedure TK_FormCMSNoiseRAttrs1.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  ChangeData : Boolean;
begin
//  CanClose := not DoOKAfter;
  if not CanClose then Exit;
  ChangeData := ModalResult = mrOK;

  if not K_CMD4WAppFinState then
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    with EdSlide.GetCurrentImage do
    begin
      if ChangeData  then
      begin
       // Set New DIB to Current Image
        DIBObj.Free;
        DIBObj := NewDIB;
        with WVCAttrs, EdSlide.GetPMapRootAttrs()^ do
        begin
          if (VCBriMinFactor = 0) and (VCBriMaxFactor = 100) then
            VCBriMaxFactor := 0;
          if MRBriMinFactor <> VCBriMinFactor then
          begin
            MRBriMinFactor := VCBriMinFactor;
          end;
          if MRBriMaxFactor <> VCBriMaxFactor then
          begin
            MRBriMaxFactor := VCBriMaxFactor;
          end;
        end;
      end else
      begin
       // Cancel Changes
        NewDIB.Free;
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( TRUE );
        EdSlide.RebuildMapImageByDIB( DIBObj, nil, @EmbDIB1 );
        RFrame.RedrawAllAndShow();
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( FALSE );
      end;
    end;

    if not K_CMD4WAppFinState then
    begin
      if ChangeData then // Image was Changed
        CMMFFinishImageEditing( N_CMResForm.aToolsNoiseAttrs1.Caption, [cmssfMapRootChanged,cmssfCurImgChanged],
               K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                                Ord(K_shImgActSharpen) ) )
      else
      begin
        CMMFCancelImageEditing();
        CMMFRefreshActiveEdFrameHistogram( );
      end;
    // Enable CMS UI
      N_CM_MainForm.CMMSetUIEnabled( TRUE );
{
      K_CMD4WSkipCloseUI := FALSE;
      N_AppSkipEvents := FALSE;
      Exclude( CMMUICurStateFlags, uicsAllActsDisabled);
      CMMFDisableActions( Self );
}
    end;

  end // with N_CM_MainForm do
  else
    NewDIB.Free;

  NewDIB1.Free;
  EmbDIB1.Free;
  LSFSigma.Free;
  LSFThresh.Free;


  with N_CMResForm do
    AddCMSActionFinish( aToolsNoiseAttrs1 );


end;

procedure TK_FormCMSNoiseRAttrs1.BtOKClick(Sender: TObject);
begin
  DoOKAfter := TRUE;
  if not (fsModal in FormState) then
    Close();
end;

procedure TK_FormCMSNoiseRAttrs1.BtCancelClick(Sender: TObject);
begin
 if not (fsModal in FormState) then
    Close();
end;

end.
