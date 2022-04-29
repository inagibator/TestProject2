unit N_CMCaptDevDemo1F;
// Form for capture Images from Demo1 Device
// 2014.01.04 Added nil check for XE5 by Valery Ovechkin, line 214

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1,
  ComCtrls, ToolWin, ImgList; //, IdBaseComponent, IdAntiFreezeBase, IdAntiFreeze;

type TN_CMCaptDevDemo1Form = class( TN_BaseForm )
    MainPanel: TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit: TButton;
    ThumbsRFrame: TN_Rast1Frame;
    StatusShape: TShape;
    StatusLabel: TLabel;
    SlideRFrame: TN_Rast1Frame;
    bnCapture: TButton;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;
    cbAutoTake: TCheckBox;
    Label1: TLabel;
    etrigger: TEdit;
    bnSetup: TButton;
    timer_check: TTimer;
    bnTest: TButton; // Other Capturing Form

    //****************  TN_CMCaptDevDemo1Form class handlers  ***********

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
    procedure cbAutoTakeClick  ( Sender: TObject );
    procedure UpDown1Click     ( Sender: TObject; Button: TUDBtnType );
    procedure bnSetupClick     ( Sender: TObject );
    procedure bnExitClick      ( Sender: TObject );
    procedure timer_checkTimer ( Sender: TObject );
    procedure bnTestClick(Sender: TObject);
  public
    CMOFThumbsDGrid:  TN_DGridArbMatr;   // DGrid for handling Thumbnails in ThumbsRFrame
    CMOFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails (jn CMOFDrawThumb)
    CMOFPNewSlides:   TN_PUDCMSArray;    // Pointer to Array of New captured Slides
    CMOFAnsiFName:    AnsiString;        // Image (created by driver) Full File Name
    CMOFPProfile:     TK_PCMOtherProfile;// Pointer to Device Profile
    CMOFDeviceIndex:  integer;           // Device Index in ECDevices Array

    CMOFNumCaptured:   integer;          // Number of Captured Slides
    CMOFCurIntStatus:  integer;          // Current Device (Form) Status
    CMOFCurTmpStatus:  integer;          // Current Sensor Status (temporary)
    CMOFNumTEvents:    integer;          // Number of Timer Events passed
    CMOFIsGrabbing:    boolean;          // True if inside (init_grabbing - finish_grabbing)
    CMOFFileNum:       integer;          // File number for Demo_Mode

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                   AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure CMOFSetStatus      ( AIntStatus: integer );
    function  CMOFCaptureSlide   (): integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDevDemo1Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown   = 0;
  N_CMOF4Manual    = 1;
  N_CMOF4Auto      = 2;

implementation
uses math,
     K_CLib0, K_Parse, K_Script1,
     N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDevDemo1;
{$R *.dfm}

//****************  TN_CMCaptDevDemo1Form class handlers  ******************

//****************************************** TN_CMCaptDevDemo1Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDevDemo1Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'DemoDev Start FormShow' );
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

  end; // with CMMFThumbsDGrid do

  with SlideRFrame do
  begin
    RFDebName := 'SlideRFrame';
    RFCenterInDst  := True;
    RFrShowComp( nil );
  end; // with SlideRFrame do


  tbRotateImage.Visible := True;

  CMOFSetStatus( -100 );

    timer_check.Enabled := False;
    cbAutoTake.Checked  := False;
    cbAutoTake.Enabled  := False;
    CMOFFileNum := 0;

  N_Dump1Str( 'DemoDev End FormShow' );
end; // procedure TN_CMCaptDevDemo1Form.FormShow

//***************************************** TN_CMCaptDevDemo1Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDevDemo1Form.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  timer_check.Enabled := False;
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  Inherited;
  N_Dump2Str( 'CMCaptDevDemo1Form.FormClose' );
end; // TN_CMCaptDevDemo1Form.FormClose

// procedure TN_CMCaptDevDemo1Form.FormKeyDown
procedure TN_CMCaptDevDemo1Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin

  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then

//    CMOFSetStatus( N_CMOF4Scanning );
end; // procedure TN_CMCaptDevDemo1Form.FormKeyDown

// procedure TN_CMCaptDevDemo1Form.FormKeyUp
procedure TN_CMCaptDevDemo1Form.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
// If F9 is Up - Create new test Slide
begin
  Exit;
end; // procedure TN_CMCaptDevDemo1Form.FormKeyUp

// procedure TN_CMCaptDevDemo1Form.cbAutoTakeClick
procedure TN_CMCaptDevDemo1Form.cbAutoTakeClick( Sender: TObject );
begin
end; // procedure TN_CMCaptDevDemo1Form.cbAutoTakeClick

// procedure TN_CMCaptDevDemo1Form.SlidePanelResize
procedure TN_CMCaptDevDemo1Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw

  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDevDemo1Form.SlidePanelResize

//************************************ TN_CMCaptDevDemo1Form.bnCaptureClick ***
// Capture Image in not CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// bnCapture button OnClick handler
//
procedure TN_CMCaptDevDemo1Form.bnCaptureClick( Sender: TObject );
begin
  CMOFCaptureSlide();
end; // procedure TN_CMCaptDevDemo1Form.bnCaptureClick

//************************************* TN_CMCaptDevDemo1Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDevDemo1Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDevDemo1Form.tbLeft90Click

//************************************ TN_CMCaptDevDemo1Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDevDemo1Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDevDemo1Form.tbRight90Click

// procedure TN_CMCaptDevDemo1Form.timer_checkTimer
procedure TN_CMCaptDevDemo1Form.timer_checkTimer(Sender: TObject);
begin

end; // procedure TN_CMCaptDevDemo1Form.timer_checkTimer

// procedure TN_CMCaptDevDemo1Form.UpDown1Click
procedure TN_CMCaptDevDemo1Form.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
//  inherited;
end; // procedure TN_CMCaptDevDemo1Form.UpDown1Click

// procedure TN_CMCaptDevDemo1Form.tbRight90Click

//**************************************** TN_CMCaptDevDemo1Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDevDemo1Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDevDemo1Form.tb180Click

//************************************ TN_CMCaptDevDemo1Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDevDemo1Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDevDemo1Form.tbFlipHorClick


//****************  TN_CMCaptDevDemo1Form class public methods  ************

//************************************* TN_CMCaptDevDemo1Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDevDemo1Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                          const ARect: TRect );
begin

  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length(CMOFPNewSlides^)-AInd] );

    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do

end; // end of TN_CMCaptDevDemo1Form.CMOFDrawThumb

//********************************** TN_CMCaptDevDemo1Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDevDemo1Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
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

end; // procedure TN_CMCaptDevDemo1Form.CMOFGetThumbSize

//************************************* TN_CMCaptDevDemo1Form.CMOFSetStatus ***
// Set and Show current Device (Form) status
//
//     Parameters
// AIntStatus - given Status (one of N_CMOF4xxx constants)
//
procedure TN_CMCaptDevDemo1Form.CMOFSetStatus( AIntStatus: integer );
begin
  CMOFCurIntStatus := AIntStatus;

  StatusLabel.Caption := Format( 'Device Status = %d', [AIntStatus] );
  StatusLabel.Font.Color  := clBlack;
  StatusShape.Pen.Color   := clBlack;
  StatusShape.Brush.Color := clBlack;

  StatusLabel.Repaint;
  StatusShape.Repaint;
end; // end of TN_CMCaptDevDemo1Form.CMOFSetStatus

// procedure TN_CMCaptDevDemo1Form.bnExitClick
procedure TN_CMCaptDevDemo1Form.bnExitClick( Sender: TObject );
begin

end; // procedure TN_CMCaptDevDemo1Form.bnExitClick

// procedure TN_CMCaptDevDemo1Form.bnSetupClick
procedure TN_CMCaptDevDemo1Form.bnSetupClick( Sender: TObject );
begin
  N_CMCDServObjDemo.CDSSettingsDlg( N_CMCDServObjDemo.PProfile );
end; // procedure TN_CMCaptDevDemo1Form.bnSetupClick

//********************************** TN_CMCaptDevDemo1Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDevDemo1Form.CMOFCaptureSlide(): integer;
var
  i: Integer;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  FileName: string;
  TestDIBParams: TN_TestDIBParams;
  Label CapturedDIB_Ready;
begin
  Result := 0;
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number

  Inc( CMOFFileNum );
  FileName := K_ExpandFileName( Format( '(##Exe#)sensor%d.jpg', [CMOFFileNum] ));

  if not FileExists( FileName ) then
  begin
    CMOFFileNum := 1;
    FileName := K_ExpandFileName( Format( '(##Exe#)sensor%d.jpg', [CMOFFileNum] ));

    if not FileExists( FileName ) then // no image files, generate Test image
    begin
      N_CreateTestDIB8( 1, @TestDIBParams );
      TestDIBParams.TDPIndsColor  := -1;
      TestDIBParams.TDPWidth      := 500;
      TestDIBParams.TDPHeight     := 500;
//        TestDIBParams.TDPString := format( 'Captured %d from %s ',
//                                    [CurNum, APDevProfile.CMDPProductName] );
      CapturedDIB := N_CreateTestDIB8( 0, @TestDIBParams );
      goto CapturedDIB_Ready;
    end; // if not FileExists then // no image files, generate Test image

  end;

  //*** Here: FileName exists, use it

  CapturedDIB := TN_DIBObj.Create( FileName );
  goto CapturedDIB_Ready;

  CapturedDIB_Ready: //************************

  NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB, @(CMOFPProfile^.CMAutoImgProcAttrs) );
  NewSlide.SetAutoCalibrated();
  NewSlide.ObjAliase := IntToStr( CMOFNumCaptured );

  with NewSlide.P()^ do
  begin
    CMSSourceDescr := CMOFPProfile^.CMDPCaption;
    NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
    CMSMediaType := CMOFPProfile^.CMDPMTypeID;
  end;

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

end; // end of TN_CMCaptDevDemo1Form.CMOFCaptureSlide

//********************************** TN_CMCaptDevDemo1Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDevDemo1Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDevDemo1Form.CurStateToMemIni

//********************************** TN_CMCaptDevDemo1Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDevDemo1Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDevDemo1Form.MemIniToCurState

//*************************************** TN_CMCaptDevDemo1Form.bnTestClick ***
// Temporary test
//
procedure TN_CMCaptDevDemo1Form.bnTestClick( Sender: TObject );
begin
  N_Dump1Str( '' );
  N_Dump1Str( 'bnTestClick' );

end; // procedure TN_CMCaptDevDemo1Form.bnTestClick

end.


