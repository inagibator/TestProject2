unit K_FCMStudyTemplateSelect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Types,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_CM0,
  N_BaseF, N_Rast1Fr, N_DGrid, N_CM2;

type
  TK_FormCMStudyTemplateSelect = class(TN_BaseForm)
    ThumbsRFrame: TN_Rast1Frame;
    BtOK: TButton;
    BtCancel: TButton;
    PnSlides: TPanel;
    GBStudyName: TGroupBox;
    EdStudyName: TEdit;
    GBSudyColor: TGroupBox;
    CmBStudyColor: TComboBox;
    BtChange: TButton;
    procedure ThumbsRFrameDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CmBStudyColorDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure BtChangeClick(Sender: TObject);
  private
    { Private declarations }
    SDCSlides: TN_UDCMSArray;
    SDCThumbsDGrid: TN_DGridArbMatr;
    SDCDrawSlideObj: TN_CMDrawSlideObj;
    SSAPrevInd : Integer;
    PRebuildCurSlidesSet : PBoolean;
  public
    { Public declarations }

    procedure SDCDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure SDCGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                  AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
    procedure SSAChangeThumbState( ADGObj: TN_DGridBase; AInd: integer );

  end;

var
  K_FormCMStudyTemplateSelect: TK_FormCMStudyTemplateSelect;

function  K_CMStudyTemplateSelect( APSlide : TN_PUDCMSlide; ASlidesCount : Integer;
               out ASudySample : TN_UDCMStudy; out AStudyLabel : string;
               out AStudyColorInd : Integer;
               out ARebuildCurSlidesSetFlag : Boolean ) : Boolean;

implementation

{$R *.dfm}

uses Math,
  K_CLib0, K_CML1F, K_FCMStudyTemplateChange1,
  N_Types, N_CM1, N_Comp1, N_CMMain5F;

function  K_CMStudyTemplateSelect( APSlide : TN_PUDCMSlide; ASlidesCount : Integer;
               out ASudySample : TN_UDCMStudy; out AStudyLabel : string;
               out AStudyColorInd : Integer;
               out ARebuildCurSlidesSetFlag : Boolean ) : Boolean;
begin
  with TK_FormCMStudyTemplateSelect.Create( Application ) do
  begin
//    BaseFormInit( nil, '', [fvfCenter] );
//    BFIniSize := Point( 576, 422 );
    BFIniSize := Point( 518, 476 );

    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    SDCDrawSlideObj := TN_CMDrawSlideObj.Create();
    SDCThumbsDGrid  := TN_DGridArbMatr.Create2( ThumbsRFrame, SDCGetThumbSize );
    SetLength( SDCSlides, ASlidesCount );
    Move( APSlide^, SDCSlides[0], ASlidesCount * SizeOf(TN_UDCMSlide) );

    with SDCThumbsDGrid do
    begin
      DGEdges := Rect( 2, 2, 2, 2 );
      DGGaps  := Point( 2, 2 );
      DGScrollMargins := Rect( 8, 8, 8, 8 );
      if ASlidesCount <= 2 then
      begin
        DGLFixNumCols   := 0;
        DGLFixNumRows   := 1;
      end
      else
      if ASlidesCount <= 4 then
      begin
        DGLFixNumCols   := 2;
        DGLFixNumRows   := 0;
      end
      else
      if ASlidesCount <= 9 then
      begin
        DGLFixNumCols   := 3;
        DGLFixNumRows   := 0;
      end
      else
      if ASlidesCount <= 12 then
      begin
        DGLFixNumCols   := 4;
        DGLFixNumRows   := 0;
      end
      else
      begin
        DGLFixNumCols   := 5;
        DGLFixNumRows   := 0;
      end;
      DGMultiMarking  := FALSE;
      DGSkipSelecting := TRUE;
      DGChangeRCbyAK  := TRUE;
//      DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
      DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

      DGBackColor     := ColorToRGB( clBtnFace );
//      DGMarkBordColor := DGBackColor;
      DGMarkBordColor := N_CM_SlideMarkColor;
      DGMarkNormWidth := 2;
      DGMarkNormShift := 2;

      DGNormBordColor := DGBackColor;
      DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
      DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

      DGLAddDySize    := 14; // see DGLItemsAspect

      DGDrawItemProcObj := SDCDrawThumb;
      DGChangeItemStateProcObj := SSAChangeThumbState;
      DGNumItems := ASlidesCount;
      DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
//      SSAThumbsDGrid.DGMarkSingleItem( 0 );
      ThumbsRFrame.DstBackColor := DGBackColor;
      Windows.SetStretchBltMode( ThumbsRFrame.OCanv.HMDC, HALFTONE );
      SSAPrevInd := -1;
      DGMarkSingleItem(0);
    end; // with ThumbsDGrid do

    ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events

    FormStyle := fsStayOnTop;

    ASudySample := nil;
    AStudyLabel := '';
    AStudyColorInd := 0;
    Result := FALSE;

    with CmBStudyColor do
    begin
//      Style := csOwnerDrawFixed;
      OnDrawItem  := N_CM_MainForm.OnComboBoxColorItemDraw;
      Items.Clear;
      Items.AddStrings( N_CM_MainForm.CMMStudyColorsList );
      ItemIndex := 0;
    end;

    EdStudyName.Text := '';
    ARebuildCurSlidesSetFlag := FALSE;
    PRebuildCurSlidesSet := @ARebuildCurSlidesSetFlag;
    if (ShowModal() = mrOK) and
       (SDCThumbsDGrid.DGMarkedList.Count <> 0) then
    begin
      AStudyLabel := Trim(EdStudyName.Text);
      AStudyColorInd := CmBStudyColor.ItemIndex;
      ASudySample := TN_UDCMStudy(SDCSlides[Integer(SDCThumbsDGrid.DGMarkedList[0])]);
      ThumbsRFrame.RFFreeObjects();
      Result := TRUE;
    end;

    SDCDrawSlideObj.Free();
    SDCThumbsDGrid.Free();

  end; // with TK_FormCMStudySamples.Create( Application ) do

end; // function  K_CMStudyTemplateSelect

//************************************ TK_FormCMStudySamples.ThumbsRFrameDblClick ***
//
procedure TK_FormCMStudyTemplateSelect.ThumbsRFrameDblClick(Sender: TObject);
begin
  if SDCThumbsDGrid.DGMarkedList.Count > 0 then
    ModalResult := mrOK;
end; // procedure TK_FormCMStudySamples.ThumbsRFrameDblClick

//************************************ TK_FormCMStudySamples.SDCDrawThumb ***
// Draw one Thumbnail (used as TN_DGridBase.DGDrawItemProcObj)
//
//     Parameters
// ADGObj  - DGrid Objects that handles Thumbnails DGrid
// AInd    - given Thumbnail one dimensional Index
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper
//   left Buf pixel and may be not equal to upper left Grid pixel )
//
// Is used as value of SSAThumbsDGrid.DGDrawItemProcObj field
//
procedure TK_FormCMStudyTemplateSelect.SDCDrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
begin
  if (SDCThumbsDGrid.DGItemsFlags[AInd] = 0) and
     (AInd = SSAPrevInd) then
  begin
    //  Name
//    EdStudyName.Enabled := FALSE;
    // Colors
//    CmBStudyColor.Enabled := FALSE;

    BtOK.Enabled := FALSE;
    BtChange.Enabled := FALSE;
    SSAPrevInd := -1;
  end;

  with N_CM_GlobObj do  begin
//    CMStringsToDraw[0] := SSASlides[AInd].GetUName;
    CMStringsToDraw[0] := SDCSlides[AInd].ObjAliase;

{
    SDCDrawSlideObj.DrawOneThumb1( SDCSlides[AInd],
                                   CMStringsToDraw, SDCThumbsDGrid, ARect,
                                   0 );
{}
{}
    SDCDrawSlideObj.DrawOneThumb6( SDCSlides[AInd],
                               CMStringsToDraw, 1,
                               ADGObj, ARect,
                               ADGObj.DGItemsFlags[AInd] );
{}
{
    SDCDrawSlideObj.DrawOneThumb2( SDCSlides[AInd],
                                   CMStringsToDraw, SDCThumbsDGrid, ARect,
                                   0 );
}
  end; // with N_CM_GlobObj do
end; // end of TK_FormCMStudySamples.SDCDrawThumb

//********************************* TK_FormCMStudySamples.SDCGetThumbSize ***
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
procedure TK_FormCMStudyTemplateSelect.SDCGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
         AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );
var
  Slide : TN_UDCMSlide;
  ThumbDIB: TN_UDDIB;
  ThumbSize: TPoint;
begin
  with N_CM_GlobObj, ADGObj do
  begin
    Slide     := SDCSlides[AInd];
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
end; // procedure TK_FormCMStudySamples.SDCGetThumbSize

//***********************************  TK_FormCMSetSlidesAttrs.SSAChangeThumbState  ******
// Thumbnail Change State processing (used as TN_DGridBase.DGChangeItemStateProcObj)
//
//     Parameters
// ADGObj    - DGrid Objects that handles Thumbnails DGrid
// AInd      - Index of Thumbnail that is change state
//
procedure TK_FormCMStudyTemplateSelect.SSAChangeThumbState(
                                   ADGObj: TN_DGridBase; AInd: integer);
begin
  //  Name
//  EdStudyName.Enabled := TRUE;
  // Colors
//  CmBStudyColor.Enabled := TRUE;

  BtOK.Enabled := TRUE;
  BtChange.Enabled := K_CMGAModeFlag and BtChange.Visible;

  SSAPrevInd := AInd;
end; // end of TK_FormCMStudySamples.SSAChangeThumbState

//********************************* TK_FormCMStudySamples.FormShow ***
// Form Show Handler
//
procedure TK_FormCMStudyTemplateSelect.FormShow(Sender: TObject);
begin
  BtChange.Visible := BtChange.Visible and
                      (K_CMEDAccess is TK_CMEDDBAccess) and
                      (K_CMEDDBVersion >= 41);
                      
  BtChange.Enabled := K_CMGAModeFlag and BtChange.Visible;
end; // procedure TK_FormCMStudySamples.FormShow

//***************************** TK_FormCMStudySamples.CmBStudyColorDrawItem ***
// ComboBox StudyColor onDrawItem handler
//
procedure TK_FormCMStudyTemplateSelect.CmBStudyColorDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
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
  with CmBStudyColor, Canvas do
  begin
    FillRect(Rect);
    LBackground := Brush.Color;

    LRect := Rect;
    LRect.Right := LRect.Bottom - LRect.Top + LRect.Left;
    InflateRect(LRect, -1, -1);
    Brush.Color := TColor(N_CM_MainForm.CMMStudyColorsList.Objects[Index]);
    FillRect(LRect);
    Brush.Color := ColorToBorderColor(ColorToRGB(Brush.Color));
    FrameRect(LRect);

    Brush.Color := LBackground;
    Rect.Left := LRect.Right + 5;

    TextRect(Rect, Rect.Left,
      Rect.Top + (Rect.Bottom - Rect.Top - TextHeight(N_CM_MainForm.CMMStudyColorsList[Index])) div 2,
      N_CM_MainForm.CMMStudyColorsList[Index]);
  end;
end; // procedure TK_FormCMStudyTemplateSelect.CmBStudyColorDrawItem

//********************************* TK_FormCMStudySamples.FormShow ***
// Button BtChange onClick handler
//
procedure TK_FormCMStudyTemplateSelect.BtChangeClick(Sender: TObject);
begin
  if K_CMStudyTemplateChangeItemsOrder(
     TN_UDCMSlide(SDCSlides[Integer(SDCThumbsDGrid.DGMarkedList[0])]).ObjName ) then
    PRebuildCurSlidesSet^ := TRUE;
end; // procedure TK_FormCMStudyTemplateSelect.BtChangeClick

end.
