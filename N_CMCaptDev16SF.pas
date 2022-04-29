unit N_CMCaptDev16SF;
// Form for capture Images from CSH ( Kodak ) Devices
// 2014.05.16 Created by Valery Ovechkin
// 2014.08.22 Standartization by Valery Ovechkin

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1,
  MPlayer, IdIOHandler, IdIOHandlerStream, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient;

type TN_CMCaptDev16Form = class( TN_BaseForm )
    MainPanel: TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit: TButton;
    ThumbsRFrame: TN_Rast1Frame;
    SlideRFrame: TN_Rast1Frame;
    TimerCheck: TTimer;
    CtrlsPanelParent: TPanel;
    CtrlsPanel: TPanel;
    bnSetup: TButton;
    bnCapture: TButton;
    pnFilter: TPanel;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    mp: TMediaPlayer;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;

    //****************  TN_CMCaptDev16SForm class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure SlidePanelResize ( Sender: TObject );
    procedure tbLeft90Click    ( Sender: TObject );
    procedure tbRight90Click   ( Sender: TObject );
    procedure tb180Click       ( Sender: TObject );
    procedure tbFlipHorClick   ( Sender: TObject );
    procedure UpDown1Click     ( Sender: TObject; Button: TUDBtnType );
    procedure bnSetupClick     ( Sender: TObject );
    procedure FormCreate       ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
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
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev16SForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown   = 0;
  N_CMOF4Manual    = 1;
  N_CMOF4Auto      = 2;

implementation

uses
  math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev0, {N_CMCaptDev16} N_CMCaptDev16S;
{$R *.dfm}

//****************  TN_CMCaptDev16SForm class handlers  ******************

//********************************************** TN_CMCaptDev16SForm.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev16Form.FormShow( Sender: TObject );
var
  ResCode: Integer;
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

  ResCode := N_CMCDServObj16.AcquisitionDllInit_ext( nil ); // Init DLL

  if ( ResCode <> 0 ) then // DLL Initialization error
  begin
    N_CMV_ShowCriticalError( 'CSH', 'DLL Initialization error = ' + IntToStr( ResCode ) );
    Exit;
  end; // if ( ResCode <> 1 ) then // DLL Initialization error

  N_CMCDServObj16.XMLHandleRequest := N_CMCDServObj16.AcquisitionXMLCreate_ext();

  if ( nil = N_CMCDServObj16.XMLHandleRequest ) then // Empty XML request
  begin
    N_CMV_ShowCriticalError( 'CSH', 'AcquisitionXMLCreate = nil' );
    Exit;
  end; // if ( nil = XMLHandleRequest ) then // Empty XML request

  tbRotateImage.Visible := False;
  TimerCheck.Enabled    := True;
  N_Dump1Str( 'E2V End FormShow' );
end; // procedure TN_CMCaptDev16SForm.FormShow

//********************************************* TN_CMCaptDev16SForm.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev16Form.FormClose( Sender: TObject; var Action: TCloseAction );
var
  WrkDir : string;

  XMLDoc: TN_CMV_XML;
  XMLRequestStr, XMLResponseStr: AnsiString;
begin
  TimerCheck.Enabled := False;

  with N_CMCDServObj16 do
  begin

  // ***** unregister notifications final
   XMLRequestStr := N_StringToAnsi(
  '<?xml version="1.0" encoding="utf-8" ?>' +
  '<trophy type="acquisition">' +
  '<acquisition command="unregisternotificationport" version="1.0" >' +
  '<notification port="' + '50000' + '" />' +
  '</acquisition>' +
  '</trophy>' );

  AcquisitionXMLSet_ext( XMLHandleRequest, @XMLRequestStr[1] );
  XMLHandleResponse := Acquisition_ext( XMLHandleRequest );

  XMLResponseStr := AcquisitionXMLGet_ext( XMLHandleResponse );
  XMLDoc := N_CMV_XMLDocLoad( N_AnsiToString( XMLResponseStr ), False );

  N_Dump1Str(N_AnsiToString(XMLResponseStr));

  end;

  WrkDir := N_CMV_GetWrkDir();
  K_DeleteFolderFilesEx( WrkDir, nil, '*.dcm', [K_dffRecurseSubfolders,K_dffRemoveReadOnly] );
  K_DeleteFolderFilesEx( WrkDir, nil, '*.xml', [K_dffRecurseSubfolders,K_dffRemoveReadOnly] );
  K_DeleteFile( WrkDir + 'trophy.bmp' );
  K_DeleteFile( WrkDir + 'cshproc.bmp' );

  N_CMCDServObj16.AcquisitionXMLDestroy_ext( N_CMCDServObj16.XMLHandleRequest );
  N_CMCDServObj16.AcquisitionDllRelease_ext( nil );

  CMOFDrawSlideObj.Free;
  N_Dump2Str( 'CMOther16Form.FormClose' );
  Inherited;
end;

procedure TN_CMCaptDev16Form.FormCreate(Sender: TObject);
begin
  inherited;
end;

// TN_CMCaptDev16SForm.FormClose

// procedure TN_CMCaptDev16SForm.FormKeyDown
procedure TN_CMCaptDev16Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev16SForm.FormKeyDown

// procedure TN_CMCaptDev16SForm.FormKeyUp
procedure TN_CMCaptDev16Form.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev16SForm.FormKeyUp

// procedure TN_CMCaptDev16SForm.SlidePanelResize
procedure TN_CMCaptDev16Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw

  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev16SForm.SlidePanelResize

//***************************************** TN_CMCaptDev16SForm.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev16Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  if not N_CMCDServObj16.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj16.Handle2D, 0, 10010, 1 ) then
    N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  if not N_CMCDServObj16.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj16.Handle2D, 0, 10010, 1 ) then
    N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  if not N_CMCDServObj16.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj16.Handle2D, 0, 10010, 1 ) then
    N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  N_CMCDServObj16.ShowUpdatedImage();

  //K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev16SForm.tbLeft90Click

//**************************************** TN_CMCaptDev16SForm.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev16Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  if not N_CMCDServObj16.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj16.Handle2D, 0, 10010, 1 ) then
        N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  N_CMCDServObj16.ShowUpdatedImage();
  //K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev16SForm.tbRight90Click

// procedure TN_CMCaptDev16SForm.UpDown1Click
procedure TN_CMCaptDev16Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev16SForm.UpDown1Click

// procedure TN_CMCaptDev16SForm.tbRight90Click

//******************************************** TN_CMCaptDev16SForm.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev16Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  if not N_CMCDServObj16.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj16.Handle2D, 0, 10009, 1 ) then
    N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  N_CMCDServObj16.ShowUpdatedImage();
  //K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev16SForm.tb180Click

//**************************************** TN_CMCaptDev16SForm.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev16Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  if not N_CMCDServObj16.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj16.Handle2D, 0, 10008, 1 ) then
    N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  N_CMCDServObj16.ShowUpdatedImage();

  //K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev16SForm.tbFlipHorClick


//****************  TN_CMCaptDev16SForm class public methods  ************

//***************************************** TN_CMCaptDev16SForm.CMOFDrawThumb ***
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
procedure TN_CMCaptDev16Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin

  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do

end; // end of TN_CMCaptDev16SForm.CMOFDrawThumb

//************************************** TN_CMCaptDev16SForm.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev16Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: Integer;
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

end; // procedure TN_CMCaptDev16SForm.CMOFGetThumbSize

//***************************************** TN_CMCaptDev16SForm.CMOFSetStatus ***
// procedure TN_CMCaptDev16SForm.bnExitClick
procedure TN_CMCaptDev16Form.bnCaptureClick(Sender: TObject);
var
  StartFile, FinishFile, s: String;
  filter: Boolean;
  ImgCount: Integer;
begin
  inherited;
  bnSetup.Enabled   := False;
  bnCapture.Enabled := False;
  StartFile  := N_CMV_GetWrkDir() + 'csh1.wav';
  FinishFile := N_CMV_GetWrkDir() + 'csh2.wav';

  if FileExists( StartFile ) then
  begin
    mp.FileName := StartFile;
    mp.Open;
    mp.Play;
  end; // if FileExists( StartFile ) then

  ImgCount := N_CMCDServObj16.CaptureById( N_CMCDServObj16.PProfile,
                                           Self,
                                           N_CMCDServObj16.CurrentDevice,
                                           N_CMCDServObj16.CurrentLine );

  filter := True;
  s := N_CMCDServObj16.PProfile.CMDPStrPar1;

  if ( 0 < Length( s ) ) then
    filter := ( '1' <> Copy( s, 1, 1 ) );
//filter := false;  // debug code
   filter := filter and not(N_CMCDServObj16.HideFiltersFlag);

  if ( 0 < ImgCount ) then
  begin
//    N_CMCDServObj16.CaptForm.pnFilter.Visible := filter;
    pnFilter.Visible := filter;

    if filter then
    begin
      N_CMCDServObj16.FillCSHFilter( DicomFileName );
      N_CMCDServObj16.CSHFilterApply( nil );
    end; // if filter then

  end; // if ( 0 < ImgCount ) then

  if FileExists( FinishFile ) then
  begin
    mp.FileName := FinishFile;
    mp.Open;
    mp.Play;
  end; // if FileExists( FinishFile ) then

  bnSetup.Enabled   := True;
  bnCapture.Enabled := True;
//N_Dump2Str( '!!! CbnCapture.Enabled := True' );  // debug code

end;

// procedure TN_CMCaptDev16SForm.bnSetupClick
procedure TN_CMCaptDev16Form.bnSetupClick( Sender: TObject );
begin
  inherited;
  bnSetup.Enabled   := False;
  bnCapture.Enabled := False;
  N_CMCDServObj16.CDSSettingsDlg( N_CMCDServObj16.PProfile );
  bnSetup.Enabled   := True;
  bnCapture.Enabled := True;
end; // procedure TN_CMCaptDev16SForm.bnSetupClick

//************************************** TN_CMCaptDev16SForm.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev16Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev16SForm.CurStateToMemIni

//************************************** TN_CMCaptDev16SForm.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev16Form.MemIniToCurState();
begin
  Inherited;
end;
// end of procedure TN_CMCaptDev16SForm.MemIniToCurState

end.


