unit N_CMSharp1F;
// Sharp/Smooth Attributes Compact Form (for new enhanced algorithm)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Comp2, N_Lib2, N_Types, N_Gra2,
  K_CM0, K_UDT1;

type TN_CMSharp1Form = class( TN_BaseForm )
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
    Edit1: TEdit;

    procedure TBValChange(Sender: TObject);
    procedure BtApplyClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    SkipRebuild : Boolean;
    SkipApply   : Boolean;
    StartEditing: Boolean;
    PrevValPosition : Integer;
  public
    SavedDIB : TN_DIBObj;
    NewDIB   : TN_DIBObj;
    EmbDIB1 : TN_DIBObj;
    SharpMatr: TN_BArray;
    SharpCoefs: TN_FArray;
    SharpDepth : Integer;
end; // type TN_CMSharp1Form = class( TN_BaseForm )

var
  N_CMSharp1Form: TN_CMSharp1Form;

//function K_CMSSharpenDlg( ) : Boolean;

implementation

uses Math,
  K_Gra1,
  N_CompBase, N_Lib1, N_Gra3, N_CMMain5F; //;

{$R *.dfm}

function K_CMSSharpenDlg( ) : Boolean;
begin
  with N_CM_MainForm, CMMFActiveEdFrame,
      TN_CMSharp1Form.Create(Application) do begin
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

procedure TN_CMSharp1Form.TBValChange(Sender: TObject);
begin
  with N_CM_MainForm, CMMFActiveEdFrame do begin
    if (Sender <> nil) and
       ( SkipRebuild                        or
         (PrevValPosition = TBVal.Position) or
         (EdSlide.CMSShowWaitStateFlag and
         (Sender = TBVal)              and
         (csLButtonDown in TControl(Sender).ControlState)) ) then Exit;

    PrevValPosition := TBVal.Position;
    SkipRebuild := TRUE;
    Timer.Enabled := TRUE;
  end;
end;

procedure TN_CMSharp1Form.BtApplyClick(Sender: TObject);
begin
  if SkipApply then Exit;
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

procedure TN_CMSharp1Form.TimerTimer(Sender: TObject);
var
  Base : Integer;
  ConvFactor : Double;
begin
  Timer.Enabled := FALSE;
  with N_CM_MainForm, CMMFActiveEdFrame do begin

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );

    if StartEditing then begin
      StartEditing := FALSE;
      SavedDIB := EdSlide.GetCurrentImage.DIBObj;
      SharpDepth := 13;
      N_CalcGaussMatr( SharpCoefs, SharpDepth, 10.0 );

      NewDIB := TN_DIBObj.Create( SavedDIB );

      SavedDIB.CalcSmoothedMatr( SharpMatr, @SharpCoefs[0], SharpDepth );

    end else begin
      Base := TBVal.Max shr 1;
      ConvFactor := (TBVal.Position - Base) / Base;
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
  end;
//  Application.ProcessMessages; //??
  SkipRebuild := FALSE;
  SkipApply := FALSE;
end;

end.
