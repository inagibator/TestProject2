unit N_IconSelF;
// Icon Selection Form

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Types,
  N_Types, N_Lib1, N_BaseF, StdCtrls, N_Rast1Fr, N_DGrid, ExtCtrls;

type TN_MarkAction = ( maSet, maClear, maToggle );

type TN_IconItemInfo = record // Info about one Icon as DGrid Item
  IIIFlags:     integer;    // not used now
  IIIImageList: TImageList; // ImageList source ImageList
  IIIIconInd:   integer;    // Icon index in IIIImageList
end; // type TN_IconItemInfo = record // Info about one Icon as DGrid Item
type TN_IconItemInfoArray = Array of TN_IconItemInfo;

type TN_IconSelectionForm = class( TN_BaseForm ) // *** Icon Selection Form
  bnOK: TButton;
  bnCancel: TButton;
  ISFRFrame: TN_Rast1Frame;

  procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;

  public
  ISFDGrid: TN_DGridUniMatr;
  ISFIconsArray: TN_IconItemInfoArray;
  BufBMP: TBitmap;

  procedure ISFAddIconsRange   ( AImageList: TImageList; ABegInd, AEndInd: integer );
  procedure ISFOKCancelHandler ( ARFrameAction: TN_RFrameAction );
  procedure ISFInit();
  procedure ISFInitDGrid     ();
  procedure ISFShowModal     ();
  procedure ISFMarkItem      ( AMarkAction: TN_MarkAction );
  procedure ISFDrawIcon      ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
  procedure CurStateToMemIni (); override;
  procedure MemIniToCurState (); override;
end; // type TN_IconSelectionForm = class( TN_BaseForm )


    //*********** Global Procedures  *****************************

function  N_CreateIconSelectionForm ( AOwner: TN_BaseForm; AWidth, AHeight: integer ): TN_IconSelectionForm;


implementation
uses
  N_Gra2, N_InfoF;
{$R *.dfm}

//****************  TN_IconSelectionForm class handlers  ******************

procedure TN_IconSelectionForm.FormClose( Sender: TObject; var Action: TCloseAction);
// OnClose FormHandler
begin
  Inherited;

  Action := caFree;
  ISFDGrid.Free;
  BufBmp.Free;
end; // procedure TN_IconSelectionForm.FormClose


//****************  TN_IconSelectionForm class public methods  ************

//************************************** TN_IconSelectionForm.AddIconsRange ***
// Add Info about one Icons Range to ISFIconsArray
//
procedure TN_IconSelectionForm.ISFAddIconsRange( AImageList: TImageList;
                                                 ABegInd, AEndInd: integer );
var
  i, CurLeng: integer;
begin
  if AEndInd >= AImageList.Count then AEndInd := AImageList.Count - 1;

  CurLeng := Length( ISFIconsArray );
  SetLength( ISFIconsArray, CurLeng + AEndInd-ABegInd+1 );

  for i := CurLeng to High(ISFIconsArray) do // along all Icons in given Range
  with ISFIconsArray[i] do
  begin
    IIIFlags     := 0;           // clear field
    IIIImageList := AImageList;  // source ImageList
    IIIIconInd   := i + ABegInd - CurLeng; // Icon index in AImageList
  end; // for i := CurLeng to High(ISIconsArray) do // along all Icons in given Range
end; // end of procedure TN_IconSelectionForm.ISFAddIconsRange

//*************************************** TN_IconSelectionForm.ISFInitDGrid ***
// Init ISFDGrid after all Icons Ranges are added by ISFAddIconsRange
// Set DGItemsSize by ImageList Icon Size and
// DGNumItems, DGPItemsInfo by already prepared ISFIconsArray
//
procedure TN_IconSelectionForm.ISFInitDGrid();
begin
  with ISFRFrame, ISFDGrid, ISFIconsArray[0] do
  begin

  //*** Assume that all ImagLists have same Icon Size !

  DGItemsSize.X := IIIImageList.Width;
  DGItemsSize.Y := IIIImageList.Height;

  if BufBmp.Width  <> DGItemsSize.X then BufBmp.Width  := DGItemsSize.X;
  if BufBmp.Height <> DGItemsSize.Y then BufBmp.Height := DGItemsSize.Y;

  DGNumItems := Length( ISFIconsArray );

  end; // with ISFRFrame, ISFDGrid, ISFIconsArray[0] do
end; // end of procedure TN_IconSelectionForm.ISFInitDGrid

//********************************* TN_IconSelectionForm.ISFOKCancelHandler ***
// OK/Cancel Handler
//
// React on DoubleClick or Enter Key by assigning ModalResult := mrOK and
// on Escape Key by assigning ModalResult := mrCancel
//
// is used as ISFDGrid.DGExtExecProcObj Procedure of Object
//
procedure TN_IconSelectionForm.ISFOKCancelHandler( ARFrameAction: TN_RFrameAction );
begin
  with ISFRFrame do
  begin

    if ((CHType = htMouseDown) and (ssDouble in CMKShift)) or
       ((CHType = htKeyDown) and (CKey.CharCode = VK_RETURN)) then
      ModalResult := mrOK;

    if (CHType = htKeyDown) and (CKey.CharCode = VK_ESCAPE) then
      ModalResult := mrCancel;

  end; // with ISFRFrame do
end; // end of procedure TN_IconSelectionForm.ISFOKCancelHandler

//*************************************** TN_IconSelectionForm.ISFInit ***
// Initialize ISFDrid, ISFRFrame and show SElf in Modal mode
// (can be used if no additional settings should be done after caling ISFInitDGrid)
//
procedure TN_IconSelectionForm.ISFInit();
begin
  ISFInitDGrid();

  // ... possible final DGrid tuning

  with ISFDGrid do
  begin
    DGInitRFrame();
    DGMarkSingleItem( 0 ); // Mark zero Item (initial view)
  end; // with ISFDGrid do

//  ActiveControl := ISFRFrame; // To receive Mouse and Kyboards events
end; // procedure TN_IconSelectionForm.ISFShowModal

//*************************************** TN_IconSelectionForm.ISFShowModal ***
// Initialize ISFDrid, ISFRFrame and show SElf in Modal mode
// (can be used if no additional settings should be done after caling ISFInitDGrid)
//
procedure TN_IconSelectionForm.ISFShowModal();
begin
  ISFInit();
  ShowModal();
//  Show();
end; // procedure TN_IconSelectionForm.ISFShowModal

//*************************************** TN_IconSelectionForm.ISFShowModal ***
// Initialize ISFDrid, ISFRFrame and show SElf in Modal mode
// (can be used if no additional settings should be done after caling ISFInitDGrid)
//
procedure TN_IconSelectionForm.ISFMarkItem( AMarkAction: TN_MarkAction );
begin

end; // procedure TN_IconSelectionForm.ISFShowModal

//**************************************** TN_IconSelectionForm.ISFDrawIcon ***
// Draw one Icon
//
// ADGObj - ISDGrid
// AInd   - Item Index to draw
// ARect  - Item Rect in DGRFrame.OCanv.MainBuf Pixel coords
//                ( (0,0) means upper left Buf pixel and may be not equal to upper left Grid pixel )
procedure TN_IconSelectionForm.ISFDrawIcon( ADGObj: TN_DGridBase; AInd: integer;
                                                           const ARect: TRect );
begin
  with ADGObj, DGRFrame.OCanv, ISFIconsArray[AInd] do
  begin

  //***** Remark:
  // It is possible to assign HMDC to specially created Delphi Canvas object
  // and draw Icon to it using only one call to IIIImageList.Draw, but
  // it changes something in my OCanv that affect my subsequent drawing

  N_CopyRect( BufBmp.Canvas.Handle, Point(0,0), HMDC, ARect ); // Prepare BufBMP Background

  IIIImageList.Draw( BufBmp.Canvas, 0, 0, IIIIconInd ); // Draw Icon in BufBMP

  N_CopyRect( HMDC, ARect.TopLeft, BufBmp.Canvas.Handle, Rect(0,0,Width-1, Height-1) ); // Copy BufBMP to DGRFrame.OCanv

//  DrawPixString( ARect.TopLeft, Format( '%0.2d', [AInd] ) ); // Debug Draw one dim Index

  end; // with ADGObj, DGRFrame.OCanv, ISFIconsArray[AInd] do
end; // procedure TN_IconSelectionForm.ISFDrawIcon

//*********************************** TN_IconSelectionForm.CurStateToMemIni ***
// Save Current Self State (ComboBox Items and others)
//
procedure TN_IconSelectionForm.CurStateToMemIni();
begin
  Inherited;
end; // end of procedure TN_IconSelectionForm.CurStateToMemIni

//*********************************** TN_IconSelectionForm.MemIniToCurState ***
// Load Current Self State (ComboBox Items and others)
//
procedure TN_IconSelectionForm.MemIniToCurState();
begin
  Inherited;
end; // end of procedure TN_IconSelectionForm.MemIniToCurState


    //*********** Global Procedures  *****************************

//*********************************************** N_CreateIconSelectionForm ***
// Create and return new instance of TN_IconSelectionForm
//
//     Parameters
// AOwner  - Owner of created Form
// AWidth  - created Form width, used only if no info in Ini file
// AHeight - created Form height, used only if no info in Ini file
//
function N_CreateIconSelectionForm( AOwner: TN_BaseForm; AWidth, AHeight: integer ): TN_IconSelectionForm;
begin
  Result := TN_IconSelectionForm.Create( Application );

  with Result do
  begin
    BFIniSize := Point( AWidth, AHeight );
//    BaseFormInit( AOwner );
    BaseFormInit( AOwner, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );

    ActiveControl := ISFRFrame; // To receive Mouse and Keyboard events

    //*** Form.WindowProc should be changed for processing Arrow and Tab keys
    WindowProc := OwnWndProc;

    ISFDGrid := TN_DGridUniMatr.Create( ISFRFrame );
    with ISFDGrid do
    begin
      DGGaps := Point( 10, 10 );

      DGDrawItemProcObj := ISFDrawIcon;
      DGExtExecProcObj  := ISFOKCancelHandler;

      DGSkipSelecting := True;
      DGChangeRCbyAK  := True;
      DGMarkByBorder  := True;

      DGBackColor     := ColorToRGB( clBtnFace );
      DGMarkFillColor := DGBackColor;
      DGNormFillColor := DGBackColor;
      DGMarkBordColor := $BB0000;
      DGNormBordColor := DGBackColor;

      DGLFixNumCols := 0;
      DGLFixNumRows := 0;
      DGLItemsByRows := False;
    end; // with ISFDGrid do

    BufBmp := TBitmap.Create();
    BufBmp.PixelFormat := pf32bit;
  end; // with Result do
end; // function N_CreateIconSelectionForm


end.
