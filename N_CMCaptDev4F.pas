unit N_CMCaptDev4F;
// Form for capture Images from Schick CDR Devices
// 2014.06.18 - 12 bit images bug fixed

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Types,
  K_Types, K_CM0,
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1,
  ComCtrls, ToolWin, ImgList;

type TN_CMCaptDev4Form = class( TN_BaseForm )
    MainPanel: TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit: TButton;
    ThumbsRFrame: TN_Rast1Frame;
    StatusShape: TShape;
    StatusLabel: TLabel;
    bnSetup: TButton;
    SlideRFrame: TN_Rast1Frame;
    CheckTimer: TTimer;
    bnCapture: TButton;
    cbAutoTake: TCheckBox;
    tbRotateImage: TToolBar;
    tbLeft90: TToolButton;
    tbRight90: TToolButton;
    tb180: TToolButton;
    tbFlipHor: TToolButton;
    RotateImagePanel: TPanel;

    //****************  TN_CMCaptDev4Form class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure bnSetupClick     ( Sender: TObject );
    procedure SlidePanelResize ( Sender: TObject );
    procedure CheckTimerTimer  ( Sender: TObject );
    procedure bnCaptureClick   ( Sender: TObject );
    procedure cbAutoTakeClick  ( Sender: TObject );
    procedure bnInitXrayDeviceClick ( Sender: TObject );
    procedure tbLeft90Click    ( Sender: TObject );
    procedure tbRight90Click   ( Sender: TObject );
    procedure tb180Click       ( Sender: TObject );
    procedure tbFlipHorClick   ( Sender: TObject );
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
    CMOFStartClosing:  integer;          // Saved value of CMOFNumTEvents when start closing scanner
    CMOFOKToCloseForm: boolean;          // Scanner was Closed OK and Form can be Closed
    CMOFAutoTake:      boolean;          // Auto Take mode
    CMOFFatalError:    boolean;          // Fatal error occured, Form should be closed
    CMOFInitError:     boolean;          // Initialization error occured, just wait for closing form by user
    CMOFInitDeviceError: boolean;        // result of N_CMECDInitXrayDevice is not eSUCCESS
    CMOFSavedNumTEvents: integer;        // Saved Number of Timer Events passed simce N_CMECDInitXrayDevice<>eSUCCESS
    CMOFDevID:           integer;        // Device ID for N_CMECDInitXrayDevice

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                                 AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure CMOFSetStatus    ( AIntStatus: integer );
    function  CMOFCaptureSlide (): integer;

    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
end; // type TN_CMCaptDev4Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF4Disconnected = 0;
  N_CMOF4Ready        = 1;
  N_CMOF4Error        = 2;


//  N_CMOF4Unknown   = 0;
//  N_CMOF4Manual    = 1;
//  N_CMOF4Auto      = 2;

//  N_CMOF4Ready        = 1;
//  N_CMOF4Disconnected = 2;
//  N_CMOF4Scanning     = 3;
//  N_CMOF4Error        = 4;
//  N_CMOF4Closing      = 5;

implementation
uses math,
 K_CLib0, K_Parse, K_Script1,
 N_Lib0, N_Lib2, N_Gra6, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev4,
  N_CML2F; // N_CMExtCDevs;
{$R *.dfm}

//****************  TN_CMCaptDev4Form class handlers  ******************

//********************************************** TN_CMCaptDev4Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev4Form.FormShow( Sender: TObject );
var
  ResCode, NumBits, ImageWidth, ImageHeight, LogMaxSize, LogMaxDays, LogDetails: integer;
  SimulatorParams: string;
  LogFullNameA: AnsiString;
begin
  N_Dump1Str( 'Schick Start FormShow' );
                             /// LLLOtherFormCaption = "%s" X-Ray Capture
  Caption := Format ( N_CML2Form.LLLOtherFormCaption.Caption, [CMOFPProfile^.CMDPCaption] );
  tbRotateImage.Images := N_CM_MainForm.CMMCurBigIcons;
  CMOFDrawSlideObj := TN_CMDrawSlideObj.Create(); // used in jn CMOFDrawThumb for Drawing Thumbnails
  CMOFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMOFGetThumbSize );

  LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'Schick.txt' );
  LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
  LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
  LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );
  ResCode := N_CMECDOpenSchickLogFile( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

  if ResCode = 0 then
    N_Dump1Str( 'N_CMECDOpenSchickLogFile Error - ' + String(LogFullNameA) );

  SimulatorParams := N_MemIniToString( 'CMS_UserDeb', 'SchickCDRSimulator', '' );

  if SimulatorParams <> '' then // Set Simulation mode
  begin
    NumBits := N_ScanInteger( SimulatorParams );
    if NumBits <> 12 then NumBits := 8;

    ImageWidth := N_ScanInteger( SimulatorParams );
    if (ImageWidth < 10) or (ImageWidth > 10000) then ImageWidth := 1000;

    ImageHeight := N_ScanInteger( SimulatorParams );
    if (ImageHeight < 10) or (ImageHeight > 10000) then ImageHeight := 1000;

    N_CMECDEnableSimaulationMode( 1, NumBits, ImageWidth, ImageHeight );
    N_Dump1Str( Format( 'Schick Simulation Mode NumBits=%d, Width=%d, Hieight=%d', [NumBits, ImageWidth, ImageHeight] ) );
  end else // normal (not Simulation) mode
    N_CMECDEnableSimaulationMode( 0, 0, 0, 0 );

  case CMOFDeviceIndex of // set CMOFDevID
    N_CMECD_CDR_XRAY: CMOFDevID := eCDR_XRAY;
    N_CMECD_CDR_CEPH: CMOFDevID := eCDR_CEPH;
    N_CMECD_CDR_PANO: CMOFDevID := eCDR_PANO;
  else
    CMOFDevID := -1; // to avoid worning
    Assert( False, 'Bad CMOFDeviceIndex!' );
  end; // case CMOFDeviceIndex of // set CMOFDevID

  ResCode := N_CMECDInitXrayDevice( CMOFDevID );
  N_Dump1Str( Format( 'bnInitXrayDeviceClick After N_CMECDInitXrayDevice ResCode=%d (DevInd=%d,DsdErr=%d)',
                            [ResCode,CMOFDeviceIndex,N_CMCDServObj4.CDSErrorInt] ));
  if ResCode <> eSUCCESS then // Initialization error
    CMOFSetStatus( -100 );

{
  // Open appropriate device
  N_Dump1Str( 'Schick before N_CMECDInitXrayDevice' );

  ResCode := N_CMECDInitXrayDevice( CMOFDevID ); // = 0

  N_Dump1Str( Format( 'Schick N_CMECDInitXrayDevice ResCode=%d (DevInd=%d,DsdErr=%d)',
                            [ResCode,CMOFDeviceIndex,N_CMCDServObj4.CDSErrorInt] ));
//  ResCode := 1; // debug

  if ResCode <> eSUCCESS then // Initialization error
  begin
    K_CMShowMessageDlg( 'Schick CDR device cannot be initialized. Please check that the correct device driver is installed and try to start the capture again. Press OK to continue.', mtWarning );
    CMOFInitDeviceError := True;
    CMOFSavedNumTEvents := 1;
    CMOFSetStatus( -100 );
  end; // if ResCode <> eSUCCESS then // Initialization error
}

//  cbAutoTake.Checked := True;

  //***** cbAutoTake.Checked Design time value is False.

  if CMOFDeviceIndex <> N_CMECD_CDR_XRAY then // N_CMECD_CDR_CEPH or N_CMECD_CDR_PANO
  begin                                       // AutoTake mode is NOT supported
//    cbAutoTake.Checked := False;
    cbAutoTake.Enabled := False;
  end else // N_CMECD_CDR_XRAY - AutoTake mode is supported
  begin
    cbAutoTake.Checked := True;
    cbAutoTake.Enabled := True;
  end;

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

  if CMOFDeviceIndex = N_CMECD_CDR_XRAY then
    RotateImagePanel.Visible := True
  else // N_CMECD_CDR_CEPH or N_CMECD_CDR_PANO
    RotateImagePanel.Visible := False;

  CheckTimer.Enabled := True; // N_CMECDGetSchickImageStatus() is supported in both (Auto and Manual) modes
  N_Dump1Str( 'Schick End FormShow' );
end; // procedure TN_CMCaptDev4Form.FormShow

//********************************************* TN_CMCaptDev4Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev4Form.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  CheckTimer.Enabled := False;
  N_CMECDCloseSchickLogFile();
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  Inherited;
end; // procedure TN_CMCaptDev4Form.FormClose

procedure TN_CMCaptDev4Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// now emply
begin
  if Key = VK_F8 then // Close Self
  begin
//    Close;
//    Exit;
  end; // if Key = VK_F9 then

//    CMOFSetStatus( N_CMOF4Scanning );
end; // procedure TN_CMCaptDev4Form.FormKeyDown

procedure TN_CMCaptDev4Form.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
// If F9 is Up - Create new test Slide
begin
  Exit;
end; // procedure TN_CMCaptDev4Form.FormKeyUp

procedure TN_CMCaptDev4Form.bnSetupClick( Sender: TObject );
// Show Setup dialog
var
  ResCode: integer;
begin
  ResCode := N_CMECDShowPropertiesDialog();

  if ResCode <> eSUCCESS then
    N_Dump1Str( Format( 'N_CMECDShowPropertiesDialog Error=(%d)', [ResCode] ) );
end; // procedure TN_CMCaptDev4Form.bnSetupClick

procedure TN_CMCaptDev4Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw

  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev4Form.SlidePanelResize

procedure TN_CMCaptDev4Form.CheckTimerTimer( Sender: TObject );
// Check Image Status in all modes and Capture Image if possible in Auto mode
var
  ResCode, Delta: integer;
  Label Fin;
begin
  ResCode := 101; // not initialized flag
  Delta := 10;
  CheckTimer.Enabled := False; // to prevent events inside CheckTimerTimer

  Inc( CMOFNumTEvents ); // whole number of CheckTimer Events received (for checking timeouts)
  N_Dump1Str( Format( 'Schick CheckTimer Start, CMOFNumTEvents=%d', [CMOFNumTEvents] ) );

  if CMOFFatalError then // Fatal error occured, Form should be closed
  begin
    N_Dump1Str( 'Schick CheckTimer Close1 CMOFFatalError' );
    Close();
    N_Dump1Str( 'Schick CheckTimer Close2 CMOFFatalError' );
    Exit;
  end; // if CMOFFatalError then // Fatal error occured, Form should be closed

  if CMOFInitDeviceError then // result of N_CMECDInitXrayDevice is not eSUCCESS
  begin
    N_Dump1Str( Format( 'Schick CheckTimer ReInit, N=%d, N+Delta=%d', [CMOFNumTEvents,(CMOFSavedNumTEvents+Delta)] ) );

    if CMOFNumTEvents < (CMOFSavedNumTEvents + Delta) then // just wait
      goto Fin;

    // Try to reinitialize Device

    N_Dump1Str( Format( 'Schick CheckTimer Before InitXrayDevice, CMOFDevID=%d', [CMOFDevID] ) );
//    ResCode := N_CMECDInitXrayDevice( CMOFDevID );
    N_Dump1Str( 'Schick CheckTimer After InitXrayDevice' );

    N_Dump1Str( Format( 'Schick N_CMECDInitXrayDevice ResCode=%d (DevInd=%d,DsdErr=%d)',
                              [ResCode,CMOFDeviceIndex,N_CMCDServObj4.CDSErrorInt] ));

    if ResCode <> eSUCCESS then // again Initialization error
    begin
      CMOFSavedNumTEvents := CMOFNumTEvents; // continue waiting
      goto Fin;
    end; // if ResCode <> eSUCCESS then // again Initialization error

    CMOFInitDeviceError := False; // return to normal mode
  end; // if CMOFInitDeviceError then // result of N_CMECDInitXrayDevice is not eSUCCESS

  N_Dump1Str( 'Schick CheckTimer 0' );
  CMOFCurTmpStatus := N_CMECDGetSchickImageStatus(); // >= 21
  N_Dump1Str( Format( 'Schick CheckTimer 1, CMOFCurTmpStatus=%d', [CMOFCurTmpStatus] ) );

  if (CMOFCurTmpStatus = AA_NO_HARDWARE)  or   // =  1; // No Sensor attached
     (CMOFCurTmpStatus = AA_NO_FIRMWARE)  or   // =  2; // Firmware not loaded in USB Remote
     (CMOFCurTmpStatus = AA_WRONG_SENSOR) or   // =  3; // Sensor does not support Auto Acquire
     (CMOFCurTmpStatus = AA_BAD_FIRMWARE) then // =  4; // Firmware is corrupt or is an old version that does not support Auto Acquire
  begin
//    CMOFInitDeviceError := True; // not initialized mode
    CMOFSavedNumTEvents := CMOFNumTEvents; // wait for Delta events before trying to reinitialized
//    CMOFSetStatus( -100 );
    CMOFSetStatus( CMOFCurTmpStatus );
    goto Fin;
  end;

//  N_Dump1Str( Format( 'Schick CheckTimer 2, - CMOFCurTmpStatus=%d', [CMOFCurTmpStatus] ) );
  CMOFSetStatus( CMOFCurTmpStatus );

  if CMOFCurTmpStatus = AA_IMAGE_AVAILABLE then
  begin
    ResCode := CMOFCaptureSlide();

    if ResCode <> 0 then
    begin
      K_CMShowMessageDlg( 'Acquiring Image Error (Auto)', mtError );
      N_Dump1Str( Format( 'CheckTimerTimer error - ResCode=%d', [ResCode] ) );
    end;
  end; // if CMOFCurStatus = AA_IMAGE_AVAILABLE then

  Fin: //**********
  N_Dump1Str( Format( 'Schick CheckTimer Fin, CMOFNumTEvents=%d', [CMOFNumTEvents] ) );
  CheckTimer.Enabled := True;
end; // procedure TN_CMCaptDev4Form.CheckTimerTimer

//**************************************** TN_CMCaptDev4Form.bnCaptureClick ***
// Capture Image in not CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// bnCapture button OnClick handler
//
procedure TN_CMCaptDev4Form.bnCaptureClick( Sender: TObject );
var
  ResCode: integer;
begin
  N_Dump1Str( 'Start bnCaptureClick' );
  bnCapture.Enabled := False;
  bnExit.Enabled    := False;

//  CMOFCurTmpStatus := N_CMECDGetSchickImageStatus();
//  N_Dump1Str( Format( 'CMOFCurTmpStatus=%d', [CMOFCurTmpStatus] ) );
//  CMOFSetStatus( CMOFCurTmpStatus );

  ResCode := CMOFCaptureSlide();

  if ResCode <> 0 then
  begin
//    K_CMShowMessageDlg( 'Acquiring Image Error (Manual)', mtError );
    N_Dump1Str( Format( 'bnCaptureClick error - ResCode=%d', [ResCode] ) );
  end;

  bnCapture.Enabled := True;
  bnExit.Enabled    := True;
  N_Dump1Str( 'Finish bnCaptureClick' );
end; // procedure TN_CMCaptDev4Form.bnCaptureClick

//*************************************** TN_CMCaptDev4Form.cbAutoTakeClick ***
// Toggle CMOFAutoTake mode
//
//     Parameters
// Sender - Event Sender
//
// cbAutoTake Checkbox OnClick handler
//
procedure TN_CMCaptDev4Form.cbAutoTakeClick( Sender: TObject );
var
  ResCode: integer;
begin
  CMOFAutoTake := cbAutoTake.Checked;
  N_Dump1Str( Format( 'cbAutoTakeClick Checked=%s', [N_B2S(CMOFAutoTake)] ) );

  if CMOFAutoTake then // AutoTake mode
  begin
    bnCapture.Enabled  := False;

    ResCode := N_CMECDSetAutoAcquire( 1 );

    if ResCode <> eSUCCESS then
    begin
      bnCapture.Enabled  := True;
      N_Dump1Str( Format( 'SetAutoAcquire( 1 ) error - ResCode=%d', [ResCode] ) );
    end;
  end else // CMOFAutoTake=False, Manual mode
  begin
    bnCapture.Enabled  := True;

    ResCode := N_CMECDSetAutoAcquire( 0 );

    if ResCode <> eSUCCESS then
    begin
      N_Dump1Str( Format( 'SetAutoAcquire( 0 ) error - ResCode=%d', [ResCode] ) );
    end;

  end; // else // CMOFAutoTake=False, Manual mode
end; // procedure TN_CMCaptDev4Form.cbAutoTakeClick

procedure TN_CMCaptDev4Form.bnInitXrayDeviceClick( Sender: TObject );
  // Try to reinitialize Device Manually
var
  ResCode: integer;
begin
  N_Dump1Str( Format( 'bnInitXrayDeviceClick Before InitXrayDevice, CMOFDevID=%d', [CMOFDevID] ) );
  ResCode := N_CMECDInitXrayDevice( CMOFDevID );
  N_Dump1Str( Format( 'bnInitXrayDeviceClick After N_CMECDInitXrayDevice ResCode=%d (DevInd=%d,DsdErr=%d)',
                            [ResCode,CMOFDeviceIndex,N_CMCDServObj4.CDSErrorInt] ));
end; // procedure TN_CMCaptDev4Form.bnInitXrayDeviceClick

//***************************************** TN_CMCaptDev4Form.tbLeft90Click ***
// Rotate last captured Image by 90 degree countercloclwise
//
//     Parameters
// Sender - Event Sender
//
// tbLeft90 button OnClick handler
//
procedure TN_CMCaptDev4Form.tbLeft90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 90, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev4Form.tbLeft90Click

//**************************************** TN_CMCaptDev4Form.tbRight90Click ***
// Rotate last captured Image by 90 degree cloclwise
//
//     Parameters
// Sender - Event Sender
//
// tbRight90 button OnClick handler
//
procedure TN_CMCaptDev4Form.tbRight90Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 270, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev4Form.tbRight90Click

//******************************************** TN_CMCaptDev4Form.tb180Click ***
// Rotate last captured Image by 180 degree
//
//     Parameters
// Sender - Event Sender
//
// tb180 button OnClick handler
//
procedure TN_CMCaptDev4Form.tb180Click( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 180, 0 );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev4Form.tb180Click

//**************************************** TN_CMCaptDev4Form.tbFlipHorClick ***
// Flip horizontally last captured Image
//
//     Parameters
// Sender - Event Sender
//
// tbFlipHor button OnClick handler
//
procedure TN_CMCaptDev4Form.tbFlipHorClick( Sender: TObject );
begin
  if CMOFNumCaptured <= 0 then Exit;

  K_CMFlipRotateSlideImage( CMOFPNewSlides^[0], 0, N_FlipHorBit );

  CMOFThumbsDGrid.DGInitRFrame();
  CMOFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame

  // Show NewSlide in SlideRFrame
  SlideRFrame.RFrShowComp( CMOFPNewSlides^[0].GetMapRoot() );
end; // procedure TN_CMCaptDev4Form.tbFlipHorClick


//****************  TN_CMCaptDev4Form class public methods  ************

//***************************************** TN_CMCaptDev4Form.CMOFDrawThumb ***
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
procedure TN_CMCaptDev4Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length(CMOFPNewSlides^)-AInd] );

    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev4Form.CMOFDrawThumb

//************************************** TN_CMCaptDev4Form.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev4Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
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
end; // procedure TN_CMCaptDev4Form.CMOFGetThumbSize

//***************************************** TN_CMCaptDev4Form.CMOFSetStatus ***
// Set and Show current Device (Form) status
//
//     Parameters
// AIntStatus - given Status (one of N_CMOF4xxx constants)
//
procedure TN_CMCaptDev4Form.CMOFSetStatus( AIntStatus: integer );
begin
  CMOFCurIntStatus := AIntStatus;
//  N_Dump1Str( Format( 'Schick CMOFSetStatus AIntStatus=%d', [AIntStatus] ) );

  case AIntStatus of

  -100: begin // =-100 - CMOFInitDeviceError=True
    StatusLabel.Caption := 'Device initialization error';
    StatusLabel.Font.Color  := clBlack;
    StatusShape.Pen.Color   := clBlack;
    StatusShape.Brush.Color := clBlack;
  end; // -100: begin // =-100 - CMOFInitDeviceError=True

  AA_NO_AUTO_ACQUIRE: begin // =0
    StatusLabel.Caption := 'Autotake not supported';
    StatusLabel.Font.Color  := clBlack;
    StatusShape.Pen.Color   := clBlack;
    StatusShape.Brush.Color := clBlack;
  end; // AA_NO_AUTO_ACQUIRE: begin // =0

  AA_NO_HARDWARE: begin // =1
    StatusLabel.Caption := 'Device disconnected';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // AA_NO_HARDWARE: begin // =1

  AA_NO_FIRMWARE: begin // =2
    StatusLabel.Caption := 'Firmware not loaded';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // AA_NO_FIRMWARE: begin // =2

  AA_WRONG_SENSOR: begin // =3
    StatusLabel.Caption := 'Auto acquire not supported';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // AA_WRONG_SENSOR: begin // =3

  AA_BAD_FIRMWARE: begin // =4
    StatusLabel.Caption := 'Firmware is corrupted';
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // AA_BAD_FIRMWARE: begin // =4

  AA_IMAGE_AVAILABLE, // = 5
  AA_NOT_READY: begin // =6
    ///  LLLOther4Processing = Processing
    StatusLabel.Caption := N_CML2Form.LLLOther4Processing.Caption;
    StatusLabel.Font.Color  := clBlue;
    StatusShape.Pen.Color   := clBlue;
    StatusShape.Brush.Color := clBlue;
  end; // AA_IMAGE_AVAILABLE, AA_NOT_READY: begin // =5, 6

  AA_TRIGGERING: begin // = 7
    ///  LLLOther4Ready = Sensor Ready
    StatusLabel.Caption := N_CML2Form.LLLOther4Ready.Caption;
    StatusLabel.Caption := 'Sensor ready';
    StatusLabel.Font.Color  := clGreen;
    StatusShape.Pen.Color   := clGreen;
    StatusShape.Brush.Color := clGreen;
//    N_Dump1Str( Format( 'Schick CMOFSetStatus Sensor ready=%d', [AIntStatus] ) );
  end; // N_CMOF4Unknown: begin

  else begin // all other codes
    StatusLabel.Caption := Format( 'Device error. Error code = %d', [AIntStatus] );
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // N_CMOF4Manual: begin

  end; // case AIntStatus of

  StatusLabel.Repaint;
  StatusShape.Repaint;
end; // end of TN_CMCaptDev4Form.CMOFSetStatus

//************************************** TN_CMCaptDev4Form.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev4Form.CMOFCaptureSlide(): integer;
var
  i, ResCode: Integer;
  OnePixSize: TN_Int2;
  DIBInfo: TN_DIBInfo;
  PBitMapInfo, PImagePixels: Pointer;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
begin
  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number
  N_Dump1Str( Format( 'Schick Start CMOFCaptureSlide %d', [CMOFNumCaptured] ) );

  PBitMapInfo := nil;
  PImagePixels := nil;

  ResCode := N_CMECDAcquireImage( @PBitMapInfo, @PImagePixels );

  if ResCode <> eSUCCESS then // some error
  begin
    N_Dump1Str( Format( 'N_CMECDAcquireImage Error1, ResCode=%d', [ResCode] ) );
    Dec( CMOFNumCaptured ); // return initial value
    N_CMECDFreeImageOutputData();
    Result := 1;
    Exit;
  end; // if ResCode <> eSUCCESS then // some error

  N_Dump1Str( 'Schick after N_CMECDAcquireImage' );

  OnePixSize := -123;
  ResCode := N_CMECDGetMicronsPerPixel( @OnePixSize );
  N_Dump1Str( 'Schick after N_CMECDGetMicronsPerPixel ' + IntToStr(OnePixSize) );

  if ResCode <> eSUCCESS then // some error
  begin
    N_Dump1Str( Format( 'N_CMECDGetMicronsPerPixel Error1, ResCode=%d', [ResCode] ) );
    Dec( CMOFNumCaptured ); // return initial value
    N_CMECDFreeImageOutputData();
    Result := 1;
    Exit;
  end; // if ResCode <> eSUCCESS then // some error

  if OnePixSize <= 0 then // error
  begin
    N_Dump1Str( Format( 'N_CMECDGetMicronsPerPixel Error2, OnePixSize=%d', [OnePixSize] ) );
    OnePixSize := 2; // dummy value
  end;

  FillChar( DIBInfo, SizeOf(DIBInfo), 0);
  move( PBitMapInfo^, DIBInfo.bmi, SizeOf(DIBInfo.bmi) );

  with DIBInfo.bmi do
    N_Dump1Str( Format( 'Shick Image: X,Y=%dx%d, BitCount=%d, ImgSize=%d, XYPerMeter=%d,%d',
                        [biWidth,biHeight,biBitCount,biSizeImage,biXPelsPerMeter,biYPelsPerMeter] ) );

  CapturedDIB := TN_DIBObj.Create();
  CapturedDIB.PrepEmptyDIBObj( @DIBInfo, -1, epfAutoGray );

  with CapturedDIB do // copy pixels from PImagePixels to CapturedDIB
    for i := 0 to DIBSize.Y-1 do // PImagePixels rows are not aligned!
      move( (TN_BytesPtr(PImagePixels)+i*RRBytesInLine)^, (PRasterBytes+i*RRLineSize)^, RRBytesInLine );

  N_Dump1Str( 'Schick before N_CMECDFreeImageOutputData' );
  N_CMECDFreeImageOutputData();
  N_Dump1Str( 'Schick after N_CMECDFreeImageOutputData' );

  if CapturedDIB.DIBExPixFmt = epfGray16 then
    CapturedDIB.SetDIBNumBits( 12 );

  CapturedDIB.XORPixels( $00FFFFFF ); // Negate CapturedDIB
  CapturedDIB.FlipAndRotate( 2 ); // Flip Vertically

  CapturedDIB.DIBInfo.bmi.biXPelsPerMeter := 1000000 div OnePixSize;
  CapturedDIB.DIBInfo.bmi.biYPelsPerMeter := CapturedDIB.DIBInfo.bmi.biXPelsPerMeter;

  //***** Here: CapturedDIB is OK

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

  N_Dump1Str( Format( 'Schick Fin CMOFCaptureSlide %d', [CMOFNumCaptured] ) );
  Result := 0;
end; // end of TN_CMCaptDev4Form.CMOFCaptureSlide

//************************************** TN_CMCaptDev4Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev4Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev4Form.CurStateToMemIni

//************************************** TN_CMCaptDev4Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev4Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev4Form.MemIniToCurState

end.
