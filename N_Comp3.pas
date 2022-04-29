unit N_Comp3;
// NonVisual Components set #3:
//   Query1_          Iterator_     Creator_      NonLinConv_
//   DynPictCreator_  CalcUParams_  TextFragm_
//   WordFragm_       ExcelFragm_   BCPattern_    BCPattern_
// Implementation

// TN_CQuery1Flags  = Set Of ( cq1fCreateRatings );
// TN_CQuery1ElemFlags = Set Of ( cq1efCreateRatings );
// TN_CQ1Elem       = packed record // one Query1 Element
// TN_CQuery1       = packed record // Query1 Component Individual Params
// TN_RQuery1       = packed record // TN_UDQuery1 RArray Record type
// TN_UDQuery1      = class( TN_UDCompBase ) // Query1 Component

// TN_CIterator     = packed record // Iterator Component Individual Params
// TN_RIterator     = packed record // TN_UDIterator RArray Record type
// TN_UDIterator    = class( TN_UDCompBase ) // Iterator Component

// TN_CCreator      = packed record // Creator Component Individual Params
// TN_RCreator      = packed record // TN_UDCreator RArray Record type
// TN_UDCreator     = class( TN_UDCompBase ) // Creator Component

// TN_NLCParType    = Set of ( nlcSkip, nlcShift, nlcRotate, ...
// TN_OneNonLinConv = packed record // One Non Linear Convertion Params
// TN_CNonLinConv   = packed record // NonLinConv Component Individual Params
// TN_RNonLinConv   = packed record // TN_UDNonLinConv RArray Record type
// TN_UDNonLinConv  = class( TN_UDCompBase ) // NonLinConv Component

// TN_DynPictCType     = ( dpctByVCTree );
// TN_DynPictCFlags    = SetOf ( dpcfDummy1 );
// TN_CDynPictCreator  = packed record // DynPictCreator Component Individual Params
// TN_RDynPictCreator  = packed record // TN_UDDynPictCreator RArray Record type
// TN_UDDynPictCreator = class( TN_UDCompBase ) // DynPictCreator Component

// TN_CVEFlags     = ( cvefSkip );
// TN_CalcUParamsElem = packed record // one CalcUParams Element
// TN_CCalcUParams    = packed record // CalcUParams Component Individual Params
// TN_RCalcUParams    = packed record // TN_UDCalcUParams RArray Record type
// TN_UDCalcUParams   = class( TN_UDCompBase ) // CalcUParams Component

// TN_CTextFragm  = packed record // TextFragm Component Individual Params
// TN_RTextFragm  = packed record // TN_UDTextFragm RArray Record type
// TN_UDTextFragm = class( TN_UDCompBase ) // TextFragm Component

// TN_WordFragmFlags = Set Of ( wffProcAllDoc, wffExpToCurDoc, wffXMLContent );
// TN_CWordFragm  = packed record // WordFragm Component Individual Params
// TN_RWordFragm  = packed record // TN_UDWordFragm RArray Record type
// TN_UDWordFragm = class( TN_UDCompBase ) // WordFragm Component

// TN_ExcelFragmFlags = Set Of ( wffProcAllDoc, wffExpToCurDoc, wffXMLContent );
// TN_CExcelFragm  = packed record // ExcelFragm Component Individual Params
// TN_RExcelFragm  = packed record // TN_UDExcelFragm RArray Record type
// TN_UDExcelFragm = class( TN_UDCompBase ) // ExcelFragm Component

// TN_CBCPattern  = packed record // BCPattern Component Individual Params
// TN_RBCPattern  = packed record // TN_UDBCPattern RArray Record type
// TN_UDBCPattern = class( TN_UDCompBase ) // BCPattern Component

// TN_WordDoc  = class( TObject ) // MS Word Document (for creating Word docs from Pascal)

interface
uses
     Windows, Graphics, Classes, Contnrs, ZLib, IniFiles,
     K_Script1, K_UDT1, K_FrRAEdit, K_DCSpace, K_SBuf, K_STBuf,
     N_Types, N_Lib0, N_Lib1, N_Lib2, N_Gra0, N_Gra1,
     N_CompCL, N_CompBase, N_GCont;

//***************************  Query1 Component  ************************

type TN_CQuery1Flags = Set of ( cq1fCreateRatings );
type TN_CQuery1ElemFlags = Set of ( cq1efCreateRatings );

type TN_CQ1Elem = packed record // one Query1 Element
  CQEFlags: TN_CQuery1ElemFlags; // Query Element Flags

  CQEBegYear: double;          // Beg Time Interval (Year as double)
  CQEEndYear: double;          // End Time Interval (Year as double)

  CQECSItem: TN_CodeSpaceItem; // Query CodeSpace Item
  CQERatingCSItems: TK_RArray; // Array of CSItems considered in Ratings (ArrayOf TN_CodeSpaceItem)
  CQEQueryCSItems: TK_RArray;  // Array of CSItems in Query (instead of one CQECSItem)

  CQESrcUObj: TN_UDBase;       // Query Source UObject (usually Data Table)
  CQESrcUObjects: TK_RArray;   // Array of Source UObjects (instead of one CQESrcUObj)

  CQEDstComp: TN_UDCompBase;   // Destination Component, where New User Parameter should be created

  CQENumDigits: integer;       // Number of digits after decimal point (Accuracy) for Function values
  CQEUPName:  string;          // User Parameter Name
  CQEUPDescr: string;          // User Parameter Description
end; // type TN_CQ1Elem = packed record // one Query1 Element
type TN_PCQ1Elem = ^TN_CQ1Elem;

type TN_CQuery1 = packed record // Query1 Component Individual Params
  CQFlags: TN_CQuery1Flags; // Query Flags
  CQElems: TK_RArray; // Array of Query Elements (ArrayOf TN_CQ1Elem)

                      // All subsequent fields are used in all Query Elements,
                      // in which this field is not given:
  CQBegYear: double;          // Beg Time Interval (Year as double)
  CQEndYear: double;          // End Time Interval (Year as double)

  CQCSItem: TN_CodeSpaceItem; // Query CodeSpace Item
  CQRatingCSItems: TK_RArray; // Array of CSItems considered in Ratings (ArrayOf TN_CodeSpaceItem)
  CQQueryCSItems: TK_RArray;  // Array of CSItems in Query (instead of one CQCSItem)

  CQSrcUObj: TN_UDBase;       // Query Source UObject (usually Data Table)
  CQSrcUObjects: TK_RArray;   // Array of Source UObjects (instead of one CQESrcUObj)

  CQDstComp: TN_UDCompBase;   // Destination Component, where New User Parameter should be created
end; // type TN_CQuery1 = packed record
type TN_PCQuery1 = ^TN_CQuery1;

type TN_RQuery1 = packed record // TN_UDQuery1 RArray Record type
  CSetParams: TK_RArray;   // Component's SetParams Array
  CCompBase: TN_CCompBase; // Component Base Params
  CQuery1:    TN_CQuery1;  // Component Individual Params
end; // type TN_RQuery1 = packed record
type TN_PRQuery1 = ^TN_RQuery1;

type TN_UDQuery1 = class( TN_UDCompBase ) // Query1_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRQuery1;
  function  PDP  (): TN_PRQuery1;
  function  PISP (): TN_PCQuery1;
  function  PIDP (): TN_PCQuery1;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDQuery1 = class( TN_UDCompBase )


//***************************  Iterator Component  ************************

type  TN_CompIterFlags = Set Of ( cifDummy1 );

type TN_CIterator = packed record // Iterator Component Individual Params
  CIFlags: TN_CompIterFlags; // Self Flags
  CIReserved1: byte;
  CIReserved2: byte;
  CIReserved3: byte;
  CIBegInd:   integer;   // Index of initial iteration
  CINumTimes: integer;   // Number of Iterations, -1 for LastIteration control
  CIIterIndName: string; // Iterator Index Global Name
end; // type TN_CIterator = packed record
type TN_PCIterator = ^TN_CIterator;

type TN_RIterator = packed record // TN_UDIterator RArray Record type
  CSetParams: TK_RArray;   // Component's SetParams Array
  CCompBase: TN_CCompBase; // Component Base Params
  CIterator: TN_CIterator; // Component Individual Params
end; // type TN_RIterator = packed record
type TN_PRIterator = ^TN_RIterator;

type TN_UDIterator = class( TN_UDCompBase ) // Iterator_ Component
    public
  CIInitFlags: TN_CompInitFlags;
  IteratorIndex: integer;
  SavedPrevInd: integer;

  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRIterator;
  function  PDP  (): TN_PRIterator;
  function  PISP (): TN_PCIterator;
  function  PIDP (): TN_PCIterator;
  procedure PascalInit   (); override;
  procedure BeforeAction (); override;
  procedure AfterAction  (); override;
end; // type TN_UDIterator = class( TN_UDCompBase )


//***************************  Creator Component  ************************

type TN_CreatorCompFlags = Set Of ( ccfSkipInit );
//type TN_WhereType = ( wtFirst, wtBefore, wtAfter, wtLast, wtInside );

type TN_CCreator = packed record // Creator Component Individual Params
  CCFlags: TN_CreatorCompFlags; // Self Flags
  CCReserved1: byte;
  CCReserved2: byte;
  CCReserved3: byte;
  CCProcName:    string;    // Pascal Procedure Name to execute (Creator specific code)
  CCPatternUObj: TN_UDBase; // Pattern UObj
  CCResUObjDir:  TN_UDBase; // Resulting UObjects Directory (in which new UObj are created)
  CCIterIndName: string;    // Iterator Index Name
  CCCompWithRef: TN_UDCompBase; // Component with Reference (in User Params) to new UObj
  CCUPRefName:   string;        // User Param Name with Reference to new UObj (in CCCompWithRef)
end; // type TN_CCreator = packed record
type TN_PCCreator = ^TN_CCreator;

type TN_CreatorProc = procedure( APCreator: TN_PCCreator; AP1, AP2: Pointer );

type TN_RCreator = packed record // TN_UDCreator RArray Record type
  CSetParams: TK_RArray;   // Component's SetParams Array
  CCompBase: TN_CCompBase; // Component Base Params
  CCreator:   TN_CCreator; // Component Individual Params
end; // type TN_RCreator = packed record
type TN_PRCreator = ^TN_RCreator;

type TN_UDCreator = class( TN_UDCompBase ) // Creator_ Component
    UDCObj1: TObject;      // RunTime Pascal Object (used in Creator Procedures)
    UDCIterIndex: integer; // Current value of Iterator Index
    UDCLastIter:  boolean; // Current value of LastIteration flag (True for Last Iteration )

  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRCreator;
  function  PDP  (): TN_PRCreator;
  function  PISP (): TN_PCCreator;
  function  PIDP (): TN_PCCreator;
  procedure PascalInit    (); override;
  procedure InitRunTimeFields ( AInitFlags: TN_CompInitFlags ); override;
  procedure BeforeAction  (); override;
  function  CreateNewUObj (): TN_UDBase;
end; // type TN_UDCreator = class( TN_UDCompBase )


//***************************  NonLinConv Component  ************************

type TN_NLCParType = Set of ( nlctSkip, nlctRotate,
                              nlctRScale, nlctXYScale, nlctShift );

type TN_OneNonLinConv = packed record // One Non Linear Convertion Params
  NLCParType: TN_NLCParType; // NLC Params Type
  NLCReserved1:   byte; // for alignment
  NLCReserved2:   byte; // for alignment
  NLCReserved3:   byte; // for alignment
                        // ***** percents -> percents convertion is assumed:
  NLCFixedPoint: TFPoint; // Convertion Fixed Point (for Rotate, RScale, and XYScale)
  NLCShift:    TFPoint;   // Convertion Shift
  NLCAngle:      float;   // Convertion Rotation Angle (in degree, counterclockwise)
  NLCScale:    TFPoint;   // Convertion (X,Y) Scale Coefs (1.0 - no change)

  NLCElCenter: TFPoint; // both Ellipses Center in OCanv.CurCRect percents
  NLCR1:       TFPoint; // small Ellipse Radiuses in OCanv.CurCRect percents
  NLCR2:       TFPoint; // big Ellipse Radiuses in OCanv.CurCRect percents
  NLCSmoothPar:  float; // Smooth Param
end; // type TN_OneNonLinConv = packed record
type TN_POneNonLinConv = ^TN_OneNonLinConv;

type TN_CNonLinConv = packed record // NonLinConv Component Individual Params
  NLCSrcCObjDir: TN_UDBase;   // UDBase Dir with All Source CObjects
  NLCDstCObjDir: TN_UDBase;   // UDBase Dir with Destination CObjects (with same Names)
  NLCMapLayerComp: TN_UDBase; // Map Layer Component with needed User Coords
  NLCConvs:      TK_RArray;   // RArray of Conversions (of TN_OneNonLinConv elements)
end; // type TN_CNonLinConv = packed record
type TN_PCNonLinConv = ^TN_CNonLinConv;

type TN_RNonLinConv = packed record // TN_UDNonLinConv RArray Record type
  CSetParams:  TK_RArray;      // Component's SetParams Array
  CCompBase:   TN_CCompBase;   // Component Base Params
  CNonLinConv: TN_CNonLinConv; // Component Individual Params
end; // type TN_RNonLinConv = packed record
type TN_PRNonLinConv = ^TN_RNonLinConv;

type TN_UDNonLinConv = class( TN_UDCompBase ) // NonLinConv_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRNonLinConv;
  function  PDP  (): TN_PRNonLinConv;
  function  PISP (): TN_PCNonLinConv;
  function  PIDP (): TN_PCNonLinConv;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDNonLinConv = class( TN_UDCompBase )


//*************************  DynPictCreator Component  ***********************

type TN_DynPictCType  = ( dpctDefault );
type TN_DynPictCFlags = Set of ( dpcfRandTestColors, dpcfShowStatPict,
                                 dpcfGivenDynPict,   dpcfDebJSOutput );
// dpcfRandTestColors - use Random Colors in final drawing created Rect,
//                      otherwise - use linear Colors (mainly
// dpcfShowStatPict   - over created Rects (filled by Test Colors) show created Static Picture (mainly for debug)
// dpcfGivenDynPict   - get intermediate 8bit raster from given File (not implemented)
// dpcfDebJSOutput    - add to protocol deb strings

type TN_CDynPictCreator = packed record // DynPictCreator Component Individual Params
  DPCType:  TN_DynPictCType;  // Dyn Pict Creation Type (not used now)
  DPCFlags: TN_DynPictCFlags; // Dyn Pict Creation Flags
  DPCReserved1:   byte; // for alignment
  DPCReserved2:   byte; // for alignment
  DPCColorsUDV: TK_UDVector;  // Colors UDVector (for dynamic pixels identification)
  DPCSrcVCTree: TN_UDCompVis; // Source VCTree
  DPCStaticColors: TK_RArray; // RArray of Static Colors (converted to DPCNAZColor with Ind=254)

  DPCSourcePictFN:   string;  // Source Picture File Name
  DPC8BitDynPictFN:  string;  // 8-bit Dynamic Pixels Picture GIF or BMP File Name
  DPC8BitStatPictFN: string;  // 8-bit Static Pixels Picture GIF File Name (Dynamic Pixels are transparent)
  DPCResJSCodeFN:    string;  // Resulting JavaScript (with Rect coords) code with comments TXT File Name

  DPCTestMinColor:  integer;  // Minimal Test Color (for debug resulting rects drawing)
  DPCTestMaxColor:  integer;  // Miximal Test Color (for debug resulting rects drawing)
  DPCRectsBackColor: integer; // Background Color (for debug resulting rects drawing)

  DPCSpecMinColor:  integer;  // Minimal Special Color (for dynamic pixels identification)
  DPCSpecMaxColor:  integer;  // Maximal Special Color (for dynamic pixels identification)
  DPCSrcTranspColor: integer; // Transparent Color in Source Raster (any Color not used in Source Raster)

  DPCAZColor:  integer; // Active Zone Color in 8-bit Dynamic Pixels Picture (with Ind=255)
  DPCNAZColor: integer; // Not Active Zone Color in 8-bit Dynamic Pixels Picture (with Ind=254)
                        // DPCAZColor and DPCNAZColor should not be in range ($000 - $0FD),
                        // because of using blue palette ($000 - $0FD) for Dynamic Pixels
end; // type TN_CDynPictCreator = packed record
type TN_PCDynPictCreator = ^TN_CDynPictCreator;

type TN_RDynPictCreator = packed record // TN_UDDynPictCreator RArray Record type
  CSetParams:      TK_RArray;          // Component's SetParams Array
  CCompBase:       TN_CCompBase;       // Component Base Params
  CDynPictCreator: TN_CDynPictCreator; // Component Individual Params
end; // type TN_RDynPictCreator = packed record
type TN_PRDynPictCreator = ^TN_RDynPictCreator;

type TN_UDDynPictCreator = class( TN_UDCompBase ) // DynPictCreator_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRDynPictCreator;
  function  PDP  (): TN_PRDynPictCreator;
  function  PISP (): TN_PCDynPictCreator;
  function  PIDP (): TN_PCDynPictCreator;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDDynPictCreator = class( TN_UDCompBase )


//***************************  CalcUParams Component  ************************

type TN_CVEFlags = Set of ( cvefSkip );

type TN_CalcUParamsElem = packed record // one CalcUParams Element
  CVEFlags: TN_CVEFlags; // Element Flags
  CVEReserved1: byte;
  CVEReserved2: byte;
  CVEReserved3: byte;
  CVEDescr: string;      // Element Description (used as a comment)
  CVESPLProc: string;    // SPL Procedure Code
end; // type TN_CalcUParamsElem = packed record
type TN_PCalcUParamsElem = ^TN_CalcUParamsElem;

type TN_CCalcUParams = packed record // CalcUParams Component Individual Params
  CVElems: TK_RArray; // ArrayOf TN_CalcUParamsElem
end; // type TN_CCalcUParams = packed record
type TN_PCCalcUParams = ^TN_CCalcUParams;

type TN_RCalcUParams = packed record // TN_UDCalcUParams RArray Record type
  CSetParams:   TK_RArray;       // Component's SetParams Array
  CCompBase:    TN_CCompBase;    // Component Base Params
  CCalcUParams: TN_CCalcUParams; // Component Individual Params
end; // type TN_RCalcUParams = packed record
type TN_PRCalcUParams = ^TN_RCalcUParams;

type TN_UDCalcUParams = class( TN_UDCompBase ) // CalcUParams_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRCalcUParams;
  function  PDP  (): TN_PRCalcUParams;
  function  PISP (): TN_PCCalcUParams;
  function  PIDP (): TN_PCCalcUParams;
  procedure PascalInit   (); override;
  procedure BeforeAction (); override;
end; // type TN_UDCalcUParams = class( TN_UDCompBase )


//***************************  TextFragm Component  ************************

type TN_CTextFragm = packed record // TextFragm Component Individual Params
  TFStyle:  string; // String to Add To Style Section (HTML or SVG Style)
  TFBefore: string; // String to Add to Body Section Before Children
  TFAfter:  string; // String to Add to Body Section After Children
end; // type TN_CTextFragm = packed record
type TN_PCTextFragm = ^TN_CTextFragm;

type TN_RTextFragm = packed record // TN_UDTextFragm RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CTextFragm: TN_CTextFragm; // Component Individual Params
end; // type TN_RTextFragm = packed record
type TN_PRTextFragm = ^TN_RTextFragm;

type TN_UDTextFragm = class( TN_UDCompBase ) // TextFragm_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRTextFragm;
  function  PDP  (): TN_PRTextFragm;
  function  PISP (): TN_PCTextFragm;
  function  PIDP (): TN_PCTextFragm;
  procedure PascalInit (); override;
  procedure PrepMacroPointers (); override;
  procedure BeforeAction (); override;
  procedure AfterAction  (); override;
end; // type TN_UDTextFragm = class( TN_UDCompBase )


//***************************  WordFragm Component  ************************

type TN_WordFragmFlags = Set Of ( wffProcAllDoc, wffExpToCurDoc, wffXMLContent,
                                  wffSkipAutoCopy, wffNewSection, wffSkipTOC,
                                  wffRemoveBookmarks, wffExpandTables,
                                  wffSkipSPLMacros, wffSkipVarMacros, wffDeb1 );
// wffProcAllDoc   - Process macros in All GCMainDoc (instead of processing only Self fragment)
// wffExpToCurDoc  - Export to Insertion Point of Currently Active Document
// wffXMLContent   - WFDocData are in XML format (file should have .xml extension)
// wffSkipAutoCopy - Skip Copy SelfDoc in Clipboard in InsertSelfDoc local method
//                   (used if Clipboard is set in document Macros)
// wffNewSection   - Insert SelfDoc as new Section with possible Header and Footer
// wffSkipTOC      - Skip Updating TOCs (Tables Of Contents)
// wffRemoveBookmarks - Remove Bookmarks after creation
// wffExpandTables  - Expand Word Tables
// wffSkipSPLMacros - Skip processing SPL Macros in Word Document
// wffSkipVarMacros - Skip processing one Variable macros in (#...#) brackets
// wffDeb1          - Debug Flag 1

type TN_CWordFragm = packed record // WordFragm Component Individual Params
  WFFlags: TN_WordFragmFlags; // Flags (two bytes)
  WFReserved1: byte;
  WFReserved2: byte;
  WFDocFName:    string;  // Word Document File Name
  WFBmGCVarName: string;  // GCVarName with Bookmark Name, used in InsertSelfDoc local method
  WFDocData:   TK_RArray; // Word Document binary content (RArray of byte)
end; // type TN_CWordFragm = packed record
type TN_PCWordFragm = ^TN_CWordFragm;

type TN_RWordFragm = packed record // TN_UDWordFragm RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CWordFragm: TN_CWordFragm; // Component Individual Params
end; // type TN_RWordFragm = packed record
type TN_PRWordFragm = ^TN_RWordFragm;

type TN_UDWordFragm = class( TN_UDCompBase ) // WordFragm_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRWordFragm;
  function  PDP  (): TN_PRWordFragm;
  function  PISP (): TN_PCWordFragm;
  function  PIDP (): TN_PCWordFragm;
  procedure PascalInit    (); override;
  procedure BeforeAction  (); override;
//  procedure ProcessMacros ( ADoc: Variant );
end; // type TN_UDWordFragm = class( TN_UDCompBase )


//***************************  ExcelFragm Component  ************************

type TN_ExcelFragmFlags = Set Of ( effXMLContent );
// effXMLContent    - EFDocData are in XML format (file should have .xml extension)

type TN_CExcelFragm = packed record // ExcelFragm Component Individual Params
  EFFlags: TN_ExcelFragmFlags; // Flags
  EFReserved1: byte;
  EFReserved2: byte;
  EFReserved3: byte;
  EFDocFName:  string;        // Excel Document File Name
  EFDocData:   TK_RArray;     // Excel Document binary content (RArray of byte)
end; // type TN_CExcelFragm = packed record
type TN_PCExcelFragm = ^TN_CExcelFragm;

type TN_RExcelFragm = packed record // TN_UDExcelFragm RArray Record type
  CSetParams:  TK_RArray;      // Component's SetParams Array
  CCompBase:   TN_CCompBase;   // Component Base Params
  CExcelFragm: TN_CExcelFragm; // Component Individual Params
end; // type TN_RExcelFragm = packed record
type TN_PRExcelFragm = ^TN_RExcelFragm;

type TN_UDExcelFragm = class( TN_UDCompBase ) // ExcelFragm_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRExcelFragm;
  function  PDP  (): TN_PRExcelFragm;
  function  PISP (): TN_PCExcelFragm;
  function  PIDP (): TN_PCExcelFragm;
  procedure PascalInit   (); override;
  procedure BeforeAction (); override;
end; // type TN_UDExcelFragm = class( TN_UDCompBase )


{ // ********* Base Component Pattern (see also in Implementation section)

      for Constructing New Component you need:
- copy this pattern (below) to interface section
- copy implementation pattern to implementation section
- copy Class registration Pattern (last lines in this file)
- copy comments lines in beg file (in interface section)
- add new N_xxxCI definition to N_ClassRef
- replace "BCPattern" by "xxx" (needed Component Name) in four file fragments
- compile to check errors

- realise new Component (type and methods)
- add new types to comments in file header if needed
- add TN_CBCPattern and additional type (is any) to Comps.spl
- add FormDescr for TN_CBCPattern in N_FormDescrSPL

- add code for new Component to N_NewObjF
- add code for new Component to N_RaEditF (in aCompIndParamsExecute)
- add new Icon in Icons_Tree.bmp and reload ButtonsForm.IconsList

//***************  BCPattern (Base Component Pattern)  ************************

// TN_CBCPattern = packed record // BCPattern Component Individual Params
// TN_RBCPattern = packed record // TN_UDBCPattern RArray Record type
// TN_UDBCPattern = class( TN_UDCompBase ) // BCPattern Component

type TN_CBCPattern = packed record // BCPattern Component Individual Params

end; // type TN_CBCPattern = packed record
type TN_PCBCPattern = ^TN_CBCPattern;

type TN_RBCPattern = packed record // TN_UDBCPattern RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase: TN_CCompBase;   // Component Base Params
  CBCPattern: TN_CBCPattern; // Component Individual Params
end; // type TN_RBCPattern = packed record
type TN_PRBCPattern = ^TN_RBCPattern;

type TN_UDBCPattern = class( TN_UDCompBase ) // BCPattern_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRBCPattern;
  function  PDP  (): TN_PRBCPattern;
  function  PISP (): TN_PCBCPattern;
  function  PIDP (): TN_PCBCPattern;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDBCPattern = class( TN_UDCompBase )
} //******************* End of Base Component Pattern

type TN_WordDoc = class( TObject ) // MS Word Document (for creating Word docs from Pascal)
  WDGCont: TN_GlobCont; // Creating Global Context

  constructor Create;
  destructor  Destroy; override;
  procedure StartCreating  ( ARootComp: TN_UDBase; APExpParams: TN_PExpParams ); overload;
  procedure StartCreating  ( ARootComp: TN_UDBase; AFName: string;
                                                AEPExecFlags : TN_EPExecFlags ); overload;
  procedure AddComponent   ( AComp: TN_UDBase );
  procedure FinishCreating ( );
end; // type TN_WordDoc = class( TObject )

//****************** Global procedures **********************

procedure N_RegCreatorProc ( AProcName: string; AnCreatorProc: TN_CreatorProc );

procedure N_CreatorJustCreate ( APParams: TN_PCCreator; AP1, AP2: Pointer );
procedure N_SetIteratorData ( AIterIndName: string; AIterIndex: integer;
                                                        ALastIteration: boolean );
procedure N_GetIteratorData ( AIterIndName: string; out AIterIndex: integer;
                                                    out ALastIteration: boolean );
procedure N_GetMVTASPLVectors ( ASPLUnitName: string; AVectorsNames: TN_SArray;
                                      AResSL: TStringList; out AVSize: integer );
procedure N_CrCreateLinHist_2Page( APParams: TN_PCCreator; AP1, AP2: Pointer );

//******************** Global Objects ******************************

var
  N_CreatorProcs: THashedStringList;


implementation
uses Math, SysUtils, Variants, ComObj, Clipbrd, StrUtils,
//     Excel_TLB,
//     Word_TLB,
     K_UDConst, K_CLib0, K_Types, K_MVQR, K_UDT2, K_IWatch,
     N_ClassRef, N_Gra2, N_ME1, N_RaEditF, N_UDat4, N_RVCTF,
     N_Comp1, N_Rast1Fr, N_InfoF, N_Deb1;


//********** TN_UDQuery1 class methods  **************

//********************************************** TN_UDQuery1.Create ***
//
constructor TN_UDQuery1.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDQuery1CI;
  ImgInd := 82;
end; // end_of constructor TN_UDQuery1.Create

//********************************************* TN_UDQuery1.Destroy ***
//
destructor TN_UDQuery1.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDQuery1.Destroy

//********************************************** TN_UDQuery1.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDQuery1.PSP(): TN_PRQuery1;
begin
  Result := TN_PRQuery1(R.P());
end; // end_of function TN_UDQuery1.PSP

//********************************************** TN_UDQuery1.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDQuery1.PDP(): TN_PRQuery1;
begin
  if DynPar <> nil then Result := TN_PRQuery1(DynPar.P())
                   else Result := TN_PRQuery1(R.P());
end; // end_of function TN_UDQuery1.PDP

//******************************************* TN_UDQuery1.PISP ***
// return typed pointer to Individual Static Query1 Params
//
function TN_UDQuery1.PISP(): TN_PCQuery1;
begin
  Result := @(TN_PRQuery1(R.P())^.CQuery1);
end; // function TN_UDQuery1.PISP

//******************************************* TN_UDQuery1.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic Query1 Params
// otherwise return typed pointer to Individual Static Query1 Params
//
function TN_UDQuery1.PIDP(): TN_PCQuery1;
begin
  if DynPar <> nil then
    Result := @(TN_PRQuery1(DynPar.P())^.CQuery1)
  else
    Result := @(TN_PRQuery1(R.P())^.CQuery1);
end; // function TN_UDQuery1.PIDP

//********************************************** TN_UDQuery1.PascalInit ***
// Init self
//
procedure TN_UDQuery1.PascalInit();
begin
  Inherited;
{
var
  PRCompS: TN_PRQuery1;
begin
  PRCompS := PSP();
  with PRCompS^, PRCompS^.CQuery1 do
  begin

  end;
}
end; // procedure TN_UDQuery1.PascalInit

//************************************** TN_UDQuery1.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDQuery1.BeforeAction();
var
  i, CSInd: integer;
  PRCompD: TN_PRQuery1;
  MVQ: TK_MVQRVectors;
  DstComp: TN_UDCompBase;
  CQ: TN_CQ1Elem;
  PTimeSeries: TN_PTimeSeriesUP;

  procedure FillTimeSeries(); // local
  // Fill PTimeSeries^ fields
  begin
    with MVQ, PTimeSeries^ do
    begin
      TSArgValues := K_RCreateByTypeName( 'Double', QVNum );
      GetVETStamps( TSArgValues.P() );

      TSFuncValues := K_RCreateByTypeName( 'Double', QVNum );
      GetVEValues( TSFuncValues.P() );

      if (cq1efCreateRatings in CQ.CQEFlags) or
         (cq1fCreateRatings  in PRCompD^.CQuery1.CQFlags) then // Create Ratings
      begin
        TSRatings := K_RCreateByTypeName( 'Double', QVNum );
        GetVERatings( TSRatings.P() );
      end;

      TSNumDigits := CQ.CQENumDigits;
      TSVectorKey := GetIndicatorKey();
      CQ.CQECSItem.ItemCS.GetItemsInfo( @TSItemKey, K_csiSclonKey, CSInd );
    end; // with MVQ, PTimeSeries^ do
  end; // procedure FillTimeSeries(); // local

  procedure DoQueryElement(); //  - local
  // Create one User Param in DstComp as Query result
  var
    PUserParam: TN_POneUserParam;
    UPVal: TK_RArray;
  begin
    PUserParam := nil;
//    PUserParam := N_CGetUserParPtr( DstComp.DynPar, CQ.CQEUPName, CQ.CQEUPDescr,
//                                                        'TN_TimeSeriesUP', 1 );
    UPVal := PUserParam^.UPValue;

    with MVQ do
    begin

    Clear;
    SetQRMode( K_mrmActVals );

    if CQ.CQEQueryCSItems <> nil then // Create TimeSeries Vector
    begin                            // by given CStems and CQESrcUObj
      Assert( False, 'Not yet!' );
    end else if CQ.CQESrcUObjects <> nil then // Create TimeSeries Vector
    begin                                     // by given CQESrcUObjects and CQECSCode
      Assert( False, 'Not yet!' );
    end else // create One TimeSeries by CQECSCode and CQESrcUObj
    begin
      N_d1 := EncodeDate( 2001, 1, 1); // debug
      N_d2 := EncodeDate( 2002, 1, 1); // debug
      AddVectors( [], CQ.CQESrcUObj, '',
                              EncodeDate( Round(CQ.CQEBegYear), 1, 1 ),
                              EncodeDate( Round(CQ.CQEEndYear), 1, 1 ), False );
      SetQCS( CQ.CQECSItem.ItemCS );
      CSInd := CQ.CQECSItem.ItemCS.IndexByCode( CQ.CQECSItem.ItemCode );
      SetCurElem( CSInd );

      UPVal.ASetLength( 1 );
      PTimeSeries := TN_PTimeSeriesUP(UPVal.P);
      FillTimeSeries();
    end; // else - create One TimeSeries by CQECSCode and CQESrcUObj

    end; // with MVQ do

  end; // procedure DoQueryElement() - local

begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;
//  Exit; // debug

  MVQ := TK_MVQRVectors.Create();

  PRCompD := PDP();
  with MVQ, PRCompD^, PRCompD^.CQuery1 do
  begin

  DstComp := CQDstComp;
  if DstComp = nil then DstComp := Self;
  N_p := @DstComp; // to avoid warning

  for i := 0 to CQElems.AHigh() do // loop along all query elements
  begin
  //********** Prepare Query fields in CQ (Current Query)

  CQ := TN_PCQ1Elem(CQElems.P(i))^;

  if CQ.CQEBegYear = 0  then CQ.CQEBegYear := CQBegYear;
  if CQ.CQEEndYear = 0  then CQ.CQEEndYear := CQEndYear;
  if CQ.CQECSItem.ItemCS = nil then CQ.CQECSItem := CQCSItem;

  if CQ.CQERatingCSItems = nil then CQ.CQERatingCSItems := CQRatingCSItems;
  if CQ.CQEQueryCSItems  = nil then CQ.CQEQueryCSItems := CQQueryCSItems;
  if CQ.CQESrcUObj     = nil then CQ.CQESrcUObj := CQSrcUObj;
  if CQ.CQESrcUObjects = nil then CQ.CQESrcUObjects := CQSrcUObjects;
  if CQ.CQEDstComp     = nil then CQ.CQEDstComp := CQDstComp;

  DoQueryElement();
  end; // for i := 0 to CQElems.AHigh() do // loop along all query elements

  end; // MVQ, PRCompD^, PRCompD^.CQuery1 do
  MVQ.Free;
end; // end_of procedure TN_UDQuery1.BeforeAction


//********** TN_UDIterator class methods  **************

//********************************************** TN_UDIterator.Create ***
//
constructor TN_UDIterator.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDIteratorCI;
  ImgInd := 84;
end; // end_of constructor TN_UDIterator.Create

//********************************************* TN_UDIterator.Destroy ***
//
destructor TN_UDIterator.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDIterator.Destroy

//********************************************** TN_UDIterator.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDIterator.PSP(): TN_PRIterator;
begin
  Result := TN_PRIterator(R.P());
end; // end_of function TN_UDIterator.PSP

//********************************************** TN_UDIterator.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDIterator.PDP(): TN_PRIterator;
begin
  if DynPar <> nil then Result := TN_PRIterator(DynPar.P())
                   else Result := TN_PRIterator(R.P());
end; // end_of function TN_UDIterator.PDP

//******************************************* TN_UDIterator.PISP ***
// return typed pointer to Individual Static Iterator Params
//
function TN_UDIterator.PISP(): TN_PCIterator;
begin
  Result := @(TN_PRIterator(R.P())^.CIterator);
end; // function TN_UDIterator.PISP

//******************************************* TN_UDIterator.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic Iterator Params
// otherwise return typed pointer to Individual Static Iterator Params
//
function TN_UDIterator.PIDP(): TN_PCIterator;
begin
  if DynPar <> nil then
    Result := @(TN_PRIterator(DynPar.P())^.CIterator)
  else
    Result := @(TN_PRIterator(R.P())^.CIterator);
end; // function TN_UDIterator.PIDP

//********************************************** TN_UDIterator.PascalInit ***
// Init self
//
procedure TN_UDIterator.PascalInit();
begin
  Inherited;

  with PISP()^ do
  begin
    CINumTimes := 1;
    CIIterIndName := '???';
  end;
end; // procedure TN_UDIterator.PascalInit

//************************************** TN_UDIterator.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDIterator.BeforeAction();
var
  CurIndex: integer;
  LastIteration: boolean;
  NextChild: TN_UDCompBase;
  PRCompD: TN_PRIterator;
begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;
  PRCompD := PDP();

  with PRCompD^, PRCompD^.CIterator do
  begin
    if CINumTimes = 0 then Exit;

  CurIndex := 0;

  while True do // Execute Self Children loop
  begin
    LastIteration := (CINumTimes >= 0) and (CurIndex >= (CINumTimes-1));
    N_SetIteratorData( CIIterIndName, CurIndex, LastIteration );

    //********************** Init children (is always needed or not?)
    Self.CurChildInd := -1;
    while True do // loop along all Children
    begin
      NextChild := GetNextChild();
      if NextChild = nil then System.Break; // Break conflicts with Word_TLB!
      NextChild.InitSubTree( [] );
    end;

    //********************** Execute children
    Self.CurChildInd := -1;
    while True do // loop along all Children
    begin
      NextChild := GetNextChild();
      if NextChild = nil then System.Break; // Break conflicts with Word_TLB!
      NextChild.DynParent := Self;
      NextChild.NGCont:= Self.NGCont;
      NextChild.ExecSubTree();
      if NGCont.StopExecFlag then Exit;
    end;

    //********************** Fin children
    Self.CurChildInd := -1;
    while True do // loop along all Children
    begin
      NextChild := GetNextChild();
      if NextChild = nil then System.Break; // Break conflicts with Word_TLB!
      NextChild.FinSubTree();
    end;

    N_GetIteratorData( CIIterIndName, N_i, LastIteration );
    if LastIteration then System.Break; // Break conflicts with Word_TLB!

    Inc( CurIndex );
  end; // while True do // Execute Self Children loop
  end; // PRCompD^, PRCompD^.CIterator do

end; // end_of procedure TN_UDIterator.BeforeAction

//************************************** TN_UDIterator.AfterAction ***
// Component method which will be called After children execution
//
procedure TN_UDIterator.AfterAction();
var
  i: integer;
  NextChild: TN_UDCompBase;
  PRCompD: TN_PRIterator;
  PCCompBase: TN_PCCompBase;
  Label Fin;
begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  PCCompBase := @(PRCompD^.CCompBase);

  with PRCompD^, PRCompD^.CIterator, NGCont.SPLMCont do
  begin

  for i := 1 to CINumTimes-1 do // iterate children
  begin
    //********************** Fin children
    CurChildInd := -1;
    while True do // loop along all Children
    begin
      NextChild := GetNextChild();
      if NextChild = nil then System.Break; // Break conflicts with Word_TLB!
      NextChild.FinSubTree();
    end;

    //********************** Init children
    CurChildInd := -1;
    while True do // loop along all Children
    begin
      NextChild := GetNextChild();
      if NextChild = nil then System.Break; // Break conflicts with Word_TLB!
      NextChild.InitSubTree( [] );
    end;

    IteratorIndex := i;
    LastInd := i;
    UpdateBySPLMCont();

    ExecSetParams( sppBBAction );
    if PCCompBase^.CBSkipSelf <> 0 then goto Fin; // Skip Self with all children

    //********************** Execute children
    CurChildInd := -1;
    while True do // loop along all Children
    begin
      NextChild := GetNextChild();
      if NextChild = nil then System.Break; // Break conflicts with Word_TLB!

//      if (N_VisCompObjBit and NextChild.ClassFlags) = N_VisCompObjBit then
//       Continue; // Skip executing Visual Components with  Nonvisual DynParent

      NextChild.DynParent := Self;
      NextChild.NGCont:= Self.NGCont;
      NextChild.ExecSubTree();
      if NGCont.StopExecFlag then goto Fin;
    end;

    ExecSetParams( sppBAAction );

  end; // for i := 1 to CINumItems-1 do // iterate children

  Fin: //********************** Restor PrevInd and LastInd

  PrevInd := SavedPrevInd;
  LastInd := PrevInd;

  end; // PRCompD^, PRCompD^.CIterator do
end; // end_of procedure TN_UDIterator.AfterAction


//********** TN_UDCreator class methods  **************

//********************************************** TN_UDCreator.Create ***
//
constructor TN_UDCreator.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDCreatorCI;
  ImgInd := 85;
end; // end_of constructor TN_UDCreator.Create

//********************************************* TN_UDCreator.Destroy ***
//
destructor TN_UDCreator.Destroy;
begin
  UDCObj1.Free;
  inherited Destroy;
end; // end_of destructor TN_UDCreator.Destroy

//********************************************** TN_UDCreator.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDCreator.PSP(): TN_PRCreator;
begin
  Result := TN_PRCreator(R.P());
end; // end_of function TN_UDCreator.PSP

//********************************************** TN_UDCreator.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDCreator.PDP(): TN_PRCreator;
begin
  if DynPar <> nil then Result := TN_PRCreator(DynPar.P())
                   else Result := TN_PRCreator(R.P());
end; // end_of function TN_UDCreator.PDP

//******************************************* TN_UDCreator.PISP ***
// return typed pointer to Individual Static Creator Params
//
function TN_UDCreator.PISP(): TN_PCCreator;
begin
  Result := @(TN_PRCreator(R.P())^.CCreator);
end; // function TN_UDCreator.PISP

//******************************************* TN_UDCreator.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic Creator Params
// otherwise return typed pointer to Individual Static Creator Params
//
function TN_UDCreator.PIDP(): TN_PCCreator;
begin
  if DynPar <> nil then
    Result := @(TN_PRCreator(DynPar.P())^.CCreator)
  else
    Result := @(TN_PRCreator(R.P())^.CCreator);
end; // function TN_UDCreator.PIDP

//********************************************** TN_UDCreator.PascalInit ***
// Init self
//
procedure TN_UDCreator.PascalInit();
begin
  Inherited;
{
var
  PRCompS: TN_PRCreator;

  PRCompS := PSP();
  with PRCompS^, PRCompS^.CCreator do
  begin

  end;
}
end; // procedure TN_UDCreator.PascalInit

//****************************************** TN_UDCreator.InitRunTimeFields ***
// Clear all Self RunTime fields
// ( Font Handels, ReInd Vectors, 2DSpace.Coefs6, Pascal Objects and so on )
//
procedure TN_UDCreator.InitRunTimeFields( AInitFlags: TN_CompInitFlags );
begin
  inherited;
  
  FreeAndNil( UDCObj1 );
end; // end_of procedure TN_UDCreator.InitRunTimeFields

//************************************** TN_UDCreator.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDCreator.BeforeAction();
var
  ProcInd: Integer;
  PRCompD: TN_PRCreator;
begin
  PRCompD := PDP();
  with PRCompD^, PRCompD^.CCreator do
  begin
    //***** Set UDCIterIndex (set -1 if not exists) and UDCLastIter (False if not exists)
    N_GetIteratorData( CCIterIndName, UDCIterIndex, UDCLastIter );

    ProcInd := -1;

    if N_CreatorProcs <> nil then
      ProcInd := N_CreatorProcs.IndexOfName( CCProcName );

    if ProcInd <> -1 then
      TN_CreatorProc(N_CreatorProcs.Objects[ProcInd])( @PRCompD^.CCreator, @Self, nil )
    else
      if CCProcName <> '' then
        N_CurShowStr( 'Creator Procedure Not Found: ' + CCProcName );

  end; // PRCompD^, PRCompD^.CCreator do
end; // end_of procedure TN_UDCreator.BeforeAction

//********************************************** TN_UDCreator.CreateNewUObj ***
// Create New UObj using Self Params
//
function TN_UDCreator.CreateNewUObj(): TN_UDBase;
var
  NewUObj: TN_UDBase;
begin
  Result := nil;

  with PDP()^.CCreator do
  begin
    if CCPatternUObj   = nil then Exit; // No Pattern UObj
    if CCResUObjDir = nil then Exit; // a precaution

    CCResUObjDir.ClearChilds( 0 ); // delete All Children

    NewUObj := N_CreateSubTreeClone( CCPatternUObj );
    NewUObj.ClassFlags := NewUObj.ClassFlags or K_SkipSelfSaveBit;

    CCResUObjDir.AddOneChildV( NewUObj );

    if CCCompWithRef <> nil then // Set Ref to NewUObj in UserParam in CCCompWithRef
      CCCompWithRef.SetDUserParUDBase( CCUPRefName, NewUObj );

  end; // with PDP()^.CCreator do

end; // function TN_UDCreator.CreateNewUObj


//*********************** TN_UDNonLinConv class methods  *********************

//********************************************** TN_UDNonLinConv.Create ***
//
constructor TN_UDNonLinConv.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDNonLinConvCI;
  ImgInd := 81;
end; // end_of constructor TN_UDNonLinConv.Create

//********************************************* TN_UDNonLinConv.Destroy ***
//
destructor TN_UDNonLinConv.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDNonLinConv.Destroy

//********************************************** TN_UDNonLinConv.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDNonLinConv.PSP(): TN_PRNonLinConv;
begin
  Result := TN_PRNonLinConv(R.P());
end; // end_of function TN_UDNonLinConv.PSP

//********************************************** TN_UDNonLinConv.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDNonLinConv.PDP(): TN_PRNonLinConv;
begin
  if DynPar <> nil then Result := TN_PRNonLinConv(DynPar.P())
                   else Result := TN_PRNonLinConv(R.P());
end; // end_of function TN_UDNonLinConv.PDP

//******************************************* TN_UDNonLinConv.PISP ***
// return typed pointer to Individual Static NonLinConv Params
//
function TN_UDNonLinConv.PISP(): TN_PCNonLinConv;
begin
  Result := @(TN_PRNonLinConv(R.P())^.CNonLinConv);
end; // function TN_UDNonLinConv.PISP

//******************************************* TN_UDNonLinConv.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic NonLinConv Params
// otherwise return typed pointer to Individual Static NonLinConv Params
//
function TN_UDNonLinConv.PIDP(): TN_PCNonLinConv;
begin
  if DynPar <> nil then
    Result := @(TN_PRNonLinConv(DynPar.P())^.CNonLinConv)
  else
    Result := @(TN_PRNonLinConv(R.P())^.CNonLinConv);
end; // function TN_UDNonLinConv.PIDP

//********************************************** TN_UDNonLinConv.PascalInit ***
// Init self
//
procedure TN_UDNonLinConv.PascalInit();
var
  PRCompS: TN_PRNonLinConv;
begin
  Inherited;
  PRCompS := PSP();
  with PRCompS^, PRCompS^.CNonLinConv do
  begin
    NLCConvs := K_RCreateByTypeName( 'TN_OneNonLinConv', 1 );
    with TN_POneNonLinConv(NLCConvs.P(0))^ do
    begin
      NLCParType := [nlctShift];
      NLCFixedPoint := FPoint( 50, 50 );
      NLCScale   := FPoint( 1, 1 );
      NLCR1      := FPoint( 30, 30 );
      NLCR2      := FPoint( 70, 70 );
      NLCSmoothPar := 1.0;
    end; // with TN_POneNonLinConv(NLCConvs.P(0))^ do
  end; // with PRCompS^, PRCompS^.CNonLinConv do
end; // procedure TN_UDNonLinConv.PascalInit

//************************************** TN_UDNonLinConv.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDNonLinConv.BeforeAction();
var
  i, j, NumCObjects, NumConverted: integer;
  PRCompD: TN_PRNonLinConv;
//  EllRect: TRect;
//  EllCent, EllSize: TPoint;
  URect: TFRect;
//  TmpNCL: TN_OneNonLinConv;
  CurObj: TN_UDBase;
  SrcCObj, DstCObj: TN_UCObjLayer;
  CurACoefs6: TN_AffCoefs6;
  ACParams: array [0..7] of double;
begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with PRCompD^, PRCompD^.CNonLinConv, NGCont.DstOCanv do
  begin

  if (NLCSrcCObjDir = nil) or (NLCDstCObjDir = nil) then Exit; // a precaution
  if not (NLCMapLayerComp is TN_UDCompVis) then Exit; // if not Visual Comp

  NumCObjects := NLCSrcCObjDir.DirLength();
  NumConverted := 0;

  for i := 0 to NumCObjects-1 do // along all Src CObjects to convert
  begin

  CurObj := NLCSrcCObjDir.DirChild( i );
  if not (CurObj is TN_UCObjLayer) then Continue; // skip if not CObject
  SrcCObj := TN_UCObjLayer(CurObj);

  CurObj := NLCDstCObjDir.DirChildByObjName( SrcCObj.ObjName );
//  CurObj := N_GetUObj( NLCDstCObjDir, SrcCObj.ObjName );
  if not (CurObj is TN_UCObjLayer) then Continue; // skip if not CObject
  DstCObj := TN_UCObjLayer(CurObj);

  //***** Calc CurACoefs6 - needed Affine convertion

  with TN_UDCompVis(NLCMapLayerComp) do
    URect := N_AffConvI2FRect1( CompIntPixRect, CompP2U );

  ACParams[0] := URect.Left;
  ACParams[1] := URect.Top;
  ACParams[2] := URect.Right;
  ACParams[3] := URect.Bottom;
  ACParams[4] := 0;
  ACParams[5] := 0;
  ACParams[6] := 100;
  ACParams[7] := 100;
  N_CalcAffCoefs6( $04, CurACoefs6, @ACParams[0] ); // User to percents

  for j := 0 to NLCConvs.AHigh() do // along all convertions
  with TN_POneNonLinConv(NLCConvs.P(i))^ do
  begin
    if nlctSkip in NLCParType then Continue; // skip Convertion

    if nlctRotate in NLCParType then // Rotate around Fixed Point
    begin
      ACParams[0] := NLCAngle;
      ACParams[1] := NLCFixedPoint.X;
      ACParams[2] := NLCFixedPoint.Y;
      N_CalcAffCoefs6( $13, CurACoefs6, @ACParams[0] );
    end; // if nlctRotate in NLCParType then

    if nlctRScale in NLCParType then // R Scale around Fixed Point
    begin
      ACParams[0] := NLCFixedPoint.X;
      ACParams[1] := NLCFixedPoint.Y;
      ACParams[2] := NLCFixedPoint.X + 100;
      ACParams[3] := NLCFixedPoint.Y + 100;
      ACParams[4] := NLCFixedPoint.X;
      ACParams[5] := NLCFixedPoint.Y;
      ACParams[6] := NLCFixedPoint.X + 100*NLCScale.X;
      ACParams[7] := NLCFixedPoint.Y + 100*NLCScale.X;
      N_CalcAffCoefs6( $14, CurACoefs6, @ACParams[0] );
    end else if nlctXYScale in NLCParType then // X,Y Scale around Fixed Point
    begin
      ACParams[0] := NLCFixedPoint.X;
      ACParams[1] := NLCFixedPoint.Y;
      ACParams[2] := NLCFixedPoint.X + 100;
      ACParams[3] := NLCFixedPoint.Y + 100;
      ACParams[4] := NLCFixedPoint.X;
      ACParams[5] := NLCFixedPoint.Y;
      ACParams[6] := NLCFixedPoint.X + 100*NLCScale.X;
      ACParams[7] := NLCFixedPoint.Y + 100*NLCScale.Y;
      N_CalcAffCoefs6( $14, CurACoefs6, @ACParams[0] );
    end; // Scale

    if nlctShift in NLCParType then // Shift
    begin
      ACParams[0] := NLCShift.X;
      ACParams[1] := NLCShift.Y;
      N_CalcAffCoefs6( $11, CurACoefs6, @ACParams[0] );
    end; // if nlctShift in NLCParType then // Shift
  end; // for j := 0 to NLCConvs.AHigh() do // along all convertions

  ACParams[0] := 0;
  ACParams[1] := 0;
  ACParams[2] := 100;
  ACParams[3] := 100;
  ACParams[4] := URect.Left;
  ACParams[5] := URect.Top;
  ACParams[6] := URect.Right;
  ACParams[7] := URect.Bottom;
  N_CalcAffCoefs6( $14, CurACoefs6, @ACParams[0] ); // back from percents to User

  //***** Here: needed Affine convertion is OK

  DstCObj.CopyContent( SrcCObj );
  DstCObj.AffConvSelf( CurACoefs6 );
  Inc( NumConverted );

  end; // for i := 0 to NumCObjects-1 do // along all Src CObjects to convert
  N_i := NumConverted; // show later in StatusBar

{
    for i := 0 to NLCConvs.AHigh() do
    with TN_POneNonLinConv(NLCConvs.P(i))^ do
    begin

      //***** debug drawing
      TmpNCL := TN_POneNonLinConv(NLCConvs.P(i))^;
      EllCent.X := Round( CCRSize.X * NLCElCenter.X / 100 );
      EllCent.Y := Round( CCRSize.Y * NLCElCenter.Y / 100 );
      EllSize.X := Round( 2 * CCRSize.X * NLCR1.X / 100 );
      EllSize.Y := Round( 2 * CCRSize.Y * NLCR1.Y / 100 );
      EllRect := N_RectMake( EllCent, EllSize, DPoint( 0.5, 0.5 ) );
//      SetBrushAttribs( $00FF00 );
//      DrawPixEllipse( EllRect );
      //***** end of debug drawing

    end; // with TN_POneNonLinConv(NLCConvs.P(i))^ do
}
  end; // PRCompD^, PRCompD^.CNonLinConv do
end; // end_of procedure TN_UDNonLinConv.BeforeAction


//********** TN_UDDynPictCreator class methods  **************

//********************************************** TN_UDDynPictCreator.Create ***
//
constructor TN_UDDynPictCreator.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDDynPictCreatorCI;
  ImgInd := 86;
end; // end_of constructor TN_UDDynPictCreator.Create

//********************************************* TN_UDDynPictCreator.Destroy ***
//
destructor TN_UDDynPictCreator.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDDynPictCreator.Destroy

//********************************************** TN_UDDynPictCreator.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDDynPictCreator.PSP(): TN_PRDynPictCreator;
begin
  Result := TN_PRDynPictCreator(R.P());
end; // end_of function TN_UDDynPictCreator.PSP

//********************************************** TN_UDDynPictCreator.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDDynPictCreator.PDP(): TN_PRDynPictCreator;
begin
  if DynPar <> nil then Result := TN_PRDynPictCreator(DynPar.P())
                   else Result := TN_PRDynPictCreator(R.P());
end; // end_of function TN_UDDynPictCreator.PDP

//******************************************* TN_UDDynPictCreator.PISP ***
// return typed pointer to Individual Static DynPictCreator Params
//
function TN_UDDynPictCreator.PISP(): TN_PCDynPictCreator;
begin
  Result := @(TN_PRDynPictCreator(R.P())^.CDynPictCreator);
end; // function TN_UDDynPictCreator.PISP

//******************************************* TN_UDDynPictCreator.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic DynPictCreator Params
// otherwise return typed pointer to Individual Static DynPictCreator Params
//
function TN_UDDynPictCreator.PIDP(): TN_PCDynPictCreator;
begin
  if DynPar <> nil then
    Result := @(TN_PRDynPictCreator(DynPar.P())^.CDynPictCreator)
  else
    Result := @(TN_PRDynPictCreator(R.P())^.CDynPictCreator);
end; // function TN_UDDynPictCreator.PIDP

//********************************************** TN_UDDynPictCreator.PascalInit ***
// Init self
//
procedure TN_UDDynPictCreator.PascalInit();
var
  PRCompS: TN_PRDynPictCreator;
begin
  Inherited;
  PRCompS := PSP();
  with PRCompS^, PRCompS^.CDynPictCreator do
  begin
    DPCFlags := [dpcfRandTestColors];

    DPCStaticColors := K_RCreateByTypeName( 'Color', 1 );
    PInteger(DPCStaticColors.P(0))^ := N_EmptyColor;

    DPCTestMinColor   := $AAAAAA;
    DPCTestMaxColor   := $FFFFFF;
    DPCRectsBackColor := $888888;

    DPCSpecMinColor   := $FE80FE;
    DPCSpecMaxColor   := $FEFDFE;
    DPCSrcTranspColor := $FEFEFE;

    DPCAZColor  := $FFFFFF;
    DPCNAZColor := $00BB00;
  end;
end; // procedure TN_UDDynPictCreator.PascalInit

//************************************** TN_UDDynPictCreator.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDDynPictCreator.BeforeAction();
var
  i, NumCRects, NumOPCRows, NumDynColors: integer;
  SrcPictFName, DynPictFName, StatPictFName, JSCodeFName, SLHeader: string;
  dy, ddy, n1, n2, n3, n4, n11: integer;
  PDynColors: PInteger;
  TestColors: TN_IArray;
  OPCRows: TN_OPCRowArray;
  CRects: TN_CRectArray;
  SrcRObj, DynRObj, StatRObj: TN_RasterObj;
  SLBuf: TN_SLBuf;
  SL: TStringList;
  PRCompD: TN_PRDynPictCreator;
  FillType: TN_RAFillColorsType;
  CurRFrame: TN_Rast1Frame;
begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with NGCont, PRCompD^, PRCompD^.CDynPictCreator do
  begin

  // TestColors are used for debug drawing of resulting rects
  NumDynColors := DPCColorsUDV.PDRA().ALength();
  SetLength( TestColors, NumDynColors );

  FillType := fctUniformLinear;
  if dpcfRandTestColors in DPCFlags then FillType := fctRangeIndependant;
  N_CreateTestColors ( FillType, DPCTestMinColor, DPCTestMaxColor,
                                     @TestColors[0], NumDynColors );

  // DPCSpecMinColor = N_EmptyColor means that DPCColorsUDV is already OK

  PDynColors := DPCColorsUDV.PDE(0);
  if DPCSpecMinColor <> N_EmptyColor then // fill DPCColorsUDV by given Special Colors
  begin                         // these colors should not be used in in Sorce Picture
    N_CreateTestColors ( fct3DigitNumbers, DPCSpecMinColor, DPCSpecMaxColor,
                                                   PDynColors, NumDynColors );
  end;

  SrcPictFName  := K_ExpandFileName( DPCSourcePictFN );
  DynPictFName  := K_ExpandFileName( DPC8BitDynPictFN );
  StatPictFName := K_ExpandFileName( DPC8BitStatPictFN );
  CurRFrame := nil;

  if SrcPictFName <> '' then // source Raster should be taken from given File
  begin
    SrcRObj := TN_RasterObj.Create( rtBArray, SrcPictFName );
    SLHeader := 'Source Picture file: ' + SrcPictFName;
    if N_ActiveRFrame <> nil then
      CurRFrame := N_ActiveRFrame; // used for created rects debug drawing
  end else // source Raster should be created by current or given VCTree
  begin
    if DPCSrcVCTree = nil then // use current VCTree (N_ActiveRFrame)
    begin
      if N_ActiveRFrame = nil then
      begin
        GCShowResponse( 'No ActveRFrame!' );
        Exit;
      end;
      CurRFrame := N_ActiveRFrame;
    end else //****************** use given DPCSrcVCTree
    begin
      N_ViewCompFull( DPCSrcVCTree, @N_MEGlobObj.RastVCTForm, GCOwnerForm, 'DynColors Map' );
      N_MEGlobObj.RastVCTForm.RFrame.aInitFrameExecute( TObject(2) ); // adjust Form size by Component
      CurRFrame := N_MEGlobObj.RastVCTForm.RFrame;
    end;

    SrcRObj := TN_RasterObj.Create( CurRFrame.OCanv );
    SLHeader := 'Source Component: ' + CurRFrame.RVCTreeRoot.ObjName;
  end;
  SrcRObj.RR.RTranspColor := DPCSrcTranspColor; // for creating Static Picture

  //***** Here: SrcRObj is OK, create DynRObj and clear DynPixels in SrcRObj

  if dpcfGivenDynPict in DPCFlags then // DynRObj should be taken from given File
  begin
    DynRObj := TN_RasterObj.Create( rtBArray, DynPictFName );
    Assert( False, 'NOT IMPLEMENTED YET!' );

    // Clear DynPixels in SrcRObj - NOT IMPLEMENTED YET!
    // .......................

  end else //**** create DynRObj by SrcRObj and list of Static and Dynamic Colors
  begin
    DynRObj := SrcRObj.Create8bitRObj( rtBArray, PDynColors, NumDynColors,
      DPCStaticColors.P(), DPCStaticColors.ALength, DPCAZColor, DPCNAZColor, 0 );

    // Save DynRObj if needed (mainly for debug)
    if DynPictFName <> '' then DynRObj.SaveRObjToFile( DynPictFName, N_FullIRect );
  end;

  // StatPictFName should be GIF file to realize transparency

  if StatPictFName <> '' then SrcRObj.SaveRObjToFile( StatPictFName,
                                                            N_FullIRect, nil );
  SrcRObj.Free();

  //***** Here: DynRObj is OK, create OPCRows by it and CRects by OPCRows

  NumOPCRows := DynRObj.CreateOPCRows( DPCNAZColor, OPCRows );
  DynRObj.Free;

  NumCRects := N_CreateColorRects( OPCRows, NumOPCRows, CRects );

  // Add debug comments, rects statistics and JavaScript code to temporary SL

  SL := TStringList.Create(); // for Protocol, statistics and JavaScript code

  if dpcfDebJSOutput in DPCFlags then // add statistics
  begin
    SL.Add( SLHeader );
    SL.Add( '' );
    SL.Add( ' Code   Left Top  Right Bottom' ); // CRects coords header

    //***** variables for CRects statistic (number of Rects with specified height):
    n1  := 0; // one pixel height Rects
    n2  := 0; // two pixel height Rects
    n3  := 0; // three pixel height Rects
    n4  := 0; // Rects with height from 4 to 10
    n11 := 0; // Rects with height >= 11

    for i := 0 to NumCRects-1 do
    begin
      if i >= 1 then
      begin
        if (CRects[i-1].CRCode  <> CRects[i].CRCode) or
           (CRects[i-1].CRect.Bottom+1 <> CRects[i].CRect.Top) then
          SL.Add( '' ); // delimeter row
      end;

      // dy  - crrent Rect height
      // ddy - gap along Y between current and previous rects

      with CRects[i] do
      begin
        dy  := CRect.Bottom - CRect.Top + 1;
        ddy := CRect.Top - CRects[i-1].CRect.Bottom - 1;
      end;

      if dy = 1 then Inc(n1);
      if dy = 2 then Inc(n2);
      if dy = 3 then Inc(n3);
      if (dy >= 4) and (dy <= 10) then Inc(n4);
      if (dy >= 11) then Inc(n11);

      with CRects[i] do
        SL.Add( Format( '  %.3d    %.3d %.3d  %.3d %.3d  (dy=%.2d, ddy=%d)',
              [CRCode, CRect.Left, CRect.Top, CRect.Right, CRect.Bottom, dy, ddy] ) );
    end; // for i := 1 to NumCRects-1 do

    SL.Add( '' );
    SL.Add( Format( ' NumOPCRows=%d,  NumCRects=%d', [NumOPCRows, NumCRects] ) );
    SL.Add( Format( ' n(=1): %d,  n(=2): %d,  n(=3): %d,  n(4-10): %d,  n(>=11): %d',
                                                       [n1, n2, n3, n4, n11] ) );
    SL.Add( '' );
  end; // if dpcfDebJSOutput in DPCFlags then // add statistics

  SLBuf := TN_SLBuf.Create( SL );
  N_ConvColorRectsToJS ( SLBuf, CRects, NumCRects );

  JSCodeFName := K_ExpandFileName( DPCResJSCodeFN );
  if JSCodeFName <> '' then
    SL.SaveToFile( JSCodeFName );

  SLBuf.Free;
  SL.Free;

  for i := 0 to NumCRects-1 do // only for debug drawing of created rects
  begin
//    N_IAdd( Format( 'i=%d, CRects[i].CRCode=%d', [i, CRects[i].CRCode] )); // debug
    CRects[i].CRCode := TestColors[CRects[i].CRCode];
  end;

  if CurRFrame <> nil then // draw created rects in CurRFrame (debug drawing)
  begin
    CurRFrame.OCanv.ClearSelfByColor( DPCRectsBackColor );
    CurRFrame.OCanv.DrawPixColorRects( CRects, NumCRects );
    CurRFrame.ShowMainBuf();

    if (dpcfShowStatPict in DPCFlags) and (StatPictFName <> '') then // draw StatPict over Color Rects
    begin
      N_DelayInSeconds( 2 ); // wait for 2 seconds to view rects before clipping
      StatRObj := TN_RasterObj.Create( rtBArray, StatPictFName, -2 ); // -2 means using GIF Transp Color
      StatRObj.Draw( CurRFrame.OCanv.HMDC, Rect(0,0,-1,-1), Rect(0,0,-1,-1) );
      StatRObj.Free;
      CurRFrame.ShowMainBuf();
    end;
  end; // if CurRFrame <> nil then

  GCShowResponse( 'JavaScript Code Created' );

  end; // with NGCont, PRCompD^, PRCompD^.CDynPictCreator do
end; // end_of procedure TN_UDDynPictCreator.BeforeAction


//********** TN_UDCalcUParams class methods  **************

//********************************************** TN_UDCalcUParams.Create ***
//
constructor TN_UDCalcUParams.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDCalcUParamsCI;
  ImgInd := 92;
end; // end_of constructor TN_UDCalcUParams.Create

//********************************************* TN_UDCalcUParams.Destroy ***
//
destructor TN_UDCalcUParams.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDCalcUParams.Destroy

//********************************************** TN_UDCalcUParams.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDCalcUParams.PSP(): TN_PRCalcUParams;
begin
  Result := TN_PRCalcUParams(R.P());
end; // end_of function TN_UDCalcUParams.PSP

//********************************************** TN_UDCalcUParams.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDCalcUParams.PDP(): TN_PRCalcUParams;
begin
  if DynPar <> nil then Result := TN_PRCalcUParams(DynPar.P())
                   else Result := TN_PRCalcUParams(R.P());
end; // end_of function TN_UDCalcUParams.PDP

//******************************************* TN_UDCalcUParams.PISP ***
// return typed pointer to Individual Static CalcUParams Params
//
function TN_UDCalcUParams.PISP(): TN_PCCalcUParams;
begin
  Result := @(TN_PRCalcUParams(R.P())^.CCalcUParams);
end; // function TN_UDCalcUParams.PISP

//******************************************* TN_UDCalcUParams.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic CalcUParams Params
// otherwise return typed pointer to Individual Static CalcUParams Params
//
function TN_UDCalcUParams.PIDP(): TN_PCCalcUParams;
begin
  if DynPar <> nil then
    Result := @(TN_PRCalcUParams(DynPar.P())^.CCalcUParams)
  else
    Result := @(TN_PRCalcUParams(R.P())^.CCalcUParams);
end; // function TN_UDCalcUParams.PIDP

//********************************************** TN_UDCalcUParams.PascalInit ***
// Init self
//
procedure TN_UDCalcUParams.PascalInit();
begin
  Inherited;
end; // procedure TN_UDCalcUParams.PascalInit

//************************************** TN_UDCalcUParams.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDCalcUParams.BeforeAction();
var
  ielem, NumElems: integer;
  UDPI: TK_UDProgramItem;
  SL: TStringList;

  function GetProcName( AElemInd: integer ): string; // local
  // create SPL Procedure Name for Element with given Index
  begin
    Result := Format( 'CalcUP_%.2d', [AElemInd] );
  end; // function GetProcName - local

begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;
  with PIDP()^ do
  begin

  InitSPLUnitText();
  SL := TStringList.Create; // used as bufer for one Element SPL code
  NumElems := CVElems.ALength();

  //***** Add to N_MEGlobObj.MECompSPLText SPL Code for all Elements

  for ielem := 0 to NumElems-1 do // along all Elements
  with TN_PCalcUParamsElem(CVElems.P(ielem))^, N_MEGlobObj.MECompSPLText do
  begin
    if cvefSkip in CVEFlags then Continue; // skip Element

    if CVESPLProc <> '' then // Add SPL Procedure Code, using SL as Buf
    begin
      Add( 'procedure ' + GetProcName( ielem ) + '();' );
      SL.Text := CVESPLProc;
      AddStrings( SL );
      Add( '' );
    end; // if CVESPLProc <> '' then // Add SPL Procedure Code
  end; // with, for ielem := 0 to NumElems-1 do // along all Elements

  SL.Free;
  FinSPLUnit();
  InitGVars();

  //***** SPLUnit is OK, Run SPL Code for all Elements

  for ielem := 0 to NumElems-1 do // along all Elements
  with TN_PCalcUParamsElem(CVElems.P(ielem))^ do
  begin
    if cvefSkip in CVEFlags then Continue; // skip Element

    if (SPLUnit <> nil) and (CVESPLProc <> '' ) then // call Element SPL Procedure
    begin
      UDPI := TK_UDProgramItem(SPLUnit.DirChildByObjName( GetProcName( ielem ) ));
      if UDPI <> nil then
        UDPI.CallSPLRoutine( [] );
    end; // if (SPLUnit <> nil) and (CVESPLProc <> '' ) then // call Element SPL Procedure
  end; // for ielem := 0 to NumBlocks-1 do // along all Cells Blocks

  end; // with PIDP()^ do
end; // end_of procedure TN_UDCalcUParams.BeforeAction


//********** TN_UDTextFragm class methods  **************

//********************************************** TN_UDTextFragm.Create ***
//
constructor TN_UDTextFragm.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDTextFragmCI;
  CStatFlags := [csfExecAfter];
  ImgInd := 51;
end; // end_of constructor TN_UDTextFragm.Create

//********************************************* TN_UDTextFragm.Destroy ***
//
destructor TN_UDTextFragm.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDTextFragm.Destroy

//********************************************** TN_UDTextFragm.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDTextFragm.PSP(): TN_PRTextFragm;
begin
  Result := TN_PRTextFragm(R.P());
end; // end_of function TN_UDTextFragm.PSP

//********************************************** TN_UDTextFragm.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDTextFragm.PDP(): TN_PRTextFragm;
begin
  if DynPar <> nil then Result := TN_PRTextFragm(DynPar.P())
                   else Result := TN_PRTextFragm(R.P());
end; // end_of function TN_UDTextFragm.PDP

//******************************************* TN_UDTextFragm.PISP ***
// return typed pointer to Individual Static TextFragm Params
//
function TN_UDTextFragm.PISP(): TN_PCTextFragm;
begin
  Result := @(TN_PRTextFragm(R.P())^.CTextFragm);
end; // function TN_UDTextFragm.PISP

//******************************************* TN_UDTextFragm.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic TextFragm Params
// otherwise return typed pointer to Individual Static TextFragm Params
//
function TN_UDTextFragm.PIDP(): TN_PCTextFragm;
begin
  if DynPar <> nil then
    Result := @(TN_PRTextFragm(DynPar.P())^.CTextFragm)
  else
    Result := @(TN_PRTextFragm(R.P())^.CTextFragm);
end; // function TN_UDTextFragm.PIDP

//********************************************** TN_UDTextFragm.PascalInit ***
// Init self
//
procedure TN_UDTextFragm.PascalInit();
begin
  Inherited;
end; // procedure TN_UDTextFragm.PascalInit

//***************************************** TN_UDTextFragm.PrepMacroPointers ***
// Prepare Pointers to all Self Strings, that can contain Macroses
//
procedure TN_UDTextFragm.PrepMacroPointers();
begin
  inherited;
  with NGCont, PDP()^.CTextFragm do
  begin
    if Length(GCMacroPtrs) < (GCMPtrsNum+3) then
      SetLength( GCMacroPtrs, GCMPtrsNum+3 );

    GCMacroPtrs[GCMPtrsNum] := @TFStyle;  Inc(GCMPtrsNum);
    GCMacroPtrs[GCMPtrsNum] := @TFBefore; Inc(GCMPtrsNum);
    GCMacroPtrs[GCMPtrsNum] := @TFAfter;  Inc(GCMPtrsNum);
  end; // with NGCont, PDP()^.CTextFragm do
end; // end_of procedure TN_UDTextFragm.PrepMacroPointers

//************************************** TN_UDTextFragm.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDTextFragm.BeforeAction();
var
  PRCompD: TN_PRTextFragm;
  SL: TStringList;
begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with NGCont, PRCompD^.CTextFragm do
  begin
    if TFStyle  <> '' then
      GCOutStyleSL.Append( TFStyle );

    if TFBefore <> '' then
    begin
      if crtfRootComp in CRTFlags then // Root Component, add by rows
      begin
        SL := TStringList.Create();
        SL.Text := TFBefore;
        GCOutSL.AddStrings( SL );
        SL.Free;
      end else // add as a single row
         GCOutSL.Append( TFBefore );
    end; // if TFBefore <> '' then

  end; // NGCont, PRCompD^.CTextFragm do
end; // end_of procedure TN_UDTextFragm.BeforeAction

//********************************************** TN_UDTextFragm.AfterAction ***
// Component Action, executed before After Children
//
procedure TN_UDTextFragm.AfterAction();
var
  PRCompD: TN_PRTextFragm;
begin
  PRCompD := PDP();
  with NGCont, PRCompD^.CTextFragm do
  begin
    if TFAfter <> '' then GCOutSL.Append( TFAfter );
  end; // NGCont, PRCompD^.CTextFragm do
end; // end_of procedure TN_UDTextFragm.AfterAction


//********** TN_UDWordFragm class methods  **************

//********************************************** TN_UDWordFragm.Create ***
//
constructor TN_UDWordFragm.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDWordFragmCI;
  CStatFlags := [csfForceExec];
  ImgInd := 90;
end; // end_of constructor TN_UDWordFragm.Create

//********************************************* TN_UDWordFragm.Destroy ***
//
destructor TN_UDWordFragm.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDWordFragm.Destroy

//********************************************** TN_UDWordFragm.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDWordFragm.PSP(): TN_PRWordFragm;
begin
  Result := TN_PRWordFragm(R.P());
end; // end_of function TN_UDWordFragm.PSP

//********************************************** TN_UDWordFragm.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDWordFragm.PDP(): TN_PRWordFragm;
begin
  if DynPar <> nil then Result := TN_PRWordFragm(DynPar.P())
                   else Result := TN_PRWordFragm(R.P());
end; // end_of function TN_UDWordFragm.PDP

//******************************************* TN_UDWordFragm.PISP ***
// return typed pointer to Individual Static WordFragm Params
//
function TN_UDWordFragm.PISP(): TN_PCWordFragm;
begin
  Result := @(TN_PRWordFragm(R.P())^.CWordFragm);
end; // function TN_UDWordFragm.PISP

//******************************************* TN_UDWordFragm.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic WordFragm Params
// otherwise return typed pointer to Individual Static WordFragm Params
//
function TN_UDWordFragm.PIDP(): TN_PCWordFragm;
begin
  if DynPar <> nil then
    Result := @(TN_PRWordFragm(DynPar.P())^.CWordFragm)
  else
    Result := @(TN_PRWordFragm(R.P())^.CWordFragm);
end; // function TN_UDWordFragm.PIDP

//********************************************** TN_UDWordFragm.PascalInit ***
// Init self
//
procedure TN_UDWordFragm.PascalInit();
begin
  Inherited;
end; // procedure TN_UDWordFragm.PascalInit

type TN_CreateSelfDocMode = ( csdmPascal, csdmVBAMain, csdmVBAFragm ); // local, used in CreateSelfDoc method

//********************************************* TN_UDWordFragm.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDWordFragm.BeforeAction();
var
  FName, TmpFName, PS: string;
//  CreateMode: TN_CreateSelfDocMode;
  SelfDoc: Variant;
  WFVFile: TK_VFile;
  PRCompD: TN_PRWordFragm;

  // procedure ExpandMVTATables(); // local
  // procedure CreateSelfDoc();    // local
  // procedure InsertSelfDoc();    // local

  procedure ExpandMVTATables(); // local
  // 1) Find Table Row with '(#!' as first three symbols
  // 2) Get List of Global Var (array) Names from founded Row
  // 3) Copy all these array elems to Clipboard
  // 4) Add needed number of additional Rows (Length(array)-1)
  // 5) Select new and source Rows
  // 6) Paste Clipboard content (with list of strings) into Selected
  //
  // Temporary apply same formatting for all columns
  var
    TableInd, RowInd, ColInd, PatRowInd : integer;
    NumTables, NumRows, NumColumns, VectorsSize: integer;
    CurStr: string;
    CurTable, CurFont, CurRange: Variant;
    VectorNames: TN_SArray;
    SL: TStringList;
  begin
    NumTables := SelfDoc.Tables.Count;
    for TableInd := 1 to NumTables do // along all tables in SelfDoc
    with NGCont do
    begin
      CurTable := SelfDoc.Tables.Item( TableInd );
//      NumRows := CurTable.Rows.Count;
//      NumColumns := CurTable.Columns.Count;
{
      //*** Debug:
      CurTable.Cell( 1, 1 ).Select;
      GCWordServer.Selection.SelectRow;
      N_i2 := GCWordServer.Selection.Cells.Count;
      for i := 1 to N_i2 do
        N_s := GCWordServer.Selection.Cells.Item( i ).Range.Text;
}
      //***** 1) Find Table Row with '(#!' as first three symbols

      CurTable.Cell( 1, 1 ).Select;
      GCWordServer.Selection.SelectColumn;
      NumRows := GCWordServer.Selection.Cells.Count;
      PatRowInd := -1;

      for RowInd := 1 to NumRows do // find Pattern Row with '(#!' as first chars
      begin
        CurStr := GCWordServer.Selection.Cells.Item( RowInd ).Range.Text;

        if Pos( '(#!', CurStr ) = 1 then // found
        begin
          PatRowInd := RowInd;
          Break;
        end; // if Pos( CurStr, '(#!' ) = 1 then // found
      end; // for RowInd := 1 to NumRows do // find Pattern Row with '(#!' as first chars

      //***** 2) Get List of Global Var Names from founded Row (in (#...#) brackets)

      if PatRowInd = -1 then Continue; // Pattern Row was not found, process next Table

      GCWordServer.Selection.Cells.Item( RowInd ).Select; // Select first Cell in Pattern Row
      CurFont := GCWordServer.Selection.Font.Duplicate; // Save Formatting
//      N_i := CurFont.Color; // debug
      GCWordServer.Selection.SelectRow; // Select all cells of Pattern Row with Vector Names

      NumColumns := GCWordServer.Selection.Cells.Count;

      SetLength( VectorNames, NumColumns );
      VectorNames[0] := Copy( CurStr, 4, Length(CurStr)-7 ); // skip first three and four last '#)'#$d#7 chars

      for ColInd := 2 to NumColumns do // fill VectorNames array
      begin
        CurStr := GCWordServer.Selection.Cells.Item( ColInd ).Range.Text;
        VectorNames[ColInd-1] := Copy( CurStr, 4, Length(CurStr)-7 ); // skip first three and four last '#)'#$d#7 chars
      end; // for ColInd := 2 to NumColumns do // fill VectorNames array

{
      FirstCol := CurTable.Columns.Item( 1 ); // First Table Column
      PatRowInd := -1;

      //***** 1) Find Table Row with '(#!' as first three symbols

      for RowInd := 1 to NumRows do // find Pattern Row with '(#!' as first chars
      begin
        CurStr := FirstCol.Cells.Item( RowInd ).Range.Text;
        if Pos( '(#!', CurStr ) = 1 then // found
        begin
          PatRowInd := RowInd;
          Break;
        end; // if Pos( CurStr, '(#!' ) = 1 then // found
      end; // for RowInd := 1 to NumRows do // find Pattern Row with '(#!' as first chars

      //***** 2) Get List of Global Var Names from founded Row (in (#...#) brackets)

      if PatRowInd = -1 then Continue; // Pattern Row was not found, process next Table

      SetLength( VectorNames, NumColumns );
      VectorNames[0] := Copy( CurStr, 4, Length(CurStr)-7 ); // skip first three and four last '#)'#$d#7 chars

      PatRow := CurTable.Rows.Item( PatRowInd ); // Pattern Row with Vector Names

      for ColInd := 2 to NumColumns do // fill VectorNames array
      begin
        CurStr := PatRow.Cells.Item( ColInd ).Range.Text;
        VectorNames[ColInd-1] := Copy( CurStr, 4, Length(CurStr)-7 ); // skip first three and four last '#)'#$d#7 chars
      end; // for ColInd := 2 to NumColumns do // fill VectorNames array
}

      //***** 3) Copy all these elems to Clipboard

      SL := TStringList.Create();
      N_GetGlobVarsAsStrings( NGCont.GCVarInfoProc, @VectorNames[0], NumColumns,
                                                                 SL, VectorsSize );
      K_PutTextToClipboard( SL.Text );

      //***** 4) Add (VectorsSize-1) of additional Rows

//      for i := 1 to VectorsSize-1 do
//        CurTable.Rows.Add( PatRow );


      GCWordServer.Selection.InsertRows( VectorsSize-1 );
      CurRange := GCWordServer.Selection.Range;
//      GCWordServer.Selection.End := 1;

      //***** 5) Save Formatting and Select new and pattern Rows

//      CurFont := CurTable.Cell( PatRowInd, 1 ).Range.Font.Duplicate;

//        N_T1.Start();
//      CurRange := PatRow.Range;
//      CurRange.MoveStart( wdRow, -(VectorsSize-1) );

      // Remark: Range.MoveStart requires wdRow, but Selection.MoveUP requires wdLine!
      CurRange.MoveEnd( wdRow, 1 );
      CurRange.Paste;

       //***** Restore Formatting
//      CurRange.Font := CurFont; // causes Error! (becuse each Cell has own Font?)

      CurRange.Font.Name   := CurFont.Name; // restore formatting
      CurRange.Font.Size   := CurFont.Size;
      CurRange.Font.Bold   := CurFont.Bold;
      CurRange.Font.Italic := CurFont.Italic;

      if GCWSMajorVersion >= 9 then
        CurRange.Font.Color  := CurFont.Color;

//        N_T1.SS( 'Set Font Fields ' ); // 25 - 40 ms - nothing to optimize

{ // old Variant with Selection instead of Range (works slowly):
        N_T1.Start();
      CurTable.Rows.Item( PatRowInd ).Select; // select expanded Rows again
      NGCont.GCWordServer.Selection.MoveDown( wdLine, VectorsSize-1, wdExtend ); // wdRow instead of wdLine causes error

      //***** 6) Paste Clipboard content (with list of strings) into Selected
      //         and restore formatting (use first Cell of PatRow formatting for all Cells)

      NGCont.GCWordServer.Selection.Paste; // Selection is empty after this statement!

      CurTable.Rows.Item( PatRowInd ).Select; // select expanded Rows again
      NGCont.GCWordServer.Selection.MoveDown( wdLine, VectorsSize-1, wdExtend ); // wdRow instead of wdLine causes error

//      NGCont.GCWordServer.Selection.Font := CurFont; // causes Error! (becuse each Cell has own Font?)
      NGCont.GCWordServer.Selection.Font.Name := CurFont.Name; // restore formatting
      NGCont.GCWordServer.Selection.Font.Size := CurFont.Size; // restore formatting
      NGCont.GCWordServer.Selection.Font.Bold := CurFont.Bold; // restore formatting
      NGCont.GCWordServer.Selection.Font.Italic := CurFont.Italic; // restore formatting
      NGCont.GCWordServer.Selection.Font.Color := CurFont.Color; // restore formatting
        N_T1.SS( 'Set Font Fields ' ); // 25 - 40 ms - nothing to optimize
}

    end; // for TableInd := 1 to NumTables do // along all tables in SelfDoc
  end; // procedure ExpandMVTATables(); // local

  procedure CreateSelfDoc(); // local
  // Create New Word Document, based on Self (as template) in SelfDoc variable
  var
    DataSize: integer;
    FExt: string;
    TempFileCreated: boolean;
    FStream: TFileStream;
  begin
    with NGCont, PDP()^.CWordFragm do
    begin

    TempFileCreated := False;

    if FName = '' then // No FileName, create File by WFDocData if any
    begin
      DataSize := WFDocData.ALength();

      if DataSize = 0 then // No WFDocData
      begin
        SelfDoc := GCWordServer.Documents.Add(); // SelfDoc is New Empty Doc
        Exit; // all done
      end else // DataSize > 0, WFDocData is not empty, create Temporary file
      begin
        TempFileCreated := True;
        FExt := '.doc';
        if wffXMLContent in WFFlags then FExt := '.xml';
        FName := 'C:\_Tmp_Word_Doc_' + FExt;

        FStream := TFileStream.Create( FName, fmCreate );
        FStream.Write( WFDocData.P()^, DataSize );
        FStream.Free;
      end; // else // WFDocData is not empty

    end; // if FName = '' then // No FileName, create File by WFDocData if any

    //***** Check if FName is Virtual file and real file should be created
    K_VFAssignByPath( WFVFile, FName );
    if WFVFile.VFType <> K_vftDFile then // FName is Virtual file
    begin
      TmpFName := K_ExpandFIleName( '(#TmpFiles#)' + ExtractFileName(FName) );
      K_VFCopyFile( FName, TmpFName, K_DFCreatePlain ); // copy FName -> TmpFName
      FName := TmpFName;
      TempFileCreated := True;
    end;

    if not (crtfRootComp in CRTFlags) then // For all Components but Root Open, if not yet
      OpenWordDocSafe( FName ); // Template FName as temporary document for speed

    SelfDoc := GCWordServer.Documents.Add( Template:=FName );

{
    if CreateMode = csdmPascal then //******* Create SelfDoc in Pascal
    begin
      SelfDoc := GCWordServer.Documents.Add( Template:=FName )
    end else if CreateMode = csdmVBAMain then // Start creating GCMainDoc
    begin
      PS := Format( '%d%s%d', [GetCurrentProcessId(), N_VBAParamsDelimeter,
                               Integer(@N_DelphiMem[0])] ) +
           N_VBAParamsDelimeter + FName + N_VBAParamsDelimeter + GCMainFileName;

      SetWordParamsStr( PS );

      RunWordMacro( 'N_StartGCMainDoc' );

      SelfDoc := GCWordServer.ActiveDocument; // Active Document was set in 'N_StartGCMainDoc'
      N_s := SelfDoc.Name; // debug
      GCWSMainDoc := SelfDoc;
//      SetWordPSMode( N_MEGlobObj.MEWordPSMode );

    end else if CreateMode = csdmVBAFragm then // Create SelfDoc as FrgmDoc in VBA
    begin // is slower than one Pascal statement, but is needed to alow VBA to insert FragmDoc in MainDoc
      SetWordParamsStr( FName );
      RunWordMacro( 'N_CreateFragmDoc' );
      SelfDoc := GCWordServer.ActiveDocument;
    end;
}
    if TempFileCreated then DeleteFile( FName );

    if wffExpandTables in WFFlags then ExpandMVTATables();

    end; // with NGCont, PDP()^.CWordFragm do
  end; // procedure CreateSelfDoc(); // local

  procedure InsertSelfDoc(); // local
  //  Insert SelfDoc in GCMainDoc, Close and Free SelfDoc,
  var
    SelfDocText: string;
    SelfDocNotEmpty: boolean;
    TmpRange: Variant;
  begin

  with NGCont, PRCompD^.CWordFragm do
  begin
//  N_T1.Start;

    if wffDeb1 in WFFlags then // debug
    begin
      // debug
    end; // if wffDeb1 in WFFlags then // debug

    // Prepare PS (ParamsStr) for VBA:
    //   L - Copy SelfDoc to cLipboard
    //   A - Add Clipboard to the end of MainDoc
    //   ? - ...
    //        Add later flags for inserting near bookmark

    PS := '';
    if not (wffSkipAutoCopy in WFFlags) then PS := PS + 'L'; // Copy SelfDoc to cLipboard
    PS := PS + 'A'; // now always Add Clipboard at the end of MainDoc

    if mewfUseVBA in GCWSVBAFlags then // Use VBA for Inserting SelfDoc
    begin
      SetWordParamsStr( PS );
      RunWordMacro( 'N_InsertFragmDoc' );
    end else //************************** Use Pascal for Inserting SelfDoc
    begin

      SelfDocNotEmpty := True;

      if Pos( 'L', PS ) > 0 then // Copy SelfDoc to Clipboard
      begin
        TmpRange := SelfDoc.Range;
        TmpRange.MoveEnd( wdCharacter, -1 ); // Skip terminating Paragraph symbol
        SelfDocText := TmpRange.Text;
        SelfDocNotEmpty := Length(SelfDocText) > 0;
        if SelfDocNotEmpty then // Copiing Empty range causes error!
          TmpRange.Copy; // copy SelfDoc to Windows Clipboard
      end; // if Pos( 'L', PS ) > 0 then // Copy SelfDoc to cLipboard

      SelfDoc.Saved := True; // Close SelfDoc without Alerts
      SelfDoc.Close;
      SelfDoc := Unassigned();

      if SelfDocNotEmpty and (Pos( 'A', PS ) > 0) then // Add Clipboard to the end of MainDoc
      begin
        TmpRange := GCWSMainDoc.Content;
        TmpRange.Collapse( Direction := wdCollapseEnd );
        TmpRange.Paste;
      end; // if Pos( 'A', PS ) > 0 then // Add Clipboard to the end of MainDoc

    end; // else // Use Pascal for Inserting SelfDoc

{
  var
    NumSections: integer;
    BookmarkName: string;
    Section, HF, HFRange, Bmk: variant;


    if not (wffSkipAutoCopy in WFFlags) then
    begin
      SelfRange := SelfDoc.Range; //??
//      SelfRange := SelfDoc.Content; // better?
      SelfRange.MoveEnd( wdCharacter, -1 );
      SelfRange.Copy; // copy SelfDoc to Windows Clipboard
    end;

    SelfDoc.Saved := True; // Close SelfDoc
    SelfDoc.Close;
    SelfDoc := Unassigned();

    BookmarkName := GCStrVars.Values[ WFBmGCVarName ];

    //***** Insert needed content in Set SelfRange to this inserted content

    if BookmarkName <> '' then // Insert near Bookmark
    begin
      SelfRange := WordInsNearBookmark( wibwhereEnd1, wibWhatClipboard, BookmarkName );
    end else // paste into GCMainDocIP
    begin
      GCWSMainDocIP := GCWSMainDoc.Content;
      GCWSMainDocIP.Collapse( Direction := wdCollapseEnd );
      GCWSMainDocIP.Paste;

      //    Remarks:
      // if SelfRange = nil then call SelfRange.SetRange causes error
      //
      // if just assign SelfRange := GCWSMainDocIP, Collapsing GCWSMainDocIP will
      //   also affect (collapse) SelfRange, so SetRange is really needed
      //   (SelfRange is used below, after this if)

//      SelfRange := GCWSMainDoc.Range;
//      SelfRange.SetRange( GCWSMainDocIP.Start, GCWSMainDocIP.End );
//      N_i1 := SelfRange.Start;

      //***** Note:
      //      Next statement(N_i2:=...), if not commented,  prevents working Ctrl+RightClick
      //      in Delphi environment (from the end of this local Proc and below) !!!
      //           N_i2 := SelfRange.End; // Delphi Parser Error!

//      GCWSMainDocIP.Collapse( Direction := wdCollapseEnd );
//        N_i1 := SelfRange.Start;
//        N_i2 := SelfRange.End;

    end;

    //***** Here: needed content was inserted in GCWSMainDoc and SelfRange
    //      contains this inserted content

    if wffNewSection in WFFlags then // format SelfRange as New Section with possible Header and Footer
    begin
      SelfRange.InsertBreak( wdSectionBreakNextPage );

      NumSections := GCWSMainDoc.Sections.Count;
      Section := GCWSMainDoc.Sections.Item( NumSections ); // last, just created section

      if GCWSMainDoc.Bookmarks.Exists( 'Header' ) then // set Header
      begin
        Bmk := GCWSMainDoc.Bookmarks.Item( 'Header' ); // Bookmark with Header Content
        HFRange := Bmk.Range;
        Bmk.Delete; // Delete Bookmark Obj, its content remains
        HFRange.Copy; // Copy Header Content
        HFRange.Text := ''; // delete Header Content from Document body

        HF := Section.Headers.Item( wdHeaderFooterPrimary ); // HeaderFooter Object
        HF.LinkToPrevious := False; // to preserve previous Section Header
        HFRange := HF.Range;
        HFRange.Paste;       // set Header Content

        // delete former Paragraph symbol
        HFRange.Collapse( wdCollapseEnd );
        HFRange.Delete( wdCharacter, 1 );
      end; // if GCWSMainDoc.Bookmarks.Exists( 'Header' ) then // set Header

      if GCWSMainDoc.Bookmarks.Exists( 'Footer' ) then // set Footer
      begin
        Bmk := GCWSMainDoc.Bookmarks.Item( 'Footer' ); // Bookmark with Footer Content
        HFRange := Bmk.Range;
        Bmk.Delete; // Delete Bookmark Obj, its content remains
        HFRange.Copy; // Copy Header Content
        HFRange.Text := ''; // delete Header Content from Document body

        HF := Section.Footers.Item( wdHeaderFooterPrimary ); // HeaderFooter Object
        HF.LinkToPrevious := False; // to preserve previous Section Footer
        HFRange := HF.Range;
        HFRange.Paste;       // set Footer Content

        // delete former Paragraph symbol
        HFRange.Collapse( wdCollapseEnd );
        HFRange.Delete( wdCharacter, 1 );
      end; // if GCWSMainDoc.Bookmarks.Exists( 'Footer' ) then // set Footer

    end; // if wffNewSection in WFFlags then // format SelfRange as New Section
}

//    N_T1.SS( 'InsertSelfDoc' );

 //***** Note:
 //      at this place Ctrl+RightClick on N_i DOES NOT work if statement
 //        N_i2 := SelfRange.End;
 //      is some where in above fragment !!!

    N_i := 1;
  end; // with NGCont, PRCompD^.CWordFragm do

  end; // procedure InsertSelfDoc(); // local

begin //*************************** main body of TN_UDWordFragm.BeforeAction();
  PRCompD := PDP();
//  CreateMode := csdmPascal;

  with NGCont, PRCompD^.CWordFragm do
  begin
    N_s := ObjName; // debug
    Inc( GCPDCounter );

    FName := K_ExpandFileName( WFDocFName );
    if (FName <> '') and not K_VFileExists( FName ) then
    begin
      GCShowString( 'File not found: ' + FName );
      Exit;
    end;

    if crtfRootComp in CRTFlags then //************************* Root Component
    begin

      if wffExpToCurDoc in WFFlags then // GCWSMainDoc is currently Active Document
                                        // Process Self macros and Paste Self in it
      begin
        GCWSMainDoc := GCWordServer.ActiveDocument;
//        N_s := GCWSMainDoc.Name; // debug
        GCWSMainDocIP := GCWordServer.Selection.Range;
        CreateSelfDoc();
        WordProcessSPLMacros( Self, SelfDoc );
        InsertSelfDoc();
      end else //********************* GCWSMainDoc is New Document, Based on Self
      begin
//        DebAddDocsInfo( 'Root Before:', 0 );
//        if mewfUseVBA in GCWSVBAFlags then CreateMode := csdmVBAMain;

        CreateSelfDoc();
        GCWSMainDoc := SelfDoc;
        SelfDoc := Unassigned();
//        GCWSMainDocIP := Unassigned();
        WordProcessSPLMacros( Self, GCWSMainDoc );
//        if mewfUseVBA in N_MEGlobObj.MEWordFlags then Exit; // all done

        if mewfUseVBA in GCWSVBAFlags then // Set N_SetGCMainDoc glob var in VBA
        begin
          GCWSMainDoc.Activate;
          RunWordMacro( 'N_SetGCMainDoc' );
        end;

{
        if VarIsEmpty( GCWSMainDocIP ) then
        begin
          GCWSMainDocIP := GCWSMainDoc.Range;
          GCWSMainDocIP.Collapse( wdCollapseEnd );
        end;

      CloseWordDocSafe( GCMainFileName );
      N_s1 := GCWSMainDoc.Name;
      N_s2 := GCWSMainDoc.Path;
      N_s := GCMainFileName;
//      if FileExists( GCMainFileName ) then DeleteFile( GCMainFileName );
//      GCWSMainDoc.SaveAs( Filename := GCMainFileName );

//      GCWSMainDoc.Activate; // may be not needed, but GCWSMainDoc should be Active
//      N_s := ExtractFileName( GCMainFileName );
//      N_v := GCWordServer.Documents.Item(N_s);

      //*** Prepare GCWSMainDoc Variable 'IPPInfo' with Sel Process Id and
      //    address of N_InterProcesParams

//      IPPStr := Format( '%d %d', [GetCurrentProcessId(),
//                                  Integer(@N_InterProcesParams[0])] );
//      N_InterProcesParams[0].IPPWriteNY := 27;
//      N_InterProcesParams[4].IPPWriteNY := 28;
//      GCWSMainDoc.Variables.Add( Name:='IPPInfo', Value := IPPStr );

//      GCWordServer.Run( 'InitializeIPP' ); // Initialize VBA InterProces Params
//      N_i := N_InterProcesParams[3].IPPWriteNY;
}
      end; // else // GCWSMainDoc is Self

    end else //******************************************** Not Root Component
    begin
//      if mewfUseVBA in GCWSVBAFlags then CreateMode := csdmVBAFragm;

      if wffProcAllDoc in WFFlags then // Process macros in whole GCWSMainDoc
      begin
        CreateSelfDoc();
        InsertSelfDoc();
        WordProcessSPLMacros( Self, GCWSMainDoc );
      end else //************************ Process macros in SelfDoc only
      begin
        CreateSelfDoc();

        if mewfUseVBA in GCWSVBAFlags then // Set N_GCFragmDoc glob var in VBA
        begin
          SelfDoc.Activate;
          RunWordMacro( 'N_SetGCFragmDoc' );
        end;
//        N_s := SelfDoc.Name; // debug
//        N_PCAdd( 1, Self.ObjName + '  ' + N_s ); // debug
        WordProcessSPLMacros( Self, SelfDoc );
        InsertSelfDoc();
      end; // else //*** Process macros in SelfDoc only

    end; // else //*** Not Root Component

//  Is needed only for documents with very large TOCs to avois crashing
//    if (GCPDCounter mod GCPDCounterDelta) = (GCPDCounterDelta-1) then
//      GCWSMainDoc.Save;

  end; // NGCont, PDP()^.CWordFragm do
end; // end_of procedure TN_UDWordFragm.BeforeAction

{
//******************************************** TN_UDWordFragm.ProcessMacros ***
// Process Macros (Expand all kind of Macros) in given Word Document ADoc
//
procedure TN_UDWordFragm.ProcessMacros( ADoc: Variant );
var
  i, j, NumMacros, NumBookMarks: integer;
  BookMarkName, NewName, CurName: string;
  SavedShowHiddenText: boolean;
  BookMark, BookMarkRange, BMFootnotes: Variant;
  BMNames: TStringlist;
  PRCompD: TN_PRWordFragm;

  procedure ProcessOneMacro( AMacroStr: string ); // local
  var
    SheetType: ULong;
    MacroType: char;
    FName, FExt, ControlToken, FlagsToken, ResStr: string;
    ChildDoc, Sheet1: Variant;
  begin
    with NGCont do
    begin

    ControlToken := TrimLeft( UpperCase( N_ScanToken( AMacroStr ) ) ); // first control token
    if Length( ControlToken ) = 0 then Exit; // Empty Macro
    MacroType := ControlToken[1]; // 'F' - File Name,  'M' - Macros (SPL code), 'C' - comment
    FlagsToken := Copy( ControlToken, 2, Length(ControlToken)-1 );

    if MacroType = 'F' then // Process Office document File (MacroStr is File Name)
    begin
      FName := K_ExpandFileName( AMacroStr );
      FExt := UpperCase( ExtractFileExt( FName ) );

      if FExt = '.DOC' then //***** Process Word Document
      begin
        DefWordServer();
        ChildDoc := GCWordServer.Documents.Add( Template:=FName );

        if Pos( 'M', FlagsToken ) >= 1 then // Macros should be processed
          ProcessMacros( ChildDoc );

        if Pos( 'C', FlagsToken ) >= 1 then // Copy ChildDoc to Clipboard
          ChildDoc.Range.Copy;

        //***** Close ChildDoc

        ChildDoc.Saved := True;
//        DebAddDocsInfo( '!!!Proc Macros After Saved := True:', 0 );

        // You shoud touch Word somehow between Copy and Close!!!
        // (Application.ProcessMessages(); // does not work!)

        N_s1 := GCWordServer.Documents.Item(1).Name;
        N_s2 := GCWordServer.Documents.Item(2).Name;
        ChildDoc.Close;
        ChildDoc := Unassigned();

        if Pos( 'B', FlagsToken ) >= 1 then // replace BookMark content by Clipboard content
        begin
          // without clearing BookMarkRange.Text Word on some computers
          // Pastes Picture BEFORE bookmark content (instaed of replacing it!)!
          BookMarkRange.Text := '';
          BookMarkRange.Paste();
        end;

        if Pos( 'E', FlagsToken ) >= 1 then // replace BookMark content by Empty string
          BookMarkRange.Text := ''

      end else if FExt = '.XLS' then //***** Process Excel Document
      begin
        DefExcelServer();
        ChildDoc := GCExcelServer.WorkBooks.Open( FName );
//        ProcessExcelMacros( AComp, ChildDoc );
//  N_T1.Start;
        Sheet1 := ChildDoc.Sheets.Item[1];
        SheetType := Sheet1.Type;

        if SheetType = xlWorksheet then // is a WorkSheet
          Sheet1.UsedRange.Copy
        else // is a Chart, not WorkSheet
          Sheet1.CopyPicture;

//  N_T1.SS( 'CopySheet' );
        ChildDoc.Saved := True;
        ChildDoc.Close;
        ChildDoc := Unassigned();

        ADoc.BookMarks.Item(1).Range.Paste;
      end;

    end else if MacroType = 'M' then // Process Macros (SPL code) in MacroStr
    begin
      ResStr := ProcessOneL1Macro( AMacroStr );

      if Length(FlagsToken) >= 1 then
      begin
        if FlagsToken[1] = 'B' then // replace BookMark content by Clipboard content
        begin
          // without clearing BookMarkRange.Text Word on some computers
          // Pastes Picture BEFORE bookmark content (instaed of replacing it!)!
          BookMarkRange.Text := '';
//          BookMarkRange.Text := '1234' + AComp.ObjName;
//          BookMarkRange.Copy;
//          BookMarkRange.Paste;
          BookMarkRange.PasteSpecial( IconIndex:=1, Link:=False );
        end else if FlagsToken[1] = 'E' then // replace BookMark content by Empty string
          BookMarkRange.Text := ''
        else if FlagsToken[1] = 'T' then // replace BookMark content by _ResStr SPL variable
          BookMarkRange.Text := ResStr;
      end; // if Length(FlagsToken) >= 1 then
    end; // else -  Process Macros (SPL code) in MacroStr

    end; // with NGCont do
  end; // procedure ProcessOneMacro( AMacroStr: string ); // local

begin //******************************* TN_UDWordFragm.ProcessMacros main body
  PRCompD := PDP();

  with NGCont, PRCompD^.CWordFragm do
  begin
//  N_T1.Start;
  if wffSkipSPLMacros in WFFlags then Exit; // Skip Processing

  BMNames := TStringlist.Create();
  NumBookMarks := ADoc.BookMarks.Count;
  GCWSCurDoc := ADoc;

  SavedShowHiddenText := GCWSCurDoc.ActiveWindow.View.ShowHiddenText;
  GCWSCurDoc.ActiveWindow.View.ShowHiddenText := True;
//  N_s := GCWSCurDoc.Name; // debug

  for i := NumBookMarks downto 1 do // along all BookMarks from bottom up
  begin
    BookMark := ADoc.BookMarks.Item(i);
    BookMarkName := UpperCase( BookMark.Name );
    BookMarkRange := BookMark.Range;

    if Pos( 'MACRO', BookMarkName ) = 1 then // BookMark itself is a Macro
    begin
      ProcessOneMacro( N_PrepSPLCode( BookMarkRange.Text ) );
    end else if Pos( 'AUTO_', BookMarkName ) = 1 then // Save Bookmark Name to rename later
    begin
      BMNames.Add( BookMarkName );
    end else // Macros are in footnotes
    begin
      BMFootnotes := BookMarkRange.Footnotes;
      NumMacros := BMFootnotes.Count;

      if NumMacros >= 1 then // process all macros in Current BookMark
        for j := 1 to NumMacros do // along all macros in BookMark
          ProcessOneMacro( N_PrepSPLCode( BMFootnotes.Item(j).Range.Text ) );
    end;

  end; // for i := NumBookMarks downto 1 do // along all BookMarks from bottom up

  for i := 0 to BMNames.Count-1 do // along all BookMarks to rename
  begin
    CurName := BMNames[i];
    BookMarkRange := ADoc.BookMarks.Item( CurName ).Range;
    NewName := Copy( CurName, 6, Length(CurName)-5 ) + IntToStr(GCPDCounter);
    ADoc.BookMarks.Add( NewName, BookMarkRange ); // Add should be before Delete ?
    ADoc.BookMarks.Item( CurName ).Delete;
  end; // for i := 0 to BMNames.Count-1 do // along all BookMarks to rename

  if not SavedShowHiddenText then
    GCWSCurDoc.ActiveWindow.View.ShowHiddenText := False;

  BMNames.Free;
  GCWSCurDoc    := Unassigned();
  GCCurWTable := Unassigned(); // (may be set in macros)
//  N_T1.SS( 'WordProcessSPLMacros' );
  end; // with NGCont, PRCompD^.CWordFragm do

end; // procedure TN_UDWordFragm.ProcessMacros
}

//********** TN_UDExcelFragm class methods  **************

//********************************************** TN_UDExcelFragm.Create ***
//
constructor TN_UDExcelFragm.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDExcelFragmCI;
  CStatFlags := [csfForceExec];
  ImgInd := 91;
end; // end_of constructor TN_UDExcelFragm.Create

//********************************************* TN_UDExcelFragm.Destroy ***
//
destructor TN_UDExcelFragm.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDExcelFragm.Destroy

//********************************************** TN_UDExcelFragm.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDExcelFragm.PSP(): TN_PRExcelFragm;
begin
  Result := TN_PRExcelFragm(R.P());
end; // end_of function TN_UDExcelFragm.PSP

//********************************************** TN_UDExcelFragm.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDExcelFragm.PDP(): TN_PRExcelFragm;
begin
  if DynPar <> nil then Result := TN_PRExcelFragm(DynPar.P())
                   else Result := TN_PRExcelFragm(R.P());
end; // end_of function TN_UDExcelFragm.PDP

//******************************************* TN_UDExcelFragm.PISP ***
// return typed pointer to Individual Static ExcelFragm Params
//
function TN_UDExcelFragm.PISP(): TN_PCExcelFragm;
begin
  Result := @(TN_PRExcelFragm(R.P())^.CExcelFragm);
end; // function TN_UDExcelFragm.PISP

//******************************************* TN_UDExcelFragm.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic ExcelFragm Params
// otherwise return typed pointer to Individual Static ExcelFragm Params
//
function TN_UDExcelFragm.PIDP(): TN_PCExcelFragm;
begin
  if DynPar <> nil then
    Result := @(TN_PRExcelFragm(DynPar.P())^.CExcelFragm)
  else
    Result := @(TN_PRExcelFragm(R.P())^.CExcelFragm);
end; // function TN_UDExcelFragm.PIDP

//********************************************** TN_UDExcelFragm.PascalInit ***
// Init self
//
procedure TN_UDExcelFragm.PascalInit();
begin
  Inherited;
end; // procedure TN_UDExcelFragm.PascalInit

//************************************** TN_UDExcelFragm.BeforeAction ***
// Component method which will be called just before childrens ExecSubTree method
//
procedure TN_UDExcelFragm.BeforeAction();
var
  FName: string;
  SelfDoc: Variant;

  procedure CreateSelfDoc(); // local
  // Create New Excel Document(Workbook), based on Self (as template)
  var
    DataSize: integer;
    FExt: string;
    TempFileCreated: boolean;
    FStream: TFileStream;
  begin
    with NGCont, PDP()^.CExcelFragm do
    begin

    TempFileCreated := False;

    if FName = '' then // No FileName, create File by EFDocData if any
    begin
      DataSize := EFDocData.ALength();

      if DataSize = 0 then // No EFDocData
      begin
        SelfDoc := GCExcelServer.WorkBooks.Add(); // SelfDoc is New Empty Doc
        Exit; // all done
      end else // DataSize > 0, EFDocData is not empty, create Temporary file
      begin
        TempFileCreated := True;
        FExt := '.xls';
        if effXMLContent in EFFlags then FExt := '.xml';
        FName := 'C:\_Tmp_Excel_Doc_' + FExt;

        FStream := TFileStream.Create( FName, fmCreate );
        FStream.Write( EFDocData.P()^, DataSize );
        FStream.Free;
      end; // else // EFDocData is not empty

    end; // if FName = '' then // No FileName, create File by EFDocData if any

    SelfDoc := GCExcelServer.WorkBooks.Add( Template:=FName );
    if TempFileCreated then DeleteFile( FName );

    end; // with NGCont, PDP()^.CExcelFragm do
  end; // procedure CreateSelfDoc(); // local

begin //************************** main body of TN_UDExcelFragm.BeforeAction();
  with NGCont, PDP()^.CExcelFragm do
  begin
    N_s := ObjName; // debug
    Inc( GCPDCounter );
    FName := K_ExpandFileName( EFDocFName );

    if (FName <> '') and not K_VFileExists( FName ) then
    begin
      GCShowString( 'File not found: ' + FName );
      Exit;
    end;

    if crtfRootComp in CRTFlags then //************************* Root Component
    begin
      CreateSelfDoc();
      GCESMainDoc := SelfDoc;
      SelfDoc := Unassigned();
      ProcessExcelMacros( Self, GCESMainDoc );
    end else //********************************************* Not Root Component
    begin
      CreateSelfDoc();
//      ProcessExcelMacros( Self, SelfDoc );
    end; // else //*** Not Root Component

  end; // NGCont, PDP()^.CExcelFragm do "
end; // end_of procedure TN_UDExcelFragm.BeforeAction

{//******************* Base Component Pattern (implementation)
//********** TN_UDBCPattern class methods  **************

//********************************************** TN_UDBCPattern.Create ***
//
constructor TN_UDBCPattern.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDBCPatternCI;
  ImgInd := 00;
end; // end_of constructor TN_UDBCPattern.Create

//********************************************* TN_UDBCPattern.Destroy ***
//
destructor TN_UDBCPattern.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDBCPattern.Destroy

//********************************************** TN_UDBCPattern.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDBCPattern.PSP(): TN_PRBCPattern;
begin
  Result := TN_PRBCPattern(R.P());
end; // end_of function TN_UDBCPattern.PSP

//********************************************** TN_UDBCPattern.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDBCPattern.PDP(): TN_PRBCPattern;
begin
  if DynPar <> nil then Result := TN_PRBCPattern(DynPar.P())
                   else Result := TN_PRBCPattern(R.P());
end; // end_of function TN_UDBCPattern.PDP

//******************************************* TN_UDBCPattern.PISP ***
// return typed pointer to Individual Static BCPattern Params
//
function TN_UDBCPattern.PISP(): TN_PCBCPattern;
begin
  Result := @(TN_PRBCPattern(R.P())^.CBCPattern);
end; // function TN_UDBCPattern.PISP

//******************************************* TN_UDBCPattern.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic BCPattern Params
// otherwise return typed pointer to Individual Static BCPattern Params
//
function TN_UDBCPattern.PIDP(): TN_PCBCPattern;
begin
  if DynPar <> nil then
    Result := @(TN_PRBCPattern(DynPar.P())^.CBCPattern)
  else
    Result := @(TN_PRBCPattern(R.P())^.CBCPattern);
end; // function TN_UDBCPattern.PIDP

//********************************************** TN_UDBCPattern.PascalInit ***
// Init self
//
procedure TN_UDBCPattern.PascalInit();
var
  PRCompS: TN_PRBCPattern;
begin
  Inherited;
  PRCompS := PSP();
  with PRCompS^, PRCompS^.CBCPattern do
  begin

  end;
end; // procedure TN_UDBCPattern.PascalInit

//************************************** TN_UDBCPattern.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDBCPattern.BeforeAction();
var
  PRCompD: TN_PRBCPattern;
begin

//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with PRCompD^, PRCompD^.CBCPattern do
  begin

  end; // PRCompD^, PRCompD^.CBCPattern do
end; // end_of procedure TN_UDBCPattern.BeforeAction

} //******************* End of New Component Pattern

//***********************  TN_WordDoc Class  ***************************

//***************************************************** TN_WordDoc.Create() ***
//
constructor TN_WordDoc.Create;
begin
  WDGCont.Free;
  WDGCont := TN_GlobCont.Create();
end; // constructor TN_WordDoc.Create

//****************************************************** TN_WordDoc.Destroy ***
//
destructor TN_WordDoc.Destroy;
begin
  WDGCont.Free;
  inherited;
end; // destructor TN_WordDoc.Destroy

//********************************************* TN_WordDoc.StartCreating(2) ***
// Start creating Document using given ARootComp and Pointer to Export Params
//
// ARootComp   - Root WordFragm (should be of TN_UDWordFragm type)
// APExpParams - Pointer to Export Params
//
procedure TN_WordDoc.StartCreating( ARootComp: TN_UDBase; APExpParams: TN_PExpParams );
var
  i: integer;
begin
  Assert( ARootComp is TN_UDWordFragm, 'Not WordFragm!' );
  TN_UDCompBase(ARootComp).DynParent := nil; // set "Root Component" flag
  WDGCont.PrepForExport( ARootComp, APExpParams );
  if WDGCont.GCPrepForExportFailed then Exit;

  WDGCont.ExecuteComp( ARootComp, [cifRootComp] );
  WDGCont.GetWSInfo( 1 );
  for i := 0 to N_InfoSL.Count-1 do
    K_InfoWatch.AddInfoLine( N_InfoSL[i], K_msInfo );

end; // procedure TN_WordDoc.StartCreating(2)

//********************************************* TN_WordDoc.StartCreating(3) ***
// Start creating Document using given ARootComp, AFName and AEPExecFlags
//
// ARootComp    - Root WordFragm (should be of TN_UDWordFragm type)
// AFName       - Resulting Document FileName
// AEPExecFlags - ExportParams Execute Flags
//
procedure TN_WordDoc.StartCreating( ARootComp: TN_UDBase; AFName: string;
                                               AEPExecFlags : TN_EPExecFlags );
var
  ExpParams: TN_ExpParams;
begin
  //***** Prepare ExpParams
  FillChar( ExpParams, SizeOf(ExpParams), 0 );
  ExpParams.EPMainFName := AFName;
  ExpParams.EPExecFlags := AEPExecFlags;

  StartCreating( ARootComp, @ExpParams );
end; // procedure TN_WordDoc.StartCreating(3)

//************************************************* TN_WordDoc.AddComponent ***
// Add given AComp content to Word Document, beeing created
//
procedure TN_WordDoc.AddComponent( AComp: TN_UDBase );
begin
  if not (AComp is TN_UDCompBase) then Exit; // a precaution

  if (AComp is TN_UDWordFragm) or (AComp is TN_UDAction) then
    WDGCont.ExecuteComp( AComp, [] ) // Add Word Fragment
  else if AComp is TN_UDCompBase then
  with TN_UDCompBase(AComp) do
  begin
    NGCont := WDGCont;
    ExecInNewGCont([cifSeparateGCont]); // Create Clipboard content and add it Word Doc
  end; // if AComp is TN_UDCompBase then

{ // new var
  with TN_UDCompBase(AComp) do
  begin

    if cbfNewExpPar in PDP()^.CCompBase.CBFlags1 then // Exec in New GCont (some image)
    begin
      NGCont := WDGCont;
      ExecInNewGCont([cifSeparateGCont]); // Create Clipboard or File content and add it Word Doc
    end else // Exec in current GCont TN_UDWordFragm or TN_UDAction
      WDGCont.ExecuteComp( AComp, [] ); // Add Word Fragment or Word Table

  end; // with TN_UDCompBase(AComp) do
}
end; // procedure TN_WordDoc.AddComponent

//*********************************************** TN_WordDoc.FinishCreating ***
//
procedure TN_WordDoc.FinishCreating( );
begin
  WDGCont.FinishExport();
end; // procedure TN_WordDoc.FinishCreating



//****************** Global procedures **********************


//******************************************************** N_RegCreatorProc ***
// Register given AnCreatorProc (is called from TN_UDCreator) under given AProcName
//
procedure N_RegCreatorProc( AProcName: string; AnCreatorProc: TN_CreatorProc );
var
  WW : TObject;
begin
  TN_CreatorProc(WW) := AnCreatorProc;
  K_RegListObject( TStrings(N_CreatorProcs), AProcName, WW );
end; //*** end of procedure N_RegCreatorProc

//***************************************************** N_CreatorJustCreate ***
// Just Create new UObj
// (for using in TN_UDCreator under Proc Name "JustCreate")
//
procedure N_CreatorJustCreate( APParams: TN_PCCreator; AP1, AP2: Pointer );
var
  UDCreatorComp: TN_UDCreator;
begin
  UDCreatorComp := TN_UDCreator(AP1^);
  N_p := @UDCreatorComp; // to avoid warning

  with APParams^, UDCreatorComp do
  begin
    CreateNewUObj(); // UDCreatorComp method
  end; // with APParams^, UDCreatorComp do
end; //*** end of procedure N_CreatorJustCreate

//******************************************************* N_SetIteratorData ***
// Set Iterator Data (Index and LastIteration flag) for given AIterIndName
//
procedure N_SetIteratorData( AIterIndName: string; AIterIndex: integer;
                                                   ALastIteration: boolean );
var
  IntFlag: integer;
  UPRealName: string;
begin
  if AIterIndex = N_NotAnInteger then Exit; // a precaution

  UPRealName := '_ii_' + AIterIndName; // Real Iterator Index User Param Name
  N_GlobUserParams.CSetSUserParInt( UPRealName, 'Iterator Index', AIterIndex );

  UPRealName := '_li_' + AIterIndName; // Real LastIteration Flag User Param Name
  IntFlag := integer(ALastIteration);
  N_GlobUserParams.CSetSUserParInt( UPRealName, 'LastIteration Flag', IntFlag );
end; //*** end of procedure N_SetIteratorData

//******************************************************* N_GetIteratorData ***
// Get Iterator Data (Index and LastIteration flag) by given AIterIndName
//
procedure N_GetIteratorData( AIterIndName: string; out AIterIndex: integer;
                                                   out ALastIteration: boolean );
var
  IntFlag: integer;
  UPRealName: string;
begin
  UPRealName := '_ii_' + AIterIndName; // Real Iterator Index User Param Name
  AIterIndex := N_GlobUserParams.GetDUserParInt( UPRealName );
  if AIterIndex = N_NotAnInteger then
    AIterIndex := -1; // to simpliy checking code

  UPRealName := '_li_' + AIterIndName; // Real LastIteration Flag User Param Name
  IntFlag := N_GlobUserParams.GetDUserParInt( UPRealName );
  ALastIteration := (IntFlag = 0) or (IntFlag = N_NotAnInteger);
end; //*** end of procedure N_GetIteratorData

//***************************************************** N_GetMVTASPLVectors ***
// Get elems of given SPL Array of Strings into given AResSL TStringList
// AResSL elems should be ordered by Rows (first elemes of all Vectors, second
// elems and so on)
//
// ASPLUnitName  - SPL Unit where Vectors are difined as global variables
// AVectorsNames - Array of Vectors (global variables) Names
// AResSL        - Resulting StringList with Vectors elems
// AVSize        - Size of all Vectors (on output)
//
procedure N_GetMVTASPLVectors( ASPLUnitName: string; AVectorsNames: TN_SArray;
                                      AResSL: TStringList; out AVSize: integer );
var
  i, NumVectors, VectorSize: integer;
begin
  NumVectors := Length( AVectorsNames );
  VectorSize := 3;

  for i := 1 to NumVectors*VectorSize do
    AResSL.Add( 'Elem' + IntToStr(i) );

  AVSize := VectorSize;
  { Accessesing SPL global vars pattern:
  UDRGlobData: TK_UDRArray;
  PField: Pointer;
  FieldTCode: TK_ExprExtType;

  UDRGlobData := SPLUnit.GetGlobalData();
  N_GetRAFieldInfo( UDRGlobData.R, '_1UPComp', FieldTCode, PField );
  if PField <> nil then
    TN_PUDBase(PField)^ := Self;
  }
end; //*** end of procedure N_GetMVTASPLVectors

//************************************************* N_CrCreateLinHist_2Page ***
// Create One LinHist_2 Page
// (for using in TN_UDCreator under Proc Name "LinHist_2Page")
//
procedure N_CrCreateLinHist_2Page( APParams: TN_PCCreator; AP1, AP2: Pointer );
var
  UDCreatorComp: TN_UDCreator;
begin
  UDCreatorComp := TN_UDCreator(AP1^);
  N_p := @UDCreatorComp; // to avoid warning

  with APParams^, UDCreatorComp do
  begin
    CreateNewUObj(); // UDCreatorComp method
  end; // with APParams^, UDCreatorComp do
end; //*** end of procedure N_CrCreateLinHist_2Page


Initialization
//  K_RegRAFEditor( 'NRAFANLCEditor', TN_RAFANLCEditor );

  N_ClassRefArray[N_UDQuery1CI]     := TN_UDQuery1;
  N_ClassTagArray[N_UDQuery1CI]     := 'Query1';

  N_ClassRefArray[N_UDIteratorCI]   := TN_UDIterator;
  N_ClassTagArray[N_UDIteratorCI]   := 'Iterator';

//  N_ClassRefArray[N_UDCreatorCI]    := TN_UDCreator;
//  N_ClassTagArray[N_UDCreatorCI]    := 'Creator';

  N_ClassRefArray[N_UDNonLinConvCI] := TN_UDNonLinConv;
  N_ClassTagArray[N_UDNonLinConvCI] := 'NonLinConv';

  N_ClassRefArray[N_UDDynPictCreatorCI] := TN_UDDynPictCreator;
  N_ClassTagArray[N_UDDynPictCreatorCI] := 'DynPictCreator';

  N_ClassRefArray[N_UDCalcUParamsCI] := TN_UDCalcUParams;
  N_ClassTagArray[N_UDCalcUParamsCI] := 'CalcUParams';

  N_ClassRefArray[N_UDTextFragmCI]   := TN_UDTextFragm;
  N_ClassTagArray[N_UDTextFragmCI]   := 'TextFragm';

  N_ClassRefArray[N_UDWordFragmCI]   := TN_UDWordFragm;
  N_ClassTagArray[N_UDWordFragmCI]   := 'WordFragm';

  N_ClassRefArray[N_UDExcelFragmCI]  := TN_UDExcelFragm;
  N_ClassTagArray[N_UDExcelFragmCI]  := 'ExcelFragm';

{ //******* Class registration Pattern
  N_ClassRefArray[N_UDBCPatternCI] := TN_UDBCPattern;
  N_ClassTagArray[N_UDBCPatternCI] := 'BCPattern';
}
  N_RegCreatorProc( 'JustCreate',  N_CreatorJustCreate ); // Just Create new UObj

Finalization
  N_CreatorProcs.Free;

end.
