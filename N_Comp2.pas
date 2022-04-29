unit N_Comp2;
// Visual Components set #2:
//   Polyline_   Arc_        SArrow_       2DSpace_
//   AxisTics_   TextMarks_  AutoAxis_     2DFunc_
//   IsoLines_   2DLinHist_  LinHistAuto1_ PieChart_
//   Table_      CompsGrid_

// TN_CPCoordsType = ( cpctPix, cpctUser, cpctPercent ); // Component Polyline Coords Type
// TN_CPolyline    = packed record // Polyline Component Individual Params
// TN_RPolyline    = packed record // TN_UDPolyline RArray Record type
// TN_UDPolyline   = class( TN_UDCompVis ) // Polyline Component

// TN_CArcShapeType = ( castArc, castChord, castPie ); // Component Arc Shape Type
// TN_CArc          = packed record // Arc Component Individual Params
// TN_RArc          = packed record // TN_UDArc RArray Record type
// TN_UDArc         = class( TN_UDCompVis ) // Arc Component

// TN_SArrowFlags = set of ( safRounded );
// TN_CSArrow     = packed record // Straight Arrow Component Individual Params
// TN_RSArrow     = packed record // TN_UDSArrow (Straight Arrow) RArray Record type
// TN_UDSArrow    = class( TN_UDCompVis ) // SArrow Component

// TN_2DSAxisPos  = ( tdsHorizontal, tdsVertical );
// TN_2DSAxisType = ( tdsArgument,   tdsFunction );
// TN_2DSAxisDir  = ( tdsIncreasing, tdsDecreasing );
// TN_C2DSpace    = packed record // 2DSpace Component Individual Params
// TN_R2DSpace    = packed record // TN_UD2DSpace RArray Record type
// TN_UD2DSpace   = class( TN_UDCompVis ) // 2DSpace Component

// TN_CAxisTics   = packed record // AxisTics Component Individual Params
// TN_RAxisTics   = packed record // TN_UDAxisTics RArray Record type
// TN_UDAxisTics  = class( TN_UDCompVis ) // AxisTics Component

// TN_CTextMarks  = packed record // TextMarks Component Individual Params
// TN_RTextMarks  = packed record // TN_UDTextMarks RArray Record type
// TN_UDTextMarks = class( TN_UDCompVis ) // TextMarks Component

// TN_CAutoAxis   = packed record // AutoAxis Component Individual Params
// TN_RAutoAxis   = packed record // TN_UDAutoAxis RArray Record type
// TN_UDAutoAxis  = class( TN_UDCompVis ) // AutoAxis Component

// TN_2DFuncType  = ( tdftLine, tdftFill, tdftSum);
// TN_C2DFunc     = packed record // 2DFunc Component Individual Params
// TN_R2DFunc     = packed record // TN_UD2DFunc RArray Record type
// TN_UD2DFunc    = class( TN_UD2DSpace ) // 2DFunc Component

// TN_CIsoLinesFlags = Set Of ( ilfLines );
// TN_CIsoLines      = packed record // IsoLines Component Individual Params
// TN_RIsoLines      = packed record // TN_UDIsoLines RArray Record type
// TN_UDIsoLines     = class( TN_UD2DSpace ) // IsoLines Component

// TN_LHFlags      = set of ( lhfItemsColumn );
// TN_LHEColorMode = (lhcmGroups, lhcmColumns, lhcmItems );
// TN_LHESPFlags   = set of ( lhespfDummy1 ); // Elems Sizes and Positions Flags
// TN_LHElemsSPos  = packed record // Elems Sizes and Positions
// TN_C2DLinHist   = packed record // 2DLinHist Component Individual Params
// TN_R2DLinHist   = packed record // TN_UD2DLinHist RArray Record type
// TN_UD2DLinHist  = class( TN_UDCompVis ) // 2DLinHist Component

// TN_CLinHistAuto1  = packed record // LinHistAuto1 Component Individual Params
// TN_RLinHistAuto1  = packed record // TN_UDLinHistAuto1 RArray Record type
// TN_UDLinHistAuto1 = class( TN_UDCompVis ) // LinHistAuto1 Component

// TN_CPieChart  = packed record // PieChart Component Individual Params
// TN_RPieChart  = packed record // TN_UDPieChart RArray Record type
// TN_UDPieChart = class( TN_UDCompVis ) // PieChart Component

// TN_CTable     = packed record // Table Component Individual Params
// TN_RTable     = packed record // TN_UDTable RArray Record type
// TN_UDTable    = class( TN_UDCompVis ) // Table Component

// TN_CCompsGridCell = packed record // CompsGrid Cell Params
// TN_CCompsGrid     = packed record // CompsGrid Component Individual Params
// TN_RCompsGrid     = packed record // TN_UDCompsGrid RArray Record type
// TN_UDCompsGrid    = class( TN_UDCompVis ) // CompsGrid Component


interface
uses
     Windows, Graphics, Classes, Contnrs,
     K_Script1, K_UDT1,
     N_Types, N_Lib1, N_Gra0, N_Gra1, N_UDat4, N_Gra2, N_GCont, N_UDCMap,
     N_CompCL, N_CompBase, N_lib2, N_2dFunc1;

//***************************  Polyline Component  ************************

type TN_CPCoordsType = ( cpctPix, cpctUser, cpctPercent ); // Component Polyline Coords Type

type TN_CPolyline = packed record // Polyline Component Individual Params
  CPCoordsType: TN_CPCoordsType; // Polyline Coords Type
  CPReserved1: byte; // for alignment
  CPReserved2: byte; // for alignment
  CPReserved3: byte; // for alignment
  CPCoords:      TK_RArray; // Polyline Coords (RArray of TFPoint)
  CPolylineAttr: TK_RArray; // Polyline drawing attributes (RArray of TN_ContAttr)
end; // type TN_CPolyline = packed record
type TN_PCPolyline = ^TN_CPolyline;

type TN_RPolyline = packed record // TN_UDPolyline RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CPolyline:  TN_CPolyline;  // Component Individual Params
end; // type TN_RPolyline = packed record
type TN_PRPolyline = ^TN_RPolyline;

type TN_UDPolyline = class( TN_UDCompVis ) // Polyline_ Component
  UDPBufPixCoords: TN_FPArray;       // Polyline BufPix Coords for searchig
  UDPShapeCoords: TN_ShapeCoords;    // Polyline Coords object for drawing
  UDPFromBufPixCoefs4: TN_AffCoefs4; // Form BufPix back to CPCoordsType convertion coefs
                                     // (for wysiwyg Polyline Coords changing by Cursor)
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRPolyline;
  function  PDP  (): TN_PRPolyline;
  function  PISP (): TN_PCPolyline;
  function  PIDP (): TN_PCPolyline;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDPolyline = class( TN_UDCompVis )


//***************************  Arc Component  ************************

type TN_CArcShapeType = ( castArc, castChord, castPie ); // Component Arc Shape Type

type TN_CArc = packed record // Arc Component Individual Params
  CArcCoordsType: TN_CPCoordsType;  // Arc Coords Type
  CArcBorderType: TN_ArcBorderType; // Arc Border Type (Arc only, Chord or Pie)
  CAReserved1: byte; // for alignment
  CAReserved2: byte; // for alignment
  CArcEnvRect: TFRect;   // Arc Envelope Rect
  // Positive Angles are in CCW in Pix coords (Angle between X and Y axises = 270)
  CArcBegAngle: Float;   // Arc Start radius Angle in degree
  CArcEndAngle: Float;   // Arc Fin radius Angle in degree
  CArcAttr:   TK_RArray; // Arc drawing attributes (RArray of TN_ContAttr)
end; // type TN_CArc = packed record
type TN_PCArc = ^TN_CArc;

type TN_RArc = packed record // TN_UDArc RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CArc:       TN_CArc;       // Component Individual Params
end; // type TN_RArc = packed record
type TN_PRArc = ^TN_RArc;

type TN_UDArc = class( TN_UDCompVis ) // Arc_ Component
  UDABufPixCoords: TN_FPArray; // Arc BUFPix Coords for searchig:
  // UDABufPixCoords[0] - Upper Left EnvRect corner
  // UDABufPixCoords[1] - Lower Right EnvRect corner
  // UDABufPixCoords[2] - Center of EnvRect
  // UDABufPixCoords[3] - Arc Beg Point
  // UDABufPixCoords[4] - Arc End Point

  UDAShapeCoords: TN_ShapeCoords; // Arc Coords for drawing
  UDAFromBufPixCoefs4: TN_AffCoefs4; // Form BufPix back to CPCoordsType convertion coefs
                                     // (for wysiwyg Arc Coords changing by Cursor)
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRArc;
  function  PDP  (): TN_PRArc;
  function  PISP (): TN_PCArc;
  function  PIDP (): TN_PCArc;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDArc = class( TN_UDCompVis )


//***************************  SArrow Component  ************************

// type TN_CSArrow  is defined in N_CompCL

type TN_RSArrow = packed record // TN_UDSArrow (Straight Arrow) RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CSArrow:    TN_CSArrow;    // Component Individual Params
end; // type TN_RSArrow = packed record
type TN_PRSArrow = ^TN_RSArrow;

type TN_UDSArrow = class( TN_UDCompVis ) //***** SArrow_ Component
  constructor Create;  override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRSArrow;
  function  PDP  (): TN_PRSArrow;
  function  PISP (): TN_PCSArrow;
  function  PIDP (): TN_PCSArrow;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDSArrow = class( TN_UDCompVis )


//***************************  2DSpace Component  ************************

type TN_2DSAxisPos  = ( tdsHorizontal, tdsVertical );
type TN_2DSAxisType = ( tdsArgument,   tdsFunction );
type TN_2DSAxisDir  = ( tdsIncreasing, tdsDecreasing );

type TN_AutoAxisFlags = Set Of ( aafDummy1 );

type TN_C2DSpace = packed record // 2DSpace Component Individual Params
  TDSArgAxisPos:    TN_2DSAxisPos;
  TDSArgDirection:  TN_2DSAxisDir;
  TDSFuncDirection: TN_2DSAxisDir;
  TDSReserved1: byte;  // for alignment
  TDSArgMin:  double;  // Minimal Argument Value
  TDSArgMax:  double;  // Maximal Argument Value
  TDSFuncMin: double;  // Minimal Function Value
  TDSFuncMax: double;  // Maximal Function Value
end; // type TN_C2DSpace = packed record
type TN_PC2DSpace = ^TN_C2DSpace;

type TN_R2DSpace = packed record // TN_UD2DSpace RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  C2DSpace:   TN_C2DSpace;   // Component Individual Params
end; // type TN_R2DSpace = packed record
type TN_PR2DSpace = ^TN_R2DSpace;

type TN_UD2DSpace = class( TN_UDCompVis ) //***** 2DSpace_ Component,
                                          // Parent Class for 2DCurve, 2DLinHist, ...
                                          // or may be used as Panel with 2DSpace
  AF2U6: TN_AffCoefs6; // coefs for ArgFunc -> User Coords convertion
  AF2P6: TN_AffCoefs6; // coefs for ArgFunc -> Pixel Coords convertion

  //*** Following boolean fields are calculated by CalcAxisInfo Self method:
  AxisIsVertical: boolean; // Axis Is Vertical
  AxisIsArgument: boolean; // Axis Is Argument
  AxisIsLess:     boolean; // Axis Is Lefter or Upper than Self

  constructor Create;  override;
  destructor  Destroy; override;
  function  PSP  (): TN_PR2DSpace;
  function  PDP  (): TN_PR2DSpace;
  function  PISP (): TN_PC2DSpace;
  function  PIDP (): TN_PC2DSpace;
  procedure PascalInit (); override;
  procedure InitRunTimeFields ( AInitFlags: TN_CompInitFlags ); override;
  procedure BeforeAction  (); override;
  procedure CalcCoefs6    ( AAlways: boolean = False );
  procedure CalcAxisInfo      ( AAxisComp: TN_UDCompVis );
  procedure CalcAxisStep      ( AAFlags: TN_AutoAxisFlags; APMinStep: TN_PMScalSize;
                                out AResStep, AResBase: double;
                                out AResStepVal, AResStepExp: integer );
  procedure GetTicksMidPoints ( AAxisComp: TN_UDCompVis; ABase, AStep: double;
                                APixShift: integer; var AResPoints: TN_IPArray;
                                var AResValues: TN_DArray );
end; // type TN_UD2DSpace = class( TN_UDCompVis )


//***************************  AxisTics Component  ************************

type TN_CAxisTics = packed record // AxisTics Component Individual Params
  ATType: TN_2DSAxisType;  // Axis Type (Type definition is before 2DSpace Component)
  ATReserved1: byte; // for alignment
  ATReserved2: byte;
  ATReserved3: byte;
  ATBaseZ:   double;       // Axis Tics Base Coord (X or Y)
  ATBaseZs:  TK_RArray;    // Array of Axis Tics Base Coords (X or Y) (RArray of double)
  ATStepZ:   double;       // Step between Tics (X or Y)
//  ATBPPos:   float;        // Tics Base Point Position (for calc. BPPixMarks)
  ATAttribs: TK_RArray;    // Tics Attributes (RArray of TN_ContAttr)
  AT2DSpace: TN_UD2DSpace; // Axis Tics 2D Space
end; // type TN_CAxisTics = packed record
type TN_PCAxisTics = ^TN_CAxisTics;

type TN_RAxisTics = packed record // TN_UDAxisTics RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CAxisTics:  TN_CAxisTics;  // Component Individual Params
end; // type TN_RAxisTics = packed record
type TN_PRAxisTics = ^TN_RAxisTics;

type TN_UDAxisTics = class( TN_UDCompVis ) //***** AxisTics_ Component
  ATTicValues:   TN_DArray;  // Tics Values  (for TextMarks component)
  ATTicPixRects: TN_FRArray; // Base Rects in float Pix (for TextMarks component)

  constructor Create;  override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRAxisTics;
  function  PDP  (): TN_PRAxisTics;
  function  PISP (): TN_PCAxisTics;
  function  PIDP (): TN_PCAxisTics;
  procedure PascalInit   (); override;
  procedure BeforeAction (); override;
end; // type TN_UDAxisTics = class( TN_UDCompVis )


//***************************  TextMarks Component  ************************

type TN_TMFlags = set of( tmfLHGroups, tmfLHColumns,
                          tmfLHElemsInGroup, tmfLHValues,
                          tmfBCValues, tmfOwnValues,
                          tmfMultiRow, tmfNewMode );
// tmfLHGroups   - one string for LinHist(TMBaseComp) Group
// tmfLHColumns  - same string for several Columns in all LinHist(TMBaseComp)
//                   Groups with same Index in Group (used only in Old Mode)
// tmfLHElemsInGroup - one String for each Element in Group
//                     (all Elemes with same index in Group have same String, same as tmfLHColumns)
// tmfLHValues   - one String for each Value
// tmfBCValues   - Values are given in TMBaseComp (LinHist, PieChart or AxisTics)
// tmfOwnValues  - Values are given in TMValues RArray of double
// tmfMultiRow   - Multi Row Text, use ParaBox formatting
// tmfNewMode    - Drawing with New params (Temporary)

type TN_TMStyleFlags = Set Of ( tmsfAddAuxBefore );

type TN_TMCoordsType = ( tmctBaseComp, tmctSelfInPrc, tmctSelfInmm,
                         tmctUniform, tmctFixed );
// tmctBaseComp  - use Rects or Points in TMBaseComp (and Style.TMSBPPos if Rects)
//                   (TMBaseComp can be LinHist, PieChart, TextMarks or AxisTics)
//                   (Rects or Points coords are in Absolute float pixels)
// tmctSelfInPrc - use Coords in TMBPCoords RArray as % of CompIntPixRect
// tmctSelfInmm  - use Coords in TMBPCoords RArray as millimeters in CompIntPixRect
// tmctUniform   - Uniform layout inside CompIntPixRect using TMUniformLP params
// tmctFixed     - Fixed value in Style.TMSBPPos (% in Self.CompIntPixRect)

type TN_TMStyle = packed record // Text Marks Style Params
  TMSFlags: TN_TMStyleFlags;  // Style Flags
  TMSFReserved1: byte; // for alignment
  TMSFReserved2: byte;
  TMSFReserved3: byte;
  TMSValsFmt:    string;   // Double Values Pascal Format (for Value to String convertion)
  TMSTextColor: integer;   // Text Color
  TMSFont:      TObject;   // Text Font (VArray of TN_NFont)
  TMSStrPos: TN_StrPosParams; // Strings Position Params
  TMSBPPos:  TFPoint;      // Base Point X,Y Pos in % (in Rect, given by TMFlags)
  TMSAuxString: string;    // Aux String (used for marking main string)
  TMSBackPanel: TK_RArray; // Background Panel Params (RArray of TN_CPanel)
end; // type TN_TMStyle = packed record
type TN_PTMStyle = ^TN_TMStyle;

TN_CTMRectType = ( tmrtGiven, tmrtText, tmrtSelf, tmrtParent, tmrtGrandParent, tmrtSkip );

type TN_CTMStyleElem = packed record // TextMarks Style Element
  TMSERectType: TN_CTMRectType; // Rect Type (Given, Text, Self, Parent, GrandParent, Skip)
  TMSEReserved1: byte;
  TMSEReserved2: byte;
  TMSEReserved3: byte;
  TMSEPanel: TN_CPanel;
end; // type TN_CTMStyleElem = packed record
type TN_PCTMStyleElem = ^TN_CTMStyleElem;

type TN_TMNStyle = packed record // Text Marks New Style Params
  TMSFlags: TN_TMStyleFlags;  // Style Flags
  TMSFReserved1: byte; // for alignment
  TMSFReserved2: byte;
  TMSFReserved3: byte;
  TMSValsFmt:    string;   // Double Values Pascal Format (for Value to String convertion)
  TMSFont:      TObject;   // Text Font (VArray of TN_NFont)
  TMSTextColor: integer;   // Text Color
  TMSAuxString: string;    // Aux String (used for marking main string)
  TMSTRSizePos: TN_RectSizePos; // Text Rect Size and Position relative to Inp Rect

  TMSInpPanel:    TK_RArray; // Inp Rect Panel Params (RArray of TN_CPanel)
  TMSTextPanel:   TK_RArray; // Text Rect Panel Params (RArray of TN_CPanel)
  TMSParaBox:     TK_RArray; // Text Attributes - RArray of one TN_CParaBox element
end; // type TN_TMNStyle = packed record
type TN_PTMNStyle = ^TN_TMNStyle;

type TN_CTextMarks = packed record // TextMarks Component Individual Params
  TMFlags:       TN_TMFlags;      // Main Flags
  TMXCoordsType: TN_TMCoordsType; // X-Coords Type
  TMYCoordsType: TN_TMCoordsType; // Y-Coords Type
  TMReserved1: byte;  // for alignment
  TMUniformLP: TN_ODFSParams; // Uniform Layout Params (One Dim Layout)
  TMMaxTextmmWidth: float;    // Max Text Width in mm

  TMStrings:       TK_RArray; // Self Strings (RArray of String)
  TMSelfRects:     TK_RArray; // Self Rects Coords (RArray of FRect)
  TMValues:        TK_RArray; // Self double Values
  TMBaseComp:   TN_UDCompVis; // Base Component with BP Coords, Values or both

  TMMainStyle:    TN_TMStyle; // Main Drawing Style
  TMMarkStyles:    TK_RArray; // Alternative Styles for Marking some strings (RArray of TN_TMStyle)
  TMMarkStyleInds: TK_RArray; // Indexes of TMMarkStyles RArray (RArray of byte)

  TMSValsFmt:    string;   // Double Values Pascal Format (for Value to String convertion)
//  TMGroupStyleInds: TK_RArray; // Group Style Inds in TMStyles RArray (RArray of bytes)
//  TMElemStyleInds:  TK_RArray; // Element in Group Style Inds in TMStyles RArray (RArray of bytes)
//  TMValueStyleInds: TK_RArray; // Value Style Inds in TMStyles RArray (RArray of bytes)
//  TMStyles:     TK_RArray; // RArray of strings, each string is a list of tokens (Phase and StyleElem index)
//  TMStyleElems: TK_RArray; // Style Elements - RArray of TN_C2DLHStyleElem

  TMNStyles:    TK_RArray; // Styles - RArray of TN_TMNStyle
  TMNStyleInds: TK_RArray; // Indexes of TMNStyles RArray (RArray of byte)
end; // type TN_CAxTextMarks = packed record
type TN_PCTextMarks = ^TN_CTextMarks;

type TN_RTextMarks = packed record // TN_UDTextMarks RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CTextMarks: TN_CTextMarks; // Component Individual Params
end; // type TN_RTextMarks = packed record
type TN_PRTextMarks = ^TN_RTextMarks;

type TN_UDTextMarks = class( TN_UDCompVis ) //***** TextMarks_ Component
  TMPixMarkRects: TN_FRArray; // Mark Rects coords in float Pixel (for possible use in another TextMarks)

  constructor Create;  override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRTextMarks;
  function  PDP  (): TN_PRTextMarks;
  function  PISP (): TN_PCTextMarks;
  function  PIDP (): TN_PCTextMarks;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDTextMarks = class( TN_UDCompVis )


//***************************  AutoAxis Component  ************************

type TN_AAFlags = Set Of ( aafSkipArrow );

type TN_AATicsParams = packed record
  AATSize:     TFPoint;      // X - Tics Upper(Left) Part Size in LLW, Y - Lower(Right) Part Size
  AATMinStep:  TN_MScalSize; // Minimal Step between Tics
  AATAttribs:  TK_RArray;    // Tics Line Attributes (RArray of TN_ContAttr)
end; // type TN_AATicsParams = packed record
type TN_PAATicsParams = ^TN_AATicsParams;

type TN_CAutoAxis = packed record // AutoAxis Component Individual Params
  AAFlags: TN_AAFlags;      // AutoAxis Flags
  AAReserved1: byte; // for alignment
  AAReserved2: byte;
  AAReserved3: byte;
  AALinePos:  TFPoint;      // X - shift from AA2DSpace Comp, Y - TextMarks Shift
  AAArrowParams: TFRect;    // Left-Length, Top-Width, Right-Type, Bottom-Not Used
  AALineAttribs: TK_RArray; // Main Line Attributes (RArray of TN_ContAttr)

  AABigTics:    TN_AATicsParams; // Big Tics Params
  AAMiddleTics: TN_AATicsParams; // Middle Tics Params
  AASmallTics:  TN_AATicsParams; // Small Tics Params
  AAFont:       TObject;   // Font for Text Marks and common multiplier
  AACMShift:    TFPoint;   // Common Multiplier additional shift in LLW
  AAMarksFmt:    string;   // Pascal Format string for Text Marks
  AAUnitsName:   string;   // Units Name (to concatenate with Text Marks)
  AA2DSpace: TN_UD2DSpace; // Auto Axis 2D Space
end; // type TN_CAutoAxis = packed record
type TN_PCAutoAxis = ^TN_CAutoAxis;

type TN_RAutoAxis = packed record // TN_UDAutoAxis RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CAutoAxis: TN_CAutoAxis;   // Component Individual Params
end; // type TN_RAutoAxis = packed record
type TN_PRAutoAxis = ^TN_RAutoAxis;

type TN_UDAutoAxis = class( TN_UDCompVis ) // AutoAxis_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRAutoAxis;
  function  PDP  (): TN_PRAutoAxis;
  function  PISP (): TN_PCAutoAxis;
  function  PIDP (): TN_PCAutoAxis;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDAutoAxis = class( TN_UDCompVis )


//***************************  2DFunc Component  ************************

type TN_2DFuncType   = ( tdftLine, tdftFill );
type TN_2DFuncFlags  = Set Of ( tdffIncRange );

type TN_2DCurveType  = ( tdctSolid );
type TN_2DCurveFlags = Set Of ( tdcfdummy1 );

type TN_2DCurve = packed record // one 2DFunc Curve Params
  CurveType:  TN_2DCurveType;  // Curve Type
  CurveFlags: TN_2DCurveFlags; // Curve Flags
  CurveReserved1: byte;   // for alignment
  CurveReserved2: byte;
  CurveArgVals:    TK_RArray; // Curve Argument Values (RArray of double)
  CurveFuncVals:   TK_RArray; // Curve Function Values (RArray of double)
//  CurveAFVals:     TK_RArray; // Curve (Arg,Func) Values (RArray of TN_DPoint)
  CurveAttr:       TK_RArray; // Curve drawing attributes (RArray of TN_ContAttr)
  CurveText: string;          // Curve Text String
end; // type TN_2DCurve = packed record
type TN_P2DCurve = ^TN_2DCurve;

type TN_C2DFunc = packed record // 2DFunc Component Individual Params
  TDFuncType:  TN_2DFuncType;  // 2DFunc Type
  TDFuncFlags: TN_2DFuncFlags; // 2DFunc Flags
  TDReserved1: byte;           // for alignment
  TDReserved2: byte;
  TDCurves:  TK_RArray;        // 2DFunc Curves (RArray of TN_2DCurve)
end; // type TN_C2DFunc = packed record
type TN_PC2DFunc = ^TN_C2DFunc;

type TN_R2DFunc = packed record // TN_UD2DFunc RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  C2DSpace:   TN_C2DSpace;   // Component 2DSpace params
  C2DFunc:    TN_C2DFunc;    // Component Individual Params
end; // type TN_R2DFunc = packed record
type TN_PR2DFunc = ^TN_R2DFunc;

type TN_UD2DFunc = class( TN_UD2DSpace ) //***** 2DFunc_ Component
  TDFAttribs:  TK_RArray;  // RArray of RArray of TN_ContAttr (for Legend only)
  constructor Create;  override;
  destructor  Destroy; override;
  function  PSP  (): TN_PR2DFunc;
  function  PDP  (): TN_PR2DFunc;
  function  PISP (): TN_PC2DFunc;
  function  PIDP (): TN_PC2DFunc;
  procedure PascalInit    (); override;
  procedure BeforeAction  (); override;
end; // type TN_UD2DFunc = class( TN_UD2DSpace )


//***************************  IsoLines Component  ************************

type TN_CIsoLinesFlags = Set Of ( ilfAutoArgFunc );

type TN_CIsoLines = packed record // IsoLines Component Individual Params
  CILFlags:   TN_CIsoLinesFlags; // some Flags
  CILIntMode: TN_2DIntMode;      // Interpolation mode for creating
  CILReserved1: byte;
  CILReserved2: byte;
  CILVMatr:    TK_RArray;  // Values Matrix (RArray of double)
  CILMMValues: TK_RArray;  // RArray of TN_MinMaxValues
  CILAttribs:  TK_RArray;  // RArray of RArray of TN_ContAttr
  CILTexts:    TK_RArray;  // IsoLine(IzoCont) comment RArray of String
  CILIntMatrScale: integer;  // Interpolated Matrix Scale (Integer) coefs
                             // ( CILIntMatrScale=2 means than IntMatr will have
                             //   4 times more points than Source CILVMatr )
  CILMatrRect: TFRect;     // Arg(X) and Func(Y) Matrix corner values

  CILGridLinesML:  TN_UDMapLayer; // Pattern MapLayer for drawing Grid Lines
  CILGridLabelsML: TN_UDMapLayer; // Pattern MapLayer for drawing Grid Node Labels
  CILSplineLine: TN_SplineLineParams; // Spline IsoLine params
end; // type TN_CIsoLines = packed record
type TN_PCIsoLines = ^TN_CIsoLines;

type TN_RIsoLines = packed record // TN_UDIsoLines RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  C2DSpace:   TN_C2DSpace;   // Component 2DSpace params
  CIsoLines:  TN_CIsoLines;  // Component Individual Params
end; // type TN_RIsoLines = packed record
type TN_PRIsoLines = ^TN_RIsoLines;

type TN_UDIsoLines = class( TN_UD2DSpace ) //***** IsoLines_ Component
  IntVMatr: TN_FVMatr;  // Interpolated Matrix

  constructor Create;  override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRIsoLines;
  function  PDP  (): TN_PRIsoLines;
  function  PISP (): TN_PCIsoLines;
  function  PIDP (): TN_PCIsoLines;
  procedure PascalInit    (); override;
  procedure BeforeAction  (); override;
  function  CreateVisRepr (): TN_UDBase;
end; // type TN_UDIsoLines = class( TN_UDCompVis )


//***************************  2DLinHist Component  ************************

type TN_LHFlags = set of ( lhfRelItems, lhfStackedColumns, lhfGroupsAlongX, lhfOldParams );
// lhfRelItems       - all Stacked Columns are of same size (=100%)
// lhfStackedColumns - Group consists of several Elemes in one Column
// lhfGroupsAlongX   - Values in One Group are Matr Columns (NumGroups=NX)
// lhfOldParams      - Use Old Draw method (temporary)

//Old Var:
type TN_LHColorMode = ( lhcmGElems, lhcmGroups, lhcmValues );

type TN_LHExtColorMode = ( lhecmGElems, lhecmGroups, lhecmValues );
//   How to interpret LHExtColors RArray:
// lhecmGElems - Colors in LHExtColors are Colors of Elements in Group
// lhecmGroups - Colors in LHExtColors are Colors of Groups
// lhecmValues - Colors in LHExtColors are Colors of Matrix elements

//Old Var:
type TN_LHMarkMode  = ( lhmmNothing, lhmmGElems, lhmmGroups, lhmmValues );
//type TN_LHStyleIndType = ( lhsGElems, lhsGroups, lhsValues );
// lhsGElems - Style Index is Index of Element in a Group
// lhsGroups - Style Index is Index of a Group
// lhsValues - Style Index is Index of a Value

type TN_C2DLHRectType = ( lhrtElemRect, lhrtSelf, lhrtParent, lhrtGrandParent, lhrtSkipRect );
// lhrtElemRect    - Use Group or Elem Rect
// lhrtLinHistRect - Update by Self(LinHist) CompIntPixRect
// lhrtParent      - Update by Parent CompIntPixRect
// lhrtGrandParent - Update by GrandParent CompIntPixRect
// lhrtSkipRect    - Skip Drawing Any Rect

//Old Var:
type TN_C2DLHStyleFlags = Set Of ( lhsfDoNotDraw, lhsfParent, lhsfGrandParent );

//Old Var:
type TN_C2DLHStyle = packed record // 2DLinHist Style (Old)
  LHSFlags: TN_C2DLHStyleFlags; // Self Flags
  LHSReserved1: byte;
  LHSReserved2: byte;
  LHSReserved3: byte;
  LHSFillColor:     integer;   // Style All Elems Fill Color
  LHSBorderColor:   integer;   // Style All Elems Border Color
  LHSBorderWidth:   float;     // Style All Elems Border Width in LSU
  LHSAuxFillParams: TK_RArray; // Style Additional Fill Params (Undef, not used now)
  LHSAddMarkRect:   TFRect;    // Additional MarkRect borders shift in LSU
  LHSMarkPanel:     TK_RArray; // one TN_CPanel element, used for Marking Background
//  LHSValStrPos:     float;     // Position of Values as Strings (0-1)
end; // type TN_C2DLHStyle = packed record
type TN_PC2DLHStyle = ^TN_C2DLHStyle;

type TN_C2DLHStyleElem = packed record // 2DLinHist Style Element
  LHSERectType: TN_C2DLHRectType; // Rect Type (Elem, Self, Parent, GrandParent, Skip)
  LHSEReserved1: byte;
  LHSEReserved2: byte;
  LHSEReserved3: byte;
  LHSEPanel: TN_CPanel;
end; // type TN_C2DLHStyleElem = packed record
type TN_PC2DLHStyleElem = ^TN_C2DLHStyleElem;

type TN_C2DLinHist = packed record // 2DLinHist Component Individual Params
  LHFlags:     TN_LHFlags;     // Self Flags

// OldVar:
  LHColorMode: TN_LHColorMode; // Color Mode (how to use LHFillColors array)

  LHExtColorMode: TN_LHExtColorMode; // How to use LHExtColors array

// OldVar:
  LHMarkMode:  TN_LHMarkMode;  // Mark  Mode (how to use LHMarkStInds array)
//  LHStyleIndType: TN_LHStyleIndType; // Style Mode (how to use LHMarkStInds array)
  LHReserved1: Byte;

  LHGroupsLP:  TN_ODFSParams; // Groups Layout Params
  LHGroupNames:  TK_RArray;   // Group Names (used by TextMarks Component)
//  LHGroupNPos:   float;       // Group Names position

  LHColumnsLP:  TN_ODFSParams; // Columns Layout Params
  LHColumnNames: TK_RArray;    // Column Names (used by TextMarks Component)
//  LHColumnNPos:  float;        // Column Names position

  LHExtColors: TK_RArray;    // Groups, Columns or Items Fill Colors (see LHExtColorMode, RArray of Color)
  LHFillColors: TK_RArray;    // Groups, Columns or Items Fill Colors (see LHColorMode, RArray of Color)

// old fields to remove:
  LHMainStyles: TK_RArray;    // Main Styles (RArray of TN_C2DLHStyle)
  LHValStyles:  TK_RArray;    // Spec. Values Styles (RArray of TN_C2DLHStyle)
  LHMarkStyles: TK_RArray;    // Mark Styles (RArray of TN_C2DLHStyle)

  LHValues:     TK_RArray; // RArray of double Values (see lhfStackedColumns flag in LHFlags )

// old fields to remove:
  LHValStyleInds:  TK_RArray; // Array of LHValStyles Inds+1 (syncro with LHValues)
  LHMarkStyleInds: TK_RArray; // Array of LHMarkStyles Inds+1 (see LHMarkMode)

  LHGRectStyleInds: TK_RArray; // whole Group Rect Style Inds in LHStyles RArray (RArray of bytes)
  LHGroupStyleInds: TK_RArray; // Group Style Inds (for Elem Rects) in LHStyles RArray (RArray of bytes)
  LHElemStyleInds:  TK_RArray; // Element in Group Style Inds in LHStyles RArray (RArray of bytes)
  LHValueStyleInds: TK_RArray; // Value Style Inds in LHStyles RArray (RArray of bytes)

  LHStyles:     TK_RArray; // RArray of strings, each string is a list of tokens (Phase and StyleElem index)
  LHStyleElems: TK_RArray; // Style Elements - RArray of TN_C2DLHStyleElem

  LHFuncBase:   double;    // Columns origin (needed for negative Values)
end; // type TN_C2DLinHist = packed record
type TN_PC2DLinHist = ^TN_C2DLinHist;

type TN_R2DLinHist = packed record // TN_UD2DLinHist RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  C2DSpace:   TN_C2DSpace;   // Component 2DSpace params
  C2DLinHist: TN_C2DLinHist; // Component Individual Params
end; // type TN_R2DLinHist = packed record
type TN_PR2DLinHist = ^TN_R2DLinHist;

type TN_UD2DLinHist = class( TN_UD2DSpace ) //***** 2DLinHist_ Component
  LHPixGroupRects: TN_FRArray; // Groups Rects coords in float Pixel (for TextMarks Comp)
  LHPixElemRects:  TN_FRArray; // Elems Rects coords in float Pixel (for TextMarks Comp)

  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PR2DLinHist;
  function  PDP  (): TN_PR2DLinHist;
  function  PISP (): TN_PC2DLinHist;
  function  PIDP (): TN_PC2DLinHist;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UD2DLinHist = class( TN_UD2DSpace )


//***************************  LinHistAuto1 Component  ************************

type TN_LHAFlags = Set of ( lhafSkipMainHeader,  lhafSkipBlockHeaders,
                            lhafSkipElemsNames,  lhafSkipValTexts,
                            lhafSkipFuncsTicks,  lhafSkipLegend,
                            lhafBlockHeadersBelow,
                            lhafDummy1, lhafDummy2 );
// lhafBlockHeadersBelow - Draw Block Headers Below LinHist Blocks

type TN_LHAType = ( lhatSimple, lhatStacked );

type TN_LHAOrient = ( lhaoHorCol, lhaoVertCol );

type TN_CLinHistAuto1 = packed record // LinHistAuto1 Component Individual Params
  LHAFlags:       TN_LHAFlags;    // LinHistAuto1 Flags (2 bytes)
  LHAType:        TN_LHAType;     // LinHistAuto1 Type
  LHAOrient:      TN_LHAOrient;   // Columns Orientation
  LHABlocksHorAlign:  TN_HVAlign; // Blocks Horizontal alignment
  LHABlocksVertAlign: TN_HVAlign; // Blocks Vertical alignment
  LHAReserved1: byte; // for alignment
  LHAReserved2: byte; // for alignment

  LHAWholeMinSize:    TFPoint; // Whole Component (Self) Min X,Y Sizes in mm
  LHAWholeMaxSize:    TFPoint; // Whole Component (Self) Max X,Y Sizes in mm
  LHAPatLHSize:       TFPoint; // Pattern LinHist X,Y Size in mm.
                               // (AcrossSize is LHAPatLHSize (X or Y) if LHAElemsFixedSize=0)
  LHAElemsFixedSize:  float;   // One Column Fixed Size in mm (Width for Vertical Column)
                               // or 0 if ColWidth shold be calculated by given LHAPatLHSize
  LHAElemsNamesWidth: float;   // Elems Names Width in mm
  LHAValTextsWidth:   float;   // ValTexts Width in mm
  LHAIntGapSize:      TFPoint; // Internal X,Y Gap between Blocks Sizes in mm
  LHALTRBPaddings:    TFRect;  // LTRB (Left,Top,Right,Bottom) Paddings in mm for Blocks alignment
  LHAMaxLegHeight:    float;   // Bottom Rect Height in mm where to place Legend
  LHAMaxBlocksInRow:  integer; // Max Blocks In Row (if = 0 - any number of Blocks is OK)

  LHAUserParams:    TN_UDBase; // (should be TN_UDCompBase)
  LHAMainHeader:    TN_UDBase; // (should be TN_UDParaBox)
  LHABlockHeader:   TN_UDBase; // (should be TN_UDParaBox)
  LHAElemsNames:    TN_UDBase; // (should be TN_UDTextMarks)
  LHAValTexts:      TN_UDBase; // (should be TN_UDTextMarks)
  LHAPatLinHist:    TN_UDBase; // (should be TN_UD2DLinHist)
  LHAFuncsTicks:    TN_UDBase; // (should be TN_UDAxisTics)
  LHALegend:        TN_UDBase; // (should be TN_UDLegend)
end; // type TN_CLinHistAuto1 = packed record
type TN_PCLinHistAuto1 = ^TN_CLinHistAuto1;

type TN_RLinHistAuto1 = packed record // TN_UDLinHistAuto1 RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CLinHistAuto1: TN_CLinHistAuto1; // Component Individual Params
end; // type TN_RLinHistAuto1 = packed record
type TN_PRLinHistAuto1 = ^TN_RLinHistAuto1;

type TN_UDLinHistAuto1 = class( TN_UDCompVis ) // LinHistAuto1_ Component
  UDLHAWrkParams: TN_BArray; // for passing params calculated in PrepRootComp to BeforeAction

  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRLinHistAuto1;
  function  PDP  (): TN_PRLinHistAuto1;
  function  PISP (): TN_PCLinHistAuto1;
  function  PIDP (): TN_PCLinHistAuto1;
  procedure PascalInit   (); override;
  procedure PrepRootComp (); override;
  procedure BeforeAction (); override;
end; // type TN_UDLinHistAuto1 = class( TN_UDCompVis )


//***************************  PieChart Component  ************************

type TN_PieChartFlags = Set of ( pcfClockWise, pcfAutoOrder,
                                 pcfShowPercents );

type TN_CPieChart = packed record // PieChart Component Individual Params
  PCFlags: TN_PieChartFlags; // PieChart Flags
  PCReserved1: byte;   // for alignment
  PCReserved2: byte;
  PCReserved3: byte;
//  PCCenter:  TFPoint;  // PieChart Ellipse Center in percents of CompIntPixRect
//  PCSize:    TFPoint;  // PieChart Ellipse X,Y Sizes in percents of CompIntPixRect
  PCVSHeight: float;   // PieChart Ellips VertSide Height in percents of CompIntPixRect
  PCBegAngle: float;   // Angle of First Pie segment

  PCBordersColor: integer; // All Borders (Pie, VertSide, Ellipse) Color
  PCBordersWidth: float;   // All Borders Width
  PCVSColorCoef:  float;   // Vertical Sides of Pie Segments Color (in % of PCColors)

  PCValStrPos:      float; // Pie Value String Position (0-center, 1-Ellipse border)
  PCNamePos:        float; // Pie Name String Position (0-center, 1-Ellipse border)
  PCValStrMinAngle: float; // do not show Value String if Angle < PCValStrMinAngle
  PCOtherMinAngle:  float; // All elements < PCOtherMinAngle will be drawn together

  PCValues:  TK_RArray;  // RArray Double vector with values to visualize
  PCColors:  TK_RArray;  // RArray Integer vector with fill Colors
end; // type TN_CPieChart = packed record
type TN_PCPieChart = ^TN_CPieChart;

type TN_RPieChart = packed record //***** TN_UDPieChart RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CPieChart:  TN_CPieChart;  // Component Individual Params
end; // type TN_RPieChart = packed record
type TN_PRPieChart = ^TN_RPieChart;

type TN_UDPieChart = class( TN_UDCompVis ) // PieChart_ Component
  PieValues:        TN_DArray; // Pie Values for converting to Strings
  BPPixEllCenter:     TFPoint; // Ellipse Center in float Pix for Strings positioning
  BPPixValStrings: TN_FPArray; // Base Points in float Pix for Pie Value Strings
  BPPixNames:      TN_FPArray; // Base Points in float Pix for Pie Names

  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRPieChart;
  function  PDP  (): TN_PRPieChart;
  function  PISP (): TN_PCPieChart;
  function  PIDP (): TN_PCPieChart;
  procedure PascalInit   (); override;
  procedure BeforeAction (); override;
end; // type TN_UDPieChart = class( TN_UDCompVis )


//***************************  Table Component  ************************

type TN_TCType  = ( tctText );
type TN_TCFlags = set of ( tcfVerticalText, tcfRowParams );
type TN_TaFlags = set of ( tafL1Macros );

type TN_TaRowColumn = packed record // one Table Row or one Table Column params
  RCSize:       TN_MScalSize;
  RCMinPixSize: integer;
  RCAttr:       string;    // Row/Col Text Attributes (for Export to HTML)
  RCPanel:      TK_RArray; // one TN_CPanel record or nil
  RCParaBox:    TK_RArray; // one TN_CParaBox record or nil
end; // TN_TaRowColumn = packed record
type TN_PTaRowColumn = ^TN_TaRowColumn;

type TN_TaCell = packed record // one Table Cell individual Params
  TCType:  TN_TCType;      // Cell Type
  TCFlags: TN_TCFlags;     // Cell Flags
  TCReserved1: Byte;
  TCReserved2: Byte;
  TCMText:      string;    // Cell Macro Text
  TCTextBlocks: TK_RArray; // RArray of TN_OneTextBlock
  TCParaBox:    TK_RArray; // one TN_CParaBox record or nil
  TCPanel:      TK_RArray; // one TN_CPanel record or nil
  TCComp:   TN_UDCompBase; // Cell Component
  TCValue:      double;    // Cel Numerical Value
  TCSPLProc:    string;    // Cell SPL Procedure
end; // TN_TaCell = packed record
type TN_PTaCell = ^TN_TaCell;

type TN_TaSBFlags = Set of ( tsbfSkip );

type TN_TaSetBlock = packed record // params for setting one block of Table Cells
  TSBFlags: TN_TaSBFlags; // settings Flags
  TSBTranspose:  byte;    // if <> 0 transpose Src Matr
  TSBReserved1:  byte;
  TSBReserved2:  byte;
  TSBSrcComp:  TN_UDCompBase; // Source Component with needed User Parameter
  TSBSrcUPName:  string;  // User Parameter Name with Source Vector or Matrix
  TSBSrcBegRow:  integer; // Beg Row Index in Source Matrix (Vector is one Column Matrix)
  TSBSrcBegCol:  integer; // Beg Column Index in Source Matrix
  TSBTaBegRow: integer; // Beg Row Index in Self (in Cells Matrix)
  TSBTaBegCol: integer; // Beg Column Index in Self
  TSBNumRows:    integer; // Number of Rows to set (<=0 means all Src Rows + TSBNumRows)
  TSBNumCols:    integer; // Number of Columns to set (<=0 means all Src Columns + TSBNumCols)
  TSBConvFmt:    string;  // Convertion Pascal Format (from Double to String)
end; // TN_TaSetBlock = packed record
type TN_PTaSetBlock = ^TN_TaSetBlock;

type TN_CTable = packed record // Table Component Individual Params
  TaFlags:      TN_TaFlags; // Table Flags
  TaDefCell:    TN_TaCell;  // default Cell Params
  TaDefPanel:   TK_RArray;  // one TN_CCPanel record or nil
  TaDefParaBox: TK_RArray;  // one TN_CParaBox record or nil
  TaCols:       TK_RArray;  // RArray of TN_TaRowColumn - Columns params
  TaRows:       TK_RArray;  // RArray of TN_TaRowColumn - Rows params
  TaCells:      TK_RArray;  // RArray of TN_TaCell (all Cells stored by rows)
  TaSetBlocks: TK_RArray;   // RArray of TN_TaSetBlock
end; // type TN_CTable = packed record
type TN_PCTable = ^TN_CTable;

type TN_RTable = packed record // TN_UDTable RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CTable:     TN_CTable;     // Component Individual Params
end; // type TN_RTable = packed record
type TN_PRTable = ^TN_RTable;

type TN_UDTable = class( TN_UDCompVis ) //***** Table_ Component
  CellVR: TN_SRTextLayout; // One Text Cell Visual Representation
  LastPixX: TN_IArray;
  LastPixY: TN_IArray;

  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRTable;
  function  PDP  (): TN_PRTable;
  function  PISP (): TN_PCTable;
  function  PIDP (): TN_PCTable;
  procedure PascalInit    (); override;
  procedure PrepMacroPointers (); override;
  procedure BeforeAction  (); override;

  procedure CalcCellSizes ( AInnerPixRect: TRect );
  procedure SetTableSize  ( AParType: TN_CompParType; ANewNX, ANewNY: integer );
  procedure IncTableSize  ( AParType: TN_CompParType; ANX, ANY: integer );
  procedure CorrectTableSize ( AParType: TN_CompParType );
  procedure SetCellsBlocks   ();
  procedure DebCellsInit     ();
end; // type TN_UDTable = class( TN_UDCompVis )


//***************************  CompsGrid Component  ********************

type TN_CGFlags = set of (
  cgfExecComps,        // Execute (Draw) Cell's Components
  cgfSetCompsPixCoords // Set Cell's Components Pix Coords
   );

type TN_CCompsGridCell = packed record // CompsGrid Cell Params
  CGCNMergedX:  integer; // Number of Merged Cells along X (0 means 1)
  CGCNMergedY:  integer; // Number of Merged Cells along Y (0 means 1)
  CGCComp: TN_UDCompVis; // Cell Component to draw
end; // type TN_CCompsGridCell = packed record
type TN_PCCompsGridCell = ^TN_CCompsGridCell;

type TN_CCompsGrid = packed record // CompsGrid Component Individual Params
  CGFlags:        TN_CGFlags; // CompsGrid Flags
  CGReserved1:          Byte; // Reserved
  CGReserved2:          Byte; // Reserved
  CGReserved3:          Byte; // Reserved
  CGRelColWidths:  TK_RArray; // Relative Grid Columns Widths (floats in any units)
  CGRelRowHeights: TK_RArray; // Relative Grid Rows Heights (floats in any units)
  CGBorderWidth:       float; // all Grid Borders Width
  CGBorderColor:     integer; // all Grid Borders Color
  CGBackColor:       integer; // all Grid Cells Background Color
  CGCells:         TK_RArray; // Cells params (RArray of TN_CCompsGridCell)
end; // type TN_CCompsGrid = packed record
type TN_PCCompsGrid = ^TN_CCompsGrid;

type TN_RCompsGrid = packed record // TN_UDCompsGrid RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CCompsGrid: TN_CCompsGrid; // Component Individual Params
end; // type TN_RCompsGrid = packed record
type TN_PRCompsGrid = ^TN_RCompsGrid;

type TN_UDCompsGrid = class( TN_UDCompVis ) // CompsGrid_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRCompsGrid;
  function  PDP  (): TN_PRCompsGrid;
  function  PISP (): TN_PCCompsGrid;
  function  PIDP (): TN_PCCompsGrid;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDCompsGrid = class( TN_UDCompVis )


//****************** Global Variables **********************
var
  N_DefC2DLHStyle: TN_C2DLHStyle = ( LHSFillColor:N_EmptyColor; LHSBorderWidth:1.0 );


//****************** Global procedures **********************

function N_CreateUDSArrow ( AObjName: string; AMinWidth, AMaxWidth,
                            AIntLeng, AExtLeng, APenWidth: float;
                            APenColor, AFillColor: integer ): TN_UDSArrow;
procedure N_InitLHStyle ( ARA: TK_RArray; BegInd, NumInds: integer );
procedure N_CreateTicsShapeCoords ( AShape: TN_ShapeCoords; AVComp: TN_UDCompVis; ATDSpace: TN_UD2DSpace );

// type TN_PCCreator is defined in N_Comp3 in implementation section
// procedure N_CrCreateLinHist_2Page( APParams: TN_PCCreator; AP1, AP2: Pointer );

//procedure N_CalclESPosPix ( ANGCont: TN_GlobCont; ANumElems, AFullPixSize: integer;
//                 APInpSPos: TN_PLHElemsSPos; var AElemsCoords: TN_IPArray );

function  N_CreateAutoAxis ( A2DSpaceComp: TN_UD2DSpace; APos: TN_RelPos ): TN_UDAutoAxis; overload
function  N_CreateAutoAxis (): TN_UDAutoAxis; overload

procedure N_PrepareConvCoefs ( ACoordsType: TN_CPCoordsType; ABasePixRect: TRect;
                               AU2PCoefs4: TN_AffCoefs4;
                               out AToPixCoefs4, AFromPixCoefs4: TN_AffCoefs4 );

implementation
uses Math, SysUtils,
     K_CLib0, K_UDConst,
     N_Lib0, N_ClassRef, N_Rast1Fr, N_Comp1, N_ME1,
     N_Comp3, Types; // N_CMMain5F,


//********** TN_UDPolyline class methods  **************

//**************************************************** TN_UDPolyline.Create ***
//
constructor TN_UDPolyline.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDPolylineCI;
  ImgInd := 106;
end; // end_of constructor TN_UDPolyline.Create

//*************************************************** TN_UDPolyline.Destroy ***
//
destructor TN_UDPolyline.Destroy;
begin
  UDPShapeCoords.Free();
  inherited Destroy;
end; // end_of destructor TN_UDPolyline.Destroy

//******************************************************* TN_UDPolyline.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDPolyline.PSP(): TN_PRPolyline;
begin
  Result := TN_PRPolyline(R.P());
end; // end_of function TN_UDPolyline.PSP

//******************************************************* TN_UDPolyline.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDPolyline.PDP(): TN_PRPolyline;
begin
  if DynPar <> nil then Result := TN_PRPolyline(DynPar.P())
                   else Result := TN_PRPolyline(R.P());
end; // end_of function TN_UDPolyline.PDP

//****************************************************** TN_UDPolyline.PISP ***
// return typed pointer to Individual Static Polyline Params
//
function TN_UDPolyline.PISP(): TN_PCPolyline;
begin
  Result := @(TN_PRPolyline(R.P())^.CPolyline);
end; // function TN_UDPolyline.PISP

//****************************************************** TN_UDPolyline.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic Polyline Params
// otherwise return typed pointer to Individual Static Polyline Params
//
function TN_UDPolyline.PIDP(): TN_PCPolyline;
begin
  if DynPar <> nil then
    Result := @(TN_PRPolyline(DynPar.P())^.CPolyline)
  else
    Result := @(TN_PRPolyline(R.P())^.CPolyline);
end; // function TN_UDPolyline.PIDP

//************************************************ TN_UDPolyline.PascalInit ***
// Init self
//
procedure TN_UDPolyline.PascalInit();
begin
  Inherited;
end; // procedure TN_UDPolyline.PascalInit

//********************************************** TN_UDPolyline.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDPolyline.BeforeAction();
var
  NumPoints: integer;
  ToBufPixCoefs4: TN_AffCoefs4;
  PRCompD: TN_PRPolyline;
begin
  PRCompD := PDP();
  with PRCompD^, PRCompD^.CPolyline do
  begin
    NumPoints := CPCoords.ALength();
    N_i := Length( UDPBufPixCoords );
    SetLength( UDPBufPixCoords, NumPoints );
    if NumPoints = 0 then Exit; // nothing to do

    //***** Calc ToBufPixCoefs4 and UDPFromBufPixCoefs4
    N_PrepareConvCoefs( CPCoordsType, CompIntPixRect, CompU2P,
                                      ToBufPixCoefs4, UDPFromBufPixCoefs4 );
    //***** Calc UDPBufPixCoords
    N_AffConv4F2FPoints( PFPoint(CPCoords.P()), @UDPBufPixCoords[0],
                                                 NumPoints, ToBufPixCoefs4 );

    //***** Create UDPShapeCoords and Draw

    if UDPShapeCoords = nil then
      UDPShapeCoords := TN_ShapeCoords.Create( 1 )
    else
      UDPShapeCoords.Clear();

    UDPShapeCoords.AddPixPolyLine( PFPoint(@UDPBufPixCoords[0]), NumPoints );
    NGCont.DrawShape( UDPShapeCoords, CPolylineAttr, N_ZFPoint );
  end; // PRCompD^, PRCompD^.CPolyline do
end; // end_of procedure TN_UDPolyline.BeforeAction


//********** TN_UDArc class methods  **************

//********************************************************* TN_UDArc.Create ***
//
constructor TN_UDArc.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDArcCI;
  ImgInd := 107;
  UDAShapeCoords := TN_ShapeCoords.Create();
  SetLength( UDABufPixCoords, 5 );
end; // end_of constructor TN_UDArc.Create

//******************************************************** TN_UDArc.Destroy ***
//
destructor TN_UDArc.Destroy;
begin
  UDAShapeCoords.Free();
  UDABufPixCoords := nil;
  inherited Destroy;
end; // end_of destructor TN_UDArc.Destroy

//************************************************************ TN_UDArc.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDArc.PSP(): TN_PRArc;
begin
  Result := TN_PRArc(R.P());
end; // end_of function TN_UDArc.PSP

//************************************************************ TN_UDArc.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDArc.PDP(): TN_PRArc;
begin
  if DynPar <> nil then Result := TN_PRArc(DynPar.P())
                   else Result := TN_PRArc(R.P());
end; // end_of function TN_UDArc.PDP

//*********************************************************** TN_UDArc.PISP ***
// return typed pointer to Individual Static Arc Params
//
function TN_UDArc.PISP(): TN_PCArc;
begin
  Result := @(TN_PRArc(R.P())^.CArc);
end; // function TN_UDArc.PISP

//*********************************************************** TN_UDArc.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic Arc Params
// otherwise return typed pointer to Individual Static Arc Params
//
function TN_UDArc.PIDP(): TN_PCArc;
begin
  if DynPar <> nil then
    Result := @(TN_PRArc(DynPar.P())^.CArc)
  else
    Result := @(TN_PRArc(R.P())^.CArc);
end; // function TN_UDArc.PIDP

//***************************************************** TN_UDArc.PascalInit ***
// Init self
//
procedure TN_UDArc.PascalInit();
begin
  Inherited;
end; // procedure TN_UDArc.PascalInit

//*************************************************** TN_UDArc.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDArc.BeforeAction();
var
  ToBufPixCoefs4: TN_AffCoefs4;
  ArcCoords: Array [0..4] of TFPoint;
  PRCompD: TN_PRArc;
begin
  PRCompD := PDP();
  with PRCompD^, PRCompD^.CArc do
  begin
    ArcCoords[0] := CArcEnvRect.TopLeft;
    ArcCoords[1] := CArcEnvRect.BottomRight;
    ArcCoords[2] := FPoint( N_RectCenter( CArcEnvRect ) );
    ArcCoords[3] := N_FloatEllipsePoint( CArcEnvRect, CArcBegAngle );
    ArcCoords[4] := N_FloatEllipsePoint( CArcEnvRect, CArcEndAngle );

    if CArcEnvRect.Left = CArcEnvRect.Right then Exit; // nothing to do

    //***** Calc ToBufPixCoefs4 and UDAFromBufPixCoefs4
    N_PrepareConvCoefs( CArcCoordsType, CompIntPixRect, CompU2P,
                                        ToBufPixCoefs4, UDAFromBufPixCoefs4 );
    //***** Calc UDABufPixCoords
    N_AffConv4F2FPoints( @ArcCoords[0], @UDABufPixCoords[0], 5, ToBufPixCoefs4 );

    //***** Create UDAShapeCoords and Draw
    UDAShapeCoords.Clear();
    if CArcEndAngle < CArcBegAngle then CArcEndAngle := CArcEndAngle + 360;
    UDAShapeCoords.AddEllipseFragm( PFRect(@UDABufPixCoords[0])^, CArcBorderType,
                                    CArcBegAngle, CArcEndAngle-CArcBegAngle );

    NGCont.DrawShape( UDAShapeCoords, CArcAttr, N_ZFPoint );
  end; // PRCompD^, PRCompD^.CArc do
end; // end_of procedure TN_UDArc.BeforeAction


//********** TN_UDSArrow class methods  **************

//****************************************************** TN_UDSArrow.Create ***
//
constructor TN_UDSArrow.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDSArrowCI;
  ImgInd := 52;
end; // end_of constructor TN_UDSArrow.Create

//***************************************************** TN_UDSArrow.Destroy ***
//
destructor TN_UDSArrow.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDSArrow.Destroy

//********************************************************* TN_UDSArrow.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDSArrow.PSP(): TN_PRSArrow;
begin
  Result := TN_PRSArrow(R.P());
end; // end_of function TN_UDSArrow.PSP

//********************************************************* TN_UDSArrow.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDSArrow.PDP(): TN_PRSArrow;
begin
  if DynPar <> nil then Result := TN_PRSArrow(DynPar.P())
                   else Result := TN_PRSArrow(R.P());
end; // end_of function TN_UDSArrow.PDP

//******************************************************** TN_UDSArrow.PISP ***
// return typed pointer to Individual Static SArrow Params
//
function TN_UDSArrow.PISP(): TN_PCSArrow;
begin
  Result := @(TN_PRSArrow(R.P())^.CSArrow);
end; // function TN_UDSArrow.PISP

//******************************************************** TN_UDSArrow.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic SArrow Params
// otherwise return typed pointer to Individual Static SArrow Params
//
function TN_UDSArrow.PIDP(): TN_PCSArrow;
begin
  if DynPar <> nil then
    Result := @(TN_PRSArrow(DynPar.P())^.CSArrow)
  else
    Result := @(TN_PRSArrow(R.P())^.CSArrow);
end; // function TN_UDSArrow.PIDP

//************************************************** TN_UDSArrow.PascalInit ***
// Init self
//
procedure TN_UDSArrow.PascalInit();
var
  PRCompS: TN_PRSArrow;
begin
  Inherited;
  PRCompS := PSP();
  with PRCompS^, PRCompS^.CSArrow do
  begin
    SAWidths  := FPoint( 1, 4 );
    SALengths := FPoint( 8, 8 );

    SAAttribs := K_RCreateByTypeName( 'TN_ContAttr', 1 );
    with TN_PContAttr(SAAttribs.P())^ do
    begin
      CAPenWidth   := 0;
      CABrushColor := 0;
    end; // with TN_PContAttr(SAAttribs.P())^ do

  end;
end; // procedure TN_UDSArrow.PascalInit

//************************************************ TN_UDSArrow.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDSArrow.BeforeAction();
var
  PRCompD: TN_PRSArrow;
  P1, P2, PCenter, PBeg: TPoint;
begin
  PRCompD := PDP();

  with PRCompD^, PRCompD^.CSArrow do
  begin
    // calc P1,P2 - beg end end SArrow points

    if safUseBegPoint in SAFlags then // use given BegPoint and SADirection
    begin
      PBeg := NGCont.ConvMSToPix( SABegPoint );
      PBeg.X := PBeg.X + CompIntPixRect.Left;
      PBeg.Y := PBeg.Y + CompIntPixRect.Top;

      case SADirection of
        sadTop: begin
          P1.X := PBeg.X;
          P1.Y := CompIntPixRect.Bottom;
          P2.X := PBeg.X;
          P2.Y := CompIntPixRect.Top;
        end;

        sadTopRight: begin
          P1.X := CompIntPixRect.Left;
          P1.Y := CompIntPixRect.Bottom;
          P2.X := CompIntPixRect.Right;
          P2.Y := CompIntPixRect.Top;
        end;

        sadRight: begin
          P1.X := CompIntPixRect.Left;
          P1.Y := PBeg.Y;
          P2.X := CompIntPixRect.Right;
          P2.Y := PBeg.Y;
        end;

        sadBotRight: begin
          P1.X := CompIntPixRect.Left;
          P1.Y := CompIntPixRect.Top;
          P2.X := CompIntPixRect.Right;
          P2.Y := CompIntPixRect.Bottom;
        end;

        sadBottom: begin
          P1.X := PBeg.X;
          P1.Y := CompIntPixRect.Top;
          P2.X := PBeg.X;
          P2.Y := CompIntPixRect.Bottom;
        end;

        sadBotLeft: begin
          P1.X := CompIntPixRect.Right;
          P1.Y := CompIntPixRect.Top;
          P2.X := CompIntPixRect.Left;
          P2.Y := CompIntPixRect.Bottom;
        end;

        sadLeft: begin
          P1.X := CompIntPixRect.Right;
          P1.Y := PBeg.Y;
          P2.X := CompIntPixRect.Left;
          P2.Y := PBeg.Y;
        end;

        sadTopLeft: begin
          P1.X := CompIntPixRect.Right;
          P1.Y := CompIntPixRect.Bottom;
          P2.X := CompIntPixRect.Left;
          P2.Y := CompIntPixRect.Top;
        end;
      end; // case SADirection of
    end else if safUseBothPoints in SAFlags then // use given BegPoint and EndPoint
    begin
      P1 := NGCont.ConvMSToPix( SABegPoint );
      P1 := NGCont.ConvMSToPix( SAEndPoint );
    end else // use CompIntPixRect and SADirection
    begin
      PCenter := N_RectCenter( CompIntPixRect );

      case SADirection of
        sadTop: begin
          P1.X := PCenter.X;
          P1.Y := CompIntPixRect.Bottom;
          P2.X := PCenter.X;
          P2.Y := CompIntPixRect.Top;
        end;

        sadTopRight: begin
          P1.X := CompIntPixRect.Left;
          P1.Y := CompIntPixRect.Bottom;
          P2.X := CompIntPixRect.Right;
          P2.Y := CompIntPixRect.Top;
        end;

        sadRight: begin
          P1.X := CompIntPixRect.Left;
          P1.Y := PCenter.Y;
          P2.X := CompIntPixRect.Right;
          P2.Y := PCenter.Y;
        end;

        sadBotRight: begin
          P1.X := CompIntPixRect.Left;
          P1.Y := CompIntPixRect.Top;
          P2.X := CompIntPixRect.Right;
          P2.Y := CompIntPixRect.Bottom;
        end;

        sadBottom: begin
          P1.X := PCenter.X;
          P1.Y := CompIntPixRect.Top;
          P2.X := PCenter.X;
          P2.Y := CompIntPixRect.Bottom;
        end;

        sadBotLeft: begin
          P1.X := CompIntPixRect.Right;
          P1.Y := CompIntPixRect.Top;
          P2.X := CompIntPixRect.Left;
          P2.Y := CompIntPixRect.Bottom;
        end;

        sadLeft: begin
          P1.X := CompIntPixRect.Right;
          P1.Y := PCenter.Y;
          P2.X := CompIntPixRect.Left;
          P2.Y := PCenter.Y;
        end;

        sadTopLeft: begin
          P1.X := CompIntPixRect.Right;
          P1.Y := CompIntPixRect.Bottom;
          P2.X := CompIntPixRect.Left;
          P2.Y := CompIntPixRect.Top;
        end;
      end; // case SADirection of
    end; // else - use CompIntPixRect and SADirection

    SARect := FRect( P1, P2 );
    NGCont.DrawStraightArrow( @CSArrow );
  end; // PRCompD^, PRCompD^.CSArrow do

end; // end_of procedure TN_UDSArrow.BeforeAction


//********** TN_UD2DSpace class methods  **************

//***************************************************** TN_UD2DSpace.Create ***
//
constructor TN_UD2DSpace.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UD2DSpaceCI;
  ImgInd := 55;
end; // end_of constructor TN_UD2DSpace.Create

//**************************************************** TN_UD2DSpace.Destroy ***
//
destructor TN_UD2DSpace.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UD2DSpace.Destroy

//******************************************************** TN_UD2DSpace.PSP ***
// Return typed pointer to all Static Params
//
function TN_UD2DSpace.PSP(): TN_PR2DSpace;
begin
  Result := TN_PR2DSpace(R.P());
end; // end_of function TN_UD2DSpace.PSP

//******************************************************** TN_UD2DSpace.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UD2DSpace.PDP(): TN_PR2DSpace;
begin
  if DynPar <> nil then Result := TN_PR2DSpace(DynPar.P())
                   else Result := TN_PR2DSpace(R.P());
end; // end_of function TN_UD2DSpace.PDP

//******************************************************* TN_UD2DSpace.PISP ***
// return typed pointer to Individual Static 2DSpace Params
//
function TN_UD2DSpace.PISP(): TN_PC2DSpace;
begin
  Result := @(TN_PR2DSpace(R.P())^.C2DSpace);
end; // function TN_UD2DSpace.PISP

//******************************************************* TN_UD2DSpace.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic 2DSpace Params
// otherwise return typed pointer to Individual Static 2DSpace Params
//
function TN_UD2DSpace.PIDP(): TN_PC2DSpace;
begin
  if DynPar <> nil then
    Result := @(TN_PR2DSpace(DynPar.P())^.C2DSpace)
  else
    Result := @(TN_PR2DSpace(R.P())^.C2DSpace);
end; // function TN_UD2DSpace.PIDP

//************************************************* TN_UD2DSpace.PascalInit ***
// Init self
//
procedure TN_UD2DSpace.PascalInit();
var
  PRCompS: TN_PR2DSpace;
begin
  Inherited;
  PRCompS := PSP();
  with PRCompS^, PRCompS^.C2DSpace, PCCD()^ do
  begin
    TDSArgAxisPos    := tdsHorizontal;
    TDSArgDirection  := tdsIncreasing;
    TDSFuncDirection := tdsIncreasing;
    TDSArgMin  := 0;
    TDSArgMax  := 100;
    TDSFuncMin := 0;
    TDSFuncMax := 100;
//    CompUCoords  := FRect( TDSArgMin, TDSFuncMin, TDSArgMax, TDSFuncMax );
    UCoordsType := cutGiven;
  end;
end; // procedure TN_UD2DSpace.PascalInit

//****************************************** TN_UD2DSpace.InitRunTimeFields ***
// Initialie Self
//
procedure TN_UD2DSpace.InitRunTimeFields( AInitFlags: TN_CompInitFlags );
begin
  AF2U6.CXX := N_NotADouble;
  AF2P6.CXX := N_NotADouble; // not really needed
end; // end_of procedure TN_UD2DSpace.InitRunTimeFields

//*********************************************** TN_UD2DSpace.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UD2DSpace.BeforeAction();
begin

end; // end_of procedure TN_UD2DSpace.BeforeAction

//************************************************* TN_UD2DSpace.CalcCoefs6 ***
// Calc coefs for AF -> User and AF -> Pixel coords convertions
// (Self.AF2U6, Self.AF2P6) if needed
//
procedure TN_UD2DSpace.CalcCoefs6( AAlways: boolean );
var
  UCoords, ArgFunc, PixCoords: TN_3DPReper;
begin
  if not (crtfRootComp in CRTFlags) and // Component was already executed
     (not AAlways) and (AF2U6.CXX <> N_NotADouble) then Exit; // already OK

//*******  1,2,3 points are: TopLeft, TopRight, BottomLeft

  with PIDP()^, PCCD()^ do
  begin
    if TDSArgAxisPos = tdsVertical then //***** Argument Axis is Vertical (Pixel Y-Axis from Top to Bottom)
    begin

      if TDSArgDirection = tdsDecreasing then // Argument Decrease along Y-Axis
      begin                                   // (from Bottom to Top)
        ArgFunc.P1.X := TDSArgMax;
        ArgFunc.P2.X := TDSArgMax;
        ArgFunc.P3.X := TDSArgMin;
      end else //************************** Argument Increase along Y-Axis
      begin                              // (from Top to Bottom)
        ArgFunc.P1.X := TDSArgMin;
        ArgFunc.P2.X := TDSArgMin;
        ArgFunc.P3.X := TDSArgMax;
      end;

      if TDSFuncDirection = tdsIncreasing then // Function Increase along X-Axis
      begin                                    // (from Left to Right)
        ArgFunc.P1.Y := TDSFuncMin;
        ArgFunc.P2.Y := TDSFuncMax;
        ArgFunc.P3.Y := TDSFuncMin;
      end else //************************** Function Decrease along X-Axis
      begin                              // (from Right to Left)
        ArgFunc.P1.Y := TDSFuncMax;
        ArgFunc.P2.Y := TDSFuncMin;
        ArgFunc.P3.Y := TDSFuncMax;
      end;

    end else //****************************** Argument Axis is Horizontal (X-Axis)
    begin

      if TDSArgDirection = tdsDecreasing then // Argument Decrease along X-Axis
      begin                                   // (from Right to Left)
        ArgFunc.P1.X := TDSArgMax;
        ArgFunc.P2.X := TDSArgMin;
        ArgFunc.P3.X := TDSArgMax;
      end else //************************** Argument Increase along X-Axis
      begin                              // (from Left to Right)
        ArgFunc.P1.X := TDSArgMin;
        ArgFunc.P2.X := TDSArgMax;
        ArgFunc.P3.X := TDSArgMin;
      end;

      if TDSFuncDirection = tdsIncreasing then // Function Increase along Pixel Y-Axis (not usual in math!)
      begin                                    // (from Top to Bottom)
        ArgFunc.P1.Y := TDSFuncMin;
        ArgFunc.P2.Y := TDSFuncMin;
        ArgFunc.P3.Y := TDSFuncMax;
      end else //************************** Function Decrease along Pixel Y-Axis
      begin                             // (from Bottom to Top)
        ArgFunc.P1.Y := TDSFuncMax;
        ArgFunc.P2.Y := TDSFuncMax;
        ArgFunc.P3.Y := TDSFuncMin;
      end;
    end; // if TDSArgAxisPos = tdsVertical then ... else ...

//*******  1,2,3 points are: TopLeft, TopRight, BottomLeft
{
    UCoords.X1 := CompIntUserRect.Left;
    UCoords.Y1 := CompIntUserRect.Top;
    UCoords.X2 := CompIntUserRect.Right;
    UCoords.Y2 := CompIntUserRect.Top;
    UCoords.X3 := CompIntUserRect.Left;
    UCoords.Y3 := CompIntUserRect.Bottom;
}
    UCoords := D3PReper( CompIntUserRect );
    AF2U6 := N_CalcAffCoefs6( ArgFunc, UCoords ); // coefs for ArgFunc -> User
{
    PixCoords.X1 := CompIntPixRect.Left;
    PixCoords.Y1 := CompIntPixRect.Top;
    PixCoords.X2 := CompIntPixRect.Right;
    PixCoords.Y2 := CompIntPixRect.Top;
    PixCoords.X3 := CompIntPixRect.Left;
    PixCoords.Y3 := CompIntPixRect.Bottom;
}
    PixCoords := D3PReper( CompIntPixRect );
    AF2P6 := N_CalcAffCoefs6( ArgFunc, PixCoords ); // coefs for ArgFunc -> Pixel

  end; // with PISP()^, PCCD()^ do
end; // procedure TN_UD2DSpace.CalcCoefs6

//*********************************************** TN_UD2DSpace.CalcAxisInfo ***
// Calculate Info about given AAxisComp:
// calculate AxisIsVertical, AxisIsArgument and AxisIsLess Self fields
//
procedure TN_UD2DSpace.CalcAxisInfo( AAxisComp: TN_UDCompVis );
var
  dx, dy: integer;
  SelfCenter, AxisCenter: TPoint;
begin
  AxisCenter := N_RectCenter( AAxisComp.CompIntPixRect );
  SelfCenter := N_RectCenter( Self.CompIntPixRect );

  with PIDP()^ do
  begin
    dx := AxisCenter.X - SelfCenter.X;
    dy := AxisCenter.Y - SelfCenter.Y;

    if abs( dx ) > abs( dy ) then // Axis is Vertical
    begin
      AxisIsVertical := True;
      AxisIsArgument := not (TDSArgAxisPos = tdsHorizontal);
      AxisIsLess := ( dx < 0 );
    end else // abs( dx ) <= abs( dy ) - Axis is Horizontal
    begin
      AxisIsVertical := False;
      AxisIsArgument := (TDSArgAxisPos = tdsHorizontal);
      AxisIsLess := ( dy < 0 );
    end;
  end; // with PIDP()^ do

end; // procedure TN_UD2DSpace.CalcAxisInfo

//*********************************************** TN_UD2DSpace.CalcAxisStep ***
// Using given APMinStep Calculate "nice" (properly rounded) AResStep, AResBase
//
// AResStep = AResStepVal*10**AResStepExp, AResStepVal=1, 2 or 5,
// AResStep >= given AMinStepPix,
// at least two Ticks would be in (AFMin, AFMax) range,
// AResStep and AResBase are in proper (Argument or Function) units
//
// AxisIsVertical and  AxisIsArgument should be already OK
//
procedure TN_UD2DSpace.CalcAxisStep( AAFlags: TN_AutoAxisFlags; APMinStep: TN_PMScalSize;
                                     out AResStep, AResBase: double;
                                     out AResStepVal, AResStepExp: integer );
var
  PixStep: integer;
  AFMin, AFMax, AFSrcStep, AFSSLog, DblResStepVal: double;

  procedure CalcNextSmallerStep();
  begin
  end;

begin
//      AxisIsVertical := True;
//      AxisIsArgument := not (TDSArgAxisPos = tdsHorizontal);
//      AxisIsLess := ( dx < 0 );

  with PIDP()^ do
  begin

  with APMinStep^ do
    PixStep := NGCont.ConvMSToPix( MSSValue, MSUnit );

  if AxisIsArgument then // Axis Is Argument
  begin
    AFMin := TDSArgMin;
    AFMax := TDSArgMax;
    AFSrcStep := PixStep / (AF2P6.CXX + AF2P6.CYX );

  end else // Axis Is Function
  begin
    AFMin := TDSFuncMin;
    AFMax := TDSFuncMax;
    AFSrcStep := PixStep / (AF2P6.CXY + AF2P6.CYY );

  end;

  if APMinStep^.MSUnit = msuSpecial1 then
    AFSrcStep := APMinStep^.MSSValue;

  AFSrcStep := Min( AFSrcStep, ((AFMax - AFMin) / 2.15) ); // Max possible value

  //***** Represent AFSrcStep as AResStepVal*10**AResStepExp

  AFSSLog := Log10( AFSrcStep );

  AResStepExp := Round( Floor( AFSSLog ) );
  DblResStepVal := Power( 10, AFSSLog - AResStepExp ); // in (1..10) range

  if DblResStepVal <= 1.4 then AResStepVal := 1
  else if DblResStepVal <= 2.5 then AResStepVal := 2
  else if DblResStepVal <= 7.5 then AResStepVal := 5
  else // DblResStepVal > 7.5
  begin
    AResStepVal := 1;
    Inc( AResStepExp );
  end;

  AResStep := AResStepVal * Power( 10, AResStepExp );

  if ((AFMax - AFMin) / AResStep) < 2.15 then
    CalcNextSmallerStep();

  AResStep := AResStepVal * Power( 10, AResStepExp );
  AResBase := 0;

  end; // with PIDP()^ do
end; // procedure TN_UD2DSpace.CalcAxisStep

//****************************************** TN_UD2DSpace.GetTicksMidPoints ***
// Calculate Ticks Mid Point coords in Pixel coords in AResPoints Array
// and Ticks Values in AResValues Array.
//
// Variables AxisIsVertical, AxisIsArgument and AxisIsLess should already be OK
//
procedure TN_UD2DSpace.GetTicksMidPoints( AAxisComp: TN_UDCompVis; ABase, AStep: double;
                                          APixShift: integer; var AResPoints: TN_IPArray;
                                          var AResValues: TN_DArray );
var
  i, NumTicks, FixPix: integer;
  ci1, ci2, HalfPix: double;
//  PAxisCoords: TN_PCompCoords;
begin
  CalcCoefs6();

//  PAxisCoords := AAxisComp.PCCD();

  with PIDP()^ do
  begin
    //***** Calc Pix coords along Axis (Arg or Func) (different for all points)

    if AxisIsArgument then // ABase, AStep are Argument values
    begin
      with AF2P6 do
        HalfPix := 0.5 / ( abs(CXX) + abs(CYX) ); // 1/2 Pixel in Argument units
        ci1 := Ceil(  (TDSArgMin - HalfPix - ABase) / AStep );
        ci2 := Floor( (TDSArgMax + HalfPix - ABase) / AStep );
        NumTicks := Round( ci2 - ci1 + 1);

        SetLength( AResPoints, NumTicks );
        SetLength( AResValues, NumTicks );

        for i := 0 to NumTicks-1 do // Calc Argument Pix Values for all Ticks
        begin
          AResValues[i] := ABase + (ci1 + i)*AStep;
          AResPoints[i] := IPoint(N_AffConv6D2DPoint( AResValues[i], 0, AF2P6 ));
        end;
    end else // ABase, AStep are Function values
    begin
      with AF2P6 do
        HalfPix := 0.5 / ( abs(CXY) + abs(CYY) ); // 1/2 Pixel in Function units
        ci1 := Ceil(  (TDSFuncMin - HalfPix - ABase) / AStep );
        ci2 := Floor( (TDSFuncMax + HalfPix - ABase) / AStep );
        NumTicks := Round( ci2 - ci1 + 1);

        SetLength( AResPoints, NumTicks );
        SetLength( AResValues, NumTicks );

        for i := 0 to NumTicks-1 do // Calc Function Pix Values for all Ticks
        begin
          AResValues[i] := ABase + (ci1 + i)*AStep;
          AResPoints[i] := IPoint(N_AffConv6D2DPoint( 0, AResValues[i], AF2P6 ));
        end;
    end;

    //***** Calc Axis itself Pix coord and set it to all AResPoints (same for all points)

    if AxisIsVertical then // Axis is Vertical, calc it's X coord
    begin
      if AxisIsLess then FixPix := CompIntPixRect.Left  - APixShift
                    else FixPix := CompIntPixRect.Right + APixShift;

      for i := 0 to NumTicks-1 do // Set X Pix coord for all Ticks
        AResPoints[i].X := FixPix;
    end else // Axis is Horizontal, calc it's Y coord
    begin
      if AxisIsLess then FixPix := CompIntPixRect.Top    - APixShift
                    else FixPix := CompIntPixRect.Bottom + APixShift;

      for i := 0 to NumTicks-1 do // Set Y Pix coord for all Ticks
        AResPoints[i].Y := FixPix;
    end;

  end; // with PIDP()^ do

end; // end_of procedure TN_UD2DSpace.GetTicksMidPoints


//********** TN_UDAxisTics class methods  **************

//**************************************************** TN_UDAxisTics.Create ***
//
constructor TN_UDAxisTics.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDAxisTicsCI;
  ImgInd := 53;
end; // end_of constructor TN_UDAxisTics.Create

//*************************************************** TN_UDAxisTics.Destroy ***
//
destructor TN_UDAxisTics.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDAxisTics.Destroy

//******************************************************* TN_UDAxisTics.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDAxisTics.PSP(): TN_PRAxisTics;
begin
  Result := TN_PRAxisTics(R.P());
end; // end_of function TN_UDAxisTics.PSP

//******************************************************* TN_UDAxisTics.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDAxisTics.PDP(): TN_PRAxisTics;
begin
  if DynPar <> nil then Result := TN_PRAxisTics(DynPar.P())
                   else Result := TN_PRAxisTics(R.P());
end; // end_of function TN_UDAxisTics.PDP

//****************************************************** TN_UDAxisTics.PISP ***
// return typed pointer to Individual Static AxisTics Params
//
function TN_UDAxisTics.PISP(): TN_PCAxisTics;
begin
  Result := @(TN_PRAxisTics(R.P())^.CAxisTics);
end; // function TN_UDAxisTics.PISP

//****************************************************** TN_UDAxisTics.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic AxisTics Params
// otherwise return typed pointer to Individual Static AxisTics Params
//
function TN_UDAxisTics.PIDP(): TN_PCAxisTics;
begin
  if DynPar <> nil then
    Result := @(TN_PRAxisTics(DynPar.P())^.CAxisTics)
  else
    Result := @(TN_PRAxisTics(R.P())^.CAxisTics);
end; // function TN_UDAxisTics.PIDP

//************************************************ TN_UDAxisTics.PascalInit ***
// Init self
//
procedure TN_UDAxisTics.PascalInit();
var
  PRCompS: TN_PRAxisTics;
begin
  Inherited;
  PRCompS := PSP();
  with PRCompS^, PRCompS^.CPanel, PRCompS^.CAxisTics do
  begin
    ATBaseZ := 0;
    ATStepZ := 1;
  end;
end; // procedure TN_UDAxisTics.PascalInit

//********************************************** TN_UDAxisTics.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDAxisTics.BeforeAction();
var
  i, i1, i2, NumTics: integer;
  VertLines: boolean;
  CurTicValue, ValueStepSign: double;
  TDSpace: TN_UD2DSpace;
  BasePix, StepPix: TDPoint;
  P1, P2: TPoint;
  TicsAttr: TK_RArray;
  ShapeCoords: TN_ShapeCoords;
begin
  N_s := ObjName; // debug
  with PIDP()^ do
  begin

  if ATStepZ < 0 then Exit; // "skip any drawing" flag

  if AT2DSpace is TN_UD2DSpace then
    TDSpace := TN_UD2DSpace(AT2DSpace)
  else
  begin
    if Integer(ATTicValues) <> 1 then // to Show warning only once
      N_WarnByMessage( 'Bad AT2DSpace!' );
    Integer(ATTicValues) := 1; // set "do not Show warning" flag
    Exit;
  end;

  with PCCD()^, TDSpace.PIDP()^, NGCont.DstOCanv do
  begin
    TicsAttr := ATAttribs;
    if TicsAttr = nil then TicsAttr := N_DefStrokeContAttr; // default Attribs

//  if N_s = 'FuncTicsGrid' then // debug
//    N_i := 1;

  with TDSpace do
  begin
    CalcCoefs6();

    BasePix := N_AffConv6D2DScalar( ATBaseZ, AF2P6 );
    StepPix := N_AffConv6D2DScalar( ATBaseZ + ATStepZ, AF2P6 );

    StepPix.X := Abs( StepPix.X - BasePix.X );
    StepPix.Y := Abs( StepPix.Y - BasePix.Y );
  end; // with TDSpace do

  VertLines := ( (ATType = tdsArgument) and (TDSArgAxisPos = tdsHorizontal) ) or
               ( (ATType = tdsFunction) and (TDSArgAxisPos = tdsVertical) );

  if ATType = tdsArgument then
  begin
    if TDSArgDirection = tdsIncreasing then ValueStepSign := 1.0
                                       else ValueStepSign := -1.0
  end else
  begin
    if TDSFuncDirection = tdsIncreasing then ValueStepSign := 1.0
                                        else ValueStepSign := -1.0
  end;

  ShapeCoords := TN_ShapeCoords.Create();

  if VertLines then // Axis is Horizontal, Tic Lines are Vertical
  begin
    if ATBaseZs <> nil then // Array of individual Tic Coords is given
    begin
      i1 := 0;
      i2 := ATBaseZs.ALength()-1;
    end else if StepPix.X = 0 then // force single Tic
    begin
      i1 := 0;
      i2 := 0;
    end else // StepPix.X > 0, several Tics with given Step
    begin
      i1 := Round( (CompIntPixRect.Left  - BasePix.X)/StepPix.X + 0.5 );
      i2 := Round( (CompIntPixRect.Right - BasePix.X)/StepPix.X - 0.5 );
    end;

    NumTics := i2 - i1 + 1;
    SetLength( ATTicValues, NumTics );
    SetLength( ATTicPixRects, NumTics );

    P1.Y := CompIntPixRect.Top;
    P2.Y := CompIntPixRect.Bottom;

    for i := i1 to i2 do // along all vertical Tics
    begin
      if ATBaseZs <> nil then // Array of individual Tic Coords is given
      begin
        CurTicValue := PDouble(ATBaseZs.P(i))^;
        ATTicValues[i-i1] := CurTicValue; // Tic Value for TextMarks Comp
        BasePix := N_AffConv6D2DScalar( CurTicValue, TDSpace.AF2P6 );
        P1.X := Round(BasePix.X);
        P2.X := P1.X;
      end else // several Tics with given Step
      begin
        ATTicValues[i-i1] := ATBaseZ + i*ValueStepSign*ATStepZ; // Tic Value for TextMarks Comp
        P1.X := Round( BasePix.X + i*StepPix.X );
        P2.X := P1.X;
      end;

      ShapeCoords.AddSeparateSegm( P1, P2 );

      ATTicPixRects[i-i1] := FRect( P1, P2 ); // Tic Rect for TextMarks Comp
    end;
  end else //********* Axis is Vertical, Tic Lines are Horizontal
  begin
    if ATBaseZs <> nil then // Array of individual Tic Coords is given
    begin
      i1 := 0;
      i2 := ATBaseZs.ALength()-1;
    end else if StepPix.Y = 0 then // force single Tic
    begin
      i1 := 0;
      i2 := 0;
    end else // StepPix.Y > 0, several Tics with given Step
    begin
      i1 := Round( (CompIntPixRect.Top    - BasePix.Y)/StepPix.Y + 0.5 );
      i2 := Round( (CompIntPixRect.Bottom - BasePix.Y)/StepPix.Y - 0.5 );
    end;

    NumTics := i2 - i1 + 1;
    SetLength( ATTicValues, NumTics );
    SetLength( ATTicPixRects, NumTics );

    P1.X := CompIntPixRect.Left;
    P2.X := CompIntPixRect.Right;

    for i := i1 to i2 do // along all horizontal Tics
    begin
      if ATBaseZs <> nil then // Array of individual Tic Coords is given
      begin
        CurTicValue := PDouble(ATBaseZs.P(i))^;
        ATTicValues[i-i1] := CurTicValue; // Tic Value for TextMarks Comp
        BasePix := N_AffConv6D2DScalar( CurTicValue, TDSpace.AF2P6 );
        P1.Y := Round(BasePix.Y);
        P2.Y := P1.Y;
      end else // several Tics with given Step
      begin
        P1.Y := Round( BasePix.Y + i*StepPix.Y );
        P2.Y := P1.Y;
        ATTicValues[i-i1] := ATBaseZ + i*ValueStepSign*ATStepZ; // Tics Values for TextMarks Comp
      end;

      ShapeCoords.AddSeparateSegm( P1, P2 );

      ATTicPixRects[i-i1] := FRect( P1, P2 ); // Tic Rect for TextMarks Comp
    end;
  end; // if VertLines then ... else ...

  NGCont.DrawShape( ShapeCoords, TicsAttr, N_ZFPoint );
  ShapeCoords.Free;

  end; // PCCD()^, TDSpace.PIDP()^, NGCont.DstOCanv do
  end; // with PIDP()^ do
end; // end_of procedure TN_UDAxisTics.BeforeAction


//********** TN_UDTextMarks class methods  **************

//*************************************************** TN_UDTextMarks.Create ***
//
constructor TN_UDTextMarks.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDTextMarksCI;
  ImgInd := 54;
end; // end_of constructor TN_UDTextMarks.Create

//************************************************** TN_UDTextMarks.Destroy ***
//
destructor TN_UDTextMarks.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDTextMarks.Destroy

//****************************************************** TN_UDTextMarks.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDTextMarks.PSP(): TN_PRTextMarks;
begin
  Result := TN_PRTextMarks(R.P());
end; // end_of function TN_UDTextMarks.PSP

//****************************************************** TN_UDTextMarks.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDTextMarks.PDP(): TN_PRTextMarks;
begin
  if DynPar <> nil then Result := TN_PRTextMarks(DynPar.P())
                   else Result := TN_PRTextMarks(R.P());
end; // end_of function TN_UDTextMarks.PDP

//***************************************************** TN_UDTextMarks.PISP ***
// return typed pointer to Individual Static TextMarks Params
//
function TN_UDTextMarks.PISP(): TN_PCTextMarks;
begin
  Result := @(TN_PRTextMarks(R.P())^.CTextMarks);
end; // function TN_UDTextMarks.PISP

//***************************************************** TN_UDTextMarks.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic TextMarks Params
// otherwise return typed pointer to Individual Static TextMarks Params
//
function TN_UDTextMarks.PIDP(): TN_PCTextMarks;
begin
  if DynPar <> nil then
    Result := @(TN_PRTextMarks(DynPar.P())^.CTextMarks)
  else
    Result := @(TN_PRTextMarks(R.P())^.CTextMarks);
end; // function TN_UDTextMarks.PIDP

//*********************************************** TN_UDTextMarks.PascalInit ***
// Init self
//
procedure TN_UDTextMarks.PascalInit();
var
  PRCompS: TN_PRTextMarks;
begin
  Inherited;
  PRCompS := PSP();

  with PRCompS^.CTextMarks, PRCompS^.CTextMarks.TMMainStyle do
  begin
    TMSValsFmt := '%f';
    TMSStrPos.SPPHotPoint := FPoint( 50, 50 );
    TMSBPPos := FPoint( 50, 50 );
  end;
end; // procedure TN_UDTextMarks.PascalInit

//********************************************* TN_UDTextMarks.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDTextMarks.BeforeAction();
var
  i, NumStrings, StringInd, NumVals, NumMarks, MarkStyleInd: integer;
  LHNX, LHNY, LHNumGroups, LHNumElems, NStyleInd, NStyleIndsInd: integer;
  MaxPixWidth: integer;
  Size, Coef: double;
  PFirstString, PCurString: PString;
  DefStr, TmpStr, DefFmt, CurFmt, CurString, DrawStr: string;
  CommonFont: TObject;
  OwnBPPixCoords: TN_FPArray;
  TmpUniformCoords: TN_IPArray;
  CurBasePoint, ShiftFPix: TFPoint;
  StrPixRect, CurFRect: TFRect;
  PBCRects, PCurFRect: PFRect;
  PBCPoints, PCurFPoint: PFPoint;
  LinHist: TN_UD2DLinHist;
  PieChart: TN_UDPieChart;
  AxisTics: TN_UDAxisTics;
  TextMarks: TN_UDTextMarks;
  PVals, PCurVal: PDouble;
  PCurStyle: TN_PTMStyle;
  PCurNStyle: TN_PTMNStyle;
  PMarkStyleInd, PMarkStyle: Pointer;
  TmpStrPosParams: TN_StrPosParams;
begin
  CommonFont := nil; // to avoid warning
  LHNumGroups := 1;  // to avoid warning

  N_s := ObjName; // debug
  if N_s = 'LHRowNames' then
    N_i := 1;

  with NGCont, NGCont.DstOCanv, PIDP()^ do
  begin

  if TMBaseComp <> nil then // debug
    N_s1 := TMBaseComp.ObjName;

  DefFmt := '%f';

  //***** Set PFirstString and NumStrings from TMStrings field

  NumStrings := TMStrings.ALength();
  if NumStrings > 0 then
    PFirstString := PString(TMStrings.P())
  else // use default String
  begin
    DefStr := 'Not Given';
    PFirstString := @DefStr;
    NumStrings := 1;
  end;

  //***** Analize TMBaseComp type

  LinHist   := nil;
  PieChart  := nil;
  AxisTics  := nil;
  TextMarks := nil;

  if      TMBaseComp is TN_UD2DLinHist then LinHist   := TN_UD2DLinHist(TMBaseComp)
  else if TMBaseComp is TN_UDPieChart  then PieChart  := TN_UDPieChart(TMBaseComp)
  else if TMBaseComp is TN_UDAxisTics  then AxisTics  := TN_UDAxisTics(TMBaseComp)
  else if TMBaseComp is TN_UDTextMarks then TextMarks := TN_UDTextMarks(TMBaseComp);

  if LinHist <> nil then
  with LinHist.PIDP()^ do
  begin
    LHValues.ALength( LHNX, LHNY ); // Get NX, NY

    if lhfGroupsAlongX in LHFlags then
    begin
      LHNumGroups := LHNX;
      LHNumElems  := LHNY;
    end else // Groups Along Y
    begin
      LHNumGroups := LHNY;
      LHNumElems  := LHNX;
    end;
  end; // with LinHist.PIDP()^ do,  if LinHist <> nil then


  //***** Set PVals (Pointer to Values) and NumVals if needed
  //      PVas <> nil means that Strings shoud be obtained from PVals

  PVals     := nil;
  NumVals   := 0;
  PBCRects  := nil;
  PBCPoints := nil;

  if tmfBCValues in TMFlags then // Set PVals, PBCRects, PBCPoints by BaseComp
  begin
    if LinHist <> nil then //*************** get Values from LinHist
    with LinHist.PIDP()^ do
    begin
      PVals := PDouble(LHValues.P());
      NumVals := LHValues.Alength;
    end else if PieChart <> nil then //***** get Values from PieChart
    with PieChart do
    begin
      PVals := @PieValues[0];
      NumVals := Length(PieValues);
      if NumVals > 0 then // a precaution
        PBCPoints := @BPPixValStrings[0];
    end else if AxisTics <> nil then //***** get Values from AxisTics
    with AxisTics, AxisTics.PIDP()^ do
    begin
      NumVals := Length(ATTicValues);
      if NumVals > 0 then // a precaution
      begin
        PVals := @ATTicValues[0];
        PBCRects := @ATTicPixRects[0];
      end;
    end;
  end else if tmfOwnValues in TMFlags then // Set PVals by TMValues Self field
  begin
    PVals := PDouble(TMValues.P());
    NumVals := TMValues.Alength;
  end;

  //***** Set NumMarks (Number of Marks to Draw) and  PBCRects, PBCPoints

  if PVals <> nil then // Set NumMarks by Number of Values
    NumMarks := NumVals
  else if tmfLHGroups in TMFlags then  // Set NumMarks by LinHist.LHPixGroupRects
  begin
    NumMarks := Length(LinHist.LHPixGroupRects);
    if NumMarks > 0 then // a precation
      PBCRects := @LinHist.LHPixGroupRects[0];
  end else if ([tmfLHColumns,tmfLHElemsInGroup,tmfLHValues] * TMFlags) <> [] then // Set NumMarks by LinHist.LHPixElemRects
  begin
    NumMarks := Length(LinHist.LHPixElemRects);
    if NumMarks > 0 then // a precation
      PBCRects := @LinHist.LHPixElemRects[0];
  end else if TextMarks <> nil then // Set NumMarks by TextMarks.TMPixMarkRects
  begin
    NumMarks := Length(TextMarks.TMPixMarkRects);
    if NumMarks > 0 then // a precation
      PBCRects := @TextMarks.TMPixMarkRects[0];
  end else if PFirstString <> @DefStr then // Set NumMarks by Number of Strings in TMStrings
    NumMarks := NumStrings
  else
    Exit; // nothig to Draw

  //***** Calc X or Y Uniform BasePoints coords if needed

  if tmctUniform = TMXCoordsType then // Calc X uniform coords
  begin
    if Length(OwnBPPixCoords) < NumMarks then
      SetLength( OwnBPPixCoords, NumMarks );

    CalcODFSCoords( NumMarks, N_RectWidth( CompIntPixRect ), @TMUniformLP,
                                                             TmpUniformCoords );
  end; // if tmctUniform = TMXCoordsType then // Calc X uniform coords

  if tmctUniform = TMYCoordsType then // Calc Y uniform coords
  begin
    if Length(OwnBPPixCoords) < NumMarks then
      SetLength( OwnBPPixCoords, NumMarks );

    CalcODFSCoords( NumMarks, N_RectHeight( CompIntPixRect ), @TMUniformLP,
                                                             TmpUniformCoords );
  end; // if tmctUniform = TMYCoordsType then // Calc Y uniform coords

  if not (tmfNewMode in TMFlags) then
  begin
    //***** CommonFont Font will be used only if same Font will be used for all Strings
    CommonFont := TMMainStyle.TMSFont;
    N_SetNFont( CommonFont, DstOCanv, TMMainStyle.TMSStrPos.SPPBLAngle );
    SetFontAttribs( TMMainStyle.TMSTextColor );
  end;

  SetLength( TMPixMarkRects, NumMarks ); // for possible use in another TextMarks

  if N_s = 'LHRowNums' then // debug
    N_i := 1;


  //***** Main Draw Marks Loop, the following variables should be already Set:
  // NumMarks     - Number of Marks to Draw
  // NumStrings   - Number of given Strings (may be less then NumMarks)
  // PFirstString - Pointer to First String to Draw

  for i := 0 to NumMarks-1 do //***** Main Draw Marks Loop
  begin //  This Loop Table of Content:
        //***** Set PCurNStyle, PCurStyle - Pointers to old and new Current Style
        //***** Set PCurString - Pointer to Current String to Draw
        //***** Set CurBasePoint.X - Current Base Point X Coord
        //***** Set CurBasePoint.Y - Current Base Point Y Coord
        //***** Set Font if needed
        //***** Draw Current Mark using: PCurString, CurBasePoint, PCurStyle

  //***** Set PCurNStyle, PCurStyle - Pointers to new and old Current Style
  PCurNStyle := nil; // to avoid warning
  PCurStyle  := nil; // to avoid warning

  if tmfNewMode in TMFlags then
  begin
    if TMNStyles.ALength() = 0 then Exit; // a precaution

    if tmfLHElemsInGroup in TMFlags then // All Elemes with same Index in Group have same StyleInd
      NStyleIndsInd := i mod LHNumGroups
    else
      NStyleIndsInd := i;

    if TMNStyleInds.ALength() = 0 then
      PCurNStyle := TN_PTMNStyle(TMNStyles.P(0))
    else // TMNStyleInds is given
    begin
      NStyleInd := PInteger(TMNStyleInds.PS( NStyleIndsInd ))^;
      PCurNStyle := TN_PTMNStyle(TMNStyles.PS( NStyleInd ));
    end;
  end else // Old Mode
  begin
    PCurStyle := @TMMainStyle;
    PMarkStyleInd := TMMarkStyleInds.P( i );
    if PMarkStyleInd <> nil then
    begin
      MarkStyleInd := PByte(PMarkStyleInd)^;

      if MarkStyleInd >= 1 then
      begin
        PMarkStyle := TMMarkStyles.P( MarkStyleInd-1 );
        if PMarkStyle <> nil then PCurStyle := PMarkStyle;
      end; // if MarkStyleInd >= 1 then
    end; // if PMarkStyleInd <> nil then
  end; // else // Old Mode


  //***** Set PCurString - Pointer to Current String to Draw

  if PVals <> nil then // String to Draw should be converted from PVals (NumVals=NumMarks)
  begin
    if tmfNewMode in TMFlags then
      CurFmt := PCurNStyle^.TMSValsFmt
    else
      CurFmt := PCurStyle^.TMSValsFmt;

    if CurFmt = '' then CurFmt := DefFmt;
    PCurVal := PVals;
    Inc( PCurVal, i );
    CurString := Format( CurFmt, [PCurVal^] );
    PCurString := @CurString;
  end else // String to Draw is in TMStrings (NumStrings >= 1)
  begin
    PCurString := PFirstString;
    StringInd := i mod NumStrings;
    Inc( PCurString, StringInd );
  end;

  if tmfNewMode in TMFlags then
  begin
    if PCurNStyle^.TMSAuxString <> '' then // add TMSAuxString
    begin
      if tmsfAddAuxBefore in PCurNStyle^.TMSFlags then
        TmpStr := PCurString^ + PCurNStyle^.TMSAuxString
      else
        TmpStr := PCurNStyle^.TMSAuxString + PCurString^;

      PCurString := @TmpStr;
    end;
  end else // Old Mode
  begin
    if PCurStyle^.TMSAuxString <> '' then // add TMSAuxString
    begin
      TmpStr := PCurString^ + PCurStyle^.TMSAuxString;
      PCurString := @TmpStr;
    end; // if PCurStyle^.TMSAuxString <> '' then // add TMSAuxString
  end; // else // Old Mode


  if tmfNewMode in TMFlags then // prepare for Setting CurBasePoint
  begin
    ShiftFPix := ConvMSToFPix( PCurNStyle^.TMSTRSizePos.RSPBPShift, N_ZFPoint );
  end; // if tmfNewMode in TMFlags then // prepare for Setting CurBasePoint

  //***** Set CurBasePoint.X - Current Base Point X Coord

  CurBasePoint := FPoint( N_RectCenter( CompIntPixRect ) ); // a precaution

  if tmfNewMode in TMFlags then
  begin
    // Calc CurFRect.Left, Right in absolute float pixels

    if tmctBaseComp = TMXCoordsType then // use BaseComponent Coords (PBCRects or PBCPoints)
    begin

      PCurFPoint := PBCPoints;
      if PCurFPoint <> nil then // CurFRect is defined by Base Component FPoint
      begin
        Inc( PCurFPoint, i );
        if PCurFPoint^.X = N_NotAFloat then Continue;

        CurFRect.Left := PCurFPoint^.X;
        CurFRect.Right := PCurFPoint^.X;
      end; // if PCurFPoint <> nil then // CurFRect is defined by Base Component FPoint

      PCurFRect := PBCRects;
      if PCurFRect <> nil then // CurFRect is defined by Base Component FRect
      begin
        Inc( PCurFRect, i );

        if PCurFRect^.Left = N_NotAFloat then Continue;

        CurFRect := PCurFRect^;
      end; // if PCurFRect <> nil then // CurFRect is defined by Base Component FRect

    end else if tmctFixed = TMXCoordsType then // calc Fixed X Coord
    begin
      CurFRect := FRect( CompIntPixRect );
    end else if tmctSelfInPrc = TMXCoordsType then // use TMSelfRects in %
    begin
      if TMSelfRects = nil then Continue;

      PCurFRect := PFRect(TMSelfRects.P( i ));
      if PCurFRect = nil then Continue;

      Size := CompIntPixRect.Right - CompIntPixRect.Left;
      CurFRect.Left  := CompIntPixRect.Left + 0.01* PCurFRect^.Left*Size;
      CurFRect.Right := CompIntPixRect.Left + 0.01* PCurFRect^.Right*Size;
    end else if tmctSelfInmm = TMXCoordsType then // use TMSelfRects in mm
    begin
      if TMSelfRects = nil then Continue;

      PCurFRect := PFRect(TMSelfRects.P( i ));
      if PCurFRect = nil then Continue;

      Coef := CurLSUPixSize*72/25.4;
      CurFRect.Left  := CompIntPixRect.Left + PCurFRect^.Left*Coef;
      CurFRect.Right := CompIntPixRect.Left + PCurFRect^.Right*Coef;
    end else if tmctUniform = TMXCoordsType then // Uniform Layout use TmpUniformCoords
    begin
      CurFRect.Left  := CompIntPixRect.Left + TmpUniformCoords[i].X;
      CurFRect.Right := CompIntPixRect.Left + TmpUniformCoords[i].Y;
    end;

    // CurFRect.Left, Right are OK, calc CurBasePoint.X

    with CurFRect, PCurNStyle^.TMSTRSizePos do
      CurBasePoint.X := Left + 0.01*RSPBPPos.X*(Right-Left) + ShiftFPix.X;

  end else // Old Mode, X Coord
  begin
    if tmctBaseComp = TMXCoordsType then // use BaseComponent Coords (PBCRects or PBCPoints)
    begin

      PCurFPoint := PBCPoints;
      if PCurFPoint <> nil then // FPoint is defined by Base Component
      begin
        Inc( PCurFPoint, i );
        if PCurFPoint^.X = N_NotAFloat then Continue;
        CurBasePoint.X := PCurFPoint^.X;
      end; // if PCurFPoint <> nil then // FPoint is defined by Base Component

      PCurFRect := PBCRects;
      if PCurFRect <> nil then // FRect is defined by Base Component
      begin
        Inc( PCurFRect, i );

        if PCurFRect^.Left = N_NotAFloat then Continue;

        with PCurFRect^, PCurStyle^.TMSBPPos do
          CurBasePoint.X := Right*0.01*X + Left*0.01*(100-X);
      end; // if PCurFRect <> nil then // FRect is defined by Base Component

    end else if tmctFixed = TMXCoordsType then // calc Fixed X Coord
    begin
      with CompIntPixRect, PCurStyle^.TMSBPPos do
        CurBasePoint.X := Left + (Right - Left)*0.01*X;
    end else if tmctSelfInPrc = TMXCoordsType then // use TMBPCoords in %
    begin
      CurBasePoint.X := 10;
    end else if tmctSelfInmm = TMXCoordsType then // use TMBPCoords in mm
    begin
      CurBasePoint.X := 10;
    end else if tmctUniform = TMXCoordsType then // Uniform Layout use TmpUniformCoords
    begin
      with PCurStyle^.TMSBPPos do
        CurBasePoint.X := CompIntPixRect.Left + TmpUniformCoords[i].Y*0.01*X +
                                                TmpUniformCoords[i].X*0.01*(100-X);
    end;
  end; // else // Old Mode, X Coord


  //***** Set CurBasePoint.Y - Current Base Point Y Coord

  if tmfNewMode in TMFlags then
  begin

    // Calc CurFRect.Top, Bottom in absolute float pixels

    if tmctBaseComp = TMYCoordsType then // use BaseComponent Coords (PBCRects or PBCPoints)
    begin

      PCurFPoint := PBCPoints;
      if PCurFPoint <> nil then // CurFRect is defined by Base Component FPoint
      begin
        Inc( PCurFPoint, i );
        if PCurFPoint^.X = N_NotAFloat then Continue;

        CurFRect.Top := PCurFPoint^.Y;
        CurFRect.Right := PCurFPoint^.Y;
      end; // if PCurFPoint <> nil then // CurFRect is defined by Base Component FPoint

      PCurFRect := PBCRects;
      if PCurFRect <> nil then // CurFRect is defined by Base Component FRect
      begin
        Inc( PCurFRect, i );

        if PCurFRect^.Left = N_NotAFloat then Continue;

        CurFRect := PCurFRect^;
      end; // if PCurFRect <> nil then // CurFRect is defined by Base Component FRect

    end else if tmctFixed = TMYCoordsType then // calc Fixed Y Coord
    begin
      CurFRect := FRect( CompIntPixRect );
    end else if tmctSelfInPrc = TMYCoordsType then // use TMSelfRects in %
    begin
      if TMSelfRects = nil then Continue;

      PCurFRect := PFRect(TMSelfRects.P( i ));
      if PCurFRect = nil then Continue;

      Size := CompIntPixRect.Bottom - CompIntPixRect.Top;
      CurFRect.Top    := CompIntPixRect.Top + 0.01* PCurFRect^.Top*Size;
      CurFRect.Bottom := CompIntPixRect.Top + 0.01* PCurFRect^.Bottom*Size;
    end else if tmctSelfInmm = TMYCoordsType then // use TMSelfRects in mm
    begin
      if TMSelfRects = nil then Continue;

      PCurFRect := PFRect(TMSelfRects.P( i ));
      if PCurFRect = nil then Continue;

      Coef := CurLSUPixSize*72/25.4;
      CurFRect.Top    := CompIntPixRect.Top + PCurFRect^.Top*Coef;
      CurFRect.Bottom := CompIntPixRect.Top + PCurFRect^.Bottom*Coef;
    end else if tmctUniform = TMYCoordsType then // Uniform Layout use TmpUniformCoords
    begin
      CurFRect.Top    := CompIntPixRect.Top + TmpUniformCoords[i].X;
      CurFRect.Bottom := CompIntPixRect.Top + TmpUniformCoords[i].Y;
    end;

    // CurFRect.Top, Bottom are OK, calc CurBasePoint.Y

    with CurFRect, PCurNStyle^.TMSTRSizePos do
      CurBasePoint.Y := Top + 0.01*RSPBPPos.Y*(Bottom-Top) + ShiftFPix.Y;

  end else // Old Mode, Y Coord
  begin
    if tmctBaseComp = TMYCoordsType then // use BaseComponent Coords (PBCRects or PBCPoints)
    begin

      PCurFPoint := PBCPoints;
      if PCurFPoint <> nil then // FPoint is defined by Base Component
      begin
        Inc( PCurFPoint, i );
        if PCurFPoint^.Y = N_NotAFloat then Continue;
        CurBasePoint.Y := PCurFPoint^.Y;
      end; // if PCurFPoint <> nil then // FPoint is defined by Base Component

      PCurFRect := PBCRects;
      if PCurFRect <> nil then // FRect is defined by Base Component
      begin
        Inc( PCurFRect, i );

        if PCurFRect^.Top = N_NotAFloat then Continue;

        with PCurFRect^, PCurStyle^.TMSBPPos do
          CurBasePoint.Y := Bottom*0.01*Y + Top*0.01*(100-Y);
      end; // if PCurFRect <> nil then // FRect is defined by Base Component

    end else if tmctFixed = TMYCoordsType then // calc Fixed X Coord
    begin
        with CompIntPixRect, PCurStyle^.TMSBPPos do
          CurBasePoint.Y := Top + (Bottom - Top)*0.01*Y;
    end else if tmctSelfInPrc = TMYCoordsType then // use TMBPCoords in %
    begin
      CurBasePoint.Y := 10;
    end else if tmctSelfInmm = TMYCoordsType then // use TMBPCoords in mm
    begin
      CurBasePoint.Y := 10;
    end else if tmctUniform = TMYCoordsType then // Uniform Layout use TmpUniformCoords
    begin
      with PCurStyle^.TMSBPPos do
        CurBasePoint.Y := CompIntPixRect.Top + TmpUniformCoords[i].Y*0.01*Y +
                                               TmpUniformCoords[i].X*0.01*(100-Y);
    end;
  end; // else // Old Mode, Y Coord


  //***** Set Font

  if tmfNewMode in TMFlags then
  begin
    N_SetNFont( PCurNStyle^.TMSFont, DstOCanv );
    SetFontAttribs( PCurNStyle^.TMSTextColor );
  end else // Old Mode
  begin
    if CommonFont <> PCurStyle^.TMSFont then // set new Font
    begin
      N_SetNFont( PCurStyle^.TMSFont, DstOCanv, PCurStyle^.TMSStrPos.SPPBLAngle );
      CommonFont := nil;
    end; // if CommonFont <> PCurStyle^.TMSFont then // set new Font

    SetFontAttribs( PCurStyle^.TMSTextColor );
  end; // else // Old Mode


  //***** Draw Current Mark using: PCurString, CurBasePoint, PCurStyle


//  BackPixRect := NGCont.DstOCanv.ShiftPixRectByLSURect(
//                                IRect(StrPixRect), PCurStyle^.TMSAddMarkRect );

  N_s2 := PCurString^; // debug

  if TMMaxTextmmWidth > 0 then
  begin
    MaxPixWidth := Round( TMMaxTextmmWidth * NGCont.mmPixSize.X );
    DrawStr := K_StrCutByWidth( NGCont.DstOCanv.HMDC, PCurString^, '...', MaxPixWidth );
  end else
    DrawStr := PCurString^;

  if tmfNewMode in TMFlags then
  begin
    if tmfMultiRow in TMFlags then // Text formatting in ParaBox should be used
    begin

    end else // Single Row Text
    begin
      FillChar( TmpStrPosParams, SizeOf(TmpStrPosParams), 0 );
      TmpStrPosParams.SPPHotPoint := PCurNStyle^.TMSTRSizePos.RSPHPPos;
      StrPixRect := NGCont.DstOCanv.CalcStrPixRect( DrawStr, CurBasePoint,
                                                             @TmpStrPosParams );
      TMPixMarkRects[i] := StrPixRect; // Save Rect of current Mark (for using in another TextMarks)
      NGCont.GDrawString( DrawStr, CurBasePoint, @TmpStrPosParams );
    end;
  end else // Old Mode
  begin
    StrPixRect := NGCont.DstOCanv.CalcStrPixRect( DrawStr, CurBasePoint,
                                                      @PCurStyle^.TMSStrPos );
    TMPixMarkRects[i] := StrPixRect; // Save Rect of current Mark (for using in another TextMarks)
    NGCont.DrawCPanel( PCurStyle^.TMSBackPanel, IRect( StrPixRect ) );
    NGCont.GDrawString( DrawStr, CurBasePoint, @PCurStyle^.TMSStrPos );
  end; // else // Old Mode


  end; // for i := 0 to NumMarks-1 do //***** Main Draw Marks Loop

  end; // with NGCont, NGCont.DstOCanv, PIDP()^ do
end; // end_of procedure TN_UDTextMarks.BeforeAction


//********** TN_UDAutoAxis class methods  **************

//**************************************************** TN_UDAutoAxis.Create ***
//
constructor TN_UDAutoAxis.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDAutoAxisCI;
  ImgInd := 88;
end; // end_of constructor TN_UDAutoAxis.Create

//*************************************************** TN_UDAutoAxis.Destroy ***
//
destructor TN_UDAutoAxis.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDAutoAxis.Destroy

//******************************************************* TN_UDAutoAxis.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDAutoAxis.PSP(): TN_PRAutoAxis;
begin
  Result := TN_PRAutoAxis(R.P());
end; // end_of function TN_UDAutoAxis.PSP

//******************************************************* TN_UDAutoAxis.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDAutoAxis.PDP(): TN_PRAutoAxis;
begin
  if DynPar <> nil then Result := TN_PRAutoAxis(DynPar.P())
                   else Result := TN_PRAutoAxis(R.P());
end; // end_of function TN_UDAutoAxis.PDP

//****************************************************** TN_UDAutoAxis.PISP ***
// return typed pointer to Individual Static AutoAxis Params
//
function TN_UDAutoAxis.PISP(): TN_PCAutoAxis;
begin
  Result := @(TN_PRAutoAxis(R.P())^.CAutoAxis);
end; // function TN_UDAutoAxis.PISP

//****************************************************** TN_UDAutoAxis.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic AutoAxis Params
// otherwise return typed pointer to Individual Static AutoAxis Params
//
function TN_UDAutoAxis.PIDP(): TN_PCAutoAxis;
begin
  if DynPar <> nil then
    Result := @(TN_PRAutoAxis(DynPar.P())^.CAutoAxis)
  else
    Result := @(TN_PRAutoAxis(R.P())^.CAutoAxis);
end; // function TN_UDAutoAxis.PIDP

//************************************************ TN_UDAutoAxis.PascalInit ***
// Init self
//
procedure TN_UDAutoAxis.PascalInit();
begin
  Inherited;
end; // procedure TN_UDAutoAxis.PascalInit

//********************************************** TN_UDAutoAxis.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDAutoAxis.BeforeAction();
var
  i, AResStepVal, AResStepExp: integer;
  AResStep, AResBase: double;
  CurMark: string;
  P1, P2: TPoint;
  PIndP: TN_PCAutoAxis;
  CSArrow: TN_CSArrow;
  TicsAttr: TK_RArray;
  ShapeCoords: TN_ShapeCoords;
  TicksMidPoints: TN_IPArray;
  EndTickPoints: TN_FPArray;
  TickValues: TN_DArray;
  StrPosParams: TN_StrPosParams;
  PRCompD: TN_PRAutoAxis;

  procedure DrawTicks( APAATicsParams: TN_PAATicsParams ); // local
  // Draw Ticks
  // and calc EndTickPoints if EndTickPoints <> nil
  var
    i, dul, dbr: integer;
  begin
    with PIndP^.AA2DSpace, PIndP^, APAATicsParams^, NGCont.DstOCanv do
    begin

    ShapeCoords.Clear();

    dul := LLWToPix( AATSize.X ) - 1; // upper or Left Tick Size
    dbr := LLWToPix( AATSize.Y ) - 1; // bottom or Right Tick Size

    for i := 0 to High(TicksMidPoints) do
    begin

      if AxisIsVertical then // Vertical Axis
      begin
        P1.Y := TicksMidPoints[i].Y;
        P2.Y := P1.Y;
        EndTickPoints[i].Y := P1.Y;

        P1.X := TicksMidPoints[i].X - dul;
        P2.X := TicksMidPoints[i].X + dbr;

        if AxisIsLess then // Axis is to left from 2DSpaceComp
          EndTickPoints[i].X := P1.X
        else // Axis is to right from 2DSpaceComp
          EndTickPoints[i].X := P2.X;
      end else // Horizontal Axis
      begin
        P1.X := TicksMidPoints[i].X;
        P2.X := P1.X;
        EndTickPoints[i].X := P1.X;

        P1.Y := TicksMidPoints[i].Y - dul;
        P2.Y := TicksMidPoints[i].Y + dbr;

        if AxisIsLess then // Axis is Upper than 2DSpaceComp
          EndTickPoints[i].Y := P1.Y
        else // Axis is Lower than 2DSpaceComp
          EndTickPoints[i].Y := P2.Y;
      end; // else // Horizontal Axis

      ShapeCoords.AddSeparateSegm( P1, P2 );

    end; // for i := 0 to High(TicksMidPoints) do

    TicsAttr := AATAttribs;
    if TicsAttr = nil then TicsAttr := AAMiddleTics.AATAttribs;
    if TicsAttr = nil then TicsAttr := AABigTics.AATAttribs;

    NGCont.DrawShape( ShapeCoords, TicsAttr, N_ZFPoint );

    end; // with PIndP^, APAATicsParams^, NGCont.DstOCanv do
  end; // procedure DrawTicks - local

begin
  N_s := ObjName;
  ShapeCoords := TN_ShapeCoords.Create();

  PRCompD := PDP();
  PIndP := @PRCompD^.CAutoAxis;

  with PRCompD^, PIndP^, PIndP^.AA2DSpace, PCCD()^, NGCont.DstOCanv do
  begin
    If AA2DSpace = nil then Exit;

    AA2DSpace.CalcCoefs6();
    CalcAxisInfo( Self );

    with AABigTics.AATMinStep do // temporary
    begin
      if MSSValue = 0 then
      begin
        MSSValue := 10;
        MSUnit := msuLSU;
      end;
    end;

    CalcAxisStep( [], @AABigTics.AATMinStep, AResStep, AResBase,
                                             AResStepVal, AResStepExp );

    GetTicksMidPoints( Self, AResBase, AResStep, LLWToPix(AALinePos.X),
                                       TicksMidPoints, TickValues );

    SetLength( EndTickPoints, Length(TicksMidPoints) );

    FillChar( CSArrow, SizeOf(CSArrow), 0 );
    with CSArrow do // set Arrow params
    begin
      if AxisIsVertical then // Vertical Axis (SARect.UpperLeft is Beg Point)
      begin
        SARect.Left  := TicksMidPoints[0].X;
        SARect.Right := TicksMidPoints[0].X;

        if TicksMidPoints[0].Y < TicksMidPoints[1].Y then // From Top to Down
        begin
          SARect.Top    := AA2DSpace.CompIntPixRect.Top;
          SARect.Bottom := AA2DSpace.CompIntPixRect.Bottom;
        end else // From Down to Top
        begin
          SARect.Top    := AA2DSpace.CompIntPixRect.Bottom;
          SARect.Bottom := AA2DSpace.CompIntPixRect.Top;
        end;
      end else // Horizontal Axis
      begin
        SARect.Top    := TicksMidPoints[0].Y;
        SARect.Bottom := TicksMidPoints[0].Y;

        if TicksMidPoints[0].X < TicksMidPoints[1].X then // From Left to Right
        begin
          SARect.Left  := CompIntPixRect.Left;
          SARect.Right := CompIntPixRect.Right;
        end else // From Right to Left
        begin
          SARect.Left  := CompIntPixRect.Right;
          SARect.Right := CompIntPixRect.Left;
        end;
      end;

      if aafSkipArrow in AAFlags then
        SAFlags := [safJustLine]
      else // Set Arrow Params and zero PenWidth
      with TN_PContAttr(AALineAttribs.P())^ do
      begin
        SAWidths.X  := CAPenWidth;                     // Arrow Line width
        SAWidths.Y  := AAArrowParams.Left*SAWidths.X;  // Arrow width
        SALengths.X := AAArrowParams.Top*SAWidths.X;   // Arrow near line length
        SALengths.Y := AAArrowParams.Right*SAWidths.X; // Arrow outer length
        CAPenWidth  := 0;
      end;

      SAAttribs := AALineAttribs;

    end; // with CSArrow do // set Arrow params

    NGCont.DrawStraightArrow( @CSArrow );

    DrawTicks( @AABigTics );

    //***** Draw Ticks Marks

    with StrPosParams do // Prepare StrPosParams
    begin
      SPPBLAngle := 0;

      if AxisIsVertical then //************************ Vertical Axis
      begin
        if AxisIsLess then // Axis is to left from 2DSpaceComp
        begin
          SPPShift := FPoint( -AALinePos.Y, 0 );
          SPPHotPoint := FPoint( 100, 50 );
        end else // Axis is to right from 2DSpaceComp
        begin
          SPPShift := FPoint( AALinePos.Y, 0 );
          SPPHotPoint := FPoint( 0, 50 );
        end;
      end else //************************************ Horizontal Axis
      begin
        if AxisIsLess then // Axis is Upper than 2DSpaceComp
        begin
          SPPShift := FPoint( 0, -AALinePos.Y );
          SPPHotPoint := FPoint( 50, 100 );
        end else // Axis is Lower than 2DSpaceComp
        begin
          SPPShift := FPoint( 0, AALinePos.Y );
          SPPHotPoint := FPoint( 50, 0 );
        end;
      end; // else // Horizontal Axis

    end; // with StrPosParams do // Prepare StrPosParams

    N_SetNFont( AAFont, NGCont.DstOCanv, 0 );

    for i := 0 to High(EndTickPoints) do // Draw Ticks Marks
    begin
      CurMark := Format( AAMarksFmt, [TickValues[i]] );
      NGCont.GDrawString( CurMark, EndTickPoints[i], @StrPosParams );
    end; // for i := 0 to High(EndTickPoints) do // Draw Ticks Marks

  end; // with PRCompD^, PIndP^, PIndP^.AA2DSpace, PCCD()^, NGCont.DstOCanv do

  ShapeCoords.Free;
end; // end_of procedure TN_UDAutoAxis.BeforeAction


//********** TN_UD2DFunc class methods  **************

//********************************************** TN_UD2DFunc.Create ***
//
constructor TN_UD2DFunc.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UD2DFuncCI;
  ImgInd := 57;
end; // end_of constructor TN_UD2DFunc.Create

//********************************************* TN_UD2DFunc.Destroy ***
//
destructor TN_UD2DFunc.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UD2DFunc.Destroy

//********************************************** TN_UD2DFunc.PSP ***
// Return typed pointer to all Static Params
//
function TN_UD2DFunc.PSP(): TN_PR2DFunc;
begin
  Result := TN_PR2DFunc(R.P());
end; // end_of function TN_UD2DFunc.PSP

//********************************************** TN_UD2DFunc.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UD2DFunc.PDP(): TN_PR2DFunc;
begin
  if DynPar <> nil then Result := TN_PR2DFunc(DynPar.P())
                   else Result := TN_PR2DFunc(R.P());
end; // end_of function TN_UD2DFunc.PDP

//******************************************* TN_UD2DFunc.PISP ***
// return typed pointer to Individual Static 2DFunc Params
//
function TN_UD2DFunc.PISP(): TN_PC2DFunc;
begin
  Result := @(TN_PR2DFunc(R.P())^.C2DFunc);
end; // function TN_UD2DFunc.PISP

//******************************************* TN_UD2DFunc.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic 2DFunc Params
// otherwise return typed pointer to Individual Static 2DFunc Params
//
function TN_UD2DFunc.PIDP(): TN_PC2DFunc;
begin
  if DynPar <> nil then
    Result := @(TN_PR2DFunc(DynPar.P())^.C2DFunc)
  else
    Result := @(TN_PR2DFunc(R.P())^.C2DFunc);
end; // function TN_UD2DFunc.PIDP

//********************************************** TN_UD2DFunc.PascalInit ***
// Init self
//
procedure TN_UD2DFunc.PascalInit();
begin
  Inherited;
end; // procedure TN_UD2DFunc.PascalInit

//************************************** TN_UD2DFunc.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UD2DFunc.BeforeAction();
var
  i, NumPoints, NumCurves: integer;
  ShapeCoords: TN_ShapeCoords;
  PRI: TN_PR2DFunc;
begin
  PRI := PDP();

  with PRI^, PRI^.C2DSpace, PRI^.C2DFunc do
  begin
  NumCurves := TDCurves.ALength();
  if NumCurves = 0 then Exit; // nothing to draw

  if TDFAttribs <> nil then // Create RunTime ContAttr, used only by Legend
    TDFAttribs.ASetLength( NumCurves )
  else
    TDFAttribs := K_RCreateByTypeName( 'TN_ContAttrArray', NumCurves );

  CalcCoefs6( True );
  ShapeCoords := TN_ShapeCoords.Create();

  //****** Conv Curve Coords to ShapeCoords format and Draw them

  for i := 0 to NumCurves-1 do // along all curves
  with ShapeCoords, TN_P2DCurve(TDCurves.P(i))^ do
  begin
    TK_PRArray(TDFAttribs.P(i))^ := CurveAttr.AAddRef(); // for Legend

    NumPoints := Min( CurveArgVals.ALength(), CurveFuncVals.ALength() );
    if NumPoints <= 1 then Continue;

    Clear();
    with SCBufs[PrepBuf( NumPoints, bfctPolyLine )] do
      N_AffConv6Points( PDouble(CurveArgVals.P(0)), PDouble(CurveFuncVals.P(0)),
                                  @BFC[SCBegInd], NumPoints, AF2P6 );
    NGCont.DrawShape( ShapeCoords, CurveAttr, N_ZFPoint ); // FPoint(CompIntPixRect.TopLeft) );

  end; // for i := 0 to NumCurves-1 do // along all curves

  ShapeCoords.Free();
  end; // with PRI^, PRI^.C2DSpace, PRI^.CIsoLines do
end; // end_of procedure TN_UD2DFunc.BeforeAction


//********** TN_UDIsoLines class methods  **************

//********************************************** TN_UDIsoLines.Create ***
//
constructor TN_UDIsoLines.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDIsoLinesCI;
  ImgInd := 12;
end; // end_of constructor TN_UDIsoLines.Create

//********************************************* TN_UDIsoLines.Destroy ***
//
destructor TN_UDIsoLines.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDIsoLines.Destroy

//********************************************** TN_UDIsoLines.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDIsoLines.PSP(): TN_PRIsoLines;
begin
  Result := TN_PRIsoLines(R.P());
end; // end_of function TN_UDIsoLines.PSP

//********************************************** TN_UDIsoLines.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDIsoLines.PDP(): TN_PRIsoLines;
begin
  if DynPar <> nil then Result := TN_PRIsoLines(DynPar.P())
                   else Result := TN_PRIsoLines(R.P());
end; // end_of function TN_UDIsoLines.PDP

//******************************************* TN_UDIsoLines.PISP ***
// return typed pointer to Individual Static IsoLines Params
//
function TN_UDIsoLines.PISP(): TN_PCIsoLines;
begin
  Result := @(TN_PRIsoLines(R.P())^.CIsoLines);
end; // function TN_UDIsoLines.PISP

//******************************************* TN_UDIsoLines.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic IsoLines Params
// otherwise return typed pointer to Individual Static IsoLines Params
//
function TN_UDIsoLines.PIDP(): TN_PCIsoLines;
begin
  if DynPar <> nil then
    Result := @(TN_PRIsoLines(DynPar.P())^.CIsoLines)
  else
    Result := @(TN_PRIsoLines(R.P())^.CIsoLines);
end; // function TN_UDIsoLines.PIDP

//********************************************** TN_UDIsoLines.PascalInit ***
// Init self
//
procedure TN_UDIsoLines.PascalInit();
begin
  Inherited;
end; // procedure TN_UDIsoLines.PascalInit

//************************************** TN_UDIsoLines.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDIsoLines.BeforeAction();
var
  DataDir: TN_UDBase;
begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  DataDir := CreateVisRepr();
  DrawAllMapLayers( DataDir );
end; // end_of procedure TN_UDIsoLines.BeforeAction

//************************************** TN_UDIsoLines.CreateVisRepr ***
// Create Self Visual Representation in DataRoot, return DataRoot
//
function TN_UDIsoLines.CreateVisRepr(): TN_UDBase;
var
  i, SrcMNX, SrcMNY, SrcMNXY: integer;
  DataDir: TN_UDBase;
  PRI: TN_PRIsoLines;
  Saved2DS: TN_C2DSpace;
  WrkVMatr: TN_FVMatr;
  GridNodes: TN_UDPoints;
  ULines1, ULines2, GridLines: TN_ULines;
  UConts: TN_UContours;
  MLIzo, MLGridLines, MLGridLabels: TN_UDMapLayer;
  UDGridLabels: TK_UDRArray;
  SplineLineObj: TN_SplineLineObj;
  IzoContsMode: boolean;
  CompAFRect, ResIndsRect, MatrIndsRect: TFRect;
  IndsAffCoefs: TN_AffCoefs4;
begin
  UConts := nil;
  PRI := PDP();

  with PRI^, PRI^.C2DSpace, PRI^.CIsoLines do
  begin
  //***** Set IzoContsMode and Prepare Data Dir

  Result := nil;
  if CILMMValues.ALength() = 0 then Exit; // nothing to draw

  with TN_PMinMaxValues(CILMMValues.P(0))^ do
    IzoContsMode := (MMVMinValue <> MMVMaxValue);

  DataDir := GetDataRoot( True );
  DataDir.ClearChilds();
  Result := DataDir;


  //***** Prepare IntVMatr

  SrcMNXY := CILVMatr.ALength();
  SrcMNX  := CILVMatr.HCol+1;
  SrcMNY  := SrcMNXY div SrcMNX;
  if IntVMatr = nil then IntVMatr := TN_FVMatr.Create();

  if CILIntMatrScale <= 1 then  // no Interpolation
  begin
    IntVMatr.SetValues( PDouble(CILVMatr.P()), SrcMNX, SrcMNY );
  end else //********************* Interpolation is needed
  begin
    WrkVMatr := TN_FVMatr.Create( PDouble(CILVMatr.P()), SrcMNX, SrcMNY );

    IntVMatr.SetSize( (SrcMNX-1)*CILIntMatrScale+1, (SrcMNY-1)*CILIntMatrScale+1 );

    IntVMatr.Resample( WrkVMatr, tdimSpline1 );
    WrkVMatr.Free;
  end; // else //*** Interpolation is needed


  //***** Set some default coords fields if needed

  with CILMatrRect do
  begin
    if Left = Right then // set full Index Coords
    begin
      Left  := 0;
      Right := IntVMatr.NX-1;
    end;

    if Top = Bottom then // set full Index Coords
    begin
      Top    := 0;
      Bottom := IntVMatr.NY-1;
    end;

    if ilfAutoArgFunc in CILFlags then // auto set Arg, Func Ranges
    begin
      if Left < Right then
      begin
        TDSArgMin  := Left;
        TDSArgMax  := Right;
      end else
      begin
        TDSArgMin  := Right;
        TDSArgMax  := Left;
      end;

      if Top < Bottom then
      begin
        TDSFuncMin := Top;
        TDSFuncMax := Bottom;
      end else
      begin
        TDSFuncMin := Bottom;
        TDSFuncMax := Top;
      end;
    end; // if ilfAutoArgFunc in CILFlags then // auto set Arg, Func Ranges
  end; // with CILMatrRect do


  //***** Create ULines1 (and UConts if needed) with IsoLine Coords

  ULines1 := TN_ULines.Create1( N_DoubleCoords, 'IsoLines1' ); // is needed for IzoConts and IsoLines
  DataDir.AddOneChildV( ULines1 );

  if IzoContsMode then // Create IzoContrours (not IsoLines)
  begin
    UConts := TN_UContours.Create();
    N_AddUChild( DataDir, UConts, 'IzoConts' );

    for i := 0 to CILMMValues.AHigh() do
    with TN_PMinMaxValues(CILMMValues.P(i))^ do
    begin
      IntVMatr.AddIzoCont( MMVMinValue, MMVMaxValue, ULines1, UConts );
    end; // for i := 0 to CILMMValues.AHigh() do
  end else //******************** Create IsoLines (not IzoContours)
  begin
    for i := 0 to CILMMValues.AHigh() do
    with TN_PMinMaxValues(CILMMValues.P(i))^ do
    begin
      IntVMatr.AddIsoLine( MMVMinValue, ULines1 );
    end; // for i := 0 to CILMMValues.AHigh() do
  end;


  //***** Set temporary C2DSpace Arg, Func ranges to Scaled index ranges and
  //      calculate AF2U6 coefs (from Index to User Coords Convertion Coefs)

  Saved2DS := C2DSpace; // save

  CompAFRect   := FRect( TDSArgMin, TDSFuncMin, TDSArgMax, TDSFuncMax );
  MatrIndsRect := FRect( 0, 0, IntVMatr.NX-1, IntVMatr.NY-1 );
  IndsAffCoefs := N_CalcAffCoefs4( CILMatrRect, MatrIndsRect );
  ResIndsRect  := N_AffConvF2FRect( CompAFRect, IndsAffCoefs );

  TDSArgMin  := ResIndsRect.Left;
  TDSArgMax  := ResIndsRect.Right;
  TDSFuncMin := ResIndsRect.Top;
  TDSFuncMax := ResIndsRect.Bottom;

  CalcCoefs6( True ); // used for IsoLine Scaled Index Coords to User Coords convertion


  //***** Spline ULines1 into ULines2 if needed

  if CILSplineLine.SLPType <> sltDoNotSpline then // Splining is needed
  begin
    SplineLineObj := TN_SplineLineObj.Create;
    SplineLineObj.PSplineParams := @CILSplineLine;
    ULines2 := TN_ULines.Create1( N_DoubleCoords, 'IsoLines2' );
    DataDir.AddOneChildV( ULines2 );

    ULines2.AddConvertedItems( ULines1, SplineLineObj.SplineLine );

    SplineLineObj.Free;
  end else //************************************** Splining is not needed
    ULines2 := ULines1;


  //***** Here: ULines2 is a separate UObj or just points to ULines1.
  //      Convert ULines2 from Index to User Coords and
  //      create MLIzo - MapLayer for IsoLines or IzoConts

  ULines2.AffConvSelf( AF2U6 );
  if UConts <> nil then  // replace ULines1 by ULines2 and Clear all "CoordsOK" flags
    UConts.SetSelfULines( ULines2 );

  if IzoContsMode then MLIzo := N_CreateUDMapLayer( UConts )
                  else MLIzo := N_CreateUDMapLayer( ULines2 );

  N_AddUChild( DataDir, MLIzo, 'MLIzo' );

  with MLIzo.PISP()^ do
  begin
    MLCAArray := CILAttribs.AAddRef();
    MLDrawMode := $00080; // User Coords, ShapeCoords Mode
  end; // with MLIzo.PISP()^ do


  //***** Create GridLines if needed

  if CILGridLinesML <> nil then // GridLines should be created
  begin
    GridLines := TN_ULines.Create1( N_FloatCoords, 'Grid Lines' );
    GridLines.AddGridSegments( FRect( 0, 0, IntVMatr.NX-1, IntVMatr.NY-1 ), DPoint(0,0), DPoint(1,1) );
    GridLines.AffConvSelf( AF2U6 );
    DataDir.AddOneChildV( GridLines );

    MLGridLines := TN_UDMapLayer(CILGridLinesML.Clone( True ));
    with MLGridLines.PISP()^ do
    begin
      K_SetUDRefField( TN_UDBase(MLCObj), GridLines );
    end;
    N_AddUChild( DataDir, MLGridLines, 'MLGridLines' );

  end; // if CILGridMapLayer <> nil then // GridLines should be created


  //***** Create Grid Node Labels if needed

  if CILGridLabelsML <> nil then // Grid Node Labels should be created
  begin                          // Create GridNodes, UDGridLabels, MLGridLabels

    GridNodes := TN_UDPoints.Create;
    GridNodes.AddGridNodes( FRect( 0, 0, IntVMatr.NX-1, IntVMatr.NY-1 ), DPoint(0,0), DPoint(1,1) );
    GridNodes.AffConvSelf( AF2U6 );
    N_AddUChild( DataDir, GridNodes, 'Grid Nodes' );

    UDGridLabels := K_CreateUDByRTypeName( 'String', IntVMatr.NXY );
  //  IntVMatr.CreateLabels( mlltInds, '%d,%d', PChar(UDGridLabels.PDE(0)) ); // fill UDGridLabels by Inds
  // UNICODE???
//    IntVMatr.CreateLabels( mlltValues, '%.2f', PChar(UDGridLabels.PDE(0)) ); // fill UDGridLabels by Values
    IntVMatr.CreateLabels( mlltValues, '%.2f', TN_BytesPtr(UDGridLabels.PDE(0)) ); // fill UDGridLabels by Values
    N_AddUChild( DataDir, UDGridLabels, 'Grid Labels' );

    MLGridLabels := TN_UDMapLayer(CILGridLabelsML.Clone( True ));
    with MLGridLabels.PISP()^ do
    begin
      K_SetUDRefField( TN_UDBase(MLCObj),   GridNodes );
      K_SetUDRefField( TN_UDBase(MLDVect1), UDGridLabels );
    end;
    N_AddUChild( DataDir, MLGridLabels, 'MLGridLabels' );

  end; // if CILLabelsMapLayer <> nil then // Node Labels should be created


  //***** Restore C2DSpace and related coefs

  C2DSpace := Saved2DS; // restore
  CalcCoefs6( True );

  end; // with PRI^, PRI^.C2DSpace, PRI^.CIsoLines do
end; // function TN_UDIsoLines.CreateVisRepr


//********** TN_UD2DLinHist class methods  **************

//********************************************** TN_UD2DLinHist.Create ***
//
constructor TN_UD2DLinHist.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UD2DLinHistCI;
  ImgInd := 56;
end; // end_of constructor TN_UD2DLinHist.Create

//********************************************* TN_UD2DLinHist.Destroy ***
//
destructor TN_UD2DLinHist.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UD2DLinHist.Destroy

//********************************************** TN_UD2DLinHist.PSP ***
// Return typed pointer to all Static Params
//
function TN_UD2DLinHist.PSP(): TN_PR2DLinHist;
begin
  Result := TN_PR2DLinHist(R.P());
end; // end_of function TN_UD2DLinHist.PSP

//********************************************** TN_UD2DLinHist.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UD2DLinHist.PDP(): TN_PR2DLinHist;
begin
  if DynPar <> nil then Result := TN_PR2DLinHist(DynPar.P())
                   else Result := TN_PR2DLinHist(R.P());
end; // end_of function TN_UD2DLinHist.PDP

//******************************************* TN_UD2DLinHist.PISP ***
// return typed pointer to Individual Static 2DLinHist Params
//
function TN_UD2DLinHist.PISP(): TN_PC2DLinHist;
begin
  Result := @(TN_PR2DLinHist(R.P())^.C2DLinHist);
end; // function TN_UD2DLinHist.PISP

//******************************************* TN_UD2DLinHist.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic 2DLinHist Params
// otherwise return typed pointer to Individual Static 2DLinHist Params
//
function TN_UD2DLinHist.PIDP(): TN_PC2DLinHist;
begin
  if DynPar <> nil then
    Result := @(TN_PR2DLinHist(DynPar.P())^.C2DLinHist)
  else
    Result := @(TN_PR2DLinHist(R.P())^.C2DLinHist);
end; // function TN_UD2DLinHist.PIDP

//*********************************************** TN_UD2DLinHist.PascalInit ***
// Init self
//
procedure TN_UD2DLinHist.PascalInit();
begin
  Inherited; // Init C2DSpace

  with PISP()^ do
  begin
    LHMainStyles.ASetLength( 1 );
  end; // with PISP()^ do
end; // procedure TN_UD2DLinHist.PascalInit

type TN_StyleToken = record // one parsed Style Token
  STPahse: integer; // Style Token Pahse
  STIndex: integer; // Style Token Index
end; // type TN_StyleToken = record
type TN_StyleTokens = Array of TN_StyleToken;

//********************************************* TN_UD2DLinHist.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UD2DLinHist.BeforeAction();
var
  i, j, RetCode, NumStyles, NumStyleElems, DefColor: integer;
  ind, ig, ie, ColArgBeg, ColArgEnd, FullPixWidth: integer;
  NX, NY, NumGroups, NumElems: integer;
  CurFunc, BegFunc, Normalizer, MinFunc, MaxFunc: double;
  Str, StyleToken: string;
  ItemDRect, CurDRect: TDRect;
  GroupsCoords, ColumnsCoords: TN_IPArray;
  ParsedStyles: Array of TN_StyleTokens;
  PRCompD: TN_PR2DLinHist;

  procedure OldDrawElemRect( const ADRect: TDRect; AGroupInd, AElemInd, AColorInd: integer );
  // Draw and Mark Element (Column or Item) Rect (local)
  var
    MainColorInd, MarkIndsInd, MarkStyleInd, CurInd: integer;
    PMainColor: PInteger;
    ItemPixRect, BackPixRect: TRect;
    MainStyle, MarkStyle, FinalStyle: TN_C2DLHStyle; // LHValStyle,
    PCurStyle: TN_PC2DLHStyle;
    ParentComp: TN_UDCompBase;
  begin
    with PRCompD^, PRCompD^.C2DLinHist do
    begin
      if not (lhfOldParams in LHFlags) then Exit;

      case LHColorMode of // how to interpret given LHFillColors
                          // ig=AGroupInd=iy, ie=AElemInd=ix
        lhcmGroups: MainColorInd := AGroupInd; // one Color (for all Elems in Group) per each Group
        lhcmValues: MainColorInd := AColorInd; // one Color per each Value
      else
        MainColorInd := AElemInd; // one Color per each Column in Group
      end; // case LHColorMode of // how to interpret given LHFillColors

      PMainColor := LHFillColors.PS( MainColorInd );
      if PMainColor = nil then
        PMainColor := @N_ClGreenGray; // Default Fill Color

      ItemPixRect := N_AffConv6D2IRect( ADRect, AF2P6 ); // used later

      //***** Set MainStyle
      MainStyle := N_DefC2DLHStyle;
      PCurStyle := TN_PC2DLHStyle(LHMainStyles.P());
      if PCurStyle <> nil then MainStyle := PCurStyle^;

      //***** Set ValStyle
      //***** Using ValStyle temporary not implemented

      //***** Set MarkStyle
      MarkStyleInd := 0;
      if (LHMarkStyles.ALength() > 0) and (LHMarkStyleInds.ALength() > 0) then
      begin
        case LHMarkMode of // Calc MarkIndsInd
          lhmmGElems: MarkIndsInd := AElemInd;
          lhmmGroups: MarkIndsInd := AGroupInd;
          lhmmValues: MarkIndsInd := AElemInd + NX*AGroupInd; // ig=AGroupInd=iy, ie=AElemInd=ix
        else
          MarkIndsInd := -1;
        end; // case LHMarkMode of

        if (MarkIndsInd <= LHMarkStyleInds.AHigh()) and (MarkIndsInd <> -1) then
        begin
          MarkStyleInd := PByte(LHMarkStyleInds.P(MarkIndsInd))^;

          if MarkStyleInd >= 1 then // MarkStyle exists
          begin
            CurInd := (MarkStyleInd - 1) mod LHMarkStyles.Alength();
            MarkStyle := TN_PC2DLHStyle(LHMarkStyles.P(CurInd))^;

            //***** LHMarkStyle is OK, Calc BackPixRect and draw CPanel

            //***** Set BackPixRect by needed Scope Rect and ItemPixRect

            BackPixRect := CompIntPixRect;
            ParentComp := Self.DynParent;
            if (([lhsfParent,lhsfGrandParent] * MarkStyle.LHSFlags) <> []) and
               (ParentComp is TN_UDCompVis) then // use Parent Scope
            begin
              BackPixRect := TN_UDCompVis(ParentComp).CompIntPixRect;
              ParentComp := ParentComp.DynParent;

              if (lhsfGrandParent in MarkStyle.LHSFlags) and
                 (ParentComp is TN_UDCompVis) then
                BackPixRect := TN_UDCompVis(ParentComp).CompIntPixRect;
            end; // if ... then // use Parent Scope

            if C2DSpace.TDSArgAxisPos = tdsVertical then // Argument Axis is Vertical
            begin
              BackPixRect.Top    := ItemPixRect.Top;
              BackPixRect.Bottom := ItemPixRect.Bottom;
            end else // Argument Axis is Horizontal
            begin
              BackPixRect.Left  := ItemPixRect.Left;
              BackPixRect.Right := ItemPixRect.Right;
            end;

            //***** Update BackPixRect by LHSAddMarkRect and Draw CPanel
            BackPixRect := NGCont.DstOCanv.ShiftPixRectByLSURect(
                                        BackPixRect, MarkStyle.LHSAddMarkRect );

            NGCont.DrawCPanel( MarkStyle.LHSMarkPanel, BackPixRect );

          end; // if MarkStyleInd >= 1 then // MarkStyle exists
        end; // if (MarkIndsInd <= LHMarkStyleInds.AHigh()) and (MarkIndsInd <> -1) then
      end; // if (LHMarkStyles.ALength() > 0) and (LHMarkStyleInds.ALength() > 0) then

      //***** LHStyle is OK, Draw Background Panel (if needed) and Element Rect

      FinalStyle := MainStyle; // temporary!

      if MarkStyleInd <> 0 then // update some Attribs if needed
      begin
        if LHColorMode <> lhcmValues then
          if MarkStyle.LHSFillColor <> N_EmptyColor then
            PMainColor := @MarkStyle.LHSFillColor;
      end; // if MarkStyleInd <> 0 then // update some Attribs if needed

      NGCont.DrawPixRoundRect( ItemPixRect, Point(0,0), PMainColor^,
                           FinalStyle.LHSBorderColor, FinalStyle.LHSBorderWidth );
    end; // with PRCompD^, PRCompD^.C2DLinHist do
  end; // procedure OldDrawElemRect - local

  procedure DrawRectByStyle( APRect: PFRect; AStyleInd: integer; APhase: integer );
  // Draw given APRect using DefColor and given AStyleInd in given APhase
  var
    i: integer;
    CurRect: TRect;
    CompPixRect: TRect;
    ParentComp: TN_UDCompBase;
  begin
  with PRCompD^.C2DLinHist do
  begin
    if (AStyleInd < 0) or (AStyleInd >= NumStyles) then Exit;

    for i := 0 to High(ParsedStyles[AStyleInd]) do // Along Style Elements
    with ParsedStyles[AStyleInd,i] do
    begin
      if STPahse <> APhase then Continue; // Skip wrong Phase

      if (STIndex < 0) or (STIndex >= NumStyleElems) then Exit;

      with TN_PC2DLHStyleElem(LHStyleElems.P(STIndex))^ do
      begin

        //***** Update APRect according to LHSRectType

        if LHSERectType = lhrtSkipRect then Continue // Skip Rect
        else if LHSERectType = lhrtElemRect then  // Element or whole Group Rect
          CurRect := IRect( APRect^ )
        else // update APRect^ by Self, Parent or GrandParent CompIntPixRect
        begin
          CurRect := IRect( APRect^ ); // prelimenary value

          //*** Calc CompPixRect for Self, Parent or GrandParent

          CompPixRect := CompIntPixRect;
          ParentComp := Self.DynParent;
          if ((LHSERectType = lhrtParent) or (LHSERectType = lhrtGrandParent)) and
             (ParentComp is TN_UDCompVis) then // use Parent Scope
          begin
            CompPixRect := TN_UDCompVis(ParentComp).CompIntPixRect;
            ParentComp := ParentComp.DynParent;

            if (LHSERectType = lhrtGrandParent) and
               (ParentComp is TN_UDCompVis) then
              CompPixRect := TN_UDCompVis(ParentComp).CompIntPixRect;
          end; // if ... then // use Parent Scope

          //***** CompPixRect is OK, update CurRect by it

          if PRCompD^.C2DSpace.TDSArgAxisPos = tdsVertical then // Argument Axis is Vertical
          begin
            CurRect.Left  := CompPixRect.Left;
            CurRect.Right := CompPixRect.Right;
          end else // Argument Axis is Horizontal
          begin
            CurRect.Top    := CompPixRect.Top;
            CurRect.Bottom := CompPixRect.Bottom;
          end; // else // Argument Axis is Horizontal

        end; // else // update APRect^ by Self, Parent or GrandParent CompIntPixRect

        //**** CurRect is OK, Draw it

        if DefColor = N_CurColor then DefColor := N_ClLtGray;

        NGCont.DrawCPanel( @LHSEPanel, CurRect, DefColor );

      end; // with TN_PC2DLHStyleElem(LHStyleElems.P(STIndex))^ do
    end; // for i := 0 to High(ParsedStyles[StyleInd]) do // Along Style Elements

  end; // with PRCompD^.C2DLinHist do
  end; // procedure procedure DrawRectByStyle - local

  procedure DrawGroupRect( APhase: integer );
  // Draw whole Group Rect (LHPixGroupRects[ig]) in given APhase
  var
    PStyleInd: PInteger;
  begin
  with PRCompD^.C2DLinHist do
  begin
    DefColor := N_CurColor;
    if (LHExtColorMode = lhecmGroups) and (LHExtColors.ALength() >= 1)  then
      DefColor := PInteger(LHExtColors.PS(ig))^;

    PStyleInd := LHGRectStyleInds.PS( ig );
    if PStyleInd = nil then Exit;

    DrawRectByStyle( @LHPixGroupRects[ig], PStyleInd^, APhase );
  end; // with PRCompD^.C2DLinHist do
  end; // procedure DrawGroupRect - local

  procedure DrawElemRect( APhase: integer );
  // Draw Elem Rect ( LHPixElemRects[ind] ) in given APhase
  // using Group, Elem in Group and Value Styles
  var
    PStyleInd: PByte;
  begin
  with PRCompD^.C2DLinHist do
    begin
      if (lhfOldParams in LHFlags) then Exit;

      PStyleInd := LHGroupStyleInds.PS( ig ); // Pointer to Group Style index
      if PStyleInd <> nil then
      begin
        DefColor := N_CurColor;
        if (LHExtColorMode = lhecmGroups) and (LHExtColors.ALength() >= 1) then
          DefColor := PInteger(LHExtColors.PS(ig))^;

        DrawRectByStyle( @LHPixElemRects[ind], PStyleInd^, APhase );
      end; // Group Style

      PStyleInd := LHElemStyleInds.PS( ie ); // Pointer to Elem in Group Style index
      if PStyleInd <> nil then
      begin
        DefColor := N_CurColor;
        if (LHExtColorMode = lhecmGElems) and (LHExtColors.ALength() >= 1) then
          DefColor := PInteger(LHExtColors.PS(ie))^;

        DrawRectByStyle( @LHPixElemRects[ind], PStyleInd^, APhase );
      end; // Elem in Group Style

      PStyleInd := LHValueStyleInds.PS( ind ); // Pointer to Value Style index
      if PStyleInd <> nil then
      begin
        DefColor := N_CurColor;
        if (LHExtColorMode = lhecmValues) and (LHExtColors.ALength() >= 1) then
          DefColor := PInteger(LHExtColors.PS(ind))^;

        DrawRectByStyle( @LHPixElemRects[ind], PStyleInd^, APhase );
      end; // Value Style
    end; // with PRCompD^.C2DLinHist do
  end; // procedure DrawElemRect - local

begin //**************** main body of TN_UD2DLinHist.BeforeAction
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with PRCompD^, PRCompD^.C2DSpace, PRCompD^.C2DLinHist, PCCD()^ do
  begin
    //***** Parse Style Tokens

    NumStyles := LHStyles.ALength();
    NumStyleElems := LHStyleElems.ALength();

    SetLength( ParsedStyles, NumStyles );

    for i := 0 to High(ParsedStyles) do // Convert Styles Strings to Array of StyleTokens
    begin
      SetLength( ParsedStyles[i], 20 ); // max possible value
      Str := UpperCase(PString(LHStyles.P(i))^);

      j := 0;
      while True do // Parse all Tokens in Str and convert them to elements of ParsedStyles[i] Array
      begin
        StyleToken := N_ScanToken( Str );
        if StyleToken = '' then Break; // end of Tokens

        ParsedStyles[i,j].STPahse := integer(StyleToken[1]) - integer('A');
        Val( StyleToken[2], ParsedStyles[i,j].STIndex, RetCode );
        Inc( j );
      end; // while True do

      SetLength( ParsedStyles[i], j ); // final value
    end; // for i := 0 to High(ParsedStyles) do // Convert Styles Strings to Array of StyleTokens

    //*** Relative Pixels Coords along LinHist width are used as Argument values
    //    in terms of 2DSpace Object

    if TDSArgAxisPos = tdsHorizontal then
      FullPixWidth := N_RectWidth( CompIntPixRect )
    else
      FullPixWidth := N_RectHeight( CompIntPixRect );

    TDSArgMin := 0;
    TDSArgMax := FullPixWidth -1;
    CalcCoefs6();

    with NGCont, NGCont.DstOCanv do
    begin

    LHValues.ALength( NX, NY ); // Get NX, NY
    if NY = 0 then Exit; // Values are not given

    //***** Group is a series of Columns or one Stacked Column
    //      Elements in a Group are called Elems, Elemes are Columns or Rects in Stacked Column

    if lhfGroupsAlongX in LHFlags then
    begin
      NumGroups := NX;
      NumElems  := NY;
    end else // Groups Along Y
    begin
      NumGroups := NY;
      NumElems  := NX;
    end;

    SetLength( LHPixGroupRects,  NumGroups );  // Groups Rects coords in float Pixel
    SetLength( LHPixElemRects, NumElems*NumGroups ); // Elems Rects coords in float Pixel

    // Calc GroupsCoords along Arg Axis
    CalcODFSCoords( NumGroups, FullPixWidth, @LHGroupsLP, GroupsCoords );

    //*** ig - Group index

    for ig := 0 to NumGroups-1 do // Along all Groups
    begin
    CurDRect := DRect( GroupsCoords[ig].X, TDSFuncMin, GroupsCoords[ig].Y, TDSFuncMax );
    LHPixGroupRects[ig] := FRect(N_AffConv6D2DRect( CurDRect, AF2P6 )); // Groups' Rect

    DrawGroupRect( 0 ); // Draw Group Rect in Phase A(0)

    if lhfStackedColumns in LHFlags then // Groups are Stacked Columns, NumElems in each Stacked Column
    begin
      Normalizer := 1.0; // for calculating relative Item's values

      if lhfRelItems in LHFlags then // use relative Item's values
      begin
        Normalizer := 0;
        for ie := 0 to NumElems-1 do // along all Elems in Column
        begin
          if lhfGroupsAlongX in LHFlags then
            Normalizer := Normalizer + N_MatrElem( LHValues, ig, ie )
          else
            Normalizer := Normalizer + N_MatrElem( LHValues, ie, ig );
        end;

        Normalizer := 0.01 * Normalizer; // ItemValue/Normalizer would be in (0 - 100) range
      end; // if lhfRelItems in LHFlags then // use relative Item's values

      if Normalizer = 0 then Normalizer := 1.0; // if all values = 0
      BegFunc := LHFuncBase;

      //*** ie - Element (Column or Item) index (Matr Values Column index)

      for ie := 0 to NumElems-1 do // Along all current Group(=Column)'s Elems
      begin
        if lhfGroupsAlongX in LHFlags then
        begin
          CurFunc := N_MatrElem( LHValues, ig, ie ) / Normalizer;
          ind := ig + NumGroups*ie;
        end else
        begin
          CurFunc := N_MatrElem( LHValues, ie, ig ) / Normalizer;
          ind := ie + NumElems*ig;
        end;

        MinFunc := BegFunc;
        MaxFunc := BegFunc + CurFunc;

        if (MaxFunc < TDSFuncMin) or (MinFunc > TDSFuncMax) then // Rect out of LinHist Rect, skip drawing
        begin
          LHPixElemRects[ind] := N_NoFRect;
          BegFunc := BegFunc + CurFunc;
          Continue;
        end; // if (MaxFunc < TDSFuncMin) or (MinFunc > TDSFuncMax) then // skip drawing

        MinFunc := Max( MinFunc, TDSFuncMin );
        MaxFunc := Min( MaxFunc, TDSFuncMax );

        ItemDRect := DRect( GroupsCoords[ig].X, MinFunc, GroupsCoords[ig].Y, MaxFunc );

        OldDrawElemRect( ItemDRect, ig, ie, ind ); // Old Var!!!

        N_AC6 := AF2P6;
        LHPixElemRects[ind] := FRect(N_AffConv6D2DRect( ItemDRect, AF2P6 )); // Items' Rect

        DrawElemRect( 1 );  // Draw Elem Rect in Phase B(1)
        DrawElemRect( 2 );  // Draw Elem Rect in Phase C(2)
        DrawElemRect( 3 );  // Draw Elem Rect in Phase D(3)

        BegFunc := BegFunc + CurFunc;
      end; // for ie := 0 to NumElems-1 do // Along all current Group(=Column)'s Items

    end else //*** NOT Stacked Columns: One Elem in Column, NumElems Columns in Group
    begin
      CalcODFSCoords( NumElems, //***** Calc ColumnsCoords along Arg Axis
         GroupsCoords[ig].Y-GroupsCoords[ig].X+1, @LHColumnsLP, ColumnsCoords );

      for ie := 0 to NumElems-1 do // Loop along all Elemets (Columns)
      begin
        if lhfGroupsAlongX in LHFlags then
        begin
          CurFunc := N_MatrElem( LHValues, ig, ie );
          ind := ig + NumGroups*ie;
        end else
        begin
          CurFunc := N_MatrElem( LHValues, ie, ig );
          ind := ie + NumElems*ig;
        end;

        if lhfGroupsAlongX in LHFlags then
          ind := ig + NumGroups*ie
        else
          ind := ie + NumElems*ig;

        ColArgBeg := GroupsCoords[ig].X + ColumnsCoords[ie].X;
        ColArgEnd := GroupsCoords[ig].X + ColumnsCoords[ie].Y;

//        CurFunc   := N_MatrElem( LHValues, ie, ig );

        MinFunc := LHFuncBase;
        MaxFunc := CurFunc;

        if MinFunc > MaxFunc then
        begin
          MinFunc := CurFunc;
          MaxFunc := LHFuncBase;
        end;

        if (MaxFunc < TDSFuncMin) or (MinFunc > TDSFuncMax) then // Rect out of LinHist Rect, skip drawing
        begin
          LHPixElemRects[ind] := N_NoFRect;
          Continue;
        end; // if (MaxFunc < TDSFuncMin) or (MinFunc > TDSFuncMax) then // skip drawing

        MinFunc := Max( MinFunc, TDSFuncMin );
        MaxFunc := Min( MaxFunc, TDSFuncMax );

//        ItemDRect := DRect( GroupsCoords[ig].X, MinFunc, GroupsCoords[ig].Y, MaxFunc );
        ItemDRect := DRect( ColArgBeg, MinFunc, ColArgEnd, MaxFunc );

        OldDrawElemRect( ItemDRect, ig, ie, ind ); // Old Var!!!

        LHPixElemRects[ind] := FRect(N_AffConv6D2DRect( ItemDRect, AF2P6 )); // Items' Rect

        DrawElemRect( 1 );  // Draw Elem Rect in Phase B(1)
        DrawElemRect( 2 );  // Draw Elem Rect in Phase C(2)
        DrawElemRect( 3 );  // Draw Elem Rect in Phase D(3)
      end; // for ie := 0 to NumColumns-1 do // Loop along all Columns
    end; // else //*** NOT Stacked Columns

    DrawGroupRect( 4 ); // Draw Group Rect in Phase E(4)

    end; // for ig := 0 to NumGroups-1 do // Along all Groups
    end; // with NGCont, NGCont.DstOCanv do
  end; // PRCompD^, PRCompD^.C2DLinHist, PCCD()^ do

end; // end_of procedure TN_UD2DLinHist.BeforeAction


//********** TN_UDLinHistAuto1 class methods  **************

//************************************************ TN_UDLinHistAuto1.Create ***
//
constructor TN_UDLinHistAuto1.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDLinHistAuto1CI;
  ImgInd := 101;
end; // end_of constructor TN_UDLinHistAuto1.Create

//*********************************************** TN_UDLinHistAuto1.Destroy ***
//
destructor TN_UDLinHistAuto1.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDLinHistAuto1.Destroy

//*************************************************** TN_UDLinHistAuto1.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDLinHistAuto1.PSP(): TN_PRLinHistAuto1;
begin
  Result := TN_PRLinHistAuto1(R.P());
end; // end_of function TN_UDLinHistAuto1.PSP

//*************************************************** TN_UDLinHistAuto1.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDLinHistAuto1.PDP(): TN_PRLinHistAuto1;
begin
  if DynPar <> nil then Result := TN_PRLinHistAuto1(DynPar.P())
                   else Result := TN_PRLinHistAuto1(R.P());
end; // end_of function TN_UDLinHistAuto1.PDP

//************************************************** TN_UDLinHistAuto1.PISP ***
// return typed pointer to Individual Static LinHistAuto1 Params
//
function TN_UDLinHistAuto1.PISP(): TN_PCLinHistAuto1;
begin
  Result := @(TN_PRLinHistAuto1(R.P())^.CLinHistAuto1);
end; // function TN_UDLinHistAuto1.PISP

//************************************************** TN_UDLinHistAuto1.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic LinHistAuto1 Params
// otherwise return typed pointer to Individual Static LinHistAuto1 Params
//
function TN_UDLinHistAuto1.PIDP(): TN_PCLinHistAuto1;
begin
  if DynPar <> nil then
    Result := @(TN_PRLinHistAuto1(DynPar.P())^.CLinHistAuto1)
  else
    Result := @(TN_PRLinHistAuto1(R.P())^.CLinHistAuto1);
end; // function TN_UDLinHistAuto1.PIDP

//******************************************** TN_UDLinHistAuto1.PascalInit ***
// Init self
//
procedure TN_UDLinHistAuto1.PascalInit();
begin
  Inherited;
end; // procedure TN_UDLinHistAuto1.PascalInit

type TN_LHAWrkParams = record // for passing params calculated in PrepRootComp to BeforeAction
  WPMainHeadermmHeight:   float; // =0 if should not be drawn
  WPBlockHeadermmHeight:  float; // =0 if should not be drawn
  WPElemsNamesmmWidth:    float; // =0 if should not be drawn
  WPValTextsmmWidth:      float; // =0 if should not be drawn
  WPAddOfsXmm:            float; // additinal X - offset for horizontal alignment

  WPBlockmmSize:          TFPoint;
  WPPatLHmmSize:          TFPoint;
  WPMatrixColors:         boolean;
  WPElNamesInBlocks:      boolean;
  WPUserColorsGiven:      boolean;
  WPErrorInPrepRoot:      boolean;

  WPNumGroups:            integer; // Number of Columns in WPRVals values Matrix (NX)
  WPNumElemsInGroup:      integer; // Number of Rows in WPRVals values Matrix (NY)
  WPNumBlocks:            integer; // =1 for Stacked Hist, =WPNumGroups for Simple Hist
  WPNumColsInBlock:       integer; // Number of Columns(Rects) for both Simple and Stacked Histogramms
  WPNumBlockRows:         integer;
  WPNumBlocksInRow:       integer;

  WPRVals:                TK_RArray;
  WPRColors:              TK_RArray;
  WPRElNames:             TK_RArray;
  WPRBlockNames:          TK_RArray;
  WPRValTexts:            TK_RArray;
  WPRFuncsTicks:          TK_RArray;
end; // type TN_LHAWrkParams = record
type TN_PLHAWrkParams = ^TN_LHAWrkParams;

//****************************************** TN_UDLinHistAuto1.PrepRootComp ***
// Prepare Self as Root component
//
// Calclate Self Size in mm and save in TN_PLHAWrkParams(@UDLHAWrkParams[0])^
// some wrk values, used in BeaforeAction method
//
// Temporary not implemented:
// - individual Elemes Names inside Blocks
// - Horizontal Blocks alignment
// - Vertical Blocks alignment
// - Vertical Elemes Names and Values (for vertical columns)
// - Axises in Blocks
// - Show Value by MouseMove for Column under cursor
//
procedure TN_UDLinHistAuto1.PrepRootComp();
var
  MaxBlocksInRow, tmpNX, tmpNY: integer;
  FreeSizeX, AcrosmmSize, BegPadding, EndPadding: float;
  SelfRealSize: TFPoint;
  PODFSParams: TN_PODFSParams;
  PRCompD: TN_PRLinHistAuto1;

//     Local Procedures:
//  procedure PrepareComp ( AComp: TN_UDBase );
//  function GetmmSWidth  ( AComp: TN_UDBase ): float;
//  function GetmmSHeight ( AComp: TN_UDBase ): float;

  procedure AddError( AErrStr: string );
  // Set Error string to N_LinHistAuto Protocol channel
  begin
    TN_PLHAWrkParams(@UDLHAWrkParams[0])^.WPErrorInPrepRoot := True;
    N_LCAddErr( N_LinHistAuto, AErrStr );
  end; // procedure AddError - local

  procedure PrepareComp( AComp: TN_UDBase );
  // Prepare given AComp for calling BeforeAction or ExecSubTree method
  begin
    if AComp = nil then Exit;

    with TN_UDCompBase(AComp) do
    begin
      PrepRootComp();
      CRTFlags := []; // clear crtfRootComp flag set in PrepRootComp

      ExecSetParams( sppBBAction );
      DynParent := Self;
    end;
  end; // procedure PrepareComp - local

  function GetmmSWidth( AComp: TN_UDBase ): float;
  // Get Given Component Width in mm from Static SRSize.X
  begin
    Result := 0.1; // error

    with TN_UDCompVis(AComp).PCCS()^ do
    begin
      if SRSizeXType <> cstmm then
        AddError( 'Bad X Size in ' + AComp.ObjName )
      else
        Result := SRSize.X;
    end;
  end; // function GetmmSWidth - local

  function GetmmSHeight( AComp: TN_UDBase ): float;
  // Get Given Component Height in mm from Static SRSize.Y
  begin
    Result := 0.1; // error

    with TN_UDCompVis(AComp).PCCS()^ do
    begin
      if SRSizeYType <> cstmm then
        AddError( 'Bad Y Size in ' + AComp.ObjName )
      else
        Result := SRSize.Y;
    end;
  end; // function GetmmSHeight - local


begin //*********************** main body of TN_UDLinHistAuto1.PrepRootComp
  inherited;
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  SetLength( UDLHAWrkParams, SizeOf(TN_LHAWrkParams) );
  PRCompD := PDP();
  N_LCClearErr( N_LinHistAuto, '' );

  with PRCompD^.CLinHistAuto1, TN_PLHAWrkParams(@UDLHAWrkParams[0])^ do
  begin

    //*** Check Self Components presense
    if LHAMainHeader  = nil then LHAFlags := LHAFlags + [lhafSkipMainHeader];
    if LHABlockHeader = nil then LHAFlags := LHAFlags + [lhafSkipBlockHeaders];
    if LHAElemsNames  = nil then LHAFlags := LHAFlags + [lhafSkipElemsNames];
    if LHAFuncsTicks  = nil then LHAFlags := LHAFlags + [lhafSkipFuncsTicks];
    if LHALegend      = nil then LHAFlags := LHAFlags + [lhafSkipLegend];


    if not (LHAUserParams is TN_UDCompBase) then //*********** Check UserParams
    begin
      AddError( 'Bad LHAUserParams' );
      Exit;
    end; // UserParams

    //***** Set WPR... RArrays by RAyyaray in UserPar
    //      (WPRVals, WPRColors, WPRElNames, WPRBlockNames, WPRValTexts, WPRFuncsTicks)


    //***** Set WPRVals, WPNumGroups, WPNumElemsInGroup by 'Values' UserPar

    WPRVals := TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'Values' ); // WPRVals
    if WPRVals <> nil then
    begin
      WPRVals.ALength( WPNumGroups, WPNumElemsInGroup );

      if (WPNumGroups < 1) or (WPNumElemsInGroup < 1) then
      begin
        AddError( 'No Data in Values UPar' );
        Exit;
      end;
    end; // WPRVals


    //***** Set WPRColors, WPUserColorsGiven, WPMatrixColors by 'Colors' UserPar

    WPRColors := TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'Colors' );
    WPRColors.ALength( tmpNX, tmpNY );
    WPMatrixColors := (tmpNX > 1);

    if tmpNY <= 0 then
      WPUserColorsGiven := False
    else // tmpNY >= 1
    begin
      if tmpNX = 1 then
      begin
        if tmpNY < WPNumElemsInGroup then
        begin
          AddError( 'Bad Colors dimensions1' );
          Exit;
        end;
      end else // tmpNX > 1
      begin
        if (tmpNX <> WPNumGroups) or (tmpNY <> WPNumElemsInGroup) then
        begin
          AddError( 'Bad Colors dimensions2' );
          Exit;
        end;
      end;
      WPUserColorsGiven := True;
    end; // else // tmpNY >= 1


    //***** Set WPRElNames, WPElNamesInBlocks by 'LHRowNames' UserPar

    WPRElNames := TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'LHRowNames' );
    WPRElNames.ALength( tmpNX, tmpNY );
    WPElNamesInBlocks := (tmpNX > 1);

    if tmpNY <= 0 then
      LHAFlags := LHAFlags + [lhafSkipElemsNames]
    else // tmpNY >= 1
    begin
      if tmpNY <> WPNumElemsInGroup then
      begin
        AddError( 'Bad LHRowNames dimensions' );
        Exit;
      end;
    end; // else // tmpNY >= 1


    //***** Set WPRBlockNames by 'LHColNames' UserPar

    WPRBlockNames := TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'LHColNames' );
    WPRBlockNames.ALength( tmpNX, tmpNY );

    if tmpNY <= 0 then
      LHAFlags := LHAFlags + [lhafSkipBlockHeaders]
    else // tmpNY >= 1
    begin
      if (tmpNX <> 1) or (tmpNY < WPNumGroups) then
      begin
        AddError( 'Bad LHColNames dimensions' );
        Exit;
      end;
    end; // else // tmpNY >= 1


    //***** Set WPRValTexts by 'ValTexts' UserPar

    WPRValTexts   := TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'ValTexts' );
    WPRValTexts.ALength( tmpNX, tmpNY );

    if tmpNY <= 0 then
      LHAFlags := LHAFlags + [lhafSkipValTexts]
    else // tmpNY >= 1
    begin
      if (tmpNX <> WPNumGroups) or (tmpNY <> WPNumElemsInGroup) then
      begin
        AddError( 'Bad ValTexts dimensions' );
        Exit;
      end;
    end; // else // tmpNY >= 1


    //***** Set WPRFuncsTicks by 'FuncsTicks' UserPar

    WPRFuncsTicks := TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'FuncsTicks' );
    WPRFuncsTicks.ALength( tmpNX, tmpNY );

    if tmpNY <= 0 then
      LHAFlags := LHAFlags + [lhafSkipFuncsTicks]
    else // tmpNY >= 1
    begin
      if (tmpNX > 1) and (tmpNX <> WPNumGroups) then
      begin
        AddError( 'Bad FuncsTicks dimensions' );
        Exit;
      end;
    end; // else // tmpNY >= 1


    //***** Calc WPNumColsInBlock
    if LHAType = lhatSimple then //*** Several Blocks with Simple Histogramm
      WPNumColsInBlock := WPNumElemsInGroup
    else //******** LHAType = lhatStacked, One Block with Stacked Histogramm
      WPNumColsInBlock := WPNumGroups;


    //***** Check all UDBase in Self Individual Params and prepare some of them

    if lhafSkipMainHeader in LHAFlags then //******************* Main Header
    begin
      WPMainHeadermmHeight := 0;
    end else
    begin
      if not (LHAMainHeader is TN_UDParaBox) then
      begin
        AddError( 'Bad LHAMainHeader' );
        Exit;
      end else
      begin
        WPMainHeadermmHeight := GetmmSHeight( LHAMainHeader );
        PrepareComp( LHAMainHeader );
      end;
    end; // Main Header


    if (lhafSkipBlockHeaders in LHAFlags) or //****************** Block Header
       (LHAType = lhatStacked) then
    begin
      WPBlockHeadermmHeight := 0;
    end else
    begin
      if not (LHABlockHeader is TN_UDParaBox) then
      begin
        AddError( 'Bad LHABlockHeader' );
        Exit;
      end else
      begin
        WPBlockHeadermmHeight := GetmmSHeight( LHABlockHeader );
        PrepareComp( LHABlockHeader );
      end;
    end; // Block Header


    if (lhafSkipElemsNames in LHAFlags) or //******************* Elems Names
       (LHAOrient = lhaoVertCol) then
    begin
      WPElemsNamesmmWidth := 0;
    end else
    begin
      if not (LHAElemsNames is TN_UDTextMarks) then
      begin
        AddError( 'Bad LHAElemsNames' );
        Exit;
      end else
      begin
        WPElemsNamesmmWidth := LHAElemsNamesWidth;
        PrepareComp( LHAElemsNames );
      end;
    end; // Elems Names


    if (lhafSkipValTexts in LHAFlags) or //********************* Val Texts
       (LHAOrient = lhaoVertCol) then
    begin
      WPValTextsmmWidth := 0;
    end else
    begin
      if not (LHAValTexts is TN_UDTextMarks) then
      begin
        AddError( 'Bad LHAValTexts' );
        Exit;
      end else
      begin
        WPValTextsmmWidth := LHAValTextsWidth;
        PrepareComp( LHAValTexts );
      end;
    end; // Val Texts


    if not (lhafSkipFuncsTicks in LHAFlags) then //************* Funcs Ticks
    begin
      if not (LHAFuncsTicks is TN_UDAxisTics) then
      begin
        AddError( 'Bad LHAFuncsTicks' );
        Exit;
      end; // Funcs Ticks

      PrepareComp( LHAFuncsTicks );

      //***** Prepare LHAFuncsTicks.ATBaseZs RArray Length by WPRFuncsTicks size

      WPRFuncsTicks.ALength( tmpNX, tmpNY );

      with TN_UDAxisTics(LHAFuncsTicks) do
      with PIDP()^ do
      begin
        if ATBaseZs = nil then
          ATBaseZs := K_RCreateByTypeCode( Ord(nptDouble), tmpNY )
        else
          ATBaseZs.ASetLength( tmpNY );
      end;
    end; // Funcs Ticks


    if not (lhafSkipLegend in LHAFlags) then //***************** Legend
    begin
      if not (LHALegend is TN_UDLegend) then
      begin
        AddError( 'Bad LHALegend' );
        Exit;
      end;
    end; // Legend
    PrepareComp( LHALegend );


    if not (LHAPatLinHist is TN_UD2DLinHist) then //************ PatLinHist
    begin
      AddError( 'Bad LHAPatLinHist' );
      Exit;
    end else
    begin
      PrepareComp( LHAPatLinHist );

      //***** Set Columns Layout Params and Orientation in LHAPatLinHist,
      //      calc WPPatLHmmSize

      with TN_UD2DLinHist(LHAPatLinHist) do
      with PIDP()^ do
      begin
        //***** Set LHAPatLinHist Flags

        if LHAType = lhatStacked then
        begin
          LHFlags := [lhfStackedColumns, lhfGroupsAlongX, lhfOldParams];
          PODFSParams := @LHGroupsLP;
        end else // LHAType = lhatSimple
        begin
          LHFlags := [lhfGroupsAlongX, lhfOldParams];
          PODFSParams := @LHColumnsLP;
        end;

        if WPMatrixColors then
          LHExtColorMode := lhecmValues
        else
          LHExtColorMode := lhecmGElems;

        byte(LHColorMode) := byte(LHExtColorMode);

        //***** Set WPPatLHmmSize and LHAPatLinHist Columns Layout Params

        WPPatLHmmSize := LHAPatLHSize; // prelimenary value


        with PODFSParams^ do
        begin
          if LHAElemsFixedSize > 0 then //***** Elems Fixed Size is given
          begin
            BegPadding := ODFLRPaddings.MSPValue.X;
            EndPadding := ODFLRPaddings.MSPValue.Y;
            AcrosmmSize := WPNumColsInBlock * LHAElemsFixedSize + BegPadding + EndPadding;

            ODFElemSize.MSSValue := LHAElemsFixedSize /
                                     ( 1 + 0.01*ODFGapSize.MSSValue );

            if LHAOrient = lhaoHorCol then
              WPPatLHmmSize.Y := Max( LHAPatLHSize.Y, AcrosmmSize )
            else // LHAOrient = lhaoVertCol
              WPPatLHmmSize.X := Max( LHAPatLHSize.X, AcrosmmSize );

          end else //********** LHAElemsFixedSize = 0 - Across Size is given
          begin
            ODFElemSize.MSSValue := 0;
          end;
        end; // with PODFSParams^ do

        //***** Set LHAPatLinHist Orientation

        with PDP()^.C2DSpace do
        begin
          case LHAOrient of

          lhaoHorCol: begin // Horizontal LinHists Columns
            TDSArgAxisPos    := tdsVertical;
            TDSArgDirection  := tdsIncreasing;
            TDSFuncDirection := tdsIncreasing;
          end; // lhaoHorCol: begin // Horizontal LinHists Columns

          lhaoVertCol: begin // Vertical LinHists Columns
            TDSArgAxisPos    := tdsHorizontal;
            TDSArgDirection  := tdsIncreasing;
            TDSFuncDirection := tdsDecreasing;
          end; // lhaoVertCol: begin // Vertical LinHists Columns

          end; // case LHAOrient of
        end; // with PDP()^.C2DSpace do
      end; // with ... do, with ... do
    end; // PatLinHist


    //***** Calc WPBlockmmSize
    WPBlockmmSize := WPPatLHmmSize;

    if LHAType = lhatSimple then //*** Several Blocks with Simple Histogramm
      WPBlockmmSize.X := WPBlockmmSize.X + WPValTextsmmWidth;


    //***** Set WPNumBlocks, WPNumColsInBlock, WPNumBlocksInRow and WPNumBlockRows
    //      by given Max Width and LHAMaxBlocksInRow

    FreeSizeX := LHAWholeMaxSize.X - WPElemsNamesmmWidth -
                                    LHALTRBPaddings.Left - LHALTRBPaddings.Right;

    if LHAType = lhatSimple then //*** Several Blocks with Simple Histogramm
    begin
      WPNumBlocks    := WPNumGroups;
      MaxBlocksInRow := max( 1, Round(Floor( FreeSizeX / WPBlockmmSize.X ))); // prelimenary value

      if LHAMaxBlocksInRow >= 1 then // Max Blocks In Row is explicitly given, use it
         MaxBlocksInRow := LHAMaxBlocksInRow;

      if WPNumBlocks <= MaxBlocksInRow then //*** One Blocks Row
      begin
        WPNumBlocksInRow := WPNumBlocks;
        WPNumBlockRows := 1;
      end else //******************************** Several Blocks Row
      begin
        WPNumBlocksInRow := MaxBlocksInRow;
        WPNumBlockRows := WPNumBlocks div MaxBlocksInRow;

        if WPNumBlockRows*WPNumBlocksInRow < WPNumBlocks then
          Inc( WPNumBlockRows );
      end; // else // Several Blocks Row
    end else //************* LHAType = lhatStacked, One Block with Stacked Histogramm
    begin
      WPNumBlocks      := 1;
      WPNumBlocksInRow := 1;
      WPNumBlockRows   := 1;
    end; // else // LHAType = lhatStacked


    //***** Calc SelfRealSize.X,Y and WPAddOfsXmm

    SelfRealSize.X := LHALTRBPaddings.Left + WPElemsNamesmmWidth +
                        WPNumBlocksInRow*( WPBlockmmSize.X + LHAIntGapSize.X) -
                                       LHAIntGapSize.X + LHALTRBPaddings.Right;

    SelfRealSize.Y := LHALTRBPaddings.Top + WPMainHeadermmHeight +
         WPNumBlockRows * (WPBlockmmSize.Y + WPBlockHeadermmHeight + LHAIntGapSize.Y) -
         LHAIntGapSize.Y + LHAMaxLegHeight + LHALTRBPaddings.Bottom;

    WPAddOfsXmm := max( 0, LHAWholeMinSize.X - SelfRealSize.X );
    case LHABlocksHorAlign of
    hvaBeg:    WPAddOfsXmm := 0;
    hvaCenter: WPAddOfsXmm := 0.5*WPAddOfsXmm;
    hvaEnd:    WPAddOfsXmm := WPAddOfsXmm;
    else
      WPAddOfsXmm := 0;
    end; // case LHABlocksHorAlign of


    SelfRealSize.X := max( SelfRealSize.X, LHAWholeMinSize.X );
    SelfRealSize.Y := max( SelfRealSize.Y, LHAWholeMinSize.Y );


    with PCCD()^ do // Update Self Size (Dynamic)
    begin
      SRSize := SelfRealSize;
      SRSizeXType := cstmm;
      SRSizeYType := cstmm;
    end;

    with PCCS()^ do // Update Self Size (Static) Temporary?
    begin
      SRSize := SelfRealSize;
      SRSizeXType := cstmm;
      SRSizeYType := cstmm;
    end;

  end; // with PRCompD^.CLinHistAuto1 do
end; // end_of procedure TN_UDLinHistAuto1.PrepRootComp

//****************************************** TN_UDLinHistAuto1.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDLinHistAuto1.BeforeAction();
var
  ix, iy, BHOfsPixX, ElNamesPixWidth, VTPixWidth, CurFreePixY: integer;
  IntGapPix, BlockSizePix, OneLHSizePix: TPoint;
  PaddingsPix, WholePixRect: TRect;
  RLegNames, RLegColors: TK_RArray;
  PRCompD: TN_PRLinHistAuto1;
  Label DrawLegend;

//      Local Procedures:
//  function  mmToPix            ( AmmSize: float ): integer;
//  procedure DrawBlockHeaders   ( ARowInd: integer );
//  procedure DrawStackedLinHist ();
//  procedure DrawNames          ( ARowInd, AIndInRow: integer );
//  procedure DrawValTexts       ( ARowInd, AIndInRow: integer );

  function mmToPix( AmmSize: float ): integer;
  // convert given Size from mm to Pixels
  begin
    Result := Round( AmmSize*NGCont.mmPixSize.X );
  end; // function mmToPix - local

  procedure DrawBlockHeaders( ARowInd: integer );
  // Draw One Row of BlockHeaders and
  // increment CurFreePixY by Max BlockHeader Height
  var
    i, ind, CurX, CurSizeY, SizeYM1, MaxSizeY: integer;
  begin
    with PRCompD^.CLinHistAuto1, TN_PLHAWrkParams(UDLHAWrkParams)^ do
    begin
    if lhafSkipBlockHeaders in LHAFlags then Exit;

    CurX     := BHOfsPixX;
    SizeYM1  := mmToPix( WPBlockHeadermmHeight ) - 1;
    MaxSizeY := 0;

    for i := 0 to WPNumBlocksInRow-1 do // Along all BlockHeaders in ARowInd
    begin
      ind := ARowInd * WPNumBlocksInRow + i;

      if ind >= WPNumBlocks then Break; // All Block Headres are Drawn

      TN_UDCompVis(LHABlockHeader).CompOuterPixRect :=
      IRect( CurX, CurFreePixY, CurX+BlockSizePix.X-1, CurFreePixY+SizeYM1 );

      TN_POneTextBlock(TN_UDParaBox(LHABlockHeader).PIDP()^.CPBTextBlocks.
                                P(0))^.OTBMText := PString(WPRBlockNames.P(ind))^;

      with TN_UDParaBox(LHABlockHeader) do
      begin
        NGCont := Self.NGCont;
        BeforeAction();
        CurSizeY := CompOuterPixRect.Bottom - CompOuterPixRect.Top + 1;
      end;

      MaxSizeY := max( MaxSizeY, CurSizeY );

      Inc( CurX, BlockSizePix.X+IntGapPix.X );
    end; // for i := 0 to WPNumBlocksInRow-1 do // Along all BlockHeaders in ARowInd

    Inc( CurFreePixY, MaxSizeY );
    end; // with PRCompD^.CLinHistAuto1, TN_PLHAWrkParams(UDLHAWrkParams)^ do
  end; // procedure DrawBlockHeaders - local

  procedure DrawOneSimpleLinHist( ARowInd, AIndInRow: integer );
  // Draw One Simple LinHist
  var
    NX, NY, ind, CurX: integer;
  begin
    with PRCompD^.CLinHistAuto1, TN_PLHAWrkParams(UDLHAWrkParams)^ do
    with TN_UD2DLinHist(LHAPatLinHist) do
    with PIDP()^ do
    begin
      //***** Set LHAPatLinHist Funcs Limits

      ind := ARowInd * WPNumBlocksInRow + AIndInRow;
      if ind >= WPNumBlocks then Exit; // All Lin Hists are Drawn

      with PDP()^.C2DSpace do
      begin
        TDSFuncMin := PDouble(TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'FuncsMin' ).PS( Ind ))^;
        TDSFuncMax := PDouble(TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'FuncsMax' ).PS( Ind ))^;
      end; // with PDP()^.C2DSpace do

      //***** Set LHAPatLinHist Values and Colors

      if LHValues.ALength() <> WPNumColsInBlock then
        LHValues.ASetLength( WPNumColsInBlock );

      N_CopyDoubles( WPRVals.P(Ind), LHValues.P(0), WPNumBlocks, WPNumColsInBlock );

      if WPUserColorsGiven then
      begin
        if LHExtColors.ALength() < WPNumColsInBlock then
          LHExtColors.ASetLength( WPNumColsInBlock );

        if WPMatrixColors then // individual Colors for all Matrix Elements
          N_CopyIntegers( WPRColors.P(Ind), LHExtColors.P(0), WPNumBlocks, WPNumColsInBlock )
        else //**************** same Colors for all groups (Blocks)
          N_CopyIntegers( WPRColors.P(0), LHExtColors.P(0), 1, WPNumColsInBlock );

        K_RFreeAndCopy( LHFillColors, LHExtColors, [K_mdfCopyRArray] ); // later remove LHFillColors
      end; // if WPUserColorsGiven then

      //***** Set Coords and Draw

      CurX := BHOfsPixX + VTPixWidth + AIndInRow * (BlockSizePix.X + IntGapPix.X);
      CompOuterPixRect := IRect( CurX,                  CurFreePixY,
                                 CurX+OneLHSizePix.X-1, CurFreePixY+OneLHSizePix.Y-1 );
      NGCont := Self.NGCont;
      CompIntPixRect := NGCont.DrawCPanel( PDP()^.CPanel, CompOuterPixRect );
      
      AF2U6.CXX := N_NotADouble; // Clear "AF2U6 coefs are OK" flag
      BeforeAction(); // Draw Simple LinHist
    end; // with...do,  with...do,  with...do,

    if not (lhafSkipFuncsTicks in PRCompD^.CLinHistAuto1.LHAFlags) then
    begin
      with PRCompD^.CLinHistAuto1, TN_PLHAWrkParams(UDLHAWrkParams)^ do
      with TN_UDAxisTics(LHAFuncsTicks) do
      with PIDP()^ do
      begin
        if WPRFuncsTicks.ALength() >= 1 then
        begin
          WPRFuncsTicks.ALength( NX, NY );

          if NX = 1 then // same Ticks for all Blocks
            ind := 0;

          N_CopyDoubles( WPRFuncsTicks.P(ind), ATBaseZs.P(0), NX, NY );

          CompIntPixRect := TN_UD2DLinHist(LHAPatLinHist).CompIntPixRect;
          NGCont := Self.NGCont;
          BeforeAction(); // Draw FuncTics
        end;
      end; // with...do,  with...do,  with...do,
    end; // if not (lhafSkipFuncsTicks in LHAFlags) then

  end; // procedure DrawOneSimpleLinHist - local

  procedure DrawStackedLinHist();
  // Draw Stacked LinHist
  var
    LeftX, RightX: integer;
  begin
    RightX := CompOuterPixRect.Right - PaddingsPix.Right;

    with PRCompD^.CLinHistAuto1, TN_PLHAWrkParams(UDLHAWrkParams)^ do
    with TN_UD2DLinHist(LHAPatLinHist) do
    with PIDP()^ do
    begin
      //***** Set LHAPatLinHist Funcs Limits

      with PDP()^.C2DSpace do
      begin
        TDSFuncMin := PDouble(TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'FuncsMin' ).PS( 0 ))^;
        TDSFuncMax := PDouble(TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'FuncsMax' ).PS( 0 ))^;
      end; // with PDP()^.C2DSpace do

      //***** Set LHAPatLinHist Values and Colors

      K_RFreeAndCopy( LHValues, WPRVals, [K_mdfCopyRArray] );

      if WPUserColorsGiven then
      begin
        K_RFreeAndCopy( LHExtColors,  WPRColors,  [K_mdfCopyRArray] );
        K_RFreeAndCopy( LHFillColors, LHExtColors, [K_mdfCopyRArray] ); // later remove LHFillColors
      end; // if WPUserColorsGiven then

      //***** Set Coords and Draw
      LeftX := BHOfsPixX + VTPixWidth * WPNumElemsInGroup;
      CompOuterPixRect := IRect( LeftX,  CurFreePixY,
                                 RightX, CurFreePixY+OneLHSizePix.Y-1 );
      NGCont := Self.NGCont;
      CompIntPixRect := NGCont.DrawCPanel( PDP()^.CPanel, CompOuterPixRect );

      AF2U6.CXX := N_NotADouble; // Clear "AF2U6 coefs are OK" flag
      BeforeAction(); // Draw Stacked LinHist
    end; // with...do,  with...do,  with...do,

    if not (lhafSkipFuncsTicks in PRCompD^.CLinHistAuto1.LHAFlags) then
    begin
      with PRCompD^.CLinHistAuto1, TN_PLHAWrkParams(UDLHAWrkParams)^ do
      with TN_UDAxisTics(LHAFuncsTicks) do
      with PIDP()^ do
      begin
        if WPRFuncsTicks.ALength() >= 1 then
        begin
          K_RFreeAndCopy( ATBaseZs, WPRFuncsTicks, [K_mdfCopyRArray] );
          CompIntPixRect := TN_UD2DLinHist(LHAPatLinHist).CompIntPixRect;
          NGCont := Self.NGCont;
          BeforeAction(); // Draw FuncTics
        end;
      end; // with...do,  with...do,  with...do,
    end; //if not (lhafSkipFuncsTicks in LHAFlags) then
  end; // procedure DrawStackedLinHist - local

  procedure DrawNames( ARowInd, AIndInRow: integer );
  // Draw One Column of Elems Names for Simple Hist of Block Names for Stacked Hist
  // now XOfsPix is always 0
  //
  // Remark For Simple Hist:
  //   AIndInRow is not used, but may be used later for drawing Elemes Names inside all Blocks
  //
  var
    ind, XOfsPix: integer;
  begin
    with PRCompD^.CLinHistAuto1, TN_PLHAWrkParams(UDLHAWrkParams)^ do
    with TN_UDTextMarks(LHAElemsNames) do
    with PIDP()^ do
    begin
      if lhafSkipElemsNames in LHAFlags then Exit; // nothing to draw

      if TMStrings = nil then
        TMStrings := K_RCreateByTypeCode( Ord(nptString), WPNumColsInBlock )
      else
        TMStrings.ASetLength( WPNumColsInBlock );

      XOfsPix := WholePixRect.Left + PaddingsPix.Left;

      if LHAType = lhatSimple then
      begin
        //***** Set TMStrings
        ind := ARowInd * WPNumBlocksInRow + AIndInRow;
        if ind >= WPNumBlocks then Exit; // All Elems Names are Drawn

        //***** Set Elems Names and Coords

        if WPElNamesInBlocks then // individual Elems Names for each Block
        begin
          N_CopyStringsByPtrs( WPRElNames.P(ind), TMStrings.P(0), WPNumBlocks, WPNumColsInBlock );
          // XOfsPix calculation is not implemented
        end else //******************************* one Elems Names for all Blocks in Row
        begin
          N_CopyStringsByPtrs( WPRElNames.P(0), TMStrings.P(0), 1, WPNumColsInBlock );
        end;
      end else // LHAType = lhatStacked
      begin
        N_CopyStringsByPtrs( WPRBlockNames.P(0), TMStrings.P(0), 1, WPNumColsInBlock );
      end; // else // LHAType = lhatStacked

      CompOuterPixRect := IRect( XOfsPix,                   CurFreePixY,
                                 XOfsPix+ElNamesPixWidth-1, CurFreePixY+OneLHSizePix.Y-1 );
      NGCont := Self.NGCont;
      CompIntPixRect := NGCont.DrawCPanel( PDP()^.CPanel, CompOuterPixRect );
      BeforeAction(); // Draw Elems Names for Simple Hist or Block Names for Stacked Hist
    end; // with...do,  with...do,  with...do,
  end; // procedure DrawNames - local

  procedure DrawValTexts( ARowInd, AIndInRow: integer );
  // Draw One Column of ValTexts
  // for Stacked Hist ARowInd=0, AIndInRow = Column index
  var
    ind, CurX: integer;
  begin
    with PRCompD^.CLinHistAuto1, TN_PLHAWrkParams(UDLHAWrkParams)^ do
    with TN_UDTextMarks(LHAValTexts) do
    with PIDP()^ do
    begin
      if lhafSkipValTexts in LHAFlags then Exit; // nothing to draw

      if TMStrings = nil then
        TMStrings := K_RCreateByTypeCode( Ord(nptString), WPNumColsInBlock )
      else
        TMStrings.ASetLength( WPNumColsInBlock );

      if LHAType = lhatSimple then
      begin
        ind := ARowInd * WPNumBlocksInRow + AIndInRow;
        if ind >= WPNumBlocks then Exit; // All ValTexts are Drawn

        N_CopyStringsByPtrs( WPRValTexts.P(ind), TMStrings.P(0), WPNumBlocks, WPNumColsInBlock );

        CurX := BHOfsPixX + AIndInRow * (BlockSizePix.X + IntGapPix.X);
      end else // LHAType = lhatStacked
      begin
        ind := AIndInRow * WPNumGroups;
        N_CopyStringsByPtrs( WPRValTexts.P(ind), TMStrings.P(0), 1, WPNumColsInBlock );

        CurX := BHOfsPixX + AIndInRow * VTPixWidth;
      end; // else // LHAType = lhatStacked

      CompOuterPixRect := IRect( CurX,              CurFreePixY,
                                 CurX+VTPixWidth-1, CurFreePixY+OneLHSizePix.Y-1 );

      NGCont := Self.NGCont;
      CompIntPixRect := NGCont.DrawCPanel( PDP()^.CPanel, CompOuterPixRect );
      BeforeAction(); // Draw one column of Val Texts
    end; // with...do,  with...do,  with...do,
  end; // procedure DrawValTexts - local

begin
//  N_TestRectDraw( NGCont.DstOCanv, 10, 10, $CC00 ); // debug
//  Exit;

//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  if UDLHAWrkParams = nil then
  begin
    N_LCAddErr( N_LinHistAuto, 'Bad UDLHAWrkParams' );
    Exit;
  end;

  PRCompD := PDP();
  with PRCompD^, PRCompD^.CLinHistAuto1, PCCD()^, TN_PLHAWrkParams(UDLHAWrkParams)^ do
  begin

    if WPErrorInPrepRoot then
    begin
      N_LCAddErr( N_LinHistAuto, 'Error deteñted in PrepRootComp' );
      Exit;
    end;

    //***** Calc IntGapPix, PaddingsPix, BlockSizePix, OneLHSizePix,
    //           VTPixWidth, BHOfsPixX, LHOfsPixX, CurFreePixY

    IntGapPix.X := mmToPix( LHAIntGapSize.X );
    IntGapPix.Y := mmToPix( LHAIntGapSize.Y );

    PaddingsPix.Left   := mmToPix( LHALTRBPaddings.Left + WPAddOfsXmm );
    PaddingsPix.Top    := mmToPix( LHALTRBPaddings.Top );
    PaddingsPix.Right  := mmToPix( LHALTRBPaddings.Right );
    PaddingsPix.Bottom := mmToPix( LHALTRBPaddings.Bottom );

    BlockSizePix.X  := mmToPix( WPBlockmmSize.X );
    BlockSizePix.Y  := mmToPix( WPBlockmmSize.Y );

    OneLHSizePix.X  := mmToPix( WPPatLHmmSize.X );
    OneLHSizePix.Y  := mmToPix( WPPatLHmmSize.Y );

    VTPixWidth      := mmToPix( WPValTextsmmWidth );
    ElNamesPixWidth := mmToPix( WPElemsNamesmmWidth );

    WholePixRect := Self.CompIntPixRect; // Show Self Pix Rect (same as LogFrameRect mines panel borders)

    //*** BHOfsPixX is Leftmoust Block Header X Offset
    BHOfsPixX   := WholePixRect.Left + PaddingsPix.Left + ElNamesPixWidth;
    CurFreePixY := WholePixRect.Top + PaddingsPix.Top;


    //***** Draw main Header

    if not (lhafSkipMainHeader in LHAFlags) then //***** Draw main Header
    with TN_UDParaBox(LHAMainHeader) do
    begin
//      N_ir := CompOuterPixRect; // debug
      Self.CurFreeRects[0] := WholePixRect;
      Inc( Self.CurFreeRects[0].Top, PaddingsPix.Top );

      NGCont := Self.NGCont;
      ExecSubTree();
      CurFreePixY := CompOuterPixRect.Bottom + 1;
    end; // with...do, if not (lhafSkipMainHeader in LHAFlags) then //***** Draw main Header


    //***** Draw Stacked Histogramm

    if LHAType = lhatStacked then // One Block with Stacked Histogramm
    begin
      //*** Check if Elems Names and ValTexts should be drawn

      DrawStackedLinHist();

      DrawNames( 0, 0 );

      for ix := 0 to WPNumElemsInGroup-1 do
      begin
        DrawValTexts( 0, ix );
      end; // for ix := 0 to WPNumElemsInGroup-1 do

      Inc( CurFreePixY, BlockSizePix.Y );

      goto DrawLegend; // All drawn except Legend
    end; // if LHAType = lhatStacked then // One Block with Stacked Histogramm


    //***** Draw Block Rows with Simple Histogramms

    for iy := 0 to WPNumBlockRows-1 do // along all Block Rows
    begin

      if not (lhafBlockHeadersBelow in LHAFlags) then // Draw Row of BlockHeaders
        DrawBlockHeaders( iy );

      //***** Draw one Leftmoust LinHist, ElemsNames and one ValTexts

      DrawOneSimpleLinHist( iy, 0 );
      DrawNames( iy, 0 );
      DrawValTexts( iy, 0 );

      for ix := 1 to WPNumBlocksInRow-1 do // along other Blocks in iy-th Row
      begin
        DrawOneSimpleLinHist( iy, ix );
        DrawValTexts( iy, ix );
      end; // for ix := 1 to WPNumBlocksInRow-1 do // along other Blocks in iy-th Row

      Inc( CurFreePixY, BlockSizePix.Y );

      if lhafBlockHeadersBelow in LHAFlags then
        DrawBlockHeaders( iy );

      Inc( CurFreePixY, IntGapPix.Y );
    end; // for iy := 0 to WPNumBlockRows-1 do // along all Block Rows


    DrawLegend: //****************************************  Draw main Legend

    if not (lhafSkipLegend in LHAFlags) and (LHALegend <> nil) then
    begin
//      N_ir := CompOuterPixRect; // debug
      CurFreeRects[0] := WholePixRect;
      CurFreeRects[0].Top := CurFreePixY;
      Dec( CurFreeRects[0].Bottom, PaddingsPix.Bottom );

      RLegNames  := nil;
      RLegColors := nil;
      K_RFreeAndCopy( RLegNames,  TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'LegNames' ), [K_mdfCopyRArray] );
      K_RFreeAndCopy( RLegColors, TN_UDCompBase(LHAUserParams).GetSUserParRArray( 'LegColors' ), [K_mdfCopyRArray] );

      if not WPMatrixColors then // Common Colors for all Groups, Prep RLegNames, RLegColors
      begin
        if RLegNames.ALength = 0 then
        begin
          K_RFreeAndCopy( RLegNames, WPRElNames, [K_mdfCopyRArray] );

          if LHAType = lhatSimple then
            RLegNames.ASetLength( WPNumColsInBlock ) // a precaution
          else // LHAType = lhatStacked
            RLegNames.ASetLength( WPNumElemsInGroup ); // a precaution

          K_RFreeAndCopy( RLegColors, WPRColors, [K_mdfCopyRArray] );
        end;
      end; // if not WPMatrixColors then // Common Colors for all Groups, Prep RLegNames, RLegColors

      with TN_UDLegend(LHALegend).PIDP()^ do // Set Legend Params by Legend Names and Colors
      begin                                  // (otherwise they should be already OK)
        if RLegNames.ALength > 0 then
          K_RFreeAndCopy( LegElemTexts, RLegNames, [K_mdfCopyRArray] );

        if RLegColors.ALength > 0 then
          K_RFreeAndCopy( LegElemColors, RLegColors, [K_mdfCopyRArray] );
      end; // with TN_UDLegend(LHALegend) do // Set Legend Params

      RLegNames.ARelease;
      RLegColors.ARelease;

      with TN_UDLegend(LHALegend) do
      begin
        NGCont := Self.NGCont;
        ExecSubTree();
      end;
    end; // if not (lhafSkipLegend in LHAFlags) then //***** Draw main Legend

  end; // PRCompD^, PRCompD^.CLinHistAuto1, PCCD()^ do
end; // end_of procedure TN_UDLinHistAuto1.BeforeAction


//********** TN_UDPieChart class methods  **************

//********************************************** TN_UDPieChart.Create ***
//
constructor TN_UDPieChart.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDPieChartCI;
  ImgInd := 58;
end; // end_of constructor TN_UDPieChart.Create

//********************************************* TN_UDPieChart.Destroy ***
//
destructor TN_UDPieChart.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDPieChart.Destroy

//********************************************** TN_UDPieChart.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDPieChart.PSP(): TN_PRPieChart;
begin
  Result := TN_PRPieChart(R.P());
end; // end_of function TN_UDPieChart.PSP

//********************************************** TN_UDPieChart.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDPieChart.PDP(): TN_PRPieChart;
begin
  if DynPar <> nil then Result := TN_PRPieChart(DynPar.P())
                   else Result := TN_PRPieChart(R.P());
end; // end_of function TN_UDPieChart.PDP

//******************************************* TN_UDPieChart.PISP ***
// return typed pointer to Individual Static PieChart Params
//
function TN_UDPieChart.PISP(): TN_PCPieChart;
begin
  Result := @(TN_PRPieChart(R.P())^.CPieChart);
end; // function TN_UDPieChart.PISP

//******************************************* TN_UDPieChart.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic PieChart Params
// otherwise return typed pointer to Individual Static PieChart Params
//
function TN_UDPieChart.PIDP(): TN_PCPieChart;
begin
  if DynPar <> nil then
    Result := @(TN_PRPieChart(DynPar.P())^.CPieChart)
  else
    Result := @(TN_PRPieChart(R.P())^.CPieChart);
end; // function TN_UDPieChart.PIDP

//********************************************** TN_UDPieChart.PascalInit ***
// Init self
//
procedure TN_UDPieChart.PascalInit();
var
  PRCompS: TN_PRPieChart;
begin
  Inherited;
  PRCompS := PSP();
  with PRCompS^, PRCompS^.CPieChart do
  begin
//    PCCenter := FPoint( 50, 40 );
//    PCSize   := FPoint( 90, 30 );
    PCVSHeight := 20;

    PCBordersWidth  := 1;
    PCVSColorCoef   := 80;

    PCValStrPos      := 0.7;
    PCValStrMinAngle := 20;
  end;
end; // procedure TN_UDPieChart.PascalInit

//************************************** TN_UDPieChart.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDPieChart.BeforeAction();
var
  i, VInd, PieInd, PieColor, NumVals, PixVSHeight, VertSideColor: integer;
  ColorInd, NumColors, PixBorderWidth, HalfWidth: integer;
  WrkFloat: float;
  OtherAngle, OtherValue, CurAngle, MidAngle: double;
  EllEnvRect, StrValsRect, NamesRect: TFRect;
  PRCompD: TN_PRPieChart;
  Vals: TN_DArray;
  PFirstVal: PDouble;
  OrderedVInds: TN_IArray; // Ordered indexes to Vals[i]
  ShapeCoords: TN_ShapeCoords;
  ContAttr: TK_RArray;
  PContAttr: TN_PContAttr;

{ // old variant
  procedure DrawPieSegm( APieColor: integer; ABegAngle, AArcAngle: double ); // local
  begin
    with NGCont, NGCont.DstOCanv, PRCompD^.CPieChart do
    begin

    NumInts := AddPieSegment( WrkInts, 0, EllCenter.X, EllCenter.Y,
                                    EllRad.X, EllRad.Y, ABegAngle, AArcAngle );

    DrawShape( @WrkInts[0], NumInts, APieColor, APieColor, 0 );
    DrawShape( @WrkInts[NumInts], 9, N_EmptyColor, PCBordersColor, PCBordersWidth );

    NumInts := AddPieSegmSide( WrkInts, 0, EllCenter.X, EllCenter.Y,
        EllRad.X, EllRad.Y, PixHeight, ABegAngle, AArcAngle, AddAngle );

    VertSideColor := N_InterpolateTwoColors( 0, APieColor, PCVSColorCoef/100 );
    DrawShape( @WrkInts[0], NumInts, VertSideColor, VertSideColor, 0 );
    DrawShape( @WrkInts[NumInts], 12, N_EmptyColor, PCBordersColor, PCBordersWidth );

    if AddAngle > 0 then // draw second part of PieSegmSide
    begin
      NumInts := DstOCanv.AddPieSegmSide( WrkInts, 0, EllCenter.X, EllCenter.Y,
                                                 EllRad.X, EllRad.Y, PixHeight,
                             ABegAngle+AddAngle, AArcAngle-AddAngle, AddAngle );

      DrawShape( @WrkInts[0], NumInts, VertSideColor, VertSideColor, 0 );
      DrawShape( @WrkInts[NumInts], 12, N_EmptyColor, PCBordersColor, PCBordersWidth );
    end; // if AddAngle > 0 then // draw second part of PieSegmSide

    end; // with NGCont, NGCont.DstOCanv, PRCompD^.CPieChart do
  end; // procedure DrawPieSegm
}
  procedure DrawPieSegm2( APieColor: integer; ABegAngle, AArcAngle: double ); // local
  begin
    with NGCont, NGCont.DstOCanv, PRCompD^.CPieChart do
    begin

    ShapeCoords.Clear();
    ShapeCoords.AddEllipseFragm( EllEnvRect, abtPieSegment, ABegAngle, AArcAngle );
    PContAttr^.CABrushColor := APieColor;
    DrawShape( ShapeCoords, ContAttr, N_ZFPoint );

    ShapeCoords.Clear();
    ShapeCoords.AddCilinderFragm( EllEnvRect, ABegAngle, AArcAngle, PixVSHeight );
    VertSideColor := N_InterpolateTwoColors( 0, APieColor, PCVSColorCoef/100 );
    PContAttr^.CABrushColor := VertSideColor;
//    PContAttr^.CABrushColor := N_EmptyColor; // debug
    DrawShape( ShapeCoords, ContAttr, N_ZFPoint );

{ // debug
  PathPoints: TN_IPArray;
  PathFlags: TN_BArray;

    ShapeCoords.PrepWinGDIPath( HMDC, N_ZFPoint );
    NumPathPoints := N_GetPathCoords( HMDC, PathPoints, PathFlags );

    ShapeCoords.Clear();
    ShapeCoords.AddPixPolyDraw( @PathPoints[0], @PathFlags[0], NumPathPoints );
    if pcfTmp in PCFlags then // old var
      DrawShape( ShapeCoords, ContAttr, N_ZFPoint );
}
    end; // with NGCont, NGCont.DstOCanv, PRCompD^.CPieChart do
  end; // procedure DrawPieSegm2

begin //********************************** body of TN_UDPieChart.BeforeAction
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();

  with NGCont, NGCont.DstOCanv, PRCompD^, PRCompD^.CPieChart, PCCD()^ do
  begin
    PixVSHeight := Round( N_RectHeight(CompIntPixRect) * PCVSHeight / 100 );
    PixBorderWidth := LLWToPix1( PCBordersWidth );
    HalfWidth := PixBorderWidth div 2;
    EllEnvRect.Left   := CompIntPixRect.Left   + HalfWidth;
    EllEnvRect.Top    := CompIntPixRect.Top    + HalfWidth;
    EllEnvRect.Right  := CompIntPixRect.Right  - HalfWidth;
    EllEnvRect.Bottom := CompIntPixRect.Bottom - HalfWidth - PixVSHeight;

    BPPixEllCenter := FPoint(N_RectCenter( EllEnvRect ));
    StrValsRect := N_RectScaleR( EllEnvRect, PCValStrPos, N_05DPoint );
    NamesRect   := N_RectScaleR( EllEnvRect, PCNamePos,   N_05DPoint );

    // force even Ellipse Pixel dimensions to have integer Ellipse Center

    WrkFloat := 0.5*N_RectWidth( EllEnvRect );
    if WrkFloat <> Floor(WrkFloat) then
      EllEnvRect.Right := EllEnvRect.Right - 1;

    WrkFloat := 0.5*N_RectHeight( EllEnvRect );
    if WrkFloat <> Floor(WrkFloat) then
      EllEnvRect.Bottom := EllEnvRect.Bottom - 1;

    //***** Prepare Values for drawing

    PFirstVal := PDouble(PCValues.P());
    NumVals := PCValues.ALength();
    N_GetNormValues( Vals, 360, PFirstVal, NumVals );

    if pcfAutoOrder in PCFlags then // Order Values in decreasing order
    begin
      OrderedVInds := TN_IArray(N_GetSortedIndexes( @Vals[0], NumVals,
                             SizeOf(Vals[0]), N_SortOrder, N_CompareDoubles ));
    end else // use source order
    begin
      SetLength( OrderedVInds, NumVals );
      for i := 0 to NumVals-1 do
        OrderedVInds[i] := i;
    end;

    ShapeCoords := TN_ShapeCoords.Create();
    ContAttr := nil;
    PContAttr := N_PrepContAttr( ContAttr );
    with PContAttr^ do
    begin
      CAPenColor := PCBordersColor;
      CAPenWidth := PCBordersWidth;
    end;

    SetLength( BPPixValStrings, NumVals ); // set max possible Length
    SetLength( BPPixNames, NumVals );
    SetLength( PieValues,  NumVals );

    OtherAngle := 0;
    OtherValue := 0;
    CurAngle   := PCBegAngle;
    NumColors  := PCColors.ALength();
    ColorInd   := 0;
    PieInd     := 0;

    for i := 0 to NumVals-1 do // Draw all Pie Segments
    begin
      VInd := OrderedVInds[i];

      if Vals[VInd] < PCOtherMinAngle then // skip drawing Pie Segment
      begin
        OtherAngle := OtherAngle + Vals[VInd];
        OtherValue := OtherValue + PDouble(PCValues.P(VInd))^;
        Continue;
      end;

      if NumColors = 0 then
        PieColor := N_ClGreenGray // default Color
      else
      begin
        if ColorInd >= NumColors then
          ColorInd := ColorInd - NumColors;

        PieColor := PInteger(PCColors.P(ColorInd))^;
      end;
      Inc( ColorInd );

      if pcfClockWise in PCFlags then
        CurAngle := CurAngle - Vals[VInd];

      DrawPieSegm2( PieColor, CurAngle, Vals[VInd] );

      MidAngle := CurAngle + 0.5*Vals[VInd];
      BPPixValStrings[PieInd] := N_EllipsePoint( StrValsRect, MidAngle );
      BPPixNames[PieInd]      := N_EllipsePoint( NamesRect, MidAngle );

      if pcfShowPercents in PCFlags then
        PieValues[PieInd] := 100*Vals[VInd]/360 // conv degree to percents
      else
        PieValues[PieInd] := PDouble(PCValues.P(VInd))^;

      Inc( PieInd );

      if not (pcfClockWise in PCFlags) then
        CurAngle := CurAngle + Vals[VInd];

    end; // for i := 0 to NumVals-1 do // Draw all Pie Segments

    if OtherAngle > 0.01 then // Draw one additional "Other" Pie Segment
    begin
      if NumColors = 0 then
        PieColor := N_ClGreenGray // default Color
      else // NumColors >= 1
      begin
        if ColorInd >= NumColors then
          ColorInd := ColorInd - NumColors;

        PieColor := PInteger(PCColors.P(ColorInd))^;
      end; // else // NumColors >= 1

      if pcfClockWise in PCFlags then
        CurAngle := CurAngle - OtherAngle;

      DrawPieSegm2( PieColor, CurAngle, OtherAngle );

      MidAngle := CurAngle + 0.5*OtherAngle;
      BPPixValStrings[PieInd] := N_EllipsePoint( StrValsRect, MidAngle );
      BPPixNames[PieInd]      := N_EllipsePoint( NamesRect, MidAngle );

      if pcfShowPercents in PCFlags then
        PieValues[PieInd] := 100*OtherAngle/360 // conv degree to percents
      else
        PieValues[PieInd] := OtherValue;

      Inc( PieInd );
    end; // if OtherAngle > 0.1 then // Draw one additional "Other" Pie Segment

    SetLength( BPPixValStrings, PieInd ); // set real Length
    SetLength( BPPixNames, PieInd );
    SetLength( PieValues,  PieInd );

{
    //***** Draw full Ellipses Borders and two vert lines
    NumInts := DstOCanv.AddArc( WrkInts, 0, EllCenter.X, EllCenter.Y,
                                                   EllRad.X, EllRad.Y, 0, 180 );
    DrawShape( @WrkInts[0], NumInts, N_EmptyColor, PCBordersColor, PCBordersWidth );


    NumInts := DstOCanv.AddPieSegmSide( WrkInts, 0, EllCenter.X, EllCenter.Y,
                             EllRad.X, EllRad.Y, PixHeight, 0, -180, AddAngle );
    DrawShape( @WrkInts[0], NumInts, N_EmptyColor, PCBordersColor, PCBordersWidth );
}

{
    DstOCanv.SetPenAttribs( $FF, 0 ); //***** debug, to compare Bezier with ellips
    DstOCanv.SetBrushAttribs( -1 );
    DstOCanv.DrawPixEllipse( Rect( EllCenter.X-EllRad.X, EllCenter.Y-EllRad.Y,
                                   EllCenter.X+EllRad.X, EllCenter.Y+EllRad.Y ) );
    DstOCanv.DrawPixEllipse( Rect( EllCenter.X-EllRad.X, EllCenter.Y-EllRad.Y+PixHeight,
                                   EllCenter.X+EllRad.X, EllCenter.Y+EllRad.Y+PixHeight ) );
}
    ContAttr.Free;
    ShapeCoords.Free;
  end; // PRCompD^, PRCompD^.CPieChart, PCCD()^ do

end; // end_of procedure TN_UDPieChart.BeforeAction


//********** TN_UDTable class methods  **************

//********************************************** TN_UDTable.Create ***
//
constructor TN_UDTable.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDTableCI;
  CStatFlags := [csfCoords, csfNonCoords]; // can work in Both visual and NonVisual modes
  ImgInd := 59;
end; // end_of constructor TN_UDTable.Create

//********************************************* TN_UDTable.Destroy ***
//
destructor TN_UDTable.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDTable.Destroy

//********************************************** TN_UDTable.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDTable.PSP(): TN_PRTable;
begin
  Result := TN_PRTable(R.P());
end; // end_of function TN_UDTable.PSP

//********************************************** TN_UDTable.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDTable.PDP(): TN_PRTable;
begin
  if DynPar <> nil then Result := TN_PRTable(DynPar.P())
                   else Result := TN_PRTable(R.P());
end; // end_of function TN_UDTable.PDP

//******************************************* TN_UDTable.PISP ***
// return typed pointer to Individual Static Table Params
//
function TN_UDTable.PISP(): TN_PCTable;
begin
  Result := @(TN_PRTable(R.P())^.CTable);
end; // function TN_UDTable.PISP

//******************************************* TN_UDTable.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic Table Params
// otherwise return typed pointer to Individual Static Table Params
//
function TN_UDTable.PIDP(): TN_PCTable;
begin
  if DynPar <> nil then
    Result := @(TN_PRTable(DynPar.P())^.CTable)
  else
    Result := @(TN_PRTable(R.P())^.CTable);
end; // function TN_UDTable.PIDP

//********************************************** TN_UDTable.PascalInit ***
// Init self (Static Params)
//
procedure TN_UDTable.PascalInit();
begin
  Inherited;
  with PISP()^ do
  begin
    TaCols  := K_RCreateByTypeName( 'TN_TaRowColumn', 1 );
    TaRows  := K_RCreateByTypeName( 'TN_TaRowColumn', 1 );
    TaCells := K_RCreateByTypeName( 'TN_TaCell', 1 );
  end;

  IncTableSize( cptStatic, 5, 3 ); // debug
  DebCellsInit(); // debug
end; // procedure TN_UDTable.PascalInit

//***************************************** TN_UDTable.PrepMacroPointers ***
// Prepare Pointers to all Self Strings, that can contain Macroses
//
procedure TN_UDTable.PrepMacroPointers();
var
  ix, iy, NumCols, NumRows: integer;
begin
  inherited;
  with NGCont, PDP()^.CTable do
  begin
    NumCols := TaCols.ALength();
    NumRows := TaRows.ALength();

    for ix := 0 to NumCols-1 do // Add nonempty Column Attributes
    with TN_PTaRowColumn(TaCols.P(ix))^ do
      if RCAttr <> '' then
        AddPtrToMText( RCAttr );

    for iy := 0 to NumRows-1 do // Add nonempty Row Attributes
    with TN_PTaRowColumn(TaRows.P(iy))^ do
      if RCAttr <> '' then
        AddPtrToMText( RCAttr );

    //***** Add nonempty Cell TCMText and TCTextBlocks

    for iy := 0 to NumRows-1 do // along all rows
    for ix := 0 to NumCols-1 do // along all columns
    with TN_PTaCell(TaCells.P(iy*NumCols+ix))^ do
    begin

      if TCMText <> '' then
        AddPtrToMText( TCMText );

      NGCont.AddTextBlocksMPtrs( TCTextBlocks );
    end; // with ... do, for ix ... , for iy ...

  end; // with NGCont, PDP()^.CParaBox do
end; // end_of procedure TN_UDTable.PrepMacroPointers

//************************************** TN_UDTable.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDTable.BeforeAction();
var
  ix, iy, NumCols, NumRows: integer;
  CellSPLPrefix, RowAttr, ColAttr, CellAttr: string;
  CurCellOuterRect, TableInnerRect, CurCellInnerRect: TRect;
  CurCPanel, CurCParaBox: TK_RArray;
  PCParaBox: TN_PCParaBox;
  CParaBox: TN_CParaBox;
  PCol, PRow: TN_PTaRowColumn;
  UDPI: TK_UDProgramItem;
  PRCompD: TN_PRTable;
begin
//  if (ObjName = 'Header')  then  // debug
//    N_i := 1;

  SetCellsBlocks();

  PRCompD := PDP();
  with PRCompD^, PRCompD^.CTable, PCCD()^, NGCont do
  begin
    //***** Prepare for loop along Cells

    if GCTextMode then // Text (HTML, SVG, ...) Export mode
      GCOutSL.Add( '<table ' + CCompBase.CBTextAttr + '>' );

    if GCCoordsMode then // Coords Export mode
    begin
      TableInnerRect := GetCPanelIntRect( CPanel, CompOuterPixRect );
      CompIntPixRect := TableInnerRect;
    end;

    CorrectTableSize( cptDynamic ); // a precaution after manual editing
    CalcCellSizes( TableInnerRect );
    NumCols := TaCols.ALength();
    NumRows := TaRows.ALength();

    //***** Create or Initialize TN_SRTextLayout Obj

    if CellVR = nil then
      CellVR := TN_SRTextLayout.Create( DstOCanv )
    else
      CellVR.SRTLInit( DstOCanv );

    FillChar( CParaBox, Sizeof(CParaBox), 0 ); // Init CParaBox

    //***** Main loop along Cells Rows and Columns

    for iy := 0 to NumRows-1 do // along all rows
    begin

    if GCTextMode then // Current Export mode is Text (HTML, SVG, ...) (not Image)
    begin
      RowAttr := TN_PTaRowColumn(TaRows.P(iy))^.RCAttr;
      GCOutSL.Add( '<tr ' + RowAttr + '>' );
    end;

    for ix := 0 to NumCols-1 do // along all columns
    begin

    with TN_PTaCell(TaCells.P(iy*NumCols+ix))^ do
    begin
      //***** Common Actions for Text and Coords Modes for each Cell

      CellSPLPrefix := Format( 'Ta_%d%d_', [ix,iy] ); // should be same as in BuilsSPLUnit method!

      if (SPLUnit <> nil) and (TCSPLProc <> '') then // call Cell Initialization Macro
      begin
        UDPI := TK_UDProgramItem(SPLUnit.DirChildByObjName( CellSPLPrefix + 'Init' ));
        if UDPI <> nil then
          UDPI.CallSPLRoutine( [ix, iy] );
      end; // if (SPLUnit <> nil) and (TCSPLProc <> '') then // call Cell Initialization Macro

      //***** Calc CurCellOuterRect - Current Cell OuterRect (without Margins,Border,Paddings in Pixels)
      //      (is needed for TextMode too)

      if ix = 0 then
        CurCellOuterRect.Left := TableInnerRect.Left
      else // not leftmoust cell ( ix >= 1 )
        CurCellOuterRect.Left := LastPixX[ix-1];

      CurCellOuterRect.Right := LastPixX[ix];

      if iy = 0 then
        CurCellOuterRect.Top := TableInnerRect.Top
      else // not topmoust cell ( iy >= 1 )
        CurCellOuterRect.Top := LastPixY[iy-1];

      CurCellOuterRect.Bottom := LastPixY[iy];

      //***** CurCellOuterRect is OK, Define CurCPanel - Current Cell Panel Params

      CurCPanel := TaDefPanel;

      PCol := TN_PTaRowColumn(TaCols.P(ix));
      PRow := TN_PTaRowColumn(TaRows.P(iy));

      if (PCol^.RCPanel <> nil) and (PRow^.RCPanel <> nil) then // both given, check flag
      begin
        if tcfRowParams in TCFlags then CurCPanel := PRow^.RCPanel
                                   else CurCPanel := PCol^.RCPanel;
      end else // one or both (Col or Row) Panel not given
      begin
        if PCol^.RCPanel <> nil then CurCPanel := PCol^.RCPanel;
        if PRow^.RCPanel <> nil then CurCPanel := PRow^.RCPanel;
      end;

      if TCPanel <> nil then CurCPanel := TCPanel;

      //***** CurCPanel is OK, Define CurCParaBox - Current Cell ParaBox Params

      K_RFreeAndCopy( CurCParaBox, TaDefParaBox, [K_mdfFreeAndFullCopy] );

      if (PCol^.RCParaBox <> nil) and (PRow^.RCParaBox <> nil) then // both given, check flag
      begin
        if tcfRowParams in TCFlags then CurCParaBox := PRow^.RCParaBox
                                   else CurCParaBox := PCol^.RCParaBox;
      end else // one or both (Col or Row) Panel not given
      begin
        if PCol^.RCParaBox <> nil then CurCParaBox := PCol^.RCParaBox;
        if PRow^.RCParaBox <> nil then CurCParaBox := PRow^.RCParaBox;
      end;

      if TCParaBox <> nil then CurCParaBox := TCParaBox;

      if CurCParaBox <> nil then
        PCParaBox := TN_PCParaBox(CurCParaBox.P(0))
      else
      begin
        FreeAndNil( CParaBox.CPBTextBlocks );
        FreeAndNil( CParaBox.CPBAuxLine );
        PCParaBox := @CParaBox;
      end;

      //***** PCParaBox is OK

      with PCParaBox^ do // Prep CParaBox.CPBTextBlocks
      begin

        if CPBTextBlocks = nil then // Prep CParaBox.CPBTextBlocks
        begin
          if TCTextBlocks <> nil then
            CPBTextBlocks := TCTextBlocks
          else // Create TextBlocks and set by TCMText
          begin
            CPBTextBlocks := K_RCreateByTypeName( 'TN_OneTextBlock', 1 );
            TN_POneTextBlock(CPBTextBlocks.P(0))^.OTBMText := TCMText;
          end;
        end; // if CPBTextBlocks = nil then // Prep CParaBox.CPBTextBlocks

      end; // with CellVR, PCParaBox^ do // Prep CParaBox.CPBTextBlocks

      //***** CParaBox.CPBTextBlocks is OK


      //***** Individual code for Text and Coords Modes

      if GCTextMode then // Text (HTML, SVG, ...) Export mode,
      begin              // Cell content is always PCParaBox^.CPBTextBlocks
        CellAttr := N_GetTBAttributes( PCParaBox^.CPBTextBlocks );
        ColAttr := TN_PTaRowColumn(TaCols.P(ix))^.RCAttr;
        if (RowAttr <> '') and (tcfRowParams in TCFlags) then ColAttr := ''; // not needed
        GCOutSL.Add( '<td ' + ColAttr + CellAttr + '>' );
        TextBlocksToHTML( PCParaBox^.CPBTextBlocks ); // same method as in UDParaBox.BeforeAction
        GCOutSL.Add(  '</td>' )
      end; // if GCTextMode then // Text (HTML, SVG, ...) Export mode,

      if GCCoordsMode then // Coords Export mode
      begin
        // Draw Cell borders and background
        CurCellInnerRect := DrawCPanel( CurCPanel, CurCellOuterRect );

        if TCComp <> nil then // TCComp is Cell content, draw it
        begin
          Self.CompIntPixRect := CurCellInnerRect; // temporary, for CComp drawing
          TCComp.DynParent := Self;
          TCComp.NGCont := Self.NGCont;
          TCComp.ExecSubTree();
        end else // Cell content is PCParaBox^.CPBTextBlocks, draw them
        with CellVR, PCParaBox^ do // Layout and Draw Cell
        begin
          SRTLInit( DstOCanv );
          N_SetSRTLByCParaBox ( CellVR, PCParaBox, CurCellInnerRect );

          DrawTextRects( @SRTLTextRects[0], SRTLFreeTRInd,
                  TN_POneTextBlock(CPBTextBlocks.P(0)), CurCellInnerRect.TopLeft );
        end; // with CellVR, PCParaBox^ do, else - Cell content is PCParaBox^.CPBTextBlocks
      end; // if GCCoordsMode then // Coords Export mode

    end; // with TN_PTaCell(TaCells.P(iy*NumCols+ix))^ do
    end; // for ix := 0 to TaNumCols-1 do // along all Columns

    if GCTextMode then // Text (HTML, SVG, ...) Export mode
      GCOutSL.Add( '</tr>' );

    end; // for iy := 0 to TaNumRows-1 do // along all Rows

    if GCTextMode then // Text (HTML, SVG, ...) Export mode
      GCOutSL.Add( '</table>' );

    if GCCoordsMode then // Coords Export mode
      CompIntPixRect := TableInnerRect; // restore CompIntPixRect

    CParaBox.CPBTextBlocks.Free;

  end; // PRCompD^, PRCompD^.CTable, PCCD()^ do

end; // end_of procedure TN_UDTable.BeforeAction

//********************************************** TN_UDTable.CalcCellSizes ***
// Calculate all Cell Sizes in Pixels:
// fill XLastPix, YLastPix arrays by last pixel coord of appropriate Column, Row
//
procedure TN_UDTable.CalcCellSizes( AInnerPixRect: TRect );
var
  i, NumCols, NumRows, NumRelSizes, PixSize, SumAbsPixSize: integer;
  CurRelInd: integer;
  Fraction: float;
  RelSizes: TN_FArray;
  RelPixSizes: TN_IArray;
  DefRowCol: TN_TaRowColumn;
  PRowCol: TN_PTaRowColumn;
begin
  with NGCont, PIDP()^ do
  begin
    FillChar( DefRowCol, SizeOf(DefRowCol), 0 ); // default Column and Rows params

    //*************** Calc all Columns Coords and Sizes (all Cells widths)

    NumCols := TaCols.ALength();
    SetLength( LastPixX, NumCols );
    SetLength( RelSizes, NumCols );
    NumRelSizes   := 0;
    Fraction      := 0;
    SumAbsPixSize := 0;
    MSParentPixSize := N_RectWidth( AInnerPixRect ); // used in ConvMSToPix

    // First Pass: Calc all Columns Abs Sizes and fill
    //             RelSizes array for Relative Size Columns
    //             ( LastPixX is used as wrk array: it contains PixSizes for
    //               Abs Size Columns and -1 for Relative Size Columns )

    for i := 0 to NumCols-1 do // First Pass
    begin
      PRowCol := TN_PTaRowColumn(TaCols.P( i ));

      with PRowCol^ do
      begin

        if RCSize.MSSValue = 0 then // use default value
        begin
          RelSizes[NumRelSizes] := 100;
          Inc(NumRelSizes);
          LastPixX[i] := -1; // set "Relative Size Column" flag
        end else // some real (not default) value was given
        begin
          if RCSize.MSUnit = msuPrc then // Relative Size, store it to RelSizes
          begin
            RelSizes[NumRelSizes] := RCSize.MSSValue;
            Inc(NumRelSizes);
            LastPixX[i] := -1; // set "Relative Size Column" flag
          end else // absolute size
          begin
            PixSize := ConvMSToPix( RCSize.MSSValue, RCSize.MSUnit, @Fraction );
            if PixSize = 0 then PixSize := 20; // debug
            Inc( SumAbsPixSize, PixSize );
            LastPixX[i] := PixSize; // save temporary Column Pixel Size
          end; // else // absolute size
        end; // else // some real (not default) value was given

      end; // with PRowCol^ do
    end; // for i := 0 to NumCols-1 do // First Pass

    //***** Second Pass: Calc Pixel Sizes (RelPixSizes) for all Relative Size Columns

    RelPixSizes := nil;
    N_CalcIntSizes ( RelSizes, NumRelSizes,
                     N_RectWidth( AInnerPixRect )-SumAbsPixSize, RelPixSizes );

    //***** Third Pass: Calc Pixel X-Coords in LastPixX using RelPixSizes, LastPixX

    CurRelInd := 0; // index for RelPixSizes array

    for i := 0 to NumCols-1 do // Third Pass
    begin
      PixSize := LastPixX[i]; // Pix Size for Absolute Size Column or -1 for Relative Size Column

      if PixSize = -1 then // Relative Size Column
      begin
        PixSize := RelPixSizes[CurRelInd];
        Inc(CurRelInd);
      end;

      if i = 0 then // special case (first Column)
        LastPixX[i] := AInnerPixRect.Left + PixSize - 1
      else // i >= 1 (not first Column)
        LastPixX[i] := LastPixX[i-1] + PixSize;

    end; // for i := 0 to NumCols-1 do // Third Pass


    //*************** Column Sizes and Coords are calculated
    //                Calc all Rows Coords and Sizes (all Cells heights)

    NumRows := TaRows.ALength();
    SetLength( LastPixY, NumRows );
    SetLength( RelSizes, NumRows );
    NumRelSizes   := 0;
    Fraction      := 0;
    SumAbsPixSize := 0;
    MSParentPixSize := N_RectHeight( AInnerPixRect ); // used in ConvMSToPix

    // First Pass: Calc all Rows Abs Sizes and fill
    //             RelSizes array for Relative Size Rows
    //             ( LastPixY is used as wrk array: it contains PixSizes for
    //               Abs Size Rows and -1 for Relative Size Rows )

    for i := 0 to NumRows-1 do // First Pass
    begin
      PRowCol := TN_PTaRowColumn(TaRows.P( i ));

      with PRowCol^ do
      begin

        if RCSize.MSSValue = 0 then // use default value
        begin
          RelSizes[NumRelSizes] := 100;
          Inc(NumRelSizes);
          LastPixY[i] := -1; // set "Relative Size Row" flag
        end else // some real (not default) value was given
        begin
          if RCSize.MSUnit = msuPrc then // Relative Size, store it to RelSizes
          begin
            RelSizes[NumRelSizes] := RCSize.MSSValue;
            Inc(NumRelSizes);
            LastPixY[i] := -1; // set "Relative Size Column" flag
          end else // absolute size
          begin
            PixSize := ConvMSToPix( RCSize.MSSValue, RCSize.MSUnit, @Fraction );
            if PixSize = 0 then PixSize := 20; // debug
            Inc( SumAbsPixSize, PixSize );
            LastPixY[i] := PixSize; // save temporary Row Pixel Size
          end; // else // absolute size
        end; // else // some real (not default) value was given

      end; // with PRowCol^ do
    end; // for i := 0 to NumRows-1 do // First Pass

    //***** Second Pass: Calc Pixel Sizes (RelPixSizes) for all Relative Size Rows

    RelPixSizes := nil;
    N_CalcIntSizes ( RelSizes, NumRelSizes,
                     N_RectHeight( AInnerPixRect )-SumAbsPixSize, RelPixSizes );

    //***** Third Pass: Calc Pixel Y-Coords in LastPixY using RelPixSizes, LastPixY

    CurRelInd := 0; // index for RelPixSizes array

    for i := 0 to NumRows-1 do // Third Pass
    begin
      PixSize := LastPixY[i]; // Pix Size for Absolute Size Row or -1 for Relative Size Row

      if PixSize = -1 then // Relative Size Row
      begin
        PixSize := RelPixSizes[CurRelInd];
        Inc(CurRelInd);
      end;

      if i = 0 then // special case (first Row)
        LastPixY[i] := AInnerPixRect.Top + PixSize - 1
      else // i >= 1 (not first Row)
        LastPixY[i] := LastPixY[i-1] + PixSize;

    end; // for i := 0 to NumRows-1 do // Third Pass

  end; // with NGCont, PIDP()^ do
end; // procedure TN_UDTable.CalcCellSizes

//********************************************** TN_UDTable.SetTableSize ***
// Set Table Size (X,Y Dimensions) in Params of given AParType
//
procedure TN_UDTable.SetTableSize( AParType: TN_CompParType; ANewNX, ANewNY: integer );
var
  i, NBytes, CurNX, CurNY, MinNX, MinNY: integer;
  WrkCells: TK_RArray;
  PCTable: TN_PCTable;
begin
  if AParType = cptStatic then PCTable := PISP()
                          else PCTable := PIDP();
  with PCTable^ do
  begin
    CurNX := TaCols.ALength();
    CurNY := TaRows.ALength();

    if (ANewNX=CurNX) and (ANewNY=CurNY) then Exit; // nothing to do

    //***** Copy existing Cells to WrkCells

    WrkCells := K_RCreateByTypeName( 'TN_TaCell', ANewNX*ANewNY );
    MinNX := min( ANewNX, CurNX );
    MinNY := min( ANewNY, CurNY );
    NBytes := MinNX*SizeOf(TN_TaCell); // Num Bytes to copy in each Row

    for i := 0 to MinNY-1 do // along Rows to copy
      move( TACells.P(i*CurNX)^, WrkCells.P(i*ANewNX)^, NBytes );

    TACells.SetElemsFreeFlag(); // to prevent destroing child RArrays in Free method
    TACells.Free;
    TACells := WrkCells;
    TaCols.ASetLengthI( ANewNX );
    TaRows.ASetLengthI( ANewNY );
  end; // with PCTable^ do
end; // procedure TN_UDTable.SetTableSize

//********************************************** TN_UDTable.IncTableSize ***
// Increase (in Params of given AParType) Table Size (X,Y Dimensions)
// if current Table Size is less than given
//
procedure TN_UDTable.IncTableSize( AParType: TN_CompParType; ANX, ANY: integer );
var
  CurNumCols, CurNumRows: integer;
  PCTable: TN_PCTable;
begin
  if AParType = cptStatic then PCTable := PISP()
                          else PCTable := PIDP();
  with PCTable^ do
  begin
    CurNumCols := TaCols.ALength();
    CurNumRows := TaRows.ALength();

    SetTableSize( cptStatic, Max(CurNumCols, ANX), Max(CurNumRows, ANY) );
  end; // with PCTable^ do
end; // procedure TN_UDTable.IncTableSize

//******************************************** TN_UDTable.CorrectTableSize ***
// Check if in params of given AParType TaCells RArray has a proper number of
// elements and correct if needed (a precaution after incorrect manual editing)
//
procedure TN_UDTable.CorrectTableSize( AParType: TN_CompParType );
var
  CurNumCols, CurNumRows, CurNumCells: integer;
  PCTable: TN_PCTable;
begin
  if AParType = cptStatic then PCTable := PISP()
                          else PCTable := PIDP();
  with PCTable^ do
  begin
    CurNumCols  := TaCols.ALength();
    CurNumRows  := TaRows.ALength();
    CurNumCells := TaCells.ALength();
    if CurNumCells <> CurNumCols*CurNumRows then
      TaCells.ASetLengthI( CurNumCols*CurNumRows );
  end; // with PCTable^ do
end; // procedure TN_UDTable.CorrectTableSize

type TSrcType = ( stNotDef, stDouble, stString );

//******************************************** TN_UDTable.SetCellsBlocks ***
// Set Cells Blocks using Elements of TaSetBlocks RArray
//
procedure TN_UDTable.SetCellsBlocks();
var
  ielem, ix, iy, TaInd, SrcInd, SrcSize: integer;
  NumBlocks, TaNumCols, NumColsToSet, NumRowsToSet: integer;
  NumSrcCols, NumSrcRows, NumSrcRestCols, NumSrcRestRows: integer;
  PSrc: Pointer;
  SrcMatr, CompPar: TK_RArray;
  SrcType: TSrcType;
  DebElem: TN_TaSetBlock; // for debug
begin
  with PIDP()^ do
  begin

  NumBlocks := TaSetBlocks.ALength();
//  Exit; // debug

  for ielem := 0 to NumBlocks-1 do // along all Cells Blocks
  with TN_PTaSetBlock(TaSetBlocks.P(ielem))^ do
  begin
    //***** Possible SrcMatr types:
    // - RArray of Double (Vector or Matrix (HCol>0))
    // - RArray of String (Vector or Matrix (HCol>0))

    DebElem := TN_PTaSetBlock(TaSetBlocks.P(ielem))^; // debug

    if (TSBSrcComp = nil) or (tsbfSkip in TSBFlags) then Continue;
    CompPar := TSBSrcComp.DynPar;
    if CompPar = nil then CompPar := TSBSrcComp.R; // to enable using static data
    SrcMatr := N_GetUserParPtr( CompPar, TSBSrcUPName ).UPValue;
    if SrcMatr = nil then Continue;

    SrcSize := SrcMatr.ALength();
    NumSrcCols := SrcMatr.HCol + 1;
    NumSrcRows := SrcSize div NumSrcCols;

    NumSrcRestCols := NumSrcCols - TSBSrcBegCol;
    NumSrcRestRows := NumSrcRows - TSBSrcBegRow;

    NumColsToSet := TSBNumCols;
    if TSBTranspose = 0 then // do not Transpose
    begin
      if NumColsToSet <= 0 then
        NumColsToSet := NumColsToSet + NumSrcRestCols;

      if NumColsToSet > NumSrcRestCols then
        NumColsToSet := NumSrcRestCols;
    end else //**************** Transpose
    begin
      if NumColsToSet <= 0 then
        NumColsToSet := NumColsToSet + NumSrcRestRows;

      if NumColsToSet > NumSrcRestRows then
        NumColsToSet := NumSrcRestRows;
    end; // else //**************** Transpose

    NumRowsToSet := TSBNumRows;
    if TSBTranspose = 0 then // do not Transpose
    begin
      if NumRowsToSet <= 0 then
        NumRowsToSet := NumRowsToSet + NumSrcRestRows;

      if NumRowsToSet > NumSrcRestRows then
        NumRowsToSet := NumSrcRestRows;
    end else //**************** Transpose
    begin
      if NumRowsToSet <= 0 then
        NumRowsToSet := NumRowsToSet + NumSrcRestCols;

      if NumRowsToSet > NumSrcRestCols then
        NumRowsToSet := NumSrcRestCols;
    end; // else //**************** Transpose

    //***** Here: NumColsToSet and NumRowsToSet are OK

    IncTableSize( cptDynamic, TSBTaBegCol+NumColsToSet, TSBTaBegRow+NumRowsToSet );
    TaNumCols := TaCols.ALength();

    SrcType := stNotDef;
    if SrcMatr.ElemType.DTCode = Ord(nptDouble) then SrcType := stDouble
    else if SrcMatr.ElemType.DTCode = Ord(nptString) then SrcType := stString;

    Assert( SrcType <> stNotDef, 'Bad SrcType!' );

    for iy := 0 to NumRowsToSet-1 do // along all rows to Set
    for ix := 0 to NumColsToSet-1 do // along all columns to Set
    begin

      if TSBTranspose = 0 then // do not Transpose
        SrcInd := (TSBSrcBegCol+iy)*NumSrcCols + TSBSrcBegRow+ix
      else
        SrcInd := (TSBSrcBegCol+ix)*NumSrcCols + TSBSrcBegRow+iy;

      PSrc := SrcMatr.P( SrcInd );

      TaInd  := (TSBTaBegRow+iy)*TaNumCols  + TSBTaBegCol+ix;

      with TN_PTaCell(TaCells.P(TaInd))^ do
      begin
        if SrcType = stString then
        begin
          TCMText := PString(PSrc)^;
        end else if SrcType = stDouble then
        begin
          TCValue := PDouble(PSrc)^;
          TCMText := Format( TSBConvFmt, [TCValue] );
        end; // else if SrcType = stDouble then


      end; // with TN_PTaCell(TaCells.P(TaInd))^ do
    end; // for ix, for iy

  end; // for ielem := 0 to NumBlocks-1 do // along all Cells Blocks

  end; // with PIDP()^ do
end; // procedure TN_UDTable.SetCellsBlocks

//******************************************** TN_UDTable.DebCellsInit ***
// Debug Cells Initialization (in Static Params)
//
procedure TN_UDTable.DebCellsInit();
var
  ix, iy, NumCols, NumRows: integer;
begin
  with PISP()^ do
  begin

  CorrectTableSize( cptDynamic ); // a precaution after manual editing
  NumCols := TaCols.ALength();
  NumRows := TaRows.ALength();

  for iy := 0 to NumRows-1 do // along all rows
  for ix := 0 to NumCols-1 do // along all columns
  with TN_PTaCell(TaCells.P(iy*NumCols+ix))^ do
  begin
    TCMText := Format( 'Cell[%d,%d]', [iy,ix] );
  end; // with, for ix, for iy

  end; // with PISP()^ do
end; // procedure TN_UDTable.DebCellsInit


//********** TN_UDCompsGrid class methods  **************

//*************************************************** TN_UDCompsGrid.Create ***
//
constructor TN_UDCompsGrid.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDCompsGridCI;
  ImgInd := 59;
end; // end_of constructor TN_UDCompsGrid.Create

//************************************************** TN_UDCompsGrid.Destroy ***
//
destructor TN_UDCompsGrid.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDCompsGrid.Destroy

//****************************************************** TN_UDCompsGrid.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDCompsGrid.PSP(): TN_PRCompsGrid;
begin
  Result := TN_PRCompsGrid(R.P());
end; // end_of function TN_UDCompsGrid.PSP

//****************************************************** TN_UDCompsGrid.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDCompsGrid.PDP(): TN_PRCompsGrid;
begin
  if DynPar <> nil then Result := TN_PRCompsGrid(DynPar.P())
                   else Result := TN_PRCompsGrid(R.P());
end; // end_of function TN_UDCompsGrid.PDP

//***************************************************** TN_UDCompsGrid.PISP ***
// return typed pointer to Individual Static CompsGrid Params
//
function TN_UDCompsGrid.PISP(): TN_PCCompsGrid;
begin
  Result := @(TN_PRCompsGrid(R.P())^.CCompsGrid);
end; // function TN_UDCompsGrid.PISP

//***************************************************** TN_UDCompsGrid.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic CompsGrid Params
// otherwise return typed pointer to Individual Static CompsGrid Params
//
function TN_UDCompsGrid.PIDP(): TN_PCCompsGrid;
begin
  if DynPar <> nil then
    Result := @(TN_PRCompsGrid(DynPar.P())^.CCompsGrid)
  else
    Result := @(TN_PRCompsGrid(R.P())^.CCompsGrid);
end; // function TN_UDCompsGrid.PIDP

//*********************************************** TN_UDCompsGrid.PascalInit ***
// Init self
//
procedure TN_UDCompsGrid.PascalInit();
begin
  Inherited;

  with PISP()^ do // Two Columns Three Rows Grid
  begin
    CGRelColWidths  := K_RCreateByTypeCode( Ord(nptFloat), 2 );
    PFloat(CGRelColWidths.P(0))^ := 30;
    PFloat(CGRelColWidths.P(1))^ := 70;

    CGRelRowHeights := K_RCreateByTypeCode( Ord(nptFloat), 3 );
    PFloat(CGRelRowHeights.P(0))^ := 20;
    PFloat(CGRelRowHeights.P(1))^ := 40;
    PFloat(CGRelRowHeights.P(2))^ := 40;

    CGBorderWidth   := 1;
    CGBorderColor   := $000000;
    CGBackColor     := -1;
    CGCells := K_RCreateByTypeName( 'TN_CCompsGridCell', 6 );
  end; // with PISP()^ do
end; // procedure TN_UDCompsGrid.PascalInit

//********************************************* TN_UDCompsGrid.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDCompsGrid.BeforeAction();
var
  i, j, ind, NumCols, NumRows, BordWidth, AllCellsWidth, AllCellsHeight: integer;
  CurLeft, CurTop: integer;
  CellWidths, CellHeights: TN_IArray;
  BordLine: TRect;
  CellsRects: TN_IRArray;
  CurComp: TN_UDCompVis;
  PRCompD: TN_PRCompsGrid;

  procedure SetCCompCoords( APPCCompsGrid: TN_PRCompVis; APixCoords: TRect ); // local
  // set given APixCoords to Static or dynamic Params
  var
    ParentPixSize: TDPoint;
  begin
    with APPCCompsGrid^.CCoords do
    begin
      ParentPixSize := DPoint( N_RectSize( CompIntPixRect ) );

      BPCoords.X := 100 * (APixCoords.Left - CompIntPixRect.Left) / ParentPixSize.X;
      BPCoords.Y := 100 * (APixCoords.Top  - CompIntPixRect.Top)  / ParentPixSize.Y;
      BPXCoordsType := cbpPercent;
      BPYCoordsType := cbpPercent;

      LRCoords.X := 100 * (APixCoords.Right  - CompIntPixRect.Left) / ParentPixSize.X;
      LRCoords.Y := 100 * (APixCoords.Bottom - CompIntPixRect.Top)  / ParentPixSize.Y;
      LRXCoordsType := cbpPercent;
      LRYCoordsType := cbpPercent;

      SRSizeXType := cstNotGiven;
      SRSizeYType := cstNotGiven;
    end; // with APPCCompsGrid^.CCoords do
  end; // procedure SetCCompCoords // local

begin //***************************** main body of TN_UDCompsGrid.BeforeAction

//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with PRCompD^, PRCompD^.CCompsGrid, NGCont.DstOCanv do
  begin
    BordWidth := LLWToPix1( CGBorderWidth ); // all Borders Width in Pixels

    //***** Calc CellWidths, CellHeights arrays

    NumCols := CGRelColWidths.Alength();
    AllCellsWidth := CompIntPixRect.Right-CompIntPixRect.Left+1 - (NumCols+1)*BordWidth;
    SetLength( CellWidths, NumCols );
    N_SplitIntegerValue( PFloat(CGRelColWidths.P(0)), NumCols, AllCellsWidth, @CellWidths[0] );

    NumRows := CGRelRowHeights.Alength();
    AllCellsHeight := CompIntPixRect.Bottom-CompIntPixRect.Top+1 - (NumRows+1)*BordWidth;
    SetLength( CellHeights, NumRows );
    N_SplitIntegerValue( PFloat(CGRelRowHeights.P(0)), NumRows, AllCellsHeight, @CellHeights[0] );

    if NumRows*NumCols < CGCells.ALength() then // a precaution
      CGCells.ASetLength( NumRows*NumCols );

    SetLength( CellsRects, NumRows*NumCols );
    SetBrushAttribs( CGBorderColor );

    BordLine.Top    := CompIntPixRect.Top;
    BordLine.Bottom := CompIntPixRect.Bottom;
    CurLeft := CompIntPixRect.Left;

    for i := 0 to NumCols do // Draw all vertical borders (NumCols+1 lines)
    begin
      BordLine.Left := CurLeft;
      BordLine.Right := BordLine.Left + BordWidth - 1;

      if i < NumCols then // all Columns except last, fill all CellsRects.Left,Right and update CurLeft
      begin
        for j := 0 to NumRows-1 do // along all Rows in i-th Column
        begin
          ind := i + j*NumCols;
          CellsRects[ind].Left := BordLine.Right + 1;
          CellsRects[ind].Right := CellsRects[ind].Left + CellWidths[i] - 1;
        end; // for j := 0 to NumRows-1 do // along all Rows in i-th Column

        Inc( CurLeft, BordWidth+CellWidths[i] );
      end; // if i < NumCols then // all Columns except last

      DrawPixFilledRect( BordLine );
    end; // for i := 0 to NumCols+1 do // Draw all vertical borders

    BordLine.Left  := CompIntPixRect.Left;
    BordLine.Right := CompIntPixRect.Right;
    CurTop := CompIntPixRect.Top;

    for i := 0 to NumRows do // Draw all horizontal borders (NumRows+1 lines)
    begin
      BordLine.Top := CurTop;
      BordLine.Bottom := BordLine.Top + BordWidth - 1;

      if i < NumRows then // all Rows except last, fill all CellsRects.Top,Bottom and update CurTop
      begin
        for j := 0 to NumCols-1 do // along all Columns in i-th Row, fill CellsRects[ind].Top,Bottom
        begin
          ind := i*NumCols + j;
          CellsRects[ind].Top := BordLine.Bottom + 1;
          CellsRects[ind].Bottom := CellsRects[ind].Top + CellHeights[i] - 1;
        end; // for j := 0 to NumRows-1 do // along all Rows in i-th Column

        Inc( CurTop, BordWidth+CellHeights[i] );
      end; // if i < NumRows then // all Rows except last

      DrawPixFilledRect( BordLine );
    end; // for i := 0 to NumRows+1 do // Draw all horizontal borders

//  Exit; // debug

    for i := 0 to NumRows*NumCols-1 do // along all Grid Cells
    begin
      SetBrushAttribs( CGBackColor );
      DrawPixFilledRect( CellsRects[i] );

      CurComp := TN_PCCompsGridCell(CGCells.P(i))^.CGCComp;

      if CurComp <> nil then
      begin

        if cgfExecComps in CGFlags then // Execute (Draw) Cell's Component
        begin
          Self.CompIntPixRect := CellsRects[i]; // temporary, for CComp drawing
          CurComp.DynParent := Self;
          CurComp.NGCont := Self.NGCont;
          CurComp.ExecSubTree();
        end; // if cgfExecComps in CGFlags then // Execute (Draw) Cell's Component

        if cgfSetCompsPixCoords in CGFlags then // Set Cell's Component Pix Coords
        begin
          SetCCompCoords( CurComp.PSP(), CellsRects[i] );
          SetCCompCoords( CurComp.PDP(), CellsRects[i] );
        end; // if cgfSetCompsPixCoords in CGFlags then // Set Cell's Component Pix Coords

      end; // if CurComp <> nil then

    end; // for i := 0 to NumRows*NumCols-1 do // along all Grid Cells

  end; // PRCompD^, PRCompD^.CCompsGrid, NGCont.DstOCanv do
end; // end_of procedure TN_UDCompsGrid.BeforeAction



//****************** Global procedures **********************

//******************************************************** N_CreateUDSArrow ***
// Create UDSArrow with given Params
//
function N_CreateUDSArrow ( AObjName: string; AMinWidth, AMaxWidth,
                            AIntLeng, AExtLeng, APenWidth: float;
                            APenColor, AFillColor: integer ): TN_UDSArrow;
begin
  Result := TN_UDSArrow( K_CreateUDByRTypeName( 'TN_RSArrow',  1, N_UDSArrowCI ));
  Result.ObjName := AObjName;

  with Result.PISP()^ do
  begin
    SAWidths  := FPoint( AMinWidth, AMaxWidth );
    SALengths := FPoint( AIntLeng,  AExtLeng );
    SAAttribs := N_CreateContAttr1( AFillColor, APenColor, APenWidth );
  end; // with Result.PISP()^ do
end; // function N_CreateUDSArrow

//*********************************************************  N_InitLHStyle  ***
// Init Elements of given RArray of NFont type records
//
procedure N_InitLHStyle( ARA: TK_RArray; BegInd, NumInds: integer );
var
  i: integer;
begin
  if ARA = nil then Exit; // a precaution
//  N_s := K_GetExecTypeName( ARA.DType.All ); // debug
  if K_GetExecTypeName( ARA.ElemType.All ) <> 'TN_NFont' then Exit;  // a precaution

  for i := BegInd to BegInd+NumInds-1 do
    TN_PC2DLHStyle(ARA.P(i))^ := N_DefC2DLHStyle;
end; // procedure N_InitLHStyle

//************************************************* N_CreateTicsShapeCoords ***
//
//
procedure N_CreateTicsShapeCoords( AShape: TN_ShapeCoords; AVComp: TN_UDCompVis;
                                                       ATDSpace: TN_UD2DSpace );
//var
//  i: integer;
begin

end; // procedure N_CreateTicsShapeCoords

//***************************************************** N_CreateAutoAxis(2) ***
// Create AutoAxis using given A2DSpaceComp and APos
//
function N_CreateAutoAxis( A2DSpaceComp: TN_UD2DSpace; APos: TN_RelPos ): TN_UDAutoAxis;
//var
//  i: integer;
begin
  Result := TN_UDAutoAxis( K_CreateUDByRTypeName( 'TN_RAutoAxis',  1, N_UDAutoAxisCI ));

  with Result.PISP()^ do // initialize fields
  begin
    AALinePos.X := 8;
    AAArrowParams.Left  := 2;
    AAArrowParams.Top   := 4;
    AAArrowParams.Right := 4;

    AALineAttribs := K_RCreateByTypeName( 'TN_ContAttr', 1 );
    with TN_PContAttr(AALineAttribs.P())^ do
    begin
      CAPenWidth   := 0.8;
      CABrushColor := 0;
    end; // with TN_PContAttr(AALineAttribs.P())^ do

  end; // with Result.PISP()^ do // initialize fields

  if A2DSpaceComp = nil then Exit;

  with Result.PSP()^, Result.PCCS()^ do
  begin
    case APos of // Set AutoAxis Coords and Line Pos

    rpLefter: begin //
    end; // rpLefter

    rpUpper: begin //
    end; // rpUpper: begin //

    rpRighter: begin //
    end; // rpRighter

    rpLower: begin //
    end; // rpLower

    end; // case APos of // Set AutoAxis Coords and Line Pos

  end; // with Result.PSP()^, Result.PCCS()^ do

end; // function N_CreateN_CreateAutoAxis(2)

//*************************************************** N_CreateAutoAxis(Dlg) ***
// Create AutoAxis getting needed params in Dialogue
//
function N_CreateAutoAxis(): TN_UDAutoAxis;
//var
//  i: integer;
begin
  Result := N_CreateAutoAxis( nil, rpLefter );

end; // function N_CreateN_CreateAutoAxis(Dlg)

//****************************************************** N_PrepareConvCoefs ***
// Prepare Convertion Coefs used in TN_UDPolyline and TN_UDArc components
//
//     Parameters
// ACoordsType    - given Coords Type
// ABasePixRect   - given Base Pixel Rect used for cpctPix and cpctPercent Coords Types
// AU2PCoefs4     - given User To Pixel Convertion coefs used for cpctUser Coords Type
// AToPixCoefs4   - resulting convertion coefs. from given Coords Type to Buf Pixel Coords
// AFromPixCoefs4 - resulting convertion coefs. from Buf Pixel Coords to given Coords Type
//
procedure N_PrepareConvCoefs( ACoordsType: TN_CPCoordsType; ABasePixRect: TRect;
                              AU2PCoefs4: TN_AffCoefs4;
                              out AToPixCoefs4, AFromPixCoefs4: TN_AffCoefs4 );
var
  TmpFRect1, TmpFRect2: TFRect;
begin
  case ACoordsType of // Prepare AToPixCoefs4

  cpctPix: begin // Pixel Coords relative to UpperLeft corner of ABasePixRect
    AToPixCoefs4    := N_DefAffCoefs4;
    AToPixCoefs4.SX := ABasePixRect.Left;
    AToPixCoefs4.SY := ABasePixRect.Top;
  end;

  cpctUser: begin // User Coords
    AToPixCoefs4 := AU2PCoefs4;
  end;

  cpctPercent: begin // Percents of ABasePixRect ( (0,0) means UpperLeft corner )
    AToPixCoefs4 := N_CalcAffCoefs4( Rect(0,0,100,100), ABasePixRect );
  end;

  end; // case ACoordsType of // Prepare AToPixCoefs4

  //***** Here: AToPixCoefs4 is OK, calc AFromPixCoefs4

  TmpFRect1 := FRect( 0, 0, 10000.0, 10000.0 );
  TmpFRect2 := N_AffConvF2FRect( TmpFRect1, AToPixCoefs4 );
  AFromPixCoefs4 := N_CalcAffCoefs4( TmpFRect2, TmpFRect1 ); // backward transformation
end; // procedure N_PrepareConvCoefs

end.
