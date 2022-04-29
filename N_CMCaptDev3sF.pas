unit N_CMCaptDev3sF;
// Form for capture Images from SOREDEX Devices

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Types,
  K_Types, K_CM0,
  N_Video, // temp
  N_Types, N_Lib1, N_Gra2, N_BaseF, N_Rast1Fr, N_DGrid, N_CM2, N_CM1; // N_CMExtDLL,

type TN_CMCaptDev3Form = class( TN_BaseForm )
    MainPanel: TPanel;
    RightPanel: TPanel;
    SlidePanel: TPanel;
    bnExit: TButton;
    ThumbsRFrame: TN_Rast1Frame;
    SlideRFrame: TN_Rast1Frame;
    CheckTimer: TTimer;
    CtrlsPanelParent: TPanel;
    CtrlsPanel: TPanel;
    bnSetup: TButton;
    StatusShape: TShape;
    StatusLabel: TLabel; // Other Capturing Form

    //****************  TN_CMCaptDev3sForm class handlers  ******************

    procedure FormShow         ( Sender: TObject );
    procedure FormCloseQuery   ( Sender: TObject; var CanClose: Boolean );
    procedure FormClose        ( Sender: TObject; var Action: TCloseAction ); override;
    procedure FormKeyDown      ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyUp        ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure bnSetupClick     ( Sender: TObject );
    procedure SlidePanelResize ( Sender: TObject );
    procedure CheckTimerTimer  ( Sender: TObject );
  public
    CMOFThumbsDGrid:  TN_DGridArbMatr;   // DGrid for handling Thumbnails in ThumbsRFrame
    CMOFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails (jn CMOFDrawThumb)
    CMOFPNewSlides:   TN_PUDCMSArray;    // Pointer to Array of New captured Slides
    CMOFAnsiFName:    AnsiString;        // Image (created by driver) Full File Name
    CMOFPProfile:     TK_PCMOtherProfile;// Pointer to Device Profile
    CMOFDeviceIndex:  integer;           // Device Index in ECDevices Array
    CMOFDeviceType:   integer;           // Device Type (

    CMOFNumCaptured:  integer;           // Number of Captured Slides
    CMOFCurStatus:    integer;           // Current Device (Form) Status
    CMOFNumTEvents:   integer;           // Number of Timer Events passed
    CMOFStartClosing: integer;           // Saved value of CMOFNumTEvents when start closing scanner
    CMOFOKToCloseForm: boolean;          // Scanner was Closed OK and Form can be Closed
    CMOFUseDump1:      boolean;          // Use N_Dump1Str in CheckTimerTimer

    procedure CMOFDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure CMOFGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                   AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure CMOFSetStatus      ( AIntStatus: integer );
    procedure CMOFTryToCloseSelf ();
    function  CMOFCaptureSlide   (): integer;
    procedure CurStateToMemIni   (); override;
    procedure MemIniToCurState   (); override;
end; // type TN_CMCaptDev3sForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

const // Form states
  N_CMOF3Unknown      = 0;
  N_CMOF3Ready        = 1;
  N_CMOF3Disconnected = 2;
  N_CMOF3Scanning     = 3;
  N_CMOF3Error        = 4;
  N_CMOF3Closing      = 5;

implementation
uses math,
 K_CLib0, K_Parse, K_Script1,
 N_Lib0, N_Lib2, N_CompBase, N_Comp1, N_CMMain5F, N_CMCaptDev3s, N_CML2F; // N_CMExtCDevs;
{$R *.dfm}

//****************  TN_CMCaptDev3sForm class handlers  ******************

//********************************************** TN_CMCaptDev3sForm.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMCaptDev3Form.FormShow( Sender: TObject );
var
  ResCode, UseCranexDSimulator, CallDiscardImage: integer;
  LogMaxSize, LogMaxDays, LogDetails: Integer;
  WrkDir: string;
  LogFullNameA, AnsiWrkDir: AnsiString;
begin
  /// LLLOtherFormCaption = "%s" X-Ray Capture
  Caption := Format ( N_CML2Form.LLLOtherFormCaption.Caption, [CMOFPProfile^.CMDPCaption] );
  CMOFDrawSlideObj := TN_CMDrawSlideObj.Create(); // used in jn CMOFDrawThumb for Drawing Thumbnails
  CMOFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMOFGetThumbSize );

//  AnsiLogDir := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) );
//  ResCode := N_CMECDOpenDSDLogFile( @AnsiLogDir[1], 'Soredex.txt', 1 );
//  if ResCode = 0 then
//    N_Dump2Str( 'N_CMECDOpenDSDLogFile Error - ' + N_AnsiToString(AnsiLogDir) );

  LogFullNameA := N_StringToAnsi( K_GetDirPath( 'CMSLogFiles' ) + 'Dev_Soredex.txt' );
  LogMaxSize := N_MemIniToInt( 'CMS_UserMain', 'LogMaxSize', 1024 );
  LogMaxDays := N_MemIniToInt( 'CMS_UserMain', 'LogMaxDays', 200 );
  LogDetails := N_MemIniToInt( 'CMS_UserMain', 'LogDetails', 2 );

  N_CMECDOpenDSDLogFile( @LogFullNameA[1], LogMaxSize, LogMaxDays, LogDetails );

  WrkDir := K_GetDirPath( 'CMSWrkFiles' );
  K_ForceDirPath( WrkDir );
  AnsiWrkDir := N_StringToAnsi( WrkDir );

  case CMOFDeviceIndex of // Open appropriate device

    N_CMECD_DigoraOpt:
    begin
      ResCode := N_CMECDOpenScanner( SO_DIGORAOPTIME, SO_SDXOPTIME, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    N_CMECD_CranexD:
    begin
      UseCranexDSimulator := N_MemIniToInt( 'CMS_UserDeb', 'UseCranexDSimulator', 0 );
      N_Dump1Str( Format( 'UseCranexDSimulator=%d', [UseCranexDSimulator] ) );

      if UseCranexDSimulator = 0 then // Use real device
        ResCode := N_CMECDOpenScanner( SO_CRANEXD, $0, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt )
      else // Use CranexD Simulator
        ResCode := N_CMECDOpenScanner( SO_CRANEXD, $10000, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    N_CMECD_CranexNov:
    begin
      ResCode := N_CMECDOpenScanner( SO_CRANEXTT, 0, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    N_CMECD_CranexNovE:
    begin
      ResCode := N_CMECDOpenScanner( SO_NOVUSE, 0, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    N_CMECD_ScaneXam:
    begin
      ResCode := N_CMECDOpenScanner( SO_SCANEXAM, SO_KAVOSCANEXAM, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    N_CMECD_PaneXam:
    begin
      ResCode := N_CMECDOpenScanner( SO_PANEXAM, SO_KAVOPANEXAM, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    N_CMECD_Express:
    begin
      ResCode := N_CMECDOpenScanner( SO_EXPRESS, SO_IDEXPRESS, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    N_CMECD_Orthopan:
    begin
      ResCode := N_CMECDOpenScanner( SO_OP30, 0, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    N_CMECD_PSPIX:
    begin
      ResCode := N_CMECDOpenScanner( SO_PSPIX, SO_PSPIX, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    N_CMECD_ExpressOrigo:
    begin
      ResCode := N_CMECDOpenScanner( SO_EXPRESS, SO_IDEXPRESSORIGO, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    N_CMECD_ScaneXamOne:
    begin
      ResCode := N_CMECDOpenScanner( SO_SCANEXAM, SO_KAVOSCANEXAMONE, @AnsiWrkDir[1], @N_CMCDServObj3A.CDSErrorInt );
    end;

    else
      ResCode := -2; // Bad CMOFDeviceIndex (very unlikely)
  end; // case CMOFDeviceIndex of

  N_Dump1Str( Format( 'N_CMECDOpenScanner ResCode=%d (DevInd=%d,DsdErr=%d)',
                            [ResCode,CMOFDeviceIndex,N_CMCDServObj3A.CDSErrorInt] ));
  CMOFUseDump1 := N_MemIniToBool( 'CMS_UserDeb', 'UseDump1', False );

  CallDiscardImage := N_MemIniToInt( 'CMS_UserDeb', 'CallDiscardImage', 0 );
  if CallDiscardImage <> 0 then
  begin
    ResCode := N_CMECDDiscardImage();
    N_Dump1Str( Format( 'N_CMECDDiscardImage ResCode=%d', [ResCode] ) );
  end;

  CMOFAnsiFName := AnsiWrkDir + AnsiString('DSDCurFile.raw');
  N_i := N_CMECDSetImageStore( @CMOFAnsiFName[1] );

  ResCode := N_CMECDSetImageFormat( (12 shl 16) or SO_IMAGE_RAW ); // 12 bps RAW format

  if ResCode <> SoS_OK then
  begin
    N_Dump1Str( 'SetImageFormat error ' + IntToStr(ResCode) );
  end;

  CheckTimer.Enabled := True;

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

  CMOFSetStatus( N_CMOF3Unknown );
end; // procedure TN_CMCaptDev3sForm.FormShow

//**************************************** TN_CMCaptDev3sForm.FormCloseQuery ***
// Check if Form can be closed
//
//     Parameters
// Sender   - Event Sender
// CanClose - True if Form can be closed
//
// OnCloseQuery Self handler
//
procedure TN_CMCaptDev3Form.FormCloseQuery( Sender: TObject; var CanClose: Boolean );
begin
  N_Dump2Str( Format( 'FormCloseQuery (%d, %d)', [CMOFNumTEvents,CMOFCurStatus] ) );
  CMOFTryToCloseSelf ();
  CanClose := CMOFOKToCloseForm;

  if 0.001*(CMOFNumTEvents-CMOFStartClosing)*CheckTimer.Interval > 5.0 then // timeout
  begin
    CheckTimer.Enabled := False; // to prevent more Timer events (while K_CMShowMessageDlg)
    N_Dump1Str( 'FormCloseQuery Error - Cannot close scanner!' );
    K_CMShowMessageDlg( 'Scanner Closing timeout. Please check your hardware.', mtError );
    CanClose := True;
  end;
end; // procedure TN_CMCaptDev3sForm.FormCloseQuery

//********************************************* TN_CMCaptDev3sForm.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMCaptDev3Form.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  N_Dump2Str( 'FormClose1' );
//  N_CMECDCloseLogFile();
//  N_Dump2Str( 'FormClose2' );
  CMOFDrawSlideObj.Free;
  CMOFThumbsDGrid.Free;

  Inherited;
  N_Dump2Str( 'CaptDev3Form.FormClose Fin' );
end; // procedure TN_CMCaptDev3sForm.FormClose

procedure TN_CMCaptDev3Form.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
// Just set "Scanning" status if F9 is Down
begin
  if Key = VK_F8 then // Close Self
  begin
    Close;
    Exit;
  end; // if Key = VK_F9 then

//    CMOFSetStatus( N_CMOF3Scanning );
end; // procedure TN_CMCaptDev3sForm.FormKeyDown

procedure TN_CMCaptDev3Form.FormKeyUp( Sender: TObject; var Key: Word; Shift: TShiftState );
// If F9 is Up - Create new test Slide
begin
  Exit;
end; // procedure TN_CMCaptDev3sForm.FormKeyUp

procedure TN_CMCaptDev3Form.bnSetupClick( Sender: TObject );
// Show Setup dialog
var
  ResCode: integer;
begin
  ResCode := N_CMECDActivateSetup();
  N_Dump2Str( Format( 'N_CMECDActivateSetup (%d)', [ResCode] ) );
end; // procedure TN_CMCaptDev3sForm.bnSetupClick

procedure TN_CMCaptDev3Form.SlidePanelResize( Sender: TObject );
// Redraw Last Captured Slide in CMOFPNewSlides^[0]
var
  RootComp: TN_UDCompVis;
begin
  if CMOFPNewSlides = nil then Exit; // no Slide to Redraw
  if Length(CMOFPNewSlides^) = 0 then Exit; // no Slide to Redraw

  RootComp := CMOFPNewSlides^[0].GetMapRoot();
  SlideRFrame.RFrShowComp( RootComp );
end; // procedure TN_CMCaptDev3sForm.SlidePanelResize

procedure TN_CMCaptDev3Form.CheckTimerTimer( Sender: TObject );
// Check connected device buttons
var
  ScannerStatus, ScannerStatusEx, ImageStatus, LastStatEvent, LastImageEvent: integer;
  PatientName: AnsiString;
begin
  CheckTimer.Enabled := False;
  if CMOFUseDump1 then N_Dump1Str( 'Start CMCaptDev3Form.CheckTimerTimer' );
  Inc( CMOFNumTEvents ); // whole number of CheckTimer Events received (for checking timeouts)

  ScannerStatusEx := N_CMECDGetScannerStatusEx();
  ImageStatus := 0; // is needed?

  ScannerStatus  :=          ScannerStatusEx and $0FF; // byte 0
  LastStatEvent  := (ScannerStatusEx shr 8)  and $0FF; // byte 1
  LastImageEvent := (ScannerStatusEx shr 16) and $0FF; // byte 2
  N_i := ImageStatus;   // to avoid warning
  N_i := LastStatEvent; // to avoid warning

  if CMOFUseDump1 then
    N_Dump1Str( Format( 'CMCaptDev3Form CheckTimer: ScanStat=$%x, StatEvent=$%x, ImgEvent=$%x, FormState=%d',
                  [ScannerStatus,LastStatEvent,LastImageEvent,CMOFCurStatus] ) )
  else
    N_Dump2Str( Format( 'CMCaptDev3Form CheckTimer: ScanStat=$%x, StatEvent=$%x, ImgEvent=$%x, FormState=%d',
                  [ScannerStatus,LastStatEvent,LastImageEvent,CMOFCurStatus] ) );

  if (CMOFCurStatus = N_CMOF3Unknown) or         // just after FormShow, waiting for SoS_CONNECTED
     (CMOFCurStatus = N_CMOF3Disconnected) then  // in Disconnected mode, waiting for SoS_CONNECTED
  begin
{ // is not needed
    if 0.001*CMOFNumTEvents*CheckTimer.Interval > 20.0 then // timeout
    begin
      CheckTimer.Enabled := False; // to prevent more Timer events (while K_CMShowMessageDlg)
      N_Dump1Str( 'SoS_CONNECTED timeout (20 sec.)' );
      K_CMShowMessageDlg( 'Connection timeout. Please check your hardware.', mtError );
      Close; // Close Form (stop scanning)
      Exit;
    end;
}

    if ScannerStatus = SoS_CONNECTED then
    begin
      CMOFSetStatus( N_CMOF3Ready );
      N_Dump2Str( 'Got SoS_CONNECTED' );

      if (CMOFDeviceIndex = N_CMECD_DigoraOpt) or
         (CMOFDeviceIndex = N_CMECD_ScaneXam)  or
         (CMOFDeviceIndex = N_CMECD_Express)   or
         (CMOFDeviceIndex = N_CMECD_ExpressOrigo) then // Set Patient Name to Digora Optime like devices
      begin
        PatientName := N_StringToAnsi( K_CMGetPatientDetails( -1, '(#PatientSurname#) (#PatientFirstName#)' ) );
        N_CMECDSetPatientName( @PatientName[1] );
        N_Dump2Str( 'PatientName = ' + N_AnsiToString(PatientName) );
      end; // if CMOFDeviceIndex = N_CMECD_DigoraOpt then // Set Patient Name

      if CMOFUseDump1 then N_Dump1Str( 'Fin 1 CMCaptDev3Form.CheckTimerTimer' );
      CheckTimer.Enabled := True;
      Exit;
    end; // if ScannerStatus = SoS_CONNECTED then

{   // SoS_SYSTEMERROR code should be ignored
    if ScannerStatus = SoS_SYSTEMERROR then // Some Error
    begin
      N_Dump1Str( 'SoS_SYSTEMERROR' );
      Close;
      Exit;
    end; // if ScannerStatus = SoS_SYSTEMERROR then // Some Error
}
  end; // if CMOFCurStatus = N_CMOF3Unknown then // just after FormShow, waiting for SoS_CONNECTED

  if CMOFCurStatus = N_CMOF3Closing then // trying to close scanner
  begin
    N_Dump2Str( 'Waiting for closing scanner' );
    Close; // Close Form (stop scanning)
    if CMOFUseDump1 then N_Dump1Str( 'Fin 2 CMCaptDev3Form.CheckTimerTimer' );
    CheckTimer.Enabled := True;
    Exit;
  end; // if CMOFCurStatus = N_CMOF3Closing then // trying to close scanner

  if CMOFCurStatus = N_CMOF3Ready then // ready and waiting for Image
  begin
    if ScannerStatus = SoS_DISCONNECTED then
    begin
      CMOFSetStatus( N_CMOF3Disconnected );
      N_Dump2Str( 'Got SoS_DISCONNECTED' );
      if CMOFUseDump1 then N_Dump1Str( 'Fin 3 CMCaptDev3Form.CheckTimerTimer' );
      CheckTimer.Enabled := True;
      Exit;
    end;

    if ScannerStatus = SoS_IMAGEREADOUT then
    begin
      CMOFSetStatus( N_CMOF3Scanning );
      N_Dump2Str( 'Got SoS_IMAGEREADOUT' );
      if CMOFUseDump1 then N_Dump1Str( 'Fin 4 CMCaptDev3Form.CheckTimerTimer' );
      CheckTimer.Enabled := True;
      Exit;
    end;
  end; // if CMOFCurStatus = N_CMOF3Ready then // ready and waiting for Image

  // Check if Image is ready
  if (LastImageEvent = SoS_OK) then
  begin
    N_Dump2Str( 'Capture Image' );
    N_i := CMOFCaptureSlide();
    N_i := N_CMECDDiscardImage();
    CMOFSetStatus( N_CMOF3Ready );
  end; // if (LastImageEvent = SoS_OK) then
  if CMOFUseDump1 then N_Dump1Str( 'Fin 5 CMCaptDev3Form.CheckTimerTimer' );
  CheckTimer.Enabled := True;

end; // procedure TN_CMCaptDev3sForm.CheckTimerTimer


//****************  TN_CMCaptDev3sForm class public methods  ************

//***************************************** TN_CMCaptDev3sForm.CMOFDrawThumb ***
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
procedure TN_CMCaptDev3Form.CMOFDrawThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                          const ARect: TRect );
begin
  with N_CM_GlobObj do begin
    CMStringsToDraw[0] := Format( ' %d ', [Length(CMOFPNewSlides^)-AInd] );

    CMOFDrawSlideObj.DrawOneThumb5( CMOFPNewSlides^[AInd],
                                    CMStringsToDraw, CMOFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMCaptDev3sForm.CMOFDrawThumb

//************************************** TN_CMCaptDev3sForm.CMOFGetThumbSize ***
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
procedure TN_CMCaptDev3Form.CMOFGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
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
end; // procedure TN_CMCaptDev3sForm.CMOFGetThumbSize

//***************************************** TN_CMCaptDev3sForm.CMOFSetStatus ***
// Set and Show current Device (Form) status
//
//     Parameters
// AIntStatus - given Status (one of N_CMOF3xxx constants)
//
procedure TN_CMCaptDev3Form.CMOFSetStatus( AIntStatus: integer );
begin
  CMOFCurStatus := AIntStatus;

  case AIntStatus of

  N_CMOF3Unknown: begin
    ///  LLLOther3Disconnected = Disconnected
    StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
    StatusLabel.Font.Color  := clBlack;
    StatusShape.Pen.Color   := clBlack;
    StatusShape.Brush.Color := clBlack;
  end; // N_CMOF3Unknown: begin

  N_CMOF3Ready: begin
    ///  LLLOther3Ready = Ready
    StatusLabel.Caption := N_CML2Form.LLLOther3Ready.Caption;
    StatusLabel.Font.Color  := clGreen;
    StatusShape.Pen.Color   := clGreen;
    StatusShape.Brush.Color := clGreen;
  end; // N_CMOF3Ready: begin

  N_CMOF3Disconnected: begin
    ///  LLLOther3Disconnected = Disconnected
    StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
    StatusLabel.Font.Color  := clBlack;
    StatusShape.Pen.Color   := clBlack;
    StatusShape.Brush.Color := clBlack;
  end; // N_CMOF3Disconnected: begin

  N_CMOF3Scanning: begin
    ///  LLLOther3Scanning = Scanning
    StatusLabel.Caption := N_CML2Form.LLLOther3Scanning.Caption;
    StatusLabel.Font.Color  := clBlue;
    StatusShape.Pen.Color   := clBlue;
    StatusShape.Brush.Color := clBlue;
  end; // N_CMOF3Scanning: begin

  N_CMOF3Error: begin
    ///  LLLOther3Error = Error
    StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
    StatusLabel.Font.Color  := clRed;
    StatusShape.Pen.Color   := clRed;
    StatusShape.Brush.Color := clRed;
  end; // N_CMOF3Error: begin

  N_CMOF3Closing: begin
    ///  LLLOther3Closing = Closing ...
    StatusLabel.Caption := N_CML2Form.LLLOther3Closing.Caption;
    StatusLabel.Font.Color  := clGreen;
    StatusShape.Pen.Color   := clGreen;
    StatusShape.Brush.Color := clGreen;
  end; // N_CMOF3Error: begin

  end; // case AIntStatus of

  StatusLabel.Repaint;
  StatusShape.Repaint;

end; // end of TN_CMCaptDev3sForm.CMOFSetStatus

//************************************ TN_CMCaptDev3sForm.CMOFTryToCloseSelf ***
// Free all resources and Close Self if possible
//
procedure TN_CMCaptDev3Form.CMOFTryToCloseSelf();
var
  ResCode: integer;
begin
  N_Dump2Str( Format( 'TryToCloseSelf (%d)', [CMOFCurStatus] ) );

  if CMOFCurStatus <> N_CMOF3Closing then // first call to CMOFTryToCloseSelf
  begin
    CMOFStartClosing := CMOFNumTEvents;
    N_Dump2Str( 'Start Closing Scanner' );
  end;

  ResCode := N_CMECDCloseScanner();
  N_Dump2Str( Format( 'Closing Scanner ResCode=%d', [ResCode] ) );

  if (ResCode = SoS_OK) or (ResCode = SoS_NOTOPEN) then // OK to Close Form
  begin
    CheckTimer.Enabled := False;
    CMOFOKToCloseForm := True;
  end else // Try to Close Scanner later
  begin
    CMOFOKToCloseForm := False;
    CMOFSetStatus( N_CMOF3Closing );
  end;

end; // procedure TN_CMCaptDev3sForm.CMOFTryToCloseSelf

//************************************** TN_CMCaptDev3sForm.CMOFCaptureSlide ***
// Capture Slide from file and show it
//
//     Parameters
// Return 0 if OK
//
function TN_CMCaptDev3Form.CMOFCaptureSlide(): integer;
var
  i, XYPixSize, XYImageSize: integer;
  DeviceDPI: float;
  CapturedDIB: TN_DIBObj;
  NewSlide: TN_UDCMSlide;
  RootComp: TN_UDCompVis;
  FileStream: TFileStream;
begin
  //***** Get DeviceDPI
  XYPixSize := N_CMECDGetDSDPixelSize(); //HighWord - X, LowWord - Y in micrometers
  DeviceDPI := N_InchInmm * 1000.0 / (XYPixSize and $0FF);

  Inc( CMOFNumCaptured ); // now CMOFNumCaptured can be used as Slide number

  //***** Create CapturedDIB (new 12 bit variant)

  XYImageSize := N_CMECDGetDSDImageSize();
  CapturedDIB := TN_DIBObj.Create();

  try
    CapturedDIB.PrepEmptyDIBObj( XYImageSize shr 16, XYImageSize and $0FFFF,
                                 pfCustom, -1, epfGray16, 12 );
  except
    N_Dump1Str( 'Out of Memory error ' );
    CapturedDIB.Free;
    Result := 2;
    Exit;
  end; // except

  FileStream := TFileStream.Create( N_AnsiToString( CMOFAnsiFName ), fmOpenRead );
  CapturedDIB.ReadPixelsFromStream( FileStream );
  FileStream.Free;
  CapturedDIB.FlipAndRotate( 2 ); // Flip Vertically
//  CapturedDIB.ReduceNumBits();


//  CapturedDIB := TN_DIBObj.Create( N_AnsiToString( CMOFAnsiFName ) ); // old variant
//  CapturedDIB.Convpf8BitToGray8();

  with CapturedDIB.DIBInfo.bmi do
  begin
    biXPelsPerMeter := Round( DeviceDPI * 1000 / N_InchInmm );
    biYPelsPerMeter := biXPelsPerMeter;
  end;

  //***** Create NewSlide

//  NewSlide := K_CMSlideCreateFromDIBObj( CapturedDIB, @(CMOFPProfile^.CMAutoImgProcAttrs) );
  NewSlide := N_CMCreateCalibratedSlide( CapturedDIB, CMOFPProfile, DeviceDPI );
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

  Result := 0;
end; // end of TN_CMCaptDev3sForm.CMOFCaptureSlide

//************************************** TN_CMCaptDev3sForm.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev3Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev3sForm.CurStateToMemIni

//************************************** TN_CMCaptDev3sForm.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMCaptDev3Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMCaptDev3sForm.MemIniToCurState

end.
