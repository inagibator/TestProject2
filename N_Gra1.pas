unit N_Gra1;
// low level Graphic (Points, Lines, Rects) coordinates objects types
//   and numerical pocedures (without any drawing and colors)
//   All integer rects are bottom-right edges Inclusive.
//
// Interface section uses only N_Types, N_Lib1 and Delphi units
// Implementation section uses only Delphi units

interface
uses // should not use any own units except Lib1; later move all needed functions to N_Lib0
     Windows, Classes, Controls, Comctrls, StdCtrls, Forms, Types,
     N_Types, N_Lib1;

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_LineEndPos
type TN_LineEndPos = record  // Used in N_ClipDContour, N_ClipRing for sorting
             // crosspoints of DLine and DClipRect border along the border
    Distance: double; // distance along the border (clockwise) from upper left 
                      // corner
    LineInd: integer; // line Index in List of OutDLines (in N_ClipDLine)
    Flags:   integer; // line End type:
                      //#F
                      // bits0-3 ($00F) =$01 - from Outside to Inside
                      //                =$02 - from Inside to Outside
                      // bits4-7 ($0F0) =$10 - beg of line
                      //                =$20 - end of line
                      // bits8-11($0F00) =$100 - upper left  corner
                      //                 =$200 - upper right corner
                      //                 =$300 - lower right corner
                      //                 =$400 - lower left  corner
                      //#/F
end; //*** end of type TN_LineEndPos = record
type TN_LEPArray = array of TN_LineEndPos; // dynamic Array of TN_LineEndPos
type TN_PLineEndPos  = ^TN_LineEndPos;     // pointer to TN_LineEndPos

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_SegmLine
type TN_SegmLine = record // Segment's end points and it's line coefficients.
  P1, P2: TDPoint; // segment's end points
  A, B, C: double; // segment's line coefficients: A*x + B*y + C = 0
end; // type TN_SegmLine = record
type TN_SegmLineItems = array of TN_SegmLine;

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_CrossPointPar
type TN_CrossPointPar = record // Cross Point params
  Ind1, Ind2: integer; // crossed segments indexes
  Flags: integer;      // crosspoint type
  CP: TDPoint;         // crosspoint coordinates
end; // type TN_CrossPointPar = record
type TN_CrossPoints = array of TN_CrossPointPar;

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_VertexRef
type TN_VertexRef = record // Reference to Vertex of some Item of TN_UBaseCLayer
  ItemInd: integer; // item index
  PartInd: integer; // item's Part index (=0 for single partItems)
  VertInd: integer; // part's relative Vertex index
  CCInd:   integer; // vertex index in LF(D)Coordinates array
  VFlags:  integer; // vertex flags:
                    //#F
                    // =0 - first Vertex in Part
                    // =1 - not first or last Vertex in Part
                    // =2 - last Vertex in Part
                    //#/F
end; // type TN_VertexRef = record
type TN_VertexRefs = array of TN_VertexRef;

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_PointPosType
type TN_PointPosType = ( // Point position relative to Polygon
  pptInside,   // strictly inside polygon
  pptOnBorder, // strictly on polygon border
  pptOutside   // strictly outside polygon
);

function  N_Get0360Angle  ( AAngle: double ): double;

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_IRects
type TN_IRects = class(TObject) // Integer Rectangles List
  public
    NumRects: integer;   // number of Integer Rectangles in IRects array
    IRects: TN_IRArray;  // Array of Integer Rectangles
//##/*
    constructor Create;
    destructor  Destroy; override;
//##*/
    procedure AddOneRect        ( ARect: TRect );
    procedure SubtractOneRect   ( ARect: TRect );
    procedure AddRectArray      ( RectArray: TN_IRects );
    procedure SubtractRectArray ( RectArray: TN_IRects );
end; // type TN_IRects = class(TObject)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_RectLinesLists
//******************************************************* TN_RectLinesLists ***
// Object designed for splitting list of any polylines to polylines inside one 
// of matrix of rectangles.
//
// Used to speed up finding line crossings. (Only lines inside each rect should 
// be checked for finding crossings)
//
type TN_RectLinesLists = class(TObject)
  public
    EnvRect: TDRect;     // envelope Rectangle of all Rectangles
    NumRectX: integer;   // number of rectangles in X direction
    NumRectY: integer;   // number of rectangles in Y direction
    RectDX: double;      // all rectangles Width
    RectDY: double;      // all rectangles Height
    DeltaSize: integer;  // minimal value, by which array size is incremented
    MaxSegmInd: integer; // =$FF if SegmInd <= 255
    MaxLineInd: integer; // =$FFFFFF if SegmInd <= 255
    SegmIndBits: integer;   // MaxSegmInd <= (2**SegmIndBits - 1)
    LinesLists: TN_AIArray; // Lines List for each Rectangle (ordered by 
                            // Rectangle rows)
    NotEmptyRectsRatio: double; // =0 - all Rectangles empty; =1.0 - all filled
    LinesListsSize: integer; // whole number of elements in all LinesLists
    AverageListSize: double; // LinesListsSize / (number of filled Rects)
    MaxListSize: integer;    // maximal ListSize for some Rectangle
    NumComparisons: integer; // needed number of comparisons (pairs of Segments)
    NumSegments: integer;    // whole number of segments

    constructor Create ( const AEnvRect: TDRect; const ANumX, ANumY: integer );
//##/*
    destructor  Destroy; override;
//##*/
    procedure AddLineSegmInd ( ARectInd, ALineSegmInd: integer );
    procedure AddLineSegment ( const ADPoint1, ADPoint2: TDPoint;
                               const ALineInd, ASegmInd: integer );
    procedure CollectStatistics ();
end; // type TN_RectLinesLists = class(TObject)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_GeoProjPar
type TN_GeoProjPar = class(TObject) // Geo Projections Parameters
    private
  C, Q: double;         // Geo Projections coefficients for all projections
  function S  ( B: double): double;
  function N  ( B: double): double;
  function RP ( B: double): double;
  function U  ( B: double): double;

    public
  Scale: double;       // scale in thousands (Scale=10 means 1 : 10 000)
  BS,B1,B2,BN: double; // South, Main1, Main2 and North rectangle's latitudes ( 
                       // 0 < BS < B1 < B2 < BN )
  LW,L0,LE: double;    // West, Middle and East rectangle's meridians (LW<L0<LE)
  MRec: TDRect;        // metrical rectangle's coordinates in millimeters
  Alfa: double;   // Geo Projections coefficients for conical1,2 projections 
                  // and, if Alfa == N_NotADouble  means, that Alfa, C,Q 
                  // coefficients are not calculated
  GPType: integer; // Geo Projection Type :
                   //#F
                   // =1 - normal conical 1 (нормальна€ коническа€ равнопромежуточна€)
                   // =2 - normal conical 2 (нормальна€ коническа€ равноугольна€)
                   // =3 - normal cylindrical Mercator (нормальна€ цилиндрическа€ ћеркатора)
                   //#/F

//##/*
  constructor Create ();
//##*/
  procedure ConvertLine( const InpCoords: TN_DPArray;
                             var OutCoords: TN_DPArray; ConvMode: integer );
end; // type TN_GeoProjPar = class(TObject)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_LineInfo
type TN_LineInfo = class( TObject ) // Object for collecting statistics about lines
    public
//##/*
  ModeFlags: integer; // temporary not used
//##*/

  SumItems:     integer;  // whole number of Items
  SumMPItems:   integer;  // whole number of MultiPart Items
  SumNumParts:  integer;  // sum of Parts number in all Items
  AvrNumParts:  double;   // average Parts number in Item
  MaxNumParts:  integer;  // maximal Parts number in Item

  WNumLines:    integer;  // whole number of Lines (Item Parts)
  WNumClosed:   integer;  // whole number of Closed Lines
  WNumNZSegms:  integer;  // whole number of Not Zero Segments
  WNumZSegms:   integer;  // whole number of Zero Segments

  SumNumPoints: integer;  // sum of Points number in all lines
  MinNumPoints: integer;  // minimal Points number in Line
  AvrNumPoints: double;   // Average Points number in Line
  MaxNumPoints: integer;  // maximal Points number in Line

  SumSegmSize: double;  // sum of Segment Sizes in all lines
  MinSegmSize: double;  // minimal Segment Size
  AvrSegmSize: double;  // average Segment Size
  MaxSegmSize: double;  // maximal    Segment Size

  MinEnvRectSize: double;  // minimal Envelope Rectangle Size
  AvrEnvRectSize: double;  // average Envelope Rectangle Size
  MaxEnvRectSize: double;  // maximal Envelope Rectangle Size

  NumPointsRanges:   TN_FArray; // number of Points Ranges
  SegmSizeRanges:    TN_FArray; // Segment Size Ranges
  EnvRectSizeRanges: TN_FArray; // Envelope Rectangle Size Ranges

//  MinRegCode: integer;  // Min Region Code
//  MaxRegCode: integer;  // Max Region Code

//  MinItemCode: integer; // Min Item Code
//  MaxItemCode: integer; // Max Item Code

  procedure Clear ();
  procedure CollectInfo   ( DLine: TN_DPArray );
  procedure SetRanges     ( NumPRanges, SegmSRanges, EnvSRanges: integer );
  procedure ConvToStrings ( ASL: TStrings; AMode: integer );
end; // type TN_LineInfo = class( TObject )

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_CurveCoords
//********************************************************** TN_CurveCoords ***
// Object for calculating curve coordinates by given polyline coordinates (for 
// smoothing polyline)
//
type TN_CurveCoords = class( TObject )
  CurveType: integer;
  PBasePoints: PDPoint;
  NumPoints: integer;
  LSLengths: TN_DArray;
  LastInd: integer;
  LastQ: double;
  LastAlpha: double;

  procedure Init ( ACurveType: integer; APBasePoints: PDPoint; ANumPoints: integer );
  procedure GetPointInfo ( AQ: double );
  procedure CalcCurve    ( QBeg, QEnd: double; ANumPoints: integer;
                                 var DCoords: TN_DPArray; var DAngles: TN_DArray );
end; // TN_CurveCoords = class( TObject )

type TN_DPProcObj   = procedure( UPoint: TDPoint ) of object;
type TN_2DPAProcObj = procedure( ASrcDC: TN_DPArray; var ADstDC: TN_DPArray ) of object;

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ArcBorderType
type TN_ArcBorderType = ( // Arc type for creating proper polyline coordinates
  abtArcOnly,   // coordinates of Arc (without pie radiuses or chord segment)
  abtChord,     // coordinates of Arc as chord (Arc itself and chord segment)
  abtPieSegment // coordinates of Arc as pie segment (Arc itself and two 
                // radiuses)
); // end type TN_ArcBorderType

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_BFCType
//************************************************************** TN_BFCType ***
// Path fragment type used in TN_BufFCoords record (in TN_ShapeCoords class)
//
type TN_BFCType = (
  bfctEmpty,        // empty buffer
  bfctPolyLine,     // polyline
  bfctPolyBezier,   // Bezier polyline
  bfctPolyDraw,     // PolyDraw
  bfctCloseFigure,  // Shape fragment is Closed
  bfctArc,          // arc with any direction
  bfctArcCW,        // Clockwise arc
  bfctArcCounterCW, // CounterClockwise arc
  bfctEllipse,      // ellipse
  bfctRoundRect     // rectangle with rounded corners
); // end type TN_BFCType

//##/*
type TN_BFPrepMode = (
  bfpmAuto,
  bfpmNewBuf,
  bfpmCurBuf
); // type TN_BFPrepMode
//##*/
// see TN_ShapeCoords class

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_BufFCoords
//*********************************************************** TN_BufFCoords ***
// Path fragment, element of SCBufs field in TN_ShapeCoords class
//
// (Float Coordinates and Number of Points)
//
type TN_BufFCoords = record //
  BFC: TN_FPArray;     // buffer for Float Points
  BFCFlags: TN_BArray; // buffer for WinGDI Point Flags (syncro to BFC, for 
                       // bfctPolyDraw only)
  BFCLength: integer;  // number of points in BFC ( <= Length(BFC) )
  BFCType: TN_BFCType; // buffer coordinates Type
end; // type TN_BufFCoords = record
type TN_BFCArray = array of TN_BufFCoords;

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords
type TN_ShapeCoords = class( TObject ) // Float Shape Coordinates with Flags
  SCBufs:   TN_BFCArray; // float Points buffers
  SCBFreeInd:   integer; // free Index in SCBufs Array (number of elements in 
                         // SCBufs)
  SCIPoints: TN_IPArray; // work Integer Points Array for drawing by WinGDI
  SCIFlags:  TN_BArray;  // work Points Flags Array for drawing by WinGDI
  SCNumIPoints: integer; // number of points in SCIPoints, SCIFlags
  SCBegInd:     integer; // index in BFC Array after call to PrepBuf
  SCNewPenPos:  boolean; // next fragment should begin with PT_Move or MoveToEx
  SCCurBuf:     boolean; // if True, Add procedure add to Current Buffer, 
                         // otherwise - to New Buffer

  constructor Create (  ANumBufs: integer = 3 );
  destructor  Destroy; override;

  procedure Clear    ( AbegInd: integer = 0 );
  procedure SetMinBufs ( AMinBufs: integer );
  function  PrepBuf  ( ANumPoints: integer; ABFCType: TN_BFCType ): integer;
  procedure PrepWinGDIPath ( AHDC: HDC; const AShiftSize: TFPoint );
  procedure CloseShape     ();

  procedure AddOnePoint       ( const AFPoint: TFPoint );
  procedure AddOneSegm        ( const AP1, AP2: TPoint );
  procedure AddSeparateSegm   ( const AP1, AP2: TPoint );
  procedure AddUserSepSegm    ( const ADP1, ADP2: TDPoint; APAffCoefs4: TN_PAffCoefs4 );
  procedure AddPixPolyLine    ( APPoint:  PIPoint;  ANumPoints: integer ); overload;
  procedure AddPixPolyLine    ( APFPoint: PFPoint; ANumPoints: integer ); overload;
  procedure AddPixPolyLine    ( APDPoint: PDPoint; ANumPoints: integer ); overload;
  procedure AddPixPolyDraw    ( APPoint: PPoint; APFlags: PByte;
                                                          ANumPoints: integer );
  procedure AddUserPolyLine   ( APFPoint: PFPoint; ANumPoints: integer; APAffCoefs4: TN_PAffCoefs4 ); overload;
  procedure AddUserPolyLine   ( APDPoint: PDPoint; ANumPoints: integer; APAffCoefs4: TN_PAffCoefs4 ); overload;
  procedure AddUserPolyLine   ( APDPoint: PDPoint; ANumPoints: integer; APAffCoefs6: TN_PAffCoefs6 ); overload;
  procedure AddPixPolyBezier  ( APFPoint: PFPoint; ANumPoints: integer ); overload;
  procedure AddPixPolyBezier  ( APDPoint: PDPoint; ANumPoints: integer ); overload;
  procedure AddUserPolyBezier ( APFPoint: PFPoint; ANumPoints: integer; APAffCoefs4: TN_PAffCoefs4 ); overload;
  procedure AddUserPolyBezier ( APDPoint: PDPoint; ANumPoints: integer; APAffCoefs4: TN_PAffCoefs4 ); overload;

  procedure AddEllipse         ( const AEnvRect: TFRect );
  procedure AddEllipseNative   ( const AEnvRect: TFRect );
  procedure AddRoundRect       ( const AEnvRect: TFRect; const ARoundEllSize: TFPoint );
  procedure AddRoundRectNative ( const AEnvRect: TFRect; const ARoundEllSize: TFPoint );
  procedure AddArc             ( const AEnvRect: TFRect; ABegAngle, AArcAngle: float );
  procedure AddArcNative       ( const AEnvRect: TFRect; ABegAngle, AArcAngle: float );
  procedure AddRegPolyFragm  ( const AEnvRect: TFRect; AShapeType: TN_ArcBorderType;
                               ABegAngle, AArcAngle: float; ANumSegments: integer );
  procedure AddEllipseFragm  ( const AEnvRect: TFRect; AShapeType: TN_ArcBorderType;
                               ABegAngle, AArcAngle: float );
  procedure AddCilinderFragm ( const AEnvRect: TFRect;
                               ABegAngle, AArcAngle: float; AVSHeight: float );
//  procedure AddSmallArc ( const ACenter, ARad: TFPoint; ABegAngle, AArcAngle: float );
//  procedure AddArc      ( const ACenter, ARad: TFPoint; ABegAngle, AArcAngle: float );
end; // type TN_ShapeCoords = class( TObject )

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_LPointPos
type TN_LPointPos = record // Point position on Polyline
  LPPInd:  integer; // segment (begin segment point) index
  LPPDelta: double; // Point position inside Segment (0-SegmBegPoint, 1 - 
                    // SegmEndPoint)
  LPPFC:   TFPoint; // Float Point X,Y Coordinates
end; // type TN_FPointPos = record

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_MatrDescr
type TN_MatrDescr = record // Matrix Description
  MDPBeg: TN_BytesPtr; // Pointer to Beg of Matrix (Matrix initial element)
  MDNumX:   integer; // Number of Elements in one Row
  MDNumY:   integer; // Number of Elements in one Column
  MDElSize: integer; // Matrix Element Size in Bytes (from 1 to 4 or 8)
  MDStepX:  integer; // Step in Bytes Along X Axis (between Columns or 
                     // heighboure elems in Row)
  MDStepY:  integer; // Step in Bytes Along Y Axis (between Rows or heighboure 
                     // elems in Column)
  MDBegIX:  integer; // Initial Submatr index along X Axis
  MDEndIX:  integer; // Final Submatr index along X Axis
  MDBegIY:  integer; // Initial Submatr index along Y Axis
  MDEndIY:  integer; // Final Submatr index along Y Axis
end; // type TN_MatrDescr = record

//******************** Global Procedures and Functions ***********************

function N_SegmPoint ( const AP1, AP2: TFPoint; Alpha: double ): TFPoint; overload;
function N_SegmPoint ( const AP1, AP2: TDPoint; Alpha: double ): TDPoint; overload;

function N_SegmAngle ( const AP1, AP2: TFPoint ): double; overload;
function N_SegmAngle ( const AP1, AP2: TDPoint ): double; overload;
function N_SegmAngle ( const AP1, AP2, AP3: TDPoint ): double; overload;
//

function  D3PReper ( const ADX1, ADY1, ADX2, ADY2, ADX3, ADY3: double ): TN_3DPReper; overload;
function  D3PReper ( const ARect: TRect ):  TN_3DPReper; overload;
function  D3PReper ( const AFRect: TFRect ): TN_3DPReper; overload;
function  D3PReper ( const ADRect: TDRect ): TN_3DPReper; overload;
procedure N_Conv3DPReperTo3PReper ( AP3DPReper: TN_P3DPReper; AP3PReper: TN_P3PReper );

function  N_Add2P    ( const APoint1,  APoint2:  TPoint  ): TPoint;  overload;
function  N_Add2P    ( const AFPoint1, AFPoint2: TFPoint ): TFPoint; overload;
function  N_Add2P    ( const ADPoint1, ADPoint2: TDPoint ): TDPoint; overload;

function  N_Substr2P ( const APoint1,  APoint2:  TPoint  ): TPoint;  overload;
function  N_Substr2P ( const AFPoint1, AFPoint2: TFPoint ): TFPoint; overload;
function  N_Substr2P ( const ADPoint1, ADPoint2: TDPoint ): TDPoint; overload;

function  N_CSA ( AColor: integer; AFSize: float  ): TN_ColorSizeAttr;

function  N_Same( const APoint1, APoint2: TPoint  ): boolean; overload;
function  N_Same( const AFPoint1, AFPoint2: TFPoint ): boolean; overload;
function  N_Same( const ADPoint1, ADPoint2: TDPoint ): boolean; overload;
function  N_Same( const ARect1, ARect2: TRect  ): boolean; overload;
function  N_Same( const AFRect1, AFRect2: TFRect ): boolean; overload;
function  N_Same( const ADRect1, ADRect2: TDRect ): boolean; overload;
function  N_Same( const APFPoint1, APFPoint2: PFPoint ):  boolean; overload;


function  N_Same( const FArray1: TN_FPArray; FPInd1, NumInds1: integer;
                  const FArray2: TN_FPArray; FPInd2, NumInds2: integer ): boolean; overload;
function  N_Same( const DArray1: TN_DPArray; FPInd1, NumInds1: integer;
                  const DArray2: TN_DPArray; FPInd2, NumInds2: integer ): boolean; overload;

function  N_RectChangeCoords1 ( const ARect, ADeltaRect: TRect ): TRect;
function  N_RectWidth  ( const ARect: TRect ): integer; overload;
function  N_RectWidth  ( const AFRect: TFRect ): double; overload;
function  N_RectHeight ( const ARect: TRect ): integer; overload;
function  N_RectHeight ( const AFRect: TFRect ): double; overload;
function  N_RectSize   ( const ARect: TRect ):  TPoint;  overload;
function  N_RectSize   ( const AFRect: TFRect ): TDPoint; overload;
function  N_RectSize   ( const ADRect: TDRect ): TDPoint; overload;
function  N_RectSizeM1 ( const ARect: TRect ): TPoint;
function  N_RectCenter ( const ARect: TRect ): TPoint;   overload;
function  N_RectCenter ( const AFRect: TFRect ): TDPoint; overload;
function  N_RectNormCoords ( const ADAbsPoint:  TDPoint; const ARect: TRect ): TDPoint;
function  N_RectAbsCoords  ( const ADNormPoint: TDPoint; const ARect: TRect ): TDPoint;
function  N_RectAspect ( const ARect: TRect  ): double; overload;
function  N_RectAspect ( const ARect: TFRect ): double; overload;
function  N_RectAspect ( const ARect: TDRect ): double; overload;
function  N_RectMaxCoord ( const ARect: TRect ): integer; overload;
function  N_RectMaxCoord ( const AFRect: TFRect ): float;  overload;
function  N_RectMaxCoord ( const ADRect: TDRect ): double; overload;
function  N_RectShift  ( const ARect: TRect; AShiftX, AShiftY: integer ): TRect; overload;
function  N_RectShift  ( const ARect: TRect; AShiftXY: TPoint ): TRect; overload;
function  N_RectShift  ( const AFRect: TFRect; ADShiftX, ADShiftY: double ): TFRect; overload;
function  N_RectShift  ( const AFRect: TFRect; AFShiftXY: TFPoint ): TFRect; overload;
function  N_RectShift4 ( const ARect: TRect; AFlags, AShiftX, AShiftY: integer ): TRect;
function  N_RectCalc   ( const ARect: TRect; AWidth, AHeight: integer ): TRect;

function  N_RectAdjustByMaxRect ( const ARect,  AMaxRect:  TRect ):  TRect;  overload;
function  N_RectAdjustByMaxRect ( const AFRect, AFMaxRect: TFRect ): TFRect; overload;

function  N_RectAdjustByMinRect ( const ARect, AMinRect: TRect ):  TRect; overload;
function  N_RectAdjustByMinRect ( const AFRect: TFRect; const AMinRect: TRect ): TFRect; overload;
procedure N_CalcRectSizePos     ( const AInpSize, AInpPos: TPoint; AFlags: TN_RectSizePosFlags;
                                    out AOutSize, AOutPos: TPoint );

function  N_RectIncr  ( const ARect: TRect;  AShiftX, AShiftY: integer ): TRect;
function  N_RectMake  ( const ATopLeft: TPoint; AWidth, AHeight: integer ): TRect; overload;
function  N_RectMake  ( const APoint: TPoint;  const AXYSize: TPoint; const ADPointPos: TDPoint ): TRect; overload;
function  N_RectMake  ( const ADPoint: TDPoint; const AXYSize: TPoint; const ADPointPos: TDPoint ): TRect; overload;
function  N_RectMake  ( const ADPoint, ADXYSize, ADPointPos: TDPoint ): TFRect; overload;
function  N_RectMakeD ( const ADPoint, ADXYSize, ADPointPos: TDPoint ): TDRect;

function  N_RectCheckPos ( const ARect1, ARect2: TRect  ): integer; overload;
function  N_RectCheckPos ( const AFRect1, AFRect2: TFRect ): integer; overload;
function  N_RectCheckPos ( const ADRect1, ADRect2: TDRect ): integer; overload;

function  N_RectCheckCross ( const ARect1, ARect2: TRect ): integer;

function  N_RectSetPos ( AMode: integer; const AMaxRect, AFixedRect: TRect;
                                              AWidth, AHeight: integer ): TRect;
function  N_RectScaleA ( const ARect: TRect; const Coef: double;
                                 const AbsFixedPoint: TPoint ): TRect; overload;
function  N_RectScaleA ( const AFRect: TFRect; const Coef: double;
                              const AbsFixedDPoint: TDPoint ): TFRect; overload;
function  N_RectScaleA ( const ADRect: TDRect; const Coef: double;
                              const AbsFixedDPoint: TDPoint ): TDRect; overload;
function  N_RectScaleR ( const ARect: TRect; const Coef: double;
                               const RelFixedDPoint: TDPoint ): TRect; overload;
function  N_RectScaleR ( const AFRect: TFRect; const Coef: double;
                               const RelFixedPoint: TDPoint ): TFRect; overload;
function  N_RectRoundInc ( const AFRect: TFRect; ANumDigits: integer ): TFRect;
function  N_RectOrder    ( const ARect: TRect  ): integer; overload;
function  N_RectOrder    ( const AFRect: TFRect ): integer; overload;
function  N_GetAbsRect   ( const ASrcRect, AFullRect: TRect ): TRect;

function  N_I2DPoint ( const IPoint: TPoint ): TDPoint;
function  N_D2IPoint ( const DPoint: TDPoint ): TPoint;
function  N_I2FRect1 ( const IRect:  TRect ): TFRect;
function  N_I2FRect2 ( const IRect:  TRect ): TFRect;
function  N_F2IRect1 ( const FRect:  TFRect ): TRect;
function  N_F2IRect2 ( const FRect:  TFRect ): TRect;

function  N_AffCoefs4     ( const ACX, ACY, ASX, ASY: double ): TN_AffCoefs4;
function  N_CalcAffCoefs4 ( const ASrcRect, ADstRect:  TRect ): TN_AffCoefs4; overload;
function  N_CalcAffCoefs4 ( const ASrcFRect, ADstFRect: TFRect ): TN_AffCoefs4; overload;
function  N_CalcAffCoefs4 ( const ASrcDRect, ADstDRect: TDRect ): TN_AffCoefs4; overload;
function  N_ComposeAffCoefs4 ( AAffCoefs1, AAffCoefs2: TN_AffCoefs4 ): TN_AffCoefs4;
procedure N_CalcAffCoefs4RS  ( const AURect: TFRect; const ARSFactor: double;
               const ASrcWidth, ASrcHeight: integer; var P2U, U2P: TN_AffCoefs4 );

function  N_CalcAffCoefs6 ( const AInpReper, AOutReper: TN_3DPReper ): TN_AffCoefs6; overload;
procedure N_CalcAffCoefs6 ( ACTransfType: TN_CTransfType; const AOutRect: TRect; const APXForm: PXForm; const APInpRect: PRect ); overload;
procedure N_CalcAffCoefs6 ( AFlags: integer; var AffCoefs6: TN_AffCoefs6; APParams: PDouble ); overload;
procedure N_CalcAffCoefs6 ( AParamsStr: string; var AffCoefs6: TN_AffCoefs6 ); overload;
function  N_ComposeAffCoefs6 ( AAffCoefs1, AAffCoefs2: TN_AffCoefs6 ): TN_AffCoefs6;
function  N_ConvToXForm   ( const AAffCoefs6: TN_AffCoefs6 ): TXForm;

procedure N_AffConv6Points    ( APInpX, APInpY: PDouble; APOutPoints: PFPoint; ANumPoints: integer; const AAffCoefs6: TN_AffCoefs6 );
procedure N_AffConv6D2DPoints ( APInpPoints, APOutPoints: PDPoint; ANumPoints: integer;  const AAffCoefs6: TN_AffCoefs6 ); overload;
procedure N_AffConv6D2DPoints ( APInpX, APInpY, APOutX, APOutY: Pointer; AStepInpX, AStepInpY, AStepOutX, AStepOutY: integer; ANumPoints: integer; const AAffCoefs6: TN_AffCoefs6 ); overload;
procedure N_AffConv6D2DPoints ( APInpX, APInpY: Pointer; var ADPArray: TN_DPArray; ANumPoints: integer; const AAffCoefs6: TN_AffCoefs6 ); overload;
function  N_AffConv6D2DScalar ( const Ascalar: double; const AAffCoefs6: TN_AffCoefs6 ): TDPoint;
function  N_AffConv6D2DPoint  ( const AX, AY: double;  const AAffCoefs6: TN_AffCoefs6 ): TDPoint;
function  N_AffConv6D2FPoint  ( const ADPoint: TDPoint; const AAffCoefs6: TN_AffCoefs6 ): TFPoint;
function  N_AffConv6D2IRect   ( const ADRect: TDRect; const AAffCoefs6: TN_AffCoefs6 ): TRect;
function  N_AffConv6D2DRect   ( const ADRect: TDRect; const AAffCoefs6: TN_AffCoefs6 ): TDRect;

procedure N_AffConv8D2DPoints ( APInpPoints, APOutPoints: PDPoint; ANumPoints: integer;  const AAffCoefs8: TN_AffCoefs8 ); overload;
procedure N_AffConv8D2DPoints ( APInpX, APInpY, APOutX, APOutY: Pointer; AStepInpX, AStepInpY, AStepOutX, AStepOutY: integer; ANumPoints: integer; const AAffCoefs8: TN_AffCoefs8 ); overload;
procedure N_AffConv8D2DPoints ( APInpX, APInpY: Pointer; var ADPArray: TN_DPArray; ANumPoints: integer; const AAffCoefs8: TN_AffCoefs8 ); overload;
function  N_AffConv8D2DScalar ( const Ascalar: double; const AAffCoefs8: TN_AffCoefs8 ): TDPoint;
function  N_AffConv8D2DPoint  ( const AX, AY: double; const AAffCoefs8: TN_AffCoefs8 ): TDPoint; overload;
function  N_AffConv8D2DPoint  ( const ADPoint: TDPoint; const AAffCoefs8: TN_AffCoefs8 ): TDPoint; overload;
function  N_AffConv8D2IRect   ( const ADRect: TDRect; const AAffCoefs8: TN_AffCoefs8 ): TRect;
function  N_AffCoefs8 ( const ACXX, ACXY, ASX, AWX, ACYX, ACYY, ASY, AWY: double ): TN_AffCoefs8; overload;
function  N_AffCoefs8 ( const AAffCoefs4: TN_AffCoefs4 ): TN_AffCoefs8; overload;
function  N_AffCoefs8 ( const AAffCoefs6: TN_AffCoefs6 ): TN_AffCoefs8; overload;
function  N_ComposeAffCoefs8 ( AAffCoefs1, AAffCoefs2: TN_AffCoefs8 ): TN_AffCoefs8;

function  N_AffConvI2FPoint( const APoint: TPoint;  const AAffCoefs4: TN_AffCoefs4): TFPoint;
function  N_AffConvI2DPoint( const APoint: TPoint;  const AAffCoefs4: TN_AffCoefs4): TDPoint;
function  N_AffConvD2IPoint( const ADPoint: TDPoint; const AAffCoefs4: TN_AffCoefs4): TPoint;
function  N_AffConvF2IPoint( const AFPoint: TFPoint; const AAffCoefs4: TN_AffCoefs4): TPoint;
function  N_AffConvF2DPoint( const AFPoint: TFPoint; const AAffCoefs4: TN_AffCoefs4): TDPoint;
function  N_AffConvD2DPoint( const ADPoint: TDPoint; const AAffCoefs4: TN_AffCoefs4): TDPoint;
function  N_AffConvF2FPoint( const AFPoint: TFPoint; const AAffCoefs4: TN_AffCoefs4): TFPoint;

function  N_AffConvF2IRect ( const AFRect: TFRect; const AAffCoefs4: TN_AffCoefs4): TRect;
function  N_AffConvI2FRect1( const ARect: TRect;  const AAffCoefs4: TN_AffCoefs4): TFRect;
function  N_AffConvI2FRect2( const ARect: TRect;  const AAffCoefs4: TN_AffCoefs4): TFRect;
function  N_AffConvF2FRect ( const AFRect: TFRect; const AAffCoefs4: TN_AffCoefs4): TFRect;
function  N_AffConvI2IRect ( const ARect: TRect;  const AAffCoefs4: TN_AffCoefs4): TRect;

procedure N_AffConv4F2IPoints( APInpPoints: PFPoint; APOutPoints: PPoint; ANumPoints: integer; const AAffCoefs4: TN_AffCoefs4 );
procedure N_AffConv4F2FPoints( APInpPoints: PFPoint; APOutPoints: PFPoint; ANumPoints: integer; const AAffCoefs4: TN_AffCoefs4 );
procedure N_FCoordsToDCoords( APSrcFPoints: PFPoint; APDstDPoints: PDPoint; ANumPoints: integer ); overload;
procedure N_DCoordsToFCoords( APSrcDPoints: PDPoint; APDstFPoints: PFPoint; ANumPoints: integer ); overload;
procedure N_FCoordsToDCoords ( const FCoords: TN_FPArray; var DCoords: TN_DPArray ); overload;
procedure N_FCoordsToDCoords ( const ASrcFPoints: TN_FPArray; ASrcInd: integer; var ADstDPoints: TN_DPArray; ADstInd, ANumInds: integer ); overload;
procedure N_DCoordsToFCoords ( const ASrcDPoints: TN_DPArray; var ADstFPoints: TN_FPArray ); overload;
procedure N_DCoordsToFCoords ( const ASrcDPoints: TN_DPArray; ASrcInd: integer; var ADstFPoints: TN_FPArray; ADstInd, ANumInds: integer ); overload;

function  N_PointInRect( const APoint: TPoint;  const ARect: TRect ): integer; overload;
function  N_PointInRect( const AFPoint: TFPoint; const AFRect: TFRect ): integer; overload;
function  N_PointInRect( const ADPoint: TDPoint; const AFRect: TFRect ): integer; overload;

function  N_IPointNearIRect( const APoint:TPoint; const ARect:TRect; const ADelta:integer ): integer;
function  N_PointNearFRect( const AFPoint:TFPoint; const AFRect:TFRect; const ADDelta:double ): integer; overload;
function  N_PointNearFRect( const ADPoint:TDPoint; const AFRect:TFRect; const ADDelta:double ): integer; overload;

function N_LineCrossesFRect( const AFPLine: TN_FPArray; AFPInd, ANumInds: integer; const AFRect: TFRect; out ASegmInd: integer ): boolean; overload;
function N_LineCrossesFRect( const ADPLine: TN_DPArray; AFPInd, ANumInds: integer; const AFRect: TFRect; out ASegmInd: integer ): boolean; overload;

function N_RectOverLine( const AFPLine: TN_FPArray; AFPInd, ANumInds: integer; const AFRect: TFRect; ASearchFlags: integer; out ASegmInd, AVertInd: integer ): boolean; overload;
function N_RectOverLine( const ADPLine: TN_DPArray; AFPInd, ANumInds: integer; const AFRect: TFRect; ASearchFlags: integer; out ASegmInd, AVertInd: integer ): boolean; overload;

function  N_CalcLineEnvRect ( const APLine: TN_IPArray; ANumPoints: integer ): TRect; overload;
function  N_CalcLineEnvRect ( const AFPLine: TN_FPArray; AFPInd, ANumInds: integer ): TFRect; overload;
function  N_CalcLineEnvRect ( const ADPLine: TN_DPArray; AFPInd, ANumInds: integer ): TFRect; overload;
function  N_CalcFLineEnvRect ( APFPoints: PFPoint; ANumPoints: integer ): TFRect;
function  N_CalcDLineEnvRect ( APDPoints: PDPoint; ANumPoints: integer ): TFRect;
function  N_CalcRectEps  ( const AFRect: TFRect ): double; overload;
function  N_CalcRectEps  ( const ADRect: TDRect ): double; overload;
function  N_DPointInsideFRing( APFRCoords: PFPoint; ANumPoints: integer; const AFRingEnv: TFRect; const ADPoint: TDPoint; APSegmInd: PInteger = nil ): integer;
function  N_DPointInsideDRing( APDRCoords: PDPoint; ANumPoints: integer; const AFRingEnv: TFRect; const ADPoint: TDPoint; APSegmInd: PInteger = nil ): integer;
function  N_AdjustIRect ( var ARect: TRect; const AMaxRect: TRect; const AMinSize: integer; const AAspect: double ): integer;
function  N_AdjustFRect ( var AFRect: TFRect; const AMaxFRect: TFRect; const AMinSize, AAspect: double ): integer;
function  N_ChangeFRect ( var ARect: TFRect; const DPointPar: TDPoint; const  Mode: integer ): TFRect;
procedure N_AffConvCoords ( const AAffCoefs4: TN_AffCoefs4; const ASrcFPoints: TN_FPArray; var ADstFPoints: TN_FPArray ); overload;
procedure N_AffConvCoords ( const AAffCoefs4: TN_AffCoefs4; const ASrcFPoints: TN_FPArray; var ADstDPoints: TN_DPArray ); overload;
procedure N_AffConvCoords ( const AAffCoefs4: TN_AffCoefs4; const ASrcDPoints: TN_DPArray; var ADstFPoints: TN_FPArray ); overload;
procedure N_AffConvCoords ( const AAffCoefs4: TN_AffCoefs4; const ASrcDPoints: TN_DPArray; var ADstDPoints: TN_DPArray ); overload;
procedure N_AffConvCoords ( const AAffCoefs6: TN_AffCoefs6; const ASrcDPoints: TN_DPArray; var ADstDPoints: TN_DPArray ); overload;
procedure N_AffConvCoords ( const AAffCoefs8: TN_AffCoefs8; const ASrcDPoints: TN_DPArray; var ADstDPoints: TN_DPArray ); overload;
function  N_FuncConvAffC6 ( const ASrcDP: TDPoint; PParams: Pointer ): TDPoint;

procedure N_ConvDLineToDLine  ( const AffCoefs: TN_AffCoefs4; var InpDline, OutDline: TN_DPArray );
procedure N_ConvDLineToDLine2 ( const AffCoefs: TN_AffCoefs4; var InpDline, OutDline: TN_DPArray; var OutEnvRect: TDRect );
procedure N_ConvDLineToILine  ( const AAffCoefs4: TN_AffCoefs4; const ANPoints: integer; APSrcDPoints: PDPoint; APDstPoints: PPoint );
function  N_ConvDLineToILine2 ( const AAffCoefs4: TN_AffCoefs4; const ANPoints: integer; APSrcDPoints: PDPoint; APDstPoints: PPoint ): integer;
function  N_ConvFLineToILine2 ( const AAffCoefs4: TN_AffCoefs4; const ANPoints: integer; APSrcFPoints: PFPoint; APDstPoints: PPoint ): integer;
function  N_SegmCrossRectBorder1 ( var ACrossFPoint: TFPoint; const AFRect: TFRect; const AFPoint1, AFPoint2: TFPoint ): integer; overload;
function  N_SegmCrossRectBorder1 ( var ACrossDPoint: TDPoint; const AFRect: TFRect; const ADPoint1, ADPoint2: TDPoint ): integer; overload;
function  N_SegmCrossRectBorder2( const AFLine: TN_FPArray; var AInd: integer; const AFRect: TFRect; const AFPoint1: TFPoint; var APos1: integer; const AFPoint2: TFPoint; var APos2: integer ): integer; overload;
function  N_SegmCrossRectBorder2( const ADLine: TN_DPArray; var AInd: integer; const AFRect: TFRect; const ADPoint1: TDPoint; var APos1: integer; const ADPoint2: TDPoint; var APos2: integer ): integer; overload;
function  N_DistAlongRectBorder ( const APos: integer; const AFRect: TFRect; const AFPoint: TFPoint ): double; overload;
function  N_DistAlongRectBorder ( const APos: integer; const AFRect: TFRect; const ADPoint: TDPoint ): double; overload;
function  N_CalcPerpendicular   ( const ADP1, ADP2, ADPRes: TDPoint ): TDPoint;
function  N_CalcCrossPoint      ( const ADP1, ADP2, ADP3, ADP4: TDPoint ): TDPoint;
procedure N_ClipFLine      ( const AClipFRect: TFRect; var ALineEnds: TN_LEPArray; const AInpFLine: TN_FPArray; var ADLA: TN_ADPArray );
procedure N_ClipDLine      ( const AClipFRect: TFRect; var ALineEnds: TN_LEPArray; const AInpDLine: TN_DPArray; var ADLA: TN_ADPArray );
function  N_ClipLineByRect ( const AClipFRect: TFRect; APInpFPoints: PFPoint; ANPoints: integer; var AOutLengths: TN_IArray; var AOutFLines: TN_AFPArray ): integer; overload;
function  N_ClipLineByRect ( const AClipFRect: TFRect; APInpDPoints: PDPoint; ANPoints: integer; var AOutLengths: TN_IArray; var AOutDLines: TN_ADPArray ): integer; overload;
function  N_ClipRingByRect ( const AClipFRect: TFRect; AInpRingDirection: integer; APInpFPoints: PFPoint; ANPoints: integer; var AOutLengths: TN_IArray; var AOutFRings: TN_AFPArray ): integer; overload;
function  N_ClipRingByRect ( const AClipFRect: TFRect; AInpRingDirection: integer; APInpDPoints: PDPoint; ANPoints: integer; var AOutLengths: TN_IArray; var AOutDRings: TN_ADPArray ): integer; overload;
procedure N_ClipRing       ( const ClipDRect: TFRect; InpRingDirection: integer; const InpRing: TN_DPArray; const REnvRect: TFRect; var OutRings: TN_ADPArray );
function  N_CalcRingSquare    ( ARCoords: TN_DPArray ): double;
function  N_CalcRingDirection ( ARCoords: TN_DPArray ): integer;

function  N_IPointToStr ( const APoint: TPoint; AFmt: string = '' ): String;
function  N_TControlToStr ( const AControl: TControl ): String;

function  N_FRectAnd   ( var AFRectRes: TFRect; const AFRectOp: TFRect ): integer;
function  N_FRectOr    ( var AFRectRes: TFRect; const AFRectOp: TFRect ): integer; overload;
function  N_FRectOr    ( var AFRectRes: TFRect; const ADPoint: TDPoint ): integer; overload;
function  N_FRectsCross( const AFRect1, AFRect2: TFRect ): boolean;
function  N_FRectIAffConv2 ( const FRectOp: TFRect; const IRectOp1, IRectOp2: TRect ): TFRect;
function  N_FRectFAffConv2 ( const AAffDstFRect: TFRect; const AAffSrcFRect, ASrcFRect: TFRect ): TFRect;
function  N_FRectOrder  ( const AFRect: TFRect ): TFRect;
function  N_FRectCreate ( const ARect: TFRect; const ANewSize, AHotPoint: TDPoint ): TFRect;
function  N_FRectSize   ( const AFRect: TFRect ): double;

function  N_DRectOrder ( const ADRect: TDRect ): TDRect;
function  N_DRectOr    ( var ADRectRes: TDRect; const ADRectOp: TDRect ): integer;

function  N_ScanIPoint ( var AStr: String ): TPoint;
function  N_ScanFPoint ( var AStr: String ): TFPoint;
function  N_ScanDPoint ( var AStr: String ): TDPoint;

function  N_ScanIRect  ( var AStr: String ): TRect;
function  N_ScanFRect  ( var AStr: String ): TFRect;
function  N_ScanDRect  ( var AStr: String ): TDRect;

function  N_ScanAffCoefs6 ( var AStr: String ): TN_AffCoefs6;
function  N_ScanIntPairs  ( var AStr: String; var APairs: TN_IArray ): integer;
function  N_IsIntInRange  ( AInt, ANumRanges: integer; ARanges: TN_IArray ): boolean;

function  N_SameIPoints ( const APoint1, APoint2: TPoint ): boolean;
function  N_SameIRects  ( const ARect1,  ARect2: TRect )  : boolean;
function  N_SameDPoints ( const ADPoint1,ADPoint2:TDPoint; const AAccuracy: integer ): boolean;
function  N_SameDRects  ( const ADRect1, ADRect2: TDRect; const AAccuracy: integer ): boolean;

function  N_SnapToGrid ( const AGridStep, AValue: float ): float;

function  N_SnapPointToGrid ( const AOrigin, AGridSteps: TDPoint; const AFPoint: TFPoint ): TFPoint; overload;
function  N_SnapPointToGrid ( const AOrigin, AGridSteps: TDPoint; const ADPoint: TDPoint ): TDPoint; overload;

procedure N_SnapDLineToGrid ( const AOrigin, AGridSteps: TDPoint; const AInpDLine: TN_DPArray; var AOutDLine: TN_DPArray );

function  N_CompareDPoints ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_CompareIPoints ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_CompareDPointAndAngle ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_CompareFPointAndInt ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_CompareFRectAndInt  ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_Compare2PFP1Int     ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_Compare2PDP1Int     ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_CompareIDD          ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
function  N_CompareIRectCenters ( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;

procedure N_IncEnvRect ( var AEnvRect: TRect;  const APoint: TPoint ); overload;
procedure N_IncEnvRect ( var AEnvFRect: TFRect; const AFPoint: TFPoint ); overload;
procedure N_IncEnvRect ( var AEnvFRect: TFRect; const ADPoint: TDPoint ); overload;
procedure N_IncEnvRect ( var AEnvDRect: TDRect; const ADPoint: TDPoint ); overload;
procedure N_IncLineEnvRect ( var AEnvFRect: TFRect; const AFCoords: TN_FPArray ); overload;
procedure N_IncLineEnvRect ( var AEnvFRect: TFRect; const ADCoords: TN_DPArray ); overload;

function  N_AdjustSizeByAspect ( AAdjustMode: TN_AdjustAspectMode; const AInpSize: TPoint; const ANeededAspect: double ): TPoint; overload;
function  N_AdjustSizeByAspect ( AAdjustMode: TN_AdjustAspectMode; const AInpSize: TFPoint; const ANeededAspect: double ): TFPoint; overload;
function  N_AdjustSizeByAspect ( AAdjustMode: TN_AdjustAspectMode; const AInpSize: TDPoint; const ANeededAspect: double ): TDPoint; overload;
procedure N_AdjustURectAspByPRect( AAdjustMode: TN_AdjustAspectMode; var AURect: TDRect; const APRect: TRect );
function  N_AdjustSizeByMaxArea  ( ASize: TPoint; AMaxArea: Integer ): TPoint;

function  N_DecRectbyAspect  ( const ARect: TRect;  const ANeededAspect: double ): TRect;
function  N_IncRectbyAspect  ( const ARect: TFRect; const ANeededAspect: double ): TFRect;

procedure N_AdjustRectAspect ( AAdjustMode: TN_AdjustAspectMode; var ARect: TRect; const ANeededAspect: double ); overload;
procedure N_AdjustRectAspect ( AAdjustMode: TN_AdjustAspectMode; var AFRect: TFRect; const ANeededAspect: double ); overload;
procedure N_AdjustRectAspect ( AAdjustMode: TN_AdjustAspectMode; var AWidth, AHeight: integer; const ANeededAspect: double ); overload;
procedure N_CheckSegmentsCrossing1 ( const ASegmLines: TN_SegmLineItems; const AEps: double; var ACrossPoints: TN_CrossPoints );

procedure N_CalcArcCoords  ( var AArcCoords: TN_DPArray; ANPoints: integer; const AOX, AOY, ARX, ARY, ABegAngle, AEndAngle: double );
procedure N_CalcRectCoords ( var ALineCoords: TN_IPArray; const ARect: TRect );

procedure N_SetScrollBarsByRects   ( const AMaxFRect, ACurFRect: TFRect; AHSB, AVSB: TScrollBar ); overload;
procedure N_SetScrollBarsByRects   ( const AMaxRect, ACurRect: TRect; AHSB, AVSB: TScrollBar ); overload;
procedure N_ShiftFRectByScrollBars ( const AMaxFRect: TFRect; var ACurFRect: TFRect; AHSB, AVSB: TScrollBar );
procedure N_ShiftIRectByScrollBars ( const AMaxRect: TRect; var ACurRect: TRect; AHSB, AVSB: TScrollBar );

function  N_Arctan2        ( const ADX, ADY: extended ): extended;
function  N_ScalarProduct2 ( const ADV1, ADV2: TDPoint ): double;
function  N_ScalarProduct3 ( const ADV1, ADP2Beg, ADP2End: TDPoint  ): double;
function  N_ScalarProduct4 ( const ADP1Beg, ADP1End, ADP2Beg, ADP2End: TDPoint ): double;

function  N_P2PDistance    ( const AFP1, AFP2: TFPoint ): double; overload;
function  N_P2PDistance    ( const ADP1, ADP2: TDPoint ): double; overload;

function  N_P2SDistance    ( const AFP, AFPBeg, AFPEnd: TFPoint ): double; overload;
function  N_P2SDistance    ( const ADP, ADPBeg, ADPEnd: TDPoint ): double; overload;

function  N_P2LSDistance   ( const ADP, ADPBeg, ADPEnd: TDPoint ): double;
function  N_P2LDistance    ( const ADP: TDPoint; ALineDCoords: TN_DPArray; const ALineEnvFRect: TFRect; const AMaxDistance: double; out ASegmInd: integer  ): double;

procedure N_AddFcoordsToFCoords ( var AResFCoords: TN_FPArray; const AAddFCoords: TN_FPArray; AOrder: integer );
procedure N_AddDcoordsToDCoords ( var AResDCoords: TN_DPArray; const AAddDCoords: TN_DPArray; AOrder: integer );

procedure N_MakeFRectBorder ( var ALineFCoords: TN_FPArray; ARect: TFRect ); overload;
procedure N_MakeFRectBorder ( var ALineDCoords: TN_DPArray; ARect: TFRect ); overload;
function  N_GetMaxAbsCoord ( AFPCoords: TN_FPArray ): double; overload;
function  N_GetMaxAbsCoord ( ADPCoords: TN_DPArray ): double; overload;
function  N_GetMaxAbsCoord ( AFRCoords: TN_FRArray ): double; overload;
function  N_GetMaxAbsCoord ( ADRCoords: TN_DRArray ): double; overload;

procedure N_LSegmLengths ( ADLine: TN_DPArray; var ALSegmLengths: TN_DArray ); overload;
procedure N_LSegmLengths ( APDPoints: PDPoint; ANumPoints: integer; var ALSegmLengths: TN_DArray ); overload;
function  N_SegmToSegmPDistance  ( AS1B, AS1E, AS2B, AS2E: TDPoint ): double;
function  N_ChordToLinePDistance ( ADLine: TN_DPArray; ALSegmLengths: TN_DArray; ABegInd, AEndInd: integer ): double;
function  N_ChordToLinePNorm     ( ADLine: TN_DPArray; ALSegmLengths: TN_DArray; ABegInd, AEndInd: integer ): double;
function  N_DecNumberOfLinePoints1 ( AInpDLine: TN_DPArray; var AOutDLine: TN_DPArray; ADelta: double ): integer;
function  N_DecNumberOfLinePoints2 ( AInpDLine: TN_DPArray; var AOutDLine: TN_DPArray; ADelta: double ): integer;
function  N_DecNumberOfLinePoints3 ( const AInpDLine: TN_DPArray; var AOutDLine: TN_DPArray; AMode: integer; AMinDelta, AMaxDelta, ADeltaCoef: double ): integer;
procedure N_MinLineSegmsSize ( const ADLine: TN_DPArray; var AMinSegmSize: double; var ANumZeros: integer );
procedure N_AddLineSegmsStat ( const ADLine: TN_DPArray; ANumIntervals: integer; const AMaxSize: double; ANumSegms: TN_IArray );

function  N_PointToStr ( const APoint: TPoint;  AFmt: string = '' ): string; overload;
function  N_PointToStr ( const AFPoint: TFPoint; AFmt: string = '' ): string; overload;
function  N_PointToStr ( const AFPoint: TFPoint; AAccuracy: integer ): string; overload;
function  N_PointToStr ( const ADPoint: TDPoint; AFmt: string = '' ): string; overload;
function  N_PointToStr ( const ADPoint: TDPoint; AAccuracy: integer ): string; overload;

function  N_RectToStr ( const ARect: TRect;  AFmt: string = '' ): string; overload;
function  N_RectToStr ( const AFRect: TFRect; AFmt: string = '' ): string; overload;
function  N_RectToStr ( const AFRect: TFRect; AAccuracy: integer ): string; overload;
function  N_RectToStr ( const ADRect: TDRect; AFmt: string = '' ): string; overload;

function  N_RectToStr2 ( const AFRect: TFRect; AFmt: string = '' ): string; overload;
function  N_RectToStr2 ( const AFRect: TFRect; AAccuracy: integer ): string; overload;

function  N_DoublesToStr   ( APDoubles: PDouble; ANumDoubles, AAccuracy: integer ): string;
function  N_AffCoefs6ToStr ( const AAffCoefs6: TN_AffCoefs6; AAccuracy: integer ): string;

function  N_DPArrayToStr ( const ADPLine: TN_DPArray; APointFmt: string ): string;
function  N_IArrayToStr  ( const AIArray: TN_IArray; AIntFmt: string ): string;
function  N_ConvIntToInt ( ASrcIntValue: integer; AConvTable: TN_IPArray ): integer;
procedure N_WriteLineCoords ( AStrings: TStrings; AAccuracy: integer; var AFPLine: TN_FPArray ); overload;
procedure N_WriteLineCoords ( AStrings: TStrings; AAccuracy: integer; var ADPLine: TN_DPArray ); overload;
procedure N_ReadLineCoords  ( AStrings: TStrings; var ASInd: integer; var AFPLine: TN_FPArray ); overload;
procedure N_ReadLineCoords  ( AStrings: TStrings; var ASInd: integer; var ADPLine: TN_DPArray ); overload;
procedure N_AddOneRect  ( var ARects: TN_IRArray; var ANumRects: integer; ANewRect: TRect );
procedure N_AddSegmRect ( AP1, AP2: TPoint; var ARects: TN_IRArray; var ANumRects: integer; APixPenWidth: integer );
procedure N_AddLineRect ( ALine: TN_IPArray; ANumPoints: integer; var ARects: TN_IRArray; var ANumRects: integer; APixPenWidth: integer );
procedure N_RemoveRects ( var ARects: TN_IRArray; var ANumRects: integer; ABegInd, AEndInd: integer );
procedure N_RemoveVertexes ( var ADPoints: TN_DPArray; ABegInd, AEndInd: integer );
procedure N_InsertVertex   ( var ADPoints: TN_DPArray; ADVertex: TDPoint; AVertInd: integer );
function  N_ProjectPointOnSegm ( ADP, ADP1, ADP2: TDPoint ): TDPoint;
function  N_ProjectPointOnRect ( ARect: TRect; APoint: TPoint ): TPoint;
procedure N_ReverseDoubles ( ADoubles: TN_DArray );
procedure N_ReversePoints  ( ADPoints: TN_DPArray );
function  N_DPointFmt      ( AFEnvRect: TFRect; AAccuracy: integer ): string; overload;
function  N_DPointFmt      ( ADEnvRect: TDRect; AAccuracy: integer ): string; overload;
function  N_MaxCoordsChars ( AFEnvRect: TFRect; AAccuracy: integer ): integer;
procedure N_FillArray ( var AFPArray: TN_FPArray; AStartValue, AStep: TFPoint; ANumVals: integer; AFirstInd: integer = 0 ); overload;
procedure N_FillArray ( var ADPArray: TN_DPArray; AStartValue, AStep: TDPoint; ANumVals: integer; AFirstInd: integer = 0 ); overload;
procedure N_DeleteArrayElems ( var APArray: TN_IPArray; ABegInd, ANumElems: integer ); overload;
procedure N_DeleteArrayElems ( var AFPArray: TN_FPArray; ABegInd, ANumElems: integer ); overload;
procedure N_DeleteArrayElems ( var ADPArray: TN_DPArray; ABegInd, ANumElems: integer ); overload;
procedure N_DeleteArrayElems ( var AFRArray: TN_FRArray; ABegInd, ANumElems: integer ); overload;

procedure N_InsertArrayElems ( var ADstArray: TN_IPArray; ADstBegInd: integer; ASrcArray: TN_IPArray; ASrcBegInd, ANumElems: integer ); overload;
procedure N_InsertArrayElems ( var ADstFPArray: TN_FPArray; ADstBegInd: integer; ASrcFPArray: TN_FPArray; ASrcBegInd, ANumElems: integer ); overload;
procedure N_InsertArrayElems ( var ADstDPArray: TN_DPArray; ADstBegInd: integer; ASrcDPArray: TN_DPArray; ASrcBegInd, ANumElems: integer ); overload;
procedure N_InsertArrayElems ( var ADstFRArray: TN_FRArray; ADstBegInd: integer; ASrcFRArray: TN_FRArray; ASrcBegInd, ANumElems: integer ); overload;
procedure N_CalcFRectDCoords  ( var ADLine: TN_DPArray; AFEnvRect: TFRect; ADirection: integer );
procedure N_CalcMeanderDCoords ( var ADLine: TN_DPArray; AFEnvRect: TFRect; ANumPeriods: integer; ACoef: double = 0.5 );
procedure N_CalcSpiralDCoords ( var ADLine: TN_DPArray; AFEnvRect: TFRect; AALfaBeg, AALfaEnd, ACoef: double; ANumVerts: integer );
procedure N_CalcRegPolyDCoords( var ADLine: TN_DPArray; AFEnvRect: TFRect; AALfaBeg: double; ANumVerts: integer );
function  N_CalcRoundRectDCoords( AFEnvRect: TFRect; ARadXY: TFPoint; ANumCornerVerts: integer ): TN_DPArray; overload;
//function  N_CalcRoundRectDCoords ( PDCoords: PDPoint; APCPanel: TN_PCPanel; ALLWUSize: float; AEnvRect: TFRect; NumCornerPoints: integer ): integer; overload;
function  N_EnvRectPos( const AEnvRect, AClipRect: TRect  ): integer; overload;
function  N_EnvRectPos( const AEnvRect, AClipRect: TFRect ): integer; overload;
procedure N_ChangePointsCoords ( const AOldCoords, ANewCoords: TDPoint; APDPoints: PDPoint; ANumPoints: integer );
procedure N_Calc2BSplineCoords ( APInpDC: PDPoint; ANInpPoints, ANAddPoints: integer; AMinAngle, AMinSegmSize: float; var AOutDC: TN_DPArray; out ANOutPoints: integer ); overload;
procedure N_Calc2BSplineCoords ( APInpDC: PDPoint; ANInpPoints, ANResPoints: integer; var AOutDC: TN_DPArray; var AOutAngles: TN_DArray ); overload;
function  N_DeleteSameDVertexes ( APDInpVert: PDPoint; ANumInpVerts: integer; out ADOutVerts: TN_DPArray ): integer;
function  N_CursorNearRect   ( const ARect: TRect; ACPos: TPoint; ADelta: integer ): integer;
function  N_IPointNearIRects ( ABegInd: integer; ARects: TN_IRArray; ACPos: TPoint; ADelta: integer; out AFlags: integer ): integer;
function  N_GetSizeByMargins ( const AMargins: TDRect; const AExtRSize: TDPoint ): TDPoint;
function  N_GetMargins ( const AMinMargins: TDRect; const AExtRSize, AEmbRSize: TDPoint; AHorAlign: TN_HVAlign; AVertAlign: TN_HVAlign ): TDRect; overload;
function  N_GetMargins ( const AMinMargins: TDRect; const AExtRSize: TDPoint; AAspect: double; AHorAlign: TN_HVAlign; AVertAlign: TN_HVAlign ): TDRect; overload;
function  N_GetPrinterDstRect  ( AMarginsmm: TDRect ): TRect;
function  N_CalcPolylineCenter ( APFLine: PFPoint; ANumPoints: integer ): TFPoint; overload;
function  N_CalcPolylineCenter ( APDLine: PDPoint; ANumVerts: integer ): TDPoint; overload;

function  N_StepAlongPolyline  ( APFLine: PFPoint; ASLengths: TN_FArray; ANumSegms: integer; AStep: double; var AInd: integer; var ADelta: float ): TFPoint; overload;
function  N_StepAlongPolyline  ( APDLine: PDPoint; ASLengths: TN_DArray; ANumSegms: integer; AStep: double; var AInd: integer; var ADelta: double ): TDPoint; overload;
function  N_CalcSegmLengths ( APDLine: PDPoint; ANumVerts: integer; var ASegmLengths: TN_DArray ): double;
function  N_Line2LineDist   ( APDVert1, APDVert2: PDPoint; ANumVerts1, ANumVerts2: integer; ASLengths1, ASLengths2: TN_DArray; AWSize1, AWSize2, AMaxDist: double; ANumCheckPoints, AModeFlags: integer ): double;

function  N_EllipseEnvRect      ( const AEllCenter, AEllSize: TFPoint ): TFRect;
function  N_FloatEllipsePoint   ( const AEnvFRect: TFRect; AAlfa: float ): TFPoint;
function  N_EllipsePoint        ( const AEnvFRect: TFRect; AAlfa: float ): TFPoint;
procedure N_EllipseCenterAndRad ( const AEnvFRect: TFRect; out AEllCenter, AEllRad: TFPoint );
function  N_Round    ( const AFPoint: TFPoint; ACoef: double = 1 ): TFPoint;
procedure N_PolyDraw ( AHDC: HDC; const APoints; const ATypes; ACount: integer );
function  N_GetPathCoords ( AHDC: HDC; var APoints: TN_IPArray; var ATypes: TN_BArray ): integer;
procedure N_ShiftICoords  ( APSrcVert, APDstVert: PPoint; ANumVerts: integer; AShiftSize: TPoint );
procedure N_CalcRotatedRectCoords ( const ASrcRect: TRect; AAngle: double; out ADstEnvRect: TRect; out AInpReper, AOutReper: TN_3DPReper );
procedure N_ProcessMainFormMove ( AMainUserFormRect: TRect );

//function  N_GetSegmentAngle ( const AP1, AP2: TFPoint ): double;


var
  N_FullIRect: TRect = ( Left:0; Top:0; Right:-1; Bottom:-1 );

//******************** Global Objects ******************************
var
  N_LineInfo: TN_LineInfo;

implementation
uses Math, Sysutils, Printers,
  N_Gra0, N_Lib0, N_InfoF;


//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Get0360Angle
//********************************************************** N_Get0360Angle ***
// Normalize given angle value
//
//     Parameters
// AAngle - given angle in degrees
// Result - Return angle normalized to [0,360) interval ( 0 <= Result < 360 )
//
function N_Get0360Angle( AAngle: double ): double;
var
  k: integer;
begin
  Result := AAngle;

  if Result >= 360 then
  begin
    k := Round( Floor( Result/360 ) );
    Result := Result - k*360;
  end;

  if Result < 0 then
  begin
    k := Round( Floor( -Result/360 ) ) + 1;
    Result := Result + k*360;
  end;

end; // function N_Get0360Angle



//********** TN_IRects class methods  **************

//******************************************************** TN_IRects.Create ***
//
constructor TN_IRects.Create;
begin
  SetLength( IRects, 100 );
  NumRects := 0;
end; //*** end of Constructor TN_IRects.Create

//******************************************************* TN_IRects.Destroy ***
//
destructor TN_IRects.Destroy;
begin
  IRects := nil;
  Inherited;
end; //*** end of destructor TN_IRects.Destroy

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_IRects\AddOneRect
//**************************************************** TN_IRects.AddOneRect ***
// Add One Integer Rectangle to self
//
//     Parameters
// ARect - adding Integer Rectngle
//
procedure TN_IRects.AddOneRect( ARect: TRect );
begin
  Inc(NumRects);
  if Length(IRects) < NumRects then
    SetLength( IRects, NumRects + (NumRects div 2) + 4 );
  IRects[NumRects-1] := ARect;
end; //*** end of procedure TN_IRects.AddOneRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_IRects\SubtractOneRect
//*********************************************** TN_IRects.SubtractOneRect ***
// Subtract area of given Rectangle from all Rectangles in Self, new (smaller) 
// Rectangles are added to Self
//
//     Parameters
// ARect - subtracting Integer Rectngle
//
procedure TN_IRects.SubtractOneRect( ARect: TRect );
var
  i, j, FreeInd, NeededLength, NewRectsCount: integer;
  NewRects: TN_IRArray;
begin
  SetLength( NewRects, 4 ); // max possible number of rezulting Rects
  FreeInd := NumRects;      // first free index in IRects array

  for i := 0 to NumRects-1 do
  begin
    NewRectsCount := N_IRectSubstr( NewRects, IRects[i], ARect );

    if NewRectsCount > 0 then // subst IRects[i] by NewRects
    begin
      NeededLength := NumRects + NewRectsCount - 1;
      if Length(IRects) < NeededLength then
      SetLength( IRects, N_NewLength(Length(IRects)) );

      IRects[i] := NewRects[0];
      for j := 0 to NewRectsCount-2 do IRects[FreeInd+j] := NewRects[j+1];
      Inc( FreeInd, NewRectsCount-1 );
    end; // if NewRectsCount > 0 then // subst IRects[i] by NewRects

  end; // end for i := 0 to NumRects-1 do

end; //*** end of procedure TN_IRects.SubtractOneRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_IRects\AddRectArray
//************************************************** TN_IRects.AddRectArray ***
// Add Rectangles Array to self
//
//     Parameters
// RectArray - adding Rectangles Array
//
procedure TN_IRects.AddRectArray( RectArray: TN_IRects );
var
  i, NewSize: integer;
begin
  NewSize := NumRects + RectArray.NumRects;
  if Length( IRects ) < NewSize then
    SetLength( IRects, N_NewLength(Length(IRects)) );
  for i := NumRects to NewSize-1 do IRects[i] := RectArray.IRects[i-NumRects];
end; //*** end of procedure TN_IRects.AddRectArray

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_IRects\SubtractRectArray
//********************************************* TN_IRects.SubtractRectArray ***
// Subtract area of all Rectangles in given Rectangles Array from all Rectangles
// in self,
//
//     Parameters
// RectArray - subtracting Rectangles Array
//
procedure TN_IRects.SubtractRectArray( RectArray: TN_IRects );
var
  i: integer;
begin
  for i := 0 to RectArray.NumRects-1 do
    SubtractOneRect( RectArray.IRects[i] );
end; //*** end of procedure TN_IRects.SubtractRectArray


//********** TN_RectLinesLists class methods  **************

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_RectLinesLists\Create
//************************************************ TN_RectLinesLists.Create ***
// TN_RectLinesLists class constructor
//
//     Parameters
// AEnvRect     - envelope Double Rectangle
// ANumX, ANumY - number of Rects along X,Y axis
//
constructor TN_RectLinesLists.Create( const AEnvRect: TDRect;
                                      const ANumX, ANumY: integer );
begin
  EnvRect := AEnvRect;
  NumRectX := ANumX;
  NumRectY := ANumY;
  RectDX := (EnvRect.Right - EnvRect.Left) / NumRectX;
  RectDY := (EnvRect.Bottom - EnvRect.Top) / NumRectY;
  DeltaSize := 4;
  MaxSegmInd := $FFFF; // max 64K Segments in each Line
  MaxLineInd := $FFFF; // max 64K Lines
  SegmIndBits := 16;
  SetLength( LinesLists, NumRectX*NumRectY );
end; //*** end of Constructor TN_RectLinesLists.Create

//*********************************************** TN_RectLinesLists.Destroy ***
destructor TN_RectLinesLists.Destroy;
begin
  LinesLists := nil;
  Inherited;
end; //*** end of destructor TN_RectLinesLists.Destroy

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_RectLinesLists\AddLineSegmInd
//**************************************** TN_RectLinesLists.AddLineSegmInd ***
// Add given LineSegmInd to RectList with given RectInd
//
//     Parameters
// ARectInd     - rectangle index
// ALineSegmInd - Line Segment index
//
procedure TN_RectLinesLists.AddLineSegmInd( ARectInd, ALineSegmInd: integer );
begin
  if LinesLists[ARectInd] = nil then // first LineSegmInd in this Rect
  begin
    SetLength( LinesLists[ARectInd], DeltaSize );
    LinesLists[ARectInd,0] := 1; // number of elements
    LinesLists[ARectInd,1] := ALineSegmInd;
    Exit;
  end;

  if High(LinesLists[ARectInd]) = LinesLists[ARectInd,0] then // inc array
    SetLength( LinesLists[ARectInd], Length(LinesLists[ARectInd])+DeltaSize );

  Inc( LinesLists[ARectInd,0] );
  LinesLists[ ARectInd, LinesLists[ARectInd,0] ] := ALineSegmInd;

end; //*** end of procedure TN_RectLinesLists.AddLineSegmInd

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_RectLinesLists\AddLineSegment
//**************************************** TN_RectLinesLists.AddLineSegment ***
// Add LineInd and SegmInd of given Line Segment to all needed Rect Lists
//
//     Parameters
// ADPoint1, ADPoint2 - Double Points
// ALineInd           - Line index
// ASegmInd           - Line Segment index
//
procedure TN_RectLinesLists.AddLineSegment( const ADPoint1, ADPoint2: TDPoint;
                                            const ALineInd, ASegmInd: integer );
var
  RectInd, RectIndX, RectIndY, LineSegmInd, SIX, SIY, SK: integer;
  RectIndX1, RectIndY1, RectIndX2, RectIndY2: integer;
  X, Y, K, KNorm, FRectIndX, FRectIndY: double;
begin

  if (ALineInd > MaxLineInd) or (ASegmInd > MaxSegmInd) then
  begin
    N_Error1( 'Too big LineInd or SegmInd' );
    Exit;
  end;
  Inc(NumSegments);
  LineSegmInd := (ALineInd shl SegmIndBits) or ASegmInd;

  SIX := 1;
  if ADPoint1.X > ADPoint2.X then SIX := -1;

  SIY := 1;
  if ADPoint1.Y > ADPoint2.Y then SIY := -1;

  RectIndX1 := Floor( ( ADPoint1.X - EnvRect.Left ) / RectDX );
  RectIndX2 := Floor( ( ADPoint2.X - EnvRect.Left ) / RectDX );

  RectIndY1 := Floor( ( ADPoint1.Y - EnvRect.Top ) / RectDY );
  RectIndY2 := Floor( ( ADPoint2.Y - EnvRect.Top ) / RectDY );

  RectInd := RectIndY1*NumRectX + RectIndX1; // LinesLists index
  AddLineSegmInd( RectInd, LineSegmInd ); // initial Rect with Point1
  RectIndX := RectIndX1;
  RectIndY := RectIndY1;

  if ADPoint1.Y = ADPoint2.Y then // horizontal line
  begin
    while True do
    begin
      if RectIndX = RectIndX2 then Exit; // all done
      Inc( RectIndX, SIX );
      RectInd := RectIndY*NumRectX + RectIndX; // LinesLists index
      AddLineSegmInd( RectInd, LineSegmInd );
    end;
  end;

  if ADPoint1.X = ADPoint2.X then // vertical line
  begin
    while True do
    begin
      if RectIndY = RectIndY2 then Exit; // all done
      Inc( RectIndY, SIY );
      RectInd := RectIndY*NumRectX + RectIndX; // LinesLists index
      AddLineSegmInd( RectInd, LineSegmInd );
    end;
  end;

  //*** not vertical, nor horizontal line
  //    prepare to loop in X direction

  K := (ADPoint2.Y - ADPoint1.Y) / (ADPoint2.X - ADPoint1.X);
  KNorm := K*RectDX/RectDY;
  SK := SIY;
  if KNorm < 0 then SK := -SK;

  if ADPoint1.X < ADPoint2.X then // from left to right
  begin
    X := EnvRect.Left + RectIndX1*RectDX;
    Y := ADPoint1.Y + (X - ADPoint1.X)*K;
  end else
  begin
    X := EnvRect.Left + (RectIndX1+1)*RectDX;
    Y := ADPoint1.Y + (X - ADPoint1.X)*K;
  end;
  FRectIndY := (Y - EnvRect.Top) / RectDY;
  RectIndX := RectIndX1;

  while True do // loop in X direction
  begin
    if RectIndX = RectIndX2 then Break; // goto loop in Y direction
    Inc( RectIndX, SIX );
    FRectIndY := FRectIndY + KNorm*SK;
    RectIndY := Floor( FRectIndY );
    RectInd := RectIndY*NumRectX + RectIndX; // LinesLists index
    AddLineSegmInd( RectInd, LineSegmInd );
  end; // while True do // loop in X direction

  //***** prepare to loop in Y direction

  KNorm := 1.0/KNorm;
  SK := SIX;
  if KNorm < 0 then SK := -SK;

  if ADPoint1.Y < ADPoint2.Y then // from top to down
  begin
    Y := EnvRect.Top + RectIndY1*RectDY;
    X := ADPoint1.X + (Y - ADPoint1.Y)/K;
  end else
  begin
    Y := EnvRect.Top + (RectIndY1+1)*RectDY;
    X := ADPoint1.X + (Y - ADPoint1.Y)/K;
  end;
  FRectIndX := (X - EnvRect.Left) / RectDX;
  RectIndY := RectIndY1;

  while True do // loop in Y direction
  begin
    if RectIndY = RectIndY2 then Exit; // all done
    Inc( RectIndY, SIY );
    FRectIndX := FRectIndX + KNorm*SK;
    RectIndX := Floor( FRectIndX );
    RectInd := RectIndY*NumRectX + RectIndX; // LinesLists index
    AddLineSegmInd( RectInd, LineSegmInd );
  end; // while True do // loop in Y direction
end; //*** end of procedure TN_RectLinesLists.AddLineSegment

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_RectLinesLists\CollectStatistics
//************************************* TN_RectLinesLists.CollectStatistics ***
// Collect statistics about LinesLists
//
procedure TN_RectLinesLists.CollectStatistics();
var
  i, NFilled, Size: integer;
begin
  NFilled := 0;
  for i := 0 to NumRectX*NumRectY-1 do
  begin
    Size := Length(LinesLists[i]);
    if Size > 0 then
    begin
      Inc(NFilled);
      Inc( LinesListsSize, Size );
      Inc( NumComparisons, Size*(Size-1) div 2 );
      if MaxListSize < Size then MaxListSize := Size;
    end
  end; // for i := 0 to NumRectX*NumRectY-1 do

  NotEmptyRectsRatio := 1.0*NFilled / (NumRectX*NumRectY);
  AverageListSize := 1.0*LinesListsSize / NFilled;

end; //*** end of procedure TN_RectLinesLists.CollectStatistics


//********** TN_GeoProjPar class methods  **************

const GPRAD = 0.017453293;
const GPA   = 8.181334E-2;

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_GeoProjPar\S
//********************************************************* TN_GeoProjPar.S ***
// Calculates Arc Length of meridian
//
//     Parameters
// B      - meridian arc length in degrees
// Result - Returns Arc Length
//
function TN_GeoProjPar.S( B: double ): double;
var
 SS, cosB, sinB, cosB2: double;
begin
  B := B * GPRAD; // convert to radians
  cosB := cos(B);  sinB := sin(B);  cosB2 := cosB * cosB;
  SS := sinB * cosB * (-32140.4049 + cosB2 * (135.3303 + cosB2 *
                                               (-0.7092 + cosB2 * 0.0042)));
  Result := 6367558.4969 * B + SS;
end; // end of function TN_GeoProjPar.S

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_GeoProjPar\N
//********************************************************* TN_GeoProjPar.N ***
// Calculates radius of curvature of first ??
//
//     Parameters
// B      - meridian arc length in degrees
// Result - Returns radius of curvature
//
function TN_GeoProjPar.N( B: double ): double;
var
  A1: double;
begin
  A1 := GPA * sin(B * GPRAD);
  Result := 6378245.0 / sqrt( 1.0 - (A1*A1) );
end; // end of function TN_GeoProjPar.N

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_GeoProjPar\RP
//******************************************************** TN_GeoProjPar.RP ***
// Calculate parallel radius
//
//     Parameters
// B      - meridian arc length in degrees
// Result - Returns given parallel radius
//
function TN_GeoProjPar.RP( B: double ): double;
begin
  Result := N(B) * cos(B*GPRAD);
end; // end of function TN_GeoProjPar.RP

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_GeoProjPar\U
//********************************************************* TN_GeoProjPar.U ***
// Calculate intermediate expression, used in ConvertLine method
//
//     Parameters
// B      - meridian arc length in degrees
// Result - Returns calculated intermediate expression
//
function TN_GeoProjPar.U( B: double ): double;
var
  B1, D1, D2, D3: double;
begin
  B1 := B/2.0+45.0;
  D1 := tan(B1*GPRAD);
  D2 := GPA*sin(B*GPRAD);
  D3 := (1.0-D2)/(1.0+D2);
  Result := ln(D1) + 0.5*GPA*ln(D3);
end; // end of function TN_GeoProjPar.U

//**************************************************** TN_GeoProjPar.Create ***
//
constructor TN_GeoProjPar.Create();
begin
  GPType := 0;
  Alfa := N_NotADouble; // Alfa, Q, C coefs. are not ready
end; //*** end of Constructor TN_GeoProjPar.Create

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_GeoProjPar\ConvertLine
//*********************************************** TN_GeoProjPar.ConvertLine ***
// Convert Line coordinates from (B,L) to needed geo projection
//
//     Parameters
// InpCoords - input Double coordinates
// OutCoords - output Double coordinates
// ConvMode  - convertion mode flags:
//#F
// bit4($010) =0 - convert from degree (B,L or L,B) to metric (X,Y) coordinates
//            =1 - convert from metric (X,Y) to degree (B,L or L,B) coordinates
//
// bit5($020) =0 - first degree coordinates is B, second is L
//            =1 - first degree coordinates is L, second is B
//
// bit6($040) =0 - do not toggle B sign
//            =1 - toggle B sign
//#/F
//
// InpCoords and OutCoords can be the same Array
//
procedure TN_GeoProjPar.ConvertLine( const InpCoords: TN_DPArray;
                                var OutCoords: TN_DPArray; ConvMode: integer );
var
  i: integer;
  R1, R2, S1, S2, U1, U2, RO, SIG, W, L, B, X, Y: double;
begin
  if Length(OutCoords) <> Length(InpCoords) then
    SetLength( OutCoords, Length(InpCoords) );

  if Alfa = N_NotADouble then // calc projection coefs
  begin

  case GPType of

  0: begin // not used
  end;

  1: begin //***** normal conical 1
           // нормальна€ (пр€ма€) коническа€ равнопромежуточна€
           // проекци€ (эллипсоид  расовского)
    if (B1 = B2) then
    begin
      Alfa := sin( B1 * GPRAD );
      C    := N( B1 ) / tan(  B1 * GPRAD) + S(B1);
    end else // B1 <> B2
    begin
      R1   := RP(B1);  R2 := RP(B2);
      S1   := S(B1);   S2 := S(B2);
      Alfa := (R1 - R2) / (S2 - S1);
      C    := R2 / Alfa + S2;
    end;

    Q := 8.0e+6;

    RO := C - S(BS);
    MRec.Top := (Q - RO) / Scale;
    RO := C - S(BN);
    MRec.Bottom := (Q - RO) / Scale;

    SIG := Alfa * ((LW - L0) * GPRAD);
    RO := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Left := (RO * sin(SIG)) / Scale;
    SIG := Alfa * ((LE - L0) * GPRAD);
    RO := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Right := (RO * sin(SIG)) / Scale;
  end; // 1: begin // normal conical 1

  2: begin //***** normal conical 2 (нормальна€ коническа€ )
           // нормальна€ (пр€ма€) коническа€ равнопромежуточна€
           // проекци€ (эллипсоид  расовского)
    R1 := RP(B1);
    U1 := U(B1);
    if B1 <> B2 then
    begin
      R2   := RP(B2);
      U2   := U(B2);
      Alfa := ln(R1/R2)/(U2-U1);
    end else
      Alfa := sin(B1 * GPRAD);

    C := exp(ln(R1/Alfa)+Alfa*U1);
    Q := 8.0E06;

    RO := C * exp(-Alfa * U(BS));
    MRec.Top := (Q - RO) / Scale;
    RO := C * exp(-Alfa * U(BN));
    MRec.Bottom := (Q - RO) / Scale;
    SIG := Alfa * ((LE - L0) * GPRAD);
    RO  := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Left := (RO * sin(SIG)) / Scale;
    SIG := Alfa * ((LW - L0) * GPRAD);
    RO  := (Q - MRec.Top * Scale) / cos(SIG);
    MRec.Right := (RO * sin(SIG)) / Scale;
  end; // 2: begin // normal conical 2 (нормальна€ коническа€ )

  3: begin //***** normal cilindrycal Mercator
           // нормальна€ цилиндрическа€ проекци€ ћеркатора (сфера)
    C := RP( B1 );

    MRec.Left := ( C * LE * GPRAD ) / Scale;
    MRec.Top  := ( C * U( BS ) ) / Scale;

    MRec.Right  := ( C * LW * GPRAD ) / Scale;
    MRec.Bottom := ( C * U( BN ) ) / Scale;
  end; // 3: begin // normal cilindrycal Mercator

  else Assert( False, 'Unknown Projection type' );

  end; // end of case GPType of

  end; // if Alfa = N_NotADouble then // calc projection coefs


  //***** all coefs are OK, convert coords

  case GPType of
  1: begin //*************************** normal conical 1

  if (ConvMode and $010) <> 0 then // convert from X,Y to B,L or L,B
  for i := 0 to High(InpCoords) do
  begin
    X := InpCoords[i].X;
    Y := InpCoords[i].Y;

    W := (Q / Scale - (Y+MRec.Top)) *
         (Q / Scale - (Y+MRec.Top))
        + (X+MRec.Left) * (X+MRec.Left);
    B := (C - Scale * sqrt(W)) / 6367558.5;
    OutCoords[i].X := (B + (25184.5 * sin(2*B) + 37.0 * sin(4*B)) * 1.0E-7)
                                                                    / GPRAD;
    W := (arctan((X+MRec.Left)/
         (Q / Scale - (Y+MRec.Top))) / GPRAD);
    OutCoords[i].Y := W / Alfa + L0;

    if (ConvMode and $040) <> 0 then // toggle B sign
      OutCoords[i].X := -OutCoords[i].X;

    if (ConvMode and $020) <> 0 then // convert from X,Y to L,B
    begin                            // swap (B,L)
      B := OutCoords[i].X;
      OutCoords[i].X := OutCoords[i].Y;
      OutCoords[i].Y := B;
    end;
  end else //*** convert from B,L or L,B to X,Y ( (ConvMode and $010) = 0 )
  for i := 0 to High(InpCoords) do
  begin
    if (ConvMode and $020) <> 0 then // convert from L,B to X,Y
    begin
      L := InpCoords[i].X;
      B := InpCoords[i].Y;
    end else // ********************* convert from B,L to X,Y
    begin
      B := InpCoords[i].X;
      L := InpCoords[i].Y;
    end;

    if (ConvMode and $040) <> 0 then // toggle B sign
      B := -B;

    RO := C - S( B );
    SIG := Alfa * ( L - L0 ) * GPRAD;
    OutCoords[i].X := RO * sin(SIG) / Scale - MRec.Left;
    OutCoords[i].Y := (Q - RO * cos(SIG)) / Scale - MRec.Top;

    if (ConvMode and $080) = 0 then // toggle Y sign
      OutCoords[i].Y := -OutCoords[i].Y;
  end;
  end; // 1: begin // normal conical 1

  2: begin //*************************** normal conical 2
  if (ConvMode and $010) <> 0 then // convert from X,Y to B,L or L,B
  for i := 0 to High(InpCoords) do
  begin
    X := InpCoords[i].X;
    Y := InpCoords[i].Y;

    W := Q / Scale - Y;
    W := W*W + X*X;
    W := ln(C / (W * Scale)) / Alfa;
    B := 2.0 * arctan(exp(W)) - 90.0 * GPRAD;
    OutCoords[i].X := (B + (33560.7 * sin(2*B) + 65.7 * sin(4*B)) * 1.0E-7)
                                                                       / GPRAD;
    W := (arctan((X+MRec.Left)/
         (Q / Scale - (Y+MRec.Top))) / GPRAD);
    OutCoords[i].Y := W / Alfa + L0;

    if (ConvMode and $040) <> 0 then // toggle B sign
      OutCoords[i].X := -OutCoords[i].X;

    if (ConvMode and $020) <> 0 then // convert from X,Y to L,B
    begin                            // swap (B,L)
      B := OutCoords[i].X;
      OutCoords[i].X := OutCoords[i].Y;
      OutCoords[i].Y := B;
    end;
  end else //**** convert from B,L or L,B to X,Y ( (conv_type and 010) == 0 )
  for i := 0 to High(InpCoords) do
  begin
    if (ConvMode and $020) <> 0 then // convert from L,B to X,Y
    begin
      L := InpCoords[i].X;
      B := InpCoords[i].Y;
    end else // ********************* convert from B,L to X,Y
    begin
      B := InpCoords[i].X;
      L := InpCoords[i].Y;
    end;

    if (ConvMode and $040) <> 0 then // toggle B sign
      B := -B;

    RO := C * exp(-Alfa * U(B));
    SIG := Alfa * (L - L0) * GPRAD;
    OutCoords[i].X := RO * sin(SIG) / Scale;
    OutCoords[i].Y := (Q - RO * cos(SIG)) / Scale;

    if (ConvMode and $080) = 0 then // toggle Y sign
      OutCoords[i].Y := -OutCoords[i].Y;
  end; // for i := 0 to High(InpCoords) do
  end; // 2: begin // normal conical 2

  3: begin //*************************** normal cilindrycal Mercator
  if (ConvMode and $010) <> 0 then // convert from X,Y to B,L or L,B
  for i := 0 to High(InpCoords) do
  begin
    X := InpCoords[i].X;
    Y := InpCoords[i].Y;

    B := Y * Scale / C;
    B := 2.0 * arctan(exp(B)) - 90. * GPRAD;
    OutCoords[i].X := (B + (33560.7 * sin(2*B) + 65.7 * sin(4*B)) * 1.0E-7) /
                                                                      GPRAD;
    OutCoords[i].Y := (X * Scale) / (C * GPRAD);

    if (ConvMode and $040) <> 0 then // toggle B sign
      OutCoords[i].X := -OutCoords[i].X;

    if (ConvMode and $020) <> 0 then // convert from X,Y to L,B
    begin                          // swap (B,L)
      B := OutCoords[i].X;
      OutCoords[i].X := OutCoords[i].Y;
      OutCoords[i].Y := B;
    end;
  end // for i := 0 to High(InpCoords) do, if
  else //**** convert from B,L or L,B to X,Y ( (conv_type and 010) == 0 )
  for i := 0 to High(InpCoords) do
  begin
    if (ConvMode and $020) <> 0 then // convert from L,B to X,Y
    begin
      L := InpCoords[i].X;
      B := InpCoords[i].Y;
    end else // ********************* convert from B,L to X,Y
    begin
      B := InpCoords[i].X;
      L := InpCoords[i].Y;
    end;

    if (ConvMode and $040) <> 0 then // toggle B sign
      B := -B;

    OutCoords[i].X := ( C * L * GPRAD ) / Scale;
    OutCoords[i].Y := ( C * U( B ) ) / Scale;

    if (ConvMode and $080) = 0 then // toggle Y sign
      OutCoords[i].Y := -OutCoords[i].Y;
  end; // for i := 0 to High(InpCoords) do
  end; // 3: begin // normal cilindrycal Mercator

  end; // case GPType of
end; //*** end of procedure TN_GeoProjPar.ConvertLine


//****************** TN_LineInfo class methods **********************

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_LineInfo\Clear
//******************************************************* TN_LineInfo.Clear ***
// Clear (initialize) all Self fields (prepare for collecting Info)
//
procedure TN_LineInfo.Clear;
begin
  SumItems    := 0;
  SumMPItems  := 0;
  AvrNumParts := 0;
  MaxNumParts := 0;

  WNumLines   := 0;
  WNumClosed  := 0;
  WNumNZSegms := 0;
  WNumZSegms  := 0;

  SumNumPoints := 0;
  MinNumPoints := N_MaxInteger;
  AvrNumPoints := 0;
  MaxNumPoints := 0;

  SumSegmSize := 0;
  MinSegmSize := N_MaxFloat;
  AvrSegmSize := 0;
  MaxSegmSize := 0;

  MinEnvRectSize := N_MaxFloat;
  AvrEnvRectSize := 0;
  MaxEnvRectSize := 0;

  NumPointsRanges   := nil;
  SegmSizeRanges    := nil;
  EnvRectSizeRanges := nil;
end; // procedure TN_LineInfo.Clear

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_LineInfo\CollectInfo
//************************************************* TN_LineInfo.CollectInfo ***
// Collect Info about one given Double Line in Self fields
//
procedure TN_LineInfo.CollectInfo( DLine: TN_DPArray );
var
  i, HDL, CurNumPoints: integer;
  CurSegmSize, LineEnvRectSize: double;
  LineEnvRect: TFRect;
begin
  HDL := High(DLine);
  Inc(WNumLines);
  if N_Same( DLine[0], DLine[HDL] ) then Inc(WNumClosed);
  CurNumPoints := HDL+1;

  Inc( SumNumPoints, CurNumPoints );
  if (MinNumPoints > CurNumPoints) then MinNumPoints := CurNumPoints;
  if (MaxNumPoints < CurNumPoints) then MaxNumPoints := CurNumPoints;
  AvrNumPoints := (AvrNumPoints*(WNumLines-1) + CurNumPoints)/WNumLines;

  for i := 0 to HDL-1 do // along all DLine segments
  begin
    CurSegmSize := N_P2PDistance( DLine[i], DLine[i+1] );

    if CurSegmSize = 0 then
      Inc(WNumZSegms)
    else
    begin
      Inc(WNumNZSegms);
      SumSegmSize := SumSegmSize + CurSegmSize;
      if (MinSegmSize > CurSegmSize) then MinSegmSize := CurSegmSize;
      if (MaxSegmSize < CurSegmSize) then MaxSegmSize := CurSegmSize;
      AvrSegmSize := (AvrSegmSize*(WNumNZSegms-1) + CurSegmSize)/WNumNZSegms;
    end;

  end; // for i := 0 to HDL-1 do // along all DLine segments

  LineEnvRect := N_CalcLineEnvRect( DLine, 0, CurNumPoints );
  LineEnvRectSize := Max( N_RectWidth(LineEnvRect), N_RectHeight(LineEnvRect) );
  if (MinEnvRectSize > LineEnvRectSize) then MinEnvRectSize := LineEnvRectSize;
  if (MaxEnvRectSize < LineEnvRectSize) then MaxEnvRectSize := LineEnvRectSize;
  AvrEnvRectSize := (AvrEnvRectSize*(WNumLines-1) + LineEnvRectSize)/WNumLines;

// add later code for Ranges filling
end; // procedure TN_LineInfo.CollectInfo

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_LineInfo\SetRanges
//*************************************************** TN_LineInfo.SetRanges ***
// Set Ranges by given numbers of ranges
//
procedure TN_LineInfo.SetRanges( NumPRanges, SegmSRanges, EnvSRanges: integer );
begin
// not implemented yet
end; // procedure TN_LineInfo.SetRanges

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_LineInfo\ConvToStrings
//*********************************************** TN_LineInfo.ConvToStrings ***
// Convert collected info to strings (add text strings to SL obj)
//
//     Parameters
// ASL   - resulting strings list
// AMode - not used now
//
procedure TN_LineInfo.ConvToStrings( ASL: TStrings; AMode: integer );
begin
  ASL.Add( Format( '   Number of Non empty Items: %.0n', [1.0*SumItems] ));
  ASL.Add( Format( '   Number of MultiPart Items: %.0n', [1.0*SumMPItems] ));
  ASL.Add( Format( ' Max Parts in MultiPart Item: %.0n', [1.0*MaxNumParts] ));
  ASL.Add( Format( ' Avr.Parts in MultiPart Item: %.1n', [AvrNumParts] ));

  ASL.Add( Format( '             Number of Lines: %.0n', [1.0*WNumLines] ));
  ASL.Add( Format( '      Number of Closed Lines: %.0n', [1.0*WNumClosed] ));
  ASL.Add( Format( ' Number of Non Zero Segments: %.0n', [1.0*WNumNZSegms] ));
  ASL.Add( Format( '     Number of Zero Segments: %.0n', [1.0*WNumZSegms] ));
  ASL.Add( '' );

  ASL.Add( Format( '      Whole Number of Points: %.0n', [1.0*SumNumPoints] ));
  ASL.Add( Format( '          Min Points in Line: %.0n', [1.0*MinNumPoints] ));
  ASL.Add( Format( '          Max Points in Line: %.0n', [1.0*MaxNumPoints] ));
  ASL.Add( Format( '      Average Points in Line: %.1n', [AvrNumPoints] ));

  ASL.Add( Format( '    Sum of all Segment Sizes: %.3e', [SumSegmSize] ));
  ASL.Add( Format( '            Min Segment Size: %.3e', [MinSegmSize] ));
  ASL.Add( Format( '            Max Segment Size: %.3e', [MaxSegmSize] ));
  ASL.Add( Format( '        Average Segment Size: %.3e', [AvrSegmSize] ));

  ASL.Add( Format( '       Min Line EnvRect Size: %.3e', [MinEnvRectSize] ));
  ASL.Add( Format( '       Max Line EnvRect Size: %.3e', [MaxEnvRectSize] ));
  ASL.Add( Format( '   Average Line EnvRect Size: %.3e', [AvrEnvRectSize] ));
end; // procedure TN_LineInfo.ConvToStrings


//****************** TN_LineInfo class methods **********************

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_CurveCoords\Init
//***************************************************** TN_CurveCoords.Init ***
// Init Curve data
//
//     Parameters
// ACurveType   - curve type enumeration
// APBasePoints - pointer to first Double Point of Double Points array
// ANumPoints   - number of Points in given points array
//
procedure TN_CurveCoords.Init( ACurveType: integer; APBasePoints: PDPoint;
                                                        ANumPoints: integer );
var
  i: integer;
  LineLength: double;
begin
  CurveType   := ACurveType;
  PBasePoints := APBasePoints;
  NumPoints   := ANumPoints;
  N_LSegmLengths( PBasePoints, NumPoints, LSLengths ); // calc LSegmLengths
  LineLength := LSLengths[NumPoints-1];

  for i := 0 to NumPoints-1 do
    LSLengths[i] := LSLengths[i] / LineLength;
end; // procedure TN_CurveCoords.Init

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_CurveCoords\GetPointInfo
//********************************************* TN_CurveCoords.GetPointInfo ***
// Get info about given Point (temporary, later improve)
//
//     Parameters
// AQ - Length from Curve begin point along segments
//
procedure TN_CurveCoords.GetPointInfo( AQ: double );
var
  i: integer;
begin
  if AQ < LSLengths[0] then
  begin
    LastQ := 0;
    LastInd := 0;
    LastAlpha := 0;
  end else if AQ >= LSLengths[NumPoints-1] then
  begin
    LastQ := 1.0;
    LastInd := NumPoints-2;
    LastAlpha := 1.0;
  end else
    for i := 0 to NumPoints-2 do
    begin
      if (LSLengths[i] <= AQ) and (AQ < LSLengths[i+1]) then
      begin
        LastQ := AQ;
        LastInd := i;
        LastAlpha := (AQ - LSLengths[i]) / (LSLengths[i+1] - LSLengths[i]);
        Break;
      end;
    end;
end; // procedure TN_CurveCoords.GetPointInfo

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_CurveCoords\CalcCurve
//************************************************ TN_CurveCoords.CalcCurve ***
// Calculate Curve coordinates and angles (if needed) (temporary version)
//
//     Parameters
// QBeg, QEnd - Lengths from Curve begin point along segments
// ANumPoints - number of resulting Points
// DCoords    - resulting array of Double Points
// DAngles    - resulting array of Double Angles
//
procedure TN_CurveCoords.CalcCurve( QBeg, QEnd: double; ANumPoints: integer;
                             var DCoords: TN_DPArray; var DAngles: TN_DArray );
var
  i: integer;
  dQ: double;
  PDP1, PDP2: PDPoint;
begin
  Assert( ANumPoints > 1, 'Bad AnumPoints' );
  if Length(DCoords) < ANumPoints then
    SetLength( DCoords, N_NewLength(ANumPoints) );

  if (DAngles <> nil) and (Length(DAngles) < ANumPoints) then
    SetLength( DAngles, N_NewLength(ANumPoints) );

  dQ := (QEnd - QBeg) / (ANumPoints-1);
  for i := 0 to ANumPoints-1 do
  begin
    GetPointInfo( QBeg + i*dQ );
    PDP1 := PBasePoints;
    Inc( PDP1, LastInd );
    PDP2 := PDP1;
    Inc(PDP2);
    DCoords[i] := N_SegmPoint( PDP1^, PDP2^, LastAlpha );
    if DAngles <> nil then
      DAngles[i] := N_SegmAngle( PDP1^, PDP2^ );
  end; // for i := 0 to ANumPoints-1 do
end; // procedure TN_CurveCoords.CalcCurve


//****************** TN_ShapeCoords class methods **********************

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\Create
//*************************************************** TN_ShapeCoords.Create ***
// TN_ShapeCoords class constructor
//
//     Parameters
// ANumBufs - initial number of float Points buffers (initial SCBufs length)
//
constructor TN_ShapeCoords.Create( ANumBufs: integer = 3 );
begin
  SetMinBufs( ANumBufs );
end; //*** end of Constructor TN_ShapeCoords.Create

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\Destroy
//************************************************** TN_ShapeCoords.Destroy ***
//
//
destructor TN_ShapeCoords.Destroy;
begin
  SCBufs := nil;
  Inherited;
end; //*** end of destructor TN_ShapeCoords.Destroy

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\Clear
//**************************************************** TN_ShapeCoords.Clear ***
// Clear Self Content beginning from given AInd (but not free memory)
//
//     Parameters
// AbegInd - given first Index of Bufs to clear
//
procedure TN_ShapeCoords.Clear( AbegInd: integer = 0 );
var
  i: integer;
begin
  for i := AbegInd to High(SCBufs) do
    with SCBufs[i] do
    begin
      BFCLength := 0;
      BFCType   := bfctEmpty;
    end; // for i := AbegInd to High(SCBufs) do

  if AbegInd = 0 then // Clear all bufs, not only additionally added
    SCBFreeInd := 0;
end; // procedure TN_ShapeCoords.Clear

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\SetMinBufs
//*********************************************** TN_ShapeCoords.SetMinBufs ***
// Increase SCBufs array if needed (so that Length(SCBufs) >= AMinBufs)
//
//     Parameters
// AMinBufs - minimal needed SCBufs array length
//
procedure TN_ShapeCoords.SetMinBufs( AMinBufs: integer );
var
  CurLeng: integer;
begin
  CurLeng := Length(SCBufs);

  if CurLeng < AMinBufs then // increasing is needed
  begin
    SetLength( SCBufs, AMinBufs );
    Clear( CurLeng ); // clear just added Bufs
  end;
end; // procedure TN_ShapeCoords.SetMinBufs

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\PrepBuf
//************************************************** TN_ShapeCoords.PrepBuf ***
// Prepare Buffer for at least given number of poits
//
//     Parameters
// ANumPoints - number of Points in buffer
// ABFCType   - coordinates type
// Result     - Returns prepared Buffer index
//
// Prepare Buffer (current or next) for at least ANumPoints, set BFCLength, 
// BFCType
//
function TN_ShapeCoords.PrepBuf( ANumPoints: integer;
                                             ABFCType: TN_BFCType ): integer;
var
  TmpInd: integer;
  CurBuf: boolean;
//  PointFlag: Char;
  PointFlag: byte;
begin
  //***** Check if current Buf can be used or new Buf should be created

  if Length(SCBufs) <= SCBFreeInd then // increase SCBufs
    SetMinBufs( SCBFreeInd + 3 );

  TmpInd := max( SCBFreeInd-1, 0 );

  with SCBufs[TmpInd] do
  begin

    if BFCType <> bfctEmpty then // cur Buf is not empty
    begin
      if (BFCType  <= bfctPolyDraw) and
         (ABFCType <= bfctPolyDraw)   then
        CurBuf := True
      else
        CurBuf := False;
    end else //********** BFCType = bfctEmpty, cur Buf is Empty, always use it
    begin
      CurBuf := True;
      if TmpInd = 0 then
        SCNewPenPos := True;
    end; // else BFCLength = 0

  end ; // with SCBufs[TmpInd] do

  if CurBuf then Result := TmpInd    // Current Buf
            else Result := TmpInd+1; // New Buf

  SCBFreeInd := Result + 1;

  with SCBufs[Result] do
  begin
    if CurBuf then // Prepare Place in Current Buf
    begin
      SCBegInd  := BFCLength;
      BFCLength := BFCLength + ANumPoints;
      if BFCType = bfctEmpty then
        BFCType := ABFCType;
      Assert( BFCType = ABFCType, 'Bad ABFCType!' );
    end else //******** Prepare New Buf
    begin
      SCBegInd  := 0;
      BFCType   := ABFCType;
      BFCLength := ANumPoints;
    end;

    //***** Here: Place is prepared, SCBegInd and ANumPoints are OK

    if Length(BFC) < BFCLength then // Increase BFC and BFCFlags arrays
    begin
      SetLength( BFC, BFCLength );
      SetLength( BFCFlags, BFCLength );
    end; // if Length(BFC) < ANumPoints then // Increase BFC and BFCFlags arrays

    if ABFCType < bfctPolyDraw then // fill Flags if needed
    begin
      if SCNewPenPos then // current Pen position should be changed
      begin
        PointFlag := PT_MOVETO;
        SCNewPenPos := False;
      end else //************ do not change current Pen Position
      begin
        if ABFCType = bfctPolyLine then PointFlag := PT_LINETO
                                   else PointFlag := PT_BEZIERTO;
      end;

      BFCFlags[SCBegInd] := PointFlag; // set flag for first point

      if ABFCType = bfctPolyLine then PointFlag := PT_LINETO
                                 else PointFlag := PT_BEZIERTO;

      if ANumPoints > 1 then // set flags for all other points (all except first)
        FillChar( BFCFlags[SCBegInd+1], ANumPoints-1, PointFlag );

    end; // if ABFCType < bfctPolyDraw then // fill Flags if needed

  end; // with SCBufs[Result] do

end; // function TN_ShapeCoords.PrepBuf

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\PrepWinGDIPath
//******************************************* TN_ShapeCoords.PrepWinGDIPath ***
// Prepare WinGDI Path in given WinGDI Device Context
//
//     Parameters
// AHDC       - handle to device context
// AShiftSize - all coordinates Shift Size
//
// Add all Polylines coordinates to SCIPoints, SCIFlags and prepare WinGDI Path 
// in given WinGDI Device Context
//
procedure TN_ShapeCoords.PrepWinGDIPath( AHDC: HDC; const AShiftSize: TFPoint );
var
  i, j, BegInd: integer;

  function PrepIntRect(): TRect; // local
  begin
    with SCBufs[i] do
    begin
      Result.Left   := Round( BFC[0].X + AShiftSize.X );
      Result.Top    := Round( BFC[0].Y + AShiftSize.Y );
      Result.Right  := Round( BFC[1].X + AShiftSize.X ) + 1;
      Result.Bottom := Round( BFC[1].Y + AShiftSize.Y ) + 1;
    end; // with SCBufs[AShapeInd] do
  end; // function PrepIntRect(); // local

begin
  Windows.BeginPath( AHDC );

  // Note: In SCIPoints, SCIFlags arrays accumulated all points in Path, except
  //       CloseFigure, Arc, Ellipse, RoundRect, for all Shape elements
  //       (now it is not neeeded, may be used later in some way)

  SCNumIPoints := 0; // Initial index for SCIPoints, SCIFlags arrays

  for i := 0 to SCBFreeInd-1 do // along all Shape elements
  with SCBufs[i] do
  begin
    if BFCType >= bfctCloseFigure then //*** CloseFigure, Arc, Ellipse or RoundRect
    begin                              //    (all except Polyline or PolyDraw)
      case BFCType of

      bfctCloseFigure:
        Windows.CloseFigure( AHDC );

      bfctArc: begin // ArcTo in any direction
        with PrepIntRect() do
          Windows.ArcTo( AHDC, Left, Top, Right, Bottom,
                                        Round( BFC[2].X ), Round( BFC[2].Y ),
                                        Round( BFC[3].X ), Round( BFC[3].Y ) );
      end; // bfctArc: begin

      bfctArcCW: begin // ArcTo in Clockwise direction
        Windows.SetArcDirection( AHDC, AD_CLOCKWISE );
        with PrepIntRect() do
          Windows.ArcTo( AHDC, Left, Top, Right, Bottom,
                                        Round( BFC[2].X ), Round( BFC[2].Y ),
                                        Round( BFC[3].X ), Round( BFC[3].Y ) );
      end; // bfctArc: begin

      bfctArcCounterCW: begin // ArcTo in CounterClockwise direction
        Windows.SetArcDirection( AHDC, AD_COUNTERCLOCKWISE );
        with PrepIntRect() do
          Windows.ArcTo( AHDC, Left, Top, Right, Bottom,
                                        Round( BFC[2].X ), Round( BFC[2].Y ),
                                        Round( BFC[3].X ), Round( BFC[3].Y ) );
      end; // bfctArc: begin

      bfctEllipse: begin
        with PrepIntRect() do
          Windows.Ellipse( AHDC, Left, Top, Right, Bottom );
      end; // bfctEllipse: begin

      bfctRoundRect: begin
        with PrepIntRect() do
          Windows.RoundRect( AHDC, Left, Top, Right, Bottom,
                                         Round( BFC[2].X ), Round( BFC[2].Y ) );
      end; // bfctRoundRect: begin

      end; // case BFCType of
    end else //************************************* Polyline or Polydraw
    begin
      BegInd := SCNumIPoints;
      Inc( SCNumIPoints, BFCLength );

      if Length(SCIPoints) < SCNumIPoints then
      begin
        SetLength( SCIPoints, N_NewLength( SCNumIPoints ) );
        SetLength( SCIFlags,  N_NewLength( SCNumIPoints ) );
      end;

      for j := BegInd to SCNumIPoints-1 do // Prepare Integer Points Coords
      begin
        SCIPoints[j].X := Round( BFC[j-BegInd].X + AShiftSize.X );
        SCIPoints[j].Y := Round( BFC[j-BegInd].Y + AShiftSize.Y );
      end; // for j := BegInd to SCNumIPoints-1 do // Prepare Integer Points Coords

      move( BFCFlags[0], SCIFlags[BegInd], SCNumIPoints-BegInd ); // Prepare Flags

      N_PolyDraw( AHDC, SCIPoints[BegInd], SCIFlags[BegInd], SCNumIPoints-BegInd ); // add to WinGDI Path

    end; // else //************************************* Polyline or Polydraw

  end; // with SCBufs[i] do, for i := 0 to SCBFreeInd-1 do // along all Shape elements

  Windows.EndPath( AHDC );
end; // procedure TN_ShapeCoords.PrepWinGDIPath

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\CloseShape
//*********************************************** TN_ShapeCoords.CloseShape ***
// Close current shape (add bfctCloseFigure Shape)
//
procedure TN_ShapeCoords.CloseShape();
var
  CurInd: integer;
begin
  CurInd := max( SCBFreeInd-1, 0 );

  with SCBufs[CurInd] do
  begin
    if (bfctPolyLine <= BFCType) and (BFCType <= bfctPolyDraw) then // flags exist
      BFCFlags[BFCLength-1] := BFCFlags[BFCLength-1] or PT_CLOSEFIGURE
    else
      PrepBuf( 0, bfctCloseFigure );
  end;
end; // procedure TN_ShapeCoords.CloseShape

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddOnePoint
//********************************************** TN_ShapeCoords.AddOnePoint ***
// Add to Self One Float Pixel Point
//
//     Parameters
// AFPoint - adding Float Pixel Point
//
procedure TN_ShapeCoords.AddOnePoint( const AFPoint: TFPoint );
begin
  with SCBufs[PrepBuf( 1, bfctPolyLine )] do
    BFC[SCBegInd] := AFPoint;
end; // procedure TN_ShapeCoords.AddOnePoint(FP)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddOneSegm
//*********************************************** TN_ShapeCoords.AddOneSegm ***
// Add to Self One Segment with two given Integer endpoints
//
//     Parameters
// AP1, AP2 - adding Segment Integer endpoints
//
procedure TN_ShapeCoords.AddOneSegm( const AP1, AP2: TPoint );
begin
  with SCBufs[PrepBuf( 2, bfctPolyLine )] do
  begin
    BFC[SCBegInd]   := FPoint( AP1 );
    BFC[SCBegInd+1] := FPoint( AP2 );
  end;
end; // procedure TN_ShapeCoords.AddOneSegm(2IP)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddSeparateSegm
//****************************************** TN_ShapeCoords.AddSeparateSegm ***
// Add to Self One Separate Segment with two given Integer endpoints
//
//     Parameters
// AP1, AP2 - adding Segment Integer endpoints
//
procedure TN_ShapeCoords.AddSeparateSegm( const AP1, AP2: TPoint );
begin
  with SCBufs[PrepBuf( 2, bfctPolyLine )] do
  begin
    SCNewPenPos := True;
    BFC[SCBegInd]   := FPoint( AP1 );
    BFC[SCBegInd+1] := FPoint( AP2 );
    SCNewPenPos := True;
  end;
end; // procedure TN_ShapeCoords.AddSeparateSegm(2IP)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddUserSepSegm
//******************************************* TN_ShapeCoords.AddUserSepSegm ***
// Add to Self One Separate Segment with two given double endpoints in User 
// Coordinates
//
//     Parameters
// ADP1, ADP2  - adding Segment Double endpoints in User coordinates
// APAffCoefs4 - pointer to Four Affine Transformation Coefficients from User 
//               coordinates to pixels
//
procedure TN_ShapeCoords.AddUserSepSegm( const ADP1, ADP2: TDPoint;
                                                  APAffCoefs4: TN_PAffCoefs4 );
begin
  with SCBufs[PrepBuf( 2, bfctPolyLine )] do
  begin
    SCNewPenPos := True;

    with APAffCoefs4^ do
    begin
      BFC[SCBegInd].X   := CX * ADP1.X + SX;
      BFC[SCBegInd].Y   := CY * ADP1.Y + SY;
      BFC[SCBegInd+1].X := CX * ADP2.X + SX;
      BFC[SCBegInd+1].Y := CY * ADP2.Y + SY;
    end;

    SCNewPenPos := True;
  end;
end; // procedure TN_ShapeCoords.AddUserSepSegm(2DP)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddPixPolyLine(Integer)
//********************************** TN_ShapeCoords.AddPixPolyLine(Integer) ***
// Add to Self Integer Pixel coordinates of given Polyline
//
//     Parameters
// APPoint    - pointer first Point of Integer Polyline
// ANumPoints - number of Points in adding Polyline
//
procedure TN_ShapeCoords.AddPixPolyLine( APPoint: PIPoint; ANumPoints: integer );
var
  i: integer;
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyLine )] do
  begin
    for i := SCBegInd to BFCLength-1 do
    begin
      BFC[i].X := APPoint^.X;
      BFC[i].Y := APPoint^.Y;
      Inc( APPoint );
    end;
  end;
end; // procedure TN_ShapeCoords.AddPixPolyLine(Integer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddPixPolyLine(Float)
//************************************ TN_ShapeCoords.AddPixPolyLine(Float) ***
// Add to Self Float Pixel coordinates of given Polyline
//
//     Parameters
// APFPoint   - pointer first Point of Float Polyline
// ANumPoints - number of Points in adding Polyline
//
procedure TN_ShapeCoords.AddPixPolyLine( APFPoint: PFPoint; ANumPoints: integer );
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyLine )] do
    move( APFPoint^, BFC[SCBegInd], ANumPoints*Sizeof(TFPoint) );
end; // procedure TN_ShapeCoords.AddPixPolyLine(Float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddPixPolyLine(Double)
//*********************************** TN_ShapeCoords.AddPixPolyLine(Double) ***
// Add to Self Double Pixel coordinates of given Polyline
//
//     Parameters
// APDPoint   - pointer first Point of Double Polyline
// ANumPoints - nuber of Points in adding Polyline
//
procedure TN_ShapeCoords.AddPixPolyLine( APDPoint: PDPoint; ANumPoints: integer );
var
  i: integer;
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyLine )] do
  begin
    for i := SCBegInd to BFCLength-1 do
    begin
      BFC[i].X := APDPoint^.X;
      BFC[i].Y := APDPoint^.Y;
      Inc( APDPoint );
    end;
  end;
end; // procedure TN_ShapeCoords.AddPixPolyLine(Double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddPixPolyDraw
//******************************************* TN_ShapeCoords.AddPixPolyDraw ***
// Add to Self given Integer Pixel coordinates with given Flags (in PolyDraw 
// format)
//
//     Parameters
// APPoint    - pointer first Point
// APFlags    - Windows GDI Points Flags, same as in Windows.PolyDraw
// ANumPoints - nuber of Points in adding Polyline
//
procedure TN_ShapeCoords.AddPixPolyDraw( APPoint: PPoint; APFlags: PByte;
                                                          ANumPoints: integer );
var
  i: integer;
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyDraw  )] do
  begin
    for i := SCBegInd to BFCLength-1 do
    begin
      BFC[i].X := APPoint^.X;
      BFC[i].Y := APPoint^.Y;
      BFCFlags[i] := APFlags^;

      Inc( APPoint );
      Inc( APFlags );
    end;
  end;
end; // procedure TN_ShapeCoords.AddPixPolyDraw(Integer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddUserPolyLine(Float)
//*********************************** TN_ShapeCoords.AddUserPolyLine(Float) ***
// Add to Self Float User coordinates of given Polyline
//
//     Parameters
// APFPoint    - pointer first Point of Float Polyline
// ANumPoints  - number of Points in adding Polyline
// APAffCoefs4 - pointer to Four Affine Transformation Coefficients from User 
//               coordinates to pixels
//
procedure TN_ShapeCoords.AddUserPolyLine( APFPoint: PFPoint; ANumPoints: integer;
                                                    APAffCoefs4: TN_PAffCoefs4 );
var
  i: integer;
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyLine )] do
  begin
    for i := SCBegInd to BFCLength-1 do
    with APAffCoefs4^ do
    begin
      BFC[i].X := CX * APFPoint^.X + SX;
      BFC[i].Y := CY * APFPoint^.Y + SY;
      Inc( APFPoint );
    end;
  end;
end; // procedure TN_ShapeCoords.AddUserPolyLine(Float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddUserPolyLine(Double)
//********************************** TN_ShapeCoords.AddUserPolyLine(Double) ***
// Add to Self Double User coordinates of given Polyline
//
//     Parameters
// APDPoint    - pointer first Point of Double Polyline
// ANumPoints  - number of Points in adding Polyline
// APAffCoefs4 - pointer to Four Affine Transformation Coefficients from User 
//               coordinates to pixels
//
procedure TN_ShapeCoords.AddUserPolyLine( APDPoint: PDPoint; ANumPoints: integer;
                                                    APAffCoefs4: TN_PAffCoefs4 );
var
  i: integer;
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyLine )] do
  begin
    for i := SCBegInd to BFCLength-1 do
    with APAffCoefs4^ do
    begin
      BFC[i].X := CX * APDPoint^.X + SX;
      BFC[i].Y := CY * APDPoint^.Y + SY;
      Inc( APDPoint );
    end;
  end;
end; // procedure TN_ShapeCoords.AddUserPolyLine(Double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddUserPolyLine(DoubleAC6)
//******************************* TN_ShapeCoords.AddUserPolyLine(DoubleAC6) ***
// Add to Self Double User coordinates of given PolyLine
//
//     Parameters
// APDPoint    - pointer first Point of Double Polyline
// ANumPoints  - number of Points in adding Polyline
// APAffCoefs6 - pointer to Six Affine Transformation Coefficients from User 
//               coordinates to pixels
//
procedure TN_ShapeCoords.AddUserPolyLine( APDPoint: PDPoint; ANumPoints: integer;
                                                    APAffCoefs6: TN_PAffCoefs6 );
var
  i: integer;
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyLine )] do
  begin
    for i := SCBegInd to BFCLength-1 do
    with APAffCoefs6^ do
    begin
      BFC[i].X := CXX * APDPoint^.X + CXY * APDPoint^.Y + SX;

      BFC[i].Y := CYX * APDPoint^.X + CYY * APDPoint^.Y + SY;
      Inc( APDPoint );
    end;
  end;
end; // procedure TN_ShapeCoords.AddUserPolyLine(DoubleAC6)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddPixPolyBezier(Float)
//********************************** TN_ShapeCoords.AddPixPolyBezier(Float) ***
// Add to Self Float Pixel coordinates of given PolyBezier
//
//     Parameters
// APFPoint   - pointer first Point of Float PolyBezier
// ANumPoints - number of Points in adding PolyBezier
//
procedure TN_ShapeCoords.AddPixPolyBezier( APFPoint: PFPoint; ANumPoints: integer );
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyBezier )] do
    move( APFPoint^, BFC[SCBegInd], Sizeof(TFPoint) );
end; // procedure TN_ShapeCoords.AddPixPolyBezier(Float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddPixPolyBezier(Double)
//********************************* TN_ShapeCoords.AddPixPolyBezier(Double) ***
// Add to Self Double Pixel Relative to APBasePoint^ coordinates of given 
// PolyBezier
//
//     Parameters
// APDPoint   - pointer first Point of Double PolyBezier
// ANumPoints - number of Points in adding PolyBezier
//
procedure TN_ShapeCoords.AddPixPolyBezier( APDPoint: PDPoint; ANumPoints: integer );
var
  i: integer;
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyBezier )] do
  begin
    for i := SCBegInd to BFCLength-1 do
    begin
      BFC[i].X := APDPoint^.X;
      BFC[i].Y := APDPoint^.Y;
      Inc( APDPoint );
    end;
  end;
end; // procedure TN_ShapeCoords.AddPixPolyBezier(Double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddUserPolyBezier(Float)
//********************************* TN_ShapeCoords.AddUserPolyBezier(Float) ***
// Add to Self Float User coordinates of given PolyBezier
//
//     Parameters
// APFPoint    - pointer first Point of Float PolyBezier
// ANumPoints  - number of Points in adding PolyBezier
// APAffCoefs4 - pointer to Four Affine Transformation Coefficients from User 
//               coordinates to pixels
//
procedure TN_ShapeCoords.AddUserPolyBezier( APFPoint: PFPoint; ANumPoints: integer;
                                                   APAffCoefs4: TN_PAffCoefs4 );
var
  i: integer;
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyBezier )] do
  begin
    for i := SCBegInd to BFCLength-1 do
    with APAffCoefs4^ do
    begin
      BFC[i].X := CX * APFPoint^.X + SX;
      BFC[i].Y := CY * APFPoint^.Y + SY;
      Inc( APFPoint );
    end;
  end;
end; // procedure TN_ShapeCoords.AddUserPolyBezier(Float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddUserPolyBezier(Double)
//******************************** TN_ShapeCoords.AddUserPolyBezier(Double) ***
// Add to Self Double User coordinates of given PolyBezier
//
//     Parameters
// APDPoint    - pointer first Point of Double PolyBezier
// ANumPoints  - number of Points in adding PolyBezier
// APAffCoefs4 - pointer to Four Affine Transformation Coefficients from User 
//               coordinates to pixels
//
procedure TN_ShapeCoords.AddUserPolyBezier( APDPoint: PDPoint; ANumPoints: integer;
                                                   APAffCoefs4: TN_PAffCoefs4 );
var
  i: integer;
begin
  with SCBufs[PrepBuf( ANumPoints, bfctPolyBezier )] do
  begin
    for i := SCBegInd to BFCLength-1 do
    with APAffCoefs4^ do
    begin
      BFC[i].X := CX * APDPoint^.X + SX;
      BFC[i].Y := CY * APDPoint^.Y + SY;
      Inc( APDPoint );
    end;
  end;
end; // procedure TN_ShapeCoords.AddUserPolyBezier(Double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddEllipse
//*********************************************** TN_ShapeCoords.AddEllipse ***
// Add to Self Ellipse
//
//     Parameters
// AEnvRect - adding Ellipse
//
procedure TN_ShapeCoords.AddEllipse( const AEnvRect: TFRect );
begin
  if N_WinNTGDI then
    AddEllipseNative( AEnvRect );
//  else
    // not implemented

  SCNewPenPos := True;
end; // procedure TN_ShapeCoords.AddEllipse

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddEllipseNative
//***************************************** TN_ShapeCoords.AddEllipseNative ***
// Add to Self Ellipse Float Rectangle
//
//     Parameters
// AEnvRect - adding Ellipse Float Rectangle
//
procedure TN_ShapeCoords.AddEllipseNative( const AEnvRect: TFRect );
begin
  with SCBufs[PrepBuf( 2, bfctEllipse )] do
  begin
    BFC[0] := AEnvRect.TopLeft;
    BFC[1] := AEnvRect.BottomRight;
  end;
end; // procedure TN_ShapeCoords.AddEllipseNative

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddRoundRect
//********************************************* TN_ShapeCoords.AddRoundRect ***
// Add to Self Round Rectangle
//
//     Parameters
// AEnvRect      - Envelope Float Rectangle
// ARoundEllSize - adding Rectangle corner Ellipses Flost Size
//
procedure TN_ShapeCoords.AddRoundRect( const AEnvRect: TFRect;
                                                 const ARoundEllSize: TFPoint );
begin
  if N_WinNTGDI then
    AddRoundRectNative( AEnvRect, ARoundEllSize );
//  else
    // not implemented

  SCNewPenPos := True;
end; // procedure TN_ShapeCoords.AddRoundRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddRoundRectNative
//*************************************** TN_ShapeCoords.AddRoundRectNative ***
// Add to Self RoundRect Float Rect and Rounding Ellipse X,Y sizex
//
//     Parameters
// AEnvRect      - Envelope Float Rectangle
// ARoundEllSize - adding Rectangle corner Ellipses Flost Size
//
procedure TN_ShapeCoords.AddRoundRectNative( const AEnvRect: TFRect;
                                             const ARoundEllSize: TFPoint );
begin
  with SCBufs[PrepBuf( 3, bfctRoundRect )] do
  begin
    BFC[0] := AEnvRect.TopLeft;
    BFC[1] := AEnvRect.BottomRight;
    BFC[2] := ARoundEllSize;
  end;
end; // procedure TN_ShapeCoords.AddRoundRectNative

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddArc
//*************************************************** TN_ShapeCoords.AddArc ***
// Add to Self Arc
//
//     Parameters
// AEnvRect  - Arc envelope Rect
// ABegAngle - Arc start angle (float)
// AArcAngle - Arc angle (float)
//
// AEnvRect should be rounded, Arc is Drawn always Counterclockwise! Positive 
// Angle is Counterclockwise in Pixel coordinates ("Left" coordinates space)
//
procedure TN_ShapeCoords.AddArc( const AEnvRect: TFRect;
                                                 ABegAngle, AArcAngle: float );
begin
  if N_WinNTGDI then
    AddArcNative( AEnvRect, ABegAngle, AArcAngle )
  else
    // not implemented
end; // procedure TN_ShapeCoords.AddArc

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddArcNative
//********************************************* TN_ShapeCoords.AddArcNative ***
// Add to Self Arc EnvRect and Beg and End Arc points
//
//     Parameters
// AEnvRect  - Arc envelope Rect
// ABegAngle - Arc start angle (float)
// AArcAngle - Arc angle (float)
//
// AEnvRect should be rounded, Positive Angle is Counterclockwise in Pixel 
// (Left!) coordinates space
//
procedure TN_ShapeCoords.AddArcNative( const AEnvRect: TFRect;
                                             ABegAngle, AArcAngle: float );
var
  BegArcPoint, EndArcPoint: TFPoint;
  ArcType: TN_BFCType;
begin
  ABegAngle := N_Get0360Angle( ABegAngle );

  BegArcPoint := N_EllipsePoint( AEnvRect, ABegAngle );
  EndArcPoint := N_EllipsePoint( AEnvRect, ABegAngle + AArcAngle );
  AddOnePoint( BegArcPoint );

  if AArcAngle >=360 then // full ellipse
  begin
    AddEllipseNative( AEnvRect );
//    SCNewPenPos := True;
    Exit; // all done
  end; // if (AArcAngle = 0) or (AArcAngle >=360) then // full ellipse

  if N_Same( BegArcPoint, EndArcPoint ) then Exit; // Arc consists of one point

  if AArcAngle > 0 then ArcType := bfctArcCounterCW
                   else ArcType := bfctArcCW;

  with SCBufs[PrepBuf( 4, ArcType )] do // set GDI Arc Params
  begin
    BFC[0] := AEnvRect.TopLeft;
    BFC[1] := AEnvRect.BottomRight;
    BFC[2] := BegArcPoint;
    BFC[3] := EndArcPoint;
  end;

{
var
  AlfaBeg, AlfaEnd: double;
  BegArcPoint, EndArcPoint: TFPoint;

  // in Win98 GDI Arc is Drawn always Counterclockwise, so additional
  // MOVETO, LINETO commands should be added if given Arc is Clockwise (AArcAngle < 0)

  if AArcAngle >= 0 then
  begin
    AlfaBeg := ABegAngle;
    AlfaEnd := ABegAngle + AArcAngle;
  end else
  begin
    AlfaEnd := ABegAngle;
    AlfaBeg := ABegAngle + AArcAngle;
  end;

  BegArcPoint := N_EllipsePoint( AEnvRect, AlfaBeg );
  EndArcPoint := N_EllipsePoint( AEnvRect, AlfaEnd );

  if SCNewPenPos then // begin new Path fragment
    AddOnePoint( BegArcPoint ) // add MoveTo command to BegArcPoint
  else //*************** continue current Path fragment
  begin
    if AArcAngle < 0 then // Clockwise Arc, add additional commands
    begin
      AddOnePoint( EndArcPoint ); // LINETO to EndArcPoint
      SCNewPenPos := True;
      AddOnePoint( BegArcPoint ); // add MoveTo command to BegArcPoint
    end; // if AArcAngle < 0 then // Clockwise Arc
  end; // else - continue current Path fragment

  with SCBufs[PrepBuf( 4, bfctArc )] do // set GDI Arc Params
  begin
    BFC[0] := AEnvRect.TopLeft;
    BFC[1] := AEnvRect.BottomRight;
    BFC[2] := BegArcPoint;
    BFC[3] := EndArcPoint;
  end;

  if AArcAngle < 0 then // Clockwise Arc, add additional commands
  begin
    SCNewPenPos := True;
    AddOnePoint( BegArcPoint ); // add MoveTo command to BegArcPoint
  end; // if AArcAngle < 0 then
}
end; // procedure TN_ShapeCoords.AddArcNative

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddRegPolyFragm
//****************************************** TN_ShapeCoords.AddRegPolyFragm ***
// Add to Self coordinates of Regular Polygon Fragment (PieSegm, Chord or 
// ArcOnly)
//
//     Parameters
// AEnvRect   - regular Polygon Envelope Rect
// AShapeType - Arc borders type enumeration
// AArcAngle  - = 0 means that AArcAngle = 360 degree (RegPolyArc is full 
//              regular polygon)
// Positive   - Angle is counterclockwise in Pixel (Left!) coordinates space
//
procedure TN_ShapeCoords.AddRegPolyFragm( const AEnvRect: TFRect; AShapeType: TN_ArcBorderType;
                           ABegAngle, AArcAngle: float; ANumSegments: integer );
var
  i, NumPoints: integer;
  RX, RY, Angle, Alfa: double;
  Center: TDPoint;
begin
  if ANumSegments < 1 then ANumSegments := 1;

  NumPoints := ANumSegments + 1;

  Angle := AArcAngle;
  if (Angle = 0) or (Angle > 360) then Angle := 360;

  if Angle <> 360 then // not full Polygon
  begin
    case AShapeType of
      abtPieSegment: Inc( NumPoints, 2 );
      abtChord:      Inc( NumPoints, 1 );
    end;
  end; // if Angle <> 360 then

  Center := N_RectCenter( AEnvRect );

  RX := Center.X - AEnvRect.Left;
  RY := Center.Y - AEnvRect.Top;

  if (AShapeType <> abtArcOnly) and (Angle <> 360) then
    SCNewPenPos := True;

  with SCBufs[PrepBuf( NumPoints, bfctPolyLine )] do
  begin

  for i := SCBegInd to SCBegInd+ANumSegments do // Regular Polygon Vertexes
  begin
    Alfa := N_PI*(ABegAngle + i*Angle/ANumSegments)/180.0;
    BFC[i].X := Round( Center.X + RX*cos(Alfa) );
    BFC[i].Y := Round( Center.Y - RY*Sin(Alfa) ); // as in Win GDI
  end;

  if Angle <> 360 then // add one or two additional segment
  case AShapeType of

    abtPieSegment: begin // RegPoly Shape is RegPoly Pie Segment
      BFC[SCBegInd+ANumSegments+1] := FPoint( Center );
      BFC[SCBegInd+ANumSegments+2] := BFC[SCBegInd];
    end; // abtPieSegment: begin

    abtChord: begin // RegPoly Shape is RegPoly Chord
      BFC[SCBegInd+ANumSegments+1] := BFC[SCBegInd];
    end; // abtChord: begin

  end; // case AShapeType of, if (AArcAngle <> 0) and (AArcAngle <> 360) then

  end; // with SCBufs[PrepBuf( NumPoints, bfctPolyLine )] do

  if (AShapeType <> abtArcOnly) or (Angle <> 360) then // Closed Shape
  begin
    CloseShape();
    SCNewPenPos := True;
  end;

end; // procedure TN_ShapeCoords.AddRegPolyFragm

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddEllipseFragm
//****************************************** TN_ShapeCoords.AddEllipseFragm ***
// Add to Self coordinates of Elipse Fragment (PieSegm, Chord or ArcOnly)
//
//     Parameters
// AEnvRect   - Elipse Envelope Rect
// AShapeType - Shape Type (PieSegment, Chord, ArcOnly)
// ABegAngle  - Arc start angle
// AArcAngle  - Arc angle (= 0 means that Arc angle = 360 degree (full 
//              ellipse)). Positive Angle is counterclockwise in Pixel (Left!) 
//              coordinates space
//
procedure TN_ShapeCoords.AddEllipseFragm( const AEnvRect: TFRect;
                    AShapeType: TN_ArcBorderType; ABegAngle, AArcAngle: float );
begin
  if (AShapeType <> abtArcOnly) and (AArcAngle <> 360) then
    SCNewPenPos := True;

  AddArc( AEnvRect, ABegAngle, AArcAngle );

  if (AArcAngle = 0) or (AArcAngle > 360) then Exit; // all done

  case AShapeType of

    abtPieSegment: begin // RegPoly Shape is RegPoly Pie Segment
      AddOnePoint( FPoint(N_RectCenter( AEnvRect )) );
      AddOnePoint( N_EllipsePoint( AEnvRect, ABegAngle ) );
    end; // abtPieSegment: begin

    abtChord: begin // RegPoly Shape is RegPoly Chord
      AddOnePoint( N_EllipsePoint( AEnvRect, ABegAngle ) );
    end; // abtChord: begin

  end; // case AShapeType of

  if (AShapeType <> abtArcOnly) or (AArcAngle = 360) then // Closed Shape
  begin
    CloseShape();
    SCNewPenPos := True;
  end;
end; // procedure TN_ShapeCoords.AddEllipseFragm

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\TN_ShapeCoords\AddCilinderFragm
//***************************************** TN_ShapeCoords.AddCilinderFragm ***
// Add to Self coordinates of visible Cilinder vertical side Fragment
//
//     Parameters
// AEnvRect  - Elipse Envelope Rect
// ABegAngle - Cilinder start angle
// AArcAngle - Cilinder angle (= 0 means that Cilinder angle = 360 degree (full 
//             Cilinder)).
// AVSHeight - Vertcal Side Heigth, should be rounded
//
// Visible are Angles from 180 to 360 degree, may have two disconected fragments
//
procedure TN_ShapeCoords.AddCilinderFragm( const AEnvRect: TFRect;
                              ABegAngle, AArcAngle: float; AVSHeight: float );
var
  BegPoint, EndPoint: TFPoint;
  EnvRect2: TFRect;
begin
  if AArcAngle < 0 then // force AArcAngle > 0
  begin
    AArcAngle := -AArcAngle;
    ABegAngle := ABegAngle - AArcAngle;
  end;

  if AArcAngle > 360 then AArcAngle := 360; // full Vert Side

  ABegAngle := N_Get0360Angle( ABegAngle );

  if ABegAngle < 180 then
  begin
    AArcAngle := AArcAngle - (180 - ABegAngle);
    ABegAngle := 180;
  end;

  if AArcAngle <= 0 then Exit; // no "vertical side Fragment", nothig to add

  if (ABegAngle + AArcAngle) > 540 then // two disconected fragments, call self twice
  begin
    AddCilinderFragm( AEnvRect, ABegAngle, 360 - ABegAngle, AVSHeight );
    SCNewPenPos := True;
    AddCilinderFragm( AEnvRect, 180, ABegAngle+AArcAngle-540, AVSHeight );
  end else //********************************* one fragment, process it
  begin
    if (ABegAngle + AArcAngle) > 360 then
      AArcAngle := 360 - ABegAngle;

    //***** Here: 180 <= ABegAngle, ABegAngle+AArcAngle <= 360
    //              0 <= AArcAngle <= 180

    AddArc( AEnvRect, ABegAngle, AArcAngle ); // first Arc

    EndPoint := N_EllipsePoint( AEnvRect, ABegAngle+AArcAngle );
    EndPoint.Y := EndPoint.Y + AVSHeight;

    AddOnePoint( EndPoint ); // LineTo to second Arc
    EnvRect2 := N_RectShift( AEnvRect, 0, AVSHeight );
    AddArc( EnvRect2, ABegAngle+AArcAngle, -AArcAngle ); // second Arc in shifted EnvRect2

    BegPoint := N_EllipsePoint( AEnvRect, ABegAngle );
    AddOnePoint( BegPoint ); // LineTo to first Arc
    CloseShape();
  end; // else - one fragment, process it

end; // procedure TN_ShapeCoords.AddCilinderFragm

{
//******************************************** TN_ShapeCoords.AddSmallArc ***
// Add to Self one Bezier segment that approximate given Arc
// if last point in BFC is same as first Arc point, only three points are
// added (two control and last Arc point), otherwise - four
//
procedure TN_ShapeCoords.AddSmallArc( const ACenter, ARad: TFPoint;
                                                  ABegAngle, AArcAngle: float );
var
  i: integer;
  BegPoint: TFPoint;
  A, B, C, S, CC, X, Y: double;

  XY: array [0..7] of double;

  function GetPoint( j: integer ): TFPoint; // local
  begin
    Result.X := ACenter.X + Round( XY[j*2]*CC - XY[j*2+1]*S );
    Result.Y := ACenter.Y + Round( (XY[j*2]*S  + XY[j*2+1]*CC)*ARad.Y/ARad.X );
  end; // local

begin
  if abs(AArcAngle) < 0.01 then // a precaution
  begin
    PrepBuf( 0, bfctPolyDraw );
    Exit;
  end;

//  B := ARY * sin( -AArcAngle * N_PI / 180 );
  B := ARad.X * sin( -AArcAngle * N_PI / 180 );
  C := ARad.X * cos( -AArcAngle * N_PI / 180 );
  A := ARad.X - C;

  X := A * 4 / 3;
  Y := B - X * (ARad.X - A) / B;

  S  := sin( -(ABegAngle + 0.5*AArcAngle) * N_PI / 180 );
  CC := cos( -(ABegAngle + 0.5*AArcAngle) * N_PI / 180 );

  XY[0] := C;
  XY[1] := -B;
  XY[2] := C + X;
  XY[3] := -Y;
  XY[4] := C + X;
  XY[5] := Y;
  XY[6] := C;
  XY[7] := B;

  BegPoint := GetPoint( 0 );

  with SCBufs[PrepBuf( 4, bfctPolyDraw )] do
  begin

    if SCBegInd = 0 then // add BegPoint
    begin
      BFC[SCBegInd] := BegPoint;
      BFCFlags[SCBegInd] := PT_BEZIERTO;
      Inc(SCBegInd);
    end else // SCBegInd > 0, check if BFC[SCBegInd-1] (last point) is same as BegPoint
    begin
      if (abs(BFC[SCBegInd-1].X - BegPoint.X) > 1.0e-3) or
         (abs(BFC[SCBegInd-1].Y - BegPoint.Y) > 1.0e-3)  then // last point <> BegPoint
      begin
        BFC[SCBegInd] := BegPoint;
        BFCFlags[SCBegInd] := PT_BEZIERTO;
        Inc(SCBegInd);
      end;
    end;

    for i := 1 to 3 do
    begin
      BFC[SCBegInd+i-1] := GetPoint( i );
      BFCFlags[SCBegInd+i-1] := PT_BEZIERTO;
    end; // for i := 1 to 3 do

    BFCLength := SCBegInd + 3;

  end; // with SCBufs[PrepBuf( 4, bfctPolyDraw )] do
end; // procedure TN_ShapeCoords.AddSmallArc

//*************************************************** TN_ShapeCoords.AddArc ***
// Add to Self several Bezier segments that approximate given Arc
// if last point in BFC is same as first Arc point, it is not duplicated
//
procedure TN_ShapeCoords.AddArc( const ACenter, ARad: TFPoint;
                                                  ABegAngle, AArcAngle: float );
var
  i, NumArcs: integer;
  SavedMode: boolean;
  Center: TFPoint;
begin
  SavedMode := SCCurBuf;

  with SCBufs[PrepBuf( 0, bfctPolyDraw )] do
  begin
    SCCurBuf := True;

    Center.X := Round( ACenter.X );
    Center.Y := Round( ACenter.Y );

    if abs(AArcAngle) <= N_MaxArcAngle then // one small Arc
      AddSmallArc( Center, ARad, ABegAngle, AArcAngle )
    else //*********************************** several small Arcs
    begin
      NumArcs := Round( Floor( abs(AArcAngle) / N_MaxArcAngle ) );

      for i := 0 to NumArcs-1 do
      begin
        AddSmallArc( Center, ARad, ABegAngle + i*(AArcAngle/NumArcs), AArcAngle/NumArcs );
      end;

    end; // else - several small Arcs

  end; // with SCBufs[PrepBuf( 0, bfctPolyDraw )] do

  SCCurBuf := SavedMode; // restore
end; // procedure TN_OCanvas.AddArc
}


//****************** Global Procedures and Functions **********************

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SegmPoint(FPoint)
//***************************************************** N_SegmPoint(FPoint) ***
// Calculate Point coordinates on strait line given by segment (by two Float 
// Points)
//
//     Parameters
// AP1, AP2 - given segment Float end Points [AP1,AP2]
// Alpha    - given Point position coefficient
// Result   - Returns resulting Float Point coordinates
//
// Position coefficient Alpha can have any value and is used in the following 
// way:
//#N
// Alpha = 0   - resulting point is equal to AP1
// Alpha = 0.5 - resulting point is in the middle between AP1 and AP2
// Alpha = 1   - resulting point is equal to AP2
//#/N
//
function N_SegmPoint( const AP1, AP2: TFPoint; Alpha: double ): TFPoint;
var
  Beta: double;
begin
  Beta := 1.0 - Alpha;
  Result.X := AP1.X*Beta + AP2.X*Alpha;
  Result.Y := AP1.Y*Beta + AP2.Y*Alpha;
end; // end of function N_SegmPoint(FPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SegmPoint(DPoint)
//***************************************************** N_SegmPoint(DPoint) ***
// Calculate Point coordinates on strait line given by segment (by two Double 
// Points)
//
//     Parameters
// AP1, AP2 - given segment end Double Points [AP1,AP2]
// Alpha    - given Point position coefficient
// Result   - Returns given double Point coordinates
//
// Position coefficient Alpha is used in the following way:
//#N
// Alpha = 0   - resulting point is equal to AP1
// Alpha = 0.5 - resulting point is in the middle between AP1 and AP2
// Alpha = 1   - resulting point is equal to AP2
//#/N
//
function N_SegmPoint( const AP1, AP2: TDPoint; Alpha: double ): TDPoint;
var
  Beta: double;
begin
  Beta := 1.0 - Alpha;
  Result.X := AP1.X*Beta + AP2.X*Alpha;
  Result.Y := AP1.Y*Beta + AP2.Y*Alpha;
end; // end of function N_SegmPoint(DPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SegmAngle(two_FPoints)
//************************************************ N_SegmAngle(two FPoints) ***
// Calculate Angle in degree between given Segment and X axis
//
//     Parameters
// AP1    - first (starting) Segment Point
// AP2    - second (ending) Segment Point
// Result - Returns calculated angle in degree
//
// X axis direction is from left to right, Y axis direction is from top to down
// CCW (Counter ClockWise) angle direction from X axis assumed to be positive.
//#F
// For AP1=(0,0), AP2=( 1, 0) Result =   0
// For AP1=(0,0), AP2=( 0,-1) Result = +90
// For AP1=(0,0), AP2=( 0, 1) Result = -90
// For AP1=(0,0), AP2=( 1, 1) Result = -45
// For AP1=(0,0), AP2=(-1, 1) Result = -135
// For AP1=(0,0), AP2=( 1,-1) Result = +45
// For AP1=(0,0), AP2=(-1,-1) Result = +135
//#/F
//
function N_SegmAngle( const AP1, AP2: TFPoint ): double;
var
  dx, dy: double;
begin
  dx := AP2.X - AP1.X;
  dy := AP1.Y - AP2.Y;

  if abs(dx) < 1.0e-10 then
    Result := 90.0*sign( dy )
  else
    Result := arctan2( dy, dx )*180/N_PI;
end; // end of function N_SegmAngle(two Foints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SegmAngle(two_DPoints)
//************************************************ N_SegmAngle(two DPoints) ***
// Calculate Angle in degree between given Segment and X axis
//
//     Parameters
// AP1    - first (starting) Segment Point
// AP2    - second (ending) Segment Point
// Result - Returns calculated angle in degree
//
// X axis direction is from left to right, Y axis direction is from top to down
// CCW (Counter ClockWise) angle direction from X axis assumed to be positive.
//#F
// For AP1=(0,0), AP2=( 1, 0) Result =   0
// For AP1=(0,0), AP2=( 0,-1) Result = +90
// For AP1=(0,0), AP2=( 0, 1) Result = -90
// For AP1=(0,0), AP2=( 1, 1) Result = -45
// For AP1=(0,0), AP2=(-1, 1) Result = -135
// For AP1=(0,0), AP2=( 1,-1) Result = +45
// For AP1=(0,0), AP2=(-1,-1) Result = +135
//#/F
//
function N_SegmAngle( const AP1, AP2: TDPoint ): double;
var
  dx, dy: double;
begin
  dx := AP2.X - AP1.X;
  dy := AP1.Y - AP2.Y;

  if abs(dx) < 1.0e-10 then
    Result := 90.0*sign( dy )
  else
    Result := arctan2( dy, dx )*180/N_PI;
end; // end of function N_SegmAngle(two Doints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SegmAngle(three_DPoints)
//********************************************** N_SegmAngle(three DPoints) ***
// Calculate Angle in degree between [AP2,AP3] and [AP1,AP2] segments given by
// three Points
//
//     Parameters
// AP1, AP2, AP3 - given segments end Points [AP1,AP2] and [AP2,AP3]
// Result        - Returns angle between given segments in degree
//
// X axis direction is from left to right, Y axis direction is from top to down
// CCW (counter Clowise) angle direction from X axis assumed to be positive. For
// AP1=(1,1), AP2=(0,0), AP2=(1,-1) Result = +90
//
function N_SegmAngle( const AP1, AP2, AP3: TDPoint ): double;
begin
  Result := N_SegmAngle( AP2, AP3 ) - N_SegmAngle( AP2, AP1 );
end; // end of function N_SegmAngle(three DPoints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\D3PReper(six_Doubles)
//*************************************************** D3PReper(six Doubles) ***
// Convert 3 Points double coordinates to TN_3DPReper record (Three Double 
// Points Reper)
//
//     Parameters
// ADX1, AdY1 - first Point double coordinates
// ADX2, ADY2 - second Point double coordinates
// ADX3, ADY3 - third Point double coordinates
// Result     - Returns TN_3DPReper record
//
function D3PReper( const ADX1, ADY1, ADX2, ADY2, ADX3, ADY3: double ): TN_3DPReper;
begin
  Result.P1.X := ADX1;
  Result.P1.Y := ADY1;
  Result.P2.X := ADX2;
  Result.P2.Y := ADY2;
  Result.P3.X := ADX3;
  Result.P3.Y := ADY3;
end; // end of function D3PReper(6Double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\D3PReper(Rect)
//********************************************************** D3PReper(Rect) ***
// Convert Integer Rectangle to TN_3DPReper record (Three Double Points Reper)
//
//     Parameters
// ARect  - given Integer Rectangle
// Result - Returns TN_3DPReper record
//
// TN_3DPReper first Point is set to Rectangle top left corner, second Point to 
// Rectangle top right corner, third Point to Rectangle bottom left corner.
//
function D3PReper( const ARect: TRect ): TN_3DPReper;
begin
  with ARect do
  begin
    Result.P1.X := ARect.Left;
    Result.P1.Y := ARect.Top;
    Result.P2.X := ARect.Right;
    Result.P2.Y := ARect.Top;
    Result.P3.X := ARect.Left;
    Result.P3.Y := ARect.Bottom;
  end;
end; // end of function D3PReper(IRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\D3PReper(FRect)
//********************************************************* D3PReper(FRect) ***
// Convert Float Rectangle to TN_3DPReper record (Three Double Points Reper)
//
//     Parameters
// AFRect - given Float Rectangle
// Result - Returns TN_3DPReper record
//
// TN_3DPReper first Point is set to Rectangle top left corner, second Point to 
// Rectangle top right corner, third Point to Rectangle bottom left corner.
//
function D3PReper( const AFRect: TFRect ): TN_3DPReper;
begin
  with AFRect do
  begin
    Result.P1.X := Left;
    Result.P1.Y := Top;
    Result.P2.X := Right;
    Result.P2.Y := Top;
    Result.P3.X := Left;
    Result.P3.Y := Bottom;
  end;
end; // end of function D3PReper(FRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\D3PReper(DRect)
//********************************************************* D3PReper(DRect) ***
// Convert Double Rectangle to TN_3DPReper record (Three Double Points Reper)
//
//     Parameters
// ADRect - given Double Rectangle
// Result - Returns TN_3DPReper record
//
// TN_3DPReper first Point is set to Rectangle top left corner, second Point to 
// Rectangle top right corner, third Point to Rectangle bottom left corner.
//
function D3PReper( const ADRect: TDRect ): TN_3DPReper;
begin
  with ADRect do
  begin
    Result.P1.X := Left;
    Result.P1.Y := Top;
    Result.P2.X := Right;
    Result.P2.Y := Top;
    Result.P3.X := Left;
    Result.P3.Y := Bottom;
  end;
end; // end of function D3PReper(DRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Conv3DPReperTo3PReper
//************************************************* N_Conv3DPReperTo3PReper ***
// Convert TN_3DPReper record (Three Double Points Reper) to TN_3PReper record 
// (Three (Integer) Points Reper)
//
//     Parameters
// AP3DPReper - given Pointer to 3DPReper
// AP3PReper  - given Pointer to 3PReper
//
procedure N_Conv3DPReperTo3PReper( AP3DPReper: TN_P3DPReper; AP3PReper: TN_P3PReper );
begin
  AP3PReper^.P1.X := Round( AP3DPReper^.P1.X );
  AP3PReper^.P1.Y := Round( AP3DPReper^.P1.Y );
  AP3PReper^.P2.X := Round( AP3DPReper^.P2.X );
  AP3PReper^.P2.Y := Round( AP3DPReper^.P2.Y );
  AP3PReper^.P3.X := Round( AP3DPReper^.P3.X );
  AP3PReper^.P3.Y := Round( AP3DPReper^.P3.Y );
end; // end of procedure N_Conv3DPReperTo3PReper

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Add2P(two_Points)
//***************************************************** N_Add2P(two Points) ***
// Add two given Integer Points
//
//     Parameters
// APoint1 - first Point
// APoint2 - second Point
// Result  - Returns Integer Point equals to sum of two given Integer Points
//
function N_Add2P( const APoint1, APoint2: TPoint ): TPoint;
begin
  Result.X := APoint1.X + APoint2.X;
  Result.Y := APoint1.Y + APoint2.Y;
end; // end of function N_Add2P(Int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Add2P(two_FPoints)
//**************************************************** N_Add2P(two FPoints) ***
// Add coordinates of two given Float Points
//
//     Parameters
// ADPoint1 - first given Point
// ADPoint2 - second given Point
// Result   - Returns Float Point equals to sum of two given Float Points
//
function N_Add2P( const AFPoint1, AFPoint2: TFPoint ): TFPoint;
begin
  Result.X := AFPoint1.X + AFPoint2.X;
  Result.Y := AFPoint1.Y + AFPoint2.Y;
end; // end of function N_Add2P(two FPoints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Add2P(two_DPoints)
//**************************************************** N_Add2P(two DPoints) ***
// Add coordinates of two given Double Points
//
//     Parameters
// ADPoint1 - first given Point
// ADPoint2 - second given Point
// Result   - Returns Double Point equals to sum of two given Double Points
//
function N_Add2P( const ADPoint1, ADPoint2: TDPoint ): TDPoint;
begin
  Result.X := ADPoint1.X + ADPoint2.X;
  Result.Y := ADPoint1.Y + ADPoint2.Y;
end; // end of function N_Add2P(two DPoints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Substr2P(two_Points)
//************************************************** N_Substr2P(two Points) ***
// Subtract two given Integer Points
//
//     Parameters
// APoint1 - minuend Point
// APoint2 - subtrahend Point
// Result  - Returns Integer Point equals to difference of two Integer Points (=
//           APoint1 - APoint2)
//
function N_Substr2P( const APoint1, APoint2: TPoint ): TPoint;
begin
  Result.X := APoint1.X - APoint2.X;
  Result.Y := APoint1.Y - APoint2.Y;
end; // end of function N_Substr2P(Int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Substr2P(two_FPoints)
//************************************************* N_Substr2P(two FPoints) ***
// Subtract two given Float Points
//
//     Parameters
// AFPoint1 - minuend Point
// AFPoint2 - subtrahend Point
// Result   - Returns Float Point equals to difference of two Float Points (= 
//            AFPoint1 - AFPoint2)
//
function N_Substr2P( const AFPoint1, AFPoint2: TFPoint ): TFPoint;
begin
  Result.X := AFPoint1.X - AFPoint2.X;
  Result.Y := AFPoint1.Y - AFPoint2.Y;
end; // end of function N_Substr2P(Float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Substr2P(two_DPoints)
//************************************************* N_Substr2P(two DPoints) ***
// Subtract two given Double Points
//
//     Parameters
// ADPoint1 - minuend Point
// ADPoint2 - subtrahend Point
// Result   - Returns Double Point equals to difference of two Double Points (= 
//            ADPoint1 - ADPoint2)
//
function N_Substr2P( const ADPoint1, ADPoint2: TDPoint ): TDPoint;
begin
  Result.X := ADPoint1.X - ADPoint2.X;
  Result.Y := ADPoint1.Y - ADPoint2.Y;
end; // end of function N_Substr2P(Dbl)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CSA
//******************************************************************* N_CSA ***
// Convert given Color and Size Attributes to TN_ColorSizeAttr record
//
//     Parameters
// AColor - given color
// AFSize - given size value
// Result - Returns TN_ColorSizeAttr record
//
function N_CSA( AColor: integer; AFSize: float  ): TN_ColorSizeAttr;
begin
  Result.Color := AColor;
  Result.Size  := AFSize;
end; // end of function N_CSA

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Same(two_Points)
//****************************************************** N_Same(two Points) ***
// Compare two Integer Points
//
//     Parameters
// APoint1 - first Integer Point
// APoint2 - second Integer Point
// Result  - Returns true if two given Points have same integer coordinates
//
function N_Same( const APoint1, APoint2: TPoint ): boolean;
begin
  Result := (APoint1.X = APoint2.X) and (APoint1.Y = APoint2.Y);
end; // end of function N_Same(IPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Same(two_FPoints)
//***************************************************** N_Same(two FPoints) ***
// Compare two Float Points
//
//     Parameters
// AFPoint1 - first Float Point
// AFPoint2 - second Float Point
// Result   - Returns true if two given Points have same float coordinates
//
function N_Same( const AFPoint1, AFPoint2: TFPoint ): boolean;
begin
  Result := (AFPoint1.X = AFPoint2.X) and (AFPoint1.Y = AFPoint2.Y);
end; // end of function N_Same(FPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Same(two_DPoints)
//***************************************************** N_Same(two DPoints) ***
// Compare two Double Points
//
//     Parameters
// ADPoint1 - first Double Point
// ADPoint2 - second Double Point
// Result   - Returns true if two given Points have same double coordinates
//
function N_Same( const ADPoint1, ADPoint2: TDPoint ): boolean;
begin
  Result := (ADPoint1.X = ADPoint2.X) and (ADPoint1.Y = ADPoint2.Y);
end; // end of function N_Same(DPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Same(two_Rects)
//******************************************************* N_Same(two Rects) ***
// Compare two Integer Rectangles
//
//     Parameters
// ARect1 - first Integer Rectangle
// ARect2 - second Integer Rectangle
// Result - Returns true if two given Rectangles have same integer coordinates
//
function N_Same( const ARect1, ARect2: TRect ): boolean;
begin
  Result := (ARect1.Left  = ARect2.Left)  and (ARect1.Top = ARect2.Top) and
            (ARect1.Right = ARect2.Right) and (ARect1.Bottom = ARect2.Bottom);
end; // end of function N_Same(IRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Same(two_FRects)
//****************************************************** N_Same(two FRects) ***
// Compare two Float Rectangles
//
//     Parameters
// AFRect1 - first Float Rectangle
// AFRect2 - second Float Rectangle
// Result  - Returns true if two given Rectangles have same float coordinates
//
function N_Same( const AFRect1, AFRect2: TFRect ): boolean;
begin
  Result := (AFRect1.Left  = AFRect2.Left)  and (AFRect1.Top = AFRect2.Top) and
            (AFRect1.Right = AFRect2.Right) and (AFRect1.Bottom = AFRect2.Bottom);
end; // end of function N_Same(FRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Same(two_DRects)
//****************************************************** N_Same(two DRects) ***
// Compare two Double Rectangles
//
//     Parameters
// ADRect1 - first Double Rectangle
// ADRect2 - second Double Rectangle
// Result  - Returns true if two given Rectangles have same double coordinates
//
function N_Same( const ADRect1, ADRect2: TDRect ): boolean;
begin
  Result := (ADRect1.Left  = ADRect2.Left)  and (ADRect1.Top = ADRect2.Top) and
            (ADRect1.Right = ADRect2.Right) and (ADRect1.Bottom = ADRect2.Bottom);
end; // end of function N_Same(DRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Same(two_PFPoints)
//**************************************************** N_Same(two PFPoints) ***
// Compare two Float Points given by two pointers to them
//
//     Parameters
// APFPoint1 - pointer to first Float Point
// APFPoint2 - pointer to second Float Point
// Result    - Returns true if two given Points have same float coordinates
//
function N_Same( const APFPoint1, APFPoint2: PFPoint ): boolean;
begin
  Result := (APFPoint1^.X = APFPoint2^.X) and (APFPoint1^.Y = APFPoint2^.Y);
end; // end of function N_Same(PFPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Same(FPArray)
//********************************************************* N_Same(FPArray) ***
// Compare elements in given Float Point arrays
//
//     Parameters
// FArray1  - first Float Points array
// FPInd1   - start compared element index in first array
// NumInds1 - number of compared elements in first array
// FArray2  - second Float Points array
// FPInd2   - start compared element index in second array
// NumInds2 - number of compared elements in second array
// Result   - Returns true if given elements in two given Double Point arrays 
//            are the same
//
function N_Same( const FArray1: TN_FPArray; FPInd1, NumInds1: integer;
                 const FArray2: TN_FPArray; FPInd2, NumInds2: integer ): boolean;
var
  NumBytes: integer; // NumChars
begin
  Result := False;
  if NumInds1 <> NumInds2 then Exit;

  NumBytes := NumInds1*Sizeof( FArray1[0] );

  if NumBytes > 0 then
    Result := N_SameBytes( @FArray1[FPInd1], NumBytes, @FArray2[FPInd2], NumBytes )
  else
    Result := True;
end; // end of function N_Same(FPArray)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Same(DPArray)
//********************************************************* N_Same(DPArray) ***
// Compare elements in given Double Point arrays
//
//     Parameters
// DArray1  - first Double Points array
// FPInd1   - start compared element index in first array
// NumInds1 - number of compared elements in first array
// DArray2  - second Double Points array
// FPInd2   - start compared element index in second array
// NumInds2 - number of compared elements in second array
// Result   - Returns true if given elements in two given Double Point arrays 
//            are the same
//
function N_Same( const DArray1: TN_DPArray; FPInd1, NumInds1: integer;
                 const DArray2: TN_DPArray; FPInd2, NumInds2: integer ): boolean;
var
  NumBytes: integer;
begin
  Result := False;
  if NumInds1 <> NumInds2 then Exit;

  NumBytes := NumInds1*Sizeof( DArray1[0] );

  if NumBytes > 0 then
    Result := N_SameBytes( @DArray1[FPInd1], NumBytes, @DArray2[FPInd2], NumBytes )
  else
    Result := True;
end; // end of function N_Same(DPArray)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectChangeCoords1(INT)
//************************************************ N_RectChangeCoords1(INT) ***
// Change Coords of given Integer Rectangle by given Integer Rectangle
//
//     Parameters
// ARect      - Integer Rectangle, whose coords should be changed
// ADeltaRect - Integer Rectangle, by which Coords ARect should be changed
// Result     - Returns Integer Rect with Changed Coords
//
function N_RectChangeCoords1( const ARect, ADeltaRect: TRect ): TRect;
begin
  Result.Left   := ARect.Left   - ADeltaRect.Left;
  Result.Top    := ARect.Top    - ADeltaRect.Top;
  Result.Right  := ARect.Right  + ADeltaRect.Right;
  Result.Bottom := ARect.Bottom + ADeltaRect.Bottom;
end; // end of function N_RectChangeCoords1 (INT)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectWidth_(Rect)
//****************************************************** N_RectWidth (Rect) ***
// Get integer width of given Integer Rectangle
//
//     Parameters
// ARect  - Integer Rectangle
// Result - Returns integer width of given Integer Rectangle
//
function N_RectWidth( const ARect: TRect ): integer;
begin
  Result := ARect.Right - ARect.Left + 1;
end; // end of function N_RectWidth (INT)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectWidth_(FRect)
//***************************************************** N_RectWidth (FRect) ***
// Get double width of given Float Rectangle
//
//     Parameters
// AFRect - Float Rectangle
// Result - Returns double width of given Float Rectangle
//
function N_RectWidth( const AFRect: TFRect ): double;
begin
  Result := AFRect.Right - AFRect.Left;
end; // end of function N_RectWidth(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectHeight_(Rect)
//***************************************************** N_RectHeight (Rect) ***
// Get integer height of given Integer Rectangle
//
//     Parameters
// ARect  - Integer Rectangle
// Result - Returns integer height of given Integer Rectangle
//
function N_RectHeight( const ARect: TRect ): integer;
begin
  Result := ARect.Bottom - ARect.Top + 1;
end; // end of function N_RectHeight (INT)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectHeight(FRect)
//***************************************************** N_RectHeight(FRect) ***
// Get double height of given Float Rectangle
//
//     Parameters
// AFRect - Float Rectangle
// Result - Returns double height of given Float Rectangle
//
function N_RectHeight( const AFRect: TFRect ): double;
begin
  Result := AFRect.Bottom - AFRect.Top;
end; // end of function N_RectHeight(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectSize(Rect)
//******************************************************** N_RectSize(Rect) ***
// Get width and height of given Integer Rectangle as Integer Point
//
//     Parameters
// ARect  - Integer Rectangle
// Result - Returns Integer Rectangle width and height as Integer Point
//
function N_RectSize( const ARect: TRect ): TPoint;
begin
  Result.X := ARect.Right - ARect.Left + 1;
  Result.Y := ARect.Bottom - ARect.Top + 1;
end; // end of function N_RectSize(int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectSize(FRect)
//******************************************************* N_RectSize(FRect) ***
// Get width and height of given Float Rectangle as Double Point
//
//     Parameters
// AFRect - Float Rectangle
// Result - Returns Float Rectangle width and height as Double Point
//
function N_RectSize( const AFRect: TFRect ): TDPoint;
begin
  Result.X := AFRect.Right - AFRect.Left;
  Result.Y := AFRect.Bottom - AFRect.Top;
end; // end of function N_RectSize(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectSize(DRect)
//******************************************************* N_RectSize(DRect) ***
// Get width and height of given Double Rectangle as Double Point
//
//     Parameters
// ADRect - Double Rectangle
// Result - Returns Double Rectangle width and height as Double Point
//
function N_RectSize( const ADRect: TDRect ): TDPoint;
begin
  Result.X := ADRect.Right - ADRect.Left;
  Result.Y := ADRect.Bottom - ADRect.Top;
end; // end of function N_RectSize(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectSizeM1
//************************************************************ N_RectSizeM1 ***
// Get width and height of given Integer Rectangle reduced by 1 as Integer Point
//
//     Parameters
// ARect  - Integer Rectangle
// Result - Returns Integer Rectangle width-1 and height-1 as Integer Point
//
// If resulting width < 0 then width = 1, in a similar if resulting height < 0 
// then height = 1.
//
function N_RectSizeM1( const ARect: TRect ): TPoint;
begin
  Result.X := ARect.Right - ARect.Left;
  if Result.X <= 0 then Result.X := 1;
  Result.Y := ARect.Bottom - ARect.Top;
  if Result.Y <= 0 then Result.Y := 1;
end; // end of function N_RectSizeM1(int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectCenter(Rect)
//****************************************************** N_RectCenter(Rect) ***
// Get given Integer Rectangle center Integer Point
//
//     Parameters
// ARect  - Integer Rectangle
// Result - Returns Rectangle center Integer Point
//
function N_RectCenter( const ARect: TRect ): TPoint;
begin
  Result.X := (ARect.Left + ARect.Right) div 2;
  Result.Y := (ARect.Top + ARect.Bottom) div 2;
end; // end of function N_RectCenter(int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectCenter(FRect)
//***************************************************** N_RectCenter(FRect) ***
// Get given Float Rectangle center Double Point
//
//     Parameters
// AFRect - Float Rectangle
// Result - Returns Rectangle center Double Point
//
function N_RectCenter( const AFRect: TFRect ): TDPoint;
begin
  Result.X := 0.5*(AFRect.Left + AFRect.Right);
  Result.Y := 0.5*(AFRect.Top  + AFRect.Bottom);
end; // end of function N_RectCenter(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectNormCoords
//******************************************************** N_RectNormCoords ***
// Get given Point normalized position (coordinates) in given Integer Rectangle
//
//     Parameters
// ADAbsPoint - Double Point with absolute coordinates
// ARect      - Integer Rectangle
// Result     - Returns given Point relative coordinates in given Rectangle as 
//              Double Point
//
// If AAbsPoint is the same as given Rectangle top left corner, then resulting 
// Point is (0,0). If AAbsPoint is the same as given Rectangle bottom right 
// corner, then resulting Point is (1,1).
//
function N_RectNormCoords( const ADAbsPoint: TDPoint; const ARect: TRect ): TDPoint;
begin
  if ARect.Right = ARect.Left then
    Result.X := 0.5
  else
    Result.X := (ADAbsPoint.X - ARect.Left) / (ARect.Right  - ARect.Left);

  if ARect.Bottom = ARect.Top then
    Result.Y := 0.5
  else
    Result.Y := (ADAbsPoint.Y - ARect.Top)  / (ARect.Bottom - ARect.Top);
end; // end of function N_RectNormCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectAbsCoords
//********************************************************* N_RectAbsCoords ***
// Get absolute coordinates from given Point normalized position in given 
// integer Rectangle
//
//     Parameters
// ADNormPoint - Double Point with normalized coordinates
// ARect       - Integer Rectangle
// Result      - Returns given Point absolute double coordinates
//
// If ANormPoint is (0,0) then resulting Point coincides with given Rectangle 
// top left corner. If ANormPoint is (1,1) then resulting Point coincides with 
// given Rectangle bottom right corner.
//
function N_RectAbsCoords( const ADNormPoint: TDPoint; const ARect: TRect ): TDPoint;
begin
  Result.X := ARect.Left + ADNormPoint.X*(ARect.Right  - ARect.Left);
  Result.Y := ARect.Top  + ADNormPoint.Y*(ARect.Bottom - ARect.Top);
end; // end of function N_RectAbsCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectAspect_(Rect)
//***************************************************** N_RectAspect (Rect) ***
// Get aspect (height/width) of given Integer Rectangle Return -1 if Aspect 
// cannot be calculated
//
//     Parameters
// ARect  - Integer Rectangle
// Result - Returns double aspect of given Integer Rectangle (height/width)
//
function N_RectAspect( const ARect: TRect ): double;
begin
  Result := -1;

  if (ARect.Right  <= (ARect.Left-1)) or
     (ARect.Bottom <= (ARect.Top-1))  then Exit;

  Result := Abs((ARect.Bottom-ARect.Top+1) / (ARect.Right-ARect.Left+1));
end; // end of function N_RectAspect (INT)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectAspect(FRect)
//***************************************************** N_RectAspect(FRect) ***
// Get aspect (height/width) of given Float Rectangle Return -1 if Aspect cannot
// be calculated
//
//     Parameters
// ARect  - Float Rectangle
// Result - Returns double aspect of given Float Rectangle (height/width)
//
function N_RectAspect( const ARect: TFRect ): double;
begin
  Result := -1;

  if (ARect.Right  <= ARect.Left) or
     (ARect.Bottom <= ARect.Top)  then Exit;

  Result := Abs((ARect.Bottom-ARect.Top) / (ARect.Right-ARect.Left));
end; // end of function N_RectAspect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectAspect_(DRect)
//**************************************************** N_RectAspect (DRect) ***
// Get aspect (height/width) of given Double Rectangle Return -1 if Aspect 
// cannot be calculated
//
//     Parameters
// ARect  - Double Rectangle
// Result - Returns double aspect of given Double Rectangle (height/width)
//
function N_RectAspect( const ARect: TDRect ): double;
begin
  Result := -1;

  if (ARect.Right  <= ARect.Left) or
     (ARect.Bottom <= ARect.Top)  then Exit;

  Result := Abs((ARect.Bottom-ARect.Top) / (ARect.Right-ARect.Left));
end; // end of function N_RectAspect (DBL)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectMaxCoord(Rect)
//**************************************************** N_RectMaxCoord(Rect) ***
// Get maximal absolute coordinate for given Integer Rectangle
//
//     Parameters
// ARect  - Integer Rectangle
// Result - Returns maximal absolute integer coordinate
//
// Function calculates Max(Abs(Left),Abs(Top),Abs(Right),Abs(Bottom)).
//
function N_RectMaxCoord( const ARect: TRect ): integer;
begin
  with ARect do
  begin
    Result := Abs(Left);
    Result := Max( Result, Abs(Top)    );
    Result := Max( Result, Abs(Right)  );
    Result := Max( Result, Abs(Bottom) );
  end;
end; // function N_RectMaxCoord(Int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectMaxCoord(FRect)
//*************************************************** N_RectMaxCoord(FRect) ***
// Get maximal absolute coordinate for given Float Rectangle
//
//     Parameters
// AFRect - Float Rectangle
// Result - Returns maximal absolute float coordinate
//
// Function calculates Max(Abs(Left),Abs(Top),Abs(Right),Abs(Bottom)).
//
function N_RectMaxCoord( const AFRect: TFRect ): float;
begin
  with AFRect do
  begin
    Result := Abs(Left);
    Result := Max( Result, Abs(Top)    );
    Result := Max( Result, Abs(Right)  );
    Result := Max( Result, Abs(Bottom) );
  end;
end; // function N_RectMaxCoord(Float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectMaxCoord(DRect)
//*************************************************** N_RectMaxCoord(DRect) ***
// Get maximal absolute coordinate for given Double Rectangle
//
//     Parameters
// ADRect - Double Rectangle
// Result - Returns maximal absolute double coordinate
//
// Function calculates Max(Abs(Left),Abs(Top),Abs(Right),Abs(Bottom)).
//
function N_RectMaxCoord( const ADRect: TDRect ): double;
begin
  with ADRect do
  begin
    Result := Abs(Left);
    Result := Max( Result, Abs(Top)    );
    Result := Max( Result, Abs(Right)  );
    Result := Max( Result, Abs(Bottom) );
  end;
end; // function N_RectMaxCoord(Double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectShift(Rect,two_Integers)
//****************************************** N_RectShift(Rect,two Integers) ***
// Shift given Integer Rectangle by given integer shifts for X and Y coordinates
//
//     Parameters
// ARect   - Integer Rectangle
// AShiftX - integer shift for X coordinate
// AShiftY - integer shift for Y coordinate
// Result  - Returns shifted Integer Rectangle
//
function N_RectShift( const ARect: TRect; AShiftX, AShiftY: integer ): TRect;
begin
  Result.Left   := ARect.Left   + AShiftX;
  Result.Top    := ARect.Top    + AShiftY;
  Result.Right  := ARect.Right  + AShiftX;
  Result.Bottom := ARect.Bottom + AShiftY;
end; // end of function N_RectShift(int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectShift(Rect,_Point)
//************************************************ N_RectShift(Rect, Point) ***
// Shift given Integer Rectangle by shifts for X and Y coordinates given as 
// integer Point
//
//     Parameters
// ARect    - Integer Rectangle
// AShiftXY - Integer Point with shifts for X and Y coordinates
// Result   - Returns shifted Integer Rectangle
//
function N_RectShift( const ARect: TRect; AShiftXY: TPoint ): TRect;
begin
  Result.Left   := ARect.Left   + AShiftXY.X;
  Result.Top    := ARect.Top    + AShiftXY.Y;
  Result.Right  := ARect.Right  + AShiftXY.X;
  Result.Bottom := ARect.Bottom + AShiftXY.Y;
end; // end of function N_RectShift(IPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectShift(FRect,_two_Doubles)
//***************************************** N_RectShift(FRect, two Doubles) ***
// Shift given Float Rectangle by given double shifts for X and Y coordinates
//
//     Parameters
// AFRect   - Integer Rectangle
// ADShiftX - double shift for X coordinate
// ADShiftY - double shift for Y coordinate
// Result   - Returns shifted Float Rectangle
//
function N_RectShift( const AFRect: TFRect; ADShiftX, ADShiftY: double ): TFRect;
begin
  Result.Left   := AFRect.Left   + ADShiftX;
  Result.Top    := AFRect.Top    + ADShiftY;
  Result.Right  := AFRect.Right  + ADShiftX;
  Result.Bottom := AFRect.Bottom + ADShiftY;
end; // end of function N_RectShift(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectShift(FRect,_FPoint)
//********************************************** N_RectShift(FRect, FPoint) ***
// Shift given Float Rectangle by shifts for X and Y coordinates given as float 
// Point
//
//     Parameters
// AFRect    - Float Rectangle
// AFShiftXY - Float Point with shifts for X and Y coordinates
// Result    - Returns shifted Float Rectangle
//
function N_RectShift( const AFRect: TFRect; AFShiftXY: TFPoint ): TFRect;
begin
  Result.Left   := AFRect.Left   + AFShiftXY.X;
  Result.Top    := AFRect.Top    + AFShiftXY.Y;
  Result.Right  := AFRect.Right  + AFShiftXY.X;
  Result.Bottom := AFRect.Bottom + AFShiftXY.Y;
end; // end of function N_RectShift(FR,FP)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectShift4
//************************************************************ N_RectShift4 ***
// Shift given Integer Rectangle by given flags and integer shifts for X and Y 
// coordinates
//
//     Parameters
// ARect   - Integer Rectangle
// AFlags  - flags for each Rectangle sides change control:
//#F
//        bits0-1   ($00003) - Top  side
//        bits4-5   ($00030) - Right side
//        bits8-9   ($00300) - Bottom side
//        bits12-13 ($03000) - Left side
//  Each side bits value: =0 - no change, =1 - increase, =2 - decrease
//#/F
// AShiftX - integer shift for X coordinate
// AShiftY - integer shift for Y coordinate
// Result  - Returns shifted Integer Rectangle
//
// AFlags bits: =0 - no change, =1 - increase, =2 - decrease : bits0-1 ($00003) 
// - Top  side bits4-5   ($00030) - Right side bits8-9   ($00300) - Bottom side 
// bits12-13 ($03000) - Left side
//
function N_RectShift4( const ARect: TRect; AFlags, AShiftX, AShiftY: integer ): TRect;
var
  Fl: integer;
begin
  Result := ARect;
  with Result do
  begin
    Fl := AFlags and $0003;
    if Fl = $1 then Inc( Top, AShiftY );
    if Fl = $2 then Dec( Top, AShiftY );

    Fl := AFlags and $0030;
    if Fl = $10 then Inc( Right, AShiftX );
    if Fl = $20 then Dec( Right, AShiftX );

    Fl := AFlags and $0300;
    if Fl = $1 then Inc( Bottom, AShiftY );
    if Fl = $2 then Dec( Bottom, AShiftY );

    Fl := AFlags and $3000;
    if Fl = $10 then Inc( Left, AShiftX );
    if Fl = $20 then Dec( Left, AShiftX );
  end;
end; // end of function N_RectShift4(int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectCalc
//************************************************************** N_RectCalc ***
// Normalize given Rectangle coordinates by given width and height
//
//     Parameters
// ARect   - Integer Rectangle
// AWidth  - Integer Rectangle width
// AHeight - Integer Rectangle height
// Result  - Returns Integer Rectangle with normalized coordinates
//
// Source Rectangle negative coordinates are used as relative to corresponding 
// size, so normal coordinate calculates as size + relative coordinate.
//
function N_RectCalc( const ARect: TRect; AWidth, AHeight: integer ): TRect;
begin
  Result := ARect;

  if Result.Left   < 0  then Result.Left   := Result.Left   + AWidth;
  if Result.Right  < 0  then Result.Right  := Result.Right  + AWidth;
  if Result.Top    < 0  then Result.Top    := Result.Top    + AHeight;
  if Result.Bottom < 0  then Result.Bottom := Result.Bottom + AHeight;
end; // function N_RectCalc

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectAdjustByMaxRect(Rect,_Rect)_Rect
//********************************** N_RectAdjustByMaxRect(Rect, Rect):Rect ***
// Adjust given Integer Rectangle by given maximal Integer Rectangle
//
//     Parameters
// ARect    - source Integer Rectangle
// AMaxRect - maximal Integer Rectangle
// Result   - Returns Integer Rectangle adjusted by given maximal Rectangle
//
// Shift given Rectangle inside maximal Rectangle and clip it by maximal 
// Rectangle if needed.
//
function N_RectAdjustByMaxRect( const ARect, AMaxRect: TRect ): TRect;
var
  Delta: integer;
begin
  Result := ARect;

  Delta := AMaxRect.Left - Result.Left;
  if Delta > 0 then // shift right
  begin
    Inc( Result.Left, Delta );
    Inc( Result.Right, Delta );
  end;

  Delta := AMaxRect.Top - Result.Top;
  if Delta > 0 then // shift down
  begin
    Inc( Result.Top, Delta );
    Inc( Result.Bottom, Delta );
  end;

  Delta := AMaxRect.Right - Result.Right;
  if Delta < 0 then // shift left
  begin
    Inc( Result.Left, Delta );
    Inc( Result.Right, Delta );
  end;

  Delta := AMaxRect.Bottom - Result.Bottom;
  if Delta < 0 then // shift up
  begin
    Inc( Result.Top, Delta );
    Inc( Result.Bottom, Delta );
  end;

  N_IRectAnd( Result, AMaxRect );
end; // function N_RectAdjustByMaxRect(int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectAdjustByMaxRect(FRect,_FRect)_FRect
//******************************* N_RectAdjustByMaxRect(FRect, FRect):FRect ***
// Adjust given Float Rectangle by given maximal Float Rectangle
//
//     Parameters
// AFRect    - source Float Rectangle
// AFMaxRect - maximal Float Rectangle
// Result    - Returns Float Rectangle adjusted by given maximal Rectangle
//
// Shift given Rectangle inside maximal Rectangle and clip it by maximal 
// Rectangle if needed.
//
function N_RectAdjustByMaxRect( const AFRect, AFMaxRect: TFRect ): TFRect;
var
  Delta: float;
begin
  Result := AFRect;

  Delta := AFMaxRect.Left - Result.Left;
  if Delta > 0 then // shift right
  begin
    Result.Left  := Result.Left + Delta;
    Result.Right := Result.Right + Delta;
  end;

  Delta := AFMaxRect.Top - Result.Top;
  if Delta > 0 then // shift down
  begin
    Result.Top    := Result.Top + Delta;
    Result.Bottom := Result.Bottom + Delta;
  end;

  Delta := AFMaxRect.Right - Result.Right;
  if Delta < 0 then // shift left
  begin
    Result.Left  := Result.Left + Delta;
    Result.Right := Result.Right + Delta;
  end;

  Delta := AFMaxRect.Bottom - Result.Bottom;
  if Delta < 0 then // shift up
  begin
    Result.Top    := Result.Top + Delta;
    Result.Bottom := Result.Bottom + Delta;
  end;

  N_FRectAnd( Result, AFMaxRect );
end; // function N_RectAdjustByMaxRect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectAdjustByMinRect(Rect,_Rect)_Rect
//********************************** N_RectAdjustByMinRect(Rect, Rect):Rect ***
// Adjust given Integer Rectangle by given minimal Integer Rectangle
//
//     Parameters
// ARect    - source Integer Rectangle
// AMinRect - minimal Integer Rectangle
// Result   - Returns Integer Rectangle adjusted by given minimal Rectangle
//
// Shift given Rectangle to cover given minimal Rectangle if possible, upper 
// left corner is always covered.
//
function N_RectAdjustByMinRect( const ARect, AMinRect: TRect ): TRect;
var
  Delta: integer;
begin
  Result := ARect;

  Delta := AMinRect.Right - Result.Right;
  if Delta > 0 then // shift Right
  begin
    Inc( Result.Left, Delta );
    Inc( Result.Right, Delta );
  end;

  Delta := AMinRect.Bottom - Result.Bottom;
  if Delta > 0 then // shift down
  begin
    Inc( Result.Top, Delta );
    Inc( Result.Bottom, Delta );
  end;

  Delta := AMinRect.Left - Result.Left;
  if Delta < 0 then // shift Left
  begin
    Inc( Result.Left, Delta );
    Inc( Result.Right, Delta );
  end;

  Delta := AMinRect.Top - Result.Top;
  if Delta < 0 then // shift up
  begin
    Inc( Result.Top, Delta );
    Inc( Result.Bottom, Delta );
  end;
end; // function N_RectAdjustByMinRect(int,int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectAdjustByMinRect(FRect,_Rect)_FRect
//******************************** N_RectAdjustByMinRect(FRect, Rect):FRect ***
// Adjust given Float Rectangle by given minimal Float Rectangle
//
//     Parameters
// AFRect   - source Float Rectangle
// AMinRect - minimal Integer Rectangle
// Result   - Returns Float Rectangle adjusted by given minimal Rectangle
//
// Shift given Rectangle to cover given minimal Rectangle if possible, upper 
// left corner is always covered.
//
function N_RectAdjustByMinRect( const AFRect: TFRect; const AMinRect: TRect ): TFRect;
var
  Delta: double;
begin
  Result := AFRect;

  Delta := AMinRect.Right + 1 - Result.Right;
  if Delta > 0 then // shift Result Right
  begin
    Result.Left  := Result.Left  + Delta;
    Result.Right := Result.Right + Delta;
  end;

  Delta := AMinRect.Bottom + 1 - Result.Bottom;
  if Delta > 0 then // shift Result Down
  begin
    Result.Top    := Result.Top    + Delta;
    Result.Bottom := Result.Bottom + Delta;
  end;

  Delta := AMinRect.Left - Result.Left;
  if Delta < 0 then // shift Result Left
  begin
    Result.Left  := Result.Left  + Delta;
    Result.Right := Result.Right + Delta;
  end;

  Delta := AMinRect.Top - Result.Top;
  if Delta < 0 then // shift Result Up
  begin
    Result.Top    := Result.Top    + Delta;
    Result.Bottom := Result.Bottom + Delta;
  end;
end; // function N_RectAdjustByMinRect(float,int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcRectSizePos
//******************************************************* N_CalcRectSizePos ***
// Calc Integer Rect Size and Pos by given input Size, Pos and Flags
//
//     Parameters
// AInpSize - given Input (initial) Size
// AInpPos  - given Input (initial) Position
// AFlags   - given Size and Position Flags
// AOutSize - resulting Rect Size
// AOutPos  - resulting Rect Position
//
procedure N_CalcRectSizePos( const AInpSize, AInpPos: TPoint; AFlags: TN_RectSizePosFlags;
                               out AOutSize, AOutPos: TPoint );
var
  Center: TPoint;
  BaseRect, OutRect: TRect;
begin
  if AInpSize.X <> N_NotAnInteger then AOutSize.X := AInpSize.X
                                  else AOutSize.X := 100;
  if AInpSize.Y <> N_NotAnInteger then AOutSize.Y := AInpSize.Y
                                  else AOutSize.Y := 100;

  if AInpPos.X <> N_NotAnInteger then AOutPos.X := AInpPos.X
                                 else AOutPos.X := 0;
  if AInpPos.Y <> N_NotAnInteger then AOutPos.Y := AInpPos.Y
                                 else AOutPos.Y := 0;

  if rspfMFRect in AFlags then
    BaseRect := N_MainUserFormRect
  else if rspfCurMonWAR in AFlags then
    BaseRect := N_CurMonWAR
  else if rspfPrimMonWAR in AFlags then
    BaseRect := N_PrimMonWAR
  else if rspfAppWAR in AFlags then
    BaseRect := N_AppWAR
  else // BaseRect is not given, a precaution
    Exit;

  if rspfMaximize in AFlags then // Maximize in Base Rect
  begin
    AOutSize := N_RectSize( BaseRect );
    AOutPos  := BaseRect.TopLeft;
    Exit;
  end; // if rspfMaximize in AFlags then // Maximize in Base Rect

  if rspfCenter in AFlags then // Center in Base Rect
  begin
    Center := N_RectCenter( BaseRect );
    AOutPos.X := Center.X - (AOutSize.X div 2);
    AOutPos.Y := Center.Y - (AOutSize.Y div 2);
    Exit;
  end; // if rspfMaximize in AFlags then // Maximize in Base Rect

  OutRect := N_RectMake( AOutPos, AOutSize, N_ZDPoint );

  if rspfShiftPart in AFlags then // at least 48 pixels or OutRect should be inside BaseRect
    BaseRect := N_RectIncr( BaseRect, AOutSize.X-48, AOutSize.Y-48 );

  OutRect := N_RectAdjustByMaxRect( OutRect, BaseRect );

  AOutSize := N_RectSize( OutRect );
  AOutPos  := OutRect.TopLeft;
end; // procedure N_CalcRectSizePos

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectIncr
//************************************************************** N_RectIncr ***
// Increase given Integer Rectangle by given delta for X and Y coordinates
//
//     Parameters
// ARect   - Integer Rectangle
// AShiftX - integer shift for X coordinates
// AShiftY - integer shift for Y coordinates
// Result  - Returns increased Integer Rectangle
//
// Shift given Rectangle sides: left to left, right to right, top to top and 
// bottom to bottom.
//
function N_RectIncr( const ARect: TRect; AShiftX, AShiftY: integer ): TRect;
begin
  Result.Left   := ARect.Left   - AShiftX;
  Result.Top    := ARect.Top    - AShiftY;
  Result.Right  := ARect.Right  + AShiftX;
  Result.Bottom := ARect.Bottom + AShiftY;
end; // end of function N_RectIncr(integer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectMake(IP,I,I)
//****************************************************** N_RectMake(IP,I,I) ***
// Create new Integer Rectangle by given TopLeft and two sizes
//
//     Parameters
// APoint  - given integer base Point
// AWidth  - given Width
// AHeight - given Height
// Result  - Returns created Integer Rectangle
//
function N_RectMake( const ATopLeft: TPoint; AWidth, AHeight: integer ): TRect;
begin
  Result.TopLeft := ATopLeft;
  Result.Right   := Result.Left + AWidth - 1;
  Result.Bottom  := Result.Top + AHeight - 1;
end; // end of function N_RectMake(IP,I,I)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectMake(Point,_Point)_Rect
//******************************************* N_RectMake(Point, Point):Rect ***
// Create new Integer Rectangle by given Integer Point, itТs relative position 
// and Rectangle size
//
//     Parameters
// APoint     - integer base Point
// AXYSize    - resulting Rectangle size given as Integer Point
// ADPointPos - base Point relative position ( (0,0) means upper left corner, 
//              (1,1) means lower right corner)
// Result     - Returns created Integer Rectangle
//
function N_RectMake( const APoint: TPoint; const AXYSize: TPoint;
                                           const ADPointPos: TDPoint ): TRect;
begin
  Result.Left   := Round( APoint.X - AXYSize.X*ADPointPos.X );
  Result.Right  := Result.Left + AXYSize.X - 1;
  Result.Top    := Round( APoint.Y - AXYSize.Y*ADPointPos.Y );
  Result.Bottom := Result.Top + AXYSize.Y - 1;
end; // end of function N_RectMake(IP,IR)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectMake(DPoint,_Point)_Rect
//****************************************** N_RectMake(DPoint, Point):Rect ***
// Create new Integer Rectangle by given Double Point, itТs relative position 
// and Rectangle size
//
//     Parameters
// ADPoint    - double base Point
// AXYSize    - resulting Rectangle size given as Integer Point
// ADPointPos - base Point relative position ( (0,0) means upper left corner, 
//              (1,1) means lower right corner)
// Result     - Returns created Integer Rectangle
//
function N_RectMake( const ADPoint: TDPoint; const AXYSize: TPoint;
                                            const ADPointPos: TDPoint ): TRect;
begin
  Result.Left   := Round( ADPoint.X - AXYSize.X*ADPointPos.X );
  Result.Right  := Result.Left + AXYSize.X - 1;
  Result.Top    := Round( ADPoint.Y - AXYSize.Y*ADPointPos.Y );
  Result.Bottom := Result.Top + AXYSize.Y - 1;
end; // end of function N_RectMake(DP,IR)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectMake(DPoint,_DPoint)_FRect
//**************************************** N_RectMake(DPoint, DPoint):FRect ***
// Create new Float Rectangle by given Double Point, itТs relative position and 
// Rectangle size
//
//     Parameters
// ADPoint    - double base Point
// ADXYSize   - resulting Rectangle size given as Double Point
// ADPointPos - base ponit relative position ( (0,0) means upper left corner, 
//              (1,1) means lower right corner)
// Result     - Returns created Float Rectangle
//
function N_RectMake( const ADPoint, ADXYSize, ADPointPos: TDPoint ): TFRect;
begin
  Result.Left   := ADPoint.X - ADXYSize.X*ADPointPos.X;
  Result.Right  := Result.Left + ADXYSize.X;
  Result.Top    := ADPoint.Y - ADXYSize.Y*ADPointPos.Y;
  Result.Bottom := Result.Top + ADXYSize.Y;
end; // end of function N_RectMake(DP,FR)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectMakeD
//************************************************************* N_RectMakeD ***
// Create new Double Rectangle by given Double Point, itТs relative position and
// Rectangle size
//
//     Parameters
// ADPoint    - double base Point
// ADXYSize   - resulting Rectangle size given as Double Point
// ADPointPos - base Point relative position ( (0,0) means upper left corner, 
//              (1,1) means lower right corner)
// Result     - Returns created Double Rectangle
//
function N_RectMakeD( const ADPoint, ADXYSize, ADPointPos: TDPoint ): TDRect;
begin
  Result.Left   := ADPoint.X - ADXYSize.X*ADPointPos.X;
  Result.Right  := Result.Left + ADXYSize.X;
  Result.Top    := ADPoint.Y - ADXYSize.Y*ADPointPos.Y;
  Result.Bottom := Result.Top + ADXYSize.Y;
end; // end of function N_RectMakeD

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectCheckPos(Rect,_Rect)
//********************************************** N_RectCheckPos(Rect, Rect) ***
// Check relative position of two given Integer Rectangles
//
//     Parameters
// ARect1 - Integer Rectangle 1
// ARect2 - Integer Rectangle 2
// Result - Returns integer, which bits indicates given Rectangles relative 
//          position:
//#F
// bit0(001) - ARect1.Left   <= ARect2.Left
// bit1(002) - ARect1.Top    <= ARect2.Top
// bit2(004) - ARect1.Right  >= ARect2.Right
// bit3(008) - ARect1.Bottom >= ARect2.Bottom
//
// bit4(010) - ARect1.Left   <  ARect2.Left
// bit5(020) - ARect1.Top    <  ARect2.Top
// bit6(040) - ARect1.Right  >  ARect2.Right
// bit7(080) - ARect1.Bottom >  ARect2.Bottom
//
// Result = $00 means that ARect1 strictly inside ARect2
// Result = $0F means that ARect1 is equal to ARect2
// Result = $FF means that ARect1 is larger or equal to ARect2
//#/F
//
function N_RectCheckPos( const ARect1, ARect2: TRect ): integer;
begin
  Result := 0;
       if ARect1.Left = ARect2.Left then Result := Result or $01
  else if ARect1.Left < ARect2.Left then Result := Result or $11;

       if ARect1.Top  = ARect2.Top  then Result := Result or $02
  else if ARect1.Top  < ARect2.Top  then Result := Result or $22;

       if ARect1.Right = ARect2.Right then Result := Result or $04
  else if ARect1.Right > ARect2.Right then Result := Result or $44;

       if ARect1.Bottom = ARect2.Bottom then Result := Result or $08
  else if ARect1.Bottom > ARect2.Bottom then Result := Result or $88;
end; // end of function N_RectCheckPos (INT)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectCheckPos(FRect,_FRect)
//******************************************** N_RectCheckPos(FRect, FRect) ***
// Check relative position of two given Float Rectangles
//
//     Parameters
// AFRect1 - Float Rectangle 1
// AFRect2 - Float Rectangle 2
// Result  - Returns integer, which bits indicates given Rectangles relative 
//           position:
//#F
// bit0(001) - AFRect1.Left   <= AFRect2.Left
// bit1(002) - AFRect1.Top    <= AFRect2.Top
// bit2(004) - AFRect1.Right  >= AFRect2.Right
// bit3(008) - AFRect1.Bottom >= AFRect2.Bottom
//
// bit4(010) - AFRect1.Left   <  AFRect2.Left
// bit5(020) - AFRect1.Top    <  AFRect2.Top
// bit6(040) - AFRect1.Right  >  AFRect2.Right
// bit7(080) - AFRect1.Bottom >  AFRect2.Bottom
//
// Result = $00 means that AFRect1 strictly inside AFRect2
// Result = $0F means that AFRect1 is equal to AFRect2
// Result = $FF means that AFRect1 is larger or equal to AFRect2
//#/F
//
function N_RectCheckPos( const AFRect1, AFRect2: TFRect ): integer;
begin
  Result := 0;
       if AFRect1.Left = AFRect2.Left then Result := Result or $01
  else if AFRect1.Left < AFRect2.Left then Result := Result or $11;

       if AFRect1.Top  = AFRect2.Top  then Result := Result or $02
  else if AFRect1.Top  < AFRect2.Top  then Result := Result or $22;

       if AFRect1.Right = AFRect2.Right then Result := Result or $04
  else if AFRect1.Right > AFRect2.Right then Result := Result or $44;

       if AFRect1.Bottom = AFRect2.Bottom then Result := Result or $08
  else if AFRect1.Bottom > AFRect2.Bottom then Result := Result or $88;
end; // end of function N_RectCheckPos(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectCheckPos_(DRect,_DRect)
//******************************************* N_RectCheckPos (DRect, DRect) ***
// Check relative position of two given Double Rectangles
//
//     Parameters
// ADRect1 - Double  Rectangle 1
// ADRect2 - Double  Rectangle 2
// Result  - Returns integer, which bits indicates given Rectangles relative 
//           position:
//#F
// bit0(001) - ADRect1.Left   <= ADRect2.Left
// bit1(002) - ADRect1.Top    <= ADRect2.Top
// bit2(004) - ADRect1.Right  >= ADRect2.Right
// bit3(008) - ADRect1.Bottom >= ADRect2.Bottom
//
// bit4(010) - ADRect1.Left   <  ADRect2.Left
// bit5(020) - ADRect1.Top    <  ADRect2.Top
// bit6(040) - ADRect1.Right  >  ADRect2.Right
// bit7(080) - ADRect1.Bottom >  ADRect2.Bottom
//
// Result = $00 means that ADRect1 strictly inside ADRect2
// Result = $0F means that ADRect1 is equal to ADRect2
// Result = $FF means that ADRect1 is larger or equal to ADRect2
//#/F
//
function N_RectCheckPos( const ADRect1, ADRect2: TDRect ): integer;
begin
  Result := 0;
       if ADRect1.Left = ADRect2.Left then Result := Result or $01
  else if ADRect1.Left < ADRect2.Left then Result := Result or $11;

       if ADRect1.Top  = ADRect2.Top  then Result := Result or $02
  else if ADRect1.Top  < ADRect2.Top  then Result := Result or $22;

       if ADRect1.Right = ADRect2.Right then Result := Result or $04
  else if ADRect1.Right > ADRect2.Right then Result := Result or $44;

       if ADRect1.Bottom = ADRect2.Bottom then Result := Result or $08
  else if ADRect1.Bottom > ADRect2.Bottom then Result := Result or $88;
end; // end of function N_RectCheckPos (DBL)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectCheckCross
//******************************************************** N_RectCheckCross ***
// Check cross-section of two given Integer Rectangles
//
//     Parameters
// ARect1 - Integer Rectangle 1
// ARect2 - Integer Rectangle 2
// Result - Returns the result of AND operation with two given Integer 
//          Rectangles
//#F
//  Result=0 Ц cross-section is empty
//  Result=1 - cross-section is NOT empty and ARect1 is NOT inside ARect2
//  Result=2 - cross-section is NOT empty and ARect1 is strictly inside ARect2
//#/F
//
// The result of routine is the same as in N_IRectAnd routine, but ARect1 is not
// changed.
//
function N_RectCheckCross( const ARect1, ARect2: TRect ): integer;
var
  TmpRect: TRect;
begin
  TmpRect := Arect1;
  Result := N_IRectAnd( TmpRect, ARect2 );
end; // end of function N_RectCheckCross(INT)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectSetPos
//************************************************************ N_RectSetPos ***
// Calculate Integer Rectangle by its Width and Height, maximal Rectangle and 
// fixed positioned Rectangle
//
//     Parameters
// AMode      - Calculating mode:
//#F
//  Mode bits3-0($000F) - main Mode:
//    =0 - place Result at some corner of AMaxRect with minimal overlapping
//         of resulting position and FixedRect
//    =1 - place Result near the given AMaxRect border (inside AMaxRect)
//    =2 - place Result near the given AFixedRect border (outside of AFixedRect)
//    =3 - place Result near the FixedRect border with minimal overlapping
//    =4 - place Result in the middle of AMaxRect (AFixedRect is not used)
//    =5 - shift AFixedRect inside AMaxRect, AWidth, AHeight are not used
//
//  Mode bits7-4($00F0) - X position:
//    =0 - Leftmost
//    =1 - in the middle
//    =2 - Rightmost
//
//  Mode bits11-8($0F00) - Y position:
//    =0 - Topmost
//    =1 - in the middle
//    =2 - Lowermost
//#/F
// AMaxRect   - maximal Integer Rectangle, inside which then resulting Rectangle
//              must be placed
// AFixedRect - Fixed positioned Integer Rectangle, outside which resulting 
//              Rectangle must be placed
// AWidth     - resulting Rectangle width
// AHeight    - resulting Rectangle height
// Result     - Returns Integer Rectangle calculated by given parameters
//
function N_RectSetPos( AMode: integer; const AMaxRect, AFixedRect: TRect;
                                              AWidth, AHeight: integer ): TRect;
var
  itmp, CurPenalty, PrevPenalty, XPenalty, YPenalty : integer;

  function AdjustRect( const InpRect: TRect ): TRect; // local
  // shift given Inp Rect inside MaxRect
  var
    Delta: integer;
  begin
    Result := InpRect;

    Delta := AMaxRect.Left - Result.Left;
    if Delta > 0 then // shift right
    begin
      Inc( Result.Left, Delta );
      Inc( Result.Right, Delta );
    end;

    Delta := AMaxRect.Top - Result.Top;
    if Delta > 0 then // shift down
    begin
      Inc( Result.Top, Delta );
      Inc( Result.Bottom, Delta );
    end;

    Delta := AMaxRect.Right - Result.Right;
    if Delta < 0 then // shift left
    begin
      Inc( Result.Left, Delta );
      Inc( Result.Right, Delta );
    end;

    Delta := AMaxRect.Bottom - Result.Bottom;
    if Delta < 0 then // shift up
    begin
      Inc( Result.Top, Delta );
      Inc( Result.Bottom, Delta );
    end;

    N_IRectAnd( Result, AMaxRect );
  end; // local function AdjustRect

begin //***** body of main N_RectSetPos function

  if (AMode and $F) = 5 then // Adjust FixedRect
  begin
    Result := AdjustRect( AFixedRect );
    Exit;
  end;

  if (AMode and $F) = 4 then // place Result in the middle of MaxRect
  begin
    itmp := N_RectWidth(AMaxRect);
    Result.Left := AMaxRect.Left + (itmp - AWidth) div 2;
    Result.Right := Result.Left + AWidth;

    itmp := N_RectHeight(AMaxRect);
    Result.Top := AMaxRect.Top + (itmp - AHeight) div 2;
    Result.Bottom := Result.Top + AHeight;
    Result := AdjustRect( Result );
    Exit;
  end;

  if (AMode and $F) = 3 then // place result near the FixedRect border with
  begin                     // minimal overlapping
    if (AMaxRect.Bottom - AFixedRect.Bottom) >= AHeight then // place under FixedRect
    begin
      Result := AdjustRect( N_RectMake( Point( AFixedRect.Left, AFixedRect.Bottom+1 ),
                                                Point(AWidth, AHeight), DPoint(0,0) ) );
      Exit;
    end;

    if (AMaxRect.Right - AFixedRect.Right) >= AHeight then // place righter FixedRect
    begin
      Result := AdjustRect( N_RectMake( Point( AFixedRect.Right+1, AFixedRect.Top ),
                                                Point(AWidth, AHeight), DPoint(0,0) ) );
      Exit;
    end;

    if (AFixedRect.Left - AMaxRect.Left) >= AWidth then // place lefter FixedRect
    begin
      Result := AdjustRect( N_RectMake( Point( AFixedRect.Left-1, AFixedRect.Top ),
                                                Point(AWidth, AHeight), DPoint(1,0) ) );
      Exit;
    end;

    if (AFixedRect.Top - AMaxRect.Top) >= AHeight then // place over FixedRect
    begin
      Result := AdjustRect( N_RectMake( Point( AFixedRect.Left, AFixedRect.Top-1 ),
                                                Point(AWidth, AHeight), DPoint(0,1) ) );
      Exit;
    end;

    AMode := AMode and $0FF0; // MaxRect is too small, place in the corner

  end; // if (AMode and $F) = 3 then // place Result near the FixedRect

  if (AMode and $F) = 1 then // place result near MaxRect border (inside it)
  begin
    case AMode and $0F0 of // define X position
    0: begin
      Result.Left  := AMaxRect.Left;
      Result.Right := Result.Left + AWidth;
    end;

    1: begin
      Result.Left  := AMaxRect.Left + (N_RectWidth(AMaxRect) - AWidth) div 2;
      Result.Right := Result.Left + AWidth;
    end;

    2: begin
      Result.Right := Result.Right;
      Result.Left  := AMaxRect.Right - AWidth;
    end;

    end; // case Mode and $0F0 of

    case AMode and $F00 of // define Y position
    0: begin
      Result.Top    := AMaxRect.Top;
      Result.Bottom := Result.Top + AHeight;
    end;

    1: begin
      Result.Top    := AMaxRect.Top + (N_RectHeight(AMaxRect) - AHeight) div 2;
      Result.Bottom := Result.Top + AHeight;
    end;

    2: begin
      Result.Bottom := Result.Bottom;
      Result.Top    := AMaxRect.Bottom - AHeight;
    end;

    end; // case Mode and $0F0 of

    Result := AdjustRect( Result );
    Exit;
  end;

  if (AMode and $F) = 0 then // place Result at some corner of MaxRect
  begin                     // with minimal overlapping
      //***** TopLeft corner
    XPenalty := Max( 0, AMaxRect.Left + AWidth - AFixedRect.Left );
    YPenalty := Max( 0, AMaxRect.Top  + AHeight - AFixedRect.Top );
    PrevPenalty := XPenalty * YPenalty;
    Result := AdjustRect( N_RectMake( AMaxRect.TopLeft, Point(AWidth, AHeight), DPoint(0,0) ) );
    if PrevPenalty = 0 then Exit; // all done

      //***** TopRight corner
    XPenalty := Max( 0, AFixedRect.Right + AWidth - AMaxRect.Right );
    YPenalty := Max( 0, AMaxRect.Top  + AHeight - AFixedRect.Top );
    CurPenalty := XPenalty * YPenalty;
    if CurPenalty < PrevPenalty then
    begin
      Result := AdjustRect( N_RectMake( Point( AMaxRect.Right-AWidth+1, AMaxRect.Top ),
                                                Point(AWidth, AHeight), DPoint(1,0) ) );
      if CurPenalty = 0 then Exit; // all done
      PrevPenalty := CurPenalty;
    end;

      //***** BottomLeft corner
    XPenalty := Max( 0, AMaxRect.Left + AWidth - AFixedRect.Left );
    YPenalty := Max( 0, AFixedRect.Bottom + AHeight - AMaxRect.Bottom );
    CurPenalty := XPenalty * YPenalty;
    if CurPenalty < PrevPenalty then
    begin
      Result := AdjustRect( N_RectMake( Point( AMaxRect.Left, AMaxRect.Bottom-AHeight+1 ),
                                                Point(AWidth, AHeight), DPoint(1,0) ) );
      if CurPenalty = 0 then Exit; // all done
      PrevPenalty := CurPenalty;
    end;

      //***** BottomRight corner
    XPenalty := Max( 0, AFixedRect.Right + AWidth - AMaxRect.Right );
    YPenalty := Max( 0, AFixedRect.Bottom + AHeight - AMaxRect.Bottom );
    CurPenalty := XPenalty * YPenalty;
    if CurPenalty < PrevPenalty then
      Result := AdjustRect( N_RectMake( Point( AMaxRect.Right-AWidth+1, AMaxRect.Bottom-AHeight+1 ),
                                                 Point(AWidth, AHeight), DPoint(1,0) ) );

  end; // if Mode = 0 then // place Result at some corner of MaxRect
end; // end of function N_RectSetPos(int)


//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectScaleA(int)
//******************************************************* N_RectScaleA(int) ***
// Calculate Integer Rectangle by given Integer Rectangle, scale factor and 
// fixed Integer Point in Absolute Coordinates
//
//     Parameters
// ARect         - source Integer Rectangle
// Coef          - scale factor
// AbsFixedPoint - fixed Integer Point in Absolute Coordinates
// Result        - Returns scaled Integer Rectangle
//
// Coef > 1.0 means increasing (resulting Rectangle is bigger then given). 
// Resulting Rectangle Width and Height are scaled (Result.Width = Coef * 
// ARect.Width). AbsFixedPoint Coordinates remains the same (i.e. AbsFixedPoint 
// = ARect.UpperLeft means that resulting Rectangle Upper Left corner remains 
// the same).
//
function N_RectScaleA( const ARect: TRect; const Coef: double;
                                        const AbsFixedPoint: TPoint ): TRect;
var
  ASize: TPoint;
  RelFixedPoint: TDPoint;
begin
  ASize := N_RectSize( ARect );
  RelFixedPoint.X := ( AbsFixedPoint.X - ARect.Left) / (ASize.X - 1);
  RelFixedPoint.Y := ( AbsFixedPoint.Y - ARect.Top)  / (ASize.Y - 1);
  ASize.X := Round( ASize.X * Coef );
  ASize.Y := Round( ASize.Y * Coef );
  Result := N_RectMake( AbsFixedPoint, ASize, RelFixedPoint );
end; // end of function N_RectScaleA(int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectScaleA(float)
//***************************************************** N_RectScaleA(float) ***
// Calculate Float Rectangle by given Float Rectangle, scale factor and fixed 
// Double Point in Absolute Coordinates
//
//     Parameters
// AFRect         - source Float Rectangle
// Coef           - scale factor
// AbsFixedDPoint - fixed Double Point in Absolute Coordinates
// Result         - Returns scaled Float Rectangle
//
// Coef > 1.0 means increasing (resulting Rectangle is bigger then given). 
// Resulting Rectangle Width and Height are scaled (Rusult.Width = Coef * 
// AFRect.Width). AbsFixedDPoint Coordinates remains the same (i.e. 
// AbsFixedDPoint = AFRect.UpperLeft means that resulting Rectangle Upper Left 
// corner remains the same).
//
function N_RectScaleA( const AFRect: TFRect; const Coef: double;
                                        const AbsFixedDPoint: TDPoint ): TFRect;
var
  RelFixedPoint, ASize: TDPoint;
begin
  ASize := N_RectSize( AFRect );
  RelFixedPoint.X := ( AbsFixedDPoint.X - AFRect.Left) / ASize.X;
  RelFixedPoint.Y := ( AbsFixedDPoint.Y - AFRect.Top)  / ASize.Y;
  ASize.X := ASize.X * Coef;
  ASize.Y := ASize.Y * Coef;
  Result := N_RectMake( AbsFixedDPoint, ASize, RelFixedPoint );
end; // end of function N_RectScaleA(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectScaleA(double)
//**************************************************** N_RectScaleA(double) ***
// Calculate Double Rectangle by given Double Rectangle, scale factor and fixed 
// Double Point in Absolute Coordinates
//
//     Parameters
// ADRect         - source Double Rectangle
// Coef           - scale factor
// AbsFixedDPoint - fixed Double Point in Absolute Coordinates
// Result         - Returns scaled Double Rectangle
//
// Coef > 1.0 means increasing (resulting Rectangle is bigger then given). 
// Resulting Rectangle Width and Height are scaled (Result.Width = Coef * 
// ADRect.Width). AbsFixedDPoint Coordinates remains the same (i.e. 
// AbsFixedDPoint = ADRect.UpperLeft means that resulting Rectangle Upper Left 
// corner remains the same).
//
function N_RectScaleA( const ADRect: TDRect; const Coef: double;
                              const AbsFixedDPoint: TDPoint ): TDRect;
var
  RelFixedPoint, ASize: TDPoint;
begin
  ASize := N_RectSize( ADRect );
  RelFixedPoint.X := ( AbsFixedDPoint.X - ADRect.Left) / ASize.X;
  RelFixedPoint.Y := ( AbsFixedDPoint.Y - ADRect.Top)  / ASize.Y;
  ASize.X := ASize.X * Coef;
  ASize.Y := ASize.Y * Coef;
  Result := N_RectMakeD( AbsFixedDPoint, ASize, RelFixedPoint );
end; // end of function N_RectScaleA(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectScaleR(int)
//******************************************************* N_RectScaleR(int) ***
// Calculate Integer Rectangle by given Integer Rectangle, scale factor and 
// fixed Double Point in Normalized Coordinates
//
//     Parameters
// ARect           - source Integer Rectangle
// Coef            - scale factor
// NormFixedDPoint - fixed Double Point in Normalized Coordinates
// Result          - Returns scaled Integer Rectangle
//
// Coef > 1.0 means increasing (resulting Rectangle is bigger then given). 
// Resulting Rectangle Width and Height are scaled (Result.Width = Coef * 
// ARect.Width). NormFixedDPoint Coordinates (Normalized Coordinates inside 
// source Rectangle) remains the same (i.e. NormFixedDPoint = (0.5,0.5) means 
// that resulting Rectangle center is coincident to ARect center).
//
function N_RectScaleR( const ARect: TRect; const Coef: double;
                                           const RelFixedDPoint: TDPoint ): TRect;
var
  AbsFixedPoint, ASize: TPoint;
begin
  ASize := N_RectSize( ARect );
  AbsFixedPoint.X := ARect.Left + Round( (ASize.X-1) * RelFixedDPoint.X );
  AbsFixedPoint.Y := ARect.Top  + Round( (ASize.Y-1) * RelFixedDPoint.Y );
  ASize.X := Round( ASize.X * Coef );
  ASize.Y := Round( ASize.Y * Coef );
  Result := N_RectMake( AbsFixedPoint, ASize, RelFixedDPoint );
end; // end of function N_RectScaleR(int)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectScaleR(float)
//***************************************************** N_RectScaleR(float) ***
// Calculate Float Rectangle by given Float Rectangle, scale factor and fixed 
// Double Point in Normalized Coordinates
//
//     Parameters
// AFRect          - source Float Rectangle
// Coef            - scale factor
// NormFixedDPoint - fixed Double Point in Normalized Coordinates
// Result          - Returns scaled Float Rectangle
//
// Coef > 1.0 means increasing (resulting Rectangle is bigger then given). 
// Resulting Rectangle Width and Height are scaled (Result.Width = Coef * 
// ARect.Width). NormFixedDPoint Coordinates (Normalized Coordinates inside 
// source Rectangle) remains the same (i.e. NormFixedDPoint = (0.5,0.5) means 
// that resulting Rectangle center is coincident to AFRect center).
//
function N_RectScaleR( const AFRect: TFRect; const Coef: double;
                                        const RelFixedPoint: TDPoint ): TFRect;
var
  AbsFixedPoint, ASize: TDPoint;
begin
  ASize := N_RectSize( AFRect );
  AbsFixedPoint.X := AFRect.Left + ASize.X * RelFixedPoint.X;
  AbsFixedPoint.Y := AFRect.Top  + ASize.Y * RelFixedPoint.Y;
  ASize.X := ASize.X * Coef;
  ASize.Y := ASize.Y * Coef;
  Result := N_RectMake( AbsFixedPoint, ASize, RelFixedPoint );
end; // end of function N_RectScaleR(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectRoundInc
//********************************************************** N_RectRoundInc ***
// Calculate Float Rectangle by round coordinates of source Float Rectangle to a
// given digit or power of ten and increase it if needed.
//
//     Parameters
// AFRect     - source Float Rectangle
// ANumDigits - number of digits in coordinate fractions
// Result     - Retuns Float Rectangle the same or bigger than given source 
//              AFRect
//
function N_RectRoundInc( const AFRect: TFRect; ANumDigits: integer ): TFRect;
var
  Delta, Cur: double;
begin
  Delta := IntPower( 1.0, -ANumDigits );

  Cur := RoundTo( AFRect.Left, ANumDigits );
  if Cur > AFRect.Left then Cur := Cur - Delta;
  Result.Left := Cur;

  Cur := RoundTo( AFRect.Top, ANumDigits );
  if Cur > AFRect.Top then Cur := Cur - Delta;
  Result.Top := Cur;

  Cur := RoundTo( AFRect.Right, ANumDigits );
  if Cur < AFRect.Right then Cur := Cur + Delta;
  Result.Right := Cur;

  Cur := RoundTo( AFRect.Bottom, ANumDigits );
  if Cur < AFRect.Bottom then Cur := Cur + Delta;
  Result.Bottom := Cur;

end; // end of function N_RectRoundInc(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectOrder(integer)
//**************************************************** N_RectOrder(integer) ***
// Check given Integer Rectangle coordinates relation
//
//     Parameters
// ARect  - source Integer Rectangle
// Result - Returns Integer value with ARect coordinates relation:
//#F
// Bits 0-3 ($00F) - Left and Right coordinates relation:
//                   0 - ARect.Left < ARect.Right
//                   1 - ARect.Left = ARect.Right
//                   2 - ARect.Left > ARect.Right
//
// Bits 4-7 ($0F0) - Top and Down coordinates relation:
//                   0 - ARect.Top < ARect.Down
//                   1 - ARect.Top = ARect.Down
//                   2 - ARect.Top > ARect.Down
//#/F
//
function N_RectOrder( const ARect: TRect ): integer;
begin
  Result := 0;

  if ARect.Left = ARect.Right then Result := Result + $01;
  if ARect.Left > ARect.Right then Result := Result + $02;

  if ARect.Top = ARect.Bottom then Result := Result + $010;
  if ARect.Top > ARect.Bottom then Result := Result + $020;
end; // end of function N_RectOrder(integer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectOrder(float)
//****************************************************** N_RectOrder(float) ***
// Check given Float Rectangle coordinates relation
//
//     Parameters
// AFRect - source Float Rectangle
// Result - Returns Integer value with AFRect coordinates relation:
//#F
// Bits 0-3 ($00F) - Left and Right coordinates relation:
//                   0 - AFRect.Left < AFRect.Right
//                   1 - AFRect.Left = AFRect.Right
//                   2 - AFRect.Left > AFRect.Right
//
// Bits 4-7 ($0F0) - Top and Down coordinates relation:
//                   0 - AFRect.Top < AFRect.Down
//                   1 - AFRect.Top = AFRect.Down
//                   2 - AFRect.Top > AFRect.Down
//#/F
//
function N_RectOrder( const AFRect: TFRect ): integer;
begin
  Result := 0;

  if AFRect.Left = AFRect.Right then Result := Result + $01;
  if AFRect.Left > AFRect.Right then Result := Result + $02;

  if AFRect.Top = AFRect.Bottom then Result := Result + $010;
  if AFRect.Top > AFRect.Bottom then Result := Result + $020;
end; // end of function N_RectOrder(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_GetAbsRect
//************************************************************ N_GetAbsRect ***
// Calculate Integer Rectangle by given source Integer Rectangle in possibly 
// Relative Coordinates and base Integer Rectangle in Absolute Coordinates
//
//     Parameters
// ASrcRect  - source Integer Rectangle in possibly Relative Coordinates
// AFullRect - base Integer Rectangle in Absolute Coordinates
// Result    - Returns Integer Rectangle in Absolute Coordinates build from 
//             ASrcRect
//
// Relative coordinates can be negative.
//
// Left and Right source Rectangle relative coordinates are relative to 
// AFullRect.Right coordinate. I.e. absolute ASrcRect.Left = relative 
// ASrcRect.Left + AFullRect.Right + 1
//
// Top and Bottom source Rectangle relative coordinates are relative to 
// AFullRect.Bottom сoordinate I.e. absolute ASrcRect.Top = relative 
// ASrcRect.Top + AFullRect.Bottom + 1
//
function N_GetAbsRect( const ASrcRect, AFullRect: TRect ): TRect;
begin
  Result := ASrcRect;

  if Result.Left   < 0 then Result.Left   := AFullRect.Right + Result.Left + 1;
  if Result.Top    < 0 then Result.Top    := AFullRect.Bottom + Result.Top + 1;
  if Result.Right  < 0 then Result.Right  := AFullRect.Right + Result.Right + 1;
  if Result.Bottom < 0 then Result.Bottom := AFullRect.Bottom + Result.Bottom + 1;
end; // end of function N_GetAbsRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_I2DPoint
//************************************************************** N_I2DPoint ***
// convert integer one point coordinates to double one point coordinates
//
function N_I2DPoint( const IPoint: TPoint ): TDPoint;
begin
  Result.X := IPoint.X;
  Result.Y := IPoint.Y;
end; // end of function N_I2DPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_D2IPoint
//************************************************************** N_D2IPoint ***
// convert double one point coordinates to integer one point coordinates
//
function N_D2IPoint( const DPoint: TDPoint ): TPoint;
begin
  Result.X := Round( DPoint.X );
  Result.Y := Round( DPoint.Y );
end; // end of function N_D2IPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_I2FRect1
//************************************************************** N_I2FRect1 ***
// convert integer Rect coordinates to float Rect coordinates as is
//
function N_I2FRect1( const IRect: TRect ): TFRect;
begin
  Result.Left   := IRect.Left;
  Result.Top    := IRect.Top;
  Result.Right  := IRect.Right;
  Result.Bottom := IRect.Bottom;
end; // end of function N_I2FRect1

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_I2FRect2
//************************************************************** N_I2FRect2 ***
// convert integer Rect coordinates to float Rect coordinates, increasing Right 
// Bottom coordinates by 1 (resulting float Rect has the same aspect as input 
// integer Rect)
//
function N_I2FRect2( const IRect: TRect ): TFRect;
begin
  Result.Left   := IRect.Left;
  Result.Top    := IRect.Top;
  Result.Right  := IRect.Right  + 1;
  Result.Bottom := IRect.Bottom + 1;
end; // end of function N_I2FRect2

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_F2IRect1
//************************************************************** N_F2IRect1 ***
// convert float Rect coordinates to integer Rect coordinates by Rounding
//
function N_F2IRect1( const FRect: TFRect ): TRect;
begin
  Result.Left   := Round( FRect.Left );
  Result.Top    := Round( FRect.Top );
  Result.Right  := Round( FRect.Right );
  Result.Bottom := Round( FRect.Bottom );
end; // end of function N_F2IRect1

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_F2IRect2
//************************************************************** N_F2IRect2 ***
// convert float Rect coordinates to integer Rect coordinates by Floor, Ceil
//
function N_F2IRect2( const FRect: TFRect ): TRect;
begin
  Result.Left   := Round( Floor(FRect.Left) );
  Result.Top    := Round( Floor(FRect.Top) );
  Result.Right  := Round( Ceil(FRect.Right) );
  Result.Bottom := Round( Ceil(FRect.Bottom) );
end; // end of function N_F2IRect2

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffCoefs4
//************************************************************* N_AffCoefs4 ***
// Calculate Four Affine Transformation Coefficients by four given double values
//
//     Parameters
// ACX    - X-coordinate factor
// ACY    - Y-coordinate factor
// ASX    - X-coordinate shift
// ASY    - Y-coordinate shift
// Result - Returns Four Affine Transformation Coefficients
//
function N_AffCoefs4( const ACX, ACY, ASX, ASY: double ): TN_AffCoefs4;
begin
  with Result do
  begin
    CX := ACX;
    CY := ACY;
    SX := ASX;
    SY := ASY;
  end;
end; // end of function N_AffCoefs4

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcAffCoefs4(integer)
//************************************************ N_CalcAffCoefs4(integer) ***
// Calculate Four Affine Transformation Coefficients by two given Integer 
// Rectangles
//
//     Parameters
// ASrcRect - source Integer Rectangle
// ADstRect - destination Integer Rectangle
// Result   - Returns Four Affine Transformation Coefficients
//
function N_CalcAffCoefs4( const ASrcRect, ADstRect: TRect ): TN_AffCoefs4;
var delta: double;
begin
  FillChar( Result, Sizeof(TN_AffCoefs4), 0 ); // needed only if error

  delta := ASrcRect.Right - ASrcRect.Left;
  if delta = 0 then Exit; // SrcRect data error
  Result.CX := (ADstRect.Right - ADstRect.Left) / delta;

  delta := ASrcRect.Bottom - ASrcRect.Top;
  if delta = 0 then Exit; // SrcRect data error
  Result.CY := (ADstRect.Bottom - ADstRect.Top) / delta;

  Result.SX := ADstRect.Left - ASrcRect.Left * Result.CX;
  Result.SY := ADstRect.Top  - aSrcRect.Top  * Result.CY;
end; // end of function N_CalcAffCoefs4(integer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcAffCoefs4(float)
//************************************************** N_CalcAffCoefs4(float) ***
// Calculate Four Affine Transformation Coefficients by two given Float 
// Rectangles
//
//     Parameters
// ASrcFRect - source Float Rectangle
// ADstFRect - destination Float Rectangle
// Result    - Returns Four Affine Transformation Coefficients
//
function N_CalcAffCoefs4( const ASrcFRect, ADstFRect: TFRect ): TN_AffCoefs4;
var delta: double;
begin
  FillChar( Result, Sizeof(TN_AffCoefs4), 0 ); // needed only if error

  delta := ASrcFRect.Right - ASrcFRect.Left;
  if delta = 0 then Exit; // SrcRect data error
  Result.CX := (ADstFRect.Right - ADstFRect.Left) / delta;

  delta := ASrcFRect.Bottom - ASrcFRect.Top;
  if delta = 0 then Exit; // SrcRect data error
  Result.CY := (ADstFRect.Bottom - ADstFRect.Top) / delta;

  Result.SX := ADstFRect.Left - ASrcFRect.Left * Result.CX;
  Result.SY := ADstFRect.Top  - ASrcFRect.Top  * Result.CY;
end; // end of function N_CalcAffCoefs4(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcAffCoefs4(double)
//************************************************* N_CalcAffCoefs4(double) ***
// Calculate Four Affine Transformation Coefficients by two given Double 
// Rectangles
//
//     Parameters
// ASrcDRect - source Double Rectangle
// ADstDRect - destination Double Rectangle
// Result    - Returns Four Affine Transformation Coefficients
//
function N_CalcAffCoefs4( const ASrcDRect, ADstDRect: TDRect ): TN_AffCoefs4;
var delta: double;
begin
  FillChar( Result, Sizeof(TN_AffCoefs4), 0 ); // needed only if error

  delta := ASrcDRect.Right - ASrcDRect.Left;
  if delta = 0 then Exit; // SrcRect data error
  Result.CX := (ADstDRect.Right - ADstDRect.Left) / delta;

  delta := ASrcDRect.Bottom - ASrcDRect.Top;
  if delta = 0 then Exit; // SrcRect data error
  Result.CY := (ADstDRect.Bottom - ADstDRect.Top) / delta;

  Result.SX := ADstDRect.Left - ASrcDRect.Left * Result.CX;
  Result.SY := ADstDRect.Top  - ASrcDRect.Top  * Result.CY;
end; // end of function N_CalcAffCoefs4(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ComposeAffCoefs4
//****************************************************** N_ComposeAffCoefs4 ***
// Calculate Four Affine Transformation Coefficients by two given AffCoefs4
//
//     Parameters
// AAffCoefs1 - convertible AffCoefs4
// AAffCoefs2 - transformative AffCoefs4
// Result     - Returns Four Affine Transformation Coefficients as a result of 
//              transformation AffCoefs1 by AffCoefs2
//
function N_ComposeAffCoefs4( AAffCoefs1, AAffCoefs2: TN_AffCoefs4 ): TN_AffCoefs4;
begin
  Result.CX := AAffCoefs1.CX * AAffCoefs2.CX;
  Result.SX := AAffCoefs1.SX * AAffCoefs2.CX + AAffCoefs2.SX;
  Result.CY := AAffCoefs1.CY * AAffCoefs2.CY;
  Result.SY := AAffCoefs1.SY * AAffCoefs2.CY + AAffCoefs2.SY;
end; // end of function N_ComposeAffCoefs4

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcAffCoefs4RS
//******************************************************* N_CalcAffCoefs4RS ***
// Calculate pair of Four Affine Transformation Coefficients (for Pixel to User 
// and User to Pixel Coordinates) using given Float Rectangle (in User 
// Coordinates) and Integer Rectangle (in Pixel Coordinates), assuming that 
// Pixel Rectangle = ( 0, 0, RSFactor*SrcWidth, RSFactor*SrcHeight )
//
//     Parameters
// AURect     - Float Rectangle in User Coordinates
// ARSFactor  - Pixel Rectangle size factor
// ASrcWidth  - source width of Integer Pixel Rectangle
// ASrcHeight - source Height of Integer Pixel Rectangle
// P2U        - resulting AffCoefs4 for transformation from Pixel to User 
//              Coordinates
// U2P        - resulting AffCoefs4 for transformation from User to Pixel 
//              Coordinates
//
// Calculations are based on given Float Rectangle (in User Coordinates) and 
// Integer Rectangle (in Pixel Coordinates), assuming that Pixel Rectangle is 
// equal to Rect( 0, 0, RSFactor*SrcWidth, RSFactor*SrcHeight )
//
procedure N_CalcAffCoefs4RS( const AURect: TFRect; const ARSFactor: double;
           const ASrcWidth, ASrcHeight: integer; var P2U, U2P: TN_AffCoefs4 );
var
  TmpPRect, TmpURect: TFRect;
begin
  FillChar( P2U, Sizeof(TN_AffCoefs4), 0 ); // needed only if error
  FillChar( U2P, Sizeof(TN_AffCoefs4), 0 ); // needed only if error
  if ARSFactor > 1 then // more than 1 pixel of scaled rect represent
  begin                // 1 pixel of RFSrcPRect
    TmpURect := AURect;
    TmpPRect.Left   := 0.5*(ARSFactor - 1);
    TmpPRect.Right  := ASrcWidth*ARSFactor -1 - 0.5*(ARSFactor - 1);
    TmpPRect.Top    := 0.5*(ARSFactor - 1);
    TmpPRect.Bottom := ASrcHeight*ARSFactor -1 - 0.5*(ARSFactor - 1);
  end else // 1 pixel of scaled rect represent more than 1 pixel of RFSrcPRect
  begin
    TmpPRect := FRect(  0, 0, Round(ARSFactor*ASrcWidth)-1,
                              Round(ARSFactor*ASrcHeight)-1 );
    TmpURect := FRect(  AURect.Left +
                0.5*(1/ARSFactor-1)*(AURect.Right-aURect.Left)/(ASrcWidth-1),
                        AURect.Top +
                0.5*(1/ARSFactor-1)*(AURect.Bottom-AURect.Top)/(ASrcHeight-1),
                        AURect.Right -
                0.5*(1/ARSFactor-1)*(AURect.Right-AURect.Left)/(ASrcWidth-1),
                        AURect.Bottom -
                0.5*(1/ARSFactor-1)*(AURect.Bottom-AURect.Top)/(ASrcHeight-1) );
  end;
  P2U := N_CalcAffCoefs4( TmpPRect, TmpURect );
  U2P := N_CalcAffCoefs4( TmpURect, TmpPRect );
end; // end of procedure N_CalcAffCoefs4RS

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcAffCoefs6(repers)
//************************************************* N_CalcAffCoefs6(repers) ***
// Calculate Six Affine Transformation Coefficients by two given input and 
// output 3DPRepers (3DPReper - three Double Points)
//
//     Parameters
// AInpReper - input 3DPReper
// AOutReper - output 3DPReper
// Result    - Returns Six Affine Transformation Coefficients
//
function N_CalcAffCoefs6( const AInpReper, AOutReper: TN_3DPReper ): TN_AffCoefs6;
var
  dxinp2, dyinp2, dxinp3, dyinp3: double;
  dxout2, dyout2, dxout3, dyout3: double;
  ax, ay, zx, zy: double ;
  Label Dyinp2_eq_0, Dxinp2_eq_0, Calc_sxsy;
begin
  dxinp2 := AInpReper.P2.X - AInpReper.P1.X;
  dyinp2 := AInpReper.P2.Y - AInpReper.P1.Y;

  dxinp3 := AInpReper.P3.X - AInpReper.P1.X;
  dyinp3 := AInpReper.P3.Y - AInpReper.P1.Y;

  dxout2 := AOutReper.P2.X - AOutReper.P1.X;
  dyout2 := AOutReper.P2.Y - AOutReper.P1.Y;

  dxout3 := AOutReper.P3.X - AOutReper.P1.X;
  dyout3 := AOutReper.P3.Y - AOutReper.P1.Y;

  if( dyinp2 = 0. ) then goto Dyinp2_eq_0;
  ay := dyinp3 / dyinp2;

  if (dxinp2 = 0. ) then goto Dxinp2_eq_0;
  ax := dxinp3 / dxinp2;

  zx := dxinp3 - dxinp2*ay ;
  Assert( Abs( zx ) > 1.0e-12, 'Bad Coefs' ); // dxinp2/dyinp2 = dxinp3/dyinp3
  Result.cxx := ( dxout3 - dxout2*ay ) / zx;

  zy := dyinp3 - dyinp2*ax ;
  Result.cxy := ( dxout3 - dxout2*ax ) / zy;

  Result.cyx := (  dyout3 -  dyout2*ay ) / zx;
  Result.cyy := (  dyout3 -  dyout2*ax ) / zy;

  goto Calc_sxsy;

  Dyinp2_eq_0 : // dyinp2 = 0

  Result.cxx :=  dxout2 /  dxinp2 ;
  Result.cxy := (dxout3 - dxinp3*Result.cxx) / dyinp3;
  Result.cyx :=  dyout2 /  dxinp2;
  Result.cyy := (dyout3 - dxinp3*Result.cyx) / dyinp3;

  goto Calc_sxsy ;

  Dxinp2_eq_0 : // dxinp2 = 0

  Result.cxy :=  dxout2 /  dyinp2;
  Result.cxx := (dxout3 - dyinp3*Result.cxy) / dxinp3;
  Result.cyy :=  dyout2 /  dyinp2;
  Result.cyx := (dyout3 - dyinp3*Result.cyy) / dxinp3;

  Calc_sxsy : //****** Cxx, Cxy, Cyx, Cyy are OK, calc SX, SY

  Result.sx := ( AOutReper.P1.X - Result.cxx*AInpReper.P1.X - Result.cxy*AInpReper.P1.Y );
  Result.sy := ( AOutReper.P1.Y - Result.cyx*AInpReper.P1.X - Result.cyy*AInpReper.P1.Y );
end; // end of function N_CalcAffCoefs6(repers)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcAffCoefs6(TransfType)
//********************************************* N_CalcAffCoefs6(TransfType) ***
// Calculate WinGDI XFORM structure and input Integer Rectangle by given 
// transformation type and output Integer Rectangle
//
//     Parameters
// ACTransfType - transformation type
// AOutRect     - output Integer Rectangle
// APXForm      - pointer to resulting WinGDI XFORM structure
// APInpRect    - pointer to resulting input Integer Rectangle
//
// XFORM structure specifies a world-space to page-space transformation 
// coefficients
//
procedure N_CalcAffCoefs6( ACTransfType: TN_CTransfType; const AOutRect: TRect;
                                 const APXForm: PXForm; const APInpRect: PRect );
var
  DX, DY: integer;
  InpRect: TRect;
  InpDRep, OutDRep: TN_3DPReper;
begin
  if ACTransfType = ctfNoTransform then
  begin
    if APXForm <> nil then
      APXForm^ := N_ConvToXFORM( N_DefAffCoefs6 );

    if APInpRect <> nil then
      with InpDRep do APInpRect^ := AOutRect;

    Exit;
  end; // if ACTransfType = ctfNoTransform then

  with AOutRect do
  begin
    DX := Right  - Left;
    DY := Bottom - Top;
  end;

  if (ACTransfType = ctfRotate90CCW) or (ACTransfType = ctfRotate90CW) then
    InpRect := Rect( 0, 0, DY, DX )  // rotate case
  else
    InpRect := Rect( 0, 0, DX, DY ); // flip case

//  InpRect := Rect( 0, 0, DX, DY ); // flip case debug

  InpDRep := D3PReper( InpRect );

  case ACTransfType of
    ctfFlipAlongX:  with AOutRect do OutDRep := D3PReper(
                                     Right,Top,   Left,Top,   Right,Bottom );
    ctfFlipAlongY:  with AOutRect do OutDRep := D3PReper(
                                     Left,Bottom, Right,Bottom, Left,Top );
    ctfRotate90CCW: with AOutRect do OutDRep := D3PReper(
                                     Left,Bottom, Left,Top,   Right,Bottom );
    ctfRotate90CW:  with AOutRect do OutDRep := D3PReper(
                                     Right,Top,  Right,Bottom, Left,Top );
    else
      OutDRep := InpDRep; // a precaution
  end; // case ACTransfType of

//  with AOutRect do OutDRep := D3PReper( 10, 5, DY+10, 5, 10, DX+5 ); // for debug
//  with AOutRect do OutDRep := D3PReper( Left, Top, Right+150, Top+50, Left, Bottom ); // for debug
//  with AOutRect do OutDRep := D3PReper( Left, Bottom, Left, Bottom-DY, Left+DX, Bottom );
//  with AOutRect do OutDRep := D3PReper( Left, Bottom, Left, Top, Right, Bottom );
//  with AOutRect do OutDRep := InpDRep; // identity for debug

  if APXForm <> nil then
    APXForm^ := N_ConvToXFORM( N_CalcAffCoefs6( InpDRep, OutDRep ) );

  if APInpRect <> nil then
//    with InpDRep do APInpRect^ := InpRect; // зачем with InpDRep do ????
    APInpRect^ := InpRect;
end; // end of procedure N_CalcAffCoefs6(TransfType)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcAffCoefs6(params)
//************************************************* N_CalcAffCoefs6(params) ***
// Calculate Six Affine Transformation Coefficients by given flags and 
// convertion parameters
//
//     Parameters
// AFlags    - calculation mode:
//#F
//   bits0-3($00F) - main calculation mode:
//    =1 - shift coordinates by adding APParams[0] to X-coordinates, APParams[1]
//                                        to Y-coordinates,
//    =2 - scale coordinates by multiplying X-coordinates by APParams[0],
//                                     Y-coordinates by APParams[1],
//    =3 - rotate coordinates by angle APParams[0] (in degree) with rotation
//         center at ( APParams[1], APParams[2] ) point coordinates,
//    =4 - change coordinates by coordinates of TWO points so that
//                point (APParams[0],APParams[1])  became (APParams[4],APParams[5])
//                point (APParams[2],APParams[3])  became (APParams[6],APParams[7])
//                (parallel transformation by shift and scale
//                without rotation, dx/dy quotient may be changed)
//    =5 - change coordinates by coordinates of TWO points so that
//                point (APParams[0],APParams[1])  became (APParams[4],APParams[5])
//                point (APParams[2],APParams[3])  became (APParams[6],APParams[7])
//                (transformation may include rotation,
//                but dx/dy quotent can not be changed)
//    =6 - change coordinates by coordinates of THREE points so that
//                point (APParams[0],APParams[1])  became (APParams[6],APParams[7])
//                point (APParams[2],APParams[3])  became (APParams[8],APParams[9])
//                point (APParams[4],APParams[5])  became (APParams[10],APParams[11])
//    =7 - change coordinates by given affine conversion coefficients
//                cxx, cxy, sx are in APParams[0] - APParams[2]
//                cyx, cyy, sy are in APParams[3] - APParams[5]
//   bit4($010) =0 - save calculated coefficients in AffCoefs6
//              =1 - first combine calculated coefficients with coefficients
//                   from AffCoefs6 and save combined coefficients in AffCoefs6
//#/F
// AffCoefs6 - resulting (or input, if bit4 AFlags=1) Six Affine Transformation 
//             Coefficients
// APParams  - pointer to double parameters
//
procedure N_CalcAffCoefs6( AFlags: integer; var AffCoefs6: TN_AffCoefs6;
                                                          APParams: PDouble );

var
  tacc: TN_AffCoefs6;
  ddelta, dcos, dsin: double;
  inprep, outrep, tmprep: TN_3DPReper;
  tPP: PDouble;
  Label tacc_OK, Make_tacc;

  function P( PInd: integer ): double; // local, to reduce code size
  begin
    Result := PDouble(TN_BytesPtr(APParams) + PInd*Sizeof(double))^;
  end; // localfunction P

begin
  case AFlags and $0F of

  1: begin //*** shift coordinates by adding prms[0], prms[1]
    tacc.cxx := 1.0;
    tacc.cyy := 1.0;
    tacc.cxy := 0.0;
    tacc.cyx := 0.0;
    tacc.sx  := P(0);
    tacc.sy  := P(1);
    goto tacc_OK;
  end; // 1: begin //*** shift coordinates by adding P(0), P(1)

  2: begin //*** scale coordinates by multiplying by P(0), P(1)
    tacc.cxy := 0.0;
    tacc.cyx := 0.0;
    tacc.sx  := 0.0;
    tacc.sy  := 0.0;
    tacc.cxx := P(0);
    tacc.cyy := P(1);
    goto tacc_OK;
  end; // 2: begin //*** scale coordinates by multiplying by P(0), P(1)

  3: begin //*** rotate coordinates by angle P(0) (in degree) with
           //    rotation center at ( P(1), P(2) )

    inprep.P1.X := P(1);
    inprep.P3.X := P(1);
    outrep.P1.X := P(1);

    inprep.P1.Y := P(2);
    inprep.P2.Y := P(2);
    outrep.P1.Y := P(2);

    if( inprep.P1.X > 0 ) then ddelta :=  inprep.P1.X + 1.0
                          else ddelta := -inprep.P1.X + 1.0;

    inprep.P2.X := inprep.P1.X + ddelta;
    inprep.P3.Y := inprep.P1.Y + ddelta;

    dsin := sin( P(0)*N_PI/180.0 )*ddelta;
    dcos := cos( P(0)*N_PI/180.0 )*ddelta;

    outrep.P2.X := outrep.P1.X + dcos;
    outrep.P2.Y := outrep.P1.Y - dsin;
    outrep.P3.X := outrep.P1.X + dsin;
    outrep.P3.Y := outrep.P1.Y + dcos;
    goto Make_tacc;
  end; // 3: begin //*** rotate coordinates by angle P(0) (in degree) with

  4: begin //*** conv coordinates by two points whithout rotation, any dx/dy
    tPP := APParams;
    move( tPP^, inprep, 4*sizeof(double) );
    Inc( tPP, 4 );
    move( tPP^, outrep, 4*sizeof(double) );

    inprep.P3.X := inprep.P1.X;
    inprep.P3.Y := P(3);
    outrep.P3.X := outrep.P1.X;
    outrep.P3.Y := P(7);
    goto Make_tacc;
  end; // 4: begin //*** conv coordinates by two points whithout rotation, any dx/dy

  5: begin //*** conv coordinates by two points whith rotation, preserv dx/dy
    tPP := APParams;
    move( tPP^, inprep, 4*sizeof(double) );
    Inc( tPP, 4 );
    move( tPP^, outrep, 4*sizeof(double) );

    inprep.P3.X := inprep.P2.X + inprep.P2.Y - inprep.P1.Y;
    inprep.P3.Y := inprep.P2.Y - inprep.P2.X + inprep.P1.X;
    outrep.P3.X := outrep.P2.X + outrep.P2.Y - outrep.P1.Y;
    outrep.P3.Y := outrep.P2.Y - outrep.P2.X + outrep.P1.X;
    goto Make_tacc;
  end; // 5: begin //*** conv coordinates by two points whith rotation, preserv dx/dy

  6: begin //** conv coordinates by three points (by two full repers)
    tPP := APParams;
    move( tPP^, inprep, 6*sizeof(double) );
    Inc( tPP, 6 );
    move( tPP^, outrep, 6*sizeof(double) );
    goto Make_tacc;
  end; // 6: begin //** conv coordinates by three points (by two full repers)

  7: begin //** conv coordinates are given explicitely
    tacc := TN_PAffCoefs6(APParams)^;
    goto tacc_OK;
  end; // 7: begin //** conv coordinates are given explicitely

  else Assert( False, 'Bad AFlags' );

  end; // case AFlags and $0F of

  Make_tacc: //*************
    tacc := N_CalcAffCoefs6( inprep, outrep );

  tacc_OK: //***************

  if (AFlags and $010) = 0 then
  begin
    AffCoefs6 := tacc;
    Exit; // all done
  end;

  //*** Here : combine coefs (AffCoefs6 and tacc) before saving in AffCoefs6

  inprep.P1.X := 0.0;
  inprep.P1.Y := 0.0;
  inprep.P2.X := 1.0;
  inprep.P2.Y := 0.0;
  inprep.P3.X := 0.0;
  inprep.P3.Y := 1.0;

  N_AffConv6D2DPoints( PDPoint(@inprep), PDPoint(@tmprep), 3, AffCoefs6 );
  N_AffConv6D2DPoints( PDPoint(@tmprep), PDPoint(@outrep), 3, tacc );
  AffCoefs6 := N_CalcAffCoefs6( inprep, outrep );
end; // end of procedure N_CaclAffCoefs6(params)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcAffCoefs6(StrParams)
//********************************************** N_CalcAffCoefs6(StrParams) ***
// Calculate Six Affine Transformation Coefficients by given convertion 
// parameters as string using N_CaclAffCoefs6(params)
//
//     Parameters
// AParamsStr - given params as string ( hex Flags and needed number of doubles
// AffCoefs6  - resulting (or input, if bit4 AFlags=1) Six Affine Transformation
//              Coefficients
//
procedure N_CalcAffCoefs6( AParamsStr: string; var AffCoefs6: TN_AffCoefs6 );
var
  i, Flags: integer;
  DParams: TN_DArray;
begin
  SetLength( DParams, 12 );

  Flags := N_ScanInteger( AParamsStr );

  for i := 0 to 11 do // along all possible params
  begin
    DParams[i] := N_ScanDouble( AParamsStr );
    if (DParams[i] = N_NotADouble) or (AParamsStr = '') then
      Break;
  end; // for i := 0 to 11 do // along all possible params

  N_CalcAffCoefs6( Flags, AffCoefs6, @DParams[0] );
end; // procedure N_CalcAffCoefs6

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ComposeAffCoefs6
//****************************************************** N_ComposeAffCoefs6 ***
// Calculate resulting AffCoefs6 by two given AffCoefs6
//
//     Parameters
// AAffCoefs1 - second transformation (after AAffCoefs2)
// AAffCoefs2 - first transformation (before AAffCoefs1)
// Result     - Returns resulting AffCoefs6() = AAffCoefs1 ( AAffCoefs2() )
//
function N_ComposeAffCoefs6( AAffCoefs1, AAffCoefs2: TN_AffCoefs6 ): TN_AffCoefs6;
begin
  Result.CXX := AAffCoefs1.CXX*AAffCoefs2.CXX + AAffCoefs1.CXY*AAffCoefs2.CYX;
  Result.CXY := AAffCoefs1.CXX*AAffCoefs2.CXY + AAffCoefs1.CXY*AAffCoefs2.CYY;
  Result.SX  := AAffCoefs1.CXX*AAffCoefs2.SX  + AAffCoefs1.CXY*AAffCoefs2.SY  + AAffCoefs1.SX;

  Result.CYX := AAffCoefs1.CYX*AAffCoefs2.CXX + AAffCoefs1.CYY*AAffCoefs2.CYX;
  Result.CYY := AAffCoefs1.CYX*AAffCoefs2.CXY + AAffCoefs1.CYY*AAffCoefs2.CYY;
  Result.SY  := AAffCoefs1.CYX*AAffCoefs2.SX  + AAffCoefs1.CYY*AAffCoefs2.SY  + AAffCoefs1.SY;
end; // end of function N_ComposeAffCoefs6

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ConvToXForm
//*********************************************************** N_ConvToXForm ***
// Convert Six Affine Transformation Coefficients to WinGDI XFORM structure
//
//     Parameters
// AAffCoefs6 - Six Affine Transformation Coefficients
// Result     - Returns WinGDI XFORM structure
//
function N_ConvToXForm( const AAffCoefs6: TN_AffCoefs6 ): TXForm;
begin
  with Result, AAffCoefs6 do
  begin
    eM11 := CXX;
    eM12 := CYX;
    eM22 := CYY;
    eM21 := CXY;
    eDx  := SX;
    eDy  := SY;
  end;
end; // function N_ConvToXForm

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv6Points
//******************************************************** N_AffConv6Points ***
// Convert given number of Points Double Coordinates to Float Points by given 
// Six Affine Transformation Coefficients
//
//     Parameters
// APInpX      - pointer to first Point Input Double X coordinate
// APInpY      - pointer to first Point Input Double Y coordinate
// APOutPoints - pointer to first Output Float Point (POutPoints should points 
//               to enough reserved memory)
// ANumPoints  - number of Points to convert
// AAffCoefs6  - Six Affine Transformation Coefficients
//
procedure N_AffConv6Points( APInpX, APInpY: PDouble; APOutPoints: PFPoint;
                            ANumPoints: integer; const AAffCoefs6: TN_AffCoefs6 );
var
  i: integer;
begin
  with AAffCoefs6 do
  for i := 1 to ANumPoints do
  with APOutPoints^ do
  begin
    X := CXX*APInpX^;
    Y := CYX*APInpX^;
    Inc(APInpX);

    X := X + CXY*APInpY^ + SX;
    Y := Y + CYY*APInpY^ + SY;
    Inc(APInpY);

    Inc(APOutPoints);
  end; // with AffCoefs6 do  for i := 1 to NumPoints do
end; // procedure N_AffConv6Points((PDX,PDY->PFP))

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv6D2DPoints(2xPDPoint)
//****************************************** N_AffConv6D2DPoints(2xPDPoint) ***
// Convert given number of Double Points to Double Points by given Six Affine 
// Transformation Coefficients
//
//     Parameters
// APInpPoints - pointer to first Input Double Point
// APOutPoints - pointer to first Output Double  Point (POutPoints should points
//               to enough reserved memory)
// ANumPoints  - number of Points to convert
// AAffCoefs6  - Six Affine Transformation Coefficients
//
procedure N_AffConv6D2DPoints( APInpPoints, APOutPoints: PDPoint;
                          ANumPoints: integer; const AAffCoefs6: TN_AffCoefs6 );
var
  i: integer;
begin
  with AAffCoefs6 do
  for i := 1 to ANumPoints do
  begin
    with APInpPoints^ do
    begin
      APOutPoints^.X := CXX*X + CXY*Y + SX;
      APOutPoints^.Y := CYX*X + CYY*Y + SY;
    end;
    Inc(APInpPoints);
    Inc(APOutPoints);
  end; // with AffCoefs6 do  for i := 1 to NumPoints do
end; // procedure N_AffConv6D2DPoints(2xPDPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv6D2DPoints(4xPDouble)
//****************************************** N_AffConv6D2DPoints(4xPDouble) ***
// Convert given number of Points Double Coordinates by given Six Affine 
// Transformation Coefficients
//
//     Parameters
// APInpX     - pointer to first Point Input Double X coordinate
// APInpY     - pointer to first Point Input Double Y coordinate
// APOutX     - pointer to first Point Output Double X coordinate
// APOutY     - pointer to first Point Output Double Y coordinate
// AStepInpX  - step over pointer to Input Double X coordinate
// AStepInpY  - step over pointer to Input Double Y coordinate
// AStepOutX  - step over pointer to Output Double X coordinate
// AStepOutY  - step over pointer to Output Double Y coordinate
// ANumPoints - number of Points to convert
// AAffCoefs6 - Six Affine Transformation Coefficients
//
procedure N_AffConv6D2DPoints( APInpX, APInpY, APOutX, APOutY: Pointer;
                               AStepInpX, AStepInpY, AStepOutX, AStepOutY: integer;
                            ANumPoints: integer; const AAffCoefs6: TN_AffCoefs6 );
var
  i: integer;
  PInpX, PInpY, POutX, POutY: TN_BytesPtr;
  // PDouble;
begin
  PInpX := APInpX;
  PInpY := APInpY;
  POutX := APOutX;
  POutY := APOutY;

  with AAffCoefs6 do
  for i := 0 to ANumPoints-1 do
  begin
    PDouble(POutX)^:= CXX * PDouble(PInpX)^ + CXY * PDouble(PInpY)^ + SX;
    Inc( POutX, AStepOutX );
    PDouble(POutY)^:= CYX * PDouble(PInpX)^ + CYY * PDouble(PInpY)^ + SY;
    Inc( PInpX, AStepInpX );
    Inc( PInpY, AStepInpY );
    Inc( POutY, AStepOutY );
  end; // for i := 0 to NumPoints-1 do
end; // end of procedure N_AffConv6D2DPoints(4xPDouble)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv6D2DPoints(2xPDoubleDPArray)
//*********************************** N_AffConv6D2DPoints(2xPDoubleDPArray) ***
// Convert given number of Points Double Coordinates to Double Points Array by 
// given Six Affine Transformation Coefficients
//
//     Parameters
// APInpX     - pointer to first Point Input Double X coordinate
// APInpY     - pointer to first Point Input Double Y coordinate
// ADPArray   - Double Points Array
// ANumPoints - number of Points to convert
// AAffCoefs6 - Six Affine Transformation Coefficients
//
procedure N_AffConv6D2DPoints( APInpX, APInpY: Pointer;
                               var ADPArray: TN_DPArray;
                            ANumPoints: integer; const AAffCoefs6: TN_AffCoefs6 );
begin
  if Length(ADPArray) < ANumPoints then
    SetLength( ADPArray, ANumPoints );

  N_AffConv6D2DPoints( APInpX, APInpY, @ADPArray[0].X, @ADPArray[0].Y,
               Sizeof(double), Sizeof(double), Sizeof(TDPoint), Sizeof(TDPoint),
                                                         ANumPoints, AAffCoefs6 );
end; // end of procedure N_AffConv6D2DPoints(2xPDoubleDPArray)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv6D2DScalar
//***************************************************** N_AffConv6D2DScalar ***
// Convert given (Ascalar, Ascalar) Double Point by given Six Affine 
// Transformation Coefficients to Double Point
//
//     Parameters
// Ascalar    - source Point Double X and Y coordinate
// AAffCoefs6 - Six Affine Transformation Coefficients
// Result     - Returns converted Double Point
//
function N_AffConv6D2DScalar( const Ascalar: double;
                                     const AAffCoefs6: TN_AffCoefs6 ): TDPoint;
begin
  N_AffConv6D2DPoints( @Ascalar, @Ascalar, @Result.X, @Result.Y,
                                                    0, 0, 0, 0, 1, AAffCoefs6 );
end; // end of function N_AffConv6D2DScalar

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv6D2DPoint
//****************************************************** N_AffConv6D2DPoint ***
// Convert given Point Double Coordinates by given Six Affine Transformation 
// Coefficients to Double Point
//
//     Parameters
// AX         - source Point Double X coordinate
// AY         - source Point Double Y coordinate
// AAffCoefs6 - Six Affine Transformation Coefficients
// Result     - Returns converted Double Point
//
function N_AffConv6D2DPoint( const AX, AY: double;
                                     const AAffCoefs6: TN_AffCoefs6 ): TDPoint;
begin
  N_AffConv6D2DPoints( @AX, @AY, @Result.X, @Result.Y,
                                                    0, 0, 0, 0, 1, AAffCoefs6 );
end; // end of function N_AffConv6D2DPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv6D2FPoint
//****************************************************** N_AffConv6D2FPoint ***
// Convert given Double Point by given Six Affine Transformation Coefficients to
// Float Point
//
//     Parameters
// ADPoint    - source Double Point
// AAffCoefs6 - Six Affine Transformation Coefficients
// Result     - Returns converted Double Point
//
function N_AffConv6D2FPoint( const ADPoint: TDPoint;
                                      const AAffCoefs6: TN_AffCoefs6 ): TFPoint;
var
  WrkDP: TDPoint;
begin
  N_AffConv6D2DPoints( @ADPoint, @WrkDP, 1, AAffCoefs6 );
  Result.X := WrkDP.X;
  Result.Y := WrkDP.Y;
end; // end of function N_AffConv6D2FPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv6D2IRect
//******************************************************* N_AffConv6D2IRect ***
// Convert given Double Rectangle to ordered Integer Rectangle by given Six 
// Affine Transformation Coefficients to Integer Rectangle
//
//     Parameters
// ADRect     - source Double Rectangle
// AAffCoefs6 - Six Affine Transformation Coefficients
// Result     - Returns converted ordered Integer Rectangle
//
// In ordered rectangle Left <= Right and Top <= Bottom.
//
function N_AffConv6D2IRect( const ADRect: TDRect;
                                     const AAffCoefs6: TN_AffCoefs6 ): TRect;
var
  ResDRect: TDRect;
begin
  N_AffConv6D2DPoints ( @ADRect.TopLeft, @ResDRect.TopLeft, 2, AAffCoefs6 );
  Result := N_IRectOrder ( IRect( ResDRect ) );
end; // end of function N_AffConv6D2IRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv6D2DRect
//******************************************************* N_AffConv6D2DRect ***
// Convert given Double Rectangle to ordered Double Rectangle by given Six 
// Affine Transformation Coefficients to Double Rectangle
//
//     Parameters
// ADRect     - source Double Rectangle
// AAffCoefs6 - Six Affine Transformation Coefficients
// Result     - Returns converted ordered Double Rectangle
//
// In ordered rectangle Left <= Right and Top <= Bottom.
//
function N_AffConv6D2DRect( const ADRect: TDRect;
                                     const AAffCoefs6: TN_AffCoefs6 ): TDRect;
begin
  N_AffConv6D2DPoints ( @ADRect.TopLeft, @Result.TopLeft, 2, AAffCoefs6 );
  Result := N_DRectOrder ( Result );
end; // end of function N_AffConv6D2DRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv8D2DPoints(2xPDPoint)
//****************************************** N_AffConv8D2DPoints(2xPDPoint) ***
// Convert given number of Double Points to Double Points by given Eight Affine 
// Projective Transformation Coefficients
//
//     Parameters
// APInpPoints - pointer to first Input Double Point
// APOutPoints - pointer to first Output Double  Point (POutPoints should points
//               to enough reserved memory)
// ANumPoints  - number of Points to convert
// AAffCoefs8  - Eight Affine Projective Transformation Coefficients
//
procedure N_AffConv8D2DPoints( APInpPoints, APOutPoints: PDPoint;
                          ANumPoints: integer; const AAffCoefs8: TN_AffCoefs8 );
var
  i: integer;
  W: double;
begin
  with AAffCoefs8 do
  for i := 1 to ANumPoints do
  begin
    with APInpPoints^ do
    begin
      W := WX*X + WY*Y + 1.0;
      APOutPoints^.X := (CXX*X + CXY*Y + SX) / W;
      APOutPoints^.Y := (CYX*X + CYY*Y + SY) / W;
    end;
    Inc(APInpPoints);
    Inc(APOutPoints);
  end; // with AffCoefs8 do  for i := 1 to NumPoints do
end; // procedure N_AffConv8D2DPoints(2xPDPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv8D2DPoints(4xPDouble)
//****************************************** N_AffConv8D2DPoints(4xPDouble) ***
// Convert given number of Points Double Coordinates by given Eight Affine 
// Projective Transformation Coefficients
//
//     Parameters
// APInpX     - pointer to first Point Input Double X coordinate
// APInpY     - pointer to first Point Input Double Y coordinate
// APOutX     - pointer to first Point Output Double X coordinate
// APOutY     - pointer to first Point Output Double Y coordinate
// AStepInpX  - step over pointer to Input Double X coordinate
// AStepInpY  - step over pointer to Input Double Y coordinate
// AStepOutX  - step over pointer to Output Double X coordinate
// AStepOutY  - step over pointer to Output Double Y coordinate
// ANumPoints - number of Points to convert
// AAffCoefs8 - Eight Affine Projective Transformation Coefficients
//
procedure N_AffConv8D2DPoints( APInpX, APInpY, APOutX, APOutY: Pointer;
                               AStepInpX, AStepInpY, AStepOutX, AStepOutY: integer;
                            ANumPoints: integer; const AAffCoefs8: TN_AffCoefs8 );
var
  i: integer;
  W: double;
  PInpX, PInpY, POutX, POutY: TN_BytesPtr;
begin
  PInpX := APInpX;
  PInpY := APInpY;
  POutX := APOutX;
  POutY := APOutY;

  with AAffCoefs8 do
  for i := 0 to ANumPoints-1 do
  begin
    W := WX * PDouble(PInpX)^ +  WY * PDouble(PInpY)^ + 1.0;
    PDouble(POutX)^:= (CXX * PDouble(PInpX)^ + CXY * PDouble(PInpY)^ + SX) / W;
    Inc( POutX, AStepOutX );
    PDouble(POutY)^:= (CYX * PDouble(PInpX)^ + CYY * PDouble(PInpY)^ + SY) / W;
    Inc( PInpX, AStepInpX );
    Inc( PInpY, AStepInpY );
    Inc( POutY, AStepOutY );
  end; // for i := 0 to NumPoints-1 do
end; // end of procedure N_AffConv8D2DPoints(4xPDouble)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv8D2DPoints(2xPDoubleDPArray)
//*********************************** N_AffConv8D2DPoints(2xPDoubleDPArray) ***
// Convert given number of Points Double Coordinates to Double Points Array by 
// given Eight Affine Projective Transformation Coefficients
//
//     Parameters
// APInpX     - pointer to first Point Input Double X coordinate
// APInpY     - pointer to first Point Input Double Y coordinate
// ADPArray   - Double Points Array
// ANumPoints - number of Points to convert
// AAffCoefs8 - Eight Affine Projective Transformation Coefficients
//
procedure N_AffConv8D2DPoints( APInpX, APInpY: Pointer;
                               var ADPArray: TN_DPArray;
                            ANumPoints: integer; const AAffCoefs8: TN_AffCoefs8 );
begin
  if Length(ADPArray) < ANumPoints then
    SetLength( ADPArray, ANumPoints );

  N_AffConv8D2DPoints( APInpX, APInpY, @ADPArray[0].X, @ADPArray[0].Y,
               Sizeof(double), Sizeof(double), Sizeof(TDPoint), Sizeof(TDPoint),
                                                         ANumPoints, AAffCoefs8 );
end; // end of procedure N_AffConv8D2DPoints(2xPDoubleDPArray)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv8D2DScalar
//***************************************************** N_AffConv8D2DScalar ***
// Convert given (Ascalar, Ascalar) Double Point by given Eight Affine 
// Projective Transformation Coefficients to Double Point
//
//     Parameters
// Ascalar    - source Point Double X and Y coordinate
// AAffCoefs8 - Eight Affine Projective Transformation Coefficients
// Result     - Returns converted Double Point
//
function N_AffConv8D2DScalar( const Ascalar: double;
                                     const AAffCoefs8: TN_AffCoefs8 ): TDPoint;
begin
  N_AffConv8D2DPoints( @Ascalar, @Ascalar, @Result.X, @Result.Y,
                                                    0, 0, 0, 0, 1, AAffCoefs8 );
end; // end of function N_AffConv8D2DScalar

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv8D2DPoint(2D)
//************************************************** N_AffConv8D2DPoint(2D) ***
// Convert given Point Double Coordinates by given Eight Affine Projective 
// Transformation Coefficients to Double Point
//
//     Parameters
// AX         - source Point Double X coordinate
// AY         - source Point Double Y coordinate
// AAffCoefs8 - Eight Affine Projective Transformation Coefficients
// Result     - Returns converted Double Point
//
function N_AffConv8D2DPoint( const AX, AY: double;
                                     const AAffCoefs8: TN_AffCoefs8 ): TDPoint;
begin
  N_AffConv8D2DPoints( @AX, @AY, @Result.X, @Result.Y,
                                                    0, 0, 0, 0, 1, AAffCoefs8 );
end; // end of function N_AffConv8D2DPoint(2D)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv8D2DPoint(1DP)
//************************************************* N_AffConv8D2DPoint(1DP) ***
// Convert given Double Point by given Eight Affine Projective Transformation 
// Coefficients to Double Point
//
//     Parameters
// ADPoint    - source Double Point
// AAffCoefs8 - Eight Affine Projective Transformation Coefficients
// Result     - Returns converted Double Point
//
function N_AffConv8D2DPoint( const ADPoint: TDPoint;
                                     const AAffCoefs8: TN_AffCoefs8 ): TDPoint;
begin
  N_AffConv8D2DPoints( @ADPoint.X, @ADPoint.Y, @Result.X, @Result.Y,
                                                    0, 0, 0, 0, 1, AAffCoefs8 );
end; // end of function N_AffConv8D2DPoint(1DP)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv8D2IRect
//******************************************************* N_AffConv8D2IRect ***
// Convert given Double Rectangle to ordered Integer Rectangle by given Eight 
// Affine Projective Transformation Coefficients to Integer Rectangle
//
//     Parameters
// ADRect     - source Double Rectangle
// AAffCoefs8 - Eight Affine Projective Transformation Coefficients
// Result     - Returns converted ordered Integer Rectangle
//
// In ordered rectangle Left <= Right and Top <= Bottom.
//
function N_AffConv8D2IRect( const ADRect: TDRect;
                                     const AAffCoefs8: TN_AffCoefs8 ): TRect;
var
  ResDRect: TDRect;
begin
  N_AffConv8D2DPoints ( @ADRect.TopLeft, @ResDRect.TopLeft, 2, AAffCoefs8 );
  Result := N_IRectOrder ( IRect( ResDRect ) );
end; // end of function N_AffConv8D2IRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffCoefs8(8D)
//********************************************************* N_AffCoefs8(8D) ***
// Calculate Eight Affine Projective Transformation Coefficients by eight given 
// double values
//
//     Parameters
// ACXX   - X-coordinate factor
// ACXY   - rotate factor (X-coordinate by Y-coordinate)
// ASX    - X-coordinate shift
// AWX    - X-coordinate projective quotient
// ACYX   - rotate factor (Y-coordinate by X-coordinate)
// ACYY   - Y-coordinate factor
// ASY    - Y-coordinate shift
// AWY    - Y-coordinate projective quotient
// Result - Returns Eight Affine Transformation Coefficients
//
function N_AffCoefs8( const ACXX, ACXY, ASX, AWX, ACYX, ACYY, ASY, AWY: double ): TN_AffCoefs8;
begin
  Result.CXX := ACXX;
  Result.CXY := ACXY;
  Result.SX  := ASX;
  Result.WX  := AWX;

  Result.CYX := ACYX;
  Result.CYY := ACYY;
  Result.SY  := ASY;
  Result.WY  := AWY;
end; // end of function N_AffCoefs8(8D)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffCoefs8(AC4)
//******************************************************** N_AffCoefs8(AC4) ***
// Convert given Four Affine Transformation Coefficients to Eight Affine 
// Projective Transformation Coefficients
//
//     Parameters
// AAffCoefs4 - source Four Affine Transformation Coefficients
// Result     - Returns Eight Affine Projective Transformation Coefficients
//
function N_AffCoefs8( const AAffCoefs4: TN_AffCoefs4 ): TN_AffCoefs8;
begin
  Result := N_DefAffCoefs8;

  Result.CXX := AAffCoefs4.CX;
  Result.SX  := AAffCoefs4.SX;
  Result.CYY := AAffCoefs4.CY;
  Result.SY  := AAffCoefs4.SY;
end; // end of function N_AffCoefs8(AC4)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffCoefs8(AC6)
//******************************************************** N_AffCoefs8(AC6) ***
// Convert given Six Affine Transformation Coefficients to Eight Affine 
// Projective Transformation Coefficients
//
//     Parameters
// AAffCoefs6 - source Six Affine Transformation Coefficients
// Result     - Returns Eight Affine Projective Transformation Coefficients
//
function N_AffCoefs8( const AAffCoefs6: TN_AffCoefs6 ): TN_AffCoefs8;
begin
  Result.CXX := AAffCoefs6.CXX;
  Result.CYX := AAffCoefs6.CYX;
  Result.SX  := AAffCoefs6.SX;
  Result.WX  := 0;

  Result.CXY := AAffCoefs6.CXY;
  Result.CYY := AAffCoefs6.CYY;
  Result.SY  := AAffCoefs6.SY;
  Result.WY  := 0;
end; // end of function N_AffCoefs8(AC6)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ComposeAffCoefs8
//****************************************************** N_ComposeAffCoefs8 ***
// Calculate Eight Affine Projective Transformation Coefficients by two given 
// AffCoefs8
//
//     Parameters
// AAffCoefs1 - convertible AffCoefs8
// AAffCoefs2 - transformative AffCoefs8
// Result     - Returns Eight Affine Projective Transformation Coefficients as a
//              result of transformation AffCoefs1 by AffCoefs2
//
function N_ComposeAffCoefs8( AAffCoefs1, AAffCoefs2: TN_AffCoefs8 ): TN_AffCoefs8;
var
  W: double;
begin
  W := AAffCoefs1.WX*AAffCoefs2.SX + AAffCoefs1.WY*AAffCoefs2.SY + 1;

  Result.CXX := (AAffCoefs1.CXX*AAffCoefs2.CXX + AAffCoefs1.CXY*AAffCoefs2.CYX + AAffCoefs1.SX*AAffCoefs2.WX)/W;
  Result.CXY := (AAffCoefs1.CXX*AAffCoefs2.CXY + AAffCoefs1.CXY*AAffCoefs2.CYY + AAffCoefs1.SX*AAffCoefs2.WY)/W;
  Result.SX  := (AAffCoefs1.CXX*AAffCoefs2.SX  + AAffCoefs1.CXY*AAffCoefs2.SY  + AAffCoefs1.SX*1.0)/W;
  Result.WX  := (AAffCoefs1.WX*AAffCoefs2.CXX  + AAffCoefs1.WY*AAffCoefs2.CYX  + 1.0*AAffCoefs2.WX)/W;

  Result.CYX := (AAffCoefs1.CYX*AAffCoefs2.CXX + AAffCoefs1.CYY*AAffCoefs2.CYX + AAffCoefs1.SY*AAffCoefs2.WX)/W;
  Result.CYY := (AAffCoefs1.CYX*AAffCoefs2.CXY + AAffCoefs1.CYY*AAffCoefs2.CYY + AAffCoefs1.SY*AAffCoefs2.WY)/W;
  Result.SY  := (AAffCoefs1.CYX*AAffCoefs2.SX  + AAffCoefs1.CYY*AAffCoefs2.SY  + AAffCoefs1.SY*1.0)/W;
  Result.WY  := (AAffCoefs1.WX*AAffCoefs2.CXY  + AAffCoefs1.WY*AAffCoefs2.CYY  + 1.0*AAffCoefs2.WY)/W;
end; // end of function N_ComposeAffCoefs8

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvI2FPoint
//******************************************************* N_AffConvI2FPoint ***
// Convert given Integer Point by given Four Affine Transformation Coefficients 
// to Float Point
//
//     Parameters
// APoint     - source Integer Point
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Float Point
//
function N_AffConvI2FPoint( const APoint: TPoint;
                                    const AAffCoefs4: TN_AffCoefs4): TFPoint;
begin
  Result.X := AAffCoefs4.CX * APoint.X + AAffCoefs4.SX;
  Result.Y := AAffCoefs4.CY * APoint.Y + AAffCoefs4.SY;
end; // end of function N_AffConvI2FPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvI2DPoint
//******************************************************* N_AffConvI2DPoint ***
// Convert given Integer Point by given Four Affine Transformation Coefficients 
// to Double Point
//
//     Parameters
// APoint     - source Integer Point
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Double Point
//
function N_AffConvI2DPoint( const APoint: TPoint;
                                    const AAffCoefs4: TN_AffCoefs4): TDPoint;
begin
  Result.X := AAffCoefs4.CX * APoint.X + AAffCoefs4.SX;
  Result.Y := AAffCoefs4.CY * APoint.Y + AAffCoefs4.SY;
end; // end of function N_AffConvI2DPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvD2IPoint
//******************************************************* N_AffConvD2IPoint ***
// Convert given Double Point by given Four Affine Transformation Coefficients 
// to Integer Point
//
//     Parameters
// ADPoint    - source Double Point
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Integer Point
//
function N_AffConvD2IPoint( const ADPoint: TDPoint;
                                        const AAffCoefs4: TN_AffCoefs4): TPoint;
begin
  Result.X := Round( AAffCoefs4.CX * ADPoint.X + AAffCoefs4.SX );
  Result.Y := Round( AAffCoefs4.CY * ADPoint.Y + AAffCoefs4.SY );
end; // end of function N_AffConvD2IPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvF2IPoint
//******************************************************* N_AffConvF2IPoint ***
// Convert given Float Point by given Four Affine Transformation Coefficients to
// Integer Point
//
//     Parameters
// AFPoint    - source Float Point
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Integer Point
//
function N_AffConvF2IPoint( const AFPoint: TFPoint;
                                        const AAffCoefs4: TN_AffCoefs4): TPoint;
begin
  Result.X := Round( AAffCoefs4.CX * AFPoint.X + AAffCoefs4.SX );
  Result.Y := Round( AAffCoefs4.CY * AFPoint.Y + AAffCoefs4.SY );
end; // end of function N_AffConvF2IPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvF2DPoint
//******************************************************* N_AffConvF2DPoint ***
// Convert given Float Point by given Four Affine Transformation Coefficients to
// Double Point
//
//     Parameters
// AFPoint    - source Float Point
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Double Point
//
function N_AffConvF2DPoint( const AFPoint: TFPoint;
                                    const AAffCoefs4: TN_AffCoefs4): TDPoint;
begin
  Result.X := AAffCoefs4.CX * AFPoint.X + AAffCoefs4.SX;
  Result.Y := AAffCoefs4.CY * AFPoint.Y + AAffCoefs4.SY;
end; // end of function N_AffConvF2DPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvD2DPoint
//******************************************************* N_AffConvD2DPoint ***
// Convert given Double Point by given Four Affine Transformation Coefficients 
// to Double Point
//
//     Parameters
// ADPoint    - source Double Point
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Double Point
//
function N_AffConvD2DPoint( const ADPoint: TDPoint;
                                    const AAffCoefs4: TN_AffCoefs4): TDPoint;
begin
  Result.X := AAffCoefs4.CX * ADPoint.X + AAffCoefs4.SX;
  Result.Y := AAffCoefs4.CY * ADPoint.Y + AAffCoefs4.SY;
end; // end of function N_AffConvD2DPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvF2FPoint
//******************************************************* N_AffConvF2FPoint ***
// Convert given Float Point by given Four Affine Transformation Coefficients to
// Float Point
//
//     Parameters
// ADPoint    - source Float Point
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Float Point
//
function N_AffConvF2FPoint( const AFPoint: TFPoint;
                                    const AAffCoefs4: TN_AffCoefs4): TFPoint;
begin
  Result.X := AAffCoefs4.CX * AFPoint.X + AAffCoefs4.SX;
  Result.Y := AAffCoefs4.CY * AFPoint.Y + AAffCoefs4.SY;
end; // end of function N_AffConvF2FPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvF2IRect
//******************************************************** N_AffConvF2IRect ***
// Convert given Float Rectangle by given Four Affine Transformation 
// Coefficients to Integer Rectangle
//
//     Parameters
// AFRect     - source Float Rectangle
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Integer Rectangle
//
function N_AffConvF2IRect( const AFRect: TFRect;
                                        const AAffCoefs4: TN_AffCoefs4): TRect;
begin
  Result.Left   := Round( AAffCoefs4.CX * AFRect.Left   + AAffCoefs4.SX );
  Result.Top    := Round( AAffCoefs4.CY * AFRect.Top    + AAffCoefs4.SY );
  Result.Right  := Round( AAffCoefs4.CX * AFRect.Right  + AAffCoefs4.SX );
  Result.Bottom := Round( AAffCoefs4.CY * AFRect.Bottom + AAffCoefs4.SY );
end; // end of function N_AffConvF2IRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvI2FRect1
//******************************************************* N_AffConvI2FRect1 ***
// Convert given pixels Integer Rectangle by given Four Affine Transformation 
// Coefficients to Float Rectangle
//
//     Parameters
// ARect      - source pixel Integer Rectangle
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Float Rectangle
//
// Resulting Rectangle coordinates are the centers of corner pixels of source 
// Integer Rectangle.
//
function N_AffConvI2FRect1( const ARect: TRect;
                                        const AAffCoefs4: TN_AffCoefs4): TFRect;
begin
  Result.Left   := AAffCoefs4.CX * ARect.Left   + AAffCoefs4.SX;
  Result.Top    := AAffCoefs4.CY * ARect.Top    + AAffCoefs4.SY;
  Result.Right  := AAffCoefs4.CX * ARect.Right  + AAffCoefs4.SX;
  Result.Bottom := AAffCoefs4.CY * ARect.Bottom + AAffCoefs4.SY;
end; // end of function N_AffConvI2DRect1

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvI2FRect2
//******************************************************* N_AffConvI2FRect2 ***
// Convert given pixels Integer Rectangle by given Four Affine Transformation 
// Coefficients to Float Rectangle
//
//     Parameters
// ARect      - source pixel Integer Rectangle
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Float Rectangle
//
// Resulting Rectangle coordinates are the outer corners of corner pixels of 
// source Integer Rectangle. Resulting Rectangle can be used as argument in 
// N_CalcAffCoefs4 function and as rearch Rectangle.
//
function N_AffConvI2FRect2( const ARect: TRect;
                                        const AAffCoefs4: TN_AffCoefs4): TFRect;
begin
  Result.Left   := AAffCoefs4.CX * (ARect.Left   - 0.5) + AAffCoefs4.SX;
  Result.Top    := AAffCoefs4.CY * (ARect.Top    - 0.5) + AAffCoefs4.SY;
  Result.Right  := AAffCoefs4.CX * (ARect.Right  + 0.5) + AAffCoefs4.SX;
  Result.Bottom := AAffCoefs4.CY * (ARect.Bottom + 0.5) + AAffCoefs4.SY;
end; // end of function N_AffConvI2FRect2

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvF2FRect
//******************************************************** N_AffConvF2FRect ***
// Convert given Float Rectangle by given Four Affine Transformation 
// Coefficients to Float Rectangle
//
//     Parameters
// AFRect     - source Float Rectangle
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Float Rectangle
//
function N_AffConvF2FRect( const AFRect: TFRect; const AAffCoefs4: TN_AffCoefs4): TFRect;
begin
  Result.Left   := AAffCoefs4.CX * AFRect.Left   + AAffCoefs4.SX;
  Result.Top    := AAffCoefs4.CY * AFRect.Top    + AAffCoefs4.SY;
  Result.Right  := AAffCoefs4.CX * AFRect.Right  + AAffCoefs4.SX;
  Result.Bottom := AAffCoefs4.CY * AFRect.Bottom + AAffCoefs4.SY;
end; // end of function N_AffConvF2FRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvI2IRect
//******************************************************** N_AffConvI2IRect ***
// Convert given Integer Rectangle by given Four Affine Transformation 
// Coefficients to Integer Rectangle
//
//     Parameters
// ARect      - source Integer Rectangle
// AAffCoefs4 - Four Affine Transformation Coefficients
// Result     - Returns converted Integer Rectangle
//
function N_AffConvI2IRect( const ARect: TRect;
                                        const AAffCoefs4: TN_AffCoefs4): TRect;
begin
  Result.Left   := Round( AAffCoefs4.CX * ARect.Left   + AAffCoefs4.SX );
  Result.Top    := Round( AAffCoefs4.CY * ARect.Top    + AAffCoefs4.SY );
  Result.Right  := Round( AAffCoefs4.CX * ARect.Right  + AAffCoefs4.SX ) + 1;
  Result.Bottom := Round( AAffCoefs4.CY * ARect.Bottom + AAffCoefs4.SY ) + 1;
end; // end of function N_AffConvI2IRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv4F2IPoints(PFPoint,PIPoint)
//************************************ N_AffConv4F2IPoints(PFPoint,PIPoint) ***
// Convert given number of Float Points to Integer Points by given Four Affine 
// Transformation Coefficients
//
//     Parameters
// APInpPoints - pointer to first Input Float Point
// APOutPoints - pointer to first Output Integer Point (POutPoints should points
//               to enough reserved memory)
// ANumPoints  - number of Points to convert
// AAffCoefs4  - Four Affine Transformation Coefficients
//
procedure N_AffConv4F2IPoints( APInpPoints: PFPoint; APOutPoints: PPoint;
                               ANumPoints: integer; const AAffCoefs4: TN_AffCoefs4 );
var
  i: integer;
begin
  with AAffCoefs4 do
  for i := 1 to ANumPoints do
  with APOutPoints^ do
  begin
    APOutPoints^.X := Round( CX*APInpPoints^.X + SX );
    APOutPoints^.Y := Round( CY*APInpPoints^.Y + SY );
    Inc(APInpPoints);
    Inc(APOutPoints);
  end; // with AffCoefs6 do  for i := 1 to NumPoints do
end; // procedure N_AffConv4F2IPoints(PFPoint,PIPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConv4F2FPoints(PFPoint,PFPoint)
//************************************ N_AffConv4F2FPoints(PFPoint,PFPoint) ***
// Convert given number of Float Points to Float Points by given Four Affine 
// Transformation Coefficients
//
//     Parameters
// APInpPoints - pointer to first Input Float Point
// APOutPoints - pointer to first Output Float Point (POutPoints should points 
//               to enough reserved memory)
// ANumPoints  - number of Points to convert
// AAffCoefs4  - Four Affine Transformation Coefficients
//
procedure N_AffConv4F2FPoints( APInpPoints: PFPoint; APOutPoints: PFPoint;
                               ANumPoints: integer; const AAffCoefs4: TN_AffCoefs4 );
var
  i: integer;
begin
  with AAffCoefs4 do
  for i := 1 to ANumPoints do
  with APOutPoints^ do
  begin
    APOutPoints^.X := CX*APInpPoints^.X + SX;
    APOutPoints^.Y := CY*APInpPoints^.Y + SY;
    Inc(APInpPoints);
    Inc(APOutPoints);
  end; // with AffCoefs6 do  for i := 1 to NumPoints do
end; // procedure N_AffConv4F2FPoints(PFPoint,PIPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FCoordsToDCoords(2)
//*************************************************** N_FCoordsToDCoords(2) ***
// Convert given Float Points Array to Double Points Array
//
//     Parameters
// ASrcFPoints - source Float Points Array
// ADstDPoints - resulting Double Points Array
//
procedure N_FCoordsToDCoords( const FCoords: TN_FPArray;
                                                    var DCoords: TN_DPArray );
var
  i: integer;
begin
  SetLength( Dcoords, Length(FCoords) );
  for i := 0 to High(FCoords) do
  begin
    DCoords[i].X := FCoords[i].X;
    DCoords[i].Y := FCoords[i].Y;
  end;
end; // end of procedure N_FCoordsToDCoords(2)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FCoordsToDCoords(3)
//*************************************************** N_FCoordsToDCoords(3) ***
// Convert Float Points to Double Points
//
//     Parameters
// APSrcFPoints - first source Float Point pointer
// APDstDPoints - first destination Double Point pointer
// ANumPoints   - number of points
//
// APDstDCoords should points to enough reserved memory.
//
procedure N_FCoordsToDCoords( APSrcFPoints: PFPoint; APDstDPoints: PDPoint;
                                                    ANumPoints: integer );
var
  i: integer;
begin
  for i := 0 to ANumPoints-1 do
  begin
    APDstDPoints^.X := APSrcFPoints^.X;
    APDstDPoints^.Y := APSrcFPoints^.Y;
    Inc(APDstDPoints);
    Inc(APSrcFPoints);
  end;
end; // end of procedure N_FCoordsToDCoords(3)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DCoordsToFCoords(3)
//*************************************************** N_DCoordsToFCoords(3) ***
// Convert Double Points to Float Points
//
//     Parameters
// APSrcDPoints - first source Double Point pointer
// APDstFPoints - first destination Float Point pointer
// ANumPoints   - number of points
//
// APDstFPoints should points to  enough reserved memory.
//
procedure N_DCoordsToFCoords( APSrcDPoints: PDPoint; APDstFPoints: PFPoint;
                                                    ANumPoints: integer );
var
  i: integer;
begin
  for i := 0 to ANumPoints-1 do
  begin
    APDstFPoints^.X := APSrcDPoints^.X;
    APDstFPoints^.Y := APSrcDPoints^.Y;
    Inc(APDstFPoints);
    Inc(APSrcDPoints);
  end;
end; // end of procedure N_DCoordsToFCoords(3)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FCoordsToDCoords(5)
//*************************************************** N_FCoordsToDCoords(5) ***
// Convert given part of Float Points Array to given part of Double Points Array
//
//     Parameters
// ASrcFPoints - source Float Points Array
// ASrcInd     - index of first source array element
// ADstDPoints - resulting Double Points Array
// ADstInd     - index of first resulting array element
// ANumInds    - number of converting array elements
//
procedure N_FCoordsToDCoords( const ASrcFPoints: TN_FPArray; ASrcInd: integer;
                         var ADstDPoints: TN_DPArray; ADstInd, ANumInds: integer );
var
  i, LastDstInd: integer;
begin
  LastDstInd := ADstInd + ANumInds - 1;
  if High(ADstDPoints) < LastDstInd then
    SetLength( ADstDPoints, N_NewLength(LastDstInd) );

  for i := 0 to ANumInds - 1 do
  begin
    ADstDPoints[ADstInd+i].X := ASrcFPoints[ASrcInd+i].X;
    ADstDPoints[ADstInd+i].Y := ASrcFPoints[ASrcInd+i].Y;
  end;
end; // end of procedure N_FCoordsToDCoords(5)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DCoordsToFCoords(1)
//*************************************************** N_DCoordsToFCoords(1) ***
// Convert given Double Points Array to Float Points Array
//
//     Parameters
// ASrcDPoints - source Double Points Array
// ADstFPoints - resulting Float Points Array
//
procedure N_DCoordsToFCoords( const ASrcDPoints: TN_DPArray;
                                                    var ADstFPoints: TN_FPArray );
var
  i: integer;
begin
  SetLength( ADstFPoints, Length(ASrcDPoints) );
  for i := 0 to High(ASrcDPoints) do
  begin
    ADstFPoints[i].X := ASrcDPoints[i].X;
    ADstFPoints[i].Y := ASrcDPoints[i].Y;
  end;
end; // end of procedure N_DCoordsToFCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DCoordsToFCoords(5)
//*************************************************** N_DCoordsToFCoords(5) ***
// Convert given part of Double Points Array to given part of Float Points Array
//
//     Parameters
// ASrcDPoints - source Double Points Array
// ASrcInd     - index of first source array element
// ADstFPoints - resulting Float Points Array
// ADstInd     - index of first resulting array element
// ANumInds    - number of converting array elements
//
procedure N_DCoordsToFCoords( const ASrcDPoints: TN_DPArray; ASrcInd: integer;
                         var ADstFPoints: TN_FPArray; ADstInd, ANumInds: integer );
var
  i, LastDstInd: integer;
begin
  LastDstInd := ADstInd + ANumInds - 1;
  if High(ADstFPoints) < LastDstInd then
    SetLength( ADstFPoints, N_NewLength(LastDstInd) );

  for i := 0 to ANumInds - 1 do
  begin
    ADstFPoints[ADstInd+i].X := ASrcDPoints[ASrcInd+i].X;
    ADstFPoints[ADstInd+i].Y := ASrcDPoints[ASrcInd+i].Y;
  end;
end; // end of procedure N_DCoordsToFCoords(5)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PointInRect(integer)
//************************************************** N_PointInRect(integer) ***
// Calculate given Integer Point position relative to given Integer Rectangle
//
//     Parameters
// APoint - Integer Point
// ARect  - Integer Rectangle
// Result - Returns point position code bits:
//#F
//   bits0-3($0F)  = 1 - lefter
//   bits0-3($0F)  = 2 - above
//   bits0-3($0F)  = 4 - righter
//   bits0-3($0F)  = 8 - lower
//
//   bits0-3($0F)  = 0 - strictly inside or on the border
//   bits0-3($0F) <> 0 - strictly outside
//#/F
//
function N_PointInRect( const APoint: TPoint; const ARect: TRect ) : integer;
begin
  Result := 0;
  if APoint.X < ARect.Left   then Result := Result or 1;
  if APoint.Y < ARect.Top    then Result := Result or 2;
  if APoint.X > ARect.Right  then Result := Result or 4;
  if APoint.Y > ARect.Bottom then Result := Result or 8;
end; //*** end of function N_PointInRect(integer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PointInRect(float)
//**************************************************** N_PointInRect(float) ***
// Calculate given Float Point position relative to given Float Rectangle
//
//     Parameters
// AFPoint - Float Point
// AFRect  - Float Rectangle
// Result  - Returns point position code bits:
//#F
//   bits0-3($0F)  = 1 - lefter
//   bits0-3($0F)  = 2 - above
//   bits0-3($0F)  = 4 - righter
//   bits0-3($0F)  = 8 - lower
//
//   bits0-3($0F)  = 0 - strictly inside or on the border
//   bits0-3($0F) <> 0 - strictly outside
//#/F
//
function N_PointInRect( const AFPoint: TFPoint; const AFRect: TFRect ): integer;
begin
  Result := 0;
  if AFPoint.X < AFRect.Left   then Result := Result or 1;
  if AFPoint.Y < AFRect.Top    then Result := Result or 2;
  if AFPoint.X > AFRect.Right  then Result := Result or 4;
  if AFPoint.Y > AFRect.Bottom then Result := Result or 8;
end; //*** end of function N_PointInRect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PointInRect(dbl/float)
//************************************************ N_PointInRect(dbl/float) ***
// Calculate given Double Point position relative to given Float Rectangle
//
//     Parameters
// ADPoint - Double Point
// AFRect  - Float Rectangle
// Result  - Returns point position code bits:
//#F
//   bits0-3($0F)  = 1 - lefter
//   bits0-3($0F)  = 2 - above
//   bits0-3($0F)  = 4 - righter
//   bits0-3($0F)  = 8 - lower
//
//   bits0-3($0F)  = 0 - strictly inside or on the border
//   bits0-3($0F) <> 0 - strictly outside
//#/F
//
function N_PointInRect( const ADPoint: TDPoint; const AFRect: TFRect ): integer;
begin
  Result := 0;
  if ADPoint.X < AFRect.Left   then Result := Result or 1;
  if ADPoint.Y < AFRect.Top    then Result := Result or 2;
  if ADPoint.X > AFRect.Right  then Result := Result or 4;
  if ADPoint.Y > AFRect.Bottom then Result := Result or 8;
end; //*** end of function N_PointInRect(dbl/float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IPointNearIRect
//******************************************************* N_IPointNearIRect ***
// Calculate given Integer Point position relative to given Integer Rectangle 
// using given tolerance
//
//     Parameters
// APoint - Integer Point
// ARect  - Integer Rectangle
// ADelta - Integer tolerance
// Result - Returns point position code bits:
//#F
//   bits0-3($0F)  = 1 - near the Left border
//   bits0-3($0F)  = 2 - near the Top border
//   bits0-3($0F)  = 4 - near the Right border
//   bits0-3($0F)  = 8 - near the Bottom border
//
//   bits4-7($0F)  = 0 - strictly inside
//   bits4-7($0F)  = 1 - strictly on the border
//   bits4-7($0F)  = 2 - strictly outside
//#/F
//
function N_IPointNearIRect( const APoint:TPoint; const ARect:TRect;
                                             const ADelta:integer ): integer;
begin
  Result := 0;
  //**************** set bits 0-3

  if (APoint.X >= ARect.Left-ADelta)  and  // Left border
     (APoint.X <= ARect.Left+ADelta)  and
     (APoint.Y >= ARect.Top-ADelta)   and
     (APoint.Y <= ARect.Bottom+ADelta)     then Result := Result or 1;

  if (APoint.X >= ARect.Left-ADelta)  and  // Top border
     (APoint.X <= ARect.Right+ADelta) and
     (APoint.Y >= ARect.Top-ADelta)   and
     (APoint.Y <= ARect.Top+ADelta)        then Result := Result or 2;

  if (APoint.X >= ARect.Right-ADelta) and  // Right border
     (APoint.X <= ARect.Right+ADelta) and
     (APoint.Y >= ARect.Top-ADelta)   and
     (APoint.Y <= ARect.Bottom+ADelta)     then Result := Result or 4;

  if (APoint.X >= ARect.Left-ADelta)   and  // Bottom border
     (APoint.X <= ARect.Right+ADelta)  and
     (APoint.Y >= ARect.Bottom-ADelta) and
     (APoint.Y <= ARect.Bottom+ADelta)     then Result := Result or 8;

  //**************** set bits 4-7

  if ( (APoint.X  = ARect.Left)   and  // Left border
       (APoint.Y >= ARect.Top)    and
       (APoint.Y <= ARect.Bottom) )   or

     ( (APoint.X >= ARect.Left)   and  // Top border
       (APoint.X <= ARect.Right)  and
       (APoint.Y  = ARect.Top)    )   or

     ( (APoint.X  = ARect.Right)  and  // Right border
       (APoint.Y >= ARect.Top)    and
       (APoint.Y <= ARect.Bottom) )   or

     ( (APoint.X >= ARect.Left)   and  // Bottom border
       (APoint.X <= ARect.Right)  and
       (APoint.Y  = ARect.Bottom) ) then Result := Result or $10; // On border

  if (APoint.X < ARect.Left)  or  // to the Left
     (APoint.Y < ARect.Top)   or  // to the Up
     (APoint.X > ARect.Right) or  // to the Right
     (APoint.Y > ARect.Bottom)      then Result := Result or $20; // Outside

end; //*** end of function N_IPointNearIRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PointNearFRect(float)
//************************************************* N_PointNearFRect(float) ***
// Calculate given Float Point position relative to given Float Rectangle using 
// given tolerance
//
//     Parameters
// AFPoint - Float Point
// AFRect  - Float Rectangle
// ADDelta - Double tolerance
// Result  - Returns point position code bits:
//#F
//   bits0-3($0F)  = 1 - near the Left border
//   bits0-3($0F)  = 2 - near the Top border
//   bits0-3($0F)  = 4 - near the Right border
//   bits0-3($0F)  = 8 - near the Bottom border
//
//   bits0-3($0F)  = 0 - strictly inside
//   bits0-3($0F)  = 1 - strictly on the border
//   bits0-3($0F)  = 2 - strictly outside
//#/F
//
function N_PointNearFRect( const AFPoint:TFPoint; const AFRect:TFRect; const ADDelta:double ): integer;
begin
  Result := 0;
  //**************** set bits 0-3

  if (AFPoint.X >= AFRect.Left-ADDelta)  and  // Left border
     (AFPoint.X <= AFRect.Left+ADDelta)  and
     (AFPoint.Y >= AFRect.Top-ADDelta)   and
     (AFPoint.Y <= AFRect.Bottom+ADDelta)     then Result := Result or 1;

  if (AFPoint.X >= AFRect.Left-ADDelta)  and  // Top border
     (AFPoint.X <= AFRect.Right+ADDelta) and
     (AFPoint.Y >= AFRect.Top-ADDelta)   and
     (AFPoint.Y <= AFRect.Top+ADDelta)        then Result := Result or 2;

  if (AFPoint.X >= AFRect.Right-ADDelta) and  // Right border
     (AFPoint.X <= AFRect.Right+ADDelta) and
     (AFPoint.Y >= AFRect.Top-ADDelta)   and
     (AFPoint.Y <= AFRect.Bottom+ADDelta)     then Result := Result or 4;

  if (AFPoint.X >= AFRect.Left-ADDelta)   and  // Bottom border
     (AFPoint.X <= AFRect.Right+ADDelta)  and
     (AFPoint.Y >= AFRect.Bottom-ADDelta) and
     (AFPoint.Y <= AFRect.Bottom+ADDelta)     then Result := Result or 8;

  //**************** set bits 4-7

  if ( (AFPoint.X  = AFRect.Left)   and  // Left border
       (AFPoint.Y >= AFRect.Top)    and
       (AFPoint.Y <= AFRect.Bottom) )   or

     ( (AFPoint.X >= AFRect.Left)   and  // Top border
       (AFPoint.X <= AFRect.Right)  and
       (AFPoint.Y  = AFRect.Top)    )   or

     ( (AFPoint.X  = AFRect.Right)  and  // Right border
       (AFPoint.Y >= AFRect.Top)    and
       (AFPoint.Y <= AFRect.Bottom) )   or

     ( (AFPoint.X >= AFRect.Left)   and  // Bottom border
       (AFPoint.X <= AFRect.Right)  and
       (AFPoint.Y  = AFRect.Bottom) )     then Result := Result or $10; // On border

  if (AFPoint.X < AFRect.Left)  or  // to the Left
     (AFPoint.Y < AFRect.Top)   or  // to the Up
     (AFPoint.X > AFRect.Right) or  // to the Right
     (AFPoint.Y > AFRect.Bottom)          then Result := Result or $20; // Outside

end; //*** end of function N_PointNearFRect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PointNearFRect(double)
//************************************************ N_PointNearFRect(double) ***
// Calculate given Double Point position relative to given Float Rectangle using
// given tolerance
//
//     Parameters
// ADPoint - Double Point
// AFRect  - Float Rectangle
// ADDelta - Double tolerance
// Result  - Returns point position code bits:
//#F
//   bits0-3($0F)  = 1 - near the Left border
//   bits0-3($0F)  = 2 - near the Top border
//   bits0-3($0F)  = 4 - near the Right border
//   bits0-3($0F)  = 8 - near the Bottom border
//
//   bits0-3($0F)  = 0 - strictly inside
//   bits0-3($0F)  = 1 - strictly on the border
//   bits0-3($0F)  = 2 - strictly outside
//#/F
//
function N_PointNearFRect( const ADPoint:TDPoint; const AFRect:TFRect; const ADDelta:double ): integer;
begin
  Result := 0;
  //**************** set bits 0-3

  if (ADPoint.X >= AFRect.Left-ADDelta)  and  // Left border
     (ADPoint.X <= AFRect.Left+ADDelta)  and
     (ADPoint.Y >= AFRect.Top-ADDelta)   and
     (ADPoint.Y <= AFRect.Bottom+ADDelta)     then Result := Result or 1;

  if (ADPoint.X >= AFRect.Left-ADDelta)  and  // Top border
     (ADPoint.X <= AFRect.Right+ADDelta) and
     (ADPoint.Y >= AFRect.Top-ADDelta)   and
     (ADPoint.Y <= AFRect.Top+ADDelta)        then Result := Result or 2;

  if (ADPoint.X >= AFRect.Right-ADDelta) and  // Right border
     (ADPoint.X <= AFRect.Right+ADDelta) and
     (ADPoint.Y >= AFRect.Top-ADDelta)   and
     (ADPoint.Y <= AFRect.Bottom+ADDelta)     then Result := Result or 4;

  if (ADPoint.X >= AFRect.Left-ADDelta)   and  // Bottom border
     (ADPoint.X <= AFRect.Right+ADDelta)  and
     (ADPoint.Y >= AFRect.Bottom-ADDelta) and
     (ADPoint.Y <= AFRect.Bottom+ADDelta)     then Result := Result or 8;

  //**************** set bits 4-7

  if ( (ADPoint.X  = AFRect.Left)   and  // Left border
       (ADPoint.Y >= AFRect.Top)    and
       (ADPoint.Y <= AFRect.Bottom) )   or

     ( (ADPoint.X >= AFRect.Left)   and  // Top border
       (ADPoint.X <= AFRect.Right)  and
       (ADPoint.Y  = AFRect.Top)    )   or

     ( (ADPoint.X  = AFRect.Right)  and  // Right border
       (ADPoint.Y >= AFRect.Top)    and
       (ADPoint.Y <= AFRect.Bottom) )   or

     ( (ADPoint.X >= AFRect.Left)   and  // Bottom border
       (ADPoint.X <= AFRect.Right)  and
       (ADPoint.Y  = AFRect.Bottom) )     then Result := Result or $10; // On border

  if (ADPoint.X < AFRect.Left)  or  // to the Left
     (ADPoint.Y < AFRect.Top)   or  // to the Up
     (ADPoint.X > AFRect.Right) or  // to the Right
     (ADPoint.Y > AFRect.Bottom)          then Result := Result or $20; // Outside

end; //*** end of function N_PointNearFRect(double)

{
//************************************************ N_DLineCrossesDRect ***
// return True if given ALine crosses given ARect (all coordinates are double)
// ALineEnv - Envelope Rect for ALine
// SegmInd  - first Segment Index, that crosses ALine (or -1)
//
function N_DLineCrossesDRect( const ALine: TN_DPArray; const ALineEnv,
                               ARect: TDRect; out SegmInd: integer ): boolean;
var
  Pos1, Pos2, LastInd, Ind1, Ind2: integer;
  X, Y, Coef: double;
begin
  Result := False;
  SegmInd := -1;

  if (ALineEnv.Right  < ARect.Left)   or
     (ALineEnv.Bottom < ARect.Top)    or
     (ALineEnv.Left   > ARect.Right)  or
     (ALineEnv.Top    > ARect.Bottom)   then Exit; // do not cross

  Pos1 := N_DPointInDRect( ALine[0], ARect );

  if Pos1 = 0 then  // first point is inside ARect
  begin
    Result := True;
    SegmInd := 0;
    Exit;
  end;

  LastInd := High(ALine);
  Ind1 := 0;
  Ind2 := 1;

  while Ind2 <= LastInd do // loop along all ALine segments
  begin
    Pos2 := N_DPointInDRect( ALine[Ind2], ARect );
    SegmInd := Ind1;

    if Pos2 = 0 then  // ALine[Ind2] point is inside ARect
    begin
      Result := True;
      Exit;
    end;

    if (Pos1 and Pos2) = 0 then // more precise check is needed
    begin                       // (y-y1)/(y2-y1) == (x-x1)/(x2-x1)

      if ALine[Ind1].X <> ALine[Ind2].X then // check Left and Right borders
      begin
        Coef := (ALine[Ind2].Y-ALine[Ind1].Y) / (ALine[Ind2].X-ALine[Ind1].X);

        Y := ALine[Ind1].Y + (ARect.Left-ALine[Ind1].X) * Coef;
        if (Y>=ARect.Top) and (Y<=ARect.Bottom) then
        begin                          // line crosses Left border of ARect
          Result := True;
          Exit;
        end;

        Y := ALine[Ind1].Y + (ARect.Right-ALine[Ind1].X) * Coef;
        if (Y>=ARect.Top) and (Y<=ARect.Bottom) then
        begin                          // line crosses Right border of ARect
          Result := True;
          Exit;
        end;
      end; // end if ALine[Ind1].X <> ALine[Ind2].X then - check Left and Right borders

      if ALine[Ind1].Y <> ALine[Ind2].Y then // check Top and Bottom borders
      begin
        Coef := (ALine[Ind2].X-ALine[Ind1].X) / (ALine[Ind2].Y-ALine[Ind1].Y);

        X := ALine[Ind1].X + (ARect.Top-ALine[Ind1].Y) * Coef;
        if (X>=ARect.Left) and (X<=ARect.Right) then
        begin                          // line crosses Top border of ARect
          Result := True;
          Exit;
        end;

        X := ALine[Ind1].X + (ARect.Bottom-ALine[Ind1].Y) * Coef;
        if (X>=ARect.Left) and (X<=ARect.Right) then
        begin                          // line crosses Bottom border of ARect
          Result := True;
          Exit;
        end;
      end; // end if ALine[Ind1].Y <> ALine[Ind2].Y then - check Top and Bottom borders
    end; // end if (Pos1 and Pos2) = 0 then - more precise check is needed

    //***** Here: ( ALine[Ind1], ALine[Ind2] ) line segment does not
    //                                 cross ARect, check next line segment

    Pos1 := Pos2; Inc(Ind1); Inc(Ind2);
  end; // while Ind2 <= LastInd do // loop along all ALine segments
end; //*** end of function N_DLineCrossesDRect
}

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_LineCrossesFRect(float)
//*********************************************** N_LineCrossesFRect(float) ***
// Search if given Float Points Polyline part crosses given Float Rectangle
//
//     Parameters
// AFPLine  - search Polyline given as Float Points Array
// AFPInd   - first Vertex index in AFPLine array
// ANumInds - number of Vertexes in given Polyline part
// AFRect   - search Float Rectangle
// ASegmInd - resulting Index of first Polyline Segment, that crosses AFRect or 
//            -1, if no crosses       found
// Result   - Returns TRUE if given AFPLine part crosses AFRect
//
// Resulting Index of first PolyLine Segment, that crosses AFRect, is counted 
// from AFPInd.
//
function N_LineCrossesFRect( const AFPLine: TN_FPArray; AFPInd, ANumInds: integer;
                          const AFRect: TFRect; out ASegmInd: integer ): boolean;
var
  Pos1, Pos2, LastInd, Ind1, Ind2: integer;
  X, Y, Coef: double;
begin
  Result := False;
  ASegmInd := -1;

  Pos1 := N_PointInRect( AFPLine[AFPInd], AFRect );

  if Pos1 = 0 then  // first point is inside ARect
  begin
    Result := True;
    ASegmInd := 0;
    Exit;
  end;

  LastInd := AFPInd+ANumInds-1;
  Ind1 := AFPInd;
  Ind2 := AFPInd+1;

  while Ind2 <= LastInd do // loop along all ALine segments
  begin
    Pos2 := N_PointInRect( AFPLine[Ind2], AFRect );
    ASegmInd := Ind1 - AFPInd;

    if Pos2 = 0 then  // ALine[Ind2] point is inside ARect
    begin
      Result := True;
      Exit;
    end;

    if (Pos1 and Pos2) = 0 then // more precise check is needed
    begin                       // (y-y1)/(y2-y1) == (x-x1)/(x2-x1)

      if AFPLine[Ind1].X <> AFPLine[Ind2].X then // check Left and Right borders
      begin
        Coef := (AFPLine[Ind2].Y-AFPLine[Ind1].Y) / (AFPLine[Ind2].X-AFPLine[Ind1].X);

        Y := AFPLine[Ind1].Y + (AFRect.Left-AFPLine[Ind1].X) * Coef;
        if (Y>=AFRect.Top) and (Y<=AFRect.Bottom) then
        begin                          // line crosses Left border of ARect
          Result := True;
          Exit;
        end;

        Y := AFPLine[Ind1].Y + (AFRect.Right-AFPLine[Ind1].X) * Coef;
        if (Y>=AFRect.Top) and (Y<=AFRect.Bottom) then
        begin                          // line crosses Right border of ARect
          Result := True;
          Exit;
        end;
      end; // end if ALine[Ind1].X <> ALine[Ind2].X then - check Left and Right borders

      if AFPLine[Ind1].Y <> AFPLine[Ind2].Y then // check Top and Bottom borders
      begin
        Coef := (AFPLine[Ind2].X-AFPLine[Ind1].X) / (AFPLine[Ind2].Y-AFPLine[Ind1].Y);

        X := AFPLine[Ind1].X + (AFRect.Top-AFPLine[Ind1].Y) * Coef;
        if (X>=AFRect.Left) and (X<=AFRect.Right) then
        begin                          // line crosses Top border of ARect
          Result := True;
          Exit;
        end;

        X := AFPLine[Ind1].X + (AFRect.Bottom-AFPLine[Ind1].Y) * Coef;
        if (X>=AFRect.Left) and (X<=AFRect.Right) then
        begin                          // line crosses Bottom border of ARect
          Result := True;
          Exit;
        end;
      end; // end if ALine[Ind1].Y <> ALine[Ind2].Y then - check Top and Bottom borders
    end; // end if (Pos1 and Pos2) = 0 then - more precise check is needed

    //***** Here: ( ALine[Ind1], ALine[Ind2] ) line segment does not
    //                                 cross ARect, check next line segment

    Pos1 := Pos2; Inc(Ind1); Inc(Ind2);
  end; // while Ind2 <= LastInd do // loop along all ALine segments

  ASegmInd := -1;
end; //*** end of function N_LineCrossesFRect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_LineCrossesFRect(double)
//********************************************** N_LineCrossesFRect(double) ***
// Search if given Double Points Polyline part crosses given Float Rectangle
//
//     Parameters
// ADPLine  - search Polyline given as Double Points Array
// AFPInd   - first Vertex index in AFPLine array
// ANumInds - number of Vertexes in given Polyline part
// AFRect   - search Float Rectangle
// ASegmInd - resulting Index of first Polyline Segment, that crosses AFRect or 
//            -1, if no crosses       found
// Result   - Returns TRUE if given AFPLine part crosses AFRect
//
// Resulting Index of first PolyLine Segment, that crosses AFRect, is counted 
// from AFPInd.
//
function N_LineCrossesFRect( const ADPLine: TN_DPArray; AFPInd, ANumInds: integer;
                          const AFRect: TFRect; out ASegmInd: integer ): boolean;
var
  Pos1, Pos2, LastInd, Ind1, Ind2: integer;
  X, Y, Coef: double;
begin
  Result := False;
  ASegmInd := -1;

  Pos1 := N_PointInRect( ADPLine[AFPInd], AFRect );

  if Pos1 = 0 then  // first point is inside ARect
  begin
    Result := True;
    ASegmInd := 0;
    Exit;
  end;

  LastInd := AFPInd+ANumInds-1;
  Ind1 := AFPInd;
  Ind2 := AFPInd+1;

  while Ind2 <= LastInd do // loop along all ALine segments
  begin
    Pos2 := N_PointInRect( ADPLine[Ind2], AFRect );
    ASegmInd := Ind1 - AFPInd;

    if Pos2 = 0 then  // ALine[Ind2] point is inside ARect
    begin
      Result := True;
      Exit;
    end;

    if (Pos1 and Pos2) = 0 then // more precise check is needed
    begin                       // (y-y1)/(y2-y1) == (x-x1)/(x2-x1)

      if ADPLine[Ind1].X <> ADPLine[Ind2].X then // check Left and Right borders
      begin
        Coef := (ADPLine[Ind2].Y-ADPLine[Ind1].Y) / (ADPLine[Ind2].X-ADPLine[Ind1].X);

        Y := ADPLine[Ind1].Y + (AFRect.Left-ADPLine[Ind1].X) * Coef;
        if (Y>=AFRect.Top) and (Y<=AFRect.Bottom) then
        begin                          // line crosses Left border of ARect
          Result := True;
          Exit;
        end;

        Y := ADPLine[Ind1].Y + (AFRect.Right-ADPLine[Ind1].X) * Coef;
        if (Y>=AFRect.Top) and (Y<=AFRect.Bottom) then
        begin                          // line crosses Right border of ARect
          Result := True;
          Exit;
        end;
      end; // end if ALine[Ind1].X <> ALine[Ind2].X then - check Left and Right borders

      if ADPLine[Ind1].Y <> ADPLine[Ind2].Y then // check Top and Bottom borders
      begin
        Coef := (ADPLine[Ind2].X-ADPLine[Ind1].X) / (ADPLine[Ind2].Y-ADPLine[Ind1].Y);

        X := ADPLine[Ind1].X + (AFRect.Top-ADPLine[Ind1].Y) * Coef;
        if (X>=AFRect.Left) and (X<=AFRect.Right) then
        begin                          // line crosses Top border of ARect
          Result := True;
          Exit;
        end;

        X := ADPLine[Ind1].X + (AFRect.Bottom-ADPLine[Ind1].Y) * Coef;
        if (X>=AFRect.Left) and (X<=AFRect.Right) then
        begin                          // line crosses Bottom border of ARect
          Result := True;
          Exit;
        end;
      end; // end if ALine[Ind1].Y <> ALine[Ind2].Y then - check Top and Bottom borders
    end; // end if (Pos1 and Pos2) = 0 then - more precise check is needed

    //***** Here: ( ALine[Ind1], ALine[Ind2] ) line segment does not
    //                                 cross ARect, check next line segment

    Pos1 := Pos2; Inc(Ind1); Inc(Ind2);
  end; // while Ind2 <= LastInd do // loop along all ALine segments

  ASegmInd := -1;
end; //*** end of function N_LineCrossesFRect(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectOverLine(float)
//*************************************************** N_RectOverLine(float) ***
// Search if given Float Points Polyline part is over given Float Rectangle
//
//     Parameters
// AFPLine      - search Polyline given as Float Points Array
// AFPInd       - first Vertex index in AFPLine array
// ANumInds     - number of Vertexes in given Polyline part
// AFRect       - search Float Rectangle
// ASearchFlags - search parameter:
//#F
//  =1 check only Polyline Segments 
//  =2 check only Polyline Vertexes 
//  =3 check both Polyline Segments and Polyline Vertexes
//#/F
// ASegmInd     - resulting Index of first Polyline Segment, that crosses AFRect
//                (counted from FPInd) or -1, if no crosses found
// AVertInd     - resulting Index of first Polyline Vertex, that lies inside 
//                AFRect or on its border or -1, if no Vertex found
// Result       - Returns TRUE if given AFPLine part is over AFRect
//
// Resulting Index of first PolyLine Segment, that crosses AFRect, is counted 
// from AFPInd. Resulting Index of first PolyLine Vertex, that lies inside 
// AFRect or on its border, is counted from AFPInd.
//
function N_RectOverLine( const AFPLine: TN_FPArray; AFPInd, ANumInds: integer;
                         const AFRect: TFRect; ASearchFlags: integer;
                                      out ASegmInd, AVertInd: integer ): boolean;
var
  i, LastInd: integer;
begin
  Result := False;
  ASegmInd := -1;
  AVertInd := -1;

  if ASearchFlags = 0 then // just check if line crossing ARect without setting ASegmInd, AVertInd
  begin
    Result := N_LineCrossesFRect( AFPLine, AFPInd, ANumInds, AFRect, ASegmInd );
    ASegmInd := -1; // not used
    Exit;
  end;

  LastInd := AFPInd+ANumInds-1;
  if (ASearchFlags = 2) or (ASearchFlags = 3) then // check Line Vertexes
  begin
    for i := AFPInd to LastInd do
    begin
      if (AFRect.Left   <= AFPLine[i].X) and
         (AFRect.Top    <= AFPLine[i].Y) and
         (AFRect.Right  >= AFPLine[i].X) and
         (AFRect.Bottom >= AFPLine[i].Y)     then
      begin
        Result := True;
        AVertInd := i - AFPInd;
        Exit;
      end;
    end; // for i := FPInd to LastInd do
  end;

  //***** Here: no vertexes found, check Segments if needed

  if (ASearchFlags = 1) or (ASearchFlags = 3) then // check Segments
  begin
    Result := N_LineCrossesFRect( AFPLine, AFPInd, ANumInds, AFRect, ASegmInd );
  end;
end; //*** end of function N_RectOverLine(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectOverLine(double)
//************************************************** N_RectOverLine(double) ***
// Search if given Float Points Polyline part is over given Float Rectangle
//
//     Parameters
// ADPLine      - search Polyline given as Double Points Array
// AFPInd       - first Vertex index in AFPLine array
// ANumInds     - number of Vertexes in given Polyline part
// AFRect       - search Float Rectangle
// ASearchFlags - search parameter:
//#F
//  =1 check only Poyline Segments
//  =2 check only Poyline Vertexes
//  =3 check both Poyline Segments and Polyline Vertexes
//#/F
// ASegmInd     - resulting Index of first Polyline Segment, that crosses AFRect
//                (counted from FPInd) or -1, if no crosses found
// AVertInd     - resulting Index of first Polyline Vertex, that lies inside 
//                AFRect or on its border or -1, if no Vertex found
// Result       - Returns TRUE if given AFPLine part is over AFRect
//
// Resulting Index of first PolyLine Segment, that crosses AFRect, is counted 
// from AFPInd. Resulting Index of first PolyLine Vertex, that lies inside 
// AFRect or on its border, is counted from AFPInd.
//
function N_RectOverLine( const ADPLine: TN_DPArray; AFPInd, ANumInds: integer;
                         const AFRect: TFRect; ASearchFlags: integer;
                                      out ASegmInd, AVertInd: integer ): boolean;
var
  i, LastInd: integer;
begin
  Result := False;
  ASegmInd := -1;
  AVertInd := -1;

  if ASearchFlags = 0 then // check line crossing ARect
  begin
    Result := N_LineCrossesFRect( ADPLine, AFPInd, ANumInds, AFRect, ASegmInd );
    ASegmInd := -1; // not used
    Exit;
  end;

  LastInd := AFPInd+ANumInds-1;
  if (ASearchFlags = 2) or (ASearchFlags = 3) then // check Line Vertexes
  begin
    for i := AFPInd to LastInd do
    begin
      if (AFRect.Left   <= ADPLine[i].X) and
         (AFRect.Top    <= ADPLine[i].Y) and
         (AFRect.Right  >= ADPLine[i].X) and
         (AFRect.Bottom >= ADPLine[i].Y)     then
      begin
        Result := True;
        AVertInd := i - AFPInd;
        Exit;
      end;
    end; // for i := FPInd to LastInd do
  end;

  //***** Here: no vertexes found, check Segments if needed

  if (ASearchFlags = 1) or (ASearchFlags = 3) then // check Segments
  begin
    Result := N_LineCrossesFRect( ADPLine, AFPInd, ANumInds, AFRect, ASegmInd );
  end;
end; //*** end of function N_RectOverLine(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcLineEnvRect(integer)
//********************************************** N_CalcLineEnvRect(integer) ***
// Calculate Envelope Integer Rectangle for given Integer Points Polyline
//
//     Parameters
// APLine     - Polyline given as Integer Points Array
// ANumPoints - number of using Vertexes
// Result     - Returns Envelope Integer Rectangle
//
function N_CalcLineEnvRect( const APLine: TN_IPArray; ANumPoints: integer ): TRect;
var
  i: integer;
begin
  Result.Left := N_NotAnInteger;
  if Length(APLine) = 0 then Exit;

  Result.Left   := APLine[0].X;
  Result.Right  := APLine[0].X;
  Result.Top    := APLine[0].Y;
  Result.Bottom := APLine[0].Y;

  for i := 1 to ANumPoints-1 do
  with Result, APLine[i] do
  begin
    if Left   > X then Left   := X;
    if Right  < X then Right  := X;
    if Top    > Y then Top    := Y;
    if Bottom < Y then Bottom := Y;
  end; // end of while Ind <= LastInd do
end; //*** end of function N_CalcLineEnvRect(integer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcLineEnvRect(float)
//************************************************ N_CalcLineEnvRect(float) ***
// Calculate Envelope Float Rectangle for given Float Points Polyline
//
//     Parameters
// AFPLine  - Polyline given as Float Points Array
// AFPInd   - first Vertex index in ADPLine array
// ANumInds - number of Vertexes in given Polyline part
// Result   - Returns Envelope Float Rectangle
//
function N_CalcLineEnvRect( const AFPLine: TN_FPArray; AFPInd, ANumInds: integer ): TFRect;
var
  i: integer;
begin
  Result.Left := N_NotAFloat;
  if Length(AFPLine) = 0 then Exit;

  Result.Left   := AFPLine[AFPInd].X;
  Result.Right  := AFPLine[AFPInd].X;
  Result.Top    := AFPLine[AFPInd].Y;
  Result.Bottom := AFPLine[AFPInd].Y;

  for i := AFPInd+1 to AFPInd+ANumInds-1 do
  with Result, AFPLine[i] do
  begin
    if Left   > X then Left   := X;
    if Right  < X then Right  := X;
    if Top    > Y then Top    := Y;
    if Bottom < Y then Bottom := Y;
  end; // end of while Ind <= LastInd do
end; //*** end of function N_CalcLineEnvRect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcLineEnvRect(double)
//*********************************************** N_CalcLineEnvRect(double) ***
// Calculate Envelope Float Rectangle for given Double Points Polyline
//
//     Parameters
// ADPLine  - Polyline given as Double Points Array
// AFPInd   - first Vertex index in ADPLine array
// ANumInds - number of Vertexes in given Polyline part
// Result   - Returns Envelope Float Rectangle
//
function N_CalcLineEnvRect( const ADPLine: TN_DPArray; AFPInd, ANumInds: integer ): TFRect;
var
  i: integer;
begin
  Result.Left := N_NotAFloat;
  if ANumInds = 0 then Exit;

  Result.Left   := ADPLine[AFPInd].X;
  Result.Right  := ADPLine[AFPInd].X;
  Result.Top    := ADPLine[AFPInd].Y;
  Result.Bottom := ADPLine[AFPInd].Y;

  for i := AFPInd+1 to AFPInd+ANumInds-1 do
  with Result, ADPLine[i] do
  begin
    if Left   > X then Left   := X;
    if Right  < X then Right  := X;
    if Top    > Y then Top    := Y;
    if Bottom < Y then Bottom := Y;
  end; // end of while Ind <= LastInd do
end; //*** end of function N_CalcLineEnvRect(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcFLineEnvRect
//****************************************************** N_CalcFLineEnvRect ***
// Calculate Envelope Float Rectangle for given Float Points Polyline
//
//     Parameters
// APFPoints  - Polyline given as Pointer to first Float Point
// ANumPoints - number of Vertexes in given Polyline
// Result     - Returns Envelope Float Rectangle
//
function N_CalcFLineEnvRect( APFPoints: PFPoint; ANumPoints: integer ): TFRect;
var
  i: integer;
begin
  Result.Left := N_NotAFloat;
  if ANumPoints = 0 then Exit;

  with Result, APFPoints^ do
  begin
    Left   := X;
    Right  := X;
    Top    := Y;
    Bottom := Y;
  end;

  for i := 1 to ANumPoints do
  with Result, APFPoints^ do
  begin
    if Left   > X then Left   := X;
    if Right  < X then Right  := X;
    if Top    > Y then Top    := Y;
    if Bottom < Y then Bottom := Y;
    Inc(APFPoints);
  end; // end of while Ind <= LastInd do
end; //*** end of function N_CalcFLineEnvRect(pfloat)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcDLineEnvRect
//****************************************************** N_CalcDLineEnvRect ***
// Calculate Envelope Float Rectangle for given Double Points Polyline
//
//     Parameters
// APDPoints  - Polyline given as Pointer to first Double Point
// ANumPoints - number of Vertexes in given Polyline
// Result     - Returns Envelope Float Rectangle
//
function N_CalcDLineEnvRect( APDPoints: PDPoint; ANumPoints: integer ): TFRect;
var
  i: integer;
begin
  Result.Left := N_NotAFloat;
  if ANumPoints = 0 then Exit;

  with Result, APDPoints^ do
  begin
    Left   := X;
    Right  := X;
    Top    := Y;
    Bottom := Y;
  end;

  for i := 1 to ANumPoints do
  with Result, APDPoints^ do
  begin
    if Left   > X then Left   := X;
    if Right  < X then Right  := X;
    if Top    > Y then Top    := Y;
    if Bottom < Y then Bottom := Y;
    Inc(APDPoints);
  end; // end of while Ind <= LastInd do
end; //*** end of function N_CalcDLineEnvRect(pdouble)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcRectEps(float)
//**************************************************** N_CalcRectEps(float) ***
// Get calculation accuracy for given Float Rectangle
//
//     Parameters
// AFRect - Float Rectangle
// Result - Returns calculation accuracy for given Rectangle
//
// Resulting accuracy is calculated as Max(Abs( Rectangle Coordinate )) 
// multiplied by N_Eps, N_Eps = 1.0e-14
//
function N_CalcRectEps( const AFRect: TFRect ): double;
var
  MaxAbsCoord: double;
begin
  MaxAbsCoord := Abs( AFRect.Left);
  MaxAbsCoord := Max( MaxAbsCoord, Abs( AFRect.Top) );
  MaxAbsCoord := Max( MaxAbsCoord, Abs( AFRect.Right) );
  MaxAbsCoord := Max( MaxAbsCoord, Abs( AFRect.Bottom) );
  Result := MaxAbsCoord * N_Eps;
end; // end of function N_CalcRectEps(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcRectEps(double)
//*************************************************** N_CalcRectEps(double) ***
// Get calculation accuracy for given Double Rectangle
//
//     Parameters
// ADRect - Double Rectangle
// Result - Returns calculation accuracy for given Rectangle
//
// Resulting accuracy is calculated as Max(Abs( Rectangle Coordinate )) 
// multiplied by N_Eps, N_Eps = 1.0e-14
//
function N_CalcRectEps( const ADRect: TDRect ): double;
var
  MaxAbsCoord: double;
begin
  MaxAbsCoord := Abs( ADRect.Left);
  MaxAbsCoord := Max( MaxAbsCoord, Abs( ADRect.Top) );
  MaxAbsCoord := Max( MaxAbsCoord, Abs( ADRect.Right) );
  MaxAbsCoord := Max( MaxAbsCoord, Abs( ADRect.Bottom) );
  Result := MaxAbsCoord * N_Eps;
end; // end of function N_CalcRectEps(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DPointInsideFRing
//***************************************************** N_DPointInsideFRing ***
// Check if given Double Point is inside given Float Points Ring
//
//     Parameters
// APFRCoords - pointer to first Ring Vertex (pointer to Float Point)
// ANumPoints - number of Vertexes in Ring
// AFRingEnv  - Ring Envelope Float Rectangle
// ADPoint    - Double Point to check
// APSegmInd  - pointer to resulting Ring border Segment Index (on input); is 
//              used only if given Point is on the Ring's border
// Result     - Returns Point position code:
//#F
//  =0 - given point is strictly inside given Ring
//  =1 - given point is on the given Ring border
//  =2 - given point is strictly outside of given Ring or ANumPoints < 4
//#/F
//
// If given point is inside given Ring or not is defined by calculation of 
// number of crosspoints of all Ring Segments with horizontal Segment from given
// Point to the right outside of Ring. Ring border position of given Point 
// (Result=1) is calculated with accuracy = N_CalcRectEps(ARingEnv).
//
function N_DPointInsideFRing( APFRCoords: PFPoint; ANumPoints: integer;
                              const AFRingEnv: TFRect; const ADPoint: TDPoint;
                                                 APSegmInd: PInteger = nil ): integer;
var
  i, CrossCount, LastInd: integer;
  Xmin, Ymin, Xmax, Ymax, Eps, CPX: double;
  PrevX, PrevY, CurX, CurY, NextX, NextY: double;
  PrevAbove: boolean;
  TPP, FPP, CPP: PFPoint;
  Label PointOnTheBorder;
begin
  Result := 2; // as if outside
  if APSegmInd <> nil then APSegmInd^ := -1; // a precaution

  if (ADPoint.X < AFRingEnv.Left)  or  // to the Left
     (ADPoint.Y < AFRingEnv.Top)   or  // to the Up
     (ADPoint.X > AFRingEnv.Right) or  // to the Right
     (ADPoint.Y > AFRingEnv.Bottom) then Exit; // DPoint is sticly Outside Ring

  if ANumPoints < 4 then Exit;
  Assert( ANumPoints >= 4, 'Bad Ring!' ); // a precation
  Eps := N_CalcRectEps( AFRingEnv );

  //***** Cacl prev border position for first ( RCoords[1] ) point
  //     ( note, that RCoords[0] is same as RCoords[High(RCoords)] )
  PrevAbove := True;
  Xmin := ADPoint.X-Eps; // accuracy rect around APoint
  Xmax := ADPoint.X+Eps;
  Ymin := ADPoint.Y-Eps;
  Ymax := ADPoint.Y+Eps;

  TPP := APFRCoords; // Temp Pointer to Point
  Inc( TPP, ANumPoints ); // set TPP to Last Point +1
  LastInd := ANumPoints-1;
  for i := 0 to LastInd do
  begin
    Dec(TPP);
    if TPP^.Y < Ymin then Break // prev border is above APoint
    else begin
      if TPP^.Y > Ymax then
      begin
        PrevAbove := False;
        Break;
      end;
    // Here: i-th point in not Abov, nor below, check previous point
    end; // end if ... else
  end; // for i := 0 to NumInds-1 do

  FPP := APFRCoords; // First Pointer to Point
  CPP := APFRCoords; // Cur Pointer to Point
  Dec(CPP);

  CrossCount := 0;
  CurX := FPP^.X;
  CurY := FPP^.Y;
//  Inc(FPP); // set to FPInd+1 - error!
  Inc(CPP); // set to FPInd+1

//  for i := FPInd+1 to LastInd do // loop along all RCoords vertexes
  for i := 1 to LastInd do // loop along all RCoords vertexes
  begin
    Inc(CPP);
    PrevX := CurX;     PrevY := CurY;
    CurX  := CPP^.X;   CurY  := CPP^.Y;

    if ( (CurY < Ymin) and PrevAbove ) or
       ( (CurY > Ymax) and not PrevAbove ) then Continue; // is not crossed

    if (CurY >= Ymin) and (CurY <= Ymax) then // Cur vertex on the line
    begin

      if (CurX >= Xmin) and (CurX <= Xmax) then goto PointOnTheBorder;

      //*** check next point position
      if i = LastInd then
      begin
//        NextX := RCoords[FPInd+1].X;
//        NextY := RCoords[FPInd+1].Y;
        NextX := FPP^.X;
        NextY := FPP^.Y;
      end else
      begin
//        NextX := RCoords[i+1].X;
//        NextY := RCoords[i+1].Y;
        TPP := CPP; // is it OK to Inc CPP ???
        Inc(TPP);
        NextX := TPP^.X;
        NextY := TPP^.Y;
      end;

      if (NextY >= Ymin) and (NextY <= Ymax) then Continue; // next on the line too

      //***** check if APoint is on the Ring border
      if NextX >= CurX then
      begin
        if (XMax >= CurX) and (XMin <= NextX) then goto PointOnTheBorder;
      end else // NextX < CurX
      begin
        if (XMax >= NextX) and (XMin <= CurX) then goto PointOnTheBorder;
      end; // end check if APoint is on the Ring border
{
      if NextY < Ymin then // Next vertex is Above
      begin
        if PrevAbove then Continue; // both Prev and Next are Above
        Inc(CrossCount); // Prev was Below, Next is Above
      end else //************ Next vertex is Below
      begin
        if not PrevAbove then Continue; // both Prev and Next are Below
        Inc(CrossCount); // Prev was Above, Next is Below
      end;
}
      if ( (NextY < Ymin) and (not PrevAbove) and (XMax < CurX) ) or
         ( (NextY > Ymax) and (    PrevAbove) and (XMax < CurX) ) then
      begin
        Inc(CrossCount); // cross point at (CurX,CurY)
        PrevAbove := not PrevAbove;
      end;

      Continue; // to next vertex

    end; // if (CurY >= Ymin) and (CurY <= Ymax) then // Cur vertex on the line

    //***** Here: segment [Prev, Cur] crosses line Y=Apoint.Y,
    //            calc CrossPoint X-coord ( CPX )

    CPX := CurX + (ADPoint.Y - CurY)*(PrevX - CurX)/(PrevY - CurY);

    if (CPX >= XMin) and (CPX <= XMax) then goto PointOnTheBorder;

    if CPX > XMax then Inc(CrossCount);
    PrevAbove := not PrevAbove;

  end; // for i := 1 to High(RCoords) do // loop along all RCoords vertexes

  if (CrossCount and $01) = 0 then Result := 2
                              else Result := 0;
  Exit;

  PointOnTheBorder: //********************************************
  Result := 1;      // APoint on the Ring border (not Inside, not Outside)
  if APSegmInd <> nil then
  begin
    APSegmInd^ := ( TN_BytesPtr(CPP) - TN_BytesPtr(FPP) ) div Sizeof(FPP^);
  end;
end; //*** end of function N_DPointInsideFRing

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DPointInsideDRing
//***************************************************** N_DPointInsideDRing ***
// Check if given Double Point is inside given Double Points Ring
//
//     Parameters
// APDRCoords - pointer to first Ring Vertex (pointer to Double Point)
// ANumPoints - number of Vertexes in Ring
// AFRingEnv  - Ring Envelope Float Rectangle
// ADPoint    - Double Point to check
// APSegmInd  - pointer to resulting Ring border Segment Index (on input); is 
//              used only if given Point is on the Ring's border
// Result     - Returns Point position code:
//#F
//  =0 - given point is strictly inside given Ring
//  =1 - given point is on the Ring border
//  =2 - given point is stricly outside of given Ring or ANumPoints < 4
//#/F
//
// If given point is inside given Ring or not is defined by calculation of 
// number of Crosspoints of all Ring Segments with horizontal Segment from given
// Point to the right outside of Ring. Ring border position of given Point 
// (Result=1) is calculated with accuracy = N_CalcRectEps(ARingEnv).
//
function N_DPointInsideDRing( APDRCoords: PDPoint; ANumPoints: integer;
                              const AFRingEnv: TFRect; const ADPoint: TDPoint;
                                                 APSegmInd: PInteger = nil ): integer;
var
  i, CrossCount, LastInd: integer;
  Xmin, Ymin, Xmax, Ymax, Eps, CPX: double;
  PrevX, PrevY, CurX, CurY, NextX, NextY: double;
  PrevAbove: boolean;
  TPP, FPP, CPP: PDPoint;
  Label PointOnTheBorder;
begin
  Result := 2; // as if outside

//  if abs(APDRCoords^.X-43.867) <= 0.001 then //debug
//  begin
//    N_IAdd( Format( '     DP[0].Y=%.3f', [ADPoint.Y] ));
//    if ADPoint.Y < 118 then
//      N_i := 1;
//  end;

  if (ADPoint.X < AFRingEnv.Left)  or  // to the Left
     (ADPoint.Y < AFRingEnv.Top)   or  // to the Up
     (ADPoint.X > AFRingEnv.Right) or  // to the Right
     (ADPoint.Y > AFRingEnv.Bottom) then Exit; // DPoint is sticly Outside Ring

  if ANumPoints < 4 then Exit;
  Assert( ANumPoints >= 4, 'Bad Ring!' ); // a precation
  Eps := N_CalcRectEps( AFRingEnv );

  //***** Cacl prev border position for first ( RCoords[1] ) point
  //     ( note, that RCoords[0] is same as RCoords[High(RCoords)] )
  PrevAbove := True;
  Xmin := ADPoint.X-Eps; // accuracy rect around APoint
  Xmax := ADPoint.X+Eps;
  Ymin := ADPoint.Y-Eps;
  Ymax := ADPoint.Y+Eps;

  TPP := APDRCoords; // Temp Pointer to Point
  Inc( TPP, ANumPoints ); // set TPP to Last Point +1
  LastInd := ANumPoints-1;

  for i := 0 to LastInd do
  begin
    Dec(TPP);
    if TPP^.Y < Ymin then // prev border is above APoint
      Break
    else
    begin
      if TPP^.Y > Ymax then
      begin
        PrevAbove := False;
        Break;
      end;
    // Here: i-th point in not Abov, nor below, check previous point
    end; // end if ... else
  end; // for i := 0 to NumInds-1 do

  FPP := APDRCoords; // First Pointer to Point
  CPP := APDRCoords; // Cur Pointer to Point
  Dec(CPP);

  CrossCount := 0;
  CurX := FPP^.X;
  CurY := FPP^.Y;
//  Inc(FPP); // set to FPInd+1 - error!
  Inc(CPP); // set to FPInd+1

//  for i := FPInd+1 to LastInd do // loop along all RCoords vertexes
  for i := 1 to LastInd do // loop along all RCoords vertexes
  begin
//    if i = 15 then
//      N_i := 1;

    Inc(CPP);
    PrevX := CurX;     PrevY := CurY;
    CurX  := CPP^.X;   CurY  := CPP^.Y;

    if ( (CurY < Ymin) and PrevAbove ) or
       ( (CurY > Ymax) and not PrevAbove ) then Continue; // is not crossed

    if (CurY >= Ymin) and (CurY <= Ymax) then // Cur vertex on the line
    begin

      if (CurX >= Xmin) and (CurX <= Xmax) then goto PointOnTheBorder;

      //*** check next point position
      if i = LastInd then
      begin
//        NextX := RCoords[FPInd+1].X;
//        NextY := RCoords[FPInd+1].Y;
        NextX := FPP^.X;
        NextY := FPP^.Y;
      end else
      begin
//        NextX := RCoords[i+1].X;
//        NextY := RCoords[i+1].Y;
        TPP := CPP; // is it OK to Inc CPP ???
        Inc(TPP);
        NextX := TPP^.X;
        NextY := TPP^.Y;
      end;

      if (NextY >= Ymin) and (NextY <= Ymax) then Continue; // next on the line too

      //***** check if APoint is on the Ring border
      if NextX >= CurX then
      begin
        if (XMax >= CurX) and (XMin <= NextX) then goto PointOnTheBorder;
      end else // NextX < CurX
      begin
        if (XMax >= NextX) and (XMin <= CurX) then goto PointOnTheBorder;
      end; // end check if APoint is on the Ring border
{
      if NextY < Ymin then // Next vertex is Above
      begin
        if PrevAbove then Continue; // both Prev and Next are Above
        Inc(CrossCount); // Prev was Below, Next is Above
      end else //************ Next vertex is Below
      begin
        if not PrevAbove then Continue; // both Prev and Next are Below
        Inc(CrossCount); // Prev was Above, Next is Below
      end;
}
      if ( (NextY < Ymin) and (not PrevAbove) and (XMax < CurX) ) or
         ( (NextY > Ymax) and (    PrevAbove) and (XMax < CurX) ) then
      begin
        Inc(CrossCount); // cross point at (CurX,CurY)
        PrevAbove := not PrevAbove;
      end;

      Continue; // to next vertex

    end; // if (CurY >= Ymin) and (CurY <= Ymax) then // Cur vertex on the line

    //***** Here: segment [Prev, Cur] crosses line Y=Apoint.Y,
    //            calc CrossPoint X-coord ( CPX )

    CPX := CurX + (ADPoint.Y - CurY)*(PrevX - CurX)/(PrevY - CurY);

    if (CPX >= XMin) and (CPX <= XMax) then goto PointOnTheBorder;

    if CPX > XMax then Inc(CrossCount);
    PrevAbove := not PrevAbove;

  end; // for i := 1 to High(RCoords) do // loop along all RCoords vertexes

  if (CrossCount and $01) = 0 then Result := 2
                              else Result := 0;
  Exit;

  PointOnTheBorder: //********************************************
  Result := 1;      // APoint on the Ring border (not Inside, not Outside)
  if APSegmInd <> nil then
  begin
    APSegmInd^ := ( TN_BytesPtr(CPP) - TN_BytesPtr(FPP) ) div Sizeof(FPP^);
  end;
end; //*** end of function N_DPointInsideDRing

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AdjustIRect
//*********************************************************** N_AdjustIRect ***
// Adjust given Integer Rectangle AFRect: move it inside AMaxRect and possibly 
// decrease
//
//     Parameters
// ARect    - Integer Rectangle to adjust (on input and output)
// AMaxRect - Integer Rectangle, which must include resulting Rectangle
// AMinSize - minimal allowed side size of resulting Rectangle
// AAspect  - resulting Rectangle Aspect (Height/Width)
// Result   - Returns 0 if AFRect is not changed, 1 - if AFRect is changed.
//
// Adjust given Float Rectangle so, that
//#F
//1) it is inside given AMaxFRect,
//2) it's Width and Height is not less than given AMinSize,
//3) it's aspect equals to given AAspect.
//#/F
//
// If given AAspect is equal to 0, then any aspect of resulting Rectangle is OK.
//
function N_AdjustIRect( var ARect: TRect; const AMaxRect: TRect;
                                 const AMinSize: integer; const AAspect: double ): integer;
var
  NewWidth, NewHeight, MaxWidth, MaxHeight: integer;
begin
  Result := 0; // not used yet

  //***** first set proper NewWidth, NewHeight

  NewWidth  := ARect.Right     - ARect.Left    + 1;
  NewHeight := ARect.Bottom    - ARect.Top     + 1;
  MaxWidth  := AMaxRect.Right  - AMaxRect.Left + 1;
  MaxHeight := AMaxRect.Bottom - AMaxRect.Top  + 1;

  NewWidth  := Min( NewWidth,  MaxWidth );
  NewHeight := Min( NewHeight, MaxHeight );
  NewWidth  := Max( NewWidth,  AMinSize );
  NewHeight := Max( NewHeight, AMinSize );

  if AAspect > 0.0 then
  begin
    if (NewHeight / NewWidth) > AAspect then
    begin // decrease NewHeight if it is not equal to MinSize, otherwise increase NewWidth
      if NewHeight = AMinSize then NewWidth  := Round( NewHeight / AAspect )
                              else NewHeight := Round( NewWidth * AAspect );
    end else // (NewHeight / NewWidth) <= AAspect
    begin // decrease NewWidth if it is not equal to MinSize
      if NewWidth = AMinSize then NewHeight := Round( NewWidth * AAspect )
                             else NewWidth  := Round( NewHeight / AAspect );
    end;
  end;

  //***** Here: NewWidth, NewHeight are OK, adjust ARect Coords

  if (ARect.Left + NewWidth - 1) > AMaxRect.Right then
    ARect.Left := AMaxRect.Right - NewWidth + 1
  else if ARect.Left < AMaxRect.Left then
    ARect.Left := AMaxRect.Left;
  ARect.Right := ARect.Left + NewWidth - 1;

  if (ARect.Top + NewHeight - 1) > AMaxRect.Bottom then
    ARect.Top := AMaxRect.Bottom - NewHeight + 1
  else if ARect.Top < AMaxRect.Top then
    ARect.Top := AMaxRect.Top;
  ARect.Bottom := ARect.Top + NewHeight - 1;

end; //*** end of function N_AdjustIRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AdjustFRect
//*********************************************************** N_AdjustFRect ***
// Adjust given Float Rectangle AFRect: move it inside AMaxRect and possibly 
// decrease
//
//     Parameters
// AFRect    - Float Rectangle to adjust (on input and output)
// AMaxFRect - Float Rectangle, which must include resulting Rectangle
// AMinSize  - minimal allowed side size of resulting Rectangle
// AAspect   - resulting Rectangle Aspect (Height/Width)
// Result    - Returns 0 if AFRect is not changed, 1 - if AFRect is changed.
//
// Adjust given Float Rectangle so, that
//#F
//1) it is inside given AMaxFRect,
//2) it's Width and Height is not less than given AMinSize,
//3) it's aspect equals to given AAspect.
//#/F
//
// If given AAspect is equal to 0, then any aspect of resulting Rectangle is OK.
//
function N_AdjustFRect( var AFRect: TFRect; const AMaxFRect: TFRect;
                                          const AMinSize, AAspect: double ): integer;
var
  NewWidth, NewHeight, MaxWidth, MaxHeight: double;
begin
  Result := 0; // not used yet

  NewWidth  := AFRect.Right  - AFRect.Left;
  NewHeight := AFRect.Bottom - AFRect.Top;

  //***** update NewWidth, NewHeight without considering Aspect:
  //      MinSize <= NewWidth  <= Width(MaxRect)
  //      MinSize <= NewHeight <= Height(MaxRect)

  MaxWidth  := AMaxFRect.Right  - AMaxFRect.Left;
  MaxHeight := AMaxFRect.Bottom - AMaxFRect.Top;

  NewWidth  := Min( NewWidth,  MaxWidth );
  NewHeight := Min( NewHeight, MaxHeight );
  NewWidth  := Max( NewWidth,  AMinSize );
  NewHeight := Max( NewHeight, AMinSize );

  //***** update NewWidth, NewHeight by Aspect using aamDecrease mode:

  if AAspect > 0.0 then // Aspect = 0 means any Aspect is OK
  begin
    if (NewHeight / NewWidth) > AAspect then
    begin // decrease NewHeight if it is not equal to MinSize, otherwise increase NewWidth
      if NewHeight = AMinSize then NewWidth  := NewHeight / AAspect
                              else NewHeight := NewWidth * AAspect;
    end else // (NewHeight / NewWidth) <= AAspect
    begin // decrease NewWidth if it is not equal to MinSize
      if NewWidth = AMinSize then NewHeight := NewWidth * AAspect
                             else NewWidth  := NewHeight / AAspect;
    end;
  end; // if Aspect > 0.0 then // Aspect = 0 means any Aspect is OK

  //***** Here: NewWidth, NewHeight are OK, adjust ARect Coords

  if AFRect.Left + NewWidth > AMaxFRect.Right then
    AFRect.Left := AMaxFRect.Right - NewWidth
  else if AFRect.Left < AMaxFRect.Left then
    AFRect.Left := AMaxFRect.Left;
  AFRect.Right := AFRect.Left + NewWidth;

  if AFRect.Top + NewHeight > AMaxFRect.Bottom then
    AFRect.Top := AMaxFRect.Bottom - NewHeight
  else if AFRect.Top < AMaxFRect.Top then
    AFRect.Top := AMaxFRect.Top;
  AFRect.Bottom := AFRect.Top + NewHeight;

end; //*** end of function N_AdjustFRect

//***************************************************** N_AdjustRect(float) ***
// adjust given float ARect so that:
// - Result.Width >= AMinSize, Result.Height >= AMinSize
// - Aspect(Result) is set by given AAdjustMode and ANeededAspect
// - Result is max possible rect inside given AMaxRect with needed Aspect
//
function N_AdjustRect( AAdjustMode: TN_AdjustAspectMode; var ASrcRect: TFRect;
                       const AMaxRect: TFRect; const AMinSize, ANeededAspect: float ): TFRect;
begin

//  Result := 0; // not used yet
{
var
  NewWidth, NewHeight, MaxWidth, MaxHeight: double;
  
  NewWidth  := ARect.Right  - ARect.Left;
  NewHeight := ARect.Bottom - ARect.Top;

  //***** update NewWidth, NewHeight without considering Aspect:
  //      MinSize <= NewWidth  <= Width(MaxRect)
  //      MinSize <= NewHeight <= Height(MaxRect)

  MaxWidth  := MaxRect.Right  - MaxRect.Left;
  MaxHeight := MaxRect.Bottom - MaxRect.Top;

  NewWidth  := Min( NewWidth,  MaxWidth );
  NewHeight := Min( NewHeight, MaxHeight );
  NewWidth  := Max( NewWidth,  MinSize );
  NewHeight := Max( NewHeight, MinSize );

  //***** update NewWidth, NewHeight by Aspect using aamDecrease mode:

  if Aspect > 0.0 then // Aspect = 0 means any Aspect is OK
  begin
    if (NewHeight / NewWidth) < Aspect then
    begin // decrease NewWidth if it is not equal to MinSize
      if NewWidth = MinSize then NewHeight := NewWidth / Aspect
                            else NewWidth  := NewHeight * Aspect;
    end else // (NewHeight / NewWidth) >= Aspect
    begin // decrease NewHeight if it is not equal to MinSize
      if NewHeight = MinSize then NewWidth  := NewHeight * Aspect
                             else NewHeight := NewWidth / Aspect;
    end;
  end; // if Aspect > 0.0 then // Aspect = 0 means any Aspect is OK

  //***** Here: NewWidth, NewHeight are OK, adjust ARect Coords

  if ARect.Left + NewWidth > MaxRect.Right then
    ARect.Left := MaxRect.Right - NewWidth
  else if ARect.Left < MaxRect.Left then
    ARect.Left := MaxRect.Left;
  ARect.Right := ARect.Left + NewWidth;

  if ARect.Top + NewHeight > MaxRect.Bottom then
    ARect.Top := MaxRect.Bottom - NewHeight
  else if ARect.Top < MaxRect.Top then
    ARect.Top := MaxRect.Top;
  ARect.Bottom := ARect.Top + NewHeight;
}
end; //*** end of function N_AdjustRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ChangeFRect
//*********************************************************** N_ChangeFRect ***
// change given ARect (all coordinates are double): if Mode = 0 - Shift Arect by
// DPointPar
//
function N_ChangeFRect( var ARect: TFRect; const DPointPar: TDPoint; const Mode: integer ): TFRect;
begin
  Result := ARect;
  if Mode = 0 then // temporary
  begin
    Result := FRect( ARect.Left  + DPointPar.X, ARect.Top    + DPointPar.Y,
                     ARect.Right + DPointPar.X, ARect.Bottom + DPointPar.Y );
    Exit;
  end;
end; //*** end of function N_ChangeFRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvCoords(4,float,float)
//****************************************** N_AffConvCoords(4,float,float) ***
// Convert Float Points by given Four Affine Transformation Coefficients
//
//     Parameters
// AAffCoefs4  - Four Affine Transformation Coefficients
// ASrcFPoints - source Float Points Array
// ADstFPoints - resulting Float Points Array
//
procedure N_AffConvCoords( const AAffCoefs4: TN_AffCoefs4;
                      const ASrcFPoints: TN_FPArray; var ADstFPoints: TN_FPArray );
var
  i, NPoints: integer;
begin
  NPoints := Length( ASrcFPoints );
  SetLength( ADstFPoints, NPoints );
  for i := 0 to NPoints-1 do
  begin
    ADstFPoints[i].X := AAffCoefs4.CX * ASrcFPoints[i].X + AAffCoefs4.SX;
    ADstFPoints[i].Y := AAffCoefs4.CY * ASrcFPoints[i].Y + AAffCoefs4.SY;
  end;
end; // end of procedure N_AffConvCoords(4,float,float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvCoords(4,float,double)
//***************************************** N_AffConvCoords(4,float,double) ***
// Convert Float Points to Double Points by given Four Affine Transformation 
// Coefficients
//
//     Parameters
// AAffCoefs4  - Four Affine Transformation Coefficients
// ASrcFPoints - source Float Points Array
// ADstDPoints - resulting Double Points Array
//
procedure N_AffConvCoords( const AAffCoefs4: TN_AffCoefs4;
                      const ASrcFPoints: TN_FPArray; var ADstDPoints: TN_DPArray );
var
  i, NPoints: integer;
begin
  NPoints := Length( ASrcFPoints );
  SetLength( ADstDPoints, NPoints );
  for i := 0 to NPoints-1 do
  begin
    ADstDPoints[i].X := AAffCoefs4.CX * ASrcFPoints[i].X + AAffCoefs4.SX;
    ADstDPoints[i].Y := AAffCoefs4.CY * ASrcFPoints[i].Y + AAffCoefs4.SY;
  end;
end; // end of procedure N_AffConvCoords(4,float,double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvCoords(4,double,float)
//***************************************** N_AffConvCoords(4,double,float) ***
// Convert Double Points to Float Points by given Four Affine Transformation 
// Coefficients
//
//     Parameters
// AAffCoefs4  - Four Affine Transformation Coefficients
// ASrcDPoints - source Double Points Array
// ADstFPoints - resulting Float Points Array
//
procedure N_AffConvCoords( const AAffCoefs4: TN_AffCoefs4;
                      const ASrcDPoints: TN_DPArray; var ADstFPoints: TN_FPArray );
var
  i, NPoints: integer;
begin
  NPoints := Length( ASrcDPoints );
  SetLength( ADstFPoints, NPoints );
  for i := 0 to NPoints-1 do
  begin
    ADstFPoints[i].X := AAffCoefs4.CX * ASrcDPoints[i].X + AAffCoefs4.SX;
    ADstFPoints[i].Y := AAffCoefs4.CY * ASrcDPoints[i].Y + AAffCoefs4.SY;
  end;
end; // end of procedure N_AffConvCoords(4,double,float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvCoords(4,double,double)
//**************************************** N_AffConvCoords(4,double,double) ***
// Convert Double Points by given Four Affine Transformation Coefficients
//
//     Parameters
// AAffCoefs4  - Four Affine Transformation Coefficients
// ASrcDPoints - source Double Points Array
// ADstDPoints - resulting Double Points Array
//
procedure N_AffConvCoords( const AAffCoefs4: TN_AffCoefs4;
                      const ASrcDPoints: TN_DPArray; var ADstDPoints: TN_DPArray );
var
  i, NPoints: integer;
begin
  NPoints := Length( ASrcDPoints );
  SetLength( ADstDPoints, NPoints );
  for i := 0 to NPoints-1 do
  begin
    ADstDPoints[i].X := AAffCoefs4.CX * ASrcDPoints[i].X + AAffCoefs4.SX;
    ADstDPoints[i].Y := AAffCoefs4.CY * ASrcDPoints[i].Y + AAffCoefs4.SY;
  end;
end; // end of procedure N_AffConvCoords(4,double,double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvCoords(6,double,double)
//**************************************** N_AffConvCoords(6,double,double) ***
// Convert Double Points by given Six Affine Transformation Coefficients
//
//     Parameters
// AAffCoefs6  - Six Affine Transformation Coefficients
// ASrcDPoints - source Double Points Array
// ADstDPoints - resulting Double Points Array
//
procedure N_AffConvCoords( const AAffCoefs6: TN_AffCoefs6;
                      const ASrcDPoints: TN_DPArray; var ADstDPoints: TN_DPArray );
var
  {i,} NPoints: integer;
begin
  NPoints := Length( ASrcDPoints );
  SetLength( ADstDPoints, NPoints );
{
  for i := 0 to NPoints-1 do
  begin
    ADstDPoints[i].X := AAffCoefs6.CXX * ASrcDPoints[i].X + AAffCoefs6.CXY * ASrcDPoints[i].Y + AAffCoefs6.SX;
    ADstDPoints[i].Y := AAffCoefs6.CYX * ASrcDPoints[i].X + AAffCoefs6.CYY * ASrcDPoints[i].Y + AAffCoefs6.SY;
  end;
}
  N_AffConv6D2DPoints( @ASrcDPoints[0], @ADstDPoints[0], NPoints, AAffCoefs6 );
end; // end of procedure N_AffConvCoords(6,double,double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffConvCoords(8,double,double)
//**************************************** N_AffConvCoords(8,double,double) ***
// Convert Double Points by given Eight Affine Transformation Coefficients
//
//     Parameters
// AAffCoefs8  - Eight Affine Transformation Coefficients
// ASrcDPoints - source Double Points Array
// ADstDPoints - resulting Double Points Array
//
procedure N_AffConvCoords( const AAffCoefs8: TN_AffCoefs8;
                      const ASrcDPoints: TN_DPArray; var ADstDPoints: TN_DPArray );
var
  NPoints: integer;
begin
  NPoints := Length( ASrcDPoints );
  SetLength( ADstDPoints, NPoints );

  N_AffConv8D2DPoints ( @ASrcDPoints[0], @ADstDPoints[0], NPoints, AAffCoefs8 );
end; // end of procedure N_AffConvCoords(8,double,double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FuncConvAffC6
//********************************************************* N_FuncConvAffC6 ***
// Convert one double point by AffCoefs6 convertion, PParams points to 
// TN_AffCoefs6
//
function N_FuncConvAffC6( const ASrcDP: TDPoint; PParams: Pointer ): TDPoint;
begin
  with TN_PAffCoefs6(PParams)^ do
  begin
    Result.X := CXX * ASrcDP.X + CXY * ASrcDP.Y + SX;
    Result.Y := CYX * ASrcDP.X + CYY * ASrcDP.Y + SY;
  end;
end; // function N_FuncConvAffC6

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ConvDLineToDLine
//****************************************************** N_ConvDLineToDLine ***
// conv DLine coordinates by given AffConv coefs InpDline and OutDline are 
// Arrays
//
procedure N_ConvDLineToDLine( const AffCoefs: TN_AffCoefs4;
                                         var InpDline, OutDline: TN_DPArray );
var
  i, NPoints: integer;
begin
  NPoints := Length( InpDline );
  SetLength( OutDLine, NPoints );
  for i := 0 to NPoints-1 do
  begin
    OutDline[i].X := AffCoefs.CX * InpDline[i].X + AffCoefs.SX;
    OutDline[i].Y := AffCoefs.CY * InpDline[i].Y + AffCoefs.SY;
  end;
end; // end of procedure N_ConvDLineToDLine

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ConvDLineToDLine2
//***************************************************** N_ConvDLineToDLine2 ***
// conv DLine coordinates by given AffConv coefs and increase given OutEnvRect 
// by converted coordinates
//
procedure N_ConvDLineToDLine2( const AffCoefs: TN_AffCoefs4;
                 var InpDline, OutDline: TN_DPArray; var OutEnvRect: TDRect );
var
  i, NPoints: integer;
begin
  NPoints := Length( InpDline );
  SetLength( OutDLine, NPoints );
  for i := 0 to NPoints-1 do
  begin
    OutDline[i].X := AffCoefs.CX * InpDline[i].X + AffCoefs.SX;
    OutDline[i].Y := AffCoefs.CY * InpDline[i].Y + AffCoefs.SY;
    N_IncEnvRect( OutEnvRect, OutDline[i] );
  end;
end; // end of procedure N_ConvDLineToDLine2

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ConvDLineToILine
//****************************************************** N_ConvDLineToILine ***
// Convert given Double Points to Integer Points by given Four Affine 
// Transformation Coefficients
//
//     Parameters
// AAffCoefs4   - Four Affine Transformation Coefficients
// ANPoints     - number of points
// APSrcDPoints - first source Double Point pointer
// APDstPoints  - first destination Integer Point pointer
//
procedure N_ConvDLineToILine( const AAffCoefs4: TN_AffCoefs4; const ANPoints: integer;
                         APSrcDPoints: PDPoint; APDstPoints: PPoint );
var
  i: integer;
begin
  with AAffCoefs4 do
  begin
    for i := 0 to ANPoints-1 do
    begin
  //    N_d1 := AffCoefs.CX * PInpDCoords^.X + AffCoefs.SX; // debug, for
  //    N_d2 := AffCoefs.CY * PInpDCoords^.Y + AffCoefs.SY; // Time measering

      APDstPoints^.X := Integer(Round( CX * APSrcDPoints^.X + SX ));
      APDstPoints^.Y := Integer(Round( CY * APSrcDPoints^.Y + SY ));
  //    POutICoords^.X := Integer(Trunc( CX * PInpDCoords^.X + SX ));
  //    POutICoords^.Y := Integer(Trunc( CY * PInpDCoords^.Y + SY ));
  //    POutICoords^.X := Round( CX * PInpDCoords^.X + SX );
  //    POutICoords^.Y := Round( CY * PInpDCoords^.Y + SY );
  //    POutICoords^.X := Floor( CX * PInpDCoords^.X + SX );
  //    POutICoords^.Y := Floor( CY * PInpDCoords^.Y + SY );
      Inc(APSrcDPoints);
      Inc(APDstPoints);
    end;
  end;
end; // end of procedure N_ConvDLineToILine

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ConvDLineToILine2
//***************************************************** N_ConvDLineToILine2 ***
// Convert given Double Points to Integer Points by given Four Affine 
// Transformation Coefficients and skip subsequent Points with same coordinates
//
//     Parameters
// AAffCoefs4   - Four Affine Transformation Coefficients
// ANPoints     - number of Src Points to convert
// APSrcDPoints - first source Double Point pointer
// APDstPoints  - first destination Integer Point pointer
// Result       - Returns number of resulting Points
//
function N_ConvDLineToILine2( const AAffCoefs4: TN_AffCoefs4; const ANPoints: integer;
                   APSrcDPoints: PDPoint; APDstPoints: PPoint ): integer;
var
  i, ix, iy, IPBeg: integer;
begin
  IPBeg := integer(APDstPoints);
  ix := 0;
  iy := 0;
  with AAffCoefs4 do
  begin
    APDstPoints^.X := Integer(Round( CX * APSrcDPoints^.X + SX ));
    APDstPoints^.Y := Integer(Round( CY * APSrcDPoints^.Y + SY ));
    Inc(APSrcDPoints);

    for i := 1 to ANPoints-1 do
    begin
      ix := Integer(Round( CX * APSrcDPoints^.X + SX ));
      iy := Integer(Round( CY * APSrcDPoints^.Y + SY ));
      Inc(APSrcDPoints);
      if (ix = APDstPoints^.X) and (iy = APDstPoints^.Y) then Continue;
      Inc(APDstPoints);
      APDstPoints^.X := ix;
      APDstPoints^.Y := iy;
    end;
  end;

  if integer(APDstPoints) = IPBeg then
  begin
    Result := 2;
    Inc(APDstPoints);
    APDstPoints^.X := ix - 1; // to allow drawing one point lines
    APDstPoints^.Y := iy;
  end else
    Result := (integer(APDstPoints) - IPBeg) div Sizeof(TPoint) + 1;
end; // end of function N_ConvDLineToILine2

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ConvFLineToILine2
//***************************************************** N_ConvFLineToILine2 ***
// Convert given Float Points to Integer Points by given Four Affine 
// Transformation Coefficients and skip subsequent Points with same coordinates
//
//     Parameters
// AAffCoefs4   - Four Affine Transformation Coefficients
// ANPoints     - number of Src Points to convert
// APSrcFPoints - first source Float Point pointer
// APDstPoints  - first destination Integer Point pointer
// Result       - Returns number of resulting Points
//
function N_ConvFLineToILine2( const AAffCoefs4: TN_AffCoefs4; const ANPoints: integer;
                   APSrcFPoints: PFPoint; APDstPoints: PPoint ): integer;
var
  i, ix, iy, IPBeg: integer;
begin
  IPBeg := integer(APDstPoints);
  ix := 0;
  iy := 0;
  with AAffCoefs4 do
  begin
    APDstPoints^.X := Integer(Round( CX * APSrcFPoints^.X + SX ));
    APDstPoints^.Y := Integer(Round( CY * APSrcFPoints^.Y + SY ));
    Inc(APSrcFPoints);

    for i := 1 to ANPoints-1 do
    begin
      ix := Integer(Round( CX * APSrcFPoints^.X + SX ));
      iy := Integer(Round( CY * APSrcFPoints^.Y + SY ));
//      ix := Integer(Round( CX * PInpCoords^.X + SX ));
//      iy := Integer(Round( CY * PInpCoords^.Y + SY ));
      Inc(APSrcFPoints);
      if (ix = APDstPoints^.X) and (iy = APDstPoints^.Y) then Continue;
      Inc(APDstPoints);
      APDstPoints^.X := ix;
      APDstPoints^.Y := iy;
    end;
  end;

  if integer(APDstPoints) = IPBeg then
  begin
    Result := 2;
    Inc(APDstPoints);
    APDstPoints^.X := ix - 1;
    APDstPoints^.Y := iy;
  end else
    Result := (integer(APDstPoints) - IPBeg) div Sizeof(TPoint) + 1;
end; // end of function N_ConvFLineToILine2(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SegmCrossRectBorder1(float)
//******************************************* N_SegmCrossRectBorder1(float) ***
// Find exactly one Float Crosspoint of given Float Rectangle and given Float 
// Segment
//
//     Parameters
// ACrossFPoint - resulting Float CrossPoint
// AFRect       - Float Rectangle
// AFPoint1     - Segment first Vertex (Float Point, should be inside given 
//                Rectangle)
// AFPoint2     - Segment second Vertex (Float Point, should be outside given 
//                Rectangle)
// Result       - Returns CrossPoint position code bits0-3($0F):
//#F
//   = 1 - on lefter AFRect border
//   = 2 - on above AFRect border 
//   = 4 - on righter AFRect border 
//   = 8 - on lower AFRect border
//#/F
//
// Find CrossPoint where Segment leaves given Rectangle out.
//
function N_SegmCrossRectBorder1( var ACrossFPoint: TFPoint; const AFRect: TFRect;
                                      const AFPoint1, AFPoint2: TFPoint ): integer;
var
  X, Y, Coef: double;
begin
  Result := 0;
  if AFPoint1.X < AFPoint2.X then // not Vertical, from left to right Segment
  begin
    Coef := (AFPoint2.Y-AFPoint1.Y) / (AFPoint2.X-AFPoint1.X);
    Y := AFPoint1.Y + (AFRect.Right-AFPoint1.X) * Coef;

    if Y > AFRect.Bottom then
    begin             // Segment crosses Bottom border of AFRect
      X := AFPoint1.X + (AFRect.Bottom-AFPoint1.Y) / Coef;
      ACrossFPoint := FPoint( X, AFRect.Bottom );
    end else if Y < AFRect.Top then
    begin             // Segment crosses Top border of AFRect
      X := AFPoint1.X + (AFRect.Top-AFPoint1.Y) / Coef;
      ACrossFPoint := FPoint( X, AFRect.Top );
    end else          // Segment crosses Right border of AFRect
    begin
      ACrossFPoint := FPoint( AFRect.Right, Y );
    end;
  end else if AFPoint1.X > AFPoint2.X then // not Vertical, from right to left Segment
  begin
    Coef := (AFPoint2.Y-AFPoint1.Y) / (AFPoint2.X-AFPoint1.X);
    Y := AFPoint1.Y + (AFRect.Left-AFPoint1.X) * Coef;

    if Y > AFRect.Bottom then
    begin             // Segment crosses Bottom border of AFRect
      X := AFPoint1.X + (AFRect.Bottom-AFPoint1.Y) / Coef;
      ACrossFPoint := FPoint( X, AFRect.Bottom );
    end else if Y < AFRect.Top then
    begin             // Segment crosses Top border of AFRect
      X := AFPoint1.X + (AFRect.Top-AFPoint1.Y) / Coef;
      ACrossFPoint := FPoint( X, AFRect.Top );
    end else
    begin             // Segment crosses Left border of AFRect
      ACrossFPoint := FPoint( AFRect.Left, Y );
    end;
  end else //************* vertical Segment
  begin
    if AFPoint2.Y < AFRect.Top then // Segment crosses Top border of AFRect
      ACrossFPoint := FPoint( AFPoint1.X, AFRect.Top )
    else                          // Segment crosses Bottom border of AFRect
      ACrossFPoint := FPoint( AFPoint1.X, AFRect.Bottom );
  end;

  if ACrossFPoint.X = AFRect.Left   then Result := Result or $01;
  if ACrossFPoint.Y = AFRect.Top    then Result := Result or $02;
  if ACrossFPoint.X = AFRect.Right  then Result := Result or $04;
  if ACrossFPoint.Y = AFRect.Bottom then Result := Result or $08;
end; // end of function N_SegmCrossRectBorder1(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SegmCrossRectBorder1(double)
//****************************************** N_SegmCrossRectBorder1(double) ***
// Find exactly one Double Crosspoint of given Float Rectangle and given Double 
// Segment
//
//     Parameters
// ACrossDPoint - resulting Double CrossPoint
// AFRect       - Float Rectangle
// ADPoint1     - Segment first Vertex (Double Point, should be inside given 
//                Rectangle)
// ADPoint2     - Segment second Vertex (Double Point, should be outside given 
//                Rectangle)
// Result       - Returns CrossPoint position code (bits0-3($0F)):
//#F
//   = 1 - on lefter AFRect border
//   = 2 - on above AFRect border
//   = 4 - on righter AFRect border
//   = 8 - on lower AFRect border
//#/F
//
// Find Crosspoint where Segment leaves given Rectangle out.
//
function N_SegmCrossRectBorder1( var ACrossDPoint: TDPoint; const AFRect: TFRect;
                                     const ADPoint1, ADPoint2: TDPoint ): integer;
var
  X, Y, Coef: double;
begin
  Result := 0;
  if ADPoint1.X < ADPoint2.X then // not Vertical, from left to right Segment
  begin
    Coef := (ADPoint2.Y-ADPoint1.Y) / (ADPoint2.X-ADPoint1.X);
    Y := ADPoint1.Y + (AFRect.Right-ADPoint1.X) * Coef;

    if Y > AFRect.Bottom then
    begin             // Segment crosses Bottom border of AFRect
      X := ADPoint1.X + (AFRect.Bottom-ADPoint1.Y) / Coef;
      ACrossDPoint := DPoint( X, AFRect.Bottom );
    end else if Y < AFRect.Top then
    begin             // Segment crosses Top border of AFRect
      X := ADPoint1.X + (AFRect.Top-ADPoint1.Y) / Coef;
      ACrossDPoint := DPoint( X, AFRect.Top );
    end else          // Segment crosses Right border of AFRect
    begin
      ACrossDPoint := DPoint( AFRect.Right, Y );
    end;
  end else if ADPoint1.X > ADPoint2.X then // not Vertical, from right to left Segment
  begin
    Coef := (ADPoint2.Y-ADPoint1.Y) / (ADPoint2.X-ADPoint1.X);
    Y := ADPoint1.Y + (AFRect.Left-ADPoint1.X) * Coef;

    if Y > AFRect.Bottom then
    begin             // Segment crosses Bottom border of AFRect
      X := ADPoint1.X + (AFRect.Bottom-ADPoint1.Y) / Coef;
      ACrossDPoint := DPoint( X, AFRect.Bottom );
    end else if Y < AFRect.Top then
    begin             // Segment crosses Top border of AFRect
      X := ADPoint1.X + (AFRect.Top-ADPoint1.Y) / Coef;
      ACrossDPoint := DPoint( X, AFRect.Top );
    end else
    begin             // Segment crosses Left border of AFRect
      ACrossDPoint := DPoint( AFRect.Left, Y );
    end;
  end else //************* vertical Segment
  begin
    if ADPoint2.Y < AFRect.Top then // Segment crosses Top border of AFRect
      ACrossDPoint := DPoint( ADPoint1.X, AFRect.Top )
    else                          // Segment crosses Bottom border of AFRect
      ACrossDPoint := DPoint( ADPoint1.X, AFRect.Bottom );
  end;

  if ACrossDPoint.X = AFRect.Left   then Result := Result or $01;
  if ACrossDPoint.Y = AFRect.Top    then Result := Result or $02;
  if ACrossDPoint.X = AFRect.Right  then Result := Result or $04;
  if ACrossDPoint.Y = AFRect.Bottom then Result := Result or $08;
end; // end of function N_SegmCrossRectBorder1(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SegmCrossRectBorder2(float)
//******************************************* N_SegmCrossRectBorder2(float) ***
// Find zero or two Float Crosspoints of given Float Rectangle and given Float 
// Segment
//
//     Parameters
// AFLine   - Float Points Array for Cross-Section Points allocation
// AInd     - resulting CrossPoints start index in AFLine (AInd = AInd + 2 if 
//            CrossPoints are found)
// AFRect   - Float Rectangle
// AFPoint1 - Segment first Vertex (Float Point, should be outside given 
//            Rectangle)
// APos1    - resulting first Vertex position code relative to given rectangle 
//            (calculates if undefined - =-1)
// AFPoint2 - Segment second Vertex (Float Point, should be outside given 
//            Rectangle)
// APos2    - resulting second Vertex position code relative to given rectangle 
//            (calculates if undefined - =-1)
// Result   - Returns CrossPoints position code:
//#F
//   bits0-3($00F)  = first CrossPoint Position
//   bits4-7($0F0)  = Second CrossPoint Position
//   =0 - no Cross-Section between given Segment  and Rectangle
//#/F
//
// Find Crosspoints where Segment leaves given Rectangle out.
//
function N_SegmCrossRectBorder2( const AFLine: TN_FPArray; var AInd: integer;
                 const AFRect: TFRect; const AFPoint1: TFPoint; var APos1: integer;
                               const AFPoint2: TFPoint; var APos2: integer ): integer;
var
  NShift: integer;
  X, Y, YLeft, YRight, XTop, XBottom, Coef: double;
  label Fin;
begin
  Result := 0;
  if APos1 = -1 then APos1 := N_PointInRect( AFPoint1, AFRect );
  if APos2 = -1 then APos2 := N_PointInRect( AFPoint2, AFRect );
  if (APos1 and APos2) <> 0 then Exit; // no crossection

  if AFPoint1.Y = AFPoint2.Y then // horizontal Segment,
  begin                         // AFRect.Top <= AFPoint1,2.Y <= AFRect.Bottom
    AFLine[AInd].X   := AFRect.Left;
    AFLine[AInd].Y   := AFPoint1.Y;
    AFLine[AInd+1].X := AFRect.Right;
    AFLine[AInd+1].Y := AFPoint1.Y;
    AInd := AInd + 2;
    Result := $041;
    goto Fin;
  end;

  if AFPoint1.X = AFPoint2.X then // vertical Segment,
  begin                         // AFRect.Left <= AFPoint1,2.X <= AFRect.Right
    AFLine[AInd].X   := AFPoint1.X;
    AFLine[AInd].Y   := AFRect.Top;
    AFLine[AInd+1].X := AFPoint1.X;
    AFLine[AInd+1].Y := AFRect.Bottom;
    AInd := AInd + 2;
    Result := $082;
    goto Fin;
  end;

  Coef := (AFPoint2.X-AFPoint1.X) / (AFPoint2.Y-AFPoint1.Y);
  NShift := 0;

  YLeft  := AFPoint1.Y + (AFRect.Left-AFPoint1.X) / Coef;
  if (YLeft>=AFRect.Top) and (YLeft<=AFRect.Bottom) then
  begin                           // Segm crosses Left border of AFRect
    AFLine[AInd].X := AFRect.Left;
    AFLine[AInd].Y := YLeft;
    AInd := AInd + 1;
    Result := $01;
    Inc( NShift, 4 );
  end;

  XTop   := AFPoint1.X + (AFRect.Top-AFPoint1.Y) * Coef;
  if (XTop>=AFRect.Left) and (XTop<=AFRect.Right) then
  begin                           // Segm crosses Top border of AFRect
    AFLine[AInd].X := XTop;
    AFLine[AInd].Y := AFRect.Top;
    AInd := AInd + 1;
    Result := Result or ($02 shl NShift);
    Inc( NShift, 4 );
  end;

  YRight := AFPoint1.Y + (AFRect.Right-AFPoint1.X) / Coef;
  if (YRight>=AFRect.Top) and (YRight<=AFRect.Bottom) then
  begin                           // Segm crosses Right border of AFRect
    AFLine[AInd].X := AFRect.Right;
    AFLine[AInd].Y := YRight;
    AInd := AInd + 1;
    Result := Result or ($04 shl NShift);
    Inc( NShift, 4 );
  end;

  XBottom   := AFPoint1.X + (AFRect.Bottom-AFPoint1.Y) * Coef;
  if (XBottom>=AFRect.Left) and (XBottom<=AFRect.Right) then
  begin                           // Segm crosses Bottom border of AFRect
    AFLine[AInd].X := XBottom;
    AFLine[AInd].Y := AFRect.Bottom;
    AInd := AInd + 1;
    Result := Result or ($08 shl NShift);
  end;

  Fin: // swap cross points if needed so, that AFLine[AInd-2] in nearer AFPoint1
       //                                  and AFLine[AInd-1] in nearer AFPoint2

  if Result <> 0 then // exactly two points are added, swap them so, that
  begin // AFLine[AInd-2] in nearer AFPoint1 and AFLine[AInd-1] in nearer AFPoint2
    if ( (AFPoint2.X-AFLine[AInd-1].X)*(AFPoint2.X-AFLine[AInd-1].X) +
         (AFPoint2.Y-AFLine[AInd-1].Y)*(AFPoint2.Y-AFLine[AInd-1].Y) ) >
       ( (AFPoint2.X-AFLine[AInd-2].X)*(AFPoint2.X-AFLine[AInd-2].X) +
         (AFPoint2.Y-AFLine[AInd-2].Y)*(AFPoint2.Y-AFLine[AInd-2].Y) ) then
    begin
      X := AFLine[AInd-1].X;
      AFLine[AInd-1].X := AFLine[AInd-2].X;
      AFLine[AInd-2].X := X;
      Y := AFLine[AInd-1].Y;
      AFLine[AInd-1].Y := AFLine[AInd-2].Y;
      AFLine[AInd-2].Y := Y;
      Result := ((Result and $F)  shl 4) or
                ((Result and $F0) shr 4); // swap flags
    end;
  end; // end if Result <> 0 then ...
end; // end of function N_SegmCrossRectBorder2(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SegmCrossRectBorder2(double)
//****************************************** N_SegmCrossRectBorder2(double) ***
// Find zero or two Double Crosspoints of given Float Rectangle and given Double
// Segment
//
//     Parameters
// ADLine   - Double Points Array for Cross-Section Points allocation
// AInd     - resulting CrossPoints start AIndex in ADLine (AAInd = AInd + 2 if 
//            CrossPoints are found)
// AFRect   - Float Rectangle
// ADPoint1 - Segment first Vertex (Double Point, should be outside given 
//            Rectangle)
// APos1    - resulting first Vertex position code relative to given rectangle 
//            (calculates if undefined - =-1)
// ADPoint2 - Segment second Vertex (Double Point, should be outside given 
//            Rectangle)
// APos2    - resulting second Vertex position code relative to given rectangle 
//            (calculates if undefined - =-1)
// Result   - Returns CrossPoints position code:
//#F
//   bits0-3($00F)  = first CrossPoint Position
//   bits4-7($0F0)  = Second CrossPoint Position
//   =0 - no Cross-Section between given Segment  and Rectangle
//#/F
//
// Find Crosspoints where Segment leaves given Rectangle out.
//
function N_SegmCrossRectBorder2( const ADLine: TN_DPArray; var AInd: integer;
                 const AFRect: TFRect; const ADPoint1: TDPoint; var APos1: integer;
                               const ADPoint2: TDPoint; var APos2: integer ): integer;
var
  NShift: integer;
  X, Y, YLeft, YRight, XTop, XBottom, Coef: double;
  label Fin;
begin
  Result := 0;
  if APos1 = -1 then APos1 := N_PointInRect( ADPoint1, AFRect );
  if APos2 = -1 then APos2 := N_PointInRect( ADPoint2, AFRect );
  if (APos1 and APos2) <> 0 then Exit; // no crossection

  if ADPoint1.Y = ADPoint2.Y then // horizontal Segment,
  begin                         // AFRect.Top <= ADPoint1,2.Y <= AFRect.Bottom
    ADLine[AInd].X   := AFRect.Left;
    ADLine[AInd].Y   := ADPoint1.Y;
    ADLine[AInd+1].X := AFRect.Right;
    ADLine[AInd+1].Y := ADPoint1.Y;
    AInd := AInd + 2;
    Result := $041;
    goto Fin;
  end;

  if ADPoint1.X = ADPoint2.X then // vertical Segment,
  begin                         // AFRect.Left <= ADPoint1,2.X <= AFRect.Right
    ADLine[AInd].X   := ADPoint1.X;
    ADLine[AInd].Y   := AFRect.Top;
    ADLine[AInd+1].X := ADPoint1.X;
    ADLine[AInd+1].Y := AFRect.Bottom;
    AInd := AInd + 2;
    Result := $082;
    goto Fin;
  end;

  Coef := (ADPoint2.X-ADPoint1.X) / (ADPoint2.Y-ADPoint1.Y);
  NShift := 0;

  YLeft  := ADPoint1.Y + (AFRect.Left-ADPoint1.X) / Coef;
  if (YLeft>=AFRect.Top) and (YLeft<=AFRect.Bottom) then
  begin                           // Segm crosses Left border of AFRect
    ADLine[AInd].X := AFRect.Left;
    ADLine[AInd].Y := YLeft;
    AInd := AInd + 1;
    Result := $01;
    Inc( NShift, 4 );
  end;

  XTop   := ADPoint1.X + (AFRect.Top-ADPoint1.Y) * Coef;
  if (XTop>=AFRect.Left) and (XTop<=AFRect.Right) then
  begin                           // Segm crosses Top border of AFRect
    ADLine[AInd].X := XTop;
    ADLine[AInd].Y := AFRect.Top;
    AInd := AInd + 1;
    Result := Result or ($02 shl NShift);
    Inc( NShift, 4 );
  end;

  YRight := ADPoint1.Y + (AFRect.Right-ADPoint1.X) / Coef;
  if (YRight>=AFRect.Top) and (YRight<=AFRect.Bottom) then
  begin                           // Segm crosses Right border of AFRect
    ADLine[AInd].X := AFRect.Right;
    ADLine[AInd].Y := YRight;
    AInd := AInd + 1;
    Result := Result or ($04 shl NShift);
    Inc( NShift, 4 );
  end;

  XBottom   := ADPoint1.X + (AFRect.Bottom-ADPoint1.Y) * Coef;
  if (XBottom>=AFRect.Left) and (XBottom<=AFRect.Right) then
  begin                           // Segm crosses Bottom border of AFRect
    ADLine[AInd].X := XBottom;
    ADLine[AInd].Y := AFRect.Bottom;
    AInd := AInd + 1;
    Result := Result or ($08 shl NShift);
  end;

  Fin: // swap cross points if needed so, that ADLine[AInd-2] in nearer ADPoint1
       //                                  and ADLine[AInd-1] in nearer ADPoint2

  if Result <> 0 then // exactly two points are added, swap them so, that
  begin // ADLine[AInd-2] in nearer ADPoint1 and ADLine[AInd-1] in nearer ADPoint2
    if ( (ADPoint2.X-ADLine[AInd-1].X)*(ADPoint2.X-ADLine[AInd-1].X) +
         (ADPoint2.Y-ADLine[AInd-1].Y)*(ADPoint2.Y-ADLine[AInd-1].Y) ) >
       ( (ADPoint2.X-ADLine[AInd-2].X)*(ADPoint2.X-ADLine[AInd-2].X) +
         (ADPoint2.Y-ADLine[AInd-2].Y)*(ADPoint2.Y-ADLine[AInd-2].Y) ) then
    begin
      X := ADLine[AInd-1].X;
      ADLine[AInd-1].X := ADLine[AInd-2].X;
      ADLine[AInd-2].X := X;
      Y := ADLine[AInd-1].Y;
      ADLine[AInd-1].Y := ADLine[AInd-2].Y;
      ADLine[AInd-2].Y := Y;
      Result := ((Result and $F)  shl 4) or
                ((Result and $F0) shr 4); // swap flags
    end;
  end; // end if Result <> 0 then ...
end; // end of function N_SegmCrossRectBorder2(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DistAlongRectBorder(float)
//******************************************** N_DistAlongRectBorder(float) ***
// Calculate distance between given Float Point and Upper/Left Float Rectangle 
// Corner along Rectangle border in clockwise direction
//
//     Parameters
// APos    - given Point position relative to given Rectangle
//#F
//   bits0-3($0F)  = 1 - on the Left side
//   bits0-3($0F)  = 2 - on the Top side
//   bits0-3($0F)  = 4 - on the Right side
//   bits0-3($0F)  = 8 - on the Bottom side
//#/F
// AFRect  - Float Rectangle
// AFPoint - FLoat Point
// Result  - Returns distance between given Point and upper/left given Rectangle
//           Corner.
//
// Given Rectangle should be ordered. If given Point coincides with 
// AFrect.TopLeft corner then resulting distance equals 0. If given Point 
// coincides with AFRect.TopRight corner then resulting distance equals 
// AFRect.Width.
//
function N_DistAlongRectBorder( const APos: integer; const AFRect: TFRect;
                                           const AFPoint: TFPoint ): double;
begin
  Result := 0.0; // to avoid warning
  if (APos and $02) = $02 then // APoint is on Top border
  begin
    Result := (AFPoint.X - AFRect.Left);
    Exit;
  end;

  if (APos and $04) = $04 then // APoint is on Right border
  begin
    Result := (AFRect.Right - AFRect.Left) + (AFPoint.Y - AFRect.Top);
    Exit;
  end;

  if (APos and $08) = $08 then // APoint is on Bottom border
  begin
    Result := (AFRect.Right - AFRect.Left) + (AFRect.Bottom - AFRect.Top) +
              (AFRect.Right - AFPoint.X);
    Exit;
  end;

  if (APos and $01) = $01 then // APoint is on Left border
  begin
    Result := 2*(AFRect.Right - AFRect.Left) + (AFRect.Bottom - AFRect.Top) +
                (AFRect.Bottom - AFPoint.Y);
    Exit;
  end;
end; // end of function N_DistAlongRectBorder(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DistAlongRectBorder(double)
//******************************************* N_DistAlongRectBorder(double) ***
// Calculate distance between given Double Point and Upper/Left Float Rectangle 
// Corner along Rectangle border in clockwise direction
//
//     Parameters
// APos    - given Point position relative to given Rectangle
//#F
//   bits0-3($0F)  = 1 - on the Left side
//   bits0-3($0F)  = 2 - on the Top side
//   bits0-3($0F)  = 4 - on the Right side
//   bits0-3($0F)  = 8 - on the Bottom side
//#/F
// AFRect  - Float Rectangle
// ADPoint - Double Point
// Result  - Returns distance between given Point and upper/left given Rectangle
//           Corner.
//
// Given Rectangle should be ordered. If given Point coincides with 
// AFrect.TopLeft corner then resulting distance equals 0. If given Point 
// coincides with AFRect.TopRight corner then resulting distance equals 
// AFRect.Width.
//
function N_DistAlongRectBorder( const APos: integer; const AFRect: TFRect;
                                           const ADPoint: TDPoint ): double;
begin
  Result := 0.0; // to avoid warning
  if (APos and $02) = $02 then // APoint is on Top border
  begin
    Result := (ADPoint.X - AFRect.Left);
    Exit;
  end;

  if (APos and $04) = $04 then // APoint is on Right border
  begin
    Result := (AFRect.Right - AFRect.Left) + (ADPoint.Y - AFRect.Top);
    Exit;
  end;

  if (APos and $08) = $08 then // APoint is on Bottom border
  begin
    Result := (AFRect.Right - AFRect.Left) + (AFRect.Bottom - AFRect.Top) +
              (AFRect.Right - ADPoint.X);
    Exit;
  end;

  if (APos and $01) = $01 then // APoint is on Left border
  begin
    Result := 2*(AFRect.Right - AFRect.Left) + (AFRect.Bottom - AFRect.Top) +
                (AFRect.Bottom - ADPoint.Y);
    Exit;
  end;
end; // end of function N_DistAlongRectBorder(double)

//***************************************************** N_CalcPerpendicular ***
// Calc Perpendicular Line to given Line
// Line is given by ADP1, ADP2 Points
// Given point ADP3 always belongs to Resulting perpendicular Line
//
//     Parameters
// ADP1, ADP2 - Line, given by two Points
// ADPRes     - some given point of Resulting perpendicular Line
// Result     - Return some second point of Resulting perpendicular Line
//
// Given Line and (ADPRes, Result) Line are perpendicular
//
function N_CalcPerpendicular( const ADP1, ADP2, ADPRes: TDPoint ): TDPoint;
begin
  // Vector ( ADP1.Y-ADP2.Y, ADP2.X-ADP1.X ) is perpendicular to given Line
  Result.X := ADPRes.X + ADP1.Y - ADP2.Y;
  Result.Y := ADPRes.Y + ADP2.X - ADP1.X;
end; // end of function N_CalcPerpendicular

//******************************************************** N_CalcCrossPoint ***
// Calc Cross Point of two given Lines (not Segments!).
// Line1 is given by ADP1, ADP2 Points
// Line2 is given by ADP3, ADP4 Points
//
//     Parameters
// ADP1, ADP2 - Line1, given by two Points
// ADP3, ADP4 - Line2, given by two Points
// Result     - Return Line1, Line2 Cross Point or Result.X = N_NotADouble
//
// for Line1 (x,y) Points:
//     y = K12*(x-ADP1.X) + ADP1.Y  where K12=(ADP2.Y-ADP1.Y)/(ADP2.X-ADP1.X)
// for Line2 (x,y) Points:
//     y = K34*(x-ADP3.X) + ADP3.Y  where K34=(ADP4.Y-ADP3.Y)/(ADP4.X-ADP3.X)
//
// K12*(x-ADP1.X) + ADP1.Y = K34*(x-ADP3.X) + ADP3.Y  ==>
// x*(K12-K34) = K12*ADP1.X - K34*ADP3.X + ADP3.Y - ADP1.Y
//
function N_CalcCrossPoint( const ADP1, ADP2, ADP3, ADP4: TDPoint ): TDPoint;
var
  x, y, K12, K34, Eps, Znam: Double;
begin
//  N_Dump1Str( 'N_CalcCrossPoint 1' );
  Eps := 1.0/10000000000; // e-10

  Znam := ADP2.X - ADP1.X;

  if abs(Znam) > Eps then
    K12 := ( ADP2.Y - ADP1.Y ) / Znam
  else
    K12 := N_NotADouble;

  Znam := ADP4.X - ADP3.X;

  if abs(Znam) > Eps then
    K34 := ( ADP4.Y - ADP3.Y ) / Znam
  else
    K34 := N_NotADouble;

  if K12 = N_NotADouble then // Line1 is vertical: x = ADP1.X = ADP2.X
  begin
    if K34 = N_NotADouble then // Line2 is vertical: x = ADP3.X = ADP4.X
    begin
      if ADP1.X = ADP3.X then
        Result := ADP1 // Line1 and Line2 are the same, any Point (1,2,3,4) is OK
      else
        Result := DPoint( N_NotADouble, 0 ); // Line1 and Line2 are parallel, no Cross Point
    end else // K34 <> N_NotADouble,  Line2 is not vertical
      Result := DPoint( ADP1.X, K34*(ADP1.X-ADP3.X) + ADP3.Y );

    Exit; // all done
  end; // if K12 = N_NotADouble then // Line1 is vertical: x = ADP1.X = ADP2.X

  if K34 = N_NotADouble then // Line2 is vertical, Line1 not
    Result := DPoint( ADP3.X, K12*(ADP3.X-ADP1.X) + ADP1.Y )
  else // K34 <> N_NotADouble,  both Line1, Line2 are not vertical
  begin
    Znam := K12 - K34;

    if abs(Znam) > Eps then // Line1, Line2 are not parallel, not vertical
    begin
      x := ( K12*ADP1.X - K34*ADP3.X + ADP3.Y - ADP1.Y ) / ( K12 - K34 );
      y := K12*( x - ADP1.X ) + ADP1.Y;
      Result := DPoint( x, y );
    end else // Line1, Line2 are not vertical but parallel
    begin
      y := K12*( ADP3.X - ADP1.X ) + ADP1.Y;

      if abs(y-ADP3.Y) > Eps then // Line1 and Line2 are parallel, no Cross Point
        Result := DPoint( N_NotADouble, 0 )
      else // Line1 and Line2 are the same, any point (1,2,3,4) is OK
        Result := ADP1;
    end; // else // Line1, Line2 are not vertical but parallel
  end; // else // K34 <> N_NotADouble,  both Line1, Line2 are not vertical

end; // end of function N_CalcCrossPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ClipFLine
//************************************************************* N_ClipFLine ***
// Clip Float Polyline by given Clipping Float Rectangle
//
//     Parameters
// AClipFRect - clipping Float Rectangle
// ALineEnds  - array of records (TN_LineEndPos) with information about
//              Crosspoints of Polyline with clipping Rectangle
// AInpFLine  - clipping Polyline given as array of Float Points
// ADLA       - array of resulting (clipped) Polylines (each Polyline as Double
//              Points array)
//
// Clipping result is stored as clipped Polylines array ADLA and array of
// records with information about clipped Polylines Crosspoints with clipping
// Rectangle.
//
procedure N_ClipFLine( const AClipFRect: TFRect; var ALineEnds: TN_LEPArray;
                             const AInpFLine: TN_FPArray; var ADLA: TN_ADPArray );
var
  InpInd, OutInd, LineEndsInd, NPoints: integer;
  PosPrev, PosCur, CrossPos, IBeg: integer;
  DLI: integer;
  CrossPoint: TFPoint;
  CrossLine: TN_FPArray;
begin
  SetLength( CrossLine, 2 );
  NPoints := Length( AInpFLine );
  SetLength( ADLA, 1 );

//!!! not implemenetd???

//!!  SetLength( ADLA[0], NPoints ); // debug
  N_FCoordsToDCoords( AInpFLine, ADLA[0] ); // debug
  Exit;  // debug

  LineEndsInd := 0;
  DLI := 0;
  OutInd := 0;

  PosCur := N_PointInRect( AInpFLine[0], AClipFRect );
  if PosCur = 0 then IBeg := 0  // first point is Inside ClipDRect
                else IBeg := 1; // first point is Outside ClipDRect

  for InpInd := IBeg to NPoints-1 do
  begin
    PosPrev := PosCur;
    PosCur := N_PointInRect( AInpFLine[InpInd], AClipFRect );
    if PosCur = 0 then // Cur point (AInpFLine[InpInd]) is Inside ClipDRect
    begin
      if PosPrev = 0 then // both Cur and Prev points inside
      begin
        ADLA[DLI,OutInd] := DPoint(AInpFLine[InpInd]);
        Inc(OutInd);
        Continue;
      end else // Prev outside, Cur inside, begin new OutDLine with two points
      begin
        CrossPos := N_SegmCrossRectBorder1( CrossPoint, AClipFRect,
                                        AInpFLine[InpInd], AInpFLine[InpInd-1] );
        ADLA[DLI,OutInd] := DPoint(CrossPoint);
        if ALineEnds <> nil then // collect info for N_ClipDContour
        begin
          ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder( CrossPos,
                                              AClipFRect, ADLA[DLI,OutInd] );
          ALineEnds[LineEndsInd].LineInd := DLI;
          ALineEnds[LineEndsInd].Flags := $011;
          Inc(LineEndsInd);
        end;
        Inc(OutInd);
        ADLA[DLI,OutInd] := DPoint(AInpFLine[InpInd]);
        Inc(OutInd);
        Continue;
      end;
    end else //***** Cur point (AInpFLine[InpInd]) is Outside ClipDRect
    begin
      if PosPrev = 0 then // Prev is Inside, Cur is Outside - add last point
      begin               // in OutDLine, close it and begin next one
        CrossPos := N_SegmCrossRectBorder1( CrossPoint, AClipFRect,
                                        AInpFLine[InpInd-1], AInpFLine[InpInd] );
        ADLA[DLI,OutInd] := DPoint(CrossPoint);
        if ALineEnds <> nil then // collect info for N_ClipDContour
        begin
          ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder( CrossPos,
                                              AClipFRect, ADLA[DLI,OutInd] );
          ALineEnds[LineEndsInd].LineInd := DLI;
          ALineEnds[LineEndsInd].Flags := $022;
          Inc(LineEndsInd);
        end;
        SetLength( ADLA[DLI], OutInd+1 );
        Inc(DLI);
        SetLength( ADLA, DLI+1 );
        SetLength( ADLA[DLI], NPoints ); // make new OutDLine
        OutInd := 0;
        Continue;
      end else // both Prev and Cur points are Outside,
      begin    // check if LineSegm crosses ClipDRect
        OutInd := 0;
        CrossPos := N_SegmCrossRectBorder2( CrossLine, OutInd, AClipFRect,
                       AInpFLine[InpInd-1], PosPrev, AInpFLine[InpInd], PosCur );
        if CrossPos <> 0 then
        begin // add new OutDLine with two points
          if ALineEnds <> nil then // collect info for N_ClipDContour
          begin
            ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              (CrossPos and $0F), AClipFRect, CrossLine[0] );
            ALineEnds[LineEndsInd].LineInd := DLI;
            ALineEnds[LineEndsInd].Flags := $011;
            Inc(LineEndsInd);

            ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
                       (CrossPos shr 4), AClipFRect, DPoint(CrossLine[1]) );
            ALineEnds[LineEndsInd].LineInd := DLI;
            ALineEnds[LineEndsInd].Flags := $022;
            Inc(LineEndsInd);
          end;
          SetLength( ADLA[DLI], 2 );
          ADLA[DLI, 0] := DPoint(CrossLine[0]);
          ADLA[DLI, 1] := DPoint(CrossLine[1]);
          Inc(DLI);
          SetLength( ADLA, DLI+1 );
          SetLength( ADLA[DLI], NPoints ); // make new OutDLine
          OutInd := 0;
        end;
        Continue;
      end;
    end; // end else - Cur point is Outside ClipDRect
  end; // end for InpInd := 0 to NPoints-1 do

  SetLength( ADLA[DLI], OutInd ); // last line size

  if OutInd = 0 then // last line is empty
  begin
    if DLI = 0 then ADLA := nil             // empty whole output array
               else SetLength( ADLA, DLI ); // remove last empty line
  end;

  if ALineEnds <> nil then // add to LineEnd ClipDRect corners
  begin                   //  (is needed N_ClipDContour proc)
    if LineEndsInd > 0 then // there are some ALineEnds, add four corner points
    begin
      ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
                      $02, AClipFRect, DPoint( AClipFRect.Left, AClipFRect.Top ) );
      ALineEnds[LineEndsInd].Flags := $100;
      Inc(LineEndsInd);
      ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
                      $02, AClipFRect, DPoint( AClipFRect.Right, AClipFRect.Top ) );
      ALineEnds[LineEndsInd].Flags := $200;
      Inc(LineEndsInd);
      ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
                      $04, AClipFRect, DPoint( AClipFRect.Right, AClipFRect.Bottom ) );
      ALineEnds[LineEndsInd].Flags := $300;
      Inc(LineEndsInd);
      ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
                      $08, AClipFRect, DPoint( AClipFRect.Left, AClipFRect.Bottom ) );
      ALineEnds[LineEndsInd].Flags := $400;
      Inc(LineEndsInd);
    end;
    SetLength( ALineEnds, LineEndsInd ); // LineEndsInd=0 if no ALineEnds
  end;
end; // procedure N_ClipFLine

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ClipDLine
//************************************************************* N_ClipDLine ***
// Clip Double Polyline by given Clipping Float Rectangle
//
//     Parameters
// AClipFRect - clipping Float Rectangle
// ALineEnds  - array of records (TN_LineEndPos) with information about 
//              Crosspoints of Polyline with clipping Rectangle
// AInpDLine  - clipping Polyline given as array of Double Points
// ADLA       - array of resulting (clipped) Polylines (each Polyline as Double 
//              Points array)
//
// Clipping result is stored as clipped Polylines array ADLA and ALineEnds array
// of records with information about clipped Polylines Crosspoints with clipping
// Rectangle.
//
procedure N_ClipDLine( const AClipFRect: TFRect; var ALineEnds: TN_LEPArray;
                             const AInpDLine: TN_DPArray; var ADLA: TN_ADPArray );
var
  InpInd, OutInd, LineEndsInd, NPoints: integer;
  PosPrev, PosCur, CrossPos, IBeg: integer;
  DLI: integer;
  CrossLine: TN_DPArray;
begin
  SetLength( CrossLine, 2 );
  NPoints := Length( AInpDLine );
  SetLength( ADLA, 1 );
  SetLength( ADLA[0], NPoints );
  LineEndsInd := 0;
  DLI := 0;
  OutInd := 0;

  PosCur := N_PointInRect( AInpDLine[0], AClipFRect );
  if PosCur = 0 then IBeg := 0  // first point is Inside AClipFRect
                else IBeg := 1; // first point is Outside AClipFRect

  for InpInd := IBeg to NPoints-1 do
  begin
    PosPrev := PosCur;
    PosCur := N_PointInRect( AInpDLine[InpInd], AClipFRect );
    if PosCur = 0 then // Cur point (AInpDLine[InpInd]) is Inside AClipFRect
    begin
      if PosPrev = 0 then // both Cur and Prev points inside
      begin
        ADLA[DLI,OutInd] := AInpDLine[InpInd];
        Inc(OutInd);
        Continue;
      end else // Prev outside, Cur inside, begin new OutDLine with two points
      begin
        CrossPos := N_SegmCrossRectBorder1( ADLA[DLI,OutInd], AClipFRect,
                      AInpDLine[InpInd], AInpDLine[InpInd-1] );
        if ALineEnds <> nil then // collect info for N_ClipDContour
        begin
          ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder( CrossPos,
                                              AClipFRect, ADLA[DLI,OutInd] );
          ALineEnds[LineEndsInd].LineInd := DLI;
          ALineEnds[LineEndsInd].Flags := $011;
          Inc(LineEndsInd);
        end;
        Inc(OutInd);
        ADLA[DLI,OutInd] := AInpDLine[InpInd];
        Inc(OutInd);
        Continue;
      end;
    end else //***** Cur point (AInpDLine[InpInd]) is Outside AClipFRect
    begin
      if PosPrev = 0 then // Prev is Inside, Cur is Outside - add last point
      begin               // in OutDLine, close it and begin next one
        CrossPos := N_SegmCrossRectBorder1( ADLA[DLI,OutInd], AClipFRect,
                                        AInpDLine[InpInd-1], AInpDLine[InpInd] );
        if ALineEnds <> nil then // collect info for N_ClipDContour
        begin
          ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder( CrossPos,
                                                  AClipFRect, ADLA[DLI,OutInd] );
          ALineEnds[LineEndsInd].LineInd := DLI;
          ALineEnds[LineEndsInd].Flags := $022;
          Inc(LineEndsInd);
        end;
        SetLength( ADLA[DLI], OutInd+1 );
        Inc(DLI);
        SetLength( ADLA, DLI+1 );
        SetLength( ADLA[DLI], NPoints ); // make new OutDLine
        OutInd := 0;
        Continue;
      end else // both Prev and Cur points are Outside,
      begin    // check if LineSegm crosses AClipFRect
        OutInd := 0;
        CrossPos := N_SegmCrossRectBorder2( CrossLine, OutInd, AClipFRect,
                      AInpDLine[InpInd-1], PosPrev, AInpDLine[InpInd], PosCur );
        if CrossPos <> 0 then
        begin // add new OutDLine with two points
          if ALineEnds <> nil then // collect info for N_ClipDContour
          begin
            ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              (CrossPos and $0F), AClipFRect, CrossLine[0] );
            ALineEnds[LineEndsInd].LineInd := DLI;
            ALineEnds[LineEndsInd].Flags := $011;
            Inc(LineEndsInd);

            ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              (CrossPos shr 4), AClipFRect, CrossLine[1] );
            ALineEnds[LineEndsInd].LineInd := DLI;
            ALineEnds[LineEndsInd].Flags := $022;
            Inc(LineEndsInd);
          end;
          SetLength( ADLA[DLI], 2 );
          move( CrossLine[0], ADLA[DLI, 0], 2*sizeof(CrossLine[0]) );
          Inc(DLI);
          SetLength( ADLA, DLI+1 );
          SetLength( ADLA[DLI], NPoints ); // make new OutDLine
          OutInd := 0;
        end;
        Continue;
      end;
    end; // end else - Cur point is Outside AClipFRect
  end; // end for InpInd := 0 to NPoints-1 do

  SetLength( ADLA[DLI], OutInd ); // last line size

  if OutInd = 0 then // last line is empty
  begin
    if DLI = 0 then ADLA := nil             // empty whole output array
               else SetLength( ADLA, DLI ); // remove last empty line
  end;

  if ALineEnds <> nil then // add to LineEnd AClipFRect corners
  begin                   //  (is needed N_ClipDContour proc)
    if LineEndsInd > 0 then // there are some ALineEnds, add four corner points
    begin
      ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
                $02, AClipFRect, DPoint( AClipFRect.Left, AClipFRect.Top ) );
      ALineEnds[LineEndsInd].Flags := $100;
      Inc(LineEndsInd);
      ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
                $02, AClipFRect, FPoint( AClipFRect.Right, AClipFRect.Top ) );
      ALineEnds[LineEndsInd].Flags := $200;
      Inc(LineEndsInd);
      ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
                $04, AClipFRect, FPoint( AClipFRect.Right, AClipFRect.Bottom ) );
      ALineEnds[LineEndsInd].Flags := $300;
      Inc(LineEndsInd);
      ALineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
                $08, AClipFRect, FPoint( AClipFRect.Left, AClipFRect.Bottom ) );
      ALineEnds[LineEndsInd].Flags := $400;
      Inc(LineEndsInd);
    end;
    SetLength( ALineEnds, LineEndsInd ); // LineEndsInd=0 if no LineEnds
  end;
end; // end of procedure N_ClipDLine

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ClipLineByRect(float)
//************************************************* N_ClipLineByRect(float) ***
// Clip Float Polyline by given Clipping Float Rectangle
//
//     Parameters
// AClipFRect   - clipping Float Rectangle
// APInpFPoints - pointer to first Float Point in given Polyline
// ANPoints     - number of pointas in given Polyline
// AOutLengths  - array of numbers of points in resulting Polylines
// AOutFLines   - array of resulting Polylines (each resulting Polyline as Float
//                Points array)
// Result       - Returns resulting Polylines counter
//
function N_ClipLineByRect( const AClipFRect: TFRect; APInpFPoints: PFPoint;
                           ANPoints: integer; var AOutLengths: TN_IArray;
                                         var AOutFLines: TN_AFPArray ): integer;
var
  InpInd, OutInd, OLI: integer;
  PosPrev, PosCur, CrossPos, IBeg: integer;
  APInpFPointsM1: PFPoint;
begin
  // initial Length of AOutFLines and AOutLengths should be >=1 and THE SAME!
  if Length(AOutLengths) > Length(AOutFLines) then
  begin
    AOutFLines := nil;
    Setlength( AOutFLines, Length(AOutLengths) );
  end;

  OLI := 0;
  if Length(AOutFLines[0]) < ANPoints then
  begin
    AOutFLines[0] := nil; // to prevent data moving
    SetLength( AOutFLines[0], N_NewLength(ANPoints) );
  end;
  OutInd := 0;

  PosCur := N_PointInRect( APInpFPoints^, AClipFRect );
  if PosCur = 0 then
  begin
   IBeg := 0;  // first point is Inside AClipFRect
   Dec(APInpFPoints);
  end else
  begin
   IBeg := 1; // first point is Outside AClipFRect
  end;

  APInpFPointsM1 := APInpFPoints;
  Dec(APInpFPointsM1); // Ptr to previous Point

  for InpInd := IBeg to ANPoints-1 do
  begin
    Inc(APInpFPoints);
    Inc(APInpFPointsM1);

    PosPrev := PosCur;
    PosCur := N_PointInRect( APInpFPoints^, AClipFRect );
    if PosCur = 0 then // Cur point (Inpline[InpInd]) is Inside AClipFRect
    begin
      if PosPrev = 0 then // both Cur and Prev points inside, add Cur Point to OutLine
      begin
        AOutFLines[OLI,OutInd] := APInpFPoints^;
        Inc(OutInd);
        Continue;
      end else // Prev outside, Cur inside, set two first Points of OutLine
      begin
        N_SegmCrossRectBorder1( AOutFLines[OLI,OutInd], AClipFRect,
                                         APInpFPoints^, APInpFPointsM1^ );
        Inc(OutInd);
        AOutFLines[OLI,OutInd] := APInpFPoints^;
        Inc(OutInd);
        Continue;
      end;
    end else //***** Cur point (APInpFPoints^) is Outside AClipFRect
    begin
      if PosPrev = 0 then // Prev is Inside, Cur is Outside - add last point
      begin               // to OutLine, close it and begin next one
        N_SegmCrossRectBorder1( AOutFLines[OLI,OutInd], AClipFRect,
                                        APInpFPointsM1^, APInpFPoints^ );
        AOutLengths[OLI] := OutInd+1;
        Inc(OLI);

        if High(AOutLengths) < OLI then
        begin
          SetLength( AOutLengths, N_NewLength(OLI) );
          SetLength( AOutFLines, Length(AOutLengths) );
        end;

        if Length(AOutFLines[OLI]) < ANPoints then
        begin
          AOutFLines[OLI] := nil; // to prevent data moving
          SetLength( AOutFLines[OLI], N_NewLength(ANPoints) );
        end;

        OutInd := 0;
        Continue;
      end else // both Prev and Cur points are Outside,
      begin    // check if LineSegm crosses AClipFRect
        OutInd := 0;
        CrossPos := N_SegmCrossRectBorder2( N_WrkFSegm1, OutInd, AClipFRect,
                       APInpFPointsM1^, PosPrev, APInpFPoints^, PosCur );
        if CrossPos <> 0 then
        begin // add new OutLine with two points and finish it
          move( N_WrkFSegm1[0], AOutFLines[OLI, 0], 2*sizeof(N_WrkFSegm1[0]) );
          AOutLengths[OLI] := 2;
          Inc(OLI);
          if High(AOutLengths) < OLI then
          begin
            SetLength( AOutLengths, N_NewLength(OLI) );
            SetLength( AOutFLines, Length(AOutLengths) );
          end;

          if Length(AOutFLines[OLI]) < ANPoints then
          begin
            AOutFLines[OLI] := nil; // to prevent data moving
            SetLength( AOutFLines[OLI], N_NewLength(ANPoints) );
          end;

          OutInd := 0;
        end;
        Continue;
      end;
    end; // end else - Cur point is Outside AClipFRect
  end; // end for InpInd := 0 to ANPoints-1 do

  AOutLengths[OLI] := OutInd; // last line size
  if OutInd = 0 then // return number of Lines in AOutFLines
    Result := OLI
  else
    Result := OLI + 1; // number of Lines in AOutFLines
end; // function N_ClipLineByRect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ClipLineByRect(double)
//************************************************ N_ClipLineByRect(double) ***
// Clip Double Polyline by given Clipping Float Rectangle
//
//     Parameters
// AClipFRect   - clipping Float Rectangle
// APInpDPoints - pointer to first Double Point in given Polyline
// ANPoints     - number of points in given Polyline
// AOutLengths  - array of numbers of points in resulting Polylines
// AOutDLines   - array of resulting Polylines (each resulting Polyline as 
//                Double Points array)
// Result       - Returns resulting Polylines counter
//
function N_ClipLineByRect( const AClipFRect: TFRect; APInpDPoints: PDPoint;
                           ANPoints: integer; var AOutLengths: TN_IArray;
                                         var AOutDLines: TN_ADPArray ): integer;
var
  InpInd, OutInd, OLI: integer;
  PosPrev, PosCur, CrossPos, IBeg: integer;
  APInpDPointsM1: PDPoint;
begin
  // initial Length of AOutDLines and AOutLengths should be >=1 and THE SAME!
  if Length(AOutLengths) > Length(AOutDLines) then
  begin
    AOutDLines := nil;
    Setlength( AOutDLines, Length(AOutLengths) );
  end;

  OLI := 0;
  if Length(AOutDLines[0]) < ANPoints then
  begin
    AOutDLines[0] := nil; // to prevent data moving
    SetLength( AOutDLines[0], N_NewLength(ANPoints) );
  end;
  OutInd := 0;

  PosCur := N_PointInRect( APInpDPoints^, AClipFRect );
  if PosCur = 0 then
  begin
   IBeg := 0;  // first point is Inside AClipFRect
   Dec(APInpDPoints);
  end else
  begin
   IBeg := 1; // first point is Outside AClipFRect
  end;

  APInpDPointsM1 := APInpDPoints;
  Dec(APInpDPointsM1); // Ptr to previous Point

  for InpInd := IBeg to ANPoints-1 do
  begin
    Inc(APInpDPoints);
    Inc(APInpDPointsM1);

    PosPrev := PosCur;
    PosCur := N_PointInRect( APInpDPoints^, AClipFRect );
    if PosCur = 0 then // Cur point (APInpDPoints^) is Inside AClipFRect
    begin
      if PosPrev = 0 then // both Cur and Prev points inside, add Cur Point to OutLine
      begin
        AOutDLines[OLI,OutInd] := APInpDPoints^;
        Inc(OutInd);
        Continue;
      end else // Prev outside, Cur inside, set two first Points of OutLine
      begin
        N_SegmCrossRectBorder1( AOutDLines[OLI,OutInd], AClipFRect,
                                         APInpDPoints^, APInpDPointsM1^ );
        Inc(OutInd);
        AOutDLines[OLI,OutInd] := APInpDPoints^;
        Inc(OutInd);
        Continue;
      end;
    end else //***** Cur point (APInpDPoints^) is Outside AClipFRect
    begin
      if PosPrev = 0 then // Prev is Inside, Cur is Outside - add last point
      begin               // to OutLine, close it and begin next one
        N_SegmCrossRectBorder1( AOutDLines[OLI,OutInd], AClipFRect,
                                        APInpDPointsM1^, APInpDPoints^ );
        AOutLengths[OLI] := OutInd+1;
        Inc(OLI);

        if High(AOutLengths) < OLI then
        begin
          SetLength( AOutLengths, N_NewLength(OLI) );
          SetLength( AOutDLines, Length(AOutLengths) );
        end;

        if Length(AOutDLines[OLI]) < ANPoints then
        begin
          AOutDLines[OLI] := nil; // to prevent data moving
          SetLength( AOutDLines[OLI], N_NewLength(ANPoints) );
        end;

        OutInd := 0;
        Continue;
      end else // both Prev and Cur points are Outside,
      begin    // check if LineSegm crosses AClipFRect
        OutInd := 0;
        CrossPos := N_SegmCrossRectBorder2( N_WrkDSegm1, OutInd, AClipFRect,
                       APInpDPointsM1^, PosPrev, APInpDPoints^, PosCur );
        if CrossPos <> 0 then
        begin // add new OutLine with two points and finish it
          move( N_WrkDSegm1[0], AOutDLines[OLI, 0], 2*sizeof(N_WrkDSegm1[0]) );
          AOutLengths[OLI] := 2;
          Inc(OLI);
          if High(AOutLengths) < OLI then
          begin
            SetLength( AOutLengths, N_NewLength(OLI) );
            SetLength( AOutDLines, Length(AOutLengths) );
          end;

          if Length(AOutDLines[OLI]) < ANPoints then
          begin
            AOutDLines[OLI] := nil; // to prevent data moving
            SetLength( AOutDLines[OLI], N_NewLength(ANPoints) );
          end;

          OutInd := 0;
        end;
        Continue;
      end;
    end; // end else - Cur point is Outside AClipFRect
  end; // end for InpInd := 0 to ANPoints-1 do

  AOutLengths[OLI] := OutInd; // last line size
  if OutInd = 0 then // return number of Lines in AOutDLines
    Result := OLI
  else
    Result := OLI + 1; // number of Lines in AOutDLines
end; // function N_ClipLineByRect(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ClipRingByRect(float)
//************************************************* N_ClipRingByRect(float) ***
// Clip Float Ring by given Clipping Float Rectangle
//
//     Parameters
// AClipFRect        - clipping Float Rectangle
// AInpRingDirection - =0 or =1 according to N_CalcRingDirection routine
// APInpFPoints      - pointer to first Double Point in given Ring
// ANPoints          - number of pointas in given Ring
// AOutLengths       - array of numbers of points in resulting Rings
// AOutFRings        - array of resulting Rings (each resulting Ring as Float 
//                     Points array)
// Result            - Returns resulting Rings counter
//
// Ring is closed Polyline. After clipping Ring as Line, Line Ends (which are on
// AClipFRect borders) are coonected by increasing distance along AClipFRect 
// borders if AInpRingDirection=0 or by decreasing distance if 
// AInpRingDirection=1.
//
function N_ClipRingByRect( const AClipFRect: TFRect; AInpRingDirection: integer;
                            APInpFPoints: PFPoint; ANPoints: integer;
               var AOutLengths: TN_IArray; var AOutFRings: TN_AFPArray ): integer;
var
  i, NEnds, LEPInd, LineEndsInd: integer;
  AddSize, CurLineInd, AOutFRingsCount, RingSize, ComparePar: integer;
  InpInd, OutInd, OLI: integer;
  PosPrev, PosCur, CrossPos, IBeg: integer;
  LineEnds: TN_LEPArray;
  LE: TN_LineEndPos;
  LI: TN_IArray; // -10 - processed, -1 - closed,inside, >=0 - index in LineEnds
  APInpFPointsM1, SavedAPInpFPoints: PFPoint;
begin
  SetLength( LineEnds, Max( 2010, 2*ANPoints + 10 ) );
  LineEndsInd := 0;

  // initial Length of N_WrkClipedLengths and N_WrkClipedDLines should be >=1 and THE SAME!
  if Length(N_WrkClipedLengths) > Length(N_WrkClipedFLines) then
  begin
    N_WrkClipedFLines := nil;
    Setlength( N_WrkClipedFLines, Length(N_WrkClipedLengths) );
  end;

  OLI := 0;
  if Length(N_WrkClipedFLines[0]) < ANPoints then
  begin
    N_WrkClipedFLines[0] := nil; // to prevent data moving
    SetLength( N_WrkClipedFLines[0], N_NewLength(ANPoints) );
  end;
  OutInd := 0;

  SavedAPInpFPoints := APInpFPoints;
  PosCur := N_PointInRect( APInpFPoints^, AClipFRect );
  if PosCur = 0 then
  begin
   IBeg := 0;  // first point is Inside AClipFRect
   Dec(APInpFPoints);
  end else
  begin
   IBeg := 1; // first point is Outside AClipFRect
  end;

  APInpFPointsM1 := APInpFPoints;
  Dec(APInpFPointsM1); // Ptr to previous Point

  for InpInd := IBeg to ANPoints-1 do
  begin
    Inc(APInpFPoints);
    Inc(APInpFPointsM1);

    PosPrev := PosCur;
    PosCur := N_PointInRect( APInpFPoints^, AClipFRect );
    if PosCur = 0 then // Cur point (APInpFPoints^) is Inside AClipFRect
    begin
      if PosPrev = 0 then // both Cur and Prev points inside, add Cur Point to OutLine
      begin
        N_WrkClipedFLines[OLI,OutInd] := APInpFPoints^;
        Inc(OutInd);
        Continue;
      end else // Prev outside, Cur inside, set two first Points of OutLine
      begin
        CrossPos := N_SegmCrossRectBorder1( N_WrkClipedFLines[OLI,OutInd],
                                       AClipFRect, APInpFPoints^, APInpFPointsM1^ );

        LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder( CrossPos,
                                    AClipFRect, N_WrkClipedFLines[OLI,OutInd] );
        LineEnds[LineEndsInd].LineInd := OLI;
        LineEnds[LineEndsInd].Flags := $011;
        Inc(LineEndsInd);

        Inc(OutInd);
        N_WrkClipedFLines[OLI,OutInd] := APInpFPoints^;
        Inc(OutInd);
        Continue;
      end;
    end else //***** Cur point (APInpFPoints^) is Outside AClipFRect
    begin
      if PosPrev = 0 then // Prev is Inside, Cur is Outside - add last point
      begin               // to OutLine, close it and begin next one
        CrossPos := N_SegmCrossRectBorder1( N_WrkClipedFLines[OLI,OutInd],
                                       AClipFRect, APInpFPointsM1^, APInpFPoints^ );

        LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder( CrossPos,
                                    AClipFRect, N_WrkClipedFLines[OLI,OutInd] );
        LineEnds[LineEndsInd].LineInd := OLI;
        LineEnds[LineEndsInd].Flags := $022;
        Inc(LineEndsInd);

        N_WrkClipedLengths[OLI] := OutInd+1;
        Inc(OLI);

        if High(N_WrkClipedLengths) < OLI then
        begin
          SetLength( N_WrkClipedLengths, N_NewLength(OLI) );
          SetLength( N_WrkClipedFLines, Length(N_WrkClipedLengths) );
        end;

        if Length(N_WrkClipedFLines[OLI]) < ANPoints then
        begin
          N_WrkClipedFLines[OLI] := nil; // to prevent data moving
          SetLength( N_WrkClipedFLines[OLI], N_NewLength(ANPoints) );
        end;

        OutInd := 0;
        Continue;
      end else // both Prev and Cur points are Outside,
      begin    // check if LineSegm crosses AClipFRect
        OutInd := 0;
        CrossPos := N_SegmCrossRectBorder2( N_WrkFSegm1, OutInd, AClipFRect,
                       APInpFPointsM1^, PosPrev, APInpFPoints^, PosCur );
        if CrossPos <> 0 then
        begin // add new OutLine with two points and finish it

          LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
            (CrossPos and $0F), AClipFRect, N_WrkFSegm1[0] );
          LineEnds[LineEndsInd].LineInd := OLI;
          LineEnds[LineEndsInd].Flags := $011;
          Inc(LineEndsInd);

          LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
            (CrossPos shr 4), AClipFRect, N_WrkFSegm1[1] );
          LineEnds[LineEndsInd].LineInd := OLI;
          LineEnds[LineEndsInd].Flags := $022;
          Inc(LineEndsInd);

          move( N_WrkFSegm1[0], N_WrkClipedFLines[OLI, 0], 2*sizeof(N_WrkFSegm1[0]) );

          N_WrkClipedLengths[OLI] := 2;
          Inc(OLI);
          if High(N_WrkClipedLengths) < OLI then
          begin
            SetLength( N_WrkClipedLengths, N_NewLength(OLI) );
            SetLength( N_WrkClipedFLines, Length(N_WrkClipedLengths) );
          end;

          if Length(N_WrkClipedFLines[OLI]) < ANPoints then
          begin
            N_WrkClipedFLines[OLI] := nil; // to prevent data moving
            SetLength( N_WrkClipedFLines[OLI], N_NewLength(ANPoints) );
          end;

          OutInd := 0;
        end;
        Continue;
      end;
    end; // end else - Cur point is Outside AClipFRect
  end; // end for InpInd := 0 to ANPoints-1 do

  N_WrkClipedLengths[OLI] := OutInd; // last line size
  Inc(OLI); // OLI - number of clipped lines
  if OutInd = 0 then Dec(OLI); // remove last empty line

  if LineEndsInd > 0 then // there are some LineEnds, add four corner points
  begin
    LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              $02, AClipFRect, FPoint( AClipFRect.Left, AClipFRect.Top ) );
    LineEnds[LineEndsInd].Flags := $100;
    Inc(LineEndsInd);
    LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              $02, AClipFRect, FPoint( AClipFRect.Right, AClipFRect.Top ) );
    LineEnds[LineEndsInd].Flags := $200;
    Inc(LineEndsInd);
    LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              $04, AClipFRect, FPoint( AClipFRect.Right, AClipFRect.Bottom ) );
    LineEnds[LineEndsInd].Flags := $300;
    Inc(LineEndsInd);
    LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              $08, AClipFRect, FPoint( AClipFRect.Left, AClipFRect.Bottom ) );
    LineEnds[LineEndsInd].Flags := $400;
    Inc(LineEndsInd);
  end;

//**** prev code is N_ClipDLine( AClipFRect, LineEnds, InpRing, ClipedLines );

  //***** Here: OLI - number of lines in N_WrkClipedFLines

  if OLI = 0 then
  with AClipFRect do // no ring border inside AClipFRect
  begin
    if 0 = N_DPointInsideFRing( SavedAPInpFPoints, ANPoints, AClipFRect,
                       DPoint( (Left+Right)/2, (Top+Bottom)/2 ) ) then
    begin // whole AClipFRect is inside InpRing
      Result := 1;
      AOutLengths[0] := 5;
      N_MakeFRectBorder( AOutFRings[0], AClipFRect );
    end else // whole AClipFRect is outside InpRing
    begin
      Result := 0;
    end;
    Exit;
  end;

  NEnds := LineEndsInd;
  ComparePar := 0;
  if AInpRingDirection <> 0 then ComparePar := N_SortOrder;

  if NEnds > 0 then
    N_SortElements( TN_BytesPtr(@LineEnds[0]), NEnds, sizeof(LineEnds[0]),
                                            ComparePar, N_CompareDoubles );

  SetLength( LI, OLI );

  for i := 0 to High(LI) do // set "End vertex of line is inside" flag
    LI[i] := -2;           // to all LI elements (initialization)

  for i := 0 to NEnds-1 do // loop along LineEnds and fill LI array
  begin
    LE := LineEnds[i];
    if ( LE.Flags and $F00) <> 0 then Continue; // corner of cliped rect
    if ( LE.Flags and $0F0) = $020 then // End of Line EndLine
      LI[LE.LineInd] := i;
  end; // for i := 0 to High(LineEnds) do // fill LI array

  if Length(AOutFRings) < OLI then
  begin
    SetLength( AOutFRings, OLI ); // max possible value
    SetLength( AOutLengths, OLI ); // max possible value
  end;

  AOutFRingsCount := 0;
  RingSize := 0;

  for i := 0 to High(LI) do // assemble Clipped Lines in AOutFRings
  begin
    if LI[i] = -10 then Continue; // i-th ClipedLine was already assembled
    if Length(N_WrkClipedFLines[i]) = 0 then Continue; // skip empty N_WrkClipedFLines

    //*** add other N_WrkClipedFLines to current ring (untill it was closed)

    CurLineInd := i;
    while True do // assemble all ring's lines
    begin
      //***** Add next (current) line coordinates to current ring

      AddSize := N_WrkClipedLengths[CurLineInd];
      if AddSize > 0 then
      begin
        if Length(AOutFRings[AOutFRingsCount]) < RingSize+AddSize then
          SetLength( AOutFRings[AOutFRingsCount], N_NewLength(RingSize+AddSize) );
        move( N_WrkClipedFLines[CurLineInd, 0], AOutFRings[AOutFRingsCount, RingSize],
                                                    AddSize*Sizeof(TFPoint) );
        Inc( RingSize, AddSize );
      end;

      if ( CurLineInd = i ) and // first line in Ring
         ( N_WrkClipedFLines[i,0].X = N_WrkClipedFLines[i,RingSize-1].X ) and
         ( N_WrkClipedFLines[i,0].Y = N_WrkClipedFLines[i,RingSize-1].Y )   then
        Break; // whole ring consists on one current line and is already OK

      LEPInd := LI[CurLineInd] + 1; // Next Line LEP index
      if LEPInd >= NEnds then LEPInd := 0;
      LI[CurLineInd] := -10;      // set "line was already assembled" flag

      if LEPInd = -9 then // no next line, previous line was last ring's line
      begin               // with it's End Vertex stricly inside ClipDRect,
        Break;            // go to next ring (if any)
      end;

      if (LEPInd = -1) then  // line has no EndPoint in LineEnds (is finished inside)
        Break; // ring is OK,  go to next ring (if any)

      Assert( LEPInd >= 0, 'error1' );

      while (LineEnds[LEPInd].Flags and $F00) <> 0 do // add ClipDRect corners
      begin
        if Length(AOutFRings[AOutFRingsCount]) < RingSize+1 then
          SetLength( AOutFRings[AOutFRingsCount], N_NewLength(RingSize+1) );
        case (LineEnds[LEPInd].Flags and $F00) of
          $100: AOutFRings[AOutFRingsCount, RingSize] := AClipFRect.TopLeft;
          $200: AOutFRings[AOutFRingsCount, RingSize] :=
                                      FPoint( AClipFRect.Right, AClipFRect.Top );
          $300: AOutFRings[AOutFRingsCount, RingSize] := AClipFRect.BottomRight;
          $400: AOutFRings[AOutFRingsCount, RingSize] :=
                                    FPoint( AClipFRect.Left, AClipFRect.Bottom );
        end; // case (LineEnds[LEPInd].Flags and $F00) of

        Inc(RingSize);
        Inc(LEPInd);
        if LEPInd >= NEnds then LEPInd := 0;

      end; // while (LineEnds[EndLineInd].Flags and $F00) <> 0 do // skip corners

      CurLineInd := LineEnds[LEPInd].LineInd; // next ring's Line index

      if CurLineInd = i then // previous line was last one,
      begin                  // just add one point and ring is OK
        if Length(AOutFRings[AOutFRingsCount]) < RingSize+1 then
          SetLength( AOutFRings[AOutFRingsCount], N_NewLength(RingSize+1) );
        AOutFRings[AOutFRingsCount, RingSize] := N_WrkClipedFLines[i, 0];
        Inc(RingSize);
        Break; // go to first line of next ring (if any)
      end;

    end; // while True do // loop along all "conected" lines

    AOutLengths[AOutFRingsCount] := RingSize;
    Inc(AOutFRingsCount); // inc number of prepared (finished) rings
    RingSize := 0;
  end; // for i := 0 to High(LI) do // assemble Clipped Lines in AOutFRings

  if RingSize > 0 then Inc(AOutFRingsCount);
  Result := AOutFRingsCount;
end; // end of function N_ClipRingByRect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ClipRingByRect(double)
//************************************************ N_ClipRingByRect(double) ***
// Clip Double Ring by given Clipping Float Rectangle
//
//     Parameters
// AClipFRect        - clipping Float Rectangle
// AInpRingDirection - =0 or =1 according to N_CalcRingDirection routine
// APInpDPoints      - pointer to first Double Point in given Ring
// ANPoints          - number of pointas in given Ring
// AOutLengths       - array of numbers of points in resulting Rings
// AOutDRings        - array of resulting Rings (each resulting Ring as Double 
//                     Points array)
// Result            - Returns resulting Rings counter
//
// Ring is closed Polyline. After clipping Ring as Line, Line Ends (which are on
// AClipFRect borders) are coonected by increasing distance along AClipFRect 
// borders if AInpRingDirection=0 or by decreasing distance if 
// AInpRingDirection=1.
//
function N_ClipRingByRect( const AClipFRect: TFRect; AInpRingDirection: integer;
                            APInpDPoints: PDPoint; ANPoints: integer;
               var AOutLengths: TN_IArray; var AOutDRings: TN_ADPArray ): integer;
var
  i, NEnds, LEPInd, LineEndsInd: integer;
  AddSize, CurLineInd, AOutDRingsCount, RingSize, ComparePar: integer;
  InpInd, OutInd, OLI: integer;
  PosPrev, PosCur, CrossPos, IBeg: integer;
  LineEnds: TN_LEPArray;
  LE: TN_LineEndPos;
  LI: TN_IArray; // -10 - processed, -1 - closed,inside, >=0 - index in LineEnds
  APInpDPointsM1, SavedAPInpDPoints: PDPoint;
begin
  SetLength( LineEnds, Max( 2010, 2*ANPoints + 10 ) );
  LineEndsInd := 0;

  // initial Length of N_WrkClipedLengths and N_WrkClipedDLines should be >=1 and THE SAME!
  if Length(N_WrkClipedLengths) > Length(N_WrkClipedDLines) then
  begin
    N_WrkClipedDLines := nil;
    Setlength( N_WrkClipedDLines, Length(N_WrkClipedLengths) );
  end;

  OLI := 0;
  if Length(N_WrkClipedDLines[0]) < ANPoints then
  begin
    N_WrkClipedDLines[0] := nil; // to prevent data moving
    SetLength( N_WrkClipedDLines[0], N_NewLength(ANPoints) );
  end;
  OutInd := 0;

  SavedAPInpDPoints := APInpDPoints;
  PosCur := N_PointInRect( APInpDPoints^, AClipFRect );
  if PosCur = 0 then
  begin
   IBeg := 0;  // first point is Inside AClipFRect
   Dec(APInpDPoints);
  end else
  begin
   IBeg := 1; // first point is Outside AClipFRect
  end;

  APInpDPointsM1 := APInpDPoints;
  Dec(APInpDPointsM1); // Ptr to previous Point

  for InpInd := IBeg to ANPoints-1 do
  begin
    Inc(APInpDPoints);
    Inc(APInpDPointsM1);

    PosPrev := PosCur;
    PosCur := N_PointInRect( APInpDPoints^, AClipFRect );
    if PosCur = 0 then // Cur point (APInpDPoints^) is Inside AClipFRect
    begin
      if PosPrev = 0 then // both Cur and Prev points inside, add Cur Point to OutLine
      begin
        N_WrkClipedDLines[OLI,OutInd] := APInpDPoints^;
        Inc(OutInd);
        Continue;
      end else // Prev outside, Cur inside, set two first Points of OutLine
      begin
        CrossPos := N_SegmCrossRectBorder1( N_WrkClipedDLines[OLI,OutInd],
                                       AClipFRect, APInpDPoints^, APInpDPointsM1^ );

        LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder( CrossPos,
                                    AClipFRect, N_WrkClipedDLines[OLI,OutInd] );
        LineEnds[LineEndsInd].LineInd := OLI;
        LineEnds[LineEndsInd].Flags := $011;
        Inc(LineEndsInd);

        Inc(OutInd);
        N_WrkClipedDLines[OLI,OutInd] := APInpDPoints^;
        Inc(OutInd);
        Continue;
      end;
    end else //***** Cur point (APInpDPoints^) is Outside AClipFRect
    begin
      if PosPrev = 0 then // Prev is Inside, Cur is Outside - add last point
      begin               // to OutLine, close it and begin next one
        CrossPos := N_SegmCrossRectBorder1( N_WrkClipedDLines[OLI,OutInd],
                                       AClipFRect, APInpDPointsM1^, APInpDPoints^ );

        LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder( CrossPos,
                                    AClipFRect, N_WrkClipedDLines[OLI,OutInd] );
        LineEnds[LineEndsInd].LineInd := OLI;
        LineEnds[LineEndsInd].Flags := $022;
        Inc(LineEndsInd);

        N_WrkClipedLengths[OLI] := OutInd+1;
        Inc(OLI);

        if High(N_WrkClipedLengths) < OLI then
        begin
          SetLength( N_WrkClipedLengths, N_NewLength(OLI) );
          SetLength( N_WrkClipedDLines, Length(N_WrkClipedLengths) );
        end;

        if Length(N_WrkClipedDLines[OLI]) < ANPoints then
        begin
          N_WrkClipedDLines[OLI] := nil; // to prevent data moving
          SetLength( N_WrkClipedDLines[OLI], N_NewLength(ANPoints) );
        end;

        OutInd := 0;
        Continue;
      end else // both Prev and Cur points are Outside,
      begin    // check if LineSegm crosses AClipFRect
        OutInd := 0;
        CrossPos := N_SegmCrossRectBorder2( N_WrkDSegm1, OutInd, AClipFRect,
                       APInpDPointsM1^, PosPrev, APInpDPoints^, PosCur );
        if CrossPos <> 0 then
        begin // add new OutLine with two points and finish it

          LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
            (CrossPos and $0F), AClipFRect, N_WrkDSegm1[0] );
          LineEnds[LineEndsInd].LineInd := OLI;
          LineEnds[LineEndsInd].Flags := $011;
          Inc(LineEndsInd);

          LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
            (CrossPos shr 4), AClipFRect, N_WrkDSegm1[1] );
          LineEnds[LineEndsInd].LineInd := OLI;
          LineEnds[LineEndsInd].Flags := $022;
          Inc(LineEndsInd);

          move( N_WrkDSegm1[0], N_WrkClipedDLines[OLI, 0], 2*sizeof(N_WrkDSegm1[0]) );

          N_WrkClipedLengths[OLI] := 2;
          Inc(OLI);
          if High(N_WrkClipedLengths) < OLI then
          begin
            SetLength( N_WrkClipedLengths, N_NewLength(OLI) );
            SetLength( N_WrkClipedDLines, Length(N_WrkClipedLengths) );
          end;

          if Length(N_WrkClipedDLines[OLI]) < ANPoints then
          begin
            N_WrkClipedDLines[OLI] := nil; // to prevent data moving
            SetLength( N_WrkClipedDLines[OLI], N_NewLength(ANPoints) );
          end;

          OutInd := 0;
        end;
        Continue;
      end;
    end; // end else - Cur point is Outside AClipFRect
  end; // end for InpInd := 0 to ANPoints-1 do

  N_WrkClipedLengths[OLI] := OutInd; // last line size
  Inc(OLI); // OLI - number of clipped lines
  if OutInd = 0 then Dec(OLI); // remove last empty line

  if LineEndsInd > 0 then // there are some LineEnds, add four corner points
  begin
    LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              $02, AClipFRect, FPoint( AClipFRect.Left, AClipFRect.Top ) );
    LineEnds[LineEndsInd].Flags := $100;
    Inc(LineEndsInd);
    LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              $02, AClipFRect, FPoint( AClipFRect.Right, AClipFRect.Top ) );
    LineEnds[LineEndsInd].Flags := $200;
    Inc(LineEndsInd);
    LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              $04, AClipFRect, FPoint( AClipFRect.Right, AClipFRect.Bottom ) );
    LineEnds[LineEndsInd].Flags := $300;
    Inc(LineEndsInd);
    LineEnds[LineEndsInd].Distance := N_DistAlongRectBorder(
              $08, AClipFRect, FPoint( AClipFRect.Left, AClipFRect.Bottom ) );
    LineEnds[LineEndsInd].Flags := $400;
    Inc(LineEndsInd);
  end;

//**** prev code is N_ClipDLine( ClipDRect, LineEnds, InpRing, ClipedLines );

  //***** Here: OLI - number of lines in N_WrkClipedDLines

  if OLI = 0 then
  with AClipFRect do // no ring border inside AClipFRect
  begin
    if 0 = N_DPointInsideDRing( SavedAPInpDPoints, ANPoints, AClipFRect,
                       DPoint( (Left+Right)/2, (Top+Bottom)/2 ) ) then
    begin // whole AClipFRect is inside InpRing
      Result := 1;
      AOutLengths[0] := 5;
      N_MakeFRectBorder( AOutDRings[0], AClipFRect );
    end else // whole AClipFRect is outside InpRing
    begin
      Result := 0;
    end;
    Exit;
  end;

  NEnds := LineEndsInd;
  ComparePar := 0;
  if AInpRingDirection <> 0 then ComparePar := N_SortOrder;

  if NEnds > 0 then
    N_SortElements( TN_BytesPtr(@LineEnds[0]), NEnds, sizeof(LineEnds[0]),
                                            ComparePar, N_CompareDoubles );

  SetLength( LI, OLI );

  for i := 0 to High(LI) do // set "End vertex of line is inside" flag
    LI[i] := -2;            // to all LI elements (initialization)

  for i := 0 to NEnds-1 do // loop along LineEnds and fill LI array
  begin
    LE := LineEnds[i];
    if ( LE.Flags and $F00) <> 0 then Continue; // corner of cliped rect
    if ( LE.Flags and $0F0) = $020 then // End of Line EndLine
      LI[LE.LineInd] := i;
  end; // for i := 0 to High(LineEnds) do // fill LI array

  if Length(AOutDRings) < OLI then
  begin
    SetLength( AOutDRings, OLI ); // max possible value
    SetLength( AOutLengths, OLI ); // max possible value
  end;

  AOutDRingsCount := 0;
  RingSize := 0;

  for i := 0 to High(LI) do // assemble Clipped Lines in AOutDRings
  begin
    if LI[i] = -10 then Continue; // i-th ClipedLine was already assembled
    if Length(N_WrkClipedDLines[i]) = 0 then Continue; // skip empty N_WrkClipedDLines

    //*** add other N_WrkClipedDLines to current ring (untill it was closed)

    CurLineInd := i;
    while True do // assemble all ring's lines
    begin
      //***** Add next (current) line coordinates to current ring

      AddSize := N_WrkClipedLengths[CurLineInd];
      if AddSize > 0 then
      begin
        if Length(AOutDRings[AOutDRingsCount]) < RingSize+AddSize then
          SetLength( AOutDRings[AOutDRingsCount], N_NewLength(RingSize+AddSize) );
        move( N_WrkClipedDLines[CurLineInd, 0], AOutDRings[AOutDRingsCount, RingSize],
                                                    AddSize*Sizeof(TDPoint) );
        Inc( RingSize, AddSize );
      end;

      if ( CurLineInd = i ) and // first line in Ring
         ( N_WrkClipedDLines[i,0].X = N_WrkClipedDLines[i,RingSize-1].X ) and
         ( N_WrkClipedDLines[i,0].Y = N_WrkClipedDLines[i,RingSize-1].Y )   then
        Break; // whole ring consists on one current line and is already OK

      LEPInd := LI[CurLineInd] + 1; // Next Line LEP index
      if LEPInd >= NEnds then LEPInd := 0;
      LI[CurLineInd] := -10;      // set "line was already assembled" flag

      if LEPInd = -9 then // no next line, previous line was last ring's line
      begin               // with it's End Vertex stricly inside ClipDRect,
        Break;            // go to next ring (if any)
      end;

      if (LEPInd = -1) then  // line has no EndPoint in LineEnds (is finished inside)
        Break; // ring is OK,  go to next ring (if any)

      Assert( LEPInd >= 0, 'error1' );

      while (LineEnds[LEPInd].Flags and $F00) <> 0 do // add ClipDRect corners
      begin
        if Length(AOutDRings[AOutDRingsCount]) < RingSize+1 then
          SetLength( AOutDRings[AOutDRingsCount], N_NewLength(RingSize+1) );
        case (LineEnds[LEPInd].Flags and $F00) of
          $100: AOutDRings[AOutDRingsCount, RingSize] := DPoint(AClipFRect.TopLeft);
          $200: AOutDRings[AOutDRingsCount, RingSize] :=
                                      DPoint( AClipFRect.Right, AClipFRect.Top );
          $300: AOutDRings[AOutDRingsCount, RingSize] := DPoint(AClipFRect.BottomRight);
          $400: AOutDRings[AOutDRingsCount, RingSize] :=
                                    DPoint( AClipFRect.Left, AClipFRect.Bottom );
        end; // case (LineEnds[LEPInd].Flags and $F00) of

        Inc(RingSize);
        Inc(LEPInd);
        if LEPInd >= NEnds then LEPInd := 0;

      end; // while (LineEnds[EndLineInd].Flags and $F00) <> 0 do // skip corners

      CurLineInd := LineEnds[LEPInd].LineInd; // next ring's Line index

      if CurLineInd = i then // previous line was last one,
      begin                  // just add one point and ring is OK
        if Length(AOutDRings[AOutDRingsCount]) < RingSize+1 then
          SetLength( AOutDRings[AOutDRingsCount], N_NewLength(RingSize+1) );
        AOutDRings[AOutDRingsCount, RingSize] := N_WrkClipedDLines[i, 0];
        Inc(RingSize);
        Break; // go to first line of next ring (if any)
      end;

    end; // while True do // loop along all "conected" lines

    AOutLengths[AOutDRingsCount] := RingSize;
    Inc(AOutDRingsCount); // inc number of prepared (finished) rings
    RingSize := 0;
  end; // for i := 0 to High(LI) do // assemble Clipped Lines in AOutDRings

  if RingSize > 0 then Inc(AOutDRingsCount);
  Result := AOutDRingsCount;
end; // end of function N_ClipRingByRect(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ClipRing
//************************************************************** N_ClipRing ***
// Clip Double Ring by given Clipping Float Rectangle
//
//     Parameters
// AClipFRect        - clipping Float Rectangle
// AInpRingDirection - =0 or =1 according to N_CalcRingDirection routine
// AInpDRing         - given Ring as Double Points array
// AREnvRect         - ?????
// AOutDRings        - array of resulting Rings (each resulting Ring as Double 
//                     Points array)
//
// Ring is closed Polyline. After clipping Ring as Line, Line Ends (which are on
// AClipFRect borders) are coonected by increasing distance along AClipFRect 
// borders if AInpRingDirection=0 or by decreasing distance if 
// AInpRingDirection=1.
//
procedure N_ClipRing( const ClipDRect: TFRect; InpRingDirection: integer;
                      const InpRing: TN_DPArray; const REnvRect: TFRect;
                                                   var OutRings: TN_ADPArray );
var
  i, NPoints, NEnds, LEPInd: integer;
  AddSize, CurLineInd, OutRingsCount, RingSize, ComparePar: integer;
  LineEnds: TN_LEPArray;
  LE: TN_LineEndPos;
  LI: TN_IArray; // -10 - processed, -1 - closed,inside, >=0 - index in LineEnds
  ClipedLines: TN_ADPArray;
begin
  NPoints := Length( InpRing );
  if (N_RectCheckPos( ClipDRect, REnvRect) and $0F) = $0F then
  begin
    SetLength( OutRings, 1 );
    SetLength( OutRings[0], NPoints );
    OutRings[0] := Copy( InpRing, 0, NPoints );
    Exit;
  end;

  SetLength( LineEnds, Max( 2010, 2*NPoints + 10 ) );

  N_ClipDLine( ClipDRect, LineEnds, InpRing, ClipedLines );

  if (Length(ClipedLines) = 0) or
     ((Length(ClipedLines) = 1) and (Length(ClipedLines[0]) = 0)) then
    with ClipDRect do // no ring border inside ClipDRect
    begin
      if 0 = N_DPointInsideDRing( PDPoint(@InpRing[0]), NPoints, ClipDRect,
                         DPoint( (Left+Right)/2, (Top+Bottom)/2 ) ) then
      begin // whole ClipDRect is inside InpRing
        SetLength( OutRings, 1 );
        N_MakeFRectBorder( OutRings[0], ClipDRect );
      end else // whole ClipDRect is outside InpRing
      begin
        SetLength( OutRings, 0 );
      end;
      Exit;
    end;

  NEnds := Length( LineEnds );
  ComparePar := 0;
  if InpRingDirection <> 0 then ComparePar := N_SortOrder;
  if NEnds > 0 then
    N_SortElements( TN_BytesPtr(@LineEnds[0]), NEnds, sizeof(LineEnds[0]),
                                            ComparePar, N_CompareDoubles );

  SetLength( LI, Length(ClipedLines) );

  for i := 0 to High(ClipedLines) do // set "End vertex of line is inside" flag
    LI[i] := -2;                     // to all LI elements (initialization)

  for i := 0 to High(LineEnds) do // fill LI array
  begin
    LE := LineEnds[i];
    if ( LE.Flags and $F00) <> 0 then Continue; // corner of cliped rect
    if ( LE.Flags and $0F0) = $020 then // End of Line EndLine
      LI[LE.LineInd] := i;
  end; // for i := 0 to High(LineEnds) do // fill LI array

  SetLength( OutRings, Length(ClipedLines) ); // max possible value
  OutRingsCount := 0;
  RingSize := 0;

  for i := 0 to High(LI) do // assemble Clipped Lines in OutRings
  begin
    if LI[i] = -10 then Continue; // i-th ClipedLine was already assembled
    if Length(ClipedLines[i]) = 0 then Continue; // skip empty ClipedLines

    //*** add other ClipedLines to current ring (untill it was closed)

    CurLineInd := i;
    while True do // assemble all ring's lines
    begin
      //***** Add next (current) line coordinates to current ring

      AddSize := Length(ClipedLines[CurLineInd]);
      if AddSize > 0 then
      begin
        SetLength( OutRings[OutRingsCount], RingSize+AddSize );
        move( ClipedLines[CurLineInd, 0], OutRings[OutRingsCount, RingSize],
                                                    AddSize*Sizeof(TDPoint) );
        Inc( RingSize, AddSize );
      end;

      if ( CurLineInd = i ) and // first line in Ring
         ( ClipedLines[i,0].X = ClipedLines[i,RingSize-1].X ) and
         ( ClipedLines[i,0].Y = ClipedLines[i,RingSize-1].Y )   then
        Break; // whole ring consists on one current line and is already OK

      LEPInd := LI[CurLineInd] + 1; // Next Line LEP index
      if LEPInd > High(LineEnds) then LEPInd := 0;
      LI[CurLineInd] := -10;      // set "line was already assembled" flag

      if LEPInd = -9 then // no next line, previous line was last ring's line
      begin               // with it's End Vertex stricly inside ClipDRect,
        Break;            // go to next ring (if any)
      end;

      if (LEPInd = -1) then  // line has no EndPoint in LineEnds (is finished inside)
        Break; // ring is OK,  go to next ring (if any)

      Assert( LEPInd >= 0, 'error1' );

      while (LineEnds[LEPInd].Flags and $F00) <> 0 do // add ClipDRect corners
      begin
        SetLength( OutRings[OutRingsCount], RingSize+1 );
        case (LineEnds[LEPInd].Flags and $F00) of
          $100: OutRings[OutRingsCount, RingSize] := DPoint(ClipDRect.TopLeft);
          $200: OutRings[OutRingsCount, RingSize] :=
                                      DPoint( ClipDRect.Right, ClipDRect.Top );
          $300: OutRings[OutRingsCount, RingSize] := DPoint(ClipDRect.BottomRight);
          $400: OutRings[OutRingsCount, RingSize] :=
                                    DPoint( ClipDRect.Left, ClipDRect.Bottom );
        end; // case (LineEnds[LEPInd].Flags and $F00) of

        Inc(RingSize);
        Inc(LEPInd);
        if LEPInd > High(LineEnds) then LEPInd := 0;

      end; // while (LineEnds[EndLineInd].Flags and $F00) <> 0 do // skip corners

      CurLineInd := LineEnds[LEPInd].LineInd; // next ring's Line index

      if CurLineInd = i then // previous line was last one,
      begin                  // just add one point and ring is OK
        SetLength( OutRings[OutRingsCount], RingSize+1 );
        OutRings[OutRingsCount, RingSize] := ClipedLines[i, 0];
        Break; // go to first line of next ring (if any)
      end;

    end; // while True do // loop along all "conected" lines

    Inc(OutRingsCount); // inc number of prepared (finished) rings
    RingSize := 0;
  end; // for i := 0 to High(LI) do // assemble Clipped Lines in OutRings

  SetLength( OutRings, OutRingsCount );
  ClipedLines := nil;
end; // end of procedure N_ClipRing

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcRingSquare
//******************************************************** N_CalcRingSquare ***
// Calculate signed square of Double Ring
//
//     Parameters
// ARCoords - Ring (double) coordinates (last point is same as first one)
// Result   - Returns signed square of Double Ring.
//
// Resulting square is positive if:
//#F
//   in RIGHT coordinates System (both conditions are equivalent):
//     - Ring vertexes are ordered counter clockwise
//     - Ring's internal area is to the left of border segments
//   in LEFT coordinates System (both conditions are equivalent):
//     - Ring vertexes are ordered clockwise
//     - Ring's internal area is to the right of border segments
//#/F
//
function N_CalcRingSquare( ARCoords: TN_DPArray ): double;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to High(ARCoords)-1 do //
  begin
    Result := Result + ( ARCoords[i].X*ARCoords[i+1].Y -
                         ARCoords[i].Y*ARCoords[i+1].X );
  end; //
  Result := 0.5*Result;
end; // end of function N_CalcRingSquare

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcRingDirection
//***************************************************** N_CalcRingDirection ***
// Get given Double Ring direction
//
//     Parameters
// ARCoords - Ring (double) coordinates (last point is same as first one)
// Result   - Returns 0 if:
//#F
//   in RIGHT coordinates System (both conditions are equivalent):
//     - Ring vertexes are ordered counter clockwise
//     - Ring's internal area is to the left of border segments
//   in LEFT coordinates System (both conditions are equivalent):
//     - Ring vertexes are ordered clockwise
//     - Ring's internal area is to the right of border segments
//#/F
//  Else resulting value equals 1.
//
// Ring direction is used as parameter of Clip Ring by Rectangle routines.
//
function N_CalcRingDirection( ARCoords: TN_DPArray ): integer;
begin
  if N_CalcRingSquare( ARCoords ) > 0 then Result := 0
                                     else Result := 1;
end; // end of procedure N_CalcRingDirection

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IPointToStr
//*********************************************************** N_IPointToStr ***
// Convert given Integer Point to text using format string
//
//     Parameters
// APoint - source Integer Point
// AFmt   - convertion format string
// Result - Returns string with converted APoint value
//
function N_IPointToStr( const APoint: TPoint; AFmt: string ): String;
begin
  if APoint.X = N_NotAnInteger then
    Result := 'NoValue'
  else with APoint do
  begin
    if AFmt = '' then AFmt := '%.d %.d';
    Result := Format( AFmt, [X, Y] );
  end;
end; // end of function N_IPointToStr

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_TControlToStr
//********************************************************* N_TControlToStr ***
// Convert coords and state of given AControl to string (for dumping)
//
//     Parameters
// AControl - given TControl Object
// Result   - Returns string with AControl attributes
//
function N_TControlToStr( const AControl: TControl ): String;
begin
  with AControl do
    Result := Format( 'TControl LTWH: %.d,%.d, %.d,%.d', [Left,Top,Width,Height] );
end; // end of function N_TControlToStr

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FRectAnd
//************************************************************** N_FRectAnd ***
// Calculate two FLoat Rectangles cross-section
//
//     Parameters
// AFRectRes - FLoat Rectangle - first operand and resulting Rectangle
// AFRectOp  - FLoat Rectangle - second operand
// Result    - Returns integer value:
//#F
//  =0 - cross-section is empty
//  =1 - cross-section is NOT empty and RectRes is NOT inside RectOp
//  =2 - cross-section is NOT empty and RectRes is stricly inside RectOp
//#/F
//
// All rectangles should be ordered.
//
function N_FRectAnd( var AFRectRes: TFRect; const AFRectOp: TFRect ): integer;
begin
  Result := 2; // preliminary value

  if( AFRectRes.Left < AFRectOp.Left ) then // check Left
  begin
    Result := 1;
    AFRectRes.Left := AFRectOp.Left;
  end;

  if( AFRectRes.Top < AFRectOp.Top ) then // check Top
  begin
    Result := 1;
    AFRectRes.Top := AFRectOp.Top;
  end;

  if( AFRectRes.Right > AFRectOp.Right ) then // check Right
  begin
    Result := 1;
    AFRectRes.Right := AFRectOp.Right;
  end;

  if( AFRectRes.Bottom > AFRectOp.Bottom ) then // check Bottom
  begin
    Result := 1;
    AFRectRes.Bottom := AFRectOp.Bottom;
  end;

  if (AFRectRes.Left + Abs(AFRectRes.Left*N_Eps) > AFRectRes.Right) or  // IF Left > Right OR
     (AFRectRes.Top + Abs(AFRectRes.Top*N_Eps) > AFRectRes.Bottom) then //    Top  > Bottom
    Result := 0;                          // --> crossection is empty
end; // end of function N_FRectAnd

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FRectOr(FRect)
//******************************************************** N_FRectOr(FRect) ***
// Calculate two Float Rectangles envelope Rectangle
//
//     Parameters
// AFRectRes - Float Rectangle - first operand and resulting Rectangle
// AFRectOp  - Float Rectangle - second operand
// Result    - Returns integer value:
//#F
//  =0 - AFRectRes remains the same (AFRectOp is inside AFRectRes)
//  =1 - AFRectRes changed
//#/F
//
// All rectangles should be ordered.
//
function N_FRectOr( var AFRectRes: TFRect; const AFRectOp: TFRect ): integer;
begin
  Result := 0; // preliminary value

  if AFRectRes.Left = N_NotAFloat then // RectRes not initialized
  begin
    AFRectRes := AFRectOp;
    Result := 1;
    Exit;
  end;

  if AFRectOp.Left = N_NotAFloat then // RectOp not initialized
  begin
    Result := 0;
    Exit;
  end;

  if( AFRectRes.Left > AFRectOp.Left ) then // check Left
  begin
    Result := 1;
    AFRectRes.Left := AFRectOp.Left;
  end;

  if( AFRectRes.Top > AFRectOp.Top ) then // check Top
  begin
    Result := 1;
    AFRectRes.Top := AFRectOp.Top;
  end;

  if( AFRectRes.Right < AFRectOp.Right ) then // check Right
  begin
    Result := 1;
    AFRectRes.Right := AFRectOp.Right;
  end;

  if( AFRectRes.Bottom < AFRectOp.Bottom ) then // check Bottom
  begin
    Result := 1;
    AFRectRes.Bottom := AFRectOp.Bottom;
  end;
end; // end of function N_FRectOr(FRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FRectOr(DPoint)
//******************************************************* N_FRectOr(DPoint) ***
// Calculate Float Rectangle and Double Point envelope Rectangle
//
//     Parameters
// AFRectRes - source Float Rectangle - first operand and resulting Rectangle
// ADPoint   - source Double Point
// Result    - Returns integer value:
//#F
//  =0 - AFRectRes remains the same (ADPoint is inside AFRectRes)
//  =1 - AFRectRes changed
//#/F
//
function N_FRectOr( var AFRectRes: TFRect; const ADPoint: TDPoint ): integer;
begin
  Result := 0; // preliminary value

  if AFRectRes.Left = N_NotAFloat then // RectRes not initialized
  begin
    AFRectRes.Left   := ADPoint.X;
    AFRectRes.Top    := ADPoint.Y;
    AFRectRes.Right  := ADPoint.X;
    AFRectRes.Bottom := ADPoint.Y;
    Result := 1;
    Exit;
  end;

  if( AFRectRes.Left > ADPoint.X ) then // check Left
  begin
    Result := 1;
    AFRectRes.Left := ADPoint.X;
  end;

  if( AFRectRes.Top > ADPoint.Y ) then // check Top
  begin
    Result := 1;
    AFRectRes.Top := ADPoint.Y;
  end;

  if( AFRectRes.Right < ADPoint.X ) then // check Right
  begin
    Result := 1;
    AFRectRes.Right := ADPoint.X;
  end;

  if( AFRectRes.Bottom < ADPoint.Y ) then // check Bottom
  begin
    Result := 1;
    AFRectRes.Bottom := ADPoint.Y;
  end;
end; // end of function N_FRectOr(DPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FRectsCross
//*********************************************************** N_FRectsCross ***
// Check intersection of two Float Rectangles
//
//     Parameters
// AFRect1 - Float Rectangle - first operand and resulting Rectangle
// AFRect2 - Float Rectangle - second operand
// Result  - Returns TRUE if intersection of two given Rectangles is not empty.
//
function N_FRectsCross( const AFRect1, AFRect2: TFRect ): boolean;
begin
  Result := True;
  if (AFRect1.Right  < AFRect2.Left)   or
     (AFRect1.Bottom < AFRect2.Top)    or
     (AFRect1.Left   > AFRect2.Right)  or
     (AFRect1.Top    > AFRect2.Bottom)   then Result := False; // do not cross
end; // end of function N_FRectsCross

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FRectIAffConv2
//******************************************************** N_FRectIAffConv2 ***
// Convert given Integer Rectangle to Float Rectangle by Affine Transformation 
// Coefficients defined as some Source Float Rectangle and Destination Integer 
// Rectangle
//
//     Parameters
// AAffDstFRect - Affine Transformation Destination Float Rectangle
// AAffSrcIRect - Affine Transformation Source Integer Rectangle
// ASrcIRect    - Source Integer Rectangle
// Result       - Returns Float Rectangle converted from ASrcIRect
//
function N_FRectIAffConv2( const FRectOp: TFRect;
                                  const IRectOp1, IRectOp2: TRect ): TFRect;
var
  AffCoefs: TN_AffCoefs4;
begin
  AffCoefs := N_CalcAffCoefs4( N_I2FRect1( IRectOp1 ), FRectOp );
  Result := N_AffConvI2FRect1( IRectOp2, AffCoefs );
end; // end of function N_FRectIAffConv2

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FRectFAffConv2
//******************************************************** N_FRectFAffConv2 ***
// Convert given Float Rectangle to Float Rectangle by Affine Transformation 
// Coefficients defined as some Source Float Rectangle and Destination Float 
// Rectangle
//
//     Parameters
// AAffDstFRect - Affine Transformation Destination Float Rectangle
// AAffSrcFRect - Affine Transformation Source Float Rectangle
// ASrcFRect    - Source Float Rectangle
// Result       - Returns Float Rectangle converted from ASrcFRect
//
function N_FRectFAffConv2( const AAffDstFRect: TFRect;
                                  const AAffSrcFRect, ASrcFRect: TFRect ): TFRect;
var
  AffCoefs: TN_AffCoefs4;
begin
  AffCoefs := N_CalcAffCoefs4( AAffSrcFRect, AAffDstFRect );
  Result := N_AffConvF2FRect( ASrcFRect, AffCoefs );
end; // end of function N_FRectFAffConv2

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FRectOrder
//************************************************************ N_FRectOrder ***
// Get Float Rectangle with ordered coordinates from given Float Rectangle
//
//     Parameters
// AFRect - source Float Rectangle
// Result - Returns Float Rectangle with ordered coordinates
//
function N_FRectOrder( const AFRect: TFRect ): TFRect;
begin
  Result := AFRect;
  if AFRect.Left > AFRect.Right then
  begin
    Result.Left  := AFRect.Right;
    Result.Right := AFRect.Left;
  end;
  if AFRect.Top > AFRect.Bottom then
  begin
    Result.Top    := AFRect.Bottom;
    Result.Bottom := AFRect.Top;
  end;
end; // end of function N_FRectOrder

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FRectCreate
//*********************************************************** N_FRectCreate ***
// Create new Float Rectangle by given Float Rectangle, new Rectangle Sizes and 
// HotPoint normalized coordinates ((0,0) means UpperLeft Corner, (1,1) - 
// LowerRight Corner, both rectangles would have same hotpoint)
//
//     Parameters
// ARect     - source Float Rectangle
// ANewSize  - new rectangle X, Y Size
// AHotPoint - HotPoint normalized coordinates ( (0,0)-UpperLeft Corner, 
//             (1,1)-LowerRight )
// Result    - Returns Float Rectangle with given sizes and position.
//
function N_FRectCreate( const ARect: TFRect;
                        const ANewSize, AHotPoint: TDPoint ): TFRect;
begin
  Result.Right := ARect.Right  - AHotPoint.X*( ARect.Right - ARect.Left - ANewSize.X );
  Result.Left  := Result.Right - ANewSize.X;

  Result.Bottom := ARect.Bottom  - AHotPoint.Y*( ARect.Bottom - ARect.Top - ANewSize.Y );
  Result.Top    := Result.Bottom - ANewSize.Y;
end; // end of function N_FRectCreate

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FRectSize
//************************************************************* N_FRectSize ***
// Get given Float Rectangle maximal dimension
//
//     Parameters
// AFRect - source Float Rectangle
// Result - Returns maximum of AFRect.Width and AFRect.Height
//
function N_FRectSize( const AFRect: TFRect ): double;
var
  Ysize: double;
begin
  Result := N_RectWidth( AFRect );
  Ysize  := N_RectHeight( AFRect );
  if Result < Ysize then Result := Ysize;
end; // end of function N_FRectSize

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DRectOrder
//************************************************************ N_DRectOrder ***
// Get Double Rectangle with ordered coordinates from given Double Rectangle
//
//     Parameters
// ADRect - source Float Rectangle
// Result - Returns Double Rectangle with ordered coordinates
//
function N_DRectOrder( const ADRect: TDRect ): TDRect;
begin
  Result := ADRect;
  if ADRect.Left > ADRect.Right then
  begin
    Result.Left  := ADRect.Right;
    Result.Right := ADRect.Left;
  end;
  if AdRect.Top > ADRect.Bottom then
  begin
    Result.Top    := ADRect.Bottom;
    Result.Bottom := ADRect.Top;
  end;
end; // end of function N_DRectOrder

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DRectOr(DRect)
//******************************************************** N_DRectOr(DRect) ***
// Calculate two Double Rectangles envelope Rectangle
//
//     Parameters
// ADRectRes - Double Rectangle - first operand and resulting Rectangle
// ADRectOp  - Double Rectangle - second operand
// Result    - Returns integer value:
//#F
//  =0 - ADRectRes remains the same (ADRectOp is inside ADRectRes)
//  =1 - ADRectRes changed
//#/F
//
// All rectangles should be ordered.
//
function N_DRectOr( var ADRectRes: TDRect; const ADRectOp: TDRect ): integer;
begin
  Result := 0; // preliminary value

  if ADRectRes.Left = N_NotADouble then // RectRes not initialized
  begin
    ADRectRes := ADRectOp;
    Result := 1;
    Exit;
  end;

  if ADRectOp.Left = N_NotADouble then // RectOp not initialized
  begin
    Result := 0;
    Exit;
  end;

  if( ADRectRes.Left > ADRectOp.Left ) then // check Left
  begin
    Result := 1;
    ADRectRes.Left := ADRectOp.Left;
  end;

  if( ADRectRes.Top > ADRectOp.Top ) then // check Top
  begin
    Result := 1;
    ADRectRes.Top := ADRectOp.Top;
  end;

  if( ADRectRes.Right < ADRectOp.Right ) then // check Right
  begin
    Result := 1;
    ADRectRes.Right := ADRectOp.Right;
  end;

  if( ADRectRes.Bottom < ADRectOp.Bottom ) then // check Bottom
  begin
    Result := 1;
    ADRectRes.Bottom := ADRectOp.Bottom;
  end;
end; // end of function N_DRectOr(DRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScanIPoint
//************************************************************ N_ScanIPoint ***
// Read Integer Point Coordinates
//
//     Parameters
// AStr   - input string, used part of the string is removed
// Result - Returns Integer Point
//
// Trim left spaces and chars with read data
//
function N_ScanIPoint( var AStr: String ): TPoint;
begin
  Result.X := N_ScanInteger( AStr );
  Result.Y := N_ScanInteger( AStr );
end; // end of function N_ScanIPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScanFPoint
//************************************************************ N_ScanFPoint ***
// Read Float Point Coordinates
//
//     Parameters
// AStr   - input string, used part of the string is removed
// Result - Returns Float Point
//
// Trim left spaces and chars with read data
//
function N_ScanFPoint( var AStr: String ): TFPoint;
begin
  Result.X := N_ScanFloat( AStr );
  Result.Y := N_ScanFloat( AStr );
end; // end of function N_ScanFPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScanDPoint
//************************************************************ N_ScanDPoint ***
// Read Double Point Coordinates
//
//     Parameters
// AStr   - input string, used part of the string is removed
// Result - Returns Double Point
//
// Trim left spaces and chars with read data
//
function N_ScanDPoint( var AStr: String ): TDPoint;
begin
  Result.X := N_ScanDouble( AStr );
  Result.Y := N_ScanDouble( AStr );
end; // end of function N_ScanDPoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScanIRect
//************************************************************* N_ScanIRect ***
// Read Integer Rectangle Coordinates
//
//     Parameters
// AStr   - input string, used part of the string is removed
// Result - Returns Integer Rectangle
//
// Trim left spaces and chars with read data
//
function N_ScanIRect( var AStr: String ): TRect;
begin
  Result.TopLeft     := N_ScanIPoint( AStr );
  Result.BottomRight := N_ScanIPoint( AStr );
end; // end of function N_ScanIRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScanFRect
//************************************************************* N_ScanFRect ***
// Read Float Rectangle Coordinates
//
//     Parameters
// AStr   - input string, used part of the string is removed
// Result - Returns Float Rectangle
//
// Trim left spaces and chars with read data
//
function N_ScanFRect( var AStr: String ): TFRect;
begin
  if AStr = 'NoValue' then
    Result := FRect( N_NotAFloat, 0, 0, 0)
  else
  begin
    Result.TopLeft     := N_ScanFPoint( AStr );
    Result.BottomRight := N_ScanFPoint( AStr );
  end;
end; // end of function N_ScanFRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScanDRect
//************************************************************* N_ScanDRect ***
// Read Double Rectangle Coordinates
//
//     Parameters
// AStr   - input string, used part of the string is removed
// Result - Returns Double Rectangle
//
// Trim left spaces and chars with read data
//
function N_ScanDRect( var AStr: String ): TDRect;
begin
  if AStr = 'NoValue' then
    Result := DRect( N_NotADouble, 0, 0, 0)
  else
  begin
    Result.TopLeft     := N_ScanDPoint( AStr );
    Result.BottomRight := N_ScanDPoint( AStr );
  end;
end; // end of function N_ScanDRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScanAffCoefs6
//********************************************************* N_ScanAffCoefs6 ***
// Read Six Affine Transformation Coefficients
//
//     Parameters
// AStr   - input string, used part of the string is removed
// Result - Returns Six Affine Transformation Coefficients
//
// Trim left spaces and chars with read data. Result.CXX = N_NotADouble if some 
// errors are detected.
//
function N_ScanAffCoefs6( var AStr: String ): TN_AffCoefs6;
begin
  with Result do
  begin

    CXX := N_ScanDouble( AStr );
    CXY := N_ScanDouble( AStr );
    SX  := N_ScanDouble( AStr );

    CYX := N_ScanDouble( AStr );
    CYY := N_ScanDouble( AStr );
    SY  := N_ScanDouble( AStr );

    if SY = N_NotADouble then // less then 6 numbers in AStr
      CXX := N_NotADouble;

  end; // with Result do
end; // end of function N_ScanAffCoefs6

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScanIntPairs
//********************************************************** N_ScanIntPairs ***
// Read array of Pairs of integer numbers
//
//     Parameters
// AStr      - input string
// AIntPairs - resulting (scanned) pairs of integers
// Result    - Return number of scanned pairs
//
// If integer is terminated by ^ or _ symbols it is first number in Pair, 
// followed by the second number. Otherwise it is both first and second numbers 
// in Pair
//
// 1 3^5 7 - three pairs AIntPairs=(1,1,3,5,7,7), Result = 3
//
function N_ScanIntPairs( var AStr: String; var APairs: TN_IArray ): integer;
var
  i, CurInt, SecInt: integer;

  procedure AddPair( AFirst, ASecond: integer ); // local
  // Add two given numbers to AIntPairs
  begin
    if High(APairs) <= i then
      SetLength( APairs, N_NewLength(i+2) );

    APairs[i] := AFirst;  Inc( i );
    APairs[i] := ASecond; Inc( i );
  end; // procedure AddPair - local

begin
  i := 0;

  while True do // along all numbers in AStr
  begin
    CurInt := N_ScanInteger( AStr );

    if CurInt = N_NotAnInteger then // all pairs are scanned
    begin
      Result := i div 2;
      if Length( APairs ) = 0 then SetLength( APairs, 2 ); // to be able to use @APairs[0] 
      Exit;
    end else if Length(AStr) > 0 then // first AStr symbol can be checked
    begin
      if AStr[1] = ' ' then Astr := TrimLeft( AStr ); // skip leading spaces
      if AStr[1] = '-' then // get Second number in Pair
      begin
        AStr[1] := ' ';
        SecInt := N_ScanInteger( AStr );
        AddPair( CurInt, SecInt );
      end else // add Pair
      begin
        AddPair( CurInt, CurInt );
      end;
    end else // CurInt is last number in AStr
    begin
      AddPair( CurInt, CurInt );
      Result := i div 2;
      Exit;
    end;

  end; // while True do // along all numbers in AStr
end; // end of function N_ScanIntPairs

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IsIntInRange
//********************************************************** N_IsIntInRange ***
// Check if given Integer is inside one of given Ranges
//
//     Parameters
// AInt       - given Integer to check,
// ANumRanges - given number of ranges
// ARanges    - given Ranges (pairs of first and last integer in a range)
// Result     - Returns True if given AInt is inside one of given Ranges
//
function N_IsIntInRange( AInt, ANumRanges: integer; ARanges: TN_IArray ): boolean;
var
  i: integer;
begin
  for i := 0 to ANumRanges-1 do // along all Ranges
  begin
    if (AInt >= ARanges[2*i]) and (AInt <= ARanges[2*i+1]) then // is inside
    begin
      Result := True;
      Exit;
    end;
  end; // for i := 0 to ANumRanges-1 do // along all Ranges

  Result := False; // out of all given Ranges
end; // end of function N_IsIntInRange

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SameIPoints
//*********************************************************** N_SameIPoints ***
// Compare two given Integer Points
//
//     Parameters
// APoint1 - first Integer Point
// APoint2 - second Integer Point
// Result  - Returns TRUE if given Points have same coordinates
//
function N_SameIPoints( const APoint1, APoint2: TPoint ): boolean;
begin
  Result := (APoint1.X = APoint2.X) and (APoint1.Y = APoint2.Y);
end; // end of function N_SameIPoints

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SameIRects
//************************************************************ N_SameIRects ***
// Compare two given Integer Rectangles
//
//     Parameters
// ARect1 - first Integer Rectangle
// ARect2 - second Integer Rectangle
// Result - Returns TRUE if given Rectangles have same coordinates
//
function N_SameIRects( const ARect1, ARect2: TRect ): boolean;
begin
  Result := N_SameIPoints( ARect1.TopLeft, ARect2.TopLeft ) and
            N_SameIPoints( ARect1.BottomRight, ARect2.BottomRight );
end; // end of function N_SameIRects

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SameDPoints
//*********************************************************** N_SameDPoints ***
// Compare two given Double Points with given accuracy
//
//     Parameters
// ADPoint1  - first Double Point
// ADPoint2  - second Double Point
// AAccuracy - compare coordinates accuracy
// Result    - Returns TRUE if given Points have same coordinates with given 
//             accuracy
//
function N_SameDPoints( const ADPoint1, ADPoint2: TDPoint; const AAccuracy: integer ): boolean;
var
  Coef: double;
begin
  Coef := Power( 10.0, AAccuracy );
  Result := (Round(Coef*ADpoint1.X) = Round(Coef*ADpoint2.X)) and
            (Round(Coef*ADpoint1.X) = Round(Coef*ADpoint1.Y));
end; // end of function N_SameDPoints

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SameDRects
//************************************************************ N_SameDRects ***
// Compare two given Double Rectangles with given accuracy
//
//     Parameters
// ADRect1   - first Double Rectangle
// ADRect2   - second Double Rectangle
// AAccuracy - compare coordinates accuracy
// Result    - Returns TRUE if given Rectangles have same coordinates with given
//             accuracy
//
function N_SameDRects( const ADRect1, ADRect2: TDRect; const AAccuracy: integer ): boolean;
begin
  Result := N_SameDPoints( ADRect1.TopLeft, ADRect2.TopLeft, AAccuracy ) and
            N_SameDPoints( ADRect1.BottomRight, ADRect2.BottomRight, AAccuracy);
end; // end of function N_SameDRects

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SnapToGrid
//************************************************************ N_SnapToGrid ***
// Snap given float value to given Grid
//
//     Parameters
// AGridStep - float Grid Step
// AValue    - snapping float value
// Result    - Returns value snapped to given Grid
//
// Grid is given by it's step. Grid origin equals 0.
//
function N_SnapToGrid( const AGridStep, AValue: float ): float;
var
  NSteps: Int64;
begin
  Result := AValue;

  if AGridStep <> 0.0 then
  begin
    NSteps := Round( AValue / AGridStep );
    Result := NSteps*AGridStep;
  end;
end; //*** end of function N_SnapToGrid(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SnapPointToGrid(float)
//************************************************ N_SnapPointToGrid(float) ***
// Snap given Float Point to given Grid
//
//     Parameters
// AOrigin    - Grid Origin given as Double Point
// AGridSteps - Grid steps given as Double Point
// AFPoint    - snapping Float Point
// Result     - Returns Float Point snapped to given Grid
//
// Resulting Float Point is the same as Grid node, nearest to given Point.
//
function N_SnapPointToGrid( const AOrigin, AGridSteps: TDPoint; const AFPoint: TFPoint ): TFPoint;
var
  NSteps: Int64;
begin
  Result := AFPoint;

  if AGridSteps.X <> 0.0 then
  begin
    NSteps := Round( ( AFPoint.X - AOrigin.X ) / AGridSteps.X );
    Result.X := AOrigin.X + NSteps*AGridSteps.X;
  end;

  if AGridSteps.Y <> 0.0 then
  begin
    NSteps := Round( ( AFPoint.Y - AOrigin.Y ) / AGridSteps.Y );
    Result.Y := AOrigin.Y + NSteps*AGridSteps.Y;
  end;

end; //*** end of function N_SnapPointToGrid(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SnapPointToGrid(double)
//*********************************************** N_SnapPointToGrid(double) ***
// Snap given Double Point to given Grid
//
//     Parameters
// AOrigin    - Grid Origin given as Double Point
// AGridSteps - Grid steps given as Double Point
// ADPoint    - snapping Float Point
// Result     - Returns Double Point snapped to given Grid
//
// Resulting Double Point is the same as Grid node, nearest to given Point.
//
function N_SnapPointToGrid( const AOrigin, AGridSteps: TDPoint; const ADPoint: TDPoint ): TDPoint;
var
  NSteps: Int64;
begin
  Result := ADPoint;

  if AGridSteps.X <> 0.0 then
  begin
    NSteps := Round( ( ADPoint.X - AOrigin.X ) / AGridSteps.X );
    Result.X := AOrigin.X + NSteps*AGridSteps.X;
  end;

  if AGridSteps.Y <> 0.0 then
  begin
    NSteps := Round( ( ADPoint.Y - AOrigin.Y ) / AGridSteps.Y );
    Result.Y := AOrigin.Y + NSteps*AGridSteps.Y;
  end;

end; //*** end of function N_SnapPointToGrid(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SnapDLineToGrid
//******************************************************* N_SnapDLineToGrid ***
// Snap given Double Polyline to given Grid
//
//     Parameters
// AOrigin    - Grid Origin given as Double Point
// AGridSteps - Grid steps given as Double Point
// AInpDLine  - snapping Double Polyline given as Double Points array
// AOutDLine  - snapped Double Polyline in Double Points array
//
procedure N_SnapDLineToGrid( const AOrigin, AGridSteps: TDPoint;
                  const AInpDLine: TN_DPArray; var AOutDLine: TN_DPArray  );
var
  i, j, NSteps: integer;
begin
  SetLength( AOutDLine, Length(AInpDLine) ); // preliminary value
  j := 0;

  for i := 0 to High(AInpDLine) do
  begin
    if AGridSteps.X <> 0.0 then
    begin
      NSteps := Round( ( AInpDLine[i].X - AOrigin.X ) / AGridSteps.X );
      AOutDLine[j].X := AOrigin.X + NSteps*AGridSteps.X;
    end;

    if AGridSteps.Y <> 0.0 then
    begin
      NSteps := Round( ( AInpDLine[i].Y - AOrigin.Y ) / AGridSteps.Y );
      AOutDLine[j].Y := AOrigin.Y + NSteps*AGridSteps.Y;
    end;

    if j > 0 then
    begin
      if (AOutDLine[j-1].X <> AOutDLine[j].X) or
         (AOutDLine[j-1].Y <> AOutDLine[j].Y)   then Inc(j);
    end else
      Inc(j);
  end; // for i := 0 to High(DLine) do

  if j >= 2 then
    SetLength( AOutDLine, j )
  else
  begin
    AOutDLine[1] := AOutDLine[0];
    SetLength( AOutDLine, 2 )
  end;

end; //*** end of procedure N_SnapDLineToGrid

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CompareDPoints
//******************************************************** N_CompareDPoints ***
// Compare records with Double Points
//
//     Parameters
// AIParam - offset in bytes of Double Point field in given records
// APtr1   - pointer to first record with Double Point field
// APtr2   - pointer to second record with Double Point field
// Result  - Returns:
//#F
// =-1 if DPoint1.X < DPoint2.X  OR
//        DPoint1.Y < DPoint2.Y if DPoint1.X = DPoint2.X
//
// =0  if DPoint1.X = DPoint2.X  AND DPoint1.Y = DPoint2.Y
//
// =1  if DPoint1.X > DPoint2.X  OR
//        DPoint1.Y > DPoint2.Y if DPoint1.X = DPoint2.X
//#/F
//
// Function can be used in N_SortPointers procedure.
//
function N_CompareDPoints( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  X1, X2, Y1, Y2: double;
begin
  X1 := PDPoint(APtr1+AIParam)^.X;
  X2 := PDPoint(APtr2+AIParam)^.X;
  Result := 0; // if X1 = X2 and Y1 = Y2

  if      X1 < X2 then  begin Result := -1; Exit; end
  else if X1 > X2 then  begin Result := +1; Exit; end
  else // X1 = X2
  begin
    Y1 := PDPoint(APtr1+AIParam)^.Y;
    Y2 := PDPoint(APtr2+AIParam)^.Y;
    if      Y1 < Y2 then  begin Result := -1; Exit; end
    else if Y1 > Y2 then  begin Result := +1; Exit; end
  end;
  //***** Here:  X1 = X2 and Y1 = Y2,  Result = 0
end; // end of function N_CompareDPoints

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CompareIPoints
//******************************************************** N_CompareIPoints ***
// Compare records with Integer Points
//
//     Parameters
// AIParam - offset in bytes of Integer Point field in given records
// APtr1   - pointer to first record with Integer Point field
// APtr2   - pointer to second record with Integer Point field
// Result  - Returns:
//#F
// =-1 if IPoint1.X < IPoint2.X  OR
//        IPoint1.Y < IPoint2.Y if IPoint1.X = IPoint2.X
// =0  if IPoint1.X = IPoint2.X  AND IPoint1.Y = IPoint2.Y
//
// =1  if IPoint1.X > IPoint2.X  OR
//        IPoint1.Y > IPoint2.Y if IPoint1.X = IPoint2.X
//#/F
//
// Function can be used in N_SortPointers procedure.
//
function N_CompareIPoints( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  X1, X2, Y1, Y2: integer;
begin
  X1 := PPoint(APtr1+AIParam)^.X;
  X2 := PPoint(APtr2+AIParam)^.X;
  Result := 0; // if X1 = X2 and Y1 = Y2

  if      X1 < X2 then  begin Result := -1; Exit; end
  else if X1 > X2 then  begin Result := +1; Exit; end
  else // X1 = X2
  begin
    Y1 := PPoint(APtr1+AIParam)^.Y;
    Y2 := PPoint(APtr2+AIParam)^.Y;
    if      Y1 < Y2 then  begin Result := -1; Exit; end
    else if Y1 > Y2 then  begin Result := +1; Exit; end
  end;
  //***** Here:  X1 = X2 and Y1 = Y2,  Result = 0
end; // end of function N_CompareIPoints

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CompareDPointAndAngle
//************************************************* N_CompareDPointAndAngle ***
// Compare records with Double Points and Angle subsequent fields
//
//     Parameters
// AIParam - offset in bytes of Double Point field in given records
// APtr1   - pointer to first record with Double  Point field
// APtr2   - pointer to second record with Double  Point field
// Result  - Returns:
//#F
// =-1 if DPoint1.X < DPoint2.X                           OR
//        DPoint1.Y < DPoint2.Y if DPoint1.X = DPoint2.X  OR
//        Angle1 < Angle2 if DPoint1 = DPoint2
// =0  if DPoint1 = DPoint2  AND Angle1 = Angle2
//
// =1  if DPoint1.X > DPoint2.X                           OR
//        DPoint1.Y > DPoint2.Y if DPoint1.X = DPoint2.X  OR
//        Angle1 > Angle2 if DPoint1 = DPoint2
//#/F
//
// Function can be used in N_SortPointers procedure.
//
function N_CompareDPointAndAngle( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  X1, X2, Y1, Y2, Angle1, Angle2: double;
begin
  X1 := PDPoint(APtr1+AIParam)^.X;
  X2 := PDPoint(APtr2+AIParam)^.X;
  Result := 0; // if X1 = X2 and Y1 = Y2 and Angle1 = Angle2

  if      X1 < X2 then  begin Result := -1; Exit; end
  else if X1 > X2 then  begin Result := +1; Exit; end
  else // X1 = X2
  begin
    Y1 := PDPoint(APtr1+AIParam)^.Y;
    Y2 := PDPoint(APtr2+AIParam)^.Y;
    if      Y1 < Y2 then  begin Result := -1; Exit; end
    else if Y1 > Y2 then  begin Result := +1; Exit; end
    else // X1 = X2, Y1 = Y2
    begin
      Angle1 := PDouble(APtr1+AIParam+Sizeof(TDPoint))^;
      Angle2 := PDouble(APtr2+AIParam+Sizeof(TDPoint))^;
      if      Angle1 < Angle2 then  begin Result := -1; Exit; end
      else if Angle1 > Angle2 then  begin Result := +1; Exit; end
    end;
  end;
  //***** Here:  X1 = X2 and Y1 = Y2,  Result = 0
end; // end of function N_CompareDPointAndAngle

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CompareFPointAndInt
//*************************************************** N_CompareFPointAndInt ***
// Compare records with Float Points and Integer subsequent fields
//
//     Parameters
// AIParam - offset in bytes of Float Point field in given records
// APtr1   - pointer to first record with Float  Point field
// APtr2   - pointer to second record with Float  Point field
// Result  - Returns:
//#F
// =-1 if FPoint1.X < FPoint2.X                           OR
//        FPoint1.Y < FPoint2.Y if FPoint1.X = FPoint2.X  OR
//        Int1 < Int2 if FPoint1 = FPoint2
// =0  if FPoint1 = FPoint2  AND Int1 = Int2
//
// =1  if FPoint1.X > FPoint2.X                           OR
//        FPoint1.Y > FPoint2.Y if FPoint1.X = FPoint2.X  OR
//        Int1 > Int2 if FPoint1 = FPoint2
//#/F
//
// Function can be used in N_SortPointers procedure.
//
function N_CompareFPointAndInt( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  X1, X2, Y1, Y2: float;
  Int1, Int2: integer;
begin
  X1 := PFPoint(APtr1+AIParam)^.X;
  X2 := PFPoint(APtr2+AIParam)^.X;
  Result := 0; // as if X1 = X2 and Y1 = Y2 and Int1 = Int2

  if      X1 < X2 then  begin Result := -1; Exit; end
  else if X1 > X2 then  begin Result := +1; Exit; end
  else // X1 = X2
  begin
    Y1 := PFPoint(APtr1+AIParam)^.Y;
    Y2 := PFPoint(APtr2+AIParam)^.Y;
    if      Y1 < Y2 then  begin Result := -1; Exit; end
    else if Y1 > Y2 then  begin Result := +1; Exit; end
    else // X1 = X2, Y1 = Y2
    begin
      Int1 := PInteger(APtr1+AIParam+Sizeof(TFPoint))^;
      Int2 := PInteger(APtr2+AIParam+Sizeof(TFPoint))^;
      if      Int1 < Int2 then  begin Result := -1; Exit; end
      else if Int1 > Int2 then  begin Result := +1; Exit; end
    end;
  end;
  //***** Here:  X1 = X2 and Y1 = Y2,  Result = 0
end; // end of function N_CompareFPointAndInt

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CompareFRectAndInt
//**************************************************** N_CompareFRectAndInt ***
// Compare records with Float Rectangles and Integer subsequent fields
//
//     Parameters
// AIParam - offset in bytes of Float Rectangle field in given records
// APtr1   - pointer to first record with Float  Rectangle field
// APtr2   - pointer to second record with Float  Rectangle field
// Result  - Returns:
//#F
// =-1 if FRect1 < FRect2                           OR
//        Int1 < Int2 if FRect1 = FRect2
// =0  if FRect1 = FRect2  AND Int1 = Int2
//
// =1  if FRect1 > FRect2                           OR
//        Int1 > Int2 if FRect1 = FRect2
//#/F
//
// Function can be used in N_SortPointers procedure.
//
function N_CompareFRectAndInt( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  F1, F2: float;
  Int1, Int2: integer;
  PF1, PF2: PFloat;
begin
  PF1 := PFloat(APtr1+AIParam);
  PF2 := PFloat(APtr2+AIParam);

  F1 := PF1^;
  F2 := PF2^;
  Result := 0; // as if FRect1 = FRect2 and Int1 = Int2

  if      F1 < F2 then  begin Result := -1; Exit; end // check first float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc(PF1);  F1 := PF1^;
  Inc(PF2);  F2 := PF2^;

  if      F1 < F2 then  begin Result := -1; Exit; end // check second float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc(PF1);  F1 := PF1^;
  Inc(PF2);  F2 := PF2^;

  if      F1 < F2 then  begin Result := -1; Exit; end // check third float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc(PF1);  F1 := PF1^;
  Inc(PF2);  F2 := PF2^;

  if      F1 < F2 then  begin Result := -1; Exit; end // check fourth float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc(PF1);  Int1 := PInteger(PF1)^;
  Inc(PF2);  Int2 := PInteger(PF2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end // check last int
  else if Int1 > Int2 then  begin Result := +1; Exit; end;
  //***** Here:  Frect1 = FRect2, Int1 = Int2  Result = 0
end; // end of function N_CompareFRectAndInt

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Compare2PFP1Int
//******************************************************* N_Compare2PFP1Int ***
// Compare records with two pointers to Float Points and Integer subsequent 
// fields
//
//     Parameters
// AIParam - offset in bytes of first pointer to Float Point field in given 
//           records
// APtr1   - pointer to first record with pointers to Float Points
// APtr2   - pointer to second record with pointers to Float Points
// Result  - Returns:
//#F
// =-1 if Record1 < Record2
//
// =0  if Record1 = Record2
//
// =1  if Record1 > Record2
//#/F
//
// Function can be used in N_SortPointers procedure.
//
function N_Compare2PFP1Int( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  F1, F2: float;
  Int1, Int2: integer;
  PF1, PF2: PFloat;
  WPtr1, WPtr2: TN_BytesPtr;
begin
  WPtr1 := APtr1+AIParam;
  WPtr2 := APtr2+AIParam;

  PF1 := PFloat(Pointer(WPtr1)^);
  PF2 := PFloat(Pointer(WPtr2)^);

  F1 := PF1^;
  F2 := PF2^;
  Result := 0; // as if FRect1 = FRect2 and Int1 = Int2

  if      F1 < F2 then  begin Result := -1; Exit; end // check first float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc(PF1);  F1 := PF1^;
  Inc(PF2);  F2 := PF2^;

  if      F1 < F2 then  begin Result := -1; Exit; end // check second float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc( WPtr1, Sizeof(Pointer) );
  Inc( WPtr2, Sizeof(Pointer) );

  PF1 := PFloat(Pointer(WPtr1)^);
  PF2 := PFloat(Pointer(WPtr2)^);

  F1 := PF1^;
  F2 := PF2^;

  if      F1 < F2 then  begin Result := -1; Exit; end // check third float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc(PF1);  F1 := PF1^;
  Inc(PF2);  F2 := PF2^;

  if      F1 < F2 then  begin Result := -1; Exit; end // check fourth float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc( WPtr1, Sizeof(Pointer) );
  Inc( WPtr2, Sizeof(Pointer) );

  Int1 := PInteger(WPtr1)^;
  Int2 := PInteger(WPtr2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end // check last int
  else if Int1 > Int2 then  begin Result := +1; Exit; end;
  //***** Here:  Record1 = Record2,  Result = 0
end; // end of function N_Compare2PFP1Int

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Compare2PDP1Int
//******************************************************* N_Compare2PDP1Int ***
// Compare records with two pointers to Double Points and Integer subsequent 
// fields
//
//     Parameters
// AIParam - offset in bytes of first pointer to Double Point field in given 
//           records
// APtr1   - pointer to first record with pointers to Double Points
// APtr2   - pointer to second record with pointers to Double Points
// Result  - Returns:
//#F
// =-1 if Record1 < Record2
//
// =0  if Record1 = Record2
//
// =1  if Record1 > Record2
//#/F
//
// Function can be used in N_SortPointers procedure.
//
function N_Compare2PDP1Int( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  F1, F2: Double;
  Int1, Int2: integer;
  PF1, PF2: PDouble;
  WPtr1, WPtr2: TN_BytesPtr;
begin
  WPtr1 := APtr1+AIParam;
  WPtr2 := APtr2+AIParam;

  PF1 := PDouble(Pointer(WPtr1)^);
  PF2 := PDouble(Pointer(WPtr2)^);

  F1 := PF1^;
  F2 := PF2^;
  Result := 0; // as if FRect1 = FRect2 and Int1 = Int2

  if      F1 < F2 then  begin Result := -1; Exit; end // check first float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc(PF1);  F1 := PF1^;
  Inc(PF2);  F2 := PF2^;

  if      F1 < F2 then  begin Result := -1; Exit; end // check second float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc( WPtr1, Sizeof(Pointer) );
  Inc( WPtr2, Sizeof(Pointer) );

  PF1 := PDouble(Pointer(WPtr1)^);
  PF2 := PDouble(Pointer(WPtr2)^);

  F1 := PF1^;
  F2 := PF2^;

  if      F1 < F2 then  begin Result := -1; Exit; end // check third float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc(PF1);  F1 := PF1^;
  Inc(PF2);  F2 := PF2^;

  if      F1 < F2 then  begin Result := -1; Exit; end // check fourth float
  else if F1 > F2 then  begin Result := +1; Exit; end;

  Inc( WPtr1, Sizeof(Pointer) );
  Inc( WPtr2, Sizeof(Pointer) );

  Int1 := PInteger(WPtr1)^;
  Int2 := PInteger(WPtr2)^;

  if      Int1 < Int2 then  begin Result := -1; Exit; end // check last int
  else if Int1 > Int2 then  begin Result := +1; Exit; end;
  //***** Here:  Record1 = Record2,  Result = 0
end; // end of function N_Compare2PDP1Int

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CompareIDD
//************************************************************ N_CompareIDD ***
// Compare records with Integer and Double Point subsequent fields
//
//     Parameters
// AIParam - not used now
// APtr1   - pointer to first record with Integer and Double Point
// APtr2   - pointer to second record with Integer and Double Point
// Result  - Returns:
//#F
// =-1 if Record1 < Record2
//
// =0  if Record1 = Record2
//
// =1  if Record1 > Record2
//#/F
//
// Function can be used in N_SortPointers procedure.
//
function N_CompareIDD( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  I1, I2: integer;
  D1, D2: double;
begin
  I1 := PInteger(APtr1)^;
  I2 := PInteger(APtr2)^;
  Result := 0; // as if I1 = I2, X1 = X2 and Y1 = Y2

  if      I1 < I2 then  begin Result := -1; Exit; end
  else if I1 > I2 then  begin Result := +1; Exit; end
  else // I1 = I2, compare next field
  begin
    D1 := PDouble(APtr1+SizeOf(Integer))^;
    D2 := PDouble(APtr2+SizeOf(Integer))^;

    if      D1 < D2 then  begin Result := -1; Exit; end
    else if D1 > D2 then  begin Result := +1; Exit; end
    else // I1 = I2, D1(1) = D2(1), compare next field
    begin
      D1 := PDouble(APtr1+SizeOf(Integer)+SizeOf(Double))^;
      D2 := PDouble(APtr2+SizeOf(Integer)+SizeOf(Double))^;
      if      D1 < D2 then  begin Result := -1; Exit; end
      else if D1 > D2 then  begin Result := +1; Exit; end
    end;
    //***** Here:  I1 = I2, D1(1) = D2(1), D1(2) = D2(2) --> Result = 0
  end; // else // I1 = I2, compare next field
end; // end of function N_CompareIDD

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CompareIRectCenters
//*************************************************** N_CompareIRectCenters ***
// Compare centers of Integer Rectangles
//
//     Parameters
// AIParam - =0 - compare X-Centers, =1 - compare Y-Centers
// APtr1   - pointer to first Integer Rectangle
// APtr2   - pointer to second Integer Rectangle
// Result  - Returns:
//#F
// =-1 if Center1 < Center2
//
// =0  if Center1 = Center2
//
// =1  if Center1 > Center2
//#/F
//
// Function can be used in N_SortPointers procedure.
//
function N_CompareIRectCenters( const AIParam: integer; const APtr1, APtr2: TN_BytesPtr ): integer;
var
  I1, I2: integer;
begin
  if AIParam = 0 then // calc X-Centers
  begin
    with PIRect(APtr1)^ do
      I1 := (Left + Right) div 2;
    with PIRect(APtr2)^ do
      I2 := (Left + Right) div 2;
  end else //*********  calc Y-Centers
  begin
    with PIRect(APtr1)^ do
      I1 := (Top + Bottom) div 2;
    with PIRect(APtr2)^ do
      I2 := (Top + Bottom) div 2;
  end;

  Result := 0; // as if I1 = I2

  if      I1 < I2 then  begin Result := -1; Exit; end
  else if I1 > I2 then  begin Result := +1; Exit; end;

end; // end of function N_CompareIRectCenters

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IncEnvRect(integer)
//*************************************************** N_IncEnvRect(integer) ***
// Increase given Integer Envelope Rectangle by given Integer Point
//
//     Parameters
// AEnvRect - Integer Envelope Rectangle, to which given point is added
// APoint   - Integer Point added to Envelope Rectangle
//
procedure N_IncEnvRect( var AEnvRect: TRect; const APoint: TPoint );
begin
  if AEnvRect.Left = N_NotAnInteger then // not initialized yet
  begin
    AEnvRect.Left   := APoint.X;
    AEnvRect.Top    := APoint.Y;
    AEnvRect.Right  := APoint.X;
    AEnvRect.Bottom := APoint.Y;
  end else
  begin
    if AEnvRect.Left   >  APoint.X then AEnvRect.Left   := APoint.X;
    if AEnvRect.Top    >  APoint.Y then AEnvRect.Top    := APoint.Y;
    if AEnvRect.Right  <  APoint.X then AEnvRect.Right  := APoint.X;
    if AEnvRect.Bottom <  APoint.Y then AEnvRect.Bottom := APoint.Y;
  end;
end; // end of procedure N_IncEnvRect(integer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IncEnvRect(float,float)
//*********************************************** N_IncEnvRect(float,float) ***
// Increase given Float Envelope Rectangle by given Float Point
//
//     Parameters
// AEnvFRect - Float Envelope Rectangle, to which given Point is added
// ADPoint   - Float Point added to Envelope Rectangle
//
procedure N_IncEnvRect( var AEnvFRect: TFRect; const AFPoint: TFPoint );
begin
  if AEnvFRect.Left = N_NotAFloat then // not initialized yet
  begin
    AEnvFRect.Left   := AFPoint.X;
    AEnvFRect.Top    := AFPoint.Y;
    AEnvFRect.Right  := AFPoint.X;
    AEnvFRect.Bottom := AFPoint.Y;
  end else
  begin
    if AEnvFRect.Left   > AFPoint.X then AEnvFRect.Left   := AFPoint.X;
    if AEnvFRect.Top    > AFPoint.Y then AEnvFRect.Top    := AFPoint.Y;
    if AEnvFRect.Right  < AFPoint.X then AEnvFRect.Right  := AFPoint.X;
    if AEnvFRect.Bottom < AFPoint.Y then AEnvFRect.Bottom := AFPoint.Y;
  end;
end; // end of procedure N_IncEnvRect(float,float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IncEnvRect(float,double)
//********************************************** N_IncEnvRect(float,double) ***
// Increase given Float Envelope Rectangle by given Double Point
//
//     Parameters
// AEnvFRect - Float Envelope Rectangle, to which given point is added
// ADPoint   - Double Point added to Envelope Rectangle
//
procedure N_IncEnvRect( var AEnvFRect: TFRect; const ADPoint: TDPoint );
begin
  if AEnvFRect.Left = N_NotAFloat then // not initialized yet
  begin
    AEnvFRect.Left   := ADPoint.X;
    AEnvFRect.Top    := ADPoint.Y;
    AEnvFRect.Right  := ADPoint.X;
    AEnvFRect.Bottom := ADPoint.Y;
  end else
  begin
    if AEnvFRect.Left   > ADPoint.X then AEnvFRect.Left   := ADPoint.X;
    if AEnvFRect.Top    > ADPoint.Y then AEnvFRect.Top    := ADPoint.Y;
    if AEnvFRect.Right  < ADPoint.X then AEnvFRect.Right  := ADPoint.X;
    if AEnvFRect.Bottom < ADPoint.Y then AEnvFRect.Bottom := ADPoint.Y;
  end;
end; // end of procedure N_IncEnvRect(float,double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IncEnvRect(double)
//**************************************************** N_IncEnvRect(double) ***
// Increase given Double Envelope Rectangle by given Double Point
//
//     Parameters
// AEnvDRect - Double Envelope Rectangle, to which given point is added
// ADPoint   - Double Point added to Envelope Rectangle
//
procedure N_IncEnvRect( var AEnvDRect: TDRect; const ADPoint: TDPoint );
begin
  if AEnvDRect.Left = N_NotADouble then // not initialized yet
  begin
    AEnvDRect.Left   := ADPoint.X;
    AEnvDRect.Top    := ADPoint.Y;
    AEnvDRect.Right  := ADPoint.X;
    AEnvDRect.Bottom := ADPoint.Y;
  end else
  begin
    if AEnvDRect.Left   > ADPoint.X then AEnvDRect.Left   := ADPoint.X;
    if AEnvDRect.Top    > ADPoint.Y then AEnvDRect.Top    := ADPoint.Y;
    if AEnvDRect.Right  < ADPoint.X then AEnvDRect.Right  := ADPoint.X;
    if AEnvDRect.Bottom < ADPoint.Y then AEnvDRect.Bottom := ADPoint.Y;
  end;
end; // end of procedure N_IncEnvRect(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IncLineEnvRect(float)
//************************************************* N_IncLineEnvRect(float) ***
// Increase given Float Envelope Rectangle by given Float Polyline
//
//     Parameters
// AEnvFRect - Float Envelope Rectangle, to which given Polyline Vertexes are 
//             added
// AFCoords  - Float Polyline given as Float Points array
//
procedure N_IncLineEnvRect( var AEnvFRect: TFRect; const AFCoords: TN_FPArray );
var
  AddRect: TFRect;
begin
  AddRect := N_CalcLineEnvRect( AFCoords, 0, Length(AFCoords) );
  N_FRectOr( AEnvFRect, AddRect ); // (EnvRect may be not initialized)
end; // end of procedure N_IncLineEnvDRect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IncLineEnvRect(double)
//************************************************ N_IncLineEnvRect(double) ***
// Increase given Float Envelope Rectangle by given Double Polyline
//
//     Parameters
// AEnvFRect - Float Envelope Rectangle, to which given Polyline Vertexes are 
//             added
// ADCoords  - Double Polyline given as Double Points array
//
procedure N_IncLineEnvRect( var AEnvFRect: TFRect; const ADCoords: TN_DPArray );
var
  AddRect: TFRect;
begin
  AddRect := N_CalcLineEnvRect( ADCoords, 0, Length(ADCoords) );
  N_FRectOr( AEnvFRect, AddRect ); // (EnvRect may be not initialized)
end; // end of procedure N_IncLineEnvDRect(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AdjustSizeByAspect(integer)
//******************************************* N_AdjustSizeByAspect(integer) ***
// Adjust given Integer sizes by given Aspect Ratio using given mode
//
//     Parameters
// AAdjustMode   - calculation mode
// AInpSize      - sizes given as Integer Point
// ANeededAspect - needed Aspect Ratio
// Result        - Returns Integer Point with calculated sizes
//
function N_AdjustSizeByAspect( AAdjustMode: TN_AdjustAspectMode;
                   const AInpSize: TPoint; const ANeededAspect: double ): TPoint;
var
  InpSizeAspect: double;
begin
  Result := AInpSize;
  if (ANeededAspect = 0) or (AAdjustMode = aamNoChange) then Exit; // nothing todo

  if AInpSize.X*AInpSize.Y = 0 then // a precaution
  begin
    Result.X := 100;
    Result.Y := Round(Result.X * ANeededAspect);
    Exit;
  end;

  InpSizeAspect := abs( AInpSize.Y / AInpSize.X );

  if AAdjustMode = aamIncRect then // X or Y size should be increased if needed
  begin
    if InpSizeAspect < ANeededAspect then // increase Result.Y
      Result.Y := Round( Result.Y * ANeededAspect / InpSizeAspect )
    else //********************************* increase Result.X
      Result.X := Round( Result.X * InpSizeAspect / ANeededAspect );
  end else if AAdjustMode = aamDecRect then  // aamDecRect, X or Y size should be decreased if needed
  begin
    if InpSizeAspect > ANeededAspect then // decrease Result.Y
      Result.Y := Round( Result.Y * ANeededAspect / InpSizeAspect )
    else //******************************** decrease Result.X
      Result.X := Round( Result.X * InpSizeAspect / ANeededAspect );
  end else // aamSwapDec, swap X,Y if needed and process aamDecRect
  begin
    if ((InpSizeAspect >= 1) and (ANeededAspect < 1)) or
       ((InpSizeAspect <= 1) and (ANeededAspect > 1))  then // swap X,Y
    begin
      Result.X := AInpSize.Y;
      Result.Y := AInpSize.X;
    end;

    Result := N_AdjustSizeByAspect( aamDecRect, Result, ANeededAspect );
  end;

  if Result.X <= 0 then Result.X := 1;
  if Result.Y <= 0 then Result.Y := 1;
end; // end of function N_AdjustSizeByAspect(integer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AdjustSizeByAspect(float)
//********************************************* N_AdjustSizeByAspect(float) ***
// Adjust given Float sizes by given Aspect using given mode
//
//     Parameters
// AAdjustMode   - calculation mode
// AInpFSize     - sizes given as Float Point
// ANeededAspect - needed Aspect Ratio
// Result        - Returns Float Point with calculated sizes
//
function N_AdjustSizeByAspect( AAdjustMode: TN_AdjustAspectMode;
                const AInpSize: TFPoint; const ANeededAspect: double ): TFPoint;
var
  InpSizeAspect: double;
begin
  Result := AInpSize;
  if (ANeededAspect = 0) or (AAdjustMode = aamNoChange) then Exit; // nothing todo

  if AInpSize.X*AInpSize.Y = 0 then // a precaution
  begin
    Result.X := 100;
    Result.Y := Result.X * ANeededAspect;
    Exit;
  end;

  InpSizeAspect := abs( AInpSize.Y / AInpSize.X );

  if AAdjustMode = aamIncRect then // X or Y size should be increased if needed
  begin
    if InpSizeAspect < ANeededAspect then // increase Result.Y
      Result.Y := Result.Y * ANeededAspect / InpSizeAspect
    else //******************************** increase Result.X
      Result.X := Result.X * InpSizeAspect / ANeededAspect;
  end else if AAdjustMode = aamDecRect then  // aamDecRect, X or Y size should be decreased if needed
  begin
    if InpSizeAspect > ANeededAspect then // decrease Result.Y
      Result.Y := Result.Y * ANeededAspect / InpSizeAspect
    else //******************************** decrease Result.X
      Result.X := Result.X * InpSizeAspect / ANeededAspect;
  end else // aamSwapDec, swap X,Y if needed and process aamDecRect
  begin
    if ((InpSizeAspect >= 1) and (ANeededAspect < 1)) or
       ((InpSizeAspect <= 1) and (ANeededAspect > 1))  then // swap X,Y
    begin
      Result.X := AInpSize.Y;
      Result.Y := AInpSize.X;
    end;

    Result := N_AdjustSizeByAspect( aamDecRect, Result, ANeededAspect );
  end;
end; // end of function N_AdjustSizeByAspect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AdjustSizeByAspect(double)
//******************************************** N_AdjustSizeByAspect(double) ***
// Adjust given Double sizes by given Aspect Ratio using given mode
//
//     Parameters
// AAdjustMode   - calculation mode
// AInpDSize     - sizes given as Double Point
// ANeededAspect - needed Aspect Ratio
// Result        - Returns Double Point with calculated sizes
//
function N_AdjustSizeByAspect( AAdjustMode: TN_AdjustAspectMode;
                const AInpSize: TDPoint; const ANeededAspect: double ): TDPoint;
var
  InpSizeAspect: double;
begin
  Result := AInpSize;
  if (ANeededAspect = 0) or (AAdjustMode = aamNoChange) then Exit; // nothing todo

  if AInpSize.X*AInpSize.Y = 0 then // a precaution
  begin
    Result.X := 100;
    Result.Y := Result.X * ANeededAspect;
    Exit;
  end;

  InpSizeAspect := abs( AInpSize.Y / AInpSize.X );

  if AAdjustMode = aamIncRect then // X or Y size should be increased if needed
  begin
    if InpSizeAspect < ANeededAspect then // increase Result.Y
      Result.Y := Result.Y * ANeededAspect / InpSizeAspect
    else //******************************** increase Result.X
      Result.X := Result.X * InpSizeAspect / ANeededAspect;
  end else if AAdjustMode = aamDecRect then  // aamDecRect, X or Y size should be decreased if needed
  begin
    if InpSizeAspect > ANeededAspect then // decrease Result.Y
      Result.Y := Result.Y * ANeededAspect / InpSizeAspect
    else //******************************** decrease Result.X
      Result.X := Result.X * InpSizeAspect / ANeededAspect;
  end else // aamSwapDec, swap X,Y if needed and process aamDecRect
  begin
    if ((InpSizeAspect >= 1) and (ANeededAspect < 1)) or
       ((InpSizeAspect <= 1) and (ANeededAspect > 1))  then // swap X,Y
    begin
      Result.X := AInpSize.Y;
      Result.Y := AInpSize.X;
    end;

    Result := N_AdjustSizeByAspect( aamDecRect, Result, ANeededAspect );
  end;
end; // end of function N_AdjustSizeByAspect(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AdjustURectAspByPRect
//************************************************* N_AdjustURectAspByPRect ***
// Adjust given Double Rectangle Aspect ratio by given Integer Rectangle Aspect 
// ratio
//
//     Parameters
// AAdjustMode - calculation mode:
//#F
//   =aamNoChange - do not change
//   =aamIncRect  - increase resulting AURect (on output AURect has needed aspect ratio and
//                                        includes given AURect)
//   =aamDecRect  - decrease URect (on output AURect has needed aspect ratio and
//                                        is inside given AURect)
//#/F
// AURect      - given Double Rectangle, on output resulting Double Rectangle
// APRect      - Integer Rectangle
//
// Only APRect's Aspect ratio is used. It's Aspect ration is 
// (APRect.Bottom-APRect.Top+1) / (APRect.Right-APRect.Left+1)
//
procedure N_AdjustURectAspByPRect( AAdjustMode: TN_AdjustAspectMode;
                                    var AURect: TDRect; const APRect: TRect );
var
  NeededAspect, NeededWidth, NeededHeight, Sum: double;
  InpAspect, InpWidth, InpHeight: double;
begin
  NeededAspect := (APRect.Bottom-APRect.Top+1) / (APRect.Right-APRect.Left+1);
  InpWidth  := AURect.Right  - AURect.Left;
  InpHeight := AUrect.Bottom - AURect.Top;
  InpAspect := InpHeight / InpWidth;

  case AAdjustMode of

  aamNoChange: Exit; // nothing to do

  aamIncRect: // increase URect
  begin
    if InpAspect < NeededAspect then // increase URect's Height
    begin
      NeededHeight := InpWidth * NeededAspect;
      Sum := AURect.Top + AURect.Bottom;
      AURect.Top    := 0.5*( Sum - NeededHeight);
      AURect.Bottom := 0.5*( Sum + NeededHeight);
    end else if InpAspect > NeededAspect then // increase URect's Width
    begin
      NeededWidth := InpHeight / NeededAspect;
      Sum := AURect.Left + AURect.Right;
      AURect.Left  := 0.5*( Sum - NeededWidth);
      AURect.Right := 0.5*( Sum + NeededWidth);
    end;
  end; // aamIncRect: begin // increase URect

  aamDecRect: // decrease URect
  begin
    if InpAspect < NeededAspect then // decrease URect's Width
    begin
      NeededWidth := InpHeight / NeededAspect;
      Sum := AURect.Left + AURect.Right;
      AURect.Left  := 0.5*( Sum - NeededWidth);
      AURect.Right := 0.5*( Sum + NeededWidth);
    end else if InpAspect > NeededAspect then // decrease URect's Height
    begin
      NeededHeight := InpWidth * NeededAspect;
      Sum := AURect.Top + AURect.Bottom;
      AURect.Top    := 0.5*( Sum - NeededHeight);
      AURect.Bottom := 0.5*( Sum + NeededHeight);
    end;
  end; // aamDecRect: begin // decrease URect

  end; // case AdjustAspectMode of
end; //*** end of procedure N_AdjustURectAspByPRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AdjustSizeByMaxArea
//*************************************************** N_AdjustSizeByMaxArea ***
// Get Rectangle Size by given Size and Maximal Rectangle Area
//
//     Parameters
// ASize  - given width and height as TPoint
// Result - Returns Maximal Width and Height
//
function N_AdjustSizeByMaxArea( ASize: TPoint; AMaxArea: Integer ) : TPoint;
var
  RRSize : Integer;
  Aspect, RNWidth : Double;
begin
  Result := ASize;
  // Calc Maximal Pixel Size
  RRSize := Result.X * Result.Y;
  if AMaxArea < RRSize then
  begin
  // Calc Needed Size
    Aspect := Result.Y / Result.X;
    RNWidth := sqrt( AMaxArea / Aspect );
    Result.Y := Round( RNWidth * Aspect ) - 1;
    Result.X := Round( RNWidth ) - 1;
  end;
end; // function N_AdjustSizeByMaxArea

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DecRectbyAspect
//******************************************************* N_DecRectbyAspect ***
// Decrease given Integer Rectangle by given Aspect ratio and center it inside 
// original Rectangle
//
//     Parameters
// ARect         - given Integer Rectangle
// ANeededAspect - needed Aspect Ratio
//
function N_DecRectbyAspect( const ARect: TRect; const ANeededAspect: double ): TRect;
var
  RectSize: TPoint;
begin
  RectSize := N_RectSize( ARect );
  RectSize := N_AdjustSizeByAspect( aamDecRect, RectSize, ANeededAspect );
  Result   := N_IRectCreate2( ARect, RectSize.X, RectSize.Y, True );
end; // function N_DecRectbyAspect (IRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IncRectbyAspect
//******************************************************* N_IncRectbyAspect ***
// Increase given Float Rectangle by given Aspect ratio, so that it has the same
// center
//
//     Parameters
// ARect         - given Float Rectangle
// ANeededAspect - needed Aspect Ratio
//
function N_IncRectbyAspect( const ARect: TFRect; const ANeededAspect: double ): TFRect;
var
  RectSize: TDPoint;
begin
  RectSize := N_RectSize( ARect );
  RectSize := N_AdjustSizeByAspect( aamIncRect, RectSize, ANeededAspect );
  Result   := N_FRectCreate( ARect, RectSize, DPoint(0.5,0.5) );
end; // function N_IncRectbyAspect (FRect)


//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AdjustRectAspect_(INT)
//************************************************ N_AdjustRectAspect (INT) ***
// Adjust given Integer Rectangle Aspect ratio by given Aspect Ratio using given
// mode
//
//     Parameters
// AAdjustMode   - calculation mode
//#F
//   =aamNoChange - do not change (ARect remains the same)
//   =aamIncRect  - increase ARect (on output ARect has needed aspect and
//                                   includes given ARect (in the middle) )
//   =aamDecRect  - decrease ARect (on output ARect has needed aspect and
//                           is inside given ARect (in upper left corner) )
//#/F
// ARect         - given Integer Rectangle, on output resulting Integer 
//                 Rectangle
// ANeededAspect - needed Aspect Ratio
//
procedure N_AdjustRectAspect( AAdjustMode: TN_AdjustAspectMode;
                              var ARect: TRect; const ANeededAspect: double );
var
  NeededWidth, NeededHeight, InpWidth, InpHeight: integer;
  InpAspect: double;
begin
  if (AAdjustMode = aamNoChange) or
     (ANeededAspect = 0)  then Exit;  // nothing to do

  InpWidth  := ARect.Right  - ARect.Left + 1;
  InpHeight := Arect.Bottom - ARect.Top + 1;

  if (InpWidth = 0) or (InpHeight = 0) then Exit; // Aspect not defined

  InpAspect := InpHeight / InpWidth;

  case AAdjustMode of

  aamNoChange: Exit; // nothing to do

  aamIncRect: //******************** increase ARect
  begin
    if InpAspect < ANeededAspect then // increase ARect's Height
    begin
      NeededHeight := Round( InpWidth*ANeededAspect );
      ARect.Top    := Round( 0.5*( ARect.Top + ARect.Bottom - NeededHeight) );
      ARect.Bottom := ARect.Top + NeededHeight - 1;
    end else if InpAspect > ANeededAspect then // increase ARect's Width
    begin
      NeededWidth := Round( InpHeight/ANeededAspect );
      ARect.Left  := Round( 0.5*( ARect.Left + ARect.Right - NeededWidth) );
      ARect.Right := ARect.Left + NeededWidth - 1;
    end;
  end; // aamIncRect: begin // increase ARect

  aamDecRect: //******************** decrease ARect
  begin
    if InpAspect < ANeededAspect then // decrease ARect's Width
    begin
      NeededWidth := Round( InpHeight/ANeededAspect );
      ARect.Right := ARect.Left + NeededWidth - 1;
    end else if InpAspect > ANeededAspect then // decrease ARect's Height
    begin
      NeededHeight := Round( InpWidth*ANeededAspect );
      ARect.Bottom := ARect.Top + NeededHeight - 1;
    end;
  end; // aamDecRect: begin // decrease ARect

  end; // case AdjustAspectMode of
end; //*** end of procedure N_AdjustRectAspect (INT)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AdjustRectAspect_(float)
//********************************************** N_AdjustRectAspect (float) ***
// Adjust given Float Rectangle Aspect ratio by given Aspect Ratio using given 
// mode
//
//     Parameters
// AAdjustMode   - calculation mode
//#F
//   =aamNoChange - do not change (AFRect remains the same)
//   =aamIncRect  - increase AFRect (on output ARect has needed aspect and
//                                   includes given AFRect (in the middle) )
//   =aamDecRect  - decrease AFRect (on output AFRect has needed aspect and
//                           is inside given AFRect (in upper left corner) )
//#/F
// AFRect        - given Float Rectangle, on output resulting Float Rectangle
// ANeededAspect - needed Aspect Ratio
//
procedure N_AdjustRectAspect( AAdjustMode: TN_AdjustAspectMode;
                              var AFRect: TFRect; const ANeededAspect: double );
var
  NeededWidth, NeededHeight, InpWidth, InpHeight, InpAspect: double;
begin
  if (AAdjustMode = aamNoChange) or
     (ANeededAspect = 0)  then Exit;  // nothing to do

  InpWidth  := AFRect.Right  - AFRect.Left;
  InpHeight := AFRect.Bottom - AFRect.Top;

  if (InpWidth = 0) or (InpHeight = 0) then Exit; // Aspect not defined

  InpAspect := InpHeight / InpWidth;

  case AAdjustMode of

  aamIncRect: //******************** increase ARect
  begin
    if InpAspect < ANeededAspect then // increase ARect's Height
    begin
      NeededHeight := InpWidth*ANeededAspect;
      AFRect.Top    := 0.5*( AFRect.Top + AFRect.Bottom - NeededHeight);
      AFRect.Bottom := AFRect.Top + NeededHeight;
    end else if InpAspect > ANeededAspect then // increase ARect's Width
    begin
      NeededWidth := InpHeight/ANeededAspect;
      AFRect.Left  := 0.5*( AFRect.Left + AFRect.Right - NeededWidth);
      AFRect.Right := AFRect.Left + NeededWidth;
    end;
  end; // aamIncRect: begin // increase ARect

  aamDecRect: //******************** decrease ARect
  begin
    if InpAspect < ANeededAspect then // decrease ARect's Width
    begin
      NeededWidth := InpHeight/ANeededAspect;
      AFRect.Right := AFRect.Left + NeededWidth;
    end else if InpAspect > ANeededAspect then // decrease ARect's Height
    begin
      NeededHeight := InpWidth*ANeededAspect;
      AFRect.Bottom := AFRect.Top + NeededHeight;
    end;
  end; // aamDecRect: begin // decrease ARect

  end; // case AdjustAspectMode of
end; //*** end of procedure N_AdjustRectAspect(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AdjustRectAspect_(INT2)
//*********************************************** N_AdjustRectAspect (INT2) ***
// Adjust given Integer Rectangle sizes by given Aspect Ratio using given mode
//
//     Parameters
// AAdjustMode   - calculation mode
// AWidth        - Integer Rectange Width
// AHeight       - Integer Rectange Height
// ANeededAspect - needed Aspect Ratio
//
procedure N_AdjustRectAspect( AAdjustMode: TN_AdjustAspectMode;
                     var AWidth, AHeight: integer; const ANeededAspect: double );
var
  InpAspect: double;
begin
  if (AAdjustMode = aamNoChange) or
     (ANeededAspect = 0)  then Exit;  // nothing to do

  if (AWidth = 0) or (AHeight = 0) then Exit; // Aspect not defined

  InpAspect := AHeight / AWidth;

  case AAdjustMode of

  aamIncRect: //******************** increase ARect
  begin
    if InpAspect < ANeededAspect then // increase Inp Rect's Height
      AHeight := Round( AWidth*ANeededAspect )
    else if InpAspect > ANeededAspect then // increase Inp Rect's Width
      AWidth := Round( AHeight/ANeededAspect );
  end; // aamIncRect: begin // increase Inp Rect

  aamDecRect: //******************** decrease Inp Rect
  begin
    if InpAspect < ANeededAspect then // decrease Inp Rect's Width
      AWidth := Round( AHeight/ANeededAspect )
    else if InpAspect > ANeededAspect then // decrease Inp Rect's Height
      AHeight := Round( AWidth*ANeededAspect );
  end; // aamDecRect: begin // decrease ARect

  end; // case AdjustAspectMode of
end; //*** end of procedure N_AdjustRectAspect (INT)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CheckSegmentsCrossing1
//************************************************ N_CheckSegmentsCrossing1 ***
// Search for crossings in given Segments Array
//
//     Parameters
// ASegmLines   - input array of TN_SegmLine records
// AEps         - crossing accuracy
// ACrossPoints - output array of TN_CrossPointPar records. Crosspoints
//
// Earch TN_SegmLine records contains Segment's End DPoints and it's line 
// coefficients (Ax + By + C = 0). Earch TN_CrossPointPar record contains 
// crossed Segemnts indexes, crosspoint Double Coordinates and Crosspoint type 
// flags.
//
procedure N_CheckSegmentsCrossing1( const ASegmLines: TN_SegmLineItems; const AEps: double;
                                            var ACrossPoints: TN_CrossPoints );
var
  i, j, IndCross: integer;
  R1, R2: double;
  Pi, Pj: TN_BytesPtr;
begin
  ACrossPoints := nil;
  IndCross := 0;
  for i := 0 to High(ASegmLines) do
  begin
    Pi := TN_BytesPtr(@ASegmLines[i]); // pointer to SegmLines[i]
    for j := i+1 to High(ASegmLines) do
    begin
      Pj := TN_BytesPtr(@ASegmLines[j]); // pointer to SegmLines[j]
// R1 := SegmLines[i].a*SegmLines[j].P1.X + SegmLines[i].b*SegmLines[j].P1.Y + SegmLines[i].c;
// R2 := SegmLines[i].a*SegmLines[j].P2.X + SegmLines[i].b*SegmLines[j].P2.Y + SegmLines[i].c;
      R1 := PDouble(Pi+4*sizeof(double))^*PDouble(Pj)^ +
            PDouble(Pi+5*sizeof(double))^*PDouble(Pj+1*sizeof(double))^ +
            PDouble(Pi+6*sizeof(double))^;
      R2 := PDouble(Pi+4*sizeof(double))^*PDouble(Pj+2*sizeof(double))^ +
            PDouble(Pi+5*sizeof(double))^*PDouble(Pj+3*sizeof(double))^ +
            PDouble(Pi+6*sizeof(double))^;

      if ( ((R1-AEps)>0) and ((R2+AEps)<0) or // External if
           ((R2-AEps)>0) and ((R1+AEps)<0) ) then
      begin
// R1 := SegmLines[j].a*SegmLines[i].P1.X + SegmLines[j].b*SegmLines[i].P1.Y + SegmLines[j].c;
// R2 := SegmLines[j].a*SegmLines[i].P2.X + SegmLines[j].b*SegmLines[i].P2.Y + SegmLines[j].c;

        R1 := PDouble(Pj+4*sizeof(double))^*PDouble(Pi)^ +
              PDouble(Pj+5*sizeof(double))^*PDouble(Pi+1*sizeof(double))^ +
              PDouble(Pj+6*sizeof(double))^;
        R2 := PDouble(Pj+4*sizeof(double))^*PDouble(Pi+2*sizeof(double))^ +
              PDouble(Pj+5*sizeof(double))^*PDouble(Pi+3*sizeof(double))^ +
              PDouble(Pj+6*sizeof(double))^;

        if ( ((R1-AEps)>0) and ((R2+AEps)<0) or  // Internal if
             ((R2-AEps)>0) and ((R1+AEps)<0) ) then
        begin // segments i and j are crossed
          if High(ACrossPoints) < IndCross then
            SetLength( ACrossPoints, 2*Length(ACrossPoints)+4 );
          ACrossPoints[IndCross].Ind1 := i;
          ACrossPoints[IndCross].Ind2 := j;
          Inc(IndCross);
        end; // if ( ((R1-Eps)>0) and ((R2+Eps)<0) or // Internal if

      end; // if ( ((R1-Eps)>0) and ((R2+Eps)<0) or // External if
    end; // for j := i+1 to High(SegmLines) do
  end; // for i := 0 to High(SegmLines) do
  SetLength( ACrossPoints, IndCross );
end; // procedure N_CheckSegmentsCrossing1

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcArcCoords
//********************************************************* N_CalcArcCoords ***
// Calculate coordinates of Polyline close to given Arc of a Circle
//
//     Parameters
// AArcCoords - resulting array of Double Points
// ANPoints   - number of resulting points
// AOX, AOY   - circle center coordinates
// ARX, ARY   - circle radii
// ABegAngle  - Acr start angle in radian
// AEndAngle  - Acr final angle in radian
//
procedure N_CalcArcCoords( var AArcCoords: TN_DPArray; ANPoints: integer;
                         const AOX, AOY, ARX, ARY, ABegAngle, AEndAngle: double );
var
  i: integer;
  StepAngle: double;
begin
  if ANPoints <= 1 then ANPoints := 2; // a precaution
  SetLength( AArcCoords, ANPoints );
  StepAngle := (AEndAngle - ABegAngle) / (ANPoints-1);
  for i := 0 to ANPoints-1 do
  begin
    AArcCoords[i].X := AOX + ARX*cos( ABegAngle + i*StepAngle );
    AArcCoords[i].Y := AOY - ARY*sin( ABegAngle + i*StepAngle );
  end;
end; // end of procedure N_CalcArcCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcRectCoords
//******************************************************** N_CalcRectCoords ***
// Calculate Integer Polyline Coordinates appropriate to given Integer Rectangle
//
//     Parameters
// ALineCoords - resulting Integer Polyline given as array of Integer Points
// ARect       - given Integer Rectangle
//
procedure N_CalcRectCoords( var ALineCoords: TN_IPArray; const ARect: TRect );
begin
  if Length(ALineCoords) < 5 then
    SetLength( ALineCoords, 5 );

  ALineCoords[0]   := ARect.TopLeft;
  ALineCoords[1].X := ARect.Right;
  ALineCoords[1].Y := ARect.Top;
  ALineCoords[2]   := ARect.BottomRight;
  ALineCoords[3].X := ARect.Left;
  ALineCoords[3].Y := ARect.Bottom;
  ALineCoords[4]   := ARect.TopLeft;
end; // end of procedure N_CalcRectCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SetScrollBarsByRects(1)
//*********************************************** N_SetScrollBarsByRects(2) ***
// Update given Vertical and Horisontal ScrollBars fields by two given Float 
// Rectangles: Maximal Rectangle and Current Visible Rectangle, inside Maximal
//
//     Parameters
// AMaxFRect - Maximal Float Rectangle inside which is ACurFRect
// ACurFRect - Float Rectangle inside AMaxFRect by which ScrollBars fields 
//             should be set
// AHSB      - given Horizontal ScrollBar
// AVSB      - given Vertical ScrollBar
//
procedure N_SetScrollBarsByRects( const AMaxFRect, ACurFRect: TFRect;
                                                    AHSB, AVSB: TScrollBar );
var
  MaxPos: integer;
  MaxSize, CurSize, PageSize, WrkLength, FDelta: double;
  SavedOnChangePtr: TNotifyEvent;
begin
  //***** ScrollBar Position is
  //      between 0 and (Max-PageSize+1) if PageSize <> 0 and
  //      between 0 and Max              if PageSize = 0  !

  //***** Set Horizontal ScrollBar *****
  AHSB.Min := Min( AHSB.Min, 0 ); // a precaution
  MaxSize := AMaxFRect.Right - AMaxFRect.Left; // Max Width
  CurSize := ACurFRect.Right - ACurFRect.Left; // Cur Width
  FDelta  := MaxSize - CurSize;

  if MaxSize*(1-N_Eps) < CurSize then // whole width is visible, so
    AHSB.Visible := False              //  ScrollBar is not needed
  else begin // calc Horizontal ScrollBar params
    AHSB.Visible := True;
    SavedOnChangePtr := AHSB.OnChange;
    AHSB.OnChange := nil;
    WrkLength := AHSB.Width - 2*AHSB.Height; // scrolling area size in pixels

    //  PageSize (always in logical units) should be so, that it's Pixel
    //            size be not less then HSB.Height (in pixels)
    PageSize := Max( AHSB.Max*AHSB.Height/WrkLength, AHSB.Max*CurSize/MaxSize );
    AHSB.PageSize := Round( PageSize );
    MaxPos := AHSB.Max-AHSB.PageSize+1; // max HSB.Position value (!)
    AHSB.Position := Round( MaxPos *
                           (ACurFRect.Left-AMaxFRect.Left) / (FDelta) );
    //*** SmallChange (always in logical units) should be about 1 pixel
    AHSB.SmallChange := Max( 1, Round(1.01*MaxPos/(AHSB.Width-AHSB.Height)+0.5));

    //*** LargeChange (always in logical units) should be about 0.9 CurWidth
    AHSB.LargeChange := Max( 1, Round( 0.9*MaxPos*CurSize/MaxSize ) );

    AHSB.OnChange := SavedOnChangePtr;
  end; // else begin // calc Horizontal ScrollBar params

  //***** Set Vertical ScrollBar *****
  AVSB.Min := Min( AVSB.Min, 0 ); // a recaution
  MaxSize := AMaxFRect.Bottom - AMaxFRect.Top; // Max Height
  CurSize := ACurFRect.Bottom - ACurFRect.Top; // Cur Height
  if MaxSize*(1-N_Eps) < CurSize then // whole Height is visible, so
    AVSB.Visible := False              //  ScrollBar is not needed
  else begin // calc Vertical ScrollBar params
    AVSB.Visible := True;
    SavedOnChangePtr := AVSB.OnChange;
    AVSB.OnChange := nil;
    WrkLength := AVSB.Height - 2*AVSB.Width; // scrolling area size in pixels

    //  PageSize (always in logical units) should be so, that it's Pixel
    //            size be not less then VSB.Height (in pixels)
    PageSize := Max( AVSB.Max*AVSB.Width/WrkLength, AVSB.Max*CurSize/MaxSize );
    AVSB.PageSize := Round( PageSize );
    MaxPos := AVSB.Max-AVSB.PageSize+1; // max VSB.Position value (!)
    AVSB.Position := Round( MaxPos *
                           (ACurFRect.Top-AMaxFRect.Top) / (MaxSize-CurSize) );
    //*** SmallChange (always in logical units) should be about 1 pixel
    AVSB.SmallChange := Max( 1, Round( 1.01*MaxPos/AVSB.Height + 0.5 ) );

    //*** LargeChange (always in logical units) should be about 0.9 CurHeight
    AVSB.LargeChange := Max( 1, Round( 0.9*MaxPos*CurSize/MaxSize ) );

    AVSB.OnChange := SavedOnChangePtr;
  end; // else begin // calc Vertical ScrollBar params
end; //*** end of procedure N_SetScrollBarsByRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SetScrollBarsByRects(2)
//*********************************************** N_SetScrollBarsByRects(1) ***
// Update given Vertical and Horisontal ScrollBars fields by two given Integer 
// Rectangles: Maximal Rectangle and Current Visible Rectangle, inside Maximal
//
//     Parameters
// AMaxRect - Maximal Integer Rectangle inside which is ACurRect
// ACurRect - Integer Rectangle inside AMaxRect by which ScrollBars fields 
//            should be set
// AHSB     - given Horizontal ScrollBar
// AVSB     - given Vertical ScrollBar
//
procedure N_SetScrollBarsByRects( const AMaxRect, ACurRect: TRect; AHSB, AVSB: TScrollBar );
var
  MaxPos, PixDelta: integer;
  MaxSize, CurSize, WrkLength: integer; //: double;
  PageSize: double;
  SavedOnChangePtr: TNotifyEvent;
begin
  //***** ScrollBar Position is
  //      between 0 and (Max-PageSize+1) if PageSize <> 0 and
  //      between 0 and Max              if PageSize = 0  !

  //***** Set AHSB - given Horizontal ScrollBar

  AHSB.Min := Min( AHSB.Min, 0 ); // a precaution
  MaxSize := AMaxRect.Right - AMaxRect.Left; // Max Width
  CurSize := ACurRect.Right - ACurRect.Left; // Cur Width

  PixDelta := MaxSize - CurSize;
  if (PixDelta = 0) or (AHSB.Height=0) then // // whole width is visible, so
    AHSB.Visible := False    // Horizontal ScrollBar is not needed
  else // calc Horizontal ScrollBar params
  begin
    AHSB.Visible := True;
    SavedOnChangePtr := AHSB.OnChange;
    AHSB.OnChange := nil;
    WrkLength := AHSB.Width - 2*AVSB.Width; // scrolling area size in pixels

    //  PageSize (always in logical units) should be so, that it's Pixel
    //            size be not less then AHSB.Height (in pixels)

    PageSize := Max( AHSB.Max*AHSB.Height/WrkLength, AHSB.Max*CurSize/MaxSize );
    AHSB.PageSize := Round( PageSize );
    MaxPos := AHSB.Max-AHSB.PageSize+1; // max HSB.Position value (!)
    AHSB.Position := Round( 1.0 * MaxPos * (ACurRect.Left-AMaxRect.Left) / PixDelta );

    //*** SmallChange (always in logical units) should be about 1 pixel
    AHSB.SmallChange := Max( 1, Round(1.01*MaxPos/PixDelta + 0.5));

    //*** LargeChange (always in logical units) should be about 0.9 CurWidth
    AHSB.LargeChange := Max( 1, Round( 0.9*MaxPos*CurSize/MaxSize ) );

    AHSB.OnChange := SavedOnChangePtr;
  end; // else begin // calc Horizontal ScrollBar params

  //***** Set Vertical ScrollBar *****
  AVSB.Min := Min( AVSB.Min, 0 ); // a precaution
  MaxSize := AMaxRect.Bottom - AMaxRect.Top; // Max Height
  CurSize := ACurRect.Bottom - ACurRect.Top; // Cur Height

  PixDelta := MaxSize - CurSize;
  if (PixDelta = 0) or (AVSB.Height=0) then // whole Height is visible, so
    AVSB.Visible := False   //  ScrollBar is not needed
  else // calc Vertical ScrollBar params
  begin
    AVSB.Visible := True;
    SavedOnChangePtr := AVSB.OnChange;
    AVSB.OnChange := nil;
    WrkLength := AVSB.Height - 2*AHSB.Height; // scrolling area size in pixels

    //  PageSize (always in logical units) should be so, that it's Pixel
    //            size be not less then VSB.Height (in pixels)
    PageSize := Max( AVSB.Max*AVSB.Width/WrkLength, AVSB.Max*CurSize/MaxSize );
    AVSB.PageSize := Round( PageSize );
    MaxPos := AVSB.Max-AVSB.PageSize+1; // max AVSB.Position value (!)
    AVSB.Position := Round( 1.0 * MaxPos * (ACurRect.Top-AMaxRect.Top) / (MaxSize-CurSize) );

    //*** SmallChange (always in logical units) should be about 1 pixel
    AVSB.SmallChange := Max( 1, Round(1.01*MaxPos/PixDelta + 0.5) );

    //*** LargeChange (always in logical units) should be about 0.9 CurHeight
    AVSB.LargeChange := Max( 1, Round( 0.9*MaxPos*CurSize/MaxSize ) );

    AVSB.OnChange := SavedOnChangePtr;
  end; // else begin // calc Vertical ScrollBar params
end; //*** end of procedure N_SetScrollBarsByRects

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ShiftFRectByScrollBars
//************************************************ N_ShiftFRectByScrollBars ***
// Set given Float Rectangle Position by given Maximal Float Rectangle and 
// ScrollBars positions.
//
//     Parameters
// AMaxFRect - Maximal Float Rectangle inside which is ACurRect
// ACurFRect - resulting Float Rectangle inside AMaxFRect shifted by ScrollBars 
//             positions
// AHSB      - given Horizontal ScrollBar
// AVSB      - given Vertical ScrollBar
//
procedure N_ShiftFRectByScrollBars( const AMaxFRect: TFRect; var ACurFRect: TFRect;
                                                    AHSB, AVSB: TScrollBar );
var
  MaxSize, CurSize: double;
begin
  //***** ScrollBar Position is
  //      between 0 and (Max-PageSize+1) if PageSize <> 0 and
  //      between 0 and Max              if PageSize = 0  !

  // set CurRect.Left, CurRect.Right
  MaxSize := AMaxFRect.Right - AMaxFRect.Left; // Max Width
  CurSize := ACurFRect.Right - ACurFRect.Left; // Cur Width
  ACurFRect.Left := AMaxFRect.Left + (MaxSize-CurSize)*AHSB.Position /
                                                   (AHSB.Max-AHSB.PageSize+1);
  ACurFRect.Right := ACurFRect.Left + CurSize;

  // set CurRect.Top, CurRect.Bottom
  MaxSize := AMaxFRect.Bottom - AMaxFRect.Top; // Max Height
  CurSize := ACurFRect.Bottom - ACurFRect.Top; // Cur Height
  ACurFRect.Top := AMaxFRect.Top + (MaxSize-CurSize)*AVSB.Position /
                                                   (AVSB.Max-AVSB.PageSize+1);
  ACurFRect.Bottom := ACurFRect.Top + CurSize;
end;  //*** end of procedure N_ShiftFRectByScrollBars

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ShiftIRectByScrollBars
//************************************************ N_ShiftIRectByScrollBars ***
// Set given Integer Rectangle Position by given Maximal Integer Rectangle and 
// ScrollBars positions.
//
//     Parameters
// AMaxRect - Maximal Integer Rectangle inside which is ACurRect
// ACurRect - resulting Integer Rectangle inside AMaxRect which should be set by
//            AMaxRect and  ScrollBars positions
// AHSB     - given Horizontal ScrollBar
// AVSB     - given Vertical ScrollBar
//
procedure N_ShiftIRectByScrollBars( const AMaxRect: TRect; var ACurRect: TRect;
                                                       AHSB, AVSB: TScrollBar );
var
  MaxSize, CurSize: integer;
begin
  //***** ScrollBar Position is
  //      between 0 and (Max-PageSize+1) if PageSize <> 0 and
  //      between 0 and Max              if PageSize = 0  !

  // set ACurRect.Left, ACurRect.Right
  MaxSize := AMaxRect.Right - AMaxRect.Left + 1; // Max Width
  CurSize := ACurRect.Right - ACurRect.Left + 1; // Cur Width
  ACurRect.Left := AMaxRect.Left + Round( (MaxSize-CurSize)*AHSB.Position /
                                                   (AHSB.Max-AHSB.PageSize+1) );
  ACurRect.Right := ACurRect.Left + CurSize - 1;

  // Aset CurRect.Top, ACurRect.Bottom
  MaxSize := AMaxRect.Bottom - AMaxRect.Top + 1; // Max Height
  CurSize := ACurRect.Bottom - ACurRect.Top + 1; // Cur Height
  ACurRect.Top := AMaxRect.Top + Round( (MaxSize-CurSize)*AVSB.Position /
                                                   (AVSB.Max-AVSB.PageSize+1) );
  ACurRect.Bottom := ACurRect.Top + CurSize - 1;
end;  //*** end of procedure N_ShiftIRectByScrollBars

//********************************************** N_AddDLineToDLine ***
// add SrcLine to the end of DstLine with given Direction:
// Direction=0 - add with straight direction, =1 - wit reverse direction
//
procedure N_AddDLineToDLine( DstLine: TN_DPArray; var DstLineInd: integer;
                  SrcLine: TN_DPArray; const Direction: integer );
var
  i: integer;
begin
  if (DstLineInd + Length(SrcLine)) > High(DstLine) then
    SetLength( DstLine, 2*DstLineInd + Length(SrcLine)+ 10 );

  if Direction = 0 then
    move( SrcLine[0], DstLine[DstLineInd], Length(SrcLine)*Sizeof(SrcLine[0]) )
  else
    for i := 0 to High(SrcLine) do
      DstLine[DstLineInd+i] := SrcLine[High(SrcLine)-i];
end;  //*** end of procedure N_AddDLineToDLine

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Arctan2
//*************************************************************** N_Arctan2 ***
// Calculate ArcTangent from DY/DX
//
//     Parameters
// ADX, ADY - calculation parameters
// Result   - Returns ArcTangent value from DY/DX in (-PI, PI) interval
//
function N_Arctan2( const ADX, ADY: extended  ): extended;
begin
//  if DX = 0.0 then
//  begin
//    if DY > 0.0 then Result := 0.5*PI
//                else Result := -0.5*PI;
//  end else
    Result := ArcTan2( ADY, ADX );
end; // end of function N_Arctan2

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScalarProduct2
//******************************************************** N_ScalarProduct2 ***
// Calculate scalar product of two vectors given by their Double Coordinates
//
//     Parameters
// ADV1   - First Vector Double Coordinates
// ADV2   - Second Vector Double Coordinates
// Result - Returns scalar product of two vectors = ADV1.X * ADV2.X + ADV1.Y * 
//          ADV2.Y
//
function N_ScalarProduct2( const ADV1, ADV2: TDPoint  ): double;
begin
    Result := ADV1.X*ADV2.X + ADV1.Y*ADV2.Y;
end; // end of function N_ScalarProduct2

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScalarProduct3
//******************************************************** N_ScalarProduct3 ***
// Calculate scalar product of two vectors given by their Double Coordinates and
// End Double Points
//
//     Parameters
// ADV1    - First Vector Double Coordinates
// ADP2Beg - Second Vector Start Double Point
// ADP2End - Second Vector End Double Point
// Result  - Returns scalar product of two vectors = ADV1.X*(ADP2Beg.X - 
//           ADP2End.X) + ADV1.Y*(ADP2Beg.Y - ADP2End.Y)
//
function N_ScalarProduct3( const ADV1, ADP2Beg, ADP2End: TDPoint  ): double;
begin
    Result := ADV1.X*(ADP2Beg.X - ADP2End.X) + ADV1.Y*(ADP2Beg.Y - ADP2End.Y);
end; // end of function N_ScalarProduct3

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ScalarProduct4
//******************************************************** N_ScalarProduct4 ***
// Calculate scalar product of two vectors given by their End Double Points
//
//     Parameters
// ADP1Beg - First Vector Start Double Point
// ADP1End - First Vector End Double Point
// ADP2Beg - Second Vector Start Double Point
// ADP2End - Second Vector End Double Point
// Result  - Returns scalar product of two vectors given by their End Double 
//           Points = (ADP1Beg.X - ADP1End.X)*(ADP2Beg.X - ADP2End.X) + 
//           (ADP1Beg.Y - ADP1End.Y)*(ADP2Beg.Y - ADP2End.Y)
//
function N_ScalarProduct4( const ADP1Beg, ADP1End, ADP2Beg, ADP2End: TDPoint ): double;
begin
    Result := (ADP1Beg.X - ADP1End.X)*(ADP2Beg.X - ADP2End.X) +
              (ADP1Beg.Y - ADP1End.Y)*(ADP2Beg.Y - ADP2End.Y);
end; // end of function N_ScalarProduct4

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_P2PDistance(float)
//**************************************************** N_P2PDistance(float) ***
// Calculate distance between two given Float Points
//
//     Parameters
// AFP1   - First Float Point
// AFP2   - Second Float Point
// Result - Returns distance between two given Points.
//
function N_P2PDistance( const AFP1, AFP2: TFPoint ): double;
begin
  // ***** implemented variant is several percents faster than
  //       dx=x2-x1; dx=dx*dx; dy=y2-y1; dy=dy*dy; result=Sqrt(dx+dy); !

    Result := Sqrt( (AFP1.X-AFP2.X)*(AFP1.X-AFP2.X) + (AFP1.Y-AFP2.Y)*(AFP1.Y-AFP2.Y) );
end; // end of function N_P2PDistance(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_P2PDistance(double)
//*************************************************** N_P2PDistance(double) ***
// Calculate distance between two given Double Points
//
//     Parameters
// ADP1   - First Double Point
// ADP2   - Second Double Point
// Result - Returns distance between two given Points
//
function N_P2PDistance( const ADP1, ADP2: TDPoint ): double;
begin
  // ***** implemented variant is several percents faster than
  //       dx=x2-x1; dx=dx*dx; dy=y2-y1; dy=dy*dy; result=Sqrt(dx+dy); !

    Result := Sqrt( (ADP1.X-ADP2.X)*(ADP1.X-ADP2.X) + (ADP1.Y-ADP2.Y)*(ADP1.Y-ADP2.Y) );
end; // end of function N_P2PDistance(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_P2SDistance(float)
//**************************************************** N_P2SDistance(float) ***
// Calculate distance between given Float Point and Float Segment
//
//     Parameters
// AFP    - Float Point
// AFPBeg - Segment Start Float Point
// AFPEnd - Segment End Float Point
// Result - Returns distance between given Point and Segment
//
function N_P2SDistance( const AFP, AFPBeg, AFPEnd: TFPoint ): double;
var
  Norm, R1, R2: double;
  Ort, Segm, PPBeg, PPEnd: TDPoint;
begin
  Segm.X  := AFPEnd.X - AFPBeg.X;
  Segm.Y  := AFPEnd.Y - AFPBeg.Y;

  PPBeg.X := AFPBeg.X - AFP.X;
  PPBeg.Y := AFPBeg.Y - AFP.Y;

  PPEnd.X := AFPEnd.X - AFP.X;
  PPEnd.Y := AFPEnd.Y - AFP.Y;

  R1 := PPBeg.X*Segm.X + PPBeg.Y*Segm.Y;
  R2 := PPEnd.X*Segm.X + PPEnd.Y*Segm.Y;

  if R1*R2 < 0 then // projection of P on segment is inside segment
  begin
    Ort.X :=  Segm.Y; // Ort is perpendicular to (PBeg, PEnd)
    Ort.Y := -Segm.X;
    Norm := Sqrt( Ort.X*Ort.X + Ort.Y*Ort.Y );
    Result := (Ort.X*PPBeg.X + Ort.Y*PPBeg.Y) / Norm;
    if Result < 0 then Result := -Result;
  end else //********* projection of P on segment is outside of segment
  begin
    if R1 >= 0 then
      Result := Sqrt((AFP.X-AFPBeg.X)*(AFP.X-AFPBeg.X)+(AFP.Y-AFPBeg.Y)*(AFP.Y-AFPBeg.Y))
    else
      Result := Sqrt((AFP.X-AFPEnd.X)*(AFP.X-AFPEnd.X)+(AFP.Y-AFPEnd.Y)*(AFP.Y-AFPEnd.Y));
  end;
end; // end of function N_P2SDistance(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_P2SDistance(double)
//*************************************************** N_P2SDistance(double) ***
// Calculate distance between given Double Point and Double Segment
//
//     Parameters
// ADP    - Double Point
// ADPBeg - Segment Start Double Point
// ADPEnd - Segment End Double Point
// Result - Returns distance between given Point and Segment
//
function N_P2SDistance( const ADP, ADPBeg, ADPEnd: TDPoint ): double;
var
  Norm, R1, R2: double;
  Ort, Segm, PPBeg, PPEnd: TDPoint;
begin
  Segm.X  := ADPEnd.X - ADPBeg.X;
  Segm.Y  := ADPEnd.Y - ADPBeg.Y;

  PPBeg.X := ADPBeg.X - ADP.X;
  PPBeg.Y := ADPBeg.Y - ADP.Y;

  PPEnd.X := ADPEnd.X - ADP.X;
  PPEnd.Y := ADPEnd.Y - ADP.Y;

  R1 := PPBeg.X*Segm.X + PPBeg.Y*Segm.Y;
  R2 := PPEnd.X*Segm.X + PPEnd.Y*Segm.Y;

  if R1*R2 < 0 then // projection of P on segment is inside segment
  begin
    Ort.X :=  Segm.Y; // Ort is perpendicular to (PBeg, PEnd)
    Ort.Y := -Segm.X;
    Norm := Sqrt( Ort.X*Ort.X + Ort.Y*Ort.Y );
    Result := (Ort.X*PPBeg.X + Ort.Y*PPBeg.Y) / Norm;
    if Result < 0 then Result := -Result;
  end else //********* projection of P on segment is outside of segment
  begin
    if R1 >= 0 then
      Result := Sqrt((ADP.X-ADPBeg.X)*(ADP.X-ADPBeg.X)+(ADP.Y-ADPBeg.Y)*(ADP.Y-ADPBeg.Y))
    else
      Result := Sqrt((ADP.X-ADPEnd.X)*(ADP.X-ADPEnd.X)+(ADP.Y-ADPEnd.Y)*(ADP.Y-ADPEnd.Y));
  end;
end; // end of function N_P2SDistance(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_P2LSDistance
//********************************************************** N_P2LSDistance ***
// Calculate Signed distance between given Double Point ADP and given Straight Line (ADPBeg,ADPEnd)
//
//     Parameters
// ADP    - given Double Point
// ADPBeg - some point on given Straight Line
// ADPEnd - some another point on given Straight Line
// Result - Return distance between given Point ADP and given Straight Line (ADPBeg,ADPEnd)
//
// Straight Line is given by two Points (APDBeg,APDEnd) on it.
//
function N_P2LSDistance( const ADP, ADPBeg, ADPEnd: TDPoint ): double;
var
  Norm: double;
  Ort, V: TDPoint;
begin
  V.X := ADPBeg.X - ADP.X;
  V.Y := ADPBeg.Y - ADP.Y;

  Ort.X := ADPEnd.Y - ADPBeg.Y; // Ort is perpendicular to (PBeg, PEnd)
  Ort.Y := ADPBeg.X - ADPEnd.X;

  Norm := Sqrt( Ort.X*Ort.X + Ort.Y*Ort.Y );

  if Norm = 0 then
    Result := 0
  else
    Result := (Ort.X*V.X + Ort.Y*V.Y) / Norm;
end; // end of function N_P2LSDistance

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_P2LDistance
//*********************************************************** N_P2LDistance ***
// Calculate distance between given Double Point and Double PolyLine
//
//     Parameters
// ADP           - Double Point
// ALineDCoords  - PolyLine given as array of Double Point
// ALineEnvFRect - PolyLine Envelope Float Rectangle
// AMaxDistance  - Maximal distance between Double Point and Double Polyline
// ASegmInd      - Index of Polyline nearest segment
// Result        - Returns distance between given Point and PolyLine
//
// If distance is greater than given AMaxDistance, than return value
// 1.1*AMaxDistance. If ALineEnvRect.Left equals N_NotAFloat, then ALineEnvRect
// should be recalculated before use.
//
function N_P2LDistance( const ADP: TDPoint; ALineDCoords: TN_DPArray;
                       const ALineEnvFRect: TFRect; const AMaxDistance: double;
                                              out ASegmInd: integer  ): double;
var
  i: integer;
  R: double;
  EnvRect: TFRect;
begin
  EnvRect := ALineEnvFRect;
  Result := 1.1*AMaxDistance;
  ASegmInd := -1; // not defined

  if ALineEnvFRect.Left = N_NotAFloat then
    EnvRect := N_CalcLineEnvRect( ALineDCoords, 0, Length(ALineDCoords) );

  if ((EnvRect.Left   - ADP.X) > AMaxDistance) or
     ((EnvRect.Top    - ADP.Y) > AMaxDistance) or
     ((ADP.X - EnvRect.Right ) > AMaxDistance) or
     ((ADP.Y - EnvRect.Bottom) > AMaxDistance) then Exit; // real distance > MaxDistance

  for i := 0 to High(ALineDCoords)-1 do
  begin
    R := N_P2SDistance( ADP, ALineDCoords[i], ALineDCoords[i+1] );
    if R < Result then
    begin
      Result := R;
      ASegmInd := i;
    end;
  end;

end; // end of function N_P2LDistance

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AddFcoordsToFCoords
//*************************************************** N_AddFcoordsToFCoords ***
// Add given Float Points to the end of given Float Points
//
//     Parameters
// AResFCoords - resulting Float Points given as Float Points Array
// AAddFCoords - adding Float Points given as Float Points Array
// AOrder      - adding points order (=0 - straight order, <>0 - revers order)
//
// If AResFCoords last point is the same to first adding point then it should be
// omitted.
//
procedure N_AddFcoordsToFCoords( var AResFCoords: TN_FPArray;
                                 const AAddFCoords: TN_FPArray; AOrder: integer );
var
  i, k, InitialResLength, HighAddCoords: integer;
begin
  InitialResLength := Length(AResFCoords);
  if InitialResLength = 0 then k := 0
                          else k := 1;

  HighAddCoords := High(AAddFCoords);
  if AOrder = 0 then // straight order
  begin
    if (k = 1) and not N_Same( AResFCoords[High(AResFCoords)],
                               AAddFCoords[0] ) then k := 0;
    SetLength( AResFCoords, InitialResLength + HighAddCoords + 1 - k );

    move( AAddFCoords[k], AResFCoords[InitialResLength],
                                 (Length(AAddFCoords)-k)*Sizeof(AResFCoords[0]) );
  end else // reverse order
  begin
    if (k = 1) and  not N_Same( AResFCoords[High(AResFCoords)],
                                AAddFCoords[High(AAddFCoords)] ) then k := 0;
    SetLength( AResFCoords, InitialResLength + HighAddCoords + 1 - k );

    for i := 0 to HighAddCoords-k do //
      AResFCoords[InitialResLength+i] := AAddFCoords[HighAddCoords-i-k];
  end;
end; // end of procedure N_AddFcoordsToFCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AddDcoordsToDCoords
//*************************************************** N_AddDcoordsToDCoords ***
// Add given Double Points to the end of given Double Points
//
//     Parameters
// AResDCoords - resulting Double Points given as Double Points Array
// AAddDCoords - adding Double Points given as Double Points Array
// AOrder      - adding points order (=0 - straight order, <>0 - revers order)
//
// If AResDCoords last point is the same to first adding point then it should be
// omitted.
//
procedure N_AddDcoordsToDCoords( var AResDCoords: TN_DPArray;
                            const AAddDCoords: TN_DPArray; AOrder: integer );
var
  i, k, InitialResLength, HighAddCoords: integer;
begin
  InitialResLength := Length(AResDCoords);
  if InitialResLength = 0 then k := 0
                          else k := 1;

  HighAddCoords := High(AAddDCoords);
  if AOrder = 0 then // straight order
  begin
    if (k = 1) and not N_Same( AResDCoords[High(AResDCoords)],
                               AAddDCoords[0] ) then k := 0;
    SetLength( AResDCoords, InitialResLength + HighAddCoords + 1 - k );

    move( AAddDCoords[k], AResDCoords[InitialResLength],
                                 (Length(AAddDCoords)-k)*Sizeof(AResDCoords[0]) );
  end else // reverse order
  begin
    if (k = 1) and  not N_Same( AResDCoords[High(AResDCoords)],
                                AAddDCoords[High(AAddDCoords)] ) then k := 0;
    SetLength( AResDCoords, InitialResLength + HighAddCoords + 1 - k );

    for i := 0 to HighAddCoords-k do //
      AResDCoords[InitialResLength+i] := AAddDCoords[HighAddCoords-i-k];
  end;

end; // end of procedure N_AddDcoordsToDCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_MakeFRectBorder(float)
//************************************************ N_MakeFRectBorder(float) ***
// Make closed Float PolyLine with 5 vertexes from given Float Rectangle
//
//     Parameters
// ALineFCoords - resulting 5 vertex Polyline as Float Points Array
// ARect        - source Float Rectangle
//
procedure N_MakeFRectBorder( var ALineFCoords: TN_FPArray; ARect: TFRect );
begin
  SetLength( ALineFCoords, 5 );
  with ARect do
  begin
    ALineFCoords[0] := TopLeft;
    ALineFCoords[1] := FPoint( Right, Top );
    ALineFCoords[2] := BottomRight;
    ALineFCoords[3] := FPoint( Left, Bottom );
    ALineFCoords[4] := TopLeft;
  end;
end; // end of procedure N_MakeFRectBorder(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_MakeFRectBorder(double)
//*********************************************** N_MakeFRectBorder(double) ***
// Make closed Double PolyLine with 5 vertexes from given Float Rectangle
//
//     Parameters
// ALineDCoords - resulting 5 vertex Polyline as Double Points Array
// ARect        - source Float Rectangle
//
procedure N_MakeFRectBorder( var ALineDCoords: TN_DPArray; ARect: TFRect );
begin
  SetLength( ALineDCoords, 5 );
  with ARect do
  begin
    ALineDCoords[0] := DPoint(TopLeft);
    ALineDCoords[1] := DPoint( Right, Top );
    ALineDCoords[2] := DPoint(BottomRight);
    ALineDCoords[3] := DPoint( Left, Bottom );
    ALineDCoords[4] := DPoint(TopLeft);
  end;
end; // end of procedure N_MakeFRectBorder(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_GetMaxAbsCoord(FPoint)
//************************************************ N_GetMaxAbsCoord(FPoint) ***
// Get Maximal Absolute coordinate in given Float Points Array
//
//     Parameters
// AFPCoords - given Float Points Array
// Result    - Returns Maximal Absolute coordinate
//
function N_GetMaxAbsCoord( AFPCoords: TN_FPArray ): double;
var
  i: integer;
  Z: float;
begin
  Result := 0;
  for i := 0 to High(AFPCoords) do //
  begin
    Z := Abs(AFPCoords[i].X);
    if Z > Result then Result := Z;
    Z := Abs(AFPCoords[i].Y);
    if Z > Result then Result := Z;
  end; //
end; // end of function N_GetMaxAbsCoord(FPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_GetMaxAbsCoord(DPoint)
//************************************************ N_GetMaxAbsCoord(DPoint) ***
// Get Maximal Absolute coordinate in given Double Points Array
//
//     Parameters
// ADPCoords - given Double Points Array
// Result    - Returns Maximal Absolute coordinate
//
function N_GetMaxAbsCoord( ADPCoords: TN_DPArray ): double;
var
  i: integer;
  Z: double;
begin
  Result := 0;
  for i := 0 to High(ADPCoords) do //
  begin
    Z := Abs(ADPCoords[i].X);
    if Z > Result then Result := Z;
    Z := Abs(ADPCoords[i].Y);
    if Z > Result then Result := Z;
  end; //
end; // end of function N_GetMaxAbsCoord(DPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_GetMaxAbsCoord(FRect)
//************************************************* N_GetMaxAbsCoord(FRect) ***
// Get Maximal Absolute coordinate in given Float Rectangles Array
//
//     Parameters
// AFRCoords - given Float Rectangles Array
// Result    - Returns Maximal Absolute coordinate
//
function N_GetMaxAbsCoord( AFRCoords: TN_FRArray ): double;
var
  i: integer;
  Z: float;
begin
  Result := 0;
  for i := 0 to High(AFRCoords) do //
  begin
    Z := Abs(AFRCoords[i].Left);
    if Z > Result then Result := Z;
    Z := Abs(AFRCoords[i].Top);
    if Z > Result then Result := Z;
    Z := Abs(AFRCoords[i].Right);
    if Z > Result then Result := Z;
    Z := Abs(AFRCoords[i].Bottom);
    if Z > Result then Result := Z;
  end; //
end; // end of function N_GetMaxAbsCoord(FRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_GetMaxAbsCoord(DRect)
//************************************************* N_GetMaxAbsCoord(DRect) ***
// Get Maximal Absolute coordinate in given Double Rectangles Array
//
//     Parameters
// ADRCoords - given Double Rectangles Array
// Result    - Returns Maximal Absolute coordinate
//
function N_GetMaxAbsCoord( ADRCoords: TN_DRArray ): double;
var
  i: integer;
  Z: double;
begin
  Result := 0;
  for i := 0 to High(ADRCoords) do //
  begin
    Z := Abs(ADRCoords[i].Left);
    if Z > Result then Result := Z;
    Z := Abs(ADRCoords[i].Top);
    if Z > Result then Result := Z;
    Z := Abs(ADRCoords[i].Right);
    if Z > Result then Result := Z;
    Z := Abs(ADRCoords[i].Bottom);
    if Z > Result then Result := Z;
  end; //
end; // end of function N_GetMaxAbsCoord(DRect)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_LSegmLengths(array)
//*************************************************** N_LSegmLengths(array) ***
// —alculate given Double Polyline Segments increasing Lengths
//
//     Parameters
// ADLine        - given Polyline as Double Points Array
// ALSegmLengths - resulting array of calculated Polyline Segments increasing 
//                 Lengths
//
// Each ALSegmLengths elemnt is calculate as ALSegmLengths[i] := 
// ALSegmLengths[i-1] + Length(Vertex[i-1], Vertex[i]). ALSegmLengths first 
// elemnt is always 0.
//
procedure N_LSegmLengths( ADLine: TN_DPArray; var ALSegmLengths: TN_DArray );
var
  i, OldLength, NumPoints: integer;
  DX, DY: double;
begin
  NumPoints := Length( ADLine );
  OldLength := Length( ALSegmLengths );
  if OldLength < NumPoints then
    SetLength( ALSegmLengths, N_NewLength( OldLength, NumPoints ) );

  ALSegmLengths[0] := 0;
  for i := 1 to NumPoints-1 do //
  begin
    DX := ADLine[i].X - ADLine[i-1].X;
    DY := ADLine[i].Y - ADLine[i-1].Y;
    ALSegmLengths[i] := ALSegmLengths[i-1] + Sqrt( DX*DX + DY*DY );
  end; // for i := 1 to NumPoints-1 do //
end; // end of procedure N_LSegmLengths(array)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_LSegmLengths(pointer)
//************************************************* N_LSegmLengths(pointer) ***
// —alculate given Double Polyline Segments increasing Lengths
//
//     Parameters
// APDPoints     - pointer to given Double Polyline first vertex
// ANumPoints    - number of vertexes in given Polyline
// ALSegmLengths - resulting array of calculated Polyline Segments increasing 
//                 Lengths
//
// Each ALSegmLengths elemnt is calculate as ALSegmLengths[i] := 
// ALSegmLengths[i-1] + Length(Vertex[i-1], Vertex[i]). ALSegmLengths first 
// elemnt is always 0.
//
procedure N_LSegmLengths( APDPoints: PDPoint; ANumPoints: integer;
                                                var ALSegmLengths: TN_DArray );
var
  i, OldLength: integer;
  DX, DY: double;
begin
  OldLength := Length( ALSegmLengths );
  if OldLength < ANumPoints then
    SetLength( ALSegmLengths, N_NewLength( OldLength, ANumPoints ) );

  ALSegmLengths[0] := 0;
  for i := 1 to ANumPoints-1 do //
  begin
    DX := -APDPoints^.X;
    DY := -APDPoints^.Y;
    Inc(APDPoints);
    DX := DX + APDPoints^.X;
    DY := DY + APDPoints^.Y;
    ALSegmLengths[i] := ALSegmLengths[i-1] + Sqrt( DX*DX + DY*DY );
  end; // for i := 1 to NumPoints-1 do //
end; // end of procedure N_LSegmLengths(pointer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_SegmToSegmPDistance
//*************************************************** N_SegmToSegmPDistance ***
// Calcucale Segment to Segment Parametric Distance
//
//     Parameters
// ASB1   - first segment begin Double Point
// ASE1   - first segment end Double Point
// ASB2   - second segment begin Double Point
// ASE2   - second segment end Double Point
// Result - Returns parametric distance betwen two Double Segmnets
//
// Segments to Segment Parametric Distance is calculate as minimal distance 
// between Segments related parametric points.
//
function N_SegmToSegmPDistance( AS1B, AS1E, AS2B, AS2E: TDPoint ): double;
var
  t, SDD: double;
  a, b, c: TDPoint;
begin
  // calc some auxiliary vectors (coefs)
  a.X := AS1B.X - AS2B.X;
  a.Y := AS1B.Y - AS2B.Y;
  b.X := AS1E.X - AS2E.X - a.X;
  b.Y := AS1E.Y - AS2E.Y - a.Y;

  SDD := b.X*b.X + b.Y*b.Y; // Square of Derivate Denominator

  if SDD < N_Eps then // S1 is parallel to S2 and have same length
    t := 0 // any t between 0 and 1 is OK
  else
  begin
    t := -( a.X*b.X + a.Y*b.Y ) / SDD; // optimal t (with minimal distance)
    if t <= 0 then t := 0
    else if t >= 1.0 then t := 1.0;
  end;

  c.X := a.X + t * b.X;
  c.Y := a.Y + t * b.Y;
  Result := Sqrt( c.X*c.X + c.Y*c.Y );
end; // end of function N_SegmToSegmPDistance

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ChordToLinePDistance
//************************************************** N_ChordToLinePDistance ***
// Calcucale Chord to corresponding Polyline fragment Parametric Distance
//
//     Parameters
// ADLine        - given Polyline as Double Points Array
// ALSegmLengths - given array of calculated Polyline Segments increasing 
//                 Lengths
// ABegInd       - given Polyline fagment begin vertex index
// AEndInd       - given Polyline fagment end vertex index
// Result        - Returns Parametric Distance between Polyline fragment and 
//                 corresponding Chord
//
// Chord to Polyline fragmet [ABegInd, AEndInd] is segment (ADLine[ABegInd], 
// ADLine[AEndInd]). Parametric Distance is calculated as maximal Paramentric 
// Distance between Polyline fragment Segments and corresponding Chord 
// fragments.
//
function N_ChordToLinePDistance( ADLine: TN_DPArray; ALSegmLengths: TN_DArray;
                                           ABegInd, AEndInd: integer ): double;
var
  i: integer;
  BegPoint, BegSegmPoint, EndSegmPoint: TDPoint;
  BegLength, FragmentLength, t, ChordDX, ChordDY, Dist: double;
begin
  Assert( (ABegInd >= 0) and( ABegInd < (AEndInd+1)) and (AEndInd <= High(ADLine)),
                                                        'Bad Line Indexes!' );
  BegPoint := ADLine[ABegInd];
  BegLength := ALSegmLengths[ABegInd];
  FragmentLength := ALSegmLengths[AEndInd] - BegLength;
  ChordDX := ADLine[AEndInd].X - BegPoint.X;
  ChordDY := ADLine[AEndInd].Y - BegPoint.Y;
  Result := 0;
  EndSegmPoint := BegPoint; // just to begin loop

  for i := ABegInd+1 to AEndInd do
  begin
    BegSegmPoint := EndSegmPoint;
    t := (ALSegmLengths[i] - BegLength) / FragmentLength;
    EndSegmPoint.X := BegPoint.X + t*ChordDX;
    EndSegmPoint.Y := BegPoint.Y + t*ChordDY;
    Dist := N_SegmToSegmPDistance( BegSegmPoint, EndSegmPoint,
                                   ADLine[i-1], ADLine[i] );
    if Dist > Result then Result := Dist;
  end; // for i := BegInd+1 to EndInd do

end; // end of function N_ChordToLinePDistance

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ChordToLinePNorm
//****************************************************** N_ChordToLinePNorm ***
// Calcucale Chord To corresponding Polyline fragment Parametric Norm
//
//     Parameters
// ADLine        - given Polyline as Double Points Array
// ALSegmLengths - given array of calculated Polyline Segments increasing 
//                 Lengths
// ABegInd       - given Polyline fagment begin vertex index
// AEndInd       - given Polyline fagment end vertex index
// Result        - Returns parametric distance between Polyline fragment and 
//                 corresponding Chord
//
// Chord to Polyline fragmet [ABegInd, AEndInd] is segment (ADLine[ABegInd], 
// ADLine[AEndInd]). Parametric Norm is calculated as maximal distance between 
// Polyline fragment Vertexes and corresponding Chord Points.
//
function N_ChordToLinePNorm( ADLine: TN_DPArray; ALSegmLengths: TN_DArray;
                                           ABegInd, AEndInd: integer ): double;
var
  i: integer;
  BegPoint: TDPoint;
  BegLength, FragmentLength, t, ChordDX, ChordDY, Dist, DX, DY: double;
begin
  Assert( (ABegInd >= 0) and( ABegInd < (AEndInd+1)) and (AEndInd <= High(ADLine)),
                                                        'Bad Line Indexes!' );
  BegPoint := ADLine[ABegInd];
  BegLength := ALSegmLengths[ABegInd];
  FragmentLength := ALSegmLengths[AEndInd] - BegLength;
  Assert( FragmentLength > 0, 'Vertex coordinates are the same!' );
//  if FragmentLength = 0 then
//    N_i := 1;
  ChordDX := ADLine[AEndInd].X - BegPoint.X;
  ChordDY := ADLine[AEndInd].Y - BegPoint.Y;
  Result := 0;

  for i := ABegInd+1 to AEndInd-1 do
  begin
    t := (ALSegmLengths[i] - BegLength) / FragmentLength;
    DX := BegPoint.X + t*ChordDX - ADLine[i].X;
    DY := BegPoint.Y + t*ChordDY - ADLine[i].Y;

    Dist := Sqrt( DX*DX + DY*DY );
    if Dist > Result then Result := Dist;
  end; // for i := BegInd+1 to EndInd do

end; // end of function N_ChordToLinePNorm

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DecNumberOfLinePoints1
//************************************************ N_DecNumberOfLinePoints1 ***
// Create new Double Polyline from given Double Polyline by removing vertexes, 
// that are nearer then given Delta
//
//     Parameters
// AInpDLine - given Polyline as Double Points Array
// AOutDLine - resulting Polyline as Double Points Array
// ADelta    - compression parameter
// Result    - Returns number of removed vertexes or -1 if no vertexes can be 
//             removed (one segment Polyline or three segments closed Polyline).
//
// This routine is variant 1 of Polyline compression algorithm. Should be used 
// before N_DecNumberOfLinePoints2 or N_DecNumberOfLinePoints3.
//
function N_DecNumberOfLinePoints1( AInpDLine: TN_DPArray; var AOutDLine: TN_DPArray;
                                                    ADelta: double ): integer;
var
  i, j, NLinePoints: integer;
begin
  NLinePoints := Length( AInpDLine );
  SetLength( AOutDLine, NLinePoints );
  AOutDLine[0] := AInpDLine[0];

  if NLinePoints = 2 then // one segment Line
  begin
    AOutDLine[1] := AInpDLine[1];
    Result := -1;
    Exit;
  end;

  if NLinePoints = 4 then
    if (AInpDLine[0].X = AInpDLine[3].X) and (AInpDLine[0].Y = AInpDLine[3].Y) then
    begin // three segments closed Line
      AOutDLine[1] := AInpDLine[1];
      AOutDLine[2] := AInpDLine[2];
      AOutDLine[3] := AInpDLine[3];
      Result := -1;
      Exit;
    end;

  j := 1;
  for i := 1 to NLinePoints-2 do
  begin
    if ADelta < N_P2PDistance( AInpDLine[j-1], AInpDLine[i] ) then
    begin
      AOutDLine[j] := AInpDLine[i];
      Inc(j);
    end;
  end;
  AOutDLine[j] := AInpDLine[NLinePoints-1];
  Inc(j);
  SetLength( AOutDLine, j );
  Result := NLinePoints - j;
end; // end of function N_DecNumberOfLinePoints1

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DecNumberOfLinePoints2
//************************************************ N_DecNumberOfLinePoints2 ***
// Create new Double Polyline from given Double Polyline by removing some 
// vertexes so, that parametric distance between new segmnet and removing 
// Polyline fragment should be less than given Delta
//
//     Parameters
// AInpDLine - given Polyline as Double Points Array
// AOutDLine - resulting Polyline as Double Points Array
// ADelta    - compression parameter
// Result    - Returns number of removed vertexes or -1 if no vertexes can be 
//             removed (one segment Polyline or three segments closed Polyline).
//
// This routine is variant 2 of Polyline compression algorithm. Should be used 
// before N_DecNumberOfLinePoints2 or N_DecNumberOfLinePoints3.
//
function N_DecNumberOfLinePoints2( AInpDLine: TN_DPArray; var AOutDLine: TN_DPArray;
                                                    ADelta: double ): integer;
var
  i, j, k, NLinePoints: integer;
  Dist: double;
  LSegmLengths: TN_DArray;
  Label RemovePoints;
begin
  NLinePoints := Length( AInpDLine );
  SetLength( AOutDLine, NLinePoints );
  AOutDLine[0] := AInpDLine[0];

  if NLinePoints = 2 then // one segment Line
  begin
    AOutDLine[1] := AInpDLine[1];
    Result := -1;
    Exit;
  end;

  if NLinePoints = 4 then
    if (AInpDLine[0].X = AInpDLine[3].X) and (AInpDLine[0].Y = AInpDLine[3].Y) then
    begin // three segments closed Line
      AOutDLine[1] := AInpDLine[1];
      AOutDLine[2] := AInpDLine[2];
      AOutDLine[3] := AInpDLine[3];
      Result := -1;
      Exit;
    end;

  N_LSegmLengths( AInpDLine, LSegmLengths );

  i := 1; // index of first point - candidat for removing
  k := 1; // index of first point to add to NewLine

  while i < NLinePoints-1 do
  begin
    // try to remove max. points. beginning  from i-th
    for j := 1 to NLinePoints-i-1  do // j - number of points to remove
    begin                             //       (i, i+1, ... ,i+j-1)
      Dist := N_ChordToLinePNorm( AInpDLine, LSegmLengths, i-1, i+j );
      if Dist > ADelta then goto RemovePoints;
    end; // for j := 1 to NLinePoints-i-1  do // j - number of points to remove

    // Here: remove NLinePoints-i-1 points
    j := NLinePoints-i;

    RemovePoints : // remove j-1 points
    AOutDLine[k] := AInpDLine[i+j-1];
    Inc(k);
    Inc( i, j );
    if i = NLinePoints-1 then // add last point
    begin
      AOutDLine[k] := AInpDLine[NLinePoints-1]; // last point
      Inc(k);
      Break;
    end;
  end; // while i < NLinePoints-1 do

  SetLength( AOutDLine, k );
  Result := NLinePoints - k;
end; // end of function N_DecNumberOfLinePoints2

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DecNumberOfLinePoints3
//************************************************ N_DecNumberOfLinePoints3 ***
// Create new Double Polyline from given Double Polyline by removing some 
// vertexes using several calls to N_DecNumberOfLinePoints2
//
//     Parameters
// AInpDLine  - given Polyline as Double Points Array
// AOutDLine  - resulting Polyline as Double Points Array
// AMode      - compression mode (not used now)
// AMinDelta  - initial Delta parameter of N_DecNumberOfLinePoints2
// AMaxDelta  - final Deleta param of N_DecNumberOfLinePoints2
// ADeltaCoef - coefficient by wich real Delta increases
// Result     - Returns number of passes (number of N_DecNumberOfLinePoints2 
//              calls).
//
function N_DecNumberOfLinePoints3( const AInpDLine: TN_DPArray;
                                    var AOutDLine: TN_DPArray; AMode: integer;
                              AMinDelta, AMaxDelta, ADeltaCoef: double ): integer;
var
  NumRemoved: integer;
  Dist: double;
  TmpLine1, TmpLine2: TN_DPArray;
begin
  Result := 0;

  //*** remove too small segments (less then 0.01*MinDelta)
  NumRemoved := N_DecNumberOfLinePoints1( AInpDLine, TmpLine1, 0.01*AMinDelta );

  if NumRemoved = -1 then
  begin
    AOutDLine := TmpLine1; // resulting output Line
    Exit;
  end;

  Dist := AMinDelta;

  while Dist < AMaxDelta do // outer loop - increasing Dist by Coef
  begin
    while True do // internal loop with same Dist
    begin
      Inc(Result);
      NumRemoved := N_DecNumberOfLinePoints2( TmpLine1, TmpLine2, Dist );

      if NumRemoved = -1 then
      begin
        AOutDLine := TmpLine2; // resulting output Line
        Exit;
      end;

      if NumRemoved =  0 then Break;

      AOutDLine  := TmpLine1; // swap pointers
      TmpLine1 := TmpLine2;
      TmpLine2 := AOutDLine;
    end; // while True do // internal loop with same Dist

    Dist := Dist * ADeltaCoef; // increase Dist
    AOutDLine  := TmpLine1; // swap pointers
    TmpLine1 := TmpLine2;
    TmpLine2 := AOutDLine;
  end; // while Dist < MaxDelta do // outer loop - increasing Dist by Coef

  AOutDLine := TmpLine1; // resulting output Line
end; // end of function N_DecNumberOfLinePoints3

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_MinLineSegmsSize
//****************************************************** N_MinLineSegmsSize ***
// Calculate for given Double Polyline minimal nonzero Segment Length and 
// increment number of Segments with zero Length
//
//     Parameters
// ADLine       - given Polyline as Double Points Array
// AMinSegmSize - minimal nonzero Segment Length
// ANumZeros    - resulting number of Segments with zero Length
//
// ANumZeros is incremented by number of Segments with zero Length for given 
// Polyline.
//
procedure N_MinLineSegmsSize( const ADLine: TN_DPArray;
                              var AMinSegmSize: double; var ANumZeros: integer );
var
  i: integer;
  d: double;
begin
  for i := 0 to High(ADLine)-1 do
  begin
    d := N_P2PDistance( ADLine[i], ADLine[i+1] );
    if d = 0      then Inc(ANumZeros) else
    if d < AMinSegmSize then AMinSegmSize := d;
  end;
end; // end of procedure N_MinLineSegmsSize

//************************************************** N_GetLineInfo ***
// calculate minimal segment size (stricly > 0) of given Line and change
// MinSegmSize param if calculated size size is less then given
// add to NumZeros varible number of zero size segments
//
procedure N_GetLineInfo( const Line: TN_DPArray;
                  var MinSegmSize, MaxSegmSize: double; var NumZeros: integer );
var
  i: integer;
  d: double;
begin
  for i := 0 to High(Line)-1 do
  begin
    d := N_P2PDistance( Line[i], Line[i+1] );
    if d = 0      then Inc(NumZeros) else
    if d < MinSegmSize then MinSegmSize := d;
  end;
end; // end of procedure N_GetLineInfo

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AddLineSegmsStat
//****************************************************** N_AddLineSegmsStat ***
// Calculate given Double Polyline segments distribution by it length
//
//     Parameters
// ADLine        - given Polyline as Double Points Array
// ANumIntervals - number of distribution intrevals
// AMaxSize      - distribution parameter
// ANumSegms     - resulting segments distribution as integer array of segments 
//                 counts for each interval.
//
// ANumSegms array length shoud be not less than ANumIntervals. ANumIntervals 
// should be not less than 3. Resulting ANumSegments[0] contains number of 
// Segments with zero Length. Resulting ANumSegments[ANumIntervals - 1] contains
// number of Segments with Length greater than AMaxSize. Other (ANumIntervals - 
// 2) elements of resulting ANumSegments array contains number of Segments in 
// intervals
//#F
//(                           0,  AMaxSize/(ANumIntervals - 2)), 
//(AMaxSize/(ANumIntervals - 2), 2*AMaxSize/(ANumIntervals - 2)) 
//... 
//etc.
//#/F
//
procedure N_AddLineSegmsStat( const ADLine: TN_DPArray; ANumIntervals: integer;
                                  const AMaxSize: double; ANumSegms: TN_IArray );
var
  i, IntervalInd: integer;
  d: double;
begin
  if ANumSegms[0] = N_NotAnInteger then // clear NumSegms
    for i := 0 to ANumIntervals-1 do ANumSegms[i] := 0;

  for i := 0 to High(ADLine)-1 do
  begin
    d := N_P2PDistance( ADLine[i], ADLine[i+1] );
    if d = 0       then Inc(ANumSegms[0]) else
    if d > AMaxSize then Inc(ANumSegms[ANumIntervals-1])
    else
    begin
      IntervalInd := Round(Floor((d/AMaxSize)*(ANumIntervals-2))) + 1;
      Inc(ANumSegms[IntervalInd]);
    end;
  end; // for i := 0 to High(Line)-1 do
end; // end of procedure N_AddLineSegmsStat

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PointToStr_(INT)
//****************************************************** N_PointToStr (INT) ***
// Convert given Integer Point to text using format string
//
//     Parameters
// APoint - source Integer Point
// AFmt   - convertion format string
// Result - Returns string with converted APoint value
//
function N_PointToStr( const APoint: TPoint; AFmt: string = '' ): string;
begin
  if APoint.X = N_NotAnInteger then
    Result := 'NoValue'
  else with APoint do
  begin
    if AFmt = '' then AFmt := '%d %d';
    Result := Format( AFmt, [X, Y] );
  end
end; // end of function N_PointToStr (INT)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PointToStr_(FLOAT_Fmt)
//************************************************ N_PointToStr (FLOAT_Fmt) ***
// Convert given Float Point to text using format string
//
//     Parameters
// AFPoint - source Float Point
// AFmt    - convertion format string
// Result  - Returns string with converted AFPoint value
//
function N_PointToStr( const AFPoint: TFPoint; AFmt: string = '' ): string;
begin
  if AFPoint.X = N_NotAnInteger then
    Result := 'NoValue'
  else with AFPoint do
  begin
    if AFmt = '' then AFmt := '%.5g %.5g';
    Result := Format( AFmt, [X, Y] );
  end
end; // end of function N_PointToStr (FLOAT_Fmt)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PointToStr(FLOAT_Acc)
//************************************************* N_PointToStr(FLOAT_Acc) ***
// Convert given Float Point to text using given accuracy
//
//     Parameters
// AFPoint   - source Float Point
// AAccuracy - convertion accuracy
// Result    - Returns string with converted AFPoint value
//
function N_PointToStr( const AFPoint: TFPoint; AAccuracy: integer ): string;
var
  FmtStr: string;
begin
  FmtStr := '%.' + IntToStr(AAccuracy) + 'f';
  FmtStr := FmtStr+' '+FmtStr;
  Result := N_PointToStr( AFPoint, FmtStr );
end; // end of function N_PointToStr(FLOAT_Acc)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PointToStr_(DBL_Fmt)
//************************************************** N_PointToStr (DBL_Fmt) ***
// Convert given Double Point to text using format string
//
//     Parameters
// ADPoint - source Double Point
// AFmt    - convertion format string
// Result  - Returns string with converted ADPoint value
//
function N_PointToStr( const ADPoint: TDPoint; AFmt: string = '' ): string;
begin
  if ADPoint.X = N_NotADouble then
    Result := 'NoValue'
  else with ADPoint do
  begin
    if AFmt = '' then AFmt := '%.5g %.5g';
    Result := Format( AFmt, [X, Y] );
  end
end; // end of function N_PointToStr (DBL_Fmt)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PointToStr(DBL_Acc)
//*************************************************** N_PointToStr(DBL_Acc) ***
// Convert given Double Point to text using given accuracy
//
//     Parameters
// ADPoint   - source Double Point
// AAccuracy - convertion accuracy
// Result    - Returns string with converted ADPoint value
//
function N_PointToStr( const ADPoint: TDPoint; AAccuracy: integer ): string;
var
  FmtStr: string;
begin
  FmtStr := '%.' + IntToStr(AAccuracy) + 'f';
  FmtStr := FmtStr+'  '+FmtStr;
  Result := N_PointToStr( ADPoint, FmtStr );
end; // end of function N_PointToStr(DBL_Acc)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectToStr(INT)
//******************************************************** N_RectToStr(INT) ***
// Convert given Integer Rectangle to text using format string
//
//     Parameters
// ARect  - source Integer Rectangle
// AFmt   - convertion format string
// Result - Returns string with converted ARect value
//
function N_RectToStr( const ARect: TRect; AFmt: string = '' ): string;
begin
  if ARect.Left = N_NotAnInteger then
    Result := 'NoValue'
  else with ARect do begin
    if AFmt = '' then AFmt := '%d %d %d %d';
    Result := Format( AFmt, [Left, Top, Right, Bottom] );
  end
end; // end of function N_RectToStr(INT)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectToStr(FLOAT_Fmt)
//************************************************** N_RectToStr(FLOAT_Fmt) ***
// Convert given Float Rectangle to text using format string
//
//     Parameters
// AFRect - source FLoat Rectangle
// AFmt   - convertion format string
// Result - Returns string with converted AFRect value
//
function N_RectToStr( const AFRect: TFRect; AFmt: string = '' ): string;
begin
  if AFRect.Left = N_NotAFloat then
    Result := 'NoValue'
  else with AFRect do begin
    if AFmt = '' then AFmt := '%.5g %.5g   %.5g %.5g';
    Result := Format( AFmt, [Left, Top, Right, Bottom] );
  end
end; // end of function N_RectToStr(FLOAT_Fmt)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectToStr(FLOAT_Acc)
//************************************************** N_RectToStr(FLOAT_Acc) ***
// Convert given Float Rectangle to text using given Accuracy
//
//     Parameters
// AFRect    - source FLoat Rectangle
// AAccuracy - convertion Accuracy
// Result    - Returns string with converted AFRect value
//
function N_RectToStr( const AFRect: TFRect; AAccuracy: integer ): string;
var
  FmtStr: string;
begin
  FmtStr := ' %.' + IntToStr(AAccuracy) + 'f ';
  FmtStr := FmtStr+FmtStr + '  ' + FmtStr+FmtStr;
  SetLength( FmtStr, Length(FmtStr)-1 ); // delete ending space
  Result := N_RectToStr( AFRect, FmtStr );
end; // end of function N_RectToStr(FLOAT_Acc)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectToStr(DBL)
//******************************************************** N_RectToStr(DBL) ***
// Convert given Double Rectangle to text using format string
//
//     Parameters
// ADRect - source Double Rectangle
// AFmt   - convertion format string
// Result - Returns string with converted ADRect value
//
function N_RectToStr( const ADRect: TDRect; AFmt: string = '' ): string;
begin
  if ADRect.Left = N_NotADouble then
    Result := 'NoValue'
  else with ADRect do begin
    if AFmt = '' then AFmt := '%.5g %.5g   %.5g %.5g';
    Result := Format( AFmt, [Left, Top, Right, Bottom] );
  end
end; // end of function N_RectToStr(DBL)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectToStr2(FLOAT_Fmt)
//************************************************* N_RectToStr2(FLOAT_Fmt) ***
// Convert given Float Rectangle to text with Width and Height using format 
// string
//
//     Parameters
// AFRect - source FLoat Rectangle
// AFmt   - convertion format string
// Result - Returns string with converted AFRect value containing Width and 
//          Height
//
function N_RectToStr2( const AFRect: TFRect; AFmt: string = '' ): string;
begin
  if AFRect.Left = N_NotAFloat then
    Result := 'NoValue'
  else with AFRect do begin
    if AFmt = '' then AFmt := '%.5g %.5g   %.5g %.5g';
    Result := Format( AFmt, [Left, Top, Right-Left, Bottom-Top] );
  end
end; // end of function N_RectToStr2(FLOAT_Fmt)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RectToStr2(FLOAT_Acc)
//************************************************* N_RectToStr2(FLOAT_Acc) ***
// Convert given Float Rectangle to text with Width and Height using given 
// Accuracy
//
//     Parameters
// AFRect    - source FLoat Rectangle
// AAccuracy - convertion Accuracy
// Result    - Returns string with converted AFRect value containing Width and 
//             Height
//
function N_RectToStr2( const AFRect: TFRect; AAccuracy: integer ): string;
var
  FmtStr: string;
begin
  FmtStr := ' %.' + IntToStr(AAccuracy) + 'f ';
  FmtStr := FmtStr+FmtStr + '  ' + FmtStr+FmtStr;
  SetLength( FmtStr, Length(FmtStr)-1 ); // delete ending space
  Result := N_RectToStr2( AFRect, FmtStr );
end; // end of function N_RectToStr2(FLOAT_Acc)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DoublesToStr
//********************************************************** N_DoublesToStr ***
// Convert given Doubles to text using given Accuracy
//
//     Parameters
// APDoubles   - pointer to converting Doubles
// ANumDoubles - number of converting Doubles
// AAccuracy   - convertion Accuracy
// Result      - Returns string with converted Doubles
//
function N_DoublesToStr( APDoubles: PDouble; ANumDoubles, AAccuracy: integer ): string;
var
  i: integer;
  FmtStr: string;
begin
  Result := '';
  FmtStr := '%.' + IntToStr( AAccuracy ) + 'g ';

  for i := 0 to ANumDoubles do // along given Doubles
  begin
    Result := Result + Format( FmtStr, [APDoubles^] );
    Inc( APDoubles );
  end; // for i := 0 to ANumDoubles do // along given Doubles

end; // end of function N_DoublesToStr

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AffCoefs6ToStr
//******************************************************** N_AffCoefs6ToStr ***
// Convert given Six Affine Transformation Coefficients to text using given 
// Accuracy
//
//     Parameters
// AAffCoefs6 - Six Affine Transformation Coefficients
// AAccuracy  - convertion Accuracy
// Result     - Returns string with converted Six Affine Transformation 
//              Coefficients
//
function N_AffCoefs6ToStr( const AAffCoefs6: TN_AffCoefs6; AAccuracy: integer ): string;
begin
  Result := N_DoublesToStr( PDouble(@AAffCoefs6), 6, AAccuracy );
end; // end of function N_AffCoefs6ToStr

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DPArrayToStr
//********************************************************** N_DPArrayToStr ***
// Convert given Double Polyline to text
//
//     Parameters
// ADPLine   - given Polyline as Double Points Array
// APointFmt - format string for one Double Point (two coordinates) convertion
// Result    - Returns string with converted Polyline coordinates.
//
// Resulting string contains comma separated Polyline vertexes coordinates.
//
function N_DPArrayToStr( const ADPLine: TN_DPArray; APointFmt: string ): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to High(ADPLine) do
  begin
    Result := Result + Format( APointFmt, [ADPLine[i].X, ADPLine[i].Y] );
  end;
end; // end of function N_DPArrayToStr

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IArrayToStr
//*********************************************************** N_IArrayToStr ***
// Convert given Integers to text
//
//     Parameters
// AIArray - given Integers as Integer Array
// AIntFmt - format string for one Integer value convertion
// Result  - Returns string with converted Integers.
//
function N_IArrayToStr( const AIArray: TN_IArray; AIntFmt: string ): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to High(AIArray) do
  begin
    Result := Result + Format( AIntFmt, [ AIArray[i] ] );
  end;
end; // end of function N_IArrayToStr

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ConvIntToInt
//********************************************************** N_ConvIntToInt ***
// Convert given Integer to Integer by given convertion table
//
//     Parameters
// ASrcIntValue - given Integer value
// AConvTable   - convertion table as Integer Points Array
// Result       - Returns converted Integer value.
//
// Resulting Integer value is Y field of convertion table where given Integer 
// value is X field.
//
function N_ConvIntToInt( ASrcIntValue: integer; AConvTable: TN_IPArray ): integer;
var
  i: integer;
begin
  for i := 0 to High(AConvTable) do
  begin
    if ASrcIntValue = AConvTable[i].X then
    begin
      Result := AConvTable[i].Y;
      Exit;
    end;
  end;
  Result := ASrcIntValue; // if not found
end; // end of function N_ConvIntToInt

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_WriteLineCoords(float)
//************************************************ N_WriteLineCoords(float) ***
// Add Float Polyline coordinates to Strings
//
//     Parameters
// AStrings  - resulting Strings
// AAccuracy - convertion Accuracy (not used now)
// AFPLine   - given Polyline as Float Points Array
//
// Polyline start string contains number of vertexes in adding Polyline. Each 
// vertex is add to separate string. Polyline terminated by "End" string.
//
procedure N_WriteLineCoords( AStrings: TStrings; AAccuracy: integer;
                                             var AFPLine: TN_FPArray );
var i: integer;
begin
  AStrings.Add( Format( '    %d  (number of points)', [ Length(AFPLine) ] ) );
  for i := 0 to High(AFPLine) do
  begin
    AStrings.Add( Format( ' %.2d  %g %g ', [ i, AFPLine[i].X, AFPLine[i].Y ] ) );
  end;
  AStrings.Add( 'End' );
end; // end of procedure N_WriteLineCoords(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_WriteLineCoords(double)
//*********************************************** N_WriteLineCoords(double) ***
// Add Double Polyline coordinates to Strings
//
//     Parameters
// AStrings  - resulting Strings
// AAccuracy - convertion Accuracy
// AFPLine   - given Polyline as Double Points Array
//
// Polyline start string contains number of vertexes in adding Polyline. Each 
// vertex is add to separate string. Polyline terminated by "End" string.
//
procedure N_WriteLineCoords( AStrings: TStrings; AAccuracy: integer;
                                             var ADPLine: TN_DPArray );
var i: integer;
begin
  AStrings.Add( Format( '    %d  (number of points)', [ Length(ADPLine) ] ) );
  for i := 0 to High(ADPLine) do
  begin
    AStrings.Add( Format( ' %.2d  %g %g ', [ i, ADPLine[i].X, ADPLine[i].Y ] ) );
  end;
  AStrings.Add( 'End' );
end; // end of procedure N_WriteLineCoords(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ReadLineCoords(float)
//************************************************* N_ReadLineCoords(float) ***
// Get Float Polyline from given Strings position
//
//     Parameters
// AStrings - given Strings
// ASInd    - given Strings current position (current string index), resulting 
//            value shows on the "End" string
// AFPLine  - resulting Polyline as Float Points Array
//
// Strings start position (ASInd) shows on the string previous to first Polyline
// vertex string.
//
procedure N_ReadLineCoords( AStrings: TStrings; var ASInd: integer;
                                                var AFPLine: TN_FPArray );
var
  Str: string;
  ic, Size: integer;
begin
  Inc(ASInd); // skip line with number of points
  if Length( AFPLine ) < 1000 then SetLength( AFPLine, 1000 );
  Size := Length( AFPLine );
  ic := 0;
  while True do
  begin
    if Size < ic+1 then
    begin
      SetLength( AFPLine, Round(1.5*Size) );
      Size := Length( AFPLine );
    end;
    Str := AStrings[ASInd];
    if Copy( Str, 1, 3 ) = 'End' then break; // end of line coords
    N_ScanInteger( Str ); // skip vertex number
    AFPLine[ic].X := N_ScanFloat( Str );
    AFPLine[ic].Y := N_ScanFloat( Str );
    Inc(ic); Inc(ASInd);
  end; // end of while True do
  SetLength( AFPLine, ic );
end; // end of procedure N_ReadLineCoords(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ReadLineCoords(double)
//************************************************ N_ReadLineCoords(double) ***
// Get Double Polyline from given Strings position
//
//     Parameters
// AStrings - given Strings
// ASInd    - given Strings current position (current string index), resulting 
//            value shows on the "End" string
// ADPLine  - resulting Polyline as Double Points Array
//
// Strings start position (ASInd) shows on the string previous to first Polyline
// vertex string.
//
procedure N_ReadLineCoords( AStrings: TStrings; var ASInd: integer;
                                                var ADPLine: TN_DPArray );
var
  Str: string;
  ic, Size: integer;
begin
  Inc(ASInd); // skip line with number of points
  if Length( ADPLine ) < 1000 then SetLength( ADPLine, 1000 );
  Size := Length( ADPLine );
  ic := 0;
  while True do
  begin
    if Size < ic+1 then
    begin
      SetLength( ADPLine, Round(1.5*Size) );
      Size := Length( ADPLine );
    end;
    Str := AStrings[ASInd];
    if Copy( Str, 1, 3 ) = 'End' then break; // end of line coords
    N_ScanInteger( Str ); // skip vertex number
    ADPLine[ic].X := N_ScanDouble( Str );
    ADPLine[ic].Y := N_ScanDouble( Str );
    Inc(ic); Inc(ASInd);
  end; // end of while True do
  SetLength( ADPLine, ic );
end; // end of procedure N_ReadLineCoords(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AddOneRect
//************************************************************ N_AddOneRect ***
// Add new Integer Rectangle to given Array
//
//     Parameters
// ARects    - array of Integer Rectangles (first ANumRects elements are 
//             occupied)
// ANumRects - number of occupied elements in ARects (on input and output)
// ANewRect  - new Rectangle to add to ARects array
//
procedure N_AddOneRect( var ARects: TN_IRArray; var ANumRects: integer;
                                                              ANewRect: TRect );
begin
  if High(ARects) < ANumRects then SetLength( ARects, ANumRects+1 );
  ARects[ANumRects] := ANewRect;
  Inc(ANumRects);
end; //*** end of procedure N_AddOneRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AddSegmRect
//*********************************************************** N_AddSegmRect ***
// Add new Integer Rectangle, that should cover all pixels of given Segment, 
// drawn by given PixPenWidth, to given Array
//
//     Parameters
// AP1, AP2     - given segment vertexes integer (pixel) coordinates
// ARects       - array of Integer Rectangles (first ANumRects elements are 
//                occupied)
// ANumRects    - number of occupied elements in ARects (on input and output)
// APixPenWidth - pen pixel width
//
procedure N_AddSegmRect( AP1, AP2: TPoint; var ARects: TN_IRArray;
                              var ANumRects: integer; APixPenWidth: integer );
var
  HalfWidth: integer;
begin
  //***** Temporary version
  HalfWidth := APixPenWidth div 2 + 2;
  if High(ARects) < ANumRects then SetLength( ARects, ANumRects+1 );

  if AP1.X < AP2.X then
  begin
    ARects[ANumRects].Left  := AP1.X - HalfWidth;
    ARects[ANumRects].Right := AP2.X + HalfWidth;
  end else
  begin
    ARects[ANumRects].Left  := AP2.X - HalfWidth;
    ARects[ANumRects].Right := AP1.X + HalfWidth;
  end;

  if AP1.Y < AP2.Y then
  begin
    ARects[ANumRects].Top    := AP1.Y - HalfWidth;
    ARects[ANumRects].Bottom := AP2.Y + HalfWidth;
  end else
  begin
    ARects[ANumRects].Top    := AP2.Y - HalfWidth;
    ARects[ANumRects].Bottom := AP1.Y + HalfWidth;
  end;

  Inc(ANumRects);
end; //*** end of procedure N_AddSegmRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_AddLineRect
//*********************************************************** N_AddLineRect ***
// Add new Integer Rectangle, that should cover all pixels of given Polyline, 
// drawn by given PixPenWidth, to given Array
//
//     Parameters
// ALine        - integer (pixel) Polyline coordinates
// ANumPoints   - number of using Line Vertexes
// ARects       - array of Integer Rectangles (first ANumRects elements are 
//                occupied)
// ANumRects    - number of occupied elements in ARects (on input and output)
// APixPenWidth - pen pixel width
//
procedure N_AddLineRect( ALine: TN_IPArray; ANumPoints: integer;
           var ARects: TN_IRArray; var ANumRects: integer; APixPenWidth: integer );
var
  HalfWidth: integer;
begin
  //***** Temporary version
  HalfWidth := APixPenWidth div 2 + 2;
  if High(ARects) < ANumRects then SetLength( ARects, ANumRects+1 );

  ARects[ANumRects] := N_CalcLineEnvRect( ALine, ANumPoints );
  Dec( ARects[ANumRects].Left,   HalfWidth );
  Dec( ARects[ANumRects].Top,    HalfWidth );
  Inc( ARects[ANumRects].Right,  HalfWidth );
  Inc( ARects[ANumRects].Bottom, HalfWidth );

  Inc(ANumRects);
end; //*** end of procedure N_AddLineRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RemoveRects
//*********************************************************** N_RemoveRects ***
// Remove Integer Rectangles from given Array
//
//     Parameters
// ARects    - array of Integer Rectangles (first ANumRects elements are 
//             occupied)
// ANumRects - number of occupied elements in ARects (on input and output)
// ABegInd   - first Array element index to remove
// AEndInd   - last  Array element index to remove
//
procedure N_RemoveRects( var ARects: TN_IRArray; var ANumRects: integer;
                                                    ABegInd, AEndInd: integer );
begin
  if ABegInd >= ANumRects then Exit; // a precaution
  if AEndInd >= ANumRects then AEndInd := ANumRects - 1; // a precaution
  if ABegInd < 0 then ABegInd := ANumRects + ABegInd;
  if AEndInd < 0 then AEndInd := ANumRects + AEndInd;
  if ABegInd > AEndInd then Exit;
  if AEndInd < (ANumRects-1) then // move rects after EndInd
    move( ARects[AEndInd+1], ARects[ABegInd], (ANumRects-AEndInd-1)*Sizeof(TRect) );
  ANumRects := ANumRects - (AEndInd - ABegInd + 1); // resulting number of Rects
end; //*** end of procedure N_RemoveRects

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_RemoveVertexes
//******************************************************** N_RemoveVertexes ***
// Remove elements with given indexes from given Double Points array
//
//     Parameters
// ADPoints - array of Double Points
// ABegInd  - first Array element index to remove
// AEndInd  - last  Array element index to remove
//
procedure N_RemoveVertexes( var ADPoints: TN_DPArray; ABegInd, AEndInd: integer );
var
  MaxInd: integer;
begin
  MaxInd := High(ADPoints);
  if ABegInd > MaxInd then Exit; // a precaution
  if AEndInd > MaxInd then AEndInd := MaxInd; // a precaution
  if ABegInd > AEndInd then Exit;
  if AEndInd < MaxInd then // move Vertexes after EndInd
    move( ADPoints[AEndInd+1], ADPoints[ABegInd], (MaxInd-AEndInd)*Sizeof(TDPoint) );
  SetLength( ADPoints, MaxInd - (AEndInd-ABegInd) );
end; //*** end of procedure N_RemoveVertexes

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_InsertVertex
//********************************************************** N_InsertVertex ***
// Insert new Double Point into given Double Points array
//
//     Parameters
// ADPoints - array of Double Points
// ADVertex - new Double Point
// AInd     - insert index
//
procedure N_InsertVertex( var ADPoints: TN_DPArray;
                                       ADVertex: TDPoint; AVertInd: integer );
var
  Leng: integer;
begin
  Leng := Length(ADPoints);
  if AVertInd > Leng then Exit; // a precaution
  SetLength( ADPoints, Leng+1 );
  if AVertInd < Leng then // move Vertexes after VertInd
    move( ADPoints[AVertInd], ADPoints[AVertInd+1], (Leng-AVertInd)*Sizeof(TDPoint) );
  ADPoints[AVertInd] := ADVertex;
end; //*** end of procedure N_InsertVertex

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ProjectPointOnSegm
//**************************************************** N_ProjectPointOnSegm ***
// Calculate coordinates of Point on given Double Segment, nearest to given 
// Double Point (get projection of point ADP on segment (ADP1, ADP2))
//
//     Parameters
// ADP        - given Double Point
// ADP1, ADP2 - given Double Segment Vertexes coordinates
// Result     - Returns Double Point nearest to ADP
//
function N_ProjectPointOnSegm( ADP, ADP1, ADP2: TDPoint ): TDPoint;
var
  P21X, P21Y, Norm, R: double;
begin
  P21X :=ADP2.X - ADP1.X;
  P21Y := ADP2.Y - ADP1.Y;
  Norm := P21X*P21X + P21Y*P21Y;
  R := ( (ADP.Y-ADP1.Y)*P21Y - (ADP1.X-ADP.X)*P21X ) / Norm;
  
  if R <= 0 then Result := ADP1
  else if R >= 1 then Result := ADP2
  else
  begin
    Result.X := ADP1.X + R*P21X;
    Result.Y := ADP1.Y + R*P21Y;
  end;
end; //*** end of function N_ProjectPointOnSegm

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ProjectPointOnRect
//**************************************************** N_ProjectPointOnRect ***
// Calculate coordinates of Point on given Integer Rectangle, nearest to given 
// Integer Point (get projection of point APoint on Rectangle ARect)
//
//     Parameters
// ARect  - given Integer Rectangle
// APoint - given Integer Point
// Result - Returns Integer Point nearest to APoint
//
function N_ProjectPointOnRect( ARect: TRect; APoint: TPoint ): TPoint;
begin
  Result := APoint;

  if APoint.X < ARect.Left  then Result.X := ARect.Left;
  if APoint.X > ARect.Right then Result.X := ARect.Right;

  if APoint.Y < ARect.Top    then Result.Y := ARect.Top;
  if APoint.Y > ARect.Bottom then Result.Y := ARect.Bottom;
end; //*** end of function N_ProjectPointOnRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ReverseDoubles
//******************************************************** N_ReverseDoubles ***
// Reverse given array of Doubles
//
//     Parameters
// ADoubles - given Doubles Array
//
procedure N_ReverseDoubles( ADoubles: TN_DArray );
var
  i, IMax: integer;
begin
  IMax := High(ADoubles);
  for i := 0 to (IMax div 2) do
  begin
    N_d := ADoubles[i];
    ADoubles[i] := ADoubles[IMax-i];
    ADoubles[IMax-i] := N_d;
  end;
end; //*** end of procedure N_ReverseDoubles

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ReversePoints
//********************************************************* N_ReversePoints ***
// Reverse given array of Double Points
//
//     Parameters
// ADPoints - given Double Points Array
//
procedure N_ReversePoints( ADPoints: TN_DPArray );
var
  i, IMax: integer;
  Ptmp: TDPoint;
begin
  IMax := High(ADPoints);
  for i := 0 to (IMax div 2) do
  begin
    Ptmp := ADPoints[i];
    ADPoints[i] := ADPoints[IMax-i];
    ADPoints[IMax-i] := Ptmp;
  end;
end; //*** end of procedure N_ReversePoints(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DPointFmt(float)
//****************************************************** N_DPointFmt(float) ***
// Build format string for printing Double Point coordinates
//
//     Parameters
// AFEnvRect - envelope Float Rectangle
// AAccuracy - number of digits after decimal point
// Result    - Returns format string for printing Double Point coordinates
//
function N_DPointFmt( AFEnvRect: TFRect; AAccuracy: integer ): string;
var
  NDigBeforePoint: Integer;
  DTmp: double;
  Fmt: string;
begin
  DTmp := N_RectMaxCoord( AFEnvRect );
  if Dtmp < 1 then Dtmp := 1;
  NDigBeforePoint := integer(Ceil(Log10( Dtmp )));
  Fmt := '%' + Format( '%d.%df', [NDigBeforePoint+AAccuracy+2, AAccuracy] );
  Result := Fmt + '  ' + Fmt;
end; // function N_DPointFmt(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_MaxCoordsChars
//******************************************************** N_MaxCoordsChars ***
// Calculate max length of resulting string while convert double value with 
// given accuracy Return Max Number of Characters for converting coordinates to 
// Str (without any space delimeters but with possible '-' sign)
//
//     Parameters
// AFEnvRect - envelope Float Rectangle
// AAccuracy - number of digits after decimal point
// Result    - Returns resulting string max length
//
// Resulting string length calculates with possible '-' sign but without any 
// space delimeters.
//
function N_MaxCoordsChars( AFEnvRect: TFRect; AAccuracy: integer ): integer;
var
  NDigBeforePoint: Integer;
  DTmp: double;
begin
  DTmp := N_RectMaxCoord( AFEnvRect );
  if Dtmp < 1 then Dtmp := 1;
  NDigBeforePoint := integer(Ceil(Log10( Dtmp )));
  if AAccuracy = 0 then Result := NDigBeforePoint + 1
                   else Result := NDigBeforePoint + 2 + AAccuracy;
end; // function N_MaxCoordsChars(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DPointFmt(double)
//***************************************************** N_DPointFmt(double) ***
// Build format string for printing Double Point coordinates
//
//     Parameters
// ADEnvRect - envelope Double Rectangle
// AAccuracy - number of digits after decimal point
// Result    - Returns format string for printing Double Point coordinates
//
function N_DPointFmt( ADEnvRect: TDRect; AAccuracy: integer ): string;
var
  NDigBeforePoint: Integer;
  DTmp: double;
//  Fmt: Ansistring;
  Fmt: string;
begin
  DTmp := N_RectMaxCoord( ADEnvRect );
  if Dtmp < 1 then Dtmp := 1;
  NDigBeforePoint := integer(Ceil(Log10( Dtmp )));
  Fmt := '%' + Format( '%d.%df', [NDigBeforePoint+AAccuracy+2, AAccuracy] );
  Result := Fmt + '  ' + Fmt;
end; // function N_DPointFmt(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FillArray(FPoint)
//***************************************************** N_FillArray(FPoint) ***
// Fill Float Points Array by values of geometric progression
//
//     Parameters
// AFPArray    - Float Points Array
// AStartValue - progression Float Point start value
// AStep       - progression Float Point step
// ANumValues  - number of Values (AFPArray length will be increased if needed)
// AFirstInd   - first AFPArray element to fill index
//
procedure N_FillArray( var AFPArray : TN_FPArray; AStartValue, AStep: TFPoint;
                                     ANumVals: integer; AFirstInd: integer = 0 );
var
  i, NeededSize: integer;
begin
  NeededSize := AFirstInd+ANumVals;
  if Length(AFPArray) < NeededSize then SetLength( AFPArray, NeededSize );

  for i := 0 to ANumVals-1 do
  begin
    AFPArray[AFirstInd+i].X := AStartValue.X + i*AStep.X;
    AFPArray[AFirstInd+i].Y := AStartValue.Y + i*AStep.Y;
  end;
end; // procedure N_FillArray(FPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FillArray(DPoint)
//***************************************************** N_FillArray(DPoint) ***
// Fill Double Points Array by values of geometric progression
//
//     Parameters
// ADPArray    - Double Points Array
// AStartValue - progression Double Point start value
// AStep       - progression Double Point step
// ANumValues  - number of Values (ADPArray length will be increased if needed)
// AFirstInd   - first ADPArray element to fill index
//
procedure N_FillArray( var ADPArray: TN_DPArray; AStartValue, AStep: TDPoint;
                                     ANumVals: integer; AFirstInd: integer = 0 );
var
  i, NeededSize: integer;
begin
  NeededSize := AFirstInd+ANumVals;
  if Length(ADPArray) < NeededSize then SetLength( ADPArray, NeededSize );

  for i := 0 to ANumVals-1 do
  begin
    ADPArray[AFirstInd+i].X := AStartValue.X + i*AStep.X;
    ADPArray[AFirstInd+i].Y := AStartValue.Y + i*AStep.Y;
  end;
end; // procedure N_FillArray(DPoint)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DeleteArrayElems(IPoints)
//********************************************* N_DeleteArrayElems(IPoints) ***
// Delete Integer Points Array elements
//
//     Parameters
// APArray   - Integer Points Array
// ABegInd   - first deleting Array element index
// ANumElems - number of deleting elements
//
procedure N_DeleteArrayElems( var APArray: TN_IPArray; ABegInd, ANumElems: integer );
var
  MoveSize: integer;
begin
  if APArray = nil then Exit;
  Assert( (AbegInd >= 0 ) and (AbegInd <= High(APArray)), 'Bad ABegInd!' );
  if (ABegInd + ANumElems - 1) > High(APArray) then
    ANumElems := High(APArray) - ABegInd + 1;

  MoveSize := (High(APArray)-ABegInd-ANumElems+1)*Sizeof(APArray[0]);
  if MoveSize > 0 then
    move( APArray[ABegInd + ANumElems], APArray[ABegInd], MoveSize );
  SetLength( APArray, Length(APArray)-ANumElems );
end; // procedure N_DeleteArrayElems(IPoints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DeleteArrayElems(FPoints)
//********************************************* N_DeleteArrayElems(FPoints) ***
// Delete Float Points Array elements
//
//     Parameters
// AFPArray  - Float Points Array
// ABegInd   - first deleting Array element index
// ANumElems - number of deleting elements
//
procedure N_DeleteArrayElems( var AFPArray: TN_FPArray; ABegInd, ANumElems: integer );
var
  MoveSize: integer;
begin
  if AFPArray = nil then Exit;
  Assert( (AbegInd >= 0 ) and (AbegInd <= High(AFPArray)), 'Bad ABegInd!' );
  if (ABegInd + ANumElems - 1) > High(AFPArray) then
    ANumElems := High(AFPArray) - ABegInd + 1;

  MoveSize := (High(AFPArray)-ABegInd-ANumElems+1)*Sizeof(AFPArray[0]);
  if MoveSize > 0 then
    move( AFPArray[ABegInd + ANumElems], AFPArray[ABegInd], MoveSize );
  SetLength( AFPArray, Length(AFPArray)-ANumElems );
end; // procedure N_DeleteArrayElems(FPoints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DeleteArrayElems(DPoints)
//********************************************* N_DeleteArrayElems(DPoints) ***
// Delete Double Points Array elements
//
//     Parameters
// ADPArray  - Double Points Array
// ABegInd   - first deleting Array element index
// ANumElems - number of deleting elements
//
procedure N_DeleteArrayElems( var ADPArray: TN_DPArray; ABegInd, ANumElems: integer );
var
  MoveSize: integer;
begin
  if ADPArray = nil then Exit;
  Assert( (AbegInd >= 0 ) and (AbegInd <= High(ADPArray)), 'Bad ABegInd!' );
  if (ABegInd + ANumElems - 1) > High(ADPArray) then
    ANumElems := High(ADPArray) - ABegInd + 1;

  MoveSize := (High(ADPArray)-ABegInd-ANumElems+1)*Sizeof(ADPArray[0]);
  if MoveSize > 0 then
    move( ADPArray[ABegInd + ANumElems], ADPArray[ABegInd], MoveSize );
  SetLength( ADPArray, Length(ADPArray)-ANumElems );
end; // procedure N_DeleteArrayElems(DPoints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DeleteArrayElems(FRects)
//********************************************** N_DeleteArrayElems(FRects) ***
// Delete Float Rectangles Array elements
//
//     Parameters
// AFRArray  - Float Rectangles Array
// ABegInd   - first deleting Array element index
// ANumElems - number of deleting elements
//
procedure N_DeleteArrayElems( var AFRArray: TN_FRArray; ABegInd, ANumElems: integer );
var
  MoveSize: integer;
begin
  if AFRArray = nil then Exit;
  Assert( (AbegInd >= 0 ) and (AbegInd <= High(AFRArray)), 'Bad ABegInd!' );
  if (ABegInd + ANumElems - 1) > High(AFRArray) then
    ANumElems := High(AFRArray) - ABegInd + 1;

  MoveSize := (High(AFRArray)-ABegInd-ANumElems+1)*Sizeof(AFRArray[0]);
  if MoveSize > 0 then
    move( AFRArray[ABegInd + ANumElems], AFRArray[ABegInd], MoveSize );
  SetLength( AFRArray, Length(AFRArray)-ANumElems );
end; // procedure N_DeleteArrayElems(FRects)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_InsertArrayElems(IPoints)
//********************************************* N_InsertArrayElems(IPoints) ***
// Insert Integer Points to given Array
//
//     Parameters
// ADstArray  - destination Integer Points Array
// ADstBegInd - index of first inserting element in destination array, (if =-1 
//              or > High(DstArray) then new elements should be append to 
//              destination array
// ASrcArray  - source Integer Points Array
// ASrcBegInd - index of first inserting element in source array 
//              (ADstArray[ADstBegInd] = ASrcArray[ASrcBegInd])
// ANumElems  - number of inserting elements, if =-1, than insert all source 
//              array elements starting from ASrcBegInd
//
procedure N_InsertArrayElems( var ADstArray: TN_IPArray; ADstBegInd: integer;
                      ASrcArray: TN_IPArray; ASrcBegInd, ANumElems: integer );
var
  MoveSize: integer;
begin
//  if DstArray = nil then Exit;
  if (ADstBegInd < 0) or (ADstBegInd > High(ADstArray)) then
    ADstBegInd := Length(ADstArray);

  if ASrcArray <> nil then
  begin
    if (ANumElems < 0) or ((ASrcBegInd + ANumElems - 1) > High(ASrcArray)) then
      ANumElems := High(ASrcArray) - ASrcBegInd + 1;
  end else // SrcArray is not given
    if ANumElems < 0 then Exit;

  SetLength( ADstArray, Length(ADstArray)+ANumElems ); // increase DstArray
  MoveSize := (Length(ADstArray)-ADstBegInd-ANumElems)*Sizeof(ADstArray[0]);

  if MoveSize > 0 then // items are inserted inside (not added after)
    move( ADstArray[ADstBegInd], ADstArray[ADstBegInd + ANumElems], MoveSize );

  if ASrcArray <> nil then
    move( ASrcArray[ASrcBegInd], ADstArray[ADstBegInd], ANumElems*Sizeof(ADstArray[0]) );
end; // procedure N_InsertArrayElems(IPoints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_InsertArrayElems(FPoints)
//********************************************* N_InsertArrayElems(FPoints) ***
// Insert Float Points to given Array
//
//     Parameters
// ADstFPArray - destination Float Points Array
// ADstBegInd  - index of first inserting element in destination array, (if =-1 
//               or > High(DstArray) then new elements should be append to 
//               destination array
// ASrcFPArray - source Float Points Array
// ASrcBegInd  - index of first inserting element in source array 
//               (ADstFPArray[ADstBegInd] = ASrcFPArray[ASrcBegInd])
// ANumElems   - number of inserting elements, if =-1, than insert all source 
//               array elements starting from ASrcBegInd
//
procedure N_InsertArrayElems( var ADstFPArray: TN_FPArray; ADstBegInd: integer;
                      ASrcFPArray: TN_FPArray; ASrcBegInd, ANumElems: integer );
var
  MoveSize: integer;
begin
//  if DstArray = nil then Exit;
  if (ADstBegInd < 0) or (ADstBegInd > High(ADstFPArray)) then
    ADstBegInd := Length(ADstFPArray);

  if ASrcFPArray <> nil then
  begin
    if (ANumElems < 0) or ((ASrcBegInd + ANumElems - 1) > High(ASrcFPArray)) then
      ANumElems := High(ASrcFPArray) - ASrcBegInd + 1;
  end else // SrcArray is not given
    if ANumElems < 0 then Exit;

  SetLength( ADstFPArray, Length(ADstFPArray)+ANumElems ); // increase DstArray
  MoveSize := (Length(ADstFPArray)-ADstBegInd-ANumElems)*Sizeof(ADstFPArray[0]);

  if MoveSize > 0 then // items are inserted inside (not added after)
    move( ADstFPArray[ADstBegInd], ADstFPArray[ADstBegInd + ANumElems], MoveSize );

  if ASrcFPArray <> nil then
    move( ASrcFPArray[ASrcBegInd], ADstFPArray[ADstBegInd], ANumElems*Sizeof(ADstFPArray[0]) );
end; // procedure N_InsertArrayElems(FPoints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_InsertArrayElems(DPoints)
//********************************************* N_InsertArrayElems(DPoints) ***
// Insert Double Points to given Array
//
//     Parameters
// ADstDPArray - destination Double Points Array
// ADstBegInd  - index of first inserting element in destination array, (if =-1 
//               or > High(DstArray) then new elements should be append to 
//               destination array
// ASrcDPArray - source Double Points Array
// ASrcBegInd  - index of first inserting element in source array 
//               (ADstDPArray[ADstBegInd] = ASrcDPArray[ASrcBegInd])
// ANumElems   - number of inserting elements, if =-1, than insert all source 
//               array elements starting from ASrcBegInd
//
procedure N_InsertArrayElems( var ADstDPArray: TN_DPArray; ADstBegInd: integer;
                      ASrcDPArray: TN_DPArray; ASrcBegInd, ANumElems: integer );
var
  MoveSize: integer;
begin
//  if DstArray = nil then Exit;
  if (ADstBegInd < 0) or (ADstBegInd > High(ADstDPArray)) then
    ADstBegInd := Length(ADstDPArray);

  if ASrcDPArray <> nil then
  begin
    if (ANumElems < 0) or ((ASrcBegInd + ANumElems - 1) > High(ASrcDPArray)) then
      ANumElems := High(ASrcDPArray) - ASrcBegInd + 1;
  end else // SrcArray is not given
    if ANumElems < 0 then Exit;

  SetLength( ADstDPArray, Length(ADstDPArray)+ANumElems ); // increase DstArray
  MoveSize := (Length(ADstDPArray)-ADstBegInd-ANumElems)*Sizeof(ADstDPArray[0]);

  if MoveSize > 0 then // items are inserted inside (not added after)
    move( ADstDPArray[ADstBegInd], ADstDPArray[ADstBegInd + ANumElems], MoveSize );

  if ASrcDPArray <> nil then
    move( ASrcDPArray[ASrcBegInd], ADstDPArray[ADstBegInd], ANumElems*Sizeof(ADstDPArray[0]) );
end; // procedure N_InsertArrayElems(DPoints)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_InsertArrayElems(FRects)
//********************************************** N_InsertArrayElems(FRects) ***
// Insert Float Rectangles to given Array
//
//     Parameters
// ADstFRArray - destination Float Rectangles Array
// ADstBegInd  - index of first inserting element in destination array, (if =-1 
//               or > High(DstArray) then new elements should be append to 
//               destination array
// ASrcFRArray - source Float Rectangles Array
// ASrcBegInd  - index of first inserting element in source array 
//               (ADstFRArray[ADstBegInd] = ASrcFRArray[ASrcBegInd])
// ANumElems   - number of inserting elements, if =-1, than insert all source 
//               array elements starting from ASrcBegInd
//
procedure N_InsertArrayElems( var ADstFRArray: TN_FRArray; ADstBegInd: integer;
                      ASrcFRArray: TN_FRArray; ASrcBegInd, ANumElems: integer );
var
  MoveSize: integer;
begin
//  if DstArray = nil then Exit;
  if (ADstBegInd < 0) or (ADstBegInd > High(ADstFRArray)) then
    ADstBegInd := Length(ADstFRArray);

  if ASrcFRArray <> nil then
  begin
    if (ANumElems < 0) or ((ASrcBegInd + ANumElems - 1) > High(ASrcFRArray)) then
      ANumElems := High(ASrcFRArray) - ASrcBegInd + 1;
  end else // SrcArray is not given
    if ANumElems < 0 then Exit;

  SetLength( ADstFRArray, Length(ADstFRArray)+ANumElems ); // increase DstArray
  MoveSize := (Length(ADstFRArray)-ADstBegInd-ANumElems)*Sizeof(ADstFRArray[0]);

  if MoveSize > 0 then // items are inserted inside (not added after)
    move( ADstFRArray[ADstBegInd], ADstFRArray[ADstBegInd + ANumElems], MoveSize );

  if ASrcFRArray <> nil then
    move( ASrcFRArray[ASrcBegInd], ADstFRArray[ADstBegInd], ANumElems*Sizeof(ADstFRArray[0]) );
end; // procedure N_InsertArrayElems(FRects)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcFRectDCoords
//****************************************************** N_CalcFRectDCoords ***
// Calculate Rectangle Border Polyline Double coordinates by given envelope 
// Float Rectangle and pass direction
//
//     Parameters
// ADLine     - resulting Polyline as Double Points Array
// AFEnvRect  - envelope Float Rectangle
// ADirection - pass direction (=0 means clockwise direction, else 
//              counterclock-wise)
//
procedure N_CalcFRectDCoords( var ADLine: TN_DPArray; AFEnvRect: TFRect;
                                                         ADirection: integer );
begin
  SetLength( ADLine, 5 );
  with AFEnvRect do
  begin
    ADLine[0] := DPoint( TopLeft );
    ADLine[2] := DPoint( BottomRight );
    ADLine[4] := ADLine[0];

    if ADirection = 0 then // clockwise direction
    begin
      ADLine[1] := DPoint( Right, Top );
      ADLine[3] := DPoint( Left, Bottom );
    end
    else //***************** counterclockwise direction
    begin
      ADLine[1] := DPoint( Left, Bottom );
      ADLine[3] := DPoint( Right, Top );
    end;
  end; // with EnvRect do
end; // procedure N_CalcFRectDCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcMeanderDCoords
//**************************************************** N_CalcMeanderDCoords ***
// Calculate Meander Polyline Double coordinates inscribed in given Float 
// Rectangle along X axis
//
//     Parameters
// ADLine      - resulting Polyline as Double Points Array
// AFEnvRect   - envelope Float Rectangle
// ANumPeriods - number of Meander periods
// ACoef       - ratio of upper part length to period (0 < Coef < 1.0,  Coef = 
//               0.5 is a simmetrical Meander)
//
// Created Polyline has has exactly 4 * ANumPeriods vertexes.
//
// Two periods Meander looks like this:
//#F
//*-------|   |-------|
//        |---|       |---#
// <-DX1->
// <--period->
//ACoef = DX1 / period
//* is AFEnvRect UpperLeft,
//# is AFEnvRect LowerRight
//#/F
//
procedure N_CalcMeanderDCoords( var ADLine: TN_DPArray; AFEnvRect: TFRect;
                                    ANumPeriods: integer; ACoef: double = 0.5 );
var
  i, NeededLength: integer;
  DX, DX1: double;
begin
  NeededLength := 4*ANumPeriods;
  if Length(ADLine) <> NeededLength then SetLength( ADLine, NeededLength );

  DX := N_RectWidth( AFEnvRect ) / ANumPeriods;
  DX1 := ACoef*DX;

  for i := 0 to ANumPeriods-1 do
  begin
    ADLine[i*4+0].X := AFEnvRect.Left + i*DX;
    ADLine[i*4+0].Y := AFEnvRect.Top;
    ADLine[i*4+1].X := AFEnvRect.Left + i*DX + DX1;
    ADLine[i*4+1].Y := AFEnvRect.Top;
    ADLine[i*4+2].X := AFEnvRect.Left + i*DX + DX1;
    ADLine[i*4+2].Y := AFEnvRect.Bottom;
    ADLine[i*4+3].X := AFEnvRect.Left + i*DX + DX;
    ADLine[i*4+3].Y := AFEnvRect.Bottom;
  end;
end; // procedure N_CalcMeanderDCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcSpiralDCoords
//***************************************************** N_CalcSpiralDCoords ***
// Calculate Spiral fragment Polyline Double coordinates
//
//     Parameters
// ADLine    - resulting Polyline as Double Points Array
// AFEnvRect - envelope Float Rectangle
// AALfaBeg  - Polyline first vertex radius-vector angle (in degree)
// AALfaEnd  - Polyline last vertex radius-vector angle (in degree)
// ACoef     - radius-vector coefficient - 0 < ACoef <= 1.0 (if ACoef = 1.0 then
//             resulting Polyline is an ellipse fragment)
// ANumVerts - number of Polyline vertexes
//
// Polyline vertexes radius-vector angle is changed from AALfaBeg to AALfaEnd 
// and radius-vector length is changed from maximum value (RMax - radius-vector 
// of ellipse inscribed in  AFEnvRect) to ACoef*RMax.
//
procedure N_CalcSpiralDCoords( var ADLine: TN_DPArray; AFEnvRect: TFRect;
                        AALfaBeg, AALfaEnd, ACoef: double; ANumVerts: integer );
var
  i: integer;
  RMaxX, RMaxY, CenterX, CenterY, Alfa, RX, RY, C: double;
begin
  Assert( ANumVerts >= 2, 'Bad NumPoints!' );
  if Length(ADLine) <> ANumVerts then SetLength( ADLine, ANumVerts );

  with AFEnvRect do
  begin
    CenterX := 0.5*(Left + Right);
    CenterY := 0.5*(Top + Bottom);
    RMaxX   := 0.5*( Right - Left);
    RMaxY   := 0.5*( Bottom - Top);
  end;

  for i := 0 to ANumVerts-1 do
  begin
    C := i / (ANumVerts-1);
    RX := RMaxX*(1-C) + RMaxX*ACoef*C;
    RY := RMaxY*(1-C) + RMaxY*ACoef*C;
    Alfa := N_PI*(AALfaBeg*(1-C) + AALfaEnd*C)/180.0;
    ADLine[i].X := CenterX + RX*cos(Alfa);
    ADLine[i].Y := CenterY + RY*Sin(Alfa);
  end;
end; // procedure N_CalcSpiralDCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcRegPolyDCoords
//**************************************************** N_CalcRegPolyDCoords ***
// Calculate Regular Polygon Double coordinates as Ellipse inscribed in given 
// Float Rectangle
//
//     Parameters
// ADLine    - resulting Polyline as Double Points Array
// AFEnvRect - envelope Float Rectangle
// AALfaBeg  - Polygon first vertex radius-vector angle (in degree)
// ANumVerts - number of Polygon vertexes
//
// Resulting Polyline has ANumVertexes + 1 vertexes.
//
procedure N_CalcRegPolyDCoords( var ADLine: TN_DPArray; AFEnvRect: TFRect;
                                    AALfaBeg: double; ANumVerts: integer );
var
  i: integer;
  CenterX, CenterY, Alfa, RX, RY: double;
begin
  Assert( ANumVerts >= 3, 'Bad NumVerts!' );
  if High(ADLine) <> ANumVerts then SetLength( ADLine, ANumVerts+1 );

  with AFEnvRect do
  begin
    CenterX := 0.5*(Left + Right);
    CenterY := 0.5*(Top + Bottom);
    RX      := 0.5*( Right - Left);
    RY      := 0.5*( Bottom - Top);
  end;

  for i := 0 to ANumVerts do
  begin
    Alfa := N_PI*(AALfaBeg + i*360/ANumVerts)/180.0;
    ADLine[i].X := CenterX + RX*cos(Alfa);
    ADLine[i].Y := CenterY + RY*Sin(Alfa);
  end;
end; // procedure N_CalcRegPolyDCoords

{
//*********************************************** N_CalcRegPolyFragmDC ***
// Calculate double coordinates of fragment of Regular Polygon ring
//
// BegPointALfa - Beg Point Angle in degrees
// NumVerts     - Number of Polygon Verteces
//
procedure N_CalcRegPolyFragmDC( var DCoords: TN_DPArray; EnvRect: TFRect;
               ABegAngle, AArcAngle, AScaleCoef: float; ANumSegments: integer );
var
  i: integer;
  CenterX, CenterY, Alfa, RX, RY: double;
begin
  Assert( NumVerts >= 3, 'Bad NumVerts!' );
  if High(DCoords) <> NumVerts then SetLength( DCoords, NumVerts+1 );

  with EnvRect do
  begin

    CenterX := 0.5*(Left + Right);
    CenterY := 0.5*(Top + Bottom);
    RX      := 0.5*( Right - Left);
    RY      := 0.5*( Bottom - Top);

  end;

  for i := 0 to NumVerts do
  begin
    Alfa := N_PI*(BegPointALfa + i*360/NumVerts)/180.0;
    DCoords[i].X := CenterX + RX*cos(Alfa);
    DCoords[i].Y := CenterY + RY*Sin(Alfa);
  end;

end; // procedure N_CalcRegPolyFragmDC
}

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcRoundRectDCoords
//************************************************** N_CalcRoundRectDCoords ***
// Calculate RoundRect Double coordinates
//
//     Parameters
// AFEnvRect       - envelope Float Rectangle
// ARadXY          - corner Radiuses as Float Point
// ANumCornerVerts - number of Vertexes in each corner arc
// Result          - Returns resulting Polyline as Double Points Array
//
// if ARadXY.X = 0 or ANumCornerPoints <= 1 then resulting Polyline is simple 
// rectangle border coordinates (as calculate by N_CalcFRectDCoords).
//
function N_CalcRoundRectDCoords( AFEnvRect: TFRect; ARadXY: TFPoint;
                                 ANumCornerVerts: integer ): TN_DPArray;
var
  CornerRect: TFRect;
  ArcCoords: TN_DPArray;
begin
  if (ARadXY.X = 0) or (ANumCornerVerts <= 1) then // not rounded rect
  begin
    SetLength( Result, 5 );
    Result[0] := DPoint(AFEnvRect.TopLeft);
    Result[1].X := AFEnvRect.Right;
    Result[1].Y := AFEnvRect.Top;
    Result[2] := DPoint(AFEnvRect.BottomRight);
    Result[3].X := AFEnvRect.Left;
    Result[3].Y := AFEnvRect.Bottom;
    Result[4] := Result[0];
    Exit; // all done
  end;

  SetLength( Result, 4*ANumCornerVerts + 1 );

  if ARadXY.Y = 0 then // assume that Y Radius is same as X Radius
    ARadXY.Y := ARadXY.X;

  CornerRect.TopLeft := AFEnvRect.TopLeft;
  CornerRect.Right   := CornerRect.Left + 2*ARadXY.X;
  CornerRect.Bottom  := CornerRect.Top  + 2*ARadXY.Y;
  N_CalcSpiralDCoords( ArcCoords, CornerRect, 180, 270, 1, ANumCornerVerts );
  move( ArcCoords[0], Result[0], ANumCornerVerts*Sizeof(TDPoint) );
  Result[4*ANumCornerVerts] := Result[0];

  CornerRect.Right  := AFEnvRect.Right;
  CornerRect.Left   := CornerRect.Right - 2*ARadXY.X;
  CornerRect.Top    := AFEnvRect.Top;
  CornerRect.Bottom := CornerRect.Top  + 2*ARadXY.Y;
  N_CalcSpiralDCoords( ArcCoords, CornerRect, -90, 0, 1, ANumCornerVerts );
  move( ArcCoords[0], Result[ANumCornerVerts], ANumCornerVerts*Sizeof(TDPoint) );

  CornerRect.BottomRight := AFEnvRect.BottomRight;
  CornerRect.Left := CornerRect.Right - 2*ARadXY.X;
  CornerRect.Top  := CornerRect.Bottom  - 2*ARadXY.Y;
  N_CalcSpiralDCoords( ArcCoords, CornerRect, 0, 90, 1, ANumCornerVerts );
  move( ArcCoords[0], Result[2*ANumCornerVerts], ANumCornerVerts*Sizeof(TDPoint) );

  CornerRect.Left   := AFEnvRect.Left;
  CornerRect.Right  := CornerRect.Left + 2*ARadXY.X;
  CornerRect.Bottom := AFEnvRect.Bottom;
  CornerRect.Top    := CornerRect.Bottom - 2*ARadXY.Y;
  N_CalcSpiralDCoords( ArcCoords, CornerRect, 90, 180, 1, ANumCornerVerts );
  move( ArcCoords[0], Result[3*ANumCornerVerts], ANumCornerVerts*Sizeof(TDPoint) );

end; // function N_CalcRoundRectDCoords

{
//*********************************************** N_CalcRoundRectDCoords ***
// Calculate RoundRect double coordinates, return number of calculated points
//
// PDCoords  - Pointer to first element of array of DPoints, where coordinates should
//             be calculated, the caller should reserve for this array
//             atleast 4*(NumCornerPoints+1)+1  elements
// APCPanel  - Pointer to Panel params (only radiuses and RadUnits fields are used)
//             (Radiuses = -1 means that UpperLeft corenr radiuses are used)
// ALLWUSize - One LLW Size in User Units (used if radiuses are given in LLW)
// AEnvRect  - RoundRect Enevlope Rect (user coordinates of corner pixels centers)
// NumCornerPoints - number of points in each corner arc if RX,RY <> 0
//
function N_CalcRoundRectDCoords( PDCoords: PDPoint; APCPanel: TN_PCPanel;
                                 ALLWUSize: float; AEnvRect: TFRect;
                                            NumCornerPoints: integer ): integer;
// not reconsruted!!!
begin
  Result := 0;

var
  CurRad: TFPoint;
  BegPoint: TDPoint;
  CornerRect: TFRect;
  ArcCoords: TN_DPArray;

  function RadToUserUnits( const ARad: TFPoint ): TFPoint; // local
  // convert two given Radiuses in RadUnits to Radiuses in User Units
  begin
    Result := FPoint(0,0);
    case APCPanel^.RadUnits of

      ruPercent: Result := FPoint( ARad.X*N_RectWidth(AEnvRect)/200,
                                   ARad.Y*N_RectHeight(AEnvRect)/200 );
      ruLLW:  Result := FPoint( ARad.X*ALLWUSize, ARad.Y*ALLWUSize );
      ruUser: Result := ARad;

    end; // case APCPanel^.RadUnits of
  end; // function RadToUserUnits - local

begin //*********************************** body of N_CalcRoundRectDCoords
  with APCPanel^ do
  begin

  if (RadUnits = ruNone) or (Radiuses.X = 0) or (NumCornerPoints <= 1) then
  begin // not rounded rect
    PDCoords^ := DPoint(AEnvRect.TopLeft);
      Inc(PDCoords);
    PDCoords^.X := AEnvRect.Right;
    PDCoords^.Y := AEnvRect.Top;
      Inc(PDCoords);
    PDCoords^ := DPoint(AEnvRect.BottomRight);
      Inc(PDCoords);
    PDCoords^.X := AEnvRect.Left;
    PDCoords^.Y := AEnvRect.Bottom;
      Inc(PDCoords);
    PDCoords^ := DPoint(AEnvRect.TopLeft);
    Result := 5;
    Exit; // all done
  end;

  //***** Here: Some of the radiuses are <> 0 and NumCornerPoints >= 2

  Result := 0;
  ArcCoords := nil;
  CurRad := Radiuses;

  if CurRad.X = 0 then // no Upper Left corner rounding
  begin
    BegPoint := DPoint(AEnvRect.TopLeft);
    PDCoords^ := BegPoint;
    Inc(PDCoords);
    Inc(Result);
  end else
  begin
    CurRad := RadToUserUnits( CurRad );
    CornerRect.TopLeft := AEnvRect.TopLeft;
    CornerRect.Right  := CornerRect.Left + 2*CurRad.X;
    CornerRect.Bottom := CornerRect.Top  + 2*CurRad.Y;
    N_CalcSpiralDCoords( ArcCoords, CornerRect, 180, 270, 1, NumCornerPoints );
    move( ArcCoords[0], PDCoords^, NumCornerPoints*Sizeof(TDPoint) );
    BegPoint := ArcCoords[0];
    Inc(PDCoords, NumCornerPoints);
    Inc( Result, NumCornerPoints );
  end;

  if CurRad.X = 0 then // no Upper Right corner rounding
  begin
    PDCoords^.X := AEnvRect.Right;
    PDCoords^.Y := AEnvRect.Top;
    Inc(PDCoords);
    Inc(Result);
  end else
  begin
    CornerRect.Right  := AEnvRect.Right;
    CornerRect.Left   := CornerRect.Right - 2*CurRad.X;
    CornerRect.Top    := AEnvRect.Top;
    CornerRect.Bottom := CornerRect.Top  + 2*CurRad.Y;
    N_CalcSpiralDCoords( ArcCoords, CornerRect, -90, 0, 1, NumCornerPoints );
    move( ArcCoords[0], PDCoords^, NumCornerPoints*Sizeof(TDPoint) );
    Inc(PDCoords, NumCornerPoints);
    Inc( Result, NumCornerPoints );
  end;

  if CurRad.X = 0 then // no Lower Right corner rounding
  begin
    PDCoords^ := DPoint(AEnvRect.BottomRight);
    Inc(PDCoords);
    Inc(Result);
  end else
  begin
    CornerRect.BottomRight := AEnvRect.BottomRight;
    CornerRect.Left := CornerRect.Right - 2*CurRad.X;
    CornerRect.Top  := CornerRect.Bottom  - 2*CurRad.Y;
    N_CalcSpiralDCoords( ArcCoords, CornerRect, 0, 90, 1, NumCornerPoints );
    move( ArcCoords[0], PDCoords^, NumCornerPoints*Sizeof(TDPoint) );
    Inc(PDCoords, NumCornerPoints);
    Inc( Result, NumCornerPoints );
  end;

  if CurRad.X = 0 then // no Lower Left corner rounding
  begin
    PDCoords^.X := AEnvRect.Left;
    PDCoords^.Y := AEnvRect.Bottom;
    Inc(PDCoords);
    Inc(Result);
  end else
  begin
    CornerRect.Left   := AEnvRect.Left;
    CornerRect.Right  := CornerRect.Left + 2*CurRad.X;
    CornerRect.Bottom := AEnvRect.Bottom;
    CornerRect.Top    := CornerRect.Bottom - 2*CurRad.Y;
    N_CalcSpiralDCoords( ArcCoords, CornerRect, 90, 180, 1, NumCornerPoints );
    move( ArcCoords[0], PDCoords^, NumCornerPoints*Sizeof(TDPoint) );
    Inc(PDCoords, NumCornerPoints);
    Inc( Result, NumCornerPoints );
  end;

  end; // with APCPanel^ do

  PDCoords^ := BegPoint; // closing point
  Inc(Result);
end; // function N_CalcRoundRectDCoords
}

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_EnvRectPos(Integer)
//*************************************************** N_EnvRectPos(Integer) ***
// Test if given Integer Rectangle intersects another Rectangle
//
//     Parameters
// AEnvRect  - first rectangle
// AClipRect - second rectangle
// Result    - Returns 0 if AEnvRect is inside AClipRect (may have common 
//             borders) or 1 if AEnvRect intresects AClipRect
//
// Used to test some object envelope rectangle and cliping rectangle. If Result 
// equals 1 then clipping is needed.
//
function N_EnvRectPos( const AEnvRect, AClipRect: TRect ): integer;
begin
  if (AEnvRect.Left   >= AClipRect.Left)  and
     (AEnvRect.Top    >= AClipRect.Top)   and
     (AEnvRect.Right  <= AClipRect.Right) and
     (AEnvRect.Bottom <= AClipRect.Bottom) then // EnvRect is inside ClipRect
    Result := 0
  else
    Result := 1; // (clipping is needed)
// (If EnvRect is stricly outside MinClipRect is NOT tested)
end; // function N_EnvRectPos(Integer)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_EnvRectPos(Float)
//***************************************************** N_EnvRectPos(Float) ***
// Test given Float Rectangle intersects another Rectangle
//
//     Parameters
// AEnvRect  - first rectangle
// AClipRect - second rectangle
// Result    - Returns 0 if AEnvRect is inside AClipRect (may have common 
//             borders) or 1 if AEnvRect intresects AClipRect
//
// Used to test some object envelope rectangle and cliping rectangle. If Result 
// equals 1 then clipping is needed.
//
function N_EnvRectPos( const AEnvRect, AClipRect: TFRect ): integer;
begin
  if (AEnvRect.Left   >= AClipRect.Left)  and
     (AEnvRect.Top    >= AClipRect.Top)   and
     (AEnvRect.Right  <= AClipRect.Right) and
     (AEnvRect.Bottom <= AClipRect.Bottom) then // EnvRect is inside ClipRect
    Result := 0
  else
    Result := 1; // (clipping is needed)
// (if EnvRect is stricly outside MinClipRect is NOT tested)
end; // function N_EnvRectPos(Float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ChangePointsCoords
//**************************************************** N_ChangePointsCoords ***
// Change Double Points Coordinates (all points that have AOldCoords by 
// ANewCoords)
//
//     Parameters
// AOldCoords - old Double Point coorinates
// ANewCoords - new Double Point coorinates
// APDPoints  - pointer to first Double Point in array
// ANumPoints - number of Double Points to consider
//
procedure N_ChangePointsCoords( const AOldCoords, ANewCoords: TDPoint;
                                        APDPoints: PDPoint; ANumPoints: integer );
var
  i: integer;
begin
  for i := 1 to ANumPoints do
  begin
    if (APDPoints^.X = AOldCoords.X) and (APDPoints^.Y = AOldCoords.Y) then
      APDPoints^ := ANewCoords;
    Inc(APDPoints);
  end;
end; // procedure N_ChangePointsCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Calc2BSplineCoords(2)
//************************************************* N_Calc2BSplineCoords(1) ***
// Calculate Polyline Double coordinates by smoothing with Quadratic Bezier (2B)
// spline V1
//
//     Parameters
// APInpDC      - pointer to first Vertex of input Double Polyline
// ANInpPoints  - number of points in input Polyline
// ANAddPoints  - number of additional points to add to each spline segment or 0
//                for automatic calculation by using AMinAngle, AMinSegmSize
// AMinAngle    - angle (in degree) between segments should not be less
// AMinSegmSize - segment size should not be less then given
// AOutDC       - resulting (smoothed) Polyline as Double Points Array (on 
//                output)
// ANOutPoints  - number of points in resulting (smoothed) Polyline (in AOutDC) 
//                (on output)
//
// Variant 1  - each initial line segment is smoothed separatly
//
procedure N_Calc2BSplineCoords( APInpDC: PDPoint; ANInpPoints, ANAddPoints: integer;
                           AMinAngle, AMinSegmSize: float; var AOutDC: TN_DPArray;
                                                     out ANOutPoints: integer );
var
  i, OutInd, OutSize: integer;
  P: TDPoint;
  Closed: boolean;

  function GV( Ind: integer ): TDPoint; //*** local
  // same as PInpDC[Ind]
  var
    PDP: PDPoint;
  begin
    PDP := APInpDC;
    Inc( PDP, Ind );
    Result := PDP^;
  end; // function GV (local)

  procedure AddSplineSegment( const P1, P2, P3: TDPoint ); //*** local
  // add to OutDC new spline vertexes
  // P1, P3 - beg and end spline points, P2 - control point
  var
    i, NAP: integer;
    t, S, S1, S2, P2Angle: double;
    Q1, Q2: TDPoint;

  begin
    S1 := N_P2PDistance( P1, P2 );
    S2 := N_P2PDistance( P2, P3 );
    S := S1 + S2;
    P2Angle := Abs(N_SegmAngle( P1, P2, P3 ));

    if ANAddPoints > 0 then
      NAP := ANAddPoints
    else
    begin
      NAP := 0;
      if AMinAngle > 0 then NAP := Round( P2Angle / AMinAngle );
      if AMinSegmSize > 0 then  NAP := Min( Nap, Round( S / AMinSegmSize ) );
    end;

    if High(AOutDC) < (OutInd+NAP) then
      SetLength( AOutDC, N_NewLength(OutInd+NAP+1) );

    for i := 1 to NAP do // add NAP additional points
    begin
      t := i / (NAP + 1.0);
      Q1 := N_SegmPoint( P1, P2, t );
      Q2 := N_SegmPoint( P2, P3, t );
      AOutDC[OutInd] := N_SegmPoint( Q1, Q2, t );
      Inc(OutInd);
    end; // for i := 1 to NAP do // add NAP additional points

    AOutDC[OutInd] := P3; // add last point
    Inc(OutInd);
  end; // procedure AddSplineSegment (local)

begin
  OutSize := Max( 1000, Max( ANAddPoints, 5 )* ANInpPoints ); // prelimenary value
  if OutSize > Length(AOutDC) then
  begin
    AOutDC := nil;
    SetLength( AOutDC, OutSize );
  end;

  if N_Same( GV(0), GV(ANInpPoints-1) ) then Closed := True
                                        else Closed := False;
  if Closed then
  begin
    AOutDC[0] := N_SegmPoint( GV(0), GV(1), 0.5 );
    OutInd := 1;
  end else // not closed
  begin
    AOutDC[0] := APInpDC^;
    AOutDC[1] := N_SegmPoint( GV(0), GV(1), 0.5 );
    OutInd := 2;
  end;

  for i := 1 to ANInpPoints-2 do
  begin
    P := GV(i);
    AddSplineSegment( N_SegmPoint( GV(i-1), P, 0.5 ), P,
                      N_SegmPoint( P, GV(i+1), 0.5 ) );
  end; // for i := 1 to NumPoints-1 do

  if Closed then
    AddSplineSegment( N_SegmPoint( GV(ANInpPoints-2), GV(0), 0.5 ), GV(0),
                      N_SegmPoint( GV(0), GV(1), 0.5 ) )
  else
  begin // add last spline point (same as last line point)
    if High(AOutDC) < OutInd then
      SetLength( AOutDC, N_NewLength(OutInd+1) );
    AOutDC[OutInd] := GV(ANInpPoints-1);
    Inc(OutInd);
  end;

  ANOutPoints := OutInd;
end; // procedure N_Calc2BSplineCoords(1)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Calc2BSplineCoords(1)
//************************************************* N_Calc2BSplineCoords(2) ***
// Calculate Polyline Double coordinates by smoothing with Quadratic Bezier (2B)
// spline V2
//
//     Parameters
// APInpDC     - pointer to first Vertex of input Double Polyline
// ANInpPoints - number of points in input Polyline
// ANResPoints - number of points in resulting spline (on input)
// AOutDC      - resulting (smoothed) Polyline as Double Points Array (on 
//               output)
// AOutAngles  - calculated angles of each resulting spline point as Double 
//               Array (on output)
//
// Variant 2 - given number of points in rezulting spline distributed uniformly 
// along whole spline, number of initial Polyline segments does not matter
//
procedure N_Calc2BSplineCoords( APInpDC: PDPoint; ANInpPoints, ANResPoints: integer;
                             var AOutDC: TN_DPArray; var AOutAngles: TN_DArray );
var
  i, OutInd, CurInd: integer;
  CurLeng, LineLeng, S, S1, S2, t: double;
  LSLengs: TN_DArray;
  P1, P2: TDPoint;

  function GV( Ind: integer ): TDPoint; //*** local
  // same as PInpDC[Ind]
  var
    PDP: PDPoint;
  begin
    PDP := APInpDC;
    Inc( PDP, Ind );
    Result := PDP^;
  end; // function GV (local)

  procedure AddSplinePoint( const P1, P2, P3: TDPoint; Alpha: double ); //*** local
  // add to OutDC and to OutAngles one new spline Point
  // P1, P3 - beg and end spline points, P2 - control point
  var
    Q1, Q2: TDPoint;
    R1, R2, R, b: double;
  begin
    R1 := N_P2PDistance( P1, P2 );
    R2 := N_P2PDistance( P2, P3 );
    R := 2*R1/(R1+R2);
    b := (-R + sqrt( R*R + 4*(1-R)*Alpha )) / (2*(1-R));
    Q1 := N_SegmPoint( P1, P2, b );
    Q2 := N_SegmPoint( P2, P3, b );
    AOutDC[OutInd] := N_SegmPoint( Q1, Q2, b );
    AOutAngles[OutInd] := N_SegmAngle( Q1, Q2 );
    Inc(OutInd);
  end; // procedure AddSplinePoint (local)

begin
  if ANResPoints > Length(AOutDC) then
  begin
    AOutDC := nil;
    SetLength( AOutDC, ANResPoints );
  end;

  if ANResPoints > Length(AOutAngles) then
  begin
    AOutAngles := nil;
    SetLength( AOutAngles, ANResPoints );
  end;

  N_LSegmLengths( APInpDC, ANInpPoints, LSLengs ); // calc inp Line segm lenghts
  LineLeng := LSLengs[ANInpPoints-1];

  if ANResPoints = 1 then
  begin
    AOutDC[0] := APInpDC^;
    AOutAngles[0] := N_SegmAngle( GV(0), GV(1) );
    Exit;
  end;

  if ANInpPoints = 2 then // resulting spline is line segment
  begin
    AOutAngles[0] := N_SegmAngle( GV(0), GV(1) );
    for i := 1 to ANResPoints do
    begin
      t := (i-1)/(ANResPoints-1);
      AOutDC[i-1] := N_SegmPoint( GV(0), GV(1), t );
      AOutAngles[i-1] := AOutAngles[0];
    end;
    Exit;
  end;

  CurInd := 0;
  OutInd := 0;

  for i := 1 to ANResPoints do
  begin
    CurLeng := LineLeng*(i-1)/(ANResPoints-1);

    while (CurLeng >= LSLengs[CurInd+1]) and
          (CurInd < (ANInpPoints-2)) do Inc(CurInd);

    if ANInpPoints = 3 then // the only spline segm
    begin
      AddSplinePoint( GV(0), GV(1), GV(2), CurLeng/LineLeng );
      Continue;
    end;

    t := (CurLeng - LSLengs[CurInd]) / (LSLengs[CurInd+1] - LSLengs[CurInd]);

    if (CurInd = 0) or ((CurInd = 1) and (t <= 0.5)) then // first spline segm
    begin
      AddSplinePoint( GV(0), GV(1), N_SegmPoint( GV(1), GV(2), 0.5 ),
                                     2*CurLeng / (LSLengs[1] + LSLengs[2]) );
      Continue;
    end;

    if (CurInd =(ANInpPoints-2)) or             // last spline segm
       ((CurInd = (ANInpPoints-3)) and (t > 0.5)) then
    begin
      S := 0.5*(LSLengs[ANInpPoints-3] + LSLengs[ANInpPoints-2]);
      AddSplinePoint( N_SegmPoint( GV(ANInpPoints-3), GV(ANInpPoints-2), 0.5),
                      GV(ANInpPoints-2), GV(ANInpPoints-1),
                                                  (CurLeng-S) / (LineLeng-S) );
      Continue;
    end;

    //***** Here: intermediate spline segment

    if t <= 0.5 then // second half of prev and first half or cur Ind
    begin
      S1 := 0.5*(LSLengs[CurInd-1] + LSLengs[CurInd]);
      S2 := 0.5*(LSLengs[CurInd] + LSLengs[CurInd+1]);
      P1 := N_SegmPoint( GV(CurInd-1), GV(CurInd), 0.5 );
      P2 := N_SegmPoint( GV(CurInd), GV(CurInd+1), 0.5 );
      AddSplinePoint( P1, GV(CurInd), P2, (CurLeng-S1)/(S2-S1) );
    end else // t > 0.5 - second half of cur and first half or next Ind
    begin
      S1 := 0.5*(LSLengs[CurInd] + LSLengs[CurInd+1]);
      S2 := 0.5*(LSLengs[CurInd+1] + LSLengs[CurInd+2]);
      P1 := N_SegmPoint( GV(CurInd), GV(CurInd+1), 0.5 );
      P2 := N_SegmPoint( GV(CurInd+1), GV(CurInd+2), 0.5 );
      AddSplinePoint( P1, GV(CurInd+1), P2, (CurLeng-S1)/(S2-S1) );
    end;
  end; // for i := 1 to NResPoints do

end; // procedure N_Calc2BSplineCoords(2)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_DeleteSameDVertexes
//*************************************************** N_DeleteSameDVertexes ***
// Delete all Same Neighboring Vertexes from given array of Double Points
//
//     Parameters
// APDInpVert  - pointer to first Input Vertex in Double Points array
// ANumInpVert - Number of Input Vertexes (>= 0)
// ADOutVerts  - Output Vertexes as Double Points array
// Result      - Returns number of points in ADOutVerts array (may be 0)
//
function N_DeleteSameDVertexes( APDInpVert: PDPoint; ANumInpVerts: integer;
                                          out ADOutVerts: TN_DPArray ): integer;
var
  i, OutInd: integer;
begin
  Result := 0;
  if ANumInpVerts < 2 then Exit;

  if Length(ADOutVerts) < ANumInpVerts then
    SetLength( ADOutVerts, N_NewLength( ANumInpVerts ) );

  ADOutVerts[0] := APDInpVert^;
  OutInd := 1;

  for i := 2 to ANumInpVerts do
  begin
    Inc(APDInpVert);
    ADOutVerts[OutInd] := APDInpVert^;
    if not CompareMem( @ADOutVerts[OutInd-1], @ADOutVerts[OutInd],
            Sizeof(ADOutVerts[0]) ) then Inc(OutInd);
  end; // for i := 1 to NumInpVerts do

  Result := OutInd; // may be = 1
end; // function N_DeleteSameDVertexes

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CursorNearRect
//******************************************************** N_CursorNearRect ***
// Check if Cursor is near given Rectangle with Integer Coordinates
//
//     Parameters
// ARect  - given Rect
// ACPos  - Cursor Position as Integer Point
// ADelta - distance tolerance
// Result - Returns resulting flags:
//#F
//  bit0($01) <> 0 - ACPos is near Top Rect Side
//  bit1($02) <> 0 - ACPos is near Right Rect Side
//  bit2($04) <> 0 - ACPos is near Bottom Rect Side
//  bit3($08) <> 0 - ACPos is near Left Rect Side
//  bit4($10) <> 0 - ACPos is near some Rect Side or inside Rect
//#/F
//
function N_CursorNearRect( const ARect: TRect; ACPos: TPoint;
                                               ADelta: integer ): integer;
begin
  Result := 0;

  with ARect, ACPos do
  begin
    if ((Top-ADelta)    > Y) or ((Right+ADelta) < X) or
       ((Bottom+ADelta) < Y) or ((Left -ADelta) > X)  then Exit; // out of Rect

    Inc( Result, $010 );

    if Abs( Top    - Y ) <= ADelta then Inc( Result, $01 );
    if Abs( Right  - X ) <= ADelta then Inc( Result, $02 );
    if Abs( Bottom - Y ) <= ADelta then Inc( Result, $04 );
    if Abs( Left   - X ) <= ADelta then Inc( Result, $08 );
  end; // with ARect, ACPos do
end; // function N_CursorNearRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_IPointNearIRects
//****************************************************** N_IPointNearIRects ***
// Check if Integer Point is near one of given Integer Rectangles
//
//     Parameters
// ABegInd - index of First Rectangle to Check
// ARects  - given Array of Integer Rectangles
// ACPos   - given Integer Point
// ADelta  - distance tolerance
// AFlags  - resulting flags:
//#F
//  bit0($01) <> 0 - ACPos is near Top Rect Side
//  bit1($02) <> 0 - ACPos is near Right Rect Side
//  bit2($04) <> 0 - ACPos is near Bottom Rect Side
//  bit3($08) <> 0 - ACPos is near Left Rect Side
//  bit4($10) <> 0 - ACPos is near some Rect Side or inside Rect
//#/F
// Result  - Returns Index of first Rectangle near to given Point or -1
//
function N_IPointNearIRects( ABegInd: integer; ARects: TN_IRArray; ACPos: TPoint;
                                ADelta: integer; out AFlags: integer ): integer;
var
  i: integer;
begin
  Result := -1;
  AFlags := 0;

  for i := ABegInd to High(ARects) do // along all ARects
  with ARects[i], ACPos do
  begin
    if ((Top-ADelta)    > Y) or ((Right+ADelta) < X) or
       ((Bottom+ADelta) < Y) or ((Left -ADelta) > X)  then Continue; // out of Rect

    Inc( AFlags, $010 ); // is near some Rect Side or inside Rect

    if Abs( Top    - Y ) <= ADelta then Inc( AFlags, $01 ); // is near Top Rect Side
    if Abs( Right  - X ) <= ADelta then Inc( AFlags, $02 ); // is near Right Rect Side
    if Abs( Bottom - Y ) <= ADelta then Inc( AFlags, $04 ); // is near Bottom Rect Side
    if Abs( Left   - X ) <= ADelta then Inc( AFlags, $08 ); // is near Left Rect Side

    if AFlags <> 0 then // near some border or inside
    begin
      Result := i;
      Exit;
    end;

  end; // for i := 0 to High(ARects) do // along all ARects
end; // function N_IPointNearIRects

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_GetSizeByMargins
//****************************************************** N_GetSizeByMargins ***
// Calculate Size of embedded Rectangle given by Double Size of external 
// Rectangle and Double Margins
//
//     Parameters
// AMargins  - margins (LTRB) as Double Rectangle
// AExtRSize - rectangle size in same units as AMargins as Double Point
// Result    - Returns Size of resulting embedded Rectangle as Double Point
//
function N_GetSizeByMargins( const AMargins: TDRect;
                             const AExtRSize: TDPoint ): TDPoint;
begin
  Result.X := AExtRSize.X - AMargins.Left - AMargins.Right;
  Result.Y := AExtRSize.Y - AMargins.Top  - AMargins.Bottom;
end; // function N_GetSizeByMargins

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_GetMargins(A)
//********************************************************* N_GetMargins(A) ***
// Calculate Double Margins by external Rectangle Double Size, embedded 
// Rectangle Double Size and align rools
//
//     Parameters
// AMinMargins - minimal margins (LTRB) as Double Rectangle
// AExtRSize   - external Rectangle Double Size (in same units as AMinMargins)
// AEmbRSize   - embedded Rectangle Double Size  (in same units as AMinMargins)
// AHorAlign   - Horizontal alignment mode
// AVertAlign  - Vertical alignment mode
// Result      - Returns double Margins  as Double Rectangle for given embedded 
//               Rectangle Size
//
function N_GetMargins( const AMinMargins: TDRect;
                       const AExtRSize, AEmbRSize: TDPoint;
                       AHorAlign: TN_HVAlign; AVertAlign: TN_HVAlign ): TDRect;
var
  Center: double;
begin
  case AHorAlign of // calc horizontal margins

    hvaEnd: begin
      Result.Right := AMinMargins.Right;
      Result.Left  := AExtRSize.X - Result.Right - AEmbRSize.X;
    end; // hvaEnd: begin

    hvaCenter: begin
      Center := 0.5*( AMinMargins.Left + AExtRSize.X - AMinMargins.Right );
      Result.Left  := Center - 0.5*AEmbRSize.X;
      Result.Right := AExtRSize.X - (Center + 0.5*AEmbRSize.X);
    end; // hvaCenter: begin

    else begin // hvaBeg and others
      Result.Left  := AMinMargins.Left;
      Result.Right := AExtRSize.X - Result.Left - AEmbRSize.X;
    end; // else begin // hvaBeg and others

  end; // case AHorAlign of // calc horizontal margins

  case AVertAlign of // calc vertical margins

    hvaEnd: begin
      Result.Bottom := AMinMargins.Bottom;
      Result.Top  := AExtRSize.Y - Result.Bottom - AEmbRSize.Y;
    end; // hvaEnd: begin

    hvaCenter: begin
      Center := 0.5*( AMinMargins.Top + AExtRSize.Y - AMinMargins.Bottom );
      Result.Top    := Center - 0.5*AEmbRSize.Y;
      Result.Bottom := AExtRSize.Y - (Center + 0.5*AEmbRSize.Y);
    end; // hvaCenter: begin

    else begin // hvaBeg and others
      Result.Top    := AMinMargins.Top;
      Result.Bottom := AExtRSize.Y - Result.Top - AEmbRSize.Y;
    end; // else begin // hvaBeg and others

  end; // case AVertAlign of // calc vertical margins

end; // function N_GetMargins(A)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_GetMargins(B)
//********************************************************* N_GetMargins(B) ***
// Return Double Margins for maximal possible Size of Rectangle embedded in 
// external Rectangle of given Size
//
//     Parameters
// AMinMargins - minimal margins (LTRB) as Double Rectangle
// AExtRSize   - external Rectangle Double Size (in same units as AMinMargins)
// AAspect     - needed embedded Rectangle Aspect (0 if any aspect is OK)
// AHorAlign   - Horizontal alignment mode
// AVertAlign  - Vertical alignment mode
// Result      - Returns double Margins as Double Rectangle for maximal possible
//               embedded Rectangle Size
//
function N_GetMargins( const AMinMargins: TDRect; const AExtRSize: TDPoint;
                       AAspect: double; AHorAlign: TN_HVAlign;
                                           AVertAlign: TN_HVAlign ): TDRect;
var
  ImageSize: TDPoint;
begin
  ImageSize := N_GetSizeByMargins( AMinMargins, AExtRSize );
  ImageSize := N_AdjustSizeByAspect( aamDecRect, ImageSize, AAspect );
  Result := N_GetMargins( AMinMargins, AExtRSize, ImageSize,
                                                  AHorAlign, AVertAlign );
end; // function N_GetMargins(B)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_GetPrinterDstRect
//***************************************************** N_GetPrinterDstRect ***
// Get current Printer Destination Pixel Rectangle by given AMarginsmm in mm
//
//     Parameters
// AMarginsmm - margins size in mm as Double Rectangle
// Result     - Returns current printer Destination Pixel Rectangle taking into 
//              account given AMarginsmm
//
function N_GetPrinterDstRect( AMarginsmm: TDRect ): TRect;
var
  DPMRes: TDPoint;
  PrnAreaPix, FullPagePix, MinMarginPix: TPoint;
begin
  // Get Printer resolution in dots per millimeter
  N_i := GetDeviceCaps( Printer.Handle, LOGPIXELSX );
  DPMRes.X := GetDeviceCaps( Printer.Handle, LOGPIXELSX ) / 25.4;
  DPMRes.Y := GetDeviceCaps( Printer.Handle, LOGPIXELSY ) / 25.4;

  // set Result to Max Printable area coordinates in pixels
  PrnAreaPix.X := GetDeviceCaps( Printer.Handle, HORZRES );
  PrnAreaPix.Y := GetDeviceCaps( Printer.Handle, VERTRES );
  Result := Rect( 0, 0, PrnAreaPix.X-1, PrnAreaPix.Y-1 );

  // get FullPagePix, MinMarginPix
  FullPagePix.X := GetDeviceCaps( Printer.Handle, PHYSICALWIDTH );
  FullPagePix.Y := GetDeviceCaps( Printer.Handle, PHYSICALHEIGHT );

  MinMarginPix.X := GetDeviceCaps( Printer.Handle, PHYSICALOFFSETX ); // Left Margin
  MinMarginPix.Y := GetDeviceCaps( Printer.Handle, PHYSICALOFFSETY ); // Top Margin

  // update Result by given AMarginsmm
  Inc( Result.Left, Round(AMarginsmm.Left*DPMRes.X) - MinMarginPix.X );
  Inc( Result.Top,  Round(AMarginsmm.Top*DPMRes.Y)  - MinMarginPix.Y );

  MinMarginPix.X := FullPagePix.X - MinMarginPix.X - PrnAreaPix.X; // Right Margin
  Dec( Result.Right, Round(AMarginsmm.Right*DPMRes.X) - MinMarginPix.X );

  MinMarginPix.Y := FullPagePix.Y - MinMarginPix.Y - PrnAreaPix.Y; // Bottom Margin
  Dec( Result.Bottom, Round(AMarginsmm.Bottom*DPMRes.X) - MinMarginPix.Y );
end; // end of function N_GetPrinterDstRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcPolylineCenter(float)
//********************************************* N_CalcPolylineCenter(float) ***
// Calculate Coordinates of Float Polyline Center Point
//
//     Parameters
// APFLine    - pointer to first Float Polyline vertex
// ANumPoints - number of vertexes in given Float Polyline
// Result     - Returns given Polyline Center Point Float Coordinates
//
function N_CalcPolylineCenter( APFLine: PFPoint; ANumPoints: integer ): TFPoint;
var
  i: integer;
begin
  Result := FPoint( 0, 0 );

  for i := 0 to ANumPoints-1 do
  begin
    Result.X := Result.X + APFLine^.X;
    Result.Y := Result.Y + APFLine^.Y;
    Inc(APFLine);
  end;

  Result.X := Result.X / ANumPoints;
  Result.Y := Result.Y / ANumPoints;
end; // function N_CalcPolylineCenter(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcPolylineCenter(double)
//******************************************** N_CalcPolylineCenter(double) ***
// Calculate Coordinates of Double Polyline Center Point
//
//     Parameters
// APDLine   - pointer to first Double Polyline vertex
// ANumVerts - number of vertexes in given Double Polyline
// Result    - Returns given Polyline Center Point Double Coordinates
//
function N_CalcPolylineCenter( APDLine: PDPoint; ANumVerts: integer ): TDPoint;
var
  i: integer;
begin
  Result := DPoint( 0, 0 );

  for i := 0 to ANumVerts-1 do
  begin
    Result.X := Result.X + APDLine^.X;
    Result.Y := Result.Y + APDLine^.Y;
    Inc(APDLine);
  end;

  Result.X := Result.X / ANumVerts;
  Result.Y := Result.Y / ANumVerts;
end; // function N_CalcPolylineCenter(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_StepAlongPolyline(float)
//********************************************** N_StepAlongPolyline(float) ***
// Calculate Next Point Coordinates and Position along given Float Polyline
//
//     Parameters
// APFLine   - pointer to first Float Polyline vertex
// ASLengths - array of Polyline Segments Legths
// ANumSegms - number of Segments in given Float Polyline
// AStep     - step to next Point along given Polyline
// AInd      - current Point Position Segment Index, on output same for next 
//             Point
// ADelta    - part of segment which specified current Point Position, on output
//             same for next Point
// Result    - Returns next Point Float Coordinates
//
// Polyline Segment Index AInd and it's part ADelta are defined Polyline Current
// Point Position.
//
function N_StepAlongPolyline( APFLine: PFPoint; ASLengths: TN_FArray;
                              ANumSegms: integer; AStep: double;
                              var AInd: integer; var ADelta: float ): TFPoint;
var
  CurInd: integer;
  Rest, RestStep, Eps, CurLength: double;
  PTmp: PFPoint;

  procedure SetResult(); // local
  // calc Resulting Point coordinates by AInd, ADelta
  begin
    //***** Here: PTmp = APLine
    Inc( PTmp, AInd );
    Result := PTmp^; // Beg Point of resulting Segment
    Inc( PTmp );
    Result.X := Result.X + (PTmp^.X - Result.X)*ADelta;
    Result.Y := Result.Y + (PTmp^.Y - Result.Y)*ADelta;
  end; // procedure SetResult - local

begin //********************************** body of N_StepAlongPolyline(float)
  Eps := AStep * N_10FEps;
  Assert( AStep > 0, 'Bad AStep!' );

  if (AInd < 0) or (AInd >= ANumSegms) then
  begin
    AInd := -1;
    ADelta := 0;
    Result := N_ZFPoint;
  end;

  PTmp := APFLine; // used later
  CurLength := ASLengths[AInd]; // Cur Segment Length
  Rest := CurLength * (1.0 - ADelta); // Cur Segm Rest Length

  if AStep < Rest then // Next Point is on the same segment
  begin
    ADelta := 1.0 - (Rest - AStep) / CurLength;
    SetResult();
    Exit;
  end else //************ Next Point on some next segment, prepare for loop
  begin
    RestStep := AStep - Rest;
    CurInd := AInd + 1;
  end;

  while True do // along Segments
  begin
    //***** Check if out of Line

    if CurInd = ANumSegms then
    begin
      if RestStep < Eps then // exactly last point
      begin
        AInd := ANumSegms - 1;
        ADelta := 1.0;
        PTmp := APFLine;
        Inc( PTmp, ANumSegms );
        Result := PTmp^;
      end else
      begin
        AInd := -1; // "out of Line" flag
        ADelta := 0;
        Result := N_ZFPoint;
      end;

      Exit;
    end; // if CurInd = ANumSegms then

    //***** Here: CurInd < ANumSegms, check if NextPoint is on the Current Segment

    CurLength := ASLengths[CurInd];

    if CurLength = 0 then // special case
    begin
      if RestStep = 0.0 then
      begin
        AInd := CurInd;
        ADelta := 0;
        SetResult();
        Exit;
      end else // RestStep > 0
      begin
        Inc( CurInd );
        Continue; // to next segment
      end
    end; // if CurLength = 0 then // special case

    if RestStep < CurLength then // Next Point is on the Current segment
    begin
      AInd := CurInd;
      ADelta := RestStep / CurLength;
      SetResult();
      Exit;
    end else //******************** Next Point is on some next segment
    begin
      RestStep := RestStep - CurLength;
      Inc( CurInd );
    end;

    //***** Check next segment
  end; // while True do // along Segments

end; // procedure N_StepAlongPolyline(float)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_StepAlongPolyline(double)
//********************************************* N_StepAlongPolyline(double) ***
// Calculate Next Point Coordinates and Position along given Double Polyline
//
//     Parameters
// APDLine   - pointer to first Double Polyline vertex
// ASLengths - array of Polyline Segments Legths
// ANumSegms - number of Segments in given Double Polyline
// AStep     - step to next Point along given Polyline
// AInd      - current Point Position Segment Index, on output same for next 
//             Point
// ADelta    - part of segment which specified current Point Position, on output
//             same for next Point
// Result    - Returns next Point Double Coordinates
//
// Polyline Segment Index AInd and it's part ADelta are defined Polyline Current
// Point Position.
//
function N_StepAlongPolyline( APDLine: PDPoint; ASLengths: TN_DArray;
                              ANumSegms: integer; AStep: double;
                              var AInd: integer; var ADelta: double ): TDPoint;
var
  CurInd: integer;
  Rest, RestStep, Eps, CurLength: double;
  PTmp: PDPoint;
//  PTmp: PChar;

  procedure SetResult(); // local
  // calc Resulting Point coordinates by AInd, ADelta
  begin
    //***** Here: PTmp = APLine
    Inc( PTmp, AInd );
    Result := PTmp^; // Beg Point of resulting Segment
    Inc( PTmp );
    Result.X := Result.X + (PTmp^.X - Result.X)*ADelta;
    Result.Y := Result.Y + (PTmp^.Y - Result.Y)*ADelta;
  end; // procedure SetResult - local

begin //*********************************** body of N_StepAlongPolyline(double)
  Eps := AStep * N_10FEps;
  Assert( AStep > 0, 'Bad AStep!' );

  if (AInd < 0) or (AInd >= ANumSegms) then
  begin
    AInd := -1;
    ADelta := 0;
    Result := N_ZDPoint;
  end;

  PTmp := APDLine; // used later
  CurLength := ASLengths[AInd]; // Cur Segment Length
  Rest := CurLength * (1.0 - ADelta); // Cur Segm Rest Length

  if AStep < Rest then // Next Point is on the same segment
  begin
    ADelta := 1.0 - (Rest - AStep) / CurLength;
    SetResult();
    Exit;
  end else //************ Next Point on some next segment, prepare for loop
  begin
    RestStep := AStep - Rest;
    CurInd := AInd + 1;
  end;

  while True do // along Segments
  begin
    //***** Check if out of Line

    if CurInd = ANumSegms then
    begin
      if RestStep < Eps then // exactly last point
      begin
        AInd := ANumSegms - 1;
        ADelta := 1.0;
        PTmp := APDLine;
        Inc( PTmp, ANumSegms );
        Result := PTmp^;
      end else
      begin
        AInd := -1; // "out of Line" flag
        ADelta := 0;
        Result := N_ZDPoint;
      end;

      Exit;
    end; // if CurInd = ANumSegms then

    //***** Here: CurInd < ANumSegms, check if NextPoint is on the Current Segment

    CurLength := ASLengths[CurInd];

    if CurLength = 0 then // special case
    begin
      if RestStep = 0.0 then
      begin
        AInd := CurInd;
        ADelta := 0;
        SetResult();
        Exit;
      end else // RestStep > 0
      begin
        Inc( CurInd );
        Continue; // to next segment
      end
    end; // if CurLength = 0 then // special case

    if RestStep < CurLength then // Next Point is on the Current segment
    begin
      AInd := CurInd;
      ADelta := RestStep / CurLength;
      SetResult();
      Exit;
    end else //******************** Next Point is on some next segment
    begin
      RestStep := RestStep - CurLength;
      Inc( CurInd );
    end;

    //***** Check next segment
  end; // while True do // along Segments

end; // procedure N_StepAlongPolyline(double)

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcSegmLengths
//******************************************************* N_CalcSegmLengths ***
// Calculate Segments Lengths of given Line with double coordinates Return Whole
// Length (Sum) of all segments
//
//     Parameters
// APDLine      - pointer to first Double Polyline vertex
// ANumVerts    - number of Vertexes in given Double Polyline
// ASegmLengths - on output array of Polyline Segments Legths
// Result       - Returns Double Polyline Length
//
function N_CalcSegmLengths( APDLine: PDPoint; ANumVerts: integer;
                                         var ASegmLengths: TN_DArray ): double;
var
  i, NumSegms: integer;
  dx, dy: double;
  PP1, PP2: PDPoint;
// PPP: Pointer;
begin
  NumSegms := ANumVerts - 1;
  Result := 0;

  if Length(ASegmLengths) < NumSegms then
    SetLength( ASegmLengths, NumSegms );

  PP1 := APDLine;
  PP2 := APDLine;
  Inc( PP2 );

  for i := 0 to NumSegms-1 do // along all segments
  begin
    dx := PP1^.X - PP2^.X;
    dy := PP1^.Y - PP2^.Y;
    ASegmLengths[i] := sqrt( dx*dx + dy*dy );
    Result := Result + ASegmLengths[i];
  end; // for i := 0 to NumSegms-1 do // along all segments

end; // function N_CalcSegmLengths(double)


//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Line2LineDist
//********************************************************* N_Line2LineDist ***
// Calculate distance between two given Double Polylines
//
//     Parameters
// APDVert1,   APDVert2    - pointers to first Vertex of each Polyline
// ANumVerts1, ANumVerts2  - number of Vertexes in each Polyline
// ASLengths1,  ASLengths2 - lengths of segments in each Polyline (on input)
// AWSize1,     AWSize2    - whole size of each Polyline
// ANumCheckPoints         - number of points equally spaced along given 
//                           Polylines, where to calculate distance
// AMaxDist                - critical distance (if Subproduct > AMaxDist 
//                           calculations are breaked just for speed)
// AModeFlags              - =0 if Polylines have same directions, =1 otherwise 
//                           (first point of 1-st Polyline should be compared 
//                           with 2-nd Polyline last point) (temporary not 
//                           implemented)
// Result                  - Returns maximal distance
//
function N_Line2LineDist( APDVert1, APDVert2: PDPoint;
                          ANumVerts1, ANumVerts2: integer;
                          ASLengths1, ASLengths2: TN_DArray;
                          AWSize1, AWSize2, AMaxDist: double;
                          ANumCheckPoints, AModeFlags: integer ): double;

var
  i, Ind1, Ind2: integer;
  Step1, Step2, Delta1, Delta2, CurDist: double;
  CurP1, CurP2: TDPoint;
begin
  Result := 0;
  if ANumCheckPoints < 2 then ANumCheckPoints := 2;

  Step1 := AWSize1 / (ANumCheckPoints - 1);
  Step2 := AWSize2 / (ANumCheckPoints - 1);
  Delta1 := 0;
  Delta2 := 0;
  Ind1 := 0;
  Ind2 := 0;

  for i := 0 to ANumCheckPoints-1 do
  begin
    CurP1 := N_StepAlongPolyline( APDVert1, ASLengths1, ANumVerts1-1,
                                             Step1, Ind1, Delta1 );
    CurP2 := N_StepAlongPolyline( APDVert2, ASLengths2, ANumVerts2-1,
                                             Step2, Ind2, Delta2 );
    CurDist := N_P2PDistance( CurP1, CurP2 );
    if CurDist > Result then Result := CurDist;
    if Result > AMaxDist then Break;

  end; // for i := 0 to ANumCheckPoints-1 do

end; // function N_Line2LineDist

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_EllipseEnvRect
//******************************************************** N_EllipseEnvRect ***
// Calculate Rounded Ellipse Envelope Rectangle by given already Rounded Ellipse
// center and Ellipse size
//
//     Parameters
// AEllCenter - already Rounded Ellipse center as Float Point
// AEllSize   - Ellipse size as Float Point
// Result     - Returns Rounded Ellipse Envelope Float Rectangle
//
function N_EllipseEnvRect( const AEllCenter, AEllSize: TFPoint ): TFRect;
var
  IntSize: TFPoint;
begin
  IntSize.X := Round( AEllSize.X );
  IntSize.Y := Round( AEllSize.Y );

  //*****  2x2 Ellipse EnvRect with (1,1) center is (0,0,1,1) )

  Result.Left   := AEllCenter.X - Floor(0.5*IntSize.X);
  Result.Top    := AEllCenter.Y - Floor(0.5*IntSize.Y);
  Result.Right  := AEllCenter.X + Ceil(0.5*IntSize.X) - 1;
  Result.Bottom := AEllCenter.Y + Ceil(0.5*IntSize.Y) - 1;
end; // function N_EllipseEnvRect

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_FloatEllipsePoint
//***************************************************** N_FloatEllipsePoint ***
// Calculate not rounded Ellipse border Point coordinates by given angle in 
// degree
//
//     Parameters
// AEnvFRect - Ellipse Envelope Float Rectangle
// AAlfa     - angle in degree
// Result    - Returns not rounded Ellipse border Point Float coordinates
//
function N_FloatEllipsePoint( const AEnvFRect: TFRect; AAlfa: float ): TFPoint;
var
  AlfaR, RX, RY: double;
  Center: TDPoint;
begin
  AlfaR := N_PI*AAlfa/180.0;        // in radians
  Center := N_RectCenter( AEnvFRect );

  RX := Center.X - AEnvFRect.Left;
  RY := Center.Y - AEnvFRect.Top;

  Result.X := Center.X + RX*cos(AlfaR);
  Result.Y := Center.Y - RY*sin(AlfaR);
end; // function N_FloatEllipsePoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_EllipsePoint
//********************************************************** N_EllipsePoint ***
// Calculate rounded Ellipse border Point coordinates by given angle in degree
//
//     Parameters
// AEnvFRect - already Rounded Ellipse Envelope Float Rectangle
// AAlfa     - angle in degree
// Result    - Returns rounded Ellipse border Point Float coordinates
//
// Ellipse Envelope Float Rectangle AEnvFRect should be already rounded, 
// N_EllipseEnvRect function can be used for it.
//
function N_EllipsePoint( const AEnvFRect: TFRect; AAlfa: float ): TFPoint;
begin
  Result := N_FloatEllipsePoint( AEnvFRect, AAlfa );

  Result.X := Round( Result.X );
  Result.Y := Round( Result.Y );
end; // function N_EllipsePoint

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_EllipseCenterAndRad
//*************************************************** N_EllipseCenterAndRad ***
// Calculate Ellipse Center and Radiuses by given Envelope Rectangle
//
//     Parameters
// AEnvFRect  - Ellipse Envelope Float Rectangle
// AEllCenter - resulting Ellipse center as Float Point
// AEllRad    - resulting Ellipse radiuses as Float Point
//
procedure N_EllipseCenterAndRad( const AEnvFRect: TFRect;
                                          out AEllCenter, AEllRad: TFPoint );
begin
  with AEnvFRect do
  begin
    AEllCenter.X := 0.5*( Left + Right );
    AEllCenter.Y := 0.5*( Top + Bottom );
    AEllRad.X := Right  - AEllCenter.X;
    AEllRad.X := Bottom - AEllCenter.Y;
  end;
end; // function N_EllipseCenterAndRad

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_Round
//***************************************************************** N_Round ***
// Multiply given Float Point coordinates by given coefficient and round it
//
//     Parameters
// AFPoint - source Float Point
// ACoef   - coordinates coefficient
// Result  - Returns resulting Float point with multiplied and rounded 
//           coordinates
//
function N_Round( const AFPoint: TFPoint; ACoef: double ): TFPoint;
begin
  Result.X := Round( AFPoint.X * ACoef );
  Result.Y := Round( AFPoint.Y * ACoef );
end; // function N_Round

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_PolyDraw
//************************************************************** N_PolyDraw ***
// Own version of PolyDraw that works in Win98 too
//
//     Parameters
// AHDC    - handle of device context
// APoints - pointer to the first element of array of POINT structures that 
//           contains the endpoints for each line segment and the endpoints and 
//           control points for each Bezier curve
// ATypes  - pointer to the first element of array that specifies how each point
//           in the APoints array is used
// ACount  - total number of elements in APoints and ATypes arrays
//
procedure N_PolyDraw( AHDC: HDC; const APoints; const ATypes; ACount: integer );
begin
  Windows.PolyDraw( AHDC, APoints, ATypes, ACount );
end; // procedure N_PolyDraw

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_GetPathCoords
//********************************************************* N_GetPathCoords ***
// Retrieves the coordinates defining the endpoints of lines and the control 
// points of curves found in the path that is selected into the specified WinGDI
// device context
//
//     Parameters
// AHDC    - handle of device context
// APoints - resulting array of Integer Points that contains the line endpoints 
//           and curve control points
// ATypes  - resulting array of bytes where the point types are placed
// Result  - Returns the number of elements in resulting arrays
//
// Resulting array length is always >=1 even for empty current selected path
//
function N_GetPathCoords( AHDC: HDC; var APoints: TN_IPArray; var ATypes: TN_BArray ): integer;
begin
  Result := Windows.GetPath( AHDC, N_p, N_p, 0 ); // Get Number of Points in Path
  if Result = 0 then // empty Path
  begin
    if Length(APoints) = 0 then Setlength( APoints, 1 );
    if Length(ATypes) = 0 then Setlength( ATypes, 1 );
    Exit;
  end;

  if Length(APoints) < Result then
  begin
    APoints := nil; // to prevent moving data
    Setlength( APoints, N_NewLength( Result ) );
    ATypes := nil; // to prevent moving data
    Setlength( ATypes, N_NewLength( Result ) );
  end;

  Windows.GetPath( AHDC, APoints[0], ATypes[0], Result );
end; // function N_GetPathCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ShiftICoords
//********************************************************** N_ShiftICoords ***
// Shift given Integer Polyline Coordinates
//
//     Parameters
// APSrcVert  - pointer to the first Vertex of source Integer Polyline
// APDstVert  - pointer to the first Vertex of resulting Integer Polyline
// ANumVerts  - number of Vertexes in shifted Polyline
// AShiftSize - Polyline Cordinates shift values as Integer Point
//
// Resulting Polyline buffer should have enough space to place shifted 
// coorinates.
//
procedure N_ShiftICoords( APSrcVert, APDstVert: PPoint;
                                    ANumVerts: integer; AShiftSize: TPoint );
var
  i: integer;
begin
  for i := 0 to ANumVerts-1 do
  begin
    APDstVert^.X := APSrcVert^.X + AShiftSize.X;
    APDstVert^.Y := APSrcVert^.Y + AShiftSize.Y;
    Inc( APSrcVert );
    Inc( APDstVert );
  end;
end; // procedure N_ShiftFCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_CalcRotatedRectCoords
//************************************************* N_CalcRotatedRectCoords ***
// Calculate Rotated Rectangle Coordinated
//
//     Parameters
// ASrcRect    - given interger Rectangle to rotate
// AAngle      - given Rotation angle in degree
// ADstEnvRect - calculated integer Envelope of given Rotated Rectangle (on 
//               output) (ADstEnvRect.UpperLeft has always (0,0) coordinates)
// AInpReper   - calculated input Reper - coordinates of three ASrcRect points 
//               (P1=UpperLeft, P2=UpperRight, P3=LowerLeft) (on output)
// AOutReper   - calculated output Reper - coordinates of these three points 
//               after rotation (on output)
//
procedure N_CalcRotatedRectCoords( const ASrcRect: TRect; AAngle: double;
               out ADstEnvRect: TRect; out AInpReper, AOutReper: TN_3DPReper );
var
  RadAngle, NormAngle, SinVal, CosVal: double;
  SrcSizeM1, DstSizeM1, Coef: TDPoint;
begin
  SrcSizeM1.X := ASrcRect.Right - ASrcRect.Left; // Size Minus 1
  SrcSizeM1.Y := ASrcRect.Bottom - ASrcRect.Top;

  ADstEnvRect.Left := 0;
  ADstEnvRect.Top  := 0;

  NormAngle := N_Get0360Angle( AAngle );
  if NormAngle > 180 then NormAngle := NormAngle - 360; // shift to (-180, +180) range

  with AInpReper do // Inp Reper, can be used for calculating AffCoefs6
  begin
    P1.X := ASrcRect.Left;
    P1.Y := ASrcRect.Top;
    P2.X := ASrcRect.Right;
    P2.Y := ASrcRect.Top;
    P3.X := ASrcRect.Left;
    P3.Y := ASrcRect.Bottom;
  end; // with AInpReper do

  with AOutReper do
  begin

  if NormAngle >= 0 then // Positive Angle means CCW direction
  begin
    if NormAngle < 90.0 then // 0 <= NormAngle < 90.0
    begin
      RadAngle := NormAngle * N_PI / 180.0; // in [0,PI/2) interval
      SinVal := Sin( RadAngle );
      CosVal := Cos( RadAngle );

      P1.X := 0;
      P1.Y := SrcSizeM1.X * SinVal;
      P2.X := SrcSizeM1.X * CosVal;
      P2.Y := 0;
      P3.X := SrcSizeM1.Y * SinVal;
      P3.Y := SrcSizeM1.X * SinVal + SrcSizeM1.Y * CosVal;

      DstSizeM1.X := P2.X + P3.X;
      ADstEnvRect.Right := Round( DstSizeM1.X );
      Coef.X := ADstEnvRect.Right / DstSizeM1.X;

      DstSizeM1.Y := P3.Y;
      ADstEnvRect.Bottom := Round( DstSizeM1.Y );
      Coef.Y := ADstEnvRect.Bottom / DstSizeM1.Y;
    end else // 90 <= NormAngle < 180.0
    begin
      NormAngle := NormAngle - 90;
      RadAngle := NormAngle * N_PI / 180.0; // in [0,PI/2) interval
      SinVal := Sin( RadAngle );
      CosVal := Cos( RadAngle );

      P1.X := SrcSizeM1.X * SinVal;
      P1.Y := SrcSizeM1.X * CosVal + SrcSizeM1.Y * SinVal;
      P2.X := 0;
      P2.Y := SrcSizeM1.Y * SinVal;
      P3.X := SrcSizeM1.Y * CosVal + SrcSizeM1.X * SinVal;;
      P3.Y := SrcSizeM1.X * CosVal;

      DstSizeM1.X := P3.X;
      ADstEnvRect.Right := Round( DstSizeM1.X );
      Coef.X := ADstEnvRect.Right / DstSizeM1.X;

      DstSizeM1.Y := P1.Y;
      ADstEnvRect.Bottom := Round( DstSizeM1.Y );
      Coef.Y := ADstEnvRect.Bottom / DstSizeM1.Y;

      P1.Y := P1.Y * Coef.Y;
      P1.X := P1.X * Coef.X;
      P2.Y := P2.Y * Coef.Y;
      P3.X := P3.X * Coef.X;
      P3.Y := P3.Y * Coef.Y;;
    end;
  end else // NormAngle < 0, Negative Angle means CW direction
  begin
    if NormAngle > -90.0 then // -90 < NormAngle <= 0
    begin
      RadAngle := -NormAngle * N_PI / 180.0; // in [0,PI/2) interval
      SinVal := Sin( RadAngle );
      CosVal := Cos( RadAngle );

      P1.X := SrcSizeM1.Y * SinVal;
      P1.Y := 0;
      P2.X := SrcSizeM1.Y * SinVal + SrcSizeM1.X * CosVal;
      P2.Y := SrcSizeM1.X * SinVal;
      P3.X := 0;
      P3.Y := SrcSizeM1.Y * CosVal;

      DstSizeM1.X := P2.X;
      ADstEnvRect.Right := Round( DstSizeM1.X );
      Coef.X := ADstEnvRect.Right / DstSizeM1.X;

      DstSizeM1.Y := P2.Y + P3.Y;
      ADstEnvRect.Bottom := Round( DstSizeM1.Y );
      Coef.Y := ADstEnvRect.Bottom / DstSizeM1.Y;
    end else // -180 < NormAngle <= -90.0
    begin
      NormAngle := -NormAngle - 90;
      RadAngle := NormAngle * N_PI / 180.0; // in [0,PI/2) interval
      SinVal := Sin( RadAngle );
      CosVal := Cos( RadAngle );

      P1.X := SrcSizeM1.Y * CosVal + SrcSizeM1.X * SinVal;
      P1.Y := SrcSizeM1.Y * SinVal;
      P2.X := SrcSizeM1.Y * CosVal;
      P2.Y := SrcSizeM1.X * CosVal + SrcSizeM1.Y * SinVal;
      P3.X := SrcSizeM1.X * SinVal;
      P3.Y := 0;

      DstSizeM1.X := P1.X;
      ADstEnvRect.Right := Round( DstSizeM1.X );
      Coef.X := ADstEnvRect.Right / DstSizeM1.X;

      DstSizeM1.Y := P2.Y;
      ADstEnvRect.Bottom := Round( DstSizeM1.Y );
      Coef.Y := ADstEnvRect.Bottom / DstSizeM1.Y;
    end;
  end; // else // NormAngle < 0, Negative Angle means CW direction

  //***** Update AOutReper by Coef(X,Y) (due to DstSizeM1(X,Y) Rounding)
  P1.X := P1.X * Coef.X;
  P1.Y := P1.Y * Coef.Y;
  P2.X := P2.X * Coef.X;
  P2.Y := P2.Y * Coef.Y;
  P3.X := P3.X * Coef.X;
  P3.Y := P3.Y * Coef.Y;

  end; // with AOutReper do

end; // procedure N_CalcRotatedRectCoords

//##path N_Delphi\SF\N_Tree\N_Gra1.pas\N_ProcessMainFormMove
//*************************************************** N_ProcessMainFormMove ***
// Process MainUserForm Move
//
// Set N_CurMonWAR, N_MainUserFormRect and clear all variables in N_Forms 
// Section of ini file if N_CurMonWAR was changed
//
procedure N_ProcessMainFormMove( AMainUserFormRect: TRect );
var
  MFCenter: TPoint;
  CurMonRect: TRect;
begin
  if not N_EnableMainFormMove then Exit;

  N_MainUserFormRect := AMainUserFormRect;
  MFCenter := N_RectCenter( N_MainUserFormRect );

  if 0 = N_PointInRect( MFCenter, N_CurMonWAR ) then Exit; // N_CurMonWAR is OK

  //***** Main Form center is not inside N_CurMonWAR, check all monitors

  CurMonRect := N_GetMonWARByRect( N_MainUserFormRect );

  if N_SameIRects( CurMonRect, N_CurMonWAR ) then Exit; // N_CurMonWAR is OK

  if N_CurMonWAR.Right = 0 then // just Initialize N_CurMonWAR
  begin
    N_CurMonWAR := CurMonRect;
    Exit;
  end;

  //***** Current monitor was changed

  N_Dump1Str( 'Main Form Monitor was changed' );
  N_CurMonWAR := CurMonRect;

//  N_ClearSavedFormCoords(); // clear N_Forms section (commented 22.08.2017)
end; // procedure N_ProcessMainFormMove


{
//******************************************************* N_GetSegmentAngle ***
// Calculate Angle in degree between given Segment and X axis
//
//     Parameters
// AP1    - first (strting) Float Point
// AP2    - second (ending) Float Point
// Result - Returns calculated angle in degree
//
// X axis direction is from left to right, Y axis direction is from top to down
// CCW (counter Clowise) angle direction from X axis assumed to be positive.
// For AP1=(0,0), AP2=(1,-1) Result = +45
//
function N_GetSegmentAngle( const AP1, AP2: TFPoint ): double;
var
  dx, dy: double;
begin

  dx := AP2.X - AP1.X;
  dy := AP1.Y - AP2.Y;

  if abs(dx) < 1.0e-10 then
    Result := 90.0*sign( dy )
  else
    Result := arctan2( dy, dx )*180/N_PI;
end; // function N_GetSegmentAngle
}

Initialization
  N_AddStrToFile( 'N_Gra1 Initialization' );

end.
