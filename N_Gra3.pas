unit N_Gra3;
// middle level Graphic procedures (mainly class methods)

interface
uses
  Windows, Classes, Graphics, StdCtrls,
  K_UDT1, K_Script1,
  N_UDat4, N_Types, N_Lib1, N_Gra0, N_Gra1, N_Gra2;

type TN_BLineRef = record //***** reference to Border Line
  UDLInd: integer;  // index of Border Line in UDLineRefs array
  BLFlags: integer; // Border Line flags:
           // bit0 - line direction in Ring (internal area is to the right):
           //    =0 - straight direction (internal area is to the right)
           //    =1 - inverse direction (internal area is to the left)
           // bit16 =1 line was already assembled in Ring (blUsedFlag = $010000)
  IndPtrBegS1: integer; // Index of Pointer to Beg Segment in PtrsBESegment1 array
  IndPtrEndS1: integer; // Index of Pointer to End Segment in PtrsBESegment1 array
end; // type TN_BLineRef = record
type TN_BLineRefs = array of TN_BLineRef;

type TN_SegmPair = record //***** Two segments info
  LineInd1: integer; // Line index in UDLineRefs to which first segment belongs
  SegmInd1: integer; // first Segment index in LineInd1 UDLine
  LineInd2: integer; // Line index in UDLineRefs to which second segment belongs
  SegmInd2: integer; // second Segment index in LineInd2 UDLine
  SPFlags:  integer; // Two Segments type flags:
      // bit0($001) - first segment direction
      // bit1($002) - second segment direction
      // bits4-5($030) - index of one corrected Point (if any)
      //           (0 - Beg Segm1, 1 - End Segm1, 2 - Beg Segm2, 3 - End Segm2)
      // bit6($040) =0 - all points remains the same (bits4-5 not used)
      //            =1 - point coords with index in bits4-5 were changed
end; // type TN_SegmPair = record
type TN_SegmPairs = array of TN_SegmPair;

type TN_LineSegment = record //***** Line Segment data
  P1, P2:  TDPoint; // Line Segment's end points
  A, B, C: double;  // Segment's Line coefs: A*x + B*y + C = 0
  LineInd: integer; // Line index in UDLineRefs to which Segment belongs
  SegmInd: integer; // Segment index in LineInd UDLine
  LSFlags: integer; // Line Segment Flags:
           // bit0 - Line Segment direction (=0 - straight, =1 - reversed)
end; // type TN_LineSegment = record
type TN_LineSegments = array of TN_LineSegment;

type TN_UDLPoint = record //***** UDLine Point
  PC: TDPoint;        // Point Coords
  IndUDLine: integer; // Index of UDLine with this point in UDLineRefs array
  IndPoint: integer;  // Index of Point in UDLine
end; // type TN_UDLPoint = record

type TN_BESegment = record //***** Beg or End line Segment Info
  BEPoint: TDPoint;  // Beg or End Point coords
  Angle: double;     // segment Angle in radians, in (-PI, PI] interval
  LineInd: integer;  // Line index in Lines array
  BESFlags: integer; // Beg or End Point segment  flags
           // bit0 - segment type ( Beg (first) or End (last) )
           //    =0 - Beg segment ( BEPoint = Blines[BLineInd].Dline.DC[0] )
           //    =1 - End segment ( BEPoint = Blines[BLineInd].Dline.DC[Hig(DC)] )
end; // type TN_BESegment = record
type TN_BESegments = array of TN_BESegment;
type TN_PtrsBESegment = array of ^TN_BESegment; // pointers to sort

type TN_UDLineRef = record //***** reference to TN_UDDLine, it's flags and
                    //  Indexes of Pointers to Beg and End Point segments Info
//  UDLine: TN_UDDLine;
//  LFPInd: integer;   // Line's First Point Index in LCoords array
//  NumInds: integer;  // Number of Indexes in LCoords array (NumPoints in Line)
//  UDLFlags: integer;
  IndPtrBegS: integer; // Index of Pointer to Beg Segment in PtrsBESegment array
  IndPtrEndS: integer; // Index of Pointer to End Segment in PtrsBESegment array
end; // type TN_UDLineRef = record
type TN_UDLineRefs = array of TN_UDLineRef;

type TN_LineSegmentRef = record
  LineInd: integer;
  SegmInd: integer;
end; // type TN_LineSegmentRef = record
type TN_LineSegmentRefs = array of array of TN_LineSegmentRef;

type TN_LSStatistics = record //***** statistics for TN_LineSegmentsLists obj
    NotEmptyRectsRatio: double; // =0 - all Rects empty; =1.0 - all filled
    SegmRefsSize: integer;   // whole number of elements in all SegmRefs
    AverageListSize: double; // SegmRefsSize / (number of filled Rects)
    MaxListSize: integer;    // Max ListSize for some Rect
    NumComparisons: integer; // needed number of comparisons (pairs of Segments)
    NumSegments: integer;    // whole number of segments
end; // type TN_LSStatistics = record

type TN_LineSegmentsLists = class( TObject ) //***
  public
    EnvDRect: TDRect;    // Envelope DRect of all Rects
    NumRectsX: integer;  // Number of rects in X direction
    NumRectsY: integer;  // Number of rects in Y direction
    NumRects:  integer;  // whole Number of rects (NumRectsX*NumRectsY)
    RectsWidth: double;   // all rects Width (EnvDRectWidth/NumRectsX)
    RectsHeight: double;  // all rects Height (EnvDRectHeight/NumRectsY)
    SegmRefs: TN_LineSegmentRefs; // lists ( may be empty) of references
                                  // to Line Segments (one list per Rect)
    SegmRefsCounts: TN_IArray; // counts of references in SegmRefs lists
    StatData: TN_LSStatistics;

    constructor Create ( const AEnvDRect: TDRect; const NumX, NumY: integer );
    destructor  Destroy; override;
    procedure AddLineSegmInds ( const RectInd, ALineInd, ASegmInd: integer );
    procedure AddLineSegment  ( const Point1, Point2: TDPoint;
                                           const LineInd, SegmInd: integer );
    procedure CollectStatistics ();
    procedure ShowStatistics    ();
end; // type TN_LineSegmentsLists = class( TObject )

type TN_BLineIndFlags = record //***** reference to Border Line
  UDLInd: integer; // index of Border Line in UDLineRefs array
  BLFlags: integer;    // Border Line flags:
           // bit0 - line direction in Ring (internal area is to the right):
           //    =0 - straight direction (internal area is to the right)
           //    =1 - inverse direction (internal area is to the left)
           // bit16 =1 line was already assembled in Ring (blUsedFlag = $010000)
end; // type TN_BLineIndFlags = record
type TN_BLineIFs = array of TN_BLineIndFlags;

type TN_MCRing = record //***** Memory Contour Ring
  Flags: integer;
  EnvDRect: TFRect;
  BegBLineInd: integer;
  NumBLines: integer;
  Level: integer;
  RCoords: TN_DPArray;
  ChildRingInds: TN_IArray;
end; // type TN_MCRing = record
type TN_MCRings = array of TN_MCRing;

type TN_MDCont = record //***** Memory DContour
  Code: integer;          // contour's Code
  BLineIFs: TN_BLineIFs;  // references to Border Lines (UDLIndex and flags)
  BLineIFsCount: integer; // number of used elements in BLineIFs array
  Rings: TN_MCRings;      // array of contour's Rings
  RingsCount: integer;    // number of used elements in Rings array
end; // type TN_MDCont = record
type TN_MDConts = array of TN_MDCont;

type TN_UDLinesCoverage = class( TObject ) //***** UDlines Coverage
  public
  UDLines:        TN_ULines;     // source Border Lines
  UDLineRefs:     TN_UDLineRefs; // array of references to all TN_UDDLine objects
  UDLineRefsCount: integer;      // number of used elements in UDLineRefs array
  UDLineRefs1:    TN_UDLineRefs; // array of references to TN_UDDLine objects of one MDCont
  UDLineRefs1Count: integer;     // number of used elements in UDLineRefs1 array
  MDConts:        TN_MDConts;  // array of contours info without rings
  Rings1:         TN_MCRings;  // array of one Contour's Rings
  Rings1Count: integer;        // number of used elements in Rings1 array
  BLineIFs1:      TN_BLineIFs; // BLines (Index and Flags) array for one cntour
  BLineIFs1Count: integer;     // number of used elements in BLineIFs1 array
  BLineRefs1:     TN_BLineRefs; // array of references to BLines (for one contour)
  BLineRefs1Count: integer;     // number of used elements in BLineRefs1 array
  LSL:            TN_LineSegmentsLists;
  BESegments:     TN_BESegments; // Beg and End Segments for all UDLineRefs
  BESegments1:    TN_BESegments; // Beg and End Segments for one contour
  PtrsBESegment:  TN_PtrsBESegment; // sorted pointers to BESegments elements
  PtrsBESegment1: TN_PtrsBESegment; // sorted pointers to BESegments1 elements
  SegmPairs:      TN_SegmPairs; // Segments pairs (usully crossed segments)
  SegmPairsCount: integer;      // number of used elements in SegmPairs array
  LineSegments:   TN_LineSegments; // Line segments coefs for checking crossings
  CalcEps: double; // overestimated calc. accuracy (usually N_Eps = 1.0e-14)
  SafeEps: double; // usually 100*SafeEps
  CurMDCont: integer; // used only in Dump creation
  CDimInd:   integer; // Codes Space Dimension Index for getting RC1, RC2

  constructor Create;
  destructor  Destroy; override;
//  procedure AddUDLine ( AUDLine: TN_UDDLine; AUDLFlags: integer );
  procedure AddMapUDLines ( AUDlines: TN_ULines );
  procedure AddBLineToMDCont ( MDContInd, AUDLInd, ABLFlags: integer );
  function  AddBLineToBLineIFs1 ( AUDLInd, ABLFlags: integer ): integer;
  procedure CreateMDConts ( OuterCode: integer );
  procedure AddUDLineToLineSegments( UDLInd, ALSFlags: integer );
  procedure FillLSLByUDLines ();
  procedure FillLineSegmentsByBLines ( MDContInd: integer );
  procedure ChangeOnePointCoords( LineInd, SegmInd: integer;
                                                   const NewPoint: TDPoint );
  procedure FillAndSortBESegments ();
  function  FindSegmentsCrossings (): integer;
  function  FindUDLinesCrossings (): integer;
  function  CalcLSCoefs ( ALineInd, ASegmInd, ALSFlags: integer ): TN_LineSegment;
  procedure CorrectTwoLSCrossing ( var SegmPair: TN_SegmPair );
  procedure AddSegmPairs ( AUDLines: TN_ULines );
  function  NormalOrt( LineInd, SegmInd, Direction: integer ): TDPoint;
  function  SignedDistance( const P: TDPoint; LineInd, SegmInd, Direction: integer ): double;
  function  GetNeighbourPtrInd( PtrInd: integer ): integer;
  function  CalcMinLineEndsDistance ( out LI1, LI2: integer ): double;
  function  SnapLineEnds( const SnapSize: double;
                                 out LineInd, NumLineEnds: integer ): double;
  procedure AssembleRings ();
  procedure DumpArrays1( FName: string; Mode: integer );
  procedure MakeRCoords ();
  procedure SortRings ( MDContInd: integer );
  procedure MakeMDContsRings ();
  procedure CreateMapContours ( UContours: TN_UContours );
  procedure FindVertex( const GivenPoint: TDPoint;
                                             out LineInd, SegmInd: integer );
end; // type TN_UDLinesCoverage = class(TObject)

procedure N_UDlinesToUDContours2( AOuterCode, ACDimInd: integer;
                               AUDLines: TN_ULInes; AUContours: TN_UContours );

procedure N_LinesToContBorders ( InpUDLines: TN_ULines; OutUALines: TN_ULines; ACDimInd: integer );

//function  N_ProcessCommands2 ( var MPGData: TN_MPGData; Mode: integer;
//           UDPMCommands: TN_UDPMCommands; var CommandInd: integer ): integer;
//procedure N_DelSmallClosedLines ( InpLinesDir, OutLinesDir: TN_UDBase;
//                                                          RecSize: double );

procedure N_RemoveSameFragments ( InpULines, OutULines: TN_ULines;
                                     SL: TStrings = nil; AMode: integer = 0 );
function  N_RectOverCObj( const SearchRect: TFRect; SearchFlags: integer;
                          ACLayer: TN_UCObjLayer; ItemInd: integer;
                          SpecialCObjPtr: Pointer; out CurCObjPtr: Pointer;
                          out PartInd, SegmInd, VertInd: integer ): boolean;

function  N_HistFindSum  ( AHistValues: TN_IArray; AStartInd, ADeltaInd, ASum: integer ): integer;
function  N_HistFindThreshold( AHistValues: TN_IArray; AStartInd, ADeltaInd, AMaxThreshold: integer ): integer;
function  N_HistFindMax  ( AHistValues: TN_IArray; AStartInd, ADeltaInd: integer; ACoef: Double ): integer;
function  N_HistFindMin  ( AHistValues: TN_IArray; AStartInd, ADeltaInd: integer; ACoef: Double ): integer;
function  N_HistFindLLUL   ( AHistValues: TN_IArray; ACoef: Double; AThresholdSum, AMaxNum, AMinVal: Integer; out ALL, AUL: integer ): integer; overload;
function  N_HistFindLLUL   ( AHistValues: TN_IArray; ACoef: Double; AThresholdSumLeft, AMaxNumLeft, AMinValLeft: Integer; AThresholdSumRight, AMaxNumRight, AMinValRight: Integer; out ALL, AUL: integer ): integer; overload;
function  N_HistFindLLULN  ( AHistValues: TN_IArray; ACoef: Double; AThresholdSumLeft, AMaxNumLeft, AMinValLeft: Integer; AThresholdSumRight, AMaxNumRight, AMinValRight: Integer; out ALL, AUL: integer ): integer;
function  N_HistFindLLULN1 ( AHistValues: TN_IArray; ACoef, ACoef1: Double; AMaxInd: Integer; AThresholdSumLeft, AMaxNumLeft, AStepLeft: Integer; AThresholdSumRight, AMaxNumRight, AStepRight: Integer; out ALL, AUL: integer ): integer;
function  N_HistRemoveZeros1 ( AHistValues: TN_IArray; var AHNZVals, AHNZInds : TN_IArray ): Integer;
function  N_HistRemoveZeros2 ( AHistValues: TN_IArray; var AHNZVals, AHNZInds : TN_IArray ): Integer;
function  N_HistRemoveZeros3 ( AHistValues: TN_IArray; var AHNZVals, AHNZInds : TN_IArray ) : Integer;
procedure N_HistRemovePeaks1 ( AHNZVals: TN_IArray; ACoefPeak: Double );
procedure N_HistSmooth1      ( AHNZVals: TN_IArray; ACoefMean: Double );
function  N_HistMiddleMax1   ( AHNZVals: TN_IArray ): Integer;
function  N_HistMiddleMax2   ( AHNZVals: TN_IArray; AEndsMinShift: Integer; AAllEndsCoef: Double ): Integer;

procedure N_HistFindLLUL1   ( AHistValues: TN_IArray; out ALL, AUL: integer );
procedure N_HistFindLLUL11  ( AHistValues: TN_IArray; out ALL, AUL: integer );
procedure N_HistFindLLUL12  ( AHistValues: TN_IArray; out ALL, AUL: integer );
procedure N_HistFindLLUL13  ( AHistValues: TN_IArray; out ALL, AUL: integer );
procedure N_HistFindLLUL2   ( AHistValues: TN_IArray; out ALL, AUL: integer );
procedure N_HistFindLLUL21  ( AHistValues: TN_IArray; out ALL, AUL: integer );
procedure N_HistFindLLUL22  ( AHistValues: TN_IArray; out ALL, AUL: integer );
procedure N_HistFindLLULPar1 ( AHistValues: TN_IArray; AIntPar: Integer; out ALL, AUL: integer );
procedure N_HistFindLLULPar2 ( AHistValues: TN_IArray; AIntPar: Integer; out ALL, AUL: integer );
procedure N_HistFindLLULXX2  ( ACoeff : double; AHistValues: TN_IArray; out ALL, AUL: integer );

procedure N_CMDIBAdjustLight     ( var ADIBObj: TN_DIBObj );
procedure N_CMDIBAdjustNormal    ( var ADIBObj: TN_DIBObj );
procedure N_CMDIBAdjustAutoAll   ( var ADIBObj: TN_DIBObj; APower: double );
procedure N_CMDIBAdjustByIntPar  ( var ADIBObj: TN_DIBObj; AIntPar: integer );
procedure N_CMDIBAdjustE2V       ( var ADIBObj: TN_DIBObj );
procedure N_CMDIBAdjustULEq      ( var ADIBObj: TN_DIBObj; AAutoUL, AAutoEq: double );
//procedure N_CMDIBAdjustUL        ( var ADIBObj: TN_DIBObj; AAutoUL: double );
//procedure N_CMDIBAdjustEq        ( var ADIBObj: TN_DIBObj; AAutoEq: double );

procedure N_ConvHist8ByXLAT ( ASrcHistValues: TN_IArray; APXLAT: PInteger;
                              var AResHistValues: TN_IArray; APMinHistInd: PInteger = nil;
                              APMaxHistInd: PInteger = nil; APMaxHistVal: PInteger = nil );

procedure N_BCGImageXlatBuild( const AXLat : TN_IArray; AYMax: Integer;
                               ACoFactor, ABriFactor, AGamFactor,
                               AXMinFactor, AXMaxFactor: Double; ANegateFlag: Boolean );

procedure N_LayoutIRects1( AParams: TK_RArray; out ASIRSArray : TN_SIRSArray );

procedure N_CalcGaussMatr   ( var AMatr: TN_FArray; ADim: Integer; ASigma: Double; AFlags: Integer = 0 );
procedure N_CalcGaussVector ( var AVector: TN_FArray; ADim: Integer; ASigma: Double );
procedure N_CalcLaplasMatr  ( var ADMatr: TN_FArray; AFactor: Float );

implementation
uses Math, SysUtils, Dialogs, Forms,
  K_CLib0, K_UDConst, K_VFunc,
  N_Lib0, N_Deb1, N_InfoF, N_ClassRef, N_ME1, N_Rast1Fr;
const
  blUsedFlag = $010000;

//********** TN_LineSegmentsLists class methods  **************

//***************************************** TN_LineSegmentsLists.Create ***
//
constructor TN_LineSegmentsLists.Create( const AEnvDRect: TDRect;
                                                 const NumX, NumY: integer );
var
  i: integer;
begin
  EnvDRect := AEnvDRect;
  NumRectsX := NumX;
  NumRectsY := NumY;
  NumRects  := NumRectsX * NumRectsY;
  RectsWidth  := (EnvDRect.Right - EnvDRect.Left) / NumRectsX;
  RectsHeight := (EnvDRect.Bottom - EnvDRect.Top) / NumRectsY;
  SetLength( SegmRefs, NumRects );
  SetLength( SegmRefsCounts, NumRects );
  for i := 0 to High(SegmRefsCounts) do SegmRefsCounts[i] := 0;
end; //*** end of Constructor TN_LineSegmentsLists.Create

//**************************************** TN_LineSegmentsLists.Destroy ***
destructor TN_LineSegmentsLists.Destroy;
begin
  SegmRefs := nil;
  SegmRefsCounts := nil;
  Inherited;
end; //*** end of destructor TN_LineSegmentsLists.Destroy

//******************************** TN_LineSegmentsLists.AddLineSegmInds ***
// add given ALineInd and ASegmInd to SegmRefs of given RectInd
//
procedure TN_LineSegmentsLists.AddLineSegmInds( const RectInd,
                                                ALineInd, ASegmInd: integer );
var
  Counter: integer;
begin
  Counter := SegmRefsCounts[RectInd];
  if High(SegmRefs[RectInd]) < Counter then
    SetLength( SegmRefs[RectInd], Round(1.3*Counter)+4 );

  SegmRefs[RectInd,Counter].LineInd := ALineInd;
  SegmRefs[RectInd,Counter].SegmInd := ASegmInd;
  Inc(SegmRefsCounts[RectInd]);
end; //*** end of procedure TN_LineSegmentsLists.AddLineSegmInds

//********************************** TN_LineSegmentsLists.AddLineSegment ***
// add LineInd and SegmInd of given Line Segment to all needed SegmRefs
//
procedure TN_LineSegmentsLists.AddLineSegment( const Point1, Point2: TDPoint;
                                            const LineInd, SegmInd: integer );
var
  RectInd, RectIndX, RectIndY, SIX, SIY, SK: integer;
  RectIndX1, RectIndY1, RectIndX2, RectIndY2: integer;
  X, Y, K, KNorm, FRectIndX, FRectIndY: double;
begin
  Inc(StatData.NumSegments);

  SIX := 1;
  if Point1.X > Point2.X then SIX := -1;

  SIY := 1;
  if Point1.Y > Point2.Y then SIY := -1;

  RectIndX1 := Floor( ( Point1.X - EnvDRect.Left ) / RectsWidth );
  RectIndX2 := Floor( ( Point2.X - EnvDRect.Left ) / RectsWidth );

  RectIndY1 := Floor( ( Point1.Y - EnvDRect.Top ) / RectsHeight );
  RectIndY2 := Floor( ( Point2.Y - EnvDRect.Top ) / RectsHeight );

  RectInd := RectIndY1*NumRectsX + RectIndX1; // SegmRefs index
  AddLineSegmInds( RectInd, LineInd, SegmInd ); // initial Rect with Point1
  RectIndX := RectIndX1;
  RectIndY := RectIndY1;

  if Point1.Y = Point2.Y then // horizontal line
  begin
    while True do
    begin
      if RectIndX = RectIndX2 then Exit; // all done
      Inc( RectIndX, SIX );
      RectInd := RectIndY*NumRectsX + RectIndX; // SegmRefs index
      AddLineSegmInds( RectInd, LineInd, SegmInd );
    end;
  end;

  if Point1.X = Point2.X then // vertical line
  begin
    while True do
    begin
      if RectIndY = RectIndY2 then Exit; // all done
      Inc( RectIndY, SIY );
      RectInd := RectIndY*NumRectsX + RectIndX; // SegmRefs index
      AddLineSegmInds( RectInd, LineInd, SegmInd );
    end;
  end;

  //*** not vertical, nor horizontal line
  //    prepare to loop in X direction

  K := (Point2.Y - Point1.Y) / (Point2.X - Point1.X);
  KNorm := K*RectsWidth/RectsHeight;
  SK := SIY;
  if KNorm < 0 then SK := -SK;

  if Point1.X < Point2.X then // from left to right
  begin
    X := EnvDRect.Left + RectIndX1*RectsWidth;
    Y := Point1.Y + (X - Point1.X)*K;
  end else
  begin
    X := EnvDRect.Left + (RectIndX1+1)*RectsWidth;
    Y := Point1.Y + (X - Point1.X)*K;
  end;
  FRectIndY := (Y - EnvDRect.Top) / RectsHeight;
  RectIndX := RectIndX1;

  while True do // loop in X direction
  begin
    if RectIndX = RectIndX2 then Break; // goto loop in Y direction
    Inc( RectIndX, SIX );
    FRectIndY := FRectIndY + KNorm*SK;
    RectIndY := Floor( FRectIndY );
    RectInd := RectIndY*NumRectsX + RectIndX; // SegmRefs index
    AddLineSegmInds( RectInd, LineInd, SegmInd );
  end; // while True do // loop in X direction

  //***** prepare to loop in Y direction

  KNorm := 1.0/KNorm;
  SK := SIX;
  if KNorm < 0 then SK := -SK;

  if Point1.Y < Point2.Y then // from top to down
  begin
    Y := EnvDRect.Top + RectIndY1*RectsHeight;
    X := Point1.X + (Y - Point1.Y)/K;
  end else
  begin
    Y := EnvDRect.Top + (RectIndY1+1)*RectsHeight;
    X := Point1.X + (Y - Point1.Y)/K;
  end;
  FRectIndX := (X - EnvDRect.Left) / RectsWidth;
  RectIndY := RectIndY1;

  while True do // loop in Y direction
  begin
    if RectIndY = RectIndY2 then Exit; // all done
    Inc( RectIndY, SIY );
    FRectIndX := FRectIndX + KNorm*SK;
    RectIndX := Floor( FRectIndX );
    RectInd := RectIndY*NumRectsX + RectIndX; // SegmRefs index
    AddLineSegmInds( RectInd, LineInd, SegmInd );
  end; // while True do // loop in Y direction
end; //*** end of procedure TN_LineSegmentsLists.AddLineSegment

//****************************** TN_LineSegmentsLists.CollectStatistics ***
// collect statistics about SegmRefs
//
procedure TN_LineSegmentsLists.CollectStatistics();
var
  i, NFilled, Size: integer;
begin
  NFilled := 0;
  for i := 0 to NumRectsX*NumRectsY-1 do
  begin
    Size := Length(SegmRefs[i]);
    if Size > 0 then
    begin
      Inc(NFilled);
      Inc( StatData.SegmRefsSize, Size );
      Inc( StatData.NumComparisons, Size*(Size-1) div 2 );
      if StatData.MaxListSize < Size then StatData.MaxListSize := Size;
    end
  end; // for i := 0 to NumRectsX*NumRectsY-1 do

  StatData.NotEmptyRectsRatio := 1.0*NFilled / (NumRectsX*NumRectsY);
  StatData.AverageListSize := 1.0*StatData.SegmRefsSize / NFilled;

end; //*** end of procedure TN_LineSegmentsLists.CollectStatistics

//****************************** TN_LineSegmentsLists.ShowStatistics ***
// show collected statistics about SegmRefs in N_InfoForm
//
procedure TN_LineSegmentsLists.ShowStatistics();
begin
  N_GetInfoForm.Memo.Lines.Clear;
  N_InfoForm.Memo.Lines.Add( 'N_CheckDLinesCrossing Statistics' );
  N_InfoForm.Memo.Lines.Add( '' );
  N_InfoForm.Memo.Lines.Add( Format( 'NumX, NumY        = %d, %d', [NumRectsX, NumRectsY]));
  N_InfoForm.Memo.Lines.Add( Format( 'NotEmptyRectsRatio = %.2e', [StatData.NotEmptyRectsRatio]));
  N_InfoForm.Memo.Lines.Add( Format( 'WholeListsSize    = %.2e', [1.0*StatData.SegmRefsSize]));
  N_InfoForm.Memo.Lines.Add( Format( 'AverageListSize   = %.1f', [StatData.AverageListSize]));
  N_InfoForm.Memo.Lines.Add( Format( 'MaxListSize          = %d', [StatData.MaxListSize]));
  N_InfoForm.Memo.Lines.Add( Format( 'NumComparisons = %.2e', [1.0*StatData.NumComparisons]));
  N_InfoForm.Memo.Lines.Add( Format( 'NumSegments     = %.2e', [1.0*StatData.NumSegments]));
  N_InfoForm.Memo.Lines.Add( Format( '(Max/Num)Comparisons = %.1f',
         [ 1.0*( StatData.NumSegments*(StatData.NumSegments-1) div 2 ) / StatData.NumComparisons ]));
  N_InfoForm.Show;
end; //*** end of procedure TN_LineSegmentsLists.ShowStatistics


//********** TN_UDLinesCoverage class methods  **************

//********************************************** TN_UDLinesCoverage.Create ***
//
constructor TN_UDLinesCoverage.Create;
begin
//  SetLength( UDLineRefs, 10 );
  UDLineRefsCount := 0;
  SegmPairsCount := 0;
  CalcEps := N_Eps;
  SafeEps := 100 * SafeEps;
end; // end_of constructor TN_UDLinesCoverage.Create

//********************************************* TN_UDLinesCoverage.Destroy ***
//
destructor TN_UDLinesCoverage.Destroy;
begin
  UDLineRefs := nil;
  SegmPairs := nil;
  LSL.Free;
end; // end_of destructor TN_UDLinesCoverage.Destroy

//************************************** TN_UDLinesCoverage.AddMapUDLines ***
// add all Items of given UDLines to UDLineRefs array
// with zero UDLine flags
//
procedure TN_UDLinesCoverage.AddMapUDLines( AUDlines: TN_ULines );
var
  i: integer;
begin
  UDlines := AUDlines;
  UDLineRefsCount := AUDLines.WNumItems;
  SetLength( UDLineRefs, UDLineRefsCount );

  for i := 0 to UDLineRefsCount-1 do // loop along Items
  with UDLineRefs[i] do
  begin
    IndPtrBegS := 0;
    IndPtrEndS := 0;
  end;
end; // end of procedure TN_UDLinesCoverage.AddMapUDLines

//********************************** TN_UDLinesCoverage.AddBLineToMDCont ***
// add one border line (given by it's UDLIndex and flags) to MDCont with
// given MDCont Index (increase MDConts array if nessasary)
//
procedure TN_UDLinesCoverage.AddBLineToMDCont( MDContInd, AUDLInd, ABLFlags: integer );
var
  i, OldMDContsLength: integer;
begin
  if MDContInd <= 0 then Exit;
  OldMDContsLength := Length(MDConts);
  if OldMDContsLength <= MDContInd then // increase MDConts array
  begin
    SetLength( MDConts, N_NewLength(MDContInd) );
    for i := OldMDContsLength to High(MDConts) do
    begin
      MDConts[i].Code := 0; // a precaution
      MDConts[i].BLineIFs := nil;
      MDConts[i].BLineIFsCount := 0;
    end;
  end; // if OldMDContsLength <= MDContInd then // increase MDConts array

  with MDConts[MDContInd] do
  begin
    Code := MDContInd;

    if High(BLineIFs) <= BLineIFsCount then
      SetLength( BLineIFs, N_NewLength(BLineIFsCount) );

    BLineIFs[BLineIFsCount].UDLInd  := AUDLInd;
    BLineIFs[BLineIFsCount].BLFlags := ABLFlags;
    Inc(BLineIFsCount);
  end;
end; // end of procedure TN_UDLinesCoverage.AddBLineToMDCont

//******************************** TN_UDLinesCoverage.AddBLineToBLineIFs1 ***
// add one border line (given by it's UDLIndex and flags) to BLineIFs1
// return added border line index in BLineIFs1
//
function TN_UDLinesCoverage.AddBLineToBLineIFs1( AUDLInd, ABLFlags: integer ): integer;
begin
  if High(BLineIFs1) <= BLineIFs1Count then
    SetLength( BLineIFs1, N_NewLength(BLineIFs1Count) );

  with BLineIFs1[BLineIFs1Count] do
  begin
    UDLInd  := AUDLInd;
    BLFlags := ABLFlags;
  end;

  Result := BLineIFs1Count;
  Inc(BLineIFs1Count);
end; // end of function TN_UDLinesCoverage.AddBLineToBLineIFs1

//************************************** TN_UDLinesCoverage.CreateMDConts ***
// create MDConts array by UDLineRefs,
// OuterCode - Outer (imaginable) Contour Code
//
procedure TN_UDLinesCoverage.CreateMDConts( OuterCode: integer );
var
  i, j, NumRestCodes, WrkCDimInd, WrkCode: integer;
  PIntCode: PInteger;
begin
  MDConts := nil;

  //*** NEW code, not tested yet!!!
  //    OuterCode temporary is not used, later add any list of Outer codes,
  //    for which Contours should not be assembled

  for i := 0 to UDLineRefsCount-1 do // along all UDLines
  begin
    PIntCode := UDLines.GetPtrToFirstCode( i, CDimInd, NumRestCodes );

    for j := 0 to NumRestCodes-1 do // along all Rest Codes in i-th Line
    begin
      N_DecodeCObjCodeInt( PIntCode^, WrkCDimInd, WrkCode );

      if WrkCDimInd = CDimInd then // IntCode has needed CDimInd
        AddBLineToMDCont( WrkCode, i, 1 ) // add to ContCode-th MDCont
      else // no more codes with needed CDimInd
        Break;

      Inc( PIntCode );
    end; // for j := 0 to NumRestCodes-1 do // along all Rest Codes in i-th Line
  end; // for i := 0 to UDLineRefsCount-1 do // along all UDLines

{ old var
var
  i, Code, RC1, RC2: integer;
//  Assert( UDLineRefsCount <= Length(UDLines.RCXY), 'Conts Error1' );
  for i := 0 to UDLineRefsCount-1 do // with UDLines.RCXY[i] do
  begin
    UDLines.GetItemTwoCodes( i, CDimInd, RC1, RC2 );
//    Code := Y; // Code contour is to the RIGHT of UDLine
    Code := RC2; // Code contour is to the RIGHT of UDLine
    if Code <> OuterCode then
      AddBLineToMDCont( Code, i, 1 );
//    Code := X; // Code contour is to the LEFT of UDLine
    Code := RC1; // Code contour is to the LEFT of UDLine
    if Code <> OuterCode then
      AddBLineToMDCont( Code, i, 0 );
  end; // for i := 0 to UDLineRefsCont-1 do with UDLines.RCXY[i] do
}
end; // end of procedure TN_UDLinesCoverage.CreateMDConts

//***************************** TN_UDLinesCoverage.AddUDLineToLineSegments ***
// add to LineSegments array all segments of given  UDLines Item
// (given by it's index UDLInd) and it's direction
//
procedure TN_UDLinesCoverage.AddUDLineToLineSegments( UDLInd, ALSFlags: integer );
var
  i, OldLength, FPInd, NumInds: integer;
begin
  OldLength := Length( LineSegments );
  UDLines.GetItemInds( UDLInd, FPInd, NumInds );
  SetLength( LineSegments, OldLength + NumInds-1 );
  for i := 0 to NumInds-2 do
    LineSegments[OldLength+i] := CalcLSCoefs( UDLInd, i, ALSFlags );
end; // end of procedure TN_UDLinesCoverage.AddUDLineToLineSegments

//***************************** TN_UDLinesCoverage.FillLSLByUDLines ***
// Fill LSL.SegmRefs as Segment Lists in Rects by all segments of
// all lines from UDLineRefs array
//
procedure TN_UDLinesCoverage.FillLSLByUDLines();
var
  i, j, FPInd, NumInds: integer;
begin
  for i := 0 to UDLineRefsCount-1 do with UDLines do
  begin
    GetItemInds( i, FPInd, NumInds );
    for j := 0 to NumInds-2 do
    begin
//      N_PCAdd( 5, Format( 'i,j = %d %d', [i,j] ) );
      LSL.AddLineSegment( LDCoords[FPInd+j], LDCoords[FPInd+j+1], i, j );
    end;
  end;
end; // end of procedure TN_UDLinesCoverage.FillLSLByUDLines

//*************************** TN_UDLinesCoverage.FillLineSegmentsByBLines ***
// Fill LineSegments array by all segments of MDContour
// with given Index (MDContInt)
//
procedure TN_UDLinesCoverage.FillLineSegmentsByBLines( MDContInd: integer );
var
  i: integer;
begin
  LineSegments := nil;
  with MDConts[MDContInd] do
    for i := 0 to BLineIFsCount-1 do
      with BLineIFs[i] do
        AddUDLineToLineSegments( UDLInd, BLFlags and $01 );
end; // end of procedure TN_UDLinesCoverage.FillLineSegmentsByBLines

//******************************** TN_UDLinesCoverage.ChangeOnePointCoords ***
// change beg Point coords of given Line Segment to NewPoint,
// if it is Line Beg or End point, change all needed (connected) UDLineRefs,
// SegmInd = -1 or SegmInd = MaxSegmInd+1 means End point of last Line Segment,
// it is assumed, that PtrsBESegment array is already filled and sorted
//
procedure TN_UDLinesCoverage.ChangeOnePointCoords( LineInd, SegmInd: integer;
                                                     const NewPoint: TDPoint );
var
  i, IndPtr, MaxSegmInd, FPInd, NumInds: integer;
  BEPS, NextBEPS: TN_BESegment;
begin
  UDLines.GetItemInds( LineInd, FPInd, NumInds );
  MaxSegmInd := FPInd + NumInds - 2;
  IndPtr := -1; // "Line internal point" flag

  if (SegmInd = -1) or (SegmInd = MaxSegmInd + 1) then
    IndPtr := UDLineRefs[LineInd].IndPtrEndS; // Line End Point

  if SegmInd = 0 then
    IndPtr := UDLineRefs[LineInd].IndPtrBegS; // Line Beg Point

  if IndPtr = -1 then // if "Line internal point" flag
  begin
    UDLines.LDCoords[FPInd+SegmInd] := NewPoint; // New Line internal Point
    Exit; // all done for Line internal Point (not Beg or End Point)
  end;

  BEPS := PtrsBESegment[IndPtr]^;

  for i := IndPtr to High(PtrsBESegment) do // loop from Given to the UP
  begin
    NextBEPS := PtrsBESegment[i]^; // next neighbour record
    if (NextBEPS.BEPoint.X <> BEPS.BEPoint.X) or // check if same point
       (NextBEPS.BEPoint.Y <> BEPS.BEPoint.Y)    then Break;

    UDLines.GetItemInds( NextBEPS.LineInd, FPInd, NumInds );
    if (NextBEPS.BESFlags and $01) = 0 then // Beg Point flag
      UDLines.LDCoords[FPInd] := NewPoint // New Line Beg Point
    else // End Point flag
      UDLines.LDCoords[FPInd+NumInds-1] := NewPoint; // New Line End Point

  end; // for i := IndPtr+1 to High(PtrsBESegment) do // loop thrue the UP neighbours

  for i := IndPtr-1 downto 0 do // loop thrue the DOWN neighbours
  begin
    NextBEPS := PtrsBESegment[i]^; // next neighbour record
    if (NextBEPS.BEPoint.X <> BEPS.BEPoint.X) or // check if same point
       (NextBEPS.BEPoint.Y <> BEPS.BEPoint.Y)    then Break;

    UDLines.GetItemInds( NextBEPS.LineInd, FPInd, NumInds );
    if (NextBEPS.BESFlags and $01) = 0 then // Beg Point flag
      UDLines.LDCoords[FPInd] := NewPoint // New Line Beg Point
    else // End Point flag
      UDLines.LDCoords[FPInd+NumInds-1] := NewPoint; // New Line End Point
  end; // for i := IndPtr-1 downto 0 do // loop thrue the DOWN neighbours

end; // end of procedure TN_UDLinesCoverage.ChangeOnePointCoords

//****************************** TN_UDLinesCoverage.FillAndSortBESegments ***
// create and fill BESegments array,
// create and fill PtrsBESegment array (pointers to BESegments array elements),
// sort PtrsBESegment array,
// fill IndPtrBegS and IndPtrEndS fields of UDLineRefs array
//
procedure TN_UDLinesCoverage.FillAndSortBESegments();
var
  i, FPInd, NumInds: integer;
begin
  //***** create and fill BESegments and PtrsBESegment arrays
  SetLength( BESegments,    2*UDLineRefsCount );
  SetLength( PtrsBESegment, 2*UDLineRefsCount );

  for i := 0 to UDLineRefsCount-1 do
  begin
    with UDLineRefs[i], UDLines do
    begin
    GetItemInds( i, FPInd, NumInds );
    PtrsBESegment[2*i] := @BESegments[2*i];
    BESegments[2*i].BEPoint := LDCoords[FPInd];
    BESegments[2*i].LineInd := i;
    BESegments[2*i].BESFlags := 0;  // Beg Point (segment) ( DC[0] ) flag
    BESegments[2*i].Angle := N_ArcTan2( LDCoords[FPInd+1].X-LDCoords[FPInd].X,
                                        LDCoords[FPInd+1].Y-LDCoords[FPInd].Y );

    PtrsBESegment[2*i+1] := @BESegments[2*i+1];
    BESegments[2*i+1].BEPoint := LDCoords[FPInd+NumInds-1];
    BESegments[2*i+1].LineInd := i;
    BESegments[2*i+1].BESFlags := 1; // End Point (segment) ( DC[High(DC)] ) flag
    BESegments[2*i+1].Angle := N_ArcTan2(
                    LDCoords[FPInd+NumInds-2].X-LDCoords[FPInd+NumInds-1].X,
                    LDCoords[FPInd+NumInds-2].Y-LDCoords[FPInd+NumInds-1].Y  );
    end; // with UDLineRefs[i], UDLines do
  end; // for i := 0 to UDLineRefsCount-1 do

  //***** Sort pointers to elements of BESegments array,
  //      result is sorted PtrsBESegment array

  N_SortPointers( TN_PArray(PtrsBESegment), 0, N_CompareDPointAndAngle );

  //***** fill IndPtrBegS and IndPtrEndS fields of UDLineRefs array
  for i := 0 to High(PtrsBESegment) do
  begin
    with PtrsBESegment[i]^ do
    begin
    if (BESFlags and $01) = 0 then
      UDLineRefs[LineInd].IndPtrBegS := i
    else
      UDLineRefs[LineInd].IndPtrEndS := i;
    end;
  end; // for i := 0 to High(BLBEPoints) do

end; // end of procedure TN_UDLinesCoverage.FillAndSortBESegments

//*************************** TN_UDLinesCoverage.FindSegmentsCrossings ***
// find all Segments (from LineSegments array) crossings and
// add them to SegmPairs array (it may be not empty)
//    Return  number of founded crossings (intersections)
//
function TN_UDLinesCoverage.FindSegmentsCrossings(): integer;
var
  i, j: integer;
  R1, R2, R1b, R2b: double;
begin
  Result := 0;
  for i := 0 to High(LineSegments) do
  begin
    for j := i+1 to High(LineSegments) do
    begin //***** loop along all (i,j) segment pairs
      R1 := LineSegments[i].A*LineSegments[j].P1.X +
            LineSegments[i].B*LineSegments[j].P1.Y + LineSegments[i].C;
      R2 := LineSegments[i].A*LineSegments[j].P2.X +
            LineSegments[i].B*LineSegments[j].P2.Y + LineSegments[i].C;
      if (R1 > CalcEps) and (R2 < -CalcEps) or
         (R2 > CalcEps) and (R1 < -CalcEps)  then
      begin
        R1b := LineSegments[j].A*LineSegments[i].P1.X +
              LineSegments[j].B*LineSegments[i].P1.Y + LineSegments[j].C;
        R2b := LineSegments[j].A*LineSegments[i].P2.X +
              LineSegments[j].B*LineSegments[i].P2.Y + LineSegments[j].C;
        if (R1b > CalcEps) and (R2b < -CalcEps) or
           (R2b > CalcEps) and (R1b < -CalcEps)  then
        begin // segments pair i,j is crossed, add it to SegmPairs array
          if High(SegmPairs) < SegmPairsCount then
            SetLength( SegmPairs, 2*SegmPairsCount+4 );
          with SegmPairs[SegmPairsCount] do
          begin
            LineInd1 := LineSegments[i].LineInd;
            SegmInd1 := LineSegments[i].SegmInd;
            LineInd2 := LineSegments[j].LineInd;
            SegmInd2 := LineSegments[j].SegmInd;
            if LineInd1 = 74 then
              LineInd1 := LineInd1 + 0;
            SPFlags := (LineSegments[i].LSFlags and $01) or  // direction info
                     ( (LineSegments[j].LSFlags and $01) shl 1 );
          end; // with SegmPairs[SegmPairsCount] do
          Inc(SegmPairsCount);
          Inc(Result);
        end; //
      end; //
    end; // for j := i+1 to High(LineSegments) do
  end; // for i := 0 to High(LineSegments) do
end; // end of function TN_UDLinesCoverage.FindSegmentsCrossings

//*************************** TN_UDLinesCoverage.FindUDLinesCrossings ***
// find all UDLines segments crossings and list them in SegmPairs array,
// assuming that LSL object is already OK
//    Return  number of intersections
//
function TN_UDLinesCoverage.FindUDLinesCrossings(): integer;
var
  i, j: integer;
begin
  with LSL do
  begin
    SegmPairsCount := 0;
    for i := 0 to High(SegmRefs) do
    begin
      SetLength( LineSegments, SegmRefsCounts[i] );
      for j := 0 to High(LineSegments) do  with SegmRefs[i,j] do
          LineSegments[j] := CalcLSCoefs( LineInd, SegmInd, 0 );
      FindSegmentsCrossings();
    end; // for i := 0 to High(SegmRefs) do
  end; // with LSL do
  Result := SegmPairsCount;
end; // end of function TN_UDLinesCoverage.FindUDLinesCrossings

//************************************ TN_UDLinesCoverage.CalcLSCoefs ***
// calculate and return Line Segment Coefs (all fields of TN_LineSegment)
// by given ALineInd, ASegmInd, ALSFlags
//
function TN_UDLinesCoverage.CalcLSCoefs( ALineInd, ASegmInd,
                                         ALSFlags: integer ): TN_LineSegment;
var
  FPInd, NumInds: integer;
begin
  with Result, UDLines do
  begin
    UDLines.GetItemInds( ALineInd, FPInd, NumInds );
    P1 := LDCoords[FPInd+ASegmInd];
    P2 := LDCoords[FPInd+ASegmInd+1];
    A  := P2.Y - P1.Y;
    B  := P1.X - P2.X;
    C  := P2.X*P1.Y - P2.Y*P1.X;
    LineInd := ALineInd;
    SegmInd := ASegmInd;
    LSFlags := ALSFlags;
  end;
end; // end of function TN_UDLinesCoverage.CalcLSCoefs

//*************************** TN_UDLinesCoverage.CorrectTwoLSCrossing ***
// Correct Two Line Segments intersection
// (change needed Segment's end point coords appropriatry)
// SegmPair - Line Segments Pair (two Line Segments), that are intersected
//     On Input - SegmPair.SPFlags bits 0 and 1 :
// bit0($001) - first segment direction
// bit1($002) - second segment direction
//     On Output bits 4-6 are set:
// bits4-5($030) - index of one corrected Point (if any)
//           (0 - Beg Segm1, 1 - End Segm1, 2 - Beg Segm2, 3 - End Segm2)
// bit6($040) =0 - all points remains the same (bits4-5 not used)
//            =1 - point coords with index in bits4-5 were changed
//
procedure TN_UDLinesCoverage.CorrectTwoLSCrossing( var SegmPair: TN_SegmPair );
var
  i, Segm1D, Segm2D: integer;
  NormOrt, NewP: TDPoint;
  LS1, LS2: TN_LineSegment;
  DistAndType: TN_DPArray; // X coord is used as distance, Y - as point type
  PtrsDistAndType: array of PDPoint;
begin
  SetLength( DistAndType, 5 );
  SetLength( PtrsDistAndType, 4 );

  with SegmPair do
  begin

  LS1 := CalcLSCoefs( LineInd1, SegmInd1, 0 );
  LS2 := CalcLSCoefs( LineInd2, SegmInd2, 0 );
  Segm1D := SPFlags and $01;         // Segment 1 direction
  Segm2D := (SPFlags shr 1) and $01; // Segment 2 direction

  for i := 0 to 3 do PtrsDistAndType[i] := @DistAndType[i];

  DistAndType[0].X := SignedDistance( LS1.P1, LineInd2, SegmInd2, Segm2D );
  DistAndType[0].Y := 0;
  DistAndType[1].X := SignedDistance( LS1.P2, LineInd2, SegmInd2, Segm2D );
  DistAndType[1].Y := 1;
  DistAndType[2].X := SignedDistance( LS2.P1, LineInd1, SegmInd1, Segm1D );
  DistAndType[2].Y := 2;
  DistAndType[3].X := SignedDistance( LS2.P2, LineInd1, SegmInd1, Segm1D );
  DistAndType[3].Y := 3;

  N_SortPointers( TN_PArray(PtrsDistAndType), 0, N_CompareDPoints );

  for i := 0 to 3 do
  begin
    DistAndType[4] := PtrsDistAndType[i]^;
    if DistAndType[4].X > CalcEps then
    begin
      SPFlags := (4 + Round( DistAndType[4].Y )) shl 4;
      if DistAndType[4].Y = 0 then
      begin
        NormOrt := NormalOrt( LineInd2, SegmInd2, Segm2D );
        NewP.X := LS1.P1.X - (SafeEps+DistAndType[4].X)*NormOrt.X;
        NewP.Y := LS1.P1.Y - (SafeEps+DistAndType[4].X)*NormOrt.Y;
        ChangeOnePointCoords( LineInd1, SegmInd1, NewP );
      end else if DistAndType[4].Y = 1 then
      begin
        NormOrt := NormalOrt( LineInd2, SegmInd2, Segm2D );
        NewP.X := LS1.P2.X - (SafeEps+DistAndType[4].X)*NormOrt.X;
        NewP.Y := LS1.P2.Y - (SafeEps+DistAndType[4].X)*NormOrt.Y;
        ChangeOnePointCoords( LineInd1, SegmInd1+1, NewP );
      end else if DistAndType[4].Y = 2 then
      begin
        NormOrt := NormalOrt( LineInd1, SegmInd1, Segm1D );
        NewP.X := LS2.P1.X - (SafeEps+DistAndType[4].X)*NormOrt.X;
        NewP.Y := LS2.P1.Y - (SafeEps+DistAndType[4].X)*NormOrt.Y;
        ChangeOnePointCoords( LineInd2, SegmInd2, NewP );
      end else if DistAndType[4].Y = 3 then
      begin
        NormOrt := NormalOrt( LineInd1, SegmInd1, Segm1D );
        NewP.X := LS2.P2.X - (SafeEps+DistAndType[4].X)*NormOrt.X;
        NewP.Y := LS2.P2.Y - (SafeEps+DistAndType[4].X)*NormOrt.Y;
        ChangeOnePointCoords( LineInd2, SegmInd2+1, NewP );
      end;
      Exit; // coords of one point were corrected
    end; // if DistAndType[i].X < CalcEps then
  end; // for i := 0 to 3 do
  end; // with SegmPair do
end; // end of procedure TN_UDLinesCoverage.CorrectTwoLSCrossing

//*********************************** TN_UDLinesCoverage.AddSegmPairs ***
// create Lines MapLayer as last child of given ParentFragment with all
// Line Segments from SegmPairs array and given LineColor, LineWidth
//   Return created MapLayer
//
procedure TN_UDLinesCoverage.AddSegmPairs( AUDLines: TN_ULines );
var
  i: integer;
  LS: TN_LineSegment;
  DLItem: TN_ULinesItem;
begin
  if Length(SegmPairs) = 0 then Exit;
  DLItem := TN_ULinesItem.Create( N_DoubleCoords );

  for i := 0 to SegmPairsCount-1 do with SegmPairs[i] do
  begin
    LS := CalcLSCoefs( LineInd1, SegmInd1, 0 );
    DLItem.CreateSegmItem( LS.P1, LS.P2, 0 );
//    DLItem.ICode := i+1;
//    DLItem.SetTwoCodes( 0, i+1, -1 );
    AUDLines.ReplaceItemCoords( DLItem, -1, i+1 );

    LS := CalcLSCoefs( LineInd2, SegmInd2, 0 );
    DLItem.CreateSegmItem( LS.P1, LS.P2, 0 );
//    DLItem.ICode := i+1;
//    DLItem.SetTwoCodes( 0, i+1, -1 );
    AUDLines.ReplaceItemCoords( DLItem, -1, i+1 );
  end; // for i := 0 to High(SegmPairs) do with SegmPairs[i] do

  DLItem.Free;
end; // end of function TN_UDLinesCoverage.AddSegmPairs

//***************************************** TN_UDLinesCoverage.NormalOrt ***
// return Normal Ort (perpendicular vector of length = 1) to given Line Segment,
// Direction - needed Normal Ort direction:
//     bit0 =0 - Resulting Normal Ort points the LEFT of given Line Segment
//     bit0 =1 - Resulting Normal Ort points the RIGHT of given Line Segment
//
function TN_UDLinesCoverage.NormalOrt( LineInd, SegmInd, Direction: integer ): TDPoint;
var
  Norm: double;
  P1, P2, Ort: TDPoint;
begin
  with UDLines, UDLines.Items[LineInd] do
  begin
    P1 := LDCoords[CFInd+SegmInd];   // beg point of Line Segment
    P2 := LDCoords[CFInd+SegmInd+1]; // end point of Line Segment
  end;
  Ort.X := P2.Y - P1.Y; // Ort, that points to the left of (P1->P2)
  Ort.Y := P1.X - P2.X;
  if (Direction and $01) <> 0 then // reverse Ort direction
  begin
    Ort.X := -Ort.X;
    Ort.Y := -Ort.y;
  end;
  Norm := Sqrt( Ort.X*Ort.X + Ort.Y*Ort.Y );
  Result.X := Ort.X / Norm;
  Result.Y := Ort.Y / Norm;
end; // end of function TN_UDLinesCoverage.NormalOrt

//************************************ TN_UDLinesCoverage.SignedDistance ***
// return signed distance of given Point P from given Line Segment,
// Direction - needed Resulting Distance sign:
//     bit0 =0 - Distance > 0 if P is to the  LEFT of given Line Segment
//     bit0 =1 - Distance > 0 if P is to the RIGHT of given Line Segment
//
function TN_UDLinesCoverage.SignedDistance( const P: TDPoint;
                               LineInd, SegmInd, Direction: integer ): double;
var
  BegSegmPoint, NormOrt: TDPoint;
begin
  NormOrt := NormalOrt( LineInd, SegmInd, Direction );
  with UDLines.Items[LineInd] do
    BegSegmPoint := UDLines.LDCoords[CFInd+SegmInd];
  Result := (P.X-BegSegmPoint.X)*NormOrt.X +  //      Scalar product of
            (P.Y-BegSegmPoint.Y)*NormOrt.Y;   //  (BegSegmPoint-P) and NormOrt
end; // end of function TN_UDLinesCoverage.SignedDistance

//********************************* TN_UDLinesCoverage.GetNeighbourPtrInd ***
// get Neighbour (nearest) to given IndPtr Ptr Index (in PtrsBESegment1 array)
//
function TN_UDLinesCoverage.GetNeighbourPtrInd( PtrInd: integer ): integer;
var
  i, k: integer;
  CurBES, NextBES: TN_BESegment;

begin
  CurBES := PtrsBESegment1[PtrInd]^;

  //***** find not processed yet (with zero blUsedFlag) BLine
  //      with same BES and minimal, greater then given  Angle,
  //      first loop from PtrInd+1 to the UP

  for i := PtrInd+1 to High(PtrsBESegment1) do //
  begin
    NextBES := PtrsBESegment1[i]^;
    Result := i;
    if (CurBES.BEPoint.X = NextBES.BEPoint.X) and
       (CurBES.BEPoint.Y = NextBES.BEPoint.Y) and
       ((BLineRefs1[NextBES.LineInd].BLFlags and blUsedFlag) = 0) then Exit;
  end; // for i := PtrInd+1 to High(PtrsBLBEPoint) do //

  //***** Here: no needed BLine with index greater then IndPtr,
  //      find lowermost BLine with same BEPoint

  k := -1;
  for i := PtrInd-1 downto 0 do //
  begin
    NextBES := PtrsBESegment1[i]^;
    if (CurBES.BEPoint.X <> NextBES.BEPoint.X) or
       (CurBES.BEPoint.Y <> NextBES.BEPoint.Y)   then
    begin
      k := i;
      Break;
    end;
  end; // for i := PtrInd-1 downto 0 do //

  //***** Here: (k+1) - index of lowermost BLine with same BEPoint
  //      find lowermost not processed yet (with zero blUsedFlag) BLine
  for i := k+1 to PtrInd-1 do //
  begin
    NextBES := PtrsBESegment1[i]^;
    Result := i;
    if (BLineRefs1[NextBES.LineInd].BLFlags and blUsedFlag) = 0 then Exit;
  end; // for j := i+1 to PtrInd-1 do //
  Result := -1;  // error: Needed BESegment not found!
//  Assert( False, 'Needed BESegment not found!' );
end; // end of local function TN_UDLinesCoverage.GetNeighbourPtrInd

//************************** TN_UDLinesCoverage.CalcMinLineEndsDistance ***
// calc minimal, but >0, distance between all pairs of LineEnds,
// (PtrsBESegment array assumed to be filled and sorted)
// on output - LI1, LI2 Line indexes with minimal Line Ends distance
//             ( LI1,LI2 > 0 if Beg Line point, < 0 if Last Line point)
//
function TN_UDLinesCoverage.CalcMinLineEndsDistance( out LI1, LI2: integer ): double;
var
  i, j: integer;
  Cur, Next: TN_BESegment;
  Dx2, Dy2, Dist2: double;
begin
  Result := 1.0e100;

  for i := 0 to High(PtrsBESegment) do //
  begin
    Cur := PtrsBESegment[i]^;

    for j := i+1 to High(PtrsBESegment) do //
    begin
      Next := PtrsBESegment[j]^;
      Dx2 := Cur.BEPoint.X - Next.BEPoint.X;
      Dx2 := Dx2*Dx2;
      Dy2 := Cur.BEPoint.Y - Next.BEPoint.Y;
      Dy2 := Dy2*Dy2;
      Dist2 := Dx2 + Dy2; // squared distance

      if (Dist2 > 0.0) and (Dist2 < Result) then
      begin
        Result := Dist2;
        LI1 := Cur.LineInd;
        if (Cur.BESFlags  and $01) <> 0 then LI1 := -LI1;
        LI2 := Next.LineInd;
        if (Next.BESFlags and $01) <> 0 then LI2 := -LI2;
      end;

      if Dx2 >= Result then Break;
    end; // for j := i+1 to High(PtrsBESegment) do //

  end; // for i := 0 to High(PtrsBESegment) do //
  Result := Sqrt( Result );
end; // end of local function TN_UDLinesCoverage.CalcMinLineEndsDistance

//*********************************** TN_UDLinesCoverage.SnapLineEnds ***
// Snap Line Ends by given SnapSize
// (PtrsBESegment array assumed to be filled and sorted)
// on output:
//   LineInd     - first Line index with Snaped EndPoint (first or last)
//                  ( EndPoint that remains the same)
//                  ( LineInd > 0 if Beg Line point, < 0 if Last Line point),
//   NumLineEnds - whole number of Snaped LineEnds
//
// return max distance between first Snaped EndPoint and other Snaped EndPoints
//
function TN_UDLinesCoverage.SnapLineEnds( const SnapSize: double;
                                out LineInd, NumLineEnds: integer ): double;
var
  i, j, FPInd, NumInds: integer;
  Cur, Next: TN_BESegment;
  Dx2, Dy2, Dist2, SnapSize2: double;
begin
  LineInd     := N_NotAnInteger;
  NumLineEnds := 0;
  Result      := 0.0;
  SnapSize2   := SnapSize*SnapSize;
  if SnapSize = 0.0 then begin Beep; Exit; end; // parametr error

  for i := 0 to High(PtrsBESegment) do // loop along potentialy all pairs of LineEnds
  begin
    Cur := PtrsBESegment[i]^;

    for j := i+1 to High(PtrsBESegment) do // compare i-th and j-th Ends
    begin
      Next := PtrsBESegment[j]^;
      Dx2 := Cur.BEPoint.X - Next.BEPoint.X;
      Dx2 := Dx2*Dx2;
      Dy2 := Cur.BEPoint.Y - Next.BEPoint.Y;
      Dy2 := Dy2*Dy2;
      Dist2 := Dx2 + Dy2; // squared distance

      if (Dist2 > 0.0) and (Dist2 < SnapSize2) then // j-th End should be snaped
      begin
        LineInd := Cur.LineInd; // not optimal: same action for all snaped Ends
        if (Cur.BESFlags and $01) <> 0 then LineInd := -LineInd;

        with UDLines do
        begin
          GetItemInds( Next.LineInd, FPInd, NumInds );
          if (Next.BESFlags and $01) = 0 then
            LDCoords[FPInd] := Cur.BEPoint // first Line End
          else
            LDCoords[FPInd+NumInds-1] := Cur.BEPoint; // last Line End
        end;

        Inc(NumLineEnds);
        if Result < Dist2 then Result := Dist2;
      end;

      if Dx2 >= SnapSize2 then Break; // for all other j-th Ends Dist2 > SnapSize2
    end; // for j := i+1 to High(PtrsBESegment) do //

  end; // for i := 0 to High(PtrsBESegment) do //
  Result := Sqrt( Result );
end; // end of local function TN_UDLinesCoverage.SnapLineEnds

//*********************************** TN_UDLinesCoverage.AssembleRings ******
// assemble all BLineRefs1 into Rings,
// result is in Rings1, Rings1Count and BLineIFs1 arrays
//
procedure TN_UDLinesCoverage.AssembleRings();
var
  i, BLFlags, RingInd: integer;
  UDLInd, FirstRingLineInd, NextPtrInd: integer;
begin
  Rings1Count := 0;
  BLineIFs1Count := 0;
  N_LCAdd( 5, 'Assemble Rings' );
  for i := 0 to BLineRefs1Count-1 do // loop along all BLineRefs1 elements
  begin
    UDLInd  := BLineRefs1[i].UDLInd;
N_LCAdd( 5, 'i='+IntToStr(UDLInd) );
    BLFlags := BLineRefs1[i].BLFlags;
    if ( BLFlags and blUsedFlag) <> 0 then Continue; // Bline was already processed

    //***** begin New Ring with BLineIFs[i] border line

    if High(Rings1) <= Rings1Count then
      SetLength( Rings1, N_NewLength(Rings1Count) );

    with Rings1[Rings1Count] do
    begin
      EnvDRect.Left  :=  0.0;
      EnvDRect.Right := -1.0;
      BegBLineInd := AddBLineToBLineIFs1( UDLInd, BLFlags );
      NumBLines   := 1;
      RCoords := nil;
      ChildRingInds := nil;
      Level := 0;
      Flags := 0;
    end; // with Rings1[Rings1Count] do
    RingInd := Rings1Count;
    Inc(Rings1Count);

    FirstRingLineInd := i; // index in BLineRefs array

    if (BLFlags and $01) = 0 then
      NextPtrInd := BLineRefs1[i].IndPtrEndS1
    else
      NextPtrInd := BLineRefs1[i].IndPtrBegS1;

N_LCAdd( 5, '' );
N_LCAdd( 5, Format( '***   NewRing=%d, NextPtrInd=%d', [RingInd,NextPtrInd] ) );

    while True do // add all other connected lines to current Ring
    begin
      N_LCAdd( 5, 'Inp NPI='+IntToStr(NextPtrInd) );
      NextPtrInd := GetNeighbourPtrInd( NextPtrInd );
      if NextPtrInd = -1 then // error: 'Not closed ring'
      begin
        DumpArrays1( 'ADump_01.~txt', 0 );
        Assert( False, 'Not closed ring' );
      end;

      with PtrsBESegment1[NextPtrInd]^ do
      begin
//*** LineInd (PtrsBESegment1[NextPtrInd]^.LineInd) is index in BLineRefs1
        BLineRefs1[LineInd].BLFlags := BLineRefs1[LineInd].BLFlags or blUsedFlag;
        N_LCAdd( 5, Format( 'New NPI=%d, RI=%d, LI=%d',
                                    [NextPtrInd, RingInd, LineInd] ) );
        if LineInd = FirstRingLineInd then Break; // all Ring lines are assembled
        if (BESFlags and $01) = 0 then
          NextPtrInd := BLineRefs1[LineInd].IndPtrEndS1
        else
          NextPtrInd := BLineRefs1[LineInd].IndPtrBegS1;

      AddBLineToBLineIFs1( BLineRefs1[LineInd].UDLInd,
                                      BLineRefs1[LineInd].BLFlags and $FFFF );
      end; // with PtrsBESegment1[NextPtrInd]^ do
      Inc(Rings1[RingInd].NumBLines);

    end; // while true do - add all other connected lines to current Ring

  end; // for i := 0 to BLineRefs1Count-1 do - loop along all BLineRefs1 elements
end; // end of procedure TN_UDLinesCoverage.AssembleRings

//***************************************** TN_UDLinesCoverage.DumpArrays1 ***
// Dump to given Text file:
// BLineRefs1, Rings1, BESegments1, PtrsBESegment1, MDConts
//
procedure TN_UDLinesCoverage.DumpArrays1( FName: string; Mode: integer );
var
  i, C1, C2, Fl: integer;
  PrevPoint: TDPoint;
  FDump: TextFile;
begin
  AssignFile( FDump, FName ); // open output Dump file
  if not FileExists( FName ) then Rewrite( FDump )
  else if (Mode and $01) = 0 then Rewrite( FDump )
                             else Append( FDump );

  if (Mode and $02) <> 0 then
  begin
    WriteLn( FDump, 'Dump file from  ' + K_DateTimeToStr( Now() ) );
    WriteLn( FDump, '' );
  end;

  WriteLn( FDump, Format( 'CurMDCont = %d', [CurMDCont] ) );

  WriteLn( FDump, '***** BLineRefs1 array' );
  WriteLn( FDump, '  i,  Ind,  Fl    Bi,  Ei    C1,  C2' );
  for i := 0 to BLineRefs1Count-1 do with BLineRefs1[i] do
  begin
//    C1 := UDLines.RCXY[UDLInd].X;
//    C2 := UDLines.RCXY[UDLInd].Y;
    UDLines.GetItemTwoCodes( UDLInd, CDimInd, C1, C2 );
    Fl := ((BLFlags and blUsedFlag) shr 12) or (BLFlags and $01);
    WriteLn( FDump, Format( '%3d, %4d,  %.2x   %3d, %3d   %3d, %3d',
                  [i, UDLInd, Fl, IndPtrBegS1, IndPtrEndS1, C1, C2 ] ) );
  end;
  WriteLn( FDump, '' ); // end of  BLineRefs1 array

  WriteLn( FDump, '***** PtrsBESegment1 array' );
  WriteLn( FDump, '  i  (     x    ,      y   )     A      Ind Fl' );
  PrevPoint.X := N_NotADouble;

  for i := 0 to High(PtrsBESegment1) do with PtrsBESegment1[i]^ do
  begin
    if not N_Same( BEPoint, PrevPoint ) then
    begin
      WriteLn( FDump, '' ); // next group
      PrevPoint := BEPoint;
    end;

    Fl := BESFlags and $01;
    WriteLn( FDump, Format( '%3d  (%9.8g, %9.8g) %6.2f  %3d  %.1x',
                           [i, BEPoint.X, BEPoint.Y, Angle, LineInd, Fl ] ) );
  end;
  WriteLn( FDump, '' ); // end of PtrsBESegment1 array

  Close( FDump );
  if (Mode and $04) <> 0 then ShowMessage( 'Dump File  ' + FName + '  was created' );
end; // end_of function TN_UDLinesCoverage.DumpArrays1


//***************************************** TN_UDLinesCoverage.MakeRCoords ***
// Calc RCoords and EnvDRect for all rings in Rings1 array,
// border lines indexes in Rings1 elements are BLineIFs1 array's indexes
//
procedure TN_UDLinesCoverage.MakeRCoords();
var
  i, j: integer;
  TmpInds: TN_IArray;
begin
  N_i := Rings1Count;
  K_UDGControlFlags := K_UDGControlFlags + [K_gcfSysDateUse];

  for i := 0 to Rings1Count-1 do with Rings1[i] do
  begin
    if Length(TmpInds) < NumBLines then
      SetLength( TmpInds, N_Newlength(NumBLines) );

    for j := 0 to NumBLines-1 do
      TmpInds[j] := BLineIFs1[BegBLineInd+j].UDLInd;

    N_MakeRingCoords( UDLines, TmpInds, 0, NumBLines, RCoords );
    EnvDRect := N_CalcLineEnvRect( RCoords, 0, Length(RCoords) );
  end; // for i := 0 to Rings1Count-1 do with Rings1[i] do
  K_UDGControlFlags := K_UDGControlFlags - [K_gcfSysDateUse];
end; // end_of function TN_UDLinesCoverage.MakeRCoords

//************************************** TN_UDLinesCoverage.SortRings ******
// Sort rings in Rings1 array by needed ierarchical order,
// EnvDRect fields (in Rings1) should already be calculated by MakeRCoords,
// on output, sorted rings are in MDCont with given index MDContInd
//
procedure TN_UDLinesCoverage.SortRings( MDContInd: integer );
var
  i, j: integer;

  function R1InsideR2( const R1, R2: TDRect ): boolean; //***** local
  // return True if R1 rect is inside R2 rect
  begin
    if (R1.Left   >= R2.Left)   and
       (R1.Right  <= R2.Right)  and
       (R1.Top    >= R2.Top)    and
       (R1.Bottom <= R2.Bottom)     then
      Result := True
    else
      Result := False;
  end; // end of local function R1InsideR2

  function Ring1InsideRing2( const Ring1, Ring2: TN_MCRing ): boolean; //***** local
  // return True if Ring1 is inside Ring2
  var
    Pos: integer;
  begin
    Result := False;
    if (Ring1.EnvDRect.Left   >= Ring2.EnvDRect.Left)   and
       (Ring1.EnvDRect.Right  <= Ring2.EnvDRect.Right)  and
       (Ring1.EnvDRect.Top    >= Ring2.EnvDRect.Top)    and
       (Ring1.EnvDRect.Bottom <= Ring2.EnvDRect.Bottom)     then
    begin // Ring1.EnvDRect is inside Ring2.EnvDRect
      Pos := N_DPointInsideDRing( @Ring2.RCoords[0], Length(Ring2.RCoords),
                                           Ring2.EnvDRect, Ring1.RCoords[0] );
      if Pos = 0 then Result := True;
    end;
  end; // end of local function R1InsideR2

  procedure AddChildRingInd( ParentRingInd, ChildRingInd: integer ); //*** local
  // add one given Index (ChildRingInd in Rings1 array) to ChildRings array of
  // a ring with ParentRingInd in Rings1 array
  var
    OldLength: integer;
  begin
    OldLength := Length(Rings1[ParentRingInd].ChildRingInds);
    SetLength( Rings1[ParentRingInd].ChildRingInds, OldLength + 1 );
    Rings1[ParentRingInd].ChildRingInds[OldLength] := ChildRingInd;
  end; // end of local procedure AddChildRingInd

  procedure AddChildRings( MDContInd, ALevel, RingInd: integer ); //*** local
  // add to contour with given index (MDContInd in MDConts array) all child
  // rings with given ALevel of ring with given index (RingInd in Rings1 array)
  var
    i: integer;
  begin
    with Rings1[RingInd] do
    begin
      if Level <> ALevel then Exit; // not needed level

      //***** add given Ring to given MDCont
      with MDConts[MDContInd] do
      begin
        if High(Rings) <= RingsCount then
          SetLength( Rings, Round(1.5*RingsCount)+1 );

        Rings[RingsCount].Flags := 0;
        Rings[RingsCount].EnvDRect := EnvDRect;
        Rings[RingsCount].Level := ALevel;
        Rings[RingsCount].RCoords := nil;
        Rings[RingsCount].ChildRingInds := nil;
        Rings[RingsCount].NumBLines := NumBLines;
        Rings[RingsCount].BegBLineInd := BLineIFsCount;

        //***** add Blines to MDConts[MDContInd]
        for i := BegBLineInd to BegBLineInd+NumBLines-1 do
          AddBLineToMDCont( MDContInd, BLineIFs1[i].UDLInd,
                                       BLineIFs1[i].BLFlags );

        Inc(RingsCount);
      end; // with MDConts[MDContInd] do

      for i := 0 to High(ChildRingInds) do // add next level child rings
        AddChildRings( MDContInd, ALevel+1, ChildRingInds[i] );

    end; // with Rings1[RingInd] do
  end; // end of local procedure AddChildRings

begin //***** SortRings main body
  if MDContInd = 38 then
    N_i := Rings1Count;
  //***** compare all pairs of rings and find Child rings
  for i := 0 to Rings1Count-1 do
  begin
    for j := i+1 to Rings1Count-1 do
    begin
//##      if R1InsideR2( Rings1[i].EnvDRect, Rings1[j].EnvDRect ) then
      if Ring1InsideRing2( Rings1[i], Rings1[j] ) then
           AddChildRingInd( j, i );
//##      if R1InsideR2( Rings1[j].EnvDRect, Rings1[i].EnvDRect ) then
      if Ring1InsideRing2( Rings1[j], Rings1[i] ) then
         AddChildRingInd( i, j );
    end; // end for j
  end; // end for i

  //***** loop along all ChildRingInds and set Level for all rings
  for i := 0 to Rings1Count-1 do
    for j := 0 to High(Rings1[i].ChildRingInds) do
      Inc( Rings1[ Rings1[i].ChildRingInds[j] ].Level );

  //***** sort rings using info about theirs childs and it's level
  MDConts[MDContInd].BLineIFsCount := 0; // clear previous data
  for i := 0 to Rings1Count-1 do
  begin
    if Rings1[i].Level > 0 then Continue; // not zero level ring
    AddChildRings( MDContInd, 0, i );
  end; // for i := 0 to High(Rings1)Rings1Count-1 do
end; // end of procedure TN_UDLinesCoverage.SortRings

//************************************ TN_UDLinesCoverage.MakeMDContsRings ***
// Make Rings arrays for all MDConts elements
//
procedure TN_UDLinesCoverage.MakeMDContsRings();
var
  i, j, FPInd, NumInds: integer;
begin
  for j := 0 to High(MDConts) do // loop along all MDConts
  begin
    CurMDCont := j; // used only in Dump creation

    //***** create and fill BLineRefs1 array by MDConts[j].BLineIFs
    with MDConts[j] do
    begin
      if BLineIFsCount = 0 then Continue; // no such contour
      BLineRefs1Count := BLineIFsCount;
      SetLength( BLineRefs1, BLineRefs1Count );
      for i := 0 to BLineIFsCount-1 do
      begin
        BLineRefs1[i].UDLInd  := BLineIFs[i].UDLInd;
        BLineRefs1[i].BLFlags := BLineIFs[i].BLFlags;
      end;
    end; // with MDConts[j] do

    //***** create and fill BESegments1 and PtrsBESegment1 arrays
    SetLength( BESegments1,    2*Length(BLineRefs1) );
    SetLength( PtrsBESegment1, 2*Length(BLineRefs1) );

    for i := 0 to High(BLineRefs1) do
    with UDLines do
    begin
      UDLines.GetItemInds( BLineRefs1[i].UDLInd, FPInd, NumInds );
      PtrsBESegment1[2*i] := @BESegments1[2*i];
      BESegments1[2*i].BEPoint := LDCoords[FPInd];
      BESegments1[2*i].LineInd := i;
      BESegments1[2*i].BESFlags := 0;  // Beg Point (segment) ( DC[0] ) flag
      BESegments1[2*i].Angle := N_ArcTan2( LDCoords[FPInd+1].X-LDCoords[FPInd].X,
                                           LDCoords[FPInd+1].Y-LDCoords[FPInd].Y );

      PtrsBESegment1[2*i+1] := @BESegments1[2*i+1];
      BESegments1[2*i+1].BEPoint := LDCoords[FPInd+NumInds-1];
      BESegments1[2*i+1].LineInd := i;
      BESegments1[2*i+1].BESFlags := 1; // End Point (segment) ( DC[High(DC)] ) flag
      BESegments1[2*i+1].Angle := N_ArcTan2(
                        LDCoords[FPInd+NumInds-2].X-LDCoords[FPInd+NumInds-1].X,
                        LDCoords[FPInd+NumInds-2].Y-LDCoords[FPInd+NumInds-1].Y  );
    end; // for i := 0 to High(BLineRefs1) do with UDLineRefs[BLineRefs1[i].UDLInd].UDLine do

    //***** Sort pointers to elements of BESegments1 array,
    //      result is sorted PtrsBESegment1 array
    N_SortPointers( TN_PArray(PtrsBESegment1), 0, N_CompareDPointAndAngle );

    //***** fill IndPtrBegS1 and IndPtrEndS1 fields of BLineRefs array
    for i := 0 to High(PtrsBESegment1) do
    begin
      with PtrsBESegment1[i]^ do
      begin
      if (BESFlags and $01) = 0 then
        BLineRefs1[LineInd].IndPtrBegS1 := i
      else
        BLineRefs1[LineInd].IndPtrEndS1 := i;
      end;
    end; // for i := 0 to High(PtrsBESegment1) do

N_LCAdd( 5, '**********************  Contour = '+IntToStr(j) );
    AssembleRings();
    MakeRCoords();
    SortRings( j ); // consumes 80% of whole time!
    MakeRCoords();
  end; // for j := 0 to High(MDConts) do
end; // end of procedure TN_UDLinesCoverage.MakeMDContsRings

//*********************************** TN_UDLinesCoverage.CreateMapContours ***
// create contours (TN_UContours object) from MDConts array
// (base UDLines (or UFLines) child is not added!)
//
procedure TN_UDLinesCoverage.CreateMapContours( UContours: TN_UContours );
var
  i, j, ItemInd, RingInd, LineInd: integer;
begin
  UContours.InitItems( Length(MDConts)+1, 1000, 4000 );
  ItemInd := 0;
  RingInd := 0;
  LineInd := 0;

  for i := 0 to High(MDConts) do with MDConts[i], UContours do // loop along all contours
  begin
    if BLineIFsCount = 0 then Continue; // no such contour

    UContours.Items[ItemInd].CFInd := RingInd;
//    UContours.Items[ItemInd].CCode := Code;
//    UContours.SetItemTwoCodes( ItemInd, 0, Code, -1 );
    Inc(ItemInd);

    if Length(CRings) < (RingInd+RingsCount) then
      SetLength( CRings, N_NewLength(RingInd+RingsCount) );

    for j := 0 to RingsCount-1 do with Rings[j] do // loop along contour's rings
    begin
      CRings[RingInd].RFlags   := Level;
      CRings[RingInd].RLInd    := LineInd+BegBLineInd;
      CRings[RingInd].RFCoords := nil;
      CRings[RingInd].RDCoords := nil;
      Inc(RingInd);
    end; // for j := 0 to RingsCount do with Rings[j] do

    if Length(LinesInds) < (LineInd+BLineIFsCount) then
      SetLength( LinesInds, N_NewLength(LineInd+BLineIFsCount) );

    for j := 0 to BLineIFsCount-1 do with BLineIFs[j] do // all contour's BLines
    begin
      LinesInds[LineInd] := UDLInd;
      Inc( LineInd );
    end;

  end; // for i := 0 to High(MDConts) do

  with UContours do // add last Item and set proper arrays length
  begin
    WNumItems := ItemInd;
//    Items[ItemInd].CCode := 0;
    Items[ItemInd].CCInd := 0;
//    SetItemTwoCodes( ItemInd, 0, 0, -1 );
    Items[ItemInd].CFInd := RingInd;
    SetLength( Items, ItemInd+1 );

    FillChar( CRings[RingInd], Sizeof(CRings[0]), 0 );
    CRings[RingInd].RLInd := LineInd;
    SetLength( CRings, RingInd+1 );

    SetLength( LinesInds, LineInd );
  end;

  ItemInd := 0;
  for i := 0 to High(MDConts) do
  with MDConts[i], UContours do // loop along all contours
  begin
    if BLineIFsCount = 0 then Continue; // no such contour
    N_i := Code;
    SetItemTwoCodes( ItemInd, 0, Code, -1 );
    Inc(ItemInd);
  end; // for i := 0 to High(MDConts) do


end; // end of procedure TN_UDLinesCoverage.CreateMapContours

//***************************************** TN_UDLinesCoverage.FindVertex ***
// find vertex (LineInd, SegmInd), nearest to given point coords
//
procedure TN_UDLinesCoverage.FindVertex( const GivenPoint: TDPoint;
                                          out LineInd, SegmInd: integer );
var
  i, j, FPInd, NumInds: integer;
  Dist, MinDist: double;
  DC: TN_DPArray;
begin
  MinDist := 1e300;
  DC := nil; // to avoid warning
  for i := 0 to UDLineRefsCount-1 do with UDLines do
  begin
    GetItemInds( i, FPInd, NumInds );
    DC := Copy( LDCoords, FPInd, NumInds );

    for j := 0 to High(DC) do with DC[j] do
    begin
      Dist := Sqrt( (GivenPoint.X-X)*(GivenPoint.X-X) +
                    (GivenPoint.Y-Y)*(GivenPoint.Y-Y) );
      if Dist < MinDist then
      begin
        MinDist := Dist;
        LineInd := i;
        SegmInd := j;
      end;
    end; // for j := 0 to High(DC) do with DC[j] do
  end; // for i := 0 to UDLineRefsCont-1 do with UDLineRefs[i] do

end; // end_of function TN_UDLinesCoverage.FindVertex


//****************** Global procedures **********************

//************************************** N_UDlinesToUDContours2 ******
// convert AUDLines to AUContours (Assemble Contours):
//
// OuterCode - Outer (imaginable) Contour Code
// (UDLines are NOT added as UContours Child!)
//
procedure N_UDlinesToUDContours2( AOuterCode, ACDimInd: integer;
                              AUDLines: TN_ULInes; AUContours: TN_UContours );
var
  UDLC: TN_UDLinesCoverage;
begin
  Assert( AUDLines.WLCType = N_DoubleCoords, 'Not Double Coords!' );

  UDLC := TN_UDLinesCoverage.Create;

  with UDLC do
  begin
    CDimInd := ACDimInd;
    AddMapUDLines( AUDLines );
    CreateMDConts( AOuterCode ); // (with empty Rings arrays)
    MakeMDContsRings ();
    CreateMapContours ( AUContours );
  end; // with UDLC do

  UDLC.Free;
end; // end of procedure N_UDlinesToUDContours2

//***** types used in the following N_LinesToContBorders procedure:

type TSegmInfo1 = record //***** Info about Line Segment (local type)
  SCenter: TDPoint;    // Segment's "Center" coords (X1+X2, Y1+Y2)
  SPtrInd: integer;    // Sorted Pointer index
  SRC1, SRC2: integer; // Segment's Region Codes (if any)
  SLineInd: integer;   // Segment's Line code
  SSegmInd: integer;   // Segment's Line code
  RCFl:    integer;    // Region Code or "Processed flag" if = -2
end; // type TSegmInfo = record
type TSegmInfoArray1 = array of TSegmInfo1;
type TPSegmInfo1 = ^TSegmInfo1;

//************************************************ N_LinesToContBorders ***
// convert Lines to Contours borders
// (for converting Shape Polygon lines to Contours borders)
//
// InpUDLines - input Lines (closed Contours rings, as in Shape polygons)
// OutUALines - output Contours Borders
//
procedure N_LinesToContBorders( InpUDLines: TN_ULines; OutUALines: TN_ULines; ACDimInd: integer );
var
//  i,
  Li, Si, MaxLi, LSi, MaxLSi, FPInd, NumInds: integer;
  PrevRC2, NewRC2, OutDCInd, CurRC1, CurRC2: integer;
  DLItem: TN_ULinesItem;
  OutDC: TN_DPArray;
  Segms: TSegmInfoArray1;
  Ptrs: TN_PArray;
//  PSrcPChar: PAnsiChar;
  Label Fin;

  function GetRC2(): integer; // local function, return RC2 of neighbour
                        // segment with same coords or 0 if no such a segment
  var
    Ind: integer;
    PSegm: TPSegmInfo1;
  begin
    if Segms[LSi].SPtrInd > 0 then // check previous (in Ptrs array)
    begin
      Ind := Segms[LSi].SPtrInd - 1;
      PSegm := TPSegmInfo1(Ptrs[Ind]);
      if (PSegm^.SCenter.X = Segms[LSi].SCenter.X) and
         (PSegm^.SCenter.Y = Segms[LSi].SCenter.Y)    then // segm exists
      begin
        Result := PSegm^.RCFl;
        PSegm^.RCFl := -2; // set already processed flag
        Exit;
      end;


    end; // if Segms[LSi].SPtrInd > 0 then // check previous

    if Segms[LSi].SPtrInd < High(Ptrs) then // check next (in Ptrs array)
    begin
      Ind := Segms[LSi].SPtrInd + 1;
      PSegm := TPSegmInfo1(Ptrs[Ind]);
      if (PSegm^.SCenter.X = Segms[LSi].SCenter.X) and
         (PSegm^.SCenter.Y = Segms[LSi].SCenter.Y)    then // segm exists
      begin
        Result := PSegm^.RCFl;
        PSegm^.RCFl := -2; // set already processed flag
        Exit;
      end;
    end; // if Segms[LSi].SPtrInd < High(Ptrs) then // check next

    Result := 0; // no segments with same coords - part of outer border
  end; // end of Local function GetRC2

  procedure DumpSegms(); // local
  // dump segments info
  var
    i, ibeg, iend: integer;
    TmpSL: TStringList;
  begin
    TmpSL := TStringList.Create;
    TmpSL.Add( 'Error, Dump Segms' );
    TmpSL.Add( '' );
    ibeg := Max( 0, Segms[LSi].SPtrInd - 6 );
    iend := Min( High(Ptrs), Segms[LSi].SPtrInd + 6 );

    TmpSL.Add( '  i   (       x  ,       y  )  RCFL  LInd  SInd ' );

    for i := ibeg to iend do
    with TPSegmInfo1(Ptrs[i])^ do
    begin
      TmpSL.Add( Format( '%3d ( %9.7g, %9.7g) %4d  %4d  %4d',
                           [i,SCenter.X,SCenter.Y,RCFl,SLineInd,SSegmInd ] ) );
    end; // for i := ibeg to iend do

    N_AddStr( 1, TmpSL.Text );
    TmpSL.Free;
  end; // end of Local procedure DumpSegms()

  procedure GetLinesInds( LSi: integer; var LInds: TN_IArray ); // local
  // get ordered Line Inedexes of all Lines, in which LSi Segment is part of
  // and set CurRC1, CurRC2
  var
    Ind: integer;
    CurX, CurY: float;
  begin
    LInds[0] := 0; // number of Indexes in Linds array
    CurRC1 := -1;
    CurRC2 := -1;
    CurX := Segms[LSi].SCenter.X;
    CurY := Segms[LSi].SCenter.Y;

    Ind := Segms[LSi].SPtrInd;
    while True do // find first segment (in ordered Ptrs array) with same SCenter
    begin
      Dec(Ind);
      if Ind < 0 then Break;

      with TPSegmInfo1(Ptrs[Ind])^ do
      if (SCenter.X <> CurX) or (SCenter.Y <> CurY) then // no more segments
        Break;
    end; // while True do // find first segment
    Inc( Ind );

    //***** Here: Ptrs[Ind] points to first segment with same SCenter

    while True do // check next (in ordered Ptrs array) segments
    begin
      with TPSegmInfo1(Ptrs[Ind])^ do
      begin
        //***** Add one Line Index for cur Segment to LInds list

        if CurRC1 = -1 then // RC1 not set yet
        begin
          if SRC1 <> -1 then CurRC1 := SRC1;
          if SRC2 <> -1 then CurRC2 := SRC2;
        end;


        if (SCenter.X <> CurX) or (SCenter.Y <> CurY) then // no more segments
          Break;
      end;

      if Ind >= MaxLSi then Break;
      Inc(Ind); // go to next segment
    end; // while True do // check next (in ordered Ptrs array) segments

  end; // procedure GetLinesInds (local)

  procedure AddOutItem(); // local
  // add DLItem to OutDLines
  var
    C0, C1, C2: integer;
  begin
    DLItem.AddPartCoords( OutDC, 0, OutDCInd );
//    DLItem.ICode := InpUDLines.Items[Li].CCode;
//    DLItem.IRC1  := InpUDLines.RCXY[Li].X;
//    DLItem.IRC2  := PrevRC2; //??
//    DLItem.IRC2  := NewRC2; //??
//    DLItem.INumRegCodes := 2;
//    DLItem.IRegCodes[0] := InpUDLines.RCXY[Li].X;
//    DLItem.IRegCodes[1] := PrevRC2;

    InpUDLines.GetItemThreeCodes( Li, C0, C1, C2 );
//    DLItem.SetThreeCodes( C0, C1, PrevRC2 );

    OutUALines.ReplaceItemCoords( DLItem, C0, C1, C2 );
    DLItem.Init();
  end; // procedure AddOutItem(); // local

begin //***** body of N_LinesToContBorders procedure

  OutDCInd := 0;   // to avoid varning

  MaxLi := InpUDLines.WNumItems-1;
  SetLength( Segms, 1000 ); // initial size
  SetLength( OutDC, 1000 ); // initial size
  LSi := 0;

  OutUALines.InitItems( 2*InpUDLines.WNumItems, Length(InpUDLines.LDCoords) );
  OutUALines.WAccuracy := InpUDLines.WAccuracy;
  OutUALines.WFlags    := 0;
  OutUALines.WComment  := 'From ' + InpUDLines.ObjName;
  DLItem := TN_ULinesItem.Create( N_DoubleCoords );
//  SetLength( DLItem.IRegCodes, 2 );
//  DLItem.INumRegCodes := 2;

  for Li := 0 to MaxLi do //*** fill all Segms[i] fields except SPtrInd
  begin
    InpUDLines.GetItemInds( Li, FPInd, NumInds );

    for Si := FPInd to FPInd+NumInds-2 do
    begin
      if LSi > High(Segms) then
        SetLength( Segms, N_NewLength(High(Segms)) );

      with Segms[LSi], InpUDLines do
      begin
        SCenter.X := 0.5*(LDCoords[Si].X + LDCoords[Si+1].X);
        SCenter.Y := 0.5*(LDCoords[Si].Y + LDCoords[Si+1].Y);
//        RCFl := InpUDLines.RCXY[Li].X;
        InpUDLines.GetItemTwoCodes( Li, ACDimInd, RCFl, N_i );

        SLineInd := Li;
        SSegmInd := Si - FPInd;
      end;
      Inc(LSi);
    end; // for Si := 0 to MaxSi do
  end; // for Li := 0 to MaxLi do

  SetLength( Ptrs, LSi );
  MaxLSi := LSi - 1;

  for LSi := 0 to MaxLSi do
    Ptrs[LSi] := TN_BytesPtr(@Segms[LSi]);

  N_SortPointers( Ptrs, 0, N_CompareDPoints ); // sort Ptrs

  for LSi := 0 to MaxLSi do // fill Segms[i].SPtrInd fields
    TPSegmInfo1(Ptrs[LSi])^.SPtrInd := LSi;

  //***** all fields of Segms and Ptrs arrays are OK

  PrevRC2 := -1; // not def (any new is OK)
  LSi := 0;

  for Li := 0 to MaxLi do //*** create contour borders from Line segments
  with InpUDLines do
  begin
    InpUDLines.GetItemInds( Li, FPInd, NumInds );

    for Si := 0 to NumInds-2 do
    begin
      if (Segms[LSi].RCFl = -2) then // segm was already processed, skip it
      begin
        Inc(LSi);
        if PrevRC2 <> -1 then AddOutItem(); // close ContBorder
        PrevRC2 := -1; // not def (any new is OK)
        Continue;
      end;

      //*** Here: add cur segment to new or existing ContBorder

      NewRC2 := GetRC2();
      if NewRC2 = -2 then // error? or three segments?
      begin
        DumpSegms();
        if PrevRC2 <> -1 then AddOutItem(); // close previous
        goto Fin;

        Assert( NewRC2 <> -2, 'Bad NewRC2' );
        if PrevRC2 <> -1 then AddOutItem(); // close previous

        //***** create new
        OutDCInd := 0;
        PrevRC2 := -1;
        Continue;
      end;
      Assert( NewRC2 <> -2, 'Bad NewRC2' );

      if PrevRC2 <> NewRC2 then // close previous ContBorder and create new one
      begin
        if PrevRC2 <> -1 then AddOutItem(); // close previous

        //***** create new
        OutDCInd := 0;
        PrevRC2 := NewRC2;
      end; // if PrevRC2 <> NewRC2 then

      //***** add cur segment to ContBorder

      if High(OutDC) < OutDCInd then
        SetLength( OutDC, N_NewLength(OutDCInd) );

      if OutDCInd = 0 then // first segment, add first point
      begin
//        OutDC[0] := InpDC[Si];
        OutDC[0] := LDCoords[FPInd+Si];

        OutDCInd := 1;
      end;

//      OutDC[OutDCInd] := InpDC[Si+1]; // add segment's last point
      OutDC[OutDCInd] := LDCoords[FPInd+Si+1]; // add segment's last point
      Inc(OutDCInd);
      Inc(LSi);
    end; // for Si := 0 to MaxSi do

    if PrevRC2 <> -1 then AddOutItem();
    PrevRC2 := -1; // not def (any new is OK)
  end; // for Li := 0 to MaxLi do

  Fin: //**********************
  OutUALines.CalcEnvRects();
  OutUALines.CompactSelf();
end; // end of procedure N_LinesToContBorders

{
//************************************************** N_ProcessCommands2 ***
// Process Commands in string array of TN_UDPMCommands obj
//
// MPGData      - Main Panel Data (global context)
// Mode         - call context mode:
//                =1 - call from GetLayoutRect,
//                =2 - call from GetLayoutRect,
// UPPMCommands - obj with command lines
// CommandInd   - on input:  first command to process Index,
//                on output: last processed command index + 1
//    Return - "Return" command parametr
//
// var MPGData: TN_MPGData;  UDPMCommands: TN_UDPMCommands;
function N_ProcessCommands2( Mode: integer;
            var CommandInd: integer ): integer;
var
  BrushColor, PenColor, PenWidth, DashSize, SkipSize: integer;
  FontColor, FontSize, FontStyle, BasePointPos, FontBackColor: integer;
  TicSize1, TicSize2, StringScalarInd, SizeMode, Style: integer;
  ArrowLength, ArrowWidth, StepX, StepY, GrayValue, GrayDotSize: integer;
  PaletteInd, PaletteColor, MaxCommandInd: integer;
  FontName, ParStr, Command, Str, Fmt, StringScalarName: string;
  BaseZ, StepZ, DXU, DYU, LineOfs: double;
  PSrcPChar: PAnsiChar;
  ZMin, ZMax: double;
  LinePoints: TN_DPArray;
  BasePoint: TDPoint;
  ADRect1, ADRect2: TDRect;
  ShiftXY: TFPoint;
begin
  //******************************* to avoid warning
  PenColor := 0;
  Result := 0;

  SetLength( LinePoints, 2 );
//  MaxCommandInd := High(UDPMCommands.CmdLines);

//  with MPGData.RBuf.OCanv do // drawing context
  with N_ActiveRFrame.OCanv do // drawing context
  while True do // loop along commands
  begin

    if CommandInd > MaxCommandInd then // no more commands
    begin
      CommandInd := -1;
      Exit;
    end;

//    ParStr := UDPMCommands.CmdLines[CommandInd]; // get command line
    Inc(CommandInd);
    Command := N_ScanToken( ParStr ); // get command name

//    if          Command = 'SetPen'     then //***** Set Pen Attributes
//    end else if Command = 'SetBrush'   then //***** Set Brush Attributes
//    end else if Command = 'SetFont'    then //***** Set Font Attributes
//    end else if Command = 'DrawSegm'   then //***** Draw Line Segment
//    end else if Command = 'SetTics'    then //***** Set Tics positions
//    end else if Command = 'DrawTics'   then //***** Draw Tics
//    end else if Command = 'DrawString' then //***** Draw Label
//    end else if Command = 'DrawAxisArrow' then //** Draw Arrow
//    end else if Command = 'DrawRect'      then //** Draw Rect
//    end else if Command = 'DrawCLines'    then //** Draw Coords Lines
//    end else if Command = 'DrawAxisMarks' then //** Draw Axis text Marks
//    end else if Command = 'Return'        then //** Return command
//    end else if Command = 'SetNewUC'      then //** Set New User Coords
//    end else if Command = 'SetOldUC'      then //** Set Old User Coords
//    end else if Command = 'SetPalColor'   then //** Set Palette Color
//    end else if Command = 'SetPalFont'    then //** Set Palette Font
//    end else if Command = 'SetFontSize'   then //** Set Font Size
//    end else if Command = 'NewPattern'    then //** Create new white pattern
//    end else if Command = 'GrayPattern'   then //** Create new white pattern
//    end else if Command = 'PatternLines'  then //** Draw black lines in Pattern

    if Command[1] = ';' then Continue;

    if          Command = 'SetPen'   then //***** Set Pen Attributes
    begin
//      PenColor := N_PrepareColor( N_ScanInteger( ParStr ), MPGData.ColorPalette );
      if ParStr = '' then
        PenWidth := 10
      else
        PenWidth := N_ScanInteger( ParStr );
      SetPenAttribs( PenColor, PenWidth );
      //***** end of Command = 'SetPen'

    end else if Command = 'SetBrush' then //***** Set Brush Attributes
    begin

//      BrushColor := N_PrepareColor( N_ScanInteger( ParStr ), MPGData.ColorPalette );
      SetBrushAttribs( BrushColor );
      //***** end of Command = 'SetBrush'

    end else if Command = 'SetFont'  then //***** Set Font Attributes
    begin
      FontName  := N_ScanToken( ParStr );
      FontColor := PenColor;
      FontSize  := N_ScanInteger( ParStr );
      FontStyle := N_ScanInteger( ParStr );
      if ParStr <> '' then
//        FontBackColor := N_PrepareColor( N_ScanInteger( ParStr ), MPGData.ColorPalette )
      else
        FontBackColor := -1; // empty color
        N_i := FontBackColor;
        N_i := FontStyle;
        N_i := FontSize;
        N_i := FontColor;
//      SetFontAttribs( FontName, FontSize, FontStyle, FontColor, FontBackColor );
      //***** end of Command = 'SetFont'

    end else if Command = 'DrawSegm' then //***** Draw Line Segement
    begin

      LinePoints[0] := N_ScanDPoint( ParStr );
      LinePoints[1] := N_ScanDPoint( ParStr );
      DrawUserPolyline1( LinePoints );
      //***** end of Command = 'DrawSegm'

    end else if Command = 'SetTics'  then //***** Set Tics params
    begin

      LinePoints[0] := N_ScanDPoint( ParStr );
      LinePoints[1] := N_ScanDPoint( ParStr );
      BaseZ := N_ScanDouble( ParStr );
      StepZ := N_ScanDouble( ParStr );
      SetTics( LinePoints[0], LinePoints[1], BaseZ, StepZ );
      //***** end of Command = 'SetTics'

    end else if Command = 'DrawTics' then //***** Draw Tics
    begin
      TicSize1 := N_ScanInteger( ParStr ); // in LLW
      TicSize2 := N_ScanInteger( ParStr );
      DrawAxisTics( TicSize1, TicSize2 );
      //***** end of Command = 'DrawTics'

    end else if Command = 'DrawString' then //***** Draw String
    begin

      BasePoint := N_ScanDPoint( ParStr );
      ShiftXY   := N_ScanFPoint( ParStr ); // in LLW
      BasePointPos := N_ScanInteger( ParStr );
      Str       := N_ScanToken( ParStr );

      if Str = '@' then // string name (Vector Name(Ind) + Scalar Name(Ind))
      begin

        StringScalarName := N_ScanToken( ParStr );
        StringScalarInd := StrToIntDef( StringScalarName, N_NotAnInteger );

        if StringScalarInd = N_NotAnInteger then
//          Str := N_GetStringScalar( N_GlobalScalars, StringScalarName )
//        else
//          N_GlobalScalars.GetDEData( StringScalarInd, Str, K_isString );
      end;

//      DrawUserString( BasePoint, ShiftXY, BasePointPos, Str );
      //***** end of Command = 'DrawString'

    end else if Command = 'DrawAxisArrow' then //***** Draw Arrow
    begin
      BaseZ := N_ScanDouble( ParStr );
      ArrowLength := N_ScanInteger( ParStr ); // in LLW
      ArrowWidth := N_ScanInteger( ParStr ); // in LLW
      DrawAxisArrow( BaseZ, ArrowLength, ArrowWidth, 0 );
      //***** end of Command = 'DrawAxisArrow'

    end else if Command = 'DrawRect' then //***** Draw Rect
    begin
      ADRect1 := N_ScanDRect( ParStr );
//      DrawUserRect( ADRect1 );
      //***** end of Command = 'DrawRect'

    end else if Command = 'DrawCLines' then //***** Draw Coords Lines
    begin
      ZMin     := N_ScanDouble( ParStr );
      ZMax     := N_ScanDouble( ParStr );
      DashSize := N_ScanInteger( ParStr );
      SkipSize := N_ScanInteger( ParStr );
      DrawCoordsLines( ZMin, ZMax, DashSize, SkipSize );
      //***** end of Command = 'DrawCLines'

    end else if Command = 'DrawAxisMarks' then //***** Draw Axis text Marks
    begin
      ShiftXY      := N_ScanFPoint( ParStr ); // in LLW
      BasePointPos := N_ScanInteger( ParStr );
      Fmt          := N_ScanToken( ParStr );
//      DrawAxisMarks( ShiftXY, BasePointPos, Fmt );
      //***** end of Command = 'DrawAxisMarks'

    end else if Command = 'Return'   then //***** Return command
    begin
      Result := N_ScanInteger( ParStr );
      Exit;
      //***** end of Command = 'Return'

    end else if Command = 'SetNewUC'   then //***** Set New User Coords
    begin
      ADRect1 := N_ScanDRect( ParStr );
      ADRect2 := N_ScanDRect( ParStr );
//      SetNewUserCoords( ADRect1, ADRect2 );
      //***** end of Command = 'SetNewUC'

    end else if Command = 'SetOldUC'   then //***** Set Old User Coords
    begin
//      SetOldUserCoords();
      //***** end of Command = 'SetOldUC'

    end else if Command = 'SetPalColor'   then //***** Set Palette Color

    begin
      PaletteInd := N_ScanInteger( ParStr );
      PaletteColor := N_ScanInteger( ParStr );
//      with MPGData do
//      begin
//        if (PaletteInd >= Low(ColorPalette)) and
//           (PaletteInd <= High(ColorPalette)) then
//        begin
//          ColorPalette[PaletteInd] := PaletteColor;
//          if (NumPaletteColors-1) < PaletteInd then
//            NumPaletteColors := PaletteInd + 1;
//        end;
//      end;
      //***** end of Command = 'SetPalColor'

    end else if Command = 'SetPalFont'   then //***** Set Palette Font
    begin
      PaletteInd := N_ScanInteger( ParStr );
      N_i := PaletteInd;
//      with MPGData do
//      begin
//        if (PaletteInd >= Low(FontPalette)) and
//           (PaletteInd <= High(FontPalette)) then
//          FontPalette[PaletteInd] := MainCanvas.Font;
//      end;
      //***** end of Command = 'SetPalFont'

    end else if Command = 'SetFontSize'   then //***** Set Font Size
    begin
      SizeMode := N_ScanInteger( ParStr );
      DXU := N_ScanDouble( ParStr );
      DYU := N_ScanDouble( ParStr );
      Str := ParStr;
      SetFontSize( SizeMode, DXU, DYU, Str );
      //***** end of Command = 'SetFontSize'
// PatInd LWidth LStepX LStepY LOfs - Draw black lines in Pattern

    end else if Command = 'NewPattern'  then //***** Create new white pattern
    begin
      PaletteInd := N_ScanInteger( ParStr );
      StepX := N_ScanInteger( ParStr );
      StepY := N_ScanInteger( ParStr );
//      BrushColor := N_PrepareColor( N_ScanInteger( ParStr ), MPGData.ColorPalette );
//      MPGData.PatternPalette.CreateEntry( PaletteInd, StepX, StepY, BrushColor );
      //***** end of Command = 'NewPattern'

    end else if Command = 'GrayPattern'  then //***** Create new white pattern
    begin
      PaletteInd := N_ScanInteger( ParStr );
      Style      := N_ScanInteger( ParStr );
      GrayValue  := N_ScanInteger( ParStr );
      GrayDotSize := N_ScanInteger( ParStr );
//      MPGData.PatternPalette.DrawGray( PaletteInd, Style, GrayValue, GrayDotSize );
      //***** end of Command = 'GrayPattern'

    end else if Command = 'PatternLines' then //*****  Draw black lines in Pattern
    begin
      PaletteInd := N_ScanInteger( ParStr );
      PenWidth := N_ScanInteger( ParStr );
      StepX := N_ScanInteger( ParStr );
      StepY := N_ScanInteger( ParStr );
      LineOfs := N_ScanDouble( ParStr );
//      PenColor := N_PrepareColor( N_ScanInteger( ParStr ), MPGData.ColorPalette );
//      MPGData.PatternPalette.DrawLines( PaletteInd, PenColor, PenWidth,
//                                                  StepX, StepY, LineOfs );
      //***** end of Command = 'PatternLines'

    end else if Command = 'XXX'   then //*****
    begin
      //***** end of Command = 'XXX'

    end else if Command = 'XXX'   then //*****
    begin
    end else
    begin
      Assert( False, 'Invalid Command: "' + Command + '"' );
    end;
  end; // while True do // loop along command lines
end; //*** end of procedure N_ProcessCommands2

//****************************************** N_DelSmallClosedLines ***
// Dlete all Small Closed Lines (with EnvRect less than given RecSize)
//      InpLinesDir - Input LinesDir
//      OutLinesDir - Output LinesDir
//      RecSize     - given min possible EnvRect size
//
procedure N_DelSmallClosedLines( InpLinesDir, OutLinesDir: TN_UDBase;
                                                          RecSize: double );
var
  i, MaxInd: integer;
  EnvRectSize: double;
  InpUDLine, OutUDLine: TN_UDDLine;
  EnvRect: TFRect;
begin
  MaxInd := InpLinesDir.DirHigh();
  OutLinesDir.ClearChilds();

  for i := 0 to MaxInd do
  begin
    InpUDLine := TN_UDDLine(InpLinesDir.DirChild(i));
    if InpUDLine = nil then Continue;
    EnvRect := N_CalcLineEnvRect( InpUDLine.DC );
    EnvRectSize := N_FRectSize( EnvRect );

    if EnvRectSize < RecSize then Continue; // skip too small Line

    OutUDLine := TN_UDDLine.Create();
    OutLinesDir.AddOneChild( OutUDLine );
    OutUDLine.CopyFields( InpUDLine );
  end; // for i := 0 to MaxInd do
end; // end of procedure N_DelSmallClosedLines

}

//***** next types are used only in the following N_RemoveSameFragments procedure

type TSegmInfo = packed record //***** Info about Line Segment (local type)
                       // first three fields used in Sort procedure
  PP1: Pointer; // Pointer to float or double P1 point (upper left segm. end)
  PP2: Pointer; // Pointer to float or double P2 point (lower right segm. end)
  SLineInd: integer;   // Segment's Line Index

  SegmInd: integer;    // for debug only
  SPtrInd: integer;    // index in Sorted Ptrs array
                       // ( TPSegmInfo(Ptrs[i])^.SPtrInd = i )
end; // type TSegmInfo = packed record
type TSegmInfoArray = array of TSegmInfo;
type TPSegmInfo = ^TSegmInfo;

//************************************************ N_RemoveSameFragments ***
// Convert InpULines with possibly same Fragments to OutULines with exactly
// same Vertexes but without any same Fragments.
// Zero size segments and Lines are not included in OutULines.
// MultiPart Items converted to SinglePart Items
// (is used e.g. for converting Shape Polygon lines to Contours borders)
//
// AMode - statistcs mode:
//         =0 - none
//         =1 - time and summary
//         =2 - all segments coords
//
procedure N_RemoveSameFragments( InpULines, OutULines: TN_ULines;
                                               SL: TStrings; AMode: integer );
var
  i, Li, Si, Pi, MaxLi, LSi, MaxLSi, NumParts, OutDCInd: integer;
  FirstInd, NumInds, NumRemoved: integer;
  Str: string;
  FTmp1, FTmp2: TFPoint;
  DTmp1, DTmp2: TDPoint;
  MemPtr: TN_BytesPtr;
  DLItem: TN_ULinesItem;
  OutDC, InpDC: TN_DPArray;
  Segms: TSegmInfoArray;
  Ptrs: TN_PArray;
  CurLineIsEmpty: boolean;
  CurLineCodes, PrevLineCodes, NewRegCodes: TN_IArray;
  NumCurLineCodes, NumPrevLineCodes: integer;
  FloatCoords: boolean;
  Timer: TN_CPUTimer1;

  procedure GetCurLineCodes(); //************************************* local
  // collect in CurLineCodes Array ordered CObj Codes (encoded)
  //    from all Lines, in which LSi Segment is part of
  var
    PtrsInd, NumItemCodes, NumSameSegments: integer;
    PCurP1, PCurP2: Pointer;
    PItemCodes: PInteger;
  begin
    PCurP1 := Segms[LSi].PP1;
    PCurP2 := Segms[LSi].PP2;

    PtrsInd := Segms[LSi].SPtrInd;

    while True do // find first segment (in ordered Ptrs array) with same SCenter
    begin
      Dec(PtrsInd);
      if PtrsInd < 0 then Break;

      with TPSegmInfo(Ptrs[PtrsInd])^ do
      begin
        if FloatCoords then
        begin
          if not N_Same( PFPoint(PCurP1)^, PFPoint(PP1)^ ) or
             not N_Same( PFPoint(PCurP2)^, PFPoint(PP2)^ )    then Break;
        end else // double Coords
        begin
          if not N_Same( PDPoint(PCurP1)^, PDPoint(PP1)^ ) or
             not N_Same( PDPoint(PCurP2)^, PDPoint(PP2)^ )    then Break;
        end;
      end; // with TPSegmInfo(Ptrs[PtrsInd])^ do

    end; // while True do // find first segment
    Inc( PtrsInd );

    //***** Here: Ptrs[PtrsInd] points to first segment with same SCenter

    NumCurLineCodes := 0;
    NumSameSegments := 0; // for statistics only

    while True do // along all segments with same coords
    begin         // add CObj Codes to CurLineCodes

      with TPSegmInfo(Ptrs[PtrsInd])^ do
      begin
        InpULines.GetItemAllCodes( SLineInd, PItemCodes, NumItemCodes );
        N_AddOrderedInts( CurLineCodes, NumCurLineCodes,
                                        PItemCodes, NumItemCodes, 0 );
        SPtrInd := -1; // set "segm was already processed" flag
      end;

      Inc( NumSameSegments );
      Inc(PtrsInd); // next segment Index

      if PtrsInd > MaxLSi then Break; // no more segments in Ptrs array

      //***** Check if next segment has same coords, otherwise Break

      with TPSegmInfo(Ptrs[PtrsInd])^ do
      begin
        if FloatCoords then
        begin
          if not N_Same( PFPoint(PCurP1)^, PFPoint(PP1)^ ) or
             not N_Same( PFPoint(PCurP2)^, PFPoint(PP2)^ )    then Break;
        end else // double Coords
        begin
          if not N_Same( PDPoint(PCurP1)^, PDPoint(PP1)^ ) or
             not N_Same( PDPoint(PCurP2)^, PDPoint(PP2)^ )    then Break;
        end;
      end; // with TPSegmInfo(Ptrs[PtrsInd])^ do

    end; // while True do // along all segments with same coords

    Inc( NumRemoved, NumSameSegments-1 ); // number of removed segments
  end; // procedure GetCurLineCodes (local)

  procedure CloseCurLine(); //************************************** local
  // close CurLine and add it to OutLines if CurLine is not a zero line,
  // set collected PrevLineCodes and copy CurLineCodes to PrevLineCodes
  var
    NewItemInd: integer;
    Label PrepForNewLine;
  begin
    if CurLineIsEmpty then Exit; // nothing to do

    // add last point or cur Segment if it is not zero

    if High(OutDC) < OutDCInd then
      SetLength( OutDC, N_NewLength(OutDCInd) );

    OutDC[OutDCInd] := InpDC[Si];

    if not N_Same( OutDC[OutDCInd-1], OutDC[OutDCInd] ) then
      Inc(OutDCInd);

    if OutDCInd = 1 then goto PrepForNewLine; // skip zero line

    DLItem.AddPartCoords( OutDC, 0, OutDCInd );
{
    Assert( False, 'Temporary not implemented!' );
    i, NumCodes: integer;
    PFirstCode: PInteger;

    DLItem.ICode := InpULines.Items[Li].CCode;
    NewItemInd := OutULines.ReplaceItemCoords( DLItem );
    DLItem.Init();

    //*** New Line was added, Set NewRegCodes for it
    NumNewRegCodes := 0;

    for i := 0 to NumPrevLineCodes-1 do
    begin
      InpULines.GetRegCodes( PrevLineCodes[i], PFirstCode, NumCodes );
      N_AddOrderedInts( NewRegCodes, NumNewRegCodes, PFirstCode, NumCodes, 1 );
    end; // for i := 0 to NumPrevLineCodes-1 do

    OutULines.SetRegCodes( NewItemInd, @NewRegCodes[0], NumNewRegCodes );
}

    NewItemInd := OutULines.ReplaceItemCoords( DLItem, -1 );
    if NumPrevLineCodes > 0 then
      OutULines.SetItemAllCodes( NewItemInd, @PrevLineCodes[0], NumPrevLineCodes );
    DLItem.Init();

    PrepForNewLine: //******************* Prepare for New Line
    CurLineIsEmpty := True;
    OutDCInd := 0;
  end; // procedure CloseCurLine(); // local

  procedure CopyCurLineCodesToPrevLineCodes(); //******************** local
  begin
    NumPrevLineCodes := NumCurLineCodes;

    if Length(PrevLineCodes) < NumCurLineCodes then
      SetLength( PrevLineCodes, N_NewLength(NumCurLineCodes) );

    move( CurLineCodes[0], PrevLineCodes[0], NumPrevLineCodes*Sizeof(integer) );
  end; // procedure CopyCurLineCodesToPrevLineCodes(); // local

  function SameLineCodes(): boolean; //***************************** local
  // Return True if CurLinesCodes and PrevLinesCodes are the same
  begin
    Result := False;
    if (NumPrevLineCodes <> NumCurLineCodes) or not CompareMem( @CurLineCodes[0],
                 @PrevLineCodes[0], NumPrevLineCodes*Sizeof(integer) ) then Exit;

    Result := True;
  end; // function SameLineCodes(): boolean; // local

begin //***** body of N_RemoveSameFragments procedure

  Timer := TN_CPUTimer1.Create;
  Timer.Start();

  if InpULines.WLCType = N_FloatCoords then FloatCoords := True
                                       else FloatCoords := False;

  MaxLi := InpULines.WNumItems-1; // Max Line Index
  SetLength( Segms, 1000 ); // initial size
  SetLength( OutDC, 250 );  // initial size

  OutULines.InitItems( 2*InpULines.WNumItems, Length(InpULines.LDCoords) );
  OutULines.WAccuracy := InpULines.WAccuracy;
  OutULines.WFlags    := InpULines.WFlags;
  OutULines.WComment  := 'From ' + InpULines.ObjName;
  DLItem := TN_ULinesItem.Create( N_DoubleCoords );

  //***** fill all Segms[i] fields except SPtrInd
  //      Segms[i].PP1, PP2 are ordered by coords

  LSi := 0; // used as Segms array index

  for Li := 0 to MaxLi do  // along InpLines Items
  begin
    InpULines.GetNumParts( Li, MemPtr, NumParts );

  for Pi := 0 to NumParts-1 do // along Parts of Li-th InpULines Item
  begin
    InpULines.GetPartInds( MemPtr, Pi, FirstInd, NumInds );

    for Si := 0 to NumInds-2 do // along segments of Pi=th Part
    begin
      if LSi > High(Segms) then
        SetLength( Segms, N_NewLength(High(Segms)) );

      with Segms[LSi], InpULines do
      begin

        if FloatCoords then //*************************** Float Coords
        begin
          FTmp1 := LFCoords[FirstInd+Si];
          FTmp2 := LFCoords[FirstInd+Si+1];

          if (FTmp1.X < FTmp2.X) or ((FTmp1.X = FTmp2.X) and
             (FTmp1.Y < FTmp2.Y) ) then
          begin
            PP1 := @LFCoords[FirstInd+Si];
            PP2 := @LFCoords[FirstInd+Si+1];
          end else
          begin
            PP1 := @LFCoords[FirstInd+Si+1];
            PP2 := @LFCoords[FirstInd+Si];
          end;

        end else //************************************** Double Coords
        begin
          DTmp1 := LDCoords[FirstInd+Si];
          DTmp2 := LDCoords[FirstInd+Si+1];

          if (DTmp1.X < DTmp2.X) or ((DTmp1.X = DTmp2.X) and
             (DTmp1.Y < DTmp2.Y) ) then
          begin
            PP1 := @LDCoords[FirstInd+Si];
            PP2 := @LDCoords[FirstInd+Si+1];
          end else
          begin
            PP1 := @LDCoords[FirstInd+Si+1];
            PP2 := @LDCoords[FirstInd+Si];
          end;

        end; // end else - Double Coords

        SLineInd := Li;
        SegmInd  := Si;
      end; // with Segms[LSi], InpULines do
      Inc(LSi);
    end; // for Si := 0 to MaxSi do - along segments of Pi=th Part

  end; // for Pi := 0 to NumParts-1 do  - along Parts of Li-th InpULines Item

  end; // for Li := 0 to MaxLi do - along InpLines Items

  //***** Here: Segms Array is OK.
  //      Create Ptrs - ordered (by PP1, PP2 coords) Pointer to it

  SetLength( Ptrs, LSi );
  MaxLSi := LSi - 1;

  for i := 0 to MaxLSi do // fill Ptrs array
    Ptrs[i] := TN_BytesPtr(@Segms[i]);

  if FloatCoords then //*** Float Coords
    N_SortPointers( Ptrs, 0, N_Compare2PFP1Int ) // sort Ptrs
  else //****************** Double Coords
    N_SortPointers( Ptrs, 0, N_Compare2PDP1Int ); // sort Ptrs

  //***** fill SPtrInd field in Segms Array

  for i := 0 to MaxLSi do // fill Segms[Ind].SPtrInd fields
    TPSegmInfo(Ptrs[i])^.SPtrInd := i;

  //***** add segment coords to statistcs

  if (Amode >= 2) and (SL <> nil) then // collect statistics
  begin
    SL.Add( 'Not ordered segments' );
    SL.Add( ' i    Li  Si Ptri   P1.X    P1.Y      P2.X    P2.Y' );

    for i := 0 to MaxLSi do // debug
    with Segms[i] do
    begin
      if FloatCoords then //**** Float Coords
      begin
        DTmp1 := DPoint( PFPoint(PP1)^ );
        DTmp2 := DPoint( PFPoint(PP2)^ );
      end else //*************** Double Coords
      begin
        DTmp1 := PDPoint(PP1)^;
        DTmp2 := PDPoint(PP2)^;
      end;

      SL.Add( Format( '%.3d  %.3d %.3d %.4d (%7.5g,%7.5g) (%7.5g,%7.5g)',
           [i, SLineInd, SegmInd, SPtrInd, DTmp1.X, DTmp1.Y, DTmp2.X, DTmp2.Y] ));
    end;
    SL.Add( 'End of not ordered segments' );
    SL.Add( '' );

    SL.Add( 'Ordered segments' );
    SL.Add( ' i    Li  Si Ptri   P1.X    P1.Y      P2.X    P2.Y' );

    for i := 0 to MaxLSi do // debug
    with TPSegmInfo(Ptrs[i])^ do
    begin
      if FloatCoords then //**** Float Coords
      begin
        DTmp1 := DPoint( PFPoint(PP1)^ );
        DTmp2 := DPoint( PFPoint(PP2)^ );
      end else //*************** Double Coords
      begin
        DTmp1 := PDPoint(PP1)^;
        DTmp2 := PDPoint(PP2)^;
      end;

      SL.Add( Format( '%.3d  %.3d %.3d %.4d (%7.5g,%7.5g) (%7.5g,%7.5g)',
           [i, SLineInd, SegmInd, SPtrInd, DTmp1.X, DTmp1.Y, DTmp2.X, DTmp2.Y] ));
    end;
    SL.Add( 'End of ordered segments' );
  end; // if (Amode >= 2) and (SL <> nil) then // collect statistics

  //***** all fields of Segms and Ptrs arrays are OK

  CurLineIsEmpty := True;
  LSi := 0;
  OutDCInd := 0;
  NumRemoved := 0;

  //***** Loop along all ULines Segments and create OutULines with all needed Codes

  for Li := 0 to MaxLi do // along InpLines Items
  with InpULines do
  begin
  NumParts := InpULines.GetNumParts( Li );

//  if Li = 5 then // debug
//    N_i := 0;

  for Pi := 0 to NumParts-1 do // along Parts of Li-th InpULines Item
  begin
    InpULines.GetPartDCoords( Li, Pi, InpDC );

    for Si := 0 to High(InpDC)-1 do // along segments of Pi=th Part
    begin
      if (Segms[LSi].SPtrInd = -1) then // segm was already processed,
                                        // close current Line if needed
      begin
        Inc( LSi );
        CloseCurLine(); // close current Line if needed
        Continue;
      end;

      //*** Here: cur segment was not processed yet

      GetCurLineCodes();
      Inc(LSi);

      if (OutDCInd > 0) and // not first segment in current line
         not SameLineCodes() then // close current Line
      begin
        CloseCurLine();
        CopyCurLineCodesToPrevLineCodes();
      end;

      if High(OutDC) < OutDCInd then
        SetLength( OutDC, N_NewLength(OutDCInd+1) );

      //*** Here: add first point of cur Segment to cur Line, skip zero segments

      OutDC[OutDCInd] := InpDC[Si];

      if OutDCInd = 0 then // first point
      begin
        Inc(OutDCInd);
        CurLineIsEmpty := False;
        CopyCurLineCodesToPrevLineCodes();
        Continue;
      end;

      //***** Here: OutDCInd > 0

      if N_Same( OutDC[OutDCInd-1], OutDC[OutDCInd] ) then
        Continue;

      Inc(OutDCInd); // not zero segment
    end; // for Si := 0 to High(InpDC)-1 do - along segments of Pi=th Part

    Si := High(InpDC);
    CloseCurLine(); // Close CurLine after end of each Part

  end; // for Pi := 0 to NumParts-1 do - along Parts of Li-th InpULines Item

  end; // for Li := 0 to MaxLi do - along InpLines Items

  //***** All Items of OutULines are created

  OutULines.CalcEnvRects();
  OutULines.CompactSelf();

  Timer.SS( 'Remove Same Fragments Time', Str );
  Timer.Free;

  if Amode >=1 then // add summary statistics
  begin
    SL.Add( Str );
    Str := Format( '  %d  Segments Removed', [NumRemoved] );
    SL.Add( Str );
  end; // if Amode >=1 then // add summary statistics

  N_Show1Str( Str );
end; // end of procedure N_RemoveSameFragments

//*********************************************** N_RectOverCObj ******
// return True if given ARect is over given Item of ACObj
// (Point is inside ARect, Line crosses ARect, ARect's center is inside Contour)
//
// SearchFlags: bits0-3($0F):
//    if ACObj is TN_UAPoint: =0 check UDDPoint.BP
//                            =1 check UDDPoint.BP
//
//    if ACObj is TN_UALine:
//        bits0-1($003) - checking ACObj as Line:
//                        =0 check Line crossing ARect
//                        =1 check Line Segment crossing ARect
//                        =2 check Line Vertex crossing ARect
//                        =3 check both ( Line Segment and Vertex)
//           bit2($004) - checking ACObj as closed simple Ring:
//                        =1 check if Center of ARect is inside Ring
//
// SegmInd, VertInd are -1 if not needed or not found
//  ( SegmInd and VertInd cannot be botrh >= 0)
//
// if SpecialCObjPtr points to LDCoords[FPInd], return True only if
// found point (VertInd) is first or last point in part (for UALines only)
//
function N_RectOverCObj( const SearchRect: TFRect; SearchFlags: integer;
                         ACLayer: TN_UCObjLayer; ItemInd: integer;
                         SpecialCObjPtr: Pointer; out CurCObjPtr: Pointer;
                         out PartInd, SegmInd, VertInd: integer ): boolean;
var
  i, ClassInd, FPInd, NumInds, NumParts: integer;
  FC: TN_FPArray;
  DC: TN_DPArray;
  Center: TDPoint;
  MemPtr: TN_BytesPtr;
begin
  FC := nil; // to avoid warning
  DC := nil; // to avoid warning
  Result := False;
  PartInd := 0;
  SegmInd := -1;
  VertInd := -1;
  CurCObjPtr := nil;

  if (ACLayer.Items[ItemInd].CFInd and N_EmptyItemBit) <> 0 then Exit;

  with SearchRect do
  begin
    Center.X := 0.5*(Left + Right);
    Center.Y := 0.5*(Top + Bottom);
  end;

  ClassInd := ACLayer.ClassFlags and $FF;

  case ClassInd of

  N_UDPointsCI : //********************* CObj is a UDPoints
  with TN_UDPoints(ACLayer) do
  begin
    Result := (0 = N_PointInRect( CCoords[ItemInd], SearchRect ));
  end; // N_UDPointsCI

  N_ULinesCI : //********************* CObj is a ULines
  with TN_ULines(ACLayer) do
  begin
    if not N_FRectsCross( Items[ItemInd].EnvRect, SearchRect ) then Exit;
    GetNumParts( ItemInd, MemPtr, NumParts );
    if NumParts = 0 then Exit; // empty item

    for i := 0 to NumParts-1 do
    begin
      GetPartInds( MemPtr, i, FPInd, NumInds );

      if WLCType = N_FloatCoords then
      begin
        CurCObjPtr := @LFCoords[FPInd];
        Result := N_RectOverLine( LFCoords, FPInd, NumInds, SearchRect,
                                        SearchFlags and $3, SegmInd, VertInd );

        if (not Result) and ((SearchFlags and $04) <> 0) and
                        N_Same( LFCoords[FPInd], LFCoords[FPInd+NumInds-1] ) then
          Result := (0 = N_DPointInsideFRing( @LFCoords[FPInd], NumInds,
                                             Items[ItemInd].EnvRect, Center ));
      end else
      begin
        CurCObjPtr := @LDCoords[FPInd];
        Result := N_RectOverLine( LDCoords, FPInd, NumInds, SearchRect,
                                        SearchFlags and $3, SegmInd, VertInd );

        if (not Result) and ((SearchFlags and $04) <> 0) and
                        N_Same( LDCoords[FPInd], LDCoords[FPInd+NumInds-1] ) then
          Result := (0 = N_DPointInsideDRing( @LDCoords[FPInd], NumInds,
                                             Items[ItemInd].EnvRect, Center ));
      end;

      if Result then
      begin
        PartInd := i;
        if (SpecialCObjPtr = CurCObjPtr) and
            (VertInd <> FPInd) and (VertInd <> (FPInd+NumInds-1)) then
          Result := False;
        Exit;
      end;
    end;
  end; // N_ULinesCI
{
  N_UDLinesCI : //********************* CObj is a UDLines
  with TN_UDLines(ACLayer) do
  begin
    if not N_FRectsCross( Items[ItemInd].EnvRect, SearchRect ) then Exit;
    GetNumParts( ItemInd, MemPtr, NumParts );
    if NumParts = 0 then Exit; // empty item

    for i := 0 to NumParts-1 do
    begin
      GetPartInds( MemPtr, i, FPInd, NumInds );
      DC := Copy( CCoords, FPInd, NumInds );
      Result := N_RectOverLine( DC, SearchRect,
                                       SearchFlags and $3, SegmInd, VertInd );

      if (not Result) and ((SearchFlags and $04) <> 0) and
                          N_Same( DC[0], DC[High(DC)] )  then
        Result := (0 = N_DPointInsideRing( DC, Items[ItemInd].EnvRect, Center ));

      if Result then
      begin
        PartInd := i;
        CurCObjPtr := @CCoords[FPInd];
        if (SpecialCObjPtr = CurCObjPtr) and
            (VertInd <> FPInd) and (VertInd <> (FPInd+NumInds-1)) then
          Result := False;
        Exit;
      end;
    end;
  end; // N_UDLinesCI
}
  N_UContoursCI : //********************* CObj is a UFLines
  with TN_UContours(ACLayer) do
  begin
    Result := (pptInside = DPointInsideItem( ItemInd, Center ));
  end; // N_UContoursCI

  end; // case ClassInd of
end; // end of function N_RectOverCObj

//*********************************************************** N_HistFindSum ***
// Find a Resulting index, that AHistValues sum from AStartInd to Result >= ASum
//
//     Parameters
// AHistValues - given Histogramm Values
// AStartInd   - Brightness Start Index
// ADeltaInd   - Index changing direction (+1 or -1)
// ASum        - given number of pixels
// Result      - Returns calculated index that AHistValues sum from AStartInd to Result is >= ASum
//
function N_HistFindSum( AHistValues: TN_IArray; AStartInd, ADeltaInd, ASum: integer ): integer;
var
  CurInd, CurSum: integer;
begin
  CurSum := 0;
  CurInd := AStartInd;

  while CurSum < ASum do
  begin
    CurSum := CurSum + AHistValues[CurInd];
    CurInd := CurInd + ADeltaInd;

    if CurInd > High(AHistValues) then
    begin
      CurInd := High(AHistValues);
//      Break;
    end; // if CurInd > High(AHistValues) then

    if CurInd < 0 then
    begin
      CurInd := 0;
      Break;
    end; // if CurInd < 0 then

  end; // while CurSum < ASum do

  if ADeltaInd > 0 then
    Result := Max( AStartInd, CurInd - ADeltaInd )
  else
    Result := Min( AStartInd, CurInd - ADeltaInd );
end; // end of function N_HistFindSum

//***************************************************** N_HistFindThreshold ***
// Find first index from(before) AStartInd so, that AHistValues[Result] >= AMaxThreshold
//
//     Parameters
// AHistValues - given Histogramm Values
// AStartInd   - Brightness Start Index
// ADeltaInd   - Index changing direction (+1 or -1)
// AMaxThreshold - Maximal Threshold Value
// Result      - Returns calculated index that AHistValues sum from AStartInd to Result is >= ASum
//
function N_HistFindThreshold( AHistValues: TN_IArray; AStartInd, ADeltaInd, AMaxThreshold: integer ): integer;
var
  LastInd : integer;
begin
  Result := AStartInd - ADeltaInd;

  LastInd := High(AHistValues);
  if ADeltaInd < 0 then
    LastInd := 0;

  repeat
    Result := Result + ADeltaInd;
  until (AHistValues[Result] >= AMaxThreshold) or (Result = LastInd);
end; // end of function N_HistFindThreshold

//*********************************************************** N_HistFindMax ***
// Find a Result index with local Maximum from given AStartInd in given
// direction (ADeltaInd)
//
//     Parameters
// AHistValues - given Histogramm Values
// AStartInd   - Brightness Start Index
// ADeltaInd   - Index changing direction (+1 or -1)
// ACoef       - search delta (from 0.0 to 1.0)
// Result      - Returns calculated index with local Maximum
//               ( if ADeltaInd=+1 then Result is smallest index (>AStartInd)
//                 so that AHistValues[Result+1] < Max*ACoef )
//
function N_HistFindMax( AHistValues: TN_IArray; AStartInd, ADeltaInd: integer; ACoef: Double  ): integer;
var
  i: integer;
  CurVal, PrevVal: double;
begin

  PrevVal := AHistValues[AStartInd];

  if ADeltaInd > 0 then // search in forward direction
  begin
    for i := AStartInd+1 to High(AHistValues) do
    begin
      CurVal := AHistValues[i];

      // PrevVal is Max of AHistValues[j], AStartInd <= j <= i
      if CurVal < PrevVal*ACoef then // found small enough value
      begin
        Result := i - 1;
        Exit;
      end;

      if CurVal > PrevVal then // Update PrevVal
        PrevVal := CurVal;
    end; // for i := AStartInd+1 to 255 do

    Result := High(AHistValues); // all values are increasing, Result is max index
  end else // ADeltaInd < 0,  search in backrward direction
  begin
    for i := AStartInd-1 downto 0 do
    begin
      CurVal := AHistValues[i];

      if CurVal < PrevVal*ACoef then
      begin
        Result := i + 1;
        Exit;
      end;

      if CurVal > PrevVal then // Update PrevVal
        PrevVal := CurVal;
    end; // for i := AStartInd-1 downto 0 do

    Result := 0; // all values are decreasing, Result is min index (=0)
  end;
end; // end of function N_HistFindMax

//*********************************************************** N_HistFindMin ***
// Find a Result index with local Minimum
// (See comments in N_HistFindMax function)
//
//     Parameters
// AHistValues - given Histogramm Values
// AStartInd   - Brightness Start Index
// ADeltaInd   - Index changing direction (+1 or -1)
// ACoef       - search delta (from 0 to 1)
// Result      - Returns calculated index with local Minimum
//
function N_HistFindMin( AHistValues: TN_IArray; AStartInd, ADeltaInd: integer; ACoef : Double ): integer;
var
  i: integer;
  CurVal, PrevVal: double;
begin

  PrevVal := AHistValues[AStartInd];
  if ADeltaInd > 0 then
  begin
    for i := AStartInd+1 to High(AHistValues) do
    begin
//      PrevVal := AHistValues[i-1];
      CurVal := AHistValues[i];
      if CurVal*ACoef > PrevVal then
      begin
        Result := i - 1;
        Exit;
      end;
      if CurVal < PrevVal then
        PrevVal := CurVal;
    end; // for i := AStartInd+1 to High(AHistValues) do

    Result := High(AHistValues);
  end else // ADeltaInd < 0
  begin
    for i := AStartInd-1 downto 0 do
    begin
//      PrevVal := AHistValues[i+1];
      CurVal := AHistValues[i];
      if CurVal*ACoef > PrevVal then
      begin
        Result := i + 1;
        Exit;
      end;
      if CurVal < PrevVal then
        PrevVal := CurVal;
    end; // for i := AStartInd-1 downto 0 do

    Result := 0;
  end;
end; // end of function N_HistFindMin

{
//********************************************************** N_HistFindLLUL ***
// Find ALL (Lower Limit) and AUL (Upper Limit)
//
//     Parameters
// AHistValues - given Histogramm Values
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
function N_HistFindLLUL( AHistValues: TN_IArray; ACoef, ACoefSum, ACoefNum : Double;  out ALL, AUL: integer ): integer;
var
//  i : Integer;
  NonZeroIndLL, NonZeroIndUL, SumInd, MinMaxInd, MaxInd, SumAll: integer;
  MinInd, MaxNum, MinVal : Integer;
begin
  Result := 0; // now not used


  SumAll := SumInt( AHistValues );

  MinVal := AMinValCoef * SumAll;
  //***** Find ALL
  MaxNum := Round( High(AHistValues) * ACoefNum );

  // At first find first index witn non zero Hist Value
  NonZeroIndLL := N_HistFindSum( AHistValues, 0, 1, 1 );
  MaxInd    := NonZeroIndLL + MaxNum;

  // find MinMaxInd (first Min after first Max)
  MinMaxInd := N_HistFindMax( AHistValues, NonZeroIndLL, 1, ACoef );
  MinMaxInd := N_HistFindMin( AHistValues, MinMaxInd, 1, ACoef );

  // find SumInd (ignore CoefSum*SumAll pixels)
  if MinMaxInd < MaxInd then
    NonZeroIndLL := MinMaxInd;
  SumInd := N_HistFindSum( AHistValues, NonZeroIndLL, 1, Round(ACoefSum*SumAll) );

  ALL := max( SumInd, MinMaxInd );
  ALL := min( ALL, MaxInd );
  ALL := min( ALL, High(AHistValues) );


  //***** Find AUL

  // At first find first index witn non zero Hist Value
  NonZeroIndUL := N_HistFindSum( AHistValues, High(AHistValues), -1, 1 );
  MinInd := NonZeroIndUL - MaxNum;

  // find MinMaxInd (first Min after first Max)
  MinMaxInd := N_HistFindMax( AHistValues, NonZeroIndUL, -1, ACoef );
  MinMaxInd := N_HistFindMin( AHistValues, MinMaxInd, -1, ACoef );

  // find SumInd (ignore CoefSum*SumAll pixels)
  if MinMaxInd > MinInd then
    NonZeroIndUL := MinMaxInd;
  SumInd := N_HistFindSum( AHistValues, NonZeroIndUL, -1, Round(ACoefSum*SumAll) );

  AUL := min( SumInd, MinMaxInd );
  AUL := max( AUL, MinInd );
  AUL := max( AUL, 0 );

  if AUL < ALL then
  begin
    ALL := NonZeroIndLL;
    AUL := NonZeroIndUL;
  end; // if AUL < ALL then

end; // function N_HistFindLLUL`
}

//********************************************************** N_HistFindLLUL ***
// Find ALL (Lower Limit) and AUL (Upper Limit)
//
//     Parameters
// AHistValues   - given Histogramm Values
// ACoef         - used in N_HistFindMax(Min) for eliminating local extremums (in (0,1) range)
// AThresholdSum -
// AMaxNum       -
// AMinVal       - AMinVal=0 means not exclude valleys
// ALL           - calculated Lower Limit (on output)
// AUL           - calculated Upper Limit (on output)
//
function N_HistFindLLUL( AHistValues: TN_IArray; ACoef: Double; AThresholdSum, AMaxNum, AMinVal: Integer;
                                     out ALL, AUL: integer ): integer; overload;
var
  NonZeroIndLL, NonZeroIndUL, SumInd, MinMaxInd, MaxInd: integer;
  MinInd, CurInd, MaxSumStep : Integer;
begin
  Result := 0; // now not used

  //***** Find ALL

  // At first find first index with non zero Hist Value
  CurInd := N_HistFindSum( AHistValues, 0, 1, 1 );
  NonZeroIndLL := CurInd;
  MaxInd    := CurInd + AMaxNum;

  // find MinMaxInd (first Min after first Max)
  MinMaxInd := N_HistFindMax( AHistValues, CurInd, 1, ACoef );
  MinMaxInd := N_HistFindMin( AHistValues, MinMaxInd, 1, ACoef );

  // if MinMaxInd < MaxInd then ignore left peak (continue from MinMaxInd)
  // Otherwise do not ignore anything (continue from CurInd)

  if MinMaxInd < MaxInd then
    CurInd := MinMaxInd;

  if AMinVal > 0 then // exclude valley
  begin
    MaxSumStep := Max( 1, Round( 2 * AThresholdSum / AMinVal ) );

    CurInd := CurInd - 1;
    repeat
      CurInd := CurInd + 1;
      CurInd := N_HistFindThreshold( AHistValues, CurInd, 1, AMinVal );
      SumInd := N_HistFindSum( AHistValues, CurInd, 1, AThresholdSum );
    until SumInd - CurInd < MaxSumStep;

    ALL := CurInd;

    if MinMaxInd < MaxInd then
      ALL := max( CurInd, MinMaxInd );

    ALL := min( ALL, High(AHistValues) );
  end else // AMinVal = 0  - skip excluding valley
    ALL := CurInd;


  //***** ALL is OK, Find AUL

  // At first find first index witn non zero Hist Value
  CurInd := N_HistFindSum( AHistValues, High(AHistValues), -1, 1 );
  NonZeroIndUL := CurInd;
  MinInd := CurInd - AMaxNum;

  // find MinMaxInd (first Min after first Max)
  MinMaxInd := N_HistFindMax( AHistValues, CurInd, -1, ACoef );
  MinMaxInd := N_HistFindMin( AHistValues, MinMaxInd, -1, ACoef );

  // find SumInd (ignore CoefSum*SumAll pixels)
  if MinMaxInd > MinInd then
    CurInd := MinMaxInd;

  if AMinVal > 0 then // exclude valley
  begin
    MaxSumStep := Max( 1, Round( 2 * AThresholdSum / AMinVal ) );

    CurInd := CurInd + 1;

    repeat
      CurInd := CurInd - 1;
      CurInd := N_HistFindThreshold( AHistValues, CurInd, -1, AMinVal );
      SumInd := N_HistFindSum( AHistValues, CurInd, -1, AThresholdSum );
    until CurInd - SumInd < MaxSumStep;

    AUL := CurInd;

    if MinMaxInd > MinInd then
      AUL := min( CurInd, MinMaxInd );

    AUL := max( AUL, 0 );
  end else // AMinVal = 0  - skip excluding valley
    AUL := CurInd;

  if AUL < ALL then
  begin
    ALL := NonZeroIndLL;
    AUL := NonZeroIndUL;
  end; // if AUL < ALL then

end; // function N_HistFindLLUL

//********************************************************** N_HistFindLLUL ***
// Find ALL (Lower Limit) and AUL (Upper Limit)
//
//     Parameters
// AHistValues - given Histogramm Values
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
function N_HistFindLLUL( AHistValues: TN_IArray; ACoef : Double;
           AThresholdSumLeft, AMaxNumLeft, AMinValLeft : Integer;
           AThresholdSumRight, AMaxNumRight, AMinValRight : Integer;  out ALL, AUL: integer ): integer; overload;
var
  NonZeroIndLL, NonZeroIndUL, SumInd, MinMaxInd, MaxInd: integer;
  MinInd, CurInd, MaxSumStep : Integer;
begin
  Result := 0; // now not used


  MaxSumStep := Max( 1, Round( 2 * AThresholdSumLeft / AMinValLeft ) );

  //***** Find ALL

  // At first find first index witn non zero Hist Value
  CurInd := N_HistFindSum( AHistValues, 0, 1, 1 );
  NonZeroIndLL := CurInd;
  MaxInd    := CurInd + AMaxNumLeft;

  // find MinMaxInd (first Min after first Max)
  MinMaxInd := N_HistFindMax( AHistValues, CurInd, 1, ACoef );
  MinMaxInd := N_HistFindMin( AHistValues, MinMaxInd, 1, ACoef );

  // find SumInd (ignore CoefSum*SumAll pixels)
  if MinMaxInd < MaxInd then
    CurInd := MinMaxInd;

  CurInd := CurInd - 1;
  repeat
    CurInd := CurInd + 1;
    CurInd := N_HistFindThreshold( AHistValues, CurInd, 1, AMinValLeft );
    SumInd := N_HistFindSum( AHistValues, CurInd, 1, AThresholdSumLeft );
  until SumInd - CurInd < MaxSumStep;
  CurInd := CurInd - 1;


  ALL := CurInd;
  if MinMaxInd < MaxInd then
    ALL := max( CurInd, MinMaxInd );
  ALL := min( ALL, High(AHistValues) );


  //***** Find AUL

  MaxSumStep := Max( 1, Round( 2 * AThresholdSumRight / AMinValRight ) );

  // At first find first index witn non zero Hist Value
  CurInd := N_HistFindSum( AHistValues, High(AHistValues), -1, 1 );
  NonZeroIndUL := CurInd;
  MinInd := CurInd - AMaxNumRight;

  // find MinMaxInd (first Min after first Max)
  MinMaxInd := N_HistFindMax( AHistValues, CurInd, -1, ACoef );
  MinMaxInd := N_HistFindMin( AHistValues, MinMaxInd, -1, ACoef );

  // find SumInd (ignore CoefSum*SumAll pixels)
  if MinMaxInd > MinInd then
    CurInd := MinMaxInd;

  CurInd := CurInd + 1;
  repeat
    CurInd := CurInd - 1;
    CurInd := N_HistFindThreshold( AHistValues, CurInd, -1, AMinValRight );
    SumInd := N_HistFindSum( AHistValues, CurInd, -1, AThresholdSumRight );
  until CurInd - SumInd < MaxSumStep;
  CurInd := CurInd + 1;


  AUL := CurInd;
  if MinMaxInd > MinInd then
    AUL := min( CurInd, MinMaxInd );
  AUL := max( AUL, 0 );

  if AUL < ALL then
  begin
    ALL := NonZeroIndLL;
    AUL := NonZeroIndUL;
  end; // if AUL < ALL then

end; // function N_HistFindLLUL

//********************************************************* N_HistFindLLULN ***
// Find ALL (Lower Limit) and AUL (Upper Limit)
//
//     Parameters
// AHistValues - given Histogramm Values
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
function N_HistFindLLULN( AHistValues: TN_IArray; ACoef : Double;
           AThresholdSumLeft, AMaxNumLeft, AMinValLeft : Integer;
           AThresholdSumRight, AMaxNumRight, AMinValRight : Integer;  out ALL, AUL: integer ): integer; // overload;
var
  i : Integer;
  NonZeroIndLL, NonZeroIndUL, SumInd, MinMaxInd, MaxInd: integer;
  MinInd, CurInd, MaxSumStep : Integer;
begin
  Result := 0; // now not used


  MaxSumStep := Max( 1, Round( 2 * AThresholdSumLeft / (1.5*AMinValLeft) ) );
//  MaxSumStep := Max( 1, Round( 2 * AThresholdSumLeft / (1.0*AMinValLeft) ) );

  //***** Find ALL

  // At first find first index witn non zero Hist Value
  CurInd := N_HistFindSum( AHistValues, 0, 1, 1 );
  NonZeroIndLL := CurInd;
  MaxInd    := CurInd + AMaxNumLeft;

  // find MinMaxInd (first Min after first Max)
  MinMaxInd := N_HistFindMax( AHistValues, CurInd, 1, ACoef );
  MinMaxInd := N_HistFindMin( AHistValues, MinMaxInd, 1, ACoef );

  // find SumInd (ignore CoefSum*SumAll pixels)
  if MinMaxInd < MaxInd then
    CurInd := MinMaxInd;

  i := 0;
  CurInd := CurInd - 1;
  repeat
    CurInd := CurInd + 1;
    CurInd := N_HistFindThreshold( AHistValues, CurInd, 1, AMinValLeft );
    SumInd := N_HistFindSum( AHistValues, CurInd, 1, AThresholdSumLeft );
    Inc(i);
  until SumInd - CurInd < MaxSumStep;

  if i = 1 then
//  if FALSE then
  begin
    CurInd := Max( 1, CurInd );
    repeat
      CurInd := CurInd - 1;
      SumInd := N_HistFindSum( AHistValues, CurInd, -1, AThresholdSumLeft );
    until (CurInd - SumInd >= MaxSumStep) or (CurInd = 0);
  end
  else
    CurInd := CurInd - 1;


  ALL := CurInd;
  if MinMaxInd < MaxInd then
    ALL := max( CurInd, MinMaxInd );
  ALL := min( ALL, High(AHistValues) );


  //***** Find AUL

  MaxSumStep := Max( 1, Round( 2 * AThresholdSumRight / (1.5*AMinValRight) ) );
//  MaxSumStep := Max( 1, Round( 2 * AThresholdSumRight / (1.0*AMinValRight) ) );

  // At first find first index witn non zero Hist Value
  CurInd := N_HistFindSum( AHistValues, High(AHistValues), -1, 1 );
  NonZeroIndUL := CurInd;
  MinInd := CurInd - AMaxNumRight;

  // find MinMaxInd (first Min after first Max)
  MinMaxInd := N_HistFindMax( AHistValues, CurInd, -1, ACoef );
  MinMaxInd := N_HistFindMin( AHistValues, MinMaxInd, -1, ACoef );

  // find SumInd (ignore CoefSum*SumAll pixels)
  if MinMaxInd > MinInd then
    CurInd := MinMaxInd;

  i := 0;
  CurInd := CurInd + 1;
  repeat
    CurInd := CurInd - 1;
    CurInd := N_HistFindThreshold( AHistValues, CurInd, -1, AMinValRight );
    SumInd := N_HistFindSum( AHistValues, CurInd, -1, AThresholdSumRight );
    Inc(i);
  until CurInd - SumInd < MaxSumStep;

  if i = 1 then
//  if FALSE then
  begin
    CurInd := Min( High(AHistValues) - 1, CurInd );
    repeat
      CurInd := CurInd + 1;
      SumInd := N_HistFindSum( AHistValues, CurInd, 1, AThresholdSumRight );
    until (SumInd - CurInd >= MaxSumStep) or (CurInd = High(AHistValues));
  end
  else
    CurInd := CurInd + 1;

  AUL := CurInd;
  if MinMaxInd > MinInd then
    AUL := min( CurInd, MinMaxInd );
  AUL := max( AUL, 0 );

  if AUL < ALL then
  begin
    ALL := NonZeroIndLL;
    AUL := NonZeroIndUL;
  end; // if AUL < ALL then

end; // function N_HistFindLLULN

//******************************************************** N_HistFindLLULN1 ***
// Find ALL (Lower Limit) and AUL (Upper Limit)
//
//     Parameters
// AHistValues - given Histogramm Values
// ACoef
// ACoef1
// AMaxInd
// AThresholdSumLeft
// AMaxNumLeft
// AStepLeft
// AThresholdSumRight
// AMaxNumRight
// AStepRight
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
function N_HistFindLLULN1( AHistValues: TN_IArray; ACoef, ACoef1: Double; AMaxInd: Integer;
           AThresholdSumLeft, AMaxNumLeft, AStepLeft: Integer;
           AThresholdSumRight, AMaxNumRight, AStepRight: Integer;  out ALL, AUL: integer ): integer; // overload;
var
  NonZeroIndLL, NonZeroIndUL, MinMaxInd, MaxInd: integer;
  MinInd, CurInd, CurTreshold, RealSum : Integer;
begin
  Result := 0; // now not used

  //***** Find ALL

  // At first find first index with non zero Hist Value
  CurInd := N_HistFindSum( AHistValues, 0, 1, 1 );
  NonZeroIndLL := CurInd;
  MaxInd    := CurInd + AMaxNumLeft;

  // find MinMaxInd (first Min after first Max)
  MinMaxInd := N_HistFindMax( AHistValues, CurInd, 1, ACoef );
  MinMaxInd := N_HistFindMin( AHistValues, MinMaxInd, 1, ACoef );

  // if MinMaxInd < MaxInd then ignore left peak (continue from MinMaxInd)
  // Otherwise do not ignore anything (continue from CurInd)

  if MinMaxInd < MaxInd then
    CurInd := MinMaxInd;

  CurInd := CurInd - 1;
  repeat
    CurInd := CurInd + 1;
//    CurTreshold := AHistValues[CurInd] * AStepLeft +  Round(ACoef1 * AStepLeft * AStepLeft / 2);
    CurTreshold := Round( ACoef1 * AHistValues[CurInd] * AStepLeft );
    RealSum := CurTreshold;
    if CurTreshold > AThresholdSumLeft then
      RealSum := K_SumOfRArray( @AHistValues[CurInd], AStepLeft, SizeOf(Integer) );
  until (RealSum > CurTreshold) or (CurInd + AStepLeft < AMaxInd);

  CurInd := CurInd - 1;


  ALL := CurInd;
  if MinMaxInd < MaxInd then
    ALL := max( CurInd, MinMaxInd );
  ALL := min( ALL, High(AHistValues) );


  //***** Find AUL

  // At first find first index witn non zero Hist Value
  CurInd := N_HistFindSum( AHistValues, High(AHistValues), -1, 1 );
  NonZeroIndUL := CurInd;
  MinInd := CurInd - AMaxNumRight;

  // find MinMaxInd (first Min after first Max)
  MinMaxInd := N_HistFindMax( AHistValues, CurInd, -1, ACoef );
  MinMaxInd := N_HistFindMin( AHistValues, MinMaxInd, -1, ACoef );

  // find SumInd (ignore CoefSum*SumAll pixels)
  if MinMaxInd > MinInd then
    CurInd := MinMaxInd;

  CurInd := CurInd + 1;
  repeat
    CurInd := CurInd - 1;
//    CurTreshold := AHistValues[CurInd] * AStepRight + Round( ACoef1 * AStepRight * AStepRight / 2 );
    CurTreshold := Round( ACoef1 * AHistValues[CurInd] * AStepRight );
    RealSum := CurTreshold;
    if CurTreshold > AThresholdSumRight then
      RealSum := K_SumOfRArray( @AHistValues[CurInd - AStepRight + 1], AStepRight, SizeOf(Integer) );
  until (RealSum > CurTreshold) or (CurInd - AStepRight > AMaxInd);


  AUL := CurInd;
  if MinMaxInd > MinInd then
    AUL := min( CurInd, MinMaxInd );
  AUL := max( AUL, 0 );

  if AUL < ALL then
  begin
    ALL := NonZeroIndLL;
    AUL := NonZeroIndUL;
  end; // if AUL < ALL then

end; // function N_HistFindLLULN1

//****************************************************** N_HistRemoveZeros1 ***
// Remove Histogram Zero Values Variant 1
//
//     Parameters
// AHistValues - given Histogramm Values
// AHNZVals    - Histogram Not Zero Values (on output)
// AHNZInds    - Indexes from source Histogram for Not Zero Values  (on output)
//
function N_HistRemoveZeros1( AHistValues: TN_IArray; var AHNZVals, AHNZInds : TN_IArray ) : Integer;
var
  i, j : Integer;
begin
/////////////////////////
// Remove Zero Values
//
  SetLength( AHNZVals, Length(AHistValues) );
  SetLength( AHNZInds, Length(AHistValues) );

  j := 0;
  for i := 0 to High(AHNZVals) do
  begin
    if AHistValues[i] = 0 then Continue;
    AHNZVals[j] := AHistValues[i];
    AHNZInds[j] := i;
    Inc(j);
  end;
  SetLength( AHNZVals, j );
  Result := j;
//
// Remove Zero Values
/////////////////////////

end; // function N_HistRemoveZeros1

//****************************************************** N_HistRemoveZeros2 ***
// Remove Histogram Zero Values Variant 2
//
//     Parameters
// AHistValues - given Histogramm Values
// AHNZVals    - Histogram Not Zero Values (on output)
// AHNZInds    - Indexes from source Histogram for Not Zero Values  (on output)
//
function N_HistRemoveZeros2( AHistValues: TN_IArray; var AHNZVals, AHNZInds : TN_IArray ) : Integer;
var
  i, j, inz1, inz2 : Integer;
begin
/////////////////////////
// Remove Zero Values
//
  // Skip Left Zeros
  inz1 := 0;
  for i := 0 to High(AHistValues) do
  begin
    if AHistValues[i] = 0 then Continue;
    inz1 := i;
    break;
  end;

  // Skip Left Peak
  j := inz1;
  for i := inz1 + 1 to High(AHistValues) do
  begin
    if AHistValues[i] <> 0 then Continue;
    j := i;
    break;
  end;
  if j - 3 <= inz1 then
     inz1 := j;

  // Skip Right Zeros
  inz2 := High(AHistValues);
  for i := High(AHistValues) downto inz1 do
  begin
    if AHistValues[i] = 0 then Continue;
    inz2 := i;
    break;
  end;

  // Skip Right Peak
  j := inz2;
  for i := inz2 - 1 downto inz1 do
  begin
    if AHistValues[i] <> 0 then Continue;
    j := i;
    break;
  end;
  if j + 3 >= inz2 then
     inz2 := j;

  // Remove Central Zeros
  SetLength( AHNZVals, inz2 - inz1 + 1 );
  SetLength( AHNZInds, Length(AHNZVals) );

  j := 0;
  for i := inz1 to inz2 do
  begin
    if (AHistValues[i] = 0) then Continue;
    AHNZVals[j] := AHistValues[i];
    AHNZInds[j] := i;
    Inc(j);
  end;
  SetLength( AHNZVals, j );
  Result := j;
//
// Remove Zero Values
/////////////////////////

end; // function N_HistRemoveZeros2

//****************************************************** N_HistRemoveZeros3 ***
// Remove Histogram Zero Values Variant 3
//
//     Parameters
// AHistValues - given Histogramm Values
// AHNZVals    - Histogram Not Zero Values (on output)
// AHNZInds    - Indexes from source Histogram for Not Zero Values  (on output)
//
function N_HistRemoveZeros3( AHistValues: TN_IArray; var AHNZVals, AHNZInds : TN_IArray ) : Integer;
var
  i, j, inz1, inz2 : Integer;
begin
  // Skip Left Zeros
  inz1 := 0;
  for i := 0 to High(AHistValues) do
  begin
    if AHistValues[i] = 0 then Continue;
    inz1 := i;
    break;
  end;

  // Skip Right Zeros
  inz2 := High(AHistValues);
  for i := High(AHistValues) downto inz1 do
  begin
    if AHistValues[i] = 0 then Continue;
    inz2 := i;
    break;
  end;

  SetLength( AHNZVals, inz2 - inz1 + 1 );
  SetLength( AHNZInds, Length(AHNZVals) );

  j := 0;
  for i := inz1 to inz2 do
  begin
    if (AHistValues[i] = 0) then Continue;
    AHNZVals[j] := AHistValues[i];
    AHNZInds[j] := i;
    Inc(j);
  end;
  SetLength( AHNZVals, j );
  SetLength( AHNZInds, j );
  Result := j;
end; // function N_HistRemoveZeros3

//****************************************************** N_HistRemovePeaks1 ***
// Remove Histogram Peak Values Variant 1
//
//     Parameters
// AHNZVals  - Histogram Not Zero Values
// ACoefPeak - Peaks coefficient
//
procedure N_HistRemovePeaks1( AHNZVals : TN_IArray; ACoefPeak : Double );
var
  i, j : Integer;
begin
  if Length(AHNZVals) = 0 then Exit;

  j := K_IndexOfMinInRArray( PInteger(@AHNZVals[0]), Length(AHNZVals) );

  for i := j + 1 to High(AHNZVals) do
  begin
    if AHNZVals[i] >= AHNZVals[i-1] * ACoefPeak then
      AHNZVals[i] := Round(AHNZVals[i-1] * ACoefPeak)
{
    if AHNZVals[i] >= AHNZVals[i-1] * ACoefPeak then
      AHNZVals[i] := Max( AHNZVals[i], Round(AHNZVals[i-1] * ACoefPeakCut) )
    else
    if AHNZVals[i-1] >= aHNZVals[i] * CoefPeak then
      AHNZVals[i] := Max( AHNZVals[i], Round(AHNZVals[i-1] / ACoefPeakCut) );
}
  end;

  for i := j - 1 downto 0 do
  begin
    if AHNZVals[i] >= AHNZVals[i+1] * ACoefPeak then
      AHNZVals[i] := Round(AHNZVals[i+1] * ACoefPeak)
{
    if AHNZVals[i] >= AHNZVals[i+1] * ACoefPeak then
      AHNZVals[i] := Max( AHNZVals[i], Round(AHNZVals[i+1] * ACoefPeakCut) )
    else
    if AHNZVals[i+1] >= HNZVals[i] * ACoefPeak then
      AHNZVals[i] := Max( AHNZVals[i], Round(AHNZVals[i+1] / ACoefPeakCut) );
}
  end; // for i := j - 1 downto 0 do

end; // procedure N_HistRemovePeaks1

//*********************************************************** N_HistSmooth1 ***
// Smooth Histogram Values Variant 1
//
//     Parameters
// AHNZVals  - Histogram Not Zero Values
// ACoefMean - Mean Value coefficient ( 0<=ACoefMean<=1 )
//
// ACoefMean = 0 - no smoothing
// ACoefMean = 1 - AHNZVals[i] = 1/3 * (HNZVals[i-1] + AHNZVals[i] + AHNZVals[i+1] )
//
procedure N_HistSmooth1( AHNZVals : TN_IArray; ACoefMean : Double );
var
  i : Integer;
  IPrev, ICur : Integer;
begin
  if Length(AHNZVals) < 3 then Exit;

  IPrev := AHNZVals[0];

  for i := 1 to High(AHNZVals) - 1 do
  begin
    ICur := Round( AHNZVals[i] * (1 - ACoefMean) +
                   (IPrev + AHNZVals[i] + AHNZVals[i+1]) / 3 * ACoefMean);
    IPrev := AHNZVals[i];
    AHNZVals[i] := ICur;
  end;
end; // function N_HistSmooth1

//******************************************************** N_HistMiddleMax1 ***
// Find Histogram Middle Maximal Value (w/o "ends") Variant 1
//
//     Parameters
// AHNZVals  - Histogram Not Zero Values
// AEndsShift - Histogram Endû Shift
//
function N_HistMiddleMax1( AHNZVals : TN_IArray ) : Integer;
var
  i, j : Integer;
begin
/////////////////////////
// Calc Max Value w/o end elements
//
  Result := 0;
  if Length(AHNZVals) = 0 then Exit;
  i := Min( 5, Round( Length(AHNZVals) / 5 ) );
  j := K_IndexOfMaxInRArray( @AHNZVals[i], Length(AHNZVals) - i - i );
  Result := AHNZVals[i + j];
//
// Calc Max Value w/o end elements
/////////////////////////
end; // function N_HistMiddleMax1

//******************************************************** N_HistMiddleMax2 ***
// Find Histogram Middle Maximal Value (w/o "ends") Variant 2
//
//     Parameters
// AHNZVals     - Histogram Not Zero Values
// AEndsShift   - Histogram Ends Shift
// AAllEndsCoef - Histogram Ends Sum Part Coefficient
//
function N_HistMiddleMax2( AHNZVals: TN_IArray; AEndsMinShift: Integer; AAllEndsCoef: Double ): Integer;
var
  i: Integer;
begin
  Result := -1;

  if Length(AHNZVals) = 0 then Exit;

  i := Min( AEndsMinShift, Round( Length(AHNZVals) * AAllEndsCoef ) );

  Result := i + K_IndexOfMaxInRArray( @AHNZVals[i], Length(AHNZVals) - i - i );
end; // function N_HistMiddleMax2

//********************************************************* N_HistFindLLUL1 ***
// Find ALL (Lower Limit) and AUL (Upper Limit) Common Variant 1 and 2
//
//     Parameters
// AHistValues - given Histogramm Values
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
procedure N_HistFindLLUL1( AHistValues: TN_IArray; out ALL, AUL: integer );
begin
  if N_KeyIsDown(VK_CONTROL) and N_KeyIsDown(VK_SHIFT) then
    N_HistFindLLUL13( AHistValues, ALL, AUL )
//    N_HistFindLLUL12( AHistValues, ALL, AUL )
//    N_HistFindLLUL22( AHistValues, ALL, AUL )
  else
    N_HistFindLLUL11( AHistValues, ALL, AUL );
end; // procedure N_HistFindLLUL1

//******************************************************** N_HistFindLLUL11 ***
// Find ALL (Lower Limit) and AUL (Upper Limit) Common Variant 1
//
//     Parameters
// AHistValues - given Histogramm Values
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
procedure N_HistFindLLUL11( AHistValues: TN_IArray; out ALL, AUL: integer );
var
  HNZVals, HNZInds : TN_IArray;
  CoefMean, Coef, CoefSum, CoefNum, CoefMinVal, CoefPeak{, CoefPeakCut} : Double;
  SumAll, ThresholdSum, MaxNum, MinVal, MaxVal, MaxInd : Integer;
begin
/////////////////////////
// Remove Zero Values
//
//  N_HistRemoveZeros1( AHistValues, HNZVals, HNZInds );
  N_HistRemoveZeros2( AHistValues, HNZVals, HNZInds );

  if Length(HNZVals) = 0 then
  begin
    ALL := 0;
    AUL := High(AHistValues);
    Exit;
  end;

/////////////////////////
// Set Attributes
//
  CoefMean := 0.6;      // Smoothing LineComb Coef
  Coef     := 0.9;      // MinMax Value Search Coef - Part of previous Histogram Element
  CoefSum  := 0.01;     // Area Treshold Coef - Part of All Histogram
  CoefNum  := 0.1;      // Histogram End Mounts Maximal Width Coef - Part of All Histogram elements number
  CoefMinVal := 0.075;  // Value Treshold Coef - Part of Maximal Histogram Element
//  CoefPeak := 2;
//  CoefPeakCut := 1.5;
//  CoefPeak := 1.5;
//  CoefPeakCut := 1.1;
  CoefPeak    := 1.75;  // Peak Value Detect Coef - Part of previous Histogram Element
//  CoefPeakCut := 1.325; // Peak Value Replace Coef - Part of previous Histogram Element

//////////////////////
// Remove Peak Values
//
  N_HistRemovePeaks1( HNZVals, CoefPeak );

//////////////////////
// Smooth Values
//
  N_HistSmooth1( HNZVals, CoefMean );

/////////////////////////
// Calc Max Value w/o end elements
//
//  MaxVal := N_HistMiddleMax1( HNZVals );
  MaxInd := N_HistMiddleMax2( HNZVals, 5, 0.2 );
  MaxVal := HNZVals[MaxInd];

/////////////////////////
// Calc Find LL/UL Attrs
//
  SumAll := SumInt( HNZVals );
  ThresholdSum := Round(SumAll * CoefSum);
  MaxNum := Max(1, Round(Length(HNZVals) * CoefNum) );
  MinVal := Max(1, Round(CoefMinVal * MaxVal) );
//  MinVal := Min(MinVal, Round(2 * ThresholdSum / MaxNum) );
//
// Calc HistFind Attrs
/////////////////////////

  N_HistFindLLUL( HNZVals, Coef, ThresholdSum, MaxNum, MinVal, ALL, AUL );

/////////////////////////////////
// Restore original LL/UL Values
  ALL := HNZInds[ALL];
  AUL := HNZInds[AUL];

{ is needed to show Histogram values converted for N_HistFindLLUL
  for i := 1 to High(HNZVals) - 1 do
    AHistValues[HNZInds[i]] := HNZVals[i];
{}
end; // function N_HistFindLLUL11

//******************************************************** N_HistFindLLUL12 ***
// Find ALL (Lower Limit) and AUL (Upper Limit) Common Variant 2
//
//     Parameters
// AHistValues - given Histogramm Values
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
procedure N_HistFindLLUL12( AHistValues: TN_IArray; out ALL, AUL: integer );
var
  HNZVals, HNZInds : TN_IArray;
  CoefMean, Coef, CoefSum, CoefNum, CoefMinVal, CoefPeak{, CoefPeakCut} : Double;
  ThresholdSumLeft, MaxNumLeft, MinValLeft : Integer;
  ThresholdSumRight, MaxNumRight, MinValRight : Integer;
  SumAll, MaxVal, MaxInd : Integer;
  WrkLength : Integer;
  MeanVal, FormFactor : Double;
begin
/////////////////////////
// Remove Zero Values
//
//  N_HistRemoveZeros1( AHistValues, HNZVals, HNZInds );
  N_HistRemoveZeros2( AHistValues, HNZVals, HNZInds );
  N_Dump2Str( 'LLUL12 after Zeros2' );

  if Length(HNZVals) = 0 then
  begin
    ALL := 0;
    AUL := High(AHistValues);
    Exit;
  end;

/////////////////////////
// Set Attributes
//
  CoefMean := 0.6;      // Smoothing LineComb Coef
  Coef     := 0.9;      // MinMax Value Search Coef - Part of previous Histogram Element
  CoefSum  := 0.01;     // Area Treshold Coef - Part of All Histogram
  CoefNum  := 0.1;      // Histogram End Mounts Maximal Width Coef - Part of All Histogram elements number
//  CoefMinVal := 0.075;  // Value Treshold Coef - Part of Maximal Histogram Element
  CoefMinVal := 0.01;  // Value Treshold Coef - Part of Maximal Histogram Element

//  CoefPeak := 2;
//  CoefPeakCut := 1.5;
//  CoefPeak := 1.5;
//  CoefPeakCut := 1.1;

//1  CoefPeak    := 1.75;  // Peak Value Detect Coef - Part of previous Histogram Element
//2  CoefPeak    := 3.75;  // Peak Value Detect Coef - Part of previous Histogram Element
//3  CoefPeak    := 3.0;  // Peak Value Detect Coef - Part of previous Histogram Element
  CoefPeak    := 1.75;  // Peak Value Detect Coef - Part of previous Histogram Element
//  CoefPeakCut := 1.325; // Peak Value Replace Coef - Part of previous Histogram Element

//////////////////////
// Remove Peak Values
//
  N_HistRemovePeaks1( HNZVals, CoefPeak );
  N_Dump2Str( 'LLUL12 after Peaks1' );

//////////////////////
// Smooth Values
//
  N_HistSmooth1( HNZVals, CoefMean );
  N_Dump2Str( 'LLUL12 after Smooth1' );

/////////////////////////
// Calc Max Value w/o end elements
//
//  MaxVal := N_HistMiddleMax1( HNZVals );
  MaxInd := N_HistMiddleMax2( HNZVals, 5, 0.2 );
  MaxVal := HNZVals[MaxInd];
  N_Dump2Str( 'LLUL12 after MiddleMax2' );

/////////////////////////
// Calc Find LL/UL Attrs
//
  WrkLength := MaxInd + 1;
  SumAll := K_SumOfRArray( PInteger(@HNZVals[0]), WrkLength, SizeOf(Integer) );
  MeanVal := SumAll / WrkLength;
  FormFactor := 2 * MeanVal / MaxVal;
//  ThresholdSumLeft := Round(SumAll * CoefSum);

  ThresholdSumLeft := Round( CoefSum  * SumAll * FormFactor );
  MaxNumLeft := Max(1, Round( WrkLength * CoefNum) );
//  MinValLeft := Max(1, Round(CoefMinVal * MaxVal) );
  MinValLeft := Max(1, Round(CoefMinVal * MaxVal / (8 * FormFactor * FormFactor * FormFactor) ) );
//  MinValLeft := Min(MinValLeft, Round(2 * ThresholdSumLeft / MaxNumLeft) );

  WrkLength := Length(HNZVals) - MaxInd;
  SumAll := K_SumOfRArray( @HNZVals[MaxInd], WrkLength, SizeOf(Integer) );
  MeanVal := SumAll / WrkLength;
  FormFactor := 2 * MeanVal / MaxVal;
//  ThresholdSumRight := Round( SumAll * CoefSum );
  ThresholdSumRight := Round( CoefSum  * SumAll * FormFactor );
  MaxNumRight := Max(1, Round( WrkLength * CoefNum ) );
//  MinValRight := Max( 1, Round( CoefMinVal * MaxVal ) );
  MinValRight := Max( 1, Round( CoefMinVal * MaxVal / (8 * FormFactor * FormFactor * FormFactor) ) );
//  MinValRight := Min( MinValRight, Round( 2 * ThresholdSumRight / MaxNumRight ) );
//
// Calc HistFind Attrs
/////////////////////////

  N_HistFindLLULN( HNZVals, Coef,
           ThresholdSumLeft, MaxNumLeft, MinValLeft,
           ThresholdSumRight, MaxNumRight, MinValRight,
           ALL, AUL );
  N_Dump2Str( 'LLUL12 after N_HistFindLLULN' );

/////////////////////////////////
// Restore original LL/UL Values
  ALL := HNZInds[ALL];
  AUL := HNZInds[AUL];

{ is needed to show Histogram values converted for N_HistFindLLUL
  for WrkLength := 1 to High(HNZVals) - 1 do
    AHistValues[HNZInds[WrkLength]] := HNZVals[WrkLength];
{}
end; // function N_HistFindLLUL12

//******************************************************** N_HistFindLLUL13 ***
// Find ALL (Lower Limit) and AUL (Upper Limit) Common Variant 2
//
//     Parameters
// AHistValues - given Histogramm Values
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
procedure N_HistFindLLUL13( AHistValues: TN_IArray; out ALL, AUL: integer );
var
  HNZVals, HNZInds : TN_IArray;
//  CoefSum, CoefMinVal : Double;
  CoefMean, Coef, CoefNum, CoefPeak, CoefAng : Double;
  ThresholdSumLeft, MaxNumLeft : Integer;
  ThresholdSumRight, MaxNumRight : Integer;
//  MinValLeft, MinValRight : Integer;
  SumAll, MaxInd : Integer;
  WrkLength : Integer;
  StepLeft, StepRight : Integer;
//  MeanVal, FormFactor : Double;
//  MaxVal : Integer;
begin
/////////////////////////
// Remove Zero Values
//
//  N_HistRemoveZeros1( AHistValues, HNZVals, HNZInds );
  N_HistRemoveZeros2( AHistValues, HNZVals, HNZInds );
  N_Dump2Str( 'LLUL12 after Zeros2' );

  if Length(HNZVals) = 0 then
  begin
    ALL := 0;
    AUL := High(AHistValues);
    Exit;
  end;

/////////////////////////
// Set Attributes
//
  CoefMean := 0.6;      // Smoothing LineComb Coef
  Coef     := 0.9;      // MinMax Value Search Coef - Part of previous Histogram Element
//  CoefSum  := 0.01;     // Area Treshold Coef - Part of All Histogram
  CoefNum  := 0.1;      // Histogram End Mounts Maximal Width Coef - Part of All Histogram elements number
//  CoefMinVal := 0.075;  // Value Treshold Coef - Part of Maximal Histogram Element
//  CoefMinVal := 0.01;  // Value Treshold Coef - Part of Maximal Histogram Element

  CoefAng := 1.50;      // Coef proportinal to Hist Gradient Angle

//  CoefPeak := 2;
//  CoefPeakCut := 1.5;
//  CoefPeak := 1.5;
//  CoefPeakCut := 1.1;

//1  CoefPeak    := 1.75;  // Peak Value Detect Coef - Part of previous Histogram Element
//2  CoefPeak    := 3.75;  // Peak Value Detect Coef - Part of previous Histogram Element
//3  CoefPeak    := 3.0;  // Peak Value Detect Coef - Part of previous Histogram Element
  CoefPeak    := 1.50;  // Peak Value Detect Coef - Part of previous Histogram Element
//  CoefPeakCut := 1.325; // Peak Value Replace Coef - Part of previous Histogram Element

//////////////////////
// Remove Peak Values
//
  N_HistRemovePeaks1( HNZVals, CoefPeak );
  N_Dump2Str( 'LLUL13 after Peaks1' );

//////////////////////
// Smooth Values
//
  N_HistSmooth1( HNZVals, CoefMean );
  N_Dump2Str( 'LLUL13 after Smooth1' );

/////////////////////////
// Calc Max Value w/o end elements
//
//  MaxVal := N_HistMiddleMax1( HNZVals );
  MaxInd := N_HistMiddleMax2( HNZVals, 5, 0.2 );
//  MaxVal := HNZVals[MaxInd];
  N_Dump2Str( 'LLUL13 after MiddleMax2' );

/////////////////////////
// Calc Find LL/UL Attrs
//
  WrkLength := MaxInd + 1;
  SumAll := K_SumOfRArray( PInteger(@HNZVals[0]), WrkLength, SizeOf(Integer) );
//  MeanVal := SumAll / WrkLength;
//  FormFactor := 2 * MeanVal / MaxVal;
//  ThresholdSumLeft := Round(SumAll * CoefSum);
  ThresholdSumLeft := 50;

  StepLeft := Max( 5, Round( N_HistFindSum( HNZVals, 0, 1, SumAll shr 2 ) / 10 ) );

ALL := N_HistFindSum( HNZVals, 0, 1, Round(SumAll / 16) );

  MaxNumLeft := Max(1, Round( WrkLength * CoefNum) );
//  MinValLeft := Max(1, Round(CoefMinVal * MaxVal) );
//  MinValLeft := Max(1, Round(CoefMinVal * MaxVal / (8 * FormFactor * FormFactor * FormFactor) ) );
//  MinValLeft := Min(MinValLeft, Round(2 * ThresholdSumLeft / MaxNumLeft) );

  WrkLength := Length(HNZVals) - MaxInd;
  SumAll := K_SumOfRArray( @HNZVals[MaxInd], WrkLength, SizeOf(Integer) );
//  MeanVal := SumAll / WrkLength;
//  FormFactor := 2 * MeanVal / MaxVal;

  StepRight := Max( 5, Round( (Length(HNZVals) - N_HistFindSum( HNZVals, High(HNZVals), -1, SumAll shr 2 )) / 10 ) );

AUL := N_HistFindSum( HNZVals, High(HNZVals), -1, Round(SumAll / 16) );

//  ThresholdSumRight := Round( SumAll * CoefSum );
  ThresholdSumRight := 50;
  MaxNumRight := Max(1, Round( WrkLength * CoefNum ) );
//  MinValRight := Max( 1, Round( CoefMinVal * MaxVal ) );
//  MinValRight := Max( 1, Round( CoefMinVal * MaxVal / (8 * FormFactor * FormFactor * FormFactor) ) );
//  MinValRight := Min( MinValRight, Round( 2 * ThresholdSumRight / MaxNumRight ) );
//
// Calc HistFind Attrs
/////////////////////////
{}
  N_HistFindLLULN1( HNZVals, Coef, CoefAng, MaxInd,
           ThresholdSumLeft, MaxNumLeft, StepLeft,
           ThresholdSumRight, MaxNumRight, StepRight,
           ALL, AUL );
  N_Dump2Str( 'LLUL13 after N_HistFindLLULN' );
{}
/////////////////////////////////
// Restore original LL/UL Values
  ALL := HNZInds[ALL];
  AUL := HNZInds[AUL];

{ is needed to show Histogram values converted for N_HistFindLLUL
  for WrkLength := 1 to High(HNZVals) - 1 do
    AHistValues[HNZInds[WrkLength]] := HNZVals[WrkLength];
{}
end; // function N_HistFindLLUL13

//********************************************************* N_HistFindLLUL2 ***
// Find ALL (Lower Limit) and AUL (Upper Limit) Common Variant 1 and 2
//
//     Parameters
// AHistValues - given Histogramm Values
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
procedure N_HistFindLLUL2( AHistValues: TN_IArray; out ALL, AUL: integer );
begin
  if N_KeyIsDown(VK_CONTROL) and N_KeyIsDown(VK_SHIFT) then
    N_HistFindLLUL21( AHistValues, ALL, AUL )
  else
    N_HistFindLLUL22( AHistValues, ALL, AUL );
end; // procedure N_HistFindLLUL2

//******************************************************** N_HistFindLLUL21 ***
// Find ALL (Lower Limit) and AUL (Upper Limit) Special E2V Variant 1
//
//     Parameters
// AHistValues - given Histogramm Values
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
procedure N_HistFindLLUL21( AHistValues: TN_IArray; out ALL, AUL: integer );
var
  HNZVals, HNZInds : TN_IArray;
  CoefMean, Coef, CoefNum, CoefPeak{, CoefPeakCut} : Double;
//  CoefSum, CoefMinVal : Double;
  ThresholdSum, MaxNum, MinVal : Integer;
//  SumAll, MaxVal : Integer;
begin
/////////////////////////
// Remove Zero Values
//
  N_HistRemoveZeros1( AHistValues, HNZVals, HNZInds );
  N_Dump2Str( 'LLUL21 after Zeros1' );

  if Length(HNZVals) = 0 then
  begin
    ALL := 0;
    AUL := High(AHistValues);
    Exit;
  end;

/////////////////////////
// Set Attributes
//
  CoefMean := 0.6;      // Smoothing LineComb Coef
  Coef     := 0.9;      // MinMax Value Search Coef - Part of previous Histogram Element
//  CoefSum  := 0.01;     // Area Treshold Coef - Part of All Histogram
  CoefNum  := 0.1;      // Histogram End Mounts Maximal Width Coef - Part of All Histogram elements number
//  CoefMinVal := 0.0075;  // Value Treshold Coef - Part of Maximal Histogram Element
  CoefPeak    := 1.75;  // Peak Value Detect Coef - Part of previous Histogram Element

//////////////////////
// Remove Peak Values
//
  N_HistRemovePeaks1( HNZVals, CoefPeak );
  N_Dump2Str( 'LLUL21 after Peaks1' );

//////////////////////
// Smooth Values
//
  N_HistSmooth1( HNZVals, CoefMean );
  N_Dump2Str( 'LLUL21 after Smooth1' );

/////////////////////////
// Calc Max Value w/o end elements
//
  //MaxVal := N_HistMiddleMax( HNZVals );

/////////////////////////
// Calc Find LL/UL Attrs
//
//  SumAll := SumInt( HNZVals );
//  ThresholdSum := Round(SumAll * CoefSum);
  ThresholdSum := 0;
  MaxNum := Round(Length(HNZVals) * CoefNum);
//  MinVal := Max(1, Round(CoefMinVal * MaxVal) );
  MinVal := 5;
//
// Calc HistFind Attrs
/////////////////////////

  N_HistFindLLUL( HNZVals, Coef, ThresholdSum, MaxNum, MinVal, ALL, AUL );

  N_Dump2Str( 'LLUL21 after N_HistFindLLUL' );
/////////////////////////////////
// Restore original LL/UL Values
  ALL := HNZInds[ALL];
  AUL := HNZInds[AUL];

end; // function N_HistFindLLUL21

//******************************************************** N_HistFindLLUL22 ***
// Find ALL (Lower Limit) and AUL (Upper Limit) Special E2V Variant 2
//
//     Parameters
// AHistValues - given Histogramm Values
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
procedure N_HistFindLLUL22( AHistValues: TN_IArray; out ALL, AUL: integer );
var
  HNZVals, HNZInds : TN_IArray;
  CoefMean, Coef, CoefNum, CoefPeak{, CoefPeakCut} : Double;
//  CoefSum, CoefMinVal : Double;
  ThresholdSum, MaxNum, MinVal : Integer;
//  SumAll, MaxVal : Integer;
begin
  N_Dump2Str( 'LLUL22 start' );
/////////////////////////
// Remove Zero Values
//
  N_HistRemoveZeros2( AHistValues, HNZVals, HNZInds );

  N_Dump2Str( 'LLUL22 after RemoveZeros2' );

  if Length(HNZVals) = 0 then
  begin
    ALL := 0;
    AUL := High(AHistValues);
    Exit;
  end;

/////////////////////////
// Set Attributes
//
  CoefMean := 0.6;      // Smoothing LineComb Coef
  Coef     := 0.9;      // MinMax Value Search Coef - Part of previous Histogram Element
//  CoefSum  := 0.01;     // Area Treshold Coef - Part of All Histogram
  CoefNum  := 0.1;      // Histogram End Mounts Maximal Width Coef - Part of All Histogram elements number
//  CoefMinVal := 0.0075;  // Value Treshold Coef - Part of Maximal Histogram Element
  CoefPeak    := 1.75;  // Peak Value Detect Coef - Part of previous Histogram Element

  N_HistRemovePeaks1( HNZVals, CoefPeak ); // Remove Peak Values

  N_HistSmooth1( HNZVals, CoefMean ); // Smooth Values

//  SumAll := SumInt( HNZVals );
//  ThresholdSum := Round(SumAll * CoefSum);
  ThresholdSum := 0;
  MaxNum := Round(Length(HNZVals) * CoefNum);
//  MinVal := Max(1, Round(CoefMinVal * MaxVal) );
  MinVal := 5;

  N_HistFindLLUL( HNZVals, Coef, ThresholdSum, MaxNum, MinVal, ALL, AUL );

  ALL := HNZInds[ALL];
  AUL := HNZInds[AUL];

end; // function N_HistFindLLUL22

//****************************************************** N_HistFindLLULPar1 ***
// Find ALL (Lower Limit) and AUL (Upper Limit) Variant #1 with integer parametr
//
//     Parameters
// AHistValues - given Histogramm Values
// AIntPar     - given integer parametr
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
procedure N_HistFindLLULPar1( AHistValues: TN_IArray; AIntPar: Integer; out ALL, AUL: integer );
var
  HNZVals, HNZInds : TN_IArray;
//  CoefSum, CoefMinVal : Double;
  CoefMean, Coef, CoefNum, CoefPeak, CoefAng : Double;
  ThresholdSumLeft, MaxNumLeft : Integer;
  ThresholdSumRight, MaxNumRight : Integer;
//  MinValLeft, MinValRight : Integer;
  SumAll, MaxInd : Integer;
  WrkLength : Integer;
  StepLeft, StepRight : Integer;
//  MeanVal, FormFactor : Double;
//  MaxVal : Integer;
begin
  N_Dump2Str( 'LLULPar start, AIntPar=' + IntToStr(AIntPar) );

  N_HistRemoveZeros2( AHistValues, HNZVals, HNZInds ); // Remove Zeros

  if Length(HNZVals) = 0 then
  begin
    ALL := 0;
    AUL := High(AHistValues);
    Exit;
  end;

//*************************** Set Attributes
  CoefMean := 0.6;      // Smoothing LineComb Coef
  Coef     := 0.9;      // MinMax Value Search Coef - Part of previous Histogram Element
//  CoefSum  := 0.01;     // Area Treshold Coef - Part of All Histogram
  CoefNum  := 0.1;      // Histogram End Mounts Maximal Width Coef - Part of All Histogram elements number
//  CoefMinVal := 0.075;  // Value Treshold Coef - Part of Maximal Histogram Element
//  CoefMinVal := 0.01;  // Value Treshold Coef - Part of Maximal Histogram Element

  CoefAng := 1.50;      // Coef proportinal to Hist Gradient Angle

//  CoefPeak := 2;
//  CoefPeakCut := 1.5;
//  CoefPeak := 1.5;
//  CoefPeakCut := 1.1;

//1  CoefPeak    := 1.75;  // Peak Value Detect Coef - Part of previous Histogram Element
//2  CoefPeak    := 3.75;  // Peak Value Detect Coef - Part of previous Histogram Element
//3  CoefPeak    := 3.0;  // Peak Value Detect Coef - Part of previous Histogram Element
  CoefPeak    := 1.50;  // Peak Value Detect Coef - Part of previous Histogram Element
//  CoefPeakCut := 1.325; // Peak Value Replace Coef - Part of previous Histogram Element

//  if AIntPar = 1 then CoefPeak := 1.5
//  else if AIntPar = 2 then CoefPeak := 3.0
//  else if AIntPar = 3 then CoefPeak := 5.0;

  N_HistRemovePeaks1( HNZVals, CoefPeak ); // Remove Peak Values

  if AIntPar = 1 then CoefMean := 0.3
  else if AIntPar = 2 then CoefMean := 0.6
  else if AIntPar = 3 then CoefMean := 0.9;

  N_HistSmooth1( HNZVals, CoefMean ); // Smooth Values

//  MaxVal := N_HistMiddleMax1( HNZVals );
  MaxInd := N_HistMiddleMax2( HNZVals, 5, 0.2 ); // Calc Max Value w/o end elements
//  MaxVal := HNZVals[MaxInd];

  WrkLength := MaxInd + 1;
  SumAll := K_SumOfRArray( PInteger(@HNZVals[0]), WrkLength, SizeOf(Integer) );
//  MeanVal := SumAll / WrkLength;
//  FormFactor := 2 * MeanVal / MaxVal;
//  ThresholdSumLeft := Round(SumAll * CoefSum);
  ThresholdSumLeft := 50;

  StepLeft := Max( 5, Round( N_HistFindSum( HNZVals, 0, 1, SumAll shr 2 ) / 10 ) );

  ALL := N_HistFindSum( HNZVals, 0, 1, Round(SumAll / 16) );

  MaxNumLeft := Max(1, Round( WrkLength * CoefNum) );
//  MinValLeft := Max(1, Round(CoefMinVal * MaxVal) );
//  MinValLeft := Max(1, Round(CoefMinVal * MaxVal / (8 * FormFactor * FormFactor * FormFactor) ) );
//  MinValLeft := Min(MinValLeft, Round(2 * ThresholdSumLeft / MaxNumLeft) );

  WrkLength := Length(HNZVals) - MaxInd;
  SumAll := K_SumOfRArray( @HNZVals[MaxInd], WrkLength, SizeOf(Integer) );
//  MeanVal := SumAll / WrkLength;
//  FormFactor := 2 * MeanVal / MaxVal;

  StepRight := Max( 5, Round( (Length(HNZVals) - N_HistFindSum( HNZVals, High(HNZVals), -1, SumAll shr 2 )) / 10 ) );

  AUL := N_HistFindSum( HNZVals, High(HNZVals), -1, Round(SumAll / 16) );

//  ThresholdSumRight := Round( SumAll * CoefSum );
  ThresholdSumRight := 50;
  MaxNumRight := Max(1, Round( WrkLength * CoefNum ) );
//  MinValRight := Max( 1, Round( CoefMinVal * MaxVal ) );
//  MinValRight := Max( 1, Round( CoefMinVal * MaxVal / (8 * FormFactor * FormFactor * FormFactor) ) );
//  MinValRight := Min( MinValRight, Round( 2 * ThresholdSumRight / MaxNumRight ) );

  N_HistFindLLULN1( HNZVals, Coef, CoefAng, MaxInd,
           ThresholdSumLeft, MaxNumLeft, StepLeft,
           ThresholdSumRight, MaxNumRight, StepRight,
           ALL, AUL );

  ALL := HNZInds[ALL];
  AUL := HNZInds[AUL];
end; // function N_HistFindLLULPar1

//****************************************************** N_HistFindLLULPar2 ***
// Find ALL (Lower Limit) and AUL (Upper Limit) Variant #2 with integer parametr
//
//     Parameters
// AHistValues - given Histogramm Values
// AIntPar     - given integer parametr ( 0-exclude both (peaks and valleys), 1-exclude only peaks)
// ALL         - calculated Lower Limit (on output)
// AUL         - calculated Upper Limit (on output)
//
procedure N_HistFindLLULPar2( AHistValues: TN_IArray; AIntPar: Integer; out ALL, AUL: integer );
var
  HNZVals, HNZInds : TN_IArray;
  CoefMean, Coef, CoefSum, CoefNum, CoefMinVal, CoefPeak{, CoefPeakCut} : Double;
  SumAll, ThresholdSum, MaxNum, MinVal, MaxVal, MaxInd : Integer;
begin
//  N_Dump2Str( 'N_HistFindLLULPar2 start, AIntPar=' + IntToStr(AIntPar) );

//  N_HistRemoveZeros2( AHistValues, HNZVals, HNZInds ); // Remove Zero Values
  N_HistRemoveZeros3( AHistValues, HNZVals, HNZInds ); // Remove Zero Values

  if Length(HNZVals) = 0 then
  begin
    ALL := 0;
    AUL := High(AHistValues);
    Exit;
  end;

  CoefMean   := 0.6;   // Smoothing LineComb Coef
  Coef       := 0.9;   // MinMax Value Search Coef - Part of previous Histogram Element
  CoefSum    := 0.01;  // Area Treshold Coef - Part of All Histogram
  CoefNum    := 0.2;   // Histogram End Mounts Maximal Width Coef - Part of All Histogram elements number
  CoefMinVal := 0.075; // Value Treshold Coef - Part of Maximal Histogram Element
  CoefPeak   := 1.75;  // Peak Value Detect Coef - Part of previous Histogram Element

//  CoefSum    := 0.05;  // Area Treshold Coef - Part of All Histogram
//  CoefNum    := 0.5;   // Histogram End Mounts Maximal Width Coef - Part of All Histogram elements number

//  N_BrighHistToFile( HNZVals, 'C:\!Atmp\Hist2_1.txt', 'After remove zeros' );
  N_HistRemovePeaks1( HNZVals, CoefPeak ); // Remove Peak Values
//  N_BrighHistToFile( HNZVals, 'C:\!Atmp\Hist2_2.txt', Format( 'CoefPeak = %.3f', [CoefPeak] ) );

  N_HistSmooth1( HNZVals, CoefMean ); // Smooth Values

// Calc MaxVal and MaxInd - Max Value in HNZVals excluding some inteval on both ends
//  MaxVal := N_HistMiddleMax1( HNZVals );
  MaxInd := N_HistMiddleMax2( HNZVals, 5, 0.2 );
  MaxVal := HNZVals[MaxInd];

  SumAll := SumInt( HNZVals );
  ThresholdSum := Round( SumAll*CoefSum );
  MaxNum := Max(1, Round(Length(HNZVals) * CoefNum) );
  MinVal := Max(1, Round(CoefMinVal * MaxVal) );
//  MinVal := Min(MinVal, Round(2 * ThresholdSum / MaxNum) );

  if AIntPar = 1 then MinVal := 0;

  N_HistFindLLUL( HNZVals, Coef, ThresholdSum, MaxNum, MinVal, ALL, AUL );

//  N_BrighHistToFile( HNZVals, 'C:\!Atmp\Hist2_3.txt',
//    Format( 'CoefMean=%.3f, SumAll=%d, Coef=%.2f, ThresholdSum=%d, MaxNum=%d, MinVal=%d *** ALL=%d, AUL=%d',
//             [CoefMean,SumAll,Coef,ThresholdSum,MaxNum,MinVal,ALL,AUL] ) );

// Restore original LL/UL Values
// ( conv indexes in HNZVals array to indexes in AHistValues array)

  ALL := HNZInds[ALL];
  AUL := HNZInds[AUL];
end; // function N_HistFindLLULPar2

procedure N_HistFindLLULXX2( ACoeff: double; AHistValues: TN_IArray; out ALL, AUL: integer );
var
  ILL1, IUL1, ILL2, IUL2: Integer;
  HNZVals, HNZInds: TN_IArray;
  Alfa, PeakRatio, ValleyRatio, Center: double;
begin
  N_HistFindLLULPar2( AHistValues, 0, ILL1, IUL1 ); // aggressive (peaks  and valleys removed)
  N_HistFindLLULPar2( AHistValues, 1, ILL2, IUL2 ); // not aggressive (only peaks removed)

  ACoeff := max( 0, min( ACoeff, 1.0 ) ); // a precation, in [0,1] range
  PeakRatio   := 0.2;
  ValleyRatio := 0.7;

  if ACoeff < PeakRatio then // inside peaks
  begin
    N_HistRemoveZeros3( AHistValues, HNZVals, HNZInds ); // Remove Zero Values
   // HNZInds[0] - first non zero, HNZInds[High(HNZInds)] - last non zero

    Alfa := ACoeff / PeakRatio;
    ALL := round( ILL2*Alfa + HNZInds[0]*(1.0-Alfa) );
    AUL := round( IUL2*Alfa + HNZInds[High(HNZInds)]*(1.0-Alfa) );
  end else // ACoeff >= PeakRatio - inside valleys or outside valleys
  begin
    if ACoeff < ValleyRatio then // inside valleys, ALL in [ILL1,ILL2],  AUL in [IUL1,IUL2]
    begin
      Alfa := (ACoeff - PeakRatio) / (ValleyRatio - PeakRatio);

      ALL := round( ILL1*Alfa + ILL2*(1.0-Alfa) );
      AUL := round( IUL1*Alfa + IUL2*(1.0-Alfa) );
    end else // ACoeff >= ValleyRatio - outside valleys, stronger than [ILL1,IUL1]
    begin
      Center := ILL1 + 0.7 * (IUL1 - ILL1);
      Alfa := 0.6 * (ACoeff - ValleyRatio) / (1.0 - ValleyRatio);

      ALL := round( Center*Alfa + ILL1*(1.0-Alfa) );
      AUL := round( Center*Alfa + IUL1*(1.0-Alfa) );
    end; // else // ACoeff >= ValleyRatio - stronger than [ILL1,IUL1]
  end; // else // ACoeff >= PeakRatio - inside valleys or outside valleys

end; // procedure N_HistFindLLULXX2

//****************************************************** N_CMDIBAdjustLight ***
// Adjust given ADIBObj like Auto LL/UL but not so strong
//
//     Parameters
// ADIBObj - given DIBObj to adjust (8 or 16 bit)
//
procedure N_CMDIBAdjustLight( var ADIBObj: TN_DIBObj );
var
  ILL, IUL, XLATLength : Integer;
  HistValues, XLAT : TN_IArray;
  WrkLLFactor, WrkULFactor : FLoat;
begin
  N_Dump2Str( 'N_CMDIBAdjustLight Start ' );

// Calc WrkLLFactor and WrkLUFactor
  ADIBObj.CalcBrighHistNData( HistValues );

  N_HistFindLLUL11( HistValues, ILL, IUL ); // like Auto LL/UL but not so strong

  WrkLLFactor := ILL / High(HistValues) * 100;
  WrkULFactor := IUL / High(HistValues) * 100;

// Correct LL/LU to Initial Values if needed
  if (WrkLLFactor = 0) and (WrkULFactor = 100) then
    WrkULFactor := 0;

  XLATLength := 1 shl ADIBObj.DIBNumBits;
  SetLength( XLat, XLATLength );
  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, 0, -26.1, WrkLLFactor, WrkULFactor, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

  N_Dump2Str( 'N_CMDIBAdjustLight Fin' );
end; // procedure N_CMDIBAdjustLight

//***************************************************** N_CMDIBAdjustNormal ***
// Adjust given ADIBObj exactly as Auto LL/UL
//
//     Parameters
// ADIBObj - given DIBObj to adjust (8 or 16 bit)
//
procedure N_CMDIBAdjustNormal( var ADIBObj: TN_DIBObj );
var
  ILL, IUL, XLATLength : Integer;
  HistValues, XLAT : TN_IArray;
  WrkLLFactor, WrkULFactor : FLoat;
begin
  N_Dump2Str( 'N_CMDIBAdjustLight Start ' );

// Calc WrkLLFactor and WrkLUFactor
  ADIBObj.CalcBrighHistNData( HistValues );

  N_HistFindLLUL22( HistValues, ILL, IUL ); // exactly as Auto LL/UL

  WrkLLFactor := ILL / High(HistValues) * 100;
  WrkULFactor := IUL / High(HistValues) * 100;

// Correct LL/LU to Initial Values if needed
  if (WrkLLFactor = 0) and (WrkULFactor = 100) then
    WrkULFactor := 0;

  XLATLength := 1 shl ADIBObj.DIBNumBits;
  SetLength( XLat, XLATLength );
  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, 0, -26.1, WrkLLFactor, WrkULFactor, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

  N_Dump2Str( 'N_CMDIBAdjustLight Fin' );
end; // procedure N_CMDIBAdjustNormal

//**************************************************** N_CMDIBAdjustAutoAll ***
// Adjust given ADIBObj like Auto LL/UL with given APower coef
//
//     Parameters
// ADIBObj - given DIBObj to adjust (8 or 16 bit)
// APower  - in [0,1] range, 0.0-no changes, 1.0- max changes
//           (same as Power value in BriCoGam Editor)
//
procedure N_CMDIBAdjustAutoAll( var ADIBObj: TN_DIBObj; APower: double );
var
  ILL, IUL, XLATLength: Integer;
  HistValues, XLAT: TN_IArray;
  WrkLLFactor, WrkULFactor: Double;
begin
  N_Dump2Str( 'N_CMDIBAdjustAutoAll Start ' );

// Calc WrkLLFactor and WrkLUFactor
  ADIBObj.CalcBrighHistNData( HistValues );
  N_HistFindLLULXX2( APower, HistValues, ILL, IUL );
//  N_HistFindLLUL11( HistValues, ILL, IUL ); // like Auto LL/UL but not so strong

  WrkLLFactor := ILL / High(HistValues) * 100;
  WrkULFactor := IUL / High(HistValues) * 100;

// Correct LL/LU to Initial Values if needed
  if (WrkLLFactor = 0) and (WrkULFactor = 100) then
    WrkULFactor := 0;

  XLATLength := 1 shl ADIBObj.DIBNumBits;
  SetLength( XLat, XLATLength );
  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, 0, 0, WrkLLFactor, WrkULFactor, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

  N_Dump2Str( 'N_CMDIBAdjustAutoAll Fin' );
end; // procedure N_CMDIBAdjustAutoAll

//******************************************************** N_CMDIBAdjustE2V ***
// Adjust given ADIBObj for E2V
//
//     Parameters
// ADIBObj - given DIBObj to adjust (from 8 to 16 bit)
//
procedure N_CMDIBAdjustE2V( var ADIBObj: TN_DIBObj );
var
  ILL, IUL, ILL1, IUL1, ILL2, IUL2, XLATLength, IntPar1, IntPar2: Integer;
  HistValues, XLAT: TN_IArray;
  WrkLLFactor, WrkULFactor: FLoat;
  Alfa: Double;
begin
//  N_Dump2Str( 'N_CMDIBAdjustE2V Start' );

  ADIBObj.CalcBrighHistNData( HistValues );
  N_HistFindLLULPar2( HistValues, 0, ILL1, IUL1 ); // aggressive (peaks  and valleys removed)
  N_HistFindLLULPar2( HistValues, 1, ILL2, IUL2 ); // not aggressive (only peaks removed)

  IntPar1 := N_MemIniToInt( 'CMS_UserMain', 'MediaRayFiltLU', 33 );
  IntPar1 := max( 0, min( IntPar1, 100 ) );
  Alfa := IntPar1 / 100.0;

  ILL := round( ILL1*Alfa + ILL2*(1.0-Alfa) );
  IUL := round( IUL1*Alfa + IUL2*(1.0-Alfa) );

  N_Dump1Str( Format( 'N_CMDIBAdjustE2V ILL1=%d, ILL2=%d, ILL=%d,  IUL1=%d, IUL2=%d, IUL=%d', [ILL1,ILL2,ILL,IUL1,IUL2,IUL] ) );

  WrkLLFactor := ILL / High(HistValues) * 100;
  WrkULFactor := IUL / High(HistValues) * 100;

// Correct LL/LU to Initial Values if needed
  if (WrkLLFactor = 0) and (WrkULFactor = 100) then
    WrkULFactor := 0;

  XLATLength := 1 shl ADIBObj.DIBNumBits;
  SetLength( XLat, XLATLength );
  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, 0, 0, WrkLLFactor, WrkULFactor, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

  IntPar2 := N_MemIniToInt( 'CMS_UserMain', 'MediaRayFiltEq', 10 );
  IntPar2 := max( 0, min( IntPar2, 100 ) );
  Alfa := 1.0 + 2.0 * IntPar2 / 100.0;

  if Alfa > 1.0 then
    ADIBObj.CalcEqualizedDIB( ADIBObj, 30, Alfa );

  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, -8, 19.0, 0.0, 100.0, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

{
var
  IntPar, FNum: Integer;
  FName: String;
  IntParStr: AnsiString;
begin
  IntPar := -1;
  if FileExists( '..\E2V_Filter.txt' ) then
  begin
    N_s := N_ReadANSITextFile( '..\E2V_Filter.txt' );
    N_s := Trim( N_s );
    N_Dump2Str( 'N_CMDIBAdjustE2V E2V_Filter.txt=' +  N_s );
    IntPar := StrToInt( N_s );
  end;

  if IntPar >= 0 then
    N_CMDIBAdjustByIntPar2( ADIBObj, IntPar );

  FNum := 1;
  FName := N_CreateUniqueFileName( '..\E2VDump_', FNum, '.png' );
  N_SaveDIBToFileByImLib( ADIBObj, FName );
//  FName := ChangeFileExt( FName, '' ) + 'a.png';
}

  N_Dump1Str( Format( 'N_CMDIBAdjustE2V Fin UL=%d, Eq=%d', [IntPar1,IntPar2] ) );
end; // procedure N_CMDIBAdjustE2V

//*************************************************** N_CMDIBAdjustByIntPar ***
// Adjust given ADIBObj like Auto LL/UL with given integer parametr AIntPar
//
//     Parameters
// ADIBObj - given DIBObj to adjust (8 or 16 bit)
// AIntPar - given integer parametr (bit0 - Autoequalize param (0-nothing, 1-1.2), bits12 - AutoLL/UL strength
//
procedure N_CMDIBAdjustByIntPar( var ADIBObj: TN_DIBObj; AIntPar: integer );
var
  ILL, IUL, ILL1, IUL1, ILL2, IUL2, XLATLength, LLULMode: Integer;
  HistValues, XLAT: TN_IArray;
  WrkLLFactor, WrkULFactor: FLoat;
  Alfa: Double;
begin
  N_Dump2Str( 'N_CMDIBAdjustByIntPar Start, IntPar=' + IntToStr(AIntPar) );

// Calc WrkLLFactor and WrkLUFactor
  ADIBObj.CalcBrighHistNData( HistValues );

//  N_BrighHistToFile( HistValues, 'C:\!Atmp\Hist1.txt', '' );

  N_HistFindLLULPar2( HistValues, 0, ILL1, IUL1 ); // aggressive (peaks  and valleys removed)
  N_HistFindLLULPar2( HistValues, 1, ILL2, IUL2 ); // not aggressive (only peaks removed)


//!!!  LLULMode := (AIntPar shr 1) and $03;
  LLULMode := AIntPar;

  Alfa := 0.0;
       if LLULMode = 1 then Alfa := 0.33
  else if LLULMode = 2 then Alfa := 0.66;


  ILL := round( ILL1*Alfa + ILL2*(1.0-Alfa) );
  IUL := round( IUL1*Alfa + IUL2*(1.0-Alfa) );

  WrkLLFactor := ILL / High(HistValues) * 100;
  WrkULFactor := IUL / High(HistValues) * 100;

// Correct LL/LU to Initial Values if needed
  if (WrkLLFactor = 0) and (WrkULFactor = 100) then
    WrkULFactor := 0;

  XLATLength := 1 shl ADIBObj.DIBNumBits;
  SetLength( XLat, XLATLength );
  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, 0, 0, WrkLLFactor, WrkULFactor, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

//!!!  if (AIntPar and $01) <> 0 then
  if AIntPar <= 1 then
    ADIBObj.CalcEqualizedDIB( ADIBObj, 30, 1.2 );

  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, -8, 19.0, 0.0, 100.0, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

  N_Dump2Str( 'N_CMDIBAdjustByIntPar Fin' );
end; // procedure N_CMDIBAdjustByIntPar

//******************************************************* N_CMDIBAdjustULEq ***
// Adjust given ADIBObj by given Auto LL/UL and Auto Equalize Params
//
//     Parameters
// ADIBObj - given DIBObj to adjust (from 8 to 16 bit)
// AAutoUL - Auto LL/UL param in [0,1], 0.0 means just skip min and max Peaks
//                                      1.0 means skip peaks and small values after peaks
// AAutoEq - Auto Equalize param in [0,1], 0.0 means no effect, 1.0 means maximal effect
//
procedure N_CMDIBAdjustULEq( var ADIBObj: TN_DIBObj; AAutoUL, AAutoEq: double );
var
  ILL, IUL, ILL1, IUL1, ILL2, IUL2, XLATLength: Integer;
  HistValues, XLAT: TN_IArray;
  WrkLLFactor, WrkULFactor: FLoat;
  Alfa: Double;
begin
  N_Dump2Str( 'N_CMDIBAdjustULEq Start' );

  ADIBObj.CalcBrighHistNData( HistValues );
  N_HistFindLLULPar2( HistValues, 0, ILL1, IUL1 ); // aggressive (peaks  and valleys removed)
  N_HistFindLLULPar2( HistValues, 1, ILL2, IUL2 ); // not aggressive (only peaks removed)

  Alfa := max( 0.0, min( AAutoUL, 1.0 ) ); // should be in [0,1] range
  ILL := round( ILL1*Alfa + ILL2*(1.0-Alfa) );
  IUL := round( IUL1*Alfa + IUL2*(1.0-Alfa) );

  WrkLLFactor := ILL / High(HistValues) * 100;
  WrkULFactor := IUL / High(HistValues) * 100;

// Correct LL/LU to Initial Values if needed
  if (WrkLLFactor = 0) and (WrkULFactor = 100) then
    WrkULFactor := 0;

  XLATLength := 1 shl ADIBObj.DIBNumBits;
  SetLength( XLat, XLATLength );
  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, 0, 0, WrkLLFactor, WrkULFactor, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

  Alfa := max( 0.0, min( AAutoEq, 1.0 ) ); // should be in [0,1] range
  Alfa := 1.0 + 2.0*Alfa; // in [1.0,3.0) range

  if Alfa > 1.0 then
    ADIBObj.CalcEqualizedDIB( ADIBObj, 30, Alfa );

  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, -8, 19.0, 0.0, 100.0, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

  N_Dump2Str( Format( 'N_CMDIBAdjustULEq Fin UL=%.2f, Eq=%.2f', [AAutoUL, AAutoEq] ) );
end; // procedure N_CMDIBAdjustULEq

//********************************************************* N_CMDIBAdjustUL ***
// Adjust given ADIBObj by given AAutoUL Parameter
//
//     Parameters
// ADIBObj - given DIBObj to adjust (from 8 to 16 bit)
// AAutoUL - Auto LL/UL param <= 1, < 0.0 means AutoConrast
//                                  = 0.0 means just skip min and max Peaks
//                                  = 1.0 means skip peaks and small values after peaks
//
procedure N_CMDIBAdjustUL( var ADIBObj: TN_DIBObj; AAutoUL: double );
begin
end; // procedure N_CMDIBAdjustUL

//********************************************************* N_CMDIBAdjustEq ***
// Adjust given ADIBObj by given AAutoEq Parameter
//
//     Parameters
// ADIBObj - given DIBObj to adjust (from 8 to 16 bit)
// AAutoEq - Auto Equalize param in [0,1], 0.0 means no effect, 1.0 means maximal effect
//
procedure N_CMDIBAdjustEq( var ADIBObj: TN_DIBObj; AAutoEq: double );
begin
end; // procedure N_CMDIBAdjustEq

//************************************************** N_CMDIBAdjustByIntPar2 ***
// Adjust given ADIBObj like Auto LL/UL with given integer parametr AIntPar
//
//     Parameters
// ADIBObj - given DIBObj to adjust (8 or 16 bit)
// AIntPar - given integer parametr (bit0 - Autoequalize param (0-nothing, 1-1.2), bits12 - AutoLL/UL strength
//
procedure N_CMDIBAdjustByIntPar2( var ADIBObj: TN_DIBObj; AIntPar: integer );
var
  ILL, IUL, ILL1, IUL1, ILL2, IUL2, XLATLength, LLULMode: Integer;
  HistValues, XLAT: TN_IArray;
  WrkLLFactor, WrkULFactor: FLoat;
  Alfa: Double;
begin
  N_Dump2Str( 'N_CMDIBAdjustByIntPar Start, IntPar=' + IntToStr(AIntPar) );

// Calc WrkLLFactor and WrkLUFactor
  ADIBObj.CalcBrighHistNData( HistValues );

//  N_BrighHistToFile( HistValues, 'C:\!Atmp\Hist1.txt', '' );

  N_HistFindLLULPar2( HistValues, 0, ILL1, IUL1 ); // aggressive (peaks  and valleys removed)
  N_HistFindLLULPar2( HistValues, 1, ILL2, IUL2 ); // not aggressive (only peaks removed)


  LLULMode := (AIntPar shr 1) and $03;

  Alfa := 0.0;
       if LLULMode = 1 then Alfa := 0.33
  else if LLULMode = 2 then Alfa := 0.66
  else if LLULMode = 3 then Alfa := 1.00;

  ILL := round( ILL1*Alfa + ILL2*(1.0-Alfa) );
  IUL := round( IUL1*Alfa + IUL2*(1.0-Alfa) );

  WrkLLFactor := ILL / High(HistValues) * 100;
  WrkULFactor := IUL / High(HistValues) * 100;

// Correct LL/LU to Initial Values if needed
  if (WrkLLFactor = 0) and (WrkULFactor = 100) then
    WrkULFactor := 0;

  XLATLength := 1 shl ADIBObj.DIBNumBits;
  SetLength( XLat, XLATLength );
  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, 0, 0, WrkLLFactor, WrkULFactor, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

  if (AIntPar and $01) <> 0 then
    ADIBObj.CalcEqualizedDIB( ADIBObj, 30, 1.2 );

  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, -8, 19.0, 0.0, 100.0, FALSE );
  ADIBObj.CalcXLATDIB( ADIBObj, 0, @XLAT[0], 1, ADIBObj.DIBPixFmt, ADIBObj.DIBExPixFmt );

  N_Dump2Str( 'N_CMDIBAdjustByIntPar Fin' );
end; // procedure N_CMDIBAdjustP2

//******************************************************* N_ConvHist8ByXLAT ***
// Convert given 8 bit Brightness Histogram by given XLAT Table
//
//     Parameters
// ASrcHistValue  - source integer array of 8 bit Data Brightness Histogram
// APXLAT         - pointer to first element of given integer XLAT Table
// AResHistValues - resulting 8 bit Brightness Histogram converted by given XLAT Table
// APMinHistInd   - Pointer to resulting minimal index with non zero data
// APMaxHistInd   - Pointer to resulting maximal index with non zero data
// APMaxHistVal   - Pointer to resulting maximal data element value
//
// HistValues[i] is number of pixels with brightness = i
//
// If AResHistValues Array has more than 256 elements it is not truncated
// (only first 256 elements are calculated)
//
// APMinHistInd, APMaxHistInd and APMaxHistVal may be nil. This means that
// appropriate resulting values will be not caculated
//
// AResHistValues[i] = 0 for (i < APMinHistInd) and (i > APMaxHistInd)
// Max( AResHistValues[i], 0<=i<256 ) = APMaxHistVal^
//
procedure N_ConvHist8ByXLAT( ASrcHistValues: TN_IArray; APXLAT: PInteger;
                             var AResHistValues: TN_IArray; APMinHistInd: PInteger = nil;
                             APMaxHistInd: PInteger = nil; APMaxHistVal: PInteger = nil );
var
  i: integer;
  CurPXLat: PInteger;
begin
  SetLength( AResHistValues, 256 );
  FillChar( AResHistValues[0], 256*SizeOf(Integer), 0 );

  if APXLAT = nil then // XLAT Table not given, just copy current HistValues
  begin
    move( ASrcHistValues[0], AResHistValues[0], 256*SizeOf(Integer) );
  end else // XLAT was given, use it
  begin
    CurPXLat := APXLAT;

    for i := 0 to 255 do
    begin
      AResHistValues[CurPXLat^] := AResHistValues[CurPXLat^] + ASrcHistValues[i];
      Inc( CurPXLat );
    end;
  end; // else // XLAT was given, use it

  if APMaxHistVal <> nil then // Calc APMaxHistVal^
  begin
    APMaxHistVal^ := 0;
    for i := 0 to 255 do
      if APMaxHistVal^ < AResHistValues[i] then APMaxHistVal^ := AResHistValues[i];
  end; // if APMaxHistVal <> nil then // Calc APMaxHistVal^

  if APMinHistInd <> nil then // Calc APMinHistInd^
    for i := 0 to 255 do
      if AResHistValues[i] > 0 then
      begin
        APMinHistInd^ := i;
        Break;
      end;

  if APMaxHistInd <> nil then // Calc APMaxHistInd^
    for i := 255 downto 0 do
      if AResHistValues[i] > 0 then
      begin
        APMaxHistInd^ := i;
        Break;
      end;

end; // procedure N_ConvHist8ByXLAT

//***************************************************** N_BCGImageXlatBuild ***
// Build Image correction XLat Table
//
//     Parameters
// AXLat       - Image XLat correction table ( 256 <= Length(AXLat) <= 2**16, cannot be nil!)
// AMaxY       - Max AXLat elements value (255 for 8 bit images)
// AXMinFactor - X Min Factor in (0,100), absolute XMin = 0.01*AXMinFactor*XMaxA, XMaxA = High(AXLat)
// AXMaxFactor - X Max Factor in (0,100), absolute XMax = 0.01*AXMaxFactor*XMaxA, XMaxA = High(AXLat)
//               AXMaxFactor=0 means that AXMaxFactor=100
// ACoFactor   - Image Contrast factor (float from -100 to 100, 0 - no contarst
//               correction done)
// ABriFactor  - Image Brightness factor (float from -100 to 100, 0 - no
//               brightness correction done)
// AGamFactor  - Image Gamma factor (float from -100 to 100, 0 - no gamma
//               correction done)
// ANegateFlag - Negate Convertion Flag
//
// If all factors are zero, AXLat[i] is a convertion line from (XMin,0) to (XMax, AMaxY)
// or from (XMin,AMaxY) to (XMax, 0) if ANegateFlag=True
//
// While ACoFactor changes from 0 to -100, convertion line changes in normalized (0,1) coords
// from (0,0)-(1,1) to (0,0.5)-(1,0.5) (horizontal line) or is (0,Y1)-(1,1-Y1), where Y1=0.005*ACoFactor
// While ABriFactor changes from -100 to +100,
// convertion line moves along vertical axis by DY = +/-(1-Y1)
//
// While ACoFactor changes from 0 to 100, convertion line changes in normalized (0,1) coords
// from (0,0)-(1,1) to (0.5,0)-(0.5,1) (vertical line) or is (X1,0)-(1-X1,1), where X1=0.005*ACoFactor
// While ABriFactor changes from -100 to +100,
// convertion line moves along horizontal axis by DX = +/-(1-X1)
//
procedure N_BCGImageXlatBuild( const AXLat : TN_IArray; AYMax: Integer;
                               ACoFactor, ABriFactor, AGamFactor,
                               AXMinFactor, AXMaxFactor: Double; ANegateFlag: Boolean );
var
  i, XMin, XMax, YBefore, YAfter: Integer;
  X1,Y1, DX, DY, AN, AA, BN, YN, Delta, CurBriFactor: Double;
begin
  //***** Calc AN, BN coefs ( YN = AN*XN + BN (in normalized coords) )


  if ANegateFlag then CurBriFactor := - ABriFactor
                 else CurBriFactor := ABriFactor;

  if ACoFactor >= 0 then // increase contrast
  begin
    if ACoFactor > 99.999 then ACoFactor := 99.999; // to avoid divizion by zero

    // Initial CC (Convertion Curve) in norm. coords is (0,0)-(1,1) segment
    // After Contrast correction has three segments (0,0)-(X1,0)-(1-X1,1)-(1,1)
    // After Brightness correction has three segments (0,0)-(X1-DX,0)-(1-X1-DX,1)-(1,1)

    X1 := 0.005*ACoFactor; // X1 is in (0, 0.499999) range
    DX := -0.01*CurBriFactor*(1.0 - X1); // CC horizontal shift value (DX>0 means increasing brightness)

    // YN = AN*XN + BN (in normalized coords)
    // YN = 0.5 + ((XN-X05)*0.5/(X2-X05), X05=0.5*(X1-DX + 1-X1-DX)=0.5-DX, X2=1-X1-DX

    AN := 0.5/(0.5-X1);
    BN := 0.5 - (DX+0.5)*0.5/(0.5-X1);
  end else // ACoFactor < 0, decrease contrast
  begin
    if ACoFactor < -99.999 then ACoFactor := -99.999; // to avoid divizion by zero

    // Initial CC (Convertion Curve) in norm. coords is (0,0)-(1,1) segment
    // After Contrast correction has one segment (0,Y1)-(1,1-Y1)
    // After Brightness correction has one segment (0,Y1+DY)-(1,1-Y1+DY)

    Y1 := -0.005*ACoFactor; // Y1 is in (0, 0.499999) range
    DY := 0.01*CurBriFactor*(1.0 - Y1); // CC vertical shift value (DY>0 means increasing brightness)

    // YN = AN*XN + BN (in normalized coords)
    // YN = Y1+DY + XN*(1.0 - 2*Y1);

    AN := 1.0 - 2*Y1;
    BN := Y1 + DY;
  end;

  //***** Calc XMin, XMax - real argument convertion range given by AXMinFactor, AXMaxFactor

  if AXMinFactor >= 99 then AXMinFactor := 99;
  if AXMaxFactor  = 0  then AXMaxFactor := 100;
  if AXMaxFactor <= AXMinFactor then AXMaxFactor := AXMinFactor + 1;

  XMin := Round( 0.01*AXMinFactor * High(AXLat) );
  XMax := Round( 0.01*AXMaxFactor * High(AXLat) );

  AA := AN / (XMax - XMin); // for using with absolute x coords (in (XMin,XMax) range)

  if ANegateFlag then // apply ANegateFlag - conv YN to 1.0 - YN
  begin
    AA := -AA;
    BN := 1.0 - BN;
  end; // if ANegateFlag then // conv YN to 1.0 - YN

  //***** Calc Delta, needed to apply Gamma Factor
  Delta := Abs(0.01*AGamFactor);
  if AGamFactor >= 0 then  //    0 <= AGamFactor <= 100
    Delta := 1.0 - 0.9 * Delta
  else                     // -100 <= AGamFactor <=   0
    Delta := 1.0 + 9.0 * Delta;

  //***** Calc YBefore, YAfter

  if ANegateFlag then // negative image, convertion curve is always decreasing
  begin
    YBefore := AYMax;
    YAfter  := 0;
  end else // normal image, convertion curve is always increasing
  begin
    YBefore := 0;
    YAfter  := AYMax;
  end;

  //***** main loop - calc all AXLat elements

  for i := 0 to High(AXLat) do // along all X integer values
  begin
         if i < XMin then AXLat[i] := YBefore // before (XMin,XMax) interval
    else if i > XMax then AXLat[i] := YAfter  // after (XMin,XMax) interval
    else // i is inside (XMin, XMax)
    begin

      YN := AA*(i-XMin) + BN; // YN normalized, X - absolute (X=i-XMin)

           if YN >= 1.0 then AXLat[i] := AYMax
      else if YN <= 0.0 then AXLat[i] :=  0
      else // 0 < YN < 1.0
      begin
        if Delta <> 1.0 then // apply Gamma Factor
          YN := Power( YN, Delta );

        AXLat[i] := Round( YN*AYMax );
      end;

    end; //  i is inside (XMin, XMax)

  end; // for i := 0 to High(AXLat) do // along all X integer values
end; // procedure N_BCGImageXlatBuild

//********************************************************* N_LayoutIRects1 ***
// Calculate Rects coords by given RArray of Strings
//
//     Parameters
// AParams - given RArray of Strings
// Result  - Return resulting Array of TN_StrIRS (Array of String and TRectS)
//
// AParams[0] - general params -
//              WholeX WholeY DX DY:
//              WholeX, WholeY - whole canvas size in pixels (0, 0, WholeX-1, WholeY-1)
//              DX, DY - empty borders (Gaps) at Canvas edges (all rects are in (DX, DY, WholeX-1-DX, WholeY-1-DY)
// AParams[i] - i-th group of Rects params -
//              RX RY GX GY * NX NY N * HPCX HPCY HPPX HPPY HPSX HPSY Str1 (Str2 Str3 ...):
//              RX RY - all Rects in Group size in pixels
//              GX GY - Gaps between Rects in Group in pixels
//              *     - any delimeter char (with at least one space before and after)
//              NX NY - Number of Rects Columns and Rows in Group
//                      (negative values means reverse order (from right to left, from bottom up)
//              N     - Number of Rects in Group
//                      (negative value means layout by columns, positive - by rows)
//              *     - any delimeter char (with at least one space before and after)
//                 HotPoint means all Group Rects Envelope HotPoint
//              HPCX HPCY - HotPoint Coords in percents of whole canvas
//                         (in (0,100) range, 100 100 - means bottom right canvas corner)
//              HPPX HPPY - HotPoint Position relative coords in (0,1) range
//                          (0 0 means upper left Envelope corner; 1 1 - means lower right Envelope corner )
//              HPSX HPSY - additional HotPoint Coords shift in pixels
//              Str1 (Str2 Str3 ...) - any number of tokens
//
// Result[0] - calculated whole Pattern Rect, all others - Pattern Items Rects with String
// If Group has only one Last token Str1, it will be copied to all Result[i].Str fields
// otherwise each Result[wind].Str field will have individual value (Str1 Str2 ...)
//
procedure N_LayoutIRects1( AParams: TK_RArray; out ASIRSArray : TN_SIRSArray );
var
  ig, ix, iy, gind, wind, NumStrings, aix, aiy: integer;
  GrX, GrY, GRSizeX, GrSizeY: integer;
  RX, RY, GX, GY, NX, NY, N, HPSX, HPSY: integer;
  WholeX, WholeY, DX, DY: integer;
  HPCX, HPCY, HPPX, HPPY: double;
  Str: string;
  StrArray: TN_SArray;
begin
  ASIRSArray := nil;
  Str := PString(AParams.P(0))^;
  N_ScanIntegers( Str, [@WholeX, @WholeY, @DX, @DY] );
  SetLength( ASIRSArray, 1 );
  ASIRSArray[0].IRS := IRectS( WholeX, WholeY );
  wind := 1; // index in Result Array
  N_DumpStr( N_Dump1LCInd, 'TestDump - N_LayoutIRects1' );

  for ig := 1 to AParams.AHigh() do // along all Rects Groups
  begin
    Str := PString(AParams.P(ig))^;
    N_ScanIntegers( Str, [@RX, @RY, @GX, @GY] );
    N_s := N_ScanToken( Str ); // any delimeter is OK

    N_ScanIntegers( Str, [@NX, @NY, @N] ); // may be negative!
    N_s := N_ScanToken( Str ); // any delimeter is OK

    N_ScanDoubles( Str, [@HPCX, @HPCY, @HPPX, @HPPY] );
    N_ScanIntegers( Str, [@HPSX, @HPSY] );

    NumStrings := N_ScanSArray( Str, StrArray );
    SetLength( StrArray, NumStrings );

    // Calc GRSizeX, GRSizeY - Group Envelope Rect Size in Pixels
    GRSizeX := abs(NX)*RX + abs(NX-1)*GX;
    GRSizeY := abs(NY)*RY + abs(NY-1)*GY;

    // Calc GrX, GrY - Group Envelope Rect UpperLeft corner coords in Pixels

    GrX := DX  + Round( 0.01*HPCX*( WholeX - 2*DX - 1 ) );
    GrX := GrX - Round(HPPX*(GRSizeX-1)) + HPSX;

    GrY := DY  + Round( 0.01*HPCY*( WholeY - 2*DY - 1 ) );
    GrY := GrY - Round(HPPY*(GRSizeY-1)) + HPSY;

    SetLength( ASIRSArray, wind+abs(N) );

    for gind := 0 to abs(N)-1 do // along all elems in group
    begin
      //***** Calc ix,iy by sign of N, NX, NY

      if N > 0 then // positive N means layout by rows
      begin
        aiy := gind div abs(NX); // Abs value of iy (abs row index)
        aix := gind mod abs(NX); // Abs value of ix (abs column index)
      end else // negative N means layout by columns
      begin
        aiy := gind mod abs(NY); // Abs value of iy (abs row index)
        aix := gind div abs(NY); // Abs value of ix (abs column index)
      end;

      if NX > 0 then // positive NX means from left to right order of rects
        ix := aix
      else // negative NX means from right to left order of rects
        ix := -NX - 1 - aix;

      if NY > 0 then // positive NY means from up to bottom order of rects
        iy := aiy
      else // negative NY means from bottom  up order of rects
        iy := -NY - 1 - aiy;

      //***** ix, iy are OK, calc rect coods

      ASIRSArray[wind].IRS.TopLeft.X := GrX + ix*(RX+GX);
      ASIRSArray[wind].IRS.TopLeft.Y := GrY + iy*(RY+GY);
      ASIRSArray[wind].IRS.Size.X := RX;
      ASIRSArray[wind].IRS.Size.Y := RY;

      if NumStrings > gind then
        ASIRSArray[wind].Str := StrArray[gind]
      else if NumStrings = 0 then
        ASIRSArray[wind].Str := ''
      else
        ASIRSArray[wind].Str := StrArray[0];

      Inc( wind );
    end; // for gind := 0 to abs(N)-1 do // along all elems in group
  end; // for ig := 1 to AParams.ALength() do // along all Rects Groups
end; // function N_LayoutIRects1

//********************************************************* N_CalcGaussMatr ***
// Calculate Gauss Matrix by given matrix dimension and sigma
//
//     Parameters
// AMatr  - resulting matrix
// ADim   - matrix dimension
// ASigma - Gauss function Sigma factor
// AFlags - matrix build parameter (now if <> 0 then central element set to 0)
//
procedure N_CalcGaussMatr( var AMatr: TN_FArray; ADim: Integer; ASigma: Double;
                           AFlags: Integer = 0 );
var
  MatrixCapacity : Integer;
  i, j, CInd, NInd, HDim : Integer;
  DX, DY, DStep : Integer;
  Sum : Double;
begin
  MatrixCapacity := ADim * ADim;

  if Length(AMatr) < MatrixCapacity then
  begin
    AMatr := nil;
    SetLength( AMatr, MatrixCapacity );
  end;

  HDim := ADim shr 1;
  ASigma := ASigma * HDim;
  ASigma := 2 * ASigma * ASigma; // Sigma Square

  Sum := 0;
  CInd := 0; // for Delphi warning prevent
  // Calc Matrix Upper/Left Corner

  for i := 0 to HDim do
  begin
    CInd := i * ADim;
    DY := HDim - i;

    for j := CInd to CInd + HDim do
    begin
      DX := CInd + HDim - j;
      AMatr[j] := exp( - (DX*DX + DY*DY) / ASigma );
      Sum := Sum + AMatr[j];
    end; // for j := CInd to CInd + HDim do
  end; // for i := 0 to HDim do

  if AFlags <> 0 then
  begin
  // Clear Matrix Central Element
    j := CInd  + HDim;
    Sum := Sum - AMatr[j];
    AMatr[j] := 0;
  end;

  // Fill Matrix Upper/Right Corner
  for i := 0 to HDim do
  begin
    CInd := i * ADim;
    NInd := CInd + ADim - 1;

    for j := CInd to CInd + HDim - 1 do
    begin
      AMatr[NInd] := AMatr[j];
      Sum := Sum + AMatr[j];
      Dec(NInd);
    end; // for j := CInd to CInd + HDim - 1 do
  end; // for i := 0 to HDim do

  // Calc Proper Sum
  Sum := Sum + Sum;
  CInd := HDim * ADim;

  for j := CInd to CInd + ADim - 1 do
    Sum := Sum - AMatr[j];

  // Correct Matrix By Sum and fill Matrix Low Half
  NInd := ADim * (ADim - 1);
  DStep := ADim * SizeOf(Float);

  for i := 0 to HDim - 1 do
  begin
    CInd := i * ADim;

    for j := CInd to CInd + ADim - 1 do
      AMatr[j] := AMatr[j] / Sum;

    Move( AMatr[CInd], AMatr[NInd], DStep );
    Dec( NInd, ADim);
  end; // for i := 0 to HDim - 1 do

  CInd := HDim * ADim;

  for j := CInd to CInd + ADim - 1 do
    AMatr[j] := AMatr[j] / Sum;

end; // procedure N_CalcGaussMatr

//******************************************************* N_CalcGaussVector ***
// Calculate Gauss Vector by given Vector size and sigma
//
//     Parameters
// AVector - resulting vector
// ADim    - resulting Vector size
// ASigma  - Gauss function Sigma factor
//
procedure N_CalcGaussVector( var AVector: TN_FArray; ADim: Integer; ASigma: Double );
var
  MatrixCapacity : Integer;
  i, HDim : Integer;
  Sum : Double;
begin
  MatrixCapacity := ADim;

  if Length(AVector) < MatrixCapacity then
  begin
    AVector := nil;
    SetLength( AVector, MatrixCapacity );
  end;

  HDim := ADim shr 1;
  ASigma := ASigma * HDim;
  ASigma := 2 * ASigma * ASigma; // Sigma Square

  Sum := 0;
  // Calc Matrix Left Corner
  for i := 0 to HDim do
  begin
    AVector[i] := exp( - (HDim - i) * (HDim - i) / ASigma );
    Sum := Sum + AVector[i];
  end;

  // Fill Matrix Right Corner
  for i := 0 to HDim - 1 do
  begin
    AVector[ADim - i - 1] := AVector[i];
    Sum := Sum + AVector[i];
  end;

  for i := 0 to ADim - 1 do
    AVector[i] := AVector[i] / Sum;
end; // procedure N_CalcGaussVector

//******************************************************** N_CalcLaplasMatr ***
// Calculate Laplace 3x3 matrix
//
//     Parameters
// ADMatr  - resulting matrix
// AFactor - Laplas coeficients factor
//
procedure N_CalcLaplasMatr( var ADMatr: TN_FArray; AFactor: Float );
begin
  SetLength( ADMatr, 9 );
  AFactor := Max( Min( AFactor, 2 ), 0 );
  
  ADMatr[0] := AFactor - 1;
  ADMatr[1] := - AFactor;
  ADMatr[2] := ADMatr[0];

  ADMatr[3] := ADMatr[1];
  ADMatr[4] := 4;
  ADMatr[5] := ADMatr[1];

  ADMatr[6] := ADMatr[0];
  ADMatr[7] := ADMatr[1];
  ADMatr[8] := ADMatr[2];
end; // procedure N_CalcLaplasMatr




Initialization
  N_AddStrToFile( 'N_Gra3 Initialization' );

end.
