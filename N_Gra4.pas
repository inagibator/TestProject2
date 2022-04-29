unit N_Gra4;
// TN_StructSegms Obj - code for checking crossings and preparing lines
//                      for Contours assembling

interface
uses
  Windows, Classes, Graphics, StdCtrls,
  N_Types, N_Lib1, N_Gra0, N_Gra1, N_UDat4;

type TN_SegmData = packed record //***** One Segment Data
  SA, SB, SC: double;  // Segment's Line coefs: SA*x + SB*y + SC = 0
  SPP1: TN_BytesPtr;         // Pointer to float or double P1 point
  SULinesInd: integer; // ULines CObj Index in SrcULines Array that contains line
  SLineInd: integer;   // Line index (Item Index) in ULines
  SSegmInd: integer;   // Segment index in LineInd Line
end; // type TN_SegmData = packed record
type TN_PSegmData = ^TN_SegmData;
type TN_ASegmData = array of TN_SegmData;

TN_CSEActionType = ( csAddPoint, csSplitLine );

type TN_CSEAction = packed record //***** Cross Segms Edit Action
    // first free fields (ALineInd, AVertSegmInd, ARelDist) used for ordering
  AULinesInd:   integer; // ULines CObj Index that contains line
  ALineInd:     integer; // Line Index (Index of Line to edit) in ULines
  AVertSegmInd: integer; // Vertex or Segment Index (2*VertexInd) or (2*SegmentInd+1)
  ARelDist:     double;  // relative distance (0-1) of APointCoords in segment
  ActionType: TN_CSEActionType;
  ANewVertex: TDPoint; // New Vertex coords to add on segment (used for csAddPoint)
end; // type TN_CSEAction = packed record
type TN_PCSEAction = ^TN_CSEAction;
type TN_CSEActions = array of TN_CSEAction;

type TN_CSegmInfo = record //***** Cross Segms Info
  CSIULinesInd1: integer;
  CSILineInd1:   integer;
  CSISegmInd1:   integer;
  CSIULinesInd2: integer;
  CSILineInd2:   integer;
  CSISegmInd2:   integer;
  CSICrossType:  integer;
end; // type TN_CSegmInfo = record //***** Cross Segms Info
type TN_CSegmsInfo = array of TN_CSegmInfo;

type TN_StructSegms = class( TObject ) // Structured Segments
    public
  SegmsEnvRect: TFRect; // Envelope FRect of all Segments
  NumRectsX: integer;   // Number of rects in X direction
  NumRectsY: integer;   // Number of rects in Y direction
  SnapDist:  double;    // Snap Distance (Snap to Grid: (0,0), (SnapDist,SnapDist)
  CorrectDist: double;  // Correction Distance (used in auto correction code)
  NumCrossed: integer;  // Number of found segments crossings

  CSEActions: TN_CSEActions; // Array of all actions, that should be preformed
                             // to correct segments crossings
  FreeActInd: integer;       // Index of first free element in CSEActions array

  RectsWidth: double;   // all rects Width
  RectsHeight: double;  // all rects Height

  SegmentsData: TN_ASegmData; // array of all Segments Data
  NumSegments: integer;       // whole number of segments
  SegmInds: TN_AIArray; // array or arrays of SegmData Indexes
   // (one Array per Rect, SegmInds[i,0] - number of segments in i-th List + 1)
  NumIndexes: integer;  // whole number of elements in all SegmInds arrays

  SrcULines: TN_AULines;    // array of source ULines
  NumSrcULines: integer;    // number of elements in SrcULines

  SumUlinesSize: integer;   // size in bytes of all ULines in SrcULines
  EmptyRectsPart: double;   // =1.0 - all Rects empty; =0.0 - all filled
  AverageListSize: double;  // SumOfAllLists / NumberOfFilledLists
  MaxListSize: integer;     // Max ListSize for some Rect
  NumComparisons: Int64;    // needed number of comparisons (pairs of Segments)
  CrossSegms: TN_ULines;    // used for visualization of found Crossings

  CrossSegmsObjName: string;   // also used for MapLayer name ('M'+CrossSegmsObjName)
  CrossSegmsPenColor: integer; // used for visualization of found Crossings
  CrossSegmsPenWidth: float;   // used for visualization of found Crossings
  CrossInfo: TN_CSegmsInfo;    // info about crossed segments

  constructor Create  ();
  destructor  Destroy (); override;
  procedure AddOneULines         ( AULines: TN_ULines );
  procedure AddSegmDataIndex     ( ARectIndX, ARectIndY, ASegmDataInd: integer );
  procedure StructULinesSegments ( AULinesInd: integer );
  procedure StructAllSegments ( NumX: integer; NumY: integer = -1;
                                                         EnvIncCoef: double = 0 );
  procedure CollectStatistics ( SL: TStrings; Mode: integer );
  procedure FindSegmCrossings ( SL: TStrings; Mode: integer );
  procedure PerformActions    ();
end; // type TN_StructSegms = class( TObject )


//***********  Nodes analisis types and methods  ***********
//  Node is Lines Endpoint, usually common to several Lines

Const
  N_EPBegPoint = $001;

type TN_EndPoint = packed record // EndPoint Description (two Endpoints per line)
  EPCoords:   TDPoint; // EndPoint Coords (may be snapped)
  EPGItemInd: integer; // EndPoint Global Item Index
  EPFlags:    integer; // EndPoint Flags (N_EPBegPoint)
  EPPtrsInd:  integer; // Index of self in EPPTRS Array;
end; // type TN_EndPoint = record
type TN_PEndPoint  = ^TN_EndPoint; // pointer to EndPoint
type TN_EndPoints  = Array of TN_EndPoint;  // array of EndPoints
type TN_PEndPoints = Array of TN_PEndPoint; // array of pointers to EndPoints

type TN_Node1 = record // Node Description #1
  NCoords:  TDPoint;  // Node Coords
  NLines: TN_IPArray; // Node's Lines List (.X - LineInd, .Y - flags)
end; // type TN_Node1 = record // Node Description
type TN_PNode1  = ^TN_Node1; // pointer to Node
type TN_Nodes1  = Array of TN_Node1;  // array of Nodes
type TN_PNodes1 = Array of TN_PNode1; // array of pointers to Nodes

type TN_GlobItem = record // one GItem description
  GIULinesInd: integer; // index in ULinesArray
  GIItemInd:   integer; // Item Index
  GIFlags:     integer; // Item Flags (N_DoubleCoords)
  GISegmLengths: TN_DArray; // all Item segments Lengths
  GIWSize:     double;      // Whole Size (Sum) of all segments
end; // type TN_GlobItem = record
type TN_GlobItems = Array of TN_GlobItem;

type TN_NodesObj = class( TObject ) // Nodes Object
    public
  ULinesArray: TN_AULines; // array of ULines to analize
  NumULines: integer;
  GItems: TN_GlobItems; // Global Items List for all ULines
  NumGItems: integer;
  EndPoints: TN_EndPoints;
  NumEndPoints: integer;
  EPPtrs: TN_PEndPoints;
  Nodes:     TN_Nodes1;
  NumNodes:  integer;

  procedure InitNodesObj      ();
  procedure AddOneULines      ( AULines: TN_Ulines );
  procedure CollectEndPoints  ();
  procedure CollectNodesLines ();
  function  RemoveNearLines   ( ADstULines: TN_ULines; ADist: double;
                                ASL: TStrings; AMode: integer ): integer;
  function  CombineLines ( AULines: TN_ULines; ASL: TStrings; AMode: integer ): integer;
  function  CheckNodesLinesCodes ( ASL: TStrings; AMode: integer ): integer;
end; // type TN_NodesObj = class( TObject )


//*********************  Global procedures  ********************

function  N_RemoveNearLines ( InpULines, OutULines: TN_ULines; ADist: double;
                                      ASL: TStrings; AMode: integer ): integer;
function  N_SmoothByRemovingPoints ( InpULines, OutULines: TN_ULines;
                                     AMinDist, AMaxDist, ACoef: double;
                                     ASL: TStrings; AMode: integer ): double;
function  N_CheckSegmentsCrossings ( InpULines, OutULines: TN_ULines;
                                     ANumXY: integer; AIncCoef: double;
                                ASL: TStrings; AMode: integer ): TN_StructSegms;
function  N_CheckLinesCodes ( AULines: TN_ULines;
                                      ASL: TStrings; AMode: integer ): integer;
function  N_CombineLines    ( AULines: TN_ULines; ANumPases: integer;
                                      ASL: TStrings; AMode: integer ): integer;
function  N_MoveCObjCodes   ( ACObj: TN_UCObjLayer; ACDim1, ACDim2: integer;
                                      ASL: TStrings; AMode: integer ): integer;
function  N_XORCObjCodes    ( ACObj: TN_UCObjLayer; ACDim, ACode1, ACode2: integer;
                                      ASL: TStrings; AMode: integer ): integer;

Const
  N_DCFlag = $40000000; // Double Coords Flag in TN_SegmData.SSegmInd


implementation
uses Math, SysUtils,
  N_Lib0, N_ME1;


//********** TN_StructSegms class methods  **************
//
// Used for checking ULines crossings, crossings corrections and converting
// closed polygons (with overlapped borders) to Contours borders? suitable
// for assembling contours

//*************************************************** TN_StructSegms.Create ***
//
constructor TN_StructSegms.Create();
begin
  inherited Create;
  NumCrossed := -1;
  CrossSegmsObjName  := 'CrossSegms';
  CrossSegmsPenColor := $0000FF;
  CrossSegmsPenWidth := 3;
end; // end_of constructor TN_StructSegms.Create

//************************************************** TN_StructSegms.Destroy ***
//
destructor TN_StructSegms.Destroy();
begin
  Inherited;
end; //*** end of destructor TN_StructSegms.Destroy

//********************************************* TN_StructSegms.AddOneULines ***
// just add one given AULine to SrcUlines array
//
procedure TN_StructSegms.AddOneULines( AULines: TN_ULines );
begin
  if AULines = nil then Exit;
  if High(SrcULines) < NumSrcULines then
    SetLength( SrcULines, N_Newlength( NumSrcULines ) );

  SrcULines[NumSrcULines] := AULines;
  Inc(NumSrcULines);
end; // procedure TN_StructSegms.AddOneULines

//****************************************** TN_StructSegms.AddLineSegmInds ***
// add given SegmData Index to RectIndX,Y array of indexes
//
procedure TN_StructSegms.AddSegmDataIndex( ARectIndX, ARectIndY, ASegmDataInd: integer );
var
  RectInd, NewSegmInd: integer;
begin
  RectInd := ARectIndY*NumRectsX + ARectIndX;

  if SegmInds[RectInd] = nil then  // first segment in List
  begin
    SetLength( SegmInds[RectInd], 2 );
    SegmInds[RectInd,0] := 2;
    NewSegmInd := 1;
  end else //************************ not first segment in List
  begin
    NewSegmInd := SegmInds[RectInd,0];
    Inc( SegmInds[RectInd,0] );
    if High(SegmInds[RectInd]) < NewSegmInd then
      SetLength( SegmInds[RectInd], N_NewLength( NewSegmInd+1 ) );
  end;

  SegmInds[RectInd,NewSegmInd] := ASegmDataInd;
end; // procedure TN_StructSegms.AddSegmDataIndex

//************************************* TN_StructSegms.StructULinesSegments ***
// Structurize all Segments of AULines CObj with given Index AULinesInd:
// - add SegmentsData elements (one element per one Line segment)
// - for each added SegmentsData element, add it's index to all SegmInds
//   array (one rect per rect) that cross this segment
//
procedure TN_StructSegms.StructULinesSegments( AULinesInd: integer );
var
  ItemInd, DCInd, SegmDataInd, FirstInd, NumInds: integer;
  RectIndX, RectIndY, SIX, SIY, SK: integer;
  RectIndX1, RectIndY1, RectIndX2, RectIndY2: integer;
  X, Y, K, KNorm, FRectIndX, FRectIndY, ABSize, NormCoef: double;
  P1, P2: TDPoint;
//  PSrcPChar: PAnsiChar;
  Label EndOfLoop;
begin
  with SrcULines[AULinesInd] do
  for ItemInd := 0 to WNumItems-1 do // loop along all lines in AULines
  begin
    GetPartInds( ItemInd, 0, FirstInd, NumInds );

    if Length(SegmentsData) < NumSegments + NumInds-1 then
      SetLength( SegmentsData, N_NewLength( NumSegments + NumInds-1 ) );

    for DCInd := 0 to NumInds-2 do // loop along all segments in cur. line
    with SegmentsData[NumSegments+DCInd] do
    begin
      //***** fill SegmentsData element

      if WLCType = N_FloatCoords then // Float Coords
      begin
        SPP1 := TN_BytesPtr(@LFCoords[FirstInd+DCInd]);
        P1.X := PFPoint(SPP1)^.X;
        P1.Y := PFPoint(SPP1)^.Y;
        P2.X := PFPoint(SPP1+Sizeof(TFPoint))^.X;
        P2.Y := PFPoint(SPP1+Sizeof(TFPoint))^.Y;
        SSegmInd := 0;         // no Double coords flag
      end else //****************************** Double Coords
      begin
        SPP1 := TN_BytesPtr(@LDCoords[FirstInd+DCInd]);
        P1.X := PDPoint(SPP1)^.X;
        P1.Y := PDPoint(SPP1)^.Y;
        P2.X := PDPoint(SPP1+Sizeof(TDPoint))^.X;
        P2.Y := PDPoint(SPP1+Sizeof(TDPoint))^.Y;
        SSegmInd := N_DCFlag; // Double coords flag
      end;

      SA := P2.Y - P1.Y;
      SB := P1.X - P2.X;
      SC := P2.X*P1.Y - P2.Y*P1.X;

      ABSize := Sqrt( SA*SA + SB*SB ); // Size (Norm) of (SA,SB) vector
      // distance between P1 and ( P1.X+SA/ABSize, P1.Y+SB/ABSize ) equals to 1
      // and (SA,SB) vector is perpendicular to (P1,P2) segment
      NormCoef := SA*(P1.X + SA/ABSize) + SB*(P1.Y + SB/ABSize) + SC;

      SA := SA / NormCoef;
      SB := SB / NormCoef;
      SC := SC / NormCoef;

      // now (SAx + SBy + SC) is real distance between (x,y) and (P1,P2) line

      SULinesInd := AULinesInd;
      SLineInd   := ItemInd;
      SSegmInd   := SSegmInd or DCInd; // preserve Double coords flag

      //***** add SegmDataInd to all needed SegmInds arrays
      SegmDataInd := NumSegments + DCInd;

      SIX := 1;
      if P1.X > P2.X then SIX := -1;

      SIY := 1;
      if P1.Y > P2.Y then SIY := -1;

      RectIndX1 := Floor( ( P1.X - SegmsEnvRect.Left ) / RectsWidth );
      RectIndX2 := Floor( ( P2.X - SegmsEnvRect.Left ) / RectsWidth );

      RectIndY1 := Floor( ( P1.Y - SegmsEnvRect.Top ) / RectsHeight );
      RectIndY2 := Floor( ( P2.Y - SegmsEnvRect.Top ) / RectsHeight );

      AddSegmDataIndex( RectIndX1, RectIndY1, SegmDataInd );
      RectIndX := RectIndX1;
      RectIndY := RectIndY1;

      if P1.Y = P2.Y then // horizontal line
      begin
        while True do
        begin
          if RectIndX = RectIndX2 then goto EndOfLoop; // all done for cur segment
          Inc( RectIndX, SIX );
          AddSegmDataIndex( RectIndX, RectIndY, SegmDataInd );
        end;
      end;

      if P1.X = P2.X then // vertical line
      begin
        while True do
        begin
          if RectIndY = RectIndY2 then goto EndOfLoop; // all done for cur segment
          Inc( RectIndY, SIY );
          AddSegmDataIndex( RectIndX, RectIndY, SegmDataInd );
        end;
      end;

      //*** not vertical, nor horizontal line
      //    prepare to loop in X direction

      K := (P2.Y - P1.Y) / (P2.X - P1.X);
      KNorm := K*RectsWidth / RectsHeight;
      SK := SIY;
      if KNorm < 0 then SK := -SK;

      if P1.X < P2.X then // from left to right
      begin
        X := SegmsEnvRect.Left + RectIndX1*RectsWidth;
        Y := P1.Y + (X - P1.X)*K;
      end else
      begin
        X := SegmsEnvRect.Left + (RectIndX1+1)*RectsWidth;
        Y := P1.Y + (X - P1.X)*K;
      end;
      FRectIndY := (Y - SegmsEnvRect.Top) / RectsHeight;
      RectIndX := RectIndX1;

      while True do // loop in X direction
      begin
        if RectIndX = RectIndX2 then Break; // goto loop in Y direction
        Inc( RectIndX, SIX );
        FRectIndY := FRectIndY + KNorm*SK;
        RectIndY := Floor( FRectIndY );
        AddSegmDataIndex( RectIndX, RectIndY, SegmDataInd );
      end; // while True do // loop in X direction

      //***** prepare to loop in Y direction

      KNorm := 1.0/KNorm;
      SK := SIX;
      if KNorm < 0 then SK := -SK;

      if P1.Y < P2.Y then // from top to down
      begin
        Y := SegmsEnvRect.Top + RectIndY1*RectsHeight;
        X := P1.X + (Y - P1.Y)/K;
      end else
      begin
        Y := SegmsEnvRect.Top + (RectIndY1+1)*RectsHeight;
        X := P1.X + (Y - P1.Y)/K;
      end;
      FRectIndX := (X - SegmsEnvRect.Left) / RectsWidth;
      RectIndY := RectIndY1;

      while True do // loop in Y direction
      begin
        if RectIndY = RectIndY2 then Break; // all done for cur segment
        Inc( RectIndY, SIY );
        FRectIndX := FRectIndX + KNorm*SK;
        RectIndX := Floor( FRectIndX );
        AddSegmDataIndex( RectIndX, RectIndY, SegmDataInd );
      end; // while True do // loop in Y direction

      EndOfLoop: //**********************************
    end; // for DCInd := 0 to High(DC) do

    Inc( NumSegments, NumInds-1 );
  end; // for i := 0 to WNumItems-1 do

end; //*** end of procedure TN_StructSegms.StructULinesSegments

//**************************************** TN_StructSegms.StructAllSegments ***
//  Fill SegmInds arrays by SrcULines array:
//  - calculate all segments Envelope Rect by AULines EnvRects
//  - calculate all rects coords (by given NumX, NumY and EnvIncCoef)
//  - call StructULinesSegments for all elements of SrcULine
//
//  NumX, NumY - number of Rects along X,Y axises
//  NumY = -1 means, that NumX is number of Rects along greater dimension
//           and Rects shoud be quadrant
//  EnvIncCoef > 0 means, that NumX, NumY should be increased by 1 and
//           SegmsEnvRect should be increased by one RectsWidth, RectsHight
//
procedure TN_StructSegms.StructAllSegments( NumX: integer; NumY: integer;
                                                         EnvIncCoef: double );
var
  i, NumRects, NeededSize: integer;
  Aspect: double;
begin
  //***** Calc SegmsEnvRect for all SrcUlines

  SegmsEnvRect.Left := N_NotAFloat;
  SumUlinesSize := 0;

  for i := 0 to NumSrcUlines-1 do
  begin
    N_FRectOr( SegmsEnvRect, SrcUlines[i].WEnvRect );
    Inc( SumUlinesSize, SrcUlines[i].GetSizeInBytes() );
  end;

  SegmsEnvRect := N_RectScaleR( SegmsEnvRect, 1.001, DPoint(0.5,0.5) );

  //***** prepare all needed objects, arrarys and coefs

  if NumY = -1 then
  begin
    Aspect := N_RectAspect(SegmsEnvRect);
    if Aspect < 1 then // X-size > Y-size,
    begin
      NumRectsX := NumX;
      NumRectsY := Round(Ceil( NumX*Aspect ));
    end else //********* X-size <= Y-size,
    begin
      NumRectsX := Round(Ceil( NumX/Aspect ));
      NumRectsY := NumY;
    end;
  end else
  begin
    NumRectsX := NumX;
    NumRectsY := NumY;
  end;

  RectsWidth  := (SegmsEnvRect.Right  - SegmsEnvRect.Left) / NumRectsX;
  RectsHeight := (SegmsEnvRect.Bottom - SegmsEnvRect.Top)  / NumRectsY;

  if EnvIncCoef > 0 then // SegmsEnvRect should be increased
  with SegmsEnvRect do
  begin
    Left   := Left   - RectsWidth*EnvIncCoef;
    Top    := Top    - RectsHeight*EnvIncCoef;
    Right  := Right  - RectsWidth*EnvIncCoef  + RectsWidth;
    Bottom := Bottom - RectsHeight*EnvIncCoef + RectsHeight;
    Inc(NumRectsX);
    Inc(NumRectsY);
  end; // if EnvIncCoef > 0 then // SegmsEnvRect should be increased

  NumRects  := NumRectsX*NumRectsY;
  SetLength( SegmInds, NumRects );

  SnapDist := 1000 * N_DEps * N_RectMaxCoord( SegmsEnvRect );
  CorrectDist := 4*SnapDist;

  NeededSize := 0;
  for i := 0 to NumSrcULines-1 do // calc SegmentsData size
  with SrcULines[i] do
  begin
    if WLCType = N_FloatCoords then
      Inc( NeededSize, Length(LFCoords) )
    else
      Inc( NeededSize, Length(LDCoords) );
  end;
  SetLength( SegmentsData, NeededSize );

  // Structurize SrcULines segments
  for i := 0 to NumSrcULines-1 do
    StructULinesSegments( i );

  SetLength( SegmentsData, NumSegments );
end; // procedure TN_StructSegms.StructAllSegments

//**************************************** TN_StructSegms.CollectStatistics ***
// Collect statistics about Segments and Crossings in given SL
//
procedure TN_StructSegms.CollectStatistics( SL: TStrings; Mode: integer );
var
  i, NFilled, Size, NRects, NumList1: integer;
  NumSelfCrossings, NumSameSegments: integer;
begin
  NFilled := 0;
  NumList1 := 0;
  NumIndexes := 0;
  NumComparisons := 0;
  MaxListSize := 0;
  NRects := NumRectsX*NumRectsY;

  for i := 0 to NRects-1 do // collect info about all Rect Lists
  begin
    if SegmInds[i] = nil then // empty list
      Continue
    else if SegmInds[i,0] = 2 then // single segment List
    begin
      Inc(NumList1);
    end else // List with 2 segments or more
    begin
      Size := SegmInds[i,0] - 1;
      Inc(NFilled);
      Inc( NumIndexes, Size );
      Inc( NumComparisons, Size*(Size-1) div 2 );
      if MaxListSize < Size then MaxListSize := Size;
    end;
  end; // for i := 0 to NumRectsX*NumRectsY-1 do

  EmptyRectsPart := 1.0*(NRects - NFilled) / NRects;

  if NFilled > 0 then
    AverageListSize := 1.0*NumIndexes / NFilled
  else
    AverageListSize := 0;

  if NumComparisons = 0 then NumComparisons := -1; // a precaution

  NumSelfCrossings := 0;
  NumSameSegments  := 0;

  for i := 0 to NumCrossed-1 do // collect Statistics about Crossings
  with CrossInfo[i] do
  begin
    if (CSIULinesInd1 = CSIULinesInd2) and
       (CSILineInd1 = CSILineInd2) then Inc( NumSelfCrossings );
    if CSICrossType = 1 then Inc( NumSameSegments );
  end; // for i := 0 to NumCrossed-1 do // collect Statistics about Crossings


  SL.Add( ' Structured Segments Statistics:' );
  if (Mode and $0F0) = $010 then // skip all except SelfCrossings
    SL.Add( '    (SelfCrossings Only)' );
  SL.Add( Format( 'SumUlinesSize      = %3.1n KB', [0.001*SumUlinesSize]));
  SL.Add( Format( 'NumSegments        = %2.0n (%3.1n KB)',  [1.0*NumSegments, 0.001*Sizeof(SegmentsData[0])*Length(SegmentsData)]));
  SL.Add( Format( 'NumX, NumY         = %d, %d', [NumRectsX, NumRectsY]));
  SL.Add( Format( 'BaseListsSize      = %2.0n (%3.1n KB)', [1.0*NRects,     0.004*NRects]));
  SL.Add( Format( 'SumLists1Size      = %2.0n (%3.1n KB)', [1.0*NumList1,   0.016*NumList1]));
  SL.Add( Format( 'SumListsNSize      = %2.0n (%3.1n KB)', [1.0*NumIndexes, 0.004*NumIndexes+0.012*NFilled]));
  SL.Add( Format( 'AverageListSize    = %3.1f',  [AverageListSize]));
  SL.Add( Format( 'MaxListSize        = %2.0n',  [1.0*MaxListSize]));
  SL.Add( Format( 'EmptyRectsPart (%s) = %2.3f', ['%', 100.0*EmptyRectsPart]));
  SL.Add( Format( 'Number of Comparisons = %2.0n', [1.0*NumComparisons]));
  SL.Add( Format( '(Max/Num) Comparisons = %3.1f',
                     [ 0.5*NumSegments*(NumSegments-1) / NumComparisons ]));
  SL.Add( '' );
  SL.Add( Format( 'Number of Crossings   = %2.0n', [1.0*NumCrossed]));
  SL.Add( Format( 'Num  Self Crossings   = %2.0n', [1.0*NumSelfCrossings]));
  SL.Add( Format( 'Number of Same Segms. = %2.0n', [1.0*NumSameSegments]));
  SL.Add( Format( 'Number of Actions     = %2.0n (%3.1n KB)', [1.0*FreeActInd,  0.040*FreeActInd]));
  SL.Add( Format( 'Number of Info Recs.  = %2.0n (%3.1n KB)', [1.0*Length(CrossInfo), 0.028*Length(CrossInfo)]));
end; //*** end of procedure TN_StructSegms.CollectStatistics

//**************************************** TN_StructSegms.FindSegmCrossings ***
// Find all segments crossings or touchings and create
// array of CSEActions - list of actions to be performed before
// assembling rings: add new vertexes and split lines at vertexes,
// common to several segments (except for adjacent segments)
//
// SL   - StringList for showing crossings data and all segments statistics (may be nil)
// Mode - bits0-4($00F) - needed crossings data (added to SL):
//                  =0 none
//                  =1 only number of crossings
//                  =2 all info about crossings
//                  =3 all info about crossings and actions
//        bits4-7($00F0) - needed crossings type
//                  =0 - all types
//                  =1 - only Self Crossings (inside one Line)
//
procedure TN_StructSegms.FindSegmCrossings( SL: TStrings; Mode: integer );
var
  i, j, MaxInd, FirstInd, NInds, CrossingsInfoMode, FreeCrossInd: integer;
  RectInd, RectIndX, RectIndY, MaxSegmIndi, MaxSegmIndj: integer;
  GlobCounter: Int64;
  R1a, R2a, R1b, R2b, Percent: double;
  AlreadyProcessed: boolean;
  P1i, P2i, P1j, P2j, CrossPoint: TDPoint;
  PSi, PSj: TN_PSegmData;
  Str: string;
//  PSrcPChar: PAnsiChar;
  Timer: TN_CPUTimer1;

  procedure GetP12( APS: TN_PSegmData; out AP1, AP2: TDPoint ); // local
  // Get P1, P2 Coords for given Segment
  begin
    with APS^ do
    begin
      if (SSegmInd and N_DCFlag) = 0 then // Float Coords
      begin
        AP1.X := PFPoint(SPP1)^.X;
        AP1.Y := PFPoint(SPP1)^.Y;
        AP2.X := PFPoint(SPP1+Sizeof(TFPoint))^.X;
        AP2.Y := PFPoint(SPP1+Sizeof(TFPoint))^.Y;
      end else //*************************** Double Coords
      begin
        AP1.X := PDPoint(SPP1)^.X;
        AP1.Y := PDPoint(SPP1)^.Y;
        AP2.X := PDPoint(SPP1+Sizeof(TDPoint))^.X;
        AP2.Y := PDPoint(SPP1+Sizeof(TDPoint))^.Y;
      end;
    end; // with APS^ do
  end; // procedure GetP12 - local

  procedure AddCurSegmsToMap(); // local
  // Add two current (crossing) segments to CrossSegms ULines (if not nil)
  // for crossings visualization
  begin
    if AlreadyProcessed then Exit; // cur crossing was already processed
    AlreadyProcessed := True; // each crossing should be processed only once

    if CrossSegms <> nil then
    begin
      CrossSegms.AddSegmentItem( P1i, P2i );
      CrossSegms.AddSegmentItem( P1j, P2j );
    end; // if CrossSegms <> nil then

    if CrossingsInfoMode >= 2 then // add info about crossing segments
    begin
      SL.Add( Format( '***** CrossingInd=%.2d  CrossPoint=(%7g, %7g)',
                                  [NumCrossed, CrossPoint.X, CrossPoint.Y] ) );
      with PSi^ do
      begin
        SL.Add( Format( '  %8s Li=%.3d Si=%.2d  P1=(%7g, %7g)  P2=(%7g, %7g)',
                [SrcULines[SUlinesInd].ObjName, SLineInd, SSegmInd and $3FFFFFFF, P1i.X, P1i.Y, P2i.X, P2i.Y] ) );
      end; // with PSi^ do

      with PSj^ do
      begin
        SL.Add( Format( '  %8s Li=%.3d Si=%.2d  P1=(%7g, %7g)  P2=(%7g, %7g)',
                [SrcULines[SUlinesInd].ObjName, SLineInd, SSegmInd and $3FFFFFFF, P1j.X, P1j.Y, P2j.X, P2j.Y] ) );
      end; // with PSj^ do
    end; // if CrossingsInfoMode = 2 then // add info about crossing segments

    Inc( NumCrossed ); // Number of found segments crossings
  end; // procedure AddCurSegmsToMap // local

  procedure AddAction( APS: TN_PSegmData; AddInd: integer;
                                     AActionType: TN_CSEActionType ); // local
  // Add One Action to CSEActions array
  var
    P1, P2: TDPoint;
    AStr: string;
  begin
    // because of AlreadyProcessed variable each crossing will be added only once

    if ((Mode and $0F0) = $010) and // skip all except SelfCrossings
       ( (PSi^.SULinesInd <> PSj^.SULinesInd) or
         (PSi^.SLineInd <> PSj^.SLineInd) ) then Exit;

    AddCurSegmsToMap();
    GetP12( APS, P1, P2 );

    with APS^, CSEActions[FreeActInd] do // add CrossPoint on i-th segment
    begin
      AULinesInd   := SULinesInd;
      ALineInd     := SLineInd;
      AVertSegmInd := (SSegmInd and $3FFFFFFF) + AddInd;
      ActionType   := AActionType;

      if ActionType = csAddPoint then
      begin
        ARelDist   := N_P2PDistance( P1, CrossPoint ) / N_P2PDistance( P1, P2 );
        ANewVertex := CrossPoint;
      end else // ActionType = csSplitLine
      begin
        ARelDist   := 1.0;
        ANewVertex := DPoint(0,0);
      end;
    end;

    if CrossingsInfoMode = 3 then // add info about actions
    with CSEActions[FreeActInd] do
    begin
      case ActionType of
      csAddPoint:  Astr := 'AddPoint';
      csSplitLine: Astr := 'SplitLine';
      end;

      SL.Add( Format( '    %9s %.2d %8s Li=%.3d VSi=%.2d, RD=%.3f, VC=(%7g, %7g)',
          [Astr, FreeActInd, SrcULines[AULinesInd].ObjName, ALineInd, AVertSegmInd, ARelDist,
                                               ANewVertex.X, ANewVertex.Y] ) );
    end; // if CrossingsInfoMode = 3 then // add info about actions

    Inc( FreeActInd );
  end; // procedure AddAction (local)

  procedure AddCrossInfo( ACrossType: integer ); // local
  // Add Info about one pair of crossed segments
  begin
    if ((Mode and $0F0) = $010) and // skip all except SelfCrossings
     ( (PSi^.SULinesInd <> PSj^.SULinesInd) or
       (PSi^.SLineInd <> PSj^.SLineInd) ) then Exit;

    if FreeCrossInd > High(CrossInfo) then
      SetLength( CrossInfo, N_NewLength( FreeCrossInd+1 ) );

    with CrossInfo[FreeCrossInd] do
    begin
      CSIULinesInd1 := PSi^.SULinesInd;
      CSILineInd1   := PSi^.SLineInd;
      CSISegmInd1   := PSi^.SSegmInd;

      CSIULinesInd2 := PSj^.SULinesInd;
      CSILineInd2   := PSj^.SLineInd;
      CSISegmInd2   := PSj^.SSegmInd;

      CSICrossType  := ACrossType;
    end; // with CrossInfo[FreeCrossInd] do
    Inc( FreeCrossInd );
  end; // procedure AddCrossInfo (local)

  function NotAdjacent(): boolean; // local
  // return True if i-th and j-th segments are not adjacent
  begin
    Result := not ( (PSi^.SULinesInd  = PSj^.SULinesInd)  and
                    (PSi^.SLineInd = PSj^.SLineInd) and
                    (PSi^.SSegmInd = PSj^.SSegmInd-1)   );
  end; // function NotAdjacent(): boolean; // local

  function SkipCrossing(): boolean; // local
  // return True if CrossPoint is not in current RectInd
  var
    CPix, CPiy: integer;
  begin
    CPix := Floor( ( CrossPoint.X - SegmsEnvRect.Left ) / RectsWidth );
    CPiy := Floor( ( CrossPoint.Y - SegmsEnvRect.Top )  / RectsHeight );
    Result := (CPix <> RectIndX) or (CPiy <> RectIndY);
  end; // function SkipCrossing(): boolean; // local

begin //*************************************** body of FindSegmCrossings

  Timer := TN_CPUTimer1.Create;
  Timer.Start();

  GlobCounter := 0;
  NumCrossed := 0;
  FreeActInd := 0;
  FreeCrossInd := 0;

  CrossingsInfoMode := Mode and $0F;
  if SL = nil then Mode := 0;

  if CrossingsInfoMode >= 1 then
  begin
    SL.Add( ' Segments Crossing Data:' );
    SL.Add( '' );
  end;

  RectInd := -1;
  for RectIndY := 0 to NumRectsY-1 do //***** loop along all Rects along Y-axis
  for RectIndX := 0 to NumRectsX-1 do //***** loop along all Rects along X-axis
  begin                   // (along Lists of Segments, associated with Rects)

  Inc(RectInd);
  if SegmInds[RectInd] = nil then Continue; // skip empty List
  if SegmInds[RectInd,0] = 2 then Continue; // skip List with one Segment

   // first element in SegmInds contains number Array elements, not Segm Index
  MaxInd := SegmInds[RectInd,0] - 1;

  for i := 1 to MaxInd do //***** external loop along all Segments in Rect List
  begin

    if (GlobCounter mod 100000) = 99999 then // Check if Progres info should be updated
    begin
      Percent := 1.0*(RectIndY*NumRectsX + RectIndX) / (NumRectsX*NumRectsY);
      N_CurShowStr( Format( 'Checking ... %.2f %s', [Percent,'%'] ) );
    end;

    //***** SegmentsData - array of all Segments (for all Rects) Data
    //  SegmInds[m,n] - index (in SegmentsData array) of n-th Segment in m-th Rect

    PSi := @SegmentsData[SegmInds[RectInd,i]];
    GetP12( PSi, P1i, P2i );

    for j := i+1 to MaxInd do //*** internal loop along all (i,j), i<j segment pairs
    begin
      Inc( GlobCounter );

      PSj := @SegmentsData[SegmInds[RectInd,j]];
      GetP12( PSj, P1j, P2j );

      //*** R1a, R2a are distance from P1j and P2j to PSi segm line

      R1a := PSi^.SA*P1j.X + PSi^.SB*P1j.Y + PSi^.SC;
      R2a := PSi^.SA*P2j.X + PSi^.SB*P2j.Y + PSi^.SC;

   //***** Check if P1j and P2j are stricly on different sides of PSi segm line
   //      if not, segments cannot be crossed or touched

      if (R1a > -SnapDist) and (R2a < SnapDist) or
         (R2a > -SnapDist) and (R1a < SnapDist)  then
      begin
        //*** Here:  i and j segments can be crossed or touched

        //*** R1b, R2b are distance from P1i and P2i to PSj segm line

        R1b := PSj^.SA*P1i.X + PSj^.SB*P1i.Y + PSj^.SC;
        R2b := PSj^.SA*P2i.X + PSj^.SB*P2i.Y + PSj^.SC;

   //***** Check if P1i and P2i are stricly on different sides of PSj segm line
   //      if not, segments cannot be crossed or touched

        if (R1b > -SnapDist) and (R2b < SnapDist) or
           (R2b > -SnapDist) and (R1b < SnapDist)  then
        begin         // crossed or touched, add them to CSEActions if needed
          //*** Here:  i and j segments are crossed or touched, process them if needed:
          //           - create needed CSEActions elem for adding new vertexex
          //           - add info about their position
          //           - add info about their position

          // get MaxSegmInd i,j to check if P1, P2 are Line endpoints or not

          SrcULines[PSi^.SULinesInd].GetPartInds( PSi^.SLineInd, 0, FirstInd, NInds );
          MaxSegmIndi := NInds - 2;

          SrcULines[PSj^.SULinesInd].GetPartInds( PSj^.SLineInd, 0, FirstInd, NInds );
          MaxSegmIndj := NInds - 2;

          AlreadyProcessed := False; // cur crossing was not processed yet

          //*** First check if segments are exactly the same

          if N_Same( P1i, P1j ) and N_Same( P2i, P2j ) or
             N_Same( P1i, P2j ) and N_Same( P2i, P1j ) then
          begin
            if (PSi^.SULinesInd = PSj^.SULinesInd) and
               (PSi^.SLineInd = PSj^.SLineInd) then
              AddCrossInfo( 1 ); // exactly the same segments inside one Line

            Continue; // skip same segments, they will be processed later,
          end;        // while removing common segments (common line fragments),
                      // splitting line should depend upon RC codes

           //*** reserve place for max possible actions (=16) for one crossings

          if Length(CSEActions) <= FreeActInd+16 then
            SetLength( CSEActions, N_NewLength( FreeActInd+16 ) );

          //*** check if segments are strilcly crossed, not touched:
          //    both points are stricly on different sides of both segm lines

          if ((R1a > SnapDist) and (R2a < -SnapDist) or
              (R2a > SnapDist) and (R1a < -SnapDist) ) and
             ((R1b > SnapDist) and (R2b < -SnapDist) or
              (R2b > SnapDist) and (R1b < -SnapDist) )   then // real crossing, not touching
          begin
            //*** real crossing, not touching,
            //    new Vertex should be added to both segments

// slash symbol at the end of statement prevents jumping up by Ctrl+Shift+Up
// to class definition in Delphi environment !!!
{
            CrossPoint := DPoint(0,0);
            if (PSi^.B*PSj^.A - PSj^.B*PSi^.A ) = 0 then
            begin
              N_d := 0;
              Continue;
            end;
}
            //*** Calculate CrossPoint - coords of segments crossing point

            if Abs(PSi^.SA) > Abs(PSi^.SB) then // PSi^.A <> 0
            begin
              CrossPoint.Y := ( PSj^.SA*PSi^.SC - PSi^.SA*PSj^.SC ) / (  // '/' should not be last symbol!
                                PSi^.SA*PSj^.SB - PSj^.SA*PSi^.SB );
              CrossPoint.X := -( PSi^.SB*CrossPoint.Y + PSi^.SC ) / PSi^.SA;
            end else //************************* PSi^.B <> 0
            begin
              CrossPoint.X := ( PSj^.SB*PSi^.SC - PSi^.SB*PSj^.SC ) / (  // '/' should not be last symbol!
                                PSi^.SB*PSj^.SA - PSj^.SB*PSi^.SA );
              CrossPoint.Y := -( PSi^.SA*CrossPoint.X + PSi^.SC ) / PSi^.SB;
            end;

            CrossPoint := N_SnapPointToGrid( DPoint(0,0),
                                     DPoint(SnapDist,SnapDist), CrossPoint );

            if SkipCrossing() then Continue;

            AddCrossInfo( 2 ); // real crossing
            AddAction( PSi, 0, csAddPoint );
            AddAction( PSj, 0, csAddPoint );
            Continue;
          end; // real crossing, not touching

          //***** Check, one by one, all possible touched segments positions
          //      ( one or both i-th segm endpoints can be near j-th segm.
          //        endpoints or the can be on "segm body" and far from endpoints )


          //***** Case 1: beg(P1) of Si segment is on Sj segment

          if ( N_P2SDistance( P1i, P1j, P2j ) < SnapDist ) then
          begin

            CrossPoint := P1i;
            if SkipCrossing() then Continue;

            AddCrossInfo( 3 ); // beg(P1) of Si segment is on Sj segment

            if (PSi^.SSegmInd and $3FFFFFFF) > 0 then // P1i is internal vertex
            begin
              AddAction( PSi, 0, csSplitLine ); // split at P1i
            end;

            if N_Same( P1i, P1j ) then // P1i = P1j
            begin
              if (PSj^.SSegmInd and $3FFFFFFF) > 0 then // P1j is internal vertex
                AddAction( PSj, 0, csSplitLine ); // split at P1j
            end else if N_Same( P1i, P2j ) then // P1i = P2j
            begin
              if (PSj^.SSegmInd and $3FFFFFFF) < MaxSegmIndj then // P2j is internal vertex
                AddAction( PSj, 1, csSplitLine ); // split at P2j
            end else // add P1i on j-th segment
              AddAction( PSj, 0, csAddPoint );

          end; // Case 1: beg(P1) of Si segment is on Sj segment


          //***** Case 2: end(P2) of Si segment is on Sj segment

          if ( N_P2SDistance( P2i, P1j, P2j ) < SnapDist ) then
          begin

            CrossPoint := P2i;
            if SkipCrossing() then Continue;

            AddCrossInfo( 4 ); // end(P2) of Si segment is on Sj segment

            if ((PSi^.SSegmInd and $3FFFFFFF) < MaxSegmIndi) and // P2i is internal vertex
                NotAdjacent() then
              AddAction( PSi, 1, csSplitLine ); // split at P2i

            if N_Same( P2i, P1j ) then // P2i = P1j
            begin
              if ((PSj^.SSegmInd and $3FFFFFFF) > 0) and // P1j is internal vertex
                  NotAdjacent() then
                AddAction( PSj, 0, csSplitLine ); // split at P1j
            end else if N_Same( P2i, P2j ) then // P2i = P2j
            begin
              if (PSj^.SSegmInd and $3FFFFFFF) < MaxSegmIndj then // P2j is internal vertex
                AddAction( PSj, 1, csSplitLine ); // split at P2j
            end else // add P2i on j-th segment
              AddAction( PSj, 0, csAddPoint );

          end; // Case 2: end(P2) of Si segment is on Sj segment


          //***** Case 3: beg(P1) of Sj segment is on Si segment

          if ( N_P2SDistance( P1j, P1i, P2i ) < SnapDist ) then
          begin

            CrossPoint := P1j;
            if SkipCrossing() then Continue;

            AddCrossInfo( 5 ); // beg(P1) of Sj segment is on Si segment

            if ((PSj^.SSegmInd and $3FFFFFFF) > 0) and // P1j is internal vertex
                NotAdjacent() then
              AddAction( PSj, 0, csSplitLine ); // split at P1j

            if N_Same( P1j, P1i ) then // P1j = P1i
            begin
              if (PSi^.SSegmInd and $3FFFFFFF) > 0 then // P1i is internal vertex
                AddAction( PSi, 0, csSplitLine ); // split at P1i
            end else if N_Same( P1j, P2i ) then // P1j = P2i
            begin
              if ((PSi^.SSegmInd and $3FFFFFFF) < MaxSegmIndi) and // P2i is internal vertex
                  NotAdjacent() then
                AddAction( PSi, 1, csSplitLine ); // split at P2i
            end else
              AddAction( PSi, 0, csAddPoint ); // add P1j on i-th segment

          end; // Case 3, beg(P1) of Sj segment is on Si segment


          //***** Case 4: end(P2) of Sj segment is on Si segment

          if ( N_P2SDistance( P2j, P1i, P2i ) < SnapDist ) then
          begin

            CrossPoint := P2j;
            if SkipCrossing() then Continue;

            AddCrossInfo( 6 ); // end(P2) of Sj segment is on Si segment

            if (PSj^.SSegmInd and $3FFFFFFF) < MaxSegmIndj then // P2j is internal vertex
              AddAction( PSj, 1, csSplitLine ); // split at P2j

            if N_Same( P2j, P1i ) then // P2j = P1i
            begin
              if (PSi^.SSegmInd and $3FFFFFFF) > 0 then // P1i is internal vertex
                AddAction( PSi, 0, csSplitLine ); // split at P1i
            end else if N_Same( P2j, P2i ) then // P2j = P2i
            begin
              if ((PSi^.SSegmInd and $3FFFFFFF) < MaxSegmIndi) then // P2i is internal vertex
                AddAction( PSi, 1, csSplitLine ) // split at P2i
            end else
              AddAction( PSi, 0, csAddPoint ); // add P2j on i-th segment

          end; // Case 4: end(P2) of Sj segment is on Si segment

        end; // if (R1b, R2b ...
      end; // if (R1a, R2a ... segments cannot be crossed or touched

    end; // for j := i+1 to MaxInd do - internal loop for checking i,j pairs
  end; // for i := 0 to MaxInd do - external loop for checking i,j pairs

  end; // for RectIndX,RectIndY; (RectInd from 0 to NumRectsX*NumRectsY-1) do - along all Rects

  Timer.SS( 'Crossings checking time', Str );

  if CrossingsInfoMode >= 1 then
  begin
    SL.Add( Str );
    SL.Add( Format( '    ***** End of  %d  Segments Crossing Data', [NumCrossed] ));

    SetLength( CrossInfo, FreeCrossInd );
    CollectStatistics( SL, Mode );
  end; // if CrossingsInfoMode >= 1 then

  Timer.Free();
end; // procedure TN_StructSegms.FindSegmCrossings

//****************************** TN_StructSegms.PerformActions ***
// Perform Actions in CSEActions array
// (add new vertexes and split lines)
//
procedure TN_StructSegms.PerformActions();
var
  i, j, InpItemInd, PrevALineInd, InpDCInd, OutDCInd: integer;
  NumPoints, NewItemInd, NewPartInd: integer;
  PActs: TN_PArray;
  CurLayer, OutLayer: TN_ULines;
  TmpLineItem: TN_ULinesItem;
  InpDC, OutDC: TN_DPArray;

  procedure FinishCurItem(); // local
  // copy rest points of cur Line (if any) as new Item of OutLayer
  begin
    NumPoints := High(InpDC) - InpDCInd + 1; // rest points of prev Item to copy
    if NumPoints > 0 then
    begin
      SetLength( OutDC, OutDCInd+NumPoints );
      move( InpDC[InpDCInd], OutDC[OutDCInd], NumPoints*Sizeof(InpDC[0]) );
      NewItemInd := -1;
      NewPartInd := 0;
      OutLayer.SetPartDCoords( NewItemInd, NewPartInd, OutDC );
    end; // if NumPoints > 0 then
  end; // procedure FinishCurItem(); // local

  procedure FinishCurLayer(); // local
  // copy rest of CurLayer to OutLayer and back to CurLayer
  var
    i: integer;
  begin
    if CurLayer = nil then Exit;

    FinishCurItem();

    for i := InpItemInd to CurLayer.WNumItems-1 do // copy rest of Items
      OutLayer.AddULItem( CurLayer, i, 0, -1, TmpLineItem );

    OutLayer.CompactSelf();
    CurLayer.CopyFields( OutLayer ); // copy back, CurLayer is updated OK
  end; // procedure FinishCurLayer(); // local

begin //************************ body of TN_StructSegms.PerformActions
  if FreeActInd = 0 then Exit; // no Actions to perform

  PrevALineInd := -1;
  InpItemInd := 0;
  InpDCInd := 0;
  OutDCInd := 0;
  CurLayer := nil;
  OutLayer := nil;
  TmpLineItem := nil;
  SetLength( PActs, FreeActInd );

  for i := 0 to High(PActs) do // fill PActs array
    PActs[i] := @CSEActions[i];

  N_SortPointers( PActs, 0, N_Compare3IntsAndDouble );

  for i := 0 to High(PActs) do // perform all PActs Actions
  with TN_PCSEAction(PActs[i])^ do
  begin
    // Skip exactly the same Actions (they can be created)
    if (i > 0) and CompareMem( PActs[i-1], PActs[i], 24 ) then Continue;

    if (CurLayer <> SrcULines[AULinesInd]) then // CurLayer changed
    begin
      FinishCurItem();

      CurLayer := SrcULines[AULinesInd]; // new current CObj Layer
      OutLayer.Free;
      OutLayer := TN_ULines.Create2( CurLayer );
      TmpLineItem.Free;
      TmpLineItem := TN_ULinesItem.Create( CurLayer.WLCType );
      InpItemInd := 0;
      PrevALineInd := -1;
    end; // if (CurLayer <> AULines) then // CurLayer changed

    if PrevALineInd <> ALineInd then // ALineInd changed, copy rest points and
    begin                            // prepare InpDC by ALineInd
      FinishCurItem();

      PrevALineInd := ALineInd;
      CurLayer.GetPartDCoords( ALineInd, 0, InpDC );
      InpDCInd := 0;
      OutDCInd := 0;
    end; // if PrevALineInd <> ALineInd then

    for j := InpItemInd to ALineInd-1 do // copy Items (if any) before ALineInd
      OutLayer.AddULItem( CurLayer, j, 0, -1, TmpLineItem );

    InpItemInd := ALineInd + 1; // first not processed Item

    NumPoints := AVertSegmInd - InpDCInd + 1; // points to copy before Action

    if Length(OutDC) < OutDCInd+NumPoints+2 then
      SetLength( OutDC, OutDCInd+NumPoints+2 );

    if NumPoints > 0 then
    begin
      move( InpDC[InpDCInd], OutDC[OutDCInd], NumPoints*Sizeof(InpDC[0]) );
      Inc( InpDCInd, NumPoints );
      Inc( OutDCInd, NumPoints );
    end; // if NumPoints > 0 then

    //***** Here: all needed previous objects are copied to OutLayer

    case ActionType of

    csAddPoint: // add new Vertex and split Line at it
    begin
      OutDC[OutDCInd] := ANewVertex;
      NewItemInd := -1;
      NewPartInd := 0;              
      SetLength( OutDC, OutDCInd+1 );
      OutLayer.SetPartDCoords( NewItemInd, NewPartInd, OutDC );

      OutDC[0] := ANewVertex;
      OutDCInd := 1;
    end; // csAddPoint - add new Vertex and split Line at it

    csSplitLine: // split Line at AVertSegmInd Vertex (ANewVertex not used)
    begin
      NewItemInd := -1;
      NewPartInd := 0;
      SetLength( OutDC, OutDCInd );
      OutLayer.SetPartDCoords( NewItemInd, NewPartInd, OutDC );

      if InpDCInd <= High(InpDC) then // InpDC not finished yet
      begin
        OutDC[0] := OutDC[OutDCInd-1];
        OutDCInd := 1;
      end else
        OutDCInd := 0;
    end; // csAddPoint - add new Vertex and split Line at it

    end; // case ActionType of
  end; // for i := 0 to High(PActs) do // perform all PActs Actions

  //***** Here: no more actions, finish last layer
  FinishCurLayer();

end; //*** end of procedure TN_StructSegms.PerformActions


//**********************  TN_NodesObj class  ***********

//*************************************** TN_NodesObj.AddOneULines
// Add One ULines to ULinesArray and to GItems
//
procedure TN_NodesObj.InitNodesObj();
begin
  NumULines := 0;
  NumGItems := 0;
  NumEndPoints := 0;
  NumNodes := 0;
end; // procedure TN_NodesObj.InitNodesObj

//*************************************** TN_NodesObj.AddOneULines
// Add One ULines to ULinesArray and to GItems
//
procedure TN_NodesObj.AddOneULines( AULines: TN_Ulines );
var
  i, GItemInd, FirstInd, NumItems, NumInds: integer;
begin
  if Length(ULinesArray) < NumULines+1 then
    SetLength( ULinesArray, N_NewLength( NumULines+1 ) );

  ULinesArray[NumULines] := AULines;
  NumItems := AULines.WNumItems;

  if Length(GItems) < NumGItems+NumItems then
    SetLength( GItems, N_NewLength( NumGItems+NumItems ) );

  GItemInd := NumGItems;

  with AULines do
  for i := 0 to NumItems-1 do // along AULines Items
  begin
    GetItemInds( i, FirstInd, NumInds );
    if NumInds = 0 then continue; // skip empty Items

    GItems[GItemInd].GIULinesInd := NumULines;
    GItems[GItemInd].GIItemInd   := i;
    GItems[GItemInd].GIFlags := WLCType and N_DoubleCoords;

    Inc( GItemInd );
  end; // for i := 0 to WNumItems-1 do // along AULines Items

  Inc( NumULines );
  NumGItems := GItemInd;
end; // procedure TN_NodesObj.AddOneULines

//*************************************** TN_NodesObj.CollectEndPoints
// Process all GItems elements and fill EndPoints elements
// (two Endpoints per each Item)
//
procedure TN_NodesObj.CollectEndPoints();
var
  i, FirstInd, NumInds: integer;
  ULines: TN_ULines;
begin
  NumEndPoints := 2 * NumGItems;

  SetLength( EndPoints, NumEndPoints );

  for i := 0 to NumGItems-1 do // along all GItems, collect theirs Endpoints
  with GItems[i] do
  begin
    ULines := ULinesArray[GIULinesInd];
    ULines.GetPartInds( GIItemInd, 0, FirstInd, NumInds );

    with EndPoints[2*i] do // Beg Point
    begin
      if (GIFlags and N_DoubleCoords) <> 0 then // double coords
        EPCoords := ULines.LDCoords[FirstInd]
      else
        EPCoords := DPoint( ULines.LFCoords[FirstInd] );

      EPGItemInd := i;
      EPFlags    := N_EPBegPoint;
    end; // with EndPoints[2*i] do // Beg Point

    with EndPoints[2*i+1] do // End Point
    begin
      if (GIFlags and N_DoubleCoords) <> 0 then // double coords
        EPCoords := ULines.LDCoords[FirstInd+NumInds-1]
      else
        EPCoords := DPoint( ULines.LFCoords[FirstInd+NumInds-1] );

      EPGItemInd := i;
      EPFlags    := 0;
    end; // with EndPoints[2*i+1] do // End Point

    GIWSize := N_CalcSegmLengths( @ULines.LDCoords[FirstInd], NumInds,
                                                              GISegmLengths );
  end; // for i := 0 to NumGItems-1 do // along all GItems, collect theirs Endpoints

  //***** Create EPPtrs - Pointers to Endpoints - and sort it

  SetLength( EPPtrs, NumEndPoints );

  for i := 0 to NumEndPoints-1 do // fill EPPtrs array
    EPPtrs[i] := @EndPoints[i];

  N_SortPointers( TN_PArray(EPPtrs), 0, N_CompareDPoints ); // sort Ptrs

  //***** fill SPtrInd field in Segms Array

  for i := 0 to NumEndPoints-1 do // fill EndPoints[].EPPtrsInd fields
    EPPtrs[i]^.EPPtrsInd := i;

end; // procedure TN_NodesObj.CollectEndPoints

//*************************************** TN_NodesObj.CollectNodesLines
// Check Endpoints coords and collect lines with same Endpoints in Lists
// (fill Nodes elemenets)
//
procedure TN_NodesObj.CollectNodesLines();
var
  i, NodeInd, CurEPInd, BegEPInd, NumSamePoints: integer;
  CurEPCoords: TDPoint;
begin
  SetLength( Nodes, N_NewLength( NumEndPoints div 2 ) ); // initial value
  BegEPInd := 0;
  NodeInd  := 0;

  while True do // along all EPPtrs elements, collect lines with same Endpoints
  begin

    CurEPCoords := EPPtrs[BegEPInd]^.EPCoords;
    CurEPInd := BegEPInd + 1;

    while True do // continue, if next Endpoint has CurEPCoords coords
    begin
      if CurEPInd = NumEndPoints then Break;
      if not N_Same( CurEPCoords, EPPtrs[CurEPInd]^.EPCoords ) then Break;

      Inc( CurEPInd ); // check next Endpoint
    end; // while True do // continue, if next Endpoint has CurEPCoords coords

    //*** Here: BegEPInd - index of first Endpoint
    //          CurEPInd - index of Last  Endpoint + 1

    NumSamePoints := CurEPInd - BegEPInd;

    if Length(Nodes) < NodeInd+1 then
      SetLength( Nodes, N_NewLength( NodeInd+1 ) );

    with Nodes[NodeInd] do
    begin
      NCoords := CurEPCoords;  // Node Coords
      SetLength( NLines, NumSamePoints );

      for i := 0 to NumSamePoints-1 do
      with NLines[i], EPPtrs[BegEPInd+i]^ do
      begin
        X := EPGItemInd;
        Y := EPFlags;
      end; // with NLines[i] do, for i := 0 to NumSamePoints-1 do

    end; // with Nodes[NodeInd] do

    if CurEPInd = NumEndPoints then Break; // no more Endpoints, all Nodes collected

    BegEPInd := CurEPInd; // to next Endpoint
    Inc( NodeInd );

  end; // while True do // along all EPPtrs elements, collect lines with same Endpoints

  NumNodes := NodeInd;

end; // procedure TN_NodesObj.CollectNodesLines

//*************************************** TN_NodesObj.RemoveNearLines ***
// Remove from given ADstULines all but one Items with same Endpoints
// and which are near each other (less then given ADist);
// add to Item that remain all Codes from Removed Items
//
function TN_NodesObj.RemoveNearLines( ADstULines: TN_ULines; ADist: double;
                                      ASL: TStrings; AMode: integer ): integer;
var
  i, j, ItemInd1, ItemInd2, PFirstInd1, NumInds1, PFirstInd2, NumInds2: integer;
  NumCodesInts1, NumCodesInts2: integer;
  Str: string;
  PCodes2: PInteger;
  CurDist: double;
  SameDirection: boolean;
  WrkPDPoint: PDPoint;
  WrkLengths: TN_DArray;
  ReversedCoords: TN_DPArray;
  WrkCodes: TN_IArray;
begin
  Result := 0;
  WrkLengths := nil; // to avoid warning
  ReversedCoords := nil; // to avoid warning

  for i := 0 to NumNodes-1 do // along all Nodes
  with Nodes[i] do
  begin
    if i = 3 then // debug
      N_i := 1;

    if AMode >= 3 then // full info about all Nodes Lines
    begin
      ASL.Add( Format( 'NodeInd=%.3d, (X=%.7g, Y=%.7g) NumLines=%d',
                               [i, NCoords.X, NCoords.Y, Length(NLines)] ));

      for j := 0 to High(NLines) do // along all i-th Node lines
      begin
        ItemInd1 := GItems[NLines[j].X].GIItemInd;
        if (i=7) and( ItemInd1 = 328) then // debug
          N_i := 1;

        Str := ADstULines.GetItemAllCodes( ItemInd1 );
        ASL.Add( Format( '  ItemInd=%.3d, Codes: %s', [ItemInd1, Str] ));
      end; // for j := 0 to High(NLines) do // along all i-th Node lines
    end; // if AMode >= 3 then // full info about all Nodes Lines

    ItemInd1 := GItems[NLines[0].X].GIItemInd;
    ADstULines.GetItemInds( ItemInd1, PFirstInd1, NumInds1 );

    if NumInds1 = 0 then // skip already processed Items
    begin
      N_i := 1;
      Continue; // to next Node
    end;

    ADstULines.GetItemAllCodes( ItemInd1, WrkCodes, NumCodesInts1 );

    for j := 1 to High(NLines) do // along all i-th Node lines except first
    begin
      ItemInd2 := GItems[NLines[j].X].GIItemInd;
      ADstULines.GetItemInds( ItemInd2, PFirstInd2, NumInds2 );

      if NumInds2 = 0 then // skip already processed Items
        Continue;

      WrkLengths := GItems[NLines[j].X].GISegmLengths;

      //*** define, if 0-th and j-th Items have same direction
      SameDirection := (NLines[0].Y xor NLines[j].Y and N_EPBegPoint) = 0;

      if SameDirection then
      begin
        WrkLengths := GItems[NLines[j].X].GISegmLengths;
        WrkPDPoint := @ADstULines.LDCoords[PFirstInd2];
      end else // not SameDirection, compare with reverse points order
      begin
        WrkLengths := Copy( GItems[NLines[j].X].GISegmLengths, 0, 100000 );
        ReversedCoords := Copy( ADstULines.LDCoords, PFirstInd2, NumInds2 );

        N_ReverseDoubles( WrkLengths );
        N_ReversePoints( ReversedCoords );
        WrkPDPoint := @ReversedCoords[0];
      end; // else - not SameDirection

      // Calc distance between 0-th and j-th Items

      CurDist := N_Line2LineDist( @ADstULines.LDCoords[PFirstInd1], WrkPDPoint,
                                  NumInds1, NumInds2,
                                  GItems[NLines[0].X].GISegmLengths, WrkLengths,
                       GItems[NLines[0].X].GIWSize, GItems[NLines[j].X].GIWSize,
                                  2.0, 10, 0 );

      if CurDist < ADist then // Item is near, remove j-th Item and add codes
      begin
        ADstULines.GetItemAllCodes( ItemInd2, PCodes2, NumCodesInts2 );
        N_AddOrderedInts( WrkCodes, NumCodesInts1, PCodes2, NumCodesInts2, 0 );
        ADstULines.SetEmptyFlag( ItemInd2 ); // remove Item
        Inc( Result );

        if AMode >= 2 then // full statistics
        begin
          ASL.Add( Format( 'I1=%.3d, I2=%.3d,  Dist=%.4g', [ItemInd1, ItemInd2, CurDist] ));
        end; // if AMode >= 2 then

      end; // if CurDist < ADstULines then // remove j-th Item and add codes

    end; // for j := 1 to High(NLines) do // along all lines except first

    ADstULines.SetItemAllCodes( ItemInd1, @WrkCodes[0], NumCodesInts1 );

  end; // for i := 0 to NumNodes-1 do // along all Nodes

  if AMode >= 1 then
    ASL.Add( Format( '%d Lines Removed', [Result] ) );

end; // procedure TN_NodesObj.RemoveNearLines

//*************************************** TN_NodesObj.CombineLines ***
// Combine adjacent Items with same Codes in given AULines
// Return number of Combined Items
//
function TN_NodesObj.CombineLines( AULines: TN_ULines; ASL: TStrings;
                                                     AMode: integer ): integer;
var
  i: integer;
  VertexRefs: TN_VertexRefs;
begin
  Result := 0;
  SetLength( VertexRefs, 2 );

  for i := 0 to NumNodes-1 do // along all Nodes
  with Nodes[i] do
  begin
    if Length(NLines) = 2 then // two lines in Node
    begin
      VertexRefs[0].ItemInd := GItems[NLines[0].X].GIItemInd;
      VertexRefs[0].VertInd := NLines[0].Y xor $01; // 0 - Beg Vertex, <> 0 - LastVertex
      VertexRefs[1].ItemInd := GItems[NLines[1].X].GIItemInd;
      VertexRefs[1].VertInd := NLines[1].Y xor $01; // 0 - Beg Vertex, <> 0 - LastVertex

      if -1 <> AULines.CombineItems( VertexRefs ) then // Combined OK
      begin
        Inc( Result );

        if AMode >= 2 then // full statistics
          ASL.Add( Format( 'I1=%.3d, I2=%.3d',
                           [VertexRefs[0].ItemInd, VertexRefs[1].ItemInd] ));
      end; // if -1 <> AULines.CombineItems( VertexRefs ) then // Combined OK

    end; // if Length(NLines) = 2 then // two lines in Node
  end; // for i := 0 to NumNodes-1 do // along all Nodes

  if AMode >= 1 then
    ASL.Add( Format( '  %d Lines Combined', [Result] ) );

end; // function TN_NodesObj.CombineLines

//*************************************** TN_NodesObj.CheckNodesLinesCodes ***
// Check if number of lines with same code in any node is even
// return number Error Nodes
//
function TN_NodesObj.CheckNodesLinesCodes( ASL: TStrings; AMode: integer ): integer;
var
  i, j, CurItemInd, CurNumCodesInts, AllNumCodesInts: integer;
  DimInd, Code, NumLines: integer;
  WasError: boolean;
  CurPCodes: PInteger;
  NodeCodes: TN_IArray;
  CurULInes: TN_ULines;

  function GetNumLinesByCode( ANodeInd, ABinCode: integer ): integer; // local
  // Return Number of Lines with given Code in given Node
  var
    k, NumCodesInts, Ind: integer;
    LineCodes: TN_IArray;
  begin
    with Nodes[ANodeInd] do
    begin
      Result := 0;

      for k := 0 to High(NLines) do // along all lines for ANodeInd node
      begin
        CurULInes := ULinesArray[GItems[NLines[k].X].GIULinesInd];
        CurItemInd := GItems[NLines[k].X].GIItemInd;
        CurULInes.GetItemAllCodes( CurItemInd, LineCodes, NumCodesInts );

        Ind := N_SearchInIArray( ABinCode, LineCodes, 0, NumCodesInts-1 );
        if Ind <> -1 then Inc( Result );

      end; // for k := 0 to High(NLines) do // along all lines for ANodeInd node

    end; // with Nodes[i] do
  end; // function GetNumLinesByCode - local

begin
  Result := 0;

  for i := 0 to NumNodes-1 do // along all Nodes
  with Nodes[i] do
  begin
    // Collect all codes for all Lines in i-th Node in NodeCodes
    AllNumCodesInts := 0;

    for j := 0 to High(NLines) do // along all i-th Node lines
    begin
      CurULInes := ULinesArray[GItems[NLines[j].X].GIULinesInd];
      CurItemInd := GItems[NLines[j].X].GIItemInd;

      CurULInes.GetItemAllCodes( CurItemInd, CurPCodes, CurNumCodesInts );
      N_AddOrderedInts( NodeCodes, AllNumCodesInts, CurPCodes, CurNumCodesInts, 0 );
    end; // for j := 1 to High(NLines) do // along all i-th Node lines

    WasError := False;

    for j := 0 to AllNumCodesInts-1 do // along all collected codes
    begin
      NumLines := GetNumLinesByCode( i, NodeCodes[j] );

      if (NumLines and $01) <> 0 then // Odd number of Lines - error
      begin
        WasError := True;

        if AMode >= 2 then // full statistics
        begin
          N_DecodeCObjCodeInt( NodeCodes[j], DimInd, Code );

          ASL.Add( Format( 'i=%.3d (X=%.7g, Y=%.7g) CDim=%.2d Code=%.4d NumLines=%d',
          [i, NCoords.X, NCoords.Y, DimInd, Code, NumLines] ));
        end; // if AMode >= 2 then
      end; // if (NumLines and $01) <> 0 then // Odd number of Lines - error

    end; // for j := 0 to AllNumCodesInts-1 do // along all collected codes

    if WasError then Inc( Result );

  end; // for i := 0 to NumNodes-1 do // along all Nodes

  if AMode >= 1 then
    ASL.Add( Format( '%d Error Nodes', [Result] ) );

end; // function TN_NodesObj.CheckNodesLinesCodes


//*********************  Global procedures  ********************

//******************************************************* N_RemoveNearLines ***
//
function N_RemoveNearLines( InpULines, OutULines: TN_ULines; ADist: double;
                                       ASL: TStrings; AMode: integer ): integer;
var
  NodesObj: TN_NodesObj;
begin
  NodesObj := TN_NodesObj.Create;
  OutULines.CopyCoords( InpULines );

  with NodesObj do
  begin
    AddOneULines( InpULines );
    CollectEndPoints();
    CollectNodesLines();
    Result := RemoveNearLines( OutULines, ADist, ASL, AMode );
  end; // with NodesObj do

  NodesObj.Free;
end; // function N_RemoveNearLines

//************************************************ N_SmoothByRemovingPoints ***
// Smooth ULines by removing Points
//
// InpULines - Sorce ULines to Smooth
// OutULines - Resulting Ulines
// Mode      - not used now
// AMinDist  - initial min possible segment size
// AMaxDist  - final min possible segment size
// ACoef     - Coef by which min possible segment size increases from pass to pass
// ASL       - Protocol TStrings
// AMode     - if (AMode and $0F) > 0 then add to ASL number of points on input and output
//
function N_SmoothByRemovingPoints( InpULines, OutULines: TN_ULines;
                                   AMinDist, AMaxDist, ACoef: double;
                                   ASL: TStrings; AMode: integer ): double;
var
  NumInpPoints, NumOutPoints: integer;
begin
  Result := 100;
  with InpULines do
    NumInpPoints := Items[WNumItems].CFInd; // approximate number of Inp Points

  if NumInpPoints = 0 then Exit; // a precaution

  OutULines.CopyCoords( InpULines );
  if ACoef = 0 then ACoef := 1.5; // default value

  OutULines.SmoothSelf( AMode shr 4, AMinDist, AMaxDist, ACoef );

  with OutULines do
    NumOutPoints := Items[WNumItems].CFInd; // approximate number of Out Points

  Result := 100.0*NumOutPoints / NumInpPoints;

  if (AMode and $0F) > 0 then
  begin
    ASL.Add( Format( 'Num Inp,Out Points: %d, %d (%.1f%s)',
                                [NumInpPoints, NumOutPoints, Result, '%'] ) );
  end; // if (AMode and $0F) > 0 then

end; // function N_SmoothByRemovingPoints

//************************************************ N_CheckSegmentsCrossings ***
// Check Segments Crossings of InpULines and add crossed segments to OutULines
// Return created TN_StructSegms Obj, used for Crossings checking
//
function N_CheckSegmentsCrossings( InpULines, OutULines: TN_ULines;
                                   ANumXY: integer; AIncCoef: double;
                                ASL: TStrings; AMode: integer ): TN_StructSegms;
begin
  Result := TN_StructSegms.Create();

  if ANumXY = 0 then ANumXY := 100;

  with Result do
  begin
    CrossSegms := OutULines;
    AddOneULines( InpULines );
    StructAllSegments( ANumXY, -1, AIncCoef );
    FindSegmCrossings( ASL, AMode );
  end; // with Result do
end; // function N_CheckSegmentsCrossings

//******************************************************* N_CheckLinesCodes ***
// Check Codes of Lines, that belongs to one Node
// Number of Lines that has some code in one Node should be even
//
function N_CheckLinesCodes( AULines: TN_ULines;
                                      ASL: TStrings; AMode: integer ): integer;
var
  NodesObj: TN_NodesObj;
begin
  NodesObj := TN_NodesObj.Create;

  with NodesObj do
  begin
    AddOneULines( AULines );
    CollectEndPoints();
    CollectNodesLines();
    Result := CheckNodesLinesCodes( ASL, AMode );
  end; // with NodesObj do

  NodesObj.Free;

  if AMode >= 1 then
    ASL.Add( Format( '  Check LinesCodes: %d Errors', [Result] ) );
end; // function N_CheckLinesCodes

//******************************************************* N_CombineLines ***
// Combine Lines with same codes
// Return number of combined Lines (Items)
//
// ANumPases - Number of Pases, ANumPases=0 means processing
//             while Number of combined Items in last pass = 0
//
function N_CombineLines( AULines: TN_ULines; ANumPases: integer;
                                      ASL: TStrings; AMode: integer ): integer;
var
  PasNumber, CurRes: integer;
  NodesObj: TN_NodesObj;
begin
  NodesObj := TN_NodesObj.Create;
  Result := 0;
  PasNumber := 1;

  while True do // perform given number of pases
  begin

    with NodesObj do
    begin
      InitNodesObj();
      AddOneULines( AULines );
      CollectEndPoints();
      CollectNodesLines();
      CurRes := CombineLines( AULines, ASL, AMode );
    end; // with NodesObj do

    Inc( Result, CurRes );

    if (CurRes = 0) or
       ( (ANumPases > 0) and (PasNumber >= ANumPases) ) then Break;

    Inc( PasNumber );
  end; // while True do // perform given number of pases

  NodesObj.Free;

  if AMode >= 1 then
    ASL.Add( Format( '    Total - %d Lines Combined', [Result] ) );
end; // function N_CombineLines

//********************************************************* N_MoveCObjCodes ***
// Move CObj Codes from ACDim1 to another ACDim2, on output remains no Codes
// in ACDim1 and all previous Codes in ACDim2 are lost
// ACDim2 = -1 means just remove codes from ACDim1
//
function N_MoveCObjCodes( ACObj: TN_UCObjLayer; ACDim1, ACDim2: integer;
                                       ASL: TStrings; AMode: integer ): integer;
var
  i, NumAllCodesInts, CDimOffset, CDim1NumCodes, CDim2NumCodes: integer;
  WrkCDimCodes, WrkAllCodes: TN_IArray;
begin
  Result := 0;

  with ACObj do
  for i := 0 to WNumItems-1 do // along all ACObj Items
  begin
    GetItemAllCodes( i, WrkAllCodes, NumAllCodesInts );
    if NumAllCodesInts = 0 then Continue; // nothing to move

    //***** Check ACDim1 Codes

    N_GetCDimCObjCodes( @WrkAllCodes[0], NumAllCodesInts, ACDim1,
                                                CDimOffset, CDim1NumCodes );
    SetLength( WrkCDimCodes, NumAllCodesInts ); // more than needed

    if CDim1NumCodes > 0 then // ACDim1 Codes exist
    begin
      move( WrkAllCodes[CDimOffset], WrkCDimCodes[0], CDim1NumCodes*Sizeof(Integer) );

      // Clear ACDim1Codes in WrkAllCodes Array

      N_ReplaceArrayElems( WrkAllCodes, CDimOffset, CDim1NumCodes,
                           NumAllCodesInts, @WrkCDimCodes[0], 0 );
    end; // if CDim1NumCodes > 0 then // ACDim1 Codes exist

    if ACDim2 = -1 then
    begin
      SetItemAllCodes( i, @WrkAllCodes[0], NumAllCodesInts ); // set Resulting Codes
      Continue;
    end;

    //***** Check ACDim2 Codes

    N_GetCDimCObjCodes( @WrkAllCodes[0], NumAllCodesInts, ACDim2,
                                                CDimOffset, CDim2NumCodes );

    // Replace old CDim2 codes by saved CDim1Codes from WrkCDimCodes

    N_ReplaceArrayElems( WrkAllCodes, CDimOffset, CDim2NumCodes,
                         NumAllCodesInts, @WrkCDimCodes[0], CDim1NumCodes );

    SetItemAllCodes( i, @WrkAllCodes[0], NumAllCodesInts ); // set Resulting Codes

  end; // for i := 0 to WNumItems-1 do

end; // function N_MoveCObjCodes

//********************************************************* N_XORCObjCodes ***
// XOR CObj Codes:
// for all Ittems, that posess ACDim ACode1, XOR given ACDim ACode2
//
function N_XORCObjCodes( ACObj: TN_UCObjLayer; ACDim, ACode1, ACode2: integer;
                                       ASL: TStrings; AMode: integer ): integer;
var
  i, CodeInt1, CodeInt2: integer;
  Str1, Str2: string;
begin
  Result := 0;

  if AMode >= 1 then
  begin
    ASL.Add( '' );
    ASL.Add( Format( '  CDimInd=%.2d  SearchCode=%.4d  XOR Code=%.4d',
                                [ACDim, ACode1, ACode2] ) );
  end; // if AMode >= 1 then

  CodeInt1 := N_EncodeCObjCodeInt( ACDim, ACode1 );
  CodeInt2 := N_EncodeCObjCodeInt( ACDim, ACode2 );

  with ACObj do
  for i := 0 to WNumItems-1 do // alonf all ACObj Items
  begin
    if ItemHasCode( i, CodeInt1 ) then
    begin
      if AMode >= 2 then
        Str1 := GetItemAllCodes( i );

      AddXORItemCode( i, @CodeInt2, 1, 1 );
      Inc( Result );

      if AMode >= 2 then
      begin
        Str2 := GetItemAllCodes( i );
        Str1 := Format( 'ItemInd=%.3d Before="%s"  After="%s"', [i, Str1, Str2] );
        ASL.Add( Str1 )
      end;
    end;
  end; // for i := 0 to WNumItems-1 do

  if AMode >= 1 then
    ASL.Add( Format( '  XOR CObj Codes: %d Items Changed', [Result] ) );
end; // function N_XORCObjCodes

Initialization
  N_AddStrToFile( 'N_Gra4 Initialization' );

end.
