unit K_FCMSIsodensity;

interface

uses
  ComCtrls, ExtCtrls, StdCtrls, Controls, Classes,
  N_BaseF, N_Gra2,
  K_CM0, K_CLib0;

type
  TK_FormCMSIsodensity = class(TN_BaseForm)

    ColorBox: TColorBox;

    TBRange : TTrackBar;
    TBTransp: TTrackBar;

    LbTransp: TLabel;
    LbRange : TLabel;
    LbColor : TLabel;
    LbR0    : TLabel;
    LbT0    : TLabel;
    LbR100  : TLabel;
    LbT100  : TLabel;
    LbT50: TLabel;
    LbR50: TLabel;
    BtOK: TButton;
    BtCancel: TButton;

    procedure FormShow( Sender: TObject );
    procedure FormCloseQuery( Sender: TObject; var CanClose: Boolean );
    procedure FormCreate( Sender: TObject );
    procedure TBRangeChange(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    { Private declarations }
//    CurDIB  : TN_DIBObj;
    WVCAttrs: TK_CMSImgViewConvData;
    CurSlide: TN_UDCMSlide;
    SkipRebuild : Boolean;
    EmbDIB1 : TN_DIBObj;
    PrevTrackBar : TTrackBar;
    PrevPosition : Integer;
    LSFRange : TK_LineSegmFunc;

//    procedure CancelIsodensity( );
    procedure TrackBarChangeRedraw();
  public
    { Public declarations }
    procedure InitIsodensityMode( AFirstMouseDownEnabled : Boolean = FALSE );
    procedure SetImgColor( AColor : Integer );
    function  SaveIsoSettings( ) : Boolean;
    procedure SelfClose();
  end;

var
  K_FormCMSIsodensity: TK_FormCMSIsodensity;


implementation

uses Forms, Graphics, SysUtils, Windows,
  N_Types, N_Lib1, N_Rast1Fr, N_CMResF, N_CMMain5F, N_CMREd3Fr, N_BrigHist2F;

{$R *.dfm}

//******************************************* TK_FormCMSIsodensity.FormShow ***
//  On Form Show handler
//
procedure TK_FormCMSIsodensity.FormShow(Sender: TObject);
begin
  LSFRange := TK_LineSegmFunc.Create( [0, 0,  5000, 30, 7500, 60, 10000, 100 ] );
  K_CMRedrawObject.InitRedraw( TrackBarChangeRedraw );
  InitIsodensityMode( TRUE );
end; // procedure TK_FormCMSIsodensity.FormShow

//************************************* TK_FormCMSIsodensity.FormCloseQuery ***
//  On Form Close Query handler
//
procedure TK_FormCMSIsodensity.FormCloseQuery( Sender: TObject;
                                               var CanClose: Boolean );
begin
  EmbDIB1.Free;
  LSFRange.Free;
  if K_FormCMSIsodensity = nil then  Exit;
  K_FormCMSIsodensity := nil;
//  N_CMResForm.aEditPointExecute(nil); // !!! 2011-10-26
  N_CM_MainForm.CMMFActiveEdFrame.SetFrameDefaultViewEditMode(); // !!! 2011-10-26
  if ModalResult = mrOK then Exit;
  N_CMResForm.aToolsIsodens.Checked := false;
  N_CMResForm.aToolsIsodensExecute(nil);
end; // procedure TK_FormCMSIsodensity.FormCloseQuery

//***************************************** TK_FormCMSIsodensity.FormCreate ***
//  On Form Create handler
//
procedure TK_FormCMSIsodensity.FormCreate(Sender: TObject);
begin
  inherited;
  K_FormCMSIsodensity := Self;
  TBRange.SetTick(11);
end; // procedure TK_FormCMSIsodensity.FormCreate

//********************************* TK_FormCMSIsodensity.InitIsodensityMode ***
//  Init Isodensity Mode
//
//     Parameters
// AFirstMouseDownEnabled - first MouseDown enabled flag
//
procedure TK_FormCMSIsodensity.InitIsodensityMode( AFirstMouseDownEnabled : Boolean = FALSE );
var
  PCMSlide : TN_PCMSlide;
begin
  if Self = nil then Exit;
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin

    PCMSlide := EdSlide.P();
    with PCMSlide^ do
    if IfSlideIsImage()  and
       (PCMSlide <> nil) and
       (cmsfGreyScale in CMSDB.SFlags) and
       (cmsfShowIsodensity in CMSDB.SFlags)  then
    begin
      // check CurImg Grey
      with EdSlide.GetCurrentImage().DIBObj do
      begin
        if (DIBPixFmt <> pfCustom)   or
           ( (DIBExPixFmt <> epfGray8) and (DIBExPixFmt <> epfGray16) ) then
          raise Exception.Create( 'Slide Current Image is not Grey' );
      end;

      with RFrame do
        RFrActionFlags := RFrActionFlags - [rfafZoomByClick, rfafZoomByPMKeys,rfafScrollCoords];
      EdViewEditMode := cmrfemIsodensity;
      EdIsodensityRFA.ActEnabled := TRUE;
      if AFirstMouseDownEnabled then
        EdIsodensityRFA.SkipNextMouseDown := FALSE;

      if CurSlide = EdSlide then Exit; // Same Slide - nothing to do
      CurSlide := EdSlide;
      CurSlide.GetImgViewConvData( @WVCAttrs );

      SkipRebuild := TRUE;
      with WVCAttrs do
      begin
        ColorBox.Selected := TColor(VCIsoColor);
        TBRange.Position := Round( LSFRange.Func2Arg( VCIsoRangeFactor ) );
//        TBRange.Position := Round( VCIsoRangeFactor * TBRange.Max / 100 );
        TBTransp.Position := Round( VCIsoTranspFactor * TBTransp.Max / 100 );
      end;
      SkipRebuild := FALSE;

    end else
    begin
      CurSlide := nil;
      Self.Close();
    end;
  end;
end; // procedure TK_FormCMSIsodensity.InitIsodensityMode

//************************************** TK_FormCMSIsodensity.TBRangeChange ***
//  On TrackBar Change Handler
//
procedure TK_FormCMSIsodensity.TBRangeChange(Sender: TObject);
begin
  if (Sender <> nil)       and
     (Sender is TTrackBar) and
     ( SkipRebuild                                   or
       ((PrevTrackBar = Sender)       and
       (PrevPosition = TTrackBar(Sender).Position))  or
       (CurSlide.CMSShowWaitStateFlag and
       (csLButtonDown in TControl(Sender).ControlState)) ) then Exit;
//
  if (Sender <> nil) and (Sender is TTrackBar) then begin
    PrevTrackBar := TTrackBar(Sender);
    PrevPosition := TTrackBar(Sender).Position;
  end;
  with WVCAttrs do begin
    VCIsoColor := ColorBox.Selected;
    VCIsoRangeFactor  := LSFRange.Arg2Func( TBRange.Position ); // Image Colors Intensity Range Factor (0-100)
//    VCIsoRangeFactor  := TBRange.Position / TBRange.Max * 100; // Image Colors Intensity Range Factor (0-100)
    VCIsoTranspFactor := TBTransp.Position / TBTransp.Max * 100; // Isodensity Draw Transparency Factor (0-100)
  end;
  if not SaveIsoSettings( ) then Exit;
  if K_CMSkipMouseMoveRedraw = 0 then
    TrackBarChangeRedraw()
  else
    K_CMRedrawObject.Redraw();

  Exit;
{ // This code is moved to TrackBarChangeRedraw
  if CurSlide.CMSShowWaitStateFlag then
    N_CM_MainForm.CMMFShowHideWaitState( TRUE );
  CurSlide.RebuildMapImageByDIB( nil, nil, @EmbDIB1 );
  N_CM_MainForm.CMMFRebuildActiveView( [rvfSkipThumbRebuild] );
//!! new Interface feature - thumbnail changed only for changes that save slide UNDO state
//!!  Include( CurSlide.P.CMSRFlags, cmsfAttribsChanged );
//!!  if K_CMEDAccess.SlidesSaveMode = K_cmesImmediately then
//!!    K_CMEDAccess.EDASaveCurSlidesSet();
  if CurSlide.CMSShowWaitStateFlag then
    N_CM_MainForm.CMMFShowHideWaitState( FALSE );

//  if N_BrigHist2Form <> nil then
//    N_BrigHist2Form.SetBriRange( CurSlide.CMSIsoMin, CurSlide.CMSIsoMax );
  N_CM_MainForm.CMMFRefreshActiveEdFrameHistogram( );
}
end; // procedure TK_FormCMSIsodensity.TBRangeChange

//**************************************** TK_FormCMSIsodensity.SetImgColor ***
//  Set Image Isodensity Base Color
//
//     Parameters
// AColor  - setting Color
//
procedure TK_FormCMSIsodensity.SetImgColor(AColor: Integer);
begin
  CurSlide.GetImgViewConvData( @WVCAttrs );
  WVCAttrs.VCIsoBaseColInt := AColor;
  TBRangeChange(nil);
end; // procedure TK_FormCMSIsodensity.SetImgColor

//************************************ TK_FormCMSIsodensity.SaveIsoSettings ***
//  Save Image Isodensity Settings
//
function TK_FormCMSIsodensity.SaveIsoSettings( ) : Boolean;
begin
  Result := FALSE;
  if (Self = nil) or (CurSlide = nil) then Exit;
  with WVCAttrs, CurSlide.P()^, CMSDB.ViewAttrs do
  begin
    if IsoBaseColInt <> VCIsoBaseColInt then
    begin
      IsoBaseColInt := VCIsoBaseColInt;
      Result := TRUE;
    end;
    if IsoRangeFactor <> VCIsoRangeFactor then
    begin
      IsoRangeFactor := VCIsoRangeFactor;
      Result := TRUE;
    end;
    if IsoColor <> VCIsoColor then
    begin
      IsoColor := VCIsoColor;
      Result := TRUE;
    end;
    if IsoTranspFactor <> VCIsoTranspFactor then
    begin
      IsoTranspFactor := VCIsoTranspFactor;
      Result := TRUE;
    end;
  end;
end; // function TK_FormCMSIsodensity.SaveIsoSettings

//****************************************** TK_FormCMSIsodensity.SelfClose ***
//  Self Close Isodensity Dialog Rouine
//
procedure TK_FormCMSIsodensity.SelfClose;
begin
  if Self = nil then Exit;
  CurSlide := nil;
  Self.Close();
end; // procedure TK_FormCMSIsodensity.SelfClose

//***************************************** TK_FormCMSIsodensity.BtOKClick ***
//  On BtOK Click Handler
//
procedure TK_FormCMSIsodensity.BtOKClick(Sender: TObject);
begin
  Close();
end; // procedure TK_FormCMSIsodensity.BtOKClick

//************************************** TK_FormCMSIsodensity.BtCancelClick ***
//  On BtCancel Click Handler
//
procedure TK_FormCMSIsodensity.BtCancelClick(Sender: TObject);
begin
  Close();
end; // procedure TK_FormCMSIsodensity.BtCancelClick

//**************************************** TK_FormCMSIsodensity.FormDestroy ***
//  On Form Destroy Handler
//
procedure TK_FormCMSIsodensity.FormDestroy(Sender: TObject);
begin
  inherited;
  K_FormCMSIsodensity := nil;
end; // procedure TK_FormCMSIsodensity.FormDestroy

//******************************* TK_FormCMSIsodensity.TrackBarChangeRedraw ***
//  TrackBar Change Redraw routine
//
procedure TK_FormCMSIsodensity.TrackBarChangeRedraw;
begin
  if CurSlide.CMSShowWaitStateFlag then
    N_CM_MainForm.CMMFShowHideWaitState( TRUE );
  CurSlide.RebuildMapImageByDIB( nil, nil, @EmbDIB1 );
  N_CM_MainForm.CMMFRebuildActiveView( [rvfSkipThumbRebuild] );
//!! new Interface feature - thumbnail changed only for changes that save slide UNDO state
//!!  Include( CurSlide.P.CMSRFlags, cmsfAttribsChanged );
//!!  if K_CMEDAccess.SlidesSaveMode = K_cmesImmediately then
//!!    K_CMEDAccess.EDASaveCurSlidesSet();
  if CurSlide.CMSShowWaitStateFlag then
    N_CM_MainForm.CMMFShowHideWaitState( FALSE );

//  if N_BrigHist2Form <> nil then
//    N_BrigHist2Form.SetBriRange( CurSlide.CMSIsoMin, CurSlide.CMSIsoMax );
  N_CM_MainForm.CMMFRefreshActiveEdFrameHistogram( );

end; // procedure TK_FormCMSIsodensity.TrackBarChangeRedraw

end.
