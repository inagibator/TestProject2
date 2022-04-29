unit K_FCMHPreview;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Contnrs, Types,
  N_BaseF, N_Rast1Fr, N_CM2, N_DGrid, N_SGComp,
  K_CM0, ActnList;

type
  TK_FormCMHPreview = class(TN_BaseForm)
    ThumbPanel: TPanel;
    ThumbsRFrame: TN_Rast1Frame;
    ImgPanel: TPanel;
    ImgRFrame: TN_Rast1Frame;
    ActionList1: TActionList;
    aSelectPrev: TAction;
    aSelectNext: TAction;
    Timer: TTimer;
    Splitter1: TSplitter;
    Panel1: TPanel;
    BtNext: TButton;
    Panel2: TPanel;
    BtPrev: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure aSelectPrevExecute(Sender: TObject);
    procedure aSelectNextExecute(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure ImgPanelMouseDown(Sender: TObject; Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer);
    procedure ImgPanelMouseUp(Sender: TObject; Button: TMouseButton;
                              Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    HPSwitchToVEUIFlag : Boolean;
    HPAddToCMSOpen : Boolean;
    procedure HPGetThumbSize( ADGObj: TN_DGridBase; AInd: integer; AInpSize: TPoint;
                              out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure HPDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure HPChangeThumbState( ADGObj: TN_DGridBase; AInd: integer);
    function  HPAllReresh() : Integer;
    function  HPShowImage() : Boolean;
    procedure HPFrameWMKeyDown( var AWMKey: TWMKey );
    procedure HPShowScale( ARFrame: TN_Rast1Frame );
    procedure HPGetSlideCaptInfo( AUDSlide : TN_UDCMBSlide; out ASDateTime, ASTeethInfo : string );
    procedure HPMain5FShow();
  public
    { Public declarations }
    HPSlides : TN_UDCMSArray;
    HPThumbsDGrid: TN_DGridArbMatr;
    HPDrawSlideObj: TN_CMDrawSlideObj;
    HPCurSelInd : Integer;
    HPStudyInd : Integer;
    HPDrawInd : Integer;
    HPCaptPrefix : string;
    HPSlide : TN_UDCMBSlide;
    HPSearchGroup: TN_SGComp;    // Group for Vector Objects RFA
    HPOpenCMSAllFlag : Boolean;

    procedure HPShowSlides( APSlides: TN_PUDCMSlide; ACount : Integer;
                            ACurSlideInd : Integer; AOpenCMSAll : Boolean );
  end;

var
  K_FormCMHPreview: TK_FormCMHPreview;

function K_CMGetHPreviewForm() : TK_FormCMHPreview;

implementation

uses N_CM1, N_Comp1, N_Types, N_CMMain5F, N_CMResF, N_Lib0, N_CompBase,
     K_UDT1, K_CML1F, K_CLib0, K_FCMMain5F, K_CM1, K_FCMDeviceLimitWarn;

{$R *.dfm}

//***************************************************** K_CMGetHPreviewForm ***
// Get High Resolution Preview Form
//
function K_CMGetHPreviewForm(): TK_FormCMHPreview;
begin
  N_Dump2Str( 'K_CMGetHPreviewForm start' );
  K_CMCloseOnCurUICloseFlag := TRUE;
  Result := K_FormCMHPreview;
  if Result <> nil then Exit;
  K_FormCMHPreview := TK_FormCMHPreview.Create(Application);
  N_Dump2Str( 'Create TK_FormCMHPreview' );
//  K_FormCMHPreview.BFFlags := [bffToDump1,bffDumpPos];

  K_FormCMHPreview.BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
  Result := K_FormCMHPreview;
  N_BaseFormStayOnTop := 2;

  with K_FormCMHPreview do
  begin
{$IF CompilerVersion >= 26.0} // Delphi >= XE5  needed to skip scroll bars blinking in W7-8
    ImgRFrame.VScrollBar.ParentDoubleBuffered := FALSE;
    ImgRFrame.HScrollBar.ParentDoubleBuffered := FALSE;
    ThumbsRFrame.HScrollBar.ParentDoubleBuffered := FALSE;
{$IFEND CompilerVersion >= 26.0}
    DoubleBuffered := True;
    ImgPanel.DoubleBuffered := True;

    HPDrawSlideObj := TN_CMDrawSlideObj.Create();
    HPThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, HPGetThumbSize );

    with HPThumbsDGrid do
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

      DGDrawItemProcObj := HPDrawThumb;
//      DGDrawItemProcObj := N_CM_MainForm.CMMFDrawThumb;
      DGChangeItemStateProcObj := HPChangeThumbState;
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

    HPSearchGroup := TN_SGComp.Create( ImgRFrame );
    with HPSearchGroup do
    begin
      GName := 'VOGroup';
      PixSearchSize := 15;
      SGFlags := $02 + // search lines even out of UDPolyline and UDArc components
                 $04;  // do redraw actions loop witout objects
    end;

    ImgRFrame.RFSGroups.Add( HPSearchGroup );

    ImgRFrame.OnWMKeyDownProcObj := HPFrameWMKeyDown;
    ImgRFrame.RFOnScaleProcObj   := HPShowScale;
    ImgRFrame.RFOnScrollProcObj  := HPShowScale;
    ImgRFrame.RFDebName := 'HPImgRFrame';
    SetStretchBltMode( ImgRFrame.OCanv.HMDC, K_CMStretchBltMode );

    ThumbsRFrame.OnWMKeyDownProcObj := HPFrameWMKeyDown;
    ThumbsRFrame.RFDebName := 'HPThumbs';
    ThumbsRFrame.RFClearFlags := 0;
    ThumbsRFrame.RFDumpEvents := True;

  end;
// 07-11-2014 close for COM StartSession proper work
//  K_CMSAppStartContext.CMASMode := K_cmamWait; // Clear Launch Interface Mode

end; // K_CMGetHPreviewForm

//********************************************** TK_FormCMHPreview.FormShow ***
// Form Show Handler
//
procedure TK_FormCMHPreview.FormShow(Sender: TObject);
begin
  Self.Caption := K_CML1Form.LLLNothingToDo.Caption;
  N_CM_MainForm.CMMCurFHPMainForm := Self;
  K_CMEDAccess.AccessReady := TRUE;
end; // TK_FormCMHPreview.FormShow

//********************************* TK_FormCMHPreview.HPGetThumbSize ***
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
procedure TK_FormCMHPreview.HPGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide : TN_UDCMSlide;
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin
  with N_CM_GlobObj, ADGObj do
  begin
    Slide     := HPSlides[AInd];
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
end; // procedure TK_FormCMHPreview.HPGetThumbSize

//************************************ TK_FormCMHPreview.HPDrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel and may be not equal to upper left Grid pixel )
//
// Is used as value of HPThumbsDGrid.DGDrawItemProcObj field
//
procedure TK_FormCMHPreview.HPDrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
var
  Slide : TN_UDCMSlide;
  LinesCount : Integer;
  SlideDrawFlags : Byte;
  FRFrame: TN_Rast1Frame;
  SDT, STeethInfo : string;
begin
  with HPThumbsDGrid, DGMarkedList do
  begin
    if (DGItemsFlags[AInd] = 0) and (Count = 1) then
    begin
      Timer.Enabled := TRUE;
    end;
  end;

  with N_CM_GlobObj do
  begin
    Slide := TN_UDCMSlide(HPSlides[AInd]);

    SlideDrawFlags := ADGObj.DGItemsFlags[AInd];
    LinesCount := 2;

    HPGetSlideCaptInfo( Slide, SDT, STeethInfo );
    CMStringsToDraw[0] := SDT;
    CMStringsToDraw[1] := STeethInfo;

    FRFrame := nil;
    if Slide = HPSlide then
      FRFrame := ImgRFrame;
    HPDrawSlideObj.DrawOneThumb8( Slide,
                               CMStringsToDraw, LinesCount,
                               ADGObj, ARect,
                               FRFrame,
                               SlideDrawFlags );

  end; // with N_CM_GlobObj do

end; // end of TK_FormCMHPreview.HPDrawThumb

//***********************************  TK_FormCMHPreview.HPChangeThumbState  ******
// Thumbnail Change State processing (used as TN_DGridBase.DGChangeItemStateProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - Index of Thumbnail that is change state
//
procedure TK_FormCMHPreview.HPChangeThumbState(
                                   ADGObj: TN_DGridBase; AInd: integer);
var
  Ind  : Integer;
begin
  with HPThumbsDGrid, DGMarkedList do
  begin
    Ind := Integer(Items[0]);
    aSelectPrev.Enabled := Ind > 0;
    aSelectNext.Enabled := Ind < High(HPSlides);
    if (Count = 1) and
       (cmsfIsMediaObj in HPSlides[Ind].P^.CMSDB.SFlags) then {Clear  ImageFrame}
    else
    begin
      if Ind = HPCurSelInd then Exit;
      {Change Selected action};
      HPDrawInd := Ind;
      Timer.Enabled := TRUE;
    end;
    HPCurSelInd := Ind;
  end;

end; // end of TK_FormCMHPreview.HPChangeThumbState

//****************************************** TK_FormCMHPreview.HPShowSlides ***
// Show given slides in High resolution Preview Mode
//
//    Parameters
// APSlides     - pointer to Slides array first element
// ACount       - number of elements in Slides array
// ACurSlideSID - 1-st selected Slide ID
//
procedure TK_FormCMHPreview.HPShowSlides( APSlides: TN_PUDCMSlide;
                                          ACount: Integer;
                                          ACurSlideInd : Integer;
                                          AOpenCMSAll : Boolean  );
begin
  N_Dump1Str( format( 'TK_FormCMHPreview >> HPShowSlides N=%d I=%d O=%s', [ACount, ACurSlideInd, N_B2S(AOpenCMSAll) ] ) );
  SetLength( HPSlides, ACount );
  if ACount > 0 then
    Move( APSlides^, HPSlides[0], ACount * SizeOf(TN_UDCMSlide) )
  else
  begin
    aSelectPrev.Enabled := FALSE;
    aSelectNext.Enabled := FALSE;
  end;

  with HPThumbsDGrid do
  begin
    DGNumItems := Length(HPSlides);
    DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
    HPCurSelInd := -1;
    HPStudyInd := -1;
    DGMarkSingleItem( ACurSlideInd );
  end; // with ThumbsDGrid do

  HPOpenCMSAllFlag := AOpenCMSAll;
end; // procedure TK_FormCMHPreview.HPShowSlides

//**************************************** TK_FormCMHPreview.FormCloseQuery ***
// Form CloseQuery Handler
//
procedure TK_FormCMHPreview.FormCloseQuery( Sender: TObject;
                                            var CanClose: Boolean );
begin
  CanClose := (HPStudyInd < 0)    or
               HPSwitchToVEUIFlag or
               K_CMCloseCurUIFlag; // Close is initialised by COM Client
  if not CanClose then
  begin
    N_Dump2Str( 'Return to Study Ind=' + IntToStr(HPStudyInd) );
    HPDrawInd := HPStudyInd;
    HPCurSelInd := HPStudyInd;
    Timer.Enabled := TRUE;
  end
  else
  begin
    N_Dump1Str( '***** TK_FormCMHPreview.OnClose ' );

    N_BaseFormStayOnTop := 0;

    ImgRFrame.RFFreeObjects();
    ThumbsRFrame.RFFreeObjects();

    if (HPSlide <> nil) and (HPSlide is TN_UDCMStudy) then
      TN_UDCMStudy(HPSlide).UnSelectAll();
    HPThumbsDGrid.Free;
    HPDrawSlideObj.Free;
    K_FormCMHPreview := nil;
    N_CM_MainForm.CMMCurFHPMainForm := nil;

    if K_CMD4WAppFinState then
    begin
      N_Dump1Str( 'TK_FormCMHPreview.OnClose >> N_CM_MainForm is already closed' );
      Exit;   // N_CM_MainForm (CMS) is already closed
    end;

    if HPSwitchToVEUIFlag or not K_CMCloseOnCurUICloseFlag then
    begin
      N_Dump1Str( 'TK_FormCMHPreview.OnClose >> Other UI mode is launching' );
      Exit;
    end;
// Temporary code - Show Main CMS Form if Close HPreview
//    HPMain5FShow();

    if K_CMD4WAppRunByCOMClient and   // Precaution for debug mode
       not K_CMOutOfMemoryFlag  and
       not K_CMD4WCloseAppByUI then
    begin
    // Close Connection only if is Run By Client and memory collisions were not detected
      with TK_CMEDDBAccess(K_CMEDAccess) do
      begin
        EDAAppDeactivate();
        EDARebuildADOObjects;
      end;
      N_Dump1Str( 'TK_FormCMHPreview.OnClose >> Close UI, wait for COM client events' +
                   #13#10'=========='#13#10 );
      K_CMD4WCNewPatientID := K_CMSAppStartContext.CMASPatID; // for future VEUI Relaunch Context
      K_CMSAppStartContext.CMASMode := K_cmamSleep;
      Exit;
    end;

    // Close Application
    N_CM_MainForm.Close();
    N_CM_MainForm.Release();
  end;
end; // procedure TK_FormCMHPreview.FormCloseQuery

//************************************ TK_FormCMHPreview.aSelectPrevExecute ***
// aSelectPrev action Handler
//
procedure TK_FormCMHPreview.aSelectPrevExecute(Sender: TObject);
begin
  if HPCurSelInd = -1 then
  begin
    HPCurSelInd := HPStudyInd;
    HPStudyInd := -1;
  end;
  HPThumbsDGrid.DGMarkSingleItem( HPCurSelInd - 1 );
end; // procedure TK_FormCMHPreview.aSelectPrevExecute

//************************************ TK_FormCMHPreview.aSelectNextExecute ***
// aSelectNext action Handler
//
procedure TK_FormCMHPreview.aSelectNextExecute(Sender: TObject);
begin
  if HPCurSelInd = -1 then
  begin
    HPCurSelInd := HPStudyInd;
    HPStudyInd := -1;
  end;
  HPThumbsDGrid.DGMarkSingleItem( HPCurSelInd + 1 );
end; // procedure TK_FormCMHPreview.aSelectNextExecute

//******************************************** TK_FormCMHPreview.TimerTimer ***
// Timer event Handler
//
procedure TK_FormCMHPreview.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := FALSE;
  if HPSwitchToVEUIFlag then
  begin // Close Self
//    N_BaseFormStayOnTop := 0;

///////////////////////////////////////////////////
//!!! Prevent bad repaint Left Toolbar in opening VEUI in W7-8
//    Var1 Self.Hide(); - all OK but blink
    Self.Width := Self.Width - 1;
    Self.Width := Self.Width + 1;
    if (Self.Left  <= N_AppWAR.Left + 8) and
       (Self.Width >= N_AppWAR.Right - N_AppWAR.Left - 16) then
      Self.Hide();
//!!! Prevent bad repaint Left Toolbar in opening VEUI in W7-8
///////////////////////////////////////////////////

    Self.Close();
    HPMain5FShow();
    Exit;
  end
  else
  if (HPCurSelInd >= 0) and
     (HPCurSelInd < Length(HPSlides))  and
     (HPThumbsDGrid.DGItemsFlags[HPCurSelInd] = 0) then
  // Mark Film Strip Item
    HPThumbsDGrid.DGMarkSingleItem( HPCurSelInd );

  if (HPDrawInd >= 0) and
     (HPDrawInd < Length(HPSlides)) then
  // Show Slide in High Resolution
    with ImgRFrame do
    begin
      if (HPSlide <> nil) and (HPSlide is TN_UDCMStudy) then
        TN_UDCMStudy(HPSlide).UnSelectAll();

      HPSlide := TN_UDCMBSlide(HPSlides[HPDrawInd]);
      if HPShowImage() then
      begin
        HPDrawInd := -1;
        HPStudyInd := -1;
        if HPSlide is TN_UDCMStudy then
          TN_UDCMStudy(HPSlide).RebuildItemsSearchList( HPSearchGroup, TRUE )
        else
          SetLength( HPSearchGroup.SComps, 0 );
      end;
    end;

end; // procedure TK_FormCMHPreview.TimerTimer

//************************************* TK_FormCMHPreview.ImgPanelMouseDown ***
// Rast1Frame OnMouseDown event handler
//
procedure TK_FormCMHPreview.ImgPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

var
  Item, Slide : TN_UDBase;
begin
  HPSwitchToVEUIFlag := FALSE;
  if HPSlide = nil then Exit;

  if not (HPSlide is TN_UDCMStudy) then
  begin
    if not HPSlide.CMSArchived then
    with ImgRFrame, CCBuf, RFLogFramePRect do
      if (X >= 0) and (X <= Right) and (Y >= 0) and (Y <= Bottom) then
      begin // Switch to VEUI if click is inside Image
        HPSwitchToVEUIFlag := TRUE;
        HPAddToCMSOpen := ssRight in Shift;
      end;
  end
  else
  begin
    with HPSearchGroup, OneSR do
    begin
      if SRType <> srtNone then
      begin
        Item := TN_UDBase(SComps[SRCompInd].SComp);
        Slide := K_CMStudyGetOneSlideByItem( Item );
        TN_UDCMStudy(HPSlide).UnSelectAll();
        TN_UDCMStudy(HPSlide).SelectItem( Item );
        if (ssLeft in Shift) then
        begin
          HPStudyInd  := HPCurSelInd;
          HPCurSelInd := -1;
          HPSlide := TN_UDCMBSlide(Slide);
          HPShowImage();
        end;
      end // if SRType <> srtNone then
      else
        TN_UDCMStudy(HPSlide).UnSelectAll();
    end; // with HPSearchGroup, OneSR do

    ImgRFrame.RedrawAllAndShow();
  end;
end; // procedure TK_FormCMHPreview.ImgPanelMouseDown

//************************************* TK_FormCMHPreview.ImgPanelMouseUp ***
// Rast1Frame OnMouseUp event handler
//
procedure TK_FormCMHPreview.ImgPanelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (HPSlide = nil) or HPSlide.CMSArchived then Exit;

  if not (HPSlide is TN_UDCMStudy) and HPSwitchToVEUIFlag then
  begin
    Timer.Enabled := TRUE;
    Exit;
  end;
end; // procedure TK_FormCMHPreview.ImgPanelMouseUp

//******************************************* TK_FormCMHPreview.HPAllReresh ***
// Refresh CurSlides  Set and HPSlides
//
function TK_FormCMHPreview.HPAllReresh() : Integer;
var
  i, j : Integer;
  RefreshNewSlidesCount,
  RefreshDelSlidesCount,
  RefreshUpdateSlidesCount : Integer;
begin
  K_CMEDAccess.EDARefreshCurSlidesSet( RefreshNewSlidesCount, RefreshDelSlidesCount,
                                       RefreshUpdateSlidesCount );
  K_CMCurVisSlidesArray := nil;
  j := 0;
  Result := -1;
  for i := 0 to High(HPSlides) do
  begin
    if K_CMEDAccess.CurSlidesList.IndexOf( HPSlides[i] ) < 0 then Continue;
    HPSlides[j] := HPSlides[i];
    if HPSlides[j] = HPSlide then
      Result := j;
    Inc(j);
  end;
  SetLength( HPSlides, j );
  if (j > 0) and (Result < 0) then Result := 0;

end; // end of procedure TK_FormCMHPreview.HPAllReresh

//******************************************* TK_FormCMHPreview.HPShowImage ***
// Show Media Object High Resolution preview
//
//     Parameters
// Result - Returns TRUE if slide exists, FALSE if slide have been deleted
//
function  TK_FormCMHPreview.HPShowImage() : Boolean;
var
  SDT, STeethInfo : string;
  UDMapRoot : TN_UDCompVis;
  MoveInd, CLength : Integer;
begin
  Result := TRUE;
//  if HPSlide.CMSArchived then Exit;
  if not K_CMSCheckMemForSlide1( TN_UDCMSlide(HPSlide) ) then
  begin
    K_CMShowSoftMessageDlg( K_CML1Form.LLLMemory10.Caption,
//      'There is not enough memory to preview this Media object.'
//      '       Please close the window and try again.'
                             mtWarning, 10 );
    K_CMOutOfMemoryFlag := TRUE;
    Exit;
  end;


  Screen.Cursor := crHourGlass; // set HourGlass cursor
  UDMapRoot := nil;
  if not HPSlide.CMSArchived then
    UDMapRoot := HPSlide.GetMapRoot();

  if UDMapRoot = nil then
  begin //  Slide was deleted - Refresh Self Context
    Screen.Cursor := crDefault; // restore default cursor
    if not HPSlide.CMSArchived then
      K_CMShowMessageDlg( ' Media object have been deleted by other Media Suite user',
                         mtInformation);
    Screen.Cursor := crHourGlass; // set HourGlass cursor

    Result := FALSE;
    if HPCurSelInd <> -1 then
    begin
    // Film Strip slide is absent -  Remove it from Film Strip
      MoveInd := HPCurSelInd + 1;
      CLength := Length(HPSlides);
      if MoveInd < CLength then
        Move( HPSlides[MoveInd], HPSlides[HPCurSelInd],
              SizeOf(TN_UDCMSlide) * (CLength - MoveInd) );
      Dec(CLength);
      SetLength( HPSlides, CLength );
      if HPCurSelInd >= CLength then
        Dec(HPCurSelInd);
    end   // if HPCurSelInd <> -1 then
    else
    begin // if HPCurSelInd = -1 then
    // Study Slide is absent - Refresh All Slides
      HPSlide := HPSlides[HPStudyInd];
      HPStudyInd := -1;
      HPCurSelInd := HPAllReresh(); // Refresh HSlides by Refreshed CurSlidesList
      CLength := Length( HPSlides );
    end; // if HPCurSelInd = -1 then

    with HPThumbsDGrid do
    begin
    // Rebuild Film Strip
      DGNumItems := Length(HPSlides);
      DGInitRFrame();
      if CLength > 0 then
      begin
      // Film Strip is not empty - Select new current
        MoveInd := HPCurSelInd;
        HPCurSelInd := -1;
        DGMarkSingleItem( MoveInd );
      end   // if CLength > 0 then
      else
      begin // if CLength = 0 then
      // Empty Film Strip - Clear Previouse ImgFrame State
        Self.Caption := K_CML1Form.LLLNothingToDo.Caption;
        ImgRFrame.RFrInitByComp( nil );
        ImgRFrame.ShowMainBuf();
        SetLength( HPSearchGroup.SComps, 0 );
        HPSlide := nil;
      end;  // if CLength = 0 then
    end; // with HPThumbsDGrid do
    Screen.Cursor := crDefault; // restore default cursor
  end   // if UDMapRoot = nil then
  else
  begin // if UDMapRoot <> nil then
    HPGetSlideCaptInfo( HPSlide, SDT, STeethInfo );
    Caption := format( '  %s   %s', [SDT, STeethInfo] );
    with ImgRFrame do
    begin
      N_Dump2Str( 'TK_FormCMHPreview >> Preview ID=' + HPSlide.ObjName );
      RVCTFrInit3( UDMapRoot );
      aFitInWindowExecute( nil );
      if Assigned(RFOnScaleProcObj) then
      begin
        RFOnScaleProcObj( ImgRFrame );
      end;
      RFGetActionByClass( N_ActZoom ).ActEnabled := True;
      Screen.Cursor := crDefault; // restore default cursor
    end; // with ImgRFrame do
  end; // if UDMapRoot <> nil then
end; // procedure TK_FormCMHPreview.HPShowImage;

//******************************************* TK_FormCMHPreview.HPShowScale ***
// Rast1Frame OnKeyDown event handler
//
procedure TK_FormCMHPreview.HPFrameWMKeyDown( var AWMKey: TWMKey );
begin
  if (AWMKey.CharCode <> VK_ESCAPE) or (HPStudyInd < 0) then Exit;
  HPCurSelInd := HPStudyInd;
  HPStudyInd := -1;
  HPSlide := TN_UDCMBSlide(HPSlides[HPCurSelInd]);
  HPShowImage();
end; // end of procedure TK_FormCMHPreview.HPFrameWMKeyDown

//******************************************* TK_FormCMHPreview.HPShowScale ***
// Show Previewed Slide Scale Info
//
//     Parameters
// ARFrame - Rast1Frame where scaled slide was drawn
//
procedure TK_FormCMHPreview.HPShowScale( ARFrame: TN_Rast1Frame );
begin
  ThumbsRFrame.RedrawAllAndShow(); // Rebuild Thumbnail Pan Rect
end; // procedure TK_FormCMHPreview.HPShowScale

//************************************ TK_FormCMHPreview.HPGetSlideCaptInfo ***
// Get Slide Caption Info
//
//     Parameters
// AUDSlide    - slide
// ASDateTime  - slide Date Taken string
// ASTeethInfo - slide Teeth Info string
//
procedure TK_FormCMHPreview.HPGetSlideCaptInfo( AUDSlide : TN_UDCMBSlide; out ASDateTime, ASTeethInfo : string );
begin
  with AUDSlide.P^ do
  begin
    ASDateTime := K_DateTimeToStr( CMSDTTaken, 'dd"/"mm"/"yy' );
    if AUDSlide is TN_UDCMStudy then
    // Study
      ASTeethInfo := CMSSourceDescr
    else
    begin // if TN_UDCMBSlide(Slide) is TN_UDCMSlide then
    // Slide
      if (CMSTeethFlags <> 0) then
        ASTeethInfo := K_CMSTeethChartStateToText( CMSTeethFlags )
      else
        ASTeethInfo := '';

    end; // if TN_UDCMBSlide(Slide) is TN_UDCMSlide then

  end; // with AUDSlide.P^ do
end; // procedure TK_FormCMHPreview.HPGetSlideCaptInfo

//****************************************** TK_FormCMHPreview.HPMain5FShow ***
// Show CMS Main5 Form
//
procedure TK_FormCMHPreview.HPMain5FShow();
var
  SelCount, i : Integer;
  WSlides : TN_UDCMSArray;
  WOpenCMSAllFlag : Boolean;
  WOpenCMSAddToFlag : Boolean;
  WSlide : TN_UDCMBSlide;
  ML : TStrings;
begin
  N_Dump1Str( format( 'TK_FormCMHPreview >> Switch to Main ID=%s Pt=%d Pr=%d Lc=%d',
                       [HPSlide.ObjName, K_CMD4WHPNewPatientID, K_CMD4WHPNewProviderID, K_CMD4WHPNewLocationID] ) );

  // Save needed Self Context to Local Varaibles
  WSlides := Copy(HPSlides);
  WOpenCMSAllFlag := HPOpenCMSAllFlag;
  WOpenCMSAddToFlag := HPAddToCMSOpen;
  WSlide := HPSlide;

{ !!! 2014-03-28 because of undefined error
  N_AppSkipEvents := TRUE; // !!!Disable events handlers in Rast1Frame
  Application.ProcessMessages; // for Self.Release Complit
  N_AppSkipEvents := FALSE;// !!!Enable events handlers in Rast1Frame
  N_Dump2Str( 'TK_FormCMHPreview >> after self release' );
}

  // Open CMS VE Form
  with TK_FormCMMain5.Create(Application) do
  begin
// !!! it is already done in K_CMPrepHPContext - 26-03-2014
{
    K_CMSAppStartContext.CMASPatID := K_CMD4WHPNewPatientID;
    K_CMSAppStartContext.CMASProvID:= K_CMD4WHPNewProviderID;
    K_CMSAppStartContext.CMASLocID := K_CMD4WHPNewLocationID;
    K_CMSAppStartContext.CMASPSlideFilterAttrs := nil;
}
    N_CM_MainForm.EdFramesPanel.Parent := Bot2Panel;
    K_CMCloseOnCurUICloseFlag := TRUE;
    // 07-11-2014 needed to skip back switch to HPUI in K_CMD4WApplyBufContext();
    K_CMSAppStartContext.CMASMode  := K_cmamCOMVEUI; // Set VEUI  start mode
    K_CMSAppStartContext.CMASState := K_cmasOK; // for proper ProviderInstance (ThumbsRFrameWidth) Initialization
    Show();
    N_Dump2Str( 'HPMain5FShow >> after Show' );
    Repaint();
    // Set Cur Context for future correct VEUI mode relaunch
    K_CMEDAccess.CurPatID  := K_CMSAppStartContext.CMASPatID; // Set Patient
    K_CMEDAccess.CurProvID := K_CMSAppStartContext.CMASProvID;
    K_CMEDAccess.CurLocID  := K_CMSAppStartContext.CMASLocID;

    // Rebuild Provider UI because it may not be set by initialization inside FormShow
    ML := K_CMEDAccess.EDAGetPatientMacroInfo();
    K_CMBuildUICaptionsByCurContext( ML );
    N_CM_MainForm.CMMUpdateUIByCTA();
    N_CM_MainForm.CMMUpdateUIByFilterProfiles();

    if K_CMLimitDevProfilesToRTDBContext() > 0 then
      K_FCMShowDeviceLimitWarning(); // Show Warning

    N_CM_MainForm.CMMUpdateUIByDeviceProfiles();
  end;

  SelCount := 0;
  if WOpenCMSAllFlag  then
  begin
  // Select All Film Strip Media Objects
    for i := 0 to  High(WSlides) do
      if N_CM_MainForm.CMMChangeSlideSelectState( WSlides[i].ObjName, ssmMark ) then
        Inc(SelCount);
  end
  else
  // Select Current Media Object
  if N_CM_MainForm.CMMChangeSlideSelectState( WSlide.ObjName, ssmMark ) then
    SelCount := 1;

  if SelCount = 0 then Exit;

  with N_CMResForm do
    if WOpenCMSAddToFlag and not WOpenCMSAllFlag then
    begin
      N_CM_MainForm.CMMFActiveEdFrame := N_CM_MainForm.CMMFEdFrames[0];
      aMediaAddToOpenedExecute( aMediaAddToOpened )
    end
    else
      aMediaOpenExecute( aMediaOpen );

  N_Dump2Str( 'HPMain5FShow >> Finish' );

end; // procedure TK_FormCMHPreview.HPMain5FShow

end.
