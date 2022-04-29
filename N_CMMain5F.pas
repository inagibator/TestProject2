unit N_CMMain5F;
// Main CMS application Form
// Delphi can not set this Form height less than 587 !!!

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, Menus, ToolWin, ActnList, Buttons, StdCtrls, ImgList,
  Contnrs, Types,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_Types, K_UDT1,  K_FrCMSlideFilter,   K_CM0,
  N_Types, N_Lib1,  N_BaseF, {N_MainFFr,}  N_Gra2,
  N_CM1,   N_CM2,   N_DGrid, N_CMREd3Fr, N_Rast1Fr, System.Actions;


type TN_RebuildViewFlags = set of ( rvfSkipThumbRebuild, rvfAllViewRebuild );
type TN_EdFrLayout = ( eflNotDef, eflOne, eflTwoHSp, eflTwoVSp,
                       eflFourHSp, eflFourVSp, eflNine );
var  N_EdFrLayoutCounts : array [0..Ord(eflNine)] of Integer = (0, 1, 2, 2, 4, 4, 9);

type TK_CMUICurStateFlags = set of (
  uicsAllActsDisabled,
  uicsServActsEnable,
  uicsFilesHandlingInProcess,
  uicsActiveFrameIsEmpty,
  uicsSkipActiveSlideEdit
  );
type TK_CMUIEDFrLayoutFlags = set of (
  uieflSkipSwitchSelectedThumb,
  uieflSkipFramesResize
  );

type TK_CMSlideAddToOpenedFlags = set of (
  uieflSkipBWRules,      // Skip BW Rules while searching Frame to Open
  uieflSkipActiveEdFrame // Skip Current Active Frame to Open
);

type TN_CMMain5Form1 = class( TN_BaseForm )
    EdFramesPanel: TPanel;
    StatusBarTimer: TTimer;
    DragThumbsTimer: TTimer;
    ActTimer: TTimer;
    MeasureTextTimer: TTimer;

    MaintenancePopupMenu: TPopupMenu;
    ViewEditStatisticsTable1: TMenuItem;
    SetVideoCodec1: TMenuItem;
    ImageandVideoFilesHandling1: TMenuItem;
    aServXRAYStreamLine1: TMenuItem;
    DisplayallobjectsinEmFilesfolder1: TMenuItem;
    Showobjecthistory1: TMenuItem;
    aServSetPedalDelay1: TMenuItem;
    ConvertCMIorRECDtoBMP1: TMenuItem;
    ImportDataafterConversion1: TMenuItem;
    BinaryDumpMode1: TMenuItem;
    N20: TMenuItem;
    ScheduleFilesTransfer2: TMenuItem;
    ransferfilesbetweenLocations1: TMenuItem;
    Deletedobjectshandling1: TMenuItem;
    Mediaobjectsintegritycheck1: TMenuItem;
    Databaserecovery1: TMenuItem;

    MainActions: TActionList;
    aServDisableActions: TAction;
    aOpenMainForm6: TAction;
    aOpenMainForm5: TAction;
    aServShowEnvStrings1: TMenuItem;
    RemoteClientSetup1: TMenuItem;
    ScheduleFilesTransfer1: TMenuItem;
    Setlogfilespath1: TMenuItem;
    AloneModeSetup1: TMenuItem;
    ExportData1: TMenuItem;
    ImportData1: TMenuItem;

    procedure FormActivate(Sender: TObject); override;
    procedure FormShow    ( Sender: TObject );
    procedure FormClose   ( Sender: TObject; var Action: TCloseAction ); override;
    procedure CMMEdFramesPanelResize      ( Sender: TObject );
    procedure CMMFDisableActions       ( Sender: TObject );
    procedure EdFramesContextPopup     ( Sender: TObject; MousePos: TPoint; var Handled: Boolean );
    procedure ThumbsRFrameContextPopup ( Sender: TObject; MousePos: TPoint; var Handled: Boolean );
    procedure ThumbsRFrameDblClick     ( Sender: TObject );
    procedure ThumbsRFrameEndDrag      ( Sender, Target: TObject; X, Y: Integer );
    procedure StatusBarTimerTimer      ( Sender: TObject );
    procedure ActTimerTimer            ( Sender: TObject );
    procedure DragThumbsTimerTimer     ( Sender: TObject );
    procedure MeasureTextTimerTimer    ( Sender: TObject );
    procedure FormKeyDown              ( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure FormKeyPress             ( Sender: TObject; var Key: Char );
    procedure DICOMTest1Click          ( Sender: TObject );
    procedure SearchProjectFormsClick  ( Sender: TObject );
    procedure aEdFrameStudyOnPopup     ( Sender: TObject );
    procedure TestEd3FrameClick        ( Sender: TObject );
    procedure MaintenancePopupMenuPopup( Sender: TObject );
//    procedure ShowNVTreeForm1Click     ( Sender: TObject );
    procedure aOpenMainForm6Execute    ( Sender: TObject );
    procedure aShowNewGUIClick         ( Sender: TObject );
    procedure aOpenMainForm5Execute(Sender: TObject);
  private
    CMMWSSavedCursor : TCursor;
    CMMWSSavedMessage: string;
//    CMMShowCloseApplicationDlgForm : TForm;
//    CMMServAction : TAction;         // Service Action Reference for Auto Activation during Application Start

    procedure CMMFrameWMKeyDown ( var AWMKey: TWMKey );
  public
//    CMMFThumbsDGrid:    TN_DGridArbMatr; // DGrid for handling Thumbnails in ThumbsRFrame
    CMMFDrawSlideObj: TN_CMDrawSlideObj; // Object with Attributes for Drawing Thumbnails
    CMMFEdFrames:    TN_CMREdit3FrArray; // Editor Frames
    CMMFActiveEdFrame: TN_CMREdit3Frame; // Active Editor Frame
    CMMFEdFrLayout:       TN_EdFrLayout; // Editor Frames Layout
    CMMEdFramePopUpMenu:     TPopupMenu; // Editor Frame default PopUpMenu

    CMMFNumVisEdFrames:   integer;   // Number of visible Editor Frames
    CMMFNumAllEdFrames:   integer;   // Number of All Created Editor Frames

    CMMFEdFrSplitterMain: TSplitter; // EdFrames Pairs or single Slitter
    CMMFEdFrSplitter1:    TSplitter; // Slitter inside CMMFEdFrPanel1 (Top or Left EdFrames Pair Panel)
    CMMFEdFrSplitter2:    TSplitter; // Slitter inside CMMFEdFrPanel2 (Bottom or Right EdFrames Pair Panel)
    CMMFEdFrPanel1:          TPanel; // Top or Left EdFrames Pair Panel
    CMMFEdFrPanel2:          TPanel; // Bottom or Right EdFrames Pair Panel

    CMMFSplitterMainCoef:     float; // CMMFEdFrSplitterMain Coef in (0-1) range
    CMMFSplitter1Coef:        float; // CMMFEdFrSplitter1 Coef in (0-1) range
    CMMFSplitter2Coef:        float; // CMMFEdFrSplitter2 Coef in (0-1) range
    CMMFSplittersSize:      integer; // Splitters Size in Pixels between Editor Frames
    CMMEdVEMode:     TN_CMRFRVEMode; // Edit Frames Global View Edit Mode
    CMMAllSlidesToOperate: TN_UDCMSArray; // All Current Slides array to operate
    CMMImgSlidesToOperate: TN_UDCMSArray; // Pure Current Slides array to operate
    CMMMediaSlidesToOperate: TN_UDCMSArray; // Pure Current Slides array to operate
    CMMStudySlidesToOperate: TN_UDCMBSArray; // Pure Current Slides array to operate
//    CMMAllActsDisabled  : Boolean; // Set All Actions Disabled Flag
    CMMUICurStateFlags  : TK_CMUICurStateFlags; // CUI current state flags
    CMMCaptActsDisabled : Boolean; // Set Capture Actions Disabled Flag
    CMMServActions : TList;        // For Service Actions Auto Activation during Application Start
    CMMServActionsExec : Boolean;  // Service Actions are executed now
    CMMServActionsNext : TList;    // Next Service Actions list
    CMMServActionsNextTS : TDateTime; // Next Service Actions list TimeStamp

    CMMFAltShift0Count: integer;   // Alt+Shift+0 counter

    // Cur Visible Form Context
    CMMCurFStatusBar : TStatusBar;
    CMMCurFThumbsDGrid: TN_DGridArbMatr; // DGrid for handling Thumbnails in ThumbsRFrame
    CMMCurFThumbsRFrame: TN_Rast1Frame;
    CMMCurFThumbsResizeTControl: TControl;
    CMMCurFThumbsResizeWidth : Integer; //  needed to save real width for correct save after form close
    CMMCurFMainForm   : TN_BaseForm; // View/Edit CMS Interface Form
    CMMCurFMainFormSkipOnShow : Boolean;
    CMMCurFHPMainForm : TN_BaseForm; // High Resolution Preview CMS Interface Form
    CMMCurCaptToolBar: TToolBar;
    CMMCurChangeToolBarsVisibility: procedure of object;
    CMMCurMenuItemsDisableProc: procedure of object;
    CMMCurUpdateCustToolBar: procedure of object;
    CMMCurSlideFilterFrame: TK_FrameCMSlideFilter;
    CMMCurMainMenu: TMainMenu;

//    CMMCurSmallIcons: TImageList;
    CMMCurBigIcons: TImageList;
    CMMDevGroupTButton: TToolButton; // Devices Profiles Group Button
    CMMDevGroupInd: Integer; // Devices Profiles Group Index

    CMMSavedMUFRect : TRect; // Saved used mainly for placing Forms over the Main Form Rectangle previous State
    CMMThumbsFrameDblClickFlag : Boolean; // ThumbsFrame DoubleClick Event was Finished - needed for correct DragAndDrop from ThumbsFrame
    CMMActiveEdFrameDblClickFlag : Boolean; // ActiveEdFrame DoubleClick Event was Finished - needed for correct DragAndDrop from ThumbsFrame

    CMMFlashlightLastEd3Frame : TN_CMREdit3Frame;
    CMMCurBeginDragControl: TControl;
    CMMCurBeginDragControlPos: TPoint;
    CMMCurDragObject: TObject;
    CMMCurDragOverComp: TObject; //TN_UDCompVis;
    CMMCurDragObjectsList: TList;

    CMMStudyPrevLayout : TN_EdFrLayout; // Layout which was before Study Open in Single Editor Frames Layout
    CMMStudyLastOpened : TN_UDCMStudy;  // Last Opened Study in Single Editor Frames Layout
    CMMStudyColorsList : TStringList;
    CMMFActiveEdFrameSlideStudy : TN_UDCMStudy;  // Active EdFrame Slide Study

    CMMThumbsSlidesTextRowsCount : Integer; // Slide Thumbnale Label Rows Count
    CMMSkipCurFStatusBarInfo : Boolean;

    CMMUpdateUIMenuItemName : string; // CMMUpdateUIByDeviceProfiles Parameter 1
    CMMUpdateUIMenuItemInd1 : Integer; // CMMUpdateUIByDeviceProfiles Parameter 2

    CMMSkipDisableActionsCount : Integer; // Skip CMMFDisableActions counter
    CMMSkipSelectThumbWhileFinishVObjEditing : Boolean; // Skip Select Thumb by current ActiveFrame while Clear EdFrame Vobj context

    CMMUHExceptionInProcess : Boolean;

    CMMDisableActionsIsDone : Boolean; // CMMDisableActionsIsDone flag needed to prevent multy call to the procedure CMMFDisableActions(Sender)
    CMMPrevEdFrLayout : TN_EdFrLayout;

    procedure CMMFAppClose          ( const ACloseInfo : string );
    function  CMMFCreateEdFrame     (): TN_CMREdit3Frame;
    function  CMMFGetFreeEdFrame    (): TN_CMREdit3Frame;
    function  CMMFGetSlideLinkedToStudy(): TN_UDCMSlide;
    procedure CMMFSetEdFramesStretchBltMode();
    function  CMMFFindEdFrame       ( ASlide: TN_UDCMSlide; APFrInd : PInteger = nil ): TN_CMREdit3Frame;
    procedure CMMFFreeEdFrObjects   ( );
    procedure CMMFEdFrRFrameFreeObjects   ( );
    procedure CMMRedrawDragOverComponent( AViewState : Integer );
    procedure CMMFSelectThumbBySlide( AUDSlide : TN_UDCMSlide; AUnselectFlag : Boolean = FALSE;
                                      ASelectStudyFlag : Boolean = FALSE );
    procedure CMMFRefreshActiveEdFrameHistogram( ADIBObj : TN_DIBObj = nil );
    procedure CMMFSetActiveEdFrame  ( AEditorFrame: TN_CMREdit3Frame; ASkipSwitchSelectedThumb : Boolean = FALSE );
    procedure CMMFCalcEdFrCoefs     ( ASender: TObject );
//    procedure CMMFSetEdFramesLayout    ( AEdFrLayout: TN_EdFrLayout );
    function  CMMFSetEdFramesLayout0   ( AEdFrLayout: TN_EdFrLayout;
                                         APUDCMSlide : TN_PUDCMSlide = nil;
                                         ASCount : Integer = 0;
                                         AEDFrLayoutFlags : TK_CMUIEDFrLayoutFlags = [] ) : Integer;
    procedure CMMFUpdateEdFramesLayout ( AEdFrLayout: TN_EdFrLayout );

    procedure CMMFDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure CMMFGetSlideDGridThumbSize( ASlide : TN_UDCMBSlide; ADGObj: TN_DGridBase;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure CMMFGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                   AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure CMMFRebuildVisSlides  ( ATryToSaveSelection : Boolean = FALSE );
    procedure CMMFShowString        ( AStr: string );
    procedure CMMFShowStringByTimer ( AStr: string );
    procedure CMMFShowHideWaitState( AShowWaitFlag : Boolean );
    procedure CMMFShowScale         ( ARFrame: TN_Rast1Frame );
    procedure CMMFShowScroll        ( ARFrame: TN_Rast1Frame );
    procedure CMMFChangeToolBarsVisibility    ();
    procedure CMMFShowHint          ( Sender : TObject );

    procedure CMMFRebuildActiveView    ( ARebuildViewFlags : TN_RebuildViewFlags = [] );
    function  CMMFCheckBSlideExisting   (): boolean;
    procedure CMMFSaveUNDOState        ( AEdActName: string;
                                         ASaveUndoFlags : TK_CMSlideSaveStateFlags;
                                         AHistActionCode : Integer );
    procedure CMMFFinishSlidesAction( AVobjSelected : TObject );
    procedure CMMFFinishImageEditing   ( AEdActName: string;
                                         ASaveUndoFlags : TK_CMSlideSaveStateFlags;
                                         AHistActionCode : Integer = -1;
                                         ARebuildActiveView : Boolean = FALSE );
    procedure CMMFFinishVObjEditing    ( AEdActName: string; AHistActionCode : Integer );
    procedure CMMFCancelImageEditing   ();
    function  CMMOpenedStudiesLock( APStudy: TN_PUDCMStudy; AStudiesCount: Integer;
                                  out AWasLockedFlag : Boolean;
                                  ASkipUnlockAfterRefresh : Boolean ) : Integer;
    function  CMMOpenedStudiesLockDlg( APStudy: TN_PUDCMStudy; AStudiesCount: Integer;
                                  out AWasLockedFlag : Boolean;
                                  ASkipUnlockAfterRefresh : Boolean ) : Integer;
    procedure CMMOpenedStudiesUnLock( APStudy: TN_PUDCMStudy; AStudiesCount: Integer );
    function  CMMStudiesLockTry( APStudies : TN_PUDCMStudy; ACount : Integer;
                                     out AWasLockedFlag : Boolean;
                                     ATryCount, ATryPauseMS : Integer  ) : Boolean;
    function  CMMActiveStudyLockTry( out AWasLockedFlag : Boolean;
                                     ATryCount, ATryPauseMS : Integer  ) : Boolean;
    function  CMMActiveStudyLockDlg( var AWasLockedFlag : Boolean;
                                     ASkipUnlockAfterRefresh : Boolean ) : Integer;
    procedure CMMActiveStudyUnLock();
    function  CMMStudyRemountOneSlideToItem( ARItem: TN_UDBase; ARSlide : TN_UDCMSlide;
                                          APRContext : TK_PCMStudyRemountOneSlideContext;
                                          var ARUpdateFlags : TK_CMStudyRemountUpdateFlags ) : TK_CMEDResult;
    function  CMMStudyRemountAllSlidesToItem( ARItem: TN_UDBase; ARSlide : TN_UDCMSlide;
                                          APRContext : TK_PCMStudyRemountOneSlideContext;
                                          var ARUpdateFlags : TK_CMStudyRemountUpdateFlags ) : TK_CMEDResult;

//    function  CMMStudyDismountSelected( AStudy: TN_UDCMStudy ) : Integer;
    procedure CMMStudyEndDrug( ASkipEndDrag : Boolean );
    procedure CMMSlideEndDrag( ASlide : TN_UDCMSlide; AEdFrame : TN_CMREdit3Frame;
                               AddToOpenedFlags : TK_CMSlideAddToOpenedFlags = [] );

    procedure CMMRedrawOpenedFromGiven( APSlide: TN_PUDCMSlide;
                                        ASlidesCount: Integer );

    function  CMMSetSlidesAttrs( ASlidesCount: Integer;
                             APDCMAttrs : TK_PCMDCMAttrs;
                             ACaption : string = '';
                             ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                             AIniMediaType : Integer = 0 ) : Integer;

    procedure CMMFDisableUNDOActions   ();

    procedure CMMFRebuildViewAfterUNDO ( AChangeCurStateFlags : TK_CMSlideSaveStateFlags;
                                         APrevSize : TPoint );
    procedure CMMUpdateUIByDeviceProfiles ();
    procedure CMMUpdateUIByFilterProfiles();
    procedure CMMUpdateUIByCTA();
    function  CMMSwitchEdframes ( AFr1, AFr2 : TN_CMREdit3Frame;
                                  AEDFrLayoutFlags : TK_CMUIEDFrLayoutFlags = [] ) : Boolean;
    function  CMMAddMediaToOpened( ASlide : TN_UDCMSlide; AddToOpenedFlags : TK_CMSlideAddToOpenedFlags;
                                   AEdFrame : TN_CMREdit3Frame = nil ) : Boolean;
    procedure CMMImg3DFolderAbsentDlg( const A3DFolderName : string );
    procedure CMMImg3DOpen( ASlide : TN_UDCMSlide );
    procedure CMMShowCloseApplicationWarning();
    function  CMMCallActionByTimer ( AAction : TAction; AStartTimer: Boolean;
                                     ATimerInterval : Integer = 0 ) : Boolean;

    procedure CurArchiveChanged (); override;
    procedure OnUHException     ( Sender: TObject; E: Exception );
    procedure OnThumbsFrameMouseDown ( Sender: TObject; Button: TMouseButton;
                                       Shift: TShiftState; X, Y: Integer );
    procedure CMMSetWindowState ( AHandle : HWND; AWinState : Integer ); overload;
    procedure CMMSetWindowState ( AWinState : Integer ); overload;
    procedure CurStateToMemIni  (); override;
    procedure MemIniToCurState  (); override;
    procedure CMMSetFramesMode( AEdVEMode: TN_CMRFRVEMode;
                                AEdFrame : TN_CMREdit3Frame = nil );
    function  CMMRebuildSlidesToOperate () : Integer;
    procedure CMMCropCancelProcObj         ( ARFAction: TObject );
    procedure CMMCropBySelectedRectProcObj ( ARFAction: TObject );
    function  CMMGetMarkedSlidesArray( var ASlidesArray: TN_UDCMSArray ) : Integer;
    procedure CMMInitThumbFrameTexts();
    procedure CMMSetMUFRectByActiveFrame();
    procedure CMMRestoreMUFRect();
    procedure CMMHideFlashlightIfNeeded();
    procedure CMMChangeThumbState( ADGObj: TN_DGridBase; AInd: integer);
    procedure OnComboBoxColorItemDraw( Control: TWinControl; Index: Integer;
                                       Rect: TRect; State: TOwnerDrawState );
    function  CMMChangeSlideSelectState(ASlideID : string; AStateMode: TN_SetStateMode) : Boolean;
    procedure CMMLaunchHPUI();
    procedure CMMLaunchVEUI();
    function  CMMImg3DViewsImportAndShowProgress(
                         const A3DSlideID, ASlideBasePath : string ) : Integer;
    procedure CMMSetUIEnabled( AUIEnabled : boolean );
//    procedure CMMFullScreenWndProc(var Msg: TMessage);
end; // type TN_CMMain5Form = class( TN_BaseForm )

const
  N_CM_MaxNumEdFrames: integer = 9; // Size of CMMFEdFrames Array
  crZoomCursor        =  1;
  crMoveTextCursor    =  2;
  crMoveVObjCursor    =  3;
  crMovePointCursor   =  4;
  crCreateText        =  5;
  crCreateNormLine    =  6;
  crCreateMeasureLine =  7;
  crCreateNormAngle   =  8;
  crCreateFreeAngle   =  9;
  crGetColor          = 10;
  crCreateRect        = 11;
  crCreateEllipse     = 12;
  crCreateArrow       = 13;
  crCreateFreeHand    = 14;
  crChangeBriCo       = 15;
  crCreateDot         = 16;

var
  N_CM_MainForm: TN_CMMain5Form1; // Main CMS Application Form

    //*********** Global Procedures  *****************************

implementation
uses IniFiles, math, StrUtils, ShellAPI,
     K_CLib0, K_UDC, K_UDConst, K_UDT2, K_Script1, K_FrRaEdit, K_FRunDFPLScript,
     K_Arch,  K_VFunc, K_FCMSIsodensity, K_FCMSFPathChange, K_FCMAltShiftMEnter,
     K_FCMSlideIcon, K_FCMMain6F, K_FCMMain5F, {K_FPMTMain5F, }K_FCMStart, K_FCMSZoomMode,
     K_CMRFA, K_CMCaptDevReg,  K_CML1F, K_FCMSetSlidesAttrs2,
     K_FCMSetSlidesAttrs3, K_FCMHPreview, K_CM1, K_FCMImg3DViewsImportProgress,

     N_ClassRef, N_Lib0, N_Lib2, N_GCont, N_SGComp, N_CMRFA,
     N_Gra0, N_Gra1, N_CMAboutF, N_EdParF,
     N_CompBase, N_Comp1, N_EdStrF, N_CompCL,
     N_CMResF, N_ButtonsF, N_BrigHist2F, N_CMTWAIN3,
     N_CMFPedalSF, N_PMTMain5F;
{$R *.dfm}

    //***********  TN_CMMain5Form event Hadlers  *****

//******************************************** TN_CMMain5Form1.FormActivate ***
// OnActivate Self handler
//
//     Parameters
// Sender    - Event Sender
//
// Is used by real GUI forms
//
procedure TN_CMMain5Form1.FormActivate(Sender: TObject);
begin
  if K_FormCMStart <> nil then
  begin
    K_SplashScreenHide();
    N_Dump1Str('***** After SplashScreen Hide 1');
  end;
end; // procedure TN_CMMain5Form1.FormActivate

//************************************************ TN_CMMain5Form1.FormShow ***
// Self initialization
//
//     Parameters
// Sender    - Event Sender
//
// OnShow Self handler
//
procedure TN_CMMain5Form1.FormShow( Sender: TObject );
var
  LogFName, CursorFName: string;
//  VFileR : TK_VFile;
//  DataFilesR: string;
begin
  N_Dump1Str( '***** Start TN_CMMain5Form1 OnShow Handler' );
//  N_Dump1Str( '' );
//  N_Dump1Str( '***** Start new session' );
//!!! 2013-11-17  CMMCurFMainForm := Self;

  N_Dump1Str( N_CMSBuildInfo() );

//  ViewEditProtocol1.ImageIndex := 4; it works!
//  N_AppShowString := CMMFShowString;


  //*** Form.WindowProc should be changed for processing Arrow and Tab keys
//  WindowProc := OwnWndProc;


////////////////////////////////////////
// Code Instead of InitMainFormFrame();
  LogFName := N_MemIniToString( 'CMS_Main', 'StartArchive', '');
  LogFName := K_ExpandFileName( LogFName );
  if not K_OpenCurArchive( LogFName ) then
    raise Exception.Create( 'Fail to load archive ' + LogFName );

//  N_Dump1Str( '***** TimeStamp: Before EDAccessInit' ); // Deb time measuring
  K_InitArchiveGCont( K_CurArchive ); // create all needed objects in K_CurArchive

// Init UI
  CMMUpdateUIMenuItemName := 'Capture1';
  CMMUpdateUIMenuItemInd1 := 3; // Set UIDevice Update parameter for CMSuite

  EdFramesPanel.DoubleBuffered := True;
  CMMEdFramePopUpMenu := N_CMResForm.EdFrPointPopupMenu;

  N_AddDirToPATHVar( K_ExpandFileName( '(#DLLFiles#)' ) );

  K_CMRedrawObject := TK_RedrawDelayObj.Create;

  K_CMEDAccessInit11();

  if K_CMSAppStartContext.CMASState = K_cmasStop then Exit; // Stop Initialization if some Errors are detected
  if K_CMSAppStartContext.CMASMode >= K_cmamCOMWEB then
  begin
//    K_CMSAppStartContext.CMASState = K_cmasRun;
    Exit; // UI Initialization is not needed
  end;
//  N_Dump1Str( '***** TimeStamp: After EDAccessInit' ); // Deb time measuring


//  N_InitWorkAreaRect(); // N_WorkAreaRect initialization by Inifile (Old var, temporary needed)
  N_InitWAR(); // Initialize N_WholeWAR and N_AppWAR using [Global]ScreenWorkArea in Ini file

// 2017-08-22 - do not N_ClearSavedFormCoords if Monitors Configuration Changed
// Do it only for the first Start after installation
//  if N_MonWARsChanged() then N_ClearSavedFormCoords(); // clear N_Forms section if needed
  if N_CurMemIni.ReadString( 'N_Forms', 'AllMonWARs', '' )= '' then
    N_ClearSavedFormCoords();

  N_CM_IDEMode := N_MemIniToInt( 'CMS_Main', 'IDEMode', 0 );

  N_DumpDPIRelatedInfo( 1 ); // add to Dump1 Monitors and DPI related Info

  if K_CMEDAccess <> nil then
  begin // Archive Initialization is OK (not Failed)

{
    // Conv Text Archive to Binary Mode
    if N_MemIniToBool( 'CMS_Main', 'BinaryArchive',  FALSE ) then
      with K_GetPArchive( K_CurArchive )^ do
        if not ArchFileFormatBin then begin
          K_ArchInfoList.Values[K_tbArchFmtCurVerID] := IntToStr(K_SPLDataCurFVer);
          with K_CurArchive do  SaveTreeToFile(  ObjAliase, K_ArchInfoList.Text, [] );
          ArchFileFormatBin := true;
        end;
}
//
///////////////////////////////////////////


    //***** Create TmpFiles dir if not yet
//    K_ForceFilePath( K_ExpandFileName( '(#TmpFiles#)' ) );
    K_ForceDirPath( K_ExpandFileName( '(#TmpFiles#)' ) );

    K_VFCopyDirFiles( K_ExpandFIleName('(#CursorFiles#)'),
                      K_ExpandFIleName('(#TmpFiles#)'), K_DFCreatePlain,
                      '*.cur', [] );

    CursorFName := K_ExpandFileName( '(#TmpFiles#)zoom.cur' );
    Screen.Cursors[crZoomCursor]     := LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)hand_td.cur' );
    Screen.Cursors[crMoveTextCursor] := LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)hand_md.cur' );
    Screen.Cursors[crMoveVObjCursor] := LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)hand_pd.cur' );
    Screen.Cursors[crMovePointCursor]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_t.cur' );
    Screen.Cursors[crCreateText]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_fh.cur' );
    Screen.Cursors[crCreateFreeHand]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_nl.cur' );
    Screen.Cursors[crCreateNormLine]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_ml.cur' );
    Screen.Cursors[crCreateMeasureLine]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_na.cur' );
    Screen.Cursors[crCreateNormAngle]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_fa.cur' );
    Screen.Cursors[crCreateFreeAngle]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_gc.cur' );
    Screen.Cursors[crGetColor]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_rt.cur' );
    Screen.Cursors[crCreateRect]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_el.cur' );
    Screen.Cursors[crCreateEllipse]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_ar.cur' );
    Screen.Cursors[crCreateArrow]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)bri_co.cur' );
    Screen.Cursors[crChangeBriCo]:= LoadCursorFromFile( PChar(CursorFName) );
    CursorFName := K_ExpandFileName( '(#TmpFiles#)cr_d.cur' );
    Screen.Cursors[crCreateDot]:= LoadCursorFromFile( PChar(CursorFName) );

    K_VFDeleteDirFiles( K_ExpandFIleName('(#TmpFiles#)'), '*.cur', [] );

    N_BinaryDumpProcObj := N_CMResForm.CreateBinDumpFile; // for saving Dump files

  end; // if K_CMEDAccess <> nil then

//  N_CMResForm.aHelpRegistration.Visible := not K_CMDemoModeFlag;
  N_CMResForm.aHelpRegistration.Enabled := not K_CMDemoModeFlag and
                                          (K_CMEDAccess is TK_CMEDDBAccess);
//  N_CMResForm.aHelpRegistration.Enabled := FALSE;

// Debug Options Visibility
  N_CMResForm.aDebOption1.Visible := N_MemIniToBool('CMS_UserDeb', 'ShowDebOptions', false);
  N_CMResForm.aDebOption2.Visible := N_CMResForm.aDebOption1.Visible;

///////////////////////////////
// Start Some VEI Objects Init
  CMMFSplittersSize := 7;
  CMMFDrawSlideObj := TN_CMDrawSlideObj.Create();
  CMMFDrawSlideObj.CMDSCSelBordWidth := 2;   // for Active EdFrame Slide Study special Mark
  CMMFDrawSlideObj.CMDSCSelColor := $00FF00; // for Active EdFrame Slide Study special Mark

  CMMStudyColorsList := TStringList.Create;
  CMMStudyColorsList.BeginUpdate;
  CMMStudyColorsList.AddObject( K_CML1Form.LLLStudyColorsList.Items[0], TObject(-1) );
  CMMStudyColorsList.AddObject( K_CML1Form.LLLStudyColorsList.Items[1], TObject($00408000) );
//  CMMStudyColorsList.AddObject( K_CML1Form.LLLStudyColorsList.Items[1], TObject(clLime) );
  CMMStudyColorsList.AddObject( K_CML1Form.LLLStudyColorsList.Items[2], TObject(clBlue) );
  CMMStudyColorsList.AddObject( K_CML1Form.LLLStudyColorsList.Items[3], TObject(clRed) );
  CMMStudyColorsList.AddObject( K_CML1Form.LLLStudyColorsList.Items[4], TObject($00A2FFFF) );
//  CMMStudyColorsList.AddObject( K_CML1Form.LLLStudyColorsList.Items[4], TObject(clYellow) );
  CMMStudyColorsList.EndUpdate;


  CMMCurDragObjectsList := TList.Create;

  SetLength( CMMFEdFrames, N_CM_MaxNumEdFrames );
// Fin Some VEI Objects Init
//////////////////////////////
  if K_CMSAppStartContext.CMAInitNotComplete then
  begin
    K_CMSAppStartContext.CMAInitNotComplete := FALSE;
    N_Dump1Str( '***** Finish TN_CMMain5Form1 OnShow Handler after Files Access mode' );
    Exit;
  end;


// DEB K_CMSAppStartContext.CMASMode := K_cmamDCMExe;

  if K_CMSAppStartContext.CMASMode = K_cmamCOMHPUI then
  ////////////////////////////////////
  // Show Highresolution Preview Interface
  //
    CMMLaunchHPUI()
  else
  // Launch Error while launch in COM mode
  //if K_CMSAppStartContext.CMASMode = K_cmamWAIT then
  ////////////////////////////////////
  // Show Main View\Edit Interface
  //
    CMMLaunchVEUI();
  //  Self.Close();
  //  Self.Release();
  //
  // Show Main Interface Form Code
  ////////////////////////////////////


  N_Dump1Str( '***** Finish TN_CMMain5Form1 OnShow Handler' );
end; // procedure TN_CMMain5Form1.FormShow

//************************************************ TN_CMMain5Form1.FormClose ***
// Self finalization (free all created Self Objects)
//
//     Parameters
// Sender - Event Sender
// Action - should be set to caFree if Self should be destroyed
//
// OnClose Self handler
//
procedure TN_CMMain5Form1.FormClose( Sender: TObject; var Action: TCloseAction );
var
  i : Integer;
begin
// To prevent actions in K_FormCMSIsodensity.FormClose
  N_Dump1Str( '***** N_CM_MainForm.OnClose Start' );
  FreeAndNil(K_CMAddADOQuery);
  FreeAndNil(K_CMAddDBConnection);
  if K_CMEDAccess = nil then Exit;
  // Needed because this form is ATimer Owner
  K_CMEDAccess.ATimer.Enabled := FALSE;
  FreeAndNil(K_CMEDAccess.ATimer);


  CMMServActions.Free;

//  K_FormCMSIsodensity.SelfClose; // 08.02.2012 - try instead K_FormCMSIsodensity := nil
//  K_FormCMSIsodensity := nil;

  K_CMD4WAppFinState := TRUE;

  CMMFFreeEdFrObjects();
//  N_CMUnloadAllExtDLL(); // Unload All Ext Devices DLL
//  CMMFThumbsDGrid.Free;
  CMMFDrawSlideObj.Free;
  CMMCurDragObjectsList.Free;

//!!! Free Rast1Frame Objects and Skip RFrame Events
  CMMFEdFrRFrameFreeObjects();
  N_AppSkipEvents := TRUE; // to prevent Rast1Frames events during application close


  inherited;

  N_Dump2Str( 'Start Data Access Close' );
  if not K_CMSkipSlidesSavingFlag then
  begin
    K_CMEDAccess.EDASaveSlidesList( nil );  // Save Slides
  end;
  K_CMEDAccess.EDAClearCurSlidesSet(); // Clear All Opend

  if K_CMStandaloneGUIMode then
    K_CMEDAccess.EDASADelAllDelPatientSlides( ); // Clear Patients in Stand Alone Mode

  K_CMEDAccess.EDASaveContextsData(); // Save App Context

//    FreeAndNil(K_CMEDAccess);
//!!! Need to separate Free and Nil because of
//!!! K_CMRemoveOldDump2HaltFiles() in K_CMEDAccess destructor
  K_CMEDAccess.Free();
  K_CMEDAccess := nil;

  if K_CMCaptDevsList <> nil then
  begin
    for i := 0 to K_CMCaptDevsList.Count - 1 do
    begin
      N_Dump2Str( format( 'CMCDServObj Free Start Name=%s',
                          [TK_CMCDServObj(K_CMCaptDevsList.Objects[i]).CDSName] ) );
      K_CMCaptDevsList.Objects[i].Free;
      N_Dump2Str( 'CMCDServObj Free Fin' );
    end;
    K_CMCaptDevsList.Free;
  end;

  FreeAndNil(N_FPCBObj);

  N_Dump1Str( '***** Finish session at ' + K_DateTimeToStr( Time, ' hh":"nn":"ss.z ' ) + #13#10 );

  if N_MemIniToBool( 'CMS_UserDeb', 'PreserveErrLog', FALSE ) then
    N_LCExecAction( N_Dump1LCInd, lcaFlush ) // do not write FinishedOK Flag
  else
    N_LCAddFinishedOKFlag( N_Dump1LCInd );

  N_Dump1Str( 'Application MainFormClose FlushCounters' + N_GetFlushCountersStr() );
  N_LCExecAction( -1, lcaFlush );
//  N_CMFinGlobals();
//  N_FinGlobals();
  K_TreeFinGlobals();
  N_CM_MainForm := nil;

end; // procedure TN_CMMain5Form1.FormClose

//************************************** TN_CMMain5Form1.CMMEdFramesPanelResize ***
// Update Editor Frames Positions
//
//     Parameters
// Sender    - Event Sender
//
// EdFramesPanel OnResize handler
//
procedure TN_CMMain5Form1.CMMEdFramesPanelResize( Sender: TObject );
begin
  N_Dump2Str( 'EdFramesPanelResize start' );
  if N_CM_MainForm = nil then Exit;
  N_CM_MainForm.CMMFUpdateEdFramesLayout( CMMFEdFrLayout );
  N_Dump2Str( 'EdFramesPanelResize fin' );
end; // procedure TN_CMMain5Form1.CMMEdFramesPanelResize

//*************************************** TN_CMMain5Form1.CMMFDisableActions ***
// Disable needed Actions by current Application state
//
//     Parameters
// Sender - Event Sender
//
// Used as OnClick handler for All MainMenu top level Items and should be
// called after all other code, that may affect list of disabled Actions
//
procedure TN_CMMain5Form1.CMMFDisableActions( Sender: TObject );
var
//  NumMarked : integer;
  i: integer;
  {ClipboardIsEmpty,}
  ThumbFrameSelectionIsEmpty, ActiveFrameIsEmpty, NoSlidesToOperate: boolean;
//  ThumbFrameNoSelected: boolean;
  ThumbFrameNoSlides  : boolean;
  NotReadOnlyMode : Boolean;
  SlidesToOperateCount : Integer;
  StudiesToOperateCount : Integer;
  VideoToOperateCount : Integer;
  Img3DToOperateCount : Integer;
  Img3DDevCount : Integer;
  EmptyStudiesToOperateCount : Integer;
  FilesHandlingInProcess : Boolean;
  CaptActsEnabled : Boolean;
  SkipActSlideFiles  : Boolean;
  OnExecuteHandler, NEVar : TNotifyEvent;
  NumMarkedAsDel : Integer;
  SlideSFlags : TN_CMSlideSFlags;
  ActiveStudyNoSlides   : boolean;
  ActiveStudyNoSelected : boolean;
  ActiveStudyIsOpened : boolean;
  ActiveStudySlidesCount : Integer;
  PCMSlideSDBF : TN_PCMSlideSDBF;
  ArchivedCount, ArchivedQCount : Integer;
  DicomViewerActive: Boolean;
begin
  if (CMMCurFThumbsDGrid = nil) or (CMMSkipDisableActionsCount <> 0) then Exit;

  N_Dump2Str( 'CMMFDisableActions start' );
  CMMDisableActionsIsDone := TRUE;
  with N_CMResForm do
  begin
//    ClipboardIsEmpty := K_CMSlidesClipboard.PrepClipboard(
//       [K_ucpRemoveNodesWithAbsentParents, K_ucpRemoveNodesWithWrongDEInd]) = 0;

//    ClipboardIsEmpty := (uicsAllActsDisabled in CMMUICurStateFlags) or
//                        (Length(K_CMSlidesClipBoardArray) = 0 );

    SlidesToOperateCount := CMMRebuildSlidesToOperate( );
    StudiesToOperateCount := 0;
    EmptyStudiesToOperateCount := 0;
    VideoToOperateCount := 0;
    Img3DToOperateCount := 0;
    Img3DDevCount       := 0;
    ArchivedCount       := 0;
    ArchivedQCount     := 0;
    for i := 0 to SlidesToOperateCount - 1 do
      if TN_UDCMBSlide(CMMAllSlidesToOperate[i]) is TN_UDCMStudy then
      begin
        Inc(StudiesToOperateCount);
        if 0 = CMMAllSlidesToOperate[i].GetFileTypeCounts() then
          Inc(EmptyStudiesToOperateCount);
      end
      else
      begin
        if CMMAllSlidesToOperate[i].CMSArchived then
        begin
          Inc(ArchivedCount);
          if CMMAllSlidesToOperate[i].CMSArchDate <> 0 then
            Inc(ArchivedQCount);
        end;
        with CMMAllSlidesToOperate[i].P^ do
          if cmsfIsMediaObj in CMSDB.SFlags then
            Inc(VideoToOperateCount)
          else
          if cmsfIsImg3DObj in CMSDB.SFlags then
          begin
            Inc(Img3DToOperateCount);
            if CMSDB.Capt3DDevObjName <> '' then
              Inc(Img3DDevCount);
          end;
      end;

    NoSlidesToOperate := (uicsAllActsDisabled in CMMUICurStateFlags) or
                         (SlidesToOperateCount = 0) or
                         (ArchivedCount > 0);
    ThumbFrameSelectionIsEmpty := (uicsAllActsDisabled in CMMUICurStateFlags) or
                                  (CMMCurFThumbsDGrid.DGMarkedList.Count = 0);

//    ThumbFrameNoSelected := (CMMCurFThumbsDGrid.DGSelectedInd = -1) or
//                            ThumbFrameSelectionIsEmpty;
    ThumbFrameNoSlides := (Length(CMMCurFThumbsDGrid.DGItemsFlags) = 0) or (uicsAllActsDisabled in CMMUICurStateFlags);

    FilesHandlingInProcess := (K_CMEDAccess <> nil) and
                              ( (K_CMEDAccess.EDACheckFSSettings( ) <> 0) or
                                (K_CMEDAccess.SlidesCRFC.RootFolder <> '') );
    if FilesHandlingInProcess then
      Include( CMMUICurStateFlags, uicsFilesHandlingInProcess )
    else
      Exclude( CMMUICurStateFlags, uicsFilesHandlingInProcess );

    SkipActSlideFiles  := (uicsAllActsDisabled in CMMUICurStateFlags) or
                          FilesHandlingInProcess or
                         (ArchivedCount > 0);

{
    if CMMFActiveEdFrame = nil then
      ActiveFameIsEmpty := True
    else
      ActiveFameIsEmpty := (CMMFActiveEdFrame.EdSlide = nil);
}
    ActiveFrameIsEmpty := (CMMFActiveEdFrame = nil) or
                          (CMMFActiveEdFrame.EdSlide = nil);
    ActiveStudyNoSlides   := TRUE;
    ActiveStudyNoSelected := TRUE;
    ActiveStudyIsOpened := FALSE;
    ActiveStudySlidesCount:= 0;
    if ActiveFrameIsEmpty or (uicsAllActsDisabled in CMMUICurStateFlags) then
    begin
      Include( CMMUICurStateFlags, uicsActiveFrameIsEmpty );
    end
    else
    begin
      Exclude( CMMUICurStateFlags, uicsActiveFrameIsEmpty );
      if TN_UDCMBSlide(CMMFActiveEdFrame.EdSlide) is TN_UDCMStudy then
        with TN_UDCMStudy(CMMFActiveEdFrame.EdSlide) do
        begin
          ActiveStudyIsOpened    := TRUE;
          ActiveStudySlidesCount := GetFileTypeCounts();
          ActiveStudyNoSlides    := ActiveStudySlidesCount = 0;
          ActiveStudyNoSelected  := 0 = CMSSelectedCount;
        end;
    end;

    aServSwitchToPhotometry.Visible := (K_CMSMainUIShowMode >= 0) and not K_CMVUIMode;
    aServSwitchToPhotometry.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);
    aServSwitchFromPhotometry.Visible := aServSwitchToPhotometry.Visible;

    aServSysSetupUI.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);

    aHelpContents.Enabled := not K_CMVUIMode;

    aServWEBSettings.Visible := K_CMVUIMode;
//    aServChangeDBAPSW.Enabled := K_CMGAModeFlag;
//    aServChangeDBAPSW.Visible := (K_CMEDDBVersion >= 47);

    if not ActiveStudyIsOpened then
    begin
      aEditStudyDismount.Enabled        := FALSE;
      aEditStudySelectAll.Enabled       := FALSE;
      aEditStudyInvertSelection.Enabled := FALSE;
      aEditStudyClearSelection.Enabled  := FALSE;
      aEditStudyItemSelectVis.Enabled   := FALSE;
    end
    else
    begin
      aEditStudyDismount.Enabled        := not ActiveStudyNoSelected;
      aEditStudySelectAll.Enabled       := not ActiveStudyNoSlides and (SlidesToOperateCount <> ActiveStudySlidesCount);
      aEditStudyInvertSelection.Enabled := not ActiveStudyNoSlides;
      aEditStudyClearSelection.Enabled  := not ActiveStudyNoSlides and not ActiveStudyNoSelected;
      aEditStudyItemSelectVis.Enabled   := TN_UDCMStudy(CMMFActiveEdFrame.EdSlide).CMSSelectedCount = 1;
    end;

    NotReadOnlyMode := not ActiveStudyIsOpened and
                       not (uicsAllActsDisabled in CMMUICurStateFlags) and
                       not ActiveFrameIsEmpty  and
                       not (cmsfSkipSlideEdit in CMMFActiveEdFrame.EdSlide.P.CMSRFlags) and
                       not K_CMMarkAsDelShowFlag and
                       (K_uarModify in K_CMCurUserAccessRights);
//                       (CMMEdVEMode <> cmrfemFlashLight);
//                       (cmsfIsLocked in CMMFActiveEdFrame.EdSlide.P.CMSRFlags);

    if not NotReadOnlyMode then
      Include( CMMUICurStateFlags, uicsSkipActiveSlideEdit )
    else
      Exclude( CMMUICurStateFlags, uicsSkipActiveSlideEdit );

    //***** Process OpenedSlideIsEmpty flag

    aMediaWCImport.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags)                   and
                              (K_uarImport in K_CMCurUserAccessRights) and
                              ( Windows.IsClipboardFormatAvailable( CF_DIB ) or
                                Windows.IsClipboardFormatAvailable( CF_HDROP ) );

//###!!!???    Tools1.Enabled := (K_uarModify in K_CMCurUserAccessRights);

    aGoToReports.Enabled      := not SkipActSlideFiles and (K_uarReports in K_CMCurUserAccessRights);
    aGoToReports.Visible      := (K_CMEDAccess <> nil) and (K_CMEDAccess is TK_CMEDDBAccess);

//    aServFilesHandling.Visible := (K_CMEDAccess <> nil) and (K_CMEDAccess is TK_CMEDDBAccess);
    aServFilesHandling.Enabled   := ( not (uicsAllActsDisabled in CMMUICurStateFlags) or
                                     (uicsServActsEnable  in CMMUICurStateFlags) ) and
                                     (K_CMEDAccess <> nil) and (K_CMEDAccess is TK_CMEDDBAccess);
    aServSetCaptureDelay.Enabled := not K_CMVUIMode;
    aCapCaptDevSetup.Enabled     := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                    not FilesHandlingInProcess and not K_CMVUIMode;
    aCapFootPedalSetup.Enabled := aCapCaptDevSetup.Enabled;
{//!!SkipOldReg
                                 not FilesHandlingInProcess and
                                ( (K_CMSLiCommonTwainNum  <> 0) or // Maximal TWAIN Device Counter
                                  (K_CMSLiCommonOtherNum  <> 0) or // Maximal Not TWAIN Device Counter
                                  (K_CMSLiCommonVideoNum  <> 0) ); // Maximal Video Device Counter
}

    // Enterprise Mode Actions control
//    aGoToGAEnter.Visible := K_CMEnterpriseModeFlag;
    aGoToGAEnter.Visible := not (uicsAllActsDisabled in CMMUICurStateFlags);
//    aGoToGAEnter.Visible := not (uicsAllActsDisabled in CMMUICurStateFlags) or (uicsServActsEnable  in CMMUICurStateFlags);
    aGoToGASettings.Visible := K_CMGAModeFlag;
    aServSpecialSettings.Visible := K_CMGAModeFlag and
                                   (K_CMSLiRegStatus <> K_lrtComplex);
    aGoToGAFSyncInfo.Visible := K_CMEnterpriseModeFlag and K_CMGAModeFlag;;
    aMediaEMChangeHLoc.Visible := K_CMEnterpriseModeFlag and K_CMGAModeFlag;;
    aMediaEMChangeHLoc.Enabled := not NoSlidesToOperate and not SkipActSlideFiles;

    aServPrintTemplatesFNameSet.Enabled := K_CMGAModeFlag;
    
//    aGoToGAEnter.Enabled := not K_CMEnterpriseGAModeFlag;
// not used now!!!    Deletedobjectshandling1.Visible := not K_CMEnterpriseModeFlag;

//###!!!???    Deletedobjectshandling2.Visible := K_CMEnterpriseGAModeFlag;

    aViewZoomMode.Enabled     := not (uicsAllActsDisabled in CMMUICurStateFlags);
    aViewZoomMode.Checked     := K_CMSZoomForm <> nil;

//    aToolsHistogramm2.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);

    aToolsSharpen1.Visible := K_CMSNF_SharpenTestMode;
//    aToolsNoiseAttrs.Visible := K_CMSNF_NoiseTestMode;
    aToolsNoiseAttrs1.Visible := K_CMSNF_NoiseTestMode;

    aServRemoteClientSetup.Visible := (K_CMEDAccess is TK_CMEDDBAccess) and (K_CMEDDBVersion >= 19);
    aServRemoteClientSetup.Enabled := K_CMGAModeFlag;

    aServLinkSetup.Visible := (K_CMEDAccess is TK_CMEDDBAccess) and (K_CMEDDBVersion >= 21);
    aServLinkSetup.Enabled := K_CMGAModeFlag;

    aServSAModeSetup.Visible := (K_CMEDAccess is TK_CMEDDBAccess) and K_CMStandaloneGUIMode and (K_CMEDDBVersion >= 21);
    aServSAModeSetup.Enabled := K_CMGAModeFlag;

    aServImportPPL.Visible := aServSAModeSetup.Visible;
    aServImportPPL.Enabled := K_CMGAModeFlag;

    aServExportPPL.Visible := aServSAModeSetup.Visible;
    aServExportPPL.Enabled := K_CMGAModeFlag;

    aServECacheRecovery.Visible  := (K_CMEDAccess is TK_CMEDDBAccess);

    aServEModeFilesSync.Visible := K_CMEnterpriseModeFlag;
    aServSelSlidesToSyncQuery.Visible := K_CMEnterpriseModeFlag;
    aServECacheAllShow.Visible  := not K_CMDEMOModeFlag;
    aServImportExtDBDlg.Visible := not K_CMDEMOModeFlag;

    aServResampleLarge.Enabled := K_CMGAModeFlag and
                                 (K_CMEDAccess is TK_CMEDDBAccess) and
                                 not SkipActSlideFiles;
//    aServMaintenance.Visible := K_CMEDAccess is TK_CMEDDBAccess;

    aServMaintenance.Enabled := K_CMGAModeFlag and not K_CMEnterpriseModeFlag and
                                (K_CMEDAccess is TK_CMEDDBAccess) and
                                not SkipActSlideFiles;

    aServSystemInfo.Enabled := (K_CMEDAccess is TK_CMEDDBAccess) and
                               not SkipActSlideFiles;
    aServImportExtDBDlg.Enabled := not SkipActSlideFiles;

    aServCreateStudyFiles.Visible := (K_CMEDAccess is TK_CMEDDBAccess) and
                                     (K_CMEDDBVersion >= 27) and
                                     (K_CMSFixStudyDataMode = 2);

//    aServDBRecoveryByFiles.Visible := K_CMEDAccess is TK_CMEDDBAccess;
    aServDBRecoveryByFiles.Enabled := (K_CMSDBRecoveryMode or K_CMGAModeFlag) and
                                      (K_CMEDAccess is TK_CMEDDBAccess) and
                                      (not SkipActSlideFiles or K_CMSDBRecoveryMode);
    aServDelObjHandling.Visible := K_CMEDAccess is TK_CMEDDBAccess;
    aServDelObjHandling.Enabled := K_CMEDAccess is TK_CMEDDBAccess;

    aServRemoveLogsHandling.Visible := K_CMGAModeFlag;
    aServRemoveLogsHandling.Enabled := K_CMGAModeFlag;

    aServArchSave.Visible := (K_CMEDAccess is TK_CMEDDBAccess) and (K_CMEDDBVersion >= 41);
    aServArchSave.Enabled := K_CMGAModeFlag and not (uicsAllActsDisabled in CMMUICurStateFlags);

    aServArchRestore.Visible := aServArchSave.Visible;
    aServArchRestore.Enabled := aServArchSave.Enabled;

    aMediaArchRestQAdd.Visible := aServArchSave.Visible;
    aMediaArchRestQAdd.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                  (SlidesToOperateCount > 0)             and
                                  (ArchivedCount = SlidesToOperateCount) and
                                  (ArchivedQCount = 0);

    aMediaArchRestQDel.Visible := aServArchSave.Visible;
    aMediaArchRestQDel.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                  (SlidesToOperateCount > 0)             and
                                  (ArchivedCount = SlidesToOperateCount) and
                                  (ArchivedQCount = ArchivedCount);


//    aServEmailSettings.Visible  := K_CMDesignModeFlag;

    aGoToPatients.Visible  := K_CMStandaloneGUIMode and
                              (not K_CMMarkAsDelShowFlag or (K_CMStandaloneMode <> K_cmsaLink));
    aGoToPatients.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);

    aGoToProviders.Visible := aGoToPatients.Visible;
    aGoToProviders.Enabled := aGoToPatients.Enabled;

    aGoToLocations.Visible := aGoToPatients.Visible;
    aGoToLocations.Enabled := aGoToPatients.Enabled;

    aGoToStudy.Visible := not (K_CMEDAccess is TK_CMEDDBAccess) or (K_CMEDDBVersion >= 24);
    aGoToStudy.Enabled := not SkipActSlideFiles and not (uicsAllActsDisabled in CMMUICurStateFlags);

    aViewStudyOnly.Enabled := aGoToStudy.Enabled;
    aViewStudyOnly.Visible := aGoToStudy.Visible;

    aMediaExportToD4WDocs.Visible := K_CMD4WAppRunByCOMClient or K_CMDesignModeFlag;

    aVTBCustToolBar.Enabled :=  not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                aVTBAlterations.Checked                         and
                                ((K_CMUseCustToolbarInd = 0) or (K_CMUseCustToolbarInd = 3) or
                                 ((K_CMUseCustToolbarInd > 0) and (K_CMUseCustToolbarInd < 3) and K_CMGAModeFlag));

    if ActiveFrameIsEmpty then // No Slide is opened in Active Editor Frame
    begin
//NotUsed      aEditCopyOpened.Enabled    := False;
      aViewZoom.Enabled          := False;
      aViewPanning.Enabled       := False;
      aViewFullScreen.Enabled    := False;
      aViewFitToWindow.Enabled   := False;
      aViewFullScreen.Enabled    := False;

      aEditCloseCurActive.Enabled:= False;
      aEditCloseAll.Enabled      := False;
      aEditFullScreen.Enabled    := False;
      aEditFullScreenClose.Visible := False;

      aEditDeleteOpened.Enabled  := False;
      aEditPoint.Enabled         := False;
      aEditRestOrigImage.Enabled := False;
      aEditRestOrigState.Enabled := False;

      aObjDelete.Enabled         := K_CMShowGUIFlag;
      aObjAngleNorm.Enabled      := K_CMShowGUIFlag;
      aObjAngleFree.Enabled      := K_CMShowGUIFlag;
      aObjDot.Enabled            := K_CMShowGUIFlag;
      aObjTextBox.Enabled        := K_CMShowGUIFlag;
      aObjCTA1.Enabled           := K_CMShowGUIFlag;
      aObjCTA2.Enabled           := K_CMShowGUIFlag;
      aObjCTA3.Enabled           := K_CMShowGUIFlag;
      aObjCTA4.Enabled           := K_CMShowGUIFlag;
      aObjPolyline.Enabled       := K_CMShowGUIFlag;
      aObjPolylineM.Enabled      := K_CMShowGUIFlag;
      aObjFreeHand.Enabled       := K_CMShowGUIFlag;
      aObjCalibrate1.Enabled     := K_CMShowGUIFlag;
      aObjCalibrateN.Enabled     := K_CMShowGUIFlag;
      aObjCalibrateDPI.Enabled   := K_CMShowGUIFlag;
      aObjShowHide.Enabled       := K_CMShowGUIFlag;
      aObjShowHide.Checked       := K_CMShowGUIFlag;
      aObjChangeAttrs.Enabled    := K_CMShowGUIFlag;
      aObjRectangleOld.Enabled   := K_CMShowGUIFlag;
      aObjRectangleLine.Enabled  := K_CMShowGUIFlag;
      aObjEllipseOld.Enabled     := K_CMShowGUIFlag;
      aObjEllipseLine.Enabled    := K_CMShowGUIFlag;
      aObjArrowOld.Enabled       := K_CMShowGUIFlag;
      aObjArrowLine.Enabled      := K_CMShowGUIFlag;
      aObjFLZEllipse.Enabled     := K_CMShowGUIFlag;

      aToolsRotateLeft.Enabled       := K_CMShowGUIFlag;
      aToolsRotateRight.Enabled      := K_CMShowGUIFlag;
      aToolsRotate180.Enabled        := K_CMShowGUIFlag;
      aToolsFlipHorizontally.Enabled := K_CMShowGUIFlag;
      aToolsFlipVertically.Enabled   := K_CMShowGUIFlag;
      aToolsBriCoGam.Enabled         := K_CMShowGUIFlag;
      aToolsBriCoGam1.Enabled        := K_CMShowGUIFlag;
      aToolsNegate.Enabled           := K_CMShowGUIFlag;
      aToolsNegate1.Enabled          := K_CMShowGUIFlag;
      aToolsNegate11.Enabled         := K_CMShowGUIFlag;
      aToolsSharpen.Enabled          := K_CMShowGUIFlag;
      aToolsSharpenN.Enabled         := K_CMShowGUIFlag;
      aToolsSharpen1.Enabled         := K_CMShowGUIFlag;
      aToolsSharpen2.Enabled         := K_CMShowGUIFlag;
      aToolsSharpen3.Enabled         := K_CMShowGUIFlag;
      aToolsImgSharp.Enabled         := K_CMShowGUIFlag;
      aToolsImgSmooth.Enabled        := K_CMShowGUIFlag;
      aToolsNoiseSelf.Enabled        := K_CMShowGUIFlag;
      aToolsMedian.Enabled           := K_CMShowGUIFlag;
      aToolsDespeckle.Enabled        := K_CMShowGUIFlag;

      aToolsNoiseAttrs.Enabled       := K_CMShowGUIFlag;
      aToolsNoiseAttrs1.Enabled      := K_CMShowGUIFlag;

      aToolsFilter1.Enabled          := K_CMShowGUIFlag and (aToolsFilter1.Hint <> '');
      aToolsFilter2.Enabled          := K_CMShowGUIFlag and (aToolsFilter2.Hint <> '');
      aToolsFilter3.Enabled          := K_CMShowGUIFlag and (aToolsFilter3.Hint <> '');
      aToolsFilter4.Enabled          := K_CMShowGUIFlag and (aToolsFilter4.Hint <> '');

      aToolsFilterA.Enabled          := K_CMShowGUIFlag and (aToolsFilterA.Hint <> '');
      aToolsFilterB.Enabled          := K_CMShowGUIFlag and (aToolsFilterB.Hint <> '');
      aToolsFilterC.Enabled          := K_CMShowGUIFlag and (aToolsFilterC.Hint <> '');
      aToolsFilterD.Enabled          := K_CMShowGUIFlag and (aToolsFilterD.Hint <> '');
      aToolsFilterE.Enabled          := K_CMShowGUIFlag and (aToolsFilterE.Hint <> '');
      aToolsFilterF.Enabled          := K_CMShowGUIFlag and (aToolsFilterF.Hint <> '');

      aToolsEmboss.Enabled           := K_CMShowGUIFlag;
      aToolsEmboss.Checked           := false;
      aToolsEmbossAttrs.Enabled      := K_CMShowGUIFlag;
      aToolsHistogramm2.Enabled      := K_CMShowGUIFlag;
      aToolsColorize.Enabled         := K_CMShowGUIFlag;
      aToolsColorize.Checked         := false;
      aToolsIsodens.Enabled          := K_CMShowGUIFlag;
      aToolsIsodens.Checked          := false;
      aToolsIsodensAttrs.Enabled     := K_CMShowGUIFlag;

      aToolsRotateByAngle.Enabled    := K_CMShowGUIFlag;
      aToolsAutoEqualize.Enabled     := K_CMShowGUIFlag;
      aToolsCropImage.Enabled        := K_CMShowGUIFlag;
      aToolsConvToGrey.Enabled       := K_CMShowGUIFlag;
      aToolsConvTo8.Enabled          := K_CMShowGUIFlag;
      aToolsAutoContrast.Enabled     := K_CMShowGUIFlag;
    end   // if ActiveFrameIsEmpty then
    else  //****************** No Slide in Active Editor Frame
    begin // if not ActiveFrameIsEmpty then
      PCMSlideSDBF := @CMMFActiveEdFrame.EdSlide.P.CMSDB;
      SlideSFlags := PCMSlideSDBF.SFlags;

//NotUsed            aEditCopyOpened.Enabled    := not (uicsAllActsDisabled in CMMUICurStateFlags);

      aEditCloseCurActive.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);
      CMMFActiveEdFrame.FinishEditing.Visible := (K_CMSFullScreenForm = nil) and // Full Screen Form is close
                                                 (K_CMSMainUIShowMode < 1);      // Not Photometry mode
//      aEditCloseCurActive.Visible := (K_CMSFullScreenForm = nil);
      aEditFullScreen.Enabled     := not (uicsAllActsDisabled in CMMUICurStateFlags);
      aEditFullScreenClose.Visible := K_CMSFullScreenForm <> nil;

      aViewZoom.Enabled        := not (uicsAllActsDisabled in CMMUICurStateFlags);
      aViewPanning.Enabled     := not (uicsAllActsDisabled in CMMUICurStateFlags);
      aViewFullScreen.Enabled  := not (uicsAllActsDisabled in CMMUICurStateFlags);
      aViewFitToWindow.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);


//      aEditDeleteOpened.Enabled  := cmsfIsLocked in CMMFActiveEdFrame.EdSlide.P.CMSRFlags;
      aEditDeleteOpened.Enabled  := not SkipActSlideFiles                    and
                                    (K_uarDelete in K_CMCurUserAccessRights) and
                                    (CMMFActiveEdFrame.EdVObjSelected = nil) and
                                    (not ActiveStudyIsOpened or (ActiveStudySlidesCount = 0));

      aEditDeleteOpened.Visible  := (K_CMSFullScreenForm = nil);
      aEditPoint.Enabled         := not (uicsAllActsDisabled in CMMUICurStateFlags);
//      aEditRestOrig.Enabled      := cmsfHasSrcImg in CMMFActiveEdFrame.EdSlide.P.CMSFlags;

      aObjDelete.Enabled         := NotReadOnlyMode and (CMMFActiveEdFrame.EdVObjSelected <> nil);
      aObjAngleNorm.Enabled      := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aObjAngleFree.Enabled      := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aObjDot.Enabled            := NotReadOnlyMode;
      aObjTextBox.Enabled        := NotReadOnlyMode;
      aObjCTA1.Enabled           := NotReadOnlyMode;
      aObjCTA2.Enabled           := NotReadOnlyMode;
      aObjCTA3.Enabled           := NotReadOnlyMode;
      aObjCTA4.Enabled           := NotReadOnlyMode;
      aObjPolyline.Enabled       := NotReadOnlyMode;
      aObjPolylineM.Enabled      := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aObjFreeHand.Enabled       := NotReadOnlyMode;
      aObjCalibrate1.Enabled     := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aObjCalibrateN.Enabled     := aObjCalibrate1.Enabled;
      aObjCalibrateDPI.Enabled   := aObjCalibrate1.Enabled;
      aObjRectangleOld.Enabled   := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aObjRectangleLine.Enabled  := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aObjEllipseOld.Enabled     := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aObjEllipseLine.Enabled    := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aObjArrowOld.Enabled       := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aObjArrowLine.Enabled      := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aObjFLZEllipse.Enabled     := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
{
      aObjCalibrate.Enabled      := (CMMFActiveEdFrame.EdVObjSelected <> nil) and
                                    (CMMFActiveEdFrame.EdVObjSelected.ObjName[1] = 'M');
}
      aObjShowHide.Enabled       := not ActiveStudyIsOpened and not (uicsAllActsDisabled in CMMUICurStateFlags);
      aObjChangeAttrs.Enabled    := NotReadOnlyMode and
                                   (CMMFActiveEdFrame.EdVObjSelected <> nil);
{
      aObjChangeAttrs.Enabled    := NotReadOnlyMode and
                                   (CMMFActiveEdFrame.EdVObjSelected <> nil) and
                                   (CMMFActiveEdFrame.EdVObjSelected.ObjName[1] <> 'Z'); // Temporary Code - Skip Flashlight Attrs Edit
}
//      aObjShowHide.Enabled   := not (cmsfHideDrawings in CMMFActiveEdFrame.EdSlide.P()^.CMSRFlags);

      aToolsRotateLeft.Enabled       := NotReadOnlyMode;
      aToolsRotateRight.Enabled      := NotReadOnlyMode;
      aToolsRotate180.Enabled        := NotReadOnlyMode;
      aToolsFlipHorizontally.Enabled := NotReadOnlyMode;
      aToolsFlipVertically.Enabled   := NotReadOnlyMode;
      aToolsRotateByAngle.Enabled    := NotReadOnlyMode;
//      aToolsRotateByAngle.Enabled    := NotReadOnlyMode and (CMMFActiveEdFrame.EdSLide.GetCurrentImage.DIBObj.DIBExPixFmt <> epfGray16);
      aToolsNegate.Enabled           := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aToolsNegate1.Enabled          := NotReadOnlyMode and not (uicsAllActsDisabled in CMMUICurStateFlags) and(K_CMSLiRegStatus > K_lrtLight);
      aToolsCropImage.Enabled        := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aToolsSharpen.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aToolsSharpenN.Enabled         := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aToolsSharpen1.Enabled         := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aToolsSharpen2.Enabled         := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (cmsfGreyScale in SlideSFlags);
      aToolsSharpen3.Enabled         := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (cmsfGreyScale in SlideSFlags);
      aToolsImgSharp.Enabled         := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);
      aToolsImgSmooth.Enabled        := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);

      aToolsFilter1.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (aToolsFilter1.Hint <> '');
      aToolsFilter2.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (aToolsFilter2.Hint <> '');
      aToolsFilter3.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (aToolsFilter3.Hint <> '');
      aToolsFilter4.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (aToolsFilter4.Hint <> '');

      aToolsFilterA.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (aToolsFilterA.Hint <> '');
      aToolsFilterB.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (aToolsFilterB.Hint <> '');
      aToolsFilterC.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (aToolsFilterC.Hint <> '');
      aToolsFilterD.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (aToolsFilterD.Hint <> '');
      aToolsFilterE.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (aToolsFilterE.Hint <> '');
      aToolsFilterF.Enabled          := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight) and (aToolsFilterF.Hint <> '');

      aToolsEmboss.Enabled           := not ActiveStudyIsOpened and not (uicsAllActsDisabled in CMMUICurStateFlags) and (K_CMSLiRegStatus > K_lrtLight);
      aToolsEmbossAttrs.Enabled      := not ActiveStudyIsOpened and not (uicsAllActsDisabled in CMMUICurStateFlags) and (K_CMSLiRegStatus > K_lrtLight);
      aToolsHistogramm2.Enabled      := not ActiveStudyIsOpened and not (uicsAllActsDisabled in CMMUICurStateFlags) and (K_CMSLiRegStatus > K_lrtLight);
//      aToolsHistogramm2.Enabled  := (cmsfGreyScale in SlideSFlags) and not (uicsAllActsDisabled in CMMUICurStateFlags) and (K_CMSLiRegStatus > K_lrtLight);
      // Code From SetActive EdFrame

//      with CMMFActiveEdFrame.EdSlide, P()^ do begin
      aToolsBriCoGam.Enabled     := NotReadOnlyMode and not (cmsfShowEmboss in SlideSFlags);
      aToolsBriCoGam1.Enabled    := NotReadOnlyMode and aToolsBriCoGam.Enabled;
      aToolsColorize.Enabled     := not ActiveStudyIsOpened and (cmsfGreyScale in SlideSFlags) and
                                    not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                    (K_CMSLiRegStatus > K_lrtLight);
      aToolsIsodens.Enabled      := not ActiveStudyIsOpened and (cmsfGreyScale in SlideSFlags) and
                                    not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                    (K_CMSLiRegStatus > K_lrtLight);
//                                    (K_CMSLiRegStatus > K_lrtLight) and
//                                    (CMMEdVEMode <> cmrfemFlashLight);
      aToolsIsodensAttrs.Enabled := aToolsIsodens.Enabled;
//        aToolsIsodensAttrs.Enabled := aToolsIsodens.Enabled and NotReadOnlyMode;

      aToolsAutoEqualize.Enabled := NotReadOnlyMode and (cmsfGreyScale in SlideSFlags) and (K_CMSLiRegStatus > K_lrtLight);
      aToolsNoiseSelf.Enabled    := NotReadOnlyMode and (cmsfGreyScale in SlideSFlags) and (K_CMSLiRegStatus > K_lrtLight);
      aToolsMedian.Enabled       := NotReadOnlyMode and (cmsfGreyScale in SlideSFlags) and (K_CMSLiRegStatus > K_lrtLight);
      aToolsDespeckle.Enabled    := NotReadOnlyMode and (K_CMSLiRegStatus > K_lrtLight);

      aToolsNoiseAttrs.Enabled   := NotReadOnlyMode and (cmsfGreyScale in SlideSFlags) and (K_CMSLiRegStatus > K_lrtLight);
      aToolsNoiseAttrs1.Enabled  := NotReadOnlyMode and (cmsfGreyScale in SlideSFlags) and (K_CMSLiRegStatus > K_lrtLight);

      aToolsColorize.Checked := aToolsColorize.Enabled and (cmsfShowColorize   in SlideSFlags);
      aToolsIsodens.Checked  := aToolsIsodens.Enabled  and (cmsfShowIsodensity in SlideSFlags);
      aToolsEmboss.Checked   := aToolsEmboss.Enabled   and (cmsfShowEmboss in SlideSFlags);

      aToolsNegate11.Enabled   := not ActiveStudyIsOpened and not (uicsAllActsDisabled in CMMUICurStateFlags) and(K_CMSLiRegStatus > K_lrtLight);
      aToolsNegate11.Checked   := aToolsNegate11.Enabled  and
        (K_smriNegateImg in CMMFActiveEdFrame.EdSlide.GetPMapRootAttrs.MRImgFlags);

      aToolsConvToGrey.Enabled := NotReadOnlyMode and not (cmsfGreyScale in SlideSFlags) and (K_CMSLiRegStatus > K_lrtLight);
      aToolsConvTo8.Enabled := NotReadOnlyMode and (cmsfGreyScale in SlideSFlags) and
                               (PCMSlideSDBF.PixBits > 8) and (K_CMSLiRegStatus > K_lrtLight);
      aToolsAutoContrast.Enabled := NotReadOnlyMode and (cmsfGreyScale in SlideSFlags) and
                                   (K_CMSLiRegStatus > K_lrtLight);
    end;  // if not ActiveFrameIsEmpty then

    if not (uicsAllActsDisabled in CMMUICurStateFlags) then
    begin
      aEditCloseAll.Enabled  := FALSE;
      for i := 0 to High(CMMFEdFrames) do
      begin
        aEditCloseAll.Enabled := (CMMFEdFrames[i] <> nil) and
                                 CMMFEdFrames[i].Visible  and
                                 (CMMFEdFrames[i].EdSlide <> nil);
        if aEditCloseAll.Enabled then break;
      end; // for i := 0 to High(CMMFEdFrames) do
    end; // if not (uicsAllActsDisabled in CMMUICurStateFlags) then

    aViewOneSquare.Enabled     := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                 ( not K_CMStudySingleOpenGUIModeFlag or not ActiveStudyIsOpened );
    aViewTwoHorizontal.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                 ( not K_CMStudySingleOpenGUIModeFlag or not ActiveStudyIsOpened );
    aViewTwoVertical.Enabled   := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                 ( not K_CMStudySingleOpenGUIModeFlag or not ActiveStudyIsOpened );
    aViewFourSquares.Enabled   := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                 ( not K_CMStudySingleOpenGUIModeFlag or not ActiveStudyIsOpened );
    aViewNineSquares.Enabled   := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                 ( not K_CMStudySingleOpenGUIModeFlag or not ActiveStudyIsOpened );

    aToolsFlashLightMode.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                    (K_FormCMSIsodensity = nil);
//                                    not aToolsIsodens.Checked;



    //***** Process ClipboardIsEmpty flag
{ //NotUsed
    if ClipboardIsEmpty then // Slides Clipboard is Empty
    begin
      aEditPaste.Enabled := False;
    end else //**************** Slides Clipboard is not Empty
    begin
      aEditPaste.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);
    end;
}

    //***** Process SelectionIsEmpty flag
{
    aMediaOpen.Enabled := not SkipActSlideFiles and
                          not (ActiveStudyNoSelected and ThumbFrameSelectionIsEmpty) and
                          (K_CMSFullScreenForm = nil) and
                          ( not K_CMStudySingleOpenGUIModeFlag or
                            (StudiesToOperateCount = 0)     or
                            ( (StudiesToOperateCount = SlidesToOperateCount) and
                              (StudiesToOperateCount = 1) ) );
}
    aMediaOpen.Enabled := not SkipActSlideFiles                              and
                          not (ActiveStudyNoSelected and
                               ThumbFrameSelectionIsEmpty)                   and
                          (K_CMSFullScreenForm = nil)                        and
                          ( (StudiesToOperateCount = 0) or
                            (StudiesToOperateCount = SlidesToOperateCount) ) and
                          ( not K_CMStudySingleOpenGUIModeFlag or
                            (StudiesToOperateCount = 0)        or
                            (StudiesToOperateCount = 1) )                    and
                          ( (Img3DToOperateCount = 0) or
                            ( (Img3DToOperateCount = SlidesToOperateCount) and
                              (Img3DToOperateCount = 1) ) );

    aMediaAddToOpened.Enabled := aMediaOpen.Enabled;

    aMediaExport3D.Enabled := (SlidesToOperateCount = 1) and
                              (Img3DToOperateCount = 1);
//                              (Img3DToOperateCount = 1)  and
//                              (Img3DDevCount = 0);

    if ThumbFrameSelectionIsEmpty then // No Marked Slide
    begin
//NotUsed            aEditPaste.Enabled          := False;
//NotUsed            aEditCut.Enabled            := False;
//NotUsed            aEditCopyMarked.Enabled     := False;

      aEditDeleteMarked.Enabled   := False;
      aEditClearSelection.Enabled := False;
    end
    else //**************** There are some Marked Slides
    begin
//NotUsed            aEditPaste.Enabled          := not (uicsAllActsDisabled in CMMUICurStateFlags);
//NotUsed            aEditCut.Enabled            := not (uicsAllActsDisabled in CMMUICurStateFlags);
//NotUsed            aEditCopyMarked.Enabled     := not (uicsAllActsDisabled in CMMUICurStateFlags);

      aEditDeleteMarked.Enabled   := not SkipActSlideFiles                              and
                                     (K_uarDelete in K_CMCurUserAccessRights)           and
                                     (not ActiveStudyIsOpened or ActiveStudyNoSelected) and // Active Frame is not Study or Active Sudy has no Selected Images
                                     (StudiesToOperateCount = EmptyStudiesToOperateCount);  // Selected list contains no studies or empty studies only

      aEditClearSelection.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);
    end;

    aGoToPropDiagMulti.Enabled  := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                   (K_uarModify in K_CMCurUserAccessRights)        and
                                   (not NoSlidesToOperate or (ArchivedCount > 0))  and
                                   ( (StudiesToOperateCount = 0) or
                                     (StudiesToOperateCount = SlidesToOperateCount) );
//                                     (StudiesToOperateCount <> SlidesToOperateCount);
    aDICOMMWL.Visible   := K_CMDICOMNewFlag and
                           (K_CMEDAccess is TK_CMEDDBAccess) and
                           K_CMDICOMVisible();
    aDICOMStore.Visible := aDICOMMWL.Visible;
    aDICOMCommitment.Visible := aDICOMMWL.Visible;

    // It was under constraction
    aDICOMQuery.Visible := aDICOMMWL.Visible and (K_CMEDDBVersion >= 46);

    aDICOMDIRExport.Visible := not K_CMDICOMNewFlag and (K_CMEDAccess is TK_CMEDDBAccess);

    if NoSlidesToOperate then // No Slides to operate
    begin
      aGoToPrint.Enabled            := False;
      aGoToPrintStudiesOnly.Enabled := False;
//      aGoToPropDiag.Enabled       := False;
//      aGoToPropDiagMulti.Enabled    := False;
      aMediaEmail.Enabled           := False;
      aMediaEmail1.Enabled          := False;
      aMediaDuplicate.Enabled       := False;
      aMediaExportOpened.Enabled    := False;
      aMediaExportToD4WDocs.Enabled := False;
      aMediaExportMarked.Enabled    := False;
      aDICOMExport.Enabled          := False;
      aDICOMDIRExport.Enabled       := False;
      aDICOMStore.Enabled           := False;
      aDICOMCommitment.Enabled      := False;

      aMediaWCExport.Enabled        := False;
      aViewPresentation.Enabled     := False;
    end   // if NoSlidesToOperate then
    else  //**************** There are some Slides to operate
    begin // if not NoSlidesToOperate then
//      aGoToPropDiag.Enabled       := not (uicsAllActsDisabled in CMMUICurStateFlags);
{
      aGoToPropDiagMulti.Enabled  := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                     (K_uarModify in K_CMCurUserAccessRights)        and
                                     (not NoSlidesToOperate or (ArchivedCount > 0))  and
                                     ( (StudiesToOperateCount = 0) or
                                       (StudiesToOperateCount = SlidesToOperateCount) );
//                                     (StudiesToOperateCount <> SlidesToOperateCount);
}
      aMediaEmail.Enabled         := not SkipActSlideFiles and
                                     (K_uarEmail in K_CMCurUserAccessRights) and
                                     not K_CMMarkAsDelShowFlag and
                                     (Img3DToOperateCount = 0);
// 2020-07-28 add Img3DDevCount      (Img3DToOperateCount = 0) and
// 2020-07-28 add Img3DDevCount      (Img3DDevCount = 0);
      aMediaEmail1.Enabled        := aMediaEmail.Enabled;

      aMediaExportOpened.Enabled  := not SkipActSlideFiles and
                                     (K_uarExport in K_CMCurUserAccessRights) and
                                     not K_CMMarkAsDelShowFlag and
// 2020-07-28 add Img3DDevCount      (Img3DDevCount = 0) and
       ((Img3DToOperateCount = 0) or (SlidesToOperateCount = Img3DToOperateCount));
// 2020-02-11 add 3D export          (Img3DToOperateCount = 0);
      aMediaExportMarked.Enabled  := not SkipActSlideFiles and
                                     (K_uarExport in K_CMCurUserAccessRights) and
                                     not K_CMMarkAsDelShowFlag and
// 2020-07-28 add Img3DDevCount      (Img3DDevCount = 0) and
                                     ((Img3DToOperateCount = 0) or (SlidesToOperateCount = Img3DToOperateCount));
// 2020-02-11 add 3D export          (Img3DToOperateCount = 0);

      aMediaExportToD4WDocs.Enabled := not SkipActSlideFiles and
                                     (K_uarExport in K_CMCurUserAccessRights) and
                                     not K_CMMarkAsDelShowFlag and
                                     (Img3DToOperateCount = 0) and
                                     (K_CMD4WPatDocPath <> '');


//      aDICOMExport.Enabled  := aMediaExportMarked.Enabled and
//                               (K_CMD4WAppRunByClient or K_CMStandaloneGUIMode);
      aDICOMExport.Enabled  := not SkipActSlideFiles and
                               (K_uarExport in K_CMCurUserAccessRights) and
                               not K_CMMarkAsDelShowFlag                and
                               (Img3DToOperateCount = 0);
//                               (((Img3DToOperateCount = 0) and (VideoToOperateCount =0))
//                                                 or
//                                      (SlidesToOperateCount = VideoToOperateCount) );

      aDICOMStore.Enabled  := not SkipActSlideFiles       and
                              not K_CMMarkAsDelShowFlag   and
                              (StudiesToOperateCount = 0) and
                              (VideoToOperateCount = 0)   and
                              (Img3DToOperateCount = 0);
      aDICOMCommitment.Enabled := aDICOMStore.Enabled;

      aMediaWCExport.Enabled := not SkipActSlideFiles and
                               (K_uarExport in K_CMCurUserAccessRights) and
                               (VideoToOperateCount = 0) and
                               not K_CMMarkAsDelShowFlag and
                               (Img3DToOperateCount = 0);

      aMediaDuplicate.Enabled     := not SkipActSlideFiles and
                                     (K_uarDuplicate in K_CMCurUserAccessRights) and
                                     not K_CMMarkAsDelShowFlag and
                                     (StudiesToOperateCount = 0) and
                                     (Img3DToOperateCount = 0);
//                                     (StudiesToOperateCount <> SlidesToOperateCount);

      aGoToPrint.Enabled     := not SkipActSlideFiles and
                                (K_uarPrint in K_CMCurUserAccessRights) and
                                not K_CMMarkAsDelShowFlag and
                                (Img3DToOperateCount = 0) and
                                (VideoToOperateCount = 0);
{!!! not needed now because of VideoToOperateCount
      if aGoToPrint.Enabled then
      begin
        aGoToPrint.Enabled := FALSE;
        for i := 0 to High(CMMAllSlidesToOperate) do
        begin
          if cmsfIsMediaObj in CMMAllSlidesToOperate[i].P().CMSDB.SFlags then Continue;
          aGoToPrint.Enabled := TRUE;
          Break;
        end;
      end;
}
      aGoToPrintStudiesOnly.Enabled := aGoToPrint.Enabled and (StudiesToOperateCount > 0);

      aViewPresentation.Enabled := not SkipActSlideFiles and
                                   not K_CMMarkAsDelShowFlag and
                                   (Img3DToOperateCount = 0) and
                                   (VideoToOperateCount = 0);
    end; // if not NoSlidesToOperate then

    aViewDisplayDel.Visible := K_CMMarkAsDelUseFlag;
    aViewDisplayDelButton.Visible := K_CMMarkAsDelUseFlag;
    aViewDisplayDel.Enabled := (K_uarDelete in K_CMCurUserAccessRights)and
                               not (uicsAllActsDisabled in CMMUICurStateFlags);
    aViewDisplayDelButton.Enabled := (K_uarDelete in K_CMCurUserAccessRights)  and
                               not (uicsAllActsDisabled in CMMUICurStateFlags) and
                               (K_CMMarkedAsDeletedCount > 0);
    aEditRestoreDel.Visible := K_CMMarkAsDelShowFlag and aViewDisplayDel.Visible;
    aEditRestoreDel.Enabled := FALSE;
//    aEditDeleteOpened.Caption := 'Delete Opened Image';
//    aEditDeleteMarked.Caption := 'De&lete';
    aEditDeleteOpened.Caption := aEditDeleteOpenedCapt.Caption;
    aEditDeleteMarked.Caption := aEditDeleteMarkedCapt.Caption;

    aViewDisplayArchived.Visible := K_CMEDDBVersion >= 41;
    aViewDisplayArchived.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);

    if not NoSlidesToOperate and aViewDisplayDel.Visible  and K_CMMarkAsDelShowFlag then
    begin
      // Calc number of marked in selection
      NumMarkedAsDel := 0;
      for i := 0 to High(CMMAllSlidesToOperate) do
        if cmsdbfMarkedAsDel in CMMAllSlidesToOperate[i].CMSDBStateFlags then Inc(NumMarkedAsDel);

      if NumMarkedAsDel = SlidesToOperateCount then
      begin // Only Marked Selected
        aEditDeleteMarked.Caption := aEditDeleteMarkedForEver.Caption;
//        aEditDeleteMarked.Caption := 'De&lete for ever';
      end
      else
      begin // if NumMarkedAsDel <> SlidesToOperateCount then - is actual only if MarkAsDel and NotMarkedAsDel Slides are visible
        if aEditDeleteMarked.Enabled then
          aEditDeleteMarked.Enabled := NumMarkedAsDel = 0; // Only not Marked Selected ???
      end;

      if aEditDeleteOpened.Enabled then
      begin
        if cmsdbfMarkedAsDel in CMMFActiveEdFrame.EdSlide.CMSDBStateFlags then
          aEditDeleteOpened.Caption := aEditDeleteOpenedForEver.Caption;
//          aEditDeleteOpened.Caption := 'Delete Opened Image for ever';
      end;

      if aEditRestoreDel.Visible then
        aEditRestoreDel.Enabled := NumMarkedAsDel = SlidesToOperateCount;
    end; // if not NoSlidesToOperate and aViewDisplayDel.Visible  and K_CMMarkAsDelShowFlag then

//    aEditDeleteCommon.Enabled := aEditDeleteOpened.Enabled or aEditDeleteMarked.Enabled;

    aEditDeleteCommon.Enabled := not SkipActSlideFiles                   and
                                (K_uarDelete in K_CMCurUserAccessRights) and
                                ( aEditDeleteOpened.Enabled or
                                  aEditDeleteMarked.Enabled or
                                  aObjDelete.Enabled );


    if ThumbFrameNoSlides then // No Thumbnails are visible
    begin
      aEditInvertSelection.Enabled := False;
      aEditSelectAll.Enabled := false
    end
    else // Some Thumbnails are visible
    begin
      aEditInvertSelection.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);
      with CMMCurFThumbsDGrid do
        aEditSelectAll.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags) and ((DGMarkedList.Count <> Length(DGItemsFlags)));
    end;

    aMediaImport.Enabled     := not SkipActSlideFiles and
                                (K_uarImport in K_CMCurUserAccessRights) and
                                not K_CMMarkAsDelShowFlag and
                                (K_CMSFullScreenForm = nil);
    aMediaImport3D.Visible   := ((K_CMSLiRegStatus = K_lrtComplex) and
                                not (limdImg3D in K_CMSLiRegModDisable))
                                        or
                                ((K_CMEDAccess is TK_CMEDDBAccess)  and K_CMDesignModeFlag);
    aMediaImport3D.Enabled   := aMediaImport.Enabled and
                                aMediaImport3D.Visible;
//    aDICOMImport.Enabled    := aMediaImport.Enabled and
//                               K_CMStandaloneGUIMode and
//                               (K_CMStandaloneMode <> K_cmsaLink);
    aDICOMImport.Enabled       := aMediaImport.Enabled;
    aDICOMImportFolder.Enabled := aMediaImport.Enabled;
    aDICOMDIRImport.Enabled    := aDICOMImport.Enabled;
    aDICOMQuery.Enabled        := aDICOMImport.Enabled and (K_CMEDDBVersion >= 46);
// Temp Code Before DICOMQuery design will be finished
//    aDICOMQuery.Visible        := K_CMDesignModeFlag;
//    aServDCMSetup.Visible      := K_CMDesignModeFlag and (K_CMGAModeFlag or (K_CMDCMQRSettingsStoreMode = 2));
//    aServDCMSetup.Visible      := (K_CMGAModeFlag or (K_CMDCMSettingsStoreMode = 2));
    aServDCMSetup.Visible      := K_CMGAModeFlag;

    aGoToPreferences.Enabled := not SkipActSlideFiles and
                                (K_uarPreferences in K_CMCurUserAccessRights);

    aViewThumbRefresh.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);
    aViewThumbRefresh.Visible := not K_CMDemoModeFlag;


    // Set Capture Actions.Enabled by Buttons in Capture ToolBar
    CaptActsEnabled := not CMMCaptActsDisabled and
                       not SkipActSlideFiles   and
                       not K_CMMarkAsDelShowFlag;

    aCapClientScan.Visible := K_CMScanIsInstalled;
    aCapClientScan.Enabled := CaptActsEnabled;

    aCaptByDentalUnit.Enabled := CaptActsEnabled;

    aServExportSlidesAll.Visible := K_CMGAModeFlag;
    aServExportSlidesAll.Enabled := aServExportSlidesAll.Visible;

    OnExecuteHandler := VideoOnExecuteHandler;
    
    if CMMCurCaptToolBar <> nil then
    for i := 0 to CMMCurCaptToolBar.ButtonCount - 1 do
      with CMMCurCaptToolBar.Buttons[i] do
        if Action <> nil then
        begin
// is removed because changing ToolButtons visibility to FALSE is bad for
// ToolBar next adding new buttons. ToolButtons are not added to ToolBar istead
//          TAction(Action).Visible := K_uarCapture in K_CMCurUserAccessRights;

          NEVar := TAction(Action).OnExecute;
                            //  Device Limitatiom      not Modal Capture Interface
          TAction(Action).Enabled := Assigned(NEVAR) and CaptActsEnabled and
          // Set Disable state for Capture Actions if CMS Light Version Type and not Video Capture Device Action
            ( (K_CMSLiRegStatus > K_lrtLight) or
//              CompareMem( @TAction(Action).OnExecute, @OnExecuteHandler, SizeOf(TNotifyEvent)));
//              CompareMem( @@NEVar, @@OnExecuteHandler, SizeOf(TNotifyEvent) ) );
              (TMethod(NEVar).Code = TMethod(OnExecuteHandler).Code) );
        end;

    aEditSelectAllCommon.Enabled := aEditSelectAll.Enabled or aEditStudySelectAll.Enabled;
//    aDeb2CreateDemoExeDistr.Visible :=  not (K_CMEDAccess is TK_CMEDDBAccess);

    aServLaunchIUApp.Visible := (K_CMEDAccess <> nil) and (K_CMEDAccess is TK_CMEDDBAccess);
    aServLaunchIUApp.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags) and
                                (K_CMIUCheckUpdatesPath <> '') and
                                FileExists(K_CMIUCheckUpdatesPath);

  end; // with N_CMResForm do


  if Assigned(CMMCurMenuItemsDisableProc) then
    CMMCurMenuItemsDisableProc();


  CMMFDisableUNDOActions();

  DicomViewerActive := ((CMMCurFMainForm as TK_FormCMMain5).pgcViewerHolder.ActivePageIndex = 1);

  if DicomViewerActive then
  with N_CMResForm do
  begin
    aViewOneSquare.Enabled := not DicomViewerActive;
    aViewTwoHorizontal.Enabled := not DicomViewerActive;
    aViewTwoVertical.Enabled := not DicomViewerActive;
    aViewFourSquares.Enabled := not DicomViewerActive;
    aViewNineSquares.Enabled := not DicomViewerActive;
    aViewStudyOnly.Enabled := not DicomViewerActive;
    aEditCloseAll.Enabled := not DicomViewerActive;
    aViewZoomMode.Enabled := not DicomViewerActive;
    aViewDisplayDelButton.Enabled := not DicomViewerActive;
    aViewFitToWindow.Enabled := not DicomViewerActive;
    aEditFullScreen.Enabled := not DicomViewerActive;
    //aMediaOpen.Enabled := not DicomViewerActive;
    aGoToPropDiagMulti.Enabled := not DicomViewerActive;
    aMediaEMail1.Enabled := not DicomViewerActive;
    aMediaExportMarked.Enabled := not DicomViewerActive;
    aToolsFilterA.Enabled := not DicomViewerActive;
    aToolsFilterB.Enabled := not DicomViewerActive;
    aToolsFilterC.Enabled := not DicomViewerActive;
    aToolsFilterD.Enabled := not DicomViewerActive;
    aToolsFilterE.Enabled := not DicomViewerActive;
    aToolsFilterF.Enabled := not DicomViewerActive;
    aToolsFlashLightMode.Enabled := not DicomViewerActive;
    aGoToPrint.Enabled := not DicomViewerActive;
  end;
end; // procedure TN_CMMain5Form1.CMMFDisableActions

//************************************* TN_CMMain5Form1.EdFramesContextPopup ***
// Disable needed Actions before showing Editor Frames PopupMenu
//
//     Parameters
// Sender - Event Sender Control
// MousePos - Mouse Coords in client coordinates
// Handled  - on output, should be set to True if appropriate PopupMenu should not be shown
//
// Editor Frames OnContextPopup event handler
//
procedure TN_CMMain5Form1.EdFramesContextPopup( Sender: TObject;
                                       MousePos: TPoint; var Handled: Boolean );
begin
  CMMFDisableActions( Sender ); // not needed?
end; // procedure TN_CMMain5Form1.EdFramesContextPopup

//********************************* TN_CMMain5Form1.ThumbsRFrameContextPopup ***
// Disable needed Actions before showing ThumbsRFrame PopupMenu
//
//     Parameters
// Sender - Event Sender Control
// MousePos - Mouse Coords in client coordinates
// Handled  - on output, should be set to True if appropriate PopupMenu should not be shown
//
// ThumbsRFrame OnContextPopup event handler
//
procedure TN_CMMain5Form1.ThumbsRFrameContextPopup( Sender: TObject;
                                       MousePos: TPoint; var Handled: Boolean );
//var
//  ActEnabled : Boolean;
begin
  CMMFDisableActions( Sender );
{!!! obsolete code all is done in CMMFDisableActions
  ActEnabled := CMMCurFThumbsDGrid.DGMarkedList.Count <> 0;
  with N_CMResForm do begin
    PropertiesDiagnoses1.Enabled := ActEnabled;
    Print1.Enabled     := ActEnabled;
    Export1.Enabled    := ActEnabled;
    Open1.Enabled      := ActEnabled;
    Email1.Enabled     := ActEnabled;
    Delete1.Enabled    := ActEnabled;
    Duplicate1.Enabled := ActEnabled;
  end;
}
end; // procedure TN_CMMain5Form1.ThumbsRFrameContextPopup

//************************************* TN_CMMain5Form1.ThumbsRFrameDblClick ***
// Define proper EdFrame and Open Double Clicked Slide in it
//
//     Parameters
// Sender - Event Sender Control
//
// ThumbsRFrame.PaintBox Double Click Handler
//
procedure TN_CMMain5Form1.ThumbsRFrameDblClick( Sender: TObject );

begin
  N_Dump1Str( 'Start Thumbnail DoubleClick Action' );

  if N_CMResForm.aMediaAddToOpened.Enabled then
  begin
    N_CMResForm.aMediaAddToOpenedExecute( N_CMResForm.aMediaAddToOpened );
  end
  else
  if N_CMResForm.aMediaArchRestQAdd.Enabled then
  begin
    N_CMResForm.aMediaArchRestQAddExecute( N_CMResForm.aMediaArchRestQAdd );
  end
  else
  if N_CMResForm.aMediaArchRestQDel.Enabled then
  begin
    N_CMResForm.aMediaArchRestQDelExecute( N_CMResForm.aMediaArchRestQDel );
  end;

  if Sender <> nil then
    CMMThumbsFrameDblClickFlag := TRUE;

  N_Dump2Str( 'Finish Thumbnail DoubleClick Action' );
end; // end of procedure TN_CMMain5Form1.ThumbsRFrameDblClick

//************************************** TN_CMMain5Form1.ThumbsRFrameEndDrag ***
// Thumbnails Frame End Drag Handler for Drag Slides
//
//     Parameters
// Sender - Event Sender Control (ThumbsRFrame)
// Target - Event Target Control (ThumbsRFrame)
// X, Y   - cursor screen coordinates
//
procedure TN_CMMain5Form1.ThumbsRFrameEndDrag( Sender, Target: TObject;
                                              X, Y: Integer );
var
//  SelectedSlideFrame : TN_CMREdit3Frame;
  SlideToMount : TN_UDCMSlide;
  UnLockSlide : Boolean;
label ClearDragContext;
begin
  if Target = nil then
  begin
ClearDragContext:
    CMMRedrawDragOverComponent( 0 ); // Clear Previouse Drag Over Component
    CMMCurBeginDragControl := nil;
    CMMCurDragObject := nil;
    CMMCurDragObjectsList.Clear;
    Exit;
  end;
 //  Search Target Ed3Frame
  while not (Target is TN_CMREdit3Frame) do Target := TControl(Target).Parent;

  with CMMCurFThumbsDGrid do
//    if DGMarkedList.Count > 1 then
    if CMMCurDragObjectsList.Count > 1 then
    begin
      if N_CMResForm.aMediaOpen.Enabled then
      begin
        N_Dump1Str( 'Start Open Action by Multi EndDrag' );
        N_CMResForm.aMediaOpenExecute( N_CMResForm.aMediaOpen )
      end
      else
        goto ClearDragContext;
    end
    else
    begin
    //*** Mark less Objects then Frames in Current Frames Layout
      if CMMCurDragOverComp <> nil then
      begin // Mount Slide to Study
        SlideToMount := TN_UDCMSlide(CMMCurDragObject);
        K_CMSlidesLockForOpen( @SlideToMount, 1, K_cmlrmOpenLock );
        UnLockSlide := K_CMEDAccess.LockResCount = 1;
        CMMStudyEndDrug( not UnLockSlide );
        if UnLockSlide then
          K_CMEDAccess.EDAUnlockSlides( @SlideToMount, 1, K_cmlrmOpenLock );
        K_CMEDAccess.LockResCount := 0;
      end
      else
      begin // Open Slide in Viewport or move between Viewports
  //        SelectedSlideFrame := CMMFFindEdFrame( TN_UDCMSlide(K_CMCurVisSlidesArray[DGSelectedInd]) );
        CMMSlideEndDrag( TN_UDCMSlide(CMMCurDragObject), TN_CMREdit3Frame(Target) );
{
        SlideToOpen := TN_UDCMSlide(CMMCurDragObject);
        CMMSlideEndDrag( SlideToOpen )
        CMMCurBeginDragControl := nil;
        CMMCurDragObject := nil;
        SelectedSlideFrame := CMMFFindEdFrame( SlideToOpen );


        if (SelectedSlideFrame <> nil)  then
        begin
          K_CMShowMessageDlgByTimer( K_CML1Form.LLLThumbsRFrame1.Caption,
//            'This object is already open',
                                    mtInformation );
          Exit;
        end;

       // Prepare Selected Frame to Open new Slide
        N_BrigHist2Form.SetSkipSelfClose( TRUE );
        CMMFSetActiveEdFrame( TN_CMREdit3Frame(Target), TRUE );
        TN_CMREdit3Frame(Target).EdFreeObjects();
        N_BrigHist2Form.SetSkipSelfClose( FALSE );
    //
     // Open new Slide
        ThumbsRFrameDblClick( nil );
}

      end;
    end;
//  N_CMResForm.aMediaOpenExecute( nil );
end; // end of procedure TN_CMMain5Form1.ThumbsRFrameEndDrag

//************************************** TN_CMMain5Form1.StatusBarTimerTimer ***
// Stop preserving StatusBar content
//
//     Parameters
// Sender - Event Sender
//
// StatusBarTimer.Enabled field is used as
// "StatusBar content should be preserved" flag.
//
// StatusBarTimer onTimer handler
//
procedure TN_CMMain5Form1.StatusBarTimerTimer( Sender: TObject );
begin
  StatusBarTimer.Enabled := False;

  // Show Close CMS Application Dialog to start Service Procedures
{
  if CMMShowCloseApplicationDlgForm <> nil then
    with CMMShowCloseApplicationDlgForm do
      try
        ShowModal();
      finally
        Release;
      end;
  CMMShowCloseApplicationDlgForm := nil;
}
end; // procedure TN_CMMain5Form1.StatusBarTimerTimer

//******************************************** TN_CMMain5Form1.ActTimerTimer ***
// Execute Actions
//
//     Parameters
// Sender - Event Sender
//
// ActTimer onTimer handler
//
procedure TN_CMMain5Form1.ActTimerTimer( Sender: TObject );
var
  i : Integer;
begin
  N_Dump1Str( 'ActTimerTimer Start' );
  ActTimer.Enabled := False;
  if K_CMD4WAppFinState  then
  begin
    N_Dump1Str( 'ActTimerTimer exit on K_CMD4WAppFinState' );
    Exit;
  end;
  N_Dump2Str( 'ActTimerTimer start' );

  ActTimer.Interval := 10;

// Check if Service Actions are Enabled
  if (uicsAllActsDisabled in CMMUICurStateFlags) then
    CMMFDisableActions( Sender );

  CMMServActionsExec := (CMMServActions <> nil) and (CMMServActions.Count > 0);
  if CMMServActionsExec then
  begin
    N_Dump2Str( 'ActTimerTimer query count=' + IntToStr(CMMServActions.Count) );
    i := 0;
    while i < CMMServActions.Count do
    begin
      if TAction(CMMServActions[i]).Enabled then
      begin
        N_Dump2Str( 'ActTimerTimer before ' + TAction(CMMServActions[i]).Caption );
        TAction(CMMServActions[i]).OnExecute( CMMServActions[i] );
      end;
      if K_CMD4WAppFinState then
      begin
        if i < CMMServActions.Count then // precaution for CMSClose action 
          N_Dump1Str( 'ActTimerTimer exit on K_CMD4WAppFinState after ' + TAction(CMMServActions[i]).Caption );
        Exit; // Action Close CMS was execute
      end;
      Inc(i);
    end;
    CMMServActionsExec := FALSE;
    CMMServActions.Clear;

  end; // if CMMServActionsExec then

  if not (uicsAllActsDisabled in CMMUICurStateFlags) and
     not K_CMEDAccess.AccessReady then
  begin
    //////////////////////////////////////////////////////
    // Execute D4W buffered commands on Application Start
    //
    if not K_CMEDAccess.AccessReady then
      K_CMD4WWaitApplyDataCount := 0; // Clear Wait State
    K_CMEDAccess.AccessReady := TRUE;

    N_Dump1Str( 'ActTimerTimer before D4WApplyBufContext' );
    K_CMD4WApplyBufContext();
    N_Dump1Str( 'ActTimerTimer after D4WApplyBufContext' );
    //
    // end of Execute D4W buffered commands on Application Start
    //////////////////////////////////////////////////////
  end;

  if (CMMServActionsNext <> nil) and (CMMServActionsNext.Count > 0) then
  begin

    CMMServActions.Assign( CMMServActionsNext );
    CMMServActionsNext.Clear;

    i := Round((CMMServActionsNextTS - Now()) * 24 * 60 * 60 * 1000 );
    if i < 10 then i := 10;
    ActTimer.Interval := i;
    ActTimer.Enabled := TRUE;
    N_Dump1Str( 'Start next query wait' );
  end;
end; // procedure TN_CMMain5Form1.ActTimerTimer

//************************************* TN_CMMain5Form1.DragThumbsTimerTimer ***
// Start Thumbnails Drag
//
//     Parameters
// Sender - Event Sender
//
// DragThumbsTimer onTimer handler
//
procedure TN_CMMain5Form1.DragThumbsTimerTimer(Sender: TObject);
var
  i : Integer;
  DragObj : TObject;
  StudyItem : TN_UDCompVis;
  MarkedStudiesCount : Integer;
//  MarkedSlidesCount : Integer;
begin
//  exit;
  DragThumbsTimer.Enabled := false;
  CMMCurDragObject := nil;
  CMMCurDragObjectsList.Clear;
  if CMMCurBeginDragControl = CMMCurFThumbsRFrame then
  begin
    CancelDrag();
    with CMMCurFThumbsRFrame do
    begin
//      if (ssLeft in CMKShift) then
      if N_KeyIsDown( VK_LBUTTON ) and
         not N_KeyIsDown( VK_CONTROL ) then
      begin
        MarkedStudiesCount := 0;
//        MarkedSlidesCount  := 0;
        with CMMCurFThumbsDGrid do
        begin
          DragObj := nil;
          for i := 0 to DGMarkedList.Count - 1 do
          begin
            DragObj := K_CMCurVisSlidesArray[Integer(DGMarkedList[i])];
            if TN_UDCMSlide(DragObj).CMSArchived then Continue;
            CMMCurDragObjectsList.Add(DragObj);
//             with TN_UDCMSlide(DragObj).P^, CMSDB do
//!!! Video may be dragged to Study
//               if (cmsfIsMediaObj in SFlags) then Continue;
//               if (cmsfIsMediaObj in SFlags) or (cmsfIsOpened in CMSRFlags) then Continue;
{
            if DragObj is TN_UDCMStudy then
            begin
              if K_CMStudySingleOpenGUIModeFlag and (CMMFNumVisEdFrames <> 1) then Continue;
              with TN_UDCMSlide(DragObj).P^ do
                if cmsfIsOpened in CMSRFlags then Continue;
            end;

            CMMCurFThumbsRFrame.BeginDrag( TRUE );
            CMMCurDragObject := DragObj;
            break;
}
            if DragObj is TN_UDCMStudy then
              Inc(MarkedStudiesCount)
//            else
//              Inc(MarkedSlidesCount);
          end; // for i := 0 to DGMarkedList.Count - 1 do

//////////////////////////////
// Correct but eclectic code
//
{
//          if (DGMarkedList.Count > 0)                      and // List is not empty
          if (DGMarkedList.Count = 1)                      and // Temp Code to Skip MultiDrag
             not TN_UDCMSlide(DragObj).CMSArchived         and
             ( (MarkedStudiesCount = 0) or
               (MarkedStudiesCount = DGMarkedList.Count) ) and // No Studies or Only Studies
             (  not K_CMStudySingleOpenGUIModeFlag  or
                (MarkedStudiesCount = 0)            or
                (MarkedStudiesCount = 1) )                 and // Not SingleStudyMode or no Studies or One Study
             ( (DGMarkedList.Count > 1)  or
                not (cmsfIsOpened in TN_UDCMSlide(DragObj).P^.CMSRFlags) ) then // ??? one selected is not opened (This case needed for MultiDrag only)
          begin
            CMMCurFThumbsRFrame.BeginDrag( TRUE );
            CMMCurDragObject := DragObj;
          end
          else
            CMMCurDragObjectsList.Clear;
{}
//
// Correct but eclectic code
/////////////////////////////

///////////////////////////////////////////
// Code for Single Drag TN_UDCMSlide object
// 2018-12-17
          if (DGMarkedList.Count = 1) and (MarkedStudiesCount = 0) and (DragObj is TN_UDCMSlide) then
          begin
            with TN_UDCMSlide(DragObj), P()^ do
              if TN_UDCMSlide(DragObj).CMSArchived or // archived object
                 ////////////////// SIR #22843 2018-12-17
                 // Skip 3D objects to be draged to study
                 (cmsfIsImg3DObj in CMSDB.SFlags)  or // 3D object
                 (cmsfIsOpened   in CMSRFlags) then   // aready opened object
               DragObj := nil;
          end
          else
            DragObj := nil;

          if DragObj <> nil then
          begin
            CMMCurFThumbsRFrame.BeginDrag( TRUE );
            CMMCurDragObject := DragObj;
          end
          else
            CMMCurDragObjectsList.Clear;
//
// Code for Single Drag TN_UDCMSlide object
///////////////////////////////////////////

        end; // with CMMCurFThumbsDGrid do
      end; // if N_KeyIsDown ...
    end; // with CMMCurFThumbsRFrame do
    CMMThumbsFrameDblClickFlag := FALSE;
  end // if CMMCurBeginDragControl = CMMCurFThumbsRFrame then
  else
  if CMMCurBeginDragControl is TN_CMREdit3Frame then
  begin
    CancelDrag();
//    if (ssLeft in CMKShift) then
    if N_KeyIsDown(VK_LBUTTON) then
    begin
      CMMCurDragObject := CMMCurBeginDragControl;
      with TN_CMREdit3Frame(CMMCurBeginDragControl) do
      begin
//        RFrame.CMPos
        if IfSlideIsStudy and
           (CMMCurBeginDragControlPos.X >= 0) and
           (CMMCurBeginDragControlPos.Y >= 0) then
        begin
          CMMCurDragObject := nil;
          CMMCurDragObjectsList.Clear;
{
          if TN_UDCMStudy(EdSlide).CMSSelectedCount > 0 then
          begin
            TN_UDCMStudy(EdSlide).UnSelectAll();
            RFrame.RedrawAllAndShow();
          end;
}
          with EdVObjsGroup, OneSR do
            if SRType <> srtNone then
            begin
              StudyItem := TN_UDCompVis(SComps[SRCompInd].SComp);
              DragObj := K_CMStudyGetOneSlideByItem( StudyItem );
              if DragObj <> nil then
              begin
                CMMCurDragObject := DragObj;
              end;
            end; // if SRType <> srtNone then
        end; // if IfSlideIsStudy then
      end; // with TN_CMREdit3Frame(CMMCurBeginDragControl) do
      if CMMCurDragObject <> nil then
        CMMCurBeginDragControl.BeginDrag( TRUE );
    end; // if N_KeyIsDown(VK_LBUTTON) then
  end; // if CMMCurBeginDragControl is TN_CMREdit3Frame then
end; // procedure TN_CMMain5Form1.DragThumbsTimerTimer

//************************************ TN_CMMain5Form1.MeasureTextTimerTimer ***
// Start MeasureText
//
//     Parameters
// Sender - Event Sender
//
// MeasureTextTimer onTimer handler
//
procedure TN_CMMain5Form1.MeasureTextTimerTimer(Sender: TObject);
var
  PMeasureRootSelected : PByte;
begin
  MeasureTextTimer.Enabled := false;
  with CMMFActiveEdFrame, EdMoveVObjRFA do
  begin
    if BriCoModeStart then
    begin
      BriCoModeStart := FALSE;
{ !!! allow Change BriCo by cursor  in ViewZoomMode
      if K_CMSZoomForm = nil then
}
      begin
        BriCoMode := TRUE;
        Screen.Cursor := crChangeBriCo;
      end;
      BriCoCursorStartPos := RFrame.CCBuf;
    end   // if BriCoModeStart then
    else
    begin // if not BriCoModeStart then
      if not ActEnabled or
         (MeasureRoot = nil) then Exit;
//    PMeasureRootSelected := PByte( N_GetUserParPtr( TN_UDCompVis(MeasureRoot).R,
//            'Selected' ).UPValue.P);
      PMeasureRootSelected := PByte( K_CMGetVObjPAttr( MeasureRoot, 'Selected' ).UPValue.P);
      if PMeasureRootSelected^ = 0 then begin
        PMeasureRootSelected^ := 1;
        RFrame.RedrawAllAndShow();
      end else
        MeasureRoot := nil; // Already Selected
    end;  // if not BriCoModeStart then
  end;
end; // procedure TN_CMMain5Form1.MeasureTextTimerTimer


    //***********  TN_CMMain5Form Public methods  *****

//******************************************** TN_CMMain5Form1.CMMFAppClose ***
// Close CMS Application
//
//     Parameters
// ACloseInfo - close Info string to dump
//
procedure TN_CMMain5Form1.CMMFAppClose( const ACloseInfo : string );
var
  InterfaceForm : TForm;
  WComp : TComponent;
  i : Integer;
  ModalFormsExist : Boolean;
begin
  N_Dump1Str( 'CMMFAppClose >>  Start >> ' + ACloseInfo );
  InterfaceForm := CMMCurFMainForm;
  if InterfaceForm = nil then
    InterfaceForm := CMMCurFHPMainForm;

  if InterfaceForm <> nil then // Precaution
  begin
    if K_CMD4WAppRunByCOMClient or K_CMD4WCloseAppByUITest then
//   if K_CMD4WAppRunByClient  then
    begin
      ModalFormsExist := FALSE;
    ////////////////////////////////////////
    //  Try to Close Open Modal Forms except N_CM_MainForm and
    //
      try
        for i := Application.ComponentCount - 1 downto 0 do
        begin
          WComp := Application.Components[i];
          if not (WComp is TForm)                    or
             not (fsModal in TForm(WComp).FormState) or
             (TForm(WComp).ModalResult = mrCancel) then Continue;
          N_Dump1Str( 'CMMFAppClose >>  close Modal Form ' + TForm(WComp).Name );
          TForm(WComp).Close;
          ModalFormsExist := TRUE;
          Break;
//          TForm(WComp).Release;
//          TForm(WComp).SetFocus();
//          Application.ProcessMessages; // for form Real Close
        end; // for i := Application.ComponentCount - 1 downto 0 do
      except
        on E: Exception do
        begin
          N_Dump1Str( 'CMMFAppClose >>  CMS modal windows closing except >> ' + E.Message );
        end;
      end;

      if ModalFormsExist then
      begin
        N_Dump1Str( 'CMMFAppClose >>  Try CMSuite close later' );
        N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServCloseCMS, TRUE, 10 );
        Exit;
      end;

    end; // if InterfaceForm <> nil then

    with InterfaceForm do
    begin
      Close();
      N_Dump1Str( 'CMMFAppClose >>  after close >> ' + InterfaceForm.Name );
//      Release();
    end;
    //!!! add 13-12-2013 to prevent ecxeption on application close by Finish Action activate from menu GoTo in D2010
    N_AppSkipEvents := TRUE; // !!!Disable events handlers in Rast1Frame
    N_Dump2Str( 'CMMFAppClose >> before ProcessMessages' );
    Application.ProcessMessages; // for Events process
    N_Dump2Str( 'CMMFAppClose >> after ProcessMessages' );
    N_AppSkipEvents := FALSE;// !!!Enable events handlers in Rast1Frame

    /////////////////////////////////////////
    // Set correct state for future CMS awake
    //        (20-02-2017)
    // Prevent CMS awake (by SetWindowState or ExecUICommand) after previouse session with Provider without Access Rights
    K_CMD4WSkipCMSAwakeFlag := not (K_uarStart in K_CMCurUserAccessRights);
    // Clear uicsAllActsDisabled for closing CMS interface for next session when CMS will be awaked
    Exclude( CMMUICurStateFlags, uicsAllActsDisabled );
  end
  else
  begin
    N_Dump1Str( 'CMMFAppClose >>  CMMCurFMainForm = nil' );
  // Close if it is not done During CMMCurFMainForm closing (if not single Main Interface Form can be used)
    if not K_CMD4WAppFinState then Self.Close();
  end;
  N_Dump1Str( format('CMMFAppClose >>  Fin >> %s >> SkipAwake=%s',
                        [ACloseInfo, N_B2S(K_CMD4WSkipCMSAwakeFlag)] ) );
end; // end of function TN_CMMain5Form1.CMMFAppClose

//*************************************** TN_CMMain5Form1.CMMFCreateEdFrame ***
// Create new instance of N_CM_REdit3Frame
//
//     Parameters
// Result - Returns new instance of N_CM_REdit3Frame
//
function TN_CMMain5Form1.CMMFCreateEdFrame(): TN_CMREdit3Frame;
var
  IShift : Integer;
begin
  Result := TN_CMREdit3Frame.Create( Self );

{$IF CompilerVersion >= 26.0} // Delphi >= XE5  needed to skip scroll bars blinking in W7-8
  Result.RFrame.VScrollBar.ParentDoubleBuffered := FALSE;
  Result.RFrame.HScrollBar.ParentDoubleBuffered := FALSE;
{$IFEND CompilerVersion >= 26.0}

  Result.Name := 'Ed3_' + IntToStr( CMMFNumAllEdFrames ); // EdFrame Name Should be unique
  Inc(CMMFNumAllEdFrames);

  SetStretchBltMode( Result.RFrame.OCanv.HMDC, K_CMStretchBltMode );

  Result.FinishEditing.Caption := '';
  Result.FinishEditing.Visible := FALSE;
//  Result.FinishEditing.Action := nil;
  Result.PopupMenu := CMMEdFramePopUpMenu;
//  Result.PopupMenu := N_CMResForm.EdFrPointPopupMenu;
  Result.OnContextPopup := EdFramesContextPopup;

  with Result, RFrame do
  begin
    DstBackColor   := ColorToRGB( PaintBox.Color );
    OCanvBackColor := ColorToRGB( PaintBox.Color );
//    CMMainForm := Self;

    N_Dump2Str( 'CMMFCreateEdFrame RFrameTop=' + IntToStr(RFrame.Top));
    IShift := FrameLeftCaption.Top + FrameLeftCaption.Height + 2 - RFrame.Top;
    if IShift > 0 then
    begin
      RFrame.Height := RFrame.Height - IShift;
      RFrame.Top    := RFrame.Top + IShift;
      N_Dump2Str( 'CMMFCreateEdFrame RFrameTop' + IntToStr(RFrame.Top));
    end;

    FrameLeftCaption.Caption := '';
    FrameRightCaption.Caption := '';
//    ImgClibrated.Picture.Bitmap.
    N_CMResForm.MainIcons18.GetIcon( 73, ImgClibrated.Picture.Icon );
    N_ButtonsForm.ButtonsList.GetIcon( 29, ImgHasDiagn.Picture.Icon );

//    SomeStatusbar  := StatusBar; // temporary
    SkipOnPaint    := False; // to enable filling background if Slide is not set yet
//    ObjectsVisible := True;

    RFCenterInDst := True;
//      RFrActionFlags := RFrActionFlags + [rfafIncrBufSize];
//      RFrActionFlags := RFrActionFlags - [rfafScrollCoords,rfafShowColor];
//    RFrActionFlags := RFrActionFlags - [rfafShowColor] + [rfafFScreenByDClick];
    RFrActionFlags := RFrActionFlags - [rfafShowColor];
    RFClearFlags := 0;
    RFDumpEvents := True;

    OnMouseDownProcObj := FrameMouseDown;
    OnWMKeyDownProcObj := CMMFrameWMKeyDown;
    RFOnScaleProcObj   := CMMFShowScale;
    RFOnScrollProcObj  := CMMFShowScroll;
    ShowCoordsType := cctUser;
    PointCoordsFmt := 'X,Y = %.2f%%, %.2f%%';

    EdVObjsGroup := TN_SGComp.Create( RFrame );
    with EdVObjsGroup do
    begin
      GName := 'VOGroup';
      PixSearchSize := 15;
      SGFlags := $02 + // search lines even out of UDPolyline and UDArc components
                 $04;  // do redraw actions loop witout objects
    end;
    RFSGroups.Add( EdVObjsGroup );

    EdMoveVObjRFA := TK_CMEMoveVObjRFA(EdVObjsGroup.SetAction( K_ActCMEMoveVObj, 0, -1, 0 ));
    with EdMoveVObjRFA do
    begin
      ActName := 'VOMove';
      ActEnabled := False;
    end; // with EdMoveVObjRFA do

    EdAddVObj1RFA := TK_CMEAddVObj1RFA(EdVObjsGroup.SetAction( K_ActCMEAddVObj1, 0, -1, 0 ));
    with EdAddVObj1RFA do
    begin
      ActName := 'VOCr1';
      ActEnabled := False;
    end; // with EdAddVObj1RFA do

    EdAddVObj2RFA := TK_CMEAddVObj2RFA(EdVObjsGroup.SetAction( K_ActCMEAddVObj2, 0, -1, 0 ));
    with EdAddVObj2RFA do
    begin
      ActName := 'VOCr2';
      ActEnabled := False;
    end; // with EdAddVObj2RFA do

    EdIsodensityRFA := TK_CMEIsodensityRFA(EdVObjsGroup.SetAction( K_ActCMEIsodensity, 0, -1, 0 ));
    with EdIsodensityRFA do
    begin
      ActName := 'Isodens';
      ActEnabled := False;
    end; // with EdIsodensityRFA do

    EdGetSlideColorRFA := TK_CMEGetSlideColorRFA(EdVObjsGroup.SetAction( N_ActCMFlashLight, 0, -1, 0 ));
    with EdGetSlideColorRFA do
    begin
      ActName := 'GColor';
      ActEnabled := False;
    end; // with EdGetSlideColorRFA do

//    EdRubberRectRFA := TN_RubberRectRFA(EdVObjsGroup.SetAction( N_ActRubberRect, 0, -1, 0 ));
    EdRubberRectRFA := TK_CMERubberRectRFA(EdVObjsGroup.SetAction( K_ActCMERubberRect, 0, -1, 0 ));
    with EdRubberRectRFA do
    begin
      ActName := 'CropImage';
      ActEnabled := False;
      ActMaxUrect := N_CMDIBURect;
      RROnOKProcObj := CMMCropBySelectedRectProcObj;
      RROnCancelProcObj := CMMCropCancelProcObj;
    end; // with EdRubberRectRFA do

    EdFlashLightModeRFA := TK_CMEFlashLightModeRFA(EdVObjsGroup.SetAction( K_ActCMEFlashLightMode, 0, -1, 0 ));
    with EdFlashLightModeRFA do
    begin
      ActName := 'FlashLightMode';
      ActEnabled := False;
    end; // with EdRubberRectRFA do

    EdFlashLightRFA := TN_CMFlashLightRFA(EdVObjsGroup.SetAction( N_ActCMFlashLight, 0, -1, 0 ));
    with EdFlashLightRFA do
    begin
      ActName := 'FlashLight1';
      ActEnabled := False;
    end; // with EdFlashLightRFA do

    RFOnMaxVSProcObj := N_CM_GlobObj.CMMaxVSWarning;

  end; // with Result, Result.RFrame do
end; // end of function TN_CMMain5Form1.CMMFCreateEdFrame

//************************************** TN_CMMain5Form1.CMMFGetFreeEdFrame ***
// Get Free Editor Frame
//
//     Parameters
// Result - Returns Editor Frame (for Editing New Slide) or nil if all
//          Editor Frames are not Free
//
// Editor Frame is Free if it's field EdSlide = nil
//
function TN_CMMain5Form1.CMMFGetFreeEdFrame(): TN_CMREdit3Frame;
var
  i: integer;
begin
  Result := nil;

  for i := 0 to CMMFNumVisEdFrames-1 do
  begin
    if CMMFEdFrames[i].EdSlide = nil then // found
    begin
      Result := CMMFEdFrames[i];
      Exit;
    end; // if CMMFEdFrames[i].EdSlide = nil then // found
  end; // for i := 0 to CMMFNumVisEdFrames-1 do
end; // end of function TN_CMMain5Form1.CMMFGetFreeEdFrame

//************************************** TN_CMMain5Form1.CMMFGetSlideLinkedToStudy ***
// Get Opened Slide Linked to Study
//
//     Parameters
// Result - Returns Opened Slide Linked to Study
//
function TN_CMMain5Form1.CMMFGetSlideLinkedToStudy(): TN_UDCMSlide;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to CMMFNumVisEdFrames-1 do
  begin
    if (CMMFEdFrames[i].EdSlide <> nil) and
       (CMMFEdFrames[i].EdSlide.GetStudyItem <> nil) then // found
    begin
      Result := CMMFEdFrames[i].EdSlide;
      Exit;
    end; // if CMMFEdFrames[i].EdSlide = nil then // found
  end; // for i := 0 to CMMFNumVisEdFrames-1 do
end; // end of function TN_CMMain5Form1.CMMFGetSlideLinkedToStudy

//*************************** TN_CMMain5Form1.CMMFSetEdFramesStretchBltMode ***
// Set StretchBlt Mode to RFrame.OCanv.HMDC
//
//     Parameters
// Result - Returns Editor Frame (for Editing New Slide) or nil if all
//          Editor Frames are not Free
//
// Editor Frame is Free if it's field EdSlide = nil
//
procedure TN_CMMain5Form1.CMMFSetEdFramesStretchBltMode();
var
  i: integer;
begin
  for i := 0 to CMMFNumAllEdFrames-1 do
    if (CMMFEdFrames[i] <> nil) and
       (CMMFEdFrames[i].RFrame <> nil) then
      with CMMFEdFrames[i] do
      begin
        SetStretchBltMode( RFrame.OCanv.HMDC,
                           K_CMStretchBltMode );

        if EdSlide <> nil then // Opened
          RFrame.RedrawAllAndShow();

      end; // for i := 0 to CMMFNumAllEdFrames-1 do
end; // end of function TN_CMMain5Form1.CMMFSetEdFramesStretchBltMode

//***************************************** TN_CMMain5Form1.CMMFFindEdFrame ***
// Find Editor Frame with given ASlide
//
//     Parameters
// ASlide - Slide to Find or nil to find free EDitor Frame
// APFrInd - pointer to resulting Frame Index
// Result - Returns Editor Frame with given ASlide or nil if not found
//
// Editor Frame is Free if it's field EdSlide = nil
//
function TN_CMMain5Form1.CMMFFindEdFrame( ASlide: TN_UDCMSlide;
                                         APFrInd : PInteger = nil ): TN_CMREdit3Frame;
var
  i, Ind: integer;
begin
  Result := nil;
  if (ASlide <> nil) and (APFrInd = nil) then
  begin
    if ASlide.CMSRFrame = nil then Exit;
    Result := TN_CMREdit3Frame(ASlide.CMSRFrame.Parent);
  end  
  else
  begin
    Ind := -1;
    for i := 0 to CMMFNumVisEdFrames-1 do
    begin
      if CMMFEdFrames[i].EdSlide = ASlide then // found
      begin
        Result := CMMFEdFrames[i];
        Ind := i;
        break;
      end; // if CMMFEdFrames[i].EdSlide = ASlide then // found
    end; // for i := 0 to CMMFNumVisEdFrames-1 do
    if APFrInd <> nil then APFrInd^ := Ind;
  end;
end; // end of function TN_CMMain5Form1.CMMFFindEdFrame

//************************************* TN_CMMain5Form1.CMMFFreeEdFrObjects ***
// Free Editor Frame Objects for all Editor Frames
//
procedure TN_CMMain5Form1.CMMFFreeEdFrObjects();
var
  i: integer;
begin
  for i := 0 to High(CMMFEdFrames) do
  begin
    if (CMMFEdFrames[i] <> nil) and
       CMMFEdFrames[i].Visible then CMMFEdFrames[i].EdFreeObjects();
  end; // for i := 0 to High(CMMFEdFrames) do
end; // procedure TN_CMMain5Form1.CMMFFreeEdFrObjects

//******************************* TN_CMMain5Form1.CMMFEdFrRFrameFreeObjects ***
// Free Editor Frame RFrame FreeObjects before destroy
//
procedure TN_CMMain5Form1.CMMFEdFrRFrameFreeObjects();
var
  i: integer;
begin
  for i := 0 to High(CMMFEdFrames) do
  begin
    if (CMMFEdFrames[i] <> nil) then CMMFEdFrames[i].RFrame.RFFreeObjects;
  end; // for i := 0 to High(CMMFEdFrames) do
end; // procedure TN_CMMain5Form1.CMMFEdFrRFrameFreeObjects

//************************************* TN_CMMain5Form1.CMMRedrawDragOverComponent ***
// Free Editor Frame Objects for all Editor Frames
//
procedure TN_CMMain5Form1.CMMRedrawDragOverComponent( AViewState : Integer );
var
  BSlide : TN_UDCMBSlide;
  PUP: TN_POneUserParam;
begin
  if CMMCurDragOverComp = nil then Exit;

  // Set CMMCurDragOverComp new State
  PUP := N_GetUserParPtr(TN_UDCompBase(CMMCurDragOverComp).R, 'DropSelShow');
  PByte(PUP.UPValue.P)^ := AViewState;
  // Redraw Study Rframe
  BSlide := TN_UDCMBSlide(TN_UDBase(CMMCurDragOverComp).Owner.Owner);
  BSlide.CMSRFrame.RedrawAllAndShow();
  if AViewState = 0 then
    CMMCurDragOverComp := nil;
end; // procedure TN_CMMain5Form1.CMMRedrawDragOverComponent

//********************************** TN_CMMain5Form1.CMMFSelectThumbBySlide ***
// Select Thumbnail by given slide
//
//     Parameters
// AUDSlide - Slide to select Thumbnail
// AUnselectFlag - if TRUE then given Slide will be unselected
//
procedure TN_CMMain5Form1.CMMFSelectThumbBySlide( AUDSlide : TN_UDCMSlide;
               AUnselectFlag : Boolean = FALSE; ASelectStudyFlag : Boolean = FALSE );
var
  Ind : integer;
  Item : TN_UDBase;
begin
//  if AUDSlide = nil then Exit;
  if TN_UDCMBSlide(AUDSlide) is TN_UDCMStudy then
  begin
    if not ASelectStudyFlag then Exit;
  end
  else
  begin
    Item := AUDSlide.GetStudyItem();
    if Item <> nil then
    begin
    // Check if Study is opened
      with TN_UDCMStudy(Item.Owner.Owner) do
      begin
        if CMSRFrame <> nil then
        begin
        // Select Slide in opened Study
          UnSelectAll();
          SelectItem(Item);
          CMSRFrame.RedrawAllAndShow();
        end;
      end;
    end;
  end;

  Ind := -1;
  if (Length(K_CMCurVisSlidesArray) > 0) and (AUDSlide <> nil) then
    Ind := K_IndexOfIntegerInRArray( Integer(AUDSlide),
                       PInteger(@K_CMCurVisSlidesArray[0]),
                       Length(K_CMCurVisSlidesArray));
  if not AUnselectFlag or (Ind = -1) then
    CMMCurFThumbsDGrid.DGMarkSingleItem( Ind )
  else
    CMMCurFThumbsDGrid.DGSetItemState( Ind, ssmUnmark );

end; // procedure TN_CMMain5Form1.CMMFSelectThumbBySlide

//*********************** TN_CMMain5Form1.CMMFRefreshActiveEdFrameHistogram ***
// Refresh Active Frame Histogram
//                                                                                       `
procedure TN_CMMain5Form1.CMMFRefreshActiveEdFrameHistogram( ADIBObj : TN_DIBObj = nil );
var
  CurDIBObj : TN_DIBObj;
//  PXLat : PInteger;
  IsoMin, IsoMax : Integer;
  PCMSlideSDBF : TN_PCMSlideSDBF;

label CloseHistogram;
begin

  if (N_BrigHist2Form = nil) then Exit;

  PCMSlideSDBF := nil;
  with CMMFActiveEdFrame do
  begin
    if EdSlide <> nil then
      PCMSlideSDBF := @EdSlide.P().CMSDB;

//    CurDIBObj := nil;
//    PXLat := nil;
    IsoMin := -1;
    IsoMax := -1;
    if PCMSlideSDBF <> nil then
    begin
      with EdSlide do
      begin
// now Histogram can work for color images
//        if cmsfGreyScale in PCMSlideSDBF.SFlags  then
//        begin
        if ADIBObj <> nil then
          CurDIBObj := ADIBObj
        else
          CurDIBObj := GetCurrentImage().DIBObj;
//        end;
//        else
//         goto CloseHistogram;

//        PXLat := K_GetPIArray0( CMSXLatBCG );
        if cmsfShowIsodensity in PCMSlideSDBF.SFlags then
        begin
          IsoMin := CMSIsoMin;
          IsoMax := CMSIsoMax;
        end;
      end; // with EdSlide, PCMSlide^ do
    end
    else
    begin
CloseHistogram:
      N_BrigHist2Form.SelfClose();
      Exit;
    end;

    N_BrigHist2Form.SetDIBObj( CurDIBObj );
    N_BrigHist2Form.SetXLATtoConv( @EdSlide.CMSXLatBCGHist[0] );
    N_BrigHist2Form.SetBriRange( IsoMin, IsoMax );
    N_BrigHist2Form.cbAuto.Checked := True;
  end; // with CMMFActiveEdFrame do

end; // procedure TN_CMMain5Form1.CMMFRefreshActiveEdFrameHistogram

//************************************ TN_CMMain5Form1.CMMFSetActiveEdFrame ***
// Activate given Editor Frame and deactivate all others
//
//     Parameters
// AEditorFrame - Editor Frame to activate
// ASkipSwitchSelectedThumb  - skip switching selected Thumbnail while new Active EdFrame is changed
//
procedure TN_CMMain5Form1.CMMFSetActiveEdFrame( AEditorFrame : TN_CMREdit3Frame;
                                                ASkipSwitchSelectedThumb : Boolean );
var
  i: integer;
//  ActiveBGColor, ActiveFontColor, InactiveBGColor, InactiveFontColor : TColor;
//  ActivePictBGColor : Integer;
  PCMSlide : TN_PCMSlide;
  PrevSelStudyItem : TN_UDBase;
  PrevSelStudy : TN_UDCMStudy;
  NewFrameStudy : TN_UDCMBSlide;
  SavedSRType : TN_SRType;
  SavedCursor : TCursor;
begin
  if AEditorFrame <> CMMFActiveEdFrame then
  begin
    // Clear Selection for Current Active Frame Slide in ThumbFrame or Opened Study

    NewFrameStudy := nil;
    if AEditorFrame.IfSlideIsStudy() then
      NewFrameStudy := AEditorFrame.EdSlide;

    with CMMFActiveEdFrame do
    begin
      if IfSlideIsImage() then
      begin
        PrevSelStudyItem := EdSlide.GetStudyItem();
        PrevSelStudy := K_CMStudyGetStudyByItem( PrevSelStudyItem );
        if (PrevSelStudy <> nil) and (PrevSelStudy <> NewFrameStudy) then
        begin  // Clear Selection in Active Study
          if PrevSelStudy.CMSRFrame <> nil then
          begin
            i := TN_UDCMStudy(nil).UnSelectItem( PrevSelStudyItem );
            if i > 0 then PrevSelStudy.CMSRFrame.RedrawAllAndShow();
          end;
        end
        else
          with CMMCurFThumbsDGrid do
          begin // Clear Selection in ThumbFrame
            DGMarkSingleItem( -1 );
            DGRFrame.ShowMainBuf();
          end; // with N_CM_MainForm.CMMFThumbsDGrid do
      end;
    end;

  // set new active frame global mode and clear previous active frame mode
//    ActiveBGColor     := N_MemIniToInt( 'CMS_Colors', 'ActiveBGColor',     clActiveCaption );
//    ActiveFontColor   := N_MemIniToInt( 'CMS_Colors', 'ActiveFontColor',   clCaptionText );
//    InactiveBGColor   := N_MemIniToInt( 'CMS_Colors', 'InactiveBGColor',   clInactiveCaption );
//    InactiveFontColor := N_MemIniToInt( 'CMS_Colors', 'InactiveFontColor', clInactiveCaptionText );
//    ActivePictBGColor := N_MemIniToInt( 'CMS_Colors', 'ActivePictBGColor', $C0C0C0 );


    for i := 0 to High(CMMFEdFrames) do
    begin
      if CMMFEdFrames[i] = nil then Continue;

      CMMFEdFrames[i].SetFrameDefaultViewEditMode( );
      if CMMFEdFrames[i] = AEditorFrame then // Set Active
      begin
        CMMFActiveEdFrame := AEditorFrame;
        with CMMFActiveEdFrame do begin
          Color := K_CMSFrameActiveBGColor;
          Font.Color := K_CMSFrameActiveFontColor;
          STReadOnly.Color := K_CMSFrameInactiveBGColor;
          STReadOnly.Font.Color := 0;
          STReadOnly.Height := 14;
          RFrame.DstBackColor := K_CMSFrameActivePictBGColor;
          RFrame.OCanvBackColor := K_CMSFrameActivePictBGColor;
        end;

        case CMMEdVEMode of
          cmrfemFlashLight,
          cmrfemIsodensity:;
          cmrfemZoom : N_CMResForm.aViewZoomExecute( nil );
          cmrfemPan  : N_CMResForm.aViewPanningExecute( nil );
          cmrfemGetSlideColor: N_CMResForm.aViewSlideColorExecute( nil );
        else
          // Save RFrame cur context
          SavedCursor := CMMFActiveEdFrame.RFRame.Cursor;
          SavedSRType := CMMFActiveEdFrame.EdVObjsGroup.OneSR.SRType;

          N_CMResForm.aEditPointExecute( nil );

          // Restore RFrame cur context
          CMMFActiveEdFrame.EdVObjsGroup.OneSR.SRType := SavedSRType;
          N_SetMouseCursorType( CMMFActiveEdFrame.RFrame, SavedCursor );
        end;
      end
      else // deactivate
      with CMMFEdFrames[i] do
      begin
        Color := K_CMSFrameInactiveBGColor;
        Font.Color := K_CMSFrameInactiveFontColor;
        STReadOnly.Color := K_CMSFrameInactiveBGColor;
        STReadOnly.Font.Color := K_CMSFrameInactiveFontColor;
        STReadOnly.Height := 14;
        RFrame.DstBackColor := ColorToRGB( RFrame.PaintBox.Color );
        RFrame.OCanvBackColor := RFrame.DstBackColor;
//        EdViewEditMode := cmrfemNone;
        if (EDSlide <> nil) and ChangeSelectedVObj( 0 ) then
          RFrame.RedrawAllAndShow();
      end; // with CMMFEdFrames[i] do

      if CMMFEdFrames[i].IfSlideIsStudy then
        CMMFEdFrames[i].RFrame.RedrawAllAndShow();

    end; // for i := 0 to High(CMMFEdFrames) do

  end;

  CMMFShowScale( CMMFActiveEdFrame.RFrame );


  CMMFDisableActions(nil);

  // Set New Active Slide modes
  K_FormCMSIsodensity.InitIsodensityMode();

//  PCMSlide := nil;
  PrevSelStudy := CMMFActiveEdFrameSlideStudy;
  CMMFActiveEdFrameSlideStudy := nil;
  with CMMFActiveEdFrame do
  begin
    if IfSlideIsStudy() then
    begin // CLear selection Thumb
      with CMMCurFThumbsDGrid do
      begin
        DGMarkSingleItem( -1 );
        DGRFrame.ShowMainBuf();
      end; // with N_CM_MainForm.CMMFThumbsDGrid do
    end
    else
    if EdSlide <> nil then
    begin
      CMMFActiveEdFrameSlideStudy := EdSlide.GetStudy();
      PCMSlide := EdSlide.P();
      if not ASkipSwitchSelectedThumb then
      begin
        CMMFSelectThumbBySlide( EdSlide );

    //    PSkipSelf := GetPMeasureRootSkipSelf();
        N_CMResForm.aObjShowHide.Checked := not (cmsfHideDrawings in PCMSlide^.CMSRFlags);
    //    if N_CMResForm.aObjShowHide.Checked then
    //      PSkipSelf^ := 0
    //    else
    //      PSkipSelf^ := 1;
      end; // if not ASkipSwitchSelectedThumb then


{ !!! new code for Self BR Correction
      if (K_FormCMSIsodensity = nil) and
         (cmsfShowIsodensity in PCMSlide.CMSDB.SFlags) then
        N_CMResForm.aToolsIsodensAttrsExecute( nil );
}

    end; // if EdSlide <> nil then

    CMMFRefreshActiveEdFrameHistogram( );

    if K_CMSFullScreenForm = nil then
      if (CMMCurFMainForm as TK_FormCMMain5).pgcViewerHolder.ActivePageIndex = 0 then
        CMMCurFMainForm.ActiveControl := RFrame;

  end; // with CMMFActiveEdFrame do

  if (CMMFActiveEdFrameSlideStudy <> PrevSelStudy) and
     (CMMCurFThumbsDGrid <> nil) then
    CMMCurFThumbsRFrame.RedrawAllAndShow();

{
  if CMMFActiveEdFrame.EdSlide = nil then exit;
  with CMMFActiveEdFrame.EdSlide, P()^, GetPMapRootAttrs()^ do begin
    N_CMResForm.aToolsColorize.Checked := (cmsfShowColorize   in CMSDB.SFlags);
    N_CMResForm.aToolsIsodens.Checked  := (cmsfShowIsodensity in CMSDB.SFlags);
  end;
}
end; // procedure TN_CMMain5Form1.CMMFSetActiveEdFrame

//*************************************** TN_CMMain5Form1.CMMFCalcEdFrCoefs ***
// Calculate current Editor Frames Coefs
//
//     Parameters
// ASender - Event Sender Control, not used
//
// Calculate CMMFSplitterMainCoef, CMMFSplitter1Coef and CMMFSplitter2Coef by
// current controls sizes.
//
// All Splitters OnMoved Handler.
//
procedure TN_CMMain5Form1.CMMFCalcEdFrCoefs( ASender: TObject );
begin
  if CMMFEdFrLayout = eflNotDef then Exit; // to simplify set break points in debugger

  if CMMFEdFrLayout = eflTwoHSp then
  begin
    CMMFSplitterMainCoef := CMMFEdFrames[0].Height /
                            (EdFramesPanel.Height - CMMFEdFrSplitterMain.Height);
  end else if CMMFEdFrLayout = eflTwoVSp then
  begin
    CMMFSplitterMainCoef := CMMFEdFrames[0].Width /
                            (EdFramesPanel.Width - CMMFEdFrSplitterMain.Width);
  end else if CMMFEdFrLayout = eflFourHSp then
  begin
    CMMFSplitterMainCoef := CMMFEdFrPanel1.Height /
                            (EdFramesPanel.Height - CMMFEdFrSplitterMain.Height);
    CMMFSplitter1Coef := CMMFEdFrames[0].Width /
                            (CMMFEdFrPanel1.Width - CMMFEdFrSplitter1.Width);
    CMMFSplitter2Coef := CMMFEdFrames[2].Width /
                            (CMMFEdFrPanel2.Width - CMMFEdFrSplitter2.Width);
  end;
end; // procedure TN_CMMain5Form1.CMMFCalcEdFrCoefs

//********************************** TN_CMMain5Form1.CMMFSetEdFramesLayout0 ***
// Set given Editor Frames Layout
//
//     Parameters
// AEdFrLayout - given Editor Frames Layout
// APUDCMSlide - pointer to first element in slides to open array
// ASCount     - slides to open array length if < 0 then Layout Rebuild is needed even if layot do not change
// AEDFrLayoutFlags - additional flags
// Result      - Returns number of frames added to visible frames (
//
// Editor Frames Coefs should be already calculated
// Should not be used in OnResize handler
//
function TN_CMMain5Form1.CMMFSetEdFramesLayout0( AEdFrLayout: TN_EdFrLayout;
                                                APUDCMSlide : TN_PUDCMSlide = nil;
                                                ASCount : Integer = 0;
                                                AEDFrLayoutFlags : TK_CMUIEDFrLayoutFlags = [] ) : Integer;
var
  i, delta, ix, iy: integer;
  Widths, Heights: TN_IArray;
  PCurSlide : TN_PUDCMSlide;
  NSlides : TN_UDCMSArray;
  FSlides : TN_UDCMSArray;
  Ind, SLInd1, FrInd1, FrInd2 : Integer;
  NEdFrames : TN_CMREdit3FrArray; // Editor Frames
  NewEdFramesCount : Integer;
  NewActiveFrame : TN_CMREdit3Frame;
  ExtSlidesToOpen : Boolean;
  FPUDCMSlide : TN_PUDCMSlide;
  FSCount : Integer;
  FRCount : Integer;
  RebuildLayoutFlag : Boolean;

  procedure DumpFramesState( const APhaseName : string );
  var
   i : Integer;
   WStr : string;
  begin
    K_CMEDAccess.TmpStrings.Clear;
    for i := 0 to High(CMMFEdFrames) do
    begin // Slides to open List by Frames Slides
      if CMMFEdFrames[i] = nil then
        K_CMEDAccess.TmpStrings.Add( '*' )
      else
      begin
        WStr := '';
        if CMMFEdFrames[i].Visible then
        begin
          WStr := '!V';
          if CMMFEdFrames[i].EdSlide <> nil then
            WStr := WStr + '!' + CMMFEdFrames[i].EdSlide.ObjName;
        end;
        K_CMEDAccess.TmpStrings.Add( CMMFEdFrames[i].Name + WStr );
      end;
    end; // for i := 0 to CMMFNumVisEdFrames - 1 do
    N_Dump2Str( 'CMMFSetEdFramesLayout0 ' + APhaseName + ' Frames order:' + K_CMEDAccess.TmpStrings.CommaText);
  end;

  procedure MakeFramesVisible( ANumVisFrames: integer ); // local
  // Make first ANumVisFrames visible and all other Frames Invisible
  var
    i : integer;
  begin
    ANumVisFrames := min( ANumVisFrames, N_CM_MaxNumEdFrames ); // a precaution
    for i := 0 to ANumVisFrames-1 do // along all Frames that should be Visible
    begin
      if CMMFEdFrames[i] = nil then // i-th Frame was not created yet CMMFEdFrames[i]
      begin
        CMMFEdFrames[i] := CMMFCreateEdFrame();

        with CMMFEdFrames[i] do
        begin
          RFrame.RFDebName := CMMFEdFrames[i].Name; // Rast1Frame Name
//          SelfIndex := i;
          DoubleBuffered := True;
        end;
      end else //********************* i-th Frame already exists
        CMMFEdFrames[i].Visible := True;

    end; // for i := 0 to ANumVisFrames-1 do // along all Frames that should be Visible

    for i := ANumVisFrames to N_CM_MaxNumEdFrames-1 do // along all Frames that should be Invisible
    begin
      if (CMMFEdFrames[i] <> nil) and (CMMFEdFrames[i].Visible) then
        with CMMFEdFrames[i] do
        begin
          EdFreeObjects();
          Visible := False;
        end; // with CMMFEdFrames[i] do
    end; // for i := ANumVisFrames to N_CM_MaxNumEdFrames-1 do // along all Frames that should be Invisible

    DumpFramesState( '2' );
  end; // procedure MakeFramesVisible - local

  procedure CreatePanel( var APanel: TPanel; AName: string; AParent: TWinControl ); // local
  // Create Panel if not yet
  begin
    if APanel = nil then // create APanel
    begin
      APanel := TPanel.Create( Self );

      with APanel do
      begin
        Name := AName; // mainly for debug
        Parent := AParent;
        BevelOuter := bvNone;
        Caption := ''; // possibly to diminish flicker, may be not needed
        DoubleBuffered := True;
      end; // with APanel do
    end; // if APanel = nil then // create CMMFEdFrPanel1
  end; // procedure CreatePanel - local

begin //********************************** main procedure body
  Result := 0;
  if AEdFrLayout = eflNotDef then AEdFrLayout := eflOne;
  if Length(CMMFEdFrames) = 0 then Exit; // Form is not initialized

  CMMFSplitterMainCoef := 0.5;
  CMMFSplitter1Coef    := 0.5;
  CMMFSplitter2Coef    := 0.5;

  N_Dump1Str( format( 'CMMFSetEdFramesLayout0 Cur=%d New=%d, SlidesCount=%d Flags=%x ',
                           [Ord(CMMFEdFrLayout), Ord(AEdFrLayout), ASCount, Byte(AEDFrLayoutFlags) ] ) );
  DumpFramesState( '1' );

  NewEdFramesCount := N_EdFrLayoutCounts[Ord(AEdFrLayout)];
  Result := NewEdFramesCount - CMMFNumVisEdFrames;
  RebuildLayoutFlag := (CMMFEdFrLayout <> AEdFrLayout) or
                       (Result <> 0)                   or
                       (ASCount < 0);

////////////////////////////////////////////////////////////////////////////
// Create SlidesToOpen array if Layout with less frame counter should be set

  ASCount := Min( ASCount, N_CM_MaxNumEdFrames );
  ASCount := Max( 0, ASCount );
{
  if (APUDCMSlide <> nil) and (ASCount <> 0) then
  begin
  // Set Source Slides Order info in Marker Field
    PCurSlide := APUDCMSlide;
    for i := 0 to ASCount - 1 do
    begin
      if PCurSlide^ <> nil then
        PCurSlide^.Marker := i
      else
        PInteger(PCurSlide)^ := i;

      Inc(PCurSlide);
    end;
  end;
}
  FPUDCMSlide := APUDCMSlide;
  FSCount := ASCount;

  ExtSlidesToOpen := FPUDCMSlide <> nil; // Extrenal Slides givenList toOpen is
  if (FPUDCMSlide = nil) and (Result < 0) then
  begin
    FSCount := NewEdFramesCount;
    SetLength( FSlides, FSCount );
    SLInd1 := 0;

    if (CMMFActiveEdFrame <> nil) and
       (CMMFActiveEdFrame.EdSlide <> nil) then
    begin
      FSlides[0] := CMMFActiveEdFrame.EdSlide;
      SLInd1 := 1;
    end;

    for i := 0 to CMMFNumVisEdFrames - 1 do
    begin // Slides to open List by Frames Slides
      if SLInd1 >= FSCount then Break;
      if (CMMFEdFrames[i].EdSlide <> nil) and
         (CMMFEdFrames[i] <> CMMFActiveEdFrame) then
      begin
        FSlides[SLInd1] := CMMFEdFrames[i].EdSlide;
        Inc(SLInd1);
        if (CMMFActiveEdFrame <> nil) and
           (CMMFActiveEdFrame.EdSlide = nil) then
          CMMFActiveEdFrame := CMMFEdFrames[i];
      end;
    end; // for i := 0 to CMMFNumVisEdFrames - 1 do

    FSCount := SLInd1;
    SetLength( FSlides, FSCount );

    if FSCount >= 1 then
      FPUDCMSlide := @FSlides[0];
  end; // if (FPUDCMSlide = nil) and (Result < 0) then

  if (FPUDCMSlide <> nil) and (FSCount <> 0) then
  begin
  // Set Source Slides Order info in Marker Field
    PCurSlide := FPUDCMSlide;
    for i := 0 to FSCount - 1 do
    begin
      if PCurSlide^ <> nil then
        PCurSlide^.Marker := i
      else
        PInteger(PCurSlide)^ := i;

      Inc(PCurSlide);
    end;
  end;

////////////////////////////////////////////////////////////////////////////
// Reorder Frames and SlidesToOpen arrays to save already opend in new Frames Layout
//
  FRCount := CMMFNumVisEdFrames;
  if (FPUDCMSlide <> nil) and (FSCount <> 0) then
  begin
    SetLength( NSlides, FSCount );
    FRCount := Max( FRCount, FSCount );
    SetLength( NEdFrames, FRCount );
    SLInd1 := 0;
    FrInd1 := 0;

    ///////////////////////////////////////////////////////////////
    // Build Frames and Slides to Open synchronized arrays
    // Step 1 - Reoreder Frames and opened slides
    //
    FrInd2 := FRCount - 1;
    for i := 0 to FRCount - 1 do
    begin
    // Reorder Frames and SlidesToOpen arrays for already opend slides
    // if they are in SlidesToOpen array
      Ind := -1;
      if (CMMFEdFrames[i] <> nil) and (CMMFEdFrames[i].EdSlide <> nil) then
        Ind := K_IndexOfIntegerInRArray( Integer(CMMFEdFrames[i].EdSlide),
                                         PInteger(FPUDCMSlide), FSCount );
//!!!!!! 2014-02-11 error instead FSCount should be used of CMMFNumVisEdFrames
//      if (CMMFEdFrames[i] <> nil) and (CMMFEdFrames[i].EdSlide <> nil) then
//        Ind := K_IndexOfIntegerInRArray( Integer(CMMFEdFrames[i].EdSlide),
//                                         PInteger(FPUDCMSlide), CMMFNumVisEdFrames );

     // Change Frame Îrder by Slides Order
      if (Ind >= 0) and (SLInd1 < FSCount) then
      begin
      // Put Frame with stay opened Slide to the begin of NEdFrames Array
      // and stay opened Slide to the begin of NSlides array
        NEdFrames[FrInd1] := CMMFEdFrames[i];
        Inc(FrInd1);
        NSlides[SLInd1] := CMMFEdFrames[i].EdSlide;
        NSlides[SLInd1].CMSlideMarker := TRUE; // Mark slides which should stay opened
//!!!!!! 2014-02-11 not optimal code
//        PCurSlide := TN_PUDCMSlide(TN_BytesPtr(FPUDCMSlide) + Ind * SizeOf(TObject));
//        PCurSlide.CMSlideMarker := TRUE; // Mark slides which should stay opened
//        NSlides[SLInd1] := PCurSlide^;
        Inc(SLInd1);
      end
      else
      begin
      // Put Frame with closing Slide or without Slide or empty Frames array element to the end of Frames Array
        NEdFrames[FrInd2] := CMMFEdFrames[i];
        Dec(FrInd2);
      end;
    end; // for i := 0 to CMMFNumVisEdFrames - 1 do


    ///////////////////////////////////////////////////////////////
    // Build Frames and Slides to Open synchronized arrays
    // Step 2 - Reoreder not opened Slides finish
    //
    if SLInd1 > 0 then
    begin
    // Some Slides are already opened
    // Add other (not opened) Slides to the new Ordered Array Tail (after already opened)
      PCurSlide := FPUDCMSlide;
      for i := 0 to FSCount - 1 do
      begin
        if ( (PLongWord(PCurSlide)^ < 100) or
             (not PCurSlide.CMSlideMarker) ) and
           (SLInd1 < FSCount) then
        begin // this can be when same image was opened in more then one frames
          NSlides[SLInd1] := PCurSlide^;
          Inc(SLInd1);
        end;
        if PLongWord(PCurSlide)^ > 100 then
        begin
//        if (PCurSlide.CMSlideMarker) and (APUDCMSlide <> nil) then
//          RebuildLayoutFlag := (PCurSlide^ <> CMMFEdFrames[PCurSlide.Marker].EdSlide) or RebuildLayoutFlag;
          if not RebuildLayoutFlag then
            RebuildLayoutFlag := PCurSlide^ <> CMMFEdFrames[PCurSlide.Marker].EdSlide;
          PCurSlide.CMSlideMarker := FALSE;
        end;
        Inc(PCurSlide);
      end;

    ///////////////////////////////////////////////////////////////
    // Build Frames and Slides to Open synchronized arrays
    // Step 3 - Reoreder Frames in Slides Open Order
    //
      if RebuildLayoutFlag then
      begin
      // Frames Reorder is needed
        if APUDCMSlide <> nil then
        begin
        // Put reordered Frames to CMMFEdFrames Array using Opened SLides Source Order
          for i := 0 to FSCount - 1 do
          begin
            if Integer(NSlides[i]) > 100 then
              SLInd1 := NSlides[i].Marker
            else
              SLInd1 := Integer(NSlides[i]);
            CMMFEdFrames[SLInd1] :=  NEdFrames[i];
          end;
          // Move reoredered Frames tail to CMMFEdFrames array
          for i := FSCount to FRCount - 1 do
            CMMFEdFrames[i] :=  NEdFrames[i];
//          Move( NEdFrames[FSCount], CMMFEdFrames[FSCount], (FRCount - FSCount) * SizeOf(TObject) );
        end
        else
        // Set Layout and no Slides to Open
          Move( NEdFrames[0], CMMFEdFrames[0], (FRCount) * SizeOf(TObject) );
      end; // if RebuildLayoutFlag then
    end;  // if SLInd1 > 0 then // Some Slides are already opened


  end; //  if (FPUDCMSlide <> nil) and (FSCount <> 0) then

  if (FPUDCMSlide <> nil) and (FSCount <> 0) then
  begin
  // Clear Source Slides Order info in Marker Field
    PCurSlide := FPUDCMSlide;
    for i := 1 to FSCount do
    begin
      if PLongWord(PCurSlide)^ > 100 then
        PCurSlide^.Marker := 0
      else
        PCurSlide^ := nil;
      Inc(PCurSlide);
    end;
  end; // if (FPUDCMSlide <> nil) and (FSCount <> 0) then

//

////////////////////////////////////////////////////////////////////////////
// Ñhange active frame if needed
//
  if CMMFActiveEdFrame <> nil then
  begin
    Ind := K_IndexOfIntegerInRArray( Integer(CMMFActiveEdFrame),
                                     PInteger(@CMMFEdFrames[0]), FRCount );
    if (Ind = -1) or (Ind >= NewEdFramesCount) then
      CMMFActiveEdFrame := CMMFEdFrames[0];
  end;


  if RebuildLayoutFlag then
  begin

    EdFramesPanel.DisableAlign();

    // Skip EdFrames Redraw and Resize
    for i := 0 to FRCount - 1 do
      if CMMFEdFrames[i] <> nil then
        with CMMFEdFrames[i] do
          if RFrame <> nil then
          begin
            RFrame.SkipOnResize := TRUE;
            RFrame.SkipOnPaint := TRUE;
          end;

    case AEdFrLayout of //******** calculate EdFrames coords

    eflNotDef: Exit;

    eflOne: //******************************************************* One Frame
    begin
      if N_CM_MaxNumEdFrames < 1 then Exit; // a precaution

      MakeFramesVisible( 1 );

      if CMMFEdFrPanel1 <> nil then CMMFEdFrPanel1.Visible := False;
      if CMMFEdFrPanel2 <> nil then CMMFEdFrPanel2.Visible := False;

      if CMMFEdFrSplitterMain <> nil then CMMFEdFrSplitterMain.Visible := False;

      CMMFEdFrames[0].Parent := EdFramesPanel;
      CMMFEdFrames[0].Align  := alClient;
    end; // eflOne:


    eflTwoHSp: //************* Two Frames with Horizontal Splitter between them
    begin
      if N_CM_MaxNumEdFrames < 2 then Exit; // a precaution

      MakeFramesVisible( 2 );

      if CMMFEdFrPanel1 <> nil then CMMFEdFrPanel1.Visible := False;
      if CMMFEdFrPanel2 <> nil then CMMFEdFrPanel2.Visible := False;

      N_PlaceTwoSplittedControls( CMMFEdFrames[0], CMMFEdFrames[1], EdFramesPanel,
                                  CMMFEdFrSplitterMain, orHorizontal, CMMFSplitterMainCoef, CMMFSplittersSize );

  //    if CMMFEdFrPanel1 <> nil then
  //    begin
  //      CMMFEdFrPanel1.Visible := False;
  //      CMMFEdFrPanel1.Parent := nil; // Is needed! Otherwise CMMFEdFrSplitterMain remembers
  //    end;                            // CMMFEdFrPanel1 size if prev. layout was eflFourHSp!

  //    if CMMFEdFrPanel2 <> nil then CMMFEdFrPanel2.Visible := False;
    end; // eflTwoHSp:


    eflTwoVSp: //*************** Two Frames with Vertical Splitter between them
    begin
      if N_CM_MaxNumEdFrames < 2 then Exit; // a precaution

      MakeFramesVisible( 2 );

      if CMMFEdFrPanel1 <> nil then CMMFEdFrPanel1.Visible := False;
      if CMMFEdFrPanel2 <> nil then CMMFEdFrPanel2.Visible := False;

      N_PlaceTwoSplittedControls( CMMFEdFrames[0], CMMFEdFrames[1], EdFramesPanel,
                                  CMMFEdFrSplitterMain, orVertical, CMMFSplitterMainCoef, CMMFSplittersSize );
    end; // eflTwoVSp:


    eflFourHSp: //*** Four Frames with Horizontal Splitter between Frames Pairs
    begin
      if N_CM_MaxNumEdFrames < 4 then Exit; // a precaution

      MakeFramesVisible( 4 );

      CreatePanel( CMMFEdFrPanel1, 'CMMFEdFrPanel1', EdFramesPanel );
      CreatePanel( CMMFEdFrPanel2, 'CMMFEdFrPanel2', EdFramesPanel );

  //    N_Dump2Str( Format( 'CMMFSetEdFramesLayout0 1 (%f):', [CMMFSplitterMainCoef] ) );
      N_PlaceTwoSplittedControls( CMMFEdFrPanel1, CMMFEdFrPanel2, EdFramesPanel,
                                  CMMFEdFrSplitterMain, orHorizontal, CMMFSplitterMainCoef, CMMFSplittersSize );

  //    N_Dump2Str( Format( 'CMMFSetEdFramesLayout0 2 (%f):', [CMMFSplitter1Coef] ) );
  //    CMMFEdFrames[0].Ed3FrDumpCurState( 2);
  //    CMMFEdFrames[1].Ed3FrDumpCurState( 4);
      N_PlaceTwoSplittedControls( CMMFEdFrames[0], CMMFEdFrames[1], CMMFEdFrPanel1,
                                  CMMFEdFrSplitter1, orVertical, CMMFSplitter1Coef, CMMFSplittersSize );
  //    CMMFEdFrames[0].Ed3FrDumpCurState( 2);
  //    CMMFEdFrames[1].Ed3FrDumpCurState( 4);

  //    N_Dump2Str( Format( 'CMMFSetEdFramesLayout0 3 (%f):', [CMMFSplitter2Coef] ) );
  //    CMMFEdFrames[2].Ed3FrDumpCurState( 2);
  //    CMMFEdFrames[3].Ed3FrDumpCurState( 4);
      N_PlaceTwoSplittedControls( CMMFEdFrames[2], CMMFEdFrames[3], CMMFEdFrPanel2,
                                  CMMFEdFrSplitter2, orVertical, CMMFSplitter2Coef, CMMFSplittersSize );
  //    CMMFEdFrames[2].Ed3FrDumpCurState( 2);
  //    CMMFEdFrames[3].Ed3FrDumpCurState( 4);
    end; // eflFourHSp:

  //  eflFourVSp: //*** Four Frames with Vertical Splitter between Frames Pairs (not implemented)

    eflNine: //********************************** Nine Frames without Splitters
    begin
      if N_CM_MaxNumEdFrames < 9 then Exit; // a precaution

      MakeFramesVisible( 9 );

      if CMMFEdFrPanel1 <> nil then CMMFEdFrPanel1.Visible := False;
      if CMMFEdFrPanel2 <> nil then CMMFEdFrPanel2.Visible := False;

      if CMMFEdFrSplitterMain <> nil then CMMFEdFrSplitterMain.Visible := False;

      SetLength( Widths, 3 );
      SetLength( Heights, 3 );

      Widths[0] := EdFramesPanel.Width div 3;
      delta := EdFramesPanel.Width - 3*Widths[0];

      case delta of
        0: begin Widths[1] := Widths[0];   Widths[2] := Widths[0];   end;
        1: begin Widths[1] := Widths[0];   Widths[2] := Widths[0]+1; end;
        2: begin Widths[1] := Widths[0]+1; Widths[2] := Widths[0]+1; end;
      end; // case delta of

      Heights[0] := EdFramesPanel.Height div 3;
      delta := EdFramesPanel.Height - 3*Heights[0];

      case delta of
        0: begin Heights[1] := Heights[0];   Heights[2] := Heights[0];   end;
        1: begin Heights[1] := Heights[0];   Heights[2] := Heights[0]+1; end;
        2: begin Heights[1] := Heights[0]+1; Heights[2] := Heights[0]+1; end;
      end; // case delta of

      for ix := 0 to 2 do
      for iy := 0 to 2 do
      begin
        with CMMFEdFrames[iy*3 + ix] do
        begin
          Parent := EdFramesPanel;
          Align := alNone;

          if ix = 0 then  Left := 0
          else if ix = 1 then Left := Widths[0]
          else if ix = 2 then Left := Widths[0] + Widths[1];

          Width  := Widths[ix];

          if iy = 0 then  Top := 0
          else if iy = 1 then Top := Heights[0]
          else if iy = 2 then Top := Heights[0] + Heights[1];

          Height := Heights[iy];
        end;
      end; //

    end; // eflNine:

    end; // case AEdFrLayout of //******** calculate EdFrames coords

    CMMFEdFrLayout := AEdFrLayout;
    CMMFNumVisEdFrames := NewEdFramesCount;

    EdFramesPanel.EnableAlign();

    for i := 0 to CMMFNumVisEdFrames - 1 do // Clear flags Skip EdFrames Redraw and Resize
    begin
      with CMMFEdFrames[i] do
        if RFrame <> nil then
        begin
          RFrame.SkipOnResize := False;
          RFrame.SkipOnPaint := False;
        end; // if RFrame <> nil then
    end; // for i := 0 to CMMFNumVisEdFrames - 1 do

    if CMMFEdFrSplitterMain <> nil then CMMFEdFrSplitterMain.OnMoved := CMMFCalcEdFrCoefs;
    if CMMFEdFrSplitter1    <> nil then CMMFEdFrSplitter1.OnMoved := CMMFCalcEdFrCoefs;
    if CMMFEdFrSplitter2    <> nil then CMMFEdFrSplitter2.OnMoved := CMMFCalcEdFrCoefs;

  end; // if RebuildLayoutFlag then

N_Dump2Str( 'AA0 ' + IntToStr(CMMFNumVisEdFrames) );

  if not ExtSlidesToOpen then
    for i := 0 to CMMFNumVisEdFrames-1 do // along all Frames that should be Visible
      if CMMFEdFrames[i] <> nil then
        with CMMFEdFrames[i] do
        begin
          if (RFrame <> nil) and (EdSlide <> nil) then
          begin
            if uieflSkipFramesResize in AEDFrLayoutFlags then
              RFrame.SetZoomLevel( rfzmCenter )
            else
              RFrame.OnResizeFrame( nil );
          end;
          Ed3FrDumpFrameRightCaption( 'Resize' );
        end;


  //***** Update CMMFActiveEdFrame

N_Dump2Str( 'AA1'  );
if CMMFActiveEdFrame <> nil then
N_Dump2Str( CMMFActiveEdFrame.Name  );

  NewActiveFrame := CMMFActiveEdFrame;
  if NewActiveFrame = nil then // no active EdFrame
    NewActiveFrame := CMMFEdFrames[0];

N_Dump2Str( 'AA2' );
if NewActiveFrame <> nil then
N_Dump2Str( NewActiveFrame.Name  );

  CMMFActiveEdFrame := nil;
  CMMFSetActiveEdFrame( NewActiveFrame,
                              uieflSkipSwitchSelectedThumb in AEDFrLayoutFlags );

N_Dump2Str( 'AA3' );

end; // procedure TN_CMMain5Form1.CMMFSetEdFramesLayout0

//******************************** TN_CMMain5Form1.CMMFUpdateEdFramesLayout ***
// Update given Editor Frames Layout
//
//     Parameters
// AEdFrLayout - given Editor Frames Layout
//
// Editor Frames Coefs should be already calculated.
// Is used in OnResize handler.
//
procedure TN_CMMain5Form1.CMMFUpdateEdFramesLayout( AEdFrLayout: TN_EdFrLayout );
var
  delta, ix, iy: integer;
  Widths, Heights: TN_IArray;
begin
  if Length(CMMFEdFrames) = 0 then Exit; // Form is not initialized

  case AEdFrLayout of

  eflNotDef: Exit;

  eflTwoHSp: //************* Two Frames with Horizontal Splitter between them
  begin
    CMMFEdFrames[0].Height := Round( CMMFSplitterMainCoef*(EdFramesPanel.Height - CMMFSplittersSize) );
  end; // eflTwoHSp:


  eflTwoVSp: //*************** Two Frames with Vertical Splitter between them
  begin
    CMMFEdFrames[0].Width := Round( CMMFSplitterMainCoef*(EdFramesPanel.Width - CMMFSplittersSize) );
  end; // eflTwoVSp:


  eflFourHSp: //*** Four Frames with Horizontal Splitter between Frames Pairs
  begin
    CMMFEdFrPanel1.Height := Round( CMMFSplitterMainCoef*(EdFramesPanel.Height - CMMFSplittersSize) );
    CMMFEdFrames[0].Width := Round( CMMFSplitter1Coef*(CMMFEdFrPanel1.Width - CMMFSplittersSize) );
    CMMFEdFrames[2].Width := Round( CMMFSplitter2Coef*(CMMFEdFrPanel2.Width - CMMFSplittersSize) );
  end; // eflFourHSp:

//  eflFourVSp: //*** Four Frames with Vertical Splitter between Frames Pairs

  eflNine: //********************************** Nine Frames without Splitters
  begin
    SetLength( Widths, 3 );
    SetLength( Heights, 3 );

    Widths[0] := EdFramesPanel.Width div 3;
    delta := EdFramesPanel.Width - 3*Widths[0];

    case delta of
      0: begin Widths[1] := Widths[0];   Widths[2] := Widths[0];   end;
      1: begin Widths[1] := Widths[0];   Widths[2] := Widths[0]+1; end;
      2: begin Widths[1] := Widths[0]+1; Widths[2] := Widths[0]+1; end;
    end; // case delta of

    Heights[0] := EdFramesPanel.Height div 3;
    delta := EdFramesPanel.Height - 3*Heights[0];

    case delta of
      0: begin Heights[1] := Heights[0];   Heights[2] := Heights[0];   end;
      1: begin Heights[1] := Heights[0];   Heights[2] := Heights[0]+1; end;
      2: begin Heights[1] := Heights[0]+1; Heights[2] := Heights[0]+1; end;
    end; // case delta of

    for ix := 0 to 2 do
    for iy := 0 to 2 do
    begin
      with CMMFEdFrames[iy*3 + ix] do
      begin
        if ix = 0 then  Left := 0
        else if ix = 1 then Left := Widths[0]
        else if ix = 2 then Left := Widths[0] + Widths[1];

        Width  := Widths[ix];

        if iy = 0 then  Top := 0
        else if iy = 1 then Top := Heights[0]
        else if iy = 2 then Top := Heights[0] + Heights[1];

        Height := Heights[iy];
      end;
    end; //
  end; // eflNine:

  end; // case AEdFrLayout of

end; // procedure TN_CMMain5Form1.CMMFUpdateEdFramesLayout

//******************************************* TN_CMMain5Form1.CMMFDrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel ad may be not equal to upper left Grid pixel )
//
// Is used as value of CMMFThumbsDGrid.DGDrawItemProcObj field
//
procedure TN_CMMain5Form1.CMMFDrawThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                           const ARect: TRect );
var
  Slide : TN_UDCMSlide;
  LinesCount : Integer;
  SlideDrawFlags : Byte;
begin
  with N_CM_GlobObj do
  begin
//N_Dump2Str( format( 'DrawOneThumb7 %d', [AInd] ) );
    Slide := TN_UDCMSlide(K_CMCurVisSlidesArray[AInd]);

    LinesCount := 0;
    SlideDrawFlags := ADGObj.DGItemsFlags[AInd];

    with Slide.P^ do
    begin
      if TN_UDCMBSlide(Slide) is TN_UDCMStudy then
      begin
      // Study
        CMStringsToDraw[LinesCount] := K_DateTimeToStr( CMSDTTaken, 'dd"/"mm"/"yy' );
        Inc(LinesCount);
        CMStringsToDraw[LinesCount] := CMSSourceDescr;
        if CMStringsToDraw[LinesCount] <> '' then
          Inc(LinesCount);
        CMMFDrawSlideObj.CMDSCSelTextBGColor := -1;
        if CMSMediaType <> 0 then
        begin
          SlideDrawFlags := SlideDrawFlags or 2;
          CMMFDrawSlideObj.CMDSCSelTextBGColor := Integer(CMMStudyColorsList.Objects[CMSMediaType]);
        end;
      end // if TN_UDCMBSlide(Slide) is TN_UDCMStudy then
      else
      begin // if TN_UDCMBSlide(Slide) is TN_UDCMSlide then
      // Slide
        if ttsObjDateTaken in K_CMSThumbTextFlags then
        begin
          CMStringsToDraw[LinesCount] := K_DateTimeToStr( CMSDTTaken, 'dd"/"mm"/"yy' );
          Inc(LinesCount);
        end;

        if ttsObjTimeTaken in K_CMSThumbTextFlags then
        begin
          CMStringsToDraw[LinesCount] := K_DateTimeToStr( CMSDTTaken, 'hh":"nn":"ss' );
          Inc(LinesCount);
        end;

        if (ttsObjTeethChart in K_CMSThumbTextFlags) and
           (CMSTeethFlags <> 0) then
        begin
          CMStringsToDraw[LinesCount] := K_CMSTeethChartStateToText( CMSTeethFlags );
          Inc(LinesCount);
        end;

        if ttsObjSource in K_CMSThumbTextFlags then
        begin
          CMStringsToDraw[LinesCount] := CMSSourceDescr;
          Inc(LinesCount);
        end;

      end; // if TN_UDCMBSlide(Slide) is TN_UDCMSlide then

    end;

    if TObject(Slide) = TObject(CMMFActiveEdFrameSlideStudy) then
      SlideDrawFlags := SlideDrawFlags or 1;

//    CMMFDrawSlideObj.DrawOneThumb4( Slide,
//                               CMStringsToDraw, CMMCurFThumbsDGrid, ARect,
//                               CMMCurFThumbsDGrid.DGItemsFlags[AInd] );
//    CMMFDrawSlideObj.DrawOneThumb4( Slide,
//                               CMStringsToDraw, ADGObj, ARect,
//                               ADGObj.DGItemsFlags[AInd] );
{
    CMMFDrawSlideObj.DrawOneThumb6( Slide,
                               CMStringsToDraw, LinesCount,
                               ADGObj, ARect,
                               ADGObj.DGItemsFlags[AInd] );
}
    CMMFDrawSlideObj.DrawOneThumb7( Slide,
                               CMStringsToDraw, LinesCount,
                               ADGObj, ARect,
                               SlideDrawFlags );

  end; // with N_CM_GlobObj do
end; // procedure TN_CMMain5Form1.CMMFDrawThumb

//****************************** TN_CMMain5Form1.CMMFGetSlideDGridThumbSize ***
// Get Slide Thumbnail Size for DGRid
//
//     Parameters
// ASlide    - SLide to get Thumbnail size
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInpSize  - given Size on input, only one field (X or Y) should be <> 0
// AOutSize  - resulting Size on output, if AInpSize.X <> 0 then OutSize.Y <> 0,
//                                       if AInpSize.Y <> 0 then OutSize.X <> 0
// AMinSize  - (on output) Minimal Size
// APrefSize - (on output) Preferable Size
// AMaxSize  - (on output) Maximal Size
//
//  Is used as value of CMMFThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TN_CMMain5Form1.CMMFGetSlideDGridThumbSize( ASlide : TN_UDCMBSlide; ADGObj: TN_DGridBase;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
  ItemDYSize : Integer;
  RowCount : Integer;
begin
  with {N_CM_GlobObj,} ADGObj do
  begin
    ThumbDIB := ASlide.GetThumbnail();
    ThumbSize := ThumbDIB.DIBObj.DIBSize;
//    N_i := DGLAddDySize; // debug

    AOutSize := Point(0,0);

    with ASlide.P^ do
      if ASlide is TN_UDCMSlide then
      begin
        RowCount := CMMThumbsSlidesTextRowsCount;
        if (ttsObjTeethChart in K_CMSThumbTextFlags) and
           (CMSTeethFlags = 0) then
          Dec(RowCount);
      end
      else
      begin
        RowCount := 1;
        if CMSSourceDescr <> '' then
          RowCount := 2;
      end;

    ItemDYSize := 4 + N_CM_ThumbFrameRowHeight * RowCount;

    if AInpSize.X > 0 then // given is AInpSize.X
//      AOutSize.Y := Round( AInpSize.X*ThumbSize.Y/ThumbSize.X ) + DGLAddDySize
      AOutSize.Y := Min( 2 * AInpSize.X,
                         Round(AInpSize.X*ThumbSize.Y/ThumbSize.X ) + ItemDYSize )
    else // AInpSize.X = 0, given is AInpSize.Y
//      AOutSize.X := Round( (AInpSize.Y-DGLAddDySize)*ThumbSize.X/ThumbSize.Y );
      AOutSize.X := Round( (AInpSize.Y-ItemDYSize)*ThumbSize.X/ThumbSize.Y );

    AMinSize  := Point(10,10);
    APrefSize := ThumbSize;
    AMaxSize  := Point(1000,1000);
  end; // with N_CM_GlobObj. ADGObj do
end; // procedure TN_CMMain5Form1.CMMFGetSlideDGridThumbSize

//**************************************** TN_CMMain5Form1.CMMFGetThumbSize ***
// Get Thumbnail Size (used as TN_DGridBase.DGGetItemSizeProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - given Thumbnail Index
// AInpSize  - given Size on input, only one field (X or Y) should be <> 0
// AOutSize  - resulting Size on output, if AInpSize.X <> 0 then OutSize.Y <> 0,
//                                       if AInpSize.Y <> 0 then OutSize.X <> 0
// AMinSize  - (on output) Minimal Size
// APrefSize - (on output) Preferable Size
// AMaxSize  - (on output) Maximal Size
//
//  Is used as value of CMMFThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TN_CMMain5Form1.CMMFGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
begin
  CMMFGetSlideDGridThumbSize( TN_UDCMBSlide(K_CMCurVisSlidesArray[AInd]),
                              ADGObj, AInpSize, AOutSize, AMinSize, APrefSize, AMaxSize );
end; // procedure TN_CMMain5Form1.CMMFGetThumbSize

//************************************ TN_CMMain5Form1.CMMFRebuildVisSlides ***
// Rebuild list of Visible (Filtered) Thumbnails and update ThumbsRFrame
//
//     Parameters
// ATryToSaveSelection - if =TRUE then TumbsFrame Selection will be saved if possible
//
// Used as SlidesFilterFrame.SFChangeNotify method
//
procedure TN_CMMain5Form1.CMMFRebuildVisSlides( ATryToSaveSelection : Boolean = FALSE );
var
//  ClosedSlidesNum : Integer;
  PrevVisSlidesArray : TN_UDCMSArray; // previous Visible Slides Array
  NewVisSlidesArray : TN_UDCMSArray;  // New Visible Slides Array - needed to prevent Consistency Error
  RFStateInds : TN_IArray;
  i, j, Ind, StudiesCount : Integer;
  SavedCurFThumbsRFrame: TN_Rast1Frame;
begin
  with CMMCurFThumbsDGrid do
  begin
//    K_CMRebuildVisSlidesByFilter();
    PrevVisSlidesArray := nil;
    RFStateInds := nil;
    if ATryToSaveSelection then
    begin
      DGGetSelection( RFStateInds );
      PrevVisSlidesArray := Copy( K_CMCurVisSlidesArray ); // to compare with new VisSlides
    end;

    N_Dump2Str( format( 'CMMFRebuildVisSlides >> StudyOnly=%s ShowArchived=%s', [N_B2S(K_CMStudyOnlyThumbsShowGUIModeFlag),N_B2S(K_CMShowArchivedSlidesFlag)] ) );

    NewVisSlidesArray := K_CMCurVisSlidesArray; //!!! needed to prevent Consistency Error while RebuildSlidesArrayByFilter

    // !!! needed to prevent CMMCurFThumbsRFrame redraw while Visible Slides List will be rebuild
    SavedCurFThumbsRFrame := CMMCurFThumbsRFrame;
    CMMCurFThumbsRFrame := nil;

    K_CMCurVisSlidesArray := nil;
//    ClosedSlidesNum := K_CMRebuildSlidesArrayByFilter(
//    K_CMRebuildSlidesArrayByFilter( K_CMEDAccess.CurSlidesList,

    with K_CMEDAccess.CurSlidesList do
    begin
      if Count > 0 then // to perevent range check error in XE5
      begin
        K_CMRebuildSlidesArrayByFilter( TN_PUDCMSlide(@(List[0])), Count,
                                        NewVisSlidesArray, StudiesCount,
                                        @K_CMCurSlideFilterAttrs );
        K_CMCurVisSlidesArray := NewVisSlidesArray;  // Set New Visiblw Slides List
      end;
    end;

    CMMCurFThumbsRFrame := SavedCurFThumbsRFrame;// Return CMMCurFThumbsRFrame

    DGNumItems := Length(K_CMCurVisSlidesArray); // Number of visible Thumbnails
    DGInitRFrame(); // should be called after all CMMFThumbsDGrid fields are set

    CMMFShowStringByTimer( format( K_CML1Form.LLLRebuildSlidesView1.Caption,
//                          ' %d of %d media object(s) are visible',
                          [DGNumItems, K_CMEDAccess.CurSlidesList.Count] ) );

    with  K_CMCurSlideFilterAttrs do
    begin
      FAOpenCount := Min( Length(K_CMCurVisSlidesArray) - StudiesCount, FAOpenCount );
      if FAOpenCount > 0 then
      begin
        SetLength( RFStateInds, FAOpenCount + 1 );
        RFStateInds[0] := 0; // Selected Slide Index
        for i := 1 to FAOpenCount  do
          RFStateInds[i] := i - 1 + StudiesCount; // Marked Slides Indexes
      end
      else
      if (PrevVisSlidesArray <> nil) and
         (Length(RFStateInds) > 0)   and
         (DGNumItems > 0) then
      begin
      // Restore ThumbsRFrame Selection if needed and possible
        j := 1;
        RFStateInds[0] := 0;
        for i := 1 to High(RFStateInds) do
        begin
          Ind := K_IndexOfIntegerInRArray( Integer(PrevVisSlidesArray[RFStateInds[i]]),
                                           PInteger(@K_CMCurVisSlidesArray[0]),
                                           DGNumItems );
          if Ind < 0 then Continue;
          RFStateInds[j] := Ind;
          Inc(j);
        end;

        if j = 1 then
          j := 0 // Clear Selection
        else
          RFStateInds[0] := RFStateInds[1];

        SetLength( RFStateInds, j );
      end;

      if FAOpenCount > 0 then
      begin
        N_Dump1Str( 'Start Open Action by UserDefFilter' );
        K_CMSMediaOpen( @K_CMCurVisSlidesArray[StudiesCount], FAOpenCount );
        FAOpenCount := 0;
        EdFramesPanel.Refresh();
      end;

      if Length(RFStateInds) > 0 then
        DGSetSelection( RFStateInds )
      else
        CMMCurFThumbsRFrame.Refresh();

    end;
    // Rebuild Actions Enable State and Correct Isodensity MOde
  end; // with CMMCurFThumbsDGrid do


  CMMFDisableActions( nil );
  K_FormCMSIsodensity.InitIsodensityMode();

//  if ClosedSlidesNum = 0 then Exit;
  if Length(RFStateInds) > 1 then
  begin
    if K_CMSFullScreenForm = nil then
      CMMCurFMainForm.ActiveControl := CMMCurFThumbsRFrame // otherwise SlidesFilterFrame gets Mouse and Keyboard events
  end
  else
  if CMMFActiveEdFrame <> nil then
  begin
    CMMFSelectThumbBySlide( CMMFActiveEdFrame.EdSlide );
    if K_CMSFullScreenForm = nil then
      if (CMMCurFMainForm as TK_FormCMMain5).pgcViewerHolder.ActivePageIndex = 0 then
        CMMCurFMainForm.ActiveControl := CMMFActiveEdFrame.RFrame;
  end;

end; // procedure TN_CMMain5Form1.CMMFRebuildVisSlides();

//****************************************** TN_CMMain5Form1.CMMFShowString ***
// Show given AStr in Self StatusBar
//
//     Parameters
// AStr - Sting to show
//
procedure TN_CMMain5Form1.CMMFShowString( AStr: string );
var
  PanelInd : Integer;
begin
  if CMMSkipCurFStatusBarInfo or
    (CMMCurFStatusBar = nil)  or
    (CMMCurFStatusBar.Panels.Count = 0) or
    StatusBarTimer.Enabled then Exit; // do not overwrite previous string

  PanelInd := 0;
  if CMMCurFStatusBar.Panels.Count > 1 then
    PanelInd := 1;

  CMMCurFStatusBar.Panels[PanelInd].Text := ' ' + AStr;

  CMMCurFStatusBar.Refresh();
end; // end of procedure TN_CMMain5Form1.CMMFShowString

//*********************************** TN_CMMain5Form1.CMMFShowStringByTimer ***
// Show given AStr in Self StatusBar and Start StatusBarTimer to preseve it
//
//     Parameters
// AStr - Sting to show
//
// Also add given AStr to Log
//
procedure TN_CMMain5Form1.CMMFShowStringByTimer( AStr: string );
begin
  if Self = nil then Exit; // needed in Support mode
  if Trim(AStr) <> '' then N_Dump1Str( AStr );
  StatusBarTimer.Enabled := False; // is needed if Time interval was not finished yet
  CMMFShowString( AStr );
  StatusBarTimer.Enabled := True; // Start Timer
end; // end of procedure TN_CMMain5Form1.CMMFShowStringByTimer

//*********************************** TN_CMMain5Form1.CMMFShowHideWaitState ***
// Show or Clear application wait mode
//
//   Parameters
// AShowWaitFlag - if =TRUE then wait mode is show, esle wait mode is clear
//
// Show crHourGlass cursor and message "Wait please ..." in StatusBar.
//
procedure TN_CMMain5Form1.CMMFShowHideWaitState( AShowWaitFlag : Boolean );
begin
//  N_Dump2Str( 'CMMFShowHideWaitState >>' +  N_B2S( AShowWaitFlag and (Screen.Cursor <> crHourGlass) ) );

  if AShowWaitFlag and (Screen.Cursor <> crHourGlass) then
  begin
    if CMMSkipCurFStatusBarInfo then Exit;
    CMMWSSavedCursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;
    if CMMCurFStatusBar <> nil then
    begin
      CMMWSSavedMessage:= CMMCurFStatusBar.Panels[1].Text;
      CMMCurFStatusBar.Panels[1].Text := '  Wait please ...';
      CMMCurFStatusBar.Repaint();
    end;
    CMMSkipCurFStatusBarInfo := TRUE;
  end
  else
  if Screen.Cursor = crHourGlass then
  begin
    if not CMMSkipCurFStatusBarInfo then Exit;
    Screen.Cursor := CMMWSSavedCursor;
    if CMMCurFStatusBar <> nil then
    begin
      CMMCurFStatusBar.Panels[1].Text:= CMMWSSavedMessage;
      CMMCurFStatusBar.Repaint();
    end;
    CMMSkipCurFStatusBarInfo := FALSE;
  end;
end; // end of procedure TN_CMMain5Form1.CMMFShowHideWaitState

//******************************************* TN_CMMain5Form1.CMMFShowScale ***
// Show Scale Factor for given ARFrame
//
//     Parameters
// ARFrame - TN_Rast1Frame which scale Factor should be shown
//
// Scale Factor is the percent of Width of RFSrcPRect relative to ARFrame.RFObjSize.X.
//
procedure TN_CMMain5Form1.CMMFShowScale( ARFrame: TN_Rast1Frame );
var
//  CurWholeWidth: integer;
//  FracDigits: integer;
//  ScaleFactor: double;
  Str: string;
begin
  if K_CMD4WAppFinState then Exit;

  Str := '';

  if TN_CMREdit3Frame(ARFrame.Parent).EdSlide <> nil then
  begin
{
    CurWholeWidth := N_RectWidth( ARFrame.RFLogFramePRect );

    if (CurWholeWidth > 0) and (ARFrame.RFObjSize.X > 0) then
    begin
      ScaleFactor := 100 * CurWholeWidth / ARFrame.RFObjSize.X;

      FracDigits := 3 - Round(Floor( log10(ScaleFactor) ));

      if FracDigits < 0 then FracDigits := 0
      else if FracDigits > 3 then FracDigits := 3;

      Str := Format( ' %.*f %%', [FracDigits, ScaleFactor] );

    end;
}
{
    ScaleFactor := 100 * ARFrame.RFGetCurRelObjSize();
    FracDigits := 3 - Round(Floor( log10(ScaleFactor) ));

    if FracDigits < 0 then FracDigits := 0
    else if FracDigits > 3 then FracDigits := 3;

    Str := Format( ' %.*f %%', [FracDigits, ScaleFactor] );
}
//  Str := Format( ' %.0f %%', [100 * ARFrame.RFGetCurRelObjSize()] );
    Str := Format( ' %3.0f%% / %.2fX', [100 * ARFrame.RFVectorScale, ARFrame.RFGetCurRelObjSize()] );
  end; // if TN_CMREdit3Frame(ARFrame.Parent).EdSlide <> nil then
  TK_FormCMSZoomMode(K_CMSZoomForm).SetByCurActiveFrame();

  if CMMCurFThumbsRFrame <> nil then
    CMMCurFThumbsRFrame.RedrawAllAndShow(); // Rebuild Thumbnail Pan Rect

  if CMMCurFStatusBar = nil then Exit; // for Old MainForm Compatibility
  CMMCurFStatusBar.Panels[0].Text := Str;
  CMMCurFStatusBar.Refresh();
end; // end of procedure TN_CMMain5Form1.CMMFShowScale

//****************************************** TN_CMMain5Form1.CMMFShowScroll ***
// Show Scroll State for given ARFrame
//
//     Parameters
// ARFrame - TN_Rast1Frame which Scroll State should be shown
//
procedure TN_CMMain5Form1.CMMFShowScroll( ARFrame: TN_Rast1Frame );
begin
  if K_CMD4WAppFinState then Exit;
  CMMCurFThumbsRFrame.RedrawAllAndShow(); // Rebuild Thumbnail Pan Rect
end; // end of procedure TN_CMMain5Form1.CMMFShowScroll

//**************************** TN_CMMain5Form1.CMMFChangeToolBarsVisibility ***
// Update ToolBars visibility by appropriate Actions state
//
procedure TN_CMMain5Form1.CMMFChangeToolBarsVisibility();
begin
  if Assigned(CMMCurChangeToolBarsVisibility) then
    CMMCurChangeToolBarsVisibility();
end; // end of procedure TN_CMMain5Form1.CMMFChangeToolBarsVisibility

//******************************************** TN_CMMain5Form1.CMMFShowHint ***
// Application ShowHint Event Handler
//
procedure TN_CMMain5Form1.CMMFShowHint( Sender: TObject );
begin
  CMMFShowString( GetLongHint( Application.Hint ) );
end; // end of procedure TN_CMMain5Form1.CMMFShowHint

//*********************************** TN_CMMain5Form1.CMMFRebuildActiveView ***
// Rebuild Thumbnail for Editing Slide Image in CMMFActiveEdFrame
//
//    Parameters
// ARebuildViewFlags - rebuilad active view flags
//
procedure TN_CMMain5Form1.CMMFRebuildActiveView( ARebuildViewFlags : TN_RebuildViewFlags = [] );
var
  NewSize : TFPoint;
  PCompCoords : TN_PCompCoords;
  MapRoot : TN_UDCompVis;
  SlideSizeChanged : Boolean;
  RFStateInds: TN_IArray;

begin
//  CMMFActiveEdFrame.RebuildSlideThumbnailSafe();
  with CMMFActiveEdFrame do
  begin
    NewSize := FPoint( EdSlide.GetMapImage.DIBObj.DIBSize );
    MapRoot := EdSlide.GetMapRoot();
    SlideSizeChanged := FALSE;
    PCompCoords := MapRoot.PCCS();
    with PCompCoords^ do
      if (rvfAllViewRebuild in ARebuildViewFlags) or
         (SRSize.X <> NewSize.X) or
         (SRSize.Y <> NewSize.Y) then
      begin
        SRSize := NewSize;
        RFrame.RVCTFrInit3( MapRoot );
//        RFrame.RFrInitByComp( MapRoot );

        RFrame.aFitInWindowExecute( TObject(-1) );
        SlideSizeChanged := TRUE;
        EdSlide.P^.CMSDB.PixWidth := Round(NewSize.X);
        EdSlide.P^.CMSDB.PixHeight := Round(NewSize.Y);

        EdFlashLightModeRFA.CMEFLComp := nil;
      end;
    // ShowWholeImage( TRUE );
    if not (rvfSkipThumbRebuild in ARebuildViewFlags) then
      RebuildSlideThumbnail();

    ImgClibrated.Visible := cmsfUserCalibrated in EdSlide.P.CMSDB.SFlags;
    ImgHasDiagn.Visible := EdSlide.P.CMSDiagn <> '';

    RFrame.RFrChangeRootComp( MapRoot ); // SetNew Root Comp
    RFrame.RedrawAllAndShow(); // needed for VObjects Search
    // ShowWholeImage();
  end;

  if rvfSkipThumbRebuild in ARebuildViewFlags then Exit;

  CMMCurFThumbsRFrame.RedrawAllAndShow();
  if not SlideSizeChanged then Exit;
  // Rebuild Thumbs RFrame
  CMMCurFThumbsDGrid.DGGetSelection( RFStateInds );
  CMMCurFThumbsDGrid.DGInitRFrame();
  CMMCurFThumbsDGrid.DGSetSelection( RFStateInds );
end; // function TN_CMMain5Form1.CMMFRebuildActiveView

//********************************** TN_CMMain5Form1.CMMFCheckBSlideExisting ***
// Start Editing Slide Image in CMMFActiveEdFrame
//
//     Parameters
// Result - Return True if CMMFActiveDIB was set OK
//
// Set CMMFActiveDIB - CMMFActiveEdFrame.CurrentUDDIB.DIBObj - and retrun True if all is OK
//
function TN_CMMain5Form1.CMMFCheckBSlideExisting( ): boolean;
begin
  Result := False;

  if CMMFActiveEdFrame = nil then Exit;
  if CMMFActiveEdFrame.EdSlide = nil then Exit;

  Result := True;
end; // function TN_CMMain5Form1.CMMFCheckBSlideExisting

//*************************************** TN_CMMain5Form1.CMMFSaveUNDOState ***
// Finish Editing Slide Image in CMMFActiveEdFrame
//
//     Parameters
// AEdActName - Editor Action Name for showing in StatusBar
// ASaveUndoFlags - Save Current State to  UndoBuffer Flags
//
procedure TN_CMMain5Form1.CMMFSaveUNDOState( AEdActName: string;
                                            ASaveUndoFlags : TK_CMSlideSaveStateFlags;
                                            AHistActionCode : Integer );
var
  SelectedVObj : TN_UDCompVis;
begin

  with CMMFActiveEdFrame do
  begin
    SelectedVObj := EdVObjSelected;

    if SelectedVObj <> nil then
      ChangeSelectedVObj( 0 );

    if cmssfCurImgChanged in ASaveUndoFlags then
      with EdSlide.GetCurrentImage(), PISP^ do
      begin // Clear CurImg.UDData
        UDData := nil;
        Include( CDIBFlagsN, uddfnFreeUDData );
      end;

    EdUndoBuf.UBPushSlideState( AEdActName, ASaveUndoFlags, AHistActionCode );

    K_CMEDAccess.EDASaveSlideToECache( EdSlide );
    if K_CMEDAccess.SlidesSaveMode = K_cmesImmediately then
      K_CMEDAccess.EDASaveSlidesArray( @EdSlide, 1 );

    if SelectedVObj <> nil then
      ChangeSelectedVObj( 1, SelectedVObj );
  end; // with CMMFActiveEdFrame do
end; // procedure TN_CMMain5Form1.CMMFSaveUNDOState

//********************************** TN_CMMain5Form1.CMMFFinishImageEditing ***
// Finish Slides not changing Action
//
//     Parameters
// AVobjSelected - Vobject to restore selection
//
procedure TN_CMMain5Form1.CMMFFinishSlidesAction( AVobjSelected : TObject );
begin
  // Restore Selected Vobj
  if AVobjSelected <> nil then
    CMMFActiveEdFrame.ChangeSelectedVObj( 1, TN_UDCompVis(AVobjSelected) );

  CMMRedrawOpenedFromGiven( @K_CMEDAccess.LockResSlides[0],
                            K_CMEDAccess.LockResCount );

  K_CMEDAccess.EDAUnlockAllLockedSlides( K_cmlrmOpenLock );

end; // procedure TN_CMMain5Form1.CMMFFinishSlidesAction

//********************************** TN_CMMain5Form1.CMMFFinishImageEditing ***
// Finish Editing Slide Image in CMMFActiveEdFrame
//
//     Parameters
// AEdActName - Editor Action Name for showing in StatusBar
// ASaveUndoFlags - Save Current State to  UndoBuffer Flags
// AHistActionCode - History Action Code
// ARebuildActiveView - unconditional rebuild EdFrame and Thumbnail (after restore original image)
//
procedure TN_CMMain5Form1.CMMFFinishImageEditing( AEdActName: string;
                                                 ASaveUndoFlags : TK_CMSlideSaveStateFlags;
                                                 AHistActionCode : Integer = -1;
                                                 ARebuildActiveView : Boolean = FALSE );
begin

  with CMMFActiveEdFrame do
  begin

//    AskAndSaveCurrentDIB( False );
    CMMFSelectThumbBySlide( EdSlide );
    if ARebuildActiveView then
      CMMFRebuildActiveView( [rvfAllViewRebuild] )
    else
      CMMFRebuildActiveView( );
    if ASaveUndoFlags <> [] then
    begin
      with EdSlide, P()^ do begin
//        CMSDTImgMod := Now();
        if cmssfMapRootChanged in ASaveUndoFlags then
          CMSDTMapRootMod := K_CMEDAccess.EDAGetSyncTimestamp();
        if cmssfCurImgChanged in ASaveUndoFlags then
          CMSDTImgMod := K_CMEDAccess.EDAGetSyncTimestamp();

        CMSProvIDModified := K_CMEDAccess.CurProvID; // Provider ID Modified
        CMSLocIDModified  := K_CMEDAccess.CurLocID; // Location ID Modified
        CMSCompIDModified := K_CMSServerClientInfo.CMSClientVirtualName;
        ASaveUndoFlags := ASaveUndoFlags + [cmssfAttribsChanged];
      end;
      CMMFSaveUNDOState( AEdActName, ASaveUndoFlags, AHistActionCode );
    end; // if AEditFinishMode <> ufmUNDOSkip then

    N_Dump1Str( Name +':' + AEdActName );
  end; // with CMMFActiveEdFrame do

  CMMFRefreshActiveEdFrameHistogram();

  CMMFDisableUNDOActions(); // Update UNDO related Actions Enable property
  CMMFShowString( '' );
end; // procedure TN_CMMain5Form1.CMMFFinishImageEditing

//*********************************** TN_CMMain5Form1.CMMFFinishVObjEditing ***
// Finish Editing Slide Vector Object in CMMFActiveEdFrame
//
//     Parameters
// AEdActName - Editor Action Name for showing in StatusBar
// AHistActionCode - History Action Code
//
procedure TN_CMMain5Form1.CMMFFinishVObjEditing( AEdActName: string; AHistActionCode : Integer );
begin
  with CMMFActiveEdFrame, EdSlide, P()^ do
  begin
//    CMSDTImgMod := Now();
//    CMSDTImgMod := K_CMEDAccess.EDAGetSyncTimestamp();
    CMSDTMapRootMod := K_CMEDAccess.EDAGetSyncTimestamp();
    CMSProvIDModified := K_CMEDAccess.CurProvID; // Provider ID Modified
    CMSLocIDModified  := K_CMEDAccess.CurLocID; // Location ID Modified
    CMSCompIDModified := K_CMSServerClientInfo.CMSClientVirtualName;
    RebuildSlideThumbnail();
//  CMMCurFThumbsRFrame.RedrawAllAndShow();
    if not CMMSkipSelectThumbWhileFinishVObjEditing then
      CMMFSelectThumbBySlide( EdSlide );
{
  end;


  with CMMFActiveEdFrame do
  begin
}
    CMMFSaveUNDOState( AEdActName, [cmssfAttribsChanged,cmssfMapRootChanged], AHistActionCode );
    N_Dump1Str( Name +':' + AEdActName );
    RFrame.RedrawAllAndShow();
  end;

  CMMFDisableUNDOActions();
  CMMFShowString( '' );
end; // procedure TN_CMMain5Form1.CMMFFinishVObjEditing

//********************************** TN_CMMain5Form1.CMMFCancelImageEditing ***
// Cancel Editing Slide Image in CMMFActiveEdFrame
//
procedure TN_CMMain5Form1.CMMFCancelImageEditing();
begin
  CMMFShowString( '' );
end; // procedure TN_CMMain5Form1.CMMFCancelImageEditing

//************************************* TN_CMMain5Form1.CMMOpenedStudiesLock ***
// Lock opened Studies for Editing
//
//     Parameters
// APStudy - pointer to Studies array start element to lock
// AStudiesCount - number of Studies to lock
// AWasLockedFlag - resulting value is TRUE is Stuies are locked - LockOpeneStudies mode
// ASkipUnlockAfterRefresh - if FALSE then if locked Studies are changed lock
//                           operation is breaked and locked Studies are unlocked,
//                           else lock operation is continued
// Result - Returns TRUE if Studies are Locked for Edit
// Result - Returns 0 - if all Studies are Locked for Edit, 1 - if some Studies Refresh is Needed
//                  2 - if some Studies are Locked by other users
//
// AStudiesCount should be 1 or 2
//
function TN_CMMain5Form1.CMMOpenedStudiesLock( APStudy: TN_PUDCMStudy;
                 AStudiesCount: Integer; out AWasLockedFlag : Boolean;
                 ASkipUnlockAfterRefresh : Boolean ) : Integer;
var
  RefreshNewSlidesCount, RefreshDelSlidesCount, RefreshUpdateSlidesCount : Integer;
  LCount : Integer;
  LockedStudies : array [0..1] of TN_UDCMSlide;
  WStr : string;

  procedure BuildLockedStudiesArray();
  var
    WPSlide : TN_PUDCMSlide;
  begin
    LCount := 0;
    WPSlide := TN_PUDCMSlide(APStudy);
    if cmsfIsLocked in APStudy.P.CMSRFlags then
    begin
      LockedStudies[0] := WPSlide^;
      LCount := 1;
    end;
    Inc(WPSlide);
    if AStudiesCount > 1 then
    begin
      if cmsfIsLocked in WPSlide.P.CMSRFlags then
      begin
        LockedStudies[1] := WPSlide^;
        LCount := 2;
      end;
    end;
  end; // procedure BuildLockedStudiesArray

begin
  Result := 0;
  // check if Opened Studies are Locked
  AWasLockedFlag := cmsfIsLocked in APStudy.P.CMSRFlags;


  AStudiesCount := Min( AStudiesCount, 2 ); // precaution

  WStr := '';
  if AStudiesCount > 0 then
  begin
    WStr := APStudy.ObjName;
    if AStudiesCount > 1 then
      WStr := WStr + ',' + TN_PUDBase((TN_BytesPtr(APStudy) + SizeOf(TN_UDBase)))^.ObjName;
  end;

  N_DumpStr( K_CMStudyDetailsDumpCInd, format( 'Study >> Lock IDs=%s WereLocked=%s',
                                       [WStr,N_B2Str(AWasLockedFlag)] ) );

  if not AWasLockedFlag then
  begin // Locked for Edit
    K_CMEDAccess.EDALockSlides( TN_PUDCMSlide(APStudy), AStudiesCount, K_cmlrmEditStudyLock );
    K_CMEDAccess.LockResCount := 0;

    BuildLockedStudiesArray();

    // Check Study Updates
    if K_CMEDAccess.LockResUpdateStudyCount > 0 then
    begin
    // Refresh all Slides
      K_CMEDAccess.EDARefreshCurSlidesSet( RefreshNewSlidesCount, RefreshDelSlidesCount,
                                           RefreshUpdateSlidesCount );
      K_CMRefreshOpenedView();
      CMMFRebuildVisSlides();

      if not ASkipUnlockAfterRefresh then
      begin
        if LCount > 0 then
          K_CMEDAccess.EDAUnLockSlides( @LockedStudies[0], LCount, K_cmlrmSaveOpenLock );

        Result := 1;
        Exit;
      end;
    end; // if K_CMEDAccess.LockResUpdateStudyCount > 0 then

    // Check Study Lock
    if LCount < AStudiesCount then
    begin
      // Unlock Locked studies
      if LCount > 0 then
        K_CMEDAccess.EDAUnLockSlides( @LockedStudies[0], LCount, K_cmlrmSaveOpenLock );
      Result := 2;
      Exit;
    end;
  end;

  // Studies are successfuly locked
end; // procedure TN_CMMain5Form1.CMMOpenedStudiesLock

//*********************************** TN_CMMain5Form1.CMMOpenedStudiesLockDlg ***
// Lock opened Studies for Editing
//
//     Parameters
// APStudy - pointer to Studies array start element to lock
// AStudiesCount - number of Studies to lock
// AWasLockedFlag - resulting value is TRUE if Studies are locked - LockOpeneStudies mode
// ASkipUnlockAfterRefresh - if FALSE then if locked Studies are changed, lock
//                           operation is breaked and locked Studies are unlocked,
//                           else lock operation is continued
// Result - Returns 0 - if all Studies are Locked for Edit,
//                  1 - if some Studies Refresh is Needed
//                  2 - if some Studies are Locked by other users
//
// AStudiesCount should be 1 or 2
//
function TN_CMMain5Form1.CMMOpenedStudiesLockDlg( APStudy: TN_PUDCMStudy;
                 AStudiesCount: Integer; out AWasLockedFlag : Boolean;
                 ASkipUnlockAfterRefresh : Boolean ) : Integer;
begin
  Result := CMMOpenedStudiesLock( APStudy, AStudiesCount, AWasLockedFlag,
                                  ASkipUnlockAfterRefresh );
  case Result of
  0: Exit;
  1: K_CMShowSoftMessageDlg( K_CML1Form.LLLStudy3.Caption, mtWarning, 5 );
  2: K_CMShowSoftMessageDlg( K_CML1Form.LLLStudy2.Caption, mtWarning, 5 );
  end;
end; // procedure TN_CMMain5Form1.CMMOpenedStudiesLockDlg

//********************************** TN_CMMain5Form1.CMMOpenedStudiesUnLock ***
// Unlock previously locked opened studies
//
//     Parameters
// APStudy - pointer to Studies array start element to lock
// AStudiesCount - number of Studies to lock
//
// AStudiesCount should be 1 or 2
//
procedure TN_CMMain5Form1.CMMOpenedStudiesUnLock( APStudy: TN_PUDCMStudy;
                                         AStudiesCount: Integer );
var
  WStr : string;
begin
  WStr := '';
  if AStudiesCount > 0 then
  begin
    WStr := APStudy.ObjName;
    if AStudiesCount > 1 then
      WStr := WStr + ',' + TN_PUDBase((TN_BytesPtr(APStudy) + SizeOf(TN_UDBase)))^.ObjName;
  end;
  N_DumpStr( K_CMStudyDetailsDumpCInd,  'Study >> UnLock IDs='+WStr );
  AStudiesCount := Min( AStudiesCount, 2 ); // precaution
  K_CMEDAccess.EDAUnLockSlides( TN_PUDCMSlide(APStudy), AStudiesCount, K_cmlrmSaveOpenLock );
end; // procedure TN_CMMain5Form1.CMMOpenedStudiesUnLock

//*************************************** TN_CMMain5Form1.CMMStudiesLockTry ***
// Try to lock Studies for Editing
//
//     Parameters
// APStudies - pointer to studies array first element
// ACount    - number of studies array elements
// AWasLockedFlag - resulting value is TRUE if Study is already locked
// ATryCount - maximal number of attemps to lock study
// ATryPauseMS - pause between attemps in milliseconds 
// Result - Returns TRUE if Studies are Locked for Edit
//
function TN_CMMain5Form1.CMMStudiesLockTry( APStudies : TN_PUDCMStudy; ACount : Integer;
                                                out AWasLockedFlag: Boolean;
                                                ATryCount, ATryPauseMS: Integer ): Boolean;
var
  i, LockResult : Integer;

begin
  Result := TRUE;
  CMMWSSavedCursor := Screen.Cursor;
  for i := 1 to ATryCount do
  begin
    if i > 1 then // wait before try again
      sleep(ATryPauseMS);

    LockResult := CMMOpenedStudiesLock( APStudies, ACount, AWasLockedFlag, TRUE );
    Result := LockResult = 0;
    if Result then break;
    Screen.Cursor := crHourGlass;
  end;

  Screen.Cursor := CMMWSSavedCursor;

end; // function TN_CMMain5Form1.CMMStudiesLockTry

//************************************ TN_CMMain5Form1.CMMActiveStudyLockDlg ***
// Try to lock current active Study for Editing
//
//     Parameters
// AWasLockedFlag - resulting value is TRUE if Study is already locked
// ATryCount - maximal number of attemps to lock study
// ATryPauseMS - pause between attemps in milliseconds
// Result - Returns TRUE if Studies are Locked for Edit
//
function TN_CMMain5Form1.CMMActiveStudyLockTry( out AWasLockedFlag: Boolean;
                                                ATryCount, ATryPauseMS: Integer ): Boolean;
begin
  Result := CMMStudiesLockTry( TN_PUDCMStudy(@CMMFActiveEdFrame.EdSlide), 1,
                               AWasLockedFlag, ATryCount, ATryPauseMS );
end; // function TN_CMMain5Form1.CMMActiveStudyLockTry

//************************************ TN_CMMain5Form1.CMMActiveStudyLockDlg ***
// Lock current active Study for Editing
//
//     Parameters
// AWasLockedFlag - resulting value is TRUE if Study is already locked
// ASkipUnlockAfterRefresh - if FALSE then if locked Studies are changed lock
//                           operation is breaked and locked Studies are unlocked,
//                           else lock operation is continued
// Result - Returns TRUE if Studies are Locked for Edit
//
function TN_CMMain5Form1.CMMActiveStudyLockDlg( var AWasLockedFlag : Boolean;
                                        ASkipUnlockAfterRefresh : Boolean  ) : Integer;
begin
  Result := CMMOpenedStudiesLockDlg( TN_PUDCMStudy(@CMMFActiveEdFrame.EdSlide), 1,
                                     AWasLockedFlag, ASkipUnlockAfterRefresh );
end; // procedure TN_CMMain5Form1.CMMActiveStudyLockDlg

//********************************** TN_CMMain5Form1.CMMActiveStudyUnLock ***
// Unlock previously locked active Study
//
procedure TN_CMMain5Form1.CMMActiveStudyUnLock();
begin
  with CMMFActiveEdFrame do
    if cmsfIsLocked in EdSlide.P.CMSRFlags then
      K_CMEDAccess.EDAUnLockSlides( @EdSlide, 1, K_cmlrmSaveOpenLock );
end; // procedure TN_CMMain5Form1.CMMActiveStudyUnLock

//*************************** TN_CMMain5Form1.CMMStudyRemountOneSlideToItem ***
// Remount given Slide to given Study Item Context
//
//     Parameters
// ARSlide - Slide to remount
// ARItem  - Study Item to remount
// APRContext - pointer to Remount Context structure
// Result - Returns Remount Update Flags
//
function TN_CMMain5Form1.CMMStudyRemountOneSlideToItem( ARItem: TN_UDBase; ARSlide : TN_UDCMSlide;
                                        APRContext : TK_PCMStudyRemountOneSlideContext;
                                        var ARUpdateFlags : TK_CMStudyRemountUpdateFlags ) : TK_CMEDResult;
var
  StudiesToLock : array [0..1] of TN_UDCMStudy;
  LockCount : Integer;
  StudiesWereLocked : Boolean;
begin
  Result := K_edOK;

  ARUpdateFlags := K_CMStudyGetRemountContext( ARSlide, ARItem, APRContext );

  if ARUpdateFlags = [] then Exit; // Same Slide or Dismount Empty Item


  // Check Mount to not empty Item
  if (APRContext.CMRItemSlide <> nil) and
     (mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLStudy4.Caption, mtConfirmation )) then
  // 'There is already an image in this template position. Do you want to Dismount the current image and replace it with the new one? '
  begin
    ARUpdateFlags := [];
    Exit;
  end;

  with K_CMEDAccess, APRContext^ do
  begin
//  K_srufRedrawItemStudy,  // Redraw Remount Item Study
//  K_srufRedrawSlideStudy  // Redraw Slide previouse Open Study

    StudiesToLock[0] := CMRItemStudy;
    LockCount := 1;
    if K_srufRedrawSlideStudy in ARUpdateFlags then
    begin
      StudiesToLock[1] := TN_UDCMStudy(CMRSlideStudy);
      LockCount := 2;
    end;

    if CMMOpenedStudiesLockDlg( @StudiesToLock[0], LockCount, StudiesWereLocked, FALSE ) <> 0 then
      ARUpdateFlags := [] // Clear Update Flags - updates are not needed
    else
    begin
    // Studies were Locked - Remount could be done

      EDAStudySavingStart();

      if CMRItemSlide <> nil then // Dismount Previouse Slide from given Study Item
         Result := K_CMEDAccess.EDAStudyDismountOneSlideFromItem( CMRItem,
                               CMRItemSlide, CMRItemStudy, FALSE );
      if CMRSlideItem <> nil then // Dismount Slide from Prevouse Study
      begin
        Result := K_CMEDAccess.EDAStudyDismountOneSlideFromItem( CMRSlideItem,
                               CMRSlide, CMRSlideStudy, FALSE  );
      // Rebuild Study Thumbnail and Save
        if K_srufRedrawSlideStudy in ARUpdateFlags then
        begin
          CMRSlideStudy.CreateThumbnail();
          CMRSlideStudy.SetChangeState();
          EDAStudySave( CMRSlideStudy );
        end;
      end;

      if CMRSlide <> nil then
      // Mount given Slide to given Study Item
        Result := EDAStudyMountOneSlideToEmptyItem( CMRItem, CMRSlide, CMRItemStudy );

      if K_srufRedrawItemStudy in ARUpdateFlags then
      begin
      // Rebuild Study Thumbnail and Save
        CMRItemStudy.CreateThumbnail();
        CMRItemStudy.SetChangeState();
        EDAStudySave( CMRItemStudy );
      end;

      EDAStudySavingFinish();

      if not StudiesWereLocked then
    // UnLocked for Edit
        CMMOpenedStudiesUnLock( @StudiesToLock[0], LockCount );
    end; // if CMMOpenedStudiesUnLock ...

  end; // with K_CMEDAccess, APRContext^ do

end; // function TN_CMMain5Form1.CMMStudyRemountOneSlideToItem

//************************** TN_CMMain5Form1.CMMStudyRemountAllSlidesToItem ***
// Remount given Slide to given Study Item Context
//
//     Parameters
// ARSlide - Slide to remount
// ARItem  - Study Item to remount
// APRContext - pointer to Remount Context structure
// Result - Returns Remount Update Flags
//
function TN_CMMain5Form1.CMMStudyRemountAllSlidesToItem( ARItem: TN_UDBase; ARSlide : TN_UDCMSlide;
                                          APRContext : TK_PCMStudyRemountOneSlideContext;
                                          var ARUpdateFlags : TK_CMStudyRemountUpdateFlags ) : TK_CMEDResult;
var
  StudiesToLock : array [0..1] of TN_UDCMStudy;
  LockCount : Integer;
  StudiesWereLocked : Boolean;
  DestSlides : TN_UDCMSArray;
  SrcSlides : TN_UDCMSArray;

begin
  Result := K_edOK;

  ARUpdateFlags := K_CMStudyGetRemountContext( ARSlide, ARItem, APRContext );

  if ARUpdateFlags = [] then Exit; // Same Slide or Dismount Empty Item


  // Show dialog if Mount to not empty Item an if Mounting Slide was Mounted to other Item
  if (APRContext.CMRItemSlide <> nil) and (APRContext.CMRSlideItem <> nil) and
     (mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLStudy7.Caption, mtConfirmation )) then
  // 'This study position contains image(s). Would you like to dismount them all and replace with the new one(s)? '
//     (mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLStudy4.Caption, mtConfirmation )) then
  // 'There is already an image in this template position. Do you want to Dismount the current image and replace it with the new one? '
  begin
    ARUpdateFlags := [];
    Exit;
  end;

  with K_CMEDAccess, APRContext^ do
  begin
//  K_srufRedrawItemStudy,  // Redraw Remount Item Study
//  K_srufRedrawSlideStudy  // Redraw Slide previouse Open Study

    StudiesToLock[0] := CMRItemStudy;
    LockCount := 1;
    if K_srufRedrawSlideStudy in ARUpdateFlags then
    begin
      StudiesToLock[1] := TN_UDCMStudy(CMRSlideStudy);
      LockCount := 2;
    end;

    if CMMOpenedStudiesLockDlg( @StudiesToLock[0], LockCount, StudiesWereLocked, FALSE ) <> 0 then
      ARUpdateFlags := [] // Clear Update Flags - updates are not needed
    else
    begin
    // Studies were Locked - Remount could be done

      EDAStudySavingStart();

      if CMRSlideItem <> nil then // Dismount Slides from Source Item
      begin
        if CMRItemSlide <> nil then // Dismount Slides from Target Item
        begin
           EDAStudyDismountAllSlidesFromItem( CMRItem,
                                             DestSlides, CMRItemStudy, FALSE,
                                             CMRItemFRFlags, CMRItemTeethFlags );
           if Length(DestSlides) > 0 then // Save FlipRotated Slides after Dismounting From Target Item
             EDASaveSlidesArray( @DestSlides[0], Length(DestSlides) );
        end;

        Result := EDAStudyDismountAllSlidesFromItem( CMRSlideItem,
                                   SrcSlides, CMRSlideStudy, FALSE,
                                   CMRSlideItemFRFlags, CMRSlideItemTeethFlags,
                                   CMRItemFRFlags, CMRItemTeethFlags );
      // Rebuild Study Thumbnail and Save
        if K_srufRedrawSlideStudy in ARUpdateFlags then
        begin
          CMRSlideStudy.CreateThumbnail();
          CMRSlideStudy.SetChangeState();
          EDAStudySave( CMRSlideStudy );
        end;
      end;

      if CMRSlide <> nil then
      begin // Mount Slides to Target Study Item
        if CMRSlideItem <> nil then // Mount all Slides Dismounted from Source Item to Target Item
        begin
          Result := EDAStudyMountAllSlidesToEmptyItem( CMRItem, SrcSlides, CMRItemStudy, FALSE, CMRItemFRFlags, CMRItemTeethFlags );
          if Length(SrcSlides) > 0 then // Save FlipRotated Slides after Mounting
            EDASaveSlidesArray( @SrcSlides[0], Length(SrcSlides) );
        end
        else                       // Add given Slide to Target Item
        begin
          Result := EDAStudyMountAddSlideToItem( CMRItem, CMRSlide, CMRItemStudy,
                                                 FALSE, CMRItemFRFlags, CMRItemTeethFlags );
          EDASaveSlide( CMRSlide );
        end;
      end; // if CMRSlide <> nil then

      if K_srufRedrawItemStudy in ARUpdateFlags then
      begin
      // Rebuild Study Thumbnail and Save
        CMRItemStudy.CreateThumbnail();
        CMRItemStudy.SetChangeState();
        EDAStudySave( CMRItemStudy );
      end;

      EDAStudySavingFinish();

      if not StudiesWereLocked then
    // UnLocked for Edit
        CMMOpenedStudiesUnLock( @StudiesToLock[0], LockCount );
    end; // if CMMOpenedStudiesUnLock ...

  end; // with K_CMEDAccess, APRContext^ do

end; // function TN_CMMain5Form1.CMMStudyRemountAllSlidesToItem

{
//******************************************** TN_CMMain5Form1.CMMStudyDismountSelected ***
// Dismount Selected Slides in Current Active Study
//
//     Parameters
// AStudy - given Study to dismount selected
// Result - Returns -1 if Study is Locked by some other User, or number of dismounted Slides
//
function TN_CMMain5Form1.CMMStudyDismountSelected( AStudy: TN_UDCMStudy ) : Integer;
var
  i : Integer;
  WasLockedFlag : Boolean;

begin
  Result := -1;
  if CMMOpenedStudiesLockDlg( @AStudy, 1, WasLockedFlag, FALSE ) > 0 then Exit;

  with AStudy do
  begin
    Result := CMSSelectedCount;
    K_CMEDAccess.EDAStudySavingStart();
    for i := CMSSelectedCount - 1 downto 0  do
      K_CMEDAccess.EDAStudyDismountOneSlideFromItem( CMSSelectedItems[i],
                                    nil, AStudy  );

    UnSelectAll();

    CreateThumbnail();
    SetChangeState();
    K_CMEDAccess.EDAStudySave( AStudy );
    K_CMEDAccess.EDAStudySavingFinish();
  end;

  if not WasLockedFlag then
  // UnLocked for Edit
    K_CMEDAccess.EDAUnLockSlides( TN_PUDCMSlide(@AStudy), 1, K_cmlrmSaveOpenLock );
end; // procedure TN_CMMain5Form1.CMMStudyDismountSelected
}

//********************************** TN_CMMain5Form1.CMMStudyEndDrug ***
// End Drugging Slide over Opened Study
//
//     Parameters
// ASkipEndDrag - if TRUE then no EndDrug action is done, clear Drag Context Only else
//
procedure TN_CMMain5Form1.CMMStudyEndDrug( ASkipEndDrag : Boolean );
var
  RUpdateFlags : TK_CMStudyRemountUpdateFlags;
  StudyRemountContext : TK_CMStudyRemountOneSlideContext;
  StudyItem : TN_UDBase;

begin

  StudyItem := TN_UDBase(CMMCurDragOverComp);
  N_DumpStr( K_CMStudyDetailsDumpCInd, format('StudyEndDrag start Slide=%s Skip=%s',
                             [TN_UDCMSlide(CMMCurDragObject).ObjName, N_B2S(ASkipEndDrag)] ) );
  CMMRedrawDragOverComponent( 0 );

  if not ASkipEndDrag then
  begin
    if K_CMEDDBVersion >= 39 then
      CMMStudyRemountAllSlidesToItem( StudyItem, TN_UDCMSlide(CMMCurDragObject),
                                      @StudyRemountContext, RUpdateFlags )
    else
      CMMStudyRemountOneSlideToItem( StudyItem, TN_UDCMSlide(CMMCurDragObject),
                                     @StudyRemountContext, RUpdateFlags );
    if K_srufRebuildVisSlides in RUpdateFlags then CMMFRebuildVisSlides();
    if K_srufRedrawItemStudy in RUpdateFlags then
      StudyRemountContext.CMRItemStudy.CMSRFrame.RedrawAllAndShow();
    if K_srufRedrawSlideStudy in RUpdateFlags then
      StudyRemountContext.CMRSlideStudy.CMSRFrame.RedrawAllAndShow();
    if not (K_srufRebuildVisSlides in RUpdateFlags) and
      (K_srufRedrawItemStudy in RUpdateFlags) then
      CMMCurFThumbsRFrame.RedrawAllAndShow();
      
  end; // if not ASkipEndDrag then

  CMMCurDragObject := nil;
  CMMCurBeginDragControl := nil;
  CMMCurDragObjectsList.Clear;
  N_Dump2Str( 'StudyEndDrag fin' );

end; // function TN_CMMain5Form1.CMMStudyEndDrug

//************************************** TN_CMMain5Form1.CMMSlideEndDrag ***
// Add given Slide to Opened after Drag
//
//     Parameters
// ASlide - given Slide to open
// AEdFrame - frame to open, if =NIL then Frame will be auto selected
// AddToOpenedFlags - flags to contorl Frame auto selection
//
procedure TN_CMMain5Form1.CMMSlideEndDrag( ASlide : TN_UDCMSlide; AEdFrame : TN_CMREdit3Frame;
                AddToOpenedFlags : TK_CMSlideAddToOpenedFlags = [] );
var
  SelectedSlideFrame : TN_CMREdit3Frame;
begin
  CMMCurBeginDragControl := nil;
  CMMCurDragObject := nil;
  CMMCurDragObjectsList.Clear;

  with ASlide.P^, CMSDB do
    if (cmsfIsMediaObj in SFlags) then Exit; // Skip Video Drag

  SelectedSlideFrame := CMMFFindEdFrame( ASlide );


  if (SelectedSlideFrame <> nil)  then
  begin
    K_CMShowMessageDlgByTimer( K_CML1Form.LLLThumbsRFrame1.Caption,
//            'This object is already open',
                              mtInformation );
    Exit;
  end;

 // Prepare Selected Frame to Open new Slide
  if AEdFrame <> nil then
  begin
    N_BrigHist2Form.SetSkipSelfClose( TRUE );
    CMMFSetActiveEdFrame( AEdFrame, TRUE );
    AEdFrame.EdFreeObjects();
    N_BrigHist2Form.SetSkipSelfClose( FALSE );
    AddToOpenedFlags := [];
  end;
//
// Open new Slide
  CMMAddMediaToOpened( ASlide, AddToOpenedFlags, AEdFrame );
end; // end of procedure TN_CMMain5Form1.CMMSlideEndDrag

//********************************** TN_CMMain5Form1.CMMRedrawOpenedFromGiven ***
// Redarw EdFrames with open Slides from given list
//
//     Parameters
// APSlide - pointer to Slides array start element
// AStudiesCount - number of Slides to check
//
// AStudiesCount should be 1 or 2
//
procedure TN_CMMain5Form1.CMMRedrawOpenedFromGiven( APSlide: TN_PUDCMSlide;
                                         ASlidesCount: Integer );
var
  i : integer;
begin
  for i := 0 to ASlidesCount - 1 do
  begin
    if APSlide^.CMSRFrame <> nil then
      APSlide^.CMSRFrame.RedrawAllAndShow();
    Inc(APSlide);
  end;
end; // procedure TN_CMMain5Form1.CMMRedrawOpenedFromGiven

//****************************************************** TN_CMMain5Form1.CMMSetSlidesAttrs ***
// Set properties to last added new Slides
//
//    Parameters
// ASlidesCount - number of last added new Slide  to edit properties
// ACaption - form caption
// ASkipProcessDate - skip date while change Objects Properties
// AIniMediaType - initial Media Type
//
function TN_CMMain5Form1.CMMSetSlidesAttrs( ASlidesCount: Integer;
                             APDCMAttrs : TK_PCMDCMAttrs;
                             ACaption : string = '';
                             ASSAFlags : TK_CMSetSlidesAttrsFlags = [K_ssafSkipProcessDate];
                             AIniMediaType : Integer = 0 ) : Integer;

var
  i : Integer;
  LockResult : Integer;
  MountToStudy : Boolean;
  SavedList : TList;
  WasLockedFlag : Boolean;
  MountedInds : TN_IArray;
  PUDCMSlide : TN_PUDCMSlide;
  AutoOpenMode : Boolean;

begin

  N_Dump2Str('DB>> CMMSetSlidesAttrs start');
  MountToStudy := CMMFActiveEdFrame.IfSlideIsStudy;

  if MountToStudy then
  begin

    //////////////////////////////////////////////////
    // Save New Slides to Wrk List because of possible
    // refresh CurSlidesSet inside CMMOpenedStudiesLock
    SavedList := TList.Create;
    with K_CMEDAccess do
    begin
      LockResult := CurSlidesList.Count - ASlidesCount;
      for i := 0 to ASlidesCount - 1 do
      begin
        SavedList.Add( CurSlidesList[LockResult] );
        CurSlidesList.Delete(LockResult);
      end;
    end;
    //////////////////////////////////////////////////

    MountToStudy := CMMActiveStudyLockTry( WasLockedFlag, 10, 300 );

    //////////////////////////////////////////////////
    // Restore Saved Slides to CurSlidesSet
    for i := 0 to ASlidesCount - 1 do
      K_CMEDAccess.CurSlidesList.Add( SavedList[i] );
    SavedList.Free;
    //////////////////////////////////////////////////

    if not MountToStudy then // Show Message that old Processing Dialog will be call
      K_CMShowMessageDlg( K_CML1Form.LLLStudy5.Caption, mtWarning );
  end; // if MountToStudy then


  if MountToStudy then
  begin
  // Call New SetSlidesAttrs Dialog with Study to Mount
    Result := K_CMSetSlidesAttrs3( MountedInds, ASlidesCount, APDCMAttrs,
                                   nil, ACaption, ASSAFlags, AIniMediaType );
    if Length(MountedInds) > 0 then
    begin
      K_CMEDAccess.EDAStudySavingStart();
      TN_UDCMStudy(CMMFActiveEdFrame.EdSlide).CreateThumbnail();
      TN_UDCMStudy(CMMFActiveEdFrame.EdSlide).SetChangeState();
      K_CMEDAccess.EDAStudySave( TN_UDCMStudy(CMMFActiveEdFrame.EdSlide) );
      K_CMEDAccess.EDAStudySavingFinish();
    end;

    if not WasLockedFlag then
  // UnLocked for Edit
      CMMActiveStudyUnLock( );
  end
  else // Call Old SetSlidesAttrs Dialog without Study to Mount
  begin
    Result := K_CMSetSlidesAttrs( ASlidesCount, APDCMAttrs, ACaption,
                                  ASSAFlags, AIniMediaType );
  end;

 ///////////////////////////////
 // Select and Open Imported
 //
  Result := Result - K_CMEDAccess.RemovedFromCurSlidesSetCount;
  K_CMEDAccess.RemovedFromCurSlidesSetCount := 0;
  if Result > 0 then
  begin
  // Insert needed UI Commands to Buffer before all existing
    with K_CMEDAccess, CurSlidesList do
    begin
      // Search for AutoOpen Slides in Imorted List
      // If even one slide with AutoOpen mark Exists - then AutoOpen Mode should be used
      AutoOpenMode := FALSE;
//      PUDCMSlide := TN_PUDCMSlide(@List^[Count - Result]); // Search From the Begin of List
//      PUDCMSlide := TN_PUDCMSlide(@List^[Count - 1]); // Search From the End of List
      PUDCMSlide := TN_PUDCMSlide(@List[Count - 1]); // Search From the End of List
      for i := 0 to Result - 1 do
      begin
        if PUDCMSlide.CMSAutoOpen then
        begin
          AutoOpenMode := TRUE;
          break;
        end;
        Dec(PUDCMSlide);
      end;


      K_CMEDAccess.ExecCommandsFlag := TRUE;

      // Insert Open Slides Command (Last)
      if AutoOpenMode then
        K_ExecUICommand( 2, 'MediaOpen', [K_uicInsToBuffer] );

      // Insert Scroll to Selected Slides Command (Last or 1-st before Last)
      K_ExecUICommand( 2, 'ScrollToSelection', [K_uicInsToBuffer] );

      // Insert Slides Selection Commands - 1 Command to 1 Slide
      PUDCMSlide := TN_PUDCMSlide(@List[Count - Result]); // Search From the Begin of List
//      PUDCMSlide := TN_PUDCMSlide(@List^[Count - 1]); // Search From the End of List
      for i := 0 to Result - 1 do
      begin
        if not AutoOpenMode or PUDCMSlide.CMSAutoOpen then
          K_ExecUICommand( 0, PUDCMSlide.ObjName, [K_uicInsToBuffer] );
        PUDCMSlide.CMSAutoOpen := FALSE; // Clear Auto Open Flag -
        Inc(PUDCMSlide);
      end;

      // Insert Clear Selection Command (First)
      K_ExecUICommand( 2, 'MediaClearSelection', [K_uicInsToBuffer] );
    end;
  end;

  N_Dump2Str('DB>> CMMSetSlidesAttrs fin');
end; // function TN_CMMain5Form1.CMMSetSlidesAttrs

//********************************** TN_CMMain5Form1.CMMFDisableUNDOActions ***
// Disable UNDO Actions by current ActiveFrame state
//
procedure TN_CMMain5Form1.CMMFDisableUNDOActions();
var
  AllEnabled : Boolean;
begin
  AllEnabled := (CMMFActiveEdFrame <> nil)           and
                (CMMFActiveEdFrame.EdUndoBuf <> nil) and
                (CMMFActiveEdFrame.EdSlide <> nil );
  with N_CMResForm do
  begin
    aEditUndoLast.Enabled  := AllEnabled;
    aEditRedoLast.Enabled  := AllEnabled;
    aEditUndoRedo.Enabled  := AllEnabled;
    aEditRestOrigImage.Enabled:= AllEnabled;
    aEditRestOrigState.Enabled:= AllEnabled;
    if not AllEnabled then Exit;
    with CMMFActiveEdFrame, EdUndoBuf do
    begin
      aEditUndoLast.Enabled := (UBCurInd > UBMinInd);
      aEditRedoLast.Enabled := (UBCurInd < UBCount - 1);
      aEditUndoRedo.Enabled := (UBCount - UBMinInd > 1);
      aEditRestOrigState.Enabled :=
                        EdUndoBuf.UBRestoreSrcStateIsEnabled();
      aEditRestOrigImage.Enabled :=
                        EdUndoBuf.UBRestoreSrcImageIsEnabled();
    end;
  end;

end; // procedure TN_CMMain5Form1.CMMFDisableUNDOActions

//******************************** TN_CMMain5Form1.CMMFRebuildViewAfterUNDO ***
// Rebuild active frame and thumbnail after UNDO
//
//     Parameters
// AChangeCurStateSet - change Slide current state flags set
// APrevSize - Image Size Before Undo
//
procedure TN_CMMain5Form1.CMMFRebuildViewAfterUNDO( AChangeCurStateFlags : TK_CMSlideSaveStateFlags;
                                                   APrevSize : TPoint );
//
var
  MapRoot : TN_UDCompVis;
  SlideSizeChanged : Boolean;
  PSkipSelf : PByte;
  RFStateInds : TN_IArray;
begin
  if (CMMFActiveEdFrame = nil) or
     (CMMFActiveEdFrame.EdUndoBuf = nil) then Exit;

  with CMMFActiveEdFrame, EdSlide do
  begin
    MapRoot := GetMapRoot();
    PSkipSelf := GetPMeasureRootSkipSelf();
    with P^ do
      if N_CMResForm.aObjShowHide.Checked then
      begin
        Exclude(CMSRFlags, cmsfHideDrawings);
        PSkipSelf^ := 0
      end
      else
      begin
        Include(CMSRFlags, cmsfHideDrawings);
        PSkipSelf^ := 1;
      end;

    CMMFSelectThumbBySlide( EdSlide );
    if (cmssfMapRootChanged in AChangeCurStateFlags) or
       (cmssfCurImgChanged  in AChangeCurStateFlags) then
    begin
     // Rebuild View
      EdVObjSelected := nil;
      RebuildSlideThumbnail();
      RebuildVObjsSearchList();

//        EdMapUDDIB := EdSlide.GetMapImage();
      SlideSizeChanged := Int64(APrevSize) <> Int64(EdSlide.GetMapImage.DIBObj.DIBSize);
      if SlideSizeChanged then
      begin
        RebuildSlideView();
      end
      else
      // New Code - Save Image Zoomed State
        RFrame.RFrChangeRootComp( MapRoot );

      RFrame.RedrawAllAndShow();

      CMMCurFThumbsRFrame.RedrawAllAndShow();
      if SlideSizeChanged then
      begin
        CMMCurFThumbsDGrid.DGGetSelection( RFStateInds );
        CMMCurFThumbsDGrid.DGInitRFrame(); // is needed because Thumbnail Aspect may be changed
        CMMCurFThumbsDGrid.DGSetSelection( RFStateInds );
      end;
    end
    else
      RFrame.RedrawAllAndShow(); // for Search Context Rebuild

    if cmssfAttribsChanged in AChangeCurStateFlags then
    begin
    // Rebuild ActiveFrame Header and ThumbnailFrame
      FrameLeftCaption.Caption  := K_CMSlideViewCaption( EdSlide );
      FrameRightCaption.Caption := K_CMSlideFilterText( EdSlide );
      CMMFRebuildVisSlides();
      if EdSlide <> nil then // If Current Active Frame Slide is Still Visible
        CMMFSelectThumbBySlide( EdSlide ); // Rebuild ThumbsFrame Selection
    end;

// Move before saving to ECach for quick update Histogram and Isodensity
    CMMFDisableActions( nil );
    K_FormCMSIsodensity.InitIsodensityMode();
    CMMFRefreshActiveEdFrameHistogram( );

    EdSlide.CMSlideECSFlags := AChangeCurStateFlags;
    K_CMEDAccess.EDASaveSlideToECache( EdSlide );
    if K_CMEDAccess.SlidesSaveMode = K_cmesImmediately then
      K_CMEDAccess.EDASaveSlidesArray( @EdSlide, 1 );
  end;

//
//  CMMFDisableActions( nil );
//  K_FormCMSIsodensity.InitIsodensityMode();
//  CMMFRefreshActiveEdFrameHistogram( );

end; // procedure TN_CMMain5Form1.CMMFRebuildViewAfterUNDO

//***************************** TN_CMMain5Form1.CMMUpdateUIByDeviceProfiles ***
// Update Capturing User Interface Menu and ToolBar Items
//
procedure TN_CMMain5Form1.CMMUpdateUIByDeviceProfiles();
var
  i : Integer;
  CaptMenuItem : TMenuItem;
begin
//  K_CMUpdateUIByDeviceProfiles0( MainMenu1.Items.Find( 'Capture' ), 3, -1 );
//  K_CMUpdateUIByDeviceProfiles0( CMMCurMainMenu.Items.Find( 'Capture' ), 3, -1 );
//  K_CMUpdateUIByDeviceProfiles0( CMMCurMainMenu.Items[2], 3, -1 );
  if K_CMSMainUIShowMode > 0 then Exit;
  N_Dump2Str( 'CMMUpdateUIByDeviceProfiles start' );

  CaptMenuItem := CMMCurMainMenu.Items[2];
  if not SameText( CaptMenuItem.Name, CMMUpdateUIMenuItemName ) then
  begin
  // seach for Capture Item
    CaptMenuItem := nil;
    for i := 0 to CMMCurMainMenu.Items.Count - 1 do
    begin
      if not SameText( CMMCurMainMenu.Items[i].Name, CMMUpdateUIMenuItemName ) then Continue;
      CaptMenuItem := CMMCurMainMenu.Items[i];
      break;
    end;
  end;
  if CaptMenuItem = nil then
    raise Exception.Create( 'Can''t find Menu Item for Capture Devices' );
  K_CMUpdateUIByDeviceProfiles0( CaptMenuItem, CMMUpdateUIMenuItemInd1, -1 );
//  K_CMUpdateUIByDeviceProfiles0( CaptMenuItem, 3, -1 );
  N_Dump2Str( 'CMMUpdateUIByDeviceProfiles fin' );
end; // procedure TN_CMMain5Form1.CMMUpdateUIByDeviceProfiles();

//***************************** TN_CMMain5Form1.CMMUpdateUIByFilterProfiles ***
// Update User Filters Interface Menu Items
//
procedure TN_CMMain5Form1.CMMUpdateUIByFilterProfiles();
var
  SShortCut : string;
  SHint : string;
  SCapt : string;
  PCMUFilterProfile : TK_PCMUFilterProfile;
  UDProfiles : TK_UDRArray;

  procedure InitAction( ActObj : TAction; ATag : Integer; AIniCapt : string );
  begin
    PCMUFilterProfile := TK_PCMUFilterProfile(UDProfiles.PDE(ATag));
    SShortCut := PCMUFilterProfile.CMUFPShortCut;
    SHint := K_CMGetUIHintByAutoImgProcAttrs( @PCMUFilterProfile.CMUFPAutoImgProcAttrs );
    SCapt := PCMUFilterProfile.CMUFPCaption;
    if SCapt <> '' then
    begin
      if SHint <> '' then
        SHint := SCapt; // If filter is actual Set Hint by user defined Caption
    end
    else
      SCapt := AIniCapt;

    ActObj.Enabled := (SHint <> '');
//    ActObj.Visible := ActObj.Enabled;
    N_Dump2Str( format( '   %s Used=%s', [ActObj.Caption, N_B2S(ActObj.Enabled)] ) );

    ActObj.Caption := SCapt;
    ActObj.ShortCut := 0;
    if SShortCut <> '' then
      ActObj.ShortCut := TextToShortCut(SShortCut);
    ActObj.Hint := SHint;
    ActObj.Tag := ATag;
  end;

begin
  N_Dump2Str( 'CMMUpdateUIByFilterProfiles start' );
  with N_CMResForm do
  begin
    UDProfiles := K_CMEDAccess.UFiltersProfiles;
    InitAction( aToolsFilter1, 0, 'Filter 1' );
    InitAction( aToolsFilter2, 1, 'Filter 2' );
    InitAction( aToolsFilter3, 2, 'Filter 3' );
    InitAction( aToolsFilter4, 3, 'Filter 4' );

    UDProfiles := K_CMEDAccess.GFiltersProfiles;
    InitAction( aToolsFilterA, 0, 'Filter A' );
    InitAction( aToolsFilterB, 1, 'Filter B' );
    InitAction( aToolsFilterC, 2, 'Filter C' );
    InitAction( aToolsFilterD, 3, 'Filter D' );
    InitAction( aToolsFilterE, 4, 'Filter E' );
    InitAction( aToolsFilterF, 5, 'Filter F' );
  end;
  K_CMUpdateUnUsedShortCuts();
  N_Dump2Str( 'CMMUpdateUIByFilterProfiles fin' );
end; // procedure TN_CMMain5Form1.CMMUpdateUIByFilterProfiles();

//**************************************** TN_CMMain5Form1.CMMUpdateUIByCTA ***
// Update User Filters Interface Menu Items
//
procedure TN_CMMain5Form1.CMMUpdateUIByCTA();
var
  SShortCut : string;
  SHint : string;
  SCapt : string;

  procedure InitAction( ActObj : TAction; ATag : Integer; AIniCapt : string );
  var
    SectName : string;
    UseMode : Integer;
  label LExit;
  begin
    SectName := K_CMVobjCTAGetMemIniContext( ATag, UseMode );

    if UseMode = 100 then
    begin
      ActObj.Caption := AIniCapt;
      ActObj.ShortCut := 0;
      ActObj.Hint := '';
      Exit;
    end;

    if (UseMode and 1) = 1 then
      SectName := 'G' + SectName;

    SShortCut := N_MemIniToString( SectName, 'ShortCut', '' );
    SCapt := N_MemIniToString( SectName, 'Caption', '' );
    if SCapt = '' then
      SCapt := AIniCapt;

    SHint := format( '%s (%s)', [SCapt, N_MemIniToString( SectName, 'Text', '' )] );

    if SCapt = AIniCapt then
      SCapt := SHint;

    N_Dump2Str( format( '   %s H=%s SC= U=%s', [ActObj.Name, SHint, SShortCut, SectName] ) );

LExit: //***********
    ActObj.Caption := SCapt;
    ActObj.ShortCut := 0;
    if SShortCut <> '' then
      ActObj.ShortCut := TextToShortCut(SShortCut);
    ActObj.Hint := SHint;
  end;

begin
  N_Dump2Str( 'CMMUpdateUIByCTA start' );
  with N_CMResForm do
  begin
    InitAction( aObjCTA1, 1, 'Text &1' );
    InitAction( aObjCTA2, 2, 'Text &2' );
    InitAction( aObjCTA3, 3, 'Text &3' );
    InitAction( aObjCTA4, 4, 'Text &4' );
  end;
  K_CMUpdateUnUsedShortCuts();
  N_Dump2Str( 'CMMUpdateUIByCTA fin' );
end; // procedure TN_CMMain5Form1.CMMUpdateUIByCTA();

//*************************************** TN_CMMain5Form1.CMMSwitchEdframes ***
// Switch visible Edit Frames
//
//    Parameters
// AFr1 - first Edit Frame to switch
// AFr2 - second Edit Frame to switch
//
function TN_CMMain5Form1.CMMSwitchEdframes( AFr1, AFr2 : TN_CMREdit3Frame;
                                AEDFrLayoutFlags : TK_CMUIEDFrLayoutFlags = [] ) : Boolean;
var
  Ind1, Ind2, Ind : Integer;
  SpOrientation: TN_Orientation;
  SplitterCoef: float;
  SplitterSize: integer;
  Splitter: TSPlitter;
begin

  Result := FALSE;
  Ind1 := K_IndexOfIntegerInRArray( Integer(AFr1), PInteger(@CMMFEdFrames[0]),
                                    CMMFNumVisEdFrames );
  Ind2 := K_IndexOfIntegerInRArray( Integer(AFr2), PInteger(@CMMFEdFrames[0]),
                                    CMMFNumVisEdFrames );
  N_Dump1Str( format( 'CMMSwitchEdframes [%d]=%s <> [%d]=%s',
                      [Ind1, AFr1.Name, Ind2, AFr2.Name] ) );

  if (Ind1 < 0) or (Ind2 < 0) then Exit; // precation in "unreal" case

  Result := TRUE;
  CMMFEdFrames[Ind1] := AFr2;
  CMMFEdFrames[Ind2] := AFr1;

  if (AFr1.Parent = AFr2.Parent) and (CMMFEdFrLayout <> eflNine) then
  begin
  //*** Switch Frames with same Parent
    N_Dump2Str( 'Common Parent Switch' );
    if Ind1 > Ind2 then begin
      Ind := Ind1;
      Ind1 := Ind2;
      Ind2 := Ind;
    end;
    TObject(Splitter) := AFr1.Parent.Controls[0];
    if not (TObject(Splitter) is TSplitter) then begin
      TObject(Splitter) := AFr1.Parent.Controls[1];
      if not (TObject(Splitter) is TSplitter) then
        TObject(Splitter) := AFr1.Parent.Controls[2];
    end;
    if CMMFEdFrLayout = eflTwoHSp then begin
      SpOrientation := orHorizontal;
      SplitterSize := Splitter.Height;
      SplitterCoef := CMMFEdFrames[Ind2].Height / (AFr1.Parent.Height - SplitterSize);
    end else begin
      SpOrientation := orVertical;
      SplitterSize := Splitter.Width;
      SplitterCoef := CMMFEdFrames[Ind2].Width / (AFr1.Parent.Width - SplitterSize);
    end;

    with AFr2 do
      if RFrame <> nil then
      begin
        RFrame.SkipOnResize := TRUE;
        RFrame.SkipOnPaint := TRUE;
      end;

    with AFr1 do
      if RFrame <> nil then
      begin
        RFrame.SkipOnResize := TRUE;
        RFrame.SkipOnPaint := TRUE;
      end;

    N_PlaceTwoSplittedControls( CMMFEdFrames[Ind1], CMMFEdFrames[Ind2], AFr1.Parent,
                                Splitter, SpOrientation, SplitterCoef, SplitterSize );
    with AFr2 do
      if RFrame <> nil then
      begin
        RFrame.SkipOnResize := FALSE;
        RFrame.SkipOnPaint := FALSE;
        if EdSlide <> nil then
          RFrame.SetZoomLevel( rfzmCenter );
      end;

    with AFr1 do
      if RFrame <> nil then
      begin
        RFrame.SkipOnResize := FALSE;
        RFrame.SkipOnPaint := FALSE;
        if EdSlide <> nil then
          RFrame.SetZoomLevel( rfzmCenter );
      end;
  end
  else
  begin
  //*** Switch Frames by Layout
    CMMFSetEdFramesLayout0( CMMFEdFrLayout, nil, -1, AEDFrLayoutFlags );
  end;
end; // procedure TN_CMMain5Form1.CMMSwitchEdframes();

//****************************************** TN_CMMain5Form1.CMMAddMediaToOpened ***
// Add given Slide to Opened for editing
//
//     Parameters
// ASlide - given slide
// AddToOpenedFlags - flags to Frame auto select
// AEdFrame - given Frame to Open
// Result - Returns TRUE if Slide open is finished, FALSE if Nothing to do
//
function TN_CMMain5Form1.CMMAddMediaToOpened( ASlide : TN_UDCMSlide; AddToOpenedFlags : TK_CMSlideAddToOpenedFlags;
                                              AEdFrame : TN_CMREdit3Frame = nil ) : Boolean;
var
  NeededEdFrame: TN_CMREdit3Frame;
  WStr : string;
  ImgSlides: TN_UDCMSArray;
  i : Integer;
  SlideTeethFlags : Int64;
  PlaceSlideFlag : Boolean;
  SlideIsStudy : Boolean;

label LExit, FExit, SkipBWRuleOpen, OpenInNeededFrame;
begin
  N_Dump1Str( 'CMMAddMediaToOpened ID=' + ASlide.ObjName ); // Add 2018-07-23
  SlideIsStudy := TN_UDCMBSlide(ASlide) is TN_UDCMStudy;
  if SlideIsStudy then
    K_CMSlidesLockForOpen( @ASlide, 1, K_cmlrmOpenLock )
  else
    K_CMSlidesLockForOpen( @ASlide, 1, K_cmlrmEditImgLock );


  if K_CMEDAccess.LockResCount = 0 then begin
LExit:
    K_CMEDAccess.LockResCount := 0;
    Result := FALSE;
    Exit;
  end;

  if SlideIsStudy and K_CMStudySingleOpenGUIModeFlag  then
  begin
  // Save Study in Open Context
    CMMStudyLastOpened := TN_UDCMStudy(ASlide);
    N_Dump2Str( 'Add >> Save in Open Context Study ID=' + ASlide.ObjName );
    if CMMStudyPrevLayout = eflNotDef then
      CMMStudyPrevLayout := CMMFEdFrLayout;
  // Change Layout to eflOne
    CMMFSetEdFramesLayout0( eflOne );
    CMMFShowString( '' ); // Clear Images Saving Strings
    AEdFrame := nil;
  end;

  with ASlide, P()^ do
  begin
    if cmsfIsMediaObj in CMSDB.SFlags then
    begin
      N_Dump2Str( 'Open Video' );
      K_CMOpenMediaFile( ASlide );
      K_CMEDAccess.EDAUnlockSlides( @ASlide, 1, K_cmlrmEditImgLock );
      goto FExit;
    end
    else
    if cmsfIsImg3DObj in CMSDB.SFlags then
    begin
      N_Dump2Str( 'Open 3D Image' );
      CMMImg3DOpen( ASlide );
      K_CMEDAccess.EDAUnlockSlides( @ASlide, 1, K_cmlrmEditImgLock );
      goto FExit;
    end;

    if cmsfIsOpened in CMSRFlags then
    begin
    // Skip Edited Slide
      N_Dump2Str( 'Slide is already open ID=' + ObjName );


      (CMMCurFMainForm as TK_FormCMMain5).pgcViewerHolder.Refresh;
      if (CMMCurFMainForm as TK_FormCMMain5).pgcViewerHolder.ActivePageIndex > 0 then
        (CMMCurFMainForm as TK_FormCMMain5).pgcViewerHolder.ActivePageIndex := 0
      else
        K_CMShowMessageDlgByTimer( K_CML1Form.LLLAddToOpened1.Caption,
//             'This object is already open'
               mtInformation );
      goto FExit;
    end;
  end;

  //*** Define NeededEdFrame in which to Open Slide with DGSelectedInd
  SlideTeethFlags := ASlide.P.CMSTeethFlags;
  ///////////////////////////////////////
  //  Check if BW rule is possible

//  if ASkipBWRules                                or  // call from End Drag
  if (AEdFrame <> nil)                           or  // Frame is given
     (AddToOpenedFlags <> [])                    or  // call from End Drag or Skip CurActive Open
     ((SlideTeethFlags and K_CMTeethBWMask) = 0) or  // New slide is not marked as BW
     ((CMMFEdFrLayout <> eflTwoVSp) and (CMMFEdFrLayout <> eflFourHSp)) or
     ( ((SlideTeethFlags and K_CMTeethBWMaskR) <> 0) and
       (CMMFEdFrames[0] <> nil)                      and
       (CMMFEdFrames[0].EdSlide <> nil)              and
       ( (CMMFEdFrames[2] <> nil) and (CMMFEdFrames[2].EdSlide <> nil) or
         (CMMFEdFrLayout = eflTwoVSp) ) )   or  // Needed Left Place is buisy
     ( ((SlideTeethFlags and K_CMTeethBWMaskL) <> 0) and
       (CMMFEdFrames[1] <> nil)                      and
       (CMMFEdFrames[1].EdSlide <> nil)              and
       ( (CMMFEdFrames[3] <> nil) and (CMMFEdFrames[3].EdSlide <> nil)  or
         (CMMFEdFrLayout = eflTwoVSp) ) ) then  // Needed Right Place is buisy
    goto SkipBWRuleOpen;

  ///////////////////////////////////////
  // Reored Slides to Apply BW Rule
  SetLength( ImgSlides, CMMFNumVisEdFrames );
  PlaceSlideFlag := FALSE;
  for i := 0 to CMMFNumVisEdFrames - 1 do
  begin
    ImgSlides[i] := CMMFEdFrames[i].EdSlide;
    if (ImgSlides[i] <> nil) or PlaceSlideFlag then Continue;
    ImgSlides[i] := ASlide;
    PlaceSlideFlag := TRUE;
  end;

  if CMMFEdFrLayout = eflTwoVSp then
    K_CMSSlidesBWReorder2( ImgSlides )
  else
    K_CMSSlidesBWReorder4( ImgSlides );

  // Dump Slides Order
  K_CMEDAccess.TmpStrings.Clear;
  K_CMEDAccess.EDADumpSlidesToTmpStrings( @ImgSlides[0], Length(ImgSlides) );
  N_Dump2Str(format('aMediaAddToOpened BW slides order %s', [K_CMEDAccess.TmpStrings.CommaText]));

  // Reorder Slides and Frames to minimize Slides reopen
  CMMFSetEdFramesLayout0( CMMFEdFrLayout, @ImgSlides[0], Length(ImgSlides) );

  EdFramesPanel.Refresh();

  // Get Open Slide Resulting position
  i := K_IndexOfIntegerInRArray( Integer(ASlide),
                                       PInteger(@ImgSlides[0]), CMMFNumVisEdFrames );
  NeededEdFrame := CMMFEdFrames[i];
  goto OpenInNeededFrame;
  // end of Reored Slides to Apply BW Rule
  ///////////////////////////////////////

SkipBWRuleOpen:
  NeededEdFrame := nil;
  if CMMFActiveEdFrame <> nil then // Active EdFrame exists
  begin
    if CMMFActiveEdFrame.EdSlide = nil then // Active EdFrame is free, use it
      NeededEdFrame := CMMFActiveEdFrame;
  end;

  if AEdFrame <> nil then
    NeededEdFrame := AEdFrame;

  if NeededEdFrame = nil then // no Active EdFrame or it is not free
  begin
    NeededEdFrame := CMMFFindEdFrame( nil ); // try to find free EdFrame

    if NeededEdFrame = nil then
    begin
     // free EdFrame not found, try to use CMMFActiveEdFrame
      if (CMMFNumVisEdFrames > 1)    and
         (uieflSkipActiveEdFrame in AddToOpenedFlags) then
      begin
      // Select Next After Current Active
        i := K_IndexOfIntegerInRArray( Integer(CMMFActiveEdFrame),
                                       PInteger(@CMMFEdFrames[0]), CMMFNumVisEdFrames ) + 1;
        if i = CMMFNumVisEdFrames then i := 0;
        NeededEdFrame := CMMFEdFrames[i]
      end
      else
        NeededEdFrame := CMMFActiveEdFrame;
    end;

    if NeededEdFrame = nil then // no Active EdFrame, use CMMFEdFrames[0]
    begin
      if CMMFNumVisEdFrames = 0 then // assert that CMMFEdFrames[0] exists
        CMMFSetEdFramesLayout0( eflOne );
//          CMMFSetEdFramesLayout( eflOne );

      NeededEdFrame := CMMFEdFrames[0];
    end; // if NeededEdFrame = nil then // no Active EdFrame, use CMMFEdFrames[0]

  end; //  if NeededEdFrame = nil then // no Active EdFrame or it is not free

  //*** NeededEdFrame is OK. Make it Active and open Slide in it

  if (NeededEdFrame.EdSlide <> nil) and
     (K_CMEDAccess.SlidesSaveMode = K_cmesFinEdit) then
    K_CMEDAccess.EDASaveSlidesArray( @NeededEdFrame.EdSlide, 1 );

OpenInNeededFrame:
  if not SlideIsStudy  then
  begin

    if NeededEdFrame.EdSlide <> nil then
      NeededEdFrame.EdFreeObjects(); // Clear Closing Slide Resources for proper Memory Check

    CMMFShowHideWaitState( TRUE );

    K_CMSResampleSlides( @ASlide, 1, CMMFShowString );

    if not K_CMSCheckMemForSlide1( ASlide ) then
    begin
    // Image was not Loaded by memory lack - unlock it
      K_CMEDAccess.EDAUnlockSlides( @ASlide, 1, K_cmlrmEditImgLock );
      N_Dump2Str('CMMAddMediaToOpened Out Of Memory ID=' + ASlide.ObjName );
      K_CMShowSoftMessageDlg( K_CML1Form.LLLMemory4.Caption,
//      'There is not enough memory to open this Media object.'
//      'Please close the open image(s) or restart Media Suite.'
                             mtWarning, 10 );
      K_CMOutOfMemoryFlag := TRUE;
      CMMFShowHideWaitState( FALSE );
      goto LExit;
    end;
  end;


  if not NeededEdFrame.SetNewSlide( ASlide ) then
  begin
    if not SlideIsStudy  then
      CMMFShowHideWaitState( FALSE );
    N_Dump2Str('CMMAddMediaToOpened File Load Err ID=' + ASlide.ObjName );
    K_CMEDAccess.EDAUnlockSlides( @ASlide, 1, K_cmlrmEditImgLock );
    goto LExit;
  end;

  if not SlideIsStudy  then
    CMMFShowHideWaitState( FALSE );

  CMMFSetActiveEdFrame( NeededEdFrame );

  if not SlideIsStudy                  and
     (CMMStudyPrevLayout <> eflNotDef) and
     (CMMFGetSlideLinkedToStudy() = nil) then
  begin
  // Clear Prev Study in Open Context if all Open Slides are not linked to any study
    CMMStudyPrevLayout := eflNotDef;
    CMMStudyLastOpened := nil;
    N_Dump2Str( 'Add >> Clear Prev Study in Open Context by New Slides' );
  end;

  WStr := '';
  if K_CMMarkAsDelShowFlag then
    WStr := K_CML1Form.LLLAddToOpened2.Caption
//          ' Media object opened in this mode couldn''t be changed.'
  else
  if (cmsfIsUsed in ASlide.P.CMSRFlags) and not SlideIsStudy then
  begin
    with ASlide do
    if CMSUndoBuf <> nil  then
        CMSUndoBuf.UBMinInd := CMSUndoBuf.UBCurInd;

    if cmsdbfMarkedAsDel in ASlide.CMSDBStateFlags then
      WStr := K_CML1Form.LLLAddToOpened3.Caption
//          ' Media object is marked as deleted. It couldn''t be changed.'#13#10 +
//          ' Please restore it''s state first if you wish to change it.'
    else
    if ASlide.CMSlideEdState <> K_edsSkipChanges then
      WStr := K_CML1Form.LLLAddToOpened4.Caption
//          ' Media object is opened by other user(s).'#13#10 +
//          ' Any changes made to it will not be saved.'
    else
      WStr := K_CML1Form.LLLAddToOpened5.Caption;
//          ' Media object is from another location. '#13#10 +
//          ' Any changes made to it will not be saved.'#13#10 +
//          ' Please duplicate the object first '#13#10 +
//          ' if you wish to save the changes.';
  end;
  if WStr <> '' then
//  K_CMShowMessageDlg( WStr, mtInformation );
    K_CMShowSoftMessageDlg( WStr, mtInformation, 10 );

FExit:
  Result := TRUE;
  K_CMEDAccess.LockResCount := 0;
end; // procedure TN_CMMain5Form1.CMMAddMediaToOpened

procedure TN_CMMain5Form1.CMMImg3DFolderAbsentDlg( const A3DFolderName : string );
var
  ErrFolderName : string;
begin
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    ErrFolderName := Copy( A3DFolderName, Length(SlidesImg3DRootFolder) + 1, Length(A3DFolderName) );

    K_CMShowMessageDlg(  format(
          K_CML1Form.LLLCheckImg3DFolder1.Caption,
//          'The 3D object folder "%s" is missing'#13#10 +
//          'in the folder "%s"'#13#10 +
//          'Please check your folder name and try again.',
                 [ErrFolderName, SlidesImg3DRootFolder] ), mtError );
  end;
end; // TN_CMMain5Form1.CMMImg3DFolderAbsentDlg

//******************************************** TN_CMMain5Form1.CMMImg3DOpen ***
// Open 3D Image object
//
//     Parameters
// ASlide - given slide
//
procedure TN_CMMain5Form1.CMMImg3DOpen( ASlide : TN_UDCMSlide );
var
  ResCode, CurSlidesNum : Integer;
  Img3DFolder : string;
//  ErrFolderName : string;
  CMCDServObj : TK_CMCDServObj;

  procedure ShowCMSuiteUI();
  begin
    if CMMCurFMainForm <> nil then
    begin
      CMMCurFMainFormSkipOnShow := TRUE;
      CMMCurFMainForm.Show();
      CMMCurFMainForm.Refresh();
      N_CM_MainForm.CMMSetUIEnabled( TRUE );
    end;
  end; // procedure ShowCMSuiteUI

begin
  N_Dump1Str( 'TN_CMMain5Form1> CMMImg3DOpen start' );
  if  not (cmsfIsLocked in ASlide.P.CMSRFlags) then
  begin
    N_Dump2Str( 'Slide is already open ID=' + ASlide.ObjName );
    K_CMShowMessageDlgByTimer( K_CML1Form.LLLImg3D4.Caption,
//             'This object is already opened by other user'
           mtInformation );
    Exit;
  end;

  if CMMCurFMainForm <> nil then
  begin
    CMMSetUIEnabled( FALSE );
    CMMCurFMainForm.Hide();
  end;

  with ASlide, P^ do
  if CMSDB.Capt3DDevObjName = '' then
  begin // self Img3D viewer
    N_Dump2Str( 'Open Img3D by Self 3DViewer slide ID=' + ObjName );
    Img3DFolder := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( ASlide ) +
                                          K_CMSlideGetImg3DFolderName( ObjName );

    if DirectoryExists(Img3DFolder) then
      ResCode := K_CMImg3DCall( Img3DFolder )
    else
    begin
      ResCode := -1;
      CMMImg3DFolderAbsentDlg( Img3DFolder );
{
      with TK_CMEDDBAccess(K_CMEDAccess) do
      begin
        ErrFolderName := Copy( Img3DFolder, Length(SlidesImg3DRootFolder) + 1, Length(Img3DFolder) );

        K_CMShowMessageDlg(  format(
              K_CML1Form.LLLCheckImg3DFolder1.Caption,
    //          'The 3D object folder "%s" is missing'#13#10 +
    //          'in the folder "%s"'#13#10 +
    //          'Please check your folder name and try again.',
                     [ErrFolderName, SlidesImg3DRootFolder] ), mtError );
      end;
}
    end;

    if K_CMD4WAppFinState then
    begin
      N_Dump1Str( '3D> !!! CMSuite is terminated' );
      Application.Terminate;
      Exit;
    end;

    ShowCMSuiteUI();
{
    if CMMCurFMainForm <> nil then
    begin
      CMMCurFMainFormSkipOnShow := TRUE;
      CMMCurFMainForm.Show();
      CMMCurFMainForm.Refresh();
      N_CM_MainForm.CMMSetUIEnabled( TRUE );
    end;
}
    if ResCode = 0 then
    begin
      // Import 2D views
      CurSlidesNum := CMMImg3DViewsImportAndShowProgress( ObjName, Img3DFolder );
      if CurSlidesNum > 0 then
      begin
        N_CM_MainForm.CMMFRebuildVisSlides();
        N_CM_MainForm.CMMFDisableActions( nil );

        N_CM_MainForm.CMMFShowStringByTimer( format( K_CML1Form.LLLImg3D3.Caption,
  //                ' %d 3D views are imported'
                  [CurSlidesNum] ) );
      end; // if CurSlidesNum > 0 then
    end; // if ResCode = 0 then
  end   // if ASlide.P^.CMSDB.Capt3DDevObjName = '' then  // self Img3D viewer
  else
  begin // if ASlide.P^.CMSDB.Capt3DDevObjName <> '' then // Dev3D viewer
    N_Dump2Str( 'Open Img3D by Device 3DViewer slide ID=' + ObjName );
    CMCDServObj := K_CMCDGetDeviceObjByName( CMSDB.Capt3DDevObjName );
    if CMCDServObj = nil then
      N_CM_MainForm.CMMFShowStringByTimer( 'Device object is not found' )
    else
    begin
      N_Dump2Str( '3D> OpenDev3DViewer before' );
      Img3DFolder := CMSDB.MediaFExt;
      if Img3DFolder = '' then
        Img3DFolder := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( ASlide ) +
                                          K_CMSlideGetImg3DFolderName( ObjName );
//      CMCDServObj.CDSOpenDev3DViewer( CMSDB.MediaFExt );
      N_Dump2Str( format( '3D> OpenDev3DViewer for ObjID=%s Serv=%s Path=%s', [ObjName, CMCDServObj.CDSName,Img3DFolder] ) );
      CMCDServObj.CDSOpenDev3DViewer( Img3DFolder );
      N_Dump2Str( '3D> OpenDev3DViewer after' );
      ShowCMSuiteUI();
    end;
  end;  // if ASlide.P^.CMSDB.Capt3DDevObjName <> '' then // Dev3D viewer
  N_Dump2Str( 'TN_CMMain5Form1> CMMImg3DOpen fin' );

end; // procedure TN_CMMain5Form1.CMMImg3DOpen

//************************** TN_CMMain5Form1.CMMShowCloseApplicationWarning ***
// Show Close Application Warning if needed
//
procedure TN_CMMain5Form1.CMMShowCloseApplicationWarning();
//var
//  Mes : string;
begin
  if (K_FormCMSFPathChange <> nil) then Exit;
  // Show Warning
  K_CMShowMessageDlgByTimer(  K_CML1Form.LLLCloseCMS.Caption,
//    'Close application for technical support please!',
                                  mtWarning );

{
  if (K_FormCMSFPathChange <> nil) or
     (CMMShowCloseApplicationDlgForm <> nil) then Exit;
  // Show Warning
  Mes := 'Close application for technical support please!';
  CMMShowCloseApplicationDlgForm := CreateMessageDialog( Mes, mtWarning, [mbOK] );
//  N_MakeFormVisible( CMMShowCloseApplicationDlgForm, [fvfCenter] );
  N_MakeFormVisible2( CMMShowCloseApplicationDlgForm, [rspfMFRect,rspfCenter]);

  with CMMShowCloseApplicationDlgForm do
  begin
    Caption := 'Media Suite SQL';
    FormStyle := fsStayOnTop;
  end;
  CMMFShowStringByTimer( Mes );
}
end; // end of procedure TN_CMMain5Form1.CMMShowCloseApplicationWarning

//************************************ TN_CMMain5Form1.CMMCallActionByTimer ***
// Call Action by Timer
//
//   Parameters
// AAction - Action to add to start by timer list
// AStartTimer - real start timer flag, if =TRUE then timer will be start, else
//               given Action will only be added to to start by timer list
// Result - Returns TRUE if ActTimer was activated
//
function TN_CMMain5Form1.CMMCallActionByTimer( AAction : TAction; AStartTimer: Boolean;
                                               ATimerInterval : Integer = 0 ) : Boolean;
var
  QCount : Integer;
begin
  Result := FALSE;

  if AAction <> nil then
  begin
    if CMMServActions = nil then
      CMMServActions := TList.Create;
    if CMMServActionsExec and AStartTimer and (ATimerInterval <> 0) then
    begin
      if CMMServActionsNext = nil then
        CMMServActionsNext := TList.Create;
      CMMServActionsNext.Add( AAction );
      CMMServActionsNextTS := Now() + ATimerInterval / (24 * 60 * 60 * 1000);
      N_Dump1Str( 'Add to next timer query action=' + AAction.Caption);
    end
    else
    begin
      CMMServActions.Add( AAction );
      N_Dump1Str( 'Add to timer query action=' + AAction.Caption);
    end;
  end
  else
    AStartTimer := (CMMServActions <> nil) and (CMMServActions.Count > 0); // Start Timer

  QCount := 0;
  if CMMServActions <> nil then QCount := CMMServActions.Count;
  N_Dump2Str( format( 'ActTimer QueryCount=%d QueryExec=%s StartFlag=%s Started=%s',
                      [QCount,
                       N_B2S(CMMServActionsExec),
                       N_B2S(AStartTimer),
                       N_B2S(ActTimer.Enabled)] ) );
  if CMMServActionsExec or // Service actions list is executed now
     not AStartTimer    or // No need to start timer
     ActTimer.Enabled then // Timer is already started
    Exit;

  Result := TRUE;

  if ATimerInterval <> 0 then
    ActTimer.Interval := ATimerInterval;

  ActTimer.Enabled := True; // Start Timer
  N_Dump1Str( 'Start ActTimer' );

end; // end of procedure TN_CMMain5Form1.CMMCallActionByTimer

//*************************************** TN_CMMain5Form1.CurArchiveChanged ***
// Update all needed Self fields after current Archive was changed
//
procedure TN_CMMain5Form1.CurArchiveChanged();
begin
//  Caption := 'Centaur Media Suite';
//  if N_CMSAppType = cmsatOnePatChild then
//    Caption := Caption + ' (child)';

//    CMMFRebuildVisSlides(); // not needed, was already called from K_CMSetCurDataContext
end; // end of procedure TN_CMMain5Form1.CurArchiveChanged

//******************************************* TN_CMMain5Form1.OnUHException ***
// On Application Unhadled Exception Handler
//
procedure TN_CMMain5Form1.OnUHException( Sender: TObject; E: Exception );
var
  ErrStr : string;
  hTaskBar: THandle;
begin
  try
    // To prevent Unhandled Exception Handler recursive call
    if CMMUHExceptionInProcess then
    begin
      TerminateProcess( GetCurrentProcess(), 20 );
      Exit;
    end;
    CMMUHExceptionInProcess := TRUE;

    // Show TaskBar if Exception raised while TaskBar  is hide
    hTaskbar := FindWindow( 'Shell_TrayWnd', nil );
    if hTaskbar <> 0 then
    begin
      EnableWindow( HTaskBar, TRUE );        // Enabled TaskBar
      ShowWindow( hTaskBar, SW_SHOWNORMAL ); // Show TaskBar
    end;

    ErrStr := ' Application terminated by exception:'#13#10 + E.Message;
    N_Dump1Str( ErrStr );
    N_Dump1Str( ' Windows Last error:'#13#10 + SysErrorMessage( GetLastError() ) );

    if K_CMEDAccess <> nil then
      K_CMRemoveOldDump2ExceptFiles();

    N_CMSCreateDumpFiles( $001 );
    N_LCExecAction( -1, lcaFlush );

    // stop timer before Exception Dialog show
    if (K_CMEDAccess <> nil) and (K_CMEDAccess.ATimer <> nil) then K_CMEDAccess.ATimer.Enabled := FALSE;

    N_Dump1Str( 'TN_CMMain5Form1.OnUHException >> before Dlg' );
    K_CMD4WAppFinState := TRUE;
    K_CMShowMessageDlg(  K_CML1Form.LLLSysErrMes.Caption,
{
  'The software has encountered a system error.'#13#10 +
  'Please try to restart the software. In case the software'#13#10 +
  'does not start, reboot your computer and try to start it.'#13#10 +
  'In case you have this error again please call the support.'#13#10 +
  '             Click OK to close the software.',
}
                        mtError, [], TRUE );
{
    with K_CMPrepMessageDlg( K_CML1Form.LLLSysErrMes.Caption, mtError, [] ) do
    begin
      BorderIcons := [];
      ShowModal;
    end;
}
    N_Dump1Str( 'TN_CMMain5Form1.OnUHException >> after Dlg' );

    if 0 = Pos( '[Sybase]', ErrStr ) then
      K_CMEDAccess.Free
    else
      N_Dump1Str( 'DB Error >> Skip K_CMEDAccess destroy'  );
    N_Dump1Str( 'CMSuite Exception fin processing'  );
    N_Dump1Str( 'Application CMSuite.UHException FlushCounters' + N_GetFlushCountersStr() );
    N_LCExecAction( -1, lcaFlush );
  finally
//    Application.Terminate();
    TerminateProcess( GetCurrentProcess(), 10 );
  end;
end; // end of procedure TN_CMMain5Form1.OnUHException

//********************************** TN_CMMain5Form1.OnThumbsFrameMouseDown ***
// On Appliction Unhadled Exception Handler
//
procedure TN_CMMain5Form1.OnThumbsFrameMouseDown( Sender: TObject; Button: TMouseButton;
                                       Shift: TShiftState; X, Y: Integer );
//var
//  i : Integer;
begin
//##!! Drag Code to Close

  if uicsAllActsDisabled in CMMUICurStateFlags then
  begin
    DragThumbsTimer.Enabled := FALSE;
    Exit;
  end;

  if (ssLeft in Shift) and
     not CMMThumbsFrameDblClickFlag then
//     (CMMCurFThumbsDGrid.DGMarkedList.Count > 0) then
  begin
    DragThumbsTimer.Enabled := TRUE;
    CMMCurBeginDragControl := CMMCurFThumbsRFrame;
//    CMMCurFThumbsRFrame.BeginDrag( false, 1 );
  end
  else
    DragThumbsTimer.Enabled := FALSE;

{
  if (ssLeft in Shift) and
     not CMMThumbsFrameDblClickFlag then
    with CMMCurFThumbsDGrid do
      for i := 0 to DGMarkedList.Count - 1 do
      begin
        with TN_UDCMSlide(K_CMCurVisSlidesArray[Integer(DGMarkedList[i])]).P^, CMSDB do
          if (cmsfIsMediaObj in SFlags) or (cmsfIsOpened in CMSRFlags) then Continue;
        CMMCurFThumbsRFrame.BeginDrag( false, 0 );
        break;
      end;
}
  CMMThumbsFrameDblClickFlag := FALSE;

  with CMMFActiveEdFrame do
    if IfSlideIsStudy then
    begin
      N_DumpStr( K_CMStudyDetailsDumpCInd, 'Active Study Clear Selection by Thumbs DblClick'  );
      TN_UDCMStudy(EdSlide).UnSelectAll();
      RFrame.RedrawAllAndShow();
    end;

end; // end of procedure TN_CMMain5Form1.OnThumbsFrameMouseDown

//*************************************** TN_CMMain5Form1.CMMSetWindowState ***
// Set Self Window State
//
//     Parameters
// AWinState - Window New State Code
//#F
//     -1 - hide,
//      0 - normal,
//      1 - minimized,
//      2 - maximized,
//#/F
//
procedure TN_CMMain5Form1.CMMSetWindowState( AHandle : HWND; AWinState : Integer );
var
  CurShowCommand : Integer;
  ShowMaxOrNormCommand : Boolean;

const
  ShowCommands: array[0..3] of Integer =
    (SW_HIDE, SW_SHOWNORMAL, SW_SHOWMINIMIZED, SW_SHOWMAXIMIZED);

begin
  CurShowCommand := ShowCommands[AWinState + 1];
  ShowMaxOrNormCommand := (CurShowCommand = SW_SHOWNORMAL) or
                          (CurShowCommand = SW_SHOWMAXIMIZED);
  N_Dump2Str( '5F.SetWindowState to '+IntToStr(CurShowCommand) );
  if IsIconic(Application.Handle) and ShowMaxOrNormCommand then
    ShowWindow( Application.Handle, SW_SHOWNORMAL );
  if IsZoomed(AHandle) and ShowMaxOrNormCommand then
    CurShowCommand := SW_SHOWMAXIMIZED; // Skip Norm COmmand if already Maximized
  ShowWindow( AHandle, CurShowCommand );
end; // end of procedure TN_CMMain5Form1.CMMSetWindowState

//*************************************** TN_CMMain5Form1.CMMSetWindowState ***
// Set Self Window State
//
//     Parameters
// AWinState - Window New State Code
//#F
//     -1 - hide,
//      0 - normal,
//      1 - minimized,
//      2 - maximized,
//#/F
//
procedure TN_CMMain5Form1.CMMSetWindowState( AWinState : Integer );
begin
  CMMSetWindowState( CMMCurFMainForm.Handle, AWinState );
end; // end of procedure TN_CMMain5Form1.CMMSetWindowState

//**************************************** TN_CMMain5Form1.CurStateToMemIni ***
// Save Current Self State
//
procedure TN_CMMain5Form1.CurStateToMemIni();
begin
  Inherited;

{
  K_SetArchiveCursor();
  MFFrame.CurStateToMemIni();

  if cmpfSaveFalgs in N_CM_LogFlags then
    N_SPLValToMemIni( 'CMS_Main', 'CMLogFlags',  N_CM_LogFlags, N_SPLTC_CMLogFlags );
}
end; // end of procedure TN_CMMain5Form1.CurStateToMemIni

//**************************************** TN_CMMain5Form1.MemIniToCurState ***
// Load Current Self State
//
procedure TN_CMMain5Form1.MemIniToCurState();
begin
  Inherited;
//  N_MakeFormVisible( Self, [fvfCenter] );

//  N_CM_IDEMode := N_MemIniToInt( 'CMS_Main', 'IDEMode', 0 );
{
  if N_CM_IDEMode = 0 then // prepare Release Version
  begin
    N_CMResForm.aDebCreateDistr.Visible := False;
    N_CMResForm.aDebAction1.Visible := False;
    N_CMResForm.aDebAction2.Visible := False;
    Debug1.Visible := False;
    Debug2.Visible := False;
//      N_CMResForm.aDebMainTmpForm.Visible := False;
  end;  // if N_CM_IDEMode = 0 then // prepare Release Version
}

    // N_CM_IDEMode :
    // = 0 Release Version
    // = 1 Full Design Mode
    // = 2 Patial Design Mode
//###!!!???    Debug1.Visible := (N_CM_IDEMode = 1);
//###!!!???    Debug2.Visible := (N_CM_IDEMode = 1) or (N_CM_IDEMode = 2);

end; // end of procedure TN_CMMain5Form1.MemIniToCurState

//*************************************** TN_CMMain5Form1.CMMFrameWMKeyDown ***
// User OnKeyDown Windows event handler for EdFrame.RFrame.WMKeyDown
//
//    Parameters
// AWMKey - record with KeyDown event info
//
procedure TN_CMMain5Form1.CMMFrameWMKeyDown( var AWMKey: TWMKey );
var
  NInd, Ind, Row, Col, NCols : Integer;
const
//        eflTwoHSp, eflTwoVSp, eflFourHSp, eflFourVSp, eflNine
  EdFLRows : array [Ord(eflTwoHSp)..Ord(eflNine)] of Integer = (2, 1, 2, 2, 3);
  EdFLCols : array [Ord(eflTwoHSp)..Ord(eflNine)] of Integer = (1, 2, 2, 2, 3);
begin
{
  if (AWMKey.CharCode = VK_ESCAPE) or
     ( ((Windows.GetKeyState(VK_MENU) and $8000) <> 0) and
       (AWMKey.CharCode = $50) ) then begin
// VK_A thru VK_Z are the same as ASCII 'A' thru 'Z' ($41 - $5A) VK_P = $50
}
  if AWMKey.CharCode = VK_ESCAPE then begin
    if (CMMEdVEMode = cmrfemZoom) or (CMMEdVEMode = cmrfemPan) then
      N_CMResForm.aEditPointExecute(Self);
    Exit;
  end;
  if Ord(CMMFEdFrLayout) <= Ord(eflOne) then Exit;
  Ind := K_IndexOfIntegerInRArray( Integer(CMMFActiveEdFrame),
                                   PInteger(@CMMFEdFrames[0]), CMMFNumVisEdFrames );
  NCols := EdFLCols[Ord(CMMFEdFrLayout)];
  Row := Ind div NCols;
  Col := Ind - Row * NCols;
  NInd := Ind;
  case AWMKey.CharCode of
  $25 : if Col > 0 then Dec(NInd);                                        // Left
  $26 : if Row > 0 then Dec(NInd, NCols);                                 // Up
  $27 : if Col < NCols - 1 then Inc(NInd);                                // Rigth
  $28 : if Row < EdFLRows[Ord(CMMFEdFrLayout)] - 1 then Inc(NInd, NCols); // Down
  end;

  if NInd <> Ind then
    CMMFSetActiveEdFrame( CMMFEdFrames[NInd] );
end; // end of procedure TN_CMMain5Form1.CMMFrameWMKeyDown

//**************************************** TN_CMMain5Form1.CMMSetFramesMode ***
// Set All Frames Mode
//
procedure TN_CMMain5Form1.CMMSetFramesMode( AEdVEMode: TN_CMRFRVEMode;
                                            AEdFrame : TN_CMREdit3Frame = nil );
var
  i : Integer;
  EdFrame : TN_CMREdit3Frame;
  EdFrameCurSLidePopupMenu : TPopupMenu;
  FrameWithStudy : Boolean;

  procedure ActiveFramePrep(  );
  begin
    if (CMMFActiveEdFrame = EdFrame) and
       EdFrame.ChangeSelectedVObj( 0 ) then
      EdFrame.RFrame.RedrawAllAndShow();
  end;

begin
//
  CMMEdVEMode := AEdVEMode;
  for i := 0 to CMMFNumVisEdFrames - 1 do
  begin
    EdFrame := CMMFEdFrames[i];
    if (EdFrame = nil) or
       ((AEdFrame <> nil) and (EdFrame <> AEdFrame))  then Continue;
    with EdFrame, RFrame do
    begin
      FrameWithStudy := IfSlideIsStudy;
//      EdFrameCurSLidePopupMenu := N_CMResForm.EdFrPointPopupMenu;
      EdFrameCurSLidePopupMenu := CMMEdFramePopUpMenu;
      if FrameWithStudy then
      begin
        N_CMResForm.EdFrameStudyPopupMenu.OnPopup := aEdFrameStudyOnPopup;
        EdFrameCurSLidePopupMenu := N_CMResForm.EdFrameStudyPopupMenu;
      end;

      if AEdVEMode = cmrfemFlashLight then
      begin
//        EdFrame.PopupMenu := N_CMResForm.EdFrPointPopupMenu;
        EdFrame.PopupMenu := EdFrameCurSLidePopupMenu;
        N_SetMouseCursorType( RFrame, crDefault );
        RFrActionFlags := RFrActionFlags - [rfafZoomByClick, rfafZoomByPMKeys,rfafScrollCoords];
        EdViewEditMode := cmrfemFlashLight;
        EdFlashLightModeRFA.ActEnabled := not FrameWithStudy;
        Continue;
      end;
      EdViewEditMode := cmrfemNone;
      if EdSlide = nil then
      begin
        EdFrame.PopupMenu := nil;
        Continue;
      end;

      if AEdVEMode = cmrfemZoom then
      begin
        EdFrame.PopupMenu := nil;
        N_SetMouseCursorType( RFrame, crZoomCursor );

        RFrActionFlags := RFrActionFlags + [rfafZoomByClick, rfafZoomByPMKeys];
        RFrActionFlags := RFrActionFlags - [rfafScrollCoords];
        EdViewEditMode := cmrfemZoom;
        ActiveFramePrep( );
      end else if AEdVEMode = cmrfemPan  then
      begin
//        EdFrame.PopupMenu := N_CMResForm.EdFrPointPopupMenu;
        EdFrame.PopupMenu := EdFrameCurSLidePopupMenu;
        N_SetMouseCursorType( RFrame, crSizeAll );
        RFrActionFlags := RFrActionFlags + [rfafScrollCoords];
        RFrActionFlags := RFrActionFlags - [rfafZoomByClick, rfafZoomByPMKeys];
        EdViewEditMode := cmrfemPan;
        ActiveFramePrep( );
      end else if AEdVEMode = cmrfemPoint then
      begin
//        EdFrame.PopupMenu := nil;
//        EdFrame.PopupMenu := N_CMResForm.EdFrPointPopupMenu;
        EdFrame.PopupMenu := EdFrameCurSLidePopupMenu;
        N_SetMouseCursorType( RFrame, crDefault );
        RFrActionFlags := RFrActionFlags - [rfafZoomByClick,rfafZoomByPMKeys,rfafScrollCoords];
        EdViewEditMode := cmrfemPoint;
        EdMoveVObjRFA.ActEnabled := not FrameWithStudy;
      end else if AEdVEMode = cmrfemCropImage then
      begin
        EdFrame.PopupMenu := nil;
        N_SetMouseCursorType( RFrame, crDefault );
        RFrActionFlags := RFrActionFlags - [rfafZoomByClick,rfafZoomByPMKeys,rfafScrollCoords];
        EdViewEditMode := cmrfemCropImage;
        ActiveFramePrep( );
        with EdRubberRectRFA do
        begin
//          RRCurUserRect := N_RectScaleR( GetVisibleURect(), 0.9, DPoint(0.5,0.5) );
          RRConP2UComp := EdSlide.GetMapRoot;
          RRCurUserRect := N_RectScaleR( RRConP2UComp.PSP.CCoords.CompUCoords, 0.9, DPoint(0.5,0.5) );
          ActEnabled := True;
          RedrawAllAndShow();
          ShowStringByTimer( 'Press Enter(OK), Escape(Cancel) or DoubleClick to Finish' );
        end; // with RubberRectRFA do
      end; // if AEdVEMode = cmrfemCropImage
    end; // with EdFrame, RFrame do
  end; // for i := 0 to CMMFNumVisEdFrames - 1 do
end; // end of procedure TN_CMMain5Form1.CMMSetFramesMode

//******************************* TN_CMMain5Form1.CMMRebuildSlidesToOperate ***
// Rebuilds Array of Slides to operate on
//
//    Parameters
// Result - Returns number of Slide in rebuilt Array
//
function TN_CMMain5Form1.CMMRebuildSlidesToOperate(): Integer;
var
  UseActiveFrame : Boolean;
  WStr : string;
  i : Integer;
begin
//  if CMMFActiveEdFrame.RFrame.Focused and (CMMFActiveEdFrame.EdSlide <> nil) then begin
  with CMMCurFThumbsDGrid do
  begin
  // Slides From Thumbnails Frame
    Result := DGMarkedList.Count;
    if Result <> 0 then
    begin
      CMMAllSlidesToOperate := K_CMSBuildSlidesArrayByList( K_CMCurVisSlidesArray, DGMarkedList );
      Result := Length(CMMAllSlidesToOperate);
    end;
  end; // with CMMCurFThumbsDGrid do

  if (CMMFActiveEdFrame <> nil) then
  begin
    UseActiveFrame := (CMMFActiveEdFrame.EdWillBeFocused or
                      not CMMCurFThumbsRFrame.Focused);
    if UseActiveFrame then
    begin
      if (CMMFActiveEdFrame.IfSlideIsStudy()) and
         (TN_UDCMStudy(CMMFActiveEdFrame.EdSlide).GetFileTypeCounts() > 0) then
      begin
      // Add Selected Slides from Active Frame Study
        Result := TN_UDCMStudy(CMMFActiveEdFrame.EdSlide).GetSelectedSlidesToArray( CMMAllSlidesToOperate );
        SetLength( CMMAllSlidesToOperate, Result );
        CMMFActiveEdFrame.EdWillBeFocused := FALSE;
      end
      else
      if (Result = 0)   and
         CMMFActiveEdFrame.IfSlideIsImage() then
      begin
      // Slide From Active Frame in StudioArea
        CMMFActiveEdFrame.EdWillBeFocused := FALSE;
        SetLength( CMMAllSlidesToOperate, 1 );
        CMMAllSlidesToOperate[0] := CMMFActiveEdFrame.EdSlide;
        Result := 1;
      end;
    end;
  end
  else // If ActivFrame is not Selected and ThumbsFrame Selection is Empry
    SetLength( CMMAllSlidesToOperate, Result );

  if Result = 0 then Exit;

// Prepare Slides to operate Dump
  WStr := '';
  for i := 0 to Result - 1 do
    WStr := WStr + ' ' + CMMAllSlidesToOperate[i].ObjName;
  N_Dump2Str( 'AllSlidesToOperate >>' + WStr );
end; // end of procedure TN_CMMain5Form1.CMMRebuildSlidesToOperate

//************************************ TN_CMMain5Form1.CMMCropCancelProcObj ***
// Crop Active Frame Current Image cancel
// (used as TN_RubberRectRFA.RROnOKProcObj)
//
procedure TN_CMMain5Form1.CMMCropCancelProcObj( ARFAction: TObject );
var
  EdFrame: TN_CMREdit3Frame;
begin
  if (CMMFActiveEdFrame = nil) and (ARFAction = nil) then Exit; // precaution
  EdFrame := CMMFActiveEdFrame;
  if EdFrame = nil then
    EdFrame := TN_CMREdit3Frame(TN_RFrameAction(ARFAction).ActGroup.RFrame.Parent);
  with EdFrame do begin
    if not EdRubberRectRFA.ActEnabled then Exit;
    EdRubberRectRFA.ActEnabled := False;
    RFrame.RedrawAllAndShow();
    N_Dump1Str( Name +':Crop Image canceled' );
  end; //

  with N_CMResForm do begin
    aEditPointExecute( nil );
  end;
  CMMFCancelImageEditing();

end; // procedure TN_CMMain5Form1.CMMCropCancelProcObj

//**************************** TN_CMMain5Form1.CMMCropBySelectedRectProcObj ***
// Crop Active Frame Current Image content by Rectangle Selected in EdRubberRectRFA
// (used as TN_RubberRectRFA.RROnOKProcObj)
//
procedure TN_CMMain5Form1.CMMCropBySelectedRectProcObj( ARFAction: TObject );
var
  NDIB : TN_DIBObj;
  AffCoefs6 : TN_AffCoefs6;
  ImgViewConvData : TK_CMSImgViewConvData;
  SelRect: TRect;
  NewSlide : TN_UDCMSlide;
  PCMSlide : TN_PCMSlide;
  NewSize:   TFPoint;
  HistCode : Integer;
  RebuildMapRoot : Boolean;
  WSFlags: TN_CMSlideSFlags; // Slide State Saved Flags
//  CCoords   : TN_CompCoords;// Component Coordinates and Position
  SavedCursor : TCursor;
label LExit;
begin
  with CMMFActiveEdFrame do
  begin
    N_Dump2Str( 'Start CMMCropBySelectedRectProcObj' );
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;


    SelRect := GetSelectedPixRect();
    N_Dump2Str( format( 'CMMCrop Rect=%d,%d,%d,%d',
                        [SelRect.Left,SelRect.Top,SelRect.Right,SelRect.Bottom] ) );
    // Switch to "Point"  mode prepare
    with EdRubberRectRFA.RRCurUserRect do
      AffCoefs6 := N_CalcAffCoefs6( D3PReper( Left, Top, Right, Bottom, Left, Bottom ),
                                   D3PReper( N_CMDIBURect.Left, N_CMDIBURect.Top,
                                             N_CMDIBURect.Right, N_CMDIBURect.Bottom,
                                             N_CMDIBURect.Left, N_CMDIBURect.Bottom ) );
    EdRubberRectRFA.ActEnabled := False;
    EdMoveVObjRFA.SkipNextMouseDown := (RFrame.CHType = htDblClick);

    if K_CMSDuplicateSlideBeforeCrop and (K_CMSMainUIShowMode <= 0) then
    begin
      NewSlide := K_CMCopySlideWithoutSrcImg( EdSlide );
      if (Integer(NewSlide) < 100) then
      begin
        if Integer(NewSlide) = 1 then // out of memory
          K_CMShowSoftMessageDlg( K_CML1Form.LLLMemory3.Caption,
    //                '     There is not enough memory to finish the action.'+#13#10+
    //                'Please close some open image(s) or restart Media Suite.',
                                            mtWarning, 10 );
        K_CMOutOfMemoryFlag := TRUE;
        RFrame.RedrawAllAndShow();
        goto LExit; // precaution
      end;


        // Save Statistics to Slides Buffer
      with K_CMEDAccess do
      begin
        HistCode := EDABuildHistActionCode(K_shATNotChange, Ord(K_shNCADuplicateCrop));
        if not (K_CMEDAccess is TK_CMEDDBAccess) then
          EDAAddHistActionToSlideBuffer( EdSlide, HistCode )
        else
          EDASaveSlidesListHistory( @EdSlide, 1, HistCode );
      end;

      PCMSlide := NewSlide.P;
      with NewSlide, PCMSlide^, GetCurrentImage() do
      begin
        UDData := nil; // Clear current Image UDData

        // Crop New DIB
        NDIB := DIBObj;
        DIBObj := TN_DIBObj.Create( NDIB, SelRect, NDIB.DIBPixFmt, NDIB.DIBExPixFmt );
        NDIB.Free;

        K_CMSlideInitByCurContext( NewSlide );
        CMSDB.PixWidth := 0; // for correct SetAttrsByCurImgParams work
        SetAttrsByCurImgParams( FALSE );
        CMSSourceDescr := 'Media Object (ID ' + EdSlide.ObjName + ') crop';

        NewSize := FPoint( DIBObj.DIBSize );
        with GetMapRoot().PCCS()^ do
          SRSize := NewSize;

        AffConvVObjects6( AffCoefs6, 0, RFrame.RFVectorScale );

        // Skip Show Emboss, Colorize, and Isodensity in Thumbnail
        RebuildMapRoot := (CMSDB.SFlags * [cmsfShowColorize, cmsfShowIsodensity, cmsfShowEmboss]) <> [];
        if RebuildMapRoot then
        begin
          WSFlags := CMSDB.SFlags;
          CMSDB.SFlags := CMSDB.SFlags - [cmsfShowColorize, cmsfShowIsodensity, cmsfShowEmboss];
          RebuildMapImageByDIB( );
        end;

        CreateThumbnail();

        if RebuildMapRoot then
        begin
          CMSDB.SFlags := WSFlags;
          RebuildMapImageByDIB( );
        end;

//N_Dump1Str( 'Coords new #1:' );
//N_Dump1Str( K_SPLValueToString( NewSlide.GetMapRoot.PSP.CCoords, K_GetTypeCode('TN_CompCoords') ) );

        K_CMEDAccess.EDAAddSlide(NewSlide);
        K_CMEDAccess.EDASaveSlidesArray( @NewSlide, 1 );
        K_CMEDAccess.EDALockSlides( @NewSlide, 1, K_cmlrmEditImgLock );
        SetNewSlide(NewSlide);
        CMMFRebuildVisSlides();
        CMMFSelectThumbBySlide( EdSlide );
      end;
    end   // if K_CMSDuplicateSlideBeforeCrop then
    else
    begin // if not K_CMSDuplicateSlideBeforeCrop then
    // Rebuild Current Image
      with EdSlide, P()^, GetCurrentImage() do begin
        GetImgViewConvData( @ImgViewConvData );
        ImgViewConvData.VCShowEmboss     := FALSE;
        ImgViewConvData.VCShowColorize   := FALSE;
        ImgViewConvData.VCShowIsodensity := FALSE;
        ImgViewConvData.VCCoFactor  := 0; // Image Contrast Correction Factor
        ImgViewConvData.VCGamFactor := 0; // Image Gamma Correction Factor
        ImgViewConvData.VCBriFactor := 0; // Image Brightness Correction Factor

        NDIB := nil;
        K_CMConvDIBBySlideViewConvData( NDIB, DIBObj,
                                        @ImgViewConvData, DIBObj.DIBPixFmt, DIBObj.DIBExPixFmt );
//        SelRect := GetSelectedPixRect();
        DIBObj.Free;
        DIBObj := TN_DIBObj.Create( NDIB, SelRect, NDIB.DIBPixFmt, NDIB.DIBExPixFmt );
        NDIB.Free;
        CMSDB.PixWidth := DIBObj.DIBSize.X;
        CMSDB.PixHeight := DIBObj.DIBSize.Y;
        CMSDB.BytesSize := ((CMSDB.PixBits + 7) shr 3) * CMSDB.PixWidth * CMSDB.PixHeight;

        with PISP^ do
        begin // Clear CurImg.UDData
          UDData := nil;
          Include( CDIBFlagsN, uddfnFreeUDData );
        end;

        N_Dump2Str( 'CMMCrop... DIBObj ReCreated' );

        // Clear Flip/Rotate in Map Attributes
        GetPMapRootAttrs()^.MRFlipRotateAttrs := 0;

        // Rebuild Map Image by new Current Image
        RebuildMapImageByDIB( );
        N_Dump2Str( 'CMMCrop... RebuildMapImageByDIB' );
      end; // with EdSlide, GetCurrentImage() do begin

      // Rebuild Vector Objects
{
      with EdRubberRectRFA.RRCurUserRect do
        AffCoefs6 := N_CalcAffCoefs6( D3PReper( Left, Top, Right, Bottom, Left, Bottom ),
                                     D3PReper( N_CMDIBURect.Left, N_CMDIBURect.Top,
                                               N_CMDIBURect.Right, N_CMDIBURect.Bottom,
                                               N_CMDIBURect.Left, N_CMDIBURect.Bottom ) );
}
//      AffConvVObjs6( AffCoefs6, 0 );
      EdSlide.AffConvVObjects6( AffCoefs6, 0, RFrame.RFVectorScale );
      N_Dump2Str( 'CMMCrop... AffConvVObjs6' );
{
      // Switch to "Point"  mode prepare
      EdRubberRectRFA.ActEnabled := False;
      EdMoveVObjRFA.SkipNextMouseDown := (RFrame.CHType = htDblClick);
}
//N_Dump1Str( 'Coords old #1:' );
//N_Dump1Str( K_SPLValueToString( EdSlide.GetMapRoot.PSP.CCoords, K_GetTypeCode('TN_CompCoords') ) );

      // Save Image changes
      CMMFFinishImageEditing( K_CML1Form.LLLTools8.Caption,
//                            'Image is cropped',
                            [cmssfCurImgChanged, cmssfMapRootChanged],
                             K_CMEDAccess.EDABuildHistActionCode( K_shATChange, Ord(K_shCAImage),
                                                                  Ord(K_shImgActCrop) ) );
//N_Dump1Str( 'Coords old #2:' );
//N_Dump1Str( K_SPLValueToString( EdSlide.GetMapRoot.PSP.CCoords, K_GetTypeCode('TN_CompCoords') ) );
    end; // if K_CMSDuplicateSlideBeforeCrop then
  end; // with CMMFActiveEdFrame do

LExit:
  CMMFDisableActions( nil );

  // Finish Crop Action
  with N_CMResForm do begin
    aEditPointExecute( nil );
  end;

  Screen.Cursor := SavedCursor;
  N_Dump2Str( 'Fin CMMCropBySelectedRectProcObj' );
end; // procedure TN_CMMain5Form1.CMMCropBySelectedRectProcObj

//********************************* TN_CMMain5Form1.CMMGetMarkedSlidesArray ***
// Get marked slides arry from Thumbnails Frame
//
//    Parameters
// ASlidesArray - resulting Slides Array
//
function TN_CMMain5Form1.CMMGetMarkedSlidesArray( var ASlidesArray: TN_UDCMSArray ) : Integer;
var
  i  : Integer;
begin
  with CMMCurFThumbsDGrid do
  begin
    Result := DGMarkedList.Count;
    //*** Select Marked Slides and Media
    if Length(ASlidesArray) < Result then
      SetLength( ASlidesArray, Result );
    for i := 0 to Result - 1 do
      ASlidesArray[i] := TN_UDCMSlide(K_CMCurVisSlidesArray[Integer(DGMarkedList[i])]);
  end;
  if CMMFActiveEdFrame.IfSlideIsStudy() and
     (TN_UDCMStudy(CMMFActiveEdFrame.EdSlide).CMSSelectedCount > 0) then
  // Add Selected Slides from Active Frame Study
    Result := TN_UDCMStudy(CMMFActiveEdFrame.EdSlide).GetSelectedSlidesToArray( ASlidesArray );

end; // procedure TN_CMMain5Form1.CMMGetMarkedSlidesArray

//********************************************* TN_CMMain5Form1.FormKeyDown ***
// Self KeyDown Handler
//
// Used Keys:
// Alt+Shift+M - Service Popup Menu
// Alt+Shift+Z - Save Dump and State Files
// Alt+Shift+0 - Abort by Divide by Zero (after pressing 3 times)
// Alt+Shift+L - Add strings to Dump1 log in Dialog
// Alt+Shift+S - Create Slides and close TWAIN mode 3 (temporary)
//
procedure TN_CMMain5Form1.FormKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
//var
//  MainFormCenter: TPoint;
begin
  if (ssShift in Shift) and (Key = Byte('M')) then // Show Service Popup Menu
  begin
{
    if K_CMDEMOModeFlag then // Hide several Options in Service Popup Menu in Demo mode
    begin
      N_CMResForm.aServECacheAllShow.Visible  := False;
      N_CMResForm.aServImportExtDBDlg.Visible := False;
    end; // if K_CMDEMOModeFlag then // Hide several Options in Service Popup Menu in Demo mode
{}
    N_CMResForm.aServSysSetupUIExecute( N_CMResForm.aServSysSetupUI );
{
    if K_CMAltShiftMConfirmDlg( ) then
    begin
      if K_CMEDAccess is TK_CMEDDBAccess then
        with K_CMEDAccess do
          EDASaveSlidesHistory( '', EDABuildHistActionCode( K_shATNotChange,
                                             Ord(K_shNCAAltShiftM) ) );

      N_CMResForm.aServSysSetupExecute(N_CMResForm.aServSysSetup);

//      MainFormCenter := N_RectCenter( N_MainUserFormRect );
//      MaintenancePopupMenu.Popup( MainFormCenter.X-124, MainFormCenter.Y-122 ); // (124,122) is PopupMenu half size

    end;
}


    Exit;
  end; // if (ssShift in Shift) and (Key = Byte('M')) then // Show Service Popup Menu

  if (ssShift in Shift) and (Key = Byte('Z')) then // Save Dump and State Files
  begin
    N_Dump2Str( 'Alt+Shift+Z(Main) is pressed' );
    N_CMSCreateDumpFiles( 0 );
    CMMFShowStringByTimer( 'Dump files created' );
    Exit;
  end; // if (ssShift in Shift) and (Key = Byte('Z')) then // Save Dump and State Files

  if (ssShift in Shift) and (Key = Byte('0')) then // Abort by Divide by Zero (after pressing 3 times)
  begin
    Inc( CMMFAltShift0Count );
    N_Dump2Str( 'Alt+Shift+0 is pressed' );
    if CMMFAltShift0Count >= 3 then
    begin
      N_i := Round(N_i / 0); // divide by Zero
    end;
  end; // if (ssShift in Shift) and (Key = Byte('0')) then // Abort by Divide by Zero

  if (ssShift in Shift) and (Key = Byte('L')) then // Add strings to Dump1 log in Dialog
  begin
    N_AddToDumpDlg();
  end; // if (ssShift in Shift) and (Key = Byte('L')) then // Add strings to Dump1 log in Dialog

  if (ssShift in Shift) and (Key = Byte('S')) then // Create Slides and close TWAIN mode 3 (temporary)
  begin
    N_Dump1Str( 'Alt+Shift+S Pressed - Create Slides and close TWAIN mode 3' );
    N_CMTWAIN3Obj.CMTManualClose := True;
  end; // if (ssShift in Shift) and (Key = Byte('S')) then // Create Slides and close TWAIN mode 3 (temporary)

end; // end of procedure TN_CMMain5Form1.FormKeyDown

//********************************************* TN_CMMain5Form1.FormKeyPress ***
// Self KeyPress Handler
//
procedure TN_CMMain5Form1.FormKeyPress(Sender: TObject; var Key: Char);
var
  i : Integer;
begin
  if N_CM_MainForm.CMMEdVEMode = cmrfemFlashLight then
  begin
    // Search for current frame
    case Key of
      Char(VK_Escape):
      with N_CMResForm do
        aToolsFlashLightModeExecute( aToolsFlashLightMode );
      '-': begin
        K_CMFlashlightModeIni.CMFLScaleFactor := Max( K_CMFlashlightModeIni.CMFLScaleFactor - 0.5, 1 );
      end;
      '+':begin
        K_CMFlashlightModeIni.CMFLScaleFactor := Min( K_CMFlashlightModeIni.CMFLScaleFactor + 0.5, 10 );
      end;
      '1':
        K_CMFlashlightModeIni.CMFLPixSize := K_CMFlashlightModeBasePixSize;
      '2':
        K_CMFlashlightModeIni.CMFLPixSize := Round( 1.5 * K_CMFlashlightModeBasePixSize );
      '3':
        K_CMFlashlightModeIni.CMFLPixSize := 2 * K_CMFlashlightModeBasePixSize;
      '4':
        K_CMFlashlightModeIni.CMFLPixSize := 3 * K_CMFlashlightModeBasePixSize;
    end;

    for i := 0 to CMMFNumVisEdFrames - 1 do
      with CMMFEdFrames[i].EdFlashLightModeRFA do
      begin
        if CMEFLComp = nil then Continue;
        Execute();
      end;
  end;
  inherited;
end;

//******************************* TN_CMMain5Form1.MaintenancePopupMenuPopup ***
// Service Menu Popup Handler
//
//
procedure TN_CMMain5Form1.MaintenancePopupMenuPopup( Sender: TObject );
begin
//
  with N_CMResForm do
  begin
    aServEModeFilesSync.Visible := K_CMEnterpriseModeFlag;
    aServSelSlidesToSyncQuery.Visible := K_CMEnterpriseModeFlag;
    aServECacheAllShow.Visible  := not K_CMDEMOModeFlag;
    aServImportExtDBDlg.Visible := not K_CMDEMOModeFlag;
//    aServImportExtDBDlg.Enabled := not (uicsAllActsDisabled in CMMUICurStateFlags);
//    aServMaintenance.Visible := K_CMEDAccess is TK_CMEDDBAccess;
    aServMaintenance.Enabled := not K_CMEnterpriseModeFlag and (K_CMEDAccess is TK_CMEDDBAccess);
//  aServDBRecoveryByFiles.Visible := K_CMEDAccess is TK_CMEDDBAccess;
    aServDBRecoveryByFiles.Enabled := K_CMEDAccess is TK_CMEDDBAccess;
    aServDelObjHandling.Visible := K_CMEDAccess is TK_CMEDDBAccess;
  end;
end; // end of procedure TN_CMMain5Form1.MaintenancePopupMenuPopup

//********************************** TN_CMMain5Form1.CMMInitThumbFrameTexts ***
// Init Thumbnails Frame Texts Draw Attributes
//
procedure TN_CMMain5Form1.CMMInitThumbFrameTexts;
begin
  CMMThumbsSlidesTextRowsCount := K_GetIntBitsCount( Byte(K_CMSThumbTextFlags) );
  CMMCurFThumbsDGrid.DGLAddDySize := 4 + N_CM_ThumbFrameRowHeight * CMMThumbsSlidesTextRowsCount;
end; // end of procedure TN_CMMain5Form1.CMMInitThumbFrameTexts

//****************************** TN_CMMain5Form1.CMMSetMUFRectByActiveFrame ***
// Save Main User Form Rect and replace it by Current Active Frame Desktop Rectangle
//
procedure TN_CMMain5Form1.CMMSetMUFRectByActiveFrame();
begin
  CMMSavedMUFRect := N_MainUserFormRect;
  if CMMFActiveEdFrame <> nil then
    N_ProcessMainFormMove( N_GetScreenRectOfControl( CMMFActiveEdFrame ) );
end; // end of procedure TN_CMMain5Form1.CMMSetMUFRectByActiveFrame

//*************************************** TN_CMMain5Form1.CMMRestoreMUFRect ***
// Restore saved Main User Form Rect
//
procedure TN_CMMain5Form1.CMMRestoreMUFRect();
begin
  if CMMSavedMUFRect.Left = CMMSavedMUFRect.Right then
    N_ProcessMainFormMove( N_GetScreenRectOfControl( CMMCurFMainForm ) )
  else
    N_MainUserFormRect := CMMSavedMUFRect;
end; // end of procedure TN_CMMain5Form1.CMMRestoreMUFRect

//*************************************** TN_CMMain5Form1.CMMHideFlashlightIfNeeded ***
// Hide Flashlight if needed
//
procedure TN_CMMain5Form1.CMMHideFlashlightIfNeeded();
begin
  if (CMMEdVEMode = cmrfemFlashLight) and
     (CMMFlashlightLastEd3Frame <> nil) then
  begin
  // Hide FlashLight if needed
     CMMFlashlightLastEd3Frame.EdFlashLightModeRFA.HideFlashlight( TRUE );
     CMMFlashlightLastEd3Frame := nil;
  end;
end; // end of procedure TN_CMMain5Form1.CMMHideFlashlightIfNeeded

//*************************************** TN_CMMain5Form1.CMMChangeThumbState ***
// Thumbnail Change State processing (used as TN_DGridBase.DGChangeItemStateProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - Index of Thumbnail that is change state
//
procedure TN_CMMain5Form1.CMMChangeThumbState( ADGObj: TN_DGridBase; AInd: integer);
begin
  with CMMCurFThumbsDGrid, DGMarkedList do begin
  end;
end; // procedure TN_CMMain5Form1.CMMChangeThumbState

//********************************* TN_CMMain5Form1.OnComboBoxColorItemDraw ***
// ComboBox Color Item OnDraw Handler
//
procedure TN_CMMain5Form1.OnComboBoxColorItemDraw( Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState );

var
  LRect: TRect;
  LBackground: TColor;

  function ColorToBorderColor(AColor: TColor): TColor;
  type
    TColorQuad = record
      Red,
      Green,
      Blue,
      Alpha: Byte;
    end;
  begin
    if (TColorQuad(AColor).Red > 192) or
       (TColorQuad(AColor).Green > 192) or
       (TColorQuad(AColor).Blue > 192) then
      Result := clBlack
    else if odSelected in State then
      Result := clWhite
    else
      Result := AColor;
  end;

begin
  with TComboBox(Control), Canvas do
  begin
    FillRect(Rect);
    LBackground := Brush.Color;

    LRect := Rect;
//!!?? if Index = 0 then
    LRect.Right := LRect.Bottom - LRect.Top + LRect.Left;

    InflateRect(LRect, -1, -1);

    if Index <> 0 then
      Brush.Color := TColor(CMMStudyColorsList.Objects[Index]);

//!!?? if Index <> 0 then
//!!?? begin
    FillRect(LRect);
    Brush.Color := ColorToBorderColor(ColorToRGB(Brush.Color));
    FrameRect(LRect);
//!!?? end;
    Brush.Color := LBackground;
    Rect.Left := LRect.Right + 5;

//!!?? if Index = 0 then
    TextRect(Rect, Rect.Left,
      Rect.Top + (Rect.Bottom - Rect.Top - TextHeight(CMMStudyColorsList[Index])) div 2,
      CMMStudyColorsList[Index]);
  end;
end; // procedure TN_CMMain5Form1.OnComboBoxColorItemDraw

//******************************* TN_CMMain5Form1.CMMChangeSlideSelectState ***
// Change Slide Thumbnail Select state by given ID
//
//     Parameters
// ASlideID    - slide ID
// AStateMode  - new State Mode
//
function TN_CMMain5Form1.CMMChangeSlideSelectState( ASlideID : string; AStateMode: TN_SetStateMode) : Boolean;
var
  i: Integer;
  SlideInd: Integer;
  Marked: TList;
  Slide : TN_UDCMSlide;
  StudyItem : TN_UDBase;
  Study : TN_UDCMStudy;
  WCount: Integer;
begin
  Result := TRUE;
  N_Dump2Str( format( 'CMMChangeSlideSelectState >> Start Select=%d By ID =%s', [Ord(AStateMode), ASlideID] ) );
  SlideInd := -1;
  WCount := Length(K_CMCurVisSlidesArray);
  if WCount > 0 then
    // Search in Visible Slides
    SlideInd := K_CMSearchSlideByID(@K_CMCurVisSlidesArray[0], WCount, ASlideID);

  N_Dump2Str( format( 'CMMChangeSlideSelectState >> Search visible I=%d C=%d', [SlideInd, WCount] ) );

  if (SlideInd = -1) and (AStateMode = ssmMark) then
  begin
    // Search in All Slides
    with K_CMEDAccess.CurSlidesList do
    begin
      SlideInd := K_CMSearchSlideByID(TN_PUDCMSlide(@List[0]), Count, ASlideID);
      N_Dump2Str( format( 'CMMChangeSlideSelectState >> Search All I=%d C=%d', [SlideInd,Count] ) );
    end;


    if SlideInd >= 0 then
    begin  // Slide Exists - in CurSlideList
      Slide := TN_UDCMSlide(K_CMEDAccess.CurSlidesList[SlideInd]);
      StudyItem := Slide.GetStudyItem();
      if (StudyItem <> nil) and K_CMD4WSlideStudyOpenFlag then
      begin
      // Open Slide Study and Select Study Item
        // Select Slide Study by Study ID
        Study := TN_UDCMStudy(StudyItem.Owner.Owner);

        N_Dump2Str( format( 'CMMChangeSlideSelectState >> Select study ID=%s slide ID=%s',
                            [Study.ObjName, Slide.ObjName] ) );

        if Study.CMSRFrame = nil then
        begin
        // Study is not opened -  Open Study
          N_Dump2Str( 'ExecUI >> Open Study' );
          // Select Study Thumb
          Result := CMMChangeSlideSelectState( Study.ObjName, ssmMark);
          with N_CMResForm do
            if Result and aMediaAddToOpened.Enabled then
            // Study is Selected
              aMediaAddToOpenedExecute( aMediaAddToOpened );
        end; // if Study.CMSRFrame = nil Study is not opened

        if Study.CMSRFrame <> nil then
        begin
        // Study is opened
          N_Dump2Str( 'CMMChangeSlideSelectState >> Study is opened - select Slide' );
          // Add New Item to Selected
          Study.SelectItem( StudyItem );
          Study.CMSRFrame.RedrawAllAndShow();

          with N_CM_MainForm, CMMCurFThumbsDGrid do
          begin
            // Clear Thumbs Selection
            if DGMarkedList.Count > 0 then
            begin
              DGMarkSingleItem( -1 ); // for proper Marked Items order
              DGRFrame.ShowMainBuf();
            end;

            // Set New Action Ability after Selection changing
            CMMFDisableActions(nil);
          end; // with N_CM_MainForm, CMMCurFThumbsDGrid do
        end; // if Study.CMSRFrame <> nil then

        Exit;
      end   // if (StudyItem <> nil) and K_CMD4WSlideStudyOpenFlag then
      else
      begin // if (StudyItem = nil) or not K_CMD4WSlideStudyOpenFlag then
      // Insert Slide to Visible
        N_Dump2Str( 'CMMChangeSlideSelectState >> Insert slide to visible' );
        SetLength(K_CMCurVisSlidesArray, WCount + 1);
        if WCount > 0 then
          Move( K_CMCurVisSlidesArray[0], K_CMCurVisSlidesArray[1],
                WCount * SizeOf(TN_UDCMSlide) );
        K_CMCurVisSlidesArray[0] := Slide;

        N_Dump2Str( 'CMMChangeSlideSelectState >> Set Marked state' );
        with N_CM_MainForm, CMMCurFThumbsDGrid do
        begin
          // Save Selected Slide Inds
          Marked := TList.Create;
          Marked.Assign(DGMarkedList);
          DGNumItems := Length(K_CMCurVisSlidesArray);
          // Number of visible Thumbnails
          N_Dump2Str( format( 'CMMChangeSlideSelectState >> Rebuild Selection SC=%d MC=%d', [DGNumItems, Marked.Count] ) );
          DGInitRFrame(); // should be called after all CMMFThumbsDGrid fields are set
          for i := 0 to Marked.Count - 1 do
            DGSetItemState(Integer(Marked[i]) + 1, ssmMark);
          Marked.Free;
        end; // with N_CM_MainForm.CMMCurFThumbsDGrid do
        SlideInd := 0;
      end; // if (StudyItem = nil) or not K_CMD4WSlideStudyOpenFlag then
    end; // if SlideInd >= 0 then
  end; // if (SlideInd = -1) and (ASetAct = ssmMark) then

  if SlideInd >= 0 then
  begin
    if N_CM_MainForm.CMMFActiveEdFrame.IfSlideIsStudy then
    begin
      N_Dump2Str( 'CMMChangeSlideSelectState >> Clear Cur Study Selection' );
    // Clear active Study Selection
      with TN_UDCMStudy(N_CM_MainForm.CMMFActiveEdFrame.EdSlide) do
      begin
        if CMSSelectedCount > 0 then
        begin
          UnSelectAll();
          CMSRFrame.RedrawAllAndShow();
        end;
      end;
    end; // if N_CM_MainForm.CMMFActiveEdFrame.IfSlideIsStudy then

    // Add New Thumb to Selected
    N_CM_MainForm.CMMCurFThumbsDGrid.DGSetItemState(SlideInd, AStateMode);
    N_CM_MainForm.CMMCurFThumbsDGrid.DGSelectItem(SlideInd);
    N_CM_MainForm.CMMCurFThumbsRFrame.RedrawAllAndShow();

    // Set New Action Ability after Selection changing
    N_CM_MainForm.CMMFDisableActions(nil);
  end
  else
    Result := FALSE;
end; // TN_CMMain5Form1.CMMChangeSlideSelectState

//******************************************* TN_CMMain5Form1.CMMLaunchHPUI ***
// Launch High Resolution User Interface Window
//
procedure TN_CMMain5Form1.CMMLaunchHPUI();
var
  HPSlideInd : Integer;
  SpecViewSlide : TN_UDCMSLide;
  PSlides: TN_PUDCMSlide;
  SlidesLeng : Integer;
  Img3DFolder : string;
  CMCDServObj : TK_CMCDServObj;
//  WCurPatID, WCurLocID, WCurProvID : Integer;
begin
  N_Dump1Str( 'TN_CMMain5Form1 >> Launch TK_FormCMHPreview start' );
  HPSlideInd := K_CMPrepHPContext( SpecViewSlide );
  if SpecViewSlide <> nil then
  begin // Special Preview
    K_CMEDAccess.AccessReady := TRUE;
    with SpecViewSlide.P.CMSDB do
    if (cmsfIsMediaObj in SFlags) then
    begin // Video
      N_Dump1Str( 'Preview video slide ID=' + SpecViewSlide.ObjName );
      K_CMOpenMediaFile( SpecViewSlide );
    end
    else
    begin // 3D Image
    //////////////////////////////////////////// SIR #22833 2018-12-17
    // Different code to open Self 3D and Device 3D objects is needed
    //
      if Capt3DDevObjName = '' then
      begin // Self 3D image
        N_Dump1Str( 'Preview Img3D by Self 3DViewer slide ID=' + SpecViewSlide.ObjName );
        Img3DFolder := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( SpecViewSlide ) +
                       K_CMSlideGetImg3DFolderName( SpecViewSlide.ObjName );
        if K_CMImg3DCall( Img3DFolder ) = 0 then
        begin
          // Import 2D views
          K_CMSRebuildCommonRImage();
  {
        // Set Cur Context for corret imported slides saving
          WCurPatID := K_CMEDAccess.CurPatID;
          K_CMEDAccess.CurPatID  := K_CMSAppStartContext.CMASPatID;
          WCurProvID := K_CMEDAccess.CurProvID;
          K_CMEDAccess.CurProvID := K_CMSAppStartContext.CMASProvID;
          WCurLocID := K_CMEDAccess.CurLocID;
          K_CMEDAccess.CurLocID  := K_CMSAppStartContext.CMASLocID;
  }
          CMMImg3DViewsImportAndShowProgress( SpecViewSlide.ObjName, Img3DFolder );
  {
        // Restore Cur Context
          K_CMEDAccess.CurPatID  := WCurPatID;
          K_CMEDAccess.CurProvID := WCurProvID;
          K_CMEDAccess.CurLocID  := WCurLocID;
  }
        end;
      end   // if Capt3DDevObjName = '' then
      else
      begin // if Capt3DDevObjName <> '' then
      // Device 3D image
        N_Dump1Str( 'Preview Img3D by Device 3DViewer slide ID=' + SpecViewSlide.ObjName );
        CMCDServObj := K_CMCDGetDeviceObjByName( Capt3DDevObjName );
        if CMCDServObj = nil then
          N_CM_MainForm.CMMFShowStringByTimer( 'Device object is not found' )
        else
        begin
//          N_Dump2Str( format( '3D> OpenDev3DViewer for ObjID=%s Serv=%s before', [SpecViewSlide.ObjName,CMCDServObj.CDSName] ) );
//          CMCDServObj.CDSOpenDev3DViewer( MediaFExt );
//          N_Dump2Str( '3D> OpenDev3DViewer after' );
          N_Dump2Str( '3D> HP OpenDev3DViewer before' );
          Img3DFolder := MediaFExt;
          if Img3DFolder = '' then
            Img3DFolder := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( SpecViewSlide ) +
                                              K_CMSlideGetImg3DFolderName( SpecViewSlide.ObjName );
    //      CMCDServObj.CDSOpenDev3DViewer( CMSDB.MediaFExt );
          N_Dump2Str( format( '3D> HP OpenDev3DViewer for ObjID=%s Serv=%s Path=%s', [SpecViewSlide.ObjName, CMCDServObj.CDSName,Img3DFolder] ) );
          CMCDServObj.CDSOpenDev3DViewer( Img3DFolder );
          N_Dump2Str( '3D> HP OpenDev3DViewer after' );
        end;
      end; // if Capt3DDevObjName <> '' then
    end; // 3D Image
  end   // Special Preview
  else
  begin // Show HPreviewForm
{
  if HPSlideInd = -1 then
    N_Dump1Str( 'TN_CMMain5Form1 >> Empty Visible Slides Set' )
  else
}
  // HighRes Preview
    with K_CMGetHPreviewForm() do
    begin
      Show();
      PSlides := nil;
      SlidesLeng := Length(K_CMCurVisSlidesArray);
      if SlidesLeng > 0 then
        PSlides := @K_CMCurVisSlidesArray[0];

      HPShowSlides( PSlides, SlidesLeng, HPSlideInd, K_CMD4WHPOpenInVEMode = 1 );

      // Return Normal State to Openning HPUI Window
      if IsIconic(Application.Handle) then
      begin
        ShowWindow( Application.Handle, SW_SHOWNORMAL );
        ShowWindow( Handle, SW_SHOWNORMAL );
      end;
    end;
    K_CMSRebuildCommonRImage();
  end;
  N_Dump2Str( 'TN_CMMain5Form1 >> Launch TK_FormCMHPreview fin' );

end; // procedure TN_CMMain5Form1.CMMLaunchHPUI

//******************************************* TN_CMMain5Form1.CMMLaunchVEUI ***
// Launch View/Edit User Interface Window
//
procedure TN_CMMain5Form1.CMMLaunchVEUI();
var
  CurForm : TForm;
begin
  N_Dump1Str( 'TN_CMMain5Form1 >> Launch Main UI' );

  if K_CMSMainUIShowMode <= 0 then
    CurForm := TK_FormCMMain5.Create(Application)
  else
  begin
    K_CMShowPMTStudiesOnlyFlag := TRUE;
//    CurForm := TK_FormPMTMain5.Create(Application);
    CurForm := TN_PMTMain5Form.Create(Application);
  end;

  with CurForm do
  begin
    K_CMCloseOnCurUICloseFlag := TRUE;
    if K_CMDesignModeFlag and (CurForm is TK_FormCMMain5) then
    begin
      DragAcceptFiles( Handle, TRUE );
{$IF CompilerVersion >= 26.0} // !!! this code is added 2021-01-19
      ChangeWindowMessageFilter (WM_DROPFILES, MSGFLT_ADD);
      ChangeWindowMessageFilter (WM_COPYGLOBALDATA, MSGFLT_ADD);
{$IFEND CompilerVersion >= 26.0}
    end;
{
///////////////////////////////////////
// Demo TEST Code
if K_CMDemoTestTop then FormStyle := fsStayOnTop;
if K_CMDemoTestModal then
  ShowModal()
else
// Demo TEST Code
///////////////////////////////////////
}
    Show();

    // Return Normal State to Openning VEUI Window
    if IsIconic(Application.Handle) then
    begin
      ShowWindow( Application.Handle, SW_SHOWNORMAL );
      ShowWindow( Handle, SW_SHOWNORMAL );
    end; // if IsIconic(Application.Handle) then
//    DragAcceptFiles( Handle, TRUE );
  end; // with CurForm do
end; // procedure TN_CMMain5Form1.CMMLaunchVEUI

//********************** TN_CMMain5Form1.CMMImg3DViewsImportAndShowProgress ***
// Import Image 3D Views and show progress while impotting
//
//     Parameters
// A3DSlide - 3D Slide ID to Import 2D views
// ASlideBasePath - base path to Import 2D views
// Result - Returns number of imported views
//
function  TN_CMMain5Form1.CMMImg3DViewsImportAndShowProgress(
                         const A3DSlideID, ASlideBasePath : string ) : Integer;
var
  SL : TStringList;
begin
    // Build 2D views files  List
  SL := TStringList.Create();
  K_CMImg3DViewsFListPrep( SL, A3DSlideID, ASlideBasePath );
  Result := SL.Count;
  if Result > 0 then
    with TK_FormCMImg3DViewsImportProgress.Create( Application ) do
    begin
    // Import Existing 2D views
      Show();
      IMaxCount := SL.Count;
      Result :=  K_CMImg3DViewsFlistImport( SL, A3DSlideID, ASlideBasePath,
                                            Img3DViewsShowProgress );
      Close();
      Release();
    end;
  SL.Free();
end; // procedure TN_CMMain5Form1.CMMImg3DViewsImportAndShowProgress

//***************************************** TN_CMMain5Form1.CMMSetUIEnabled ***
// Set Use Interface Enabled
//
//     Parameters
// AUIEnabled - new value for enabled property
//
// Needed to disable Application UI when not modal devices are started and so on
//
procedure TN_CMMain5Form1.CMMSetUIEnabled( AUIEnabled : boolean );
begin
  if not AUIEnabled and not K_CMD4WSkipCloseUI then
  begin // Disable UI
    Include( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled );
    CMMFDisableActions( Self );
    N_AppSkipEvents := TRUE;
    K_CMD4WSkipCloseUI := TRUE;
    Inc( K_CMD4WWaitApplyDataCount );
    N_Dump2Str( 'CMS UI is disabled' );
  end
  else
  if K_CMD4WSkipCloseUI then
  begin // Enable UI
    K_CMD4WSkipCloseUI := FALSE;
    N_AppSkipEvents := FALSE;
    Exclude( N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled);
    CMMFDisableActions( nil );
    Dec(K_CMD4WWaitApplyDataCount);
    N_Dump2Str( 'CMS UI is enabled' );
  end;
end; // procedure TN_CMMain5Form1.CMMSetUIEnabled

{
//************************************* TN_CMMain5Form1.CMMFullScreenWndProc ***
// Self WindowProc
//
//     Parameters
// Msg - Window Message
//
//#F
// Messages to skip (Ctrl + F):
//     Msg    WParam
//  0000B02E 00000046  'F' Key
//
//#/F
procedure TN_CMMain5Form1.CMMFullScreenWndProc(var Msg: TMessage);
begin
//if N_KeyIsDown(VK_SHIFT) then
  N_Dump2Str( format('FS %x %x %x', [Msg.Msg,Msg.WParam,Msg.LParam]) );

  if N_KeyIsDown(VK_CONTROL) and (Msg.Msg = $B02E) and (Msg.WParam = $46) then
  begin
    N_CMResForm.aEditFullScreenCloseExecute( N_CMResForm.aEditFullScreenClose );
    Exit;
  end;

  OwnWndProc( Msg );
end; // TN_CMMain5Form1.CMMFullScreenWndProc
}

//********************************* TN_CMMain5Form1.SearchProjectFormsClick ***
// SearchProjectForms click Handler
//
procedure TN_CMMain5Form1.SearchProjectFormsClick( Sender: TObject );
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

end; // procedure TN_CMMain5Form1.SearchProjectFormsClick

//************************************ TN_CMMain5Form1.aEdFrameStudyOnPopup ***
// aEdFrameStudy OnPopup Handler
//
procedure TN_CMMain5Form1.aEdFrameStudyOnPopup(Sender: TObject);
var
  UDInvisibleRoot : TN_UDBase;
begin
  if not N_CMResForm.aEditStudyItemSelectVis.Enabled then Exit;
  with TN_UDCMStudy(CMMFActiveEdFrame.EdSlide) do
  begin
//    UDInvisibleRoot := CMSSelectedItems[0].DirChild(K_CMStudyItemIndInvisRoot);
    UDInvisibleRoot := K_CMStudyGetItemInvisibleRoot( CMSSelectedItems[0] );
    N_CMResForm.aEditStudyItemSelectVis.Enabled :=
           (UDInvisibleRoot <> nil) and (UDInvisibleRoot.DirLength() > 0);
  end;

end; // procedure TN_CMMain5Form1.aEdFrameStudyOnPopup(Sender: TObject)

procedure TN_CMMain5Form1.TestEd3FrameClick( Sender: TObject );
var
  FF : TN_BaseForm;
  hTaskBar: THandle;
  PrevParent: TWinControl;
begin
//
//  with N_CM_MainForm do begin
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
//      BFSelfName := 'FullScreenForm';
  //    RFrame.ParentForm := Result;
//      BaseFormInit( Self );
      BaseFormInit( nil, 'FullScreenForm', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

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
//  end;
end; // procedure TN_CMMain5Form1.TestEd3FrameClick

{
procedure TN_CMMain5Form1.ShowNVTreeForm1Click(Sender: TObject);
begin
  inherited;
  MFFrame.aFormsNVtreeExecute(Sender);
end;
}

procedure TN_CMMain5Form1.aShowNewGUIClick( Sender: TObject );
//var
//  CurThumbsFrameWidth : Integer;
begin
{
  CurThumbsFrameWidth := CMMCurFThumbsRFrame.Width;
  with TK_FormCMMain6.Create(Application) do
  begin
//    BaseFormInit(nil);
    K_CMShowGUIFlag := TRUE;
    N_CM_MainForm.CMMFDisableActions(Sender);
    ShowModal();
  end;
  N_CM_MainForm.CMMCurFStatusBar := StatusBar;
  N_CM_MainForm.CMMCurFMainForm := Self;
  N_CM_MainForm.CMMCurFThumbsDGrid := CMMFThumbsDGrid;
  N_CM_MainForm.CMMCurFThumbsRFrame := ThumbsRFrame;
  N_CM_MainForm.CMMCurFThumbsResizeTControl := ThumbsRFrame;
  N_CM_MainForm.CMMCurFThumbsResizeTControl.Width := CurThumbsFrameWidth;
  N_CM_MainForm.CMMFRebuildVisSlides();
  N_CM_MainForm.ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events
  K_CMShowGUIFlag := FALSE;
  N_CM_MainForm.CMMFDisableActions(Sender);
}
end; // procedure TN_CMMain5Form1.aShowNewGUIClick

procedure TN_CMMain5Form1.aOpenMainForm6Execute( Sender: TObject );
//var
//  CurThumbsFrameWidth, EdFrPanelLeft : Integer;
//  PRevParent : TWinControl;
begin
{
  CurThumbsFrameWidth := CMMCurFThumbsRFrame.Width;
  with TK_FormCMMain6.Create(Application) do
  begin
//    BaseFormInit(nil);
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
    CurThumbsFrameWidth := Left2Panel.Width;
    N_CM_MainForm.EdFramesPanel.Visible := FALSE;
    N_CM_MainForm.EdFramesPanel.Left := EdFrPanelLeft;
    N_CM_MainForm.EdFramesPanel.Parent := PRevParent;
    N_CM_MainForm.EdFramesPanel.Visible := TRUE;
  end;
  N_CM_MainForm.CMMCurFStatusBar := StatusBar;
  N_CM_MainForm.CMMCurFMainForm := Self;
  N_CM_MainForm.CMMCurFThumbsDGrid := CMMFThumbsDGrid;
  N_CM_MainForm.CMMCurFThumbsRFrame := ThumbsRFrame;
  N_CM_MainForm.CMMCurFThumbsResizeTControl := ThumbsRFrame;
  N_CM_MainForm.CMMCurFThumbsResizeTControl.Width := CurThumbsFrameWidth;
  N_CM_MainForm.CMMFRebuildVisSlides();
  N_CM_MainForm.ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events
  N_CM_MainForm.CMMFDisableActions(Sender);
}
end; // procedure TN_CMMain5Form1.aOpenMainForm6Execute

procedure TN_CMMain5Form1.aOpenMainForm5Execute( Sender: TObject );
begin
  with TK_FormCMMain5.Create(Application) do
  begin
{
//    BaseFormInit(nil);
    N_CM_MainForm.EdFramesPanel.Visible := FALSE;
    N_CM_MainForm.EdFramesPanel.Parent := Bot2Panel;
    N_CM_MainForm.EdFramesPanel.Visible := TRUE;
    ThumbsRFrame.Width := N_CM_MainForm.ThumbsRFrame.Width;
//    K_CMShowGUIFlag := TRUE;
//    CurSlideFilterAttrs := K_CMCurSlideFilterAttrs;

    N_CM_MainForm.CMMFDisableActions(Sender);
    ShowModal();
    N_CM_MainForm.CMMCurFMainForm := N_CM_MainForm;
    N_CM_MainForm.CMMCurFStatusBar := N_CM_MainForm.StatusBar;
    N_CM_MainForm.CMMCurFThumbsDGrid := N_CM_MainForm.CMMFThumbsDGrid;
    N_CM_MainForm.CMMCurFThumbsRFrame := N_CM_MainForm.ThumbsRFrame;
    N_CM_MainForm.CMMCurFThumbsResizeTControl := N_CM_MainForm.ThumbsRFrame;
    N_CM_MainForm.CMMCurFThumbsResizeTControl.Width := CMMCurFThumbsRFrame.Width;
    N_CM_MainForm.EdFramesPanel.Visible := FALSE;
    N_CM_MainForm.EdFramesPanel.Parent := N_CM_MainForm.Bot2Panel;
    N_CM_MainForm.EdFramesPanel.Visible := TRUE;
    N_CM_MainForm.ThumbsRFrame.Width := ThumbsRFrame.Width;
    N_CM_MainForm.ActiveControl := N_CM_MainForm.ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events
    N_CM_MainForm.CMMFRebuildVisSlides();
    N_CM_MainForm.CMMFDisableActions(Sender);
}
  end;
end; // procedure TN_CMMain5Form1.aOpenMainForm5Execute

procedure TN_CMMain5Form1.DICOMTest1Click( Sender: TObject );
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
end; // procedure TN_CMMain5Form1.DICOMTest1Click

end.


