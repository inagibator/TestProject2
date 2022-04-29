unit K_FCMSSharpAttrs1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_BaseF, N_Comp2, N_Lib2, N_Types, N_Gra2,
  K_CLib0, K_CM0, K_UDT1;

type
  TK_FormCMSSharpAttrs1 = class(TN_BaseForm)
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
    SharpRadius : Integer;
    VSigma : Double;
    LSFGamma : TK_LineSegmFunc;
    ResConvFactor : Double;
    TimeAsString: string;
  end;

var
  K_FormCMSSharpAttrs1: TK_FormCMSSharpAttrs1;

procedure N_TmpMedianCT     ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ACMDim: integer );
procedure N_TmpMedianSlow1  ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpAverageSlow1 ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpAverageSlow2 ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpEmptySlow1   ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpAverageFastV ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ACMDim: integer );
procedure N_TmpCopy1        ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );
procedure N_TmpCopy2        ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; ARadius: integer );

function K_CMSSharpen1Dlg  ( ) : Boolean;

implementation

uses Math,
  N_Gra3,
  N_CompBase, N_Lib0, N_Lib1, N_CMMain5F, N_Gra6; //, N_Gra7;

{$R *.dfm}

//*************************** TK_FormCMSSharpAttrs1 Event Handlers *****

procedure TK_FormCMSSharpAttrs1.FormShow( Sender: TObject );
begin
  SkipRebuild := TRUE;
  SkipApply := TRUE;
  StartEditing := TRUE;

  TBVal.Position := TBVal.Max shr 1;
  PrevValPosition := TBVal.Position;

  LSFGamma := TK_LineSegmFunc.Create( [0, 0.1,  2500, 0.5,  5000, 1.5,  7500, 5,  10000, 20 ] );
  VSigma := 10;
  TBSigma.Position := Round( LSFGamma.Func2Arg( VSigma ) );
  EdSigmaVal.Text := format( '%6.2f', [VSigma] );

  SharpRadius := 2;
  with cbRadius do
    ItemIndex := Items.IndexOf(IntToStr(SharpRadius));

  CmBSmoothType.ItemIndex := 0;
  PrevSmoothTypeIndex := -1;

  Timer.Enabled := TRUE;
end; // procedure TK_FormCMSSharpAttrs1.FormShow

procedure TK_FormCMSSharpAttrs1.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
begin
  CanClose := not DoOKAfter;
end; // procedure TK_FormCMSSharpAttrs1.FormCloseQuery

procedure TK_FormCMSSharpAttrs1.TimerTimer( Sender: TObject );
var
  Base : Integer;
  ConvFactor : Double;
  VConvFactor : Double;
  WSigma : Double;
  WSharpRadius : Integer;
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

      N_T1.Start;
      if CmBSmoothType.ItemIndex <= 0 then
        N_CalcGaussMatr( SharpCoefs, 2*SharpRadius+1, VSigma );
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

        N_T1.Start;
        if CmBSmoothType.ItemIndex <= 0 then
          N_CalcGaussMatr( SharpCoefs, 2*SharpRadius+1, VSigma );
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
      SavedDIB.CalcLinCombDIB( NewDIB, @SharpMatr[0], ConvFactor );

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
  end;

  LbEdConvFactor.Text := format( '%6.1f', [VConvFactor] );

end; // procedure TK_FormCMSSharpAttrs1.TimerTimer

procedure TK_FormCMSSharpAttrs1.TBValChange( Sender: TObject );
var
  Base : Integer;
begin
  with N_CM_MainForm, CMMFActiveEdFrame do
  begin
    if (Sender <> nil) then
    begin
      Base := TBVal.Max shr 1;
      LbEdConvFactor.Text := format( '%6.1f', [(TBVal.Position - Base) / Base * 100] );

      if SkipRebuild                      or
         (PrevValPosition = TBVal.Position) then Exit;
    end;

    PrevValPosition := TBVal.Position;
    SkipRebuild := TRUE;
    Timer.Enabled := TRUE;
  end;
end; // procedure TK_FormCMSSharpAttrs1.TBValChange


procedure TK_FormCMSSharpAttrs1.BtApplyClick( Sender: TObject );
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

procedure TK_FormCMSSharpAttrs1.bnSaveClick( Sender: TObject );
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

procedure TK_FormCMSSharpAttrs1.BtOKClick( Sender: TObject );
var
  VKR : Char;
begin

  if not ApplyOKWait then
  begin
    VKR := Chr(VK_RETURN);
    LbEdConvFactorKeyPress( Sender, VKR );
  end;
  DoOKAfter := ApplyOKWait;
end; // procedure TK_FormCMSSharpAttrs1.BtOKClick

procedure TK_FormCMSSharpAttrs1.TBSigmaChange( Sender: TObject );
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

procedure TK_FormCMSSharpAttrs1.cbRadiusChange( Sender: TObject );
begin
  if (Sender <> nil) and SkipRebuild then Exit;

  SkipRebuild := TRUE;
  Timer.Enabled := TRUE;
end; // procedure TK_FormCMSSharpAttrs1.CmBDepthChange

procedure TK_FormCMSSharpAttrs1.EdSigmaValKeyPress( Sender: TObject; var Key: Char );
var
  WSigma : Double;
begin
  if (Key <> Chr(VK_RETURN)) or SkipRebuild  then Exit;
  SkipRebuild := TRUE;
  WSigma := StrToFloatDef( Trim(EdSigmaVal.Text), VSigma );
  TBSigma.Position := Round( LSFGamma.Func2Arg( WSigma ) );

  Timer.Enabled := TRUE;
end; // procedure TK_FormCMSSharpAttrs1.EdSigmaValKeyPress

procedure TK_FormCMSSharpAttrs1.LbEdConvFactorKeyPress( Sender: TObject; var Key: Char );
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

procedure TK_FormCMSSharpAttrs1.DIBObjCalcSmoothedMatr();
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
  else // Empty Slow1, a precaution
    N_TmpEmptySlow1( SavedDIB, SharpMatr, SharpRadius );
  end;
end; // procedure TK_FormCMSSharpAttrs1.DIBObjCalcSmoothedMatr


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

function K_CMSSharpen1Dlg( ): Boolean;
begin
  with N_CM_MainForm, CMMFActiveEdFrame,
      TK_FormCMSSharpAttrs1.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
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
    LSFGamma.Free;
  end;
end; // function K_CMSSharpen1Dlg

end.
