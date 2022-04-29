unit N_CMCaptDev14F;
// Valery Ovechkin 26.02.2013 Form for capture Images from E2V Devices
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.07.03 Thread Code redesign by Alex Kovalev
// 2014.09.15 Fixed File exceptions processing ( like i/o 32, etc. ) by Valery Ovechkin
// 2014.09.15 Standartizing ( All functions parameters name starts from 'A' ) by Valery Ovechkin

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_Gra3, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1;

type TN_CMCaptDev14Form = class( TN_BaseForm )
    MainPanel: TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit: TButton;
    ThumbsRFrame: TN_Rast1Frame;
    StatusShape: TShape;
    StatusLabel: TLabel;
    SlideRFrame: TN_Rast1Frame;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;
    bnSetup: TButton;

    //****************  TN_CMCaptDev14Form class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure SlidePanelResize ( Sender: TObject );
    procedure tbLeft90Click    ( Sender: TObject );
    procedure tbRight90Click   ( Sender: TObject );
    procedure tb180Click       ( Sender: TObject );
    procedure tbFlipHorClick   ( Sender: TObject );
    procedure cbAutoTakeClick  ( Sender: TObject);
//    procedure UpDown1Click     ( Sender: TObject; Button: TUDBtnType );
//    procedure bnCaptureClick   ( Sender: TObject );
    procedure bnSetupClick     ( Sender: TObject );
    procedure bnExitClick      ( Sender: TObject );
    procedure OnDeviceChange   ( var AMsg: TMessage ); message WM_DEVICECHANGE;

    {procedure FormResize(Sender: TObject);
    procedure BFFormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);}
//    procedure barmClick(Sender: TObject);
//    procedure bdisarmClick(Sender: TObject);

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
    function  CMOFCaptureSlide ( ImageWidth, ImageHeight: Integer ): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev14Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown   = 0;
  N_CMOF4Manual    = 1;
  N_CMOF4Auto      = 2;

implementation

uses
  math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev14, N_CMCaptDev0;
{$R *.dfm}

//****************  TN_CMCaptDev14Form class handlers  ******************

//********************************************** TN_CMCaptDev14Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev14Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'Hamamatsu FormShow Start' );
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
  tbRotateImage.Visible := True;
  //TimerCheck.Enabled := True;

  // This Code is moved here from FormActivate (because sometimes FormActivate event was escape)
  N_CMV_USBReg( Self.Handle, N_CMCDServObj14.USBHandle );
  N_CMCDServObj14.DeviceArm();

  N_Dump1Str( 'Hamamatsu FormShow End' );
end; // procedure TN_CMCaptDev14Form.FormShow
{
//***************************************** TN_CMCaptDev14Form.FormActivate ***
// Perform needed Actions on Activating Self
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev14Form.FormActivate(Sender: TObject);
begin
  N_Dump2Str( 'TN_CMCaptDev14Form.FormActivate start' );
  inherited;
  N_CMCDServObj14.ShowStatus( Self, nil );

  N_CMV_USBReg( Self.Handle, N_CMCDServObj14.USBHandle );
  N_CMCDServObj14.DeviceArm();

  N_Dump2Str( 'TN_CMCaptDev14Form.FormActivate Fin' );
end; // TN_CMCaptDev14Form.FormActivate
}
//********************************************* TN_CMCaptDev14Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev14Form.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  N_Dump2Str( 'TN_CMCaptDev14Form.FormClose start' );
  N_CMV_USBUnreg( N_CMCDServObj14.USBHandle );
  N_CMCDServObj14.CDSFreeAll();
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;
  inherited;
  N_Dump2Str( 'TN_CMCaptDev14Form.FormClose fin' );
end; // TN_CMCaptDev14Form.FormClose

//****************************************** TN_CMCaptDev14Form.FormKeyDown ***
// procedure TN_CMCaptDev14Form.FormKeyDown
//
procedure TN_CMCaptDev14Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev14Form.FormKeyDown

//******************************************** TN_CMCaptDev14Form.FormKeyUp ***
// procedure TN_CMCaptDev14Form.FormKeyUp
//
procedure TN_CMCaptDev14Form.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  Exit;
end;

// procedure TN_CMCaptDev14Form.cbAutoTakeClick
procedure TN_CMCaptDev14Form.cbAutoTakeClick( Sender: TObject );
begin
  //N_CMCDServObj14.ShowDeviceStatus( ThisForm );
end; // procedure TN_CMCaptDev14Form.cbAutoTakeClick

// procedure TN_CMCaptDev14Form.SlidePanelResize
procedure TN_CMCaptDev14Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev14Form.SlidePanelResize

//***************************************** TN_CMCaptDev14Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev14Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev14Form.tbLeft90Click

//**************************************** TN_CMCaptDev14Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev14Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev14Form.tbRight90Click

procedure ThreadArm();
begin

end;
{
procedure TN_CMCaptDev14Form.barmClick(Sender: TObject);
begin
  inherited;
  N_CMCDServObj14.DeviceArm();
end;

procedure TN_CMCaptDev14Form.bdisarmClick(Sender: TObject);
begin
  inherited;
  N_CMCDServObj14.DeviceDisarm();
end;
}
{
//**************************************** TN_CMCaptDev14Form.bnCaptureClick ***
// Capture Image in not CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// bnCapture button OnClick handler
//
procedure TN_CMCaptDev14Form.bnCaptureClick( Sender: TObject );
begin
end; // procedure TN_CMCaptDev14Form.bnCaptureClick

// procedure TN_CMCaptDev14Form.UpDown1Click
procedure TN_CMCaptDev14Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev14Form.UpDown1Click
}

// procedure TN_CMCaptDev14Form.tbRight90Click

//******************************************** TN_CMCaptDev14Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev14Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev14Form.tb180Click

//**************************************** TN_CMCaptDev14Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev14Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev14Form.tbFlipHorClick


//****************  TN_CMCaptDev14Form class public methods  ************

//***************************************** TN_CMCaptDev14Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev14Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do
  begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev14Form.CMOFDrawThumb

//************************************** TN_CMCaptDev14Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev14Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: Integer;
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
end; // procedure TN_CMCaptDev14Form.CMOFGetThumbSize

//**************************************** TN_CMCaptDev14Form.CMOFSetStatus ***
// procedure TN_CMCaptDev14Form.bnExitClick
//
procedure TN_CMCaptDev14Form.bnExitClick( Sender: TObject );
begin
  N_Dump2Str( 'TN_CMCaptDev14Form.bnExitClick' );
end; // procedure TN_CMCaptDev14Form.bnExitClick

//*************************************** TN_CMCaptDev14Form.OnDeviceChange ***
// Windows message from Hamamatsu driver
//
//     Parameters
// AMsg - incoming Windows message
//
procedure TN_CMCaptDev14Form.OnDeviceChange( var AMsg: TMessage );
begin
  N_CMCDServObj14.ProcessUSB( AMsg, Self, nil );
end; // procedure TN_CMCaptDev14Form.OnDeviceChange

//***************************************** TN_CMCaptDev14Form.bnSetupClick ***
// procedure TN_CMCaptDev14Form.bnSetupClick
//
procedure TN_CMCaptDev14Form.bnSetupClick( Sender: TObject );
begin
  N_Dump2Str( 'TN_CMCaptDev14Form.bnSetupClick start' );
  // show device settings
  N_CMCDServObj14.DeviceDisarm();
  N_CMCDServObj14.ShowStatus( Self, nil );
  N_CMCDServObj14.CDSSettingsDlg( N_CMCDServObj14.PProfile );
  N_CMV_USBReg( Self.Handle, N_CMCDServObj14.USBHandle );
  N_CMCDServObj14.DeviceArm();
  N_CMCDServObj14.ShowStatus( Self, nil );
  N_Dump2Str( 'TN_CMCaptDev14Form.bnSetupClick fin' );
end; // procedure TN_CMCaptDev14Form.bnSetupClick

//************************************** TN_CMCaptDev14Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev14Form.CMOFCaptureSlide( ImageWidth, ImageHeight: Integer ): Integer;
var
  i: Integer;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
  Result := 0;

  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  CapturedDIB := TN_DIBObj.Create(); // create DIB

  CapturedDIB.PrepEmptyDIBObj( ImageWidth, ImageHeight, pfCustom, -1, epfGray16, 14 );
  CapturedDIB.DIBInfo.bmi.biXPelsPerMeter := 1000000 div 20;
  CapturedDIB.DIBInfo.bmi.biYPelsPerMeter := CapturedDIB.DIBInfo.bmi.biXPelsPerMeter;

  for i := 0 to ImageHeight - 1 do // along all pixel rows
    move( N_CMCDServObj14.ImgBuf[14 + i * CapturedDIB.RRBytesInLine],
          ( CapturedDIB.PRasterBytes + i * CapturedDIB.RRLineSize )^,
            CapturedDIB.RRBytesInLine );
  // CapturedDIB.RRBytesInLine = ImageWidth * 2
{
  for i := 0 to ImageWidth - 1 do
    for j := 0 to ImageHeight - 1 do
    begin
      n := ( j * 2 * ImageWidth ) + ( 2 * i );
      Byte( CapturedDIB.PRasterBytes[n + 0] ) := N_CMCDServObj14.ImgBuf[14 + n + 0];
      Byte( CapturedDIB.PRasterBytes[n + 1] ) := N_CMCDServObj14.ImgBuf[14 + n + 1];
    end;
}
  CapturedDIB.XORPixels( $00FFFFFF ); // Negate CapturedDIB

  if N_CMCDServObj14.Filter then // Apply image filter
  begin

    if N_CMCDServObj14.FilterE2V then  // E2V filter
      N_CMDIBAdjustLight( CapturedDIB );

    if N_CMCDServObj14.FilterTrident then  // Trident filter
      N_CMSTridentDIBAdjust( CapturedDIB );

  end; // if N_CMCDServObj14.Filter then // Apply image filter

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
end; // end of TN_CMCaptDev14Form.CMOFCaptureSlide

//************************************** TN_CMCaptDev14Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev14Form.CurStateToMemIni();
begin
  inherited;
end; // end of procedure TN_CMCaptDev14Form.CurStateToMemIni

//************************************** TN_CMCaptDev14Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev14Form.MemIniToCurState();
begin
  inherited;
end; // end of procedure TN_CMCaptDev14Form.MemIniToCurState

end.


