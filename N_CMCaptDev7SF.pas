unit N_CMCaptDev7SF;
// Form for capture Images from E2V (Mediaray) Devices
// 2014.01.04 Added nil check for XE5 by Valery Ovechkin, line 200
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2015.11.16 N_CMDIBAdjustE2V replaced by AutoContrast

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_Gra3, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1;

type TN_CMCaptDev7Form = class( TN_BaseForm )
    MainPanel: TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit: TButton;
    ThumbsRFrame: TN_Rast1Frame;
    SlideRFrame: TN_Rast1Frame;
    TimerCheck: TTimer;
    CtrlsPanelParent: TPanel;
    CtrlsPanel: TPanel;
    bnCapture: TButton;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;
    cbAutoTake: TCheckBox;
    bnSetup: TButton;
    StatusShape: TShape;
    StatusLabel: TLabel;

    //****************  TN_CMCaptDev7Form class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure SlidePanelResize ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
    procedure tbLeft90Click    ( Sender: TObject );
    procedure tbRight90Click   ( Sender: TObject );
    procedure tb180Click       ( Sender: TObject );
    procedure tbFlipHorClick   ( Sender: TObject );
    procedure cbAutoTakeClick  ( Sender: TObject);
    procedure UpDown1Click     ( Sender: TObject; Button: TUDBtnType );
    procedure bnSetupClick     ( Sender: TObject );
    procedure bnExitClick      ( Sender: TObject );
    procedure TimerCheckTimer  ( Sender: TObject );
  public
    CMOFThumbsDGrid:  TN_DGridArbMatr;   // DGrid for handling Thumbnails in ThumbsRFrame
    CMOFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails (jn CMOFDrawThumb)
    CMOFPNewSlides:   TN_PUDCMSArray;    // Pointer to Array of New captured Slides
    CMOFAnsiFName:    AnsiString;        // Image (created by driver) Full File Name
    CMOFPProfile:     TK_PCMOtherProfile;// Pointer to Device Profile
    CMOFDeviceIndex:  Integer;           // Device Index in ECDevices Array
    CMOFNumCaptured:  Integer;           // Number of Captured Slides
    CMOFNumTEvents:   Integer;           // Number of Timer Events passed
    CMOFIsGrabbing:   Boolean;           // True if inside (init_grabbing - finish_grabbing)
    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer; const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer; AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide (): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev7Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown   = 0;
  N_CMOF4Manual    = 1;
  N_CMOF4Auto      = 2;

implementation

uses
  math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev7S;
{$R *.dfm}

//****************  TN_CMCaptDev7Form class handlers  ******************

//********************************************** TN_CMCaptDev7Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev7Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'E2V Start FormShow' );
  Caption := CMOFPProfile^.CMDPCaption + ' X-Ray Capture';
  tbRotateImage.Images := N_CM_MainForm.CMMCurBigIcons;
  CMOFDrawSlideObj := TN_CMDrawSlideObj.Create(); // used in jn CMOFDrawThumb for Drawing Thumbnails
  CMOFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMOFGetThumbSize );

  with CMOFThumbsDGrid do
  begin
    DGEdges := Rect( 2, 2, 2, 2 );
    DGGaps  := Point( 2, 2 );
    DGScrollMargins := Rect( 8, 8, 8, 8 );

    DGLFixNumCols   := 1;
    DGLFixNumRows   := 0;
    DGSkipSelecting := True;
    DGChangeRCbyAK  := True;
    DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
    DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

    DGBackColor     := ColorToRGB( clBtnFace );

    DGMarkBordColor := $800000;
    DGNormBordColor := $808080;
    DGMarkNormWidth := 0;

    DGNormBordColor := DGBackColor;
    DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
    DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)
    DGLAddDySize    := 0; // see DGLItemsAspect
    DGLItemsAspect  := 0.75;
    DGDrawItemProcObj := CMOFDrawThumb;
    ThumbsRFrame.DstBackColor := DGBackColor;
    CMOFThumbsDGrid.DGInitRFrame();
    CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  end; // with CMMFThumbsDGrid do

  with SlideRFrame do
  begin
    RFDebName := 'SlideRFrame';
    RFCenterInDst := True;
    RFrShowComp( nil );
  end; // with SlideRFrame do

//  tbRotateImage.Visible := True;  // !!!  not needed because is already visible
  TimerCheck.Enabled := True;
  N_Dump1Str( 'E2V End FormShow' );
end; // procedure TN_CMCaptDev7Form.FormShow

//********************************************* TN_CMCaptDev7Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev7Form.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  TimerCheck.Enabled := False;
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;
  N_CMCDServObj7.E2VClose( Self );                // close device
  N_Dump2Str( 'CMOther7Form.FormClose' );
  Inherited;
end; // TN_CMCaptDev7Form.FormClose

// procedure TN_CMCaptDev7Form.FormKeyDown
procedure TN_CMCaptDev7Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev7Form.FormKeyDown

// procedure TN_CMCaptDev7Form.FormKeyUp
procedure TN_CMCaptDev7Form.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev7Form.FormKeyUp

// procedure TN_CMCaptDev7Form.cbAutoTakeClick
procedure TN_CMCaptDev7Form.cbAutoTakeClick( Sender: TObject );
begin
  inherited;
  N_Dump2Str( 'E2V >> cbAutoTakeClick ' + N_B2S(cbAutoTake.Checked) );
  bnCapture.Enabled := False;

  if cbAutoTake.Checked then // if user set auto mode
     N_CMCDServObj7.E2VArm( Self ) // arm device
  else                        // if user set manual mode
  begin
     N_CMCDServObj7.E2VDisArm( Self );    // disarm device
     bnCapture.Enabled := True;
  end;

end; // procedure TN_CMCaptDev7Form.cbAutoTakeClick

// procedure TN_CMCaptDev7Form.SlidePanelResize
procedure TN_CMCaptDev7Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw

  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev7Form.SlidePanelResize

//**************************************** TN_CMCaptDev7Form.bnCaptureClick ***
// Capture Image in not CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// bnCapture button OnClick handler
//
procedure TN_CMCaptDev7Form.bnCaptureClick( Sender: TObject );
begin
  bnCapture.Enabled := False;
  cbAutoTake.Enabled := False;
  N_Dump2Str( 'E2V >> bnCaptureClick');
  N_CMCDServObj7.E2VArm( Self ); // arm device
end; // procedure TN_CMCaptDev7Form.bnCaptureClick

//***************************************** TN_CMCaptDev7Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev7Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev7Form.tbLeft90Click

//**************************************** TN_CMCaptDev7Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev7Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev7Form.tbRight90Click

// procedure TN_CMCaptDev7Form.timer_checkTimer
procedure TN_CMCaptDev7Form.TimerCheckTimer( Sender: TObject );
begin
  N_CMCDServObj7.E2VOnTimer( Self );
end; // procedure TN_CMCaptDev7Form.timer_checkTimer

// procedure TN_CMCaptDev7Form.UpDown1Click
procedure TN_CMCaptDev7Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev7Form.UpDown1Click

// procedure TN_CMCaptDev7Form.tbRight90Click

//******************************************** TN_CMCaptDev7Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev7Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev7Form.tb180Click

//**************************************** TN_CMCaptDev7Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev7Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev7Form.tbFlipHorClick


//****************  TN_CMCaptDev7Form class public methods  ************

//***************************************** TN_CMCaptDev7Form.CMOFDrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel and may be not equal to upper left Grid pixel )
//
// Is used as value of CMOFThumbsDGrid.DGDrawItemProcObj field
//
procedure TN_CMCaptDev7Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin

  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do

end; // end of TN_CMCaptDev7Form.CMOFDrawThumb

//************************************** TN_CMCaptDev7Form.CMOFGetThumbSize ***
// Get Thumbnail Size (used as TN_DGridBase.DGGetItemSizeProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - given Thumbnail Index
// AInpSize  - given Size on input, only one fileld (X or Y) should be <> 0
// AOutSize  - resulting Size on output, if AInpSize.X <> 0 then OutSize.Y <> 0,
//                                       if AInpSize.Y <> 0 then OutSize.X <> 0
// AMinSize  - (on output) Minimal Size
// APrefSize - (on output) Preferable Size
// AMaxSize  - (on output) Maximal Size
//
//  Is used as value of CMOFThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TN_CMCaptDev7Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: Integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide: TN_UDCMSlide;
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin

  with N_CM_GlobObj, ADGObj do
  begin
    Slide     := CMOFPNewSlides^[AInd];
    ThumbDIB  := Slide.GetThumbnail();
    ThumbSize := ThumbDIB.DIBObj.DIBSize;
    AOutSize  := Point( 0,0 );

    if AInpSize.X > 0 then // given is AInpSize.X
      AOutSize.Y := Round( AInpSize.X * ThumbSize.Y / ThumbSize.X ) + DGLAddDySize
    else // AInpSize.X = 0, given is AInpSize.Y
      AOutSize.X := Round( ( AInpSize.Y - DGLAddDySize ) * ThumbSize.X / ThumbSize.Y );

    AMinSize  := Point( 10, 10 );
    APrefSize := ThumbSize;
    AMaxSize  := Point( 1000, 1000 );
  end; // with N_CM_GlobObj. ADGObj do

end; // procedure TN_CMCaptDev7Form.CMOFGetThumbSize

//***************************************** TN_CMCaptDev7Form.CMOFSetStatus ***
// procedure TN_CMCaptDev7Form.bnExitClick
procedure TN_CMCaptDev7Form.bnExitClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMCaptDev7Form.bnExitClick

// procedure TN_CMCaptDev7Form.bnSetupClick
procedure TN_CMCaptDev7Form.bnSetupClick( Sender: TObject );
var
  IsArmed: Boolean;
begin
  inherited;
  TimerCheck.Enabled := False; // disable timer
  // is armed
  IsArmed := ( N_CMCDServObj7.DeviceStatus = dsArmed ) or
              ( N_CMCDServObj7.DeviceStatus = dsTakesXray );

  // if device armed
  if IsArmed then
    N_CMCDServObj7.E2VDisArm( Self ); // disarm device

  // show device settings
  N_CMCDServObj7.CDSSettingsDlg( N_CMCDServObj7.PProfile );

  // if device was armed before setup click
  if IsArmed then
    N_CMCDServObj7.E2VArm( Self ); // arm device

  TimerCheck.Enabled := True; // enable timer
end; // procedure TN_CMCaptDev7Form.bnSetupClick

//************************************** TN_CMCaptDev7Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev7Form.CMOFCaptureSlide(): integer;
var
  i: Integer;
  CapturedDIB: TN_DIBObj;
  NDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  MediaFilter: Boolean;
begin
  Result := 0;
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  CapturedDIB := TN_DIBObj.Create(); // create DIB
  CapturedDIB.PrepEmptyDIBObj( N_CMCDServObj7.sens.usWidth,
                               N_CMCDServObj7.sens.usHeight,
                               pfCustom, -1, epfGray16, 16 );
  CapturedDIB.DIBInfo.bmi.biXPelsPerMeter := 1000000 div N_CMCDServObj7.pixelSizeH;
  CapturedDIB.DIBInfo.bmi.biYPelsPerMeter := CapturedDIB.DIBInfo.bmi.biXPelsPerMeter;

  for i := 0 to N_CMCDServObj7.sens.usHeight - 1 do // along all pixel rows
  begin
    move( N_CMCDServObj7.ImageArray[i * N_CMCDServObj7.sens.usWidth * 2],
          ( CapturedDIB.PRasterBytes + i * CapturedDIB.RRLineSize )^,
          N_CMCDServObj7.sens.usWidth * 2 );
  end; // for i := 0 to N_CMCDServObj7.sens.usHeight - 1 do // along all pixel rows

  CapturedDIB.SetDIBNumBits( 12 );
  CapturedDIB.XORPixels( $00FFFFFF ); // Negate CapturedDIB

//  CapturedDIB.DIBNumBits := 16; // old code, now not needed
//  TmpDIB := N_CreateGray8DIBFromGray16( CapturedDIB );
//  CapturedDIB.Free;
//  CapturedDIB := TmpDIB;

  MediaFilter := True;                // Media Filter default value

  if ( 5 <= Length( CMOFPProfile^.CMDPStrPar1 ) ) then // if correct profile
    if ( '1' <> CMOFPProfile^.CMDPStrPar1[3] ) then
      MediaFilter := False;

  if MediaFilter then
  begin
//    N_CMDIBAdjustE2V( CapturedDIB ); // Apply Media Filter
//    N_Dump1Str( 'E2V >> DIB with Adjust' );

   if CapturedDIB.DIBNumBits > 8 then
     CapturedDIB.DIBNumBits := 16;
    NDIB := nil;
    CapturedDIB.CalcMaxContrastDIB( NDIB );
    CapturedDIB.Free();
    CapturedDIB := NDIB;
    N_Dump1Str( 'E2V >> DIB with Autocontrast' );
  end
  else
    N_Dump1Str( 'E2V >> DIB without Adjust' );

  CapturedDIB.FlipAndRotate( 5 );

  NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB, @( CMOFPProfile^.CMAutoImgProcAttrs ) );
  NewSlide.SetAutoCalibrated();
  NewSlide.ObjAliase := IntToStr( CMOFNumCaptured );

  with NewSlide.P()^ do
  begin
    CMSSourceDescr   := CMOFPProfile^.CMDPCaption;
    NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
    CMSMediaType     := CMOFPProfile^.CMDPMTypeID;
    NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@CMOFPProfile^.CMDPDModality) );
  end;

  K_CMEDAccess.EDAAddSlide( NewSlide ); // from now on NewSlide is owned by K_CMEDAccess
  // Add NewSlide to beg of CMOFPNewSlides^ array
  SetLength( CMOFPNewSlides^, CMOFNumCaptured );

  for i := High( CMOFPNewSlides^ ) downto 1 do // Shift all elems by 1
    CMOFPNewSlides^[i] := CMOFPNewSlides^[i - 1];

  CMOFPNewSlides^[0] := NewSlide;
  // Add NewSlide to CMOFThumbsDGrid
  Inc( CMOFThumbsDGrid.DGNumItems );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  RootComp := NewSlide.GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // end of TN_CMCaptDev7Form.CMOFCaptureSlide

//************************************** TN_CMCaptDev7Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev7Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev7Form.CurStateToMemIni

//************************************** TN_CMCaptDev7Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev7Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev7Form.MemIniToCurState

end.


