unit N_CMCaptDev13F;
// Form for capture Images from Apixia Devices
// 2014.02.21 created by Valery Ovechkin
// 2014.03.05 Fixed log strings from 'E2V' to 'Apixia' by Valery Ovechkin
// 2014.03.20 Fixed USB event listener by Valery Ovechkin
// 2014.03.21 Standartization and 'N_CMV_' prefix addition by Valery Ovechkin
// 2014.09.15 Fixed File exceptions processing ( like i/o 32, etc. ) by Valery Ovechkin
// 2014.09.15 Standartizing ( All functions parameters name starts from 'A' ) by Valery Ovechkin

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1;

const
  PSP_MSG_COMMAND  = WM_USER + 89; // Message from Apixia driver ( reply )
  PSP_MSG_PROGRESS = WM_USER + 90; // Message from Apixia driver ( progress )

type TN_CMCaptDev13Form = class( TN_BaseForm )
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
    ProgressBar: TProgressBar;
    brearm: TButton;

    //****************  TN_CMCaptDev13Form class handlers  ******************

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
    procedure UpDown1Click     ( Sender: TObject; Button: TUDBtnType );
    procedure bnSetupClick     ( Sender: TObject );
    procedure bnExitClick      ( Sender: TObject );

    procedure ApixiaOnCommand      ( var AMsg: TMessage ); message PSP_MSG_COMMAND;
    procedure ApixiaOnProgress     ( var AMsg: TMessage ); message PSP_MSG_PROGRESS;
    procedure ApixiaOnDeviceChange ( var AMsg: TMessage ); message WM_DEVICECHANGE;
    //procedure FormResize           ( Sender: TObject );
    procedure bRearmClick          ( Sender: TObject );
    procedure FormActivate         ( Sender: TObject ); override;

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
    ThisForm: TN_CMCaptDev13Form;        // Pointer to this form
    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: Integer; const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: Integer; AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMOFCaptureSlide ( ImageNum: Integer; Raw: Boolean ): Integer;
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev13Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Unknown   = 0;
  N_CMOF4Manual    = 1;
  N_CMOF4Auto      = 2;

implementation

uses
  math,
  K_CLib0, K_Parse, K_Script1,
  N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev13, N_CMCaptDev0;
{$R *.dfm}

//****************  TN_CMCaptDev13Form class handlers  ******************

//********************************************* TN_CMCaptDev13Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev13Form.FormShow( Sender: TObject );
begin
  N_Dump1Str( 'Apixia Start FormShow' );
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

  // ***** moved from Activate
  N_CMCDServObj13.ShowStatus( ThisForm, nil );
  N_CMV_USBReg( ThisForm.Handle, N_CMCDServObj13.USBHandle );
  N_CMCDServObj13.StartDriver( ThisForm.Handle );
  N_CMCDServObj13.ShowStatus( ThisForm, nil );

  N_Dump1Str( 'Apixia End FormShow' );
end; // procedure TN_CMCaptDev13Form.FormShow

//******************************************** TN_CMCaptDev13Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev13Form.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  N_CMV_USBUnreg( N_CMCDServObj13.USBHandle );
  N_CMCDServObj13.CloseDriver();
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;
  
  inherited;
  N_Dump2Str( 'CMOther13Form.FormClose' );
end; // procedure TN_CMCaptDev13Form.FormClose

//***************************************** TN_CMCaptDev13Form.FormActivate ***
// Perform needed Actions on Activate Self
//
//     Parameters
// Sender - Event Sender
//
// OnActivate Self handler
//
procedure TN_CMCaptDev13Form.FormActivate(Sender: TObject);
begin
  inherited;
  
end; // procedure TN_CMCaptDev13Form.FormActivate

// procedure TN_CMCaptDev13Form.FormKeyDown
procedure TN_CMCaptDev13Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then
end; // procedure TN_CMCaptDev13Form.FormKeyDown

// procedure TN_CMCaptDev13Form.FormKeyUp
procedure TN_CMCaptDev13Form.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
begin
  Exit;
end; // procedure TN_CMCaptDev13Form.FormKeyUp

// procedure TN_CMCaptDev13Form.cbAutoTakeClick
procedure TN_CMCaptDev13Form.cbAutoTakeClick( Sender: TObject );
begin
  inherited;
  //N_CMCDServObj13.ShowDeviceStatus( ThisForm );
end; // procedure TN_CMCaptDev13Form.cbAutoTakeClick

// procedure TN_CMCaptDev13Form.SlidePanelResize
procedure TN_CMCaptDev13Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw
  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev13Form.SlidePanelResize

//**************************************** TN_CMCaptDev13Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree counterclockwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev13Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev13Form.tbLeft90Click

//*************************************** TN_CMCaptDev13Form.tbRight90Click ***
// Rotate last captured Image by 90 degree clockwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev13Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // TN_CMCaptDev13Form.tbRight90Click

//************************************** TN_CMCaptDev13Form.ApixiaOnCommand ***
// Windows message from Apixia driver ( reply )
//
//     Parameters
// AMsg - incoming Windows message
//
procedure TN_CMCaptDev13Form.ApixiaOnCommand( var AMsg: TMessage );
var
  WP, LP: Integer;
begin
  WP := Integer( AMsg.WParam );
  LP := Integer( AMsg.LParam );
  N_CMCDServObj13.SetStatus( WP, LP );
  N_CMCDServObj13.ShowStatus( ThisForm, nil );

  N_Dump1Str( 'Apixia >> ExtMessage( Capture ): WP = ' + IntToStr( WP ) +
              ', LP = ' + IntToStr( LP ) );

  N_CMCDServObj13.ArmDevice( True, LP );
end; // procedure TN_CMCaptDev13Form.ApixiaOnCommand

//************************************* TN_CMCaptDev13Form.ApixiaOnProgress ***
// Windows message from Apixia driver ( scan progress )
//
//     Parameters
// AMsg - incoming Windows message
//
procedure TN_CMCaptDev13Form.ApixiaOnProgress( var AMsg: TMessage );
var
  LP, WP, Progress: Integer;
  cap: String;
begin
  WP := Integer( AMsg.WParam );
  LP := Integer( AMsg.LParam );

  if ( ( 2 > WP) or ( 2 > LP) ) then // trim false triggering 1 / 1
    Exit;

  Progress := 0;
  cap := 'Processing Lines ' + IntToStr( WP ) + ' / ' + IntToStr( LP );

  if ( 0 < LP ) then // correct value of lines / total
    Progress := ( WP * 100 ) div LP;

  N_CMCDServObj13.ShowStatusAux( ThisForm, nil, $900000, cap, False, True, Progress );
end; // procedure TN_CMCaptDev13Form.ApixiaOnProgress

//********************************* TN_CMCaptDev13Form.ApixiaOnDeviceChange ***
// Windows message from Apixia driver
//
//     Parameters
// AMsg - incoming Windows message
//
procedure TN_CMCaptDev13Form.ApixiaOnDeviceChange( var AMsg: TMessage );
begin
  N_CMCDServObj13.ProcessUSB( AMsg, ThisForm, nil );
end; // procedure TN_CMCaptDev13Form.ApixiaOnDeviceChange



// procedure TN_CMCaptDev13Form.UpDown1Click
procedure TN_CMCaptDev13Form.UpDown1Click( Sender: TObject; Button: TUDBtnType );
begin
end; // procedure TN_CMCaptDev13Form.UpDown1Click

// procedure TN_CMCaptDev13Form.tbRight90Click

//******************************************* TN_CMCaptDev13Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev13Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev13Form.tb180Click

//*************************************** TN_CMCaptDev13Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev13Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;
  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );
  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev13Form.tbFlipHorClick


//****************  TN_CMCaptDev13Form class public methods  ************

//**************************************** TN_CMCaptDev13Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev13Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: Integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length( CMOFPNewSlides^ ) - AInd] );
    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev13Form.CMOFDrawThumb

//************************************* TN_CMCaptDev13Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev13Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: Integer;
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
end; // procedure TN_CMCaptDev13Form.CMOFGetThumbSize

//**************************************** TN_CMCaptDev13Form.CMOFSetStatus ***
// procedure TN_CMCaptDev13Form.bnExitClick
procedure TN_CMCaptDev13Form.bnExitClick( Sender: TObject );
begin
  inherited;
end; // procedure TN_CMCaptDev13Form.bnExitClick

//***************************************** TN_CMCaptDev13Form.bnSetupClick ***
// Button "Setup" click event handler
//
//     Parameters
// Sender - Event sender
//
procedure TN_CMCaptDev13Form.bnSetupClick( Sender: TObject );
begin
  N_CMCDServObj13.CaptForm := ThisForm;
  inherited;
  // show device settings
  N_CMCDServObj13.CDSSettingsDlg( N_CMCDServObj13.PProfile );
  N_CMCDServObj13.CloseDriver();
  N_CMCDServObj13.StartDriver( ThisForm.Handle );
  N_CMCDServObj13.CaptForm := ThisForm;
  N_CMCDServObj13.ShowStatus( ThisForm, nil );
end; // procedure TN_CMCaptDev13Form.bnSetupClick

//****************************************** TN_CMCaptDev13Form.bRearmClick ***
// Button "Rearm" click event handler
//
//     Parameters
// Sender - Event sender
//
procedure TN_CMCaptDev13Form.bRearmClick( Sender: TObject );
begin
  inherited;

  if ( N_CMCDServObj13.DevStatus <> tsImageReady ) then
  begin
    N_CMV_ShowCriticalError( 'Apixia', 'Image is not ready yet' );
    Exit;
  end; // if ( N_CMCDServObj13.DevStatus <> tsImageReady ) then

  N_CMCDServObj13.ArmDevice( False, 0 ); // Arm w/o slide processing
end; // procedure TN_CMCaptDev13Form.bRearmClick

//************************************* TN_CMCaptDev13Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// ImageNum - Image number
// Raw      - Process also raw image ( in test mode only )
// Result   - True if capture is successfull
//
function TN_CMCaptDev13Form.CMOFCaptureSlide( ImageNum: Integer; Raw: Boolean ): Integer;
var
  i, w, h, l, t, r, b, iw, ih: Integer;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  FileStream: TFileStream;
  arr: TN_SArray;
  par: TN_CMV_ParamPairs;
  WrkDir, ImageFile, RawFile, ParamFile, CaptFile: String;
begin
  Result := 0;

  WrkDir    := N_CMV_GetWrkDir();
  ImageFile := WrkDir + 'Image_'    + IntToStr( ImageNum ) + '.img';
  RawFile   := WrkDir + 'ImageRaw_' + IntToStr( ImageNum ) + '.img';
  ParamFile := WrkDir + 'Param_'    + IntToStr( ImageNum ) + '.par';


  if not N_CMV_FileToArr( arr, ParamFile ) then // read image parameters
  begin
    N_CMV_ShowCriticalError( 'Apixia', 'Parameters file not found' );
    Exit;
  end; // if not FileToArr( arr, ParamFile ) then // read image parameters

  SetLength( par, 0 );
  N_CMV_ArrToParams( arr, par );
  // Image parameters from file
  w := StrToIntDef( N_CMV_GetParamValue( par, 'Width'      ), 0 );
  h := StrToIntDef( N_CMV_GetParamValue( par, 'Height'     ), 0 );
  l := StrToIntDef( N_CMV_GetParamValue( par, 'CropLeft'   ), 0 );
  r := StrToIntDef( N_CMV_GetParamValue( par, 'CropRight'  ), 0 );
  t := StrToIntDef( N_CMV_GetParamValue( par, 'CropTop'    ), 0 );
  b := StrToIntDef( N_CMV_GetParamValue( par, 'CropBottom' ), 0 );
  // log image parameters
  N_Dump1Str( 'Apixia >> Image Width = '      + IntToStr( w ) );
  N_Dump1Str( 'Apixia >> Image Height = '     + IntToStr( h ) );
  N_Dump1Str( 'Apixia >> Image CropLeft = '   + IntToStr( l ) );
  N_Dump1Str( 'Apixia >> Image CropRight = '  + IntToStr( r ) );
  N_Dump1Str( 'Apixia >> Image CropTop = '    + IntToStr( t ) );
  N_Dump1Str( 'Apixia >> Image CropBottom = ' + IntToStr( b ) );

  iw := ( r - l ) + 1; // width of cropped image
  ih := ( b - t ) + 1; // height of cropped image
  CaptFile := ImageFile;

  if Raw then // if it is raw file ( test mode )
  begin
    CaptFile := RawFile;
    iw := w;
    ih := h;
  end; // if Raw then // if it is raw file ( test mode )

  if not FileExists( CaptFile ) then
  begin
    N_CMV_ShowCriticalError( 'Apixia', 'Image file not found' );
    Exit;
  end; // if not FileExists( CaptFile ) then

  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  CapturedDIB := TN_DIBObj.Create(); // create DIB

  CapturedDIB.PrepEmptyDIBObj( iw, ih, pfCustom, -1, epfGray16, 16 ); // 16 bit
  CapturedDIB.DIBInfo.bmi.biXPelsPerMeter := 23437; // empirically calculated
  CapturedDIB.DIBInfo.bmi.biYPelsPerMeter := CapturedDIB.DIBInfo.bmi.biXPelsPerMeter;
  FileStream := TFileStream.Create( CaptFile, fmOpenRead ); // read image file
  CapturedDIB.ReadPixelsFromStream( FileStream );           // file to dib
  FileStream.Free;                                          // free file stream
  CapturedDIB.SetDIBNumBits( 14 );                          // 14 bit
  CapturedDIB.XORPixels( $00FFFFFF ); // Negate CapturedDIB
  NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB, @( CMOFPProfile^.CMAutoImgProcAttrs ) );
  NewSlide.SetAutoCalibrated();
  NewSlide.ObjAliase := IntToStr( CMOFNumCaptured );

  // Delete Apixia images files
  if not Raw then
  begin

    if not N_CMCDServObj13.DeleteImages() then
    begin
      N_CMV_ShowCriticalError( 'Apixia', 'Some temporary files not deleted' );
    end; // if not DeleteImages() then

  end; // if not Raw then

  with NewSlide.P()^ do
  begin
    CMSSourceDescr   := CMOFPProfile^.CMDPCaption;
    NewSlide.ObjInfo := 'Captured from ' + CMSSourceDescr;
    CMSMediaType     := CMOFPProfile^.CMDPMTypeID;
    NewSlide.SetInitDCMAttrs( TK_PCMDCMAttrs(@CMOFPProfile^.CMDPDModality) );
  end; // with NewSlide.P()^ do

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
end; // end of TN_CMCaptDev13Form.CMOFCaptureSlide

//************************************* TN_CMCaptDev13Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev13Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev13Form.CurStateToMemIni

//************************************* TN_CMCaptDev13Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev13Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev13Form.MemIniToCurState

end.


