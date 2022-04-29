unit K_FCMSFlashlightModeAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Gra2, N_Lib2, N_Types, N_Comp1,
  K_CLib0, K_CM0, K_UDT1;

type
  TK_FormCMSFlashlightModeAttrs = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK    : TButton;
    GBGamma: TGroupBox;
    GBZoom: TGroupBox;
    Label4: TLabel;
    TBZoom: TTrackBar;
    Label1_: TLabel;
    Label2_: TLabel;
    Label6_: TLabel;
    Label3: TLabel;
    TBGamma: TTrackBar;
    EdGamVal: TEdit;
    RGSize_4: TRadioGroup;
    RGShape: TRadioGroup;
    RGMode: TRadioGroup;
    procedure TBValChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EdGamValKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdGamValEnter(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    SkipRebuild : Boolean;
    FlashlightIniData : TK_CMFlashlightIniData;
    PFlashlightIniData : TK_PCMFlashlightIniData;
    procedure FlashlightRedraw;
  public
    { Public declarations }
    CUDFlashlight : TN_UDBase;
    LSFGamma : TK_LineSegmFunc;
    LSFScale : TK_LineSegmFunc;

  end;

var
  K_FormCMSFlashlightModeAttrs: TK_FormCMSFlashlightModeAttrs;

function K_CMSFlashlightModeAttrsDlg( APFlashlightIniData : TK_PCMFlashlightIniData;
                                      AUDFlashlight : TN_UDBase  ) : Boolean;

implementation

uses Types, Math,
     N_Lib1, N_Gra0, N_Gra1, N_CompBase, N_CMMain5F;

{$R *.dfm}

//********************************************* K_CMSFlashlightModeAttrsDlg ***
//  Flashlight attrs change dialog
//
//     Parameters
// APFlashlightIniData - pointer to Flashlight Initial Attributes
// AUDFlashlight - Flashlight Component UDBase
// Result        - Returns TRUE if ROI attributes were changed
//
function K_CMSFlashlightModeAttrsDlg( APFlashlightIniData : TK_PCMFlashlightIniData;
                                      AUDFlashlight : TN_UDBase  ) : Boolean;
begin

  with TK_FormCMSFlashlightModeAttrs.Create(Application) do
  begin
    CUDFlashlight := AUDFlashlight;
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
    PFlashlightIniData := APFlashlightIniData;
    FlashlightIniData := APFlashlightIniData^;
    Result := ShowModal() = mrOK;
    if not Result then
    begin
      APFlashlightIniData^ := FlashlightIniData;
      FlashlightRedraw();
    end;
  end;
end; // function K_CMSFlashlightModeAttrsDlg

//******************************* TK_FormCMSFlashlightModeAttrs.TBValChange ***
//  On TrackBar Change Handler
//
procedure TK_FormCMSFlashlightModeAttrs.TBValChange(Sender: TObject);
begin
  with N_CM_MainForm, CMMFlashlightLastEd3Frame do begin
    if SkipRebuild then Exit;
    with PFlashlightIniData^ do
    begin
      case RGSize_4.ItemIndex of
      0 : CMFLPixSize := K_CMFlashlightModeBasePixSize;
      1 : CMFLPixSize := Round( 1.5 * K_CMFlashlightModeBasePixSize );
      2 : CMFLPixSize := 2 * K_CMFlashlightModeBasePixSize;
      3 : CMFLPixSize := 3 * K_CMFlashlightModeBasePixSize;
      end;
      CMFLScaleFactor := LSFScale.Arg2Func( TBZoom.Position );
      CMFLRectFlag := RGShape.ItemIndex;
      CMFLGamFactor := LSFGamma.Arg2Func( TBGamma.Position );
      EdGamVal.Text := format( '%5.1f', [Round(CMFLGamFactor*10)/10] );
      CMFLMode := TN_UDDIBRectMode(RGMode.ItemIndex);
    end;
    
    if K_CMSkipMouseMoveRedraw = 0 then
      FlashlightRedraw()
    else
      K_CMRedrawObject.Redraw();

  end;

end; // procedure TK_FormCMSFlashlightModeAttrs.TBValChange

//************************** TK_FormCMSFlashlightModeAttrs.FlashlightRedraw ***
//  Flashlight redraw routine
//
procedure TK_FormCMSFlashlightModeAttrs.FlashlightRedraw;
var WF : Float;
begin
  if N_CM_MainForm.CMMFlashlightLastEd3Frame = nil then Exit; // precaution
  with N_CM_MainForm, CMMFlashlightLastEd3Frame do
  begin
    K_CMSetFlashLightAttrs( TN_UDCompVis(CUDFlashlight), PFlashlightIniData );
    with TN_UDCompVis(CUDFlashlight).PCCS()^ do
    begin
      WF := SRSize.X;
      SRSize.X := TN_UDCompVis(CUDFlashlight.Owner).CompP2U.CX * PFlashlightIniData.CMFLPixSize;
      BPCoords.X := BPCoords.X + (WF - SRSize.X) / 2;
      WF := SRSize.Y;
      SRSize.Y := TN_UDCompVis(CUDFlashlight.Owner).CompP2U.CY * PFlashlightIniData.CMFLPixSize;
      BPCoords.Y := BPCoords.Y + (WF - SRSize.Y) / 2;
    end;
    K_CMSFlashlightCalcSrcRect( TN_UDCompVis(CUDFlashlight), RFrame.RFVectorScale,
               Point(PFlashlightIniData.CMFLPixSize, PFlashlightIniData.CMFLPixSize) );
    RFrame.RedrawAllAndShow();
  end;

end; // procedure TK_FormCMSFlashlightModeAttrs.FlashlightRedraw

//********************************** TK_FormCMSFlashlightModeAttrs.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMSFlashlightModeAttrs.FormShow(Sender: TObject);
var
  FInd : Double;
begin
  K_CMRedrawObject.InitRedraw( FlashlightRedraw );
  LSFGamma := TK_LineSegmFunc.Create( [0, -100,  100, -60,  250, -20,  750, 20,  900, 60,  1000, 100 ] );
  LSFScale := TK_LineSegmFunc.Create( [0, 1,  1000, 10 ] );

  with N_CM_MainForm, CMMFActiveEdFrame do begin
    SkipRebuild := TRUE;
    with FlashlightIniData do
    begin
      FInd := CMFLPixSize / K_CMFlashlightModeBasePixSize - 0.9;
      if FInd >= 1 then
        FInd := FInd + 1;
      if FInd >= 3 then
        FInd := 3;
      RGSize_4.ItemIndex := Round(FInd);
      TBZoom.Position := Round( LSFScale.Func2Arg( CMFLScaleFactor ) );
      RGShape.ItemIndex := CMFLRectFlag;
      EdGamVal.Text := format( '%5.1f', [Round(CMFLGamFactor*10)/10] );
      TBGamma.Position := Round( LSFGamma.Func2Arg( CMFLGamFactor ) );
      RGMode.ItemIndex := Ord(CMFLMode);
    end;
    SkipRebuild := FALSE;
  end;

end; // procedure TK_FormCMSFlashlightModeAttrs.FormShow

//*************************** TK_FormCMSFlashlightModeAttrs.EdGamValKeyDown ***
//  On EdGamVal Kew Down Handler
//
procedure TK_FormCMSFlashlightModeAttrs.EdGamValKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_RETURN then Exit;

  SkipRebuild := TRUE;
  TBGamma.Position := Round( LSFGamma.Func2Arg( StrToFloatDef( EdGamVal.Text, PFlashlightIniData^.CMFLGamFactor ) ) );
  SkipRebuild := FALSE;

  TBValChange( Sender );
end; // procedure TK_FormCMSFlashlightModeAttrs.EdGamValKeyDown

//***************************** TK_FormCMSFlashlightModeAttrs.EdGamValEnter ***
//  On EdGamVal Enter Handler
//
procedure TK_FormCMSFlashlightModeAttrs.EdGamValEnter(Sender: TObject);
begin
  TEdit(Sender).SelectAll;
end; // procedure TK_FormCMSFlashlightModeAttrs.EdGamValEnter

//**************************** TK_FormCMSFlashlightModeAttrs.FormCloseQuery ***
//  On Form Close Query Handler
//
procedure TK_FormCMSFlashlightModeAttrs.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  LSFGamma.Free;
  LSFScale.Free;
end; // procedure TK_FormCMSFlashlightModeAttrs.FormCloseQuery

end.
