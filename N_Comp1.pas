unit N_Comp1;
// Visual Components set #1:
//   Panel_     TextBox_   ParaBox_   Legend_
//   NLegend_   Picture_   DIB_       File_
//   Action_    ExpComp_   DIBRect_   VCPattern_

// TN_RPanel        = packed record // TN_UDPanel RArray Record type
// TN_UDPanel       = class( TN_UDCompVis ) // Panel Component

// TN_CTextBoxFlags = set of ( tbfFixWidth, tbfFixHeight, tbfMultiFont );
// TN_CTextBox      = packed record // TextBox Params
// TN_RTextBox      = packed record // TN_UDTextBox RArray Record type
// TN_UDTextBox     = class( TN_UDCompVis ) // simple Text Box Component

// TN_CParaBoxFlags = set of ( tbfFixWidth, tbfFixHeight, tbfMultiFont );
// TN_CParaBox      = packed record // TextBlocks Params
// TN_RParaBox      = packed record // TN_UDParaBox RArray Record type
// TN_UDParaBox     = class( TN_UDCompVis ) // simple Text Box Component

// TN_CLegendFlags  = set of ( lfFixWidth, lfFixHeight );
// TN_CLegElemType  = ( letRect, letHLine );
// TN_CLegElemPar   = packed record // One legend Element Params
// TN_CLegSetElemes = packed record // Set Legend Elements
// TN_CLegend       = packed record // Legend Component Params
// TN_RLegend       = packed record // TN_UDLegend RArray Record type
// TN_UDLegend      = class( TN_UDCompVis ) // Legend Component

// TN_CPictureType  = ( cptNotDef, cptFile, cptLib, cptMem );
// TN_CPicture      = packed record // Picture Component Params
// TN_RPicture      = packed record // TN_UDPicture RArray Record type
// TN_UDPicture     = class( TN_UDCompVis ) // Picture Component

// TN_UDDIBFlags = Set Of ( uddfUseFile,   uddfUseBArray, ...
// TN_CDIB   = packed record // DIB Component Individual Params
// TN_RDIB   = packed record // TN_UDDIB RArray Record type
// TN_UDDIB  = class( TN_UDCompVis ) // DIB Component

// TN_UDDIBRectFlags = Set Of ( uddrfEllipseMask, uddrfDynXLAT );
// TN_CDIBRect  = packed record // DIBRect Component Individual Params
// TN_RDIBRect  = packed record // TN_UDDIBRect RArray Record type
// TN_UDDIBRect = class( TN_UDCompVis ) // DIBRect Component

// TN_UDFileFlags = Set Of ( udffFileOwner, udffFileFullName, udffCompress );
// TN_CFile  = packed record // File Component Individual Params
// TN_RFile  = packed record // TN_UDFile RArray Record type
// TN_UDFile = class( TN_UDCompVis ) // File Component

// TN_CAction       = packed record // Action Component Individual Params
// TN_RAction       = packed record // TN_UDAction RArray Record type
// TN_UDAction      = class( TN_UDCompVis ) // Action Component

// TN_ExpParFlags = set of ( epfExpParams, epfCompCoords );
// TN_CExpComp    = packed record // ExpComp Component Individual Params
// TN_RExpComp    = packed record // TN_UDExpComp RArray Record type
// TN_UDExpComp   = class( TN_UDCompBase ) // ExpComp Component

// TN_CVCPattern  = packed record // VCPattern Component Individual Params
// TN_RVCPattern  = packed record // TN_UDVCPattern RArray Record type
// TN_UDVCPattern = class( TN_UDCompVis ) // VCPattern Component

interface
uses // !!!!! GDIPAPI and Graphics contains different TPixelFormat
     //       (Enum in Graphics and integer in GDIPAPI), last module (Graphics) has a priority)
     Windows, GDIPAPI, Graphics, Classes, Controls, Contnrs, IniFiles, Types,
     K_Script1, K_UDT1, K_DCSpace, K_SBuf, K_STBuf,
     N_Types, N_Lib1, N_Gra0, N_Gra1, N_UDat4, N_Gra2,
     N_Lib2, N_CompCL, N_CompBase, N_GCont, N_UDCMap, N_BaseF;


//***************************  Panel Component  ************************

//*** TN_C1Panel type is defined in N_Types, because it is used in several units

type TN_RPanel = packed record // TN_UDPanel RArray Record type
  CSetParams: TK_RArray;      // Component's SetParams Array
  CCompBase:  TN_CCompBase;   // Component Base Params
  CLayout:    TK_RArray;      // Component Layout
  CCoords:    TN_CompCoords;  // Component Coords and Position
  CPanel:     TK_RArray;      // Component Panel (may be nil)
end; // type TN_RPanel = packed record
type TN_PRPanel = ^TN_RPanel;

type TN_UDPanel = class( TN_UDCompVis ) // Panel_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRPanel;
  function  PDP  (): TN_PRPanel;
  function  PISP (): TK_RArray;
  function  PIDP (): TK_RArray;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDPanel = class( TN_UDCompVis )


//***************************  TextBox Component  ************************

type TN_CTextBoxFlags = set of ( tbfFixWidth, tbfFixHeight,
                                 tbfCompPrefWidth, tbfCompPrefHeight,
                                 tbfMultiFont, tbfAutoFit, tbfVertical,
                                 tbfL1Macros, tbfTmp );

type TN_ImageParams = packed record // Image inside paragraph params
  IPStyle: string;                // HTML Style attributes
  IPClassName: string;            // HTML Class Name
  IPVisibleSizeXY: TN_MPointSize; // Visible Image X,Y Sizes
  IPPixelSizeXY: TPoint;          // Real Image X,Y Sizes in Pixels
  IPUDCompVis: TN_UDBase;         // Visual Tree Root (some TN_UDCompVis descendant)
end; // type TN_ImageParams = packed record
type TN_PImageParams = ^TN_ImageParams;

type TN_CTextBox = packed record // TextBox Component Individual Params
  TBFlags: TN_CTextBoxFlags; // (two bytes)
  TBReserved1: byte;  // for alignment
  TBReserved2: byte;
  TBPlainText: string;       // wrk TextBox content after Macro expansion (if needed) or original
  TBHorAlign:  TN_HVAlign;  // Horizontal Alignment
  TBVertAlign: TN_HVAlign; // Vertical Alignment
  TBFont: TN_UDLogFont;      // TextBox Font (for Plain TextBox)
  TBFSCoef: float;           // TextBox Font Scale Coef.
  TBLineExtraSpace: float;   // Additional vert. Space (in FonSize unis) between Lines
  TBTokenExtraSpace: float;  // Additional hor. Space (in FonSize unis) between Tokens
  TBIndent: float;           // First Line Indent (in LFH)
  TBTextColor: integer;      // Text Color
  TBPaddings:  TFRect;       // TextBox Paddings (LTRB - Left,Top,Right,Bottom)

  TBPrefWidth:  float;  // Preferable Width in LSU (NOT including margins and borders)
  TBPrefHeight: float;  // Preferable Height in LSU (NOT including margins and borders)
  TBAuxLine: TK_RArray; // nil or TN_AuxLine record
  TBMacroText: string;  // TextBox content with possible Macroses
  TBImages: TK_RArray;  // really RArray of TN_ImageParams ???
end; // type TN_CTextBox = packed record
type TN_PCTextBox = ^TN_CTextBox;

type TN_RTextBox = packed record // TN_UDTextBox RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase: TN_CCompBase;   // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CTextBox:   TN_CTextBox;   // Component Individual Params
end; // type TN_RTextBox = packed record
type TN_PRTextBox = ^TN_RTextBox;

type TN_UDTextBox = class( TN_UDCompVis ) // TextBox_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRTextBox;
  function  PDP  (): TN_PRTextBox;
  function  PISP (): TN_PCTextBox;
  function  PIDP (): TN_PCTextBox;
  procedure PascalInit   (); override;
  procedure BeforeAction (); override;
end; // type TN_UDTextBox = class( TN_UDCompVis )


//***************************  UDParaBox Component  ************************

// TN_CParaBox type is defined in N_CompCL

type TN_RParaBox = packed record // TN_UDParaBox RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CParaBox:   TN_CParaBox;   // Component Individual Params
end; // type TN_RParaBox = packed record
type TN_PRParaBox = ^TN_RParaBox;

type TN_UDParaBox = class( TN_UDCompVis ) // ParaBox_ (Text Blocks) Component
  SelfVR: TN_SRTextLayout; // Self Visual Representation

  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRParaBox;
  function  PDP  (): TN_PRParaBox;
  function  PISP (): TN_PCParaBox;
  function  PIDP (): TN_PCParaBox;
  procedure PascalInit   (); override;
  procedure PrepMacroPointers (); override;
  procedure BeforeAction (); override;
  procedure FillParaBox1 ( AText: string; ABasePoint: TFPoint; AFont: TObject; AFlags: integer );
  procedure FillParaBox2 ( ASizeX, ASizeY, AExtraY, AWidth2: float; ATextColor, ABack2Color: integer );
end; // type TN_UDParaBox = class( TN_UDCompVis )


type TN_TBVisualRepr = class( TObject ) // TextBox Visual Representation
  TBVRGCont:    TN_GlobCont;  // Global Context used for Visual Representation
  TBVRUObj:     TN_UDCompBase;// Source Component or nil if not given (usualy UDTextBox)
  TBVRWrkCTB:   TN_CTextBox;  // CTextBox record, used if TBVRUObj = nil
  TBVRPtr:      TN_PCTextBox; // Pointer to TBVRWrkCTB or to TBVRUObj params
  TBVRDataDir:  TN_UDBase;    // Data Dir where to create all needed Map Objects
  TBVRPrefXYSize:  TDPoint;   // Prefered (on input) Text Box X,Y Sizes in double Pixels
  TBVRRealXYSize:  TDPoint;   // Calculated Real (on output) Text Box X,Y Sizes in double Pixels
  ODLayout:  TN_OneDimLayout; // data for One Dimensional Layout algorithm

  constructor Create        ( AUDCompBase: TN_UDCompBase );
  destructor  Destroy; override;
  procedure CreateEmpyMapObjects ( ADataDir: TN_UDBase );
  procedure LayoutTokens         ();
  procedure FinishCreation       ( ULPixCoords: TPoint );
  procedure DrawTokens           ();
end; // type TN_TBVisualRepr = class( TObject )


//***************************  Old Legend Component  ************************

type TN_CLegendFlags = set of ( lfFixWidth, lfFixHeight, lfSameColHeights );

type TN_CLegElemType = ( letDefRect, letRect, letHLine );

type TN_CLegElemPar = packed record // One legend Element Params
  LEPType: TN_CLegElemType;
  LEPReserved1: byte;
  LEPReserved2: byte;
  LEPReserved3: byte;
end; // type TN_CLegElemPar = packed record
type TN_PCLegElemPar = ^TN_CLegElemPar;

type TN_CLegSetElemes = packed record // Set Legend Elements
  LSESrcUObj: TN_UDBase;
  LSEBegSrcInd: integer;
  LSEBegLegInd: integer;
  LSENumElemes: integer;
  LSELegElemPar: TN_CLegElemPar;
end; // type TN_CLegSetElemes = packed record
type TN_PCLegSetElemes = ^TN_CLegSetElemes;

type TN_CLegend = packed record // Legend Component Individual Params
  LegFlags: TN_CLegendFlags; // Legend Flags
  LegReserved1: byte;
  LegReserved2: byte;
  LegReserved3: byte;
  LegTextColor: integer; // Legend Text Color
  LegPaddings:  TFRect;  // Legend Paddings (Left, Top, Right, Bottom)

  LegHeaderText: string;
  LegHeaderFont: TN_UDLogFont;
  LegHFSCoef: float;         // LegHeader Font Scale Coef.
//  LegHeaderNFont: TObject;
  LegHeaderAlign: TN_HVAlign;
  LegHeaderBotPadding: float;

  LegFooterText: string;
  LegFooterFont: TN_UDLogFont;
  LegFFSCoef: float;         // LegFooter Font Scale Coef.
//  LegFooterNFont: TObject;
  LegFooterAlign: TN_HVAlign;
  LegFooterTopPadding: float;

  LegNumColumns: integer;     // Number of Legend Columns (=0 means Auto mode)
  LegNumRows:    integer;     // Number of Legend Rows (=0 means Auto mode)
  LegColumnsGap: float;       // Gap between columns along X axis

  LegElemTexts:  TK_RArray;   // Legend Elements Texts
  LegElemColors: TK_RArray;   // Legend Elements Colors (to fill SignRect)
  LegElemsFont: TN_UDLogFont; // Legend Text Elements Font
  LegEFSCoef: float;          // LegElements Font Scale Coef.
//  LegElemsNFont: TObject; // Legend Text Elements Font
  LegElemsYGap: float;        // Gap between Elements along Y axis

  LegSignWidth: float;      // Place for Sign Width in LSU?
  LegSignMinHeight: float;  // Place for Sign (and Elements) Min Height allowed
  LegSignRect: TFRect;      // in LSU, relative to Upper Left Sign Place corner
  LegSRBWidth: float;       // Sign Rect Border Width

  LegSignDashXPos: TFPoint; // Beg and End X coord of SignDash (in LLW?)
  LegSignDashWidth: float;  // Width of SignDash (in LLW?)

  LegElemsPar:  TK_RArray;  // Legend Elements Ext Params (RArray of TN_CLegElemPar)
  LegSetElems:  TK_RArray;  // Set Self Elems Info (RArray of TN_CLegSetElemes)
  LegElemsAttr: TK_RArray;  // Element Draw Attributes (RArray of RArray of TN_ContAttr)

  LegTmpNumElems: integer;    // Number of Elements (temporary)
  LegElemsVAlign: TN_HVAlign; // Elements Vertical Alignment
  LegPrefColsRows: TPoint;    // Preferable number of Elements Rows and Columns (0 means default value)
  LegSideSizeCoef: float;     // =100 means that Side Spaces are equal to Internal Spaces
  LegElemsMaxYGap: float;     // Max Gap between Elements along Y axis in LSU
  LegOneColNumElems: integer; // if NumElems <= LegOneColNumElems - One column Layout is preferable
end; // type TN_CLegend = packed record
type TN_PCLegend = ^TN_CLegend;

type TN_RLegend = packed record // TN_UDLegend RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CLegend:    TN_CLegend;    // Component Individual Params
end; // type TN_RLegend = packed record
type TN_PRLegend = ^TN_RLegend;

type TN_UDLegend = class( TN_UDCompVis ) // Legend_ (old) Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRLegend;
  function  PDP  (): TN_PRLegend;
  function  PISP (): TN_PCLegend;
  function  PIDP (): TN_PCLegend;
  procedure PascalInit    (); override;
  procedure BeforeAction  (); override;
  function  CreateVisRepr (): TN_UDBase;
  procedure SetElemsD     ();
end; // type TN_UDLegend = class( TN_UDCompVis )


//***************************  New Legend Component  ************************

type TN_CNLegend = packed record // New Legend Component Individual Params
  NLFlags: TN_CLegendFlags; // Legend Flags
  NLReserved1: byte;
  NLReserved2: byte;
  NLReserved3: byte;

  NLNumColumns: integer;     // Number of Legend Columns (=0 means Auto mode)
  NLNumRows:    integer;     // Number of Legend Rows (=0 means Auto mode)
  NLColumnsGap: float;       // Gap between columns along X axis

  NLElemTextColor: integer;  // Legend Elements Text Color
  NLElemTexts:  TK_RArray;   // Legend Elements Texts
  NLElemColors: TK_RArray;   // Legend Elements Colors (to fill SignRect)
  NLElemsNFont: TObject;     // Legend Text Elements Font
  NLElemsYGap:  float;       // Gap between Elements along Y axis

  NLSignWidth: float;      // Place for Sign Width in LSU?
  NLSignMinHeight: float;  // Place for Sign (and Elements) Min Height allowed
  NLSignRect: TFRect;      // in LSU, relative to Upper Left Sign Place corner
  NLSRBWidth: float;       // Sign Rect Border Width

  NLSignDashXPos: TFPoint; // Beg and End X coord of SignDash (in LLW?)
  NLSignDashWidth: float;  // Width of SignDash (in LLW?)

  NLElemsPar:  TK_RArray;  // Legend Elements Ext Params (RArray of TN_CLegElemPar)
  NLSetElems:  TK_RArray;  // Set Self Elems Info (RArray of TN_CLegSetElemes)
  NLElemsAttr: TK_RArray;  // Element Draw Attributes (RArray of RArray of TN_ContAttr)
end; // type TN_CNLegend = packed record
type TN_PCNLegend = ^TN_CNLegend;

type TN_RNLegend = packed record // TN_UDNLegend RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CNLegend:   TN_CNLegend;   // Component Individual Params
end; // type TN_RLegend = packed record
type TN_PRNLegend = ^TN_RNLegend;

type TN_UDNLegend = class( TN_UDCompVis ) // NLegend_ (New Legend) Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRNLegend;
  function  PDP  (): TN_PRNLegend;
  function  PISP (): TN_PCNLegend;
  function  PIDP (): TN_PCNLegend;
  procedure PascalInit    (); override;
  procedure BeforeAction  (); override;
  procedure SetElemsD     ();
end; // type TN_UDNLegend = class( TN_UDCompVis )


//***************************  Picture Component  ************************

type TN_CPictType = ( cptNotDef, cptFile, cptArchRaw, cptArchCompr );
// cptNotDef    - Picture Type is not Defined
// cptFile      - Picture never saved to Archive, always loaded from File
//                (Raster implemented as rtBArray or rtBMP)
// cptArchRaw   - Picture loaded from Archive and saved to Archive
//                (Raster implemented as rtRArray)
// cptArchCompr - Picture is loaded and saved to Archive as compressed by ZLib
//                bytes and should be decompressed to rtBArray before using

type TN_CPicture = packed record // Picture Component Individual Params
  PictType: TN_CPictType;     // Picture Type
  PictNotVisible: byte;       // Picture is not Visisble in VCTree if =1
  PictRaster: TN_Raster;      // Picture Raster
  PictFName: string;          // Picture File Name (for cptFile pictures)
  PictFragm: TRect;           // Picture Fragment to Draw
  PictScale: float;           // Picture Scale
  PictPlace: TN_PictPlace;    // Picture Place (rpUpperLeft,rpCenter,rpRepeat)
  PictDynColors: TK_UDRArray; // Dynamic Colors data vector
  PictCSS: TK_UDDCSSpace;     // Picture Palete CSS (for drawing Dynamic Colors)
  PictAsZLibRA: TObject;      // Compressed Picture Raster as RArray of byte
                              // (for cptArchCompr pictures)
end; // type TN_CPicture = packed record
type TN_PCPicture = ^TN_CPicture;

type TN_RPicture = packed record // TN_UDPicture RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CPicture:   TN_CPicture;   // Component Individual Params
end; // type TN_RPicture = packed record
type TN_PRPicture = ^TN_RPicture;

type TN_UDPicture = class( TN_UDCompVis ) // Picture_ Component
  PictRObj: TN_RasterObj;    // temporary obj for handling picture
  PictLoaded: boolean;       // Picture is already loaded from File (for cptFile pictures)
  PictDecompressed: boolean; // Picture is already decompressed (for cptArchCompr pictures)
  PictReIndVect: TN_IArray;  // ReIndexing vector for PictDynColors

  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRPicture;
  function  PDP  (): TN_PRPicture;
  function  PISP (): TN_PCPicture;
  function  PIDP (): TN_PCPicture;
  procedure PascalInit   (); override;
  procedure BeforeAction (); override;
  function  GetPixPictSize         (): TPoint;
  function  SetUCoordsByPixelSizeS (): TFRect;
  procedure LoadFromFile ();
  procedure Compress     ();
  procedure Decompress   ();
  procedure ChangeType   ( ANewType: TN_CPictType );
end; // type TN_UDPicture = class( TN_UDCompVis )


//***************************  DIB Component (Old and New)  **********

// Now UDDIB objects in old format are converted to new format while reading
// from archive (both in GetFieldsFromSBuf and GetFieldsFromText using ConvRDIBToRDIBN)
//
// Note: in SPL UDDIB new format TN_RDIBN record has CDIB field of TN_CDIBN type,
//       in Pascal this field has CDIBN name !!!

//***** Old DIB types (TN_RDIB, TN_CDIB, TN_UDDIBFlags):

type TN_UDDIBFlags = Set Of ( uddfUseFile,   uddfUseBArray,
                              uddfFileOwner, uddfFileFullName, uddfCompress,
                              uddUseCDIBURect );
// uddfUseFile      - Raster should be stored in Separate File (in CDIBFName)
// uddfUseBArray    - Raster should be stored in CDIBRaster RArray of Bytes
//                    (if (uddfUseFile=0) and (uddfUseBArray=0) use internal Place)
// uddfFileOwner    - Self is File Owner (File should be deleted in Self.Destroy) (used only in uddfUseFile mode)
// uddfFileFullName - CDIBFName is full File Name (not in ArchFiles Dir) (used only in uddfUseFile mode)
// uddfCompress     - Raster is Compressed by ZLib (now not implemented)
// uddUseCDIBURect  - use CDIBURect field (CompIntPixRect field would be used if not set)

type TN_CDIB = packed record // DIB Component Individual Params
  CDIBFlags:  TN_UDDIBFlags; // Raster Storing mode Flags
  CDIBReserved1: Byte; // for align
  CDIBReserved2: Byte;
  CDIBReserved3: Byte;
  CDIBFName:  string;    // Raster File Name (Full or inside ArchFiles Dir, used only in uddfUseFile mode))
  CDIBInfo:   string;    // Info String (BitsPerPix, Width x Height, Size), not used in Programs
  CDIBURect:  TFRect;    // Raster User Coords Rect
  CDIBTranspColor: integer; // Raster Transparent Color or -1
  CDIBBArray: TK_RArray; // RArray of Bytes with DIB data (used only in uddfUseBArray mode)
end; // type TN_CDIB = packed record
type TN_PCDIB = ^TN_CDIB;

type TN_RDIB = packed record // TN_UDDIB RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CDIB:       TN_CDIB;       // Component Individual Params
end; // type TN_RDIB = packed record
type TN_PRDIB = ^TN_RDIB;

//***** End of Old DIB types


//***** New DIB types (TN_RDIBN, TN_CDIBN, TN_UDDIBFlagsN, TN_UDDIBDataFormat):

// type TN_UDDIBDataFormat is in N_Types module because it depends upon a GDI+ enum

type TN_UDDIBFlagsN = Set Of (
  uddfnSkipSavingData, // Skip Saving DIBObj and UDData, should be used only with uddfnUseFile
  uddfnUseUDData,      // Use UDData field for Saving and Loading, otherwise plain DIBObj serialization will be used
  uddfnUseFile,        // Use CDIBFName File (instead of archive) for Saving and Loading (uddfnUseUDData should be set)
  uddfnIsFileOwner,    // Self is File Owner (CDIBFName File should be deleted in Self.Destroy)
  uddfnAutoCreateDIB,  // Always create DIBObj from CDIBFName File or from UDData in TN_UDDIB.GetFieldsFromxxx method
  uddfnAutoSaveToFile, // Always save UDData or DIBObj to CDIBFName File in TN_UDDIB.AddFieldsToxxx method
  uddfnFreeUDData,     // Free UDData field after Loading and creating DIBObj from UDData field
                       //                or after saving UDData field if DIBObj<>nil
  uddfnUseCDIBURect,   // Use CDIBURect field for drawing (CompIntPixRect field would be used if not set)
  uddfnReserved1       // force more than 8 members (force size of TN_UDDIBFlagsN to TWO bytes)
);

type TN_CDIBN = packed record // DIB Component Individual Params
  CDIBFlagsN:  TN_UDDIBFlagsN; // Raster Storing mode Flags (TWO bytes!)
  CDIBReserved1: Byte; // for align
  CDIBReserved2: Byte;
  CDIBFName:  string;    // Raster File Name (Full or inside ArchFiles Dir, used only in uddfUseFile mode))
  CDIBInfo:   string;    // Info String (BitsPerPix, Width x Height, Size), not used in Programs
  CDIBURect:  TFRect;    // Raster User Coords Rect
  CDIBTranspColor: integer; // >0 - given Transp Color, =-3 Use TranspColor=0, all other - no Transp Color
  CDIBBArray: TK_RArray; // Not used
  CDIBDataFormat: TN_UDDIBDataFormat; // UDData field Format while saving (not used while loading!)
  CDIBJPEGQuality: integer; // JPEG Quality (Compression level) from 1 to 100
  CDIBReserved4: string;
  CDIBReserved5: integer;
end; // type TN_CDIBN = packed record
type TN_PCDIBN = ^TN_CDIBN;

type TN_RDIBN = packed record // TN_UDDIB RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CDIBN:      TN_CDIBN;       // Component Individual Params
end; // type TN_RDIBN = packed record
type TN_PRDIBN = ^TN_RDIBN;

                                             //0123456789
const N_UDDataAddInfoSignature : AnsiString = 'ADDDIBINFO';
type TN_UDDataAddInfo = packed record // TN_UDDIB UDData Additional Info
  UAISignature1 : array [0..9] of AnsiChar;
  UAINumBits    : Integer; // NumBits
  UAIFlags      : Integer; // Flags: bit01 = 1 Covertion to Grey is Needed
  UAIReserve    : Integer; // Reserved Space
  UAISignature2 : array [0..9] of AnsiChar;
end;
type TN_PUDDataAddInfo = ^TN_UDDataAddInfo;

type TN_UDDIB = class( TN_UDCompVis ) // DIB_ Component
  DIBObj: TN_DIBObj; // runtime object for handling raster
  UDData: TN_BArray; // runtime object for storing DIBObj in external format
  constructor Create;  override;
  destructor  Destroy; override;

    //************* TN_UDBase methods of TN_UDDIB
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( SBuf: TK_SerialTextBuf;
                                AShowFlags: Boolean = true ): Boolean; override;
  function  GetFieldsFromText ( SBuf: TK_SerialTextBuf ): Integer; override;
  procedure CopyFields        ( SrcObj: TN_UDBase ); override;

  function  PSP  (): TN_PRDIBN;
  function  PDP  (): TN_PRDIBN;
  function  PISP (): TN_PCDIBN;
  function  PIDP (): TN_PCDIBN;
  procedure PascalInit  (); override;
  procedure CalcParams1 (); override;
  procedure ConvRDIBToRDIBN ();
  function  PrepUDDataAddInfo( APAddInfo : TN_PUDDataAddInfo ) : Boolean;
  procedure CreateUDDataFromDIBObj();
  procedure BeforeAction (); override;
  function  ImageFullFileName (): string;
  procedure LoadDIBObj ( );
  procedure SaveDIBObj ();
  function  BufToDIBCoords ( ABufCoords: TPoint ): TPoint;
end; // type TN_UDDIB = class( TN_UDCompVis )

//***** End of New DIB types

//***************************  DIBRect Component  ************************

type TN_UDDIBRectFlags = Set Of (
  uddrfEllipseMask,  // Apply Ellipse Mask (otherwise use rect image)
  uddrfNewParams,    // Use new Params
  uddrfGreyDIB,      // Source DIB is Grey
  uddrfSkipBriCoGam, // in uddrmNoEffect mode just Draw without BriCoGam convertion
  uddrfUseCurBuf,    // in uddrmNoEffect mode Use current content of BufDIB
  uddrfEmboss,       // Emboss effect is Active
  uddrfColorize,     // Colorize effect is Active
  uddrfIsodensity    // Isodensity effect is Active
    );

type TN_UDDIBRectMode =(
  uddrmNoEffect, // No effect, just Scale and Draw
  uddrmNegate,   // Negate, Scale and Draw
  uddrmEqualize, // Simple Equalize effect
  uddrmColorize, // Colorize effect
  uddrmEmboss    // Emboss effect
    );

type TN_CDIBRect = packed record // DIBRect Component Individual Params
  CDRFlags:  TN_UDDIBRectFlags; // viewing method Flags
  CDRReserved1:  Byte; // for align
  CDRReserved2:  Byte;
  CDRReserved3:  Byte;
  CDRSrcUDDIB:   TN_UDDIB; // Source UDDIB component
  CDRSrcRect:    TRect;    // Pixel Rect in Source UDDIB component to show
  CDRXLATInts:  TK_RArray; // XLAT Table of integers or nil if not needed

  //*** New fields for new params
  CDRMode:   TN_UDDIBRectMode;  // Mode (effect)
  CDRReserved4:  Byte; // for align
  CDRReserved5:  Byte;
  CDRReserved6:  Byte;
  CDRSrcUDDIBPath: string; // Path to CDRSrcUDDIB
  CDRBriFactor: float; // Brightnes factor (from -100 to +100, see K_BCGImageXlatBuild)
  CDRCoFactor:  float; // Contrast  factor (from -100 to +100, see K_BCGImageXlatBuild)
  CDRGamFactor: float; // Gamma     factor (from -100 to +100, see K_BCGImageXlatBuild)
  CDREmbAngle:    float;   // Emboss Angle    (see CalcEmbossDIB)
  CDREmbCoef:     float;   // Emboss Coef     (see CalcEmbossDIB)
  CDREmbDepth:    integer; // Emboss Depth    (see CalcEmbossDIB)
  CDREmbBaseGrey: integer; // Emboss BaseGrey (see CalcEmbossDIB)

  CDRXLATClrz: TK_RArray; // XLAT Table of integers for Colorize or nil if not needed
end; // type TN_CDIBRect = packed record
type TN_PCDIBRect = ^TN_CDIBRect;

type TN_RDIBRect = packed record // TN_UDDIBRect RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CDIBRect:   TN_CDIBRect;   // Component Individual Params
end; // type TN_RDIBRect = packed record
type TN_PRDIBRect = ^TN_RDIBRect;

type TN_UDDIBRect = class( TN_UDCompVis ) // DIBRect_ Component
  XLATBufDIB: TN_DIBObj; // Buf DIBObj for XLAT convertion
  BufDIB:     TN_DIBObj; // Buf DIBObj for new params effects
  BufDIB2:    TN_DIBObj; // Buf DIBObj for new params effects
  TmpXLAT:    TN_IArray; // Temporary XLAT table for Equalize convertion

  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRDIBRect;
  function  PDP  (): TN_PRDIBRect;
  function  PISP (): TN_PCDIBRect;
  function  PIDP (): TN_PCDIBRect;
  procedure PascalInit   (); override;
  procedure BeforeAction (); override;
  procedure CalcSrcRect  ( ASrcDIBFRect: TFRect; ASrcMidFPoint: TFPoint;
                                                 ASrcPixSize: integer );
end; // type TN_UDDIBRect = class( TN_UDCompVis )


//***************************  File Component  ************************
//
// May be it should not be a Component, but just a UDRArray?
// It is the first Component with empty BeforeAction method!
// The differencese are:
// - the ability to use Settings while executing Self
// - possible additional actions (like load/unload) at Tree Initializing
//   or Finalizing steps
// - in future BeforeAction may load file in memory, now BeforeAction is empty

type TN_UDFileFlags = Set Of ( udffFileOwner, udffFileFullName, udffCompress );
// udffFileOwner    - Self is File Owner (File should be deleted in Self.Destroy)
// udffFileFullName - CFName is full File Name (not in ArchFiles Dir)
// udffCompress     - File is Compressed by ZLib (now not implemented)

type TN_CFile = packed record // File Component Individual Params
  CFFlags:  TN_UDFileFlags; // File Flags
  CFName:   string;         // File Name (Full or inside ArchFiles Dir)
end; // type TN_CFile = packed record
type TN_PCFile = ^TN_CFile;

type TN_RFile = packed record // TN_UDFile RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CFile:      TN_CFile;      // Component Individual Params
end; // type TN_RFile = packed record
type TN_PRFile = ^TN_RFile;

type TN_UDFile = class( TN_UDCompBase ) // File_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRFile;
  function  PDP  (): TN_PRFile;
  function  PISP (): TN_PCFile;
  function  PIDP (): TN_PCFile;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
  function  GetFullFileName(): string;
end; // type TN_UDFile = class( TN_UDCompBase )


//***************************  Action Component  ************************
// TN_CAction and TN_PCAction types defined in N_Lib2

type TN_ActionProcType = ( aptPrepRoot, aptBefore, aptAfter );

type TN_RAction = packed record // TN_UDAction RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CAction:    TN_CAction;    // Component Individual Params
end; // type TN_RAction = packed record
type TN_PRAction = ^TN_RAction;

type TN_UDAction = class( TN_UDCompVis ) // Action_ Component
  UDActObj1: TObject;
  UDActObj2: TObject;
  UDActionProcType: TN_ActionProcType;

  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRAction;
  function  PDP  (): TN_PRAction;
  function  PISP (): TN_PCAction;
  function  PIDP (): TN_PCAction;
  procedure PrepRootComp (); override;
  procedure BeforeAction (); override;
  procedure AfterAction  (); override;
end; // type TN_UDAction = class( TN_UDCompVis )


//***************************  ExpComp Component  ************************

type TN_ExpParFlags = set of ( epfExpParams, epfCompCoords );

type TN_CExpComp = packed record // ExpComp Component Individual Params
  ECExpParFlags: TN_ExpParFlags; // Export Params Flags
  ECReserved1: Byte;
  ECReserved2: Byte;
  ECReserved3: Byte;
  ECExpComp: TN_UDBase; // Component to Export
end; // type TN_CExpComp = packed record
type TN_PCExpComp = ^TN_CExpComp;

type TN_RExpComp = packed record // TN_UDExpComp RArray Record type
  CSetParams: TK_RArray;    // Component's SetParams Array
  CCompBase: TN_CCompBase;  // Component Base Params
  CLayout:   TK_RArray;     // Component Layout
  CCoords:   TN_CompCoords; // Component Coords and Position
  CPanel:    TK_RArray;     // Component Panel
  CExpComp:  TN_CExpComp;   // Component Individual Params
end; // type TN_RExpComp = packed record
type TN_PRExpComp = ^TN_RExpComp;

type TN_UDExpComp = class( TN_UDCompVis ) // ExpComp_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRExpComp;
  function  PDP  (): TN_PRExpComp;
  function  PISP (): TN_PCExpComp;
  function  PIDP (): TN_PCExpComp;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDExpComp = class( TN_UDCompVis )


{********* VCPattern (Visual and NonVisual Component Pattern) (see also in Implementation section)

      for Constructing New Component you need:
- copy comments lines (below) in beg file to interface section
- copy interface pattern (below) to interface section
- copy implementation pattern (after TN_UDExpComp.BeforeAction) to implementation section
- replace "VCPattern" by "xxx" (needed Component Name) in four file fragments

- replace TN_UDCompVis by UDCompBase if needed (if new Component is not visual)
- add new N_xxxCI definition to N_ClassRef unit
- add two new lines (15 lines below) in N_AVRInit unit (fill N_ClassRefArray and N_ClassTagArray)
- compile to check errors

- add new Component name in beg file (in names in first rows)
- correct formatting of new code
- if needed, add new Icon in Icons_Tree.bmp and reload ButtonsForm.IconsList
- assign ImageIndex and set it in Consrtuctor
- write new Component methods code (RArray type and methods)
- add new types to comments in file header if needed
- if not Visual component delete CLayout, CCoords, CPanel fields from TN_Rxxx struct!
- update N_Comps.spl by new RArray type fields
- add FormDescr new Component in N_FormDescrSPL
- add code for new Component to N_NewObjF
- add code for new Component to N_RaEditF

    Class registration Pattern (add it in N_AVRInit file):
  N_ClassRefArray[N_UDDIBRectCI] := TN_UDVCPattern;
  N_ClassTagArray[N_UDVCPatternCI] := 'VCPattern';

// TN_CVCPattern  = packed record // VCPattern Component Individual Params
// TN_RVCPattern  = packed record // TN_UDVCPattern RArray Record type
// TN_UDVCPattern = class( TN_UDCompVis ) // VCPattern Component


//***************************  VCPattern Component  ************************

type TN_CVCPattern = packed record // VCPattern Component Individual Params
  DummyName: integer;
end; // type TN_CVCPattern = packed record
type TN_PCVCPattern = ^TN_CVCPattern;

type TN_RVCPattern = packed record // TN_UDVCPattern RArray Record type
  CSetParams: TK_RArray;     // Component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // Component Layout
  CCoords:    TN_CompCoords; // Component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CVCPattern: TN_CVCPattern; // Component Individual Params
end; // type TN_RVCPattern = packed record
type TN_PRVCPattern = ^TN_RVCPattern;

type TN_UDVCPattern = class( TN_UDCompVis ) // VCPattern_ Component
  constructor Create; override;
  destructor  Destroy; override;
  function  PSP  (): TN_PRVCPattern;
  function  PDP  (): TN_PRVCPattern;
  function  PISP (): TN_PCVCPattern;
  function  PIDP (): TN_PCVCPattern;
  procedure PascalInit (); override;
  procedure BeforeAction (); override;
end; // type TN_UDVCPattern = class( TN_UDCompVis )

} //******************* End of New Visual Component Pattern


//****************** Global procedures **********************

// procedure N_DrawCPanel( ANGCont: TN_GlobCont; ACurPixRect: TRect; APCPanel: TK_RArray );
procedure N_SetSRTLByCParaBox ( ASRTL: TN_SRTextLayout;
                     APCParaBox: TN_PCParaBox; const AIntPixRect: TRect );
procedure N_InitCTextBox( APCTB: TN_PCTextBox; APrefWidth: float; ATextcolor: integer = 0;
                 AHorAlign: TN_HVAlign = hvaBeg; AAddLineSpacing: float = 0 );

procedure N_PrepCTextBox  ( ADataRoot: TN_UDBase; const ACTextBox: TN_CTextBox );
procedure N_CalcCTextBox( ADataRoot: TN_UDBase; AOCanv: TN_OCanvas;
           APCP: TK_RArray; APCTB: TN_PCTextBox; APLayout: TN_POneDimLayout;
                                                 out ANeededSizeLLW: TFPoint ); overload;
procedure N_CalcCTextBox  ( ADataRoot: TN_UDBase; AOCanv: TN_OCanvas;
            APCP: TN_PCPanel; APCTB: TN_PCTextBox; APLayout: TN_POneDimLayout;
                                                 out ANeededSizeLLW: TFPoint ); overload;
procedure N_FinTextBox ( ULUCoords: TFPoint; APCP: TK_RArray; APCTB: TN_PCTextBox;
                         AOCanv: TN_OCanvas; APLayout: TN_POneDimLayout;
                                    ATBLLWHeight: float; ADataRoot: TN_UDBase );
function  N_CreateUDTextBox( APRTextBox: TN_PRTextBox ): TN_UDTextBox;

procedure N_InitCLegend  ( APCLegend: TN_PCLegend );
procedure N_InitCNLegend ( APCNLegend: TN_PCNLegend );

function  N_CreateUDPicture( APictType: TN_CPictType;
                                ARObj: TN_RasterObj ): TN_UDPicture; overload;
function  N_CreateUDPicture( APictType: TN_CPictType; ARasterType: TN_RasterType;
                             AFileName: string = '';
                 ATranspColor: integer = N_EmptyColor ): TN_UDPicture; overload;

function  N_CreateUDDIB ( AUCoords: TFRect; AFlags: TN_UDDIBFlagsN; AFileName, AObjName: string ): TN_UDDIB; overload;
function  N_CreateUDDIB ( AImageList: TImageList; AImageIndex, ATranspColor: integer; AObjName: string ): TN_UDDIB; overload;

function  N_CreateUDPanel     ( AObjName: string ): TN_UDPanel; overload;
function  N_CreateUDPanel     ( AObjName: string; AUCoords: TFRect ): TN_UDPanel; overload;
function  N_CreateUDParaBox   ( AObjName: string; AUCoords: TFRect ): TN_UDParaBox;
function  N_CreateFullUDPanel ( AObjName: string ): TN_UDPanel;
function  N_PrepUDPanelInmm   ( AParentDir: TN_UDBase; AObjName: string; ABPX, ABPY, ASizeX, ASizeY: double ): TN_UDPanel;

function  N_CreateMapRoot   (): TN_UDPanel; overload;
function  N_CreateMapRoot2  ( AUCoords: TFRect; APixSize: TPoint;
                              ASRSizeAspType: TN_CompSAspectType; AObjName: string ): TN_UDCompVis;
function  N_PrepMapRoot     ( AMapParent: TN_UDBase; AMapObjName: string ): TN_UDPanel;
function  N_PrepParaBox     ( APatPB: TN_UDParaBox; AParent: TN_UDBase; AObjName: string ): TN_UDParaBox;
function  N_AddParaBox      ( APatPB: TN_UDParaBox; AParent: TN_UDBase; AObjName: string ): TN_UDParaBox;

var
  N_UDDIBRectStretchBltMode : Integer = COLORONCOLOR; // TN_UDDIBRect Stretch Blt Mode

implementation
uses Math, SysUtils, StrUtils, ZLib, // Variants, ComObj, ActiveX, Clipbrd,
     K_Gra0, K_CLib0, K_UDT2, K_RImage,
     N_Lib0, N_Gra3, N_ClassRef, N_ME1, N_Comp2; // , N_CM1;

//********** TN_UDPanel class methods  **************

//********************************************** TN_UDPanel.Create ***
//
constructor TN_UDPanel.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDPanelCI;
  ImgInd := 46;
end; // end_of constructor TN_UDPanel.Create

//********************************************* TN_UDPanel.Destroy ***
//
destructor TN_UDPanel.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDPanel.Destroy

//********************************************** TN_UDPanel.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDPanel.PSP(): TN_PRPanel;
begin
  Result := TN_PRPanel(R.P());
end; // end_of function TN_UDPanel.PSP

//********************************************** TN_UDPanel.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDPanel.PDP(): TN_PRPanel;
begin
  if DynPar <> nil then Result := TN_PRPanel(DynPar.P())
                   else Result := TN_PRPanel(R.P());
end; // end_of function TN_UDPanel.PDP

//******************************************* TN_UDPanel.PISP ***
// return typed pointer to Individual Static Panel Params
//
function TN_UDPanel.PISP(): TK_RArray;
begin
  Result := TN_PRPanel(R.P())^.CPanel;
end; // function TN_UDPanel.PISP

//******************************************* TN_UDPanel.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic Panel Params
// otherwise return typed pointer to Individual Static Panel Params
//
function TN_UDPanel.PIDP(): TK_RArray;
begin
  if DynPar <> nil then
    Result := TN_PRPanel(DynPar.P())^.CPanel
  else
    Result := TN_PRPanel(R.P())^.CPanel;
end; // function TN_UDPanel.PIDP

//********************************************** TN_UDPanel.PascalInit ***
// Init self
//
procedure TN_UDPanel.PascalInit();
begin
  Inherited;
end; // procedure TN_UDPanel.PascalInit

//************************************** TN_UDPanel.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDPanel.BeforeAction();
var
  i: integer;
  CurUObj: TN_UDBase;
  CurMLCObj: TN_UCObjLayer;
  NeededEnvRect: TFRect;
begin
  // CPanel was already drawn in ExecSubTree method

  N_s := ObjName; // debug
  N_CC := PCCD^; // debug

  with PCCD()^ do
  begin

  // Check if Self User Coords should be updated

  if (UCoordsType = cutGiven) and (CompUCoords.Left = N_NotAFloat) then
  begin

  // Update Self User Coords by MLCobj WEnvRect field of all child UDMapLayers

  NeededEnvRect.Left := N_NotAFloat;

  for i := 0 to DirHigh() do // along all Self Children
  begin
    CurUObj := DirChild( i );
    if not (CurUObj is TN_UDMapLayer) then Continue; // skip all except Map Layers

    CurMLCObj := TN_UDMapLayer(CurUObj).PIDP()^.MLCObj;
    CurMLCObj.CalcEnvRects(); // a precaution

    N_FRectOR( NeededEnvRect, CurMLCObj.WEnvRect );
  end; // for i := 0 to DirHigh() do // along all Self Children

  NeededEnvRect := N_RectScaleR( NeededEnvRect, 1.05, DPoint( 0.5, 0.5 ) );

  UCoordsType := cutGiven;
  CompUCoords := NeededEnvRect;
  SetCompUCoords();

  end; // if (UCoordsType = cutGiven) and (CompUCoords.Left = N_NotAFloat) then
  end; // with PCCD()^ do

end; // end_of procedure TN_UDPanel.BeforeAction


//********** TN_UDTextBox class methods  **************

//********************************************** TN_UDTextBox.Create ***
//
constructor TN_UDTextBox.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDTextBoxCI;
  CStatFlags := [csfCoords, csfNonCoords]; // can work in Both Visual and NonVisual modes
  ImgInd := 44;
end; // end_of constructor TN_UDTextBox.Create

//********************************************* TN_UDTextBox.Destroy ***
//
destructor TN_UDTextBox.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDTextBox.Destroy

//********************************************** TN_UDTextBox.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDTextBox.PSP(): TN_PRTextBox;
begin
  Result := TN_PRTextBox(R.P());
end; // end_of function TN_UDTextBox.PSP

//********************************************** TN_UDTextBox.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDTextBox.PDP(): TN_PRTextBox;
begin
  if DynPar <> nil then Result := TN_PRTextBox(DynPar.P())
                   else Result := TN_PRTextBox(R.P());
end; // end_of function TN_UDTextBox.PDP

//******************************************* TN_UDTextBox.PISP ***
// return typed pointer to Individual Static TextBox Params
//
function TN_UDTextBox.PISP(): TN_PCTextBox;
begin
  Result := @(TN_PRTextBox(R.P())^.CTextBox);
end; // function TN_UDTextBox.PISP

//******************************************* TN_UDTextBox.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic TextBox Params
// otherwise return typed pointer to Individual Static TextBox Params
//
function TN_UDTextBox.PIDP(): TN_PCTextBox;
begin
  if DynPar <> nil then
    Result := @(TN_PRTextBox(DynPar.P())^.CTextBox)
  else
    Result := @(TN_PRTextBox(R.P())^.CTextBox);
end; // function TN_UDTextBox.PIDP

//********************************************** TN_UDTextBox.PascalInit ***
// Init self
//
procedure TN_UDTextBox.PascalInit();
var
  PRCompS: TN_PRTextBox;
begin
  Inherited;
  PRCompS := PSP();
  N_InitCTextBox( @PRCompS^.CTextBox, 100 );
  with PRCompS^, PRCompS^.CTextBox do
  begin
    CCompBase.CBFlags1 := CCompBase.CBFlags1 + [cbfVariableSize];
    TBFlags := [tbfFixWidth, tbfFixHeight, tbfCompPrefWidth, tbfCompPrefHeight];
    TBAuxLine := K_RCreateByTypeName( 'TN_AuxLine', 1 ); // debug ?
  end;
end; // procedure TN_UDTextBox.PascalInit

//************************************** TN_UDTextBox.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDTextBox.BeforeAction();
var
  DataDir: TN_UDBase;
  PRCompD: TN_PRTextBox;
  TBVR: TN_TBVisualRepr;
begin
  PRCompD := PDP();
//  if (ObjName = 'NameTB') and (Owner.Owner.ObjName = 'Group_8') then  // debug
  if ObjName = 'Reg_1' then  // debug
    N_i := 1;

  with PRCompD^, PRCompD^.CTextBox, PCCD()^, NGCont do
  begin
//    if (TBMacroText TBPlainText <> '')
    ExpandMacrosBySPL( TBMacroText, 'TBProc', TBPlainText, tbfL1Macros in TBFlags );

    if GCTextMode then // Current Export mode is Text (HTML, SVG, ...) (not Image)
    begin
      GCOutSL.Add( '<p>' + TBPlainText + '</p>' );
      Exit; // all done
    end;

    //***** Here: Current Export mode is Image (not HTML)

    CompIntPixRect := NGCont.DrawCPanel( CPanel, CompOuterPixRect );
    SetCompUCoords();

    if tbfCompPrefWidth in TBFlags then
      TBPrefWidth  := N_RectWidth( CompIntPixRect ) / DstOCanv.CurLSUPixSize;

    if tbfCompPrefHeight in TBFlags then
      TBPrefHeight := N_RectHeight( CompIntPixRect ) / DstOCanv.CurLSUPixSize;

    // Create Self Visual Representation in DataDir

    DataDir := GetDataRoot( True );
    DataDir.ClassFlags := DataDir.ClassFlags or K_SkipSelfSaveBit;
    TBVR := TN_TBVisualRepr.Create( Self );

    with TBVR do
    begin

    CreateEmpyMapObjects( DataDir );
    LayoutTokens();

{ //******* AutoScaling is not implemented !!!
  CurDecrCoef: double;

    if (tbfAutoFit in TBFlags) then
    while True do // decrease Font Size by Font Scale Coef if needed
    begin
      if (NeededSizeLLW.X  <= TBPrefWidth) and
         (NeededSizeLLW.Y <= TBPrefHeight) then Break; // Scaling is not needed

      if TBPrefWidth  = 0 then TBPrefWidth  := NeededSizeLLW.X;
      if TBPrefHeight = 0 then TBPrefHeight := NeededSizeLLW.Y;

      CurDecrCoef := Max( NeededSizeLLW.X/TBPrefWidth, NeededSizeLLW.Y/TBPrefHeight );
      if CurDecrCoef > 1.2 then CurDecrCoef := Sqrt( CurDecrCoef );
      with PISP()^ do
        TBFSCoef := 0.95 * (TBFSCoef / CurDecrCoef);

      N_PrepCTextBox( DataDir, CTextBox );
      N_CalcCTextBox( DataDir, DstOCanv, CPanel,
                                        @CTextBox, @TBLayout, NeededSizeLLW );
    end; // while True do, if (tbfAutoFit in TBFlags) then
} //******* AutoScaling is not implemented !!!

    if not (tbfFixWidth in TBFlags) then // update Component Width
    begin
      // temporary variant, later check Component CoordsScope
      SRSize.X    := TBVRRealXYSize.X / PixPixSize.X; // convert to Src Pixels
      SRSizeXType := cstPixel;
    end;

    if not (tbfFixHeight in TBFlags) then // update Component Height
    begin
      // temporary variant, later check Component CoordsScope
      SRSize.Y    := TBVRRealXYSize.Y / PixPixSize.Y; // convert to Src Pixels
      SRSizeYType := cstPixel;
    end;

    //*** ReCalc Self CompIntPixRect for just calculated new Self Size
    SetCompUCoords();

    FinishCreation( CompIntPixRect.TopLeft );
    DrawTokens();
  end; // with TBVR do

  TBVR.Free;
  end; // with PRCompD^, PRCompD^.CTextBox, PCCD()^, NGCont do

  DrawAuxLine( PRCompD^.CTextBox.TBAuxLine ); // Draw AuxLine if needed

end; // end_of procedure TN_UDTextBox.BeforeAction


//********** TN_UDParaBox class methods  **************

//********************************************** TN_UDParaBox.Create ***
//
constructor TN_UDParaBox.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDParaBoxCI;
  CStatFlags := [csfCoords, csfNonCoords]; // can work in Both Visual and NonVisual modes
  ImgInd := 48;
end; // end_of constructor TN_UDParaBox.Create

//********************************************* TN_UDParaBox.Destroy ***
//
destructor TN_UDParaBox.Destroy;
begin
    // If OTBNFont as RArray should it be Freed???
    // If Font Handels in CPBTextBlocks should be deleted by Windows.DeleteObject( NFHandle ); ???

  SelfVR.Free;
  inherited Destroy;
end; // end_of destructor TN_UDParaBox.Destroy

//********************************************** TN_UDParaBox.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDParaBox.PSP(): TN_PRParaBox;
begin
  Result := TN_PRParaBox(R.P());
end; // end_of function TN_UDParaBox.PSP

//********************************************** TN_UDParaBox.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDParaBox.PDP(): TN_PRParaBox;
begin
  if DynPar <> nil then Result := TN_PRParaBox(DynPar.P())
                   else Result := TN_PRParaBox(R.P());
end; // end_of function TN_UDParaBox.PDP

//******************************************* TN_UDParaBox.PISP ***
// return typed pointer to Individual Static TextBlocks Params
//
function TN_UDParaBox.PISP(): TN_PCParaBox;
begin
  Result := @(TN_PRParaBox(R.P())^.CParaBox);
end; // function TN_UDParaBox.PISP

//******************************************* TN_UDParaBox.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic TextBlocks Params
// otherwise return typed pointer to Individual Static TextBlocks Params
//
function TN_UDParaBox.PIDP(): TN_PCParaBox;
begin
  if DynPar <> nil then
    Result := @(TN_PRParaBox(DynPar.P())^.CParaBox)
  else
    Result := @(TN_PRParaBox(R.P())^.CParaBox);
end; // function TN_UDParaBox.PIDP

//********************************************** TN_UDParaBox.PascalInit ***
// Init self
//
procedure TN_UDParaBox.PascalInit();
begin
  Inherited;

  // to prevent drawing CPanel in ExecSubTree method
  with PSP()^ do
    CCompBase.CBFlags1 := CCompBase.CBFlags1 + [cbfVariableSize];

end; // procedure TN_UDParaBox.PascalInit

//***************************************** TN_UDParaBox.PrepMacroPointers ***
// Prepare Pointers to all Self Strings, that can contain Macroses
//
procedure TN_UDParaBox.PrepMacroPointers();
begin
  inherited;
  NGCont.AddTextBlocksMPtrs( PDP()^.CParaBox.CPBTextBlocks );
end; // end_of procedure TN_UDParaBox.PrepMacroPointers

//************************************** TN_UDParaBox.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDParaBox.BeforeAction();
var
  TBTypeCode: TK_ExprExtType;
  PRCompD: TN_PRParaBox;
  PSCPB: TN_PCParaBox;
begin
//  if (ObjName = 'NameTB') and (Owner.Owner.ObjName = 'Group_8') then  // debug
//  if ObjName = 'Reg_1' then  // debug
//    N_i := 1;

  if ObjName = 'Reg_1' then  // debug
  begin


  end;


  PRCompD := PDP();
  with PRCompD^, PRCompD^.CParaBox, NGCont do
  begin
    if GCMSWordMode then // Export To MS Word
    begin
      TextBlocksToMSWord( CPBTextBlocks );
    end else if GCMSExcelMode then // Export To MS Excel
    begin
      TextBlocksToMSExcel( CPBTextBlocks );
    end else if GCCoordsMode then // Coords Export mode
    begin
      { temporary not implemented
          if GCTextMode then // Text (HTML, SVG, ...) Export mode
          begin
            if not (pbfSkipTag in CPBFlags) then
              GCOutSL.Add( '<p ' + CCompBase.CBTextAttr + '>' );

            TextBlocksToHTML( CPBTextBlocks );

            if not (pbfSkipTag in CPBFlags) then GCOutSL.Add( '</p>' );
          end; // if GCTextMode then // Text (HTML, SVG, ...) Export mode
      }

      if SelfVR = nil then
        SelfVR := TN_SRTextLayout.Create( DstOCanv )
      else
        SelfVR.SRTLInit( DstOCanv );

      CompIntPixRect := GetCPanelIntRect( CPanel, CompOuterPixRect );

//      if CPBNewSrcHTML <> '' then // check if convertion of HTML text to CPBTextBlocks is needed
//      begin                       // Static Params are used !!!
        PSCPB := @(PSP()^.CParaBox);
        if PSCPB^.CPBNewSrcHTML <> PSCPB^.CPBPrevSrcHTML then // HTML Text changed and
        begin                                      // should be converted to CPBTextBlocks
          PSCPB^.CPBPrevSrcHTML := PSCPB^.CPBNewSrcHTML; // to perform convertion only once

          N_ParseHTMLToTextBlocks( PSCPB^.CPBNewSrcHTML, PSCPB^.CPBTextBlocks,
                                   DstOCanv, K_CountUDRef );
          TBTypeCode := PSCPB^.CPBTextBlocks.GetArrayType();

          // copy Parsed Static CPBTextBlocks to Dyn Params
          K_MoveSPLData( PSCPB^.CPBTextBlocks, CParaBox.CPBTextBlocks,
                                TBTypeCode, [K_mdfCopyRArray, K_mdfFreeDest] );
        end; // if CPBNewSrcHTML <> CPBPrevSrcHTML then
//      end; // if CPBNewSrcHTML <> '' then // check if convertion HTML text to CPBTextBlocks is needed

      N_SetSRTLByCParaBox( SelfVR, @CParaBox, CompIntPixRect );

      with SelfVR do
      begin
        //***** update CompOuterPixRect by difference between SRTL Pref and Real Size

        Inc( CompOuterPixRect.Right,  SRTLRealSize.X - SRTLPrefSize.X );
        Inc( CompOuterPixRect.Bottom, SRTLRealSize.Y - SRTLPrefSize.Y );

        CompIntPixRect := NGCont.DrawCPanel( CPanel, CompOuterPixRect );

        if cbfDoClipping in CCompBase.CBFlags1 then // set new PClipRect
          SetNewPClipRect( CompIntPixRect );

        SetCompUCoords();

        //***** SelfVR.SRTLTextRects array is OK, Draw it

        DrawTextRects( @SRTLTextRects[0], SRTLFreeTRInd,
                 TN_POneTextBlock(CPBTextBlocks.P(0)), CompIntPixRect.TopLeft );

      end; // with SelfVR do
    end; // if GCCoordsMode then // Coords Export mode
  end; // with PIDP()^, NGCont do

end; // end_of procedure TN_UDParaBox.BeforeAction

//*********************************************** TN_UDParaBox.FillParaBox1 ***
// Fill Self by given Params, variant #1
//
//     Parameters
// AText      - given TextBlock content (OTBMText field value)
// ABasePoint - given BasePoint of Resulting TN_UDParaBox (in Percents or in User Coords, see AFlags)
// AFont      - given Font ( TN_UDNFont or RArray of TN_PNFont type) used in TextBlock
// AFlags     - several creation Flags:
//#F
//              Bit0=0 - ABasePoint in Percents, Bit0=1 - ABasePoint in User Coords
//#/F
//
// First TextBlock is filled, all others are deleted
//
procedure TN_UDParaBox.FillParaBox1( AText: string; ABasePoint: TFPoint; AFont: TObject; AFlags: integer );
begin
  //***** Set Base Point Coords

  with PCCS()^ do
  begin
    if (AFlags and $01) = 0 then // ABasePoint in Percents
    begin
      BPXCoordsType := cbpPercent;
      BPYCoordsType := cbpPercent;
    end else // (AFlags and $01) = 1, ABasePoint in User Coords
    begin
      BPXCoordsType := cbpUser;
      BPYCoordsType := cbpUser;
    end;

    BPCoords := ABasePoint;

    if (AFlags and $02) <> 0 then // set BPPos to (0,0)
      BPPos := N_ZFPoint;
  end; // with PCCS()^ do

  with PISP()^ do
  begin
    CPBTextBlocks.ASetLength( 1 );

    with TN_POneTextBlock(CPBTextBlocks.P(0))^ do
    begin
      OTBMText := AText;
      K_SetVArrayField( OTBNFont, AFont );
    end; // with TN_POneTextBlock(CPBTextBlocks.P(0))^ do
  end; // with PISP()^ do

end; // end of procedure TN_UDParaBox.FillParaBox1

//*********************************************** TN_UDParaBox.FillParaBox2 ***
// Fill Self by given Params, variant #2
//
//     Parameters
// ASizeX      - Component Size in current units (usually LLW)
// AExtraY     - Extra Y space between lines in LSU
// AWidth2     - Back2 Color width in LLW
// ATextColor  - Text Color
// ABack2Color - Back2 Color
//
procedure TN_UDParaBox.FillParaBox2( ASizeX, ASizeY, AExtraY, AWidth2: float; ATextColor, ABack2Color: integer );
begin
  //***** Set Base Point Coords

  with PCCS()^ do
  begin
    SRSize.X := ASizeX;
    SRSize.Y := ASizeY;
  end; // with PCCS()^ do

  with PISP()^ do
  begin
    CPBExYSpace := AExtraY; // Extra Y-space (between Rows, in LSU)

    with TN_POneTextBlock(CPBTextBlocks.P(0))^ do
    begin
      OTBBack2Width := AWidth2;     // Text Background 2 Color Width in LLW
      OTBTextColor  := ATextColor;  // Text Foreground Color
      OTBBack2Color := ABack2Color; // Text Background 2 Color
//      OTBBack2Color := N_EmptyColor; // Text Background 2 Color
    end; // with TN_POneTextBlock(CPBTextBlocks.P(0))^ do
  end; // with PISP()^ do

end; // end of procedure TN_UDParaBox.FillParaBox2


//******************* TN_TBVisualRepr class methods  **************

//********************************************** TN_TBVisualRepr.Create ***
// Create Self and if AUDCompVis is UDTextBox initialize Self by Dynamic (if exists)
// or Static Params of given UDTextBox
//
constructor TN_TBVisualRepr.Create( AUDCompBase: TN_UDCompBase );
var
  PUDTextBox: TN_PRTextBox;
begin
  inherited Create();

  TBVRUObj := AUDCompBase;
  if AUDCompBase <> nil then
    TBVRGCont := AUDCompBase.NGCont;

  if AUDCompBase is TN_UDTextBox then // UDTextBox is given
  with TN_UDTextBox(AUDCompBase) do
  begin
    PUDTextBox := PDP();
    if PUDTextBox = nil then PUDTextBox := PSP();

    TBVRPtr := @(PUDTextBox^.CTextBox);
  end else // create new empty Wrk CTextBox ( AUDTextBox = nil )
  begin
    TBVRPtr := @TBVRWrkCTB;
  end;

  if TBVRGCont <> nil then // Set prferable Sizes in double Pixels
  with TBVRGCont.DstOCanv, TBVRPtr^ do
  begin
    TBVRPrefXYSize.X := TBPrefWidth  * CurLSUPixSize;
    TBVRPrefXYSize.Y := TBPrefHeight * CurLSUPixSize;
  end; // with TBVRGCont, TBVRPtr^ do, if TBVRGCont <> nil then

end; // end_of constructor TN_TBVisualRepr.Create

//********************************************* TN_TBVisualRepr.Destroy ***
//
destructor TN_TBVisualRepr.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_TBVisualRepr.Destroy

//*********************************** TN_TBVisualRepr.CreateEmpyMapObjects ***
// Clear given ADataDir and create all needed Empty Map Objects
// (MapLayers, CObjLayers and RArrays) in given ADataRoot:
//
// TBTokens  - UDRArray with all TextBox Tokens to draw
// TBTPoints - UDPoints with Tokens Base Points
// TBTFonts  - UDRArray with old Font references
// MTBTokens - UDMapLayer for drawing Tokens
//
procedure TN_TBVisualRepr.CreateEmpyMapObjects( ADataDir: TN_UDBase );
var
  TBTPoints: TN_UDPoints;
  MTBTokens: TN_UDMapLayer;
  TBTokens, TBTFonts: TK_UDRArray;
begin
  TBVRDataDir := ADataDir;
  with TBVRPtr^ do
  begin
  TBVRDataDir.ClearChilds(); // clear previously created objects

  //*** create Labels(Tokens) CObj and Map Layers (TBTPoints, TBTFonts, MTBTokens, TBTokens)

  TBTPoints := TN_UDPoints.Create();
  TBTPoints.ObjName := 'TBTPoints';
  TBVRDataDir.PutDirChildSafe( N_TBTPoints, TBTPoints );
  TBTPoints.InitItems( 1, 1 );

  TBTFonts := nil;
  if tbfMultiFont in TBFlags then // create UDRArray with UDNFonts
  begin
    TBTFonts := K_CreateUDByRTypeName( 'TN_NFont', 0 );
    TBTFonts.ObjName := 'TBFonts';
    TBVRDataDir.PutDirChildSafe( N_TBTFonts, TBTFonts );
  end; // if tbfMultiFont in TBFlags then // create UDRArray with Token's Fonts

  MTBTokens := N_CreateUDMapLayer( TBTPoints, mltHorLabels );
  TBVRDataDir.PutDirChildSafe( N_MTBTokens, MTBTokens );
  with MTBTokens.PISP^ do
  begin
    K_SetUDRefField( TN_UDBase(MLAux1), TBFont ); // TextBoxes UDLogFont
//    MLFSCoef    := TBFSCoef;
    MLTextColor := TBTextColor; // TextBox Text Color
    MLHotPoint  := FPoint(0,0);

    TBTokens := K_CreateUDByRTypeName( 'String', 0 );
    TBTokens.ObjName := 'TBTokens';
    TBVRDataDir.PutDirChildSafe( N_TBTokens, TBTokens );
    K_SetUDRefField( TN_UDBase(MLDVect1), TBTokens ); // UDRArray with Tokens
    K_SetUDRefField( TN_UDBase(MLDVect3), TBTFonts ); // TBTFonts may be nil
  end; // with MTBTokens.PSP^ do

  end; // with TBVRPtr^ do

end; // end_of function TN_TBVisualRepr.CreateEmpyMapObjects

//***************************************** TN_TBVisualRepr.LayoutTokens ***
// Parse Tokens in CTextBox.TBPlainText string, add them to TBTokens UDRArray and
// Calculate Tokens relative positions (shifts) in float Pixels
//
procedure TN_TBVisualRepr.LayoutTokens();
var
  i, iMax, BegTInd, EndTInd, NElems, Dx, Dy, NTokens: integer;
  Token: string;
  EmptyToken: boolean;
  TBTokens, TBTFonts: TK_UDRArray;
  CurFont: TN_UDLogFont;
  PCurFont: TN_PLogFontRef;
  Label NextChar;

  procedure AddToken( ASkipLast, ASkipAfter: integer ); // local
  // add one Token to TBTokens UDRArray and set ElSize field in ODLElems array
  // ASkipLast  - num. last token's chars. to skip
  //              (0 means last char has index i (last analized char) )
  // ASkipAfter - num. chars. to skip after last token's chars
  begin
    with Self.TBVRPtr^, ODLayout do
    begin

    // BegTInd, EndTInd - Beg and End Token's indexes
    EndTInd := i - ASkipLast;
    Token := Copy( TBPlainText, BegTInd, EndTInd-BegTInd+1 );
    Token := TrimRight( Token ); // left spaces will remain in token
    EmptyToken := True;

    if Length(ODLElems) <= NElems then
      SetLength( ODLElems, N_NewLength( NElems ) );

    if Trim(Token) = '<br>' then // force row break
    begin
      if (NElems = 0) or
         (leltRowBreak in ODLElems[NElems-1].ElFlags) then // add empty token
      begin
        Token := '';
        ODLElems[NElems].ElFlags := [leltRowBreak, leltNoSpaceAfter];
      end else // add RowBreak to prev. Element and skip adding cur token
      begin
        ODLElems[NElems-1].ElFlags := ODLElems[NElems-1].ElFlags +
                          [leltRowBreak, leltNoSpaceAfter]; // to prev. Element
        BegTInd := i;
        Inc( i );
        Exit;
      end;
    end;

    NTokens := TBTokens.R.ALength(); // number of previously parsed tokens
    TBTokens.R.ASetLength( NTokens + 1 ); // place for one new token

    TBTFonts := TK_UDRArray(TBVRDataDir.DirChild( N_TBTFonts ));
    if (TBTFonts <> nil) and (tbfMultiFont in TBFlags) then // save Token Font
    begin
      TBTFonts.R.ASetLength( NTokens + 1 ); // place for one new token Font
      PCurFont := TN_PLogFontRef(TBTFonts.R.P(NTokens));
      K_SetUDRefField( TN_UDBase(PCurFont^.LFRUDFont), CurFont );
      PCurFont^.LFRFSCoef := TBFSCoef;
    end;

    PString(TBTokens.R.P(NTokens))^ := Token;

    with TBVRGCont.DstOCanv do
    begin
      GetStringSize( Token, Dx, Dy ); // Dx is in DstOCanv Pixels
      ODLElems[NElems].ElSize := Dx;
    end;

    Inc( NElems );
    Inc( i, ASkipAfter - ASkipLast + 1 ); // to next char to analize
    BegTInd := i;

    end; // with TBVRPtr^, ODLayout do
  end; // end of procedure AddToken(); // local

begin //***** body of LayoutTokens method

  with TBVRPtr^, ODLayout do
  begin

  //*** Parse Tokens in TBPlainText string,
  //    add them to TBTokens UDRArray and ODLElems array

  FillChar( ODLayout, Sizeof(TN_OneDimLayout), 0 ); // clear Layout data
  SetLength( ODLElems, 20 ); // initial value

  TBTokens := TK_UDRArray(TBVRDataDir.DirChild( N_TBTokens ));
  CurFont := N_SetUDFont( TBFont, TBVRGCont.DstOCanv, TBFSCoef ); // for AOCanv.GetStringSize method

  NElems := 0;
  i := 1;
  BegTInd := 1; // Beg Token Index
  iMax := Length(TBPlainText);
  EmptyToken := True;

  while True do //****************** loop along characters in TBPlainText
  begin
    if EmptyToken then // include leading spaces in token
    begin
      if i > iMax then Break; // end of characters

      if TBPlainText[i] = ' ' then
      begin
        Inc( i ); // to next char
        Continue;
      end;
    end;

    EmptyToken := False; // PlainText[i] <> ' '
{
    if TBPlainText[i] = '-' then // Minus is Token delimiter
    begin
      AddToken( 0, 0 );
      ODLElems[NElems-1].ElFlags := [leltNoSpaceAfter]; // to prev. Element
      Continue;
    end;
}
    if TBPlainText[i] = ' ' then // This Space is Token delimiter
    begin
      AddToken( 1, 1 );
      Continue;
    end;

    if TBPlainText[i] = Char($0D) then // End of Line is Token delimiter
    begin
      AddToken( 1, 2 );
      ODLElems[NElems-1].ElFlags := [leltRowBreak]; // to prev. Element
      Continue;
    end;

    if i >= iMax then // end of characters
    begin
      AddToken( 0, 0 );
      Break;
    end;

    Inc( i ); // to next char
  end; // while True do // loop along characters in TBPlainText

  ODLRowHeight := CurFont.CalcPixHeight( TBVRGCont.DstOCanv ) *
                                           (1 + TBLineExtraSpace); // in float Pixels
  ODLAlign     := TBHorAlign;
  ODLSpaceSize := 0.3*ODLRowHeight;
  ODLPrefWidth := TBVRPrefXYSize.X;
  ODLNumElems  := NELems;
  ODLRows      := nil;
  if tbfFixWidth in TBFlags then ODLFlags := [odlfFixWidth];

  N_DoOneDimLayout( @ODLayout ); //********* do Layout

  TBVRRealXYSize.X := Round(ODLRealWidth);
  TBVRRealXYSize.Y := Round( (ODLNumRows - 1)*ODLRowHeight +
                       ODLRowHeight/(1+TBLineExtraSpace) ); // last Row Height

  //***** Layout data are OK and ready for using in FinishCreation method

  end; // with TBVRPtr^, ODLayout do
end; // end_of function TN_TBVisualRepr.LayoutTokens

//*************************************** TN_TBVisualRepr.FinishCreation ***
// Finish creating TextBox Visual Representation:
// convert already calculated tokens float relative Pix coords to User coords and
// add TBTPoints Items with calculated tokens User Coords
//
// ULPixCoords - Absolute Pixel Coords of Point with (0,0) relative Pixel Coords
//
procedure TN_TBVisualRepr.FinishCreation( ULPixCoords: TPoint );
var
  i: integer;
  FreeYSize, OfsY, RowHeight: double;
  ULUC, TUC: TDPoint;
  TBTPoints: TN_UDPoints;
begin
  with TBVRPtr^, ODLayout do
  begin
    OfsY := 0; // to awoid warning;
    FreeYSize := TBVRPrefXYSize.Y - ODLNumRows * ODLRowHeight;
    RowHeight := ODLRowHeight;

    case TBVertAlign of
      hvaBeg: begin
        OfsY := 0;
      end; // hvaBeg: begin

      hvaCenter: begin
        OfsY := 0.5 * FreeYSize;
      end; // hvaCenter: begin

      hvaEnd: begin
        OfsY := FreeYSize;
      end; // hvaEnd: begin

      hvaJustify: begin
        OfsY := 0;
        if ODLNumRows >= 2 then
          RowHeight := ODLRowHeight + FreeYSize/(ODLNumRows-1);
      end; // hvaJustify: begin

      hvaUniform: begin
        RowHeight := FreeYSize / (ODLNumRows + 1);
        OfsY := RowHeight;
      end; // hvaUniform: begin

    end; // case TBVertAlign of

    //*** create TBTPoints Items

    TBTPoints := TN_UDPoints(TBVRDataDir.DirChild( N_TBTPoints ));
    ULUC := N_AffConvI2DPoint( ULPixCoords, TBVRGCont.DstOCanv.P2U );

    for i := 0 to ODLNumElems-1 do // along all tokens
    with TBVRGCont.DstOCanv do
    begin
        // TUC is current Token upper left corner User Coords:
      TUC.X := ULUC.X + P2U.CX*ODLElems[i].ElOffs;
      TUC.Y := ULUC.Y + P2U.CY*( OfsY + ODLElems[i].ElRowInd * RowHeight );
//        if Abs(TUC.X) > 10.0e10 then // debug
//          N_i := 1;
      TBTPoints.AddOnePointItem( TUC, -1 );
    end; // for i := 0 to ODLNumElems-1 do

  end; // with  TBVRPtr^, ODLayout  do
end; // end_of function TN_TBVisualRepr.FinishCreation

//*************************************** TN_TBVisualRepr.DrawTokens ***
// Draw Tokens (Draw created MTBTokens MapLayer)
//
procedure TN_TBVisualRepr.DrawTokens();
begin
  with TN_UDMapLayer(TBVRDataDir.DirChild( N_MTBTokens )) do // with MTBTokens MapLayer
  begin
    NGCont := TBVRGCont;
    K_RFreeAndCopy( DynPar, R, [K_mdfCopyRArray] );
    BeforeAction(); // draw MTBTokens MapLayer
  end;
end; // end_of function TN_TBVisualRepr.DrawTokens


//********** TN_UDLegend class methods  **************

//********************************************** TN_UDLegend.Create ***
//
constructor TN_UDLegend.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDLegendCI;
  ImgInd := 42;
end; // end_of constructor TN_UDLegend.Create

//********************************************* TN_UDLegend.Destroy ***
//
destructor TN_UDLegend.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDLegend.Destroy

//********************************************** TN_UDLegend.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDLegend.PSP(): TN_PRLegend;
begin
  Result := TN_PRLegend(R.P());
end; // end_of function TN_UDLegend.PSP

//********************************************** TN_UDLegend.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDLegend.PDP(): TN_PRLegend;
begin
  if DynPar <> nil then Result := TN_PRLegend(DynPar.P())
                   else Result := TN_PRLegend(R.P());
end; // end_of function TN_UDLegend.PDP

//******************************************* TN_UDLegend.PISP ***
// return typed pointer to Individual Static Legend Params
//
function TN_UDLegend.PISP(): TN_PCLegend;
begin
  Result := @(TN_PRLegend(R.P())^.CLegend);
end; // function TN_UDLegend.PISP

//******************************************* TN_UDLegend.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic Legend Params
// otherwise return typed pointer to Individual Static Legend Params
//
function TN_UDLegend.PIDP(): TN_PCLegend;
begin
  if DynPar <> nil then
    Result := @(TN_PRLegend(DynPar.P())^.CLegend)
  else
    Result := @(TN_PRLegend(R.P())^.CLegend);
end; // function TN_UDLegend.PIDP

//********************************************** TN_UDLegend.PascalInit ***
// Init self
//
procedure TN_UDLegend.PascalInit();
var
  PRCompS: TN_PRLegend;
begin
  Inherited;
  PRCompS := PSP();
  with PRCompS^, PRCompS^.CLegend do
  begin
    N_InitCLegend( @CLegend );
  end;
end; // procedure TN_UDLegend.PascalInit

//************************************** TN_UDLegend.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDLegend.BeforeAction();
var
  DataDir: TN_UDBase;
begin
  DataDir := CreateVisRepr(); // Create Self Visual Representation in DataDir
  DataDir.ClassFlags := DataDir.ClassFlags or K_SkipSelfSaveBit;
  DrawAllMapLayers( DataDir );
end; // end_of procedure TN_UDLegend.BeforeAction

//************************************** TN_UDLegend.CreateVisRepr ***
// Create Self Visual Representation in DataRoot, return DataRoot
//
// AInternalRect - Panel Internal Pixel Rect
//
function TN_UDLegend.CreateVisRepr(): TN_UDBase;
var
  i, NElems, j, NumColumns, Dx, Dy, MaxDx, ColInd: integer;
  PixSX, PixSY, PixLegWidth, PixLegHeight: integer;
  CurNumCols, CurNumRows, MaxNumRows, NumElemsOK, APrefNumRows: integer;
  OneColTried, TwoColsTried, ThreeColsTried: boolean;
  HeaderHeight, FooterHeight, ColWidth, MaxETextWidth, ShiftX, RNumColumns: double;
  LegWidth, LegHeight, CurElemTextSize: double;
  PixSignRect: TRect;
  SignURect: TFRect;
  ULegRects, ULegDashes: TN_Ulines;
  MLegRects, MLegDashes: TN_UDMapLayer;
  ElemsLayout, ColumnsLayout: TN_OneDimLayout;
//  TBLayouts: TN_OneDimLayouts;
  PRL: TN_PRLegend;
  DataRoot: TN_UDBase;
  AOCanv: TN_OCanvas;
  TBVR: TN_TBVisualRepr;
  CurLEPar: TN_CLegElemPar;
  ColWidths: TN_FArray;
  ElemWidths: TN_FArray;
  DC: TN_DPArray;
  PMLContAttrRA: TK_PRArray;
  Label TryOneCol, TryTwoCols, TryThreeCols, LayoutColumns;

  function LegLayoutElems(): integer; // local
  // Layout Elems in CurNumCols Columns and return Number of "layouted" elems
  var
    i: integer;
  begin
    with TBVR, TBVR.TBVRPtr^, PRL^.CLegend, AOCanv do
    begin

    if CurNumCols = 1 then
      ColWidth := LegWidth
    else
      ColWidth := (LegWidth - (CurNumCols-1)*LegColumnsGap) / CurNumCols;

    //***** Prepare TextBox for Elements Texts

    TBVRPrefXYSize.X := (ColWidth - LegSignWidth) * CurLSUPixSize;
    TBFlags     := [tbfMultiFont]; // tbfFixWidth should be off
    TBHorAlign  := hvaBeg;
    TBFont      := LegElemsFont;
    TBFSCoef    := LegEFSCoef;

    //***** prepare for Elements Layout

    FillChar( ElemsLayout, Sizeof(TN_OneDimLayout), 0 ); // clear Layout data

    with ElemsLayout do
    begin
      ODLFlags      := [odlfFixWidth];
      ODLElemsInRow := CurNumRows;
      ODLAlign      := LegElemsVAlign;
      ODLSpaceSize  := LegElemsYGap;
      ODLPrefWidth  := LegHeight - HeaderHeight - FooterHeight;
      ODLUnifSSpace := LegSideSizeCoef;
      ODLMaxSpace   := LegElemsMaxYGap;
      ODLNumElems   := NElems;
      SetLength( ODLElems, NElems );
    end; // with ElemsLayout do

    //***** Calc and save Legend Text Elements Heights in ODLElems[i].ElSize
    //      and Elements Widths in ElemWidths

    SetLength( ElemWidths, NElems );

    for i := 0 to NElems-1 do // loop along all Legend Elements
    begin                      // calc all Elements Heights
      TBPlainText := PString(LegElemTexts.Ps(i))^; // Ps mainly for debug

      LayoutTokens();
      CurElemTextSize := TBVRRealXYSize.Y / CurLSUPixSize; // in LSU
      ElemWidths[i]   := TBVRRealXYSize.X / CurLSUPixSize; // in LSU

      with ElemsLayout do
      begin
        ODLElems[i].ElRealSize := CurElemTextSize;

        if CurElemTextSize < LegSignMinHeight then // Sign Place is Heigher
          ODLElems[i].ElSize := LegSignMinHeight
        else //************* Elem TextBox is Heigher than Sign Place
          ODLElems[i].ElSize := CurElemTextSize;

      end; // with ElemsLayout do

    end; // for i := 0 to NElems do // loop along all Legend Elements

    //***** ElemsLayout Rows are Legend Columns, do Elements Layout

    N_DoOneDimLayout( @ElemsLayout );

    with ElemsLayout do
    begin
      if ODLNumRows > CurNumCols then // some Elements are out of Legend
        Result := ODLRows[CurNumCols].RowFEInd
      else // all Elements are OK
        Result := NElems;
    end; // with ElemsLayout do

  end; // with TBVR, TBVR,TBVRPtr^, PRL^.CLegend, AOCanv do
  end; // function LegLayoutElems(); // local

begin
  SetElemsD();

  PRL       := PDP();
  AOCanv    := NGCont.DstOCanv;
  DataRoot  := GetDataRoot( True );
  Result    := DataRoot;

  with PRL^, CLegend, AOCanv do
  begin

  PixLegWidth  := N_RectWidth( CompIntPixRect );
  PixLegHeight := N_RectHeight( CompIntPixRect );
  LegWidth  := PixLegWidth  / CurLSUPixSize; // conv to LSU
  LegHeight := PixLegHeight / CurLSUPixSize;

  NElems := LegElemTexts.ALength(); // Number of Legend Elements

  if LegTmpNumElems > 0 then NElems := LegTmpNumElems; // temporary, for Debug

  TBVR := TN_TBVisualRepr.Create( Self ); // for creating Legend's Text Boxes Visual representations
  TBVR.TBVRPtr^.TBFlags := [tbfFixWidth, tbfMultiFont];
  TBVR.CreateEmpyMapObjects( DataRoot ); // Clear DataRoot and create MapObjects, needed for TextBoxes

//******* Create Empty Visual Representation objects, related to Sign Rects:
// ULegRects  - TN_Ulines with Sign Rects borders
// ULegColors - TK_UDRArray with Sign Rects Colors (array of integer)
// MLegRects  - TN_UDMapLayer (mltLines1) for drawing Sign Rects (according to LegElemsPar)

  ULegRects := TN_Ulines.Create1( N_FloatCoords, 'LegSignRects' ); // ULegRects
  DataRoot.PutDirChildSafe( N_ULegRects, ULegRects );
  ULegRects.InitItems( 1, 1 );

//  ULegColors := K_CreateUDByRTypeName( 'Integer', NElems ); //***** ULegColors
//  ULegColors.ObjName := 'LegColors';
//  DataRoot.PutDirChildSafe( N_ULegColors, ULegColors );

  MLegRects := N_CreateUDMapLayer( ULegRects, mltLines1 ); //******* MLegRects
  DataRoot.PutDirChildSafe( N_MLegRects, MLegRects );
  with MLegRects.PISP()^ do
  begin
    MLCAArray := K_RCreateByTypeName( 'TN_ContAttrArray', NElems );
    MLDrawMode := $00080; // User Coords, ShapeCoords Mode
{
    K_SetUDRefField( TN_UDBase(MLDVect1), ULegColors ); // Colors for filling Sign Rects
    MLPenColor   := 0;           // Sign Rects border Color
    MLPenWidth   := LegSRBWidth; // Sign Rects border Width
    MLDrawMode   := $01;         // draw using WindowPolygon
    MLColorMode  := $01;         // individual Colors
}
  end; // with MLegRects.PSP^ do

//******* Create Empty Visual Representation objects, related to Sign Dashes:
// ULegDashes - TN_Ulines with Sign Dashes
// MLegDashes - TN_UDMapLayer (mltLines1) for drawing Sign Dashes

  ULegDashes := TN_Ulines.Create1( N_FloatCoords, 'LegDashes' ); // ULegDashes
  DataRoot.PutDirChildSafe( N_ULegDashes, ULegDashes );
  ULegDashes.InitItems( 1, 1 );

  MLegDashes := N_CreateUDMapLayer( ULegDashes, mltLines1 ); //**** MLegDashes
  DataRoot.PutDirChildSafe( N_MLegDashes, MLegDashes );
  with MLegDashes.PISP()^ do
  begin
    MLPenColor := 0;                // Sign Rects Dash Color
    MLPenWidth := LegSignDashWidth; // Sign Rects Dash Width
  end; // with MLegRects.PSP^ do

  //***** All needed Empty Visual Representation objects in DataRoot are created,
  //      Create Legend Header

  with TBVR, TBVR.TBVRPtr^ do // TBVR object is used for Header, Footer and Elems TextBoxes
  begin
    TBHorAlign := LegHeaderAlign;

    HeaderHeight := LegHeaderBotPadding;
    if LegHeaderText <> '' then // Legend Header is not empty
    begin
      TBPlainText := LegHeaderText;
      TBFont      := LegHeaderFont;
      TBFSCoef    := LegHFSCoef;
      TBVRPrefXYSize.X := PixLegWidth;

      LayoutTokens();

      HeaderHeight := TBVRRealXYSize.Y / CurLSUPixSize + LegHeaderBotPadding;
      FinishCreation( CompIntPixRect.TopLeft );
    end; // if LegHeaderText <> '' then // Legend Header is not empty

  //***** Legend Header created, Create Legend Footer

    FooterHeight := LegFooterTopPadding;
    if LegFooterText <> '' then // Legend Footer is not empty
    begin
      TBPlainText := LegFooterText;
      TBFont      := LegFooterFont;
      TBFSCoef    := LegFFSCoef;
      TBHorAlign  := LegFooterAlign;

      LayoutTokens();

      FooterHeight := TBVRRealXYSize.Y / CurLSUPixSize + LegFooterTopPadding;
      // Footer LowerRight corner is CompIntPixRect.BottomRight
      FinishCreation( Point( CompIntPixRect.Left,
                             CompIntPixRect.Bottom - Round(TBVRRealXYSize.Y) ) );
    end; // if LegFooterText <> '' then // Legend Footer is not empty


    //********  Legend Header and Footer are created, do Elements Layout  *****

    MaxDx := 0; //***** Calc MaxDx - max Legend Text Elements width in Pixels
    for i := 0 to NElems-1 do
    begin
      AOCanv.GetStringSize( PString(LegElemTexts.Ps(i))^, Dx, Dy ); // Dx,Dy in pixels!
      MaxDx := Max( MaxDx, Dx ); // in Pixels
    end;

    MaxETextWidth := MaxDx / CurLSUPixSize; // conv Pix to LSU
    MaxNumRows := Round(Floor( PixLegHeight / Dy )); // Max Number of Rows in each Column
    OneColTried    := False;
    TwoColsTried   := False;
    ThreeColsTried := False;

    CurNumCols := LegPrefColsRows.X;

    if CurNumCols <= 0 then // Set preferable number of columns
    begin
      if NElems <= LegOneColNumElems then
        CurNumCols := 1
      else
        CurNumCols := 2;
    end; // if CurNumCols <= 0 then // Set preferable number of columns

    case CurNumCols of
        1: goto TryOneCol;
        2: goto TryTwoCols;
        3: goto TryThreeCols;
      else
        goto TryTwoCols;
    end; // case CurNumCols of


    TryOneCol: //*********************************** Try One Column Layout
    CurNumCols := 1;
    NumElemsOK := LegLayoutElems();

    if NumElemsOK = NElems then
      goto LayoutColumns
    else // One Column Layout failed
    begin
      OneColTried := True;
      if not TwoColsTried then goto TryTwoCols
      else if not ThreeColsTried then goto TryThreeCols
      else goto LayoutColumns;
    end; // else // One Column Layout failed


    TryTwoCols: //*********************************** Try Two Columns Layout
    CurNumCols := 2;
    CurNumRows := 0; // any number of Elems in Row is OK
    NumElemsOK := LegLayoutElems();

    if NumElemsOK = NElems then
    with ElemsLayout do
    begin
      if lfSameColHeights in LegFlags then // try to achive same Columns Height
      begin
        CurNumRows := NElems div CurNumCols;
        if (NElems mod CurNumCols) <> 0 then Inc(CurNumRows); // for even NElems
        NumElemsOK := LegLayoutElems();

        if NumElemsOK = NElems then
          goto LayoutColumns
        else // try with increased CurNumRows
        begin
          Inc(CurNumRows);
          NumElemsOK := LegLayoutElems();
          if NumElemsOK = NElems then
            goto LayoutColumns
          else // Layout again with any number of Elems in Row is OK
          begin
            CurNumRows := 0; // any number of Elems in Row is OK
            LegLayoutElems();
            goto LayoutColumns;
          end;
        end;
      end else // Given Fixed NumRows or Cur Layout (with any NumRows) is OK
      begin
        CurNumRows := LegPrefColsRows.Y;
        if CurNumRows > 0 then // Given Fixed NumRows
        begin
          LegLayoutElems();
          goto LayoutColumns;
        end else // Cur Layout (with any NumRows) is OK
          goto LayoutColumns;
      end;
    end else // Two Columns Layout failed
    begin
      TwoColsTried := True;
      if not OneColTried then goto TryOneCol
      else if not ThreeColsTried then goto TryThreeCols
      else goto LayoutColumns;
    end; // else // Two Columns Layout failed


    TryThreeCols: //********************************* Try Three Columns Layout
    CurNumCols := 3;
    CurNumRows := 0; // any number of Elems in Row is OK
    NumElemsOK := LegLayoutElems();

    if NumElemsOK = NElems then
    with ElemsLayout do
    begin
      if lfSameColHeights in LegFlags then // try to achive same Columns Height
      begin
        CurNumRows := NElems div CurNumCols;
        if (NElems mod CurNumCols) <> 0 then Inc(CurNumRows); // for even NElems
        NumElemsOK := LegLayoutElems();

        if NumElemsOK = NElems then
          goto LayoutColumns
        else // try with increased CurNumRows
        begin
          Inc(CurNumRows);
          NumElemsOK := LegLayoutElems();
          if NumElemsOK = NElems then
            goto LayoutColumns
          else // Layout again with any number of Elems in Row is OK
          begin
            CurNumRows := 0; // any number of Elems in Row is OK
            LegLayoutElems();
            goto LayoutColumns;
          end;
        end;
      end else // Given Fixed NumRows or Cur Layout (with any NumRows) is OK
      begin
        CurNumRows := LegPrefColsRows.Y;
        if CurNumRows > 0 then // Given Fixed NumRows
        begin
          LegLayoutElems();
          goto LayoutColumns;
        end else // Cur Layout (with any NumRows) is OK
          goto LayoutColumns;
      end;
    end else // Three Columns Layout failed
    begin
      ThreeColsTried := True;
      if not TwoColsTried then goto TryTwoCols
      else if not OneColTried then goto TryOneCol
      else goto LayoutColumns;
    end; // else // Three Columns Layout failed



{ // previous code:
    NumColumns := LegNumColumns;
    if NumColumns = 0 then // choose NumColumns automaticly
    begin
      RNumColumns := (LegWidth + LegColumnsGap) /
                                (MaxETextWidth + LegColumnsGap + LegSignWidth);
      NumColumns :=Max( 1, Round(Floor( RNumColumns )) );
    end; // if NumColumns = 0 then // choose NumColumns automaticly

    ColWidth := Min( (LegWidth + LegColumnsGap) / NumColumns,     // in LSU
                      MaxETextWidth + LegColumnsGap + LegSignWidth );

    //***** Prepare TextBox for Elements Texts

    TBVRPrefXYSize.X := (ColWidth - (LegColumnsGap + LegSignWidth)) * CurLSUPixSize + 2;
    TBHorAlign  := hvaBeg;
    TBFont      := LegElemsFont;
    TBFSCoef    := LegEFSCoef;
//    SetLength( TBLayouts, NElems ); // for saving Layout for each element

    //***** prepare for Elements Layout

    FillChar( ElemsLayout, Sizeof(TN_OneDimLayout), 0 ); // clear Layout data
    with ElemsLayout do // prepare for Elements Layout
    begin
//      ODLFlags     := [odlfFixWidth,odlfCheckElRealSize]; // old var
      ODLFlags     := [odlfFixWidth];
//      ODLAlign     := hvaBeg;
      ODLAlign     := LegFooterAlign; // debug!
      ODLSpaceSize := LegElemsYGap;
      ODLPrefWidth := LegHeight - HeaderHeight - FooterHeight;
      SetLength( ODLElems, NElems );
      ODLNumElems  := NElems;
      ODLElemsInRow := LegNumRows;

      if ODLElemsInRow = 0 then // choose ODLNElemsInRow automaticly
        ODLElemsInRow := Round(Ceil( NElems / NumColumns ));

      if (ODLElemsInRow*NumColumns) < NElems then // correct ODLNElemsInRow
        ODLElemsInRow := Round(Ceil( NElems / NumColumns ));

    end; // with ElemsLayout do // prepare for Elements Layout

    //***** Calc and save Legend Text Elements Heights in ODLElems[i].ElSize
    //      and Elements Widths in ElemWidths

    SetLength( ElemWidths, NElems );

    for i := 0 to NElems-1 do // first loop along all Legend Elements
    begin                      // calc all Elements Heights
      TBPlainText := PString(LegElemTexts.P(i))^;

      LayoutTokens();
      CurElemTextSize := TBVRRealXYSize.Y / CurLSUPixSize; // in LSU
      ElemWidths[i]   := TBVRRealXYSize.X / CurLSUPixSize; // in LSU

      with ElemsLayout do
      begin
        ODLElems[i].ElRealSize := CurElemTextSize;

        if CurElemTextSize < LegSignMinHeight then // Sign Place is Heigher
          ODLElems[i].ElSize := LegSignMinHeight
        else //************* Elem TextBox is Heigher than Sign Place
          ODLElems[i].ElSize := CurElemTextSize;

      end; // with ElemsLayout do

    end; // for i := 0 to NElems do // first loop along all Legend Elements

    //***** ElemsLayout Rows are Legend Columns, do Elements Layout

    N_DoOneDimLayout( @ElemsLayout );
}

    LayoutColumns: //***** DO Columns horizontal Uniform layout with real Columns widths

    NumColumns := ElemsLayout.ODLNumRows; // may be greater then CurNumCols (some columns may be out of Legend Rect)
    SetLength( ColWidths, NumColumns );

    for j := 0 to NumColumns-1 do
      ColWidths[j] := 0;

    //***** prepare for Columns Layout

    FillChar( ColumnsLayout, Sizeof(TN_OneDimLayout), 0 ); // clear Layout data

    with ColumnsLayout do // prepare for Columns Layout
    begin
      ODLFlags      := [odlfFixWidth];
      ODLAlign      := hvaUniform;
      ODLSpaceSize  := 0; // (LegColumnsGap was considered in ColWidth calculation)
      ODLPrefWidth  := LegWidth;
      SetLength( ODLElems, NumColumns );
      ODLNumElems  := NumColumns;
    end; // with ColumnsLayout do // prepare for Columns Layout

    for i := 0 to NElems-1 do // calc real Columns widths
    with ColumnsLayout do      // (Max Width for All Column Elems)
    begin
      ColInd := ElemsLayout.ODLElems[i].ElRowInd;
      ColWidths[ColInd] := Max( ColWidths[ColInd], ElemWidths[i] );
    end; // for i := 0 to NElems-1 do // calc real Columns widths in ColWidths array

    for j := 0 to NumColumns-1 do
    with ColumnsLayout.ODLElems[j] do
    begin
      ElRealSize := ColWidths[j] + LegSignWidth;
      ElSize     := ElRealSize;
    end; // for j := 0 to NumColumns-1 do

    N_DoOneDimLayout( @ColumnsLayout ); // Layout Columns horizontally

    ShiftX := 0; // additional shift of all Columns along X in LSU

    //***** Fill all Visual Representation objects:

    SetLength( DC, 2 );

    for i := 0 to NElems-1 do // loop along all Legend Elements
    with ElemsLayout do
    begin
      //***** PixSX, PixSY - Upper Left Corner of Sign Element relative to CompIntPixRect in Pixels
//      PixSX := Round( (ShiftX + ColWidth*ODLElems[i].ElRowInd)*CurLSUPixSize ); // old var

      ColInd := ODLElems[i].ElRowInd;
      if ColInd >= CurNumCols then // Element is out of Legend Rect, skip it
        Continue;

      PixSX := Round( ColumnsLayout.ODLElems[ColInd].ElOffs*CurLSUPixSize );
      PixSY := Round( (HeaderHeight + ODLElems[i].ElOffs)*CurLSUPixSize );

      // Layout Tokens once more (result of first Layot can be stored in Array of TBVR objects)
      TBPlainText := PString(LegElemTexts.Ps(i))^;
      LayoutTokens();

      Dx := Round( LegSignWidth*CurLSUPixSize );
      FinishCreation( Point( CompIntPixRect.Left + PixSX + Dx,
                             CompIntPixRect.Top  + PixSY ) );

      //***** Finish Creating: fill TBPoints by Elems Tokens coords,
      //                       Fill ULegRects, ULegColors, ULegDashes

      if LegSignWidth > 0 then // Finish Creating
      begin
        PixSignRect := IRect( N_RectScaleA( LegSignRect, CurLSUPixSize, DPoint(0,0) ) ); // relative to Sign Elem TopLeft
        PixSignRect := N_RectShift( PixSignRect, CompIntPixRect.Left+PixSX, CompIntPixRect.Top+PixSY ); // Abs Pix
        SignURect   := N_AffConvI2FRect1( PixSignRect, P2U ); // in User Coords

        if LegElemsPar = nil then // default Element type
          CurLEPar.LEPType := letDefRect
        else
          CurLEPar := TN_PCLegElemPar(LegElemsPar.P(i))^;

        PMLContAttrRA := TK_PRArray(MLegRects.PISP()^.MLCAArray.P(i));

        case CurLEPar.LEPType of

        letDefRect: begin // filled Rect with LegElemColors[i]
          if PMLContAttrRA^ = nil then
            PMLContAttrRA^ := K_RCreateByTypeName( 'TN_ContAttr', 1 )
          else
            PMLContAttrRA^.ASetLength( 1 );

          with TN_PContAttr(PMLContAttrRA^.P())^ do
          begin
            ULegRects.AddRectItem( SignURect );
            CAPenColor  := $000000;
            CAPenWidth  := LegSRBWidth; // Sign Rects border Width
            CABrushColor := PInteger(LegElemColors.P(i))^; // Set Item Color
          end; // with TN_PContAttr(PMLContAttrRA^.P())^ do
        end; // letDefRect: begin // filled Rect

        letRect: begin // filled Rect with any drawing Attributes
          ULegRects.AddRectItem( SignURect );
          N_AssignRArray( PMLContAttrRA^, TK_PRArray(LegElemsAttr.P(i))^ );
        end; // letRect: begin // filled Rect

        letHLine: begin // Horizontal Line
          with SignURect do
          begin
            DC[0].X := Left;
            DC[0].Y := 0.5*(Top + Bottom);
            DC[1].X := Right;
            DC[1].Y := DC[0].Y;
          end; // with SignURect do
          ULegRects.AddSimpleItem( DC, 2 );
          N_AssignRArray( PMLContAttrRA^, TK_PRArray(LegElemsAttr.P(i))^ );
        end; // letHLine: begin // Horizontal Line

        end; // case CurLEPar.LEPType of

        //***** PixSignRect and SignURect are used here as Dash Segment Beg and End Points

        PixSignRect.Top := (PixSignRect.Top + PixSignRect.Bottom) div 2;
        PixSignRect.Bottom := PixSignRect.Top;
        PixSignRect.Left  := CompIntPixRect.Left + PixSX + Round( LegSignDashXPos.X * CurLSUPixSize );
        PixSignRect.Right := CompIntPixRect.Left + PixSX + Round( LegSignDashXPos.Y * CurLSUPixSize );
        SignURect := N_AffConvI2FRect1( PixSignRect, P2U );
        ULegDashes.AddSegmentItem( SignURect.TopLeft, SignURect.BottomRight );  // Add Item Dash Segment

      end; // Finish Creating

    end; // for i := 0 to NElems do // second loop along all Legend Elements

  end; // with WrkTextBox do // WrkTextBox is used for Header, Footer, Elems TextBoxes
  end; // with APLegend^, AOCanv do
end; // function TN_UDLegend.CreateVisRepr

//********************************************** TN_UDLegend.SetElemsD ***
// Set some Self Elements by LegSetElems in Dyn Params
//
procedure TN_UDLegend.SetElemsD();
var
  i, j, NumToSet, MinLegElemes: integer;
begin
  with PIDP()^ do
  begin

  for i := 0 to LegSetElems.AHigh() do // along all SetElems groups
  with TN_PCLegSetElemes(LegSetElems.P(i))^ do
  begin

    if LSESrcUObj is TN_UD2DFunc then //*************************** TN_UD2DFunc
    with TN_UD2DFunc(LSESrcUObj), TN_UD2DFunc(LSESrcUObj).PIDP()^ do
    begin

      NumToSet := N_GetNumElemes( TDFAttribs, LSEBegSrcInd,
                                  LegElemsPar, LSEBegLegInd,
                                  LSENumElemes, 'TN_CLegElemPar' );
      MinLegElemes := LegElemsPar.ALength();

      for j := 0 to NumToSet-1 do // along Elements to set in current group
      begin
        TN_PCLegElemPar(LegElemsPar.P(LSEBegSrcInd+j))^ := LSELegElemPar;

        N_PrepCAArray( LegElemsAttr, MinLegElemes );
        N_AssignRArray( TK_PRArray(LegElemsAttr.P(LSEBegLegInd+j))^,
                        TK_PRArray(TDFAttribs.P(LSEBegSrcInd+j))^ );

        N_PrepRArray( LegElemTexts, MinLegElemes, 'String' );

        if TDCurves.AHigh() >= (LSEBegSrcInd+j) then
          PString(LegElemTexts.P(LSEBegLegInd+j))^ :=
                            TN_P2DCurve(TDCurves.P(LSEBegSrcInd+j))^.CurveText;
      end; // for j := 0 to NumElemes-1 do // along Elements in current group

    end else if LSESrcUObj is TN_UDIsoLines then //************** TN_UDIsoLines
    with TN_UDIsoLines(LSESrcUObj), TN_UDIsoLines(LSESrcUObj).PIDP()^ do
    begin

      NumToSet := N_GetNumElemes( CILAttribs, LSEBegSrcInd,
                                   LegElemsPar, LSEBegLegInd,
                                   LSENumElemes, 'TN_CLegElemPar' );
      MinLegElemes := LegElemsPar.ALength();

      for j := 0 to NumToSet-1 do // along Elements to set in current group
      begin
        TN_PCLegElemPar(LegElemsPar.P(LSEBegSrcInd+j))^ := LSELegElemPar;

        N_PrepCAArray( LegElemsAttr, MinLegElemes );
        N_AssignRArray( TK_PRArray(LegElemsAttr.P(LSEBegLegInd+j))^,
                        TK_PRArray(CILAttribs.P(LSEBegSrcInd+j))^ );

        N_PrepRArray( LegElemTexts, MinLegElemes, 'String' );

        if CILTexts.AHigh() >= (LSEBegSrcInd+j) then
          PString(LegElemTexts.P(LSEBegLegInd+j))^ :=
                                          PString(CILTexts.P(LSEBegSrcInd+j))^;
      end; // for j := 0 to NumElemes-1 do // along Elements in current group

    end; // else if LSESrcUObj is TN_UDIsoLines then

  end; // for i := 0 to LegSetElems.AHigh() do // along all SetElems members

  end; // with PIDP()^ do
end; // procedure TN_UDLegend.SetElemsD


//********** TN_UDNLegend class methods  **************

//********************************************** TN_UDNLegend.Create ***
//
constructor TN_UDNLegend.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDNLegendCI;
  ImgInd := 47;
end; // end_of constructor TN_UDNLegend.Create

//********************************************* TN_UDNLegend.Destroy ***
//
destructor TN_UDNLegend.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDNLegend.Destroy

//********************************************** TN_UDNLegend.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDNLegend.PSP(): TN_PRNLegend;
begin
  Result := TN_PRNLegend(R.P());
end; // end_of function TN_UDNLegend.PSP

//********************************************** TN_UDNLegend.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDNLegend.PDP(): TN_PRNLegend;
begin
  if DynPar <> nil then Result := TN_PRNLegend(DynPar.P())
                   else Result := TN_PRNLegend(R.P());
end; // end_of function TN_UDNLegend.PDP

//******************************************* TN_UDNLegend.PISP ***
// return typed pointer to Individual Static NLegend Params
//
function TN_UDNLegend.PISP(): TN_PCNLegend;
begin
  Result := @(TN_PRNLegend(R.P())^.CNLegend);
end; // function TN_UDNLegend.PISP

//******************************************* TN_UDNLegend.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic NLegend Params
// otherwise return typed pointer to Individual Static NLegend Params
//
function TN_UDNLegend.PIDP(): TN_PCNLegend;
begin
  if DynPar <> nil then
    Result := @(TN_PRNLegend(DynPar.P())^.CNLegend)
  else
    Result := @(TN_PRNLegend(R.P())^.CNLegend);
end; // function TN_UDNLegend.PIDP

//********************************************** TN_UDNLegend.PascalInit ***
// Init self
//
procedure TN_UDNLegend.PascalInit();
var
  PRCompS: TN_PRNLegend;
begin
  Inherited;
  PRCompS := PSP();
  with PRCompS^, PRCompS^.CNLegend do
  begin
    N_InitCNLegend( @CNLegend );
  end;
end; // procedure TN_UDNLegend.PascalInit

//************************************** TN_UDNLegend.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDNLegend.BeforeAction();
var
  DataDir: TN_UDBase;
begin
//  DataDir := CreateVisRepr(); // Create Self Visual Representation in DataDir
  DataDir := nil;
  DataDir.ClassFlags := DataDir.ClassFlags or K_SkipSelfSaveBit;
  DrawAllMapLayers( DataDir );
end; // end_of procedure TN_UDNLegend.BeforeAction

//********************************************** TN_UDNLegend.SetElemsD ***
// Set some Self Elements by LegSetElems in Dyn Params
//
procedure TN_UDNLegend.SetElemsD();
var
  i, j, NumToSet, MinLegElemes: integer;
begin
  with PIDP()^ do
  begin

  for i := 0 to NLSetElems.AHigh() do // along all SetElems groups
  with TN_PCLegSetElemes(NLSetElems.P(i))^ do
  begin

    if LSESrcUObj is TN_UD2DFunc then //*************************** TN_UD2DFunc
    with TN_UD2DFunc(LSESrcUObj), TN_UD2DFunc(LSESrcUObj).PIDP()^ do
    begin

      NumToSet := N_GetNumElemes( TDFAttribs, LSEBegSrcInd,
                                  NLElemsPar, LSEBegLegInd,
                                  LSENumElemes, 'TN_CLegElemPar' );
      MinLegElemes := NLElemsPar.ALength();

      for j := 0 to NumToSet-1 do // along Elements to set in current group
      begin
        TN_PCLegElemPar(NLElemsPar.P(LSEBegSrcInd+j))^ := LSELegElemPar;

        N_PrepCAArray( NLElemsAttr, MinLegElemes );
        N_AssignRArray( TK_PRArray(NLElemsAttr.P(LSEBegLegInd+j))^,
                        TK_PRArray(TDFAttribs.P(LSEBegSrcInd+j))^ );

        N_PrepRArray( NLElemTexts, MinLegElemes, 'String' );

        if TDCurves.AHigh() >= (LSEBegSrcInd+j) then
          PString(NLElemTexts.P(LSEBegLegInd+j))^ :=
                            TN_P2DCurve(TDCurves.P(LSEBegSrcInd+j))^.CurveText;
      end; // for j := 0 to NumElemes-1 do // along Elements in current group

    end else if LSESrcUObj is TN_UDIsoLines then //************** TN_UDIsoLines
    with TN_UDIsoLines(LSESrcUObj), TN_UDIsoLines(LSESrcUObj).PIDP()^ do
    begin

      NumToSet := N_GetNumElemes( CILAttribs, LSEBegSrcInd,
                                   NLElemsPar, LSEBegLegInd,
                                   LSENumElemes, 'TN_CLegElemPar' );
      MinLegElemes := NLElemsPar.ALength();

      for j := 0 to NumToSet-1 do // along Elements to set in current group
      begin
        TN_PCLegElemPar(NLElemsPar.P(LSEBegSrcInd+j))^ := LSELegElemPar;

        N_PrepCAArray( NLElemsAttr, MinLegElemes );
        N_AssignRArray( TK_PRArray(NLElemsAttr.P(LSEBegLegInd+j))^,
                        TK_PRArray(CILAttribs.P(LSEBegSrcInd+j))^ );

        N_PrepRArray( NLElemTexts, MinLegElemes, 'String' );

        if CILTexts.AHigh() >= (LSEBegSrcInd+j) then
          PString(NLElemTexts.P(LSEBegLegInd+j))^ :=
                                          PString(CILTexts.P(LSEBegSrcInd+j))^;
      end; // for j := 0 to NumElemes-1 do // along Elements in current group

    end; // else if LSESrcUObj is TN_UDIsoLines then

  end; // for i := 0 to NLSetElems.AHigh() do // along all SetElems members

  end; // with PIDP()^ do
end; // procedure TN_UDNLegend.SetElemsD


//********** TN_UDPicture class methods  **************

//********************************************** TN_UDPicture.Create ***
//
constructor TN_UDPicture.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDPictureCI;
  ImgInd := 41;
end; // end_of constructor TN_UDPicture.Create

//********************************************* TN_UDPicture.Destroy ***
//
destructor TN_UDPicture.Destroy;
begin
  PictRObj.Free;
  inherited Destroy;
end; // end_of destructor TN_UDPicture.Destroy

//********************************************** TN_UDPicture.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDPicture.PSP(): TN_PRPicture;
begin
  Result := TN_PRPicture(R.P());
end; // end_of function TN_UDPicture.PSP

//********************************************** TN_UDPicture.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDPicture.PDP(): TN_PRPicture;
begin
  if DynPar <> nil then Result := TN_PRPicture(DynPar.P())
                   else Result := TN_PRPicture(R.P());
end; // end_of function TN_UDPicture.PDP

//******************************************* TN_UDPicture.PISP ***
// return typed pointer to Individual Static Picture Params
//
function TN_UDPicture.PISP(): TN_PCPicture;
begin
  Result := @(TN_PRPicture(R.P())^.CPicture);
end; // function TN_UDPicture.PISP

//******************************************* TN_UDPicture.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic Picture Params
// otherwise return typed pointer to Individual Static Picture Params
//
function TN_UDPicture.PIDP(): TN_PCPicture;
begin
  if DynPar <> nil then
    Result := @(TN_PRPicture(DynPar.P())^.CPicture)
  else
    Result := @(TN_PRPicture(R.P())^.CPicture);
end; // function TN_UDPicture.PIDP

//********************************************** TN_UDPicture.PascalInit ***
// Init self
//
procedure TN_UDPicture.PascalInit();
var
  PRCompS: TN_PRPicture;
begin
  Inherited;
  PRCompS := PSP();
//  N_InitCPanel( @PRCompS^.CPanel );
  PictDecompressed := True;
  FillChar( PRCompS^.CPicture, Sizeof(TN_CPicture), 0 );

  with PRCompS^.CPicture do
  begin
    PictType  := cptNotDef;
    PictFName := '';
    PictFragm := Rect(0,0,-1,-1);
    PictScale := 0;
    PictPlace := ppUpperLeft;
  end;
end; // procedure TN_UDPicture.PascalInit

//************************************** TN_UDPicture.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method.
// Draw picture in SelfRect
//
procedure TN_UDPicture.BeforeAction();
var
  i, j, NumDynColors, OutInt: integer;
  DVectCSS: TK_UDDCSSpace;
  PPal: PInteger;
  PRCompD: TN_PRPicture;
begin
  PRCompD := PDP();

  with PRCompD^, PRCompD^.CPicture do
  begin
    if PictNotVisible <> 0 then Exit; // Picture is invisible

    if (PictType = cptArchCompr) and not PictDecompressed then
      Decompress()
    else if (PictType = cptFile) and not PictLoaded then
      LoadFromFile()
    else if PictType = cptNotDef then
      Exit; // picture not defined yet

    if PictRObj = nil then // PictRObj should always exists
      TN_RasterObj.Create( @PictRaster );

//    N_ud := PictDynColors;
//    N_i := Ord(PictRaster.RPixFmt);

    //***** Prepare Dynamic Palette if needed
    if (PictDynColors <> nil) and (PictRaster.RPixFmt <= pf8bit) then
    begin // set Picture Paletee by given Dyn Colors

      PictReIndVect := nil;
      if (PictDynColors is TK_UDVector) and
                       (PictCSS <> nil)     then // create PictReIndVect
      begin
        DVectCSS := TK_UDVector(PictDynColors).GetDCSSpace();
        // DynColors Picture always has 256 color palette, Ind=255 is transparent
        SetLength( PictReIndVect, 255 );

        for i := 0 to 254 do
          PictReIndVect[i] := -1;

        K_BuildDataProjection( DVectCSS, PictCSS, @PictReIndVect[0], OutInt );

      end; // if ... then  // create PictReIndVect

      NumDynColors := PictDynColors.ALength();
      PPal := PictRObj.PPalColors;

      for i := 0 to 254 do
      begin

        if PictReIndVect = nil then // use Palette Index
        begin
          if i < NumDynColors then
            PPal^ := PInteger(PictDynColors.R.P( i ))^;
        end else // use PictReIndVect
        begin
          j := PictReIndVect[i];
          if j <> -1 then
            PPal^ := N_SwapRedBlueBytes( PInteger(PictDynColors.R.P( j ))^ );
        end;

        Inc(PPal);

      end; // for i := 0 to 254 do
    end; // if (PictDynColors <> nil) and (PictRaster.RPixFmt <= pf8bit) then

    with NGCont do
    begin
//      PictRect := DrawCPanel( CPanel, CompIntPixRect );
      PictRObj.Draw( DstOCanv.HMDC, CompIntPixRect, PictFragm, PictScale, PictPlace);
   end; // with NGCont do

  end; // with PRCompD^, PRCompD^.CPicture do
end; // end_of procedure TN_UDPicture.BeforeAction

//********************************************** TN_UDPicture.GetPixPictSize ***
// Return Picture Pixel Sizes
//
function TN_UDPicture.GetPixPictSize(): TPoint;
begin
  with PISP()^ do
  begin
    Result := Point(-1,-1);
    if PictType = cptNotDef then Exit;

    if (PictType = cptFile) and not PictLoaded then
      LoadFromFile();

//    Result := FPoint( PictRaster.RWidth+2*CPanel.BorderWidth,    // what is better?
//                      PictRaster.RHeight+2*CPanel.BorderWidth );
    Result := Point( PictRaster.RWidth, PictRaster.RHeight );
  end;
end; // end_of procedure TN_UDPicture.GetPixPictSize

//************************************* TN_UDPicture.SetUCoordsByPixelSizeS ***
// Set Component Coords By PixelSize so that User coords are equal to Pixel Coords
//
function TN_UDPicture.SetUCoordsByPixelSizeS(): TFRect;
var
  PictSize: TPoint;
begin
  Result := Frect( N_NotAFloat, 0,0,0 );
  PictSize := GetPixPictSize();
  if PictSize.X = -1 then Exit; // Picture Sze not defined

  with PISP()^, PCCS()^ do
  begin
    BPcoords := FPoint( -0.5, -0.5 );
    BPXCoordsType := cbpUser;
    BPYCoordsType := cbpUser;

    LRcoords := FPoint( PictSize.X-0.5, PictSize.Y-0.5 );
    LRXCoordsType := cbpUser;
    LRYCoordsType := cbpUser;

    SRSizeXType := cstNotGiven;
    SRSizeYType := cstNotGiven;

    Result := Frect( -0.5, -0.5, PictSize.X-0.5, PictSize.Y-0.5 );
  end; // with PISP()^, PCCS()^ do
end; // function TN_UDPicture.SetUCoordsByPixelSizeS

//********************************************** TN_UDPicture.LoadFromFile ***
// Load Picture from PictFName
//
procedure TN_UDPicture.LoadFromFile();
begin
  with PDP()^, PIDP()^ do
  begin
    if PictType = cptNotDef then Exit;
    PictRObj := TN_RasterObj.Create( PictRaster.RType,
                      K_ExpandFileName( PictFName ), PictRaster.RTranspColor );
    PictRaster := PictRObj.RR;
//!!C1P    CPanel.BackColor := N_EmptyColor;
    PictLoaded := True;
  end; // with TN_PCPicture(PStat)^, PCC^ do
end; // procedure TN_UDPicture.LoadFromFile

//********************************************** TN_UDPicture.Compress ***
// Compress Raster to PictAsZLibRA RArray of byte
//
procedure TN_UDPicture.Compress();
var
  MStream: TMemoryStream;
  ZStream: TCompressionStream;
  RObj: TN_RasterObj;
  PPict: TN_PCPicture;
begin
  PPict := PISP();
  RObj := TN_RasterObj.Create( @(PPict^.PictRaster) );

  with PPict^, RObj do
  begin
    MStream := TMemoryStream.Create();
    ZStream := TCompressionStream.Create( clMax,  MStream );

    ZStream.Write( PRasterBytes^, RRasterSize );

    if RMaskSize > 0 then
      ZStream.Write( PMaskBytes^, RMaskSize );

    if RR.RNumPalColors > 0 then
      ZStream.Write( PPalColors^, RR.RNumPalColors*Sizeof(Integer) );

    ZStream.Free;

    if PictAsZLibRA = nil then
      PictAsZLibRA := K_RCreateByTypeName( 'Byte', MStream.Size )
    else
      TK_RArray(PictAsZLibRA).ASetLength( MStream.Size );

    MStream.Position := 0;
    MStream.Read( TK_RArray(PictAsZLibRA).P^, MStream.Size );
    MStream.Free;
  end; // with PPict^, RObj do
  RObj.Free;
end; // procedure TN_UDPicture.Compress

//********************************************** TN_UDPicture.Decompress ***
// Decompress Raster from PictAsZLibRA RArray of byte
//
procedure TN_UDPicture.Decompress();
var
  MStream: TMemoryStream;
  ZStream: TDecompressionStream;
  RObj: TN_RasterObj;
  PPict: TN_PCPicture;
begin
  PPict := PISP();
  RObj := TN_RasterObj.Create( @(PPict^.PictRaster) );

  with PPict^, RObj do
  begin
    Assert( PictAsZLibRA <> nil, 'Bad PictAsZLibRA' ); // a precaution

    MStream := TMemoryStream.Create();
    MStream.Write( TK_RArray(PictAsZLibRA).P^, TK_RArray(PictAsZLibRA).ALength );
    MStream.Position := 0;

    ZStream := TDecompressionStream.Create( MStream );

    ZStream.Read( PRasterBytes^, RRasterSize );

    if RMaskSize > 0 then
      ZStream.Read( PMaskBytes^, RMaskSize );

    if RR.RNumPalColors > 0 then
      ZStream.Read( PPalColors^, RR.RNumPalColors*Sizeof(Integer) );

    ZStream.Free;

    if PictAsZLibRA = nil then
      PictAsZLibRA := K_RCreateByTypeName( 'Byte', MStream.Size );

    MStream.Read( TK_RArray(PictAsZLibRA).P^, MStream.Size );
    MStream.Free;

    PictDecompressed := True;
  end; // with PPict^, RObj do
  RObj.Free;
end; // procedure TN_UDPicture.Decompress

//********************************************** TN_UDPicture.ChangeType ***
// Change Picture Type
//
procedure TN_UDPicture.ChangeType( ANewType: TN_CPictType );
var
  RObj: TN_RasterObj;
  PPict: TN_PCPicture;
begin
  PPict := PISP();
  RObj := TN_RasterObj.Create( @(PPict^.PictRaster) );

  with PPict^, RObj do
  begin
    // not implemented

  end; // with PPict^, RObj do
  RObj.Free;
end; // procedure TN_UDPicture.ChangeType


//******************* TN_UDDIB class methods  **************

//********************************************************* TN_UDDIB.Create ***
//
constructor TN_UDDIB.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDDIBCI;
  ImgInd := 41;
end; // end_of constructor TN_UDDIB.Create

//******************************************************** TN_UDDIB.Destroy ***
//
destructor TN_UDDIB.Destroy;
var
  FName: string;
begin
  with PISP()^ do // STATIC Params should be used!
  begin
    if uddfnIsFileOwner in CDIBFlagsN then // Self is File Owner, delete it
    begin
      FName := ImageFullFileName();
      if FileExists( FName ) then
        DeleteFile( FName );
    end; // if uddfFileOwner in CDIBFlagsN then // Self is File Owner, delete it
  end; // with PISP()^ do

  DIBObj.Free;
  UDData := nil;

  inherited Destroy;
end; // end_of destructor TN_UDDIB.Destroy


    //************* TN_UDBase methods of TN_UDDIB

//************************************************ TN_UDDIB.AddFieldsToSBuf ***
// Save Self to Serial binary Buf
//
procedure TN_UDDIB.AddFieldsToSBuf( SBuf: TN_SerialBuf );
var
  NeededSize: integer;
begin
  Inherited; // save all TN_RDIBN fields (save all except raster data)

  with SBuf, PISP()^ do // save Raster data (form DIBObj or UDData runtime fields)
  begin
    // uddfnSkipSavingData means that no raster data will be saved
    if uddfnSkipSavingData in CDIBFlagsN then Exit; // should be used only with uddfnUseFile

    if uddfnUseUDData in CDIBFlagsN then // save UDData field (DIBObj content in external format)
    begin
      if Length(UDData) = 0 then // create UDData from DIBObj, otherwise it should be already OK
      begin
        if DIBObj <> nil then
          CreateUDDataFromDIBObj()
        else
          Assert( False, 'TN_UDDIB.AddFieldsToSBuf: DIBObj is absent!' );
      end; // if Length(UDData) = 0 then // ctrate UDData from DIBObj

      //***** Here: UDData is OK

      if (uddfnUseFile in CDIBFlagsN) and
         (uddfnAutoSaveToFile in CDIBFlagsN) then // save UDData to CDIBFName File
      begin
        Assert( False, 'TN_UDDIB.AddFieldsToSBuf: not implemented1!' );
        Exit;
      end;

      //***** Save UDData content

      NeededSize := Length(UDData);
      AddRowBytes( 4, PByte(@NeededSize) );
      if NeededSize = 0 then Exit; // all done for empty DIBObj

      IncCapacity( NeededSize );
      move( UDData[0], Buf1[OfsFree], NeededSize );
      Inc( OfsFree, NeededSize );

      if (uddfnFreeUDData in CDIBFlagsN) and (DIBObj <> nil) then
        UDData := nil; // to free memory after saving (UDData is not needed because all data are DIBObj)

    end else //***** uddfnUseUDData is not set,
             //      save DIBObj field in internal not compressed DIBObj format
             //      using SerializeSelf method
    begin
      if (uddfnUseFile in CDIBFlagsN) and
         (uddfnAutoSaveToFile in CDIBFlagsN) then // save DIBObj to CDIBFName File
      begin
        if DIBObj = nil then Exit; // a precaution

        Assert( False, 'TN_UDDIB.AddFieldsToSBuf: not implemented2!' );
        Exit;
      end;

      if DIBObj = nil then
      begin
        NeededSize := 0;
        AddRowBytes( 4, PByte(@NeededSize) );
        Exit; // all done for empty DIBObj
      end;

      NeededSize := DIBObj.SerializedSize();

      AddRowBytes( 4, PByte(@NeededSize) );
      IncCapacity( NeededSize );
      DIBObj.SerializeSelf( @Buf1[OfsFree], NeededSize );
      Inc( OfsFree, NeededSize );
    end;
  end; // with SBuf, PISP()^ do
end; // end_of procedure TN_UDDIB.AddFieldsToSBuf

//********************************************** TN_UDDIB.GetFieldsFromSBuf ***
// Load Self from Serial Buf
//
procedure TN_UDDIB.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
var
  NeededSize: integer;
begin
  Inherited; // load all TN_RDIB or TN_RDIBN fields (load all except raster data)

  UDData := nil;
  FreeAndNil( DIBObj );

  if R.ElemType.DTCode = N_SPLTC_RDIB then // old format (TN_RDIB), convert to TN_RDIBN
  begin
    ConvRDIBToRDIBN();

    DIBObj := TN_DIBObj.Create();

    with SBuf do
    begin
      GetRowBytes( 4, PByte(@NeededSize) );
      DIBObj.DeSerializeSelf( @Buf1[SBuf.CurOfs] );
      Inc( CurOfs, NeededSize );
    end;

    Exit; // all done for old format (TN_RDIB)
  end; // if R.ElemType.DTCode = N_SPLTC_RDIB then // old format (TN_RDIB), convert to TN_RDIBN

  //*** load from new TN_RDIBN format

  with SBuf, PISP()^ do // load Raster data (DIBObj or UDData runtime fields)
  begin
    if uddfnUseUDData in CDIBFlagsN then // load UDData (DIBObj content in external format)
    begin
      GetRowBytes( 4, PByte(@NeededSize) );
      SetLength( UDData, NeededSize );
      move( Buf1[CurOfs], UDData[0], NeededSize );
      Inc( CurOfs, NeededSize );

      // UDData field is OK, create DIBObj from it if needed
      if uddfnAutoCreateDIB in CDIBFlagsN then
        LoadDIBObj();

    end else //***** uddfnUseUDData is not set,
             //      load DIBObj field from internal DIBObj format
    begin
      GetRowBytes( 4, PByte(@NeededSize) );

      if NeededSize > 0 then
      begin
        DIBObj := TN_DIBObj.Create();

        DIBObj.DeSerializeSelf( @Buf1[CurOfs] );
        Inc( CurOfs, NeededSize );
      end; // if NeededSize > 0 then

    end; // if uddfnUseUDData in CDIBFlagsN then ... else
  end; // with SBuf, PISP()^ do
end; // end_of procedure TN_UDDIB.GetFieldsFromSBuf

//************************************************ TN_UDDIB.AddFieldsToText ***
// Save Self to Serial Text Buf
//
function TN_UDDIB.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                   AShowFlags : Boolean = true ): Boolean;
var
  NeededSize: integer;
  TmpBuf: TN_BArray;
begin
  inherited AddFieldsToText( SBuf, AShowFlags ); // save all TN_RDIBN fields (save all except raster data)
  Result := True;

  with SBuf, PISP()^ do // save Raster data (form DIBObj or UDData runtime fields)
  begin
    // uddfnSkipSavingData means that no raster data will be saved
    if uddfnSkipSavingData in CDIBFlagsN then Exit; // should be used only with uddfnUseFile

    if uddfnUseUDData in CDIBFlagsN then // save UDData field (DIBObj content in external format)
    begin
      if Length(UDData) = 0 then // create UDData from DIBObj, otherwise it should be already OK
      begin
        if DIBObj <> nil then
          CreateUDDataFromDIBObj()
        else
          Assert( False, 'TN_UDDIB.AddFieldsToText: DIBObj is absent!' );
      end; // if Length(UDData) = 0 then // ctrate UDData from DIBObj

      //***** Here: UDData is OK

      if (uddfnUseFile in CDIBFlagsN) and
         (uddfnAutoSaveToFile in CDIBFlagsN) then // save UDData to CDIBFName File
      begin
        Assert( False, 'TN_UDDIB.AddFieldsToText: not implemented1!' );
        Exit;
      end;

      //***** Save UDData content

      NeededSize := Length(UDData);

      AddTag( 'UDDIBData', tgOpen );
      AddBytes( PByte(@NeededSize), 4 );

      if NeededSize > 0 then
        AddBytes( @UDData[0], NeededSize );

      AddEOL();
      AddTag( 'UDDIBData', tgClose );
      if (uddfnFreeUDData in CDIBFlagsN) and (DIBObj <> nil) then
        UDData := nil; // to free memory after saving (UDData is not needed because all data are DIBObj)
    end else //***** uddfnUseUDData is not set,
             //      save DIBObj field in internal not compressed DIBObj format
             //      using SerializeSelf method
    begin
      if (uddfnUseFile in CDIBFlagsN) and
         (uddfnAutoSaveToFile in CDIBFlagsN) then // save DIBObj to CDIBFName File
      begin
        if DIBObj = nil then Exit; // a precaution

        Assert( False, 'TN_UDDIB.AddFieldsToText: not implemented2!' );
        Exit;
      end;

      if DIBObj <> nil then
        NeededSize := DIBObj.SerializedSize()
      else
        NeededSize := 0;

      AddTag( 'UDDIBData', tgOpen );
      AddBytes( PByte(@NeededSize), 4 );

      if NeededSize > 0 then
      begin
        SetLength( TmpBuf, NeededSize );
        DIBObj.SerializeSelf( @TmpBuf[0], NeededSize );
        AddBytes( @TmpBuf[0], NeededSize );
      end;

      AddEOL();
      AddTag( 'UDDIBData', tgClose );
    end;
  end; // with SBuf, PISP()^ do

end; // end_of procedure TN_UDDIB.AddFieldsToText

//********************************************** TN_UDDIB.GetFieldsFromText ***
// Load Self from Serial Text Buf
//
// if (uddfUseFile in CDIBFlagsN) or (uddfUseBArray in CDIBFlagsN) Self DIBObj
// should be created later by application
//
function TN_UDDIB.GetFieldsFromText( SBuf: TK_SerialTextBuf ): Integer;
var
  NeededSize: integer;
  TmpBuf: TN_BArray;
begin
  inherited GetFieldsFromText( SBuf ); // load all TN_RDIB or TN_RDIBN fields (load all except raster data)
  Result := 0;
  N_s := ObjName; // debug
  if N_s = 'TestUDDIB2' then
    N_i := 1;

  UDData := nil;
  FreeAndNil( DIBObj );

  if R.ElemType.DTCode = N_SPLTC_RDIB then // old format (TN_RDIB), convert to TN_RDIBN
  begin
    ConvRDIBToRDIBN();

    with SBuf do
    begin
      DIBObj := TN_DIBObj.Create();

      GetSpecTag( 'DIBData', tgOpen );
      GetBytes( PByte(@NeededSize), 4 );
      SetLength( TmpBuf, NeededSize );
      GetBytes( @TmpBuf[0], NeededSize );
      DIBObj.DeSerializeSelf( @TmpBuf[0] );
      GetSpecTag( 'DIBData', tgClose );
    end; // with SBuf do

    Exit; // all done for old format (TN_RDIB)
  end; // if R.ElemType.DTCode = N_SPLTC_RDIB then // old format (TN_RDIB), convert to TN_RDIBN

  //*** load from new TN_RDIBN format

  with SBuf, PISP()^ do // load Raster data (DIBObj or UDData runtime fields)
  begin
    if uddfnUseUDData in CDIBFlagsN then // load UDData (DIBObj content in external format)
    begin
      GetSpecTag( 'UDDIBData', tgOpen );
      GetBytes( PByte(@NeededSize), 4 );
      SetLength( UDData, NeededSize );
      GetBytes( @UDData[0], NeededSize );
      GetSpecTag( 'UDDIBData', tgClose );

      // UDData field is OK, create DIBObj from it if needed
      if uddfnAutoCreateDIB in CDIBFlagsN then
        LoadDIBObj();

    end else //***** uddfnUseUDData is not set,
             //      load DIBObj field from internal DIBObj format
    begin
      DIBObj := TN_DIBObj.Create();

      GetSpecTag( 'UDDIBData', tgOpen );
      GetBytes( PByte(@NeededSize), 4 );
      SetLength( TmpBuf, NeededSize );
      GetBytes( @TmpBuf[0], NeededSize );
      DIBObj.DeSerializeSelf( @TmpBuf[0] );
      GetSpecTag( 'UDDIBData', tgClose );
    end;
  end; // with SBuf, PISP()^ do
end; // end_of procedure TN_UDDIB.GetFieldsFromText

//***************************************************** TN_UDDIB.CopyFields ***
// Copy to Self given TN_UDDIB object
//
procedure TN_UDDIB.CopyFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution
  inherited;
end; // end_of procedure TN_UDDIB.CopyFields


    //************* TN_UDDIB methods of TN_UDDIB

//************************************************************ TN_UDDIB.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDDIB.PSP(): TN_PRDIBN;
begin
  Result := TN_PRDIBN(R.P());
end; // end_of function TN_UDDIB.PSP

//************************************************************ TN_UDDIB.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDDIB.PDP(): TN_PRDIBN;
begin
  if DynPar <> nil then Result := TN_PRDIBN(DynPar.P())
                   else Result := TN_PRDIBN(R.P());
end; // end_of function TN_UDDIB.PDP

//*********************************************************** TN_UDDIB.PISP ***
// return typed pointer to Individual Static DIB Params
//
function TN_UDDIB.PISP(): TN_PCDIBN;
begin
  Result := @(TN_PRDIBN(R.P())^.CDIBN);
end; // function TN_UDDIB.PISP

//*********************************************************** TN_UDDIB.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic DIB Params
// otherwise return typed pointer to Individual Static DIB Params
//
function TN_UDDIB.PIDP(): TN_PCDIBN;
begin
  if DynPar <> nil then
    Result := @(TN_PRDIBN(DynPar.P())^.CDIBN)
  else
    Result := @(TN_PRDIBN(R.P())^.CDIBN);
end; // function TN_UDDIB.PIDP

//***************************************************** TN_UDDIB.PascalInit ***
// Init self
//
procedure TN_UDDIB.PascalInit();
begin
  Inherited;
end; // procedure TN_UDDIB.PascalInit

//**************************************************** TN_UDDIB.CalcParams1 ***
// Calculate several Self Params just after end of Settings
//
// Now only Aspect is calculated if cffFullAspSize is set
//
procedure TN_UDDIB.CalcParams1( );
begin
  Inherited;

  with PCCD()^ do
  begin
    if cffFullAspSize in CurFreeFlags then // Calc Image Aspect
    begin
      LoadDIBObj();

      with DIBObj.DIBSize do
      begin
        if Y = 0 then SRSizeAspect := 1.0
                 else SRSizeAspect := 1.0*Y / X;
        N_d := SRSizeAspect; // for debug only
      end;
    end;
  end; // with PCCD()^ do
end; // procedure TN_UDDIB.CalcParams1

//************************************************ TN_UDDIB.ConvRDIBToRDIBN ***
// Convert Self.R field from TN_RDIB to TN_RDIBN type
//
procedure TN_UDDIB.ConvRDIBToRDIBN();
var
  OldFlags: TN_UDDIBFlags;
  RDIB: TN_RDIB;
begin
  move( R.P()^, RDIB, SizeOf(RDIB) ); // save
  ZeroMemory( R.P(), SizeOf(RDIB) );
  R.Free;


  R := K_RCreateByTypeName( 'TN_RDIBN', 1 );

  //*** first TN_RDIBN fields except FlagsN are exactly the same as TN_RDIB
  OldFlags := RDIB.CDIB.CDIBFlags; // the only needed field

  move( RDIB, R.P()^, SizeOf(RDIB) ); // restore
//  N_s1 := RDIB.CDIB.CDIBFName;
//  N_s2 := PISP()^.CDIBFName;
  ZeroMemory( @RDIB, SizeOf(RDIB) );



  with PISP()^ do // set CDIBFlagsN by OldFlags
  begin
//    CDIBFName := RDIB.CDIB.CDIBFName;
//    CDIBInfo := RDIB.CDIB.CDIBInfo;
//    CDIBURect := RDIB.CDIB.CDIBURect;
//    CDIBTranspColor := RDIB.CDIB.CDIBTranspColor;
//    CDIBBArray := RDIB.CDIB.CDIBBArray;
    CDIBFlagsN := [];

    if uddfUseFile     in OldFlags then CDIBFlagsN := CDIBFlagsN + [uddfnUseFile];
    if uddfFileOwner   in OldFlags then CDIBFlagsN := CDIBFlagsN + [uddfnIsFileOwner];
    if uddUseCDIBURect in OldFlags then CDIBFlagsN := CDIBFlagsN + [uddfnUseCDIBURect];
  end; // with PISP()^ do // set CDIBFlagsN by OldFlags
end; // procedure TN_UDDIB.ConvRDIBToRDIBN

//*********************************************** TN_UDParaBox.FillParaBox1 ***
// Prepare UDData aditional Info if needed
//
//     Parameters
// APAddInfo - pointer to UDData Aditional Info record
// Result    - Returns TRUE if UDData Aditional Info is neede and was prepared
//
function  TN_UDDIB.PrepUDDataAddInfo( APAddInfo : TN_PUDDataAddInfo ) : Boolean;
begin
  with DIBObj do
  begin
    Result := (DIBExPixFmt = epfGray8)                           or
              ((DIBExPixFmt = epfGray16) and (DIBNumBits <> 16)) or
              ((DIBExPixFmt = epfBMP)    and (DIBPixFmt = pf24bit)); // Additional Info is needed
    if Result then
    begin
      FillChar( APAddInfo^, SizeOf(TN_UDDataAddInfo), 0 );
      Move( N_UDDataAddInfoSignature[1], APAddInfo^.UAISignature1[0], Length(N_UDDataAddInfoSignature) );
      Move( N_UDDataAddInfoSignature[1], APAddInfo^.UAISignature2[0], Length(N_UDDataAddInfoSignature) );
      if DIBExPixFmt = epfGray8 then
        APAddInfo^.UAIFlags := 1;
      if DIBExPixFmt = epfGray16 then
        APAddInfo^.UAINumBits := DIBNumBits;
    end;
  end;
end; // function  TN_UDDIB.PrepUDDataAddInfo

//***************************************** TN_UDDIB.CreateUDDataFromDIBObj ***
// Create UDData field from DIBObj field
//
procedure TN_UDDIB.CreateUDDataFromDIBObj();
var
  MStream : TK_SelfMemStream;
  RIEncodingInfo : TK_RIFileEncInfo;
  UDDataAddInfo : TN_UDDataAddInfo;
begin
  with PISP()^ do
  begin
    Assert( (CDIBDataFormat <> uddfNotDef),
            'TN_UDDIB.CreateUDDataFromDIBObj CDIBDataFormat: not implemented!' );
    MStream := TK_SelfMemStream.CreateBArrrayStream( UDData );
    if (CDIBDataFormat >= uddfBMP) and
       (CDIBDataFormat <= uddfPNG) then
    begin
    // Raster Image Serialization
      with K_RIObj do
      begin
        RIClearFileEncInfo( @RIEncodingInfo );
        case CDIBDataFormat of
        uddfBMP  : RIEncodingInfo.RIFileEncType := rietBMP;
        uddfGIF  : RIEncodingInfo.RIFileEncType := rietGIF;
        uddfJPEG : RIEncodingInfo.RIFileEncType := rietJPG;
        uddfTIF  : RIEncodingInfo.RIFileEncType := rietTIF;
        uddfPNG  : RIEncodingInfo.RIFileEncType := rietPNG;
        end;
        RIEncodingInfo.RIFComprQuality := CDIBJPEGQuality;
        RISaveDIBToStream( DIBObj, MStream, @RIEncodingInfo );
      end;
      if PrepUDDataAddInfo( @UDDataAddInfo ) then
        MStream.Write( UDDataAddInfo, SizeOf(TN_UDDataAddInfo) );
    end else
    begin
    // Self serialization
      if CDIBDataFormat < uddfDIBSer0 then
        CDIBDataFormat := uddfDIBSer0;
      MStream.SetSize( DIBObj.SerializedSize() );
      DIBObj.SelfToStream( MStream, Ord(CDIBDataFormat) - Ord(uddfDIBSer0) );
    end;
    SetLength( UDData, MStream.Position );
    MStream.Free;
  end;
end; // procedure TN_UDDIB.CreateUDDataFromDIBObj
{
//***************************************** TN_UDDIB.CreateUDDataFromDIBObj ***
// Create UDData field from DIBObj field
//
procedure TN_UDDIB.CreateUDDataFromDIBObj();
var
  MStream : TK_SelfMemStream;
  FMimeType : TK_GPImgMimeType;
begin
  with PISP()^ do
  begin
    Assert( (CDIBDataFormat <> uddfNotDef),
            'TN_UDDIB.CreateUDDataFromDIBObj CDIBDataFormat: not implemented!' );
    MStream := TK_SelfMemStream.CreateBArrrayStream( UDData );
    if (CDIBDataFormat >= uddfBMP) and
       (CDIBDataFormat <= uddfPNG) then
    begin
    // GDI+ serialization
      FMimeType := TK_GPImgMimeType( Ord(CDIBDataFormat) - Ord(uddfBMP) );
      with TK_GPDIBCodecsWrapper.Create do begin
      // Save DIB
        if FMimeType = K_gpiJPG then
          GPEncQuality := CDIBJPEGQuality;
        GPSaveDIBObjToStream( DIBObj, MStream, FMimeType );
        Free;
      end;
    end else
    begin
    // Self serialization
      if CDIBDataFormat < uddfDIBSer0 then
        CDIBDataFormat := uddfDIBSer0;
      MStream.SetSize( DIBObj.SerializedSize() );
      DIBObj.SelfToStream( MStream, Ord(CDIBDataFormat) - Ord(uddfDIBSer0) );
    end;
    SetLength( UDData, MStream.Position );
    MStream.Free;
  end;
end; // procedure TN_UDDIB.CreateUDDataFromDIBObj
}
//*************************************************** TN_UDDIB.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDDIB.BeforeAction();
var
  CurTranspColor: integer;
  BufRect: TRect;
  PRCompD: TN_PRDIBN;
begin

  PRCompD := PDP();
  with PRCompD^, PRCompD^.CDIBN do
  begin
    LoadDIBObj();
//    DIBObj.DIBDumpSelf( 'UDDIB DIB', 4 ); // debug

    if uddfnUseCDIBURect in CDIBFlagsN then
      BufRect := N_AffConvF2IRect( CDIBURect, NGCont.DstOCanv.U2P )
    else
      BufRect := CompIntPixRect;

    CurTranspColor := CDIBTranspColor;
    if CurTranspColor = -3 then // special case because CDIBTranspColor = 0
       CurTranspColor := 0;     // is a default value and means no Transp Color

    if (CDIBTranspColor = -3) or (CDIBTranspColor > 0) then // use CurTranspColor
      NGCont.DstOCanv.DrawTranspDIB( DIBObj, BufRect, Rect(0,0,-1,-1), CurTranspColor )
    else // do not use any transp color (normal drawing)
      NGCont.DstOCanv.DrawPixDIB( DIBObj, BufRect, Rect(0,0,-1,-1) );

//  N_CopyRect( NGCont.DstOCanv.HMDC, Point(0,0), DIBObj.DIBOCanv.HMDC, Rect(30, 30, 100, 200) );
//  N_TestRectDraw ( NGCont.DstOCanv, 5, 5, 255 ); // debug
  end; // PRCompD^, PRCompD^.CDIB do
end; // end_of procedure TN_UDDIB.BeforeAction

//********************************************** TN_UDDIB.ImageFullFileName ***
// Return Image Full FileName from STATIC Params
//
// If using Dynamic params, when changing CDIBFName, you will have to change
// both Dynamic and Static Params and it is not convinient.
//
function TN_UDDIB.ImageFullFileName(): string;
begin
  with PISP()^ do
  begin
    Result := K_ExpandFileName( CDIBFName )
  end; // with PISP()^ do
end; // function TN_UDDIB.ImageFullFileName


//***************************************************** TN_UDDIB.LoadDIBObj ***
// Load Self DIBObj from File in BMP format or
// from BArray (in STATIC Params!) if not yet
//
procedure TN_UDDIB.LoadDIBObj( );
var
  WrongDataFormat : Boolean;
  WrongDataFormatInfo : string;
  MStream : TK_SelfMemStream;
  TmpDIB : TN_DIBObj;
  DeserRes : Integer;
  TMPFStream : TFileStream;
  TMPFName : string;
  RIRCODE : TK_RIResult;
  MStreamSize : Integer;
  ConvToGrey : Integer;
  UDDataNUMBits : Integer;

begin
  if (Self = nil)    or
     (DIBObj <> nil) or
     (Length(UDData) = 0) then  // Self is not Assigned or DIB is already loaded
    Exit;

  with PISP()^ do
  begin
    MStream := nil;
    if uddfnUseUDData in CDIBFlagsN then // create DIBObj form from UDData field
    begin
      try
        // Check UDDataAddInfo
        ConvToGrey := 0;
        UDDataNUMBits := 0;
        MStreamSize := Length(UDData);
        if MStreamSize > SizeOf(TN_UDDataAddInfo) then
          with TN_PUDDataAddInfo(@UDData[MStreamSize - SizeOf(TN_UDDataAddInfo)])^ do
            if CompareMem( @N_UDDataAddInfoSignature[1], @UAISignature1[0], Length(N_UDDataAddInfoSignature) ) and
               CompareMem( @N_UDDataAddInfoSignature[1], @UAISignature2[0], Length(N_UDDataAddInfoSignature) ) then
            begin
              MStreamSize := MStreamSize - SizeOf(TN_UDDataAddInfo);
              ConvToGrey := -1;
              if (UAIFlags and 1) <> 0 then
                ConvToGrey := 1;

              UDDataNUMBits := UAINumBits;
            end;

        WrongDataFormatInfo := 'TK_SelfMemStream.Create error';
        MStream := TK_SelfMemStream.CreateMemStream( @UDData[0], MStreamSize );
//        MStream := TK_SelfMemStream.CreateBArrrayStream( UDData );
        DIBObj := TN_DIBObj.Create( 1, 1, pf24bit );
        WrongDataFormatInfo := 'TN_DIBObj.SelfFromStream error';
        DeserRes := DIBObj.SelfFromStream( MStream );
        WrongDataFormat := DeserRes <> 0;
        if DeserRes = 1 then
        begin
        // Wrong Self Stream Signature - try Raster Image
          WrongDataFormatInfo := 'RIOpenStream error';
          RIRCODE := K_RIObj.RIOpenStream( MStream );
          if (RIRCODE <> rirOK) and (K_RIObj is TK_RIGDIP) then
          begin
            if K_RIObj.RIGetLastNativeErrorCode() = Ord(Win32Error) then
            begin
            // Try to Use TMP File for DIB Loading
              FreeAndNil(MStream);
              TMPFName := K_ExpandFileName( '(#TMPFiles#)UDData.dat' );
              TMPFStream := TFileStream.Create(TMPFName, fmCreate);
              TMPFStream.Write( UDData[0], Length(UDData) );
              TMPFStream.Free;
              RIRCODE := K_RIObj.RIOpenFile( TMPFName );
              N_Dump2Str( 'Try ' + TMPFName + ' RCode=' + IntToStr(K_RIObj.RIGetLastNativeErrorCode()) );
            end;
          end;

          WrongDataFormat := RIRCODE <> rirOK;
          if not WrongDataFormat then
          begin
            WrongDataFormatInfo := 'wrong Raster Image data';
            RIRCODE := K_RIObj.RIGetDIB( 0, DIBObj );
            WrongDataFormat := RIRCODE <> rirOK;
            if not WrongDataFormat then
            begin
              if (DIBObj.DIBPixFmt = pf24bit) then
              begin
                if ConvToGrey = 0 then
                begin // Check if convertion to grey is needed
                  if DIBObj.GetMaxRGBDif( 0 ) <= 0 then
                    ConvToGrey := 1;
                end;

                if ConvToGrey = 1 then
                begin
                  WrongDataFormatInfo := 'TN_DIBObj.Create error';
                  TmpDIB := TN_DIBObj.Create( DIBObj.DIBSize.X, DIBObj.DIBSize.Y, pfCustom, -1, epfGray8 );
                  WrongDataFormatInfo := 'TN_DIBObj.CalcGrayDIB error';
                  DIBObj.CalcGrayDIB( TmpDIB );
                  FreeAndNil( DIBObj );
                  DIBObj := TmpDIB;
                end
              end
              else
              if (DIBObj.DIBExPixFmt = epfGray16) then
              begin
                if UDDataNUMBits <> 0 then // Restore from UDData
                  DIBObj.DIBNumBits := UDDataNUMBits;
                if DIBObj.DIBNumBits = 0 then
                  DIBObj.DIBNumBits := 16; // Precaution
//                  DIBObj.ReduceNumBits();
              end; // if (DIBObj.DIBExPixFmt = epfGray16) then
              DIBObj.CorrectResolution( -1 );
            end // if not WrongDataFormat then after K_RIObj.RIGetDIB
            else
            if RIRCODE = rirOutOfMemory then
              WrongDataFormatInfo := 'Raster Image out of memory'
          end // if not WrongDataFormat then after K_RIObj.RIOpenStream
          else
            WrongDataFormatInfo := 'wrong Raster Image Stream format';

        end // if DeserRes = 1 then
        else
        if DeserRes = 2 then
          WrongDataFormatInfo := 'wrong Self Stream size';

      except
        on E: Exception do
        begin
          WrongDataFormat := TRUE;
          WrongDataFormatInfo := WrongDataFormatInfo + ' >> '  + E.Message;
        end;
      end;

      K_RIObj.RIClose();
      MStream.Free;

      if WrongDataFormat then
      begin
        FreeAndNil( DIBObj );
        raise TK_LoadUDDataError.Create( format( 'TN_UDDIB.LoadDIBObj : DataSize=%d %s', [ Length(UDData), WrongDataFormatInfo] ) );
      end
      else
      if uddfnFreeUDData in CDIBFlagsN then UDData := nil; // to free memory
    end; // if uddfnUseUDData in CDIBFlagsN then // create DIBObj form from UDData field

    CDIBInfo := DIBObj.GetInfoString();
  end; // with PISP()^ do
end; // end_of procedure TN_UDDIB.LoadDIBObj
{
//***************************************************** TN_UDDIB.LoadDIBObj ***
// Load Self DIBObj from File in BMP format or
// from BArray (in STATIC Params!) if not yet
//
procedure TN_UDDIB.LoadDIBObj();
var
  GPCWrapper: TK_GPDIBCodecsWrapper;
  WrongDataFormat : Boolean;
  WrongDataFormatInfo : string;
  MStream : TK_SelfMemStream;
  RGBDiff : Double;
  TmpDIB : TN_DIBObj;
  DeserRes : Integer;
  GPResult : TStatus;
  TMPFStream : TFileStream;
  TMPFName : string;
begin
  if (Self = nil)    or
     (DIBObj <> nil) or
     (Length(UDData) = 0) then  // Self is not Assigned or DIB is already loaded
    Exit;

  with PISP()^ do
  begin
    if uddfnUseUDData in CDIBFlagsN then // create DIBObj form from UDData field
    begin
      try
        WrongDataFormatInfo := 'TK_SelfMemStream.Create error';
        MStream := TK_SelfMemStream.CreateBArrrayStream( UDData );
        DIBObj := TN_DIBObj.Create( 1, 1, pf24bit );
        WrongDataFormatInfo := 'TN_DIBObj.SelfFromStream error';
        DeserRes := DIBObj.SelfFromStream( MStream );
        WrongDataFormat := DeserRes <> 0;
        if DeserRes = 1 then
        begin
        // Wrong Self Stream Signature - try GDI+
          WrongDataFormatInfo := 'wrong Self Stream Signature';
          GPCWrapper := TK_GPDIBCodecsWrapper.Create;
          GPResult := GPCWrapper.GPLoadFromStream( MStream );
          if GPResult = Win32Error then
          begin
          // Try to Use TMP File for DIB Loading
            TMPFName := K_ExpandFileName( '(#TMPFiles#)UDData.dat' );
            TMPFStream := TFileStream.Create(TMPFName, fmCreate);
            TMPFStream.Write( UDData[0], Length(UDData) );
            TMPFStream.Free;
            GPResult := GPCWrapper.GPLoadFromFile( TMPFName );
            N_Dump2Str( 'Try ' + TMPFName + ' RCode=' + IntToStr(Word(GPResult)) );
          end;
          WrongDataFormat := GPResult <> Ok;
          if not WrongDataFormat then
          begin
            WrongDataFormatInfo := 'wrong GDI+ frame data';
            WrongDataFormat := GPCWrapper.GPGetFrameToDIBObj( DIBObj, 0 ) <> Ok;
            if not WrongDataFormat then
            begin
              WrongDataFormatInfo := 'TN_DIBObj.GetMaxRGBDif error';
              RGBDiff := DIBObj.GetMaxRGBDif( 0 );
              if RGBDiff <= 0 then // Convert DIBObj to Gray
              begin
                WrongDataFormatInfo := 'TN_DIBObj.Create error';
                TmpDIB := TN_DIBObj.Create( DIBObj, 0, pfCustom, -1, epfGray8 );
                WrongDataFormatInfo := 'TN_DIBObj.CalcGrayDIB error';
                DIBObj.CalcGrayDIB( TmpDIB );
                FreeAndNil( DIBObj );
                DIBObj := TmpDIB;
              end;
            end;
          end else
            WrongDataFormatInfo := 'wrong GDI+ Stream format';

          GPCWrapper.Free;
        end else if DeserRes = 2 then
          WrongDataFormatInfo := 'wrong Self Stream size';

        MStream.Free;
        if WrongDataFormat then
          FreeAndNil( DIBObj );

      except
        on E: Exception do
        begin
          WrongDataFormat := TRUE;
          WrongDataFormatInfo := WrongDataFormatInfo + ' >> '  + E.Message;
        end;
      end;

      if WrongDataFormat then
        raise TK_LoadUDDataError.Create( format( 'TN_UDDIB.LoadDIBObj : DataSize=%d %s', [ Length(UDData), WrongDataFormatInfo] ) );

      if uddfnFreeUDData in CDIBFlagsN then UDData := nil; // to free memory
    end; // if uddfnUseUDData in CDIBFlagsN then // create DIBObj form from UDData field

    CDIBInfo := DIBObj.GetInfoString();
  end; // with SBuf, PISP()^ do
end; // end_of procedure TN_UDDIB.LoadDIBObj
}
//***************************************************** TN_UDDIB.SaveDIBObj ***
// Save Self DIBObj to File in BMP format or to BArray (in STATIC Params!)
//
procedure TN_UDDIB.SaveDIBObj();
var
  PRCompS: TN_PRDIBN;
begin
  PRCompS := PSP();
  with PRCompS^.CDIBN do
  begin
    if DIBObj = nil then Exit; // a precaution

    if uddfnUseFile in CDIBFlagsN then // Save to File
    begin
      DIBObj.SaveToBMPFormat( ImageFullFileName() );
    end; // if uddfUseFile in CDIBFlagsT then // Save to File

{
  DataSize: integer;

    if uddfUseBArray in CDIBFlagsT then // Save to BArray
    begin
      DataSize := DIBObj.SerializedSize();
      if CDIBBArray = nil then
        CDIBBArray := K_RCreateByTypeCode( Ord(nptByte), DataSize )
      else
        CDIBBArray.ASetLength( DataSize );

      DIBObj.SerializeSelf( CDIBBArray.P(), DataSize );
    end; // if uddfUseBArray in CDIBFlagsT then // Save to BArray
}

    CDIBInfo := DIBObj.GetInfoString();
  end; // with PRCompD^.CDIB do
end; // end_of procedure TN_UDDIB.SaveDIBObj

//************************************************* TN_UDDIB.BufToDIBCoords ***
// Return DIB Pixel coords by given OCanv Buffer coords
// (TN_Rast1Frame.CCBuf can be used)
//
function TN_UDDIB.BufToDIBCoords( ABufCoords: TPoint ): TPoint;
var
  BufRect: TRect;
begin
  Result := Point( 0, 0 );
  if DIBObj = nil then Exit;

  with PISP()^ do
  begin
    if uddfnUseCDIBURect in CDIBFlagsN then
      BufRect := N_AffConvF2IRect( CDIBURect, CompU2P )
    else
      BufRect := CompIntPixRect;

    Result.X := Round( (0.5 + ABufCoords.X - BufRect.Left)*
                       DIBObj.DIBSize.X/(BufRect.Right - BufRect.Left + 1) - 0.5 );

    Result.Y := Round( (0.5 + ABufCoords.Y - BufRect.Top)*
                       DIBObj.DIBSize.Y/(BufRect.Bottom - BufRect.Top + 1) - 0.5 );
  end; // with PISP()^ do
end; // function TN_UDDIB.BufToDIBCoords


//********** TN_UDDIBRect class methods  **************

//***************************************************** TN_UDDIBRect.Create ***
//
constructor TN_UDDIBRect.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDDIBRectCI;
  ImgInd := 86;
end; // end_of constructor TN_UDDIBRect.Create

//**************************************************** TN_UDDIBRect.Destroy ***
//
destructor TN_UDDIBRect.Destroy;
begin
  XLATBufDIB.Free;
  inherited Destroy;
end; // end_of destructor TN_UDDIBRect.Destroy

//******************************************************** TN_UDDIBRect.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDDIBRect.PSP(): TN_PRDIBRect;
begin
  Result := TN_PRDIBRect(R.P());
end; // end_of function TN_UDDIBRect.PSP

//******************************************************** TN_UDDIBRect.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDDIBRect.PDP(): TN_PRDIBRect;
begin
  if DynPar <> nil then Result := TN_PRDIBRect(DynPar.P())
                   else Result := TN_PRDIBRect(R.P());
end; // end_of function TN_UDDIBRect.PDP

//******************************************************* TN_UDDIBRect.PISP ***
// return typed pointer to Individual Static DIBRect Params
//
function TN_UDDIBRect.PISP(): TN_PCDIBRect;
begin
  Result := @(TN_PRDIBRect(R.P())^.CDIBRect);
end; // function TN_UDDIBRect.PISP

//******************************************************* TN_UDDIBRect.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic DIBRect Params
// otherwise return typed pointer to Individual Static DIBRect Params
//
function TN_UDDIBRect.PIDP(): TN_PCDIBRect;
begin
  if DynPar <> nil then
    Result := @(TN_PRDIBRect(DynPar.P())^.CDIBRect)
  else
    Result := @(TN_PRDIBRect(R.P())^.CDIBRect);
end; // function TN_UDDIBRect.PIDP

//************************************************* TN_UDDIBRect.PascalInit ***
// Init self
//
procedure TN_UDDIBRect.PascalInit();
begin
  Inherited;
end; // procedure TN_UDDIBRect.PascalInit

//*********************************************** TN_UDDIBRect.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDDIBRect.BeforeAction();
var
  DstSize, DIBRight, DIBBottom, MinHistInd, MaxHistInd: integer;
  ScaleCoef: double;
  NegateBool: boolean;
  DstRect, DstBackRect, SrcRect, DIBSrcRect: TRect;
  ellipsrgn: HRGN;
  BrighHistValues: TN_IArray;
  PRCompD: TN_PRDIBRect;
  WrkCDRMode: TN_UDDIBRectMode;

  procedure PrepGrayBufDIB(); // local
  // Prepare epfGray8 BufDIB so that it contain proper CDRSrcUDDIB Rect
  // Sometimes color!
  begin
    with PRCompD^.CDIBRect do
    begin
      if BufDIB = nil then // Create BufDIB
        BufDIB := TN_DIBObj.Create( CDRSrcUDDIB.DIBObj, DIBSrcRect, pfCustom, epfGray8 )
      else if (BufDIB.DIBSize.X = N_RectWidth(DIBSrcRect))  and
              (BufDIB.DIBSize.Y = N_RectHeight(DIBSrcRect)) and
              (BufDIB.DIBPixFmt = pfCustom) and
              (BufDIB.DIBExPixFmt = epfGray8) then // Size and type are OK, just draw
        BufDIB.DIBOCanv.DrawPixDIB( CDRSrcUDDIB.DIBObj, BufDIB.DIBRect, DIBSrcRect )
      else // XLATBufDIB exists, but Size is not OK, recreate it
      begin
        BufDIB.Free;
        BufDIB := TN_DIBObj.Create( CDRSrcUDDIB.DIBObj, DIBSrcRect, pfCustom, epfGray8 )
      end;
    end; // with PRCompD^.CDIBRect do
  end; // procedure PrepGrayBufDIB(); // local

  procedure PrepColorBufDIB(); // local
  // Prepare pf24bit BufDIB by CDRSrcUDDIB DIBSrcRect content
  begin
    with PRCompD^.CDIBRect do
    begin
      if BufDIB = nil then // Create BufDIB
        BufDIB := TN_DIBObj.Create( CDRSrcUDDIB.DIBObj, DIBSrcRect, pf24bit, epfBMP )
      else if (BufDIB.DIBSize.X = N_RectWidth(DIBSrcRect))  and
              (BufDIB.DIBSize.Y = N_RectHeight(DIBSrcRect)) and
              (BufDIB.DIBPixFmt = pf24bit) and
              (BufDIB.DIBExPixFmt = epfBMP) then // Size and type are OK, just draw
        BufDIB.DIBOCanv.DrawPixDIB( CDRSrcUDDIB.DIBObj, BufDIB.DIBRect, DIBSrcRect )
      else // BufDIB exists, but Size or type are not OK, recreate BufDIB
      begin
        BufDIB.Free;
        BufDIB := TN_DIBObj.Create( CDRSrcUDDIB.DIBObj, DIBSrcRect, pf24bit, epfBMP )
      end;
    end; // with PRCompD^.CDIBRect do
  end; // procedure PrepColorBufDIB(); // local

begin //******************************************** main body of BeforeAction
  PRCompD := PDP();
  with PRCompD^.CDIBRect, NGCont.DstOCanv do
  begin
    if uddrfNewParams in CDRFlags then // use new params (with effects)
    begin
      if CDRSrcUDDIB = nil then
      begin
        if CDRSrcUDDIBPath = '' then Exit; // a precaution, Source UDDIB component not defined

        K_SetUDRefField( TN_UDBase(CDRSrcUDDIB), K_UDCursorGetObj(CDRSrcUDDIBPath) );
        if CDRSrcUDDIB = nil then Exit; // a precaution, Source UDDIB component not defined
      end;
    end else // use old params (without effects)
    begin
      if CDRSrcUDDIB = nil then Exit; // a precaution, Source UDDIB component not defined
    end; // end else // use old params (without effects)

    SrcRect := CDRSrcRect;
    with SrcRect do // a precaution, check if SrcRect is not Empty
      if (Left > Right) or (Top > Bottom) then Exit;

    CDRSrcUDDIB.LoadDIBObj();

    // Set Ellipse mask if needed (it shoud be done before any drawing!)

    if uddrfEllipseMask in CDRFlags then // create and select elliptical clip region
    begin
//      N_T1.Start();
//      with CompIntPixRect do
      with CompOuterPixRect do
        ellipsrgn := Windows.CreateEllipticRgn( Left, Top, Right+2, Bottom+2 ); // 0.025 msec for 32x32 rect
//      N_T1.SS( 'CreateEllipticRgn' );

      N_gdi := Windows.SelectObject( NGCont.DstOCanv.HMDC, ellipsrgn );
      //*** ellipsrgn can be deleted even while selected in DC
      N_b := Windows.DeleteObject( ellipsrgn );
    end; // if uddrfEllipseMask in CDRFlags then // create and select elliptical clip region

    // Clip CDRSrcRect manually by CDRSrcUDDIB (otherwise Windows.StretchDIBits works bad)
    // and calc DstPixRect from CompIntPixRect appropriately
    // (if CDRSrcRect is inside CDRSrcUDDIB.DIBObj.DIBRect then DstPixRect=CompIntPixRect)

    DstRect := CompIntPixRect;
    SetBrushAttribs( $000000 ); // fill color for DstBackRect

    // Adjust Horizontal coords

    ScaleCoef := 1.0*N_RectWidth(CompIntPixRect) / N_RectWidth(SrcRect);
    DIBRight  := CDRSrcUDDIB.DIBObj.DIBRect.Right; // to reduce code size

    if SrcRect.Left < 0 then // Clip left CDRSrcRect side
    begin
      SrcRect.Left := 0;
      DstSize := Round( ScaleCoef * N_RectWidth(SrcRect) );

      DstRect.Left := DstRect.Right - DstSize + 1;

      DstBackRect := CompIntPixRect;
      DstBackRect.Right := DstRect.Left - 1;

      if DstBackRect.Right >= DstBackRect.Left then
        DrawPixFilledRect( DstBackRect );
    end; // if CDRSrcRect.Left < 0 then // Clip left CDRSrcRect side

    if SrcRect.Right > DIBRight then // Clip right CDRSrcRect side
    begin
      SrcRect.Right := DIBRight;
      DstSize := Round( ScaleCoef * N_RectWidth(SrcRect) );

      DstRect.Right := DstRect.Left + DstSize - 1;

      DstBackRect := CompIntPixRect;
      DstBackRect.Left := DstRect.Right + 1;

      if DstBackRect.Right >= DstBackRect.Left then
        DrawPixFilledRect( DstBackRect );
    end; // if SrcRect.Right > DIBRight then // Clip right CDRSrcRect side

    // Adjust Vertical coords

    ScaleCoef := 1.0*N_RectHeight(CompIntPixRect) / N_RectHeight(SrcRect);
    DIBBottom := CDRSrcUDDIB.DIBObj.DIBRect.Bottom; // to reduce code size

    if SrcRect.Top < 0 then // Clip Top CDRSrcRect side
    begin
      SrcRect.Top := 0;
      DstSize := Round( ScaleCoef * N_RectHeight(SrcRect) );

      DstRect.Top := DstRect.Bottom - DstSize + 1;

      DstBackRect := CompIntPixRect;
      DstBackRect.Bottom := DstRect.Top - 1;

      if DstBackRect.Bottom >= DstBackRect.Top then
        DrawPixFilledRect( DstBackRect );
    end; // if CDRSrcRect.Top < 0 then // Clip Top CDRSrcRect side

    if SrcRect.Bottom > DIBBottom then // Clip Bottom CDRSrcRect side
    begin
      SrcRect.Bottom := DIBBottom;
      DstSize := Round( ScaleCoef * N_RectHeight(SrcRect) );

      DstRect.Bottom := DstRect.Top + DstSize - 1;

      DstBackRect := CompIntPixRect;
      DstBackRect.Top := DstRect.Bottom + 1;

      if DstBackRect.Bottom >= DstBackRect.Top then
        DrawPixFilledRect( DstBackRect );
    end; // if SrcRect.Bottom > DIBBottom then // Clip Bottom CDRSrcRect side

    // SrcRect, DstRect are OK
    // Convert SrcRect to DIBSrcRect
    // (Convert to DIB coords - (0,0) is lower left corner, Y axis from bottom up)

    DIBSrcRect := SrcRect;


    //***** Draw SrcRect (needed CDRSrcUDDIB fragment) in DstRect

    Windows.SetStretchBltMode( NGCont.DstOCanv.HMDC, N_UDDIBRectStretchBltMode );
//    Windows.SetStretchBltMode( NGCont.DstOCanv.HMDC, HALFTONE ); // for debug

    if uddrfNewParams in CDRFlags then // use new params (with effects), used for FlashLight tool
    begin

    //*** Prepare WrkCDRMode:
    //    if Emboss, Colorize or Isodensity tool is active then uddrmNoEffect mode should be used
    //    if Slide is not Gray, uddrmNoEffect mode should be used instead of uddrmEqualize or uddrmColorize

    WrkCDRMode := CDRMode;

    if (uddrfEmboss     in CDRFlags) or
       (uddrfColorize   in CDRFlags) or
       (uddrfIsodensity in CDRFlags)    then WrkCDRMode := uddrmNoEffect;

    if (not (uddrfGreyDIB in CDRFlags)) and
       ( (WrkCDRMode = uddrmEqualize) or (WrkCDRMode = uddrmColorize) ) then WrkCDRMode := uddrmNoEffect;

    case WrkCDRMode of

    uddrmNoEffect, uddrmNegate: begin //********* No special effect or negate
      if Length(TmpXLAT) < 256 then
        SetLength( TmpXLAT, 256 );

      // Create TmpXLAT
      NegateBool := (WrkCDRMode = uddrmNegate);
      N_BCGImageXlatBuild( TmpXLAT, 255, CDRCoFactor, CDRBriFactor, CDRGamFactor, 0, 100, NegateBool );
//      N_DumpXLAT( @TmpXLAT[0], 256, $41, 'C:\aa0.txt' );

      PrepColorBufDIB(); // Prepare Color BufDIB
//      BufDIB.SaveToBMPFormat( 'C:\aa1.bmp' );
      BufDIB.XLATSelf( @TmpXLAT[0], 1 );
      NGCont.DstOCanv.DrawPixDIB( BufDIB, DstRect, BufDIB.DIBRect );
//      BufDIB.SaveToBMPFormat( 'C:\aa2.bmp' );
    end; // uddrmNoEffect, uddrmNegate: begin // No special effect or negate

    uddrmEqualize: begin //********************************** Equalize effect
      PrepColorBufDIB(); // Prepare Color BufDIB
      BufDIB.CalcBrighHistNData( BrighHistValues, @BufDIB.DIBRect,
                                             @MinHistInd, @MaxHistInd, nil, 8 );

      if Length(TmpXLAT) < 256 then
        SetLength( TmpXLAT, 256 );

      N_SetXLATFragm( @TmpXLAT[0], MinHistInd, MaxHistInd, 0, 255 );

      BufDIB.XLATSelf( @TmpXLAT[0], 1 );
      NGCont.DstOCanv.DrawPixDIB( BufDIB, DstRect, BufDIB.DIBRect );
    end; // uddrmEqualize: begin //************************** Equalize effect

    uddrmColorize: begin //********************************** Colorize effect
      if CDRXLATClrz = nil then Exit; // a precaution, No XLAT Table for Colorize

      PrepColorBufDIB(); // Prepare BufDIB
      BufDIB.XLATSelf( CDRXLATClrz.P(0), 3 );
      NGCont.DstOCanv.DrawPixDIB( BufDIB, DstRect, BufDIB.DIBRect );
    end; // uddrmColorize: begin //************************** Colorize effect

    uddrmEmboss: begin //************************************** Emboss effect
      PrepGrayBufDIB(); // Prepare Gray8 BufDIB

      if BufDIB2 = nil then // Create BufDIB2
        BufDIB2 := TN_DIBObj.Create( N_RectWidth(DIBSrcRect), N_RectHeight(DIBSrcRect), pfCustom, -1, epfGray8 )
      else if (BufDIB2.DIBSize.X <> N_RectWidth(DIBSrcRect)) or
              (BufDIB2.DIBSize.Y <> N_RectHeight(DIBSrcRect))  then // BufDIB2 exists, but Size is not OK, recreate it
      begin
        BufDIB2.Free;
        BufDIB2 := TN_DIBObj.Create( N_RectWidth(DIBSrcRect), N_RectHeight(DIBSrcRect), pfCustom, -1, epfGray8 );
      end;

      BufDIB.CalcEmbossDIB( BufDIB2, CDREmbAngle, CDREmbCoef, CDREmbDepth, CDREmbBaseGrey );
      NGCont.DstOCanv.DrawPixDIB( BufDIB2, DstRect, BufDIB2.DIBRect );
    end; // uddrmEmboss: begin //****************************** Emboss effect

    end; // case WrkCDRMode of
    end else // use old params (without effects), used for Magnify Region tool
    begin

      if CDRXLATInts <> nil then // XLAT convertion is needed
      begin
        if XLATBufDIB = nil then // Create XLATBufDIB
          XLATBufDIB := TN_DIBObj.Create( CDRSrcUDDIB.DIBObj, DIBSrcRect, CDRSrcUDDIB.DIBObj.DIBPixFmt, CDRSrcUDDIB.DIBObj.DIBExPixFmt )
        else if (XLATBufDIB.DIBSize.X = N_RectWidth(DIBSrcRect)) and
                (XLATBufDIB.DIBSize.Y = N_RectHeight(DIBSrcRect))  then // Size is OK, just draw
          XLATBufDIB.DIBOCanv.DrawPixDIB( CDRSrcUDDIB.DIBObj, XLATBufDIB.DIBRect, DIBSrcRect )
        else // XLATBufDIB exists, but Size is not OK, recreate it
        begin
          XLATBufDIB.Free;
          XLATBufDIB := TN_DIBObj.Create( CDRSrcUDDIB.DIBObj, DIBSrcRect, CDRSrcUDDIB.DIBObj.DIBPixFmt, CDRSrcUDDIB.DIBObj.DIBExPixFmt )
        end;

        //***** XLATBufDIB is OK, XLAT it and draw it

        XLATBufDIB.XLATSelf( CDRXLATInts.P(0), 1 );
        NGCont.DstOCanv.DrawPixDIB( XLATBufDIB, DstRect, XLATBufDIB.DIBRect );
      end else // CDRXLATInts = nil, XLAT convertion is not needed, just draw CDRSrcUDDIB.DIBObj fragment
      begin
        //  N_T1.Start();
        NGCont.DstOCanv.DrawPixDIB( CDRSrcUDDIB.DIBObj, DstRect, DIBSrcRect );  // 0.19 msec for 32x32 rect
        //  N_T1.SS( 'Draw Fragment' );
      end;

    end; // end else // use old params (without effects)

    if uddrfEllipseMask in CDRFlags then // remove created elliptical clip region from DC
      N_i := Windows.SelectClipRgn( NGCont.DstOCanv.HMDC, 0 );

  end; // PRCompD^.CDIBRect do
end; // end_of procedure TN_UDDIBRect.BeforeAction

//************************************************ TN_UDDIBRect.CalcSrcRect ***
// Calculate and set Self.CDRSrcRect field
//
//     Parameters
// ASrcDIBFRect  - Whole Src UDDIB Rect in any coords system (e.g. UserCoords)
// ASrcMidFPoint - Center of CDRSrcRect in same coords system
// ASrcPixSize   - CDRSrcRect Pixel Size (it is assumed that Width=Height=ASrcPixSize)
//
procedure TN_UDDIBRect.CalcSrcRect( ASrcDIBFRect: TFRect; ASrcMidFPoint: TFPoint;
                                                          ASrcPixSize: integer );
var
  MidPixPoint: TPoint;
  PRCompD: TN_PRDIBRect;
begin
  PRCompD := PDP();
  with PRCompD^.CDIBRect do
  begin
    if CDRSrcUDDIB = nil then Exit; // a precaution, Source UDDIB component not defined

    CDRSrcUDDIB.LoadDIBObj();

    MidPixPoint.X := Round( CDRSrcUDDIB.DIBObj.DIBRect.Right *
                            (ASrcMidFPoint.X - ASrcDIBFRect.Left) /
                            (ASrcDIBFRect.Right - ASrcDIBFRect.Left) );

    MidPixPoint.Y := Round( CDRSrcUDDIB.DIBObj.DIBRect.Bottom *
                            (ASrcMidFPoint.Y - ASrcDIBFRect.Top) /
                            (ASrcDIBFRect.Bottom - ASrcDIBFRect.Top) );

    CDRSrcRect := N_RectMake( MidPixPoint, Point(ASrcPixSize,ASrcPixSize), N_05DPoint );
  end; // PRCompD^.CDIBRect do
end; // procedure TN_UDDIBRect.CalcSrcRect


//********** TN_UDFile class methods  **************

//******************************************************** TN_UDFile.Create ***
//
constructor TN_UDFile.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDFileCI;
  ImgInd := 105;
end; // end_of constructor TN_UDFile.Create

//******************************************************* TN_UDFile.Destroy ***
//
destructor TN_UDFile.Destroy;
var
  FName: string;
begin
  with PISP()^ do // STATIC Params should be used!
  begin
    //  Self is File Owner        and  Not Application Finalization
    if (udffFileOwner in CFFlags) and (K_MainRootObj <> nil) then // delete it
    begin
      FName := GetFullFileName();
      if FileExists( FName ) then
        DeleteFile( FName );
    end; // if udffFileOwner in CFFlags then // Self is File Owner, delete it
  end; // with PISP()^ do

  inherited Destroy;
end; // end_of destructor TN_UDFile.Destroy

//*********************************************************** TN_UDFile.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDFile.PSP(): TN_PRFile;
begin
  Result := TN_PRFile(R.P());
end; // end_of function TN_UDFile.PSP

//*********************************************************** TN_UDFile.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDFile.PDP(): TN_PRFile;
begin
  if DynPar <> nil then Result := TN_PRFile(DynPar.P())
                   else Result := TN_PRFile(R.P());
end; // end_of function TN_UDFile.PDP

//********************************************************** TN_UDFile.PISP ***
// return typed pointer to Individual Static File Params
//
function TN_UDFile.PISP(): TN_PCFile;
begin
  Result := @(TN_PRFile(R.P())^.CFile);
end; // function TN_UDFile.PISP

//********************************************************** TN_UDFile.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic File Params
// otherwise return typed pointer to Individual Static File Params
//
function TN_UDFile.PIDP(): TN_PCFile;
begin
  if DynPar <> nil then
    Result := @(TN_PRFile(DynPar.P())^.CFile)
  else
    Result := @(TN_PRFile(R.P())^.CFile);
end; // function TN_UDFile.PIDP

//**************************************************** TN_UDFile.PascalInit ***
// Init self
//
procedure TN_UDFile.PascalInit();
begin
  Inherited;
end; // procedure TN_UDFile.PascalInit

//************************************************** TN_UDFile.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDFile.BeforeAction();
//var
//  PRCompD: TN_PRFile;
begin

//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

//  PRCompD := PDP();
//  with PRCompD^, PRCompD^.CFile  do
//  begin

//  end; // PRCompD^, PRCompD^.CFile do
end; // end_of procedure TN_UDFile.BeforeAction

//*********************************************** TN_UDFile.GetFullFileName ***
// Get Self Full FileName from STATIC Params
//
// If using Dynamic params, when changing CDIBFName, you will have to change
// both Dynamic and Static Params and it is not convinient.
//
function TN_UDFile.GetFullFileName(): string;
begin
  with PISP()^ do
  begin
    if udffFileFullName in CFFlags then // Full (absolute) name
      Result := K_ExpandFileName( CFName )
    else // Name in ArchFiles Dir
      Result := N_ArchDFilesDir() + '\' + CFName;
  end; // with PISP()^ do
end; // function TN_UDFile.GetFullFileName


//********** TN_UDAction class methods  **************

//****************************************************** TN_UDAction.Create ***
//
constructor TN_UDAction.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDActionCI;
  CStatFlags := [csfCoords, csfNonCoords,    // can work in Both Visual and NonVisual modes
                 csfExecAfter,csfForceExec];
  ImgInd := 50;
end; // end_of constructor TN_UDAction.Create

//***************************************************** TN_UDAction.Destroy ***
//
destructor TN_UDAction.Destroy;
begin
  PISP()^.CAObj1.Free;
  UDActObj1.Free;
  UDActObj2.Free;

  inherited Destroy;
end; // end_of destructor TN_UDAction.Destroy

//********************************************************* TN_UDAction.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDAction.PSP(): TN_PRAction;
begin
  Result := TN_PRAction(R.P());
end; // end_of function TN_UDAction.PSP

//********************************************************* TN_UDAction.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDAction.PDP(): TN_PRAction;
begin
  if DynPar <> nil then Result := TN_PRAction(DynPar.P())
                   else Result := TN_PRAction(R.P());
end; // end_of function TN_UDAction.PDP

//******************************************************** TN_UDAction.PISP ***
// return typed pointer to Individual Static Action Params
//
function TN_UDAction.PISP(): TN_PCAction;
begin
  Result := @(TN_PRAction(R.P())^.CAction);
end; // function TN_UDAction.PISP

//******************************************************** TN_UDAction.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic Action Params
// otherwise return typed pointer to Individual Static Action Params
//
function TN_UDAction.PIDP(): TN_PCAction;
begin
  if DynPar <> nil then
    Result := @(TN_PRAction(DynPar.P())^.CAction)
  else
    Result := @(TN_PRAction(R.P())^.CAction);
end; // function TN_UDAction.PIDP

//************************************************ TN_UDAction.PrepRootComp ***
// Prepare Self as Root component
//
procedure TN_UDAction.PrepRootComp();
var
  ProcInd : Integer;
  Str, ProcPrepRoot: string;
  PRCompD: TN_PRAction;
begin
  inherited;
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with PRCompD^.CAction do
  begin
    Str := CAActNames;
    N_ScanToken( Str ); // Skip ProcBefore Name
    N_ScanToken( Str ); // Skip ProcAfter Name
    ProcPrepRoot := N_ScanToken( Str );
    if ProcPrepRoot    = ''  then Exit; // PrepRoot not given
    if ProcPrepRoot[1] = '-' then Exit; // PrepRoot not given

    UDActionProcType := aptPrepRoot;
    ProcInd := N_ActionProcs.IndexOfName( ProcPrepRoot );

    if ProcInd <> -1 then
      TN_ActionProc(N_ActionProcs.Objects[ProcInd])( @PRCompD^.CAction, @Self, nil )
    else
      N_CurShowStr( 'Action PrepRoot Not Found: ' + ProcPrepRoot );

  end; // with PRCompD^.CAction do
end; // end_of procedure TN_UDAction.PrepRootComp

//************************************************ TN_UDAction.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDAction.BeforeAction();
var
  ProcInd: Integer;
  Str, ProcBefore: string;
  PRCompD: TN_PRAction;
begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with PRCompD^.CAction do
  begin
    Str := CAActNames;
    ProcBefore := N_ScanToken( Str );
    if ProcBefore    = ''  then Exit; // BeforeAction not given
    if ProcBefore[1] = '-' then Exit; // BeforeAction not given

    UDActionProcType := aptBefore;
    ProcInd := N_ActionProcs.IndexOfName( ProcBefore );

    if ProcInd <> -1 then
      TN_ActionProc(N_ActionProcs.Objects[ProcInd])( @PRCompD^.CAction, @Self, nil )
    else
      N_CurShowStr( 'Action Before Not Found: ' + ProcBefore );

  end; // with PRCompD^.CAction do
end; // end_of procedure TN_UDAction.BeforeAction

//************************************************* TN_UDAction.AfterAction ***
// Component Action, executed before After Children
//
procedure TN_UDAction.AfterAction();
var
  ProcInd : Integer;
  Str, ProcAfter: string;
  PRCompD: TN_PRAction;
begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with PRCompD^.CAction do
  begin
    Str := CAActNames;
    N_ScanToken( Str ); // Skip ProcBefore Name
    ProcAfter := N_ScanToken( Str );
    if ProcAfter    = ''  then Exit; // AfterAction not given
    if ProcAfter[1] = '-' then Exit; // AfterAction not given

    UDActionProcType := aptAfter;
    ProcInd := N_ActionProcs.IndexOfName( ProcAfter );

    if ProcInd <> -1 then
      TN_ActionProc(N_ActionProcs.Objects[ProcInd])( @PRCompD^.CAction, @Self, nil )
    else
      N_CurShowStr( 'Action After Not Found: ' + ProcAfter );

  end; // with PRCompD^.CAction do
end; // end_of procedure TN_UDAction.AfterAction


//********** TN_UDExpComp class methods  **************

//********************************************** TN_UDExpComp.Create ***
//
constructor TN_UDExpComp.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDExpCompCI;
  ImgInd := 93;
end; // end_of constructor TN_UDExpComp.Create

//********************************************* TN_UDExpComp.Destroy ***
//
destructor TN_UDExpComp.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDExpComp.Destroy

//********************************************** TN_UDExpComp.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDExpComp.PSP(): TN_PRExpComp;
begin
  Result := TN_PRExpComp(R.P());
end; // end_of function TN_UDExpComp.PSP

//********************************************** TN_UDExpComp.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDExpComp.PDP(): TN_PRExpComp;
begin
  if DynPar <> nil then Result := TN_PRExpComp(DynPar.P())
                   else Result := TN_PRExpComp(R.P());
end; // end_of function TN_UDExpComp.PDP

//******************************************* TN_UDExpComp.PISP ***
// return typed pointer to Individual Static ExpComp Params
//
function TN_UDExpComp.PISP(): TN_PCExpComp;
begin
  Result := @(TN_PRExpComp(R.P())^.CExpComp);
end; // function TN_UDExpComp.PISP

//******************************************* TN_UDExpComp.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic ExpComp Params
// otherwise return typed pointer to Individual Static ExpComp Params
//
function TN_UDExpComp.PIDP(): TN_PCExpComp;
begin
  if DynPar <> nil then
    Result := @(TN_PRExpComp(DynPar.P())^.CExpComp)
  else
    Result := @(TN_PRExpComp(R.P())^.CExpComp);
end; // function TN_UDExpComp.PIDP

//********************************************** TN_UDExpComp.PascalInit ***
// Init self
//
procedure TN_UDExpComp.PascalInit();
begin
  Inherited;
{
var
  PRCompS: TN_PRExpComp;

  PRCompS := PSP();
  with PRCompS^, PRCompS^.CExpComp do
  begin

  end;
}
end; // procedure TN_UDExpComp.PascalInit

//************************************** TN_UDExpComp.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDExpComp.BeforeAction();
var
  PRCompD: TN_PRExpComp;
  ExecComp: TN_UDCompBase;
  ExecCompVis: TN_UDCompVis;
  SelfExpParRArray: TK_RArray;
  PSelfExpParams: TN_PExpParams;
  SavedCoords: TN_CompCoords;
  NewGCont: TN_GlobCont;
begin
//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with PRCompD^, PRCompD^.CExpComp do
  begin
    if not (ECExpComp is TN_UDCompBase) then
    begin
      NGCont.GCShowResponse( 'Bad ExecComp!' );
      Exit; // a precaution
    end;

    ExecComp := TN_UDCompBase(ECExpComp); // to reduce code size

    SelfExpParRArray := CCompBase.CBExpParams;

    if (epfExpParams in ECExpParFlags) and // use Self dynamic ExpParams for executing ExecComp
       (SelfExpParRArray <> nil) then
      PSelfExpParams := TN_PExpParams(SelfExpParRArray.P())
    else
      PSelfExpParams := nil;

    ExecCompVis := nil;

    if (epfCompCoords in ECExpParFlags) and // use Self dynamic Coords for executing ExecComp
       (ExecComp is TN_UDCompVis) then
    begin
      ExecCompVis := TN_UDCompVis(ECExpComp);
      SavedCoords := ExecCompVis.PSP()^.CCoords;
      ExecCompVis.PSP()^.CCoords := PRCompD^.CCoords;
    end; // if epfCompCoords in ECExpParFlags then // use Self Coords for executing ExecComp

    NewGCont := TN_GlobCont.CreateByGCont( NGCont ); // GCont for Exporting ExecComp

    with NewGCont do
    begin
      PrepForExport( ExecComp, PSelfExpParams );
      ExecuteComp( ExecComp, [cifRootComp] );
      FinishExport();
    end; // with NewGCont do

    NGCont.GCUpdateSelf( NewGCont );
    NewGCont.Free;

    //***** Restore ECExpComp static coords if needed

    if ExecCompVis <> nil then // Coords were saved, restore them
      ExecCompVis.PSP()^.CCoords := SavedCoords;

  end; // PRCompD^, PRCompD^.CExpComp do
end; // end_of procedure TN_UDExpComp.BeforeAction


{ //******************* New Visual Component Pattern (implementation)
//********** TN_UDVCPattern class methods  **************

//********************************************** TN_UDVCPattern.Create ***
//
constructor TN_UDVCPattern.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDVCPatternCI;
  ImgInd := 0;
end; // end_of constructor TN_UDVCPattern.Create

//********************************************* TN_UDVCPattern.Destroy ***
//
destructor TN_UDVCPattern.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDVCPattern.Destroy

//********************************************** TN_UDVCPattern.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDVCPattern.PSP(): TN_PRVCPattern;
begin
  Result := TN_PRVCPattern(R.P());
end; // end_of function TN_UDVCPattern.PSP

//********************************************** TN_UDVCPattern.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDVCPattern.PDP(): TN_PRVCPattern;
begin
  if DynPar <> nil then Result := TN_PRVCPattern(DynPar.P())
                   else Result := TN_PRVCPattern(R.P());
end; // end_of function TN_UDVCPattern.PDP

//******************************************* TN_UDVCPattern.PISP ***
// return typed pointer to Individual Static VCPattern Params
//
function TN_UDVCPattern.PISP(): TN_PCVCPattern;
begin
  Result := @(TN_PRVCPattern(R.P())^.CVCPattern);
end; // function TN_UDVCPattern.PISP

//******************************************* TN_UDVCPattern.PIDP ***
// if DynPar <> nil then return typed pointer to Individual Dynamic VCPattern Params
// otherwise return typed pointer to Individual Static VCPattern Params
//
function TN_UDVCPattern.PIDP(): TN_PCVCPattern;
begin
  if DynPar <> nil then
    Result := @(TN_PRVCPattern(DynPar.P())^.CVCPattern)
  else
    Result := @(TN_PRVCPattern(R.P())^.CVCPattern);
end; // function TN_UDVCPattern.PIDP

//********************************************** TN_UDVCPattern.PascalInit ***
// Init self
//
procedure TN_UDVCPattern.PascalInit();
begin
  Inherited;
end; // procedure TN_UDVCPattern.PascalInit

//************************************** TN_UDVCPattern.BeforeAction ***
// Component method which will be called just before childrens ExecSubtree method
//
procedure TN_UDVCPattern.BeforeAction();
var
  PRCompD: TN_PRVCPattern;
begin

//  if (ObjName = 'Header') and (Owner.ObjName = 'Group_2') then  // debug
//    N_i := 1;

  PRCompD := PDP();
  with PRCompD^, PRCompD^.CVCPattern do
  begin

  end; // PRCompD^, PRCompD^.CVCPattern do
end; // end_of procedure TN_UDVCPattern.BeforeAction

} //******************* End of New Visual Component Pattern

//****************** Global procedures **********************

{
//************************************************ N_DrawCPanel ***
// Draw panel Background and border in Pixel Coords
//
// ANGCont     - Global Context
// ACurPixRect - Panel Envelope Rect in Pixel Coords (Component.CompIntPixRect)
// APCPanel    - Pointer to Panel Params
//
procedure N_DrawCPanel( ANGCont: TN_GlobCont; ACurPixRect: TRect;
                                                        APCPanel: TK_RArray );
begin
  ANGCont.DrawCPanel( APCPanel, ACurPixRect );
var
  PixRad, LeftPixWidth, TopPixWidth, RightPixWidth, BotPixWidth: integer;
  LeftColor, TopColor, RightColor, BotColor: integer;
  SideRect: TRect;
  PCPanel: TN_PCPanel;
begin
  PCPanel := TN_PCPanel(APCPanel.P());

  with ANGCont, ANGCont.DstOCanv, PCPanel^ do
  begin

  if (BackColor = N_EmptyColor) and
     ( ((BorderColor = N_EmptyColor) or (BorderWidth = -1)) and
       (((TopBordWidth = -2) and (RightBordWidth = -2) and (BotBordWidth = -2)) or
        ((TopBordWidth = 0)  and (RightBordWidth = 0)  and (BotBordWidth = 0))) ) then Exit;

  PixRad := 0;
  if N_RectAspect( ACurPixRect ) > 1 then // Width < Height
  begin
    case RadUnits of // Radius in pixels usind Width
      ruPercent: PixRad := Round(Radius*N_RectWidth(ACurPixRect)/200);
      ruLLW:     PixRad := Round(Radius*CurLSUPixSize);
      ruUser:    PixRad := Round(Radius*U2P.CX);
      rumm:      PixRad := Round(Radius*mmPixSize.X);
    end; // case RadUnits of
  end else //  // Width > Height
  begin
    case RadUnits of // Radius in pixels usind Height
      ruPercent: PixRad := Round(Radius*N_RectHeight(ACurPixRect)/200);
      ruLLW:     PixRad := Round(Radius*CurLSUPixSize);
      ruUser:    PixRad := Round(Radius*U2P.CY);
      rumm:      PixRad := Round(Radius*mmPixSize.Y);
    end; // case RadUnits of
  end;

  if (PixRad > 0) or
     ((TopBordWidth = -2) and (RightBordWidth = -2) and (BotBordWidth = -2)) or
     ((TopBordWidth = 0)  and (RightBordWidth = 0)  and (BotBordWidth = 0))   then
    ANGCont.DrawPixRoundRect( ACurPixRect, Point(PixRad,PixRad),
                                          BackColor, BorderColor, BorderWidth )
  else // draw Panel Sides with individual attributes
  begin
    FillPixRect( ACurPixRect, BackColor ); // fill Panel Background

    //***** prepare Width and Color of each Side

    LeftPixWidth := LLWToPix1( BorderWidth );
    LeftColor := BorderColor;

    if TopBordWidth = -2 then
    begin
      TopPixWidth := LeftPixWidth;
      TopColor    := LeftColor;
    end else
    begin
      TopPixWidth := LLWToPix1( TopBordWidth );
      TopColor    := TopBordColor;
    end;

    if RightBordWidth = -2 then
    begin
      RightPixWidth := TopPixWidth;
      RightColor    := TopColor;
    end else
    begin
      RightPixWidth := LLWToPix1( RightBordWidth );
      RightColor    := RightBordColor;
    end;

    if BotBordWidth = -2 then
    begin
      BotPixWidth := RightPixWidth;
      BotColor    := RightColor;
    end else
    begin
      BotPixWidth := LLWToPix1( BotBordWidth );
      BotColor    := BotBordColor;
    end;

    if (LeftColor <> N_EmptyColor) and (BorderWidth <> -1) then //***** Draw Left Side
    begin
      SideRect := ACurPixRect;
      SideRect.Right := SideRect.Left + LeftPixWidth - 1;

      if (LeftPixWidth < TopPixWidth) and (TopColor <> N_EmptyColor) then
        SideRect.Top := SideRect.Top + TopPixWidth;

      if (LeftPixWidth < BotPixWidth) and (BotColor <> N_EmptyColor) then
        SideRect.Bottom := SideRect.Bottom - BotPixWidth;

      FillPixRect( SideRect, LeftColor );
    end; // //***** Draw Left Side

    if (TopColor <> N_EmptyColor) and (TopBordWidth <> -1) then //***** Draw Top Side
    begin
      SideRect := ACurPixRect;
      SideRect.Bottom := SideRect.Top + TopPixWidth - 1;

      if (TopPixWidth < LeftPixWidth) and (LeftColor <> N_EmptyColor) then
        SideRect.Left := SideRect.Left + LeftPixWidth;

      if (TopPixWidth < RightPixWidth) and (RightColor <> N_EmptyColor) then
        SideRect.Right := SideRect.Right - RightPixWidth;

      FillPixRect( SideRect, TopColor );
    end; // //***** Draw Top Side

    if (RightColor <> N_EmptyColor) and (RightBordWidth <> -1) then //***** Draw Right Side
    begin
      SideRect := ACurPixRect;
      SideRect.Left := SideRect.Right - RightPixWidth + 1;

      if (RightPixWidth < TopPixWidth) and (TopColor <> N_EmptyColor) then
        SideRect.Top := SideRect.Top + TopPixWidth;

      if (RightPixWidth < BotPixWidth) and (BotColor <> N_EmptyColor) then
        SideRect.Bottom := SideRect.Bottom - BotPixWidth;

      FillPixRect( SideRect, RightColor );
    end; // //***** Draw Right Side

    if (BotColor <> N_EmptyColor) and (BotBordWidth <> -1) then //***** Draw Bottom Side
    begin
      SideRect := ACurPixRect;
      SideRect.Top := SideRect.Bottom - BotPixWidth + 1;

      if (BotPixWidth < LeftPixWidth) and (LeftColor <> N_EmptyColor) then
        SideRect.Left := SideRect.Left + LeftPixWidth;

      if (BotPixWidth < RightPixWidth) and (RightColor <> N_EmptyColor) then
        SideRect.Right := SideRect.Right - RightPixWidth;

      FillPixRect( SideRect, BotColor );
    end; // //***** Draw Bottom Side

  end; // else // draw Panel Sides with individual attributes

  end; // with AGC, APCPanel^ do
end; // procedure N_DrawCPanel
}

//************************************************ N_SetSRTLByCParaBox ***
// Init, Add TextBlocks and Layout to given ASRTL Obj by given pointer to CParaBox
// (is used in UDParaBox and in UDTable)
//
procedure N_SetSRTLByCParaBox( ASRTL: TN_SRTextLayout;
                     APCParaBox: TN_PCParaBox; const AIntPixRect: TRect );
begin
  with ASRTL, APCParaBox^ do
  begin
    SRTLHAlign   := CPBHorAlign;
    SRTLVAlign   := CPBVertAlign;
    SRTLFlags    := CPBSRTLFlags;
    SRTLPrefSize := N_RectSize( AIntPixRect );
    SRTLExYSpace := CPBExYSpace;

    AddTextBlocks( TN_POneTextBlock(CPBTextBlocks.P(0)), CPBTextBlocks.ALength() );
    LayoutTextRects();
  end; // with ASRTL, APCParaBox^ do
end; // procedure N_SetSRTLByCParaBox

//***************************************************** N_InitCTextBox ***
// Initialize given CTextBox params
//
procedure N_InitCTextBox( APCTB: TN_PCTextBox; APrefWidth: float; ATextcolor: integer;
                                 AHorAlign: TN_HVAlign; AAddLineSpacing: float );
begin
  FillChar( APCTB^, SizeOf(TN_CTextBox), 0 );
  with APCTB^ do
  begin
    TBPrefWidth := APrefWidth;
    TBTextcolor := ATextcolor;
    TBHorAlign  := AHorAlign;
    TBLineExtraSpace := AAddLineSpacing;
    TBFSCoef := 1;
    TBMacroText := 'TextBox Sample Text';
  end;
end; // procedure N_InitCTextBox

//***************************************************** N_PrepCTextBox ***
// Prepare for CTextBox Creation by N_CalcCTextBox and N_FinTextBox
// (create empty objects (MapLayers, CObjLayers and RArrays) in ADataRoot )
//
// ADataRoot - UDBase Dir, where to create all needed objects for TextBox Drawing
// ACTextBox - TextBox params
//
procedure N_PrepCTextBox( ADataRoot: TN_UDBase; const ACTextBox: TN_CTextBox );
var
  TBTPoints: TN_UDPoints;
  MTBTokens: TN_UDMapLayer;
  TBTokens, TBTFonts: TK_UDRArray;
begin
  with ACTextBox do
  begin
  ADataRoot.ClearChilds(); // clear previously created objects

// TBTokens  - UDRArray with Tokens
// TBTPoints - UDPoints with Tokens Base Points
// MTBTokens - UDMapLayer for drawing Tokens

  //*** create Labels(Tokens) CObj and Map Layers

  TBTPoints := TN_UDPoints.Create();
  TBTPoints.ObjName := 'TBTPoints';
  ADataRoot.PutDirChildSafe( N_TBTPoints, TBTPoints );
  TBTPoints.InitItems( 1, 1 );

  if tbfMultiFont in TBFlags then // create UDRArray with Token's Fonts
  begin
    TBTFonts := K_CreateUDByRTypeName( 'TN_LogFontRef', 0 );
    TBTFonts.ObjName := 'TBFonts';
    ADataRoot.PutDirChildSafe( N_TBTFonts, TBTFonts );
  end; // if tbfMultiFont in TBFlags then // create UDRArray with Token's Fonts

  MTBTokens := N_CreateUDMapLayer( TBTPoints, mltHorLabels );
  ADataRoot.PutDirChildSafe( N_MTBTokens, MTBTokens );
  with MTBTokens.PISP^ do
  begin
    K_SetUDRefField( TN_UDBase(MLAux1), TBFont ); // TextBoxes UDLogFont
    MLTextColor := TBTextColor; // TextBox Text Color
//    MLFSCoef    := TBFSCoef;
    MLHotPoint  := FPoint(0,0);

    TBTokens := K_CreateUDByRTypeName( 'String', 0 );
    TBTokens.ObjName := 'TBTokens';
    ADataRoot.PutDirChildSafe( N_TBTokens, TBTokens );
    K_SetUDRefField( TN_UDBase(MLDVect1), TBTokens ); // UDRArray with Tokens
  end; // with MTBTokens.PSP^ do

  end; // with APTB^, APTB^.CTextBox do
end; // procedure N_PrepCTextBox

procedure N_CalcCTextBox( ADataRoot: TN_UDBase; AOCanv: TN_OCanvas;
           APCP: TK_RArray; APCTB: TN_PCTextBox; APLayout: TN_POneDimLayout;
                                                 out ANeededSizeLLW: TFPoint );
begin
  N_CalcCTextBox( ADataRoot, AOCanv, TN_PCPanel(APCP.P()),
                                             APCTB, APLayout, ANeededSizeLLW );
end;

//******************************************************* N_CalcCTextBox ***
// Parse TextBox Tokens, add them to TBTokens UDRArray and Calc Tokens
// relative coords in LLW in APLayout record
//
// ADataRoot - UDBase Dir, where to create all needed objects for TextBox Drawing
// AOCanv    - Canvas for Tokens and Font Size calculations
// APTB      - Pointer to TextBox params
// APLayout  - Pointer to Wrk Tokens Layout data (contains no input data)
// ANeededSizeLLW - Needed Size in LLW to show all tokens
//
procedure N_CalcCTextBox( ADataRoot: TN_UDBase; AOCanv: TN_OCanvas;
           APCP: TN_PCPanel; APCTB: TN_PCTextBox; APLayout: TN_POneDimLayout;
                                                 out ANeededSizeLLW: TFPoint );
var
  i, iMax, BegTInd, EndTInd, NElems, Dx, Dy, NTokens: integer;
  Token: string;
  EmptyToken: boolean;
  TBTokens, TBTFonts: TK_UDRArray;
  TmpLayout: TN_OneDimLayout; // for viewing in debugger
  TmpCTB: TN_CTextBox;        // for viewing in debugger
  PCurFont: TN_PLogFontRef;
  Label NextChar;

  procedure AddToken( ASkipLast, ASkipAfter: integer ); // local
  // add one Token to TBTokens UDRArray and set ElSize field in ODLElems array
  // ASkipLast  - num. last token's chars. to skip
  //              (0 means last char has index i (last analized char) )
  // ASkipAfter - num. chars. to skip after last token's chars
  begin
    with APCTB^, APLayout^ do
    begin

    // BegTInd, EndTInd - Beg and End Token's indexes
    EndTInd := i - ASkipLast;
    Token := Copy( TBPlainText, BegTInd, EndTInd-BegTInd+1 );
    Token := TrimRight( Token ); // left spaces will remain in token
    EmptyToken := True;

    if Length(ODLElems) <= NElems then
      SetLength( ODLElems, N_NewLength( NElems ) );

    if Trim(Token) = '<br>' then // force row break
    begin
      if (NElems = 0) or
         (leltRowBreak in ODLElems[NElems-1].ElFlags) then // add empty token
      begin
        Token := '';
        ODLElems[NElems].ElFlags := [leltRowBreak, leltNoSpaceAfter];
      end else // add RowBreak to prev. Element and skip adding cur token
      begin
        ODLElems[NElems-1].ElFlags := ODLElems[NElems-1].ElFlags +
                          [leltRowBreak, leltNoSpaceAfter]; // to prev. Element
        BegTInd := i;
        Inc( i );
        Exit;
      end;
    end;

    NTokens := TBTokens.R.ALength(); // number of previously parsed tokens
    TBTokens.R.ASetLength( NTokens + 1 ); // place for one new token

    TBTFonts := TK_UDRArray(ADataRoot.DirChild( N_TBTFonts ));
    if (TBTFonts <> nil) and (tbfMultiFont in TBFlags) then // save Token Font
    begin
      TBTFonts.R.ASetLength( NTokens + 1 ); // place for one new token Font
      PCurFont := TN_PLogFontRef(TBTFonts.R.P(NTokens));
      K_SetUDRefField( TN_UDBase(PCurFont^.LFRUDFont), TBFont );
      PCurFont^.LFRFSCoef := TBFSCoef;
    end;

    PString(TBTokens.R.P(NTokens))^ := Token;

    AOCanv.GetStringSize( Token, Dx, Dy ); // Dx is in pixels!
    ODLElems[NElems].ElSize := 1.0*Dx/AOCanv.CurLLWPixSize; // in LLW

    Inc( NElems );
    Inc( i, ASkipAfter - ASkipLast + 1 ); // to next char to analize
    BegTInd := i;

    end; // with APTB^, APLayout^ do
  end; // end of procedure AddToken(); // local

begin //***** body of N_CalcCTextBox

  with APCTB^, APLayout^ do // APCP^,
  begin
  //*** Parse Tokens in TBPlainText,
  //    add them to TBTokens UDRArray and ODLElems array

  FillChar( APLayout^, Sizeof(TN_OneDimLayout), 0 ); // clear Layout data
  SetLength( ODLElems, 20 );

  TBTokens := TK_UDRArray(ADataRoot.DirChild( N_TBTokens ));
  N_SetUDFont( TBFont, AOCanv, TBFSCoef ); // for AOCanv.GetStringSize method

  NElems := 0;
  i := 1;
  BegTInd := 1; // Beg Token Index
  iMax := Length(TBPlainText);
  EmptyToken := True;

  while True do //****************** loop along characters in TBPlainText
  begin
    if EmptyToken then // include leading spaces in token
    begin
      if i > iMax then Break; // end of characters

      if TBPlainText[i] = ' ' then
      begin
        Inc( i ); // to next char
        Continue;
      end;
    end;

    EmptyToken := False; // PlainText[i] <> ' '

    if TBPlainText[i] = '-' then // Minus is Token delimiter
    begin
      AddToken( 0, 0 );
      ODLElems[NElems-1].ElFlags := [leltNoSpaceAfter]; // to prev. Element
      Continue;
    end;

    if TBPlainText[i] = ' ' then // This Space is Token delimiter
    begin
      AddToken( 1, 1 );
      Continue;
    end;

    if TBPlainText[i] = Char($0D) then // End of Line is Token delimiter
    begin
      AddToken( 1, 2 );
      ODLElems[NElems-1].ElFlags := [leltRowBreak]; // to prev. Element
      Continue;
    end;

    if i >= iMax then // end of characters
    begin
      AddToken( 0, 0 );
      Break;
    end;

    Inc( i ); // to next char
  end; // while True do // loop along characters in TBPlainText

  with N_GetUDFontParams( TBFont )^ do
  begin
    N_f := LFHeight;
    ODLRowHeight := TBFSCoef * LFHeight * (1 + TBLineExtraSpace); // in LLW
    N_f := ODLRowHeight;
  end;

  ODLAlign := TBHorAlign;
  ODLSpaceSize := 0.3*ODLRowHeight;
//~  ODLPrefWidth := TBPrefWidth - 2*BorderWidth - TBPaddings.Left - TBPaddings.Right;
  ODLNumElems  := NELems;
  ODLRows := nil;
  if tbfFixWidth in TBFlags then ODLFlags := [odlfFixWidth];

//  TmpLayout := APLayout^; // debug
  N_DoOneDimLayout( APLayout ); // do Layout

  // Real Width and Height are in LLW
//~  ANeededSizeLLW.X := ODLRealWidth + TBPaddings.Left + TBPaddings.Right + 2*BorderWidth;
//~  ANeededSizeLLW.Y := (ODLNumRows - 1)*ODLRowHeight +
//~                     ODLRowHeight/(1+TBLineExtraSpace) +  // last Row Height
//~                     TBPaddings.Top + TBPaddings.Bottom + 2*BorderWidth;

//  if tbfFixWidth in TBFlags then TBRealWidth := TBPrefWidth
//                            else TBRealWidth := ANeededSizeLLW.X;

//  if tbfFixHeight in TBFlags then TBRealHeight := TBPrefHeight
//                             else TBRealHeight := ANeededSizeLLW.Y;

  TmpLayout := APLayout^; // debug
  TmpCTB := APCTB^;       // debug

  //***** Layout data are OK and ready for using in N_FinTextBox

  end; // with APTB^, APLayout^ do
end; // procedure N_CalcCTextBox

//************************************ N_FinTextBox ***
// Finish creating TextBox
// (conv relative LLW tokens coords to User coords and add TBTPoints Items)
//
// ULUCoords - UpperLeft corner Float User Coords
// APTB      - Pointer to TextBox
// AOCanv    - where to draw
// APLayout  - Pointer to OneDim Layout
// ADataRoot - UDBase Root, where to create needed objects
//
procedure N_FinTextBox( ULUCoords: TFPoint; APCP: TK_RArray; APCTB: TN_PCTextBox;
                        AOCanv: TN_OCanvas; APLayout: TN_POneDimLayout;
                                   ATBLLWHeight: float; ADataRoot: TN_UDBase  );
var
  i: integer;
  SX, SY, FreeYSize, OfsY, RowHeight: double;
  TUC: TDPoint;
  TBTPoints: TN_UDPoints;
//  PCP: TN_PCPanel;
begin
  //***** Calc whole TextBox coords
//  PCP := TN_PCPanel(APCP.P());

  with APCTB^, APLayout^ do // PCP^,
  begin
    // (SX, SY) is User Coords of Token in Upper Left corner
    SX := 0;
    SY := 0;
//~    SX := ULUCoords.X + AOCanv.LSUToUserX( TBPaddings.Left + BorderWidth );
//~    SY := ULUCoords.Y + AOCanv.LSUToUserY( TBPaddings.Top  + BorderWidth );

    OfsY := 0; // to awoid warning;
    FreeYSize := ATBLLWHeight - ODLNumRows * ODLRowHeight;
    RowHeight := ODLRowHeight;

    case TBVertAlign of
      hvaBeg: begin
        OfsY := 0;
      end; // hvaBeg: begin

      hvaCenter: begin
        OfsY := 0.5 * FreeYSize;
      end; // hvaCenter: begin

      hvaEnd: begin
        OfsY := FreeYSize;
      end; // hvaEnd: begin

      hvaJustify: begin
        OfsY := 0;
        if ODLNumRows >= 2 then
          RowHeight := ODLRowHeight + FreeYSize/(ODLNumRows-1);
      end; // hvaJustify: begin

      hvaUniform: begin
        RowHeight := FreeYSize / (ODLNumRows + 1);
        OfsY := RowHeight;
      end; // hvaUniform: begin

    end; // case TBVertAlign of

    //*** create TBTPoints Items

    TBTPoints := TN_UDPoints(ADataRoot.DirChild( N_TBTPoints ));

    for i := 0 to ODLNumElems-1 do // along all tokens
    begin
        // TUC is current Token upper left corner User Coords:
      TUC.X := SX + AOCanv.LSUToUserX( ODLElems[i].ElOffs );
      TUC.Y := SY + AOCanv.LSUToUserY( OfsY + ODLElems[i].ElRowInd * RowHeight );
        if Abs(TUC.X) > 10.0e10 then
          N_i := 1;
      TBTPoints.AddOnePointItem( TUC, -1 );
    end; // for i := 0 to ODLNumElems-1 do

  end; // with APTB^, APLayout^ do
end; // procedure N_FinTextBox

//****************************************  N_CreateUDTextBox  ******
// Create and return UDTextBox by given Pointer to RTextBox
//
function N_CreateUDTextBox( APRTextBox: TN_PRTextBox ): TN_UDTextBox;
begin
  Result := TN_UDTextBox(K_CreateUDByRTypeName( 'TN_RTextBox', 1, N_UDTextBoxCI ));
  with Result do
  begin
    ObjName := 'NewTextBox';
    K_MoveSPLData( APRTextBox^, R.P()^, K_GetTypeCodeSafe( 'TN_RTextBox' ),
                                          [K_mdfCountUDRef, K_mdfCopyRArray] );
  end;
end; // end of function N_CreateUDTextBox

//***************************************************** N_InitCLegend ***
// Initialize given Legend params by given Pointer to CLegend
//
procedure N_InitCLegend ( APCLegend: TN_PCLegend );
begin
  FillChar( APCLegend^, SizeOf(TN_CLegend), 0 );
  with APCLegend^ do
  begin
//    LegHFSCoef := 1;
    LegHeaderText := 'Sample Legend Header';
    LegHeaderAlign := hvaCenter;
    LegHeaderBotPadding := 5;
//    LegFFSCoef := 1;

//    LegEFSCoef := 1;
    LegElemTexts  := K_RCreateByTypeName( 'String', 3 );
    PString(LegElemTexts.P(0))^ := 'Element 1';
    PString(LegElemTexts.P(1))^ := 'Second Element';
    PString(LegElemTexts.P(2))^ := 'Element 3 in new Legend';

    LegElemColors := K_RCreateByTypeName( 'Color', 3 );
    PInteger(LegElemColors.P(0))^ := $0000FF;
    PInteger(LegElemColors.P(1))^ := $00FF00;
    PInteger(LegElemColors.P(2))^ := $FF0000;

    LegElemsYGap := 3;
    LegSignWidth := 35;
    LegSignRect  := FRect( 3, 5, 20, 10 );
    LegSRBWidth  := 1;
    LegSignDashXPos  := FPoint( 25, 30 );
    LegSignDashWidth := 1;
  end; // with APCLegend^ do
end; // procedure N_InitCLegend

//***************************************************** N_InitCNLegend ***
// Initialize given NLegend params by given Pointer to CNLegend
//
procedure N_InitCNLegend ( APCNLegend: TN_PCNLegend );
begin
  FillChar( APCNLegend^, SizeOf(TN_CNLegend), 0 );
  with APCNLegend^ do
  begin
    NLElemTexts  := K_RCreateByTypeName( 'String', 3 );
    PString(NLElemTexts.P(0))^ := 'Element 1';
    PString(NLElemTexts.P(1))^ := 'Second Element';
    PString(NLElemTexts.P(2))^ := 'Element 3 in new NLegend';

    NLElemColors := K_RCreateByTypeName( 'Color', 3 );
    PInteger(NLElemColors.P(0))^ := $0000FF;
    PInteger(NLElemColors.P(1))^ := $00FF00;
    PInteger(NLElemColors.P(2))^ := $FF0000;

    NLElemsYGap := 3;
    NLSignWidth := 35;
    NLSignRect  := FRect( 3, 5, 20, 10 );
    NLSRBWidth  := 1;
    NLSignDashXPos  := FPoint( 25, 30 );
    NLSignDashWidth := 1;
  end; // with APCNLegend^ do
end; // procedure N_InitCNLegend

//****************************************  N_CreateUDPicture  ******
// Create and return UDPicture by given APictType and ARObj
//
function N_CreateUDPicture( APictType: TN_CPictType; ARObj: TN_RasterObj ): TN_UDPicture;
begin
  Result := TN_UDPicture(K_CreateUDByRTypeName( 'TN_RPicture', 1, N_UDPictureCI ));
  with Result do
  begin

  PictRObj := ARObj;
  PictLoaded := True;
  PictDecompressed := True;

  with PISP()^ do
  begin
    PictType := APictType;
    PictRaster := ARObj.RR;
  end; // with PISP()^ do

  SetUCoordsByPixelSizeS();

  end; // with Result do
end; // end of function N_CreateUDPicture

//****************************************  N_CreateUDPicture  ******
// Create and return UDPicture by given Type and FileName
//
function N_CreateUDPicture( APictType: TN_CPictType; ARasterType: TN_RasterType;
                     AFileName: string; ATranspColor: integer ): TN_UDPicture;
begin
  Result := TN_UDPicture(K_CreateUDByRTypeName( 'TN_RPicture', 1, N_UDPictureCI ));
  with Result.PISP()^ do
  begin
    PictType := APictType;
    PictRaster.RType := ARasterType;

    if ARasterType = rtDefault then
      case APictType of
        cptFile:      PictRaster.RType := rtBArray;
        cptArchRaw:   PictRaster.RType := rtRArray;
        cptArchCompr: PictRaster.RType := rtBArray;
      end; // case APictType of

    if AFileName= '' then Exit; // FileName not given, nothing to do

    PictFName := AFileName;
    PictRaster.RTranspColor := ATranspColor;
    Result.ObjName := ChangeFileExt( ExtractFileName(PictFName), '' );
    Result.LoadFromFile();
    Result.SetUCoordsByPixelSizeS();
  end; // with Result.PISP()^ do
end; // end of function N_CreateUDPicture

//**************************************************** N_CreateUDDIB(empty) ***
// Create UDDIB with given params and DIBObj = nil
//
function N_CreateUDDIB( AUCoords: TFRect; AFlags: TN_UDDIBFlagsN;
                                          AFileName, AObjName: string ): TN_UDDIB;
begin
  Result := TN_UDDIB(K_CreateUDByRTypeName( 'TN_RDIBN', 1, N_UDDIBCI ));
  Result.ObjName := AObjName;

  with Result.PISP()^ do
  begin
    CDIBFlagsN := AFlags;
    CDIBFName := AFileName; // Raster File Name
    CDIBURect := AUCoords;  // Raster User Coords Rect
  end; // with Result.PISP()^ do
end; // end of function N_CreateUDDIB(empty)

//************************************************ N_CreateUDDIB(ImageList) ***
// Create UDDIB from ImagesList element
//
//     Parameters
// AImageList   - given ImagesList with needed Image
// AImageIndex  - given Image index in AImageList
// ATranspColor - Image Transparent Color
// AObjName     - Resulting UDDIB ObjName
// Result       - Return created TN_UDDIB Object
//
function N_CreateUDDIB( AImageList: TImageList; AImageIndex, ATranspColor: integer;
                                                   AObjName: string ): TN_UDDIB;
var
  TmpBitmap: TBitmap;
begin
  Result := N_CreateUDDIB( FRect(0,0,100,100), [], '', AObjName );

  TmpBitmap := TBitmap.Create;
  TmpBitmap.PixelFormat := pf24bit; // GetBitmap function do not set PixelFormat!
  TmpBitmap.Canvas.Brush.Color := ATranspColor; // GetBitmap function will use it!
  AImageList.GetBitmap( AImageIndex, TmpBitmap );
  // TmpBitmap.SaveToFile( 'C:\\aa9.bmp' ); // debug

  Result.DIBObj := TN_DIBObj.Create( TmpBitmap, ATranspColor );
  TmpBitmap.Free;

  Result.PISP()^.CDIBInfo := Result.DIBObj.GetInfoString(); // not used in Pascal code
end; // end of function N_CreateUDDIB(ImageList)


//********************************************************* N_CreateUDPanel ***
// Create UDPanel with params, suitable for Map Group
//
function N_CreateUDPanel( AObjName: string ): TN_UDPanel;
begin
  Result := TN_UDPanel(K_CreateUDByRTypeName( 'TN_RPanel', 1, N_UDPanelCI ));
  Result.ObjName := AObjName;
end; // end of function N_CreateUDPanel

//********************************************************* N_CreateUDPanel ***
// Create UDPanel with given User Coords (can be used as Map Layer)
//
function N_CreateUDPanel( AObjName: string; AUCoords: TFRect ): TN_UDPanel;
begin
  Result := N_CreateUDPanel( AObjName );

  with Result.PCCS()^ do
  begin
    BPCoords := AUCoords.TopLeft;
    LRCoords := AUCoords.BottomRight;
    BPXCoordsType := cbpUser;
    BPYCoordsType := cbpUser;
    LRXCoordsType := cbpUser;
    LRYCoordsType := cbpUser;

    SRSizeXType := cstNotGiven;
    SRSizeYType := cstNotGiven;
  end; // with Result.PCCS()^ do
end; // end of function N_CreateUDPanel

//***************************************************** N_CreateFullUDPanel ***
// Create Full UDPanel with Full Parent Size (can be used as Map Layer)
//
function N_CreateFullUDPanel( AObjName: string ): TN_UDPanel;
begin
  Result := N_CreateUDPanel( AObjName );

  with Result.PCCS()^ do
  begin
    BPCoords := FPoint( 0, 0 );
    BPXCoordsType := cbpPercent;
    BPYCoordsType := cbpPercent;

    LRCoords := FPoint( 100, 100 );
    LRXCoordsType := cbpPercent;
    LRYCoordsType := cbpPercent;

    SRSizeXType := cstNotGiven;
    SRSizeYType := cstNotGiven;
  end; // with Result.PCCS()^ do
end; // end of function N_CreateFullUDPanel

//******************************************************* N_PrepUDPanelInmm ***
// Create UDPanel with borders and given Coords and Size in mm
//
function N_PrepUDPanelInmm( AParentDir: TN_UDBase; AObjName: string; ABPX, ABPY, ASizeX, ASizeY: double ): TN_UDPanel;
var
  TmpUDBase: TN_UDBase;
begin
  TmpUDBase := AParentDir.DirChildByObjName( AObjName );

  if (TmpUDBase = nil) or not (TmpUDBase is TN_UDPanel) then
  begin
    Result := N_CreateUDPanel( AObjName );
    AParentDir.AddOneChildV( Result );
  end else
  begin
    Result := TN_UDPanel(TmpUDBase);
  end;

  with Result.PCPanelS()^ do // Static CPanel RArray was created inside if not yet
  begin
    PaBackColor   := N_EmptyColor; // Panel Background Color
    PaBorderColor := N_ClBlack;    // Panel All Borders Common Color
    PaBorderWidth := 0;;           // Panel All Borders Common Width
  end;

  with Result.PCCS()^ do
  begin
    BPCoords.X := ABPX;
    BPCoords.Y := ABPY;
    BPXCoordsType := cbpmm;
    BPYCoordsType := cbpmm;

    LRXCoordsType := cbpNotGiven;
    LRYCoordsType := cbpNotGiven;

    SRSize.X := ASizeX;
    SRSize.Y := ASizeY;

    SRSizeXType := cstmm;
    SRSizeYType := cstmm;
  end; // with Result.PCCS()^ do
end; // end of function N_PrepUDPanelInmm

//******************************************************* N_CreateUDParaBox ***
// Create ParaBox with given User Coords
//
function N_CreateUDParaBox( AObjName: string; AUCoords: TFRect ): TN_UDParaBox;
begin
  Result := TN_UDParaBox(K_CreateUDByRTypeName( 'TN_RParaBox', 1, N_UDParaBoxCI ));
  Result.ObjName := AObjName;
  Result.SetSelfPosByURect( AUCoords );
end; // end of function N_CreateUDParaBox

//********************************************************* N_CreateMapRoot ***
// Create and return Map Root - (Root אשך Map Layers, of UDPanel type)
//
function N_CreateMapRoot(): TN_UDPanel;
begin
  Result := TN_UDPanel(K_CreateUDByRTypeName( 'TN_RPanel', 1, N_UDPanelCI ));
  Result.PCPanelS(); // Create Static CPanel RArray

  with Result.PCCS()^ do
  begin
    LRCoords :=  FPoint( 100, 100 );
    SRSize   :=  FPoint( 100, 100 );
    CompUCoords.Left := N_NotAFloat; // not given flag
    BPXCoordsType := cbpPercent;
    BPYCoordsType := cbpPercent;
    LRXCoordsType := cbpNotGiven;
    LRYCoordsType := cbpNotGiven;
    SRSizeXType   := cstPercentS;
    SRSizeYType   := cstPercentS;
    UCoordsType   := cutGiven;
    SRSizeAspType := catUCoords;
  end;

end; // end of function N_CreateMapRoot

//*********************************************************** N_PrepMapRoot ***
// Prepare Masp Root - Create, if needed, and return Map Root using
// given AMapParent and AMapObjName
//
//     Parameters
// AMapParent  - given Map Parent
// AMapObjName - given Map ObjName
//
// If Map already exists, just return it, otherwise create new Map by N_CreateMapRoot();
//
function N_PrepMapRoot( AMapParent: TN_UDBase; AMapObjName: string ): TN_UDPanel;
var
  TmpUDBase: TN_UDBase;
begin
  Assert( AMapParent <> nil, 'AMapParent is not given!' );
  TmpUDBase := N_GetUObjByPath( AMapParent, AMapObjName );

  if TmpUDBase = nil then // Create FOMap
  begin
    Result := N_CreateMapRoot();
    Result.ObjName := AMapObjName;
    AMapParent.AddOneChildV( Result );
  end  else // TmpUDBase <> nil
  begin
    Assert( TmpUDBase is TN_UDPanel, AMapObjName + ' is not TN_UDPanel!' );
    Result := TN_UDPanel( TmpUDBase );
  end;

end; // end of function N_PrepMapRoot

//*********************************************************** N_PrepParaBox ***
// Prepare UDParaBox - Create, if needed, and return UDParaBox
//
//     Parameters
// APatPB     - given TN_UDParaBox Pattern or nil if already exists
// AParent    - given Parent of Resulting TN_UDParaBox
// AObjName   - given ObjName for Resulting TN_UDParaBox
// Result     - return found or created TN_UDParaBox
//
// If UDParaBox already exists, just return it, otherwise create new UDParaBox
//
function N_PrepParaBox( APatPB: TN_UDParaBox; AParent: TN_UDBase; AObjName: string ): TN_UDParaBox;

var
  TmpUDBase: TN_UDBase;
begin
  Assert( AParent <> nil, 'AParent is not given!' );
  TmpUDBase := N_GetUObjByPath( AParent, AObjName );

  if TmpUDBase = nil then // Create new UDParaBox
  begin
    Result := TN_UDParaBox(N_CreateSubTreeClone( APatPB ));
    Result.ObjName := AObjName;
    AParent.AddOneChildV( Result );
  end  else // TmpUDBase <> nil, fill it
  begin
    Assert( TmpUDBase is TN_UDParaBox, AObjName + ' is not TN_UDParaBox!' );
    Result := TN_UDParaBox( TmpUDBase );
  end;
end; // end of function N_PrepParaBox

//************************************************************ N_AddParaBox ***
// Add UDParaBox - Create, and add it to given AParent, return created UDParaBox
//
//     Parameters
// APatPB     - given TN_UDParaBox Pattern
// AParent    - given Parent of Resulting TN_UDParaBox
// AObjName   - given ObjName for Resulting TN_UDParaBox, if not unique, it will be changed
// Result     - Return created TN_UDParaBox
//
function N_AddParaBox( APatPB: TN_UDParaBox; AParent: TN_UDBase; AObjName: string ): TN_UDParaBox;
begin
  Assert( AParent <> nil, 'AParent is not given!' );
  AObjName := N_CreateUniqueUObjName( AParent, AObjName );
  Result := TN_UDParaBox(N_CreateSubTreeClone( APatPB ));
  Result.ObjName := AObjName;
  AParent.AddOneChildV( Result );
end; // end of function N_AddParaBox

//******************************************************** N_CreateMapRoot2 ***
// Create Map Root with given params
//
function N_CreateMapRoot2( AUCoords: TFRect; APixSize: TPoint;
                          ASRSizeAspType: TN_CompSAspectType; AObjName: string ): TN_UDCompVis;
var
  PSCoords: TN_PCompCoords;
begin
  Result := TN_UDCompVis(K_CreateUDByRTypeName( 'TN_RPanel', 1, N_UDPanelCI ));
  Result.ObjName := AObjName;
  PSCoords := Result.PCCS();

//  TN_UDPanel(Result).PISP()^.PaBorderColor := N_EmptyColor; // "Clear" Borders

  FillChar( PSCoords^, SizeOf(TN_CompCoords), 0 );

  with PSCoords^ do
  begin
    BPXCoordsType := cbpPix;
    BPYCoordsType := cbpPix;

    SRSize := FPoint( APixSize );
    SRSizeXType := cstPixel;
    SRSizeYType := cstPixel;
    SRSizeAspType := ASRSizeAspType;

    CompUCoords := AUCoords;
    UCoordsType := cutGiven;
  end; // with PSCoords^ do
end; // end of function N_CreateMapRoot2

end.
