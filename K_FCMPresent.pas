unit K_FCMPresent;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Contnrs, Types, ActnList, ComCtrls, ToolWin, ImgList,
  N_Types, N_BaseF, N_Rast1Fr, N_CM2, N_DGrid, N_SGComp, N_CompBase,
  K_UDT1, K_CM0;

type
  TK_FormCMPresent = class(TN_BaseForm)
    ThumbPanel: TPanel;
    ThumbsRFrame: TN_Rast1Frame;
    ImgPanel: TPanel;
    ImgRFrame: TN_Rast1Frame;
    ActionList1: TActionList;
    aSelectPrev: TAction;
    aSelectNext: TAction;
    CtrlTimer: TTimer;
    Splitter1: TSplitter;
    Panel1: TPanel;
    BtNext: TButton;
    Panel2: TPanel;
    BtPrev: TButton;
    PnControl: TPanel;
    RBFilmStrip: TRadioButton;
    RBAll: TRadioButton;
    ImageList: TImageList;
    TBControl: TToolBar;
    TBFilmStrip: TToolButton;
    TBAll: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure aSelectPrevExecute(Sender: TObject);
    procedure aSelectNextExecute(Sender: TObject);
    procedure CtrlTimerTimer(Sender: TObject);
    procedure ImgPanelMouseDown(Sender: TObject; Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer);
    procedure ImgPanelMouseUp(Sender: TObject; Button: TMouseButton;
                              Shift: TShiftState; X, Y: Integer);
    procedure RBFilmStripClick(Sender: TObject);
    procedure RBAllClick(Sender: TObject);
    procedure ImgRFramePaintBoxDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ImgRFrameEndDrag(Sender, Target: TObject; X, Y: Integer);
  private
    { Private declarations }
    PRFullScreenForm : TForm;
    PRSlidesRootUDComp : TN_UDCompVis; // slides Parent Component
    PRState : Integer; // bit0=1 - FS is init; bit1=1 - A is init;
                       // bit2=1 - FS is current; bit3=1 - A is current;
                       // bit4=1 - Single Slide is selected from A
    PRMemCheckFlag     : Boolean; //
    PRViewAllThumb     : Boolean; //
    PRMemIniToCurState : Boolean;
    PRSkipImageShow : Boolean;
    PRPageDragStartComp : TN_UDBase;
    PRPageDragOverComp : TN_UDBase;
    PRDragMode : Boolean;
    PRCurDragInd : Integer;


    procedure PRGetThumbSize( ADGObj: TN_DGridBase; AInd: integer; AInpSize: TPoint;
                              out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure PRDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure PRChangeThumbState( ADGObj: TN_DGridBase; AInd: integer);
    function  PRShowImage() : Boolean;
    procedure PRFrameWMKeyDown( var AWMKey: TWMKey );
    procedure PRShowScale( ARFrame: TN_Rast1Frame );
//    procedure PRGetSlideCaptInfo( AUDSlide : TN_UDCMBSlide; out ASDateTime, ASTeethInfo : string );
    procedure PRGetSlideCaptInfo( AUDSlide : TN_UDCMBSlide; var ASDateTime : string );
    procedure PRRebuildAllView();
    procedure PRShowSlideByFilmStrip( AInd : Integer );
    procedure RedrawDragOverComponent( AViewState : Integer );
    procedure RBShowCurByFilmStrip();
  public
    { Public declarations }
    PRSlides : TN_UDCMSArray;
    PRSlideInds : TN_IArray;
    PRThumbsDGrid: TN_DGridArbMatr;
    PRDrawSlideObj: TN_CMDrawSlideObj;
    PRCurSelInd : Integer;
    PRStudyInd : Integer;
    PRDrawInd : Integer;
    PRSlide : TN_UDCMBSlide;
    PRSearchGroup: TN_SGComp;    // Group for Study items
    PRFullScreenScaleFactor : Double;
    PRAllColCount : Integer;
    PRAllRowCount : Integer;
    PRSkipFormShow : Boolean;

    procedure PRSetSlides( APSlides: TN_PUDCMSlide; ACount : Integer );
    procedure PRSwitchToFilmStripView();
    procedure PRInitFilmStripView();
    procedure PRClearAllView();
    procedure PRSwitchToAllView( );
    procedure PRInitAllView();
    procedure PRShowInFullScreenMode();
    procedure CurStateToMemIni   (); override;
    procedure MemIniToCurState   (); override;
  end;

var
  K_FormCMPresent: TK_FormCMPresent;

function K_CMGetPresentForm() : TK_FormCMPresent;

implementation

uses N_CM1, N_Comp1, N_CMMain5F, N_CMResF, N_Lib0, N_Lib1, N_Lib2, N_Gra0,
     K_CML1F, K_CLib0, K_FCMMain5F, K_CM1, K_VFunc, K_CLib;

{$R *.dfm}

//****************************************************** K_CMGetPresentForm ***
// Get Presentation Form
//
function K_CMGetPresentForm(): TK_FormCMPresent;
begin
  N_Dump2Str( 'K_CMGetPresentForm start' );
  K_FormCMPresent := TK_FormCMPresent.Create(Application);

  Result := K_FormCMPresent;

  with K_FormCMPresent do
  begin
{$IF CompilerVersion >= 26.0} // Delphi >= XE5  needed to skip scroll bars blinking in W7-8
    ImgRFrame.VScrollBar.ParentDoubleBuffered := FALSE;
    ImgRFrame.HScrollBar.ParentDoubleBuffered := FALSE;
    ThumbsRFrame.HScrollBar.ParentDoubleBuffered := FALSE;
{$IFEND CompilerVersion >= 26.0}
    DoubleBuffered := True;
    ImgPanel.DoubleBuffered := True;

    PRDrawSlideObj := TN_CMDrawSlideObj.Create();
    PRThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, PRGetThumbSize );

    with PRThumbsDGrid do
    begin
      DGEdges := Rect( 3, 3, 3, 12 );
      DGGaps  := Point( 6, 0 );

      DGLFixNumCols   := 0;
      DGLFixNumRows   := 1;
      DGSkipSelecting := True;
      DGChangeRCbyAK  := True;
      DGMultiMarking  := False;

    //      DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
      DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

      DGBackColor := ColorToRGB(clBtnFace);

      DGMarkNormWidth := 3;
      DGMarkNormShift := 2;

      DGMarkBordColor := $800000;
    //      DGNormBordColor := $808080;
    //  DGNormBordColor := $BBBBBB;
      DGNormBordColor := DGBackColor;

      DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
      DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

      DGDrawItemProcObj := PRDrawThumb;
//      DGDrawItemProcObj := N_CM_MainForm.CMMFDrawThumb;
      DGChangeItemStateProcObj := PRChangeThumbState;
    end; // with ThumbsDGrid do

    with ImgRFrame do
    begin
      DoubleBuffered := True;
      DstBackColor   := ColorToRGB( PaintBox.Color );
      OCanvBackColor := ColorToRGB( PaintBox.Color );

      SkipOnPaint    := False; // to enable filling background if Slide is not set yet

      RFCenterInDst := True;
      RFrActionFlags := RFrActionFlags - [rfafShowColor];
//      RFrActionFlags := RFrActionFlags + [rfafScrollCoords];
      RFrActionFlags := RFrActionFlags + [rfafZoomByPMKeys]; // Zoom by "+" and '-' keys
      RFClearFlags := 0;
      RFDumpEvents := True;
      OnMouseDownProcObj := ImgPanelMouseDown;
      OnMouseUpProcObj := ImgPanelMouseUp;
    end; // with ImgRFrame do

    PRSearchGroup := TN_SGComp.Create( ImgRFrame );
    PRSearchGroup.GName := 'SearchGroup';
    ImgRFrame.RFSGroups.Add( PRSearchGroup );


    ImgRFrame.OnWMKeyDownProcObj := PRFrameWMKeyDown;
    ImgRFrame.RFOnScaleProcObj   := PRShowScale;
    ImgRFrame.RFOnScrollProcObj  := PRShowScale;
    ImgRFrame.RFDebName := 'PRImgRFrame';
    SetStretchBltMode( ImgRFrame.OCanv.HMDC, K_CMStretchBltMode );

    ThumbsRFrame.OnWMKeyDownProcObj := PRFrameWMKeyDown;
    ThumbsRFrame.RFDebName := 'PRThumbs';
    ThumbsRFrame.RFClearFlags := 0;
    ThumbsRFrame.RFDumpEvents := True;

  end;
// 07-11-2014 close for COM StartSession proper work
//  K_CMSAppStartContext.CMASMode := K_cmamWait; // Clear Launch Interface Mode

end; // K_CMGetPresentForm

//********************************************** TK_FormCMPresent.FormShow ***
// Form Show Handler
//
procedure TK_FormCMPresent.FormShow(Sender: TObject);
var
  AML : TStrings;

begin
//  Self.Caption := K_CML1Form.LLLNothingToDo.Caption;

  if PRSkipFormShow then
  begin
    PRSkipFormShow := FALSE;
    Exit;
  end;

  AML := K_CMEDAccess.EDAGetPatientMacroInfo();
  Self.Caption := K_StringMListReplace( 'Px:[(#PatientCardNumber#)] (#PatientFirstName#) (#PatientSurname#)', AML, K_ummRemoveMacro );

  PRState := -1;
  CtrlTimer.Enabled := TRUE;

{
  if RBFilmStrip.Checked then
  begin
    PRInitFilmStripView();
  end
  else
  begin
    PRInitAllView();
    PRRebuildAllView();
  end;
}
end; // TK_FormCMPresent.FormShow

//********************************* TK_FormCMPresent.PRGetThumbSize ***
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
//  Is used as value of SSAThumbsDGrid.DGGetItemSizeProcObj field
//
procedure TK_FormCMPresent.PRGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide : TN_UDCMSlide;
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin
  with N_CM_GlobObj, ADGObj do
  begin
    Slide     := PRSlides[PRSlideInds[AInd]];
    ThumbDIB  := Slide.GetThumbnail();
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
end; // procedure TK_FormCMPresent.PRGetThumbSize

//************************************ TK_FormCMPresent.PRDrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel and may be not equal to upper left Grid pixel )
//
// Is used as value of PRThumbsDGrid.DGDrawItemProcObj field
//
procedure TK_FormCMPresent.PRDrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
var
  Slide : TN_UDCMSlide;
  LinesCount : Integer;
  SlideDrawFlags : Byte;
  FRFrame: TN_Rast1Frame;
  SDT{, STeethInfo} : string;
begin
  with PRThumbsDGrid, DGMarkedList do
  begin
    if (DGItemsFlags[AInd] = 0) and (Count = 1) and not PRSkipImageShow then
    begin
      CtrlTimer.Enabled := TRUE;
    end;
  end;

  with N_CM_GlobObj do
  begin
    Slide := TN_UDCMSlide(PRSlides[PRSlideInds[AInd]]);

    SlideDrawFlags := ADGObj.DGItemsFlags[AInd];
    LinesCount := 1;

//    PRGetSlideCaptInfo( Slide, SDT, STeethInfo );
    PRGetSlideCaptInfo( Slide, SDT );
    CMStringsToDraw[0] := SDT;
//    CMStringsToDraw[1] := STeethInfo;

    FRFrame := nil;
    if Slide = PRSlide then
      FRFrame := ImgRFrame;
    PRDrawSlideObj.DrawOneThumb8( Slide,
                               CMStringsToDraw, LinesCount,
                               ADGObj, ARect,
                               FRFrame,
                               SlideDrawFlags );

  end; // with N_CM_GlobObj do

end; // end of TK_FormCMPresent.PRDrawThumb

//***********************************  TK_FormCMPresent.PRChangeThumbState  ******
// Thumbnail Change State processing (used as TN_DGridBase.DGChangeItemStateProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - Index of Thumbnail that is change state
//
procedure TK_FormCMPresent.PRChangeThumbState(
                                   ADGObj: TN_DGridBase; AInd: integer);
var
  Ind  : Integer;
begin
  with PRThumbsDGrid, DGMarkedList do
  begin
    Ind := Integer(Items[0]);
    aSelectPrev.Enabled := Ind > 0;
    aSelectNext.Enabled := Ind < High(PRSlides);

    if Ind = PRCurSelInd then Exit;

    {Change Selected action};
    PRDrawInd := Ind;
    CtrlTimer.Enabled := TRUE;
    PRCurSelInd := Ind;
  end;

end; // end of TK_FormCMPresent.PRChangeThumbState

//******************************************** TK_FormCMPresent.PRSetSlides ***
// Show given slides in High resolution Preview Mode
//
//    Parameters
// APSlides     - pointer to Slides array first element
// ACount       - number of elements in Slides array
// ACurSlideSID - 1-st selected Slide ID
//
procedure TK_FormCMPresent.PRSetSlides( APSlides: TN_PUDCMSlide;
                                              ACount: Integer );
begin
  N_Dump1Str( format( 'TK_FormCMPresent >> PRSetSlides N=%d', [ACount] ) );
  SetLength( PRSlides, ACount );
  SetLength( PRSlideInds, ACount );
  if ACount = 0 then Exit;
  Move( APSlides^, PRSlides[0], ACount * SizeOf(TN_UDCMSlide) );
  K_FillIntArrayByCounter( @PRSlideInds[0], ACount );
end; // procedure TK_FormCMPresent.PRShowSlides

//******************************** TK_FormCMPresent.PRSwitchToFilmStripView ***
// Switch to Film Strip view
//
procedure TK_FormCMPresent.PRSwitchToFilmStripView( );
begin
  N_Dump2Str( 'TK_FormCMPresent >> PRSwitchToFilmStripView start' );
  PRState := (PRState and 3) or 4;
  CtrlTimer.Interval := 10;
  with PRSearchGroup do
  begin
    PixSearchSize := 15;
    SGFlags := $02 + // search lines even out of UDPolyline and UDArc components
               $04;  // do redraw actions loop witout objects
  end;
  Splitter1.Visible  := TRUE;
  ThumbPanel.Visible := TRUE;
  ImgRFrame.RFrInitByComp( nil );
  ImgRFrame.ShowMainBuf();
  N_Dump2Str( 'TK_FormCMPresent >> PRSwitchToFilmStripView fin' );
end; // procedure TK_FormCMPresent.PRSwitchToFilmStripView

//************************************ TK_FormCMPresent.PRInitFilmStripView ***
// Init Film Strip view
//
procedure TK_FormCMPresent.PRInitFilmStripView( );
begin
  N_Dump2Str( 'TK_FormCMPresent >> PRInitFilmStripView start' );
  PRSwitchToFilmStripView( );
  PRState := PRState or 1;
  with PRThumbsDGrid do
  begin
    DGNumItems := Length(PRSlides);
    DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
    PRCurSelInd := -1;
    PRStudyInd := -1;
    DGMarkSingleItem( 0 );
  end; // with ThumbsDGrid do
  N_Dump2Str( 'TK_FormCMPresent >> PRInitFilmStripView fin' );
end; // procedure TK_FormCMPresent.PRInitFilmStripView

//***************************************** TK_FormCMPresent.PRClearAllView ***
// Init all view
//
procedure TK_FormCMPresent.PRClearAllView( );
var
  i : Integer;
begin
  if PRSlidesRootUDComp = nil then Exit;
  with PRSlidesRootUDComp do
  begin
    for i := 0 to DirHigh do
      DirChild(i).ClearChilds();
    ClearChilds();
  end;
end; // procedure TK_FormCMPresent.PRClearAllView

//************************************** TK_FormCMPresent.PRSwitchToAllView ***
// Switch to All view
//
procedure TK_FormCMPresent.PRSwitchToAllView( );
begin
  N_Dump2Str( 'TK_FormCMPresent >> PRSwitchToAllView start' );
  PRState := (PRState and 3) or 8;

  CtrlTimer.Interval := 300;

  with PRSearchGroup do
  begin
    PixSearchSize := 5;
    SGFlags := 0;
  end;

  ThumbPanel.Visible := FALSE;
  Splitter1.Visible  := FALSE;
  ImgRFrame.RFrInitByComp( nil );
  ImgRFrame.ShowMainBuf();
  N_Dump2Str( 'TK_FormCMPresent >> PRSwitchToAllView fin' );

end; // procedure TK_FormCMPresent.PRSwitchToAllView

//****************************************** TK_FormCMPresent.PRInitAllView ***
// Init all view
//
procedure TK_FormCMPresent.PRInitAllView( );
var
  ColDelta : Integer;
  Y0, Y1, X0, X1 : Float;
  ic, ir, n : Integer;
  UDSlideParent, UDSlideRoot : TN_UDCompVis;
  SlidePatRootUDComp : TN_UDCompVis;
  SlidesCount : Integer;
  BColor : Integer;
begin
  N_Dump2Str( 'TK_FormCMPresent >> PRInitAllView start' );
  PRSwitchToAllView( );
  PRState := PRState or 2;
  PRMemCheckFlag := TRUE;

  if PRSlidesRootUDComp = nil then
    PRSlidesRootUDComp :=  TN_UDCompVis(K_CMEDAccess.ArchPrnPageSlidesRoot);

//  ColCount := SPPageSlidesCCount;
//  RowCount := SPPageSlidesRCount;
//  ColCount := 4;
//  RowCount := 4;
  SlidesCount := Length(PRSlides);

  // Rebuild Current Layout if Slides number is less then PageLayout capacity
  PRAllColCount := Round( sqrt( SlidesCount ) );
  PRAllRowCount := 0;
  if PRAllColCount <> 0 then // precaution
    PRAllRowCount := Round( SlidesCount/PRAllColCount );

  if PRAllRowCount * PRAllColCount < SlidesCount then
    PRAllRowCount := PRAllRowCount + 1;

  if ((PRAllColCount / PRAllRowCount < 1) and (Width / Height > 1)) or
     ((PRAllColCount / PRAllRowCount > 1) and (Width / Height < 1)) then
  begin
    n := PRAllColCount;
    PRAllColCount := PRAllRowCount;
    PRAllRowCount := n;
  end;


  n := 0;
  X1 := 100 / PRAllColCount;
  Y1 := 100 / PRAllRowCount;
  SlidePatRootUDComp   := TN_UDCompVis(K_CMEDAccess.ArchPrnSlidePatRoot);
  BColor := ColorToRGB( ImgRFrame.PaintBox.Color );
  for ir := 0 to PRAllRowCount - 1 do
  begin
    // Calc Slide Root Componenet Position
    Y0 := ir * Y1;
    X0 := 0;
    ColDelta := SlidesCount - n - PRAllColCount;
    if ColDelta < 0 then
      X0 := -ColDelta * X1 / 2;

    for ic := 0 to PRAllColCount - 1 do
    begin
      UDSlideRoot := TN_UDCompVis( PRSlidesRootUDComp.AddOneChild(
                                N_CreateSubTreeClone( SlidePatRootUDComp ) ) );
    // Set Slide Place Position and Size
      with UDSlideRoot.PCCS^ do
      begin
        BPCoords.X := X0 + ic * X1;
        SRSize.X := X1;
        BPCoords.Y := Y0;
        SRSize.Y := Y1;
      end;
      UDSlideParent := TN_UDCompVis( UDSlideRoot.GetObjByRPath('SlideParent\SlidePosScale') );
      UDSlideParent.PCPanelS()^.PaBackColor := BColor;
      Inc(n);
      if n >= SlidesCount then Exit;
    end; // for ic := 0 to ColCount - 1 do
  end; // for ir := 0 to RowCount - 1 do

  N_Dump2Str( 'TK_FormCMPresent >> PRInitAllView fin' );
end; // procedure TK_FormCMPresent.PRInitAllView

//********************************* TK_FormCMPresent.PRShowInFullScreenMode ***
// Show current selected slide in full screen mode
//
procedure TK_FormCMPresent.PRShowInFullScreenMode( );
var
  hTaskBar: THandle;
  FullScreenScaleFactor : Double;

//  MonitorIndex: integer;
//  NeededHeight, NeededWidth, NeededLeft, NeededTop : integer;
//  CurMonitor : TMonitor;
  NeededRect, CurFormRect, CurMonitorRect : TRect;

begin
  if PRSlide = nil then exit; // precaution
  N_Dump2Str( 'TK_FormCMPresent >> FullScreen Preview ID=' + PRSlide.ObjName );

//  FullScreenScaleFactor := ImgRFrame.RFGetCurRelObjSize();
  NeededRect := K_PrepFullScreenInfo( Self, CurFormRect, CurMonitorRect );
{
  with Self do
    CurFormRect := IRect( Left, Top, Left + Width, Top + Height );
  N_GetMonWARByRect( CurFormRect, @MonitorIndex );
  CurMonitor := Screen.Monitors[MonitorIndex];

  with CurMonitor do
  begin
    CurMonitorRect := WorkareaRect;
    NeededHeight := WorkareaRect.Bottom - WorkareaRect.Top;
    NeededWidth  := WorkareaRect.Right - WorkareaRect.Left;
    NeededLeft   := WorkareaRect.Left;
    NeededTop    := WorkareaRect.Top;
    if Primary then // Current Monitor is Primary
    begin
    // use whole Monitor Size instead of Work Area Size
    // (TaskBar is present only on Primary monitor)
      NeededHeight := Height;
      NeededWidth  := Width;
      NeededLeft   := Left;
      NeededTop    := Top;
    end;
  end; //  with CurMonitor do
}
  PRFullScreenForm := TN_BaseForm.Create( Application );

  with TN_BaseForm(PRFullScreenForm) do
  begin
    BFSelfName := 'FullScreenForm';
    BaseFormInit( nil );
    Left := NeededRect.Left;
    Top  := NeededRect.Top;
    Height := NeededRect.Bottom;
    Width  := NeededRect.Right;
{
    Left := NeededLeft;
    Top  := NeededTop;
    Height := NeededHeight;
    Width  := NeededWidth;
}
    BorderStyle := bsNone;

    ImgRFrame.Parent := PRFullScreenForm;
    ActiveControl := ImgRFrame;

    hTaskbar := FindWindow( 'Shell_TrayWnd', nil );
    if hTaskbar <> 0 then
    begin // Hide TaskBar
      EnableWindow( HTaskBar, FALSE ); // Disabled TaskBar
      ShowWindow( hTaskBar, SW_HIDE ); // Hide TaskBar
    end;

    if PRStudyInd >= 0 then
       PRShowImage()
    else
    if (PRState and 16) <> 0 then
      PRShowSlideByFilmStrip( PRCurSelInd );

    // Hide Main Form if needed
    N_IRectAnd( CurMonitorRect, CurFormRect );
    if (CurMonitorRect.Left <> CurFormRect.Left)   or
       (CurMonitorRect.Top <> CurFormRect.Top)     or
       (CurMonitorRect.Right <> CurFormRect.Right) or
       (CurMonitorRect.Bottom <> CurFormRect.Bottom) then
      Self.Hide; // Hide Main Visible Form before

    ShowModal;

    PRFullScreenForm := nil;
    if (PRState and 16) = 0 then
    begin
      FullScreenScaleFactor := ImgRFrame.RFGetCurRelObjSize();
      if FullScreenScaleFactor < 1 then FullScreenScaleFactor := 1;
    end
    else
      FullScreenScaleFactor := PRFullScreenScaleFactor;


    ImgRFrame.Parent := Self;


    // Correct Zoom Level after Full Screen
    if (PRState and 16) = 0 then
    with ImgRFrame do
    begin
      RFVectorScale := RFVectorScale * FullScreenScaleFactor / RFGetCurRelObjSize();
//        SetZoomLevel( rfzmCenter );
      SetZoomLevel( rfzmUpperleft );
    end;

    if hTaskbar <> 0 then
    begin // Show TaskBar
      EnableWindow( hTaskBar, TRUE );        // Enabled TaskBar
      ShowWindow( hTaskBar, SW_SHOWNORMAL ); // Show TaskBar
    end;

    // Show Main Form if needed
    if not Self.Visible then
    begin
      Self.PRSkipFormShow := TRUE;
      Self.Show; // Show Main Visible Form after hide
      // Return Form before (Left,Top) because Show move Form to the Monitor (Left,Top)
//      Self.Left := CurFormRect.Left;
//      Self.Top := CurFormRect.Top;
    end;

  end; // with TN_BaseForm(K_CMSFullScreenForm) do

{ !!!Old Code
  with TN_BaseForm(PRFullScreenForm) do
  begin
    BFSelfName := 'FullScreenForm';
    BaseFormInit( nil, '', [rspfCurMonWAR,rspfMaximize], [rspfCurMonWAR,rspfMaximize] );

    NeededHeight := Height;
    NeededWidth  := Width;

    BorderStyle := bsNone;

    N_GetMonWARByRect( N_CurMonWAR, @MonitorIndex ); // Get Current Monitor Index

    with Screen.Monitors[MonitorIndex] do
    begin
      if Primary then // Current Monitor is Primary
      begin
      // use whole Monitor Size instead of Work Area Size
      // (TaskBar is present only on Primary monitor)
        NeededHeight := Height;
        NeededWidth  := Width;
      end;
    end; // with Screen.Monitors[MonitorIndex] do

    Height := NeededHeight;
    Width  := NeededWidth;

    ImgRFrame.Parent := PRFullScreenForm;
    ActiveControl := ImgRFrame;

    hTaskbar := FindWindow( 'Shell_TrayWnd', nil );
    if hTaskbar <> 0 then
    begin // Hide TaskBar
      EnableWindow( HTaskBar, FALSE ); // Disabled TaskBar
      ShowWindow( hTaskBar, SW_HIDE ); // Hide TaskBar
    end;

//    OnKeyPress := N_CM_MainForm.FormKeyPress;
//    KeyPreview := TRUE;

    if PRStudyInd >= 0 then
       PRShowImage()
    else
    if (PRState and 16) <> 0 then
      PRShowSlideByFilmStrip( PRCurSelInd );
{
    // Correct Zoom Level before Full Screen
    with ImgRFrame do
    begin
      RFVectorScale := RFVectorScale * FullScreenScaleFactor / RFGetCurRelObjSize();
      SetZoomLevel( rfzmCenter );
    end;
}
{
    ShowModal;

    PRFullScreenForm := nil;
    if (PRState and 16) = 0 then
    begin
      FullScreenScaleFactor := ImgRFrame.RFGetCurRelObjSize();
      if FullScreenScaleFactor < 1 then FullScreenScaleFactor := 1;
    end
    else
      FullScreenScaleFactor := PRFullScreenScaleFactor;


    ImgRFrame.Parent := Self;


    // Correct Zoom Level after Full Screen
    if (PRState and 16) = 0 then
    with ImgRFrame do
    begin
      RFVectorScale := RFVectorScale * FullScreenScaleFactor / RFGetCurRelObjSize();
//        SetZoomLevel( rfzmCenter );
      SetZoomLevel( rfzmUpperleft );
    end;

    if hTaskbar <> 0 then
    begin // Show TaskBar
      EnableWindow( hTaskBar, TRUE );        // Enabled TaskBar
      ShowWindow( hTaskBar, SW_SHOWNORMAL ); // Show TaskBar
    end;

  end; // with TN_BaseForm(K_CMSFullScreenForm) do
}

  Self.ActiveControl := ImgRFrame;

  N_Dump2Str( 'TK_FormCMPresent >> FullScreen fin' );

  if (PRState and 16) <> 0 then
  begin
    PRState := PRState - 16;
    ImgRFrame.RFrInitByComp( nil );
    ImgRFrame.ShowMainBuf();
    PRRebuildAllView();
  end
  else
  if PRStudyInd >= 0 then
    RBShowCurByFilmStrip();

end; // procedure TK_FormCMPresent.PRShowInFullScreenMode

//**************************************** TK_FormCMPresent.FormCloseQuery ***
// Form CloseQuery Handler
//
procedure TK_FormCMPresent.FormCloseQuery( Sender: TObject;
                                            var CanClose: Boolean );
begin
  N_Dump1Str( '***** TK_FormCMPresent.OnClose ' );

  PRClearAllView( );

  ImgRFrame.RFFreeObjects();
  ThumbsRFrame.RFFreeObjects();

  if (PRSlide <> nil) and (PRSlide is TN_UDCMStudy) then
    TN_UDCMStudy(PRSlide).UnSelectAll();
  PRThumbsDGrid.Free;
  PRDrawSlideObj.Free;
  K_FormCMPresent := nil;
  
end; // procedure TK_FormCMPresent.FormCloseQuery

//************************************ TK_FormCMPresent.aSelectPrevExecute ***
// aSelectPrev action Handler
//
procedure TK_FormCMPresent.aSelectPrevExecute(Sender: TObject);
begin
  if PRCurSelInd = -1 then
  begin
    PRCurSelInd := PRStudyInd;
    PRStudyInd := -1;
  end;
  PRThumbsDGrid.DGMarkSingleItem( PRCurSelInd - 1 );
end; // procedure TK_FormCMPresent.aSelectPrevExecute

//************************************ TK_FormCMPresent.aSelectNextExecute ***
// aSelectNext action Handler
//
procedure TK_FormCMPresent.aSelectNextExecute(Sender: TObject);
begin
  if PRCurSelInd = -1 then
  begin
    PRCurSelInd := PRStudyInd;
    PRStudyInd := -1;
  end;
  PRThumbsDGrid.DGMarkSingleItem( PRCurSelInd + 1 );
end; // procedure TK_FormCMPresent.aSelectNextExecute

//************************************ TK_FormCMPresent.CtrlTimerTimer ***
// Timer event Handler
//
procedure TK_FormCMPresent.CtrlTimerTimer(Sender: TObject);
begin
  N_Dump2Str( 'TK_FormCMPresent >> CtrlTimerTimer start' );
  CtrlTimer.Enabled := FALSE;

  if PRState = -1 then
  begin // Form Show Init
    PRState := 0;
    ///////////////////////////
    // Is mooved from form show
    if RBFilmStrip.Checked then
    begin
      PRInitFilmStripView();
    end
    else
    begin
      PRInitAllView();
      PRRebuildAllView();
    end;
    // Is mooved from form show
    ///////////////////////////
    Exit;
  end; // Form Show Init

  if (PRState and 4) <> 0 then
  begin
  ///////////////////
  // Film Strip View
  //
    if (PRCurSelInd >= 0) and
       (PRCurSelInd < Length(PRSlides))  and
       (PRThumbsDGrid.DGItemsFlags[PRCurSelInd] = 0) then
    // Mark Film Strip Item
      PRThumbsDGrid.DGMarkSingleItem( PRCurSelInd );

    if (PRDrawInd >= 0) and
       (PRDrawInd < Length(PRSlides)) then
    // Show Slide in High Resolution
      PRShowSlideByFilmStrip( PRDrawInd );
  //
  // Film Strip View
  ///////////////////
  end
  else
  begin
  ///////////////////
  // All View
  //
    CancelDrag();
    if ((Windows.GetKeyState(VK_LBUTTON)   and $8000) <> 0) and
       (PRCurDragInd >= 0) then
    begin
      PRDragMode := TRUE;
      ImgRFrame.BeginDrag( TRUE );
      N_Dump2Str( 'TK_FormCMPresent >> CtrlTimerTimer BeginDrag' );
    end
    else
    begin
      PRDragMode := FALSE;
      PRCurDragInd := -1;
    end;
  //
  // All View
  ///////////////////
  end;

end; // procedure TK_FormCMPresent.CtrlTimerTimer

//************************************* TK_FormCMPresent.ImgPanelMouseDown ***
// Rast1Frame OnMouseDown event handler
//
procedure TK_FormCMPresent.ImgPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

var
  Item, Slide : TN_UDBase;
begin

  if (PRState and (4 or 16)) <> 0 then
  begin
  ///////////////////
  // Film Strip View
  //
    if (PRSlide = nil) then Exit;
    if not (PRSlide is TN_UDCMStudy) then
    begin
      with ImgRFrame, CCBuf, RFLogFramePRect do
        if (X >= 0) and (X <= Right) and (Y >= 0) and (Y <= Bottom) and
           (ssLeft in Shift) then
        begin // Switch to VEUI if click is inside Image
          if PRFullScreenForm <> nil then
            PRFullScreenForm.Close()
          else
            PRShowInFullScreenMode();
        end;
    end
    else
    begin
      with PRSearchGroup, OneSR do
      begin
        if SRType <> srtNone then
        begin
          Item := TN_UDBase(SComps[SRCompInd].SComp);
          Slide := K_CMStudyGetOneSlideByItem( Item );
          TN_UDCMStudy(PRSlide).UnSelectAll();
          if (PRState and 16) = 0 then
            TN_UDCMStudy(PRSlide).SelectItem( Item );
          if (ssLeft in Shift) then
          begin
            PRStudyInd  := PRCurSelInd;
            PRCurSelInd := -1;
            PRSlide := TN_UDCMBSlide(Slide);
            PRShowInFullScreenMode();
            // PRShowImage();
          end;
        end    // if SRType <> srtNone then
        else
        begin // if SRType = srtNone then
          TN_UDCMStudy(PRSlide).UnSelectAll();
          if (PRState and 16) <> 0 then
          begin
            PRState := PRState - 16;
            PRRebuildAllView();
          end
        end;
      end; // with PRSearchGroup, OneSR do

      ImgRFrame.RedrawAllAndShow();
    end;
  //
  // Film Strip View
  ///////////////////
  end
  else
  begin
  ///////////////////
  // All View
  //
    if (ssLeft in Shift) then
    begin
  //    if check if mouse is down inside slide place with slide
      ImgRFrame.SearchInAllGroups2( X, Y );
      // Select Page position under cursor
      PRPageDragStartComp := nil;
      RedrawDragOverComponent( 0 );
      with PRSearchGroup, OneSR do
        if (SRType <> srtNone)then
          PRPageDragStartComp := TN_UDBase(SComps[SRCompInd].SComp);

      RedrawDragOverComponent( 0 );

      // if this position is used by Slide check Drag Start by Timer
      PRDragMode := FALSE;
      PRCurDragInd := - 1;
      if PRPageDragStartComp <> nil then
      begin
        Item := PRPageDragStartComp.GetObjByRPath('SlideParent\SlidePosScale');
        if (Item <> nil) and (Item.DirChild(0) <> nil) then
        begin //
          PRCurDragInd := PRPageDragStartComp.Marker;
          CtrlTimer.Enabled := TRUE;
        end;
      end;
    end;
  //
  // All View
  ///////////////////
  end;
end; // procedure TK_FormCMPresent.ImgPanelMouseDown

//************************************* TK_FormCMPresent.ImgPanelMouseUp ***
// Rast1Frame OnMouseUp event handler
//
procedure TK_FormCMPresent.ImgPanelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (PRState and 4) <> 0 then
  begin
{
  ///////////////////
  // Film Strip View
  //
    if (PRSlide = nil) then Exit;

    if not (PRSlide is TN_UDCMStudy) then
    begin
      CtrlTimer.Enabled := TRUE;
      Exit;
    end;
  //
  // Film Strip View
  ///////////////////
}  
  end
  else
  begin
  ///////////////////
  // All View
  //
      if PRDragMode or (PRCurDragInd < 0) then Exit;
      PRCurSelInd := PRCurDragInd;
      PRCurDragInd := -1;
      PRState := PRState or 16;
      if TN_UDCMBSlide(PRSlides[PRSlideInds[PRCurSelInd]]) is  TN_UDCMStudy then
        PRShowSlideByFilmStrip( PRCurSelInd )
      else
      begin
        PRSlide := PRSlides[PRSlideInds[PRCurSelInd]];
        PRShowInFullScreenMode( );
      end;
  //
  // All View
  ///////////////////
  end;
end; // procedure TK_FormCMPresent.ImgPanelMouseUp

//******************************************* TK_FormCMPresent.PRShowImage ***
// Show Media Object High Resolution preview
//
//     Parameters
// Result - Returns TRUE if slide exists, FALSE if slide have been deleted
//
function  TK_FormCMPresent.PRShowImage() : Boolean;
var
  SDT{, STeethInfo} : string;
  UDMapRoot : TN_UDCompVis;
  SavedCursor : TCursor;
begin
  Result := TRUE;
  if not K_CMSCheckMemForSlide1( TN_UDCMSlide(PRSlide) ) then
  begin
    K_CMShowSoftMessageDlg( K_CML1Form.LLLMemory10.Caption,
//      'There is not enough memory to preview this Media object.'
//      '       Please close the window and try again.'
                             mtWarning, 10 );
    K_CMOutOfMemoryFlag := TRUE;
    Exit;
  end;

  SavedCursor   := Screen.Cursor;
  Screen.Cursor := crHourGlass; // set HourGlass cursor

  UDMapRoot := PRSlide.GetMapRoot();

//  PRGetSlideCaptInfo( PRSlide, SDT, STeethInfo );
//  Caption := format( '  %s   %s', [SDT, STeethInfo] );
  PRGetSlideCaptInfo( PRSlide, SDT );
//  Caption := format( '  %s', [SDT] );
  with ImgRFrame do
  begin
    N_Dump2Str( 'TK_FormCMPresent >> Preview ID=' + PRSlide.ObjName );
    RVCTFrInit3( UDMapRoot );
    aFitInWindowExecute( nil );
    if Assigned(RFOnScaleProcObj) then
    begin
      RFOnScaleProcObj( ImgRFrame );
    end;
    RFGetActionByClass( N_ActZoom ).ActEnabled := True;
  end; // with ImgRFrame do

  Screen.Cursor := SavedCursor; // restore default cursor

end; // procedure TK_FormCMPresent.PRShowImage;

//******************************************* TK_FormCMPresent.PRShowScale ***
// Rast1Frame OnKeyDown event handler
//
procedure TK_FormCMPresent.PRFrameWMKeyDown( var AWMKey: TWMKey );
begin
  if (AWMKey.CharCode <> VK_ESCAPE) or (PRStudyInd < 0) then Exit;
//  if (PRFullScreenForm = nil) or (PRCurSelInd = -1) then
  if PRFullScreenForm = nil then
  begin
    PRCurSelInd := PRStudyInd;
    PRStudyInd := -1;
    PRSlide := TN_UDCMBSlide(PRSlides[PRCurSelInd]);
    PRShowImage();
  end
  else
    PRFullScreenForm.Close();

end; // end of procedure TK_FormCMPresent.PRFrameWMKeyDown

//******************************************* TK_FormCMPresent.PRShowScale ***
// Show Previewed Slide Scale Info
//
//     Parameters
// ARFrame - Rast1Frame where scaled slide was drawn
//
procedure TK_FormCMPresent.PRShowScale( ARFrame: TN_Rast1Frame );
begin
  PRSkipImageShow := TRUE;
  ThumbsRFrame.RedrawAllAndShow(); // Rebuild Thumbnail Pan Rect
  PRSkipImageShow := FALSE;
end; // procedure TK_FormCMPresent.PRShowScale

//************************************ TK_FormCMPresent.PRGetSlideCaptInfo ***
// Get Slide Caption Info
//
//     Parameters
// AUDSlide    - slide
// ASDateTime  - slide Date Taken string
// ASTeethInfo - slide Teeth Info string
//
//procedure TK_FormCMPresent.PRGetSlideCaptInfo( AUDSlide : TN_UDCMBSlide; out ASDateTime, ASTeethInfo : string );
procedure TK_FormCMPresent.PRGetSlideCaptInfo( AUDSlide : TN_UDCMBSlide; var ASDateTime : string );
begin
  with AUDSlide.P^ do
  begin
//    ASDateTime := K_DateTimeToStr( CMSDTTaken, 'dd"/"mm"/"yy hh:nn' );
    ASDateTime := K_DateTimeToStr( CMSDTTaken, 'dd"/"mm"/"yy' );
  end; // with AUDSlide.P^ do
end; // procedure TK_FormCMPresent.PRGetSlideCaptInfo

//*************************************** TK_FormCMPresent.PRRebuildAllView ***
// Rebuild All Slides View
//
procedure TK_FormCMPresent.PRRebuildAllView();
var
  UDSlideRoot : TN_UDCompVis;
  UDSlideParent : TN_UDBase;
  UDSlideTree : TN_UDBase;
  UDPosNumberComp : TN_UDCompVis;
  PPosNumberSkip : TN_PByte;

  PrintSlide : TN_UDCMSlide;
  i, Ind, SlidesCount : Integer;
  SavedCursor : TCursor;
  PosHeight, PosWidth : Integer;
  StudyThumb, ImgThumb, IsStudy : Boolean;
  MSlides : TN_UDCMSArray;
  MSlidesFlags : TN_IArray;

begin
  N_Dump2Str('TK_FormCMPresent >> PRRebuildAllView start ');


  SlidesCount := PRSlidesRootUDComp.DirLength();
  SetLength( PRSearchGroup.SComps, SlidesCount );
  // Link Slides Places Components with Slides

  SavedCursor   := Screen.Cursor;
  Screen.Cursor := crHourGlass; // set HourGlass cursor

  PosHeight := Round( ClientHeight / PRAllRowCount );
  PosWidth  := Round( ClientWidth / PRAllColCount );

  ImgThumb := PRViewAllThumb;
  if not ImgThumb or
    ((PosHeight > K_CMSlideThumbSize) and (PosWidth < K_CMSlideThumbSize)) then
  begin
    ImgThumb := (PosHeight < K_CMSlideThumbSize) or (PosWidth < K_CMSlideThumbSize);

    if not ImgThumb and PRMemCheckFlag then
    begin // Check if Memory is enough
      PRMemCheckFlag := FALSE;
      Ind := 0;
      // Put All Image Slides to K_CMSlidesToSkipMemFree
      SetLength( MSlides, SlidesCount );
      SetLength( MSlidesFlags, SlidesCount );
      for i := 0 to SlidesCount - 1 do
      begin
        if TN_UDCMBSlide(PRSlides[i]) is TN_UDCMStudy then Continue;
        MSlides[Ind] := PRSlides[i];
        Inc(Ind);
      end;

      // Attemp to load all MapRoots
      for i := 0 to Ind - 1 do
      begin
        PRViewAllThumb := not K_CMSCheckMemForSlide1( MSlides[i] ) ;
        if PRViewAllThumb then break;
        with MSlides[i], P^ do
        begin
          GetMapRoot();
          if cmsfIsOpened in CMSRFlags then
            MSlidesFlags[i] := 1
          else // Set Extra Opened State
            Include( CMSRFlags, cmsfIsOpened );
        end;
      end;

      ImgThumb := PRViewAllThumb;

      // Clear Extra Opened State
      for i := 0 to Ind - 1 do
        if MSlidesFlags[i] = 0 then
          with MSlides[i], P^ do
             Exclude( CMSRFlags, cmsfIsOpened );

    end; // if not ImgThumb and PRMemCheckFlag then
  end; // if not ImgThumb then

  StudyThumb := (PosWidth < K_CMSlideThumbSize);

  for i := 0 to SlidesCount - 1 do
  begin
    UDSlideRoot := TN_UDCompVis( PRSlidesRootUDComp.DirChild( i ) );
    UDSlideRoot.Marker := i;
    UDSlideParent := UDSlideRoot.GetObjByRPath('SlideParent\SlidePosScale');
    UDPosNumberComp := TN_UDCompVis(UDSlideParent.Owner.DirChild(1));
    PPosNumberSkip := @(UDPosNumberComp.PSP.CCompBase.CBSkipSelf);
    PPosNumberSkip^ := 255; // Hide Pos Number

    with PRSearchGroup.SComps[i] do
    begin
      SComp  := TN_UDCompVis(UDSlideRoot);
      SFlags := 0;
    end;

    Ind := PRSlideInds[i];

    // Mount Slide to Print sample Place Get Slide Attrs
    PrintSlide := PRSlides[Ind];
    IsStudy := TN_UDCMBSlide(PrintSlide) is TN_UDCMStudy;
    if (IsStudy and StudyThumb) or (not IsStudy and ImgThumb) then
      UDSlideTree := PrintSlide.GetThumbnail()
    else
      UDSlideTree := PrintSlide.GetMapRoot();

    if UDSlideTree <> nil then
      UDSlideParent.PutDirChildSafe( 0, UDSlideTree );

    // Build Position Texts
{
    with UDSlideRoot.GetSUserParRArray( 'SlideHeader' )  do
      PRGetSlideCaptInfo( PrintSlide, PString(P)^ );
    with UDSlideRoot.GetSUserParRArray( 'SlideFooterSkipFlag' )  do
      PByte(P)^ := 255;
}
    with UDSlideRoot.GetSUserParRArray( 'SlideFooter' )  do
      PRGetSlideCaptInfo( PrintSlide, PString(P)^ );
    with UDSlideRoot.GetSUserParRArray( 'SlideHeaderSkipFlag' )  do
      PByte(P)^ := 255;
  end; // for i := 0 to SlidesCount - 1 do

  ImgRFrame.RVCTFrInit3( PRSlidesRootUDComp );
  ImgRFrame.RedrawAllAndShow();

  Screen.Cursor := SavedCursor; // restore default cursor

  N_Dump2Str( 'TK_FormCMPresent >> PRRebuildAllView fin' );
end; // procedure TK_FormCMPresent.PRRebuildAllView

//********************************* TK_FormCMPresent.PRShowSlideByFilmStrip ***
// Show Slide by FilmStrip Context
//
procedure TK_FormCMPresent.PRShowSlideByFilmStrip( AInd : Integer );
begin
  N_Dump2Str( 'TK_FormCMPresent >> PRShowSlideByFilmStrip start' );
  with ImgRFrame do
  begin
    if (PRSlide <> nil) and (PRSlide is TN_UDCMStudy) then
      TN_UDCMStudy(PRSlide).UnSelectAll();

    PRSlide := TN_UDCMBSlide(PRSlides[PRSlideInds[AInd]]);
    if PRShowImage() then
    begin
      PRDrawInd := -1;
      PRStudyInd := -1;
      if PRSlide is TN_UDCMStudy then
      begin
        TN_UDCMStudy(PRSlide).RebuildItemsSearchList( PRSearchGroup, TRUE );
        N_Dump2Str( 'TK_FormCMPresent.PRShowSlideByFilmStrip Add SearchGroup SComps = ' + IntToStr( Length(PRSearchGroup.SComps) ) );
      end
      else
        SetLength( PRSearchGroup.SComps, 0 );
    end;
  end;
  N_Dump2Str( 'TK_FormCMPresent >> PRShowSlideByFilmStrip fin' );
end; // procedure TK_FormCMPresent.PRShowSlideByFilmStrip

//******************************** TK_FormCMPresent.RedrawDragOverComponent ***
// Redraw Page Place Frame Component
//
//     Parameters
// AViewState - if 0 then component will be shown, if 255 then will be hide
//
procedure TK_FormCMPresent.RedrawDragOverComponent( AViewState : Integer );
var
  DrawComp : TN_UDBase;
  PUP: TN_POneUserParam;
begin
  if PRPageDragOverComp = nil then Exit;
  DrawComp := PRPageDragOverComp;
  // Set CMMCurDragOverComp new State
  PUP := N_GetUserParPtr(TN_UDCompBase(DrawComp).R, 'DropSelShow');
  if PUP = nil then Exit; // precaution
  PByte(PUP.UPValue.P)^ := Byte(AViewState);
  ImgRFrame.RedrawAllAndShow();

  if AViewState = 0 then
    PRPageDragOverComp := nil;
end; // procedure TK_FormCMPresent.RedrawDragOverComponent

//*********************************** TK_FormCMPresent.RBShowCurByFilmStrip ***
// Show Current Slide by Film Strp Context
//
procedure TK_FormCMPresent.RBShowCurByFilmStrip();
var
  Ind : Integer;
begin
  if PRCurSelInd = -1 then
  begin
     PRCurSelInd := PRStudyInd;
     PRStudyInd := -1;
  end;
  Ind := PRCurSelInd;

  PRCurSelInd := -1;
  N_Dump2Str( format( 'TK_FormCMPresent >> RBShowCurByFilmStrip = Show Ind=%d', [Ind] ) );
  PRThumbsDGrid.DGMarkSingleItem( Ind );
  ThumbsRFrame.RedrawAllAndShow();
end; // procedure TK_FormCMPresent.RBShowCurByFilmStrip

//*************************************** TK_FormCMPresent.RBFilmStripClick ***
// RBFilmStrip onClick event Handler
//
procedure TK_FormCMPresent.RBFilmStripClick(Sender: TObject);
begin
  if PRMemIniToCurState then Exit;
  N_Dump2Str( 'TK_FormCMPresent >> RBFilmStripClick' );
  if RBFilmStrip.Checked then
    RBAll.Checked := FALSE;
  if (PRState and 1) = 0 then
    PRInitFilmStripView( )
  else
    PRSwitchToFilmStripView();

  RBShowCurByFilmStrip();
end; // procedure TK_FormCMPresent.RBFilmStripClick

procedure TK_FormCMPresent.RBAllClick(Sender: TObject);
begin
  if PRMemIniToCurState then Exit;
  N_Dump2Str( 'TK_FormCMPresent >> RBAllClick' );
  if RBAll.Checked then
    RBFilmStrip.Checked := FALSE;
  if (PRState and 2) = 0 then
    PRInitAllView( )
  else
    PRSwitchToAllView();

  PRRebuildAllView();

  // Prepare All View

end; // procedure TK_FormCMPresent.RBAllClick

procedure TK_FormCMPresent.CurStateToMemIni;
begin
  inherited;
//  N_BoolToMemIni( Name+'State', 'FilmStripMode', RBFilmStrip.Checked );
  N_BoolToMemIni( Name+'State', 'FilmStripMode', TBFilmStrip.Down );

end; // procedure TK_FormCMPresent.CurStateToMemIni

procedure TK_FormCMPresent.MemIniToCurState;
begin
  PRMemIniToCurState := TRUE;
  inherited;
  if N_MemIniToBool( Name+'State', 'FilmStripMode', TRUE ) then
  begin
    RBFilmStrip.Checked := TRUE;
    TBFilmStrip.Down    := TRUE;
  end
  else
  begin
    RBAll.Checked := TRUE;
    TBAll.Down    := TRUE;
  end;
  PRMemIniToCurState := FALSE;
end; // procedure TK_FormCMPresent.MemIniToCurState

procedure TK_FormCMPresent.ImgRFramePaintBoxDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  DragOverComp : TN_UDBase;

label LExit;

begin
  Accept := FALSE;
  if not PRDragMode then
  begin
LExit: // ***********
    RedrawDragOverComponent( 0 );
    Exit;
  end;

// if cursor position is not inside slide place or insde the slide place with same slide then exit;
  ImgRFrame.SearchInAllGroups2( X, Y );
  DragOverComp := nil;
  with PRSearchGroup, OneSR do
    if (SRType <> srtNone)then
      DragOverComp := TN_UDBase(SComps[SRCompInd].SComp);

  if (DragOverComp = nil) or (PRPageDragStartComp = DragOverComp) then goto LExit;
  Accept := TRUE;

  if PRPageDragOverComp = DragOverComp then Exit;

  RedrawDragOverComponent( 0 );
  PRPageDragOverComp := DragOverComp;
  RedrawDragOverComponent( 255 );

end; // procedure TK_FormCMPresent.ImgRFramePaintBoxDragOver

procedure TK_FormCMPresent.ImgRFrameEndDrag(Sender, Target: TObject; X,
  Y: Integer);
var
  UDComp : TN_UDBase;
  TargetInd : Integer;
  WInd : Integer;

begin
  if (PRPageDragOverComp = nil) then Exit;
  if (Target <> ImgRFrame.PaintBox) then
  begin
    RedrawDragOverComponent(0);
    Exit;
  end;
  TargetInd := PRPageDragOverComp.Marker;
  UDComp := PRPageDragOverComp.GetObjByRPath('SlideParent\SlidePosScale');
  RedrawDragOverComponent(0);
  if UDComp = nil then Exit;

  N_Dump2Str( format('TK_FormCMPresent >> Drag Switch ID=%s at Pos=%d and ID=%s at Pos=%d',
  [PRSlides[PRSlideInds[TargetInd]].ObjName,TargetInd,
   PRSlides[PRSlideInds[PRCurDragInd]].ObjName,PRCurDragInd]) );
  WInd := PRSlideInds[TargetInd];
  PRSlideInds[TargetInd] := PRSlideInds[PRCurDragInd];
  PRSlideInds[PRCurDragInd] := WInd;

  PRRebuildAllView();

  // Clear Drag Context
  PRDragMode := FALSE;
  PRCurDragInd := - 1;
end; // procedure TK_FormCMPresent.ImgRFrameEndDrag

end.
