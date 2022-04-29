unit N_DGrid;
// TN_DGridXXX clases for showing Grids (Tables) in Rast1Frame
//
// TN_DGridBase        = class( TObject )         - DGrid Base Class with Abstract methods
// TN_DGridBaseMatr    = class( TN_DGridBase )    - DGrid Base Matrix (Uniform and arbitrary)
// TN_DGridBaseMatrRFA = class( TN_RFrameAction ) - DGridBaseMatr RFrame Action
// TN_DGridUniMatr  = class( TN_DGridBaseMatr )   - DGrid Uniform Matrix (all cells have same size)
// TN_DGridArbMatr  = class( TN_DGridBaseMatr )   - DGrid Arbitrary (Nonuniform) Matrix (all Rows have same number of Items)
// TN_DGridNonMatr  = class( TN_DGridBase )       - DGrid NonMatrix (Rows may have different number of Items)
//
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Contnrs,
  N_Types, N_Gra2, N_Rast1Fr;

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_SetStateMode
type TN_SetStateMode = ( // DGSetItemState parameter type
  ssmMark,      // Mark Item
  ssmUnmark,    // Unmark Item
  ssmToggleMark // Mark if Unmarked, Unmark if marked
);

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGIndexType
type TN_DGIndexType = ( // DGGet... methods output parameter type
  dgitBefore, // given X or Y coordinate is Before (lefter or upper) Item Rect
  dgitInside, // given X or Y coordinate is Inside Item Rect
  dgitAfter,  // given X or Y coordinate is After (righter or lower) Item Rect
  dgitNotDef  // Item rect is not exists
);

type TN_DGridBase = class; // forward declaration

{type} TN_DGChangeItemStateProcObj = procedure( // User defined Proc of Obj for one item processing after it changed state
    ADGObj: TN_DGridBase; // Self
    AInd: integer         // Item one dimensional Index
                       ) of object;

{type} TN_DGDrawItemProcObj = procedure( // User defined Proc of Obj for drawing one item
    ADGObj: TN_DGridBase; // Self (at least DGRFrame.OCanv field is needed for drawing)
    AInd: integer;        // Item to draw one dimensional Index
    const ARect: TRect    // where to draw item in Grid Pixel coords
                          // ( (0,0) means upper left Grid pixel,
                          //   in DGRFrame.OCanv.MainBuf it may have negative coords )
                       ) of object;

{type} TN_DGGetItemSizeProcObj = procedure( // User defined Proc of Obj for getting given item Size
    ADGObj:   TN_DGridBase; // Self
    AInd:     integer;      // given Item one dimensional Index
    AInpSize: TPoint;       // Given Item Size (on input)
    out AOutSize, AMinSize, APrefSize, AMaxSize: TPoint // Resulting Item Sizes (on output)
                       ) of object;
//##fmt PELSize=80,PELPos=0,PELShift=2

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase
{type} TN_DGridBase = class( TObject ) // DrawGrid Base Class with Abstract methods

  DGRFrame: TN_Rast1Frame; // RFrame where to show Items (Self is not owner of 
                           //   DGRFrame)
  DGMarkedList: TList;     // List of Marked Items Indexes
  DGDrawItemProcObj: TN_DGDrawItemProcObj; // User defined Proc of Obj for 
                                           //   drawing one item
  DGExtExecProcObj:  TN_ActExtExecProcObj; // External RFrameAction Execute 
                                           //   Procedure of Object
  DGGetItemSizeProcObj: TN_DGGetItemSizeProcObj;
  DGChangeItemStateProcObj: TN_DGChangeItemStateProcObj;

  DGNumItems:    integer; // Number of Items to Show (<= DGNumCols*DGNumRows)
  DGNumRows:     integer; // Number of Rows (Matrix Y dimension or number of Row
                          //   Cell Arrays)
  DGNumCols:     integer; // Number Columns (Matrix X dimension)

  DGEdges:         TRect; // LTRB Edges widths around all Items (counting 
                          //   marking) in Pixels
  DGGaps:         TPoint; // X,Y Gaps between Items marking Borders in Pixels
  DGScrollMargins: TRect; // LTRB Margins around Item (counting marking) for 
                          //   Scrolling (used in DGScrollToItem)

  DGItemsFlags: TN_BArray;  // Array of Items flags
  DGItemsRects: TN_IRArray; // Array of Items Rects ( (0,0) - Upper Left DGRid 
                            //   pixel )
  DGColsPos:    TN_IPArray; // Array of Columns Positions (leftmoust and 
                            //   righmoust pixel X coord)
  DGRowsPos:    TN_IPArray; // Array of Rows Positions (uppermoust and 
                            //   lowermoust pixel Y coord)
  DGIndsInRows: TN_IPArray; // Array of first and last Items Indexes in Rows
  DGIndsInCols: TN_IPArray; // Array of first and last Items Indexes in Columns

  DGSelectedInd:    integer; // Selected Item one dimensional Index
  DGShiftAnchorInd: integer; // Anchor Item Ind (for marking with Shift Down)

  DGSkipMarkBefore: boolean; // 
  DGCurrentIsEmpty: boolean; // True if No Current Item, otherwise Current Item 
                             //   is the Selected Item
  DGSkipSelecting:  boolean; // Skip Special drawing for Selected Item
  DGCloseOnClick:   boolean; // Close DGRFrame Owner Form after Item Selection 
                             //   (for choosing only one Item)
  DGMultiMarking:   boolean; // Enable Multiple Marking (Enable Marking more 
                             //   than one Item)
  DGToggleOnShift:  boolean; // If Shift Key is Down - Toggle Marking (not just 
                             //   Mark) Items in Range
  DGCtrlDownMode:   boolean; // Mark as if Ctrl key is Down (leave previous 
                             //   marking unchanged)
  DGMarkByBorder:   boolean; // if True Mark by Drawing Border and filling by 
                             //   DGFillColor
  DGNotOrdered:     boolean; // Items are not oredered by Rows or Columns

  DGBackColor:     integer; // Grid Background Color
  DGMarkNormWidth: integer; // Rectangle Border width for Marked/Unmarked Items 
                            //   (relative to ItemRect+DGMarkNormShift)
  DGMarkNormShift: integer; // Rectangle Border Shift for Marked/Unmarked Items 
                            //   (relative to ItemRect)
  DGMarkFillColor: integer; // Rectangle Border interior Fill Color for Marked 
                            //   Items (used only if DGMarkByBorder=True)
  DGNormFillColor: integer; // Rectangle Border interior Fill Color for Unmarked
                            //   Items (used only if DGMarkByBorder=True)
  DGMarkBordColor: integer; // Rectangle Border Color for Marked Items
  DGNormBordColor: integer; // Rectangle Border Color for Normal (nor Marked) 
                            //   Items
  DGSelectWidth:   integer; // Rectangle Border width for Slected Item
  DGSelectShift:   integer; // Rectangle Border Shift for Slected Item (relative
                            //   to ItemRect)
  DGSelectColor1:  integer; // Rectangle Border Color1 for Slected Item
  DGSelectColor2:  integer; // Rectangle Border Color2 for Slected Item

  DGUpdateCounter: integer; // Skip DGRFrame.ShowMainBuf if DGUpdateCounter > 0

  DGLFixNumCols:  integer; // if > 0 Number of Columns are fixed
  DGLFixNumRows:  integer; // if > 0 Number of Rows are fixed
  DGLAddDySize:   integer; // Additional Dy Size (for calculating Size and 
                           //   Drawing)
  DGLItemsByRows: boolean; // Horizontal Items Layout (by Rows), otherwise by 
                           //   Columns
  DGLItemsAspect: double;  // Items Size should satisfy: 
                           //   (Size.Y-DGLAddDySize)/Size.X = DGLItemsAspect

  constructor Create  ( ARFrame: TN_Rast1Frame ); virtual;
  destructor  Destroy ();  override;

  procedure DGInitRFrame    (); virtual;
  procedure DGCalcItemInds  ( AInd: integer; out AColInd, ARowInd: integer ); virtual;

  function  DGGetRowInd       ( APixY: integer; out AIndType: TN_DGIndexType ): integer; virtual;
  function  DGGetColInd       ( APixX: integer; out AIndType: TN_DGIndexType ): integer; virtual;
  function  DGGetItemIndInCol ( AColInd, APixY: integer; out AIndType: TN_DGIndexType ): integer; virtual;
  function  DGGetItemIndInRow ( ARowInd, APixX: integer; out AIndType: TN_DGIndexType ): integer; virtual;

  procedure DGGetItemByPoint  ( APoint: TPoint; out AColInd, ARowInd, AItemInd: integer;
                             out AColIndType, ARowIndType, AItemIndType: TN_DGIndexType ); virtual;

  function  DGGetItemRect     ( AItemInd: integer ): TRect;
  function  DGGetTopLeftItemInd (): integer;
  function  DGGetItemPos      ( AInd: integer ): TPoint;
  procedure DGScrollToItemPos ( AInd: integer; AItemPos: TPoint );
  procedure DGScrollToItem    ( AInd: integer );
  procedure DGSetItemState    ( AInd: integer; ASetAct: TN_SetStateMode );
  procedure DGMarkSingleItem  ( AInd: integer );
  procedure DGMarkItems       ( AMarkedList: TList );
  procedure DGSelectItem      ( AInd: integer );

  procedure DGDrawRFrame     ();
  procedure DGDrawRFrameRect ( ARect: TRect );
  procedure DGDrawItem       ( AInd: integer );
  procedure DGTestDrawItem1  ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
  procedure DGTestDrawItem2  ( ADGObj: TN_DGridBase; AInd: integer; const ARect: TRect );
  procedure DGResizeRFrame   ();
  procedure DGBeginUpdate    ();
  procedure DGEndUpdate      ();
  procedure DGSetAllItemsState ( AState: TN_SetStateMode );
  procedure DGGetSelection     ( var AInds: TN_IArray );
  procedure DGSetSelection     ( AInds: TN_IArray );
end; // type TN_DGridBase = class( TObject )

//##fmt

type TN_DGridBaseMatrRFA = class; // forvard Reference

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatr
{type} TN_DGridBaseMatr = class( TN_DGridBase ) // DrawGrid Base Matrix (Uniform and arbitrary)
  DGChangeRCbyAK: boolean; // Change Row, Column by Arrow Keys
  DGBaseMatrRFA: TN_DGridBaseMatrRFA; // Self DGRFrame Action

  constructor Create        ( ARFrame: TN_Rast1Frame ); override;
  procedure DGInitRFrame    (); override;

  function  DGGetItemInd    ( AColInd, ARowInd: integer ): integer;
  procedure DGCalcItemInds  ( AInd: integer; out AColInd, ARowInd: integer ); override;
  function  DGGetMaxRowInd  ( AColInd: integer ): integer;
  function  DGGetMaxColInd  ( ARowInd: integer ): integer;
  procedure DGGetItemByPoint( APoint: TPoint; out AColInd, ARowInd, AItemInd: integer;
                          out AColIndType, ARowIndType, AItemIndType: TN_DGIndexType ); override;

  procedure DGInitArrays    ();
end; // type TN_DGridBaseMatr = class( TN_DGridBase )


//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatrRFA
{type} TN_DGridBaseMatrRFA = class( TN_RFrameAction ) // DrawGrid Base Matrix Raster Frame Action
  RFADGrid: TN_DGridBaseMatr; // Main DGrid Object
  RFALastMarked : Integer;    // Item index marked by last MouseDown
  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure RedrawAction (); override;
end; // type TN_DGridBaseMatrRFA = class( TN_RFrameAction )


//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridUniMatr
type TN_DGridUniMatr = class( TN_DGridBaseMatr ) // DrawGrid Uniform Matrix (all cells have same size)
  DGItemsSize: TPoint; // all Items X,Y Size in Pixels (in some modes they are 
                       // calculated while layout)

  constructor Create      ( ARFrame: TN_Rast1Frame );  override;
  procedure DGInitRFrame  (); override;

  function  DGGetRowInd       ( APixY: integer; out AIndType: TN_DGIndexType ): integer; override;
  function  DGGetColInd       ( APixX: integer; out AIndType: TN_DGIndexType ): integer; override;
  function  DGGetItemIndInCol ( AColInd, APixY: integer; out AIndType: TN_DGIndexType ): integer; override;
  function  DGGetItemIndInRow ( ARowInd, APixX: integer; out AIndType: TN_DGIndexType ): integer; override;
end; // type TN_DGridUniMatr = class( TN_DGridBaseMatr )


//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridArbMatr
type TN_DGridArbMatr = class( TN_DGridBaseMatr ) // DrawGrid Arbitrary (Non uniform) Matrix
                            // (different Rows,Cols Size, Item may be less than its Row,Col Size)

  constructor Create2     ( ARFrame: TN_Rast1Frame; AGetSize: TN_DGGetItemSizeProcObj );
  procedure DGInitRFrame  (); override;
end; // type TN_DGridArbMatr = class( TN_DGridBaseMatr )


//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridNonMatr
type TN_DGridNonMatr = class( TN_DGridBase ) // DrawGrid NonMatrix
                            // (Rows can have different number of items)
  constructor Create      ( ARFrame: TN_Rast1Frame ); override;
  procedure DGInitRFrame  (); override;
//  function  DGGetRowInd   ( APixY: integer ): integer; override;
//  function  DGGetColInd   ( ARowInd, APixX: integer ): integer; override;
end; // type TN_DGridNonMatr = class( TN_DGridBase )


const
  N_DGMarkBit:     Byte = $80; // Marked Item Bit
  N_DGMarkBitMask: Byte = $7F; // Marked Item Bit clear Mask

implementation

uses Types, math,
//  K_FCMChangeSlidesAttrsN,
  N_Lib0, N_Lib1, N_Gra0, N_Gra1, N_InfoF;

//********** TN_DGridBase class Public methods  **************

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\Create
//***************************************************** TN_DGridBase.Create ***
// TN_DGridBase constructor
//
//     Parameters
// ARFrame - TN_Rast1Frame in which DGrid should be shown
//
constructor TN_DGridBase.Create( ARFrame: TN_Rast1Frame );
var
  BSize: integer;
begin
  DGDrawItemProcObj := DGTestDrawItem1; // not really needed, can be used as default drawing

  DGEdges          := Rect( 5, 5, 5, 5 );
  DGGaps           := Point( 5, 5 );
  DGSelectedInd    := -1; // No Item is Selected
  DGShiftAnchorInd := -1; // No Anchor Item

  DGBackColor     := $FFFFFF; // DGrid backgroung Color
  DGMarkNormWidth := 1;       // Marked and Nonmarked Items Border width in Pixels
  DGMarkBordColor := $00CC00; // Marked Items Border Color
  DGMarkFillColor := DGMarkBordColor;
  DGNormBordColor := $CCCCCC; // Nonmarked Items Border Color
  DGNormFillColor := DGNormBordColor;

  BSize := DGMarkNormWidth + DGMarkNormShift;
  with DGGaps do
    DGScrollMargins := Rect( X+BSize, Y+BSize, X+BSize, Y+BSize );

  DGSelectWidth   := 1;       // Selected Item (one or none) Border width in Pixels
  DGSelectColor1  := 0;       // Selected Item (one or none) Border first dash Color
  DGSelectColor2  := $FFFFFF; // Selected Item (one or none) Border second dash Color

  DGMultiMarking := True;
  
  DGMarkedList := TList.Create; // Indexes of marked Items

  DGRFrame := ARFrame;

  with DGRFrame do // prepare DGRFrame (given ARFrame) for using by TN_DGridBase
  begin
    RFFixedScale       := True;
    ScrollByMouseWheel := True;
    RFSkipAnimation    := True;
    DstBackColor       := DGBackColor;

    DrawProcObj     := DGDrawRFrame;   // Draw all Items, not only intersecting MainBuf
    // DrawProcObj := DGDrawRFrameRect; // Draw only Items that affect MainBuf

    RFResizeProcObj := DGResizeRFrame; // On Resize handler
  end; // with DGRFrame do // prepare DGRFrame
end; // constructor TN_DGridBase.Create

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\Destroy
//**************************************************** TN_DGridBase.Destroy ***
// TN_DGridBase destructor
//
destructor TN_DGridBase.Destroy;
begin
  DGMarkedList.Free;
end; // // destructor TN_DGridBase.Destroy;

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGInitRFrame
//*********************************************** TN_DGridBase.DGInitRFrame ***
// Layout Grid Elements and Initialize DGRFrame
//
procedure TN_DGridBase.DGInitRFrame();
begin
//  DGRFrame.SkipOnPaint    := False; // to enable filling background if Slide is not set yet
//  DGRFrame.SkipOnResize    := False; // to enable filling background if Slide is not set yet
  // empty in Base Class
end; // procedure TN_DGridBase.DGInitRFrame

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGCalcItemInds
//********************************************* TN_DGridBase.DGCalcItemInds ***
// Calculate Item Column and Row Indexes by it's one dimensional index
//
//     Parameters
// AInd    - given Item one dimensional Index
// AColInd - on output, resulting Item Column Index (Index along X Axis)
// ARowInd - on output, resulting Item Row Index (Index along Y Axis)
//
// For Not Matrix DGrid, really only one output index is Row or Column Index, 
// the other one is relative Item index in approprite Column or Row
//
procedure TN_DGridBase.DGCalcItemInds( AInd: integer; out AColInd, ARowInd: integer );
var
  FoundInd: integer;
begin
  ARowInd := -1;
  AColInd := -1;
  if DGNotOrdered then Exit;

  if (AInd < 0) or (AInd >= DGNumItems) then Exit; // a precaution

  if DGLItemsByRows then
  begin
    if DGIndsInRows = nil then Exit; // a precaution

    FoundInd := N_BinSearch2( TN_BytesPtr(@DGIndsInRows[0]), 2*DGNumRows,
                                               SizeOf(integer), AInd );
    ARowInd := FoundInd div 2;
    AColInd := AInd - ARowInd*DGNumCols;
  end else // Items by Columns Layout
  begin
    if DGIndsInCols = nil then Exit; // a precaution

    FoundInd := N_BinSearch2( TN_BytesPtr(@DGIndsInCols[0]), 2*DGNumCols,
                                               SizeOf(integer), AInd );
    AColInd := FoundInd div 2;
    ARowInd := AInd - AColInd*DGNumRows;
  end;
end; // procedure TN_DGridBase.DGCalcItemInds

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGGetRowInd
//************************************************ TN_DGridBase.DGGetRowInd ***
// Get Grid Row Index by given Y coordinate
//
//     Parameters
// APixY    - given Y coordinate in Grid Pixel coords
// AIndType - resulting Row Index type
// Result   - Returns Row Index which intersect Y=APixY line, is before or after
//            this line.
//
function TN_DGridBase.DGGetRowInd( APixY: integer;
                                   out AIndType: TN_DGIndexType ): integer;
var
  NumInts, FoundInd: integer;
begin
  Result := -1; // can be any value if AIndType = dgitNotDef
  AIndType := dgitNotDef;

  if DGNotOrdered then Exit; // Items are not Ordered
  if DGRowsPos = nil then Exit; // Rows Positions (coords) are not defined

  NumInts := 2*DGNumRows;
  FoundInd := N_BinSearch2( TN_BytesPtr(@DGRowsPos[0]), NumInts, SizeOf(integer), APixY );

  if FoundInd = -1 then // APixY is Before first Row
  begin
    Result := 0; // Before first Row
    AIndType := dgitBefore;
  end else if FoundInd = NumInts then // APixY is After last Row
  begin
    Result := DGNumRows - 1; // After last Row
    AIndType := dgitAfter;
  end else // BegFirstRow <= APixY <= EndLastRow, inside or before some Row
  begin
    Result := FoundInd shr 1;
    AIndType := dgitInside;

    if ((FoundInd and $01) <> 0)  and // EndRow <= APixY < BegRow
       (APixY > DGRowsPos[Result].Y) then // EndRow < APixY < BegRow
    begin
      Inc( Result );
      AIndType := dgitBefore;
    end; // if ... then // EndRow < APixY < BegRow

  end; // else // BegFirstRow <= APixY <= EndLastRow
end; // function TN_DGridBase.DGGetRowInd

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGGetColInd
//************************************************ TN_DGridBase.DGGetColInd ***
// Get Grid Column Index by given X coordinate
//
//     Parameters
// APixX    - given X coordinate in Grid Pixel coords
// AIndType - resulting Column Index type
// Result   - Returns Column Index which intersect X=APixX line, is before or 
//            after this line.
//
function TN_DGridBase.DGGetColInd( APixX: integer;
                                   out AIndType: TN_DGIndexType ): integer;
var
  NumInts, FoundInd: integer;
begin
  Result := -1; // can be any value if AIndType = dgitNotDef
  AIndType := dgitNotDef;

  if DGNotOrdered then Exit; // Items are not Ordered
  if DGColsPos = nil then Exit; // Columns Positions (coords) are not defined

  NumInts := 2*DGNumCols;
  FoundInd := N_BinSearch2( TN_BytesPtr(@DGColsPos[0]), NumInts, SizeOf(integer), APixX );

  if FoundInd = -1 then // APixX is Before first Column
  begin
    Result := 0; // Before first Column
    AIndType := dgitBefore;
  end else if FoundInd = NumInts then // APixX is After last Column
  begin
    Result := DGNumRows - 1; // After last Column
    AIndType := dgitAfter;
  end else // BegFirstCol <= APixX <= EndLastCol, inside or before some Column
  begin
    Result := FoundInd shr 1;
    AIndType := dgitInside;

    if ((FoundInd and $01) <> 0)  and // EndCol <= APixX < BegCol
       (APixX > DGColsPos[Result].Y) then // EndCol < APixX < BegCol
    begin
      Inc( Result );
      AIndType := dgitBefore;
    end; // if ... then // EndCol < APixX < BegCol

  end; // else // BegFirstCol <= APixX <= EndLastCol
end; // function TN_DGridBase.DGGetColInd

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGGetItemIndInCol
//****************************************** TN_DGridBase.DGGetItemIndInCol ***
// Get Index of Item in given Column by given Y coordinate
//
//     Parameters
// AColInd  - given Column Index (Index along X Axis)
// APixY    - given X coordinate in Grid Pixel coords
// AIndType - resulting Item Index type
// Result   - Returns Item Index for the Item in given AColInd Column which 
//            intersect Y=APixY line, is before or after this line.
//
function TN_DGridBase.DGGetItemIndInCol( AColInd, APixY: integer;
                                     out AIndType: TN_DGIndexType ): integer;
var
  NumItems, FirstInd, LastInd, FoundInd: integer;
begin
  Result := -1; // can be any value if AIndType = dgitNotDef
  AIndType := dgitNotDef;

  if DGNotOrdered then Exit; // Items are not Ordered
  if DGItemsRects = nil then Exit; // no Items Rects
  if DGIndsInCols = nil then Exit; // range of Items Indexes in Column are not defined

  if (AColInd < 0) or (AColInd >= DGNumCols) then Exit; // AColInd out of range

  FirstInd := DGIndsInCols[AColInd].X; // First Item Index in AColInd Column
  LastInd  := DGIndsInCols[AColInd].Y; // Last Item Index in AColInd Column
  NumItems := LastInd - FirstInd + 1;  // Number of Items in AColInd Column

  FoundInd := N_BinSearch2( TN_BytesPtr(@DGItemsRects[FirstInd].Top), 2*NumItems,
                                                            SizeOf(TPoint), APixY );
  if FoundInd = -1 then // APixY is Before first Item
  begin
    Result := FirstInd; // Before first Item
    AIndType := dgitBefore;
  end else if FoundInd = (FirstInd+NumItems) then // APixY is After last Item
  begin
    Result := LastInd; // After last Item
    AIndType := dgitAfter;
  end else // BegFirstItem <= APixY <= EndLastItem, inside or before some Item in AColInd Column
  begin
    Result := FoundInd shr 1;
    AIndType := dgitInside;

    if ((FoundInd and $01) <> 0)  and // EndItem <= APixY < BegItem
       (APixY > DGItemsRects[Result].Right) then // EndItem < APixY < BegItem
    begin
      Inc( Result );
      AIndType := dgitBefore;
    end; // if ... then // EndItem < APixY < BegItem

  end; // else // BegFirstItem <= APixY <= EndLastItem

end; // function TN_DGridBase.DGGetItemIndInCol

//##fmt DFLSize=60,DFLILPos=0,DFLILShift=-3

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGGetItemIndInRow
//****************************************** TN_DGridBase.DGGetItemIndInRow ***
// Get Index of Item in given Row by given X coordinate
//
//     Parameters
// ARowInd  - given Row Index (Index along Y Axis)
// APixX    - given X coordinate in Grid Pixel coords
// AIndType - resulting Item Index type
// Result   - Returns Item Index for the Item in given 
//         ARowInd Row which intersect X=APixX line, is 
//         before or after this line.
//
function TN_DGridBase.DGGetItemIndInRow( ARowInd, APixX: integer;
                                     out AIndType: TN_DGIndexType ): integer;
var
  NumItems, FirstInd, LastInd, FoundInd: integer;
begin
  Result := -1; // can be any value if AIndType = dgitNotDef
  AIndType := dgitNotDef;

  if DGNotOrdered then Exit; // Items are not Ordered
  if DGItemsRects = nil then Exit; // no Items Rects
  if DGIndsInRows = nil then Exit; // range of Items Indexes in Row are not defined

  if (ARowInd < 0) or (ARowInd >= DGNumRows) then Exit; // ARowInd out of range

  FirstInd := DGIndsInRows[ARowInd].X; // First Item Index in ARowInd Row
  LastInd  := DGIndsInRows[ARowInd].Y; // Last Item Index in ARowInd Row
  NumItems := LastInd - FirstInd + 1;  // Number of Items in ARowInd Row

  FoundInd := N_BinSearch2( TN_BytesPtr(@DGItemsRects[FirstInd].Left), 2*NumItems,
                                                            SizeOf(TPoint), APixX );
  if FoundInd = -1 then // APixX is Before first Item
  begin
    Result := FirstInd; // Before first Item
    AIndType := dgitBefore;
  end else if FoundInd = (FirstInd+NumItems) then // APixX is After last Item
  begin
    Result := LastInd; // After last Item
    AIndType := dgitAfter;
  end else // BegFirstItem <= APixX <= EndLastItem, inside or before some Item in ARowInd Row
  begin
    Result := FoundInd shr 1;
    AIndType := dgitInside;

    if ((FoundInd and $01) <> 0)  and // EndItem <= APixX < BegItem
       (APixX > DGItemsRects[Result].Bottom) then // EndItem < APixX < BegItem
    begin
      Inc( Result );
      AIndType := dgitBefore;
    end; // if ... then // EndItem < APixX < BegItem

  end; // else // BegFirstItem <= APixX <= EndLastItem

end; // function TN_DGridBase.DGGetItemIndInRow

//##fmt

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGGetItemByPoint
//******************************************* TN_DGridBase.DGGetItemByPoint ***
// Get Item Indexes by given APoint
//
//     Parameters
// APoint       - given Point in Grid Pixel coords ( (0,0) means upper left Grid
//                pixel )
// AColInd      - resulting Item Column Index if aplicable
// ARowInd      - resulting Item Row Index if aplicable
// AItemInd     - resulting Item Index that covers or is near given APoint
// AColIndType  - resulting Item Column Index Type
// ARowIndType  - resulting Item Row Index Type
// AItemIndType - resulting Item Index Type
//
procedure TN_DGridBase.DGGetItemByPoint( APoint: TPoint;
                                         out AColInd, ARowInd, AItemInd: integer;
                      out AColIndType, ARowIndType, AItemIndType: TN_DGIndexType );
var
  i: integer;
begin
  AColInd := DGGetColInd( APoint.X, AColIndType );

  if AColIndType = dgitNotDef then // Col Index can not be defined, try get Row Index
  begin
    ARowInd := DGGetRowInd( APoint.Y, ARowIndType );

    if ARowIndType = dgitNotDef then // Row Index also can not be defined
    begin
      AItemInd := -1; // not found
      AItemIndType := dgitNotDef;

      if DGItemsRects = nil then Exit; // a precaution

      for i := 0 to DGNumItems-1 do // along all ItmesRects
      begin
        if 0 <> N_PointInRect( APoint, DGItemsRects[i] ) then // found
        begin
          AItemInd := i;
          AItemIndType := dgitInside;
          Exit; // all done
        end; // if 0 <> N_PointInRect( APoint, DGItemsRects[i] ) then // found
      end; // for i := 0 to DGNumItems-1 do // along all ItmesRects

      //***** Here: not found, all output Params are already OK
      Exit; // not really needed
    end else //************************ ARowInd is OK, use it
      AItemInd := DGGetItemIndInRow( ARowInd, APoint.X, AItemIndType );

  end else //************************ AColInd is OK, use it
  begin
    ARowInd := -1;
    ARowIndType := dgitNotDef;
    AItemInd := DGGetItemIndInCol( AColInd, APoint.Y, AItemIndType );
  end; // else // AColInd is OK, use it

end; // procedure TN_DGridBase.DGGetItemInds

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGGetItemRect
//********************************************** TN_DGridBase.DGGetItemRect ***
// Get Item Rectangle in Grid Pixel coords
//
//     Parameters
// AItemInd - given Item Index
// Result   - Return Item Rectangle in Grid Pixel coords ( (0,0) means upper 
//            left Grid pixel )
//
function TN_DGridBase.DGGetItemRect( AItemInd: integer ): TRect;
begin
  if (AItemInd < 0) or (AItemInd >= DGNumItems) or (DGItemsRects = nil) then
    Result := Rect(0,0,0,0)
  else
    Result := DGItemsRects[AItemInd];
end; // function TN_DGridBase.DGGetItemRect

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGGetTopLeftItemInd
//**************************************** TN_DGridBase.DGGetTopLeftItemInd ***
// Get Item index for the Top Left partially visible Item
//
//     Parameters
// Result - Returns Item index for the Top Left visible Item
//
// Item is partially visible if it intersects whole visible Rectangle 
// DGRFrame.RFSrcPRect
//
function TN_DGridBase.DGGetTopLeftItemInd(): integer;
var
  ColInd, RowInd: integer;
  GridTopLeftVis: TPoint;
  ColIndType, RowIndType, ItemIndType: TN_DGIndexType;
begin
  with DGRFrame do
  begin
    Result := -1;
    if RFLogFramePRect.Left = RFLogFramePRect.Right then Exit; // DGRFrame is not initailized

    GridTopLeftVis.X := RFSrcPRect.Left - RFLogFramePRect.Left;
    GridTopLeftVis.Y := RFSrcPRect.Top  - RFLogFramePRect.Top;

    DGGetItemByPoint( GridTopLeftVis, ColInd, RowInd, Result,
                                      ColIndType, RowIndType, ItemIndType );
  end; // with DGRFrame do
end; // function TN_DGridBase.DGGetTopLeftItemInd

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGGetItemPos
//*********************************************** TN_DGridBase.DGGetItemPos ***
// Get given AInd Item's 'visible' position
//
//     Parameters
// AInd   - given Item one dimensional Index
// Result - Returns Item's 'visible' position
//
// Item's 'visible' position is the distance between given Item Rect.TopLeft and
// DGRFrame.RFSrcPRect.TopLeft. Item is partially visible if it intersects whole
// visible Rectangle DGRFrame.RFSrcPRect.
//
function TN_DGridBase.DGGetItemPos( AInd: integer ): TPoint;
var
  ItemRect: Trect;
begin
  Result := Point( 0, 0 );
  if (AInd < 0) or (AInd >= DGNumItems) then Exit; // Item is not given

  ItemRect := DGGetItemRect( AInd );

  with DGRFrame do
  begin
    Result.X := ItemRect.Left - RFLogFramePRect.Left - RFSrcPRect.Left;
    Result.Y := ItemRect.Top  - RFLogFramePRect.Top  - RFSrcPRect.Top;
  end; // with DGRFrame do
end; // function TN_DGridBase.DGGetItemPos

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGScrollToItemPos
//****************************************** TN_DGridBase.DGScrollToItemPos ***
// Scroll DGRFrame by given Item's 'visible' position
//
//     Parameters
// AInd     - given Item one dimensional Index or -1
// AItemPos - given needed 'visible' position for given Item or needed 
//            DGRFrame.RFSrcPRect.TopLeft if AInd = -1
//
// Item's 'visible' position is the distance between given Item Rect.TopLeft and
// DGRFrame.RFSrcPRect.TopLeft.
//
// Procedure Scrolls DGRFrame so, that given Item Top Left corner has given 
// distance from Top Left corner of whole visible Rectangle DGRFrame.RFSrcPRect
//
procedure TN_DGridBase.DGScrollToItemPos( AInd: integer; AItemPos: TPoint );
var
  NewTopLeftRel: TPoint;
  ItemRect: Trect;
begin
  if AInd = -1 then
    DGRFrame.ShiftRFSrcPRect( AItemPos )
  else // AInd >= 0, ItemRect can be calculated
  begin
    ItemRect := DGGetItemRect( AInd );

    NewTopLeftRel.X := ItemRect.Left - AItemPos.X;
    NewTopLeftRel.Y := ItemRect.Top  - AItemPos.Y;

    DGRFrame.ShiftRFSrcPRect( NewTopLeftRel );
  end; // else // AInd >= 0, ItemRect can be calculated
end; // procedure TN_DGridBase.DGScrollToItemPos

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGScrollToItem
//********************************************* TN_DGridBase.DGScrollToItem ***
// Scroll DGRFrame to make given Item fully visible
//
//     Parameters
// AInd - given Item one dimensional Index
//
// If Item is already visible (Item itself, without counting DGScrollMargins) do
// not do anything. Otherwise minimally Scroll DGFRame to make given AInd Item 
// fully Visible with given DGScrollMargins around it.
//
// Item fully Visible if it is stricly inside whole visible Rectangle 
// DGRFrame.RFSrcPRect
//
procedure TN_DGridBase.DGScrollToItem( AInd: integer );
var
  ItemRect, NeededRect: TRect;
begin
  ItemRect := DGGetItemRect( AInd );
  ItemRect := N_RectChangeCoords1( ItemRect, DGScrollMargins );

  NeededRect := DGRFrame.RFSrcPRect;

  // minimally Shift NeededRect to cover ItemRect
  NeededRect := N_RectAdjustByMinRect( NeededRect, ItemRect );

  DGRFrame.ShiftRFSrcPRect( NeededRect.TopLeft );
end; // procedure TN_DGridBase.DGScrollToItem

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGSetItemState
//********************************************* TN_DGridBase.DGSetItemState ***
// Set given Item State (now only Mark State)
//
//     Parameters
// AInd    - given Item one dimensional Index
// ASetAct - given Set Action (Mark, Unmark or ToggleMarking)
//
// Mark, Unmark or Toggle given Item Marking. DGSelectedInd remains unchanged.
//
procedure TN_DGridBase.DGSetItemState( AInd: integer; ASetAct: TN_SetStateMode );
var
  NowIsMarked: boolean;
  Label Mark, Unmark, Draw;
begin
//  N_Dump1Str( Format( 'DGSetItemState AInd=%d, ASetAct=%1x', [AInd,integer(ASetAct)] ));
  if (AInd < 0) or (AInd >=DGNumItems) then Exit; // a precaution

  NowIsMarked := (DGItemsFlags[AInd] and N_DGMarkBit) <> 0;

  if NowIsMarked then // AInd Item is Marked
  begin
    case ASetAct of
      ssmMark:       Exit; // already Marked, nothing todo
      ssmUnmark:     goto Unmark;
      ssmToggleMark: goto Unmark;
    end;
  end else //*********** AInd Item is not Marked
  begin
    case ASetAct of
      ssmMark:       goto Mark;
      ssmUnmark:     Exit; // already not Marked, nothing todo
      ssmToggleMark: goto Mark;
    end;
  end;

  Mark: //*******
  DGItemsFlags[AInd] := DGItemsFlags[AInd] or N_DGMarkBit; // Set Marked bit for AInd Item
  DGMarkedList.Add( Pointer(AInd) ); // Add AInd Item to DGMarkedList
  goto Draw;

  Unmark: //*****
  DGItemsFlags[AInd] := DGItemsFlags[AInd] and N_DGMarkBitMask; // Clear Marked bit for AInd Item
  DGMarkedList.Remove( Pointer(AInd) ); // Remove AInd Item from the DGMarkedList

  Draw: //*******
  if Assigned(DGChangeItemStateProcObj) then
    DGChangeItemStateProcObj( Self, AInd );
  DGDrawItem( AInd ); // Redraw AInd Item
end; // procedure TN_DGridBase.DGSetItemState

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGMarkSingleItem
//******************************************* TN_DGridBase.DGMarkSingleItem ***
// Mark Single Item
//
//     Parameters
// AInd - given Item one dimensional Index
//
// If AInd >= 0 then Unmark all Items and mark given Item. Set DGSelectedInd 
// equal to AInd.
//
// If AInd = -1 unmark all Items and set DGCurrentIsEmpty to True. DGSelectedInd
// should remains unchanged.
//
procedure TN_DGridBase.DGMarkSingleItem( AInd: integer );
var
  i, CurInd: integer;
begin
  if (AInd <= -2) or (AInd >=DGNumItems) then Exit; // a precaution

  DGSelectItem( AInd );

  for i := 0 to DGMarkedList.Count-1 do // along all Marked Items
  with DGMarkedList do
  begin
    CurInd := Integer(Items[i]);
//    if CurInd = AInd then Continue; // AInd Item will be processed later, after this loop

    DGItemsFlags[CurInd] := DGItemsFlags[CurInd] and N_DGMarkBitMask; // Clear Marked bit for CurInd Item

    DGDrawItem( CurInd ); // Redraw CurInd Item (DGSelectedInd should already have been set!)
  end; // with DGMarkedList do, for i := 0 to DGMarkedList.Count-1 do // along all Marked Items

  DGMarkedList.Clear();

  if AInd >= 0 then // Process AInd Item
  begin
    DGSetItemState( AInd, ssmMark );
    DGScrollToItem( AInd );
  end; // if AInd >= 0 then // Process AInd Item
end; // procedure TN_DGridBase.DGMarkSingleItem

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGMarkItems
//************************************************ TN_DGridBase.DGMarkItems ***
// Mark given Items
//
//     Parameters
// AMarkedList - TList with Items Indexes to Mark
//
// Unmark all Items and Mark Items with Indexes in given AMarkedList
//
procedure TN_DGridBase.DGMarkItems( AMarkedList: TList );
var
  i: integer;
begin
  DGMarkSingleItem( -1 ); // Unmark all Items

  for i := 0 to AMarkedList.Count-1 do
    DGSetItemState( integer(AMarkedList.Items[i]), ssmMark );
end; // procedure TN_DGridBase.DGMarkItems

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGSelectItem
//*********************************************** TN_DGridBase.DGSelectItem ***
// Select given Item
//
//     Parameters
// AInd - given Item Index to Select or -1 to make no Items Selected
//
procedure TN_DGridBase.DGSelectItem( AInd: integer );
begin
  if AInd >= 0 then // some Item Selected
  begin
    DGSelectedInd := AInd;
    DGCurrentIsEmpty := False;
  end else // AInd = -1
    DGCurrentIsEmpty := True;
end; // procedure TN_DGridBase.DGSelectItem

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGDrawRFrame
//*********************************************** TN_DGridBase.DGDrawRFrame ***
// Draw all Items
//
// Draw all Items (whole Grid) in RFrame Buf, using Self DGDrawItem method.
//
// DGDrawRFrame method can be used as TN_Rast1Frame.DrawProcObj method.
//
procedure TN_DGridBase.DGDrawRFrame();
var
  i: integer;
begin
  if not Assigned(DGDrawItemProcObj) then Exit; // a precaution

  for i := 0 to DGNumItems-1 do
    DGDrawItem( i );

  DGRFrame.SkipOnPaint := False; // MainBuf content is OK and can be shown
end; // procedure TN_DGridBase.DGDrawRFrame

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGDrawRFrameRect
//******************************************* TN_DGridBase.DGDrawRFrameRect ***
// Draw all Items, that intersect given ARect in RFrame Buf
//
//     Parameters
// ARect - given Rectangle in Grid Pixel coords
//
// Draw all Items, that intersect given ARect, using Self DGDrawItem method.
//
// Using DGDrawRFrameRect method enables to avoid Drawing Items that are out of 
// RFrame Buf.
//
// DGDrawRFrameRect method can be used as TN_Rast1Frame.DrawProcObj method.
//
procedure TN_DGridBase.DGDrawRFrameRect( ARect: TRect );
begin
  if not Assigned(DGDrawItemProcObj) then Exit; // a precaution
  Assert( False, 'DGDrawRFrameRect is not implemented!' );

{
var
  ix, iy, ixBeg, ixEnd, iyBeg, iyEnd: integer;

  iyBeg := DGGetRowInd( ARect.Top );
  iyEnd := DGGetRowInd( ARect.Bottom );

  for iy := iyBeg to iyEnd do // loop along all Rows that intersect given ARect
  begin
    ixBeg := DGGetColInd( iy, ARect.Left );
    ixEnd := DGGetColInd( iy, ARect.Right );

    for ix := ixBeg to ixEnd do // loop along all Items in iy-th Row that intersect given ARect
    begin
      DGDrawItem( DGGetItemInd( ix, iy ) );
    end; // for ix := 0 to NumColsInRow-1 do // loop along all Items in iy-th Row
  end; // for iy := 0 to DGNumRows-1 do // loop along all Items in Grid

  SkipOnPaint := False; // MainBuf content is OK and can be shown
}
end; // procedure TN_DGridBase.DGDrawRFrameRect

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGDrawItem
//************************************************* TN_DGridBase.DGDrawItem ***
// Draw one Item with needed Marking and Selection
//
//     Parameters
// AInd - given Item Index
//
// Drawing Item with needed Marking and Selection occures in three stages:
//#L
// - Fill Mark Rectangle with DGMarkBordColor (for Marked Items) or with 
//   DGNormBordColor (for Nonmarked Items)
// - Draw Item content using DGDrawItemProcObj
// - Draw Selection Border (analog of Windows Focus Rect) if Item is Selected
//#/L
//
// DGDrawItem method is used in DGDrawRFrame and DGDrawRFrameRect methods.
//
procedure TN_DGridBase.DGDrawItem( AInd: integer );
var
  BordColor, FillColor: integer;
  ItemRect, MarkRect, FillRect, SelectRect: TRect;
begin
  with DGRFrame.OCanv do
  begin
  // DGRFrame.ShowMainBuf(); // Debug

  ItemRect := DGGetItemRect( AInd );

  if not DGSkipMarkBefore then // Draw needed marking before User Drawing Proc of Obj
  begin
    FillRect := Rect( ItemRect.Left-DGMarkNormShift,  ItemRect.Top-DGMarkNormShift,
                      ItemRect.Right+DGMarkNormShift, ItemRect.Bottom+DGMarkNormShift );

    MarkRect := Rect( FillRect.Left-DGMarkNormWidth,  FillRect.Top-DGMarkNormWidth,
                      FillRect.Right+DGMarkNormWidth, FillRect.Bottom+DGMarkNormWidth );

    if (DGItemsFlags[AInd] and N_DGMarkBit) <> 0 then // Marked Item
    begin
      BordColor := DGMarkBordColor;
      FillColor := DGMarkFillColor;
    end else //**************************************** Normal (Not Marked) Item
    begin
      BordColor := DGNormBordColor;
      FillColor := DGNormFillColor;
    end;

    SetBrushAttribs( BordColor );

    if DGMarkByBorder then // Mark by MarkRect Border (BordColor) and FillRect (FillColor)
    begin
      DrawPixRectBorder( MarkRect, DGMarkNormWidth );

      SetBrushAttribs( FillColor );
      DrawPixFilledRect( FillRect );
    end else //************** Mark by Filling whole MarkRect (BordColor), not only it's border
    begin
      DrawPixFilledRect( MarkRect );
    end;

  end; // if not DGSkipMarkBefore then // Draw needed marking before User Drawing Proc of Obj

  DGDrawItemProcObj( Self, AInd, ItemRect ); // User Drawing Proc of Obj
  //  DGRFrame.ShowMainBuf(); // debug

  if not DGSkipSelecting then // do not Skip Special drawing for Selected Item
  begin
    SelectRect := Rect( ItemRect.Left-DGSelectWidth-DGSelectShift,  ItemRect.Top-DGSelectWidth-DGSelectShift,
                        ItemRect.Right+DGSelectWidth+DGSelectShift, ItemRect.Bottom+DGSelectWidth+DGSelectShift );

    if (DGSelectedInd >= 0) and (DGSelectedInd = AInd) then // Mark as Selected Item
    begin
      SetBrushAttribs( DGSelectColor1 );
      DrawPixRectBorder( SelectRect, DGSelectWidth );

      SetBrushAttribs( DGSelectColor2 );
      DrawPixRectDashBorder( SelectRect, DGSelectWidth, DGSelectWidth, 2*DGSelectWidth, 0 );
    end else //********************************************** not Selected Item
    begin
      if DGSkipMarkBefore then // Possible previous Selection should be cleared
      begin
        SetBrushAttribs( DGBackColor );
        DrawPixRectBorder( SelectRect, DGSelectWidth );
      end;
    end; // else // not Selected Item
  end; // if not DGSkipSelecting then // do not Skip Special drawing for Selected Item

  end; // with DGRFrame.OCanv do
end; // procedure TN_DGridBase.DGDrawItem

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGTestDrawItem1
//******************************************** TN_DGridBase.DGTestDrawItem1 ***
// Test Draw one given Item, variant #1
//
//     Parameters
// ADGObj - Self (is needed if it is some other object's method)
// AInd   - given Item one dimensional Index
// ARect  - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper left
//          Buf pixel and may be not equal to upper left Grid pixel )
//
// Fill Item Rectangle by one of two colors ($DDDDDD and $EECCEE) in chess order
// and draw Item one dimensional Index.
//
procedure TN_DGridBase.DGTestDrawItem1( ADGObj: TN_DGridBase; AInd: integer;
                                                           const ARect: TRect );
var
  ColInd, RowInd: integer;
begin
  with DGRFrame.OCanv do
  begin

  DGCalcItemInds( AInd, ColInd, RowInd );

  //***** fill Cell Background by one of two Colors (in Chess Order)
  if ((ColInd + (RowInd and 1)) and 1) = 0 then
    N_DrawFilledRect( HMDC, ARect, $DDDDDD )
  else
    N_DrawFilledRect( HMDC, ARect, $EECCEE );

  //***** Draw Cell content (one dimensional Index)

  DrawPixString( ARect.TopLeft, Format( '%0.2d', [AInd] ) );

  end; // with DGRFrame.OCanv do
end; // procedure TN_DGridBase.DGTestDrawItem1

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGTestDrawItem2
//******************************************** TN_DGridBase.DGTestDrawItem2 ***
// Test Draw one given Item, variant #2
//
//     Parameters
// ADGObj  - Self (is needed if it is some other object's method)
// AInd    - given Item one dimensional Index
// AColInd - given Item Column Index (Index along X Axis)
// ARowInd - given Item Row Index (Index along Y Axis)
// ARect   - Item Rectangle in DGRFrame Buf Pixel coords ( (0,0) means upper 
//           left Buf pixel and may be not equal to upper left Grid pixel )
//
// Fill Item Rectangle by one of two colors ($DDDDDD and $EECCEE) in chess order
// and draw Item Column and Row Indexes, separated by comma.
//
procedure TN_DGridBase.DGTestDrawItem2( ADGObj: TN_DGridBase; AInd: integer;
                                                           const ARect: TRect );
var
  ColInd, RowInd: integer;
begin
  with DGRFrame.OCanv do
  begin

  DGCalcItemInds( AInd, ColInd, RowInd );

  //***** fill Cell Background by one of two Colors
  if ((ColInd + (RowInd and 1)) and 1) = 0 then
    N_DrawFilledRect( HMDC, ARect, $DDDDDD )
  else
    N_DrawFilledRect( HMDC, ARect, $EECCEE );

  //***** Draw (ix,iy) Cell content at (PixX,PixY)

  DrawPixString( ARect.TopLeft, Format( '%0.2d,%0.2d', [ColInd, RowInd] ) );

  end; // with DGRFrame.OCanv do
end; // procedure TN_DGridBase.DGTestDrawItem2

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGResizeRFrame
//********************************************* TN_DGridBase.DGResizeRFrame ***
// On Resize RFrame handler
//
// Reinitialize Self and scroll, trying to preserve upper left Item visible
//
// DGResizeRFrame method should be assigned to TN_Rast1Frame.RFResizeProcObj 
// field.
//
procedure TN_DGridBase.DGResizeRFrame();
var
  TLItemInd, SavedSelInd: integer;
  TLItemPos: TPoint;
  SavedList: TList;
begin
  DGBeginUpdate();

  //***** Get previous (before resize) Top Left Item Index and Position
  TLItemInd := DGGetTopLeftItemInd();
  if TLItemInd >= 0 then // Top Left Item exists
    TLItemPos := DGGetItemPos( TLItemInd ) // Top Left Item Position relative to RFSrcPRect.TopLeft
  else //****************** TLItemInd = -1, no Top Left Item
    TLItemPos := DGRFrame.RFSrcPRect.TopLeft; // Current Upper Left visible Pixel

  //***** Save info about Marked and Slected Items
  SavedList := TList.Create;
  SavedList.Assign( DGMarkedList );
  SavedSelInd := DGSelectedInd;

  DGInitRFrame();

  DGMarkItems( SavedList );
  SavedList.Free;

  DGSelectItem( SavedSelInd );

  // Scroll and Redraw if needed, TLItemInd may be equal to -1
  DGScrollToItemPos( TLItemInd, TLItemPos );

  DGEndUpdate(); // Show MainBuf if needed
end; // procedure TN_DGridBase.DGResizeRFrame

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGBeginUpdate
//********************************************** TN_DGridBase.DGBeginUpdate ***
// Begin updating Items or Layout
//
// If DGUpdateCounter > 0 DGRFrame.ShowMainBuf is not called. Should be used 
// with DGEndUpdate to prevent flicker, caused by multiple Items redrawing.
//
procedure TN_DGridBase.DGBeginUpdate();
begin
  Inc( DGUpdateCounter );
end; // procedure TN_DGridBase.DGBeginUpdate

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGEndUpdate
//************************************************ TN_DGridBase.DGEndUpdate ***
// End updating Items or Layout
//
// Decrement DGUpdateCounter and call DGRFrame.ShowMainBuf if DGUpdateCounter = 
// 0.
//
// If DGUpdateCounter > 0 DGRFrame.ShowMainBuf is not called. Should be used 
// with DGBeginUpdate to prevent flicker, caused by multiple Items redrawing.
//
procedure TN_DGridBase.DGEndUpdate();
begin
  if DGUpdateCounter > 0 then
    Dec( DGUpdateCounter );

  if DGUpdateCounter = 0 then DGRFrame.ShowMainBuf();
end; // procedure TN_DGridBase.DGEndUpdate

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGSetAllItemsState
//***************************************** TN_DGridBase.DGSetAllItemsState ***
// Set All Items State by given AState
//
//     Parameters
// AState - needed Items State
//
procedure TN_DGridBase.DGSetAllItemsState( AState: TN_SetStateMode );
var
  i: integer;
begin
  DGBeginUpdate();

  if AState = ssmMark then // first unmark all for proper Marked Items order
    DGMarkSingleItem( -1 );

  for i := 0 to DGNumItems-1 do
    DGSetItemState( i, AState );

  DGEndUpdate();
end; // procedure TN_DGridBase.DGSetAllItemsState

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGGetSelection
//********************************************* TN_DGridBase.DGGetSelection ***
// Get Items Selection info
//
//     Parameters
// AInds - resulting array of integers
//
// AInds[0] contains Selected Item Index, all other elements - marked Items 
// Indexes
//
procedure TN_DGridBase.DGGetSelection( var AInds: TN_IArray );
var
  i, NumMarked: integer;
begin
  NumMarked := DGMarkedList.Count;
  SetLength( AInds, NumMarked+1 );
  AInds[0] := DGSelectedInd;

  for i := 1 to NumMarked do
    AInds[i] := Integer(DGMarkedList[i-1]);

end; // procedure TN_DGridBase.DGGetSelection

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBase\DGSetSelection
//********************************************* TN_DGridBase.DGSetSelection ***
// Set Items Selection info (previously obtained by DGGetSelection)
//
//     Parameters
// AInds - resulting array of integers
//
// AInds[0] contains Selected Item Index, all other elements - marked Items 
// Indexes
//
procedure TN_DGridBase.DGSetSelection( AInds: TN_IArray );
var
  i: integer;
begin
  DGBeginUpdate();
  DGMarkSingleItem( -1 ); // Unmark all Items

  for i := 1 to High(AInds) do
    DGSetItemState( AInds[i], ssmMark );

  DGSelectItem( AInds[0] );
  DGEndUpdate();
end; // procedure TN_DGridBase.DGSetSelection


//********** TN_DGridBaseMatr class Public methods  **************

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatr\Create
//************************************************* TN_DGridBaseMatr.Create ***
// TN_DGridBaseBase constructor
//
//     Parameters
// ARFrame - TN_Rast1Frame in which DGrid should be shown
//
constructor TN_DGridBaseMatr.Create( ARFrame: TN_Rast1Frame );
var
  ZeroGroup: TN_SGBase;
begin
  inherited;

  ZeroGroup := TN_SGBase(DGRFrame.RFSGroups[0]);
  DGBaseMatrRFA := TN_DGridBaseMatrRFA(ZeroGroup.SetAction( N_ActDGridRFA, $00 ));
  DGBaseMatrRFA.RFADGrid := Self;

  DGLItemsByRows := True;
end; // constructor TN_DGridBaseMatr.Create

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatr\DGInitRFrame
//******************************************* TN_DGridBaseMatr.DGInitRFrame ***
// Layout Grid Elements and Initialize DGRFrame
//
procedure TN_DGridBaseMatr.DGInitRFrame();
begin
  DGBaseMatrRFA.ActExtExecProcObj := DGExtExecProcObj;
end; // procedure TN_DGridBaseMatr.DGInitRFrame

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatr\DGGetItemInd
//******************************************* TN_DGridBaseMatr.DGGetItemInd ***
// Get Item Index by it's Column and Row Indexes
//
//     Parameters
// AColInd - given Item Column Index (Index along X Axis)
// ARowInd - given Item Row Index (Index along Y Axis)
// Result  - Returns one dimensional Item index by it's Column and Row Indexes
//
function TN_DGridBaseMatr.DGGetItemInd( AColInd, ARowInd: integer ): integer;
begin
  Result := -1;
  if (AColInd < 0) or (ARowInd < 0) then Exit; // cannot be defined

  if DGLItemsByRows then
    Result := ARowInd*DGNumCols + AColInd
  else // Items by Columns Layout
    Result := AColInd*DGNumRows + ARowInd;

  if Result >= DGNumItems then // no such Item
    Result := -1;
end; // function TN_DGridBaseMatr.DGGetItemInd

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatr\DGCalcItemInds
//***************************************** TN_DGridBaseMatr.DGCalcItemInds ***
// Calculate Item Column and Row Indexes by it's one dimensional index
//
//     Parameters
// AInd    - given Item one dimensional Index
// AColInd - on output, resulting Item Column Index (Index along X Axis)
// ARowInd - on output, resulting Item Row Index (Index along Y Axis)
//
procedure TN_DGridBaseMatr.DGCalcItemInds( AInd: integer; out AColInd, ARowInd: integer );
begin
  AColInd := -1;
  ARowInd := -1;
  if (AInd < 0) or (AInd >= DGNumItems) or (DGNumCols = 0) or (DGNumRows = 0) then Exit;

  if DGLItemsByRows then
  begin
    ARowInd := AInd div DGNumCols;
    AColInd := AInd mod DGNumCols;
  end else // Items by Columns Layout
  begin
    AColInd := AInd div DGNumRows;
    ARowInd := AInd mod DGNumRows;
  end;
end; // procedure TN_DGridBaseMatr.DGCalcItemInds

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatr\DGGetMaxRowInd
//***************************************** TN_DGridBaseMatr.DGGetMaxRowInd ***
// Get max Item Row Index in a given Column
//
//     Parameters
// AColInd - given Column Index in which max Item Row Index should be calculated
// Result  - Returns max Item Row Index in a given Column
//
// Return -1 if there are no Items in given Column.
//
function TN_DGridBaseMatr.DGGetMaxRowInd( AColInd: integer ): integer;
var
  LIColInd, LIRowInd: integer;
begin
  Result := -1;
  if (AColInd < 0) or (AColInd >= DGNumCols) then Exit; // no such a Column

  DGCalcItemInds( DGNumItems-1, LIColInd, LIRowInd ); // Last Item inds

  if AColInd < LIColInd then // Columns before Last Item Column
    Result := DGNumRows - 1
  else if AColInd = LIColInd then // Column with Last Item
    Result := LIRowInd
  else // AColInd > LIColInd, DGLItemsByRows=True, Columns after Last Item Column
    Result := DGNumRows - 2;

end; // procedure TN_DGridBaseMatr.DGGetMaxRowInd

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatr\DGGetMaxColInd
//***************************************** TN_DGridBaseMatr.DGGetMaxColInd ***
// Get max Item Column Index in a given Row
//
//     Parameters
// ARowInd - given Row Index in which max Item Column Index should be calculated
// Result  - Returns max Item Column Index in a given Row
//
// Return -1 if there are no Items in given Row.
//
function TN_DGridBaseMatr.DGGetMaxColInd( ARowInd: integer ): integer;
var
  LIColInd, LIRowInd: integer;
begin
  Result := -1;
  if (ARowInd < 0) or (ARowInd >= DGNumRows) then Exit; // no such a Row

  DGCalcItemInds( DGNumItems-1, LIColInd, LIRowInd ); // Last Item inds

  if ARowInd < LIRowInd then // Rows before Last Item Row
    Result := DGNumCols - 1
  else if ARowInd = LIRowInd then // Row with Last Item
    Result := LIColInd
  else // ARowInd > LIRowInd, DGLItemsByRows=False, Rows after Last Item Row
    Result := DGNumCols - 2;

end; // procedure TN_DGridBaseMatr.DGGetMaxColInd

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatr\DGGetItemByPoint
//*************************************** TN_DGridBaseMatr.DGGetItemByPoint ***
// Get Item Indexes by given APoint
//
//     Parameters
// APoint       - given Point in Grid Pixel coords ( (0,0) means upper left Grid
//                pixel )
// AColInd      - resulting Item Column Index
// ARowInd      - resulting Item Row Index
// AItemInd     - resulting Item Index that covers given APoint or -1
// AColIndType  - resulting Item Column Index Type
// ARowIndType  - resulting Item Row Index Type
// AItemIndType - resulting Item Index Type (only dgitInside or dgitNotDef)
//
procedure TN_DGridBaseMatr.DGGetItemByPoint( APoint: TPoint;
                                         out AColInd, ARowInd, AItemInd: integer;
                      out AColIndType, ARowIndType, AItemIndType: TN_DGIndexType );
begin
  AColInd  := DGGetColInd( APoint.X, AColIndType );
  ARowInd  := DGGetRowInd( APoint.Y, ARowIndType );
  AItemInd := DGGetItemInd( AColInd, ARowInd );

  if AColIndType = ARowIndType then
      AItemIndType := AColIndType
  else // AColIndType <> ARowIndType
    if (AColIndType = dgitAfter) or (ARowIndType = dgitAfter) then //
      AItemIndType := dgitAfter
    else
      AItemIndType := dgitBefore;
end; // procedure TN_DGridBaseMatr.DGGetItemInds

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatr\DGInitArrays
//******************************************* TN_DGridBaseMatr.DGInitArrays ***
// Init DGIndsInRows, DGIndsInCols and DGItemsRects Arrays using DGColsPos and 
// DGRowsPos Arrays
//
procedure TN_DGridBaseMatr.DGInitArrays();
var
  i, LastColInd, LastRowInd, ColInd, RowInd: integer;
begin
  // Get Last Grid Item Column and Row Indexes
  DGCalcItemInds( DGNumItems-1, LastColInd, LastRowInd );

  SetLength( DGIndsInCols, DGNumCols );

  for i := 0 to DGNumCols-1 do // along all Columns
  begin
    if DGLItemsByRows then // Items by Rows Layout
    begin
      DGIndsInCols[i].X := i;

      if i <= LastColInd then // not after Column with Last Grid Item
        DGIndsInCols[i].Y := i + (DGNumRows-1)*DGNumCols
      else //********************* after Column with Last Grid Item
        DGIndsInCols[i].Y := i + (DGNumRows-2)*DGNumCols;
    end else //************** Items by Columns Layout
    begin
      DGIndsInCols[i].X := i*DGNumRows;

      if i = (DGNumCols-1) then // Last Column
        DGIndsInCols[i].Y := DGIndsInCols[i].X + LastRowInd
      else // not Last Column
        DGIndsInCols[i].Y := DGIndsInCols[i].X + DGNumRows - 1;
    end; // else // Items by Columns Layout
  end; // for i := 0 to DGNumCols-1 do // along all Columns

  SetLength( DGIndsInRows, DGNumRows );

  for i := 0 to DGNumRows-1 do // along all Rows
  begin
    if DGLItemsByRows then // Items by Rows Layout
    begin
      DGIndsInRows[i].X := i*DGNumCols;

      if i = (DGNumRows-1) then // Last Row
        DGIndsInRows[i].Y := DGIndsInRows[i].X + LastColInd
      else // not Last Row
        DGIndsInRows[i].Y := DGIndsInRows[i].X + DGNumCols - 1;
    end else //************** Items by Columns Layout
    begin
      DGIndsInRows[i].X := i;

      if i <= LastRowInd then // not after Row with Last Grid Item
        DGIndsInRows[i].Y := i + (DGNumCols-1)*DGNumRows
      else //********************* after Row with Last Grid Item
        DGIndsInRows[i].Y := i + (DGNumCols-2)*DGNumRows;
    end; // else // Items by Columns Layout
  end; // for i := 0 to DGNumRows-1 do // along all Rows

  SetLength( DGItemsRects, DGNumItems );

  for i := 0 to DGNumItems-1 do // along all Items
  with DGItemsRects[i] do
  begin
    DGCalcItemInds( i, ColInd, RowInd );

    Left   := DGColsPos[ColInd].X;
    Right  := DGColsPos[ColInd].Y;
    Top    := DGRowsPos[RowInd].X;
    Bottom := DGRowsPos[RowInd].Y;
  end; // for i := 0 to DGNumItems-1 do // along all Items

end; // procedure TN_DGridBaseMatr.DGInitArrays


//****************  TN_DGridBaseMatrRFA class methods  *****************

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatrRFA\SetActParams
//**************************************** TN_DGridBaseMatrRFA.SetActParams ***
// Set some Self fields
//
// Set ActName field, used mainly for debugging
//
procedure TN_DGridBaseMatrRFA.SetActParams();
begin
  ActName := 'DGridRFA';
  inherited;
end; // procedure TN_DGridBaseMatrRFA.SetActParams();

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatrRFA\Execute
//********************************************* TN_DGridBaseMatrRFA.Execute ***
// Action Mouse and Keyboard Event handler
//
procedure TN_DGridBaseMatrRFA.Execute();
var
  i, NewItemInd, SelColInd, SelRowInd, NewColInd, NewRowInd: integer;
  MinInd, MaxInd, MaxRowInd, MaxColInd: integer;
  CurGridPos: TPoint;
  SetStyleAction: TN_SetStateMode;
  CtrlMode: boolean;
  NewIsMarked: boolean;
  ColIndType, RowIndType, ItemIndType: TN_DGIndexType;
  label SelectNewItem;
begin
  NewItemInd := 0; // to avoid warning
 //    Inc(N_i2); N_IAdd( Format( '*** Form DGridBaseMatrRFA: %d', [N_i2] ) ); // debug

  with RFADGrid, ActGroup.RFrame do
  begin

  DGBeginUpdate();

  if (CHType = htMouseDown) then //****************************** MouseDown
//    or (CHType = htMouseUp)  then //*** ???
  begin                        // choose Item under cursor
    CurGridPos.X := CCBuf.X - RFLogFramePRect.Left; // Cursor pos in Grid Pixel coords
    CurGridPos.Y := CCBuf.Y - RFLogFramePRect.Top;

    DGGetItemByPoint( CurGridPos, NewColInd, NewRowInd, NewItemInd,
                                  ColIndType, RowIndType, ItemIndType );

    if (ssRight in CMKShift) and    // Right Mouse Click should not chage current marking
       (NewItemInd >= 0)       then // if clicked on already marked Item
    begin
      if (DGItemsFlags[NewItemInd] and N_DGMarkBit) <> 0 then // clicked on already marked Item
      begin
        DGEndUpdate();
        Exit;
      end; // if ... // clicked on already marked Item
    end; // if (ssRight in CMKShift) ...

    if ItemIndType <> dgitInside then // clik out of any Items
      NewItemInd := -1;

    goto SelectNewItem;
  end; // if CHType = htMouseDown then //********************** MouseDown

  if CHType = htKeyDown then // Process Keyboard Event (called from WMKeyDown or WMKeyUp)
  begin

    if CKey.CharCode = VK_HOME then //************************* Home Key
    begin
      NewItemInd := 0;
      goto SelectNewItem;
    end; // if CKey.CharCode = VK_HOME then //***************** Home Key

    if CKey.CharCode = VK_END then //************************** End Key
    begin
      NewItemInd := DGNumItems - 1;
      goto SelectNewItem;
    end; // if CKey.CharCode = VK_END then  //***************** End Key

    //*** For calculating NewItemInd by all navigating Keys except VK_HOME, VK_END
    //    DGSelectedInd is needed

    if DGSelectedInd = -1 then // DGSelectedInd is not defined
    begin
      DGEndUpdate();
      Exit;
    end; // if CKey.CharCode = VK_HOME then //***************** Home Key

    DGCalcItemInds( DGSelectedInd, SelColInd, SelRowInd );
    MaxRowInd := DGGetMaxRowInd( SelColInd );
    MaxColInd := DGGetMaxColInd( SelRowInd );

    if CKey.CharCode = VK_LEFT then //************************* Left Arrow Key
    begin
      if DGSelectedInd = 0 then Exit; // Do not change anything

      if SelColInd = 0 then //*** Leftmoust Column
      begin
        if DGLItemsByRows and DGChangeRCbyAK then // Changing Rows Columns by Arrow Keys is alowed
          NewItemInd := DGGetItemInd( DGNumCols-1, SelRowInd-1 ) // last(rightmoust) Item in prev. Row
        else // Changig Row Column is not allowed
          Exit;
      end else //**************** SelColInd >= 1
        NewItemInd := DGGetItemInd( SelColInd-1, SelRowInd ); // prev. Item in cur Row

      goto SelectNewItem;
    end; // if CKey.CharCode = VK_LEFT then //***************** Left Arrow Key

    if CKey.CharCode = VK_RIGHT then //************************ Right Arrow Key
    begin
      if DGSelectedInd = (DGNumItems-1) then Exit; // Do not change anything

      if SelColInd = MaxColInd then //*** Rightmoust Column
      begin
        if DGLItemsByRows and DGChangeRCbyAK then // Changing Rows Columns by Arrow Keys is alowed
          NewItemInd := DGGetItemInd( 0, SelRowInd+1 ) // first(leftmoust) Item in next Row
        else // Changig Row Column is not allowed
          Exit;
      end else //**************** SelColInd < MaxColInd
        NewItemInd := DGGetItemInd( SelColInd+1, SelRowInd ); // next Item in cur Row

      goto SelectNewItem;
    end; // if CKey.CharCode = VK_RIGHT then //**************** Right Arrow Key

    if CKey.CharCode = VK_UP then //*************************** Up Arrow Key
    begin
      if DGSelectedInd = 0 then Exit; // Do not change anything

      if SelRowInd = 0 then //*** Upper Row
      begin
        if (not DGLItemsByRows) and DGChangeRCbyAK then // Changing Rows Columns by Arrow Keys is alowed
          NewItemInd := DGGetItemInd( SelColInd-1, DGNumRows-1 ) // last(lowest) Item in prev. Column
        else // Changig Row Column is not allowed
          Exit;
      end else //**************** SelRowInd >= 1
        NewItemInd := DGGetItemInd( SelColInd, SelRowInd-1 ); // prev. Item in cur Column

      goto SelectNewItem;
    end; // if CKey.CharCode = VK_UP then //******************* Up Arrow Key

    if CKey.CharCode = VK_DOWN then //************************* Down Arrow Key
    begin
      if DGSelectedInd = (DGNumItems-1) then Exit; // Do not change anything

      if SelRowInd = MaxRowInd then //*** Lowest Row
      begin
        if (not DGLItemsByRows) and DGChangeRCbyAK then // Changing Rows Columns by Arrow Keys is alowed
          NewItemInd := DGGetItemInd( SelColInd+1, 0 ) // first (upper) Item in next Column
        else // Changig Row Column is not allowed
          Exit;
      end else //**************** SelRowInd < MaxRowInd
        NewItemInd := DGGetItemInd( SelColInd, SelRowInd+1 ); // next Item in cur Column

      goto SelectNewItem;
    end; // if CKey.CharCode = VK_DOWN then //***************** Down Arrow Key

    if CKey.CharCode = VK_PRIOR then //************************ Page Up Key
    begin
      //*** not implemented
    end; // if CKey.CharCode = VK_PRIOR then //**************** Page Up Key

    if CKey.CharCode = VK_NEXT then //************************* Page Down Key
    begin
      //*** not implemented
    end; // if CKey.CharCode = VK_NEXT then //***************** Page Down Key

  end; // if CHType = htKeyDown then // Process Keyboard Event

  DGEndUpdate();
  Exit;

  SelectNewItem: //***** DGSelectedInd - prev. selected, NewItemInd - new selected

  if DGSelectedInd = -1 then // No Selected Item
  begin
    DGSelectedInd := NewItemInd; // is needed if Shift key is down
  end; // if DGSelectedInd = -1 then // No Selected Item

  if CHType = htKeyDown then
    CtrlMode := (ssCtrl in CMKShift)
  else
    CtrlMode := (ssCtrl in CMKShift) or DGCtrlDownMode;

  if NewItemInd >= 0 then // Some Item was choosen (by Mouse or Keyboard)
  begin
    DGCurrentIsEmpty := False;

    //***** Prepare for processing New Selected Item

    MinInd := min( DGShiftAnchorInd, NewItemInd );
    MaxInd := max( DGShiftAnchorInd, NewItemInd );

    DGSelectedInd := NewItemInd;

    if not (ssShift in CMKShift) then // Update DGShiftAnchorInd is Shift in not pressed
      DGShiftAnchorInd := NewItemInd;

    if DGToggleOnShift or (CHType = htKeyDown) then
      SetStyleAction := ssmToggleMark
    else
      SetStyleAction := ssmMark;


    if (not DGMultiMarking) or // DGMultiMarking=False, only one Item can be marked
       (not (ssShift in CMKShift)) and (not CtrlMode) then //****** Both Shift, Ctrl are Up
    begin //*** clear all Items, Mark and Select NewItemInd

      DGMarkSingleItem( NewItemInd );

    end else if (not (ssShift in CMKShift)) and CtrlMode then //*** Shift is Up, Ctrl is Down
    begin //*** toggle NewItemInd Marking state

      NewIsMarked := (DGItemsFlags[NewItemInd] and N_DGMarkBit) <> 0;
      if (CHType = htMouseDown) then
      begin
        if (not NewIsMarked) or (ssRight in CMKShift) then
          RFALastMarked := NewItemInd
        else
          RFALastMarked := -1;
      end;
      N_Dump1Str( Format( 'OnExec 1 NewIsMarked=%1x, RFALastMarked=%d', [integer(NewIsMarked),RFALastMarked] ));

      if (ssRight in CMKShift) or (ssDouble in CMKShift) or
         (not NewIsMarked and (CHType = htMouseDown)) then
        DGSetItemState( NewItemInd, ssmMark )
      else if (CHType <> htMouseUp) or (RFALastMarked <> NewItemInd) then
        DGSetItemState( NewItemInd, ssmToggleMark );


    end else if (ssShift in CMKShift) and (not CtrlMode) then //*** Shift is Dowm, Ctrl is Up
    begin //*** Mark or Toggle Items from DGSelectedInd to NewItemInd, Unmark all other items

      for i := 0 to DGNumItems-1 do // along all Items
      begin
        if (MinInd <= i) and (i <= MaxInd) then // Mark or Toggle i-th item
          DGSetItemState( i, SetStyleAction )
        else // i is not in [DGSelectedInd,NewItemInd] Range, Unmark i-th Item
          DGSetItemState( i, ssmUnmark );
      end; // for i := 0 to DGNumItems-1 do // along all Items

    end else //**************************************************** Both Shift, Ctrl are Down
    begin //*** Mark or Toggle Items from DGSelectedInd to NewItemInd, all other items remains unchanged

      for i := MinInd to MaxInd do // along all Items in [DGSelectedInd,NewItemInd] Range
        DGSetItemState( i, SetStyleAction ); // Mark or Toggle i-th item

    end; // end else Both Shift, Ctrl are Down

    DGScrollToItem( NewItemInd );

  end else // NewItemInd = -1, Clear all Marking, DGSelectedInd remains the same
  begin
    DGCurrentIsEmpty := True;

    if not CtrlMode then
      DGMarkSingleItem( -1 );
  end;

  DGEndUpdate();
  end; // with RFADGrid, ActGroup.RFrame do
end; // procedure TN_DGridBaseMatrRFA.Execute

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridBaseMatrRFA\RedrawAction
//**************************************** TN_DGridBaseMatrRFA.RedrawAction ***
// Redraw Temporary Action objects (should be called from RFrame.RedrawAll )
//
procedure TN_DGridBaseMatrRFA.RedrawAction();
begin
{
  with N_ActiveRFrame do
  begin
    OCanv.SetBrushAttribs( -1 );
    OCanv.SetPenAttribs( $999999, 1 );
//    OCanv.DrawUserRect( SRSelectionFRect );
    N_TestRectDraw( OCanv, 10, 20, $FF );
  end; // with N_ActiveRFrame, SRCMREdit2Form do
}
end; // procedure TN_DGridBaseMatrRFA.RedrawAction


//********** TN_DGridUniMatr class Public methods  **************

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridUniMatr\Create
//************************************************** TN_DGridUniMatr.Create ***
// TN_DGridUniMatr constructor
//
//     Parameters
// ARFrame - TN_Rast1Frame in which DGrid should be shown
//
constructor TN_DGridUniMatr.Create( ARFrame: TN_Rast1Frame );
begin
  inherited;

  DGLItemsAspect := 1;
end; // constructor TN_DGridUniMatr.Create

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridUniMatr\DGInitRFrame
//******************************************** TN_DGridUniMatr.DGInitRFrame ***
// Layout Grid Elements and Initialize DGRFrame
//
// Layout scheme: if DGLFixNumCols=0 and DGLFixNumRows=0 then use given 
// DGItemsSize and no more than one ScrollBar
//
// if DGLFixNumCols=0 and DGLFixNumRows>0 then Items Size depend upon FRame
// Height
//
// if DGLFixNumCols>0 and DGLFixNumRows=0 then Items Size depend upon FRame
// Width
//
// if DGLFixNumCols>0 and DGLFixNumRows>0 then just use given DGLFixNumRows,
// DGLFixNumCols, DGItemsSize.Y+DGLAddDySize, DGItemsSize.X
//
procedure TN_DGridUniMatr.DGInitRFrame();
var
  i, GridHeight, GridWidth, FreeSpace, BSize: integer;
  FullSize: TPoint;
  Label Fin;
begin
  inherited;

  with DGRFrame do
  begin

  DGNumRows := 0;
  DGNumCols := 0;

  SetLength( DGItemsFlags, DGNumItems );
  SetLength( DGItemsRects, DGNumItems );

  for i := 0 to DGNumItems-1 do // clear all Itmes Flags
    DGItemsFlags[i] := 0;

  DGMarkedList.Clear;
  BSize := DGMarkNormWidth + DGMarkNormShift; // "Borders" Size (to reduce code size)

  N_Dump2Str( Format( 'DGInitRFrame1 %d %d', [DGLFixNumCols,DGLFixNumRows] ) );

  if DGNumItems = 0 then goto Fin; // Self is not initialized yet

  if (DGLFixNumCols = 0) and (DGLFixNumRows = 0) then //********************
  begin // use DGItemsSize, no more than one ScrollBar

    if DGLItemsByRows then // Items by Rows Layout, no Horizontal ScrollBar,
    begin                  // DGNumCols = Number of fully visible items in Row

      // Try first without Vertical ScrollBar (as if whole Grid is visible)

      FreeSpace := ClientWidth - DGEdges.Left - DGEdges.Right; // Free Horizontal Space for Items

      DGNumCols := FreeSpace div (DGItemsSize.X + DGGaps.X + 2*BSize); // preliminary value

      // Check if only last Gap is not visible, but Item itself (with borders) is visible
      if (FreeSpace mod (DGItemsSize.X + DGGaps.X + 2*BSize)) >= (DGItemsSize.X + 2*BSize) then
        Inc( DGNumCols );

      DGNumRows := (DGNumItems+DGNumCols-1) div DGNumCols;
      FullSize.Y := DGEdges.Top + (DGItemsSize.Y + 2*BSize)*DGNumRows +
                    DGGaps.Y*(DGNumRows-1) + DGEdges.Bottom;

      if FullSize.Y > ClientHeight then // Vertical ScrollBar is needed
      begin
        FreeSpace := FreeSpace - VScrollBar.Width; // Free Horizontal Space for Items
        DGNumCols := FreeSpace div (DGItemsSize.X + DGGaps.X + 2*BSize); // preliminary value

        // Check if only last Gap is not visible, but Item itself (with borders) is visible
        if (FreeSpace mod (DGItemsSize.X + DGGaps.X + 2*BSize)) >= (DGItemsSize.X + 2*BSize) then
          Inc( DGNumCols );

        DGNumRows := (DGNumItems+DGNumCols-1) div DGNumCols;
      end; // if FullSize.Y > ClientHeight then // Vertical ScrollBar is needed

    end else //************** Items by Columns Layout, no Vertical ScrollBar
    begin    //               DGNumRows = Number of fully visible items in Column

      // Try first without Horizontal ScrollBar (as if whole Grid is visible)

      FreeSpace := ClientHeight - DGEdges.Top - DGEdges.Bottom; // Free Vertical Space for Items

      DGNumRows := FreeSpace div (DGItemsSize.Y + DGGaps.Y + 2*BSize); // preliminary value

      // Check if only last Gap is not visible, but Item itself (with borders) is visible
      if (FreeSpace mod (DGItemsSize.Y + DGGaps.Y + 2*BSize)) >= (DGItemsSize.Y + 2*BSize) then
        Inc( DGNumRows );

      DGNumCols := (DGNumItems+DGNumRows-1) div DGNumRows;
      FullSize.X := DGEdges.Left  + (DGItemsSize.X + 2*BSize)*DGNumCols + DGGaps.X*(DGNumCols-1) + DGEdges.Right;

      if FullSize.X > ClientWidth then // Horizontal ScrollBar is needed
      begin
        FreeSpace := FreeSpace - HScrollBar.Height; // Free Vertical Space for Items
        DGNumRows := FreeSpace div (DGItemsSize.Y + DGGaps.Y + 2*BSize); // preliminary value

        // Check if only last Gap is not visible, but Item itself (with borders) is visible
        if (FreeSpace mod (DGItemsSize.Y + DGGaps.Y + 2*BSize)) >= (DGItemsSize.Y + 2*BSize) then
          Inc( DGNumRows );

        DGNumCols := (DGNumItems+DGNumRows-1) div DGNumRows;
      end; // if FullSize.X > ClientWidth then // Horizontal ScrollBar is needed

    end; // else //************** Items by Columns Layout

  end else if (DGLFixNumCols = 0) and (DGLFixNumRows > 0) then //***********
  begin // set DGNumRows = DGLFixNumRows, all of them should be visible (no Vertical ScrollBar)
        // Items Height is calculated by RFrame.Height,
        // DGLItemsByRows is set to False

    DGNumRows := DGLFixNumRows;
    DGNumCols := (DGNumItems+DGNumRows-1) div DGNumRows;
    DGLItemsByRows := False; // Items are ordered by Columns

    // Try first without Horizontal ScrollBar (as if whole Grid is visible)
    GridHeight := ClientHeight - DGEdges.Top - DGEdges.Bottom;
    DGItemsSize.Y := (GridHeight - (DGNumRows-1)*DGGaps.Y) div DGNumRows - 2*BSize;
    DGItemsSize.X := Round( (DGItemsSize.Y - DGLAddDySize) / DGLItemsAspect ) - 2*BSize;

    FullSize.X := DGEdges.Left  + (DGItemsSize.X+2*BSize)*DGNumCols + DGGaps.X*(DGNumCols-1) + DGEdges.Right;

    if FullSize.X > ClientWidth then // Horizontal ScrollBar is needed
    begin
      GridHeight := GridHeight - HScrollBar.Height;
      DGItemsSize.Y := (GridHeight - (DGNumRows-1)*DGGaps.Y) div DGNumRows - 2*BSize;
      DGItemsSize.X := Round( (DGItemsSize.Y - DGLAddDySize) / DGLItemsAspect ) - 2*BSize;
    end; // if FullSize.X > ClientWidth then // Horizontal ScrollBar is needed

  end else if (DGLFixNumCols > 0) and (DGLFixNumRows = 0) then //***********
  begin // DGNumCols = DGLFixNumCols, all of them should be visible (no Horizontal ScrollBar)
        // Items Width is calculated by RFrame.Width-VertScrollBar.Width
        // DGLItemsByRows is set to True

    DGNumCols := DGLFixNumCols;
    DGNumRows := (DGNumItems+DGNumCols-1) div DGNumCols;
    DGLItemsByRows := True; // Items are ordered by Rows

    // Try first without Vertical ScrollBar (as if whole Grid is visible)
    GridWidth := ClientWidth - DGEdges.Left - DGEdges.Right;
    DGItemsSize.X := (GridWidth - (DGNumCols-1)*DGGaps.X) div DGNumCols - 2*BSize;
    DGItemsSize.Y := Round( DGItemsSize.X*DGLItemsAspect + DGLAddDySize ) - 2*BSize;

    FullSize.Y := DGEdges.Top  + (DGItemsSize.Y+2*BSize)*DGNumRows + DGGaps.Y*(DGNumRows-1) + DGEdges.Bottom;

    if FullSize.Y > ClientHeight then // Vertical ScrollBar is needed
    begin
      GridWidth := GridWidth - VScrollBar.Width;
      DGItemsSize.X := (GridWidth - (DGNumCols-1)*DGGaps.X) div DGNumCols - 2*BSize;
      DGItemsSize.Y := Round( DGItemsSize.X*DGLItemsAspect + DGLAddDySize ) - 2*BSize;
    end; // if FullSize.Y > ClientHeight then // Vertical ScrollBar is needed

  end else if (DGLFixNumCols > 0) and (DGLFixNumRows > 0) then //***********
  begin // set DGNumRows := DGLFixNumRows, DGNumCols := DGLFixNumCols,
        // use DGItemsSize, RFrame Size does not matter
    DGNumRows := DGLFixNumRows;
    DGNumCols := DGLFixNumCols;
  end; // end else if (DGLFixNumCols > 0) and (DGLFixNumRows > 0)

  FullSize.X := DGEdges.Left  + (DGItemsSize.X + 2*BSize)*DGNumCols + DGGaps.X*(DGNumCols-1) + DGEdges.Right;
  FullSize.Y := DGEdges.Top   + (DGItemsSize.Y + 2*BSize)*DGNumRows + DGGaps.Y*(DGNumRows-1) + DGEdges.Bottom;

  //***** Fill DGColsPos and DGRowsPos Arrays

  SetLength( DGColsPos, DGNumCols );
  for i := 0 to DGNumCols-1 do // along all Columns
  begin
    DGColsPos[i].X := DGEdges.Left + BSize + (DGItemsSize.X + DGGaps.X + 2*BSize)*i;
    DGColsPos[i].Y := DGColsPos[i].X + DGItemsSize.X - 1;
  end; // for i := 0 to DGNumCols-1 do // along all Columns

  SetLength( DGRowsPos, DGNumRows );
  for i := 0 to DGNumRows-1 do // along all Rows
  begin
    DGRowsPos[i].X := DGEdges.Top + BSize + (DGItemsSize.Y + DGGaps.Y + 2*BSize)*i;
    DGRowsPos[i].Y := DGRowsPos[i].X + DGItemsSize.Y - 1;
  end; // for i := 0 to DGNumRows-1 do // along all Rows

  DGInitArrays(); // Init other Arrays (DGIndsInRows, DGIndsInCols and DGItemsRects)

  Fin: //***** Prepare OCanv, Redraw All and Show MainBuf if needed

  if (DGNumCols <= 0) or (DGNumRows <= 0) then
    RFObjSize := Point( 1, 1 ) // Value (0,0) causes that SetCurCRectSize do nothing and OCanv remains the same
  else // DGNumCols >= 1 and DGNumRows >= 1
    RFObjSize := FullSize;

  OCanv.SetCurCRectSize( RFObjSize.X, RFObjSize.Y );
  RFLogFramePRect := IRect( RFObjSize );
  RecalcPRects();

  OCanvBackColor := DGBackColor;
  DstBackColor   := DGBackColor;

  //***** Later, for optimization, Redrawing may be postponed after all Items
  //      would have final state
  RedrawAll();

  if DGUpdateCounter = 0 then ShowMainBuf();

  end; // with DGRFrame do
end; // procedure TN_DGridUniMatr.DGInitRFrame

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridUniMatr\DGGetRowInd
//********************************************* TN_DGridUniMatr.DGGetRowInd ***
// Get Grid Row Index by given Y coordinate
//
//     Parameters
// APixY    - given Y coordinate in Grid Pixel coords
// AIndType - resulting Row Index type
// Result   - Returns Row Index which intersect Y=APixY line, is before or after
//            this line.
//
function TN_DGridUniMatr.DGGetRowInd( APixY: integer;
                                   out AIndType: TN_DGIndexType ): integer;
var
  y, iy, dy, BSize: integer;
begin
  BSize := DGMarkNormWidth + DGMarkNormShift; // "Borders" Size (to reduce code size)

  y := APixY - DGEdges.Top - BSize;
  Result := 0;
  AIndType := dgitBefore;
  if y < 0 then Exit; // before first Row

  dy := DGItemsSize.Y + DGGaps.Y + 2*BSize;
  iy := y div dy;
  y  := y - iy*dy;

  Result := iy;

  if y >= DGItemsSize.Y then // between iy-th and (iy+1)-th Row
    Inc( Result )
  else //********************** inside iy-th Row
    AIndType := dgitInside;

end; // function TN_DGridUniMatr.DGGetRowInd

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridUniMatr\DGGetColInd
//********************************************* TN_DGridUniMatr.DGGetColInd ***
// Get Grid Column Index by given X coordinate
//
//     Parameters
// APixX    - given X coordinate in Grid Pixel coords
// AIndType - resulting Column Index type
// Result   - Returns Column Index which intersect X=APixX line, is before or 
//            after this line.
//
function TN_DGridUniMatr.DGGetColInd( APixX: integer;
                                   out AIndType: TN_DGIndexType ): integer;
var
  x, ix, dx, BSize: integer;
begin
  BSize := DGMarkNormWidth + DGMarkNormShift; // "Borders" Size (to reduce code size)

  x := APixX - DGEdges.Left - BSize;
  Result := 0;
  AIndType := dgitBefore;
  if x < 0 then Exit; // before first Column

  dx := DGItemsSize.X + DGGaps.X + 2*BSize;
  ix := x div dx;
  x  := x - ix*dx;

  Result := ix;

  if x >= DGItemsSize.X then // between ix-th and (ix+1)-th Column
    Inc( Result )
  else //********************** inside ix-th Column
    AIndType := dgitInside;

end; // function TN_DGridUniMatr.DGGetColInd

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridUniMatr\DGGetItemIndInCol
//*************************************** TN_DGridUniMatr.DGGetItemIndInCol ***
// Get Index of Item in given Column by given Y coordinate
//
//     Parameters
// AColInd  - given Column Index (Index along X Axis)
// APixY    - given X coordinate in Grid Pixel coords
// AIndType - resulting Item Index type
// Result   - Returns Item Index for the Item in given AColInd Column which 
//            intersect Y=APixY line, is before or after this line.
//
function TN_DGridUniMatr.DGGetItemIndInCol( AColInd, APixY: integer;
                                     out AIndType: TN_DGIndexType ): integer;
begin
  Result := DGGetRowInd( APixY, AIndType ); // AColInd is not used
end; // function TN_DGridUniMatr.DGGetItemIndInCol

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridUniMatr\DGGetItemIndInRow
//*************************************** TN_DGridUniMatr.DGGetItemIndInRow ***
// Get Index of Item in given Row by given X coordinate
//
//     Parameters
// ARowInd  - given Row Index (Index along Y Axis)
// APixX    - given X coordinate in Grid Pixel coords
// AIndType - resulting Item Index type
// Result   - Returns Item Index for the Item in given ARowInd Row which 
//            intersect X=APixX line, is before or after this line.
//
function TN_DGridUniMatr.DGGetItemIndInRow( ARowInd, APixX: integer;
                                     out AIndType: TN_DGIndexType ): integer;
begin
  Result := DGGetColInd( APixX, AIndType ); // ARowInd is not used
end; // function TN_DGridUniMatr.DGGetItemIndInRow


{
//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridUniMatr\DGGetRowInd
//********************************************* TN_DGridUniMatr.DGGetRowInd ***
// Get Grid Row Index
//
//     Parameters
// APixY  - given Y coordinate in Grid Pixel coords
// Result - Returns Row Index for the Row whose Items (may be not all of them)
//   intersect Y=APixY line;
//
// Return negative Result if line Y=APixY intersects no item: (-1-Result) is the
// Row index that is below  Y=APixY line (-2-Result) is the Row index that is
// above Y=APixY line
//
// Grid Pixel coords is coords system in which upper left Grid Pixel has coords
// (0,0)
//
function TN_DGridUniMatr.DGGetRowInd( APixY: integer ): integer;
var
  y, iy, dy, BSize: integer;
begin
  BSize := DGMarkNormWidth + DGMarkNormShift; // "Borders" Size (to reduce code size)

  y := APixY - DGEdges.Top - BSize;
  Result := -1;
  if y < 0 then Exit; // upper than 0-th Row

  dy := DGItemsSize.Y + DGGaps.Y + 2*BSize;
  iy := y div dy;
  y  := y - iy*dy;

  Result := iy;
  if y < DGItemsSize.Y then Exit; // line Y=APixY intersects iy-th Row

  Result := -iy - 2;  // line Y=APixY is between iy-th  and (iy+1)-th Rows
end; // function TN_DGridUniMatr.DGGetRowInd

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridUniMatr\DGGetColInd
//********************************************* TN_DGridUniMatr.DGGetColInd ***
// Get Grid Column Index
//
//     Parameters
// ARowInd - given Grid Row Index (Index along Y Axis)
// APixX   - given X coordinate in Grid Pixel coords
// Result  - Returns Column Index for the Item in given ARowInd Row which
//   intersect X=APixX line;
//
// Return negative Result if line X=APixX intersects no item in ARowInd Row:
// (-1-Result) is the Column index that is righter than X=APixX line (-2-Result)
// is the Column index that is lefter  than X=APixX line
//
function TN_DGridUniMatr.DGGetColInd( ARowInd, APixX: integer ): integer;
var
  x, ix, dx, BSize: integer;
begin
  //***** for Uniform Matrix ARowInd does not affect the Result

  BSize := DGMarkNormWidth + DGMarkNormShift; // "Borders" Size (to reduce code size)

  x := APixX - DGEdges.Left - BSize;
  Result := -1;
  if x < 0 then Exit; // lefter than 0-th Item in Row

  dx := DGItemsSize.X + DGGaps.X + 2*BSize;
  ix := x div dx;
  x  := x - ix*dx;

  Result := ix;
  if x < DGItemsSize.X then Exit; // line X=APixX intersects ix-th Item in Row

  Result := -ix - 2;  // line X=APixX is between ix-th  and (ix+1)-th Columns
end; // function TN_DGridUniMatr.DGGetColInd
}

//********** TN_DGridArbMatr class Public methods  **************

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridArbMatr\Create2
//************************************************* TN_DGridArbMatr.Create2 ***
// TN_DGridArbMatr constructor
//
//     Parameters
// ARFrame  - TN_Rast1Frame in which DGrid should be shown
// AGetSize - external Proc of Obj for inquiring Item Size
//
constructor TN_DGridArbMatr.Create2( ARFrame: TN_Rast1Frame; AGetSize: TN_DGGetItemSizeProcObj );
begin
  inherited Create( ARFrame );

  DGGetItemSizeProcObj := AGetSize;
end; // constructor TN_DGridArbMatr.Create2

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridArbMatr\DGInitRFrame
//******************************************** TN_DGridArbMatr.DGInitRFrame ***
// Layout Grid Elements and Initialize DGRFrame
//
// Layout scheme: if DGLFixNumCols=0 and DGLFixNumRows>0 then all Rows have the 
// same Height which is calculated by FRame Height
//
// if DGLFixNumCols>0 and DGLFixNumRows=0 then all Columns have the same Width 
// which is calculated by FRame Width
//
// Other variants are temporary not implemented
//
// How to use remarks:
//
// 1) RedrawAll() is always called after initialization. Drawing once even an 
// empty Buf is really needed to set proper DGRFrame flags, otherwise 
// DGRFrame.SkipOnPaint would be True and DGRFrame would be transparent 2) 
// Showing MainBuf after RedrawAll() is called only if DGUpdateCounter = 0. If 
// Self should be changed in caller just after call to DGInitRFrame, call to 
// DGBeginUpdate/DGEndUpdate parentheses should be used
//
procedure TN_DGridArbMatr.DGInitRFrame();
var
  i, GridHeight, GridWidth, RowHeight, ColWidth, BSize: integer;
  FullSize, OutSize, MinSize, PrefSize, MaxSize: TPoint;
  Label Fin;

  function GetFullWidth(): integer; // local
  // Calculate DGRowsPos, DGColsPos Arrays and Return Full Grid Width
  // DGNumRows, DGNumCols, RowHeight are used and should be alreay OK
  var
    RowInd, ColInd, ItemInd, CurColWidth, CurLeft: integer;
  begin
    for RowInd := 0 to DGNumRows-1 do // Set Rows Positions
    begin
      DGRowsPos[RowInd].X := DGEdges.Top + BSize + (RowHeight + DGGaps.Y + 2*BSize)*RowInd;
      DGRowsPos[RowInd].Y := DGRowsPos[RowInd].X + RowHeight - 1;
    end; // for RowInd := 0 to DGNumRows-1 do // Set Rows Positions

    ItemInd := 0;
    CurLeft := DGEdges.Left + BSize; // Current Column leftmoust Pixel

    for ColInd := 0 to DGNumCols-1 do // along all Columns
    begin
      //*** Calculate CurColWidth - Current Column Width (Max Width of all Items in Column)
      CurColWidth := -1;

      for RowInd := 0 to DGNumRows-1 do // along all Items in ColInd Column
      begin
        if ItemInd >= DGNumItems then break;
        //*** Get Item Width in OutSize.X,
        //    all other DGGetItemSizeProcObj output params are not used
        DGGetItemSizeProcObj( Self, ItemInd, Point( 0, RowHeight ),
                                         OutSize, MinSize, PrefSize, MaxSize );
        CurColWidth := max( CurColWidth, OutSize.X );

        Inc( ItemInd );
      end; // for RowInd := 0 to DGNumRows-1 do // along all Items in ColInd Column

      //*** CurColWidth is OK, Set DGColsPos[ColInd]
      DGColsPos[ColInd].X := CurLeft;
      DGColsPos[ColInd].Y := CurLeft + CurColWidth - 1;
      Inc( CurLeft, CurColWidth + DGGaps.X + 2*BSize );
    end; // for ColInd := 0 to DGNumCols-1 do // along all Columns

    Result := DGColsPos[DGNumCols-1].Y + DGEdges.Right + BSize + 1;
  end; // function GetFullWidth(): integer; // local

  function GetFullHeight(): integer; // local
  // Calculate DGRowsPos, DGColsPos Arrays and Return Full Grid Height
  // DGNumRows, DGNumCols, ColWidth are used and should be alreay OK
  var
    RowInd, ColInd, ItemInd, CurRowHeight, CurTop: integer;
  begin
    for ColInd := 0 to DGNumCols-1 do // Set Cols Positions
    begin
      DGColsPos[ColInd].X := DGEdges.Left + BSize + (ColWidth + DGGaps.X + 2*BSize)*ColInd;
      DGColsPos[ColInd].Y := DGColsPos[ColInd].X + ColWidth - 1;
    end; // for ColInd := 0 to DGNumCols-1 do // Set Cols Positions

    ItemInd := 0;
    CurTop  := DGEdges.Top + BSize; // Current Row uppermoust Pixel

    for RowInd := 0 to DGNumRows-1 do // along all Rows
    begin
      //*** Calculate CurRowHeight - Current Row Heigth (Max Heigth of all Items in Row)
      CurRowHeight := -1;

      for ColInd := 0 to DGNumCols-1 do // along all Items in RowInd Row
      begin
        if ItemInd >= DGNumItems then break;
        //*** Get Item Height in OutSize.Y,
        //    all other DGGetItemSizeProcObj output params are not used
        DGGetItemSizeProcObj( Self, ItemInd, Point( ColWidth, 0 ),
                                         OutSize, MinSize, PrefSize, MaxSize );
        CurRowHeight := max( CurRowHeight, OutSize.Y );

        Inc( ItemInd );
      end; // for ColInd := 0 to DGNumCols-1 do // along all Items in RowInd Row

      //*** CurRowHeight is OK, Set DGRowsPos[RowInd] and ItemsRects
      DGRowsPos[RowInd].X := CurTop;
      DGRowsPos[RowInd].Y := CurTop + CurRowHeight - 1;
      Inc( CurTop, CurRowHeight + DGGaps.Y + 2*BSize );
    end; // for RowInd := 0 to DGNumRows-1 do // along all Rows

    Result := DGRowsPos[DGNumRows-1].Y + DGEdges.Bottom + BSize + 1;
  end; // function GetFullHeight(): integer; // local

begin //********************** main TN_DGridArbMatr.DGInitRFrame body
  inherited;

//  K_DumpCSADlgCoords( 'DGInitRFrame Start' );

  with DGRFrame do
  begin

  DGNumRows := 0;
  DGNumCols := 0;

  SetLength( DGItemsFlags, DGNumItems );
  SetLength( DGItemsRects, DGNumItems );

  for i := 0 to DGNumItems-1 do // clear all Itmes Flags
    DGItemsFlags[i] := 0;

  DGMarkedList.Clear;
  BSize := DGMarkNormWidth + DGMarkNormShift; // "Borders" Size (to reduce code size)

  if DGNumItems = 0 then goto Fin; // Self is not initialized yet

  if (DGLFixNumCols = 0) and (DGLFixNumRows > 0) then //***********
  begin // set DGNumRows = DGLFixNumRows, all of them should be visible (no Vertical ScrollBar)
        // all Rows have the same Height which is calculated by FRame Height
        // DGLItemsByRows is set to False

    DGNumRows := DGLFixNumRows;
    DGNumCols := (DGNumItems+DGNumRows-1) div DGNumRows;
    SetLength( DGRowsPos, DGNumRows );
    SetLength( DGColsPos, DGNumCols );
    DGLItemsByRows := False; // Items are ordered by Columns

//  K_DumpCSADlgCoords( 'DGInitRFrame 2 1' );
//  N_i := ClientHeight;
//  K_DumpCSADlgCoords( 'DGInitRFrame 2 2' );

    // Try first without Horizontal ScrollBar (as if whole Grid is visible)
    GridHeight := ClientHeight - DGEdges.Top - DGEdges.Bottom;
//  K_DumpCSADlgCoords( 'DGInitRFrame 2 3' );
    RowHeight  := (GridHeight - (DGNumRows-1)*DGGaps.Y) div DGNumRows - 2*BSize;
//  K_DumpCSADlgCoords( 'DGInitRFrame 2 4' );
    FullSize.X := GetFullWidth();

    if FullSize.X > ClientWidth then // Horizontal ScrollBar is needed
    begin
      GridHeight := GridHeight - HScrollBar.Height;
//  K_DumpCSADlgCoords( 'DGInitRFrame 2 5' );
      RowHeight  := (GridHeight - (DGNumRows-1)*DGGaps.Y) div DGNumRows - 2*BSize;
      FullSize.X := GetFullWidth();
    end; // if FullSize.X > ClientWidth then // Horizontal ScrollBar is needed

//  K_DumpCSADlgCoords( 'DGInitRFrame 3' );
    FullSize.Y := DGRowsPos[DGNumRows-1].Y + DGEdges.Bottom + BSize + 1;
  end else if (DGLFixNumCols > 0) and (DGLFixNumRows = 0) then //***********
  begin // DGNumCols = DGLFixNumCols, all of them should be visible (no Horizontal ScrollBar)
        // all Columns have the same Width which is calculated by FRame Width
        // DGLItemsByRows is set to True

    DGNumCols := DGLFixNumCols;
    DGNumRows := (DGNumItems+DGNumCols-1) div DGNumCols;
    SetLength( DGColsPos, DGNumCols );
    SetLength( DGRowsPos, DGNumRows );
    DGLItemsByRows := True; // Items are ordered by Rows

    // Try first without Vertical ScrollBar (as if whole Grid is visible)
    GridWidth  := ClientWidth - DGEdges.Left - DGEdges.Right;
    ColWidth   := (GridWidth - (DGNumCols-1)*DGGaps.X) div DGNumCols - 2*BSize;
    FullSize.Y := GetFullHeight();

    if FullSize.Y > ClientHeight then // Vertical ScrollBar is needed
    begin
      GridWidth  := GridWidth - VScrollBar.Width;
      ColWidth   := (GridWidth - (DGNumCols-1)*DGGaps.X) div DGNumCols - 2*BSize;
      FullSize.Y := GetFullHeight();
    end; // if FullSize.Y > ClientHeight then // Vertical ScrollBar is needed

    FullSize.X := DGColsPos[DGNumCols-1].Y + DGEdges.Right + BSize + 1;
  end; // end else if (DGLFixNumCols > 0) and (DGLFixNumRows = 0)

//  K_DumpCSADlgCoords( 'DGInitRFrame 6' );
  DGInitArrays(); // Init other Arrays (DGIndsInRows, DGIndsInCols and DGItemsRects)
//  K_DumpCSADlgCoords( 'DGInitRFrame 7' );

  Fin: //***** Prepare OCanv, Redraw All and Show MainBuf if needed

  if (DGNumCols <= 0) or (DGNumRows <= 0) then
    RFObjSize := Point( 1, 1 ) // Value (0,0) causes that SetCurCRectSize do nothing and OCanv remains the same
  else // DGNumCols >= 1 and DGNumRows >= 1
    RFObjSize := FullSize;

  OCanv.SetCurCRectSize( RFObjSize.X, RFObjSize.Y );
  RFLogFramePRect := IRect( RFObjSize );
  RecalcPRects();

  OCanvBackColor := DGBackColor;
  DstBackColor   := DGBackColor;

  //***** Later, for optimization, Redrawing may be postponed after all Items
  //      would have final state
  RedrawAll();

  if DGUpdateCounter = 0 then ShowMainBuf();

  end; // with DGRFrame do
end; // procedure TN_DGridArbMatr.DGInitRFrame


//********** TN_DGridNonMatr class Public methods  **************

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridNonMatr\Create
//************************************************** TN_DGridNonMatr.Create ***
// TN_DGridNonMatr constructor
//
//     Parameters
// ARFrame - TN_Rast1Frame in which DGrid should be shown
//
constructor TN_DGridNonMatr.Create( ARFrame: TN_Rast1Frame );
begin
end; // constructor TN_DGridNonMatr.Create

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridNonMatr\DGInitRFrame
//******************************************** TN_DGridNonMatr.DGInitRFrame ***
// Initialize DGRFrame
//
procedure TN_DGridNonMatr.DGInitRFrame ();
begin
end; // procedure TN_DGridNonMatr.DGInitRFrame

{
//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridNonMatr\DGGetRowInd
//********************************************* TN_DGridNonMatr.DGGetRowInd ***
// Get Grid Row Index
//
//     Parameters
// APixY  - given Y coordinate in Grid Pixel coords
// Result - Returns Row Index for the Row whose Items (may be not all of them)
//   intersect Y=APixY line;
//
// Return negative Result if line Y=APixY intersects no item:
//#F
//    (-1-Result) is the Row index that is below  Y=APixY line
//    (-2-Result) is the Row index that is above  Y=APixY line
//
//#/F
//
// Grid Pixel coords is coords system in which upper left Grid Pixel has coords
// (0,0)
//
function TN_DGridNonMatr.DGGetRowInd( APixY: integer ): integer;
begin
  Result := -1;
end; // function TN_DGridNonMatr.DGGetRowInd

//##path N_Delphi\SF\N_Tree\N_DGrid.pas\TN_DGridNonMatr\DGGetColInd
//********************************************* TN_DGridNonMatr.DGGetColInd ***
// Get Grid Column Index
//
//     Parameters
// ARowInd - given Grid Row Index (Index along Y Axis)
// APixX   - given X coordinate in Grid Pixel coords
// Result  - Returns Column Index for the Item in given ARowInd Row which
//   intersect X=APixX line;
//
// Return negative Result if line X=APixX intersects no item in ARowInd Row:
//#F
//    (-1-Result) is the Column index that is righter than X=APixX line
//    (-2-Result) is the Column index that is lefter  than X=APixX line
//#/F
//
function TN_DGridNonMatr.DGGetColInd( ARowInd, APixX: integer  ): integer;
begin
  Result := -1;
end; // function TN_DGridNonMatr.DGGetColInd
}

end.
