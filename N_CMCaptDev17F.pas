unit N_CMCaptDev17F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0, N_CMCaptDev0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1, N_CML2F;

const
  WM_PROGENY_COMMAND = WM_USER + 3;
  WM_PROGENY_HANDLE  = WM_USER + 4;

type TN_CMCaptDev17Form = class( TN_BaseForm )
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
    bnStopCapture: TButton;
    bnStartCapture: TButton;

    //******************  TN_CMCaptDev17Form class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction );
                                                                       override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
    procedure SlidePanelResize ( Sender: TObject );
    procedure tbLeft90Click    ( Sender: TObject );
    procedure tbRight90Click   ( Sender: TObject );
    procedure tb180Click       ( Sender: TObject );
    procedure tbFlipHorClick   ( Sender: TObject );
    procedure UpDown1Click     ( Sender: TObject; Button: TUDBtnType );
    procedure TimerImageTimer(Sender: TObject);
    procedure bnClick(Sender: TObject);
    procedure OnCommand( var Msg: TMessage ); message WM_PROGENY_COMMAND;
    procedure OnHandle ( var Msg: TMessage ); message WM_PROGENY_HANDLE;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bnSetupClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bnStopCaptureClick(Sender: TObject);
    procedure bnStartCaptureClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
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

    ThisForm: TN_CMCaptDev17Form;        // Pointer to this form

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer;
                                                           const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide ( CapturedDIB: TN_DIBObj ): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;

end; // type TN_CMCaptDev17Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

var
  ProgenyHandle: LongInt; // driver's window handle

  PelsPerInch: integer; // pixels per inch received from a driver
  FlagStop: Boolean;

implementation

uses
  Math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev17;
{$R *.dfm}

//**********************  TN_CMCaptDev17Form class handlers  ******************

//********************************************* TN_CMCaptDev17Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev17Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'Progeny Start FormShow' );

  bnStartCapture.Enabled := False;
  bnStopCapture.Enabled := False;
  bnSetup.Enabled := False;

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
  tbRotateImage.Visible := True;

  FlagStop := False;

  N_CMCDServObj17.StartDriver( ThisForm.Handle );

  N_Dump1Str( 'Progeny End FormShow' );
end; // procedure TN_CMCaptDev17Form.FormShow

//******************************************** TN_CMCaptDev17Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev17Form.FormClose( Sender: TObject;
                                                     var Action: TCloseAction );
begin
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  N_Dump2Str( 'CMOther11Form.FormClose' );
  Inherited;
end;

//*************************************** TN_CMCaptDev17Form.FormCloseQuery ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// CanClose
//
// OnClose Self handler
//
procedure TN_CMCaptDev17Form.FormCloseQuery(Sender: TObject;
                                                         var CanClose: Boolean);
begin
  inherited;
  PostMessage( HWND(ProgenyHandle), WM_PROGENY_COMMAND, 1, 0 );
end; // TN_CMCaptDev17Form.FormCloseQuery

procedure TN_CMCaptDev17Form.FormCreate(Sender: TObject);
begin
  inherited;

end;

//****************************************** TN_CMCaptDev17Form.FormKeyDown ***
// If key is pressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev17Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev17Form.FormKeyDown

//******************************************** TN_CMCaptDev17Form.FormKeyUp ***
// If key is unpressed
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev17Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
begin
  Exit;
end; 

procedure TN_CMCaptDev17Form.FormPaint(Sender: TObject);
begin
  inherited;
end;

// procedure TN_CMCaptDev17Form.FormKeyUp

// procedure TN_CMCaptDev17Form.SlidePanelResize
procedure TN_CMCaptDev17Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev17Form.SlidePanelResize

//***************************************** TN_CMCaptDev17Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev17Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev17Form.tbLeft90Click

//**************************************** TN_CMCaptDev17Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev17Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end;

procedure TN_CMCaptDev17Form.TimerImageTimer(Sender: TObject);
begin
  inherited;
  
end;

// TN_CMCaptDev17Form.tbRight90Click

// procedure TN_CMCaptDev17Form.UpDown1Click
procedure TN_CMCaptDev17Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev17Form.UpDown1Click

//******************************************* TN_CMCaptDev17Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev17Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev17Form.tb180Click

//*************************************** TN_CMCaptDev17Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev17Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev17Form.tbFlipHorClick


//**********************  TN_CMCaptDev17Form class public methods  ************

//**************************************** TN_CMCaptDev17Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev17Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                   CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev17Form.CMOFDrawThumb

//************************************* TN_CMCaptDev17Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev17Form.CMOFGetThumbSize( ADGObj: TN_DGridBase;
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
end; // procedure TN_CMCaptDev17Form.CMOFGetThumbSize

//****************************************** TN_CMCaptDev17Form.bnExitClick ***
// Exit
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev17Form.bnClick(Sender: TObject);
begin
  inherited;
  PostMessage( HWND(ProgenyHandle), WM_PROGENY_COMMAND, 0, 0 );
end; // procedure TN_CMCaptDev17Form.bnExitClick

//***************************************** TN_CMCaptDev17Form.bnSetupClick ***
// Setup
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev17Form.bnSetupClick(Sender: TObject);
begin
  inherited;
  FlagStop := True;
  PostMessage( HWND(ProgenyHandle), WM_PROGENY_COMMAND, 3, 0 );
  //PostMessage( HWND(ProgenyHandle), WM_PROGENY_COMMAND, 2, 0 );

end; // procedure TN_CMCaptDev17Form.bnSetupClick

//*********************************** TN_CMCaptDev17Form.bnStopCaptureClick ***
// Stop capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev17Form.bnStopCaptureClick(Sender: TObject);
begin
  inherited;
  PostMessage( HWND(ProgenyHandle), WM_PROGENY_COMMAND, 3, 0 );
end;

// procedure TN_CMCaptDev17Form.bnStopCaptureClick

//********************************** TN_CMCaptDev17Form.bnStartCaptureClick ***
// Start capture
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev17Form.bnStartCaptureClick(Sender: TObject);
begin
  inherited;
  PostMessage( HWND(ProgenyHandle), WM_PROGENY_COMMAND, 0, 0 );
end; // procedure TN_CMCaptDev17Form.bnStartCaptureClick

//************************************* TN_CMCaptDev17Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev17Form.CMOFCaptureSlide( CapturedDIB: TN_DIBObj ): Integer;
var
  i: Integer;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format('Progeny+ Start CMOFCaptureSlide %d', [CMOFNumCaptured]));

  // set bmi calculated with pixel size
  with CapturedDIB.DIBInfo.bmi do
  begin
    if PelsPerInch <> 0 then
      biXPelsPerMeter := PelsPerInch;
    N_Dump1Str('~~~~~ Progeny, dpi = '+IntToStr(biXPelsPerMeter));
    biXPelsPerMeter := Round( (biXPelsPerMeter/2.54)*100 ); // pixels per meter
    N_Dump1Str('~~~~~ Progeny, per meter = '+IntToStr(biXPelsPerMeter));
    biYPelsPerMeter := biXPelsPerMeter;
  end;

  // ***** Here: CapturedDIB is OK
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

  N_Dump1Str(Format('Progeny Fin CMOFCaptureSlide %d', [CMOFNumCaptured]));
  Result := 0;
end; // end of TN_CMCaptDev17Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev17Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev17Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev17Form.CurStateToMemIni

//************************************* TN_CMCaptDev17Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev17Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev17Form.MemIniToCurState

//******************************************* TN_CMCaptDev13aForm.OnCommand ***
// Windows message from Progeny ( reply )
//
//     Parameters
// Msg - incoming Windows message
//
procedure TN_CMCaptDev17Form.OnCommand( var Msg: TMessage );
var
  WP, LP: Integer;
  DIB: TN_DIBObj;
  WrkDirTemp: string;
  // set aquired status
  procedure SetStatus( Status: Integer );
  begin
    case LP of
        0: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        1: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        2: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        3: begin
          StatusLabel.Caption := 'Device Initialization';
          StatusLabel.Font.Color  := TColor( $168EF7 ); // orange color
          StatusShape.Pen.Color   := TColor( $168EF7 );
          StatusShape.Brush.Color := TColor( $168EF7 );

          bnStartCapture.Enabled := True;
          bnStopCapture.Enabled := False;
          bnSetup.Enabled := False;           

          if (not FlagStop) and (ThisForm.Active) then
          begin          
            bnStartCaptureClick( Nil ); // start capture (press capture button)
          end;

          if FlagStop then
          begin
            PostMessage( HWND(ProgenyHandle), WM_PROGENY_COMMAND, 2, 0 );
            FlagStop := False;           
          end; 

          //FlagReady := False;
        end;
        4: begin
          StatusLabel.Caption := 'Optimizing captured image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        5: begin
          StatusLabel.Caption := 'Optimizing captured image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        6: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        7: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        8: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        9: begin
          //StatusLabel.Caption := 'Capture cancelled';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        10: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        11: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        12: begin
          //StatusLabel.Caption := 'Device added';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        13: begin
          //StatusLabel.Caption := 'Clear';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        14: begin
          StatusLabel.Caption := 'Ready';
          StatusLabel.Font.Color  := clGreen;
          StatusShape.Pen.Color   := clGreen;
          StatusShape.Brush.Color := clGreen;
          bnStartCapture.Enabled := False;
          bnStopCapture.Enabled := True;
          bnSetup.Enabled := True;
          //FlagReady := True;
          N_Dump1Str('FlagReady := True;');
        end;
        15: begin
          StatusLabel.Caption := 'Capturing image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        16: begin
          StatusLabel.Caption := 'Capturing image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        17: begin
          StatusLabel.Caption := 'Capturing image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        18: begin
          StatusLabel.Caption := 'Capturing image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        19: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        20: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        21: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        22: begin
          StatusLabel.Caption := 'Optimizing captured image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        23: begin
          StatusLabel.Caption := 'N_CML2Form.LLLOther3Error.Caption';
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;

        // extra, only for cms
        24: begin
          StatusLabel.Caption := 'Device Initialization';
          StatusLabel.Font.Color  := TColor( $168EF7 ); // orange color
          StatusShape.Pen.Color   := TColor( $168EF7 );
          StatusShape.Brush.Color := TColor( $168EF7 );
          //FlagReady := False;
          bnSetup.Enabled := False;
        end;
        25: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          //FlagReady := False;
        end;
        end;
  end;

//********************************************** N_CreateDIBFromCMSIProgeny ***
// Create DIB object from given AFileName (with any extension) in cmsi Format
//
//     Parameters
// AFileName - given file name
// Result    - Returns resulting DIB object
//
function N_CreateDIBFromCMSIProgeny( AFileName: string ): TN_DIBObj;
var
  i: integer;
  FStream: TFileStream;
  Image: PDK_WIN32_Image;
begin
  FStream := nil; // to avoid warning
  Result := nil;
  try

  FStream := TFileStream.Create( AFileName, fmOpenRead );

  FStream.Read(Image, sizeof(PDK_WIN32_Image));
  N_Dump1Str('Progeny, Width = ' + IntToStr(Image.ImageWidth) +
          ', Height = ' + IntToStr(Image.ImageHeight) + ', Image Data Size = ' +
                                   IntToStr(Image.ImageDataSize) + ', Bits = ' +
                                     IntToStr(Image.ImageNumberOfBitsPerPixel));

  N_Dump1Str('Progeny, before reading image');

  if Image.ImageNumberOfBitsPerPixel = 8 then
  begin
    Result := TN_DIBObj.Create( Image.ImageWidth, Image.ImageHeight, pfCustom, -1, epfGray8 );

    for i := Image.ImageHeight-1 downto 0 do // along all pixel rows
      FStream.Read( (Result.PRasterBytes + i*Result.RRLineSize)^, Image.ImageWidth ); // read i-th row

  end else if Image.ImageNumberOfBitsPerPixel = 16 then
  begin
    N_Dump1Str('Progeny, creating image started');
    Result := TN_DIBObj.Create( Image.ImageWidth, Image.ImageHeight, pfCustom, -1, epfGray16 );
    N_Dump1Str('Progeny, DIB after created');
    for i := Image.ImageHeight-1 downto 0 do // along all pixel rows
    begin
      FStream.Read( (Result.PRasterBytes + i*Result.RRLineSize)^, 2*Image.ImageWidth ); // read i-th row
    end; // for i := 0 to NY-1 do // along all pixel rows

  end;
  N_Dump1Str('Progeny, DIB before cleaning');
  FStream.Free;
  except
    on E: Exception do
    begin
      FStream.Free;
      Result.Free;
      raise Exception.Create(E.Message);
    end;
  end; // try
end;

begin
  WP := Integer( Msg.WParam );
  LP := Integer( Msg.LParam );

  case WP of
    0: begin
      SetStatus( LP );
    end;
    1: begin
      WrkDirTemp := K_ExpandFileName( '(#TmpFiles#)' );
      WrkDirTemp := WrkDirTemp + 'CMSuiteProgeny.obj';

      N_Dump1Str( 'Progeny, filename = ' + WrkDirTemp );
      if FileExists( WrkDirTemp ) then
      begin
        N_Dump1Str('Progeny, before N_CreateDIBFromCMSIProgeny');
        DIB := N_CreateDIBFromCMSIProgeny(WrkDirTemp);
        N_Dump1Str('Progeny, before CMOFCaptureSlide');
        CMOFCaptureSlide( DIB );
        N_Dump1Str('Progeny, before DeleteFile');
        DeleteFile(WrkDirTemp);
      end;
    end;
    2: begin
      PelsPerInch := LP;
    end;     
  end;
end; // procedure TN_CMCaptDev17Form.OnCommand

//********************************************* TN_CMCaptDev17Form.OnHandle ***
// Receiving a driver's window handle
//
//     Parameters
// Msg - message received
//
procedure TN_CMCaptDev17Form.OnHandle( var Msg: TMessage );
var
  WP{, LP}: Integer;
begin
N_Dump1Str('Progeny, OnHandle started');
  WP := Integer( Msg.WParam );
  //LP := Integer( Msg.LParam );
  ProgenyHandle := WP;
  N_Dump1Str('Progeny, OnHandle ended');
end; // procedure TN_CMCaptDev17Form.OnHandle( var Msg: TMessage );

end.


