unit N_Lib2;
// low level types and pocedures based upon types,
// defined in K_UDT1, K_Script1 and some other files

// TN_SetParamInfo   = packed record // Info for Setting One Param (Old Comps)
// TN_EnvRectOp      = ( eroScale, eroOR, eroScaleOr );
// TN_ParseTreeData1 = record
// TN_RefName        = record // info about one Reference (see CalcRefsInOST method)
// TN_ScanDTreeObj   = class( TObject ) // Container of ProcOfObj used in ScanDTree
// TN_AuxLineFlags   = set of ( alfPanelBorder, alfSignBorder );
// TN_AuxLine        = packed record // Aux Line Coords and BegLine Point Attribs
// TN_OneUserParam   = packed record // One User Parameter                     Clone
// TN_TimeSeriesUP   = packed record // Time Series as User Parameter
// TN_CodeSpaceItem  = packed record // One CodeSpace Item
// TN_RAEditFlags    = set of ( raefCountUDRefs, raefNotCountUDRefs );
// TN_RArrayOfDouble = packed record // for constructing "ArrayOf TN_RArrayOfDouble" SPL type
// TN_FillColorAttr1 = packed record // Fill Color Attributes
// TN_HTMLTagParser  = class( TK_XMLTagParser ) //***** TN_HTMLTagParserS

// TN_LFStyle        = set of ( lfsBold, lfsItalic, lfsUnderline );
// TN_LogFont        = packed record   // Logical Font (TN_UDLogFont record type)
// TN_UDLogFont      = class( TK_UDRArray )     // one record of TN_LogFont type
// TN_LogFontRef     = packed record // Reference to UDLogFont and ScaleCoef
// TN_UDNFont        = class( TK_UDRArray )     // one record of TN_NFont type
// TN_UDText         = class( TK_UDRArray )     // UDRArray with one String fields

//  TN_PointAttr2Type   = ( patNotDef, patStrokeShape, patRoundRect, patEllipseFragm,
//  TN_PointAttr2Flags  = set of ( pafMinShape, pafMaxShape );
//  TN_StrokeShapeType  = ( sstMinus, sstPlus, sstDiagonals );
//  TN_PA2ArrowFlags    = set of ( paafRound );
//  TN_PA2PolyLineFlags = set of ( paplfSinglePath );
//  TN_PointAttr2       = packed record //***** Point Attributes #2
//  TN_PA2StrokeShape   = packed record // Stroke Shape Special params (patStrokeShape)
//  TN_PA2RoundRect     = packed record // Round Rect Special params (patRoundRect)
//  TN_PA2EllipseFragm  = packed record // Ellipse Arc Special params (patEllipseFragm)
//  TN_PA2RegPolyFragm  = packed record // Regular Polygon Arc Special params (patRegPolyFragm)
//  TN_PA2TextRow       = packed record // Text Row Special params (patTextRow)
//  TN_PA2Picture       = packed record // Picture Special params (patPicture)
//  TN_PA2Arrow         = packed record // Arrow Special params (patArrow)
//  TN_PA2PolyLine      = packed record // PolyLine Special params (patPolyLine)


interface
uses
  Windows, SysUtils, Classes, Controls, Forms, Dialogs, IniFiles, ExtCtrls,
  Graphics, Types,
  K_Types, K_CLib0, K_UDT1, K_UDT2, K_Script1, K_DCSpace, K_FrRaEdit,
  K_StBuf, K_SBuf,
  N_Types, N_Lib0, N_Lib1, N_Gra0, N_Gra1, N_Gra2, N_BaseF;

procedure N_IniGlobals ();

//type TN_GetSPLVarInfoObj  = procedure( AVarName: string; out AVarType: TK_ExprExtType;
//                                       out AVarPtr: Pointer ) of object;

//##/*
function  N_GetGlobVarAsString   ( AGetVarInfoObj: TK_MVGetVarInfoProc;
                                                 AGlobVarName: string ): string;
procedure N_GetGlobVarsAsStrings ( AGetVarInfoObj: TK_MVGetVarInfoProc;
                                   APFirstName: PString; ANumNames: integer;
                                   AResSL: TStringList; out ANumRows: integer );

function  N_ExpandBracketsInStr  ( AGetVarInfoObj: TK_MVGetVarInfoProc;
                                   ASrcStr: string; AResInfo: TN_BracketsInfo ): string;



type TN_RAFillStrType  = ( // Auto Strings generation Type
  fstFormatInt, // Format Given Numbers as Integers
  fstFormatDbl, // Format Given Numbers as Doubles
  fstCharCodes  // Format Given Numbers as Chars
);
type TN_RAFillStrFlags = Set Of ( // Auto Strings Filling Flags
fstAddAfter // Add AutoString aftre existing string
);

type TN_RAFillStrParams = packed record // Filling Records Array (TK_RArray) of String Parameters
  FSRFillType:  TN_RAFillStrType;  // auto generation type
  FSRFillFlags: TN_RAFillStrFlags; // filling Flags
  FSRReserved1: byte; // for alignment
  FSRReserved2: byte;
  FSRBegIndex:   integer; // first Index of Records Array Element to Fill
  FSRNumStrings: integer; // number of Records Array Elements to Fill
  FSRFormat:     string;  // Delphi Format String (for one Double or Integer value)
  FSRDValues: TK_RArray;  // source Double Values for Format convertion ((TK_RArray of Double)
end; // type TN_RAFillStrParams = packed record
type TN_PRAFillStrParams = ^TN_RAFillStrParams;

type TN_EnvRectOp = ( eroScale, eroOR, eroScaleOr );

type TN_ParseTreeData1 = record
  Ind:    integer;
  Dir:    TN_UDBase;
  Params: TN_UDBase;
end; // type TN_ParseTreeData1 = record
type TN_APDT1s = array of TN_ParseTreeData1;

type TN_CAction = packed record // Action Component Individual Params
  CAActNames: string;   // Action Names (Before, After, PrepRoot Action Names, registered by N_RegActionProc)
  CAFlags1:  integer;   // first flags
  CAColor1:  integer;   // first Color
  CAColor2:  integer;   // second Color

  CAStr1:    string;    // string #1  // Obsolete! Should be deleted after converting using CAStr to CAParStr!!!
  CAStr2:    string;    // string #2
  CAStr3:    string;    // string #3

  CAFName1:  string;    // File Name #1
  CAFName2:  string;    // File Name #2
  CAFName3:  string;    // File Name #3
  CAFName4:  string;    // File Name #4

  CAUDBase1: TN_UDBase; // UDBase #1
  CAUDBase2: TN_UDBase; // UDBase #2
  CAUDBase3: TN_UDBase; // UDBase #3
  CAUDBase4: TN_UDBase; // UDBase #4
  CAUDBase5: TN_UDBase; // UDBase #5

  CAParStr1: string;    // Params String #1
  CAParStr2: string;    // Params String #2
  CAParStr3: string;    // Params String #3
  CAParStr4: string;    // Params String #4
  CAParStr5: string;    // Params String #4

  CAIRect:   TRect;     // integer Rect Coords (Left, Top, Right, Bottom) (four ints)
  CAFRect:   TFRect;    // float Rect Coords (Left, Top, Right, Bottom) (four doubles)
  CAFont:    TObject;   // Text Font (VArray of TN_NFont)
  CAAux1:    TObject;   // any VArray #1 (VArrayOf Undef)
  CAAux2:    TObject;   // any VArray #2 (VArrayOf Undef)
  CAObj1:    TObject;   // any Pascal TObject #1 (could be created only in Static params!)
  CAObj2:    TObject;   // any Pascal TObject #2 (could be created only in Static params!)

  CAIntArray:    TK_RArray; // RArray of integer
  CADblArray:    TK_RArray; // RArray of double
  CAStrArray:    TK_RArray; // RArray of string
  CAUDBaseArray: TK_RArray; // RArray of UDBase
  CAFPArray:     TK_RArray; // RArray of TFPoint
  CADPArray:     TK_RArray; // RArray of TDPoint
  CAFloatArray:  TK_RArray; // RArray of Float
end; // type TN_CAction = packed record
type TN_PCAction = ^TN_CAction;

type TN_ActionProc  = procedure( APAction: TN_PCAction; AP1, AP2: Pointer );

//************************************************************ TN_ScanRefInfo ***
// Information about one IDB Object collected during
//
// Used in TN_ScanDTreeOb methods (CalcRefsInOST, CollectUObjInfo, ...) for collecting Info during IDB Objects Tree-walk.
//
type TN_ScanRefInfo = record
  SRIRefPath: string;      // Path to processed IDB Object
  SRIUDParent: TN_UDBase;  // Parent of processed IDB Object
  SRIUDChild: TN_UDBase;   // processed IDB Object
  SRIFieldName: string;    // user Data structure Field Name were reference to processed IDB Object is stored
end; // type TN_TN_ScanRefInfo = record
type TN_RefInfoArray = array of TN_ScanRefInfo;

//************************************************************ TN_ScanRefInfo ***
// Container of different IDB Subnet Tree-walk algorithms used in TN_UDBase.ScanSubTree
//
type TN_ScanDTreeObj = class( TObject )
  ActionIndex: integer; // Index of Action to perform
  IncValue: integer;    // Increment Value for CSCode
  NumNodes: integer;    // Number of Nodes in Owners SubTree
  NumRefs:  integer;    // number of elements in RefInfos Array
  NumErrors: integer;   // number of Error Nodes in Owners SubTree
  NumDeleted: integer;  // number of Deleted Objects
  NumChanged: integer;  // number of Changed Objects
  CSCode:    string;    // CSCode to set
  ResPointer: Pointer;  // resulting Pointer ( CSS for SetCSCode )
  ResPointers: TN_PArray; // resulting Pointers (while collecting pointers to some objects)
  ResSL:     TStringList; // Resulting Strings (collected while Scanning Subtree)
  RefInd: integer;           // Index by RefInfos Array
  RefInfos: TN_RefInfoArray; // info about references
  ParInt1: integer;    // Params Integer 1
  ParInt2: integer;    // Params Integer 2
  ParInt3: integer;    // Params Integer 3
  ParStr1: string;     // Params String 1
  ParStr2: string;     // Params String 2
  ParStr3: string;     // Params String 3
  ParUObj1: TN_UDBase; // Params UObj 1
  ParUObj2: TN_UDBase; // Params UObj 2
  ParUObj3: TN_UDBase; // Params UObj 3
  ResInt1: integer;    // Resulting Integer 1
  ResInt2: integer;    // Resulting Integer 2
  ResInt3: integer;    // Resulting Integer 3
  RAFieldFunc: TK_RATestFieldFunc; // Process RAField Func of Of Obj used in ScanUDRArrays

  function  GetRefInd        ( ARef: TN_UDBase ): integer;
  function  PrepareOST       ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  UnmarkOST        ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  CalcRefsInOST    ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  CheckRefsInOST   ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  ViewOST          ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  IncrementCSCodes ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  SetCSCode        ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  DelUnresolved    ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
//  function  ConvComponents   ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; FieldName: string = '' ): TK_ScanTreeResult;
  function  ChangeSetParams  ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  CollectUObjInfo  ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  CollectUObjStat  ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  ScanUDRArrays    ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
  function  ChangeUObjects1  ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;
  function  ChangeUObjects2  ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer; const FieldName: string = '' ): TK_ScanTreeResult;

  function  ViewClearRAFields( AUDRoot: TN_UDBase; RARoot: TK_RArray; var AField; AFieldType: TK_ExprExtType; AFieldName: string; AFieldPath: string; ARowInd: Integer ): TK_ScanTreeResult;
end; // type TN_ScanDTreeObj = class( TObject )

type TN_GlobObj2 = class( TObject ) // Global Object for N_Lib2 file
  public
    GO2VNodeFlags: TK_VNodeStateFlags;
    GO2NewSubObjMode: boolean; // Create new File or new SlideId while creating SubTree copy
    GO2PasteAfterCut: boolean; // used in InsChildFullCopy

  constructor Create ();
  destructor  Destroy; override;
  function  InsChildRef      ( UDParent : TN_UDBase; ChildInd : Integer;
                                          const SrcDE : TN_DirEntryPar ) : Boolean;
  function  InsChildFullCopy ( UDParent: TN_UDBase; ChildInd: Integer;
                                         const SrcDE: TN_DirEntryPar ): Boolean;
end; // type TN_GlobObj2 = class( TObject )
//##*/

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_AuxLineFlags
type TN_AuxLineFlags = set of ( // Auxiliary Line Draw Flags
  alfPanelBorder, // AuxLine should finish on Panel Border (EndPoint should be 
                  // inside Panel)
  alfSignBorder   // AuxLine should begin at Sign border (for Signs with 
                  // transparent interior)
);

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_AuxLine
type TN_AuxLine = packed record // Auxiliary Line  Coordinates and Start Point Attributes
  ALFlags: TN_AuxLineFlags; // Draw Flags
  ALCType: TN_CompCoordsType; // Coordinates Type
//##/*
  ALReserved1: byte;        // for alignment
  ALReserved2: byte;        // for alignment
//##*/
  ALColor:  integer;        // Color
  ALWidth: float;           // Width in LLW
  ALBPAttribs: TK_RArray;   // Start Point Attributes (RArray of TN_PointAttr1)
  ALNumPoints: integer;     // Number of Points (from 2 to 6)
  ALP1P2:   TFRect;         // First two points coords in percents of parent 
                            // Component Internal Pixel Rectangle 
                            // (CompIntPixRect)
  ALP3P4:   TFRect;         // Next  two points coords
  ALP5P6:   TFRect;         // Next  two points coords
end; // type TN_AuxLine = packed record
type TN_PAuxLine = ^TN_AuxLine;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_OneUserParam
type TN_OneUserParam = packed record // One User Parameter
  UPName:  string;    // User Parameter Name
  UPDescr: string;    // User Parameter Description
  UPValue: TK_RArray; // User Parameter Value
end; // type TN_OneUserParam = packed record
type TN_POneUserParam = ^TN_OneUserParam;

//##/*
type TN_TimeSeriesUP = packed record // Time Series as User Parameter
  TSArgValues:  TK_RArray; // Argument Values in Years (ArrayOf double)
  TSFuncValues: TK_RArray; // Function Values (ArrayOf double)
  TSRatings:    TK_RArray; // Item Ratings (>=1, ArrayOf double)
  TSTimePeriodTypes: TK_RArray; // Arg. Values Time Period Types (ArrayOf TK_TimePeriodType)

  TSNumDigits: integer;    // Number of digits after decimal point (Accuracy)
  TSVectorKey:  string;    // Source UDVector Key1 in Sclon Table
  TSItemKey:    string;    // UDVector Item Key1 in Sclon Table
end; // type TN_TimeSeriesUP = packed record
type TN_PTimeSeriesUP = ^TN_TimeSeriesUP;

type TN_CodeSpaceItem = packed record // One CodeSpace Item
  ItemCS: TK_UDDCSpace; // Items's CodeSpace
  ItemCode: string;     // Item Code in ItemCS
end; // type TN_CodeSpaceItem = packed record
type TN_PCodeSpaceItem = ^TN_CodeSpaceItem;

type TN_RAEditFlags = set of ( raefCountUDRefs, raefNotCountUDRefs );

type TN_RArrayOfDouble = packed record // for constructing "ArrayOf TN_RArrayOfDouble" SPL type
  V: TK_RArray;
end; // type TN_OneDouble = packed record

type TN_FillColorAttr1 = packed record // Fill Color Attributes
  FAMainColor:  integer;   // Main Fill Color
  FAParams:   TK_RArray;   // Additional Fill Color Params as RArray (if needed)
//  FAUDParams: TK_UDRArray; // Additional Fill Color Params as UDBase (if needed)
end; // type TN_FillColorAttr1 = packed record
type TN_PFillColorAttr1 = ^TN_FillColorAttr1;

type TN_HTMLTagParser = class( TK_XMLTagParser ) //***** TN_HTMLTagParserS
    StyleDelims   : string;
    constructor Create( SourceStr : string );
    function    ParseTag( var CurPos : Integer; AttrsList : TStrings ) : string; override;
end; //*** end of type TK_XMLTagParser = class( TObject )

type TN_LFStyle = set of ( lfsBold, lfsItalic, lfsUnderline  );
type TN_LFFlags = set of ( lffProofQuality, lffDraftQuality );

type TN_LogFont = packed record // Logical Font (TN_UDLogFont record type)
  LFType: integer;         // now only 0 - Windows Font
  LFHeight: float;         // Font height in LFH
  LFStyle: TN_LFStyle;     // Font Style (lfsBold, lfsItalic, lfsUnderline)
  LFFlags: TN_LFFlags;     // additional Font Flags
  LFReservedByte1: byte;   // reserved
  LFReservedByte2: byte;   // reserved
  LFNormWeight: integer;   // Normal Font Weight
  LFBoldWeight: integer;   // Bold   Font Weight
  LFFaceName: string;      // Font Face Name (less then 32 characters!)
  LFBaseLinePos: float;    // Base Line Shift = BaseLinePos*LFHeight
  LFSpaceWidthCoef: float; // SpaceWidth is LFHeight*LFSpaceWidthCoef
  LFnWidthCoef: float;     // letter 'n' Width is LFHeight*LFnWidthCoef
  LFHyphenWidthCoef: float; // Hyphen Width is LFHeight*LFnWidthCoef
  LFCharExtraSpace: float; // additional space size between characters in LFH
end; // type TN_LogFont = packed record
type TN_PLogFont = ^TN_LogFont;

type TN_UDLogFont = class( TK_UDRArray ) //*** record of TN_LogFont type
  SelfWinHandle: HFont;   // Windows GDI Font Handle, created by Self
  SelfPixHeight: integer; // Self Pix Size   with which SelfWinHandle was created
  SelfBLAngle:   integer; // Self BL Angle   (Escapement)  with which SelfWinHandle was created
  SelfCharAngle: integer; // Self Char Angle (Orientation) with which SelfWinHandle was created
  ScaleCoef:     double;  // Self Scale coef. (SetFont second parameter)
  constructor Create;  override;
  destructor  Destroy; override;
  procedure PascalInit      (); override;
  procedure ClearWinHandle  ();
  function  CalcPixHeight   ( OCanv: TN_OCanvas ): integer;
  procedure CreateWinHandle ( OCanv: TN_OCanvas; ABLAngle, ACharAngle: float );
  procedure SetFont         ( OCanv: TN_OCanvas; AScaleCoef: float = 1.0 ); overload;
  procedure SetFont         ( OCanv: TN_OCanvas;
                                 AScaleCoef, ABLAngle, ACharAngle: float ); overload;
end; // type TN_UDLogFont = class( TK_UDRArray )
type TN_PUDLogFont = ^TN_UDLogFont;

type TN_LogFontRef = packed record // Reference to UDLogFont and ScaleCoef
  LFRUDFont: TN_UDLogFont; // UDLogFont
  LFRFSCoef: float;        // Font Scale Coef
end; // type TN_LogFontRef = packed record
type TN_PLogFontRef = ^TN_LogFontRef;
//##*/

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_UDNFont
//************************************************************** TN_UDNFont ***
// IDB Object with Windows Font Attributes
//
// One or more records of TN_NFont type
//
type TN_UDNFont = class( TK_UDRArray )
//##/*
  constructor Create;  override;
  destructor  Destroy; override;
  procedure PascalInit   (); override;
//##*/
  constructor Create2( AHeight: float; AFaceName: string );
  procedure DeleteWinHandle ( AFontInd: integer = 0 );
end; // type TN_UDNFont = class( TK_UDRArray )
type TN_PUDNFont = ^TN_UDNFont;

{
type TN_UDText = class( TK_UDRArray ) //*** UDRArray with one String fields
  constructor Create; override;
  destructor  Destroy; override;
  procedure PascalInit (); override;
end; // type TN_UDText = class( TK_UDRArray )
type TN_PUDText = ^TN_UDText;
}

// TN_PointAttr2Type indexes are syncro to N_PA2SPTypes array elements !!!

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PointAttr2Type
type TN_PointAttr2Type = ( // Point Attributes Type enumeration
  patNotDef,       // type is not defined
  patStrokeShape,  // stroked shape
  patRoundRect,    // rectangle with rouned corners
  patEllipseFragm, // ellipse
  patRegPolyFragm, // Regular Polygon Fragment (PieSegm, Chord or ArcOnly)
  patTextRow,      // text
  patPicture,      // picture
  patArrow,        // arrow
  patPolyLine      // polyline
);

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PointAttr2
type TN_PointAttr2 = packed record // ***** Point Attributes #2
  PAType:  TN_PointAttr2Type;  // Point Attributes Type
  PAShape: TN_StandartShape;   // Set of Several Standart Sign Shapes
//##/*
  PAReserved1: Byte;  // for allignment
//##*/
  PABrushColor: integer; // brush color (not used in cross and rotated cross 
                         // Sign Shapes)
  PAPenColor:   integer; // pen color (used for all Sign Shapes)
  PAPenWidth:   float;   // border and cross lines Width in LLW
  PAPenStyle:   integer; // Windows Path drawing Flags
  PASizeXY:   TFPoint;   // sign Width and Heght (X,Y sizes) in LSU
  PAShiftXY:  TFPoint;   // sign X,Y shifts in LSU via Hot Point
  PAHotPoint: TFPoint;   // sign Hot Point position in Normalized Coordinates, 
                         // ((0,0)-UpperLeft corner, (0.5,0.5)-Center)
  PASP: TK_RArray;       // special parameters (different for different PAType)
end; // type TN_PointAttr2 = packed record
type TN_PPointAttr2 = ^TN_PointAttr2;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_StrokeShapeType
type TN_StrokeShapeType  = ( // Stroke Sign type
  sstPlus,     // cross (+)
  sstMinus,    // horisontal stroke (-)
  sstDiagonals // line rotate to some angle
);

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PA2StrokeShape
type TN_PA2StrokeShape = packed record // Stroke Shape Special parameters (patStrokeShape)
  PASSType: TN_StrokeShapeType; // Stroke Shape Type
  PASSAngle: float;             // Angle to rotate all Strokes
end; // type TN_PA2StrokeShape = packed record
type TN_PPA2StrokeShape = ^TN_PA2StrokeShape;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PA2RoundRect
type TN_PA2RoundRect = packed record // Round Rect Special parameters (patRoundRect)
  PAEllSizeXY: TFPoint; // Rounding Ellipse X,Y Sizes
end; // type TN_PA2RoundRect = packed record
type TN_PPA2RoundRect = ^TN_PA2RoundRect;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PA2EllipseFragm
type TN_PA2EllipseFragm = packed record // Ellipse Fragment Special parameters (patEllipseFragm)
  PAEBorderType: TN_ArcBorderType; // Shape Border Type
//##/*
  PAEReserved1: Byte;  // for allignment
  PAEReserved2: Byte;  // for allignment
  PAEReserved3: Byte;  // for allignment
//##*/
  PAEBegAngle: float; // Start Arc Angle (in Degree, counterclockwise in Pixel 
                      // coordinates)
  PAEArcAngle: float; // Arc Angle Value, 0 means 360 (in Degree)
end; // type TN_PA2EllipseFragm = packed record
type TN_PPA2EllipseFragm = ^TN_PA2EllipseFragm;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PA2RegPolyFragm
type TN_PA2RegPolyFragm = packed record // Regular Polygon Fragment Special parameters (patRegPolyFragm)
  PAPBorderType: TN_ArcBorderType; // Shape Border Type
//##/*
  PAPReserved1: Byte;  // for allignment
  PAPReserved2: Byte;  // for allignment
  PAPReserved3: Byte;  // for allignment
//##*/
  PAPBegAngle: float; // Start Arc Angle (in Degree, counterclockwise in Pixel 
                      // coords)
  PAPArcAngle: float; // Arc Angle Value, 0 means 360 (in Degree)
  PAPNumSegments: integer; // number of segments
end; // type TN_PA2RegPolyFragm = packed record
type TN_PPA2RegPolyFragm = ^TN_PA2RegPolyFragm;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PA2TextRow
type TN_PA2TextRow = packed record // Text Row Special parameters (patTextRow)
  PAText: string;       // TextRow Text
  PAFont: TN_UDLogFont; // Text Font Object
  PAFSCoef:    float;   // Font Scale Coefficient
  PATRAngle:   float;   // TextRow Base Line Angle in Degree in Clockwise 
                        // direction
  PACESpace:   float;   // Text Characters Extra Space in LSU
end; // type TN_PA2TextRow = packed record
type TN_PPA2TextRow = ^TN_PA2TextRow;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PA2Picture
type TN_PA2Picture = packed record // Picture Special parameters (patPicture)
  PAPict:  TN_UDBase; // refernce to ID object with picture (TN_UDPicture) 
                      // (TN_UDBase is used to avoid Delphi circular references)
  PAScaleCoef: float; // picture scale coefficient (if > 0 - use it instead of 
                      // PASizeXY)
  PAPictFragm: TRect; // rectangle fragment to show in pixels ( (0,-1) means 
                      // full size)
  PAMaintainAspect: byte; // maintain Picture Aspect flag (if <> 0 Picture 
                          // Aspect should be maintained)
end; // type TN_PA2Picture = packed record
type TN_PPA2Picture = ^TN_PA2Picture;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PA2ArrowFlags
type TN_PA2ArrowFlags    = set of ( // Sign Arrow Flags
 paafRound // Round edges flag
);

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PA2Arrow
type TN_PA2Arrow = packed record // Arrow Special parameters (patArrow)
  PAAFlags: TN_PA2ArrowFlags; // Arrow Flags
//##/*
  PAAReserved1: Byte; // for allignment
  PAAReserved2: Byte; // for allignment
  PAAReserved3: Byte; // for allignment
//##*/
  PAAIntWidth:  float; // Internal Arrow Width  in LSU
  PAAIntLength: float; // Internal Arrow Length in LSU
  PAAExtWidth:  float; // External Arrow Width  in LSU
  PAAExtLength: float; // External Arrow Length in LSU
  PAArrowAngle: float; // Arrow Base Line Angle in Degree in Clockwise direction
end; // type TN_PA2Arrow = packed record
type TN_PPA2Arrow = ^TN_PA2Arrow;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PA2PolyLineFlags
type TN_PA2PolyLineFlags = set of ( // Sign Polyline Flags
  paplfSinglePath // Single line path flag
);

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_PA2PolyLine
type TN_PA2PolyLine = packed record // PolyLine Special parameters (patPolyLine)
  PALFlags: TN_PA2PolyLineFlags; // PolyLine Flags
//##/*
  PALReserved1: Byte;
  PALReserved2: Byte;
  PALReserved3: Byte;
//##*/
  PALCObj: TN_UDBase; // refernece to IDB object Lines Coordinates container 
                      // (TN_ULines) (TN_UDBase is used to avoid Delphi circular
                      // references)
  PALBegItemToDraw:  integer; // Start Item Index to Draw
  PALNumItemsToDraw: integer; // Number of  Items to Draw (0 means all 
                              // subsequent Items)
end; // type TN_PA2PolyLine = packed record
type TN_PPA2PolyLine = ^TN_PA2PolyLine;


//************************ TN_ContAttr related Types *************************

//##/*
type TN_ExtContAttrFlags = Set Of ( ecafDummy1 );
//##*/

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_ExtContAttr
type TN_ExtContAttr = packed record // Extended Contour drawing Attributes (stroke and fill)
//##/*
  ECAFlags: TN_ExtContAttrFlags; // some additional flags
  ECAReserved1: byte;
  ECAReserved2: byte;
  ECAReserved3: byte;
//##*/
  ECAMiterLimit: float;     // Miter Limit
  ECAPenImage:   TN_UDBase; // reference to IDB Object with picture (used 
                            // instead of Pen Color)
  ECAPenHandle:    integer; // GDI Pen Handle (used instead of Pen Color)
  ECABrushImage: TN_UDBase; // reference to IDB Object with picture (used 
                            // instead of Brush Color)
  ECABrushHandle:  integer; // GDI Brush Handle
  ECABegOfs: float;         // Dash Offset (empty Dash) at Beg of Line
  ECAEndOfs: float;         // Dash Offset (empty Dash) at End of Line
end; // type TN_ExtContAttr = packed record
type TN_PExtContAttr = ^TN_ExtContAttr;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_ContAttrFlags
type TN_ContAttrFlags = Set Of ( // Contour General Flags set
  cafWidthInmm,     // line width in mm flag
//##/*
  cafOnlyColor,
  cafOnlyMono,
  cafWidthUnits,
//##*/
  cafSkipMainPath,  // skip main path flag
  cafPenStyleDashes // dashed style flag
);

type TN_MarkerFlags = Set Of ( // Contour Points Marker Flags set
  mafBegLine,       // draw contour line start vertex
  mafEndLine,       // draw contour line final vertex
  mafInternalVerts, // draw contour line internal vertecies
  mafStep,          // Step along FlatLine
//##/*
  mafRotateCS,
  mafWidthUnits,
//##*/
  mafSinglePath,    // single path flag (one Symbol for all Markers with Attributes of first Marker and coords of all Markers)

//##/*
  mafDummy1,
  mafDummy2
//##*/
);

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_ContAttr
type TN_ContAttr = packed record // Contour drawing Attributes (stroke and fill)
  CAFlags: TN_ContAttrFlags;     // Some General flags
  CAMarkerFlags: TN_MarkerFlags; // Some Marker Flags (two bytes)
  CADashUnits: TN_DashUnits;     // Dash Units ( duPenWidth, duLLW, dumm )
  CAPenColor:   integer;   // Pen Color
  CAPenWidth:   float;     // Pen Width (in LLW or in mm if cafWidthInmm flag)
  CAPenStyle:   integer;   // GDI Pen Style
  CABrushColor: integer;   // Brush Color
  CAOpacity:    float;     // Stroke and Fill Opacity (0-opaque, 
                           // 1.0-transparent)
  CADashSizes: TK_RArray;  // Measered Dashes Sizes (RArray of Float or nil if 
                           // not needed)
  CAMarkers:   TK_RArray;  // RArray of TN_PointAttr2 or nil if Markers are not 
                           // needed
  CAExtAttr:   TK_RArray;  // Extended Attributes (one record of TN_ExtContAttr)
                           // or nil
end; // type TN_ContAttr = packed record
type TN_PContAttr = ^TN_ContAttr;

//##/*
type TN_TRDataType = ( trdtText, trdtOpenBlock, trdtCloseBlock );

type TN_TRDataFlags = Set of ( trdfSubscript, trdfSuperScript );

type TN_TextRowData = packed record // TextRow Data (String, Attributes, Coords, Controls)
  TRDType: TN_TRDataType;   // TextRow Data Type
  TRDFlags: TN_TRDataFlags; // TextRow Data Flags
  TRDText:     string;    // TextRow Text
  TRDTextColor: integer;  // Text Color
  TRDBackColor: integer;  // Text Color
  TRDFont: TN_UDLogFont;  // Text Font
  TRDCESpace:   float;    // Text Characters Extra Space in LSU
  TRDULCords:   TFPoint;  // UpperLeft TextRow Float Pixel Coords
  TRDULSizes:   TFPoint;  // TextRow Float Pixel X,Y Sizes
end; // type TN_CTextRow = packed record
type TN_PTextRowData = ^TN_TextRowData;
//##*/

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_CurRAFrFieldInfo
type TN_CurRAFrFieldInfo = record // Information about Current Field in Records Array View/Edit Frame (RAFrame)
  CurFType: TK_ExprExtType; // Current Field Type
  CurFTypeName: string;     // Current Field Type Name
  CurPRArray: TK_PRArray;   // Pointer to Current Field if it is RArray, or nil 
                            // if not
end; // type TN_CurRAFrFieldInfo = record
type TN_PCurRAFrFieldInfo = ^TN_CurRAFrFieldInfo;

{
type TN_UDMem = class( TN_UDBase ) // just TN_BArray container
  SelfMem: TN_BArray;

  constructor Create;  override;
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( SBuf: TK_SerialTextBuf;
                           AShowFlags : Boolean = true ): Boolean; override;
  function  GetFieldsFromText ( SBuf: TK_SerialTextBuf ): Integer; override;
  procedure CopyFields ( SrcObj: TN_UDBase ); override;
  function  SameFields ( SrcObj: TN_UDBase; AFlags: integer ): boolean; override;

  procedure LoadStringsFromSelf ( AStrings: TStrings );
  function  LoadSelfFromMVFile  ( AFileName: string;
                                  AOpenFlags: TK_MVFOpenFlags = [];
                                  APasWord: string = '' ): boolean;
end; // type TN_UDMem = class( TN_UDBase )
}

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_MemTextFragms
//******************************************************** TN_MemTextFragms ***
// Named Text Fragments in Memory Object
//
// Objects are TStringLists with Fragments Strings content
// MTFragmsList[i]         - Name of i-th Fragment
// MTFragmsList.Objects[i] - TStringList wuth Content of i-th Fragment
//
type TN_MemTextFragms = class( TObject ) // Named Text Fragments in Memory
  MTFragmsList:   TStringList;       // List Of Named TStringLists with
                                     // Fragments content
  MTVFileName:    string;            // Expanded File Name (saved in
                                     // Self.AddFromVFile)
  MTCreateParams: TK_DFCreateParams; // Virtual File Create Parameters (saved in
                                     // Self.AddFromVFile)
  MTFIsWinIni:    boolean;           // is TRUE if Strings added by
                                     // Self.AddFragms are in Windows *.ini file
                                     // format, FALSE - added Strings are in own
                                     // format
//##/*
  constructor Create; overload;
  destructor  Destroy; override;
//##*/
  constructor CreateFromVFile( AVFileName: string ); overload;
  procedure Clear             ();
  function  AddFragm          ( AFragmName: string; AStrings: TStrings ): integer; overload;
  function  AddFragm          ( AFragmName: string; AStr: string ): integer; overload;
  function  FragmAddToStrings ( AFragmName: string; AStrings: TStrings ): integer;
  procedure SelfAddToStrings  ( AStrings: TStrings );
  procedure AddFragms         ( AStrings: TStrings );
  procedure SaveToVFile       ( AVFileName: string; const ACreateParams: TK_DFCreateParams ); overload;
  function  AddFromVFile      ( AVFileName: string; const APassword: AnsiString = '' ): Boolean;
end; // type TN_MemTextFragms = class( TObject ) // Named Text Fragments in Memory


//************************ Global Variables ****************************

// N_PA2SPTypes array is syncro to TN_PointAttr2Type-1 indexes !!!
var  N_PA2SPTypes: array [0..7] of string = ('TN_PA2StrokeShape', 'TN_PA2RoundRect',
          'TN_PA2EllipseFragm', 'TN_PA2RegPolyFragm', 'TN_PA2TextRow', 'TN_PA2Picture',
          'TN_PA2Arrow', 'TN_PA2PolyLine' );

  N_DefContAttr:       TK_RArray; // default Cont Attr, fill by LightBlue, always exist
  N_DefStrokeContAttr: TK_RArray; // default Cont Attr, do not fill, always exist
  N_GlobObj2: TN_GlobObj2; // Global Object for N_Lib2

//******************************  Global Procedures  ********************

function  N_PVAE   ( AVArray: TObject; AInd: integer ): Pointer;
procedure N_UDToRA ( var AVArray: TObject; AMDFlags: TK_MoveDataFlags );
procedure N_ReplaceChildren ( ASrcUD, ADstUD: TN_UDBase );
procedure N_CopyUDRArray1   ( ASrcUD, ADstUD: TK_UDRArray );
procedure N_GetCurRAFrFieldInfo ( ARAFrame: TK_FrameRAEdit; APInfo: TN_PCurRAFrFieldInfo );

//##/*
function  N_CreateUDFont ( AName, AFace: string; ASize: float; AStyle: TN_LFStyle = [] ): TN_UDLogFont;
function  N_SetUDFont ( AUDLogFont: TN_UDLogFont; AOCanv: TN_OCanvas; AScaleCoef: float = 1.0;
                        ABLAngle: float = 0; ACharAngle: float = 0 ): TN_UDLogFont;
//##*/
function  N_CreateRArrayNFont ( AHeight: float; AFaceName: string ): TK_RArray;
//function  N_CreateUDNFont     ( AObjName, AFaceName: string; AHeight: float ): TK_UDRArray;
procedure N_SetNFont      ( ANFont: TObject; AOCanv: TN_OCanvas; ABLAngle: float = 0; AFontInd: integer = 0 );
procedure N_DebSetNFont   ( AOCanv: TN_OCanvas; AFontSize: float; AFaceNum: integer; ABLAngle: float = 0 );
procedure N_DebDrawString ( AOCanv: TN_OCanvas; APixBasePoint: TPoint; AStr: string; AFontColor, AFontSize: integer );

//##/*
function  N_GetUDFontParams  ( AUDLogFont: TN_UDLogFont ): TN_PLogFont;
function  N_ScanOnlyOwners ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd: integer ): TK_ScanTreeResult;
function  N_ScanAllRefs    ( UDParent: TN_UDBase; var UDChild: TN_UDBase; ChildInd: integer ): TK_ScanTreeResult;

function  N_IncCSCode ( ACSS: TN_UDBase; ACSCode: string; AIncValue: integer ): string;
procedure N_IncCSCodesInUDBase  ( AUDBase: TN_UDBase; AIncValue: integer );
procedure N_SetCSCodeInUDBase   ( AUDBase: TN_UDBase; ACSCode: string; PCSS: PPointer = nil );
procedure N_IncCSCodesInSubTree ( ARoot: TN_UDBase; AIncValue: integer );
procedure N_SetCSCodeInSubTree  ( ARoot: TN_UDBase; ACSCode: string; PCSS: PPointer = nil );

procedure N_CopyFieldsExceptNames ( ASrcUDBase, ADstUDBase: TN_UDBase );
function  N_GetPointerByName ( AName: string ): Pointer;

function  N_CreateUniqueUObjName  ( AParentDir: TN_UDBase; AName: string ): string;
function  N_CreateUDBaseDir       ( AParentDir: TN_UDBase; ANewDirName: string ): TN_UDBase;
function  N_CreateUDBaseClone     ( AParentDir: TN_UDBase; ANewUObjName: string; ASrcUObj: TN_UDBase ): TN_UDBase;
function  N_CreateUniqueUDBaseDir ( AParentDir: TN_UDBase; ANewDirName: string ): TN_UDBase;
function  N_PrepUDBaseDir         ( AParentDir: TN_UDBase; ANewDirName: string ): TN_UDBase;
function  N_PrepUDBaseClone       ( AParentDir: TN_UDBase; ANewUObjName: string; ASrcUObj: TN_UDBase ): TN_UDBase;
procedure N_ReplaceChildRefs1   ( ASrcDir, ADstDir: TN_UDBase );
procedure N_ReplaceChildRefs2   ( ASrcDir, ADstDir: TN_UDBase );
function  N_CreateOneLevelClone ( ASrcRoot: TN_UDBase ): TN_UDBase;
function  N_CreateSubTreeClone  ( ASrcRoot: TN_UDBase ): TN_UDBase;
function  N_CreateSubTreeClone3 ( AParentDir: TN_UDBase; ANewUObjName: string; ASrcUObj: TN_UDBase ): TN_UDBase;
function  N_PrepSubTreeClone    ( AParentDir: TN_UDBase; ANewUObjName: string; ASrcUObj: TN_UDBase ): TN_UDBase;

function  N_ForceSingleInstance ( ACloneType: TN_UObjType; AVNode: TN_VNode ): TN_UDBase;

//##*/
function  N_SplitPath    ( const APath: string; out ARestOfPath: string ): string;
function  N_AddPath1     ( APath: string; AUObj: TN_UDBase ): string;
function  N_AddPath1s    ( APath, ALastName: string ): string;
function  N_CreatePath2  ( AParent, AChild: TN_UDBase ): string;
function  N_CreatePath3  ( APParent, AParent, AChild: TN_UDBase ): string;
function  N_CreatePath3s ( APParent, AParent, AChild: TN_UDBase; ALastName: string ): string;
//##/*
//function  N_GetUObjByName    ( AParent: TN_UDBase; AName: string ): TN_UDBase;
//function  N_GetUObj          ( AParent: TN_UDBase; AName: string ): TN_UDBase;
//##*/
function  N_GetUObjByPath ( ARoot: TN_UDBase; APath: string; AObjNameType : TK_UDObjNameType = K_ontObjName  ): TN_UDBase;
//function  N_DeleteUObjByPath ( Root: TN_UDBase; Path: string ): TN_UDBase;
//function  N_GetParamsByPath  ( Root: TN_UDBase; Path: string;
//                                           out ScalarName: string ): TN_UDBase;
//function  N_CreateUChild  ( ParentObj: TN_UDBase; ChildName: string ): TN_UDBase;
//function  N_CreateUPChild ( ParentObj: TN_UDBase; ChildName: string;
//                                  out ChildParams: TN_UDBase ): TN_UDBase;
procedure N_AddUChild     ( AParentObj, AChildObj: TN_UDBase; AChildName: string );
//function  N_AddUPChild    ( ParentObj, ChildObj: TN_UDBase;
//                                      ChildName: string ): TN_UDBase;
//procedure N_RenameUChild  ( ParentObj, ChildObj: TN_UDBase; ChildName: string );
//function  N_CreateUParams ( ParentObj: TN_UDBase ): TN_UDBase;

function  N_SaveUObjToString ( ARootUObj: TN_UDBase ): string;
function  N_SaveUObjToMem    ( ARootUObj: TN_UDBase; out APBuf: Pointer ): Integer;
function  N_LoadUObjFromMem  ( APData: Pointer; ADataLength: Integer; APErrCode: PInteger = nil ): TN_UDBase;

function  N_SaveUObjAsText ( ARootUObj: TN_UDBase; AFileName: string ): boolean; overload;
//##/*
function  N_SaveUObjAsText ( AParentDir: TN_UDBase; AUObjName, AFileName: string ): boolean; overload;
//##*/

function  N_SaveUObjAsBin  ( ARootUObj: TN_UDBase; AFileName: string ): boolean; overload;
function  N_SaveUObjAsBin  ( AParentDir: TN_UDBase; AUObjName, AFileName: string ): boolean; overload;

function  N_LoadUObjFromText ( AFileName: string ): TN_UDBase;
function  N_LoadUObjFromBin  ( AFileName: string ): TN_UDBase;

function  N_LoadUObjFromAny ( AFileName: string ): TN_UDBase; overload;
//##/*
function  N_LoadUObjFromAny ( AParentDir: TN_UDBase; AUObjName, AFileName: string ): TN_UDBase; overload;

procedure N_SaveUChildsAsText   ( ARootUObj: TN_UDBase; AFileName: string );
procedure N_SaveUChildsAsBin    ( ARootUObj: TN_UDBase; AFileName: string );

procedure N_LoadUChildsFromText ( RootUObj: TN_UDBase; FileName: string );
procedure N_LoadUChildsFromBin  ( RootUObj: TN_UDBase; FileName: string );
procedure N_LoadUChildsFromAny  ( RootUObj: TN_UDBase; FileName: string );

procedure N_UObjNamesToStrings  ( RootUObj: TN_UDBase; Strings: TStrings );
procedure N_DTreeNamesToStrings ( RootUObj: TN_UDBase; Strings: TStrings;
                                                           Mode: integer );

procedure N_DeleteUObjByInds  ( AUObjDir: TN_UDBase; AIndexes: TN_IArray );
procedure N_DeleteAllUObjects ( AUObjDir: TN_UDBase );
procedure N_CopyCObjects ( InpCObjDir, OutCObjDir: TN_UDBase; Indexes: TN_IArray);
procedure N_MoveCObjects ( InpCObjDir, OutCObjDir: TN_UDBase; Indexes: TN_IArray);
//##*/
//function  N_CopyUDRArrayField   ( AFlags: integer;
//                                  ASrcUObj: TN_UDBase; ASrcPath: string;
//                                  ADstUObj: TN_UDBase; ADstPath: string ): boolean;
//function  N_ExecuteSetParams  ( AUDSetParams: TN_UDBase ): boolean;
//##/*
function  N_GetReverseRefPath ( AUObj: TN_UDBase; IncSelf: boolean = True ): string;
function  N_GetOSTSize        ( ARoot: TN_UDBase ): integer;
//##*/
function  N_CreateArrayOfUDBase ( AVNodesList: TList ): TN_UDArray;
function  N_SameDTCodes ( const ADTCode1, ADTCode2: TK_ExprExtType ): boolean;
function  N_GetRAFieldInfo( ARArray: TK_RArray; AFieldPath: string; out AFieldType: TK_ExprExtType; out AFieldPtr: Pointer ): integer;
function  N_SetUDRArraysField ( const ASrcData; APFirst: TN_PUDBase; ANumUDRArrays: integer; AFieldPath: string;
                                AFieldTypeCode : TK_ExprExtType; APUpValsInfo: TN_PUpdateValsInfo ): integer;
//##/*
function  N_GetUDRefsRArray ( ARootObj: TObject; AClassInd: integer ): TK_RArray;
procedure N_FillNumRArray ( var ARArray: TK_RArray; APParams: TN_PRAFillNumParams );
procedure N_FillColRArray ( var ARArray: TK_RArray; APParams: TN_PRAFillColParams );
procedure N_FillStrRArray ( var ARArray: TK_RArray; APParams: TN_PRAFillStrParams );
procedure N_Fill2DRArray  ( var ARArray: TK_RArray; APParams: TN_P2DRAFillNumParams );
function  N_CSItemAsStr   ( APCSItem: TN_PCodeSpaceItem ): string;
function  N_CSIntCodeName ( ACode: integer; ACodeSpace: TK_UDDCSpace ): string;
//##*/
function  N_GetRAFlags    ( ASPLTypeCode: TK_ExprExtType ): TN_RAEditFlags;
function  N_GetSPLTypeCode( ARAFlags: TN_RAEditFlags; ATypeName: string ): TK_ExprExtType;
function  N_IsRArray      ( ATypeName: string ): boolean;
function  N_MatrElem      ( AMatr: TK_RArray; AIndX, AIndY: integer ): double;
procedure N_CalcIntSizes  ( ARelCoefs: TN_FArray; ANumSizes, AFullIntSize: integer; var AOutIntSizes: TN_IArray );

procedure N_InitAuxLine   ( ARA: TK_RArray; ABegInd, ANumInds: integer );
procedure N_InitExpParams ( ARA: TK_RArray; ABegInd, ANumInds: integer );
procedure N_InitContAttr  ( ARA: TK_RArray; ABegInd, ANumInds: integer );
procedure N_InitNFont     ( ARA: TK_RArray; ABegInd, ANumInds: integer );

procedure N_PrepRArray    ( var ARArray: TK_RArray; ANumElems: integer; ATypeName: string );
procedure N_PrepCAArray   ( var ACAArray: TK_RArray; ANumElems: integer );
function  N_PrepContAttr  ( var AContAttr: TK_RArray ): TN_PContAttr;
procedure N_FillContAttr1 ( var AContAttr: TK_RArray; ABrushColor, APenColor: integer; APenWidth: float );
function  N_CreateContAttr1 ( ABrushColor, APenColor: integer; APenWidth: float ): TK_RArray;
procedure N_AssignRArray  ( var ADstRA: TK_RArray; ASrcRA: TK_RArray );
function  N_GetNumElemes  ( ASrcRA: TK_RArray; ASrcInd: integer; var ADstRA: TK_RArray;
                            ADstInd, ANumElems: integer; AElemsTypeName: string = '' ): integer;
procedure N_AddRArrayInfo  ( ARA: TK_RArray; AStrings: TStrings );
procedure N_RegActionProc  ( AProcName: string; AnActionProc: TN_ActionProc );
function  N_GetPVArrayData ( AVArray: TObject ): Pointer;
function  N_SelectUDBase   ( ADefUDBase: TN_UDBase; ACaption: string ): TN_UDBase;
procedure N_SetNodeWasChanged_NotUsed ( ANode: TN_UDBase );
procedure N_SetChildsWereChanged  ( AParent: TN_UDBase );
procedure N_SetSubTreeWasChanged  ( ARoot: TN_UDBase );
procedure N_LoadTImage   ( AImage: TImage; AVFileName: string; ATranspBMP: boolean );
//##/*
procedure N_AddNumRArray ( ARArray: TK_RArray; ANumVals: integer; AStrings: TStrings );
//##*/
function  N_RootIsOwner  ( AUObj, ARoot: TN_UDBase ): boolean;
function  N_GetUObjPath  ( AUObj, ARoot: TN_UDBase; AMaxSize: integer;
                                         APathFlags: TN_UObjPathFlags ): string;
function  N_GetPathFlags ( AGetInfoFlags: TN_GetInfoFlags ): TN_UObjPathFlags;
function  N_GetUnresRefsInfo  ( ASL: TStrings; ARoot: TN_UDBase; AFlags: TN_GetInfoFlags ): integer;
procedure N_GetExtUObjects    ( ASL: TStrings; ARoot: TN_UDBase; AFlags: TN_GetInfoFlags );
function  N_GetRefsToUObj     ( ASL: TStrings; AUObj, ARoot: TN_UDBase; AScanFlags: TK_UDTreeChildsScanFlags;
                                              AFlags: TN_GetInfoFlags ): integer;
procedure N_GetRefsFromSubTree( ASL: TStrings; ARoot: TN_UDBase; AFlags: TN_GetInfoFlags );
procedure N_GetRefsBetween    ( ASL: TStrings; ASrcRoot, ADstRoot: TN_UDBase; AFlags: TN_GetInfoFlags );
//##/*
function  N_ConvUObjects ( ASrcUObjDir, ADstUObjDir, AMapRoot: TN_UDBase; AFunc: TN_ConvDPFuncObj;
                           APAuxPar: Pointer; AScaleCoef: float; APInfoStr: PString = nil ): integer;
procedure N_IAddSPL ( const ASPLVar; APrefix: string; ASPLTCode: integer );
//##*/
function  N_ArchDFilesDir (): string;
function  N_ArchDFilesUniqueName ( AInitialName: string ): string;

procedure N_PlaceTwoSplittedControls( AControl1, AControl2, AParentControl: TWinControl;
                                 var ASplitter: TSPlitter; ASpOrientation: TN_Orientation;
                                 ASplitterCoef: float; ASplitterSize: integer ); // overload;

procedure N_ShowSpeedTestResults ( LegendText: string; T1, T2: double;
                                                           NTimes: integer );

//##/*
function  N_Int2EET ( ADTCode: integer ): TK_ExprExtType;
//##*/


//******************** Global Objects ******************************

var
  N_ActionProcs: THashedStringList;

     //*** dummy objects, that can be used to avoid warnings and for debug
  N_UD, N_UD1, N_UD2: TN_UDBase;
  N_RA, N_RA1, N_RA2: TK_RArray;
  N_ET, N_ET1, N_ET2: TK_ExprExtType;
  N_CA, N_CA1, N_CA2: TN_ContAttr;
  N_SPLT: TK_ExprExtType;


const
//      Map Layer Type possible values:
  N_SLines1    = 'Lines1';    // simple Lines
  N_SSysLines1 = 'SysLines1'; // SysLines (Lines with vertexes)
  N_SContours1 = 'Contours1'; // simple Contours
  N_SPoints1   = 'Points1';   // simple Points

//     used in N_DeleteChildsBeforeExport and N_CreateChildsAfterImport
  N_SReferenceTo = 'ReferenceTo';
  N_SDeleteChild = 'DeleteChild';

//      others
  N_SUntitled = 'Untitled'; // new object was created whithout file name
  N_SDefault  = 'Default';  // Default element in any Dir


var //********** SPL Type Codes ( set in N_Lib2 procedure N_IniGlobals() ):
  N_SPLTC_Bool1:          integer;
  N_SPLTC_Boolean4:       integer;
//  N_SPLTC_Boolean4:       TK_ExprExtType;
  N_SPLTC_CPanel:         integer;
  N_SPLTC_MEDebFlags:     integer;
  N_SPLTC_MEWordFlags:    integer;
  N_SPLTC_MEWordPSMode:   integer;
  N_SPLTC_NFont:          integer;
  N_SPLTC_RecompFlags:    integer;
  N_SPLTC_SDTUnloadFlags: integer;
  N_SPLTC_RFCoordsState:  integer;
  N_SPLTC_OneTextBlock:   integer;
  N_SPLTC_LCInfo:         integer;
//  N_SPLTC_PCFlags:        integer;
  N_SPLTC_UDDIBFlags:     integer;
  N_SPLTC_SLSRoot:        integer;
  N_SPLTC_RDIB:           integer;
  N_SPLTC_RDIBN:          integer;

implementation
uses Math, StrUtils, // Printers,
     K_UDC, K_Arch, K_IWatch,
     K_UDConst, K_SParse1, K_FSelectUDB, // K_FMVMSOExp,
     N_ClassRef, N_PlainEdF, N_MsgDialF, N_InfoF, N_GS1, N_ME1,
     N_CompBase, N_GCont, N_CompCL, N_Comp1, N_UDCmap, N_2DFunc1, N_NVTreeFr,
     N_UDat4, N_Deb1;

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_IniGlobals
//************************************************************ N_IniGlobals ***
// Application Graphic Context Initialization
//
// Is always called from K_TreeIniGlobals for all Projects
//
procedure N_IniGlobals();
var
  i, PCInd, MaxPCInd, ir, ig, ib, ColorR, ColorG, ColorB: integer;
  NumChanels: integer;
  Str, ErrInfo: string;
  SL: TStringList;
  LCInfo: TN_LogChannelInfo;
//  WrkAreaRect : TRect;
begin
  //***** Set Windows version
  N_PlatformInfo( nil, 0 );

  //***** Set needed GDI modes

//  N_SetFontSmoothing( True );
//  N_SetFontSmoothing( False );

  //***** GDI modes are OK, Initialize N_SysColors

  SetLength( N_SysColors, 3 ); //***** Set three System Color palettes
  SetLength( N_SysColors[0], 125 ); // 5**3 Light Colors

  for ib := 0 to 4 do
  begin
    i := (1 + 2*ib) mod 5; // i = 1, 3, 0, 2, 4
    ColorB := $7F + i*$20;

    for ig := 0 to 4 do
    begin
      i := (1 + 2*ig) mod 5; // i = 1, 3, 0, 2, 4
      ColorG := (ColorB shl 8) + $7F + i*$20;

      for ir := 0 to 4 do
      begin
        i := (1 + 2*ir) mod 5; // i = 1, 3, 0, 2, 4
        ColorR := (ColorG shl 8) + $7F + i*$20;
        N_SysColors[0][ib + 5*ig + 25*ir] := ColorR;

      end; // for ir := 0 to 4 do
    end; // for ig := 0 to 4 do
  end; // for ir := 0 to 4 do

  SetLength( N_SysColors[1], 8 ); // Eight different dark colors
  N_SysColors[1][0] := $000000; N_SysColors[0][1] := $800000;
  N_SysColors[1][2] := $008000; N_SysColors[0][3] := $808000;
  N_SysColors[1][4] := $000080; N_SysColors[0][5] := $800080;
  N_SysColors[1][6] := $008080; N_SysColors[0][7] := $505050;

  SetLength( N_SysColors[2], 256 ); // for debug
  N_CreateTestColors( fctAnyIndependant, 0, 0, @N_SysColors[2,0], Length(N_SysColors[2]) );

  //***** N_SysColors are OK, initialize SPL Type Codes

  N_SPLTC_Bool1          := K_GetTypeCodeSafe( 'Bool1' ).DTCode;
  N_SPLTC_Boolean4       := K_GetTypeCodeSafe( 'TN_Boolean4' ).DTCode;
  N_SPLTC_CPanel         := K_GetTypeCodeSafe( 'TN_CPanel' ).DTCode;
  N_SPLTC_MEDebFlags     := K_GetTypeCodeSafe( 'TN_MEDebFlags' ).DTCode;
  N_SPLTC_MEWordFlags    := K_GetTypeCodeSafe( 'TN_MEWordFlags' ).DTCode;
  N_SPLTC_MEWordPSMode   := K_GetTypeCodeSafe( 'TN_MEWordPSMode' ).DTCode;
  N_SPLTC_NFont          := K_GetTypeCodeSafe( 'TN_NFont' ).DTCode;
  N_SPLTC_RecompFlags    := K_GetTypeCodeSafe( 'TK_RecompileGSPLFlags' ).DTCode;
  N_SPLTC_SDTUnloadFlags := K_GetTypeCodeSafe( 'TK_TextModeFlags' ).DTCode;
  N_SPLTC_RFCoordsState  := K_GetTypeCodeSafe( 'TN_RFCoordsState' ).DTCode;
  N_SPLTC_OneTextBlock   := K_GetTypeCodeSafe( 'TN_OneTextBlock' ).DTCode;
  N_SPLTC_LCInfo         := K_GetTypeCodeSafe( 'TN_LogChannelInfo' ).DTCode;
  N_SPLTC_UDDIBFlags     := K_GetTypeCodeSafe( 'TN_UDDIBFlags' ).DTCode;
  N_SPLTC_SLSRoot        := K_GetTypeCodeSafe( 'TK_SLSRoot' ).DTCode;
  N_SPLTC_RDIB           := K_GetTypeCodeSafe( 'TN_RDIB' ).DTCode;
  N_SPLTC_RDIBN          := K_GetTypeCodeSafe( 'TN_RDIBN' ).DTCode;

  //***** SPL Types are OK, Set Global flags and other N_MEGlobObj fields

  with N_MEGlobObj do
  begin
    MEDebFlags := [];
    N_MemIniToSPLVal( 'GlobalFlags', 'MEDebFlags',  MEDebFlags,  N_SPLTC_MEDebFlags );
//    if medfProtocolToFile in MEDebFlags then N_DebGroups[0].DSInd := 0;
    if medfInfoWatch in MEDebFlags then K_InfoWatch.WatchMax := 200
                                   else K_InfoWatch.WatchMax := 0;

    MERecompFlags := [];
    N_MemIniToSPLVal( 'GlobalFlags', 'RecompFlags',    MERecompFlags,   N_SPLTC_RecompFlags );
    N_MemIniToSPLVal( 'GlobalFlags', 'SDTUnloadFlags', K_TextModeFlags, N_SPLTC_SDTUnloadFlags );

    MEDefScrResDPI := N_MemIniToDbl( 'User_Interface', 'DefScreenResDPI',  100 );
    MEDefPrnResDPI := N_MemIniToDbl( 'User_Interface', 'DefPrinterResDPI', 300 );
    MEScrResCoef   := N_MemIniToDbl( 'User_Interface', 'ScreenResCoef',    1.5 );
  end;

  //***** Global flags are set,  initialize Language specific strings (temporary variant)
  N_InitGSArray();

  //***** Initialize N_LogChannels - Array of Log Channels
  SL := TStringlist.Create();
  N_ReadMemIniSection( 'LogChannels', SL );
  MaxPCInd := -1;

  for i := 0 to SL.Count-1 do // find Max Channel Index
  begin
    Str := SL.Names[i];
    PCInd := N_ScanInteger( Str );
    if PCInd = N_NotAnInteger then Continue;
    if PCInd > MaxPCInd then MaxPCInd := PCInd;
  end;

  NumChanels := MaxPCInd+1;
  SetLength( N_LogChannels, NumChanels );
  if NumChanels >= 1 then
    FillChar( N_LogChannels[0], NumChanels*SizeOf(TN_LogChannel), 0 );

  for i := 0 to SL.Count-1 do // each i=... String contains info about i-th Channel:
  begin                       // Chanel Index followed by TN_LogChannelInfo fields
    Str := SL.Names[i];
    PCInd := N_ScanInteger( Str );
    if PCInd = N_NotAnInteger then Continue;

    if PCInd >= 0 then // Init PCInd Log channel
    begin
      FillChar( LCInfo, SizeOf(LCInfo), 0 );
      ErrInfo := K_SPLValueFromString( LCInfo, N_SPLTC_LCInfo, SL.ValueFromIndex[i] );
      if ErrInfo <> '' then
        raise Exception.Create( 'K_SPLValueFromString error'#13#10 +
                                     ErrInfo + #13#10 + SL.ValueFromIndex[i] );

      with N_LogChannels[PCInd] do
      begin
        LCFlags      := LCInfo.LCIFlags;
        LCFName      := LCInfo.LCIFName;
        LCSecondCInd := LCInfo.LCISecondCInd;
        LCTimeShift  := 0;
//        LCTimeShift := 11.0/(24*60*60); // 11 seconds shift (debug)
        LCWrapSize   := 240;
      end;

      N_LCExecAction( PCInd, lcaSetBufSize, LCInfo.LCIBufSize );
    end; // if PCInd >= 0 then // Init PCInd Log channel

  end; // for i := 0 to SL.Count-1 do // each i=... String contains info about i-th Channel

  SL.Free;

  //***** N_LogChannels are OK, Initialize List of SPL Units TN_IndIterator objects

  N_SPLIndIterators := TStringList.Create;
  N_SPLIndIterators.Sorted := True;
  N_SPLIndIterators.CaseSensitive := False;

  N_TerminateSelfProcObj := N_GlobObj.TerminateSelf;
end; // procedure N_IniGlobals

//**************************************************** N_GetGlobVarAsString ***
// Return content of given Global Variable
//
// AGetVarInfoObj - ProcOfObj for getting Info about Global Variable
//
function N_GetGlobVarAsString( AGetVarInfoObj: TK_MVGetVarInfoProc;
                                               AGlobVarName: string ): string;
var
  PValue: Pointer;
  VType: TK_ExprExtType;
begin
  if Assigned(AGetVarInfoObj) then
  begin
    AGetVarInfoObj( AGlobVarName, PValue, VType.All );
    Result := '';
    if PValue <> nil then
      Result := K_SPLValueToString( PValue^, VType );
  end else
    Result := '(??' + AGlobVarName + '??)';
end; // function N_GetGlobVarAsString

//************************************************** N_GetGlobVarsAsStrings ***
// Get elems of given Global Var Names (Arrays of Strings) into given AResSL TStringList
// AResSL elems should be ordered by Rows (first elemes of all Arrays, second
// elems and so on)
//
// AGetVarInfoObj - ProcOfObj for getting Info about Global Variable
// APFirstName    - Pointer to First SPL Variable Name
// ANumNames      - Number of SPL Variables Names
// AResSL         - Resulting StringList with Variables (Arrays of Strings) elems
// ANumRows       - Number of Table Rows (Size of all Arrays, on output)
//
procedure N_GetGlobVarsAsStrings( AGetVarInfoObj: TK_MVGetVarInfoProc;
                                  APFirstName: PString; ANumNames: integer;
                                  AResSL: TStringList; out ANumRows: integer );
var
  i, j, ix, iy, Count: Integer;
  RAFlag: Boolean;
  CStr:   string;
  PCurName: PString;
  PValue: Pointer;
  VType:  TK_ExprExtType;
  VTypes:  TK_EETArray;
  PValues: TN_PArray;
  SValues: TN_SArray;
  RA:     TK_RArray;
begin
  AResSL.Clear;

  if not Assigned(AGetVarInfoObj) then
  begin
{ // temporary!
    if APFirstName^ = 'StatTest1' then // Stat Test1 (Karasev)
      ANumRows := N_TstStatTest1( AResSL )
    else if APFirstName^ = 'StatTest2' then // Stat Test2 (Karasev)
      ANumRows := N_TstStatTest2( AResSL )
    else // simple Test
}
    begin
      ANumRows := 4;

      for iy := 0 to ANumRows-1 do
      begin
        PCurName := APFirstName;
        for ix := 0 to ANumNames-1 do
        begin
          AResSL.Add( PCurName^ + '_' + IntToStr(iy+1) );
          Inc( PCurName );
        end;
      end;
    end; // else // simple Test

    Exit;
  end; // if not Assigned(AGetVarInfoObj) then

  SetLength( VTypes,  ANumNames );
  SetLength( PValues, ANumNames );
  SetLength( SValues, ANumNames );

  //*** Parse Varaibles
  Count := MaxInt;
  for i := 0 to ANumNames - 1 do
  begin
    AGetVarInfoObj( APFirstName^, PValue, VType.All );

    if PValue = nil then
    begin // Varaible is absent
      SValues[i] := '!!!No Value';
      Continue;
    end;

    RAFlag := false;
    if VType.D.TFlags = K_ffVArray then
    begin
      PValue := K_GetPVRArray( PValue );
      if PValue = nil then
      begin
        SValues[i] := '!!!WRong VArray';
        Continue;
      end;
      RAFlag := true;
    end else if VType.D.TFlags = K_ffArray then
      RAFlag := true;

    if RAFlag then // RArray
    begin
      RA := TK_PRArray(PValue)^;
      if RA <> nil then begin
        VType := RA.ElemType;
        Count := Min( Count, RA.Alength );
        PValues[i] := PValue;
        VTypes[i] := VType;
      end else
        SValues[i] := '!!!Empty Array';
    end else
      SValues[i] := K_SPLValueToString( PValue^, VType );

    Inc( APFirstName );
  end;

  if Count = MaxInt then
    Count := 1; // No Real Array Found

  for j := 0 to Count - 1 do
    for i := 0 to ANumNames - 1 do
    begin
      if SValues[i] <> '' then // Scalar or Error
        CStr := SValues[i]
      else                     // RArray Element
        CStr := K_SPLValueToString( TK_PRArray(PValues[i]).P(j)^, VTypes[i] );
      AResSL.Add( CStr );
    end;

  ANumRows := Count;

end; // procedure N_GetGlobVarsAsStrings

//*************************************************** N_ExpandBracketsInStr ***
// Return String with Expanded Brackets
//
// AGetVarInfoObj - ProcOfObj for getting Info about Global Variable
// ASrcText       - Source string with Global Vars in brackets
// AResInfo       - given array with info about brackets
//
function N_ExpandBracketsInStr( AGetVarInfoObj: TK_MVGetVarInfoProc;
                                ASrcStr: string; AResInfo: TN_BracketsInfo ): string;
var
  i, SrcInd, ResFreeInd, NumChars, NeededSize: integer;
  VarContent: string;
begin
  SetLength( Result, Length(ASrcStr) + 10*Length(AResInfo) ); // initial size
  SrcInd := 1;
  ResFreeInd := 1;

  for i := 0 to High(AResInfo) do // along all brackets
  with AResInfo[i] do
  begin
    //***** Copy chars before i-th bracket
    NumChars := BIBegInd - SrcInd;

    if NumChars > 0 then
    begin
      NeededSize := ResFreeInd + NumChars - 1;
      if Length(Result) < NeededSize then
        SetLength( Result, N_NewLength(NeededSize) );

      move( ASrcStr[SrcInd], Result[ResFreeInd], NumChars );
      Inc( ResFreeInd, NumChars );
    end; // if NumChars > 0 then

    //***** Copy Global Var content
    VarContent := N_GetGlobVarAsString( AGetVarInfoObj, BIText );
    NumChars := Length(VarContent);

    if NumChars > 0 then
    begin
      NeededSize := ResFreeInd + NumChars - 1;
      if Length(Result) < NeededSize then
        SetLength( Result, N_NewLength(NeededSize) );

      move( VarContent[1], Result[ResFreeInd], NumChars );
      Inc( ResFreeInd, NumChars );
    end; // if NumChars > 0 then

    SrcInd := BIEndInd + 1; // next char after i-th bracket

  end; // for i := 0 to High(AResInfo) do // along all brackets

  //***** Copy chars after last bracket
  NumChars := Length(ASrcStr) - SrcInd + 1;

  if NumChars > 0 then
  begin
    NeededSize := ResFreeInd + NumChars - 1;
    if Length(Result) < NeededSize then
      SetLength( Result, NeededSize );

    move( ASrcStr[SrcInd], Result[ResFreeInd], NumChars );
    Inc( ResFreeInd, NumChars );
  end; // if NumChars > 0 then

  SetLength( Result, ResFreeInd-1 ); // final Size
end; // function N_ExpandBracketsInStr

//*******************  TN_ScanDTreeObj class methods  ********************

//*********************************************  TN_ScanDTreeObj.GetRefInd  ***
// Find and return index of RefInfos Array element
//
//     Parameters
// ARef - reference to IDB Object
// Result - Returns Index of RefInfos Array element which SRIUDChild
// (RefInfos[Result].SRIUDChild) is equal to given ARef
//
function TN_ScanDTreeObj.GetRefInd( ARef: TN_UDBase ): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to NumRefs-1 do
  begin
    if RefInfos[i].SRIUDChild = ARef then
    begin
      Result := i;
      Exit;
    end;
  end; // for i := 0 to NumRefs-1 do
end; // function TN_ScanDTreeObj.GetRefInd

//*************************************  TN_ScanDTreeObj.PrepareOST  ***
// Scanning IBD Object routine
//
// Prepare all Nodes and direct References from Owners SubTree -
// create markers array and set markers[0] := 0
//
function TN_ScanDTreeObj.PrepareOST( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
begin
  UDChild.SetMarker( 0, 0 ); // create markers array and set markers[0] := 0

  Result := N_ScanAllRefs( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.PrepareOST

//*************************************  TN_ScanDTreeObj.UnmarkOST  ***
// Scanning IBD Object routine
//
// Unmark (set UDBase.Marker to 0) all Nodes and direct References from Owners SubTree
//
function TN_ScanDTreeObj.UnmarkOST( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
begin
  UDChild.SetMarker( 0, -1 ); // clear all markers

  Result := N_ScanAllRefs( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.UnmarkOST

//*************************************  TN_ScanDTreeObj.CalcRefsInOST  ***
// Scanning IBD Object routine
//
// Calculate in IBD Objects Subnet Owners SubTree:
//#F
// - number of references to each IDB Object and store references Source IDB Objects
// - whole number of IDB Objects and References
//#/F
//
function TN_ScanDTreeObj.CalcRefsInOST( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
var
  MarkerInd: integer;
begin
  with UDChild do
  begin
{ // debug
    if (UDChild.ObjName = 'Report1') or
       (UDParent.ObjName = 'Query1')   then
          N_IAdd( 'Deb (Child,Parent/Field): ' + UDChild.ObjName + '  ' + UDParent.ObjName +
                                    '/' + FieldName );
}

    MarkerInd := GetMarker( 0 ); // Number of Refs and Index-1 of New Ref to UDChild
    if RefInd > High(RefInfos) then
      SetLength( RefInfos, N_NewLength( RefInd ) );

    with RefInfos[RefInd] do
    begin
      if FieldName = '' then
        SRIRefPath := N_GetReverseRefPath( UDParent )
      else
        SRIRefPath := FieldName + '>' + N_GetReverseRefPath( UDParent );

      //*** for debug:
      SRIUDParent  := UDParent;
      SRIUDChild   := UDChild;
      SRIFieldName := FieldName;

    end; // with RefInfos[RefInd] do

{ // debug
  i, j: integer;

    for i := 1 to MarkerInd do // check if same Node   //??
    begin
      j := GetMarker( i );
      with RefInfos[j] do
        if (SRIUDParent = UDParent) and (SRIUDChild = UDChild) and
           (SRIFieldName = FieldName) then
          N_IAdd( UDChild.ObjName + '  ' + RefInfos[RefInd].SRIRefPath +
                                    '  ' + FieldName );
    end; // for i := 1 to MarkerInd do
}

    SetMarker( RefInd, MarkerInd+1 );

    Inc(RefInd);
    Inc(MarkerInd);
    SetMarker( MarkerInd, 0 );

    Inc(NumRefs);
    if UDChild.Owner = UDParent then // UDChild belongs to Owners SubTree
      Inc(NumNodes);
  end;

  Result := N_ScanAllRefs( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.CalcRefsInOST

//*************************************  TN_ScanDTreeObj.CheckRefsInOST  ***
// Scanning IBD Object routine
//
// Check in all Nodes in Owners SubTree if RefCounter is not equal to previously
// calculated Marker, add needed info to Resulting Strings List (ResSL)
//
function TN_ScanDTreeObj.CheckRefsInOST( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
var
  i, CalcCounter: integer;
  CurRefPath: string;
begin
  with UDChild do
  begin

  if Owner = UDParent then // UDChild belongs to Owners SubTree
  begin
    CalcCounter := GetMarker( 0 ); // Calculated RefCounter

    if CalcCounter <> RefCounter then // Error, collect Info about it
    begin
      Inc(NumErrors);

      if ResSL <> nil then // add Info strings
      begin
        CurRefPath := N_GetReverseRefPath( UDChild );
        ResSL.Add( Format( '%.3d %.3d  %s',
                                    [CalcCounter, RefCounter, CurRefPath] ));

        for i := 1 to CalcCounter do // along all Refs to UDChild
        begin
          RefInd := GetMarker( i );
          ResSL.Add( '   ' + RefInfos[RefInd].SRIRefPath );
        end; // for i := 1 to CalcCounter do // along all Refs to UDChild

      end; // if ResSL <> nil then // add Info strings
    end; // if CalcCounter <> UDChild.RefCounter then

  end; // if UDChild.Owner = UDParent then // UDChild belongs to Owners SubTree

  end; // with UDChild do

  Result := N_ScanOnlyOwners( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.CheckRefsInOST

//*************************************  TN_ScanDTreeObj.ViewOST  ***
// Scanning IBD Object routine
//
// View Owners SubTree: add to Resulting Strings List (ResSL)
// paths to all Owners SubTree IDB Objects and direct referencess from them
//
function TN_ScanDTreeObj.ViewOST( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
begin
  if ResSL <> nil then // add Info strings
  begin
    ResSL.Add( Format( 'to %2d %d %s',
                     [ChildInd, ChildLevel, N_GetReverseRefPath( UDChild )] ));
    if FieldName = '' then
      ResSL.Add( '  from ' + N_GetReverseRefPath( UDParent ) )
    else
      ResSL.Add( '  from ' + FieldName + '>>' + N_GetReverseRefPath( UDParent ) );

    if FieldName <> '' then
      N_i := 1;

  end; // if ResSL <> nil then // add Info strings

  Result := N_ScanAllRefs( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.ViewOST

//*************************************  TN_ScanDTreeObj.IncrementCSCode  ***
// Scanning IBD Object routine
//
// Increment CSCode by Self.IncValue in all processing IDB Objects
//
function TN_ScanDTreeObj.IncrementCSCodes( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
begin
  if ChildInd <> -1 then // UDChild is UDBase Child (not RArray TN_UDBase field)
  begin
    if UDChild.Owner = UDParent then // UDChild belongs to Owners SubTree
    begin
      Result := K_tucOK;
      N_IncCSCodesInUDBase( UDChild, IncValue );
    end else // do NOT belongs to Owner Tree
      Result := K_tucSkipSubTree;
  end else // UDChild is RArray TN_UDBase field (not UDBase Child)
    Result := K_tucSkipSibling; // Skip References from RArray fields
end; // function TN_ScanDTreeObj.IncrementCSCodes

//*************************************  TN_ScanDTreeObj.SetCSCode  ***
// Scanning IBD Object routine
//
// Set Self.CSCode in all processing IDB Objects
//
function TN_ScanDTreeObj.SetCSCode( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
begin
  if ChildInd <> -1 then // UDChild is UDBase Child (not RArray TN_UDBase field)
  begin
    if UDChild.Owner = UDParent then // UDChild belongs to Owners SubTree
    begin
      Result := K_tucOK;
      N_SetCSCodeInUDBase( UDChild, CSCode, @ResPointer );
    end else // do NOT belongs to Owner Tree
      Result := K_tucSkipSubTree;
  end else // UDChild is RArray TN_UDBase field (not UDBase Child)
    Result := K_tucSkipSibling; // Skip References from RArray fields
end; // function TN_ScanDTreeObj.SetCSCode

//******************************************* TN_ScanDTreeObj.DelUnresolved ***
// Scanning IBD Object routine
//
// Delete Unresolved Referencies to IDB Objects in IDB Objects Subnet
//
function TN_ScanDTreeObj.DelUnresolved( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
begin
  if UDChild is TK_UDRef then // Is Unresolved Ref
  begin
    N_s := UDChild.ObjName; // debug
    UDChild.UDDelete;
    UDChild := nil;
    Inc( NumDeleted );
  end; // if UDChild is TK_UDRef then // Is Unresolved Ref

  Result := K_tucOK;
  if ChildInd = -1 then
    Result := K_tucSkipSubTree;

//  Result := N_ScanOnlyOwners( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.DelUnresolved

{
//*************************************  TN_ScanDTreeObj.ConvComponents  ***
// Convert Old Components to New Components
//
function TN_ScanDTreeObj.ConvComponents( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; FieldName: string ): TK_ScanTreeResult;
var
  i: integer;
  Str, S1, S2: string;
  ChildDir, DataDir, U1: TN_UDBase;
  OldComp: TK_UDComponent;
  NewComp: TN_UDCompVis;

  procedure ConvSPC( OldComp: TK_UDComponent; NewComp: TN_UDCompVis ); // local
  // Convert Srtatic Params, CompCords and SetParams
  var
    i: integer;
    OldSetParams, NewSetParams: TK_RArray;
  begin
    NewComp.PCCS()^ := OldComp.PCC()^; // copy CompCoords

    // copy static params
    K_MoveSPLData( OldComp.PStat()^, TN_PRCompVis(NewComp.R.P())^.OtherParams,
                TK_PCompBase(OldComp.R.P).CompSPars.DType,  [K_mdfSafeCopy] );

    OldSetParams := TK_PCompBase(OldComp.R.P).SetParams;
    if OldSetParams = nil then Exit; // no External Params

    NewSetParams := K_RCreateByTypeName( 'TN_OneSetParam', OldSetParams.ALength() );

    for i := 0 to OldSetParams.AHigh() do // convert SetParams Info
    begin
      with TN_PSetParamInfo(OldSetParams.P(i))^ do // store Old Params
      begin
        U1 := SPSrcUObj;
        S1 := SPSrcPath;
        S2 := SPDstPath;
        if S2[1] = '!' then S2 := Copy( S2, 16, 100 ); // Skip !CompSPars![0]! prefix
        if S2[1] = 'C' then S2 := Copy( S2, 15, 100 ); // Skip CompSPars![0]! prefix
        if S2[1] = 'B' then S2 := 'CPan.' + S2;        // Add CPan prefix
      end;

      with TN_POneSetParam(NewSetParams.P(i))^ do // set New Params
      begin
        SPPhase := sppBBAction;
        SPFlags := [];
        SPSrcFlags := [];
        SPDstFlags := [];
//        K_SetUDRefField( SPSrcUObj, U1 ); //???
        SPSrcUObj  := U1;
        SPSrcPath  := '';
        SPSrcField := S1;
        SPDstUObj  := nil;
        SPDstPath  := '';
        SPDstField := S2;
      end;
      TN_PRCompVis(NewComp.R.P())^.CSetParams := NewSetParams;

    end; // for i := 0 to OldSetParams.AHigh() do // convert SetParams Info
  end; // procedure ConvSPC local

begin
  NewComp := nil; // to avoid warning

  if (ChildInd <> -1) and (UDChild is TK_UDComponent) then
  begin
    Str := StringOfChar( ' ', 2*ChildLevel ) + UDChild.ObjName;
    OldComp := TK_UDComponent(UDChild);

    if UDChild is TN_UDCPanel then
    begin
      NewComp := TN_UDCompVis(K_CreateUDByRTypeName( 'TN_RPanel', 1, N_UDPanelCI ));
      ConvSPC( OldComp, NewComp );
    end else if UDChild is TN_UDCMapLayer then
    begin
      NewComp := TN_UDCompVis(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
      ConvSPC( OldComp, NewComp );
      TN_UDMapLayer(NewComp).SetIconIndex();
    end else if UDChild is TN_UDCMap then // conv Map --> Panel
    begin
      NewComp := TN_UDCompVis(K_CreateUDByRTypeName( 'TN_RPanel', 1, N_UDPanelCI ));
      NewComp.PCCS()^.CurUCoords := OldComp.PCC()^.CurUCoords;
    end else if UDChild is TN_UDCTextBox then
    begin
      NewComp := TN_UDCompVis(K_CreateUDByRTypeName( 'TN_RTextBox', 1, N_UDTextBoxCI ));
      ConvSPC( OldComp, NewComp );
    end;
    NewComp.ObjName := OldComp.ObjName; // + 'N';

    if not (OldComp is TN_UDCTextBox) then // skip TextBox Data
    begin
      DataDir := OldComp.DirChild(K_cmpDataInd);
      if DataDir <> nil then
      begin
        NewComp.AddOneChild( DataDir );
        DataDir.Owner := NewComp;
      end;
    end;

    ChildDir := OldComp.DirChild(K_cmpChildsInd);
    if ChildDir <> nil then
    begin
      for i := 0 to ChildDir.DirHigh() do
      begin
        U1 := ChildDir.DirChild( i );
        NewComp.AddOneChild( U1 );
        U1.Owner := NewComp;
      end;
    end;

//    UDChild.Delete(); // old vars
//    UDChild := NewComp;
//    Inc(NewComp.RefCounter);
//    K_SetUDRefField( UDChild, NewComp );

    UDChild := NewComp;
    UDParent.PutDirChild( ChildInd, NewComp );
    Inc(NewComp.RefCounter);

    ResSL.Add( Str );
  end; // if (ChildInd <> -1) and (UDChild is TK_UDComponent) then

  Result := N_ScanOnlyOwners( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.ConvComponents
}

//*************************************  TN_ScanDTreeObj.ChangeSetParams  ***
// Convert Old Var of SetParams to New one
//
function TN_ScanDTreeObj.ChangeSetParams( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
var
  i: integer;
  SetParams: TK_RArray;
begin
  if (ChildInd <> -1) and (UDChild is TN_UDCompBase) then // is a Component to analize
  begin

    SetParams := TN_UDCompBase(UDChild).PSP()^.CSetParams;

    for i := 0 to SetParams.AHigh() do // change SetParams Info
    with TN_POneSetParam(SetParams.P(i))^ do
    begin
      if SPDstField = ParStr1 then
      begin
        SPDstField := ParStr2 + SPDstField;
        Inc(NumNodes);
      end;
    end; // for i := 0 to SetParams.AHigh() do // change SetParams Info

  end; // if (ChildInd <> -1) and (UDChild is TK_UDComponent) then

  Result := N_ScanOnlyOwners( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.ChangeSetParams

//*************************************  TN_ScanDTreeObj.CollectUObjInfo  ***
// Scanning IBD Object routine
//
// Collect info about UObjects in RefInfos Array and
// ( NumRefs is number of elements in RefInfos Array )
//
// Implemented functions:
// - Collect Info about Old Fonts Objects (TN_UDLogFont)
//
function TN_ScanDTreeObj.CollectUObjInfo( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
  Label Fin;
begin
  if (ChildInd <> -1) then // Analize UDChild
  begin

    //******************* Collect Info about Old Fonts Objects (TN_UDLogFont)
    if UDChild is TN_UDLogFont then
    begin
      if High(RefInfos) < NumRefs then
        SetLength( RefInfos, N_NewLength( NumRefs+1 ) );

      RefInfos[NumRefs].SRIUDChild  := UDChild;
      RefInfos[NumRefs].SRIUDParent := UDParent;
      Inc( NumRefs );
    end; // if UDChild is TN_UDLogFont then

    goto Fin;

  end; // if if (ChildInd <> -1) then // Analize UDChild

  Fin: //**********
  Result := N_ScanOnlyOwners( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.CollectUObjInfo

//***************************************** TN_ScanDTreeObj.CollectUObjStat ***
// Collect Statisctics OST UObjects:
// NumNodes - Whole Number of Nodes in Owners SubTree
// NumRefs  - Whole Number of UDBase Children in Owners SubTree
// ResInt1  - Number of Nodes in Owners SubTree with Zero Children
//
function TN_ScanDTreeObj.CollectUObjStat( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
var
  NumChildren: integer;
begin
  if (ChildInd <> -1) then // Analize UDChild
  begin
    N_s := UDChild.ObjName; // debug
    Inc( NumNodes );
    NumChildren := UDChild.DirLength();
    Inc( NumRefs, NumChildren );
    if NumChildren = 0 then Inc( ResInt1 );
  end; // if if (ChildInd <> -1) then // Analize UDChild

  Result := N_ScanOnlyOwners( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.CollectUObjStat

//******************************************* TN_ScanDTreeObj.ScanUDRArrays ***
//  Scan UDRArrays and parse all RAFields with RAFieldFunc
//  ParUObj1 is Root UObj for creating Paths to UDRArrays
//
function TN_ScanDTreeObj.ScanUDRArrays( UDParent: TN_UDBase; var UDChild: TN_UDBase;
        ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
var
  CurCount: integer;
begin
  if (ChildInd <> -1) then // Is UDChild
  begin

  if UDChild is TK_UDRArray then
  begin
    CurCount := ResSL.Count;

    TK_UDRArray(UDChild).ScanRAFields( RAFieldFunc );

    if ResSL.Count > CurCount then // RAFieldFunc add some strings to ResSL
    begin
      ResSL.Insert( CurCount, '  UDRArray: ' + N_GetUObjPath( UDChild, ParUObj1, N_PathShortSize, [] ) );
    end; // if ResSL.Count > CurCount then // RAFieldFunc add some strings to ResSL

  end; // if UDChild is TK_UDRArray then

  end; // if if (ChildInd <> -1) then // Analize UDChild

  Result := N_ScanOnlyOwners( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.ScanUDRArrays

//***************************************  TN_ScanDTreeObj.ChangeUObjects1  ***
// Is used in debug and converting procedures
// Implemented functions:
// - Convert Old Var of SetParams to New one
// - Convert Old Var Margins in TextBox and Legend to Paddings
// - change  UDPanel Image Index
// - delete  all CPanel RArrays
// - Collect Pointers to UDTextBox
// - used in TN_Params1Form.aUConvToParaBoxExecute for UDTextBox to UDParaBox converting
// - Create New Fonts objects before all Old Fonts Objects
//
function TN_ScanDTreeObj.ChangeUObjects1( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;

  Label Fin;
begin
  if (ChildInd <> -1) and (UDChild is TN_UDCompBase) then // is a Component to analize
  begin
  { //*********** Convert Old Var of SetParams to New one
    //            For All DstFields with ParStr1 value add ParStr2 Prefix

var
  i: integer;
  Str: string;
  SetParams: TK_RArray;

    SetParams := TN_UDCompBase(UDChild).PSP()^.CSetParams;

    for i := 0 to SetParams.AHigh() do // change SetParams Info
    with TN_POneSetParam(SetParams.P(i))^ do
    begin
      if SPDstField = ParStr1 then
      begin
        SPDstField := ParStr2; // + SPDstField;
        Inc(NumNodes);
      end;
    end; // for i := 0 to SetParams.AHigh() do // change SetParams Info
  } // Convert Old Var of SetParams to New one

  { //***********  Set Empty Border Color

    with TN_UDCompVis(UDChild).PSP()^.CPanel do
    begin
      if BorderWidth = 0 then
      begin
        BorderColor := N_EmptyColor;
        Inc(NumNodes);
      end;
    end;
  } // Set Empty Border Color

  { //*********** Convert Old Var Margins in TextBox and Legend to Paddings
    if UDChild is TN_UDTextBox then
      with TN_UDTextBox(UDChild).PISP^ do
        TBPaddings := FRect( TBLeftMargin, TBTopMargin, TBRightMargin, TBBottomMargin );

    if UDChild is TN_UDLegend then
      with TN_UDLegend(UDChild).PISP^ do
        LegPaddings := FRect( LegLeftMargin, LegTopMargin, LegRightMargin, LegBottomMargin );
  } // Convert Old Var Margins in TextBox and Legend to Paddings

  { //*********** change UDPanel Image Index
    if UDChild is TN_UDPanel then
      UDChild.ImgInd := 46;
  } // change UDPanel Image Index

{  //*********** used in TN_Params1Form.aUConvToParaBoxExecute
   //            for UDTextBox to UDParaBox converting:
   //            Update all CPanel RArrays in Nivc VCTree and  Collect pointers
   //            to UDTextBox in ResPointers and Set number of collected pointers to NumRefs field
var
  i: integer;
  Str: string;
  SetParams: TK_RArray;

    if UDChild is TN_UDCompVis then
    with TN_UDCompVis(UDChild).PSP()^ do
    begin
//      FreeAndNil( CPanel );

      Str := Copy( UDChild.ObjName, 1, 3 );
      if (Str = 'niv') or (Str = 'Lab') or (Str = 'Leg') then
      begin
        TN_UDCompVis(UDChild).PCPanelS(); // create default CPanel again
        Inc( NumChanged );
      end;

      SetParams := TN_UDCompBase(UDChild).PSP()^.CSetParams;

      for i := 0 to SetParams.AHigh() do // change SetParams Info
      with TN_POneSetParam(SetParams.P(i))^ do
      begin
        if SPDstField = 'CPanel.BackColor' then  SPDstField := 'CPanel.PaBackColor';
      end; // for i := 0 to SetParams.AHigh() do // change SetParams Info

      //*********** Collect pointers to UDTextBox in ResPointers and Set NumRefs to number of collected pointers

      if UDChild is TN_UDTextBox then
      begin
        if High(ResPointers) < NumRefs then
          SetLength( ResPointers, N_NewLength( NumRefs+1 ) );

        ResPointers[NumRefs] := UDChild;
        Inc( NumRefs );
        Inc( NumChanged );
      end; // if UDChild is TN_UDTextBox then

    end; // with TN_UDCompVis(UDChild).PSP()^ do, if UDChild is TN_UDCompVis then

  // Update all CPanel RArrays in Nivc VCTree and  Collect pointers
}
  end; // if (ChildInd <> -1) and (UDChild is TN_UDCompBase) then

  Fin: //**********
  Result := N_ScanOnlyOwners( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.ChangeUObjects1

//*************************************  TN_ScanDTreeObj.ChangeUObjects2  ***
// Is used in debug and converting procedures
// Implemented functions:
// - fill new font field by UObj that is just before old font for all
//   components with fonts (TN_UDParaBox, TN_UDLegend, ... ):
//     - UDParaBox.CPBTextBlocks[i].OTBNFont by OTBFont
//
function TN_ScanDTreeObj.ChangeUObjects2( UDParent: TN_UDBase; var UDChild: TN_UDBase;
       ChildInd, ChildLevel: Integer; const FieldName: string ): TK_ScanTreeResult;
var
  i, RefInd, OldFontInd: integer;
  NewFont: TN_UDBase;

  Label Fin;
begin
  if (ChildInd <> -1) and (UDChild is TN_UDCompBase) then // is a Component to analize
  begin
  // - fill new font field by UObj that is just before old font for all
  //   components with fonts (TN_UDParaBox, TN_UDLegend, ... )

    if UDChild is TN_UDParaBox then // set UDParaBox.CPBTextBlocks[i].OTBFont
    with TN_UDParaBox(UDChild).PISP^ do
    begin
      for i := 0 to CPBTextBlocks.AHigh() do
      with TN_POneTextBlock(CPBTextBlocks.P(i))^ do
      begin
        RefInd := GetRefInd( OTBFont );
        if RefInd >= 0 then
        with RefInfos[RefInd] do
        begin
          OldFontInd := SRIUDParent.IndexOfDEField( SRIUDChild );

          if OldFontInd >= 1 then // a precaution
          begin
            NewFont := SRIUDParent.DirChild( OldFontInd-1 );
            if not (NewFont is TN_UDNFont) then Continue; // a precaution

            OTBNFont := NewFont;
            Inc( NumChanged );
          end; // if OldFontInd >= 1 then // a precaution

        end; // if RefInd >= 1 then
      end; // for j := 0 to CPBTextBlocks.AHigh() do

    end; // if UDChild is TN_UDParaBox then

    if UDChild is TN_UDLegend then
    begin

    end; // if UDChild is TN_UDLegend then


  end; // if (ChildInd <> -1) and (UDChild is TN_UDCompBase) then

  Fin: //**********
  Result := N_ScanOnlyOwners( UDParent, UDChild, ChildInd );
end; // function TN_ScanDTreeObj.ChangeUObjects2

//*************************************** TN_ScanDTreeObj.ViewClearRAFields ***
// View (ParInt1=0) or Clear  (ParInt1=1) RAField with Name in ParStr1
// ResInt2 is used for storing Fiels Size
//
function TN_ScanDTreeObj.ViewClearRAFields( AUDRoot: TN_UDBase; RARoot: TK_RArray;
                     var AField; AFieldType: TK_ExprExtType; AFieldName: string;
                     AFieldPath: string; ARowInd: Integer ): TK_ScanTreeResult;
begin
{ // debug
  ResSL.Add( Format( 'Type=%s  Ind=%d, Path=%s',
                     [K_GetExecTypeName(AFieldType.All),ARowInd,AFieldPath] ));

  if (AFieldType.DTCode = Ord(nptNotDef)) or
     (AFieldType.DTCode = Ord(NoData)) then
    ResSL.Add( Format( '%s=NotDef', [AFieldName] ))
  else
    ResSL.Add( Format( '%s=%s', [AFieldName,K_SPLValueToString(AField,AFieldType)] ));

  ResSL.Add( '' );
}

  if K_CheckTextPattern(AFieldName, ParStr1, False) then // Is needed Field
  begin
    if (AFieldType.DTCode = Ord(nptNotDef)) or
       (AFieldType.DTCode = Ord(nptNoData)) then // Size and Value could not be obtained
      ResSL.Add( AFieldPath + ' = Not Defined' )
    else //**************************************** Field has proper Type
    begin
//      N_PCAdd( 0, Format( 'Type=%s  Ind=%d, Path=%s',
//                     [K_GetExecTypeName(AFieldType.All),ARowInd,AFieldPath] ));

      if ResInt2 = -1 then // Get Field Size (at first call)
        ResInt2 := K_GetExecTypeSize( AFieldType.All );

      if not K_FieldIsEmpty( @AField, ResInt2 ) then // Field is Not Empty
      begin
        if AFieldType.DTCode > Ord(nptNoData) then // SPL Struct
          ResSL.Add( AFieldPath + ' = Struct' )
        else //************************************** Simple Data Type
          ResSL.Add( AFieldPath + ' = ' + K_SPLValueToString( AField, AFieldType ) );

        if ParInt1 = 1 then // Clear AField
          K_FreeSPLData( AField, AFieldType.All, True );

        Inc( ResInt1 );
      end; // if not K_FieldIsEmpty( @AField, ResInt2 ) then // Field is Not Empty

    end; // else // Field has proper Type


  end; // if AFieldName = ParStr1 then // found

  Result := K_tucOK; // now not used
end; // function TN_ScanDTreeObj.ViewClearRAFields


//****************** TN_GlobObj2 class methods  **********************

//****************************************************** TN_GlobObj2.Create ***
//
constructor TN_GlobObj2.Create();
begin
end; //*** end of Constructor TN_GlobObj2.Create

//***************************************************** TN_GlobObj2.Destroy ***
destructor TN_GlobObj2.Destroy;
begin
  Inherited;
end; //*** end of destructor TN_GlobObj2.Destroy

//************************************************* TN_GlobObj2.InsChildRef ***
// Paste Reference (shortcut) to given Child
// for use in TK_UDTreeClipboard.PasteFromClipboard method
//
function  TN_GlobObj2.InsChildRef( UDParent : TN_UDBase; ChildInd : Integer;
                                          const SrcDE : TN_DirEntryPar ) : Boolean;
begin
  Result := True;
//  if N_GetUObj( UDParent, SrcDE.Child.ObjName ) <> nil then // skip pasting same ref
  if UDParent.DirChildByObjName( SrcDE.Child.ObjName ) <> nil then // skip pasting same ref
  begin
    Result := False;
    Exit;
  end;

  UDParent.InsOneChild( ChildInd, SrcDE.Child );
  UDParent.AddChildVnodes( ChildInd, GO2VNodeFlags );
end; // end of TN_GlobObj2.InsChildRef

//******************************************** TN_GlobObj2.InsChildFullCopy ***
// Paste Full SubTree Copy of given Child
// for use in TK_UDTreeClipboard.PasteFromClipboard method
//
function  TN_GlobObj2.InsChildFullCopy( UDParent : TN_UDBase; ChildInd : Integer;
                                          const SrcDE : TN_DirEntryPar ) : Boolean;
var
  NewUObj: TN_UDBase;
  PasteRef : Boolean;
begin
  Result := True;

  PasteRef := GO2PasteAfterCut and (SrcDE.Child.RefCounter = 1);
  if PasteRef then // is used while pasting after Cut operation
    NewUObj := SrcDE.Child
  else
    NewUObj := N_CreateSubTreeClone( SrcDE.Child );

  if not (PasteRef and (UDParent = SrcDE.Parent)) then // not move in same Dir
    NewUObj.ObjName := UDParent.BuildUniqChildName( NewUObj.ObjName );

  UDParent.InsOneChild( ChildInd, NewUObj );
  if NewUObj.Owner = nil then NewUObj.Owner := UDParent;
  UDParent.AddChildVnodes( ChildInd, GO2VNodeFlags );
end; // end of TN_GlobObj2.InsChildFullCopy


//****************** TN_HTMLTagParser class methods  **********************

constructor TN_HTMLTagParser.Create( SourceStr: string );
begin
  inherited Create( SourceStr );
  StyleDelims := ':;'+Chr($0D)+Chr($0A)+K_TagCloseChar;
end;

function TN_HTMLTagParser.ParseTag( var CurPos : Integer; AttrsList : TStrings ): string;
var
  Ind : Integer;
  AttrName : string;
begin
  Result := inherited ParseTag( CurPos, AttrsList );
  Ind := AttrsList.IndexOfName( 'style' );
  if Ind = -1 then Exit;
  St.setSource( AttrsList.ValueFromIndex[Ind] );
  St.setDelimiters(StyleDelims);
  while St.hasMoreTokens do begin
    AttrName := Trim( St.nextToken );
    if AttrName = '' then break;
    AttrsList.Add( AttrName + '=' + Trim( St.nextToken ) );
  end;
  St.setDelimiters(DataDelims);
end;

//********** TN_UDLogFont class methods  **************

//********************************************** TN_UDLogFont.Create ***
//
constructor TN_UDLogFont.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and $FFFFFF00) or N_UDLogFontCI;
  ImgInd := 10;
  ScaleCoef := 1;
end; // end_of constructor TN_UDLogFont.Create

//********************************************* TN_UDLogFont.Destroy ***
// TN_UDLogFont objects should not be deleted while any TN_OCanv objects exists!
//
destructor TN_UDLogFont.Destroy;
begin
  // SelfWinHandle can safly be deleted while it was selected in some device context!
  ClearWinHandle();
  inherited Destroy;
end; // end_of destructor TN_UDLogFont.Destroy

//********************************************** TN_UDLogFont.PascalInit ***
// Init self (should be always called after create)
//
procedure TN_UDLogFont.PascalInit();
begin
  R.Free;
  R := K_RCreateByTypeName( 'TN_LogFont', 1 );
  with TN_PLogFont(R.P)^ do
  begin
    LFHeight      := 12;
    LFNormWeight  := 400;
    LFBoldWeight  := 700;
    LFFaceName    := 'Arial';
    LFBaseLinePos := 0.5;
    LFSpaceWidthCoef  := 0.3;
    LFnWidthCoef      := 0.35;
    LFHyphenWidthCoef := 0.3;
  end;
end; // procedure TN_UDLogFont.PascalInit

//********************************************** TN_UDLogFont.ClearWinHandle ***
// Clear previously created WinHandle
// (should be called after changing any Self fields!)
//
procedure TN_UDLogFont.ClearWinHandle();
begin
  // FontHandle can be deleted even if it is currently selected?
  if SelfWinHandle <> 0 then  // delete previously created GDI FontHandle
    N_b := DeleteObject( SelfWinHandle );

  SelfWinHandle := 0;
end; // procedure TN_UDLogFont.ClearWinHandle

//******************************************* TN_UDLogFont.CalcPixHeight ***
// Calc LogFont Height in pixels
//
function TN_UDLogFont.CalcPixHeight( OCanv: TN_OCanvas ): integer;
begin
  // 0.9 is experimental coef, FontSize is nearly same with Corel and Word

  if ScaleCoef > 0 then // Scale original LFHeight
    Result := Round( ScaleCoef * OCanv.CurLFHPixSize *
                               TN_PLogFont(R.P())^.LFHeight )
  else //***************** Set absolute Height in LFH units
    Result := Round( -ScaleCoef * OCanv.CurLFHPixSize );

//                                * 0.9 *   // old var
//                                GetDeviceCaps( OCanv.HMDC, LOGPIXELSY ) / 72 );
end; // procedure TN_UDLogFont.CalcPixHeight

//******************************************* TN_UDLogFont.CreateWinHandle ***
// Create Windows Font Handle by Self fields content
//
procedure TN_UDLogFont.CreateWinHandle( OCanv: TN_OCanvas; ABLAngle, ACharAngle: float );
var
  NameSize: integer;
  PLogFont: TN_PLogFont;
  WinLogFont: TLogFont;
begin
  PLogFont := TN_PLogFont(R.P);
  with PLogFont^ do
  begin
    if LFType = 0 then // Windows font (now the only possibility)
    begin
      if OCanv.ConFontHandle = SelfWinHandle then OCanv.ConFontHandle := 0;
      ClearWinHandle();

      FillChar( WinLogFont, Sizeof(WinLogFont), 0 );

      //***** Remark: WinLogFont.lfHeight > 0 - means cell height,
      //                                  < 0 - means character height

      SelfPixHeight := CalcPixHeight(OCanv); // save for future comparison
      WinLogFont.lfHeight := SelfPixHeight;

      if lfsBold in LFStyle then
        WinLogFont.lfWeight := LFBoldWeight
      else
        WinLogFont.lfWeight := LFNormWeight;

      if lfsItalic    in LFStyle then WinLogFont.lfItalic := 1;
      if lfsUnderline in LFStyle then WinLogFont.lfUnderline := 1;

      WinLogFont.lfCharSet := DEFAULT_CHARSET; // =204

      WinLogFont.lfQuality := DEFAULT_QUALITY;
      if lffDraftQuality in LFFlags then WinLogFont.lfQuality := DRAFT_QUALITY;
      if lffProofQuality in LFFlags then WinLogFont.lfQuality := PROOF_QUALITY;

      NameSize := Length( LFFaceName );
      if NameSize > 31 then NameSize := 31;
      if NameSize > 0 then
        Move( LFFaceName[1], WinLogFont.lfFaceName[0], NameSize+1 )
      else
        WinLogFont.lfFaceName[0] := Char(0);

      WinLogFont.lfEscapement  := Round( 10 * ABLAngle );
      WinLogFont.lfOrientation := Round( 10 * (ABLAngle + ACharAngle) );

      SelfWinHandle := CreateFontIndirect( WinLogFont );
    end; // if LFType = 0 then // Windows font

  end; // with PLogFont^ do
end; // procedure TN_UDLogFont.CreateWinHandle

//********************************************* TN_UDLogFont.SetFont(2) ***
// Set Self as current Font if not yet (Select Self in OCanv.MainCanvas)
//
procedure TN_UDLogFont.SetFont( OCanv: TN_OCanvas; AScaleCoef: float );
var
  PixExt: integer;
begin
  ScaleCoef := AScaleCoef;
  if ScaleCoef = 0 then ScaleCoef := 1; // for compatability

  with OCanv do
  begin
    if (SelfWinHandle = 0) or
       (SelfPixHeight <> CalcPixHeight(OCanv) ) then CreateWinHandle( OCanv, 0, 0 );

    // SelfWinHandle can safly be selected in several device contexts!

    if ConFontHandle <> SelfWinHandle then
    begin
      SelectObject( HMDC, SelfWinHandle );
      ConFontHandle := SelfWinHandle;
    end;

    PixExt := LLWToPix( TN_PLogFont(R.P())^.LFCharExtraSpace );
    if PixExt <> ConCharsExtPix then
    begin
      ConCharsExtPix := PixExt;
      Windows.SetTextCharacterExtra( HMDC, PixExt );
    end;

  end; // with OCanv do
end; //*** end of procedure TN_UDLogFont.SetFont(2)

//********************************************* TN_UDLogFont.SetFont(4) ***
// Always create New WinHandle and Select it in OCanv.MainCanvas
//
procedure TN_UDLogFont.SetFont( OCanv: TN_OCanvas;
                                     AScaleCoef, ABLAngle, ACharAngle: float );
begin
  ScaleCoef := AScaleCoef;
  with OCanv do // PLogFont^,
  begin
    CreateWinHandle( OCanv, ABLAngle, ACharAngle );
    SelectObject( HMDC, SelfWinHandle );
    ConFontHandle := SelfWinHandle;
    SelfPixHeight := -1; // to prevent using again just created SelfWinHandle
  end;
end; //*** end of procedure TN_UDLogFont.SetFont(4)


{
//********** TN_UDText class methods  **************

//********************************************** TN_UDText.Create ***
//
constructor TN_UDText.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and $FFFFFF00) or N_UDTextCI;
  ImgInd := 33;
end; // end_of constructor TN_UDText.Create

//********************************************* TN_UDText.Destroy ***
//
destructor TN_UDText.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDText.Destroy

//********************************************** TN_UDText.PascalInit ***
// Init self (should be always called after create)
//
procedure TN_UDText.PascalInit();
begin
  R.Free;
  R := K_RCreateByTypeName( 'String', 1 );
end; // procedure TN_UDText.PascalInit
}

//********** TN_UDNFont class methods  **************

//******************************************************* TN_UDNFont.Create ***
// Create UDNFont with empty fields
//
constructor TN_UDNFont.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and $FFFFFF00) or N_UDNFontCI;
  ImgInd := 35;
end; // end_of constructor TN_UDNFont.Create

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_UDNFont\Create2
//****************************************************** TN_UDNFont.Create2 ***
// Create Font Object with given attributes
//
//     Parameters
// AHeight   - given font height
// AFaceName - given font face name
//
constructor TN_UDNFont.Create2( AHeight: float; AFaceName: string );
begin
  Create;
  R.Free;
  R := N_CreateRArrayNFont( AHeight, AFaceName );
end; // end_of constructor TN_UDNFont.Create2

//****************************************************** TN_UDNFont.Destroy ***
// TN_UDNFont objects should not be deleted while any TN_OCanv objects exists!
//
destructor TN_UDNFont.Destroy;
begin
  DeleteWinHandle( -1 );

  inherited Destroy;
end; // end_of destructor TN_UDNFont.Destroy

//*************************************************** TN_UDNFont.PascalInit ***
// Init self (should be always called after Create but not after Create2)
//
procedure TN_UDNFont.PascalInit();
begin
  DeleteWinHandle( -1 );
  R.Free;
  R := K_RCreateByTypeName( 'TN_NFont', 1 );
  TN_PNFont(R.P)^.NFWin.lfCharSet := RUSSIAN_CHARSET; // = 204
end; // procedure TN_UDNFont.PascalInit

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_UDNFont\DeleteWinHandle
//********************************************** TN_UDNFont.DeleteWinHandle ***
// Delete previously created Windows Font Handle
//
//     Parameters
// AFontInd - index of font in Font Records Array, if =-1 then Windows Font 
//            Handles in all array Records will be deleted
//
// Should be called after changing any Font Attributes (Self.fields!)
//
procedure TN_UDNFont.DeleteWinHandle( AFontInd: integer = 0 );
var
  i, NumFonts: integer;
begin
  // NFHandle can be deleted even if it is currently selected

  if R = nil then Exit;
  NumFonts := R.ALength();
  if AFontInd >= NumFonts then Exit;

  if AFontInd < 0 then // delete all self Fonts WinHandles
    for i := 0 to NumFonts-1 do
      DeleteWinHandle( i )
  else //**************** delete one WinHandle
  begin
    with TN_PNFont(R.P(AFontInd))^ do
    begin
      if NFHandle <> 0 then  // delete previously created GDI FontHandle
        N_b := DeleteObject( NFHandle );

      NFHandle := 0;
    end; // with TN_PNFont(R.P(AFontInd))^ do
  end;
end; // procedure TN_UDNFont.DeleteWinHandle

{
//********** TN_UDMem class methods  **************

//********************************************************* TN_UDMem.Create ***
//
constructor TN_UDMem.Create;
begin
  inherited Create;
  ClassFlags := N_UDMemCI;
  ImgInd := 39;
end; // end_of constructor TN_UDMem.Create

//************************************************ TN_UDMem.AddFieldsToSBuf ***
// save self to Serial Binary Buf
//
procedure TN_UDMem.AddFieldsToSBuf( SBuf: TN_SerialBuf );
var
  Size: integer;
begin
  Inherited;
  Size := Length(SelfMem);
  SBuf.AddRowInt( Size );
  if Size > 0 then
    SBuf.AddRowBytes( Size, @SelfMem[0] );
end; // end_of procedure TN_UDMem.AddFieldsToSBuf

//********************************************** TN_UыDMem.GetFieldsFromSBuf ***
// load self from Serial Binary Buf
//
procedure TN_UDMem.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
var
  Size: integer;
begin
  Inherited;
  SBuf.GetRowInt( Size );
  SetLength( SelfMem, Size );
  if Size > 0 then
    SBuf.GetRowBytes( Size, @SelfMem[0] );
end; // end_of procedure TN_UDMem.GetFieldsFromSBuf

//************************************************ TN_UDMem.AddFieldsToText ***
// save self to Serial Text Buf
//
function TN_UDMem.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ): Boolean;
var
  Size: integer;
begin
  inherited AddFieldsToText( SBuf, AShowFlags );

  Size := Length(SelfMem);
  if Size > 0 then
  begin
    SBuf.AddTagAttr( 'Size', Size, K_isInteger );
    SBuf.AddRowBytes( Size, @SelfMem[0] );
  end;

  Result := True;
end; // end_of procedure TN_UDMem.AddFieldsToText

//********************************************** TN_UDMem.GetFieldsFromText ***
// load self from Serial Text Buf
//
function TN_UDMem.GetFieldsFromText( SBuf: TK_SerialTextBuf ): Integer;
var
  Size: integer;
begin
  inherited GetFieldsFromText(SBuf);

  if SBuf.GetTagAttr( 'Size', Size, K_isInteger ) then
  begin
    SetLength( SelfMem, Size );
    SBuf.GetRowBytes( Size, @SelfMem[0] );
  end else
    SelfMem := nil;

  Result := 0;
end; // end_of procedure TN_UDMem.GetFieldsFromText

//***************************************************** TN_UDMem.CopyFields ***
// copy to self given TN_UDMem object (including Obj Name,Aliase,Info)
//
procedure TN_UDMem.CopyFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution
  Assert( SrcObj.CI() = N_UDMemCI, 'Not UDMem!' );

  inherited;
  SelfMem := Copy( TN_UDMem(SrcObj).SelfMem );
end; // end_of procedure TN_UDMem.CopyFields

//***************************************************** TN_UDMem.SameFields ***
// returns True if all self.fields are the same as given SrcObj.fields
// (SrcObj must be of the same class as self)
//
function TN_UDMem.SameFields( SrcObj: TN_UDBase; AFlags: integer ): boolean;
begin
  Result := Inherited SameFields( SrcObj, AFlags ); // prelimenary value
  if Result = False then Exit; // not same
  Assert( SrcObj.CI() = N_UDMemCI, 'Not UDMem!' );

  Result := N_SameBytes( @SelfMem[0], Length(SelfMem),
                         @TN_UDMem(SrcObj).SelfMem[0],

                         Length(TN_UDMem(SrcObj).SelfMem) );
end; // end_of procedure TN_UDMem.SameFields

//******************************************** TN_UDMem.LoadStringsFromSelf ***
// Load content of Self to given AStrings
//
procedure TN_UDMem.LoadStringsFromSelf( AStrings: TStrings );
var
  BufStr: String;
begin
  SetString( BufStr, PChar(SelfMem), Length(SelfMem) );
  AStrings.Text := BufStr;
end; // procedure TN_UDMem.LoadStringsFromSelf

//********************************************* TN_UDMem.LoadSelfFromDFile ***
// Load content of given DFile to Self, return True if OK
//
function TN_UDMem.LoadSelfFromDFile( AFileName: string;
                       AOpenFlags: TN_DFOpenFlags; APasWord: string ): boolean;
var
  DFState: TN_DFileState;
begin
  Result := N_DFOpen( AFileName, DFState, AOpenFlags );
  if not Result then Exit; // Error while opening

  SetLength( SelfMem, DFState.DFPlainDataSize );
  Result := N_DFReadAll( Pointer(SelfMem), DFState, APasWord );
end; // function TN_UDMem.LoadSelfFromDFile

//********** end of TN_UDMem class methods  **************
}

//********** TN_MemTextFragms class methods  **************

//************************************************* TN_MemTextFragms.Create ***
//
constructor TN_MemTextFragms.Create;
begin
  MTFragmsList := TStringList.Create;
end; // end_of constructor TN_MemTextFragms.Create

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_MemTextFragms\CreateFromVFile
//**************************************** TN_MemTextFragms.CreateFromVFile ***
// Text Fragments Object constructor
//
//     Parameters
// AVFileName - virtual text file name with Text Fragments content
//
constructor TN_MemTextFragms.CreateFromVFile( AVFileName: string );
begin
  MTFragmsList := TStringList.Create;
  AddFromVFile( AVFileName );
end; // end_of constructor TN_MemTextFragms.CreateFromVFile

//************************************************ TN_MemTextFragms.Destroy ***
//
destructor TN_MemTextFragms.Destroy;
begin
  Clear();
  MTFragmsList.Free;
end; // end_of constructor TN_MemTextFragms.Destroy

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_MemTextFragms\Clear
//************************************************** TN_MemTextFragms.Clear ***
// Clear all objcts with Text Fragments
//
// TSringList Objects with Text Fragments Content will be Free.
//
procedure TN_MemTextFragms.Clear();
var
  i: integer;
begin
  with MTFragmsList do
  begin
    for i := 0 to Count-1 do
      Objects[i].Free;

    Clear;
  end; // with MTFragmsList do
end; // end_of procedure TN_MemTextFragms.Clear

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_MemTextFragms\AddFragm(List)
//***************************************** TN_MemTextFragms.AddFragm(List) ***
// Add Text Fragment given by Strings
//
//     Parameters
// AFragmName - Text Fragment Name
// AStrings   - Strings with Text Fragment Content
// Result     - Returns Fragment index (changed or added)
//
// If Text Fragment with given Name exists, it's content will be replaced.
//
function TN_MemTextFragms.AddFragm( AFragmName: string;
                                                AStrings: TStrings ): integer;
var
  SL: TStringList;
begin
  Result := MTFragmsList.IndexOf( AFragmName );

  if Result >= 0 then // Fragment with given Name exist, replace it's content
  begin
    with TStringList(MTFragmsList.Objects[Result]) do
    begin
      Clear();
      AddStrings( AStrings );
    end;
  end else // create New Fragment
  begin
    SL := TStringList.Create;
    SL.AddStrings( AStrings );
    Result := MTFragmsList.AddObject( AFragmName, SL ); // Add New Fragment to Self
  end;
end; // end_of function TN_MemTextFragms.AddFragm(List)

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_MemTextFragms\AddFragm(Text)
//***************************************** TN_MemTextFragms.AddFragm(Text) ***
// Add Text Fragment given by single String
//
//     Parameters
// AFragmName - Text Fragment Name
// AStrings   - String with Text Fragment Content
// Result     - Returns Fragment index (changed or added)
//
// If Text Fragment with given Name exists, it's content will be replaced.
//
function TN_MemTextFragms.AddFragm( AFragmName: string; AStr: string ): integer;
var
  SL: TStringList;
begin
  Result := MTFragmsList.IndexOf( AFragmName );

  if Result >= 0 then // Fragment with given Name exist, replace it's content
  begin
    TStringList(MTFragmsList.Objects[Result]).Text := AStr;
  end else // create New Fragment
  begin
    SL := TStringList.Create;
    SL.Text := AStr;
    Result := MTFragmsList.AddObject( AFragmName, SL ); // Add New Fragment to Self
  end;
end; // end_of function TN_MemTextFragms.AddFragm(Text)

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_MemTextFragms\FragmAddToStrings
//************************************** TN_MemTextFragms.FragmAddToStrings ***
// Add Text Fragment content to given Strings
//
//     Parameters
// AFragmName - Text Fragment Name
// AStrings   - Strings Text Fragment Content to add
// Result     - Returns Fragment index or -1 if not found
//
function TN_MemTextFragms.FragmAddToStrings( AFragmName: string;
                                             AStrings: TStrings ): integer;
begin
  Result := MTFragmsList.IndexOf( AFragmName );
  if Result >= 0 then
    AStrings.AddStrings( TStringList(MTFragmsList.Objects[Result]) );
end; // end_of function TN_MemTextFragms.FragmAddToStrings

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_MemTextFragms\SelfAddToStrings
//*************************************** TN_MemTextFragms.SelfAddToStrings ***
// Add all Text Fragments content to given Strings
//
//     Parameters
// AStrings - Strings Text Fragments Content to add
//
// Text Fragments will be added to given Strings in Windows ini-file format 
// ([FragmName] string before each Text Fragment) or in own Text Fragments File 
// format (each Text Fragment is separated by [[FragmName]] ... [[/FragmName]] 
// brackets)
//
procedure TN_MemTextFragms.SelfAddToStrings( AStrings: TStrings );
var
  i: integer;
begin
  AStrings.BeginUpdate();

  for i := 0 to MTFragmsList.Count-1 do
  begin
    if MTFIsWinIni then
      AStrings.Add( '[' + MTFragmsList.Strings[i] + ']' )
    else
      AStrings.Add( '[[' + MTFragmsList.Strings[i] + ']]' );

    AStrings.AddStrings( TStringList(MTFragmsList.Objects[i]) );

    if not MTFIsWinIni then
      AStrings.Add( '[[/' + MTFragmsList.Strings[i] + ']]' );

    AStrings.Add( '' ); // empty string separator
  end;

  AStrings.EndUpdate();
end; // end_of procedure TN_MemTextFragms.SelfAddToStrings

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_MemTextFragms\AddFragms
//********************************************** TN_MemTextFragms.AddFragms ***
// Add Text Fragments given by Strings
//
//     Parameters
// AStrings - Strings with Text Fragments Content
//
// Given strings should be in Windows ini-file format ([FragmName] string before
// each Text Fragment) or in own Text Fragments File format (each Text Fragment 
// is separated by [[FragmName]] ... [[/FragmName]] brackets)
//
// Detected format type is set to MTFIsWinIni field
//
procedure TN_MemTextFragms.AddFragms( AStrings: TStrings );
const
  OpenBrackets = '[[';
var
  i, ibeg, j, Ind, PatLeng, FragmInd: integer;
  Str, FragmName, FragmNamePat: string;
  SL: TStringList;
  label AddNextFragm, BegFragmLocated, AddStr,
        AddNextIniFragm, BegIniFragmLocated, AddIniStr, Fin,
        IniFragmHeader, FragmHeader;

  procedure LocalAddReplaceFragm(); // local
  // add new or replace existed fragment with FragmName using SL as content
  // and clear SL (MTFragmsList owns it)
  begin
    FragmInd := MTFragmsList.IndexOf( FragmName );

    if FragmInd >= 0 then // Fragment with given Name exist, replace it's content
    begin
      MTFragmsList.Objects[FragmInd].Free;
      MTFragmsList.Objects[FragmInd] := SL;
    end else // create New Fragment
      MTFragmsList.AddObject( FragmName, SL ); // Add New Fragment to Self

    SL := nil; // to prevent destoying saved SL in SL.Free statement
  end; // procedure LocalAddReplaceFragm - local

begin //****************************** TN_MemTextFragms.AddFragms main body
  //***** Main Loop initialization

  SL := nil;
  MTFragmsList.BeginUpdate();
  ibeg := 0;

  //***** Check given AStrings format (set MTFIsWinIni field)

  for i := 0 to AStrings.Count-1 do // loop till first '[' char
  begin
    Str := AStrings[i];
    Ind := Pos( '[', Str );
    if Ind = 0 then Continue; // no '[' char, analize next string

    MTFIsWinIni := True; // prelimenary value

    if Length(Str) >= (Ind+1) then
    begin
      if Str[Ind+1] = '[' then // next char is also '[' - is own format
        MTFIsWinIni := False; // set "is own format" flag
    end; // if Length(Str) >= (Ind+1) then

    if MTFIsWinIni then goto AddNextIniFragm
                   else goto AddNextFragm;

  end; // for i := 0 to AStrings.Count-1 do // loop till first '[' char

  goto Fin; //  no '[' char in given AStrings (no Text Fragments)

  AddNextFragm: //********************* Add one Fragment in own format

  for i := ibeg to AStrings.Count-1 do // Main loop till [[FragmName]] string
  begin
    Str := AStrings[i];
    if Length(Str) <= 4 then Continue; // could not be Beg of Fragment

    if TN_PTwoChars(@Str[1])^ = TN_PTwoChars(@OpenBrackets[1])^ then // Beg of Fragment (two square brackets [[)
    begin
      Ind := Pos( ']]', Str );
      if Ind = 0 then Continue; // no end of Fragment Name
      FragmName := Copy( Str, 3, Ind-3 );
      FragmNamePat := '[[/' + FragmName + ']]';
      PatLeng := Length(FragmNamePat);
      goto BegFragmLocated;
    end; // if TN_PTwoChars(@Str[1])^ = TN_PTwoChars(@OpenBrackets[1])^ then // Beg of Fragment (two square brackets [[)
  end; // for i := 0 to AStrings.Count-1 do // loop till [[FragmName]] string

  goto Fin; // no more fragments

  BegFragmLocated: //***** i is index of [[FragmName]] string

  SL := TStringList.Create;

  for j := i+1 to AStrings.Count-1 do // loop till [[/FragmName]] string
  begin
    Str := AStrings[j];
    if Length(Str) < PatLeng then goto AddStr; // could not be End of Fragment

    if TN_PTwoChars(@Str[1])^ = TN_PTwoChars(@OpenBrackets[1])^ then // possible End of Fragment
    begin
      if Copy( Str, 1, PatLeng ) = FragmNamePat then // End Fragment Located
      begin
        LocalAddReplaceFragm();
        ibeg := j+1;
        goto AddNextFragm;
      end else
        goto AddStr;
    end; // if TN_PTwoChars(@Str[1])^ = TN_PTwoChars(@OpenBrackets[1])^ then // possible End of Fragment

    AddStr: //***** add Str to SL (to current Fragment)
    SL.Add( Str );
  end; // for j := i+1 to AStrings.Count-1 do // loop till [[/FragmName]] string

  //*** end of processing fragments in own format
  goto Fin;

  AddNextIniFragm: //****************** Add one Fragment in Win Ini file format

  for i := ibeg to AStrings.Count-1 do // Main loop till [FragmName] string
  begin
    Str := Trim(AStrings[i]);
    if Length(Str) <= 2 then Continue; // could not be Beg of Fragment

    if Str[1] = '[' then // Beg of Fragment
    begin
IniFragmHeader:
      Ind := Pos( ']', Str );
      if Ind = 0 then Continue; // no end of Fragment Name
      FragmName := Copy( Str, 2, Ind-2 );
      goto BegIniFragmLocated;
    end; // if Str[1] = '[' then // Beg of Fragment
  end; // for i := 0 to AStrings.Count-1 do // loop till [FragmName] string

  goto Fin; // no more fragments

  BegIniFragmLocated: //***** i is index of [FragmName] string

  SL := TStringList.Create;

  for j := i+1 to AStrings.Count-1 do // loop till next [FragmName] string
  begin
    Str := Trim(AStrings[j]);
    if (Str = '') or (Str[1] = ';') then Continue; // all empty strings should be skipped in Windows ini file format
                                                    // Skip comments (';' char is comment flag)
    if Str[1] <> '[' then // add Str to SL (to current Fragment)
      SL.Add( Str )
    else begin
    //***** Here: End Fragment (Beg of next Section) Located ( AStrings[j][1] = Str[1] = '[' )

      LocalAddReplaceFragm();
      i := j;
      goto IniFragmHeader;
//      ibeg := j;
//      goto AddNextIniFragm;
    end;
  end; // for j := i+1 to AStrings.Count-1 do // loop till next [FragmName] string

//  if SL.Count <> 0 then // Add Last Ini Fragment

  LocalAddReplaceFragm(); // Add Last Ini Fragment

  //*** end of processing fragments in Windows Ini file format

  Fin: //***** all Fragments are added to Self

  MTFragmsList.EndUpdate();
  SL.Free;
end; // end_of procedure TN_MemTextFragms.AddFragms


//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_MemTextFragms\SaveToVFile
//******************************************** TN_MemTextFragms.SaveToVFile ***
// Save all Text Fragments to Virtual File given by Name
//
//     Parameters
// AVFileName    - Virtual File Name
// ACreateParams - Virtual File Create Parameters
//
procedure TN_MemTextFragms.SaveToVFile( AVFileName: string;
                                      const ACreateParams: TK_DFCreateParams );
var
  SL: TStringList;
  FileName: string;
begin
  SL := TStringList.Create;
  SelfAddToStrings( SL );
  FileName := K_ExpandFileName( AVFileName );
  K_VFSaveStrings( SL, FileName, ACreateParams );
  SL.Free;
end; // end_of procedure TN_MemTextFragms.SaveToVFile(full)

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\TN_MemTextFragms\AddFromVFile
//******************************************* TN_MemTextFragms.AddFromVFile ***
// Add Text Fragments from Virtual File given by Name
//
//     Parameters
// AVFileName - Virtual File Name
// APassword  - Virtual File access password
// Result     - Returns TRUE if file content was successfully read
//
// Expanded File Name will be stored in MTVFileName and File Create Parameters 
// (get from File штсдгвштп зфыыцщкв) are stored in MTCreateParams.
//
function TN_MemTextFragms.AddFromVFile( AVFileName: string;
                                        const APassword: AnsiString = '' ): Boolean;
var
  SL: TStringList;
begin
  MTVFileName := K_ExpandFileName( AVFileName );
  SL := TStringList.Create;

  Result := K_VFLoadStrings( SL, MTVFileName, @MTCreateParams, APassword );
  if Result then AddFragms( SL );

  SL.Free;
end; // end_of function TN_MemTextFragms.AddFromVFile


//******************************  Global Procedures  ********************

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_PVAE
//****************************************************************** N_PVAE ***
// Get Pointer to given Virtual Records Array element
//
//     Parameters
// AVArray - given Virtual Records Array (TK_RArray - Records Array, TK_UDRArray
//           - IDB Object Records Array Container, TK_UDVector - IDB Object 
//           special Records Array syncronized to some Code Space Elements 
//           Container)
// AInd    - given Index
// Result  - Returns untyped pointer to AVArray element
//
function N_PVAE( AVArray: TObject; AInd: integer ): Pointer;
begin
  Result := nil;
  if AVArray = nil then Exit;

  if AVArray is TK_RArray then
    Result := TK_RArray(AVArray).P( AInd )
  else
    Result := TK_UDRArray(AVArray).PDE( AInd );
end; // function N_PVAE

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_UDToRA
//**************************************************************** N_UDToRA ***
// Convert given Virtual Records Array to Records Array Object
//
//     Parameters
// AVArray  - given Virtual Records Array (TK_RArray - Records Array or 
//            TK_UDRArray - IDB Object Records Array Container)
// AMDFlags - move Records Array Data Flags used for Records Array copy creation
//
// If AVArray is TK_RArray then nothing will be done. If AVArray is TK_UDRArray,
// then AVArray will be set to the copy of source TK_UDRArray internal Records 
// Array.
//
procedure N_UDToRA( var AVArray: TObject; AMDFlags: TK_MoveDataFlags );
begin
  if AVArray is TK_RArray then Exit; // already RArray, nothing to do

  AVArray := K_RCopy( TK_UDRArray(AVArray).R, AMDFlags );
end; // procedure N_UDToRA

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_ReplaceChildren
//******************************************************* N_ReplaceChildren ***
// Replace IDB Child Objects
//
//     Parameters
// ASrcUD - source IDB Parent Object
// ADstUD - destination IDB Parent Object
//
// Replace Child Objects of one IDB Parent Object by Child Objects of another 
// IDB Parent Object:
//#F
// 1) clear ADstUD Child Objects
// 2) add all ASrcUD Child Objects to ADstUD childs
// 3) change added Child Objects Owner to from ASrcUD (if any) to ADstUD
//#/F
//
procedure N_ReplaceChildren( ASrcUD, ADstUD: TN_UDBase );
var
  i: integer;
  CurChild: TN_UDBase;
begin
// 1) clear current ADstUD children
  ADstUD.ClearChilds();

// 2,3) add all ASrcUD children to ADstUD and change children's owner from ASrcUD to ADstUD

  for i := 0 to ASrcUD.DirHigh() do // along all ASrcUD children
  begin
    CurChild := ASrcUD.DirChild( i );
    if CurChild = nil then Continue;

    ADstUD.AddOneChild( CurChild );

    if (CurChild.Owner = ASrcUD) or (CurChild.Owner = nil) then
      CurChild.Owner := ADstUD; // Change Owner
  end; // for i := 0 to ASrcUD.DirHigh() do // along all children

end; // procedure N_ReplaceChildren

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CopyUDRArray1
//********************************************************* N_CopyUDRArray1 ***
// Copy given IDB Records Array Container Object including Child Objects 
// (variant 1)
//
//     Parameters
// ASrcUD - source IDB Parent Object
// ADstUD - destination IDB Parent Object
//
// Copy given ASrcUD UDRArray to given ADstUD, variant #1: 1) replace ADstUD 
// internal Records Array by reference to ASrcUD internal Records Array (real 
// copy will be created after IDB serialization/deserialization) 2) clear ADstUD
// Child Objects 3) add all ASrcUD Child Objects to ADstUD childs 4) change 
// added Child Objects Owner to from ASrcUD (if any) to ADstUD
//
procedure N_CopyUDRArray1( ASrcUD, ADstUD: TK_UDRArray );
begin
  // 1) create copy of ASrcUD.R RArray
  ADstUD.R.ARelease(); // clear current ASrcUD.R RArray
  ADstUD.R := ASrcUD.R.AAddRef();

  // 2,3,4:
  N_ReplaceChildren( ASrcUD, ADstUD );
end; // procedure N_CopyUDRArray1

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetCurRAFrFieldInfo
//*************************************************** N_GetCurRAFrFieldInfo ***
// Get Info about Current Field in Records Array View/Edit Frame
//
//     Parameters
// ARAFrame - Records Array View/Edit Frame
// APInfo   - pointer to Field Info Record
//
procedure N_GetCurRAFrFieldInfo( ARAFrame: TK_FrameRAEdit; APInfo: TN_PCurRAFrFieldInfo );
// (later add checking some given CSS)
begin
  with ARAFrame, APInfo^ do
  begin
    CurFType.All := 0;
    CurFType.DTCode := -1;
    CurFTypeName := '';
    CurPRArray   := nil;

    if (CurLCol <= -1) or (CurLRow <= -1) then Exit; // no current field

    CurFType := RAFCArray[CurLCol].CDType;

    N_s := RAFCArray[CurLCol].Name; // debug, is TypeName for base type fields!

    if (CurFType.D.TFlags and K_ffArray) <> 0 then // Current Field is RArray
    begin
      CurPRArray := TK_PRArray(DataPointers[CurLRow][CurLCol]);

      if CurPRArray^ <> nil then // get real Code of Dynamic RArray (if DTCode = nptNotDef)
        CurFType := CurPRArray^.ArrayType;

    end; // if (CurFType.D.TFlags and K_ffArray) <> 0 then // Current Field is RArray

    CurFTypeName := K_GetExecTypeName( CurFType.All );
  end; // with ARAFrame, APInfo^ do
end; // procedure N_GetCurRAFrFieldInfo

//*****************************************  N_CreateUDFont  ******
// Create and return UDLogFont
//
function N_CreateUDFont( AName, AFace: string; ASize: float;
                                        AStyle: TN_LFStyle ): TN_UDLogFont;
begin
  Result :=TN_UDLogFont(K_CreateUDByRTypeName( 'TN_LogFont', 1, N_UDLogFontCI ));
  Result.ObjName := AName;
  with TN_PLogFont(Result.R.P)^ do
  begin
    LFHeight   := ASize;
    LFFaceName := AFace;
    LFStyle    := AStyle;
  end;
end; // function N_CreateUDFont

//****************************************  N_SetUDFont  ******
// Set given AUDLogFont or (if nil) default font to given AOCanv
// Return UDFont, that was set to AOCanv - AUDLogFont (if not nil) or default font
//
function N_SetUDFont( AUDLogFont: TN_UDLogFont; AOCanv: TN_OCanvas;
                      AScaleCoef: float = 1.0; ABLAngle: float = 0;
                                         ACharAngle: float = 0 ): TN_UDLogFont;
begin
  Result := AUDLogFont;
  if Result = nil then // use defaul font
    Result := TN_UDLogFont(N_DefObjectsDir.DirChildByObjName( 'DefFont' ));
//    Result := TN_UDLogFont(N_GetUObj( N_DefObjectsDir, 'DefFont' ));

  if (ABLAngle = 0) and (ACharAngle = 0) then
    Result.SetFont( AOcanv, AScaleCoef )
  else
    Result.SetFont( AOcanv, AScaleCoef, ABLAngle, ACharAngle );
end; // function N_SetUDFont

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CreateRArrayNFont
//***************************************************** N_CreateRArrayNFont ***
// Create NFont Records Array with given Font Face Name and Height
//
//     Parameters
// AHeight   - Font Height
// AFaceName - Font Face Name
// Result    - Returns created Records Array with single element assigned by 
//             given Font Attributes
//
function N_CreateRArrayNFont( AHeight: float; AFaceName: string ): TK_RArray;
begin
  Result := K_RCreateByTypeCode( N_SPLTC_NFont, 1 );
  with TN_PNFont(Result.P)^ do
  begin
    NFLLWHeight := AHeight;
    NFFaceName  := AFaceName;
    NFWin.lfCharSet := RUSSIAN_CHARSET; // = 204
  end;
end; // function N_CreateRArrayNFont

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SetNFont
//************************************************************** N_SetNFont ***
// Set in given Canvas given Font with given Base Line Angle in degree
//
//     Parameters
// ANFont   - Font to set (is Virtual Records Array i.e. TK_RArray or 
//            TK_UDRArray of TN_NFont)
// AOCanv   - Own Canvas Object
// ABLAngle - Font Angle in degree
// AFontInd - Font Record Index in ANFont Records Array
//
procedure N_SetNFont( ANFont: TObject; AOCanv: TN_OCanvas;
                      ABLAngle: float = 0; AFontInd: integer = 0 );
var
  NewPixSize, NameSize: integer;
  WideFaceName: WideString;
  PNFont: TN_PNFont;
  IsUDRArray: boolean;
  FontsRArray: TK_RArray;
begin
  if ANFont = nil then // use default NFont
    ANFont := TN_UDNFont(N_DefObjectsDir.DirChildByObjName( N_DefNFontName ));
//    ANFont := TN_UDNFont(N_GetUObj( N_DefObjectsDir, N_DefNFontName ));

  if ANFont is TK_UDRArray then // ANFont is UDRArray
  begin
    FontsRArray := TK_UDRArray(ANFont).R;
    IsUDRArray := True;
  end else //********************* ANFont is RArray
  begin
    FontsRArray := TK_RArray(ANFont);
    IsUDRArray := False;
  end;

  if (AFontInd < 0) or (AFontInd >= FontsRArray.ALength()) or
                  (FontsRArray.ElemSType <> N_SPLTC_NFont)    then Exit;
  PNFont := FontsRArray.P( AFontInd );
  if PNFont = nil then Exit;

  with PNFont^, AOCanv do
  begin
    N_d1 := NFLLWHeight;
    N_d2 := CurLFHPixSize;
    NewPixSize := - Round( NFLLWHeight * CurLFHPixSize );
//    if abs(NewPixSize) <= 2 then NewPixSize := -1;

    if (NFWin.lfHeight <> NewPixSize) or (ABLAngle <> 0) then // Delete Cur Handle
    begin
      NFWin.lfHeight := NewPixSize;
      if NFHandle <> 0 then Windows.DeleteObject( NFHandle );
      NFHandle := 0;
    end;

    if NFHandle = 0 then // Create New Font Handle and select it in AOCanv.HMDC
    begin
      NFWin.lfEscapement := Round( 10 * ABLAngle );
      NFWin.lfOrientation := Round( 10 * ABLAngle );

      if NFWeight = 0 then // set lfWeight by NFBold flag
      begin
        if NFBold = 0 then NFWin.lfWeight := FW_NORMAL
                      else NFWin.lfWeight := FW_BOLD;
      end else //************ set lfWeight by NFWeight
      begin
        NFWin.lfWeight := NFWeight;
      end;

      FillChar( NFWin.lfFaceName[0], 64, 0 ); // clear lfFaceName field, always 64 bytes
      NameSize := Length( NFFaceName );
      if NameSize > 31 then NameSize := 31;
      if NameSize > 0 then
      begin
        WideFaceName := NFFaceName; // Always Wide!
        Move( WideFaceName[1], NFWin.lfFaceName[0], NameSize*2 );
      end;

      // All fields of NFWin (Windows LogFontW) are OK

      NFHandle := Windows.CreateFontIndirectW( tagLOGFONTW(NFWin) ); // ok for both Ansi and Wide Chars

      SelectObject( HMDC, NFHandle );
      ConFontHandle := NFHandle;

      //*** check if just created NFHandle should be deleted

      if not IsUDRArray or (Round(10*ABLAngle) <> 0) then
      begin
        Windows.DeleteObject( NFHandle );
        NFHandle := 0;
        ConFontHandle := 0;
      end;

    end else // NFHandle already exists (NFHandle <> 0)
    begin
      if ConFontHandle <> NFHandle then // Select Font in Device Context
        SelectObject( HMDC, NFHandle );

      ConFontHandle := NFHandle;
    end;

  end; // with PNFont^, AOCanv do
end; // procedure N_SetNFont

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_DebSetNFont
//*********************************************************** N_DebSetNFont ***
// Set in given Canvas new Font with given Size, Face  and  Base Line Angle in 
// degree
//
//     Parameters
// AOCanv    - Own Canvas Object
// AFontSize - Font Height in LLW
// AFaceNum  - Font FaceName integer index: 0-SmallFonts, 1-Courier New, 
//             else-Arial
// ABLAngle  - Base Line Angle in degree
//
procedure N_DebSetNFont( AOCanv: TN_OCanvas; AFontSize: float; AFaceNum: integer;
                                                             ABLAngle: float = 0 );
var
  NFont: TK_RArray;
begin
  NFont := K_RCreateByTypeName( 'TN_NFont', 1 );
  with TN_PNFont(NFont.P())^ do
  begin
    NFLLWHeight := AFontSize;
    case AFaceNum of
      0: if AFontSize <= 7 then NFFaceName := 'Small Fonts'
                           else NFFaceName := 'Microsoft Sans Serif';
      1: NFFaceName := 'Courier New';
    else
      NFFaceName := 'Arial';
    end;
  end; // with TN_PNFont(NFont.P())^ do

  N_SetNFont( NFont, AOCanv, ABLAngle );
  NFont.Free;
end; // procedure N_DebSetNFont

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_DebDrawString
//********************************************************* N_DebDrawString ***
// Draw one string using given text color and font size
//
//     Parameters
// AOCanv        - Own Canvas Object
// APixBasePoint - upper left string corner in Pixel coordinates
// AStr          - string to draw
// AFontColor    - Font Foreground Color (BackGroung Color is always 
//                 transparent)
// AFontSize     - Font Size (Height) in LLW
//
procedure N_DebDrawString( AOCanv: TN_OCanvas; APixBasePoint: TPoint; AStr: string;
                                               AFontColor, AFontSize: integer );
var
  StrLeng: integer;
begin
  StrLeng := Length( AStr );
  if StrLeng = 0 then Exit; // a precaution

  N_DebSetNFont( AOCanv, AFontSize, 0 );
  AOCanv.SetFontAttribs( AFontColor );

  Windows.ExtTextOut( AOCanv.HMDC, APixBasePoint.X, APixBasePoint.Y, 0,
                                                 nil, @AStr[1], StrLeng, nil );
end; //*** end of procedure N_DebDrawString

{
//************************************************************** N_SetNFont ***
// Set in given AOCanv ANFont with given Base Line Angle in degree
// ANFont - Font to set (is VArray i.e. TK_RArray or TK_UDRArray of TN_NFont)
//
procedure N_SetNFont( ANFont: TObject; AOCanv: TN_OCanvas; ABLAngle: float );
var
  PNFont: TN_PNFont;
  NewFontHandle, IsUDRArray: boolean;
  PrevHFont: HFont;
begin
  if ANFont is TK_UDRArray then // ANFont is UDRArray
  begin
    PNFont := TK_UDRArray(ANFont).R.P();
    IsUDRArray := True;
  end else //********************* ANFont is RArray
  begin
    PNFont := TK_RArray(ANFont).P();
    IsUDRArray := False;
  end;

  if PNFont = nil then Exit;

  with PNFont^, AOCanv do
  begin

    if not IsUDRArray then NFHandle := 0;
    NewFontHandle := False;

    NFHandle := 0; // temporary

    if NFHandle = 0 then // Font was not created yet
    begin
      NFWin.lfEscapement := Round( 10 * ABLAngle );
      N_CreateFontHandle( PNFont, CurLFHPixSize );
      NewFontHandle := True;
    end;

    // NFHandle can safly be selected in several device contexts!

    if NewFontHandle or
       (ConFontHandle <> NFHandle) then // Select Font in Device Context
    begin
      PrevHFont := SelectObject( HMDC, NFHandle );
      if ConDelCurHFont then DeleteObject( PrevHFont );

      ConDelCurHFont := not IsUDRArray;
      ConFontHandle := NFHandle;
    end;

  end; // with PNFont^, AOCanv do
end; // procedure N_SetNFont


//****************************************  N_SetUDFont  ******
// Set given AUDLogFont or (if nil) default font to given AOCanv
// Return UDFont, that was set to AOCanv - AUDLogFont (if not nil) or default font
//
function N_SetUDNFont( ANFont: TN_UDLogFont; AOCanv: TN_OCanvas;
                      AScaleCoef: float = 1.0; ABLAngle: float = 0;
                                         ACharAngle: float = 0 ): TN_UDLogFont;
begin
  Result := AUDLogFont;
  if Result = nil then // use defaul font
    Result := TN_UDLogFont(N_GetUObj( N_DefObjectsDir, 'DefFont' ));

  if (ABLAngle = 0) and (ACharAngle = 0) then
    Result.SetFont( AOcanv, AScaleCoef )
  else
    Result.SetFont( AOcanv, AScaleCoef, ABLAngle, ACharAngle );
end; // function N_SetUDFont
}

//****************************************  N_GetUDFontParams  ******
// Return typed Pointer to given AUDLogFont params (AUDLogFont may be nil)
//
function N_GetUDFontParams( AUDLogFont: TN_UDLogFont ): TN_PLogFont;
var
  UDLogFont: TN_UDLogFont;
begin
  UDLogFont := AUDLogFont;
  if UDLogFont = nil then // use defaul font
    UDLogFont := TN_UDLogFont(N_DefObjectsDir.DirChildByObjName( 'DefFont' ));
//    UDLogFont := TN_UDLogFont(N_GetUObj( N_DefObjectsDir, 'DefFont' ));

  Result := TN_PLogFont(UDLogFont.R.P);
end; // function N_GetUDFontParams

//******************************************************** N_ScanOnlyOwners ***
// can be used in scanning SubTree, Analise input params and return Result,
// needed for scanning only Owners SubTree
//
function N_ScanOnlyOwners( UDParent: TN_UDBase; var UDChild: TN_UDBase;
                                      ChildInd: integer ): TK_ScanTreeResult;
begin
  if ChildInd <> -1 then // UDChild is UDBase Child (not RArray field of TN_UDBase type)
  begin
    if UDChild.Owner = UDParent then // UDChild belongs to Owners SubTree
    begin
      Result := K_tucOK;
    end else // UDChild do NOT belongs to Owner Tree
      Result := K_tucSkipSubTree;
  end else // UDChild is RArray TN_UDBase field (not UDBase Child)
    Result := K_tucSkipSibling; // Skip subsequent refs from RArray fields
end; // function N_ScanOnlyOwners

//*********************************************************** N_ScanAllRefs ***
// can be used in scanning SubTree, Analise input params and return Result,
// needed for scanning all Owners SubTree Nodes and UDRefs in them
//
function N_ScanAllRefs( UDParent: TN_UDBase; var UDChild: TN_UDBase;
                                      ChildInd: integer ): TK_ScanTreeResult;
begin
  if (UDChild.Owner = UDParent) and (ChildInd <> -1) then
    Result := K_tucOK // UDChild belongs to Owners SubTree, scan it's children
  else
    Result := K_tucSkipSubTree; // UDChild do NOT belongs to Owner Tree, skip children
end; // function N_ScanAllRefs

//**********************************************  N_IncCSCode  ***
// Increment given ACSCode by AIncValue in given ACSS (should be TK_UDDCSSpace)
//
function N_IncCSCode( ACSS: TN_UDBase; ACSCode: string; AIncValue: integer ): string;
var
  NewCSInd, CSSInd: integer;
  CSCodes: TK_RArray;
begin
  Result := '';
  if not (ACSS is TK_UDDCSSpace) then Exit;

  with TK_UDDCSSPace(ACSS) do
  begin
    CSSInd := IndexByCode( ACSCode );
    if CSSInd = -1 then Exit; // no such ACSCode in ACSS

    Inc( CSSInd, AIncValue ); // needed new value of ACSS Index
    CSSInd := Min( CSSInd, PDRA()^.AHigh() );
    NewCSInd := PInteger(DP(CSSInd))^; // needed new value of CS Index

    CSCodes := TK_PDCSpace(GetDCSpace().R.P)^.Codes;
    Result := PString(CSCodes.P(NewCSInd))^;
  end; // with TK_UDDCSPace(ACS) do
end; // procedure function N_IncCSCode

//**********************************************  N_IncCSCodesInUDBase  ***
// Increment CSCodes by AIncValue in given AUDBase
// (later add checking some given CSS)
//
procedure N_IncCSCodesInUDBase( AUDBase: TN_UDBase; AIncValue: integer );
begin
{
var
  i: integer;
  CSCode: string;
  ParamsList: TK_RArray;
  if not (AUDBase is TK_UDComponent) then Exit;

  ParamsList := TK_PCompBase(TK_UDComponent(AUDBase).R.P).SetParams;
  if ParamsList = nil then Exit;

  if K_GetExecTypeName(ParamsList.DType.All) <> 'TN_SetParamInfo' then Exit;

  for i := 0 to ParamsList.AHigh() do // along SetParams Items
  with TN_PSetParamInfo(ParamsList.P(i))^ do
  begin
    if SPSrcPath[1] = '#' then // CS Code is given (ASrcUObj should be TK_UDVector)
    begin
      if not (SPSrcUObj is TK_UDVector) then Continue;

      // later add checking some given CSS, now any CSS is OK

      CSCode := Copy( SPSrcPath, 2, Length(SPSrcPath) );
      SPSrcPath := '#' + N_IncCSCode( TK_UDVector(SPSrcUObj).GetDCSSpace(),
                                                             CSCode, AIncValue );
    end; // if SPSrcPath[1] = '#' then
  end; // for i := 0 to ParamsList.AHigh() do
}
end; // procedure N_IncCSCodesInUDBase

//**********************************************  N_SetCSCodeInUDBase  ***
// Set given ACSCode in given AUDBase
// return last encountered CSS in PCSS^ (if PCSS <> nil)
// (later add checking some given CSS)
//
procedure N_SetCSCodeInUDBase( AUDBase: TN_UDBase; ACSCode: string;
                                                       PCSS: PPointer = nil );
begin
{
var
  i: integer;
  ParamsList: TK_RArray;
  CSS: TK_UDDCSSpace;
  if not (AUDBase is TK_UDComponent) then Exit;

  ParamsList := TK_PCompBase(TK_UDComponent(AUDBase).R.P).SetParams;
  if ParamsList = nil then Exit;

  if K_GetExecTypeName(ParamsList.DType.All) <> 'TN_SetParamInfo' then Exit;

  for i := 0 to ParamsList.AHigh() do // along SetParams Items
  with TN_PSetParamInfo(ParamsList.P(i))^ do
  begin
    if SPSrcPath[1] = '#' then // CS Code is given (ASrcUObj should be TK_UDVector)
    begin
      if not (SPSrcUObj is TK_UDVector) then Continue;

      CSS := TK_UDVector(SPSrcUObj).GetDCSSpace();

      // later add checking some given CSS, now any CSS is OK

      if CSS.IndexByCode( ACSCode ) <> -1 then // ACSCode exists in CSS
      begin
        SPSrcPath := '#' + ACSCode;

        if PCSS <> nil then
          PCSS^ := CSS;

      end; // if CSS.IndexByCode( ACSCode ) <> -1 then // ACSCode exists in CSS
    end; // if SPSrcPath[1] = '#' then
  end; // for i := 0 to ParamsList.AHigh() do
}
end; // procedure N_SetCSCodeInUDBase

//**********************************************  N_IncCSCodesInSubTree  ***
// Increment CSCodes by AIncValue in all level children of given ARoot
//
procedure N_IncCSCodesInSubTree( ARoot: TN_UDBase; AIncValue: integer );
var
  ScanObj: TN_ScanDTreeObj;
begin
  ScanObj := TN_ScanDTreeObj.Create();
  ScanObj.IncValue := AIncValue;

  N_IncCSCodesInUDBase( ARoot, AIncValue ); // ScanSubTree does not process Root
  ARoot.ScanSubTree( ScanObj.IncrementCSCodes );

  ScanObj.Free();
end; // procedure N_IncCSCodesInSubTree

//**********************************************  N_SetCSCodeInSubTree  ***
// Set given ACSCode in all level children of given ARoot
// return last encountered CSS in PCSS^ (if PCSS <> nil)
//
procedure N_SetCSCodeInSubTree( ARoot: TN_UDBase; ACSCode: string;
                                                       PCSS: PPointer = nil );
var
  ScanObj: TN_ScanDTreeObj;
begin
  ScanObj := TN_ScanDTreeObj.Create();
  ScanObj.CSCode := ACSCode;

  N_SetCSCodeInUDBase( ARoot, ACSCode, @ScanObj.ResPointer ); // ScanSubTree does not process Root
  ARoot.ScanSubTree( ScanObj.SetCSCode );

  if PCSS <> nil then
    PCSS^ := ScanObj.ResPointer; // some CSS set in ScanObj.SetCSCode

  ScanObj.Free();
end; // procedure N_SetCSCodeInSubTree

//************************************************* N_CopyFieldsExceptNames ***
// Copy all Fields from ASrcUDBase to ADstUDBase except ObjName, ObjAliase, ObjInfo
//
// ASrcUDBase - given Source UDBase
// ADstUDBase - given Destination  UDBase
//
procedure N_CopyFieldsExceptNames( ASrcUDBase, ADstUDBase: TN_UDBase );
var
  Name, Aliase, Info: string;
begin
  Name   := ADstUDBase.ObjName;
  Aliase := ADstUDBase.ObjAliase;
  Info    := ADstUDBase.ObjInfo;

  ADstUDBase.CopyFields( ASrcUDBase );

  ADstUDBase.ObjName   := Name;
  ADstUDBase.ObjAliase := Aliase;
  ADstUDBase.ObjInfo   := Info;
end; // procedure N_CopyFieldsExceptNames


//********************************************** N_GetPointerByName ***
// Get Pointer to UDBase or its fragment by given Name
//
function N_GetPointerByName( AName: string ): Pointer;
begin
  Result := nil; // not implemented
end; // end of function N_GetPointerByName

//********************************************** N_CreateUniqueUObjName ***
// Get new Child Object Unique Name for given Parent
//
//     Parameters
// ADir - IDB Parent Object
// AName - unique name prefix
// Result - Returns IDB Child Object Name unique for given Parent Object
//
// Unique name is created as given Name Prefix + Unique Number
//
function N_CreateUniqueUObjName( AParentDir: TN_UDBase; AName: string ): string;
var
  Number, n: integer;
  nc: char;
begin
  if AName = '' then AName := 'New';
  Result := AName;
  if -1 = AParentDir.IndexOfChildObjName( Result ) then Exit; // is already unique

  n := Length( AName );
  nc := AName[n];

  if (nc >= '0') and (nc <= '9') then // last char is digit
    Number := Integer(nc) - Integer('0') + 1
  else
  begin
    Number := 1;
    Inc( n );
  end;

  while True do
  begin
    Result := Copy(AName, 1, n-1) + Format( '%d', [Number] );

    if -1 = AParentDir.IndexOfChildObjName( Result ) then Exit;

    Inc(Number);
  end; // while True do
end; // end of function N_CreateUniqueUObjName


//******************************************************* N_CreateUDBaseDir ***
// Create new empty UDBase Dir in given AParentDir with ANewDirName
//
//     Parameters
// AParentDir  - given Parent Object where NewDir (Result) should be created
// ANewDirName - given NewDir ObjName
// Result      - Return created empy UDBase Dir
//
function N_CreateUDBaseDir( AParentDir: TN_UDBase; ANewDirName: string ): TN_UDBase;
begin
  Result := TN_UDBase.Create();
  Result.ObjName := ANewDirName;
  AParentDir.AddOneChildV( Result );
end; // function N_CreateUDBaseDir

//***************************************************** N_CreateUDBaseClone ***
// Create Clone of given ASrcUObj UDBase in given AParent dir with ANewName
//
//     Parameters
// AParentDir   - given Parent Object where new UObj (Result) should be created
// ANewUObjName - given new UObj (Result) ObjName
// ASrcUObj     - given Source UDBase to clone
// Result       - Return created UObj (clone of ASrcUObj)
//
function N_CreateUDBaseClone( AParentDir: TN_UDBase; ANewUObjName: string; ASrcUObj: TN_UDBase ): TN_UDBase;
begin
  Result := ASrcUObj.Clone();
  Result.ObjName := ANewUObjName;
  AParentDir.AddOneChildV( Result );
end; // function N_CreateUDBaseClone

//************************************************* N_CreateUniqueUDBaseDir ***
// Create new empty UDBase Dir in given AParentDir with Unique name, based
// on given ANewDirName
//
//     Parameters
// AParentDir  - given Parent Object where NewDir (Result) should be created
// ANewDirName - given NewDir ObjName
// Result      - Return created empy UDBase Dir
//
function N_CreateUniqueUDBaseDir( AParentDir: TN_UDBase; ANewDirName: string ): TN_UDBase;
var
  UniqueUObjName: string;
begin
  UniqueUObjName := N_CreateUniqueUObjName( AParentDir, ANewDirName );
  Result := N_CreateUDBaseDir( AParentDir, UniqueUObjName );
end; // function N_CreateUniqueUDBaseDir

//********************************************************* N_PrepUDBaseDir ***
// Prepare (Find or Create) UDBase Dir in given AParentDir with ANewDirName
//
//     Parameters
// AParentDir  - given Parent Object where NewDir (Result) should be found or created
// ANewDirName - given NewDir ObjName
// Result      - Return found or created UDBase Dir
//
function N_PrepUDBaseDir( AParentDir: TN_UDBase; ANewDirName: string ): TN_UDBase;
begin
  Result := N_GetUObjByPath( AParentDir, ANewDirName );

  if Result = nil then
    Result := N_CreateUDBaseDir( AParentDir, ANewDirName );
end; // function N_PrepUDBaseDir

//******************************************************* N_PrepUDBaseClone ***
// Prepare (Find or Clone ASrcUObj) any UObj in given AParent dir with ANewName
//
//     Parameters
// AParentDir   - given Parent Object where new UObj (Result) should be created
// ANewUObjName - given new UObj (Result) ObjName
// ASrcUObj     - given Source UDBase to clone
// Result       - Return found or created UObj
//
function N_PrepUDBaseClone( AParentDir: TN_UDBase; ANewUObjName: string; ASrcUObj: TN_UDBase ): TN_UDBase;
begin
  Result := N_GetUObjByPath( AParentDir, ANewUObjName );

  if Result = nil then
    Result := N_CreateUDBaseClone( AParentDir, ANewUObjName, ASrcUObj );
end; // function N_PrepUDBaseClone

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CopyChildRefs
//***************************************************** N_ReplaceChildRefs1 ***
// Replace all Childs in one IDB Root by references to Childs from another IDB
// Root, all Childs Owners remains the same
//
//     Parameters
// ASrcDir - source IDB Root Object
// ADstDir - destination IDB Root Object
//
procedure N_ReplaceChildRefs1( ASrcDir, ADstDir: TN_UDBase );
var
  i, Leng: integer;
begin
  if ASrcDir = nil then Exit;

  Leng := ASrcDir.DirLength();
  ADstDir.ClearChilds( 0, Leng ); // Enlarges ADstDir if Leng > ADstDir.DirLength()

  for i := 0 to Leng-1 do
    ADstDir.PutDirChildV( i, ASrcDir.DirChild(i) );
end; // end of procedure N_ReplaceChildRefs1

//***************************************************** N_ReplaceChildRefs2 ***
// Replace all Childs in one IDB Root by references to Childs from another IDB
// Root and replace all Childs Owners by ADstDir
//
//     Parameters
// ASrcDir - source IDB Root Object
// ADstDir - destination IDB Root Object
//
procedure N_ReplaceChildRefs2( ASrcDir, ADstDir: TN_UDBase );
var
  i, Leng: integer;
  Child: TN_UDBase;
begin
  if ASrcDir = nil then Exit;

  Leng := ASrcDir.DirLength();
  ADstDir.ClearChilds( 0, Leng ); // Enlarges ADstDir if Leng > ADstDir.DirLength()

  for i := 0 to Leng-1 do
  begin
    Child := ASrcDir.DirChild(i);
    Child.Owner := ADstDir;
    ADstDir.PutDirChildV( i, Child );
  end;end; // end of procedure N_ReplaceChildRefs2

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CreateOneLevelClone
//*************************************************** N_CreateOneLevelClone ***
// Create One Level clone of given IDB SubTree Root Object
//
//     Parameters
// ASrc   - given IDB SubTree Root Object for one level clone
// Result - Returns created Root Object (result value is nil if source Root
//          Object is not assigned).
//
// Only Root Object is cloned. Source Root Object Child references are copied to
// to resulting Root.
//
function N_CreateOneLevelClone( ASrcRoot: TN_UDBase ): TN_UDBase;
begin
  Result := nil;
  if ASrcRoot = nil then Exit;

  Result := ASrcRoot.Clone( True );
  K_SetChangeSubTreeFlags( Result );
  N_ReplaceChildRefs1( ASrcRoot, Result );
end; // end of function N_CreateOneLevelClone

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CreateSubTreeClone
//**************************************************** N_CreateSubTreeClone ***
// Create full clone of IDB SubTree given by Root Object
//
//     Parameters
// ASrcRoot - given IDB SubTree Root Object
// Result   - Returns created Root Object (result value is nil if source Root
//            Object is not assigned).
//
// IDB SubTree clone is created by it serialization and back deserialization to
// Result
//
function N_CreateSubTreeClone( ASrcRoot: TN_UDBase ): TN_UDBase;
begin
  Result := nil;
  if ASrcRoot = nil then Exit;

//***** Clone in Text mode (for debug):
//  K_SaveTreeToText( ASrcRoot, K_SerialTextBuf );
//  Result := K_LoadTreeFromText( K_SerialTextBuf, not N_MEGlobObj.NotUseRefInds );
//  K_SetArchiveCursor( K_CurArchive );
//  N_SetSubTreeWasChanged( Result );

//***** Clone in Binary mode:
  K_SaveTreeToMem( ASrcRoot, N_SerialBuf );
  Result := K_LoadTreeFromMem( N_SerialBuf );
  K_SetArchiveCursor( K_CurArchive );
  N_SetSubTreeWasChanged( Result );
end; // end of function N_CreateSubTreeClone

//*************************************************** N_CreateSubTreeClone3 ***
// Create full clone of IDB SubTree and add it to given Parent
//
//     Parameters
// AParentDir   - given Parent Object where full clone (Result) should be created
// ANewUObjName - given resulting clone ObjName
// ASrcUObj     - given IDB SubTree Root Object
// Result       - Returns created Root Object (result value is nil if source Root
//                 Object is not assigned).
//
// IDB SubTree clone is created by it serialization and back deserialization to
// Result
//
function N_CreateSubTreeClone3( AParentDir: TN_UDBase; ANewUObjName: string; ASrcUObj: TN_UDBase ): TN_UDBase;
begin
  Result := N_CreateSubTreeClone( ASrcUObj );
  if Result = nil then Exit;

  Result.ObjName := ANewUObjName;
  AParentDir.AddOneChildV( Result );
  K_SetChangeSubTreeFlags( Result );
end; // end of function N_CreateSubTreeClone3

//****************************************************** N_PrepSubTreeClone ***
// Prepare (Find or Create) full clone of IDB SubTree
//
//     Parameters
// AParentDir   - given Parent Object where full clone (Result) should be created
// ANewUObjName - given resulting clone ObjName
// ASrcUObj     - given IDB SubTree Root Object
// Result       - Returns created Root Object (result value is nil if source Root
//                 Object is not assigned).
//
// IDB SubTree clone is created by it serialization and back deserialization to
// Result
//
function N_PrepSubTreeClone( AParentDir: TN_UDBase; ANewUObjName: string; ASrcUObj: TN_UDBase ): TN_UDBase;
var
  TmpUDBase: TN_UDBase;
begin
  Result := N_GetUObjByPath( AParentDir, ANewUObjName );

  if Result = nil then
    Result := N_CreateSubTreeClone3( AParentDir, ANewUObjName, ASrcUObj )
  else // Result <> nil
  begin
    TmpUDBase := N_CreateSubTreeClone( ASrcUObj );
    N_CopyFieldsExceptNames( TmpUDBase, Result );
    N_ReplaceChildRefs2( TmpUDBase, Result );
    TmpUDBase.UDDelete();
  end;
end; // end of function N_PrepSubTreeClone

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_ForceSingleInstance
//*************************************************** N_ForceSingleInstance ***
// Force Single Instance of IDB Object given by it's Visual Node
//
//     Parameters
// ACloneType - IDB Object clone type
// AVNode     - IDB Object Visual Node Object (VNode)
// Result     - Returns created IDB Object clone or source IDB Object (if
//              RefCounter = 1)
//
// If given IDB Object RefCounter > 1, then it's clone is created and IDB Object
// reference defined by Visual Node is replaced by created clone. Clone type
// depends on ACloneType parameter - One Level Clone or Full SubTree Clone.
//
function N_ForceSingleInstance( ACloneType: TN_UObjType; AVNode: TN_VNode ): TN_UDBase;
var
  CurUObjInd: integer;
  ParentUObj, CurUObj: TN_UDBase;
begin
  Result := nil; // to avoid warning
  if AVNode = nil then Exit;

  CurUObj := AVNode.VNUDObj;

  if CurUObj.RefCounter = 1 then // nothing todo
  begin
    Result := CurUObj;
  end else // Create One Level Clone
  begin
    if ACloneType = uotOneLevelClone then
      Result := N_CreateOneLevelClone( CurUObj )
    else
      Result := N_CreateSubTreeClone( CurUObj );

    ParentUObj := AVNode.VNParent.VNUDObj;
    CurUObjInd := AVNode.GetDirIndex(); // CurUObj index in ParentUObj
    ParentUObj.PutDirChildV( CurUObjInd, Result ); // AVNode will be destroyed!
//    CurUObj.SetChangedSubTreeFlag();
    N_SetChildsWereChanged( ParentUObj );
  end; // else // Create One Level Clone
end; // end of function N_ForceSingleInstance

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SplitPath
//************************************************************* N_SplitPath ***
// Extract Path first Segment
//
//     Parameters
// APath       - source Path string
// ARestOfPath - resulting part of the Path left after first Path Segment 
//               extracting
// Result      - Returns extracted Path Segment
//
// Path is the string consisting of substrings separated by '\'. If APath has no
// Segments separated by '\' then ARestOfPath value will be empty string and 
// resulting string will be equal to APath.
//
function N_SplitPath( const APath: string; out ARestOfPath: string ): string;
var
  Ind: integer;
begin
  Ind := Pos( '\', APath );
  if Ind = 0 then // the only componenet
  begin
    Result := APath;
    ARestOfPath := '';
  end else
  begin
    Result := LeftStr( APath, Ind-1 );
    ARestOfPath := Copy( APath, Ind+1, Length(APath) );
  end;
end; // end of function N_SplitPath

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_AddPath1
//************************************************************** N_AddPath1 ***
// Append IDB Object Name to given Path string as last Segment
//
//     Parameters
// APath  - given Path string
// AUObj  - IDB Object as Path Segment Container
// Result - Returns resulting Path
//
function N_AddPath1( APath: string; AUObj: TN_UDBase ): string;
begin
  Result := N_AddPath1s( APath, AUObj.ObjName );
end; // end of function N_AddPath1

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_AddPath1s
//************************************************************* N_AddPath1s ***
// Append given substring to given Path string as last Segment
//
//     Parameters
// APath     - given Path string
// ALastName - appending Path Segment substring
// Result    - Returns resulting Path
//
function N_AddPath1s( APath, ALastName: string ): string;
begin
  if APath = '' then Result := ALastName
               else Result := APath + '\' + ALastName;
end; // end of function N_AddPath1s

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CreatePath2
//*********************************************************** N_CreatePath2 ***
// Create Path string from Parent and Child IDB Object Names
//
//     Parameters
// AParent - Parent IDB Object
// AChild  - Child IDB Object
// Result  - Returns resulting Path
//
function N_CreatePath2( AParent, AChild: TN_UDBase ): string;
begin
  Result := N_AddPath1( '', AParent );
  Result := N_AddPath1( Result, AChild );
end; // end of function N_CreatePath2

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CreatePath3
//*********************************************************** N_CreatePath3 ***
// Create Path string from Parent Parent, Parent and Child IDB Object Names
//
//     Parameters
// APParent - Parent Parent IDB Object
// AParent  - Parent IDB Object
// AChild   - Child IDB Object
// Result   - Returns resulting Path
//
function N_CreatePath3( APParent, AParent, AChild: TN_UDBase ): string;
begin
  Result := N_AddPath1( '', APParent );
  Result := N_AddPath1( Result, AParent );
  Result := N_AddPath1( Result, AChild );
end; // end of function N_CreatePath3

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CreatePath3s
//********************************************************** N_CreatePath3s ***
// Create Path string from IDB Object Names and Segment substring
//
//     Parameters
// APParent  - Parent Parent IDB Object
// AParent   - Parent IDB Object
// AChild    - Child IDB Object
// ALastName - last Path Segment substring
// Result    - Returns resulting Path
//
function N_CreatePath3s( APParent, AParent, AChild: TN_UDBase;
                                             ALastName: string ): string;
begin
  Result := N_CreatePath3( APParent, AParent, AChild );
  Result := N_AddPath1s( Result, ALastName );
end; // end of function N_CreatePath3s
{
//************************************************** N_GetUObjByName ***
// find UObj by its AName and return it
//
//     Parameters
// AParent - IDB Object
// AName
//
// is used only in OLD files, should be removed later
//
function N_GetUObjByName( AParent: TN_UDBase; AName: string ): TN_UDBase;
begin
  with AParent do
    Result := DirChild(IndexOfChildObjName( AName ));
end; // end of function N_GetUObjByName
//************************************************** N_GetUObj ***
// find UObj by given AName and return it
//
function N_GetUObj( AParent: TN_UDBase; AName: string ): TN_UDBase;
begin
  with AParent do
    Result := DirChild(IndexOfChildObjName( AName ));
end; // end of function N_GetUObj
}

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetUObjByPath
//********************************************************* N_GetUObjByPath ***
// Get IDB Subnet Root descendant Object by given relative path
//
//     Parameters
// ARoot        - IDB Subnet Root Object
// ARPath       - IDB relative path
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns found IDB object.
//
// Resulting value is nil if given ARoot is not assigned If path is wrong thenn 
// assertion exception will be raised
//
function N_GetUObjByPath( ARoot: TN_UDBase; APath: string;
                                 AObjNameType : TK_UDObjNameType ): TN_UDBase;
var
  DE: TN_DirEntryPar;
  PathPos: Integer;
begin
  Result := nil;
  if not Assigned( ARoot ) then Exit;
  PathPos := ARoot.GetDEByRPath( APath, DE, AObjNameType );
  if PathPos < 0 then Exit; // Error!

  assert( PathPos >= 0, 'GetPath Error in path "' +
                                 APath + '" pos: ' + IntToStr(-PathPos) );
  Result := DE.Child;
end; // end of function N_GetUObjByPath
{
//************************************************** N_DeleteUObjByPath ***
// find Obj by its full Path, delete it and return
// some other object in same Dir or nil if not found or it was last UObj
//
function N_DeleteUObjByPath( Root: TN_UDBase; Path: string ): TN_UDBase;
begin
  Result := Root.GetObjByRPath( Path );
//  Result := nil;
//  if not Assigned( Root ) then Exit;
//  N_GetUObjByPath( Root, Path );

end; // end of function N_DeleteUObjByPath

//************************************************** N_GetParamsByPath ***
// Obsolete, used only in N_UDat1
// find Params Obj by full Path to some of it's scalar,
// return Params Obj as result (nil if not found) and ScalarName
//
function N_GetParamsByPath( Root: TN_UDBase; Path: string;
                                     out ScalarName: string ): TN_UDBase;
begin
  Result := nil;

var DE : TN_DirEntryPar;
PathPos : Integer;
begin
  ScalarName := ''; // needed if error
  Assert( Root <> nil, 'FatalError 000001.  Root = nil.' );
  PathPos := Root.GetDEByRPath( Path, DE );
  Result := DE.Child;
  if PathPos < 0 then
  begin
    PathPos := -PathPos;
    if Path[PathPos] <> '.' then
    begin
      N_WarnByMessage( Format(
        'Object with Name =  "%s"  was not found in RootDir  "%s"',
          [ Copy( Path, PathPos, Length(Path) ), Root.ObjName ] ) );
      Result := nil;
    end else
      ScalarName := Copy( Path, PathPos+1, Length(Path) );
    exit;
  end;
  if (Result.ClassFlags and $FF) = K_UDScalVectorCI then
  begin
    ScalarName := DE.DEName;
  end else
  begin
    if not N_SkipGetScalarWarning then //
      N_WarnByMessage( Format(
        'Object with Name =  "%s"  in RootDir  "%s"  is not Scalars obj.',
                               [ Result.ObjName, Root.ObjName ] ) );
  end;
var
  Ind, NameBeg, NameSize: integer;
  CurName: string;
  PStr1, Pstr2: PChar;
  CurParent: TN_UDBase;
begin
  Result := nil;
  ScalarName := ''; // needed if error
  Assert( Root <> nil, 'FatalError 000001.  Root = nil.' );

  CurParent := Root;
  PStr1 := PChar(Path);
  NameBeg := 1;

  while True do // parse Path componenets
  begin
    PStr2 := StrScan( PStr1, '\');
    if PStr2 = nil then NameSize := Length(Path)
                   else NameSize := PStr2 - PStr1;
    CurName := MidStr( Path, NameBeg, NameSize );
    if Pstr2 <> nil then // not last Path component
    begin
      Inc( NameBeg, NameSize+1 );
      Inc( PStr1, NameSize+1 );
      Ind := CurParent.IndexOfChildObjName( CurName );
      if Ind = -1 then // not found
      begin
        if not N_SkipGetScalarWarning then //
          N_WarnByMessage( Format(
            'Object with Name =  "%s"  was not found in RootDir  "%s"',
                                           [ CurName, Root.ObjName ] ) );
        Exit;
      end; // if Ind = -1 then // not found
      CurParent := CurParent.DirChild( Ind );
    end else // last Path component (ScalarName)
    begin
      if CurParent is TK_UDScalVector then
      begin
        Result := CurParent;
        ScalarName := CurName;
      end else
      begin
        if not N_SkipGetScalarWarning then //
          N_WarnByMessage( Format(
            'Object with Name =  "%s"  in RootDir  "%s"  is not Scalars obj.',
                                   [ CurParent.ObjName, Root.ObjName ] ) );
      end;
      Exit;
    end;
  end; // while True do // parse Path componenets

  if N_SkipGetScalarWarning then // just return N_NotAnInteger value


end; // end of function N_GetParamsByPath


//************************************************** N_CreateUChild ***
// create in given ParetObj new UBBase Child with
// Unique ObjName (given ChildName changed if it is not unique)
// return created Child
//
function N_CreateUChild( ParentObj: TN_UDBase; ChildName: string ): TN_UDBase;
begin
  Result := TN_UDBase.Create();
  Result.ObjName := N_NotAString;
  Result.ObjName := N_CreateUniqueUObjName( ParentObj, ChildName );
  ParentObj.AddOneChildV( Result );
end; // end of function N_CreateUChild

//************************************************** N_CreateUPChild ***
// create in given ParetObj new UBBase Child with Params and
// Unique ObjName (given ChildName changed if it is not unique) and
// return created Child (and created Params in ChildParams)
//
function N_CreateUPChild( ParentObj: TN_UDBase; ChildName: string;
                                  out ChildParams: TN_UDBase ): TN_UDBase;
begin
  Result := TN_UDBase.Create();
  ChildParams := N_AddUPChild( ParentObj, Result, ChildName );
end; // end of function N_CreateUPChild
}

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_AddUChild
//************************************************************* N_AddUChild ***
// Add Given IDB Object as Child to given Root Object
//
//     Parameters
// AParentObj - given Parent IDB Object
// AChildObj  - given Child IDB Object
// AChildName - Child IDB Object new Name (if ='' then 'New' is used)
//
// Given IDB Child Object Name will be unique among Parent Childs
//
procedure N_AddUChild( AParentObj, AChildObj: TN_UDBase; AChildName: string );
begin
//  ChildObj.ObjName := N_NotAString;
  if AChildName = '' then AChildName := 'New';
  AChildObj.ObjName := N_CreateUniqueUObjName( AParentObj, AChildName );
  AParentObj.AddOneChildV( AChildObj );
end; // end of procedure N_AddUChild

{
//************************************************** N_AddUPChild ***
// add (Unique name) child and create Child's Params
// (given ChildName changed if it is not unique)
// return created Child's Params
//
function N_AddUPChild( ParentObj, ChildObj: TN_UDBase;
                                          ChildName: string ): TN_UDBase;
begin
  ParentObj.AddOneChild( ChildObj );
  ChildObj.ObjName := N_NotAString;
  ChildObj.ObjName := N_CreateUniqueUObjName( ParentObj, ChildName );
  Result := N_CreateUParams( ChildObj );
end; // end of function N_AddUPChild

//************************************************** N_RenameUChild ***
// Rename (Unique name) Child
// (new ChildName changed if it is not unique)
//
procedure N_RenameUChild( ParentObj, ChildObj: TN_UDBase; ChildName: string );
begin
  ChildObj.ObjName := N_NotAString;
  ChildObj.ObjName := N_CreateUniqueUObjName( ParentObj, ChildName );
end; // end of procedure N_RenameUChild

//************************************************** N_CreateUParams ***
// clear all children of given ParentObj,
// create and return TK_UDScalVector (as TN_UDBase) with 'Params' ObjName
// ( not!! ObjName = ParentObj.ObjName + ' Params'
//
function N_CreateUParams( ParentObj: TN_UDBase ): TN_UDBase;
begin
  ParentObj.ClearChilds();
  Result := TK_UDScalVector.Create();
  N_AddUChild( ParentObj, Result, 'Params' );
end; // end of function N_CreateUParams
}

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SaveUObjToString
//****************************************************** N_SaveUObjToString ***
// Save given IDB SubTree to text
//
//     Parameters
// ARootUObj - given IDB SubTree Root Object
// Result    - Returns text with serialized content of given IDB SubTree
//
// IDB SubTree content is serialized including Root Object.
//
function N_SaveUObjToString( ARootUObj: TN_UDBase ): string;
begin
  Result := '';
  if ARootUObj = nil then Exit;
  K_SerialTextBuf.SetLineSize(60);
  K_SaveTreeToText( ARootUObj, K_SerialTextBuf );
  Result := K_SerialTextBuf.TextStrings.Text;
  K_SerialTextBuf.SetCapacity( -1000 );
end; // end of function N_SaveUObjToString

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SaveUObjToMem
//********************************************************* N_SaveUObjToMem ***
// Save given IDB SubTree to Memory with CheckSum and Signature
//
//     Parameters
// ARootUObj - IDB SubTree Root Object
// APBuf     - resulting pointer to memory buffer with serialize data
// Result    - Returns Size of resulting Data
//
// IDB SubTree content including Root Object is serialized in binary mode to 
// N_SerialBuf. Resulting pointer points to N_SerialBuf.Buf1 start byte.
//
function N_SaveUObjToMem( ARootUObj: TN_UDBase; out APBuf: Pointer ): Integer;
begin
  APBuf :=  nil;
  Result := 0;
  if ARootUObj = nil then Exit;

  K_SaveTreeToMem( ARootUObj, N_SerialBuf );
  N_SerialBuf.SetBufHeader();
  N_SerialBuf.AddBufCRC( );
  APBuf := @N_SerialBuf.Buf1[0];
  Result := N_SerialBuf.OfsFree;
end; // end of function N_SaveUObjToMem

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_LoadUObjFromMem
//******************************************************* N_LoadUObjFromMem ***
// Load serialized IDB SubTree from text or bynary data
//
//     Parameters
// APData      - pointer to serialized data
// ADataLength - serialized data length
// APErrcode   - pointer to integer resulting code (if =nil then no Error Code 
//               will be returned)
// Result      - Returns Root Object of loaded IDB SubTree (created Root Object 
//               can be of any type, but returned value type is TN_UDBase).
//
// Resulting Error Code is:
//#F
//  0 - OK
//  1 - Empty Buffer
//  2 - CRC Error
//#/F
//
// IDB SubTree can be loaded both from Text and Binary formats including SubTree
// Root Object. If load from binary then CheckSum and Signature are checked.
//
function N_LoadUObjFromMem( APData: Pointer; ADataLength: Integer;
                            APErrCode: PInteger = nil ): TN_UDBase;
var
  ErrCode : Integer;
begin
  Result :=  nil;
  ErrCode := 0;
  case N_SerialBuf.TestMem( APData, ADataLength ) of
   -1 : ErrCode := -1; // wrong Src Data

    0 : begin // Binary Src Data
      N_SerialBuf.LoadFromMem( APData^, ADataLength );
      if not N_SerialBuf.CheckBufCRC( ) then
        ErrCode := 2 // Wrong CRC
      else begin
        Dec( N_SerialBuf.OfsFree, SizeOf(Integer) );
        Result := K_LoadTreeFromMem( N_SerialBuf );
      end;
//***      N_SerialBuf.Init();
    end;

    1 : begin // Text Src Data
// UNICODE??? - is PChar OK?
      K_SerialTextBuf.LoadFromText( PChar(APData) );
//***      K_SerialTextBuf.TextStrings.Text := TN_BytesPtr(PData);
//***      K_SerialTextBuf.InitLoad;

      Result := K_LoadTreeFromText( K_SerialTextBuf );
    end;
  end; // case N_SerialBuf.TestMem( PData, DataLength ) of

  if APErrCode <> nil then APErrCode^ := ErrCode;
end; // end of function N_LoadUObjFromMem

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SaveUObjAsText(2)
//***************************************************** N_SaveUObjAsText(2) ***
// Save IDB SubTree given by Root Object to text file
//
//     Parameters
// ARootUObj - IDB SubTree Root Object
// AFileName - file name
// Result    - Returns FALSE if given Root Object is not assigned.
//
// IDB SubTree content is serialized including Root Object. If Root Object is 
// not assigned then file with given name is not changed.
//
function N_SaveUObjAsText( ARootUObj: TN_UDBase; AFileName: string ): boolean;
begin
  Result := ARootUObj <> nil;
  if not Result then Exit;

  K_SerialTextBuf.SetLineSize(60);
//  K_SerialTextBuf.PathToExtFiles := ExtractFilePath( FileName );
  K_SaveTreeToText( ARootUObj, K_SerialTextBuf );
  K_SerialTextBuf.SaveToFile( AFileName );
end; // end of function N_SaveUObjAsText(2)

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SaveUObjAsText(3)
//***************************************************** N_SaveUObjAsText(3) ***
// Save IDB SubTree given by Child of some Parent Object to text file
//
//     Parameters
// AParentDir - IDB SubTree Root Parent Object
// AUObjName  - IDB SubTree Root Object Name
// AFileName  - file name
// Result     - Returns FALSE if given Root Object is absent.
//
// IDB SubTree content is serialized including Root Object. If Root Object is 
// absent then file with given name is not changed.
//
function N_SaveUObjAsText( AParentDir: TN_UDBase; AUObjName, AFileName: string ): boolean;
//###??? Эта функция нигде не используется кандидат на выкидывание (раньше использовалась в N_ImpF)
var
  UObjToSave: TN_UDBase;
begin
  Result := False;
  UObjToSave := AParentDir.DirChildByObjName( AUObjName );
//  UObjToSave := N_GetUObj( ParentDir, UObjName );

  if UObjToSave = nil then // not found
  begin
    N_MessageDlg( 'Object  "' + AUObjName + '"  is absent in ' +
                  AParentDir.ObjName + ' directory!', mtWarning, [mbCancel], 0 );
    Exit;
  end;

  if not N_ConfirmOverwriteDlg( AFileName ) then Exit; // skip overwriting

  Screen.Cursor := crHourGlass;
  K_SerialTextBuf.SetLineSize(60);
//  K_SerialTextBuf.PathToExtFiles := ExtractFilePath( FileName );
  K_SaveTreeToText( UObjToSave, K_SerialTextBuf );
  K_SerialTextBuf.SaveToFile( AFileName );
  Screen.Cursor := crDefault;

  Result := True;
end; // end of function N_SaveUObjAsText(3)

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SaveUObjAsBin(2)
//****************************************************** N_SaveUObjAsBin(2) ***
// Save IDB SubTree given by Root Object to binary file
//
//     Parameters
// ARootUObj - IDB SubTree Root Object
// AFileName - file name
// Result    - Returns FALSE if given Root Object is not assigned.
//
// IDB SubTree content is serialized including Root Object. If Root Object is 
// not assigned then file with given name is not changed.
//
function N_SaveUObjAsBin( ARootUObj: TN_UDBase; AFileName: string ): boolean;
var
  TmpUObj: TN_UDBase;
begin
  Result := ARootUObj <> nil;
  if not Result then Exit; // not assigned
  TmpUObj := TN_UDBase.Create();
  TmpUObj.AddOneChild( ARootUObj );
  TmpUObj.SaveTreeToFile( AFileName );
  Inc( ARootUObj.RefCounter, 1 );
  TmpUObj.UDDelete();
  Dec( ARootUObj.RefCounter ); // to restore original RefCounter value
end; // end of function N_SaveUObjAsBin(2)

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SaveUObjAsBin(3)
//****************************************************** N_SaveUObjAsBin(3) ***
// Save IDB SubTree given by Child of some Parent Object to binary file
//
//     Parameters
// AParentDir - IDB SubTree Root Parent Object
// AUObjName  - IDB SubTree Root Object Name
// AFileName  - file name
// Result     - Returns FALSE if given Root Object is absent.
//
// IDB SubTree content is serialized including Root Object. If Root Object is 
// absent then file with given name is not changed. If file with given name 
// exists, then overwrite dialog is shown.
//
function N_SaveUObjAsBin( AParentDir: TN_UDBase; AUObjName, AFileName: string ): boolean;
var
  UObjToSave, TmpParentUObj: TN_UDBase;
begin
  Result := False;
  UObjToSave := AParentDir.DirChildByObjName( AUObjName );
//  UObjToSave := N_GetUObj( ParentDir, UObjName );

  if UObjToSave = nil then // not found
  begin
    N_MessageDlg( 'Object  "' + AUObjName + '"  is absent in ' +
                  AParentDir.ObjName + ' directory!', mtWarning, [mbCancel], 0 );
    Exit;
  end;

  if not N_ConfirmOverwriteDlg( AFileName ) then Exit; // skip overwriting

  TmpParentUObj := TN_UDBase.Create();
  TmpParentUObj.AddOneChild( UObjToSave );

  Screen.Cursor := crHourGlass;
  TmpParentUObj.SaveTreeToFile( AFileName );
  Screen.Cursor := crDefault;

  Inc( UObjToSave.RefCounter, 1 );
  TmpParentUObj.UDDelete();
  Dec( UObjToSave.RefCounter ); // to restore original RefCounter value
  Result := True;
end; // end of function N_SaveUObjAsBin(3)

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_LoadUObjFromText
//****************************************************** N_LoadUObjFromText ***
// Load serialized IDB SubTree from text file
//
//     Parameters
// AFileName - name of text file with serialized data
// Result    - Returns Root Object of loaded IDB SubTree (created Root Object 
//             can be of any type, but returned value type is TN_UDBase).
//
function N_LoadUObjFromText( AFileName: string ): TN_UDBase;
begin
  K_SerialTextBuf.LoadFromFile( AFileName );
  Result := K_LoadTreeFromText( K_SerialTextBuf );
end; // end of function N_LoadUObjFromText

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_LoadUObjFromBin
//******************************************************* N_LoadUObjFromBin ***
// Load serialized IDB SubTree from binary file
//
//     Parameters
// AFileName - name of binary file with serialized data
// Result    - Returns Root Object of loaded IDB SubTree (created Root Object 
//             can be of any type, but returned value type is TN_UDBase).
//
function N_LoadUObjFromBin( AFileName: string ): TN_UDBase;
begin
  N_SerialBuf.LoadFromFile( AFileName );
  Result := K_LoadTreeFromMem( N_SerialBuf );
end; // end of function N_LoadUObjFromBin

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_LoadUObjFromAny(1)
//**************************************************** N_LoadUObjFromAny(1) ***
// Load serialized IDB SubTree from binary or text file
//
//     Parameters
// AFileName - name of binary or text file with serialized data
// Result    - Returns Root Object of loaded IDB SubTree (created Root Object 
//             can be of any type, but returned value type is TN_UDBase).
//
function N_LoadUObjFromAny( AFileName: string ): TN_UDBase;
var
  Res: integer;
begin
  Res := N_SerialBuf.TestFile( AFileName );
  if Res = 0 then
    Result := N_LoadUObjFromBin( AFileName )
  else if Res = 1 then
    Result := N_LoadUObjFromText( AFileName )
  else
    Result := nil; // file not found or not an archive
end; // end of function N_LoadUObjFromAny(1)

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_LoadUObjFromAny(3)
//**************************************************** N_LoadUObjFromAny(3) ***
// Load serialized IDB SubTree from binary or text file add it to given Parent
//
//     Parameters
// AParentDir - Parent Object for loaded IDB SubTree Root
// AUObjName  - loaded IDB SubTree Root Object Name
// AFileName  - file name
// Result     - Returns Root Object of loaded IDB SubTree (created Root Object 
//              can be of any type, but returned value type is TN_UDBase).
//
// Returned value will be nil if some errors will be detected.
//
function N_LoadUObjFromAny( AParentDir: TN_UDBase; AUObjName, AFileName: string ): TN_UDBase;
//###??? Эта функция используется только в N_ImpF - кандидат на выкидывание - слишком частный случай
var
  Res: integer;
  UObj1, UObj2: TN_UDBase;
begin
  Result := nil;

  if not FileExists( AFileName ) then // not found
  begin
    N_MessageDlg( 'File  "' + AFileName + '"  is not found!',
                  mtWarning, [mbCancel], 0 );
    Exit;
  end;
  UObj1 := AParentDir.DirChildByObjName( AUObjName );
//  UObj1 := N_GetUObj( ParentDir, UObjName );

  if UObj1 <> nil then // already exists
    if N_MessageDlg( 'Object  "' + AUObjName + '"  already exists in ' +
                  AParentDir.ObjName + ' directory!  Overwrite it ?',
                  mtConfirmation, mbOkCancel, 0 ) = mrCancel then Exit;

  Screen.Cursor := crHourGlass;
  Res := N_SerialBuf.TestFile( AFileName );
  if Res = 0 then
    UObj2 := N_LoadUObjFromBin( AFileName )
  else if Res = 1 then
    UObj2 := N_LoadUObjFromText( AFileName )
  else
    UObj2 := nil;
  Screen.Cursor := crDefault;

  if UObj2 = nil then Exit; // errors while loading

  if AUObjName <> '?' then
    UObj2.ObjName := AUObjName; // change loaded UObj Name by given

// здесь стоиn добавить дополнительный код для вставки вместо удаляемого объекта
  AParentDir.DeleteOneChild( UObj1 );
  AParentDir.AddOneChild( UObj2 );
  Result := UObj2;
end; // end of function N_LoadUObjFromAny(3)

//************************************************* N_SaveUChildsAsText ***
// Save all childs from given IDB SubTree Root Object to text file
//
//     Parameters
// ARootUObj - IDB SubTree Root Object
// AFileName - file name
//
// IDB SubTree content is serialized without Root Object.
//
procedure N_SaveUChildsAsText( ARootUObj: TN_UDBase; AFileName: string );
//###??? Эта функция нигде не используется кандидат на выкидывание
begin
  ARootUObj.SaveTreeToTextFile( AFileName, K_TextModeFlags );
end; // end of procedure N_SaveUChildsAsText

//************************************************* N_SaveUChildsAsBin ***
// Save all childs from given IDB SubTree Root Object to binary file
//
//     Parameters
// ARootUObj - IDB SubTree Root Object
// AFileName - file name
//
// IDB SubTree content is serialized without Root Object.
//
procedure N_SaveUChildsAsBin( ARootUObj: TN_UDBase; AFileName: string );
//###??? Эта функция нигде не используется кандидат на выкидывание
begin
  ARootUObj.SaveTreeToFile( AFileName );
end; // end of procedure N_SaveUChildsAsBin

//*********************************************** N_LoadUChildsFromText ***
// Load all childs of given RootUObj and all below from Text file
//
procedure N_LoadUChildsFromText( RootUObj: TN_UDBase; FileName: string );
//###??? Эта функция нигде не используется кандидат на выкидывание
begin
  RootUObj.LoadTreeFromTextFile( FileName );
end; // end of procedure N_LoadUChildsFromText

//*********************************************** N_LoadUChildsFromBin ***
// Load all childs of given RootUObj and all below from Binary file
//
procedure N_LoadUChildsFromBin( RootUObj: TN_UDBase; FileName: string );
//###??? Эта функция нигде не используется кандидат на выкидывание
begin
  RootUObj.LoadTreeFromFile( FileName );
end; // end of procedure N_LoadUChildsFromBin

//******************************************** N_LoadUChildsFromAny ***
// Load all childs of given RootUObj and all below from Text or Binary file
//
procedure N_LoadUChildsFromAny( RootUObj: TN_UDBase; FileName: string );
//###??? Эта функция нигде не используется кандидат на выкидывание
var
  SavedCursor: TCursor;
begin
  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;

  if 0 = N_SerialBuf.TestFile( FileName ) then
    N_LoadUChildsFromBin( RootUObj, FileName )
  else
    N_LoadUChildsFromText( RootUObj, FileName );

  Screen.Cursor := SavedCursor;
end; // end of procedure N_LoadUChildsFromAny

//***************************************** N_UObjNamesToStrings ***
// clear given Strings and add UObjNames to it
//
procedure N_UObjNamesToStrings( RootUObj: TN_UDBase; Strings: TStrings );
//###??? Эта функция нигде не используется кандидат на выкидывание
var
  i: integer;
begin
  Strings.Clear;
  for i := 0 to RootUObj.DirHigh() do
    Strings.Add( RootUObj.DirChild( i ).ObjName );
end; // end of procedure N_UObjNamesToStrings

//***************************************** N_DTreeNamesToStrings ***
// clear given Strings and add DTree Names to it
// (Mode - now bits0-3 used as number of levels)
// Now only two levels
//
procedure N_DTreeNamesToStrings( RootUObj: TN_UDBase; Strings: TStrings;
                                                          Mode: integer );
//###??? Эта функция нигде не используется кандидат на выкидывание
var
  i, j, k, NLevels: integer;
  Str1, Str2, StrTmp: string;
  Root1, Root2: TN_UDBase;
begin
  NLevels := Mode and $F;
  Strings.Clear;

  for i := 0 to RootUObj.DirHigh() do
  begin
    Root1 := RootUObj.DirChild( i );
    if Root1 = nil then Continue;
    Str1 := RootUObj.DirChild( i ).ObjName;
    if NLevels >= 2 then
    begin
      for j := 0 to Root1.DirHigh() do
      begin
        Root2 := Root1.DirChild( j );
        if Root2 = nil then Continue;
        StrTmp := Root1.DirChild( j ).ObjName;
        if StrTmp = 'Params' then Continue; // skip Params
        Str2 := Str1 + '\' +  StrTmp;
        if NLevels >= 3 then
        begin
          for k := 0 to Root2.DirHigh() do
          begin
            if Root2.DirChild( k ) <> nil then
            begin
              StrTmp := Root2.DirChild( k ).ObjName;
              if StrTmp = 'Params' then Continue; // skip Params
              Strings.Add( Str2 + '\' + StrTmp );
            end;
          end;
        end else
          Strings.Add( Str2 );
      end; // for j := 0 to Root1.DirHigh() do
    end else
    Strings.Add( Str1 );
  end; // for i := 0 to RootUObj.DirHigh() do
end; // end of procedure N_DTreeNamesToStrings

//****************************************************** N_DeleteUObjByInds ***
// Delete from given AUObjDir all UDBase Objects, with given indexes
//
procedure N_DeleteUObjByInds( AUObjDir: TN_UDBase; AIndexes: TN_IArray );
//###??? Эта функция нигде не используется кандидат на выкидывание
var
  i, j, MaxInd: integer;
begin
  if AUObjDir = nil then Exit;
  MaxInd := AUObjDir.DirHigh();

  for i := 0 to High(AIndexes) do
  begin
    j := AIndexes[i];

    if (j >= 0) and (j <= MaxInd) then
      AUObjDir.RemoveDirEntry( j );

  end; // for i := 0 to High(AIndexes) do
end; // end of procedure N_DeleteUObjByInds

//***************************************************** N_DeleteAllUObjects ***
// Delete all UDBase Objects in given AUObjDir
//
procedure N_DeleteAllUObjects( AUObjDir: TN_UDBase );
var
  i, MaxInd: integer;
begin
  if AUObjDir = nil then Exit;

  MaxInd := AUObjDir.DirHigh();

  for i := MaxInd downto 0 do
      AUObjDir.RemoveDirEntry( i );
end; // end of procedure N_DeleteAllUObjects

//***************************************** N_CopyCObjects ***
// Copy all CObjects, with indexes in given Indexes array
// from InpCObjDir to OutCObjDir
//
procedure N_CopyCObjects( InpCObjDir, OutCObjDir: TN_UDBase; Indexes: TN_IArray );
//###??? Эта функция нигде не используется кандидат на выкидывание
var
  i, j, MaxInd: integer;
  NewCObj: TN_UDBase;
begin
  MaxInd := InpCObjDir.DirHigh();
  for i := 0 to High(Indexes) do
  begin
    j := Indexes[i];
    if (j >= 0) and (j <= MaxInd) then
    begin
      NewCObj := InpCObjDir.DirChild(j).Clone(True);
      OutCObjDir.AddOneChild( NewCObj );
    end;
  end; // for i := 0 to MaxInd do
end; // end of procedure N_CopyCObjects

//***************************************** N_MoveCObjects ***
// Move all CObjects, with Codes in given Codes array
// from InpCObjDir to OutCObjDir
//
procedure N_MoveCObjects( InpCObjDir, OutCObjDir: TN_UDBase; Indexes: TN_IArray );
//###??? Эта функция нигде не используется кандидат на выкидывание
var
  i, j, MaxInd: integer;
  NewCObj: TN_UDBase;
begin
  MaxInd := InpCObjDir.DirHigh();
  for i := 0 to High(Indexes) do
  begin
    j := Indexes[i];
    if (j >= 0) and (j <= MaxInd) then
    begin
      NewCObj := InpCObjDir.DirChild(j).Clone(True);
      OutCObjDir.AddOneChild( NewCObj );
      InpCObjDir.RemoveDirEntry( j );
    end;
  end; // for i := 0 to MaxInd do
end; // end of procedure N_MoveCObjects

{ // obsolete
//***************************************** N_CopyUDRArrayField ***
// Copy one UDRArray filed (UDRArray Data Element) from Src to Dst
// Return True if OK
//
// ( AFlags is not used now )
//
function N_CopyUDRArrayField( AFlags: integer;
                              ASrcUObj: TN_UDBase; ASrcPath: string;
                              ADstUObj: TN_UDBase; ADstPath: string ): boolean;
var
  Ind: integer;
  PSrcField, PDstField: Pointer;
  SrcFTCode, DstFTCode : TK_ExprExtType;
begin
  Result := False;

  if ASrcPath[1] = '#' then // CS Code is given (ASrcUObj should be TK_UDVector)
  begin
    if not (ASrcUObj is TK_UDVector) then Exit;

    with TK_UDVector(ASrcUObj) do
    begin
      Ind := GetDCSSpace().IndexByCode( Copy( ASrcPath, 2, Length(ASrcPath) ) );
      PSrcField := DP( Ind );
      SrcFTCode := PDRA().DType;
      SrcFTCode.D.TFlags := SrcFTCode.D.TFlags and (not K_ffArray);
    end; // with TK_UDVector(ASrcUObj) do

  end else // Path is given
  begin
    SrcFTCode := K_GetUDFieldPointerByRPath( ASrcUObj, ASrcPath, PSrcField );
    if SrcFTCode.DTCode = -1 then Exit;
  end;

  if not (ADstUObj is TK_UDRArray) then Exit;
  with TK_UDRArray(ADstUObj).R do
    DstFTCode := K_GetFieldPointer( P, DType, ADstPath, PDstField );

  if (DstFTCode.DTCode = -1) or (SrcFTCode.All <> DstFTCode.All) then Exit;

  if PSrcField <> PDstField then // some times is needed
    K_MoveSPLData( PSrcField^, PDstField^, SrcFTCode, [K_mdfSafeCopy] );

  Result := True; // OK
end; // end of function N_CopyUDRArrayField

// obsolete
//***************************************** N_ExecuteSetParams ***
// Set DTree Params
//
function N_ExecuteSetParams( AUDSetParams: TN_UDBase ): boolean;
var
  i: integer;
  ParamsList: TK_RArray;
begin
  Result := False;

  if not (AUDSetParams is TK_UDRArray) then Exit;
  ParamsList := TK_UDRArray(AUDSetParams).R;

  if K_GetExecTypeName(ParamsList.DType.All) <>
           (K_sccArray + 'TN_SetParamInfo') then Exit;

  for i := 0 to ParamsList.AHigh() do
  with TN_PSetParamInfo(ParamsList.P(i))^ do
  begin
    if not N_CopyUDRArrayField( SPFlags, SPSrcUObj, SPSrcPath,
                                         SPDstUObj, SPDstPath ) then
    begin
       N_WarnByMessage( 'SetParams Error in ' + AUDSetParams.ObjName +
                                           ' i=' + IntToStr(i) );
    end;
  end; // for i := 0 to ParamsList.AHigh() do

  Result := True; // OK
end; // end of function N_ExecuteSetParams
}

//***************************************** N_GetReverseRefPath ***
// Get Reverse RefPath to given AUObj
// if IncSelf = True, include AUObj as first element of RefPath
//
function N_GetReverseRefPath( AUObj: TN_UDBase; IncSelf: boolean ): string;
var
  i, j: integer;
  UObj: TN_UDBase;
  Owners: TN_UDArray;
begin
  if IncSelf then UObj := AUObj
             else UObj := AUObj.Owner;
  i := 0;

  while UObj <> nil do
  begin
    if High(Owners) < i then SetLength( Owners, N_NewLength(i) );
    Owners[i] := UObj;
    Inc(i);
    UObj := UObj.Owner;
  end; // while UObj <> nil then

  Result := '';
  for j := 0 to i-1 do // along RefPath segments
  begin
    if j = (i-1) then // last segment
      Result := Result + Owners[j].ObjName + ';'
    else
      Result := Result + Owners[j].ObjName + '>';
  end; // for j := 0 to i-1 do

end; // end of function N_GetReverseRefPath

//***************************************** N_GetOSTSize ***
// Get Owners SubTree Size (binary archive size) in bytes
//
function N_GetOSTSize( ARoot: TN_UDBase ): integer;
begin
  Result := -1;
  if ARoot = nil then Exit;

  K_SaveTreeToMem( ARoot, N_SerialBuf );
  Result := N_SerialBuf.OfsFree;
end; // end of function N_GetOSTSize

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CreateArrayOfUDBase
//*************************************************** N_CreateArrayOfUDBase ***
// Create array of IDB Objects given by List of Visual Nodes
//
//     Parameters
// AVNodesList - list of Visual Nodes
// Result      - Returns Array of IDB Objects (TN_UDBase)
//
function N_CreateArrayOfUDBase( AVNodesList: TList ): TN_UDArray;
var
  i: integer;
begin
  SetLength( Result, AVNodesList.Count );
  for i := 0 to High(Result) do
    with TN_VNode(AVNodesList.Items[i]) do
      Result[i] := VNUDObj;
end; // end of function N_CreateArrayOfUDBase

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SameDTCodes
//*********************************************************** N_SameDTCodes ***
// Compare SPL Type Codes
//
//     Parameters
// ADTCode1 - one SPL Type Code to compare
// ADTCode2 - another SPL Type Code to compare
// Result   - Returns TRUE if SPL Type Codes are equal
//
function N_SameDTCodes( const ADTCode1, ADTCode2: TK_ExprExtType ): boolean;
begin
  Result := False;
  if (ADTCode1.DTCode = -1) or
    (((ADTCode1.All xor ADTCode2.All) and K_ffCompareTypesMask) <> 0 ) then Exit;

  Result := True;
end; // end of function N_SameDTCodes

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetRAFieldInfo
//******************************************************** N_GetRAFieldInfo ***
// Get Records Array Field Type and Pointer
//
//     Parameters
// ARArray    - given Records Array
// AFieldPath - given Field Path
// AFieldType - found Field Type Code
// AFieldPtr  - pointer to found Field Value
// Result     - Returns Field Path error position
//
function N_GetRAFieldInfo( ARArray: TK_RArray; AFieldPath: string;
           out AFieldType: TK_ExprExtType; out AFieldPtr: Pointer ): integer;
var
  RAType: TK_ExprExtType;
begin
    RAType := ARArray.ElemType;
    RAType.D.TFlags := RAType.D.TFlags or K_ffArray;
    AFieldPtr := nil;

    AFieldType := K_GetFieldPointer( @ARArray, RAType, AFieldPath,
                                                          AFieldPtr, @Result );
end; // end of function N_GetRAFieldInfo

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SetUDRArraysField
//***************************************************** N_SetUDRArraysField ***
// Set given Field new Value in all given IDB Objects Records Array
//
//     Parameters
// ASrcData       - given Field new Value
// APFirst        - pointer to first element of IDB Objects Array
// ANumUDRArrays  - number of elements in IDB Objects Array
// AFieldPath     - path to given Field in IDB Object Records Array
// AFieldTypeCode - given Field SPL Type Code
// APUpValsInfo   - pointer to Update Field Value Attributes
// Result         - Returns number of changed IDB Objects
//
function N_SetUDRArraysField( const ASrcData; APFirst: TN_PUDBase;
                              ANumUDRArrays: integer; AFieldPath: string;
                              AFieldTypeCode : TK_ExprExtType;
                              APUpValsInfo: TN_PUpdateValsInfo ): integer;
var
  i, j, CurOfs: integer;
  PCur: TN_PUDBase;
  DstRA: TK_RArray;
  DstFieldTypeCode, DstUObjType: TK_ExprExtType;
  PDstField, PSrcV, PDstV, PPreV: TN_BytesPtr;
  Label SkipChanging;
begin
  Result := 0;
  PCur := APFirst;
  AFieldTypeCode.D.CFlags := 0;

  for i := 0 to ANumUDRArrays-1 do // along all UDRArray objects
  begin
    if not (PCur^ is TK_UDRArray) then
      goto SkipChanging;

    DstRA := TK_UDRArray(PCur^).R;
    DstUObjType := DstRA.ElemType;
    DstUObjType.D.TFlags := DstUObjType.D.TFlags or K_ffArray; // why not already?
    PDstField := nil; // a precaution

    DstFieldTypeCode := K_GetFieldPointer( @DstRA, DstUObjType,
                                               AFieldPath, Pointer(PDstField) );
    DstFieldTypeCode.D.CFlags := 0; // to enable comparing with AFieldTypeCode

    if (PDstField = nil)       or           // PDstField was not set
       (@ASrcData = PDstField) or           // PDstField points to ASrcData
       (DstFieldTypeCode.All <> AFieldTypeCode.All) // not same Field Types
                                            then goto SkipChanging;
    if APUpValsInfo = nil then
      K_MoveSPLData( ASrcData, PDstField^, AFieldTypeCode, [K_mdfFreeAndFullCopy] )
    else
    with APUpValsInfo^ do
    begin
      if not ApplyToAll then // normal mode, do not analize APUpValsInfo
        K_MoveSPLData( ASrcData, PDstField^, AFieldTypeCode, [K_mdfFreeAndFullCopy] )
      else // ApplyToAll is True
      begin // Update only Values in DstField given in UpValsInfo
        if DeltaMode then // DstField = DstField + SrcField - PrevData
        begin
          CurOfs := 0;

          for j := 0 to NumVals-1 do // loop along all fields
          begin
            PSrcV := TN_BytesPtr(@ASrcData) + CurOfs;
            PDstV := PDstField + CurOfs;
            PPreV := TN_BytesPtr(@ValsPrevData) + CurOfs;
            inc( CurOfs, ValOffset );

            case ValType of
              ovtInteger: PInteger(PDstV)^ := PInteger(PDstV)^ +
                                      PInteger(PSrcV)^ - PInteger(PPreV)^;
              ovtFloat:   PFloat(PDstV)^   := PFloat(PDstV)^ +
                                      PFloat(PSrcV)^ - PFloat(PPreV)^;
              ovtDouble:  PDouble(PDstV)^  := PDouble(PDstV)^ +
                                       PDouble(PSrcV)^ - PDouble(PPreV)^;
              else
                Assert( False, 'Bad ValueType!' );
            end; // case ValType of

          end; // for j := 0 to NumVals-1 do

        end else // set one value in DstField
        begin
          PSrcV := TN_BytesPtr(@ASrcData) + ValOffset;
          PDstV := PDstField + ValOffset;

          case ValType of
            ovtInteger: PInteger(PDstV)^ := PInteger(PSrcV)^;
            ovtFloat:   PFloat(PDstV)^   := PFloat(PSrcV)^;
            ovtDouble:  PDouble(PDstV)^  := PDouble(PSrcV)^;
            else
              Assert( False, 'Bad ValueType!' );
          end; // case ValType of
        end; // else -- set one value in DstField
      end; // else -- ApplyToAll is True
    end; // with APUpValsInfo^ do

    Inc( Result );
    Inc( PCur ); // to next UDRArray
    Continue;

    SkipChanging: // Skip - to next UDRArray without increasing Result
      Inc( PCur );
  end; // for i := 0 to ANumUDRArrays-1 do // along all UDRArray objects

end; // end of function N_SetUDRArraysField

//***************************************** N_GetUDRefsRArray ***
// Create (if needed) and RArray with UDBase objects with given AClassInd
// ARootObj can be needed UDBase, RArray with Refs to needed UDBase objects or
// UDBase with needed child UDBase
//
function N_GetUDRefsRArray( ARootObj: TObject; AClassInd: integer ): TK_RArray;
//###??? Эта функция нигде не используется кандидат на выкидывание
var
  i, NumItems, MaxInd: integer;
  RootChild: TN_UDBase;
begin
  Result := nil;

  if ARootObj is TK_RArray then // ARootObj is RArray with Refs to needed UDBase objects
  begin
    Result := TK_RArray(ARootObj);
    Result.AAddRef(); // to be able call Result.Free without deleting initial RArray
  end else // RArray should be constructed by ARootObj
  begin
    if not (ARootObj is TN_UDBase) then Exit; // error
//    N_s := TN_UDBase(ARootObj).ObjName; // debug

    Result := K_RCreateByTypeName( 'TN_UDBase', 1, [K_crfNotCountUDRef] );
    PObject(Result.P( 0 ))^ := nil;

//    if TN_UDBase(ARootObj).CI = AClassInd then // fill Result by ARootObj
    if ARootObj is N_ClassRefArray[AClassInd] then // fill Result by ARootObj
    begin
      PObject(Result.P( 0 ))^ := ARootObj;
    end else // fill Result by ARootObj children
    begin
      NumItems := 0;
      MaxInd := TN_UDBase(ARootObj).DirHigh;
      Result.ASetLength( MaxInd+1 ); // max possible length

      for i := 0 to MaxInd do // along ARootObj children
      begin
        RootChild := TN_UDBase(ARootObj).DirChild( i );
        if not (RootChild is N_ClassRefArray[AClassInd]) then // skip not needed objects
          Continue;

        PObject(Result.P( NumItems ))^ := RootChild;
        Inc(NumItems);
      end; // for i := 0 to MaxInd do // along ARootObj children
      if NumItems >= 1 then
        Result.ASetLength( NumItems ) // set real length
      else
        Result := nil;
    end; // else // fill Result by ARootObj children
  end; // else // Result should be constructed by ARootObj
end; // end of function N_GetUDRefsRArray

//****************************************************** N_FillNumRArray ***
// Fill or Update given RArray of Numbers using given APParams
//
//    Parameters
// ARArray
// APParams
//
// DebugValues, ZeroConst, Linear, Power, Sin(Degree) functions are implemented
// if FNRAddMode <> 0 then calculated Value is added to Current,
// then Random Noise is added to resulting Value,
// then resulting Value is Shifted ans Scaled,
// then resulting Value is Rounded to given Precision
//
procedure N_FillNumRArray( var ARArray: TK_RArray; APParams: TN_PRAFillNumParams );
var
  i, NeededSize: integer;
  CurValue, FuncValue, CurArg, Coef, TmpValue, NumIntevals, DeltaFunc, AbsDF: double;
  PCurValue: TN_BytesPtr;
begin
  CurValue  := 0; // to avoid warning
  FuncValue := 0; // to avoid warning

  with APParams^ do
  begin
  if FNRBegIndex < 0 then FNRBegIndex := 0; // a precaution
  if FNRNumValues <= 0 then FNRNumValues := 1; // a precaution

  NeededSize := FNRBegIndex + FNRNumValues;
  if ARArray.ALength < NeededSize then
    ARArray.ASetLength( NeededSize );

  PCurValue := ARArray.P( FNRBegIndex );

  NumIntevals := Max( 1, FNRNumValues - 1 ); // to avoid dividing by zero
  DeltaFunc := FNREndFunc - FNRBegFunc;
  AbsDF := abs(DeltaFunc);

  for i := 0 to FNRNumValues-1 do
  begin
    if FNRFuncType = fnftDebug then //**************************** Debug Values
    begin
      FuncValue := FNRBegFunc + i*1.01;
    end else if FNRFuncType = fnftZero then //******************* Zero Constant
      FuncValue := 0
    else if FNRFuncType = fnftLinear then //******************* Linear function
    begin
      FuncValue := FNRBegFunc + i*DeltaFunc/NumIntevals;
    end else if FNRFuncType = fnftPower then //***************** Power function
    begin
      if AbsDF < 1.0e-6 then
        FuncValue := 0.5*(FNRBegFunc + FNREndFunc)
      else if DeltaFunc > 0 then
        FuncValue := FNRBegFunc + AbsDF*Power( 1.0*i/NumIntevals, FNRPowerCoef )
      else
        FuncValue := FNRBegFunc - AbsDF*Power( 1.0*i/NumIntevals, FNRPowerCoef );
    end else if FNRFuncType = fnftSinDegree then //*** Sinus with Arg in Degree
    begin
      CurArg := N_PI*(FNRBegArg + i*(FNREndArg - FNRBegArg)/NumIntevals) / 180.;
      FuncValue := 0.5*DeltaFunc*Sin(CurArg) + 0.5*(FNRBegFunc + FNREndFunc);
    end else
      Assert( False, 'Bad FuncType!' );

    if FNRAddMode <> 0 then // "Add calculated Value to Current" mode
    begin
      if ARArray.ElemType.DTCode = N_SPLTC_Bool1 then
        CurValue := PByte(PCurValue)^
      else
      case ARArray.ElemType.DTCode of
        Ord(nptByte):   CurValue := PByte(PCurValue)^;
        Ord(nptInt):    CurValue := PInteger(PCurValue)^;
        Ord(nptFloat):  CurValue := PFloat(PCurValue)^;
        Ord(nptDouble): CurValue := PDouble(PCurValue)^;
      end; // case ARArray.DType.DTCode of
      CurValue := CurValue + FuncValue;
    end else
      CurValue := FuncValue;

    CurValue := CurValue + Random*FNRNoiseVal; // Add Noise
    CurValue := CurValue*FNRMultCoef + FNRShiftVal; // Scale and Shift

    //***** Round CurValue to given precision
    Coef := IntPower( 10.0, FNRNumDigits );
    TmpValue  := CurValue*Coef;
    TmpValue  := Floor( TmpValue + 0.5 ); // round
    CurValue := TmpValue / Coef;

    if ARArray.ElemType.DTCode = N_SPLTC_Bool1 then
      PByte(PCurValue)^ := Round(CurValue)
    else
    case ARArray.ElemType.DTCode of
      Ord(nptByte):       PByte(PCurValue)^    := Round(CurValue);
      Ord(nptInt):        PInteger(PCurValue)^ := Round(CurValue);
      Ord(nptFloat):      PFloat(PCurValue)^   := CurValue;
      Ord(nptDouble):     PDouble(PCurValue)^  := CurValue;
    end; // case ARArray.DType.DTCode of

    Inc( PCurValue, ARArray.ElemSize );
  end; // for i := 0 to FNRNumValues-1 do

  end; // with APParams^ do
end; // procedure N_FillNumRArray

//****************************************************** N_Fill2DRArray ***
// Fill or Update given 2D RArray using given APParams
// (supported ARArray elements type: integer, float, double, string)
//
procedure N_Fill2DRArray( var ARArray: TK_RArray; APParams: TN_P2DRAFillNumParams );
var
  i, NX, NY, ElemType: integer;
  DVMatr: TN_DVMatr;
begin
  with APParams^ do
  begin
    NX := ARArray.HCol + 1;
    NY := ARArray.ALength() div NX;
    DVMatr := TN_DVMatr.Create( NX, NY );
    DVMatr.Clear();
    ElemType := ARArray.ElemSType;

    if not (tdnftClearFirst in FNRFlags) then // Init DVMatr by ARArray
    begin
      if ElemType = Ord(nptInt) then
        DVMatr.SetValues( PInteger(ARArray.P()), NX, NY )
      else if ElemType = Ord(nptFloat) then
        DVMatr.SetValues( PFloat(ARArray.P()), NX, NY )
      else if ElemType = Ord(nptDouble) then
        DVMatr.SetValues( PDouble(ARArray.P()), NX, NY );
    end; // if not (tdnftClearFirst in FNRFlags) then

    case FNRFuncType of

    tdnftLinear1: begin // Add Linear1 Func (given X,Y Steps)
      DVMatr.AddLin1Func( FNRVX0Y0, FNRVXMaxY0, FNRVX0YMax );
    end; // tdnftLinear1: begin // Add Linear1 Func

    tdnftLinear2: begin // Add Linear2 Func (given corner values)
      DVMatr.AddLin2Func( FNRVX0Y0, FNRVXMaxY0, FNRVX0YMax );
    end; // tdnftLinear2: begin // Add Linear2 Func

    tdnftExp: begin // Add Exponent
      DVMatr.Add2DExp( FNRExtrCoords, FNRExtrVal, FNRInfExpVal,
                                                  FNRSigmaExp.X, FNRSigmaExp.Y );
    end; // tdnftExp: begin // Add Exponent

    tdnftParab: begin // Add Parabolic Func
      DVMatr.AddParab( FNRExtrCoords, FNRExtrVal, FNRCXYPar.X, FNRCXYPar.Y );
    end; // tdnftParab: begin // Add Parabolic Func

    end; // case FNRFuncType of

    with DVMatr do
    begin
      for i := 0 to NXY-1 do
      begin
        case ElemType of
          Ord(nptInt):    PInteger(ARArray.P(i))^ := Round(VM[i]);
          Ord(nptFloat):  PFloat(ARArray.P(i))^   := VM[i];
          Ord(nptDouble): PDouble(ARArray.P(i))^  := VM[i];
          Ord(nptString): PString(ARArray.P(i))^  := Format( FNRFormat, [VM[i]] );
        end; // case ElemType of
      end; // for i := 0 to NXY-1 do

      Free;
    end; // with DVMatr do

  end; // with APParams^ do
end; // procedure N_Fill2DRArray

//******************************************************* N_FillColRArray ***
// Fill given RArray of Colors using given APParams
//
procedure N_FillColRArray( var ARArray: TK_RArray; APParams: TN_PRAFillColParams );
var
  NeededSize: integer;
  PCurColor: PInteger;
begin
  with APParams^ do
  begin

  if FCRBegIndex  < 0 then FCRBegIndex := 0; // a precaution
  if FCRNumValues <= 0 then FCRNumValues := 1; // a precaution

  NeededSize := FCRBegIndex + FCRNumValues;
  if ARArray.ALength < NeededSize then
    ARArray.ASetLength( NeededSize );

  PCurColor := PInteger(ARArray.P( FCRBegIndex ));
  N_CreateTestColors( FCRFillType, FCRMinColor, FCRMaxColor, PCurColor,
                                                                FCRNumValues );
  end; // with APParams^ do
end; // procedure N_FillColRArray

//******************************************************* N_FillStrRArray ***
// Fill given RArray of Strings using given APParams
//
procedure N_FillStrRArray( var ARArray: TK_RArray; APParams: TN_PRAFillStrParams );
var
  i, NeededSize: integer;
  DblIndex: double;
  PValue: PDouble;
  PCurStr: PString;
  Str: string;
begin
  with APParams^ do
  begin
  if FSRBegIndex   < 0  then FSRBegIndex := 0;   // a precaution
  if FSRNumStrings <= 0 then FSRNumStrings := 1; // a precaution

  NeededSize := FSRBegIndex + FSRNumStrings;
  if ARArray.ALength < NeededSize then
    ARArray.ASetLength( NeededSize );

  PCurStr := PString(ARArray.P( FSRBegIndex ));

  for i := 0 to FSRNumStrings-1 do
  begin
    PValue := PDouble(FSRDValues.PS( i ));
    DblIndex := i;
    if PValue = nil then PValue := @DblIndex; // if FSRDValues was not defined use Index values

    case FSRFillType of
      fstFormatInt: Str := Format( FSRFormat, [Round(PValue^)] );
      fstFormatDbl: Str := Format( FSRFormat, [PValue^] );
      fstCharCodes: Str := Char( Round(PValue^) );
    end; // case FSRFillType of

    if fstAddAfter in FSRFillFlags then
      PCurStr^ := PCurStr^ + Str
    else
      PCurStr^ := Str;

    Inc( PCurStr, 1 );
  end; // for i := 0 to FSRNumStrings-1 do

  end; // with APParams^ do
end; // procedure N_FillStrRArray

//*********************************************************** N_CSItemAsStr ***
// Return String representation of given CodeSpace Item
//
function N_CSItemAsStr( APCSItem: TN_PCodeSpaceItem ): string;
//###??? Эта функция нигде не используется кандидат на выкидывание
var
  Ind: integer;
  ItemName, CSName: string;
begin
  Result := 'CS Item not defined'; // representation for not initialized CodeSpace Item
  with APCSItem^ do
  begin
    if (ItemCS = nil) or (ItemCode = '') then Exit;

    Ind := ItemCS.IndexByCode( ItemCode );
    ItemCS.GetItemsInfo( @ItemName, K_csiCSName, Ind );
    if ItemName = '' then Exit;

    CSName := ItemCS.ObjAliase;
    if CSName = '' then CSName := ItemCS.ObjName;

    Result := Format( '%s  (%s)', [ItemName, CSName] );
  end;
end; // function N_CSItemAsStr

//********************************************************* N_CSIntCodeName ***
// Return Name of given integer ACode in given ACodeSpace
//
function N_CSIntCodeName( ACode: integer; ACodeSpace: TK_UDDCSpace ): string;
var
  Ind: integer;
  CodeAsStr: string;
begin
  Result := N_NotDefStr;
  if ACodeSpace = nil then Exit;

  CodeAsStr := IntToStr( ACode );
  Ind := ACodeSpace.IndexByCode( CodeAsStr );

  if Ind >= 0 then // ACode was found
    ACodeSpace.GetItemsInfo( @Result, K_csiCSName, Ind );
end; // function N_CSIntCodeName

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetRAFlags
//************************************************************ N_GetRAFlags ***
// Get Records Array Editor Data Type Flags from full SPL Type Code
//
//     Parameters
// ASPLTypeCode - full SPL Type Code
// Result       - Returns Records Array Editor Data Type Flags for given Type 
//                Code
//
function N_GetRAFlags( ASPLTypeCode: TK_ExprExtType ): TN_RAEditFlags;
begin
  Result := [];

  if (ASPLTypeCode.D.CFlags and K_ccCountUDRef) <> 0 then
    Result := Result + [raefCountUDRefs];

  if (ASPLTypeCode.D.CFlags and K_ccStopCountUDRef) <> 0 then
    Result := Result + [raefNotCountUDRefs];
end; // function N_GetRAFlags

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetSPLTypeCode
//******************************************************** N_GetSPLTypeCode ***
// Get full SPL Type Code by given Type Name and Records Array Editor Data Type 
// Flags
//
//     Parameters
// ARAFlags  - Records Array Editor Data Type Flags
// ATypeName - SPL TypeName
// Result    - Returns SPL full Type Code
//
function N_GetSPLTypeCode( ARAFlags: TN_RAEditFlags; ATypeName: string ): TK_ExprExtType;
begin
  Result := K_GetExecTypeCodeSafe( ATypeName );

  if raefCountUDRefs in ARAFlags then
    Result.D.CFlags := Result.D.CFlags or K_ccCountUDRef;

  if raefNotCountUDRefs in ARAFlags then
    Result.D.CFlags := Result.D.CFlags or K_ccStopCountUDRef;
end; // function N_GetSPLTypeCode

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_IsRArray
//************************************************************** N_IsRArray ***
// Check if given ATypeName is Array of Records
//
//     Parameters
// ATypeName - SPL Type Name
// Result    - Returns TRUE if given Type Name defines Array of Records (not 
//             single record structure).
//
function N_IsRArray( ATypeName: string ): boolean;
begin
//
  Result := K_StrStartsWith( K_sccArray, ATypeName, TRUE, Length(K_sccArray) );
//  Result := Copy( ATypeName, 1, Length(K_sccArray) ) = K_sccArray;
end; // function N_IsRArray

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_MatrElem
//************************************************************** N_MatrElem ***
// Get value of foat point Matrix Element as Double
//
//     Parameters
// AMatr  - Records Array Matrix
// AIndX  - Matrix Column index
// AIndY  - Matrix Row index
// Result - Returns Float or Double Matrix Element Value as Double
//
function N_MatrElem( AMatr: TK_RArray; AIndX, AIndY: integer ): double;
var
//  NX, NY, ElemType: integer;
  ElemType: integer;
  PData : Pointer;
begin
  Result := 0; // default value if AMatr = nil or AIndX, AIndY are out of bounds
  PData := AMatr.PME( AIndX, AIndY );
  if PData = nil then Exit;
  ElemType := AMatr.ElemSType;

  if ElemType = Ord(nptDouble) then
    Result := PDouble( PData )^
  else if ElemType = Ord(nptFloat) then
    Result := PFloat( PData )^
{
  Result := 0; // default value if AMatr = nil or AIndX, AIndY are out of bounds

  AMatr.ALength( NX, NY );

  if (AIndX < 0) or (AIndX >= NX) or
     (AIndY < 0) or (AIndY >= NY)    then Exit; // out of bounds

  ElemType := AMatr.GetElemType().DTCode;

  if ElemType = Ord(nptDouble) then
    Result := PDouble( AMatr.P( AIndX + AIndY*NX ))^
  else if ElemType = Ord(nptFloat) then
    Result := PFloat( AMatr.P( AIndX + AIndY*NX ))^
}
end; // function N_MatrElem

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CalcIntSizes
//********************************************************** N_CalcIntSizes ***
// Calculate array of integer Sizes by given Sizes number, Full Size and parts 
// coefficients
//
//     Parameters
// ARelCoefs    - array of relative (parts) coefficients to split given Full 
//                Size
// ANumSizes    - number of Sizes to split
// AFullIntSize - Full Size value to split
// AOutIntSizes - resulting array of splited Sizes (sum of all AOutIntSizes 
//                elements will be exactly AFullIntSize)
//
procedure N_CalcIntSizes( ARelCoefs: TN_FArray; ANumSizes, AFullIntSize: integer;
                                                  var AOutIntSizes: TN_IArray );
var
  i : integer;
  DSplitVal : Double;
  DVals, SVals : TN_DArray;
begin
  if ANumSizes <= 0 then Exit;
  SetLength( SVals, ANumSizes );

  for i := 0 to ANumSizes-1 do // Conv source floats to doubles
    SVals[i] := ARelCoefs[i];

  DSplitVal := AFullIntSize;
  SetLength( DVals, ANumSizes );

  K_RoundDVectorBySum( @DVals[0], ANumSizes, @SVals[0], @DSplitVal );

  if Length( AOutIntSizes ) < ANumSizes then
    SetLength( AOutIntSizes, ANumSizes );

  for i := 0 to ANumSizes-1 do // Conv rounded doubles to integers
    AOutIntSizes[i] := Round(DVals[i]);
{
var
  i, SumIntSizes, RestIntSize: integer;
  SumCoefs: float;
begin
  if ANumSizes <= 0 then Exit;

  if Length( AOutIntSizes ) < ANumSizes then
    SetLength( AOutIntSizes, ANumSizes );

  SumCoefs := 0;

  for i := 0 to ANumSizes-1 do // calc SumCoefs - sum of all ARelCoefs
    SumCoefs := SumCoefs + ARelCoefs[i];

  SumIntSizes := 0;

  for i := 0 to ANumSizes-1 do // calc Floor of AOutIntSizes and Sum of them
  begin
    AOutIntSizes[i] := Round( Floor( AFullIntSize*ARelCoefs[i]/SumCoefs ) );
    Inc( SumIntSizes, AOutIntSizes[i] );
  end;

  RestIntSize := AFullIntSize - SumIntSizes;

  // Add RestIntSize to first AOutIntSizes elements,
  // later improove algorithm: Add RestIntSize to AOutIntSizes elements
  //                           with max rounding error

  for i := 0 to RestIntSize-1 do
    Inc( AOutIntSizes[i] );
}
end; // procedure N_CalcIntSizes

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_InitAuxLine
//*********************************************************** N_InitAuxLine ***
// Initialize Elements of Records Array of TN_AuxLine Type
//
//     Parameters
// ARA      - given Records Array
// ABegInd  - element start idnex to initialize
// ANumInds - number of elements to initialize
//
// Is called automatically by Records Array method RA.InitElems
//
procedure N_InitAuxLine( ARA: TK_RArray; ABegInd, ANumInds: integer );
begin
  if ARA = nil then Exit; // a precaution
//  N_s := K_GetExecTypeName( ARA.DType.All ); // debug
  if K_GetExecTypeName( ARA.ElemType.All ) <> 'TN_AuxLine' then Exit;  // a precaution

end; // procedure N_InitAuxLine

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_InitExpParams
//********************************************************* N_InitExpParams ***
// Initialize Elements of Records Array of TN_ExpParams Type
//
//     Parameters
// ARA      - given Records Array
// ABegInd  - element start idnex to initialize
// ANumInds - number of elements to initialize
//
// Is called automatically by Records Array method RA.InitElems
//
procedure N_InitExpParams( ARA: TK_RArray; ABegInd, ANumInds: integer );
var
  i: integer;
begin
  if ARA = nil then Exit; // a precaution
//  N_s := K_GetExecTypeName( ARA.DType.All ); // debug
  if K_GetExecTypeName( ARA.ElemType.All ) <> 'TN_ExpParams' then Exit;  // a precaution

  for i := ABegInd to ABegInd+ANumInds-1 do
    TN_PExpParams(ARA.P(i))^ := N_DefExpParams;

end; // procedure N_InitExpParams

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_InitContAttr
//********************************************************** N_InitContAttr ***
// Initialize Elements of Records Array of TN_ContAttr Type
//
//     Parameters
// ARA      - given Records Array
// ABegInd  - element start idnex to initialize
// ANumInds - number of elements to initialize
//
// Is called automatically by Records Array method RA.InitElems
//
procedure N_InitContAttr( ARA: TK_RArray; ABegInd, ANumInds: integer );
var
  i: integer;
begin
  if ARA = nil then Exit; // a precaution
//  N_s := K_GetExecTypeName( ARA.DType.All ); // debug
  if K_GetExecTypeName( ARA.ElemType.All ) <> 'TN_ContAttr' then Exit;  // a precaution

  for i := ABegInd to ABegInd+ANumInds-1 do
  with TN_PContAttr(ARA.P(i))^ do
  begin
    CAPenWidth := 1.0;
    CABrushColor := $FFBCDE; // Fill by Light Blue
  end; // for i := BegInd to BegInd+NumInds-1 do

end; // procedure N_InitContAttr

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_InitNFont
//************************************************************* N_InitNFont ***
// Initialize Elements of Records Array of TN_NFont Type
//
//     Parameters
// ARA      - given Records Array
// ABegInd  - element start idnex to initialize
// ANumInds - number of elements to initialize
//
// Is called automatically by Records Array method RA.InitElems
//
procedure N_InitNFont( ARA: TK_RArray; ABegInd, ANumInds: integer );
var
  i: integer;
begin
  if ARA = nil then Exit; // a precaution
//  N_s := K_GetExecTypeName( ARA.DType.All ); // debug
  if K_GetExecTypeName( ARA.ElemType.All ) <> 'TN_NFont' then Exit;  // a precaution

  for i := ABegInd to ABegInd+ANumInds-1 do
  with TN_PNFont(ARA.P(i))^ do
  begin
    NFWin.lfCharSet := RUSSIAN_CHARSET; // = 204

    NFFaceName  := 'Arial';
    NFLLWHeight := 12;
  end; // for i := BegInd to BegInd+NumInds-1 do

end; // procedure N_InitNFont

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_PrepRArray
//************************************************************ N_PrepRArray ***
// Prepare Records Array Object with given Elements Number and Type
//
//     Parameters
// ARArray   - Records Array Object
// ANumElems - Number of Records Array Elements
// ATypeName - Records Array Element Type Name
//
// If ARArray is nil then new Records Array Object with elements of ATypeName 
// will be created.
//
procedure N_PrepRArray( var ARArray: TK_RArray; ANumElems: integer; ATypeName: string );
begin
  if ARArray = nil then
  begin
    Assert( ATypeName <> '', 'Bad TypeName!' );
    ARArray := K_RCreateByTypeName( ATypeName, ANumElems )
  end else if ARArray.ALength() < ANumElems then
    ARArray.ASetLengthI( ANumElems );
end; // procedure N_PrepRArray

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_PrepCAArray
//*********************************************************** N_PrepCAArray ***
// Prepare Records Array of TN_ContAttrArray with given Number of Elements
//
//     Parameters
// ACAArray  - Records Array of TN_ContAttrArray
// ANumElems - Number of Records Array Elements
//
// If ACAArray is nil then new Records Array Object with elements of 
// TN_ContAttrArray will be created.
//
procedure N_PrepCAArray( var ACAArray: TK_RArray; ANumElems: integer );
var
  i: integer;
  PRA: TK_PRArray;
begin
  if ACAArray = nil then
    ACAArray := K_RCreateByTypeName( 'TN_ContAttrArray', ANumElems )
  else if ACAArray.ALength() < ANumElems then
    ACAArray.ASetLengthI( ANumElems );

  for i := 0 to ANumElems-1 do
  begin
    PRA := TK_PRArray(ACAArray.P(i));
    if PRA^ = nil then
      PRA^ := K_RCreateByTypeName( 'TN_ContAttr', 0 )

  end; // for i := 0 to ANumElems-1 do
end; // procedure N_PrepCAArray

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_PrepContAttr
//********************************************************** N_PrepContAttr ***
// Assure that given TN_ContAttr have exactly one element clear it and return 
// pointer to it
//
// Prepare Records Array of TN_ContAttr with exactly one element
//
// Parameters AContAttr   - Records Array of TN_ContAttr Result - Returns 
// pointer Records Array Element Data
//
// If AContAttr is nil then new Records Array Object with exactly one element of
// TN_ContAttr will be created. If Records Array Element exists then it will be 
// cleared.
//
function N_PrepContAttr( var AContAttr: TK_RArray ): TN_PContAttr;
begin
  if AContAttr = nil then
    AContAttr := K_RCreateByTypeName( 'TN_ContAttr', 1 )
  else
    AContAttr.ASetLengthI( 1 );

  Result := TN_PContAttr(AContAttr.P());

  with Result^ do
  begin
    CADashSizes.Free;
    CAMarkers.Free;
    CAExtAttr.Free;
  end;

  FillChar( Result^, Sizeof(Result^), 0 );
end; // function N_PrepContAttr

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_FillContAttr1
//********************************************************* N_FillContAttr1 ***
// Set given Records Array of TN_ContAttr element by given draw Attributes
//
//     Parameters
// AContAttr   - Records Array of TN_ContAttr
// ABrushColor - Brush Clor
// APenColor   - Pen Color
// APenWidth   - Pen Width
//
procedure N_FillContAttr1( var AContAttr: TK_RArray; ABrushColor, APenColor: integer;
                                                             APenWidth: float );
begin
  with N_PrepContAttr( AContAttr )^ do
  begin
    CAPenColor   := APenColor;
    CAPenWidth   := APenWidth;
    CABrushColor := ABrushColor;
  end;
end; // procedure N_FillContAttr1

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_CreateContAttr1
//******************************************************* N_CreateContAttr1 ***
// Create Records Array of TN_ContAttr with one element and set it by given 
// Attributes
//
//     Parameters
// ABrushColor - Brush Clor
// APenColor   - Pen Color
// APenWidth   - Pen Width
// Result      - Returns created Records Array of TN_ContAttr
//
function N_CreateContAttr1( ABrushColor, APenColor: integer; APenWidth: float ): TK_RArray;
var
  PCA: TN_PContAttr;
begin
  Result := K_RCreateByTypeName( 'TN_ContAttr', 1 );
  PCA := TN_PContAttr(Result.P());
//  FillChar( PCA^, Sizeof(PCA^), 0 );

  with PCA^ do
  begin
    CAPenColor   := APenColor;
    CAPenWidth   := APenWidth;
    CABrushColor := ABrushColor;
  end;
end; // function N_CreateContAttr1

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_AssignRArray
//********************************************************** N_AssignRArray ***
// Assing Records Array Object variable by given Records Array Object
//
//     Parameters
// ADstRA - Records Array Object variable
// ASrcRA - source Records Array Object that is assined to ADstRA variable
//
procedure N_AssignRArray( var ADstRA: TK_RArray; ASrcRA: TK_RArray );
begin
//  if ADstRA <> nil then ADstRA.ARelease();
  ADstRA.ARelease();
  ADstRA := ASrcRA.AAddRef();
end; // procedure N_AssignRArray

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetNumElemes
//********************************************************** N_GetNumElemes ***
// Prepare destination Records Array Object for given number of Elements to copy
//
//     Parameters
// ASrcRA         - source Records Array Object
// ASrcInd        - source Records Array start element
// ADstRA         - destination Records Array Object
// ADstInd        - destination Records Array start element to copy
// ANumElems      - number of elements to copy
// AElemsTypeName - Records Array Elements Type Name
// Result         - Returns Number of elements to copy (<= ANumElems)
//
function N_GetNumElemes( ASrcRA: TK_RArray; ASrcInd: integer;
                         var ADstRA: TK_RArray; ADstInd, ANumElems: integer;
                                              AElemsTypeName: string ): integer;
var
  NeededDstSize: integer;
begin
  Result := 0;
  if ASrcRA = nil then Exit; // a precaution

  if ANumElems <= 0 then // means that ANumElems is skip from the End Cont
    Result := ASrcRA.ALength() + ANumElems - ASrcInd
  else
    Result := ANumElems;

  if Result <= 0 then
  begin
    Result := 0;
    Exit;
  end;

  NeededDstSize := ADstInd + Result;
  if ADstRA.ALength() < NeededDstSize then
  begin
    if ADstRA = nil then begin
      Assert( AElemsTypeName <> '', 'Type Name not given!' );
      ADstRA := K_RCreateByTypeName( AElemsTypeName, NeededDstSize )
    end else
      ADstRA.ASetLength( NeededDstSize );
  end;

end; // function N_GetNumElemes

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_AddRArrayInfo
//********************************************************* N_AddRArrayInfo ***
// Add Info about given Records Array to given Strings
//
//     Parameters
// ARA      - given Records Array Object
// AStrings - Strings to add Records Array Info
//
procedure N_AddRArrayInfo( ARA: TK_RArray; AStrings: TStrings );
var
  NX, NY: integer;
  ArrayTName, ElemTName, AttrTName: string;
begin
  if ARA <> nil then
  begin
    ARA.ALength( NX, NY );
    AStrings.Add( Format( 'RArray Dimensions: NX=%d,  NY=%d', [NX,NY] ) );

    if ARA.AttrsSize = 0 then // no Attributes
    begin
      ElemTName  := K_GetExecTypeName( ARA.ElemType.All );
      AStrings.Add( Format( 'No Attributes, Elem Type Name : %s', [ElemTName] ) );
    end else // ARA has Attributes
    begin
      ArrayTName := K_GetExecTypeName( ARA.ArrayType.All );
      ElemTName  := K_GetExecTypeName( ARA.ElemType.All );
      AttrTName  := K_GetExecTypeName( ARA.AttrsType.All );
      AStrings.Add( Format( 'Type Names - Main : %s,  Elem : %s,  Attr : %s',
                                         [ArrayTName, ElemTName, AttrTName] ) );
    end;
  end else // ARA = nil
    AStrings.Add( 'RArray is nil' );
end; // procedure N_AddRArrayInfo

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_RegActionProc
//********************************************************* N_RegActionProc ***
// Register given procedure that should be called from TN_UDAction
//
//     Parameters
// AProcName    - registed procedure Name
// AnActionProc - pointer to registed procedure
//
procedure N_RegActionProc( AProcName: string; AnActionProc: TN_ActionProc );
var
  WW : TObject;
begin
  TN_ActionProc(WW) := AnActionProc;
  K_RegListObject( TStrings(N_ActionProcs), AProcName, WW );
end; //*** end of procedure N_RegActionProc

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetPVArrayData
//******************************************************** N_GetPVArrayData ***
// Get pointer to Start Element Data of given Virtual Records Array Object
//
//     Parameters
// AVArray - Virtual Records Array Object
// Result  - Returns Pointer to Virtual Records Array Object start Element Data
//
// If given Virtual Records Array Object is not assigned or it's start Element 
// is absent.
//
function N_GetPVArrayData( AVArray: TObject ): Pointer;
begin
  Result := K_GetPVRArray( AVArray ).P();
{
  if AVArray is TK_UDRArray then // VArray is UDRArray
    Result := TK_UDRArray(AVArray).R.P()
  else
    Result := TK_RArray(AVArray).P();
}
end; //*** end of N_GetPVArrayData

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SelectUDBase
//********************************************************** N_SelectUDBase ***
// Select IDB object in Current Archive using IDB Objects Tree Dialog
//
//     Parameters
// ADefUDBase - IDB Object that would be initially highlighted
// ACaption   - Select IDB Object Dialog Caption
// Result     - Returns selected IDB Object or nil if Select Dialog was break
//
function N_SelectUDBase( ADefUDBase: TN_UDBase; ACaption: string ): TN_UDBase;
var
  InitialPath: string;
begin
{
  if ADefUDBase <> nil then
    InitialPath := K_CurArchive.GetRefPathToObj( ADefUDBase )
  else
    InitialPath := '';
}
  InitialPath := K_GetPathToUObj( ADefUDBase, K_CurArchive );
  Result := K_SelectUDB( K_CurArchive, InitialPath, nil, nil, ACaption );
end; //*** end of function N_SelectUDBase

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SetNodeWasChanged_NotUsed
//********************************************* N_SetNodeWasChanged_NotUsed ***
// obsolete is not used
//
// Set "was changed" Flag to IDB SubTree if given Object was changed
//
// Parameters ANode - IDB Object to mark by "was changed" Flag
//
// "Was changed" Flag will be set to given IDB Object and all Owner Objects up 
// to Archive Root or Separately Loaded SubTree Root
//
procedure N_SetNodeWasChanged_NotUsed( ANode: TN_UDBase );
begin
  K_SetChangeSubTreeFlags( ANode, [] );
end; //*** end of procedure procedure N_SetNodeWasChanged

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SetChildsWereChanged
//************************************************** N_SetChildsWereChanged ***
// Set "was changed" Flag to IDB SubTree if given Object Childs were changed
//
//     Parameters
// ANode - IDB Object which Childs were changed
//
// "Was changed" Flag will be set to given IDB Object and all Owner Objects up 
// to Archive Root or Separately Loaded SubTree Root. If given IDB Object is 
// self Separately Loaded SubTree Root, then it will be mark by another flag 
// "Separately Loaded SubTree Childs were changed".
//
procedure N_SetChildsWereChanged( AParent: TN_UDBase );
begin
  K_SetChangeSubTreeFlags( AParent, [K_cstfSetSLSRChangeFlag] );
end; //*** end of procedure procedure N_SetChildsWereChanged

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_SetSubTreeWasChanged
//************************************************** N_SetSubTreeWasChanged ***
// Set "was changed" Flag to given IDB Object and all it's Childs
//
//     Parameters
// ANode - IDB Object which SubTree was changed
//
// "Was changed" Flag will be set to given IDB Object, all Owner Objects up to 
// Archive Root or Separately Loaded SubTree Root and all it's Childs.
//
procedure N_SetSubTreeWasChanged( ARoot: TN_UDBase );
begin
  K_SetChangeSubTreeFlags( ARoot, [K_cstfSetDown] );
end; //*** end of procedure procedure N_SetSubTreeWasChanged

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_LoadTImage
//************************************************************ N_LoadTImage ***
// Load Image content from given virtual file
//
//     Parameters
// AImage     - TImage Object to load
// AVFileName - virtual file name
// ATranspBMP - if TRUE then Transparent Color Mode will be used for file in BMP
//              format
//
// In Transparent Color Mode BMP images are treated as having Transparent Color 
// equal to Color of Bottom Left most BMP pixel (JPEG images are always treated 
// as not Transparent).
//
procedure N_LoadTImage( AImage: TImage; AVFileName: string; ATranspBMP: boolean );
var
  DataSize: integer;
  VFName: string;
  VFType: TN_ImageFileFormat;
  TmpBitmap: TBitmap;
  TmpMF: TMetafile;
  VFile: TK_VFile;
  Stream: TStream;
  Buf10 : array [1..10] of byte;
//  Buf: TN_BArray;
//  MStream: TMemoryStream;
begin
  VFName := K_ExpandFileName( AVFileName );
  K_VFAssignByPath( VFile, VFName );
  DataSize := K_VFOpen( VFile );
  if DataSize = -1 then Exit; // Open error
 
  Stream := K_VFStreamGetToRead( VFile );
  Stream.Read( Buf10[1], 10 );
  VFType := N_GetFileFmtByHeader( @Buf10[1] );
  Stream.Seek( 0, soFromBeginning );
  if VFType = imffEMF then
  begin
    TmpMF := TMetafile.Create();
    TmpMF.LoadFromStream( Stream );
    AImage.Picture.Metafile := TmpMF;
    TmpMF.Free;
  end else // BMP, GIF or JPEG
  begin
    TmpBitmap := N_CreateBMPObjFromStream( Stream );
    if TmpBitmap <> nil then
    begin
      if ATranspBMP and (VFType = imffBMP) then
      begin // Proper Stream Format
  //    TmpBitmap.TransparentMode := tmFixed;
  //    TmpBitmap.TransparentColor := $FF00FF;
        TmpBitmap.TransparentMode := tmAuto;
        TmpBitmap.Transparent := True;
        AImage.Transparent := True;
      end else if VFType = imffGIF then
      begin
        if N_GlobObj.GOGifTranspColor <> -1 then
          AImage.Transparent := True;
      end;
 
      AImage.Picture.Graphic := TmpBitmap;
      TmpBitmap.Free;
    end;
  end;
 
  K_VFStreamFree(VFile);
  Exit;
end; //*** end of procedure N_LoadTImage

//********************************************************** N_AddNumRArray ***
// Add Values of given Numerical (integer, float, double) ARArray to given AStrings,
// adding given ANumVals Values in row (mainly for debug logging)
//
procedure N_AddNumRArray( ARArray: TK_RArray; ANumVals: integer;
                                                        AStrings: TStrings  );
//###??? Эта функция используется только в N_TstC1, кандидат на выкидывание
var
  i, RowInd, SType: integer;
  BufStr: string;
begin
  SType := ARArray.ElemSType;
  RowInd := 0;
  BufStr := '';

  for i := 0 to ARArray.AHigh() do
  begin
    if i mod (ANumVals+1) = 0 then // End of row
    begin
      if BufStr <> '' then AStrings.Add( BufStr );
      BufStr := Format( '%0.3d) ', [RowInd] );
    end; // if i mod (ANumVals+1) = 0 then // End of row

    case SType of
    Ord(nptInt):    BufStr := Format( '%s  %d',  [BufStr, PInteger(ARArray.P(i))^] );
    Ord(nptFloat):  BufStr := Format( '%s  %.f', [BufStr, PInteger(ARArray.P(i))^] );
    Ord(nptDouble): BufStr := Format( '%s  %.f', [BufStr, PInteger(ARArray.P(i))^] );

    Ord(nptDPoint): with PDPoint(ARArray.P(i))^ do BufStr := Format( '%s  %.f, %f', [BufStr,X,Y] );
    end; // case SType of

  end; // for i := 0 to ARArray.AHigh() do

  AStrings.Add( BufStr ); // Add Last row
end; //*** end of procedure N_AddNumRArray

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_RootIsOwner
//*********************************************************** N_RootIsOwner ***
// Check if given IDB Object is Owner Ancestor Object for another IDB Object
//
//     Parameters
// AUObj  - probable Owner Descendant Object for ARoot
// ARoot  - probable Owner Ancestor Object for AUObj
// Result - Returns TRUE if ARoot is Owner Ancestor Object for AUObj
//
function N_RootIsOwner( AUObj, ARoot: TN_UDBase ): boolean;
begin
  Result := False;
  if AUObj = nil then Exit; // ARoot is NOT AUObj Owner

  if AUObj = ARoot then
  begin
    Result := True;
    Exit;
  end;

  Result := N_RootIsOwner( AUObj.Owner, ARoot );
end; // function N_RootIsOwner

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetUObjPath
//*********************************************************** N_GetUObjPath ***
// Create Path string to given IDB Object from another IDB Object
//
//     Parameters
// AUObj      - given destination IDB Object for Path creating
// ARoot      - given source Root IDB Object for Path creating
// AMaxSize   - resulting Path string maximal length (if =0, then no PAth string
//              length control will be done)
// APathFlags - Path creation Flags set
// Result     - Returns relative path string from ARoot to AUObj
//
// If Path string maximal length is less than full resuting path length then 
// resulting value will be created as '...' + <truncated full path tail>.
//
function N_GetUObjPath( AUObj, ARoot: TN_UDBase; AMaxSize: integer;
                                         APathFlags: TN_UObjPathFlags ): string;
var
  FPSize: integer;
  FullPath: string;
  NameType: TK_UDObjNameType;
  UseOwnersPath, ARootIsOwner: boolean;
begin
//APathFlags: upfUseUObjName, upfOwnersPath, upfUObjRefPath, upfOneSegmPath
  Result := '';
  if AUObj = nil then Exit;

  //***** Check some special cases
  if AUObj = K_MainRootObj then
  begin
    Result := 'MainRoot';
    Exit;
  end else if AUObj = K_CurArchive then
  begin
    Result := K_CurArchive.ObjName;
    Exit;
  end;

  NameType := K_ontObjUName;
  if upfUseUObjName in APathFlags then
    NameType := K_ontObjName;

  //***** Build needed FullPath
  if upfUObjRefPath in APathFlags then //***** For Unresolved refs only
    FullPath := AUObj.RefPath
  else if upfOneSegmPath in APathFlags then // One Segment Path (AUObj Name or Aliase)
    FullPath := AUObj.GetUName( NameType )
  else //************************************* Owners Path or Path from ARoot
  begin

    ARootIsOwner := N_RootIsOwner( AUObj, ARoot );
    UseOwnersPath := upfOwnersPath in APathFlags;

    if ARootIsOwner and not UseOwnersPath then // Path from ARoot
    begin
//      FullPath := ARoot.GetPathToObj( AUObj, NameType );
      FullPath := K_GetPathToUObj( AUObj, ARoot, NameType, [K_ptfSkipScanOwners] );
    end else //********************************** Owners Path
    begin
      if ARootIsOwner then
//        FullPath := AUObj.GetOwnersPath( ARoot, NameType )
        FullPath := K_GetPathToUObj( AUObj, ARoot, NameType )
      else
//        FullPath := AUObj.GetOwnersPath( K_CurArchive, NameType );
        FullPath := K_GetPathToUObj( AUObj, K_CurArchive, NameType );
    end; // else // Owners Path
//!!! May be is OK single this call instead of all previous code
//    FullPath := K_GetPathToUObj( AUObj, ARoot, NameType, [K_ptfTryAltRelPath, K_ptfBreakByRefPath] );

  end; // Owners Path or Path from ARoot

  //***** FullPath is OK, build ShortPath if needed
  FPSize := Length(FullPath);
  if (AMaxSize = 0) or (FPSize < AMaxSize) then // Return Full Path
    Result := FullPath
  else // Return Short Path
    Result := '...' + Copy( FullPath, FPSize-AMaxSize+1, AMaxSize ) +
              ' (' + FullPath + ')';
end; // function N_GetUObjPath

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetPathFlags
//********************************************************** N_GetPathFlags ***
// Get IDB Subnet Path creation flags set from IDB Subnet Info representation 
// flags
//
//     Parameters
// AGetInfoFlags - IDB Subnet Info representation flags set
// Result        - Returns IDB Subnet Path creation flags set
//
function N_GetPathFlags( AGetInfoFlags: TN_GetInfoFlags ): TN_UObjPathFlags;
//
// Return Path Flags by given AGetInfoFlags and Keyboard State:
// Set PathFlags in Dialogue if Shift is Down or
// Use N_GlobObj.GOPathFlags if Ctrl is Down
//
begin
  Result := [];
  if gifObjNames  in AGetInfoFlags then Result := Result + [upfUseUObjName];
  if gifOwnerPath in AGetInfoFlags then Result := Result + [upfOwnersPath];

  if N_KeyIsDown( VK_SHIFT ) then // Set PathFlags in Dialogue
  begin
    N_EditRecord( [], Result, 'TN_UObjPathFlags', 'Edit Path Flags', '', nil, nil, nil, mmfModal );
  end else if N_KeyIsDown( VK_CONTROL ) then // Use N_GlobObj.GOPathFlags
    Result := N_GlobObj.GOPathFlags;
end; // function N_GetPathFlags


//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetUnresRefsInfo
//****************************************************** N_GetUnresRefsInfo ***
// Add Unresolved references Info from IDB SubTree given by Root to given 
// Strings
//
//     Parameters
// ASL    - Strings where Resulting Info to add
// ARoot  - IDB SubTree Root for Unresolved references search
// AFlags - IDB Subnet Info representation flags
//
function N_GetUnresRefsInfo( ASL: TStrings; ARoot: TN_UDBase;
                                            AFlags: TN_GetInfoFlags ): integer;
var
  i, j, NumRow, MaxRows, NumAbsObj: integer;
  SubTreeName: string;
  PathFlags: TN_UObjPathFlags;
begin
  with TK_ScanUDSubTree.Create do begin
    BuildUDRefParentsList( ARoot, [K_udtsRAFieldsScan] ); // collect info in internal Lists

    Result := ParentLPaths.TotalCount;
    if Result = 0 then
    begin
      ASL.Add( 'No Unresolved References' );
      Exit;
    end;

    PathFlags := N_GetPathFlags( AFlags );
    SubTreeName := N_GetUObjPath( ARoot, nil, 0, PathFlags );

    ASL.Add( IntToStr(Result) + '  Unresolved References in "' +
                                SubTreeName + '" SubTree:' );    // Info Header

    if ([gifMediumInfo, gifMaxInfo] * AFlags) = [] then Exit;

    ASL.Add( '' );
    ASL.Add( 'Absent UObjects:' );
    NumAbsObj := UniqRefs.Count;
    if not (gifGetAllRows in AFlags) then
      NumAbsObj := Min( NumAbsObj, N_MaxGetInfoRows div 2 );

    for i := 0 to NumAbsObj-1 do
      ASL.Add( '  ' + TN_UDBase(UniqRefs[i]).RefPath );

    if NumAbsObj < UniqRefs.Count then
      ASL.Add( '   ......... and other ....'  );

    ASL.Add( '' );

    MaxRows := N_MaxGetInfoRows-NumAbsObj;
    NumRow := 1;

    for i := 0 to ParentNodes.Count-1 do // along Source UDBase Objects
    begin
      ASL.Add( ' UObj ' + N_GetUObjPath( TN_UDBase(ParentNodes[i]),
                          ARoot, N_PathShortSize, PathFlags ) + ' :' );
      Inc( NumRow );
      with TStrings( ParentLPaths[i] ) do // Local Path --> Dst UObj
      begin
        for j := 0 to Count-1 do
        begin
          ASL.Add( '  ' + Strings[j] + ' --> ' +
                          N_GetUObjPath( TN_UDBase(Objects[j]),
                          nil, 0, [upfUObjRefPath] ) );
          Inc( NumRow );
          if (MaxRows > 0) and (NumRow > MaxRows) then Break;
        end; // for j := 0 to Count-1 do

        if (MaxRows > 0) and (NumRow > MaxRows) then Break;
      end; // with TStrings( ParentLPaths[i] ) do // Local Path --> Dst UObj

    end; // for i := 0 to ASrcUObjects.Count-1 do // along Source UDBase Objects

    if (MaxRows > 0) and (NumRow > MaxRows) then // restrict Info Rows
    begin
      ASL.Add( '......... and other ....'  );
    end;

    ASL.Add( '' );
    Free; // Free TK_ScanUDSubTree object
  end; // with TK_ScanUDSubTree.Create do begin
end; //*** end of function N_GetUnresRefsInfo

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetExtUObjects
//******************************************************** N_GetExtUObjects ***
// Add External IDB Objects Info from IDB SubTree given by Root to given Strings
//
//     Parameters
// ASL    - Strings where Resulting Info to add
// ARoot  - IDB SubTree Root for External IDB Objects search
// AFlags - IDB Subnet Info representation flags
//
// External IDB Objects in IDB Subtree means Objects referenced from outside of 
// given SubTree.
//
procedure N_GetExtUObjects( ASL: TStrings; ARoot: TN_UDBase;
                                                     AFlags: TN_GetInfoFlags );
var
  i, NumExtObj: integer;
  SubTreeName: string;
  PathFlags: TN_UObjPathFlags;
begin
  with TK_ScanUDSubTree.Create do begin
    BuildEERefNodesLists( ARoot, False );

    PathFlags := N_GetPathFlags( AFlags );
    SubTreeName := N_GetUObjPath( ARoot, nil, 0, PathFlags );

    ASL.Add( Format( '  %d Ext UObjects in "%s" SubTree :',
                       [EntryNodes.Count,SubTreeName] ) );
    ASL.Add( '' );
    if ([gifMediumInfo, gifMaxInfo] * AFlags) = [] then Exit;

    NumExtObj := EntryNodes.Count;
    if NumExtObj >= 1 then // add Info about External UObjects
    begin
      NumExtObj := Min( NumExtObj, N_MaxGetInfoRows );

      for i := 0 to NumExtObj-1 do
        ASL.Add( '  ' + N_GetUObjPath( TN_UDBase(EntryNodes[i]), ARoot, 0, PathFlags ) );

      if NumExtObj < EntryNodes.Count then
        ASL.Add( '   ......... and other ....'  );

      ASL.Add( '' );
    end; // if NumExtObj >= 1 then // add Info about External UObjects

    Free; // Free TK_ScanUDSubTree object
  end; // with TK_ScanUDSubTree.Create do begin
end; //*** end of function N_GetExtUObjects

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetRefsToUObj
//********************************************************* N_GetRefsToUObj ***
// Add Info about references to given IDB Object from IDB SubTree given by Root 
// to given Strings
//
//     Parameters
// ASL        - Strings where Resulting Info to add
// AUObj      - Target IDB Object
// ARoot      - IDB SubTree Root of SubTree where references to AUObj to seach
// AScanFlags - IDB Data Subnet scan Objects flags set
// AFlags     - IDB Subnet Info representation flags
// Result     - Returns number of found references
//
function N_GetRefsToUObj( ASL: TStrings; AUObj, ARoot: TN_UDBase;
                          AScanFlags: TK_UDTreeChildsScanFlags;
                                            AFlags: TN_GetInfoFlags ): integer;
var
  i, j: integer;
  SubTreeName, UObjName: string;
  DstUObj: TN_UDBase;
  PathFlags: TN_UObjPathFlags;
begin
  with TK_ScanUDSubTree.Create do begin
    BuildParentsList( ARoot, AUObj, AScanFlags ); // collect info in internal Lists

    Result := ParentLPaths.TotalCount;
    if Result = 0 then
    begin
      ASL.Add( 'No Refs found' );
      Exit;
    end;

    PathFlags := N_GetPathFlags( AFlags );
    SubTreeName := N_GetUObjPath( ARoot, nil, 0, PathFlags );
    UObjName := N_GetUObjPath( AUObj, nil, 0, PathFlags );

    ASL.Add( IntToStr(Result) + ' Ref(s) to ' + UObjName );

    if ARoot <> K_CurArchive then
      ASL.Add( '  From "' + SubTreeName + '" SubTree:' );

    if ([gifMediumInfo, gifMaxInfo] * AFlags) = [] then Exit;

    ASL.Add( '' ); // add delimeter string

    for i := 0 to ParentNodes.Count-1 do // along UObjects in Source SubTree
    begin
      ASL.Add( ' From ' + N_GetUObjPath( TN_UDBase(ParentNodes[i]),
                                  ARoot, N_PathShortSize, PathFlags ) + ' :' );
      with TStrings( ParentLPaths[i] ) do // Local Path --> Dst UObj
      begin
        for j := 0 to Count-1 do
        begin
          DstUObj := TN_UDBase(Objects[j]);
          ASL.Add( '  ' + Strings[j] + ' --> ' +
                    N_GetUObjPath( DstUObj, ARoot, N_PathShortSize,
                                            PathFlags + [upfOneSegmPath] ) );
        end; // for j := 0 to Count-1 do
      end; // with TStrings( ParentLPaths[i] ) do // Local Path --> Dst UObj

      ASL.Add( '' ) // add delimeter string
    end; // for i := 0 to ParentNodes.Count-1 do // along UObjects in Source SubTree

    Free; // Free TK_ScanUDSubTree object
  end; // with TK_ScanUDSubTree.Create do begin
end; //*** end of function N_GetRefsToUObj

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetRefsFromSubTree
//**************************************************** N_GetRefsFromSubTree ***
// Add External references Info from IDB SubTree given by Root to given Strings
//
//     Parameters
// ASL    - Strings where Resulting Info to add
// ARoot  - IDB SubTree Root for External references search
// AFlags - IDB Subnet Info representation flags
//
procedure N_GetRefsFromSubTree( ASL: TStrings; ARoot: TN_UDBase;
                                               AFlags: TN_GetInfoFlags );
var
  i, j: integer;
  SubTreeName: string;
  DstUObj: TN_UDBase;
  PathFlags: TN_UObjPathFlags;
begin
  with TK_ScanUDSubTree.Create do begin
    BuildEERefNodesLists( ARoot );

    PathFlags := N_GetPathFlags( AFlags );
    SubTreeName := N_GetUObjPath( ARoot, nil, 0, PathFlags );

    ASL.Add( Format( '  %d Ext Refs From SubTree  "%s" :',
                               [ParentLPaths.TotalCount, SubTreeName] ) );
    if ([gifMediumInfo, gifMaxInfo] * AFlags) = [] then Exit;

    if ParentLPaths.TotalCount > 0 then  // add Info about External refs
    begin
      ASL.Add( '' );

      for i := 0 to ParentNodes.Count-1 do // along UObjects in Source SubTree
      begin
        ASL.Add( ' From ' + N_GetUObjPath( TN_UDBase(ParentNodes[i]),
                                    ARoot, N_PathShortSize, PathFlags ) + ' :' );
        with TStrings( ParentLPaths[i] ) do // Local Path --> Dst UObj
        begin
          for j := 0 to Count-1 do
          begin
            DstUObj := TN_UDBase(Objects[j]);
            ASL.Add( '  ' + Strings[j] + ' --> ' +
                     N_GetUObjPath( DstUObj, ARoot, N_PathShortSize, PathFlags ));
          end; // for j := 0 to Count-1 do
        end; // with TStrings( ParentLPaths[i] ) do // Local Path --> Dst UObj

        ASL.Add( '' ) // add delimeter string
      end; // for i := 0 to ParentNodes.Count-1 do // along UObjects in Source SubTree

    end; // if ParentLPaths.TotalCount > 0 then  // add Info about External refs

    Free; // Free TK_ScanUDSubTree object
  end; // with TK_ScanUDSubTree.Create do begin
end; //*** end of function N_GetRefsFromSubTree

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_GetRefsBetween
//******************************************************** N_GetRefsBetween ***
// Add references Info from source IDB SubTree to destination IDB SubTree to 
// given Strings
//
//     Parameters
// ASL      - Strings where Resulting Info to add
// ASrcRoot - source IDB SubTree Root for External references search
// ADstRoot - destination IDB SubTree Root for External Objects search
// AFlags   - IDB Subnet Info representation flags
//
procedure N_GetRefsBetween( ASL: TStrings; ASrcRoot, ADstRoot: TN_UDBase;
                                                     AFlags: TN_GetInfoFlags );
var
  i, j, NumRefs, FirstInd: integer;
  Str, SrcRootName, DstRootName: string;
  RefsInDst: boolean;
  DstUObj: TN_UDBase;
  PathFlags: TN_UObjPathFlags;
begin
  with TK_ScanUDSubTree.Create do begin
    BuildEERefNodesLists( ASrcRoot );

    PathFlags := N_GetPathFlags( AFlags );
    SrcRootName := N_GetUObjPath( ASrcRoot, nil, 0, PathFlags );
    DstRootName := N_GetUObjPath( ADstRoot, nil, 0, PathFlags );

    FirstInd := ASL.Count;
    ASL.Add( ' Ref(s) from ' + SrcRootName );
    ASL.Add( '        into ' + DstRootName );
    ASL.Add( '' );
    NumRefs := 0;

    for i := 0 to ParentNodes.Count-1 do // along UObjects in Source SubTree
    begin
      Str := ' From Src UObj ' + N_GetUObjPath( TN_UDBase(ParentNodes[i]),
                                   ASrcRoot, N_PathShortSize, PathFlags ) + ' :';
      RefsInDst := False;

      with TStrings( ParentLPaths[i] ) do // Local Path --> Dst UObj
      begin
        for j := 0 to Count-1 do
        begin
          DstUObj := TN_UDBase(Objects[j]);
          if N_RootIsOwner( DstUObj, ADstRoot ) then // Ref inside Dst SubTree
          begin
            if not RefsInDst then ASL.Add( Str );
            Inc( NumRefs );
            RefsInDst := True;
            ASL.Add( '  ' + Strings[j] + ' --> ' +
                      N_GetUObjPath( DstUObj, ADstRoot, N_PathShortSize, PathFlags ) );
          end;
        end; // for j := 0 to Count-1 do

        if RefsInDst then ASL.Add( '' );
      end; // with TStrings( ParentLPaths[i] ) do // Local Path --> Dst UObj

    end; // for i := 0 to ParentNodes.Count-1 do // along UObjects in Source SubTree

    if NumRefs = 0 then // Change Header
    begin
      //*** Each Info String may occupy several ASL strings because of
      //    Word Wrap mode (if ASL is Memo.Lines)!

      while ASL.Count > FirstInd do // clear all strings
        ASL.Delete( ASL.Count - 1 );

      ASL.Add( ' No Refs from ' + SrcRootName );
      ASL.Add( '         into ' + DstRootName );
      ASL.Add( '' );

    end; // if NumRefs = 0 then // Change Header

    Free; // Free TK_ScanUDSubTree object
  end; // with TK_ScanUDSubTree.Create do begin
end; //*** end of function N_GetRefsBetween

//********************************************************** N_ConvUObjects ***
// Convert all suitable UObjects in given ADstUObjDir by given AFunc and
//   update AMapRoot CompUCoords if needed
// Return number of converted UObjects and theirs ObjNames
//
//    Parameters
// ASrcUObjDir - Source UObjects Dir, if <> nil Dst UObjects would be
//               initialized by Source UObjects before convertion
// ADstUObjDir - Destination UObjects Dir (with UObjects to Convert)
// AMapRoot    - MapRoot Component (that shows Dst UObjects), if <> nil, it's
//               CompUCoords field in Static Params would be set by EnvRect
//               of all resulting coords, scaled by given AScaleCoef (if <> 0)
// AFunc       - One DPoint Coords Converting Function of Object (may be nil)
// APAuxPar    - Aux Params for AFunc
// AScaleCoef  - on output, MapRoot CompUCoords is set to DstCObjEnvRect*AScaleCoef
//               AScaleCoef=0 means, that CompUCoords remains the same
// APInfoStr   - Pointer to Info String, where to place on output list of
//               converted UObj ObjNames
//
function N_ConvUObjects( ASrcUObjDir, ADstUObjDir, AMapRoot: TN_UDBase;
                         AFunc: TN_ConvDPFuncObj; APAuxPar: Pointer;
                         AScaleCoef: float; APInfoStr: PString ): integer;
//###??? Эта функция похоже очень специальный случай поэтому не включена в общее описание
var
  i: integer;
  Str: string;
  CurDstUObj, CurSrcUObj: TN_UDBase;
  TmpDPoint: TDPoint;
  DstEnvRect: TFRect;
begin
  Result := 0;

  Str := '';
  DstEnvRect.Left := N_NotAFloat;

  for i := 0 to ADstUObjDir.DirHigh() do // along all UObjects in ADstUObjDir
  begin
    CurDstUObj := ADstUObjDir.DirChild( i );

    if not (CurDstUObj is TN_UCObjLayer) and
       not (CurDstUObj is TN_UDCompVis) then Continue;

    K_SetChangeSubTreeFlags( CurDstUObj );

    if CurDstUObj is TN_UContours then // Contours have no self coords
    begin
      TN_UContours(CurDstUObj).ClearCoordsOKFlags();
      Continue;
    end; // if CurDstUObj is TN_UContours then

    if Assigned(AFunc) and
       (CurDstUObj is TN_UDCompVis) then // Convert Component Static User Coords Fields
    with TN_UDCompVis(CurDstUObj).PCCS()^ do
    begin
      if BPXCoordsType = cbpUser then
      begin
        TmpDPoint := AFunc( DPoint(BPCoords), APAuxPar );
        BPCoords.X := TmpDPoint.X;
      end;

      if BPYCoordsType = cbpUser then
      begin
        TmpDPoint := AFunc( DPoint(BPCoords), APAuxPar );
        BPCoords.Y := TmpDPoint.Y;
      end;

      if LRXCoordsType = cbpUser then
      begin
        TmpDPoint := AFunc( DPoint(LRCoords), APAuxPar );
        LRCoords.X := TmpDPoint.X;
      end;

      if LRYCoordsType = cbpUser then
      begin
        TmpDPoint := AFunc( DPoint(LRCoords), APAuxPar );
        LRCoords.Y := TmpDPoint.Y;
      end;
    end; // if CurDstUObj is TN_UDCompVis then

    if ASrcUObjDir <> nil then // Init CurDstUObj by SrcUObj with same ObjName
    begin
      CurSrcUObj := ASrcUObjDir.DirChildByObjName( CurDstUObj.ObjName );

      if (CurSrcUObj is TN_UDCompVis) and
         (CurDstUObj is TN_UDCompVis) then
        TN_UDCompVis(CurDstUObj).PCCS()^ := TN_UDCompVis(CurSrcUObj).PCCS()^;

      if (CurSrcUObj is TN_UCObjLayer) and
         (CurDstUObj is TN_UCObjLayer) then
        TN_UCObjLayer(CurDstUObj).CopyContent( CurSrcUObj );

    end; // if ASrcUObjDir <> nil then // Init CurDstUObj by SrcUObj with same ObjName

    if CurDstUObj is TN_UCObjLayer then // Process Coords Objects
    begin
      if Assigned(AFunc) then
        TN_UCObjLayer(CurDstUObj).ConvSelfCoords( AFunc, APAuxPar );

      N_FRectOr( DstEnvRect, TN_UCObjLayer(CurDstUObj).WEnvRect );
    end; // if CurDstUObj is TN_UCObjLayer then // Process Coords Objects

    Str := Str + ', ' + CurDstUObj.ObjName; // collect converted UObjects ObjNames
  end; // for i := 0 to ADstUObjDir.DirHigh() do // along all CObjects in ADstUObjDir

  //***** Update AMapRoot.CompUCoords field in Static Params (if needed)

  if (AScaleCoef > 0) and (AMapRoot is TN_UDCompVis) and
     (DstEnvRect.Left <> N_NotAFloat) then // updating is needed
  begin
    DstEnvRect := N_RectRoundInc( N_RectScaleR( DstEnvRect, AScaleCoef, N_05DPoint ), 0);
    TN_UDCompVis(AMapRoot).PCCS()^.CompUCoords := DstEnvRect;
    K_SetChangeSubTreeFlags( AMapRoot );
  end; // if (AScaleCoef > 0) and (AMapRoot is TN_UDCompVis) then // updating is needed

  if APInfoStr <> nil then APInfoStr^ := Str;

end; //*** end of procedure N_ConvUObjects

//*************************************************************** N_IAddSPL ***
// Show SPL Value
//
procedure N_IAddSPL( const ASPLVar; APrefix: string; ASPLTCode: integer );
//###??? Эта функция нигде не используется кандидат на выкидывание
var
  FullTCode: TK_ExprExtType;
begin
  FullTCode.All := ASPLTCode;
  N_IAdd( APrefix + K_SPLValueToString( ASPLVar, FullTCode ) );
end; // procedure N_IAddSPL

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_ArchDFilesDir
//********************************************************* N_ArchDFilesDir ***
// Get Current Archive Linked Files Directory Name
//
//     Parameters
// Result - Returns Current Archive Linked Files Directory Full Name without 
//          trailing BackSlash or empty string if Archive Name is absent
//
function N_ArchDFilesDir(): string;
begin
  Result := ChangeFileExt( K_CurArchive.ObjAliase, '.files' );

  if ExtractFileDrive( Result ) = '' then // no Path, usually K_CurArchive.ObjAliase = 'Untitled'
  begin
    Result := ''; // Error Flag
    Exit;
  end;
end; // function N_ArchDFilesDir

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_ArchDFilesUniqueName
//************************************************** N_ArchDFilesUniqueName ***
// Create Current Archive Linked File unique Name
//
//     Parameters
// AInitialName - file name prefix
// Result       - Returns relative path to file with unique name in Current 
//                Archive Linked Files directory.
//
// Current Archive Linked Files directory wll be created (if not yet). Resulting
// File Name will be unique in Archive Linked Files directory and will be based 
// on AInitialName prefix.
//
function N_ArchDFilesUniqueName( AInitialName: string ): string;
var
  PathToArchFiles: string;
begin
  Result := ''; // Error Flag
  PathToArchFiles := N_ArchDFilesDir();
  if( PathToArchFiles ) = '' then Exit;

  K_ForceDirPath( PathToArchFiles );

  Result := N_CreateUniqueFileName( PathToArchFiles + '\' + AInitialName );
  Result := Copy( Result, Length(PathToArchFiles)+2, 500 );
end; // function N_ArchDFilesUniqueName

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_PlaceTwoSplittedControls
//********************************************** N_PlaceTwoSplittedControls ***
// Place Two given Slitted Controls
//
//     Parameters
// AControl1      - first Control to Place
// AControl2      - second Control to Place
// AParentControl - Parent Control for AControl1, AControl2
// ASplitter      - TSplitter object between AControl1, AControl2
// ASpOrientation - ASplitter Orientation (orHorizontal or orVertical)
// ASplitterCoef  - is equal to Control1.Size / 
//                  (AParentControl.Size-ASplitter.Size)
// ASplitterSize  - Vertical Splitter Width or Horizontal Splitter Height
//
// Place Two given Controls (AControl1, AControl2) in given AParentControl, 
// splitted by given ASplitter
//
// If ASplitter = nil on input, it would be created.
//
procedure N_PlaceTwoSplittedControls( AControl1, AControl2, AParentControl: TWinControl;
                                 var ASplitter: TSPlitter; ASpOrientation: TN_Orientation;
                                 ASplitterCoef: float; ASplitterSize: integer );
begin
  if ASplitter = nil then // Create new Splitter
  begin
    ASplitter := TSplitter.Create( AParentControl.Owner );
    with ASplitter do
    begin
      Beveled  := True;
      AutoSnap := False;
      ResizeStyle := rsUpdate;
    end;
  end; // if ASplitter = nil then // Create new Splitter

//  N_Dump2Str( ' s AParentControl: ' + N_TControlToStr(AParentControl) );
//  N_Dump2Str( ' s Before: AC1     ' + N_TControlToStr(AControl1) + '; AC2 ' + N_TControlToStr(AControl2) );

  if ASpOrientation = orVertical then //***** Vertical Splitter
  begin
    AControl1.Align  := alNone;
    AControl1.Left   := 0;
    AControl1.Top    := 0;
    AControl1.Width  := Round( ASplitterCoef*(AParentControl.Width - ASplitterSize) );
    AControl1.Height := AParentControl.Height;
    AControl1.Align  := alLeft;

    ASplitter.Align := alNone;
    ASplitter.Left  := AControl1.Left + AControl1.Width;
    ASplitter.Width := ASplitterSize;
    ASplitter.Align := alLeft;

    AControl2.Align  := alNone;
    AControl2.Left   := ASplitter.Left + ASplitterSize;
    AControl2.Top    := 0;
    AControl2.Width  := AParentControl.Width - AControl1.Width - ASplitterSize;
    AControl2.Height := AParentControl.Height;
    AControl2.Align  := alClient;
  end else //****************************** Horizontal Splitter
  begin
    AControl1.Align  := alNone;
    AControl1.Left   := 0;
    AControl1.Top    := 0;
    AControl1.Width  := AParentControl.Width;
    AControl1.Height := Round( ASplitterCoef*(AParentControl.Height - ASplitterSize) );
    AControl1.Align  := alTop;

    ASplitter.Align  := alNone;
    ASplitter.Top    := AControl1.Top + AControl1.Height;
    ASplitter.Height := ASplitterSize;
    ASplitter.Align  := alTop;

    AControl2.Align  := alNone;
    AControl2.Left   := 0;
    AControl2.Top    := ASplitter.Top + ASplitter.Height;
    AControl2.Width  := AParentControl.Width;
    AControl2.Height := AParentControl.Height - AControl1.Height - ASplitterSize;
    AControl2.Align  := alClient;
  end; // else // Horizontal Splitter

  //**** make all controls visible

  AParentControl.Visible := True;

  AControl1.Parent  := AParentControl;
  AControl1.Visible := True;

  AControl2.Parent  := AParentControl;
  AControl2.Visible := True;

  ASplitter.Parent  := AParentControl;
  ASplitter.Visible := True;
  N_Dump2Str( ' s After:  AC1     ' + N_TControlToStr(AControl1) + '; AC2 ' + N_TControlToStr(AControl2) );

end; // procedure N_PlaceTwoSplittedControls

//##path N_Delphi\SF\N_Tree\N_Lib2.pas\N_ShowSpeedTestResults
//************************************************** N_ShowSpeedTestResults ***
// show speed test results in N_InfoForm in the following format: LegendText = 
// xx.x units (%acc), units - sec, msec, mcsec, nsec, acc   - time interval 
// accuracy in percents T1,T2  - times in days NTimes - number of repetitions ( 
// Time := (T2 - T1) / NTimes )
//
procedure N_ShowSpeedTestResults( LegendText: string; T1, T2: double;
                                                           NTimes: integer );
begin
  N_GetInfoForm.Show;
  N_InfoForm.Memo.Lines.Add( Format( '%s = %s',
                           [ LegendText, N_TimeToString( T2-T1, NTimes ) ]));
end; // procedure N_ShowSpeedTestResults

//*************************************************************** N_Int2EET ***
// Return TK_ExprExtType from given integer ADTCode
//
function N_Int2EET( ADTCode: integer ): TK_ExprExtType;
//###??? Эта функция нигде не используется кандидат на выкидывание
begin
  Result.All := 0;
  Result.DTCode := ADTCode;
end; // function N_Int2EET

{
Initialization
  N_GlobObj2  := TN_GlobObj2.Create;

  N_ClassRefArray[N_UDLogFontCI] := TN_UDLogFont;
  N_ClassTagArray[N_UDLogFontCI] := 'LogFont';

  N_ClassRefArray[N_UDNFontCI]   := TN_UDNFont;
  N_ClassTagArray[N_UDNFontCI]   := 'NFont';

  N_ClassRefArray[N_UDTextCI]    := TN_UDText;
  N_ClassTagArray[N_UDTextCI]    := 'UDText';

//  N_ClassRefArray[N_UDMemCI]  := TN_UDMem;
//  N_ClassTagArray[N_UDMemCI]  := 'UDMem';

  K_RegRAFrDescription( 'TN_PointAttr1',     'TN_PointAttr1FormDescr' );
  K_RegRAFrDescription( 'TN_PointAttr2',     'TN_PointAttr2FormDescr' );
  K_RegRAFrDescription( 'TN_PA2StrokeShape', 'TN_PA2StrokeShapeFormDescr' );
  K_RegRAFrDescription( 'TN_PA2RoundRect',   'TN_PA2RoundRectFormDescr' );
  K_RegRAFrDescription( 'TN_PA2EllipseFragm', 'TN_PA2EllipseFragmFormDescr' );
  K_RegRAFrDescription( 'TN_PA2RegPolyFragm', 'TN_PA2RegPolyFragmFormDescr' );
  K_RegRAFrDescription( 'TN_PA2TextRow',     'TN_PA2TextRowFormDescr' );
  K_RegRAFrDescription( 'TN_PA2Picture',     'TN_PA2PictureFormDescr' );
  K_RegRAFrDescription( 'TN_PA2Arrow',       'TN_PA2ArrowFormDescr' );
  K_RegRAFrDescription( 'TN_PA2PolyLine',    'TN_PA2PolyLineFormDescr' );

  K_RegRAFrDescription( 'TN_SysLineAttr',    'TN_SysLineAttrFormDescr' );
  K_RegRAFrDescription( 'TN_AuxLine',        'TN_AuxLineFormDescr' );
  K_RegRAFrDescription( 'TN_TimeSeriesUP',   'TN_TimeSeriesUPFormDescr' );
  K_RegRAFrDescription( 'TN_CodeSpaceItem',  'TN_CSItem1FormDescr' );

  K_RegRAInitFunc( 'TN_AuxLine',    N_InitAuxLine );
  K_RegRAInitFunc( 'TN_ExpParams',  N_InitExpParams );
  K_RegRAInitFunc( 'TN_ContAttr',   N_InitContAttr );
  K_RegRAInitFunc( 'TN_NFont',      N_InitNFont );

Finalization
  N_DefContAttr.Free;
  N_GlobObj2.Free;
}

end.
