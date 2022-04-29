unit K_FCMSSharpAttrs12;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Comp2, N_Lib2, N_Types, N_Gra2,
  K_CLib0, K_CM0, K_UDT1;

type
  TK_FormCMSSharpAttrs12 = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK    : TButton;
    TBVal: TTrackBar;
    BtApply: TButton;
    LbSharpen: TLabel;
    LbSmoothen: TLabel;
    Timer: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LbEdConvFactor: TLabeledEdit;
    LbRadius: TLabel;
    LbSigma: TLabel;
    cbRadius: TComboBox;
    TBSigma: TTrackBar;
    EdSigmaVal: TEdit;
    LbSVal1: TLabel;
    LbSVal3: TLabel;
    LbSVal5: TLabel;
    LbSVal4: TLabel;
    LbSVal2: TLabel;
    CmBSmoothType: TComboBox;
    StatusBar: TStatusBar;
    lbSmoothType: TLabel;
    bnSave: TButton;
    TBSV1: TTrackBar;
    LbEdSV1: TLabeledEdit;
    TBSV2: TTrackBar;
    LbEdSV2: TLabeledEdit;
    TBSD1: TTrackBar;
    LbEdSD1: TLabeledEdit;
    TBSD2: TTrackBar;
    LbEdSD2: TLabeledEdit;

    procedure FormShow       ( Sender: TObject );
    procedure FormCloseQuery ( Sender: TObject; var CanClose: Boolean );
    procedure TimerTimer     ( Sender: TObject );
    procedure TBValChange    ( Sender: TObject );
    procedure BtApplyClick   ( Sender: TObject );
    procedure bnSaveClick    ( Sender: TObject );
    procedure BtOKClick      ( Sender: TObject );
    procedure TBSigmaChange  ( Sender: TObject );
    procedure cbRadiusChange ( Sender: TObject );
    procedure EdSigmaValKeyPress     ( Sender: TObject; var Key: Char );
    procedure LbEdConvFactorKeyPress ( Sender: TObject; var Key: Char );
    procedure BtCancelClick(Sender: TObject);
    procedure FormActivate(Sender: TObject); override;

  private
    { Private declarations }
    SkipRebuild : Boolean;
    SkipApply   : Boolean;
    DoApplyAfter: Boolean;
    DoOKAfter: Boolean;
    ApplyOKWait: Boolean;
    StartEditing: Boolean;
    PrevValPosition : Integer;
    PrevSigmaPosition : Integer;
    PrevSmoothTypeIndex : Integer;

    procedure DIBObjCalcSmoothedMatr();

  public
    { Public declarations }
    SavedDIB : TN_DIBObj;
    NewDIB   : TN_DIBObj;
    EmbDIB1 : TN_DIBObj;
    SharpMatr: TN_BArray;
    SharpCoefs: TN_FArray;
    SharpCoefs2: TN_FArray;
    SharpRadius : Integer;
    VSigma : Double;
    LSFGamma : TK_LineSegmFunc;
    ResConvFactor : Double;
    TimeAsString: string;
  end;

var
  K_FormCMSSharpAttrs12: TK_FormCMSSharpAttrs12;

procedure N_TmpMedianCT     ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ACMDim: integer );
procedure N_TmpMedianSlow1  ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpAverageSlow1 ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpAverageSlow2 ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpEmptySlow1   ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpAverageFastV ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ACMDim: integer );
procedure N_TmpCopy1        ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpCopy2        ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpGaussFast1   ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; APCM: PFloat; ARadius: integer );

function  K_CMSSharpen12Dlg  ( ) : Boolean;
procedure K_CMSSharpen12NMDlg( );

implementation

uses Math,
  N_CompBase, N_Lib0, N_Lib1, N_CMMain5F, N_Gra6, N_CMResF, N_CMREd3Fr, N_Gra3,
  K_Gra0; //, N_Gra7;

{$R *.dfm}

var CurCMMFActiveEdFrame: TN_CMREdit3Frame; // Active Editor Frame


{
//********************************************************* N_Conv2SMbyMatr2 ***
// Convert (calculated weighted sum) given SubMatr by given Matrix of coefficients
// (two operands)
//
//     Parameters
// APSrcSM - Pointer to Source SubMatrix description
// APDstSM - Pointer to Destination SubMatrix description
// APCM    - Pointer to first element of Float coefficients Matrix
// ACMDim  - coefficients Matrix Dimension (usually 3 or 5)
//
// Both Src and Dst Submatrixes should have same description (except SMDPBeg),
// Any Element Size is OK.
// SMDEndIX(Y) should be >= SMDBegIX(Y)
//
//
procedure N_Conv2SMbyMatr2( APSrcSM, APDstSM: TN_PSMatrDescr; APCM: TN_BytesPtr; ACMDim: integer );
var
  ix, iy, jx, jy, kx, ky, CaseInd, HCMDIM, kxMax, kyMax, XBufStep: integer;
  PSrcElem, PDstElem, PCurSrcElem, PCurSrcRow, PXBufElem: TN_BytesPtr;
  CurCoef: Float;
  WS1, WS2, WS3, SCSUM: double;
  WVars: TN_ConvSMVars;
  XBuff1 : TN_FArray;
begin
  N_Prep2SMWVars( APSrcSM, APDstSM, @WVars ); // prpepare Working Variables

  CaseInd := APSrcSM^.SMDElSize - 1; // =0 - one byte, =1 - two bytes, =2 - 3,4 bytes
  if CaseInd = 3 then CaseInd := 2;

  HCMDIM := (ACMDim - 1) div 2; // Half of ACMDim, =1 for 3x3 CM, =2 for 5x5 CM
  kxMax := APSrcSM^.SMDNumX+HCMDIM-1; // kx > kxMax means out of whole Matr
  kyMax := APSrcSM^.SMDNumY+HCMDIM-1; // ky > kyMax means out of whole Matr

  with WVars do
  begin

  with APSrcSM^ do // shift WPSrcBegX to upper left by HCMDIM
    WPSrcBegX := WPSrcBegX - HCMDIM*SMDStepY;

//  N_Dump1Str(  'Start N_Conv2SMbyMatr' );
  XBufStep := APSrcSM^.SMDEndIX - APSrcSM^.SMDBegIX + 1; // Buffer Length
  if CaseInd = 2 then
  begin
  // Color Image
    SetLength( XBuff1, XBufStep * 3 );
    XBufStep := SizeOf(Float) * 3;
  end
  else
  begin
  // Grey Image
    SetLength( XBuff1, XBufStep );
    XBufStep := SizeOf(Float);
  end;
  for iy := APSrcSM^.SMDBegIY to APSrcSM^.SMDEndIY do // along all Src and Dst Rows
  begin
    PSrcElem := WPSrcBegX; // WPSrcBegX is shifted to upper left by HCMDIM relative to WPDstBegX
    PDstElem := WPDstBegX;
    PXBufElem := TN_BytesPtr(@XBuff1[0]);

    for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do // along all elems in cur Row
    begin
      WS1   := 0; // Weighted Sum to calculate (for single or first byte)
      WS2   := 0; // Weighted Sum to calculate (for second byte)
      WS3   := 0; // Weighted Sum to calculate (for third byte)
      SCSUM := 0; // Scipped Coefs. Sum
      PCurSrcRow := PSrcElem;

      case CaseInd of

      0: begin // One byte Element (both Src and Dst)
      for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
      begin
        CurCoef := PFloat( APCM + jy * SizeOf(Float) )^;
        ky := iy + jy;
        if (ky < HCMDIM) or (ky > kyMax) then // PCurSrcElem element is out of Matr
        begin
          SCSUM := SCSUM + CurCoef;
        end else // PCurSrcElem element is inside Matr
        begin
          WS1 := WS1 + PByte(PCurSrcRow)^*CurCoef;
        end;
        PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
      end; // // for jy := 0 to ACMDim-1 do
      PFloat(PXBufElem)^ := WS1/(1.0000001-SCSUM); // One byte XBuf Element
      end; // 0: begin

      1: begin // Two bytes Element (both Src and Dst)
      for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
      begin
        CurCoef := PFloat( APCM + jy*SizeOf(Float) )^;
        ky := iy + jy;
        if (ky < HCMDIM) or (ky > kyMax)   then // PCurSrcElem element is out of Matr
        begin
          SCSUM := SCSUM + CurCoef;
        end else // PCurSrcElem element is inside Matr
        begin
          WS1 := WS1 + PWord(PCurSrcRow)^*CurCoef;
        end;
        PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
      end; // // for jy := 0 to ACMDim-1 do
      PFloat(PXBufElem)^ := WS1/(1.0000001-SCSUM); // One word XBuf Element
      end; // 1: begin

      2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes
      for jy := 0 to ACMDim-1 do // along all Coefs. Matr Rows
      begin
        CurCoef := PFloat( APCM + jy*SizeOf(Float) )^;
        ky := iy + jy;
        if (ky < HCMDIM) or (ky > kyMax)   then // PCurSrcElem element is out of Matr
        begin
          SCSUM := SCSUM + CurCoef;
        end else // PCurSrcElem element is inside Matr
        begin
          WS1 := WS1 + PByte(PCurSrcRow+0)^*CurCoef;
          WS2 := WS2 + PByte(PCurSrcRow+1)^*CurCoef;
          WS3 := WS3 + PByte(PCurSrcRow+2)^*CurCoef;
        end;
        PCurSrcRow := PCurSrcRow + WSrcStepY; // to next Src Row
      end; // // for jy := 0 to ACMDim-1 do
      PFloat(PXBufElem+0*SizeOf(Float))^ := WS1/(1.0000001-SCSUM); // first  byte of XBuf Element
      PFloat(PXBufElem+1*SizeOf(Float))^ := WS2/(1.0000001-SCSUM); // second byte of XBuf Element
      PFloat(PXBufElem+2*SizeOf(Float))^ := WS3/(1.0000001-SCSUM); // third  byte of XBuf Element
      end; // 2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes

      end; // case CaseInd of

      PXBufElem := PXBufElem + XBufStep; // to next XBuf Element in Row
      PSrcElem := PSrcElem + WSrcStepX; // to next Src Element in Row
    end; // for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do

    PXBufElem := TN_BytesPtr(@XBuff1[0]) - HCMDIM*XBufStep;
    for ix := APSrcSM^.SMDBegIX to APSrcSM^.SMDEndIX do // along all elems in cur Row XBUF
    begin
      WS1   := 0; // Weighted Sum to calculate (for single or first byte)
      WS2   := 0; // Weighted Sum to calculate (for second byte)
      WS3   := 0; // Weighted Sum to calculate (for third byte)
      SCSUM := 0; // Scipped Coefs. Sum
      PCurSrcElem := PXBufElem;

      case CaseInd of

      0: begin // One byte Element (both Src and Dst)
      for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
      begin
       // get Coeff. value for PCurSrcElem Src Matr element
        CurCoef := PFloat( APCM + jx*SizeOf(Float) )^;
        kx := ix + jx; // real index + HCMDIM
        if (kx < HCMDIM) or (kx > kxMax)   then // PCurSrcElem element is out of Matr
        begin
          SCSUM := SCSUM + CurCoef;
        end else // PCurSrcElem element is inside Matr
        begin
          WS1 := WS1 + PFloat(PCurSrcElem)^*CurCoef;
        end;

        PCurSrcElem := PCurSrcElem + XBufStep; // to next XBuf Element in Row
      end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
      PByte(PDstElem)^ := Round( WS1/(1.0000001-SCSUM) ); // One byte Dst Element
      end; // 0: begin

      1: begin // Two bytes Element (both Src and Dst)
      for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
      begin
       // get Coeff. value for PCurSrcElem Src Matr element
        CurCoef := PFloat( APCM + jx*SizeOf(Float) )^;
        kx := ix + jx; // real index + HCMDIM
        if (kx < HCMDIM) or (kx > kxMax)   then // PCurSrcElem element is out of Matr
        begin
          SCSUM := SCSUM + CurCoef;
        end else // PCurSrcElem element is inside Matr
        begin
          WS1 := WS1 + PFloat(PCurSrcElem)^*CurCoef;
        end;

        PCurSrcElem := PCurSrcElem + XBufStep; // to next XBuf Element in Row
      end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
      PWord(PDstElem)^ := Round( WS1/(1.0000001-SCSUM) ); // One byte Dst Element
      end; // 1: begin

      2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes
      for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
      begin
       // get Coeff. value for PCurSrcElem Src Matr element
        CurCoef := PFloat( APCM + jx*SizeOf(Float) )^;
        kx := ix + jx; // real index + HCMDIM
        if (kx < HCMDIM) or (kx > kxMax)   then // PCurSrcElem element is out of Matr
        begin
          SCSUM := SCSUM + CurCoef;
        end else // PCurSrcElem element is inside Matr
        begin
          WS1 := WS1 + PFloat(PCurSrcElem+0*SizeOf(Float))^*CurCoef;
          WS2 := WS2 + PFloat(PCurSrcElem+1*SizeOf(Float))^*CurCoef;
          WS3 := WS3 + PFloat(PCurSrcElem+2*SizeOf(Float))^*CurCoef;
        end;

        PCurSrcElem := PCurSrcElem + XBufStep; // to next XBuf Element in Row
      end; // for jx := 0 to ACMDim-1 do // along all Coefs. Matr alems in jy-th Row
      PByte(PDstElem+0)^ := Round( WS1/(1.0000001-SCSUM) ); // first  byte of Dst Element
      PByte(PDstElem+1)^ := Round( WS2/(1.0000001-SCSUM) ); // second byte of Dst Element
      PByte(PDstElem+2)^ := Round( WS3/(1.0000001-SCSUM) ); // third  byte of Dst Element
      end; // 2: begin // Three or Four bytes Element (both Src and Dst), process each of 3 bytes

      end; // case CaseInd of

      PDstElem := PDstElem + WDstStepX; // to next Dst Element in Row
      PXBufElem := PXBufElem + XBufStep; // to next XBuf Element in Row
    end;

    WPSrcBegX := WPSrcBegX + WSrcStepY; // to next Src Row
    WPDstBegX := WPDstBegX + WDstStepY; // to next Dst Row
  end; // for iy := 0 to NY-1 do // along all Src and Dst Rows

  end; //with WVars do
end; // procedure N_Conv2SMbyMatr2
}

//*************************** TK_FormCMSSharpAttrs1 Event Handlers *****

procedure TK_FormCMSSharpAttrs12.FormShow( Sender: TObject );
begin
  SkipRebuild := TRUE;
  SkipApply := TRUE;
  StartEditing := TRUE;

  TBVal.Position := TBVal.Max shr 1;
  PrevValPosition := TBVal.Position;

  LSFGamma := TK_LineSegmFunc.Create( [0, 0.1,  2500, 0.5,  5000, 1.5,  7500, 5,  10000, 20 ] );
  VSigma := 1.4;
  TBSigma.Position := Round( LSFGamma.Func2Arg( VSigma ) );
  EdSigmaVal.Text := format( '%6.2f', [VSigma] );

  SharpRadius := 2;
  with cbRadius do
    ItemIndex := Items.IndexOf(IntToStr(SharpRadius));

  CmBSmoothType.ItemIndex := 0;
  PrevSmoothTypeIndex := -1;

  CurCMMFActiveEdFrame := N_CM_MainForm.CMMFActiveEdFrame;
{
  K_CalcGaussMatr( SharpCoefs, 5, 0.1 );
  K_CalcGaussMatr( SharpCoefs, 5, 0.2 );
  K_CalcGaussMatr( SharpCoefs, 5, 0.5 );
  K_CalcGaussMatr( SharpCoefs, 5, 0.75 );
  K_CalcGaussMatr( SharpCoefs, 5, 1 );
  K_CalcGaussMatr( SharpCoefs, 5, 1.5 );
  K_CalcGaussMatr( SharpCoefs, 5, 2 );
  K_CalcGaussMatr( SharpCoefs, 5, 2.5 );
  K_CalcGaussMatr( SharpCoefs, 5, 5 );
  K_CalcGaussMatr( SharpCoefs, 5, 10 );
{}
  Timer.Enabled := TRUE;
end; // procedure TK_FormCMSSharpAttrs1.FormShow

procedure TK_FormCMSSharpAttrs12.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
var
  ChangeData : Boolean;
begin
  CanClose := not DoOKAfter;
  if not CanClose then Exit;
  ChangeData := ModalResult = mrOK;

  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    with EdSlide.GetCurrentImage do begin
      if SavedDIB <> DIBObj then
        SavedDIB.Free;
      if ChangeData then begin
       // Set New DIB to Current Image
        DIBObj.Free;
        DIBObj := NewDIB;
      end else begin
       // Cancel Changes
        N_CM_MainForm.CMMCurFMainForm.Refresh();
        NewDIB.Free;
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( TRUE );
        EdSlide.RebuildMapImageByDIB( DIBObj, nil, @EmbDIB1 );
        RFrame.RedrawAllAndShow();
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( FALSE );
      end;
    end;
    EmbDIB1.Free;
    LSFGamma.Free;

    if ChangeData then // Image was Changed
      CMMFFinishImageEditing( N_CMResForm.aToolsSharpen12.Caption, [cmssfCurImgChanged],
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
    with N_CMResForm do
      AddCMSActionFinish( aToolsSharpen12 );

  end; // with N_CM_MainForm do

end; // procedure TK_FormCMSSharpAttrs12.FormCloseQuery

procedure TK_FormCMSSharpAttrs12.TimerTimer( Sender: TObject );
var
  Base : Integer;
  ConvFactor : Double;
  VConvFactor : Double;
  WSigma : Double;
  WSharpRadius : Integer;
  SMatrDescr: TN_SMatrDescr;
  SMatrDescr1: TN_SMatrDescr;
  SMatrDescrR: TN_SMatrDescr;
  SMPixComb : TK_SMPixComb;
begin
  Timer.Enabled := FALSE;
  TBSigma.Enabled := CmBSmoothType.ItemIndex = 0;
  EdSigmaVal.Enabled := CmBSmoothType.ItemIndex = 0;

  with N_CM_MainForm, CMMFActiveEdFrame do begin

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );

    if StartEditing then
    begin

      VConvFactor := 0;
      StartEditing := FALSE;
      SavedDIB := EdSlide.GetCurrentImage.DIBObj;

      NewDIB := TN_DIBObj.Create( SavedDIB );

      StatusBar.SimpleText := 'Please wait ...';
      PrevSmoothTypeIndex := CmBSmoothType.ItemIndex;

      if CmBSmoothType.ItemIndex <= 0 then
        N_CalcGaussMatr( SharpCoefs, 2*SharpRadius+1, VSigma );
      if CmBSmoothType.ItemIndex = 11 then
        N_CalcGaussVector( SharpCoefs2, 2*SharpRadius+1, VSigma );
      N_T1.Start;
      DIBObjCalcSmoothedMatr();
      N_T1.Stop;

      with SavedDIB do
        TimeAsString := '  ' + N_T1.ToStr( DIBSize.X * DIBSize.Y ) + ' per pixel';
      StatusBar.SimpleText := TimeAsString

    end
    else
    begin
      WSigma := LSFGamma.Arg2Func( TBSigma.Position );
      with cbRadius do
        WSharpRadius := StrToInt(Items[ItemIndex]);
      if (WSharpRadius <> SharpRadius)  or
         (Abs(WSigma-VSigma) > 0.01 ) or
         (PrevSmoothTypeIndex <> CmBSmoothType.ItemIndex) then
      begin
        PrevSmoothTypeIndex := CmBSmoothType.ItemIndex;
        VSigma := WSigma;
        SharpRadius := WSharpRadius;
        StatusBar.SimpleText := 'Please wait ...';

        if CmBSmoothType.ItemIndex <= 0 then
          N_CalcGaussMatr( SharpCoefs, 2*SharpRadius+1, VSigma );
        if CmBSmoothType.ItemIndex = 11 then
          N_CalcGaussVector( SharpCoefs2, 2*SharpRadius+1, VSigma );
        N_T1.Start;
        DIBObjCalcSmoothedMatr();
        N_T1.Stop;

        with SavedDIB do
          TimeAsString := '  ' + N_T1.ToStr( DIBSize.X * DIBSize.Y ) + ' per pixel';

        StatusBar.SimpleText := TimeAsString
      end;
      EdSigmaVal.Text := format( '%6.2f', [VSigma] );


      Base := TBVal.Max shr 1;
      ConvFactor := (TBVal.Position - Base) / Base;
      VConvFactor := ConvFactor * 100;

      if ConvFactor < 0 then
        ConvFactor := ConvFactor * K_CMSharpenMax;

      ResConvFactor := ConvFactor;

    //  Convert by Sharpen Filter
//      SavedDIB.CalcLinCombDIB( NewDIB, @SharpMatr[0], ConvFactor );
      with SavedDIB do
        PrepEDIBAndSMD( NewDIB, 0, @SMatrDescr, nil, DIBPixFmt, DIBExPixFmt );

//      N_Conv3SMLinComb( @SMatrDescr, @SharpMatr[0], NewDIB.PRasterBytes, ConvFactor );
{}
      SMatrDescr1 := SMatrDescr;
      SMatrDescr1.SMDPBeg := TN_BytesPtr(@SharpMatr[0]);
      SMatrDescrR := SMatrDescr;
      SMatrDescrR.SMDPBeg := TN_BytesPtr(NewDIB.PRasterBytes);


      SMPixComb := TK_SMPixComb.Create();
      with  SMPixComb do
      begin
        SMPSrcVMin1 := TBSV1.Position;
        SMPSrcVMax1 := TBSV2.Position;
        SMPSrcDMin := TBSD1.Position;
        SMPSrcDMax := TBSD2.Position;
        SMAlfa := ConvFactor;
        SMBeta := 1 - ConvFactor;
        SMPixFormat := SMatrDescr.SMDElSize - 1;
        N_Conv3SMProcObj ( @SMatrDescr, @SMatrDescr1, @SMatrDescrR, SMPixComb.SMComb1 );
        Free();
      end;
{}
    //  Rebuild Slide View
      with N_CM_MainForm.CMMFActiveEdFrame do
      begin
        EdSlide.RebuildMapImageByDIB( NewDIB, nil, @EmbDIB1 );
        RFrame.RedrawAllAndShow();
      end;
    end;

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( FALSE );
    N_CM_MainForm.CMMFRefreshActiveEdFrameHistogram( NewDIB );
  end;
//  Application.ProcessMessages; //??
  SkipRebuild := FALSE;
  SkipApply := FALSE;

  ApplyOKWait := FALSE;

  if DoApplyAfter then
  begin
    DoApplyAfter := FALSE;
    BtApplyClick(Sender);
  end;

  if DoOKAfter then
  begin
    DoOKAfter := FALSE;
    ModalResult := mrOK;
    if not (fsModal in FormState) then
      Close();
  end;

  LbEdConvFactor.Text := format( '%6.1f', [VConvFactor] );

end; // procedure TK_FormCMSSharpAttrs1.TimerTimer

procedure TK_FormCMSSharpAttrs12.TBValChange( Sender: TObject );
var
  Base : Integer;
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if (Sender <> nil) then
    begin
      Base := TBVal.Max shr 1;
      LbEdConvFactor.Text := format( '%6.1f', [(TBVal.Position - Base) / Base * 100] );

//      if SkipRebuild                      or
//         (PrevValPosition = TBVal.Position) then Exit;
      if SkipRebuild  then Exit;
    end;
    LbEdSV1.Text := format( '%3d', [TBSV1.Position]);
    LbEdSV2.Text := format( '%3d', [TBSV2.Position]);
    LbEdSD1.Text := format( '%3d', [TBSD1.Position]);
    LbEdSD2.Text := format( '%3d', [TBSD2.Position]);

    PrevValPosition := TBVal.Position;
    SkipRebuild := TRUE;
    Timer.Enabled := TRUE;
  end;
end; // procedure TK_FormCMSSharpAttrs1.TBValChange


procedure TK_FormCMSSharpAttrs12.BtApplyClick( Sender: TObject );
var
  VKR : Char;
begin
  cbRadiusChange( nil );
  Exit;

  if SkipApply then Exit;

  if not ApplyOKWait then
  begin
    VKR := Chr(VK_RETURN);
    LbEdConvFactorKeyPress( Sender, VKR );
  end;

  DoApplyAfter := ApplyOKWait;
  if DoApplyAfter then Exit;

  SkipApply := TRUE;
  if SavedDIB <> N_CM_MainForm.CMMFActiveEdFrame.EdSlide.GetCurrentImage.DIBObj then
    SavedDIB.Free;
  SavedDIB := NewDIB;
  NewDIB := nil;

  with N_CM_MainForm, CMMFActiveEdFrame do begin
//    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );

    SavedDIB.CalcXLATDIB( NewDIB, 0, nil, 0, SavedDIB.DIBPixFmt, SavedDIB.DIBExPixFmt );

    DIBObjCalcSmoothedMatr();
      CMMFShowHideWaitState( FALSE );
  end;

//  TBValChange(nil);
//  TBVal.Position := TBVal.Max shr 1;
//  PrevValPosition := TBVal.Position;
//??  Application.ProcessMessages;
  SkipApply := FALSE;
end; // procedure TK_FormCMSSharpAttrs1.BtApplyClick

procedure TK_FormCMSSharpAttrs12.bnSaveClick( Sender: TObject );
// Save current Image (after liner combination with smoothed image)
var
  FName: string;
begin
  FName := K_ExpandFileName( '(#OutFiles#)' + 'SmoothTest1.bmp' );

  if N_KeyIsDown( VK_SHIFT ) then // save current image in bmp format
  begin
    FName := N_CreateUniqueFileName( FName );
    NewDIB.SaveToBMPFormat( FName );
  end else // save current image in txt format
  begin
    N_SL.Clear;
    N_SL.Add( Format( '*** %s, ApRadius=%d, Coef=%.2f %s', [CmBSmoothType.Text,
                                     SharpRadius, ResConvFactor, TimeAsString] ) );
    NewDIB.RectToStrings( Rect(0,0,-1,-1), 0, FName, N_SL );
    FName := ChangeFileExt( FName, '.txt' );
    FName := N_CreateUniqueFileName( FName );
    N_SL.SaveToFile( FName );
  end;

  StatusBar.SimpleText := FName;
end; // procedure TK_FormCMSSharpAttrs1.bnSaveClick

procedure TK_FormCMSSharpAttrs12.BtOKClick( Sender: TObject );
var
  VKR : Char;
begin

  if not ApplyOKWait then
  begin
    VKR := Chr(VK_RETURN);
    LbEdConvFactorKeyPress( Sender, VKR );
  end;
  DoOKAfter := ApplyOKWait;
  if not (fsModal in FormState) then
    Close();
end; // procedure TK_FormCMSSharpAttrs1.BtOKClick

procedure TK_FormCMSSharpAttrs12.TBSigmaChange( Sender: TObject );
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if (Sender <> nil) then
    begin
      EdSigmaVal.Text := format( '%6.2f', [LSFGamma.Arg2Func( TBSigma.Position )] );
      if SkipRebuild                          or
         (PrevSigmaPosition = TBSigma.Position) or
         (EdSlide.CMSShowWaitStateFlag and
         (Sender = TBSigma)            and
         (csLButtonDown in TControl(Sender).ControlState)) then Exit;
    end;

    PrevSigmaPosition := TBSigma.Position;
    SkipRebuild := TRUE;
    Timer.Enabled := TRUE;
  end;
end; // procedure TK_FormCMSSharpAttrs1.TBSigmaChange

procedure TK_FormCMSSharpAttrs12.cbRadiusChange( Sender: TObject );
begin
  if (Sender <> nil) and SkipRebuild then Exit;

  SkipRebuild := TRUE;
  Timer.Enabled := TRUE;
end; // procedure TK_FormCMSSharpAttrs1.CmBDepthChange

procedure TK_FormCMSSharpAttrs12.EdSigmaValKeyPress( Sender: TObject; var Key: Char );
var
  WSigma : Double;
begin
  if (Key <> Chr(VK_RETURN)) or SkipRebuild  then Exit;
  SkipRebuild := TRUE;
  WSigma := StrToFloatDef( Trim(EdSigmaVal.Text), VSigma );
  TBSigma.Position := Round( LSFGamma.Func2Arg( WSigma ) );

  Timer.Enabled := TRUE;
end; // procedure TK_FormCMSSharpAttrs1.EdSigmaValKeyPress

procedure TK_FormCMSSharpAttrs12.LbEdConvFactorKeyPress( Sender: TObject; var Key: Char );
var
  VConvFactor : Double;
  NPos : Integer;
begin
  if Key <> Chr(VK_RETURN) then Exit;
  VConvFactor :=  200*( PrevValPosition  / TBVal.Max - 0.5 );
  VConvFactor := StrToFloatDef( Trim(LbEdConvFactor.Text), VConvFactor);
  VConvFactor := Max(-100, VConvFactor);
  VConvFactor := Min( 100, VConvFactor);
  LbEdConvFactor.Text := format( '%6.1f', [VConvFactor] );
  NPos := Round( TBVal.Max * (0.5 + VConvFactor / 200) );

  if NPos <> TBVal.Position then
  begin
    ApplyOKWait := TRUE;
    TBVal.Position := Round( TBVal.Max * (0.5 + VConvFactor / 200) );
  end;
end; // procedure TK_FormCMSSharpAttrs1.LbEdConvFactorKeyPress


//*************************** TK_FormCMSSharpAttrs1 Private methods *****

procedure TK_FormCMSSharpAttrs12.DIBObjCalcSmoothedMatr();
begin
  case CmBSmoothType.ItemIndex of
  0: SavedDIB.CalcSmoothedMatr( SharpMatr, @SharpCoefs[0], 2*SharpRadius+1 ); // Old Gauss
  1: N_ConvDIBToArrMedianHuang( SavedDIB, SharpMatr, SharpRadius ); // Median Huang
  2: N_TmpMedianCT( SavedDIB, SharpMatr, 2*SharpRadius+1 );    // Median CT
  3: N_TmpMedianSlow1( SavedDIB, SharpMatr, SharpRadius );     // Median Slow1
  4: N_TmpAverageSlow1( SavedDIB, SharpMatr, SharpRadius );    // Average Slow1
  5: N_TmpAverageSlow2( SavedDIB, SharpMatr, SharpRadius );    // Average Slow2
  6: N_TmpEmptySlow1( SavedDIB, SharpMatr, SharpRadius );      // Empty Slow1
  7: N_TmpAverageFastV( SavedDIB, SharpMatr, 2*SharpRadius+1); // Average FastV
  8: N_ConvDIBToArrAverageFast1( SavedDIB, SharpMatr, SharpRadius );    // Average FastN
  9: N_TmpCopy1( SavedDIB, SharpMatr, SharpRadius );           // Copy1
 10: N_TmpCopy2( SavedDIB, SharpMatr, SharpRadius );           // Copy2
 11: N_TmpGaussFast1( SavedDIB, SharpMatr, @SharpCoefs2[0], SharpRadius );

  else // Empty Slow1, a precaution
    N_TmpEmptySlow1( SavedDIB, SharpMatr, SharpRadius );
  end;
end; // procedure TK_FormCMSSharpAttrs1.DIBObjCalcSmoothedMatr


procedure N_TmpGaussFast1( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; APCM: PFloat; ARadius: integer );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ARadius := 2*ARadius + 1;
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMbyVector( @SrcSM, @DstSM, APCM, ARadius );
end; // procedure procedure N_TmpGaussFast1

procedure N_TmpMedianCT( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ACMDim: integer );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMMedianCT( @SrcSM, @DstSM, ACMDim );
end; // procedure procedure N_TmpMedianCT

procedure N_TmpMedianSlow1( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

//  N_Conv2SMMedianSort1( @SrcSM, @DstSM, ACMDim );
  N_Conv2SMSlow1(  @SrcSM, @DstSM, ARadius, fbmZero, 0, 1 );
end; // procedure procedure N_TmpMedianSlow1

procedure N_TmpAverageSlow1( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMSlow1(  @SrcSM, @DstSM, ARadius, fbmNotFill, 0, 0 );
end; // procedure procedure N_TmpAverageSlow1

procedure N_TmpAverageSlow2( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMSlow2(  @SrcSM, @DstSM, ARadius, fbmNotFill, 0, 0 );
end; // procedure procedure N_TmpEmptySlow2

procedure N_TmpEmptySlow1( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMSlow2(  @SrcSM, @DstSM, ARadius, fbmZero, 0, 2 );
end; // procedure procedure N_TmpEmptySlow1

procedure N_TmpAverageFastV( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ACMDim: integer );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

//  N_Conv2SMbyMatr2( @SrcSM, @DstSM, ACMDim );
end; // procedure procedure N_TmpAverageFastV

procedure N_TmpCopy1( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMCopy( @SrcSM, @DstSM, 0 );
end; // procedure procedure N_TmpCopy1

procedure N_TmpCopy2( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMCopy( @SrcSM, @DstSM, 0 );
end; // procedure procedure N_TmpCopy2

function K_CMSSharpen12Dlg( ): Boolean;
begin
  with N_CM_MainForm, CMMFActiveEdFrame,
      TK_FormCMSSharpAttrs12.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    Result := ShowModal() = mrOK;
{
    with EdSlide.GetCurrentImage do begin
      if SavedDIB <> DIBObj then
        SavedDIB.Free;
      if Result then begin
       // Set New DIB to Current Image
        DIBObj.Free;
        DIBObj := NewDIB;
      end else begin
       // Cancel Changes
        N_CM_MainForm.CMMCurFMainForm.Refresh();
        NewDIB.Free;
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( TRUE );
        EdSlide.RebuildMapImageByDIB( DIBObj, nil, @EmbDIB1, @EmbDIB2 );
        RFrame.RedrawAllAndShow();
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( FALSE );
      end;
    end;
    EmbDIB1.Free;
    EmbDIB2.Free;
    LSFGamma.Free;
}
  end;
end; // function K_CMSSharpen1Dlg

procedure K_CMSSharpen12NMDlg( );
begin
  with N_CM_MainForm, CMMFActiveEdFrame,
      TK_FormCMSSharpAttrs12.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    Show();
  end;
end; // function K_CMSSharpen1Dlg

procedure TK_FormCMSSharpAttrs12.BtCancelClick(Sender: TObject);
begin
  inherited;
  if not (fsModal in FormState) then
    Close();
end;

procedure TK_FormCMSSharpAttrs12.FormActivate(Sender: TObject);
begin
  inherited;
  N_CM_MainForm.CMMFSetActiveEdFrame(CurCMMFActiveEdFrame); // Switch to Form EdFrame
end;

end.
