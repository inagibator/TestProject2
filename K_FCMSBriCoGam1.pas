unit K_FCMSBriCoGam1;
// Brightness, Contrast, Gamm Editor Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_Types, N_BaseF, N_Gra2,
  K_CLib0, K_CM0, N_BrigHistFr;

type
  TK_FormCMSBriCoGam1 = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK    : TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    TBBrightness: TTrackBar;
    TBGamma: TTrackBar;
    TBContrast: TTrackBar;
    bnReset: TButton;
    EdBriVal: TEdit;
    EdCoVal: TEdit;
    EdGamVal: TEdit;
    LbLL: TLabel;
    TBLL: TTrackBar;
    EdLLVal: TEdit;
    LbLU: TLabel;
    TBLU: TTrackBar;
    EdLUVal: TEdit;
    ChBSyncLLUL: TCheckBox;
    BCGHistFrame: TN_BrigHistFrame;
    ChBAutoLLLU: TCheckBox;
    ChBAutoLLLUPower: TCheckBox;
    LbAutoLLULPower: TLabel;
    TBAutoLLULPower: TTrackBar;
    LbEdAutoLLULPower: TLabeledEdit;
    procedure TBValChange     ( Sender: TObject);
    procedure FormShow        ( Sender: TObject);
    procedure FormCloseQuery  ( Sender: TObject; var CanClose: Boolean );
    procedure bnResetClick    ( Sender: TObject);
    procedure EdBriValEnter   ( Sender: TObject);
    procedure EdBriValKeyDown ( Sender: TObject; var Key: Word;
                                Shift: TShiftState );
    procedure HistFrameResize(Sender: TObject);
    procedure ChBAutoLLLUClick(Sender: TObject);
  private
    { Private declarations }
    WVCAttrs: TK_CMSImgViewConvData;
    SkipRebuild : Boolean;
    PrevPosition : Integer;
    PrevTrackBar : TObject;
    PrevLLPosition : Integer;
    PrevLUPosition : Integer;
    AutoPower : Double;
    CurMinFactor, CurMaxFactor : Float;
    RemainingRedrawMode : Integer;

    procedure TrackBarChangeRedraw();

  public
    { Public declarations }
    EmbDIB1 : TN_DIBObj;
    LSFGamma : TK_LineSegmFunc;
    LSFGamma1: TK_LineSegmFunc;
    XLatBCG : TN_IArray;
    XNegateBCG : TN_IArray;
  end;

var
  K_FormCMSBriCoGam1: TK_FormCMSBriCoGam1;

function K_CMSBriCoGam1Dlg( ) : Boolean;

implementation

uses Math,
     K_VFunc,
     N_Lib0, N_Lib2, N_CMMain5F, N_CM1, N_BrigHist2F, N_Gra3;

{$R *.dfm}

//***************************************** K_CMSBriCoGam1Dlg ***
//  Change Brightnes/Contrast/Gamma Dialog
//
function K_CMSBriCoGam1Dlg( ) : Boolean;
var
  WasChanged : Boolean;
begin

  with N_CM_MainForm, CMMFActiveEdFrame,
                      TK_FormCMSBriCoGam1.Create(Application) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    SetLength( XLatBCG, 256 );

    Result := ShowModal() = mrOK;

    if Result then
    begin
      WasChanged := FALSE;
      with WVCAttrs, EdSlide.GetPMapRootAttrs()^ do
      begin
        if MRCoFactor <> VCCoFactor then
        begin
          MRCoFactor := VCCoFactor;
          WasChanged := TRUE;
        end;
        if MRGamFactor <> VCGamFactor then
        begin
          MRGamFactor := VCGamFactor;
          WasChanged := TRUE;
        end;
        if MRBriFactor <> VCBriFactor then
        begin
          MRBriFactor := VCBriFactor;
          WasChanged := TRUE;
        end;
        if (VCBriMinFactor = 0) and (VCBriMaxFactor = 100) then
          VCBriMaxFactor := 0;
        if MRBriMinFactor <> VCBriMinFactor then
        begin
          MRBriMinFactor := VCBriMinFactor;
          WasChanged := TRUE;
        end;
        if MRBriMaxFactor <> VCBriMaxFactor then
        begin
          MRBriMaxFactor := VCBriMaxFactor;
          WasChanged := TRUE;
        end;
      end;
      Result := WasChanged;
    end
    else
    begin
     // Cancel Changes
      N_Dump2Str( 'Cancel BriCoGam Changes' );
//      if EdSlide.CMSShowWaitStateFlag then
//        CMMFShowHideWaitState( TRUE );
      EdSlide.RebuildMapImageByDIB( nil, nil, @EmbDIB1 );
      RFrame.RedrawAllAndShow();
//      if EdSlide.CMSShowWaitStateFlag then
//        CMMFShowHideWaitState( FALSE );
      if N_BrigHist2Form <> nil then
        N_BrigHist2Form.SetXLATtoConv( K_GetPIArray0(EdSlide.CMSXLatBCGHist) );
    end;


    BCGHistFrame.LabelsNFont.Free;
    BCGHistFrame.RFrame.RFFreeObjects();

    LSFGamma.Free;
    LSFGamma1.Free;
    EmbDIB1.Free;
  end; // with N_CM_MainForm, CMMFActiveEdFrame, ...

end; // function K_CMSBriCoGam1Dlg

//***************************************** TK_FormCMSBriCoGam1.TBValChange ***
//  On Track Bar value change Handler
//
procedure TK_FormCMSBriCoGam1.TBValChange(Sender: TObject);
var
  ID : Integer;
{//!!++}  SlideDIB : TN_DIBObj; // Temporary closed
const
  LL_LU_Delta = 4;
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
{
    if SkipRebuild or
       ((PrevTrackBar = Sender) and (PrevPosition = TTrackBar(Sender).Position)) or
       (EdSlide.CMSShowWaitStateFlag and
        (Sender is TTrackBar)        and
        (csLButtonDown in TControl(Sender).ControlState)) then Exit;
}

    if SkipRebuild or
       ((PrevTrackBar = Sender) and
        (PrevPosition = TTrackBar(Sender).Position)) then Exit;

    SkipRebuild := TRUE;
    if ChBSyncLLUL.Checked   and
       (PrevLLPosition >= 0) and
       (PrevLUPosition >= 0) then
    begin
      if Sender = TBLL then
      begin
        ID := TBLL.Position - PrevLLPosition;
        if TBLU.Position + ID > 1000 then
        begin
          TBLL.Position := TBLL.Position - TBLU.Position - ID + 1000;
          ID := 1000 - TBLU.Position;
        end;
        TBLU.Position := TBLU.Position + ID;
      end;
      if Sender = TBLU then
      begin
        ID := TBLU.Position - PrevLUPosition;
        if TBLL.Position + ID < 0 then
        begin
          TBLU.Position := TBLU.Position - TBLL.Position - ID;
          ID := -TBLL.Position;
        end;
        TBLL.Position := TBLL.Position + ID;
      end;
    end;

    if TBLL.Position >= TBLU.Position - LL_LU_Delta then
    begin
      if (Sender = TBLL) or (PrevLLPosition <> TBLL.Position) then
        TBLL.Position := Max( 0, TBLU.Position - LL_LU_Delta )
      else
        TBLU.Position := Min( 1000, TBLL.Position + LL_LU_Delta );
    end;

    if Sender is TTrackBar then
    begin
      PrevTrackBar := Sender;
      PrevPosition := TTrackBar(Sender).Position;
    end;

    PrevLLPosition := TBLL.Position;
    PrevLUPosition := TBLU.Position;


    with WVCAttrs do
    begin
      VCBriFactor    := LSFGamma.Arg2Func( TBBrightness.Position );
      VCGamFactor    := LSFGamma.Arg2Func( TBGamma.Position );
      VCCoFactor     := LSFGamma.Arg2Func( TBContrast.Position );
      CurMinFactor := LSFGamma1.Arg2Func( TBLL.Position );
      CurMaxFactor := LSFGamma1.Arg2Func( TBLU.Position );

      EdBriVal.Text := format( '%5.1f', [Round(VCBriFactor*10)/10] );
      EdCoVal.Text  := format( '%5.1f', [Round(VCCoFactor*10)/10] );
      EdGamVal.Text := format( '%5.1f', [Round(VCGamFactor*10)/10] );
      EdLLVal.Text  := format( '%5.1f', [Round(CurMinFactor*10)/10] );
      EdLUVal.Text  := format( '%5.1f', [Round(CurMaxFactor*10)/10] );


      LbEdAutoLLULPower.Text := format( '%4.2f', [TBAutoLLULPower.Position/TBAutoLLULPower.Max] );

      VCBriMinFactor := CurMinFactor;
      VCBriMaxFactor := CurMaxFactor;
      if VCNegateFlag then
      begin
        VCBriMinFactor := 100 - CurMaxFactor;
        VCBriMaxFactor := 100 - CurMinFactor;
      end;

// Skip Negate for XLAT curve
//      N_BCGImageXlatBuild( XLatBCG, 255, VCCoFactor, VCBriFactor, VCGamFactor,
//                           VCBriMinFactor, VCBriMaxFactor, FALSE );
      N_BCGImageXlatBuild( XLatBCG, 255, VCCoFactor, VCBriFactor, VCGamFactor,
                           CurMinFactor, CurMaxFactor, FALSE );
//      N_BCGImageXlatBuild( XLatBCG, 255, VCCoFactor, VCBriFactor, VCGamFactor,
//                           VCBriMinFactor, VCBriMaxFactor, VCNegateFlag );
    end; // with WVCAttrs do begin

    TBLL.SelStart := TBLL.Position;
    TBLL.SelEnd   := TBLU.Position;
    TBLU.SelStart := TBLL.Position;
    TBLU.SelEnd   := TBLU.Position;

//    if EdSlide.CMSShowWaitStateFlag then
//      CMMFShowHideWaitState( TRUE );

    if (K_CMSkipMouseMoveRedraw = 0) or
       (RemainingRedrawMode = 0) then
      TrackBarChangeRedraw()
    else
    begin
      K_CMRedrawObject.Redraw();
      if K_CMSkipMouseMoveRedraw <= 1 then
      begin // Redraw Self Histogram only
        RemainingRedrawMode := 2;
        TrackBarChangeRedraw();
        RemainingRedrawMode := 1;
      end;
    end;

    SkipRebuild := FALSE;

    Exit;

    EdSlide.RebuildMapImageByDIB( nil, @WVCAttrs, @EmbDIB1 );
    RFrame.RedrawAllAndShow();

    if N_BrigHist2Form <> nil then
      N_BrigHist2Form.SetXLATtoConv( @EdSlide.CMSXLatBCGHist[0] );
//      N_BrigHist2Form.SetXLATtoConv( @XLatBCG[0] );

//    if EdSlide.CMSShowWaitStateFlag then
//      CMMFShowHideWaitState( FALSE );


    with BCGHistFrame do
    begin
      SlideDIB := EdSlide.GetCurrentImage().DIBObj;
      if BHFSrcDIB <> SlideDIB then
        BHFrameSetDIBObj( SlideDIB );

      //***** XLatBCG, CurMinBri, CurMaxBri are all 8 bit values

      BHFPXLAT8toDraw := @XLatBCG[0];
//      CurMinBri  := Round( High(XLatBCG)* WVCAttrs.VCBriMinFactor / 100 );
      CurMinBri  := Round( High(XLatBCG)* CurMinFactor / 100 );
      CurMinBri8 := CurMinBri;
//      CurMaxBri  := Round( High(XLatBCG)* WVCAttrs.VCBriMaxFactor / 100 );
      CurMaxBri  := Round( High(XLatBCG)* CurMaxFactor / 100 );
      CurMaxBri8 := CurMaxBri;

      CalcPolygons( -1 ); // Calc all polygons coords
      RedrawRFrame();
    end;
  end;

  SkipRebuild := FALSE;
end; // procedure TK_FormCMSBriCoGam1.TBValChange

//***************************************** TK_FormCMSBriCoGam1.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMSBriCoGam1.FormShow(Sender: TObject);
begin
  LSFGamma  := TK_LineSegmFunc.Create( [0, -100,  1000, -60,  2500, -20,  7500, 20,  9000, 60,  10000, 100 ] );
  LSFGamma1 := TK_LineSegmFunc.Create( [0, 0,  1000, 100 ] );

  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    PrevTrackBar := nil;
    PrevPosition := -1;
    PrevLLPosition := -1;
    PrevLUPosition := -1;

//   BCGHistFrame.Visible := cmsfGreyScale in EdSlide.P.CMSDB.SFlags;

    EdSlide.GetImgViewConvData( @WVCAttrs );

    SkipRebuild := TRUE;

    with WVCAttrs do
    begin
      TBBrightness.Position := Round( LSFGamma.Func2Arg( VCBriFactor ) );
      TBGamma.Position      := Round( LSFGamma.Func2Arg( VCGamFactor ) );
      TBContrast.Position   := Round( LSFGamma.Func2Arg( VCCoFactor ) );

      CurMinFactor := VCBriMinFactor;
      CurMaxFactor := VCBriMaxFactor;
      if VCNegateFlag then
      begin
        CurMinFactor := 100 - VCBriMaxFactor;
        CurMaxFactor := 100 - VCBriMinFactor;
        // Preare XLAT to "negate" Histogram
        SetLength( XNegateBCG, 256 );
        with EdSlide.GetPMapRootAttrs()^ do
          N_BCGImageXlatBuild( XNegateBCG, 255, 0, 0, 0, 0, 100, TRUE );
      end;

      TBLL.Position := Round( LSFGamma1.Func2Arg( CurMinFactor ) );
      TBLU.Position := Round( LSFGamma1.Func2Arg( CurMaxFactor ) );

      if (TBLU.Position = 0) and (TBLL.Position = 0) then
        TBLU.Position := 1000
      else
      if (TBLU.Position = 1000) and (TBLL.Position = 1000) then
        TBLL.Position := 0;

      TBLL.SelStart := TBLL.Position;
      TBLL.SelEnd   := TBLU.Position;
      TBLU.SelStart := TBLL.Position;
      TBLU.SelEnd   := TBLU.Position;


    end; // with WVCAttrs do

    SkipRebuild := FALSE;
  end; // with N_CM_MainForm, CMMFActiveEdFrame do

  with BCGHistFrame do //***** Init BCGHistFrame
  begin
    if Length(XNegateBCG) > 0 then
    begin
      BHFPXLAT8toConv := @XNegateBCG[0];
      PrepXLATHist8Values();
   end
   else
     BHFPXLAT8toConv   := nil;

    HistPolygonSize   := 0;
    BRangePolygonSize := 0;
    YAxisUnits := yauNone;

    DxLeft      := 4;
    DxRight     := 3;
    DyBottom    := 18;
    DyGrad      := 5;
    DyGradHist  := 4;
    DyTop       := 3;

    DyTicks     := 4;
    DyLabels    := 6;
    DxTicks     := 4;
    DxLabels    := 6;

    SetLength( BRDWidths, 256 );
    SetLength( BRWidths,  256 );
    SetLength( BRLefts,   256 );

    CurBri    := -1; // not given
    CurMinBri := -1;
    CurMaxBri := -1;

    BackColor      := ColorToRGB( clBtnFace );
    HistColor      := $888888;
    RangeMainColor := $444444;
    RangeBackColor := $EFEFEF;
    CurBriColor    := $0000FF;
    XLATPolygonColor := $00BB00;

    LabelsNFont := TN_UDNFont.Create2( 14, 'Arial' ); // 'Courier New'
    N_SetNFont( LabelsNFont, RFrame.OCanv );

    //***** BHFSrcDIB is needed for drawing X Axis labels

    BHFrameSetDIBObj( N_CM_MainForm.CMMFActiveEdFrame.EdSlide.GetCurrentImage().DIBObj );

    RFrameResize( nil ); // all previous calls did not work because BrigHist2Form was not ready

    with RFrame do //***** Init RFrame
    begin
      RFCenterInDst  := True;
      DrawProcObj    := nil;
      OCanvBackColor := -1; // to prevent clear RFrame OCanv Bufer
      OCanv.SetFontAttribs( 0 );
      RedrawAllAndShow();
    end; // with RFrame do //***** Init RFrame

  end; // with BCGHistFrame do //***** Init BCGHistFrame

  K_CMRedrawObject.InitRedraw( TrackBarChangeRedraw );
  TBValChange( Sender );
  ChBAutoLLLUClick( Sender );
  RemainingRedrawMode := 1;
end; // procedure TK_FormCMSBriCoGam1.FormShow

//***************************************** TK_FormCMSBriCoGam1.FormShow ***
//  On Form Close Query Handler
//
procedure TK_FormCMSBriCoGam1.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  K_CMRedrawObject.OnRedrawProcObj := nil;
end; // procedure TK_FormCMSBriCoGam1.FormCloseQuery

//***************************************** TK_FormCMSBriCoGam1.FormShow ***
//  On bnReset button Click handler
//
procedure TK_FormCMSBriCoGam1.bnResetClick( Sender: TObject );
begin
  SkipRebuild := TRUE;
  ChBAutoLLLU.Checked   := FALSE;
  ChBSyncLLUL.Checked   := FALSE;
  TBGamma.Position      := TBGamma.Max      shr 1;
  TBBrightness.Position := TBBrightness.Max shr 1;
  TBContrast.Position   := TBContrast.Max   shr 1;

  TBLL.Position         := TBLL.Min;
  TBLU.Position         := TBLU.Max;
  TBLL.SelEnd           := TBLL.Max;
  TBLU.SelStart         := TBLU.Min;
  SkipRebuild := FALSE;

  TBAutoLLULPower.Position := TBAutoLLULPower.Min;
  ChBAutoLLLUPower.Checked := FALSE;

  TBValChange( Sender );
  ChBAutoLLLUClick( Sender );
end; // procedure TK_FormCMSBriCoGam1.bnResetClick

//***************************************** TK_FormCMSBriCoGam1.EdBriValEnter ***
//  On TEdit Field enter Handler
//
procedure TK_FormCMSBriCoGam1.EdBriValEnter(Sender: TObject);
begin
  TEdit(Sender).SelectAll;
end; // procedure TK_FormCMSBriCoGam1.EdBriValEnter

//***************************************** TK_FormCMSBriCoGam1.EdBriValKeyDown ***
//  On TEdit Field Key Down Handler
//
procedure TK_FormCMSBriCoGam1.EdBriValKeyDown( Sender: TObject;
                                            var Key: Word; Shift: TShiftState );
begin
  if Key <> VK_RETURN then Exit;

  SkipRebuild := TRUE;
  with WVCAttrs do begin
    TBBrightness.Position := Round( LSFGamma.Func2Arg( StrToFloatDef( EdBriVal.Text, VCBriFactor ) ) );
    TBGamma.Position      := Round( LSFGamma.Func2Arg( StrToFloatDef( EdGamVal.Text, VCGamFactor ) ) );
    TBContrast.Position   := Round( LSFGamma.Func2Arg( StrToFloatDef( EdCoVal.Text, VCCoFactor ) ) );

    TBLL.Position := Round( LSFGamma1.Func2Arg( StrToFloatDef( EdLLVal.Text, CurMinFactor ) ) );
    TBLU.Position := Round( LSFGamma1.Func2Arg( StrToFloatDef( EdLUVal.Text, CurMaxFactor ) ) );

    TBAutoLLULPower.Position := Round( TBAutoLLULPower.Max * StrToFloatDef( LbEdAutoLLULPower.Text, AutoPower ) );
  end;
  SkipRebuild := FALSE;

  TBValChange( Sender );
end; // procedure TK_FormCMSBriCoGam1.EdBriValKeyDown

//***************************************** TK_FormCMSBriCoGam1.HistFrameResize ***
//  On Histogram Frame Resize Handler
//
procedure TK_FormCMSBriCoGam1.HistFrameResize(Sender: TObject);
begin
  BCGHistFrame.RFrameResize( Sender );
end; // procedure TK_FormCMSBriCoGam1.HistFrameResize

//***************************************** TK_FormCMSBriCoGam1.ChBAutoLLLUClick ***
//  On Auto LL/LU calc Handler
//
procedure TK_FormCMSBriCoGam1.ChBAutoLLLUClick(Sender: TObject);
var
  ILL, IUL : Integer;
begin
  TBLL.Enabled := not ChBAutoLLLU.Checked;
  TBLU.Enabled := not ChBAutoLLLU.Checked;
  EdLLVal.Enabled := not ChBAutoLLLU.Checked;
  EdLUVal.Enabled := not ChBAutoLLLU.Checked;
  ChBAutoLLLUPower.Enabled  := ChBAutoLLLU.Checked;
  TBAutoLLULPower.Enabled   := ChBAutoLLLUPower.Enabled and ChBAutoLLLUPower.Checked;
  LbEdAutoLLULPower.Enabled := TBAutoLLULPower.Enabled;
  LbAutoLLULPower.Enabled   := TBAutoLLULPower.Enabled;
  if not ChBAutoLLLU.Checked then Exit;
  SkipRebuild := TRUE;
  with BCGHistFrame, WVCAttrs do
  begin
    if TBAutoLLULPower.Enabled then
    begin
      AutoPower := TBAutoLLULPower.Position / TBAutoLLULPower.Max;
      N_HistFindLLULXX2( AutoPower, SrcHist8Values, ILL, IUL )
    end
    else
      N_HistFindLLUL11( SrcHist8Values, ILL, IUL );
//    N_HistFindLLUL1( SrcHist8Values, ILL, IUL );
//    N_HistFindLLUL1( SrcHist8Values, ILL, IUL );
//    N_HistFindLLUL3( SrcHist8Values, ILL, IUL );
//    N_HistFindLLUL2( SrcHist8Values, ILL, IUL );

    VCBriMinFactor := ILL / High(SrcHist8Values) * 100;
    VCBriMaxFactor := IUL / High(SrcHist8Values) * 100;

    CurMinFactor := VCBriMinFactor;
    CurMaxFactor := VCBriMaxFactor;
    if VCNegateFlag then
    begin
      CurMinFactor := 100 - VCBriMaxFactor;
      CurMaxFactor := 100 - VCBriMinFactor;
    end;


    TBLL.Position := Round( LSFGamma1.Func2Arg( CurMinFactor ) );
    TBLU.Position := Round( LSFGamma1.Func2Arg( CurMaxFactor ) );
  end;
  SkipRebuild := FALSE;
  TBValChange( Sender );
end; // procedure TK_FormCMSBriCoGam1.ChBAutoLLLUClick

//******************************** TK_FormCMSBriCoGam1.TrackBarChangeRedraw ***
//  On Change Redraw routine
//
procedure TK_FormCMSBriCoGam1.TrackBarChangeRedraw;
var
  SlideDIB : TN_DIBObj; // Temporary closed

begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
//    sleep( 1000 );  // debug - imitation of slow redraw
    if (K_CMSkipMouseMoveRedraw = 0) or
       (RemainingRedrawMode = 0) or
       (RemainingRedrawMode = 1) then
    begin // Redraw in all cases except redraw self histogram only:
          // (RemainingRedrawMode = 2) 

  //    if EdSlide.CMSShowWaitStateFlag then
  //      CMMFShowHideWaitState( TRUE );
      EdSlide.RebuildMapImageByDIB( nil, @WVCAttrs, @EmbDIB1 );
      RFrame.RedrawAllAndShow();

      if N_BrigHist2Form <> nil then
        N_BrigHist2Form.SetXLATtoConv( @EdSlide.CMSXLatBCGHist[0] );
  //      N_BrigHist2Form.SetXLATtoConv( @XLatBCG[0] );

  //    if EdSlide.CMSShowWaitStateFlag then
  //      CMMFShowHideWaitState( FALSE );
    end;

    if (K_CMSkipMouseMoveRedraw = 0) or (RemainingRedrawMode = 0) or
       ((RemainingRedrawMode = 1) and (K_CMSkipMouseMoveRedraw > 1)) or
       ((RemainingRedrawMode = 2) and (K_CMSkipMouseMoveRedraw = 1)) then
      // Redraw Self Histigram if no redraw delay or special ini redraw or
      // ordinary redraw and DelayMode > 1 or special Self Histigram redraw in DelayMode = 1
      with BCGHistFrame do
      begin
        SlideDIB := EdSlide.GetCurrentImage().DIBObj;
        if BHFSrcDIB <> SlideDIB then
          BHFrameSetDIBObj( SlideDIB );

        //***** XLatBCG, CurMinBri, CurMaxBri are all 8 bit values

        BHFPXLAT8toDraw := @XLatBCG[0];
  //      CurMinBri  := Round( High(XLatBCG)* WVCAttrs.VCBriMinFactor / 100 );
        CurMinBri  := Round( High(XLatBCG)* CurMinFactor / 100 );
        CurMinBri8 := CurMinBri;
  //      CurMaxBri  := Round( High(XLatBCG)* WVCAttrs.VCBriMaxFactor / 100 );
        CurMaxBri  := Round( High(XLatBCG)* CurMaxFactor / 100 );
        CurMaxBri8 := CurMaxBri;

        CalcPolygons( -1 ); // Calc all polygons coords
        RedrawRFrame();
      end; // with BCGHistFrame do
  end; // with N_CM_MainForm, CMMFActiveEdFrame do

end; // procedure TK_FormCMSBriCoGam1.TrackBarChangeRedraw

end.


