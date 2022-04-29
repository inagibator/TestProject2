unit K_FCMSSharpAttrs11;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Comp2, N_Lib2, N_Types, N_Gra2,
  K_CLib0, K_CM0, K_UDT1;

type
  TK_FormCMSSharpAttrs11 = class(TN_BaseForm)
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
    TBRadius: TTrackBar;
    EdRadiusVal: TEdit;
    LbSVal1: TLabel;
    LbSVal3: TLabel;
    LbSVal5: TLabel;
    LbSVal4: TLabel;
    LbSVal2: TLabel;
    LbTimeInfo: TLabel;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TBValChange(Sender: TObject);
    procedure LbEdConvFactorKeyPress(Sender: TObject; var Key: Char);
    procedure TBRadiusChange(Sender: TObject);
    procedure EdRadiusValKeyPress(Sender: TObject; var Key: Char);
    procedure BtOKClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtApplyClick(Sender: TObject);
  private
    { Private declarations }
    SkipRebuild : Boolean;
    SkipApply   : Boolean;
    DoApplyAfter: Boolean;
    DoOKAfter: Boolean;
    ApplyOKWait: Boolean;
    StartEditing: Boolean;
    PrevValPosition : Integer;
    PrevRadiusPosition : Integer;
  public
    { Public declarations }
    SavedDIB : TN_DIBObj;
    NewDIB   : TN_DIBObj;
    EmbDIB1 : TN_DIBObj;
    SharpMatr: TN_BArray;
    SharpRadius : Integer;
    MaxRadius : Integer;
    LSFGamma : TK_LineSegmFunc;
    DIBSmoothProc : TN_DIBObjCalcSmoothedMatr;
  end;

var
  K_FormCMSSharpAttrs11: TK_FormCMSSharpAttrs11;

function K_CMSSharpen11Dlg( ADIBSmoothProc : TN_DIBObjCalcSmoothedMatr ) : Boolean;

implementation

uses Math,
  N_CompBase, N_Lib0, N_Lib1, N_CMMain5F, N_Gra6;

{$R *.dfm}


function K_CMSSharpen11Dlg( ADIBSmoothProc : TN_DIBObjCalcSmoothedMatr ) : Boolean;
begin
  Assert( Assigned(ADIBSmoothProc), 'No ADIBSmoothProc' );

  with N_CM_MainForm, CMMFActiveEdFrame,
      TK_FormCMSSharpAttrs11.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    DIBSmoothProc := ADIBSmoothProc;
    Result := ShowModal() = mrOK;
    with EdSlide.GetCurrentImage do begin
      if SavedDIB <> DIBObj then
        SavedDIB.Free;
      if Result then
      begin
       // Set New DIB to Current Image
        DIBObj.Free;
        DIBObj := NewDIB;
      end
      else
      begin
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
  end;
end;


//***************************************** TK_FormCMSSharpAttrs11.FormShow ***
//  On Form Show Handler
//
procedure TK_FormCMSSharpAttrs11.FormShow(Sender: TObject);
const
  VConvFactor = -30.0;
begin
  SkipRebuild := TRUE;
  SkipApply := TRUE;
  StartEditing := TRUE;

//  TBVal.Position := TBVal.Max shr 1;
  PrevValPosition := TBVal.Max shr 1;
  TBVal.Position := Round( TBVal.Max * (0.5 + VConvFactor / 200) );

  LSFGamma := TK_LineSegmFunc.Create( [0, 1,  2500, 6,  5000, 16,  7500, 66,  10000, 266 ] );

  MaxRadius := 1000;
  SharpRadius := 6;
  TBRadius.Position := Round( LSFGamma.Func2Arg( SharpRadius ) );
  SharpRadius := 3;
  EdRadiusVal.Text := ' 6';
  Timer.Enabled := TRUE;
end; // procedure TK_FormCMSSharpAttrs11.FormShow

//***************************************** TK_FormCMSSharpAttrs11.FormShow ***
//  On Timer Event Handler
//
procedure TK_FormCMSSharpAttrs11.TimerTimer(Sender: TObject);
var
  Base : Integer;
  ConvFactor : Double;
  VConvFactor : Double;
  WSharpRadius : Integer;
begin
  Timer.Enabled := FALSE;

  with N_CM_MainForm, CMMFActiveEdFrame do
  begin

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( TRUE );

    if StartEditing then
    begin
      StartEditing := FALSE;
      SavedDIB := EdSlide.GetCurrentImage.DIBObj;
      with SavedDIB.DIBSize do
      MaxRadius := Round( Min(X,Y) / 4 ) - 1;
      NewDIB := TN_DIBObj.Create( SavedDIB );
    end;

  /////////////////////////////
  //  Smoothed Matrix Prepare
  //
    WSharpRadius := Round(LSFGamma.Arg2Func( TBRadius.Position ));
    if (WSharpRadius <> SharpRadius) then
    begin
    // Rebuild Image Smoothed Matrix
      SharpRadius := WSharpRadius;
      LbTimeInfo.Caption := 'Please wait ...';
      LbTimeInfo.Refresh();
      N_T1.Start;
      DIBSmoothProc( SavedDIB, SharpMatr, SharpRadius );
      N_T1.Stop;
//        LbTimeInfo.Caption := N_T1.ToStr( SavedDIB.DIBSize.X * SavedDIB.DIBSize.Y ) +
//                            ' per pixel';
      LbTimeInfo.Caption := '';
    end;
    EdRadiusVal.Text := format( ' %d', [SharpRadius] );
  //
  // end of Smoothed Matrix Prepare
  /////////////////////////////


  ///////////////////////////////////////////
  // Combine Smoothed Matrix with Source DIB
  //
    Base := TBVal.Max shr 1;
    ConvFactor := (TBVal.Position - Base) / Base;
    VConvFactor := ConvFactor * 100;

    if ConvFactor < 0 then
      ConvFactor := ConvFactor * K_CMSharpenMax;

    SavedDIB.CalcLinCombDIB( NewDIB, @SharpMatr[0], ConvFactor );
  //
  // end of Combine Smoothed Matrix with Source DIB
  ///////////////////////////////////////////

  ///////////////////////////////////////////
  //  Rebuild Slide View
  //
    with N_CM_MainForm.CMMFActiveEdFrame do
    begin
      EdSlide.RebuildMapImageByDIB( NewDIB, nil, @EmbDIB1 );
      RFrame.RedrawAllAndShow();
    end;
  //
  // end of Rebuild Slide View
  ///////////////////////////////////////////

    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( FALSE );

    CMMFRefreshActiveEdFrameHistogram( NewDIB );
  end; // with N_CM_MainForm, CMMFActiveEdFrame do



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

end; // procedure TK_FormCMSSharpAttrs11.TimerTimer

//***************************************** TK_FormCMSSharpAttrs11.FormShow ***
//  On Sharp/Smooth factor Track Bar value change Handler
//
procedure TK_FormCMSSharpAttrs11.TBValChange(Sender: TObject);
var
  Base : Integer;
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if (Sender <> nil) then
    begin
      Base := TBVal.Max shr 1;
      LbEdConvFactor.Text := format( '%6.1f', [(TBVal.Position - Base) / Base * 100] );
{
      if SkipRebuild                      or
         (PrevValPosition = TBVal.Position) or
         (EdSlide.CMSShowWaitStateFlag and
         (Sender = TBVal)              and
         (csLButtonDown in TControl(Sender).ControlState)) then Exit;
}
      if SkipRebuild                      or
         (PrevValPosition = TBVal.Position) then Exit;
    end;

    PrevValPosition := TBVal.Position;
    SkipRebuild := TRUE;
    Timer.Enabled := TRUE;
  end;
end; // procedure TK_FormCMSSharpAttrs11.TBValChange

//***************************************** TK_FormCMSSharpAttrs11.FormShow ***
//  On Sharp/Smooth factor Value Key Press Handler
//
procedure TK_FormCMSSharpAttrs11.LbEdConvFactorKeyPress(Sender: TObject;
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

end; // procedure TK_FormCMSSharpAttrs11.LbEdConvFactorKeyPress

//***************************************** TK_FormCMSSharpAttrs11.FormShow ***
//  On Radius Track Bar value change Handler
//
procedure TK_FormCMSSharpAttrs11.TBRadiusChange(Sender: TObject);
var
  IRadius : Integer;
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if (Sender <> nil) then
    begin
      IRadius := Round(LSFGamma.Arg2Func( TBRadius.Position ));
      if IRadius > MaxRadius then
        TBRadius.Position := Round( LSFGamma.Func2Arg( MaxRadius ) );
      EdRadiusVal.Text := format( ' %d',
                    [Round(LSFGamma.Arg2Func( TBRadius.Position ))] );
      if SkipRebuild                          or
         (PrevRadiusPosition = TBRadius.Position) or
         (EdSlide.CMSShowWaitStateFlag and
         (Sender = TBRadius)            and
         (csLButtonDown in TControl(Sender).ControlState)) then Exit;
    end;

    PrevRadiusPosition := TBRadius.Position;
    SkipRebuild := TRUE;
    Timer.Enabled := TRUE;
  end;
end; // procedure TK_FormCMSSharpAttrs11.TBRadiusChange

//***************************************** TK_FormCMSSharpAttrs11.FormShow ***
//  On Radius value Key Press Handler
//
procedure TK_FormCMSSharpAttrs11.EdRadiusValKeyPress(Sender: TObject;
  var Key: Char);
var
  IRadius : Double;
begin
  if (Key <> Chr(VK_RETURN)) or SkipRebuild  then Exit;
  SkipRebuild := TRUE;
  IRadius := StrToIntDef( Trim(EdRadiusVal.Text), SharpRadius );
  if IRadius > MaxRadius then
    IRadius := MaxRadius;
  TBRadius.Position := Round( LSFGamma.Func2Arg( IRadius ) );

  Timer.Enabled := TRUE;

end; // procedure TK_FormCMSSharpAttrs11.EdRadiusValKeyPress

//***************************************** TK_FormCMSSharpAttrs11.FormShow ***
//  On Button OK Click Handler
//
procedure TK_FormCMSSharpAttrs11.BtOKClick(Sender: TObject);
var
  VKR : Char;
begin

  if not ApplyOKWait then
  begin
    VKR := Chr(VK_RETURN);
    LbEdConvFactorKeyPress( Sender, VKR );
  end;
  DoOKAfter := ApplyOKWait;

end; // procedure TK_FormCMSSharpAttrs11.BtOKClick

//***************************************** TK_FormCMSSharpAttrs11.FormShow ***
//  On Form Close Query Handler
//
procedure TK_FormCMSSharpAttrs11.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not DoOKAfter;
end; // procedure TK_FormCMSSharpAttrs11.FormCloseQuery

//***************************************** TK_FormCMSSharpAttrs11.FormShow ***
//  On Button Apply Click Handler
//
procedure TK_FormCMSSharpAttrs11.BtApplyClick(Sender: TObject);
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

    DIBSmoothProc( SavedDIB, SharpMatr, SharpRadius );


//    if EdSlide.CMSShowWaitStateFlag then
      CMMFShowHideWaitState( FALSE );
  end;

//  TBValChange(nil);
  TBVal.Position := TBVal.Max shr 1;
  PrevValPosition := TBVal.Position;
//??  Application.ProcessMessages;
  SkipApply := FALSE;
end; // procedure TK_FormCMSSharpAttrs11.BtApplyClick

end.
