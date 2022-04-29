unit K_FCMSSharpAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Comp2, N_Lib2, N_Types, N_Gra2,
  K_CM0, K_UDT1;

type
  TK_FormCMSSharpAttrs = class(TN_BaseForm)
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
    procedure TBValChange(Sender: TObject);
    procedure BtApplyClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure LbEdConvFactorKeyPress(Sender: TObject; var Key: Char);
    procedure BtOKClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    SkipRebuild : Boolean;
    SkipApply   : Boolean;
    DoApplyAfter: Boolean;
    DoOKAfter: Boolean;
    ApplyOKWait: Boolean;
    StartEditing: Boolean;
    PrevValPosition : Integer;
  public
    { Public declarations }
    SavedDIB : TN_DIBObj;
    NewDIB   : TN_DIBObj;
    EmbDIB1 : TN_DIBObj;
    SharpMatr: TN_BArray;
    SharpCoefs: TN_FArray;
    SharpDepth : Integer;
  end;

var
  K_FormCMSSharpAttrs: TK_FormCMSSharpAttrs;

function K_CMSSharpenDlg( ) : Boolean;

implementation

uses Math,
  N_Gra3,
  N_CompBase, N_Lib1, N_CMMain5F, N_Gra6;

{$R *.dfm}

function K_CMSSharpenDlg( ) : Boolean;
begin
  with N_CM_MainForm, CMMFActiveEdFrame,
      TK_FormCMSSharpAttrs.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    SkipRebuild := TRUE;
    SkipApply := TRUE;
    TBVal.Position := TBVal.Max shr 1;
    PrevValPosition := TBVal.Position;
    StartEditing := TRUE;
    Timer.Enabled := TRUE;
    Result := ShowModal() = mrOK;
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
        EdSlide.RebuildMapImageByDIB( DIBObj, nil, @EmbDIB1 );
        RFrame.RedrawAllAndShow();
        if EdSlide.CMSShowWaitStateFlag then
          CMMFShowHideWaitState( FALSE );
      end;
    end;
    EmbDIB1.Free;
  end;
end;

procedure TK_FormCMSSharpAttrs.TBValChange(Sender: TObject);
begin
  with N_CM_MainForm, CMMFActiveEdFrame do begin
    if (Sender <> nil) and
       ( SkipRebuild                        or
         (PrevValPosition = TBVal.Position) ) then Exit;
{
    if (Sender <> nil) and
       ( SkipRebuild                        or
         (PrevValPosition = TBVal.Position) or
         (EdSlide.CMSShowWaitStateFlag and
         (Sender = TBVal)              and
         (csLButtonDown in TControl(Sender).ControlState)) ) then Exit;
}
    PrevValPosition := TBVal.Position;
    SkipRebuild := TRUE;
    Timer.Enabled := TRUE;
  end;
end;

procedure TK_FormCMSSharpAttrs.BtApplyClick(Sender: TObject);
var
  VKR : Char;
begin
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

    SavedDIB.CalcSmoothedMatr( SharpMatr, @SharpCoefs[0], SharpDepth );

//    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( FALSE );
  end;

//  TBValChange(nil);
  TBVal.Position := TBVal.Max shr 1;
  PrevValPosition := TBVal.Position;
//??  Application.ProcessMessages;
  SkipApply := FALSE;
end;

procedure TK_FormCMSSharpAttrs.TimerTimer(Sender: TObject);
var
  Base : Integer;
  ConvFactor : Double;
  VConvFactor : Double;
begin
  Timer.Enabled := FALSE;
  with N_CM_MainForm, CMMFActiveEdFrame do begin

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );

    if StartEditing then begin
      VConvFactor := 0;
      StartEditing := FALSE;
      SavedDIB := EdSlide.GetCurrentImage.DIBObj;
      SharpDepth := 13;
      N_CalcGaussMatr( SharpCoefs, SharpDepth, 10.0 );

      NewDIB := TN_DIBObj.Create( SavedDIB );

      SavedDIB.CalcSmoothedMatr( SharpMatr, @SharpCoefs[0], SharpDepth );

    end else begin
      Base := TBVal.Max shr 1;
      ConvFactor := (TBVal.Position - Base) / Base;
      VConvFactor := ConvFactor * 100;

      if ConvFactor < 0 then
        ConvFactor := ConvFactor * K_CMSharpenMax;

    //  Convert by Sharpen Filter
      SavedDIB.CalcLinCombDIB( NewDIB, @SharpMatr[0], ConvFactor );

    //  Rebuild Slide View
      with N_CM_MainForm.CMMFActiveEdFrame do begin
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
  end;

  LbEdConvFactor.Text := format( '%6.1f', [VConvFactor] );

end;

procedure TK_FormCMSSharpAttrs.LbEdConvFactorKeyPress(Sender: TObject;
  var Key: Char);
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

end;

procedure TK_FormCMSSharpAttrs.BtOKClick(Sender: TObject);
var
  VKR : Char;
begin

  if not ApplyOKWait then
  begin
    VKR := Chr(VK_RETURN);
    LbEdConvFactorKeyPress( Sender, VKR );
  end;
  DoOKAfter := ApplyOKWait;

end;

procedure TK_FormCMSSharpAttrs.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not DoOKAfter;
end;

end.
