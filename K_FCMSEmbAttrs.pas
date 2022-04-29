unit K_FCMSEmbAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_Types, N_BaseF, N_Gra2,
  K_CLib0, K_CM0;

type
  TK_FormCMSEmboss = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK    : TButton;
    bnReset: TButton;

    LbBri: TLabel;
    LbDepth: TLabel;
    LbDir: TLabel;
    LbRFactor: TLabel;

    TBDepth  : TTrackBar;
    TBDir    : TTrackBar;
    TBRFactor: TTrackBar;
    TBBri    : TTrackBar;
    LbB0_: TLabel;
    LbB50_: TLabel;
    LbB100_: TLabel;
    LbL0_: TLabel;
    LbL50_: TLabel;
    LbL100_: TLabel;
    LbD0_: TLabel;
    LbD50_: TLabel;
    LbD100_: TLabel;
    LbE0_: TLabel;
    LbE50_: TLabel;
    LbE100_: TLabel;
    procedure TBValChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bnResetClick(Sender: TObject);
  private
    { Private declarations }
    WVCAttrs: TK_CMSImgViewConvData;
    SkipRebuild : Boolean;
    PrevTrackBar : TTrackBar;
    PrevPosition : Integer;
    procedure SetTracBarsByAttrs();
  public
    { Public declarations }
    EmbDIB1 : TN_DIBObj;
    LSFDepth  : TK_LineSegmFunc;
    LSFDir    : TK_LineSegmFunc;
    LSFBri    : TK_LineSegmFunc;
    LSFRFactor: TK_LineSegmFunc;
  end;

var
  K_FormCMSEmboss: TK_FormCMSEmboss;

function K_CMSEmbossDlg( ) : Boolean;

implementation

uses Math,
     N_CMMain5F;

{$R *.dfm}

function K_CMSEmbossDlg( ) : Boolean;
var
  WasChanged : Boolean;
begin

  with N_CM_MainForm, CMMFActiveEdFrame,
       TK_FormCMSEmboss.Create(Application) do begin

//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    Result := ShowModal() = mrOK;
    if Result then begin
      WasChanged := FALSE;
      with EdSlide.P.CMSDB.ViewAttrs do
      begin
        if EmbDepth <> WVCAttrs.VCEmbDepth then
        begin
          EmbDepth := WVCAttrs.VCEmbDepth;
          WasChanged := TRUE;
        end;
        if EmbDirAngle <> WVCAttrs.VCEmbDirAngle then
        begin
          EmbDirAngle := WVCAttrs.VCEmbDirAngle;
          WasChanged := TRUE;
        end;
        if EmbRFactor <> WVCAttrs.VCEmbRFactor then
        begin
          EmbRFactor := WVCAttrs.VCEmbRFactor;
          WasChanged := TRUE;
        end;
        if EmbBase <> WVCAttrs.VCEmbBase then
        begin
          EmbBase := WVCAttrs.VCEmbBase;
          WasChanged := TRUE;
        end;
      end;
      Result := WasChanged;
    end else begin
     // Cancel Changes
      if EdSlide.CMSShowWaitStateFlag then
        CMMFShowHideWaitState( TRUE );
      EdSlide.RebuildMapImageByDIB( nil, nil, @EmbDIB1 );
      RFrame.RedrawAllAndShow();
      if EdSlide.CMSShowWaitStateFlag then
        CMMFShowHideWaitState( FALSE );
    end;
    EmbDIB1.Free;
    LSFDepth.Free;
    LSFDir.Free;
    LSFBri.Free;
    LSFRFactor.Free;
  end;

end;

procedure TK_FormCMSEmboss.TBValChange(Sender: TObject);
begin
  with N_CM_MainForm, CMMFActiveEdFrame do begin
    if SkipRebuild                                   or
       ( (Sender is TTrackBar) and
         ( ((PrevTrackBar = Sender)       and
           (PrevPosition = TTrackBar(Sender).Position))  or
           (EdSlide.CMSShowWaitStateFlag  and
           (csLButtonDown in TControl(Sender).ControlState)) ) ) then Exit;

    if (Sender is TTrackBar) then begin
      PrevTrackBar := TTrackBar(Sender);
      PrevPosition := TTrackBar(Sender).Position;
    end;

    with WVCAttrs do begin
      VCEmbDepth    := Round( LSFDepth.Arg2Func( TBDepth.Position ) );
      VCEmbDirAngle :=        LSFDir.Arg2Func( TBDir.Position );
      VCEmbRFactor  :=        LSFRFactor.Arg2Func( TBRFactor.Position );
      VCEmbBase     := Round( LSFBri.Arg2Func( TBBri.Position ) );
    end;

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );
    EdSlide.RebuildMapImageByDIB( nil, @WVCAttrs, @EmbDIB1 );
    RFrame.RedrawAllAndShow();
    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( FALSE );
  end;
end;

procedure TK_FormCMSEmboss.FormShow(Sender: TObject);
begin
  with N_CM_MainForm, CMMFActiveEdFrame do begin
    // Prepare LineSegmFunctions
    LSFDepth  := TK_LineSegmFunc.Create( [0,   1,    100, 20] );
    LSFDir    := TK_LineSegmFunc.Create( [0,   0,   1000, 359.9] );
    LSFBri    := TK_LineSegmFunc.Create( [0,   0,   1000, 255] );
    LSFRFactor:= TK_LineSegmFunc.Create( [0,   0.5, 200, 3.0, 500, 10.0, 1000, 80.0] );

    EdSlide.GetImgViewConvData( @WVCAttrs );
    K_CMInitEmbossAttrs( @WVCAttrs );
    SetTracBarsByAttrs();
  end;

end;

procedure TK_FormCMSEmboss.bnResetClick( Sender: TObject );
begin
{
  with WVCAttrs do begin
    VCEmbDepth    := 3;
    VCEmbDirAngle := 45;
    VCEmbRFactor  := 0.5;
    VCEmbBase     := 140;
  end;
}
  K_CMInitEmbossAttrs( @WVCAttrs, TRUE );
  SetTracBarsByAttrs();
  TBValChange( Sender );
end;

procedure TK_FormCMSEmboss.SetTracBarsByAttrs();
begin
    SkipRebuild := TRUE;
    with WVCAttrs do begin
      TBDepth.Position   := Round( LSFDepth.Func2Arg  ( VCEmbDepth ) );
      TBDir.Position     := Round( LSFDir.Func2Arg    ( VCEmbDirAngle ) );
      TBRFactor.Position := Round( LSFRFactor.Func2Arg( VCEmbRFactor ) );
      TBBri.Position     := Round( LSFBri.Func2Arg    ( VCEmbBase ) );
    end;
    SkipRebuild := FALSE;
end;

end.
