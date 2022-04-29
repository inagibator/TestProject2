unit K_FCMPrint1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, ExtCtrls, StdCtrls, Buttons, ActnList, IniFiles,
  N_Types, N_BaseF, N_CompBase, N_Rast1Fr, N_SGComp, N_DGrid, N_Gra2,
  K_UDT1, K_CM0;

//type TK_CMSPGetGroupAttrsFunc = procedure( AGroupAttrs : TStrings ) of object;
//type TK_CMSPGetSlideAttrsFunc = procedure( ASlide : TN_UDBase;
//                                           out ASlideUDVTree, ASlideImage : TN_UDBase;
//                                           ASlideAttrs : TStrings ) of object;
type TK_FormCMPrint1 = class(TN_BaseForm)
  TimerMin: TTimer;
  TimerMax: TTimer;

  PnPreview: TPanel;
    RFrame: TN_Rast1Frame;

    PnPageScroll: TPanel;
      TBPageView: TToolBar;
        TBZoomIn: TToolButton;
      TBPageView1: TToolBar;
        TBZoomOut1: TToolButton;
      TBPageView2: TToolBar;
        TBFitInWindow1: TToolButton;
      TBSlideScale: TToolBar;
        TBSlideFitToView: TToolButton;
      TBSlideScale1: TToolBar;
        TBSlideFixZoom1: TToolButton;
      LbSlideScale: TLabel;
    CmBSlideScale_7: TComboBox;
      PnPageScroll0: TPanel;
        LbPageNum: TLabel;
        BBPageFirst: TBitBtn;
        BBPageLast: TBitBtn;
        BBPageNext: TBitBtn;
        BBPagePrev: TBitBtn;
        PrinterSetupDialog: TPrinterSetupDialog;
  SBControls: TScrollBox;
    PnControls: TPanel;
      GBPageLayout: TGroupBox;
        EdColCount: TLabeledEdit;
        UDColCount: TUpDown;
        EdRowCount: TLabeledEdit;
        UDRowCount: TUpDown;
      GBPrinter: TGroupBox;
        EdPrinterName: TLabeledEdit;
        LbPaperSize: TLabel;
        BBPrinterSetUp: TBitBtn;
        UDCopyCount: TUpDown;
        EdCopyCount: TLabeledEdit;
        GBPrintRange: TGroupBox;
          RBPageAll: TRadioButton;
          RBPageRange: TRadioButton;
          EdBegPage: TLabeledEdit;
          EdEndPage: TLabeledEdit;

      GBPageMargins: TGroupBox;
        EdMarginTop: TLabeledEdit;
        EdMarginBottom: TLabeledEdit;
        EdMarginLeft: TLabeledEdit;
        EdMarginRight: TLabeledEdit;
        UDMarginRight: TUpDown;
        UDMarginLeft: TUpDown;
        UDMarginTop: TUpDown;
        UDMarginBottom: TUpDown;
    ChBSetMinMargins: TCheckBox;
      GBData: TGroupBox;
      BtCancel: TButton;
      BtPrint: TButton;
    GBHeader: TGroupBox;
    EdReportTitle: TLabeledEdit;
    ChBProvDetails: TCheckBox;
    ChBPatDetails: TCheckBox;
    ChBPrintPageHeader: TCheckBox;
    GBPageFooter: TGroupBox;
    ChBPrintPageNumber: TCheckBox;
    ChBImgDetails: TCheckBox;
    StartDragTimer: TTimer;
    Splitter1: TSplitter;
    PnSlides: TPanel;
    PrintSlidesRFrame: TN_Rast1Frame;
    BtFillAll: TButton;
    BtClearAll: TButton;
    BtClearPage: TButton;
    BtFillPage: TButton;
    ChBAutoFillAll: TCheckBox;
    BtNextLayout: TButton;
    CmBPrintTemplates: TComboBox;
    LbTemplate: TLabel;
    BtPrevLayout: TButton;
    GBLogo: TGroupBox;
    ChBLogoShow: TCheckBox;
    BtLogoLoad: TButton;
    ChBLogoChangePos: TCheckBox;
    ChBDiagnoses: TCheckBox;
    GBPageOrientation: TGroupBox;
    RBPortrait: TRadioButton;
    RBLandscape: TRadioButton;

  procedure FormShow       ( Sender: TObject );
  procedure FormCloseQuery ( Sender: TObject; var CanClose: Boolean );
  procedure FormResize     ( Sender: TObject ); override;
  procedure FormKeyDown    ( Sender: TObject; var Key: Word; Shift: TShiftState );

  procedure BBPrinterSetUpClick     ( Sender: TObject );
  procedure PrinterSetupDialogClose ( Sender: TObject );
  procedure TimerMinTimer           ( Sender: TObject );
  procedure EdINumChange            ( Sender: TObject );
  procedure EdINumEnter             ( Sender: TObject );
  procedure EdINumExit              ( Sender: TObject );
  procedure UDINumChanging          ( Sender: TObject; var AllowChange: Boolean );
  procedure EdFNumChange            ( Sender: TObject);
  procedure EdFNumEnter             ( Sender: TObject);
  procedure EdFNumExit              ( Sender: TObject );
  procedure UDFNumClick             ( Sender: TObject; Button: TUDBtnType );
  procedure UDFNumChanging          ( Sender: TObject; var AllowChange: Boolean );
  procedure RBPageRangeClick        ( Sender: TObject );
  procedure RBPageAllClick          ( Sender: TObject );
  procedure EdCopyCountExit         ( Sender: TObject );
  procedure EdBegPageEnter          ( Sender: TObject );
  procedure EdEndPageEnter          ( Sender: TObject );
  procedure TimerMaxTimer           ( Sender: TObject );
  procedure EdKeyDown               ( Sender: TObject; var Key: Word; Shift: TShiftState );
  procedure UDMarginsEnter          ( Sender: TObject );
  procedure BBPageFirstClick        ( Sender: TObject );
  procedure BBPagePrevClick         ( Sender: TObject );
  procedure BBPageNextClick         ( Sender: TObject );
  procedure BBPageLastClick         ( Sender: TObject );
  procedure UDPageLayoutClick       ( Sender: TObject; Button: TUDBtnType );
  procedure BtPrintClick            ( Sender: TObject );
  procedure RBPortraitClick         ( Sender: TObject );
  procedure RBLandscapeClick        ( Sender: TObject );
  procedure ChBSetMinMarginsClick  ( Sender: TObject );
  procedure ChBPatDetailsClick      ( Sender: TObject );
  procedure ChBImgDetailsClick      ( Sender: TObject );
  procedure EdReportTitleKeyDown    ( Sender: TObject; var Key: Word; Shift: TShiftState );
  procedure TBSlideFixZoomClick     ( Sender: TObject );
  procedure CmBSlideScale_7Change   ( Sender: TObject );
  procedure RFrameMouseDown( Sender: TObject; Button: TMouseButton;
                             Shift: TShiftState; X, Y: Integer );
  procedure RFrameDragOver ( Sender, Source: TObject; X, Y: Integer;
                             State: TDragState; var Accept: Boolean );
  procedure StartDragTimerTimer     ( Sender: TObject );
  procedure RFrameEndDrag( Sender, Target: TObject; X, Y: Integer );
  procedure ChBAutoFillAllClick( Sender: TObject );
  procedure BtFillAllClick( Sender: TObject );
  procedure BtClearAllClick( Sender: TObject );
  procedure BtFillPageClick( Sender: TObject );
  procedure BtClearPageClick( Sender: TObject );
  procedure PrintSlidesRFrameMouseDown( Sender: TObject; Button: TMouseButton;
                                        Shift: TShiftState; X, Y: Integer );
  procedure BtNextLayoutClick(Sender: TObject);
  procedure BtPrevLayoutClick(Sender: TObject);
  procedure CmBPrintTemplatesChange(Sender: TObject);
  procedure PrintSlidesRFramePaintBoxDblClick(Sender: TObject);
  procedure RFramePaintBoxDblClick(Sender: TObject);
  procedure PrintSlidesRFramePaintBoxDragOver(Sender, Source: TObject;
                     X, Y: Integer; State: TDragState; var Accept: Boolean);
  procedure ChBLogoShowClick(Sender: TObject);
  procedure BtLogoLoadClick(Sender: TObject);
  procedure LogoChangeOK(Sender: TObject);
  procedure LogoChangeCancel(Sender: TObject);
  procedure ChBLogoChangePosClick(Sender: TObject);

private
  SPPrinterChagedFlag : Boolean; // printer change event flag
  SPSkipINumEvent : Boolean; // skip INumTEdit ChangeEvent flag
  SPInpTEdit : TLabeledEdit; // current editing INumTEdit
  SPInpPrev  : Integer;      // current editing INumTEdit Int Value
  SPInpMax   : Integer;      // current editing INumTEdit MaxInt Value
  SPInpMin   : Integer;      // current editing INumTEdit MinInt Value

  SPSkipFNumEvent : Boolean; // skip FNumTEdit Change Event flag
  SPInpFTEdit : TLabeledEdit;// current editing FNumTEdit
  SPInpFPrev  : Double;      // current editing FNumTEdit Float Value
  SPInpFMax   : Double;      // current editing FNumTEdit MaxFloat Value
  SPInpFMin   : Double;      // current editing FNumTEdit MinFloat Value

  SPPrevDeviceRes:  TPoint;// previous device (X,Y) resolutions in DPI
  SPDeviceRes:      TPoint;// device (X,Y) resolutions in DPI
  SPPrevPaperSize: TDPoint;// previous device (X,Y) paper size in millimeters
  SPPaperSize:  TDPoint;   // device (X,Y) paper size in millimeters
  SPMinMargin:  TDPoint;   // minimal device (X,Y) margins in millimeters
  SPPrAreaSize: TDPoint;   // printable Area Size in millimeters
  SPMargins:    TFRect;    // current margins in millimeters
  SPPrevMargins:TFRect;    // margins previous to minimal

  SPLTPixMargin:  TPoint;   // Left,Top device (X,Y) margins in Pixels
  SPAreaPixSize:  TPoint;   // device (X,Y) printable Area Size in Pixels
  SPPaperPixSize: TPoint;   // device (X,Y) whole Paper Size in Pixels

  SPFloatFieldsFormat : string; // margins Format
  SPFloatFieldsDelta : Double;  // margins Delta

  SPPageRootUDComp       : TN_UDCompVis; // page Root Component
  SPPageSlidesRootUDComp : TN_UDCompVis; // slides Parent Component
  SPSlidePatRootUDComp   : TN_UDCompVis; // slide Pattern Root Component
  SPSlidePatParentPath   : string;       // slide Pattern Parent Node Path
  SPPageParamsUDComp     : TN_UDCompVis; // slide Pattern Component
  SPCurPageUsedNum : Integer; // current page Used Places Number
  SPCurPageSSInd : Integer; // current page start slide index
  SPCurPageSFInd : Integer; // current page finish slide index
  SPPageCount : Integer; // current Pages Counter
  SPCurPageNum   : Integer; // current Page Number
  SPFirstPrintPage: Integer; // First Print Page
  SPLastPrintPage : Integer; // Last Print Page

  SPPrevMaxPageSlidesCount : Integer; // prev current Page Slides Counter
  SPMaxPageSlidesCount: Integer;  // current Page Slides Counter
//  SPCurPageSlidesCount: Integer; // current Page Slides Counter
  SPPageSlidesRCount: Integer;   // current Page Slides Rows Counter
  SPPageSlidesCCount: Integer;   // current Page Slides Cols Counter

  SPCommonMList : THashedStringList; // aplication common attributes list for page texts macroreplace
  SPSlideMList  : THashedStringList; // current slide attributes for page slide texts macroreplace

  SPPageTextsList : TStringList;  // Name=Value StringList with Page Pattern UDComTree Texts
  SPSlideTextsList : TStringList; // Name=Value StringList with Slide Pattern UDComTree Texts
  SPWrkTextsList  : TStringList;  // Name=Value StringList used to create texts on current page

  SPPrintMode  : Boolean; // Page Draw Mode for control margins frame border in Preview mode
  SPMemIniToCurStateMode : Boolean;
  SPPrintSlidesCount : Integer;

  SPPagePlacesGroup: TN_SGComp; // Group for Page Positions Search
  SPDragMode : Integer; // 0 - no drag object, 1 - select Used Slide for, 2 - select Unused Slide for Drag
                        // 5 - Used Slide is draged, 6 - Unused Slide is draged
  SPCurDragInd     : Integer; // Index of Used Slide in SPUsedInds or Unused Slide in SPUnUsedInds
  SPPageDragStartComp : TN_UDBase;
  SPPageDragOverComp : TN_UDBase;

  SPLogoPositionRFA    : TN_RubberRectRFA;       // Change Ellipse or Rectangle by Rubber Rectangle

  SPSlidesPrintDGrid : TN_DGridArbMatr; // DGrid for handling Slide Thumbnails in PrintSlidesRFrame

  SPCurLayoutID : Integer;

  SPTemplatePageLogoCoords : TN_FRArray; // Array of Templates Logo position
  SPTemplatePageCoords : array of TN_FRArray; // Array of static layout data
  SPTemplatePageOrientation : TN_IArray;

  SPLogoUDRoot  : TN_UDCompBase;
  SPLogoUDDIB   : TN_UDCompBase;
  SPLogoUDDIBRoot : TN_UDCompBase;
  SPLogoUDFrame : TN_UDCompBase;
  SPSkipLogoRFrameRedrawAllAndShow : Boolean;
  SPSkipLogoChangePosClear : Boolean;
  SPSkipLogoChangePosCancel : Boolean;
  SPSLogoChangePosOK : Boolean;
  SPSaveTemplatesInfoToMemIni : Boolean;
  SPTemplatesInfoIsReadyToSaveToMemIni : Boolean;

  procedure SetCmBSlideScaleState();
  procedure GetPrinterInfo();
  procedure GetEDMargins();
  procedure BuildPageSlidePosComps();
  procedure InitPageCounter( ASkipShowPage : Boolean = FALSE );
  procedure RebuildControlsByPageRange();
  procedure RebuildPagesRangeToPrint( ASkipShowPage : Boolean = FALSE );
  procedure UpdateMarginsByPrinterSettings();
  procedure UpdateMarginsUpDown0;
  procedure UpdateMarginsUpDown;
  procedure SetFNumMinMax;
  procedure ShowPageByNumber( ACurPageNum : Integer );
  procedure RebuildCurPageView( );
  procedure SetUDCompTextMacroValues( UDComp: TN_UDBase;
                                      MacroTexts, MacroVaues : TStrings );
  procedure ClearSlidesPrintingFlag();
  procedure ClearPageSlideComps();
  procedure RedrawDragOverComponent( AViewState : Integer );
  procedure DrawPrintThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                           const ARect: TRect );
  procedure EnabledFillClearControls();
  procedure GetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                   AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
  procedure ClearUsedSlides( ASInd, AEInd : Integer; AMoveToBegin : Boolean );
  procedure FillUsedSlides( ASInd, AEInd, AUnUsedInd : Integer );
  procedure SetLayoutContext();
  procedure InitLogo( ALogoDIB : TN_DIBObj );
  procedure ClearLogoChangePosMode();

public
  { Public declarations }
//    SPGetGroupAttrs : TK_CMSPGetGroupAttrsFunc;

  SPUDSlides : TN_UDCMSArray;  // printing Slides array
  SPPUDSlides : TN_UDCMSArray;  // printed Slides array
  SPSlidesCount : Integer;      // printed Slides Counter
  SPStudiesOnlyFlag : Boolean;

  SPUsedInds   : TN_IArray;  // printing Slides Used Indexes array
  SPUnUsedInds : TN_IArray;  // printing Slides Unused Indexes array
  SPUnUsedIndsB: TN_IArray;  // printing Slides Unused Indexes array

//  SPGetSlideAttrs : TK_CMSPGetSlideAttrsFunc;
  procedure InitRFrameCoords;
  procedure PreparePrintList( APrintList : TN_UDCMSArray );
  procedure InitPreview();
//  procedure SetSlidesList( APUObj : Pointer; AUStep, AUCount : Integer  );
  procedure CurStateToMemIni (); override;
  procedure MemIniToCurState (); override;
end;

var
  K_FormCMPrint1: TK_FormCMPrint1;

implementation

{$R *.dfm}
uses
  Printers, Math, Types,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  System.Contnrs,
{$IFEND CompilerVersion >= 26.0}
  N_Lib2, N_Lib1, N_Lib0, N_ButtonsF,
  N_Gra0, N_Gra1, N_GCont, N_CMResF, N_CompCL, N_Comp1, N_CMMain5F, N_CM1,
  N_ClassRef,
  K_CLib0, K_CLib, K_Script1, K_UDT2, K_CML1F, K_VFunc, K_RImage;

const TemplateSectPref = 'CMS_Template' ;

//***********************************  TK_FormCMPrint.FormShow  ******
//
procedure TK_FormCMPrint1.FormShow(Sender: TObject);
var
  PLInd : Integer;
  PLSectname, PLCapt : String;
  PLItem, PLItemCount, PLItemCountPrev : Integer;
  PLItemVal : string;
  PLMemIni : TMemIniFile;
  PL1 : TStringList;
  PLTableAutoAdd : Boolean;

begin
  SPWrkTextsList  := TStringList.Create;
// Moved from FormCreate
  SPFloatFieldsFormat := '%.1f';
//  SPFloatFieldsDelta := 0.1;
  SPFloatFieldsDelta := 1;

  RFrame.RFrActionFlags := RFrame.RFrActionFlags - [rfafShowCoords]; // RFrameActions control Flags
  RFrame.RFrActionFlags := RFrame.RFrActionFlags + [rfafZoomByPMKeys]; // Zoom by "+" and '-' keys
  RFrame.RFCenterInDst := TRUE;

  // Init Components Context
  SPPageRootUDComp       := TN_UDCompVis(K_CMEDAccess.ArchPrnPageRoot);
  SPPageSlidesRootUDComp := TN_UDCompVis(K_CMEDAccess.ArchPrnPageSlidesRoot);
  SPPageParamsUDComp     := TN_UDCompVis(K_CMEDAccess.ArchPrnPageParams);
  SPSlidePatRootUDComp   := TN_UDCompVis(K_CMEDAccess.ArchPrnSlidePatRoot);
  SPSlidePatParentPath   := 'SlideParent\SlidePosScale';

  RFrame.RFrInitByComp( SPPageRootUDComp );
  RFrame.DstBackColor := ColorToRGB( RFrame.PaintBox.Color );
  RFrame.RFGetActionByClass( N_ActZoom ).ActEnabled := True;

  SPPageTextsList := TStringList.Create;
//  N_CurMemIni.ReadSectionValues( 'CMSPrintPageTexts', SPPageTextsList );
  SPPageTextsList.Assign( K_CMSPrintPageTexts );
  K_ReplaceStringsVaues( SPPageTextsList, 0, K_CML1Form.LLLPrintPageTexts.Items );

  SPSlideTextsList := TStringList.Create;
//  N_CurMemIni.ReadSectionValues( 'CMSPrintSlideTexts', SPSlideTextsList );
  SPSlideTextsList.Assign( K_CMSPrintSlideTexts );
  K_ReplaceStringsVaues( SPSlideTextsList, 0, K_CML1Form.LLLPrintSlideTexts.Items );

  SPCommonMList := THashedStringList.Create;
  SPSlideMList := THashedStringList.Create;
// this code is moved from Print Action (CommonAttrs=SPCommonMList)
  K_CMEDAccess.EDAGetPatientMacroInfo( -1, SPCommonMList, True );
  K_CMEDAccess.EDAGetProviderMacroInfo( -1, SPCommonMList, true );
  K_CMEDAccess.EDAGetLocationMacroInfo( -1, SPCommonMList, true );

// end of  Moved from FormCreate

//  WindowProc := OwnWndProc;

  SPPagePlacesGroup := TN_SGComp.Create( RFrame );
  with SPPagePlacesGroup do
  begin
    GName := 'PPGroup';
    PixSearchSize := 5;
  end;
  RFrame.RFSGroups.Add( SPPagePlacesGroup );
  RFrame.OnMouseDownProcObj := RFrameMouseDown;

  SPLogoPositionRFA := TN_RubberRectRFA(SPPagePlacesGroup.SetAction( N_ActRubberRect, 0, -1, 0 ));
  with SPLogoPositionRFA do
  begin
    ActName := 'LogoPos';
    ActEnabled := False;
    ActMaxUrect := N_CMDIBURect;
    RRMinPixSize := Point(5,5);
    RRConP2UComp := SPPageRootUDComp;
    RROnOKProcObj := LogoChangeOK;
    RROnCancelProcObj := LogoChangeCancel;
  end; // with SPLogoPositionRFA do

  PrintSlidesRFrame.OnMouseDownProcObj := PrintSlidesRFrameMouseDown;

  UpdateMarginsByPrinterSettings();
  UpdateMarginsUpDown();

  SPSlidesPrintDGrid  := TN_DGridArbMatr.Create2( PrintSlidesRFrame, GetThumbSize );
  with SPSlidesPrintDGrid do
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

    DGDrawItemProcObj := DrawPrintThumb;
//    DGExtExecProcObj  := N_CMResForm.ThumbsRFrameExecute;

    PrintSlidesRFrame.DstBackColor := DGBackColor;
    PrintSlidesRFrame.RFDebName := 'PrintSlides';
    Windows.SetStretchBltMode( PrintSlidesRFrame.OCanv.HMDC, HALFTONE );
  end; // with CMMFThumbsDGrid do

/////////////////////////////////////////
// Prepare Templates Info
//
  //////////////////////////////////
  // Templates External Init
  //
  if (K_CMGAModePrintTemplatesFName = '') and K_CMGAModeFlag then
    K_CMGAModePrintTemplatesFName := N_MemIniToString( 'CMS_UserDeb', 'PrintTemplatesFName', '' );
  if K_CMGAModePrintTemplatesFName <> '' then
  begin // Init Templates by given file
    PL1 := TStringList.Create;
    if K_VFLoadStrings1( K_ExpandFileName(K_CMGAModePrintTemplatesFName), PL1,  PLInd ) <> '' then
     // Loading Templates Error
      K_CMShowMessageDlg( 'Error loading file ' + K_CMGAModePrintTemplatesFName, mtWarning )
    else
    begin // Loading Templates OK
//    K_CMGAModePrintTemplatesSaveFlag := TRUE; // To Save Print Templates to Global Context

      PLMemIni := TMemIniFile.Create('');
      PLMemIni.SetStrings(PL1);
      N_Dump1Str( 'Print Temlates from ' + K_CMGAModePrintTemplatesFName +
                  #13#10 + PL1.Text );

      // New Templates state to CurMemIni Loop
      PLInd := -1;
      while TRUE do
      begin
        Inc(PLInd);
        PLSectname := format( TemplateSectPref+'%d', [PLInd] );
//        N_CurMemIni.EraseSection( PLSectname );
        // Copy Section to MemIni
        PLMemIni.ReadSectionValues( PLSectname, PL1 );
        if PL1.Count = 0 then
        begin
          if PLInd > 0 then
            break;
        end
        else
        begin
          PLItemCountPrev := N_MemIniToInt( PLSectname, 'Count', 0 );
          K_AddStringsToMemIniSection( N_CurMemIni, PLSectname, PL1 );
          PLItemCount := N_MemIniToInt( PLSectname, 'Count', 0 );
          for PLItem := PLItemCount + 1 to PLItemCountPrev do
            N_CurMemIni.DeleteKey( PLSectname, IntToStr(PLItem) );
        end;
      end; // while TRUE do

      PLMemIni.Free;

      // Clear Prevouse CurMemIni Templates that are not reloaded by new ones
      while TRUE do
      begin
        N_CurMemIni.EraseSection( PLSectname );
        Inc(PLInd);
        PLSectname := format( TemplateSectPref+'%d', [PLInd] );
        N_CurMemIni.ReadSectionValues( PLSectname, PL1 );
        if PL1.Count = 0 then break;
      end; // while TRUE do

//      SPSaveTemplatesInfoToMemIni := TRUE; // to save
      SPTemplatesInfoIsReadyToSaveToMemIni := TRUE;
    end; // Loading Layouts OK
    PL1.Free;
  end; // if PLInitFName <> '' then
  //
  // Templates External Init
  //////////////////////////////////

  //////////////////////////////////
  // Get Templates Info from CurMemIni
  //
  PLInd := -1;
  CmBPrintTemplates.Items.BeginUpdate;
  CmBPrintTemplates.Items.Clear;
  PLTableAutoAdd := FALSE;
  while TRUE do
  begin
    Inc(PLInd);
    PLSectname := format( TemplateSectPref+'%d', [PLInd] );
    PLCapt := N_MemIniToString( PLSectname, 'Caption', '' );
    if PLCapt = '' then
    begin
      if PLInd = 0 then
      begin
      // Auto Add Table Layout
        PLCapt := 'Table';
        PLTableAutoAdd := TRUE;
      end
      else
        break;
    end;
    CmBPrintTemplates.Items.Add( PLCapt );
  end;
  CmBPrintTemplates.Items.EndUpdate;

//  CmBPrintTemplates.Items.Clear; // debug
  if (CmBPrintTemplates.Items.Count > 1) or
     ((CmBPrintTemplates.Items.Count = 1) and not PLTableAutoAdd) then
  begin
    SetLength( SPTemplatePageOrientation, CmBPrintTemplates.Items.Count );
    SetLength( SPTemplatePageCoords, CmBPrintTemplates.Items.Count - 1 );
    SetLength( SPTemplatePageLogoCoords, CmBPrintTemplates.Items.Count );

//    SPTemplatePageOrientation[0] := 2;
    for PLInd := 0 to CmBPrintTemplates.Items.Count - 1 do
    begin
      PLSectname := format( TemplateSectPref+'%d', [PLInd] );
      SPTemplatePageOrientation[PLInd] := N_MemIniToInt( PLSectname, 'PageOrientation', 2 );

      PLItemVal := N_MemIniToString( PLSectname, 'Logo', '' );
      if PLItemVal = '' then
        SPTemplatePageLogoCoords[PLInd] := FRect(1,1,8,8)
      else
        SPTemplatePageLogoCoords[PLInd] := N_ScanFRect(PLItemVal);

      if PLInd = 0 then Continue;

      PLItemCount := N_MemIniToInt( PLSectname, 'Count', 0 );
      if PLItemCount = 0 then Continue;

      SetLength( SPTemplatePageCoords[PLInd -1], PLItemCount );
      for PLItem := 1 to PLItemCount do
      begin
        PLItemVal := N_MemIniToString( PLSectname, IntToStr(PLItem), '' );
        SPTemplatePageCoords[PLInd - 1][PLItem - 1] := N_ScanFRect(PLItemVal);
      end; // for PLItem := 1 to PLItemCount do
    end; // for PLInd := 1 to CmBPrintTemplates.Items.Count - 1 do
  end
  //
  // Get Templates Info from CurMemIni
  //////////////////////////////////
  else
  begin
  //////////////////////////////////
  // Set Templates by Constants
  //
    SPSaveTemplatesInfoToMemIni := TRUE; // to save
    SPTemplatesInfoIsReadyToSaveToMemIni := FALSE;
    N_CurMemIni.EraseSection( TemplateSectPref+'0' ); // Clear MemIni Table Description


    CmBPrintTemplates.Items.BeginUpdate;
//    CmBPrintTemplates.Clear;
    if CmBPrintTemplates.Items.Count = 0 then // precaution
      CmBPrintTemplates.Items.Add('Table');
    // Set Layouts caption list
    CmBPrintTemplates.Items.Add('4VH Portrait / Landscape');
    CmBPrintTemplates.Items.Add('2H 4V 2H Portrait');
    CmBPrintTemplates.Items.Add('8VH Portrait / Landscape');
    CmBPrintTemplates.Items.Add('1C 8H Landscape');
    CmBPrintTemplates.Items.Add('1C 3H 2V 3H Landscape');
    CmBPrintTemplates.Items.Add('1C 2H 2V 2H Portrait');
    CmBPrintTemplates.Items.EndUpdate;

    // Set Page Orientation Data
    // 0 - Portrait only 1 - Landscape only 2 - Portrait and Landscape
    SetLength( SPTemplatePageOrientation, 7 );
    SPTemplatePageOrientation[0] := 2; // Table
    SPTemplatePageOrientation[1] := 2; // 4VH Portrait / Landscape
    SPTemplatePageOrientation[2] := 0; // 2H 4V 2H Portrait
    SPTemplatePageOrientation[3] := 2; // 8VH Portrait / Landscape
    SPTemplatePageOrientation[4] := 1; // 1C 8H Landscape
    SPTemplatePageOrientation[5] := 1; // 1C 3H 2V 3H Landscape
    SPTemplatePageOrientation[6] := 0; // 1C 2H 2V 2H Portrait

    SetLength( SPTemplatePageLogoCoords, 7 );
    for PLInd := 0 to High(SPTemplatePageLogoCoords) do
      SPTemplatePageLogoCoords[PLInd] := FRect(1,1,8,8);
    SPTemplatePageLogoCoords[3] := FRect(42,42,16,16); // 8 vertival/horizontal

    SetLength( SPTemplatePageCoords, 6 );
    // 4VH Portrait / Landscape
    SetLength(SPTemplatePageCoords[0], 4 );
    SPTemplatePageCoords[0][0] := FRect(10, 0,35,45);
    SPTemplatePageCoords[0][1] := FRect(55, 0,35,45);
    SPTemplatePageCoords[0][2] := FRect(10,50,35,45);
    SPTemplatePageCoords[0][3] := FRect(55,50,35,45);

    // 2H 4V 2H Portrait
    SetLength(SPTemplatePageCoords[1], 8 );
    SPTemplatePageCoords[1][0] := FRect( 0,    6,40,20);
    SPTemplatePageCoords[1][1] := FRect(60,    6,40,20);
    SPTemplatePageCoords[1][2] := FRect( 0,   32,24,30);
    SPTemplatePageCoords[1][3] := FRect(25.33,32,24,30);
    SPTemplatePageCoords[1][4] := FRect(50.66,32,24,30);
    SPTemplatePageCoords[1][5] := FRect(76,   32,24,30);
    SPTemplatePageCoords[1][6] := FRect( 0,   68,40,20);
    SPTemplatePageCoords[1][7] := FRect(60,   68,40,20);

    // 8VH Portrait / Landscape
    SetLength(SPTemplatePageCoords[2], 8 );
    SPTemplatePageCoords[2][0] := FRect( 0,    0,30,30);
    SPTemplatePageCoords[2][1] := FRect(35,    0,30,30);
    SPTemplatePageCoords[2][2] := FRect(70,    0,30,30);
    SPTemplatePageCoords[2][3] := FRect( 0,   35,30,30);
    SPTemplatePageCoords[2][4] := FRect(70,   35,30,30);
    SPTemplatePageCoords[2][5] := FRect( 0,   70,30,30);
    SPTemplatePageCoords[2][6] := FRect(35,   70,30,30);
    SPTemplatePageCoords[2][7] := FRect(70,   70,30,30);

    // 1C 8H Landscape
    SetLength(SPTemplatePageCoords[3], 9 );
    SPTemplatePageCoords[3][0] := FRect(37.5,28.5,25,43);
    SPTemplatePageCoords[3][1] := FRect( 9,   0,  24,25);
    SPTemplatePageCoords[3][2] := FRect(38,   0,  24,25);
    SPTemplatePageCoords[3][3] := FRect(67,   0,  24,25);
    SPTemplatePageCoords[3][4] := FRect( 9,37.5,  24,25);
    SPTemplatePageCoords[3][5] := FRect(67,37.5,  24,25);
    SPTemplatePageCoords[3][6] := FRect( 9,  75,  24,25);
    SPTemplatePageCoords[3][7] := FRect(38,  75,  24,25);
    SPTemplatePageCoords[3][8] := FRect(67,  75,  24,25);

    // 1C 3H 2V 3H Landscape
    SetLength(SPTemplatePageCoords[4], 9 );
    SPTemplatePageCoords[4][0] := FRect(38,   29,  24,   42);
    SPTemplatePageCoords[4][1] := FRect(14,    0,  24,   25);
    SPTemplatePageCoords[4][2] := FRect(38,    0,  24,   25);
    SPTemplatePageCoords[4][3] := FRect(62,    0,  24,   25);
    SPTemplatePageCoords[4][4] := FRect(19,   30,  13.33,40);
    SPTemplatePageCoords[4][5] := FRect(67.66,30,  13.33,40);
    SPTemplatePageCoords[4][6] := FRect(14,   75,  24,   25);
    SPTemplatePageCoords[4][7] := FRect(38,   75,  24,   25);
    SPTemplatePageCoords[4][8] := FRect(62,   75,  24,   25);

    // 1C 2H 2V 2H Portrait
    SetLength(SPTemplatePageCoords[5], 7 );
    SPTemplatePageCoords[5][0] := FRect(28,   34,  44,   32);
    SPTemplatePageCoords[5][1] := FRect( 0,   10,  36,   17);
    SPTemplatePageCoords[5][2] := FRect(64,   10,  36,   17);
    SPTemplatePageCoords[5][3] := FRect( 5,   35,  20,   30);
    SPTemplatePageCoords[5][4] := FRect(75,   35,  20,   30);
    SPTemplatePageCoords[5][5] := FRect( 0,   73,  36,   17);
    SPTemplatePageCoords[5][6] := FRect(64,   73,  36,   17);

  //
  // Set Templates by Constants
  //////////////////////////////////
  end;
//
// Prepare Templates Info
/////////////////////////////////////////

  InitLogo( K_CMEDAccess.EDAPrintLogoGetDIB() );

  InitPreview();

  RBPageAll.Checked := true;
  RBPageAllClick( nil );

  CmBPrintTemplates.SetFocus();
  //  BtPrint.SetFocus();
end; // end of TK_FormCMPrint.FormShow

//***********************************  TK_FormCMPrint.RebuildCurPageView ***
//  Before real Form close action to free allocated objects
//
procedure TK_FormCMPrint1.FormCloseQuery( Sender: TObject;
                                          var CanClose: Boolean );
begin
  SPCommonMList.Free;
  SPSlideMList.Free;
  SPPageTextsList.Free;
  SPSlideTextsList.Free;
  ClearSlidesPrintingFlag();
  ClearPageSlideComps();

//!!  SPPageSlidesRootUDComp.ClearChilds();
  RFrame.RFFreeObjects();
  SPWrkTextsList.Free;
  SPSlidesPrintDGrid.Free;
  PrintSlidesRFrame.RFFreeObjects();
  if SPLogoUDDIB <> nil then
    FreeAndNil( TN_UDDIB(SPLogoUDDIB).DIBObj ); // Free Logo DIBObj
end; // end of TK_FormCMPrint.RebuildCurPageView

//***********************************  TK_FormCMPrint.FormResize ***
//
procedure TK_FormCMPrint1.FormResize(Sender: TObject);
begin
  inherited;

//  GBPageMargins.Top :=
//  ( GBPrinter.Top - GBPageLayout.Top +
//    GBPageLayout.Height - GBPageMargins.Height ) div 2;
//  PnPageScroll0.Left :=
//       (PnPageScroll.Width + TBPageView.Width - PnPageScroll0.Width) div 2;
  PnPageScroll0.Left := CmBSlideScale_7.Left + CmBSlideScale_7.Width + 10;
//  PnPageScroll0.Width := PnPageScroll.Width - PnPageScroll0.Left - 10;
  LbPageNum.Left := BBPagePrev.Left + BBPagePrev.Width + 3;
  LbPageNum.Width := BBPageNext.Left - LbPageNum.Left - 3;

end; // end of TK_FormCMPrint.FormResize

//*************************************** TK_FormCMPrint.BBPrinterSetUpClick
//
procedure TK_FormCMPrint1.BBPrinterSetUpClick(Sender: TObject);
begin
  PrinterSetupDialog.Execute();
end; // end of TK_FormCMPrint.BBPrinterSetUpClick

//*************************************** TK_FormMVMSOExport.PrinterSetupDialogClose
// Printer Setup Dialog Close Event Handler
//
// Setting Current Info about Printer is impossible inside this handler
// because Printer object was not yet changed by Delphi.
// Real setting will take place by Self.GetPrinterInfo() method, which
// would be called from OnTimer event handler (see just bellow)
//
procedure TK_FormCMPrint1.PrinterSetupDialogClose( Sender: TObject );
begin
  TimerMin.Enabled := True;
  SPPrinterChagedFlag := true;
end; //*** end of TK_FormCMPrint.PrinterSetupDialogClose

//*************************************** TK_FormCMPrint.TimerTimer
//  Number Changing and Printer Changing Timer Control Event
//
procedure TK_FormCMPrint1.TimerMinTimer( Sender: TObject );
var
  NewVal : Double;
  ErrCode : Integer;
begin
  LogoChangeOK(nil);
  TimerMin.Enabled := False;
  if SPSkipINumEvent then
  begin
    SPSkipINumEvent := false;
    SPInpPrev := StrToIntDef( SPInpTEdit.Text, SPInpPrev );
    SPInpTEdit.Text := IntToStr( SPInpPrev );
  end;
  if SPSkipFNumEvent then
  begin
    SPSkipFNumEvent := false;
    Val( SPInpFTEdit.Text, NewVal, ErrCode );
    if ErrCode > 0 then
    begin
      SPInpFTEdit.Text := format( SPFloatFieldsFormat, [SPInpFPrev] );
    end
    else
    begin
      SPInpFPrev := NewVal;
//    SPInpFPrev := StrToFloatDef( SPInpFTEdit.Text, SPInpFPrev );
      SetFNumMinMax();
//    SPInpFPrev := Max( SPInpFMin, SPInpFPrev );
//      SPInpFPrev := Min( SPInpFMax, SPInpFPrev );
      if SPInpFPrev > SPInpFMax then
      begin
        SPInpFPrev := 0.95 * SPInpFMax;
        SPInpFTEdit.Text := format( SPFloatFieldsFormat, [SPInpFPrev] );
      end;
      UpdateMarginsUpDown0();
      SPSkipFNumEvent := false;
      GetEDMargins();
      if ChBLogoChangePos.Checked then
        LogoChangeOK(Sender)
      else
        RebuildCurPageView( );
    end;
  end;
  if SPPrinterChagedFlag then
  begin
    SPPrinterChagedFlag := false;
    UpdateMarginsByPrinterSettings();
    UpdateMarginsUpDown();
    ShowPageByNumber( -3 ); // Rebuild Page
  end;
end; //*** end of TK_FormCMPrint.TimerMinTimer

//*************************************** TK_FormCMPrint.TimerMaxTimer
//  Finish Editing Timer Control Event
//
procedure TK_FormCMPrint1.TimerMaxTimer(Sender: TObject);
begin
  TimerMax.Enabled := false;
  if SPInpTEdit = nil then Exit;
  SPInpTEdit.Parent.SetFocus();
end; //*** end of TK_FormCMPrint.TimerMaxTimer


//***********************************  TK_FormCMPrint.CurStateToMemIni  ******
//
procedure TK_FormCMPrint1.CurStateToMemIni();
var
  FName : string;
  PLSectname : string;
  i, j : Integer;
begin
  FName := Name;
  if Name[Length(Name)] = '1' then  // "K_FormCMPrint1" >> "K_FormCMPrint"
    SetLength( FName, Length(Name) - 1 );

  inherited;
  // Temp Code for new PrintManager

  N_StringToMemIni  ( FName+'State', 'CopyCount',    EdCopyCount.Text );
  N_StringToMemIni  ( FName+'State', 'MarginTop',    EdMarginTop.Text );
  N_StringToMemIni  ( FName+'State', 'MarginBottom', EdMarginBottom.Text );
  N_StringToMemIni  ( FName+'State', 'MarginLeft',   EdMarginLeft.Text );
  N_StringToMemIni  ( FName+'State', 'MarginRight',  EdMarginRight.Text );

  if not SPStudiesOnlyFlag then
  begin
    N_StringToMemIni  ( FName+'State', 'ColCount',     EdColCount.Text );
    N_StringToMemIni  ( FName+'State', 'RowCount',     EdRowCount.Text );
  end;

//  N_BoolToMemIni    ( FName+'State', 'HCenter',      ChBHCenter.Checked );
//  N_BoolToMemIni    ( FName+'State', 'VCenter',      ChBVCenter.Checked );
  N_BoolToMemIni    ( FName+'State', 'PatDetails',   ChBPatDetails.Checked );
  N_BoolToMemIni    ( FName+'State', 'ProvDetails',  ChBProvDetails.Checked );
  N_BoolToMemIni    ( FName+'State', 'ImgDetails',   ChBImgDetails.Checked );
  N_BoolToMemIni    ( FName+'State', 'Diagnoses',    ChBDiagnoses.Checked );

  N_StringToMemIni  ( FName+'State', 'PageTitle',    EdReportTitle.Text );
//  N_BoolToMemIni    ( FName+'State', 'SlideFixZoom', TBSlideFixZoom1.Down );
  N_IntToMemIni     ( FName+'State', 'ScaleIndex',   CmBSlideScale_7.ItemIndex );
  N_BoolToMemIni    ( FName+'State', 'PrintPageHeader',   ChBPrintPageHeader.Checked );
  N_BoolToMemIni    ( FName+'State', 'PrintPageNumber',   ChBPrintPageNumber.Checked );

  if not SPStudiesOnlyFlag then
  begin
    N_BoolToMemIni    ( FName+'State', 'AutoFillAll',  ChBAutoFillAll.Checked );
    N_IntToMemIni     ( FName+'State', 'PageLayoutID', SPCurLayoutID );
  end;

  N_BoolToMemIni    ( FName+'State', 'LogoShow',   ChBLogoShow.Checked );

  if SPSaveTemplatesInfoToMemIni then
  begin // Save Templates Info to MemIni

    if not SPTemplatesInfoIsReadyToSaveToMemIni then
    // Prepare updated Print Temlates MemIni Context
      for i := 0 to CmBPrintTemplates.Items.Count - 1 do
      begin
        PLSectname := format( TemplateSectPref+'%d', [i] );
        N_StringToMemIni( PLSectname, 'Caption', CmBPrintTemplates.Items[i] );
        N_IntToMemIni( PLSectname, 'PageOrientation',   SPTemplatePageOrientation[i] );
        with SPTemplatePageLogoCoords[i] do
          N_StringToMemIni( PLSectname, 'Logo', format( '%.6g %.6g %.6g %.6g',
                                                    [Left,Top,Right,Bottom] ) );
        if i = 0 then Continue;

        N_IntToMemIni( PLSectname, 'Count', Length(SPTemplatePageCoords[i - 1]) );
        for j := 1 to Length(SPTemplatePageCoords[i - 1]) do
          with SPTemplatePageCoords[i - 1][j - 1] do
            N_StringToMemIni( PLSectname, IntToStr(j), format( '%.6g %.6g %.6g %.6g',
                                                      [Left,Top,Right,Bottom] ) );
      end; // for i := 0 to CmBPrintTemplates.Items.Count - 1 do

     K_CMGAModePrintTemplatesSaveFlag := K_CMGAModePrintTemplatesFName <> '';
     if not K_CMGAModePrintTemplatesSaveFlag then
     // Save Print Templates MemIni now
       K_CMEDAccess.EDAPrintLocMemIniSave;
     // if K_CMGAModePrintTemplatesSaveFlag then Print Temlates MemIni will be saved later
  end; // if SPSaveTemplatesInfoToMemIni do

end; // end of TK_FormCMPrint.CurStateToMemIni

//***********************************  TK_FormCMPrint.MemIniToCurState  ******
//
procedure TK_FormCMPrint1.MemIniToCurState();
var
  FName : string;
begin
  SPMemIniToCurStateMode := TRUE;

  inherited;
  // Temp Code for new PrintManager
  FName := Name;
  if Name[Length(Name)] = '1' then
    SetLength( FName, Length(Name) - 1 );

  EdCopyCount.Text    := N_MemIniToString( FName+'State', 'CopyCount', '1' );
  UDCopyCount.Position := StrToIntDef( EdCopyCount.Text, 1 );
  Printer.Copies := UDCopyCount.Position;
  EdMarginTop.Text    := N_MemIniToString( FName+'State', 'MarginTop', '20.0' );
  EdMarginBottom.Text := N_MemIniToString( FName+'State', 'MarginBottom', '20.0' );
  EdMarginLeft.Text   := N_MemIniToString( FName+'State', 'MarginLeft', '20.0' );
  EdMarginRight.Text  := N_MemIniToString( FName+'State', 'MarginRight', '20.0' );
  if not SPStudiesOnlyFlag then
  begin
    EdColCount.Text     := N_MemIniToString( FName+'State', 'ColCount', '2' );
    UDColCount.Position := StrToIntDef( EdColCount.Text, 20 );
    EdRowCount.Text     := N_MemIniToString( FName+'State', 'RowCount', '2' );
    UDRowCount.Position := StrToIntDef( EdRowCount.Text, 20 );
  end
  else
  begin
    EdColCount.Text     := '1';
    UDColCount.Position :=  1;
    EdRowCount.Text     := '1';
    UDRowCount.Position :=  1;
  end;
//  ChBHCenter.Checked := N_MemIniToBool( FName+'State', 'HCenter', TRUE );
//  ChBVCenter.Checked := N_MemIniToBool( FName+'State', 'VCenter', TRUE );
  ChBPatDetails.Checked := N_MemIniToBool( FName+'State', 'PatDetails', TRUE );
  ChBProvDetails.Checked := N_MemIniToBool( FName+'State', 'ProvDetails', TRUE );
  ChBImgDetails.Checked := N_MemIniToBool( FName+'State', 'ImgDetails', TRUE );
  ChBDiagnoses.Checked  := N_MemIniToBool( FName+'State', 'Diagnoses', TRUE );
  EdReportTitle.Text   := N_MemIniToString( FName+'State', 'PageTitle', '' );
//  TBSlideFixZoom1.Down := N_MemIniToBool( FName+'State', 'SlideFixZoom', FALSE );
  ChBPrintPageHeader.Checked := N_MemIniToBool( FName+'State', 'PrintPageHeader', FALSE );
  ChBPrintPageNumber.Checked := N_MemIniToBool( FName+'State', 'PrintPageNumber', TRUE );

  TBSlideFixZoom1.Down := FALSE;
  TBSlideFitToView.Down := not TBSlideFixZoom1.Down;

//  _CmBSlideScale.Enabled := TBSlideFixZoom1.Down;
  SetCmBSlideScaleState();
  LbSlideScale.Enabled := TBSlideFixZoom1.Down;

  if not SPStudiesOnlyFlag then
  begin
    ChBAutoFillAll.Checked := N_MemIniToBool( FName+'State', 'AutoFillAll', TRUE );
    SPCurLayoutID := N_MemIniToInt( FName+'State', 'PageLayoutID', 0 );
  end
  else
  begin
    ChBAutoFillAll.Checked := TRUE;
    SPCurLayoutID := 0;
  end;

  ChBLogoShow.Checked := N_MemIniToBool( FName+'State', 'LogoShow', FALSE );

  SPMemIniToCurStateMode := FALSE;

end; // end of TK_FormCMPrint.MemIniToCurState

//***********************************  TK_FormCMPrint.EdINumChange ***
//  Integer Values Controls Change Value
//
procedure TK_FormCMPrint1.EdINumChange(Sender: TObject);
begin
  if SPSkipINumEvent then Exit;
  SPSkipINumEvent := true;
  TimerMin.Enabled := true;
  TimerMax.Enabled := false;
  TimerMax.Enabled := true;
end; // end of TK_FormCMPrint.EdINumChange

//***********************************  TK_FormCMPrint.EdINumEnter ***
//  Integer Values Controls Start Editing
//
procedure TK_FormCMPrint1.EdINumEnter( Sender: TObject );
begin
  SPSkipINumEvent := false;
  SPInpTEdit := TLabeledEdit(Sender);
  SPInpPrev := StrToIntDef( TLabeledEdit(Sender).Text, 1 );
  SPInpMax  := 0;
  SPInpMin  := 1;
end; // end of TK_FormCMPrint.EdINumEnter

//***********************************  TK_FormCMPrint.EdINumExit ***
//  Integer Values Controls Finish Editing
//
procedure TK_FormCMPrint1.EdINumExit( Sender: TObject );
begin
  TimerMax.Enabled := false;
  if SPInpMin > 0 then
    SPInpPrev := Max( SPInpMin, SPInpPrev );
  if SPInpMax > 0 then
    SPInpPrev := Min( SPInpMax, SPInpPrev );
  SPInpTEdit.Text := IntToStr( SPInpPrev );
  SPInpTEdit := nil;
end; // end of TK_FormCMPrint.EdINumExit

//***********************************  TK_FormCMPrint.UDINumChanging ***
//  Integer Values Controls Change Value
//
procedure TK_FormCMPrint1.UDINumChanging( Sender: TObject;
             var AllowChange: Boolean );
begin
  SPSkipINumEvent := true;
end; // end of TK_FormCMPrint.UDINumChanging

//***********************************  TK_FormCMPrint.EdFNumChange ***
//  Margins Controls Change Value
//
procedure TK_FormCMPrint1.EdFNumChange(Sender: TObject);
begin
  if SPSkipFNumEvent then Exit;
  SPSkipFNumEvent := true;
  TimerMin.Enabled := true;
  TimerMax.Enabled := false;
  TimerMax.Enabled := true;
end; // end of TK_FormCMPrint.EdFNumChange

//***********************************  TK_FormCMPrint.EdFNumEnter ***
//  Margins Controls Start Editing
//
procedure TK_FormCMPrint1.EdFNumEnter( Sender: TObject );
begin
  SPSkipFNumEvent := false;
  SPInpFTEdit := TLabeledEdit(Sender);
  SetFNumMinMax();
  SPInpFPrev := StrToFloatDef( TLabeledEdit(Sender).Text, SPInpFMin );
end; // end of TK_FormCMPrint.EdFNumEnter

//***********************************  TK_FormCMPrint.EdFNumExit ***
//  Margins Controls Finish Editing
//
procedure TK_FormCMPrint1.EdFNumExit( Sender: TObject );
begin
  TimerMax.Enabled := false;
  SPInpFTEdit := nil;
end; // end of TK_FormCMPrint.EdFNumExit

//***********************************  TK_FormCMPrint.UDFNumClick ***
//  Margins UpDown Controls finish changing
//
procedure TK_FormCMPrint1.UDFNumClick( Sender: TObject;
                                       Button: TUDBtnType );
var
  WFPrev  : Double;
begin
  if Button = btPrev then
    WFPrev := SPInpFPrev - SPFloatFieldsDelta
  else
    WFPrev := SPInpFPrev + SPFloatFieldsDelta;

//  SPInpFPrev := Min(SPInpFPrev, SPInpFMax);
//  SPInpFPrev := Max(SPInpFPrev, SPInpFMin);
  if (WFPrev > SPInpFMax) or
     (WFPrev < SPInpFMin)  then Exit;
  SPInpFPrev := WFPrev;
  SPInpFTEdit.Text := format( SPFloatFieldsFormat, [SPInpFPrev] );
  SPSkipFNumEvent := true;
  TimerMin.Enabled := true;
end; // end of TK_FormCMPrint.UDFNumClick

//***********************************  TK_FormCMPrint.UDFNumChanging ***
//  Margins UpDown Controls start changing
//
procedure TK_FormCMPrint1.UDFNumChanging( Sender: TObject;
             var AllowChange: Boolean );
begin
  SPSkipFNumEvent := true;
  if Sender = UDMarginRight then
    SPInpFTEdit := EdMarginRight
  else if Sender = UDMarginLeft then
    SPInpFTEdit := EdMarginLeft
  else if Sender = UDMarginTop then
    SPInpFTEdit := EdMarginTop
  else if Sender = UDMarginBottom then
    SPInpFTEdit := EdMarginBottom;
  SetFNumMinMax();
  SPInpFPrev := StrToFloatDef( SPInpFTEdit.Text, SPInpFMin );
end; // end of TK_FormCMPrint.UDFNumChanging

//***********************************  TK_FormCMPrint.EdBegPageEnter ***
//  Pages Range First Page Start Editing
//
procedure TK_FormCMPrint1.EdBegPageEnter(Sender: TObject);
begin
  EdINumEnter( Sender );
  SPInpMax  := StrToIntDef( EdEndPage.Text, SPPageCount );
  SPInpMin  := 1;
  if SPLastPrintPage <> SPInpMax then RebuildPagesRangeToPrint();
end; // end of TK_FormCMPrint.EdBegPageEnter

//***********************************  TK_FormCMPrint.EdEndPageEnter ***
//  Pages Range Last Page Start Editing
//
procedure TK_FormCMPrint1.EdEndPageEnter(Sender: TObject);
begin
  EdINumEnter( Sender );
  SPInpMax  := SPPageCount;
  SPInpMin  := StrToIntDef( EdBegPage.Text, SPPageCount );
  if SPFirstPrintPage <> SPInpMin then RebuildPagesRangeToPrint();
end; // end of TK_FormCMPrint.EdEndPageEnter

//*************************************  TK_FormCMPrint.TBSlideFixZoomClick ***
// EdReportTitle KeyDown Event Handler
//
procedure TK_FormCMPrint1.SetCmBSlideScaleState();
var
  ChangeState : Boolean;
  II : Integer;
begin
  ChangeState := CmBSlideScale_7.Enabled <> TBSlideFixZoom1.Down;
  CmBSlideScale_7.Enabled := TBSlideFixZoom1.Down;
  if ChangeState then
    with CmBSlideScale_7 do begin
      II := ItemIndex;
      if not TBSlideFixZoom1.Down then
        Items.Insert( II, '')
      else
        Items.Delete(ItemIndex);
      ItemIndex := II;
    end;
  CmBSlideScale_7.Enabled := TBSlideFixZoom1.Down;
end; // end of TK_FormCMPrint.SetCmBSlideScaleState();

//***********************************  TK_FormCMPrint.GetPrinterInfo  ******
// Get Printer Info and set DeviceRes, MinMargin, PrAreaSize, PaperSize
//
procedure TK_FormCMPrint1.GetPrinterInfo();
begin

{
  SPDeviceRes.X := Printer.PageWidth;
  SPDeviceRes.Y := GetDeviceCaps( Printer.Handle, PHYSICALWIDTH );

  SPDeviceRes.Y := SPDeviceRes.Y - GetDeviceCaps( Printer.Handle, PHYSICALOFFSETX );
  SPDeviceRes.Y := SPDeviceRes.Y - GetDeviceCaps( Printer.Handle, PHYSICALOFFSETX );
  SPDeviceRes.Y := Round( GetDeviceCaps( Printer.Handle, HORZSIZE ) *
                          GetDeviceCaps( Printer.Handle, LOGPIXELSX ) / 25.4 );
}
  //***** Set Pinter (X,Y) Resolution in device pixels
  SPDeviceRes.X := GetDeviceCaps( Printer.Handle, LOGPIXELSX );
  SPDeviceRes.Y := GetDeviceCaps( Printer.Handle, LOGPIXELSY );
//  lbResolution.Caption := Format( 'Resolution (X,Y) : %d x %d DPI',
//                                             [DeviceRes.X, DeviceRes.Y] );

  //***** Get Pinter (X,Y) Minimal Margins in millimeters
  SPMinMargin.X := 25.4 * GetDeviceCaps( Printer.Handle, PHYSICALOFFSETX ) / SPDeviceRes.X;
  SPMinMargin.Y := 25.4 * GetDeviceCaps( Printer.Handle, PHYSICALOFFSETY ) / SPDeviceRes.Y;

  //***** Get Pinter (X,Y) Printeble Area Size in millimeters
  SPPrAreaSize.X := GetDeviceCaps( Printer.Handle, HORZSIZE );
  SPPrAreaSize.Y := GetDeviceCaps( Printer.Handle, VERTSIZE );

  //***** Get Pinter (X,Y) Paper Size in millimeters
//  SPPaperSize.X := SPPrAreaSize.X + 2*SPMinMargin.X;
//  SPPaperSize.Y := SPPrAreaSize.Y + 2*SPMinMargin.Y;
  SPPaperSize.X := 25.4 * GetDeviceCaps( Printer.Handle, PHYSICALWIDTH ) / SPDeviceRes.X;
  SPPaperSize.Y := 25.4 * GetDeviceCaps( Printer.Handle, PHYSICALHEIGHT ) / SPDeviceRes.Y;

  LbPaperSize.Caption := Format( K_CML1Form.LLLPrint1.Caption,
//                         'Paper (width, height): %.0f x %.0f mm',
                                       [SPPaperSize.X, SPPaperSize.Y] );
//  LbPaperSize.Width := LbPaperSize.Parent.Width - LbPaperSize.Left * 2;
  LbPaperSize.Width := EdPrinterName.Width;
  EdPrinterName.Text := Printer.Printers[Printer.PrinterIndex];
  EdCopyCount.Text := IntToStr( Printer.Copies );
  if Printer.Orientation = poPortrait then
  begin
    RBPortrait.Checked := true;
    RBLandscape.Checked := false;
  end
  else
  begin
    RBPortrait.Checked := false;
    RBLandscape.Checked := true;
  end;
//  Orientation
end; // end of TK_FormCMPrint.GetPrinterInfo

//***********************************  TK_FormCMPrint.GetEDMargins ***
// Get Margins from edit controls
//
procedure TK_FormCMPrint1.GetEDMargins();
begin
  SPMargins.Left := StrToFloatDef( EdMarginLeft.Text, SPMargins.Left );
  SPMargins.Right := StrToFloatDef( EdMarginRight.Text, SPMargins.Right );
  SPMargins.Top := StrToFloatDef( EdMarginTop.Text, SPMargins.Top );
  SPMargins.Bottom := StrToFloatDef( EdMarginBottom.Text, SPMargins.Bottom );
end; // end of procedure TK_FormCMPrint.GetEDMargins

//*********************************** TK_FormCMPrint.BuildPageSlidePosComps ***
// Get Table Layuot parameters from edit controls
//
procedure TK_FormCMPrint1.BuildPageSlidePosComps();
var
  ColCount, RowCount, ColDelta : Integer;
  Y0, Y1, X0, X1 : Float;
  ic, ir, n : Integer;
  UDSlideRoot : TN_UDCompVis;
begin
  //  Build Page Slides Components Tree
  ClearSlidesPrintingFlag();
  ClearPageSlideComps();

//  SPPageSlidesRootUDComp.ClearChilds();
  // Set Logo Position
  with TN_UDCompVis( SPLogoUDRoot ).PCCS^ do
  begin // Set Logo Coords
    BPCoords := SPTemplatePageLogoCoords[SPCurLayoutID].TopLeft;
    SRSize   := SPTemplatePageLogoCoords[SPCurLayoutID].BottomRight;
  end;

  if SPCurLayoutID = 0 then
  begin // Table Page Layout
    // Prepare Current Table Layout params
    ColCount := SPPageSlidesCCount;
    RowCount := SPPageSlidesRCount;
    if (SPCurPageSSInd = 0)                  and   // first page
       (SPMaxPageSlidesCount > SPSlidesCount) then  // not full last page
    begin
    // Rebuild Current Layout if Slides number is less then PageLayout capacity
      ColCount := Round( sqrt( SPSlidesCount ) );
      RowCount := 0;
      if ColCount <> 0 then // precaution
        RowCount := Round( SPSlidesCount/ColCount );

      if RowCount * ColCount < SPSlidesCount then
        RowCount := RowCount + 1;
      if (RBPortrait.Checked  and (ColCount > RowCount)) or
         (RBLandscape.Checked and (RowCount > ColCount)) then
      begin
      // Switch Cols and Rows
        ColDelta := ColCount;
        ColCount := RowCount;
        RowCount := ColDelta;
      end;
    end;

    n := SPCurPageSSInd;
    X1 := 100 / ColCount;
    Y1 := 100 / RowCount;

    for ir := 0 to RowCount - 1 do
    begin
      // Calc Slide Root Componenet Position
      Y0 := ir * Y1;
      X0 := 0;
      ColDelta := SPCurPageSFInd + 1 - n - ColCount;
      if ColDelta < 0 then
        X0 := -ColDelta * X1 / 2;

      for ic := 0 to ColCount - 1 do
      begin
        UDSlideRoot := TN_UDCompVis( SPPageSlidesRootUDComp.AddOneChild(
                                  N_CreateSubTreeClone( SPSlidePatRootUDComp ) ) );
      // Set Slide Place Position and Size
        with UDSlideRoot.PCCS^ do
        begin
          BPCoords.X := X0 + ic * X1;
          SRSize.X := X1;
          BPCoords.Y := Y0;
          SRSize.Y := Y1;
        end;
        Inc(n);
        if n > SPCurPageSFInd then Exit;
      end; // for ic := 0 to ColCount - 1 do
    end; // for ir := 0 to RowCount - 1 do
  end   // Table Page Layout
  else
  begin // Static Page Layouts
    for n := 0 to High(SPTemplatePageCoords[SPCurLayoutID-1]) do
      with TN_UDCompVis( SPPageSlidesRootUDComp.AddOneChild(
                   N_CreateSubTreeClone( SPSlidePatRootUDComp ) ) ).PCCS^ do
      begin
        BPCoords := SPTemplatePageCoords[SPCurLayoutID-1][n].TopLeft;
        SRSize   := SPTemplatePageCoords[SPCurLayoutID-1][n].BottomRight;
      end;
  end; // Static Page Layouts

end; // procedure TK_FormCMPrint.BuildPageSlidePosComps

//****************************************** TK_FormCMPrint.InitPageCounter ***
// Get Page Layuot parameters from edit controls
//
procedure TK_FormCMPrint1.InitPageCounter( ASkipShowPage : Boolean = FALSE  );
begin
  if SPPrevMaxPageSlidesCount = SPMaxPageSlidesCount then Exit;
  SPPageCount := (SPSlidesCount + SPMaxPageSlidesCount - 1) div SPMaxPageSlidesCount;
  SPPageCount := Max( SPPageCount, 1 );
  EdBegPage.Text := '1';
  EdEndPage.Text := IntToStr(SPPageCount);

  ChBPrintPageHeader.Enabled := SPPageCount > 1;

  RebuildPagesRangeToPrint( ASkipShowPage );
end; // end of procedure TK_FormCMPrint.InitPageCounter

//******************************  TK_FormCMPrint.RebuildControlsByPageRange ***
// Rebuild Controls by Pages Range
//
procedure TK_FormCMPrint1.RebuildControlsByPageRange();
begin
  LbPageNum.Left := BBPagePrev.Left + BBPagePrev.Width + 3;
  LbPageNum.Width := BBPageNext.Left - LbPageNum.Left - 3;
//  BBPageNext.Enabled := SPCurPageNum < SPPageCount;
  BBPageNext.Enabled := SPCurPageNum < SPLastPrintPage;
  BBPageLast.Enabled := BBPageNext.Enabled;
//  BBPageFirst.Enabled := SPCurPageNum > 1;
  BBPageFirst.Enabled := SPCurPageNum > SPFirstPrintPage;
  BBPagePrev.Enabled := BBPageFirst.Enabled;
end; // end of procedure TK_FormCMPrint.RebuildControlsByPageRange

//********************************  TK_FormCMPrint.RebuildPagesRangeToPrint ***
// Rebuild Pages Range
//
procedure TK_FormCMPrint1.RebuildPagesRangeToPrint( ASkipShowPage : Boolean = FALSE );
var
  NewPageNum : Integer;
begin
  SPFirstPrintPage := 1;
  SPLastPrintPage  := SPPageCount;

  if not RBPageAll.Checked then
  begin
    SPFirstPrintPage := StrToInt( EdBegPage.Text );
    SPLastPrintPage := StrToInt( EdEndPage.Text );
  end;

  NewPageNum := SPCurPageNum;
  if NewPageNum > SPLastPrintPage then
    NewPageNum := SPLastPrintPage
  else
  if NewPageNum < SPFirstPrintPage then
    NewPageNum := SPFirstPrintPage;

  if (NewPageNum <> SPCurPageNum) and not ASkipShowPage then
  begin
    if Length(SPUsedInds) > 0 then // precation
      ShowPageByNumber( NewPageNum )
  end;
//  else
  RebuildControlsByPageRange();

end; // end of procedure TK_FormCMPrint.RebuildPagesRangeToPrint

//***********************************  TK_FormCMPrint.UpdateMarginsByPrinterSettings ***
// Update Margins by Printer Settings
//
procedure TK_FormCMPrint1.UpdateMarginsByPrinterSettings();
begin
  GetPrinterInfo(); // a precaution

  if not ChBSetMinMargins.Checked then
  begin
    GetEDMargins();
    if SPMargins.Left   < SPMinMargin.X then SPMargins.Left   := SPMinMargin.X;
    if SPMargins.Top    < SPMinMargin.Y then SPMargins.Top    := SPMinMargin.Y;
    if SPMargins.Right  < SPMinMargin.X then SPMargins.Right  := SPMinMargin.X;
    if SPMargins.Bottom < SPMinMargin.Y then SPMargins.Bottom := SPMinMargin.Y;
  end
  else
  begin
    SPMargins.TopLeft := FPoint( SPMinMargin );
    SPMargins.BottomRight := FPoint( SPMinMargin );
  end;

  if (SPMargins.Left + SPMargins.Right) > SPPaperSize.X then
  begin
    SPMargins.Left  := Round(0.5*SPPaperSize.X) - 1;
    SPMargins.Right := Round(0.5*SPPaperSize.X) - 1;
  end;

  if (SPMargins.Top + SPMargins.Bottom) > SPPaperSize.Y then
  begin
    SPMargins.Top    := Round(0.5*SPPaperSize.Y) - 1;
    SPMargins.Bottom := Round(0.5*SPPaperSize.Y) - 1;
  end;

  EdMarginLeft.Text   := format( SPFloatFieldsFormat, [SPMargins.Left] );
  EdMarginTop.Text    := Format( SPFloatFieldsFormat, [SPMargins.Top]    );
  EdMarginRight.Text  := Format( SPFloatFieldsFormat, [SPMargins.Right]  );
  EdMarginBottom.Text := Format( SPFloatFieldsFormat, [SPMargins.Bottom] );

end; // end of procedure TK_FormCMPrint.UpdateMarginsByPrinterSettings

//***********************************  TK_FormCMPrint.UpdateMarginsUpDown0 ***
// Set Margins UpDown Controls Position
//
procedure TK_FormCMPrint1.UpdateMarginsUpDown0;
begin
  UDMarginTop.Position := Round( StrToFloatDef( EdMarginTop.Text, 20 ) * 10 );
  UDMarginBottom.Position := Round( StrToFloatDef( EdMarginBottom.Text, 20 ) * 10 );
  UDMarginLeft.Position := Round( StrToFloatDef( EdMarginLeft.Text, 20 ) * 10 );
  UDMarginRight.Position := Round( StrToFloatDef( EdMarginRight.Text, 20 ) * 10 );
end; // end of TK_FormCMPrint.UpdateMarginsUpDown0

//***********************************  TK_FormCMPrint.UpdateMarginsUpDown ***
// Set Margins UpDown Controls Limits
//
procedure TK_FormCMPrint1.UpdateMarginsUpDown;
begin
  UDMarginRight.Min  := Round(SPMinMargin.X * 10);
  UDMarginLeft.Min   := UDMarginRight.Min;

  UDMarginRight.Max  := Round( 5 * SPPaperSize.X );
  UDMarginLeft.Max   := UDMarginRight.Max;

  UDMarginTop.Min    := Round(SPMinMargin.Y * 10);
  UDMarginBottom.Min := UDMarginTop.Min;

  UDMarginTop.Max    := Round( 5 * SPPaperSize.Y );
  UDMarginBottom.Max := UDMarginTop.Max;
end; // end of TK_FormCMPrint.UpdateMarginsUpDown

//***********************************  TK_FormCMPrint.SetFNumMinMax ***
// Set Margins Min/Max for Edit Controls
//
procedure TK_FormCMPrint1.SetFNumMinMax;
begin
  if SPInpFTEdit = nil then Exit;
  if (SPInpFTEdit = EdMarginLeft) or (SPInpFTEdit = EdMarginRight) then begin
    SPInpFMin := SPMinMargin.X;
    SPInpFMax := SPPaperSize.X;
  end else begin
    SPInpFMin := SPMinMargin.Y;
    SPInpFMax := SPPaperSize.Y;
  end;
end; // end of TK_FormCMPrint.SetFNumMinMax

//***********************************  TK_FormCMPrint.RBPageRangeClick ***
//  Set Print Given Pages Range Mode
//
procedure TK_FormCMPrint1.RBPageRangeClick(Sender: TObject);
begin
  RBPageAll.Checked := false;
  EdBegPage.Enabled := true;
  EdBegPage.Color := $00A2FFFF;
  EdEndPage.Enabled := true;
  EdEndPage.Color := $00A2FFFF;
  RebuildPagesRangeToPrint();
end; // end of TK_FormCMPrint.RBPageRangeClick

//***********************************  TK_FormCMPrint.RBPageAllClick ***
//  Set Print All Pages Mode
//
procedure TK_FormCMPrint1.RBPageAllClick(Sender: TObject);
begin
  RBPageRange.Checked := false;
  EdBegPage.Enabled := false;
  EdBegPage.Color := $00FFFFFF;
  EdEndPage.Enabled := false;
  EdEndPage.Color := $00FFFFFF;
  RebuildPagesRangeToPrint();
end; // end of TK_FormCMPrint.RBPageAllClick

//***********************************  TK_FormCMPrint.EdCopyCountExit ***
//  Printing Copies Counter Finish Editing
//
procedure TK_FormCMPrint1.EdCopyCountExit(Sender: TObject);
begin
  Printer.Copies := StrToIntDef( EdCopyCount.Text, Printer.Copies );
end; // end of TK_FormCMPrint.EdCopyCountExit

//***********************************  TK_FormCMPrint.EdKeyDown ***
// All TEdit Controls KeyDown handler
//
procedure TK_FormCMPrint1.EdKeyDown( Sender: TObject;
                                     var Key: Word; Shift: TShiftState );
begin
  if Key <> VK_RETURN then Exit;
  RebuildPagesRangeToPrint();
  BtPrint.SetFocus();
end; // end of TK_FormCMPrint.EdKeyDown

//***********************************  TK_FormCMPrint.ChBtSetMinMarginsClick ***
// Toggle Minimal Paper Margins
//
procedure TK_FormCMPrint1.ChBSetMinMarginsClick(Sender: TObject);
  procedure SetMarginsText( MRect : TFRect );
  begin
    EdMarginLeft.Text   := Format( SPFloatFieldsFormat, [MRect.Left] );
    EdMarginRight.Text  := Format( SPFloatFieldsFormat, [MRect.Right] );
    EdMarginTop.Text    := Format( SPFloatFieldsFormat, [MRect.Top] );
    EdMarginBottom.Text := Format( SPFloatFieldsFormat, [MRect.Bottom] );
  end;
begin
  if ChBSetMinMargins.Checked then begin
    SPPrevMargins := SPMargins;
    SetMarginsText( FRect( SPMinMargin.X, SPMinMargin.Y, SPMinMargin.X, SPMinMargin.Y ) );
  end else
    SetMarginsText( SPPrevMargins );

  UpdateMarginsUpDown0();
  if ChBLogoChangePos.Checked then
    LogoChangeOK(Sender)
  else
    RebuildCurPageView( );

end; // end of TK_FormCMPrint.ChBtSetMinMarginsClick

//***********************************  TK_FormCMPrint.UDMarginsEnter ***
// Set Margins UpDowns Position
//
procedure TK_FormCMPrint1.UDMarginsEnter(Sender: TObject);
begin
  UpdateMarginsUpDown0();
end; // end of TK_FormCMPrint.UDMarginsEnter

//***********************************  TK_FormCMPrint.BBPageFirstClick ***
//
procedure TK_FormCMPrint1.BBPageFirstClick(Sender: TObject);
begin
//  ShowPageByNumber( 1 );
  ShowPageByNumber( SPFirstPrintPage );
end; // end of TK_FormCMPrint.BBPageFirstClick

//***********************************  TK_FormCMPrint.BBPagePrevClick ***
//
procedure TK_FormCMPrint1.BBPagePrevClick(Sender: TObject);
begin
  ShowPageByNumber( SPCurPageNum - 1 );
end; // end of TK_FormCMPrint.BBPagePrevClick

//***********************************  TK_FormCMPrint.BBPageNextClick ***
//
procedure TK_FormCMPrint1.BBPageNextClick(Sender: TObject);
begin
  ShowPageByNumber( SPCurPageNum + 1 );
end; // end of TK_FormCMPrint.BBPageNextClick

//***********************************  TK_FormCMPrint.BBPageLastClick ***
//
procedure TK_FormCMPrint1.BBPageLastClick(Sender: TObject);
begin
//  ShowPageByNumber( SPPageCount );
  ShowPageByNumber( SPLastPrintPage );
end; // end of TK_FormCMPrint.BBPageLastClick
{
//***********************************  TK_FormCMPrint.SetSlidesList ***
//  Set Printing Slides List
//
procedure TK_FormCMPrint.SetSlidesList( APUObj: Pointer; AUStep,
                                         AUCount: Integer );
var
  i : Integer;
begin
   SetLength( SPUDSlides, AUCount );
   SetLength( SPPUDSlides, AUCount );
   SPSlidesCount := AUCount;
   for i := 0 to AUCount - 1 do begin
     SPUDSlides[i] := TN_UDCMSlide(TN_PUDBase(APUObj)^);
     Inc( TN_BytesPtr(APUObj), AUStep );
   end;
end; // end of TK_FormCMPrint.SetSlidesList
}
//***********************************  TK_FormCMPrint.InitRFrameCoords ***
//  Rebuild Preview
//
procedure TK_FormCMPrint1.InitRFrameCoords;
begin
  RFrame.InitializeCoords( @N_DefRFInitParams, @N_DefRFCoordsState );
end; // end of TK_FormCMPrint.InitRFrameCoords

//***********************************  TK_FormCMPrint.PreparePrintList ***
//  Rebuild Preview
//
procedure TK_FormCMPrint1.PreparePrintList( APrintList : TN_UDCMSArray );
var
  Ind, i : Integer;
begin
// Clear Media Slides
  i := 0;
  SetLength(SPUDSlides, Length(APrintList) );
  for Ind := 0 to High(APrintList) do
  begin
    with APrintList[Ind], P.CMSDB do
      if (cmsfIsMediaObj in SFlags) or
         (cmsfIsImg3DObj in SFlags) or
         (K_CMEDAccess.EDACheckSlideMedia( APrintList[Ind] ) = K_edFails) then Continue; // Slide Image is absent or Media File or 3DImage
    SPUDSlides[i] := APrintList[Ind];
    Inc(i);
  end;
  SetLength( SPUDSlides, i );
  SetLength( SPPUDSlides, i );
  SetLength( SPUsedInds, i );
  SetLength( SPUnUsedInds, i );
  SetLength( SPUnUsedIndsB, i );
  SPSlidesCount := i;
end; // end of TK_FormCMPrint.PreparePrintList

//***********************************  TK_FormCMPrint.InitPreview ***
//  Rebuild Preview
//
procedure TK_FormCMPrint1.InitPreview;
var
  Ind : Integer;
  S : string;
begin
//  InitPageCounter();
// Correct  PageLayout UpDown Controls
//  UDColCount.Max := SPSlidesCount;
//  UDColCount.Position := Min( SPSlidesCount, UDColCount.Position );
//  UDRowCount.Max := SPSlidesCount;
//  UDRowCount.Position := Min( SPSlidesCount, UDRowCount.Position );
//  UDRowCount.Max := SPSlidesCount;
// Prepare Common Macro Values List

{ will be used in future when Print sample Manual Fill will be used
  // Set Inds Init State
  FillChar( SPUsedInds[0], SizeOf(Integer) * Length( SPUsedInds), -1 );
//  K_FillIntArrayByCounter( @SPUsedInds[0], Length( SPUsedInds), -1, 0 );
  K_FillIntArrayByCounter( @SPUnUsedInds[0], Length( SPUsedInds) );
}
  N_Dump2Str( 'Print start Count=' + IntToStr(SPSlidesCount) );
  if ChBAutoFillAll.Checked then
  begin
    K_FillIntArrayByCounter( @SPUsedInds[0], Length( SPUsedInds) );
    Ind := 0;
    N_Dump2Str( 'Print Sample fill all' );
  end
  else
  begin
    FillChar( SPUsedInds[0], SizeOf(Integer) * Length( SPUsedInds), -1 );
    K_FillIntArrayByCounter( @SPUnUsedInds[0], SPSlidesCount );
    Ind := SPSlidesCount; // Number of visible Thumbnails
    N_Dump2Str( 'Print Sample not fill' );
  end;

  SPSlidesPrintDGrid.DGNumItems := Ind;
  SPSlidesPrintDGrid.DGInitRFrame(); // should be called after all CMMFThumbsDGrid fields are set
  SPSlidesPrintDGrid.DGSelectedInd := -1;
  EnabledFillClearControls();

  // for Print sample AutoFill
//  K_FillIntArrayByCounter( @SPUsedInds[0], Length( SPUsedInds) );

// Switch to start Page
//  ShowPageByNumber( -1 );

  S := 'PageCount=' + IntToStr(SPPageCount);
  Ind := SPCommonMList.IndexOfName( 'PageCount' );
  if Ind = -1 then
    SPCommonMList.Add( S )
  else
    SPCommonMList[Ind] := S;
  if SPCommonMList.IndexOfName( 'PageNumber' ) = -1 then
    SPCommonMList.Add( 'PageNumber=' );
  if SPCommonMList.IndexOfName( 'Date' ) = -1 then
    SPCommonMList.Add( 'PrintDate=' );

  // Init Current Page Layout
  Dec( SPCurLayoutID ); // Dec because Inc is inside BtChangeLayoutClick
  BtNextLayoutClick( nil );

end; // end of TK_FormCMPrint.InitPreview

//***********************************  TK_FormCMPrint.ShowPageByNumber ***
// Prepare UDCompTree and Show Page with given number
//
//     Parameters
// ACurPageNum - number of Page To Show (Page is not rebuild if Current Shown
//               Page number equal to ACurPageNum). If =-1 then Start Page is
//               unconditionaly shown. If =-2 then Current Shown Page is rebuild
//               If =-3 and Page Slides Positions count is not changed
//               then Current Shown Page is rebuild and Start Page is Shown else.
//
procedure TK_FormCMPrint1.ShowPageByNumber( ACurPageNum : Integer );
var
//  ic, ir : Integer;
  n : Integer;
  UDDiagnComp : TN_UDCompVis;
  UDSlideRoot : TN_UDCompVis;
  UDSlideParent : TN_UDBase;
  UDSlideTree : TN_UDBase;
  UDPosNumberComp : TN_UDCompVis;
  PPosNumberSkip : TN_PByte;
//  Y0, Y1, X0, X1 : Float;
// SL : TStringList;
  RepDetailsText, RepTitleText : string;
//  ColCount, RowCount, ColDelta : Integer;

// UDSlideImage : TN_UDBase;
// ScaleFactor : Double;
// biXPixPerMeter, biYPixPerMeter : Integer;
  PrintSlide : TN_UDCMSlide;
  i, Ind, PagePlacesCount : Integer;
  SPosNum : string;
  MacroList : TStrings;
  WStr : string;
  PosWidth, PosHeight, FontCharAWidth, FontHeight, FontFullHeight : Double;
begin
  if ACurPageNum = -3 then
  begin // Show Current Page Number if possible
    if SPPrevMaxPageSlidesCount = SPMaxPageSlidesCount then
      ACurPageNum := -2
    else
      ACurPageNum := -1;
  end;
  if ACurPageNum = -2 then
  begin
  // Rebuild Current Page
    ACurPageNum := SPCurPageNum;
    SPCurPageNum := -1;
  end;
  if SPCurPageNum = ACurPageNum then Exit;

  SPCurPageNum := Max(1, ACurPageNum);
  SPCurPageNum := Min(SPCurPageNum, SPPageCount); // Pecaution

  N_Dump2Str('ShowPageByNumber start ' + IntTostr(SPCurPageNum) );


// Set Page Scroll Controls
  LbPageNum.Caption := format( K_CML1Form.LLLPrint2.Caption,
//                             'Page %2d of %2d',
                               [SPCurPageNum, SPPageCount] );
//                               [SPCurPageNum, SPLastPrintPage] );
  RebuildControlsByPageRange();

  /////////////////////////
  // Page Texts
  //

// Set Current Page  Number Macro
  with SPCommonMList do begin
    Values['PageCount']  := IntToStr(SPPageCount);
    Values['PageNumber'] := IntToStr(SPCurPageNum);
    Values['PrintDate'] := K_DateTimeToStr( Date(), 'dd/mm/yyyy' );
//    Values['PrintDate='] := FormatDateTime( N_WinFormatSettings.ShortDateFormat, Date() );
  end;

//  SL := TStringList.Create;
  SPWrkTextsList.Assign( SPPageTextsList );
  if not ChBPrintPageNumber.Checked then
  begin
    SPWrkTextsList[1] := 'PageFooter_=' + SPWrkTextsList.ValueFromIndex[1];
    SPWrkTextsList[2] := 'PageFooter=' + SPWrkTextsList.ValueFromIndex[2];
  end;

  RepDetailsText  := '';
  RepTitleText := '';
  if ChBPrintPageHeader.Checked or (SPCurPageNum = 1) then
  begin
    RepTitleText := EdReportTitle.Text;
    if ChBPatDetails.Checked then
      RepDetailsText := K_CML1Form.LLLMPatPrintPatDetails1.Caption;
////      RepDetailsText := '<b>'+ K_CML1Form.LLLMPatPrintPatDetails1.Caption + '</b><br>' +
////                        K_CML1Form.LLLMPatPrintPatDetails2.Caption;
//      RepDetailsText := '<b>'+ K_CMENPTPrintPatientDetails1 + '</b><br>' +
//                        K_CMENPTPrintPatientDetails2;

    if ChBProvDetails.Checked then
    begin
      if RepDetailsText <> '' then RepDetailsText := RepDetailsText + '<br>';
      RepDetailsText := RepDetailsText + K_CMENPTPrintProviderDetails;
    end;
{
    if ChBPatDetails.Checked then
      AddText := '<span style="FONT-FAMILY:Tahoma;FONT-SIZE:8;FONT-WEIGHT:BOLD">'+ K_CMENFPrintPatDetails1 + '</span><br>' +
                 '<span style="FONT-FAMILY:Tahoma;FONT-SIZE:8;">'+ K_CMENFPrintPatDetails2 + '</span><br>';

    if ChBProvDetails.Checked then begin
      if AddText <> '' then AddText := AddText + '<br>';
      AddText := AddText + '<span style="FONT-FAMILY:Tahoma;FONT-SIZE:8;">'+ K_CMENFPrintProvDetails + '</span>';
    end;
}
  end;

  SPWrkTextsList.Add( 'ReportTitle=' + RepTitleText );
  SPWrkTextsList.Add( 'ReportDetails=' + RepDetailsText );

// Build Common Page Texts
  SetUDCompTextMacroValues( SPPageParamsUDComp, SPWrkTextsList, SPCommonMList );

{
  // Prepare Slide Base Tree Components
//  ScaleFactor := 1;
  with TN_UDCompVis( SPSlidePatRootUDComp.GetObjByRPath(SPSlidePatParentPath) ).PCCS^ do
  begin
    if ChBHCenter.Checked then
    begin
      BPCoords.X := 50;
      BPPos.X := 0.5;
    end
    else
    begin
      BPCoords.X := 0;
      BPPos.X := 0;
    end;
    if ChBVCenter.Checked then
    begin
      BPCoords.Y := 50;
      BPPos.Y := 0.5;
    end
    else
    begin
      BPCoords.Y := 0;
      BPPos.Y := 0;
    end;

    if TBSlideFixZoom1.Down then
    begin  // Not Used Now
      SRSizeXType := cstmm;
      SRSizeYType := cstmm;
//      with CmBSlideScale_7 do
//        ScaleFactor := StrToFloatDef( Text, 1 );
    end
    else
    begin
      SRSize.X := 100;
      SRSize.Y := 100;
      SRSizeXType := cstPercentP;
      SRSizeYType := cstPercentP;
    end;
  end; // with TN_UDCompVis( SPSlidePatRootUDComp.GetObjByRPath(SPSlidePatParentPath) ).PCCS^ do
}
  //
  // Page Texts
  /////////////////////////

  /////////////////////////
  // Page Logo
  //

  with SPLogoUDRoot.PSP.CCompBase do
    if ChBLogoShow.Checked and not ChBLogoChangePos.Checked then
    begin
      CBSkipSelf := 0; // Show All Logo
      with SPLogoUDFrame.PSP.CCompBase do
        if SPPrintMode then
          CBSkipSelf := 255 // Hide Logo Frame
        else
          CBSkipSelf := 0;  // Show Logo Frame
    end
    else
      CBSkipSelf := 255; // Hide All Logo
  //
  // Page Logo
  /////////////////////////


  /////////////////////////
  // Page Positions
  //
  // Build Slide Text Patterns
  SPWrkTextsList.Assign( SPSlideTextsList );
  if not ChBImgDetails.Checked and not ChBDiagnoses.Checked then
    for i := 0 to SPWrkTextsList.Count - 1 do
      SPWrkTextsList[i] := SPWrkTextsList.Names[i]+'=';

// Set Current Page Slides Indexes
  SPCurPageSSInd := (SPCurPageNum - 1) * SPMaxPageSlidesCount;

//  SPCurPageSlidesCount := SMaxPageSlidesCount;
  SPCurPageSFInd := SPCurPageSSInd + SPMaxPageSlidesCount - 1;
  if (SPCurLayoutID = 0) and (SPCurPageSFInd >= SPSlidesCount) then
    SPCurPageSFInd := SPSlidesCount - 1; // for Table Layout Only

  // Build Page Slides Places Components
  BuildPageSlidePosComps();

  // Link Slides Places Components with Slides
  n := SPCurPageSSInd;

  PagePlacesCount := SPPageSlidesRootUDComp.DirLength();

  SPCurPageUsedNum := 0;
  SetLength( SPPagePlacesGroup.SComps, PagePlacesCount );

  FontHeight     := 25.4 / 72 * 7;    // Font Height for Tahoma 7 pt
  FontCharAWidth := FontHeight * 0.5; // Average Font Char Width
  FontFullHeight := FontHeight * 1.2; // Font line Height

  for i := 0 to PagePlacesCount - 1 do
  begin
    UDSlideRoot := TN_UDCompVis( SPPageSlidesRootUDComp.DirChild( i ) );
    UDSlideParent := UDSlideRoot.GetObjByRPath(SPSlidePatParentPath);

    UDPosNumberComp := TN_UDCompVis(UDSlideParent.Owner.DirChild(1));
    PPosNumberSkip := @(UDPosNumberComp.PSP.CCompBase.CBSkipSelf);
    PPosNumberSkip^ := 255; // Hide Pos Number

    with SPPagePlacesGroup.SComps[i] do
    begin
      SComp  := TN_UDCompVis(UDSlideRoot);
      SFlags := 0;
      UDSlideRoot.Marker := SPCurPageSSInd + i;
    end;

    if n <= SPCurPageSFInd then
      Ind := SPUsedInds[n]
    else
      Ind := -1;
    SPSlideMList.Clear;
    SPosNum := IntToStr(n + 1);
    SPSlideMList.Add( 'SlideNum=' + SPosNum );

    MacroList := SPWrkTextsList;
    if Ind >= 0 then
    begin
      Inc(SPCurPageUsedNum);
      // Mount Slide to Print sample Place Get Slide Attrs
      PrintSlide := SPUDSlides[Ind];
      with PrintSlide, P()^ do
      begin
        if SPPrintMode then
        begin
           if not (K_CMEDAccess is TK_CMEDDBAccess) then
                 // Saving Print Statistics to Slide buffer
             with K_CMEDAccess do
               EDAAddHistActionToSlideBuffer( PrintSlide,
                  EDABuildHistActionCode( K_shATNotChange, Ord(K_shNCAPrint) ) )
           else
           begin // Saving Print Stastics in DB mode after printing is finished
             SPPUDSlides[SPPrintSlidesCount] := PrintSlide;
             Inc(SPPrintSlidesCount);
           end;
        end; // if SPPrintMode then

        if ChBImgDetails.Checked then
        begin
          SPSlideMList.Add( 'SlideID='      + ObjName );
          WStr := K_DateTimeToStr( CMSDTTaken, 'dd/mm/yyy hh:nn' );
          if (TN_UDCMBSlide(PrintSlide) is TN_UDCMStudy) and (CMSSourceDescr <> '') then
            WStr := WStr + '<br>' + CMSSourceDescr;
          SPSlideMList.Add( 'SlideDTTaken=' + WStr );
          SPSlideMList.Add( 'SlideChartNo=' + K_CMSTeethChartStateToText( CMSTeethFlags ) );
        end; // if ChBImgDetails.Checked then

        if ChBDiagnoses.Checked and
           (CMSDiagn <> '')     and
           (TN_UDCMBSlide(PrintSlide) is TN_UDCMSlide) then
        begin

          with UDSlideRoot.PSP.CCoords do
          begin
            PosWidth  := (SPPaperSize.X - SPMargins.Left - SPMargins.Right) * SRSize.X / 100;
            PosHeight := (SPPaperSize.Y - SPMargins.Top - SPMargins.Bottom) * SRSize.Y / 100;
          end;

          UDDiagnComp := TN_UDCompVis( UDSlideRoot.DirChild( 1 ) );
          with UDDiagnComp.PSP.CCoords do
          begin
//1
//            BPYCoordsType := cbpmm;
//            BPCoords.Y    := PosWidth * (CMSDB.PixHeight / CMSDB.PixWidth) + 20;

//2
            BPYCoordsType := cbpmm_LR;
            BPCoords.Y := FontFullHeight * Min(
                           Floor(PosHeight*0.5/FontFullHeight),
                           Ceil(FontCharAWidth * Length(CMSDiagn)/PosWidth) + 1 );
          end; // with UDDiagnComp.PSP.CCoords do

          SPSlideMList.Add( 'SlideDiagn=' + CMSDiagn );
        end; // if ...

        UDSlideTree  := GetMapRoot();

        if UDSlideTree <> nil then
        begin
          if UDSlideParent <> nil then
          begin
            Include( CMSRFlags, cmsfIsPrinting );
            UDSlideParent.AddOneChild( UDSlideTree );
          end; // if UDSlideParent <> nil then
        end; // if UDSlideTree <> nil then

      end; // with PrintSlide, P()^  do
    end // if Ind >= 0 then
    else
    begin
    // Empty Position
      if SPPrintMode then
      begin
        UDSlideRoot.PSP.CCompBase.CBSkipSelf := 255;
      end
      else
      begin
{
      if not SPPrintMode then
      begin
        with TN_UDParaBox(UDPosNumberComp).PISP()^ do
          TN_POneTextBlock(CPBTextBlocks.P).OTBMText := SPosNum;
        PPosNumberSkip^ := 0; // Show Pos Number
      end;
}
        with TN_UDParaBox(UDPosNumberComp).PISP()^ do
          TN_POneTextBlock(CPBTextBlocks.P).OTBMText := SPosNum;
        PPosNumberSkip^ := 0; // Show Pos Number

        if ChBImgDetails.Checked or ChBDiagnoses.Checked then
        begin
  //        K_CMEDAccess.TmpStrings.Text := 'SlideHeader=(#SlideNum#)'#13#10'SlideFooter=';
          K_CMEDAccess.TmpStrings.Text := 'SlideHeader=   '#13#10'SlideFooter='; // whitespace chars in SlideHeader is needed
          MacroList := K_CMEDAccess.TmpStrings;
        end;
      end;
    end; // end of Empty Position

    // Build Position Texts
    SetUDCompTextMacroValues( UDSlideRoot, MacroList, SPSlideMList );

    Inc(n);
//    if n > SPCurPageSFInd then Break;
  end; // for i := 0 to PagePlacesNum - 1 do

  BtFillPage.Enabled := (PagePlacesCount > SPCurPageUsedNum) and (SPSlidesPrintDGrid.DGNumItems > 0);
  BtClearPage.Enabled := SPCurPageUsedNum > 0;
  //
  // Page Positions
  /////////////////////////

//  SL.Free;
  RebuildCurPageView();
  N_Dump2Str( 'ShowPageByNumber fin' );
end; // end of TK_FormCMPrint.ShowPageByNumber

//***********************************  TK_FormCMPrint.RebuildCurPageView ***
//  Rebuild Peview
//
procedure TK_FormCMPrint1.RebuildCurPageView(  );
begin
// Set Margins depended SPPageParams
  with SPPageParamsUDComp.GetSUserParRArray( 'FrameLeftTop' )  do
    PFPoint(P)^ := SPMargins.TopLeft;
  with SPPageParamsUDComp.GetSUserParRArray( 'FrameRightBottom' )  do
    PFPoint(P)^ := SPMargins.BottomRight;
  with SPPageParamsUDComp.GetSUserParRArray( 'SkipFrameFlag' )  do
    PByte(P)^ := Byte(SPPrintMode);
  with SPPageParamsUDComp.GetSUserParRArray( 'PaperSize' )  do
    PFPoint(P)^ := FPoint(SPPaperSize);
  with SPPageParamsUDComp.GetSUserParRArray( 'Resolution' )  do
    PFloat(P)^ := SPDeviceRes.X;

  if SPPrintMode then Exit;

  RFrame.RFrInitByComp( SPPageRootUDComp );
  if not CompareMem( @SPPrevDeviceRes, @SPDeviceRes, SizeOf(TPoint) ) or
     not CompareMem( @SPPaperSize, @SPPrevPaperSize, SizeOf(TDPoint) ) then
    InitRFrameCoords();
  SPPrevPaperSize := SPPaperSize;
  SPPrevDeviceRes := SPDeviceRes;

  ClearLogoChangePosMode();

  if Visible then
  begin
    RFrame.RedrawAllAndShow();
//    RFrame.Refresh();
  end
  else
  begin
    RFrame.RedrawAll();
    Show();
  end;
//  RFrame.SetFocus();
end; // end of TK_FormCMPrint.RebuildCurPageView

//***********************************  TK_FormCMPrint.SetUDCompTextMacroValues ***
// Set UDComponet User Params Text Varaibles by List of Macro Patterns and List of Macro Values
//
procedure TK_FormCMPrint1.SetUDCompTextMacroValues( UDComp: TN_UDBase;
                                           MacroTexts, MacroVaues : TStrings );
var
  i : Integer;
  UPVR : TK_RArray;
  UPName : string;
  UPValue : string;
begin

  for i := 0 to MacroTexts.Count -1 do begin
    UPName := MacroTexts.Names[i];
    UPVR := TN_UDCompVis(UDComp).GetSUserParRArray( UPName );
    if UPVR = nil then Continue;
    UPValue := MacroTexts.ValueFromIndex[i];
    PString(UPVR.P)^ := K_StringMListReplace( UPValue,
                                              MacroVaues, K_ummRemoveMacro );
    UPVR := TN_UDCompVis(UDComp).GetSUserParRArray( UPName + 'SkipFlag' );
    if UPVR = nil then Continue;
    if UPValue <> '' then
      PByte(UPVR.P)^ := 0
    else
      PByte(UPVR.P)^ := 255;
  end;

end; // end of TK_FormCMPrint.SetUDCompTextMacroValues

//***********************************  TK_FormCMPrint.UDPageLayoutClick ***
// Change Page Slides Layout Event Handler
//
procedure TK_FormCMPrint1.UDPageLayoutClick( Sender: TObject;
                                             Button: TUDBtnType );
begin
  SPPageSlidesCCount := StrToInt( EdColCount.Text );
  SPPageSlidesRCount := StrToInt( EdRowCount.Text );
  SPMaxPageSlidesCount := SPPageSlidesRCount * SPPageSlidesCCount;

  InitPageCounter();
  ShowPageByNumber( -1 );
end; // end of TK_FormCMPrint.UDPageLayoutClick

//***********************************  TK_FormCMPrint.BtPrintClick ***
// Print selected pages action
//
procedure TK_FormCMPrint1.BtPrintClick(Sender: TObject);
var
  i : Integer;
  FirstPage, LastPage : Integer;
  ExpParams: TN_ExpParams;
  TmpGCont: TN_GlobCont;
//  CSPCurPageNum : Integer;
begin
//  SPPrintMode := not SPPrintMode;
//  CSPCurPageNum := SPCurPageNum;
  SPPrintMode := TRUE;
  RebuildCurPageView();
  FirstPage := 1;
  LastPage := SPPageCount;
  if not RBPageAll.Checked then
  begin
    FirstPage := StrToInt( EdBegPage.Text );
    LastPage := StrToInt( EdEndPage.Text );
  end;

  SPLTPixMargin.X  := GetDeviceCaps( Printer.Handle, PHYSICALOFFSETX );
  SPLTPixMargin.Y  := GetDeviceCaps( Printer.Handle, PHYSICALOFFSETY );
  SPAreaPixSize.X  := GetDeviceCaps( Printer.Handle, HORZRES );
  SPAreaPixSize.Y  := GetDeviceCaps( Printer.Handle, VERTRES );
  SPPaperPixSize.X := GetDeviceCaps( Printer.Handle, PHYSICALWIDTH );
  SPPaperPixSize.Y := GetDeviceCaps( Printer.Handle, PHYSICALHEIGHT );

  ExpParams := N_DefExpParams;
  with ExpParams, ExpParams.EPImageFPar do
  begin
    EPImageExpMode := iemJustDraw;
    EPExecFlags := EPExecFlags + [epefHALFTONE];
    IFPImFileFmt := imffBMP;
    IFPPixFmt    := pf24bit;
    IFPSizePix   := SPPaperPixSize;
    IFPSizemm    := FPoint( SPPaperSize );
    IFPResDPI    := FPoint( SPDeviceRes );

    IFPVisPixRect := Rect( SPLTPixMargin.X,
                           SPLTPixMargin.Y,
                           SPLTPixMargin.X + SPAreaPixSize.X,
                           SPLTPixMargin.Y + SPAreaPixSize.Y );

  end; // with ExpParams, ExpParams.EPImageFPar do
  N_Dump2Str('Before Printer.BeginDoc');
  Printer.BeginDoc;
  if Printer.Printing then // check printing needed for Microsoft XPS Writer in XP
  begin
    SPPrintSlidesCount := 0;
    SPCurPageNum := -1;
    for i := FirstPage to LastPage do
    begin
      ShowPageByNumber(i);

      TmpGCont := TN_GlobCont.Create();
      TmpGCont.ExecuteRootComp( SPPageRootUDComp, [], nil, nil, @ExpParams );

      with TmpGCont do
        N_StretchRect( Printer.Canvas.Handle, Rect( 0, 0, SPAreaPixSize.X-1, SPAreaPixSize.Y-1 ),
                                              DstOCanv.HMDC, VisPixRect );
      TmpGCont.Free;

  //    N_StretchRect( Printer.Canvas.Handle, Rect( 0, 0, Printer.PageWidth-1, Printer.PageHeight-1 ),
  //                   RFrame.OCanv.HMDC, RFrame.RFDstPRect );
      if not Printer.Printing then
      begin
        N_Dump1Str('!!!Printer.Printing is FALSE before Printer.NewPage');
        break;
      end;
      if i < LastPage then
      begin
        N_Dump2Str('Before Printer.NewPage');
        Printer.NewPage;
      end;
    end;

    if Printer.Printing then
    begin
      N_Dump2Str('Before Printer.EndDoc');
      Printer.EndDoc;
    end;
  end
  else
    N_Dump1Str('!!!Printer.Printing is FALSE after Printer.BeginDoc');


  if (SPPrintSlidesCount >= 0)    and
     (K_CMEDAccess is TK_CMEDDBAccess) then
    with K_CMEDAccess do
//      EDASaveSlidesListHistory( @SPUDSlides[SPPrintSlideStartInd], SPPrintSlidesCount,
      EDASaveSlidesListHistory( @SPPUDSlides[0], SPPrintSlidesCount,
                EDABuildHistActionCode( K_shATNotChange, Ord(K_shNCAPrint) ) );
  Close;

  SPPrintMode := FALSE; // 2016-03-16 open this code
//  ShowPageByNumber(CSPCurPageNum);

end; // end of TK_FormCMPrint.BtPrintClick

//***********************************  TK_FormCMPrint.RBPortraitClick ***
// Change printer orientation to Portrait
//
procedure TK_FormCMPrint1.RBPortraitClick(Sender: TObject);
begin
  if Printer.Orientation = poPortrait then Exit;
  Printer.Orientation := poPortrait;
  PrinterSetupDialogClose(Sender);
end; // end of TK_FormCMPrint.RBPortraitClick

//***********************************  TK_FormCMPrint.RBLandscapeClick ***
// Change printer orientation to Landscape
//
procedure TK_FormCMPrint1.RBLandscapeClick(Sender: TObject);
begin
  if Printer.Orientation = poLandscape then Exit;
  Printer.Orientation := poLandscape;
  PrinterSetupDialogClose(Sender);
end; // end of TK_FormCMPrint.RBLandscapeClick

//***********************************  TK_FormCMPrint.ChBPatDetailsClick ***
// Change Patient or Provider Details
//
procedure TK_FormCMPrint1.ChBPatDetailsClick( Sender: TObject );
begin
  if SPMemIniToCurStateMode then Exit;
  if (SPCurPageNum = 1) or ChBPrintPageHeader.Checked then
    ChBImgDetailsClick(Sender); // Rebuild Page View
end; // end of TK_FormCMPrint.ChBPatDetailsClick

//***********************************  TK_FormCMPrint.ChBImgDetailsClick ***
// Change Slide Details
//
procedure TK_FormCMPrint1.ChBImgDetailsClick(Sender: TObject);
begin
  if SPMemIniToCurStateMode then Exit;
  LogoChangeOK( nil );
  ShowPageByNumber( -2 );
end; // end of TK_FormCMPrint.ChBImgDetailsClick

//***********************************  TK_FormCMPrint.EdReportTitleKeyDown ***
// EdReportTitle KeyDown Event Handler
//
procedure TK_FormCMPrint1.EdReportTitleKeyDown( Sender: TObject;
                                var Key: Word; Shift: TShiftState );
begin
  if Key = VK_RETURN then
    ChBPatDetailsClick( Sender );
end; // end of TK_FormCMPrint.EdReportTitleKeyDown

//*************************************  TK_FormCMPrint.TBSlideFixZoomClick ***
// EdReportTitle KeyDown Event Handler
//
procedure TK_FormCMPrint1.TBSlideFixZoomClick(Sender: TObject);
begin
  if Sender = TBSlideFixZoom1 then
    TBSlideFitToView.Down := not TBSlideFixZoom1.Down
  else
    TBSlideFixZoom1.Down := not TBSlideFitToView.Down;
//  _CmBSlideScale.Enabled := TBSlideFixZoom.Down;
  SetCmBSlideScaleState();
{
  ChangeState := _CmBSlideScale.Enabled <> TBSlideFixZoom1.Down;
  _CmBSlideScale.Enabled := TBSlideFixZoom1.Down;
  if ChangeState then
    with _CmBSlideScale do begin
      if not Enabled then
        Items.Insert( ItemIndex, '')
      else
        Items.Delete(ItemIndex);
    end;
  }
  LbSlideScale.Enabled := TBSlideFixZoom1.Down;
  ChBImgDetailsClick(Sender); // Rebuild Page View
end; // end of TK_FormCMPrint.TBSlideFixZoomClick

//*********************************************  TK_FormCMPrint.FormKeyDown ***
//
procedure TK_FormCMPrint1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
  VK_ADD      : RFrame.aZoomInExecute(Sender); // '+' on NumPad
  187         : RFrame.aZoomInExecute(Sender); // '+=' Key

  VK_SUBTRACT : RFrame.aZoomOutExecute(Sender); // '-' on NumPad
  189         : RFrame.aZoomOutExecute(Sender); // '_-' Key
  end;
end; // end of TK_FormCMPrint.FormKeyDown

//*************************************  TK_FormCMPrint._CmBSlideScaleChange ***
//
procedure TK_FormCMPrint1.CmBSlideScale_7Change(Sender: TObject);
begin
  ChBImgDetailsClick(Sender); // Rebuild Page View
end; // end of TK_FormCMPrint._CmBSlideScaleChange

//***************************************** TK_FormCMPrint1.RFrameMouseDown ***
// RFrame OnMouseDown event handler
//
procedure TK_FormCMPrint1.RFrameMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  UDComp : TN_UDBase;
begin
  if (ssLeft in Shift) and not ChBLogoChangePos.Checked then
  begin
//    if check if mouse is down inside slide place with slide
    RFrame.SearchInAllGroups2( X, Y );
    // Select Page position under cursor
    SPPageDragStartComp := nil;
    RedrawDragOverComponent( 0 );
    with SPPagePlacesGroup, OneSR do
      if (SRType <> srtNone)then
        SPPageDragStartComp := TN_UDBase(SComps[SRCompInd].SComp);

    RedrawDragOverComponent( 0 );

    // if this position is used by Slide check Drag Start by Timer
    SPDragMode := 0;
    SPCurDragInd := - 1;
    if SPPageDragStartComp <> nil then
    begin
      UDComp := SPPageDragStartComp.GetObjByRPath(SPSlidePatParentPath);
      if (UDComp <> nil) and (UDComp.DirChild(0) <> nil) then
      begin //
        SPDragMode := 1;
        SPCurDragInd := SPPageDragStartComp.Marker;
        StartDragTimer.Enabled := TRUE;
      end;
    end;
  end;
end; // procedure TK_FormCMPrint.RFrameMouseDown

//****************************************** TK_FormCMPrint1.RFrameDragOver ***
// RFrame OnDragOver event handler
//
procedure TK_FormCMPrint1.RFrameDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  DragOverComp : TN_UDBase;

label LExit;

begin
//   inherited;
  Accept := FALSE;
  if (SPDragMode and 4) = 0 then
  begin
LExit: // ***********
    RedrawDragOverComponent( 0 );
    Exit;
  end;

// if cursor position is not inside slide place or insde the slide place with same slide then exit;
  RFrame.SearchInAllGroups2( X, Y );
  DragOverComp := nil;
  with SPPagePlacesGroup, OneSR do
    if (SRType <> srtNone)then
      DragOverComp := TN_UDBase(SComps[SRCompInd].SComp);

  if (DragOverComp = nil) or (SPPageDragStartComp = DragOverComp) then goto LExit;
  Accept := TRUE;

  if SPPageDragOverComp = DragOverComp then Exit;

  RedrawDragOverComponent( 0 );
  SPPageDragOverComp := DragOverComp;
  RedrawDragOverComponent( 1 );

end; // procedure TK_FormCMPrint.RFrameDragOver

//************************************* TK_FormCMPrint1.StartDragTimerTimer ***
// StartDragTimer OnTimer event handler
//
procedure TK_FormCMPrint1.StartDragTimerTimer(Sender: TObject);
begin
//
  StartDragTimer.Enabled := FALSE;
  CancelDrag();
  if ((Windows.GetKeyState(VK_LBUTTON)   and $8000) <> 0) and
     ((SPDragMode = 1)  or
      ((SPDragMode = 2) and not SPSlidesPrintDGrid.DGCurrentIsEmpty)) then
  begin
    SPDragMode := SPDragMode + 4;
    if SPDragMode = 6 then
      SPCurDragInd := SPSlidesPrintDGrid.DGSelectedInd;
    RFrame.BeginDrag( TRUE );
  end
  else
  begin
    SPDragMode := 0;
    SPCurDragInd := -1;
  end;

end; // procedure TK_FormCMPrint1.StartDragTimerTimer

//******************************************* TK_FormCMPrint1.RFrameEndDrag ***
// RFrame OnEndDrag event handler
//
procedure TK_FormCMPrint1.RFrameEndDrag(Sender, Target: TObject; X,
  Y: Integer);
var
  UDComp : TN_UDBase;
  TargetInd : Integer;
  WInd : Integer;
begin


  if (Target <> nil ) and
     (SPPageDragStartComp <> nil) and
     (TComponent(Target).Owner.Name = 'PrintSlidesRFrame') then
  begin
    ClearUsedSlides( SPPageDragStartComp.Marker, SPPageDragStartComp.Marker, TRUE );
    Exit;
  end;

  if SPPageDragOverComp = nil then Exit;
  TargetInd := SPPageDragOverComp.Marker;
  UDComp := SPPageDragOverComp.GetObjByRPath(SPSlidePatParentPath);
  RedrawDragOverComponent(0);
  if UDComp = nil then Exit;

  if UDComp.DirChild(0) <> nil then
  begin // Target place is used
    if SPDragMode = 5 then // Used Slide is draged - switch used places
    begin
      N_Dump2Str( format('Drag Switch ID=%s at PagePos=%d and ID=%s at PagePos=%d',
      [SPUDSlides[SPUsedInds[TargetInd]].ObjName,TargetInd,
       SPUDSlides[SPUsedInds[SPCurDragInd]].ObjName,SPCurDragInd]) );
      WInd := SPUsedInds[TargetInd];
      SPUsedInds[TargetInd] := SPUsedInds[SPCurDragInd];
      SPUsedInds[SPCurDragInd] := WInd;
    end
    else
    if SPDragMode = 6 then // Unused Slide is draged - switch Used and Unused Slide
    begin
      N_Dump2Str( format('Drag Switch ID=%s at PagePos=%d and unused ID=%s at Pos=%d',
        [SPUDSlides[SPUsedInds[TargetInd]].ObjName,TargetInd,
       SPUDSlides[SPUnUsedInds[SPCurDragInd]].ObjName,SPCurDragInd]) );
      WInd := SPUsedInds[TargetInd];
      SPUsedInds[TargetInd] := SPUnUsedInds[SPCurDragInd];
      SPUnUsedInds[SPCurDragInd] := WInd;
      SPSlidesPrintDGrid.DGInitRFrame();
      SPSlidesPrintDGrid.DGSelectedInd := -1;
    end
  end   // Target place is busy
  else
  begin // Target place is free
    if SPDragMode = 5 then // Used Slide is draged - swith used and unused page places
    begin
      N_Dump2Str( format('Drag ID=%s at PagePos=%d to PagePos=%d',
      [SPUDSlides[SPUsedInds[SPCurDragInd]].ObjName,SPCurDragInd,TargetInd]) );
      SPUsedInds[TargetInd] := SPUsedInds[SPCurDragInd];
      SPUsedInds[SPCurDragInd] := -1;
    end
    else
    if SPDragMode = 6 then // Unused Slide is draged - fill unused page place
    begin
      N_Dump2Str( format('Drag unused ID=%s at Pos=%d to PagePos=%d',
      [SPUDSlides[SPUnUsedInds[SPCurDragInd]].ObjName,SPCurDragInd,TargetInd]) );
      SPUsedInds[TargetInd] := SPUnUsedInds[SPCurDragInd];
      SPSlidesPrintDGrid.DGNumItems := SPSlidesPrintDGrid.DGNumItems - 1;
      if SPCurDragInd < SPSlidesPrintDGrid.DGNumItems then
        Move( SPUnUsedInds[SPCurDragInd + 1], SPUnUsedInds[SPCurDragInd],
              (SPSlidesPrintDGrid.DGNumItems - SPCurDragInd) * SizeOf(Integer) );
      SPSlidesPrintDGrid.DGInitRFrame();
      SPSlidesPrintDGrid.DGSelectedInd := -1;
      Inc(SPCurPageUsedNum);
      BtFillPage.Enabled := (Min(SPCurPageSFInd + 1, SPSlidesCount) - SPCurPageSSInd > SPCurPageUsedNum) and
                            (SPSlidesPrintDGrid.DGNumItems > 0);
      BtClearPage.Enabled := SPCurPageUsedNum > 0;
    end
  end;  // Target place is free

  LogoChangeOK(nil);

  ShowPageByNumber( -2 );
  EnabledFillClearControls();

  // Clear Drag Context
  SPDragMode := 0;
  SPCurDragInd := - 1;

end; // procedure TK_FormCMPrint1.RFrameEndDrag

//************************************* TK_FormCMPrint1.ChBAutoFillAllClick ***
// ChBAutoFillAll OnClick event handler
//
procedure TK_FormCMPrint1.ChBAutoFillAllClick(Sender: TObject);
begin
  if SPMemIniToCurStateMode or not ChBAutoFillAll.Checked then Exit;
  if BtFillAll.Enabled then BtFillAllClick(Sender);
end; // procedure TK_FormCMPrint1.ChBAutoFillAllClick

//****************************************** TK_FormCMPrint1.BtFillAllClick ***
// BtClearAll OnClick event handler
//
procedure TK_FormCMPrint1.BtFillAllClick(Sender: TObject);
begin
  FillUsedSlides( 0, SPSlidesCount - 1, -1 );
end; // procedure TK_FormCMPrint1.BtFillAllClick

//***************************************** TK_FormCMPrint1.BtClearAllClick ***
// BtClearAll OnClick event handler
//
procedure TK_FormCMPrint1.BtClearAllClick(Sender: TObject);
begin
  ClearUsedSlides( 0, High(SPUsedInds), FALSE );
end; // procedure TK_FormCMPrint1.BtClearAllClick

//***************************************** TK_FormCMPrint1.BtFillPageClick ***
// BtFillPage OnClick event handler
//
procedure TK_FormCMPrint1.BtFillPageClick(Sender: TObject);
begin
  FillUsedSlides( SPCurPageSSInd, SPCurPageSFInd, -1 );
end; // procedure TK_FormCMPrint1.BtFillPageClick

//**************************************** TK_FormCMPrint1.BtClearPageClick ***
// BtClearPage OnClick event handler
//
procedure TK_FormCMPrint1.BtClearPageClick(Sender: TObject);
begin
  ClearUsedSlides( SPCurPageSSInd, SPCurPageSFInd, FALSE );
end; // procedure TK_FormCMPrint1.BtClearPageClick

//****************************** TK_FormCMPrint1.PrintSlidesRFrameMouseDown ***
// PrintSlidesRFrame OnMouseDown event handler
//
procedure TK_FormCMPrint1.PrintSlidesRFrameMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) then
  begin
    SPPageDragStartComp := nil;
    RedrawDragOverComponent( 0 );
    SPDragMode := 2;
    SPCurDragInd := - 1;
    // Unconditional Start of Drag Timer - Real Element Selection Check will be done
    // later during OnTimer event. It is needed because this OnMouseDown handler is called before
    // DGrid OnMouse down Handler when real element selection will be done
    StartDragTimer.Enabled := TRUE;
  end;
end; // procedure TK_FormCMPrint1.PrintSlidesRFrameMouseDown

//*************************************** TK_FormCMPrint1.BtNextLayoutClick ***
// Button BtNextLayout OnClick event handler
//
procedure TK_FormCMPrint1.BtNextLayoutClick(Sender: TObject);
begin
  Inc(SPCurLayoutID);
  if SPCurLayoutID > Length(SPTemplatePageCoords) then
    SPCurLayoutID := 0;
  CmBPrintTemplates.ItemIndex := SPCurLayoutID;
  SetLayoutContext();
end; // procedure TK_FormCMPrint1.BtNextLayoutClick

//*************************************** TK_FormCMPrint1.BtPrevLayoutClick ***
// Button BtPrevLayout OnClick event handler
//
procedure TK_FormCMPrint1.BtPrevLayoutClick(Sender: TObject);
begin
  Dec(SPCurLayoutID);
  if SPCurLayoutID < 0 then
    SPCurLayoutID := Length(SPTemplatePageCoords);
  CmBPrintTemplates.ItemIndex := SPCurLayoutID;
  SetLayoutContext();
end; // procedure TK_FormCMPrint1.BtPrevLayoutClick

//********************************* TK_FormCMPrint1.CmBPrintTemplatesChange ***
// ComboBox CmBPrintTemplates OnChange event handler
//
procedure TK_FormCMPrint1.CmBPrintTemplatesChange(Sender: TObject);
begin
  SPCurLayoutID := CmBPrintTemplates.ItemIndex;
  SetLayoutContext();
end; // procedure TK_FormCMPrint1.CmBPrintTemplatesChange

//*********************** TK_FormCMPrint1.PrintSlidesRFramePaintBoxDblClick ***
// PrintSlidesRFramePaintBox OnDblClick event handler
//
procedure TK_FormCMPrint1.PrintSlidesRFramePaintBoxDblClick( Sender: TObject );
begin
//  inherited;
  PrintSlidesRFrame.PaintBoxDblClick(Sender);
  if SPSlidesPrintDGrid.DGCurrentIsEmpty or
     not BtFillAll.Enabled or
     not BtFillPage.Enabled then Exit;

  FillUsedSlides( SPCurPageSSInd, SPCurPageSFInd, SPSlidesPrintDGrid.DGSelectedInd );
end; // procedure TK_FormCMPrint1.PrintSlidesRFramePaintBoxDblClick

//********************************** TK_FormCMPrint1.RFramePaintBoxDblClick ***
// RFramePaintBox OnDblClick event handler
//
procedure TK_FormCMPrint1.RFramePaintBoxDblClick(Sender: TObject);
var
  PageComp : TN_UDBase;
  TargetInd : Integer;
begin
  N_Dump2Str('RFramePaintBoxDblClick start');
  SPSkipLogoChangePosCancel := ChBLogoChangePos.Checked;
  RFrame.PaintBoxDblClick(Sender);
  SPSkipLogoChangePosCancel := FALSE;
{
  if ChBLogoChangePos.Checked then
  begin
    LogoChangeOK(Sender);
//    N_Dump2Str('RFramePaintBoxDblClick LogoChangePos fin');
//    Exit;
  end;
}
  PageComp := nil;
  with SPPagePlacesGroup, OneSR do
    if (SRType <> srtNone)then
      PageComp := TN_UDBase(SComps[SRCompInd].SComp);

  if PageComp = nil then Exit;
  TargetInd := PageComp.Marker;
  if SPUsedInds[TargetInd] < 0 then Exit;

  ClearUsedSlides( TargetInd, TargetInd, TRUE );

  N_Dump2Str('RFramePaintBoxDblClick fin');
end; // procedure TK_FormCMPrint1.RFramePaintBoxDblClick

//*********************** TK_FormCMPrint1.PrintSlidesRFramePaintBoxDragOver ***
// PrintSlidesRFramePaintBox OnDragOver event handler
//
procedure TK_FormCMPrint1.PrintSlidesRFramePaintBoxDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := SPPageDragStartComp <> nil;
end; // procedure TK_FormCMPrint1.PrintSlidesRFramePaintBoxDragOver

//**************************************** TK_FormCMPrint1.ChBLogoShowClick ***
// ChBLogoShow OnClick event handler
//
procedure TK_FormCMPrint1.ChBLogoShowClick(Sender: TObject);
begin
  N_Dump2Str('ChBLogoShowClick start');
  if SPMemIniToCurStateMode then Exit;
  LogoChangeOK( nil );
//  SPSkipLogoRFrameRedrawAllAndShow := TRUE;
//  if not ChBLogoShow.Checked then
//    ChBLogoChangePos.Checked := FALSE;
//  SPSkipLogoRFrameRedrawAllAndShow := FALSE;
  ShowPageByNumber( -2 ); // Just rebuild current page
  N_Dump2Str('ChBLogoShowClick fin');
end; // procedure TK_FormCMPrint1.ChBLogoShowClick

//***************************************** TK_FormCMPrint1.BtLogoLoadClick ***
// BtLogoLoad OnClick event handler
//
procedure TK_FormCMPrint1.BtLogoLoadClick(Sender: TObject);
var
  NewLogoDIB : TN_DIBObj;
begin
  N_Dump1Str('BtLogoLoadClick start');
  K_CMEDAccess.TmpStrings.Clear();
  K_CMImportFilesSelectDlg( K_CMEDAccess.TmpStrings, '', 2 );
  if K_CMEDAccess.TmpStrings.Count > 0 then
  begin
    NewLogoDIB := K_CMEDAccess.EDAPrintLogoSetByFile( K_CMEDAccess.TmpStrings[0] );
    if LongWord(NewLogoDIB) > 10 then
    begin
      InitLogo( NewLogoDIB );
      if ChBLogoShow.Checked then
      begin
        LogoChangeOK( nil );
        ShowPageByNumber( -2 ); // Just rebuild current page
      end
      else
        ChBLogoShow.Checked := TRUE;
    end
    else
      K_CMShowMessageDlg( 'New Logo file has not proper format ' + K_CMEDAccess.TmpStrings[0], mtWarning );

    N_Dump2Str('BtLogoLoadClick fin');
  end
  else
    N_Dump2Str('BtLogoLoadClick no Logo Load');
end; // procedure TK_FormCMPrint1.BtLogoLoadClick

//******************************************** TK_FormCMPrint1.LogoChangeOK ***
// Logo Position Change event handler
//
procedure TK_FormCMPrint1.LogoChangeOK(Sender: TObject);
begin
  N_Dump2Str('LogoChangeOK start');

  if ChBLogoChangePos.Checked or SPSLogoChangePosOK then
  begin
    SPSLogoChangePosOK := FALSE;
  // Change Logo Position Coords by Rubber Rect Coords
    with SPLogoPositionRFA do
    begin
      SPTemplatePageLogoCoords[SPCurLayoutID].Left  := RRCurUserRect.Left;
      SPTemplatePageLogoCoords[SPCurLayoutID].Top   := RRCurUserRect.Top;
      SPTemplatePageLogoCoords[SPCurLayoutID].Right := RRCurUserRect.Right - RRCurUserRect.Left;
      SPTemplatePageLogoCoords[SPCurLayoutID].Bottom:= RRCurUserRect.Bottom - RRCurUserRect.Top;
    end; // with SPLogoPositionRFA do


      // Clear LogoChagePos mode
    SPSkipLogoRFrameRedrawAllAndShow := TRUE;
    ChBLogoChangePos.Checked := FALSE;
    SPSkipLogoRFrameRedrawAllAndShow := FALSE;

    if ChBLogoShow.Checked then
    begin
      if Sender <> nil then
        ShowPageByNumber( -2 ) // Just rebuild current page - LogoChagePos mode will be clear inside ShowPage
    end
    else
      // Set LogoShow mode to Show LogoChagePos results
      ChBLogoShow.Checked := TRUE;
    SPSaveTemplatesInfoToMemIni := TRUE;
    SPTemplatesInfoIsReadyToSaveToMemIni := FALSE;
    N_Dump2Str('LogoChangeOK fin');
  end
  else
    N_Dump2Str('LogoChangeOK fin');
end; // procedure TK_FormCMPrint1.LogoChangeOK

//**************************************** TK_FormCMPrint1.LogoChangeCancel ***
// Logo Position Change event handler
//
procedure TK_FormCMPrint1.LogoChangeCancel(Sender: TObject);
begin
  N_Dump2Str('LogoChangeCancel start');
  if SPSkipLogoChangePosCancel then Exit;
  ChBLogoChangePos.Checked := FALSE;
//  SPLogoPositionRFA.ActEnabled := FALSE;
//  RFrame.RedrawAllAndShow();
  N_Dump2Str('LogoChangeCancel fin');
end; // procedure TK_FormCMPrint1.LogoChangeCancel

//********************************** TK_FormCMPrint1.ChBLogoChangePosClick ***
// ChBLogoChangePos OnClick event handler
//
procedure TK_FormCMPrint1.ChBLogoChangePosClick(Sender: TObject);
begin
// Set RubberRect Coordinates
  N_Dump2Str('ChBLogoChangePosClick start');

  with SPLogoPositionRFA do
  begin
    if ChBLogoChangePos.Checked then
    begin
      RRCurUserRect := N_AffConvI2FRect1( TN_UDCompVis(SPLogoUDRoot).CompOuterPixRect, RRConP2UComp.CompP2U );
      ActEnabled := TRUE;
//    ShowStringByTimer( 'Press Enter(OK), Escape(Cancel) or DoubleClick to Finish' );
    end
    else
      ActEnabled := FALSE;
  end; // with SPLogoPositionRFA do


  if not SPSkipLogoRFrameRedrawAllAndShow then
  begin
    if not ChBLogoChangePos.Checked then
    begin
      SPSLogoChangePosOK := TRUE;
      LogoChangeOK( nil );
    end;
    if ChBLogoShow.Checked then
    begin // Hide/Show Logo
      SPSkipLogoChangePosClear := TRUE;
      ShowPageByNumber( -2 );
      SPSkipLogoChangePosClear := FALSE;
    end
    else
      RFrame.RedrawAllAndShow()
  end;

  N_Dump2Str('ChBLogoChangePosClick fin');
end; // procedure TK_FormCMPrint1.ChBLogoChangePosClick

//********************************** TK_FormCMPrint.ClearSlidesPrintingFlag ***
// Clear Slides Printing Flag after Page is closed
//
procedure TK_FormCMPrint1.ClearSlidesPrintingFlag;
var
  i : Integer;
  SlideParent : TN_UDBase;
  UDSlideTree : TN_UDBase;
begin
  with SPPageSlidesRootUDComp do
  for i := 0 to DirHigh do
  begin
    SlideParent := DirChild(i).GetObjByRPath(SPSlidePatParentPath);
    if SlideParent = nil then Continue; // precaution
    UDSlideTree := SlideParent.DirChild(0);
    if UDSlideTree = nil then Continue; // needed if page has unused places
    Exclude( TN_UDCMSlide(UDSlideTree.Owner).P^.CMSRFlags, cmsfIsPrinting );
  end;
end; // end of TK_FormCMPrint.ClearSlidesPrintingFlag

//************************************** TK_FormCMPrint.ClearPageSlideComps ***
// Clear Page  Slides Components
//
procedure TK_FormCMPrint1.ClearPageSlideComps;
var
  i : Integer;
begin
  with SPPageSlidesRootUDComp do
  begin
    for i := 0 to DirHigh do
      DirChild(i).ClearChilds();
    ClearChilds();
  end;
end; // end of TK_FormCMPrint.ClearPageSlideComps

//********************************** TK_FormCMPrint.RedrawDragOverComponent ***
// Redraw Page Place Frame Component
//
//     Parameters
// AViewState - if 0 then component will be shown, if 255 then will be hide
//
procedure TK_FormCMPrint1.RedrawDragOverComponent( AViewState : Integer );
var
  DrawComp : TN_UDBase;
  PUP: TN_POneUserParam;
begin
  if SPPageDragOverComp = nil then Exit;
  DrawComp := SPPageDragOverComp;
  // Set CMMCurDragOverComp new State
  PUP := N_GetUserParPtr(TN_UDCompBase(DrawComp).R, 'DropSelShow');
  if PUP = nil then Exit; // precaution
  PByte(PUP.UPValue.P)^ := AViewState;
  RFrame.RedrawAllAndShow();

  if AViewState = 0 then
    SPPageDragOverComp := nil;
end; // procedure TK_FormCMPrint.RedrawDragOverComponent

//****************************************** TK_FormCMPrint1.DrawPrintThumb ***
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
procedure TK_FormCMPrint1.DrawPrintThumb( ADGObj: TN_DGridBase; AInd: integer;
                                                           const ARect: TRect );
var
  Slide : TN_UDCMSlide;
  Ind, LinesCount : Integer;
  SlideDrawFlags : Byte;
begin
  with N_CM_GlobObj, N_CM_MainForm do
  begin
    Ind := SPUnUsedInds[AInd];
    if Ind < 0 then Exit; // Precaution
    Slide := SPUDSlides[Ind];

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

    end; // with Slide.P^ do

    if TObject(Slide) = TObject(CMMFActiveEdFrameSlideStudy) then
      SlideDrawFlags := SlideDrawFlags or 1; // currently active Mount Study, mark it

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
end; // procedure TK_FormCMPrint1.DrawPrintThumb

//********************************* TK_FormCMPrint.EnabledFillClearControls ***
// Enabled/Diabled Fill/Clear Controls
//
procedure TK_FormCMPrint1.EnabledFillClearControls();
begin
  BtFillAll.Enabled := SPSlidesPrintDGrid.DGNumItems > 0;
  BtClearAll.Enabled := SPSlidesCount <> SPSlidesPrintDGrid.DGNumItems;
end; // procedure TK_FormCMPrint1.EnabledFillClearControls

//******************************************** TK_FormCMPrint1.GetThumbSize ***
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
//  Is used as value of DGrid.DGGetItemSizeProcObj field
//
procedure TK_FormCMPrint1.GetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Ind : Integer;
begin
  Ind := SPUnUsedInds[AInd];
  if Ind < 0 then Exit; // Precaution
  N_CM_MainForm.CMMFGetSlideDGridThumbSize( TN_UDCMBSlide(SPUDSlides[Ind]),
                              ADGObj, AInpSize, AOutSize, AMinSize, APrefSize, AMaxSize );
end; // procedure TK_FormCMPrint1.GetThumbSize

//***************************************** TK_FormCMPrint1.ClearUsedSlides ***
// Move Used Slides to Unused by Used Indexes range
//
//     Parameters
// ASInd - first Index
// AEInd - last Index
//
procedure TK_FormCMPrint1.ClearUsedSlides( ASInd, AEInd : Integer; AMoveToBegin : Boolean );
var
  i, j, Ind : Integer;
begin
  N_Dump2Str( format('Clear Used start from %d to %d', [ASInd,AEInd] ) );
  j := SPSlidesPrintDGrid.DGNumItems;
  for i := ASInd to AEind do
  begin
    Ind := SPUsedInds[i];
    if Ind < 0 then Continue;
    N_Dump2Str( format('Clear ID=%s PagePos=%d to unused Pos=%d', [SPUDSlides[Ind].ObjName,i,j] ) );
    SPUnUsedInds[j] := SPUsedInds[i];
    Inc(j);
    SPUsedInds[i] := -1;
  end;
  if j = SPSlidesPrintDGrid.DGNumItems then Exit;

  if AMoveToBegin and (SPSlidesPrintDGrid.DGNumItems > 0) then
  begin
    Ind := j - SPSlidesPrintDGrid.DGNumItems;
    Move( SPUnUsedInds[0], SPUnUsedIndsB[0], SPSlidesPrintDGrid.DGNumItems * SizeOf(Integer) );
    Move( SPUnUsedInds[SPSlidesPrintDGrid.DGNumItems], SPUnUsedInds[0], Ind * SizeOf(Integer) );
    Move( SPUnUsedIndsB[0], SPUnUsedInds[Ind], SPSlidesPrintDGrid.DGNumItems * SizeOf(Integer) );
  end;
  // Rebuild Unused Slides Frame
  SPSlidesPrintDGrid.DGNumItems := j;
  SPSlidesPrintDGrid.DGInitRFrame(); // should be called after all CMMFThumbsDGrid fields are set
  SPSlidesPrintDGrid.DGSelectedInd := -1;

//  ClearLogoChangePosMode();
  LogoChangeOK(nil);

  ShowPageByNumber( -2 ); // Rebuild current Page
  EnabledFillClearControls();
  N_Dump2Str( 'Clear Used fin' );
end; // procedure TK_FormCMPrint1.ClearUsedSlides

//****************************************** TK_FormCMPrint1.FillUsedSlides ***
// Move Unused Slides to Used by Used Indexes range
//
//     Parameters
// ASInd - first Index
// AEInd - last Index
// AFillCount - number of unused slides to use, if =0 then all not used
//
procedure TK_FormCMPrint1.FillUsedSlides( ASInd, AEInd, AUnUsedInd : Integer );
var
  i, j, Ind, n : Integer;
begin
  N_Dump2Str( format('Fill Used start from %d to %d by unused Pos=%d', [ASInd,AEInd,AUnUsedInd] ) );
  j := 0;
  if AUnUsedInd >= 0 then
    j := AUnUsedInd;
  n := 0;
  for i := ASInd to AEInd do
  begin
    Ind := SPUsedInds[i];
    if Ind >= 0 then Continue;
    N_Dump2Str( format('Fill PagePos=%d by unused ID=%s Pos=%d', [i,SPUDSlides[SPUnUsedInds[j]].ObjName,j] ) );
    SPUsedInds[i] := SPUnUsedInds[j];
    Inc(n);
    Inc(j);
    if (AUnUsedInd >= 0) or (n = SPSlidesPrintDGrid.DGNumItems) then break;
  end;
  if (n = 0) or ((AUnUsedInd >=0) and (j = AUnUsedInd)) then Exit; // Precaution

  // Rebuild Unused Slides Frame
  i := SPSlidesPrintDGrid.DGNumItems - n;
  if i > 0 then
  begin
    if AUnUsedInd < 0 then
      Move( SPUnUsedInds[j], SPUnUsedInds[0], i * SizeOf(Integer) )
    else
    if SPSlidesPrintDGrid.DGNumItems > j then
      Move( SPUnUsedInds[j], SPUnUsedInds[j - 1], (SPSlidesPrintDGrid.DGNumItems - j) * SizeOf(Integer) )
  end;

  SPSlidesPrintDGrid.DGNumItems := i;
  SPSlidesPrintDGrid.DGInitRFrame(); // should be called after all CMMFThumbsDGrid fields are set
  SPSlidesPrintDGrid.DGSelectedInd := -1;

//  ClearLogoChangePosMode();
  LogoChangeOK(nil);

  ShowPageByNumber( -2 ); // Rebuild current Page
  EnabledFillClearControls();
  N_Dump2Str( 'Fill Used fin' );
end; // procedure TK_FormCMPrint1.FillUsedSlides

//**************************************** TK_FormCMPrint1.SetLayoutContext ***
// Set current Layout Context
//
procedure TK_FormCMPrint1.SetLayoutContext();
var
  CurUsedIndsCount, PrevUsedIndsCount, i, j, CurLayoutPageOrientation : Integer;
begin
  N_Dump2Str( 'SetLayoutContext start ' + IntToStr(SPCurLayoutID) );

  BtNextLayout.Enabled := SPCurLayoutID < CmBPrintTemplates.Items.Count - 1;
  BtPrevLayout.Enabled := SPCurLayoutID > 0;

  SPPrevMaxPageSlidesCount := SPMaxPageSlidesCount;

  if SPCurLayoutID <> 0 then
  begin // Static Page Layout
  // Disable Table Lauout Controls
{}
    EdRowCount.Color := clWindow;
    EdRowCount.Enabled := FALSE;
    UDRowCount.Enabled := FALSE;
    EdColCount.Color := clWindow;
    EdColCount.Enabled := FALSE;
    UDColCount.Enabled := FALSE;
{}
{
    EdRowCount.Visible := FALSE;
    UDRowCount.Visible := FALSE;
    EdColCount.Visible := FALSE;
    UDColCount.Visible := FALSE;
{}
  // Set Static Layout Properties
    SPMaxPageSlidesCount := Length(SPTemplatePageCoords[SPCurLayoutID - 1]);
  end
  else
  begin // Table Layout
  // Enable Controls
{}
    EdColCount.Color := $00A2FFFF;
    EdColCount.Enabled := TRUE;
    UDColCount.Enabled := TRUE;
    EdRowCount.Color := $00A2FFFF;
    EdRowCount.Enabled := TRUE;
    UDRowCount.Enabled := TRUE;
{}
{
    EdRowCount.Visible := TRUE;
    UDRowCount.Visible := TRUE;
    EdColCount.Visible := TRUE;
    UDColCount.Visible := TRUE;
{}
  // Set Table Layout Properties
    SPPageSlidesCCount := StrToInt( EdColCount.Text );
    SPPageSlidesRCount := StrToInt( EdRowCount.Text );
    SPMaxPageSlidesCount := SPPageSlidesRCount * SPPageSlidesCCount;
  end;
  CurLayoutPageOrientation := SPTemplatePageOrientation[SPCurLayoutID];

  InitPageCounter( TRUE );

  /////////////////////////////////////////
  // Change Slides Used Info by new Layout
  //
  PrevUsedIndsCount := Length(SPUsedInds);
  // Calc new Used Slides Inds Array Length
  if SPCurLayoutID = 0 then
    CurUsedIndsCount := SPSlidesCount
  else
    CurUsedIndsCount := SPPageCount * SPMaxPageSlidesCount;


  i := CurUsedIndsCount - PrevUsedIndsCount;
  if i > 0 then
  begin // New UsedIndsCount is greater than prev UsedIndsCount - just fill new Inds with -1
    SetLength( SPUsedInds, CurUsedIndsCount );
    FillChar( SPUsedInds[PrevUsedIndsCount], i * SizeOf(Integer), -1 );
  end
  else
  if i < 0 then
  begin // New UsedIndsCount is less than prev UsedIndsCount
    // Move Used Slides to Unused
    j := SPSlidesPrintDGrid.DGNumItems;
    for i := CurUsedIndsCount to PrevUsedIndsCount - 1 do
    begin
      if SPUsedInds[i] < 0 then Continue;
      SPUnUsedInds[j] := SPUsedInds[i];
      Inc(j);
    end;

    SetLength( SPUsedInds, CurUsedIndsCount );

    // Rebuild UnUsed Slides Frame if some Used Slides were moved to UnUsed
    if SPSlidesPrintDGrid.DGNumItems < j then
    begin
      SPSlidesPrintDGrid.DGNumItems := j;
      SPSlidesPrintDGrid.DGInitRFrame();
      SPSlidesPrintDGrid.DGSelectedInd := -1;
    end;
  end;
  //
  // Change Slides Used Info by new Layout
  /////////////////////////////////////////

  /////////////////////////////////////////
  // Define Page Orientation by new Layout
  //
  if CurLayoutPageOrientation <> 2 then
  begin // Layout has fixed page orientation
    RBLandscape.Enabled := FALSE;
    RBPortrait.Enabled  := FALSE;
    if CurLayoutPageOrientation <> Ord(Printer.Orientation) then
    begin // Change Page Orientation
      if CurLayoutPageOrientation = 0 then
      begin // Change Page Orientation to Portrait
        RBPortrait.Checked  := TRUE;
        RBLandscape.Checked := FALSE;
        if Printer.Orientation = poLandscape then
        begin
          RBPortraitClick(nil);
          Exit; // Visible Page will be rebuild during Page orientation change
        end;
      end
      else
      begin // Change Page Orientation to Landscape
        RBPortrait.Checked  := FALSE;
        RBLandscape.Checked := TRUE;
        if Printer.Orientation = poPortrait then
        begin
          RBLandscapeClick(nil);
          Exit; // Visible Page will be rebuild during Page orientation change
        end;
      end;
    end;
  end   // Layout has fixed page orientation
  else
  begin // Layout has dual page orientation
    RBLandscape.Enabled := TRUE;
    RBPortrait.Enabled  := TRUE;
  end;
  //
  // Define Page Orientation by new Layout
  /////////////////////////////////////////

  LogoChangeOK(nil);
  ShowPageByNumber( -3 ); // Just rebuild current page

  N_Dump2Str( 'SetLayoutContext fin' );

end; // procedure TK_FormCMPrint1.SetLayoutContext

//************************************************ TK_FormCMPrint1.InitLogo ***
// Set current Layout Context
//
procedure TK_FormCMPrint1.InitLogo( ALogoDIB : TN_DIBObj );
begin

///////////////////////////////
// Init Logo
//
  if LongWord(ALogoDIB) < 10 then
    ALogoDIB := nil;
  SPLogoUDRoot := TN_UDCompBase( SPPageRootUDComp.DirChild(2) );
  SPLogoUDDIBRoot := TN_UDCompBase(SPLogoUDRoot.DirChild(0) );
  SPLogoUDFrame := TN_UDCompBase(SPLogoUDRoot.DirChild(1));
  SPLogoUDDIB := nil;
  with SPLogoUDDIBRoot.PSP.CCompBase do
    if ALogoDIB = nil then
      CBSkipSelf := 255
    else
    begin
      CBSkipSelf := 0;

      SPLogoUDDIB := TN_UDCompBase(SPLogoUDDIBRoot.DirChild(0));
      if SPLogoUDDIB = nil then
      begin // Create Logo DIB UDTree
        // Create Picture Root Component
        TN_UDCompVis(SPLogoUDDIB) := N_CreateMapRoot2(N_CMDIBURect, ALogoDIB.DIBSize, catSize, 'LogDIBRoot');
        with TN_UDCompVis(SPLogoUDDIB), PSP^, CCompBase, PCCS()^ do
        begin
          // for printing only
          CBFlags1 := [cbfSelfSizeUnits];
          CurFreeFlags := [cffFullAspSize];
{
          if CPanel <> nil then
            with TN_PCPanel(CPanel.P())^ do //
              PaBackColor := N_EmptyColor;
}
        end;
        SPLogoUDDIB.ClassFlags := SPLogoUDDIB.ClassFlags + K_SkipSelfSaveBit;
        SPLogoUDDIBRoot.AddOneChild( SPLogoUDDIB );

        // Create Picture UDDIB Component
        SPLogoUDDIB := TN_UDCompBase( SPLogoUDDIB.AddOneChild(
                            N_CreateUDDIB(N_CMDIBURect, [], '', 'LogoUDDIB') ) );
//        SPLogoUDDIB.ClassFlags := SPLogoUDDIB.ClassFlags + K_SkipSelfSaveBit;
      end
      else
      begin
        with TN_UDCompVis(SPLogoUDDIB), PCCS()^ do
          SRSize := FPoint( ALogoDIB.DIBSize ); // Set Size to Picture Root Component

        // Get Picture UDDIB Component
        SPLogoUDDIB := TN_UDCompBase(SPLogoUDDIB.DirChild(0));
        TN_UDDIB(SPLogoUDDIB).DIBObj.Free(); // free previouse DIB
      end;

      TN_UDDIB(SPLogoUDDIB).DIBObj := ALogoDIB;
    end; // LogoDIB <> nil
//
//  Init Logo
////////////////////////////////
end; // procedure TK_FormCMPrint1.InitLogo

//********************************** TK_FormCMPrint1.ClearLogoChangePosMode ***
// Clear LogoChangePos Mode
//
procedure TK_FormCMPrint1.ClearLogoChangePosMode();
begin
  N_Dump2Str('ClearLogoChangePosMode start');
  // Clear LogoChangePos mode
  if ChBLogoChangePos.Checked and not SPSkipLogoChangePosClear then
  begin
    SPSkipLogoRFrameRedrawAllAndShow := TRUE;
    ChBLogoChangePos.Checked := FALSE;
    SPSkipLogoRFrameRedrawAllAndShow := FALSE;
  end;
  N_Dump2Str('ClearLogoChangePosMode fin');
end; // procedure TK_FormCMPrint1.ClearLogoChangePosMode

end.

