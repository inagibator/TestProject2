unit N_CompCL;
// low level Components Coords and Layout -  Types, Classes and Procedures

// TN_CompInitFlags    = set of ( // Component SubTree initialization Flags
// TN_SavedOCanvFields = packed record // Saved OCanv fields, used in ExecSubtree,
// TN_WordInsBmkWhere  = ( // Word Bookmark insert content "where" flags
// TN_WordInsBmkWhat   = ( // Word Bookmark insert content "what" flags
// TN_CPanelFlags      = Set Of ( // Visual Component Panel Flags
// TN_CPanelSide       = packed record // Visual Component Panel One Side parameters
// TN_CPanel           = packed record // Visual Component's Panel Params

// TN_CompCoordsScope = ( ccsParent,  ccsRoot );
// TN_CompBPCType     = ( cbpNotGiven, cbpNorm, cbpLSU, cbpLSU_LR, cbpUser );
// TN_CompSizeType    = ( cstNotGiven, cstNorm, cstLSU, cstLSUComp, cstAspect );
// TN_CompUCoordsType = ( cutGiven,  cutGivAsp, cutLSU, cutParent);
// TN_CompCoords      = packed record //***** Component Coords and Position

// TN_LElType         = ( leltRowBreak, leltNoSpaceAfter ); // Layout Element Type
// TN_ODLElem         = record // Data for one Element, used in OneDimLayout algorithm
// TN_ODLRow          = record   // one Row Data for OneDimLayout algorithm
// TN_ODLFlags        = set of ( odlfFixWidth, odlfFlag2 );
// TN_OneDimLayout    = record // inp and out Data, used in OneDimLayout algorithm

// TN_OneTextBlockType  = ( tbtText, tbtAttr, tbtTextComp, tbtVisComp,
// TN_OneTextBlockFlags = set of ( tbfClosePrev, tbfCloseSelf );
// TN_OneTextBlock    = packed record // One Text Block (one element of TextBlocks)
// TN_TextRectType    = ( trtToken, trtHyphen, trtBullet );
// TN_TextRectFlags   = set of ( trf1 );
// TN_TextRect        = packed record // One Text Rect

// TN_SRTLRowFlags    = set of ( rowNoJustify );
// TN_SRTLRow         = record  // one Row Data for Super Rich Text Layout
// TN_SRTextLayout    = class( TObject ) // Super Rich Text Layout

// TN_CParaBoxFlags = set of ( pbfSkipTag );
// TN_CParaBox = packed record // UDParaBox Component Individual Params

// TN_TDPointsLayout  = record // Two Dimensional Points layout Data
// TN_LOElem          = record // Data for one LayoutObj Element (on Input and Output)
// TN_LORowFlags      = set of ( rfNoJustify );
// TN_LORow           = record   // one Row Data used in LayoutObj
// TN_LOElType        = set of ( loelRowBreak, loelNoSpaceAfter ); // LayoutObj Element Type
// TN_LOFlags         = set of ( lofFixWidth, lofCheckElRealSize );
// TN_LayoutObj       = class( TObject )

interface
uses Windows, Classes,
  K_UDT1, K_Script1, Types,
  N_Types, N_Gra0, N_Gra1, N_Gra2, N_Lib1, N_Lib2;

const K_CountUDRef = True;
{
type TN_CompRTFags    = set of ( crtfDummy1 );
type TN_CompStatFags  = set of ( csfCoords, csfNonCoords, csfVarSize, csfExecAfter );
}

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CompInitFlags
type TN_CompInitFlags = set of ( // Component SubTree initialization Flags
  cifSkipRTFName,  // clear RTFileName field
  cifRootComp,     // Self is Root Component
  cifSeparateGCont // new GCont should not inherit Self GCont
  );
// cifSkipRTFName   - clear RTFileName field
// cifRootComp      - Self is Root Component
// cifSeparateGCont - New GCont should not inherit Self GCont

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SavedOCanvFields
type TN_SavedOCanvFields = packed record // Saved OCanv fields, used in ExecSubtree,
  // User Coords related fields (not boolean)
  SavedU2P:    TN_AffCoefs4; // User to Pixel coords convertion coefs.
  SavedP2U:    TN_AffCoefs4; // Pixel to User coords convertion coefs.

  SavedU2P6:   TN_AffCoefs6; // User to Pixel coords convertion coefs.
  SavedP2U6:   TN_AffCoefs6; // Pixel to User coords convertion coefs.

  SavedMaxUClipRect: TFRect; // if coords are inside MaxUClipRect they could not
                             // be clipped (as vectors) - Windows will do it 
                             // otherwise vector topological clipping is needed 
                             // (in Win98 - MaxUClipRect=N_Max9XPRect in User 
                             // Coords
  SavedMinUClipRect: TFRect; // if Object EnvRect is out of MinUClipRect it is 
                             // not visible and can be not drawn (can be 
                             // skipped) (usually SelfMaxPREct+50 Pix in User 
                             // Coords)
  SavedUserAspect:   double; // OCanv User Coords Aspect, for (PixDX,PixDY) rect
                             // needed aspect is 
                             // OCPixAspect*OCUserAspect*(PixDY/PixDX), ( almost
                             // always = 1, <> 1 only if visual quadrat should 
                             // have different X,Y sizes in User Units) (=0 
                             // means that any aspect is OK)

  // Pixel Coords related fields (not boolean)
  SavedP2PWin:    TXFORM; // Pixel to Pixel Windows Transformation coefs.
  SavedPClipRect: TRect;  // always save current PClipRect

  // boolean (1 byte) fields
  SavedUseAffCoefs6: boolean; // use U2P6 and P2U6 instead of U2P and P2U
  SavedUseP2PWin:    boolean; // use WinGDI World coords convertion
  UserCoordsChanged: boolean; // not used now
  P2PWinChanged:     boolean; // P2PWin was changed and need to be restored
  ClipRectChanged:   boolean; // restore PClipRect (it was saved in 
                              // SetOuterPixCoords method)
//##/*
  SavedReserved1: byte;
  SavedReserved2: byte;
  SavedReserved3: byte;
//##*/
end; // type TN_SavedOCanvFields = packed record

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_WordInsBmkWhere
type TN_WordInsBmkWhere = ( // Word Bookmark insert content "where" flags
  wibwhereBefore1, // one character before Bookmark
  wibwhereBefore0, // just before Bookmark
  wibwhereBegin,   // as Bookmark first characters
  wibwhereInstead, // Instead of Bookmark (Bookmark will be removed)
  wibwhereInside,  // as a whole Bookmark new Content
  wibwhereEnd1,    // before the last Bookmark character
  wibwhereEnd0,    // as Bookmark Last characters
  wibwhereAfter,   // just After Bookmark
  wibwhereCurrent  // at current GCWSMainDocIP (Bookmark is not used)
  );
// (00) wibwhereBefore1 - one character before Bookmark
// (01) wibwhereBefore0 - just before Bookmark
// (02) wibwhereBegin   - as Bookmark first characters
// (03) wibwhereInstead - Instead of Bookmark (Bookmark will be removed)
// (04) wibwhereInside  - as a whole Bookmark new Content
// (05) wibwhereEnd1    - before the last Bookmark character
// (06) wibwhereEnd0    - as Bookmark Last characters
// (07) wibwhereAfter   - just After Bookmark
// (08) wibwhereCurrent - at current GCWSMainDocIP (Bookmark is not used)

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_WordInsBmkWhat
type TN_WordInsBmkWhat  = ( // Word Bookmark insert content "what" flags
  wibWhatClipboard, // Current Clipboard Content
  wibWhatString,    // given String
  wibWhatDoc,       // File Content (FileName is given)
  wibWhatSubDoc     // SubDocument  (FileName is given)
  );
// (0) wibWhatClipboard - Current Clipboard Content
// (1) wibWhatString    - given String
// (2) wibWhatDoc       - File Content (FileName is given)
// (3) wibWhatSubDoc    - SubDocument  (FileName is given)

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CPanelFlags
type TN_CPanelFlags = Set Of ( // Visual Component Panel Flags
  cpfBaseIntRect // given Rect is Internal (Inner) Rect (not OuterRect)
);
// cpfBaseIntRect - given Rect is Internal (Inner) Rect (not OuterRect)

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CPanelSide
type TN_CPanelSide = packed record // Visual Component Panel One Side parameters
  PaSBorderColor: integer;    // Panel One Side Border Color
  PaSBorderWidth: float;      // Panel One Side Border Width
  PaSRoundXYRads: TN_MPointSize; // Panel Round (X,Y) Radiuses in Measured Units
                                 // for corner between current and next Side
end; // type TN_CPanelSide = packed record
type TN_PCPanelSide = ^TN_CPanelSide;

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CPanel
type TN_CPanel = packed record // Visual Component Panel parameters
  PaFlags:  TN_CPanelFlags;  // Panel flags
//##/*
  PaReserved1: byte;
  PaReserved2: byte;
  PaReserved3: byte;
//##*/
  PaMargins:  TN_MRectSize;  // Panel Margins in Measured Units
  PaPaddings: TN_MRectSize;  // Panel Paddings in Measured Units
  PaBackColor:   integer;    // Panel Background Color
  PaBorderColor: integer;    // Panel All Borders Common Color
  PaBorderWidth: float;      // Panel All Borders Common Width
  PaRoundXYRads: TN_MPointSize; // Panel Round (X,Y) Radiuses in Measured Units 
                                // (Common)
  PaSideParams:  TK_RArray;     // Panel Sides (Left, Top, Right, Bottom - LTRB)
                                // Individual Params (may be nil) (Array of 
                                // TN_CPanelSide with  0...4 elements)
end; // type TN_CPanel = packed record
type TN_PCPanel = ^TN_CPanel;

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SArrowFlags
type TN_SArrowFlags = set of ( // Visual Component Straight Arrow flags
  safJustLine,     //
  safUseBegPoint,  //
  safUseBothPoints //
  );

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SArrowDirection
type TN_SArrowDirection = ( // Visual Component Straight Arrow Direction enumeration
  sadTop,       // from Bottom to Top
  sadTopRight,  // from Top to Right
  sadRight,     // from Left to Right
  sadBotRight,  // from Bottom to Right
  sadBottom,    // from Top to Bottom
  sadBotLeft,   // from Bottom to Left
  sadLeft,      // from Right to Left
  sadTopLeft    // from Top to Left
 );

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CSArrow
type TN_CSArrow = packed record // Straight Arrow Component Individual Parameters
  SAFlags: TN_SArrowFlags;         // Straight Arrow Flags (see comments after 
                                   // TN_SArrowFlags)
  SADirection: TN_SArrowDirection; // Straight Arrow Direction
//##/*
  SAReserved1: byte; // for alignment
  SAReserved2: byte;
//##*/
  SAWidths:  TFPoint;   // Straight Arrow Widths (across Line, X - Internal 
                        // Width,  Y - Full Width)
  SALengths: TFPoint;   // Straight Arrow Lengths (along Line, X - Internal 
                        // Length, Y - Outer Length)
  SAAttribs: TK_RArray; // Straight Arrow drawing attributes (RArray of 
                        // TN_ContAttr)
  SABegPoint: TN_MPointSize; // Straight Arrow Beg Point
  SAEndPoint: TN_MPointSize; // Straight Arrow End Point
  SARect:    TFRect;    // Straight Arrow Rect Pixel Coords
end; // type TN_CSArrow = packed record
type TN_PCSArrow = ^TN_CSArrow;

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CompCoordsScope
type TN_CompCoordsScope = ( // Visual Component Coordinates Scope for BasePoint, LRPoint and Size enumeration
  ccsParent,  // Parent Component CompIntPixRect
  ccsCurFree, // Parent Component CurFreeRect
  ccsRoot,    // Root   Component CompIntPixRect
  ccsVisible, // OCanv.CurCRect
  ccsDstImage // Destination (resulting) Image
);

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CompBPCType
//********************************************************** TN_CompBPCType ***
// Visual Component Base Point Coordinates (X and Y) Type enumeration
//
// Positive pixel, LSU and mm  LowRight coordinates means shift inside Component
// Coordinates Scope. If SrcResDPI = 0 then value of 72 for SrcResDPI is used in
// cbpmm and cbpmm_LR cases.
//
type TN_CompBPCType = (
  cbpNotGiven, // Base Point Coordinates (X or Y) is not given
  cbpUser,     // in Parent (current, before Component processing) User 
               // Coordinates
  cbpPercent,  // percent of Component Coordinates Scope ((100,100) - lower 
               // right corner)
  cbpLSU,      // in LSU units relative to Component Coordinates Scope upper 
               // left corner
  cbpmm,       // in millimeters relative to Component Coordinates Scope upper 
               // left corner
  cbpPix,      // in Pixels relative to Component Coordinates Scope upper left 
               // corner
  cbpLSU_LR,   // in LSU units relative to Component Coordinates Scope Lower 
               // Right corner
  cbpmm_LR,    // in millimeters relative to Component Coordinates Scope Lower 
               // Right corner
  cbpPix_LR    // in Pixels relative to Component Coordinates Scope Lower Right 
               // corner
);

// cbpNotGiven - Base Point Coords (X or Y) is not given
// cbpUser     - in Parent (current, before Component processing) User Coords
// cbpPercent  - Percent of Component Coords Scope ((100,100) - lower right corner)
// cbpLSU      - in LSU units relative to Component Coords Scope upper left corner
// cbpmm       - in millimeters relative to Component Coords Scope upper left corner
// cbpPix      - in Pixels relative to Component Coords Scope upper left corner
// cbpLSU_LR   - in LSU units relative to Component Coords Scope Lower Right corner
// cbpmm_LR    - in millimeters relative to Component Coords Scope Lower Right corner
// cbpPix_LR   - in Pixels relative to Component Coords Scope Lower Right corner
//   (positive Pix, LSU and mm  _LR coords means inside Component Coords Scope)
//   (if SrcResDPI = 0 then value of 72 for SrcResDPI is used for cbpmm, cbpmm_LR)

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CompSizeType
type TN_CompSizeType = ( // Visual Component Size Type enumeration
  cstNotGiven, // Component Size is not given (UL and LR corner coordinates are 
               // given instead)
  cstAspect,   // one Size should be calculated by another (given) Size, using 
               // SRSizeAspect
  cstPercentS, // Percent of Component Coordinates Scope (100 - whole Scope)
  cstPercentP, // Percent of whole Parent CompIntPixRect (100 - whole 
               // CompIntPixRect)
  cstLSU,      // in LSU units ( one LSU is usually equal to 1 point (1/72") )
  cstmm,       // in millimeters
  cstPixel,    // in Pixels
  cstUser      // in Parent User Coordinates units
  );
//    Component Size Type (if given):
// cstNotGiven - Component Size is not given (UL and LR corner coords are given instead)
// cstAspect   - one Size should be calculated by another (given) Size, using SRSizeAspect
// cstPercentS - Percent of Component Coords Scope (100 - whole Scope)
// cstPercentP - Percent of whole Parent CompIntPixRect (100 - whole CompIntPixRect)
// cstLSU      - in LSU units ( one LSU is usually equal to 1 point (1/72") )
// cstmm       - in millimeters
// cstPixel    - in Pixels
// cstUser     - in Parent User Coords units

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CompUCoordsType
type TN_CompUCoordsType = ( // Component User Coordinates Type enumeration
  cutParent,      // parent User Coordinates (can be used if User Coordinates 
                  // are not needed)
  cutGiven,       // given in CompUCoords field, Coordinates aspect should be 
                  // the same as in CompIntPixRect
  cutGivenAnyAsp, // given in CompUCoords field, any Coordinates aspect is OK
  cutLLW,         // rectangle (-0.5, -0.5, WidthInLLW-0.5, HeightInLLW-0.5)
  cutmm,          // same as in LLW but in millimeters
  cutPercent,     // rectangle ( 0, 0, 100, 100 )
  cutNotGiven     // Component User Coordinates Type is not given
  );
//    Component User Coords Type:
// cutParent   - parent User Coords (can be used if User Coords are not needed)
// cutGiven    - given in CompUCoords field, UCoords Aspect should be the same as of CompIntPixRect
// cutGivenAnyAsp - given in CompUCoords field, any UCoords Aspect is OK
// cutLLW      - (-0.5, -0.5, WidthInLLW-0.5, HeightInLLW-0.5)
// cutmm       - same as in LLW but in millimeters
// cutPercent  - ( 0, 0, 100, 100 )
// cutNotGiven - User Coords are not needed and can be of any value

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CurFreeFlags
//********************************************************* TN_CurFreeFlags ***
// Visual Component childs layout by free space in component rectangle rest 
// after next child Component placing flags set
//
type TN_CurFreeFlags = set of (
  cffSetLeft,     // place next child to right from current
  cffSetRight,    // place next child to left from current
  cffSetTop,      // place next child lower than current
  cffSetBottom,   // place next child upper than current
  cffResetLeft,   // reset current free space rectangle left border
  cffResetRight,  // reset current free space rectangle right border
  cffResetTop,    // reset current free space rectangle top border
  cffResetBottom, // reset current free space rectangle bottom border
  cffPushBefore,  // push current free space rectangle to free space rectangles 
                  // stack before next child Component placing
  cffPopBefore,   // pop current free space rectangle from free space rectangles
                  // stack before next child Component placing
  cffPushAfter,   // push current free space rectangle to free space rectangles 
                  // stack after next child Component placing
  cffAABefore,    // flag controls current free space rectangle correction phase
  cffABAfter,     // flag controls current free space rectangle correction phase
  cffAAAfter,     // flag controls current free space rectangle correction phase
  cffFullAspSize  // use ScopePixRect field instead of Component Size
 );
// CurFreeRect Actions Flags (see TN_UDCompVis.UpdateCurFreeRect method)

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CompSAspectType
type TN_CompSAspectType = ( // Visual Component Aspect Type enumeration
  catAnyOK,   // any aspect calculating during component layout is OK
  catSize,    // aspect is defined by Component size
  catUCoords, // aspect is defined by Component User Coordinates
  catGiven    // aspect is defined by Component Aspect field
  );

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CompCoords
//*********************************************************** TN_CompCoords ***
// Visual Component Coordinates and Position fields
//
type TN_CompCoords = packed record
  BPCoords: TFPoint; // Base Point X,Y coords (in BPXCoordsType, BPYCoordsType 
                     // units)
  BPShift:  TFPoint; // Base Point Shift, always in LSU
  BPPos:    TFPoint; // Base Point Position in SelfRect: (0,0) - BP at Upper 
                     // Left corner, (1,1) - BP at Low Right corner
  LRCoords: TFPoint; // Lower Right Corner X,Y coords (in LRXCoordsType, 
                     // LRYCoordsType units)
  SRSize:   TFPoint; // SelfRect X,Y Size (in SRSizeXType, SRSizeYType units)
  SRSizeAspect: float; // needed SRSize Aspect (SRSize.Y/SRSize.X) coefficient, 
                       // in not Root component is used only if SRSize X or Y 
                       // Type is cstAspect
                       //#F
                       //  0 means that any SRSize Aspect is OK,
                       // -1 means that SRSizeAsp=SRSize.Y/SRSize.X, (is used only for Root component)
                       // -2 means that SRSizeAsp=CompUCoordsAspect, (is used only for Root component)
                       // -3 means that SRSizeAsp is calculated by CalcParams1 
                       //#/F
  SrcResDPI: float; // Preferred Resolution in DPI (0 - if not given)

  CompUCoords:  TFRect; // User Coords of Component.CompIntPixRect (if needed)
  UCoordsAspect: float; // needed UCoords Aspect, if =0 - any Aspect is OK 
                        // (almost always = 0 or 1, <> 0,1 only if visual 
                        // quadrat should have different X,Y sizes in User Units
                        // )
  BPXCoordsType: TN_CompBPCType; // Base Point X Coords Type
  BPYCoordsType: TN_CompBPCType; // Base Point Y Coords Type
  LRXCoordsType: TN_CompBPCType; // Lower Right Corner X Coords Type
  LRYCoordsType: TN_CompBPCType; // Lower Right Corner Y Coords Type

  SRSizeXType: TN_CompSizeType;    // Component X Size Type
  SRSizeYType: TN_CompSizeType;    // Component Y Size Type
  UCoordsType: TN_CompUCoordsType; // how to set User Coords
  CoordsScope: TN_CompCoordsScope; // Coords Scope for BasePoint, LRPoint and 
                                   // Size

  CurFreeFlags:  TN_CurFreeFlags;    // CurFreeRect Action Flags (Two bytes)
  SRSizeAspType: TN_CompSAspectType; // Self Rect Size Aspect Type
  UserTransfType:  TN_CTransfType;   // User coords Transform Type
  PixTransfType: TN_CTransfType;     // Pixel coords Transform Type
  CCRotateAngle:  float;             // Component Rotate Angle in degree
end;
type TN_PCompCoords = ^TN_CompCoords;
type TN_CompCoordsArray = array of TN_CompCoords;
type TN_CCAArray = array of TN_CompCoordsArray;


//******** One Dimensional Layout Data (all sizes are in Float Pixels)

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_LElType
//************************************************************** TN_LElType ***
// Layout Element Type enumeration
//
// Type of each Element, used in N_DoOneDimLayout.
//
type TN_LElType = (
  leltRowBreak,    // force Row Break after this Element
  leltNoSpaceAfter // no space should be added after this Element, but Row Break
                   // can occure

);
// type of each Element, used in N_DoOneDimLayout:
// leltRowBreak     - force Row Break after this Element
// leltNoSpaceAfter - No Space should be added after this Element, but
//                    Row Break can occure

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_ODLElem
//************************************************************** TN_ODLElem ***
// Data for one Element, used in One Dimention Layout algorithm
//
type TN_ODLElem = record
  ElSize: float;     // Element Size (width or height) (on input)
  ElRealSize: float; // Real Element Size (on input), ElRealSize <= ElSize, used
                     // for center Element in ElSize place, used only if 
                     // odlfCheckElRealSize bit is set
  ElFlags: set of TN_LElType; // set of Layout Element Type Flags
  ElOffs: float;     // Element Offset (on output)
  ElRowInd: integer; // Element row or column Index (on output)
end; // type TN_ODLElem = record
type TN_ODLElems = array of TN_ODLElem;

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_ODLRow
type TN_ODLRow = record   // One Row Data for One Dimention Layout algorithm
  RowFEInd: integer;      // first (in Row) Element Index (in ODLElems array)
  RowNumElems: integer;   // number of Elements in Row
  RowMinSize: float;      // left aujusted Row Size
  RowNoJustify: boolean;  // row cannot be Justified (if last Row or RowBreak)
  RowNumSpaces: integer;  // number of Spaces between Elements in Row
end; // type TN_ODLRow = record
type TN_ODLRows = array of TN_ODLRow;

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_ODLFlags
type TN_ODLFlags = set of ( // One Dimention Layout algorithm working flags
  odlfFixWidth,       // ODLRealWidth should be exactly equal to ODLPrefWidth
  odlfCheckElRealSize // center Element in ElSize place if ElRealSize < ElSize
  );
// OneDimLayout algorithm working flags:
// odlfFixWidth        - ODLRealWidth should be exactly equal to ODLPrefWidth
// odlfCheckElRealSize - center Element in ElSize place if ElRealSize < ElSize

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_OneDimLayout
//********************************************************* TN_OneDimLayout ***
// Input and output Data, used in One Dimention Layout algorithm
//
type TN_OneDimLayout = record
  ODLFlags: TN_ODLFlags; // One Dimention Layout algorithm flags
  ODLAlign: TN_HVAlign;  // alignment mode
  ODLRowHeight: float;   // row height including TBAddLineSpacing not used in 
                         // One Dimention Layout algorithm, can be used as work 
                         // variable in outer algorithms
  ODLSpaceSize: float;   // space size between Elements
  ODLUnifSSpace: float;  // side Space for Uniform Layout (in % of internal 
                         // Space, =0 means = 100%)
  ODLMaxSpace:  float;   // maximal possible Space for Uniform Layout in LSU
  ODLPrefWidth: float;   // preferable all Rows Width
  ODLRealWidth: float;   // calculated MaxWidth of all Rows (can be less or 
                         // greater then ODLPrefWidth!)
  ODLElemsInRow: integer;// number of Elements In one Row (<= 0 - max possible)
  ODLNumElems: integer;  // number of Elements (on input)
  ODLNumRows: integer;   // number of Rows (on output)
  ODLElems: TN_ODLElems; // elements to layout
  ODLRows:  TN_ODLRows;  // rows params (used inside N_DoOneDimLayout)
end; // type TN_OneDimLayout = record
type TN_POneDimLayout = ^TN_OneDimLayout;
type TN_OneDimLayouts = array of TN_OneDimLayout;


//*********************** TN_SRTextLayout related types ***************

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_OneTextBlockType
//***************************************************** TN_OneTextBlockType ***
// TextBox Visual Component one Text Block Type enumeration
//
type TN_OneTextBlockType = (
  tbtText,     // Text Block Text field is text content
  tbtAttr,     // Text Block Text field is HTML or SVG text attributes
  tbtTextComp, // Text Block Reference field is reference to some Text Component
               // with content
  tbtVisComp,  // Text Block Text field  is content of HTML <img> TAG
  tbtPictFile, // Text Block Text field containsatributes of HTML <img> TAG and 
               // FileName field contains file name to place to HTML <img> TAG 
               // src attribute
  tbtTextFile, // Text Block FileName field contains text file name with real 
               // text content
  tbtRef       // not used now
);

//##/*
type TN_OneTextBlockFlags = set of (
  tbfClosePrev,
  tbfCloseSelf
);
//##*/
//##/*

//********************************************************* TN_OneTextBlock ***
// One Text Block data structure
//
type TN_OneTextBlock = packed record // One Text Block (one element of TextBlocks)
  OTBType:  TN_OneTextBlockType;  // Text Block Type
  OTBFlags: TN_OneTextBlockFlags; // Text Block Flags
//##/*
  OTBReserved1: byte;  // for alignment
  OTBReserved2: byte;
//##*/
  OTBMText:   string;     // Text Content or Attributes
//##/*
  OTBFont:  TN_UDLogFont; // Old Font
//##*/
  OTBNFont:   TObject;    // Text Font
  OTBTextColor:  integer; // Text Foreground Color
  OTBBackColor:  integer; // Text Background Color
  OTBShift:      TFPoint; // Text Block X,Y Shift in Pixels
  OTBSize:       TFPoint; // Text Block X,Y Size in Pixels
  OTBComp:     TN_UDBase; // Visual Component (<img> Tag in TextMode)
  OTBFName:    string;    // File Name (Text or Picture) - Text Block external Content
  OTBBack2Color: integer; // Text Background 2 Color
  OTBBack2Width:   float; // Text Background 2 Color Width in LLW
  OTBBack2Shift: TFPoint; // Text Background 2 Color X,Y Shift in LLW
end; // type TN_OneTextBlock
type TN_POneTextBlock = ^TN_OneTextBlock;
type TN_TextBlocks = Array of TN_OneTextBlock;
type TN_PTextBlocks = Array of TN_POneTextBlock;

//##/*
type TN_TextRectType = ( trtToken, trtHyphen, trtBullet );
type TN_TextRectFlags = set of ( trf1 );

type TN_TextRect = packed record // One Text Rect
  TRType:  TN_TextRectType;
  TRFlags: TN_TextRectFlags;
  TRReserved1: byte;  // for alignment
  TRReserved2: byte;
  TRTBIndex: integer;
  TRCharsOfs: integer;
  TRNumChars: integer;
  TRNumSpaces: integer;
  TRWidth: integer;
  TRBLPos: TPoint;
  TRRect: TRect;
end; // type TN_TextRect
type TN_PTextRect = ^TN_TextRect;
type TN_TRArray = array of TN_TextRect;
//##*/

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SRTLRowFlags
type TN_SRTLRowFlags = set of ( // Super Rich Text Row Layout Flags
  rowNoJustify // Row should not be Justified (last Row or RowBreak)
);
// rowNoJustify - Row should not be Justified (last Row or RowBreak)

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SRTLRow
type TN_SRTLRow = record  // Super Rich Text one Row Layout Data
  RowFlags: TN_SRTLRowFlags; // row Layout Flags
//##/*
  RowReserved1: byte;
  RowReserved2: byte;
  RowReserved3: byte;
//##*/
  RowFTRInd:    integer;  // first (in Row) Text Rectangle Index (in 
                          // SRTLTextRects array)
  RowNumTRects: integer;  // number of ext Rectangles in Row
  RowSumWidth:  integer;  // sum of all Token Widths in Row
  RowAscent:    integer;  // maximal Token Ascent in Row
  RowDescent:   integer;  // maximal Token Descent in Row
  RowNumBreaks: integer;  // number of Breaks (Spaces) between Elements in Row
  RowBLY:       integer;  // row base Line Y Coordinate
end; // type TN_SRTLRow = record
type TN_SRTLRows = array of TN_SRTLRow;

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SRTLFlags
type TN_SRTLFlags = set of ( // Super Rich Text Layout Flags Set
  srtlContWidth,   // set Width by Content - SRTLRealSize.X set by max Row Width
  srtlEnlWidth,    // enlarge Width - SRTLRealSize.X set by Max( max Row Width, 
                   // CompWidth )
  srtlContHeight,  // set Height by Content - SRTLRealSize.Y set summ of all 
                   // Rows Heights
  srtlEnlHeight,   // enlarge Height - SRTLRealSize.Y set by Max( summ of all 
                   // Rows Heights, CompHeight )
  srtlSimpleSplit, // split Tokens at any place and add Hyphen
  srtlLangSplit    // language specific Tokens split (not implemented)
);
// srtlContWidth   - Set Width by Content  - SRTLRealSize.X set by max Row Width
// srtlEnlWidth    - Enlarge Width         - SRTLRealSize.X set by Max( max Row Width, CompWidth )
// srtlContHeight  - Set Height by Content - SRTLRealSize.Y set summ of all Rows Heights
// srtlEnlHeight   - Enlarge Height        - SRTLRealSize.Y set by Max( summ of all Rows Heights, CompHeight )
// srtlSimpleSplit - Split Tokens at any place and add Hyphen
// srtlLangSplit   - Language specific Tokens split (not implemented)

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SRTextLayout
type TN_SRTextLayout = class( TObject ) // Super Rich Text Layout Object
  SRTLOCanv: TN_Ocanvas;    // Text Canvas

  SRTLFlags:  TN_SRTLFlags; // layout flags
  SRTLHAlign: TN_HVAlign;   // horizontal alignment mode
  SRTLVAlign: TN_HVAlign;   // vertical alignment mode
  SRTLPrefSize:  TPoint;    // preferable (on input) X,Y Size in Pixels
  SRTLRealSize:  TPoint;    // real (on output) X,Y Size in Pixels (can be less 
                            // or greater then SRTLPrefSize!)
  SRTLElemsInRow: integer;  // number of Elements In Row (on input, <= 0 - max 
                            // possible)
  SRTLExYSpace:   float;    // extra Y-space (between Rows, in LSU)

  SRTLTextRects: TN_TRArray; // array of resulting TextRects
  SRTLFreeTRInd:    integer; // free TextRect Index (in SRTLTextRects array)
  SRTLRows:     TN_SRTLRows; // rows params
  SRTLCurRowInd:    integer; // current row Index (in SRTLRows array)

  SRTLBlocksStack: TN_TextBlocks; // TextBlocks Stack array
  SRTLCurStackInd: integer;       // TextBlocks Stack Top position

  constructor Create ( AOCanv: TN_Ocanvas );
//##/*
  destructor  Destroy; override;
//##*/

  procedure SRTLInit        ( AOCanv: TN_Ocanvas );
  procedure AddOneTextBlock ( ATBInd, ATBLastInd: integer; APTextBlock: TN_POneTextBlock;
                                                      var AFreePixInRow: integer );
  procedure AddTextBlocks   ( APTextBlock: TN_POneTextBlock; ANumBlocks: integer );
  procedure LayoutTextRects ();
end; // type TN_SRTextLayout = class( TObject )


//##/*
type TN_CParaBoxFlags = set of ( pbfSkipTag );
//##*/

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_CParaBox
//************************************************************* TN_CParaBox ***
// Text Box Visual Component data structure
//
// TN_UDParaBox Component Individual Params
//
type TN_CParaBox = packed record
//##/*
  CPBFlags: TN_CParaBoxFlags; // Additional Flags
//##*/
  CPBSRTLFlags: TN_SRTLFlags; // Super Rich Text Layout Flags Set
  CPBHorAlign:  TN_HVAlign;   // Horizontal Alignment
  CPBVertAlign: TN_HVAlign;   // Vertical Alignment
  CPBIndent:     float;       // First Line Indent (in LSU)
  CPBExYSpace:   float;       // Extra Y-space (between Rows, in LSU)
  CPBTextBlocks: TK_RArray;   // Records Array of Text Blocks (TN_OneTextBlock)
  CPBNewSrcHTML:    string;   // New Source HTML Text - should be parsed if not 
                              // same with Previous (CPBPrevSrcHTML)
  CPBPrevSrcHTML:   string;   // Previous Source HTML Text (already parsed)
  CPBAuxLine:    TK_RArray;   // Line allong which text should be placed 
                              // (Records Array of TN_AuxLine or nil)
end; // type TN_CParaBox = packed record
type TN_PCParaBox = ^TN_CParaBox;



//********************** Two Dimensional Points layout

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_TDPointsLayout
type TN_TDPointsLayout = record // Two Dimensional Points layout Data
  tdpFRect: TFRect;       // rectangle area to place given number of points
  tdpMode: integer;       // place points mode
  tdpNX:   integer;       // number of columns
  tdpNY:   integer;       // number of rows
  tdpNPoints: integer;    // number of placed points
  tdpPOutCoords: PDPoint; // pointer to first element of resulting base points 
                          // coordinates array
end; // type TN_TDPointsLayout = record
type TN_PTDPointsLayout = ^TN_TDPointsLayout;

//********************** LayoutObj

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_LOElType
//************************************************************* TN_LOElType ***
// Layout Object Element Flags Set
//
// Set of Flags for each Element, used in One Dimension Layout
//
type TN_LOElType = set of ( //
  loelRowBreak,    // force Row Break after this Element
  loelNoSpaceAfter // No Space should be added after this Element, but Row Break
                   // can occure
);
// type of each Element, used in N_DoOneDimLayout:
// loelRowBreak     - force Row Break after this Element
// loelNoSpaceAfter - No Space should be added after this Element, but
//                    Row Break can occure

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_LOElem
type TN_LOElem = record // Data for one Layout Object Element (on Input and Output)
  ElInpSize: TDPoint;   // Element X,Y Size
  ElFlags: TN_LOElType; // Element flags
  ElPos:    TDPoint;    // Element Position
  ElRowInd:  integer;   // Element row Index
  ElLColInd: integer;   // Element Layout Column Index
  ElPageInd: integer;   // Element Page
end; // type TN_LOElem = record
type TN_LOElems = array of TN_LOElem;

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_LORowFlags
type TN_LORowFlags = set of ( // Row Elements Layout Flags Set
  rfNoJustify // justify row Elements
);

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_LORow
type TN_LORow = record   // One row Elements Layout Data (used in Layout Object)
  RowFlags: TN_LORowFlags; // row Elements Layout Flags Set
  RowFEInd: integer;       // first (in row) Element Index (in LOElems array)
  RowNumElems: integer;    // number of Elements in Row
  RowMinWidth: double;     // left aujusted row Size
  RowHeight: double;       // row height
  RowNoJustify: boolean;   // skip row justify flag ( needed to mark last or 
                           // broken Row)
end; // type TN_TN_LORow = record
type TN_LORows = array of TN_LORow;

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_LOFlags
type TN_LOFlags = set of ( // Layout Object Common Flags Set
 lofFixWidth,       // fix object width
 lofCheckElRealSize // check elements real size
);

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_LayoutObj
//************************************************************ TN_LayoutObj ***
// Layout Object
//
type TN_LayoutObj = class( TObject )
  LOFlags: TN_LOFlags;    // layout algorithm flags
  LOHAlign: TN_HVAlign;   // horizontal Alignment mode
  LOVAlign: TN_HVAlign;   // vertical Alignment mode
  LOSpaceSize: TDPoint;   // layout space X,Y size
  LOColPrefSize: TDPoint; // current column X,Y preferable Size (on input)
  LOColRealSize: TDPoint; // current column X,Y real Size (on output)
  LORows:  TN_LORows;     // array of placed rows layout parameters (on input 
                          // and output)
  LONumRows: integer;     // resulting number of rows (on output)
  LOElems: TN_LOElems;    // array of placed Elements
  LONumElems: integer;    // given number of Elements (on input)

  procedure LayoutColumnRows ( AFirstElInd: integer; out ALastElInd: integer );
end; // type TN_LayoutObj = class( TObject )


//****************** Global procedures **********************


procedure N_InitTextBlock   ( APTextBlock: TN_POneTextBlock; AMode: integer );
procedure N_InitTextBlocks  ( ARA: TK_RArray; ABegInd, ANumInds: integer );
procedure N_InitTextBlocks2 ( var ARA: TK_RArray; ABegInd, ANumInds: integer; ACountUDRef: boolean );
procedure N_CopyTextBlock   ( APSrcTextBlock, APDstTextBlock: TN_POneTextBlock; ACountUDRef: boolean );
procedure N_ParseHTMLToTextBlocks ( AHTML: string; var ATextBlocks: TK_RArray;
                                    AOCanv: TN_OCanvas; ACountUDRef: boolean );

function  N_GetTBAttributes ( ATextBlocks: TK_RArray ): string;

procedure N_DoOneDimLayout   ( APLayout: TN_POneDimLayout );
procedure N_DoTDPointsLayout ( APLayout: TN_PTDPointsLayout );

//##/*
//##*/

var
  N_CC: TN_CompCoords; // for viewing in debugger
  N_CP: TN_CPanel;     // for viewing in debugger

implementation
uses
  Math, SysUtils,
  K_CLib0,
  N_Lib0, N_InfoF;

//**********************  TN_SRTextLayout  class methods *********************

type TN_TokenType = set of ( ttSpace, ttLastInBlock, ttBreak, tt0D0A );

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SRTextLayout\Create
//************************************************** TN_SRTextLayout.Create ***
// Super Rich Text Layout Object consrtructor
//
//     Parameters
// AOCanv - Own Canvas Object
//
constructor TN_SRTextLayout.Create( AOCanv: TN_Ocanvas );
begin
  inherited Create();
  SRTLInit( AOCanv );
end; // end_of constructor TN_SRTextLayout.Create

//********************************************* TN_SRTextLayout.Destroy ***
//
destructor TN_SRTextLayout.Destroy;
var
  i: integer;
begin
//  SRTLOCanv is not owned by Self and should not be destroyed

  for i := 0 to High(SRTLBlocksStack) do // Free Objects in TextBlocks
  with SRTLBlocksStack[i] do
  begin
//    OTBFont (old Font, always TK_UDRArray) is not owned by Self and should not be destroyed
//    OTBComp is not owned by Self and should not be destroyed
    if OTBNFont <> nil then
    begin
    // If OTBNFont as RArray should be Freed???
    // If Font Handels should be deleted by Windows.DeleteObject( NFHandle ); ???
    end;

//    OTBNFont: TObject;    // Text Font
  end; // with SRTLBlocksStack[i] do, for i := 0 to High(SRTLBlocksStack) do

  inherited Destroy;
end; // end_of destructor TN_SRTextLayout.Destroy

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SRTextLayout\SRTLInit
//************************************************ TN_SRTextLayout.SRTLInit ***
// Super Rich Text Layout Object initialization
//
//     Parameters
// AOCanv - Own Canvas Object
//
procedure TN_SRTextLayout.SRTLInit( AOCanv: TN_Ocanvas );
begin
  SRTLOCanv := AOCanv;

  // if content of SRTLBlocksStack should be somehow freed?

  //***** Initialize SRTLTextRects and SRTLRows arrays

  if Length(SRTLTextRects) < 10 then
    SetLength( SRTLTextRects, 10 );

  SRTLFreeTRInd := 0;

  if Length(SRTLRows) < 10 then
    SetLength( SRTLRows, 10 );

  SRTLCurRowInd := 0;
  FillChar( SRTLRows[0], Sizeof(SRTLRows[0]), 0 );
end; // procedure TN_SRTextLayout.SRTLInit

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SRTextLayout\AddOneTextBlock
//***************************************** TN_SRTextLayout.AddOneTextBlock ***
// Add One given Text Block to Super Rich Text Layout Object
//
//     Parameters
// ATBInd        - text rectangle start index
// ATBLastInd    - text rectangles last index
// APTextBlock   - pointer to one Text Block data
// AFreePixInRow - current Free pixel position in row (on input and in output)
//
// All "Use current" attributes should be already set. Ñonvert given TextBlock 
// to Text Rectangles and add them to SRTLTextRects array field.
//
procedure TN_SRTextLayout.AddOneTextBlock( ATBInd, ATBLastInd: integer;
                   APTextBlock: TN_POneTextBlock; var AFreePixInRow: integer );
var
  BegTokenInd, LastTBInd, HyphenWidth, TokenWidth: integer;
  NumChars, NumSpaces, NextTokenInd, NumSplitChars, SplitPixWidth: integer;
  CurFlags: TN_SRTLRowFlags;
  TokenType: TN_TokenType;
  StrSize: TSize;
  TextMetric: TTextMetric;
  Label TryAgain;

  // procedure CheckToken ( out ANumChars, ANumSpaces, ANextInd: integer; out ATokenType: TN_TokenType ); // local
  // procedure SplitToken ( PText: PChar; out ANumSplitChars, ASplitPixWidth: integer ); // local
  // procedure AddTokenToCurRow ( ANumChars: integer ); // local
  // procedure AddHyphenToken (); // local
  // procedure FinishCurRow ( ARowFlags: TN_SRTLRowFlags ); // local

  procedure CheckToken( out ANumChars, ANumSpaces, ANextInd: integer;
                                               out ATokenType: TN_TokenType ); // local
  // Check Token, that begins from BegTokenInd
  var
    CurInd: integer;
    CurChar: Char;
    WrkStr: string;
    EmptyToken: boolean;
  begin
    with APTextBlock^, SRTLOCanv do
    begin

    ANumSpaces := 0;
    CurInd := BegTokenInd;
    EmptyToken := True;

    while True do // along all characters in token
    begin

      if CurInd > LastTBInd then // end of TextBlock
      begin
        ANumChars := CurInd - BegTokenInd;
        ANextInd := -1;
        ATokenType := [ttLastInBlock];
        Exit;
      end;

      CurChar := OTBMText[CurInd];

      if CurChar = ' ' then // Space - leading spaces or Space as delimiter
      begin

        if EmptyToken then // initial leading spaces before token
        begin
          Inc( ANumSpaces );
          Inc( CurInd );
          Continue; // check next char
        end else // end of token (Space as delimiter)
        begin
          ANumChars := CurInd - BegTokenInd;
          ANextInd := CurInd;
          ATokenType := [ttSpace];
          Exit;
        end;

      end; // if CurChar = ' ' then

      if CurChar = '<' then // check if <br>
      begin
        WrkStr := UpperCase( Copy( OTBMText, CurInd, 4 ) );

        if WrkStr = '<BR>' then
        begin
          ANumChars  := CurInd - BegTokenInd;
          ATokenType := [ttBreak];
          ANextInd   := CurInd + 4;
          if ANextInd > LastTBInd then // end of TextBlock
          begin
            ANextInd := -1;
            ATokenType := [ttBreak,ttLastInBlock];
          end;
          Exit;
        end;

      end; // if CurChar = '<' then // check if <br>

      if CurChar = Char($0D)  then // End of Line
      begin
        ANumChars  := CurInd - BegTokenInd;
        ATokenType := [ttBreak];
        ANextInd   := CurInd + 2;

        if ANextInd > LastTBInd then // end of TextBlock
        begin
          ANextInd := -1;
          ATokenType := [ttBreak,ttLastInBlock];
        end;

        Exit;
      end;

      //***** Here: CurChar is not space and is not token delimiter

      EmptyToken := False;
      Inc( CurInd );
    end; // while True do // along all characters in token

    end; // with APTextBlock^, SRTLOCanv do

  end; // procedure CheckToken - local

  procedure SplitToken( PText: PChar; out ANumSplitChars, ASplitPixWidth: integer ); // local
  // Split Token - return Last Character Index in CurRow or 0 if whole
  // Token should be placed in Next Row
  var
    i, FreePix: integer;
    SplitSize: TSize;
  begin
    ANumSplitChars := 0;
    ASplitPixWidth := 0;

    if not (srtlSimpleSplit in SRTLFlags) then Exit; // do not split (placed whole Token in Next Row)

    FreePix := AFreePixInRow - HyphenWidth;

    for i := 1 to NumChars do // along all characters in Token
    begin
      Windows.GetTextExtentPoint32( SRTLOCanv.HMDC, PText, i, SplitSize );

      if SplitSize.cx > FreePix then // out of Free Space
      begin
        if (i = 1) or (i <= NumSpaces) then Exit; // do not split (placed whole Token in Next Row)

        ANumSplitChars := i-1;
        ASplitPixWidth := SplitSize.cx;

        Exit; // all done
      end; // if SplitSize.cx > FreePix then // out of Free Space

    end; // for i := 1 to NumChars do // along all characters in Token

    Assert( False, 'Bad Split!' );
  end; // procedure SplitToken(); // local

  procedure AddTokenToCurRow( ANumChars: integer ); // local
  // Add Token To Current Row (ANumChars characters from BegTokenInd)
  begin
    with SRTLRows[SRTLCurRowInd] do // update info about current Row
    begin
      RowAscent  := max( TextMetric.tmAscent,  RowAscent );
      RowDescent := max( TextMetric.tmDescent, RowDescent );

      Inc( RowSumWidth, TokenWidth );
      Inc( RowNumTRects );
      Inc( RowNumBreaks, NumSpaces );
    end;

    if High(SRTLTextRects) < SRTLFreeTRInd then
      SetLength( SRTLTextRects, N_NewLength( SRTLFreeTRInd+1 ) );

    FillChar( SRTLTextRects[SRTLFreeTRInd], Sizeof(SRTLTextRects[0]), 0 );

    with SRTLTextRects[SRTLFreeTRInd] do
    begin
      TRType      := trtToken;
      TRTBIndex   := ATBInd;
      TRCharsOfs  := BegTokenInd - 1;
      TRNumChars  := ANumChars;
      TRNumSpaces := NumSpaces;
      TRWidth     := TokenWidth;
      Dec( AFreePixInRow, TRWidth );
    end;

    Inc( SRTLFreeTRInd );
  end; // procedure AddTokenToCurRow(); // local

  procedure AddHyphenToken(); // local
  // Add Hyphen Token To Current Row
  begin
    with SRTLRows[SRTLCurRowInd] do // update info about current Row
    begin
      Inc( RowSumWidth, HyphenWidth );
      Inc( RowNumTRects );
    end;

    if High(SRTLTextRects) < SRTLFreeTRInd then
      SetLength( SRTLTextRects, N_NewLength( SRTLFreeTRInd+1 ) );

    FillChar( SRTLTextRects[SRTLFreeTRInd], Sizeof(SRTLTextRects[0]), 0 );

    with SRTLTextRects[SRTLFreeTRInd] do
    begin
      TRType  := trtHyphen;
      TRWidth := HyphenWidth; // not needed if it is last token in Row
      Dec( AFreePixInRow, TRWidth );
    end;

    Inc( SRTLFreeTRInd );
  end; // procedure AddHyphenToken(); // local

  procedure FinishCurRow( ARowFlags: TN_SRTLRowFlags ); // local
  // Finish Current Row
  begin
    with SRTLRows[SRTLCurRowInd] do
    begin
      RowFlags := RowFlags + ARowFlags;
      RowNumTRects := SRTLFreeTRInd - RowFTRInd;
    end;

    if Length(SRTLRows) < (SRTLCurRowInd+2) then
      SetLength( SRTLRows, N_NewLength( SRTLCurRowInd+2 ) );

    Inc( SRTLCurRowInd );
    FillChar( SRTLRows[SRTLCurRowInd], Sizeof(SRTLRows[0]), 0 );

    with SRTLRows[SRTLCurRowInd] do
    begin
      RowFTRInd := SRTLFreeTRInd;
    end;

    AFreePixInRow := SRTLPrefSize.X;
  end; // procedure FinishCurRow(); // local

begin //****************************** body of TN_SRTextLayout.AddOneTextBlock
  with APTextBlock^, SRTLOCanv do
  begin

  LastTBInd := Length( OTBMText );
  if LastTBInd = 0 then Exit; // Empty TextBlock, nothing to do

  if OTBNFont <> nil then
    N_SetNFont( OTBNFont, SRTLOCanv ) // for using Windows.GetTextExtentPoint32
  else
    N_SetUDFont( OTBFont, SRTLOCanv ); // for using Windows.GetTextExtentPoint32

  Windows.GetTextExtentPoint32( HMDC, @N_Bullets[1], 1, StrSize );
  HyphenWidth := StrSize.cx;

  Windows.GetTextMetrics( HMDC, TextMetric );
  BegTokenInd := 1;

  while True do // along all Tokens of OTBMText
  begin
    CheckToken( NumChars, NumSpaces, NextTokenInd, TokenType );
    Windows.GetTextExtentPoint32( HMDC, @OTBMText[BegTokenInd], NumChars, StrSize );
    TokenWidth := StrSize.cx;

    if (TokenType = [ttSpace]) or
       ( (TokenType = [ttLastInBlock]) and (ATBInd < ATBLastInd) ) then CurFlags := []
    else
      CurFlags := [rowNoJustify];

    TryAgain: //********************

    if TokenWidth > AFreePixInRow then // no place for Token in current Row
    begin

      SplitToken( @OTBMText[BegTokenInd], NumSplitChars, SplitPixWidth );

      if NumSplitChars >= 1 then // place NumSplitChars in Cur Row
      begin

        TokenWidth := SplitPixWidth;
        AddTokenToCurRow( NumSplitChars );

        //***** Update Cur Token info
        BegTokenInd := BegTokenInd + NumSplitChars;
        TokenWidth  := SplitPixWidth;
        NumChars    := NumChars - NumSplitChars;
        NumSpaces   := 0;

        FinishCurRow( [] );
        goto TryAgain;

      end else // place whole Token in Next Row
      begin

        if AFreePixInRow = SRTLPrefSize.X then // Token is bigger then whole Row and
        begin                            // can not be splitted, place it in current Row anyway
          AddTokenToCurRow( NumChars );
          FinishCurRow( CurFlags );
        end else // Cur Row is not Empty
        begin
          FinishCurRow( [] );
          goto TryAgain;
        end;

      end; // else // place whole Token in Next Row

    end else // there is enough place for Token in current Row
    begin
      AddTokenToCurRow( NumChars );

      if CurFlags <> [] then // CurFlags = [rowNoJustify]
       FinishCurRow( CurFlags );

    end; // else // there is enough place for Token in current Row

    //***** Cur Token was processed ( was placed in some row(s) )

    if ttLastInBlock in TokenType then Break; // it was last Token

    BegTokenInd := NextTokenInd; // Prepare for checking Next Token

  end; // while True do // along all Tokens of OTBMText

  end; // with APTextBlock^, SRTLOCanv do
end; // end_of procedure TN_SRTextLayout.AddOneTextBlock

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SRTextLayout\AddTextBlocks
//******************************************* TN_SRTextLayout.AddTextBlocks ***
// Add given TextBlocks to Super Rich Text Layout Object
//
//     Parameters
// APTextBlock - pontre to first element of Text Blocks array
// ANumBlocks  - number of elements in Text Blocks array
//
procedure TN_SRTextLayout.AddTextBlocks( APTextBlock: TN_POneTextBlock; ANumBlocks: integer );
var
  i, FreePixInRow: integer;

  procedure InitTextBlock( APResTB, APPrevTB, APCurTB: TN_POneTextBlock ); // local
  // Fill APResTB^ by APCurTB^ and APPrevTB^
  begin
    APResTB^ := APCurTB^;

    if APResTB^.OTBTextColor = N_CurColor then APResTB^.OTBTextColor := APPrevTB^.OTBTextColor;
    if APResTB^.OTBBackColor = N_CurColor then APResTB^.OTBBackColor := APPrevTB^.OTBBackColor;
  end; // procedure InitTextBlock - local

begin //*************************** body of TN_SRTextLayout.AddTextBlocks

  SetLength( SRTLBlocksStack, 3 );
  N_InitTextBlock( @SRTLBlocksStack[0], 0 ); // initialize SRTLBlocksStack[0]
  SRTLCurStackInd := 0;
  FreePixInRow := SRTLPrefSize.X;

  for i := 0 to ANumBlocks-1 do // along all TextBlocks
  with APTextBlock^ do
  begin

    if tbfClosePrev in OTBFlags then
    begin
      Dec( SRTLCurStackInd );
      if SRTLCurStackInd <= 0 then SRTLCurStackInd := 0; // a precaution
    end;

    Inc( SRTLCurStackInd );
    if High(SRTLBlocksStack) < SRTLCurStackInd then
      SetLength( SRTLBlocksStack, SRTLCurStackInd + 5 );

    InitTextBlock( @SRTLBlocksStack[SRTLCurStackInd], APTextBlock, @SRTLBlocksStack[SRTLCurStackInd-1] );

    AddOneTextBlock( i, ANumBlocks-1, APTextBlock, FreePixInRow );

    if tbfCloseSelf in OTBFlags then
      Dec( SRTLCurStackInd );

    Inc( APTextBlock ); // to next TextBlock

  end; // for i := 0 to ANumBlocks-1 do // along all TextBlocks
end; // end_of procedure TN_SRTextLayout.AddTextBlocks

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_SRTextLayout\LayoutTextRects
//***************************************** TN_SRTextLayout.LayoutTextRects ***
// Layout added Text Rectangles
//
// Calculate all Text Rectangles relative pixel coordinates
//
procedure TN_SRTextLayout.LayoutTextRects();
var
  i, j, NumRows, MaxSumWidth, CurX, CurY, SumHeight: integer;
  SumAddY, ExtraYSpace: integer;
  HorAlign, VertAlign: TN_AlignData;
begin
  // Calc MaxSumWidth (max RowSumWidth),
  // and RowBLY - Y Base Line coords for all Rows (as if they should be TopAligned)

  NumRows := SRTLCurRowInd;
  MaxSumWidth := -1;
  CurY := 0;
  ExtraYSpace := Round( SRTLExYSpace*SRTLOCanv.CurLSUPixSize ); // In Pixels

  for i := 0 to NumRows-1 do // along all Rows, Calc MaxSumWidth and RowBLY
  with SRTLRows[i] do
  begin
    if RowSumWidth > MaxSumWidth then MaxSumWidth := RowSumWidth;
    Inc( CurY, RowAscent );

    if i > 0 then // Shift all Rows except first by given Extra Y Space
      Inc( CurY, ExtraYSpace );

    RowBLY := CurY;
    Inc( CurY, RowDescent );

  end; // for i := 0 to NumRows-1 do // along all Rows, Calc MaxSumWidth and RowBLY

  SumHeight := CurY; // Summ of all Rows Heights

  //***** Set SRTLRealSize according to Flags srtlVar(Width,Heght) flags

  if srtlContWidth in SRTLFlags then
    SRTLRealSize.X := MaxSumWidth
  else if srtlEnlWidth in SRTLFlags then
    SRTLRealSize.X := Max( MaxSumWidth, SRTLPrefSize.X )
  else
    SRTLRealSize.X := SRTLPrefSize.X;

  if srtlContHeight in SRTLFlags then
    SRTLRealSize.Y := SumHeight
  else if srtlEnlHeight in SRTLFlags then
    SRTLRealSize.Y := Max( SumHeight, SRTLPrefSize.Y )
  else
    SRTLRealSize.Y := SRTLPrefSize.Y;

  //***** Set VertAlign, HorAlign records

  with VertAlign do
  begin
    AlignMode := Ord(SRTLVAlign);
    FreeSpace := SRTLRealSize.Y - SumHeight;
    NumGaps   := NumRows;
  end;
  HorAlign.AlignMode := Ord(SRTLHAlign);

  SumAddY := 0;

  for i := 0 to NumRows-1 do // along all Rows, Align TextRects along X and Y
  with SRTLRows[i] do
  begin

    Inc( SumAddY, N_GetAlignDelta( VertAlign, i ) );
    Inc( RowBLY, SumAddY ); // All TextRects in Row Y Base Line relative Y Pixel coord

    HorAlign.FreeSpace := SRTLRealSize.X - RowSumWidth;
    HorAlign.NumGaps   := RowNumTRects;
    CurX := 0;

    for j := 0 to RowNumTRects-1 do // along all TextRects in current Row
    with SRTLTextRects[RowFTRInd+j] do
    begin
      if not ((SRTLHAlign = hvaJustify) and (rowNoJustify in RowFlags)) then
        Inc( CurX, N_GetAlignDelta( HorAlign, j ) );

      TRBLPos.X := CurX;
      TRBLPos.Y := RowBLY;

      Inc( CurX, TRWidth );
    end; // for j := 0 to RowNumTRects do // along all TextRects in current Row

  end; // for i := 0 to NumRows-1 do // along all Rows, Align TextRects along X and Y

end; // end_of procedure TN_SRTextLayout.LayoutTextRects



//**********************  TN_LayoutObj  class methods ************************

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\TN_LayoutObj\LayoutColumnRows
//******************************************* TN_LayoutObj.LayoutColumnRows ***
// Layout Elements in Rows of one current Column
//
//     Parameters
// AFirstElInd - Index of First Element in current Column
// ALastElInd  - Index of Last  Element in current Column
//
procedure TN_LayoutObj.LayoutColumnRows( AFirstElInd: integer; out ALastElInd: integer );
var
  i, MaxElInd, PrevX: integer;
  CurColSize: TDPoint;
begin
  // Init Column Layout variables
  PrevX := 0;           // X Size of all previous Elements in current Row
  CurColSize.X := LOColPrefSize.X; // initial value, can be increased

  MaxElInd := LONumElems - 1;
  for i := AFirstElInd to MaxElInd do //
  with LOElems[i] do
  begin
    N_i := PrevX;
  end;


end; // end_of procedure TN_LayoutObj.LayoutColumnRows


//****************** Global procedures **********************

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\N_InitTextBlock
//********************************************************* N_InitTextBlock ***
// Initialize Text Block Data (one TN_OneTextBlock record)
//
//     Parameters
// APTextBlock - pointer to Text Block Data
// AMode       - initialization mode (=0 means initialization by absolute 
//               values, otherwis current values are used)
//
procedure N_InitTextBlock( APTextBlock: TN_POneTextBlock; AMode: integer );
begin
  if APTextBlock = nil then Exit; // a precaution

  FillChar( APTextBlock^, Sizeof(APTextBlock^), 0 );

  with APTextBlock^ do
  begin
    OTBMText := '123';
    if AMode = 0 then
    begin
      OTBBackColor := N_EmptyColor;
    end else // AMode >= 1
    begin
      OTBTextColor := N_CurColor;
      OTBBackColor := N_CurColor;
    end;
  end; // with APTextBlock^ do
end; // procedure N_InitTextBlock

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\N_InitTextBlocks
//******************************************************** N_InitTextBlocks ***
// Initialized Elements in given records array of Text Blocks data 
// (TN_OneTextBlock)
//
//     Parameters
// ARA      - Text Blocks data records array
// ABegInd  - Text Blocks records array start element index
// ANumInds - number of elements to initialize
//
// Given records array ARA should be of proper type and enough length.
//
procedure N_InitTextBlocks( ARA: TK_RArray; ABegInd, ANumInds: integer );
var
  i: integer;
begin
  if ARA = nil then Exit; // a precaution
  if ARA.ElemType.DTCode <> N_SPLTC_OneTextBlock then Exit;  // a precaution

  for i := ABegInd to ABegInd+ANumInds-1 do
     N_InitTextBlock( TN_POneTextBlock(ARA.P(i)), i );

end; // procedure N_InitTextBlocks

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\N_InitTextBlocks2
//******************************************************* N_InitTextBlocks2 ***
// Initialized Elements in given records array of Text Blocks data 
// (TN_OneTextBlock)
//
//     Parameters
// ARA         - Text Blocks data records array
// ABegInd     - Text Blocks records array start element index
// ANumInds    - number of elements to initialize
// ACountUDRef - if =TRUE then IDB objects references counting is permited if 
//               new Text Blocks data records array should be created
//
// Given records array should be created or it's length should be increased to 
// needed size.
//
procedure N_InitTextBlocks2( var ARA: TK_RArray; ABegInd, ANumInds: integer;
                                                         ACountUDRef: boolean );
var
  NumElems: integer;
begin
  NumElems := ABegInd + ANumInds;

  if ARA = nil then // Create new RArray
  begin
    if ACountUDRef then
      ARA := K_RCreateByTypeCode( N_SPLTC_OneTextBlock, NumElems, [K_crfCountUDRef] )
    else
      ARA := K_RCreateByTypeCode( N_SPLTC_OneTextBlock, NumElems, [] );
  end; // if ARA = nil then // Create new RArray

  if ARA.ALength() < NumElems then
    ARA.ASetLength( NumElems );

  N_InitTextBlocks( ARA, ABegInd, ANumInds );
end; // procedure N_InitTextBlocks2

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\N_CopyTextBlock
//********************************************************* N_CopyTextBlock ***
// Copy given Text Block data
//
//     Parameters
// APSrcTextBlock - pointer to source Text Block data record
// APDstTextBlock - pointer to destination Text Block data record
// ACountUDRef    - if =TRUE then IDB objects references counting is permited 
//                  while Text Blocks data copy
//
// Reference to font UDRArray (OTBNFont field) remains the same (if any).
//
procedure N_CopyTextBlock( APSrcTextBlock, APDstTextBlock: TN_POneTextBlock;
                                                           ACountUDRef: boolean );
var
  MDFlags: TK_MoveDataFlags;
  FullTCode: TK_ExprExtType;
begin
  if (APSrcTextBlock = nil) or (APDstTextBlock = nil) then Exit; // a precaution

//  APDstTextBlock^ := APSrcTextBlock^;
//  Exit;

  MDFlags := [K_mdfCopyRArray];
  FullTCode.All := 0;
  FullTCode.DTCode := N_SPLTC_OneTextBlock;
  if ACountUDRef then MDFlags := MDFlags +[K_mdfCountUDRef];

  K_MoveSPLData( APSrcTextBlock^, APDstTextBlock^, FullTCode, MDFlags );
end; // procedure N_CopyTextBlock

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\N_ParseHTMLToTextBlocks
//************************************************* N_ParseHTMLToTextBlocks ***
// Parse given HTML text into Records Array of Text Blocks
//
//     Parameters
// AHTML       - source HTML text
// ATextBlocks - Text Blocks data records array
// AOCanv      - Own Canvas Object
// ACountUDRef - if =TRUE then IDB objects references counting is permited
//
// Information about parsing errors is dumped to  Log Channel with 
// N_PCIHTMLParser index. Following error strings can be dumped to Log File: 
// 'Empty Src', 'Undefined Tag', 'Tag Stack Ind < 0'
//
procedure N_ParseHTMLToTextBlocks( AHTML: string; var ATextBlocks: TK_RArray;
                                     AOCanv: TN_OCanvas; ACountUDRef: boolean );
var
  CurTBInd, StackInd: integer;
  NewBlockForText: boolean;
  CurTag, CurValue, ConvErrStr, OKSrc: string;
  PHTML, SavedPHTML: PChar;
  PCurTextBlock, PPrevTextBlock: TN_POneTextBlock;
  PNFont: TN_PNFont;
  ATBIndsStack: TN_IArray; // Indexes to ATextBlocks Stack
  CurPortion: TN_HTMLPortion;
  TmpTextBlock: TN_OneTextBlock;

  Label EndOfHTML, Err;

  procedure AddErrInfo( AStr: string ); // local
  // Add given AStr to Log Channel
  begin
    N_LCAdd( N_LCIHTMLParser, AStr );
  end; // procedure AddErrInfo - local

  function PrepNFont(): TN_PNFont; // local
  // Convert PCurTextBlock.OTBNFont to RArray and clear NFHandle
  var
    MDFlags: TK_MoveDataFlags;
  begin
    if Not (PCurTextBlock.OTBNFont is TK_RArray) then // convertion is needed
    begin
      MDFlags := [K_mdfCopyRArray];
      if ACountUDRef then MDFlags := MDFlags +[K_mdfCountUDRef];

      N_UDToRA( PCurTextBlock.OTBNFont, MDFlags );
    end; // if Not (PCurTextBlock.OTBNFont is TK_RArray) then // convertion is needed

    Result := TN_PNFont( TK_RArray(PCurTextBlock.OTBNFont).P());
    Result^.NFHandle := 0;
  end; // function PrepNFont() - local

  procedure AddNewTextBlock(); // local
  // Create New TextBlock and Add it to ATextBlocks RArray as last record:
  // - Add new last record
  // - increment CurTBInd and set PCurTextBlock
  // - copy ATextBlocks.ATBIndsStack[StackInd] content to new record (inherit Attribs)
  // - clear OTBMText field
  begin
    Inc( CurTBInd );

    if ATextBlocks.ALength() <= CurTBInd then
      ATextBlocks.ASetLength( N_NewLength(CurTBInd+1) );

    PCurTextBlock  := ATextBlocks.P(CurTBInd);
    PPrevTextBlock := TN_POneTextBlock(ATextBlocks.P(ATBIndsStack[StackInd]));

    TmpTextBlock := PPrevTextBlock^; // debug

    FillChar( PCurTextBlock^, SizeOf(TN_OneTextBlock), 0 );
    N_CopyTextBlock( PPrevTextBlock, PCurTextBlock, ACountUDRef );
    PCurTextBlock^.OTBMText := '';

    TmpTextBlock := PCurTextBlock^; // debug
  end; // procedure AddNewTextBlock() - local

begin //******************************* main body of N_ParseHTMLToTextBlocks
  if ATextBlocks = nil then
    N_InitTextBlocks2( ATextBlocks, 0, 3, ACountUDRef );

  PCurTextBlock := ATextBlocks.P(0);
  PCurTextBlock^.OTBMText := '';
  CurTBInd := 0;
  NewBlockForText := False;
  FillChar( CurPortion, SizeOf(CurPortion), 0 );
  CurPortion.HPStateFlags := [hsfLastSpace]; // to skip leading spaces
//  CurPortion.HPStateFlags := [hsfLastSpace,hsfDumpMode]; // debug mode

  SetLength( ATBIndsStack, 3 );
  StackInd := 0;
  ATBIndsStack[StackInd] := CurTBInd;

  ConvErrStr := 'Empty Src';
  if AHTML = '' then goto Err;
  PHTML := @AHTML[1];

  while True do // main Parse loop
  begin
    SavedPHTML := PHTML; // only for Info about Error

    N_GetHTMLPortion( PHTML, @CurPortion );

    case CurPortion.HPPortionType of

      hptError: // HTML Parser Error, Write to Log and Exit
      begin
        AddErrInfo( '' );
        AddErrInfo( CurPortion.HPErrInfoSL.Text );
        AddErrInfo( '***** Full Src:' );
        AddErrInfo( AHTML );

        AddErrInfo( '' );
        AddErrInfo( '***** Parsed OK Full Src:' );
        OKSrc := Copy( AHTML, 1, integer(@AHTML[1])- integer(SavedPHTML) );
        AddErrInfo( OKSrc );

        N_LCExecAction( N_LCIHTMLParser, lcaFlush );
        Exit;
      end; // hptError: // Write to Log and Exit

      hptEnd: goto EndOfHTML;

      hptText: // Text between Tags
      begin
        if NewBlockForText then // Create New TextBlock
          AddNewTextBlock();

        with PCurTextBlock^ do // add new Text to current TextBlock
          OTBMText := OTBMText + CurPortion.HPText;
      end; // hptText: // Text between Tags

      hptTagOpen: // Start New Tag
      begin
        NewBlockForText := False;
        AddNewTextBlock(); // Create New TextBlock

        CurTag := CurPortion.HPText;

        if CurTag = 'B' then // Bold
        begin
          PNFont := PrepNFont();
          PNFont^.NFBold := 1;
        end else if CurTag = 'I' then // Italic
        begin
          PNFont := PrepNFont();
          PNFont^.NFWin.lfItalic := 1;
        end else if CurTag = 'FONT' then // Font
        begin
          with CurPortion.HPAttribsSL do
          begin
            CurValue := Values['Color'];
            if CurValue <> '' then // Set Font Color
            begin
              PCurTextBlock^.OTBTextColor := N_StrToColor( CurValue );
            end; // if CurValue <> '' then // Set Font Color

            CurValue := Values['Size'];
            if CurValue <> '' then // Change Font Size
            begin
              PNFont := PrepNFont();
              PNFont^.NFLLWHeight := PNFont^.NFLLWHeight *
                                     Power( 1.2, N_ScanInteger( CurValue ) );
            end; // if CurValue <> '' then // Set Font Size

            CurValue := Values['Face'];
            if CurValue <> '' then // Set Font Face
            begin
              PNFont := PrepNFont();
              PNFont^.NFFaceName := CurValue;
            end; // if CurValue <> '' then // Set Font Face
          end; // with CurPortion.HPAttribsSL do
        end  else if CurTag = 'SPAN' then //************** SPAN with Style
        begin
          with CurPortion.HPStyleSL do
          begin
            PNFont := PrepNFont();

            CurValue := Values['COLOR'];
            if CurValue <> '' then // Set Font Color
            begin
              PCurTextBlock^.OTBTextColor := N_StrToColor( CurValue );
            end; // if CurValue <> '' then // Set Font Color

            CurValue := UpperCase( Values['BACKGROUND-COLOR'] );
            if CurValue <> '' then // Set Font Back Color
            begin
              if CurValue = 'TRANSPARENT' then
                PCurTextBlock^.OTBBackColor := N_EmptyColor
              else
                PCurTextBlock^.OTBBackColor := N_StrToColor( CurValue );
            end; // if CurValue <> '' then // Set Font Back Color

            CurValue := Values['FONT-FAMILY'];
            if CurValue <> '' then // Set Font Name
            begin
              PNFont^.NFFaceName := CurValue;
            end; // if CurValue <> '' then // Set Font Name

            CurValue := Values['FONT-SIZE'];
            if CurValue <> '' then // Set Font Size in LLW
            begin
              with PNFont^ do
                NFLLWHeight := AOCanv.GetFontLLWSize( CurValue, NFLLWHeight );
            end; // if CurValue <> '' then // Set Font Size in LLW

            CurValue := UpperCase( Values['FONT-WEIGHT'] );
            if CurValue <> '' then // Set Font Weight
            with PNFont^ do
            begin
              NFWeight := 0;

              if CurValue = 'NORMAL' then
                NFBold := 0
              else if CurValue = 'BOLD' then
                NFBold := 1
              else
                NFWeight := N_ScanInteger( CurValue );
            end; // if CurValue <> '' then // Set Font Weight

            CurValue := UpperCase( Values['FONT-STYLE'] );
            if CurValue <> '' then // Set Font Italic Style
            begin
              if CurValue = 'NORMAL' then
                PNFont^.NFWin.lfItalic := 0
              else
                PNFont^.NFWin.lfItalic := 1;
            end; // if CurValue <> '' then // Set Font Italic Style

            CurValue := UpperCase( Values['TEXT-DECORATION'] );
            if CurValue <> '' then // Set Font Underline and StrikeOut Style
            with PNFont^.NFWin do
            begin
              lfUnderline := 0;
              lfStrikeOut := 0;

              if Pos( 'UNDERLINE',    CurValue ) > 0 then lfUnderline := 1;
              if Pos( 'LINE-THROUGH', CurValue ) > 0 then lfStrikeOut := 1;
            end; // if CurValue <> '' then // Set Font Underline and StrikeOut Style

          end; // with CurPortion.HPStyleSL do
        end else // Undefined Tag
        begin
          ConvErrStr := 'Undefined Tag';
          goto Err;
        end;

        Inc( StackInd );
        if Length(ATBIndsStack) <= StackInd then
          SetLength( ATBIndsStack, N_NewLength(StackInd+1) );

        ATBIndsStack[StackInd] := CurTBInd;
      end; // hptTagOpen: // Start New Tag

      hptTagSingle: // Process Single Tag
      begin
        CurTag := CurPortion.HPText;

        if CurTag = 'BR' then // Break
        begin
          with CurPortion do
            HPStateFlags := HPStateFlags + [hsfLastSpace]; // to skip leading spaces in next line

          with PCurTextBlock^ do // add new Text to current TextBlock
            OTBMText := OTBMText + '<br>';
        end else // Undefined Tag
        begin
          ConvErrStr := 'Undefined Tag';
          goto Err;
        end;

      end; // hptTagSingle: // Process Single Tag

      hptTagClose: // Finish Current Tag
      begin
        NewBlockForText := True;
        Dec( StackInd );

        if StackInd < 0 then
        begin
          ConvErrStr := 'Tag Stack Ind < 0';
          goto Err;
        end;
      end; // hptTagClose: // Finish Current Tag

      else // error, Undefined CurPortionType
      begin
        ConvErrStr := 'Undefined CurPortionType';
        goto Err;
      end;

    end; // case HPPortionType of

  end; // while True do // main Parse loop

  EndOfHTML: //***
  ATextBlocks.ASetLength( CurTBInd + 1 );
  Exit;

  Err: //*****
  AddErrInfo( '' );
  AddErrInfo( 'HTML To TextBlocks Convertion Error: ' +  ConvErrStr );
  AddErrInfo( 'Full Src:' );
  AddErrInfo( AHTML );
  N_LCExecAction( N_LCIHTMLParser, lcaFlush );
end; // procedure N_ParseHTMLToTextBlocks

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\N_GetTBAttributes
//******************************************************* N_GetTBAttributes ***
// Get Attributes string from given Text Blocks data records array
//
//     Parameters
// ATextBlocks - Text Blocks data records array
// Result      - Returns Text Content (OTBMText field value) of some Text Block 
//               in given Text Blocks data records array which contains HTML or 
//               SVG text attributes. Empty string should be returned if Text 
//               Block with attributes is absent/
//
function N_GetTBAttributes( ATextBlocks: TK_RArray ): string;
var
  i: integer;
begin
  Result := '';

  for i := 0 to ATextBlocks.ALength()-1 do
  with TN_POneTextBlock(ATextBlocks.P(i))^ do
  begin

    if OTBType = tbtAttr then
    begin
      Result := OTBMText;
      Exit;
    end; // if OTBType = tbtAttr then

  end; // with ... do, for i := 0 to ATextBlocks.ALength()-1 do
end; // function N_GetTBAttributes

//##path N_Delphi\SF\N_Tree\N_CompCL.pas\N_DoOneDimLayout
//******************************************************** N_DoOneDimLayout ***
// Do One Dimensional Layout algorithm to elements in given data
//
//     Parameters
// APLayout - pointer to One Dimensional Layout algorithm data
//
// Following fields in One Dimensional Layout algorithm data should be set 
// before procedure call: ODLFlags, ODLAlign, ODLSpaceSize, ODLPrefWidth, 
// ODLNumElems and array of ODLElems
//
procedure N_DoOneDimLayout( APLayout: TN_POneDimLayout );
var
  i, j, FirstInd: integer;
  PrevOffs, MinTextWidth, MaxTextWidth, WrkODLSpaceSize, AISpace: float;
  CurSpace, CurFElOffs, CurSpaceSize, FreeSize, MinLeftOfs, RestSize: float;
  LastSpaceAdded: boolean;
//  TmpRow: TN_ODLRow; // for viewing in debugger
  Label FinByCurrent;

begin //*********************** body of N_DoOneDimLayout

  with APLayout^ do
  begin
  LastSpaceAdded := False; // to avoid warning
  MinLeftOfs := 0;         // to avoid warning
  WrkODLSpaceSize := ODLSpaceSize;
  if WrkODLSpaceSize = 0 then WrkODLSpaceSize := 0.0001; // SpaceSize exactly=0 is used as flag
  if ODLUnifSSpace = 0 then ODLUnifSSpace := 100;
  if ODLMaxSpace   = 0 then ODLMaxSpace := N_MaxFloat;

  if Length(ODLRows) < ODLNumElems then
    SetLength( ODLRows, ODLNumElems ); // max possible value

  //********** Split Elelements by ODLRows **************

  ODLNumRows := 0;   // initial value
  FirstInd := 0;     // First Index of curent Row
  PrevOffs := 0;     // length of all previous Elements in current Row
  MinTextWidth := 0; // Min Text Width
  MaxTextWidth := ODLPrefWidth; // initial value, can be increased

  for i := 0 to ODLNumElems-1 do // along all Elements
  with ODLElems[i] do
  begin
    if (FirstInd <= (i-1)) and  // prev. Element belongs to cur. Row exists
       ( ((PrevOffs + ElSize) > MaxTextWidth) or // no place for cur. Element
         ((i - FirstInd) = ODLElemsInRow) )  // Fin Row by Number of Elements
                              then // Fin Row by previous, (i-1)-th Element
    with ODLRows[ODLNumRows] do
    begin
      RowFEInd := FirstInd; // Row First Element Index
      RowNumElems := i - FirstInd;

      if LastSpaceAdded then
      begin
        PrevOffs := PrevOffs - WrkODLSpaceSize;
        Dec( RowNumSpaces );
      end;

      RowMinSize := PrevOffs;

      if MinTextWidth < RowMinSize then MinTextWidth := RowMinSize;
      if MaxTextWidth < RowMinSize then MaxTextWidth := RowMinSize;

      RowNoJustify := False; // not last Row
      Inc( ODLNumRows );
      FirstInd := i;
      PrevOffs := 0;
    end; // Fin Row by previous, (i-1)-th Element

    if (leltNoSpaceAfter in ElFlags) then CurSpace := 0
                                     else CurSpace := WrkODLSpaceSize;

    if ((PrevOffs+ElSize+CurSpace) > MaxTextWidth) or // no place for next Element
       (leltRowBreak in ElFlags) or        // force Row Break
       (i = (ODLNumElems-1))               // Last Element in ODLElems array
                                then // Fin Group by current Element
    with ODLRows[ODLNumRows] do
    begin
      RowFEInd := FirstInd;
      RowNumElems := i - FirstInd + 1;
      RowMinSize := PrevOffs + ElSize;

      if MinTextWidth < RowMinSize then MinTextWidth := RowMinSize;
      if MaxTextWidth < RowMinSize then MaxTextWidth := RowMinSize;

      if (leltRowBreak in ElFlags) or // force Row Break
         (i = (ODLNumElems-1)) then   // Last Element in ODLElems array
        RowNoJustify := True // this Row cannot be justified
      else
        RowNoJustify := False; // this Row can be justified

      Inc( ODLNumRows );
      FirstInd := i+1;
      PrevOffs := 0;
      Continue;
    end; // Fin Group by current Element

    //*** Here: there is place for cur. Element

    with ODLRows[ODLNumRows] do
    begin
      if PrevOffs = 0 then RowNumSpaces := 0; // clear Spaces counter
      PrevOffs := PrevOffs + ElSize + CurSpace; // cur Element in cur Group
      LastSpaceAdded := False;
      if CurSpace > 0 then
      begin
        LastSpaceAdded := True;
        Inc( RowNumSpaces );
      end;
    end;

  end; // with ODLElems[i] do, for i := 0 to ODLNumElems-1 do // along all Elements

  if odlfFixWidth in ODLFlags then
    ODLRealWidth := ODLPrefWidth
  else
    ODLRealWidth := MinTextWidth;

  //*** Here: ODLRows array is OK, calc Elements Offsets



  if ODLAlign = hvaUniformBeg then // Calc min Left Offset for Uniform Layout for all Rows
  begin
    MinLeftOfs := N_MaxFloat;

    for i := 0 to ODLNumRows-1 do // along all ODLRows
    with ODLRows[i] do
    begin
      FreeSize := ODLRealWidth - RowMinSize; // free space for all ADDITIONAL Spaces
      RestSize := FreeSize - 2*ODLUnifSSpace*WrkODLSpaceSize/100; // free space for additional internal spaces

      if RestSize > 0 then
      begin
        AISpace := RestSize / (0.02*ODLUnifSSpace + RowNumSpaces); // Additional Internal Space
        CurFElOffs := 0.01*ODLUnifSSpace*( WrkODLSpaceSize + AISpace );

        if AISpace > ODLMaxSpace then
          CurFElOffs := CurFElOffs + 0.5*( RowNumSpaces*(AISpace - ODLMaxSpace) );
      end else
        CurFElOffs := 0.5 * FreeSize;

      MinLeftOfs := Min( MinLeftOfs, CurFElOffs );
    end; // for i := 0 to ODLNumRows-1 do // along all ODLRows
  end; // if ODLAlign = hvaUniformBeg then // Calc min Left Offset for Uniform Layout for all Rows

  for i := 0 to ODLNumRows-1 do // along all ODLRows
  with ODLRows[i] do
  begin
//    tmprow := ODLRows[i]; // for debug, to see ODLRows[i] in Debugger

    // calc CurFElOffs and CurSpaceSize for current Group

    CurSpaceSize := WrkODLSpaceSize; // for all cases but hvaJustify, hvaUniform, hvaUniformBeg
    FreeSize := ODLRealWidth - RowMinSize; // free space for ADDITIONAL Spaces

    //***** AISpace is needed only for hvaUnifrom and hvaUniformBeg
    //      CurFElOffs is needed only for hvaUnifrom

    RestSize := FreeSize - 2*ODLUnifSSpace*WrkODLSpaceSize/100; // free space for additional internal spaces

    if RestSize > 0 then
    begin
      AISpace := RestSize / (0.02*ODLUnifSSpace + RowNumSpaces); // Additional Internal Space
      if AISpace > ODLMaxSpace then AISpace := ODLMaxSpace;
      CurFElOffs := 0.01*ODLUnifSSpace*( WrkODLSpaceSize + AISpace );

      if AISpace > ODLMaxSpace then
      begin
        CurFElOffs := CurFElOffs + 0.5*( RowNumSpaces*(AISpace - ODLMaxSpace) );
        AISpace := ODLMaxSpace;
      end;
    end else // RestSize <= 0 - no place for additional internal spaces
    begin
      AISpace := 0;
      CurFElOffs := 0.5 * FreeSize;
    end;

    case ODLAlign of

      hvaBeg: begin
        CurFElOffs := 0;
      end;

      hvaCenter: begin
        CurFElOffs := 0.5*FreeSize;
      end;

      hvaEnd: begin
        CurFElOffs := FreeSize;
      end;

      hvaJustify: begin
        CurFElOffs := 0;
        if (RowNumSpaces >= 1) and not RowNoJustify then
          CurSpaceSize := CurSpaceSize + (FreeSize / RowNumSpaces);
      end;

      hvaUniform: begin
        CurSpaceSize := CurSpaceSize + AISpace;
        // CurFElOffs is already OK
      end;

      hvaUniformBeg: begin
        CurSpaceSize := CurSpaceSize + AISpace;
        CurFElOffs := MinLeftOfs; // minimal FElOffs (for hvaUniform case) for all Rows
      end;

    end; // case ODLAlignMode of

    //***** Here: CurFElOffs and CurSpaceSize are OK

    PrevOffs := CurFElOffs;

    for j := 0 to RowNumElems-1 do // along Elements in cur. Row
    with ODLElems[RowFEInd+j] do
    begin
      ElOffs := PrevOffs;

      if odlfCheckElRealSize in ODLFlags then // center Element in ElSize place
        ElOffs := ElOffs + 0.5*(ElSize - ElRealSize);

      ElRowInd := i;
      if (leltNoSpaceAfter in ElFlags) then CurSpace := 0
                                       else CurSpace := CurSpaceSize;
      PrevOffs := PrevOffs + ElSize + CurSpace; // offset of next Element
    end; // for j := 0 to GNumElems-1 do // along Elements in cur. Group

  end; // with ODLRows[i] do, for i := 0 to ODLNumRows-1 do // along all ODLRows
  end; // with PParams^ do
end; // procedure N_DoOneDimLayout


//##path N_Delphi\SF\N_Tree\N_CompCL.pas\N_DoTDPointsLayout
//****************************************************** N_DoTDPointsLayout ***
// Do Two Dimensional Base Points Layout algorithm to elements in given data
//
//     Parameters
// APLayout - pointer to Two Dimensional Layout algorithm data
//
// Following fields in Two Dimensional Layout algorithm data should be set 
// before procedure call.
//
procedure N_DoTDPointsLayout( APLayout: TN_PTDPointsLayout );
var
  i, j, NX, NY, NFullRows, NFullCols, NLast, NFullElems: integer;
  StepX, StepY, CurX, CurY, OfsX, OfsY: double;
  PDPCur: PDPoint;
  AlignMode: TN_HVAlign;
begin
  OfsX := 0; OfsY := 0; // to awoid warning

  with APLayout^ do
  begin
    if (tdpMode and $0F) = 0 then // Horizontal, from left to right
    begin
      NFullRows := Round(Floor( tdpNPoints / tdpNX ));
      NLast := tdpNPoints - tdpNX*NFullRows; // Num points in Last Row
      StepX := 0;
      if tdpNX >= 2 then StepX := N_RectWidth(tdpFRect) / (tdpNX-1);

      NY := NFullRows;
      if NLast >= 1 then Inc(NY);

      StepY := 0;
      if NY >= 2 then StepY := N_RectHeight(tdpFRect) / (NY-1);

      //***** Calc Coords for Full Rows

      for i := 0 to NFullRows-1 do // vertical loop along Rows
      begin
        CurY := tdpFRect.Top + StepY*i;
        for j := 0 to tdpNX-1 do // horizontal loop along current Row
        begin
          CurX := tdpFRect.Left + StepX*j;
          PDPCur := tdpPOutCoords;
          Inc( PDPCur, i*tdpNX + j );
          PDPCur^ := DPoint( CurX, CurY );
        end; // for j := 0 to tdpNX-1 do
      end; // for i := 0 to NFullRows-1 do

      //***** Calc Coords for Last Row

      CurY := tdpFRect.Top + StepY*NFullRows;
      NFullElems := tdpNX * NFullRows; // Number of Elements in Full Rows

      AlignMode := TN_HVAlign( (tdpMode shr 4) and $0F );

      case AlignMode of
        hvaBeg: OfsX := 0;
        hvaCenter: OfsX := 0.5*( N_RectWidth(tdpFRect) - StepX*(NLast-1) );
        hvaEnd: OfsX := N_RectWidth(tdpFRect) - StepX*(NLast-1);
        hvaJustify: begin
          OfsX := 0;
          StepX := 0;
          if NLast >= 2 then StepX := N_RectWidth(tdpFRect) / (NLast-1);
        end; // hvaJustify: begin
      end; // case AlignMode of

      for j := 0 to NLast-1 do // horizontal loop along Last Row
      begin
        CurX := tdpFRect.Left + StepX*j + OfsX;
        PDPCur := tdpPOutCoords;
        Inc( PDPCur, NFullElems + j );
        PDPCur^ := DPoint( CurX, CurY );
      end; // for j := 0 to NLast-1 do

    end; // if (tdpMode and $0F) = 0 then // Horizontal, from left to right

    if (tdpMode and $0F) = 2 then // Vertical, from top to bottom
    begin
      NFullCols := Round(Floor( tdpNPoints / tdpNY ));
      NLast := tdpNPoints - tdpNY*NFullCols; // Num points in Last Column
      StepY := 0;
      if tdpNY >= 2 then StepY := N_RectHeight(tdpFRect) / (tdpNY-1);

      NX := NFullCols;
      if NLast >= 1 then Inc(NX);

      StepX := 0;
      if NX >= 2 then StepX := N_RectWidth(tdpFRect) / (NX-1);

      //***** Calc Coords for Full Columns

      for i := 0 to NFullCols-1 do // horizontal loop along Columns
      begin
        CurX := tdpFRect.Left + StepX*i;
        for j := 0 to tdpNY-1 do // vertical loop along current Column
        begin
          CurY := tdpFRect.Top + StepY*j;
          PDPCur := tdpPOutCoords;
          Inc( PDPCur, i*tdpNY + j );
          PDPCur^ := DPoint( CurX, CurY );
        end; // for j := 0 to tdpNY-1 do
      end; // for i := 0 to NFullCols-1 do

      //***** Calc Coords for Last Column

      CurX := tdpFRect.Left + StepX*NFullCols;
      NFullElems := tdpNY * NFullCols; // Number of Elements in Full Clumns

      AlignMode := TN_HVAlign( (tdpMode shr 4) and $0F );

      case AlignMode of
        hvaBeg: OfsY := 0;
        hvaCenter: OfsY := 0.5*( N_RectHeight(tdpFRect) - StepY*(NLast-1) );
        hvaEnd: OfsY := N_RectHeight(tdpFRect) - StepY*(NLast-1);
        hvaJustify: begin
          OfsY := 0;
          StepY := 0;
          if NLast >= 2 then StepY := N_RectHeight(tdpFRect) / (NLast-1);
        end; // hvaJustify: begin
      end; // case AlignMode of

      for j := 0 to NLast-1 do // vertical loop along Last Column
      begin
        CurY := tdpFRect.Top + StepY*j + OfsY;
        PDPCur := tdpPOutCoords;
        Inc( PDPCur, NFullElems + j );
        PDPCur^ := DPoint( CurX, CurY );
      end; // for j := 0 to NLast-1 do

    end; // if (tdpMode and $0F) = 2 then // Vertical, from top to bottom

  end; // with APLayout^ do
end; // procedure N_DoTDPointsLayout

type TN_SplitStringData = packed record //***** SplitString Inp and Out params
  SSDMaxWidth: integer;    // given Max Row width in pixels
  SSDFont:     TObject;    // given NFont (VArray of TN_NFont)
  SSDMaxNumChars: integer; // given Max Number of characters in Row
  SSDResNumRows:  integer; // Resulting Number of Rows
  SSDResString:   string;  // Resulting String (input string with inserted $0D $0A chars)
  SSDResStringList: TStringList; // Resulting Rows
end; // type TN_SplitStringData = packed record //***** SplitString Inp and Out params

//***************************************************  N_SplitStringBySize  ***
// Return given string AStr with inserted CR LF characters ($0D $0A)
//
procedure N_SplitStringBySize( AStr: string; var AData: TN_SplitStringData );
begin

end; // procedure N_SplitStringBySize

{
Initialization
  K_RegRAInitFunc( 'TN_OneTextBlock', N_InitTextBlocks );
}
end.


