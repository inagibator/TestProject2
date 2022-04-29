unit N_GCont;
// Global Context class and methods
// (including procedures for creating various SVG, HTML and JavaScript fragments)

interface
uses Windows, Graphics, Classes, Comctrls, Controls, Variants, Types,
  K_Types, K_UDT1, K_Script1,
  N_Types, N_Lib0, N_Lib1, N_Lib2, N_Gra0, N_Gra1, N_Gra2, N_CompCL, N_BaseF;

type TN_CompExpFlags = set of ( cefExec, cefGDI, cefCoords,
                                cefGDIFile, cefTextFile,
                                cefWordDoc, cefExcelDoc );
// cefExec     - Component can be Executed by GCont.ExecuteRootComp method
// cefGDI      - Component can be rendered in OCanv (raster or emf) and shown in
//                 RastVCTForm by N_ViewUObjAsMap or saved to raster or emf file
// cefCoords   - Coords calculations are needed for visual components
// cefGDIFile  - OCanv content should be saved to file and can be shown by TN_RastVCTForm.ShowPictFile
// cefTextFile - export to Text (HTML, SVG, ...) File that can be shown or edited as text file
// cefWordDoc  - export to Word Document (may be not to File, but to current OLEServer)
// cefExcelDoc - export to Word Document (may be not to File, but to current OLEServer)

type TN_HTMLFragmType1 = ( htmltBeg, htmltPara, htmltEnd );
type TN_HTMLFragmType2 = ( htmltDivNxNy );
type TN_GCDebFlags = set of ( gcdfShowBorder, gcdfShowMarked );

type TN_DstImageType = ( ditNotDef, ditWinGDI, ditCoordsOnly,
                         // next elems are obsolete:
                         ditVML, ditSVG, ditJS, ditText, ditHTMLMap );



type TN_CompExportMode = ( cemDefault, cemSVG, cemVML, cemHTMLMap ); // now hot used at all!
// cemDefault - Export mode is set by Root Component,
// cemSVG     - Export to SVG,
// cemVML     - Export to VML (to HTML file as VML picture),
// cemHTMLMap - Export to HTML Map

type TN_ImageExportMode = ( iemToFile,  iemToClb,   iemToPrn,
                            iemHTMLMap, iemHTMLVML, iemSVG,
                            iemJustDraw );
// iemToFile    - Export to File (txt, bmp, gif, jpg, emf, htm, svg, ...)
// iemToClb     - Export to Clipboard (in EMF or DIB format)
// iemToPrn     - Export to default Printer (in EMF or DIB format)
// iemHTMLMap   - Export to text file in HTML Map format
// iemHTMLVML   - Export to HTML file in VML format
// iemSVG       - Export to SVG file in SVG format
// iemJustDraw  - Just Draw In Memory (to DstOCanv) for using Image in Pascal

type TN_ImageExportFlags = set of ( iefIsFirstPage, iefIsLastPage, iefUsePrnRes );
// iefIsFirstPage - Is First Page to Print (StartDoc() should be called before printing)
// iefIsLastPage  - Is Last  Page to Print (EndDoc() should be called after printing)
// iefUsePrnRes   - Use Printer Resolution for Root Component for printing

type TN_EPExecFlags  = set of ( epefInitByComp, epefShowTime, epefHALFTONE );
// epefInitByComp  - do not Initialize Comp SubTree if Comp has no cbfInitSubTree
// epefShowTime    - Collect and Show Execution Time

{
type TN_CompExportMode = ( cemDefault, cemSVG, cemVML, cemHTMLMap );   // not used any more!
// cemDefault - Export mode is set by Root Component,
// cemSVG     - Export to SVG,
// cemVML     - Export to VML (to HTML file as VML picture),
// cemHTMLMap - Export to HTML Map

type TN_ImageExportMode = ( iemNotGiven,  iemEMFClb,   iemBMPClb, // Old Var
                            iemEmbedFile, iemLinkFile, iemJustDraw );
// iemNotGiven  - Not Given (may be given in another field or defalt mode assumed)
// iemEMFClb    - Paste in Main Document using EMF Clipboard format
// iemBMPClb    - Paste in Main Document using BMP Clipboard format
// iemEmbedFile - Paste in Main Document from File (without linking)
// iemLinkFile  - Paste in Main Document Link to File, not File itself
// iemJustDraw  - Just Draw In Memory (to DstOCanv)

type TN_EPExecFlags  = set of ( epefInitByComp, epefShowTime );  // Old var
// epefNotCloseDoc, epefShowBefore, epefShowAfter, epefShowTime );
// epefInitByComp  - do not Initialize Comp SubTree if Comp has no cbfInitSubTree
//                      flag in Comp.CCompBase.CBFlags1

// epefNotCloseDoc - do Not Close Document after exporting to MS Word or Excel
// epefShowBefore  - Show OLE Server Before Exporting (mainly for debug)
// epefShowAfter   - Show OLE Server After Exporting (to see Created Document)
// epefShowTime    - Collect and Show Execution Time
}

type TN_ExpParams = packed record //***************** Component Export Params
  zzEPCompExpMode: TN_CompExportMode;   // Component Export Mode  // not used any more!
  EPImageExpMode:  TN_ImageExportMode;  // Image Export Mode
  EPExecFlags:     TN_EPExecFlags;      // Execute Flags
  EPImageExpFlags: TN_ImageExportFlags; // Image Export Flags
  EPMainFName:     string;              // Full Main File Name
  EPFilesExt:      string;              // New Image Files Extension
  EPImageFPar:     TN_ImageFilePar;     // Image File Params
  EPTextFPar:      TN_TextFilePar;      // Text File Params
end; // type TN_ExpParams = packed record
type TN_PExpParams = ^TN_ExpParams;

type TN_SLBuf = class( TObject ) //*** StringList Buffer
  ExtSLBuf: TStrings;    // External StringList Buffer
  RowBuf: string;        // One Row Buffer
  RowSize: integer;      // One Row Size
  Margin: integer;       // current left Margin (number of leading spaces)
  CSTMode: boolean;      // Comma Separated Tokens Mode
  constructor Create   ( ASL: TStrings; ARowSize: integer = 60 );
  procedure AddToken   ( AToken: string );
  procedure AddCSToken ( AToken: string );
  procedure AddSL      ( ASL: TStringList );
  procedure Flash      ( AToken: string = '' );
end; // type TN_SLBuf = class( TObject )

type TN_SPLMacroContext = packed record // SPL Macros Context (content of SPL _G var)
  PrevInd: integer; // Previous Iterator Index
  LastInd: integer; // Last Iterator Index
  CurParent:   TN_UDBase; // where UDCreator will create components
  LastCreated: TN_UDBase; // Last Created by UDCreator component UDRArray (in CurParent dir)
end; // type TN_SPLMacroContext = packed record
type TN_PSPLMacroContext = ^TN_SPLMacroContext;

type TN_OneSymbol = record // One Symbol Coords and Attributes
  SymbCoords: TN_ShapeCoords; // Symbol Coords
  SymbAttr:   TK_RArray;      // Symbol drawing Attributes
end; // type TN_OneSymbol = packed record
type TN_PSymbol = ^TN_OneSymbol;
type TN_Symbols = Array of TN_OneSymbol;

type TN_OneFlatLine = record // One Flat Line
  FLCoords:  TN_FPArray; // Flat Line Coords
  FLLengts:   TN_FArray; // Flat Line Segments Lengths
  FLNumPoints:  integer; // Number of Points in FLCoords (in FLLengts one elem less)
  FLWholeLength:  float; // Whole Flat Line Length (summ of all FLLengts elems)
end; // type TN_OneFlatLine = packed record
type TN_FlatLines = Array of TN_OneFlatLine;

type TN_PrepMarker = record // One Prepared Marker
  PMSymbols:  TN_Symbols; // Array of Symbols (Symbol Coords + Attributes)
  PMNumSymbols:  integer; // Number of Symbols in GCBSymbols
  PMPoints:   TN_IPArray; // integer Pixel Coords, where to draw markers
  PMNumPoints:   integer; // Number of elements in PMPoints
end; // type TN_PrepMarker = packed record
type TN_PrepMarkers = Array of TN_PrepMarker;

type TN_GContBuf = record // One Buf for Markers drawing
  GCBPMarkers: TN_PrepMarkers; // Array of Prepared Markers (parallel to ConAttr)

  GCBFlatLines: TN_FlatLines;  // Array of Flat Lines (Flat Lines Coords + Lengths)
  GCBNumFlatLines: integer;    // Number of elements in GCBFlatLines array

//  GCBIPixDashes: TN_AIArray;   // Dash sizes in integer Pixels (one TN_IArray per each ConAttr)
//  GCBFPixDashes: TN_AFArray;   // Dash sizes in float Pixels (one TN_FArray per each ConAttr)
  GCBLLWDashes: TN_AFArray;    // Dash sizes in LLW or in LengthPrc (one TN_FArray per each ConAttr)

  GCBFLPoints: TN_IPArray;     // IPoints for Flat WinGDI Path
  GCBFLFlags: TN_BArray;       // vertexes Flags for Flat WinGDI Path

  GCBSymbZPoints: TN_IPArray;  // PolyDraw IPoints at Zero Base Point
  GCBSymbSPoints: TN_IPArray;  // Shifted PolyDraw IPoints (for Shifted Symbols coords)
  GCBSymbFlags:   TN_BArray;   // Flags for GCBSymbZPoints and GCBSymbSPoints
end; // type TN_GContBuf = record
TN_GContBufs = Array of TN_GContBuf; // Buf Arrays, needed for nested Markers drawing

type TN_NKGlobCont = class( TK_CSPLCont )
  SPLComp: TObject; // really TN_UDCompBase
end; // type TN_NKGlobCont = class( TK_CSPLCont );

type TN_SideAttribs = record // used in DrawCPanel and GetCPanelIntRect methods
  SAFillRect: TRect; // OuterRect - Margins ( OuterBorders Rect)
  SAPixBorderWidth: integer; // All Borders Pix Width if Side Params are not given

  SALeftPixWidth:  integer;
  SALeftColor:     integer;
  SATopPixWidth:   integer;
  SATopColor:      integer;
  SARightPixWidth: integer;
  SARightColor:    integer;
  SABotPixWidth:   integer;
  SABotColor:      integer;
end; // type TN_SideAttribs = record
type TN_PSideAttribs = ^TN_SideAttribs;

type TN_GCAnimDrawMode = ( // Animation Draw Mode
  gcadmNotDef,     // not defined - drawing without animation
  gcadmBackground, // draw only Background
  gcadmSprite,     // draw only Sprite (moving object)
  gcadmBoth );     // draw Both Background and Sprite

type TN_GlobCont = class( TObject ) // Global Context of VCTree interpreter
  DstImageType: TN_DstImageType; // Destination (resulting) Image Type
  GCRootComp:   TObject;         // GlobCont Root Component, always TN_UDCompBase
  GVCTSizeType: TN_VCTSizeType;  // GlobCont Root Component Size Type

  DstMetaFile: TMetafile;       // Destination (resulting) Enh.Metafile
  DstMFCanvas: TMetafileCanvas; // Destination (resulting) Enh.Metafile Canvas
  DstOCanv:    TN_OCanvas;      // Destination (resulting) Win GDI Canvas, used also
                                // for expotring to not GDI formats (SVG, HTML, ... )

  // next seven Dst and Src fields are set before drawing VCTree and are not changed
  VisPixRect: TRect;   // Visible part of DstPixRect ( VisPixRect.TopLeft always = (0,0) )
  VisPixSize: TPoint;  // Visible part of DstPixRect Size (VisPixRect always = IRect(VisPixSize))
  DstPixRect: TRect;   // Destination (resulting) Pixel Rect (DstPixRect.Left,Top may be < 0)
  DstPixSize: TPoint;  // Destination (resulting) Size in Pixels (Sizes of DstPixRect)
  DstmmSize: TFPoint;  // Destination (resulting) Size in millimeters
  SrcPixSize: TPoint;  // Source (component) Size in Pixels
  SrcmmSize: TFPoint;  // Source (component) Size in millimeters
  AnimDrawMode: TN_GCAnimDrawMode; // Animation Draw Mode

  // next three fields are set (and restored) by Components with cbfSelfSizeUnits flag in CBFlags1
  GCCurSrcPixSize: TPoint; // Current Source Size in Pixels
  GCCurSrcmmSize: TFPoint; // Current Source Size in millimeters
  GCCurDstPixSize: TPoint; // Current Destination Size in Pixels

  // next two fields are set before drawing each Component in TN_UDCompVis.SetSizeUnitsCoefs method
  mmPixSize:  TDPoint;    // DstPixSize(X,Y) := SizeInmm*mmPixSize(X,Y)
  PixPixSize: TDPoint;    // DstPixSize(X,Y) := SizeInPix*PixPixSize(X,Y)

  MSParentPixSize:   float;   // used only in ConvMSToPix as global input parameter
  MSParentPixXYSize: TFPoint; // used only in ConvMSToPix as global input parameter (for Points and Rects)

  GCOutSL: TStringList;      // Output StringList (where to create SVG, HTML, ... content)
  GCOutStyleSL: TStringList; // Output StringList for Style section
  GCOutSLBuf: TN_SLBuf;      // Buffer for adding to GCOutSL separate tokens
  GCPatternSL: TStringList;  // Pattern File, loaded into StringList
  GCOutLabelInd: integer;    // Label row index in GCPatternSL

  GCDebFlags: TN_GCDebFlags; // Global Context Debug Flags

  SVGIdPref:    string;   // SVG prefix before ID
  SVGIdObjName: string;   // SVG Id attribute ( i.e. id="MapLayerObjName")
  SVGPenWidth:  string;   // SVG stroke-width attribute ( i.e. stroke-width="0.105")
  SVGPenColor:  string;   // SVG stroke attribute ( i.e. stroke="#FF0000")
  SVGFillColor: string;   // SVG fill attribute ( i.e. fill="#FF0000")

  GCMacroPtrs: TN_PSArray;  // pointers to Strings with Macros
  GCMPtrsNum:  integer;     // number of elements in GCMacroPtrs
//  TextStyleSL: TStringList; // Text (HTML,SVG,...) Style Content
//  TextBodySL:  TStringList; // Text (HTML,SVG,...) Body Content
//  TextBodySLBuf: TN_SLBuf;  // Buffer for adding to TextBodySL separate tokens

  StopExecFlag:  boolean; // Execution should be stopped if this flag is Set
  GCCoordsMode:  boolean; // Coords Export Mode - if True, all export is done inside GCont.Draw methods
  GCTextMode:    boolean; // Text (HTML, SVG, ...) Export Mode
  GCMSWordMode:  boolean; // MS Word  Export Mode (Export to MS Word OLE Server)
  GCMSExcelMode: boolean; // MS Excel Export Mode (Export to MS Excel OLE Server)

  //***** Word related fields
  GCWordServer:     Variant;     // Word OLE Server
  GCWSVBAFlags:  TN_MEWordFlags; // Word OLE Server VBA related Flags
  GCWSMajorVersion: integer;     // Word OLE Server Major version (8-97, 9-200, 10-202(XP), 11-2003)
  GCProperWordIsAbsent: boolean; // False if all is OK
  GCWSWasCreated:   boolean;     // GCWordServer was created
  GCWSWasVisible:   boolean;     // Saved GCWordServer visibility
  GCMSWordMacros:  TStringList;  // MS Word  Macros Names (DelhiName=WordName)
  GCPDCounter:      integer;     // Processed Documents Counter
  GCPDCounterDelta: integer;     // GCPDCounter Delta (used for calling intermediate Save)
  GCWSMainDoc:      Variant;     // Word Main Document (doc beeing exported)
  GCWSMainDocIP:    Variant;     // GCWSMainDoc Insertion Point (empty Range)
  GCStrVars:    TStringList;     // Named string variables for communicating between documents (?)
  GCWSDocNames: TStringList;     // Currently opened Full Docs Names
  GCCurWTable:      Variant;     // Current Word Table for using in SPL functions
  GCWSCurDoc:       Variant;     // for using Word Document in SPL functions
  GCWSOutDir:        string;     // Out Files Directory
  GCWSTmpDir:        string;     // Tmp Files Directory
  GCWSPSMode:   TN_MEWordPSMode;   // Passing params between VBA and Delphi mode
  GCWSPSDoc:        Variant;     // Word special Document used for passing params

  //***** Excel related fields
  GCExcelServer:   Variant;     // Excel OLE Server
  GCESMajorVersion: integer;    // Excel OLE Server Major version (8-97, 9-200, 10-202(XP), 11-2003)
  GCMSExcelMacros: TStringList; // MS Excel Macros Names (DelhiName=WordName)
  GCESWasCreated:  boolean;     // GCExcelServer was created
  GCESSavedVis:    boolean;     // Saved GCExcelServer visibility
  GCESMainDoc:     Variant;     // Excel Main Document (doc beeing exported)
  GCCurESheet:     Variant;     // Current Excel Sheet for using in SPL functions
  GCCurEChart:     Variant;     // Current Excel Chart for using in SPL functions
  GCCurMacroAdr:   string;      // Excel Cell Addres of current Macro (i.e. '=Sheet1!$B$2' )
  GCESCurDoc:      Variant;     // for using Excel Document in SPL functions

  SPLMCont: TN_SPLMacroContext; // should be copied to SPL _G variable
  GCOwnerForm: TN_BaseForm;     // used in some nonvisual components
  GCBFreeInd: integer;          // Free Index in SymbsArray and LengthsArray
  GCBufs: TN_GContBufs;         // Array of TN_GContBuf
  GCExpParams: TN_ExpParams;    // VCTree Export Params
  GCExpFlags: TN_CompExpFlags;  // VCTree Export Flags
  GCNKGCont: TN_NKGlobCont;     // for SPL Macros

  GCMainFileName: string;       // Full Main File Name
  GCNewFilesDir:  string;       // Full Name of New Files Dir

  GCNewFilesInd:  integer;              // Index for creating New Files Names
  GCShowResponseProc: TN_OneStrProcObj; // used in Self.GCShowResponse procedure
  GCPrepForExportFailed: boolean;       // Is False if all is OK

  GCSavedCursor:  TCursor;   // for setting temporary Cursor to crHourglass
  GCTimerFull: TN_CPUTimer1; // Timer for collecting Full execution Time
  GCTimerFin:  TN_CPUTimer1; // Timer for collecting Finishing Time

  GCVarInfoProc: TK_MVGetVarInfoProc; // ProcOfObj for getting Info about Global User Variable
  GCShowMessageProc : TK_MVShowMessageProc; // Show Message Procedure of Object

  GCUsesName: string;               // SPL Unit Name for adding to Uses statement

  constructor Create; overload;
  constructor CreateByGCont ( AGCont: TN_GlobCont ); overload;
  destructor  Destroy; override;
  procedure   GCUpdateSelf  ( AGCont: TN_GlobCont );

    //************************  New Drawing methods  **********

  procedure FreeMarkers    ( ALevel: integer );
  procedure PrepareMarkers ( ALevel: integer; AContAttr: TK_RArray );
  procedure WinGDIPolyDraw ( const APoints; const ATypes; ACount: integer;
        APContAttr: TN_PContAttr; APDashSizes: PFloat = nil; ANumDashes: integer = 0 );
  procedure DrawShape      ( AShapeCoords: TN_ShapeCoords; AContAttr: TK_RArray;
                                          const AShiftSize: TFPoint ); overload;
  procedure DrawTextRects  ( APTextRect: TN_PTextRect; ANumTextRects: integer;
                             APTextBlock: TN_POneTextBlock; ATopLeft: TPoint );
  procedure DrawStraightArrow  ( APCSArrow: TN_PCSArrow );
//  procedure GSetFont       ( ANFont: TObject; ABLAngle: float = 0 );
  procedure GDrawString    ( AStr: string; ABasePoint: TFPoint;
                                           APStrPos: TN_PStrPosParams );

    //************************  Old Drawing methods  **********
    // only new DrawShape( ShapeCoords, ContAttr, ... ) method should be used,
    // Now:
    //   DrawIntPolyline is used in DrawAuxLine
    //   DrawUserPoint is used in VectorEditor (N_VRE3 unit)
    //   old DrawShape methods are used in UDPieSegment

  procedure DrawShape ( APFlags: PByte; APPoints: PPoint; ANumPoints,
      ABrushColor, APenColor: integer; APenWidth: float; APenStyle: integer = 0;
               ANumDashes: integer = 0; APDashSizes: PFloat = nil ); overload;
  procedure DrawShape ( APFlags: PByte; APPoints: PPoint; ANumPoints: integer;
                                               AContAttr: TK_RArray ); overload;
  procedure DrawShape ( APData: PInteger; ANumInts, ABrushColor, APenColor: integer;
            APenWidth: float; APenStyle: integer = 0; ANumDashes: integer = 0;
                                        APDashSizes: PFloat = nil ); overload;
//  procedure DrawShape ( AShapeCoords: TN_ShapeCoords; ABrushColor,
//                      APenColor: integer; APenWidth: float; APenStyle: integer = 0;
//                      ANumDashes: integer = 0; APDashSizes: PInteger = nil ); overload;
  procedure DrawFilledPixRect   ( const APixRect: TRect; AFillColor: integer );

  procedure DrawIntPolygon      ( APPoint: PPoint; ANumPoints, ABrushColor,
                 APenColor: integer; APenWidth: float; APenStyle: integer = 0;
                    ANumDashes: integer = 0; APDashSizes: PFloat = nil );
  procedure DrawIntPolyline     ( APPoint: PPoint; ANumPoints, APenColor: integer;
                               APenWidth: float; APenStyle: integer = 0;
                    ANumDashes: integer = 0; APDashSizes: PFloat = nil );
  procedure DrawEllipse      ( AEnvRect: TRect;
                            ABrushColor, APenColor: integer; APenWidth: float );
  procedure DrawPixPoint     ( APoint: TPoint; APParams1: TN_PPointAttr1;
                    APParams2: TN_PPointAttr2 = nil; ANumParams2: integer = 0 );
  procedure DrawUserPoint ( const AUserBP: TDPoint; APParams1: TN_PPointAttr1;
                    APParams2: TN_PPointAttr2 = nil; ANumParams2: integer = 0 );
  procedure DrawUserSysPolyline ( PPoints: PDPoint;
                              NumPoints: integer; PAttribs: TN_PSysLineAttr );
  procedure DrawPixRoundRect ( const APixRect: TRect; APixRadXY: TPoint;
                            ABrushColor, APenColor: integer; APenWidth: Float );

    //************************  Component Interpreter methods  **********
  procedure GCShowResponse ( AStr: string );
  procedure GCSetStrVar    ( AVarName: string; AVarContent: string );
  function  GCGetStrVar    ( AVarName: string ): string;
  procedure InitGCByType   ( ADstImageType: TN_DstImageType;
                                                AOCanvType: TN_OCanvType );
  procedure SetRootComp    ( ARootComp: TObject );
  procedure SetSizes       ( const ADstPixRect: TRect; const ADstmmSize: TFPoint );

  function  ConvMSToPix    ( ASize: float; AUnit: TN_MSizeUnit;
                                            APFraction: PFloat = nil ): integer; overload;
  function  ConvMSToPix    ( const AMPointSize: TN_MPointSize;
                                            APFractions: PFPoint = nil ): TPoint; overload;
  function  ConvMSToPix    ( const AMRectSize: TN_MRectSize;
                                            APFractions: PFRect = nil ): TRect; overload;
  function  ConvMSToFPix   ( ASize: float; AUnit: TN_MSizeUnit;
                                               AFullPixSize: Float = 0 ): float; overload;
  function  ConvMSToFPix   ( const AMPointSize: TN_MPointSize;
                                                  AFullSize: TFPoint ): TFPoint; overload;
  function  ConvMSToDblPix ( ASize: float; AUnit: TN_MSizeUnit ): double;

  function  ConvMSToLSU ( ASize: float; AUnit: TN_MSizeUnit; AFullSizeLSU: float = 0 ): float;  overload;
  function  ConvMSToLSU ( const AMPointSize: TN_MPointSize; APFullPSizeLSU: PFPoint = nil ): TFPoint; overload;

  procedure CalcODFSCoords ( ANumElems, AFullPixSize: integer;
                        APODFSParams: TN_PODFSParams; var ACoords: TN_IPArray );

//  procedure SaveCoords     ( out SavedCoords: TN_OCanvCoords );
//  procedure RestoreCoords  ( const SavedCoords: TN_OCanvCoords );

  procedure DrawRootComp ( const AVisPixRect: TRect );
  procedure AddPtrToMText       ( var AMText: string );
  procedure AddTextBlocksMPtrs  ( ATextBlocks: TK_RArray );
  procedure TextBlocksToHTML    ( ATextBlocks: TK_RArray );

    //*********************************  Word related methods  **********
  procedure DefWordServer         ();
  function  GetWSInfo             ( AMode: integer; AHeader: string = '' ): TStringList;
  procedure OpenWordDocSafe       ( AFullFileName: string );
  procedure CloseWordDocSafe      ( AFullFileName: string );
  procedure WordProcessSPLMacros  ( AComp: TN_UDBase; ADoc: Variant );
  procedure WordPasteClipBoard    ();
  procedure TextBlocksToMSWord    ( ATextBlocks: TK_RArray );
  function  WordInsNearBookmark   ( AWhere: TN_WordInsBmkWhere;
                                    AWhat:  TN_WordInsBmkWhat; ABookmarkName: string;
                                                    AContent: string = '' ): variant;
  procedure WordExpAndInsSubdoc   ( ASubDocComp: TObject; AFileName: string );
  function  AddPDCounter          ( AStr: string ): string;
  procedure SetWordPSMode         ( AMode: TN_MEWordPSMode );
  procedure SetWordParamsStr      ( AParStr: string );
  function  GetWordParamsStr      (): string;
  procedure RunWordMacro          ( AName: string );

    //*********************************  Excel related methods  **********
  procedure DefExcelServer      ();
  procedure CloseExcelDocSafe   ( AFileName: string );
  procedure ProcessExcelMacros  ( AComp: TN_UDBase; ADoc: Variant );
  procedure TextBlocksToMSExcel ( ATextBlocks: TK_RArray );
  procedure RunExcelMacro       ( AName: string );

//  procedure ProcessOLEMacros ( AComp: TN_UDBase; ADoc: Variant; ADocType: TN_OLEDocType );
  function  GetNewFilesDir   ( ACreate: boolean ): string;
  function  PrepNewFileName  ( AFName, AFNamePat: string ): string;
  procedure PrepForExport    ( ARootComp: TObject; APExpParams: TN_PExpParams = nil );
  procedure FinishExport     ();
  procedure ExecuteComp      ( AComp: TObject; AInitFlags: TN_CompInitFlags = [] );
  procedure ExecuteRootComp  ( AComp: TObject; AInitFlags: TN_CompInitFlags = [];
                                 AShowResponse: TN_OneStrProcObj = nil; AOwner: TN_BaseForm = nil;
                                 APExpParams: TN_PExpParams = nil; ABackColor: integer = N_EmptyColor );
  function  DrawCPanel       ( ARCPanel: TK_RArray;  ABasePixRect: TRect ): TRect; overload;
  function  DrawCPanel       ( APCPanel: TN_PCPanel; ABasePixRect: TRect; ADefColor: integer ): TRect; overload;
  function  GetCPanelIntRect ( ARCPanel: TK_RArray; AOuterPixRect: TRect;
                                    APSideAttribs: TN_PSideAttribs = nil ): TRect; overload;
  function  GetCPanelIntRect ( APCPanel: TN_PCPanel; AOuterPixRect: TRect;
                                    APSideAttribs: TN_PSideAttribs = nil ): TRect; overload;
//  procedure PrepareRootCont  ();
  procedure DebAddDocsInfo   ( AHeader: string; AMode: integer );
  procedure GCShowString     ( AStr: string );
  procedure GCAddToProtocol  ( AStr: string );

    //*********************************  VML oriented methods  **********
  procedure AddHTMLHeader    ( ATitle: string );

  procedure VMLAddHTMLHeader    ();
  procedure VMLAddTopLevelGroup ();
  function  VMLPos      ( ARect: TRect ):  string; overload;
  function  VMLPos      ( ARect: TFRect ): string; overload;
  function  VMLPenBrush ( ABrushColor, APenColor: integer; APenWidth: float ): string;
  procedure DrawToVML ();
//  procedure DrawToEMF (); // not needed?
end; // type TN_GlobCont

    //*********** Global Procedures  *****************************

procedure N_AddHTMLFragm  ( AHTML: TStrings; AFragmType: TN_HTMLFragmType1 );
function  N_CreateColorRects ( AOPCRows: TN_OPCRowArray; ANumOPCRows: integer;
                                         var ACRects: TN_CRectArray ): integer;
procedure N_ConvColorRectsToJS ( ASL: TN_SLBuf;
                                 ACRects: TN_CRectArray; ANumCRects: integer );

procedure N_SetWordRangeEnd ( ARange: Variant; AEnd: integer );
function  N_GetWordRangeEnd ( ARange: Variant ): integer;

var
  N_ActiveGCont: TN_GlobCont; // used in Pascal code of SPL functions
  N_GC: TN_GlobCont; // for debug


implementation
uses Math, SysUtils, Printers, ComObj, ActiveX, Forms, Clipbrd, StrUtils,
  K_CLib0, K_CLib, K_UDT2,
  N_ClassRef, N_CompBase, N_UDat4, N_Rast1Fr, N_EdParF,
  N_ME1, N_WebBrF, N_Comp3, N_InfoF, N_ButtonsF, N_EdStrF;

//********** TN_SLBuf class methods  **************

//******************************************** TN_SLBuf.Create ***
//
constructor TN_SLBuf.Create( ASL: TStrings; ARowSize: integer );
begin
  inherited Create();
  ExtSLBuf := ASL; // ASL is NOT owned by Self
  RowBuf   := StringOfChar( ' ', Margin );
  RowSize  := ARowSize;
end; // constructor TN_SLBuf.Create

//*************************************** TN_SLBuf.AddToken ***
// Add given Token to RowBuf
//
procedure TN_SLBuf.AddToken( AToken: string );
begin
  if ( Length(RowBuf) + Length(AToken) ) > RowSize then
  begin
    ExtSLBuf.Add( RowBuf );
    RowBuf := StringOfChar(' ', Margin) + AToken;
  end else
  begin
    RowBuf := RowBuf + AToken;
  end;
end; // end_of procedure TN_SLBuf.AddToken

//*************************************** TN_SLBuf.AddCSToken ***
// Add given Comma Separated Token to RowBuf
// (add ',' before token in CSTMode)
//
procedure TN_SLBuf.AddCSToken( AToken: string );
begin
  if CSTMode then RowBuf := RowBuf + ','
  else CSTMode := True;

  AddToken( AToken );
end; // end_of procedure TN_SLBuf.AddCSToken

//*************************************** TN_SLBuf.AddSL ***
// Add given StringList ASL to RowBuf
//
procedure TN_SLBuf.AddSL( ASL: TStringList );
var
  i: integer;
begin
  for i := 0 to  ASL.Count-1 do
    AddToken( ASL[i] );
end; // end_of procedure TN_SLBuf.AddSL

//*************************************** TN_SLBuf.Flash ***
// Flash RowBuf
//
procedure TN_SLBuf.Flash( AToken: string );
begin
  CSTMode := False; // clear Comma Separated Tokens Mode
  AddToken( AToken );

  if RowBuf <> '' then
  begin
    ExtSLBuf.Add( RowBuf );
    RowBuf := StringOfChar(' ', Margin);
  end;
end; // end_of procedure TN_SLBuf.Flash


    //*********** TN_GlobCont class methods  *****************************

//********************************************** TN_GlobCont.Create ***
//
constructor TN_GlobCont.Create();
begin
  inherited Create();
  GCNKGCont    := TN_NKGlobCont.Create();
  GCTimerFull  := TN_CPUTimer1.Create();
  GCTimerFin   := TN_CPUTimer1.Create();
  GCStrVars    := TStringList.Create();
  GCWSDocNames := TStringList.Create();
//  GCWSVBAFlags := N_MEGlobObj.MEWordFlags; recursive use in N_ME1 initialisation
  GCWSOutDir  := N_GCWSInitialDir;
  GCPDCounterDelta := 50;
  if Length(N_DelphiMem) < 64008 then SetLength( N_DelphiMem, 64008 );
end; // end_of constructor TN_GlobCont.Create

//********************************************** TN_GlobCont.CreateByGCont ***
// Create and initialize new GCont by given AGCont
// (usually GCUpdateSelf should be called before destruction)
//
constructor TN_GlobCont.CreateByGCont( AGCont: TN_GlobCont );
begin
  Create();
  DstOcanv := AGCont.DstOCanv;
  AGCont.DstOCanv := nil; // just to check errors, AGCont.DstOCanv shoud be restored in

  GCShowResponseProc := AGCont.GCShowResponseProc; // procedure ShowString( AStr: string ) of object
  GCOwnerForm := AGCont.GCOwnerForm; // Owner Form, can be nil

  Self.GCNewFilesInd := AGCont.GCNewFilesInd;
  Self.GCPDCounter   := AGCont.GCPDCounter;

  // Swapping is really not neeeded, but faster then creating new object
  N_SwapTObjects( TObject(Self.GCStrVars), TObject(AGCont.GCStrVars) );
  N_SwapTObjects( TObject(Self.GCWSDocNames), TObject(AGCont.GCWSDocNames) );
end; // end_of constructor TN_GlobCont.CreateByGCont

//********************************************* TN_GlobCont.Destroy ***
//
destructor TN_GlobCont.Destroy;
var
  i, j, k: integer;
begin
  GCNKGCont.Free;
  GCOutSL.Free;
  GCOutStyleSL.Free;
  GCOutSLBuf.Free;
  GCPatternSL.Free;
  DstMetaFile.Free;
  GCTimerFull.Free;
  GCTimerFin.Free;
  GCStrVars.Free;
  GCWSDocNames.Free;
  GCMSWordMacros.Free;
  GCMSExcelMacros.Free;

  GCWSMainDoc   := UnAssigned();
  GCWSMainDocIP := UnAssigned();
  GCWSPSDoc     := Unassigned();
  GCWSCurDoc    := UnAssigned();
  GCCurWTable   := UnAssigned();

  GCESCurDoc  := UnAssigned();
  GCCurESheet := UnAssigned();
  GCCurEChart := UnAssigned();

  if not VarIsEmpty(GCWordServer) then // normally GCWordServer should be empty
  begin
    if GCWSWasCreated and not GCWordServer.Visible then
      GCWordServer.Quit;
  end;
  GCWordServer  := UnAssigned();

  GCExcelServer := UnAssigned();

  if DstOCanv <> nil then
  begin
    if DstOCanv.OCanvType <> octRFrameRaster then
      DstOCanv.Free;
  end;

  for i := 0 to High(GCBufs) do
  with GCBufs[i] do
  begin
    for j := 0 to High(GCBPMarkers) do
      for k := 0 to High(GCBPMarkers[j].PMSymbols) do
      with GCBPMarkers[j].PMSymbols[k] do
      begin
        SymbCoords.Free;
        SymbAttr.Free;
      end; // for k, j
  end;

  inherited Destroy;
end; // end_of destructor TN_GlobCont.Destroy

//******************************************** TN_GlobCont.GCUpdateSelf ***
// Update Self by given AGCont
// (usually should be called if created by CreateByGCont constructor)
//
procedure TN_GlobCont.GCUpdateSelf( AGCont: TN_GlobCont );
begin
  Self.DstOcanv := AGCont.DstOCanv;
  AGCont.DstOCanv := nil; // is needed to avoid destroying DstOCanv in AGCont.Destroy

  Self.GCNewFilesInd := AGCont.GCNewFilesInd;
  Self.GCPDCounter   := AGCont.GCPDCounter;

  // Swapping is really not neeeded, but faster then creating new object
  N_SwapTObjects( TObject(Self.GCStrVars), TObject(AGCont.GCStrVars) );
  N_SwapTObjects( TObject(Self.GCWSDocNames), TObject(AGCont.GCWSDocNames) );
end; // procedure TN_GlobCont.GCUpdateSelf


    //************************  New Drawing methods  **********

//************************************************* TN_GlobCont.FreeMarkers ***
// Free GCBufs[ALevel].GCBPMarkers
//
procedure TN_GlobCont.FreeMarkers( ALevel: integer );
var
  j, k: integer;
begin
  with GCBufs[ALevel] do
  begin
    for j := 0 to High(GCBPMarkers) do
      for k := 0 to High(GCBPMarkers[j].PMSymbols) do
      with GCBPMarkers[j].PMSymbols[k] do
      begin
        SymbCoords.Free;
        SymbAttr.Free;
      end; // for k, j
  end; // with GCBufs[ALevel] do
end; // procedure TN_GlobCont.FreeMarkers

//******************************************** TN_GlobCont.PrepareMarkers ***
// Prepare Markers in GCBufs[ALevel].GCBPMarkers
//
procedure TN_GlobCont.PrepareMarkers ( ALevel: integer; AContAttr: TK_RArray );
var
  i, j, k, Ind, NumAttr, SymbInd, NumLines, NumCAMarkers, TextLeng: integer;
  kk: integer;
  PMPFreeInd, CurFreeInd: integer;
  Delta, Step: float;
  PIPoint: PPoint;
  TmpMarker: TN_PointAttr2;
  PixLine: Array [0..3] of TFPoint;
  PCA: TN_PContAttr;
  PMA: TN_PPointAttr2;
  PCurSymbol: TN_PSymbol;
  CurStandShape: TN_StandartShape;
  SinglePath: boolean;

  function PrepSymbol( AAttrInd, ASymbInd: integer; APDefAttr: TN_PContAttr;
                                 APMarker: TN_PPointAttr2 ): TN_PSymbol; // local
  // Prepare SymbAttr and initialize SymbCoords
  // Return pointer to initialized Symbol
  var
    PCurCA: TN_PContAttr;
  begin

    with GCBufs[ALevel].GCBPMarkers[AAttrInd] do
    begin
      //***** Create and prepare SymbAttr
      Result := @PMSymbols[ASymbInd];

      PCurCA := N_PrepContAttr( Result^.SymbAttr );

      with PCurCA^, APMarker^ do
      begin
        CAPenColor   := PAPenColor;
        CAPenWidth   := PAPenWidth;
        CAPenStyle   := PAPenStyle or PS_GEOMETRIC; // otherwise last pixel in line would not be drawn!
        CABrushColor := PABrushColor;

        if CAPenColor   = N_CurColor   then CAPenColor   := APDefAttr^.CAPenColor;
        if CAPenWidth   = N_CurLLWSize then CAPenWidth   := APDefAttr^.CAPenWidth;
        if CABrushColor = N_CurColor   then CABrushColor := APDefAttr^.CABrushColor;
      end; // with PCurCA^, APMarker do

      //***** Create if needed and initialize SymbCoords

      with Result^ do
        if SymbCoords = nil then
          SymbCoords := TN_ShapeCoords.Create()
        else
          SymbCoords.Clear();

    end; // with GCBufs[ALevel].GCBPMarkers[AAttrInd] do
  end; // function PrepSymbol  - local

  procedure CreateSpecParamsRArray( ASPType: TN_PointAttr2Type ); // local
  // Create given Special Type RArray in TmpMarker.PASP
  begin
    with TmpMarker do
    begin
      if PASP <> nil then PASP.Free;
      PAType := ASPType;
      PASP := K_RCreateByTypeName( N_PA2SPTypes[integer(PAType)-1], 1 );
    end; //
  end; // procedure CreateSpecParamsRArray - local

  procedure AddShapeToSymbCoords(); // local
  // Add elements to PCurSymbol^.SymbCoords by TmpMarker
  var
    CosA, SinA: double;
    PixFCenter, PixFSize: TFPoint;
    PixFRect: TFRect;
    TextSize: TSize;

{
    DC: TN_DPArray;
    j, k, NumParts, NumItems, NPoints: integer;
    CL: TN_ULines;
    MemPtr: TN_BytesPtr;
    AffCoefs: TN_AffCoefs4;
}

    function Rotate( const AFPoint: TFPoint ): TFPoint; // local in AddShapeToSymbCoords
    // rotate given FPoint relative to PixFCenter
    var
      DX, DY: double;
    begin
      DX := AFPoint.X - PixFCenter.X;
      DY := AFPoint.Y - PixFCenter.Y;
      Result.X := Round( DX*CosA - DY*SinA + PixFCenter.X );
      Result.Y := Round( DX*SinA + DY*CosA + PixFCenter.Y );
    end; // function Rotate - local in AddShapeToSymbCoords

  begin //************** body of local procedure AddShapeToSymbCoords

  with DstOCanv, TmpMarker, PCurSymbol^ do
  begin

    if PAType = patTextRow then // set PASizeXY by real Text Size
    with TN_PPA2TextRow(PASP.P())^ do
    begin
      N_SetUDFont( PAFont, DstOCanv, PAFSCoef );
      TextLeng := Length( PAText );
      GetTextExtentPoint32( HMDC, @PAText[1], TextLeng, TextSize );
      PASizeXY.X := TextSize.cx / CurLSUPixSize;
      PASizeXY.Y := TextSize.cy / CurLSUPixSize;
    end; // with TN_PPA2TextRow(PASP.P())^ do, if PAType = patTextRow then

    PixFCenter.X := Round( (PAShiftXY.X + PASizeXY.X*(0.5 - PAHotPoint.X))*CurLSUPixSize );
    PixFCenter.Y := Round( (PAShiftXY.Y + PASizeXY.Y*(0.5 - PAHotPoint.Y))*CurLSUPixSize );

    PixFSize := N_Round( PASizeXY, CurLSUPixSize );

    //***** PixFRect is Float Pixel Coords:
    //      2x2 pix rect with (1,1) center is (0,0,1,1) )

    PixFRect := N_EllipseEnvRect( PixFCenter, PixFSize );

    case PAType of

    patStrokeShape: // Stroked Shape (straight lines only)
    with TN_PPA2StrokeShape(PASP.P())^ do
    begin

      with PixFRect do
      case PASSType of

      sstMinus: begin // Minus ('-', one horizontal dash)
        NumLines := 1;
        PixLine[0].X := Left;
        PixLine[0].Y := PixFCenter.Y;
        PixLine[1].X := Right;
        PixLine[1].Y := PixFCenter.Y;
      end; // sstMinus: begin // Minus ('-', one horizontal dash)

      sstPlus: begin // Plus ('+', two dashes)
        NumLines := 2;
        PixLine[0].X := Left;
        PixLine[0].Y := PixFCenter.Y;
        PixLine[1].X := Right;
        PixLine[1].Y := PixFCenter.Y;

        PixLine[2].X := PixFCenter.X;
        PixLine[2].Y := Top;
        PixLine[3].X := PixFCenter.X;
        PixLine[3].Y := Bottom;
      end; // sstPlus: begin // Plus ('+', two dashes)

      sstDiagonals: begin // two Diagonals ('x', two dashes, Mult sign)
        NumLines := 2;
        PixLine[0].X := Left;
        PixLine[0].Y := Top;
        PixLine[1].X := Right;
        PixLine[1].Y := Bottom;

        PixLine[2].X := Right;
        PixLine[2].Y := Top;
        PixLine[3].X := Left;
        PixLine[3].Y := Bottom;
      end; // sstDiagonals: begin // two Diagonals ('x', two dashes, Mult sign)

      end; // case PASSType of, with PixRect do

      CosA := Cos( N_PI*PASSAngle/180 );
      SinA := Sin( N_PI*PASSAngle/180 );

      SymbCoords.SCNewPenPos := True;
      SymbCoords.AddOnePoint( Rotate( PixLine[0] ) );
      SymbCoords.AddOnePoint( Rotate( PixLine[1] ) );

      if NumLines = 2 then
      begin
        SymbCoords.SCNewPenPos := True;
        SymbCoords.AddOnePoint( Rotate( PixLine[2] ) );
        SymbCoords.AddOnePoint( Rotate( PixLine[3] ) );
      end;

    end; // with TN_PPA2StrokeShape(PASP.P())^ do, patStrokeShape: // Stroked Shape

    patRoundRect: // RoundRect
    with TN_PPA2RoundRect(PASP.P())^ do
    begin
      SymbCoords.AddRoundRect( PixFRect, PAEllSizeXY );
    end; // with TN_PPA2RoundRect(PASP.P())^ do, patRoundRect: // RoundRect

    patEllipseFragm: // Elliptical Arc shape (Ellipse, Arc, Chord or PieSegm)
    with TN_PPA2EllipseFragm(PASP.P())^ do
    begin
      SymbCoords.AddEllipseFragm( PixFRect, PAEBorderType,
                                  PAEBegAngle, PAEArcAngle );
    end; // with TN_PPA2EllipseFragm(PASP.P())^ do, patEllipseFragm:

    patRegPolyFragm: // Regular Polygon Arc shape (Arc, Chord or PieSegm)
    with TN_PPA2RegPolyFragm(PASP.P())^ do
    begin
      SymbCoords.AddRegPolyFragm( PixFRect, PAPBorderType,
                                  PAPBegAngle, PAPArcAngle, PAPNumSegments );
    end; // with TN_PPA2RegPolyFragm(PASP.P())^ do, patRegPolyFragm:

    patTextRow: // Text Row (at any angle), angle not implemented yet!
    with TN_PPA2TextRow(PASP.P())^ do
    begin // Font and Position is already OK
      SetTextColor( HMDC, PAPenColor ); // WinGDI function
      SetTextCharacterExtra( HMDC, Round( PACESpace*CurLSUPixSize ) );
///1      ExtTextOut( HMDC, PixIRect.Left, PixIRect.Top, 0, nil, @PAText[1], TextLeng, nil );
    end; // with TN_PPA2TextRow(PASP.P())^ do, pattTextRow: begin // Text Row (at any angle)

    patArrow: // Arrow
    with TN_PPA2Arrow(PASP.P())^ do
    begin
    // not implemented
    end; // with TN_PPA2Arrow(PASP.P())^ do, patArrow: // Arrow

    patPolyLine: // PolyLine // should be replaced by any component
    begin

{
    with TN_PPA2PolyLine(PASP.P())^ do
    if PALCObj.CI = N_ULinesCI then // a precaution
    begin
      CL := TN_ULines(PALCObj);
      DC := nil;

      SetBrushAttribs( PABrushColor );
      SetPenAttribs( PAPenColor, PAPenWidth );

      with AffCoefs do
      begin
        CX := CurLSUPixSize;
        SX := PixFRect.Left;
        CY := CurLSUPixSize;
        SY := PixFRect.Top;
      end;

      if paplfSinglePath in PALFlags then BeginPath( HMDC );

      NumItems := PALNumItemsToDraw;
      if NumItems = 0 then
        NumItems := CL.WNumItems - PALBegItemToDraw;

      for j := PALBegItemToDraw to PALBegItemToDraw+NumItems-1 do
      begin
        if not (paplfSinglePath in PALFlags) then BeginPath( HMDC );

        CL.GetNumParts( j, MemPtr, NumParts );

        for k := 0 to NumParts-1 do // draw to Path all Parts of current Item
        begin
          CL.GetPartDCoords( j, k, DC );
          NPoints := Length( DC );

          if Length(WrkCILine) < NPoints then
          begin
            WrkCILine := nil;
            SetLength( WrkCILine, N_NewLength(NPoints) );
          end;

          NPoints := N_ConvDLineToILine2( AffCoefs, NPoints, @DC[0], @WrkCILine[0] );
          Windows.Polyline( HMDC, (@WrkCILine[0])^, NPoints )
        end; // for k := 0 to NumParts-1 do // draw to Path all Parts of current Item

        if not (paplfSinglePath in PALFlags) then // draw each Item as separate Path
        begin
          EndPath( HMDC );
          PrepSymbAttributes();
        end;
      end; // for j := PALBegItemToDraw to PALBegItemToDraw+PALNumItemsToDraw-1 do

      if paplfSinglePath in PALFlags then // draw all Items as a single Path
      begin
        EndPath( HMDC );
        PrepSymbAttributes();
      end;
}

    end; // with TN_PPA2RegPolyFragm(PASP.P())^ do, patPolyLine:

    end; // case PAType of

  end; // with DstOCanv, TmpMarker do

  end; // procedure AddShapeToSymbCoords(); // local

  function PrepPMPoints( ANumPMPoints: integer ): PPoint; // local
  // Prepare place for given number of points in PMPoints array and
  // return pointer to first of it
  begin
    with GCBufs[ALevel].GCBPMarkers[i] do
    begin
      if Length(PMPoints) < PMPFreeInd+ANumPMPoints then
        SetLength( PMPoints, N_NewLength( PMPFreeInd+ANumPMPoints ) );

      Result := @PMPoints[PMPFreeInd];
      Inc( PMPFreeInd, ANumPMPoints );
    end; // with GCBufs[ALevel].GCBPMarkers[i] do
  end; // function PrepPMPoints - local

begin //*********************** main body of TN_GlobCont.PrepareMarkers

  with GCBufs[ALevel], DstOCanv do
  begin

  NumAttr := AContAttr.Alength();

  if Length(GCBPMarkers) < NumAttr then // increase GCBPMarkers length
    SetLength( GCBPMarkers, 3+NumAttr );


  for i := 0 to NumAttr-1 do // along all Attributes (AContAttr elements)
  begin                      // prepare one GCBPMarkers elem for each AContAttr elem

  PCA := TN_PContAttr(AContAttr.P(i)); // pointer to i-th AContAttr element
  SymbInd := 0; // Initial Symbol index (at CurLevel)

  with PCA^ do
  begin

  NumCAMarkers := CAMarkers.ALength();

  if NumCAMarkers = 0 then Continue; // no Markers in i-th element of ContAttr Attributes

  // SinglePath means that only one Symbol for all CAMarkers hould be created
  // with Attributes of first Marker and coords of all CAMarkers

  SinglePath := mafSinglePath in CAMarkerFlags;

  if SinglePath then // one Symbol (with Attributes of first CAMarker) for all CAMarkers
  begin
    if Length(GCBPMarkers[i].PMSymbols) < 1 then // increase PMSymbols length
      SetLength( GCBPMarkers[i].PMSymbols, 4 );

    PCurSymbol := PrepSymbol( i, SymbInd, PCA, TN_PPointAttr2(CAMarkers.P(0)) );
    Inc( SymbInd );
  end else //********** NumCAMarkers Symbols (one Symbol per CAMarkers element)
  begin
    if Length(GCBPMarkers[i].PMSymbols) < NumCAMarkers then // increase PMSymbols length
      SetLength( GCBPMarkers[i].PMSymbols, 3+NumCAMarkers );
  end;

  for j := 0 to NumCAMarkers-1 do // for all markers at i-th element of ContAttr Attributes
  begin
    PMA := TN_PPointAttr2(CAMarkers.P(j));

    if not SinglePath then // one Symbol per each CAMarkers element
    begin
      PCurSymbol := PrepSymbol( i, SymbInd, PCA, PMA );
      Inc( SymbInd );
    end;

    CurStandShape := PMA^.PAShape;
    TmpMarker := PMA^;

    if sshRect in CurStandShape then
    begin
      CreateSpecParamsRArray( patRoundRect );
      AddShapeToSymbCoords();
    end;

    if sshEllipse in CurStandShape then
    begin
      CreateSpecParamsRArray( patEllipseFragm );
      with TN_PPA2EllipseFragm(TmpMarker.PASP.P())^ do
      begin
        PAEBorderType := abtArcOnly;
        PAEArcAngle   := 360;
      end;
      AddShapeToSymbCoords();
    end;

    if sshRomb in CurStandShape then
    begin
      CreateSpecParamsRArray( patRegPolyFragm );
      with TN_PPA2RegPolyFragm(TmpMarker.PASP.P())^ do
      begin
        PAPBorderType  := abtPieSegment;
        PAPBegAngle    := 90;
        PAPNumSegments := 4;
      end;
      AddShapeToSymbCoords();
    end;

    if sshATriangle in CurStandShape then
    begin
      CreateSpecParamsRArray( patRegPolyFragm );
      with TN_PPA2RegPolyFragm(TmpMarker.PASP.P())^ do
      begin
        PAPBorderType  := abtPieSegment;
        PAPBegAngle    := -90;
        PAPNumSegments := 3;
      end;
      AddShapeToSymbCoords();
    end;

    if sshVTriangle in CurStandShape then
    begin
      CreateSpecParamsRArray( patRegPolyFragm );
      with TN_PPA2RegPolyFragm(TmpMarker.PASP.P())^ do
      begin
        PAPBorderType  := abtPieSegment;
        PAPBegAngle    := 90;
        PAPNumSegments := 3;
      end;
      AddShapeToSymbCoords();
    end;

    if sshPlus in CurStandShape then
    begin
      CreateSpecParamsRArray( patStrokeShape );
      with TN_PPA2StrokeShape(TmpMarker.PASP.P())^ do
      begin
        PASSType := sstPlus;
      end;
      AddShapeToSymbCoords();
    end;

    if sshEllMult in CurStandShape then
    begin
      CreateSpecParamsRArray( patStrokeShape );
      with TN_PPA2StrokeShape(TmpMarker.PASP.P())^ do
      begin
        PASSType  := sstPlus;
        PASSAngle := 45;
      end;
      AddShapeToSymbCoords();
    end;

    if sshCornerMult in CurStandShape then
    begin
      CreateSpecParamsRArray( patStrokeShape );
      with TN_PPA2StrokeShape(TmpMarker.PASP.P())^ do
      begin
        PASSType := sstDiagonals;
      end;
      AddShapeToSymbCoords();
    end;

    //*** Coords for all given Standart Shapes are added, add Specific Shape

    TmpMarker.PASP.Free;
    TmpMarker := PMA^;
    AddShapeToSymbCoords();
    TmpMarker.PASP.Free;

  end; // for j := 0 to NumCAMarkers-1 do // for all markers at i-th element of ContAttr Attributes

  with GCBPMarkers[i] do // finish preparing markers for i-th ContAttr element
  begin
    PMNumSymbols := SymbInd;

    //***** Symbols Coords and Attributes are OK,
    //      fill PMPoints array with Point coords, where markers should be drawn

    PMPFreeInd := 0;

    for j := 0 to GCBNumFlatLines-1 do // along all Flat Lines
    with GCBFlatLines[j] do
    begin
      // Add to PMPoints Beg and End Vertexes if needed
      if mafBegLine in PCA^.CAMarkerFlags then PrepPMPoints(1)^ := IPoint( FLCoords[0] );
      if mafEndLine in PCA^.CAMarkerFlags then PrepPMPoints(1)^ := IPoint( FLCoords[FLNumPoints-1] );

      if mafInternalVerts in PCA^.CAMarkerFlags then // All Internal Vertexes
      begin
        PIPoint := PrepPMPoints( FLNumPoints-2 );

        for k := 1 to FLNumPoints-2 do
        begin
          PIPoint^ := IPoint( FLCoords[k] );
          Inc( PIPoint );
        end;

      end; // if mafInternalVerts in PCA^.CAMarkerFlags then  // All Internal Vertexes

      if mafStep in PCA^.CAMarkerFlags then // Step along FlatLine
      if PCA^.CADashSizes.ALength() >= 2 then // a precaution
      begin
        // Use GCBPixDashes[i][0] as offset and GCBPixDashes[i][1] as Marker Step
        Ind := 0;   // current Index in FLCoords and FLLengts
        Delta := 0; // current position in current segment

        // duLengthPrc case is not implemented!!!

        Step := GCBLLWDashes[i][0]*CurLLWPixSize;
        N_StepAlongPolyline( @FLCoords[0], FLLengts, FLNumPoints-1,
                                                           Step, Ind, Delta );
        Step := GCBLLWDashes[i][1]*CurLLWPixSize;
        CurFreeInd := PMPFreeInd;
        PIPoint := PrepPMPoints( Round(FLWholeLength/Step)+2 );

        while True do // add Points along cur FlatLine
        begin
          PIPoint^ := IPoint( N_StepAlongPolyline( @FLCoords[0], FLLengts,
                                           FLNumPoints-1, Step, Ind, Delta ) );
          if Ind = -1 then Break; // end of FlatLine
          Inc( PIPoint );
          Inc( CurFreeInd );
        end;

        PMPFreeInd := CurFreeInd;
      end; // if mafStep in PCA^.CAMarkerFlags then // Step along FlatLine

    end; // for j := 0 to GCBNumFlatLines-1 do // along all Flat Lines

    PMNumPoints := PMPFreeInd;

  end; // with GCBPMarkers[i] do // finish preparing markers for i-th Attributes element

  end; // with PCA^ do
  end; // for i := 0 to NumAttr-1 do // along all Attributes

  end; // GCBufs[ACurLevel], DstOCanv
end; // function TN_GlobCont.PrepareMarkers

//********************************************** TN_GlobCont.WinGDIPolyDraw ***
// Draw given PolyDraw data (Points and Flags) with given Attributes using WinGDI
//
procedure TN_GlobCont.WinGDIPolyDraw( const APoints; const ATypes; ACount: integer;
        APContAttr: TN_PContAttr; APDashSizes: PFloat = nil; ANumDashes: integer = 0 );
begin
  with DstOCanv, APContAttr^ do
  begin
    Windows.BeginPath( HMDC );
    N_PolyDraw( HMDC, APoints, ATypes, ACount );
    Windows.EndPath( HMDC );

    DrawCurPath( CABrushColor, CAPenColor, CAPenWidth, CAPenStyle,
                                                     APDashSizes, ANumDashes );
  end; // with DstOCanv, APContAttr^ do
end; // procedure TN_GlobCont.WinGDIPolyDraw

//*************************************************** TN_GlobCont.DrawShape ***
// Draw given AShapeCoords with all given attributes AContAttr and
// given AShiftSize (all coords are shifted by AShiftSize)
//
procedure TN_GlobCont.DrawShape( AShapeCoords: TN_ShapeCoords; AContAttr: TK_RArray;
                                                    const AShiftSize: TFPoint );
var
  i, j, k, FLInd, FLPInd, NumDashes, NumRestPoints: integer;
  CurLevel, NumAttr, NumMains, NumPathPoints: integer;
  dx, dy, Coef, FSize: float;
  PrepFlatLines, SomeMarkers, PixDashes: boolean;
  PCA: TN_PContAttr;
  PDashSizes: PFloat;
begin
  CurLevel := GCBFreeInd; // CurLevel Buffers

  if High(GCBufs) < CurLevel then
    SetLength( GCBufs, 2+CurLevel );

  with GCBufs[CurLevel], AShapeCoords, DstOCanv do
  begin

  if SCBFreeInd = 0 then Exit; // No Shapes to Draw

  //**************** Analize given AShapeCoords and set:
  //                 PrepFlatLines - FlatLines should be prepared
  //                 SomeMarkers   - Markers are given in some AContAttr elements
  //                 NumMains      - Number of Times to draw Native Path

  NumAttr := AContAttr.ALength();

  PrepFlatLines := False;
  SomeMarkers   := False;
  PixDashes     := False;
  NumMains      := 0;

  if NumAttr = 0 then // draw by default attributes
  begin
    NumMains := 1;
    AContAttr := N_DefContAttr;
    NumAttr := 1;
  end else // analize attributes
  begin
    for i := 0 to NumAttr-1 do // along all Attributes
    with TN_PContAttr(AContAttr.P(i))^ do
    begin
      if not (cafSkipMainPath in CAFlags) then Inc( NumMains ); // Main Path drawing is needed
      if CAMarkers   <> nil then SomeMarkers := True;
      if CADashSizes <> nil then PixDashes := True;
      if (CAMarkers <> nil) or (CADashSizes <> nil) then PrepFlatLines := True;
    end; // with ..., for ...
  end; // else // analize attributes

  if (not SomeMarkers) and (NumMains = 0) then Exit; // nothing to do

  Inc( GCBFreeInd ); // GCBFreeInd will be used in possible nested calls to Self

  //***** variables PrepFlatLines, SomeMarkers, NumMains are set
  //      Prepare coords objects, needed for all AContAttr elements

  if PrepFlatLines then // prepare FlatLines in GCBFlatLines array using WinGDI FlattenPath
  begin
    PrepWinGDIPath( HMDC, AShiftSize ); // Prepare Windows Path for AShapeCoords
    Windows.FlattenPath( HMDC );
    NumPathPoints := N_GetPathCoords( HMDC, GCBFLPoints, GCBFlFlags );

    FLInd  := -1;
    FLPInd := 0;

    for i := 0 to NumPathPoints-1 do // along all points in FlattenPath (GCBFLPoints)
    begin                           // Path may consists of several Flat Lines
      // i is index of a point in FlattenPath (GCBFLPoints)
      // Flat Line Ind (FLInd) and point index in each Flat Line (FLPInd)
      // are updated for each i in this loop

      if GCBFLFlags[i] = PT_MOVETO then // prepare new Flat Line
      begin
        if FLInd = -1 then // first Flat Line
        begin
          FLInd  := 0;
          FLPInd := 0;
        end else // End of Flat Line with FLInd index
        begin
          GCBFlatLines[FLInd].FLNumPoints := FLPInd;
          FLPInd := 0;  // first point of next Flat Line
          Inc( FLInd ); // to next FlatLine
        end;

        if High(GCBFlatLines) < FLInd then // prepare GCBFlatLines array
          SetLength( GCBFlatLines, FLInd+2 );

        NumRestPoints := NumPathPoints - i; // Max possible Flat Line length

        with GCBFlatLines[FLInd] do // prepare Flat Line Points and Lengths arrays
        begin
          if Length(FLCoords) < NumRestPoints then
            SetLength( FLCoords, NumRestPoints );

          if Length(FLLengts) < NumRestPoints then
            SetLength( FLLengts, NumRestPoints );
        end; // with GCBFlatLines[FLInd] do // prepare Flat Line Points and Lengths arrays

        GCBFlatLines[FLInd].FLWholeLength := 0;
      end; // if GCBFLFlags[i] = PT_MOVETO then // prepare new Flat Line

      with GCBFlatLines[FLInd] do
      begin
        FLCoords[FLPInd] := FPoint( GCBFLPoints[i] );

        if FLPInd > 0 then // not first point in Flat Line, calc segm Length
        begin
          dx := FLCoords[FLPInd].X - FLCoords[FLPInd-1].X;
          dy := FLCoords[FLPInd].Y - FLCoords[FLPInd-1].Y;
          FLLengts[FLPInd-1] := sqrt( dx*dx + dy*dy );
          FLWholeLength := FLWholeLength + FLLengts[FLPInd-1];
        end;

      end; // with GCBFlatLines[FLInd] do

      Inc( FLPInd ); // to next point in current Flat Line or to first point in next FlatLine
    end; // for i := 0 to NumPathPoints do // along all points in GCBFLPoints

    if FLInd >= 0 then // GCBFlatLines array is not empty
      GCBFlatLines[FLInd].FLNumPoints := FLPInd; // Set FLNumPoints for last Flat Line

    GCBNumFlatLines := FLInd + 1; // Number of Flat Lines
  end; // if PrepFlatLines then // prepare FlatLines using WinGDI FlattenPath

  if PixDashes then // prepare Dash Sizes in Pixels
  begin             // (one TN_IArray and one TNFArray per each ConAttr)
//    SetLength( GCBIPixDashes, NumAttr );
//    SetLength( GCBFPixDashes, NumAttr );
    SetLength( GCBLLWDashes, NumAttr );

    for i := 0 to NumAttr-1 do // along ContAttr elements
    with TN_PContAttr(AContAttr.P(i))^ do
    begin

      NumDashes := CADashSizes.ALength();
//      SetLength( GCBIPixDashes[i], NumDashes );
//      SetLength( GCBFPixDashes[i], NumDashes );
      SetLength( GCBLLWDashes[i], NumDashes );

      case CADashUnits of
        duLLW:       Coef := 1;
        dumm:        Coef := 72/25.4;
        duPix:       Coef := 1/CurLLWPixSize;
        duPenWidth:  Coef := CAPenWidth;
        duLengthPrc: Coef := 1; // Real sizes in Pixels will be calculated later in PrepareMarkers
      else
        Coef := 1; // not used, just a precaution
      end; // case CADashUnits of
//type TN_DashUnits = ( duLLW, dumm, duPix, duPenWidth, duLengthPrc );

      for j := 0 to NumDashes-1 do
        GCBLLWDashes[i][j] := PFloat(CADashSizes.P(j))^*Coef;

    end; // for i := 0 to NumAttr-1 do // along ContAttr elements
  end; // if PixDashes then

  if SomeMarkers then // prepare Markers in GCBPMarkers array
  begin
    PrepareMarkers( CurLevel, AContAttr );
  end;

  //******* All Target independant work is done

  if DstImageType = ditWinGDI then //************** draw by WinGDI to DstOCanv
  begin

  for i := 0 to NumAttr-1 do // along all Attributes
  begin
  PCA := TN_PContAttr(AContAttr.P(i));
  with PCA^ do
  begin

    PDashSizes := nil;
    NumDashes := 0;

    if PixDashes and not (cafPenStyleDashes in CAFlags) then // use prepared PixDashes
    begin
      NumDashes := Length(GCBLLWDashes[i]);

      if NumDashes > 0 then
        PDashSizes := @GCBLLWDashes[i][0];

    end; // if ... then // use prepared PixDashes

    // Prpare and Draw main Path (same for all Attributes (AContAttr elements))
    PrepWinGDIPath( HMDC, AShiftSize );
    DrawCurPath( CABrushColor, CAPenColor, CAPenWidth, CAPenStyle, PDashSizes, NumDashes );

    if SomeMarkers and (CAMarkers <> nil) then // markers are given, draw them
    with GCBPMarkers[i] do // for i-th Attributes element
    begin
      for j := 0 to PMNumSymbols-1 do // along all Symbols that should be drawn at each of PMPoints for i-th Attributes element
      with PMSymbols[j].SymbCoords do
      begin
        // Draw all Shapes at point (0,0)
        PrepWinGDIPath( HMDC, N_ZFPoint );

        NumPathPoints := N_GetPathCoords( HMDC, GCBSymbZPoints, GCBSymbFlags );

        if NumPathPoints = 0 then // Path is empty or consists of pone point
        begin
          if Length(SCIPoints) = 0 then Continue; // skip Drawing current Symbol
          NumPathPoints := 1;
          GCBSymbZPoints[0] := SCIPoints[0];
          GCBSymbFlags[0] := SCIFlags[0];
        end; // if NumPathPoints = 0 then // Path is empty or consists of pone point

        SetLength( GCBSymbSPoints, Length(GCBSymbZPoints) );

        for k := 0 to PMNumPoints-1 do // along all points where markers should be drawn
        begin
          N_ShiftICoords( @GCBSymbZPoints[0], @GCBSymbSPoints[0], NumPathPoints, PMPoints[k] );


          WinGDIPolyDraw ( GCBSymbSPoints[0], GCBSymbFlags[0], NumPathPoints,
                                     TN_PContAttr(PMSymbols[j].SymbAttr.P(0)) );

        end; // for k := 0 to PMNumPoints-1 do // along all points where markers should be drawn

      end; // for j := 0 to PMNumSymbols-1 do // along all Symbols that should be drawn at PMPoints

    end; // with GCBPMarkers[i] do, if CAMarkers <> nil then // markers are given

  end; // with PCA^ do
  end; // for i := 0 to NumAttr-1 do // along all Attributes

  end else if DstImageType = ditVML then // draw to VML
  begin
//    DrawToVML
  end else if DstImageType = ditSVG then // draw to SVG
  begin
//    DrawToSVG
  end else if DstImageType = ditJS then // draw to JS
  begin
//    DrawToJS
  end else if DstImageType = ditText then // draw to Text (create dump text)
  begin
//    DrawToText
  end;

  end; // with ... do

  Dec( GCBFreeInd );
end; // procedure TN_GlobCont.DrawShape

//******************************************** TN_GlobCont.DrawTextRects ***
// Draw given Text Rects
//
procedure TN_GlobCont.DrawTextRects( APTextRect: TN_PTextRect; ANumTextRects: integer;
                                     APTextBlock: TN_POneTextBlock; ATopLeft: TPoint );
var
  i, NumChars, PixShiftX, PixShiftY: integer;
  SavedTAMode: UINT;
  PTextBlock: TN_POneTextBlock;
  PText: PChar;
//  Str: string;
begin
  PText := nil; // to avoid warning

  with DstOCanv do
  begin

  if DstImageType = ditWinGDI then // draw to OCanv
  begin
    SavedTAMode := Windows.GetTextAlign( HMDC );
//    Windows.SetTextAlign( HMDC, TA_TOP or TA_LEFT );
    Windows.SetTextAlign( HMDC, TA_BASELINE or TA_LEFT );

    for i := 0 to ANumTextRects-1 do // along all given TextRects
    with APTextRect^ do
    begin
      PTextBlock := APTextBlock;
      Inc( PTextBlock, TRTBIndex );
      with PTextBlock^ do
      begin
        if OTBNFont <> nil then
          N_SetNFont( OTBNFont, DstOCanv )
        else
          N_SetUDFont( OTBFont, DstOCanv );

        NumChars := 0;
        case TRType of

        trtToken: begin // One Token from TextBlock PlaintText
          PText := PChar(@OTBMText[1]) + TRCharsOfs;
          NumChars := TRNumChars;
        end;

        trtHyphen: begin
          PText := @N_Bullets[1];
          NumChars := 1;
        end;

        trtBullet: begin
          PText := @N_Bullets[2]; // temporary
          NumChars := 1;
        end;

        end; // case TRType of

        TRRect.Left   := TRBLPos.X   + ATopLeft.X;
        TRRect.Top    := TRBLPos.Y   + ATopLeft.Y;

        TRRect.Right  := TRRect.Left + TRWidth;
        TRRect.Bottom := TRRect.Top  + 10; // temporary

        windows.GetWorldTransform( HMDC, N_XForm );

        if (NumChars >= 1) and (OTBTextColor <> N_EmptyColor) then // Drawing is needed
        begin
          if (OTBBack2Color = N_EmptyColor) or (OTBBack2Width = 0.0) then // usual mode without using Back2 Color
          begin
            SetFontAttribs( OTBTextColor, OTBBackColor );
            Windows.ExtTextOut( HMDC, TRRect.Left, TRRect.Top, 0, nil, PText, NumChars, nil );
          end else // Draw with using Back2 Color
          begin
            PixShiftX := LLWToPix( OTBBack2Shift.X );
            PixShiftY := LLWToPix( OTBBack2Shift.Y );

            if OTBBack2Width = -1.0 then // use second ExtTextOut with OTBBack2Shift
            begin
              SetFontAttribs( OTBBack2Color, N_EmptyColor ); // Aus ExtTextOut
              Windows.ExtTextOut( HMDC, TRRect.Left+PixShiftX, TRRect.Top+PixShiftY, 0, nil, PText, NumChars, nil );

              SetFontAttribs( OTBTextColor, OTBBackColor ); // Main ExtTextOut
              Windows.ExtTextOut( HMDC, TRRect.Left, TRRect.Top, 0, nil, PText, NumChars, nil );
            end else if OTBBack2Width > 0.0 then // outline chars with OTBBack2Color
            begin
              Windows.BeginPath( HMDC );
              Windows.ExtTextOut( HMDC, TRRect.Left+PixShiftX, TRRect.Top+PixShiftY, 0, nil, PText, NumChars, nil );
              Windows.EndPath( HMDC );

              SetPenAttribs( OTBBack2Color, OTBBack2Width );
              Windows.StrokePath( HMDC ); // outline chars

              SetFontAttribs( OTBTextColor, OTBBackColor ); // Main ExtTextOut
              Windows.ExtTextOut( HMDC, TRRect.Left, TRRect.Top, 0, nil, PText, NumChars, nil );
            end else // usual mode without using Back2 Color

          end; // else // Draw with using Back2 Color
        end; // if (NumChars >= 1) and (OTBTextColor <> N_EmptyColor) then // Drawing is needed

      end; // with PTextBlock^ do
      Inc( APTextRect );
    end; // with APTextRect^ do, for i := 0 to ANumTextRects-1 do

    SetFontAttribs( 0, N_EmptyColor, 0, 0 ); // set default values
    Windows.SetTextAlign( HMDC, SavedTAMode ); // restore initial mode
  end else if DstImageType = ditVML then // draw to VML
  begin
//    DrawToVML
  end else if DstImageType = ditSVG then // draw to SVG
  begin
//    DrawToSVG
  end else if DstImageType = ditJS then // draw to JS
  begin
//    DrawToJS
  end else if DstImageType = ditText then // draw to Text (create dump text)
  begin
//    DrawToText
  end;

  end; // with DstOCanv do
end; // procedure TN_GlobCont.DrawTextRects

//******************************************* TN_GlobCont.DrawStraightArrow ***
// Draw Straight Segment or Arrow (one segment with Arrow) as Polygon
//
// SARect.TopLeft - SArrow BegPoint, SARect.BottomRight - SArrow EndPoint
//
// If safJustLine in SAFlags then draw Segment without Arrow using SAAttribs,
// otherwise draw Arrow as closed Polygon (based upon SAWidths, SALengths) using SAAttribs.
// All other CSArrow fields are not used.
//
procedure TN_GlobCont.DrawStraightArrow( APCSArrow: TN_PCSArrow );
var
  P1, P2: TPoint;
  L1, L2, W1, W2: float;

  DX1, DY1: integer;
  DX, DY, Coef, P1P2Size: double;
  P2a: TPoint;
  PixPolygon: TN_IPArray;
  ShapeCoords: TN_ShapeCoords;
begin
  with DstOCanv, APCSArrow^ do
  begin

  if safJustLine in SAFlags then // Draw just Line without Arrow
  begin
    ShapeCoords := TN_ShapeCoords.Create;
    ShapeCoords.AddPixPolyLine( PFPoint(@SARect.TopLeft), 2 );
    DrawShape( ShapeCoords, SAAttribs, N_ZFPoint );
    ShapeCoords.Free;
    Exit;
  end; // if safJustLine in SAFlags then // Draw just Line without Arrow

  // temporary just set old OCanv.DrawPixSArrow params and use old code,
  // later improve

  P1.X := Round(SARect.Left);
  P1.Y := Round(SARect.Top);
  P2.X := Round(SARect.Right);
  P2.Y := Round(SARect.Bottom);

  L1 := SALengths.X; // all in LLW units
  L2 := SALengths.Y;
  W1 := SAWidths.X;
  W2 := SAWidths.Y;

  //*** Old code:

  SetLength( PixPolygon, 8 );
  DX := P2.X-P1.X;
  DY := P2.Y-P1.Y;
  P1P2Size := Sqrt( DX*DX + DY*DY );
  if P1P2Size = 0 then Exit;

  PrepWidthVector( P1, P2, W1, PixPolygon[0], PixPolygon[6] );
  PixPolygon[7] := PixPolygon[0];

  Coef := (P1P2Size - LLWToPix( L1 )) / P1P2Size;
  DX1 := Round(DX*Coef);
  DY1 := Round(DY*Coef);
  PixPolygon[1].X := PixPolygon[0].X + DX1;
  PixPolygon[1].Y := PixPolygon[0].Y + DY1;
  PixPolygon[5].X := PixPolygon[6].X + DX1;
  PixPolygon[5].Y := PixPolygon[6].Y + DY1;

  Coef := (P1P2Size - LLWToPix( L2 )) / P1P2Size;
  P2a.X := P1.X + Round(DX*Coef);
  P2a.Y := P1.Y + Round(DY*Coef);
  PrepWidthVector( P2a, P1, W2, PixPolygon[4], PixPolygon[2] );

  PixPolygon[3] := P2;

  ShapeCoords := TN_ShapeCoords.Create;
  ShapeCoords.AddPixPolyLine( PIPoint(@PixPolygon[0]), 8 );
  DrawShape( ShapeCoords, SAAttribs, N_ZFPoint );
  ShapeCoords.Free;

{ not implemented yet
  if (Flags and $0F) = 1 then // draw circle with P1 as center (Arrow begpoint)
  begin
    PrepWidthVector( P1, Point( P1.X+1, P1.Y ), W1, PixPolygon[0], PixPolygon[1] );
    PrepWidthVector( P1, Point( P1.X, P1.Y+1 ), W1, PixPolygon[2], PixPolygon[3] );
    DrawPixEllipse( Rect( PixPolygon[2].X, PixPolygon[0].Y,
                          PixPolygon[3].X, PixPolygon[1].Y ) );
  end;
}

  end; // with DstOCanv, APCSArrow do
end; // procedure TN_GlobCont.DrawStraightArrow

{
//**************************************************** TN_GlobCont.GSetFont ***
// Set in DstOCanv ANFont with given Base Line Angle in degree
// ANFont - Font to set (is VArray i.e. TK_RArray or TK_UDRArray of TN_NFont)
//
procedure TN_GlobCont.GSetFont( ANFont: TObject; ABLAngle: float );
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

  with DstOCanv, PNFont^ do
  begin

    // temporary always create new font
    // (Windows font handle could not be in Component Dyn Params!!!)

//    NFWin.lfEscapement := Round( 10 * ABLAngle );
//    N_CreateFontHandle( PNFont, CurLFHPixSize );
//    SelectObject( HMDC, NFHandle );
//    Exit;

    if not IsUDRArray then NFHandle := 0;
    NewFontHandle := False;

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

  end; // with DstOCanv, PNFont^ do
end; // procedure TN_GlobCont.GSetFont
}

//*********************************************** TN_GlobCont.GDrawString ***
// Draw given AStr at given ABasePoint with given APStrPos
// using current Font Settings
//
procedure TN_GlobCont.GDrawString( AStr: string; ABasePoint: TFPoint;
                                     APStrPos: TN_PStrPosParams );
var
  NumChars: integer;
  ULShift: TFPoint;
begin
  with DstOCanv do
  begin

  ULShift := CalcULStrPixShift( AStr, APStrPos );
  NumChars := Length( AStr );

  if DstImageType = ditWinGDI then // draw to OCanv
  begin
    if NumChars >= 1 then
      Windows.ExtTextOut( HMDC, Round(ABasePoint.X + ULShift.X),
             Round(ABasePoint.Y + ULShift.Y), 0, nil, @AStr[1], NumChars, nil );

  end else if DstImageType = ditVML then // draw to VML
  begin
//    DrawToVML
  end else if DstImageType = ditSVG then // draw to SVG
  begin
//    DrawToSVG
  end else if DstImageType = ditJS then // draw to JS
  begin
//    DrawToJS
  end else if DstImageType = ditText then // draw to Text (create dump text)
  begin
//    DrawToText
  end;

  end; // with DstOCanv do

end; // procedure TN_GlobCont.GDrawString


    //************************  Old Drawing methods  **********

//****************************************** TN_GlobCont.DrawShape(nativeOld) ***
// Draw Shape (Bezier and Line fragments) in Pixel Coords with given attributes
// Data are given in native Windows format as two arrays
//
procedure TN_GlobCont.DrawShape( APFlags: PByte; APPoints: PPoint; ANumPoints,
       ABrushColor, APenColor: integer; APenWidth: float; APenStyle: integer;
                              ANumDashes: integer; APDashSizes: PFloat );
begin
  if (APenColor = N_EmptyColor) and (ABrushColor = N_EmptyColor) then Exit;
  if ANumPoints <= 1 then Exit; // a precaution

  with DstOCanv do
  begin

  if DstImageType = ditWinGDI then // draw to OCanv
  begin
    BeginPath( HMDC );
    PolyDraw( HMDC, APPoints^, APFlags^, ANumPoints );
    EndPath( HMDC );
    DrawCurPath( ABrushColor, APenColor, APenWidth, APenStyle,
                                                    APDashSizes, ANumDashes );
  end else if DstImageType = ditVML then // draw to VML
  begin
//    DrawToVML
  end else if DstImageType = ditSVG then // draw to SVG
  begin
//    DrawToSVG
  end else if DstImageType = ditJS then // draw to JS
  begin
//    DrawToJS
  end else if DstImageType = ditText then // draw to Text (create dump text)
  begin
//    DrawToText
  end;

  end; // with DstOCanv do
end; // procedure TN_GlobCont.DrawShape(nativeOld)

//****************************************** TN_GlobCont.DrawShape(nativeNew) ***
// Draw Shape (Bezier and Line fragments) in Pixel Coords with given attributes
// Data are given in native Windows format as two arrays
//
procedure TN_GlobCont.DrawShape( APFlags: PByte; APPoints: PPoint;
                                 ANumPoints: integer; AContAttr: TK_RArray );
var
  i, NumAttr: integer;
begin
//  if (APenColor = N_EmptyColor) and (ABrushColor = N_EmptyColor) then Exit;
  if ANumPoints <= 1 then Exit; // a precaution

  NumAttr := AContAttr.ALength();

  with DstOCanv do
  begin

  if DstImageType = ditWinGDI then // draw to OCanv
  begin

  for i := 0 to NumAttr-1 do
  with TN_PContAttr(AContAttr.P(i))^ do
  begin
    BeginPath( HMDC );
      PolyDraw( HMDC, APPoints^, APFlags^, ANumPoints );
    EndPath( HMDC );

    DrawCurPath( CABrushColor, CAPenColor, CAPenWidth, CAPenStyle );


  end; // for i := 0 to NumAttr-1 do

  end else if DstImageType = ditVML then // draw to VML
  begin
//    DrawToVML
  end else if DstImageType = ditSVG then // draw to SVG
  begin
//    DrawToSVG
  end else if DstImageType = ditJS then // draw to JS
  begin
//    DrawToJS
  end else if DstImageType = ditText then // draw to Text (create dump text)
  begin
//    DrawToText
  end;

  end; // with DstOCanv do
end; // procedure TN_GlobCont.DrawShape(nativeNew)

//******************************************** TN_GlobCont.DrawShape(ints) ***
// Draw Shape (Bezier and Line fragments) in Pixel Coords with given attributes
// using Windows native DrawShape
// Data are given as one array of integer, each data element represents by
//          three integers:  Flag ( PT_MOVETO, ...) and X,Y Pixel coords
//
procedure TN_GlobCont.DrawShape( APData: PInteger; ANumInts, ABrushColor,
                    APenColor: integer; APenWidth: float; APenStyle: integer;
                              ANumDashes: integer; APDashSizes: PFloat );
var
  i, NumPoints: integer;
begin
  NumPoints := ANumInts div 3;
  if (APenColor = N_EmptyColor) and (ABrushColor = N_EmptyColor) then Exit;
  if NumPoints <= 1 then Exit; // a precaution

  with DstOCanv do
  begin

  if Length( WrkBytes ) < NumPoints then
    SetLength( WrkBytes, N_NewLength( NumPoints ) );

  if Length( WrkPoints ) < NumPoints then
    SetLength( WrkPoints, N_NewLength( NumPoints ) );

  for i := 0 to NumPoints-1 do
  begin
    WrkBytes[i] := Byte( APData^ ); Inc( APData );
    WrkPoints[i].X := APData^;      Inc( APData );
    WrkPoints[i].Y := APData^;      Inc( APData );
  end;

  DrawShape( @WrkBytes[0], @WrkPoints[0], NumPoints, ABrushColor, APenColor,
                 APenWidth, APenStyle, ANumDashes, APDashSizes );
  end; // with DstOCanv do
end; // procedure TN_GlobCont.DrawShape(ints)

{
//******************************************** TN_GlobCont.DrawShape(ShapeCoordsOld) ***
// Draw Shape (Bezier and Line fragments) in Pixel Coords with given attributes
// using Windows native DrawShape
// Data are given as one array of integer, each data element represents by
//          three integers:  Flag ( PT_MOVETO, ...) and X,Y Pixel coords
//
procedure TN_GlobCont.DrawShape( AShapeCoords: TN_ShapeCoords; ABrushColor,
                  APenColor: integer; APenWidth: float; APenStyle: integer;
                                ANumDashes: integer; APDashSizes: PInteger );
var
  i: integer;
begin
  with AShapeCoords do
  begin

  if (APenColor = N_EmptyColor) and (ABrushColor = N_EmptyColor) then Exit;
  if FreeInd <= 1 then Exit; // a precaution

  with DstOCanv do
  begin

  if Length( WrkPoints ) < FreeInd then
    SetLength( WrkPoints, N_NewLength( FreeInd ) );

  for i := 0 to FreeInd-1 do
  begin
    WrkPoints[i].X := Round(SFC[i].X);
    WrkPoints[i].Y := Round(SFC[i].Y);
  end;

  DrawShape( @SPF[0], @WrkPoints[0], FreeInd, ABrushColor, APenColor,
                 APenWidth, APenStyle, ANumDashes, APDashSizes );
  end; // with AShapeCoords do
  end; // with DstOCanv do
end; // procedure TN_GlobCont.DrawShape(ShapeCoordsOld)
}

//******************************************* TN_GlobCont.DrawFilledPixRect ***
// Fill given APixRect by given AFillColor
//
procedure TN_GlobCont.DrawFilledPixRect( const APixRect: TRect; AFillColor: integer );
begin
  if AFillColor = N_EmptyColor then Exit;

  with DstOCanv do
  begin

  if DstImageType = ditWinGDI then // draw to OCanv
  begin
    SetBrushAttribs( AFillColor );
    DrawPixFilledRect( APixRect );
  end else if DstImageType = ditVML then // draw to VML
  begin
//    DrawToVML
  end else if DstImageType = ditSVG then // draw to SVG
  begin
//    DrawToSVG
  end else if DstImageType = ditJS then // draw to JS
  begin
//    DrawToJS
  end else if DstImageType = ditText then // draw to Text (create dump text)
  begin
//    DrawToText
  end;

  end; // with DstOCanv do
end; // procedure TN_GlobCont.DrawFilledPixRect

//******************************************** TN_GlobCont.DrawIntPolygon ***
// Draw Polygone in Pixel Coords with given attributes
//
procedure TN_GlobCont.DrawIntPolygon( APPoint: PPoint; ANumPoints, ABrushColor,
                    APenColor: integer; APenWidth: float; APenStyle: integer;
                              ANumDashes: integer; APDashSizes: PFloat );
var
  i: integer;
  PLast: PPoint;
begin
  if (APenColor = N_EmptyColor) and (ABrushColor = N_EmptyColor) then Exit;

  with DstOCanv do
  begin

  if Length( WrkBytes ) < ANumPoints then
    SetLength( WrkBytes, N_NewLength( ANumPoints ) );

  WrkBytes[0] := PT_MOVETO;

  for i := 1 to ANumPoints-1 do
    WrkBytes[i] := PT_LINETO;

  PLast := APPoint;
  Inc( PLast, ANumPoints - 1 );
  if N_Same( APPoint^, PLast^ ) then
    WrkBytes[ANumPoints-1] := WrkBytes[ANumPoints-1] or PT_CLOSEFIGURE;

  DrawShape( @WrkBytes[0], APPoint, ANumPoints, ABrushColor, APenColor,
                           APenWidth, APenStyle, ANumDashes, APDashSizes );
  end; // with DstOCanv do
end; // procedure TN_GlobCont.DrawIntPolygon

//******************************************** TN_GlobCont.DrawIntPolyline ***
// Draw Polyline in Pixel Coords with given attributes using DrawIntPolygon method
//
procedure TN_GlobCont.DrawIntPolyline( APPoint: PPoint; ANumPoints, APenColor: integer;
                                    APenWidth: float; APenStyle: integer;
                              ANumDashes: integer; APDashSizes: PFloat );
begin
  DrawIntPolygon( APPoint, ANumPoints, N_EmptyColor, APenColor,
                           APenWidth, APenStyle, ANumDashes, APDashSizes );
end; // procedure TN_GlobCont.DrawIntPolyline

//******************************************** TN_GlobCont.DrawEllipse ***
// Draw Ellipse in Pixel Coords with given attributes
//
procedure TN_GlobCont.DrawEllipse( AEnvRect: TRect;
                            ABrushColor, APenColor: integer; APenWidth: float );
begin
  if (APenColor = N_EmptyColor) and (ABrushColor = N_EmptyColor) then Exit;

  with DstOCanv do
  begin

  if DstImageType = ditWinGDI then // draw to OCanv
  begin
    if ABrushColor <> N_CurColor then
      SetBrushAttribs( ABrushColor );

    if (APenColor <> N_CurColor) or (APenWidth <> N_CurLLWSize ) then
      SetPenAttribs( APenColor, APenWidth );

    with AEnvRect do
      Windows.Ellipse( HMDC, Left, Top, Right, Bottom );
  end else if DstImageType = ditVML then // draw to VML
  begin
//    DrawToVML
  end else if DstImageType = ditSVG then // draw to SVG
  begin
//    DrawToSVG
  end else if DstImageType = ditJS then // draw to JS
  begin
//    DrawToJS
  end else if DstImageType = ditText then // draw to Text (create dump text)
  begin
//    DrawToText
  end;

  end; // with DstOCanv do
end; // procedure TN_GlobCont.DrawEllipse

//******************************************** TN_GlobCont.DrawPixPoint ***
// Draw Point in Pixel coords using PointAttr1 and PointAttr2 (if given)
//
procedure TN_GlobCont.DrawPixPoint( APoint: TPoint; APParams1: TN_PPointAttr1;
                              APParams2: TN_PPointAttr2; ANumParams2: integer );
var
  i, PrevMode, PenStyle, NumLines, NumInts, TextLeng: integer;
  CurParams1: TN_PointAttr1;
  CurParams2: TN_PointAttr2;
  PixLine: Array [0..3] of TDPoint;
  ShapeCoords: TN_ShapeCoords;

  procedure DrawOneShape( APCurParams2: TN_PPointAttr2 ); // local
  var
    j, k, NumParts, NumItems, NPoints: integer;
    CosA, SinA: double;
    PixICenter, PixIRad: TPoint;
    PixFCenter, PixFRad: TFPoint;
    PixIRect: TRect;
    PixFRect: TFRect;
    TextSize: TSize;
    CL: TN_ULines;
    MemPtr: TN_BytesPtr;
    DC: TN_DPArray;
    AffCoefs: TN_AffCoefs4;

    function Rotate( ADPoint: TDPoint ): TPoint; // local in DrawOneShape
    // rotate given DPoint relative to PixFCenter
    var
      DX, DY: double;
    begin
      DX := ADPoint.X - PixFCenter.X;
      DY := ADPoint.Y - PixFCenter.Y;
      Result.X := Round( DX*CosA - DY*SinA + PixFCenter.X );
      Result.Y := Round( DX*SinA + DY*CosA + PixFCenter.Y );
    end; // function Rotate - local in DrawOneShape

    procedure LocalDrawCurPath(); // local in DrawOneShape
    begin
      with DstOCanv, APCurParams2^ do
      begin
        if PABrushColor = N_EmptyColor then
          StrokePath( HMDC )
        else // PABrushColor <> N_EmptyColor
        begin
          if PAPenColor = N_EmptyColor then
            FillPath( HMDC )
          else // PAPenColor <> N_EmptyColor and PABrushColor <> N_EmptyColor
            StrokeAndFillPath( HMDC );
        end; // else // PABrushColor <> N_EmptyColor
      end; // with DstOCanv, APCurParams2^ do
    end; //procedure LocalDrawCurPath  - local in DrawOneShape

  begin //************** body of local procedure DrawOneShape

  with DstOCanv, APCurParams2^, ShapeCoords do
  begin
    if DstImageType = ditWinGDI then // draw to OCanv
    begin
      PrevMode := SetGraphicsMode( HMDC, GM_ADVANCED ); // to prevent excluding lower right side
    end else; // add later code for other targets if needed

    PenStyle := PS_GEOMETRIC;
{
    if pafMinShape in PAFlags then
      PenStyle := PenStyle or PS_ENDCAP_FLAT or PS_JOIN_BEVEL
    else if pafMaxShape in PAFlags then
      PenStyle := PenStyle or PS_ENDCAP_SQUARE or PS_JOIN_MITER;
}
    if PAType = patTextRow then // set PASizeXY by real Text Size
    with TN_PPA2TextRow(PASP.P())^ do
    begin
      N_SetUDFont( PAFont, DstOCanv, PAFSCoef );
      TextLeng := Length( PAText );
      GetTextExtentPoint32( HMDC, @PAText[1], TextLeng, TextSize );
      PASizeXY.X := TextSize.cx / CurLSUPixSize;
      PASizeXY.Y := TextSize.cy / CurLSUPixSize;
    end; // with TN_PPA2TextRow(PASP.P())^ do, if PAType = patTextRow then

    // PixCenter - Sign Center in Pixel Coords
    PixICenter.X := APoint.X + Round( (PAShiftXY.X +
                                PASizeXY.X*(0.5 - PAHotPoint.X)) * CurLSUPixSize );
    PixICenter.Y := APoint.Y + Round( (PAShiftXY.Y +
                                PASizeXY.Y*(0.5 - PAHotPoint.Y)) * CurLSUPixSize );

    // PixRad - Sign Circle Radius in Pixels
    PixIRad.X := max( 1, Round( 0.5*(PASizeXY.X*CurLSUPixSize-1) ) );
    PixIRad.Y := max( 1, Round( 0.5*(PASizeXY.Y*CurLSUPixSize-1) ) );

    // PixRect - Sign Rect (inclusive)
    PixIRect := Rect( PixICenter.X-PixIRad.X, PixICenter.Y-PixIRad.Y,
                      PixICenter.X+PixIRad.X, PixICenter.Y+PixIRad.Y );

    PixFCenter := FPoint( PixICenter );
    PixFRad    := FPoint( PixIRad );
    PixFRect   := FRect( PixIRect );

    case PAType of

    patStrokeShape: // Stroked Shape (straight lines only)
    with TN_PPA2StrokeShape(PASP.P())^ do
    begin

      with PixFRect do
      case PASSType of

      sstMinus: begin // Minus ('-', one horizontal dash)
        NumLines := 1;
        PixLine[0].X := Left;
        PixLine[0].Y := PixFCenter.Y;
        PixLine[1].X := Right;
        PixLine[1].Y := PixFCenter.Y;
      end; // sstMinus: begin // Minus ('-', one horizontal dash)

      sstPlus: begin // Plus ('+', two dashes)
        NumLines := 2;
        PixLine[0].X := Left;
        PixLine[0].Y := PixFCenter.Y;
        PixLine[1].X := Right;
        PixLine[1].Y := PixFCenter.Y;

        PixLine[2].X := PixFCenter.X;
        PixLine[2].Y := Top;
        PixLine[3].X := PixFCenter.X;
        PixLine[3].Y := Bottom;
      end; // sstPlus: begin // Plus ('+', two dashes)

      sstDiagonals: begin // two Diagonals ('x', two dashes, Mult sign)
        NumLines := 2;
        PixLine[0].X := Left;
        PixLine[0].Y := Top;
        PixLine[1].X := Right;
        PixLine[1].Y := Bottom;

        PixLine[2].X := Right;
        PixLine[2].Y := Top;
        PixLine[3].X := Left;
        PixLine[3].Y := Bottom;
      end; // sstDiagonals: begin // two Diagonals ('x', two dashes, Mult sign)

      end; // case PASSType of, with PixRect do

      CosA := Cos( N_PI*PASSAngle/180 );
      SinA := Sin( N_PI*PASSAngle/180 );

      WrkCILine[0] := Rotate( PixLine[0] );
      WrkCILine[1] := Rotate( PixLine[1] );

      DrawIntPolyline( (@WrkCILine[0]), 2, PAPenColor, PAPenWidth, PenStyle );

      if NumLines >= 2 then
      begin
        WrkCILine[2] := Rotate( PixLine[2] );
        WrkCILine[3] := Rotate( PixLine[3] );

        DrawIntPolyline( (@WrkCILine[2]), 2, PAPenColor, PAPenWidth, PenStyle );
      end;

    end; // with TN_PPA2StrokeShape(PASP.P())^ do, patStrokeShape: // Stroked Shape

    patRoundRect: // RoundRect
    with TN_PPA2RoundRect(PASP.P())^ do
    begin
      PixIRad.X := Round( 0.5*PAEllSizeXY.X*CurLSUPixSize );
      PixIRad.Y := Round( 0.5*PAEllSizeXY.Y*CurLSUPixSize );
      DrawPixRoundRect( PixIRect, PixIRad, PABrushColor, PAPenColor, PAPenWidth );
    end; // with TN_PPA2RoundRect(PASP.P())^ do, patRoundRect: // RoundRect

    patEllipseFragm: // Elliptical Arc shape (Arc, Chord or PieSegm)
    with TN_PPA2EllipseFragm(PASP.P())^ do
    begin
      WrkInts := nil;
      NumInts := AddPieFragment( WrkInts, 0, PixICenter.X, PixICenter.Y,
                 PixIRad.X, PixIRad.Y, PAEBegAngle, PAEArcAngle, 0 );
      DrawShape( @WrkInts[0], NumInts, PABrushColor, PAPenColor, PAPenWidth );
    end; // with TN_PPA2EllipseFragm(PASP.P())^ do, patEllipseFragm:

    patRegPolyFragm: // Regular Polygon Arc shape (Arc, Chord or PieSegm)
    with TN_PPA2RegPolyFragm(PASP.P())^ do
    begin
      ShapeCoords.Clear();
      ShapeCoords.AddRegPolyFragm( PixFRect, PAPBorderType,
                                   PAPBegAngle, PAPArcAngle, PAPNumSegments );
///!      DrawShape( ShapeCoords, PABrushColor, PAPenColor, PAPenWidth );
    end; // with TN_PPA2RegPolyFragm(PASP.P())^ do, patRegPolyFragm:

    patTextRow: // Text Row (at any angle), angle not implemented yet!
    with TN_PPA2TextRow(PASP.P())^ do
    begin // Font and Position is already OK
      SetTextColor( HMDC, PAPenColor ); // WinGDI function
      SetTextCharacterExtra( HMDC, Round( PACESpace*CurLSUPixSize ) );
      Windows.ExtTextOut( HMDC, PixIRect.Left, PixIRect.Top, 0, nil, @PAText[1], TextLeng, nil );
    end; // with TN_PPA2TextRow(PASP.P())^ do, pattTextRow: begin // Text Row (at any angle)

    patArrow: // Arrow
    with TN_PPA2Arrow(PASP.P())^ do
    begin
    // not implemented
    end; // with TN_PPA2Arrow(PASP.P())^ do, patArrow: // Arrow

    patPolyLine: // PolyLine
    with TN_PPA2PolyLine(PASP.P())^ do
    if PALCObj.CI = N_ULinesCI then // a precaution
    begin
      CL := TN_ULines(PALCObj);
      DC := nil;

      SetBrushAttribs( PABrushColor );
      SetPenAttribs( PAPenColor, PAPenWidth );

      with AffCoefs do
      begin
        CX := CurLSUPixSize;
        SX := PixFRect.Left;
        CY := CurLSUPixSize;
        SY := PixFRect.Top;
      end;

      if paplfSinglePath in PALFlags then BeginPath( HMDC );

      NumItems := PALNumItemsToDraw;
      if NumItems = 0 then
        NumItems := CL.WNumItems - PALBegItemToDraw;

      for j := PALBegItemToDraw to PALBegItemToDraw+NumItems-1 do
      begin
        if not (paplfSinglePath in PALFlags) then BeginPath( HMDC );

        CL.GetNumParts( j, MemPtr, NumParts );

        for k := 0 to NumParts-1 do // draw to Path all Parts of current Item
        begin
          CL.GetPartDCoords( j, k, DC );
          NPoints := Length( DC );

          if Length(WrkCILine) < NPoints then
          begin
            WrkCILine := nil;
            SetLength( WrkCILine, N_NewLength(NPoints) );
          end;

          NPoints := N_ConvDLineToILine2( AffCoefs, NPoints, @DC[0], @WrkCILine[0] );
          Windows.Polyline( HMDC, (@WrkCILine[0])^, NPoints )
        end; // for k := 0 to NumParts-1 do // draw to Path all Parts of current Item

        if not (paplfSinglePath in PALFlags) then // draw each Item as separate Path
        begin
          EndPath( HMDC );
          LocalDrawCurPath();
        end;
      end; // for j := PALBegItemToDraw to PALBegItemToDraw+PALNumItemsToDraw-1 do

      if paplfSinglePath in PALFlags then // draw all Items as a single Path
      begin
        EndPath( HMDC );
        LocalDrawCurPath();
      end;

    end; // with TN_PPA2RegPolyFragm(PASP.P())^ do, patPolyLine:

    end; // case PAType of

    if DstImageType = ditWinGDI then // draw to OCanv
    begin
      SetGraphicsMode( HMDC, PrevMode ); // restore initial mode
    end else; // add later code for other targets if needed

  end; // with DstOCanv, APCurParams2^ do
  end; // procedure DrawOneShape(); // local

  procedure CreateSpecParamsRArray( ASPType: TN_PointAttr2Type ); // local
  begin
    with CurParams2 do
    begin
      if PASP <> nil then PASP.Free;
      PAType := ASPType;
      PASP := K_RCreateByTypeName( N_PA2SPTypes[integer(PAType)-1], 1, [] );
    end; //
  end; // procedure CreateSpecParamsRArray - local

begin //*********************** main body of TN_GlobCont.DrawPixPoint
  FillChar( CurParams1, SizeOf(CurParams1), 0 );
  FillChar( CurParams2, SizeOf(CurParams2), 0 );
  ShapeCoords := TN_ShapeCoords.Create();

  if APParams1 <> nil then CurParams1 := APParams1^;

  if (APParams2 <> nil) and (ANumParams2 >= 1) then // Params2 are given
  for i := 0 to ANumParams2-1 do // draw all shapes (sign elements)
  begin
    CurParams2 := APParams2^; // initial value

    with CurParams1, CurParams2 do // update CurParams2 by CurParams1 if needed
    begin
      if PABrushColor = N_CurColor   then PABrushColor := SBrushColor;
      if PAPenColor   = N_CurColor   then PAPenColor   := SPenColor;
      if PAPenWidth   = N_CurLLWSize then PAPenWidth   := SPenWidth;
    end; // with CurParams1, CurParams2 do

    DrawOneShape( @CurParams2 );
    Inc( APParams2 ); // to next shape (to next sign element)
  end else // Params2 are not given, create one shape by CurParams1 and draw it
  begin
    with CurParams1, CurParams2 do // set CurParams2 by CurParams1
    begin
      PABrushColor := SBrushColor;
      PAPenColor   := SPenColor;
      PAPenWidth   := SPenWidth;
      PAPenStyle   := SPenStyle;
      PASizeXY     := SSizeXY;
      PAShiftXY    := SShiftXY;
      PAHotPoint   := SHotPoint;

      if PASP <> nil then PASP.Free;

      if sshRect in SShape then
      begin
        CreateSpecParamsRArray( patRoundRect );
        DrawOneShape( @CurParams2 );
      end;

      if sshEllipse in SShape then
      begin
        CreateSpecParamsRArray( patEllipseFragm );
        with TN_PPA2EllipseFragm(PASP.P())^ do
        begin
          PAEBorderType := abtPieSegment;
        end;
        DrawOneShape( @CurParams2 );
      end;

      if sshRomb in SShape then
      begin
        CreateSpecParamsRArray( patRegPolyFragm );
        with TN_PPA2RegPolyFragm(PASP.P())^ do
        begin
          PAPBorderType  := abtPieSegment;
          PAPBegAngle    := 90;
          PAPNumSegments := 4;
        end;
        DrawOneShape( @CurParams2 );
      end;

      if sshATriangle in SShape then
      begin
        CreateSpecParamsRArray( patRegPolyFragm );
        with TN_PPA2RegPolyFragm(PASP.P())^ do
        begin
          PAPBorderType  := abtPieSegment;
          PAPBegAngle    := -90;
          PAPNumSegments := 3;
        end;
        DrawOneShape( @CurParams2 );
      end;

      if sshPlus in SShape then
      begin
        CreateSpecParamsRArray( patStrokeShape );
        with TN_PPA2StrokeShape(PASP.P())^ do
        begin
          PASSType := sstPlus;
        end;
        DrawOneShape( @CurParams2 );
      end;

      if sshEllMult in SShape then
      begin
        CreateSpecParamsRArray( patStrokeShape );
        with TN_PPA2StrokeShape(PASP.P())^ do
        begin
          PASSType  := sstPlus;
          PASSAngle := 45;
        end;
        DrawOneShape( @CurParams2 );
      end;

      if sshCornerMult in SShape then
      begin
        CreateSpecParamsRArray( patStrokeShape );
        with TN_PPA2StrokeShape(PASP.P())^ do
        begin
          PASSType := sstDiagonals;
        end;
        DrawOneShape( @CurParams2 );
      end;

    end; // with CurParams1, CurParams2 do
  end;

  ShapeCoords.Free;
end; // procedure TN_GlobCont.DrawPixPoint

//********************************* TN_GlobCont.DrawUserPoint ***
// Draw Point in User coords using DrawPixPoint method and
// DstOCanv.U2P coefs, PointAttr1 and PointAttr2 (if given)
//
procedure TN_GlobCont.DrawUserPoint( const AUserBP: TDPoint; APParams1: TN_PPointAttr1;
                             APParams2: TN_PPointAttr2; ANumParams2: integer );
begin
  DrawPixPoint( N_AffConvD2IPoint( AUserBP, DstOCanv.U2P ), APParams1,
                                                 APParams2, ANumParams2 );
end; // procedure TN_GlobCont.DrawUserPoint

//***************************************** TN_GlobCont.DrawUserSysPolyline ***
// draw Polyline in User coords showing it's vertexes using given Attribs:
//
procedure TN_GlobCont.DrawUserSysPolyline( PPoints: PDPoint;
                              NumPoints: integer; PAttribs: TN_PSysLineAttr );
var
  i: integer;
  BegSegm: TN_DPArray;
  AEnvRect: TFRect;
  PP: PDPoint;
begin
  with DstOCanv, PAttribs^ do
  begin

  if AtLBSColor <> N_EmptyColor then // draw first half of first segment
  begin
    PP := PPoints;
    SetLength( BegSegm, 2 );
    BegSegm[0] := PP^; Inc(PP);
    BegSegm[1] := PP^;
    BegSegm[1] := DPoint( 0.5*(BegSegm[0].X+BegSegm[1].X),
                          0.5*(BegSegm[0].Y+BegSegm[1].Y) );
    AEnvRect := N_CalcDLineEnvRect( @BegSegm[0], 2 );

    SetPenAttribs( AtLBSColor, AtLBSWidth );
    DrawUserDPoly( AEnvRect, @BegSegm[0], 2 );
    BegSegm := nil;
  end;

  if AtLAV.SPenColor <> N_EmptyColor then // draw all line vertexes
  begin
    PP := PPoints;

    for i := 1 to NumPoints do // draw all Vertexes
    begin
      DrawUserPoint( PP^, @AtLAV );
      Inc(PP);
    end; // for i := 1 to NumPoints do // draw all Vertexes
  end; // if AtLAV.PenColor <> N_EmptyColor then // draw all line vertexes

  if AtLBV.SPenColor <> N_EmptyColor then // draw Beg line vertex
  begin
    DrawUserPoint( PPoints^, @AtLBV );
  end;

  if AtLASColor <> N_EmptyColor then // draw line with normal attributes
  begin
    SetPenAttribs( AtLASColor, AtLASWidth );
    AEnvRect := N_CalcDLineEnvRect( PPoints, NumPoints );
    DrawUserDPoly( AEnvRect, PPoints, NumPoints );
  end;

  end; // with PAttribs^ do
end; //*** end of procedure TN_GlobCont.DrawUserSysPolyline

//******************************************** TN_GlobCont.DrawPixRoundRect ***
// Draw given RoundRect with given attributes
//
procedure TN_GlobCont.DrawPixRoundRect( const APixRect: TRect; APixRadXY: TPoint;
                           ABrushColor, APenColor: integer; APenWidth: Float );
var
//  PixHalfWidth1, PixHalfWidth2: integer;
  VMLRad, PixHalfWidth3: float;
  PixFRect: TFRect;
begin
  with DstOCanv do
  begin

  if (ABrushColor = N_EmptyColor) and
     (APenColor   = N_EmptyColor)     then Exit; // nothing todo

  SetPenAttribs( APenColor, APenWidth );

//  PixHalfWidth1 := (ConPenPixWidth - 1) div 2; // for odd ConPenPixWidth
//  PixHalfWidth2 := (ConPenPixWidth) div 2; // for even ConPenPixWidth Top and Left sides
  PixHalfWidth3 := 0.5*ConPenPixWidth;

//  if APenColor = N_EmptyColor then
//  begin
//    PixHalfWidth1 := -1;
//    PixHalfWidth2 := 0;
//  end;

  PixFRect := FRect( APixRect.Left+PixHalfWidth3, APixRect.Top+PixHalfWidth3,
                     APixRect.Right-PixHalfWidth3, APixRect.Bottom-PixHalfWidth3 );

  if DstImageType = ditWinGDI then // draw to OCanv
  begin
//    SetBrushAttribs( ABrushColor );
//    Windows.RoundRect( HMDC, APixRect.Left+PixHalfWidth2, APixRect.Top+PixHalfWidth2,
//                     APixRect.Right-PixHalfWidth1+ConOnePix, APixRect.Bottom-PixHalfWidth1+ConOnePix,
//                           2*APixRadXY.X, 2*APixRadXY.Y );
//    if CollectInvRects then
//      with APixRect do
//        N_AddOneRect( InvRects, NumInvRects, APixRect );
    DrawPixRoundRect( APixRect, APixRadXY, ABrushColor, APenColor, APenWidth );
  end else if DstImageType = ditVML then // draw to VML
  begin
    if N_RectAspect( APixRect ) > 1 then
      VMLRad := APixRadXY.X / N_RectWidth( APixRect )
    else
      VMLRad := APixRadXY.Y / N_RectHeight( APixRect );

    GCOutSLBuf.AddToken( '<v:roundrect style=' );
    GCOutSLBuf.AddToken( '''' + VMLPos( PixFRect ) + ''' ' );
    GCOutSLBuf.AddToken( Format( ' arcsize="%.1f%s" ', [100*VMLRad, '%'] ) );
//    GCOutSLBuf.AddToken( Format( ' arcsize="%.3f" ', [VMLRad] ) );
    GCOutSLBuf.AddToken( VMLPenBrush( ABrushColor, APenColor, APenWidth ) );
    GCOutSLBuf.AddToken( '/>' );
  end else if DstImageType = ditSVG then // draw to SVG
  begin
//    DrawToSVG
  end else if DstImageType = ditJS then // draw to JS
  begin
//    DrawToJS
  end else if DstImageType = ditText then // draw to Text (create dump text)
  begin
//    DrawToText
  end;

  end; // with DstOCanv do
end; // procedure TN_GlobCont.DrawPixRoundRect


    //************************  Component Interpreter methods  **********


//******************************************** TN_GlobCont.GCShowResponse ***
// Show Response String
//
procedure TN_GlobCont.GCShowResponse( AStr: string );
begin
  if Assigned(GCShowResponseProc) then GCShowResponseProc( Astr );
end; // procedure TN_GlobCont.GCShowResponse

//******************************************** TN_GlobCont.GCSetStrVar ***
// Set GC String Variable with given AVarName by given string AVarContent
//
procedure TN_GlobCont.GCSetStrVar( AVarName: string; AVarContent: string );
begin
  GCStrVars.Values[ AVarName ] := AVarContent;
end; // procedure TN_GlobCont.GCSetStrVar

//****************************************** TN_GlobCont.GCGetStrVar ***
// Return content of GC String Variable with given AVarName
//
function TN_GlobCont.GCGetStrVar( AVarName: string ): string;
begin
  Result := GCStrVars.Values[ AVarName ];
end; // function TN_GlobCont.GCGetStrVar

//********************************************** TN_GlobCont.InitGCByType ***
// Init Self by given Image and Canvas types
// obsolete, now used only in N_ExpCompF
//
procedure TN_GlobCont.InitGCByType( ADstImageType: TN_DstImageType;
                                                    AOCanvType: TN_OCanvType );
begin
  //***** Clear needed variables:
  StopExecFlag  := False;
  GCBFreeInd    := 0;
  GCNewFilesInd := 1;

  DstImageType := ADstImageType;

//  if GCMacroSL = nil then GCMacroSL := TStringList.Create
//                     else GCMacroSL.Clear;

  if GCOutStyleSL = nil then GCOutStyleSL := TStringList.Create
                        else GCOutStyleSL.Clear;

  if GCOutSL = nil then GCOutSL := TStringList.Create
                       else GCOutSL.Clear;

  GCOutSLBuf.Free;
  GCOutSLBuf := TN_SLBuf.Create( GCOutSL );

  if not ((AOCanvType = octNotDef) or (AOCanvType = octRFrameRaster)) then
  begin
    DstOCanv := TN_OCanvas.Create();
    DstOCanv.OCanvType := AOCanvType;

    if AOCanvType = octEMF then
    begin
      DstMetaFile.Free;
      DstMetaFile := TMetaFile.Create;
      N_b := Windows.DeleteDC( DstOCanv.HMDC );
      Assert( N_b, 'Bad DstOCanv.HMDC' );
    end; // if AOCanvType = octEMF then

  end; // if not ((AOCanvType = octNotDef) or (AOCanvType = octRFrameRaster)) then

end; // end_of constructor TN_GlobCont.InitGCByType

//******************************************** TN_GlobCont.SetRootComp ***
// Set GCRootComp by given Component and prepare GCRootComp depending fields
//
procedure TN_GlobCont.SetRootComp( ARootComp: TObject );
begin
  GCRootComp := ARootComp;
  Assert( GCRootComp is TN_UDCompVis, 'Bad VCTreeRoot!' );

  with TN_UDCompVis(GCRootComp) do
  begin
    GVCTSizeType := GetSize( @SrcmmSize, @SrcPixSize );
    GCCurSrcmmSize  := SrcmmSize;
    GCCurSrcPixSize := SrcPixSize;
  end;

end; // procedure TN_GlobCont.SetRootComp

//**************************************************** TN_GlobCont.SetSizes ***
// Set Destination Rect and Sizes in Pix and millimeters,
// correct Src Sizes if needed
//
procedure TN_GlobCont.SetSizes( const ADstPixRect: TRect; const ADstmmSize: TFPoint );
begin
  DstPixRect := ADstPixRect;
  DstPixSize := N_RectSize( DstPixRect );
  DstmmSize  := ADstmmSize;
  GCCurDstPixSize := DstPixSize;

  if DstmmSize.X = 0 then // assume 72 DPI
  begin
    DstmmSize.X := (25.4/72)*DstPixSize.X;
    DstmmSize.Y := (25.4/72)*DstPixSize.Y;
  end;

  if GVCTSizeType = vstNotGiven then
  begin
    SrcmmSize  := DstmmSize;
    SrcPixSize := DstPixSize;

    GCCurSrcmmSize  := SrcmmSize;
    GCCurSrcPixSize := SrcPixSize;
  end;

end; // procedure TN_GlobCont.SetSizes


//************************************* TN_GlobCont.ConvMSToPix(Scalar Int) ***
// Conv given float ASize in given AUnit to int Src Pixels (Mesuared Scalar -> Pix)
// if APFraction <> nil it is used on input and on output
//
function TN_GlobCont.ConvMSToPix( ASize: float; AUnit: TN_MSizeUnit;
                                                APFraction: PFloat ): integer;
var
  FRes: float;
begin
  with DstOCanv do
    case AUnit of
      msuLSU: FRes := CurLSUPixSize * ASize;
      msumm:  FRes := mmPixSize.X * ASize;
      msuPix: FRes := ASize;
      msuPrc: FRes := 0.01 * MSParentPixSize * ASize;
    else
      FRes := 0;
    end; // case AUnit of

  if APFraction = nil then
    Result := Round( FRes )
  else // APFraction is given
  begin
    Result := Round( FRes + APFraction^ );
    APFraction^ := FRes + APFraction^ - Result;
  end;
end; // function TN_GlobCont.ConvMSToPix(Scalar Int)

//****************************************** TN_GlobCont.ConvMSToPix(Point) ***
// Conv given Measured Point Size to Pix Point
// if APFractions <> nil it is used on input and on output
//
function TN_GlobCont.ConvMSToPix( const AMPointSize: TN_MPointSize;
                                        APFractions: PFPoint ): TPoint;
var
  WrkFractions: TFPoint;
  SavedSize: float;
begin
  if APFractions <> nil then WrkFractions := APFractions^
                        else FillChar( WrkFractions, Sizeof(WrkFractions), 0 );

  with AMPointSize, Result do
  begin
    SavedSize := MSParentPixSize;

    if MSParentPixXYSize.X <> 0 then MSParentPixSize := MSParentPixXYSize.X;
    X := ConvMSToPix( MSPValue.X, MSXUnit, @WrkFractions.X );

    if MSParentPixXYSize.Y <> 0 then MSParentPixSize := MSParentPixXYSize.Y;
    Y := ConvMSToPix( MSPValue.Y, MSYUnit, @WrkFractions.Y );

    MSParentPixSize := SavedSize;
  end;

  if APFractions <> nil then APFractions^ := WrkFractions;

end; // function TN_GlobCont.ConvMSToPix(Point)

//******************************************* TN_GlobCont.ConvMSToPix(Rect) ***
// Conv given Measured Rect Size to Pix Rect
// if APFractions <> nil it is used on input and on output
//
function TN_GlobCont.ConvMSToPix( const AMRectSize: TN_MRectSize;
                                        APFractions: PFRect ): TRect;
var
  WrkFractions: TFRect;
begin
  if APFractions <> nil then WrkFractions := APFractions^
                        else FillChar( WrkFractions, Sizeof(WrkFractions), 0 );

  with AMRectSize, Result do
  begin
    Left   := ConvMSToPix( MSRValue.Left,   MSLeftUnit,   @WrkFractions.Left );
    Top    := ConvMSToPix( MSRValue.Top,    MSTopUnit,    @WrkFractions.Top );
    Right  := ConvMSToPix( MSRValue.Right,  MSRightUnit,  @WrkFractions.Right );
    Bottom := ConvMSToPix( MSRValue.Bottom, MSBottomUnit, @WrkFractions.Bottom );
  end;

  if APFractions <> nil then APFractions^ := WrkFractions;

end; // function TN_GlobCont.ConvMSToPix(Rect)

//**************************************** TN_GlobCont.ConvMSToFPix(Scalar Float) ***
// Conv given float ASize in given AUnit to Float Pixels (Mesuared Scalar -> Pix)
//
function TN_GlobCont.ConvMSToFPix( ASize: float; AUnit: TN_MSizeUnit;
                                               AFullPixSize: Float = 0 ): float;
begin
  with DstOCanv do
    case AUnit of
      msuLSU: Result := CurLSUPixSize * ASize;
      msumm:  Result := mmPixSize.X * ASize;
      msuPix: Result := ASize;
      msuPrc: Result := 0.01 * AFullPixSize * ASize;
    else
      Result := 0;
    end; // case AUnit of
end; // function TN_GlobCont.ConvMSToFPix(Scalar Float)

//****************************************** TN_GlobCont.ConvMSToFPix(FPoint) ***
// Conv given Measured Point Size to Pix Point
// if APFractions <> nil it is used on input and on output
//
function TN_GlobCont.ConvMSToFPix( const AMPointSize: TN_MPointSize;
                                                AFullSize: TFPoint ): TFPoint;
begin
  with AMPointSize, Result do
  begin
    X := ConvMSToFPix( MSPValue.X, MSXUnit, AFullSize.X );
    Y := ConvMSToFPix( MSPValue.Y, MSYUnit, AFullSize.Y );
  end;
end; // function TN_GlobCont.ConvMSToFPix(FPoint)

//******************************* TN_GlobCont.ConvMSToDblPix(Scalar Double) ***
// Conv given float ASize in given AUnit to Double Pixels (Mesuared Scalar -> Pix)
//
function TN_GlobCont.ConvMSToDblPix( ASize: float; AUnit: TN_MSizeUnit ): double;
begin
  with DstOCanv do
  begin
    case AUnit of
      msuLSU: Result := CurLSUPixSize * ASize;
      msumm:  Result := mmPixSize.X * ASize;
      msuPix: Result := ASize;
      msuPrc: Result := 0.01 * MSParentPixSize * ASize;
    else
      Result := 0;
    end; // case AUnit of
  end; // with DstOCanv do
end; // function TN_GlobCont.ConvMSToDblPix(Scalar Double)

//***************************************** TN_GlobCont.ConvMSToLSU(Scalar) ***
// Conv given float ASize in given AUnit to float LSU (Mesuared Scalar -> LSU)
//
// ASize  - given value in some AUnit: TN_MSizeUnit;
// AUnit  - Units in which ASize is given
// AFullSizeLSU - given full size, used only if AUnit = msuPrc
//
function TN_GlobCont.ConvMSToLSU( ASize: float; AUnit: TN_MSizeUnit;
                                                AFullSizeLSU: float = 0 ): float;
begin
  with DstOCanv do
    case AUnit of
      msuLSU: Result := ASize;
      msumm:  Result := ASize * mmPixSize.X / CurLSUPixSize;
      msuPix: Result := ASize / CurLSUPixSize;
      msuPrc: Result := 0.01 * AFullSizeLSU * ASize;
    else
      Result := 0;
    end; // case AUnit of
end; // function TN_GlobCont.ConvMSToLSU(Scalar)

//****************************************** TN_GlobCont.ConvMSToLSU(FPoint) ***
// Conv given Measured Point Size to LSU FPoint, using scalar variant ConvMSToLSU
//
function TN_GlobCont.ConvMSToLSU( const AMPointSize: TN_MPointSize;
                                  APFullPSizeLSU: PFPoint = nil ): TFPoint;
var
  TmpFPoint: TFPoint;
begin
  if APFullPSizeLSU = nil then
    TmpFPoint := N_ZFPoint
  else // APFullPSizeLSU is given
    TmpFPoint := APFullPSizeLSU^;

  with AMPointSize, Result do
  begin
    X := ConvMSToLSU( MSPValue.X, MSXUnit, TmpFPoint.X );
    Y := ConvMSToLSU( MSPValue.Y, MSYUnit, TmpFPoint.Y );
  end;
end; // function TN_GlobCont.ConvMSToLSU(FPoint)

//********************************************** TN_GlobCont.CalcODFSCoords ***
// Calculate Elements coords using ODFS layout
// ( ODFS layout means One Dimensional Fixed Elements Size layout )
//
// ANumElems    - Number of Elements to layout
// AFullPixSize - Full Scope Size in Pixel, where to layout Elements
// APODFSParams - Pointer to ODFS layout Params
// ACoords      - Resulting Beg and End Elements Pixel (integer) Coords
//                (ACoords is increased if needed and may have Length > ANumElems)
//
procedure TN_GlobCont.CalcODFSCoords( ANumElems, AFullPixSize: integer;
                        APODFSParams: TN_PODFSParams; var ACoords: TN_IPArray );
var
  i, LeftPix, RightPix, AllElemsSize, AlignOfs, FreeSize: integer;
  ElemFraction, GapFraction, ElemPix, GapPix: float;
begin
  if ANumElems <= 0 then Exit;

  with APODFSParams^ do
  begin
    MSParentPixSize := AFullPixSize; // used in Self.ConvMSToPix method

    with ODFLRPaddings do
    begin
      LeftPix  := ConvMSToPix( MSPValue.X, MSXUnit );
      RightPix := ConvMSToPix( MSPValue.Y, MSYUnit );
    end; // with ODFLRPaddings do

    AllElemsSize := AFullPixSize - LeftPix - RightPix;
    //*** AllElemsSize = ElemSize*ANumElems + GapSize*(ANumElems-1)

    with ODFElemSize do // check if ElemSize field is 0 or not
    begin

      if MSSValue = 0 then // ElemSize is not given and should be calculated by uniform layout
      begin
        if ODFGapSize.MSUnit = msuPrc then // Relative Gap size (percents of ElemSize)
        begin
          //*** GapSize = ElemSize*0.01*ODFGapSize.MSSValue (MSSValue is in %)
          //*** AllElemsSize = ElemSize*( ANumElems + 0.01*ODFGapSize.MSSValue*(ANumElems-1) )

          ElemPix := AllElemsSize / (ANumElems + (ANumElems-1)*0.01*ODFGapSize.MSSValue);
          GapPix  := ElemPix*0.01*ODFGapSize.MSSValue;
        end else //************************** Abs Gap size
        begin
          GapPix := ConvMSToDblPix( ODFGapSize.MSSValue, ODFGapSize.MSUnit );
          ElemPix := (AllElemsSize - (ANumElems-1)*GapPix) / ANumElems;
        end;
      end else //************ ElemSize is given (<>0), conv it to Pixels
      begin
        ElemPix := ConvMSToDblPix( MSSValue, MSUnit );

        if ODFGapSize.MSUnit = msuPrc then // calc ESPGapPix by ESPElemPix
          GapPix := ElemPix * 0.01 * ODFGapSize.MSSValue
        else
          GapPix := ConvMSToDblPix( ODFGapSize.MSSValue, ODFGapSize.MSUnit );

      end; // end else // absolute ElemSize is given, conv it to Pixels

    end; // with ODFElemSize do

    if odffEqualSizes in ODFFLags then // Round ElemPix and GapPix
    begin
      ElemFraction := ElemPix - Floor( ElemPix );
      ElemPix := Floor( ElemPix );

      GapFraction  := GapPix - Floor( GapPix );
      GapPix := Floor( GapPix );

      if (ElemFraction + GapFraction) >= 1 then ElemPix := ElemPix + 1;

      if ElemPix = 0 then ElemPix := 1; // a precaution
    end; // if odffEqualSizes then // Round ElemPix and GapPix

    AlignOfs := 0;
    if odffAlignCenter in ODFFLags then // Center Elems
    begin
      FreeSize := AllElemsSize - Round(ANumElems*(ElemPix + GapPix));
      if FreeSize > 0 then
        AlignOfs := Round( 0.5*FreeSize );
    end;

  end; // with APODFSParams^ do

  if Length(ACoords) < ANumElems then
    SetLength( ACoords, N_NewLength( ANumElems ) );

  for i := 0 to ANumElems-1 do // Calc all Elems Coords
  begin
    ACoords[i].X := AlignOfs + Round( LeftPix + i*(ElemPix + GapPix) );
    ACoords[i].Y := Round( ACoords[i].X + ElemPix - 1 );
  end; // for i := 0 to ANumElems-1 do // Calc all Elems Coords

end; // procedure TN_GlobCont.CalcODFSCoords

{
//*********************************************  TN_GlobCont.SaveCoords  ******
// Save OCanv Coords relative fields in SavedCoords record
//
procedure TN_GlobCont.SaveCoords( out SavedCoords: TN_OCanvCoords );
begin
  with DstOcanv, SavedCoords do
  begin
    SavedU2P  := U2P;
    SavedP2U  := P2U;
    SavedU2P6 := U2P6;
    SavedP2U6 := P2U6;
    SavedP2PWin := P2PWin;
    SavedMaxUClipRect := MaxUClipRect;
    SavedMinUClipRect := MinUClipRect;
    SavedPClipRect    := PClipRect;
    SavedUserAspect   := OCUserAspect;
    SavedUseAffCoefs6 := UseAffCoefs6;
    SavedUseP2PWin    := UseP2PWin;
  end; // with DstOcanv, SavedCoords do
end; // procedure TN_GlobCont.SaveCoords

//******************************************  TN_GlobCont.RestoreCoords  ******
// Restore OCanv Coords relative fields by given SavedCoords record
//
procedure TN_GlobCont.RestoreCoords( const SavedCoords: TN_OCanvCoords );
begin
  with DstOcanv, SavedCoords do
  begin
    U2P := SavedU2P;
    P2U := SavedP2U;

    U2P6 := SavedU2P6;
    P2U6 := SavedP2U6;

    P2PWin := SavedP2PWin;

    OCUserAspect := SavedUserAspect;
    UseAffCoefs6 := SavedUseAffCoefs6;
    UseP2PWin    := SavedUseP2PWin;

    if UseP2PWin then
      SetWorldTransform( HMDC, P2PWin );

    MaxUClipRect := SavedMaxUClipRect;
    MinUClipRect := SavedMinUClipRect;
    SetPClipRect( SavedPClipRect ); // P2PWin should be already OK if neded
  end; // with DstOcanv, SavedCoords do
end; // procedure TN_GlobCont.RestoreCoords
}

//************************************************ TN_GlobCont.DrawRootComp ***
// Draw GCRootComp after All Self fields are prepared
//
procedure TN_GlobCont.DrawRootComp( const AVisPixRect: TRect );
begin
  if not (GCRootComp is TN_UDCompVis) then Exit; // a precaution

  with TN_UDCompVis(GCRootComp) do
  begin
    NGCont := Self;
    NGCont.GCCoordsMode := True;  // temp
    NGCont.GCTextMode   := False; // temp
    CompOuterPixRect    := DstPixRect;
    DstOCanv.CurCRect   := AVisPixRect;
    DstOCanv.ConPenLLWWidth := -1;

    InitSubTree( [] );
    CRTFlags := [crtfRootComp];  // Self is Root Component flag

    ExecSubTree();

    FinSubTree();
  end; // with TN_UDCompVis(GCRootComp) do
end; // procedure TN_GlobCont.DrawRootComp

//*********************************************** TN_GlobCont.AddPtrToMText ***
// Add to GCMacroPtrs array one Pointer to given string
//
procedure TN_GlobCont.AddPtrToMText( var AMText: string );
begin
  if AMText <> '' then // skip empty strings
  begin
    if Length(GCMacroPtrs) < (GCMPtrsNum+1) then
      SetLength( GCMacroPtrs, N_NewLength( GCMPtrsNum+1 ) );

    GCMacroPtrs[GCMPtrsNum] := @AMText;
    Inc( GCMPtrsNum );

  end; // if AMText <> '' then // skip empty strings
end; // procedure TN_GlobCont.AddPtrToMText

//**************************************** TN_GlobCont.AddTextBlocksMPtrs ***
// Add to GCMacroPtrs array Pointers to OTBMText elements
//
procedure TN_GlobCont.AddTextBlocksMPtrs( ATextBlocks: TK_RArray );
var
  i: integer;
begin
  if ATextBlocks = nil then Exit; // a precaution

  for i := 0 to ATextBlocks.ALength()-1 do
  with TN_POneTextBlock(ATextBlocks.P(i))^ do
  begin
    if OTBMText <> '' then
      AddPtrToMText( OTBMText );
  end; // with ... do, for i := 0 to ATextBlocks.ALength()-1 do
end; // procedure TN_GlobCont.AddTextBlocksMPtrs

//******************************************  TN_GlobCont.TextBlocksToHTML  ***
// Convert given ATextBlocks to HTML and add it to GCOutSL
//
procedure TN_GlobCont.TextBlocksToHTML( ATextBlocks: TK_RArray );
var
  i: integer;
  Str, FName: string;
  SL: TStringList;
begin
  if ATextBlocks = nil then Exit; // a precaution

  for i := 0 to ATextBlocks.ALength()-1 do
  with TN_POneTextBlock(ATextBlocks.P(i))^ do
  begin

  if OTBFName <> '' then FName := K_ExpandFileName( OTBFName );

  case OTBType of

  tbtText: // Text (HTML, SVG, ...) fragment in OTBMText
  begin
    // Add later Font, Position and Color processing
    GCOutSL.Add( OTBMText );
  end; // tbtText: // Text (HTML, SVG, ...) fragment in OTBMText

  tbtTextComp: // External Text Component in OTBComp (add Text to Cell)
  begin
    if not (OTBComp is TN_UDCompBase) then Continue; // a precaution

//    TN_UDCompBase(OTBComp).ExecRootSubTree( Self, [] );
    ExecuteComp( OTBComp, [] );
  end; // tbtTextComp: // External Text Component in OTBComp (add Text to Cell)

  tbtVisComp: // External Visual Component in OTBComp (create Pict File and add <img> Tag)
  begin
    if not (OTBComp is TN_UDCompVis) then Continue; // a precaution

    TN_UDCompBase(OTBComp).ExpImageTag( OTBMText, Self ); // use OTBMText as <img> tag attributes 
  end; // tbtVisComp: // External Visual Component in OTBComp

  tbtPictFile: // Picture File with OTBFName (add <img> Tag)
  begin
    if OTBMText = '' then Str := '>' // OTBMText may contain additional attributes
                     else Str := ' ' + OTBMText + '>';

    Str := '<img src=' + ExtractRelativePath( GCMainFileName, FName) + Str;
    GCOutSL.Add( Str );
  end; // tbtPictFile: // Picture File with OTBFName (add <img> Tag)

  tbtTextFile: // Include Content of Text (HTML, SVG, ...) File with OTBFName
  begin
    SL := TStringList.Create();
    SL.LoadFromFile( FName );
    GCOutSL.AddStrings( SL );
    SL.Free;
  end; // tbtTextFile: // Include Text (HTML, SVG, ...) File with OTBFName

  end; // case OTBType of

  end; // with ... do, for i := 0 to ATextBlocks.ALength()-1 do
end; // procedure TN_GlobCont.TextBlocksToHTML

    //*********************************  Word related methods  **********

var N_CloseWordModes: array [0..3] of string = ( ' Save all Documents ',
         ' Cancel all Documents ', 'Close Word manually', 'Abort Using Word' );

//*********************************************** TN_GlobCont.DefWordServer ***
// Define GCWordServer (if not yet), add Word Templates, load Word Macro Names
//
procedure TN_GlobCont.DefWordServer();
var
  i, NumDocs: integer;
  Str, FName, TmpFName, DocName: string;
  SL: TStringList;
  WFVFile: TK_VFile;
  ParamsForm: TN_EditParamsForm;
begin
  if not VarIsEmpty( GCWordServer ) then Exit; // GCWordServer is already OK
  N_MEGlobObj.MemIniToVBAParams(); // Copy VBA Params from N_MemIni to N_MEGlobObj

  GCWordServer := N_GetOLEServer( N_MEGlobObj.MEWordServerName, @GCWSWasCreated );
  GCWSWasVisible := GCWordServer.Visible; // save initial state of Visible property

  //***** Get Word Server Version

  Str := GCWordServer.Build;
  Str := Copy( Str, 1, Pos( '.', Str )-1 );
  GCWSMajorVersion := StrToInt( Str );
  GCProperWordIsAbsent := False;


  //***** Check if GCWordServer is invisible (this may occure after previous errors)

  if (not GCWSWasCreated) and (not GCWSWasVisible) then // Quit GCWordServer and create again
  begin
    GCWordServer.Visible := True; // to enable view Word warnings and close all Docs manually

    ParamsForm := N_CreateEditParamsForm( 300 );
    with ParamsForm do
    begin
      Caption := 'Closing current copy of Word';
      AddFixComboBox( 'Close Mode:', N_CloseWordModes, 0 );

      ShowSelfModal();

      if (ModalResult <> mrOK) or       // Closing Mode was not choosen or
         (EPControls[0].CRInt = 3) then // Abort Mode was choosen
      begin
        GCWordServer := Unassigned();
        Application.ProcessMessages(); // a precaution
        GCProperWordIsAbsent := True;  // should be checked in caller
//        Release; // Free ParamsForm
        Exit;
      end; // Abort Using Word (Abort current session of creating new document)

      if EPControls[0].CRInt <= 1 then // Close all Docs programmatically without saving
      begin
        NumDocs := GCWordServer.Documents.Count;

        for i := NumDocs downto 1 do
        begin
          if EPControls[0].CRInt = 1 then // Cancel all Docs
            GCWordServer.Documents.Item(i).Saved := True;

          GCWordServer.Documents.Item(i).Close;
        end; // for i := NumDocs downto 1 do
      end; // if EPControls[0].CRInt <= 1 then // Close all Docs programmatically

//      Release; // Free ParamsForm
    end; // with ParamsForm do

    GCWordServer.Quit;
    GCWordServer := Unassigned();
    Application.ProcessMessages(); // a precaution

    //*** Some dialog is needed, because closing Word may took several seconds
    N_WarnByMessage( 'New copy of Word would be created' );

    GCWordServer := N_GetOLEServer( N_MEGlobObj.MEWordServerName, @GCWSWasCreated ); // Create again
  end; // if ... then // Quit GCWordServer and create again


  //***** Check if current Word Version is suitable

  if GCWSMajorVersion < N_MEGlobObj.MEWordMinVersion then
  begin
    if GCWSWasCreated then // GCWordServer was just created, Quit it
    begin
      GCWordServer.Quit;
      GCWordServer := Unassigned();
    end; // if GCWSWasCreated then // GCWordServer was just created, Quit it

    GCProperWordIsAbsent := True; // should be checked in caller
    Exit;
  end; // Check if current Word Version is suitable

  GCWordServer.Visible := mewfWordVisible in N_MEGlobObj.MEWordFlags; // Set Visible mode if needed (for debug)


  //***** Prepare GCWSTmpDir and GCWSOutDir if needed

  GCWSTmpDir := K_ExpandFIleName( '(#TmpFiles#)' );
  if not K_ForceDirPathDlg( GCWSTmpDir ) then
  begin
    GCProperWordIsAbsent := True; // should be checked in caller
    Exit;
  end; // GCWSTmpDir is absent

  GCWSOutDir := K_ExpandFileName( '(#OutFiles#)' );
  if not K_ForceDirPathDlg( GCWSOutDir ) then
  begin
    GCProperWordIsAbsent := True; // should be checked in caller
    Exit;
  end; // GCWSOutDir is absent


  //***** Fill GCWSDocNames by Documents full file Names
  //      (by Documents, that were opened before GCWordServer was created)

  NumDocs := GCWordServer.Documents.Count;
  GCWSDocNames.Clear;

  for i := 1 to NumDocs do // along all opened Documents
  begin
    DocName := GCWordServer.Documents.Item(i).FullName;

    with GCWSDocNames do
      Objects[ Add( DocName ) ] := TObject(1); // Add Name and set "was opened before" flag
  end; // for i := 1 to NumDocs do // along all opened Documents


  GCWSVBAFlags := N_MEGlobObj.MEWordFlags;

  if not (mewfUseVBA in GCWSVBAFlags) then // "No VBA" mode
  begin
    //    N_IAdd( GetWSInfo( 2, 'DefWordServer 2' ) ); // debug

    //***** in "No VBA" mode - all is done
    Exit;
  end;

  //***** Here: VBA should be used
  //
  //      Add Global Templates - Macros Libraries in *.dot files,
  //      listed in [WordTemplates] Section in Ini file

  SL := TStringList.Create();
  N_ReadMemIniSection( 'WordTemplates', SL );
//  N_IAdd( GetWSInfo( 2, 'DefWordServer 1' ) ); // debug

  for i := 0 to SL.Count-1 do // along all strings in [WordTemplates] section
  begin
    FName := K_ExpandFileName( SL.ValueFromIndex[i] );

    //***** Check if FName is Virtual file and real file should be created in (#TmpFiles#) Dir
    K_VFAssignByPath( WFVFile, FName );
    if WFVFile.VFType <> K_vftDFile then // FName is Virtual file
    begin
      TmpFName := K_ExpandFIleName( '(#TmpFiles#)' + ExtractFileName(FName) );
      K_VFCopyFile( FName, TmpFName, K_DFCreatePlain ); // copy FName -> TmpFName
      FName := TmpFName;
    end;

    GCWordServer.AddIns.Add( FName );
  end; // for i := 0 to SL.Count-1 do // along all strings in [WordTemplates] section

  GCMSWordMacros := TStringList.Create; // MS Word  Macros Names (DelphiName=WordName)
  N_ReadMemIniSection( 'WordMacros', GCMSWordMacros );
  GCMSWordMacros.Sort;


  //***** GCMSWordMacros are OK, Initialize VBA and check if Win32 API works in VBA

  //***** Initialize VBA

  RunWordMacro( 'N_InitVBA1' ); // first macro, it can be aborted in some Word versions because of using WinAPI
  GCWSPSDoc := GCWordServer.ActiveDocument; // was set in InitVBA1 macro

  Str := GCWSPSDoc.Content.Text;
  if Pos( 'APIOK', Str ) <> 1 then // Win32 API in VBA Failed ( InitVBA1 macro was aborted)
    GCWSVBAFlags := GCWSVBAFlags - [mewfUseWin32API];

  RunWordMacro( 'N_InitVBA2' ); // second macro, it should finish initialization
{
  Str := GCWSPSDoc.Content.Text; // Opened full file names, delimeted by %%

  GCWSDocNames.Clear;
  N_SplitSubStrings( Str, '%%', GCWSDocNames );

  for i := 0 to GCWSDocNames.Count-1 do // along all opened Documents
    GCWSDocNames.Objects[i] := TObject(1); // set "was opened before" flag
}

//  Str := GetWordParamsStr();  // 'APIOK' or 'APIFailed' was set in 'InitVBA1' and 'InitVBA2' Macros
//  if Str <> 'APIOK' then // Win32 API in VBA Failed
//    GCWSVBAFlags := GCWSVBAFlags - [mewfUseWin32API];

  //***** Set N_Win32APIOK, N_ParamsStrFName and N_ProtocolFName VBA Glob Vars

//  if mewfUseWin32API in GCWSVBAFlags then Str := '1'
//                                     else Str := '0';
// 'N_Win32APIOK%%' + Str +

  Str :=   'N_ParamsStrFName%%' + GCWSTmpDir + N_GCWSParamsStrFName +
         '%%N_ProtocolFName%%'  + GCWSOutDir + 'Protocol.txt' +
         '%%N_DelphiProcId%%'   + IntToStr(GetCurrentProcessId()) +
         '%%N_DelphiMemAdr%%'   + IntToStr(Integer(@N_DelphiMem[0]));

  GCWSPSMode := psmPSDocText; // this Mode is set temporary only for one next call to SetWordParamsStr
  SetWordParamsStr( Str );
  RunWordMacro( 'N_SetGlobVars' );

  SetWordPSMode( N_MEGlobObj.MEWordPSMode ); // set any new PSMode, given by User
//  N_IAdd( GetWSInfo( 2, 'DefWordServer 3' ) ); // debug
end; // procedure TN_GlobCont.DefWordServer

//*************************************************** TN_GlobCont.GetWSInfo ***
// Get Info about current Word Server:
// Return N_InfoSL (global object) with Info strings
// if AHeader <> '', add it as first string
// AMode - what Info to collect:
//   =0 - only one short string with Version and flags
//   =1 - all variables and modes
//   =2 - same as =1 + all Doc and AddIn Names
//
function TN_GlobCont.GetWSInfo( AMode: integer; AHeader: string ): TStringList;
var
  i, NumDocs, NumAddins: integer;
  Str: string;
begin
  N_InfoSL.Clear;
  Result := N_InfoSL;
  if VarIsEmpty( GCWordServer ) then
  begin
    N_InfoSL.Add( 'GCWordServer is not defined!' );
    Exit;
  end;

  if AMode = 0 then // one short string with Version and flags
  begin
    Str := Format( 'Ver:%s, Fl:%d%d', [GCWordServer.Application.Build,
                              integer(GCWSPSMode), TN_PByte(@GCWSVBAFlags)^ ] );
    N_InfoSL.Add( Str );
    Exit; // all done
  end; // if AMode = 0 then // one short string with Version and flags

  NumDocs := GCWordServer.Documents.Count;
  NumAddins := GCWordServer.AddIns.Count;

  //***** here: Amode >= 1 get Info about all variables and modes

  with N_InfoSL do
  begin
    if AHeader <> '' then Add( AHeader );

    Str := 'Word ' + GCWordServer.Application.Build;
    Str := Format( '%s, NDocs=%d, NAddIns=%d', [Str,NumDocs,NumAddins] );
    Add( Str );

    if mewfUseVBA in GCWSVBAFlags then
    begin
      if mewfUseWin32API in GCWSVBAFlags then
        Str := 'VBA and Win32API Used'
      else
        Str := 'VBA is Used, Win32API NOT';
    end else
      Str := 'VBA NOT Used';

    if integer(GCWSPSMode) >= 7 then
      N_i := 1;

    Str := Str + ', PSM:' + N_PSModeNames[integer(GCWSPSMode)];
    Str := Str + Format( ', WasVisible:%d, WasCreated:%d',
                           [integer(GCWSWasVisible),integer(GCWSWasCreated)] );
    Add( Str );

    if AMode = 2 then // add all Doc and AddIn Names
    begin
      Str := 'Docs: ';
      for i := 1 to NumDocs do
      begin
        Str := Str + GCWordServer.Documents.Item(i).Name;
        if i < NumDocs then Str := Str + ', ';
      end;
      Add( Str );

      if mewfUseVBA in GCWSVBAFlags then
      begin
        Str := 'AddIns: ';
        for i := 1 to NumAddins do
        begin
          Str := Str + GCWordServer.AddIns.Item(i).Name;
          if i < NumAddins then Str := Str + ', ';
        end;
        Add( Str );
      end; // if mewfUseVBA in GCWSVBAFlags then
    end; // if AMode = 2 then // add all Doc and AddIn Names

    Add( '' ); // final empty string as delimeter
  end; // with N_InfoSL do
end; // function TN_GlobCont.GetWSInfo

//********************************************* TN_GlobCont.OpenWordDocSafe ***
// Open given AFileName as Word Document if not already opened
//
procedure TN_GlobCont.OpenWordDocSafe( AFullFileName: string );
begin
  with GCWSDocNames do
  begin
    AFullFileName := K_OptimizePath( AFullFileName );
    if -1 <> IndexOf( AFullFileName ) then Exit; // already opened

//    N_i1 := GCWordServer.Documents.Count;

    if GCWSMajorVersion >= 10 then
      GCWordServer.Documents.Open( FileName:=AFullFileName, Visible:=False )
    else
      GCWordServer.Documents.Open( FileName:=AFullFileName );

    Objects[ Add( AFullFileName ) ] := TObject(0); // Add and set "was NOT initially opened" flag
//    N_i2 := IndexOf( AFullFileName );
  end; // with GCWSDocNames do
end; // procedure TN_GlobCont.OpenWordDocSafe

//******************************************** TN_GlobCont.CloseWordDocSafe ***
// If Word Document with given AFileName exists, Close it without saving
// ( AFileName can contain Full Path)
//
procedure TN_GlobCont.CloseWordDocSafe( AFullFileName: string );
var
  Ind: integer;
//  Doc: Variant;
begin
  Ind := GCWSDocNames.IndexOf( AFullFileName );
  if Ind = -1 then Exit; // no such a Document
  GCWSDocNames.Delete( Ind );

//  N_i1 := GCWordServer.Documents.Count;
  GCWordServer.Documents.Item( AFullFileName ).Close( SaveChanges:=wdDoNotSaveChanges );
//  N_i2 := GCWordServer.Documents.Count;
//  if N_i1 <> (N_i2+1) then
//    N_i := 0;

//  Doc := GCWordServer.Documents.Item( AFullFileName );
//  N_s := Doc.Name;
//  Doc.Saved := True;
//  Doc.Close( SaveChanges:=wdDoNotSaveChanges );
//  Doc := Unassigned();

  Application.ProcessMessages();
end; // procedure TN_GlobCont.CloseWordDocSafe

//*****************************************  TN_GlobCont.WordProcessSPLMacros  ***
// Process macros (Expand all Level Macros) attached to AComp in given Word Document ADoc
//
procedure TN_GlobCont.WordProcessSPLMacros( AComp: TN_UDBase; ADoc: Variant );
var
  i, j, NumMacros, NumBookMarks: integer;
  BegBracketInd, BegSearchInd: integer;
  BookMarkName, NewName, CurName, DocText, ResRangeText: string;
  SavedShowHiddenText: boolean;
  BookMark, BookMarkRange, BMFootnotes, BracketRange: Variant;
  BMNames: TStringlist;
  BracketsInfo: TN_BracketsInfo;

  procedure ProcessOneMacro( AMacroStr: string ); // local
  var
    SheetType: ULong;
    MacroType: char;
    FName, FExt, ControlToken, FlagsToken, ResStr: string;
    ChildDoc, Sheet1: Variant;
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
          WordProcessSPLMacros( AComp, ChildDoc );

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
          // Pastes Picture BEFORE bookmark content (instead of replacing it!)!
          BookMarkRange.Text := '';
          BookMarkRange.Paste();
        end;

        if Pos( 'E', FlagsToken ) >= 1 then // replace BookMark content by Empty string
          BookMarkRange.Text := ''

      end else if FExt = '.XLS' then //***** Process Excel Document
      begin
        DefExcelServer();
        ChildDoc := GCExcelServer.WorkBooks.Open( FName );
        ProcessExcelMacros( AComp, ChildDoc );
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
      ResStr := TN_UDCompBase(AComp).ProcessOneL1Macro( AMacroStr );

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

  end; // procedure ProcessOneMacro( AMacroStr: string ); // local

begin //******************************* TN_GlobCont.WordProcessSPLMacros main body
//  N_T1.Start;

  //***** Expand Glob Vars in (#...#) brackets if needed
  if not (wffSkipSPLMacros in TN_UDWordFragm(AComp).PIDP()^.WFFlags) then
  begin
    BracketRange := ADoc.Content; // is used later as wrk Range
    DocText := N_ConvUnicodeTo1251( BracketRange.Text );

    N_GetBracketsInfo( DocText, BracketsInfo );

    if Length(BracketsInfo) > 0 then
      BracketRange.Find.Text := '(#';

    BegSearchInd := 0;

    for i := 0 to High(BracketsInfo) do // along all Brackets in forward direction
    with BracketsInfo[i] do
    begin
      BracketRange.SetRange( BegSearchInd, BegSearchInd );
      BracketRange.EndOf( wdStory, wdExtend );
      BracketRange.Find.Execute;

      BegBracketInd := BracketRange.Start;
//      BracketRange.End := BegBracketInd + Length(BIText) + 4;
      N_SetWordRangeEnd ( BracketRange, BegBracketInd + Length(BIText) + 4 );

//      N_s := BracketRange.Text; // debug
      ResRangeText := N_Conv1251ToUnicode( N_GetGlobVarAsString( GCVarInfoProc, BIText ) );
      BracketRange.Text := ResRangeText;

//      N_s2 := BracketRange.Text; // debug
//      BegSearchInd := BracketRange.End;
      BegSearchInd := N_GetWordRangeEnd( BracketRange );
//      N_s2 := ADoc.Content.Text; // debug
    end; // for i := 0 to High(BracketsInfo) do // along all Brackets in forward direction

{ Old variant
    //***** Corrent BracketsInfo by "Word EndOfCell" characters ( #7 )
    BegInd := 1;
    NumCells := 0;

    for i := 0 to High(BracketsInfo) do // along all Brackets
    with BracketsInfo[i] do
    begin
      // Calc number of Table Cells before i-th Bracket
      NumCells := NumCells + N_CalcNumChars( DocText, BegInd, BIBegInd, #7 );
      BegInd := BIEndInd + 1; // after i-th Bracket

      Dec( BIBegInd, NumCells ); // correct Inds for using BracketRange.SetRange
      Dec( BIEndInd, NumCells );
    end; // for i := High(BracketsInfo) downto 0 do // along all Brackets from bottom up

    for i := High(BracketsInfo) downto 0 do // along all Brackets from bottom up
    with BracketsInfo[i] do
    begin
      BracketRange.SetRange( BIBegInd-1, BIEndInd );

      N_s := BracketRange.Text; // debug
      N_s1 := N_Conv1251ToUnicode( N_GetGlobVarAsString( GCVarInfoProc, BIText ) );
      BracketRange.Text := N_s1;

      N_s2 := BracketRange.Text; // debug
//      N_s2 := ADoc.Content.Text; // debug
    end; // for i := High(BracketsInfo) downto 0 do // along all Brackets from bottom up
}
    NumBookMarks := ADoc.BookMarks.Count;

    for i := NumBookMarks downto 1 do // along all BookMarks from bottom up
    begin
      BookMark := ADoc.BookMarks.Item(i);
      BookMarkName := UpperCase( BookMark.Name );

      if BookMarkName[Length(BookMarkName)] <> '_' then Continue;

      BookMarkRange := BookMark.Range;

      ResRangeText := N_Conv1251ToUnicode( N_GetGlobVarAsString( GCVarInfoProc, BookMarkRange.Text ) );
      BookMarkRange.Text := ResRangeText;
    end; // for i := NumBookMarks downto 1 do // along all BookMarks from bottom up

  end; // if not (wffSkipSPLMacros in TN_UDWordFragm(AComp).PIDP()^.WFFlags) then

  if wffSkipSPLMacros in TN_UDWordFragm(AComp).PIDP()^.WFFlags then Exit; // Skip Processing

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
end; // procedure TN_GlobCont.WordProcessSPLMacros( ADoc: Variant );

//***************************************** TN_GlobCont.WordPasteClipBoard ***
// Paste Clipboard to GCWSMainDocIP and Collapse GCWSMainDocIP to the End
//
procedure TN_GlobCont.WordPasteClipBoard();
begin
  GCWSMainDocIP.Paste; // Paste Clipboard
  GCWSMainDocIP.Collapse( Direction := wdCollapseEnd );
end; // procedure TN_GlobCont.WordPasteClipBoard

//***************************************  TN_GlobCont.TextBlocksToMSWord  ***
// Add given ATextBlocks to MS Word
//
procedure TN_GlobCont.TextBlocksToMSWord( ATextBlocks: TK_RArray );
var
  i: integer;
//  Str, FName: string;
//  SL: TStringList;
begin
  if ATextBlocks = nil then Exit; // a precaution

  for i := 0 to ATextBlocks.ALength()-1 do
  with TN_POneTextBlock(ATextBlocks.P(i))^ do
  begin

//  if OTBFName <> '' then FName := K_ExpandFileName( OTBFName );

  case OTBType of

  tbtText: // Text (HTML, SVG, ...) fragment in OTBMText
  begin
    // Add later Font, Position and Color processing
    GCWordServer.ActiveDocument.Range.InsertAfter( OTBMText );
  end; // tbtText: // Text (HTML, SVG, ...) fragment in OTBMText

{ // temporary not implemented
  tbtTextComp: // External Text Component in OTBComp (add Text to Cell)
  begin
    if not (OTBComp is TN_UDCompBase) then Continue; // a precaution

//    TN_UDCompBase(OTBComp).ExecRootSubTree( Self, [] );
    ExecuteComp( OTBComp, [] );
  end; // tbtTextComp: // External Text Component in OTBComp (add Text to Cell)

  tbtVisComp: // External Visual Component in OTBComp (create Pict File and add <img> Tag)
  begin
    if not (OTBComp is TN_UDCompVis) then Continue; // a precaution

    TN_UDCompBase(OTBComp).ExpImageTag( OTBMText, Self ); // use OTBMText as <img> tag attributes
  end; // tbtVisComp: // External Visual Component in OTBComp

  tbtPictFile: // Picture File with OTBFName (add <img> Tag)
  begin
    if OTBMText = '' then Str := '>' // OTBMText may contain additional attributes
                     else Str := ' ' + OTBMText + '>';

    Str := '<img src=' + ExtractRelativePath( GCMainFileName, FName) + Str;
    GCOutSL.Add( Str );
  end; // tbtPictFile: // Picture File with OTBFName (add <img> Tag)

  tbtTextFile: // Include Content of Text (HTML, SVG, ...) File with OTBFName
  begin
    SL := TStringList.Create();
    SL.LoadFromFile( FName );
    GCOutSL.AddStrings( SL );
    SL.Free;
  end; // tbtTextFile: // Include Text (HTML, SVG, ...) File with OTBFName
}

  end; // case OTBType of
  end; // with ... do, for i := 0 to ATextBlocks.ALength()-1 do
end; // procedure TN_GlobCont.TextBlocksToMSWord

//************************************** TN_GlobCont.WordInsNearBookmark ***
// Insert given Content near given Bookmark in GCWSMainDoc Word Document
// Return Range with inserted content
//
// AContent is a String to Insert or a FileName
//
function TN_GlobCont.WordInsNearBookmark( AWhere: TN_WordInsBmkWhere;
                                           AWhat:  TN_WordInsBmkWhat;
                                     ABookmarkName, AContent: string ): variant;
var
  SavedViewType: integer;
  WasChanged: boolean;
  WhereIP: variant;
begin
  WhereIP := GCWSMainDoc.Bookmarks.Item( ABookmarkName ).Range;

  // define empty Insertion Point WhereIP at needed place in GCWSMainDoc

  case AWhere of

  wibwhereBefore1: begin // one character before Bookmark
    WhereIP.Collapse( wdCollapseStart );
    WhereIP.Move( wdCharacter, -1 );
  end; // wibwhereBefore1: begin // one character before Bookmark

  wibwhereBefore0: begin // just before Bookmark
    // temporary not implemented
  end; // wibwhereBefore0: begin // just before Bookmark

  wibwhereBegin: begin // as Bookmark first characters
    WhereIP.Collapse( wdCollapseStart );
  end; // wibwhereBegin: begin // as Bookmark first characters

  wibwhereInstead: begin // Instead of Bookmark (Bookmark will be removed)
    // WhereIP is already OK
  end; // wibwhereInstead: begin // Instead of Bookmark (Bookmark will be removed)

  wibwhereInside: begin // as a whole Bookmark new Content
    // temporary not implemented
  end; // wibwhereInside: begin // as a whole Bookmark new Content

  wibwhereEnd1: begin // before the last Bookmark character
    WhereIP.Collapse( wdCollapseEnd );
    WhereIP.Move( wdCharacter, -1 );
  end; // wibwhereEnd1: begin // before the last Bookmark character

  wibwhereEnd0: begin // as Bookmark Last characters
    // temporary not implemented
  end; // wibwhereEnd0: begin // as Bookmark Last characters

  wibwhereAfter: begin // just After Bookmark
    WhereIP.Collapse( wdCollapseEnd );
  end; // wibwhereAfter: begin // just After Bookmark

  wibwhereCurrent: begin // at current GCWSMainDocIP (Bookmark is not used)
    WhereIP := GCWSMainDocIP;
  end; // wibwhereCurrent: begin // at current GCWSMainDocIP (Bookmark is not used)

  end; // case AWhere of

  // Insert needed Content at WhereIP

  case AWhat of

  wibWhatClipboard: begin // Current Clipboard Content
    WhereIP.Paste();
  end; // wibWhatClipboard: begin // Current Clipboard Content

  wibWhatString: begin // given String
    WhereIP.Text := AContent;
  end; // wibWhatString: begin // given String

  wibWhatDoc: begin // File Content (AContent is FileName)
    WhereIP.InsertFile( AContent );
  end; // wibWhatDoc: begin // File Content (AContent is FileName)

  wibWhatSubDoc: begin // SubDocument  (AContent is FileName)
    SavedViewType := GCWSMainDoc.ActiveWindow.View.Type;
    WasChanged := False;
//ActiveDocument.Subdocuments.Expanded
    if SavedViewType <> wdMasterView then
    begin
      GCWSMainDoc.ActiveWindow.View.Type := wdMasterView;
      WasChanged := True;
    end;
//    WhereIP.InsertParagraphAfter;
//    WhereIP.Move( wdCharacter, 1 );
    WhereIP.Select; // is needed for using AddFromFile method
    GCWSMainDoc.Subdocuments.AddFromFile( AContent );
    GCWordServer.Selection.Collapse( wdCollapseStart );
    GCWordServer.Selection.Delete( wdCharacter, -1 );
//    GCWordServer.Selection.Range.Text := 'Û'; // debug AFTER added Subdocument!

    if WasChanged then
      GCWSMainDoc.ActiveWindow.View.Type := SavedViewType;
  end; // wibWhatSubDoc: begin // SubDocument (AContent is FileName)

  end; // case AWhat of

  Result := WhereIP;
end; // procedure TN_GlobCont.WordInsNearBookmark

//**************************************** TN_GlobCont.WordExpAndInsSubdoc ***
// Export given Component ASubDocComp to a given AFileName and
// Insert created file as Word Subdocument into GCWSMainDoc at GCWSMainDocIP
// ( if AFileName = '' then ASubDocComp.ExpParams.EPMainFName is used,
//   but if several Subdocumnts are created by the same Component, EPMainFName
//   cannot be used and differnet AFileNames should be given as params! )
//
procedure TN_GlobCont.WordExpAndInsSubdoc( ASubDocComp: TObject; AFileName: string );
var
  SDComp: TN_UDCompBase;
  NewExpPar: TN_ExpParams;
begin
  if not (ASubDocComp is TN_UDCompBase) then Exit; // a precaution
  SDComp := TN_UDCompBase(ASubDocComp); // to reduce code size

  if AFileName = '' then // not given, try to take from ExpParams
  begin
    AFileName := SDComp.GetPExpParams()^.EPMainFName;
    AFileName := PrepNewFileName( AFileName, 'WordSubDoc.doc' );
  end;

  NewExpPar := N_DefExpParams;
  NewExpPar.EPMainFName := AFileName;

  SDComp.ExecInNewGCont( [cifSeparateGCont], nil, nil, @NewExpPar ); // Create document with AFileName
  WordInsNearBookmark( wibwhereCurrent, wibWhatSubDoc, '', AFileName );
end; // procedure TN_GlobCont.WordExpAndInsSubdoc

//****************************************  TN_GlobCont.AddPDCounter  ***
// Add to given AStr numerical postfix from GCPDCounter
//
function TN_GlobCont.AddPDCounter( AStr: string ): string;
begin
  Result := AStr + IntToStr( GCPDCounter );
end; // function TN_GlobCont.AddPDCounter

//*********************************************** TN_GlobCont.SetWordPSMode ***
// Set given Word ParamsStr AMode in VBA and Delphi environment
// If given AMode is not correct, set proper mode
//
procedure TN_GlobCont.SetWordPSMode( AMode: TN_MEWordPSMode );
begin
  // in not mewfUseVBA mode SetWordPSMode procedure should not be called!
  Assert( (AMode <> psmNotGiven) and (mewfUseVBA in GCWSVBAFlags), 'Bad AMode!' );

  if ((AMode = psmFile) or (AMode = psmWinAPIClb) or (AMode = psmDelphiMem)) and
       not (mewfUseWin32API in GCWSVBAFlags) then
    AMode := psmPSDocClb; // can always be used

  //***** Set new AMode in VBA environment
  SetWordParamsStr( 'N_ParamsStrMode%%' + IntToStr(integer(AMode)) );
  RunWordMacro( 'N_SetGlobVars' );

  //***** Set newAMode in Delphi environment
  GCWSPSMode := AMode;
end; // procedure TN_GlobCont.SetWordPSMode

//******************************************** TN_GlobCont.SetWordParamsStr ***
// Pass given AParStr (Params string) to Word VBA using current GCWSPSMode
//
procedure TN_GlobCont.SetWordParamsStr( AParStr: string );
var
  AParStrSize: integer;
begin
  AParStrSize := Length(AParStr);

  Assert( (not (GCWSPSMode = psmPSDocVar)) or
          (AParStrSize <= 64000), 'Too Big DocVar!' );

  Assert( not ((GCWSPSMode = psmFile) or (GCWSPSMode = psmWinAPIClb) or
               (GCWSPSMode = psmDelphiMem)) or
       (mewfUseWin32API in GCWSVBAFlags), 'No Win32API in VBA!' );


  case GCWSPSMode of
    psmFile:      N_WriteTextFile( GCWSTmpDir + N_GCWSParamsStrFName, AParStr );
//    psmMDDocVar:  GCWSMainDoc.Variables.Item( N_GCWSParStrDocVarName ).Value :=
//                                                 N_Conv1251ToUnicode( AParStr );
    psmWinAPIClb: K_PutTextToClipboard( AParStr );

    psmDelphiMem:
    begin
      if Length(N_DelphiMem) < (AParStrSize+8) then
        SetLength( N_DelphiMem, AParStrSize+8 );

      PInteger(@N_DelphiMem[0])^ := AParStrSize;

      if AParStrSize >= 1 then
        Move( AParStr[1], N_DelphiMem[4], AParStrSize );
    end; // psmDelphiMem:

    psmPSDocVar:  GCWSPSDoc.Variables.Item( N_GCWSParStrDocVarName ).Value :=
                                                 N_Conv1251ToUnicode( AParStr );
    psmPSDocText: GCWSPSDoc.Content.Text := N_Conv1251ToUnicode( AParStr );
    psmPSDocClb:  K_PutTextToClipboard( AParStr );
  end; // case GCWSPSMode of

end; // procedure TN_GlobCont.SetWordParamsStr

//******************************************** TN_GlobCont.GetWordParamsStr ***
// Return Params String from Word VBA using current GCWSPSMode
//
function TN_GlobCont.GetWordParamsStr(): string;
var
  ParamsStrSize: integer;
begin
  Assert( not ((GCWSPSMode = psmFile) or (GCWSPSMode = psmWinAPIClb) or
               (GCWSPSMode = psmDelphiMem)) or
       (mewfUseWin32API in GCWSVBAFlags), 'No Win32API in VBA!' );

  case GCWSPSMode of
    psmFile:      Result := N_ReadTextFile( GCWSTmpDir + N_GCWSParamsStrFName );
//    psmMDDocVar:  Result := N_ConvUnicodeTo1251( GCWSMainDoc.Variables.Item( N_GCWSParStrDocVarName ).Value );
    psmWinAPIClb: Result := K_GetTextFromClipboard();

    psmDelphiMem:
    begin
      ParamsStrSize := PInteger(@N_DelphiMem[0])^;
      Assert( ParamsStrSize < 64000, 'TooBigParStr!' );
      SetLength( Result, ParamsStrSize );
      Move( N_DelphiMem[4], Result[1], ParamsStrSize );
    end; // psmDelphiMem:

    psmPSDocVar:   Result := N_ConvUnicodeTo1251( GCWSPSDoc.Variables.Item( N_GCWSParStrDocVarName ).Value );
    psmPSDocText:
    begin
      Result := N_ConvUnicodeTo1251( GCWSPSDoc.Content.Text );
      SetLength( Result, Length(Result)-1 );
    end;
    psmPSDocClb:
    begin
      Result := K_GetTextFromClipboard();
//      SetLength( Result, Length(Result)-1 );
    end;
  end; // case GCWSPSMode of
end; // function TN_GlobCont.GetWordParamsStr


//******************************************** TN_GlobCont.DefExcelServer ***
// Define GCExcelServer if not yet
//
procedure TN_GlobCont.DefExcelServer();
begin
  if not VarIsEmpty( GCExcelServer ) then Exit; // GCExcelServer is OK

  GCExcelServer := N_GetOLEServer( N_MEGlobObj.MEExcelServerName, @GCESWasCreated );
//  GCExcelServer.Visible := True; // debug
end; // procedure TN_GlobCont.DefExcelServer

//*******************************************  TN_GlobCont.CloseExcelDocSafe  ***
// If Excel Document with given AFileName exists, Close it without saving
//
procedure TN_GlobCont.CloseExcelDocSafe( AFileName: string );
var
  i: integer;
  DocName: string;
  Docs, Doc: Variant;
begin
  DocName := ExtractFileName( AFileName );
  Docs := GCExcelServer.Workbooks;

  for i := 1 to Docs.Count do
  begin
    Doc := Docs.Item[i];
    if Doc.Name = DocName then // found
    begin
      Doc.Saved := True;
      Doc.Close;
      Exit;
    end;
  end; // for i := 1 to Docs.Count do
end; // procedure TN_GlobCont.CloseExcelDocSafe

//****************************************  TN_GlobCont.ProcessExcelMacros  ***
// Process macros (Expand all Level Macros) in given Excel Document ADoc
//
procedure TN_GlobCont.ProcessExcelMacros( AComp: TN_UDBase; ADoc: Variant );
var
  j, NumNames: integer;
  MacroType: char;
  FName, FExt, ControlToken, FlagsToken, MacroStr, ResStr, NamePrefix: string;
  ChildDoc, CurNameObj, NameRange: Variant;
begin
//  N_T1.Start;
  NumNames := ADoc.Names.Count;
  GCESCurDoc := ADoc;
//  N_s := GCESCurDoc.Name; // debug

  for j := 1 to NumNames do // along all Names
  begin
    CurNameObj := ADoc.Names.Item(j);
    N_s := CurNameObj.Name; // debug
    NamePrefix := UpperCase( Copy ( CurNameObj.Name, 1, 5 ) );
    if NamePrefix <> 'MACRO' then Continue; // not a macro, check next Name

    GCCurMacroAdr := UpperCase( CurNameObj.RefersTo );
    NameRange := CurNameObj.RefersToRange;
    MacroStr := N_PrepSPLCode( NameRange.Text );
    ControlToken := TrimLeft( UpperCase( N_ScanToken( MacroStr ) ) ); // first control token
    MacroType := ControlToken[1]; // 'F' - File Name,  'M' - Macros (SPL code)
    FlagsToken := Copy( ControlToken, 2, Length(ControlToken)-1 );

    if MacroType = 'F' then // Process Office document File (MacroStr is File Name)
    begin
      FName := K_ExpandFileName( MacroStr );
      FExt := UpperCase( ExtractFileExt( FName ) );

      if FExt = '.DOC' then //***** Process Word Document
      begin
        DefWordServer();
        ChildDoc := GCWordServer.Documents.Add( Template:=FName );

        if Pos( 'M', FlagsToken ) >= 1 then // Macros should be processed
          WordProcessSPLMacros( AComp, ChildDoc );

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

        if Pos( 'B', FlagsToken ) >= 1 then // replace Name content by Clipboard content
          NameRange.Paste();

        if Pos( 'E', FlagsToken ) >= 1 then // replace Name content by Empty string
          NameRange.Text := ''

      end else if FExt = '.XLS' then //***** Process Excel Document
      begin
{ // not implemented
  var
  SheetType: ULong;

        DefExcelServer();
        ChildDoc := GCExcelServer.WorkBooks.Open( FName );
        ProcessExcelMacros( AComp, ChildDoc );
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

        ADoc.Names.Item(1).Range.Paste;
}
      end; // else if FExt = '.XLS' then //***** Process Excel Document

    end else if MacroType = 'M' then // Process Macros (SPL code) in MacroStr
    begin
      ResStr := TN_UDCompBase(AComp).ProcessOneL1Macro( MacroStr );

      if Length(FlagsToken) >= 1 then
      begin
        if FlagsToken[1] = 'B' then // replace Name content by Clipboard content
  //        NameRange.PasteSpecial( ... )
        else if FlagsToken[1] = 'E' then // replace Name content by Empty string
          NameRange.Value := ''
        else if FlagsToken[1] = 'T' then // replace Name content by _ResStr SPL variable
          NameRange.Value := ResStr;
      end; // if Length(FlagsToken) >= 1 then
    end; // else -  Process Macros (SPL code) in MacroStr

  end; // for j := 1 to NumNames do // along all Names

  GCESCurDoc  := Unassigned();
  GCCurWTable := Unassigned(); // (may be set in macros)
  GCCurESheet := Unassigned(); // (may be set in macros)
  GCCurEChart := Unassigned(); // (may be set in macros)

//  N_T1.SS( 'ProcessExcelMacros' );
end; // procedure TN_GlobCont.ProcessExcelMacros( ADoc: Variant );

//***************************************  TN_GlobCont.TextBlocksToMSExcel  ***
// Add given ATextBlocks to ActiveCell of MS Excel
//
procedure TN_GlobCont.TextBlocksToMSExcel( ATextBlocks: TK_RArray );
var
  i: integer;
  A: Variant;
//  Str, FName: string;
//  SL: TStringList;
begin
  if ATextBlocks = nil then Exit; // a precaution

  for i := 0 to ATextBlocks.ALength()-1 do
  with TN_POneTextBlock(ATextBlocks.P(i))^ do
  begin

//  if OTBFName <> '' then FName := K_ExpandFileName( OTBFName );

  case OTBType of

  tbtText: // Text (HTML, SVG, ...) fragment in OTBMText
  begin
    A := GCExcelServer.ActiveSheet;
    A.Cells[1,2] := A.Cells[1,1];
    A.Cells[1,1] := A.Cells[1,1].Value + 10;
    // Add later Font, Position and Color processing
//    GCOLEServer.ActiveSheet.Cells[1,1].Text := OTBMText;
  end; // tbtText: // Text (HTML, SVG, ...) fragment in OTBMText

{ // temporary not implemented
  tbtTextComp: // External Text Component in OTBComp (add Text to Cell)
  begin
    if not (OTBComp is TN_UDCompBase) then Continue; // a precaution

//    TN_UDCompBase(OTBComp).ExecRootSubTree( Self, [] );
    ExecuteComp( OTBComp, [] );
  end; // tbtTextComp: // External Text Component in OTBComp (add Text to Cell)

  tbtVisComp: // External Visual Component in OTBComp (create Pict File and add <img> Tag)
  begin
    if not (OTBComp is TN_UDCompVis) then Continue; // a precaution

    TN_UDCompBase(OTBComp).ExpImageTag( OTBMText, Self ); // use OTBMText as <img> tag attributes
  end; // tbtVisComp: // External Visual Component in OTBComp

  tbtPictFile: // Picture File with OTBFName (add <img> Tag)
  begin
    if OTBMText = '' then Str := '>' // OTBMText may contain additional attributes
                     else Str := ' ' + OTBMText + '>';

    Str := '<img src=' + ExtractRelativePath( GCMainFileName, FName) + Str;
    GCOutSL.Add( Str );
  end; // tbtPictFile: // Picture File with OTBFName (add <img> Tag)

  tbtTextFile: // Include Content of Text (HTML, SVG, ...) File with OTBFName
  begin
    SL := TStringList.Create();
    SL.LoadFromFile( FName );
    GCOutSL.AddStrings( SL );
    SL.Free;
  end; // tbtTextFile: // Include Text (HTML, SVG, ...) File with OTBFName
}

  end; // case OTBType of
  end; // with ... do, for i := 0 to ATextBlocks.ALength()-1 do
end; // procedure TN_GlobCont.TextBlocksToMSExcel

{
//******************************************  TN_GlobCont.ProcessOLEMacros  ***
// Check that needed OLE Server is defined and
// Process macros (Expand all Level Macros) in given Document ADoc
//
procedure TN_GlobCont.ProcessOLEMacros( AComp: TN_UDBase; ADoc: Variant;
                                                      ADocType: TN_OLEDocType );
begin
  if ADocType = odtWord then
  begin
    DefWordServer();
    WordProcessSPLMacros( AComp, ADoc );
  end; // if ADocType = ostWord then

  if ADocType = odtExcel then
  begin
    DefExcelServer();
    ProcessExcelMacros( AComp, ADoc );
  end; // if ADocType = ostExcel then
end; // procedure TN_GlobCont.ProcessOLEMacros
}

//****************************************  TN_GlobCont.GetNewFilesDir  ***
// Return NewFilesDir Name (by GCMainFileName) and create it,
// if not yet and if ACreate = True
//
function TN_GlobCont.GetNewFilesDir( ACreate: boolean ): string;
var
  DirLastToken, DirPath: string;
begin
  if GCNewFilesDir <> '' then Exit; // already OK

  DirLastToken := ChangeFileExt( ExtractFileName( GCMainFileName ), '' );

  if DirLastToken = '' then Exit; // GCMainFileName is empty

  DirPath := ExtractFileDir( GCMainFileName );
  GCNewFilesDir := DirPath + '\' + DirLastToken;

  if ACreate and not DirectoryExists( GCNewFilesDir ) then
    CreateDir( GCNewFilesDir );

end; // function TN_GlobCont.GetNewFilesDir

//****************************************  TN_GlobCont.PrepNewFileName  ***
// Prepare NewFileName by given AFName (if <> '') and given FileName
// pattern AFNamePat
//
function TN_GlobCont.PrepNewFileName( AFName, AFNamePat: string ): string;
begin

end; // function TN_GlobCont.PrepNewFileName

//*********************************************** TN_GlobCont.PrepForExport ***
// Prepare GlobCont(Self) for Exporting given ARootComp according to given
// APExpParams and ARootComp.CBExpParams
// (ARootComp should be TN_UDCompBase type, TObject is used to avoid circular unit reference)
//
procedure TN_GlobCont.PrepForExport( ARootComp: TObject; APExpParams: TN_PExpParams );
var
  i: integer;
  DSTResDPI: TFPoint;
  NewFilesDir: string;
  RootComp: TN_UDCompBase;
  RootVisComp: TN_UDCompVis;
begin
  GCPrepForExportFailed := False; // initial value
  GCRootComp := nil; // is used "Preparing failed" flag
  if not (ARootComp is TN_UDCompBase) then Exit; // a precaution

  GCSavedCursor := Screen.Cursor; // change cursor until FinishExport
  Screen.Cursor := crHourglass;

  GCRootComp := ARootComp;
  RootComp   := TN_UDCompBase(ARootComp); // to reduce code size
  RootComp.PrepRootComp();

  //***** Prepare GCExpParams by given APExpParams and ARootComp.CBExpParams

  GCExpParams := RootComp.GetPExpParams()^;
  N_PrepExpParams( APExpParams, @GCExpParams );
  if epefShowTime in GCExpParams.EPExecFlags then GCTimerFull.Start();

  //***** GCExpParams are OK, set Export Flags and GC...Mode boolean fields

  GCExpFlags := RootComp.GetExpFlags( @GCExpParams );
  if not (cefExec in GCExpFlags) then Exit; // a precaution, Component cannot be Exported (Executed)

  GCCoordsMode  := False;
  GCTextMode    := False;
  GCMSWordMode  := False;
  GCMSExcelMode := False;

  if RootComp.CI() = N_UDExpCompCI then Exit; // temporary

  //***** Prepare all needed File Name related fields and clear NewFiles Dir

  GCMainFileName := K_ExpandFileName( GCExpParams.EPMainFName );
  GCShowResponse( 'Exporting ' + ExtractFileName(GCMainFileName) + ' ...' );
  GCNewFilesDir := '';
  NewFilesDir := GetNewFilesDir( False );

  if DirectoryExists( NewFilesDir ) then
    N_DeleteFiles( GCNewFilesDir + '\*.*', 0 );

  //***** Clear needed variables:
  StopExecFlag  := False;
  GCBFreeInd    := 0;
  GCNewFilesInd := 1;

  //***** Individual code for different export modes:
  //      Word, Excel, Coords, GDI, Text, ...

//  DebAddDocsInfo( '', 0 );
//  DebAddDocsInfo( '*** Prepare for ' + GCMainFileName, 0 );


  if cefWordDoc in GCExpFlags then //********************** Export to MS Word
  with TN_UDWordFragm(RootComp).PIDP()^ do
  begin
    DefWordServer();

    if GCProperWordIsAbsent then // not proper Word version (now Word 97 or less)
    begin
      GCPrepForExportFailed := True;
      Screen.Cursor := GCSavedCursor;
      Exit;
    end; // if GCProperWordIsAbsent then // not proper Word version (now Word 97 or less)

    GCMSWordMode := True;
    DstImageType := ditNotDef;

    Exit; // all done for Export to MS Word
  end; // if RootComp is TN_UDWordFragm then // Export to MS Word


  if cefExcelDoc in GCExpFlags then //******************** Export to MS Excel
  with TN_UDExcelFragm(RootComp).PIDP()^ do
  begin
    GCMSExcelMode := True;
    DstImageType := ditCoordsOnly;
    DefExcelServer();
    GCESSavedVis := GCExcelServer.Visible; // save for using in Finish Export

    GCWordServer.Visible := mewfWordVisible in N_MEGlobObj.MEWordFlags;

    GCMSExcelMacros := TStringList.Create; // MS Excel Macros Names (DelhiName=WordName)
    N_ReadMemIniSection( 'ExcelMacros', GCMSExcelMacros );
    GCMSExcelMacros.Sort;

    Exit; // all done for Export to MS Excel
  end; // if RootComp is TN_UDExcelFragm then // Export to MS Excel


  if cefCoords in GCExpFlags then //*** prepare all coords dependant fields
  with GCExpParams.EPImageFPar do // (for GDI, SVG, VML, HTMLMap modes)
  begin                           // Set Sizes and Resolution
    Assert( RootComp is TN_UDCompVis, 'Bad ExpFlags!' );
    GCCoordsMode := True;

    if DstOCanv = nil then
      DstOCanv := TN_OCanvas.Create()
    else
      DstOCanv.InitOCanv();

    if not (cefGDI in GCExpFlags) then // SVG, HTMLVML, HTMLMap modes
    begin
      DstImageType := ditCoordsOnly;
      DstOCanv.OCanvType := octCoordsOnly;
    end;

    RootVisComp := TN_UDCompVis(RootComp); // to reduce code size

    // Prepare Sizes and Resolution (calculate zero Size and Resolution fields if any)

    DSTResDPI := IFPResDPI;


    if iefUsePrnRes in GCExpParams.EPImageExpFlags then // Use current Printer Resolution
    begin

    end; // if iefUsePrnRes in GCExpParams.EPImageExpFlags then // Use current Printer Resolution

    GVCTSizeType := RootVisComp.GetSize( @SrcmmSize, @SrcPixSize, DSTResDPI.X );
    GCCurSrcmmSize  := SrcmmSize;
    GCCurSrcPixSize := SrcPixSize;

    DstmmSize  := IFPSizemm;
    DstPixSize := IFPSizePix;
    if (DstmmSize.X = 0) and (DstPixSize.X = 0) then // Both IFPSizes are not given
    begin
      DstmmSize  := SrcmmSize;
      DstPixSize := SrcPixSize;
    end;

    N_UpdateRFResAndSize( DstPixSize, DstmmSize, DSTResDPI );
    GCCurDstPixSize := DstPixSize;

    VisPixRect := IFPVisPixRect;
    if VisPixRect.Left = VisPixRect.Right then // not given, assume that whole Image is visible
      VisPixRect := IRect( DstPixSize );

    VisPixSize := N_RectSize( VisPixRect );
    DstPixRect := N_RectShift( IRect( DstPixSize ), -VisPixRect.Left, -VisPixRect.Top );
    VisPixRect := N_RectShift( VisPixRect,          -VisPixRect.Left, -VisPixRect.Top );

    RootVisComp.CompOuterPixRect := DstPixRect;
    DstOCanv.CurCRect := VisPixRect; // is needed for setting ClipRects
  end; // with GCExpParams.EPImageFPar do, if cefCoords in GCExpFlags then

  if cefGDI in GCExpFlags then //****************** Render by GDI
  with GCExpParams.EPImageFPar do  // (Coords and sizes are already OK)
  begin
    if IFPPixFmt = pfDevice then IFPPixFmt := pf24bit;

    if IFPImFileFmt = imffByFileExt then // set IFPImFileFmt by File Extention
      IFPImFileFmt := N_GetFileFmtByExt( GCMainFileName );

    if (IFPImFileFmt = imffUnknown) or
       (IFPImFileFmt = imffSVG)     or
       (IFPImFileFmt = imffVML) then IFPImFileFmt := imffBMP; // a precaution

    if (IFPImFileFmt = imffGIF) and (IFPPixFmt > pf8bit) then IFPPixFmt := pf8bit; // a precaution

    if (IFPImFileFmt = imffJPEG) and
       ((IFPJPEGQuality < 1) or (IFPJPEGQuality > 100)) then IFPJPEGQuality := 80; // default value

    if (IFPImFileFmt = imffEMF) then // Export to EMF
    begin
      DstImageType := ditWinGDI;
      DstOCanv.OCanvType := octEMF;
      DstMetaFile.Free;
      DstMetaFile := TMetaFile.Create;
      N_b := Windows.DeleteDC( DstOCanv.HMDC );
      Assert( N_b, 'Bad DstOCanv.HMDC' );

      with DstMetaFile do // Define EMF Canvas Size, EMF mm size will be set in FinishExport
      begin                     // MMWidth, MMHeight would be calculated by Delphi:
        Width  := VisPixSize.X; // MMWidth := MulDiv( Value,    ( metafile width in pixels )
        Height := VisPixSize.Y; //   EMFHeader.szlMillimeters.cx*100, ( device width in mm )
      end;                      //   EMFHeader.szlDevice.cx );    ( device width in pixels )

      DstMFCanvas := TMetafileCanvas.Create( DstMetaFile, 0 ); // Graphics 4000
      //  GetEnhMetaFileHeader( DstMetaFile.Handle, Sizeof(MFHeader), @MFHeader ); // debug
      DstOCanv.HMDC := DstMFCanvas.Handle;
      DstOCanv.InitOCanv();
      DstOCanv.CurCRect := VisPixRect;
//      N_TestRectDraw( DstOCanv, 0, 0, $CC ); // debug

    end else //********************* Export to Raster
    begin
      DstImageType := ditWinGDI;
      DstOCanv.OCanvType := octOwnRaster;
      DstOCanv.SetCurCRectSize( VisPixSize.X, VisPixSize.Y, pf24bit );

      if epefHALFTONE in GCExpParams.EPExecFlags then
        Windows.SetStretchBltMode( DstOCanv.HMDC, HALFTONE );

//      N_TestRectDraw( DstOCanv, 0, 0, $CCCC ); // debug
    end; // end else // Export to Raster

  end; // with GCExpParams.EPImageFPar do, if cefGDIFile in GCExpFlags then

  if cefTextFile in GCExpFlags then //**** Export to Text (HTML, SVG, ...) file
  with GCExpParams.EPTextFPar do
  begin
    GCTextMode := True;
    DstImageType := ditText;
    if DstOCanv <> nil then
      DstOCanv.OCanvType := octCoordsOnly;

    if GCOutSL = nil then GCOutSL := TStringList.Create
                     else GCOutSL.Clear;

    if GCOutStyleSL = nil then GCOutStyleSL := TStringList.Create
                          else GCOutStyleSL.Clear;

    GCOutSLBuf.Free;
    GCOutSLBuf := TN_SLBuf.Create( GCOutSL );
    if TFPRowLength > 0 then GCOutSLBuf.RowSize := TFPRowLength;

    if TFPHeader <> '' then GCOutSL.Add( TFPHeader ); // Output File Header

    GCOutLabelInd := -1;
    if TFPPatFName <> '' then // Pattern File Name is given
    begin
      if GCPatternSL = nil then GCPatternSL := TStringList.Create
                           else GCPatternSL.Clear;

      GCPatternSL.LoadFromFile( K_ExpandFileName( TFPPatFName ) );

      GCOutLabelInd := GCPatternSL.IndexOf( N_OutSL_Label );
      if GCOutLabelInd >= 0 then // Label Row found
      begin
        for i := 0 to GCOutLabelInd-1 do // copy beg part of Pattern File
          GCOutSL.Add( GCPatternSL[i] );
      end;

    end; // if TFPPatFName <> '' then // Pattern File Name is given

  end; // if cefTextFile in GCExpFlags then //**** Export to Text (HTML, SVG, ...) file

end; // procedure TN_GlobCont.PrepForExport

//************************************************ TN_GlobCont.FinishExport ***
// Finish Exporting Component:
// save created Office Document or
// save already created Raster or EMF to Picture File or
// save prepared Texts to Text (HTML, SVG, ...) File
//
procedure TN_GlobCont.FinishExport();
var
  i, Ind, EMFContentSize, NumTocs, NumBookmarks: integer;
//  PS, FName: string;
//  ShortFName: string;
  NewHEMF: HENHMETAFILE;
  TmpBMP: TBitmap;
  UseClipboard: boolean;
  WFlags: TN_WordFragmFlags;
  Label Fin;
begin
  if epefShowTime in GCExpParams.EPExecFlags then
    GCTimerFin.Start();

  // set "Use Clipboard" flag
  UseClipboard := N_UseClipboard( GCMainFileName ) or
                  (GCExpParams.EPImageExpMode = iemToClb);

  if GCMSWordMode then //************************** Finish Exporting to MS Word
  begin
    Assert( TN_UDBase(GCRootComp).CI = N_UDWordFragmCI, 'BadType!' );
    WFlags := TN_UDWordFragm(GCRootComp).PDP()^.CWordFragm.WFFlags; // Root WordFragm Flags

//    N_IAdd( GetWSInfo( 2, 'GCont 1' ) ); // debug

    //*****  // Update TOCs (Tables Of Contents) if needed

    if not (wffSkipTOC in WFlags) then // Update TOCs IS needed
    begin
      if mewfUseVBA in GCWSVBAFlags then // Use VBA for Updating TOCs
      begin
        RunWordMacro( 'N_UpdateTOCsAll' );
      end else // Use pascal for Updating TOCs
      begin
        NumTocs := GCWSMainDoc.TablesOfContents.Count;

        for i := NumTocs downto 1 do // expand all TOCs (create TOCs entries)
          GCWSMainDoc.TablesOfContents.Item(i).Update;

        // N_GCMainDoc.Save; // is needed only for very large TOCs

        if NumTocs >= 2 then
        begin
          for i := 1 to NumTocs do // Repaginate after expanding TOCs (is needed only for NumTocs > 1)
            GCWSMainDoc.TablesOfContents.Item(i).UpdatePageNumbers;
        end; // if NumTocs >= 2 then

      end; // else // Use pascal for Updating TOCs
    end; // if not (wffSkipTOC in WFlags) then // Update TOCs is needed


    //***** Remove Bookmarks if needed

    if wffRemoveBookmarks in WFlags then // Remove Bookmarks IS needed
    begin
      if mewfUseVBA in GCWSVBAFlags then // Use VBA for Removing Bookmarks
      begin
        RunWordMacro( 'N_RemoveBookmarks' );
      end else // Use pascal for Updating TOCs
      begin
        NumBookmarks := GCWSMainDoc.Bookmarks.Count;
        for i := 1 to NumBookmarks do
          GCWSMainDoc.Bookmarks.Item(i).Delete;
      end; // else // Use pascal for Updating TOCs
    end; // if wffRemoveBookmarks in WFlags then // Remove Bookmarks IS needed


    //***** Save GCWSMainDoc As GCMainFileName to file or copy to Clipboard

    if GCMainFileName <> '' then // FileName for GCWSMainDoc was given
    begin
      if UseClipboard then // Copy GCWSMainDoc to Clipboard
        GCWSMainDoc.Range.Copy
      else //**************** Save GCWSMainDoc As GCMainFileName file
      begin
        Ind := GCWSDocNames.IndexOf( GCMainFileName );
        if Ind >= 0 then // Document with same name exists, close it
          GCWordServer.Documents.Item( GCMainFileName ).Close( SaveChanges:=wdDoNotSaveChanges );

        if FileExists( GCMainFileName ) then // delete file to avoid warning while SaveAs
          DeleteFile( GCMainFileName );

//        N_IAdd( GetWSInfo( 2, 'GCont 2' ) ); // debug

        GCWSMainDoc.SaveAs( Filename := GCMainFileName );
      end; // else - Save GCWSMainDoc  As GCMainFileName file
    end; // if GCMainFileName <> '' then

    if UseClipboard or (mewfCloseResDoc in GCWSVBAFlags) then
      GCWSMainDoc.Close // Close Created Document (GCWSMainDoc)
    else
      GCWSMainDoc.Activate; // a precaution

    GCWSMainDoc := Unassigned(); // Free reference to Created Document (closed or not)


    //***** Close all temporary opened documents (mainly Templates and GCWSPSDoc)

    with GCWSDocNames do
    begin
//      N_IAdd( GetWSInfo( 2, 'Deb before delete:' ) ); // debug

      for i := 0 to Count-1 do // along all opened documents
      begin
        if Objects[i] = TObject(0) then // was not open before, close it
        begin
          GCWordServer.Documents.Item( Strings[i] ).Close;
//          ShortFName := ExtractFileName( Strings[i] );
//          GCWordServer.Documents.Item( ShortFName ).Close;
        end;
      end; // for i := 1 to Count do // along all opened documents

//      N_IAdd( GetWSInfo( 2, 'Deb after delete:' ) ); // debug
    end; // with GCWSDocNames do

    if mewfUseVBA in GCWSVBAFlags then // GCWSPSDoc is used only in 'Use VBA' mode
    begin
//      GCWSPSDoc.Saved := True;
      GCWSPSDoc.Close( SaveChanges:=wdDoNotSaveChanges );
    end;

    GCWSPSDoc := Unassigned();

{
    // Prepare PS (ParamsStr) for VBA:
    //   U - Update TOCs
    //   R - Remove Bookmarks
    //   L - Copy to cLipboard
    //   C - Close MainDoc
    //   V - Word should be Visible

    PS := '';
    if not (wffSkipTOC in WFlags)   then PS := PS + 'U'; // Update TOCs (Tables Of Contents)
    if wffRemoveBookmarks in WFlags then PS := PS + 'R'; // Remove Bookmarks
    if UseClipboard                 then PS := PS + 'L'; // Copy to cLipboard
//    if not (epefNotCloseDoc in GCExpParams.EPExecFlags) then PS := PS + 'C'; // Close Created Document
    if mewfCloseResDoc in N_MEGlobObj.MEWordFlags then PS := PS + 'C'; // Close Created Document

    ShouldBeVisible := GCWSWasVisible;
    if not (mewfCloseResDoc in N_MEGlobObj.MEWordFlags) then // Show Server
      ShouldBeVisible := True;

    if ShouldBeVisible then PS := PS + 'V'; // Word should be Visible
    GCWSWasVisible := ShouldBeVisible; // update GCWSWasVisible (will be used in destroy)

    if mewfUseVBA in GCWSVBAFlags then // Use VBA macro Finishing Export
    begin
      SetWordParamsStr( PS );
      RunWordMacro( 'FinishExport' );
    end else //************************** Use Pascal for Finishing Export
    begin

      if Pos( 'U', PS ) > 0 then // Update TOCs (Tables Of Contents)
      begin
        NumTocs := GCWSMainDoc.TablesOfContents.Count;

        for i := NumTocs downto 1 do // expand all TOCs (create TOCs entries)
          GCWSMainDoc.TablesOfContents.Item(i).Update;

        // N_GCMainDoc.Save; // is needed only for very large TOCs

        if NumTocs >= 2 then
        begin
          for i := 1 to NumTocs do // Repaginate after expanding TOCs (is needed only for NumTocs > 1)
            GCWSMainDoc.TablesOfContents.Item(i).UpdatePageNumbers;
        end; // if NumTocs >= 2 then
      end; // if Pos( 'U', PS ) > 0 then // Update TOCs (Tables Of Contents)

      if Pos( 'R', PS ) > 0 then  // Remove Bookmarks
      begin
        NumBookmarks := GCWSMainDoc.Bookmarks.Count;
        for i := 1 to NumBookmarks do
          GCWSMainDoc.Bookmarks.Item(i).Delete;
      end; // if Pos( 'R', PS ) > 0 then  // Remove Bookmarks

//      GCWSMainDoc.Save; // Always Save Created Document
      GCWSMainDoc.SaveAs( Filename := GCMainFileName );

      if Pos( 'L', PS ) > 0 then GCWSMainDoc.Range.Copy; // Copy to cLipboard
      if Pos( 'C', PS ) > 0 then GCWSMainDoc.Close;      // Close MainDoc

      if Pos( 'V', PS ) > 0 then GCWordServer.Visible := True    // Word should be Visible
                            else GCWordServer.Visible := False;

    end; // else // Use Pascal for Finishing Export

    if not (wffSkipTOC in WFlags) then // Update TOCs (Tables Of Contents)
    begin
      if mewfUseVBA in GCWSVBAFlags then // Update Tocs using VBA macros
        RunWordMacro( 'UpdateTOCs' )
      else //****************************** Update Tocs without VBA macros
      begin
        NumTocs := GCWSMainDoc.TablesOfContents.Count;

        for i := NumTocs downto 1 do // expand all TOCs (create TOCs entries)
          GCWSMainDoc.TablesOfContents.Item(i).Update;

        // N_GCMainDoc.Save; // is needed only for very large TOCs

        if NumTocs >= 2 then
        begin
          for i := 1 to NumTocs do // Repaginate after expanding TOCs (is needed only for NumTocs > 1)
            GCWSMainDoc.TablesOfContents.Item(i).UpdatePageNumbers;
        end; // if NumTocs >= 2 then
      end;
    end; // if not (wffSkipTOC in WFlags) then // Update TOCs (Tables Of Contents)

    if wffRemoveBookmarks in WFlags then // Remove Bookmarks
    begin
      if mewfUseVBA in GCWSVBAFlags then // Remove Bookmarks using VBA macros
        RunWordMacro( 'RemoveBookmarks' )
      else //****************************** Remove Bookmarks without VBA macros
      begin
        NumBookmarks := GCWSMainDoc.Bookmarks.Count;
        for i := 1 to NumBookmarks do
          GCWSMainDoc.Bookmarks.Item(i).Delete;
      end;
    end; // if wffRemoveBookmarks in WFlags then // Remove Bookmarks

    if GCMainFileName <> '' then // Save to file or copy to Clipboard
    begin
      if UseClipboard then // Copy GCWSMainDoc to Clipboard (may be not needed, because GCWSMainDoc can be copied to Clipboard in macro)
        GCWSMainDoc.Range.Copy
      else //**************** Save GCWSMainDoc to GCMainFileName file
      begin
//        if FileExists( GCMainFileName ) then
//          DeleteFile( GCMainFileName );
          GCWSMainDoc.Save;

// debug statements:
//        CloseWordDocSafe( GCMainFileName );
//        DebAddDocsInfo( 'Fin Exp Before SaveAs:', 0 );
//      N_T1b.Start();
//        GCWSMainDoc.SaveAs( Filename := GCMainFileName );
//        GCWSMainDoc.Save;
//      N_T1b.SS( 'GCWSMainDoc.Save' );
      end; // else - Save GCWSMainDoc to GCMainFileName file
    end; // if GCMainFileName <> '' then

    if not (epefNotCloseDoc in GCExpParams.EPExecFlags) then
      GCWSMainDoc.Close;  // Close Created Document if needed

    GCWSMainDoc := Unassigned(); // Free reference to Created Document (closed or not)

    ShouldBeVisible := GCWSWasVisible;
    if (epefShowAfter in GCExpParams.EPExecFlags) or
       (epefShowBefore in GCExpParams.EPExecFlags) then // Show Server
      ShouldBeVisible := True;

    GCWordServer.Visible := ShouldBeVisible;
    GCWSWasVisible := ShouldBeVisible; // update GCWSWasVisible (is used in destroy)

    if mewfUseVBA in GCWSVBAFlags then // GCWSPSDoc is used only in 'Use VBA' mode
    begin
      GCWSPSDoc.Saved := True;
      GCWSPSDoc.Close;
      FName := K_ExpandFileName( '(#TmpFiles#)' ) + N_GCPSDocName;
      DeleteFile( FName );
    end;
    GCWSPSDoc := Unassigned();


// , mewfWordVisible
    ShouldBeVisible := GCWSWasVisible;
//    if (epefShowAfter in GCExpParams.EPExecFlags) or
//       (epefShowBefore in GCExpParams.EPExecFlags) then // Show Server
      ShouldBeVisible := True;

    GCWordServer.Visible := ShouldBeVisible;
    GCWSWasVisible := ShouldBeVisible; // update GCWSWasVisible (is used in destroy)

    if GCWSWasCreated and not ShouldBeVisible then // Quit if not visible (may be not needed)
      GCWordServer.Quit;
}

    if GCWSWasVisible or (mewfWordVisible in N_MEGlobObj.MEWordFlags) or
       not (mewfCloseResDoc in GCWSVBAFlags) then
      GCWordServer.Visible := True
    else
      GCWordServer.Quit;

    GCWordServer  := Unassigned();
    Clipboard.AsText := '';
    goto Fin;
  end; // if GCMSWordMode then // ***** Finish Exporting to MS Word


  if GCMSExcelMode then //************************ Finish Exporting to MS Excel
  begin
    if GCMainFileName <> '' then // Save to GCMainFileName file
    begin
      if FileExists( GCMainFileName ) then
        DeleteFile( GCMainFileName );

      CloseExcelDocSafe( GCMainFileName );
//        DebAddDocsInfo( 'Fin Exp Before SaveAs:', 0 );
      GCESMainDoc.SaveAs( Filename := GCMainFileName );
    end; // if GCMainFileName <> '' then

    if mewfCloseResDoc in N_MEGlobObj.MEWordFlags then
      GCESMainDoc.Close;  // Close Created Document if needed

    GCESMainDoc := Unassigned(); // Free reference to Created Document

//    if epefShowAfter in GCExpParams.EPExecFlags then // Show Server if needed
//      GCExcelServer.Visible := True
//    else
//      GCExcelServer.Visible := GCESSavedVis; // restore value, saved in PrepForExport

    GCExcelServer := Unassigned();
    goto Fin;
  end; // if GCMSExcelMode then // ***** Finish Exporting to MS Excel

{
  if GCMainFileName = '' then // a precaution
  begin
    GCShowResponse( 'No File Name!' );
    goto Fin;
  end;
}

  //***************** Finish Exporting to Picture File

  if cefGDIFile in GCExpFlags then // Save Picture in DstOCanvas or in DstMFCanvas To File
  with GCExpParams.EPImageFPar do
  begin
    if DstOCanv.OCanvType = octEMF then // EMF Obj, not Raster, use DstMFCanvas
    begin
//      N_TestRectDraw( DstOCanv, 0, 0, $CC ); // debug

      DstMFCanvas.Free; // move created Image from DstMFCanvas to DstMetaFile
      //  GetEnhMetaFileHeader( DstMetaFile.Handle, Sizeof(MFHeader), @MFHeader ); // debug

      DstOCanv.HMDC := 0; // it was DstMFCanvas.Handle, is no more valid
      FreeAndNil( DstOCanv );

      with N_MEGlobObj do // set EMF Size in mm by DstmmSize, using global Buf in N_MEGlobObj
      begin
        EMFContentSize := GetEnhMetaFileBits( DstMetaFile.Handle, 0, nil );

        if MEEMFBufSize < EMFContentSize then // prepare Buf size
        begin
          MEEMFBuf := nil; // to avoid moving not needed data
          MEEMFBufSize := EMFContentSize + 100;
          SetLength( MEEMFBuf, MEEMFBufSize );
        end;

        GetEnhMetaFileBits( DstMetaFile.Handle, EMFContentSize, @MEEMFBuf[0] );

        with PEnhMetaHeader(@MEEMFBuf[0])^ do // update EMF Size in mm
        begin
//          Coef.X := DstmmSize.X * szlDevice.cx / (szlMillimeters.cx * DstPixSize.X);
//          Coef.Y := DstmmSize.Y * szlDevice.cy / (szlMillimeters.cy * DstPixSize.Y);
//          szlMillimeters.cx := Round( szlMillimeters.cx * Coef.X );
//          szlMillimeters.cy := Round( szlMillimeters.cy * Coef.Y );
//          rclFrame.Right  := Round( rclFrame.Right  * Coef.X );
//          rclFrame.Bottom := Round( rclFrame.Bottom * Coef.Y );

          szlDevice.cx := VisPixSize.X;
          szlDevice.cy := VisPixSize.Y;

          szlMillimeters.cx := Round( DstmmSize.X*VisPixSize.X/DstPixSize.X );
          szlMillimeters.cy := Round( DstmmSize.Y*VisPixSize.Y/DstPixSize.Y );

          rclFrame.Right  := Round( DstmmSize.X*VisPixSize.X/DstPixSize.X * 100  );
          rclFrame.Bottom := Round( DstmmSize.Y*VisPixSize.Y/DstPixSize.Y * 100 );
        end; // with PEnhMetaHeader(@MEEMFBuf[0])^ do // update EMF Size in mm

{$IFDEF VER150} // Delphi 7
        NewHEMF := SetEnhMetaFileBits( EMFContentSize, PChar(@MEEMFBuf[0]) );
{$ELSE}         // Delphi XE2 or Delphi 2010
        NewHEMF := SetEnhMetaFileBits( EMFContentSize, PByte(@MEEMFBuf[0]) );
{$ENDIF VER150}

        if UseClipboard then // Save to Clipboard
        begin
          if OpenClipboard( N_ButtonsForm.Handle ) then // Clipboard is not locked
          begin
            EmptyClipboard();
            SetClipboardData( CF_ENHMETAFILE, NewHEMF );
            CloseClipboard();
//              N_CreateFile1( Format( 'C:\aa%d.emf', [N_MEGlobObj.GlobCounter]), [ftfWritePlain], @MEEMFBuf[0], EMFContentSize ); // debug
//            N_b := DeleteEnhMetaFile( NewHEMF ); // deleting is error?
//            Assert( N_b, 'BadHEMF!' );
          end else // Clipboard is locked by another application
          begin
            // How to react?
          end; // else // Clipboard is locked by another application
        end else //**************** Save to File
        begin
          K_DFWriteAll( GCMainFileName, K_DFCreatePlain, @MEEMFBuf[0], EMFContentSize );
          N_b := DeleteEnhMetaFile( NewHEMF ); // deleting is error?
          Assert( N_b, 'BadHEMF!' );
        end;
      end; // with N_MEGlobObj do // set EMF Size in mm by DstmmSize

{ old var
      if UseClipboard then // Save to Clipboard
        N_CopyMetafileToClipBoard( DstMetaFile )
      end else //**************** Save to File
        DstMetaFile.SaveToFile( GCMainFileName );
}

    end else if (DstOCanv.OCanvType = octOwnRaster) or
                (DstOCanv.OCanvType = octRFrameRaster) then // Raster
    begin
      if GCExpParams.EPImageExpMode <> iemJustDraw then // Save to Clipboard or to File
      begin
        // temporary create BMP Obj, later use RasterObj

        TmpBMP := TBitmap.Create;
        TmpBMP.Width  := VisPixSize.X;
        TmpBMP.Height := VisPixSize.Y;
        TmpBMP.PixelFormat := IFPPixFmt;

        N_CopyRect( TmpBMP.Canvas.Handle, Point(0,0), DstOCanv.HMDC, VisPixRect );

        if UseClipboard then // Copy To Clipboard
          N_CopyBMPToClipboard( TmpBMP )
        else //**************** Save to File
          N_SaveBMPObjToFile( TmpBMP, GCMainFileName, @GCExpParams.EPImageFPar );

        TmpBMP.Free;
      end; // if GCExpParams.EPImageExpMode <> iemJustDraw then // Save to Clipboard or to File
    end; // else - Raster
    goto Fin;
  end; // if cefGDIFile in GCExpFlags then // Save Created Picture To File


  //***************** Finish Exporting to Text (HTML, SVG, ...) File

  if cefTextFile in GCExpFlags then // Save Created Text To File
  with GCExpParams do
  begin

    if GCOutLabelInd >= 0 then // Label Row exists
    begin
      for i := GCOutLabelInd+1 to GCPatternSL.Count-1 do // copy end part of Pattern File
        GCOutSL.Add( GCPatternSL[i] );
    end;

    Ind := GCOutSL.IndexOf( '<<PlaceForStyle>>' );

    if Ind >= 0 then // Place for Style Section was reserved
    begin
      GCOutSL.Strings[Ind] := GCOutStyleSL.Text;
    end; // if Ind >= 0 then // Place for Style Section was reserved

    if EPMainFName <> '' then
    begin
//      GCMainFileName := K_ExpandFileName( EPMainFName );
      GCOutSL.SaveToFile( GCMainFileName );
    end;

    goto Fin;
  end; // if cefTextFile in GCExpFlags then // Save Created Text To File


  Fin: //*******************
  GCOwnerForm := nil; // to avoid refs to destroyed objects
  Screen.Cursor := GCSavedCursor;
  GCShowResponse( 'Exporting ' + ExtractFileName(GCMainFileName) + ' finished' );

  if epefShowTime in GCExpParams.EPExecFlags then // show Time
  begin
    GCTimerFin.Stop();
    GCTimerFull.Stop();

    GCTimerFin.Show( ExtractFileName(GCMainFileName) + ' finishing' );
    GCTimerFull.SS( ExtractFileName(GCMainFileName) + ' creation' );
    N_IAdd( '' ); // delimeter row
  end; // if epefShowTime in GCExpParams.EPExecFlags then // show Time

//  if not (cbfSkipResponse in TN_UDCompBase(GCRootComp).PDP()^.CCompBase.CBFlags1) then
//    GCShowResponse( ExtractFileName(GCMainFileName) + ' Exported OK' );
end; // procedure TN_GlobCont.FinishExport

//**********************************************  TN_GlobCont.RunWordMacro  ***
// Run MS Word Macro with given Delphi or VBA AMacroName
//
procedure TN_GlobCont.RunWordMacro( AName: string );
var
  NameInd: integer;
  MSMacroName: string;
begin
  NameInd := GCMSWordMacros.IndexOfName( AName );

  if NameInd >= 0 then // AName exists in GCMSWordMacros List
    MSMacroName := GCMSWordMacros.ValueFromIndex[NameInd]
  else //**************** AName is direct VBA Name
    MSMacroName := AName;

  if MSMacroName <> '' then
    GCWordServer.Run( MSMacroName );
end; // procedure TN_GlobCont.RunWordMacro

//*********************************************  TN_GlobCont.RunExcelMacro  ***
// Run MS Excel Macro with given Delphi or VBA AMacroName
//
procedure TN_GlobCont.RunExcelMacro( AName: string );
var
  MSMacroName: string;
begin
  MSMacroName := GCMSExcelMacros.Values[AName];
  if MSMacroName <> '' then
    GCExcelServer.Run( MSMacroName );
end; // procedure TN_GlobCont.RunExcelMacro

//************************************************* TN_GlobCont.ExecuteComp ***
// Execute given AComp in current context (in current state of it) as SubTree Root
// (AComp should be TN_UDCompBase type, TObject is used to avoid circular unit reference)
//
procedure TN_GlobCont.ExecuteComp( AComp: TObject; AInitFlags: TN_CompInitFlags );
var
  SavedGCont: TN_GlobCont;
  DoInit: boolean;
begin
  if not (AComp is TN_UDCompBase) then Exit; // a precaution

  with TN_UDCompBase(AComp) do
  begin
    SavedGCont := NGCont;
    NGCont     := Self;

    DoInit := True;
    if epefInitByComp in GCExpParams.EPExecFlags then
    begin
      if not (cbfInitSubTree in PDP()^.CCompBase.CBFlags1) then
        DoInit := False;
    end; // if epefInitByComp in EPExecFlags then

    if DoInit then InitSubTree( AInitFlags );

    if cifRootComp in AInitFlags then
      CRTFlags := [crtfRootComp]; // Self is Root Component flag

    ExecSubTree();

    if DoInit then FinSubTree();

    NGCont := SavedGCont; // restore
  end; // with TN_UDCompBase(AComp) do
end; // procedure TN_GlobCont.ExecuteComp

//******************************************** TN_GlobCont.ExecuteRootComp ***
// Prepare Self and Execute given AComp by Self.ExecuteComp method
// (AComp should be TN_UDCompBase type, TObject is used to avoid circular unit reference)
//
procedure TN_GlobCont.ExecuteRootComp( AComp: TObject; AInitFlags: TN_CompInitFlags;
                                   AShowResponse: TN_OneStrProcObj;
                                   AOwner: TN_BaseForm; APExpParams: TN_PExpParams;
                                   ABackColor: integer );
begin
  if Assigned(AShowResponse) then
  begin
    GCShowResponseProc := AShowResponse;
    AShowResponse( '' ); // clear response string
  end;

  GCOwnerForm := AOwner;
  PrepForExport( AComp, APExpParams );

//  SetStretchBltMode( DstOCanv.HMDC, HALFTONE );
  DstOCanv.ClearSelfByColor ( ABackColor );

  if GCRootComp is TN_UDCompBase then // a precaution
  begin
    ExecuteComp( AComp, AInitFlags + [cifRootComp] );
    FinishExport();
  end;

  GCOwnerForm := nil;
end; // procedure TN_GlobCont.ExecuteRootComp

//****************************************** TN_GlobCont.DrawCPanel(RArray) ***
// Draw given CPanel RArray in given ABasePixRect (External or Internal) and
// return CPanel Output (Internal or External) Rect in Pixel Coords
//
// Add later consequent drawing several Border Rects with different attributes
// and, may be, gradient or 3D filled borders
//
function TN_GlobCont.DrawCPanel( ARCPanel: TK_RArray; ABasePixRect: TRect ): TRect;
var
  SideRect: TRect;
  PixXYRads: TPoint;
  SideAttribs: TN_SideAttribs;
  PCPanel: TN_PCPanel;
  i : Integer;
begin
  Result := ABasePixRect;
  if ARCPanel = nil then Exit; // Empty panel
  if ARCPanel.ElemSType <> N_SPLTC_CPanel then Exit; // a precaution

  for i := ARCPanel.AHigh downto 0 do
  begin
    PCPanel := TN_PCPanel(ARCPanel.P(i));

    with PCPanel^, SideAttribs do
    begin
      Result := GetCPanelIntRect( PCPanel, ABasePixRect, @SideAttribs );

      if PaSideParams = nil then // individual Side Params are not given
      begin
        if SAPixBorderWidth = 0 then // no Border
          DrawFilledPixRect( SAFillRect, PaBackColor )
        else //****************** Border exists
        begin
          with Result do
            MSParentPixXYSize := FPoint( 0.5*(Right-Left), 0.5*(Bottom-Top) );

          PixXYRads   := ConvMSToPix( PaRoundXYRads );
          DrawPixRoundRect( SAFillRect, PixXYRads, PaBackColor,
                                                   PaBorderColor, PaBorderWidth );
        end;
      end else //****************** Draw individual Side Params
      begin

        if SALeftPixWidth > 0 then //***** Draw Left Side
        begin
          SideRect := SAFillRect;
          SideRect.Right := SideRect.Left + SALeftPixWidth - 1;

          if SALeftPixWidth < SATopPixWidth then
            SideRect.Top := SideRect.Top + SATopPixWidth;

          if SALeftPixWidth < SABotPixWidth then
            SideRect.Bottom := SideRect.Bottom - SABotPixWidth;

          DrawFilledPixRect( SideRect, SALeftColor );
        end; // if SALeftPixWidth > 0 then //***** Draw Left Side

        if SATopPixWidth > 0 then //***** Draw Top Side
        begin
          SideRect := SAFillRect;
          SideRect.Bottom := SideRect.Top + SATopPixWidth - 1;

          if SATopPixWidth < SALeftPixWidth then
            SideRect.Left := SideRect.Left + SALeftPixWidth;

          if SATopPixWidth < SARightPixWidth then
            SideRect.Right := SideRect.Right - SARightPixWidth;

          DrawFilledPixRect( SideRect, SATopColor );
        end; // SATopPixWidth > 0 then //***** Draw Top Side

        if SARightPixWidth > 0 then //***** Draw Right Side
        begin
          SideRect := SAFillRect;
          SideRect.Left := SideRect.Right - SALeftPixWidth + 1;

          if SARightPixWidth < SATopPixWidth then
            SideRect.Top := SideRect.Top + SATopPixWidth;

          if SARightPixWidth < SABotPixWidth then
            SideRect.Bottom := SideRect.Bottom - SABotPixWidth;

          DrawFilledPixRect( SideRect, SARightColor );
        end; // if SARightPixWidth > 0 then //***** Draw Right Side

        if SABotPixWidth > 0 then //***** Draw Bottom Side
        begin
          SideRect := SAFillRect;
          SideRect.Top := SideRect.Bottom - SABotPixWidth + 1;

          if SABotPixWidth < SALeftPixWidth then
            SideRect.Left := SideRect.Left + SALeftPixWidth;

          if SABotPixWidth < SARightPixWidth then
            SideRect.Right := SideRect.Right - SARightPixWidth;

          DrawFilledPixRect( SideRect, SABotColor );
        end; // SATopPixWidth > 0 then //***** Draw Bottom Side

       end; // else //****************** Draw individual Side Params

    end; // with TN_PCPanel(ACPanel.P())^, SideAttribs do
  end; // Panels Loop
end; // function TN_GlobCont.DrawCPanel(RArray)

//****************************************** TN_GlobCont.DrawCPanel(CPanel) ***
// Draw given CPanel in given ABasePixRect (External or Internal) and
// return CPanel Output (Internal or External) Rect in Pixel Coords
//
function TN_GlobCont.DrawCPanel( APCPanel: TN_PCPanel; ABasePixRect: TRect;
                                                    ADefColor: integer ): TRect;
var
  FillColor, BorderColor: integer;
  SideRect: TRect;
  PixXYRads: TPoint;
  SideAttribs: TN_SideAttribs;
begin
  Result := GetCPanelIntRect( APCPanel, ABasePixRect, @SideAttribs );

  with APCPanel^, SideAttribs do
  begin

    FillColor := PaBackColor;
    if (ADefColor <> N_CurColor) and (FillColor = N_CurColor) then
      FillColor := ADefColor;

    BorderColor := PaBorderColor;
    if (ADefColor <> N_CurColor) and (BorderColor = N_CurColor) then
      BorderColor := ADefColor;

    if PaSideParams = nil then // individual Side Params are not given
    begin
      if SAPixBorderWidth = 0 then // no Border
        DrawFilledPixRect( SAFillRect, FillColor )
      else //****************** Border eixists
      begin
        PixXYRads   := ConvMSToPix( PaRoundXYRads );
        DrawPixRoundRect( SAFillRect, PixXYRads, FillColor,
                                                 BorderColor, PaBorderWidth );
      end;
    end else //****************** Draw individual Side Params
    begin

      if SALeftPixWidth > 0 then //***** Draw Left Side
      begin
        SideRect := SAFillRect;
        SideRect.Right := SideRect.Left + SALeftPixWidth - 1;

        if SALeftPixWidth < SATopPixWidth then
          SideRect.Top := SideRect.Top + SATopPixWidth;

        if SALeftPixWidth < SABotPixWidth then
          SideRect.Bottom := SideRect.Bottom - SABotPixWidth;

        DrawFilledPixRect( SideRect, SALeftColor );
      end; // if SALeftPixWidth > 0 then //***** Draw Left Side

      if SATopPixWidth > 0 then //***** Draw Top Side
      begin
        SideRect := SAFillRect;
        SideRect.Bottom := SideRect.Top + SATopPixWidth - 1;

        if SATopPixWidth < SALeftPixWidth then
          SideRect.Left := SideRect.Left + SALeftPixWidth;

        if SATopPixWidth < SARightPixWidth then
          SideRect.Right := SideRect.Right - SARightPixWidth;

        DrawFilledPixRect( SideRect, SATopColor );
      end; // SATopPixWidth > 0 then //***** Draw Top Side

      if SARightPixWidth > 0 then //***** Draw Right Side
      begin
        SideRect := SAFillRect;
        SideRect.Left := SideRect.Right - SALeftPixWidth + 1;

        if SARightPixWidth < SATopPixWidth then
          SideRect.Top := SideRect.Top + SATopPixWidth;

        if SARightPixWidth < SABotPixWidth then
          SideRect.Bottom := SideRect.Bottom - SABotPixWidth;

        DrawFilledPixRect( SideRect, SARightColor );
      end; // if SARightPixWidth > 0 then //***** Draw Right Side

      if SABotPixWidth > 0 then //***** Draw Bottom Side
      begin
        SideRect := SAFillRect;
        SideRect.Top := SideRect.Bottom - SABotPixWidth + 1;

        if SABotPixWidth < SALeftPixWidth then
          SideRect.Left := SideRect.Left + SALeftPixWidth;

        if SABotPixWidth < SARightPixWidth then
          SideRect.Right := SideRect.Right - SARightPixWidth;

        DrawFilledPixRect( SideRect, SABotColor );
      end; // SATopPixWidth > 0 then //***** Draw Bottom Side

     end; // else //****************** Draw individual Side Params

  end; // with TN_PCPanel(ACPanel.P())^, SideAttribs do
end; // function TN_GlobCont.DrawCPanel(CPanel)


//************************************ TN_GlobCont.GetCPanelIntRect(RArray) ***
// Return CPanel Internal Rect in Pixel Coords by given AOuterPixRect and
// if APSideAttribs <> nil return individual Side Attributes
//
function TN_GlobCont.GetCPanelIntRect( ARCPanel: TK_RArray; AOuterPixRect: TRect;
                                        APSideAttribs: TN_PSideAttribs ): TRect;
var
  PixMargins, PixPaddings: TRect;
  SideAttribs: TN_SideAttribs;

  procedure GetSideAttribs( ASideInd: integer; out ASideColor: integer;
                                               out ASidePixWidth: integer ); // local
  var
    CurColor: integer;
    CurWidth: float;
    IsGiven: boolean;

  begin
    with TN_PCPanel(ARCPanel.P())^, APSideAttribs^ do
    begin
      CurColor := -2;
      CurWidth := -2;
      IsGiven := PaSideParams.AHigh() >= ASideInd;
      if IsGiven then
      with TN_PCPanelSide(PaSideParams.P(ASideInd))^ do
      begin
        CurColor := PaSBorderColor;
        CurWidth := PaSBorderWidth;
      end; // if IsGiven then

      if CurColor = -2 then CurColor := PaBorderColor;
      if CurColor = N_EmptyColor then CurWidth := -1;
      if CurWidth = -2 then CurWidth := PaBorderWidth;

      ASideColor := CurColor;
      if CurWidth >= 0 then ASidePixWidth := DstOCanv.LLWToPix1( CurWidth )
                       else ASidePixWidth := 0;
    end; // with TN_PCPanel(ARCPanel.P())^, APSideAttribs^ do
  end; // procedure GetSideAttribs - local

begin //****************************** body of TN_GlobCont.GetCPanelIntRect
  if ARCPanel = nil then // Empty panel
  begin
    Result := AOuterPixRect;
    Exit; // all done
  end;

  if APSideAttribs = nil then APSideAttribs := @SideAttribs;
  FillChar( APSideAttribs^, SizeOf(APSideAttribs^), 0 );

  with TN_PCPanel(ARCPanel.P())^, APSideAttribs^ do
  begin
    PixMargins  := ConvMSToPix( PaMargins );
    PixPaddings := ConvMSToPix( PaPaddings );

    if PaBorderColor = N_EmptyColor then
      SAPixBorderWidth := 0
    else
      SAPixBorderWidth := DstOCanv.LLWToPix1( PaBorderWidth );

      SAFillRect := Rect( AOuterPixRect.Left   + PixMargins.Left,
                          AOuterPixRect.Top    + PixMargins.Top,
                          AOuterPixRect.Right  - PixMargins.Right,
                          AOuterPixRect.Bottom - PixMargins.Bottom );

    if PaSideParams <> nil then // Process individual Side Params
    begin
      //***** prepare individual Pix Widths and Colors for all Sides

      GetSideAttribs( 0, SALeftColor,  SALeftPixWidth );
      GetSideAttribs( 1, SATopColor,   SATopPixWidth );
      GetSideAttribs( 2, SARightColor, SARightPixWidth );
      GetSideAttribs( 3, SABotColor,   SABotPixWidth );

      Result := Rect( SAFillRect.Left   + SALeftPixWidth  + PixPaddings.Left,
                      SAFillRect.Top    + SATopPixWidth   + PixPaddings.Top,
                      SAFillRect.Right  - SARightPixWidth + PixPaddings.Right,
                      SAFillRect.Bottom - SABotPixWidth   + PixPaddings.Bottom );

    end else // Individual Side Params are not given
    begin
      Result := Rect( SAFillRect.Left   + SAPixBorderWidth + PixPaddings.Left,
                      SAFillRect.Top    + SAPixBorderWidth + PixPaddings.Top,
                      SAFillRect.Right  - SAPixBorderWidth - PixPaddings.Right,
                      SAFillRect.Bottom - SAPixBorderWidth - PixPaddings.Bottom );
    end;

  end; // with TN_PCPanel(ACPanel.P())^, APSideAttribs^ do
end; // function TN_GlobCont.GetCPanelIntRect(RArray)

//************************************ TN_GlobCont.GetCPanelIntRect(CPanel) ***
// Return CPanel Internal Rect in Pixel Coords by given AOuterPixRect and
// if APSideAttribs <> nil return individual Side Attributes
//
function TN_GlobCont.GetCPanelIntRect( APCPanel: TN_PCPanel; AOuterPixRect: TRect;
                                        APSideAttribs: TN_PSideAttribs ): TRect;
var
  PixMargins, PixPaddings: TRect;
  SideAttribs: TN_SideAttribs;

  procedure GetSideAttribs( ASideInd: integer; out ASideColor: integer;
                                               out ASidePixWidth: integer ); // local
  var
    CurColor: integer;
    CurWidth: float;
    IsGiven: boolean;

  begin
    with APCPanel^, APSideAttribs^ do
    begin
      CurColor := -2;
      CurWidth := -2;
      IsGiven := PaSideParams.AHigh() >= ASideInd;
      if IsGiven then
      with TN_PCPanelSide(PaSideParams.P(ASideInd))^ do
      begin
        CurColor := PaSBorderColor;
        CurWidth := PaSBorderWidth;
      end; // if IsGiven then

      if CurColor = -2 then CurColor := PaBorderColor;
      if CurColor = N_EmptyColor then CurWidth := -1;
      if CurWidth = -2 then CurWidth := PaBorderWidth;

      ASideColor := CurColor;
      if CurWidth >= 0 then ASidePixWidth := DstOCanv.LLWToPix1( CurWidth )
                       else ASidePixWidth := 0;
    end; // with TN_PCPanel(ACPanel.P())^, APSideAttribs^ do
  end; // procedure GetSideAttribs - local

begin //****************************** body of TN_GlobCont.GetCPanelIntRect
  if APSideAttribs = nil then APSideAttribs := @SideAttribs;
  FillChar( APSideAttribs^, SizeOf(APSideAttribs^), 0 );

  with APCPanel^, APSideAttribs^ do
  begin
    PixMargins  := ConvMSToPix( PaMargins );
    PixPaddings := ConvMSToPix( PaPaddings );

//    if PaBorderColor = N_EmptyColor then
//      SAPixBorderWidth := 0
//    else
      SAPixBorderWidth := DstOCanv.LLWToPix1( PaBorderWidth );

      SAFillRect := Rect( AOuterPixRect.Left   + PixMargins.Left,
                          AOuterPixRect.Top    + PixMargins.Top,
                          AOuterPixRect.Right  - PixMargins.Right,
                          AOuterPixRect.Bottom - PixMargins.Bottom );

    if PaSideParams <> nil then // Process individual Side Params
    begin
      //***** prepare individual Pix Widths and Colors for all Sides

      GetSideAttribs( 0, SALeftColor,  SALeftPixWidth );
      GetSideAttribs( 1, SATopColor,   SATopPixWidth );
      GetSideAttribs( 2, SARightColor, SARightPixWidth );
      GetSideAttribs( 3, SABotColor,   SABotPixWidth );

      Result := Rect( SAFillRect.Left   + SALeftPixWidth  + PixPaddings.Left,
                      SAFillRect.Top    + SATopPixWidth   + PixPaddings.Top,
                      SAFillRect.Right  - SARightPixWidth + PixPaddings.Right,
                      SAFillRect.Bottom - SABotPixWidth   + PixPaddings.Bottom );

    end else // Individual Side Params are not given
    begin
      Result := Rect( SAFillRect.Left   + SAPixBorderWidth + PixPaddings.Left,
                      SAFillRect.Top    + SAPixBorderWidth + PixPaddings.Top,
                      SAFillRect.Right  - SAPixBorderWidth - PixPaddings.Right,
                      SAFillRect.Bottom - SAPixBorderWidth - PixPaddings.Bottom );
    end;

  end; // with TN_PCPanel(ACPanel.P())^, APSideAttribs^ do
end; // function TN_GlobCont.GetCPanelIntRect(CPanel)

//********************************************** TN_GlobCont.DebAddDocsInfo ***
// Debug Actions:
//   AMode=0 - Add Info about currently opened Documents
//
procedure TN_GlobCont.DebAddDocsInfo( AHeader: string; AMode: integer );
var
  i, NumDocs, IsSaved: integer;
  BufStr, DocName, FullName: string;
  Docs, Doc: Variant;
begin
  N_IAdd( AHeader );

  if not VarIsEmpty( GCWordServer ) then
  begin
    if AMode = 0 then // List of all docs
    begin
      Docs := GCWordServer.Documents;
      NumDocs := Docs.Count;

      if NumDocs = 0 then
        N_IAdd( '  No Documents' );

      for i := 1 to NumDocs do
      begin
        Doc := Docs.Item(i);
        DocName := Doc.Name;
        FullName := Doc.FullName;
        IsSaved := integer(Doc.Saved);
        BufStr := Format( '  %d) Doc:%s, Saved:%d, Full:%s', [i,DocName,IsSaved,FullName] );
        N_IAdd( BufStr );
      end; // for i := 1 to NumDocs do
    end; // if AMode = 0 then
  end; // if Assigned(GCWordServer) then
end; // procedure TN_GlobCont.DebAddDocsInfo

//*********************************************** TN_GlobCont.GCShowString ***
// Show Given String in appropriate StatusBar and add it to Protocol if needed
//
procedure TN_GlobCont.GCShowString( AStr: string );
begin
  N_StateString.Show( Astr );
end; // procedure TN_GlobCont.GCShowString

//******************************************** TN_GlobCont.GCAddToProtocol ***
// Add Given String to Protocol
//
procedure TN_GlobCont.GCAddToProtocol( AStr: string );
begin
  N_StateString.Protocol.Add( AStr );
end; // procedure TN_GlobCont.GCAddToProtocol


{ //***** Pattern Code
//******************************************** TN_GlobCont.DrawPattern ***
// Fill given APixRect by given AFillColor
//
procedure TN_GlobCont.DrawPattern( APixRect: TRect; AFillColor: integer );
begin
  if DstImageType = ditWinGDI then // draw to OCanv
  begin
// Draw to Raster
  end else if DstImageType = ditVML then // draw to VML
  begin
//    DrawToVML
  end else if DstImageType = ditSVG then // draw to SVG
  begin
//    DrawToSVG
  end else if DstImageType = ditJS then // draw to JS
  begin
//    DrawToJS
  end else if DstImageType = ditText then // draw to Text (create dump text)
  begin
//    DrawToText
  end;
end; // procedure TN_GlobCont.DrawPattern
}


    //************************  VML oriented methods  **********

//******************************************** TN_GlobCont.AddHTMLHeader ***
// Add to GCOutSL all HTML header before Style tag
//
procedure TN_GlobCont.AddHTMLHeader( ATitle: string );
begin
  with GCOutSL do
  begin
    Add( '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' );
    Add( '<html><head><title>' + ATitle + '</title>' );
  end;
end; // procedure TN_GlobCont.AddHTMLHeader

//******************************************** TN_GlobCont.VMLAddHTMLHeader ***
// Add to GCOutSL all needed by VML HTML code before top-level group
//
procedure TN_GlobCont.VMLAddHTMLHeader();
begin
  with GCOutSL do
  begin
    Add( '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' );
    Add( '<html xmlns:v="urn:schemas-microsoft-com:vml">' );
    Add( '<head><style>v\:* {behavior:url(#default#VML);}</style>' );
    Add( '<title>Test VML</title></head><body>' );
  end;
end; // procedure TN_GlobCont.VMLAddHTMLHeader

//******************************************** TN_GlobCont.VMLAddTopLevelGroup ***
// Add to GCOutSL top-level group open tag
//
procedure TN_GlobCont.VMLAddTopLevelGroup();
begin
  with GCOutSL do
  begin
    Add( Format(
          '<v:group style=''width:%.1fmm;height:%.1fmm'' coordsize="%d,%d" >',
                    [DstmmSize.X, DstmmSize.Y, DstPixSize.X, DstPixSize.Y] ) );
  end;
end; // procedure TN_GlobCont.VMLAddTopLevelGroup

//*********************************************** TN_GlobCont.VMLPos ***
// Return Style integer Pos and Size elements
//
function TN_GlobCont.VMLPos( ARect: TRect ): string;
begin
  with ARect do
    Result := Format( 'left:%d;top:%d;width:%d;height:%d;',
                           [Left, Top, Right-Left+1, Bottom-Top+1] );
end; // function TN_GlobCont.VMLPos

//*********************************************** TN_GlobCont.VMLPos ***
// Return Style float Pos and Size elements
//
function TN_GlobCont.VMLPos( ARect: TFRect ): string;
begin
  with ARect do
    Result := Format( 'left:%.1f;top:%.1f;width:%.1f;height:%.1f;',
                           [Left, Top, Right-Left, Bottom-Top] );
end; // function TN_GlobCont.VMLPos

//*********************************************** TN_GlobCont.VMLPenBrush ***
// Return Pen and Brush attributes
//
function TN_GlobCont.VMLPenBrush( ABrushColor, APenColor: integer; APenWidth: float ): string;
var
  Stroke, Fill: string;
begin
  if ABrushColor = N_EmptyColor then
    Fill := 'fill="f" '
  else
    Fill := 'fillcolor=' + N_ColorToQHTMLHex( ABrushColor ) + ' ';

  if APenColor = N_EmptyColor then
    Stroke := 'stroked="f"'
  else
    Stroke := Format( 'strokeweight="%.2fpt" strokecolor=', [APenWidth] ) +
                                          N_ColorToQHTMLHex( APenColor );
  Result := Fill + Stroke;
end; // function TN_GlobCont.VMLPenBrush


//*********************************************** TN_GlobCont.DrawToVML ***
// Draw GCRootComp to VML (Export to VML - add needed strings to GCOutSL)
//
procedure TN_GlobCont.DrawToVML();
begin
  VMLAddHTMLHeader();
  VMLAddTopLevelGroup();
  DrawRootComp( VisPixRect );

  GCOutSL.Add( '</v:group></body></html>' );
end; // procedure TN_GlobCont.DrawToVML

{
//*********************************************** TN_GlobCont.DrawToEMF ***
// Draw GCRootComp to EMF
//
procedure TN_GlobCont.DrawToEMF();
var
  DstMFCanvas: TMetafileCanvas;
  SavedHMDC: HDC;
//  MFHeader: ENHMETAHEADER; // for debug
begin
  DstMetaFile.Free;
  DstMetaFile := TMetaFile.Create;

  with DstMetaFile do
  begin                     // MMWidth, MMHeight would be calculated by Delphi:
    Width  := DstPixSize.X; // MMWidth := MulDiv( Value,    // metafile width in pixels
    Height := DstPixSize.Y; //   EMFHeader.szlMillimeters.cx*100, // device width in mm
  end;                      //   EMFHeader.szlDevice.cx );    // device width in pixels 

  DstMFCanvas := TMetafileCanvas.Create( DstMetaFile, 0 ); // Graphics 4000
//  GetEnhMetaFileHeader( DstMetaFile.Handle, Sizeof(MFHeader), @MFHeader ); // debug

  SavedHMDC := DstOCanv.HMDC;
  DstOCanv.HMDC := DstMFCanvas.Handle;
  DstOCanv.InitOCanv();

  DrawRootComp( VisPixRect );
//  N_TstGr1Metafile_6( Self );

  DstMFCanvas.Free; // move created Image from DstMFCanvas to DstMetaFile
//  GetEnhMetaFileHeader( DstMetaFile.Handle, Sizeof(MFHeader), @MFHeader ); // debug

  DstOCanv.HMDC := SavedHMDC;
end; // procedure TN_GlobCont.DrawToEMF
}

    //*********** Global Procedures  *****************************

//*********************************************** N_AddHTMLFragm ***
// Add to AHTML Fragment of given type
//
procedure N_AddHTMLFragm( AHTML: TStrings; AFragmType: TN_HTMLFragmType1 );
begin
  with AHTML do
  case AFragmType of

  htmltBeg: begin
    Add( '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' );
    Add( '<html><head><title> Test HTML</title></head><body>' );
  end; // htmlBeg: begin

  htmltPara: begin
    Add( '<p>Sample Paragraph</p>' );
  end; // htmlPara: begin

  htmltEnd: begin
    Add( '</body></html>' );
  end; // htmlEnd: begin

  end; // case AFragmType of
end; // procedure N_AddHTMLFragm

//*********************************************** N_AddHTMLFragm2 ***
// Add to AHTML Fragment of given type
//
procedure N_AddHTMLFragm2( AHTML: TStrings; AFragmType: TN_HTMLFragmType2;
                                                     ANx, ANy: integer );
begin
  with AHTML do
  case AFragmType of

  htmltDivNxNy: begin
    Add( '<div S>' );
  end; // htmlBeg: begin


  end; // case AFragmType of
end; // procedure N_AddHTMLFragm2

//************************************************ N_CreateColorRects ***
// Create ACRects - Color Rects from AOPCRows - given Array of OPCRows (One Pixel Color Rows),
// (resulting Color Rects in ACRects are ordered by CRCode),
// return number of created Elements in ACRects
//
function N_CreateColorRects( AOPCRows: TN_OPCRowArray; ANumOPCRows: integer;
                                       var ACRects: TN_CRectArray ): integer;
var
  i, FreeInd, CurMinLeft, CurMaxLeft, CurMinRight, CurMaxRight, CurTop: integer;
  SPtrs: TN_PArray;

//************************ Local functions:
//  function  CrossIntervals ( L1, R1, L2, R2: integer; out NewL, NewR: integer ): boolean;
//  function  AddCurOPCRow (): boolean; // local
//  procedure BeginNewRect (); // local
//  procedure AddCurRect (); // local

  function CrossIntervals( L1, R1, L2, R2: integer; out NewL, NewR: integer ): boolean;
  // Cacl (NewL,NewR) = (L1,R1) and (L2,R2) return True if NewL <= NewR
  begin
    NewL := Max( L1, L2 );
    NewR := Min( R1, R2 );
    Result := NewL <= NewR;
  end; // function CrossIntervals // local

  function AddCurOPCRow(): boolean; // local
  // update Cur Interval by current OPCRow if possible, return True if OK
  var
    NewMinLeft, NewMaxLeft, NewMinRight, NewMaxRight: integer;
    LeftOk, RightOK: boolean;
  begin
    with TN_POPCRow(SPtrs[i])^ do
    begin

      LeftOk := CrossIntervals( CurMinLeft, CurMaxLeft,
                            OPCRMinLeft, OPCRMaxLeft, NewMinLeft, NewMaxLeft );

      RightOk := CrossIntervals( CurMinRight, CurMaxRight,
                        OPCRMinRight, OPCRMaxRight, NewMinRight, NewMaxRight );

    end; // with TN_POPCRow(SPtrs[i])^ do

    Result := LeftOk and RightOk;
    if Result then // Update Cur Interval
    begin
      CurMinLeft  := NewMinLeft;
      CurMaxLeft  := NewMaxLeft;
      CurMinRight := NewMinRight;
      CurMaxRight := NewMaxRight;
    end;
  end; // function AddCurOPCRow(): boolean; // local

  procedure InitCurInterval(); // local
  // Initialize Cur Interval by current OPCRow
  begin
    with TN_POPCRow(SPtrs[i])^ do
    begin
      CurTop      := OPCRY;
      CurMinLeft  := OPCRMinLeft;
      CurMaxLeft  := OPCRMaxLeft;
      CurMinRight := OPCRMinRight;
      CurMaxRight := OPCRMaxRight;
    end; // with TN_POPCRow(SPtrs[i])^ do
  end; // procedure BeginNewInterval(); // local

  procedure AddNewRect(); // local
  // Create New Rect by Cur Interval and add it to ACRects array
  begin
    if Length(ACRects) <= FreeInd then
      SetLength( ACRects, N_Newlength( FreeInd ) );

    with TN_POPCRow(SPtrs[i-1])^ do
    begin
      if OPCRCode >= 254 then Exit;
      ACRects[FreeInd].CRCode := OPCRCode;
      ACRects[FreeInd].CRect := Rect( CurMaxLeft, CurTop, CurMinRight, OPCRY );
    end;

    Inc(FreeInd);
  end; // procedure AddNewRect(); // local

begin //************************************** main body of N_CreateColorRects

  //***** Sort Pointers by Code, Y and MaxLeft
  SPtrs := N_GetSortedPointers( @AOPCRows[0], ANumOPCRows,
                                sizeof(AOPCRows[0]), 0, N_Compare4Ints );

  //***** Calc OPCRXInd field in all AOPCRows elements
  //      (now for all OPCRows XInd = 0, XInd=-1 means that OPCRow is not needed)

  for i := 1 to ANumOPCRows-1 do // along sorted (by Code,Y,MaxLeft) OPCRows
  begin
    if (TN_POPCRow(SPtrs[i-1])^.OPCRY    <> TN_POPCRow(SPtrs[i])^.OPCRY) or
       (TN_POPCRow(SPtrs[i-1])^.OPCRCode <> TN_POPCRow(SPtrs[i])^.OPCRCode) then
      Continue; // XInd is already = 0

    if (TN_POPCRow(SPtrs[i-1])^.OPCRMinLeft  = TN_POPCRow(SPtrs[i])^.OPCRMinLeft) and
       (TN_POPCRow(SPtrs[i-1])^.OPCRMaxRight = TN_POPCRow(SPtrs[i])^.OPCRMaxRight)  then
    begin // OPCRows overlaps, exclude (i-1)-th and update i-th OPCRow
      TN_POPCRow(SPtrs[i])^.OPCRXInd := TN_POPCRow(SPtrs[i-1])^.OPCRXInd;
      TN_POPCRow(SPtrs[i-1])^.OPCRCode := MaxInt; // set "not needed" flag

      TN_POPCRow(SPtrs[i])^.OPCRMaxLeft := Min(
        TN_POPCRow(SPtrs[i-1])^.OPCRMaxLeft, TN_POPCRow(SPtrs[i])^.OPCRMaxLeft );

      TN_POPCRow(SPtrs[i])^.OPCRMinRight := Max(
        TN_POPCRow(SPtrs[i-1])^.OPCRMinRight, TN_POPCRow(SPtrs[i])^.OPCRMinRight );
    end else // OPCRows are separate
      TN_POPCRow(SPtrs[i])^.OPCRXInd := TN_POPCRow(SPtrs[i-1])^.OPCRXInd + 1;
  end; // for i := 1 to ANumOPCRows-1 do // along sorted (by Code,Y,MaxLeft) OPCRows

  //***** Sort Pointers by Code, XInd and Y
  SPtrs := N_GetSortedPointers( @AOPCRows[0], ANumOPCRows,
                                sizeof(AOPCRows[0]), 0, N_Compare3Ints );
{
  //*** debug output:
  FASCII: TextFile;

  AssignFile( FASCII, 'c:\Delphi_Prj\N_Tree\Data\a1.txt' ); // open output ASCII file
  Rewrite( FASCII );
  WriteLn( FASCII, 'Code  XInd  Y   MinLeft MaxLeft   MinRight  MaxRight' );
  for i := 1 to ANumOPCRows-1 do // along sorted (by Code,Y,MaxLeft) OPCRows
  begin
    if (TN_POPCRow(SPtrs[i-1])^.OPCRY+1  <> TN_POPCRow(SPtrs[i])^.OPCRY) or
       (TN_POPCRow(SPtrs[i-1])^.OPCRCode <> TN_POPCRow(SPtrs[i])^.OPCRCode) then
      WriteLn( FASCII, '' );

    with TN_POPCRow(SPtrs[i])^ do
    WriteLn( FASCII, Format( '   %d   %d   %d     %d %d    %d %d',
      [OPCRCode, OPCRXInd, OPCRY, OPCRMinLeft, OPCRMaxLeft, OPCRMinRight, OPCRMaxRight]) );
  end; // for i := 1 to ANumOPCRows-1 do // along sorted (by Code,Y,MaxLeft) OPCRows
  CloseFile( FASCII );
  //*** end of debug output:
}
  FreeInd := 0; // used in AddNewRect()
  i := 0;
  InitCurInterval();

  for i := 1 to ANumOPCRows do // along sorted (by Code,XInd,Y) OPCRows
  begin
    if i = (ANumOPCRows) then // Prev OPCRow was last one, add last Rect and finish
    begin
      AddNewRect();
      Break;
    end;

    if TN_POPCRow(SPtrs[i])^.OPCRCode = MaxInt then // Skip all last OPCRows
                           // with OPCRCode = MaxInt, add last Rect and finish
    begin
      AddNewRect();
      Break;
    end;

    if (TN_POPCRow(SPtrs[i-1])^.OPCRY+1  <> TN_POPCRow(SPtrs[i])^.OPCRY) or
       (TN_POPCRow(SPtrs[i-1])^.OPCRCode <> TN_POPCRow(SPtrs[i])^.OPCRCode) then
    begin // Y is not sequential or Code is Changed
      AddNewRect();
      InitCurInterval();
      Continue; // to next OPCRow
    end;

    //***** Here: Y and Code are OK, check Left and Right intervals

    if not AddCurOPCRow() then
    begin
      AddNewRect();
      InitCurInterval();
    end;

  end; // for i := 1 to ANumOPCRows-1 do // along sorted (by Code,XInd,Y) OPCRows

  Result := FreeInd;
end; //*** function N_CreateColorRects

//************************************************ N_ConvColorRectsToJS ***
// Convert given ACRects (array of Color Rects) to JavaScript code and
// add it to given ASL ( in [ ... ] without concluding ';' )
//
procedure N_ConvColorRectsToJS( ASL: TN_SLBuf;
                                ACRects: TN_CRectArray; ANumCRects: integer );
var
  i, CurCode, PrevCode, CurY, NextY, SequenceInd: integer;
  XBeg, YBeg, DX, DY, dxLeft, dxRight: integer;
begin
  ASL.AddToken( '[');
  NextY := N_NotAnInteger;
  PrevCode := N_NotAnInteger;
  SequenceInd := -1;

  for i := 0 to ANumCRects-1 do // along all Color Rects
  begin
    CurCode := ACRects[i].CRCode;
    if PrevCode <> CurCode then // begin new Array for new Code
    begin
      if i = 0 then // first code array
        ASL.AddToken( Format( '[%d', [CurCode] ) )
      else // i > 0 - not first code array
        ASL.AddToken( Format( ']],[%d', [CurCode] ) );

      PrevCode := CurCode;
      NextY := N_NotAnInteger; // force new Y sequence
      SequenceInd := 0;
    end; // if PrevCode <> CurCode then // begin new Array for new Code

    CurY := ACRects[i].CRect.Top;
    with ACRects[i].CRect do
    begin
      XBeg := Left;
      YBeg := Top;
      DX   := Right  - Left + 1;
      DY   := Bottom - Top  + 1;
    end;

    //***** Check if CurRect and PrevRect are connected
    //      (belongs to one connected polygon)
    //      (is needed for creting Polygons by JS client)

    if (ACRects[i].CRect.Left  > ACRects[i-1].CRect.Right) or
       (ACRects[i].CRect.Right < ACRects[i-1].CRect.Left) then
      NextY := N_NotAnInteger; // force new Y sequence

    if NextY <> CurY then // begin new Y sequence
    begin

      if SequenceInd = 0 then // first Y sequence for current Code
        ASL.AddToken( Format( ',[%d,%d,%d,%d', [XBeg, YBeg, DX, DY] ) )
      else
        ASL.AddToken( Format( '],[%d,%d,%d,%d', [XBeg, YBeg, DX, DY] ) );

      Inc(SequenceInd);

    end else // continue current Y sequence
    begin
      dxLeft  := ACRects[i].CRect.Left  - ACRects[i-1].CRect.Left;
      dxRight := ACRects[i].CRect.Right - ACRects[i-1].CRect.Right;
      ASL.AddToken( Format( ',%d,%d,%d', [DY, dxLeft, dxRight] ) );
    end;

    NextY := ACRects[i].CRect.Bottom + 1;
  end; // for i := 0 to ANumCRects-1 do // along all Color Rects

  ASL.Flash( ']]]' );
end; //*** procedure N_ConvColorRectsToJS

//******************************************************* N_SetWordRangeEnd ***
// Assign given value AEnd to End property of given ARange
//
// Is needed only because after using End property Delphi IDE cannot find
// any declarartion in the subsequent code
//
procedure N_SetWordRangeEnd( ARange: Variant; AEnd: integer );
begin
  ARange.End := AEnd;
end; // procedure N_SetWordRangeEnd

//******************************************************* N_GetWordRangeEnd ***
// Return End property of given ARange
//
// Is needed only because after using End property Delphi IDE cannot find
// any declarartion in the subsequent code
//
function N_GetWordRangeEnd( ARange: Variant ): integer;
begin
  Result := ARange.End;
end; // function N_GetWordRangeEnd

Initialization
  N_AddStrToFile( 'N_GCont Initialization' );


end.
