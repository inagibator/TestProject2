unit N_RastFrOpF;
// TN_Rast1Frame Options Form

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, Contnrs,
  N_Lib0, N_Lib1, N_Types, N_Rast1Fr, N_FNameFr, N_BaseF, N_ColViewFr, ActnList,
  Menus;

type TN_RFrameOptionsForm = class( TN_BaseForm )
    bnApply: TButton;
    bnCancel: TButton;
    bnOk: TButton;
    PageControl: TPageControl;
    tsCoords: TTabSheet;
    edBuferSize: TLabeledEdit;
    edSrcPRect: TLabeledEdit;
    edLogFrameRect: TLabeledEdit;
    edVisibleUCoords: TLabeledEdit;
    tsAux: TTabSheet;
    Label11: TLabel;
    mbSCType: TComboBox;
    cbShowPixelColor: TCheckBox;
    cbCenterInDst: TCheckBox;
    TabSheet1: TTabSheet;
    Label14: TLabel;
    mbBuferColors: TComboBox;
    rgMouseMoveAction: TRadioGroup;
    tsFile: TTabSheet;
    tsAdjIUC: TTabSheet;
    bnPS8: TButton;
    bnPS0: TButton;
    bnPS1: TButton;
    bnPS9: TButton;
    bnPS2: TButton;
    bnPS10: TButton;
    Tmp2: TTabSheet;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    edOrigin: TEdit;
    edStep: TEdit;
    bnPS12: TButton;
    bnPS4: TButton;
    bnPS5: TButton;
    bnPS13: TButton;
    bnPS6: TButton;
    bnPS14: TButton;
    bnPS7: TButton;
    bnPS15: TButton;
    Label1: TLabel;
    Label2: TLabel;
    PSTimer: TTimer;
    bnPS3: TButton;
    bnPS11: TButton;
    cbMaintainAspect: TCheckBox;
    bnAspCoefEq1: TButton;
    edAspectCoef: TEdit;
    bnEditU2P: TButton;
    edResizeFlags: TLabeledEdit;
    tsDeb: TTabSheet;
    edDebugFlags: TLabeledEdit;
    bnSetCapture: TButton;
    frFileName: TN_FileNameFrame;
    GroupBox1: TGroupBox;
    edMetafilePix: TLabeledEdit;
    edMetafileDPI: TLabeledEdit;
    edMetafileSm: TLabeledEdit;
    bnSaveToFile: TButton;
    bnCopyToClipboard: TButton;
    cbWholeBuf: TCheckBox;
    cbAutoRename: TCheckBox;
    mbImageFormat: TComboBox;
    edTranspColor: TLabeledEdit;
    StaticText1: TStaticText;
    cbCenterInSrc: TCheckBox;
    edPaintBoxSize: TLabeledEdit;
    frBackColor: TN_ColorViewFrame;
    bnDebActions: TButton;
    DebActPopupMenu: TPopupMenu;
    ActionList: TActionList;
    aDebViewRFActions: TAction;
    ViewRastrFrActions1: TMenuItem;
    edFormSelfName: TLabeledEdit;
    edBufCompSize: TLabeledEdit;
    BFMinBRPanel2: TPanel;
//    procedure FormShow      ( Sender: TObject );

      //**************** Bottom Buttons event handlers
    procedure bnApplyClick  ( Sender: TObject );
    procedure bnCancelClick ( Sender: TObject );
    procedure bnOkClick     ( Sender: TObject );

      //******************* File TabSheet event handlers
    procedure edMetafilePixKeyDown ( Sender: TObject; var Key: Word;
                                                      Shift: TShiftState );
    procedure edMetafileSmKeyDown  ( Sender: TObject; var Key: Word;
                                                      Shift: TShiftState );
    procedure SaveCopyToClick      ( Sender: TObject );

      //******************* Adjust IUC TabSheet event handlers
    procedure bnEditU2PClick ( Sender: TObject );
    procedure bnPSMouseDown  ( Sender: TObject; Button: TMouseButton;
                                       Shift: TShiftState; X, Y: Integer );
    procedure bnPSMouseUp    ( Sender: TObject; Button: TMouseButton;
                                       Shift: TShiftState; X, Y: Integer );
    procedure PSTimerTimer      ( Sender: TObject );
    procedure bnAspCoefEq1Click ( Sender: TObject );

      //******************* Deb TabSheet event handlers
    procedure bnSetCaptureClick ( Sender: TObject );

      //******************* Other Handlers *******************
    procedure edFrameSizeDblClick      ( Sender: TObject );
    procedure mbSCTypeCloseUp          ( Sender: TObject );
    procedure aDebViewRFActionsExecute ( Sender: TObject );

    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  public
    RFrame: TN_Rast1Frame; // this field should be set before Form showing!
    PSState: integer;
    PSTag: integer;

    procedure SetFormFields    ();
    procedure PSChangeUCoords  ();
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_RFrameOptionsForm = class( TN_BaseForm )

    //************* Global procedures **********************

function N_CreateRFrameOptionsForm( ARFrame: TN_Rast1Frame;
                                AOwner: TN_BaseForm ): TN_RFrameOptionsForm;

implementation
uses
  K_Clib,
  N_Gra0, N_Gra1, N_Gra2, N_AffC4F, N_LibF, N_MsgDialF, N_InfoF; // K_FDTE, 

{$R *.DFM}

var
  CoordsTypeNames: Array [0..6] of string = ( 'Parent User', 'Parent LSU',
        'Parent mm', 'Parent Pix', 'Parent Percents', 'Dst Pix', 'Dst mm' );

//****************  TN_RFrameOptionsForm class methods  ******************
{
procedure TN_RFrameOptionsForm.FormShow( Sender: TObject );
// OnShow event hadler - set Form fields by theirs Frame values
// (Form initialization)
var
  A, NX, NY, NDPI: integer;
  Fmt: string;
  TmpURect: TFRect;
begin
  with RFrame do
  begin
//**********  Coords TabSheet *************

  with RFSrcPRect do
    edVisibleRect.Text := Format( ' %d %d  %d %d',
                                            [Left, Top, Right, Bottom] );

    edBuferSize.Text := Format( ' %d  %d', [OCanv.CCRSize.X, OCanv.CCRSize.Y] );
    A := RFrame.UCAccuracyFmt + 1;
    Fmt := '%' + Format( '.%df ', [A] );
    edFullUCoords.Text := N_RectToStr( RFrame.OCanvMaxURect, Fmt );

    TmpURect := N_AffConvI2FRect2( RFSrcPRect, OCanv.P2U );
    edVisibleUCoords.Text := N_RectToStr( TmpURect, Fmt );
    edAspectCoef.Text := Format( ' %.5f', [RFrame.AspectCoef] );

//**********  File TabSheet *************

   NX := N_RectWidth(  RFSrcPRect );
   NY := N_RectHeight( RFSrcPRect );
   edMetafilePix.Text := Format( ' %d %d', [NX, NY] );
   NDPI := GetDeviceCaps( Canvas.Handle, LOGPIXELSX );
   edMetafileDPI.Text := IntToStr( NDPI );
   edMetafileSm.Text := Format( ' %5.2f %5.2f', [NX*2.54/NDPI, NY*2.54/NDPI] );

  end; // with RFrame.RBuf do

  with RFrame do
  begin
  edOrigin.Text := N_PointToStr( CCUserSGridOrigin, Fmt );
  edStep.Text   :=  N_PointToStr( CCUserSGridStep, Fmt );

//**********  View TabSheet *************

  case ShowCoordsType of
  sctPixelCoords: mbSCType.ItemIndex := 0;
  sctUserCoords:  mbSCType.ItemIndex := 1;
  sctApplCoords:  mbSCType.ItemIndex := 2;
  end;

  edUAccFmt.Text := IntToStr( UCAccuracyFmt );
  edAAccFmt.Text := IntToStr( ACAccuracyFmt );

  cbShowPixelColor.Checked := ShowPixelColor;
//  cbCenterInDst.Checked := RBuf.CenterInDst;

  edResizeFlags.Text := IntToStr( ResizeFlags );

//**********  Aux TabSheet *************

  case OCanv.CPixFmt of
  pf16bit: mbBuferColors.ItemIndex := 0;
  pf32bit: mbBuferColors.ItemIndex := 1;
  end; // case OCanv.CPixFmt of
}
{
  case OCanv.GDIType of
  WinGDI:    mbGDIType.ItemIndex := 0;
  DelphiGDI: mbGDIType.ItemIndex := 1;
  end; // case RBuf.MainBuf.OCanv.GDIType of

  edPTolerance.Text := IntToStr( PTolerance );
  if DefNeededAction = 0 then
    rgMouseMoveAction.ItemIndex := 0
  else if (DefNeededAction and 1) <> 0 then
    rgMouseMoveAction.ItemIndex := 1
  else if (DefNeededAction and 2) <> 0 then
    rgMouseMoveAction.ItemIndex := 2;
}
{
//**********  Deb TabSheet *************

  edDebugFlags.Text := '$' + IntToHex( RFDebugFlags, 4 );

  end; // with RFrame do

end; // end of procedure TN_RFrameEditForm.FormShow
}


procedure TN_RFrameOptionsForm.bnApplyClick( Sender: TObject );
// Apply Button Click - update Frame fields by changed Form values
var
  Str: string;
  MaxDX, MaxDY, VisDX, VisDY: integer;
  TmpPixFmt: TPixelFormat;
begin
  with RFrame do
  begin
//**********  Aux TabSheet *************
  TmpPixFmt := pf32bit; // a precaution
  case mbBuferColors.ItemIndex of
  0: TmpPixFmt := pf16bit;
  1: TmpPixFmt := pf32bit;
  end;

//**********  Coords TabSheet *************
    Str := edBuferSize.Text;
    MaxDX := N_ScanInteger( Str );
    MaxDY := N_ScanInteger( Str );
    OCanv.SetCurCRectSize( MaxDX, MaxDY, TmpPixFmt );

    Str := edSrcPRect.Text;
    RFSrcPRect := N_ScanIRect( Str );

    VisDX := Round(RFRasterScale*N_RectWidth(  RFSrcPRect ));
    VisDY := Round(RFRasterScale*N_RectHeight( RFSrcPRect ));

    ResizeSelf( VisDX, VisDY );

  end; // with RFrame.RBuf do

  with RFrame do
  begin
  Str := edOrigin.Text;
  CCUserSGridOrigin.X := N_ScanDouble( Str );
  CCUserSGridOrigin.Y := N_ScanDouble( Str );

  Str := edStep.Text;
  CCUserSGridStep.X := N_ScanDouble( Str );
  CCUserSGridStep.Y := N_ScanDouble( Str );

//**********  View TabSheet *************

  ShowCoordsType := TN_CompCoordsType(mbSCType.ItemIndex);

//  UCAccuracyFmt := StrToInt( edUAccFmt.Text );
//  ACAccuracyFmt := StrToInt( edAAccFmt.Text );

  ShowPixelColor := cbShowPixelColor.Checked;
  RFCenterInDst  := cbCenterInDst.Checked;
  RFCenterInSrc  := cbCenterInSrc.Checked;
  ResizeFlags    := StrToInt( edResizeFlags.Text );

  OCanvBackColor := frBackColor.edBackColor.Color;

//**********  Deb TabSheet *************

  RFDebugFlags := StrToInt( edDebugFlags.Text );

  RecalcPRects();
  RedrawAllAndShow();

  end; // with RFrame do

  SetFormFields(); // refresh Form fields

end; // end of procedure TN_RFrameEditForm.bnApplyClick

procedure TN_RFrameOptionsForm.bnCancelClick( Sender: TObject );
// Close Self without any changes to Frame (Cancel Button Click)
begin
  Close;
end; // procedure TN_RFrameOptionsForm.bnCancelClick

procedure TN_RFrameOptionsForm.bnOkClick( Sender: TObject );
// Apply all changes and Close (OK Button Click)
begin
  bnApplyClick( Sender );
  Close;
end; // procedure TN_RFrameOptionsForm.bnOkClick

      //******************* File TabSheet event handlers

procedure TN_RFrameOptionsForm.edMetafilePixKeyDown( Sender: TObject;
                                           var Key: Word; Shift: TShiftState);
// Set new Metafile size in Pixels and recalc its size in Cantimeters
var
  NX, NY, NDPI: integer;
  Str: string;
begin
   if Key <> VK_RETURN then Exit;
   with RFrame do
   begin
     Str := edMetafilePix.Text;
     NX := N_ScanInteger( Str );
     NY := N_ScanInteger( Str );
     if NY = N_NotAnInteger then // only NX was given
     begin
       NY := Round(NX * N_RectHeight( RFSrcPRect ) / N_RectWidth( RFSrcPRect ));
       edMetafilePix.Text := Format( ' %d %d', [NX, NY] );
     end;

     Str := edMetafileDPI.Text;
     NDPI := N_ScanInteger( Str );

     edMetafileSm.Text := Format( ' %5.2f %5.2f', [NX*2.54/NDPI, NY*2.54/NDPI] );
   end; // with RFrame.RBuf do
end; // procedure TN_RFrameOptionsForm.edMetafilePixKeyDown

procedure TN_RFrameOptionsForm.edMetafileSmKeyDown( Sender: TObject;
                                           var Key: Word; Shift: TShiftState);
// Set new Metafile size in Santimeters and recalc its size in Pixels
// (also used as edMetafileDPIKeyDown event handler)
var
  NDPI: integer;
  SmX, SmY: double;
  Str: string;
begin
   if Key <> VK_RETURN then Exit;
   with RFrame do
   begin
     Str := edMetafileSm.Text;
     SmX := N_ScanDouble( Str );
     SmY := N_ScanDouble( Str );
     if SmY = N_NotADouble then // only SmX is given
     begin
       SmY := SmX * N_RectHeight( RFSrcPRect ) / N_RectWidth( RFSrcPRect );
       edMetafileSm.Text := Format( ' %5.2f %5.2f', [SmX, SmY] );
     end;

     Str := edMetafileDPI.Text;
     NDPI := N_ScanInteger( Str );

     edMetafilePix.Text := Format( ' %d %d', [Round(SmX*NDPI/2.54),
                                              Round(SmY*NDPI/2.54)] );
   end; // with RFrame.RBuf do
end; // procedure TN_RFrameOptionsForm.edMetafileSmKeyDown

procedure TN_RFrameOptionsForm.SaveCopyToClick( Sender: TObject );
// Copy To Clipboard or Save to File (BMP, GIF, JPG, EMF)
// Visible Part or Whole MainBuf
begin
{
var
  FName, Str: string;
  RectToSave, PixRect, MM01Rect: TRect;
  SmSize: TFPoint;
  TmpMF: TMetafile;
  SaveToFile: boolean;
  ExtRFPar: TN_ExtRastFilePar;
begin
  RFrame.SomeStatusBar.SimpleText := '';
  SaveToFile := False;
  if TButton(Sender).Name = 'bnSaveToFile' then SaveToFile := True;

  FName := 'CLIPBOARD';
  if SaveToFile then
  begin
    FName := frFileName.mbFileName.Text;
    if FileExists(FName) then
    begin
      if cbAutorename.Checked then
        FName := N_CreateUniqueFileName( FName )
      else
        if not N_ConfirmOverwriteDlg( FName ) then Exit;
    end; // if FileExists(FName) then
  end; // if Sender.Name = bnSaveToFile then

  ExtRFPar := N_ZeroERFPar;
  ExtRFPar.ERFTranspColor := StrToInt(edTranspColor.Text);

  with RFrame do
  begin
    if mbImageFormat.ItemIndex = 3 then // Copy or Save Metafile, not Raster
    begin
      Str := edmetafilePix.Text;
      PixRect := IRect( N_ScanIPoint( Str ) );
      Str := edmetafileSm.Text;
      SmSize := N_ScanFPoint( Str );
      MM01Rect := Rect( 0, 0, Round(1000*SmSize.X), Round(1000*SmSize.Y) );
      TmpMF := RedrawAllToMetafile( PixRect, MM01Rect );
      if SaveToFile then TmpMF.SaveToFile( FName )
                    else N_CopyMetafileToClipBoard( TmpMF );
      TmpMF.Free;
    end else //*************************** Copy or Save Raster from MainBuf
    begin
      if cbWholeBuf.Checked then RectToSave := Ocanv.CurCRect
                            else RectToSave := RFSrcPRect;

      RFrame.OCanv.SaveCopyTo( FName, TN_ImageFileFormat(mbImageFormat.ItemIndex+1),
                                                        RectToSave, @ExtRFPar );
    end;

  if SaveToFile then
    SomeStatusBar.SimpleText := 'Saved to File  "' + FName + '"'
  else
    SomeStatusBar.SimpleText := 'Copied to Clipboard';

  end; // with RFrame do
}  
end; // procedure TN_RFrameOptionsForm.bnSaveToFileClick

      //******************* Adjust UC TabSheet event handlers

procedure TN_RFrameOptionsForm.bnEditU2PClick( Sender: TObject );
// Edit U2P coefs.
var
  TmpAffCoefs: TN_AffCoefs4;
  TmpURect: TFRect;
begin
  TmpAffCoefs := RFrame.OCanv.P2U;
  with N_GetAffCoefs4Form( TmpAffCoefs ) do
  begin
    ARFrame := RFrame;
    ApplyProc := N_SetP2UAndRedraw;
    ShowModal;
  end;

  with RFrame do
    TmpURect := N_AffConvI2FRect2( RFSrcPRect, OCanv.P2U );

//  edVisibleUCoords.Text := N_RectToStr( TmpURect,
//                    '%' + Format( '.%df', [RFrame.UCAccuracyFmt+1] ) );
end; // procedure TN_RFrameOptionsForm.bnEditU2PClick

procedure TN_RFrameOptionsForm.bnPSMouseDown( Sender: TObject;
                 Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
// setup timer to enable UCoords changing by timer events
begin
  PSState := 0;
  PSTag := TComponent(Sender).Tag;
  PSTimer.Enabled := True;
  PSTimer.Interval := 250; // wait before repeat time
  PSChangeUCoords();
end; // procedure TN_RFrameOptionsForm.bnPSMouseDown

procedure TN_RFrameOptionsForm.bnPSMouseUp( Sender: TObject;
                 Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
// stop timer to prevent UCoords changing by timer events
begin
  PSTimer.Enabled := False;
end; // procedure TN_RFrameOptionsForm.bnPSMouseUp

procedure TN_RFrameOptionsForm.PSTimerTimer( Sender: TObject );
// chande UCoords according to currently pressed button
// by timer events
begin
  if PSState = 0 then
  begin
    PSTimer.Interval := 55; // repeat time
    PSState := 1;
  end;

  PSChangeUCoords();
end; // procedure TN_RFrameOptionsForm.PSTimerTimer

procedure TN_RFrameOptionsForm.bnAspCoefEq1Click( Sender: TObject );
// set AspectCoef equal to 1
var
  TmpURect: TFRect;
begin
  with RFrame.OCanv do
  begin
    TmpURect := N_AffConvI2FRect2( CurCRect, P2U );
    RFrame.OCanv.OCUserAspect := 1;
    edAspectCoef.Text := Format( ' %.5f', [RFrame.OCanv.OCUserAspect] );
    SetIncCoefsAndUCRect( TmpURect, CurCRect );
  end; // with RFrame.RBuf do
  RFrame.RedrawAllAndShow();
end; // procedure TN_RFrameOptionsForm.bnAspCoefEq1Click


    //***************** Public methods

procedure TN_RFrameOptionsForm.SetFormFields;
// set Form fields by corresponding Frame fields
var
  NX, NY, NDPI: integer;
  BufCSize: TPoint;
  VisibleURect: TFRect;
  FrameParent: TN_BaseForm;
begin
  with RFrame do
  begin
    //**********  Coords TabSheet *************

    // OCanv.CCRSize = SizeOf(OCanv.CRect)
    edBuferSize.Text := Format( ' %d  %d', [OCanv.CCRSize.X, OCanv.CCRSize.Y] );

    // Frame Client Size is PaintBox.Size + SrcrollBars.Size
    edPaintBoxSize.Text := Format( ' %d  %d', [PaintBox.Width, PaintBox.Height] );

    with RFSrcPRect do // Visible Rect in Buf Pixel Coords
      edSrcPRect.Text := Format( ' %d %d  %d %d', [Left,Top,Right,Bottom]);

//    with LogFrameFRect do // Current Whole Component Rect in Buf Pixel Coords
//      edLogFrameRect.Text := Format( ' %.1f  %.1f   %.1f  %.1f', [Left,Top,Right,Bottom]);

    VisibleURect := N_AffConvI2FRect2( RFSrcPRect, OCanv.P2U );
    with VisibleURect do // Currently Visible Rect in User Coords
      edVisibleUCoords.Text := Format( ' %.3f  %.3f   %.3f  %.3f', [Left,Top,Right,Bottom]);

    // BufCSize is BufSize adjusted by Component Aspect
    BufCSize := N_AdjustSizeByAspect( aamDecRect, OCanv.CCRSize, RFObjAspect );
    edBufCompSize.Text := Format( ' %d  %d', [BufCSize.X, BufCSize.Y] );


  //**********  View TabSheet *************

    N_SetMBItems( mbSCType, CoordsTypeNames, Ord(ShowCoordsType), -1 );

//    edUAccFmt.Text := IntToStr( UCAccuracyFmt );
//    edAAccFmt.Text := IntToStr( ACAccuracyFmt );

    cbShowPixelColor.Checked := ShowPixelColor;
    cbCenterInDst.Checked := RFCenterInDst;
    cbCenterInSrc.Checked := RFCenterInSrc;

    edResizeFlags.Text := IntToStr( ResizeFlags );

    frBackColor.SetFields( OCanvBackColor );

  //**********  Aux TabSheet *************

    case OCanv.CPixFmt of
      pf16bit: mbBuferColors.ItemIndex := 0;
      pf32bit: mbBuferColors.ItemIndex := 1;
    end; // case OCanv.CPixFmt of

//**********  File TabSheet *************

    NX := N_RectWidth(  RFSrcPRect );
    NY := N_RectHeight( RFSrcPRect );
    edMetafilePix.Text := Format( ' %d %d', [NX, NY] );
    NDPI := GetDeviceCaps( Canvas.Handle, LOGPIXELSX );
    edMetafileDPI.Text := IntToStr( NDPI );
    edMetafileSm.Text := Format( ' %5.2f %5.2f', [NX*2.54/NDPI, NY*2.54/NDPI] );

    edOrigin.Text := N_PointToStr( CCUserSGridOrigin, PointCoordsFmt );
    edStep.Text   := N_PointToStr( CCUserSGridStep, PointCoordsFmt );

    FrameParent := K_GetOwnerBaseForm( RFrame.Owner );
    if FrameParent <> nil then
      edFormSelfName.Text := FrameParent.BFSelfName
    else
      edFormSelfName.Text := 'N/A';

  //**********  Adjust TabSheet *************
    edAspectCoef.Text := Format( ' %.5f', [RFrame.OCanv.OCUserAspect] );


  //**********  Deb TabSheet *************

    edDebugFlags.Text := '$' + IntToHex( RFDebugFlags, 6 );

  end; // with RFrame do
end; // end of procedure TN_RFrameEditForm.SetFormFields

procedure TN_RFrameOptionsForm.PSChangeUCoords();
begin
{
// Change Initial User Coords (OCanvCurURect) according to PSTag
var
  PSize: integer;
  AAMode: TN_AdjustAspectMode;
  TmpURect: TFRect;
  PixAspect: double;
begin
  if (PSTag and $08) = 0 then PSize := 1
                         else PSize := 8;

  if (PSTag and $01) <> 0 then PSize := -PSize;

  with RFrame, RFrame.OCanv do
  begin

  SetCoefs( OCanvCurURect, CurCRect ); // Set Initial User Coords
  TmpURect := OCanvCurURect;
  PixAspect := N_RectAspect( CurCRect );

  case (PSTag and $06) of

  0: begin // X Position
    TmpURect.Left  := TmpURect.Left  + P2U.CX*PSize;
    TmpURect.Right := TmpURect.Right + P2U.CX*PSize;
  end;

  2: begin // Y Position
    TmpURect.Top    := TmpURect.Top    + P2U.CY*PSize;
    TmpURect.Bottom := TmpURect.Bottom + P2U.CY*PSize;
  end;

  4: begin // X Size
    TmpURect.Right := TmpURect.Right + P2U.CX*PSize;
    if cbMaintainAspect.Checked then
      TmpURect.Bottom := TmpURect.Bottom + P2U.CY*PSize*PixAspect;
  end;

  6: begin // Y Size
    TmpURect.Bottom := TmpURect.Bottom + P2U.CY*PSize;
    if cbMaintainAspect.Checked then
      TmpURect.Right := TmpURect.Right + P2U.CX*PSize/PixAspect;
  end;

  end; // case (PSTag and $06) of

  AAMode := aamNoChange;
  if cbMaintainAspect.Checked then
  begin
    if PSize > 0 then AAMode := aamIncRect
                 else AAMode := aamDecRect;
  end else
    OCUserAspect := N_RectAspect( TmpURect ) / PixAspect;

  edAspectCoef.Text := Format( ' %.5f', [OCUserAspect] );
  N_AdjustRectAspect( AAMode, TmpURect, OCUserAspect*PixAspect );
  OCanvCurURect := TmpURect;
  edVisibleUCoords.Text := N_RectToStr( TmpURect,
                          '%' + Format( '.%df', [RFrame.UCAccuracyFmt+1] ) );
  end; // with RFrame, RFrame.OCanv do

  RFrame.RedrawAllAndShow();
}  
end; // procedure TN_RFrameOptionsForm.PSChangeUCoords

procedure TN_RFrameOptionsForm.bnSetCaptureClick( Sender: TObject );
// set Mouse Capture
var
  OldHWND: integer;
begin
  OldHWND := SetCapture( RFrame.Handle ); // ????
  edDebugFlags.Text := '$' + IntToHex( OldHWND, 6 );
end; // procedure TN_RFrameOptionsForm.bnSetCaptureClick

procedure TN_RFrameOptionsForm.edFrameSizeDblClick( Sender: TObject );
// Change Parent Form Size
var
  NeededPBWidth, NeededPBHeight: integer;
  Str: string;
  FrameParent: TForm;
begin
  Str := edPaintBoxSize.Text;
  NeededPBWidth := N_ScanInteger( Str );
  NeededPBHeight := N_ScanInteger( Str );

  with RFrame do
  begin
    SkipOnResize := True;
    FrameParent := K_GetOwnerForm( Owner );
    FrameParent.Width  := FrameParent.Width  + NeededPBWidth  - PaintBox.Width;
    FrameParent.Height := FrameParent.Height + NeededPBHeight - PaintBox.Height;
    SkipOnResize := False;
  end;
end; // procedure TN_RFrameOptionsForm.edFrameSizeDblClick

procedure TN_RFrameOptionsForm.mbSCTypeCloseUp( Sender: TObject );
// just Close Form after new ShowCoordsType was choosen
begin
  bnOkClick( nil );
end; // procedure TN_RFrameOptionsForm.mbSCTypeCloseUp

procedure TN_RFrameOptionsForm.aDebViewRFActionsExecute( Sender: TObject );
// View RastrFrame Actions
var
  i, j: integer;
  InfoForm: TN_InfoForm;
begin
  InfoForm := N_GetInfoForm();
  with RFrame do
  begin
    for i := 0 to RFSGroups.Count-1 do // along RastrFrame SearchGroups
    with TN_SGBase(RFSGroups.Items[i]) do
    begin
      InfoForm.Memo.Lines.Add( '  Group: ' + GName );

      for j := 0 to GroupActList.Count-1 do // along current Group RFActions
      with TN_RFrameAction(GroupActList.Items[j]) do
      begin
        InfoForm.Memo.Lines.Add( Format( 'RFAction: %s, Flags:%X, ActInd:%d',
                                                 [ActName,ActFlags,ActRGInd] ));
      end; // for j := 0 to GroupActList.Count-1 do // along current Group RFActions

      InfoForm.Memo.Lines.Add( '' );
    end; // for i := 0 to RFSGroups.Count-1 do // along RastrFrame SearchGroups

    if not InfoForm.Visible then InfoForm.Show;
  end; // with N_GetInfoForm() do
end; // TN_RFrameOptionsForm.aDebViewRFActionsExecute


procedure TN_RFrameOptionsForm.FormClose( Sender: TObject;
                                                  var Action: TCloseAction);
begin
  Inherited;
end; // procedure TN_RFrameOptionsForm.FormClose

//******************************  TN_RFrameOptionsForm.CurStateToMemIni  ******
// Save Current Self State (ComboBox Items and others)
//
procedure TN_RFrameOptionsForm.CurStateToMemIni();
begin
  Inherited;
//  frFileName.UpdateMemIniFile();
  N_ComboBoxToMemIni('RastFrOpF_frFileName', frFileName.mbFileName );
  N_IntToMemIni( 'RastFrOpF', 'AutoRename', Integer(cbAutoRename.Checked) );
end; // end of procedure TN_RFrameOptionsForm.CurStateToMemIni

//******************************  TN_RFrameOptionsForm.MemIniToCurState  ******
// Load Current Self State (ComboBox Items and others)
//
procedure TN_RFrameOptionsForm.MemIniToCurState();
begin
  Inherited;
//  frFileName.InitFromMemIniFile( N_MemIniFile, 'RastFrOpF_frFileName' );
  N_MemIniToComboBox( 'RastFrOpF_frFileName', frFileName.mbFileName );
  cbAutoRename.Checked := boolean( N_MemIniToInt( 'RastFrOpF', 'AutoRename' ) );
end; // end of procedure TN_RFrameOptionsForm.MemIniToCurState


    //************* Global procedures **********************

//******************************************  N_CreateRFrameOptionsForm  ******
// Create N_RFrameOptionsForm
// ARFrame - Raster Frame, which fields are to be shown and edited
//
function N_CreateRFrameOptionsForm( ARFrame: TN_Rast1Frame;
                                    AOwner: TN_BaseForm ): TN_RFrameOptionsForm;
begin
  Result := TN_RFrameOptionsForm.Create( Application );
  with Result do
  begin
//    BaseFormInit( AOwner );
    BaseFormInit( AOwner, '', [], [] );
    RFrame := ARFrame;
    SetFormFields();
    frFileName.OpenDialog.InitialDir := N_InitialFileDir;
    frFileName.OpenDialog.Filter := N_PictFilesFilter;
  end;
end; // end of function N_CreateRFrameOptionsForm

end.
