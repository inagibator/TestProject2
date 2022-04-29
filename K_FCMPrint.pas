unit K_FCMPrint;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, ExtCtrls, StdCtrls, Buttons, ActnList, IniFiles,
  N_Types, N_BaseF, N_CompBase, N_Rast1Fr, N_SGComp,
  K_UDT1, K_CM0;

//type TK_CMSPGetGroupAttrsFunc = procedure( AGroupAttrs : TStrings ) of object;
//type TK_CMSPGetSlideAttrsFunc = procedure( ASlide : TN_UDBase;
//                                           out ASlideUDVTree, ASlideImage : TN_UDBase;
//                                           ASlideAttrs : TStrings ) of object;
type TK_FormCMPrint = class(TN_BaseForm)
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
        ChBHCenter: TCheckBox;
        ChBVCenter: TCheckBox;
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
        GBPageOrientation: TGroupBox;
          RBPortrait: TRadioButton;
          RBLandscape: TRadioButton;

      GBPageMargins: TGroupBox;
        EdMarginTop: TLabeledEdit;
        EdMarginBottom: TLabeledEdit;
        EdMarginLeft: TLabeledEdit;
        EdMarginRight: TLabeledEdit;
        UDMarginRight: TUpDown;
        UDMarginLeft: TUpDown;
        UDMarginTop: TUpDown;
        UDMarginBottom: TUpDown;
        ChBtSetMinMargins: TCheckBox;
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
  procedure ChBtSetMinMarginsClick  ( Sender: TObject );
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

  SPCurPageSSInd : Integer; // current page start slide index
  SPCurPageSFInd : Integer; // current page finish slide index
  SPPageCount : Integer; // current Pages Counter
  SPCurPageNum   : Integer; // current Page Number
  SPFirstPrintPage: Integer; // First Print Page
  SPLastPrintPage : Integer; // Last Print Page

  SMaxPageSlidesCount: Integer;  // current Page Slides Counter
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

  procedure SetCmBSlideScaleState();
  procedure GetPrinterInfo();
  procedure GetEDMargins();
  procedure BuildPageSlidePosComps();
  procedure InitPageCounter();
  procedure RebuildControlsByPageRange();
  procedure RebuildPagesRangeToPrint();
  procedure UpdateMarginsByPrinterSettings();
  procedure UpdateMarginsUpDown0;
  procedure UpdateMarginsUpDown;
  procedure SetFNumMinMax;
  procedure ShowPageByNumber( ACurPageNum : Integer );
  procedure RebuildCurPageView;
  procedure SetUDCompTextMacroValues( UDComp: TN_UDBase;
                                      MacroTexts, MacroVaues : TStrings );
  procedure ClearSlidesPrintingFlag();
  procedure ClearPageSlideComps();
  procedure RedrawDragOverComponent( AViewState : Integer );
public
  { Public declarations }
//    SPGetGroupAttrs : TK_CMSPGetGroupAttrsFunc;

  SPUDSlides : TN_UDCMSArray;  // printing Slides array
  SPPUDSlides : TN_UDCMSArray;  // printed Slides array
  SPSlidesCount : Integer;      // printed Slides Counter
  SPStudiesOnlyFlag : Boolean;

  SPUsedInds   : TN_IArray;  // printing Slides Used Indexes array
  SPUnUsedInds : TN_IArray;  // printing Slides Unused Indexes array

//  SPGetSlideAttrs : TK_CMSPGetSlideAttrsFunc;
  procedure InitRFrameCoords;
  procedure PreparePrintList( APrintList : TN_UDCMSArray );
  procedure InitPreview();
//  procedure SetSlidesList( APUObj : Pointer; AUStep, AUCount : Integer  );
  procedure CurStateToMemIni (); override;
  procedure MemIniToCurState (); override;
end;

var
  K_FormCMPrint: TK_FormCMPrint;

implementation

{$R *.dfm}
uses
  Printers, Math,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  System.Contnrs,
{$IFEND CompilerVersion >= 26.0}
  N_Lib2, N_Lib1, N_Lib0, N_ButtonsF,
  N_Gra0, N_Gra1, N_Gra2, N_GCont, N_CMResF, N_CompCL, N_Comp1,
  K_CLib0, K_CLib, K_Script1, K_UDT2, K_CML1F, K_VFunc;


//***********************************  TK_FormCMPrint.FormShow  ******
//
procedure TK_FormCMPrint.FormShow(Sender: TObject);
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
//  RFrame.OnMouseDownProcObj := RFrameMouseDown;


  UpdateMarginsByPrinterSettings();
  UpdateMarginsUpDown();

  InitPreview();

  RBPageAll.Checked := true;
  RBPageAllClick( nil );

  //  BtPrint.SetFocus();
end; // end of TK_FormCMPrint.FormShow

//***********************************  TK_FormCMPrint.RebuildCurPageView ***
//  Before real Form close action to free allocated objects
//
procedure TK_FormCMPrint.FormCloseQuery( Sender: TObject;
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
end; // end of TK_FormCMPrint.FormCloseQuery

//***********************************  TK_FormCMPrint.FormResize ***
//
procedure TK_FormCMPrint.FormResize(Sender: TObject);
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
procedure TK_FormCMPrint.BBPrinterSetUpClick(Sender: TObject);
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
procedure TK_FormCMPrint.PrinterSetupDialogClose( Sender: TObject );
begin
  TimerMin.Enabled := True;
  SPPrinterChagedFlag := true;
end; //*** end of TK_FormCMPrint.PrinterSetupDialogClose

//*************************************** TK_FormCMPrint.TimerTimer
//  Number Changing and Printer Changing Timer Control Event
//
procedure TK_FormCMPrint.TimerMinTimer( Sender: TObject );
var
  RebuildCurPageViewFlag : Boolean;
  NewVal : Double;
  ErrCode : Integer;
begin
  TimerMin.Enabled := False;
  RebuildCurPageViewFlag := false;
  if SPSkipINumEvent then begin
    SPSkipINumEvent := false;
    SPInpPrev := StrToIntDef( SPInpTEdit.Text, SPInpPrev );
    SPInpTEdit.Text := IntToStr( SPInpPrev );
  end;
  if SPSkipFNumEvent then begin
    SPSkipFNumEvent := false;
    Val( SPInpFTEdit.Text, NewVal, ErrCode );
    if ErrCode > 0 then begin
      SPInpFTEdit.Text := format( SPFloatFieldsFormat, [SPInpFPrev] );
    end else begin
      SPInpFPrev := NewVal;
//    SPInpFPrev := StrToFloatDef( SPInpFTEdit.Text, SPInpFPrev );
      SetFNumMinMax();
//    SPInpFPrev := Max( SPInpFMin, SPInpFPrev );
//      SPInpFPrev := Min( SPInpFMax, SPInpFPrev );
      if SPInpFPrev > SPInpFMax then begin
        SPInpFPrev := 0.95 * SPInpFMax;
        SPInpFTEdit.Text := format( SPFloatFieldsFormat, [SPInpFPrev] );
      end;
      UpdateMarginsUpDown0();
      SPSkipFNumEvent := false;
      GetEDMargins();
      RebuildCurPageViewFlag := true;
    end;
  end;
  if SPPrinterChagedFlag then begin
    SPPrinterChagedFlag := false;
    UpdateMarginsByPrinterSettings();
    UpdateMarginsUpDown();
    RebuildCurPageViewFlag := true;
  end;
  if RebuildCurPageViewFlag then RebuildCurPageView();
end; //*** end of TK_FormCMPrint.TimerTimer

//*************************************** TK_FormCMPrint.TimerMaxTimer
//  Finish Editing Timer Control Event
//
procedure TK_FormCMPrint.TimerMaxTimer(Sender: TObject);
begin
  TimerMax.Enabled := false;
  if SPInpTEdit = nil then Exit;
  SPInpTEdit.Parent.SetFocus();
end; //*** end of TK_FormCMPrint.TimerMaxTimer


//***********************************  TK_FormCMPrint.CurStateToMemIni  ******
//
procedure TK_FormCMPrint.CurStateToMemIni();
begin
  inherited;
  N_StringToMemIni  ( Name+'State', 'CopyCount',    EdCopyCount.Text );
  N_StringToMemIni  ( Name+'State', 'MarginTop',    EdMarginTop.Text );
  N_StringToMemIni  ( Name+'State', 'MarginBottom', EdMarginBottom.Text );
  N_StringToMemIni  ( Name+'State', 'MarginLeft',   EdMarginLeft.Text );
  N_StringToMemIni  ( Name+'State', 'MarginRight',  EdMarginRight.Text );
  if not SPStudiesOnlyFlag then
  begin
    N_StringToMemIni  ( Name+'State', 'ColCount',     EdColCount.Text );
    N_StringToMemIni  ( Name+'State', 'RowCount',     EdRowCount.Text );
  end;
  N_BoolToMemIni    ( Name+'State', 'HCenter',      ChBHCenter.Checked );
  N_BoolToMemIni    ( Name+'State', 'VCenter',      ChBVCenter.Checked );
  N_BoolToMemIni    ( Name+'State', 'PatDetails',   ChBPatDetails.Checked );
  N_BoolToMemIni    ( Name+'State', 'ProvDetails',  ChBProvDetails.Checked );
  N_BoolToMemIni    ( Name+'State', 'ImgDetails',   ChBImgDetails.Checked );
  N_StringToMemIni  ( Name+'State', 'PageTitle',    EdReportTitle.Text );
//  N_BoolToMemIni    ( Name+'State', 'SlideFixZoom', TBSlideFixZoom1.Down );
  N_IntToMemIni     ( Name+'State', 'ScaleIndex',   CmBSlideScale_7.ItemIndex );
  N_BoolToMemIni    ( Name+'State', 'PrintPageHeader',   ChBPrintPageHeader.Checked );
  N_BoolToMemIni    ( Name+'State', 'PrintPageNumber',   ChBPrintPageNumber.Checked );

end; // end of TK_FormCMPrint.CurStateToMemIni

//***********************************  TK_FormCMPrint.MemIniToCurState  ******
//
procedure TK_FormCMPrint.MemIniToCurState();
begin
  SPMemIniToCurStateMode := true;

  inherited;
  EdCopyCount.Text    := N_MemIniToString( Name+'State', 'CopyCount', '1' );
  UDCopyCount.Position := StrToIntDef( EdCopyCount.Text, 1 );
  Printer.Copies := UDCopyCount.Position;
  EdMarginTop.Text    := N_MemIniToString( Name+'State', 'MarginTop', '20.0' );
  EdMarginBottom.Text := N_MemIniToString( Name+'State', 'MarginBottom', '20.0' );
  EdMarginLeft.Text   := N_MemIniToString( Name+'State', 'MarginLeft', '20.0' );
  EdMarginRight.Text  := N_MemIniToString( Name+'State', 'MarginRight', '20.0' );
  if not SPStudiesOnlyFlag then
  begin
    EdColCount.Text     := N_MemIniToString( Name+'State', 'ColCount', '2' );
    UDColCount.Position := StrToIntDef( EdColCount.Text, 20 );
    EdRowCount.Text     := N_MemIniToString( Name+'State', 'RowCount', '2' );
    UDRowCount.Position := StrToIntDef( EdRowCount.Text, 20 );
  end
  else
  begin
    EdColCount.Text     := '1';
    UDColCount.Position :=  1;
    EdRowCount.Text     := '1';
    UDRowCount.Position :=  1;
  end;
  ChBHCenter.Checked := N_MemIniToBool( Name+'State', 'HCenter', TRUE );
  ChBVCenter.Checked := N_MemIniToBool( Name+'State', 'VCenter', TRUE );
  ChBPatDetails.Checked := N_MemIniToBool( Name+'State', 'PatDetails', TRUE );
  ChBProvDetails.Checked := N_MemIniToBool( Name+'State', 'ProvDetails', TRUE );
  ChBImgDetails.Checked := N_MemIniToBool( Name+'State', 'ImgDetails', TRUE );
  EdReportTitle.Text   := N_MemIniToString( Name+'State', 'PageTitle', '' );
//  TBSlideFixZoom1.Down := N_MemIniToBool( Name+'State', 'SlideFixZoom', FALSE );
  ChBPrintPageHeader.Checked := N_MemIniToBool( Name+'State', 'PrintPageHeader', FALSE );
  ChBPrintPageNumber.Checked := N_MemIniToBool( Name+'State', 'PrintPageNumber', TRUE );

  TBSlideFixZoom1.Down := FALSE;
  TBSlideFitToView.Down := not TBSlideFixZoom1.Down;

//  _CmBSlideScale.Enabled := TBSlideFixZoom1.Down;
  SetCmBSlideScaleState();
  LbSlideScale.Enabled := TBSlideFixZoom1.Down;

  SPMemIniToCurStateMode := false;
end; // end of TK_FormCMPrint.MemIniToCurState

//***********************************  TK_FormCMPrint.EdINumChange ***
//  Integer Values Controls Change Value
//
procedure TK_FormCMPrint.EdINumChange(Sender: TObject);
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
procedure TK_FormCMPrint.EdINumEnter( Sender: TObject );
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
procedure TK_FormCMPrint.EdINumExit( Sender: TObject );
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
procedure TK_FormCMPrint.UDINumChanging( Sender: TObject;
             var AllowChange: Boolean );
begin
  SPSkipINumEvent := true;
end; // end of TK_FormCMPrint.UDINumChanging

//***********************************  TK_FormCMPrint.EdFNumChange ***
//  Margins Controls Change Value
//
procedure TK_FormCMPrint.EdFNumChange(Sender: TObject);
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
procedure TK_FormCMPrint.EdFNumEnter( Sender: TObject );
begin
  SPSkipFNumEvent := false;
  SPInpFTEdit := TLabeledEdit(Sender);
  SetFNumMinMax();
  SPInpFPrev := StrToFloatDef( TLabeledEdit(Sender).Text, SPInpFMin );
end; // end of TK_FormCMPrint.EdFNumEnter

//***********************************  TK_FormCMPrint.EdFNumExit ***
//  Margins Controls Finish Editing
//
procedure TK_FormCMPrint.EdFNumExit( Sender: TObject );
begin
  TimerMax.Enabled := false;
  SPInpFTEdit := nil;
end; // end of TK_FormCMPrint.EdFNumExit

//***********************************  TK_FormCMPrint.UDFNumClick ***
//  Margins UpDown Controls finish changing
//
procedure TK_FormCMPrint.UDFNumClick( Sender: TObject;
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
procedure TK_FormCMPrint.UDFNumChanging( Sender: TObject;
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
procedure TK_FormCMPrint.EdBegPageEnter(Sender: TObject);
begin
  EdINumEnter( Sender );
  SPInpMax  := StrToIntDef( EdEndPage.Text, SPPageCount );
  SPInpMin  := 1;
  if SPLastPrintPage <> SPInpMax then RebuildPagesRangeToPrint();
end; // end of TK_FormCMPrint.EdBegPageEnter

//***********************************  TK_FormCMPrint.EdEndPageEnter ***
//  Pages Range Last Page Start Editing
//
procedure TK_FormCMPrint.EdEndPageEnter(Sender: TObject);
begin
  EdINumEnter( Sender );
  SPInpMax  := SPPageCount;
  SPInpMin  := StrToIntDef( EdBegPage.Text, SPPageCount );
  if SPFirstPrintPage <> SPInpMin then RebuildPagesRangeToPrint();
end; // end of TK_FormCMPrint.EdEndPageEnter

//*************************************  TK_FormCMPrint.TBSlideFixZoomClick ***
// EdReportTitle KeyDown Event Handler
//
procedure TK_FormCMPrint.SetCmBSlideScaleState();
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
procedure TK_FormCMPrint.GetPrinterInfo();
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
  if Printer.Orientation = poPortrait then begin
    RBPortrait.Checked := true;
    RBLandscape.Checked := false;
  end else begin
    RBPortrait.Checked := false;
    RBLandscape.Checked := true;
  end;
//  Orientation
end; // end of TK_FormCMPrint.GetPrinterInfo

//***********************************  TK_FormCMPrint.GetEDMargins ***
// Get Margins from edit controls
//
procedure TK_FormCMPrint.GetEDMargins();
begin
  SPMargins.Left := StrToFloatDef( EdMarginLeft.Text, SPMargins.Left );
  SPMargins.Right := StrToFloatDef( EdMarginRight.Text, SPMargins.Right );
  SPMargins.Top := StrToFloatDef( EdMarginTop.Text, SPMargins.Top );
  SPMargins.Bottom := StrToFloatDef( EdMarginBottom.Text, SPMargins.Bottom );
end; // end of procedure TK_FormCMPrint.GetEDMargins

//*********************************** TK_FormCMPrint.BuildPageSlidePosComps ***
// Get Table Layuot parameters from edit controls
//
procedure TK_FormCMPrint.BuildPageSlidePosComps();
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

  if EdColCount.Enabled then
  begin // Use Pattern with Auto Table Pade Layout

    // Prepare Current Table Layout params
    ColCount := SPPageSlidesCCount;
    RowCount := SPPageSlidesRCount;
    if (SPCurPageSSInd = 0)                  and   // first page
       (SMaxPageSlidesCount > SPSlidesCount) then  // not full last page
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
  end   // end of Pattern with Auto Table Pade Layout
  else
  begin // Use Other Print Patterns

  end;  // E]end of Other Print Patterns
end; // procedure TK_FormCMPrint.BuildPageSlidePosComps

//****************************************** TK_FormCMPrint.InitPageCounter ***
// Get Page Layuot parameters from edit controls
//
procedure TK_FormCMPrint.InitPageCounter();
begin
  if EdColCount.Enabled then
  begin // Use Table Pade Layout
    SPPageSlidesCCount := StrToInt( EdColCount.Text );
    SPPageSlidesRCount := StrToInt( EdRowCount.Text );
    SMaxPageSlidesCount := SPPageSlidesRCount * SPPageSlidesCCount;
  end;
  SPPageCount := (SPSlidesCount + SMaxPageSlidesCount - 1) div SMaxPageSlidesCount;
  SPPageCount := Max( SPPageCount, 1 );
  EdBegPage.Text := '1';
  EdEndPage.Text := IntToStr(SPPageCount);

  ChBPrintPageHeader.Enabled := SPPageCount > 1;

  RebuildPagesRangeToPrint();
end; // end of procedure TK_FormCMPrint.InitPageCounter

//******************************  TK_FormCMPrint.RebuildControlsByPageRange ***
// Rebuild Controls by Pages Range
//
procedure TK_FormCMPrint.RebuildControlsByPageRange();
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
procedure TK_FormCMPrint.RebuildPagesRangeToPrint();
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

  if NewPageNum <> SPCurPageNum then
    ShowPageByNumber( NewPageNum )
  else
    RebuildControlsByPageRange();

end; // end of procedure TK_FormCMPrint.RebuildPagesRangeToPrint

//***********************************  TK_FormCMPrint.UpdateMarginsByPrinterSettings ***
// Update Margins by Printer Settings
//
procedure TK_FormCMPrint.UpdateMarginsByPrinterSettings();
begin
  GetPrinterInfo(); // a precaution

  GetEDMargins();

  if SPMargins.Left   < SPMinMargin.X then SPMargins.Left   := SPMinMargin.X;
  if SPMargins.Top    < SPMinMargin.Y then SPMargins.Top    := SPMinMargin.Y;
  if SPMargins.Right  < SPMinMargin.X then SPMargins.Right  := SPMinMargin.X;
  if SPMargins.Bottom < SPMinMargin.Y then SPMargins.Bottom := SPMinMargin.Y;

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
procedure TK_FormCMPrint.UpdateMarginsUpDown0;
begin
  UDMarginTop.Position := Round( StrToFloatDef( EdMarginTop.Text, 20 ) * 10 );
  UDMarginBottom.Position := Round( StrToFloatDef( EdMarginBottom.Text, 20 ) * 10 );
  UDMarginLeft.Position := Round( StrToFloatDef( EdMarginLeft.Text, 20 ) * 10 );
  UDMarginRight.Position := Round( StrToFloatDef( EdMarginRight.Text, 20 ) * 10 );
end; // end of TK_FormCMPrint.UpdateMarginsUpDown0

//***********************************  TK_FormCMPrint.UpdateMarginsUpDown ***
// Set Margins UpDown Controls Limits
//
procedure TK_FormCMPrint.UpdateMarginsUpDown;
begin
  UDMarginRight.Min :=  Round(SPMinMargin.X * 10);
  UDMarginLeft.Min := UDMarginRight.Min;

  UDMarginRight.Max := Round( 5 * SPPaperSize.X );
  UDMarginLeft.Max := UDMarginRight.Max;

  UDMarginTop.Min :=  Round(SPMinMargin.Y * 10);
  UDMarginBottom.Min := UDMarginTop.Min;

  UDMarginTop.Max := Round( 5 * SPPaperSize.Y );
  UDMarginBottom.Max := UDMarginTop.Max;
end; // end of TK_FormCMPrint.UpdateMarginsUpDown

//***********************************  TK_FormCMPrint.SetFNumMinMax ***
// Set Margins Min/Max for Edit Controls
//
procedure TK_FormCMPrint.SetFNumMinMax;
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
procedure TK_FormCMPrint.RBPageRangeClick(Sender: TObject);
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
procedure TK_FormCMPrint.RBPageAllClick(Sender: TObject);
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
procedure TK_FormCMPrint.EdCopyCountExit(Sender: TObject);
begin
  Printer.Copies := StrToIntDef( EdCopyCount.Text, Printer.Copies );
end; // end of TK_FormCMPrint.EdCopyCountExit

//***********************************  TK_FormCMPrint.EdKeyDown ***
// All TEdit Controls KeyDown handler
//
procedure TK_FormCMPrint.EdKeyDown( Sender: TObject;
                                     var Key: Word; Shift: TShiftState );
begin
  if Key <> VK_RETURN then Exit;
  RebuildPagesRangeToPrint();
  BtPrint.SetFocus();
end; // end of TK_FormCMPrint.EdKeyDown

//***********************************  TK_FormCMPrint.ChBtSetMinMarginsClick ***
// Toggle Minimal Paper Margins
//
procedure TK_FormCMPrint.ChBtSetMinMarginsClick(Sender: TObject);
  procedure SetMarginsText( MRect : TFRect );
  begin
    EdMarginLeft.Text   := Format( SPFloatFieldsFormat, [MRect.Left] );
    EdMarginRight.Text  := Format( SPFloatFieldsFormat, [MRect.Right] );
    EdMarginTop.Text    := Format( SPFloatFieldsFormat, [MRect.Top] );
    EdMarginBottom.Text := Format( SPFloatFieldsFormat, [MRect.Bottom] );
  end;
begin
  if ChBtSetMinMargins.Checked then begin
    SPPrevMargins := SPMargins;
    SetMarginsText( FRect( SPMinMargin.X, SPMinMargin.Y, SPMinMargin.X, SPMinMargin.Y ) );
  end else
    SetMarginsText( SPPrevMargins );

  UpdateMarginsUpDown0();
  RebuildCurPageView();

end; // end of TK_FormCMPrint.ChBtSetMinMarginsClick

//***********************************  TK_FormCMPrint.UDMarginsEnter ***
// Set Margins UpDowns Position
//
procedure TK_FormCMPrint.UDMarginsEnter(Sender: TObject);
begin
  UpdateMarginsUpDown0();
end; // end of TK_FormCMPrint.UDMarginsEnter

//***********************************  TK_FormCMPrint.BBPageFirstClick ***
//
procedure TK_FormCMPrint.BBPageFirstClick(Sender: TObject);
begin
//  ShowPageByNumber( 1 );
  ShowPageByNumber( SPFirstPrintPage );
end; // end of TK_FormCMPrint.BBPageFirstClick

//***********************************  TK_FormCMPrint.BBPagePrevClick ***
//
procedure TK_FormCMPrint.BBPagePrevClick(Sender: TObject);
begin
  ShowPageByNumber( SPCurPageNum - 1 );
end; // end of TK_FormCMPrint.BBPagePrevClick

//***********************************  TK_FormCMPrint.BBPageNextClick ***
//
procedure TK_FormCMPrint.BBPageNextClick(Sender: TObject);
begin
  ShowPageByNumber( SPCurPageNum + 1 );
end; // end of TK_FormCMPrint.BBPageNextClick

//***********************************  TK_FormCMPrint.BBPageLastClick ***
//
procedure TK_FormCMPrint.BBPageLastClick(Sender: TObject);
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
procedure TK_FormCMPrint.InitRFrameCoords;
begin
  RFrame.InitializeCoords( @N_DefRFInitParams, @N_DefRFCoordsState );
end; // end of TK_FormCMPrint.InitRFrameCoords

//***********************************  TK_FormCMPrint.PreparePrintList ***
//  Rebuild Preview
//
procedure TK_FormCMPrint.PreparePrintList( APrintList : TN_UDCMSArray );
var
  Ind, i : Integer;
begin
// Clear Media Slides
  i := 0;
  SetLength(SPUDSlides, Length(APrintList) );
  for Ind := 0 to High(APrintList) do begin
    with APrintList[Ind] do
      if (cmsfIsMediaObj in P.CMSDB.SFlags) or
         (cmsfIsImg3DObj in P.CMSDB.SFlags) or
         (K_CMEDAccess.EDACheckSlideMedia( APrintList[Ind] ) = K_edFails) then Continue; // Slide Image is absent or Media File
    SPUDSlides[i] := APrintList[Ind];
    Inc(i);
  end;
  SetLength( SPUDSlides, i );
  SetLength( SPPUDSlides, i );
  SetLength( SPUsedInds, i );
  SetLength( SPUnUsedInds, i );
  SPSlidesCount := i;
end; // end of TK_FormCMPrint.PreparePrintList

//***********************************  TK_FormCMPrint.InitPreview ***
//  Rebuild Preview
//
procedure TK_FormCMPrint.InitPreview;
var
  Ind : Integer;
  S : string;
begin
  InitPageCounter();
// Correct  PageLayout UpDown Controls
//  UDColCount.Max := SPSlidesCount;
//  UDColCount.Position := Min( SPSlidesCount, UDColCount.Position );
//  UDRowCount.Max := SPSlidesCount;
//  UDRowCount.Position := Min( SPSlidesCount, UDRowCount.Position );
//  UDRowCount.Max := SPSlidesCount;
// Prepare Common Macro Values List

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

{ will be used in future when Print sample Manual Fill will be used
  // Set Inds Init State
  FillChar( SPUsedInds[0], SizeOf(Integer) * Length( SPUsedInds), -1 );
//  K_FillIntArrayByCounter( @SPUsedInds[0], Length( SPUsedInds), -1, 0 );
  K_FillIntArrayByCounter( @SPUnUsedInds[0], Length( SPUsedInds) );
}
  // for Print sample AutoFill
  K_FillIntArrayByCounter( @SPUsedInds[0], Length( SPUsedInds) );

// Switch to start Page
  ShowPageByNumber( -1 );
end; // end of TK_FormCMPrint.InitPreview

//***********************************  TK_FormCMPrint.ShowPageByNumber ***
// Prepare UDCompTree and Show Page with given number
//
procedure TK_FormCMPrint.ShowPageByNumber( ACurPageNum : Integer );
var
//  ic, ir : Integer;
  n : Integer;
  UDSlideRoot : TN_UDCompVis;
  UDSlideParent : TN_UDBase;
  UDSlideTree : TN_UDBase;
//  Y0, Y1, X0, X1 : Float;
// SL : TStringList;
  RepDetailsText, RepTitleText : string;
//  ColCount, RowCount, ColDelta : Integer;

// UDSlideImage : TN_UDBase;
// ScaleFactor : Double;
// biXPixPerMeter, biYPixPerMeter : Integer;
  PrintSlide : TN_UDCMSlide;
  i, Ind : Integer;

label Rebuild;
begin
  if SPCurPageNum = ACurPageNum then Exit;
  SPCurPageNum := Max(1, ACurPageNum);
// Set Page Scroll Controls
  LbPageNum.Caption := format( K_CML1Form.LLLPrint2.Caption,
//                             'Page %2d of %2d',
                               [SPCurPageNum, SPPageCount] );
//                               [SPCurPageNum, SPLastPrintPage] );
  RebuildControlsByPageRange();

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


  SPWrkTextsList.Assign( SPSlideTextsList );
  if not ChBImgDetails.Checked then
    for i := 0 to SPWrkTextsList.Count - 1 do
      SPWrkTextsList[i] := SPWrkTextsList.Names[i]+'=';

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
  end;

// Set Current Page Slides Indexes
  SPCurPageSSInd := (SPCurPageNum - 1) * SMaxPageSlidesCount;

//  SPCurPageSlidesCount := SMaxPageSlidesCount;
  SPCurPageSFInd := SPCurPageSSInd + SMaxPageSlidesCount - 1;
  if SPCurPageSFInd >= SPSlidesCount then
    SPCurPageSFInd := SPSlidesCount - 1;

  // Build Page Slides Places Components
  BuildPageSlidePosComps();

  // Link Slides Places Components with Slides
  n := SPCurPageSSInd;

  SetLength( SPPagePlacesGroup.SComps, SPPageSlidesRootUDComp.DirLength() );

  for i := 0 to SPPageSlidesRootUDComp.DirHigh do
  begin
    UDSlideRoot := TN_UDCompVis( SPPageSlidesRootUDComp.DirChild( i ) );

    with SPPagePlacesGroup.SComps[i] do
    begin
      SComp  := TN_UDCompVis(UDSlideRoot);
      SFlags := 0;
      UDSlideRoot.Marker := SPCurPageSSInd + i;
    end;

    Ind := SPUsedInds[n];
    if Ind >= 0 then
    begin
      // Mount Slide to Print sample Get Slide Attrs
      SPSlideMList.Clear;
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
  //        SPSlideMList.Add( 'SlideName='    + ObjName );
  //        SPSlideMList.Add( 'SlideID='      + IntToStr(CMSSelfId) );
        SPSlideMList.Add( 'SlideID='      + ObjName );
        SPSlideMList.Add( 'SlideDTTaken=' + K_DateTimeToStr( CMSDTTaken, 'dd/mm/yyy hh:nn' ) );
        SPSlideMList.Add( 'SlideChartNo=' + K_CMSTeethChartStateToText( CMSTeethFlags ) );

        UDSlideTree  := GetMapRoot();

        if UDSlideTree <> nil then
        begin
          UDSlideParent := UDSlideRoot.GetObjByRPath(SPSlidePatParentPath);
          if UDSlideParent <> nil then
          begin
            Include( CMSRFlags, cmsfIsPrinting );
            UDSlideParent.AddOneChild( UDSlideTree );
          end; // if UDSlideParent <> nil then
        end; // if UDSlideTree <> nil then
      end; // with PrintSlide, P()^  do

      SPSlideMList.Add( 'SlideNum=' + IntToStr(n + 1) );

    // Build Slide Texts
  //      SetUDCompTextMacroValues( UDSlideRoot, SPSlideTextsList, SPSlideMList );
      SetUDCompTextMacroValues( UDSlideRoot, SPWrkTextsList, SPSlideMList );
    end; // if Ind >= 0 then

    Inc(n);
    if n > SPCurPageSFInd then Break;
  end;
{
  // Clear Prevouse Page Slides Components Tree
  ClearSlidesPrintingFlag();
  SPPageSlidesRootUDComp.ClearChilds();

  // Prepare Current Layout
  ColCount := SPPageSlidesCCount;
  RowCount := SPPageSlidesRCount;
  if (SPCurPageSSInd = 0)                  and   // first page
     (SMaxPageSlidesCount > SPSlidesCount) then  // not full last page
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

  //(cmsfIsPrinting in CMSRFlags)

  if (ColCount = 0) or (RowCount = 0) then goto Rebuild; // precaution

  n := SPCurPageSSInd;

  X1 := 100 / ColCount;
  Y1 := 100 / RowCount;

  for ir := 0 to RowCount - 1 do
  begin
    Y0 := ir * Y1;
    X0 := 0;
//    if (ir = RowCount - 1) then begin
    ColDelta := SPCurPageSFInd + 1 - n - ColCount;
    if ColDelta < 0 then
      X0 := -ColDelta * X1 / 2;
//    end;
    for ic := 0 to ColCount - 1 do
    begin
      UDSlideRoot := TN_UDCompVis( SPPageSlidesRootUDComp.AddOneChild(
                                N_CreateSubTreeClone( SPSlidePatRootUDComp ) ) );
    // Set Slide Place Coordinates
      with UDSlideRoot.PCCS^ do
      begin
        BPCoords.X := X0 + ic * X1;
        SRSize.X := X1;
        BPCoords.Y := Y0;
        SRSize.Y := Y1;
      end;

      SPSlideMList.Clear;

    // Get Slide Attrs
      PrintSlide := SPUDSlides[n];
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
//        SPSlideMList.Add( 'SlideName='    + ObjName );
//        SPSlideMList.Add( 'SlideID='      + IntToStr(CMSSelfId) );
        SPSlideMList.Add( 'SlideID='      + ObjName );
        SPSlideMList.Add( 'SlideDTTaken=' + K_DateTimeToStr( CMSDTTaken, 'dd/mm/yyy hh:nn' ) );
        SPSlideMList.Add( 'SlideChartNo=' + K_CMSTeethChartStateToText( CMSTeethFlags ) );

        UDSlideTree  := GetMapRoot();

        if UDSlideTree <> nil then
        begin
          UDSlideParent := UDSlideRoot.GetObjByRPath(SPSlidePatParentPath);
          if UDSlideParent <> nil then
          begin
            Include( CMSRFlags, cmsfIsPrinting );
            UDSlideParent.AddOneChild( UDSlideTree );
          end; // if UDSlideParent <> nil then
        end; // if UDSlideTree <> nil then
      end; // with PrintSlide, P()^  do

      SPSlideMList.Add( 'SlideNum=' + IntToStr(n + 1) );

    // Build Slide Texts
//      SetUDCompTextMacroValues( UDSlideRoot, SPSlideTextsList, SPSlideMList );
      SetUDCompTextMacroValues( UDSlideRoot, SPWrkTextsList, SPSlideMList );
      Inc(n);
      if n > SPCurPageSFInd then goto Rebuild;
    end; // for ic := 0 to ColCount - 1 do
  end; // for ir := 0 to RowCount - 1 do
}
Rebuild:
//  SL.Free;
  RebuildCurPageView();
end; // end of TK_FormCMPrint.ShowPageByNumber


//***********************************  TK_FormCMPrint.RebuildCurPageView ***
//  Rebuild Peview
//
procedure TK_FormCMPrint.RebuildCurPageView;
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

  if Visible then
  begin
    RFrame.RedrawAllAndShow();
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
procedure TK_FormCMPrint.SetUDCompTextMacroValues( UDComp: TN_UDBase;
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
procedure TK_FormCMPrint.UDPageLayoutClick( Sender: TObject;
                                             Button: TUDBtnType );
begin
  InitPageCounter();
  ShowPageByNumber( -1 );
end; // end of TK_FormCMPrint.UDPageLayoutClick

//***********************************  TK_FormCMPrint.BtPrintClick ***
// Print selected pages action
//
procedure TK_FormCMPrint.BtPrintClick(Sender: TObject);
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
  RebuildCurPageView;
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
procedure TK_FormCMPrint.RBPortraitClick(Sender: TObject);
begin
  if Printer.Orientation = poPortrait then Exit;
  Printer.Orientation := poPortrait;
  PrinterSetupDialogClose(Sender);
end; // end of TK_FormCMPrint.RBPortraitClick

//***********************************  TK_FormCMPrint.RBLandscapeClick ***
// Change printer orientation to Landscape
//
procedure TK_FormCMPrint.RBLandscapeClick(Sender: TObject);
begin
  if Printer.Orientation = poLandscape then Exit;
  Printer.Orientation := poLandscape;
  PrinterSetupDialogClose(Sender);
end; // end of TK_FormCMPrint.RBLandscapeClick

//***********************************  TK_FormCMPrint.ChBPatDetailsClick ***
// Change Patient or Provider Details
//
procedure TK_FormCMPrint.ChBPatDetailsClick( Sender: TObject );
begin
  if SPMemIniToCurStateMode then Exit;
  if SPCurPageNum = 1 then
    ChBImgDetailsClick(Sender); // Rebuild Page View
end; // end of TK_FormCMPrint.ChBPatDetailsClick

//***********************************  TK_FormCMPrint.ChBImgDetailsClick ***
// Change Slide Details
//
procedure TK_FormCMPrint.ChBImgDetailsClick(Sender: TObject);
var
  CurPageNum : Integer;
begin
  if SPMemIniToCurStateMode then Exit;
  CurPageNum := SPCurPageNum;
  SPCurPageNum := -1;
  ShowPageByNumber( CurPageNum );
end; // end of TK_FormCMPrint.ChBImgDetailsClick

//***********************************  TK_FormCMPrint.EdReportTitleKeyDown ***
// EdReportTitle KeyDown Event Handler
//
procedure TK_FormCMPrint.EdReportTitleKeyDown( Sender: TObject;
                                var Key: Word; Shift: TShiftState );
begin
  if Key = VK_RETURN then
    ChBPatDetailsClick( Sender );
end; // end of TK_FormCMPrint.EdReportTitleKeyDown

//*************************************  TK_FormCMPrint.TBSlideFixZoomClick ***
// EdReportTitle KeyDown Event Handler
//
procedure TK_FormCMPrint.TBSlideFixZoomClick(Sender: TObject);
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
procedure TK_FormCMPrint.FormKeyDown(Sender: TObject; var Key: Word;
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
procedure TK_FormCMPrint.CmBSlideScale_7Change(Sender: TObject);
begin
  ChBImgDetailsClick(Sender); // Rebuild Page View
end; // end of TK_FormCMPrint._CmBSlideScaleChange

//*************************************  TK_FormCMPrint.ClearSlidesPrintingFlag ***
//
procedure TK_FormCMPrint.ClearSlidesPrintingFlag;
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
procedure TK_FormCMPrint.ClearPageSlideComps;
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

procedure TK_FormCMPrint.RFrameMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  UDComp : TN_UDBase;
begin
  inherited;
  if (ssLeft in Shift) then
  begin
//    if check if mouse is down inside slide place with slide
    RFrame.SearchInAllGroups2( X, Y );
    // Select Page position under cursor
    SPPageDragStartComp := nil;
    SPPageDragOverComp := nil;
    with SPPagePlacesGroup, OneSR do
      if (SRType <> srtNone)then
        SPPageDragStartComp := TN_UDBase(SComps[SRCompInd].SComp);

    // if this position is used by Slide check Drag Start by Timer
    SPDragMode := 0;
    SPCurDragInd := - 1;
    if SPPageDragStartComp <> nil then
    begin
      UDComp := SPPageDragStartComp.GetObjByRPath(SPSlidePatParentPath);
      if (UDComp <> nil) and (UDComp.DirChild(0) <> nil) then
      begin //
        SPDragMode := 1;
        SPCurDragInd := UDComp.Marker;
        StartDragTimer.Enabled := TRUE;
      end;
    end;
  end;

end; // procedure TK_FormCMPrint.RFrameMouseDown

procedure TK_FormCMPrint.RFrameDragOver(Sender, Source: TObject; X,
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

  SPPageDragOverComp := DragOverComp;
  RedrawDragOverComponent( 1 );

end; // procedure TK_FormCMPrint.RFrameDragOver

//********************************** TK_FormCMPrint.RedrawDragOverComponent ***
//
//
procedure TK_FormCMPrint.RedrawDragOverComponent( AViewState : Integer );
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

procedure TK_FormCMPrint.StartDragTimerTimer(Sender: TObject);
begin
//
  StartDragTimer.Enabled := FALSE;
  CancelDrag();
  if (SPDragMode = 1) or (SPDragMode = 2) then
  begin
    SPDragMode := SPDragMode + 4;
    RFrame.BeginDrag( TRUE );
  end
  else
  begin
    SPDragMode := 0;
    SPCurDragInd := - 1;
  end;

end; // procedure TK_FormCMPrint.StartDragTimerTimer

end.

