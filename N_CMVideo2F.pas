unit N_CMVideo2F;
// Form for Video Capturing in CMS Project (Mode #0)
// 29.06.2015 - Still Image is the first and default always
// 16.07.2015 - Dental Unit code updated

// 04.08.15 - added N_Video in the uses for some shared functions

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, Types, Menus,
  K_Types, K_CM0,
  N_Types, N_Lib0, N_Lib1, N_Gra0, N_Gra1, N_Gra2, N_BaseF, N_Video, N_Rast1Fr,
  N_DGrid, N_CM2,  N_CM1;

type TN_CMVFPrepFlags = Set Of ( cmvfpfInitialCall, cmvfpfInitSizes );

type TN_CMVideo2Form = class( TN_BaseForm )
    MainPanel: TPanel;
    RightPanel: TPanel;
    ButtonsPanel: TPanel;
    Label2: TLabel;
    cbCaptMode: TComboBox;
    VideoPanel: TPanel;
    bnFinish: TButton;
    bnCaptFilterSettings: TButton;
    bnStreamSettings: TButton;
    RecordTimer: TTimer;
    gbCaptured: TGroupBox;
    NumCaptLabel: TLabel;
    Label3: TLabel;
    cbCaptSize: TComboBox;
    ThumbsRframe: TN_Rast1Frame;
    bnCameraSettings: TButton;
    bnStop: TButton;
    TimeLabel: TLabel;
    bnCapture: TButton;
    VideoControlsPanel: TPanel;
    StillControlsPanel: TPanel;
    bnRecord: TButton;
    rgOneTwoClicks: TRadioGroup;
    gbPreviewMode: TGroupBox;
    tbarPreviwMode: TToolBar;
    tbnPM1: TToolButton;
    PleaseWaitLabel: TLabel;
    LeftPanel: TPanel;
    SlidePanel2: TPanel;
    RFrame2: TN_Rast1Frame;
    SlidePanel3: TPanel;
    RFrame3: TN_Rast1Frame;
    SlidePanel4: TPanel;
    RFrame4: TN_Rast1Frame;
    TmpLabel: TLabel;
    SlidePanel1: TPanel;
    RFrame1: TN_Rast1Frame;
    tbnPM2: TToolButton;
    tbnPM3: TToolButton;
    tbnPM4: TToolButton;
    ExtDLLTimer: TTimer;
    bnCrossBarSettings: TButton; // Video Capturing Form

    //****************  TN_CMVideo2Form class handlers  ******************

    procedure FormShow  ( Sender: TObject );
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;

    procedure cbCaptSizeChange   ( Sender: TObject );
    procedure cbCaptModeChange   ( Sender: TObject );

    procedure bnStreamSettingsClick     ( Sender: TObject );
    procedure bnCaptFilterSettingsClick ( Sender: TObject );
    procedure bnCrossBarSettingsClick   ( Sender: TObject );

    procedure bnStopLiveClick     ( Sender: TObject );
    procedure bnRecordClick       ( Sender: TObject );
    procedure bnStopClick         ( Sender: TObject );
    procedure tbnPMNClick         ( Sender: TObject );
    procedure LeftPanelResize     ( Sender: TObject );
    procedure rgOneTwoClicksClick ( Sender: TObject );
    procedure bnCaptureMouseDown  ( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure bnCaptureMouseUp    ( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown         ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyUp           ( Sender: TObject; var Key: Word; Shift: TShiftState );

    procedure RecordTimerTimer    ( Sender: TObject );
    procedure ExtDLLTimerTimer    ( Sender: TObject );
  public
    CMVFThumbsDGrid:  TN_DGridArbMatr;   // DGrid for handling Thumbnails in ThumbsRFrame
    CMVFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails
    CMVFSSASlides: TN_UDCMSArray; // Array of Saved Slides

    CMVFPProfile: TK_PCMVideoProfile; // Pointer to Device Profile (Capturing Settings)
    CMVFVideoCapt: TN_VideoCaptObj; // main Video Capturing Object
    CMVFRecordedFName: string;      // Recorded File, ready after Stop button pressed

    CMVFStillImages: boolean; // True - Capturing Still Images, False - Recording Video
    CMVFRecordMode:  boolean; // True while Recording or in Record Pause
    CMVFPauseMode:   boolean; // True after Pause was pressed once in CMVFRecordMode

    CMVFNumSeconds:    double; // Number Of Seconds od Recorded Video
    CMVFNumStills:    integer; // Number Of Captured Still Images
    CMVFNumVideos:    integer; // Number Of Captured Videos
    CMVFileNumber:    integer; // Number used for creating Unique File Name

    CMVFPCurStatRecord: TN_PCMVideoStatRecord;
    CMVFNewPreviewMode:  integer; // New Preview Mode: 0-not init, 1-1Win, 2-2WinsVer, 3-2WinsHor, 4-4Wins
    CMVFCurPreviewMode:  integer; // Current Preview Mode: 0-not init, 1-1Win, 2-2WinsVer, 3-2WinsHor, 4-4Wins
    CMVFLastPreviewMode: integer; // Last PreviewMode: 0-not init, 1-1Win, 2-2WinsVer, 3-2WinsHor, 4-4Wins

    CMVFTwoClicksMode: Boolean; // True for TwoClicksMode and False for OneClickMode
    CMVFIsFirstClick:  Boolean; // True for First Click in TwoClicksMode
    CMVFIsFreezed:     Boolean; // Video Stream is Freezed in Still Images Mode
    CMVFUseF2F3Keys:   Boolean; // Use F2,F3 Keys as Foot Pedal (Camera Button) 0,1
    CMVFKey1IsDown:    Boolean; // Key 1 is currently down (to skip subsequent same events (Down or Up)
    CMVFKey2IsDown:    Boolean; // Key 2 is currently down (to skip subsequent same events (Down or Up)

    CMVFNumPWins:      integer; // Number of Preview Windows in Still Images mode (1, 2 or 4)
    CMVFPreviewSInds: array [0..3] of integer; // Array Slides indexes (CMVFSSASlides) in Preview Windows
    CMVFFreezedSlideInd:   integer; // Freezed (Last captured and not saved yet) Slide index
    CMVFHighlitedSlideInd: integer; // Highlited Slide index
    CMVFCurVideoAspect:     double; // Current Video Aspect
    CMVFFreezedSlide: TN_UDCMSlide; // Freezed Slide
    CMVFFreezedColor:      integer; // Freezed Slide Border Color

    CMVFFootPedalInd:      integer; // Foot Pedal DLL Index (old var)
//    CMVFIsFootPedalPressed1: TN_IntFuncPWChar; // Foot Pedal IsButtonPressed1 function (old var)
    CMVFFootPedalState:    integer; // current Foot Pedal state (0-Up, 1-Down) (old var)

    CMVFFootPedalDevInd:   integer; // current Foot Pedal Device index
    CMVFCameraBtnDevInd:   integer; // current Camera Button Device  Index
    CMVFDentalUnitDevInd:  Integer; // current Dental Unit Device  Index

//    CMVFCameraBtnInd:      integer; // Camera Button DLL Index
//    CMVFIsCameraBtnPressed1: TN_IntFuncPWChar; // Camera Button IsButtonPressed1 function
//    CMVFCameraBtnState:    integer; // current Camera Button state (0-Up, 1-Down)

//    CMVFSPCPUCounter: int64; // Sopro Touch CPU Counter

    CMVFCheckVideoFolderFlag : Boolean; // Check Video Folder before Capturing Flag

    procedure CMVFShowNumCaptured ();
    procedure CMVFPrepare         ( APrepFlags: TN_CMVFPrepFlags );
    procedure CMVFControlControls ( AEnable: boolean );
    procedure CMVFSetNewSize      ( ASizeStr: string );
    procedure CMVFSetVisibleVideoRect ();

    procedure CMVFDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure CMVFGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                   AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    function  CMVFSearchStatRecord ( ACompName, AOpName, ADevName, ACodec,
                                             ASize: string ): TN_PCMVideoStatRecord;
    function  CMVFAddStatRecord      ( AIsWorkingField: string ): TN_PCMVideoStatRecord;
    procedure CMVFSetIsWorkingField  ( AIsWorkingField: string );
    procedure CMVFThumbsDGridProcObj ( ADGObj: TN_DGridBase; AInd: integer );
    procedure CMVFFreezeStream   ();
    procedure CMVFRunStream      ();
    procedure CMVFSaveAndCont    ();
    procedure CMVFSkipAndCont    ();
    procedure CMVFFPCBDown       ( AKey: integer );
    procedure CMVFFPCBUp         ( AKey: integer );
    function  CMVFFindPWin       ( ASlideInd: integer ): integer;
    function  CMVFGetFreePWinInd (): integer;
    procedure CMVFLayoutPreviewWindows ( APreviewMode: integer );
    procedure CMVFDiscardFreezedSlide  ();
    procedure CMVFUpdatePWinsContent   ();
    procedure CMVFClearPWins      ();
    procedure CMVFUnHighlightPWin ( APWinIndex: integer );
    procedure CMVFCalcVideoAspect ( AStrSize: string );
    procedure V2FAddCurState      ( AStrings: TStrings; AIndent: integer );

    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
end; // type TN_CMVideo2Form = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

function N_CreateCMVideo2Form ( AOwner: TN_BaseForm;
                               APProfile: TK_PCMVideoProfile ): TN_CMVideo2Form;

var
  N_CMVideo2Form: TN_CMVideo2Form; // used in N_CMSCreateDumpFiles

implementation
uses
  Math, StrUtils,
  DirectShow9, DirectDraw,
  USBCam20SDK_TLB,
  K_CLib0, K_Parse, K_Script1,
  N_CompBase, N_Comp1, N_CMMain5F, N_CMResF, N_CMFPedalSF;
{$R *.dfm}
{$OPTIMIZATION OFF}

//var
//  edSourceNameText: string;

//****************  TN_CMVideo2Form class handlers  ******************

//************************************************ TN_CMVideo2Form.FormShow ***
// Perform needed Actions on Show Self
//
//     Parameters
// Sender - Event Sender
//
// OnShow Self handler
//
procedure TN_CMVideo2Form.FormShow( Sender: TObject );
var
  i: integer;
  StringTemp: string;
begin
  N_Dump2Str( 'Start TN_CMVideo2Fotimrm.FormShow, CMDPStrPar2 = ' +
                                                     CMVFPProfile.CMDPStrPar2 );
  CMVFDrawSlideObj := TN_CMDrawSlideObj.Create();
  CMVFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, CMVFGetThumbSize );

  with CMVFThumbsDGrid do
  begin
    DGEdges := Rect( 2, 2, 2, 2 );
    DGGaps  := Point( 2, 2 );
    DGScrollMargins := Rect( 8, 8, 8, 8 );

    DGLFixNumCols   := 1;
    DGLFixNumRows   := 0;
    DGSkipSelecting := True;
    DGChangeRCbyAK  := True;
    DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor
    DGMultiMarking  := False;

    DGBackColor     := ColorToRGB( clBtnFace );
    DGMarkBordColor := N_CM_SlideMarkColor;
    DGMarkNormWidth := 2;
    DGMarkNormShift := 2;

    DGNormBordColor := DGBackColor;
    DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
    DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

    DGLAddDySize    := 0; // see DGLItemsAspect
    DGLItemsAspect  := 0.75;

    DGDrawItemProcObj := CMVFDrawThumb;
//    DGExtExecProcObj  := ThumbsRFrameExecute;
    DGChangeItemStateProcObj := CMVFThumbsDGridProcObj;

    ThumbsRFrame.DstBackColor := DGBackColor;
    CMVFThumbsDGrid.DGInitRFrame();
    CMVFThumbsDGrid.DGDrawRFrame(); // should be call manually after each call to DGInitRFrame
  end; // with CMMFThumbsDGrid do

  CMVFShowNumCaptured();
  CMVFCheckVideoFolderFlag := K_CMEDAccess.EDAVideoFolderAccessPrevCheck();

  try // Always (temporary?) Create Schick USB Cam4 Camera Interface
    N_CMFPedalSF.N_SchickUSBCam4Camera := CoCCamera.Create;

    if N_CMFPedalSF.N_SchickUSBCam4Camera <> Nil then
      N_Dump1Str( 'SchickUSBCam4 Camera is present' )
    else
      N_Dump1Str( 'SchickUSBCam4 Camera is absent' );

  except // CoCCamera.Create failure
     N_CMFPedalSF.N_SchickUSBCam4Camera := Nil;
  end; // try // Always (temporary?) Create Schick USB Cam4 Camera Interface

  N_Dump2Str( 'TN_CMVideo2Form.FormShow before, CMDPStrPar2 = ' +
                                                     CMVFPProfile.CMDPStrPar2 );
  if Length(CMVFPProfile.CMDPStrPar2) < 8 then
  begin
    if Length(CMVFPProfile.CMDPStrPar2) = 7 then
    begin
      StringTemp := '0';
      StringTemp[1] := CMVFPProfile.CMDPStrPar2[5];
      CMVFPProfile.CMDPStrPar2[5] := CMVFPProfile.CMDPStrPar2[7];
      CMVFPProfile.CMDPStrPar2 := CMVFPProfile.CMDPStrPar2 + StringTemp[1];
      CMVFPProfile.CMDPStrPar2[8] := StringTemp[1];
      CMVFPProfile.CMDPStrPar2[7] := '0';
    end;

    // set initial parameters
    // CMDStrPar2 =
    // - Flip
    // - Capture Button usage
    // - Camera Button Threshold
    // - Still Pin usage
    // - Filter
    // - Renderer
    StringTemp := '00000100';

    if Length(CMVFPProfile.CMDPStrPar2) <> 8 then
      for i := Length(CMVFPProfile.CMDPStrPar2) + 1 to 8 do
        CMVFPProfile.CMDPStrPar2 := CMVFPProfile.CMDPStrPar2 + StringTemp[i];
  end;
  N_Dump2Str('TN_CMVideo2Form.FormShow after, CMDPStrPar2 = ' +
                                                     CMVFPProfile.CMDPStrPar2 );

end; // procedure TN_CMVideo2Form.FormShow

//*********************************************** TN_CMVideo2Form.FormClose ***
// Perform needed Actions on Closing Self
//
//     Parameters
// Sender - Event Sender
// Action - what to do after closing (caNone, caHide, caFree, caMinimize)
//
// OnClose Self handler
//
procedure TN_CMVideo2Form.FormClose( Sender: TObject; var
                                                         Action: TCloseAction );
begin

  CMVFVideoCapt.Free;

  if CMVFIsFreezed then  // clear all info about Freezed Slide if closing in Freezed mode
    CMVFDiscardFreezedSlide();

  //***** Save current Interface Settings
  with CMVFPProfile^ do
  begin
    CMVResolution  := cbCaptSize.Text;
    //CMVCMode       := TK_CMVCMode(cbCaptMode.ItemIndex);
    CMPreviewMode  := CMVFNewPreviewMode; // set by last tbnPMi Toolbutton Click
    CMNumClicksInd := rgOneTwoClicks.ItemIndex;
  end; // with CMVFPProfile^ do

  N_FPCBObj.FPCBUnloadDLL( CMVFFootPedalDevInd ); // Unload Foot Pedal DLL (if any)
  N_FPCBObj.FPCBUnloadDLL( CMVFCameraBtnDevInd ); // Unload Camera Button DLL (if any)

  N_FPCBObj.FPCBDUCameraTaken := False; // is needed to enable calling FPCBGetDUState form FPCBIfDUCameraTaken

  CMVFThumbsDGrid.Free;
  CMVFDrawSlideObj.Free;
  N_CMFPedalSF.N_SchickUSBCam4Camera := Nil; // N_SchickUSBCam4Camera Interface was created in FormShow

  Inherited;

  N_CMVideo2Form := nil;
end; // procedure TN_CMVideo2Form.FormClose

//**************************************** TN_CMVideo2Form.cbCaptSizeChange ***
// Set new Capturing Size
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// cbCaptSizeChange OnChange Handler
//
procedure TN_CMVideo2Form.cbCaptSizeChange( Sender: TObject );
begin
  N_Dump2Str( ' cbCaptSize : ' + cbCaptSize.Text );
  CMVFPrepare( [] );
end; // procedure TN_CMVideo2Form.cbCaptSizeChange

//**************************************** TN_CMVideo2Form.cbCaptModeChange ***
// Set Capturing Mode: Still Images (Ind=0) or Recording Video (Ind=1)
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//           or nil for initialize controls only without preparing Graph
//
// All current activity shoulb Stopped and all fields initialized properly
//
// cbCaptMode OnChange Handler
//
procedure TN_CMVideo2Form.cbCaptModeChange( Sender: TObject );
begin
  if cbCaptMode.ItemIndex = 0 then // initialize "Still Images" mode
    N_Dump2Str( 'Set "Still Images" mode' )
  else //************************ initialize "Recording Video" mode
    N_Dump2Str( 'Set "Recording Video" mode' );

  CMVFPrepare( [cmvfpfInitSizes] );
end; // procedure TN_CMVideo2Form.cbCaptModeChange

//*********************************** TN_CMVideo2Form.bnStreamSettingsClick ***
// Show StreamConfig Dialog, provided by installed Drived
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// bnStreamSettings OnClick Handler (DriverSettings1 button)
//
procedure TN_CMVideo2Form.bnStreamSettingsClick( Sender: TObject );
var
  VFInfo: TN_VideoFileInfo;
begin
  with CMVFVideoCapt do
  begin
    if N_KeyIsDown( VK_SHIFT ) then // debug - just collect info about VCOVCaptDevName capabilities
    begin
      N_DSEnumVideoCaps( VCOVCaptDevName, VCOStrings );
      N_SaveStringsToAnsiFile( K_ExpandFileName( '(#CMSLogFiles#)Video_Caps.txt' ), VCOStrings );
      Exit;
    end; // if N_KeyIsDown( VK_SHIFT ) then // just collect info about Device capabilities

    if N_KeyIsDown( VK_CONTROL ) then // debug - get frames from avi file
    begin
      FillChar( VFInfo, SizeOf(VFInfo), 0 );
      VFInfo.VFINumDIBs := 2;
      VFInfo.VFIFirstDIBTime := 0.2;
      VFInfo.VFIDIBTimeStep  := 2.0;
      N_i := N_GetVideoFileInfo( '(#CMSLogFiles#)ResVideo_000.avi', @VFInfo );

      Exit;
    end; // if N_KeyIsDown( VK_CONTROL ) then //

    if N_KeyIsDown(VK_MENU) then // Alt is down
    begin
//      VCOClearGraph(); // Stop and clear all, for debug only
    end; // if N_KeyIsDown(VK_MENU) then // Alt is down

    VCOShowStreamDialog( VCOWindowHandle );

    if VCOIError <> 0 then VCOIError := 0; // ignore errors ?
  end; // with CMVFVideoCapt do
end; // procedure TN_CMVideo2Form.bnStreamSettingsClick

//******************************* TN_CMVideo2Form.bnCaptFilterSettingsClick ***
// Show Video Capturing Device Dialog, provided by installed Drived
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// bnFilterSettings OnClick Handler (DriverSettings2 button)
//
procedure TN_CMVideo2Form.bnCaptFilterSettingsClick( Sender: TObject );
var
  VCOIMediaFilter: IMediaFilter;
  WideName: WideString;
begin
  with CMVFVideoCapt do
  begin

  if N_KeyIsDown( VK_SHIFT ) then // not used
  begin
    N_i := VCOIGraphBuilder.QueryInterface( IID_IMediaFilter, VCOIMediaFilter );
    VCOGetErrorDescr( N_i );
//    N_i := VCOIMediaControl.Stop();
    N_i := VCOIMediaControl.Pause();
//    N_i := VCOIMediaFilter.SetSyncSource( nil ); // Live video stops!
    VCOGetErrorDescr( N_i );
    N_i := VCOIMediaControl.Run();
    Exit;
  end; // if N_KeyIsDown( VK_SHIFT ) then

  if N_KeyIsDown( VK_CONTROL ) then // not used
  begin
    N_i := VCOIMediaControl.Stop(); // stop Graph to be able to change FileName
    N_i := VCOICaptGraphBuilder.RenderStream( @PIN_CATEGORY_PREVIEW,
         @MEDIATYPE_Video, VCOIVideoCaptFilter, VCOIVideoComprFilter, VCOIMux );

    VCOControlStream( [csfCapture,csfStop] ); // Stop Capture Stream
    N_i := VCOIMediaControl.Run();
    Exit;

//    N_CM_MainForm.CMMFShowStringByTimer( 'VIDEO ' + IntToStr( N_i+30 ) );
//    VCOControlStream( [csfCapture,csfStop] ); // Stop Capture stream (not needed?)
    N_i := VCOIMediaControl.Stop(); // stop Graph to be able to change FileName
    WideName := VCOFileNames[VCOFileNameInd];
    VCOFileNameInd := VCOFileNameInd xor 1;
//    N_i := VCOISink.SetFileName( PWideChar(WideName), nil );
    VCOControlStream( [csfCapture,csfStop] ); // Stop Capture Stream
    N_i := VCOIMediaControl.Run();
    Exit;


//   VCOControlStream( [csfCapture,csfStop] ); // Stop Capture stream (not needed?)
    N_i := VCOIMediaControl.Stop(); // stop Graph to be able to change FileName

    WideName := VCOFileNames[VCOFileNameInd];
    VCOFileNameInd := VCOFileNameInd xor 1;
    N_i := VCOISink.SetFileName( PWideChar(WideName), nil );

    N_i := VCOIMediaControl.Run();
    Exit;

    VCOControlStream( [csfCapture,csfStop] ); // Stop Capture stream (not needed?)
    N_i := VCOIMediaControl.Stop(); // stop Graph to be able to change FileName
//    VCOGetErrorDescr( N_i );
//    N_i := VCOGetGraphState();

    WideName := VCOFileNames[VCOFileNameInd];
    VCOFileNameInd := VCOFileNameInd xor 1;
//    N_i := VCOISink.SetFileName( PWideChar(WideName), nil );
    VCOControlStream( [csfCapture,csfStop] ); // Stop Capture Stream
//    N_i := VCOIError;
//    N_i := VCOGetGraphState();
    N_i := VCOIMediaControl.Run();
//    N_i := VCOGetGraphState();
    Exit;
  end; // if N_KeyIsDown( VK_CONTROL ) then

  VCOShowFilterDialog( VCOIVideoCaptFilter, VCOWindowHandle );

  end; // with CMVFVideoCapt do
end; // procedure TN_CMVideo2Form.bnCaptFilterSettingsClick

//********************************* TN_CMVideo2Form.bnCrossBarSettingsClick ***
// Show CrossBar Device Dialog, provided by installed Drived
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// bnCrossBarSettings OnClick Handler (CrossBar Settings button)
//
procedure TN_CMVideo2Form.bnCrossBarSettingsClick( Sender: TObject );
var
  CrossbarFilter: IBaseFilter;
begin
  with CMVFVideoCapt do
  begin
    CrossbarFilter := VCOGetCrossbarFilter();

    if CrossbarFilter <> nil then
      VCOShowFilterDialog( CrossbarFilter, VCOWindowHandle );

    CrossbarFilter := nil;
  end; // with CMVFVideoCapt do
end; // procedure TN_CMVideo2Form.bnCrossBarSettingsClick


//***************************************** TN_CMVideo2Form.bnStopLiveClick ***
// Stop Recording or Stop Viewing Freezed Picture and start Live Video
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// bnStopLive OnClick Handler
//
procedure TN_CMVideo2Form.bnStopLiveClick( Sender: TObject );
var
  SError: string;
  Label ShowError;
begin
  with CMVFVideoCapt do
  begin
  N_Dump2Str( 'Start bnStopLiveClick' );

  //*** Common settings
//  bnRecordFreeze.Enabled := True;
//  bnStopLive.Enabled     := False;
  CMVFControlControls( True ); // Enable ComboBoxes and DriverSettings Buttons

  if CMVFStillImages then //***** "Live" button pressed, return to "Live" mode
  begin
//    bnSave.Enabled  := False;

    VCOCoRes := VCOIMediaControl.Run();
    if Sender = nil then Exit; // if called from bnSaveClick, check error in it
    if VCOCheckRes( 190 ) then goto ShowError;
  end else //******************** "Stop" button pressed, Stop Recording Video
  begin
//    bnSave.Enabled  := True;

    CMVFRecordMode  := False;
//    bnPause.Enabled := False;

    TimeLabel.Visible := False;
    RecordTimer.Enabled := False;

    CMVFRecordedFName := VCOStopRecording();
    if VCOIError <> 0 then goto ShowError;
  end; // else // Record Video

  N_Dump2Str( 'Fin bnStopLiveClick' );
  Exit; // all done OK

  ShowError: //**************************
  SError := IntToStr(VCOIError) +  ' - Unexpected DirectShow Error5 - '
                                                                    + VCOSError;
  N_Dump1Str( SError );
  K_CMShowMessageDlg( SError, mtWarning );
  end; // with CMVFVideoCapt do
end; // procedure TN_CMVideo2Form.bnStopLiveClick

//******************************************* TN_CMVideo2Form.bnRecordClick ***
// Start recording Video
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// bnRecord OnClick Handler
//
procedure TN_CMVideo2Form.bnRecordClick( Sender: TObject );
begin
  with CMVFVideoCapt do
  begin
    if K_CMDEMOAddConstraint() = 0 then Exit; // later show warning text

    if CMVFCheckVideoFolderFlag then
    begin
    // Check Video Folder Access
      CMVFCheckVideoFolderFlag := FALSE; // Check only for 1st Video Capturing
//      if not K_CMEDAccess.EDACheckVideoFolderAccessDlg() then
      if 0 <> K_CMEDAccess.EDACheckAllFilesAccess( False, True, False,
                    ' Press OK to stop Video data processing.' ) then
      begin
        bnRecord.Enabled := FALSE;
        bnStop.Enabled := FALSE;
        Exit;
      end;
    end;

    N_Dump2Str( 'Start bnRecordClick' );

    CMVFControlControls( False ); // temporary disable ComboBoxes and DriverSettings Buttons
    CMVFRecordMode  := True;

    CMVFNumSeconds := 0.0;
    RecordTimerTimer( Sender ); // Show TimeLabel
    TimeLabel.Visible   := True;
    RecordTimer.Enabled := True;
    bnStop.Enabled      := True;

    VCOStartRecording();

    if VCOIError <> 0 then
    begin
      K_CMShowMessageDlg( IntToStr(VCOIError) +
                  ' - Unexpected DirectShow Error6 - ' + VCOSError, mtWarning );
    end; // if VCOIError <> 0 then

  end; // with CMVFVideoCapt do
end; // procedure TN_CMVideo2Form.bnRecordClick

//********************************************* TN_CMVideo2Form.bnStopClick ***
// Stop recording Video and Save it (create Media Object)
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// bnStop OnClick Handler
//
procedure TN_CMVideo2Form.bnStopClick( Sender: TObject );
var
  SlideInd: Integer;
  SError: string;
  WMediaFName, WCaptMediaFName: WideString;
  FSlide: TN_UDCMSlide;
  SavedCursor : TCursor;
//  PCMVideoProfile: TK_PCMDeviceProfile;
  Label ShowError;
begin
  bnStop.Enabled := False;
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  CMVFNumSeconds := 0;
  RecordTimerTimer( nil );
  TimeLabel.Caption := ' Saving ... ';
  TimeLabel.Visible := True;

  with CMVFVideoCapt do
  begin
    N_Dump2Str( 'Start bnStopClick' );
    CMVFRecordMode  := False;

    TimeLabel.Visible := False;
//    RecordTimer.Enabled := False;

    CMVFRecordedFName := VCOStopRecording();
    if VCOIError <> 0 then goto ShowError;

    if VCOIVideoWindow <> nil then
      VCOIVideoWindow.put_Visible( FALSE );

    N_Dump2Str( 'Recording is stopped' );

    Inc( CMVFNumVideos );

    FSlide := K_CMSlideCreateForMediaObject( '.avi' );
    WMediaFName := FSlide.GetMediaFileClientName(); // TMP MediaFileName

    WCaptMediaFName := VCOFileNames[VCOFileNameInd];
    VCOCoRes := VCOICaptGraphBuilder.CopyCaptureFile(
                   PWideChar(WCaptMediaFName), PWideChar(WMediaFName), 0, nil );
    if VCOCheckRes( 193 ) then
    begin
      FSlide.UDDelete();
      goto ShowError;
    end;
    FSlide.AddMediaFile( WMediaFName );

    //***** Prepare FSlide and add it to Current Slides Set

    SlideInd := Length(CMVFSSASlides);
    SetLength( CMVFSSASlides, SlideInd + 1 );
    CMVFSSASlides[SlideInd] := FSlide;

    //*** FSlide.ObjAliase is used for Showing in ThumbRFrame and in Setting Properties Form
    FSlide.ObjAliase := 'Video ' + IntTostr(CMVFNumVideos);

    with FSlide.P()^ do
    begin
//      CMSSourceDescr := CMVFVideoCapt.VCOVCaptDevName;
      CMSSourceDescr := CMVFPProfile^.CMDPCaption;
      FSlide.ObjInfo := 'Imported from ' + CMSSourceDescr;
      CMSMediaType := CMVFPProfile^.CMDPMTypeID;
    end;

    K_CMEDAccess.EDAAddSlide( FSlide );

    Inc(CMVFThumbsDGrid.DGNumItems);
    CMVFThumbsDGrid.DGInitRFrame();

    CMVFShowNumCaptured();

    if CMVFPCurStatRecord <> nil then // new record was created
      CMVFPCurStatRecord^.CMSRIsWorking := 'OK';

    RecordTimer.Enabled := False;
    TimeLabel.Visible := False; // clear "Saving ..." label
    PleaseWaitLabel.Visible := False;

    if VCOIVideoWindow <> nil then
      VCOIVideoWindow.put_Visible( TRUE );

    CMVFControlControls( True ); // enable ComboBoxes and DriverSettings Buttons
    Screen.Cursor := SavedCursor;
    Exit; // all done OK


    ShowError: //**************************
    SError := IntToStr(VCOIError) +  ' - Unexpected DirectShow Error5 - '
                                                                    + VCOSError;
    N_Dump1Str( SError );
    K_CMShowMessageDlg( SError, mtWarning );

    if CMVFPCurStatRecord <> nil then // new record was created
      CMVFPCurStatRecord^.CMSRIsWorking := 'Failed2';

    CMVFControlControls( True ); // enable ComboBoxes and DriverSettings Buttons
  end; // with CMVFVideoCapt do

  CMVFControlControls( True ); // Enable ComboBoxes and DriverSettings Buttons
  Screen.Cursor := SavedCursor;
end; // procedure TN_CMVideo2Form.bnStopClick

//********************************************* TN_CMVideo2Form.tbnPMNClick ***
// Set Still Images Preview Mode 1 - 4 by Sender.Tag
//
//     Parameters
// ASender - ToolButton just clicked
//
// tbnPM1,tbnPM2,tbnPM3,tbnPM4  OnClick Handler
//
procedure TN_CMVideo2Form.tbnPMNClick( Sender: TObject );
var
  CurFreezedPwinInd: integer;
begin
  CMVFNewPreviewMode := Integer(Sender);
  if CMVFNewPreviewMode > 4 then // Sender is one of tbnPM1 - tbnPM4 buttons
    CMVFNewPreviewMode := TToolButton(Sender).Tag;

  N_Dump2Str( Format( 'New CMVFNewPreviewMode = %d was set',
                                                       [CMVFNewPreviewMode] ) );

  if not CMVFIsFreezed then Exit; // all done (CMVFNewPreviewMode was set) if not currently Freezed

  //***** Change Preview Windows if needed in Freezed state

  CMVFCurPreviewMode := CMVFNewPreviewMode;
  CurFreezedPwinInd := CMVFFindPWin( CMVFFreezedSlideInd ); // Pwin with Freezed image

  CMVFUnHighlightPWin( 0 );
  CMVFPreviewSInds[CurFreezedPwinInd] := -1; // clear ref to Freezed Slide
  CMVFPreviewSInds[0] := CMVFFreezedSlideInd; // always move Freezed PWin to Index=0

  if CMVFCurPreviewMode = CMVFLastPreviewMode then // Same Layout, Clear Preview Wins content
  begin
    N_Dump2Str( 'Same Layout' );
    CMVFClearPWins();
    CMVFPreviewSInds[0] := CMVFFreezedSlideInd;
    CMVFUpdatePWinsContent();
  end else //*********************** New Layout, Update Preview Windows layout
  begin
    N_Dump2Str( 'New Layout' );
    CMVFLayoutPreviewWindows( CMVFCurPreviewMode );

    case CMVFCurPreviewMode of //
      1: CMVFNumPWins := 1;
      2: CMVFNumPWins := 2;
      3: CMVFNumPWins := 2;
      4: CMVFNumPWins := 4;
    end; // case CMVFCurPreviewMode of //

    CMVFUpdatePWinsContent();
    CMVFLastPreviewMode := CMVFCurPreviewMode
  end; // else // New Layout, Update Preview Windows layout

{ // old vars
    if CMVFCurPreviewMode = 1 then // One Preview Window
    begin
      CMVFNumPWins := 1;
    end else if CMVFCurPreviewMode <= 3 then // Two Preview Windows (Modes 2,3)
    begin

      if (CMVFPreviewSInds[2] = CMVFFreezedSlideInd) or
         (CMVFPreviewSInds[3] = CMVFFreezedSlideInd)   then
      begin
        CMVFUnHighlightPWin( 0 );
        CMVFPreviewSInds[CurFreezedPwinInd] := -1; // clear ref to Freezed Slide
        CMVFPreviewSInds[0] := CMVFFreezedSlideInd;
      end;

      CMVFNumPWins := 2;
    end else // Four Preview Windows (Modes 4)
    begin
      CMVFNumPWins := 4;
    end;

    case CMVFCurPreviewMode of //
    1: begin // One Preview Window
       end; // 1: begin // One Preview Window
    2: begin // Two Preview Vertical Windows (one over another, Splitter is horizontal)
       end; // 2: begin // Two Preview Vertical Windows (one over another, Splitter is horizontal)
    3: begin // Two Preview Horizontal Windows (Splitter is Vertical)
       end; // 3: begin // Two Preview Horizontal Windows (Splitter is Vertical)
    4: begin // Four Preview Windows
         // nothing todo
       end; // 4: begin // Four Preview Windows
    end; // case NewMode of
}
end; // procedure TN_CMVideo2Form.tbnPMNClick

//***************************************** TN_CMVideo2Form.LeftPanelResize ***
// Update Video Panel and Preview Frames size and position
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// LeftPanel OnResize Handler
//
procedure TN_CMVideo2Form.LeftPanelResize( Sender: TObject );
var
  CurRect, NeededRect: TRect;
begin
//  TmpLabel.Caption := Format( 'Live: %d %d', [LeftPanel.Width, LeftPanel.Height] ); // debug

  if CMVFIsFreezed then // update Preview Frames size and position
  begin
    CMVFLayoutPreviewWindows( CMVFCurPreviewMode );
  end else //************* update Video Panel size and position
  begin
    NeededRect := N_GetClientRectOfControl( LeftPanel );
    NeededRect := N_DecRectbyAspect( NeededRect, 0.75 );
    CurRect    := N_GetClientRectOfControl( VideoPanel );

    if not N_SameIRects( CurRect, NeededRect ) then
      N_SetClientRectOfControl( VideoPanel, NeededRect );

    CMVFSetVisibleVideoRect();
  end; // else //************* update Video Panel size and position
end; // procedure TN_CMVideo2Form.LeftPanelResize

//************************************* TN_CMVideo2Form.rgOneTwoClicksClick ***
// Set One or Two Clicks Mode (for Still Images) and initialize Clicks State
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// rgOneTwoClicks OnClick Handler
//
procedure TN_CMVideo2Form.rgOneTwoClicksClick( Sender: TObject );
begin
  CMVFTwoClicksMode := rgOneTwoClicks.ItemIndex = 0;

  if CMVFTwoClicksMode then
    N_Dump2Str( 'Set Two Clicks Mode' )
  else
    N_Dump2Str( 'Set Single Click Mode' );

  //*** initialize Clicks State

  CMVFIsFirstClick := True;
  if CMVFIsFreezed then CMVFSkipAndCont();
end; // procedure TN_CMVideo2Form.rgOneTwoClicksClick

//************************************** TN_CMVideo2Form.bnCaptureMouseDown ***
// Freeze if needed
//
//     Parameters
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
// bnCapture OnMouseDown Handler
//
procedure TN_CMVideo2Form.bnCaptureMouseDown ( Sender: TObject;
                      Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
begin
  N_Dump2Str( 'bnCaptureMouseDown' );
  CMVFFPCBDown( 1 ); // Capture button is treated as Key 1
end; // procedure TN_CMVideo2Form.bnCaptureMouseDown

//**************************************** TN_CMVideo2Form.bnCaptureMouseUp ***
// Save if needed
//
//     Parameters
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
// bnCapture OnMouseUp Handler
//
procedure TN_CMVideo2Form.bnCaptureMouseUp( Sender: TObject;
                       Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  N_Dump2Str( 'bnCaptureMouseUp' );
  CMVFFPCBUp( 1 ); // Capture button is treated as Key 1
end; // procedure TN_CMVideo2Form.bnCaptureMouseUp

//********************************************* TN_CMVideo2Form.FormKeyDown ***
// Freeze if needed if F2 key is pressed
//
//     Parameters
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
// Self (Form) OnKeyDown Handler
//
procedure TN_CMVideo2Form.FormKeyDown( Sender: TObject; var Key: Word;
                                                           Shift: TShiftState );
var
  LogFilesDir, FName: string;
  SL: TStringList;
begin
//  if (Key = VK_F12) and (ssShift in Shift) and (ssCtrl in Shift) then // trmporary divide by 0 for debug!!
//    N_d := 1.0 / Sin(0);

  if (Key = VK_F11) and (ssShift in Shift) and (ssCtrl in Shift) then // create deb info
  begin
    LogFilesDir := K_ExpandFileName( '(#CMSLogFiles#)' );
    FName := LogFilesDir + N_GetDateTimeStr1() + '_CaptGraphFilters.txt';

    SL := TStringlist.Create;
    SL.Add( 'Capture Graph Filters info:' );
    SL.Add( '' );

    CMVFVideoCapt.VCOEnumFilters( SL );

    N_SaveStringsToAnsiFile( FName, SL );
    N_Dump1Str( FName + ' file created' );
    SL.Free;
    Exit;
  end; // if (Key = VK_F11) and (ssShift in Shift) and (ssCtrl in Shift) then // create deb info

  if CMVFCameraBtnDevInd = N_FPCB_Keystrokes then // Use "Keystrokes" Camera Button Device
  begin
    with CMVFPProfile^ do
    begin
      if ShortCut( Key, Shift ) = CMFreezeUnfreezeKey then // Freeze / Unfreeze
      begin
        if CMVFTwoClicksMode then // Two Clicks Mode, toggle Freeze / Unfreeze
        begin
          if CMVFIsFreezed then
            CMVFSkipAndCont()
          else
            CMVFFreezeStream();
        end else //***************** Single Click Mode, Freeze, Save and Unfreeze
        begin
          CMVFFreezeStream();
          CMVFSaveAndCont();
        end // else //***************** Single Click Mode, Freeze, Save and Unfreeze
      end; // if ShortCut( Key, Shift ) = CMFreezeUnfreezeKey then // Freeze / Unfreeze

      if ShortCut( Key, Shift ) = CMSaveAndUnfreezeKey then // Save And Unfreeze
      begin
        if CMVFTwoClicksMode then // Two Clicks Mode, Save and Unfreeze only if Frozen
        begin
          if CMVFIsFreezed then
            CMVFSaveAndCont();
        end else //***************** Single Click Mode, Freeze, Save and Unfreeze
        begin
          // nothing todo
        end // else //***************** Single Click Mode, Freeze, Save and Unfreeze
      end; // // if ShortCut( Key, Shift ) = CMSaveAndUnfreezeKey then // Save And Unfreeze

      Exit; // All done for "Keystrokes" Camera Button
    end; // with CMVFPProfile^ do
  end; // if CMVFCameraBtnDevInd = N_FPCB_Keystrokes then // Use "Keystrokes" Camera Button Device

  if (Key = VK_F2) and CMVFUseF2F3Keys then // emulate Key 1 press
  begin
    N_Dump2Str( 'FormKeyDown F2' );
    CMVFFPCBDown( 1 ); // F2 Key is treated as FPCB Key 1
    Exit;
  end; // if (Key = VK_F2) and CMVFUseF2F3Keys then

  if (Key = VK_F3) and CMVFUseF2F3Keys then
  begin
    N_Dump2Str( 'FormKeyDown F3' );
    CMVFFPCBDown( 1 ); // F3 Key is treated as Foot Pedal (Camera Button) 1
    Exit;
  end; // if (Key = VK_F3) and CMVFUseF2F3Keys then

  if (ssShift in Shift) and (Key = Byte('Z')) then // Create Dump files
  begin
    N_Dump2Str( 'Alt+Shift+Z(Video) is pressed ' );
    N_CMSCreateDumpFiles( 0 );
//    CMMFShowStringByTimer( 'Dump files created' );
    Exit;
  end; // if (ssShift in Shift) and (Key = Byte('Z')) then // Create Dump files
end; // procedure TN_CMVideo2Form.FormKeyDown

//*********************************************** TN_CMVideo2Form.FormKeyUp ***
// Save if needed if F2 key is pressed
//
//     Parameters
// Sender - Event Sender (Action, MenuItem or ToolButton)
//
// Self (Form) OnKeyDown Handler
//
procedure TN_CMVideo2Form.FormKeyUp( Sender: TObject; var Key: Word;
                                                            Shift: TShiftState);
begin
  if (Key = VK_F2) and CMVFUseF2F3Keys then
  begin
    N_Dump2Str( 'FormKeyUp F2' );
    CMVFFPCBUp( 1 );
  end; // if (Key = VK_F2) and CMVFUseF2F3Keys then

  if (Key = VK_F3) and CMVFUseF2F3Keys then
  begin
    N_Dump2Str( 'FormKeyUp F3' );
    CMVFFPCBUp( 2 );
  end; // if (Key = VK_F3) and CMVFUseF2F3Keys then
end; // procedure TN_CMVideo2Form.FormKeyUp

//**************************************** TN_CMVideo2Form.RecordTimerTimer ***
// In Recording mode while VRecording - Update and Show CMVFNumSeconds,
// in Still Images mode - check if currently freezed image should be discarded
//                        because of second long press in Two Clicks mode.
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// RecordTimer OnTimer Handler
//
procedure TN_CMVideo2Form.RecordTimerTimer( Sender: TObject );
var
  Phase: double;
begin
  if CMVFStillImages then //************************* Still Images mode
  begin
    if not CMVFIsFirstClick then // really not needed, just a precaution
    begin
      if CMVFNumSeconds > K_CMCaptButDelay then // discard currently freezed image and return to live mode
      begin
        N_Dump2Str( 'Still Image Discarded by Timer' );
        CMVFSkipAndCont();
      end; // if CMVFNumSeconds > K_CMCaptButDelay then
    end;
  end else //**************************************** Video recording mode
  begin
    if CMVFRecordMode then
    begin
      TimeLabel.Caption := Format( '  %5.1f  s ', [CMVFNumSeconds] );
    end else // Video is currently saving
    begin
      Phase := Frac( CMVFNumSeconds / 0.8 );
      if Phase <= 0.5 then PleaseWaitLabel.Visible := True
                      else PleaseWaitLabel.Visible := False;
    end;
  end;

  CMVFNumSeconds := CMVFNumSeconds + 0.2; // Timer interval should be 200!
end; // procedure TN_CMVideo2Form.RecordTimerTimer

//**************************************** TN_CMVideo2Form.ExtDLLTimerTimer ***
// Check all FPCB (Foot Pedal and Camera Buttons) Devices state
//
//     Parameters
// ASender - Event Sender (Action, MenuItem or ToolButton)
//
// ExtDLLTimer OnTimer Handler
//
procedure TN_CMVideo2Form.ExtDLLTimerTimer( Sender: TObject );
var
  CurState, PrevState, ResCode: integer;
  FP1Pressed, FP1Released, FP2Pressed, FP2Released: boolean;
begin
  with CMVFPProfile^ do // check all FPCB (Foot Pedal and Camera Buttons) Devices state
  begin

    if CMVFFootPedalDevInd <> N_FPCB_None then // Use Foot Pedal Device
    begin
      // Get Foot Pedal Current and Previous State in two least bits
      ResCode := N_FPCBObj.FPCBGetFPCBState( CMVFFootPedalDevInd, CurState,
                                                                    PrevState );

      if (ResCode <> 0) or (CurState <> PrevState) then
        N_Dump2Str( Format( 'Foot Pedal States: Cur=%d, Prev=%d (ResCode=%d)',
                                                [CurState,PrevState,ResCode] ));

      if ResCode <> 0 then // Foot Pedal Device error
      begin
        CMVFFootPedalDevInd := N_FPCB_None // do not Use Foot Pedal Device
      end else //*** No Foot Pedal Device error, use it
      begin
        // Decode CurState, PrevState ==> FP1Pressed, FP1Released, FP2Pressed, FP2Released
        N_CMDecodeFPCBStates ( CurState, PrevState,
                             FP1Pressed, FP1Released, FP2Pressed, FP2Released );

        if FP1Pressed then CMVFFPCBDown( 1 )
        else if FP1Released then CMVFFPCBUp( 1 )
        else // FP1 State did not changed, check FP2
        begin
          if FP2Pressed then CMVFFPCBDown( 2 )
          else if FP2Released then CMVFFPCBUp( 2 );
        end; // else // FP1 State did not changed

        if CurState <> PrevState then // Foot Pedal Device was used
          Exit; // Skip Camera Button Device processing
      end; // else //*** No Foot Pedal Device error, use it

    end; // if CMVFFootPedalDevInd <> N_FPCB_None then // Use Foot Pedal Device

    if CMVFCameraBtnDevInd <> N_FPCB_None then // Use Camera Button Device
    begin
      // Get Camera Button Current and Previous State in two least bits
      ResCode := N_FPCBObj.FPCBGetFPCBState( CMVFCameraBtnDevInd, CurState,
                                                                    PrevState );

      if (ResCode <> 0) or (CurState <> PrevState) then
        N_Dump2Str( Format(
                           'Camera Button States: Cur=%d, Prev=%d (ResCode=%d)',
                                                [CurState,PrevState,ResCode] ));

      if ResCode <> 0 then // Camera Button Device error
      begin
        CMVFCameraBtnDevInd := N_FPCB_None // do not Use Camera Button Device
      end else //*** No Camera Button Device error, use it
      begin
        // Decode CurState, PrevState ==> FP1Pressed, FP1Released, FP2Pressed, FP2Released
        N_CMDecodeFPCBStates ( CurState, PrevState,
                             FP1Pressed, FP1Released, FP2Pressed, FP2Released );

        if FP1Pressed then CMVFFPCBDown( 1 )
        else if FP1Released then CMVFFPCBUp( 1 )
        else // FP1 State did not changed, check FP2
        begin
          if FP2Pressed then CMVFFPCBDown( 2 )
          else if FP2Released then CMVFFPCBUp( 2 );
        end; // else // FP1 State did not changed

      end; // else //*** No Camera Button Device error, use it

    end; // if CMVFCameraBtnDevInd <> N_FPCB_None then // Use Camera Button Device


    if CMVFDentalUnitDevInd <> N_FPCB_None then // Use Dental Unit Device
    with N_FPCBObj do
    begin

      ResCode := FPCBGetDUState(); // one of N_DU_xxx constants:
	          // N_DU_NOTHING_TODO           = 0; // Nothing todo
	          // N_DU_SAVE_AND_UNFREEZE      = 1; // Save Picture and unfreeze video
	          // N_DU_FREEZE_UNFREEZE_TOGGLE = 2; // Toggle freeze/unfreeze mode
	          // N_DU_CAMERA_TAKEN           = 3; // Start using camera (Open VideoForm)
	          // N_DU_CAMERA_RETURNED        = 4; // Finish using camera (Close VideoForm)

      if ResCode <> N_DU_NOTHING_TODO then // some DU event occured
      begin
        N_Dump2Str( Format( 'Dental Unit event = %d', [ResCode ]));

        if ResCode = N_DU_CAMERA_RETURNED then // =4, Close Self
        begin
          if FPCBDUCloseMode = 0 then
            ModalResult := mrOK;
        end else if ResCode = N_DU_SAVE_AND_UNFREEZE then // =1
          if CMVFTwoClicksMode then // Two Clicks Mode
          begin
            if CMVFIsFreezed then
              CMVFSaveAndCont();
          end else //***************** Single Click Mode
          begin
            // nothing to do
          end
        else if ResCode = N_DU_FREEZE_UNFREEZE_TOGGLE then // =2
        begin
          if CMVFTwoClicksMode then // Two Clicks Mode
          begin
            if CMVFIsFreezed then
              CMVFSkipAndCont()
            else
              CMVFFreezeStream();
          end else //***************** Single Click Mode
          begin
            CMVFFreezeStream();
            CMVFSaveAndCont();
          end;
        end; // if ResCode = N_DU_FREEZE_UNFREEZE_TOGGLE then // =2

      end; // if ResCode <> 0 then // some event occured

    end; // if CMVFDentalUnitDevInd <> N_FPCB_None then // Use Dental Unit Device

  end; // with CMVFPProfile^ do // check Foot Pedal and Camera buttons state
end; // procedure TN_CMVideo2Form.ExtDLLTimerTimer


//****************  TN_CMVideo2Form class public methods  ************

//************************************* TN_CMVideo2Form.CMVFShowNumCaptured ***
// Update NumCaptLabel Caption - Show Number of Captured Still Images and Videos
//
procedure TN_CMVideo2Form.CMVFShowNumCaptured();
begin
  NumCaptLabel.Caption := Format( 'Stills: %d    Video: %d',
                                   [CMVFNumStills, CMVFNumVideos] );
end; // end of procedure TN_CMVideo2Form.CMVFShowNumCaptured

//********************************************* TN_CMVideo2Form.CMVFPrepare ***
// Fully Reconstruct Capturing Graph and prepare all Form Controls
//
//     Parameters
// APrepFlags - prepare Flags:
//  cmvfpfInitialCall - Initial call from CMResForm, Profile fields should be used
//  cmvfpfInitSizes   - cbCaptSize.Items should be created
//
procedure TN_CMVideo2Form.CMVFPrepare( APrepFlags: TN_CMVFPrepFlags );
var
  Str, NeededSizeStr, StringTemp: string;
  i: integer;
  Label ClearCMVFVideoCapt;
begin
  N_Dump2Str( 'TN_CMVideo3Form.CMVFPrepare before, CMDPStrPar2 = ' +
                                                     CMVFPProfile.CMDPStrPar2 );
  if Length(CMVFPProfile.CMDPStrPar2) < 8 then
  begin
    if Length(CMVFPProfile.CMDPStrPar2) = 7 then
    begin
      StringTemp := '0';
      StringTemp[1] := CMVFPProfile.CMDPStrPar2[5];
      CMVFPProfile.CMDPStrPar2[5] := CMVFPProfile.CMDPStrPar2[7];
      CMVFPProfile.CMDPStrPar2 := CMVFPProfile.CMDPStrPar2 + StringTemp[1];
      CMVFPProfile.CMDPStrPar2[8] := StringTemp[1];
      CMVFPProfile.CMDPStrPar2[7] := '0';
    end;
    // set initial parameters
    // CMDStrPar2 =
    // - Flip
    // - Capture Button usage
    // - Camera Button Threshold
    // - Still Pin usage
    // - Filter
    // - Renderer
    StringTemp := '00000100';

    if Length(CMVFPProfile.CMDPStrPar2) <> 8 then
      for i := Length(CMVFPProfile.CMDPStrPar2) + 1 to 8 do
        CMVFPProfile.CMDPStrPar2 := CMVFPProfile.CMDPStrPar2 + StringTemp[i];
  end;
  N_Dump2Str( 'TN_CMVideo3Form.CMVFPrepare after, CMDPStrPar2 = ' +
                                                     CMVFPProfile.CMDPStrPar2 );

  if cmvfpfInitialCall in APrepFlags then // Initial call from CMResForm, just add to Protocol
  begin
    if cbCaptMode.ItemIndex = 0 then // initialize "Still Images" mode
      N_Dump2Str( ' cbCaptMode : "Still Images"' )
    else //************************ initialize "Recording Video" mode
      N_Dump2Str( ' cbCaptMode : "Recording Video"' );

    NeededSizeStr := CMVFPProfile^.CMVResolution  // Profile Size should be used
  end else // call from cbCaptxxx.OnChange
  begin
    NeededSizeStr := cbCaptSize.Text; // try to use same Size
  end;

  with CMVFVideoCapt do
  begin
  //***** Common initial assignments for all modes

  CMVFNumSeconds := 0;
  CMVFPauseMode       := False;
  TimeLabel.Visible   := False;
  RecordTimer.Enabled := False;

  LeftPanelResize( nil ); // set Video Size and position

  //***** Common setting are OK, initialize controls for needed mode

  if cbCaptMode.ItemIndex = 0 then // initialize "Still Images" mode
  begin
    CMVFStillImages   := True;
    bnCapture.Visible := True;
    StillControlsPanel.Visible := True;
    VideoControlsPanel.Visible := False;
    CMVFHighlitedSlideInd := -1;
    CMVFFreezedSlideInd   := -1;

    CMVFClearPWins();
    CMVFLayoutPreviewWindows( 0 ); // hide all Preview Windows

    CMVFKey1IsDown := False;
    CMVFKey2IsDown := False;
    ExtDLLTimer.Enabled  := True;

//    CMVFFootPedalState := 0;
//    CMVFCameraBtnState := 0;

    rgOneTwoClicksClick( nil );
  end else //************************ initialize "Recording Video" mode
  begin
    CMVFStillImages   := False;
    bnCapture.Visible := False;
    bnRecord.Enabled  := True;
    bnStop.Enabled    := False;
    StillControlsPanel.Visible := False;
    VideoControlsPanel.Visible := True;

    ExtDLLTimer.Enabled  := False;

    CMVFLayoutPreviewWindows( 0 ); // hide all Preview Windows
  end; // else // initialize "Recording Video" mode

  //*** All Form Controls are OK

  //***** Prepare Interfaces

//  VideoPanel.Caption := 'Configuring Video ...'; // really not needed?
  VCOClearGraph(); // fully clear Graph
//  N_i := N_GetFileSize( VCOFileNames[0] ); // debug
//  N_i := N_GetFileSize( VCOFileNames[1] ); // debug

//  VCOVCaptDevName := cbCaptSource.Text; // Capturing Device Name
//  VCOVCaptDevName := edSourceName.Text; // Capturing Device Name
  VCOVCaptDevName := CMVFPProfile^.CMDPProductName; // Capturing Device Name
  VCOPrepInterfaces(); // VCO Interfaces are needed for VCOEnumVideoSizes and CMVFSetNewSize

  if VCOIError <> 0 then // something wrong
    goto ClearCMVFVideoCapt;

  //***** Interfaces are OK, fill cbCaptSize.Items if needed

  if cmvfpfInitSizes in APrepFlags then // fill cbCaptSize by all possible Sizes
  begin
    VCOEnumVideoSizes( cbCaptSize.Items );

    if VCOIError <> 0 then // something wrong
      goto ClearCMVFVideoCapt;
  end; // if cmvfpfInitSizes in APrepFlags then // fill cbCaptSize by all possible Sizes

  CMVFSetNewSize( NeededSizeStr ); // try to set needed Size

  if VCOIError <> 0 then // failed, use default (current) Size, get from device
    CMVFSetNewSize( '' );

  if VCOIError <> 0 then // something wrong
    goto ClearCMVFVideoCapt;


  //***** Interfaces and Video Size are OK, initialize needed mode

  if cbCaptMode.ItemIndex = 0 then // initialize "Still Images" mode
  begin
    VCOPrepGrabGraph();
  end else //************************ initialize "Recording Video" mode
  begin
    VCOPrepVideoFiles();
    VCOPrepRecordGraph();
  end;

  if VCOIError <> 0 then goto ClearCMVFVideoCapt; // something wrong

  CMVFPCurStatRecord := CMVFAddStatRecord( 'OK?' ); // add new Stat Record if needed
  N_Dump2Str( ' Capture Graph Prepared' );

  Exit; // All done OK

  ClearCMVFVideoCapt: //***** something wrong, clear all Objects
  CMVFPCurStatRecord := CMVFAddStatRecord( 'Failed1' ); // add new Stat Record if needed

//  Str := edSourceName.Text + ' is not plugged in or not working properly! (Error=' +
//                             IntToStr(CMVFVideoCapt.VCOIError) + ')';
  Str := CMVFPProfile^.CMDPProductName +
                         ' is not plugged in or not working properly! (Error=' +
                                        IntToStr(CMVFVideoCapt.VCOIError) + ')';
  VideoPanel.Caption := Str;
//!!  N_CMSLCAddError( Str );
  CMVFVideoCapt.VCOClearGraph();

  end; // with CMVFVideoCapt do

end; // end of procedure TN_CMVideo2Form.CMVFPrepare

//************************************* TN_CMVideo2Form.CMVFControlControls ***
// Control some controls (set Enable property by given AEnable value)
//
//     Parameters
// AEnable - given value to assign to some controls
//
// Is used for temporary disable controls while Recording or Freezing
//
procedure TN_CMVideo2Form.CMVFControlControls( AEnable: boolean );
begin
  cbCaptSize.Enabled       := AEnable;
  cbCaptMode.Enabled       := AEnable;
  bnCameraSettings.Enabled := AEnable;
  rgOneTwoClicks.Enabled   := AEnable;
end; // end of procedure TN_CMVideo2Form.CMVFControlControls

//****************************************** TN_CMVideo2Form.CMVFSetNewSize ***
// Set given Video Capturing Size for current VCOIVideoCaptFilter
//
//     Parameters
// ASizeStr - given new size as string (Width x Height)
//            or '' if current Device Size should be used
//
// Configure Video Capturing Device if needed, set proper cbCaptSize.ItemIndex
// and set proper VideoPanelSize
//
// VCOIStreamConfig Interface is used and should be already OK.
// cbCaptSize.Items should be already filled with proper Sizes.
//
procedure TN_CMVideo2Form.CMVFSetNewSize( ASizeStr: string );
var
  i, ind: integer;
  NewSizeStr: string;
  NewVideoSize: TPoint;
begin
  with CMVFVideoCapt do
  begin
    // should not be called while Graph is working with not empty size string
    // because of ... (SetFormat ...) (Portnoy note)
    VCOSetVideoSize( ASizeStr, NewVideoSize );
    //if NewVideoSize.X = -1 then
    //begin
    //  VCOSetVideoSize( '', NewVideoSize );
    //  Exit;
    //end;

    if VCOIError <> 0 then
    begin
      VCOIError := 0;
      VCOSetVideoSize( '', NewVideoSize );
      ASizeStr := Format( '%4d x %d', [NewVideoSize.X, NewVideoSize.Y] );
    end;

    NewSizeStr := ASizeStr;
    if NewSizeStr = '' then
      NewSizeStr := Format( '%4d x %d', [NewVideoSize.X, NewVideoSize.Y] );

    with cbCaptSize do // set cbCaptSize.ItemIndex by NewSizeStr
    begin
      ind := -1;
      NewSizeStr := Trim(NewSizeStr);

      for i := 0 to Items.Count-1 do
        if NewSizeStr = Trim(Items[i]) then // found
        begin
          ind := i;
          Break;
        end;

      ItemIndex := ind;
    end; // with cbCaptSize do // set cbCaptSize.ItemIndex by NewSizeStr

    CMVFSetVisibleVideoRect();

  end; // with CMVFVideoCapt do
end; // procedure TN_CMVideo2Form.CMVFSetNewSize

//********************************* TN_CMVideo2Form.CMVFSetVisibleVideoRect ***
// Set VCOCurWindowRect by current VideoPanel size and position
// and update Visible Video Rect in live video mode (if Graph is currently running)
//
procedure TN_CMVideo2Form.CMVFSetVisibleVideoRect();
begin
  if CMVFVideoCapt = nil then Exit; // not initialized yet

  with CMVFVideoCapt do
  begin
    with VideoPanel do // Video Panel coords should be already OK
      VCOCurWindowRect := Rect( 2, 2, Width-3, Height-3 );

    VCOGetGraphState();

    if VCOGraphState = State_Running then
    with VideoPanel do
    begin
//      VCOIVideoWindow.put_Left( 2 ); // not needed, because always the same
//      VCOIVideoWindow.put_Top( 2 );
      VCOIVideoWindow.put_Width( Width-3 );
      VCOIVideoWindow.put_Height( Height-3 );
    end;
  end; // with CMVFVideoCapt do
end; // end of TN_CMVideo2Form.CMVFSetVisibleVideoRect

//******************************************** TN_CMVideo2Form.CMVFDrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel and may be not equal to upper left Grid pixel )
//
// Is used as value of CMVFThumbsDGrid.DGDrawItemProcObj field
//
procedure TN_CMVideo2Form.CMVFDrawThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                           const ARect: TRect );
begin
  with N_CM_GlobObj do  begin
    CMStringsToDraw[0] := CMVFSSASlides[AInd].GetUName;

    CMVFDrawSlideObj.DrawOneThumb3( CMVFSSASlides[AInd],
                               CMStringsToDraw, CMVFThumbsDGrid, ARect, 0 );
  end; // with N_CM_GlobObj do
end; // end of TN_CMVideo2Form.CMVFDrawThumb

//***************************************** TN_CMVideo2Form.CMVFGetThumbSize ***
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
//  Is used as value of CMVFThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TN_CMVideo2Form.CMVFGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
        AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide : TN_UDCMSlide;
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin
  with N_CM_GlobObj, ADGObj do
  begin
    Slide := CMVFSSASlides[AInd];
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
end; // procedure TN_CMVideo2Form.CMVFGetThumbSize

//**************************************** TN_CMVideo2Form.CMVFSearchStatRecord ***
// Search for Video Statistics Variant
//
//     Parameters
// ACompName - Computer Namw
// AOpName   - Operation Name
// ADevName  - Device Name
// ACodec    - Codec Name
// ASize     - Image Size as String
// Result    - Return Pointer to needed Variant (RArray element) or nil
//
// Video Setting Variants Table is stored in N_CM_VideoStat UDRarray
//
function TN_CMVideo2Form.CMVFSearchStatRecord( ACompName, AOpName, ADevName,
                                 ACodec, ASize: string ): TN_PCMVideoStatRecord;
var
  i: integer;
begin
  for i := 0 to N_CM_VideoStat.AHigh() do // along all records
  begin
    Result := N_CM_VideoStat.PDE( i );

    if Trim(ASize) <> Result^.CMSRImageSize  then Continue;
    if ACodec      <> Result^.CMSRVideoCodec then Continue;
    if ADevName    <> Result^.CMSRDeviceName then Continue;
    if AOpName     <> Result^.CMSROperation  then Continue;
    if ACompName   <> Result^.CMSRCompName   then Continue;

    Exit; // Result points to nbeeded record
  end; // for i := 0 to N_CM_VideoStat.AHigh() do // along all records

  Result := nil;
end; // function TN_CMVideo2Form.CMVFSearchStatRecord

//******************************************* TN_CMVideo2Form.CMVFAddStatRecord ***
// Add Video Statistics Variant if needed
//
//     Parameters
// AIsWorkingField - content of CMSRIsWorking field is record was added
// Result          - Return Pointer to new added Variant (RArray element) or nil
//                   if such a record was already existed
//
// Search for Video Statistics Variant, defined TN_CMVideo2Form fields and
// if not found, add it to the end of table and return pointer to it. Otherwise
// (variant was found) return nil
//
// Video Setting Variants Table is stored in N_CM_VideoStat UDRarray
//
function TN_CMVideo2Form.CMVFAddStatRecord( AIsWorkingField: string ):
                                                          TN_PCMVideoStatRecord;
var
  FreeInd: integer;
  OpName: string;
begin
  Result := nil;
  if not (cmpfVideoStat in N_CM_LogFlags) then Exit; // Collecting Statistics is not needed

  if cbCaptMode.ItemIndex = 0 then OpName := 'Still'
                              else OpName := 'Video';

  with CMVFVideoCapt do
  begin
    if nil <> CMVFSearchStatRecord( N_CM_CompName, OpName, VCOVCaptDevName,
                                 VCOVComprFiltName, cbCaptSize.Text ) then Exit;

    //*** Current Video Settings Variant not in the Table yet, add it

    FreeInd := N_CM_VideoStat.ALength();
    N_CM_VideoStat.ASetLength( FreeInd+1 );

    Result := TN_PCMVideoStatRecord(N_CM_VideoStat.PDE( FreeInd ));
    with Result^ do
    begin
      CMSRCompName   := N_CM_CompName;
//      CMSRDeviceName := edSourceName.Text;
      CMSRDeviceName := CMVFPProfile^.CMDPProductName;
      CMSRImageSize  := cbCaptSize.Text;
      CMSROperation  := OpName;
      CMSRVideoCodec := VCOVComprFiltName;
      CMSRIsWorking  := AIsWorkingField;
      CMSRComments   := '';
      CMSRDateTime   := K_DateTimeToStr( SysUtils.Date() + Time() ); // Date is declared also in DirectShow9 unit

           if IsEqualGUID( VCOCurVideoCMST, MEDIASUBTYPE_RGB24 ) then
                                                        CMSRVideoCMST := 'RGB24'
      else if IsEqualGUID( VCOCurVideoCMST, MEDIASUBTYPE_I420  ) then
                                                         CMSRVideoCMST := 'I420'
      else if IsEqualGUID( VCOCurVideoCMST, MEDIASUBTYPE_YUY2  ) then
                                                         CMSRVideoCMST := 'YUY2'
      else CMSRVideoCMST := '???';

      N_Dump2Str( 'New Stat Record added:' );
      N_Dump2Str( CMSRCompName   + ', ' + CMSRDeviceName );
      N_Dump2Str( CMSRImageSize  + ', ' + CMSROperation + ', ' +
                                                                CMSRVideoCMST );
      N_Dump2Str( CMSRVideoCodec + ', ' + CMSRDateTime );
    end; // with Result do
  end; // with CMVFVideoCapt do
end; // function TN_CMVideo2Form.CMVFAddStatRecord

//************************************ TN_CMVideo2Form.CMVFSetIsWorkingField ***
// Set CMSRIsWorking of CMVFPCurStatRecord if it is not nil
//
//     Parameters
// AIsWorkingField - content of CMSRIsWorking field to set
//
procedure TN_CMVideo2Form.CMVFSetIsWorkingField( AIsWorkingField: string );
begin
  if CMVFPCurStatRecord = nil then Exit;

end; // end of TN_CMVideo2Form.CMVFSetIsWorkingField

//********************************** TN_CMVideo2Form.CMVFThumbsDGridProcObj ***
// Show Slide image with AInd index in appropriate PWin if not yet and if it is possible
//
//     Parameters
// ADGObj - TN_DGridBase object
// AInd   - Item one dimensional Index
//
// Used as CMVFThumbsDGrid.DGChangeItemStateProcObj
//
procedure TN_CMVideo2Form.CMVFThumbsDGridProcObj( ADGObj: TN_DGridBase;
                                                                AInd: integer );
var
  NeededSlideInd, PWinInd: integer;
begin
  if not CMVFIsFreezed then Exit; // Thumbs highlighting may be arbitrary changed in not Freezed mode
  if CMVFNumPWins = 1 then Exit;  // only one Freezed Slide is visible
  if cmsfIsMediaObj in CMVFSSASlides[AInd].P()^.CMSDB.SFlags then Exit; // Video, not an Image

  PWinInd := CMVFFindPWin( AInd ); // find PWin with AInd Slide

  if (PWinInd >= 0)           and // AInd was found
     (PWinInd < CMVFNumPWins) and // PWinInd is visible
     (CMVFHighlitedSlideInd = AInd) then Exit; // already highlighted, nothing todo

  if (PWinInd = -1) or (PWinInd >= CMVFNumPWins) then // AInd Slide is currently not visible
    NeededSlideInd := CMVFGetFreePWinInd() // where to show AInd Slide
  else
    NeededSlideInd := PWinInd; // where AInd Slide is already shown

  CMVFPreviewSInds[NeededSlideInd] := AInd;
  CMVFHighlitedSlideInd := AInd;
  CMVFUpdatePWinsContent();

end; // procedure procedure TN_CMVideo2Form.CMVFThumbsDGridProcObj

//**************************************** TN_CMVideo2Form.CMVFFreezeStream ***
// Freeze Video stream, always create Slide from Freezed Image
// and show Preview Windows with Freeze (just created) Slide
//
// Used only in Self.CMVFFPCBDown method
//
procedure TN_CMVideo2Form.CMVFFreezeStream();
var
  FreezedPWinInd: Integer;
  GrabbedSample: TN_DIBObj;
begin
  N_Dump2Str( 'Start Freeze' );

  with CMVFVideoCapt do
  begin
    CMVFControlControls( False ); // temporary disable ComboBoxes and DriverSettings Buttons
    GrabbedSample := VCOGrabSample(); // Grab Image from Video Stream

    if VCOIError <> 0 then
    begin
      K_CMShowMessageDlg( IntToStr(VCOIError) +
                  ' - Unexpected DirectShow Error9 - ' + VCOSError, mtWarning );
    end;

    VCOCoRes := VCOIMediaControl.Pause();
    if VCOCheckRes( 192 ) then
    begin
      K_CMShowMessageDlg( IntToStr(VCOIError) +  ' - Unexpected DirectShow Error10 - ' + VCOSError, mtWarning );
    end;
  end; // with CMVFVideoCapt do

  //***** Here: GrabbedSample is OK
  //      Create Slide from it (GrabbedSample will be owned by CMVFFreezedSlide)

  Assert( CMVFFreezedSlide = nil, 'CMVFFreezedSlide <> nil' );
  N_Dump2Str( 'Before CreateFromDIBObj' );
  CMVFFreezedSlide := K_CMSlideCreateFromDIBObj( GrabbedSample,
                                          @(CMVFPProfile^.CMAutoImgProcAttrs) );
  // now GrabbedSample is owned by CMVFFreezedSlide

  //*** ObjAliase is used for Showing in ThumbRFrame and in Properties/Diagnosis Form
  CMVFFreezedSlide.ObjAliase := 'Image ' + IntTostr(CMVFNumStills+1);

  with CMVFFreezedSlide.P()^ do
  begin
//    CMSSourceDescr := CMVFVideoCapt.VCOVCaptDevName;
    CMSSourceDescr := CMVFPProfile^.CMDPCaption;
    CMVFFreezedSlide.ObjInfo := 'Imported from ' + CMSSourceDescr;
    CMSMediaType := CMVFPProfile^.CMDPMTypeID;
  end; // with CMVFFreezedSlide.P()^ do

  N_Dump2Str( 'After CreateFromDIBObj' );

  //*** Add CMVFFreezedSlide to CMVFSSASlides array (as new last element)
  CMVFFreezedSlideInd := Length(CMVFSSASlides);
  SetLength( CMVFSSASlides, CMVFFreezedSlideInd + 1 );
  CMVFSSASlides[CMVFFreezedSlideInd] := CMVFFreezedSlide;

  //*** Show needed Preview Windows
  CMVFIsFreezed := True;
  CMVFLayoutPreviewWindows( CMVFNewPreviewMode );
  CMVFCurPreviewMode  := CMVFNewPreviewMode;
  CMVFLastPreviewMode := CMVFNewPreviewMode;
  FreezedPWinInd := CMVFGetFreePWinInd();
  CMVFPreviewSInds[FreezedPWinInd] := CMVFFreezedSlideInd; // just freezed image
  VideoPanel.Visible := False;
  CMVFUpdatePWinsContent();
  N_Dump2Str( 'Fin Freeze' );
end; // procedure procedure TN_CMVideo2Form.CMVFFreezeStream

//******************************************* TN_CMVideo2Form.CMVFRunStream ***
// Run Video stream after it was Freezed (return to live view mode)
//
// Used in several controls handlers (Capture button, Space key, Pedal or Camera button)
//
procedure TN_CMVideo2Form.CMVFRunStream();
var
  SError: string;
begin
  with CMVFVideoCapt do
  begin
    VCOCoRes := VCOIMediaControl.Run();
    if VCOCheckRes( 190 ) then
    begin
      SError := IntToStr(VCOIError) +  ' - Unexpected DirectShow Error5 - '
                                                                    + VCOSError;
      N_Dump1Str( SError );
      K_CMShowMessageDlg( SError, mtWarning );
    end;
  end; // with CMVFVideoCapt do

  CMVFLayoutPreviewWindows( 0 ); // hide all Preview Windows and show VideoPanel

  CMVFControlControls( True ); // enable ComboBoxes and DriverSettings Buttons
  CMVFIsFreezed := False;
  N_Dump2Str( 'Fin CMVFRunStream' );
end; // procedure procedure TN_CMVideo2Form.CMVFRunStream

//***************************************** TN_CMVideo2Form.CMVFSaveAndCont ***
// Save Freezed Slide and continue showing live video
//
// Used in several controls handlers (Capture button, Space key, Pedal or Camera button)
//
procedure TN_CMVideo2Form.CMVFSaveAndCont();
begin
  if not CMVFIsFreezed then Exit;

  //  if K_CMDEMOAddConstraint() = 0 then Exit; // temporary commented

  // Save CMVFFreezedSlide and add it to ThumbsRFrame

  Inc( CMVFNumStills );
  N_Dump2Str( Format( 'Start Saving Still Image %d', [CMVFNumStills] ));

  K_CMEDAccess.EDAAddSlide( CMVFFreezedSlide ); // from now on CMVFFreezedSlide is owned by K_CMEDAccess
  CMVFFreezedSlide := nil; // CMVFFreezedSlide.Free is an Error!

  Inc(CMVFThumbsDGrid.DGNumItems);
  CMVFThumbsDGrid.DGInitRFrame();

  CMVFShowNumCaptured();

  RecordTimer.Enabled := False;
  CMVFRunStream();

  CMVFThumbsDGrid.DGMarkSingleItem( CMVFFreezedSlideInd );
  CMVFHighlitedSlideInd := CMVFFreezedSlideInd;
  CMVFFreezedSlideInd := -1;
end; // procedure procedure TN_CMVideo2Form.CMVFSaveAndCont

//***************************************** TN_CMVideo2Form.CMVFSkipAndCont ***
// Skip (do not Save) Freezed Slide and continue showing live video
//
// Used in several controls handlers (Capture button, Space key, Pedal or Camera button)
//
procedure TN_CMVideo2Form.CMVFSkipAndCont();
var
  SError: string;
begin
  with CMVFVideoCapt do
  begin
    Assert( CMVFIsFreezed, 'CMVFIsFreezed is false!' );
    N_Dump2Str( 'Start CMVFSkipAndCont' );

    CMVFControlControls( True ); // Enable ComboBoxes and DriverSettings Buttons

    VCOCoRes := VCOIMediaControl.Run();
    if VCOCheckRes( 190 ) then
    begin
      SError := IntToStr(VCOIError) +  ' - Unexpected DirectShow Error5 - '
                                                                    + VCOSError;
      N_Dump1Str( SError );
      K_CMShowMessageDlg( SError, mtWarning );
    end;

  end; // with CMVFVideoCapt do

  CMVFDiscardFreezedSlide(); //*** clear all info about Freezed Slide
  RecordTimer.Enabled := False;
  CMVFRunStream();
end; // procedure procedure TN_CMVideo2Form.CMVFSkipAndCont

//******************************************** TN_CMVideo2Form.CMVFFPCBDown ***
// Process pressing Capture Button, Foot Pedal or Camera Button
//
//     Parameters
// AKey - Key (Pedal or Button) that was pressed down (now =1 or =2)
//
// Implemented busines logic:
//
// Key 1 pressed in Single Click mode - call CMVFFreezeStream
// Key 1 pressed first  time - Freeze Image
// Key 1 pressed second time - Start RecordTimer
//
// Key 2 pressed in Single Click mode - call CMVFFreezeStream (same as if FPCB 0 was pressed)
// Key 2 pressed in Two Clicks mode - if CMVFIsFreezed - call CMVFSkipAndCont, otherwise - nothing
//
//  used as Mouse, Key, Camera button or Foot Pedal Down handler
//
procedure TN_CMVideo2Form.CMVFFPCBDown ( AKey: integer );
begin
  Assert( (AKey = 1) or (AKey = 2), 'Bad AKey (CMVFFPCBDown)' ); // a precaution

  if AKey = 1 then // Key 1 was Pressed
  begin
    if CMVFKey1IsDown then Exit; // skip subsequent Down events (may be from different devices)
    CMVFKey1IsDown := True;

    if CMVFTwoClicksMode then // Two Clicks Mode
    begin
      if CMVFIsFirstClick then // Key 1 First Click in Two Clicks Mode, Freeze Stream
      begin
        N_Dump2Str( 'Key 1 First press' );
        CMVFFreezeStream();
      end else // Second Key 1 Click in Two Clicks Mode, start RecordTimer
      begin
        N_Dump2Str( 'Key 1 Second press' );
        CMVFNumSeconds := 0;
        RecordTimer.Enabled := True; // discarding or storing freezed image implemented in RecordTimerTimer handler
      end;
    end else //***************** Single Click Mode, Freeze Stream
    begin
      N_Dump2Str( 'Key 1 Single press' );
      CMVFFreezeStream();
    end;

  end else //************ Key 2 was Pressed
  begin
    if CMVFKey2IsDown then Exit; // skip subsequent Down events (may be from different devices)
    CMVFKey2IsDown := True;

    if CMVFTwoClicksMode then // Two Clicks Mode
    begin
      if CMVFIsFreezed then // Image was Freezed, discard it
      begin
        N_Dump2Str( 'Freezed Image Discarded by Key 2 press' );
        CMVFSkipAndCont();
        CMVFIsFirstClick := True;
      end else // currently in live mode
        Exit; // do nothing

    end else //***************** Single Click Mode, Freeze Stream
    begin
      N_Dump2Str( 'Key 2 Single press' );
      CMVFFreezeStream();
    end;

  end; // else //************ Key 2 was Pressed

end; // procedure TN_CMVideo2Form.CMVFFPCBDown

//********************************************** TN_CMVideo2Form.CMVFFPCBUp ***
// Process releasing Capture Button, Foot Pedal or Camera Button
//
//     Parameters
// AKey - Key (Pedal or Button) that was released (now =1 or =2)
//
// Implemented busines logic:
//
// Key 1 released in Single Click mode - call CMVFSaveAndCont
// Key 1 released first  time - do nothing
// Key 1 released second time - call CMVFSaveAndCont (it was released before end of delay)
//
// Key 2 released in Single Click mode - call CMVFSaveAndCont (same as if FPCB 0 was released)
// Key 2 released in Two Clicks mode - do nothing
//
// used as Mouse, Key, Camera button or Foot Pedal Up handler
//
procedure TN_CMVideo2Form.CMVFFPCBUp ( AKey: integer );
begin
  Assert( (AKey = 1) or (AKey = 2), 'Bad AKey (CMVFFPCBUp)' ); // a precaution

  if AKey = 1 then // Key 1 was Released
  begin
    if not CMVFKey1IsDown then Exit; // skip subsequent Up events (may be from different devices)
    CMVFKey1IsDown := False;

    if CMVFTwoClicksMode then // Two Clicks Mode
    begin
      if CMVFIsFirstClick then // First Click in Two Clicks Mode, do nothing
      begin
        N_Dump2Str( 'Key 1 First release' );
        CMVFIsFirstClick := False;
      end else // Second Click in Two Clicks Mode, Save Freezed Image and return to live video
      begin
        N_Dump2Str( 'Key 1 Second release' );
        CMVFSaveAndCont();
        CMVFIsFirstClick := True;
      end;
    end else //***************** Single Click Mode, Save Freezed Image and return to live video
    begin
      N_Dump2Str( 'Key 1 Single release' );
      CMVFSaveAndCont();
    end;

  end else //************ AKey = 2, Key 2 was Released
  begin
    if not CMVFKey2IsDown then Exit; // skip subsequent Up events (may be from different devices)
    CMVFKey2IsDown := False;

    if CMVFTwoClicksMode then // Two Clicks Mode
    begin
      Exit; // do nothing
    end else //***************** Single Click Mode, Save Freezed Image and return to live video
    begin
      N_Dump2Str( 'Key 2 Single release' );
      CMVFSaveAndCont();
    end;

  end; // else //************ Key 2 was Released

end; // procedure TN_CMVideo2Form.CMVFFPCBUp


//******************************************** TN_CMVideo2Form.CMVFFindPWin ***
// Find PWin Index by given ASlideInd (search in CMVFPreviewSInds array)
//
//     Parameters
// ASlideInd - given SlideIndex in CMVFSSASlides array
// Result    - Return Index of founded PWin or -1 is not found
//
// ASlideInd can be equal to -1 (for searchin free PWwin)
// Resulting PWin Index can be >= CMVFNumPWins!
//
function TN_CMVideo2Form.CMVFFindPWin( ASlideInd: integer ): integer;
var
  i: integer;
begin
  for i := 0 to High(CMVFPreviewSInds) do // along all PWins
  begin
    if CMVFPreviewSInds[i] = ASlideInd then // found
    begin
      Result := i;
      Exit;
    end;
  end; // for i := 0 to High(CMVFPreviewSInds) do // along all PWins

  Result := -1; // not found
end; // end of function TN_CMVideo2Form.CMVFFindPWin


//************************************** TN_CMVideo2Form.CMVFGetFreePWinInd ***
// Get first Free Preview Window Index (0-3)
//
function TN_CMVideo2Form.CMVFGetFreePWinInd(): integer;
var
  i: integer;
begin
  for i := 0 to CMVFNumPWins-1 do // try to find Free PWin
  begin
    if CMVFPreviewSInds[i] = -1 then // found
    begin
      Result := i;
      Exit;
    end;
  end; // for i := 0 to High(CMVFPreviewSInds) do // try to find Free PWin

  //***** No one Free PWin, check CMVFNumPWins-1

  if CMVFPreviewSInds[CMVFNumPWins-1] = CMVFFreezedSlideInd then // occupied by Freezed Image
    Result := CMVFNumPWins - 2 // use previous one
  else // return last visible PWin Index
    Result := CMVFNumPWins - 1;

  Assert( Result >= 0, 'GetFreePWinInd Error' ); // just a precaution
end; // end of function TN_CMVideo2Form.CMVFGetFreePWinInd


//******************************** TN_CMVideo2Form.CMVFLayoutPreviewWindows ***
// Set Preview Vindows coords for given Preview Mode (0 means hiding all of them)
// all other variables except CMVFNumPWins remains the same
//
//     Parameters
// APreviewMode - given Preview Mode (0-4)
//
procedure TN_CMVideo2Form.CMVFLayoutPreviewWindows( APreviewMode: integer );
var
  WinSize: TPoint;
begin
  WinSize.X := LeftPanel.Width  div 2;
  WinSize.Y := LeftPanel.Height div 2;

  case APreviewMode of

  0: begin // hide all PWins and show VideoPanel
       SlidePanel1.Visible := False;
       SlidePanel2.Visible := False;
       SlidePanel3.Visible := False;
       SlidePanel4.Visible := False;

       VideoPanel.Visible := True;
     end; // 0: begin // hide all windows

  1: begin // One Preview Window
       SlidePanel1.Visible := True;
       SlidePanel1.Left   := 0;
       SlidePanel1.Top    := 0;
       SlidePanel1.Width  := LeftPanel.Width;
       SlidePanel1.Height := LeftPanel.Height;
       RFrame1.RedrawAllAndShow();

       SlidePanel2.Visible := False;
       SlidePanel3.Visible := False;
       SlidePanel4.Visible := False;
       CMVFNumPWins := 1;
     end; // 1: begin // One Preview Window

  2: begin // Two Preview Vertical Windows (one over another, Splitter is horizontal)
       SlidePanel1.Visible := True;
       SlidePanel1.Left   := 0;
       SlidePanel1.Top    := 0;
       SlidePanel1.Width  := LeftPanel.Width;
       SlidePanel1.Height := WinSize.Y;
       RFrame1.RedrawAllAndShow();

       SlidePanel2.Visible := True;
       SlidePanel2.Left   := 0;
       SlidePanel2.Top    := WinSize.Y;
       SlidePanel2.Width  := LeftPanel.Width;
       SlidePanel2.Height := LeftPanel.Height - WinSize.Y;
       RFrame2.RedrawAllAndShow();

       SlidePanel3.Visible := False;
       SlidePanel4.Visible := False;
       CMVFNumPWins := 2;
     end; // 2: begin // Two Preview Vertical Windows (one over another, Splitter is horizontal)

  3: begin // Two Preview Horizontal Windows (Splitter is Vertical)
       SlidePanel1.Visible := True;
       SlidePanel1.Left   := 0;
       SlidePanel1.Top    := 0;
       SlidePanel1.Width  := WinSize.X;
       SlidePanel1.Height := LeftPanel.Height;
       RFrame1.RedrawAllAndShow();

       SlidePanel2.Visible := True;
       SlidePanel2.Left   := WinSize.X;
       SlidePanel2.Top    := 0;
       SlidePanel2.Width  := LeftPanel.Width - WinSize.X;
       SlidePanel2.Height := LeftPanel.Height;
       RFrame2.RedrawAllAndShow();

       SlidePanel3.Visible := False;
       SlidePanel4.Visible := False;
       CMVFNumPWins := 2;
     end; // 3: begin // Two Preview Horizontal Windows (Splitter is Vertical)

  4: begin // Four Preview Windows
       SlidePanel1.Visible := True;
       SlidePanel1.Left   := 0;
       SlidePanel1.Top    := 0;
       SlidePanel1.Width  := WinSize.X;
       SlidePanel1.Height := WinSize.Y;
       RFrame1.RedrawAllAndShow();

       SlidePanel2.Visible := True;
       SlidePanel2.Left   := WinSize.X;
       SlidePanel2.Top    := 0;
       SlidePanel2.Width  := LeftPanel.Width - WinSize.X;
       SlidePanel2.Height := WinSize.Y;
       RFrame2.RedrawAllAndShow();

       SlidePanel3.Visible := True;
       SlidePanel3.Left   := 0;
       SlidePanel3.Top    := WinSize.Y;
       SlidePanel3.Width  := WinSize.X;
       SlidePanel3.Height := LeftPanel.Height - WinSize.Y;
       RFrame3.RedrawAllAndShow();

       SlidePanel4.Visible := True;
       SlidePanel4.Left   := WinSize.X;
       SlidePanel4.Top    := WinSize.Y;
       SlidePanel4.Width  := LeftPanel.Width  - WinSize.X;
       SlidePanel4.Height := LeftPanel.Height - WinSize.Y;
       RFrame4.RedrawAllAndShow();

       CMVFNumPWins := 4;
     end; // 4: begin // Four Preview Windows
  end; // case APreviewMode of

end; // procedure TN_CMVideo2Form.CMVFLayoutPreviewWindows

//********************************* TN_CMVideo2Form.CMVFDiscardFreezedSlide ***
// Clear all info about Freezed Slide and free it
//
// Used in CMVFSkipAndCont and in OnClose handler
//
procedure TN_CMVideo2Form.CMVFDiscardFreezedSlide();
var
  i: integer;
  FreezedRootComp: TN_UDCompVis;
begin
  Assert( CMVFSSASlides[CMVFFreezedSlideInd] = CMVFFreezedSlide,
                     'CMVFSSASlides[CMVFFreezedSlideInd] <> CMVFFreezedSlide' );

  //*** Clear reference to Freezed Slide from all CMVFPreviewSInds array elements
  for i := 0 to High(CMVFPreviewSInds) do // along all Preview Windows
  begin
    if CMVFPreviewSInds[i] = CMVFFreezedSlideInd then
    begin
      CMVFPreviewSInds[i] := -1;
      Break;
    end;
  end; // for i := 0 to High(CMVFPreviewSInds) do // along all Preview Windows

  //*** Clear reference to Freezed Slide MapRoot from all RFrames
  FreezedRootComp := CMVFFreezedSlide.GetMapRoot();
  if RFrame1.RVCTreeRoot = FreezedRootComp then RFrame1.RVCTreeRoot := nil;
  if RFrame2.RVCTreeRoot = FreezedRootComp then RFrame2.RVCTreeRoot := nil;
  if RFrame3.RVCTreeRoot = FreezedRootComp then RFrame3.RVCTreeRoot := nil;
  if RFrame4.RVCTreeRoot = FreezedRootComp then RFrame4.RVCTreeRoot := nil;

  for i := 0 to High(CMVFPreviewSInds) do // along all Preview Windows
  begin
    if CMVFPreviewSInds[i] = CMVFFreezedSlideInd then
    begin
      CMVFPreviewSInds[i] := -1;
      Break;
    end;
  end; // for i := 0 to High(CMVFPreviewSInds) do // along all Preview Windows

  SetLength( CMVFSSASlides, CMVFFreezedSlideInd ); // clear ref from CMVFSSASlides (decrease Size by 1)
  FreeAndNil( CMVFFreezedSlide ); // clear Freezed Slide itself
  CMVFFreezedSlideInd := -1;
end; // procedure TN_CMVideo2Form.CMVFDiscardFreezedSlide

//********************************** TN_CMVideo2Form.CMVFUpdatePWinsContent ***
// Update (if needed) currently visible Preview Windows content
// (Update RootComp (with Redrawing if needed) and Panel (Image Border) color)
//
procedure TN_CMVideo2Form.CMVFUpdatePWinsContent();

  procedure UpdateOne( APWinInd: integer; APanel: TPanel;
                                                       ARFrame: TN_Rast1Frame );
  // Update one given PWin
  //   APWinInd - Preview Window Index
  //   APanel   - TPanel (content of Preview Window with APWinInd index)
  //   ARFrame  - RFrame on APanel
  var
    SlideInd: integer;
    RootComp: TN_UDCompVis;
  begin
    SlideInd := CMVFPreviewSInds[APWinInd]; // Slide index in CMVFSSASlides array

    //*** Set APanel.Color - Image Border color
    if SlideInd = -1 then
      APanel.Color := ColorToRGB( clBtnFace )
    else if SlideInd = CMVFHighlitedSlideInd then
      APanel.Color := N_CM_SlideMarkColor
    else if SlideInd = CMVFFreezedSlideInd then
      APanel.Color := CMVFFreezedColor // Yellow
    else
      APanel.Color := ColorToRGB( clBtnFace );

    //*** Set RootComp local var
    RootComp := nil;
    if SlideInd <> -1 then // In APWinInd Preview Window new Slide should be drawn
    with CMVFSSASlides[SlideInd] do
    begin
      if not (cmsfIsMediaObj in P()^.CMSDB.SFlags) then // not Video file
        RootComp := GetMapRoot();
    end; // if SlideInd <> -1 then // In APWinInd Preview Window new Slide should be drawn

    if ARFrame.RVCTreeRoot <> RootComp then // Redrawing in ARFrame is needed
      ARFrame.RFrShowComp( RootComp ); // RootComp is CMVFSSASlides[SlideInd] Slide
  end; // procedure UpdateOne - local

begin //********************************** main body of CMVFUpdatePWinsContent
  UpdateOne( 0, SlidePanel1, RFrame1 );
  UpdateOne( 1, SlidePanel2, RFrame2 );
  UpdateOne( 2, SlidePanel3, RFrame3 );
  UpdateOne( 3, SlidePanel4, RFrame4 );
end; // end of procedure TN_CMVideo2Form.CMVFUpdatePWinsContent

//****************************************** TN_CMVideo2Form.CMVFClearPWins ***
// Clear CMVFPreviewSInds array (fill by -1 values)
//
procedure TN_CMVideo2Form.CMVFClearPWins();
var
  i: integer;
begin
  for i := 0 to High(CMVFPreviewSInds) do
  begin
    CMVFUnHighlightPWin( i );
    CMVFPreviewSInds[i] := -1;
  end;
end; // end of procedure TN_CMVideo2Form.CMVFClearPWins

//************************************* TN_CMVideo2Form.CMVFUnHighlightPWin ***
// UnHighlight given PWin if it is currently highlighted
//
//     Parameters
// APWinIndex - Index of Preview Window to Highlight
//
procedure TN_CMVideo2Form.CMVFUnHighlightPWin( APWinIndex: integer );
begin
  if CMVFHighlitedSlideInd = -1 then Exit; // nothing todo

  if CMVFPreviewSInds[APWinIndex] = CMVFHighlitedSlideInd then // is highlighted
  begin
    // later add UnHighlighting Thumbnails!!!

    CMVFHighlitedSlideInd := -1;
  end; // if CMVFPreviewSInds[APWinIndex] = CMVFHighlitedSlideInd >= 0 then // is highlighted
end; // end of procedure TN_CMVideo2Form.CMVFUnHighlightPWin

//************************************* TN_CMVideo2Form.CMVFCalcVideoAspect ***
// Calculate Video Aspect and save it to CMVFCurVideoAspect by given string sizes
//
//     Parameters
// AStrSize - given string sizes (it is of '%4d x %d' format)
//
procedure TN_CMVideo2Form.CMVFCalcVideoAspect( AStrSize: string );
var
  nx, ny: integer;
  Str: string;
begin
  Str := AStrSize;
  nx := N_ScanInteger( Str );
  N_ScanToken( Str );
  ny := N_ScanInteger( Str );

  if (nx = 0) or (nx = N_NotAnInteger) then
    CMVFCurVideoAspect := 0.75
  else
    CMVFCurVideoAspect := 1.0 * ny / nx;
end; // end of procedure TN_CMVideo2Form.CMVFCalcVideoAspect

//****************************************** TN_CMVideo2Form.V2FAddCurState ***
// Add to given strings current state params
//
//     Parameters
// AStrings - given strings
// AIndent  - number of spaces to add before all strings
//
procedure TN_CMVideo2Form.V2FAddCurState( AStrings: TStrings;
                                                             AIndent: integer );
var
  i: integer;
  Prefix: string;

  procedure LAdd( AStr: string ); // local, to reduce code size
  begin
    AStrings.Add( Prefix + AStr );
  end; // procedure LAdd( AStr: string ); // local

begin
  Prefix := DupeString( ' ', AIndent+2 );
  with AStrings do
  begin
    Add( '' );
    LAdd( '***** TN_CMVideo2Form info:' );
    LAdd( 'CMVFRecordedFName=' + CMVFRecordedFName + '  Size='
                                                            + cbCaptSize.Text );
    LAdd( Format(
  'Still=%s, Record=%s, 2Cliks=%s, IsFirstC=%s, IsFreezed=%s, Keys12Down=%s %s',
   [N_B2Str(CMVFStillImages),N_B2Str(CMVFRecordMode),N_B2Str(CMVFTwoClicksMode),
       N_B2Str(CMVFIsFirstClick),N_B2Str(CMVFIsFreezed),N_B2Str(CMVFKey1IsDown),
                                                    N_B2Str(CMVFKey2IsDown)] ));

    LAdd( Format( 'NumSec=%f, NumStills=%d, NumVideos=%d, FileNumber=%d',
                  [CMVFNumSeconds,CMVFNumStills,CMVFNumVideos,CMVFileNumber] ));

    LAdd( Format( 'PrevMode: New=%d, Cur=%d, Last=%d',
                 [CMVFNewPreviewMode,CMVFCurPreviewMode,CMVFLastPreviewMode] ));

    LAdd( Format( 'NumPWins=%d, PrSInds=%d,%d%d%d, FrSI=%d, HSI=%d',
      [CMVFNumPWins,CMVFPreviewSInds[0],CMVFPreviewSInds[1],CMVFPreviewSInds[2],
              CMVFPreviewSInds[3],CMVFFreezedSlideInd,CMVFHighlitedSlideInd] ));

    with N_FPCBObj do
      LAdd( Format( 'Foot Pedal: %d (%s), Camera Button: %d (%s)',
                 [CMVFFootPedalDevInd,FPCBDevices[CMVFFootPedalDevInd].FPCBName,
              CMVFCameraBtnDevInd,FPCBDevices[CMVFCameraBtnDevInd].FPCBName] ));

    if CMVFFreezedSlide <> nil then
    begin
      LAdd( '   FreezedSlide:' );
      CMVFFreezedSlide.CMSlideAddCurState( AStrings, AIndent+2 );
    end;

    LAdd( '   RFrames:' );
    RFrame1.RFAddCurState( AStrings, AIndent+2 );
    RFrame2.RFAddCurState( AStrings, AIndent+2 );
    RFrame3.RFAddCurState( AStrings, AIndent+2 );
    RFrame4.RFAddCurState( AStrings, AIndent+2 );
    LAdd( '' );

    LAdd( '   CMVFSSASlides:' );
    for i := 0 to High(CMVFSSASlides) do
      CMVFSSASlides[i].CMSlideAddCurState( AStrings, AIndent+2 );

    Add( Prefix + '***** End of TN_CMVideo2Form info' );
//    RFrame.RFAddCurState( AStrings, AIndent+2 );
  end; // with AStrings do
end; // procedure TN_CMVideo2Form.V2FAddCurState

//**************************************** TN_CMVideo2Form.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_CMVideo2Form.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_CMVideo2Form.CurStateToMemIni

//**************************************** TN_CMVideo2Form.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_CMVideo2Form.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_CMVideo2Form.MemIniToCurState


    //*********** Global Procedures  *****************************

//**************************************************** N_CreateCMVideo2Form ***
// Create and return new instance of TN_CMVideo2Form
//
//     Parameters
// AOwner        - Owner of created Form
// ACMVFProfile  - Pointer to VideoProfile
// Result        - Return created Form
//
function N_CreateCMVideo2Form( AOwner: TN_BaseForm;
                               APProfile: TK_PCMVideoProfile ): TN_CMVideo2Form;
var
  i, InitVideoFileSize, SavedOldInd, ResCode: integer;
  DevName, Str: string;
  WrkVideoFName: string;

  procedure PrepRFrame( ARFrame: TN_Rast1Frame; ARFrName: string ); // local
  begin
    with ARFrame do
    begin
      RFDebName      := ARFrName;
//      DstBackColor   := ColorToRGB( clBtnFace );
//      OCanvBackColor := ColorToRGB( clBtnFace );
      RFCenterInDst  := True;

      RFrShowComp( nil );
    end;
  end; // procedure PrepRFrame - local

begin
  N_CMVideo2Form := TN_CMVideo2Form.Create( Application );
  Result := N_CMVideo2Form;

  with N_CMVideo2Form do
  begin
//    BaseFormInit( AOwner );
    BaseFormInit( AOwner, '', [rspfMFRect,rspfCenter],
                                                    [rspfAppWAR,rspfShiftAll] );
//    CurArchiveChanged();

//    CMVFSPCPUCounter := N_CPUCounter(); // save start time

    ThumbsRFrame.RFDebName := 'V2FThumbs';

    for i := 0 to High(CMVFPreviewSInds) do
      CMVFPreviewSInds[i] := -1;

    PrepRFrame( RFrame1, 'V2FFr1' );
    PrepRFrame( RFrame2, 'V2FFr2' );
    PrepRFrame( RFrame3, 'V2FFr3' );
    PrepRFrame( RFrame4, 'V2FFr4' );

    //*** Initial settings given by APProfile^
    CMVFPProfile := APProfile;

    with CMVFPProfile^ do // Initialize Controls
    begin
      DevName             := CMDPProductName;
      CMVFLastPreviewMode := 0;
      cbCaptMode.ItemIndex     := 0;// integer(CMVCMode);
      rgOneTwoClicks.ItemIndex := CMNumClicksInd;
      CMVFCurPreviewMode := 4;
      if (CMPreviewMode >= 1) and (CMPreviewMode <=4) then // a precaution
        CMVFCurPreviewMode  := CMPreviewMode;
    end; // with CMVFPProfile^ do // Initialize Controls

    case CMVFCurPreviewMode of // Set needed button Down
      1: tbnPM1.Down := True;
      2: tbnPM2.Down := True;
      3: tbnPM3.Down := True;
      4: tbnPM4.Down := True;
    end; // case CMVFCurPreviewMode of
    CMVFNewPreviewMode := CMVFCurPreviewMode;

    Caption := CMVFPProfile^.CMDPCaption;
    N_DSEnumVideoSizes( DevName, cbCaptSize.Items );

    PleaseWaitLabel.Visible := False;
    CMVFFreezedColor := $00FFFF;
    CMVFFreezedSlide := nil;

    // WrkVideoFName is File Name Pattern, two real names will be creted in TN_VideoCaptObj.Create3
    WrkVideoFName := K_ExpandFileName( '(#WrkFiles#)LastFilm.avi' );
    K_ForceDirPathDlg( ExtractFilePath(WrkVideoFName) );
    InitVideoFileSize := Round(1024*1024*N_MemIniToDbl( 'CMS_Main',
                                                     'InitVideoFileSize', 10 ));

    CMVFVideoCapt := TN_VideoCaptObj.Create3( VideoPanel.Handle, Rect(0,0,1,1),
                                             WrkVideoFName, InitVideoFileSize );
    with CMVFVideoCapt do // set VCONeededVideoCMST
    begin
      VCOCaptPin := N_MemIniToInt( 'CMSUserDeb', 'CaptPin', 2 );

      VCOVComprSectionName := N_CMSVideoComprSectName;
      Str := UpperCase(N_MemIniToString( 'CMS_Main', 'NeededVideoCMST', '' ));

           if Str = 'RGB24' then VCONeededVideoCMST := MEDIASUBTYPE_RGB24
      else if Str = 'I420'  then VCONeededVideoCMST := MEDIASUBTYPE_I420
      else if Str = 'YUY2'  then VCONeededVideoCMST := MEDIASUBTYPE_YUY2
      else VCONeededVideoCMST := NilGUID;
    end; // with CMVFVideoCapt do // set VCONeededVideoCMST


    //***** Load Foot Pedal Device DLL if needed

    CMVFFootPedalDevInd := N_MemIniToInt( 'CMS_Main', 'FootPedalDevInd', -1 );

    if CMVFFootPedalDevInd = -1 then // check if old ComboBox (not Device) index was saved
    begin                   // (for compatability with 2.790 and earlier CMS Builds)
      SavedOldInd := N_MemIniToInt( 'CMS_Main', 'FootPedalIndex', 0 );

      if SavedOldInd = 1 then CMVFFootPedalDevInd := N_FPCB_Delcom
                         else CMVFFootPedalDevInd := N_FPCB_None;
    end; // if CMVFFootPedalDevInd = -1 then // check if old ComboBox (not Device) index was saved

    ResCode := N_FPCBObj.FPCBLoadDLL( CMVFFootPedalDevInd ); // Load DLL and Initialize Device
    if ResCode <> 0 then // Loading or Initializing error
      CMVFFootPedalDevInd := N_FPCB_None; // do not use Foot Pedal Device

    if CMVFFootPedalDevInd <> N_FPCB_None then
      with N_FPCBObj.FPCBDevices[CMVFFootPedalDevInd] do
        N_Dump1Str( Format( 'Foot Pedal "%s" initialized OK', [FPCBName] ));


    //***** Load Camera Button Device DLL if needed

    CMVFCameraBtnDevInd := N_CMConvCBToFPCBInd( CMVFPProfile^.CMCaptButDLLInd );

    ResCode := N_FPCBObj.FPCBLoadDLL( CMVFCameraBtnDevInd ); // Load DLL and Initialize Device
    if ResCode <> 0 then // Loading or Initializing error
      CMVFCameraBtnDevInd := N_FPCB_None; // do not use Camera Button Device

    if CMVFCameraBtnDevInd <> N_FPCB_None then
      with N_FPCBObj.FPCBDevices[CMVFCameraBtnDevInd] do
      begin
        FPCBWideDriverName := WideString( DevName ); // needed for some devices
        N_Dump1Str( Format( 'Camera Button %s initialized OK', [FPCBName] ));
      end;

    // ***** Prepare for using Dental Unit if needed (it should be alrerady initialized)

    with N_FPCBObj do
    begin
      if FPCBDUProfName = CMVFPProfile^.CMDPCaption then
        CMVFDentalUnitDevInd := FPCBDUInd; // may be N_FPCB_None if Dental Unit should not be used

      if FPCBDUActivateMode = 1 then
        FPCBSironaActivateCamera( 1 );
    end; // with N_FPCBObj do

  end; // with Result do

  N_Dump1Str( 'End of N_CreateCMVideo2Form' );
end; // function N_CreateCMVideo2Form

end.
