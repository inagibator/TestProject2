unit K_FCMMain5F;
// Main CMS application Form
// Delphi can not set this Form height less than 587 !!!

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, Menus, ToolWin, ActnList, Buttons, StdCtrls, ImgList,
  K_Types, K_UDT1,  K_FrCMSlideFilter,   K_CM0,
  N_Types, N_Lib1,  N_BaseF, {N_MainFFr,}  N_Gra2,
  N_CM1,   N_CM2,   N_DGrid, N_CMREd3Fr, N_Rast1Fr, System.Actions{,
  L_VirtUI},
  ViewerTabSheet;
{
  IdMessage, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTP, IdSSLOpenSSL,IdSocks;
}

type TN_RebuildViewFlags = set of ( rvfSkipThumbRebuild, rvfAllViewRebuild );
type TN_EdFrLayout = ( eflNotDef, eflOne, eflTwoHSp, eflTwoVSp,
                       eflFourHSp, eflFourVSp, eflNine );
var  N_EdFrLayoutCounts : array [0..Ord(eflNine)] of Integer = (0, 1, 2, 2, 4, 4, 9);

type TK_FormCMMain5 = class( TN_BaseForm ) //***** Main CMS application Form
    MainMenu1: TMainMenu;
    GoTo1: TMenuItem;
    View1: TMenuItem;
    Capture1: TMenuItem;
    Tools1: TMenuItem;
    Media1: TMenuItem;
    StatusBar: TStatusBar;
    Left1Panel: TPanel;
    Print1: TMenuItem;
    PropertiesDiagnoses1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Debug1: TMenuItem;
    Preferences1: TMenuItem;
    OneSquare1: TMenuItem;
    woHorizontal1: TMenuItem;
    woVertical1: TMenuItem;
    FourSquares1: TMenuItem;
    NineSquares1: TMenuItem;
    N3: TMenuItem;
    ZoomInandZoomOut1: TMenuItem;
    FullScreen1: TMenuItem;
    FittoWindow1: TMenuItem;
    N5: TMenuItem;
    DeviceSetup1: TMenuItem;
    RotateLeft1: TMenuItem;
    RotateRight1: TMenuItem;
    Rotateby1801: TMenuItem;
    N6: TMenuItem;
    FlipHorizontally1: TMenuItem;
    FlipVertically1: TMenuItem;
    N7: TMenuItem;
    BrightnessGammaContrast1: TMenuItem;
    Import1: TMenuItem;
    Export1: TMenuItem;
    N8: TMenuItem;
    Open1: TMenuItem;
    N9: TMenuItem;
    Email1: TMenuItem;
    ShowNVTreeForm1: TMenuItem;
    OtherOptions1: TMenuItem;
    CreateDistributive1: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    DebAction11: TMenuItem;
    DebAction21: TMenuItem;
    Right1Panel: TPanel;
    ToolBar1: TToolBar;
    ToolButton27: TToolButton;
    ToolButton28: TToolButton;
    ToolButton29: TToolButton;
    ToolButton30: TToolButton;
    ToolButton31: TToolButton;
    ToolButton32: TToolButton;
    ToolButton33: TToolButton;
    Bot2Panel: TPanel;
    ThumbsSplitter: TSplitter;
    ThumbsRFrame: TN_Rast1Frame;
    EdFramesPanel: TPanel;
    Top2Panel: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    MediaToolBar: TToolBar;
    ToolButton34: TToolButton;
    ToolButton35: TToolButton;
    ToolButton36: TToolButton;
    ToolButton37: TToolButton;
    ToolButton38: TToolButton;
    ToolButton39: TToolButton;
    GFiltersToolBar: TToolBar;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    ToolButton23: TToolButton;
    ToolButton24: TToolButton;
    ToolButton25: TToolButton;
    ToolButton26: TToolButton;
    Panel1: TPanel;
    SysToolBar3: TToolBar;
    FlashlightToolButton: TToolButton;
    ToolButton7: TToolButton;
    CaptToolBar: TToolBar;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton6: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;

    ChangeCurrentDBPatientProviderLocationContext1: TMenuItem;
    ToolButton18: TToolButton;
    AllTopToolbars2: TMenuItem;
    AlterationsToolbar1: TMenuItem;
    Noise1: TMenuItem;
    SharpenSmoothen1: TMenuItem;
    Emboss1: TMenuItem;
    N4: TMenuItem;
    Colorize1: TMenuItem;
    Isodensity1: TMenuItem;
    N18: TMenuItem;
    N15: TMenuItem;
    N1: TMenuItem;
    miAnnotations: TMenuItem;
    CreateMultiLine1: TMenuItem;
    CreateText1: TMenuItem;
    N10: TMenuItem;
    ShowDrawings1: TMenuItem;
    DeleteAnnotationsMeasure1: TMenuItem;
    ChangeDrawingattributes1: TMenuItem;
    N11: TMenuItem;
    CreateMultiLineMeasure1: TMenuItem;
    CreateAngle1: TMenuItem;
    CreateFreeAngle1: TMenuItem;
    CalibrateImage1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Contents1: TMenuItem;
    Edit1: TMenuItem;
    UndoRedo1: TMenuItem;
    RedoLastAction1: TMenuItem;
    UndoLastAction1: TMenuItem;
    RestoreOriginal1: TMenuItem;
    N16: TMenuItem;
    SelectAll1: TMenuItem;
    N17: TMenuItem;
    DeletesSlected1: TMenuItem;
    Dummy1: TMenuItem;
    BrightnessContrastGamma1: TMenuItem;
    ToolButtonIsodens: TToolButton;
    ToolButtonEmboss: TToolButton;
    ToolButtonColorize: TToolButton;
    Rectangle1: TMenuItem;
    Ellipse1: TMenuItem;
    Arrow1: TMenuItem;
    EmbossAttributes1: TMenuItem;
    Service: TMenuItem;
    ViewEditProtocol2: TMenuItem;
    ViewEditServiceFlags2: TMenuItem;
    ViewEditStatisticsTable2: TMenuItem;
    SetVideoCodec2: TMenuItem;
    Duplicate1: TMenuItem;
    ImportfromClipboard1: TMenuItem;
    N12: TMenuItem;
    ExportmediatoClipboard1: TMenuItem;
    FreeHand1: TMenuItem;
    N19: TMenuItem;
    Flashlight1: TMenuItem;
    Rotatebyangle1: TMenuItem;
    CropImage1: TMenuItem;
    AutoEqualizeImage1: TMenuItem;
    Registration1: TMenuItem;
    FootPedalSetup2: TMenuItem;
    Refresh1: TMenuItem;
    CreateBMPfromgivenfile1: TMenuItem;
    ArchiveOpen2: TMenuItem;
    OtherOptions2: TMenuItem;
    N21: TMenuItem;
    ArchiveSaveAs1: TMenuItem;
    ShowPlatformInfo1: TMenuItem;
    N22: TMenuItem;
    SetPatientProviderLocationInfo1: TMenuItem;
    ClearAllSlidesinArchiveinitArchive1: TMenuItem;
    ClearLockedSlidesfromDB1: TMenuItem;
    AbortCMSbyexception1: TMenuItem;
    CheckFileinDebugger1: TMenuItem;
    N23: TMenuItem;
    CreateClonesfromgivenFile1: TMenuItem;
    SearchProjectFormschangedbyDelphi20101: TMenuItem;
    DICOMTest1: TMenuItem;
    TestEd3FrameinSeparateWindow1: TMenuItem;
    SynchronizeDPRFilesUses1: TMenuItem;
    Debug2: TMenuItem;
    CreateDemoEXEDistributivefromrunningCMSuitDemoexe1: TMenuItem;
    N24: TMenuItem;
    ArchiveNew1: TMenuItem;
    Changeaccountdetails1: TMenuItem;
    FilesSynchronizationDetails1: TMenuItem;
    N25: TMenuItem;
    N26: TMenuItem;
    DebMPAction11: TMenuItem;
    DebMPAction12: TMenuItem;
    Reports1: TMenuItem;
    DisplayDeleted1: TMenuItem;
    RestoreMarkedAsDeleted1: TMenuItem;
    Deletedobjectshandling2: TMenuItem;
    MainActions: TActionList;
    aServDisableActions: TAction;
    aOpenMainForm6: TAction;
    aOpenMainForm61: TMenuItem;
    aShowNewGUI: TMenuItem;
    EditGlobalOptions1: TMenuItem;
    Debug3: TMenuItem;
    AbortCMSbyexception2: TMenuItem;
    ShowTestForm1: TMenuItem;
    ViewEditDBContext1: TMenuItem;
    N27: TMenuItem;
    MainIcons18: TImageList;
    MainIcons44: TImageList;
    CalibrateImagebyline1: TMenuItem;
    CalibrateImagebypolyline2: TMenuItem;
    CalibrateImagebyimageresolution2: TMenuItem;
    CloseAll1: TMenuItem;
    ShowNVTreeForm2: TMenuItem;
    N20: TMenuItem;
    CallNCMTest2Form1: TMenuItem;
    N28: TMenuItem;
    HistogrammNew1: TMenuItem;
    ToolButtonNegate: TToolButton;
    PositiveNegative2: TMenuItem;
    Arrow2: TMenuItem;
    Ellipse2: TMenuItem;
    Rectangle3: TMenuItem;
    FlashlightMode2: TMenuItem;
    PopupMenu1: TPopupMenu;
    N29: TMenuItem;
    NoiseReductionAttributes2: TMenuItem;
    ImagingFilters: TMenuItem;
    A1: TMenuItem;
    B1: TMenuItem;
    C1: TMenuItem;
    D1: TMenuItem;
    E1: TMenuItem;
    F1: TMenuItem;
    Filter12: TMenuItem;
    Filter22: TMenuItem;
    Filter32: TMenuItem;
    Filter42: TMenuItem;
    SharpSmoothfast1: TMenuItem;
    SharpSmoothmedian1: TMenuItem;
    Patients1: TMenuItem;
    N30: TMenuItem;
    Providers1: TMenuItem;
    Practice1: TMenuItem;
    SharpSmoothfast2: TMenuItem;
    SharpSmoothtest21: TMenuItem;
    NoiseReductionTest1: TMenuItem;
    ConvPlainFileToEnc: TMenuItem;
    Sharp1: TMenuItem;
    Smooth1: TMenuItem;
    Median1: TMenuItem;
    Despeckle1: TMenuItem;
    Study1: TMenuItem;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ViewStudiesOnly1: TMenuItem;
    Databaserecovery1: TMenuItem;
    est11: TMenuItem;
    DebAction31: TMenuItem;
    Convertto8bit1: TMenuItem;
    Convertotgreyscale1: TMenuItem;
    AutoContrast1: TMenuItem;
    DebOption11: TMenuItem;
    DebOption21: TMenuItem;
    Fixthestudydata1: TMenuItem;
    DICOM1: TMenuItem;
    DICOMImport1: TMenuItem;
    DICOMExport1: TMenuItem;
    DICOMDIRImport2: TMenuItem;
    DICOMDIRExport1: TMenuItem;
    HRPreview1: TMenuItem;
    DICOMImportfolder1: TMenuItem;
    HighresolutionPreview1: TMenuItem;
    FSRecovery1MItem: TMenuItem;
    Printstudiesonly1: TMenuItem;
    ShowProtocolWindow1: TMenuItem;
    N3DImport1: TMenuItem;
    TWAINTest: TMenuItem;
    aServLaunchIUApp1: TMenuItem;
    CorrectBuildDProjFiles1: TMenuItem;
    CopytoD4WDocumentManager1: TMenuItem;
    TWAINASettings: TMenuItem;
    PnBBToolbars: TPanel;
    TBBB1: TToolBar;
    TBBB2: TToolBar;
    PnSBToolbars: TPanel;
    TBSB1: TToolBar;
    TBSB2: TToolBar;
    TBSB3: TToolBar;
    TBSB4: TToolBar;
    CustomizableTextAnnotations1: TMenuItem;
    ext11: TMenuItem;
    ext21: TMenuItem;
    ext32: TMenuItem;
    ext42: TMenuItem;
    CustomizeToolbar1: TMenuItem;
    DICOMQueryRetrieve1: TMenuItem;
    Presentation1: TMenuItem;
    ViewToolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    StudyOnlyToolButton: TToolButton;
    ToolButton8: TToolButton;
    ZoomToolButton: TToolButton;
    DisplayDelButton: TToolButton;
    SlidesFilterFrame: TK_FrameCMSlideFilter;
    Presentation2: TMenuItem;
    Loganal1: TMenuItem;
    CreateCMScanexeDistributive1: TMenuItem;
    OpenMainForm61: TMenuItem;
    Displayarchivedobjects1: TMenuItem;
    N31: TMenuItem;
    Addarchivedmediaobjectstorestoringqueue1: TMenuItem;
    Deletearchivedmediaobjectsfromrestoringqueue1: TMenuItem;
    SystemSetup1: TMenuItem;
    StringsAnalises1: TMenuItem;
    Switchtophotometrymode1: TMenuItem;
    WEBSettings1: TMenuItem;
    Export3D1: TMenuItem;
    DICOMStore1: TMenuItem;
    DICOMMWL1: TMenuItem;
    DICOMCommitment1: TMenuItem;
    pgcViewerHolder: TPageControl;
    tsSlidesViewer: TTabSheet;
    pmImportMedia: TPopupMenu;
    Raster1: TMenuItem;
    DICOM2: TMenuItem;
    Raster2: TMenuItem;
    DICOM3: TMenuItem;
    pnlSlidesViewerHolder: TPanel;

    procedure FormShow   ( Sender: TObject );
    procedure FormCloseQuery( Sender: TObject;  var CanClose: Boolean );
    procedure FormClose  ( Sender: TObject; var Action: TCloseAction ); override;
// Real Handlers Wrappers - saved to minimise onShow code
    procedure CMMFDisableActions       ( Sender: TObject );
    procedure FormActivate(Sender: TObject); override;
    procedure FormCanResize( Sender: TObject; var NewWidth,
                             NewHeight: Integer; var Resize: Boolean );
    procedure WMDropFiles( var Msg: TWMDropFiles ); message WM_DROPFILES;
//    procedure WMQueryEndSessionvar( var Message: TWMQueryEndSession);
// Self Interface Handlers
    procedure DICOMTest1Click          ( Sender: TObject );
    procedure SearchProjectFormsClick  ( Sender: TObject );
    procedure TestEd3FrameClick        ( Sender: TObject );
//    procedure MaintenancePopupMenuPopup(Sender: TObject);
    procedure aOpenMainForm6Execute(Sender: TObject);
    procedure aShowNewGUIClick(Sender: TObject);

    procedure ConvPlainFileToEncClick(Sender: TObject);
    procedure est11Click(Sender: TObject);
    procedure HRPreview1Click(Sender: TObject);
    procedure FSRecovery1MItemClick(Sender: TObject);
    procedure TWAINTestClick(Sender: TObject);
    procedure TWAINASettingsClick(Sender: TObject);
    procedure SlidesFilterFrameCmBFilterAttrsChange(Sender: TObject);
    procedure Loganal1Click(Sender: TObject);
    procedure StringsAnalises1Click(Sender: TObject);
    procedure DoMessageEvent(var Msg: TMsg; var Handled: Boolean);
    procedure FormCreate(Sender: TObject); //// Igor 11112019
    procedure FormDestroy(Sender: TObject); //Ura
    procedure BrowserClose(Sender: TObject);
    procedure pgcViewerHolderDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure pgcViewerHolderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pgcViewerHolderMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pgcViewerHolderMouseLeave(Sender: TObject);
    procedure pgcViewerHolderMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); //Igor Ura
  private
    FDICOMViewerHolder: TViewerTabSheet;

    FCloseButtonMouseDownTab: TViewerTabSheet;
    FCloseButtonShowPushed: Boolean;

    procedure CloseTabProc(Sender: TObject);
  private
    BPath : string;
    CheckConnDB: TTimer;
    procedure CheckConnDBTimer(Sender: TObject);
  public
    CMThumbsDGrid:    TN_DGridArbMatr; // DGrid for handling Thumbnails in ThumbsRFrame
    procedure MenuItemsDisableProc();
    procedure ChangeToolBarsVisibility    ();
    procedure CMFWndProc    ( var Msg: TMessage );
    procedure UpdateCustToolBar( ASetPanelsVisibilityOnly : Boolean );
    procedure UpdateCustToolBar1(  );
    function  TestDumpFiles1( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  TestDumpFiles2( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  TestDumpFiles3( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  TestDumpFiles31( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  TestDumpFiles4( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  TestDumpFiles41( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  TestDumpFiles5( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  TestDumpFiles51( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  TestDumpFiles52( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
    function  TestDumpFiles20200925( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
  public
    property DICOMViewerHolder: TViewerTabSheet read FDICOMViewerHolder;
end; // type TN_CMMain5Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

implementation
uses Types, IniFiles, math, StrUtils, ShellAPI,
     K_CLib0, K_UDT2, K_Script1, K_FRunDFPLScript,
     K_FCMSIsodensity, K_FCMMain6F, K_FCMStart, K_FCMHPreview, K_CMUtils,
     K_FCMTwainTest, K_FCMTwainASettings, K_FAStrings,
     L_VirtUI,
     N_Lib0, N_Gra1, N_CMResF, N_ButtonsF, N_CMMain5F, K_CML1F{DEBUG >>, K_CMSCom, ComServ},
     fDICOMViewer, K_CM1, K_FCMDCMDImport,
     VCL.Themes;
{$R *.dfm}

    //***********  TK_FormCMMain5 event Hadlers  *****

//************************************************* TK_FormCMMain5.FormShow ***
// Self initialization
//
//     Parameters
// Sender    - Event Sender
//
// OnShow Self handler
//
procedure TK_FormCMMain5.FormShow( Sender: TObject );
var
  i : Integer;
//  WStr, MaxRectStr: string;

begin
  if N_CM_MainForm.CMMCurFMainFormSkipOnShow then
  begin
    N_CM_MainForm.CMMCurFMainFormSkipOnShow := FALSE;
    Exit;
  end;

  pgcViewerHolder.ActivePageIndex := 0;

  N_Dump1Str( '***** Start TK_FormCMMain5 OnShow Handler' );

//  BFFlags := [bffToDump1];
  Self.Caption := N_CM_MainForm.Caption;

{$IF CompilerVersion >= 26.0} // Delphi >= XE5  needed to skip scroll bars blinking in W7-8
  ThumbsRFrame.VScrollBar.ParentDoubleBuffered := FALSE;
{$IFEND CompilerVersion >= 26.0}

  DoubleBuffered := True;
  Left1Panel.DoubleBuffered := True;
  Bot2Panel.DoubleBuffered := True;
  Top2Panel.DoubleBuffered := True;
  EdFramesPanel.DoubleBuffered := True;
  CaptToolBar.DoubleBuffered := True;

  Emboss1.ImageIndex := -1;
  Colorize1.ImageIndex := -1;
  PositiveNegative2.ImageIndex := -1;
  FlashlightMode2.ImageIndex := -1;
  ZoomInandZoomOut1.ImageIndex := -1;
  ViewStudiesOnly1.ImageIndex := -1;
  ShowDrawings1.ImageIndex := -1;

  for i := 0 to ImagingFilters.Count - 1 do
    ImagingFilters.Items[i].ImageIndex := -1;


{
  ToolButtonEmboss.ImageIndex   := 37;
  ToolButtonColorize.ImageIndex := 38;
  ToolButtonIsodens.ImageIndex  := 39;
  ToolButtonNegate.ImageIndex   := 34;
  ZoomToolButton.ImageIndex     := 15;
  StudyOnlyToolButton.ImageIndex := 107;
  FlashlightToolButton.ImageIndex := 61;
}
  //*** Form.WindowProc should be changed for processing Arrow and Tab keys
//  WindowProc := OwnWndProc;
  WindowProc := CMFWndProc;

  if CMThumbsDGrid = nil then // for recall after files handling on start
  begin
    CMThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, N_CM_MainForm.CMMFGetThumbSize );
    with CMThumbsDGrid do
    begin
      DGEdges := Rect( 2, 2, 2, 2 );
  //    DGEdges := Rect( 12, 12, 12, 12 );
      DGGaps  := Point( 2, 2 );
      DGScrollMargins := Rect( 8, 8, 8, 8 );

      DGLFixNumCols   := 1;
      DGLFixNumRows   := 0;
      DGSkipSelecting := True;
      DGChangeRCbyAK  := True;
  //    DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
      DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

      DGBackColor     := ColorToRGB( clBtnFace );
      DGMarkBordColor := N_CM_SlideMarkColor;
      DGMarkNormWidth := 2;
      DGMarkNormShift := 2;

      DGNormBordColor := DGBackColor;
      DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
      DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

      DGLAddDySize    := 28; // see DGLItemsAspect   - 2 Text Lines

      DGDrawItemProcObj := N_CM_MainForm.CMMFDrawThumb;
      DGExtExecProcObj  := N_CMResForm.ThumbsRFrameExecute;

      ThumbsRFrame.DstBackColor := DGBackColor;
      ThumbsRFrame.RFDebName := 'Thumbs';
      Windows.SetStretchBltMode( ThumbsRFrame.OCanv.HMDC, HALFTONE );
    end; // with CMMFThumbsDGrid do
  end;

  // Set Current Visual Contex
  N_CM_MainForm.CMMCurFMainForm := Self;
  N_CM_MainForm.CMMCurFStatusBar := StatusBar;
  N_CM_MainForm.CMMCurCaptToolBar := CaptToolBar;
  N_CM_MainForm.CMMCurFThumbsDGrid := CMThumbsDGrid;
  N_CM_MainForm.CMMCurFThumbsRFrame := ThumbsRFrame;
  N_CM_MainForm.CMMCurFThumbsResizeTControl := ThumbsRFrame;
  N_CM_MainForm.CMMCurChangeToolBarsVisibility := ChangeToolBarsVisibility;
  N_CM_MainForm.CMMCurMenuItemsDisableProc := MenuItemsDisableProc;
  N_CM_MainForm.CMMCurUpdateCustToolBar := UpdateCustToolBar1;
  N_CM_MainForm.CMMCurSlideFilterFrame := SlidesFilterFrame;
  N_CM_MainForm.CMMCurBigIcons := MainIcons44;
  N_CM_MainForm.EdFramesPanel.Parent := Bot2Panel;
  N_CM_MainForm.CMMCurMainMenu := MainMenu1;


  //  N_CM_MainForm.CMMCurSmallIcons:= MainIcons18;
  N_CMResForm.MainIcons18.Assign( MainIcons18 );
  K_CMDynIconsSInd := N_CMResForm.MainIcons18.Count;
  N_CM_MainForm.CMMCurMainMenu.Images := N_CMResForm.MainIcons18;

//  Init Controls Context
  Self.OnKeyDown := N_CM_MainForm.FormKeyDown;
  Self.OnKeyPress := N_CM_MainForm.FormKeyPress;

  EdFramesPanel.OnResize := N_CM_MainForm.CMMEdFramesPanelResize;

  // N_CM_IDEMode :
  // = 0 Release Version
  // = 1 Full Design Mode
  // = 2 Patial Design Mode
  Debug1.Visible := (N_CM_IDEMode = 1);
  Debug2.Visible := (N_CM_IDEMode = 1) or (N_CM_IDEMode = 2);

//  Init ThumbsRFr Context
  ThumbsRFrame.PopupMenu := N_CMResForm.ThumbsRFrPopupMenu;
  ThumbsRFrame.OnContextPopup := N_CM_MainForm.ThumbsRFrameContextPopup;
  ThumbsRFrame.OnEndDrag := N_CM_MainForm.ThumbsRFrameEndDrag;
  ThumbsRFrame.PaintBox.OnDblClick := N_CM_MainForm.ThumbsRFrameDblClick;
  ThumbsRFrame.OnMouseDownProcObj := N_CM_MainForm.OnThumbsFrameMouseDown;
//  ThumbsRFrame.DragCursor := crMultiDrag;
//  ThumbsRFrame.RFDumpEvents := True;

  BaseFormInit( nil, '', [rspfPrimMonWAR,rspfMaximize], [rspfAppWAR,rspfShiftAll] );
// 2017-08-22 - skip form moving processing to the new monitor
//  N_EnableMainFormMove := True;
  N_ProcessMainFormMove( N_GetScreenRectOfControl( Self ) );

  if K_CMEDAccess <> nil then
  begin // Archive Initialization is OK (not Failed)
    if not K_CMEDAccessInit2() then
      N_Dump1Str( 'TK_FormCMMain5 OnShow Handler >> K_CMEDAccessInit2=FALSE' );
  end; // if K_CMEDAccess <> nil then

  N_Dump1Str( Format( 'MainForm5: FormSize=(%d,%d) ClientSize=(%d,%d) BFMinBRPanelLT=(%d,%d)',
                [Width,Height,ClientWidth,ClientHeight,BFMinBRPanel.Left,BFMinBRPanel.Top] ));

  if K_CMEDAccess <> nil then
  begin // Archive Initialization is OK (not Failed)
    with SlidesFilterFrame do
    begin
      SFPFilterAttrs := @K_CMCurSlideFilterAttrs;
      SFChangeNotify := N_CM_MainForm.CMMFRebuildVisSlides;
      SFInit();
    end; // with SlidesFilterFrame do
    ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events
//    FSRecovery1MItem.Visible := K_CMDesignModeFlag or not (K_CMEDAccess is TK_CMEDDBAccess);
    FSRecovery1MItem.Visible := K_CMDesignModeFlag;
  end  // if K_CMEDAccess <> nil then
  else
    N_CM_MainForm.CMMFDisableActions( nil );

// Do resize SlidesFilterFrame and it's components after CMMFDisableActions
// defines aViewDisplayDelButton visibility
  with SlidesFilterFrame do
  begin
    Top := ViewToolBar.Top + ViewToolBar.Height + 1;
    Anchors := Anchors - [akRight];
    Width := ViewToolBar.Width;
    CmBFilterAttrs.Anchors := CmBFilterAttrs.Anchors - [akRight];
    CmBFilterAttrs.Width := ViewToolBar.Width;
  end;

  N_CM_MainForm.FormActivate( Sender ); // To Close CMS Splash Screen earlier then FormActivate

  N_Dump1Str( '***** Finish TK_FormCMMain5 OnShow Handler' );
// 07-11-2014 close for COM StartSession proper work
//  K_CMSAppStartContext.CMASMode := K_cmamWait; // Clear Start Mode (??? may be needed for HR Preview)

end; // procedure TK_FormCMMain5.FormShow

//******************************************* TK_FormCMMain5.FormCloseQuery ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TK_FormCMMain5.FormCloseQuery( Sender: TObject;  var CanClose: Boolean );
begin
  inherited;
  CanClose := not K_CMD4WSkipCloseUI; // needed to prevent application UI close
  N_Dump2Str( 'TK_FormCMMain5.FormCloseQuery CanClose =' + N_B2S(CanClose) );
end; // TK_FormCMMain5.FormCloseQuery

//Coutner TimeOut ////Igor 11112019
procedure TK_FormCMMain5.DoMessageEvent(var Msg: TMsg; var Handled: Boolean);
begin
  case Msg.message of
    WM_KEYFIRST..WM_KEYLAST, WM_MOUSEFIRST..WM_MOUSELAST:
    begin
      VirtUI_CountTime := 0;   //Drop Coutner Time Seconds in active application
    end;
    else
    inherited;
  end;
end; // procedure TK_FormCMMain5.DoMessageEvent

procedure TK_FormCMMain5.FormCreate(Sender: TObject);
var
  f: TForm;
begin
  inherited;
  if K_CMVUIMode then
  begin
    Application.OnMessage := DoMessageEvent; ////Igor 11112019    //key, mouse event
    VirtUI_Obj.OnClose := BrowserClose;
    CheckConnDB := TTimer.Create(Self);
    CheckConnDB.OnTimer := CheckConnDBTimer;
  end
  else
  begin
    FDICOMViewerHolder := TViewerTabSheet.Create(pgcViewerHolder);
    FDICOMViewerHolder.Caption := 'DICOM      ';
    FDICOMViewerHolder.PageControl := pgcViewerHolder;
    FDICOMViewerHolder.OnClose := CloseTabProc;
    FDICOMViewerHolder.TabVisible := False;
    FDICOMViewerHolder.Visible := True;

    FCloseButtonMouseDownTab := nil;

    DICOMViewer := TDICOMViewer.Create(DICOMViewerHolder);
    DICOMViewer.Parent := FDICOMViewerHolder;
    DICOMViewer.Show;
  end;
end; // procedure TK_FormCMMain5.FormCreate

procedure TK_FormCMMain5.FormDestroy(Sender: TObject); //Ura
begin
  if K_CMVUIMode then
  begin
    Application.OnMessage := nil;
    VirtUI_Obj.OnClose := nil;
  end;
  inherited;
end; // procedure TK_FormCMMain5.FormDestroy

procedure TK_FormCMMain5.BrowserClose(Sender: TObject);
begin
  N_Dump2Str('The Browser or Tab is closed by User!');
  Close;
end; // procedure TK_FormCMMain5.BrowserClose

//************************************************ TK_FormCMMain5.FormClose ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TK_FormCMMain5.FormClose( Sender: TObject; var Action: TCloseAction );
var
  WCurPatID : Integer;
  i : Integer;
//  WCurProvID, WCurLocID : Integer;
begin
  if K_CMSZoomForm <> nil then
    K_CMSZoomForm.Close;
//////////////////////////////////////////////////////////////////
//  Should be changed when real multy interface will be done
//

  K_GetFreeSpaceProfile();
  N_Dump1Str( '!!!MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr('; ', '%.0n') );
//  N_Dump1Str( '!!!MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr() );

  WCurPatID  := K_CMEDAccess.CurPatID;
//  WCurProvID := K_CMEDAccess.CurProvID;
//  WCurLocID  := K_CMEDAccess.CurLocID;

  K_FormCMSIsodensity.SelfClose; //!!!  15.11.2013 - moved from N_CM_MainForm.FormClose
  N_Dump1Str( '***** TK_FormCMMain5.OnClose Start' );
// To prevent collision in N_CM_MainForm.FormClose

  Inc(K_CMD4WWaitApplyDataCount); // To Prevent ñall to K_CMD4WApplyBufContext while FilesSaving
  N_CM_MainForm.CMMCurFThumbsRFrame := nil; // To prevent ThumbsRFrame Redraw
  N_CM_MainForm.CMMFFreeEdFrObjects();
  Dec(K_CMD4WWaitApplyDataCount); // clear

// To prevent actions in K_FormCMSIsodensity.FormClose
  CMThumbsDGrid.Free;
  ThumbsRFrame.RFFreeObjects();

  // to save current left frame width
  N_CM_MainForm.CMMCurFThumbsResizeWidth := N_CM_MainForm.CMMCurFThumbsResizeTControl.Width;

  // Clear Current Visual Contex
  N_CM_MainForm.CMMCurFMainForm := nil;
  N_CM_MainForm.CMMCurFStatusBar := nil;
  N_CM_MainForm.CMMCurCaptToolBar := nil;
  N_CM_MainForm.CMMCurFThumbsDGrid := nil;
  N_CM_MainForm.CMMCurFThumbsRFrame := nil;
  N_CM_MainForm.CMMCurFThumbsResizeTControl := nil;
  N_CM_MainForm.CMMCurChangeToolBarsVisibility := nil;
  N_CM_MainForm.CMMCurMenuItemsDisableProc := nil;
  N_CM_MainForm.CMMCurUpdateCustToolBar := nil;
  N_CM_MainForm.CMMCurSlideFilterFrame := nil;
  N_CM_MainForm.CMMCurBigIcons := nil;
  N_CM_MainForm.EdFramesPanel.Parent := N_CM_MainForm;
  N_CM_MainForm.CMMCurMainMenu := nil;

//  N_CM_MainForm.CMMFEdFrLayout := eflNotDef; //!!!

  inherited;

  DragAcceptFiles( Handle, FALSE );

//////////////////////////////////////////////////////////////////
//  New Main Interface Form Finish Code - Close Main "Start" Form

  if K_CMD4WAppFinState then
  begin
    N_Dump1Str( 'TK_FormCMMain5.OnClose >> N_CM_MainForm is already closed' );
    Exit;   // N_CM_MainForm (CMS) is already closed
  end;

  if K_CMGAModeFlag then // Clear GA Mode if VEUI is closed
    K_CMEDAccess.EDAClearGAMode();

  if K_CMEDAccess is TK_CMEDDBAccess and not K_CMSwitchMainUIFlag then
    TK_CMEDDBAccess(K_CMEDAccess).EDAClearActiveContext();

  if not K_CMCloseOnCurUICloseFlag then
  begin
    N_Dump1Str( 'TK_FormCMMain5.OnClose >> Other UI mode is launching' );
    Exit; // CMS should be continued on UI form closing
  end;

//  K_CMD4WHPNewPatientID    := WCurPatID;  // D4W HP New Patient ID
//  K_CMD4WHPNewProviderID   := WCurProvID; // D4W HP New Provider ID
//  K_CMD4WHPNewLocationID   := WCurLocID;  // D4W HP New Location ID

{}
/////////////////////////////////
// Dump Active Instances Table
//
  if K_CMEDAccess is TK_CMEDDBAccess then
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      if (LANDBConnection <> nil)    and
         (LANDBConnection.Connected) and
         (CurBlobDSet <> nil) then
      begin
        TmpStrings.Clear;
        EDADumpActiveContext( CurBlobDSet, TmpStrings, TRUE );
        if TmpStrings.Count > 1 then
          N_Dump1Str('*** Other Active CMSuites on Self Close ***'#13#10 + TmpStrings.Text);
      end
      else
        N_Dump1Str('*** Fails to Dump Other Active CMSuites on Self Close ***');
    end;
//
// Dump Active Instances Table
/////////////////////////////////
{}

//!!  if FALSE and
    if not K_CMVUIMode          and
       K_CMD4WAppRunByCOMClient and
       not K_CMOutOfMemoryFlag  and
       not K_CMD4WCloseAppByUI  and
       not (N_KeyIsDown(VK_SHIFT) and N_KeyIsDown(VK_CONTROL)) then
    begin
    // Close Connection only if is Run By Client and memory collisions were not detected


      with TK_CMEDDBAccess(K_CMEDAccess) do
      begin
        EDAAppDeactivate();
        EDARebuildADOObjects;

        ATimer.Enabled := TRUE;
      end;
      K_CMD4WCNewPatientID := WCurPatID; // Set K_CMD4WCNewPatientID as Flag that
                                         // CMS should be awaked with this patient context
                                         // on SetWindowState and ExecUICommand COM commands

      K_CMAutoCloseLastActTS := Now(); // Set Start DateTime to AutoClose CMSuite

      ////////////////////////////////
      // Dump Opened Slides UNDO files
      K_CMEDAccess.TmpStrings.Clear;
      for i := 0 to K_CMEDAccess.CurSlidesList.Count - 1 do
        if TObject(K_CMEDAccess.CurSlidesList[i]) is TN_UDCMSlide then
        begin
          with TN_UDCMSlide(K_CMEDAccess.CurSlidesList[i]) do
          if CMSUndoBuf <> nil then
            K_CMEDAccess.TmpStrings.Add( CMSUndoBuf.FUndoFilePath );
        end;
      if K_CMEDAccess.TmpStrings.Count > 0 then
        N_Dump1Str( format('UNDO Files List in %s:'#13#10, [K_ExpandFileName('(#TmpFiles#)')] ) +
                    K_CMEDAccess.TmpStrings.Text );

      N_Dump1Str( 'TK_FormCMMain5.OnClose >> Close UI, wait for COM client events' +
                  #13#10'=========='#13#10 );
      K_CMSAppStartContext.CMASMode := K_cmamSleep;
      Exit;
    end;
// Temp code to prevent warnings
{!!
i := N_i;
N_i := i;
N_i := WCurPatID;
}
//  N_Dump1Str( '***** K_FormCMMain.OnClose 2' );

  // Close Application
//??  N_CM_MainForm.ActTimer.Enabled := TRUE;
//??  K_CMD4WMainFormCloseFlag := TRUE;
  N_CM_MainForm.Close();
//  N_Dump1Str( '***** K_FormCMMain.OnClose 3' );
//  N_CM_MainForm.Release();
//  N_Dump1Str( '***** K_FormCMMain.OnClose 4' );

//  K_CMEDAccess.SkipProcessMessages := TRUE;
end; // procedure TK_FormCMMain5.FormClose

//*************************************** TK_FormCMMain5.CMMFDisableActions ***
// Disable needed Actions by current Application state
//
//     Parameters
// Sender - Event Sender
//
// Used as OnClick handler for All MainMenu top level Items and should be
// called after all other code, that may affect list of disabled Actions
//
procedure TK_FormCMMain5.CMMFDisableActions( Sender: TObject );
begin
  N_CM_MainForm.CMMFDisableActions( Sender );
end; // procedure TK_FormCMMain5.CMMFDisableActions

//********************************************* TK_FormCMMain5.FormActivate ***
// Self initialization
//
//     Parameters
// Sender    - Event Sender
//
// OnFormActivate Self handler
//
procedure TK_FormCMMain5.FormActivate( Sender: TObject );
begin
  inherited;
  N_CM_MainForm.FormActivate( Sender );
end; // TK_FormCMMain5.FormActivate

//*********************************************** TK_FormCMMain5.CMFWndProc ***
// Self WindowProc
//
//     Parameters
// Msg - Window Message
//
procedure TK_FormCMMain5.CMFWndProc(var Msg: TMessage);
begin
//if N_KeyIsDown(VK_SHIFT) then
//N_Dump2Str( format('%x %x', [Msg.Msg,Msg.WParam]) );

//  if Msg.Msg = WM_QUERYENDSESSION then
//    N_i := 0
{
  if Msg.Msg = WM_DESTROY then
  begin
    K_CMD4WCloseAppByUI := TRUE;
    Self.Close;
  end
  else
}  
  if Msg.Msg = WM_DROPFILES then
    WMDropFiles( TWMDropFiles(Msg) )
  else
  if (Msg.Msg = WM_SYSCOMMAND) and
     (Msg.WParam and $FFF0 = SC_MINIMIZE) then
    ShowWindow( Application.Handle, SW_SHOWMINIMIZED )
  else
    OwnWndProc( Msg );
end; // TK_FormCMMain5.CMFWndProc

//**************************************** TK_FormCMMain5.UpdateCustToolBar ***
// Update Customizable ToolBar
//
procedure TK_FormCMMain5.UpdateCustToolBar( ASetPanelsVisibilityOnly : Boolean );
var
  NewToolButton : TToolButton;
  NewAct : TAction;
  ActName : string;
  SL : TStrings;
  ActListsIniPref : string;
  SmallButtonsIniPref : string;
  LeftPos : Integer;

  function  CountButtons( APanel : TPanel ) : Integer;
  var
    i : Integer;
  begin
    Result := 0;
    for i := 0 to APanel.ControlCount - 1 do
      with TToolbar(APanel.Controls[i]) do
        Result := Result + ButtonCount
  end; // function CountButtons

  procedure ClearToolbars( APanel : TPanel );
  var
    i,j : Integer;
  begin
    for i := 0 to APanel.ControlCount - 1 do
    begin
      with TToolbar(APanel.Controls[i]) do
      begin
        for j := ButtonCount downto 1 do
          Buttons[0].Free;
        Visible := FALSE;
      end;
    end;
  end; // procedure ClearToolbars

  procedure FillToolbars( APanel : TPanel );
  var
    i, j : Integer;
    CurToolBar : TToolBar;
  begin
    for i := 0 to APanel.ControlCount - 1 do
    begin
      N_MemIniToStrings( ActListsIniPref + IntToStr(i), SL );
      CurToolBar := TToolbar(APanel.Controls[i]);
      N_Dump2Str( format( 'UpdateCustToolBar >> ToolBar %s', [CurToolBar.Name] ) );
      with SL do
      for j := Count - 1 downto 0 do
      begin
        ActName := Strings[j];
        NewAct := TAction(N_CMResForm.FindComponent( ActName ));
        if NewAct = nil then
          N_Dump1Str( format( '!!!UpdateCustToolBar >> action %s not found', [ActName] ) )
        else
        begin
          NewToolButton := TToolButton.Create(CurToolBar);
          NewToolButton.Action := NewAct;
          NewToolButton.Parent := CurToolBar;
          NewToolButton.ShowHint := TRUE;
          NewToolButton.Wrap := TRUE;
//          NewToolButton.Visible := TRUE;
          N_Dump2Str( format( 'UpdateCustToolBar >> New button %s', [ActName] ) );
        end
      end; // for j := Count - 1 downto 0 do

      if CurToolBar.ButtonCount > 0 then
      begin
        CurToolBar.Align := alNone;
        CurToolBar.Left := LeftPos;
        LeftPos := LeftPos + CurToolBar.Width;
        CurToolBar.Align := alLeft;
        APanel.Visible := TRUE;
        CurToolBar.Visible := TRUE;
        CurToolBar.Realign();
      end
      else
        CurToolBar.Visible := FALSE;
    end; // for i := 0 to APanel.ControlCount - 1 do
  end; // procedure FillToolbars
{
  procedure DumpToolbars( APanel : TPanel );
  var
    i, j : Integer;
    CurToolBar : TToolBar;
  begin
    for i := 0 to APanel.ControlCount - 1 do
    begin
      N_MemIniToStrings( ActListsIniPref + IntToStr(i), SL );
      CurToolBar := TToolbar(APanel.Controls[i]);
      N_Dump2Str( format( 'List %d=%d ToolBar %s=%d', [i, SL.Count, CurToolBar.Name, CurToolBar.ButtonCount] ) );
      with SL do
      for j := 0 to Min(Count,CurToolBar.ButtonCount) - 1 do
      begin
        with CurToolBar.Buttons[j] do
        N_Dump2Str( format( '%d L=%s T[%s]=%s', [j, Strings[j], Name, Action.Name] ) );
      end; // for j := Count - 1 downto 0 do
    end; // for i := 0 to APanel.ControlCount - 1 do
  end; // procedure DumpToolbars
}
begin

  N_Dump1Str( 'UpdateCustToolBar >> start VisOnly=' + N_B2S(ASetPanelsVisibilityOnly) );

// 2019-11-25 SIR 24115
  K_CMPrepIniFileCustToolbarNames( ActListsIniPref, SmallButtonsIniPref );
{ this code is moved to K_CMPrepIniFileContNames
  // Provider|Instance specific
  ActListsIniPref := 'CMCustToolbar';
  SmallButtonsIniPref := 'CustToolbarSmallButtons';
//  if K_CMUseCustToolbarGlobal then
  if K_CMUseCustToolbarInd = 1 then
  begin // Location specific
    ActListsIniPref := 'G' + ActListsIniPref;
    SmallButtonsIniPref := 'G' + SmallButtonsIniPref;
  end
  else
  if K_CMUseCustToolbarInd = 2 then
  begin // Global specific
    ActListsIniPref := 'GG' + ActListsIniPref;
    SmallButtonsIniPref := 'GG' + SmallButtonsIniPref;
  end;
}
  if ASetPanelsVisibilityOnly then
  begin
//    PnSBToolbars.Visible := N_MemIniToBool( 'CMS_Main', SmallButtonsIniPref,  FALSE );
//    PnBBToolbars.Visible := not PnSBToolbars.Visible;
    if N_MemIniToBool( 'CMS_Main', SmallButtonsIniPref,  FALSE ) then
    begin
      PnSBToolbars.Visible := CountButtons( PnSBToolbars ) > 0;
      PnBBToolbars.Visible := FALSE;
    end
    else
    begin
      PnBBToolbars.Visible := CountButtons( PnBBToolbars ) > 0;
      PnSBToolbars.Visible := FALSE;
    end;
    Exit;
  end;

  SL := TStringList.Create;
  LeftPos := 0;
  PnSBToolbars.Visible := FALSE;
  PnBBToolbars.Visible := FALSE;
  ClearToolbars( PnBBToolbars );
  ClearToolbars( PnSBToolbars );
  N_Dump1Str( format( 'UpdateCustToolBar by >> %s %s', [SmallButtonsIniPref, ActListsIniPref] ) );

  if N_MemIniToBool( 'CMS_Main', SmallButtonsIniPref,  FALSE ) then
  begin
    N_Dump2Str( 'UpdateCustToolBar >> Start BS ToolBars' );

//    PnSBToolbars.Visible := TRUE;
//    PnBBToolbars.Visible := FALSE;

    FillToolbars( PnSBToolbars );
//    PnSBToolbars.Refresh();
//    DumpToolbars( PnSBToolbars );
  end
  else
  begin
    N_Dump2Str( 'UpdateCustToolBar >> Start BB ToolBars' );

//    PnBBToolbars.Visible := TRUE;
//    PnSBToolbars.Visible := FALSE;

    FillToolbars( PnBBToolbars );
//    PnBBToolbars.Refresh();

  end;
  SL.Free;
  N_Dump2Str( 'UpdateCustToolBar >> Update fin' );

end; // procedure TK_FormCMMain5.UpdateCustToolBar

//*************************************** TK_FormCMMain5.UpdateCustToolBar1 ***
// Update Customizable ToolBar
//
procedure TK_FormCMMain5.UpdateCustToolBar1;
begin
  UpdateCustToolBar( FALSE );
end; // procedure TK_FormCMMain5.UpdateCustToolBar1


//******************************************** TK_FormCMMain5.FormCanResize ***
// Self Can Resize
//
//     Parameters
// Sender    - Event Sender
//
// onCanResize Self handler
//
procedure TK_FormCMMain5.FormCanResize( Sender: TObject; var NewWidth,
                                        NewHeight: Integer; var Resize: Boolean );
begin
  N_ProcessMainFormMove( N_GetScreenRectOfControl( Self ) );
end; // TK_FormCMMain5.FormCanResize


//********************************************** TK_FormCMMain5.WMDropFiles ***
// Drop Files Windows Message Handler
//
//     Parameters
// Msg - Windows Message
//
procedure TK_FormCMMain5.WMDropFiles( var Msg: TWMDropFiles );
var
  DropH: HDROP;               // Drop Files Handle
  DroppedFileCount: Integer;  // Drop Files Count
  FileNameLength: Integer;    // File Nme Length
  FileName: string;           // Drop File Name
  i: Integer;                 // Drop File Index
  ImpFiles: TStringList;
  ImpSlidesCount: Integer;   // Imported Slides Count
begin
  DropH := Msg.Drop;
  ImpFiles := TStringList.Create;
  try
    DroppedFileCount := DragQueryFile( DropH, $FFFFFFFF, nil, 0 ); // Get Drop Files Count
    N_Dump1Str( 'DropFiles>> Start Import ' + IntToStr(DroppedFileCount) );
    for i := 0 to DroppedFileCount - 1 do
    begin
      FileNameLength := DragQueryFile( DropH, i, nil, 0 ); // Get Drop File Name Length
      SetLength( FileName, FileNameLength );
      DragQueryFile( DropH, i, PChar(FileName), FileNameLength + 1 ); // Get Drop File Name
      ImpFiles.Add( FileName );
    end;
  finally
    DragFinish( DropH ); // Free Drop Handle
  end;
  Msg.Result := 0; // Message is processed

  ImpSlidesCount := K_CMSlidesImportAndProcessFromFilesList( ImpFiles );
  N_Dump1Str( format( 'DropFiles>> %d imported of %d droped',
                      [ImpSlidesCount,DroppedFileCount] ) );
  if ImpSlidesCount > 0 then
  begin
    N_CM_MainForm.CMMFRebuildVisSlides();
    N_CM_MainForm.CMMFDisableActions( nil );
  end;

  ImpFiles.Free;

end; // TK_FormCMMain5.WMDropFiles

    //***********  TK_FormCMMain5 Public methods  *****

//************************************* TK_FormCMMain5.MenuItemsDisableProc ***
// Disabled/Enabled Menu Items
//
procedure TK_FormCMMain5.MenuItemsDisableProc();
var
  WFlag : Boolean;
  i : Integer;
begin
  Tools1.Enabled := (K_uarModify in K_CMCurUserAccessRights)         and
                    (N_CM_MainForm.CMMFActiveEdFrame <> nil)         and
                    (N_CM_MainForm.CMMFActiveEdFrame.EdSlide <> nil) and
                    not (TN_UDCMBSlide(N_CM_MainForm.CMMFActiveEdFrame.EdSlide) is TN_UDCMStudy);
  Deletedobjectshandling2.Visible := K_CMEnterpriseModeFlag and K_CMGAModeFlag;
  Capture1.Enabled := (K_uarCapture in K_CMCurUserAccessRights) and not K_CMVUIMode;

// Calc ImagingFilters SubMenu Visible
  WFlag := FALSE;
  for i := 0 to ImagingFilters.Count - 1 do
    with ImagingFilters.Items[i] do
    begin
      Visible := Enabled;
      WFlag := WFlag or Visible;
    end;
  ImagingFilters.Visible := WFlag;

// Calc ImagingFilters SubMenu Enable
  WFlag := FALSE;
  for i := 0 to ImagingFilters.Count - 1 do
    if ImagingFilters.Items[i].Enabled then
    begin
      WFlag := TRUE;
      Break;
    end;
  ImagingFilters.Enabled := WFlag;

// Calc CalibrateImage1 SubMenu Enable
  WFlag := FALSE;
  for i := 0 to CalibrateImage1.Count - 1 do
    if CalibrateImage1.Items[i].Enabled and
      (CalibrateImage1.Items[i].Caption <> '-') then
    begin
      WFlag := TRUE;
      Break;
    end;
  CalibrateImage1.Enabled := WFlag;

// Calc miAnnotations SubMenu Enable
  WFlag := FALSE;
  for i := 0 to miAnnotations.Count - 1 do
    if miAnnotations.Items[i].Enabled and
      (miAnnotations.Items[i].Caption <> '-') then
    begin
      WFlag := TRUE;
      Break;
    end;
  miAnnotations.Enabled := WFlag;

// Set GFiltersToolBar Buttons Visible
  for i := 0 to GFiltersToolBar.ButtonCount - 1 do
    with GFiltersToolBar.Buttons[i] do
    begin
    //////////////////////////////////////////////////////
    // is needed because if VEUI mode is restored after
    // close TK_FormCMMain5 without application close
    // Buttons[1].Wrap is TRUE instead of Buttons[2].Wrap
      if i <> 2 then
        Wrap := FALSE
      else
        Wrap := TRUE;
    //
    //////////////////////////////////////////////////////

      ImageIndex := 100 + i;
    end;

  GFiltersToolBar.Realign();
  
//                  Run by D4W            or StandAlone Mode (because)
//  DICOM1.Visible := K_CMD4WAppRunByClient or N_CMResForm.aGoToPatients.Visible;
//  DICOM1.Enabled := K_CMD4WAppRunByClient or N_CMResForm.aGoToPatients.Visible;
{
    DICOM1.Visible := ( (K_CMSLiRegStatus <> K_lrtComplex) and
                         K_CMGUIDICOMMenuVisFlag )
                                        or
                      ( (K_CMSLiRegStatus = K_lrtComplex) and
                        not (limdDICOM in K_CMSLiRegModDisable) )
                                        or
                                 K_CMDesignModeFlag;
}
    DICOM1.Visible := K_CMDICOMVisible();

//    aDeb2CreateDemoExeDistr
{
  ZoomToolButton.Down := K_CMSZoomForm <> nil;
  if ZoomInandZoomOut1.ImageIndex <> -1 then
  begin
    ZoomInandZoomOut1.ImageIndex := -1;
    ZoomInandZoomOut1.Caption := '&Zoom';
  end;
  ZoomInandZoomOut1.Checked := K_CMSZoomForm <> nil;
}

end;

procedure TK_FormCMMain5.pgcViewerHolderDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  CloseBtnSize: Integer;
  PageControl: TPageControl;
  TabSheet: TViewerTabSheet;
  TabCaption: TPoint;
  CloseBtnRect: TRect;
  CloseBtnDrawState: Cardinal;
  CloseBtnDrawDetails: TThemedElementDetails;
begin
  PageControl := Control as TPageControl;
  TabCaption.Y := Rect.Top + 3;

  if Active then
  begin
    CloseBtnRect.Top := Rect.Top + 4;
    CloseBtnRect.Right := Rect.Right - 5;
    TabCaption.X := Rect.Left + 6;
  end
  else
  begin
    CloseBtnRect.Top := Rect.Top + 3;
    CloseBtnRect.Right := Rect.Right - 5;
    TabCaption.X := Rect.Left + 3;
  end;

  if PageControl.Pages[TabIndex] is TViewerTabSheet then
  begin
    TabSheet:=PageControl.Pages[TabIndex] as TViewerTabSheet;
    CloseBtnSize := 14;

    CloseBtnRect.Bottom := CloseBtnRect.Top + CloseBtnSize;
    CloseBtnRect.Left := CloseBtnRect.Right - CloseBtnSize;
    TabSheet.CloseButtonRect := CloseBtnRect;

    PageControl.Canvas.FillRect(Rect);
    PageControl.Canvas.TextOut(TabCaption.X, TabCaption.Y,
            PageControl.Pages[TabIndex].Caption);

    if not ThemeServices.ThemesEnabled then
    begin
      if (FCloseButtonMouseDownTab = TabSheet) and FCloseButtonShowPushed then
        CloseBtnDrawState := DFCS_CAPTIONCLOSE + DFCS_PUSHED
      else
        CloseBtnDrawState := DFCS_CAPTIONCLOSE;

      DrawFrameControl(PageControl.Canvas.Handle, TabSheet.CloseButtonRect, DFC_CAPTION, CloseBtnDrawState);
    end
    else
    begin
//      TabSheet.CloseButtonRect.Left := TabSheet.CloseButtonRect.Left - 1;

      if (FCloseButtonMouseDownTab = TabSheet) and FCloseButtonShowPushed then
        CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonPushed)
      else
        CloseBtnDrawDetails := ThemeServices.GetElementDetails(twCloseButtonNormal);

      ThemeServices.DrawElement(PageControl.Canvas.Handle, CloseBtnDrawDetails, TabSheet.CloseButtonRect);
    end;
  end
  else
  begin
    PageControl.Canvas.FillRect(Rect);
    PageControl.Canvas.TextOut(TabCaption.X, TabCaption.Y, PageControl.Pages[TabIndex].Caption);
  end;
end;

procedure TK_FormCMMain5.pgcViewerHolderMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  PageControl: TPageControl;
  TabSheet: TViewerTabSheet;
begin
  PageControl := Sender as TPageControl;

  if Button = mbLeft then
  begin
    for I := 0 to PageControl.PageCount - 1 do
    begin
      if not (PageControl.Pages[i] is TViewerTabSheet) then Continue;

      TabSheet:=PageControl.Pages[i] as TViewerTabSheet;

      if PtInRect(TabSheet.CloseButtonRect, Point(X, Y)) then
      begin
        FCloseButtonMouseDownTab := TabSheet;
        FCloseButtonShowPushed := True;
        PageControl.Repaint;
      end;
    end;
  end;
end;

procedure TK_FormCMMain5.pgcViewerHolderMouseLeave(Sender: TObject);
var
  PageControl: TPageControl;
begin
  PageControl := Sender as TPageControl;
  FCloseButtonShowPushed := False;
  PageControl.Repaint;
end;

procedure TK_FormCMMain5.pgcViewerHolderMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  PageControl: TPageControl;
  Inside: Boolean;
begin
  PageControl := Sender as TPageControl;

  if (ssLeft in Shift) and Assigned(FCloseButtonMouseDownTab) then
  begin
    Inside := PtInRect(FCloseButtonMouseDownTab.CloseButtonRect, Point(X, Y));

    if FCloseButtonShowPushed <> Inside then
    begin
      FCloseButtonShowPushed := Inside;
      PageControl.Repaint;
    end;
  end;
end;

procedure TK_FormCMMain5.pgcViewerHolderMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  PageControl: TPageControl;
begin
  PageControl := Sender as TPageControl;

  if (Button = mbLeft) and Assigned(FCloseButtonMouseDownTab) then
  begin
    if PtInRect(FCloseButtonMouseDownTab.CloseButtonRect, Point(X, Y)) then
    begin
      FCloseButtonMouseDownTab.Close;
      FCloseButtonMouseDownTab := nil;
      PageControl.Repaint;
    end;
  end;
end;

// end of procedure TK_FormCMMain5.MenuItemsDisableProc

//*************************************** TK_FormCMMain5.ChangeToolBarsVisibility ***
// Update ToolBars visibility by appropriate Actions state
//
procedure TK_FormCMMain5.ChangeToolBarsVisibility();
begin
//  Right1Panel.Visible := N_CMResForm.aVTBAlterations.Checked;
  N_Dump2Str( 'ChangeToolBarsVisibility=' + N_B2S(N_CMResForm.aVTBAlterations.Checked) );
  Right1Panel.Visible := FALSE;
  if N_CMResForm.aVTBAlterations.Checked then
    UpdateCustToolBar( TRUE )
  else
  begin
    PnSBToolbars.Visible := FALSE;
    PnBBToolbars.Visible := FALSE;
  end;


  if N_CMResForm.aVTBAllTopToolbars.Checked then
  begin
//    CaptToolBar.Visible := True;
////    SysToolbar1.Visible := True;
////    SysToolbar2.Visible := True;
//    MediaToolBar.Visible := True;
//    SlidesFilterFrame.Visible := True;
//    ViewToolBar.Visible := True;
    Top2Panel.Visible   := True;
  end else
  begin
//    CaptToolBar.Visible := False;
////    SysToolbar1.Visible := False;
////    SysToolbar2.Visible := False;
//    MediaToolBar.Visible := False;
//    SlidesFilterFrame.Visible := False;
//    ViewToolBar.Visible := False;
    Top2Panel.Visible   := False;
  end;
end; // end of procedure TN_CMMain5Form.ChangeToolBarsVisibility

procedure TK_FormCMMain5.CheckConnDBTimer(Sender: TObject);
begin
  if not K_CMVUIMode then Exit;
  VirtUI_CountTime := VirtUI_CountTime + 1;
  if VirtUI_ScanRun then VirtUI_CountTime := 0;  ////Igor 16092020 SIR#25767
  if VirtUI_CountTime > K_CMVUICMSIdleTime * 60 then        ////second TimeOut
  begin
    N_Dump1Str( 'AppTimeOut>> Close App TimeOut...');
    Close;                                                               ////Igor 14072020
  end;
  if not CheckConnection(K_CMVUIDataBaseIP, K_CMVUIDataBasePort) then    ////Igor 25102019
  begin
    N_Dump1Str( 'CheckConnDB>> Close App...'  + IntToStr(K_CMVUIDataBaseIP) + ': ' +  IntToStr(K_CMVUIDataBasePort) );
    Application.Terminate;
  end;
end;

// procedure TK_FormCMMain5.CheckConnDBTimer(Sender: TObject);


{
//********************************************** TK_FormCMMain5.MaintenancePopupMenuPopup ***
// Service Menu Popup Handler
//
//
procedure TK_FormCMMain5.MaintenancePopupMenuPopup(Sender: TObject);
begin
//
  with N_CMResForm do
  begin
    aServEModeFilesSync.Visible := K_CMEnterpriseModeFlag;
    aServSelSlidesToSyncQuery.Visible := K_CMEnterpriseModeFlag;
    aServECacheAllShow.Visible  := not K_CMDEMOModeFlag;
    aServImportExtDBDlg.Visible := not K_CMDEMOModeFlag;
    aServMaintenance.Visible := K_CMEDAccess is TK_CMEDDBAccess;
    aServMaintenance.Enabled := not K_CMEnterpriseModeFlag;
    aServDBRecoveryByFiles.Visible := K_CMEDAccess is TK_CMEDDBAccess;
    aServDelObjHandling.Visible := K_CMEDAccess is TK_CMEDDBAccess;
  end;
end; // end of procedure TK_FormCMMain5.MaintenancePopupMenuPopup
}
procedure TK_FormCMMain5.DICOMTest1Click( Sender: TObject );
var
  WFName : string;
begin
  with TK_DICOMAccess.Create do begin
    with TOpenDialog.Create( Application ) do begin
      Filter := 'All files (*.*)|*.*';
      Options := Options + [ofEnableSizing];
      Title := 'DICOM Test';
      WFName := '';
      if Execute then
        WFName := FileName;
      Free;
    end;
    if WFName <> '' then
      DCFileDump( WFName, ChangeFileExt( WFName, '.txt' ) );
    Free;
  end;
end; // procedure TK_FormCMMain5.DICOMTest1Click

procedure TK_FormCMMain5.SearchProjectFormsClick ( Sender: TObject );
var
  BasePath : string;
  ResTStrings : TStrings;
begin
  BasePath := K_ExpandFileName( '(##Exe#)..\' );
  with TK_SearchInFiles.Create do begin
    SIFFNamePat := '*.dfm';
    SIFFoundStrRFormat := '';
    SIFSeachCond := 'Explicit';

    SIFFilesPath := BasePath + 'K_CLib\';
    ResTStrings := SIFSearchResultsToStrings( nil );

    SIFFilesPath := BasePath + 'K_MVDar\';
    SIFSearchResultsToStrings( nil );

    ResTStrings.Insert( 0, '           Forms with "Explicit" Fields changed by Delphi 2010' );
    SIFFilesPath := BasePath + 'N_Tree\';
    BasePath := K_ExpandFileName( '(#TmpFiles#)!!!ProjectFormsWithExplicit.txt' );
    SIFSearchResultsToFile( BasePath );
    ResTStrings.Free;
    Free;

    K_ShellExecute( 'open', BasePath );
//    N_ShowFileInRichEditor ( BasePath );
  end;

end; // procedure TK_FormCMMain5.SearchProjectFormsClick

procedure TK_FormCMMain5.TestEd3FrameClick( Sender: TObject );
var
  FF : TN_BaseForm;
  hTaskBar: THandle;
  PrevParent: TWinControl;
begin
//
  with N_CM_MainForm do begin
    if not CMMFCheckBSlideExisting() then
    begin
  //    Dec(K_CMD4WWaitApplyDataCount);
  //    K_CMD4WWaitApplyDataFlag := false;
      N_Dump2Str( 'Nothing to do TestEd3Frame' );
      Exit;
    end;
    FF := TN_BaseForm.Create( Application );
    with FF do
    begin
      BFSelfName := 'FullScreenForm';
  //    RFrame.ParentForm := Result;
      BaseFormInit( Self );

//      BorderStyle := bsNone;
      Top    := 0;
      Left   := 0;
      Width  := Screen.Width - 200;
      Height := Screen.Height - 200;

      PrevParent := CMMFActiveEdFrame.Parent;
      CMMFActiveEdFrame.Parent := FF;
      ActiveControl := CMMFActiveEdFrame.RFrame;

      hTaskbar := FindWindow( 'Shell_TrayWnd', nil );
      if hTaskbar <> 0 then
      begin
        EnableWindow( HTaskBar, FALSE ); // Disabled TaskBar
        ShowWindow( hTaskBar, SW_HIDE ); // Hide TaskBar
      end;

    //***** now always "fit in Window" mode is used
      ShowModal;
      CMMFActiveEdFrame.Parent := PrevParent;

      if hTaskbar <> 0 then
      begin
        EnableWindow( HTaskBar, TRUE );        // Enabled TaskBar
        ShowWindow( hTaskBar, SW_SHOWNORMAL ); // Show TaskBar
      end;

//      RFrame.SomeStatusbar := StatusBar;
//      RFrame.RFDebName := RFrame.Name;
    end;

//      RFrame.aFullScreenExecute( Sender );
    SetFocus();
  end;
end; // procedure TK_FormCMMain5.TestEd3FrameClick

procedure TK_FormCMMain5.aOpenMainForm6Execute(Sender: TObject);
var
  CurThumbsFrameWidth, EdFrPanelLeft : Integer;
  PRevParent : TWinControl;
//  CurSlideFilterAttrs: TK_CMSlideFilterAttrs; // Current Filtering Attributes
begin
  CurThumbsFrameWidth := N_CM_MainForm.CMMCurFThumbsRFrame.Width;
  with TK_FormCMMain6.Create(Application) do
  begin
    BaseFormInit(nil);
    Left2Panel.Width := CurThumbsFrameWidth;
    N_CM_MainForm.EdFramesPanel.Visible := FALSE;
    EdFrPanelLeft := N_CM_MainForm.EdFramesPanel.Left;
    N_CM_MainForm.EdFramesPanel.Left   := 0;
    PRevParent := N_CM_MainForm.EdFramesPanel.Parent;
    N_CM_MainForm.EdFramesPanel.Parent := EdFramesPanel;
    N_CM_MainForm.EdFramesPanel.Visible := TRUE;
//    K_CMShowGUIFlag := TRUE;
//    CurSlideFilterAttrs := K_CMCurSlideFilterAttrs;

    N_CM_MainForm.CMMFDisableActions(Sender);
    ShowModal();
//    CurThumbsFrameWidth := Left2Panel.Width;
    N_CM_MainForm.EdFramesPanel.Visible := FALSE;
    N_CM_MainForm.EdFramesPanel.Left := EdFrPanelLeft;
    N_CM_MainForm.EdFramesPanel.Parent := PRevParent;
    N_CM_MainForm.EdFramesPanel.Visible := TRUE;
  end;
  // Set Current Visual Contex
  N_CM_MainForm.CMMCurFMainForm := Self;
  N_CM_MainForm.CMMCurFStatusBar := StatusBar;
  N_CM_MainForm.CMMCurCaptToolBar := CaptToolBar;
  N_CM_MainForm.CMMCurFThumbsDGrid := CMThumbsDGrid;
  N_CM_MainForm.CMMCurFThumbsRFrame := ThumbsRFrame;
  N_CM_MainForm.CMMCurFThumbsResizeTControl := ThumbsRFrame;
  N_CM_MainForm.CMMCurChangeToolBarsVisibility := ChangeToolBarsVisibility;
  N_CM_MainForm.CMMCurMenuItemsDisableProc := MenuItemsDisableProc;
  N_CM_MainForm.CMMCurSlideFilterFrame := SlidesFilterFrame;
  N_CM_MainForm.CMMCurMainMenu := MainMenu1;

  N_CM_MainForm.CMMFRebuildVisSlides();
  N_CM_MainForm.CMMFDisableActions(Sender);

end; // procedure TK_FormCMMain5.aOpenMainForm6Execute

procedure TK_FormCMMain5.aShowNewGUIClick(Sender: TObject);
//var
//  CurThumbsFrameWidth : Integer;
begin
//  CurThumbsFrameWidth := N_CM_MainForm.CMMCurFThumbsRFrame.Width;
  with TK_FormCMMain6.Create(Application) do
  begin
    BaseFormInit(nil);
    K_CMShowGUIFlag := TRUE;
    N_CM_MainForm.CMMFDisableActions(Sender);
    ShowModal();
  end;
  N_CM_MainForm.CMMCurFMainForm := Self;
  N_CM_MainForm.CMMCurFStatusBar := StatusBar;
  N_CM_MainForm.CMMCurCaptToolBar := CaptToolBar;
  N_CM_MainForm.CMMCurFThumbsDGrid := CMThumbsDGrid;
  N_CM_MainForm.CMMCurFThumbsRFrame := ThumbsRFrame;
  N_CM_MainForm.CMMCurFThumbsResizeTControl := ThumbsRFrame;
  N_CM_MainForm.CMMCurChangeToolBarsVisibility := ChangeToolBarsVisibility;
  N_CM_MainForm.CMMCurMenuItemsDisableProc := MenuItemsDisableProc;
  N_CM_MainForm.CMMCurSlideFilterFrame := SlidesFilterFrame;
  N_CM_MainForm.CMMCurMainMenu := MainMenu1;
//  N_CM_MainForm.CMMCurSmallIcons:= MainIcons18;
  N_CM_MainForm.CMMCurBigIcons := MainIcons44;
  N_CMResForm.MainIcons18.Assign( MainIcons18 );
  K_CMDynIconsSInd := N_CMResForm.MainIcons18.Count;

  N_CM_MainForm.CMMFRebuildVisSlides();
  N_CM_MainForm.ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events
  K_CMShowGUIFlag := FALSE;
  N_CM_MainForm.CMMFDisableActions(Sender);

end; // procedure TK_FormCMMain5.aShowNewGUIClick

procedure TK_FormCMMain5.ConvPlainFileToEncClick(Sender: TObject);
var
  FName : string;
  CreatePars : TK_DFCreateParams;

begin
  with TOpenDialog.Create( Application ) do
  begin
    Options := Options + [ofEnableSizing];
    Title := 'CMS file conversion';
    FName := '';
    if Execute  then
      FName := FileName;
    Free;
  end;
  if FName = '' then Exit;
  CreatePars.DFCreateFlags := [K_dfcEncryptSrc];
  CreatePars.DFEncryptionType := K_dfeXOR;
  CreatePars.DFFormatVersion := K_DFFormatVersion1;

  K_VFCopyFile( FName, ChangeFileExt( FName, '.dat'), CreatePars );

end; // end of TK_CMEDAccess.EDASlideDataToFile


procedure TK_FormCMMain5.est11Click(Sender: TObject);
var
  VFile1: TK_VFile;
  VFile2: TK_VFile;
//  MW, MH : OleVariant;
begin
//MW := 0;
//MH := 0;
//TD4WCMServer(ComServer).GetSlideImageFile( 488, MW, MH, 3,0,'C:\Delphi_prj_new\DTmp\!CMS_LogFiles\Alex\1.jpg');
//Exit;

N_b := K_CheckTextPatternEx( '1111', 4, '*', 1 );
N_b := K_CheckTextPatternEx( '1111', 4, '**', 2 );
N_b := K_CheckTextPatternEx( '111', 3, '??', 2);
N_b := K_CheckTextPatternEx( '111', 3, '???', 3 );
N_b := K_CheckTextPatternEx( '111', 3, '????', 4 );
N_b := K_CheckTextPatternEx( '111', 3, '*???', 4 );
N_b := K_CheckTextPatternEx( '111', 3, '???*', 4 );
N_b := K_CheckTextPatternEx( '1114', 4, '*?4', 3 );
N_b := K_CheckTextPatternEx( '14', 2, '*?4', 3 );
N_b := K_CheckTextPatternEx( '1111', 4, '1', 1 );
N_b := K_CheckTextPatternEx( '1111', 4, '*1', 2 );
N_b := K_CheckTextPatternEx( '1234', 4, '2', 1 );
N_b := K_CheckTextPatternEx( '1234', 4, '*2*', 3 );
N_b := K_CheckTextPatternEx( '1234', 4, '?2*', 3 );
N_b := K_CheckTextPatternEx( '1234', 4, '?2??', 4 );
N_b := K_CheckTextPatternEx( '1234', 4, '1?3?', 4 );
N_b := K_CheckTextPatternEx( '1234', 4, '*3?', 3 );
N_b := K_CheckTextPatternEx( '1234', 4, '*2*4', 4 );
N_b := K_CheckTextPatternEx( '123232344', 9, '*23?4', 5 );
N_b := K_CheckTextPatternEx( '123232345', 9, '*23?4', 5 );

N_b := K_SearchTextPattern( '1234', 4, '23', 2, N_i, N_i1 );
N_b := K_SearchTextPattern( '111', 3, '??', 2, N_i, N_i1 );
N_b := K_SearchTextPattern( '1144', 4, '*?4', 3, N_i, N_i1 );
N_b := K_SearchTextPattern( '2111445', 7, '?1?4', 4, N_i, N_i1 );
N_b := K_SearchTextPattern( '2111445', 7, '1*4', 3, N_i, N_i1 );
N_b := K_SearchTextPattern( '2111445', 7, '1*5', 3, N_i, N_i1 );

//exit;

N_Dump1Str('CMS test close from D4W');
K_CMD4WCloseAppByUITest := TRUE;
N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServCloseCMS, TRUE, 30000 );
exit;
////////////////////
raise Exception.Create( 'Test Exception' );
/////////////////////
// Create 2 Segments 25 bytes each and close compound file
  K_VFAssignByPath( VFile1, K_ExpandFileName('(#TmpFiles#)1.dat|file\1') );
  K_VFSaveText0( '1234567890     1234567890', VFile1 );
  K_VFAssignByPath( VFile2, K_ExpandFileName('(#TmpFiles#)1.dat|file\2') );
  K_VFSaveText0( '0987654321     0987654321', VFile2 );
  K_MVCBFileClose ( VFile1.UDCBFRoot );

/////////////////////
// Change Segment 1 Space to 30 and close compound file
  K_VFAssignByPath( VFile1, K_ExpandFileName('(#TmpFiles#)1.dat>file\1') );
  K_VFSetDataSpace( VFile1, 30 );
  K_MVCBFileClose ( VFile1.UDCBFRoot );

// Check 1
  K_VFAssignByPath( VFile1, K_ExpandFileName('(#TmpFiles#)1.dat>file\1') );
  K_VFLoadText0( N_S, VFile1 );
  if N_S <> '1234567890     1234567890' then
    N_S := '';

// Check 2
  K_VFAssignByPath( VFile2, K_ExpandFileName('(#TmpFiles#)1.dat>file\2') );
  K_VFLoadText0( N_S, VFile2 );
  if N_S <> '0987654321     0987654321' then
    N_S := '';
  K_MVCBFileClose ( VFile2.UDCBFRoot );

/////////////////////
// Change Segment 1 Content (30) and try to change Space 30 -> 25 and close compound file
  K_VFAssignByPath( VFile1, K_ExpandFileName('(#TmpFiles#)1.dat>file\1') );
  K_VFSaveText0( '1234567890          1234567890', VFile1 );
  K_VFSetDataSpace( VFile1, 25 );
  K_MVCBFileClose ( VFile1.UDCBFRoot );

// Check 1
  K_VFAssignByPath( VFile1, K_ExpandFileName('(#TmpFiles#)1.dat>file\1') );
  K_VFLoadText0( N_S, VFile1 );
  if N_S <> '1234567890          1234567890' then
    N_S := '';

// Check 2
  K_VFAssignByPath( VFile2, K_ExpandFileName('(#TmpFiles#)1.dat>file\2') );
  K_VFLoadText0( N_S, VFile2 );
  if N_S <> '0987654321     0987654321' then
    N_S := '';
  K_MVCBFileClose ( VFile2.UDCBFRoot );

/////////////////////
// Try to change Segment 1 Space 30 -> 25 and close compound file
  K_VFAssignByPath( VFile1, K_ExpandFileName('(#TmpFiles#)1.dat>file\1') );
  K_VFSetDataSpace( VFile1, 25 );
  K_MVCBFileClose ( VFile1.UDCBFRoot );

// Check 1
  K_VFAssignByPath( VFile1, K_ExpandFileName('(#TmpFiles#)1.dat>file\1') );
  K_VFLoadText0( N_S, VFile1 );
  if N_S <> '1234567890          1234567890' then
    N_S := '';

 // Check 2
  K_VFAssignByPath( VFile2, K_ExpandFileName('(#TmpFiles#)1.dat>file\2') );
  K_VFLoadText0( N_S, VFile2 );
  if N_S <> '0987654321     0987654321' then
    N_S := '';
  K_MVCBFileClose ( VFile2.UDCBFRoot );

/////////////////////
// Change Segment 1 Content 30 -> 25 and close compound file
  K_VFAssignByPath( VFile1, K_ExpandFileName('(#TmpFiles#)1.dat>file\1') );
  K_VFSaveText0( '1234567890     1234567890', VFile1 );
  K_MVCBFileClose ( VFile1.UDCBFRoot );

// Check 1
  K_VFAssignByPath( VFile1, K_ExpandFileName('(#TmpFiles#)1.dat>file\1') );
  K_VFLoadText0( N_S, VFile1 );
  if N_S <> '1234567890     1234567890' then
    N_S := '';

// Check 2
  K_VFAssignByPath( VFile2, K_ExpandFileName('(#TmpFiles#)1.dat>file\2') );
  K_VFLoadText0( N_S, VFile2 );
  if N_S <> '0987654321     0987654321' then
    N_S := '';
  K_MVCBFileClose ( VFile2.UDCBFRoot );


/////////////////////
// Change Segment 2 Content 25 -> 30 and close compound file
  K_VFAssignByPath( VFile2, K_ExpandFileName('(#TmpFiles#)1.dat>file\2') );
  K_VFSaveText0( '0987654321          0987654321', VFile2 );
  K_MVCBFileClose ( VFile2.UDCBFRoot );


  K_VFAssignByPath( VFile1, K_ExpandFileName('(#TmpFiles#)1.dat>file\1') );
  K_VFLoadText0( N_S, VFile1 );
  if N_S <> '1234567890     1234567890' then
    N_S := '';

// Check 2
  K_VFAssignByPath( VFile2, K_ExpandFileName('(#TmpFiles#)1.dat>file\2') );
  K_VFLoadText0( N_S, VFile2 );
  if N_S <> '0987654321          0987654321' then
    N_S := '';
  K_MVCBFileClose ( VFile2.UDCBFRoot );

end;

procedure TK_FormCMMain5.HRPreview1Click(Sender: TObject);
var
  ImgSlides : TN_UDCMSArray;
  ViewInd : Integer;
begin
  N_Dump1Str( 'TN_CMMain5Form1.HRPreview1Click start' );
  inherited;
  ImgSlides := nil;
  ViewInd := N_CM_MainForm.CMMGetMarkedSlidesArray( ImgSlides );
  if ViewInd = 0 then
    ImgSlides := Copy( K_CMCurVisSlidesArray )
  else
  begin
    with N_CM_MainForm.CMMCurFThumbsDGrid do
      ViewInd := DGMarkedList.IndexOf( Pointer(DGSelectedInd) );
    if ViewInd < 0 then ViewInd := 0;
  end;

//  if N_CM_MainForm.CMMGetMarkedSlidesArray( ImgSlides ) > 0 then
//  ViewInd := Integer(N_CM_MainForm.CMMCurFThumbsDGrid.DGMarkedList[0]);

  K_CMD4WHPNewPatientID := K_CMEDAccess.CurPatID;
  K_CMD4WHPNewProviderID := K_CMEDAccess.CurProvID;
  K_CMD4WHPNewLocationID := K_CMEDAccess.CurLocID;

//  K_CMCloseOnCurUICloseFlag := FALSE;
//  Self.Hide();      // Use Hide for quick
//  Self.Close();
{ ??? Leads to undefined error
  Self.Release(); //

  N_AppSkipEvents := TRUE; // !!!Disable events handlers in Rast1Frame
  Application.ProcessMessages; // for Self.Release Complit
  N_AppSkipEvents := FALSE;// !!!Enable events handlers in Rast1Frame
}
  with K_CMGetHPreviewForm() do
  begin
//    HPShowSlides( @K_CMCurVisSlidesArray[0],
//                  Length(K_CMCurVisSlidesArray), ViewInd, FALSE );
    Show();
    HPShowSlides( @ImgSlides[0],
                  Length(ImgSlides), ViewInd, FALSE );
    K_CMCloseOnCurUICloseFlag := FALSE;
    Self.Close();
    Repaint();
  end;

end;

procedure TK_FormCMMain5.FSRecovery1MItemClick(Sender: TObject);
begin
  K_CMFSRecovery1Dlg();
end;

procedure TK_FormCMMain5.TWAINTestClick(Sender: TObject);
begin
  with TK_FormCMTwainTest.Create( Application ) do
    ShowModal();
end;
{
procedure TK_FormCMMain5.SendMailClick(Sender: TObject);
var
  smtpSendMail: TIdSMTP;
  mesgMessage: TIdMessage;
  IdSSLIOHandlerSocket : TIdSSLIOHandlerSocket;
  IdSocksInfo : TIdSocksInfo;
begin
  smtpSendMail:= TIdSMTP.Create(Self);
  mesgMessage := TIdMessage.Create(Self);

  with mesgMessage do
  begin
    Clear;
    From.Text := 'kovalev_ad@list.ru';
    Recipients.Add.Text := 'kovalev_ad@list.ru';
    Subject := 'test Indy SMTP client';
    Body.Add('test Indy SMTP client');
    Body.Add('test Indy SMTP client');
    Body.Add('test Indy SMTP client');
//      Body.Assign(memoMsg.Lines);
  end;

  with smtpSendMail do
  begin
//    Host := 'smtp.list.ru';
//    Port := 465;
//    AuthenticationType := atLogin;
//    Username := 'kovalev_ad';
//    Password := '362362';
    IdSocksInfo := TIdSocksInfo.Create(Self);
    IdSocksInfo.Authentication:=saUsernamePassword;
    IdSocksInfo.Username:='kovalev_ad';
    IdSocksInfo.Password:='362362';
    IdSocksInfo.Port:=465;
    IdSocksInfo.Version:=svNoSocks;

    IdSSLIOHandlerSocket := TIdSSLIOHandlerSocket.Create(Self);
    IdSSLIOHandlerSocket.SocksInfo:=IdSocksInfo;
    IdSSLIOHandlerSocket.SSLOptions.Method:=sslvTLSv1;
//    IdSSLIOHandlerSocket.SSLOptions.Method:=sslvSSLv3;

    IOHandler:= IdSSLIOHandlerSocket;
    Host := 'smtp.list.ru';
    Port := 465;
    AuthenticationType := atLogin;
    IdSSLIOHandlerSocket.UseTLS := utUseImplicitTLS;


    try
      Connect;
      Send(mesgMessage);
    finally if Connected then Disconnect; end;
  end;
  IdSocksInfo.Free();
  IdSSLIOHandlerSocket.Free();
  smtpSendMail.Free();
  mesgMessage.Free();
end;
}
procedure TK_FormCMMain5.TWAINASettingsClick(Sender: TObject);
begin
  with TK_FormCMTwainASettings.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    ShowModal()
  end;

end;


procedure TK_FormCMMain5.SlidesFilterFrameCmBFilterAttrsChange(
  Sender: TObject);
begin
  inherited;
  SlidesFilterFrame.CmBFilterAttrsChange(Sender);

end;

function TK_FormCMMain5.TestDumpFiles1( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  i, j, k : Integer;
  PrevD, CurD : Double;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  N_s := APathName + AFileName;
  if K_GetFileAge( N_s ) < EncodeDate(2016,1,1) then Exit;
  K_CMEDAccess.TmpStrings.LoadFromFile( N_s );
  PrevD := 0;
  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin
    j := Pos( 'changed from ClientTime=', K_CMEDAccess.TmpStrings[i] );
    if j = 0 then Continue;
    N_s1 := Copy( N_s, Length(BPath) + 1, 1000);
    N_s1[21] := '=';
    k := PosEx( '\', N_s1, 25 );
    N_s1[k] := '=';

    N_s2 := Copy( K_CMEDAccess.TmpStrings[i], j + 23, 100 );

    N_s1 := N_s1 + N_s2;
    k := PosEx( ' ', N_s2, 39);
    CurD := StrToFloat( Copy( N_s2, 39, k - 39 ) );
    if (PrevD <> 0) and (Abs(PrevD - CurD) > 100) then
      N_s1 := N_s1 + '###';
    PrevD := CurD;
    N_SL.Add( N_s1 );
  end;
end;

function TK_FormCMMain5.TestDumpFiles2( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  i : Integer;
  FDate : TDAteTime;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  N_s := APathName + AFileName;
  FDate := K_GetFileAge( N_s );
  if (FDate < EncodeDate(2014,1,1)) or (FDate >= EncodeDate(2015,1,1)) then Exit;
  K_CMEDAccess.TmpStrings.LoadFromFile( N_s );
  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin
    if 0 = Pos( '*** Active Instances Dump ***', K_CMEDAccess.TmpStrings[i] ) then Continue;
    N_s1 := Copy( N_s, Length(BPath) + 1, 1000);
    N_SL.Add( N_s1 );
    break;
  end;
end;

function TK_FormCMMain5.TestDumpFiles3( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  i, j : Integer;
  FDate : TDAteTime;

begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  N_s := APathName + AFileName;
  FDate := K_GetFileAge( N_s );
  if (FDate < EncodeDate(2017,2,20))then Exit;
  K_CMEDAccess.TmpStrings.LoadFromFile( N_s );
  j := 0;
  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin
    if j = 0 then
    begin
      j := Pos( 'changed from ClientTime=', K_CMEDAccess.TmpStrings[i] );
      if j = 0 then Continue;
      N_s2 := Copy( K_CMEDAccess.TmpStrings[i], j + 23, 100 );
    end;

    if 0 = Pos( 'DB>> Use existed ', K_CMEDAccess.TmpStrings[i] ) then Continue;

    N_s1 := Copy( N_s, Length(BPath) + 1, 1000);
    N_s1[21] := '=';
    j := PosEx( '\', N_s1, 25 );
    N_s1[j] := '=';

    N_SL.Add( N_s1 + N_s2 );
    break;
  end;
end;

function TK_FormCMMain5.TestDumpFiles31( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  i, j : Integer;
  FDate : TDAteTime;

begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  N_s := APathName + AFileName;
  FDate := K_GetFileAge( N_s );
//  if (FDate < EncodeDate(2016,1,1))then Exit;
//  if (FDate < EncodeDate(2015,1,1)) or (FDate >= EncodeDate(2016,1,1)) then Exit;
  if (FDate < EncodeDate(2017,7,18))then Exit;
  K_CMEDAccess.TmpStrings.LoadFromFile( N_s );
  j := 0;

  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin
    if j = 0 then
    begin
      j := Pos( 'changed from ClientTime=', K_CMEDAccess.TmpStrings[i] );
      if j = 0 then Continue;
      N_s2 := Copy( K_CMEDAccess.TmpStrings[i], j + 23, 100 );
    end;

    if 0 = Pos( 'Deadlock detected', K_CMEDAccess.TmpStrings[i] ) then Continue;

    N_s1 := Copy( N_s, Length(BPath) + 1, 1000);
    N_s1[21] := '=';
    j := PosEx( '\', N_s1, 25 );
    N_s1[j] := '=';

    N_SL.Add( N_s1 + N_s2 );
    break;
  end;
end;

function TK_FormCMMain5.TestDumpFiles4( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  i, j : Integer;
  FDate : TDAteTime;
  FLag : Boolean;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  N_s := APathName + AFileName;
  FDate := K_GetFileAge( N_s );
//  if (FDate < EncodeDate(2017,2,20))then Exit;
  if (FDate < EncodeDate(2017,7,18))then Exit;
  K_CMEDAccess.TmpStrings.LoadFromFile( N_s );
  j := 0;
  FLag := FALSE;
  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin
    if j = 0 then
    begin
      j := Pos( 'changed from ClientTime=', K_CMEDAccess.TmpStrings[i] );
      if j = 0 then Continue;
      N_s2 := Copy( K_CMEDAccess.TmpStrings[i], j + 23, 100 );
    end;

    if FLag then
    begin
      if (0 = Pos( 'DB>> Unlock Objects', K_CMEDAccess.TmpStrings[i] )) then
      begin
        FLag := FALSE;
        Continue;
      end;
    end
    else
    begin
      if 0 = Pos( 'DB>> Active Instance. Set Current Context ActRTID', K_CMEDAccess.TmpStrings[i] ) then Continue;
      if not FLag then
      begin
        FLag := TRUE;
        Continue;
      end;
    end;

    N_s1 := Copy( N_s, Length(BPath) + 1, 1000);
    N_s1[21] := '=';
    j := PosEx( '\', N_s1, 25 );
    N_s1[j] := '=';

    N_SL.Add( N_s1 + N_s2 );
    break;
  end;
end;

function TK_FormCMMain5.TestDumpFiles41( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  i, j : Integer;
  FDate : TDAteTime;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  N_s := APathName + AFileName;
  FDate := K_GetFileAge( N_s );
  if (FDate < EncodeDate(2017,2,20))then Exit;
//  if (FDate < EncodeDate(2016,11,1))then Exit;
  K_CMEDAccess.TmpStrings.LoadFromFile( N_s );
  j := 0;
  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin
    if j = 0 then
    begin
      j := Pos( 'changed from ClientTime=', K_CMEDAccess.TmpStrings[i] );
      if j = 0 then Continue;
      N_s2 := Copy( K_CMEDAccess.TmpStrings[i], j + 23, 100 );
    end;

    if 0 = Pos( '*** Active Instances Dump ***', K_CMEDAccess.TmpStrings[i] ) then Continue;
//    if 0 = Pos( 'PatID=316146', K_CMEDAccess.TmpStrings[i] ) then Continue;

    N_s1 := Copy( N_s, Length(BPath) + 1, 1000);
    N_s1[21] := '=';
    j := PosEx( '\', N_s1, 25 );
    N_s1[j] := '=';

    N_SL.Add( N_s1 + N_s2 );
    break;
  end;
end;

function TK_FormCMMain5.TestDumpFiles5( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  FDate : TDAteTime;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  N_s := APathName + AFileName;
  FDate := K_GetFileAge( N_s );
  if (FDate < EncodeDate(2017,2,20))then Exit;
  if 0 = Pos('Chadstone.img', N_s ) then Exit;
  N_s1 := Copy( N_s, Length(BPath) + 1, 1000);
  N_SL.Add( N_s1 );
end;

function TK_FormCMMain5.TestDumpFiles51( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  FDate : TDAteTime;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  N_s := APathName + AFileName;
  FDate := K_GetFileAge( N_s );
  if (FDate < EncodeDate(2017,7,18))then Exit;
  N_s1 := Copy( N_s, Length(BPath) + 1, 1000);
  N_SL.Add( N_s1 );
end;

function TK_FormCMMain5.TestDumpFiles52( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
  i, j : Integer;
  FDate : TDAteTime;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  N_s := APathName + AFileName;
  FDate := K_GetFileAge( N_s );
  if (FDate < EncodeDate(2017,7,18))then Exit;
//  if (FDate < EncodeDate(2016,11,1))then Exit;
  K_CMEDAccess.TmpStrings.LoadFromFile( N_s );
  j := 0;
  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin
    if j = 0 then
    begin
      j := Pos( 'changed from ClientTime=', K_CMEDAccess.TmpStrings[i] );
      if j = 0 then Continue;
      N_s2 := Copy( K_CMEDAccess.TmpStrings[i], j + 23, 100 );
    end;

    if 0 = Pos( 'Reconnect Try=', K_CMEDAccess.TmpStrings[i] ) then Continue;
//    if 0 = Pos( 'PatID=316146', K_CMEDAccess.TmpStrings[i] ) then Continue;

    N_s1 := Copy( N_s, Length(BPath) + 1, 1000);
    N_s1[21] := '=';
    j := PosEx( '\', N_s1, 25 );
    N_s1[j] := '=';

    N_SL.Add( N_s1 + N_s2 );
    break;
  end;
end;

function TK_FormCMMain5.TestDumpFiles20200925( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
var
//  i : Integer;
i, j : Integer;
//  FDate : TDAteTime;
begin
  Result := K_tucOK;
  if AFileName = '' then Exit;
  N_s := APathName + AFileName;
//  FDate := K_GetFileAge( N_s );
//  if (FDate < EncodeDate(2017,7,18))then Exit;
//  if (FDate < EncodeDate(2016,11,1))then Exit;
  K_CMEDAccess.TmpStrings.LoadFromFile( N_s );
  j := 0;
  for i := 0 to K_CMEDAccess.TmpStrings.Count - 1 do
  begin

    if 0 = Pos( 'ClientScan.SCGetTaskSlides Open error="stream open error"', K_CMEDAccess.TmpStrings[i] ) then Continue;
    if j = 0 then
      N_SL.Add( '     ' + N_s );
    N_s1 := IntToStr(i + 1) + ' ';
    N_SL.Add( N_s1  );
    Inc(j);
  end;
  if j = 0 then
    N_SL.Add( '     ' + N_s );
end;

procedure TK_FormCMMain5.Loganal1Click(Sender: TObject);
var
  SavedCursor: TCursor;

begin
//  BPath := 'C:\Delphi_prj_new\DTmp\ErrLogs\2016\2016-12-19_Karpenkov_FW Ongoing CMS issues\CMS Log Files\';
  BPath := 'C:\Delphi_prj_new\DTmp\ErrLogs\2017\2017-02-27_NDC crash problem\LogFiles\';
  BPath := 'D:\Delphi_prj_new\DTmp\ErrLogs\DT\DT00020521\NDC Log Files 1-20170719T074542Z-001\NDC Log Files 1\';
  BPath := 'D:\Delphi_prj_new\DTmp\ErrLogs\2020\2020-09-17_CMScan_problems_NDC\NDC009OPG001\';
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

// Select all log files time syncronization with DB server (lines where time delta is shift marked with ###)
// '=' divider for Excel
//  N_SL.Clear;
//  K_ScanFilesTree( BPath, TestDumpFiles1, '*errlog.txt'  );
//  N_SL.SaveToFile(K_ExpandFileName('(#CMSLogFiles#)LogsAnal.txt'));

// Select log files for CMS aborted by ActiveInstancesTable errors
// '\' divider for Excel
//  N_SL.Clear;
//  K_ScanFilesTree( BPath, TestDumpFiles2, '*errlog.txt'  );
//  N_SL.SaveToFile(K_ExpandFileName('(#CMSLogFiles#)LogsActInsError.txt'));
{

// Select log files for CMS user by name
// '=' divider for Excel
  N_SL.Clear;
  K_ScanFilesTree( BPath, TestDumpFiles5, '*errlog.txt'  );
  N_SL.SaveToFile(BPath + 'User.txt');


// Select log files for CMS which are have Lost RTID error
// '=' divider for Excel
  N_SL.Clear;
  K_ScanFilesTree( BPath, TestDumpFiles41, '*errlog.txt'  );
  N_SL.SaveToFile(BPath + 'LostRTID.txt');

// Select log files for CMS which are have Lost RTID error
// in prev logs C:\Delphi_prj_new\DTmp\ErrLogs\2016\2016-12-19_Karpenkov_FW Ongoing CMS issues\CMS Log Files\
// '=' divider for Excel
  N_SL.Clear;
  K_ScanFilesTree( BPath, TestDumpFiles41, '*errlog.txt'  );
  N_SL.SaveToFile(BPath + 'LostRTID2016.txt');


// Select log files for CMS which are have PatID=316146 error
// '=' divider for Excel
  N_SL.Clear;
  K_ScanFilesTree( BPath, TestDumpFiles41, '*errlog.txt'  );
  N_SL.SaveToFile(BPath + 'Pt316146.txt');
}
// Select log files for CMS whith DeadLock
// '=' divider for Excel
//  N_SL.Clear;
//  K_ScanFilesTree( BPath, TestDumpFiles31, '*errlog.txt'  );
//  N_SL.SaveToFile(K_ExpandFileName(BPath + 'LogsDeadlock.txt'));
//  N_SL.SaveToFile(K_ExpandFileName('(#CMSLogFiles#)LogsDeadlock.txt'));
{
// Select log files for CMS which aborted other while registed in ActiveInstancesTable
// '=' divider for Excel
  N_SL.Clear;
  K_ScanFilesTree( BPath, TestDumpFiles3, '*errlog.txt'  );
  N_SL.SaveToFile(BPath + 'LogsUseExisted.txt');
//N_SL.SaveToFile(K_ExpandFileName('(#CMSLogFiles#)LogsUseExisted.txt'));
{
// Select log files for CMS which aborted other while clear ActiveInstancesTable when patient is changed
// '=' divider for Excel
  N_SL.Clear;
  K_ScanFilesTree( BPath, TestDumpFiles4, '*errlog.txt'  );
  N_SL.SaveToFile(BPath + 'LogsFreeExisted.txt');
//N_SL.SaveToFile(K_ExpandFileName('(#CMSLogFiles#)LogsFreeExisted.txt'));
//N_SL.SaveToFile(K_ExpandFileName('(#CMSLogFiles#)LogsUseExisted.txt'));
{}

// Select log files for CMS which are have Lost RTID error
// '=' divider for Excel
//  N_SL.Clear;
//  K_ScanFilesTree( BPath, TestDumpFiles41, '*errlog.txt'  );
//  N_SL.SaveToFile(BPath + 'LostRTID1.txt');

// Select log files for CMS which work 2017-07-18
// '=' divider for Excel
//  N_SL.Clear;
//  K_ScanFilesTree( BPath, TestDumpFiles51, '*errlog.txt'  );
//  N_SL.SaveToFile(BPath + 'Wrk20170718.txt');


// Select log files for CMS which work 2017-07-18 and have "Reconnect Try="
// '=' divider for Excel
//N_SL.Clear;
//K_ScanFilesTree( BPath, TestDumpFiles52, '*errlog.txt'  );
//N_SL.SaveToFile(BPath + 'Reconnect20170718.txt');

// Select CMSLog which containes ClientScan stream error
  K_ScanFilesTree( BPath, TestDumpFiles20200925, 'CMSLog.txt' );
  N_SL.SaveToFile(BPath + 'ClientScanStreamError20200925(1).txt');

  Screen.Cursor := SavedCursor;
  N_SL.Clear;
end;

//************************************************ TK_FormCMMain5.FormClose ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TK_FormCMMain5.StringsAnalises1Click(Sender: TObject);
begin
  Application.CreateForm(TK_FormAnalisesStrings, K_FormAnalisesStrings);
  K_FormAnalisesStrings.ShowModal;
end;
{
procedure TK_FormCMMain5.WMQueryEndSessionvar(
  var Message: TWMQueryEndSession);
begin
//
end;
}
procedure TK_FormCMMain5.CloseTabProc(Sender: TObject);
  function VisiblePageCount: integer;
  var
    i: integer;
  begin
    Result := 0;

    for i := 0 to pgcViewerHolder.PageCount - 1 do
      if pgcViewerHolder.Pages[i].TabVisible then
        inc(Result);
  end;

var
  ViewerPage: TViewerTabSheet;
begin
  ViewerPage := (Sender as TViewerTabSheet);

  LockWindowUpdate(Self.Handle);

  try
    if (ViewerPage = FDICOMViewerHolder) then
    begin
      FDICOMViewerHolder.TabVisible := False;
      FDICOMViewerHolder.Visible := True;
      FreeAndNil(DICOMViewer);
    end;
  finally
    tsSlidesViewer.TabVisible := not (VisiblePageCount < 2);
    tsSlidesViewer.Visible := True;
    pgcViewerHolder.ActivePage := tsSlidesViewer;

    LockWindowUpdate(0);
  end;
end;

end.
