unit K_FCMSharpSmooth;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Comp2, N_Lib2, N_Types, N_Gra2,
  K_CM0, K_UDT1;

type
  TK_FormCMSharpSmooth = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK    : TButton;
    TBPower: TTrackBar;
    TBBound: TTrackBar;
    BtReset: TButton;
    Timer: TTimer;
    LbEdConvFactor: TLabeledEdit;
    LbPower: TLabel;
    LbBound: TLabel;
    LbEdBound: TLabeledEdit;
    ChBAuto: TCheckBox;
    LbSharp: TLabel;
    LbSmooth: TLabel;
    procedure TBPowerChange(Sender: TObject);
    procedure TBBoundChange(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure BtResetClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure LbEdConvFactorKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure ChBAutoClick(Sender: TObject);
  private
    { Private declarations }
    SkipRebuild : Boolean;
    DoResetAfter: Boolean;
    DoOKAfter: Boolean;
    DoAuto: Boolean;
    ResetOKWait: Boolean;
    StartEditing: Boolean;
    ChangeSharpDepth: Boolean;
    PrevPowerPosition : Integer;
    PrevBoundPosition : Integer;
    function GetBoundTBPosition( ABound : Integer ) : Integer;
    procedure TrackBarChangeRedraw();
  public
    { Public declarations }
    SavedDIB : TN_DIBObj;
    NewDIB   : TN_DIBObj;
    EmbDIB1 : TN_DIBObj;
    SharpMatr: TN_BArray;
//    SharpCoefs: TN_FArray;
    SharpFactor: Double;
    SharpDepth : Integer;
    SharpAutoDepth  : Boolean;
    SharpFlag  : Boolean;
    procedure CurStateToMemIni   (); override;
    procedure MemIniToCurState   (); override;
  end;

var
  K_FormCMSharpSmooth: TK_FormCMSharpSmooth;

function K_CMSSharpSmoothDlg( ASharpFlag : Boolean ) : Boolean;

implementation

uses Math,
  K_CLib0, K_VFunc,
  N_Lib0, N_CompBase, N_Lib1, N_CMMain5F, N_Gra6;

{$R *.dfm}
var DepthArray : array [0..8] of Integer = (7,9,11,13,17,21,29,37,51);

//****************************************************** K_CMSSharpSmoothDlg ***
// Image Sharpen/Smoothen Processing Dialog
//
//     Parameters
// ASharpFlag - if =TRUE then Image Sharpen wil be done, Smoothen else
// Result - Return TRUE if Image adjust was done
//
function K_CMSSharpSmoothDlg( ASharpFlag : Boolean ) : Boolean;
begin
  with N_CM_MainForm, CMMFActiveEdFrame,
      TK_FormCMSharpSmooth.Create(Application) do
  begin
//    BaseFormInit( nil );
    SharpFlag := ASharpFlag;
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    SkipRebuild := TRUE;
    TBPower.Position := Round( TBPower.Max * SharpFactor );
    PrevPowerPosition := TBPower.Position;
    TBBound.Position := K_IndexOfIntegerInRArray( SharpDepth, @DepthArray[0], Length(DepthArray) );
    PrevBoundPosition := TBBound.Position;
    ChBAuto.Checked := SharpAutoDepth;
    StartEditing := TRUE;
    ChangeSharpDepth := TRUE;
    Timer.Enabled := TRUE;
    LbEdBound.EditLabel.Caption := '';
    LbEdConvFactor.EditLabel.Caption := '';
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
end; // function K_CMSSharpSmoothDlg

//******************************************** TK_FormCMSharpSmooth.TBPowerChange ***
//  TBPowerChange Handler
//
procedure TK_FormCMSharpSmooth.TBPowerChange(Sender: TObject);
begin
  if (Sender <> nil) and
     ( SkipRebuild                        or
       (PrevPowerPosition = TBPower.Position) ) then Exit;
  SharpFactor := TBPower.Position / TBPower.Max;
  LbEdConvFactor.Text := format( '%4.2f', [SharpFactor] );
//  if (Sender = TBPower) and
//     (csLButtonDown in TControl(Sender).ControlState) then Exit;
  PrevPowerPosition := TBPower.Position;
  SkipRebuild := TRUE;
  if K_CMSkipMouseMoveRedraw > 0 then
  begin
    K_CMRedrawObject.Redraw();
    SkipRebuild := FALSE;
  end
  else
    Timer.Enabled := TRUE;
end; // procedure TK_FormCMSharpSmooth.TBPowerChange

//******************************************** TK_FormCMSharpSmooth.TBBoundChange ***
//  TBBoundChange Handler
//
procedure TK_FormCMSharpSmooth.TBBoundChange(Sender: TObject);
begin
  if (Sender <> nil) and
     ( SkipRebuild     or
       SharpAutoDepth  or
       ((PrevBoundPosition = TBBound.Position) and
        not (csLButtonDown in TControl(Sender).ControlState))) then Exit;
  SharpDepth := DepthArray[TBBound.Position];
  LbEdBound.Text := format( '%2d', [SharpDepth] );
  if (Sender = TBBound) and
     (csLButtonDown in TControl(Sender).ControlState) then Exit;
  SkipRebuild := TRUE;
  PrevBoundPosition := TBBound.Position;
  ChangeSharpDepth := TRUE;
  Timer.Enabled := TRUE;
end; // procedure TK_FormCMSharpSmooth.TBBoundChange

//******************************************** TK_FormCMSharpSmooth.BtOKClick ***
//  BtOKClick Handler
//
procedure TK_FormCMSharpSmooth.BtOKClick(Sender: TObject);
//var
//  VKR : Char;
begin
{
  if not ResetOKWait then
  begin
    VKR := Chr(VK_RETURN);
    LbEdConvFactorKeyPress( Sender, VKR );
  end;
}
  DoOKAfter := ResetOKWait;

end; // procedure TK_FormCMSharpSmooth.BtOKClick

//******************************************** TK_FormCMSharpSmooth.BtResetClick ***
//  BtResetClick Handler
//
procedure TK_FormCMSharpSmooth.BtResetClick(Sender: TObject);
begin
  DoResetAfter := ResetOKWait;
  if DoResetAfter then Exit;
  SkipRebuild := TRUE;
  ChBAuto.Checked := FALSE;
  SharpFactor := 0.0;
  SharpDepth := 17;

  TBPower.Position := Round( TBPower.Max * SharpFactor );
  PrevPowerPosition := TBPower.Position;
  TBBound.Position := K_IndexOfIntegerInRArray( SharpDepth, @DepthArray[0], Length(DepthArray) );
  PrevBoundPosition := TBBound.Position;

  Timer.Enabled := TRUE;
end;

//******************************************** TK_FormCMSharpSmooth.TimerTimer ***
//  TimerTimer Handler
//
procedure TK_FormCMSharpSmooth.TimerTimer(Sender: TObject);
//var
//  ConvFactor : Double;
//  WDepth : Integer;
begin
  Timer.Enabled := FALSE;
//  SkipRebuild := TRUE;
{
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );

    if StartEditing then
    begin
      StartEditing := FALSE;
      SavedDIB := EdSlide.GetCurrentImage.DIBObj;
      NewDIB := TN_DIBObj.Create( SavedDIB );
    end;

    if SharpAutoDepth then
    begin
      WDepth := K_CMSelectFilterApertureByResolution( EdSlide.P.CMSDB.PixPermm, 1 );
      if WDepth <> SharpDepth then
      begin
        SharpDepth := WDepth;
        ChangeSharpDepth := TRUE;
      end;
    end;

    if ChangeSharpDepth then
    begin
      ChangeSharpDepth := FALSE;
      N_ConvDIBToArrAverageFast1( SavedDIB, SharpMatr, SharpDepth );
    end;

    ConvFactor := SharpFactor;
    if SharpFlag then
      ConvFactor := - ConvFactor * K_CMSharpenMax;

  //  Convert by Sharpen Filter
    SavedDIB.CalcLinCombDIB( NewDIB, @SharpMatr[0], ConvFactor );

  //  Rebuild Slide View
    with N_CM_MainForm.CMMFActiveEdFrame do begin
      EdSlide.RebuildMapImageByDIB( NewDIB, nil, @EmbDIB1 );
      RFrame.RedrawAllAndShow();
    end;

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( FALSE );
    N_CM_MainForm.CMMFRefreshActiveEdFrameHistogram( NewDIB );
  end;
//  Application.ProcessMessages; //??
  LbEdConvFactor.Text := format( '%4.2f', [SharpFactor] );
  TBBound.Position := GetBoundTBPosition( SharpDepth );
  LbEdBound.Text := format( '%2d', [SharpDepth] );

  SkipRebuild := FALSE;
  ResetOKWait := FALSE;
}
  TrackBarChangeRedraw();
  
  if DoResetAfter then
  begin
    DoResetAfter := FALSE;
    BtResetClick(Sender);
  end;

  if DoOKAfter then
  begin
    DoOKAfter := FALSE;
    ModalResult := mrOK;
  end;

  if DoAuto then
  begin
    DoAuto := FALSE;
    ChBAutoClick(Sender);
  end;

end; // procedure TK_FormCMSharpSmooth.TimerTimer

//******************************************** TK_FormCMSharpSmooth.LbEdConvFactorKeyPress ***
//  LbEdConvFactorKeyPress Handler
//
procedure TK_FormCMSharpSmooth.LbEdConvFactorKeyPress(Sender: TObject;
  var Key: Char);
var
  VConvFactor : Double;
  NPos : Integer;
begin
  if Key <> Chr(VK_RETURN) then Exit;
  VConvFactor :=  0.5;
  VConvFactor := StrToFloatDef( Trim(LbEdConvFactor.Text), VConvFactor);
  VConvFactor := Max(0.0, VConvFactor);
  VConvFactor := Min(1.0, VConvFactor);
  LbEdConvFactor.Text := format( '%4.2f', [VConvFactor] );
  NPos := Round( TBPower.Max * VConvFactor );

  if NPos <> TBPower.Position then
  begin
    ResetOKWait := TRUE;
    TBPower.Position := NPos;
  end;

end; // procedure TK_FormCMSharpSmooth.LbEdConvFactorKeyPress

//************************************** TK_FormCMSharpSmooth.FormCloseQuery ***
//  FormCloseQuery Handler
//
procedure TK_FormCMSharpSmooth.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not DoOKAfter;
end; // procedure TK_FormCMSharpSmooth.FormCloseQuery

//******************************************** TK_FormCMSharpSmooth.FormShow ***
//  FormShow Handler
//
procedure TK_FormCMSharpSmooth.FormShow(Sender: TObject);
begin
  if SharpFlag then
    Caption := LbSharp.Caption
  else
    Caption := LbSmooth.Caption;
  K_CMRedrawObject.InitRedraw( TrackBarChangeRedraw );
end; // procedure TK_FormCMSharpSmooth.FormShow

//******************************************** TK_FormCMSharpSmooth.ChBAutoClick ***
//  ChBAutoClick Handler
//
procedure TK_FormCMSharpSmooth.ChBAutoClick(Sender: TObject);
var
  {ID, IDM, i,} Ind : Integer;

begin
  SharpAutoDepth := ChBAuto.Checked;
  TBBound.Enabled := not SharpAutoDepth;
  if not SharpAutoDepth then
  begin
  // Get Closest Allowed Value
    Ind := GetBoundTBPosition( SharpDepth );
{
    Ind := 0;
    IDM := Abs(DepthArray[0] - SharpDepth);
    for i := 1 to High(DepthArray) do
    begin
      ID := Abs(DepthArray[i] - SharpDepth);
      if ID < IDM then
      begin
        IDM := ID;
        Ind := i;
      end;
    end;
}
    TBBound.Position := Ind;
    if SharpDepth = DepthArray[Ind] then Exit;
    SharpDepth := DepthArray[Ind];
  end;
  DoAuto := ResetOKWait;
  if SkipRebuild  then Exit;
  Timer.Enabled := TRUE;
end; // procedure TK_FormCMSharpSmooth.ChBAutoClick

//******************************************** TK_FormCMSharpSmooth.CurStateToMemIni ***
//
procedure TK_FormCMSharpSmooth.CurStateToMemIni;
begin
  N_IntToMemIni( BFSelfName + N_B2S(SharpFlag), 'Bound', SharpDepth );
  N_DblToMemIni( BFSelfName + N_B2S(SharpFlag), 'Power', '%g', SharpFactor );
  N_BoolToMemIni( BFSelfName + N_B2S(SharpFlag), 'Auto', SharpAutoDepth );
  inherited;
end; // procedure TK_FormCMSharpSmooth.CurStateToMemIni

//******************************************** TK_FormCMSharpSmooth.MemIniToCurState ***
//
procedure TK_FormCMSharpSmooth.MemIniToCurState;
begin
  inherited;
  SharpDepth := N_MemIniToInt( BFSelfName + N_B2S(SharpFlag), 'Bound', 17 );
  SharpFactor:= N_MemIniToDbl( BFSelfName + N_B2S(SharpFlag), 'Power', 0 );
  SharpAutoDepth := N_MemIniToBool( BFSelfName + N_B2S(SharpFlag), 'Auto', FALSE );
end; // procedure TK_FormCMSharpSmooth.MemIniToCurState

//******************************************** TK_FormCMSharpSmooth.GetBoundTBPosition ***
//
function TK_FormCMSharpSmooth.GetBoundTBPosition( ABound: Integer): Integer;
var
  ID, IDM, i : Integer;
begin
    Result := 0;
    IDM := Abs(DepthArray[0] - ABound);
    for i := 1 to High(DepthArray) do
    begin
      ID := Abs(DepthArray[i] - ABound);
      if ID < IDM then
      begin
        IDM := ID;
        Result := i;
      end;
    end;
end; // function TK_FormCMSharpSmooth.GetBoundTBPosition

//******************************* TK_FormCMSharpSmooth.TrackBarChangeRedraw ***
// On change Redraw
//
procedure TK_FormCMSharpSmooth.TrackBarChangeRedraw;
var
  ConvFactor : Double;
  WDepth : Integer;
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );

    if StartEditing then
    begin
      StartEditing := FALSE;
      SavedDIB := EdSlide.GetCurrentImage.DIBObj;
      NewDIB := TN_DIBObj.Create( SavedDIB );
    end;

    if SharpAutoDepth then
    begin
      WDepth := K_CMSelectFilterApertureByResolution( EdSlide.P.CMSDB.PixPermm, 1 );
      if WDepth <> SharpDepth then
      begin
        SharpDepth := WDepth;
        ChangeSharpDepth := TRUE;
      end;
    end;

    if ChangeSharpDepth then
    begin
      ChangeSharpDepth := FALSE;
      N_ConvDIBToArrAverageFast1( SavedDIB, SharpMatr, SharpDepth );
    end;

    ConvFactor := SharpFactor;
    if SharpFlag then
      ConvFactor := - ConvFactor * K_CMSharpenMax;

  //  Convert by Sharpen Filter
    SavedDIB.CalcLinCombDIB( NewDIB, @SharpMatr[0], ConvFactor );

  //  Rebuild Slide View
    with N_CM_MainForm.CMMFActiveEdFrame do begin
      EdSlide.RebuildMapImageByDIB( NewDIB, nil, @EmbDIB1 );
      RFrame.RedrawAllAndShow();
    end;

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( FALSE );
    N_CM_MainForm.CMMFRefreshActiveEdFrameHistogram( NewDIB );
  end;
//  Application.ProcessMessages; //??
  LbEdConvFactor.Text := format( '%4.2f', [SharpFactor] );
  TBBound.Position := GetBoundTBPosition( SharpDepth );
  LbEdBound.Text := format( '%2d', [SharpDepth] );

  SkipRebuild := FALSE;
  ResetOKWait := FALSE;

end; // procedure TK_FormCMSharpSmooth.TrackBarChangeRedraw

end.
