unit N_CMCaptDev8SF;
// Form for capture Images from Gendex Devices
// 2014.01.04 Added nil check for XE5 by Valery Ovechkin, line 188
// 2014.01.04 Changed by Valery Ovechkin for Denoptix, lines 302 - 328
// 2014.03.20 substituted 'K_CMShowMessageDlg' by 'ShowCriticalError' calls by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1;

type TN_CMCaptDev8Form = class( TN_BaseForm )
    MainPanel:  TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit:     TButton;

    ThumbsRFrame:  TN_Rast1Frame;
    SlideRFrame:   TN_Rast1Frame;

    timer_check: TTimer;
    CtrlsPanelParent: TPanel;
    CtrlsPanel: TPanel;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;
    StatusShape: TShape;
    StatusLabel: TLabel;
    bnSetup: TButton;
    bnCapture: TButton; // Other Capturing Form

    //****************  TN_CMCaptDev8Form class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure SlidePanelResize ( Sender: TObject );
    procedure tbLeft90Click    ( Sender: TObject );
    procedure tbRight90Click   ( Sender: TObject );
    procedure tb180Click       ( Sender: TObject );
    procedure tbFlipHorClick   ( Sender: TObject );
    procedure bnSetupClick     ( Sender: TObject );
    procedure bnExitClick      ( Sender: TObject );
    procedure timer_checkTimer ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
  public
    CMOFThumbsDGrid:  TN_DGridArbMatr;   // DGrid for handling Thumbnails in ThumbsRFrame
    CMOFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails (jn CMOFDrawThumb)
    CMOFPNewSlides:   TN_PUDCMSArray;    // Pointer to Array of New captured Slides
    CMOFAnsiFName:    AnsiString;        // Image (created by driver) Full File Name
    CMOFPProfile:     TK_PCMOtherProfile;// Pointer to Device Profile

    CMOFNumCaptured:   Integer;          // Number of Captured Slides
    CMOFCurIntStatus:  Integer;          // Current Device (Form) Status
    CMOFCurTmpStatus:  Integer;          // Current Sensor Status (temporary)
    CMOFNumTEvents:    Integer;          // Number of Timer Events passed
    CMOFIsGrabbing:    Boolean;          // True if inside (init_grabbing - finish_grabbing)

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer; AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure CMOFSetStatus    ( AIntStatus: Integer );
    function  CMOFCaptureSlide (): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev8Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

implementation

uses
  math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev8S,
  N_CMCaptDev0;
{$R *.dfm}

//****************  TN_CMCaptDev8Form class handlers  ******************

//********************************************** TN_CMCaptDev8Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev8Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'Gendex Start FormShow' );
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

  //CMOFSetStatus( -100 );

  timer_check.Enabled := True;

  N_Dump1Str( 'Gendex End FormShow' );
end; // procedure TN_CMCaptDev8Form.FormShow

//********************************************* TN_CMCaptDev8Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev8Form.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  timer_check.Enabled := False;
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;
  N_CMCDServObj8.CDSFreeAll();
  Inherited;
  N_Dump1Str( 'CMCaptDev8Form.FormClose Fin' );
end; // TN_CMCaptDev8Form.FormClose

// procedure TN_CMCaptDev8Form.FormKeyDown
procedure TN_CMCaptDev8Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev8Form.FormKeyDown

// procedure TN_CMCaptDev8Form.FormKeyUp
procedure TN_CMCaptDev8Form.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
// If F9 is Up - Create new test Slide
begin
  Exit;
end; // procedure TN_CMCaptDev8Form.FormKeyUp

// procedure TN_CMCaptDev8Form.SlidePanelResize
procedure TN_CMCaptDev8Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw

  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev8Form.SlidePanelResize

//***************************************** TN_CMCaptDev8Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev8Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev8Form.tbLeft90Click

//**************************************** TN_CMCaptDev8Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev8Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev8Form.tbRight90Click

//******************************************** TN_CMCaptDev8Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev8Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev8Form.tb180Click

//**************************************** TN_CMCaptDev8Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev8Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev8Form.tbFlipHorClick



//****************************************** TN_CMCaptDev8Form.bnSetupClick ***
// Show Settings dialog
//
//     Parameters
// Sender - Event Sender
//
// bnSetup button OnClick handler
//
procedure TN_CMCaptDev8Form.bnSetupClick( Sender: TObject );
begin
  N_Dump1Str( 'CMCaptDev8Form.bnSetupClick Start' );
  N_CMCDServObj8.DisplayProperties_ext();
  N_Dump1Str( 'CMCaptDev8Form.bnSetupClick Fin' );
end;

procedure TN_CMCaptDev8Form.bnCaptureClick(Sender: TObject);
var
  id: Integer;
  st: TN_Int2;
begin
  inherited;
  id := StrToIntDef( CMOFPProfile^.CMDPProductName, 0 );
  N_CMCDServObj8.StartAcquisition_ext();
  st := N_CMCDServObj8.GetState_ext();

  if N_MemIniToBool( 'CMS_UserDeb', 'GendexCheckDeviceStateForDenoptix', True ) then
  begin

    if ( id = 1 ) then // Denoptix
    begin

      while ( ( st <> 1 ) and ( st <> 2) and ( st <> 6 ) ) do
      begin
        st := N_CMCDServObj8.GetState_ext();
        Application.ProcessMessages;
      end; //while ( ( st <> 1 ) and ( st <> 2) and ( st <> 6 ) ) do

      if ( st = 6 ) then // IDLE
      begin
        N_CMCDServObj8.StartAcquisition_ext();
        Exit;
      end; // if ( st = 6 ) then // IDLE

      N_CMV_ShowCriticalError( 'Gendex', 'device status = ' + IntToStr( id ) );
      Exit;
    end; // if ( id = 1 ) then // Denoptix

  end; // if N_MemIniToBool( 'CMS_UserDeb', 'GendexCheckDeviceStateForDenoptix', True ) then

end;

// procedure TN_CMCaptDev8Form.bnSetupClick

//******************************************* TN_CMCaptDev8Form.bnExitClick ***
// Close Self
//
//     Parameters
// Sender - Event Sender
//
// bnExit button OnClick handler
//
procedure TN_CMCaptDev8Form.bnExitClick( Sender: TObject );
begin
  N_Dump1Str( 'CMCaptDev8Form.bnExitClick Start' );
  Close;
end; // procedure TN_CMCaptDev8Form.bnExitClick

//************************************** TN_CMCaptDev8Form.timer_checkTimer ***
// Main Timer events handler
//
//     Parameters
// Sender - Event Sender
//
// timer_check timer OnTimer handler
//
procedure TN_CMCaptDev8Form.timer_checkTimer( Sender: TObject );
begin
  N_CMCDServObj8.GendexOnTimer( Self );
end; // procedure TN_CMCaptDev8Form.timer_checkTimer


//****************  TN_CMCaptDev8Form class public methods  ************

//***************************************** TN_CMCaptDev8Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev8Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                          const ARect: TRect );
begin

  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length(CMOFPNewSlides^)-AInd] );

    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do

end; // end of TN_CMCaptDev8Form.CMOFDrawThumb

//************************************** TN_CMCaptDev8Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev8Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide: TN_UDCMSlide;
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

end; // procedure TN_CMCaptDev8Form.CMOFGetThumbSize

//***************************************** TN_CMCaptDev8Form.CMOFSetStatus ***
// Set and Show current Device (Form) status
//
//     Parameters
// AIntStatus - given Status (one of N_CMOF4xxx constants)
//
procedure TN_CMCaptDev8Form.CMOFSetStatus( AIntStatus: integer );
begin
  CMOFCurIntStatus := AIntStatus;

  StatusLabel.Caption := Format( 'Device Status = %d', [AIntStatus] );
  StatusLabel.Font.Color  := clBlack;
  StatusShape.Pen.Color   := clBlack;
  StatusShape.Brush.Color := clBlack;

  StatusLabel.Repaint;
  StatusShape.Repaint;
end; // end of TN_CMCaptDev8Form.CMOFSetStatus

//************************************** TN_CMCaptDev8Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev8Form.CMOFCaptureSlide(): Integer;
var
  i:           Integer;
  CapturedDIB: TN_DIBObj;
  NewSlide:    TN_UDCMSlide;
  RootComp:    TN_UDCompVis;
begin
  Result := 0;
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  CapturedDIB := TN_DIBObj.Create(); // create DIB
  CapturedDIB.XORPixels( $00FFFFFF ); // Negate CapturedDIB

  //CapturedDIB.FlipAndRotate(6);
  NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB, @(CMOFPProfile^.CMAutoImgProcAttrs) );
  NewSlide.SetAutoCalibrated();
  NewSlide.ObjAliase := IntToStr( CMOFNumCaptured );

  with NewSlide.P()^ do
  begin
    CMSSourceDescr := CMOFPProfile^.CMDPCaption;
    NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
    CMSMediaType := CMOFPProfile^.CMDPMTypeID;
    NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@CMOFPProfile^.CMDPDModality) );
  end; // with NewSlide.P()^ do

  K_CMEDAccess.EDAAddSlide( NewSlide ); // from now on NewSlide is owned by K_CMEDAccess

  // Add NewSlide to beg of CMOFPNewSlides^ array
  SetLength( CMOFPNewSlides^, CMOFNumCaptured );

  for i := High(CMOFPNewSlides^) downto 1 do // Shift all elems by 1
    CMOFPNewSlides^[i] := CMOFPNewSlides^[i - 1];

  CMOFPNewSlides^[0] := NewSlide;

  // Add NewSlide to CMOFThumbsDGrid
  Inc( CMOFThumbsDGrid.DGNumItems );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  RootComp := NewSlide.GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );

end; // end of TN_CMCaptDev8Form.CMOFCaptureSlide

//************************************** TN_CMCaptDev8Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev8Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev8Form.CurStateToMemIni

//************************************** TN_CMCaptDev8Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev8Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev8Form.MemIniToCurState

end.


