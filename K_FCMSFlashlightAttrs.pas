unit K_FCMSFlashlightAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Gra2, N_Lib2, N_Types, N_Comp1,
  K_CLib0, K_CM0, K_UDT1;

type
  TK_FormCMSFlashlightAttrs = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK    : TButton;
    GBEqualize: TGroupBox;
    Label3: TLabel;
    Label5: TLabel;
    TBBrightness: TTrackBar;
    TBContrast: TTrackBar;
    bnReset: TButton;
    GBZoom: TGroupBox;
    Label4: TLabel;
    TBZoom: TTrackBar;
    GBBorder: TGroupBox;
    LbColor: TLabel;
    ColorBox: TColorBox;
    LbUnit: TLabel;
    CmBLineWidth: TComboBox;
    ChBBorder: TCheckBox;
    ChBZoom: TCheckBox;
    ChBAutoEqualize: TCheckBox;
    Label1_: TLabel;
    Label2_: TLabel;
    Label6_: TLabel;
    RGShape: TRadioGroup;
    procedure FlashlightRedraw;
    procedure TBValChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bnResetClick(Sender: TObject);
  private
    { Private declarations }
    SkipRebuild : Boolean;
//    PrevPosition : Integer;
//    PrevTrackBar : TObject;

    PUPScaleFactor: TN_POneUserParam;
    PUPSkipScaleFlag: TN_POneUserParam;
    PUPUseAutoEqualizeFlag: TN_POneUserParam;
    PUPBriFactor: TN_POneUserParam;
    PUPCoFactor: TN_POneUserParam;
    PUPBorderColor: TN_POneUserParam;
    PUPBorderColor1: TN_POneUserParam;
    PUPBorderWidth: TN_POneUserParam;
    PUPEllipseBorderFlag: TN_POneUserParam;
    PUPRectBorderFlag: TN_POneUserParam;
    PCDIBRect : TN_PCDIBRect;

    PrevScaleFactor : Single;
    PrevSkipScaleFlag : Integer;
    PrevUseAutoEqualizeFlag : Integer;
    PrevBriFactor : Single;
    PrevCoFactor : Single;
    PrevBorderColor : TColor;
    PrevBorderWidthIndex : Integer;
    PrevEllipseMask : Boolean;

  public
    { Public declarations }
    CUDFlashlight : TN_UDBase;
//    LSFBriCo : TK_LineSegmFunc;
    LSFBrigh : TK_LineSegmFunc;
    LSFContr : TK_LineSegmFunc;
    LSFScale : TK_LineSegmFunc;

  end;

var
  K_FormCMSFlashlightAttrs: TK_FormCMSFlashlightAttrs;

function K_CMSFlashlightAttrsDlg( AUDFlashlight : TN_UDBase ) : Boolean;

implementation

uses Math,
     N_Lib1, N_Gra0, N_Gra1, N_CompBase, N_CMMain5F;

{$R *.dfm}

//************************************************* K_CMSFlashlightAttrsDlg ***
//  ROI (Flashlight) attrs change dialog
//
//     Parameters
// AUDFlashlight - ROI (Flashlight) Component UDBase
// Result        - Returns TRUE if ROI attributes were changed
//
function K_CMSFlashlightAttrsDlg( AUDFlashlight : TN_UDBase ) : Boolean;
begin

  with N_CM_MainForm,
       CMMFActiveEdFrame,
       TK_FormCMSFlashlightAttrs.Create(Application) do begin
    CUDFlashlight := AUDFlashlight;
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    Result := ShowModal() = mrOK;
    if Result then begin
      if not ChBAutoEqualize.Enabled then
        PInteger(PUPUseAutoEqualizeFlag.UPValue.P)^ := PrevUseAutoEqualizeFlag;

      Result :=
      (PColor(PUPBorderColor.UPValue.P)^ <> PrevBorderColor) or
      (PFloat(PUPBorderWidth.UPValue.P)^ <>
         Float(CmBLineWidth.Items.Objects[CmBLineWidth.ItemIndex])) or
      (PFloat(PUPBriFactor.UPValue.P)^ <> PrevBriFactor) or
      (PFloat(PUPCoFactor.UPValue.P)^ <> PrevCoFactor) or
      (PFloat(PUPScaleFactor.UPValue.P)^ <> PrevScaleFactor) or
      (PInteger(PUPSkipScaleFlag.UPValue.P)^ <> PrevSkipScaleFlag) or
      (PrevEllipseMask <> (uddrfEllipseMask in PCDIBRect.CDRFlags)) or
      (PInteger(PUPUseAutoEqualizeFlag.UPValue.P)^ <> PrevUseAutoEqualizeFlag);

      // Save Current ROI Attributes as Flashlight Ini Atrributes
      K_CMFlashlightIni.CMFLRectFlag := PInteger(PUPRectBorderFlag.UPValue.P)^;

    end else begin
     // Cancel Changes
      PColor(PUPBorderColor.UPValue.P)^ := PrevBorderColor;
      if (PUPBorderColor1 <> nil) and (PrevBorderColor <> -1) then
        PColor(PUPBorderColor1.UPValue.P)^ := PrevBorderColor;

      PFloat(PUPBorderWidth.UPValue.P)^ := Float(CmBLineWidth.Items.Objects[PrevBorderWidthIndex]);
      PFloat(PUPBriFactor.UPValue.P)^ := PrevBriFactor;
      PFloat(PUPCoFactor.UPValue.P)^ := PrevCoFactor;
      PFloat(PUPScaleFactor.UPValue.P)^ := PrevScaleFactor;
      PInteger(PUPSkipScaleFlag.UPValue.P)^ := PrevSkipScaleFlag;
      PInteger(PUPUseAutoEqualizeFlag.UPValue.P)^ := PrevUseAutoEqualizeFlag;
      if PrevEllipseMask then begin
        Include( PCDIBRect.CDRFlags, uddrfEllipseMask );
        PInteger(PUPEllipseBorderFlag.UPValue.P)^ := 1;
        PInteger(PUPRectBorderFlag.UPValue.P)^ := 0;
      end else begin
        Exclude( PCDIBRect.CDRFlags, uddrfEllipseMask );
        PInteger(PUPEllipseBorderFlag.UPValue.P)^ := 0;
        PInteger(PUPRectBorderFlag.UPValue.P)^ := 1;
      end;

//      if EdSlide.CMSShowWaitStateFlag then
//        CMMFShowHideWaitState( TRUE );

      K_CMSFlashlightCalcSrcRect( TN_UDCompVis(CUDFlashlight), RFrame.RFVectorScale,
                                  N_RectSize( TN_UDCompVis(CUDFlashlight).CompOuterPixRect ) );

      RFrame.RedrawAllAndShow();

//      if EdSlide.CMSShowWaitStateFlag then
//        CMMFShowHideWaitState( FALSE );
    end;
    LSFBrigh.Free;
    LSFContr.Free;
    LSFScale.Free;
  end;

end; // function K_CMSFlashlightAttrsDlg

//****************************** TK_FormCMSFlashlightAttrs.FlashlightRedraw ***
//  ROI redraw routine
//
procedure TK_FormCMSFlashlightAttrs.FlashlightRedraw;
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
//    if EdSlide.CMSShowWaitStateFlag then
//      CMMFShowHideWaitState( TRUE );

    K_CMSFlashlightCalcSrcRect( TN_UDCompVis(CUDFlashlight), RFrame.RFVectorScale,
                                N_RectSize( TN_UDCompVis(CUDFlashlight).CompOuterPixRect ) );
    RFrame.RedrawAllAndShow();

//    if EdSlide.CMSShowWaitStateFlag then
//      CMMFShowHideWaitState( FALSE );
  end; // with N_CM_MainForm, CMMFActiveEdFrame do
end; // procedure TK_FormCMSFlashlightAttrs.FlashlightRedraw

//*********************************** TK_FormCMSFlashlightAttrs.TBValChange ***
//  On TrackBar Change Handler
//
procedure TK_FormCMSFlashlightAttrs.TBValChange(Sender: TObject);
var
  CColor : TColor;
  IVal : Integer;
begin
  with N_CM_MainForm, CMMFActiveEdFrame do begin
{
    if SkipRebuild or
       ((PrevTrackBar = Sender) and (PrevPosition = TTrackBar(Sender).Position)) or
       (EdSlide.CMSShowWaitStateFlag and
        (Sender is TTrackBar)        and
        (csLButtonDown in TControl(Sender).ControlState)) then Exit;
}
    if SkipRebuild then Exit;
{
    if Sender is TTrackBar then begin
      PrevTrackBar := Sender;
      PrevPosition := TTrackBar(Sender).Position;
    end;
}

    CColor := -1;
    if ChBBorder.Checked and (ColorBox.ItemIndex >= 0) then
    begin
      CColor := ColorBox.Selected;
    end;

    if PUPBorderColor1 <> nil then
      PColor(PUPBorderColor1.UPValue.P)^ := ColorBox.Selected;

    PColor(PUPBorderColor.UPValue.P)^ := CColor;

    with CmBLineWidth do
      PFloat(PUPBorderWidth.UPValue.P)^ := Float(Items.Objects[ItemIndex]);

    PFloat(PUPBriFactor.UPValue.P)^   := LSFBrigh.Arg2Func( TBBrightness.Position );
    PFloat(PUPCoFactor.UPValue.P)^    := LSFContr.Arg2Func( TBContrast.Position );
    PFloat(PUPScaleFactor.UPValue.P)^ := LSFScale.Arg2Func( TBZoom.Position );
    IVal := 0;
    if ChBAutoEqualize.Checked then
      IVal := 1;
    PInteger(PUPUseAutoEqualizeFlag.UPValue.P)^ := IVal;

    IVal := 1;
    if ChBZoom.Checked then
      IVal := 0;
    PInteger(PUPSkipScaleFlag.UPValue.P)^ := IVal;

    if RGShape.ItemIndex = 0 then begin
      Include( PCDIBRect.CDRFlags, uddrfEllipseMask );
      PInteger(PUPEllipseBorderFlag.UPValue.P)^ := 1;
      PInteger(PUPRectBorderFlag.UPValue.P)^ := 0;
    end else begin
      PInteger(PUPEllipseBorderFlag.UPValue.P)^ := 0;
      PInteger(PUPRectBorderFlag.UPValue.P)^ := 1;
      Exclude( PCDIBRect.CDRFlags, uddrfEllipseMask );
    end;

    if K_CMSkipMouseMoveRedraw = 0 then
      FlashlightRedraw()
    else
      K_CMRedrawObject.Redraw();
{
//    if EdSlide.CMSShowWaitStateFlag then
//      CMMFShowHideWaitState( TRUE );

    K_CMSFlashlightCalcSrcRect( TN_UDCompVis(CUDFlashlight), RFrame.RFVectorScale,
                                N_RectSize( TN_UDCompVis(CUDFlashlight).CompOuterPixRect ) );
    RFrame.RedrawAllAndShow();

//    if EdSlide.CMSShowWaitStateFlag then
//      CMMFShowHideWaitState( FALSE );
}
  end;

end; // procedure TK_FormCMSFlashlightAttrs.TBValChange

//************************************** TK_FormCMSFlashlightAttrs.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMSFlashlightAttrs.FormShow(Sender: TObject);
var
  LWidth, CWidth : Single;
  WStr : string;
  i : Integer;
begin
  LSFBrigh := TK_LineSegmFunc.Create( [0, -100,  100, -60,  250, -20,  750, 20,  900, 60,  1000, 100 ] );
  LSFContr := TK_LineSegmFunc.Create( [0, 1,  500, 5,  800, 20,  1000, 50 ] );
  LSFScale := TK_LineSegmFunc.Create( [0, 1,  1000, 10 ] );
  SkipRebuild := TRUE;
  K_CMRedrawObject.InitRedraw( FlashlightRedraw );

  with N_CM_MainForm, CMMFActiveEdFrame do
  begin

//    PUPBorderColor := N_GetUserParPtr( TN_UDCompBase(CUDFlashlight).R, 'MainColor' );
    PUPBorderColor  := K_CMGetVObjPAttr( CUDFlashlight, 'MainColor' );
    PUPBorderColor1 := K_CMGetVObjPAttr( CUDFlashlight, 'MainColor1' );
    if PUPBorderColor <> nil then begin
      PrevBorderColor := PColor(PUPBorderColor.UPValue.P)^;
      ChBBorder.Checked := PrevBorderColor <> -1;
      if PUPBorderColor1 <> nil then
        ColorBox.Selected := PColor(PUPBorderColor1.UPValue.P)^;
      if ColorBox.ItemIndex = -1 then
        ColorBox.ItemIndex := 9;
    end;

  // Build Widths ComboBox
    with CmBLineWidth, Items do begin
      CommaText :=  N_MemIniToString( 'CMS_Main', 'VObjLineWidth', '0.1,0.3,0.8,1.5,3.0,4.5,6.0' );
      for i := 0 to Count - 1 do begin
        WStr := Trim( Strings[i] );
        Strings[i] := WStr + ' pt';
        LWidth := StrToFloatDef( WStr, 1 + i * 1.5 );
        Objects[i] := TObject(LWidth);
      end;
      ItemIndex := 0;

//      PUPBorderWidth := N_GetUserParPtr( TN_UDCompBase(CUDFlashlight).R, 'LineWidth' );
      PUPBorderWidth := K_CMGetVObjPAttr( CUDFlashlight, 'LineWidth' );
      if PUPBorderWidth <> nil then begin
        CWidth := PFloat(PUPBorderWidth.UPValue.P)^;
        ItemIndex := IndexOfObject( TObject(CWidth) );
        if ItemIndex = -1 then ItemIndex := 0;
        PrevBorderWidthIndex := ItemIndex;
      end;
    end;

//    PUPEllipseBorderFlag := N_GetUserParPtr( TN_UDCompBase(CUDFlashlight).R, 'ShowEllipse' );
    PUPEllipseBorderFlag := K_CMGetVObjPAttr( CUDFlashlight, 'ShowEllipse' );
//    PUPRectBorderFlag := N_GetUserParPtr( TN_UDCompBase(CUDFlashlight).R, 'ShowRect' );
    PUPRectBorderFlag := K_CMGetVObjPAttr( CUDFlashlight, 'ShowRect' );
//!! Old    PCDIBRect := @(TN_UDDIBRect(CUDFlashlight.DirChild(0)).PSP.CDIBRect);
    PCDIBRect := @(TN_UDDIBRect(CUDFlashlight.DirChild(1)).PSP.CDIBRect);
    PrevEllipseMask := uddrfEllipseMask in PCDIBRect.CDRFlags;
    RGShape.ItemIndex := PInteger(PUPRectBorderFlag.UPValue.P)^;


//    CDIBRect.CDRFlags
//    TN_UDDIBRect(DirChild(0)).PSP.CDIBRect

//    PUPBriFactor  := N_GetUserParPtr( TN_UDCompBase(CUDFlashlight).R, 'BriFactor' );
    PUPBriFactor  := K_CMGetVObjPAttr( CUDFlashlight, 'BriFactor' );
    PrevBriFactor := PFloat(PUPBriFactor.UPValue.P)^;
    TBBrightness.Position := Round( LSFBrigh.Func2Arg( PrevBriFactor ) );

//    PUPCoFactor  := N_GetUserParPtr( TN_UDCompBase(CUDFlashlight).R, 'CoFactor' );
    PUPCoFactor  := K_CMGetVObjPAttr( CUDFlashlight, 'CoFactor' );
    PrevCoFactor := PFloat(PUPCoFactor.UPValue.P)^;

    if PrevCoFactor = 0 then PrevCoFactor := 3; // temporary

    TBContrast.Position := Round( LSFContr.Func2Arg( PrevCoFactor ) );

//    PUPScaleFactor := N_GetUserParPtr( TN_UDCompBase(CUDFlashlight).R, 'ScaleFactor' );
    PUPScaleFactor := K_CMGetVObjPAttr( CUDFlashlight, 'ScaleFactor' );
    PrevScaleFactor := PFloat(PUPScaleFactor.UPValue.P)^;
    TBZoom.Position := Round( LSFScale.Func2Arg( PrevScaleFactor ) );

//    PUPSkipScaleFlag := N_GetUserParPtr( TN_UDCompBase(CUDFlashlight).R, 'SkipScaleFlag' );
    PUPSkipScaleFlag := K_CMGetVObjPAttr( CUDFlashlight, 'SkipScaleFlag' );
    PrevSkipScaleFlag := PInteger(PUPSkipScaleFlag.UPValue.P)^;
    ChBZoom.Checked := PrevSkipScaleFlag = 0;

    ChBAutoEqualize.Enabled := cmsfGreyScale in EdSlide.P.CMSDB.SFlags;
    bnReset.Enabled := ChBAutoEqualize.Enabled;
    TBBrightness.Enabled := ChBAutoEqualize.Enabled;
    TBContrast.Enabled := ChBAutoEqualize.Enabled;
//    PUPUseAutoEqualizeFlag := N_GetUserParPtr( TN_UDCompBase(CUDFlashlight).R, 'AutoEqualizeFlag' );
    PUPUseAutoEqualizeFlag := K_CMGetVObjPAttr( CUDFlashlight, 'AutoEqualizeFlag' );
    PrevUseAutoEqualizeFlag := PInteger(PUPUseAutoEqualizeFlag.UPValue.P)^;
    ChBAutoEqualize.Checked := (PrevUseAutoEqualizeFlag <> 0) and
                               ChBAutoEqualize.Enabled;

  end; // with N_CM_MainForm, CMMFActiveEdFrame do

  SkipRebuild := FALSE;

end; // procedure TK_FormCMSFlashlightAttrs.FormShow

//************************************** TK_FormCMSFlashlightAttrs.FormShow ***
//  On bnReset Click Handler
//
procedure TK_FormCMSFlashlightAttrs.bnResetClick( Sender: TObject );
begin
  SkipRebuild := TRUE;
  TBBrightness.Position := 500;
  TBContrast.Position   := 1000;
  SkipRebuild := FALSE;

  TBValChange( Sender );
end; // procedure TK_FormCMSFlashlightAttrs.bnResetClick

end.
