unit N_CMCaptDev33SF;
// Form for capture Images from CSH ( Kodak ) Devices
// 2014.05.16 Created by Valery Ovechkin
// 2014.08.22 Standartization by Valery Ovechkin

interface

{$IFNDEF VER150} //***** not Delphi 7

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1,
  MPlayer, IdIOHandler, IdIOHandlerStream, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdContext, IdCustomTCPServer, IdTCPServer;

type TN_CMCaptDev33Form = class( TN_BaseForm )
    MainPanel: TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit: TButton;
    ThumbsRFrame: TN_Rast1Frame;
    SlideRFrame: TN_Rast1Frame;
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
    cbAutoTake: TCheckBox;
    TimerAutotake: TTimer;
    IdTCPServer1: TIdTCPServer;
    StatusLabel: TLabel;
    StatusShape: TShape;
    TimerFirstStart: TTimer;

    //****************  TN_CMCaptDev33SForm class handlers  ******************

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
    procedure bnCaptureClick   ( Sender: TObject );
    procedure cbAutoTakeClick  ( Sender: TObject );
    procedure TimerAutotakeTimer  ( Sender: TObject );
    procedure IdTCPServer1Execute ( AContext: TIdContext );
    procedure SetStatus           ( Status: string );
    procedure TimerFirstStartTimer( Sender: TObject );
    procedure pnFilterClick       ( Sender: TObject );
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
    ProcessFirstSeen: Boolean;
    SlidesCountTemp:  Integer;           // to know if image was actually taken
    IsFirstCapture:   Boolean;           // to start capture right away, nevermind the slides count isn't raised
    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer; const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer; AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev33SForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown   = 0;
  N_CMOF4Manual    = 1;
  N_CMOF4Auto      = 2;

implementation

uses
  math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev0,
  N_CMCaptDev33S, TlHelp32;
{$R *.dfm}

//****************  TN_CMCaptDev33SForm class handlers  ******************

//********************************************** TN_CMCaptDev33SForm.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev33Form.FormShow( Sender: TObject );
var
  ResCode: Integer;
begin
  N_Dump1Str( 'CSH 2 Start FormShow' );
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

  try // initialization

  ResCode := N_CMCDServObj33.AcquisitionDllInit_ext( nil ); // Init DLL

  if ( ResCode <> 0 ) then // DLL Initialization error
  begin
    N_CMV_ShowCriticalError( 'CSH', 'DLL Initialization error = ' + IntToStr( ResCode ) );
    Exit;
  end; // if ( ResCode <> 1 ) then // DLL Initialization error

  N_CMCDServObj33.XMLHandleRequest := N_CMCDServObj33.AcquisitionXMLCreate_ext();

  if ( nil = N_CMCDServObj33.XMLHandleRequest ) then // Empty XML request
  begin
    N_CMV_ShowCriticalError( 'CSH', 'AcquisitionXMLCreate = nil' );
    Exit;
  end; // if ( nil = XMLHandleRequest ) then // Empty XML request

  if N_CMCDServObj33.AutoTakeNeeded then
  begin
    cbAutoTake.Visible := True;
  end;

  IsFirstCapture := True; // auto start

  if N_CMCDServObj33.Devices[N_CMCDServObj33.CurrentDevice].Lines[N_CMCDServObj33.CurrentLine].Async then
  begin
    StatusLabel.Visible := True;
    StatusShape.Visible := True;
  end;
  
  except // initialization exception
    on E : Exception do
    begin
      K_CMShowMessageDlg( E.ClassName + ' error raised, with message: ' + E.Message, mtError );
      Exit();
    end;
  end;

  tbRotateImage.Visible := False;

  TimerFirstStart.Enabled := True;

  N_Dump1Str( 'CSH 2 End FormShow' );
end; // procedure TN_CMCaptDev33SForm.FormShow

//******************************************* TN_CMCaptDev33SForm.SetStatus ***
// Setting status of Device
//
//     Parameters
// Status - text status taken from ini
//
procedure TN_CMCaptDev33Form.SetStatus( Status: string );
begin
  if Status = 'off' then
  begin
    StatusLabel.Caption := 'Disconnected';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end;
  if Status = 'standby' then
  begin
    StatusLabel.Caption := 'Waiting';
    StatusLabel.Font.Color  := TColor( $168EF7 );
    StatusShape.Pen.Color   := TColor( $168EF7 );
    StatusShape.Brush.Color := TColor( $168EF7 );
  end;
  if Status = 'ready' then
  begin
    StatusLabel.Caption := 'Ready';
    StatusLabel.Font.Color  := clGreen;
    StatusShape.Pen.Color   := clGreen;
    StatusShape.Brush.Color := clGreen;
  end;
  if Status = 'error' then
  begin
    StatusLabel.Caption := 'Disconnected';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end;
end; // procedure TN_CMCaptDev33SForm.SetStatus( Status: string );

//********************************* TN_CMCaptDev33SForm.IdTCPServer1Execute ***
// Receiving messages to TCP server
//
//     Parameters
// Status - text status taken from ini
//
procedure TN_CMCaptDev33Form.IdTCPServer1Execute( AContext: TIdContext );
var
  sName, Status: String;
  Position, PositionEnd: Integer;
begin

  while AContext.Connection.Socket.Connected do
  begin
    sName := AContext.Connection.Socket.ReadLn;

    // ***** parsing status from message
    Position := Pos( '<property key="status" value="', sName );
    if Position > 0 then
    begin
      Position := Position + 30;
      PositionEnd := Pos('" />', sName);
      Status := Copy( sName, Position, PositionEnd-Position );
      N_Dump1Str('Status received = '+ Status);
      SetStatus(Status);
    end;
  end;

  AContext.Connection.Disconnect;
end; // procedure TN_CMCaptDev33SForm.IdTCPServer1Execute( AContext: TIdContext );

//********************************************* TN_CMCaptDev33SForm.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev33Form.FormClose( Sender: TObject; var Action: TCloseAction );
var
  WrkDir : string;

  XMLDoc: TN_CMV_XML;
  XMLRequestStr, XMLResponseStr: AnsiString;
begin
  TimerAutotake.Enabled := False;

  with N_CMCDServObj33 do
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

  // ***** closing moved here
  N_CMCDServObj33.AcquisitionXMLDestroy_ext( N_CMCDServObj33.XMLHandleRequest );
  N_CMCDServObj33.AcquisitionDllRelease_ext( nil );

  CMOFDrawSlideObj.Free;
  N_Dump2Str( 'CMOther33Form.FormClose' );
  Inherited;
end; // procedure TN_CMCaptDev33SForm.FormClose( Sender: TObject; var Action: TCloseAction );

// procedure TN_CMCaptDev33SForm.FormKeyDown
procedure TN_CMCaptDev33Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev33SForm.FormKeyDown

// procedure TN_CMCaptDev33SForm.FormKeyUp
procedure TN_CMCaptDev33Form.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev33SForm.FormKeyUp

// procedure TN_CMCaptDev33SForm.SlidePanelResize
procedure TN_CMCaptDev33Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw

  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev33SForm.SlidePanelResize

//***************************************** TN_CMCaptDev33SForm.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev33Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  if not N_CMCDServObj33.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj33.Handle2D, 0, 10010, 1 ) then
    N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  if not N_CMCDServObj33.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj33.Handle2D, 0, 10010, 1 ) then
    N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  if not N_CMCDServObj33.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj33.Handle2D, 0, 10010, 1 ) then
    N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  N_CMCDServObj33.ShowUpdatedImage();

  //K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev33SForm.tbLeft90Click

//**************************************** TN_CMCaptDev33SForm.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev33Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  if not N_CMCDServObj33.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj33.Handle2D, 0, 10010, 1 ) then
        N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  N_CMCDServObj33.ShowUpdatedImage();
  //K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev33SForm.tbRight90Click

//******************************** TN_CMCaptDev33SForm.TimerFirstStartTimer ***
// Auto start timer
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev33Form.TimerFirstStartTimer( Sender: TObject );
begin
  inherited;

  if N_CMCDServObj33.AutoTakeNeeded then
  begin
    //cbAutoTake.Visible := True;
    if N_CMCDServObj33.PProfile.CMDPStrPar2 <> '' then
      cbAutoTake.Checked := StrToBool(N_CMCDServObj33.PProfile.CMDPStrPar2);
  end;

  // ***** first capture always starts if autotake
  if IsFirstCapture then
  if cbAutoTake.Checked then // autotake enabled
  begin
    IsFirstCapture := False;

    //bnCapture.OnClick(Nil);
    TimerAutotake.Enabled := True;
  end;
  TimerFirstStart.Enabled := False;
end; // procedure TN_CMCaptDev33Form.TimerFirstStartTimer( Sender: TObject );

//******************************** TN_CMCaptDev33SForm.TimerFirstStartTimer ***
// Auto-Take timer
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev33Form.TimerAutotakeTimer( Sender: TObject );
begin
  inherited;
//  TimerAutotake.Enabled := False;

  if bnCapture.Enabled then // if possible
//  if ( SlidesCountTemp <> Length( N_CMCDServObj33.PSlideArr^ ) ) then // if still going (not closed manually)
  if N_CMCDServObj33.AutoTakeNeeded then // if needed
  if N_CMCDServObj33.PProfile.CMDPStrPar2 <> '' then //if checked
  begin
    bnCapture.OnClick( Nil );
  end;

//  TimerAutotake.Enabled := True;
end; // procedure TN_CMCaptDev33SForm.TimerAutotakeTimer( Sender: TObject );

// procedure TN_CMCaptDev33SForm.UpDown1Click
procedure TN_CMCaptDev33Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev33SForm.UpDown1Click

// procedure TN_CMCaptDev33SForm.tbRight90Click

//******************************************** TN_CMCaptDev33SForm.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev33Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  if not N_CMCDServObj33.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj33.Handle2D, 0, 10009, 1 ) then
    N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  N_CMCDServObj33.ShowUpdatedImage();
  //K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev33SForm.tb180Click

//**************************************** TN_CMCaptDev33SForm.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev33Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  if not N_CMCDServObj33.ImageProcessor2DEnableAlgo_ext( N_CMCDServObj33.Handle2D, 0, 10008, 1 ) then
    N_CMV_ShowCriticalError( 'CSH', 'ImageProcessor2DEnableAlgo_ext error' );

  N_CMCDServObj33.ShowUpdatedImage();

  //K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev33SForm.tbFlipHorClick


//****************  TN_CMCaptDev33SForm class public methods  ************

//***************************************** TN_CMCaptDev33SForm.CMOFDrawThumb ***
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
procedure TN_CMCaptDev33Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin

  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do

end; // end of TN_CMCaptDev33SForm.CMOFDrawThumb

//************************************** TN_CMCaptDev33SForm.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev33Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: Integer;
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

end; // procedure TN_CMCaptDev33SForm.CMOFGetThumbSize

//************************************** TN_CMCaptDev33SForm.bnCaptureClick ***
// Capture button
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev33Form.bnCaptureClick( Sender: TObject );
var
  StartFile, FinishFile, s: String;
  filter: Boolean;
  ImgCount: Integer;
begin
  inherited;

  Screen.Cursor := crHourGlass;

  SlidesCountTemp := Length( N_CMCDServObj33.PSlideArr^ ); // slides count before capture

  bnSetup.Enabled   := False;
  bnCapture.Enabled := False;
  StartFile  := N_CMV_GetWrkDir() + 'csh1.wav';
  FinishFile := N_CMV_GetWrkDir() + 'csh2.wav';

  //TimerAutotake.Enabled := True;

  if FileExists( StartFile ) then
  begin
    mp.FileName := StartFile;
    mp.Open;
    mp.Play;
  end; // if FileExists( StartFile ) then

  ImgCount := N_CMCDServObj33.CaptureById( N_CMCDServObj33.PProfile,
                                           Self,
                                           N_CMCDServObj33.CurrentDevice,
                                           N_CMCDServObj33.CurrentLine ); // for autotake

  filter := True;
  s := N_CMCDServObj33.PProfile.CMDPStrPar1;

  Screen.Cursor := crDefault;

  if ( 0 < Length( s ) ) then
    filter := ( '1' <> Copy( s, 1, 1 ) );
//filter := false;  // debug code
   filter := filter and not(N_CMCDServObj33.HideFiltersFlag);

  if ( 0 < ImgCount ) then
  begin
//    N_CMCDServObj33.CaptForm.pnFilter.Visible := filter;
    pnFilter.Visible := filter;

    if filter then
    begin
      N_CMCDServObj33.FillCSHFilter( DicomFileName );
      N_CMCDServObj33.CSHFilterApply( nil );
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

end; // procedure TN_CMCaptDev33SForm.bnCaptureClick( Sender: TObject );

//**************************************** TN_CMCaptDev33SForm.bnSetupClick ***
// Setup button
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev33Form.bnSetupClick( Sender: TObject );
begin
  inherited;
  bnSetup.Enabled   := False;
  bnCapture.Enabled := False;
  N_CMCDServObj33.CDSSettingsDlg( N_CMCDServObj33.PProfile );
  bnSetup.Enabled   := True;
  bnCapture.Enabled := True;
end; // procedure TN_CMCaptDev33SForm.bnSetupClick

//************************************* TN_CMCaptDev33SForm.cbAutoTakeClick ***
// Auto-take ComboBox
//
//     Parameters
// Sender - Event Sender
//
procedure TN_CMCaptDev33Form.cbAutoTakeClick( Sender: TObject );
begin
  inherited;
  N_CMCDServObj33.PProfile.CMDPStrPar2 := BoolToStr(cbAutoTake.Checked);

  if cbAutoTake.Checked then
  begin
    //bnCapture.OnClick(Nil);
    TimerAutotake.Enabled := True;
  end
  else
    TimerAutotake.Enabled := False;
end;

//************************************** TN_CMCaptDev33SForm.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev33Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev33SForm.CurStateToMemIni

//************************************** TN_CMCaptDev33SForm.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev33Form.MemIniToCurState();
begin
  Inherited;
end;
procedure TN_CMCaptDev33Form.pnFilterClick(Sender: TObject);
begin
  inherited;

end;

// end of procedure TN_CMCaptDev33SForm.MemIniToCurState

{$ELSE} //************** no code in Delphi 7
implementation
{$ENDIF VER150} //****** no code in Delphi 7

end.


