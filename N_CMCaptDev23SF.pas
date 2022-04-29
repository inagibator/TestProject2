unit N_CMCaptDev23SF;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F;

type TN_CMCaptDev23Form = class( TN_BaseForm )
    MainPanel:  TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit:     TButton;
    ThumbsRFrame: TN_Rast1Frame;
    SlideRFrame:  TN_Rast1Frame;
    TimerCheck:   TTimer;
    CtrlsPanelParent: TPanel;
    CtrlsPanel: TPanel;
    lbExpoLevel: TLabel;
    lbExpoLevelPrev: TLabel;
    LbSerialID: TLabel;
    LbSerialText: TLabel;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;
    StatusShape: TShape;
    StatusLabel: TLabel;
    cbAutoTake: TCheckBox;
    bnSetup: TButton;
    bnCapture: TButton;

    //******************  TN_CMCaptDev23Form class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction );
                                                                       override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
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

    CMOFLastState: Integer;              // last device state

 //   ThisForm: TN_CMCaptDev23Form;        // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide ( DIBPointer: Pointer ): Integer;
    function  CMOFCaptureSlide16Bit (): Integer; // capturing tiff 16 bit image
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

end; // type TN_CMCaptDev23Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown   = 0;
  N_CMOF4Manual    = 1;
  N_CMOF4Auto      = 2;

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev23S,
  N_CMCaptDev0;
{$R *.dfm}

//**********************  TN_CMCaptDev23Form class handlers  ******************

//********************************************* TN_CMCaptDev23Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev23Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'Owandy Start FormShow' );

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
    RFrShowComp( Nil );
  end; // with SlideRFrame do

//  tbRotateImage.Visible := True; // Is visible in Delphi designer
  TimerCheck.Enabled := True;

  N_CMECD_SensorOpen;
  lbExpoLevel.Caption := IntToStr(N_CMECD_SensorGetExpoLevel) + '%';

  if CMOFPProfile.CMDPStrPar2 = '1' then // 16bit checked
  begin
    N_CMECD_SensorSet16BitMode(1);
  end
  else // 16bit unchecked
  begin
    N_CMECD_SensorSet16BitMode(0);
  end;

  N_Dump1Str( 'Owandy End FormShow' );
end; // procedure TN_CMCaptDev23Form.FormShow

//******************************************** TN_CMCaptDev23Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev23Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  TimerCheck.Enabled := False;

  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;
  N_CMCDServObj23.CDSFreeAll();

  N_Dump2Str( 'CMOther23Form.FormClose' );
  Inherited;
end; // TN_CMCaptDev23Form.FormClose

//****************************************** TN_CMCaptDev23Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev23Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev23Form.FormKeyDown

//******************************************** TN_CMCaptDev23Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev23Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev23Form.FormKeyUp

// procedure TN_CMCaptDev23Form.cbAutoTakeClick - not implemented in the interface
procedure TN_CMCaptDev23Form.cbAutoTakeClick( Sender: TObject );
begin
  inherited;

  if cbAutoTake.Checked then
  begin
    // nothing
  end
  else
  begin
    // nothing
  end;

end; // procedure TN_CMCaptDev23Form.cbAutoTakeClick

// procedure TN_CMCaptDev23Form.SlidePanelResize
procedure TN_CMCaptDev23Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev23Form.SlidePanelResize

//*************************************** TN_CMCaptDev23Form.bnCaptureClick ***
// Capture Image in not CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// bnCapture button OnClick handler
//
procedure TN_CMCaptDev23Form.bnCaptureClick( Sender: TObject );
begin
end; // procedure TN_CMCaptDev23Form.bnCaptureClick

//***************************************** TN_CMCaptDev23Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev23Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev23Form.tbLeft90Click

//**************************************** TN_CMCaptDev23Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev23Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev23Form.tbRight90Click

//************************************** TN_CMCaptDev23Form.TimerCheckTimer ***
// Timer actions
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev23Form.TimerCheckTimer( Sender: TObject );
var
  IsImage, State:        Integer;
  DIBHandle, DIBPointer: Pointer;
  TempAnsiStr:           PAnsiChar;
begin
  TimerCheck.Enabled := False;
  IsImage := N_CMECD_SensorIsImageAvailable();

  if IsImage = 1 then
  begin
    N_Dump1Str( 'StrPar2 = '+ CMOFPProfile.CMDPStrPar2 );

    if CMOFPProfile.CMDPStrPar2 = '0' then // 8bit capture
    begin

      DIBHandle := Pointer( N_CMECD_SensorGetDIB() ); // handle to an image
      N_Dump1Str( 'Before lock' );

      DIBPointer := GlobalLock( HGLOBAL(DIBHandle) ); // pointer to an image structure
      N_Dump1Str( 'After lock' );

      CMOFCaptureSlide( DIBPointer ); // capture by pointer
      N_Dump1Str( 'Before unlock' );

      GlobalUnlock( HGLOBAL(DIBHandle) );
      N_Dump1Str( 'After unlock' );

      //***** showing an exposition level
      lbExpoLevel.Caption := IntToStr(N_CMECD_SensorGetExpoLevel) + '%';
      lbExpoLevel.Visible := True;
      lbExpoLevelPrev.Visible := True;
    end
    else // 16bit
    begin

      DIBHandle := Pointer( N_CMECD_SensorGetDIB() ); // handle to an image

      // temp image path
      TempAnsiStr := @( N_StringToAnsi(K_ExpandFileName( '(#TmpFiles#)' )) +
                                                          'Owandy_temp.tif')[1];

      N_CMECD_SensorSaveTiff( TempAnsiStr, DIBHandle );
      CMOFCaptureSlide16Bit();

      // delete a temp image
      if FileExists( K_ExpandFileName( '(#TmpFiles#)' ) + 'Owandy_temp.tif' ) then
        DeleteFile( K_ExpandFileName( '(#TmpFiles#)' ) + 'Owandy_temp.tif' );

      //*****showing an exposition level
      lbExpoLevel.Caption := IntToStr(N_CMECD_SensorGetExpoLevel) + '%';
      lbExpoLevel.Visible := True;
      lbExpoLevelPrev.Visible := True;
    end;
  end
  else // error
    if IsImage < 0 then
      N_Dump1Str( 'Error with SensorIsImageAvailable = ' + IntToStr(IsImage) );

  State := N_CMECD_SensorGetSensorState();

  if CMOFLastState <> State then
  case State of
  0:  begin
      StatusLabel.Caption := 'Disconnected';
      StatusLabel.Font.Color  := clRed;
      StatusShape.Pen.Color   := clRed;
      StatusShape.Brush.Color := clRed;
    end;
  1: begin // busy
      StatusLabel.Caption := 'Busy';
      StatusLabel.Font.Color  := TColor( $168EF7 ); // orange color
      StatusShape.Pen.Color   := TColor( $168EF7 );
      StatusShape.Brush.Color := TColor( $168EF7 );
    end;
  2: begin // connected
      StatusLabel.Caption := 'Ready';
      StatusLabel.Font.Color  := clGreen;
      StatusShape.Pen.Color   := clGreen;
      StatusShape.Brush.Color := clGreen;
    end;
  end;

  CMOFLastState := State; // so it won't blink

  TimerCheck.Enabled := True;
end; // procedure TN_CMCaptDev23Form.TimerCheckTimer

// procedure TN_CMCaptDev23Form.UpDown1Click
procedure TN_CMCaptDev23Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev23Form.UpDown1Click

//******************************************* TN_CMCaptDev23Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev23Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev23Form.tb180Click

//*************************************** TN_CMCaptDev23Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev23Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev23Form.tbFlipHorClick


//**********************  TN_CMCaptDev23Form class public methods  ************

//**************************************** TN_CMCaptDev23Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev23Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev23Form.CMOFDrawThumb

//************************************* TN_CMCaptDev23Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev23Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
                                  AInd: Integer; AInpSize: TPoint; out AOutSize,
                                        AMinSize, APrefSize, AMaxSize: TPoint );
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
      AOutSize.Y := Round( AInpSize.X * ThumbSize.Y / ThumbSize.X )
                                                                  + DGLAddDySize
    else // AInpSize.X = 0, given is AInpSize.Y
      AOutSize.X := Round( ( AInpSize.Y - DGLAddDySize ) *
                                                    ThumbSize.X / ThumbSize.Y );
    AMinSize  := Point( 10, 10 );
    APrefSize := ThumbSize;
    AMaxSize  := Point( 1000, 1000 );
  end; // with N_CM_GlobObj. ADGObj do
end; // procedure TN_CMCaptDev23Form.CMOFGetThumbSize

//****************************************** TN_CMCaptDev23Form.bnExitClick ***
// Exit
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev23Form.bnExitClick( Sender: TObject );
begin
  inherited;

  N_CMECD_SensorClose;
end; // procedure TN_CMCaptDev23Form.bnExitClick

//***************************************** TN_CMCaptDev23Form.bnSetupClick ***
// Setup form
//
//     Parameters
// Sender - Event Sender
//
// Not implemented in the interface
//
procedure TN_CMCaptDev23Form.bnSetupClick( Sender: TObject );
begin
  inherited;
  TimerCheck.Enabled := False; // disable timer
  N_CMECD_SensorShowConfigDialog();// show device settings
  TimerCheck.Enabled := True; // enable timer
end; // procedure TN_CMCaptDev23Form.bnSetupClick

//************************************* TN_CMCaptDev23Form.CMOFCaptureSlide ***
// Capture Slide and show it
//
//     Parameters
// DIBPointer - image pointer
// Return 0 if OK
//
function TN_CMCaptDev23Form.CMOFCaptureSlide( DIBPointer: Pointer ): Integer;
var
  CapturedDIB: TN_DIBObj;
  i:           Integer;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  DIBInfo:  TN_DIBInfo;
  PImagePixels: Pointer;
begin
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Owandy Start CMOFCaptureSlide %d', [CMOFNumCaptured]) );

  FillChar( DIBInfo, SizeOf(DIBInfo), 0 );
  Move( DIBPointer^, DIBInfo.bmi, SizeOf(DIBInfo.bmi) ); // filling dibinfo

  with DIBInfo.bmi do
    N_Dump1Str( Format(
           'Owandy Image: X,Y=%dx%d, BitCount=%d, ImgSize=%d, XYPerMeter=%d,%d',
                   [biWidth, biHeight, biBitCount, biSizeImage, biXPelsPerMeter,
                                                           biYPelsPerMeter] ) );

  CapturedDIB := TN_DIBObj.Create();
  CapturedDIB.PrepEmptyDIBObj( @DIBInfo, -1, epfAutoGray );

  Inc( PBITMAPINFOHEADER(DIBPointer) ); // pixels are right after dibinfo
  PImagePixels := DIBPointer;

  N_Dump1Str( 'CapturedDIB DIBSize.Y = ' + IntToStr(CapturedDIB.DIBSize.Y) );

  with CapturedDIB do // copy pixels from PImagePixels to CapturedDIB
    for i := 0 to DIBSize.Y-1 do // PImagePixels rows are not aligned!
      Move( (TN_BytesPtr(PImagePixels)+i*RRBytesInLine)^,
                                  (PRasterBytes+i*RRLineSize)^, RRBytesInLine );

  N_Dump1Str('Created DIB, NumBits = '+IntToStr(CapturedDIB.DIBNumBits));

  NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB,
                                          @(CMOFPProfile^.CMAutoImgProcAttrs) );
  NewSlide.SetAutoCalibrated();
  NewSlide.ObjAliase := IntToStr(CMOFNumCaptured);

  with NewSlide.P()^ do
  begin
    CMSSourceDescr := CMOFPProfile^.CMDPCaption;
    NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
    CMSMediaType := CMOFPProfile^.CMDPMTypeID;
    NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@CMOFPProfile^.CMDPDModality) );
  end; // with NewSlide.P()^ do

  // Add NewSlide to list of all Slides of current Patient
  K_CMEDAccess.EDAAddSlide( NewSlide ); // from now on NewSlide is owned by K_CMEDAccess

  // Add NewSlide to beg of CMOFPNewSlides^ array
  SetLength( CMOFPNewSlides^, CMOFNumCaptured );

  for i := High(CMOFPNewSlides^) downto 1 do // Shift all elems by 1
    CMOFPNewSlides^[i] := CMOFPNewSlides^[i - 1];

  CMOFPNewSlides^[0] := NewSlide;

  // Add NewSlide to CMOFThumbsDGrid
  Inc(CMOFThumbsDGrid.DGNumItems);
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  RootComp := NewSlide.GetMapRoot();
  SlideRFrame.RFrShowComp(RootComp);

  N_Dump1Str( Format('Owandy Fin CMOFCaptureSlide %d', [CMOFNumCaptured]) );
  Result := 0;
end; // end of TN_CMCaptDev23Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev23Form.CMOFCaptureSlide ***
// Capture 16bit Slide and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev23Form.CMOFCaptureSlide16Bit(): Integer;
var
  CapturedDIB: TN_DIBObj;
  i:        Integer;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Owandy Start CMOFCaptureSlide %d', [CMOFNumCaptured]) );

  CapturedDIB := Nil;
  N_LoadDIBFromFileByImLib( CapturedDIB, K_ExpandFileName( '(#TmpFiles#)' ) +
                                       'Owandy_temp.tif' ); // new 16bit variant

  NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB,
                                          @(CMOFPProfile^.CMAutoImgProcAttrs) );
  NewSlide.SetAutoCalibrated();
  NewSlide.ObjAliase := IntToStr(CMOFNumCaptured);

  with NewSlide.P()^ do
  begin
    CMSSourceDescr := CMOFPProfile^.CMDPCaption;
    NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
    CMSMediaType := CMOFPProfile^.CMDPMTypeID;
    NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@CMOFPProfile^.CMDPDModality) );
  end; // with NewSlide.P()^ do

  // Add NewSlide to list of all Slides of current Patient
  K_CMEDAccess.EDAAddSlide( NewSlide ); // from now on NewSlide is owned by K_CMEDAccess

  // Add NewSlide to beg of CMOFPNewSlides^ array
  SetLength( CMOFPNewSlides^, CMOFNumCaptured );

  for i := High(CMOFPNewSlides^) downto 1 do // Shift all elems by 1
    CMOFPNewSlides^[i] := CMOFPNewSlides^[i - 1];

  CMOFPNewSlides^[0] := NewSlide;

  // Add NewSlide to CMOFThumbsDGrid
  Inc(CMOFThumbsDGrid.DGNumItems);
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  RootComp := NewSlide.GetMapRoot();
  SlideRFrame.RFrShowComp(RootComp);

  N_Dump1Str( Format('Owandy Fin CMOFCaptureSlide %d', [CMOFNumCaptured]) );
  Result := 0;
end;

//************************************* TN_CMCaptDev23Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev23Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev23Form.CurStateToMemIni

//************************************* TN_CMCaptDev23Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev23Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev23Form.MemIniToCurState

end.


