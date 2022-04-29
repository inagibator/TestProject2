unit K_FCMSelectSlide;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Types,
  K_CM0,
  N_BaseF, N_Rast1Fr, N_DGrid, N_CM2;

type
  TK_FormCMSelectSlide = class(TN_BaseForm)
    ThumbsRFrame: TN_Rast1Frame;
    BtOK: TButton;
    BtCancel: TButton;
    PnSlides: TPanel;
    procedure ThumbsRFramePaintBoxDblClick(Sender: TObject);
  private
    { Private declarations }
    SDCSlides: TN_UDCMSArray;
    SDCThumbsDGrid: TN_DGridArbMatr;
    SDCDrawSlideObj: TN_CMDrawSlideObj;
    SDShowSlideTime: Boolean;
  public
    { Public declarations }

    procedure SDCDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure SDCDrawThumb1   ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure SDCGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                  AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );

  end;

var
  K_FormCMSelectSlide: TK_FormCMSelectSlide;

function  K_CMSelectSlideDlg( APSlide : TN_PUDCMSlide; ASlidesCount : Integer;
                             const ADlgWinCapt : string; AShowSlideTime : Boolean = FALSE ) : Integer;

implementation

{$R *.dfm}

uses Math,
  K_CLib0,
  N_Types, N_CM1, N_Comp1;


function  K_CMSelectSlideDlg( APSlide : TN_PUDCMSlide; ASlidesCount : Integer;
                             const ADlgWinCapt : string; AShowSlideTime : Boolean = FALSE ) : Integer;
begin
  with TK_FormCMSelectSlide.Create( Application ) do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    Caption := ADlgWinCapt;
    SDShowSlideTime := AShowSlideTime;
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
      if ASlidesCount <= 6 then
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
//      DGSkipSelecting := True;
      DGMultiMarking  := False;
      DGChangeRCbyAK  := True;
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

      DGDrawItemProcObj := SDCDrawThumb1;
      DGNumItems := ASlidesCount;
      DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
//      SSAThumbsDGrid.DGMarkSingleItem( 0 );
      ThumbsRFrame.DstBackColor := DGBackColor;
    end; // with ThumbsDGrid do

    ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events

    FormStyle := fsStayOnTop;
    Result := -1;
    if ShowModal = mrOK then
      Result := SDCThumbsDGrid.DGSelectedInd;

    ThumbsRFrame.RFFreeObjects();
    SDCDrawSlideObj.Free();
    SDCThumbsDGrid.Free();

  end; // with TK_FormCMSlideIcons.Create( Application ) do

end;

//************************************ TK_FormCMSelectSlide.SDCDrawThumb ***
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
procedure TK_FormCMSelectSlide.SDCDrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
//var
//  WStr : string;
begin
  with N_CM_GlobObj do  begin
//    CMStringsToDraw[0] := SSASlides[AInd].GetUName;
    CMStringsToDraw[0] := K_CMSlideViewCaption( SDCSlides[AInd] );
//    CMStringsToDraw[0] := K_CMSlideViewCaption( SDCSlides[AInd] ) + WStr;

{}
    SDCDrawSlideObj.DrawOneThumb1( SDCSlides[AInd],
                                   CMStringsToDraw, SDCThumbsDGrid, ARect,
                                   0 );
{}
{
    SDCDrawSlideObj.DrawOneThumb2( SDCSlides[AInd],
                                   CMStringsToDraw, SDCThumbsDGrid, ARect,
                                   0 );
}
  end; // with N_CM_GlobObj do
end; // end of TK_FormCMSelectSlide.SDCDrawThumb

//************************************** TK_FormCMSelectSlide.SDCDrawThumb1 ***
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
procedure TK_FormCMSelectSlide.SDCDrawThumb1( ADGObj: TN_DGridBase; AInd: integer;
                                                           const ARect: TRect );
var
  LinesCount : Integer;
begin
  with N_CM_GlobObj do
  begin

    LinesCount := 0;
    with SDCSlides[AInd], P()^ do
    begin
      CMStringsToDraw[0] := K_DateTimeToStr( CMSDTTaken, 'dd"/"mm"/"yy' );
      Inc(LinesCount);

      if SDShowSlideTime then
      begin
        CMStringsToDraw[LinesCount] := K_DateTimeToStr( CMSDTTaken, 'hh":"nn":"ss' );
        Inc(LinesCount);
      end;
    end;


{
    CMMFDrawSlideObj.DrawOneThumb6( SDCSlides[AInd],
                               CMStringsToDraw, LinesCount,
                               ADGObj, ARect,
                               ADGObj.DGItemsFlags[AInd] );
}
    SDCDrawSlideObj.DrawOneThumb7( SDCSlides[AInd],
                               CMStringsToDraw, LinesCount,
                               ADGObj, ARect,
                               ADGObj.DGItemsFlags[AInd] );

  end; // with N_CM_GlobObj do
end; // procedure TK_FormCMSelectSlide.SDCDrawThumb1

//********************************* TK_FormCMSlidesDelConf.SDCGetThumbSize ***
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
procedure TK_FormCMSelectSlide.SDCGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
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
end; // procedure TK_FormCMSlidesDelConf.SDCGetThumbSize


procedure TK_FormCMSelectSlide.ThumbsRFramePaintBoxDblClick(
  Sender: TObject);
begin
  inherited;
  ThumbsRFrame.PaintBoxDblClick(Sender);
  ModalResult := mrOK;
end;

end.
