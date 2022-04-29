unit K_FCMSlideIcons;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Types,
  K_CM0,
  N_BaseF, N_Rast1Fr, N_DGrid, N_CM2;

type
  TK_FormCMSlideIcons = class(TN_BaseForm)
    Image: TImage;
    LbHead: TLabel;
    ThumbsRFrame: TN_Rast1Frame;
    BtOK: TButton;
    BtCancel: TButton;
    PnSlides: TPanel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    SDCSlides: TN_UDCMSArray;
    SDCThumbsDGrid: TN_DGridArbMatr;
    SDCDrawSlideObj: TN_CMDrawSlideObj;
    SDActiveButtonInd : Integer;
  public
    { Public declarations }

    procedure SDCDrawThumb    ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
    procedure SDCGetThumbSize ( ADGObj: TN_DGridBase; AInd: integer;
                  AInpSize: TPoint; out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint );

  end;

var
  K_FormCMSlideIcons: TK_FormCMSlideIcons;

function  K_CMSlideIconsDlg( APSlide : TN_PUDCMSlide; ASlidesCount : Integer;
                             const ADlgWinCapt, ADlgText : string;
                             ADlgType: TMsgDlgType = mtConfirmation;
                             AMDButtons: TMsgDlgButtons = [];
                             AMDButtonFocusInd : Integer = 0 ) : Boolean;
//                           AButCapts : array of const ) : Boolean;

implementation

{$R *.dfm}

uses Math,
  K_CLib0,
  N_Types, N_CM1, N_Comp1;

var
  IconIDs: array[TMsgDlgType] of PChar = (IDI_EXCLAMATION, IDI_HAND,
    IDI_ASTERISK, IDI_QUESTION, nil);

function  K_CMSlideIconsDlg( APSlide : TN_PUDCMSlide; ASlidesCount : Integer;
                             const ADlgWinCapt, ADlgText : string;
                             ADlgType: TMsgDlgType = mtConfirmation;
                             AMDButtons: TMsgDlgButtons = [];
                             AMDButtonFocusInd : Integer = 0 ) : Boolean;
//                             AButCapts : array of const ) : Boolean;
var
  ButCount : Integer;
  SA : TN_SArray;

begin
  with TK_FormCMSlideIcons.Create( Application ) do
  begin
//    BaseFormInit( nil, '', [fvfCenter] );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    Caption := ADlgWinCapt;
    if IconIDs[ADlgType] <> nil then
      Image.Picture.Icon.Handle := LoadIcon(0, IconIDs[ADlgType]);

    LbHead.Caption := ADlgText;

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
      DGSkipSelecting := True;
      DGChangeRCbyAK  := True;
//      DGCtrlDownMode  := True; // Mark as if Ctrl key is Down (leave previous marking unchanged)
      DGMarkByBorder  := True; // Mark by Drawing Border and filling by DGFillColor

      DGBackColor     := ColorToRGB( clBtnFace );
      DGMarkBordColor := DGBackColor;
//      DGMarkBordColor := N_CM_SlideMarkColor;
      DGMarkNormWidth := 2;
      DGMarkNormShift := 2;

      DGNormBordColor := DGBackColor;
      DGMarkFillColor := DGBackColor; // Rect Border interior Fill Color for Marked Items (used only if DGMarkByBorder=True)
      DGNormFillColor := DGBackColor; // Rect Border interior Fill Color for Unmarked Items (used only if DGMarkByBorder=True)

      DGLAddDySize    := 14; // see DGLItemsAspect

      DGDrawItemProcObj := SDCDrawThumb;
      DGNumItems := ASlidesCount;
      DGInitRFrame(); // should be called after all ThumbsDGrid fields are set
//      SSAThumbsDGrid.DGMarkSingleItem( 0 );
      ThumbsRFrame.DstBackColor := DGBackColor;
    end; // with ThumbsDGrid do

    ActiveControl := ThumbsRFrame; // otherwise SlidesFilterFrame gets Mouse and Keyboard events

    FormStyle := fsStayOnTop;

    SDActiveButtonInd := AMDButtonFocusInd;
    if AMDButtons = [] then
    begin
      if ADlgType = mtConfirmation then
        AMDButtons := [mbYes,mbNo]
      else
        AMDButtons := [mbOK];
    end;
    SA := K_CMGetMessageDlgTexts(AMDButtons);

    ButCount := Min( 1, High( SA ) );

    case ButCount of
       1: begin
        BtOK.Caption := SA[0];
        BtCancel.Caption := SA[1];
      end;
       0: BtCancel.Caption := SA[0];
      -1: BtCancel.Caption := 'OK';
    end;

{
    case ButCount of
       1: begin
        BtOK.Caption := K_GetStringFromVarRec( @AButCapts[0], 'Yes' );
        BtCancel.Caption := K_GetStringFromVarRec( @AButCapts[1], 'No' );
      end;
       0: BtCancel.Caption := K_GetStringFromVarRec( @AButCapts[0], 'OK' );
      -1: BtCancel.Caption := 'OK';
    end;
}
    if ButCount < 1 then
    begin
      BtCancel.ModalResult := mrOK;
      BtOK.Visible := FALSE;
    end;

    Result := ShowModal = mrOK;
    ThumbsRFrame.RFFreeObjects();
    SDCDrawSlideObj.Free();
    SDCThumbsDGrid.Free();

  end; // with TK_FormCMSlideIcons.Create( Application ) do

end;

//************************************ TK_FormCMSlidesDelConf.SDCDrawThumb ***
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
procedure TK_FormCMSlideIcons.SDCDrawThumb( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
var
  WStr : string;
begin
  with N_CM_GlobObj do  begin
//    CMStringsToDraw[0] := SSASlides[AInd].GetUName;
    CMStringsToDraw[0] := K_CMSlideViewCaption( SDCSlides[AInd] ) + WStr;

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
end; // end of TK_FormCMSlidesDelConf.SDCDrawThumb

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
procedure TK_FormCMSlideIcons.SDCGetThumbSize( ADGObj: TN_DGridBase; AInd: integer;
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

procedure TK_FormCMSlideIcons.FormShow(Sender: TObject);
begin
  if BtOK.Visible and (SDActiveButtonInd = 0) then
    BtOK.SetFocus()
  else
    BtCancel.SetFocus();
end;

end.
