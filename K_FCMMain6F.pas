unit K_FCMMain6F;
// Main CMS application Form

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, Menus, ToolWin, ActnList, Buttons, StdCtrls, ImgList,
  K_Types, K_UDT1,  K_FrCMSlideFilter,   K_CM0,
  N_Types, N_Lib1,  N_BaseF, {N_MainFFr,}  N_Gra2,
  N_CM1,   N_CM2,   N_DGrid, N_CMREd3Fr, N_Rast1Fr;


type TN_RebuildViewFlags = set of ( rvfSkipThumbRebuild, rvfAllViewRebuild );
type TN_EdFrLayout = ( eflNotDef, eflOne, eflTwoHSp, eflTwoVSp,
                       eflFourHSp, eflFourVSp, eflNine );
var  N_EdFrLayoutCounts : array [0..Ord(eflNine)] of Integer = (0, 1, 2, 2, 4, 4, 9);

type TK_FormCMMain6 = class( TN_BaseForm ) //***** Main CMS application Form
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
    N3: TMenuItem;
    ZoomInandZoomOut1: TMenuItem;
    Panning1: TMenuItem;
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
    ToolButton26: TToolButton;
    ToolButton27: TToolButton;
    ToolButton28: TToolButton;
    ToolButton29: TToolButton;
    ToolButton30: TToolButton;
    ToolButton31: TToolButton;
    ToolButton32: TToolButton;
    ToolButton33: TToolButton;
    Bot2Panel: TPanel;
    EdFramesPanel: TPanel;
    ChangeCurrentDBPatientProviderLocationContext1: TMenuItem;
    ToolButton18: TToolButton;
    AllTopToolbars2: TMenuItem;
    AlterationsToolbar1: TMenuItem;
    PositiveNegative1: TMenuItem;
    SharpenSmoothen1: TMenuItem;
    NoiseReduction1: TMenuItem;
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
    Deteteselected1: TMenuItem;
    Dummy1: TMenuItem;
    BrightnessContrastGamma1: TMenuItem;
    ToolButton35: TToolButton;
    ToolButtonEmboss: TToolButton;
    Rectangle1: TMenuItem;
    Ellipse1: TMenuItem;
    Arrow1: TMenuItem;
    EmbossAttributes1: TMenuItem;
    Service: TMenuItem;
    ViewEditProtocol2: TMenuItem;
    ViewEditServiceFlags2: TMenuItem;
    ViewEditStatisticsTable2: TMenuItem;
    SetVideoCodec2: TMenuItem;
    Point2: TMenuItem;
    Duplicate1: TMenuItem;
    ImportfromClipboard1: TMenuItem;
    N12: TMenuItem;
    ExportmediatoClipboard1: TMenuItem;
    FreeHand1: TMenuItem;
    N19: TMenuItem;
    Histogramm1: TMenuItem;
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
    ClearAllSlidesInExtDBforAllPatients1: TMenuItem;
    AddCurrentSlidesToExtDBforcurrentPatient1: TMenuItem;
    ListSlidesInExtDBforCurrentPatient1: TMenuItem;
    ClearLockedSlidesfromDB1: TMenuItem;
    AbortCMSbyexception1: TMenuItem;
    CheckFileinDebugger1: TMenuItem;
    ConvertSlidetoGray1: TMenuItem;
    N23: TMenuItem;
    EmbossAttributes2: TMenuItem;
    NoiseReductionAttributes1: TMenuItem;
    ViewSlideColor1: TMenuItem;
    CreateClonesfromgivenFile1: TMenuItem;
    SearchProjectFormschangedbyDelphi20101: TMenuItem;
    DICOMTest1: TMenuItem;
    estEd3FrameinSeparateWindow1: TMenuItem;
    ransferfilesbetweenLocations2: TMenuItem;
    ScheduleFilesTransfer1: TMenuItem;
    BuildDemoDistr: TMenuItem;
    SynchronizeDPRFilesUses1: TMenuItem;
    Debug2: TMenuItem;
    CreateDemoEXEDistributivefromrunningCMSuitDemoexe1: TMenuItem;
    N24: TMenuItem;
    ArchiveNew1: TMenuItem;
    Changeaccountdetails1: TMenuItem;
    FilesSynchronizationDetails1: TMenuItem;
    ChangeHostLocation1: TMenuItem;
    N25: TMenuItem;
    N26: TMenuItem;
    DebMPAction11: TMenuItem;
    DebMPAction12: TMenuItem;
    Reports1: TMenuItem;
    Showmarkedasdeleted1: TMenuItem;
    Restoremarkedasdeleted1: TMenuItem;
    Deletedobjectshandling2: TMenuItem;
    Left2Panel: TPanel;
    ThumbsPnSplitter: TSplitter;
    ThumbsRFrame: TN_Rast1Frame;
    SlidesFilterFrame: TK_FrameCMSlideFilter;
    Top2Panel: TPanel;
    CaptToolBar: TToolBar;
    ViewportsToolBar: TToolBar;
    MainNIcons40N: TImageList;
    MainNIcons40H: TImageList;
    MainNIcons18N: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    MediaToolBar: TToolBar;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton19: TToolButton;
    ToolBar2: TToolBar;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    ToolButton23: TToolButton;
    MeasurePUMenu: TPopupMenu;
    Measureline1: TMenuItem;
    Angle1: TMenuItem;
    MeasureFreeAngle1: TMenuItem;
    CalibrateImage2: TMenuItem;
    ToolButton34: TToolButton;
    TextDrawPUMenu: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MultiLine1: TMenuItem;
    Arrow2: TMenuItem;
    Ellipse2: TMenuItem;
    Rectangle2: TMenuItem;
    MagnifyRegion1: TMenuItem;
    ActionList1: TActionList;
    aObjMeasurements: TAction;
    MainNIcons18D: TImageList;
    MainNIcons40D: TImageList;

    procedure FormShow   ( Sender: TObject );
    procedure FormClose  ( Sender: TObject; var Action: TCloseAction ); override;
// Real Handlers Wrappers - saved to minimise onShow code
    procedure CMMFDisableActions( Sender: TObject );
    procedure DICOMTest1Click          ( Sender: TObject );
//    procedure ShowNVTreeForm1Click(Sender: TObject);
// Self Interface Handlers
    procedure TextDrawPUMenuPopup(Sender: TObject);
    procedure MeasurePUMenuPopup(Sender: TObject);
    procedure aObjMeasurementsExecute(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MultiLine1Click(Sender: TObject);
    procedure MagnifyRegion1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject); override;
  private

  public
    CMMFThumbsDGrid:    TN_DGridArbMatr; // DGrid for handling Thumbnails in ThumbsRFrame
//    CMMFThumbsRFrameWidth : Integer;
//    CMMFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails


    procedure MenuItemsDisableProc();
    procedure CMMFUpdateToolBars    ();

end; // type TN_CMMain5Form = class( TN_BaseForm )

    //*********** Global Procedures  *****************************

implementation
uses Types, IniFiles, math, StrUtils,
     K_CLib0, K_UDC, K_UDConst, K_UDT2, K_Script1, K_FrRaEdit, K_FRunDFPLScript,
     K_Arch,  K_VFunc, K_FCMSIsodensity, K_FCMSFPathChange, K_FCMAltShiftMEnter,
     K_FCMSlideIcon,
     N_ClassRef, N_Lib0, N_Lib2, N_GCont, N_SGComp, // N_CMExtDLL,
     N_Gra0, N_Gra1, N_CMAboutF, N_EdParF, // N_TstC1, N_Tst1, N_TstF, N_Deb1,
     N_CompBase, N_Comp1, N_EdStrF, N_CompCL,
     N_CMResF, N_ButtonsF, N_CMMain5F; // N_CMDLLTestF,
{$R *.dfm}

    //***********  TN_CMMain5Form event Hadlers  *****

//************************************************* TN_CMMain5Form.FormShow ***
// Self initialization
//
//     Parameters
// Sender    - Event Sender
//
// OnShow Self handler
//
procedure TK_FormCMMain6.FormShow( Sender: TObject );
//var
//  WStr : string;
//  MaxRectStr : string;
begin
  N_Dump1Str( 'Start MainForm6 OnShow Handler' );
  Self.Caption := N_CM_MainForm.Caption;

  DoubleBuffered := True;
  Left1Panel.DoubleBuffered := True;
  Bot2Panel.DoubleBuffered := True;
  Top2Panel.DoubleBuffered := True;
  EdFramesPanel.DoubleBuffered := True;
  CaptToolBar.DoubleBuffered := True;
  ToolButtonEmboss.ImageIndex   := 37;

  //*** Form.WindowProc should be changed for processing Arrow and Tab keys
  WindowProc := OwnWndProc;


  CMMFThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, N_CM_MainForm.CMMFGetThumbSize );
  with CMMFThumbsDGrid do
  begin
    DGEdges := Rect( 2, 2, 2, 2 );
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
  end; // with CMMFThumbsDGrid do
  N_CM_MainForm.CMMCurFMainForm := Self;
  N_CM_MainForm.CMMCurFStatusBar := StatusBar;
  N_CM_MainForm.CMMCurCaptToolBar := CaptToolBar;
  N_CM_MainForm.CMMCurFThumbsDGrid := CMMFThumbsDGrid;
  N_CM_MainForm.CMMCurFThumbsRFrame := ThumbsRFrame;
  N_CM_MainForm.CMMCurFThumbsResizeTControl := Left2Panel;
  N_CM_MainForm.CMMCurChangeToolBarsVisibility := CMMFUpdateToolBars;
  N_CM_MainForm.CMMCurMenuItemsDisableProc := MenuItemsDisableProc;
  N_CM_MainForm.CMMCurSlideFilterFrame := SlidesFilterFrame;
//  N_CM_MainForm.CMMCurSmallIcons:= MainNIcons18N;
  N_CMResForm.MainIcons18.Assign( MainNIcons18N );
  K_CMDynIconsSInd := N_CMResForm.MainIcons18.Count;
  N_CM_MainForm.CMMCurBigIcons:= MainNIcons40N;
  N_CM_MainForm.CMMCurMainMenu := MainMenu1;
  N_CM_MainForm.CMMCurMainMenu.Images := N_CMResForm.MainIcons18;


//  Init Controls Context
  Self.OnKeyDown := N_CM_MainForm.FormKeyDown;

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
  ThumbsRFrame.RFDumpEvents := True;

  N_Dump1Str( Format( 'MainForm6: FormSize=(%d,%d) ClientSize=(%d,%d) BFMinBRPanelLT=(%d,%d)',
                [Width,Height,ClientWidth,ClientHeight,BFMinBRPanel.Left,BFMinBRPanel.Top] ));

{
  if not K_CMDesignModeFlag then // always maximize MainForm in not Design mode
  begin
    with N_AppWAR do // MaxRectStr should be in MemIni format (Top, Left, Width, Height)
      MaxRectStr := Format( '%d %d %d %d', [Left, Top, Right-Left+1, Bottom-Top+1] );

    // Overwrite saved size and position, alway use whole N_AppWAR
    BFSectionName := 'N_Forms';
    BFSelfName := 'N_CMMain5Form';
    N_StringToMemIni( BFSectionName, BFSelfName, MaxRectStr );
  end; // if not K_CMDesignModeFlag then // always maximize MainForm in not Design mode

  BaseFormInit( nil, '', [] );
  WStr := N_CurMemIni.ReadString( 'N_Forms', Name, '!Absent!' );
  if WStr = '!Absent!' then
  begin
    if N_NewBaseForm then
      BFChangeSelfSize( N_RectSize( BFFormMaxRect ) )
    else
      with N_CM_MainForm do
        CMMSetWindowState( Handle, 2 );
  end; // if WStr = '!Absent!' then // Maximize if launch for first time
}
  BaseFormInit( nil, '', [rspfPrimMonWAR,rspfMaximize], [rspfAppWAR,rspfShiftAll] );


  if K_CMEDAccess <> nil then
  begin // Archive Initialization is OK (not Failed)

    with SlidesFilterFrame do
    begin
      SFPFilterAttrs := @K_CMCurSlideFilterAttrs;
      SFChangeNotify := N_CM_MainForm.CMMFRebuildVisSlides;
      SFInit();
    end; // with SlidesFilterFrame do


  //  ThumbsRFrame.Width := CMMFThumbsRFrWidth
  //  Realign();
  //  Application.ProcessMessages;

    N_CM_MainForm.CMMInitThumbFrameTexts(); // Should be called after contexts init
    N_CM_MainForm.CMMFRebuildVisSlides();

//    ThumbsRFrame.Width := CMMFThumbsRFrameWidth;
    ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events

  end; // if K_CMEDAccess <> nil then

  N_Dump1Str( '***** Run process: Finish MainForm6 OnShow Handler' );
end; // procedure TN_CMMain5Form.FormShow

//************************************************ TN_CMMain5Form.FormClose ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TK_FormCMMain6.FormClose( Sender: TObject; var Action: TCloseAction );
begin
// To prevent actions in K_FormCMSIsodensity.FormClose
  N_CM_MainForm.CMMCurFThumbsDGrid := nil;
  CMMFThumbsDGrid.Free;
  ThumbsRFrame.RFFreeObjects();

  inherited;
//  K_CMEDAccess.SkipProcessMessages := TRUE;
end; // procedure TN_CMMain5Form.FormClose

//************************************* TK_FormCMMain6.CMMFDisableActions ***
// Disable needed Actions by current Application state
//
//     Parameters
// Sender - Event Sender
//
// Used as OnClick handler for All MainMenu top level Items and should be
// called after all other code, that may affect list of disabled Actions
//
procedure TK_FormCMMain6.CMMFDisableActions( Sender: TObject );
begin
  N_CM_MainForm.CMMFDisableActions( Sender );
end; // end of procedure TK_FormCMMain6.CMMFDisableActions

    //***********  TN_CMMain5Form Public methods  *****

//************************************* TK_FormCMMain6.MenuItemsDisableProc ***
// Disabled/Enabled Menu Items
//
procedure TK_FormCMMain6.MenuItemsDisableProc();
begin
  Tools1.Enabled := K_uarModify in K_CMCurUserAccessRights;
  Deletedobjectshandling2.Visible := K_CMEnterpriseModeFlag and K_CMGAModeFlag;
  Capture1.Enabled := K_uarCapture in K_CMCurUserAccessRights;
end; // end of procedure TK_FormCMMain6.MenuItemsDisableProc

//*************************************** TN_CMMain5Form.CMMFUpdateToolBars ***
// Update ToolBars visibility by appropriate Actions state
//
procedure TK_FormCMMain6.CMMFUpdateToolBars();
begin
  Right1Panel.Visible := N_CMResForm.aVTBAlterations.Checked;
{
  if N_CMResForm.aVTBAllTopToolbars.Checked then
  begin
    CaptToolBar.Visible := True;
    SysToolbar1.Visible := True;
    SysToolbar2.Visible := True;
    SlidesFilterFrame.Visible := True;
    ViewToolBar.Visible := True;
    Top2Panel.Visible   := True;
  end else
  begin
    CaptToolBar.Visible := False;
    SysToolbar1.Visible := False;
    SysToolbar2.Visible := False;
    SlidesFilterFrame.Visible := False;
    ViewToolBar.Visible := False;
    Top2Panel.Visible   := False;
  end;
}
end; // end of procedure TN_CMMain5Form.CMMFUpdateToolBars

procedure TK_FormCMMain6.DICOMTest1Click( Sender: TObject );
begin
  N_CM_MainForm.DICOMTest1Click( Sender );
end; // procedure TN_CMMain5Form.DICOMTest1Click
{
procedure TK_FormCMMain6.ShowNVTreeForm1Click(Sender: TObject);
begin
  inherited;
  N_CM_MainForm.MFFrame.aFormsNVtreeExecute(Sender);
end;
}
procedure TK_FormCMMain6.TextDrawPUMenuPopup(Sender: TObject);
begin
//  inherited;
end;

procedure TK_FormCMMain6.MeasurePUMenuPopup(Sender: TObject);
begin
//  inherited;
end;

procedure TK_FormCMMain6.aObjMeasurementsExecute(Sender: TObject);
begin
  with Mouse.CursorPos do
//    MeasurePUMenu.Popup( Max( 0, X - 140 ), Y + 20 );
    MeasurePUMenu.Popup( X, Y );
end;

procedure TK_FormCMMain6.MenuItem1Click(Sender: TObject);
begin
  N_CMResForm.aObjTextBox.OnExecute(N_CMResForm.aObjTextBox);
  ToolButton35.Action := N_CMResForm.aObjTextBox;
end;

procedure TK_FormCMMain6.MenuItem2Click(Sender: TObject);
begin
  N_CMResForm.aObjFreeHand.OnExecute(N_CMResForm.aObjFreeHand);
  ToolButton35.Action := N_CMResForm.aObjFreeHand;
end;

procedure TK_FormCMMain6.MultiLine1Click(Sender: TObject);
begin
  N_CMResForm.aObjPolyline.OnExecute(N_CMResForm.aObjPolyline);
  ToolButton35.Action := N_CMResForm.aObjPolyline;
end;

procedure TK_FormCMMain6.MagnifyRegion1Click(Sender: TObject);
begin
  N_CMResForm.aObjFLZEllipse.OnExecute(N_CMResForm.aObjFLZEllipse);
  ToolButton35.Action := N_CMResForm.aObjFLZEllipse;
end;

procedure TK_FormCMMain6.FormActivate(Sender: TObject);
begin
  inherited;
  N_CM_MainForm.FormActivate( Sender );
end;

end.
