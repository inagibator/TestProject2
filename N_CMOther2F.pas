unit N_CMOther2F;
// Form for capture Images from N_CMECD_TestDevice2
// with captured images thumbnails, Status indicator and capuring by pressing F9

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Types,
  K_Types, K_CM0,
  N_Video, // temp
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1; // N_CMExtDLL, 

type TN_CMOther2Form = class( TN_BaseForm )
    MainPanel: TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit: TButton;
    ThumbsRFrame: TN_Rast1Frame;
    StatusShape: TShape;
    StatusLabel: TLabel;
    bnSetup: TButton;
    SlideRFrame: TN_Rast1Frame; // Other Capturing Form

    //****************  TN_CMOther2Form class handlers  ******************

    procedure FormShow     ( Sender: TObject );
    procedure FormClose    ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormKeyDown  ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyUp    ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure bnSetupClick ( Sender: TObject );
    procedure SlidePanelResize ( Sender: TObject );
  public
    CMOFThumbsDGrid:  TN_DGridArbMatr;   // DGrid for handling Thumbnails in ThumbsRFrame
    CMOFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails (jn CMOFDrawThumb)
    CMOFPNewSlides:   TN_PUDCMSArray;    // Pointer to Array of New captured Slides
    CMOFPProfile:    TK_PCMOtherProfile; // Pointer to Device Profile
    CMOFNumCaptured: integer;            // Number of Captured Slides
    CMOFDeviceIndex:  integer;           // Device Index in ECDevices Array

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                   AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure CMOFShowStatus   ( AIntStatus: integer );
    function  CMOFCreateSlide  ( ASlideNum: integer ): TN_UDCMSlide;

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMOther2Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

const
  N_CMOF2Unknown      = 0;
  N_CMOF2Ready        = 1;
  N_CMOF2Disconnected = 2;
  N_CMOF2Scanning     = 3;
  N_CMOF2Error        = 4;

implementation
uses math,
 K_CLib0, K_Parse, K_Script1,
 N_Lib0, N_Lib2, N_CompBase, N_Comp1, N_CMMain5F;
{$R *.dfm}

//****************  TN_CMOther2Form class handlers  ******************

//************************************************ TN_CMOther2Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMOther2Form.FormShow( Sender: TObject );
begin
  Caption := CMOFPProfile^.CMDPCaption + ' X-Ray Capture';
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
//    DGMarkBordColor := N_CM_SlideMarkColor;
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

    CMOFShowStatus( N_CMOF2Unknown );
  end; // with CMMFThumbsDGrid do

  with SlideRFrame do
  begin
    RFDebName := 'SlideRFrame';
    RFCenterInDst  := True;
    RFrShowComp( nil );
  end; // with SlideRFrame do

end; // procedure TN_CMOther2Form.FormShow

//*********************************************** TN_CMOther2Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMOther2Form.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  Inherited;
end; // procedure TN_CMOther2Form.FormClose

procedure TN_CMOther2Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F9 then
    CMOFShowStatus( N_CMOF2Scanning );
end; // procedure TN_CMOther2Form.FormKeyDown

procedure TN_CMOther2Form.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
// If F9 is Up - Create new test Slide
var
  i: integer;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
  if Key = VK_F9 then
  begin
    Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
    NewSlide := CMOFCreateSlide( CMOFNumCaptured );

    // Add NewSlide to list of all Slides of current Patient
    K_CMEDAccess.EDAAddSlide( NewSlide ); // from now on NewSlide is owned by K_CMEDAccess

    // Add NewSlide to beg of CMOFPNewSlides^ array
    SetLength( CMOFPNewSlides^, CMOFNumCaptured );
    for i := High(CMOFPNewSlides^) downto 1 do // Shift all elems by 1
      CMOFPNewSlides^[i] := CMOFPNewSlides^[i-1];

    CMOFPNewSlides^[0] := NewSlide;

    // Add NewSlide to CMOFThumbsDGrid
    Inc( CMOFThumbsDGrid.DGNumItems );
    CMOFThumbsDGrid.DGInitRFrame();
    CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

    // Show NewSlide in SlideRFrame
    RootComp := NewSlide.GetMapRoot();
    SlideRFrame.RFrShowComp( RootComp );

    CMOFShowStatus( N_CMOF2Ready );
  end; // if Key = VK_F9 then
end; // procedure TN_CMOther2Form.FormKeyUp

procedure TN_CMOther2Form.bnSetupClick( Sender: TObject );
// Show Setup dialog
begin
// ...
end; // procedure TN_CMOther2Form.bnSetupClick

procedure TN_CMOther2Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw

  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMOther2Form.SlidePanelResize


//****************  TN_CMOther2Form class public methods  ************

//******************************************* TN_CMOther2Form.CMOFDrawThumb ***
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
procedure TN_CMOther2Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length(CMOFPNewSlides^)-AInd] );

    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMOther2Form.CMOFDrawThumb

//**************************************** TN_CMOther2Form.CMOFGetThumbSize ***
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
procedure TN_CMOther2Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide : TN_UDCMSlide;
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin
  with N_CM_GlobObj, ADGObj do
  begin
    Slide := CMOFPNewSlides^[AInd];
    ThumbDIB := Slide.GetThumbnail();
    ThumbSize := ThumbDIB.DIBObj.DIBSize;

    AOutSize := Point(0,0);
    if AInpSize.X > 0 then // given is AInpSize.X
      AOutSize.Y := Round( AInpSize.X*ThumbSize.Y/ThumbSize.X ) + DGLAddDySize
    else // AInpSize.X = 0, given is AInpSize.Y
      AOutSize.X := Round( (AInpSize.Y-DGLAddDySize)*ThumbSize.X/ThumbSize.Y );

    AMinSize  := Point(10,10);
    APrefSize := ThumbSize;
    AMaxSize  := Point(1000,1000);
  end; // with N_CM_GlobObj. ADGObj do
end; // procedure TN_CMOther2Form.CMOFGetThumbSize

//****************************************** TN_CMOther2Form.CMOFShowStatus ***
// Show current device status
//
//     Parameters
// AIntStatus - given Status (one of N_CMOF2xxx constants)
//
procedure TN_CMOther2Form.CMOFShowStatus( AIntStatus: integer );
begin
  case AIntStatus of

  N_CMOF2Unknown: begin
    StatusLabel.Caption := 'Unknown';
    StatusLabel.Font.Color  := clBlack;
    StatusShape.Pen.Color   := clBlack;
    StatusShape.Brush.Color := clBlack;
  end; // N_CMOF2Unknown: begin

  N_CMOF2Ready: begin
    StatusLabel.Caption := 'Ready';
    StatusLabel.Font.Color  := clGreen;
    StatusShape.Pen.Color   := clGreen;
    StatusShape.Brush.Color := clGreen;
  end; // N_CMOF2Ready: begin

  N_CMOF2Disconnected: begin
    StatusLabel.Caption := 'Disconnected';
    StatusLabel.Font.Color  := clYellow;
    StatusShape.Pen.Color   := clYellow;
    StatusShape.Brush.Color := clYellow;
  end; // N_CMOF2Disconnected: begin

  N_CMOF2Scanning: begin
    StatusLabel.Caption := 'Scanning';
    StatusLabel.Font.Color  := clBlue;
    StatusShape.Pen.Color   := clBlue;
    StatusShape.Brush.Color := clBlue;
  end; // N_CMOF2Scanning: begin

  N_CMOF2Error: begin
    StatusLabel.Caption := 'Error';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // N_CMOF2Error: begin

  end; // case AIntStatus of

  StatusLabel.Repaint;
  StatusShape.Repaint;

end; // end of TN_CMOther2Form.CMOFShowStatus

//***************************************** TN_CMOther2Form.CMOFCreateSlide ***
// Create and return Test Slide
//
//     Parameters
// ASlideNum - given Slide Number to Draw over the Slide
//
function TN_CMOther2Form.CMOFCreateSlide( ASlideNum: integer ): TN_UDCMSlide;
var
  SizeX, SizeY: integer;
  NewDIB, GrayDIB: TN_DIBObj;
begin
  SizeX := 1262; // Test Image Size
  SizeY := 1640;

  NewDIB := TN_DIBObj.Create( SizeX, SizeY, pf24bit );
  NewDIB.DIBOCanv.DrawPixGrid( Rect(0,0,SizeX-1,SizeY-1), 200, 4, 0,  200, 4, 0,
                                           $666666, $DDDDDD, $888888, $000000 );

  N_DebSetNFont( NewDIB.DIBOCanv, 400, 0 );
  NewDIB.DIBOCanv.SetFontAttribs( $000000, $FFFFFF );
  NewDIB.DIBOCanv.DrawPixString( Point(230,230), Format( ' (%d) ', [ASlideNum] ) );

  GrayDIB := TN_DIBObj.Create( SizeX, SizeY, pfcustom, -1, epfGray8 );
  NewDIB.CalcGrayDIB( GrayDIB );

  Result := K_CMSlideCreateFromDIBObj( GrayDIB, @(CMOFPProfile^.CMAutoImgProcAttrs) );
  NewDIB.Free;
  // now GrayDIB is owned by CMVFFreezedSlide and should not be freed
end; // end of TN_CMOther2Form.CMOFCreateSlide

//**************************************** TN_CMOther2Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMOther2Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMOther2Form.CurStateToMemIni

//***************************************** TN_CMOther2Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMOther2Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMOther2Form.MemIniToCurState


    //*********** Global Procedures  *****************************

end.
