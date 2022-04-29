unit N_Gra2;
// low level drawing pocedures and structures
//
//   Main types:
//
// TN_OCanvType    = ( octNotDef, octOwnRaster, octRFrameRaster, octCoordsOnly, octEMF, octPrinter );
// TN_PictPlace    = ( ppUpperLeft, ppCenter, ppRepeat );
// TN_RasterType   = ( rtBMP, rtRArray, rtPascArray );
// TN_Raster       = packed record //***** Raster with transparency Mask
// TN_DrawDashRectPar = record // param. type for N_DrawDashRect procedure
// TN_OCanvCoords  = record // all OCanv Coords fields, changed by UDComponent
// TN_OPCRow       = packed record //********************** One Pixel Color Row
// TN_CRect        = record //********************** Color Rect
// TN_OCanvas      = class( TObject ) //***** Own Canvas
// TN_DIBObj       = class // Windows DIB as Object
// TN_PatPalEntry  = record // Pattern Palette Entry
// TN_PatternPalette = class( TOBject ) //***** Pattern Palette
// TN_Metafile     = class( TObject ) //***** parse, analize, create EnhMetafiles
// TN_RasterObj    = class( TObject ) // Raster as Object

// {$DEFINE CheckTime}
//{$R-} // Disable Range Checking
//{$R+} // Enable Range Checking

interface
uses Windows, Classes, Graphics, Controls, StdCtrls,
     N_Types, N_Lib0, N_Lib1, N_Gra0, N_Gra1, N_Gra6;

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvType
type TN_OCanvType  = ( // Resulting Graphic Device type enumeration
  octNotDef,       // undefine Graphic Device Context type
  octOwnRaster,    // own raster buffer
  octRFrameRaster, // Raster Frame buffer
  octCoordsOnly,   // text file in *.SVG, *.HTML (VML graphics) or *.HTML (image
                   // Map) formats
  octEMF,          // Windows Enhanced MetaFile
  octPrinter       // printer
  ); // type TN_OCanvType

//##/*
type TN_PictPlace  = ( ppUpperLeft, ppCenter, ppRepeat );
type TN_RasterType = ( rtDefault, rtBArray, rtRArray, rtBMP, rtOCanv );
// rtDefault - may be used as input Param and would be converted to some other type,
// rtBArray  - Raster, Mask and Palette are Pascal arrays of Byte (used for runtime rasters)
// rtRArray  - Raster, Mask and Palette are RArrays and can be saved to Archive
// rtBMP     - all content is TBitmap objects (used for runtime rasters)
// rtOCanv   - Raster and Palette are external OCanv fields and are not owned by Raster

type TN_Raster = packed record //***** Raster with transparency Mask, used in obsolete TN_RasterObj
  RType:  TN_RasterType;  // Raster implementation Type
  RPixFmt: TPixelFormat;  // Raster Pixel Format
  RWidth:  integer;       // Raster Width in pixels
  RHeight: integer;       // Raster Height in pixels
  RTranspColor: integer;  // Color for visualising Transparent Raster Pixels
                          // (it should be absent in other Raster pixels)
  RTranspIndex:  integer; // Color Index of RTranspColor for palette rasters
  RNumPalColors: integer; // Number of Colors in Palette
  RDPI:          TFPoint; // Raster X,Y Resolution (in DPI)

                          // Mask is Pascal array of Byte, used for runtime rasters
  RasterRA: TObject;      // Raster pixels as TK_RArray of Byte
  RasterBA: TN_BArray;    // Raster pixels as TN_BArray (not saved to Archive)

  RMaskRA:  TObject;      // Transparency Mask as TK_RArray of Byte
  RMaskBA:  TN_BArray;    // Transparency Mask as TN_BArray (not saved to Archive)

  RPalRA:   TObject;      // Raster Palette as TK_RArray of Integer
  RPalIA:   TN_IArray;    // Raster Palette as TN_IArray (not saved to Archive)
                          // (RPalRA would be saved, RPalIA - not, $FF is Blue)
  RBMP:     TBitmap;      // Raster as BMP (for rtBMP rasters) without Mask
                          // (RBMP never saved to Archive)
end; // type TN_Raster = packed record
type TN_PRaster = ^TN_Raster;
//##*/

//##/*
// ## closed for next doc portion ## //
type TN_DrawDashRectPar = record // param. type for N_DrawDashRect procedure
  DstCanvas: TCanvas; // Destination Canvas
  OutRect:  TRect;    // Outer Rect coords in Pixels
  InRect:   TRect;    // Inner Rect coords in Pixels
  DashSize: integer;  // Dash (and holes) Size (Length) in Pixels
  Phase:    integer;  // Initial Phase in Pixels
  Color1:   integer;  // Dashes Color
  Color2:   integer;  // Holes Color
end; // type TN_DrawDashRectPar = record

type TN_OCanvCoords = record // all OCanv Coords fields, changed by Component
  SavedU2P:    TN_AffCoefs4; // User To Pixel AffCoefs4
  SavedP2U:    TN_AffCoefs4; // Pixel To User AffCoefs4

  SavedU2P6:   TN_AffCoefs6; // User To Pixel AffCoefs6
  SavedP2U6:   TN_AffCoefs6; // Pixel To User AffCoefs6
  SavedP2PWin: TXFORM;       // Pixel to Pixel Windows Transformation coefs.

  SavedMaxUClipRect: TFRect; // Max Clip Rect in User Coords
  SavedMinUClipRect: TFRect; // Min Clip Rect in User Coords
  SavedPClipRect:    TRect;  // Clip Rect in Pixel Coords
  SavedUserAspect:   double; // User Coords Aspect

  SavedUseAffCoefs6: boolean; // Use SavedU2P6 and SavedP2U6 coefs.
  SavedUseP2PWin: boolean;    // Use Pixel to Pixel Windows Transform coefs.
end; // type TN_OCanvCoords = record
type TN_POCanvCoords = ^TN_OCanvCoords;
//##*/

//##/*
type TN_OPCRow = packed record //********************** One Pixel Color Row
            // first four Ints are used while Sorting and should not be moved!
  OPCRCode: integer;     // Code or Color
  OPCRXInd: integer;     // X Index
  OPCRY:    integer;     // Y Coord
  OPCRMaxLeft:  integer; // Maximal Left X Coord
  OPCRMinLeft:  integer; // Minimal Left X Coord
  OPCRMaxRight: integer; // Maximal Right X Coord
  OPCRMinRight: integer; // Minimal Right X Coord
end; // type TN_OPCRow = packed record
type TN_POPCRow = ^TN_OPCRow;
type TN_OPCRowArray = array of TN_OPCRow;

type TN_CRect = record //********************** Color Rect
  CRCode: integer;
  CRect: TRect;
end; // type TN_CRect = record
type TN_CRectArray = array of TN_CRect;
//##*/

type TN_DIBObj = class; // forvard reference

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas
{type} TN_OCanvas = class( TObject ) // Own Canvas Object
  OCanvType: TN_OCanvType;  // resulting Graphic Device type
  CPixFmt: TPixelFormat;    // resulting  DIB Section pixel format
  CollectInvRects: boolean; // collect Invalidate Rectangles while drawing flag
  UseAffCoefs6:    boolean; // use Six Affine Transformation Coefficients from 
                            // User coordinates to pixels (U2P6) and pixels to 
                            // User coordinates (P2U6) instead of Four Affine 
                            // Transformation Coefficients flag
  UseP2PWin:       boolean; // use Windows GDI linear transformation between 
                            // world space and page space coordinates convertion
                            // flag (for scale, rotate, shear, or translate)
  GMAdvanced:      boolean; // indicates whether the resulting Windows GDI 
                            // device (HMDC) advanced graphics mode was set flag
  UseBackBuf:      boolean; // Main resulting buffer should be copied to Back 
                            // buffer after any redrawing flag
//##/*
  OCanvReserved1:  byte; // for alignment
//##*/

//##/*
  RFrameCounter: integer;  // number of Raster Frames (RFrames) (usually =1) which are used this canvas object for drawing
  HMDC: HDC;            // Windows GDI Context Handle to Main buffer
  HMDS: HBitMap;        // Windows GDI Context Handle to Main buffer DIB Section
  MPixPtr: TN_BytesPtr; // pointer to Main buffer pixels
  HMIniBMP: HBitMap;    // initial Main buffer GDI Context (HMDC) Bitmap (for destroying only)
  HBDC: HDC;            // Windows GDI Context Handle to Back buffer
  HBDS: HBitMap;        // Windows GDI Context Handle to Back buffer DIB Section
  BPixPtr: TN_BytesPtr; // pointer to Back buffer pixels
  HBIniBMP: HBitMap;    // initial Back buffer GDI Context (HMDC) Bitmap (for destroying only)

  CCRSize:  TPoint;    // current Canvas Rectangle Size (X,Y) in pixels, CurCRect=(0,0,CCRSize.X-1,CCRSize.Y-1)
  CurCRect: TRect;     // current Canvas Rectangle in pixels (visible rectangle to draw)
  DIBSize: TPoint;     // DIB Section Size (X,Y) in pixels, DIBSize >= CCRSize
  MinDIBMemSize: integer; // minimal Buffer Size in bytes

  InvRects: TN_IRArray;     // array of Invalidated (changed while drawing) Rectangels
  NumInvRects: integer;     // number of actual elements in InvRects array
  PrevNumInvRects: integer; // previous number of actual elements in InvRects array (changed while previous drawing phase, used in RFrame.ShowNewPhase)

  U2P:  TN_AffCoefs4;     // Four User to Pixel coordinates Affine Transformation Coefficients
  P2U:  TN_AffCoefs4;     // Four Pixel to User coordinates Affine Transformation Coefficients
  U2P6: TN_AffCoefs6;     // Six User to Pixel coordinates Affine Transformation Coefficients
  P2U6: TN_AffCoefs6;     // Six Pixel to User coordinates Affine Transformation Coefficients
  P2PWin: TXFORM;         // Windows GDI data structure (XFORM) for World coordinates convertion
  MaxUClipRect: TFRect;   // maximal User coordinates clippong rectangle
                          // (if coords are inside MaxUClipRect they could not
                          // be clipped (as vectors) - Windows will do it
                          // otherwise vector topological clipping is needed)
                          // (in Win98 - MaxUClipRect=N_Max9XPRect in User Coords
  MinUClipRect: TFRect;   // minimal User coordinates clipping rectangle
                          // (if drawing object envelope rectangle is out of MinUClipRect it is
                          // not visible and can be not drawn - can be skipped)
                          // (usually SelfMaxPREct+50 Pix in User Coords)
  OCPixelAspect: double;  // One Pixel aspect (PixYSize/PixXSize)
                          // (Screen or Printer media property, usually = 1)
                          // (OCPixelAspect <> 1 only if visual quadrat have
                          //  different X,Y Pixel sizes, now not implemented)
  OCUserAspect: double;   // User coordinates aspect (for (0,0,PixDX,PixDY) rectangle needed
                          // aspect is OCPixAspect*OCUserAspect*(PixDY/PixDX),
                          // (almost always =1, =0 means that any aspect is OK,
                          // value not equal 1 only could be used only if visual quadrat
                          // should have different X,Y sizes in User Units)

  CurLLWPixSize: double;  // current(Dst or Src) value of one Logical Line Width unit in Pixels  (usually =1pt)
  CurLSUPixSize: double;  // current(Dst or Src) value of one Logical Size Unit in Pixels        (usually =1pt)
  CurLFHPixSize: double;  // current(Dst or Src) value of one Logical Font Height unit in Pixels (usually =1pt)

//##/*
  UClipRectRing: TDRect;  // User  coordinates clipping Rectangle for current Ring
  PClipRectRing: TRect;   // Pixel coords Clipping Rect for current Ring
  U2PRing: TN_AffCoefs4;  // User to Pixel coordinates conv.coefs. for current Ring
//##*/

  MetaFile: TMetafile;    // resulting Windows Enhance metafile
  MetafileCanvas: TMetafileCanvas; // resulting Windows Enhance metafile surface
                                   // on which to draw a metafile image
//##/*
  SI2P4: TN_AffCoefs4;     // Sign Internal to Pixel coordinates 4 convertion coefficients
  SI2P6: TN_AffCoefs6;     // Sign Internal to Pixel coordinates 6 convertion coefficients

  WrkDLA1:   TN_ADPArray;  // working area 1 for clipping and converting
  WrkDLA2:   TN_ADPArray;  // working area 2 for clipping and converting
  WrkCILine: TN_IPArray;   // working area for coords converting
  WrkPoints: TN_IPArray;   // working area for Delphi coords arrays
  WrkBytes:  TN_BArray;    // working area for Delphi point flags arrays
  WrkInts:   TN_IArray;    // working area for Delphi integer arrays
  WrkPixDashes: TN_IArray; // working area for pixel Dash sizes for ExtCreatePen
  WrkStrPixRect: TRect;    // for output string PixRect in DrawUserString

  WrkOutLengths: TN_IArray;   //
  WrkOutFLines:  TN_AFPArray; //
  WrkOutDLines:  TN_ADPArray; //
//##*/

         //**************************** Own Graphic Context  ************
  ConPenColor:     integer; // Pen Color selected in Windows Device Context
  ConPenStyle:     integer; // Pen Flags selected in Windows Device Context
  ConPenPixWidth:  integer; // Pen Width in pixels selected in Windows Device 
                            // Context (>=1)
  ConPenLLWWidth:    float; // Pen Width in LLW
  ConMaxSize:        float; // polyline vertexes maximal size (for wide 
                            // polylines only)
  ConAngleStyle:   integer; // polyline vertexes angle style (for wide polylines
                            // only)
  ConBrushColor:   integer; // Brush Color selected in Windows Device Context
  ConBrushStyle:   integer; // Brush style N_ClearStyle or N_SolidStyle
  ConFontHandle:     HFont; // Windows GDI Font Handle
  ConTextColor:    integer; // text Color (Font Foreground Color)
  ConBackColor:    integer; // back Color (Font Background Color)
  ConCharsExtPix:  integer; // extra space (in Pixels) to add after each Char
  ConBreaksExtPix: integer; // whole Extra Space (in Pixels) to add
  ConNumBreaks:    integer; // number of Break Chars 
                            // (ConAllBreaksExtPix/ConNumBreaks is added to each
                            // Break Char)

//##/*
  ConTicP1:       TDPoint; // starting Tic Segment Point in User coordinates
  ConTicP2:       TDPoint; // final Tic Segment Point in User coordinates
  ConTicZBase:    double;  // Base Tic Z coordinate (X for horizontal ConTicSegm)
  ConTicZStep:    double;  // Tic Z Step (along X for horizontal ConTicSegm)
  ConTicInd1:     integer; // precalculated Tic index 1
  ConTicInd2:     integer; // precalculated Tic index 2
  ConSegm:     TN_DPArray; // segment coordinates (used in DrawUserPoly)
  ConRingDirection: integer; // 0-Counterclockwise, 1-Clockwise
  ConOnePix:      integer; // =1 in GM_COMPATIBLE mode or =0 in GM_ADVANCED mode
//##*/
  ConPClipRect:   TRect;   // pixel coordinates Clipping Rectangle

  ConWinPolyLine:   boolean; // Windows polyline draw mode (use Winows.Polyline 
                             // if TRUE or Winows.Polygon if FALSE)
  ConClipPolyLine:  boolean; // polyline clip mode (use ClipLine if TRUE or 
                             // ClipRing if FALSE)
  ConDelCurHFont:   boolean; // delete current context font (HFont) after 
                             // selecting new font (HFont) in HMDC
  CorrectLastPixel: boolean; // polyline lst pixel mode (if TRUE, add one pixel 
                             // to the end of polyline)
  MinAngleStep:       float; // angle step in degree, for converting curves to 
                             // polylines
//##/*
  FullRgnH:            HRgn; // instead of Empty Clip Region (needed for Corel EMF)
//##*/

//##/*
  constructor Create ();
  destructor  Destroy; override;
//##*/

  procedure InitOCanv          ();
  procedure ClearSelfByColor   ( AClearColor: integer );
  procedure CreateBackBuf      ();
  procedure CopyWholeToBack    ();
  procedure CopyWholeToMain    ();
  procedure CopyInvRectsToBack ();
  procedure CopyInvRectsToMain ();
  procedure ClearPrevPhase     ();
  procedure FixPhase           ();
//##/*
  function  GetPixColor ( AX, AY: integer ): integer;
//##*/

  procedure SetCurCRectSize( AWidth, AHeight: integer; APixFmt: TPixelFormat=pfDevice);

  procedure BeginMetafile ( APixWidth, APixHeight: integer );
  procedure EndMetafile   ();
  function  IncreaseURect ( AURect: TFRect; ADeltaPix: integer): TFRect;
  procedure SetUserCoordsSameToPixel ();

  procedure AdvancedMode  ( ASet: boolean = True );
  procedure SetCoefs      ( const AURect: TFRect; const APRect: TRect;
                                 ATransfType: TN_CTransfType = ctfNoTransform );
  procedure SetUClipRect  ( const APRect: TRect );
  procedure SetCoefsAndUCRect   ( const AURect: TFRect; const APRect: TRect;
                                  ATransfType: TN_CTransfType = ctfNoTransform );
  procedure SetIncCoefsAndUCRect( const AURect: TFRect; const APRect: TRect;
                                  ATransfType: TN_CTransfType = ctfNoTransform );

  function  LLWToPix    ( ASizeInLLW: float ): integer;
  function  LLWToPix1   ( ASizeInLLW: float ): integer;
  function  PixToLLW    ( ASizeInPix: integer ): float;
  function  ShiftPixRectByLSURect ( AInpPixRect: TRect; AShiftRect: TFRect ): TRect;
  function  LSUToUserX  ( ASizeInLSU: float ): double;
  function  LSUToUserY  ( ASizeInLSU: float ): double;
  function  ShiftUPoint ( AUPoint: TDPoint; ALSUShift: TPoint ): TDPoint;
  function  UserRect    ( AUSPoint: TDPoint; ALSURect: TFRect ): TFRect;
//##/*
  function  CalcULStrPixShift ( AStr: string; APStrPos: TN_PStrPosParams = nil ): TFPoint;
//##*/
  function  CalcStrPixRect    ( AStr: string; const APixBasePoint: TFPoint;
                         APStrPos: TN_PStrPosParams; APBasePoint: PFPoint = nil ): TFRect;

  procedure SetBackColor    ( ABackColor: integer );
  procedure SetPenAttribs   ( APenColor: integer; AStrAttr: string ); overload;
  procedure SetPenAttribs   ( APenColor: integer; APenWidth: float = 1.0;
                              APenStyle: integer = 0; APDashSizes: PFloat = nil;
                                            ANumDashes: integer = 0 ); overload;
  procedure SetBrushAttribs ( ABrushColor: integer );
  procedure SetFontAttribs  ( ATextColor: integer = 0; ABackColor: integer = N_EmptyColor;
                              ABreaksExtPix: integer = 0; ANumBreaks: integer = 0 );
  procedure GetStringSize ( AStr: string; out AWidth, AHeight: integer );
//##/*
  procedure SetFontSize   ( SizeMode: integer; const DXU, DYU: double;
                                                             Str: string );
//##*/
  procedure SetExtraSpace ( AAllCharsPix, ABreakCharPix, ANumBreaks: integer );

  procedure SetPClipRect  ( const APClipRect: TRect );
  procedure RemovePClipRect ();

  procedure DrawPixRect  ( const ARect: TRect ); overload;
  procedure DrawPixRect  ( const ARect: TRect; AAttrType: integer;
                                               APAttribs: Pointer ); overload;
  procedure DrawUserRect ( const AUserRect: TFRect );
//  procedure DrawUserPoint( const UserBP: TDPoint; const Params: TN_PointAttr1 );
  procedure DrawPixRoundRect ( const ARect: TRect; ARoundRad: TPoint;
                            ABrushColor, APenColor: integer; APenWidth: Float );
//##/*
  procedure DrawUserRoundRect  ( const UserRect: TFRect; RoundSizeXY: TFPoint );
//##*/
  procedure DrawPixFilledRect  ( const ARect: TRect );
  procedure DrawUserFilledRect ( const AUserRect: TFRect );
  procedure DrawPixFilledRect2 ( const ARect: TRect; AColor: integer );
  procedure DrawPixRectBorder  ( const ARect: TRect; APixBorderWidth: integer );
  procedure DrawPixRectBorder2 ( const ARect: TRect; APixBorderWidth, ABorderColor: integer );
  procedure DrawPixRectDashBorder( const ARect: TRect; ABorderWidth,
                                    ADashSize, ADashStep, ADashPhase: integer );
  procedure DrawDashedRect     ( const AParams: TN_DrawDashRectPar ); overload;
  procedure DrawDashedRect     ( const ARect: TRect; ADashSize, AColor1, AColor2: integer ); overload;
  procedure DrawPixDashedRect  ( APixRect: TRect; ADashPixSize: integer );
  procedure DrawPixColorRects  ( ACRects: TN_CRectArray; ANumRects: integer );
//##/*
  procedure DrawPixGrid        ( ARect: TRect; ASizeX, ABordX, ANumX,
                                 ASizeY, ABordY, ANumY, AFillColor1, AFillColor2,
                                 ABordColor, AFontColor: integer );
//##*/
  procedure DrawPixEllipse       ( APixRect: TRect ); overload;
  procedure DrawPixEllipse       ( APixRect: TRect; ABrushColor: integer;
                                   APenColor: integer = 0; APenWidth: float = 1 );  overload;
  procedure DrawUserRectEllipse  ( AUserRect: TFRect );
  procedure DrawUserPointEllipse ( AUserPoint: TDPoint; ASizeXY: TFPoint );

  procedure DrawPixPolyline ( var APoints: TN_IPArray; ANumPoints: integer );
  procedure DrawPixPolygon  ( APoints: TN_IPArray; const ANumPoints: integer );
  procedure DrawPixRectSegments ( APenColor: integer; APenWidth: float; APixRect: TRect; ASegmFlags: integer );
  procedure DrawCurPath     ( ABrushColor, APenColor: integer; APenWidth: float;
                              APenStyle: integer = 0; APDashSizes: PFloat = nil; ANumDashes: integer = 0 );

  procedure DrawUserFPoly ( AEnvRect: TFRect; APPoints: PFPoint;
                                                 ANPoints: integer ); overload;
  procedure DrawUserFPoly ( APPoints: PFPoint; ANPoints: integer;
                                       APAttribs: TN_PNormLineAttr ); overload;
  procedure DrawUserDPoly ( AEnvRect: TFRect; APPoints: PDPoint;
                                                 ANPoints: integer ); overload;
  procedure DrawUserDPoly ( APPoints: PDPoint; ANPoints: integer;
                                       APAttribs: TN_PNormLineAttr ); overload;
  procedure DrawUserDPoly ( APEnvRect: PFRect; APPoints: PDPoint;
                                                 ANPoints: integer ); overload;
  procedure DrawUserFPoly ( APEnvRect: PFRect; APPoints: PFPoint;
                                                 ANPoints: integer ); overload;
  procedure DrawUserPolyline1 ( APoints: TN_FPArray ); overload;
  procedure DrawUserPolyline2 ( APoints: TN_FPArray; const APenColor: integer;
                                            const APenWidth: float ); overload;
  procedure DrawUserPolyline1 ( APoints: TN_DPArray ); overload;
  procedure DrawUserPolyline2 ( APoints: TN_DPArray; const APenColor: integer;
                                            const APenWidth: float ); overload;
  procedure DrawUserMatrPoints ( APFPoint: PFPoint; ANX, ANY: integer );
  procedure DrawUserSegment    ( AP1, AP2: TDPoint; AAttr: TN_NormLineAttr );
//  procedure DrawUserSysPolyline ( PPoints: PDPoint;
//                              NumPoints: integer; PAttribs: TN_PSysLineAttr );

  procedure PrepWidthVector ( const AP1, AP2: TPoint; AWidth: float;
                                                out AP1Left, AP1Right: TPoint );
  procedure PrepWideSegm ( const AP1, AP2: TPoint; const ASegmWidth: float;
                                                 var APixPolygon: TN_IPArray );
  function  PrepWideVertex ( const AMaxSize: float; AAngleStyle: integer;
                                        var APixPolygon: TN_IPArray ): integer;
  procedure DrawPixStraightArrow  ( const AP1, AP2: TPoint; AFlags: integer;
                                                      AL1, AL2, AW1, AW2: float );
  procedure DrawUserStraightArrow ( const AP1, AP2: TDPoint; AFlags: integer;
                                                      AL1, AL2, AW1, AW2: float );
  procedure DrawWidePolyline ( APoints: TN_IPArray; const ANumPoints: integer );
  procedure DrawDashedPolyline ( APoints: TN_DPArray;
                    const ADashAttribs: TN_DashAttribs; ALoopInd: integer = 0 );

  procedure DrawUserMonoRing  ( ARCoords: TN_DPArray;
                  const AREnvRect: TFRect; ARingDirection, AFillColor: integer );

  procedure DrawUserColorRing ( ARCoords: TN_DPArray;
                                     const AREnvRect: TFRect; ARingDirection,
                             ABrushColor, APenColor: integer; APenWidth: float );

  procedure DrawPixString  ( APixBasePoint: TPoint; AStr: string );
  procedure DrawPixString2 ( APixBasePoint: TPoint; ABasePointPos: TFPoint; AStr: string );
  procedure DrawUserString ( AUserBasePoint: TDPoint; AShiftXY: TFPoint;
                                         ABasePointPos: TFPoint; AStr: string );
  procedure DrawCurveString ( APDPoints: PDPoint; ANumPoints: integer;
                                                                AStr: string );

//  procedure DrawPixRaster  ( APRaster: TN_PRaster; ADstRect, ASrcRect: TRect;
//                ARScale: float; APPlace: TN_PictPlace; AMonoColor: integer );
//  procedure DrawUserRaster ( APRaster: TN_PRaster; UserRect: TFRect;
//                ARScale: float; APPlace: TN_PictPlace; AMonoColor: integer );

  procedure DrawPixBMP  ( ABMP: TBitmap; ASelfRect, ABMPRect: TRect );
  procedure DrawUserBMP ( ABMP: TBitmap; AUserRect: TFRect; ABMPRect: TRect ); overload;
  procedure DrawUserBMP ( ABMP: TBitmap; ABPUser: TDPoint; ABPOfs: TFPoint;
                                  ASizeXY: TFPoint; ABMPRect: TRect ); overload;

  procedure DrawPixDIB  ( ADIB: TN_DIBObj; ASelfRect, ADIBRect: TRect );
  procedure DrawUserDIB ( ADIB: TN_DIBObj; AUserRect: TFRect; ADIBRect: TRect ); overload;
  procedure DrawUserDIB ( ADIB: TN_DIBObj; ABPUser: TDPoint; ABPOfs: TFPoint;
                                  ASizeXY: TFPoint; ADIBRect: TRect ); overload;

  procedure DrawMaskedDIBPlg ( ADIB: TN_DIBObj; ASelfRect, ADIBRect: TRect;
                                             AMask: HBitMap; AMaskShift: TPoint );
  procedure DrawTranspDIB    ( ADIB: TN_DIBObj; ASelfRect, ADIBRect: TRect;
                                                          ATranspColor: integer );
  procedure DrawPixDIBAlfa   ( ADIB: TN_DIBObj; AAlfa: integer );

  procedure DrawPixMetafile  ( AMetafile: TMetafile; ASelfRect, AMetafileRect: TRect );
  procedure DrawUserMetafile ( AMetafile: TMetafile; AUserRect: TFRect; AMetafileRect: TRect ); overload;
  procedure DrawUserMetafile ( AMetafile: TMetafile; ABPUser: TDPoint;
                               ABPOfs: TFPoint; ASizeXY: TFPoint; AMetafileRect: TRect ); overload;

//##/*
  procedure SetTics ( TicP1, TicP2: TDPoint; const TicZBase, TicZStep: double );
  procedure DrawCoordsLines ( ZMin, ZMax: double;
                                            LLWDashSize, LLWSkipSize: float );
  procedure DrawAxisTics  ( TicSize1, TicSize2: integer );
  procedure DrawAxisMarks ( ShiftXY: TFPoint; BasePointPos: TFPoint;
                                                                Fmt: string );
  procedure DrawAxisArrow ( BaseZ: double;
                                     ArrowLength, ArrowWidth, Mode: integer );
  procedure DrawSArrow    ( ASegm: TFRect; SAWidths, SALengths: TFPoint;
                                            AFlags: integer; AColor: integer );
  procedure DrawHatchLines ( HatchAttr: TN_HatchAttr;
                                                DashAttribs: TN_DashAttribs );

  procedure SaveCopyTo ( FileName: string; AFileFmt: TN_ImageFileFormat;
                         PixRect: Trect; APImFPar: TN_PImageFilePar = nil );
//                                  APFile1Params: TN_PFile1Params = nil );
  procedure SaveInBMPFormat ( AFileName: string; ARectToSave: TRect;
                                                 AFileFmt: TN_ImageFileFormat );
//##*/
  function  AddSmallArc    ( var AInts: TN_IArray;  ANumInts, AX0, AY0,
                      ARX, ARY: integer; ABegAngle, AArcAngle: float ): integer;
  function  AddArc         ( var AInts: TN_IArray;  ANumInts, AX0, AY0,
                      ARX, ARY: integer; ABegAngle, AArcAngle: float ): integer;
  function  AddPieSegment  ( var AInts: TN_IArray;  ANumInts, AX0, AY0,
                      ARX, ARY: integer; ABegAngle, AArcAngle: float ): integer;
  function  AddPieFragment( var AInts: TN_IArray; ANumInts, AX0, AY0,
          ARX, ARY: integer; ABegAngle, AArcAngle, AScaleCoef: float ): integer;
//##/*
  function  AddPieSegmSide ( var AInts: TN_IArray;
                                    ANumInts, AX0, AY0, ARX, ARY, DY: integer;
                   ABegAngle, AArcAngle: float; var AAddAngle: float ): integer;
//##*/
  function  GetFontLLWSize ( AHTMLSize: string; ASrcLLWSize: float ): float;
end; // end of TN_OCanvas type


//*************************************************************** TN_DIBObj ***

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj
{type} TN_DIBObj = class // Windows Device Iindependent Bitmap (DIB) envelope Object
  DIBInfo:   TN_DIBInfo;   // BMPInfoHeader and 256-colors Palette or
                           // BitFieldsMasks
  DIBHandle:    HBitmap;   // Windows DIB Handle
  DIBOCanv:  TN_OCanvas;   // Own Canvas Object based upon self DIB (for drawing
                           // in self)
  DIBPixFmt: TPixelFormat; // DIB Pixel Format
  DIBExPixFmt: TN_ExPixFmt;// Extended (own) Pixel Format
  DIBSize:   TPoint;       // DIB Pixel Size (Width, Heigth)
  DIBRect:   TRect;        // DIB Pixel Rect (0, 0, Width-1, Heigth-1)
  DIBTranspColor: integer; // DIB Transparent Color
  DIBNumBits:     integer; // Number of bits in chanel (8 for epfBMP, 9-16 for
                           // epfGray16,epfColor48)
  DIBPixels:    TN_BArray; // Raster Bytes if DIBExPixFmt = epfGray16 or
                           // epfColor48
  PRasterBytes:  TN_BytesPtr; // Pointer to first byte of DIB pixels (returned
                              // by Windows)
  RRBytesInLine: integer;  // Number of bytes with Raster pixels in one scan
                           // line
  RRLineSize:    integer;  // whole Raster scan line size in bytes (DWORD
                           // aligned, RRLineSize >= RRBytesInLine)

  constructor Create ( AWidth, AHeight: integer; APixFmt: TPixelFormat; AFillColor: integer = -1; AExPixFmt: TN_ExPixFmt = epfBMP; ANumBits: integer = 0 ); overload;
  constructor Create ( ASrcDIBObj: TN_DIBObj; ASrcRect: TRect; APixFmt: TPixelFormat; AExPixFmt: TN_ExPixFmt = epfBMP; ANumBits: integer = 0 ); overload;
  constructor Create ( ASrcDIBObj: TN_DIBObj ); overload;
  constructor Create ( ASrcDIBObj: TN_DIBObj; AFlipRotateFlags: integer; APixFmt: TPixelFormat; AFillColor: integer = -1; AExPixFmt: TN_ExPixFmt = epfBMP; ANumBits: integer = 0 ); overload;
  constructor Create ( ABitmap: TBitmap; ATranspColor: integer = -1 ); overload;
  constructor Create ( ASrcOCanv: TN_OCanvas; ASrcRect: TRect; APixFmt: TPixelFormat ); overload;
  constructor Create ( AFileName: string ); overload;

  destructor  Destroy; override;

  procedure ClearSelfObjects ();
  procedure CreateSelfOCanv  ();

  procedure PrepSMatrDescr        ( APSMatrDescr: TN_PSMatrDescr; APMatrSize: PInteger = nil );
  procedure PrepSMatrDescrByFlags ( APSMatrDescr: TN_PSMatrDescr; AFlipRotateFlags: integer; APMatrSize: PInteger = nil );
  procedure PrepSMatrDescrByRect  ( APSMatrDescr: TN_PSMatrDescr; ASelfRect: TRect );
  procedure SetDIBNumBits         ( ANumBits: integer );
//  procedure SetSelfDIBNumBits    ();
//  procedure ReduceNumBits        ();
  procedure FillRectByPixValue   ( APixRect: TRect; APixValue: integer );
  procedure ReadAndConvBMPPixels ( APDIBInfo: TN_PDIBInfo; APPixels: Pointer );
  procedure ReadPixelsFromStream ( AStream: TStream );

  procedure PrepSameDIBObj  ( var AResDIBObj: TN_DIBObj );
  procedure PrepEmptyDIBObj ( AWidth, AHeight: integer; APixFmt: TPixelFormat;
                              AFillColor: integer = -1; AExPixFmt: TN_ExPixFmt = epfBMP;
                              ANumBits: integer = 0 ); overload;
  procedure PrepEmptyDIBObj ( APDIBInfo: TN_PDIBInfo; AFillColor: integer = -1;
                              AExPixFmt: TN_ExPixFmt = epfBMP; ANumBits: integer = 0 ); overload;
  procedure PrepEDIBAndSMD  ( var ADstDIB: TN_DIBObj; AFlipRotateFlags: integer;
                              APSelfSMD, APDstSMD: TN_PSMatrDescr;
                              APixFmt: TPixelFormat; AExPixFmt: TN_ExPixFmt = epfBMP;
                              ANumBits: integer = 0 );
  function  GetInfoString      (): string;
  function  GetElemSizeInBytes (): integer;
  function  SerializedSize     (): integer;
  procedure SerializeSelf   ( AMemPtr: Pointer; AMemSize: integer );
  procedure DeSerializeSelf ( AMemPtr: Pointer );
  procedure SelfToStream    ( AStream: TStream; AComprLevel : Integer );
  function  SelfFromStream  ( AStream: TStream ) : Integer;

  function  GetPixColor        ( AXYCoords: TPoint ): integer;
  function  GetPixGrayValue    ( AXYCoords: TPoint ): integer;
  function  GetPixValue        ( AXYCoords: TPoint ): integer;
  procedure SetPixValue        ( AXYCoords: TPoint; APixValue: integer );

  function  GetPixValuesVector ( var APixValues: TN_IArray; AX1, AY1, AX2, AY2: integer ): integer;
  function  SetPixValuesVector (     APixValues: TN_IArray; AX1, AY1, AX2, AY2: integer ): integer;
  function  GetPixValuesRect   ( var AValues: TN_IArray;    AX1, AY1, AX2, AY2: integer ): integer;
  function  SetPixValuesRect   (     AValues: TN_IArray;    AX1, AY1, AX2, AY2: integer ): integer;
  function  GetPixColorsVector ( var APixColors: TN_IArray; AX1, AY1, AX2, AY2: integer ): integer;
  function  GetPixRGBValuesRect( var ARGBValues: TN_BArray; AX1, AY1, AX2, AY2: integer ): integer;
  function  SetPixRGBValuesRect(     ARGBValues: TN_BArray; AX1, AY1, AX2, AY2: integer ): integer;
//  procedure ConvAndSetPixRGBValues ( AXLatTable, ARGBValues: TN_BArray );

  procedure AddDIBToSelf       ( ASrcDIB: TN_DIBObj );
  procedure CopyRectBy2SM ( ASelfUpperLeft: TPoint; ASrcDIB: TN_DIBObj; ASrcRect: TRect );
  procedure CopyRectAuto  ( ASelfUpperLeft: TPoint; ASrcDIB: TN_DIBObj; ASrcRect: TRect );

  procedure LoadFromBitmap     ( ABitmap: TBitmap );
  function  CreateBitmap       ( ARect: TRect ): TBitmap;
  function  LoadFromBMPFormat  ( AFileName: string ): integer;
  procedure SaveToBMPFormat    ( AFileName: string );
  function  LoadFromCMSIFormat ( AFileName: string ): integer;
  function  SaveToCMSIFormat   ( AFileName: string ): integer;
  function  LoadFromFile       ( AFileName: string ): integer;
  procedure SaveToFile         ( AFileName: string; APImageFilePar: TN_PImageFilePar ); // empty, not implemented
  function  LoadFromStreamByGDIP ( AStream: TStream ): integer;
  function  LoadFromFileByGDIP   ( AFileName: string ): integer;
  procedure SaveToFileByGDIP     ( AFileName: string );
  procedure LoadFromMemBMP       ( AMemPtr: Pointer );
  function  SaveToMemBmp         ( AMemPtr: Pointer; AMemSize: integer ): integer;
  function  SaveToBArrayBMP      ( var ABArray: TN_BArray ): integer;
  function  LoadFromClipborad    (): integer;
  function  SaveToClipborad      (): boolean;

{ // obsolete, use CalcBrighHistNData
  procedure CalcBrighHist8Data  ( var ABrighHistValues: TN_IArray; APRect: PRect = nil;
                                  APMinHistInd: PInteger = nil; APMaxHistInd: PInteger = nil;
                                  APMaxHistVal: PInteger = nil );
  procedure CalcBrighHist16Data ( var ABrighHistValues: TN_IArray; APRect: PRect = nil;
                                  APMinHistInd: PInteger = nil; APMaxHistInd: PInteger = nil;
                                  APMaxHistVal: PInteger = nil );
  procedure CalcBrighHistData   ( var ABrighHistValues: TN_IArray; APRect: PRect = nil;
                                  APMinHistInd: PInteger = nil; APMaxHistInd: PInteger = nil;
                                  APMaxHistVal: PInteger = nil );
}
  procedure CalcBrighHistNData  ( var ABrighHistValues: TN_IArray; APRect: PRect = nil;
                                  APMinHistInd: PInteger = nil; APMaxHistInd: PInteger = nil;
                                  APMaxHistVal: PInteger = nil; ANumBits: integer = 8 );

//  procedure FlipAndRotate  ( AFlipRotateFlags: TN_FlipRotateFlags ); overload;
  procedure FlipAndRotate  ( AFlipRotateFlags: integer );
  procedure RotateByAngle  ( AFlipRotateFlags: integer; AAngle: double;
                             AFillColor: integer; var AResDIB: TN_DIBObj;
                             APPixAffCoefs6: TN_PAffCoefs6 = nil;
                             APNormAffCoefs6:  TN_PAffCoefs6 = nil;
                             AMaxPixelsSize: integer = 0 );
  procedure Rotate90CCW    ();
  procedure Rotate90CW     ();
  procedure Rotate180      ();
  procedure FlipHorizontal ();
  procedure FlipVertical   ();

  procedure XORPixels        ( AXOROP: integer );
  procedure CalcSmoothedMatr ( var ADstMatr: TN_BArray; APCM: PFloat; ACMDim: integer );

  procedure CalcLinCombDIB   ( var ADstDIB: TN_DIBObj; APSrcMatr: Pointer; AAlfa: double );
  procedure XLATSelf         ( APXLAT: PInteger; AXLATType: integer );
  procedure CalcXLATDIB      ( var ADstDIB: TN_DIBObj; AFlipRotateFlags: integer;
                               APXLAT: PInteger; AXLATType: integer;
                               APixFmt: TPixelFormat; AExPixFmt: TN_ExPixFmt = epfBMP );
  procedure CalcGrayDIB      ( AResDIB: TN_DIBObj );
  procedure Convpf8BitToGray8 ();
//  procedure CalcEmbossDIB  ( AResDIB: TN_DIBObj; ADelta: TPoint; out AMin, AMax: integer ); overload;
//  procedure CalcEmbossDIB  ( AResDIB: TN_DIBObj; ADelta: TPoint; ABaseGray: integer; APXLAT: PInteger; out AMin, AMax: integer ); overload;
  procedure CalcEmbossDIB  ( AResDIB: TN_DIBObj; AAngle, ACoef: float; ADepth, ABaseGray: integer ); overload;
  procedure CalcMaxContrastDIB  ( var AResDIB: TN_DIBObj );
  procedure CalcIncrContrastDIB ( var AResDIB: TN_DIBObj; ACoef: double );
  procedure CalcEqualizedDIB ( var AResDIB: TN_DIBObj; ANumRanges: integer; AMaxCoef: float );
  procedure CalcDeNoise1DIB  ( var AResDIB: TN_DIBObj; ANRDepth: Integer; ANRSigma, ANRThresh1, ANRThresh2: Double );
  procedure CalcDeNoise2DIB  ( var AResDIB: TN_DIBObj; ANRDepth: Integer; ANRThresh: Double );
  procedure CalcDeNoise3DIB  ( var AResDIB: TN_DIBObj; ANRDepth: Integer );

  function  GetMaxRGBDif   ( AMaxAllowedDif: double ): double;
  procedure RectToStrings  ( ARect: TRect; AFlags: integer; AName: string;
                             AResStrings: TStrings; APUpperLeft: PPoint = nil; APMatrElems: TN_BytesPtr = nil );
  function  DIBPixToString      ( AX, AY, ANumPix: integer ): string;
  procedure DIBCornersToStrings ( ADIBName: string; AResStrings: TStrings );
  procedure DIBDump2Self        ( ADIBName: string; AIndent: integer );
  procedure DIBSelfToTextFile   ( AFName, ADIBName: string; ARect: TRect; AFlags: Integer );
  procedure DIBSelfToBothFiles  ( AFName, ADIBName: string; ARect: TRect; AFlags: Integer );
  procedure PixelsToStream    ( AStream: TStream );
  procedure StreamToPixels    ( AStream: TStream );
  procedure AddAlfaBytes      ( AAlfaDIBObj: TN_DIBObj );
  procedure GetAlfaBytes      ( var AAlfaDIBObj: TN_DIBObj );
  procedure CorrectResolution ( ADefPelsPerMeter: Integer );
  function  CalcMaxGrayVal       (): Integer;
  function  CalcMinNeededNumBits (): Integer;
  //  procedure DrawPixDIBAlfa   ( ADIB: TN_DIBObj; AAlfa: integer );
end; // type TN_DIBObj = class( TObject )
type TN_PDIBObj = ^TN_DIBObj;
type TN_DIBObjArray = Array of TN_DIBObj;

//##/*

type TN_PatPalEntry = record // Pattern Palette Entry
  PatRect:   TRect;     // Pattern Rect in PatOCanv
  PatWidth: integer;    // Pattern Rect width (to speed up)
                           // PatWidth = 0 means empty enry
  PatHeight: integer;   // Pattern Rect Height (to speed up)
  PatColor: integer;    // used if whole pattern consists of 1 pixel
  PatOCanv: TN_OCanvas; // Pattern OCanvas (for drawing while creating entry)
end; // type TN_PatPalEntry = record
type TN_PatPalEntries = array of TN_PatPalEntry;

type TN_PatternPalette = class( TOBject ) //***** Pattern Palette
  PatPalEntries: TN_PatPalEntries; // Pattern Palette entries
  PatternsBitMap: TBitMap; // BitMap with all patterns
        // (later add several different BitMaps to PatternPalette if needed)
  NumEntries: integer;     // number of filled entries (2<=NumEntries<=256)
  OCanv: TN_OCanvas;       // OCanvas fro drawing into PatternsBitMap
  OfsFreeX:  integer;      //
  OfsFreeY:  integer;
  RowHeight: integer;

  constructor Create ( BitMapWidth, BitMapHeight: integer; PixFmt: TPixelFormat );
  destructor  Destroy; override;
  procedure ClearAllEntries ();
  procedure CreateEntry ( PatInd, APatWidth, APatHeight, FillColor: integer );
  procedure DrawLines   ( PatInd, LColor, LWidth, LStepX,
                                              LStepY: integer; LOfs: double );
  procedure DrawGray    ( PatInd, Style, GrayValue, GrayDotSize: integer );
  procedure ConvRGBColors ( BitMap: TBitMap; ConvRect: TRect;
                               PhaseX, PhaseY, AbsentColor: integer;
                           var NumColors: integer; ColorPalette: TN_IArray );
end; //*** end of type TN_PatternPalette = class( TOBject )

type TN_Metafile = class( TObject ) //***** parse, analize, create EnhMetafiles
  MFBuf:         TN_BArray;      // MetaFile content
  PMFHeader:     PEnhMetaHeader; // Pointer to metafileHeader
  CRPtr:  TN_BytesPtr;   // Pointer to Current Record
  CRInd:  DWORD;   // Current Record Index
  CRType: integer; // Current Record Type
  CRSize: integer; // Current Record Size in bytes
  procedure GetFromFile   ( FileName: string );
  procedure GetNextRecord ( out RPtr: TN_BytesPtr; out RType: integer );
end; // type TN_Metafile = class( TObject )

//***** TN_RasterObj is not used now but can not be simply deleted,
//                   because it is used in other  code:
//                     - in TN_UDPicture - obsolete or should be replaced by TN_DIBObj?
//                     - in TN_FVMatr - probably should be replaced by TN_DIBObj
type TN_RasterObj = class( TObject ) // Raster as Object OBSOLETE!

  RR: TN_Raster;          // Raster Record (Self is not RR Owner!)

  PRasterBytes: TN_BytesPtr;    // pointer to first byte of Raster pixels
  RRasterSize: DWORD;     // Raster Size in bytes (RLineSize * RHeight)
  RRBytesInLine: integer; // Number of bytes with Raster pixels in one scan line
  RRLineSize: integer;    // whole Raster scan line size in bytes (DWORD aligned)

  PMaskBytes: TN_BytesPtr;      // pointer to first byte of Mask pixels
  RMaskSize: DWORD;       // Mask Size in bytes (RMLineSize * RHeight)
  RMBytesInLine: integer; // Number of bytes with Mask bits in one scan line
  RMLineSize: integer;    // whole Mask scan line size in bytes (DWORD aligned)

  PPalColors: PInteger;   // pointer to first Color in Palette ($FF is Blue)

  RDIBInfo: TN_DIBInfo;   // BMPInfoHeader and 256-colors Paltte or BitFieldsMasks

  constructor Create ( ARType: TN_RasterType ); overload;
  constructor Create ( APRaster: TN_PRaster ); overload;
  constructor Create ( APRaster: TN_PRaster; AWidth, AHeight: integer ); overload;
  constructor Create ( ARType: TN_RasterType; AFileName: string;
                       ATranspColor: integer = N_EmptyColor;
                       APixFmt: TPixelFormat = pfDevice ); overload;
  constructor Create ( AOCanv: TN_OCanvas ); overload;
  destructor  Destroy; override;
  procedure InitRasterObj ( ARType: TN_RasterType );
  procedure PrepSelfFields     ();
  procedure PrepSelfByRDIBInfo ();
  procedure PrepRDIBInfoBySelf ();
  procedure SetTranspIndex     ();
  procedure SetPalColors       ( APPalColors: PInteger; ANumColors: integer );
  function  GetPixelValue      ( AX, AY: integer ): integer;
  function  GetPixelColor      ( AX, AY: integer ): integer;
  procedure SetPixelValue      ( AX, AY, APixValue: integer );
  function  GetPixValuesVector ( var APixValues: TN_IArray; AX1, AY1, AX2, AY2: integer ): integer;
  function  GetPixValuesRect   ( var AValues: TN_IArray;    AX1, AY1, AX2, AY2: integer ): integer;
  function  SetPixValuesRect   (     AValues: TN_IArray;    AX1, AY1, AX2, AY2: integer ): integer;
  function  GetPixColorsVector ( var APixColors: TN_IArray; AX1, AY1, AX2, AY2: integer ): integer;
  function  SetPixValuesVector (     APixValues: TN_IArray; AX1, AY1, AX2, AY2: integer ): integer;
  function  GetPixRGBValuesRect( var ARGBValues: TN_BArray; AX1, AY1, AX2, AY2: integer ): integer;
  function  SetPixRGBValuesRect(     ARGBValues: TN_BArray; AX1, AY1, AX2, AY2: integer ): integer;
  procedure ConvRGBValues      ( ASrcRGBValues: TN_BArray; var ADstRGBValues: TN_BArray;
                                 ANumTriples: integer; ARValues, AGValues, ABValues: TN_BArray );

  procedure SaveInBMPFormat   ( AFileName: string; const AFragm: TRect;
                                                   APImageFilePar: TN_PImageFilePar );
  procedure LoadFromBMPFormat ( AFileName: string );
  function  SaveToBMPObj      (): TBitmap;
  procedure LoadFromBMPObj    ( ABMP: TBitmap; APixFmt: TPixelFormat = pfDevice );
  procedure SaveRObjToFile    ( AFileName: string; const ARect: TRect;
                                            APImageFilePar: TN_PImageFilePar = nil );
  procedure LoadRObjFromFile  ( AFileName: string );
  procedure CreateMask        ();
  function  CreateOPCRows     ( ANAZColor: integer;
                                      var AOPCRows: TN_OPCRowArray ): integer;
  procedure ChangeTranspColor ( ANewTranspColor: integer = N_EmptyColor );
  procedure LoadFromOCanv  ( AOCanv: TN_OCanvas; ASrcFragment: TRect;
                                       ATranspColor: integer = N_EmptyColor );
  function  CopySelf       ( ARType: TN_RasterType = rtDefault ): TN_RasterObj;
  function  Create1bitRObj ( ARType: TN_RasterType;
                                AMinColor, AMaxColor: integer ): TN_RasterObj; overload;
  function  Create1bitRObj ( ARType: TN_RasterType;
                      APColors: PInteger; ANumColors: integer ): TN_RasterObj; overload;
  function  Create8bitRObj ( ARType: TN_RasterType; APDynColors: PInteger;
                             ANumDynColors: integer; APStatColors: PInteger;
                     ANumStatColors, AAZColor, ANAZColor, AMode: integer ): TN_RasterObj;
  function  ConvTo8bitRObj ( ARType: TN_RasterType ): TN_RasterObj;
  procedure Draw ( ADC: HDC; ADstRect, ASrcRect: TRect; ARScale: float = 1;
                                       APPlace: TN_PictPlace = ppUpperLeft );
  procedure CalcBrighHistData ( var ABrighHistValues: TN_FArray );
end; // type TN_RasterObj = class( TObject );
//##*/

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_TestDIBParams
type TN_TestDIBParams = packed record // ****** N_CreateTestDIB(8,16) function params
  TDPWidth:       integer; // DID Width in pixels
  TDPHeight:      integer; // DID Height in pixels
  TDPPixFmt: TPixelFormat; // DIB Pixel Format
  TDPNumCellsX:   integer; // Number of cells along X
  TDPNumCellsY:   integer; // Number of cells along Y
  TDPFillColor1:  integer; // Cells Fill Color for Even ix+iy
  TDPFillColor2:  integer; // Cells Fill Color for Odd ix+iy
  TDPBordSize:    integer; // Cells Borders Size (vertical lines Width and 
                           // Horizontal lines height)
  TDPBordColor:   integer; // Cells Borders Color
  TDPIndsColor:   integer; // Font Color for drawing Cell indexes
  TDPString:       string; // String to draw over the grid
  TDPStringColor:  integer; // Font Color for drawing TDPString
  TDPStringHeight: integer; // Font Size for drawing TDPString in pixels
end; // type TN_PTestDIBParams = packed record
type TN_PTestDIBParams = ^TN_TestDIBParams;

type TN_DIBObjCalcSmoothedMatr = procedure ( ADIBObj: TN_DIBObj; var AResMatr: TN_BArray; AApRadius: integer );


//****************** Global procedures **********************

procedure N_PrepDIBObj ( var AResDIBObj: TN_DIBObj; AWidth, AHeight: integer; APixFmt: TPixelFormat;
                         AExPixFmt: TN_ExPixFmt; ANumBits: integer = 0 );

procedure N_DrawMonoRaster ( DstBMP: TBitMap; DstULCorner: TPoint;
                             SrcPtr: pointer; SrcLineSize: integer;
                             SrcBmp: TBitmap; SrcRect: TRect; Color: integer );

procedure N_DrawFilledRect ( AHDC: HDC; ARect: TRect; AColor: integer );
procedure N_CopyRect       ( AHDst: HDC; ADstUpperLeft: TPoint; AHSrc: HDC; ASrcRect: TRect; AROp: DWORD = SRCCOPY );
procedure N_CopyRectByMask ( AHDst: HDC; ADstUpperLeft: TPoint; AHSrc: HDC; ASrcRect: TRect; AHMask: HBitMap; AROP4: DWORD );

procedure N_CopyRects      ( AHDst, AHSrc: HDC; ASrcRects: TN_IRArray; ANumRects, AShiftX, AShiftY: integer );
procedure N_StretchRect    ( AHDst: HDC; ADstRect: TRect; AHSrc: HDC; ASrcRect: TRect; AROp: DWORD = SRCCOPY );
procedure N_DrawRectBorder ( AHDC: HDC; const ARectBorder: TRect; AColor, AWidth: integer );
procedure N_DrawDashRect   ( const ADrawDashPars: TN_DrawDashRectPar );

//##/*
procedure N_RGBColorsToColorInds ( DstBitMap: TBitMap; DstRect: TRect;
                                   SrcBitMap: TBitMap; SrcRect: TRect;
                                   ColorInd: integer; var NumColors: integer;
                                                        RGBColors: TN_IArray );
//##*/
procedure N_DrawMesh ( ACanvas: TCanvas; const ARect: TRect;
                                              AX0, AY0, AStepX, AStepY: integer );
procedure N_CopyMetafileToClipBoard   ( AMF: TMetafile );
procedure N_LoadMetafileFromClipBoard ( var AMF: TMetafile );
procedure N_PrepDIBLineSizes ( AWidth: integer; APixFmt: TPixelFormat;
                               AExPixFmt: TN_ExPixFmt; out ABytesInLine, ALineSize: integer );
procedure N_CreateDIBSection ( var AHDS: HBitMap; AWidth, AHeight: integer;
                               APixelFormat: TPixelFormat; var APixPtr: Pointer );
//##/*
procedure N_DrawBMP ( DC: HDC; ABMP: TBitmap; ADstRect, ASrcRect: TRect;
                                     ARScale: float; APPlace: TN_PictPlace );
function  N_CreateBMPFragment ( BMP: TBitmap; BMPRect: TRect ): TBitmap;
procedure N_TestRectDraw ( AOCanv: TN_OCanvas; AX, AY, AColor: integer );
procedure N_HDCRectDraw  ( AHDC: HDC; AX, AY, AColor: integer ); overload;
//##*/
procedure N_HDCRectDraw  ( AHDC: HDC; ARect: TRect; AColor: integer ); overload;
//##/*
//##*/
function  N_AddToImageList ( AImageList: TImageList; AFileName: string;
                             APTranspColor: PInteger ): integer;

function  N_CreateTestDIB8     ( AMode: integer; APTestDIBParams: TN_PTestDIBParams ): TN_DIBObj;
function  N_CreateTestDIB16    ( AMode: integer; APTestDIBParams: TN_PTestDIBParams ): TN_DIBObj;
function  N_CreateTestDIB      ( AParams: String ): TN_DIBObj;
function  N_CreateTestDIBFromDIB ( AParams: String; ASrcDIB: TN_DIBObj ): TN_DIBObj;
function  N_CreateDIBFromCMSI  ( AFileName: string ): TN_DIBObj;
//function  N_CreateGray8DIBFromGray16( AGray16DIB: TN_DIBObj ): TN_DIBObj;
function  N_CreateEmptyBMP     ( AWidth, AHeight: integer; APixFmt: TPixelFormat ): TBitmap;
function  N_CreateBMPObjFromFile   ( AFileName: string ): TBitmap;
function  N_CreateBMPObjFromStream ( AStream: TStream ): TBitmap;
procedure N_SaveBMPObjToFile   ( ABMPObj: TBitmap; AFName: string; APParams: TN_PImageFilePar );
procedure N_CopyBMPToClipboard ( ABMP: TBitmap );

//##/*
procedure N_ReplaceOneColorInDIB ( PDIBInfo: TN_PDIBInfo; OldColor, NewColor: integer );
procedure N_SetFontSmoothing   ( AUseSmoothing: boolean );
procedure N_SetResToRasterFile ( AFileName: string; AFileFmt: TN_ImageFileFormat;
                                                             AResDPI: TFPoint );
procedure N_SetTranspColorToGifFile ( AFileName: string; ATranspColor: integer );
procedure N_ParseGifFile            ( AFileName: string );
procedure N_CreateScreenShot        ( AFileName: string );
procedure N_AddScreenShotToLogFiles ( AFNamePrefix: string );
function  N_CheckDIBFreeSpace       ( ADIBSize: integer ) : Boolean;
procedure N_TestPatternBrush        ();
procedure N_BrighHistToText         ( ABrighHistValues: TN_IArray; AStrings: TStrings );
procedure N_BrighHistToFile         ( ABrighHistValues: TN_IArray; AFName, AHeader: String );

procedure N_Prepare1BitBMPby8BitDIB ( ASrcDIB8: TN_DIBObj; APWhiteInds: PInteger; ANumInds: integer; var AWrkBitmap: TBitmap );
procedure N_DrawGraphicMenuItems    ( ADstHDC: HDC; ADIBWhite, ADIBBlack, ADIB8Mask: TN_DIBObj; APWhiteInds: PInteger; ANumInds: integer; var AWrkBitmap: TBitmap );

procedure N_ConvDIBToArrAverageFast1 ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; AApRadius: integer );
procedure N_ConvDIBToArrMedianHuang  ( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; AApRadius: integer );
procedure N_ConvSMatrDescr ( APSrcSMatrDescr, APDstSMatrDescr: TN_PSMatrDescr; AOffset: integer );

procedure N_TestLoadDIB  ( var ADIB: TN_DIBObj; AFName: string; AMode, ALib: integer );
procedure N_TestSaveDIB  ( ADIB: TN_DIBObj; AFName: string; AMode, ALib: integer );
function  N_LoadDIBFromFileByImLib ( var ADIB: TN_DIBObj; AFileName: string ): integer;
function  N_LoadDIBFromFile        ( var ADIB: TN_DIBObj; AFileName: string ): integer;
function  N_SaveDIBToFileByImLib   ( ADIB: TN_DIBObj; AFileName: string ): Integer;

procedure N_DIBInfoToStrings ( APDIBInfo: TN_PDIBInfo; AName: string; AResStrings: TStrings );

procedure N_CMSTridentDIBAdjust    ( var ADIBObj : TN_DIBObj );
procedure N_DICOMPixToDIBPix       ( APDICOMPix: TN_BytesPtr; ADIBObj: TN_DIBObj );
procedure N_DIBPixToDICOMPix       ( APDICOMPix: TN_BytesPtr; ADIBObj: TN_DIBObj );

//##*/



var
  N_OCanv: TN_OCanvas; // for debug and testing
  N_XForm: TXForm; // for debug and testing
  N_SysPatternPalette: TN_PatternPalette;
  N_SavedU2P, N_SavedP2U: TN_AffCoefs4;
  N_SavedUClipRect: TFRect;
  N_RasterChangedRect: TRect; // set in N_DrawRaster, used in OCanv.DrawPixRaster
  N_ZeroIntegers: TN_IArray;
//  N_GM_Advanced: boolean; // current GDI mode

  N_DIB, N_DIB1, N_DIB2: TN_DIBObj; // temporary DIB Objects for debug

implementation
uses // GDIPAPI,
     SysUtils, StrUtils, Math, ClipBrd, JPeg, ZLib, IniFiles, Forms,
     K_Types, K_Gra0, K_CLib0, K_VFunc, K_GifFile, K_Script1, K_UDT2,
     K_RImage, K_URImage,
     Types, N_Gra3, N_InfoF, N_Deb1, N_Lib2, N_ME1, N_ImLib;


//********************* TN_OCanvas class methods  **********************

//******************************************************* TN_OCanvas.Create ***
//
constructor TN_OCanvas.Create();
begin
  RFrameCounter := 1;
  OCanvType := octRFrameRaster;
  HMDC := CreateCompatibleDC( 0 );
  InitOCanv();

  SetLength( InvRects, 10 ); // InvRects Length never decreases
  CollectInvRects := False;
  OCUserAspect  := 1;
  OCPixelAspect := 1;
  MaxUClipRect := N_EFRect; // a precaution
  MinUClipRect := N_EFRect; // a precaution
  P2U  := N_DefAffCoefs4; // a precaution
  U2P  := N_DefAffCoefs4; // a precaution
  P2U6 := N_DefAffCoefs6; // a precaution
  U2P6 := N_DefAffCoefs6; // a precaution
  UseAffCoefs6 := False;

  P2PWin    := N_ConvToXForm( N_DefAffCoefs6 );
  UseP2PWin := False;

  SetLength( WrkDLA1, 3 );
  SetLength( WrkDLA2, 3 );
  SetLength( WrkCILine, 1000 );
  SetLength( WrkBytes, 1000 );
  SetLength( WrkPoints, 1000 );
  SetLength( ConSegm, 2 );
  ConPClipRect.Left := N_NotAnInteger; // "Clip Rect not defined" flag

  SetLength( WrkOutLengths, 5 );
  SetLength( WrkOutFLines,  5 );
  SetLength( WrkOutDLines,  5 );

  ConPenColor     := N_NotAnInteger;
  ConPenStyle     := PS_COSMETIC or PS_SOLID;
  ConPenPixWidth  := N_NotAnInteger;
  ConPenLLWWidth  := N_NotAFloat;
  ConBrushColor   := N_NotAnInteger;
  ConBrushStyle   := N_SolidStyle;
  ConTextColor    := N_NotAnInteger;
  ConBackColor    := N_NotAnInteger;
  ConCharsExtPix  := N_NotAnInteger;
  ConBreaksExtPix := N_NotAnInteger;
  ConNumBreaks    := N_NotAnInteger;

  CurLSUPixSize := 1;
  CurLLWPixSize := 1;
  CurLFHPixSize := 1;

  CorrectLastPixel := not N_Win2K;
  SetPenAttribs( $000000, 1.0 );
  SetBrushAttribs( $FFFFFF );
  ConWinPolyLine  := True;
  ConClipPolyLine := True;
//  ConClipPolyLine    := False;
  MinAngleStep := 5;

  if N_Win2K then
//    FullRgnH := CreateRectRgn( -50000000, -50000000, 50000000, 50000000 ) // instead of empty Clip Region  Error
    FullRgnH := CreateRectRgn( -10000, -10000, 3500000, 3500000 ) // instead of empty Clip Region
  else
    FullRgnH := CreateRectRgn( -50000, -50000, 50000, 50000 ); // instead of empty Clip Region
end; //*** end of Constructor TN_OCanvas.Create

//****************************************************** TN_OCanvas.Destroy ***
//
destructor TN_OCanvas.Destroy;
var
  GDIHandle: HGDIOBJ;
begin
  if HMDC <> 0 then // free all own GDI objects from HMDC
  begin
    GDIHandle := GetStockObject( BLACK_PEN );
    GDIHandle := SelectObject( HMDC, GDIHandle ); // release current HPen from HMDC
    DeleteObject( GDIHandle );

    GDIHandle := GetStockObject( GRAY_BRUSH );
    GDIHandle := SelectObject( HMDC, GDIHandle ); // release current HBrush from HMDC
    DeleteObject( GDIHandle );

    GDIHandle := GetStockObject( SYSTEM_FONT );
    GDIHandle := SelectObject( HMDC, GDIHandle ); // release current HFont from HMDC
    if ConDelCurHFont then DeleteObject( GDIHandle );

    SelectObject( HMDC, HMIniBMP ); // release HMDS from HMDC
    if HMDS <> 0 then
    begin
      N_b := DeleteObject( HMDS );
//      Assert( N_b, 'Bad HMDS' );
      if not N_b then
        raise Exception.Create( 'Bad HMDS' );
    end;
    N_b := DeleteDC( HMDC );
//    Assert( N_b, 'Bad HMDC' );
    if not N_b then
      raise Exception.Create( 'Bad HMDC' );

    if HBDC <> 0 then
    begin
      SelectObject( HBDC, HBIniBMP ); // release HBDS from HBDC
      if HBDS <> 0 then
      begin
        N_b := DeleteObject( HBDS );
//        Assert( N_b, 'Bad HBDS' );
        if not N_b then
          raise Exception.Create( 'Bad HBDS' );
      end;
      N_b := DeleteDC( HBDC );
//      Assert( N_b, 'Bad HBDC' );
      if not N_b then
        raise Exception.Create( 'Bad HBDC' );
    end;

  end; // if OCanvType = octOwnRaster then

  InvRects  := nil;
  WrkDLA1   := nil;
  WrkDLA2   := nil;
  WrkCILine := nil;
  WrkPoints := nil;

  WrkPixDashes  := nil;
  WrkOutLengths := nil;
  WrkOutFLines  := nil;
  WrkOutDLines  := nil;

  ConSegm := nil;
  MetafileCanvas.Free;
  Metafile.Free;
  DeleteObject( FullRgnH );
  Inherited;
end; //*** end of destructor TN_OCanvas.Destroy

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\InitOCanv
//**************************************************** TN_OCanvas.InitOCanv ***
// Initialize Self
//
// Should be called each time after HMDC is changed or can be called to force 
// default settings.
//
procedure TN_OCanvas.InitOCanv();
begin
//  Assert( HMDC <> 0, 'HMDC Err!' );
  if HMDC = 0 then
    raise Exception.Create( 'HMDC Err!' );

  GMAdvanced := False; // is neeeded for proper work of AdvancedMode procedure
  AdvancedMode( True );

  Windows.SetMapMode( HMDC, MM_TEXT );
  Windows.SetBkMode( HMDC, TRANSPARENT );
  Windows.SetStretchBltMode( HMDC, COLORONCOLOR );
//  Windows.SetStretchBltMode( HMDC, HALFTONE ); // later add StretchMode field
  Windows.SetPolyFillMode( HMDC, ALTERNATE );
  UseP2PWin    := False;
  UseAffCoefs6 := False;

  ModifyWorldTransform( HMDC, P2PWin, MWT_IDENTITY ); // P2PWin is not used
end; //*** end of procedure TN_OCanvas.InitOCanv

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\ClearSelfByColor
//********************************************* TN_OCanvas.ClearSelfByColor ***
// Clear Self by given color
//
procedure TN_OCanvas.ClearSelfByColor( AClearColor: integer );
begin
  if HMDC = 0 then Exit; // a precaution
  SetBrushAttribs( AClearColor );
  DrawPixFilledRect( CurCRect );
end; //*** end of procedure TN_OCanvas.ClearSelfByColor

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\CreateBackBuf
//************************************************ TN_OCanvas.CreateBackBuf ***
// Create Back raster buffer if not yet
//
// If Back raster buffer was created then Main raster buffer should be copy to 
// it.
//
procedure TN_OCanvas.CreateBackBuf();
begin
  if HBDC <> 0 then Exit; // already exists, nothing todo
  if CCRSize.X = 0 then Exit;  // MainBuf was not created
  HBDC := CreateCompatibleDC( 0 );
  N_CreateDIBSection( HBDS, CCRSize.X, CCRSize.Y, CPixFmt, Pointer(BPixPtr) );
//  Assert( HBDS <> 0, 'Bad HBDS' );
  if HBDS = 0 then
    raise Exception.Create( 'Bad HBDS' );
  HBIniBMP := SelectObject( HBDC, HBDS );
  BitBlt( HBDC, 0, 0, CCRSize.X, CCRSize.Y, HMDC, 0, 0, SRCCOPY );
end; //*** end of procedure TN_OCanvas.CreateBackBuf

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\CopyWholeToBack
//********************************************** TN_OCanvas.CopyWholeToBack ***
// Copy whole Main raster buffer to Back raster buffer
//
procedure TN_OCanvas.CopyWholeToBack();
begin
  BitBlt( HBDC, 0, 0, CCRSize.X, CCRSize.Y, HMDC, 0, 0, SRCCOPY );
end; //*** end of procedure TN_OCanvas.CopyWholeToBack

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\CopyWholeToMain
//********************************************** TN_OCanvas.CopyWholeToMain ***
// Copy whole Back raster buffer to Main raster buffer
//
procedure TN_OCanvas.CopyWholeToMain();
begin
  BitBlt( HMDC, 0, 0, CCRSize.X, CCRSize.Y, HBDC, 0, 0, SRCCOPY );
end; //*** end of procedure TN_OCanvas.CopyWholeToMain

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\CopyInvRectsToBack
//******************************************* TN_OCanvas.CopyInvRectsToBack ***
// Copy Invalidated Rectangles contents from Main raster buffer to Back raster 
// buffer
//
// Invalidated Rectangles list is stored in InvRects field.
//
procedure TN_OCanvas.CopyInvRectsToBack();
begin
  N_CopyRects ( HBDC, HMDC, InvRects, NumInvRects, 0, 0 );
end; //*** end of procedure TN_OCanvas.CopyInvRectsToBack

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\CopyInvRectsToMain
//******************************************* TN_OCanvas.CopyInvRectsToMain ***
// Copy Invalidated Rectangles contents from Back raster buffer to Main raster 
// buffer
//
// Invalidated Rectangles list is stored in InvRects field.
//
procedure TN_OCanvas.CopyInvRectsToMain();
begin
  N_CopyRects( HMDC, HBDC, InvRects, NumInvRects, 0, 0 );
end; //*** end of procedure TN_OCanvas.CopyInvRectsToMain

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\ClearPrevPhase
//*********************************************** TN_OCanvas.ClearPrevPhase ***
// Clear previous animation drawing phase in Main raster buffer by Back raster 
// buffer
//
procedure TN_OCanvas.ClearPrevPhase();
begin
  if HBDC = 0 then CreateBackBuf();
  CopyInvRectsToMain();
  PrevNumInvRects := NumInvRects; // used in ShowNewPhase
  CollectInvRects := True;
end; // procedure TN_OCanvas.ClearPrevPhase

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\FixPhase
//***************************************************** TN_OCanvas.FixPhase ***
// Fix animation drawing phase end
//
// All drawn after last call to ClearPrevPhase will be copy to Back raster 
// buffer.
//
procedure TN_OCanvas.FixPhase();
begin
  PrevNumInvRects := NumInvRects; // for removing in ShowNewPhase
  CopyInvRectsToBack();           // update Background
end; // procedure TN_OCanvas.FixNewPhase

//************************************************** TN_OCanvas.GetPixColor ***
// Get Color of Pixel with given coords AX, AY
//
function TN_OCanvas.GetPixColor( AX, AY: integer ): integer;
begin
  // Temporary Not implemented!
  Assert( False, 'TN_OCanvas.GetPixColor Temporary Not implemented!' );
  Result := 0;
end; // function TN_OCanvas.GetPixColor

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetCurCRectSize
//********************************************** TN_OCanvas.SetCurCRectSize ***
// Set Canvas given pixel size and format
//
//     Parameters
// AWidth  - given Canvas pixel width
// AHeight - given Canvas pixel height
// APixFmt - given Canvas pixel format
//
// APixFmt = pfDevice means current PixelFormat if MainBuf exists or 
// N_OCanvDefPixFmt if not.
//
// Recreate Main raster buffer and Back Main raster buffer DIB Sections if 
// needed.
//
// Canvas CurCRect, CCRSize and CPixFmt fields should be redefind.
//
procedure TN_OCanvas.SetCurCRectSize( AWidth, AHeight: integer; APixFmt: TPixelFormat );
var
  NumPix: double;
begin
  if APixFmt = pfDevice then // use current Pixel Format or N_OCanvDefPixFmt
  begin
    if HMDS <> 0 then APixFmt := CPixFmt
                 else APixFmt := N_OCanvDefPixFmt;
  end;

  if (CCRSize.X = AWidth) and (CCRSize.Y = AHeight) and (CPixFmt = APixFmt) then Exit;

  if (AWidth = 0) and (AHeight = 0) then Exit;

  NumPix := 1.0 * AWidth * AHeight;
//  Assert( (NumPix > 0) and (NumPix < 500.0e6), 'Bad CCRSize' );
  if (NumPix <= 0) or (NumPix > 500.0e6) then
    raise Exception.Create( 'Bad CCRSize' );

  //*** Temporary, later try to avoid recreating DIBSection:
  //    decrease it's size only if needed and increase with reserve if allowed

  DIBSize  := Point( AWidth, AHeight );
  CCRSize  := DIBSize;
  CurCRect := IRect( CCRSize );
  CPixFmt  := APixFmt;


  if HMDC <> 0 then
    SelectObject( HMDC, HMIniBMP ); // release HMDS from HMDC

//    N_T2.Clear(2);
//    N_T2.Start(0);
  N_CreateDIBSection( HMDS, AWidth, AHeight, APixFmt, Pointer(MPixPtr) );
//    N_T2.Stop(0);
//    N_T2.Show(1);
  HMIniBMP := SelectObject( HMDC, HMDS );
//  Assert( HMIniBMP <> 0, 'Bad HMDS' );
  if HMIniBMP = 0 then
    raise Exception.Create( 'Bad HMIniBMP' );

  if HBDC <> 0 then
  begin
    SelectObject( HBDC, HBIniBMP ); // release HBDS from HBDC
    N_CreateDIBSection( HBDS, AWidth, AHeight, APixFmt, Pointer(BPixPtr) );
    HBIniBMP := SelectObject( HBDC, HBDS );
//    Assert( HBIniBMP <> 0, 'Bad HBDS' );
    if HBIniBMP = 0 then
      raise Exception.Create( 'Bad HBIniBMP' );
  end;

end; // end of procedure TN_OCanvas.SetCurCRectSize

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\BeginMetafile
//************************************************ TN_OCanvas.BeginMetafile ***
// Begin drawing to Metafile
//
//     Parameters
// APixWidth  - metafile pixel width
// APixHeight - metafile pixel height
//
// Free previous metafile if needed.
//
procedure TN_OCanvas.BeginMetafile( APixWidth, APixHeight: integer );
begin
  if Metafile <> nil then
  begin
    if MetafileCanvas <> nil then FreeAndNil( MetafileCanvas );
    Metafile.Free;
  end;

  Metafile := TMetafile.Create();
  Metafile.Width  := APixWidth;
  Metafile.Height := APixHeight;
  MetafileCanvas := TMetafileCanvas.Create( Metafile, 0 );
//  MHDC := MetafileCanvas.Handle;
end; // end of procedure TN_OCanvas.BeginMetafile

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\EndMetafile
//************************************************** TN_OCanvas.EndMetafile ***
// End drawing to Metafile
//
// Free Canvas Metafile
//
procedure TN_OCanvas.EndMetafile();
begin
  FreeAndNil( MetafileCanvas );
//  MainCanvas := HMDC;
end; // end of procedure TN_OCanvas.EndMetafile

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\IncreaseURect
//************************************************ TN_OCanvas.IncreaseURect ***
// Increase given recangle in User coordinates by given delta in pixels
//
//     Parameters
// AURect    - source recangle in User coordinates
// ADeltaPix - delta in pixels
// Result    - Returns resulting rectangle in User coordinates.
//
function TN_OCanvas.IncreaseURect( AURect: TFRect; ADeltaPix: integer): TFRect;
var
  TmpPRect: TRect;
begin
  TmpPRect := N_IRectOrder( N_AffConvF2IRect( AURect, U2P ) );
  Dec( TmpPRect.Left,   ADeltaPix );
  Dec( TmpPRect.Top,    ADeltaPix );
  Inc( TmpPRect.Right,  ADeltaPix );
  Inc( TmpPRect.Bottom, ADeltaPix );
  Result := N_AffConvI2FRect2( TmpPRect, P2U );
end; // end of function TN_OCanvas.IncreaseURect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetUserCoordsSameToPixel
//************************************* TN_OCanvas.SetUserCoordsSameToPixel ***
// Set canvas User coordinates same to current pixel coordinates
//
procedure TN_OCanvas.SetUserCoordsSameToPixel();
var
  URect: TFRect;
begin
  URect := FRect( -0.5, -0.5, CCRSize.X-0.5, CCRSize.Y-0.5 );
  SetCoefsAndUCRect( URect, IRect( CCRSize ) );
end; //*** end of procedure TN_OCanvas.SetUserCoordsSameToPixel

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\AdvancedMode
//************************************************* TN_OCanvas.AdvancedMode ***
// Set Windows GDI device (HMDC) advanced graphics mode
//
//     Parameters
// ASet - if TRUE advanced graphics mode (GM_ADVANCED) will be set, else it will
//        be clear
//
procedure TN_OCanvas.AdvancedMode( ASet: boolean = True );
begin
  if Aset then // Set GM_ADVANCED HMDC mode
  begin
    if GMAdvanced then Exit;

    Windows.SetGraphicsMode( HMDC, GM_ADVANCED );
    GMAdvanced := True;
    ConOnePix := 0;
  end else //**** Clear GM_ADVANCED HMDC mode
  begin
    if not GMAdvanced then Exit;

    Windows.SetGraphicsMode( HMDC, GM_COMPATIBLE );
    GMAdvanced := False;
    ConOnePix := 1;
  end;
end; //*** end of procedure TN_OCanvas.SetAdvancedMode

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetCoefs
//***************************************************** TN_OCanvas.SetCoefs ***
// Set User to Pixel and Pixel to User coordinates Affine Transformation 
// Coefficients
//
//     Parameters
// AURect      - rectangle in User coordinates
// APRect      - corresponding rectangle in pixel coordinates
// ATransfType - additional coordinates transformation type
//
// User to Pixel and Pixel to User coordinates Affine Transformation 
// Coefficients are calculated by given rectangle in User coordinates, 
// corresponding rectangle in pixel coordinates and additional coordinates 
// transformation type, any Aspect is OK, MaxUClipRect and MinUClipRect fields 
// are not recalculated.
//
procedure TN_OCanvas.SetCoefs( const AURect: TFRect; const APRect: TRect;
                                 ATransfType: TN_CTransfType = ctfNoTransform );
var
  HalfPixSizeX, HalfPixSizeY, DTmp: double;
//  PTmpp: PChar;
  TmpURect, DPRect: TDRect;
  InpUserRep, OutPixRep: TN_3DPReper;
begin
  with AURect do
    if (Left = Right) or (Top = Bottom) then Exit; // a precaution

  with APRect do
    if ((Right-Left+1) = 0) or ((Bottom-Top+1) = 0) then Exit; // a precaution

  HalfPixSizeX := 0.45*(AURect.Right - AURect.Left)/(APRect.Right - APRect.Left + 1);
  HalfPixSizeY := 0.45*(AURect.Bottom - AURect.Top)/(APRect.Bottom - APRect.Top + 1);

  TmpURect := DRect( AURect.Left+HalfPixSizeX,  AURect.Top+HalfPixSizeY,
                     AURect.Right-HalfPixSizeX, AURect.Bottom-HalfPixSizeY );
  DPRect := DRect( APRect.Left, APRect.Top, APRect.Right, APRect.Bottom );
//type TN_CTransfType = ( ctfNoTransform, ctfFlipAlongX, ctfFlipAlongY,
//                        ctfRotate90CCW, ctfRotate90CW );

  case ATransfType of

  ctfNoTransform: // do not Rotate
                  // UpperLeft User Rect Corner --> UpperLeft Pixel Rect Corner
  begin
    UseAffCoefs6 := False;
    U2P := N_CalcAffCoefs4( TmpURect, DPRect );
    P2U := N_CalcAffCoefs4( DPRect, TmpURect );
    U2P6 := N_DefAffCoefs6;
    P2U6 := N_DefAffCoefs6;
  end; // ctfNoTransform: // do not Rotate

  ctfFlipAlongX: // Flip (Inverse) X coords, Y coords remains the same
                  // UpperLeft User Rect Corner --> UpperRight Pixel Rect Corner
  begin
    UseAffCoefs6 := False;

    DTmp := TmpURect.Left;
    TmpURect.Left  := TmpURect.Right;
    TmpURect.Right := DTmp;

    DTmp := DPRect.Left;
    DPRect.Left  := DPRect.Right;
    DPRect.Right := DTmp;

    DTmp := TmpURect.Top;
    TmpURect.Top    := TmpURect.Bottom;
    TmpURect.Bottom := DTmp;

    U2P := N_CalcAffCoefs4( TmpURect, DPRect );
    P2U := N_CalcAffCoefs4( DPRect, TmpURect );
    U2P6 := N_DefAffCoefs6;
    P2U6 := N_DefAffCoefs6;
  end; // ctfFlipAlongX: // Flip (Inverse) X coords, Y coords remains the same

  ctfFlipAlongY: // Flip (Inverse) Y coords, X coords remains the same
                  // UpperLeft User Rect Corner --> LowerLeft Pixel Rect Corner
  begin
    UseAffCoefs6 := False;

    DTmp := TmpURect.Top;
    TmpURect.Top    := TmpURect.Bottom;
    TmpURect.Bottom := DTmp;

    DTmp := DPRect.Top;
    DPRect.Top    := DPRect.Bottom;
    DPRect.Bottom := DTmp;

    U2P := N_CalcAffCoefs4( TmpURect, DPRect );
    P2U := N_CalcAffCoefs4( DPRect, TmpURect );
    U2P6 := N_DefAffCoefs6;
    P2U6 := N_DefAffCoefs6;
  end; // ctfFlipAlongX: // Flip (Inverse) X coords, Y coords remains the same

  ctfRotate90CW: // Rotate by 90 degree Clockwise
                 // UpperLeft User Rect Corner --> UpperRight Pixel Rect Corner
  begin
    UseAffCoefs6 := True;
    InpUserRep := D3PReper( TmpURect );
    with OutPixRep do
    begin
      P1.X := DPRect.Right;
      P1.Y := DPRect.Top;
      P2.X := DPRect.Right;
      P2.Y := DPRect.Bottom;
      P3.X := DPRect.Left;
      P3.Y := DPRect.Top;
    end;

    U2P6 := N_CalcAffCoefs6( InpUserRep, OutPixRep );
    P2U6 := N_CalcAffCoefs6( OutPixRep, InpUserRep );

    U2P := N_DefAffCoefs4;
    P2U := N_DefAffCoefs4;
  end; // ctfRotate90CW: // Rotate by 90 degree Clockwise

  ctfRotate90CCW: // Rotate by 90 degree CounterClockwise
                  // UpperLeft User Rect Corner --> LowerLeft Pixel Rect Corner
  begin
    UseAffCoefs6 := True;
    InpUserRep := D3PReper( TmpURect );
    with OutPixRep do
    begin
      P1.X := DPRect.Left;
      P1.Y := DPRect.Bottom;
      P2.X := DPRect.Left;
      P2.Y := DPRect.Top;
      P3.X := DPRect.Right;
      P3.Y := DPRect.Bottom;
    end;

    U2P6 := N_CalcAffCoefs6( InpUserRep, OutPixRep );
    P2U6 := N_CalcAffCoefs6( OutPixRep, InpUserRep );

    U2P := N_DefAffCoefs4;
    P2U := N_DefAffCoefs4;
  end; // ctfRotate90CCW: // Rotate by 90 degree CounterClockwise

  end; // case ATransfType of

end; // end of procedure TN_OCanvas.SetCoefs

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetUClipRect
//************************************************* TN_OCanvas.SetUClipRect ***
// Set clip rectangles in User coordinates by given pixel rectangle
//
//     Parameters
// APRect - given clip rectangle in pixel coordinates
//
// Calculate MaxUClipRect and MinUClipRect. Current User to Pixel and Pixel to 
// User coordinates Affine Transformation Coefficients (U2P and P2U) are used.
//
procedure TN_OCanvas.SetUClipRect( const APRect: TRect );
begin
  MaxUClipRect := N_AffConvI2FRect1( N_Max9XPRect, P2U );
  MinUClipRect := N_AffConvI2FRect1( APRect, P2U );
  MinUClipRect := IncreaseURect( MinUClipRect, 50 );
end; // end of procedure TN_OCanvas.SetUClipRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetCoefsAndUCRect
//******************************************** TN_OCanvas.SetCoefsAndUCRect ***
// Set User to Pixel and Pixel to User coordinates Affine Transformation 
// Coefficients and clip rectangles in User coordinates
//
//     Parameters
// AURect      - rectangle in User coordinates
// APRect      - corresponding rectangle in pixel coordinates
// ATransfType - additional coordinates transformation type
//
// User to Pixel and Pixel to User coordinates Affine Transformation 
// Coefficients (U2P and P2U) and clip rectangles in User coordinates 
// (MaxUClipRect and MinUClipRect) are calculated by given rectangle in User 
// coordinates, corresponding rectangle in pixel coordinates and additional 
// coordinates transformation type, any Aspect is OK.
//
procedure TN_OCanvas.SetCoefsAndUCRect( const AURect: TFRect; const APRect: TRect;
                                 ATransfType: TN_CTransfType = ctfNoTransform );
begin
  SetCoefs( AURect, APRect, ATransfType );
  SetUClipRect( APRect );
end; // end of procedure TN_OCanvas.SetCoefsAndUCRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetIncCoefsAndUCRect
//***************************************** TN_OCanvas.SetIncCoefsAndUCRect ***
// Set User to Pixel and Pixel to User coordinates Affine Transformation 
// Coefficients and clip rectangles in User coordinates using give pixel aspect
//
//     Parameters
// AURect      - rectangle in User coordinates
// APRect      - corresponding rectangle in pixel coordinates
// ATransfType - additional coordinates transformation type
//
// Given User coordinates rectangle is increased by given pixel rectangle aspect
// and then User to Pixel and Pixel to User coordinates Affine Transformation 
// Coefficients (U2P and P2U) and clip rectangles in User coordinates 
// (MaxUClipRect and MinUClipRect) are calculated by calculated rectangle in 
// User coordinates, corresponding rectangle in pixel coordinates and additional
// coordinates transformation type.
//
procedure TN_OCanvas.SetIncCoefsAndUCRect( const AURect: TFRect; const APRect: TRect;
                                 ATransfType: TN_CTransfType = ctfNoTransform );
var
  TmpURect: TFRect;
begin
  TmpURect := AURect;
  N_AdjustRectAspect( aamIncRect, TmpURect,
                          OCUserAspect*OCPixelAspect*N_RectAspect( APRect ) );
  SetCoefs( TmpURect, APRect, ATransfType );
  SetUClipRect( APRect );
end; // end of procedure TN_OCanvas.SetIncCoefsAndUCRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\LLWToPix
//***************************************************** TN_OCanvas.LLWToPix ***
// Convert given value in Logical Line Width units (LLW) to pixels
//
//     Parameters
// ASizeInLLW - given value in Logical Line Width units (LLW)
// Result     - Returns resulting value in pixels.
//
// Resulting value may be zero.
//
function TN_OCanvas.LLWToPix( ASizeInLLW: float ): integer;
begin
  Result := Round( CurLLWPixSize*ASizeInLLW );
end; //*** end of function TN_OCanvas.LLWToPix

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\LLWToPix1
//**************************************************** TN_OCanvas.LLWToPix1 ***
// Convert given value in Logical Line Width units (LLW) to pixels
//
//     Parameters
// ASizeInLLW - given value in Logical Line Width units (LLW)
// Result     - Returns resulting value in pixels.
//
// New variant, resulting value may be zero if ASizeInLLW <= 0, in previous 
// variant resulting value was always >= 1
//
function TN_OCanvas.LLWToPix1( ASizeInLLW: float ): integer;
begin
  if ASizeInLLW <= 0 then
    Result := 0
  else // ASizeInLLW > 0
  begin
    Result := Round( CurLLWPixSize*ASizeInLLW );
    if Result = 0 then Result := 1;
  end;
end; //*** end of function TN_OCanvas.LLWToPix

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\PixToLLW
//***************************************************** TN_OCanvas.PixToLLW ***
// Convert given value in pixels to Logical Line Width units (LLW)
//
//     Parameters
// ASizeInPix - given value in pixels
// Result     - Returns resulting value in Logical Line Width units (LLW).
//
function TN_OCanvas.PixToLLW( ASizeInPix: integer ): float;
begin
  Result := ASizeInPix / CurLLWPixSize;
end; //*** end of function TN_OCanvas.PixToLLW

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\ShiftPixRectByLSURect
//**************************************** TN_OCanvas.ShiftPixRectByLSURect ***
// Shift given pixel rectangle by given shifts in Logical Size Unit (LSU)
//
//     Parameters
// AInpPixRect - given pixel rectangle
// AInpPixRect - given shifts in Logical Size Unit (LSU) as float rectangle
// Result      - Returns resulting pixel rectangle.
//
function TN_OCanvas.ShiftPixRectByLSURect( AInpPixRect: TRect; AShiftRect: TFRect ): TRect;
begin
  Result.Left   := AInpPixRect.Left   + Round( CurLSUPixSize*AShiftRect.Left );
  Result.Top    := AInpPixRect.Top    + Round( CurLSUPixSize*AShiftRect.Top );
  Result.Right  := AInpPixRect.Right  + Round( CurLSUPixSize*AShiftRect.Right );
  Result.Bottom := AInpPixRect.Bottom + Round( CurLSUPixSize*AShiftRect.Bottom );
end; //*** end of function TN_OCanvas.ShiftPixRectByLSURect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\LSUToUserX
//*************************************************** TN_OCanvas.LSUToUserX ***
// Convert given value in Logical Size Units (LSU) to X User coordinates
//
//     Parameters
// ASizeInLSU - given value in Logical Size Units units (LSU)
// Result     - Returns resulting value in User X coordinates.
//
function TN_OCanvas.LSUToUserX( ASizeInLSU: float ): double;
begin
  Result := P2U.CX*CurLSUPixSize*ASizeInLSU;
end; //*** end of function TN_OCanvas.LSUToUserX

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\LSUToUserY
//*************************************************** TN_OCanvas.LSUToUserY ***
// Convert given value in Logical Size Units (LSU) to Y User coordinates
//
//     Parameters
// ASizeInLSU - given value in Logical Size Units units (LSU)
// Result     - Returns resulting value in User Y coordinates.
//
function TN_OCanvas.LSUToUserY( ASizeInLSU: float ): double;
begin
  Result := P2U.CY*CurLSUPixSize*ASizeInLSU;
end; //*** end of function TN_OCanvas.LSUToUserY

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\ShiftUPoint
//************************************************** TN_OCanvas.ShiftUPoint ***
// Shift given point in User coordinates by given shifts in Logical Size Units 
// (LSU)
//
//     Parameters
// AUPoint    - given point in User coordinates
// ASizeInLSU - given shifts in Logical Size Units (LSU) as integer point
// Result     - Returns resulting shifted point in User coordinates.
//
function TN_OCanvas.ShiftUPoint( AUPoint: TDPoint; ALSUShift: TPoint ): TDPoint;
begin
  Result.X := AUPoint.X + LSUToUserX( ALSUShift.X );
  Result.Y := AUPoint.Y + LSUToUserY( ALSUShift.Y );
end; //*** end of function TN_OCanvas.ShiftUPoint

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\UserRect
//***************************************************** TN_OCanvas.UserRect ***
// Get rectangle in User coordinates by given rectangle in Logical Size Unit 
// (LSU) and shifts in User coordinates
//
//     Parameters
// AUSPoint - given shifts in User coordinates as double point
// ALSURect - given rectangle in Logical Size Unit (LSU) as float rectangle
// Result   - Returns resulting rectangle in User coordinates.
//
function TN_OCanvas.UserRect( AUSPoint: TDPoint; ALSURect: TFRect ): TFRect;
begin
  Result := FRect( AUSPoint.X + LSUToUserX(ALSURect.Left),
                   AUSPoint.Y + LSUToUserY(ALSURect.Top),
                   AUSPoint.X + LSUToUserX(ALSURect.Right),
                   AUSPoint.Y + LSUToUserY(ALSURect.Bottom) );
end; //*** end of function TN_OCanvas.UserRect

//************************************************ TN_OCanvas.CalcULStrPixShift ***
// Obsolete, use CalcStrPixRect
// Calc and return UpperLeft corner of given AStr shift in float Pixels
// for current Font settings
//
function TN_OCanvas.CalcULStrPixShift( AStr: string;
                                       APStrPos: TN_PStrPosParams = nil ): TFPoint;
var
  Leng: integer;
  Alfa, CosAlfa, SinAlfa: double;
  StrPixSize: TSize;
begin
  Result := N_ZFPoint;
  if APStrPos = nil then Exit;
  Leng := Length( AStr );
  if Leng = 0 then Exit;

  with APStrPos^ do
  begin
    if (SPPHotPoint.X = 0) and (SPPHotPoint.Y = 0) then
    begin
      Result.X := SPPShift.X*CurLSUPixSize;
      Result.Y := SPPShift.Y*CurLSUPixSize;
      Exit;
    end;

    Windows.GetTextExtentPoint32( HMDC, @AStr[1], Leng, StrPixSize );

    if SPPBLAngle = 0 then //***** CosAlfa = 1, SinAlfa = 0
    begin
      Result.X := SPPShift.X*CurLSUPixSize - StrPixSize.cx * 0.01*SPPHotPoint.X;
      Result.Y := SPPShift.Y*CurLSUPixSize - StrPixSize.cy * 0.01*SPPHotPoint.Y;
    end else //******************* SPPBLAngle <> 0
    begin
      Alfa := N_PI*SPPBLAngle/180; // conv to radians
      CosAlfa := Cos(Alfa);
      SinAlfa := Sin(Alfa);

      Result.X := SPPShift.X*CurLSUPixSize -
                  StrPixSize.cx * CosAlfa * 0.01*SPPHotPoint.X -
                  StrPixSize.cy * SinAlfa * 0.01*SPPHotPoint.Y;

      Result.Y := SPPShift.Y*CurLSUPixSize +
                  StrPixSize.cx * SinAlfa * 0.01*SPPHotPoint.X -
                  StrPixSize.cy * CosAlfa * 0.01*SPPHotPoint.Y;
    end;

  end; // with APStrPos^ do
end; //*** end of function TN_OCanvas.CalcULStrPixShift

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\CalcStrPixRect
//*********************************************** TN_OCanvas.CalcStrPixRect ***
// Calulate given string envelope rectangle and base point by current font 
// setting and given string position parameters
//
//     Parameters
// AStr          - given string
// APixBasePoint - given string base point pixel position
// APStrPos      - string position parameters (base point relative position in 
//                 string envelope rectangle, base point shift, base line angle)
// APBasePoint   - pointer to string resulting TopLeft pixel float point (if 
//                 APBasePoint <> nil then TopLeft corner will be returned)
// Result        - Returns resulting string envelope pixel float rectangle
//
// Resulting string TopLeft corner can be used for string drawing.
//
function TN_OCanvas.CalcStrPixRect( AStr: string; const APixBasePoint: TFPoint;
                         APStrPos: TN_PStrPosParams; APBasePoint: PFPoint = nil ): TFRect;
var
  Leng: integer;
  Alfa, CosAlfa, SinAlfa: double;
  StrPixSize: TSize;
  TLCorner: TFPoint;
begin
  Result := N_ZFRect;
  if APStrPos = nil then Exit;
  Leng := Length( AStr );
  if Leng = 0 then Exit;

  with APStrPos^ do
  begin
    Windows.GetTextExtentPoint32( HMDC, @AStr[1], Leng, StrPixSize );

    if (SPPHotPoint.X = 0) and (SPPHotPoint.Y = 0) and (SPPBLAngle = 0) then
    begin
      Result.Left   := APixBasePoint.X + SPPShift.X*CurLSUPixSize;
      Result.Top    := APixBasePoint.Y + SPPShift.Y*CurLSUPixSize;
      Result.Right  := Result.Left + StrPixSize.cx - 1;
      Result.Bottom := Result.Top  + StrPixSize.cy - 1;

      if APBasePoint <> nil then APBasePoint^ := Result.TopLeft;
      Exit;
    end;

    if SPPBLAngle = 0 then //***** CosAlfa = 1, SinAlfa = 0
    begin
      Result.Left   := APixBasePoint.X + SPPShift.X*CurLSUPixSize - StrPixSize.cx * 0.01*SPPHotPoint.X;
      Result.Top    := APixBasePoint.Y + SPPShift.Y*CurLSUPixSize - StrPixSize.cy * 0.01*SPPHotPoint.Y;
      Result.Right  := Result.Left + StrPixSize.cx - 1;
      Result.Bottom := Result.Top  + StrPixSize.cy - 1;

      if APBasePoint <> nil then APBasePoint^ := Result.TopLeft;
    end else //******************* SPPBLAngle <> 0
    begin
      Alfa := N_PI*SPPBLAngle/180; // conv to radians
      CosAlfa := Cos(Alfa);
      SinAlfa := Sin(Alfa);

      TLCorner.X := APixBasePoint.X + SPPShift.X*CurLSUPixSize -
                    StrPixSize.cx * CosAlfa * 0.01*SPPHotPoint.X -
                    StrPixSize.cy * SinAlfa * 0.01*SPPHotPoint.Y;

      TLCorner.Y := APixBasePoint.Y + SPPShift.Y*CurLSUPixSize +
                    StrPixSize.cx * SinAlfa * 0.01*SPPHotPoint.X -
                    StrPixSize.cy * CosAlfa * 0.01*SPPHotPoint.Y;

      if APBasePoint <> nil then APBasePoint^ := TLCorner;

      if SPPBLAngle < 0 then SPPBLAngle := SPPBLAngle + 360;

      if (0 <= SPPBLAngle) and (SPPBLAngle <= 90) then // first quarter
      begin
        Result.Left   := TLCorner.X;
        Result.Top    := TLCorner.Y;
        Result.Right  := Result.Left + StrPixSize.cx - 1;
        Result.Bottom := Result.Top  + StrPixSize.cy - 1;
{
        Result.Right  := TLCorner.X + StrPixSize.cx * CosAlfa + StrPixSize.cy * SinAlfa;
        Result.Bottom := TLCorner.Y                           + StrPixSize.cy * CosAlfa;
        Result.Left   := TLCorner.X;
        Result.Top    := TLCorner.Y - StrPixSize.cx * SinAlfa;
        Result.Right  := TLCorner.X + StrPixSize.cx * CosAlfa + StrPixSize.cy * SinAlfa;
        Result.Bottom := TLCorner.Y                           + StrPixSize.cy * CosAlfa;
}
      end else if (90 <= SPPBLAngle) and (SPPBLAngle <= 180) then // second quarter
      begin
        Result.Left   := TLCorner.X + StrPixSize.cx * CosAlfa;
        Result.Top    := TLCorner.Y - StrPixSize.cx * SinAlfa + StrPixSize.cy * CosAlfa;;
        Result.Right  := TLCorner.X                           + StrPixSize.cy * SinAlfa;
        Result.Bottom := TLCorner.Y;
      end else if (180 <= SPPBLAngle) and (SPPBLAngle <= 240) then // third quarter
      begin
        Result.Left   := TLCorner.X - StrPixSize.cx * CosAlfa + StrPixSize.cy * SinAlfa ;
        Result.Top    := TLCorner.Y                           - StrPixSize.cy * CosAlfa;
        Result.Right  := TLCorner.X;
        Result.Bottom := TLCorner.Y - StrPixSize.cx * SinAlfa;
      end else // fourth quarter
      begin
        Result.Left   := TLCorner.X                           + StrPixSize.cy * SinAlfa;
        Result.Top    := TLCorner.Y;
        Result.Right  := TLCorner.X + StrPixSize.cx * CosAlfa;
        Result.Bottom := TLCorner.Y - StrPixSize.cx * SinAlfa + StrPixSize.cy * CosAlfa;
      end;

    end;

  end; // with APStrPos^ do
end; //*** end of function TN_OCanvas.CalcStrPixRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetBackColor
//************************************************* TN_OCanvas.SetBackColor ***
// Set Windows current font background mode and color
//
//     Parameters
// ABackColor - given background color
//
procedure TN_OCanvas.SetBackColor( ABackColor: integer );
begin
  if ABackColor = ConBackColor then Exit;

  ConBackColor := ABackColor;

  if ABackColor = N_EmptyColor then
    Windows.SetBkMode( HMDC, TRANSPARENT )
  else
  begin
    Windows.SetBkMode( HMDC, OPAQUE );
    if CPixFmt = pf16Bit then
      ABackColor := N_RoundTo16bitColor( ABackColor );

    Windows.SetBkColor( HMDC, ABackColor );
  end;
end; //*** end of procedure TN_OCanvas.SetBackColor

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetPenAttribs(2)
//********************************************* TN_OCanvas.SetPenAttribs(2) ***
// Set current Pen Attributes by given AColor and other attribs given as string
//
//     Parameters
// APenColor - Pen Color, may be N_EmptyColor
// AStrAttr  - other attribs (Width Style Dash1 Dash2 ... NumDashes)
//
procedure TN_OCanvas.SetPenAttribs( APenColor: integer; AStrAttr: string );
var
  PenStyle, NumDashes: integer;
  PenWidth: float;
  PDashSizes: PFloat;
  DashSizes: TN_FArray;
begin
  PenStyle := 0;
  DashSizes := nil;
  PDashSizes := nil;
  NumDashes := 0;

  PenWidth := N_ScanFloat( AStrAttr );

  if PenWidth <> N_NotAFloat then
  begin
    PenStyle := N_ScanInteger( AStrAttr );

    if PenStyle <> N_NotAnInteger then
    begin
      NumDashes := N_ScanFArray( AStrAttr, DashSizes );
      if NumDashes >= 2 then
        PDashSizes := @DashSizes[0]
      else
        NumDashes := 0;
    end else
      PenStyle := 0;

  end else
    PenWidth := 1;

  SetPenAttribs( APenColor, PenWidth, PenStyle, PDashSizes, NumDashes );
end; //*** end of procedure TN_OCanvas.SetPenAttribs

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetPenAttribs(1)
//********************************************* TN_OCanvas.SetPenAttribs(1) ***
// Set current Pen Attributes (Color, Width and Style)
//
//     Parameters
// APenColor   - Pen Color, may be N_EmptyColor or N_CurColor
// APenWidth   - Pen width in LLW
// APenStyle   - Windows Pen Style (see PS_XXX constants below)
// APDashSizes - Pointer to float Dash and Gap Sizes in LLW units (if Style is 
//               PS_USERSTYLE)
// ANumDashes  - Number of Dashes and Gaps (Number of integers in APDashSizes 
//               Array)
//
// Gaps btween Dashes are drawn by Background Color (set by SetBackColor method)
//
// Pen Styles (see also EXTLOGPEN Structure in 
// http://msdn.microsoft.com/en-us/library/dd162711.aspx): PS_SOLID         = 0;
// // сплошная PS_DASH          = 1; // штриховая      ------- PS_DOT           
// = 2; // пунктир        ....... PS_DASHDOT       = 3; // штрихпунктир1  
// _._._._ PS_DASHDOTDOT    = 4; // штрихпунктир2  _.._.._ PS_NULL          = 5;
// // линия не рисуется PS_INSIDEFRAME   = 6; // рисуется только внутренняя 
// часть толстой границы конутра (ширина линии уменьшается) PS_USERSTYLE     = 
// 7; // штриховая, размеры штрихов заданы пользователем PS_ALTERNATE     = 8; 
// // штриховая, размеры и штрихов и промежутков равны 1 пикселю
//
// PS_ENDCAP_ROUND  = 0;    // концы полилинии закрулены (на концах полилинии 
// рисуются круги) PS_ENDCAP_SQUARE = $100; // на концах полилинии рисуются 
// квадраты PS_ENDCAP_FLAT   = $200; // концы полилинии обрезаны (короче на 
// полширины линии с каждой сторы)
//
// PS_JOIN_ROUND    = 0;     // внутрение вершины закрулены PS_JOIN_BEVEL    = 
// $1000; // внутрение вершины острые, без ограничения длины угла PS_JOIN_MITER 
// = $2000; // внутрение вершины острые, с ограничением максимальной длины (set 
// by SetMeterLimit method)
//
// PS_COSMETIC      = 0;      // простая линия (сплошная и тонкая 
// (однопиксельная)) PS_GEOMETRIC     = $10000; // узорная линия
//
// ************************* Brush Styles BS_SOLID                = 0; BS_NULL  
// = 1; BS_HOLLOW               = BS_NULL; BS_HATCHED              = 2; 
// BS_PATTERN              = 3; BS_INDEXED              = 4; BS_DIBPATTERN      
// = 5; BS_DIBPATTERNPT         = 6; BS_PATTERN8X8           = 7; 
// BS_DIBPATTERN8X8        = 8; BS_MONOPATTERN          = 9;
//
// DIB_RGB_COLORS          = 0; LogBrush.lbColor value for BS_DIBPATTERN Brush 
// Style DIB_PAL_COLORS          = 0; LogBrush.lbColor value for BS_DIBPATTERN 
// Brush Style
//
// HS_HORIZONTAL = 0;       { ----- } HS_VERTICAL   = 1;       { ||||| } 
// HS_FDIAGONAL  = 2;       { ///// } HS_BDIAGONAL  = 3;       { \\\\\ } 
// HS_CROSS      = 4;       { +++++ } HS_DIAGCROSS  = 5;       { xxxxx }
//
procedure TN_OCanvas.SetPenAttribs( APenColor: integer; APenWidth: float = 1.0;
                              APenStyle: integer = 0; APDashSizes: PFloat = nil;
                                            ANumDashes: integer = 0 );
var
  i, DeviceColor: integer;
  OldHandle, NewHandle: HPen;
  LogBrush: TLogBrush;
  PIntDashSizes: PInteger;
begin
  // N_CurColor is a spechial value (=-2), it means last used color should be used again
  // N_CurLLWSize is a spechial value (=-2), it means last used Pen Width should be used again
  if ((APenColor = N_CurColor) and (APenWidth = N_CurLLWSize)) then Exit; // nothing to do

  // check if all Pen attributes are the same
  if (APenColor = ConPenColor)    and
     (APenWidth = ConPenLLWWidth) and
     (APenStyle = ConPenStyle)        then Exit; // nothing to do

  if APenColor = N_CurColor then APenColor := ConPenColor; // use current color

  ConPenColor    := APenColor;
  ConPenLLWWidth := APenWidth;
  ConPenStyle    := APenStyle;

  if APenColor = N_EmptyColor then // set empty color
  begin
    NewHandle := GetStockObject( NULL_PEN	);
    OldHandle := SelectObject( HMDC, NewHandle );
    DeleteObject( OldHandle );
  end else  // set new color, width and style
  begin
    DeviceColor := APenColor;
    if CPixFmt = pf16Bit then // conv to HighColor if needed (now practically not used)
      DeviceColor := N_RoundTo16bitColor( APenColor );

    // to assure that ConPenLLWWidth correspond to ConPenPixWidth,
    // ConPenLLWWidth should be set to N_NotAFloat after changing CurLLWPixSize!

    //*** note, that now LLWToPix1 may return 0
    ConPenPixWidth := max( 1, LLWToPix1( ConPenLLWWidth )); // should be always >= 1
    
    with LogBrush do
    begin
      lbStyle := BS_SOLID;
      lbColor := DeviceColor;
      lbHatch := 0;
    end;

    if (ConPenPixWidth > 1) or (APenStyle <> 0) or
       (ANumDashes >= 2)  then APenStyle := APenStyle or PS_GEOMETRIC;

    if ANumDashes >= 2 then // Dashed Line
    begin
      APenStyle := APenStyle or PS_USERSTYLE;
      if Length(WrkPixDashes) < ANumDashes then
        SetLength( WrkPixDashes, ANumDashes+4 );

      PIntDashSizes := @WrkPixDashes[0];

      for i := 0 to ANumDashes-1 do // convert Sizes in LLW to Pixels for ExtCreatePen
      begin
        //      In ExtCreatePen Dashes are one pixel bigger, Gaps are one pixel smaller
        //      (in both compatible and advanced modes)
        //        e.g 0, 2 means one pixel dash and one pixel gap
        //        e.g 1, 3 means two pixels dash and two pixels gap
        //       So, even (2*k) dashes should be decreased by 1,
        //           odd (2*k+1) dashes should be increased by 1

        WrkPixDashes[i] := LLWToPix( APDashSizes^ ) + 2*( i and $1 ) - 1;
        Inc( APDashSizes );
      end; // for i := 0 to ANumDashes-1 do // convert Sizes in LLW to Pixels for ExtCreatePen
    end else // Solid (not Dashed) Line
    begin
      APenStyle := APenStyle and ( not PS_USERSTYLE ); // clear PS_USERSTYLE bits
      ANumDashes := 0;
      PIntDashSizes := nil;
    end;

    NewHandle := ExtCreatePen( APenStyle, ConPenPixWidth, LogBrush, ANumDashes, PIntDashSizes );
//    NewHandle := GetStockObject( White_PEN	);

    OldHandle := SelectObject( HMDC, NewHandle );
    DeleteObject( OldHandle );
  end; // else  // set new color and width
end; //*** end of procedure TN_OCanvas.SetPenAttribs

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetBrushAttribs
//********************************************** TN_OCanvas.SetBrushAttribs ***
// Set Brush Attributes
//
//     Parameters
// ABrushColor - brush color
//
procedure TN_OCanvas.SetBrushAttribs( ABrushColor: integer );
var
  OldHandle, NewHandle: HBrush;
begin
  if (ABrushColor = ConBrushColor) or (ABrushColor = N_CurColor) then Exit;
  ConBrushColor := ABrushColor;

  if ABrushColor = N_EmptyColor then
  begin
    NewHandle := GetStockObject( NULL_BRUSH	);
    OldHandle := SelectObject( HMDC, NewHandle );
    DeleteObject( OldHandle );
  end else
  begin
    if CPixFmt = pf16Bit then
      ABrushColor := N_RoundTo16bitColor( ABrushColor );

    NewHandle := CreateSolidBrush( ABrushColor );
    OldHandle := SelectObject( HMDC, NewHandle );
    DeleteObject( OldHandle );
  end;

end; //*** end of procedure TN_OCanvas.SetBrushAttribs

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetFontAttribs
//*********************************************** TN_OCanvas.SetFontAttribs ***
// Set Font Attributes
//
//     Parameters
// ATextColor    - text foreground color
// ABackColor    - text background color
// ABreaksExtPix - whole Extra Space (in pixels) to add
// ANumBreaks    - number of Break Chars (ABreaksExtPix/ANumBreaks is added to 
//                 each Break Char)
//
procedure TN_OCanvas.SetFontAttribs( ATextColor: integer = 0; ABackColor: integer = N_EmptyColor;
                              ABreaksExtPix: integer = 0; ANumBreaks: integer = 0 );
begin
  if ATextColor = N_EmptyColor then Exit;

  if (ATextColor <> ConTextColor) and (ATextColor <> N_CurColor) then
  begin
    ConTextColor := ATextColor;
    if CPixFmt = pf16Bit then
      ATextColor := N_RoundTo16bitColor( ATextColor );
    Windows.SetTextColor( HMDC, ATextColor );
  end; // if ATextColor <> ConTextColor then

  SetBackColor( ABackColor );
{
  if (ABackColor <> ConBackColor) and (ABackColor <> N_CurColor) then
  begin
    ConBackColor := ABackColor;

    if ABackColor = N_EmptyColor then
      Windows.SetBkMode( HMDC, TRANSPARENT )
    else
    begin
      Windows.SetBkMode( HMDC, OPAQUE );
      if CPixFmt = pf16Bit then
        ABackColor := N_RoundTo16bitColor( ABackColor );

      Windows.SetBkColor( HMDC, ABackColor );
    end;

  end; // if ABackColor <> ConBackColor then
}
  if (ABreaksExtPix <> ConBreaksExtPix) or (ANumBreaks <> ConNumBreaks) then
  begin
    ConBreaksExtPix := ABreaksExtPix;
    ConNumBreaks    := ANumBreaks;
    Windows.SetTextJustification( HMDC, ABreaksExtPix, ANumBreaks );
  end; // if ... then
end; //*** end of procedure TN_OCanvas.SetFontAttribs

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\GetStringSize
//************************************************ TN_OCanvas.GetStringSize ***
// Get given string size (dimensions) in pixels
//
//     Parameters
// AStr    - given string
// AWidth  - resulting string width in pixels
// AHeight - resulting string height in pixels
//
procedure TN_OCanvas.GetStringSize( AStr: string; out AWidth, AHeight: integer );
var
  StrLeng: integer;
  StrSize: TSize;
begin
  StrLeng := Length(AStr);
  if StrLeng >= 1 then
  begin
    GetTextExtentPoint32( HMDC, @AStr[1], StrLeng, StrSize );
    AWidth := StrSize.cx;
    AHeight := StrSize.cy;
  end else
  begin
    AWidth := 0;
    AHeight := 0;
  end;
end; //*** end of procedure TN_OCanvas.GetStringSize

//************************************************ TN_OCanvas.SetFontSize ***
// set current Font size by points (SizeMode=0) or by given Rect dimensions
// in User units and given string to fit into it
//
// SizeMode - =0 use DXU as font size in Points
//            =1 use User Rect and string
// DXU, DYU - Rect dimensions in User units (for SizeMode=1)
// Str      - string to fit in given Rect
//
procedure TN_OCanvas.SetFontSize( SizeMode: integer; const DXU, DYU: double;
                                                                Str: string );
begin
{
var
  NewFontLFHSize: float;
  PixSizeX, PixSizeY: integer;
  CoefX, CoefY: double;
begin
  case SizeMode of
  0: begin // DXU is needed size in points
    NewFontLFHSize := Round( DXU * DstResDPI / 72 );
  end; // 0: begin // DXU is needed size in points

  1: begin // Calc size to fit given string in given Rect (in User Coords)
//!!    SetFontAttribs( '-1', 20, N_CurFontStyle, N_CurColor, N_CurColor );
    GetStringSize( Str, PixSizeX, PixSizeY );
    CoefX := DXU*ABS(U2P.CX) / PixSizeX;
    CoefY := DYU*ABS(U2P.CY) / PixSizeY;

    if CoefX < CoefY then
      NewFontLFHSize := ConFontSize * CoefX
    else
      NewFontLFHSize := ConFontSize * CoefY;
  end; // 1: begin // Calc size to fit given string in given Rect (in User Coords)

  else
    Exit; // wrong SizeMode

  end; // case SizeMode of

//!!  SetFontAttribs( '-1', NewFontLFHSize, N_CurFontStyle, N_CurColor, N_CurColor );
  GetStringSize( Str, PixSizeX, PixSizeY );
}
end; //*** end of procedure TN_OCanvas.SetFontSize

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetExtraSpace
//************************************************ TN_OCanvas.SetExtraSpace ***
// Set special mode, in which DrawPixString method adds additional pixels after 
// each character and to break characters
//
//     Parameters
// AAllCharsPix  - number of Extra Space Pixels to add after all characters
// ABreakCharPix - number of Extra Space Pixels to add to each set of 
//                 ConNumBreaks break characters
// ANumBreaks    - number of break characters, along which BreakCharPix value 
//                 should be distributed uniformly
//
procedure TN_OCanvas.SetExtraSpace( AAllCharsPix, ABreakCharPix, ANumBreaks: integer );
begin
  SetTextCharacterExtra( HMDC, AAllCharsPix );
  SetTextJustification( HMDC, ABreakCharPix, ANumBreaks );
end; //*** end of procedure TN_OCanvas.SetExtraSpace

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\SetPClipRect
//************************************************* TN_OCanvas.SetPClipRect ***
// Set Clip Region in HMDC Device Context
//
//     Parameters
// APClipRect - given pixel Clip Region coordinates as integer rectangle
//
// If given rectangle APClipRect.Left is equal to N_NotAnInteger then clip rest 
// will be removed. All clip rectangle edges are included in given APClipRect.
//
procedure TN_OCanvas.SetPClipRect( const APClipRect: TRect );
var
  RgnHandle: HRgn;
begin
  ConPClipRect := APClipRect;

  if ConPClipRect.Left <> N_NotAnInteger then
  begin
    RgnHandle := CreateRectRgn( ConPClipRect.Left,    ConPClipRect.Top,
                                ConPClipRect.Right+1, ConPClipRect.Bottom+1 );
    SelectClipRgn( HMDC, RgnHandle );
    DeleteObject( RgnHandle );
  end else // remove Clip Rect
  begin
    // Remark: ExtSelectClipRgn( HMDC, RgnHandle, RGN_COPY	); is same as
    //            SelectClipRgn( HMDC, RgnHandle );

    if OCanvType = octEMF then
      SelectClipRgn( HMDC, FullRgnH ) // Zero Region causes error in Corel EMF!
    else
    begin
      RgnHandle := 0;
      SelectClipRgn( HMDC, RgnHandle );
    end;
  end;
end; //*** end of procedure TN_OCanvas.SetPClipRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\RemovePClipRect
//********************************************** TN_OCanvas.RemovePClipRect ***
// Remove Clip Region from HMDC Device Context
//
procedure TN_OCanvas.RemovePClipRect();
begin
  SetPClipRect( Rect( N_NotAnInteger, 0, 0, 0 ) );
end; //*** end of procedure TN_OCanvas.RemovePClipRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixRect(1)
//*********************************************** TN_OCanvas.DrawPixRect(1) ***
// Draw given pixel rectangle
//
//     Parameters
// ARect - given rectangle pixel coordinates
//
// Draw given pixel rectangle including lower and right rectangle edges using 
// current Brush and Pen attributes (now only in NativeWidePen mode).
//
procedure TN_OCanvas.DrawPixRect( const ARect: TRect );
var
  HalfWidth: integer;
begin
  Windows.Rectangle( HMDC, ARect.Left, ARect.Top,
                           ARect.Right+ConOnePix, ARect.Bottom+ConOnePix );

  if CollectInvRects then
  begin
    HalfWidth := 2; //  2 is precaution, only 1 is needed
    with ARect do
      N_AddOneRect( InvRects, NumInvRects,
                    Rect( Left-HalfWidth,  Top-HalfWidth,
                          Right+HalfWidth, Bottom+HalfWidth ) );
  end;
end; //*** end of procedure TN_OCanvas.DrawPixRect(1)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixRect(3)
//*********************************************** TN_OCanvas.DrawPixRect(3) ***
// Draw given pixel rectangle
//
//     Parameters
// ARect     - given rectangle pixel coordinates
// AAttrType - draw attributes type
// APAttribs - pointegr to draw atributes
//
// Draw given pixel rectangle including lower and right rectangle edges using 
// given Attributes
//
procedure TN_OCanvas.DrawPixRect( const ARect: TRect; AAttrType: integer;
                                                          APAttribs: Pointer );
var
  Shift, PixWidth, i, NumRecords, RAttrType, AWidth, AHeight: integer;
  HBr: HBrush;
  RectPlus: TRect;
//  PTmpp: PChar;
begin
  AWidth  := 0;
  AHeight := 0;

  if AAttrType = 0 then
  begin
    AAttrType := PInteger(APAttribs)^; // first Integer in Attribs record
    Inc( TN_BytesPtr(APAttribs), Sizeof(integer) );
  end;

  with ARect do RectPlus := Rect( Left, Top, Right+1, Bottom+1 );

  case AAttrType of

  1: //*********************************** Rect Attributes #1
  with TN_PPixRectAttr1(APAttribs)^ do
  begin
    if ((ModeFlags and $010) <> 0) and (FillColor <> N_EmptyColor) then
    begin
      HBr := CreateSolidBrush( FillColor );
      Windows.FillRect( HMDC, RectPlus, HBr );
      DeleteObject( HBr );
    end;

    RectPlus := N_RectIncr( ARect, LLWToPix( ABShift ), LLWToPix( ABShift ) );
    if ((ModeFlags and $020) <> 0) then // create or draw Bitmap
    begin
      if FillBMP = nil then // create FillBMP and fill it from MainCanvas
      begin
        FillBMP := TBitmap.Create;
        with FillBMP do
        begin
          AWidth  := N_RectWidth( RectPlus );
          Width   := AWidth;
          AHeight := N_RectHeight( RectPlus );
          Height  := AHeight;
          PixelFormat := CPixFmt;
          BitBlt( Canvas.Handle, 0, 0, AWidth, AHeight, HMDC,
                                        RectPlus.Left, RectPlus.Top, SRCCOPY );
        end;
      end else with FillBMP do
        BitBlt( HMDC, RectPlus.Left, RectPlus.Top, AWidth, AHeight,
                                                Canvas.Handle, 0, 0, SRCCOPY );
    end; // if ((ModeFlags and $020) <> 0) then // create or draw Bitmap

    if ((ModeFlags and $00F) <> 0) and
       (Border.Color <> N_EmptyColor) then // draw Border
    begin
      PixWidth := LLWToPix( Border.Size );
      Shift := 0; // a precaution

      case (ModeFlags and $0F) of
      1: Shift := 0;
      2: Shift := PixWidth div 2;
      3: Shift := PixWidth;
      end;

      with RectPlus do
        RectPlus := Rect( Left-Shift, Top-Shift, Right+Shift+1, Bottom+Shift+1 );

      Inc(PixWidth);
      HBr := CreateSolidBrush( Border.Color );
      with RectPlus do
      begin
        Windows.FillRect( HMDC, Rect(Left, Top, Right, Top+PixWidth), HBr );
        Windows.FillRect( HMDC, Rect(Right-PixWidth, Top, Right, Bottom), HBr );
        Windows.FillRect( HMDC, Rect(Left, Bottom-PixWidth, Right, Bottom), HBr );
        Windows.FillRect( HMDC, Rect(Left, Top, Left+PixWidth, Bottom), HBr );
      end; // with ARect do
      DeleteObject( HBr );
    end; // if ((ModeFlags and $00F) <> 0) and ...

    if CollectInvRects then
      N_AddOneRect( InvRects, NumInvRects, RectPlus );
  end; // 1: begin // Point Attributes #1

  2: begin //*********************************** Rect Attributes #2
           // sequence of any Rect Attributes except #2
           // not tested yet

    NumRecords := PInteger(APAttribs)^; // Number of Records in sequence
    Inc( TN_BytesPtr(APAttribs), Sizeof(integer) );


    for i := 1 to NumRecords do
    begin
      RAttrType := PInteger(APAttribs)^; // cur Records Attributes type
      Inc( TN_BytesPtr(APAttribs), Sizeof(integer) );

      case RAttrType of
      1: begin
        DrawPixRect( ARect, 1, APAttribs );
        Inc( TN_BytesPtr(APAttribs), Sizeof(TN_PixRectAttr1) ); // to next Record
      end; // 1: begin
      else
//        Assert( False, 'Bad AttrType' );
        raise Exception.Create( 'Bad AttrType' );
      end; // case RAttrType of

    end; // for i := 1 to NumRecords do

//   with TN_PPixRectAttr1(PAttribs)^ do
  end; // 2: begin Rect Attributes #2

  end; // case AttrType of
end; //*** end of procedure TN_OCanvas.DrawPixRect(3)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserRect
//************************************************* TN_OCanvas.DrawUserRect ***
// Draw given rectangle in user coordinates
//
//     Parameters
// AUserRect - given rectangle in user coordinates
//
// Draw given rectangle in user coordinates using current Brush and Pen 
// attributes (now only in NativeWidePen mode).
//
procedure TN_OCanvas.DrawUserRect( const AUserRect: TFRect );
begin
  DrawPixRect( N_AffConvF2IRect( AUserRect, U2P ) );
end; //*** end of procedure TN_OCanvas.DrawUserRect

{
//******************************************* TN_OCanvas.DrawUserPoint ***
// draw Point in User coords by some sign
// by current Brush and Pen attributes
//
// UserBP   - User Base Point coords
// AttrType - what is given by PAttribs:
//     =0 - AttrType is given by first integer in PAttribs^
//     =1 - PAttribs is TN_PPointAttr1
// PAttribs - Pointer to Attributes (see AttrType)
//
procedure TN_OCanvas.DrawUserPoint( const UserBP: TDPoint;
                                    const Params: TN_PointAttr1 );
var
  PixSizeX, PixSizeY, PixSiftX, PixSiftY, HalfPW, dx, dy: integer;
  Shape: TN_StandartShape;
  PixBP: TPoint;
  PixRect: TRect;
begin
  if 0 <> N_PointInRect( UserBP, MinUClipRect ) then Exit; // Not visible

  with Params do
  begin
    SetPenAttribs( SPenColor, SPenWidth );
    SetBrushAttribs( SBrushColor );

    PixSizeX := LLWToPix( SSizeXY.X );
    PixSizeY := LLWToPix( SSizeXY.Y );
    PixRect  := Rect( 0, 0, PixSizeX-1, PixSizeY-1 );
    PixBP    := N_AffConvD2IPoint( UserBP, U2P );
    PixSiftX := LLWToPix( SShiftXY.X - SSizeXY.X*SHotPoint.X + 0.001 );
    PixSiftY := LLWToPix( SShiftXY.Y - SSizeXY.Y*SHotPoint.Y + 0.001 );
    PixRect  := N_RectShift( PixRect, PixBP.X + PixSiftX, PixBP.Y + PixSiftY );

    PixBP.X := PixRect.Left + Round( 0.5*(PixSizeX) - 0.001 ); // set to Sign Center
    PixBP.Y := PixRect.Top  + Round( 0.5*(PixSizeY) - 0.001 ); // set to Sign Center

    Shape := SShape;
    if Shape = [] then Shape := [sshRect];

    if sshATriangle in Shape then //***** Triangle ('A' like)
    with PixRect do
    begin
      WrkCILine[0].X := PixBP.X;
      WrkCILine[0].Y := Top;
      WrkCILine[1].X := Right;
      WrkCILine[1].Y := Bottom;
      WrkCILine[2].X := Left;
      WrkCILine[2].Y := Bottom;
      WrkCILine[3].X := PixBP.X;
      WrkCILine[3].Y := Top;
      Windows.Polygon( HMDC, (@WrkCILine[0])^, 4 );
    end;

    if sshVTriangle in Shape then //***** Triangle ('V' like)
    with PixRect do
    begin
      WrkCILine[0].X := Left;
      WrkCILine[0].Y := Top;
      WrkCILine[1].X := PixBP.X;
      WrkCILine[1].Y := Bottom;
      WrkCILine[2].X := Right;
      WrkCILine[2].Y := Top;
      WrkCILine[3].X := Left;
      WrkCILine[3].Y := Top;
      Windows.Polygon( HMDC, (@WrkCILine[0])^, 4 );
    end;

    if sshLTriangle in Shape then //***** Triangle ('<' like)
    with PixRect do
    begin
      WrkCILine[0].X := Left;
      WrkCILine[0].Y := PixBP.Y;
      WrkCILine[1].X := Right;
      WrkCILine[1].Y := Top;
      WrkCILine[2].X := Right;
      WrkCILine[2].Y := Bottom;
      WrkCILine[3].X := Left;
      WrkCILine[3].Y := PixBP.Y;
      Windows.Polygon( HMDC, (@WrkCILine[0])^, 4 );
    end;

    if sshGTriangle in Shape then //***** Triangle ('>' like)
    with PixRect do
    begin
      WrkCILine[0].X := Left;
      WrkCILine[0].Y := Top;
      WrkCILine[1].X := Right;
      WrkCILine[1].Y := PixBP.Y;
      WrkCILine[2].X := Left;
      WrkCILine[2].Y := Bottom;
      WrkCILine[3].X := Left;
      WrkCILine[3].Y := Top;
      Windows.Polygon( HMDC, (@WrkCILine[0])^, 4 );
    end;

    if sshRect in Shape then //***** Rectangular
    with PixRect do
    begin
      WrkCILine[0].X := Left;
      WrkCILine[0].Y := Top;
      WrkCILine[1].X := Right;
      WrkCILine[1].Y := Top;
      WrkCILine[2].X := Right;
      WrkCILine[2].Y := Bottom;
      WrkCILine[3].X := Left;
      WrkCILine[3].Y := Bottom;
      WrkCILine[4].X := Left;
      WrkCILine[4].Y := Top;
      Windows.Polygon( HMDC, (@WrkCILine[0])^, 5 );
    end;

    if sshRomb in Shape then //***** romb (rotated qwadrat)
    with PixRect do
    begin
      WrkCILine[0].X := PixBP.X;
      WrkCILine[0].Y := Top;
      WrkCILine[1].X := Right;
      WrkCILine[1].Y := PixBP.Y;
      WrkCILine[2].X := PixBP.X;
      WrkCILine[2].Y := Bottom;
      WrkCILine[3].X := Left;
      WrkCILine[3].Y := PixBP.Y;
      WrkCILine[4].X := PixBP.X;
      WrkCILine[4].Y := Top;
      Windows.Polygon( HMDC, (@WrkCILine[0])^, 5 );
    end;

    if sshEllipse in Shape then //***** Ellipse
    with PixRect do
      Windows.Ellipse( HMDC, Left, Top, Right+1, Bottom+1 );

    if sshPlus in Shape then //***** Plus Sign ('+')
    with PixRect do
    begin
      WrkCILine[0].X := Left;
      WrkCILine[0].Y := PixBP.Y;
      WrkCILine[1].X := Right+1;
      WrkCILine[1].Y := PixBP.Y;
      Windows.Polyline( HMDC, (@WrkCILine[0])^, 2 );

      WrkCILine[0].X := PixBP.X;
      WrkCILine[0].Y := Top;
      WrkCILine[1].X := PixBP.X;
      WrkCILine[1].Y := Bottom+1;
      Windows.Polyline( HMDC, (@WrkCILine[0])^, 2 );
    end;

    if sshCornerMult in Shape then //***** Multipliy Sign ('x') with Line Ends at Corners
    with PixRect do
    begin
      WrkCILine[0].X := Left;
      WrkCILine[0].Y := Top;
      WrkCILine[1].X := Right+1;
      WrkCILine[1].Y := Bottom+1;
      Windows.Polyline( HMDC, (@WrkCILine[0])^, 2 );

      WrkCILine[0].X := Right;
      WrkCILine[0].Y := Top;
      WrkCILine[1].X := Left-1;
      WrkCILine[1].Y := Bottom+1;
      Windows.Polyline( HMDC, (@WrkCILine[0])^, 2 );
    end;

    if sshEllMult in Shape then //***** Multipliy Sign ('x') with Line Ends at Circle
    with PixRect do
    begin
      dx := Round( PixSizeX * 0.5 * (1 - 0.5*sqrt(2)) ); // = Rad.X * (1 - cos(45))
      dy := Round( PixSizeY * 0.5 * (1 - 0.5*sqrt(2)) ); // = Rad.Y * (1 - cos(45))
      WrkCILine[0].X := Left + dx;
      WrkCILine[0].Y := Top + dy;
      WrkCILine[1].X := Right+1 - dx;
      WrkCILine[1].Y := Bottom+1 - dy;
      Windows.Polyline( HMDC, (@WrkCILine[0])^, 2 );

      WrkCILine[0].X := Right - dx;
      WrkCILine[0].Y := Top + dy;
      WrkCILine[1].X := Left-1 + dx;
      WrkCILine[1].Y := Bottom+1 - dy;
      Windows.Polyline( HMDC, (@WrkCILine[0])^, 2 );
    end;

    if CollectInvRects then
    begin

      HalfPW := Round(Ceil(0.5*SPenWidth)) + 1;
      N_AddOneRect( InvRects, NumInvRects,
                                    N_RectIncr( PixRect, HalfPW, HalfPW ) );
    end;

  end; // with Params do
end; //*** end of procedure TN_OCanvas.DrawUserPoint
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixRoundRect
//********************************************* TN_OCanvas.DrawPixRoundRect ***
// Draw given pixel round rectangle by given Brush and Pen attributes
//
//     Parameters
// ARect       - given pixel rectangle
// ARoundRad   - rectangle round radiuses as integer point
// ABrushColor - Brush color
// APenColor   - Pen color
// APenWidth   - Pen width
//
// Rectangle is drawn using Windows.RoundRect routine. All border width is 
// inside given rectangle.
//
procedure TN_OCanvas.DrawPixRoundRect( const ARect: TRect; ARoundRad: TPoint;
                            ABrushColor, APenColor: integer; APenWidth: Float );
var
  PixHalfWidth1, PixHalfWidth2: integer;
begin
  if (ABrushColor = N_EmptyColor) and
     (APenColor   = N_EmptyColor)     then Exit; // nothing todo

  SetBrushAttribs( ABrushColor );
  SetPenAttribs( APenColor, APenWidth );

  PixHalfWidth1 := (ConPenPixWidth - 1) div 2; // for odd ConPenPixWidth
  PixHalfWidth2 := (ConPenPixWidth) div 2; // for even ConPenPixWidth Top and Left sides

  if APenColor = N_EmptyColor then
  begin
    PixHalfWidth1 := -1;
    PixHalfWidth2 := 0;
  end;

  Windows.RoundRect( HMDC, ARect.Left+PixHalfWidth2, ARect.Top+PixHalfWidth2,
                ARect.Right-PixHalfWidth1+ConOnePix, ARect.Bottom-PixHalfWidth1+ConOnePix,
                     2*ARoundRad.X, 2*ARoundRad.Y );

  if CollectInvRects then
  begin
    with ARect do
      N_AddOneRect( InvRects, NumInvRects, ARect );
  end;
end; //*** end of procedure TN_OCanvas.DrawPixRoundRect

//******************************************* TN_OCanvas.DrawUserRoundRect ***
// draw Round Rect in User coords
// by current Brush and Pen attributes (now only in NativeWidePen mode)
//
// RoundSizeXY - Ellipse size in LSU, that matches round rects
//
procedure TN_OCanvas.DrawUserRoundRect( const UserRect: TFRect; RoundSizeXY: TFPoint );
begin
// Is needed?
//  DrawPixRoundRect( N_AffConvF2IRect( UserRect, U2P ),
//                            LLWToPix(RoundSizeXY.X), LLWToPix(RoundSizeXY.Y) );
end; //*** end of procedure TN_OCanvas.DrawUserRoundRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixFilledRect
//******************************************** TN_OCanvas.DrawPixFilledRect ***
// Draw filled given pixel rectangle
//
//     Parameters
// ARect - given rectangle in pixel coordinates
//
// Fill given rectangle in pixel coordinates including lower and right rectangle
// edges by current Brush (Pen Color does not matter).
//
procedure TN_OCanvas.DrawPixFilledRect( const ARect: TRect );
var
  CurHandle: LongWord;
begin
  if ConBrushColor = N_EmptyColor then Exit; // nothing todo

  CurHandle := GetCurrentObject( HMDC, OBJ_BRUSH );
  Windows.FillRect( HMDC, Rect( ARect.Left, ARect.Top,
                                ARect.Right+1, ARect.Bottom+1 ), CurHandle );
  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, ARect );
end; //*** end of procedure TN_OCanvas.DrawPixFilledRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserFilledRect
//******************************************* TN_OCanvas.DrawUserFilledRect ***
// Draw filled given rectangle in user coordinates
//
//     Parameters
// ARect - given rectangle in user coordinates
//
// Fill given rectangle in pixel coordinates by current Brush (Pen Color does 
// not matter).
//
procedure TN_OCanvas.DrawUserFilledRect( const AUserRect: TFRect );
begin
  DrawPixFilledRect( N_AffConvF2IRect( AUserRect, U2P ) );
end; //*** end of procedure TN_OCanvas.DrawUserFilledRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixFilledRect2
//******************************************* TN_OCanvas.DrawPixFilledRect2 ***
// Draw filled given pixel rectangle
//
//     Parameters
// ARect - given rectangle in pixel coordinates
//
// Fill given rectangle in pixel coordinates including lower and right rectangle
// edges by current Brush (Pen Color does not matter).
//
procedure TN_OCanvas.DrawPixFilledRect2( const ARect: TRect; AColor: integer );
var
  TmpHandle: LongWord;
begin
  if AColor = N_EmptyColor then Exit; // nothing todo

  TmpHandle := Windows.CreateSolidBrush( AColor );
  Windows.FillRect( HMDC, Rect( ARect.Left, ARect.Top,
                                ARect.Right+1, ARect.Bottom+1 ), TmpHandle );
  N_b := Windows.DeleteObject( TmpHandle );

  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, ARect );
end; //*** end of procedure TN_OCanvas.DrawPixFilledRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixRectBorder
//******************************************** TN_OCanvas.DrawPixRectBorder ***
// Draw given pixel rectangle boder by current Brush Color and given Border 
// Width
//
//     Parameters
// ARect           - given rectangle in pixel coordinates
// APixBorderWidth - given border width in pixels
//
// Lower right border corner coordinates are (Right-1, Bottom-1), rectangle 
// border is outer border, whole border width is inside it.
//
procedure TN_OCanvas.DrawPixRectBorder( const ARect: TRect;
                                                    APixBorderWidth: integer );
var
  PBWidth: integer;
begin
  if APixBorderWidth <= 0 then Exit;
  PBWidth := APixBorderWidth - 1;

  with ARect do
  begin
    DrawPixFilledRect( Rect(Left, Top, Right, Top+PBWidth) );
    DrawPixFilledRect( Rect(Right-PBWidth, Top, Right, Bottom) );
    DrawPixFilledRect( Rect(Left, Bottom-PBWidth, Right, Bottom) );
    DrawPixFilledRect( Rect(Left, Top, Left+PBWidth, Bottom) );
  end; // with ARect do

  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, ARect );
end; //*** end of procedure TN_OCanvas.DrawPixRectBorder

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixRectBorder2
//******************************************* TN_OCanvas.DrawPixRectBorder2 ***
// Draw boder of given pixel rectangle ARect by given AColor and given Border 
// Width
//
//     Parameters
// ARect           - given rectangle in pixel coordinates
// APixBorderWidth - given Border width in pixels
// ABorderColor    - given Border Color
//
// Lower right border corner coordinates are (Right-1, Bottom-1), rectangle 
// border is outer border, whole border width is inside it.
//
procedure TN_OCanvas.DrawPixRectBorder2( const ARect: TRect;
                                      APixBorderWidth, ABorderColor: integer );
var
  PBWidth: integer;
begin
  if APixBorderWidth <= 0 then Exit;
  PBWidth := APixBorderWidth - 1;

  with ARect do
  begin
    DrawPixFilledRect2( Rect(Left, Top, Right, Top+PBWidth), ABorderColor );
    DrawPixFilledRect2( Rect(Right-PBWidth, Top, Right, Bottom), ABorderColor );
    DrawPixFilledRect2( Rect(Left, Bottom-PBWidth, Right, Bottom), ABorderColor );
    DrawPixFilledRect2( Rect(Left, Top, Left+PBWidth, Bottom), ABorderColor );
  end; // with ARect do

  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, ARect );
end; //*** end of procedure TN_OCanvas.DrawPixRectBorder2

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixRectDashBorder
//**************************************** TN_OCanvas.DrawPixRectDashBorder ***
// Draw given pixel rectangle dashed border by given dash attributes and current
// Brush color
//
//     Parameters
// ARect        - outer rectangle pixel coordinates (whole border width is 
//                inside it)
// ABorderWidth - border width in pixels (same for all sides)
// ADashSize    - dash size in pixels (dash size along rectangle sides)
// ADashStep    - dash step in pixels (between two subsequent dashes along 
//                rectangle sides)
// ADashPhase   - first dash offset in pixels from rectangle  upper left corner 
//                (along upper rectangle side)
//
procedure TN_OCanvas.DrawPixRectDashBorder( const ARect: TRect; ABorderWidth,
                                    ADashSize, ADashStep, ADashPhase: integer );
var
  x1, x2, y1, y2, RightP1, BottomP1: integer;
  CurHandle: THandle;
//  PTmpp: PChar;
begin
  if ConBrushColor = N_EmptyColor then Exit; // nothing todo
  if ABorderWidth <= 0 then Exit;

  CurHandle := GetCurrentObject( HMDC, OBJ_BRUSH );

  with ARect do
  begin

  RightP1  := Right + 1;
  BottomP1 := Bottom + 1;

  x1 := Left + ABorderWidth + ADashPhase;
  y1 := Top;
  y2 := Top + ABorderWidth;

  while x1 <= Right do // Top Rect Side, from left to right
  begin
    x2 := x1 + ADashSize;
    if x2 > RightP1 then x2 := RightP1;
    Windows.FillRect( HMDC, Rect( x1, y1, x2, y2 ), CurHandle );
    x1 := x1 + ADashStep;
  end; // while True do // Top Rect Side, from left to right

  x2 := RightP1;
  x1 := x2 - ABorderWidth;
  y1 := Top + ABorderWidth + ADashPhase;

  while y1 <= Bottom do // Right Rect Side, from top to bottom
  begin
    y2 := y1 + ADashSize;
    if y2 > BottomP1 then y2 := BottomP1;
    Windows.FillRect( HMDC, Rect( x1, y1, x2, y2 ), CurHandle );
    y1 := y1 + ADashStep;
  end; // while y1 <= Bottom do // Right Rect Side, from top to bottom

  x2 := Right + 1 - ABorderWidth - ADashPhase;
  y2 := BottomP1;
  y1 := y2 - ABorderWidth;

  while x2 >= Left+1 do // Bottom Rect Side, from right to left
  begin
    x1 := x2 - ADashSize;
    if x1 < Left then x1 := Left;
    Windows.FillRect( HMDC, Rect( x1, y1, x2, y2 ), CurHandle );
    x2 := x2 - ADashStep;
  end; // while x2 >= Left+1 do // Bottom Rect Side, from right to left

  y2 := BottomP1;
  x1 := Left;
  x2 := Left + ABorderWidth;

  while y2 >= Top+1 do // Left Rect Side, from bottom to top
  begin
    y1 := y2 - ADashSize;
    if y1 < Top then y1 := Top;
    Windows.FillRect( HMDC, Rect( x1, y1, x2, y2 ), CurHandle );
    y2 := y2 - ADashStep;
  end; // while y2 >= Top+1 do // Left Rect Side, from bottom to top

  end; // with ARect do

  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, ARect );
end; //*** end of procedure TN_OCanvas.DrawPixRectDashBorder

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawDashedRect(1)
//******************************************** TN_OCanvas.DrawDashedRect(1) ***
// Draw dashed rectangle
//
//     Parameters
// AParams - dash rectangle parameters (including rectangle coordinates)
//
// Used mainly for animated rectangle outline
//
procedure TN_OCanvas.DrawDashedRect( const AParams: TN_DrawDashRectPar );
var
  OutColor, InColor: integer;
begin
  with AParams do
  begin
                               //***** temporary implementation
  if (Phase and $01) = 0 then
  begin
    OutColor := Color1;
    InColor  := Color2;
  end else
  begin
    OutColor := Color2;
    InColor  := Color1;
  end;

  SetBrushAttribs( OutColor );
  DrawPixRectBorder( OutRect, 1 );
  SetBrushAttribs( InColor );
  DrawPixRectBorder( InRect, 1 );

  end; // with Params do
end; //*** end of procedure TN_OCanvas.DrawDashedRect(1)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawDashedRect(4)
//******************************************** TN_OCanvas.DrawDashedRect(4) ***
// Draw one pixel width dashed rectangle in pixel coordinates
//
//     Parameters
// ARect     - given pixel rectangle
// ADashSize - dash size in pixels
// AColor1   - dash first color
// AColor2   - dash second color
//
procedure TN_OCanvas.DrawDashedRect( const ARect: TRect;
                                     ADashSize, AColor1, AColor2: integer );
var
  Dashes: array [0..1] of Float;
  LineCoords: TN_IPArray;
begin
    N_CalcRectCoords( LineCoords, ARect );

    Dashes[0] := ADashSize;
    Dashes[1] := ADashSize;
    SetPenAttribs( AColor1, 0.1 );
    DrawPixPolyline( LineCoords, 5 );
    SetPenAttribs( AColor2, 0.1, 0, @Dashes[0], 2 );
    DrawPixPolyline( LineCoords, 5 );
end; //*** end of procedure TN_OCanvas.DrawDashedRect(4)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixDashedRect
//******************************************** TN_OCanvas.DrawPixDashedRect ***
// Draw Black/White one pixel width dashed pixel rectangle
//
//     Parameters
// APixRect     - given pixel rectangle
// ADashPixSize - given dash size in pixels
//
procedure TN_OCanvas.DrawPixDashedRect( APixRect: TRect; ADashPixSize: integer );
var
  OldHandle, NewHandle: HPen;
  LogBrush: TLogBrush;
begin
  with LogBrush do
  begin
    lbStyle := BS_SOLID;
    lbColor := $FFFFFF;
    lbHatch := 0;
  end;

  NewHandle := ExtCreatePen( PS_GEOMETRIC or PS_DASH, 1, LogBrush, 0, nil );
  OldHandle := SelectObject( HMDC, NewHandle );
  SetBrushAttribs( N_EmptyColor );

  with APixRect do
    Windows.Rectangle( HMDC, Left, Top, Right, Bottom );

  Windows.SelectObject( HMDC, OldHandle );
  Windows.DeleteObject( NewHandle );

end; //*** end of procedure TN_OCanvas.DrawDashedRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixColorRects
//******************************************** TN_OCanvas.DrawPixColorRects ***
// Draw given filled colored rectangles (in pixel coordinates)
//
//     Parameters
// ACRects   - array of colored rectangle descriptions (each elemnt contains one
//             rectagle pixel coordinates and fill color)
// ANumRects - number of actual array elements
//
procedure TN_OCanvas.DrawPixColorRects( ACRects: TN_CRectArray; ANumRects: integer );
var
  i: integer;
begin
  for i := 0 to ANumRects-1 do
  with ACRects[i] do
  begin
    SetBrushAttribs( CRCode );
    DrawPixFilledRect( CRect );
  end; // for i := 0 to ANumRects-1 do
end; //*** end of procedure TN_OCanvas.DrawPixColorRects

//************************************************** TN_OCanvas.DrawPixGrid ***
// Draw Grid with Cell Numbers, mainly for testing
//
//     Parameters
// ARect   - Rect in Pixel Coords, where to Draw
// ASizeX  - Grid Cell Size along X (Cell Width) in pixels (>= 0)
// ABordX  - Vertical Cells Borders Width in pixels
// ANumX   - Number of Cells along X, or if = 0, cover whole ARect
// ASizeY  - Grid Cell Size along Y (Cell Height) in pixels
// ABordY  - Horizontal Cells Borders Width in pixels (>= 0)
// ANumY   - Number of Cells along Y, or if = 0, cover whole ARect
// AFillColor1 - Cells Fill Color for Even ix+iy
// AFillColor2 - Cells Fill Color for Odd ix+iy
// ABordColor  - Cells Borders Color
// AFontColor  - Font Color for drawing Cell indexes
//
// Font size is choosen automaticly according to Cell Size
//
procedure TN_OCanvas.DrawPixGrid( ARect: TRect; ASizeX, ABordX, ANumX,
                                  ASizeY, ABordY, ANumY, AFillColor1, AFillColor2,
                                  ABordColor, AFontColor: integer );
var
  ix, iy, FontPixSize: integer;
  StringPoint: TPoint;
  CellRect, BordRect: TRect;
begin
  FontPixSize := Round( 0.4*(ASizeY-ABordY) );
  if FontPixSize < 6 then FontPixSize := 0;

  N_DebSetNFont( Self, FontPixSize/CurLFHPixSize, 0 );
  SetFontAttribs( AFontColor );

  //***** Fill Cells interior and Draw Cells ix,iy indexes

  ix := -1;
  while True do // along X axis
  begin
    Inc( ix );
    CellRect.Left  := ARect.Left + ix*ASizeX;
    CellRect.Right := CellRect.Left + ASizeX - 1;

    if (ANumX > 0) and (ix = ANumX) or
       (CellRect.Left > ARect.Right) then Break;

    iy := -1;
    while True do // along Y axis
    begin
      Inc( iy );
      CellRect.Top    := ARect.Top + iy*ASizeY;
      CellRect.Bottom := CellRect.Top + ASizeY - 1;
      if (ANumY > 0) and (iy = ANumY) or
         (CellRect.Top > ARect.Bottom) then Break;

      if ( (ix+iy) and 1) = 0 then SetBrushAttribs( AFillColor1 )
                              else SetBrushAttribs( AFillColor2 );
      DrawPixFilledRect( CellRect );

      StringPoint := Point( CellRect.Left+ABordX+Round(0.1*(ASizeY-ABordY)),
                            CellRect.Top +ABordY+Round(0.1*(ASizeY-ABordY)) );

      DrawPixString( StringPoint, Format( '%d', [ix] ) );
      Inc( StringPoint.Y, FontPixSize+1 );
      DrawPixString( StringPoint, Format( '%d', [iy] ) );

    end; // while True do // along Y axis
  end; // while True do // along X axis


  //***** Draw Cells Borders

  SetBrushAttribs( ABordColor );

  BordRect.Top := ARect.Top;
  if ANumY = 0 then BordRect.Bottom := ARect.Bottom
               else BordRect.Bottom := BordRect.Top + ANumY*ASizeY + ABordY -1;
  ix := -1;

  while True do // along X axis, Draw Vertical Cells Borders
  begin
    Inc( ix );
    BordRect.Left  := ARect.Left + ix*ASizeX;
    BordRect.Right := BordRect.Left + ABordX - 1;

    if (ANumX > 0) and (ix > ANumX) or
       (BordRect.Left > ARect.Right) then Break;

    DrawPixFilledRect( BordRect );
  end; // while True do // along X axis, Draw Vertical Cells Borders

  BordRect.Left  := ARect.Left;
  if ANumX = 0 then BordRect.Right := ARect.Right
               else BordRect.Right := BordRect.Left + ANumX*ASizeX + ABordX -1;
  iy := -1;

  while True do // along Y axis, Draw Horizontal Cells Borders
  begin
    Inc( iy );
    BordRect.Top := ARect.Top + iy*ASizeY;
    BordRect.Bottom := BordRect.Top + ABordY - 1;

    if (ANumY > 0) and (iy > ANumY) or
       (BordRect.Top > ARect.Bottom) then Break;

    DrawPixFilledRect( BordRect );
  end; // while True do // along Y axis, Draw Horizontal Cells Borders

end; //*** end of procedure TN_OCanvas.DrawPixGrid

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixEllipse(1)
//******************************************** TN_OCanvas.DrawPixEllipse(1) ***
// Draw ellipse by given envelope pixel rectangle using current draw attributes 
// settings
//
//     Parameters
// APixRect - given ellipse envelope rectangle pixel coordinates
//
// Now draw ellipse only in NativeWidePen mode
//
procedure TN_OCanvas.DrawPixEllipse( APixRect: TRect );
var
  HalfWidth: integer;
begin
// lower right edge will not be drawn by Windows!
  with APixRect do
    Ellipse( HMDC, Left, Top, Right+1, Bottom+1 );

  if CollectInvRects then
  begin
    HalfWidth := (ConPenPixWidth div 2) + 2; // 2 is precaution, only 1 is needed
    with APixRect do
      N_AddOneRect( InvRects, NumInvRects,
                    Rect( Left-HalfWidth,  Top-HalfWidth,
                          Right+HalfWidth, Bottom+HalfWidth ) );
  end;
end; //*** end of procedure TN_OCanvas.DrawPixEllipse

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixEllipse(3)
//******************************************** TN_OCanvas.DrawPixEllipse(3) ***
// Draw ellipse by given envelope pixel rectangle using given draw attributes
//
//     Parameters
// APixRect    - given ellipse envelope rectangle pixel coordinates
// ABrushColor - Brush color
// APenColor   - Pen color
// APenWidth   - Pen width in LLW
//
procedure TN_OCanvas.DrawPixEllipse( APixRect: TRect; ABrushColor: integer;
                                   APenColor: integer = 0; APenWidth: float = 1 );
var
  HalfWidth: integer;
begin
  SetBrushAttribs( ABrushColor );
  SetPenAttribs( APenColor, APenWidth );

// lower right edge will not be drawn by Windows!
  with APixRect do
    Ellipse( HMDC, Left, Top, Right+1, Bottom+1 );

  if CollectInvRects then
  begin
    HalfWidth := (ConPenPixWidth div 2) + 2; // 2 is precaution, only 1 is needed
    with APixRect do
      N_AddOneRect( InvRects, NumInvRects,
                    Rect( Left-HalfWidth,  Top-HalfWidth,
                          Right+HalfWidth, Bottom+HalfWidth ) );
  end;
end; //*** end of procedure TN_OCanvas.DrawPixEllipse

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserRectEllipse
//****************************************** TN_OCanvas.DrawUserRectEllipse ***
// Draw ellipse by given envelope rectangle in User coordinates using current 
// draw attributes settings
//
//     Parameters
// AUserRect - given ellipse envelope rectangle User coordinates
//
// Now draw ellipse only in NativeWidePen mode
//
procedure TN_OCanvas.DrawUserRectEllipse( AUserRect: TFRect );
begin
  DrawPixEllipse( N_AffConvF2IRect( AUserRect, U2P ) );
end; //*** end of procedure TN_OCanvas.DrawUserRectEllipse

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserPointEllipse
//***************************************** TN_OCanvas.DrawUserPointEllipse ***
// Draw ellipse in given center User coordinates and size in LSU using current 
// draw attributes settings
//
//     Parameters
// AUserPoint - ellipse center in user coords
// ASizeXY    - ellipse width and height in LSU
//
// Now draw ellipse only in NativeWidePen mode
//
procedure TN_OCanvas.DrawUserPointEllipse( AUserPoint: TDPoint; ASizeXY: TFPoint );
var
  PixSizeX, PixSizeY: integer;
  PixBasePoint: TPoint;
  PixRect: TRect;
begin
  PixBasePoint := N_AffConvD2IPoint( AUserPoint, U2P );
  PixSizeX := Round( CurLSUPixSize*ASizeXY.X );
  PixSizeY := Round( CurLSUPixSize*ASizeXY.Y );
  PixRect.Left := PixBasePoint.X - (PixSizeX div 2);
  PixRect.Top  := PixBasePoint.Y - (PixSizeY div 2);
  PixRect.Right  := PixRect.Left + PixSizeX;
  PixRect.Bottom := PixRect.Top  + PixSizeY;
  DrawPixEllipse( PixRect );
end; //*** end of procedure TN_OCanvas.DrawUserPointEllipse

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixPolyline
//********************************************** TN_OCanvas.DrawPixPolyline ***
// Draw Polyline in pixel coordinates using current draw attributes settings
//
//     Parameters
// APoints    - array of pixel points
// ANumPoints - number of actual points in array
//
// If NativeWidePen = False, only thin (one pixel width) lines would be drawn. 
// Windows (Delphi) Polyline routine is used for polyline draw.
//
procedure TN_OCanvas.DrawPixPolyline( var APoints: TN_IPArray; ANumPoints: integer );
var
  i1: integer;
begin
  if CorrectLastPixel and (ConPenPixWidth = 1) then // add one more pixel
  begin          // (Windows do not draw last pixel for thin (1 pixel) lines! )
    if High(APoints) < ANumPoints then SetLength( APoints, ANumPoints+1 );
    i1 := ANumPoints - 1;
    APoints[ANumPoints].X := APoints[i1].X + 1;
    APoints[ANumPoints].Y := APoints[i1].Y + 1;

    if APoints[ANumPoints].X = APoints[0].X then    // needed only for lines of
      APoints[ANumPoints].X := APoints[i1].X - 1;   //        two pixels length

    Inc(ANumPoints);
  end;

  Windows.Polyline( HMDC, (@APoints[0])^, ANumPoints );

  if CollectInvRects then
  begin
    N_AddLineRect( APoints, ANumPoints, InvRects, NumInvRects, ConPenPixWidth );
  end;
end; //*** end of procedure TN_OCanvas.DrawPixPolyline

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixPolygon
//*********************************************** TN_OCanvas.DrawPixPolygon ***
// Draw Polygon in pixel coordinates using current draw attributes settings
//
//     Parameters
// APoints    - array of pixel points
// ANumPoints - number of actual points in array
//
// If NativeWidePen = False, only thin (one pixel width) bordres would be drawn.
// Windows (Delphi) Polygon routine is used for polygon draw.
//
procedure TN_OCanvas.DrawPixPolygon( APoints: TN_IPArray;
                                                    const ANumPoints: integer );
begin
  Windows.Polygon( HMDC, (@APoints[0])^, ANumPoints );
end; //*** end of procedure TN_OCanvas.DrawPixPolygon

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixRectSegments
//****************************************** TN_OCanvas.DrawPixRectSegments ***
// Draw given Segments of given ARect by given draw attributes
//
//     Parameters
// APenColor  - Pen color
// APenWidth  - Pen width in LLW
// APixRect   - given rectangle in pixel coordinates which segments should be 
//              drawn
// ASegmFlags - which segments should be drawn Flags: bit0 ($01) - Left side 
//              bit1 ($02) - Top side bit2 ($04) - Right side bit3 ($08) - 
//              Bottom side bit4 ($10) - Backslash diagonal 
//              (TopLeft->BottomRight) bit5 ($20) - Slash diagonal 
//              (BottomLeft->TopRight)
//
procedure TN_OCanvas.DrawPixRectSegments( APenColor: integer; APenWidth: float;
                                          APixRect: TRect; ASegmFlags: integer );
var
  PixSegm: TN_IPArray;
begin
  SetPenAttribs( APenColor, APenWidth );
  SetLength( PixSegm, 2 );

  if (ASegmFlags and $001) <> 0 then // bit0 ($01) - Left side
  begin
    PixSegm[0]   := APixRect.TopLeft;
    PixSegm[1].X := APixRect.Left;
    PixSegm[1].Y := APixRect.Bottom;
    DrawPixPolyline( PixSegm, 2 );
  end; // if (ASegmFlags and $001) <> 0 then // bit0 ($01) - Left side

  if (ASegmFlags and $002) <> 0 then // bit0 ($02) - Top side
  begin
    PixSegm[0]   := APixRect.TopLeft;
    PixSegm[1].X := APixRect.Right;
    PixSegm[1].Y := APixRect.Top;
    DrawPixPolyline( PixSegm, 2 );
  end; // if (ASegmFlags and $002) <> 0 then // bit0 ($02) - Top side

  if (ASegmFlags and $004) <> 0 then // bit0 ($04) - Right side
  begin
    PixSegm[0]   := APixRect.BottomRight;
    PixSegm[1].X := APixRect.Right;
    PixSegm[1].Y := APixRect.Top;
    DrawPixPolyline( PixSegm, 2 );
  end; // if (ASegmFlags and $004) <> 0 then // bit0 ($04) - Right side

  if (ASegmFlags and $008) <> 0 then // bit0 ($08) - Bottom side
  begin
    PixSegm[0]   := APixRect.BottomRight;
    PixSegm[1].X := APixRect.Left;
    PixSegm[1].Y := APixRect.Bottom;
    DrawPixPolyline( PixSegm, 2 );
  end; // if (ASegmFlags and $008) <> 0 then // bit0 ($08) - Bottom side

  if (ASegmFlags and $010) <> 0 then // bit4 ($10) - Backslash diagonal (TopLeft->BottomRight)
  begin
    PixSegm[0] := APixRect.TopLeft;
    PixSegm[1] := APixRect.BottomRight;
    DrawPixPolyline( PixSegm, 2 );
  end; // if (ASegmFlags and $010) <> 0 then // bit4 ($10) - Backslash diagonal (TopLeft->BottomRight)

  if (ASegmFlags and $020) <> 0 then // bit5 ($20) - Slash diagonal (BottomLeft->TopRight)
  begin
    PixSegm[0].X := APixRect.Left;
    PixSegm[0].Y := APixRect.Bottom;
    PixSegm[1].X := APixRect.Right;
    PixSegm[1].Y := APixRect.Top;
    DrawPixPolyline( PixSegm, 2 );
  end; // if (ASegmFlags and $020) <> 0 then // bit5 ($20) - Slash diagonal (BottomLeft->TopRight)
  
end; // procedure TN_OCanvas.DrawPixRectSegments

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawCurPath
//************************************************** TN_OCanvas.DrawCurPath ***
// Draw current Path by given draw attributes
//
//     Parameters
// ABrushColor - Brush color
// APenColor   - Pen color
// APenWidth   - Pen width in LLW
// APenStyle   - Pen style
// APDashSizes - ponter dash sizes array start element (size in LLW)
// ANumDashes  - number of dash sizes array actual elements
//
procedure TN_OCanvas.DrawCurPath( ABrushColor, APenColor: integer; APenWidth: float;
                              APenStyle: integer = 0; APDashSizes: PFloat = nil;
                                                      ANumDashes: integer = 0 );
begin
  if ABrushColor = N_EmptyColor then
  begin
    SetPenAttribs( APenColor, APenWidth, APenStyle, APDashSizes, ANumDashes );
    StrokePath( HMDC );
  end else // ABrushColor <> N_EmptyColor
  begin
    if APenColor = N_EmptyColor then
    begin
      SetBrushAttribs( ABrushColor );
      FillPath( HMDC );
    end else // APenColor <> N_EmptyColor and ABrushColor <> N_EmptyColor
    begin
      SetBrushAttribs( ABrushColor );
      if ANumDashes = 0 then APDashSizes := nil; // a precaution
      SetPenAttribs( APenColor, APenWidth, APenStyle, APDashSizes, ANumDashes );
      StrokeAndFillPath( HMDC );

// Windows error ???? - при заливке полного круга (составленного из 8 сегментов кривой Безье)
// получается полная фигня - заливается набор из 8 треугольников по кругу
// похоже это ошибка Windows, поскольку вставка FlattenPath не помогает.
// На потом: проанализировать результаты N_GetPathCoords в этом случае и понять в чем дело
// Тестировать можно на кружке начальной точки выносной линии в карте RusFOM
//
//      SetBrushAttribs( $FF );
//      SetPenAttribs( 0, 0.05 );
//      N_i := N_GetPathCoords( HMDC, N_IPA, N_BA );
//      FlattenPath( HMDC );
//      N_i1 := N_GetPathCoords( HMDC, N_IPA1, N_BA1 );
//      StrokePath( HMDC );
//      FillPath( HMDC );
//      StrokePath( HMDC );
    end;
  end; // else // ABrushColor <> N_EmptyColor
end; //*** end of procedure TN_OCanvas.DrawCurPath

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserFPoly(Float_1)
//*************************************** TN_OCanvas.DrawUserFPoly(Float#1) ***
// Draw PolyLine or PolyGon in User coordinates by current draw attributes
//
//     Parameters
// AEnvRect - envelope float rectangle in user coordinates
// APPoints - ponter to points array start element (float points in User 
//            coordinates)
// ANPoints - number of points array actual elements
//
procedure TN_OCanvas.DrawUserFPoly( AEnvRect: TFRect; APPoints: PFPoint;
                                                            ANPoints: integer );
var
  j, EnvRectPos, NLines, NP2: integer;
begin
  EnvRectPos := N_EnvRectPos( AEnvRect, MaxUClipRect );
  case EnvRectPos of

  0: begin //***** whole EnvRect is visible, clipping is not needed
    if Length(WrkCILine) < ANPoints then
    begin
      WrkCILine := nil;
      SetLength( WrkCILine, N_NewLength(ANPoints) );
    end;

N_T2.Start(11);
    ANPoints := N_ConvFLineToILine2( U2P, ANPoints, APPoints, @WrkCILine[0] );
N_T2.Stop(11);
N_T2.Start(12);
    if ConWinPolyline then
      Windows.Polyline( HMDC, (@WrkCILine[0])^, ANPoints )
    else
      Windows.Polygon( HMDC, (@WrkCILine[0])^, ANPoints );
N_T2.Stop(12);
    if CollectInvRects then
      N_AddLineRect( WrkCILine, ANPoints, InvRects, NumInvRects, ConPenPixWidth );
  end; // 0: begin // whole EnvRect is visible, clipping is not needed

  1: begin //************************* clipping is needed
N_T2.Start(10);
    if ConClipPolyLine then
      NLines := N_ClipLineByRect( MaxUClipRect, APPoints,
                                  ANPoints, WrkOutLengths, WrkOutFLines )
    else
      NLines := N_ClipRingByRect( MaxUClipRect, 0, APPoints,
                                  ANPoints, WrkOutLengths, WrkOutFLines );
N_T2.Stop(10);
    for j := 0 to NLines-1 do
    begin
      ANPoints := WrkOutLengths[j];
      if Length(WrkCILine) < ANPoints then
      begin
        WrkCILine := nil;
        SetLength( WrkCILine, N_NewLength(ANPoints) );
      end;

N_T2.Start(11);
      NP2 := N_ConvFLineToILine2( U2P, ANPoints, @WrkOutFLines[j][0],
                                                                @WrkCILine[0] );
N_T2.Stop(11);
N_T2.Start(12);
    if ConWinPolyline then
      Windows.Polyline( HMDC, (@WrkCILine[0])^, NP2 )
    else
      Windows.Polygon( HMDC, (@WrkCILine[0])^, NP2 );
N_T2.Stop(12);
      if CollectInvRects then
        N_AddLineRect( WrkCILine, NP2, InvRects, NumInvRects, ConPenPixWidth );
    end; // for j := 0 to NLines-1 do
  end; // 1: begin // clipping is needed

  end; // case EnvRectPos of
end; //*** end of procedure TN_OCanvas.DrawUserFPoly(Float#1)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserFPoly(Float_2)
//*************************************** TN_OCanvas.DrawUserFPoly(Float#2) ***
// Draw PolyLine or PolyGon in User coordinates by given draw attributes
//
//     Parameters
// APPoints  - ponter to points array start element (float points in User 
//             coordinates)
// ANPoints  - number of points array actual elements
// APAttribs - pointers to draw attributes data structure
//
procedure TN_OCanvas.DrawUserFPoly( APPoints: PFPoint; ANPoints: integer;
                                            APAttribs: TN_PNormLineAttr );
var
  AEnvRect: TFRect;
begin
  with APAttribs^ do
    SetPenAttribs( Color, Size );
  AEnvRect := N_CalcFLineEnvRect( APPoints, ANPoints );
  DrawUserFPoly( AEnvRect, APPoints, ANPoints );
end; // procedure TN_OCanvas.DrawUserFPoly(Float#2)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserDPoly(Double_1)
//************************************** TN_OCanvas.DrawUserDPoly(Double#1) ***
// Draw PolyLine or PolyGon in User coordinates by given draw attributes
//
//     Parameters
// AEnvRect - envelope float rectangle in user coordinates
// APPoints - ponter to points array start element (double points in User 
//            coordinates)
// ANPoints - number of points array actual elements
//
procedure TN_OCanvas.DrawUserDPoly( AEnvRect: TFRect; APPoints: PDPoint;
                                                            ANPoints: integer );
var
  j, EnvRectPos, NLines, NP2: integer;
begin
  EnvRectPos := N_EnvRectPos( AEnvRect, MaxUClipRect );
  case EnvRectPos of

  0: begin // whole EnvRect is visible, clipping is not needed
    if Length(WrkCILine) < ANPoints then
    begin
      WrkCILine := nil;
      SetLength( WrkCILine, N_NewLength(ANPoints) );
    end;

N_T2.Start(11);
    ANPoints := N_ConvDLineToILine2( U2P, ANPoints, APPoints, @WrkCILine[0] );
N_T2.Stop(11);
N_T2.Start(12);
    if ConWinPolyline then
      Windows.Polyline( HMDC, (@WrkCILine[0])^, ANPoints )
    else
      Windows.Polygon( HMDC, (@WrkCILine[0])^, ANPoints );
N_T2.Stop(12);
    if CollectInvRects then
      N_AddLineRect( WrkCILine, ANPoints, InvRects, NumInvRects, ConPenPixWidth );
  end; // 0: begin // whole EnvRect is visible, clipping is not needed

  1: begin // clipping is needed
N_T2.Start(10);
    if ConClipPolyLine then
      NLines := N_ClipLineByRect( MaxUClipRect, APPoints,
                                  ANPoints, WrkOutLengths, WrkOutDLines )
    else
      NLines := N_ClipRingByRect( MaxUClipRect, 0, APPoints,
                                  ANPoints, WrkOutLengths, WrkOutDLines );
N_T2.Stop(10);
    for j := 0 to NLines-1 do
    begin
      ANPoints := WrkOutLengths[j];
      if Length(WrkCILine) < ANPoints then
      begin
        WrkCILine := nil;
        SetLength( WrkCILine, N_NewLength(ANPoints) );
      end;

N_T2.Start(11);
      NP2 := N_ConvDLineToILine2( U2P, ANPoints, @WrkOutDLines[j][0],
                                                                @WrkCILine[0] );
N_T2.Stop(11);
N_T2.Start(12);
    if ConWinPolyline then
      Windows.Polyline( HMDC, (@WrkCILine[0])^, NP2 )
    else
      Windows.Polygon( HMDC, (@WrkCILine[0])^, NP2 );
N_T2.Stop(12);
      if CollectInvRects then
        N_AddLineRect( WrkCILine, NP2, InvRects, NumInvRects, ConPenPixWidth );
    end; // for j := 0 to NLines-1 do
  end; // 1: begin // clipping is needed

  end; // case EnvRectPos of
end; //*** end of procedure TN_OCanvas.DrawUserDPoly(Double#1)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserDPoly(Double_3)
//************************************** TN_OCanvas.DrawUserDPoly(Double#3) ***
// Draw PolyLine or PolyGon in User coordinates by current draw attributes
//
//     Parameters
// APEnvRect - pointer to envelope float rectangle in user coordinates
// APPoints  - ponter to points array start element (double points in User 
//             coordinates)
// ANPoints  - number of points array actual elements
//
// Drawing is done according to ConClipPolyline, ConWinPolyline and 
// ConRingDirection
//
// If APEnvRect =nil then MaxUClipRect is used for polyline clipping. APEnvRect 
// =1 value is coordinates clipping is not needed flag.
//
procedure TN_OCanvas.DrawUserDPoly( APEnvRect: PFRect; APPoints: PDPoint;
                                                            ANPoints: integer );
var
  j, EnvRectPos, NLines, NP2: integer;
  Label SkipClipping, ClipCoords;
begin
  case integer(APEnvRect) of
  0: goto ClipCoords;   // PEnvRect = nil (not given)
  1: goto SkipClipping; // "EnvRect is inside MaxUClipRect" flag
  end;
  if APEnvRect^.Left = N_NotAFloat then goto ClipCoords;

  //***** Here: real EnvRect is given, check it

  EnvRectPos := N_EnvRectPos( APEnvRect^, MaxUClipRect );
  if EnvRectPos = 1 then goto ClipCoords; // partially visible

  SkipClipping: //***** whole EnvRect is visible, clipping is not needed

  if Length(WrkCILine) < ANPoints then
  begin
    WrkCILine := nil;
    SetLength( WrkCILine, N_NewLength(ANPoints) );
  end;

  {$IFDEF CheckTime} N_T2.Start(11); {$ENDIF}
  ANPoints := N_ConvDLineToILine2( U2P, ANPoints, APPoints, @WrkCILine[0] );
  {$IFDEF CheckTime} N_T2.Stop(11); N_T2.Start(12); {$ENDIF}

  if ConWinPolyline then
    Windows.Polyline( HMDC, (@WrkCILine[0])^, ANPoints )
  else
    Windows.Polygon( HMDC, (@WrkCILine[0])^, ANPoints );
  {$IFDEF CheckTime} N_T2.Stop(12); {$ENDIF}

  if CollectInvRects then
    N_AddLineRect( WrkCILine, ANPoints, InvRects, NumInvRects, ConPenPixWidth );
  Exit;

  ClipCoords: //******************************** clipping is needed

  {$IFDEF CheckTime} N_T2.Start(10); {$ENDIF}
  if ConClipPolyLine then
    NLines := N_ClipLineByRect( MaxUClipRect, APPoints,
                                ANPoints, WrkOutLengths, WrkOutDLines )
  else
    NLines := N_ClipRingByRect( MaxUClipRect, ConRingDirection, APPoints,
                                ANPoints, WrkOutLengths, WrkOutDLines );
  {$IFDEF CheckTime} N_T2.Stop(10); {$ENDIF}

  for j := 0 to NLines-1 do
  begin
    ANPoints := WrkOutLengths[j];
    if Length(WrkCILine) < ANPoints then
    begin
      WrkCILine := nil;
      SetLength( WrkCILine, N_NewLength(ANPoints) );
    end;

    {$IFDEF CheckTime} N_T2.Start(11); {$ENDIF}
    NP2 := N_ConvDLineToILine2( U2P, ANPoints, @WrkOutDLines[j][0],
                                                              @WrkCILine[0] );
    {$IFDEF CheckTime} N_T2.Stop(11); N_T2.Start(12); {$ENDIF}

    if ConWinPolyline then
      Windows.Polyline( HMDC, (@WrkCILine[0])^, NP2 )
    else
      Windows.Polygon( HMDC, (@WrkCILine[0])^, NP2 );
    {$IFDEF CheckTime} N_T2.Stop(12); {$ENDIF}

    if CollectInvRects then
      N_AddLineRect( WrkCILine, NP2, InvRects, NumInvRects, ConPenPixWidth );
  end; // for j := 0 to NLines-1 do

end; //*** end of procedure TN_OCanvas.DrawUserDPoly(Double#3)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserFPoly(Float_3)
//*************************************** TN_OCanvas.DrawUserFPoly(Float#3) ***
// Draw PolyLine or PolyGon in User coordinates by current draw attributes
//
//     Parameters
// APEnvRect - pointer to envelope float rectangle in user coordinates
// APPoints  - ponter to points array start element (float points in User 
//             coordinates)
// ANPoints  - number of points array actual elements
//
// Drawing is done according to ConClipPolyline, ConWinPolyline and 
// ConRingDirection
//
// If APEnvRect =nil then MaxUClipRect is used for polyline clipping. APEnvRect 
// =1 value is coordinates clipping is not needed flag.
//
procedure TN_OCanvas.DrawUserFPoly( APEnvRect: PFRect; APPoints: PFPoint;
                                                            ANPoints: integer );
var
  j, EnvRectPos, NLines, NP2: integer;
  Label SkipClipping, ClipCoords;
begin
  case integer(APEnvRect) of
  0: goto ClipCoords;   // PEnvRect = nil (not given)
  1: goto SkipClipping; // "EnvRect is inside MaxUClipRect" flag
  end;
  if APEnvRect^.Left = N_NotAFloat then goto ClipCoords;

  //***** Here: real EnvRect is given, check it

  EnvRectPos := N_EnvRectPos( APEnvRect^, MaxUClipRect );
  if EnvRectPos = 1 then goto ClipCoords; // partially visible

  SkipClipping: //***** whole EnvRect is visible, clipping is not needed

  if Length(WrkCILine) < ANPoints then
  begin
    WrkCILine := nil;
    SetLength( WrkCILine, N_NewLength(ANPoints) );
  end;

  {$IFDEF CheckTime} N_T2.Start(11); {$ENDIF}
  ANPoints := N_ConvFLineToILine2( U2P, ANPoints, APPoints, @WrkCILine[0] );
  {$IFDEF CheckTime} N_T2.Stop(11); N_T2.Start(12); {$ENDIF}

  if ConWinPolyline then
    Windows.Polyline( HMDC, (@WrkCILine[0])^, ANPoints )
  else
    Windows.Polygon( HMDC, (@WrkCILine[0])^, ANPoints );
  {$IFDEF CheckTime} N_T2.Stop(12); {$ENDIF}

  if CollectInvRects then
    N_AddLineRect( WrkCILine, ANPoints, InvRects, NumInvRects, ConPenPixWidth );
  Exit;

  ClipCoords: //******************************** clipping is needed

  {$IFDEF CheckTime} N_T2.Start(10); {$ENDIF}
  if ConClipPolyLine then
    NLines := N_ClipLineByRect( MaxUClipRect, APPoints,
                                ANPoints, WrkOutLengths, WrkOutFLines )
  else
    NLines := N_ClipRingByRect( MaxUClipRect, ConRingDirection, APPoints,
                                ANPoints, WrkOutLengths, WrkOutFLines );
  {$IFDEF CheckTime} N_T2.Stop(10); {$ENDIF}

  for j := 0 to NLines-1 do
  begin
    ANPoints := WrkOutLengths[j];
    if Length(WrkCILine) < ANPoints then
    begin
      WrkCILine := nil;
      SetLength( WrkCILine, N_NewLength(ANPoints) );
    end;

    {$IFDEF CheckTime} N_T2.Start(11); {$ENDIF}
    NP2 := N_ConvFLineToILine2( U2P, ANPoints, @WrkOutFLines[j][0],
                                                              @WrkCILine[0] );
    {$IFDEF CheckTime} N_T2.Stop(11); N_T2.Start(12); {$ENDIF}

    if ConWinPolyline then
      Windows.Polyline( HMDC, (@WrkCILine[0])^, NP2 )
    else
      Windows.Polygon( HMDC, (@WrkCILine[0])^, NP2 );
    {$IFDEF CheckTime} N_T2.Stop(12); {$ENDIF}

    if CollectInvRects then
      N_AddLineRect( WrkCILine, NP2, InvRects, NumInvRects, ConPenPixWidth );
  end; // for j := 0 to NLines-1 do

end; //*** end of procedure TN_OCanvas.DrawUserFPoly(Float#3)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserDPoly(Double_2)
//************************************** TN_OCanvas.DrawUserDPoly(Double#2) ***
// Draw PolyLine or PolyGon in User coordinates by given draw attributes
//
//     Parameters
// APPoints  - ponter to points array start element (double points in User 
//             coordinates)
// ANPoints  - number of points array actual elements
// APAttribs - pointers to draw attributes data structure
//
procedure TN_OCanvas.DrawUserDPoly( APPoints: PDPoint; ANPoints: integer;
                                            APAttribs: TN_PNormLineAttr );
var
  AEnvRect: TFRect;
begin
  with APAttribs^ do
    SetPenAttribs( Color, Size );
  AEnvRect := N_CalcDLineEnvRect( APPoints, ANPoints );
  DrawUserDPoly( AEnvRect, APPoints, ANPoints );
end; // procedure TN_OCanvas.DrawUserDPoly(Double#2)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserPolyline1(Float)
//************************************* TN_OCanvas.DrawUserPolyline1(Float) ***
// Draw Polyline in User coordinates by current draw attributes
//
//     Parameters
// APoints - array of float points in User coordinates
//
procedure TN_OCanvas.DrawUserPolyline1( APoints: TN_FPArray );
var
  j, NPoints: integer;
  LineEnds: TN_LEPArray;
begin
  LineEnds := nil;
  N_ClipFline( MinUClipRect, LineEnds, APoints, WrkDLA2 );
  for j := 0 to High(WrkDLA2) do
  begin
    NPoints := Length( WrkDLA2[j] );
    if Npoints = 0 then Continue;
    if Length(WrkCILine) < NPoints then SetLength( WrkCILine, NPoints );
    N_ConvDlineToILine( U2P, NPoints, @WrkDLA2[j,0], @WrkCILine[0] );
//    NPoints := N_ConvDlineToILine2( U2P, NPoints, @WrkDLA2[j,0], @WrkCILine[0] );

//    if (not NativeWidePen) and (ConPenPixWidth > 1) then
//      DrawWidePolyline( WrkCILine, NPoints )
//    else
      DrawPixPolyline( WrkCILine, NPoints );

  end; // for j := 0 to High(ComDLA) do
end; //*** end of procedure TN_OCanvas.DrawUserPolyline1(Float)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserPolyline2(Float)
//************************************* TN_OCanvas.DrawUserPolyline2(Float) ***
// draw Polyline in User coords by given draw attributes
//
//     Parameters
// APoints   - array of float points in User coordinates
// APenColor - Pen color
// APenWidth - Pen width in LLW
//
procedure TN_OCanvas.DrawUserPolyline2( APoints: TN_FPArray;
                             const APenColor: integer; const APenWidth: float );
var
  j, NPoints: integer;
  LineEnds: TN_LEPArray;
begin
  if Length(APoints) <= 1 then Exit; // a precaution
  if APenColor = N_EmptyColor then Exit; // nothing todo
  LineEnds := nil;
  SetPenAttribs( APenColor, APenWidth );
  N_ClipFline( MinUClipRect, LineEnds, APoints, WrkDLA2 );
  for j := 0 to High(WrkDLA2) do
  begin
    NPoints := Length( WrkDLA2[j] );
    if Npoints = 0 then Continue;
    if Length(WrkCILine) < NPoints then  SetLength( WrkCILine, NPoints );
    N_ConvDlineToILine( U2P, NPoints, @WrkDLA2[j,0], @WrkCILine[0] );
//    if (not NativeWidePen) and (ConPenPixWidth > 1) then
//      DrawWidePolyline( WrkCILine, NPoints )
//    else
      DrawPixPolyline( WrkCILine, NPoints );
  end; // for j := 0 to High(ComDLA) do
end; //*** end of procedure TN_OCanvas.DrawUserPolyline2(Float)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserPolyline1(Double)
//************************************ TN_OCanvas.DrawUserPolyline1(Double) ***
// Draw Polyline in User coordinates by current draw attributes
//
//     Parameters
// APoints - array of double points in User coordinates
//
procedure TN_OCanvas.DrawUserPolyline1( APoints: TN_DPArray );
var
  j, NPoints: integer;
  LineEnds: TN_LEPArray;
begin
  LineEnds := nil;
  N_ClipDline( MinUClipRect, LineEnds, APoints, WrkDLA2 );
  for j := 0 to High(WrkDLA2) do
  begin
    NPoints := Length( WrkDLA2[j] );
    if Npoints = 0 then Continue;
    if Length(WrkCILine) < NPoints then SetLength( WrkCILine, NPoints );
    N_ConvDlineToILine( U2P, NPoints, @WrkDLA2[j,0], @WrkCILine[0] );
//    if (not NativeWidePen) and (ConPenPixWidth > 1) then
//      DrawWidePolyline( WrkCILine, NPoints )
//    else
      DrawPixPolyline( WrkCILine, NPoints );
  end; // for j := 0 to High(ComDLA) do
end; //*** end of procedure TN_OCanvas.DrawUserPolyline1(Double)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserPolyline2(Double)
//************************************ TN_OCanvas.DrawUserPolyline2(Double) ***
// draw Polyline in User coords by given draw attributes
//
//     Parameters
// APoints   - array of double points in User coordinates
// APenColor - Pen color
// APenWidth - Pen width in LLW
//
procedure TN_OCanvas.DrawUserPolyline2( APoints: TN_DPArray;
                         const APenColor: integer; const APenWidth: float );
var
  j, NPoints: integer;
  LineEnds: TN_LEPArray;
begin
  if APenColor = N_EmptyColor then Exit; // nothing todo
  LineEnds := nil;
  SetPenAttribs( APenColor, APenWidth );
  N_ClipDline( MinUClipRect, LineEnds, APoints, WrkDLA2 );
  for j := 0 to High(WrkDLA2) do
  begin
    NPoints := Length( WrkDLA2[j] );
    if Npoints = 0 then Continue;
    if Length(WrkCILine) < NPoints then  SetLength( WrkCILine, NPoints );
    N_ConvDlineToILine( U2P, NPoints, @WrkDLA2[j,0], @WrkCILine[0] );
//    if (not NativeWidePen) and (ConPenPixWidth > 1) then
//      DrawWidePolyline( WrkCILine, NPoints )
//    else
      DrawPixPolyline( WrkCILine, NPoints );
  end; // for j := 0 to High(ComDLA) do
end; //*** end of procedure TN_OCanvas.DrawUserPolyline2(Double)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserMatrPoints(Float)
//************************************ TN_OCanvas.DrawUserMatrPoints(Float) ***
// Draw rectangle mesh lines with given nodes float coordinates
//
//     Parameters
// APFPoint - pointer to float points array start element
// ANX      - matrix horizontal dimension size
// ANY      - matrix vertical dimension size
//
// Float points array should be matrix which elements are ordered by horizontal 
// dimension.
//
procedure TN_OCanvas.DrawUserMatrPoints( APFPoint: PFPoint; ANX, ANY: integer );
var
  ix, iy: integer;
  FPoints: TN_FPArray;
  PCur: PFPoint;
  PEnvRect: PFRect;
//  PTmpp: PChar;
begin
  PCur := APFPoint;
  integer(PEnvRect) := 1; // "Clipping is not needed" Flag

  for iy := 0 to ANY-1 do // Draw Horizontal lines
  begin
    DrawUserFPoly( PEnvRect, PCur, ANX );
    Inc( PCur, ANX );
  end; // for iy := 0 to ANY-1 do // Draw horizontal lines

  SetLength( FPoints, ANY );

  for ix := 0 to ANX-1 do // Draw Vertical lines
  begin
    PCur := APFPoint;
    Inc( PCur, ix );

    for iy := 0 to ANY-1 do // Fill FPoints by vertical line vertexes
    begin
      FPoints[iy] := PCur^;
      Inc( PCur, ANX );
    end; // for iy := 0 to ANY-1 do // Fill FPoints by vertical line vertexes

    DrawUserFPoly( PEnvRect, @FPoints[0], ANY );
  end; // for ix := 0 to ANY-1 do // Draw Vertical lines

end; //*** end of procedure TN_OCanvas.DrawUserMatrPoints(Float)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserSegment
//********************************************** TN_OCanvas.DrawUserSegment ***
// Draw Segment given by vetexes User coordinates using given line draw 
// attributes
//
//     Parameters
// AP1   - first vertex User coordinates
// AP2   - second vertex User coordinates
// AAttr - line draw attributes
//
procedure TN_OCanvas.DrawUserSegment( AP1, AP2: TDPoint; AAttr: TN_NormLineAttr );
begin
  ConSegm[0] := AP1;
  ConSegm[1] := AP2;
  DrawUserPolyline2( ConSegm, AAttr.Color, AAttr.Size );
end; //*** end of procedure TN_OCanvas.DrawUserSegment

{
//******************************************* TN_OCanvas.DrawUserSysPolyline ***
// draw Polyline in User coords showing it's vertexes using given Attribs:
//   (all sizes are in LLW)
// Attribs[0] - Line Color, Width
// Attribs[1] - Half of BegSegment Color, Width
// Attribs[2] - Vertex Color, Size
// Attribs[3] - BegVertex Color, Size

// IParams[0] - LineColor
// IParams[1] - LineWidth
// IParams[2] - VertexColor
// IParams[3] - VertexSize
// IParams[4] - BegVertexColor
// IParams[5] - BegVertexSize
// IParams[6] - BegSegmentColor
// IParams[7] - BegSegmentWidth
//
//  AtLASColor: integer; // Line All Segments Color
//  AtLASWidth: float;   // Line All Segments Width (in LLW)
//  AtLBSColor: integer; // Line Beg Segment (first half) Color
//  AtLBSWidth: float;   // Line Beg Segment (first half)Width (in LLW)
//  AtLAVColor: integer; // Line All Vertexes Color
//  AtLAVSize: float;    // Line All Vertexes Size (in LLW)
//  AtLBVColor: integer; // Line Beg Vertex Color
//  AtLBVSize: float;    // Line Beg Vertexes Size (in LLW)

procedure TN_OCanvas.DrawUserSysPolyline( PPoints: PDPoint;
                              NumPoints: integer; PAttribs: TN_PSysLineAttr );
var
  i: integer;
  BegSegm: TN_DPArray;
  AEnvRect: TFRect;
  PP: PDPoint;
begin
  with PAttribs^ do
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
      DrawUserPoint( PP^, AtLAV );
      Inc(PP);
    end; // for i := 1 to NumPoints do // draw all Vertexes
  end; // if AtLAV.PenColor <> N_EmptyColor then // draw all line vertexes

  if AtLBV.SPenColor <> N_EmptyColor then // draw Beg line vertex
  begin
    DrawUserPoint( PPoints^, AtLBV );
  end;

  if AtLASColor <> N_EmptyColor then // draw line with normal attributes
  begin

    SetPenAttribs( AtLASColor, AtLASWidth );
    AEnvRect := N_CalcDLineEnvRect( PPoints, NumPoints );
    DrawUserDPoly( AEnvRect, PPoints, NumPoints );

  end;

  end; // with PAttribs^ do

end; //*** end of procedure TN_OCanvas.DrawUserSysPolyline
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\PrepWidthVector
//********************************************** TN_OCanvas.PrepWidthVector ***
// Prepare Left and Right pixel coordinates of given wide segment first point
//
//     Parameters
// AP1      - segment first point pixel сoordinates
// AP2      - segment second point pixel сoordinates
// AWidth   - wide segment width in LLW
// AP1Left  - wide segment first point Left bound pixel coordinates
// AP1Right - wide segment first point Right bound pixel coordinates
//
procedure TN_OCanvas.PrepWidthVector( const AP1, AP2: TPoint; AWidth: float;
                                                 out AP1Left, AP1Right: TPoint );
var
  PixWidth: integer;
  DX, DY, Coef, P1P2Size: double;
begin
  DX := AP2.X-AP1.X;
  DY := AP2.Y-AP1.Y;
  PixWidth := Round( CurLLWPixSize * AWidth ); // needed width in pixels

  case PixWidth of

  0, 1: // one pixel wide
    begin
      AP1Left  := AP1;
      AP1Right := AP1;
    end;

  2: begin // two pixels wide
    if Abs(DX) > Abs(DY) then // low slope segment
    begin
      AP1Left.X  := AP1.X;
      AP1Left.Y  := AP1.Y - 1;
      AP1Right.X := AP1.X;
      AP1Right.Y := AP1.Y;
    end else //**************** high slope segment
    begin
      AP1Left.X  := AP1.X - 1;
      AP1Left.Y  := AP1.Y;
      AP1Right.X := AP1.X;
      AP1Right.Y := AP1.Y;
    end;
  end; // two pixels wide

  3: begin // three pixels wide
    if Abs(DX) > Abs(DY) then // low slope segment
    begin
      AP1Left.X  := AP1.X;
      AP1Left.Y  := AP1.Y - 1;
      AP1Right.X := AP1.X;
      AP1Right.Y := AP1.Y + 1;
    end else //**************** high slope segment
    begin
      AP1Left.X  := AP1.X - 1;
      AP1Left.Y  := AP1.Y;
      AP1Right.X := AP1.X + 1;
      AP1Right.Y := AP1.Y;
    end;
  end; // three pixels wide

  else begin
    P1P2Size := Sqrt( DX*DX + DY*DY );
    if P1P2Size = 0 then
    begin
      AP1Left  := AP1;
      AP1Right := AP1;
    end else
    begin
      Coef := (CurLLWPixSize * AWidth - 1) / P1P2Size;
     // (DY,-DX) vector is (P1->P2) vector, rotated counterclockwise by 90 degree

      AP1Left.X := AP1.X + Round(  DY*0.5001*Coef ); // 0.501 and 0.5000001 causes rounding errors!
      AP1Left.Y := AP1.Y + Round( -DX*0.5001*Coef );

      AP1Right.X := AP1Left.X - Round(  DY*Coef );
      AP1Right.Y := AP1Left.Y - Round( -DX*Coef );

      //***** Center rezulting Width Vector relative to P1
      //      (correct possible rounding errors)

      // now not imlemented

    end;
  end; // PixWidth >= ?

  end; // case PixWidth of
end; //*** end of procedure TN_OCanvas.PrepWidthVector

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\PrepWideSegm
//************************************************* TN_OCanvas.PrepWideSegm ***
// Prepare pixel coordinates needed for drawing Wide Segment as closed Polygon
//
//     Parameters
// AP1         - segment first point pixel сoordinates
// AP2         - segment second point pixel сoordinates
// ASegmWidth  - wide segment width in LLW
// APixPolygon - calculated pixel coordinates of Wide Segment Polygon (array of 
//               integer points) ( clockwise in LEFT (Pixel) coords )
//#F
//                                                   ************(1)
//                                (0,4)**************************<-P2
//                                 P1->**************************(2)
//                                  (3)**************
//#/F
//
procedure TN_OCanvas.PrepWideSegm( const AP1, AP2: TPoint; const ASegmWidth: float;
                                                  var APixPolygon: TN_IPArray  );
begin
  if Length(APixPolygon) < 5 then SetLength( APixPolygon, 5 );
  PrepWidthVector( AP1, AP2, ASegmWidth, APixPolygon[0], APixPolygon[3] );

  APixPolygon[1].X := APixPolygon[0].X + AP2.X - AP1.X;
  APixPolygon[1].Y := APixPolygon[0].Y + AP2.Y - AP1.Y;

  APixPolygon[2].X := APixPolygon[3].X + AP2.X - AP1.X;
  APixPolygon[2].Y := APixPolygon[3].Y + AP2.Y - AP1.Y;

  APixPolygon[4] := APixPolygon[0];
end; //*** end of procedure TN_OCanvas.PrepWideSegm

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\PrepWideVertex
//*********************************************** TN_OCanvas.PrepWideVertex ***
// Prepare pixel coordinates needed for drawing Wide Vertex as closed Polygon
//
//     Parameters
// AMaxSize    - Max Vertex Size in LLW
// AAngleStyle - not used now
// APixPolygon - on input:
//#F
//     [0] - segment1 rectangle corner
//     [1] - segment1 and segment2 crosspoint
//     [2] - segment2 rectangle corner
//     [3] - segment1 rectangle another corner (3->0 is parallel to segment1)
//     [4] - segment2 rectangle another corner (4->2 is parallel to segment2)
//
//              on output - calculated pixel coordinatess of Wide Vertex Polygon:
//     [0-2]   - same as on input
//     [3]     - same as [0] if MaxSize=0 (WideVertex is triangle)
//     [3,4]   - if MaxSize is big enough
//     [3,4,5] - if MaxSize is small enough
//#/F
// Result      - Returns number of points in resulting polygon
//
// Wide Vertex is figure that should be draw between two neighbour Wide 
// Segments.
//
function TN_OCanvas.PrepWideVertex( const AMaxSize: float; AAngleStyle: integer;
                                    var APixPolygon: TN_IPArray ): integer;
begin
//!! not implemented!
  APixPolygon[3] := APixPolygon[0]; // temporary
  Result := 4;
end; //*** end of function TN_OCanvas.PrepWideVertex

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixStraightArrow
//***************************************** TN_OCanvas.DrawPixStraightArrow ***
// Draw Straight Arrow as Polygon around segment in pixel coordinates using 
// current Pen and Brush attributes
//
//     Parameters
// AP1    - Arrow start point pixel coordinates
// AP2    - Arrow final point pixel coordinates
// AFlags - Arrow start point shape flags
// AL1    - internal Arrow length in LLW ( AP1, (AP2-AL1) ) Arrow straight 
//          segment length
// AL2    - full Arrow final point shape length in LLW
// AW1    - Arrow straight segment width in LLW
// AW2    - full Arrow width in LLW (AW1 < AW2)
//
// Arrow points from AP1 to AP2.
//
procedure TN_OCanvas.DrawPixStraightArrow( const AP1, AP2: TPoint; AFlags: integer;
                                                        AL1, AL2, AW1, AW2: float );
var
  DX1, DY1: integer;
  DX, DY, Coef, P1P2Size: double;
  P2a: TPoint;
  PixPolygon: TN_IPArray;
begin
  SetLength( PixPolygon, 8 );
  DX := AP2.X-AP1.X;
  DY := AP2.Y-AP1.Y;
  P1P2Size := Sqrt( DX*DX + DY*DY );
  if P1P2Size = 0 then Exit;

  PrepWidthVector( AP1, AP2, AW1, PixPolygon[0], PixPolygon[6] );
  PixPolygon[7] := PixPolygon[0];

  Coef := (P1P2Size - LLWToPix( AL1 )) / P1P2Size;
  DX1 := Round(DX*Coef);
  DY1 := Round(DY*Coef);
  PixPolygon[1].X := PixPolygon[0].X + DX1;
  PixPolygon[1].Y := PixPolygon[0].Y + DY1;
  PixPolygon[5].X := PixPolygon[6].X + DX1;
  PixPolygon[5].Y := PixPolygon[6].Y + DY1;

  Coef := (P1P2Size - LLWToPix( AL2 )) / P1P2Size;
  P2a.X := AP1.X + Round(DX*Coef);
  P2a.Y := AP1.Y + Round(DY*Coef);
  PrepWidthVector( P2a, AP1, AW2, PixPolygon[4], PixPolygon[2] );

  PixPolygon[3] := AP2;
  DrawPixPolygon( PixPolygon, 8 );

  if (AFlags and $0F) = 1 then // draw circle with P1 as center (Arrow begpoint)
  begin
    PrepWidthVector( AP1, Point( AP1.X+1, AP1.Y ), AW1, PixPolygon[0], PixPolygon[1] );
    PrepWidthVector( AP1, Point( AP1.X, AP1.Y+1 ), AW1, PixPolygon[2], PixPolygon[3] );
    DrawPixEllipse( Rect( PixPolygon[2].X, PixPolygon[0].Y,
                          PixPolygon[3].X, PixPolygon[1].Y ) );
  end;
end; //*** end of procedure TN_OCanvas.DrawPixStraightArrow

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserStraightArrow
//**************************************** TN_OCanvas.DrawUserStraightArrow ***
// Draw Straight Arrow as Polygon around segment in User coordinates using 
// current Pen and Brush attributes
//
//     Parameters
// AP1    - Arrow start point User coordinates
// AP2    - Arrow final point User coordinates
// AFlags - Arrow start point shape flags
// AL1    - internal Arrow length in LLW ( AP1, (AP2-AL1) ) Arrow straight 
//          segment length
// AL2    - full Arrow final point shape length in LLW
// AW1    - Arrow straight segment width in LLW
// AW2    - full Arrow width in LLW (AW1 < AW2)
//
// Arrow points from AP1 to AP2.
//
procedure TN_OCanvas.DrawUserStraightArrow( const AP1, AP2: TDPoint; AFlags: integer;
                                                        AL1, AL2, AW1, AW2: float );
begin
  DrawPixStraightArrow( N_AffConvD2IPoint( AP1, U2P ),
                       N_AffConvD2IPoint( AP2, U2P ),
                                        AFlags, AL1, AL2, AW1, AW2 );
end; //*** end of procedure TN_OCanvas.DrawUserStraightArrow

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawWidePolyline
//********************************************* TN_OCanvas.DrawWidePolyline ***
// Draw wide Polyline given by it's vertexes pixel coordinates using current Pen
// attributes
//
//     Parameters
// APoints    - Polyline vertexes pixel coordinates as integer points array
// ANumPoints - number of actual elements in Polyline vertexes pixel coordinates
//              array
//
// Current Pen attributes are in ConPenColor, ConPenPixWidth, ConMaxSize and 
// ConAngleStyle fields
//#F
// ConAngleStyle:
//    bits0-3  - beg of polyline style
//    bits4-7  - intermediate polyline Vertexes style
//    bits8-11 - end of polyline style
//
// One Vertex style (beg, intermedite or end):
//    =0 - shortest possible rect
//    =1 - draw circle
//    =2 - enlarged by HalfWidth  rect
//    =3 - use MaxSize
//#/F
//
procedure TN_OCanvas.DrawWidePolyline( APoints: TN_IPArray; const ANumPoints: integer );
var
  i, CircRad, NVertPoints: integer;
  CircleRect: TRect;
  SegmPolygon, VertPolygon: TN_IPArray;
  SavedBrushColor: integer;
  RestoreBrushColor: boolean;

  procedure DrawEndCircle( Center: TPoint ); // local
  // draw circle at segment's endpoints
  begin
    CircleRect := Rect( Center.X-CircRad, Center.Y-CircRad,
                        Center.X+CircRad, Center.Y+CircRad );
    DrawPixEllipse( CircleRect );
  end; // procedure DrawEndCircle( Center: TPoint ); // local

begin //*************************************** DrawWidePolyline main body
  CircRad := Round( 0.5*(ConPenLLWWidth-1) );
  SetLength( SegmPolygon, 5 );
  SetLength( VertPolygon, 6 );

  RestoreBrushColor := False;
  SavedBrushColor := ConBrushColor;

  if ConPenColor <> ConBrushColor then
  begin
    SetBrushAttribs( ConPenColor );
//    SetBrushAttribs( $FFFFFF ); // temporary, for debug only
    RestoreBrushColor := True;
  end;

  if ANumPoints = 2 then // draw one segment
  begin
    PrepWideSegm( APoints[0], APoints[1], ConPenLLWWidth, SegmPolygon );
    DrawPixPolygon( SegmPolygon, 5 );
    if (ConAngleStyle and $0F) = 1 then DrawEndCircle( APoints[0] );
    if ((ConAngleStyle shr 8) and $0F) = 1 then DrawEndCircle( APoints[1] );

  end else // two or more segments
  begin
    PrepWideSegm( APoints[0], APoints[1], ConPenLLWWidth, SegmPolygon );
    DrawPixPolygon( SegmPolygon, 5 ); // first Polyline segment
    if (ConAngleStyle and $0F) = 1 then DrawEndCircle( APoints[0] );

    VertPolygon[0] := SegmPolygon[2];
    VertPolygon[3] := SegmPolygon[3];

    for i := 1 to ANumPoints-3 do // loop along intermediate Polyline segments
    begin
      PrepWideSegm( APoints[i], APoints[i+1], ConPenLLWWidth, SegmPolygon );
      DrawPixPolygon( SegmPolygon, 5 ); // intermediate Polyline segment
      if ((ConAngleStyle shr 4) and $0F) = 1 then DrawEndCircle( APoints[i] );

      VertPolygon[1] := APoints[i];
      VertPolygon[2] := SegmPolygon[3];
      VertPolygon[4] := SegmPolygon[2];

      if ((ConAngleStyle shr 4) and $0F) = 3 then // draw WideVertexAngle
      begin
        NVertPoints := PrepWideVertex( ConMaxSize,
                             ((ConAngleStyle shr 4) and $0F), VertPolygon );
        DrawPixPolygon( VertPolygon, NVertPoints ); // intersegments angle
      end;

      VertPolygon[0] := SegmPolygon[2]; // for next intersegments angle
      VertPolygon[3] := SegmPolygon[3];
    end; // for i := 1 to NumPoints-3 do

    PrepWideSegm( APoints[ANumPoints-2], APoints[ANumPoints-1],
                                                 ConPenLLWWidth, SegmPolygon );
    DrawPixPolygon( SegmPolygon, 5 ); // last Polyline segment
    if ((ConAngleStyle shr 4) and $0F) = 1 then DrawEndCircle( APoints[ANumPoints-2] );
    if ((ConAngleStyle shr 8) and $0F) = 1 then DrawEndCircle( APoints[ANumPoints-1] );

    VertPolygon[1] := APoints[ANumPoints-2];
    VertPolygon[2] := SegmPolygon[3];
    VertPolygon[4] := SegmPolygon[2];

    if ((ConAngleStyle shr 4) and $0F) = 3 then // draw WideVertexAngle
    begin
      NVertPoints := PrepWideVertex( ConMaxSize,
                             ((ConAngleStyle shr 4) and $0F), VertPolygon );
      DrawPixPolygon( VertPolygon, NVertPoints ); // intersegments angle
    end;
  end; // else // two or more segments

  if RestoreBrushColor then SetBrushAttribs( SavedBrushColor );
  SegmPolygon := nil;
  VertPolygon := nil;

  if CollectInvRects then
  begin
    N_AddLineRect( APoints, ANumPoints, InvRects, NumInvRects, ConPenPixWidth );
  end;
end; //*** end of procedure TN_OCanvas.DrawWidePolyline

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawDashedPolyline
//******************************************* TN_OCanvas.DrawDashedPolyline ***
// Draw dashed Polyline given by it's vertexes User coordinates using given 
// array of Dash Attributes
//
//     Parameters
// APoints      - Polyline vertexes User coordinates as double points array
// ADashAttribs - dash attributes array ()
// ALoopInd     - index in ADashAttribs array, that should be used after last 
//                one
//
procedure TN_OCanvas.DrawDashedPolyline( APoints: TN_DPArray;
                     const ADashAttribs: TN_DashAttribs; ALoopInd: integer = 0 );
var
  i, Ibeg, Iend, DAInd, NPoints, NOCF, SavedConAngleStyle: integer;
  DX, DY, DS, DSbeg, DSend: double;
  OneColorFragm: TN_DPArray;
  SegmSizes: TN_DArray;

  function GetCoord( Ind: integer; DS: double ): TDPoint; // local
  // get coords of point in Ind segment of Points, with DS shift from beg of segment
  var
    Coef: double;
  begin
    if SegmSizes[Ind] = 0 then
      Result := APoints[Ind] // Points[Ind] is same as Points[Ind+1]
    else
    begin
      Coef := DS / SegmSizes[Ind];
      Result.X := APoints[Ind].X + (APoints[Ind+1].X - APoints[Ind].X) * Coef;
      Result.Y := APoints[Ind].Y + (APoints[Ind+1].Y - APoints[Ind].Y) * Coef;
    end;
  end; // end of local function GetCoord
begin
  NPoints := Length( APoints );
  if NPoints <= 1 then Exit; // a precaution
  SetLength( OneColorFragm, NPoints );
  SetLength( SegmSizes, NPoints-1 );
  SavedConAngleStyle := ConAngleStyle;

  for i := 0 to NPoints-2 do
  begin
    DX := APoints[i+1].X - APoints[i].X;
    DY := APoints[i+1].Y - APoints[i].Y;
    SegmSizes[i] := Sqrt( DX*DX + DY*DY );
  end; // for i := 0 to NPoints-1 do

  Ibeg := 0; // index of beg segment (first segment for current Dash)
  Iend := 0; // index of end segment (last segment for current Dash)
  DSbeg := 0.0; // Beg of Dash shift in Ibeg segment
  DSend := 0.0; // End of Dash shift in Iend segment
  DAInd := 0; // Dash Attr index

  while True do // loop along polyline
  begin
    DS := LSUToUserX( ADashAttribs[DAInd].DashSize );
    if ((DSend+DS) <= SegmSizes[Iend]) or // Dash Endpoint in Cur segment OR
       (Iend = (NPoints-2)) then          // last Polyline segment
    begin // end of cur. Dash in Iend segment, draw it and go to next Dash
      if DSend + DS > SegmSizes[Iend] then
        DSend := SegmSizes[Iend] // if last segment
      else
        DSend := DSend + DS;

      NOCF := Iend - Ibeg + 2; // Number of points in One Color Fragment
      SetLength( OneColorFragm, NOCF );
      if Iend > Ibeg then OneColorFragm := Copy( APoints, Ibeg, NOCF );
      OneColorFragm[0] := GetCoord( Ibeg, DSbeg );
      OneColorFragm[NOCF-1] := GetCoord( Iend, DSend );

      ConAngleStyle := ADashAttribs[DAInd].DashAngleStyle;
      DrawUserPolyline2( OneColorFragm, ADashAttribs[DAInd].DashColor,
                                            ADashAttribs[DAInd].DashWidth );

      if (DSend = SegmSizes[Iend]) and (Iend = (NPoints-2)) then Break;

      Ibeg := Iend;
      DSbeg := DSend;
      Inc( DAInd ); // to next Dash
      if DAInd > High(ADashAttribs) then DAInd := ALoopInd;
    end else // Dash not finished, go to next segment
    begin
      DSend := 0;
      Inc( Iend );
     end;
  end; // while True do // loop along polyline

  ConAngleStyle := SavedConAngleStyle;
  OneColorFragm := nil;
  SegmSizes := nil;
end; //*** end of procedure TN_OCanvas.DrawDashedPolyline

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserMonoRing
//********************************************* TN_OCanvas.DrawUserMonoRing ***
// Fill Ring interior given by vertexes user coordinates in MonoBitMap (by 0 or 
// by 1)
//
//     Parameters
// ARCoords       - Ring vertexes user coordinates as double points array
// AREnvRect      - Ring envelope rectangle
// ARingDirection - Ring direction (should be calculated by N_CalcRingDirection 
//                  function)
// AFillColor     - how to fill ring's interior pixels:
//#F
//     =0 - fill by 1 (for even level rings),
//     =1 - fill by 0 (for odd level rings)
//#/F
//
// Ring is closed Polyline (simply connected contour).
//
procedure TN_OCanvas.DrawUserMonoRing( ARCoords: TN_DPArray;
                    const AREnvRect: TFRect; ARingDirection, AFillColor: integer );
var
  i, NPoints: integer;
  EnvRect: TFRect;
begin
  EnvRect := AREnvRect;
  if EnvRect.Left = N_NotAFloat then
    EnvRect := N_CalcLineEnvRect( ARCoords, 0, Length(ARCoords) );

  N_ClipRing( MinUClipRect, ARingDirection, ARCoords, EnvRect, WrkDLA2 );

  for i := 0 to High(WrkDLA2) do
  begin
    NPoints := Length( WrkDLA2[i] );
    if Npoints = 0 then Continue;
    if Length(WrkCILine) < NPoints then SetLength( WrkCILine, NPoints );
    N_ConvDlineToILine( U2PRing, NPoints, @WrkDLA2[i,0], @WrkCILine[0] );
{
    case GDIType of
    WinGDI: begin //***** use Windows GDI functions
      if FillColor <> 0 then GDIFillMode := R2_Black
                        else GDIFillMode := R2_White;
      SetROP2( MonoBitMap.Canvas.Handle, GDIFillMode );
      Polygon( MonoBitMap.Canvas.Handle, (@WrkCILine[0])^, NPoints );
    end; // use Windows GDI functions

    DelphiGDI: begin //***** use Delphi GDI functions
      SetLength( WrkCILine, NPoints );
//      MonoBitMap.Canvas.Pen.Width := 1;
//      MonoBitMap.Canvas.Pen.Style := psInsideFrame;
      if FillColor <> 0 then
      begin
//       MonoBitMap.Canvas.Pen.Mode := pmBlack;
       MonoBitMap.Canvas.Brush.Color := $01000000;
       MonoBitMap.Canvas.Pen.Color   := $01000000;
      end else
      begin
//       MonoBitMap.Canvas.Pen.Mode := pmWhite;
        MonoBitMap.Canvas.Brush.Color := $01000001;
        MonoBitMap.Canvas.Pen.Color   := $01000001;
      end;
      MonoBitMap.Canvas.Polygon( WrkCILine );
    end; // use Delphi GDI functions
    end; // case GDIType of
}

  end; // for i := 0 to High(WrkDLA) do

end; //*** end of procedure TN_OCanvas.DrawUserMonoRing

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserColorRing
//******************************************** TN_OCanvas.DrawUserColorRing ***
// Draw Ring given by vertexes user coordinates using given draw attributes
//
//     Parameters
// ARCoords       - Ring vertexes user coordinates as double points array
// AREnvRect      - Ring envelope rectangle
// ARingDirection - Ring direction (should be calculated by N_CalcRingDirection 
//                  function)
// ABrushColor    - Brush color
// APenColor      - Pen color
// APenWidth      - Pen width in LLW
//
// Ring is closed Polyline (simply connected contour).
//
procedure TN_OCanvas.DrawUserColorRing( ARCoords: TN_DPArray;
                                      const AREnvRect: TFRect; ARingDirection,
                                      ABrushColor, APenColor: integer;
                                      APenWidth: float );
var
  i, NPoints: integer;
  EnvRect: TFRect;
begin
//  N_T2.Start(1);
  SetPenAttribs( APenColor, APenWidth );
  SetBrushAttribs( ABrushColor );
//  N_T2.Stop(1);

  EnvRect := AREnvRect;
  if EnvRect.Left = N_NotAFloat then
    EnvRect := N_CalcLineEnvRect( ARCoords, 0, Length(ARCoords) );

//  N_T2.Start(2);
  N_ClipRing( MinUClipRect, ARingDirection, ARCoords, EnvRect, WrkDLA1 );
//  N_T2.Stop(2);
{
  NPoints := Length( RCoords );
  SetLength( WrkDLA1, 1 );
  SetLength( WrkDLA1[0], NPoints );
  WrkDLA1[0] := Copy( RCoords, 0, NPoints );
}
  for i := 0 to High(WrkDLA1) do
  begin
    NPoints := Length( WrkDLA1[i] );
    if Npoints = 0 then Continue;
    if Length(WrkCILine) < NPoints then SetLength( WrkCILine, NPoints );
//    N_T2.Start(3);
    N_ConvDlineToILine( U2P, NPoints, @WrkDLA1[i,0], @WrkCILine[0] );
//    N_T2.Stop(3);
//    N_T2.Start(4);
    DrawPixPolygon( WrkCILine, NPoints );
//    N_T2.Start(4);
  end; // for i := 0 to High(WrkDLA1) do
end; //*** end of procedure TN_OCanvas.DrawUserColorRing

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixString
//************************************************ TN_OCanvas.DrawPixString ***
// Draw one string at pixel point using current font attributes
//
//     Parameters
// ABasePoint - upper left string corner in pixel coordinates
// AStr       - string to draw
//
procedure TN_OCanvas.DrawPixString( APixBasePoint: TPoint; AStr: string );
var
  StrLeng: integer;
begin
  StrLeng := Length( AStr );

  if StrLeng >= 1 then // debug
    if AStr[1] = 'N' then
      N_i := 1;

  if StrLeng >= 1 then
    Windows.ExtTextOut( HMDC, APixBasePoint.X, APixBasePoint.Y, 0,
                                                 nil, @AStr[1], StrLeng, nil );
end; //*** end of procedure TN_OCanvas.DrawPixString

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixString2
//*********************************************** TN_OCanvas.DrawPixString2 ***
// Draw one string at pixel point using current font attributes and 
// ABasePointPos
//
//     Parameters
// ABasePoint    - upper left string corner in pixel coordinates
// ABasePointPos - Base Point Position in string envelope rectangle in 
//                 normalized coordinates ( (0,0)-upper-left, 
//                 (0.5,0.5)-hcenter-vcenter, (1,1)- lower-right )
// AStr          - string to draw
//
procedure TN_OCanvas.DrawPixString2( APixBasePoint: TPoint; ABasePointPos: TFPoint; AStr: string );
var
  PixSizeX, PixSizeY: integer;
  PixBasePoint: TPoint;
begin
  if Length(AStr) >= 1 then // debug
    if AStr[1] = 'N' then
      N_i := 1;

  PixBasePoint := APixBasePoint;
  GetStringSize( AStr, PixSizeX, PixSizeY );

  Dec( PixBasePoint.X, Round(PixSizeX*ABasePointPos.X) );
  Dec( PixBasePoint.Y, Round(PixSizeY*ABasePointPos.Y) );

  WrkStrPixRect.TopLeft := PixBasePoint;
  WrkStrPixRect.Right   := WrkStrPixRect.Left + PixSizeX;
  WrkStrPixRect.Bottom  := WrkStrPixRect.Top  + PixSizeY;

  DrawPixString( PixBasePoint, AStr );
end; //*** end of procedure TN_OCanvas.DrawPixString2

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserString
//*********************************************** TN_OCanvas.DrawUserString ***
// Draw one string at User point using current font attributes
//
//     Parameters
// AUserBasePoint - Base Point User coordinates
// AShiftXY       - Base Point (X,Y) shifts in LSU
// ABasePointPos  - Base Point Position in string envelope rectangle in 
//                  normalized coordinates ( (0,0)-upper-left, 
//                  (0.5,0.5)-hcenter-vcenter, (1,1)- lower-right )
// AStr           - string to draw
//
procedure TN_OCanvas.DrawUserString( AUserBasePoint: TDPoint; AShiftXY: TFPoint;
                                           ABasePointPos: TFPoint; AStr: string );
var
  PixSizeX, PixSizeY: integer;
  PixBasePoint: TPoint;
begin
  if Length(AStr) >= 1 then // debug
    if AStr[1] = 'N' then
      N_i := 1;

  PixBasePoint := N_AffConvD2IPoint( AUserBasePoint, U2P );
  Inc( PixBasePoint.X, Round( CurLSUPixSize*AShiftXY.X ) );
  Inc( PixBasePoint.Y, Round( CurLSUPixSize*AShiftXY.Y ) );

  GetStringSize( AStr, PixSizeX, PixSizeY );
  Dec( PixBasePoint.X, Round(PixSizeX*ABasePointPos.X) );
  Dec( PixBasePoint.Y, Round(PixSizeY*ABasePointPos.Y) );

  WrkStrPixRect.TopLeft := PixBasePoint;
  WrkStrPixRect.Right   := WrkStrPixRect.Left + PixSizeX;
  WrkStrPixRect.Bottom  := WrkStrPixRect.Top  + PixSizeY;

// if some WinGDI World transf. is active using CurCRect is not correct!
//  if 0 = N_IRectAnd( WrkStrPixRect, CurCRect ) then // string is not visible
//    Exit;

//  if PixBasePoint.X > 10.e7 then
//    N_i := 1;

  DrawPixString( PixBasePoint, AStr );
end; //*** end of procedure TN_OCanvas.DrawUserString

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawCurveString
//********************************************** TN_OCanvas.DrawCurveString ***
// Draw one string along curve given by spline base points in User coordinates 
// using current font attributes
//
//     Parameters
// APDPoints  - pointer to spline base points in User coordinates array start 
//              element
// ANumPoints - number of actual elements in spline base points array
// AStr       - string to draw
//
procedure TN_OCanvas.DrawCurveString( APDPoints: PDPoint; ANumPoints: integer;
                                                                 AStr: string );
var
  i, NumChars: integer;
  HCurFont, HNewFont, HTmp1: HFont;
  CharPoint: TPoint;
  LogFont: TLogFont;
  DC: TN_DPArray;
  DA: TN_DArray;
begin
  HNewFont := 0;
  N_i := HNewFont; // to avoid warning
  N_T2.Clear(3);
  NumChars := Length(AStr);
  N_T2.Start(0);
  N_Calc2BSplineCoords( APDPoints, ANumPoints, NumChars, DC, DA );
  HCurFont := GetCurrentObject( HMDC, OBJ_FONT );
  GetObject( HCurFont, Sizeof(LogFont), @LogFont );
  N_T2.Stop(0);

  for i := 0 to NumChars-1 do
  begin
    CharPoint := N_AffConvD2IPoint( DC[i], U2P );
    LogFont.lfEscapement := Round( 10*DA[i] );
//    LogFont.lfHeight := 40;
  N_T2.Start(1);
    HNewFont := CreateFontIndirect( LogFont );
//    Assert( HNewFont <> 0, 'Bad Handle' );
    if HNewFont = 0 then
      raise Exception.Create( 'Bad HNewFont Handle' );
    HTmp1 := SelectObject( HMDC, HNewFont );
//    Assert( HTmp1 <> 0, 'Bad Handle' );
    if HTmp1 = 0 then
      raise Exception.Create( 'Bad HTmp1 Handle' );
    if i > 0 then DeleteObject( HTmp1 );
  N_T2.Stop(1);

  N_T2.Start(2);
    Windows.ExtTextOut( HMDC, CharPoint.X, CharPoint.Y, 0,
                                                   nil, @AStr[i+1], 1, nil );
  N_T2.Stop(2);
  end;

  HTmp1 := SelectObject( HMDC, HCurFont );
//  Assert( HTmp1 = HNewFont, 'Bad Handle' );
  if HTmp1 = 0 then
    raise Exception.Create( 'Bad HCurFont Handle' );
  DeleteObject( HTmp1 );
//  N_T2.Show(3);
end; //*** end of procedure TN_OCanvas.DrawCurveString

{ // temporary not implemented
//********************************************* TN_OCanvas.DrawPixRaster ***
// draw Raster fragment in Pixel coords (see N_DrawRaster Params)
//
procedure TN_OCanvas.DrawPixRaster( APRaster: TN_PRaster; ADstRect, ASrcRect: TRect;
                      ARScale: float; APPlace: TN_PictPlace; AMonoColor: integer );
begin
  N_DrawRaster( HMDC, APRaster, ADstRect, ASrcRect, ARScale, APPlace, AMonoColor );

  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, N_RasterChangedRect );
end; //*** end of procedure TN_OCanvas.DrawPixRaster

//******************************************* TN_OCanvas.DrawUserRaster(Rect) ***
// draw Raster in UserRect (see N_DrawRaster Params)
//
procedure TN_OCanvas.DrawUserRaster( APRaster: TN_PRaster; UserRect: TFRect;
                ARScale: float; APPlace: TN_PictPlace; AMonoColor: integer );
var
  BufRect: TRect;
begin
  BufRect := N_AffConvF2IRect( UserRect, U2P );
  DrawPixRaster( APRaster, BufRect, Rect(0,0,-1,-1), ARScale, APPlace, AMonoColor );
end; //*** end of procedure TN_OCanvas.DrawUserRaster(Rect)
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixBMP
//*************************************************** TN_OCanvas.DrawPixBMP ***
// Draw Bitmap fragment in given pixel rectangle
//
//     Parameters
// ABMP      - TBitmap object
// ASelfRect - Self (MainBuf) pixel rectangle where to draw ABMP fragment 
//             (ASelfRect.Right=-1 and ASelfRect.Bottom=-1 means using given 
//             ABMP.Width,ABMP.Height)
// ABMPRect  - ABMP fragment (in pixels) to draw (ABMPRect.Right=-1 and 
//             ABMPRect.Bottom=-1 means ABMPRect.Right=ABMP.Width-1 and 
//             ABMPRect.Bottom=ABMP.Height-1)
//
// if ABMP.Transparent is True, ABMP.TransparentColor is used (not yet).
//
procedure TN_OCanvas.DrawPixBMP( ABMP: TBitmap; ASelfRect, ABMPRect: TRect );
begin
  if ASelfRect.Right  = -1 then ASelfRect.Right  := ASelfRect.Left + ABMP.Width  - 1;
  if ASelfRect.Bottom = -1 then ASelfRect.Bottom := ASelfRect.Top  + ABMP.Height - 1;

  if (ABMPRect.Right = -1) or (ABMPRect.Right >= ABMP.Width) then
    ABMPRect.Right  := ABMP.Width  - 1;
  if (ABMPRect.Bottom = -1) or (ABMPRect.Bottom >= ABMP.Height) then
    ABMPRect.Bottom := ABMP.Height - 1;

  Inc(ASelfRect.Right); Inc(ASelfRect.Bottom); // Windows Rect should be 1 Pix bigger
  Inc(ABMPRect.Right); Inc(ABMPRect.Bottom);

  N_StretchRect( HMDC, ASelfRect, ABMP.Canvas.Handle, ABMPRect );

  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, ASelfRect );
end; //*** end of procedure TN_OCanvas.DrawPixBMP

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserBMP(Rect)
//******************************************** TN_OCanvas.DrawUserBMP(Rect) ***
// Draw Bitmap fragment in rectangle given in User coordinates
//
//     Parameters
// ABMP      - TBitmap object
// AUserRect - rectangle in User coordinates where to draw ABMP fragment
// ABMPRect  - ABMP fragment (in pixels) to draw (ABMPRect.Right=-1 and 
//             ABMPRect.Bottom=-1 means ABMPRect.Right=ABMP.Width-1 and 
//             ABMPRect.Bottom=ABMP.Height-1)
//
// if ABMP.Transparent is True, ABMP.TransparentColor is used (not yet).
//
procedure TN_OCanvas.DrawUserBMP( ABMP: TBitmap; AUserRect: TFRect;
                                                         ABMPRect: TRect );
var
  BufRect: TRect;
begin
  BufRect := N_AffConvF2IRect( AUserRect, U2P );
  DrawPixBMP( ABMP, BufRect, ABmpRect );
end; //*** end of procedure TN_OCanvas.DrawUserBMP(Rect)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserBMP(Point)
//******************************************* TN_OCanvas.DrawUserBMP(Point) ***
// Draw Bitmap fragment in rectangle given by base point in User coordinates and
// size in LSU
//
//     Parameters
// ABMP     - TBitmap object
// ABPUser  - ABMP fragment Base Point in Main raster buffer in User coordinates
// ABPOfs   - Base Point Position in ABMP fragment in normalized coordinates 
//            ((0,0) - upper left, (1,1) - lower right BMP fragment pixel)
// ASizeXY  - ABMP fragment width and height in Main raster buffer in LSU 
//            (negative values means scale coefficients to original ABMP size in
//            pixels)
// ABMPRect - ABMP fragment (in pixels) to draw (ABMPRect.Right=-1 and 
//            ABMPRect.Bottom=-1 means ABMPRect.Right=ABMP.Width-1 and 
//            ABMPRect.Bottom=ABMP.Height-1)
//
// if ABMP.Transparent is True, ABMP.TransparentColor is used (not yet).
//
procedure TN_OCanvas.DrawUserBMP( ABMP: TBitmap; ABPUser: TDPoint;
                         ABPOfs: TFPoint; ASizeXY: TFPoint; ABMPRect: TRect );
var
  PixSizeX, PixSizeY: integer;
  BPPix: TPoint;
  BufRect: TRect;
begin
  if ASizeXY.X < 0 then ASizeXY.X := -ASizeXY.X*ABMP.Width;
  if ASizeXY.Y < 0 then ASizeXY.Y := -ASizeXY.Y*ABMP.Height;
  PixSizeX := Round( ASizeXY.X * CurLSUPixSize );
  PixSizeY := Round( ASizeXY.Y * CurLSUPixSize );
  BPPix := N_AffConvD2IPoint( ABPUser, U2P );
  BufRect.Left := BPPix.X - Round(ABPOfs.X*PixSizeX);
  BufRect.Top  := BPPix.Y - Round(ABPOfs.Y*PixSizeY);
  BufRect.Right := BufRect.Left + PixSizeX - 1;
  BufRect.Bottom := BufRect.Top + PixSizey - 1;

  DrawPixBMP( ABMP, BufRect, ABmpRect );
end; //*** end of procedure TN_OCanvas.DrawUserBMP(Point)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixDIB
//*************************************************** TN_OCanvas.DrawPixDIB ***
// Draw given DIB fragment in Self given pixel rectangle
//
//     Parameters
// ADIB      - TN_DIBObj object
// ASelfRect - Self (MainBuf) pixel rectangle where to draw ADIB fragment
//             (ASelfRect.Right=-1 and ASelfRect.Bottom=-1 means using
//             ADIB.DIBSize)
// ADIBRect  - ADIB fragment (in pixels) to draw (ADIBRect.Right=-1 and
//             ADIBRect.Bottom=-1 means ADIBRect.Right=ADIB.DIBSize.X-1 and
//             ADIBRect.Bottom=ADIB.DIBSize.Y-1)
//
procedure TN_OCanvas.DrawPixDIB( ADIB: TN_DIBObj; ASelfRect, ADIBRect: TRect );
var
  DIBWidth, DIBHeight, DIBTop: integer;
begin
  DIBWidth  := ADIB.DIBInfo.bmi.biWidth; // is alwasy positive

  if ASelfRect.Right  = -1 then ASelfRect.Right  := ASelfRect.Left + DIBWidth  - 1;

  if (ADIBRect.Right = -1) or (ADIBRect.Right >= DIBWidth) then
    ADIBRect.Right  := DIBWidth  - 1;

  DIBHeight := ADIB.DIBInfo.bmi.biHeight; // is positive for bottom-up DIB, is negative for top-down DIB

  if DIBHeight > 0 then //*** bottom-up DIB, origin is the lower left corner
  begin
    if ASelfRect.Bottom = -1 then ASelfRect.Bottom := ASelfRect.Top  + DIBHeight - 1;

    if (ADIBRect.Bottom = -1) or (ADIBRect.Bottom >= DIBHeight) then
      ADIBRect.Bottom := DIBHeight - 1;

    DIBTop := DIBHeight - 1 - ADIBRect.Bottom;
  end else //**************** top-down DIB, origin is the upper left corner (DIBHeight < 0)
  begin
    if ASelfRect.Bottom = -1 then ASelfRect.Bottom := ASelfRect.Top  - DIBHeight - 1;

    if (ADIBRect.Bottom = -1) or (ADIBRect.Bottom >= -DIBHeight) then
      ADIBRect.Bottom := -DIBHeight - 1;

    DIBTop := ADIBRect.Top;
  end;

  Windows.StretchDIBits( HMDC,
                   ASelfRect.Left, ASelfRect.Top,
                   ASelfRect.Right-ASelfRect.Left+1, ASelfRect.Bottom-ASelfRect.Top+1,
//                   ADIBRect.Left, ADIB.DIBRect.Bottom-ADIBRect.Top,
//                   ADIBRect.Left, ADIBRect.Top,
                   ADIBRect.Left, DIBTop,
                   ADIBRect.Right-ADIBRect.Left+1, ADIBRect.Bottom-ADIBRect.Top+1,
                   ADIB.PRasterBytes, PBitmapInfo(@ADIB.DIBInfo)^, DIB_RGB_COLORS, SRCCOPY );
{
  Windows.StretchDIBits( HMDC, 0, 0, 640, 480, 0, 0, 640, 480,
                   ADIB.PRasterBytes, PBitmapInfo(@ADIB.DIBInfo)^, DIB_RGB_COLORS, SRCCOPY );
  Windows.StretchDIBits( HMDC,
                   BufRect.Left, BufRect.Top,
                   BufRect.Right-BufRect.Left+1, BufRect.Bottom-BufRect.Top+1,
                   DIBRect.Left, DIBHeight-DIBRect.Top-1,
                   DIBRect.Right-DIBRect.Left+1, DIBRect.Bottom-DIBRect.Top+1,
                   ADIB.PRasterBytes, PBitmapInfo(@ADIB.DIBInfo)^, DIB_RGB_COLORS, SRCCOPY );
}
  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, ASelfRect );
end; //*** end of procedure TN_OCanvas.DrawPixDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserDIB(Rect)
//******************************************** TN_OCanvas.DrawUserDIB(Rect) ***
// Draw DIB fragment in rectangle given in User coordinates
//
//     Parameters
// ADIB      - TN_DIBObj object
// AUserRect - rectangle in User coordinates where to draw ADIB fragment
// ADIBRect  - ADIB fragment (in pixels) to draw (ADIBRect.Right=-1 and 
//             ADIBRect.Bottom=-1 means ADIBRect.Right=ADIB.DIBSize.X-1 and 
//             ADIBRect.Bottom=ADIB.DIBSize.Y-1)
//
procedure TN_OCanvas.DrawUserDIB( ADIB: TN_DIBObj; AUserRect: TFRect;
                                                   ADIBRect: TRect );
var
  BufRect: TRect;
begin
  BufRect := N_AffConvF2IRect( AUserRect, U2P );
  DrawPixDIB( ADIB, BufRect, ADIBRect );
end; //*** end of procedure TN_OCanvas.DrawUserDIB(Rect)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserDIB(Point)
//******************************************* TN_OCanvas.DrawUserDIB(Point) ***
// Draw DIB fragment in rectangle given by base point in User coordinates and 
// size in LSU
//
//     Parameters
// ADIB     - TN_DIBObj object
// ABPUser  - ADIB fragment Base Point in Main raster buffer in User coordinates
// ABPOfs   - Base Point Position in ADIB fragment in normalized coordinates 
//            ((0,0) - upper left, (1,1) - lower right ADIB fragment pixel)
// ASizeXY  - ADIB fragment width and height in Main raster buffer in LSU 
//            (negative values means scale coefficients to original ADIB size in
//            pixels)
// ADIBRect - ADIB fragment (in pixels) to draw (ADIBRect.Right=-1 and 
//            ADIBRect.Bottom=-1 means ADIBRect.Right=ADIB.DIBSize.X-1 and 
//            ADIBRect.Bottom=ADIB.DIBSize.Y-1)
//
procedure TN_OCanvas.DrawUserDIB( ADIB: TN_DIBObj; ABPUser: TDPoint;
                              ABPOfs: TFPoint; ASizeXY: TFPoint; ADIBRect: TRect );
var
  PixSizeX, PixSizeY: integer;
  BPPix: TPoint;
  BufRect: TRect;
begin
  if ASizeXY.X < 0 then ASizeXY.X := -ASizeXY.X*ADIB.DIBInfo.bmi.biWidth;
  if ASizeXY.Y < 0 then ASizeXY.Y := -ASizeXY.Y*ADIB.DIBInfo.bmi.biHeight;
  PixSizeX := Round( ASizeXY.X * CurLSUPixSize );
  PixSizeY := Round( ASizeXY.Y * CurLSUPixSize );
  BPPix := N_AffConvD2IPoint( ABPUser, U2P );
  BufRect.Left := BPPix.X - Round(ABPOfs.X*PixSizeX);
  BufRect.Top  := BPPix.Y - Round(ABPOfs.Y*PixSizeY);
  BufRect.Right := BufRect.Left + PixSizeX - 1;
  BufRect.Bottom := BufRect.Top + PixSizey - 1;

  DrawPixDIB( ADIB, BufRect, ADIBRect );
end; //*** end of procedure TN_OCanvas.DrawUserDIB(Point)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawMaskedDIBPlg
//********************************************* TN_OCanvas.DrawMaskedDIBPlg ***
// Draw DIB fragment in Self pixel rectangle using Windows.PlgBlt
//
//     Parameters
// ADIB       - TN_DIBObj object to draw
// ASelfRect  - Self (MainBuf) pixel rectangle where to draw ADIB fragment 
//              (ASelfRect.Right=-1 and ASelfRect.Bottom=-1 means using 
//              ADIB.DIBSize)
// ADIBRect   - ADIB fragment (in pixels) to draw (ADIBRect.Right=-1 and 
//              ADIBRect.Bottom=-1 means ADIBRect.Right=ADIB.DIBSize.X-1 and 
//              ADIBRect.Bottom=ADIB.DIBSize.Y-1)
// AMask      - Windows handle of one bit per pixel bitmap
// AMaskShift - Mask shift (Mask pixel that should be used for upper left ADIB 
//              pixel)
//
procedure TN_OCanvas.DrawMaskedDIBPlg( ADIB: TN_DIBObj; ASelfRect, ADIBRect: TRect;
                                       AMask: HBitMap; AMaskShift: TPoint );
var
  DIBWidth, DIBHeight, DIBTop: integer;
begin
  DIBWidth  := ADIB.DIBInfo.bmi.biWidth; // is alwasy positive

  if ASelfRect.Right  = -1 then ASelfRect.Right  := ASelfRect.Left + DIBWidth  - 1;

  if (ADIBRect.Right = -1) or (ADIBRect.Right >= DIBWidth) then
    ADIBRect.Right  := DIBWidth  - 1;

  DIBHeight := ADIB.DIBInfo.bmi.biHeight; // is positive for bottom-up DIB, is negative for top-down DIB

  if DIBHeight > 0 then //*** bottom-up DIB, origin is the lower left corner
  begin
    if ASelfRect.Bottom = -1 then ASelfRect.Bottom := ASelfRect.Top  + DIBHeight - 1;

    if (ADIBRect.Bottom = -1) or (ADIBRect.Bottom >= DIBHeight) then
      ADIBRect.Bottom := DIBHeight - 1;

    DIBTop := DIBHeight - 1 - ADIBRect.Bottom;
  end else //**************** top-down DIB, origin is the upper left corner (DIBHeight < 0)
  begin
    if ASelfRect.Bottom = -1 then ASelfRect.Bottom := ASelfRect.Top  - DIBHeight - 1;

    if (ADIBRect.Bottom = -1) or (ADIBRect.Bottom >= -DIBHeight) then
      ADIBRect.Bottom := -DIBHeight - 1;

    DIBTop := ADIBRect.Top;
  end;

  N_i := DIBTop;

{
// Windows.PlgBlt
var
  DestPoints: array [0..2] of TPoint;
  Result: BOOL;
begin
  DestPoints[0] := ASelfRect.Points[1];
  DestPoints[1] := ASelfRect.Points[2];
  DestPoints[2] := ASelfRect.Points[0];

  Result := PlgBlt(HMDC, DestPoints,
             ADIB.DIBOCanv.HMDC,
             ADIBRect.Left, ADIBRect.Top,
             ADIBRect.Right-ADIBRect.Left+1, ADIBRect.Bottom-ADIBRect.Top+1, AMask, AMaskShift.X, AMaskShift.Y);
}

  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, ASelfRect );
end; //*** end of procedure TN_OCanvas.DrawMaskedDIBPlg

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawTranspDIB
//************************************************ TN_OCanvas.DrawTranspDIB ***
// Draw DIB fragment in Self pixel rectangle using Windows.TransparentBlt
//
//     Parameters
// ADIB         - TN_DIBObj object to draw
// ASelfRect    - Self (MainBuf) pixel rectangle where to draw ADIB fragment 
//                (ASelfRect.Right=-1 and ASelfRect.Bottom=-1 means using 
//                ADIB.DIBSize)
// ADIBRect     - ADIB fragment (in pixels) to draw (ADIBRect.Right=-1 and 
//                ADIBRect.Bottom=-1 means ADIBRect.Right=ADIB.DIBSize.X-1 and 
//                ADIBRect.Bottom=ADIB.DIBSize.Y-1)
// ATranspColor - Transparent ADIB Color (ADIB pixels of this Color would be 
//                transparent)
//
procedure TN_OCanvas.DrawTranspDIB( ADIB: TN_DIBObj; ASelfRect, ADIBRect: TRect;
                                                          ATranspColor: integer );
var
  DIBWidth, DIBHeight, DIBTop: integer;
begin
  DIBWidth  := ADIB.DIBInfo.bmi.biWidth; // is alwasy positive

  if ASelfRect.Right  = -1 then ASelfRect.Right  := ASelfRect.Left + DIBWidth  - 1;

  if (ADIBRect.Right = -1) or (ADIBRect.Right >= DIBWidth) then
    ADIBRect.Right  := DIBWidth  - 1;

  DIBHeight := ADIB.DIBInfo.bmi.biHeight; // is positive for bottom-up DIB, is negative for top-down DIB

  if DIBHeight > 0 then //*** bottom-up DIB, origin is the lower left corner
  begin
    if ASelfRect.Bottom = -1 then ASelfRect.Bottom := ASelfRect.Top  + DIBHeight - 1;

    if (ADIBRect.Bottom = -1) or (ADIBRect.Bottom >= DIBHeight) then
      ADIBRect.Bottom := DIBHeight - 1;

    DIBTop := DIBHeight - 1 - ADIBRect.Bottom;
  end else //**************** top-down DIB, origin is the upper left corner (DIBHeight < 0)
  begin
    if ASelfRect.Bottom = -1 then ASelfRect.Bottom := ASelfRect.Top  - DIBHeight - 1;

    if (ADIBRect.Bottom = -1) or (ADIBRect.Bottom >= -DIBHeight) then
      ADIBRect.Bottom := -DIBHeight - 1;

    DIBTop := ADIBRect.Top;
  end;
  N_i := DIBTop; // to avoid warning

  TransparentBlt(HMDC, ASelfRect.Left, ASelfRect.Top,
             ASelfRect.Right-ASelfRect.Left+1, ASelfRect.Bottom-ASelfRect.Top+1,
             ADIB.DIBOCanv.HMDC,
             ADIBRect.Left, ADIBRect.Top,
             ADIBRect.Right-ADIBRect.Left+1, ADIBRect.Bottom-ADIBRect.Top+1, ATranspColor);

  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, ASelfRect );
end; //*** end of procedure TN_OCanvas.DrawTranspDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixDIBAlfa
//*********************************************** TN_OCanvas.DrawPixDIBAlfa ***
//
//
//     Parameters
// ADIB  - TN_DIBObj object
// AAlfa - AAlfa = -1 use Alfa bytes in ADIB, otherwise given fixed Alfa
//
procedure TN_OCanvas.DrawPixDIBAlfa( ADIB: TN_DIBObj; AAlfa: integer );
Const
  AC_SRC_ALPHA = $01;
  // defined in BDS2006 headers as BlendOp,
  // but this seems to be really AlphaFormat
var
  blend : BLENDFUNCTION;
  ASelfRect, ADIBRect: TRect;
  DIBWidth, DIBHeight, DIBTop: integer;
begin
  if  ADIB.DIBInfo.bmi.biBitCount < 24 then Exit; // a precaution

  ADIBRect  := ADIB.DIBRect;
  ASelfRect := ADIB.DIBRect;

  with blend do
  begin
    BlendOp := AC_SRC_OVER; // one blend op really supported
    BlendFlags := 0;
    If AAlfa = -1 then
     begin
     AlphaFormat :=  AC_SRC_ALPHA;
     SourceConstantAlpha := 255;
    // Src image must contain alpha and RGB channels must be premulted
     end else
     begin
     AlphaFormat := 0;
     SourceConstantAlpha := 128;
     end;

  end;

  DIBWidth  := ADIB.DIBInfo.bmi.biWidth; // is alwasy positive

  if ASelfRect.Right  = -1 then ASelfRect.Right  := ASelfRect.Left + DIBWidth  - 1;

  if (ADIBRect.Right = -1) or (ADIBRect.Right >= DIBWidth) then
    ADIBRect.Right  := DIBWidth  - 1;

  DIBHeight := ADIB.DIBInfo.bmi.biHeight; // is positive for bottom-up DIB, is negative for top-down DIB

  if DIBHeight > 0 then //*** bottom-up DIB, origin is the lower left corner
  begin
    if ASelfRect.Bottom = -1 then ASelfRect.Bottom := ASelfRect.Top  + DIBHeight - 1;

    if (ADIBRect.Bottom = -1) or (ADIBRect.Bottom >= DIBHeight) then
      ADIBRect.Bottom := DIBHeight - 1;

    DIBTop := DIBHeight - 1 - ADIBRect.Bottom;
  end else //**************** top-down DIB, origin is the upper left corner (DIBHeight < 0)
  begin
    if ASelfRect.Bottom = -1 then ASelfRect.Bottom := ASelfRect.Top  - DIBHeight - 1;

    if (ADIBRect.Bottom = -1) or (ADIBRect.Bottom >= -DIBHeight) then
      ADIBRect.Bottom := -DIBHeight - 1;

    DIBTop := ADIBRect.Top;
  end;

  N_i := DIBTop;

  // to display bitmaps that have transparent or semitransparent pixels
  AlphaBlend(HMDC, ASelfRect.Left, ASelfRect.Top,
             ASelfRect.Right-ASelfRect.Left+1, ASelfRect.Bottom-ASelfRect.Top+1,
             ADIB.DIBOCanv.HMDC,
             ADIBRect.Left, ADIBRect.Top,
             ADIBRect.Right-ADIBRect.Left+1, ADIBRect.Bottom-ADIBRect.Top+1, blend);

end; // procedure TN_OCanvas.DrawPixDIBAlfa

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawPixMetafile
//********************************************** TN_OCanvas.DrawPixMetafile ***
// Draw Metafile fragment in given pixel rectangle
//
//     Parameters
// AMetafile     - TMetafile object
// ASelfRect     - Self (MainBuf) pixel rectangle where to draw AMetafile 
//                 fragment (ASelfRect.Right=-1 and ASelfRect.Bottom=-1 means 
//                 using given AMetafile.Width and AMetafile.Height)
// AMetafileRect - AMetafile fragment (in pixels) to draw 
//                 (AMetafileRect.Right=-1 and AMetafileRect.Bottom=-1 means 
//                 AMetafileRect.Right=AMetafile.Width-1 and 
//                 AMetafileRect.Bottom=AMetafile.Height-1)
//
procedure TN_OCanvas.DrawPixMetafile( AMetafile: TMetafile;
                                                ASelfRect, AMetafileRect: TRect );
var
  DX, DY: integer;
  SavedClipRect, EnlargedBufRect, WholeRect: TRect;
begin
{
  k, DX, DY, MFHeaderSize: integer;
  MFHeader: ENHMETAHEADER;
  MFHeaderSize := GetEnhMetaFileHeader( Metafile.Handle, 0, nil );
//  Assert( MFHeaderSize > 0, 'Metafile Header Error' );
  if MFHeaderSize <= 0 then
    raise Exception.Create( 'Metafile Header Error' );
  GetEnhMetaFileHeader( Metafile.Handle, Sizeof(MFHeader), @MFHeader );

  with MFHeader do
  begin
    DX := rclFrame.Right - rclFrame.Left;
    k := szlMillimeters.cx * 100;
    DX := (DX*szlDevice.cx + k div 2) div k;
    DY := rclFrame.Bottom - rclFrame.Top;
    k := szlMillimeters.cy * 100;
    DY := (DY*szlDevice.cy + k div 2) div k;
  end; // with MFHeader do
}
  DX := AMetafile.Width;
  DY := AMetafile.Height;
  if ASelfRect.Right  = -1 then ASelfRect.Right  := ASelfRect.Left + DX - 1;
  if ASelfRect.Bottom = -1 then ASelfRect.Bottom := ASelfRect.Top  + DY - 1;

  if (AMetafileRect.Right = -1) or (AMetafileRect.Right >= DX) then
    AMetafileRect.Right  := DX - 1;
  if (AMetafileRect.Bottom = -1) or (AMetafileRect.Bottom >= DY) then
    AMetafileRect.Bottom := DY - 1;

//??  Inc(BufRect.Right); Inc(BufRect.Bottom); // Windows Rect should be 1 Pix bigger
//??  Inc(BMPRect.Right); Inc(BMPRect.Bottom);

  SavedClipRect.Left := N_NotAnInteger;
  if (AMetafileRect.Left > 0) or (AMetafileRect.Right  < (DX-1)) or
     (AMetafileRect.Top  > 0) or (AMetafileRect.Bottom < (DY-1)) then
  begin // draw Metafile fragment, clipping is needed
    SavedClipRect := ConPClipRect;
    SetPClipRect( ASelfRect );
    WholeRect := Rect( 0, 0, DX-1, DY-1 ); // whole Metafile Rect
    EnlargedBufRect := N_IRectIAffConv2( WholeRect, AMetafileRect, WholeRect );
    // Remark: Delphi GDI do not able to draw Metafile fragment!
    PlayEnhMetaFile( HMDC, AMetafile.Handle, EnlargedBufRect );
    SetPClipRect( SavedClipRect ); // restore
  end else // draw whole Metafile
    PlayEnhMetaFile( HMDC, AMetafile.Handle, ASelfRect );

  if CollectInvRects then
    N_AddOneRect( InvRects, NumInvRects, ASelfRect );
end; // procedure TN_OCanvas.DrawPixMetafile

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserMetafile(Rect)
//*************************************** TN_OCanvas.DrawUserMetafile(Rect) ***
// Draw Metafile fragment in rectangle given in User coordinates
//
// AMetafile     - TMetafile object AUserRect     - rectangle in User 
// coordinates where to draw Metafile fragment AMetafileRect - AMetafile 
// fragment (in pixels) to draw (AMetafileRect.Right=-1 and 
// AMetafileRect.Bottom=-1 means AMetafileRect.Right=AMetafile.Width-1 and 
// AMetafileRect.Bottom=AMetafile.Height-1)
//
procedure TN_OCanvas.DrawUserMetafile( AMetafile: TMetafile;
                                       AUserRect: TFRect; AMetafileRect: TRect );
var
  BufRect: TRect;
begin
  BufRect := N_AffConvF2IRect( AUserRect, U2P );
  DrawPixMetafile( AMetafile, BufRect, AMetafileRect );
end; //*** end of procedure TN_OCanvas.DrawUserMetafile(Rect)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\DrawUserMetafile(Point)
//************************************** TN_OCanvas.DrawUserMetafile(Point) ***
// Draw Metafile fragment in rectangle given by base point in User coordinates 
// and size in LSU
//
//     Parameters
// AMetafile     - TMetafile object
// ABPUser       - AMetafile fragment Base Point in Main raster buffer in User 
//                 coordinates
// ABPOfs        - Base Point Position in AMetafile fragment in normalized 
//                 coords ((0,0)-upper left, (1,1)-lower right AMetafile 
//                 fragment pixel)
// ASizeXY       - Metafile fragment width and height in Main raster buffer in 
//                 LSU (negative values means scale coefficients to original 
//                 AMetafile size in pixels)
// AMetafileRect - AMetafile fragment (in pixels) to draw 
//                 (AMetafileRect.Right=-1 and AMetafileRect.Bottom=-1 means 
//                 AMetafileRect.Right=AMetafile.Width-1 and 
//                 AMetafileRect.Bottom=AMetafile.Height-1)
//
procedure TN_OCanvas.DrawUserMetafile( AMetafile: TMetafile; ABPUser: TDPoint;
                       ABPOfs: TFPoint; ASizeXY: TFPoint; AMetafileRect: TRect );
var
  PixSizeX, PixSizeY: integer;
  BPPix: TPoint;
  BufRect: TRect;
begin
  if ASizeXY.X < 0 then ASizeXY.X := -ASizeXY.X*AMetafile.Width;
  if ASizeXY.Y < 0 then ASizeXY.Y := -ASizeXY.Y*AMetafile.Height;
  PixSizeX := Round( ASizeXY.X * CurLSUPixSize );
  PixSizeY := Round( ASizeXY.Y * CurLSUPixSize );
  BPPix := N_AffConvD2IPoint( ABPUser, U2P );
  BufRect.Left := BPPix.X - Round(ABPOfs.X*PixSizeX);
  BufRect.Top  := BPPix.Y - Round(ABPOfs.Y*PixSizeY);
  BufRect.Right  := BufRect.Left + PixSizeX - 1;
  BufRect.Bottom := BufRect.Top + PixSizey - 1;

  DrawPixMetafile( AMetafile, BufRect, AMetafileRect );
end; //*** end of procedure TN_OCanvas.DrawUserBMP(Point)


//********************************************* TN_OCanvas.SetTics ***
// Set all Tics params:
// -
// Should be moved to higher level object
//
// DP1, DP2 - ConTicSegm end points
// TicZBase - Tic Base coord (X for horizontal ConSegm, Y for vertical)
// TicZStep - Tic Step size (along ConSegm)
//
procedure TN_OCanvas.SetTics( TicP1, TicP2: TDPoint;
                              const TicZBase, TicZStep: double );
var
  CurEps, DX: double;
begin
  ConTicP1 := TicP1;
  ConTicP2 := TicP2;
  ConTicZBase := TicZBase;
  ConTicZStep := TicZStep;

  CurEps := (Abs(ConTicP1.X)+1)*N_Eps; // current calculation accuracy
  DX := ConTicP2.X - ConTicP1.X;

  if Abs(DX) < CurEps then //****** vertical ConTicSegm
  begin
    ConTicP2.X := ConTicP1.X; // to enable if (P1.X=P2.X) then ... checking
    if ConTicP1.Y > ConTicP2.Y then // order P1,P2 Y coords
    begin
      DX := ConTicP1.Y; // DX is used as temporary variable
      ConTicP1.Y := ConTicP2.Y;
      ConTicP2.Y := DX;
    end;
    ConTicZBase := Max( ConTicZBase, ConTicP1.Y ); // a precaution
    ConTicZBase := Min( ConTicZBase, ConTicP2.Y ); // a precaution

    CurEps := (Abs(ConTicP1.Y)+1)*N_Eps; // current calculation Y accuracy

    ConTicInd1 := -Round( (ConTicZBase-ConTicP1.Y)/ConTicZStep - 0.5 );
    if Abs(ConTicP1.Y - (ConTicZBase+ConTicInd1*ConTicZStep)) < CurEps then
      Inc(ConTicInd1);  // exclude first Tic point

    ConTicInd2 := Round( (ConTicP2.Y-ConTicZBase)/ConTicZStep - 0.5 );
    if Abs(ConTicP2.Y - (ConTicZBase+ConTicInd2*ConTicZStep)) < CurEps then
      Dec(ConTicInd2);  // exclude last Tic point

  end else //****** horizontal ConTicSegm
  begin
    ConTicP2.Y := ConTicP1.Y; // to enable if (P1.Y=P2.Y) then ... checking
    if ConTicP1.X > ConTicP2.X then // order P1,P2 X coords
    begin
      DX := ConTicP1.X; // DX is used as temporary variable
      ConTicP1.X := ConTicP2.X;
      ConTicP2.X := DX;
    end;
    ConTicZBase := Max( ConTicZBase, ConTicP1.X ); // a precaution
    ConTicZBase := Min( ConTicZBase, ConTicP2.X ); // a precaution

    ConTicInd1 := -Round( (ConTicZBase-ConTicP1.X)/ConTicZStep - 0.5 );
    if Abs(ConTicP1.X - (ConTicZBase+ConTicInd1*ConTicZStep)) < CurEps then
      Inc(ConTicInd1);  // exclude first Tic point

    ConTicInd2 := Round( (ConTicP2.X-ConTicZBase)/ConTicZStep - 0.5 );
    if Abs(ConTicP2.X - (ConTicZBase+ConTicInd2*ConTicZStep)) < CurEps then
      Dec(ConTicInd2);  // exclude last Tic point
  end;
end; // end of procedure TN_OCanvas.SetTics

//****************************************** TN_OCanvas.DrawCoordsLines ***
// draw coords lines perpendicular to current ConSegm at Current ConTic
// steps using current Pen attributes,
// ( if Tic segment is vertical, coords lines are horizontal,
//   if Tic segment is horizontal, coords lines are vertical )
//
// ZMin        - Min Z User coord (Z=X for horizontal coords lines)
// ZMax        - Max Z User coord (Z=X for horizontal coords lines)
//               ( ZMin, ZMax should be ordered: ZMin < ZMax )
// LLWDashSize - line Dash Size in LLW units,
// LLWSkipSize - line Skip Size (gap btween dashes)  in LLW units,
//
procedure TN_OCanvas.DrawCoordsLines( ZMin, ZMax: double;
                                        LLWDashSize, LLWSkipSize: float );
var
  i: integer;
  Cline: TN_DParray;
begin
  setLength( Cline, 2 );

  if ConTicP1.X = ConTicP2.X then // draw horizontal coords lines
  begin
    for i := ConTicInd1 to ConTicInd2 do
    begin
      Cline[0].X := ZMin;
      Cline[1].X := Cline[0].X + LSUToUserX( LLWDashSize );
      Cline[0].Y := ConTicZBase + i*ConTicZStep;
      Cline[1].Y := Cline[0].Y;
      while Cline[0].X  < ZMax do
      begin
        Cline[1].X := Min( Cline[1].X, ZMax );
        DrawUserPolyline1( Cline );
        Cline[0].X := Cline[1].X + LSUToUserX( LLWSkipSize );
        Cline[1].X := Cline[0].X + LSUToUserX( LLWDashSize );
      end; // while
    end; // for i := ConTicInd1 to ConTicInd2 do
  end else // draw vertical coords lines
  begin
    for i := ConTicInd1 to ConTicInd2 do
    begin
      Cline[0].Y := ZMin;
      Cline[1].Y := Cline[0].Y + LSUToUserY( LLWDashSize );
      Cline[0].X := ConTicZBase + i*ConTicZStep;
      Cline[1].X := Cline[0].X;
      while Cline[0].Y  < ZMax do
      begin
        Cline[1].Y := Min( Cline[1].Y, ZMax );
        DrawUserPolyline1( Cline );
        Cline[0].Y := Cline[1].Y + LSUToUserY( LLWSkipSize );
        Cline[1].Y := Cline[0].Y + LSUToUserY( LLWDashSize );
      end; // while
    end; // for i := ConTicInd1 to ConTicInd2 do
  end;
end; //*** end of procedure TN_OCanvas.DrawCoordsLines

//****************************************** TN_OCanvas.DrawAxisTics ***
// draw Axis Tics using current Pen and Tics params
// ( if Tic segment is vertical, Tics are horizontal,
//   if Tic segment is horizontal, Tics are vertical )
//
// TicSize1 - Tic size in LLW to the left or below of TcSegm
// TicSize2 - Tic size in LLW to the right or upper of TcSegm
//
procedure TN_OCanvas.DrawAxisTics( TicSize1, TicSize2: integer );
var
  i: integer;
  TicLine: TN_DParray;
begin
  setLength( TicLine, 2 );

  if ConTicP1.X = ConTicP2.X then // draw horizontal Tics
  begin
    for i := ConTicInd1 to ConTicInd2 do
    begin
      TicLine[0].X := ConTicP1.X - LSUToUserX( TicSize1 );
      TicLine[1].X := ConTicP1.X + LSUToUserX( TicSize2 );
      TicLine[0].Y := ConTicZBase + i*ConTicZStep;
      TicLine[1].Y := TicLine[0].Y;
      DrawUserPolyline1( TicLine );
    end; // for i := ConTicInd1 to ConTicInd2 do
  end else // draw vertical Tics
  begin
    for i := ConTicInd1 to ConTicInd2 do
    begin
      TicLine[0].Y := ConTicP1.Y - LSUToUserY( TicSize1 );
      TicLine[1].Y := ConTicP1.Y + LSUToUserY( TicSize2 );
      TicLine[0].X := ConTicZBase + i*ConTicZStep;
      TicLine[1].X := TicLine[0].X;
      DrawUserPolyline1( TicLine );
    end; // for i := ConTicInd1 to ConTicInd2 do
  end;
end; //*** end of procedure TN_OCanvas.DrawAxisTics

//****************************************** TN_OCanvas.DrawAxisMarks ***
// draw Axis text Marks using current Pen and Tics params
//
// ShiftXY      - shifts in LLW of text Mark BasePoint against Tic point
// BasePointPos - Base Point Position (see DrawUserString method)
// Fmt          - Pascal format string for converting coord value to text
//
procedure TN_OCanvas.DrawAxisMarks( ShiftXY: TFPoint; BasePointPos: TFPoint;
                                                              Fmt: string );
var
  i: integer;
  MarkPoint: TDPoint;
  MarkStr: string;
begin
  if ConTicP1.X = ConTicP2.X then // draw Y-Coord Text Marks along vertical Axis
  begin
    for i := ConTicInd1 to ConTicInd2 do
    begin
      MarkPoint.X := ConTicP1.X;
      MarkPoint.Y := ConTicZBase + i*ConTicZStep;
      MarkStr := Format( Fmt, [MarkPoint.Y] );
      DrawUserString( MarkPoint, ShiftXY, BasePointPos, MarkStr );
    end; // for i := ConTicInd1 to ConTicInd2 do
  end else // draw X-Coord Text Marks along horizontal Axis
  begin
    for i := ConTicInd1 to ConTicInd2 do
    begin
      MarkPoint.Y := ConTicP1.Y;
      MarkPoint.X := ConTicZBase + i*ConTicZStep;
      MarkStr := Format( Fmt, [MarkPoint.X] );
      DrawUserString( MarkPoint, ShiftXY, BasePointPos, MarkStr );
    end; // for i := ConTicInd1 to ConTicInd2 do
  end;
end; //*** end of procedure TN_OCanvas.DrawAxisMarks

//*************************************** TN_OCanvas.DrawAxisArrow ***
// draw AxisArrow on current Tic segment
//
// BaseZ       - Arrow point coord (Z=X if axis (Tic segment) is horizontal)
// ArrowLength - Arrow Length in LLW
// ArrowWidth  - Arrow Width in LLW
// Mode        - Arrow Mode (not yet)
//
procedure TN_OCanvas.DrawAxisArrow( BaseZ: double;
                               ArrowLength, ArrowWidth, Mode: integer );
var
  ALine: TN_DParray;
begin
  setLength( ALine, 3 );

  if ConTicP1.X = ConTicP2.X then // draw Arrow on vertical Axis
  begin
    ALine[0].X := ConTicP1.X - LSUToUserX( ArrowWidth );
    ALine[0].Y := BaseZ - LSUToUserY( ArrowLength );
    ALine[1].X := ConTicP1.X;
    ALine[1].Y := BaseZ;
    ALine[2].X := ConTicP1.X + LSUToUserX( ArrowWidth );
    ALine[2].Y := ALine[0].Y;
  end else // draw Arrow on horizontal Axis
  begin
    ALine[0].Y := ConTicP1.Y - LSUToUserY( ArrowWidth );
    ALine[0].X := BaseZ - LSUToUserX( ArrowLength );
    ALine[1].Y := ConTicP1.Y;
    ALine[1].X := BaseZ;
    ALine[2].Y := ConTicP1.Y + LSUToUserY( ArrowWidth );
    ALine[2].X := ALine[0].X;
  end;
  DrawUserPolyline1( ALine );
end; //*** end of procedure TN_OCanvas.DrawAxisArrow

//*************************************** TN_OCanvas.DrawSArrow ***
// draw DrawSArrow in User Coords using given attributes
// (see TN_CSArrow struct)
//
procedure TN_OCanvas.DrawSArrow( ASegm: TFRect; SAWidths, SALengths: TFPoint;
                                             AFlags: integer; AColor: integer );

var
  P1, P2: TDPoint;
begin
  SetPenAttribs( AColor, 0 );
  SetBrushAttribs( AColor );

  P1 := DPoint( ASegm.TopLeft );
  P2 := DPoint( ASegm.BottomRight );
  DrawUserStraightArrow( P1, P2, AFlags, SALengths.X, SALengths.Y,
                                          SAWidths.X, SAWidths.Y );
end; //*** end of procedure TN_OCanvas.DrawSArrow

//************************************** TN_OCanvas.DrawHatchLines ***
// Fill Whole current ClipBox by Drawing Hatch Lines (Solid or Dashed)
// (it is assumed, that Proper ClipRegion should be already set)
// (DashAttribs should be nil for Solid Lines)
//
procedure TN_OCanvas.DrawHatchLines( HatchAttr: TN_HatchAttr;
                                                DashAttribs: TN_DashAttribs );
var
  i, j, JMax, Y1Beg, Y2Beg, X1Beg, X2Beg, DXi, DYi: integer;
  Alfa, CosA, SinA, Sx, Sy, S, StepX, StepY: double;
  CCBox: TRect;
  Line: TN_IPArray;
  DLine: TN_DPArray;
  SavedP2U, SavedU2P: TN_AffCoefs4;
  SavedUClipRect: TFRect;

  procedure DrawHatchLine(); // local (used twice)
  begin
    if DashAttribs = nil then
      Polyline( HMDC, (@Line[0])^, 2 )
    else
    begin
      DLine[0].X := Line[0].X;
      DLine[0].Y := Line[0].Y;
      DLine[1].X := Line[1].X;
      DLine[1].Y := Line[1].Y;
      DrawDashedPolyline( DLine, DashAttribs );
    end;
  end; // procedure DrawHatchLine(); // local

begin
  GetClipBox( HMDC, CCBox ); // Current Clip Box
//  CCBox := Rect( 100, 100, 300, 200 ); // temporary, for debug
  SetLength( Line, 2 );

  if DashAttribs = nil then // Solid Hatch Lines
  begin
    SetPenAttribs( HatchAttr.LineColor, HatchAttr.LineWidth );
    BeginPath( HMDC ); // use Path only for Solid Lines
  end
  else //******************** Dashed Hatch Lines
  begin // (Dashed Lines can be Drawn only in User Coords ...)
    SetLength( DLine, 2 );
    SavedP2U := P2U;
    SavedU2P := U2P;
    SavedUClipRect := MinUClipRect;

    P2U := N_DefAffCoefs4;
    U2P := N_DefAffCoefs4; // U2P.SX := 1.0e-6; U2P.SY := 1.0e-6;
    MinUClipRect := FRect( -9000, -9000, 9000, 9000 ); // to skip clipping
  end;

  with HatchAttr do
  begin
    // convert LineAngle to ( -90 < LineAngle <= 90 ) range

    if LineAngle = - 90 then LineAngle := 90;
    if (LineAngle > 90)  and (LineAngle < 180)  then LineAngle := LineAngle - 180;
    if (LineAngle < -90) and (LineAngle > -180) then LineAngle := LineAngle + 180;

    if (LineOffs < 0) or (LineOffs >= LineStep) then
    begin                         // force 0 <= LineOffs < LineStep
      S := LineOffs / LineStep;
      LineOffs := LineStep*(S - Floor(S));
    end;

    Alfa := N_PI * LineAngle / 180; // conv to radians
    CosA := Cos(Alfa);  SinA := Sin(Alfa);
    Sx := SinA; Sy := - CosA; // (Sx,Sy) - Ort, perpendicular to Line

    //***** 1) Si = LineOffset + i*LineStep
    //      2) in all scalar products Y sign shoud be changed

    if (-45 <= LineAngle) and (45 >= LineAngle) then // low slope
    begin
      StepY := LineSTep / CosA; // step between lines along Y

      if LineAngle >= 0 then // slash like lines (/), angle in (0...45),
      begin                  // go from Upper Left ClipBox corner
        S := Sx*CCBox.Left - Sy*CCBox.Top;  // projection of CCBox.(Left,Top) on (Sx,Sy)
        i := Round(Floor((S - LineOffs) / LineStep));
        S := LineOffs + i*LineStep;

        // (Sx,Sy)*(Left,-Y1Beg) = S

        Y1Beg := -Round((S - Sx*CCBox.Left) / Sy);
        Y2Beg := Y1Beg - Round((CCBox.Right - CCBox.Left)*SinA/CosA);
        JMax := Round((CCBox.Bottom - Y2Beg)/StepY); // number of Lines
      end else // backslash like lines (\), angle in (-45...0),
      begin    // go from Upper Right ClipBox corner
        S := Sx*CCBox.Right - Sy*CCBox.Top;
        i := Round(Floor((S - LineOffs) / LineStep));
        S := LineOffs + i*LineStep;

        // (Sx,Sy)*(Right,-Y2Beg) = S

        Y2Beg := -Round((S - Sx*CCBox.Right) / Sy);
        Y1Beg := Y2Beg + Round((CCBox.Right - CCBox.Left)*SinA/CosA);
        JMax := Round((CCBox.Bottom - Y1Beg)/StepY);
      end; // else // backslash like lines (\)

      Line[0].X := CCBox.Left;  // for all Lines
      Line[1].X := CCBox.Right; // for all Lines

      for j := 0 to JMax do
      begin
        DYi := Round( j*StepY );
        Line[0].Y := Y1Beg + DYi;
        Line[1].Y := Y2Beg + DYi;

        DrawHatchLine(); // Solid or Dashed
      end; // for j := 0 to JMax do

    end else //************  high slope ( LineAngle < - 45 or LineAngle > 45 )
    begin
      if LineAngle >= 0 then // slash like lines (/), angle in (45...90),
      begin                  // go from Upper Left ClipBox corner
        StepX := LineSTep / SinA; // StepX always > 0
        S := Sx*CCBox.Left - Sy*CCBox.Top;
        i := Round(Floor((S - LineOffs) / LineStep));
        S := LineOffs + i*LineStep;

        // (Sx,Sy)*(X1Beg,-Top) = S

        X1Beg := Round((S + Sy*CCBox.Top) / Sx);
        X2Beg := X1Beg - Round((CCBox.Bottom - CCBox.Top)*CosA/SinA);
        JMax  := Round((CCBox.Right - X2Beg)/StepX);
      end else // backslash like lines (\), angle in (-90...-45),
      begin    // go from Lower Left ClipBox corner
        StepX := - LineSTep / SinA; // StepX >= 0
        S := Sx*CCBox.Left - Sy*CCBox.Bottom;
        i := Round(Floor((S - LineOffs) / LineStep));
        S := LineOffs + i*LineStep;

        // (Sx,Sy)*(X2Beg,-Bottom) = S

        X2Beg := Round((S + Sy*CCBox.Bottom) / Sx);
        X1Beg := X2Beg + Round((CCBox.Bottom - CCBox.Top)*CosA/SinA);
        JMax  := Round((CCBox.Right - X1Beg )/StepX);
      end;

      Line[0].Y := CCBox.Top;
      Line[1].Y := CCBox.Bottom;

      for j := 0 to JMax do
      begin
        DXi := Round( j*StepX );
        Line[0].X := X1Beg + DXi;
        Line[1].X := X2Beg + DXi;

        DrawHatchLine(); // Solid or Dashed
      end; // for j := 0 to JMax do

    end; // else - backslash like lines (\), go from Upper Right ClipBos corner
  end; // with HatchAttr do

  Line := nil;
  if DashAttribs = nil then // Solid Hatch Lines
  begin
    EndPath( HMDC );
    StrokePath( HMDC );
  end
  else //******************** Dashed Hatch Lines
  begin
    DLine  := nil;
    P2U := SavedP2U; // restore original values
    U2P := SavedU2P;
    MinUClipRect := SavedUClipRect;
  end;
end; //*** end of procedure TN_OCanvas.DrawHatchLines

//************************************************** TN_OCanvas.SaveCopyTo ***
//
// Obsolete implementation, should be redesined!
//
// Save to File or Copy To Clipboard given MainBuf fragment
//
// FileName    - Full File Name or '' for copiing to Clipboard in BMP format
// AFileFmt    - File Format (implemented formats are BMP, GIF, JPEG)
// PixRect     - Pixel Rect to Save
// APExtRFPar  - Pointer to Extended Raster File Params
//              (X,Y Resolutions, TranspColor, JPEG Quality)
//
procedure TN_OCanvas.SaveCopyTo( FileName: string; AFileFmt: TN_ImageFileFormat;
                         PixRect: Trect; APImFPar: TN_PImageFilePar = nil );
//                                            APFile1Params: TN_PFile1Params );
var
  TmpBMP: TBitmap;
  ImSize: TPoint;
//  JPG: TJPEGImage;
//  GIF: TGifFile;
//  GifSubImage: TGifSubImage;
  FilePixFmt: TPixelFormat;
  WrkImFPar: TN_ImageFilePar;
begin
  if APImFPar = nil then WrkImFPar := N_DefImageFilePar
                    else WrkImFPar := APImFPar^;

{ // not implemented now
  if (FileName <> '') and // save to file, not to clipboard
     ( (IntFileFormat = iffDIB) or (IntFileFormat = iffDIBZ) ) then
  begin // save to BMP or BMPZ file without using intermediate TBitmap object
    SaveInBMPFormat( FileName, PixRect, AFileFmt );
    Exit;
  end; // // save to BMP or BMPZ file without using intermediate TBitmap object
}

  //***** Here: intermediate TBitmap object is used
  //      it's size should be less than 39 MB in WinXP !

  TmpBMP := TBitmap.Create;
  ImSize := N_RectSize( PixRect );
  TmpBMP.Width  := ImSize.X;
  TmpBMP.Height := ImSize.Y;
  FilePixFmt := CPixFmt;

  if (CPixFmt = pf32bit) or (CPixFmt = pf16bit) then FilePixFmt := pf24bit;
  TmpBMP.PixelFormat := FilePixFmt;

  N_CopyRect( TmpBMP.Canvas.Handle, Point(0,0), HMDC, PixRect );

  if FileName = '' then // Copy To Clipboard
    N_CopyBMPToClipboard( TmpBMP )
  else //***************** Save to File
//    N_SaveBMPObjToFile( TmpBMP, FileName, AFileFmt, APExtRFPar );

{
    case AFileFmt of

    imffBMP: begin //********** Save as BMP file
      TmpBMP.SaveToFile( FileName );
    end;

    imffGIF: begin //********** Save as GIF file
      GIF := TGifFile.Create;
      GIF.AddBitmap( TmpBMP );
      TmpBMP := nil; // TmpBMP is owned by GIF an will be freed in GIF.Free
      GIF.SaveToFile( FileName );
      GIF.Free;
    end;

    imffJPEG: begin //********** Save as JPG file
      JPG := TJPEGImage.Create;
      JPG.CompressionQuality := N_MEGlobObj.JPEGQuality;
      JPG.Assign( TmpBMP );
      JPG.SaveToFile( FileName );
      JPG.Free;
    end;

    end; // case AFileFmt of

  N_SetResToRasterFile( FileName, AFileFmt, WrkImageFilePar.IFPFResDPI );
}
  TmpBMP.Free;
end; //*** end of procedure TN_OCanvas.SaveCopyTo

//*********************************************** TN_OCanvas.SaveInBMPFormat ***
// Save ARectToSave fragment of Main Buf to given AFileName in BMP format,
// RectToSave.Right,Bottom = -1 means whole image (CurCRect)
//
procedure TN_OCanvas.SaveInBMPFormat( AFileName: string; ARectToSave: TRect;
                                               AFileFmt: TN_ImageFileFormat );
begin

// not implemented
end; //*** end of procedure TN_OCanvas.SaveInBMPFormat

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\AddSmallArc
//************************************************** TN_OCanvas.AddSmallArc ***
// Add to given integer array flags and points for approximating given Arc by 
// one Bezier segment
//
//     Parameters
// AInts     - resulting integer array
// ANumInts  - index of AInts first free element to add
// AX0       - Arc center X pixel coordinate
// AY0       - Arc center Y pixel coordinate
// ARX       - Arc X radius in pixels
// ARY       - Arc Y radius in pixels
// ABegAngle - start Arc angle in degree
// AArcAngle - Arc angle size in degree
// Result    - Returns number of elements in AInts array on output
//
function TN_OCanvas.AddSmallArc( var AInts: TN_IArray; ANumInts, AX0, AY0,
                      ARX, ARY: integer; ABegAngle, AArcAngle: float ): integer;
var
  i, FreeInd: integer;
  BegPoint, CurPoint: TPoint;
  A, B, C, S, CC, X, Y: double;
  XY: array [0..7] of double;

  function GetPixPoint( j: integer ): TPoint; // local
  begin
    Result.X := AX0 + Round(  XY[j*2]*CC - XY[j*2+1]*S );
    Result.Y := AY0 + Round( (XY[j*2]*S  + XY[j*2+1]*CC)*ARY/ARX );
  end; // local

begin
  if abs(AArcAngle) < 0.01 then // a precaution
  begin
    Result := ANumInts;
    Exit;
  end;

//  B := ARY * sin( -AArcAngle * N_PI / 180 );
  B := ARX * sin( -AArcAngle * N_PI / 180 );
  C := ARX * cos( -AArcAngle * N_PI / 180 );
  A := ARX - C;

  X := A * 4 / 3;
  Y := B - X * (ARX - A) / B;

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

  BegPoint := GetPixPoint( 0 );
  if Length( AInts ) < (ANumInts+12) then
    SetLength( AInts, N_NewLength( ANumInts+12 ) );

  if ANumInts < 3 then // really ANumInts = 0, add PT_MOVETO to BegPoint command
  begin
    AInts[0] := PT_MOVETO;
    AInts[1] := BegPoint.X;
    AInts[2] := BegPoint.Y;
    FreeInd := 3;
  end else // ANumInts >= 3, if last point (three last ints) is not equal
  begin    // to BegPoint, add PT_MOVETO to BegPoint command
    FreeInd := ANumInts;
    if (abs(AInts[ANumInts-2] - BegPoint.X)>1) or
       (abs(AInts[ANumInts-1] - BegPoint.Y)>1)  then // last point <> BegPoint
    begin
      AInts[FreeInd]   := PT_MOVETO;
      AInts[FreeInd+1] := BegPoint.X;
      AInts[FreeInd+2] := BegPoint.Y;
      Inc( FreeInd, 3 );
    end;
  end;

  for i := 1 to 3 do
  begin
    CurPoint := GetPixPoint( i );
    AInts[FreeInd]   := PT_BEZIERTO;
//    AInts[FreeInd]   := PT_LINETO; // debug
    AInts[FreeInd+1] := CurPoint.X;
    AInts[FreeInd+2] := CurPoint.Y;
    Inc( FreeInd, 3 );
  end; // for i := 1 to 3 do

  Result := FreeInd;
end; // procedure TN_OCanvas.AddSmallArc

const N_MaxArcAngle = 45.0; // approximating (Ellips-Bezier) error is about 0.0004%

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\AddArc
//******************************************************* TN_OCanvas.AddArc ***
// Add to given integer array flags and points for approximating given Arc by 
// several Bezier segments
//
//     Parameters
// AInts     - resulting integer array
// ANumInts  - index of AInts first free element to add
// AX0       - Arc center X pixel coordinate
// AY0       - Arc center Y pixel coordinate
// ARX       - Arc X radius in pixels
// ARY       - Arc Y radius in pixels
// ABegAngle - start Arc angle in degree
// AArcAngle - Arc angle size in degree
// Result    - Returns number of elements in AInts array on output
//
function TN_OCanvas.AddArc( var AInts: TN_IArray;  ANumInts, AX0, AY0,
                      ARX, ARY: integer; ABegAngle, AArcAngle: float ): integer;
var
  i, NumArcs: integer;
begin
  if abs(AArcAngle) <= N_MaxArcAngle then
    Result := AddSmallArc( AInts, ANumInts, AX0, AY0, ARX, ARY, ABegAngle, AArcAngle )
  else
  begin
    NumArcs := Round( Floor( abs(AArcAngle) / N_MaxArcAngle ) );
    Result := ANumInts;
    for i := 0 to NumArcs-1 do
    begin
      Result := AddSmallArc( AInts, Result, AX0, AY0, ARX, ARY,
                                        ABegAngle + i*(AArcAngle/NumArcs),
                                        AArcAngle/NumArcs );
    end; // for i := 0 to NumArcs-1 do
  end;
end; // procedure TN_OCanvas.AddArc

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\AddPieSegment
//************************************************ TN_OCanvas.AddPieSegment ***
// Add to given integer array flags and points for approximating given Pie 
// Segment Border and two additional segments - Pie Serment Radiuses (9 
// additional integers) by several Bezier segments
//
//     Parameters
// AInts           - resulting integer array
// ANumInts        - index of AInts first free element to add
// AX0             - Arc center X pixel coordinate
// AY0             - Arc center Y pixel coordinate
// ARX             - Arc X radius in pixels
// ARY             - Arc Y radius in pixels
// ABegAngle       - start Arc angle in degree
// AArcAngle       - Arc angle size in degree
// Result          - Returns number of elements in AInts array on output, 
//                   counting only Pie Segment Border
// ( AInts[Result] - AInts[Result+8] - two additional segments)
//
function TN_OCanvas.AddPieSegment( var AInts: TN_IArray; ANumInts, AX0, AY0,
                      ARX, ARY: integer; ABegAngle, AArcAngle: float ): integer;
var
  BegInd: integer;
begin
  BegInd := ANumInts;
  Result := AddArc( AInts, ANumInts, AX0, AY0, ARX, ARY, ABegAngle, AArcAngle );
  if Result = ANumInts then Exit; // Arc was not added

  if Length( AInts ) < (Result+15) then
    SetLength( AInts, N_NewLength( Result+15 ) );

  AInts[Result]   := PT_LINETO;
  AInts[Result+1] := AX0;
  AInts[Result+2] := AY0;

  AInts[Result+3] := PT_LINETO;
  AInts[Result+4] := AInts[BegInd+1];
  AInts[Result+5] := AInts[BegInd+2];

  //***** Pie Segment Border is finished, add two additional radiuses

  AInts[Result+6] := PT_MOVETO;
  AInts[Result+7] := AInts[Result-2];
  AInts[Result+8] := AInts[Result-1];

  AInts[Result+9]  := PT_LINETO;
  AInts[Result+10] := AX0;
  AInts[Result+11] := AY0;

  AInts[Result+12] := PT_LINETO;
  AInts[Result+13] := AInts[BegInd+1];
  AInts[Result+14] := AInts[BegInd+2];

  Inc( Result, 6 );
end; // procedure TN_OCanvas.AddPieSegment

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\AddPieFragment
//*********************************************** TN_OCanvas.AddPieFragment ***
// Add to given integer array flags and points for approximating given Pie 
// Fragment Border
//
//     Parameters
// AInts      - resulting integer array
// ANumInts   - index of AInts first free element to add
// AX0        - Arc center X pixel coordinate
// AY0        - Arc center Y pixel coordinate
// ARX        - Arc X radius in pixels
// ARY        - Arc Y radius in pixels
// ABegAngle  - start Arc angle in degree
// AArcAngle  - Arc angle size in degree
// AScaleCoef - Arc Radius scale cofficient
// Result     - Returns number of elements in AInts array on output
//
// AScaleCoef = 0 means PieSegment, otherwise it is used for calculating 
// internal arc of PieFragment ( PieFragment is fragment of elliptical ring)
//
// AArcAngle = 0 means that AArcAngle = 360 degree (PieFragment is ellipse)
//
function TN_OCanvas.AddPieFragment( var AInts: TN_IArray; ANumInts, AX0, AY0,
          ARX, ARY: integer; ABegAngle, AArcAngle, AScaleCoef: float ): integer;
var
  BegInd1, BegInd2: integer;
begin
  if (AArcAngle = 0) or (AArcAngle >=360) then // Add full Ellipse coords
  begin
    Result := AddArc( AInts, ANumInts, AX0, AY0, ARX, ARY, ABegAngle, 360 );
    Exit;
  end;

  if AScaleCoef <= 0 then // Add PieSegment
  begin
    Result := AddPieSegment( AInts, ANumInts, AX0, AY0, ARX, ARY, ABegAngle, AArcAngle );
    Exit;
  end;

  //***** Add fragment of elliptical ring

  BegInd1 := ANumInts; // BegPoint of first Arc

  Result := AddArc( AInts, ANumInts, AX0, AY0, ARX, ARY, ABegAngle, AArcAngle );
  if Result = ANumInts then Exit; // Arc was not added

  BegInd2 := Result + 3; // BegPoint of second Arc

  // reserve place for LineTo command and add second Arc
  Result := AddArc( AInts, BegInd2, AX0, AY0, Round(ARX*AScaleCoef),
                    Round(ARY*AScaleCoef), ABegAngle+AArcAngle, -AArcAngle );

  if Length( AInts ) < (Result+3) then
    SetLength( AInts, N_NewLength( Result+3 ) );

  AInts[Result]   := PT_LINETO; // last segment - from second Arc to first Arc
  AInts[Result+1] := AInts[BegInd1+1];
  AInts[Result+2] := AInts[BegInd1+2];
  Inc( Result, 3 );

  AInts[BegInd2-3] := PT_LINETO; // internal segment - from first Arc to second Arc
  AInts[BegInd2-2] := AInts[BegInd2+1];
  AInts[BegInd2-1] := AInts[BegInd2+2];
end; // procedure TN_OCanvas.AddPieFragment

//******************************************** TN_OCanvas.AddPieSegmSide ***
// Add to given Integer Array Flags and points for "Vertical" (shadow) side
// Border of given Pie Segment and two verical segments (12 additional ints)
// Return Number of Ints in AInts Array on output countiong only Side Border
// ( AInts[Result] - AInts[Result11] - two additional segments)
//
// should be: AArcAngle > 0 and 0 <= ABegAngle <= 360 (to simplify calculating)
//
function TN_OCanvas.AddPieSegmSide( var AInts: TN_IArray;
                                    ANumInts, AX0, AY0, ARX, ARY, DY: integer;
                   ABegAngle, AArcAngle: float; var AAddAngle: float ): integer;
var
  BegInd: integer;
  EndPoint: TPoint;
begin
  if abs(AArcAngle) < 0.001 then // a precaution
  begin
    Result := ANumInts;
    Exit;
  end;

  if AArcAngle < 0 then // force AArcAngle > 0
  begin
    AArcAngle := -AArcAngle;
    ABegAngle := ABegAngle - AArcAngle;
  end;

  ABegAngle := N_Get0360Angle( ABegAngle );

  if ABegAngle < 180 then
  begin
    AArcAngle := AArcAngle - (180 - ABegAngle);
    ABegAngle := 180;
  end;

  Result := ANumInts;
  if AArcAngle <= 0 then Exit; // no "Vertical" side

  if (ABegAngle + AArcAngle) > 540 then // special case - two separate parts
    AAddAngle := 450 - ABegAngle
  else
    AAddAngle := 0; // one part

  if (ABegAngle + AArcAngle) > 360 then
    AArcAngle := 360 - ABegAngle;

  //***** Here: 180 <= ABegAngle, ABegAngle+AArcAngle <= 360
  //              0 <= AArcAngle <= 180

  BegInd := ANumInts;
  Result := AddArc( AInts, ANumInts, AX0, AY0, ARX, ARY, ABegAngle, AArcAngle );

  if Result = ANumInts then Exit; // Arc was not created

  EndPoint.X := AInts[Result-2];
  EndPoint.Y := AInts[Result-1];

  if Length( AInts ) < (Result+3) then
    SetLength( AInts, N_NewLength( Result+3 ) );

  AInts[Result]   := PT_LINETO;
  AInts[Result+1] := AInts[Result-2];
  AInts[Result+2] := AInts[Result-1] + DY;

  Result := AddArc( AInts, Result+3, AX0, AY0+DY, ARX, ARY,
                                              ABegAngle+AArcAngle, -AArcAngle );
  if Length( AInts ) < (Result+15) then
    SetLength( AInts, N_NewLength( Result+15 ) );

  AInts[Result]   := PT_LINETO;
  AInts[Result+1] := AInts[BegInd+1];
  AInts[Result+2] := AInts[BegInd+2];

  //***** "Vertical" (shadow) side Border is finished,
  //      Add two additional vertical Lines (12 integers)

  AInts[Result+3] := PT_MOVETO;
  AInts[Result+4] := AInts[BegInd+1];
  AInts[Result+5] := AInts[BegInd+2];

  AInts[Result+6] := PT_LINETO;
  AInts[Result+7] := AInts[BegInd+1];
  AInts[Result+8] := AInts[BegInd+2] + DY;

  AInts[Result+9]  := PT_MOVETO;
  AInts[Result+10] := EndPoint.X;
  AInts[Result+11] := EndPoint.Y;

  AInts[Result+12] := PT_LINETO;
  AInts[Result+13] := EndPoint.X;
  AInts[Result+14] := EndPoint.Y + DY;

  Inc( Result, 3 );
end; // function TN_OCanvas.AddPieSegmSide

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_OCanvas\GetFontLLWSize
//*********************************************** TN_OCanvas.GetFontLLWSize ***
// Get font size in LLW by given string with font size in HTML format
//
//     Parameters
// AHTMLSize   - string with font size in HTML format
// ASrcLLWSize - source font size in LLW (needed if AHTMLSize is in %)
//
// Font size can be given as 12pt, 12px, 12.1mm, 150%, 12 (means 12px)
//
function TN_OCanvas.GetFontLLWSize( AHTMLSize: string; ASrcLLWSize: float ): float;
var
  LastInd: integer;
  Val: float;
  Units: string;
begin
  AHTMLSize := Trim( AHTMLSize );
  Result := ASrcLLWSize;
  LastInd := Length( AHTMLSize );
  Units := '';

  if AHTMLSize[LastInd] = '%' then
  begin
    Val := N_ScanFloat( AHTMLSize );
    Result := ASrcLLWSize * Val / 100;
    Exit;
  end else if LastInd > 2 then
    Units := UpperCase( Copy( AHTMLSize, LastInd-1, 2 ) );

  Val := N_ScanFloat( AHTMLSize );

  if Units = 'MM' then
    Result := 72 * Val / 25.4
  else if Units = 'PX' then
    Result := Val / CurLLWPixSize;

end; // function TN_OCanvas.GetFontLLWSize


//********** TN_PatternPalette class methods  **************

//********************************************** TN_PatternPalette.Create ***
//
constructor TN_PatternPalette.Create( BitMapWidth, BitMapHeight: integer;
                                                       PixFmt: TPixelFormat );
var
  i: integer;
begin
//  Assert( (PixFmt = pf16bit) or (PixFmt = pf32bit),
//                                     'Only 16 or 32 bit PixFmt is allowed!' );
  if (PixFmt <> pf16bit) and (PixFmt <> pf32bit) then
    raise Exception.Create( 'Only 16 or 32 bit PixFmt is allowed!' );
  SetLength( PatPalEntries, 256 );
  PatPalEntries[0].PatWidth := -1;
  PatPalEntries[0].PatColor := $000000;
  PatPalEntries[1].PatWidth := -1;
  PatPalEntries[1].PatColor := $FFFFFF;
  if PixFmt = pf16bit then PatPalEntries[1].PatColor := $FFFF;

  for i := 2 to 255 do PatPalEntries[i].PatWidth := 0;  // free entry flag

  PatternsBitMap := TBitMap.Create;
  PatternsBitMap.Width  := BitMapWidth;
  PatternsBitMap.Height := BitMapHeight;
  PatternsBitMap.PixelFormat := PixFmt;
  NumEntries := 2;

  OfsFreeX := 0;
  OfsFreeY := 0;
  RowHeight := 0;
//!!  OCanv := TN_OCanvas.Create( PatternsBitMap );
end; // end_of constructor TN_PatternPalette.Create

//********************************************* TN_PatternPalette.Destroy ***
//
destructor TN_PatternPalette.Destroy;
begin
  OCanv.Free;
  PatPalEntries := nil;
  PatternsBitMap.Free;
end; // end_of destructor TN_PatternPalette.Destroy

//*********************************** TN_PatternPalette.ClearAllEntries ***
// Clear All Pattern Palette Entry (PatternsBitMap remains same size)
//
procedure TN_PatternPalette.ClearAllEntries();
var
  i: integer;
begin
  for i := 2 to 255 do PatPalEntries[i].PatWidth := 0;  // free entry flag
  NumEntries := 2;
  OfsFreeX := 0;
  OfsFreeY := 0;
  RowHeight := 0;
end; // procedure TN_PatternPalette.ClearAllEntries

//************************************** TN_PatternPalette.CreateEntry ***
// create Pattern Palette Entry
//
// PatInd     - Pattern Palette Index to create
// APatWidth  - Pattern Width  in pixels
// APatHeight - Pattern Height in pixels
// FillColor  - Pattern Background Color (usually 1 (white) for monochrome patterns)
//
procedure TN_PatternPalette.CreateEntry( PatInd, APatWidth, APatHeight,
                                                       FillColor: integer );
begin
//  Assert( (PatInd >= 0) and (PatInd <= 255), 'Bad Pattern Index' );
  if (PatInd < 0) or (PatInd > 255) then
    raise Exception.Create( 'Bad Pattern Index!' );

  if APatWidth <= 0 then // APatWidth = 0 or -1
    with PatPalEntries[PatInd] do
    begin
      PatWidth := APatWidth;
      PatColor := FillColor;
      Exit;
    end; // with PatPalEntries[PatInd] do

  // several pases thru Panel Objects Tree should not cause
  // multiple Entry creation!

  if PatPalEntries[PatInd].PatWidth > 0 then Exit; // already created

  if (OfsFreeX + APatWidth) > PatternsBitMap.Width then // next row of patterns
  begin
    OfsFreeX := 0;
    OfsFreeY := OfsFreeY + RowHeight;
    RowHeight := 0;
  end;

  if (OfsFreeY + APatHeight) > PatternsBitMap.Height then // inc BitMap height
    PatternsBitMap.Height := OfsFreeY + APatHeight + 20;

  if RowHeight < APatHeight then RowHeight := APatHeight; // inc Row height

  with PatPalEntries[PatInd] do
  begin
    PatRect.Left := OfsFreeX;
    PatRect.Top  := OfsFreeY;
    PatRect.Right  := OfsFreeX + APatWidth - 1;
    PatRect.Bottom := OfsFreeY + APatHeight - 1;
    Inc( OfsFreeX, APatWidth );
    PatWidth  := APatWidth;
    PatHeight := APatHeight;
    PatOCanv := OCanv;
    PatOCanv.SetPClipRect( PatRect );
    PatOCanv.SetBrushAttribs( FillColor );
    PatOCanv.DrawPixFilledRect( PatRect ); // clear by given color
  end; // with PatPalEntries[PatInd] do
end; // procedure TN_PatternPalette.CreateEntry

//************************************** TN_PatternPalette.DrawLines ***
// Draw Lines in given Pattern
//
// PatInd - Pattern Palette Index to create
// LColor - Line Color (usually 0 (black) for monochrome patterns)
// LWidth - Line Width in pixels
// LStepX - Step between Lines in X direction in pixels
// LStepY - Step between Lines in Y direction in pixels
//          (positive LStepY means slash like (/) lines
//          (negative LStepY means backslash like (\) lines
// LOfs   - initial Line relative position inside Line Steps
//          (from 0.0 to 1.0)
//
procedure TN_PatternPalette.DrawLines( PatInd, LColor, LWidth, LStepX,
                                           LStepY: integer; LOfs: double );
var
  LOfsX, LOfsY, LWidthX, LWidthY, ALStepY: integer;
  DLStep: double;
  X0, Y0: integer;
  LC: TN_IPArray; // Line Coords
begin
//  Assert( (PatInd >= 0) and (PatInd <= 255), 'Bad Pattern Index' );
  if (PatInd < 0) or (PatInd > 255) then
    raise Exception.Create( 'Bad Pattern Index!' );
  with PatPalEntries[PatInd] do
  begin

  if PatWidth <= 0 then // empty entry
  begin
    N_WarnByMessage( ' Patern Palette Entry ' + IntToStr(PatInd) +
                     ' was not created!' );
    Exit;
  end;

  SetLength( LC, 5 );
  ALStepY := Abs(LStepY);
  LOfsX := Round( LOfs*LStepX );
  LOfsY := Round( LOfs*ALStepY );
  X0 := PatRect.Left + LOfsX;
  DLStep := Round( Sqrt( LStepX*LStepX + LStepY*LStepY) );

  PatOCanv.SetPenAttribs( LColor, 0 );
  PatOCanv.SetBrushAttribs( LColor );
  PatOCanv.SetPClipRect( PatRect );

  if LStepX = 0 then // Horizontal lines
  begin
//    Assert( (PatHeight mod ALStepY) = 0, 'Bad LStepY!' );
    if (PatHeight mod ALStepY) <> 0 then
      raise Exception.Create( 'Bad Bad LStepY!' );
    Y0 := PatRect.Top  + LOfsY;

    while Y0 <= PatRect.Bottom do
    begin
      LC[0].X := PatRect.Left;
      LC[0].Y := Y0;

      LC[1].X := PatRect.Right;
      LC[1].Y := Y0;

      LC[2].X := PatRect.Right;
      LC[2].Y := Y0 + LWidth - 1;

      LC[3].X := PatRect.Left;
      LC[3].Y := Y0 + LWidth - 1;

      LC[4] := LC[0];
      PatOCanv.DrawPixPolygon( LC, 5 );
      Inc( Y0, ALStepY );
    end; // while True do

  end else if LStepY = 0 then // Vertical lines
  begin
//    Assert( (PatWidth mod LStepX)  = 0, 'Bad LStepX!' );
    if (PatWidth mod LStepX) <> 0 then
      raise Exception.Create( 'Bad Bad LStepX!' );

    while X0 <= PatRect.Right do
    begin
      LC[0].X := X0;
      LC[0].Y := PatRect.Top;

      LC[1].X := X0 + LWidth - 1;
      LC[1].Y := PatRect.Top;

      LC[2].X := X0 + LWidth - 1;
      LC[2].Y := PatRect.Bottom;

      LC[3].X := X0;
      LC[3].Y := PatRect.Bottom;

      LC[4] := LC[0];
      PatOCanv.DrawPixPolygon( LC, 5 );
      Inc( X0, LStepX );
    end; // while True do

  end else // any slanting line (LStepX > 0, LStepY > 0)
  begin
//    Assert( (PatWidth mod LStepX)  = 0, 'Bad LStepX!' );
//    Assert( (PatHeight mod LStepY) = 0, 'Bad LStepY!' );
    if (PatWidth mod LStepX) <> 0 then
      raise Exception.Create( 'Bad Bad LStepX!' );
    if (PatHeight mod ALStepY) <> 0 then
      raise Exception.Create( 'Bad Bad LStepY!' );

    LWidthX := Round( LWidth * DLStep / ALStepY );
    LWidthY := Round( LWidth * DLStep / LStepX );

    if LStepY > 0 then // "slash like" (/) slanting line (LStepY > 0)
    begin
      Y0 := PatRect.Top  + LOfsY;
      while (X0 <= PatRect.Right+PatWidth) or
            (Y0 <= PatRect.Bottom+PatHeight) do
      begin
        LC[0].X := X0;
        LC[0].Y := PatRect.Top;

        LC[1].X := X0 + LWidthX - 1;
        LC[1].Y := PatRect.Top;

        LC[2].X := PatRect.Left;
        LC[2].Y := Y0 + LWidthY - 1;

        LC[3].X := PatRect.Left;
        LC[3].Y := Y0;

        LC[4] := LC[0];
        PatOCanv.DrawPixPolygon( LC, 5 );
        Inc( X0, LStepX );
        Inc( Y0, LStepY );
      end; // while True do
    end else // "back slash like" (\) slanting line (LStepY < 0)
    begin
      Y0 := PatRect.Bottom - LOfsY;
      while (X0 <= PatRect.Right+PatWidth) or
            (Y0 >= PatRect.Top-PatHeight)    do
      begin
        LC[0].X := X0;
        LC[0].Y := PatRect.Bottom;

        LC[1].X := X0 + LWidthX - 1;
        LC[1].Y := PatRect.Bottom;

        LC[2].X := PatRect.Left;
        LC[2].Y := Y0 - LWidthY + 1;

        LC[3].X := PatRect.Left;
        LC[3].Y := Y0;

        LC[4] := LC[0];
        PatOCanv.DrawPixPolygon( LC, 5 );
        Inc( X0, LStepX );
        Inc( Y0, LStepY );
      end; // while True do
    end; // else // "back slash like" (\) slanting line (LStepY < 0)

  end; // else // any slanting line (LStepX > 0, LStepY > 0)

  LC := nil;
  end; // with PatPalEntries[PatInd] do
end; // procedure TN_PatternPalette.DrawLines

//************************************** TN_PatternPalette.DrawGray ***
// fill given Pattern by given Gray level (0-Black, 255-White)
//
// PatInd - Pattern Palette Index to create
// Style  - Gray Pattern Style:
//          =0 - one big black dot in upper left corner of whole GrayDot
//          =1 - fine gray pattern
// GrayValue   - Gray intensity ( from 0 (black) to 255 (white) )
// GrayDotSize - GrayDot Size in pixels (for Style=0 only)
//
procedure TN_PatternPalette.DrawGray( PatInd, Style, GrayValue, GrayDotSize: integer );
var
  ix, iy, BlackDotSize: integer;
  BMP1: TBitMap;
begin
//  Assert( (PatInd >= 0) and (PatInd <= 255), 'Bad Pattern Index' );
  if (PatInd < 0) or (PatInd > 255) then
    raise Exception.Create( 'Bad Pattern Index!' );

  with PatPalEntries[PatInd] do
  begin
    if PatWidth <= 0 then // empty entry
    begin
      N_WarnByMessage( ' Patern Palette Entry ' + IntToStr(PatInd) +
                       ' was not created!' );
      Exit;
    end;

    PatOCanv.SetPClipRect( PatRect );
    case Style of

    0: begin  // one big black dot in upper left corner of whole GrayDot
      BlackDotSize := Round( Sqrt( (255-GrayValue)/255 ) * GrayDotSize );

      for iy := PatRect.Top  to PatRect.Bottom  do
      for ix := PatRect.Left to PatRect.Right   do
      begin
        if ((ix mod GrayDotSize) < BlackDotSize) and
           ((iy mod GrayDotSize) < BlackDotSize)     then
//!!          PatOCanv.HMDC.Pixels[ix,iy] := 0; // black color
      end; // for ix, for iy
    end; // mode 0

    1: begin  // fine gray pattern
      BMP1 := TBitMap.Create;
      BMP1.Width  := PatWidth;
      BMP1.Height := PatHeight;
      BMP1.PixelFormat := pf1bit;
      BMP1.Canvas.Brush.Color := (GrayValue shl 16) or
                                 (GrayValue shl 8)  or GrayValue;
      BMP1.Canvas.FillRect( Rect( 0, 0, PatWidth, PatHeight ) );
//      BMP1.SaveToFile( 'a_g1.bmp' ); // debug
//      PatOCanv.MainBitMap.SaveToFile( 'a_g2.bmp' ); // debug
      N_CopyRect( PatOCanv.HMDC, PatRect.TopLeft,
      BMP1.Canvas.Handle, Rect( 0, 0, PatWidth-1, PatHeight-1 ) );
//      PatOCanv.MainBitMap.SaveToFile( 'a_g3.bmp' ); // debug
      BMP1.Free;
    end; // mode 1

    end; // case Style of

  end; // with PatPalEntries[PatInd] do
end; // procedure TN_PatternPalette.DrawGray

//************************************** TN_PatternPalette.ConvRGBColors ***
// Convert Pixels RGB colors in given Rect of given BitMap (High or True Color)
// using given Color Palette and self Pattern Palette
// ( BitMap should have same PixelFormat as Pattern BitMap )
//
// BitMap   - BitMap to convert (on input and output)
// ConvRect - Rect to convert
// PhaseX   - X Pattern Phase  ( to add to BitMap pixel coords to calculate
// PhaseY   - Y Pattern Phase    pattern's pixel coords )
// AbsentColor  - used if original color was not found in Color Palette,
//                =-1 means do not change these pixels
// NumColors    - Number of Colors in ColorPalette
// ColorPalette - RGB 32 bit Colors, index in Color Palette used
//                as index in Pattern Palette
//
procedure TN_PatternPalette.ConvRGBColors( BitMap: TBitMap; ConvRect: TRect;
                               PhaseX, PhaseY, AbsentColor: integer;
                           var NumColors: integer; ColorPalette: TN_IArray );

var
  i, ix, iy, CurColor, PatIx, PatIy, PrevPatIy: integer;
  PScanLine, PPatScanLine, PTmp: TN_BytesPtr;
  WrkColors: TN_IArray;
  label Found16, Found32;
begin
//  Assert( BitMap.PixelFormat = PatternsBitMap.PixelFormat,
//          'BitMap should have same PixelFormat as Pattern BitMap!' );
  if BitMap.PixelFormat <> PatternsBitMap.PixelFormat then
    raise Exception.Create( 'BitMap should have same PixelFormat as Pattern BitMap!' );
  SetLength( WrkColors, 256 );
  PrevPatIy := -1;
  PPatScanLine := nil; // to avoid warning

//*** Add later 8bit case!

  if BitMap.PixelFormat = pf32bit then // TrueColor BitMap
  begin
    if AbsentColor >= 0 then AbsentColor := N_32ToR32BitColor( AbsentColor );
    for i := 0 to NumColors-1 do
    begin
      WrkColors[i] := N_32ToR32BitColor( ColorPalette[i] ) or (i shl 24);
    end;

    for iy := ConvRect.Top  to ConvRect.Bottom do
    begin
    PScanLine := TN_BytesPtr(BitMap.ScanLine[iy]);
    PTmp := PScanLine + (ConvRect.Left shl 2) - 4;
    for ix := ConvRect.Left to ConvRect.Right do
    begin
  //    CurColor := $0000FF; // debug
  //    CurColor := BitMap.Canvas.Pixels[ix,iy]; // too slow!!
  //    PTmp := PScanLine + (ix shl 2);
      Inc( PTmp, 4 );
      CurColor := TN_PUInt4(PTmp)^;

      if (CurColor = 0) or (CurColor = $FFFFFF) then // black or white pixel
        Continue
      else // not black or white, try to find it in WrkColors
      begin

        //***** later reorder WrkColors to speed up searching

        for i := 0 to NumColors-1 do
        begin
          if CurColor = (WrkColors[i] and $FFFFFF) then goto Found32;
        end; // for i := 0 to NumColors-1 do

        //*** Here: CurColor was not found in WrkColors[]

        if AbsentColor = -2 then // add CurColor to Palette
        begin
//          Assert( NumColors < 255, 'Too many colors!' );
          if NumColors >= 255 then
            raise Exception.Create( 'Too many colors!' );
          i := NumColors;
          Inc(NumColors);
          WrkColors[i] := CurColor or (i shl 24);
          ColorPalette[i] := N_32ToR32BitColor( CurColor );
          goto Found32;
        end else if AbsentColor = -1 then
          Continue
        else // change CurColor by given AbsentColor
          TN_PUInt4(PTmp)^ := AbsentColor;

        Continue; // to next pixel

        Found32: //*** Here: i is needed Pattern Palette Index

        with PatPalEntries[i] do
        begin
          if PatWidth = 0 then // PatPal Entry is not defined
          begin
            if AbsentColor >= 0 then TN_PUInt4(PTmp)^ := AbsentColor;
          end else //***************** PatPal Entry is OK
          begin
            PatIx := (ix+PhaseX) mod PatWidth  + PatRect.Left;
            PatIy := (iy+PhaseY) mod PatHeight + PatRect.Top;
            if PrevPatIy <> PatIy then
            begin
              PrevPatIy := PatIy;
//!!              PPatScanLine := TN_BytesPtr(PatOCanv.MainBitMap.ScanLine[PatIy]);
            end;
            TN_PUInt4(PTmp)^ := TN_PUInt4(PPatScanLine+(PatIx shl 2) )^;
//            TN_PUInt4(PTmp)^ := TN_PUInt4(TN_BytesPtr(
//                      PatOCanv.MainBitMap.ScanLine[PatIy])+(PatIx shl 2) )^;
          end; // else //***************** PatPal Entry is OK
        end; // with PatPalEntries[i] do
      end; // else // not black or white, try to find it in WrkColors
    end; // for ix
    end; // for iy

  end else //******************** HighColor BitMap
  begin
    Assert( BitMap.PixelFormat = pf16bit, 'Only 32 or 16 bit BMP is allowed!' );
    if AbsentColor >= 0 then AbsentColor := N_32ToR16BitColor( AbsentColor );

    for i := 0 to NumColors-1 do
    begin
      WrkColors[i] := N_32ToR16BitColor( ColorPalette[i] ) or (i shl 24);
    end;

    for iy := ConvRect.Top  to ConvRect.Bottom do
    begin
    PScanLine := TN_BytesPtr(BitMap.ScanLine[iy]);
    PTmp := PScanLine + (ConvRect.Left shl 1) - 2;
    for ix := ConvRect.Left to ConvRect.Right do
    begin
  //    CurColor := $0000FF; // debug
  //    CurColor := BitMap.Canvas.Pixels[ix,iy]; // too slow!!
      Inc( PTmp, 2 );
      CurColor := TN_PUInt2(PTmp)^;

      if (CurColor = 0) or (CurColor = $FFFF) then // black or white pixel
        Continue
      else // not black or white, try to find it in WrkColors
      begin
        //***** later reorder WrkColors to speed up searching

        for i := 0 to NumColors-1 do
        begin
          if CurColor = (WrkColors[i] and $FFFF) then goto Found16;
        end; // for i := 0 to NumColors-1 do

        //*** Here: CurColor was not found in WrkColors[]

        if AbsentColor = -2 then // add CurColor to Palette
        begin
          Assert( NumColors < 255, 'Too many colors!' );
          i := NumColors;
          Inc(NumColors);
          WrkColors[i] := CurColor or (i shl 24);
          ColorPalette[i] := N_16ToR32BitColor( CurColor );
          goto Found16;
        end else if AbsentColor = -1 then
          Continue
        else // change CurColor by given AbsentColor
          TN_PUInt2(PTmp)^ := AbsentColor;

        Continue; //  to next pixel

        Found16: //*** Here: i is needed Pattern Palette Index

        with PatPalEntries[i] do
        begin
          if PatWidth = 0 then // PatPal Entry is not defined
          begin
            if AbsentColor >= 0 then TN_PUInt2(PTmp)^ := AbsentColor;
          end else //***************** PatPal Entry is OK
          begin
            PatIx := (ix+PhaseX) mod PatWidth  + PatRect.Left;
            PatIy := (iy+PhaseY) mod PatHeight + PatRect.Top;
            if PrevPatIy <> PatIy then
            begin
              PrevPatIy := PatIy;
//!!              PPatScanLine := TN_BytesPtr(PatOCanv.MainBitMap.ScanLine[PatIy]);
            end;
            TN_PUInt2(PTmp)^ := TN_PUInt2(PPatScanLine+(PatIx shl 1) )^;
//            TN_PUInt2(PTmp)^ := TN_PUInt2(TN_BytesPtr(
//                     PatOCanv.MainBitMap.ScanLine[PatIy])+(PatIx shl 1) )^;
          end; // else //***************** PatPal Entry is OK
        end; // with PatPalEntries[i] do
      end; // else // not black or white, try to find it in WrkColors
    end; // for ix
    end; // for iy

  end; // else //******************** HighColor BitMap

  WrkColors := nil;
end; // procedure TN_PatternPalette.ConvRGBColors


//************************** TN_Metafile methods ***************************

//******************************************* TN_Metafile.GetFromFile ***
// Get MetaFile contenet from given file
//
procedure TN_Metafile.GetFromFile( FileName: string );
var
  HMF: HDC;
  Size: integer;
//  MFHeader: EnhmetaHeader; // for debug
begin
  HMF := GetEnhMetafile( PChar(FileName) );
  Size := GetEnhMetafileBits( HMF, 0, nil );
  MFBuf := nil;
  SetLength( MFBuf, Size );
  Size := GetEnhMetafileBits( HMF, 0, nil );
  Assert( Size > 0, 'Bad HMF' );
  GetEnhMetafileBits( HMF, Size, @MFBuf[0] );
  PMFHeader := PEnhMetaHeader(@MFBuf[0]);
  CRInd  := 0;
  CRPtr  := TN_BytesPtr(@MFBuf[0]);
  CRType := PMFHeader^.iType;
  CRSize := PMFHeader^.nSize;
//  move( PMFHeader^, MFHeader, Sizeof(MFHeader) ); // for debug
  DeleteEnhMetafile( HMF );
end; // procedure TN_Metafile.GetFromFile

//******************************************* TN_Metafile.GetNextRecord ***
// Get next MetaFile record
//
// RPtr  - pointer to beg of next MetaFile Record
// RType - MetaFile Record Type (see Windows.16400)
//
procedure TN_Metafile.GetNextRecord( out RPtr: TN_BytesPtr; out RType: integer );
begin
  if CRInd = (PMFHeader^.nRecords-1) then // no more records
  begin
    RPtr := nil;
    RType := -1;
  end else
  begin
    Inc( CRPtr, CRSize );
    CRSize := PInteger(CRPtr+Sizeof(DWORD))^;
    Inc( CRInd );

    RPtr  := CRPtr;
    RType := PInteger(RPtr)^;
  end;
end; // procedure TN_Metafile.GetNextRecord

//********************* TN_RasterObj class methods  **********************

//************************************************ TN_RasterObj.Create ***
// Create empty Self by given Raster Type
//
constructor TN_RasterObj.Create( ARType: TN_RasterType );
begin
  InitRasterObj( ARType );
end; //*** end of Constructor TN_RasterObj.Create

//************************************************ TN_RasterObj.Create ***
// Create Self by given Raster
//
constructor TN_RasterObj.Create( APRaster: TN_PRaster );
begin
  InitRasterObj( APRaster^.RType );
  RR := APRaster^;
  PrepRDIBInfoBySelf(); // assign memory if needed and set self fields
end; //*** end of Constructor TN_RasterObj.Create

//************************************************ TN_RasterObj.Create ***
// Create Self by given Size and given Raster
//
constructor TN_RasterObj.Create( APRaster: TN_PRaster; AWidth, AHeight: integer );
begin
  InitRasterObj( APRaster^.RType );
  RR := APRaster^;
  RR.RWidth  := AWidth;
  RR.RHeight := AHeight;
  PrepRDIBInfoBySelf(); // assign memory if needed and set self fields
end; //*** end of Constructor TN_RasterObj.Create

//************************************************ TN_RasterObj.Create ***
// Create Self by given Raster Type and BMP or BMPZ AFileName
// ATranspColor = -2 means using GIF transparent color if exists
//
constructor TN_RasterObj.Create( ARType: TN_RasterType; AFileName: string;
                                 ATranspColor: integer = N_EmptyColor;
                                 APixFmt: TPixelFormat = pfDevice );
begin
  with RR do
  begin
    InitRasterObj( ARType );
    RTranspColor := ATranspColor;
    RPixFmt := APixFmt;
    LoadRObjFromFile( AFileName );
  end;
end; //*** end of Constructor TN_RasterObj.Create

//************************************************ TN_RasterObj.Create ***
// Create Self by given OCanv
//
constructor TN_RasterObj.Create( AOCanv: TN_OCanvas );
begin
  with RR, AOCanv do
  begin
    InitRasterObj( rtOCanv );
    RWidth  := CCRSize.X;
    RHeight := CCRSize.Y;
    RPixFmt := CPixFmt;
    PRasterBytes := MPixPtr;
  end;
  PrepRDIBInfoBySelf(); // assign memory if needed and set self fields
end; //*** end of Constructor TN_RasterObj.Create

//************************************************ TN_RasterObj.Destroy ***
//
destructor TN_RasterObj.Destroy;
begin
  InitRasterObj( rtDefault ); // free all objects and memory
  Inherited;
end; //*** end of destructor TN_RasterObj.Destroy

//************************************** TN_RasterObj.InitRasterObj  ***
// Clear all Self fields and set given ARType
// (free all memmory if it was assigned)
//
procedure TN_RasterObj.InitRasterObj( ARType: TN_RasterType );
begin
  with RR do
  begin
    RasterRA.Free();
    RasterBA := nil;

    RMaskRA.Free();
    RMaskBA := nil;

    RPalRA.Free();
    RPalIA := nil;

    RBMP.Free();

    FillChar( RR, Sizeof(RR), 0 );

    PRasterBytes := nil;
    RRasterSize  := 0;

    PMaskBytes := nil;
    RMaskSize  := 0;

    PPalColors := nil;
    RNumPalColors := 0;
    RDPI := N_ZFPoint;

    RType := ARType;
    RTranspColor := N_EmptyColor;
    RTranspIndex := -1;
  end; // with RR do
end; //*** end of procedure TN_RasterObj.InitRasterObj

//************************************** TN_RasterObj.PrepSelfFields  ***
// Prepare Self fields except (they should be already OK):
//   RWidth, RHeight, RPixFmt, RTranspColor, RNumPalColors
//
// set RRBytesInLine, RRLineSize, RasterSize, RMBytesInLine, RMLineSize, RMaskSize,
// assign memory, if not yet, for Raster Bytes, Mask Bytes and Palette,
// set pointers PRasterBytes, PMaskBytes, PPalColors
// (RDIBInfo and RTranspIndex are not set on output)
//
procedure TN_RasterObj.PrepSelfFields();
begin
  with RR do
  begin
    if RType = rtBMP then // Raster is TBitmap object, nothig should be done
      Exit;
{
    case RPixFmt of
    pf1bit:  RRBytesInLine := (RWidth-1) div 8 + 1;
    pf4bit:  RRBytesInLine := (RWidth-1) div 2 + 1;
    pf8bit:  RRBytesInLine := RWidth;
    pf16bit: RRBytesInLine := RWidth * 2;
    pf24bit: RRBytesInLine := RWidth * 3;
    pf32bit: RRBytesInLine := RWidth * 4;
    else
      Assert( False, 'Bad RPixFmt' );
    end; // case RPixFmt of

    RRLineSize := ((RRBytesInLine+3) shr 2) shl 2; // Lines should be DWord aligned
}
    N_PrepDIBLineSizes( RWidth, RPixFmt, epfBMP, RRBytesInLine, RRLineSize );
    RRasterSize := RRLineSize * RHeight;

    //***** assign place for Raster Bytes if needed
{
    if RType = rtRArray then // assign place in RArray
    begin
      if RasterRA = nil then
        RasterRA := K_RCreateByTypeName( 'Byte', RRasterSize+1 );
      PRasterBytes := TN_BytesPtr(TK_RArray(RasterRA).P(1));
    end else if RType = rtBArray then // assign place in TN_BArray
    begin
      if RasterBA = nil then
        SetLength( RasterBA, RRasterSize+1 );
      PRasterBytes := TN_BytesPtr(@RasterBA[1]);
    end else if RType = rtDefault then
      Assert( False, 'Bad RType' );
}
    //***** assign place for Mask Bytes if needed

    if (RTranspColor <> N_EmptyColor) and (RPixFmt >= pf16bit) then // Mask is needed
    begin
      RMBytesInLine := (RWidth-1) div 8 + 1;         // Mask BytesInLine
      RMLineSize := ((RMBytesInLine+3) shr 2) shl 2; // Mask Line Size (DWORD aligned)
      RMaskSize  := RMLineSize * RHeight;            // Mask Size in Bytes
{
      if RType = rtRArray then
      begin
        if RMaskRA = nil then
          RMaskRA := K_RCreateByTypeName( 'Byte', RMaskSize+1 );
        PMaskBytes := TN_BytesPtr(TK_RArray(RMaskRA).P(1));
      end else // if (RType = rtBArray) then
      begin
        if RMaskBA = nil then
          SetLength( RMaskBA, RMaskSize+1 );
        PMaskBytes := TN_BytesPtr(@RMaskBA[1]);
      end;
}
    end; // if ... then // Mask is needed

    PPalColors := nil; // a precaution
    if RNumPalColors = 0 then Exit; // No Palette, all done
{
    if RType = rtRArray then // assign place for Palette in RArray
    begin
      if RPalRA = nil then
        RPalRA := K_RCreateByTypeName( 'Integer', RNumPalColors );
      PPalColors := PInteger(TK_RArray(RPalRA).P);
    end else if RType = rtBArray then // assign place for Palette in TN_IArray
    begin
      if RPalIA = nil then
        SetLength( RPalIA, RNumPalColors );
      PPalColors := PInteger(@RPalIA[0]);
    end else if RType = rtDefault then
      Assert( False, 'Bad RType' );
}
  end; // with RR do
end; //*** end of procedure TN_RasterObj.PrepSelfFields

//************************************** TN_RasterObj.PrepSelfByRDIBInfo  ***
// Prepare Self fields by RDIBInfo (it should be already OK):
// set RWidth, RHeight, RPixFmt, RNumPalColors and call PrepSelFields method
//
procedure TN_RasterObj.PrepSelfByRDIBInfo();
begin
  with RR, RDIBInfo.bmi do
  begin
    RWidth  := biWidth;
    RHeight := Abs(biHeight);

    case biBitCount of
    1:  RPixFmt := pf1bit;
    4:  RPixFmt := pf4bit;
    8:  RPixFmt := pf8bit;
    16: RPixFmt := pf16bit;
    24: RPixFmt := pf24bit;
    32: RPixFmt := pf32bit;
    else
      Assert( False, 'Bad biBitCount' );
    end; // case biBitCount of

    RNumPalColors := biClrUsed;
    RDPI.X := biXPelsPerMeter * 2.54 / 100;
    RDPI.Y := biYPelsPerMeter * 2.54 / 100;

    if RNumPalColors = 0 then
      case biBitCount of
      1: RNumPalColors := 2;
      4: RNumPalColors := 16;
      8: RNumPalColors := 256;
      end;

  end; // with RR, RDIBInfo.bmi do

  PrepSelfFields(); // assign memory if needed and set self fields
end; //*** end of procedure TN_RasterObj.PrepSelfByRDIBInfo

//************************************** TN_RasterObj.PrepRDIBInfoBySelf  ***
// Prepare Self fields by PrepSelfFields() and RDIBInfo fields by Self
//
procedure TN_RasterObj.PrepRDIBInfoBySelf();
var
  i: integer;
begin
  PrepSelfFields(); // assign memory if needed and set self fields

  FillChar( RDIBInfo, Sizeof(RDIBInfo), 0 );
  with RR, RDIBInfo, RDIBInfo.bmi do
  begin
    biSize   := Sizeof(TBitmapInfoHeader);
    biWidth  := RWidth;
    biHeight := RHeight;
    biPlanes := 1;
    biCompression := BI_RGB;
    biClrUsed := RNumPalColors;
    biSizeImage := RRasterSize;
    biXPelsPerMeter := Round( RDPI.X*100/2.54 );
    biYPelsPerMeter := Round( RDPI.Y*100/2.54 );

    case RPixFmt of
      pf1bit:  biBitCount := 1;
      pf4bit:  biBitCount := 4;
      pf8bit:  biBitCount := 8;
      pf16bit: begin biBitCount := 16; biCompression := BI_BITFIELDS;
                 RedMask := $F800; GreenMask := $07E0; BlueMask := $001F; end;
      pf24bit: biBitCount := 24;
//      pf32bit: begin biBitCount := 32; biCompression := BI_BITFIELDS;
//                 RedMask := $FF0000; GreenMask := $FF00; BlueMask := $FF; end;
      pf32bit: biBitCount := 32;
      else
        Assert( false, 'Bad PixelFormat' );
    end; // case PixFmt of

    // Note: In DIB Palette as in own Raster Palette $FF is Blue

    if RNumPalColors > 0 then
      move( PPalColors^, PalEntries[0], RNumPalColors*Sizeof(integer) )
    else if RPixFmt <= pf8bit then // PalEntries should be filled,
    begin                          // create dummy gray palette with colors
      for i := 0 to 255 do         // from $808080 to $BFBFBF
        PalEntries[i] := $808080 + $010101 * (i shr 2);
    end;

  end; // with RR, RDIBInfo, RDIBInfo.bmi do
end; //*** end of procedure TN_RasterObj.PrepRDIBInfoBySelf

//************************************** TN_RasterObj.SetTranspIndex  ***
// Set RTranspIndex field (index of RTanspColor for RPixFmt <= pf8bit)
//
procedure TN_RasterObj.SetTranspIndex();
var
  i, SwapedTranspColor: integer;
  PPal: PInteger;
begin
  with RR do
  begin

  RTranspIndex := -1;
  if RPixFmt > pf8bit then Exit; // no Palette, RTranspIndex is not defined

  PPal := PPalColors;
  SwapedTranspColor := N_SwapRedBlueBytes( RTranspColor );

  for i := 0 to RNumPalColors-1 do // search for RTranspColor in Palette
  begin

    if PPal^ = SwapedTranspColor then
    begin
      RTranspIndex := i;
      Break;
    end;
    Inc(PPal);

  end; // for i := 0 to RNumPalColors-1 do

  if RTranspIndex = -1 then // not found
    RTranspColor := N_EmptyColor;

  end; // with RR do
end; //*** end of procedure TN_RasterObj.SetTranspIndex

//************************************** TN_RasterObj.SetPalColors  ***
// Set given number of Palette Colors (from 0 to ANumColors-1),
// other palette Colors remains the same,
// APPalColors points to first new palette color
//
procedure TN_RasterObj.SetPalColors( APPalColors: PInteger; ANumColors: integer );
var
  i: integer;
  PPal: PInteger;
begin
  with RR do
  begin
    if PPalColors = nil then Exit; // Raster has no Palette

    PPal := PPalColors; // to be able to use Inc(PPal)

    if ANumColors > RNumPalColors then ANumColors := RNumPalColors;

    for i := 0 to ANumColors-1 do
    begin // in DIB Palette least significant byte is Blue
      PPal^ := N_SwapRedBlueBytes( APPalColors^ );
      Inc(PPal);
      Inc(APPalColors);
    end; // for i := 0 to RNumPalColors-1 do

  end; // with RR do
end; //*** end of procedure TN_RasterObj.SetPalColors

//********************************************** TN_RasterObj.GetPixelValue ***
// Get one Pixel Value (Color or Color index)
// AX, AY - pixel coords
//
function TN_RasterObj.GetPixelValue( AX, AY: integer ): integer;
var
  PLine: TN_BytesPtr;
begin
  PLine := PRasterBytes + AY*RRLineSize;
  Result := 0; // to avoid warning

  case RR.RPixFmt of

  pf1bit:  Result := ( PByte(PLine+(AX shr 3))^ shr (AX and $7) ) and $1;
  pf4bit:  Result := ( PByte(PLine+(AX shr 1))^ shr (4*(AX and $1)) ) and $F;
  pf8bit:  Result :=   PByte(PLine+AX)^;
  pf16bit: Result := TN_PUInt2(PLine+2*AX)^;
  pf24bit: Result := PByte(PLine+3*AX)^ + ( TN_PUInt2(PLine+3*AX+1)^ shl 8 );
  pf32bit: Result := PInteger(PLine+4*AX)^;

  end; // case RPixFmt of
end; //*** end of function TN_RasterObj.GetPixelValue

//********************************************** TN_RasterObj.GetPixelColor ***
// Get one Pixel Color (RGB Color value (least byte is Blue), not Color index)
// AX, AY - pixel coords
//
function TN_RasterObj.GetPixelColor( AX, AY: integer ): integer;
var
  PColor: PInteger;
begin
  Result := GetPixelValue( AX, AY );

  if RR.RPixFmt > pf8bit then Exit; // not palette mode, all done

  PColor := PPalColors;
  Inc( PColor, Result );
//  Result := N_SwapRedBlueBytes( PColor^ );
  Result := PColor^; // Red Blue Colors are swaped (as in TrueColor raster Pixels)
end; //*** end of function TN_RasterObj.GetPixelColor

//********************************************** TN_RasterObj.SetPixelValue ***
// Set New one Pixel Value (Color or Color index)
//
// AX, AY    - pixel X,Y coords
// APixValue - New Pixel Value in device format (Blue in least significant bits)
//
procedure TN_RasterObj.SetPixelValue( AX, AY, APixValue: integer );
var
  BitShiftL, BitShiftR: integer;
  PLine: TN_BytesPtr;
begin
  PLine := PRasterBytes + AY*RRLineSize;

  case RR.RPixFmt of

  pf1bit:  begin
             BitShiftR := AX and $7;
             PLine := PLine + (AX shr 3);
             BitShiftL := 7 - BitShiftR;
             PByte(PLine)^ := (APixValue shl BitShiftL) or
                              (PByte(PLine)^ and ($FF7F shr BitShiftR));
           end;

  pf4bit:  begin
             PLine := PLine + (AX shr 1);
             if (AX and 1) = 0 then
               PByte(PLine)^ := (APixValue shl 4) or (PByte(PLine)^ and $FF)
             else
               PByte(PLine)^ := APixValue or (PByte(PLine)^ and $FF00);
           end;

  pf8bit:  PByte(PLine+AX)^ := APixValue;

  pf16bit: TN_PUInt2(PLine+2*AX)^ := APixValue;

  pf24bit: begin
             PLine := PLine + 3*AX;
             PByte(PLine)^ := APixValue and $FF;
             Inc(PLine);
             TN_PUInt2(PLine)^ := APixValue shr 8;
           end;

  pf32bit: PInteger(PLine+4*AX)^ := APixValue;

  end; // case RPixFmt of
end; //*** end of procedure TN_RasterObj.SetPixelValue

//***************************************** TN_RasterObj.GetPixValuesVector ***
// Get Vector (horizontal or vertical) of Pixel Values (Colors or Color indexes)
// Return number of Pixels in Vector (AX2-AX1+1 or AY2-AY1+1)
//
// APixValues - Resulting array of Pixel Values with Result elements
// AX1, AY1   - upper left  pixel coords
// AX2, AY2   - lower right pixel coords
// ( (AX1=AX2 or AY1=AY2) is always True )
//
function TN_RasterObj.GetPixValuesVector( var APixValues: TN_IArray;
                                          AX1, AY1, AX2, AY2: integer ): integer;
var
  i: integer;
  PLine: TN_BytesPtr;
  Label NotImplemeneted;
begin
  if AX1 = AX2 then // vertical Vector
    Result := AY2 - AY1 + 1
  else //************* horizontal Vector
    Result := AX2 - AX1 + 1;

  if Length(APixValues) < Result then
    SetLength( APixValues, Result );

  PLine := PRasterBytes + AY1*RRLineSize; // Beg of Row of first pixel
  N_i1 := integer(PLine);

  case RR.RPixFmt of
  pf1bit:  goto NotImplemeneted;
  pf4bit:  goto NotImplemeneted;

  pf8bit: begin
    PLine := PLine + AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PByte(PLine)^;
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PByte(PLine)^;
        Inc( PLine );
      end;
  end; // pf8bit: begin

  pf16bit: begin
    PLine := PLine + 2*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := TN_PUInt2(PLine)^;
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := TN_PUInt2(PLine)^;
        Inc( PLine, 2 );
      end;
  end; // pf16bit: begin

  pf24bit: begin
    PLine := PLine + 3*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PByte(PLine)^ + (TN_PUInt2(PLine+1)^ shl 8);
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PByte(PLine)^ + (TN_PUInt2(PLine+1)^ shl 8);
        Inc( PLine, 3 );
      end;
  end; // pf24bit: begin

  pf32bit: begin
    PLine := PLine + 4*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PInteger(PLine)^;
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PInteger(PLine)^;
        Inc( PLine, 4 );
      end;
  end; // pf32bit: begin

  end; // case RPixFmt of

  Exit;
  NotImplemeneted: Assert( False, 'Not Implemeneted!' );
end; //*** end of function TN_RasterObj.GetPixValuesVector

//***************************************** TN_RasterObj.SetPixValuesVector ***
// Set Vector (horizontal or vertical) of Pixel Values
//  (Colors(least byte is Blue) or Color indexes for Palette modes)
// Return number of Pixels in Vector (AX2-AX1+1 or AY2-AY1+1)
//
// APixValues - given Vector of Pixel Values with Result elements
// AX1, AY1   - upper left  pixel coords
// AX2, AY2   - lower right pixel coords
// ( (AX1=AX2 or AY1=AY2) is always True )
//
function TN_RasterObj.SetPixValuesVector( APixValues: TN_IArray;
                                          AX1, AY1, AX2, AY2: integer ): integer;
var
  i, WrkAY1: integer;
  PLine: TN_BytesPtr;
  Label NotImplemeneted;
begin
  WrkAY1 := AY1; // Debugger shows bad AY1 value!

  if AX1 = AX2 then // vertical array
    Result := AY2 - AY1 + 1
  else //************* horizontal array
    Result := AX2 - AX1 + 1;

  Assert( Length(APixValues) >= Result, 'Bad Size!' );

  PLine := PRasterBytes + WrkAY1*RRLineSize; // Beg of Row of first pixel
  N_i2 := integer(PLine);

  case RR.RPixFmt of
  pf1bit:  goto NotImplemeneted;
  pf4bit:  goto NotImplemeneted;

  pf8bit: begin
    PLine := PLine + AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        PByte(PLine)^ := APixValues[i];
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        PByte(PLine)^ := APixValues[i];
        Inc( PLine );
      end;
  end; // pf8bit: begin

  pf16bit: begin
    PLine := PLine + 2*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        TN_PUInt2(PLine)^ := APixValues[i];
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        TN_PUInt2(PLine)^ := APixValues[i];
        Inc( PLine, 2 );
      end;
  end; // pf16bit: begin

  pf24bit: begin
    PLine := PLine + 3*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        PByte(PLine)^ := APixValues[i] and $FF;
        Inc( PLine );
        TN_PUInt2(PLine)^ := APixValues[i] shr 8;
        Inc( PLine, RRLineSize-1 );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        PByte(PLine)^ := APixValues[i] and $FF;
        Inc( PLine );
        TN_PUInt2(PLine)^ := APixValues[i] shr 8;
        Inc( PLine, 2 );
      end;
  end; // pf24bit: begin

  pf32bit: begin
    PLine := PLine + 4*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        PInteger(PLine)^ := APixValues[i];
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        PInteger(PLine)^ := APixValues[i];
        Inc( PLine, 4 );
      end;
  end; // pf32bit: begin

  end; // case RPixFmt of

  Exit;
  NotImplemeneted: Assert( False, 'Not Implemeneted!' );
end; //*** end of function TN_RasterObj.SetPixValuesVector

//******************************************* TN_RasterObj.GetPixValuesRect ***
// Get Values of given Rect's pixels in resulting AValues integer Array
// Return number of Values in ARGBValues Array (AX2-AX1+1)*(AY2-AY1+1)
//
// AValues  - resulting integer Array with Pixel Values
// AX1, AY1 - upper left  pixel coords
// AX2, AY2 - lower right pixel coords
//
function TN_RasterObj.GetPixValuesRect( var AValues: TN_IArray;
                                        AX1, AY1, AX2, AY2: integer ): integer;
var
  i, j, ind, NX, NY: integer;
  PixRow: TN_IArray;
begin
  NX := AX2-AX1+1;
  SetLength( PixRow, NX );
  NY := AY2-AY1+1;
  Result := NX*NY;
  if Length(AValues) < Result then
    SetLength( AValues, Result );

  ind := 0;
  for i := AY1 to AY2 do // along PixelRows
  begin
    GetPixValuesVector( PixRow, AX1, i, AX2, i );

    for j := 0 to NX-1 do // along Pixels in i-th PixelRow
    begin
      AValues[ind] := PixRow[j];
      Inc( ind );
    end; // for j := 0 to NX-1 do // along Pixels in i-th PixelRow

  end; // for i := AY1 to AY2 do // along PixelRows
end; //*** end of function TN_RasterObj.GetPixValuesRect

//******************************************* TN_RasterObj.SetPixValuesRect ***
// Set given Rect's pixels by given AValues integer Array of Pixel Values
// Return number of Pixels in Rect (AX2-AX1+1)*(AY2-AY1+1)
//
// AValues  - given integer Array with Pixel Values
// AX1, AY1 - upper left  pixel coords
// AX2, AY2 - lower right pixel coords
//
function TN_RasterObj.SetPixValuesRect( AValues: TN_IArray;
                                        AX1, AY1, AX2, AY2: integer ): integer;
var
  i, j, ind, NX, NY: integer;
  PixRow: TN_IArray;
begin
  NX := AX2-AX1+1;
  SetLength( PixRow, NX );
  NY := AY2-AY1+1;
  Result := NX*NY;

  ind := 0;
  for i := AY1 to AY2 do // along PixelRows
  begin

    for j := 0 to NX-1 do // along Pixels in i-th PixelRow
    begin
      PixRow[j] := AValues[ind];
      Inc( ind );
    end; // for j := 0 to NX-1 do // along Pixels in i-th PixelRow

    SetPixValuesVector( PixRow, AX1, i, AX2, i );
  end; // for i := AY1 to AY2 do // along PixelRows
end; //*** end of function TN_RasterObj.SetPixValuesRect

//***************************************** TN_RasterObj.GetPixColorsVector ***
// Get Vector (horizontal or vertical) of Pixel Colors
// (RGB Color values (least byte is Blue), not Color indexes)
// Return number of Pixels in Vector (AX2-AX1+1 or AY2-AY1+1)
//
// APixColors - Resulting array of Pixel Colors with Result elements
// AX1, AY1   - upper left  pixel coords
// AX2, AY2   - lower right pixel coords
// ( (AX1=AX2 or AY1=AY2) is always True )
//
function TN_RasterObj.GetPixColorsVector( var APixColors: TN_IArray;
                                          AX1, AY1, AX2, AY2: integer ): integer;
var
  i: integer;
  PColor: PInteger;
begin
  Result := GetPixValuesVector( APixColors, AX1, AY1, AX2, AY2 );

  if RR.RPixFmt > pf8bit then Exit; // not palette mode

  for i := 0 to Result-1 do // conv Color Index to Color
  begin
    PColor := PPalColors;
    Inc( PColor, APixColors[i] );
    APixColors[i] := PColor^;
  end; // for i := 0 to Result-1 do // conv Color Index to Color

end; //*** end of function TN_RasterObj.GetPixColorsVector

//**************************************** TN_RasterObj.GetPixRGBValuesRect ***
// Get RGB Values of given Rect's pixels in resulting ARGBValues byte Array
// Return number of RGB triples in ARGBValues Array (AX2-AX1+1)*(AY2-AY1+1)
// (First byte is Blue, ARGBValues Array length is Result*3)
//
// ARGBValues - resulting byte Array with B,G,R,B,G,R, ... Values
// AX1, AY1   - upper left  pixel coords
// AX2, AY2   - lower right pixel coords
//
function TN_RasterObj.GetPixRGBValuesRect( var ARGBValues: TN_BArray;
                                           AX1, AY1, AX2, AY2: integer ): integer;
var
  i, j, ind, NX, NY: integer;
  PixRow: TN_IArray;
begin
  NX := AX2-AX1+1;
  SetLength( PixRow, NX );
  NY := AY2-AY1+1;
  Result := NX*NY;
  if Length(ARGBValues) < 3*Result then
    SetLength( ARGBValues, 3*Result );

  ind := 0;
  for i := AY1 to AY2 do // along PixelRows
  begin
    GetPixColorsVector( PixRow, AX1, i, AX2, i );

    for j := 0 to NX-1 do // along Pixels in i-th PixelRow
    begin
      ARGBValues[ind]   := PixRow[j] and $FF;
      ARGBValues[ind+1] := (PixRow[j] shr 8)  and $FF;
      ARGBValues[ind+2] := (PixRow[j] shr 16) and $FF;
      Inc( ind, 3 );
    end; // for j := 0 to NX-1 do // along Pixels in i-th PixelRow

  end; // for i := AY1 to AY2 do // along PixelRows
end; //*** end of function TN_RasterObj.GetPixRGBValuesRect

//**************************************** TN_RasterObj.SetPixRGBValuesRect ***
// Set given Rect's pixels by given ARGBValues byte Array of RGB Values
// Return number of Pixels in Rect (AX2-AX1+1)*(AY2-AY1+1)
// (First byte is Blue, ARGBValues Array length is Result*3)
//
// ARGBValues - given byte Array with B,G,R,B,G,R, ... Values
// AX1, AY1   - upper left  pixel coords
// AX2, AY2   - lower right pixel coords
//
function TN_RasterObj.SetPixRGBValuesRect( ARGBValues: TN_BArray;
                                           AX1, AY1, AX2, AY2: integer ): integer;
var
  i, j, ind, NX, NY: integer;
  PixRow: TN_IArray;
begin
  NX := AX2-AX1+1;
  SetLength( PixRow, NX );
  NY := AY2-AY1+1;
  Result := NX*NY;

  ind := 0;
  for i := AY1 to AY2 do // along PixelRows
  begin

    for j := 0 to NX-1 do // along Pixels in i-th PixelRow
    begin
      PixRow[j] := ARGBValues[ind] or (ARGBValues[ind+1] shl 8) or
                                      (ARGBValues[ind+2] shl 16);
      Inc( ind, 3 );
    end; // for j := 0 to NX-1 do // along Pixels in i-th PixelRow

    SetPixValuesVector( PixRow, AX1, i, AX2, i );
  end; // for i := AY1 to AY2 do // along PixelRows
end; //*** end of function TN_RasterObj.SetPixRGBValuesRect

//**************************************** TN_RasterObj.SetPixRGBValuesRect ***
// Convert given ARGBValues by three given XLat Tables
//
// ASrcRGBValues - given byte Array with B,G,R,B,G,R, ... Values to convert
// ADstRGBValues - resulting byte Array with B,G,R,B,G,R, ... converted Values
// ANumTriples   - Number of triples to convert
// ARValues      - given XLat table to convert Red   Values
// AGValues      - given XLat table to convert Green Values
// ABValues      - given XLat table to convert Blue  Values
//
procedure TN_RasterObj.ConvRGBValues( ASrcRGBValues: TN_BArray;
                                      var ADstRGBValues: TN_BArray; ANumTriples: integer;
                                      ARValues, AGValues, ABValues: TN_BArray );
var
  i, NumBytes: integer;
begin
  NumBytes := ANumTriples * 3;
  if Length(ADstRGBValues) < NumBytes then
    SetLength( ADstRGBValues, NumBytes );

  for i := 0 to ANumTriples-1 do // along RGB Triples
  begin
    ADstRGBValues[i]   := ABValues[ASrcRGBValues[i]];
    ADstRGBValues[i+1] := AGValues[ASrcRGBValues[i+1]];
    ADstRGBValues[i+2] := ARValues[ASrcRGBValues[i+2]];
  end; // for i := 0 to ANumTriples-1 do // along RGB Triples
end; //*** end of function TN_RasterObj.ConvRGBValues

//******************************************** TN_RasterObj.SaveInBMPFormat  ***
// Save given Fragment of Self to given AFileName in BMP format, or
// if AFileName = 'Clipboard' copy to Windows Clipboard in BMP format
// Self PixelFormat is used (APImageFilePar.IFPIFPPixFmt is ignored)
// Negative AFragm coords means coords, relative to lower right borders
// ( AFragm=(0,0,-1,-1) means full rect )
//
procedure TN_RasterObj.SaveInBMPFormat( AFileName: string; const AFragm: TRect;
                                                   APImageFilePar: TN_PImageFilePar );
//                                               APFile1Params: TN_PFile1Params );
var
  DIBInfoSize: integer;
  FStream: TFileStream;
  BMPFHeader: TBitmapFileHeader;
begin
  FStream := nil; // to avoid warning

  with RR, BMPFHeader, RDIBInfo.bmi do
  begin
    PrepRDIBInfoBySelf(); // a precaution, all should be already OK
    DIBInfoSize := Sizeof(RDIBInfo.bmi) + RNumPalColors*Sizeof(integer);


    try
      FStream := TFileStream.Create( AFileName, fmCreate );
      FillChar( BMPFHeader, Sizeof(BMPFHeader), 0 );
      bfType := $4D42; // 'BM' signature
      bfOffBits := Sizeof(BMPFHeader) + DIBInfoSize;
      bfSize := bfOffBits + RRasterSize;

      FStream.Write( BMPFHeader, Sizeof(BMPFHeader) );
      FStream.Write( RDIBInfo, DIBInfoSize );
      FStream.Write( PRasterBytes^, RRasterSize );

    finally
      FStream.Free;
    end; // try

  end; // with RR, BMPFHeader, RDIBInfo.bmi do
end; //*** end of procedure TN_RasterObj.SaveInBMPFormat

//***************************************** TN_RasterObj.LoadFromBMPFormat  ***
// Load Raster from given AFileName in BMP format, or
// if AFileName = 'Clipboard' paste from Windows Clipboard in BMP format
// (temporary not implemented)
//
procedure TN_RasterObj.LoadFromBMPFormat( AFileName: string );
var
  i, j, SavedTranspColor, BMPLineSize: integer;
  FStream: TFileStream;
//  ZStream: TDecompressionStream;
  BMPFHeader: TBitmapFileHeader;
  NeededPixFmt: TPixelFormat;
  Conv24to32: boolean;
  RowBuf: TN_BArray;
  PSrc, PDst: TN_BytesPtr;
begin
  with RR, BMPFHeader, RDIBInfo.bmi do
  begin
  SavedTranspColor := RTranspColor;
  NeededPixFmt := RPixFmt;

  InitRasterObj( RType ); // free memory from previous picture if any

  FStream := nil; // to avoid warning
//  ZStream := nil; // to avoid warning
  try

  if RType = rtBMP then //************************* just load Bitmap object
  begin
    if RBMP <> nil then RBMP.Free;

    RBMP := N_CreateBMPObjFromFile( AFileName );
    RWidth  := RBMP.Width;
    RHeight := RBMP.Height;
    RPixFmt := RBMP.PixelFormat;
    PrepRDIBInfoBySelf(); // set all needed self fields, used in other methods

    Exit; // all done
  end; // if RType = rtBMP then

  try
    FStream := TFileStream.Create( AFileName, fmOpenRead );

{ // obsolete
    if UpperCase(AFileName[Length(AFileName)]) = 'Z' then // decompress by ZLib
    begin
      FStream.Read( BMPZ, 4 );
      if BMPZ <> $5A504D42 then
        raise Exception.Create( 'Not a BMPZ file!' );

      ZStream := TDecompressionStream.Create( FStream );
      ZStream.Read( FileTranspColor, 4 );
      if FileTranspColor = N_EmptyColor then
        RTranspColor := SavedTranspColor
      else
        RTranspColor := FileTranspColor;
      ZStream.Read( RTranspIndex, 4 );
      ZStream.Read( RDIBInfo.bmi, Sizeof(RDIBInfo.bmi) );

      PrepSelfByRDIBInfo(); // set self fields and assign all needed memory

      if RNumPalColors > 0 then
        ZStream.Read( PPalColors^, RNumPalColors*Sizeof(Integer) );

      ZStream.Read( PRasterBytes^, RRasterSize ); // RRasterSize always > 0

      if RMaskSize > 0 then
        ZStream.Read( PMaskBytes^, RMaskSize )
      else
        CreateMask();

    end else //****************************************** ordinary BMP file
    begin
}
      FStream.Read( BMPFHeader, Sizeof(BMPFHeader) );
      if BMPFHeader.bfType <> $4D42 then
        raise Exception.Create( 'Not a BMP file!' );

      FStream.Read( RDIBInfo.bmi, Sizeof(RDIBInfo.bmi) );
      RTranspColor := SavedTranspColor;

      Conv24to32 := (NeededPixFmt = pf32bit) and (biBitCount = 24);
      if Conv24to32 then biBitCount := 32;

      PrepSelfByRDIBInfo(); // set self fields and assign all needed memory

      if RNumPalColors > 0 then
        FStream.Read( PPalColors^, RNumPalColors*Sizeof(Integer) );

//      FStream.Seek( bfOffBits, soFromBeginning ); //  // in Delphi XE5 warning W1000 Symbol 'Seek' is deprecated
      FStream.Seek( integer(bfOffBits), soFromBeginning );

      if Conv24to32 then // convert from 24bit to 32bit while reading
      begin
        BMPLineSize := ((3*RWidth+3) shr 2) shl 2; // Lines should be DWord aligned
        SetLength( RowBuf, BMPLineSize );

        for i := 0 to RHeight-1 do // along scanlines
        begin
          FStream.Read( RowBuf[0], BMPLineSize ); // read to temporary buf

          PSrc := TN_BytesPtr(@RowBuf[0]);
          PDst := PRasterBytes + i*RRLineSize;

          for j := 0 to RWidth-1 do // along pixels in scanline
          begin
            (PDst)^ := PSrc^;
            TN_PUInt2(PDst+1)^ := TN_PUInt2(PSrc+1)^;
            PByte(PDst+3)^ := 0;

            Inc( PDst, 4 );
            Inc( PSrc, 3 );
          end; // for j := 0 to RBytesInLine-1 do // along bytes in scanline
        end; // for i := 0 to RHeight-1 do // along scanlines
      end else // read RasterBytes as is
        FStream.Read( PRasterBytes^, RRasterSize );

      CreateMask();
//    end;

  finally
//    ZStream.Free;
    FStream.Free;
  end;

  except end;
  end; // with RR, BMPFHeader, RDIBInfo do
end; //*** end of procedure TN_RasterObj.LoadFromBMPFormat

//******************************************** TN_RasterObj.SaveToBMPObj  ***
// Create new BMP Obj and Save Self to it
//
function TN_RasterObj.SaveToBMPObj(): TBitmap;
var
  i: integer;
  BMPRect: TRect;
  LogPal: TN_LogPalette;
  PPal: PInteger;
begin
  with RR do
  begin
    Result := N_CreateEmptyBMP( RWidth, RHeight, RPixFmt );

    if RPixFmt <= pf8bit then // copy manually palette and pixels
    begin                     // (Draw does not copy pixel values!)
                              // (CreatePalette changes Pixels!!!)
      PrepSelfFields(); // a preacaution

      with LogPal do //*** Copy Palette (before copiing Pixels!)
      begin
        palVersion := $300;
        palNumEntries := RNumPalColors;

        PPal := PPalColors;
        for i := 0 to RNumPalColors-1 do
        begin
          palEntries[i] := N_SwapRedBlueBytes( PPal^ );
          Inc(PPal);
        end;

        Result.Palette := CreatePalette( Header );
      end; // with LogPal do //*** Copy Palette

      for i := 0 to RHeight-1 do // copy Raster pixels ( Raster has no mask! )
        move( (PRasterBytes+(RHeight-i-1)*RRLineSize)^,
                                   PByte(Result.ScanLine[i])^, RRBytesInLine );
    end else // RPixFmt >= pf16bit, mask may exists, but Draw can be used
    begin
      BMPRect := Rect( 0, 0, RWidth, RHeight ); // full image rect

      if RTranspColor <> N_EmptyColor then // clear whole bitmap by RTranspColor
      with Result.Canvas do
      begin
        Brush.Color := RTranspColor;
        FillRect( BMPRect );
      end;

      Draw( Result.Canvas.Handle, BMPRect, Rect(0,0,-1,-1), 1, ppUpperLeft );
    end; // else // RPixFmt >= pf16bit, mask may exists, but Draw can be used
  end; // with RR do
end; //*** end of function TN_RasterObj.SaveToBMPObj

//********************************************** TN_RasterObj.LoadFromBMPObj  ***
// Load Raster from given BMP Object
//
procedure TN_RasterObj.LoadFromBMPObj( ABMP: TBitmap; APixFmt: TPixelFormat = pfDevice );
var
  i, SavedTranspColor: integer;
begin
  with RR do
  begin
  SavedTranspColor := RTranspColor;
  InitRasterObj( RType ); // free memory from previous picture if any

  RTranspColor := SavedTranspColor;

  RWidth  := ABMP.Width;
  RHeight := ABMP.Height;
  RPixFmt := ABMP.PixelFormat;

  if RPixFmt = pfDevice then RPixFmt := APixFmt;

  if RType = rtBMP then
  begin
    if RBMP <> nil then RBMP.Free;
    RBMP := ABMP;
    Exit; // all done
  end; // if RType = rtBMP then

  PrepSelfFields();

  if RPixFmt <= pf8bit then // get Palettte from ABMP
  begin
    SetLength( RPalIA, 256 );

    // Note: GetPaletteEntries returns Colors in Pascal format ($FF is Red)

    RNumPalColors := GetPaletteEntries( ABMP.Palette, 0, 256, RPalIA[0] );
    N_ia := RPalIA; // debug
    SetLength( RPalIA, RNumPalColors );
    PPalColors := @RPalIA[0];

    // in DIB Palette least significant byte ($FF) is Blue
    for i := 0 to RNumPalColors-1 do
      RPalIA[i] := N_SwapRedBlueBytes( RPalIA[i] );
{
    if RType = rtRArray then // move Palette from IArray to RArray
    begin
      RPalRA := K_RCreateByTypeName( 'Integer', RNumPalColors );
      PPalColors := TK_RArray(RPalRA).P(0);
      move( RPalIA[0], PPalColors^, RNumPalColors*Sizeof(Integer) );
      RPalIA := nil;
    end;
}
  end; // if RPixFmt <= pf8bit then // get Palettte

  for i := 0 to RHeight-1 do // copy Raster pixels
    move( PByte(ABMP.ScanLine[i])^,
                     (PRasterBytes+(RHeight-i-1)*RRLineSize)^, RRBytesInLine );

  N_ba := RasterBA;

  CreateMask(); // create transparency mask if needed

  end; // with RR do
end; //*** end of procedure TN_RasterObj.LoadFromBMPObj

//******************************************** TN_RasterObj.SaveRObjToFile  ***
// Save given ARect of Self to given AFileName in bmp, gif or jpeg format
// with all needed PixelFormat convertion
// AFileName = 'Clipboard' means copy to Windows Clipboard in BMP format
//
procedure TN_RasterObj.SaveRObjToFile( AFileName: string; const ARect: TRect;
                                                  APImageFilePar: TN_PImageFilePar );
//                                              APFile1Params: TN_PFile1Params );
var
  FragmRect: TRect;
  TmpBMPObj: TBitmap;
  TmpRObj: TN_RasterObj;
  ImageFilePar: TN_ImageFilePar;
begin
  FragmRect := ARect; // (0,0,-1,-1) means full rect
  if FragmRect.Right  < 0 then FragmRect.Right  := FragmRect.Right  + RR.RWidth;
  if FragmRect.Bottom < 0 then FragmRect.Bottom := FragmRect.Bottom + RR.RHeight;

  if APImageFilePar = nil then
  begin
    ImageFilePar := N_DefImageFilePar;
    with ImageFilePar do
    begin
      IFPResDPI      := RR.RDPI;
      IFPTranspColor := RR.RTranspColor;
    end;
  end else
    ImageFilePar := APImageFilePar^;

  with ImageFilePar do
  begin

  if IFPImFileFmt = imffByFileExt then
    IFPImFileFmt := N_GetFileFmtByExt( AFileName );

  if IFPImFileFmt = imffBMP then // save in BMP format without using TBitmap GDI Object
  begin
    SaveInBMPFormat( AFileName, FragmRect, @ImageFilePar )
  end else // Save in GIF or JPEG format using temporary TBitmap GDI Object (TmpBMPObj)
  begin
    if (IFPImFileFmt = imffGIF) and (RR.RPixFmt > pf8bit) then // conv to pf8bit format
    begin
      TmpRObj := ConvTo8bitRObj( rtBArray );
      if TmpRObj = nil then
        raise Exception.Create( 'More than 256 colors, cannot convert to gif!' );
      TmpBMPObj := TmpRObj.SaveToBMPObj();
      TmpRObj.Free;
    end else // save Self of any RPixFmt to JPEG ro pf8bit Self to GIF
    begin
      TmpBMPObj := SaveToBMPObj();
    end;

    N_SaveBMPObjToFile( TmpBMPObj, AFileName, @ImageFilePar );
    TmpBMPObj.Free;
  end; // else // Save in GIF or JPEG format using temporary TBitmap GDI Object (TmpBMPObj)

  end; // with ImageFilePar do
end; //*** end of procedure TN_RasterObj.procedure TN_RasterObj.SaveRObjToFile

//********************************************** TN_RasterObj.LoadRObjFromFile  ***
// Load Raster from given file in bmp, bmpz, gif, and jpeg format
//
procedure TN_RasterObj.LoadRObjFromFile( AFileName: string );
var
  FExt: string;
  TmpBMPObj: TBitmap;
begin
  FExt := UpperCase( ExtractFileExt( AFileName ) );

  if (FExt = '.BMP') or (FExt = '.BMPZ') then
    LoadFromBMPFormat( AFileName )
  else
  begin
    TmpBMPObj := N_CreateBMPObjFromFile( AFileName );
    LoadFromBMPObj( TmpBMPObj, pfDevice );

    if RR.RTranspColor = -2 then // use GIF Transp Color, set in N_CreateBMPObjFromFile
    begin
      RR.RTranspColor := N_GlobObj.GOGifTranspColor;
      RR.RTranspIndex := N_GlobObj.GOGifTranspColorInd;
      if RR.RTranspIndex >= 0 then
        CreateMask(); // is needed only for GIF files with transparent color
    end;
// temporary not implemented!
//    RR.RTranspColor := N_MEGlobObj.GOGifTranspColor;
//    CreateMask(); // is needed only for GIF files with transparent color

    TmpBMPObj.Free;
  end;
end; //*** end of procedure TN_RasterObj.LoadRObjFromFile

//********************************************** TN_RasterObj.CreateMask  ***
// Create Mask by current RTranspColor,
// for RPixFmt >= pf16bit Rasters RTranspColor pixels would be replaced by zero,
// call ChangeTranspColor( N_EmptyColor ); to restore them
//
procedure TN_RasterObj.CreateMask();
var
  i, j, k, NMaskFullBytes, NRestBits: integer;
  SwapedTranspColor: integer;
  PPixel, PMask: TN_BytesPtr;
  CurMaskByte: Byte;
begin
  with RR do
  begin

  if (RTranspColor = N_EmptyColor) or // Mask is not needed
     (RTranspColor = -2) then Exit; // TranspColor was not yet defined from GIF File

  PrepSelfFields(); // assign memory for mask (if not yet)
  SwapedTranspColor := N_SwapRedBlueBytes( RTranspColor );

  if RPixFmt <= pf8bit then // Raster with Palette,
  begin                     // Mask is not needed, just calc RTranspIndex
    SetTranspIndex();
    Exit; // all done
  end; // if RPixFmt <= pf8bit then // Raster with Palette,

  //*************** Here: RPixFmt >= pf16bit

  NMaskFullBytes := RWidth shr 3;  // Number of whole Bytes in Mask Line
  NRestBits      := RWidth and $7; // Number of Bits in Last Byte of Mask Line

  case RPixFmt of // only pf24bit case was tested

  pf16bit: begin //*************************** not tested !!!

  for i := 0 to RHeight-1 do
  begin
    PPixel := PRasterBytes + i*RRLineSize;
    PMask  := PMaskBytes   + i*RMLineSize;

    for j := 0 to NMaskFullBytes-1 do
    begin
      CurMaskByte := 0;
      for k := 0 to 7 do // along all bits in Full Bytes of Mask scanline
      begin
        if TN_PUInt2(PPixel)^ = SwapedTranspColor then // transparent Pixel
        begin
          Inc( CurMaskByte, $80 shr k ); // add 1 to Mask
          TN_PUInt2(PPixel)^ := 0; // clear transparent Pixel
        end;

        Inc( PPixel, 2 );
      end; // for k := 0 to 7 do // along all bits in whole Mask Bytes
      PMask^ := TN_Byte(CurMaskByte);
      Inc(PMask);

    end; // for j := 0 to NMaskBytes-1 do

    if NRestBits > 0 then
    begin
      CurMaskByte := 0;
      for k := 0 to NRestBits-1 do // along bits in last Byte
      begin
        if TN_PUInt2(PPixel)^ = SwapedTranspColor then // transparent Pixel
        begin
          Inc( CurMaskByte, $80 shr k ); // add 1 to Mask
          TN_PUInt2(PPixel)^ := 0; // clear transparent Pixel
        end;

        Inc( PPixel, 2 );
      end; // for k := 0 to NRestBits-1 do // along bits in last Byte
      PMask^ := TN_Byte(CurMaskByte);
    end; // if NRestBits > 0 then
  end; // for i := 0 to RHeight-1 do
  end; // pf16bit: begin

  pf24bit: begin //***************************************** pf24bit

  for i := 0 to RHeight-1 do
  begin
    PPixel := PRasterBytes + i*RRLineSize;
    PMask  := PMaskBytes   + i*RMLineSize;

    for j := 0 to NMaskFullBytes-1 do
    begin
      CurMaskByte := 0;

      for k := 0 to 7 do // along all bits in Full Bytes of Mask scanline
      begin
        if (PInteger(PPixel)^ and $00FFFFFF) = SwapedTranspColor then // transparent Pixel
        begin
          Inc( CurMaskByte, $80 shr k ); // add 1 to Mask
          PByte(PPixel)^ := 0; // clear first byte of transparent Pixel
          TN_PUInt2(PPixel+1)^ := 0; // clear next two bytes of transparent Pixel
        end;

        Inc( PPixel, 3 ); // to next pixel
      end; // for k := 0 to 7 do // along all bits in Full Mask Bytes
      PMask^ := TN_Byte(CurMaskByte);
      Inc(PMask);

    end; // for j := 0 to NMaskBytes-1 do

    if NRestBits > 0 then
    begin
      CurMaskByte := 0;

      for k := 0 to NRestBits-1 do // along bits in last Byte
      begin
        if (PInteger(PPixel)^ and $00FFFFFF) = SwapedTranspColor then // transparent Pixel
        begin
          Inc( CurMaskByte, $80 shr k ); // add 1 to Mask
          PByte(PPixel)^ := 0; // clear first byte of transparent Pixel
          TN_PUInt2(PPixel+1)^ := 0; // clear next two bytes of transparent Pixel
        end;

        Inc( PPixel, 3 ); // to next pixel
      end; // for k := 0 to NRestBits-1 do // along bits in last Byte
      PMask^ := TN_Byte(CurMaskByte);

    end; // if NRestBits > 0 then
  end; // for i := 0 to RHeight-1 do
  end; // pf24bit: begin

    pf32bit: begin //*************************** not tested !!!

  for i := 0 to RHeight-1 do
  begin
    PPixel := PRasterBytes + i*RRLineSize;
    PMask  := PMaskBytes   + i*RMLineSize;

    for j := 0 to NMaskFullBytes-1 do
    begin
      CurMaskByte := 0;

      for k := 0 to 7 do // along all bits in Full Bytes of Masc scanline
      begin
        if PInteger(PPixel)^ = SwapedTranspColor then // transparent Pixel
        begin
          Inc( CurMaskByte, $80 shr k ); // add 1 to Mask
          PInteger(PPixel)^ := 0; // clear transparent Pixel
        end;

        Inc( PPixel, 4 );
      end; // for k := 0 to 7 do // along all bits in whole Mask Bytes
      PMask^ := TN_Byte(CurMaskByte);
      Inc(PMask);

    end; // for j := 0 to NMaskBytes-1 do

    if NRestBits > 0 then
    begin
      CurMaskByte := 0;

      for k := 0 to NRestBits-1 do // along bits in last Byte
      begin
        if PInteger(PPixel)^ = SwapedTranspColor then // transparent Pixel
        begin
          Inc( CurMaskByte, $80 shr k ); // add 1 to Mask
          PInteger(PPixel)^ := 0; // clear transparent Pixel
        end;

        Inc( PPixel, 4 );
      end; // for k := 0 to NRestBits-1 do // along bits in last Byte
      PMask^ := TN_Byte(CurMaskByte);

    end; // if NRestBits > 0 then
  end; // for i := 0 to RHeight-1 do
  end; // pf32bit: begin

  end; // case RPixFmt of
  end; // with RR do

end; //*** end of procedure TN_RasterObj.CreateMask

//********************************************* TN_RasterObj.CreateOPCRows  ***
// Create Array of OPCRows (One Pixel height Color Rows)
// return number of created Elements in AOPCRows
//
// OPCRows created for pixels with Colors (not Color Indexes!)
// in range (0 - 253) - Blue color hue
//
// Pixels with all other Colors except ANAZColor should be included in neighbour
// OPCRow, Pixels with ANAZColor - should not
//
// Now Self Raster should have 8 bit format, the ability to handle True and
// High Color rasters can be easily added
//
function TN_RasterObj.CreateOPCRows( ANAZColor: integer;
                                       var AOPCRows: TN_OPCRowArray ): integer;
var
  i, j, FreeInd, CurCode: integer;
  CurOPCR: TN_OPCRow;
  PPixel: TN_BytesPtr;
  Pal: Array [0..255] of integer;

  procedure AddCurOPCR(); // local
  // Add CurOPCR to AOPCRows Array,
  // OPCRCode, OPCRMaxLeft, OPCRMinRight should be already OK
  var
    k, CurCode2: integer;
    PPixel2: TN_BytesPtr;
    Label OPCRMinLeftIsOK, OPCRMaxRightIsOK;
  begin
    with RR, CurOPCR do
    begin

    if OPCRCode = 255 then Exit; // is needed if whole Row consists of Static Pixels

    //***** Find OPCRMinLeft

    PPixel2 := PRasterBytes + (RHeight-i-1)*RRLineSize + OPCRMaxLeft-1;

    for k := OPCRMaxLeft-1 downto 0 do // search to the left till end of Cur OPCRow
    begin
      CurCode2 := Pal[PByte(PPixel2)^];
      Dec(PPixel2);

      if (CurCode2 < OPCRCode) or (CurCode2 = ANAZColor) then
      begin
        OPCRMinLeft := k + 1;
        goto OPCRMinLeftIsOK;
      end;
    end; // for k := OPCRMaxLeft-1 downto 0 do // go to the left till another Code
    OPCRMinLeft := 0; // any value from 0 to OPCRMaxLeft-1 is OK

    OPCRMinLeftIsOK: //***** OPCRMinLeft was found, find now OPCRMaxRight

    PPixel2 := PRasterBytes + (RHeight-i-1)*RRLineSize + OPCRMinRight+1;

    for k := OPCRMinRight+1 to RWidth-1 do // search to the right till another Code
    begin
      CurCode2 := Pal[PByte(PPixel2)^];
      Inc(PPixel2);

      if (CurCode2 < OPCRCode) or (CurCode2 = ANAZColor) then
      begin
        OPCRMaxRight := k - 1;
        goto OPCRMaxRightIsOK;
      end;
    end; // for k := OPCRMinRight+1 downto RWidth-1 do // search to the right till another Code
    OPCRMaxRight := RWidth-1; // any value from OPCRMinRight+1 to RWidth-1 is OK

    OPCRMaxRightIsOK: //**************** CurOPCR is OK

    if Length(AOPCRows) <= FreeInd then
      SetLength( AOPCRows, N_Newlength( FreeInd ) );

    OPCRXInd := 0; // is used while Sorting and should be set!
    AOPCRows[FreeInd] := CurOPCR;
    Inc(FreeInd);

    //***** prepare next OPCRow

    OPCRCode := CurCode;
    OPCRMaxLeft := j;
    OPCRMinRight := j;

    end; // with RR, CurOPCR do
  end; // procedure AddCurOPCR(); // local

begin //************************** main body of CreateOPCRows
  FreeInd := 0;

  with RR, CurOPCR do
  begin

  move( PPalColors^, Pal[0], 256*Sizeof(integer) ); // to speed up access

  for i := 0 to RHeight-1 do // loop along Raster Rows (Bottom --> Up!)
  begin

  OPCRCode := 255;
  OPCRY := i;
  PPixel := PRasterBytes + (RHeight-i-1)*RRLineSize; // initial value

  for j := 0 to RWidth-1 do // loop along i-th Raster Row
  begin
    CurCode := Pal[PByte(PPixel)^];
    Inc(PPixel);

    // AAZColor and ANAZColor are always > 253
    if CurCode > 253 then Continue; // Cur Pixel is Static, check next Pixel

    if OPCRCode = 255 then // all prev pixels were Static, first Dyn Pixel
    begin
      OPCRCode := CurCode;
      OPCRMaxLeft := j;
      OPCRMinRight := j;
    end else // not first Dyn Pixel (OPCRCode<=253), check if Codes are the same
    begin

      if OPCRCode = CurCode then // same Code, continue currnet OPCRow
      begin
        OPCRMinRight := j;
      end else // Code Changed, finish current and begin new OPCRow
      begin
        //*** Here: OPCRMaxLeft, OPCRMinRight are OK
        AddCurOPCR();
      end;

    end; // else - not first Dyn Pixel, check if Codes are the same

  end; // for j := 0 to RWidth-1 do // loop along i-th Raster Row

  AddCurOPCR();
  end; // for i := 0 to RHeight-1 do // loop along Raster Rows (Bottom --> Up!)

  Result := FreeInd; // number of Elements in resulting array AOPCRows
  end; // with RR, CurOPCR do
end; //*** end of function TN_RasterObj.CreateOPCRows

//**************************************** TN_RasterObj.ChangeTranspColor  ***
// Set all previously transparent pixels to previous RTranspColor,
// set RTranspColor to given ANewTranspColor and
// remove Mask if ANewTranspColor = N_EmptyColor
//
procedure TN_RasterObj.ChangeTranspColor( ANewTranspColor: integer );
var
  WrkOCanv: TN_OCanvas;
begin
  with RR do
  begin

  if RTranspColor <> N_EmptyColor then // clear previous TranspColor
  begin
    WrkOCanv := TN_OCanvas.Create;

    with WrkOCanv do
    begin
      SetCurCRectSize( RWidth, RHeight, RPixFmt );
      SetPenAttribs( RTranspColor );  // a precaution
      SetBrushAttribs( RTranspColor );
      DrawPixRect( Rect( 0, 0, RWidth, RHeight ) ); // fill by RTranspColor
      Draw( HMDC, CurCRect, CurCRect ); // WrkOCanv MainBuf is OK

      LoadFromOCanv( WrkOCanv, CurCRect, ANewTranspColor );
    end; // with WrkOCanv do

    WrkOCanv.Free;
  end else // just create Mask if needed
  begin
    RTranspColor := ANewTranspColor;
    CreateMask();
  end;

  end; // with RR do

end; //*** end of procedure TN_RasterObj.ChangeTranspColor

//**************************************** TN_RasterObj.LoadFromOCanv  ***
// Load Raster from given Fragment of MainBuf of given OCanvas
//
// AOCanv       - OCanvas Obj - Raster Source
// ASrcFragment - Raster Source Rect
// ATranspColor - Transparent Color
//
procedure TN_RasterObj.LoadFromOCanv( AOCanv: TN_OCanvas; ASrcFragment: TRect;
                                         ATranspColor: integer = N_EmptyColor );
var
  i, DIBSLineSize, DIBSBytesInPixel: integer;
  WrkRaster: TN_Raster;
  PDIBSPix, PSelfPix: TN_BytesPtr;
begin
  with RR, AOCanv, ASrcFragment do
  begin

  Assert( (RPixFmt >= pf8bit) and (RPixFmt <= pf32bit), 'Bad RPixFmt!' );

  WrkRaster := RR;
  InitRasterObj( RType );
  RR := WrkRaster;

  RWidth := N_RectWidth( ASrcFragment );
  RHeight := N_RectHeight( ASrcFragment );
  RTranspColor := ATranspColor;

  PrepRDIBInfoBySelf();
  DIBSLineSize := RRLineSize;
  DIBSBytesInPixel := RDIBInfo.bmi.biBitCount div 8;

  for i := Top to Bottom do // along DIB scanlines
  begin
    PDIBSPix := MPixPtr + i*DIBSLineSize + Left*DIBSBytesInPixel;
    PSelfPix := PRasterBytes + (i-Top)*RRLineSize;
    move( PDIBSPix^, PSelfPix^, RWidth*DIBSBytesInPixel ); // copy one scanline
  end; // for i := Top to Bottom do // along DIB scan lines

  CreateMask(); // create transparency mask if needed

  end; // with RR, AOCanv do

end; //*** end of procedure TN_RasterObj.LoadFromOCanv

//**************************************** TN_RasterObj.CopySelf  ***
// Create and return a copy of Self, possibly with different RasterType
//
function TN_RasterObj.CopySelf( ARType: TN_RasterType ): TN_RasterObj;
var
  ResRType:  TN_RasterType;
begin
  with RR do
  begin

  if ARType = rtDefault then
    ResRType := RType
  else
    ResRType := ARType;

  Result := TN_RasterObj.Create( ResRType );

  Result.RR.RPixFmt       := Self.RR.RPixFmt;
  Result.RR.RWidth        := Self.RR.RWidth;
  Result.RR.RHeight       := Self.RR.RHeight;
  Result.RR.RTranspColor  := Self.RR.RTranspColor;
  Result.RR.RTranspIndex  := Self.RR.RTranspIndex;
  Result.RR.RNumPalColors := Self.RR.RNumPalColors;
  Result.RR.RBMP          := Self.RR.RBMP;

  Result.PrepSelfFields();

  move( PRasterBytes^, Result.PRasterBytes^, RRasterSize );

  if RMaskSize > 0 then
    move( PMaskBytes^, Result.PMaskBytes^, RMaskSize );

  if RNumPalColors > 0 then
    move( PPalColors^, Result.PPalColors^, RNumPalColors*Sizeof(integer) );

  end; // with RR do
end; //***** end of function TN_RasterObj.CopySelf

//**************************************** TN_RasterObj.Create1bitRObj(Range)  ***
// Create and return new pf1bit RasterObj by given Color Range (AMinAColor,AMaxColor)
// (in created raster pixels with ColorIndex = 1 are same as pixels in Self
//  with colors, belongs to (AMinAColor,AMaxColor) )
//
function TN_RasterObj.Create1bitRObj( ARType: TN_RasterType;
                                  AMinColor, AMaxColor: integer ): TN_RasterObj;
var
  i, j, CurColor, CurBit: integer;
  MinR, MinG, MinB, MaxR, MaxG, MaxB, CurR, CurG, CurB: integer;
  PColor: PInteger;
//  PResPixel: TN_BytesPtr;
begin
  with RR do
  begin

  Result := TN_RasterObj.Create( ARType );
  Result.RR.RWidth  := RWidth;
  Result.RR.RHeight := RHeight;
  Result.RR.RPixFmt := pf1bit;
  Result.RR.RNumPalColors := 2;
  Result.PrepSelfFields();

  PColor := Result.PPalColors; // Create two Colors Palette
  PColor^ := 0;
  Inc(PColor);
  PColor^ := $FFFFFF;

  MinR := AMinColor and $FF0000;
  MinG := AMinColor and $00FF00;
  MinB := AMinColor and $0000FF;

  MaxR := AMaxColor and $FF0000;
  MaxG := AMaxColor and $00FF00;
  MaxB := AMaxColor and $0000FF;

  for i := 0 to RHeight-1 do // along source raster scanlines (From Bottom Up)
  begin
//    PResPixel := Result.PRasterBytes + i*Result.RRLineSize;

    for j := 0 to RWidth-1 do // along source raster current scanline
    begin
      CurColor := GetPixelColor( j, i ); // current Pixel Color of source raster
      CurR := CurColor and $FF0000;
      CurG := CurColor and $00FF00;
      CurB := CurColor and $0000FF;
      CurBit := 0;

      if (MinR <= CurR) and (CurR <= MaxR) and
         (MinG <= CurG) and (CurG <= MaxG) and
         (MinB <= CurB) and (CurB <= MaxB)     then CurBit := 1;

      Result.SetPixelValue( j, i, CurBit );

    end; // for j := 0 to RWidth-1 do
  end; // for i := 0 to RHeight-1 do
  end; // with RR do
end; //*** end of function TN_RasterObj.Create1bitRObj(Range)

//**************************************** TN_RasterObj.Create1bitRObj(Array)  ***
// Create and return new pf1bit RasterObj by given Color Array (AMinAColor,AMaxColor)
// (in created raster pixels with ColorIndex = 1 are same as pixels in Self
//  with colors, belongs to (AMinAColor,AMaxColor) )
//
function TN_RasterObj.Create1bitRObj( ARType: TN_RasterType;
                         APColors: PInteger; ANumColors: integer ): TN_RasterObj;
var
  i, j, Ind, CurColor, CurBit: integer;
  PColor: PInteger;
  Str: string;
  HSL: THashedStringList;
//  PResPixel: TN_BytesPtr;
begin
  with RR do
  begin

  Result := TN_RasterObj.Create( ARType );
  Result.RR.RWidth  := RWidth;
  Result.RR.RHeight := RHeight;
  Result.RR.RPixFmt := pf1bit;
  Result.RR.RNumPalColors := 2;
  Result.PrepSelfFields();

  PColor := Result.PPalColors; // Create two Colors Palette
  PColor^ := 0;
  Inc(PColor);
  PColor^ := $FFFFFF;

  HSL := THashedStringList.Create; // for searching Colors in given APColors
  SetLength( Str, 6 );

  for i := 0 to ANumColors-1 do // add APColors to HSL
  begin
    Str := IntToHex( N_SwapRedBlueBytes( APColors^ ), 6 );
    HSL.Add( Str );
    Inc(APColors);
  end;

  for i := 0 to RHeight-1 do // along source raster scanlines (From Bottom Up)
  begin
//    PResPixel := Result.PRasterBytes + i*Result.RRLineSize;

    for j := 0 to RWidth-1 do // along source raster current scanline
    begin
      CurColor := GetPixelColor( j, i ); // current Pixel Color of source raster
      CurBit := 0;
      Str := IntToHex( CurColor, 6 );
      Ind := HSL.IndexOf( Str ); // search for CurColor in APColors
      if Ind >= 0 then CurBit := 1;

      Result.SetPixelValue( j, i, CurBit );
    end; // for j := 0 to RWidth-1 do
  end; // for i := 0 to RHeight-1 do
  end; // with RR do
end; //*** end of function TN_RasterObj.Create1bitRObj(Array)

//**************************************** TN_RasterObj.Create8bitRObj  ***
// Create and return new pf8bit RasterObj by Self and two given arrays of Colors.
//
// if Color of some Pixel in Self (Sorce) Raster is APDynColors[i] then
// Color Index and Color in Resulting RasterObj Raster will be = i
//   ( In created raster, pixels with Color(Index) = i are same as pixels in Self
//     with Color =  APDynColors[i] ),
// if Color belongs to any of APStatColors, Color=ANAZColor, ColorIndex = 254,
// otherwise (Color not belongs to APDynColors, APStatColors) -
//                                           Color=AAZColor, ColorIndex = 255
//
// if AMode bit0 = 0 then all dynamic (with ColorIndex in (0-253)) pixels
// in Self (Source) Raster would be converted to Self.RTranspColor
// (AMode bit0 = 1 means that source raster would NOT be changed)
//
// Remarks.
// 1. Pixels with AAZColor are Static Pixels that can be included in any
//    (some neighbour) Active Zone, Pixels with ANAZColor are Static Pixels
//    that would NOT be included in any Active Zone.
//
// 2. Because of blue palette, pixels with ColorIndex <= 253 in Resulting
//    RasterObj have Color=ColorIndex. It is really used because some other
//    procedures (such as CreateOPCRows) works with Colors (not with Color Indexes)
//    (to be able to handle not only 8bit Rasters or 8bit Rasters with
//     arbitrary Color Indexes (e.g. prepared in CorelDraw) )
//
// 3. APStatColors may be nil and may contain Empty Colors
//
function TN_RasterObj.Create8bitRObj( ARType: TN_RasterType; APDynColors: PInteger;
                                    ANumDynColors: integer; APStatColors: PInteger;
                   ANumStatColors, AAZColor, ANAZColor, AMode: integer ): TN_RasterObj;
var
  i, j, DynInd, StatInd, CurColor, TranspValue, PixValue: integer;
  Str: string;
  PResPixel: TN_BytesPtr;
  DynHSL, StatHSL: THashedStringList;
  BluePal: array [0..255] of integer;
begin
  with RR do
  begin

  Result := TN_RasterObj.Create( ARType );
  Result.RR.RWidth  := RWidth;
  Result.RR.RHeight := RHeight;
  Result.RR.RPixFmt := pf8bit;
  Result.RR.RNumPalColors := 256;
  Result.RR.RTranspColor := Self.RR.RTranspColor;
  Result.RR.RTranspIndex := 255;
  Result.PrepSelfFields();

  for i := 0 to 253 do // Create Blue Palette for first 253 indesex
    BluePal[i] := i shl 16;

  BluePal[254] := ANAZColor; // Not Active Zone Color
  BluePal[255] := AAZColor;  // Active Zone Color

  Result.SetPalColors( @BluePal[0], 256 );

  TranspValue := 0; // to avoid warning (ColorValue or ColorIndex)

  if (AMode and 01) = 0 then // Calc TranspValue for changing Self dyn pixels
  begin
    if RPixFmt <= pf8bit then
    begin

      if RTranspIndex = -1 then // Error! - no Palette Entry for RTranspColor
      begin
        Result.Free;
        Result := nil;
        Exit;
      end else
        TranspValue := RTranspIndex;

    end else if RPixFmt = pf16bit then
      Assert( False, 'Not implemented!' )
    else if (RPixFmt = pf24bit) or (RPixFmt = pf32bit) then
      TranspValue := N_SwapRedBlueBytes( RTranspColor )
    else // some other RPixFmt
      Assert( False, 'Not implemented!' );

    //***** Here: TranspValue (TranspColor or TranspIndex) is OK
  end; // if (AMode and 01) = 0 then // Calc TranspValue for changing Self pixels

  DynHSL  := THashedStringList.Create; // for searching Colors in given APDynColors
  StatHSL := THashedStringList.Create; // for searching Colors in given APStatColors
  SetLength( Str, 6 );

  for i := 0 to ANumDynColors-1 do // add APDynColors to DynHSL
  begin
{
    if i = 40 then
      N_i := 0;
    Str[1] := Chr(APDynColors^ and $FF);          // Red
    Str[2] := Chr((APDynColors^ shr 8) and $FF);  // Green
    Str[3] := Chr((APDynColors^ shr 16) and $FF); // Blue

  N_i := integer(Str[1]);
  N_i := integer(Str[2]);
  N_i := integer(Str[3]);
}
  Str := IntToHex( N_SwapRedBlueBytes( APDynColors^ ), 6 );

    DynHSL.Add( Str );
    Inc(APDynColors);
  end;

  if APStatColors = nil then // Stat Colors are not given (a precaution)
    ANumStatColors := 0;

  for i := 0 to ANumStatColors-1 do // add APStatColors to StatHSL
  begin
    if APStatColors^ = N_EmptyColor then Continue; // skip Empty colors
    Str := IntToHex( N_SwapRedBlueBytes( APStatColors^ ), 6 );

    StatHSL.Add( Str );
    Inc(APStatColors);
  end;
  //  ANumStatColors := StatHSL.Count; // because of possible Empty Colors

{
  Str := HSL.Strings[26];
  N_i := integer(Str[1]);
  N_i := integer(Str[2]);
  N_i := integer(Str[3]);
  N_i := HSL.IndexOf( Str );

  Str := HSL.Strings[27];
  N_i := integer(Str[1]);
  N_i := integer(Str[2]);
  N_i := integer(Str[3]);
  N_i := HSL.IndexOf( Str );

  Str := HSL.Strings[40];
  N_i := integer(Str[1]);
  N_i := integer(Str[2]);
  N_i := integer(Str[3]);
  N_i := HSL.IndexOf( Str );


  Str[3] := Chr($FE);
  Str[2] := Chr($FE);

  Str[1] := Chr($7F);
  N_i := HSL.IndexOf( Str ); // search for CurColor in APDynColors

  Str[1] := Chr($80);
  N_i := HSL.IndexOf( Str ); // search for CurColor in APDynColors

  Str[1] := Chr($81);
  N_i := HSL.IndexOf( Str ); // search for CurColor in APDynColors
}

  for i := 0 to RHeight-1 do // along source raster scanlines (From Bottom Up)
  begin
    PResPixel := Result.PRasterBytes + i*Result.RRLineSize;

    for j := 0 to RWidth-1 do // along source raster current scanline
    begin
      CurColor := GetPixelColor( j, i ); // current Pixel Color of source raster

//      Str[3] := Chr(CurColor and $FF);          // Blue
//      Str[2] := Chr((CurColor shr 8) and $FF);  // Green
//      Str[1] := Chr((CurColor shr 16) and $FF); // Red

      Str := IntToHex( CurColor, 6 );
      DynInd := DynHSL.IndexOf( Str ); // search for CurColor in APDynColors

      if ((AMode and 01) = 0) and
         (DynInd <> -1) then // found, set all found Pixels of source raster to TranspValue
        SetPixelValue( j, i, TranspValue );

      //***** Set Resulting Raster ColorIndex to index in APDynColors
      //      or to 254 if CurColor is in StatHSL
      //      or to 255 if not found in DynHSL and in StatHSL
      //      (all dynamic pixels set to Ind, all static pixels to 254 or 255)

      if DynInd = -1 then
      begin
        StatInd := StatHSL.IndexOf( Str ); // search for CurColor in APStatColors
        if StatInd = -1 then PixValue := 255  // AAZColor  - Active Zone Color
                        else PixValue := 254; // ANAZColor - Not Active Zone Color
      end else
        PixValue := DynInd;

      PByte(PResPixel + j)^ := PixValue; // Resulting Pixel Value

    end; // for j := 0 to RWidth-1 do
  end; // for i := 0 to RHeight-1 do

  DynHSL.Free;
  StatHSL.Free;
  end; // with RR do
end; //*** end of function TN_RasterObj.Create8bitRObj

//**************************************** TN_RasterObj.ConvTo8bitRObj  ***
// Convert self to pf8bit RObj
// (now number of different colors in Self should be less than 256!)
//
function TN_RasterObj.ConvTo8bitRObj( ARType: TN_RasterType ): TN_RasterObj;
var
  i, j, Ind, CurColor: integer;
  Str: string;
  PResPixel: TN_BytesPtr;
  HSL: THashedStringList;
  PPal: PInteger;
begin
  with RR do
  begin

  if RPixFmt <= pf8bit then
  begin
    Result := CopySelf(); // convertion is not needed
    Exit;
  end;

  Result := TN_RasterObj.Create( ARType );
  Result.RR.RWidth  := RWidth;
  Result.RR.RHeight := RHeight;
  Result.RR.RPixFmt := pf8bit;
  Result.RR.RTranspColor := Self.RR.RTranspColor;

  Result.PrepSelfFields();


  HSL := THashedStringList.Create; // for searching Colors
  SetLength( Str, 3 );

  for i := 0 to RHeight-1 do // along source raster scanlines (From Bottom Up)
  begin
    PResPixel := Result.PRasterBytes + i*Result.RRLineSize;

    for j := 0 to RWidth-1 do // along source raster current scanline
    begin
      CurColor := GetPixelColor( j, i ); // current Pixel Color of source raster
// UNICODE!!!
      move( CurColor, Str[1], 3 );

      Ind := HSL.IndexOf( Str ); // search for CurColor in HSL

      if Ind = -1 then // not found, add new entry in HSL
      begin
        HSL.Add( Str );
        Ind := HSL.Count - 1;

        if Ind > 255 then // error, more than 256 different Colors!
        begin
          FreeAndNil( Result );
          Exit;
        end;
      end; // if Ind = -1 then // not found, add new entry in HSL

      PByte(PResPixel + j)^ := Ind; // Cur Pixel ColorIndex
    end; // for j := 0 to RWidth-1 do
  end; // for i := 0 to RHeight-1 do

  Result.RR.RNumPalColors := HSL.Count;
  Result.PrepSelfFields(); // just for setting PPalColors
  PPal := Result.PPalColors;

  for i := 0 to HSL.Count-1 do // create Result Palette from HSL
  begin
    PPal^ := 0;
    move( HSL.Strings[i][1], PPal^, 3 );
    Inc(PPal);
  end; // for i := 0 to HSL.Count do

  Result.CreateMask(); // just for setting RTranspIndex

  HSL.Free;
  end; // with RR do
end; //*** end of function TN_RasterObj.ConvTo8bitRObj

//********************************************** TN_RasterObj.Draw  ***
// Draw Self in given Device Context ADC
//
// ADC        - Windows Device Context
// ADstRect   - Destination Rect
//              ( Right, Bottom = -1 means SrcSizes * ARScale )
// ASrcRect   - Source Rect, (0,0) - UpperLeft Raster Pixel,
//              Right, Bottom < 0 means RRasterSizes + Right(Bottom)
// ARScale    - Raster Scale ( DstPixSize = ARScale*SrcPixSize)
// ARPlace    - Raster Place in ADstRect ( rpUpperLeft, rpCenter, rpRepeat )
//
procedure TN_RasterObj.Draw( ADC: HDC; ADstRect, ASrcRect: TRect;
                                       ARScale: float; APPlace: TN_PictPlace );
var
  SavedbiBitCount, SavedbiCompression, ROP: integer;
  SrcWidth, SrcHeight, ScaledRasterWidth, ScaledRasterHeight: integer;
  DstWidth, DstHeight, FullDstWidth, FullDstHeight: integer;
  TmpRect: TRect;
// PTmpp: PAnsiChar;
begin
  with RR, RDIBInfo, RDIBInfo.bmi do
  begin
    PrepRDIBInfoBySelf();

    ASrcRect := N_RectCalc( ASrcRect, RWidth, RHeight );
    SrcWidth  := ASrcRect.Right - ASrcRect.Left + 1;
    SrcHeight := ASrcRect.Bottom - ASrcRect.Top + 1;

    with ADstRect do
    begin
      if (Right = -1) or (Bottom = -1) then // set Dst size by scaled Src size
      begin
        if ARScale = 0 then ARScale := 1.0; // a precaution
        APPlace := ppUpperLeft;             // a precaution
      end; // if (Right = -1) or (Bottom = -1) then

      ScaledRasterWidth  := Round(SrcWidth*ARScale);
      ScaledRasterHeight := Round(SrcHeight*ARScale);

      if Right  = -1 then Right  := Left + ScaledRasterWidth  - 1;
      if Bottom = -1 then Bottom := Top  + ScaledRasterHeight - 1;

      FullDstWidth  := Right - Left + 1;
      FullDstHeight := Bottom - Top + 1;

      if ARScale = 0 then // strech mode
      begin
        APPlace   := ppUpperLeft;   // a precaution
        DstWidth  := FullDstWidth;  // temporary value if RScale <> 0
        DstHeight := FullDstHeight; // temporary value if RScale <> 0
      end else // RScale is given
      begin
        DstWidth  := ScaledRasterWidth;
        DstHeight := ScaledRasterHeight;
      end;
    end; // with ADstRect do

    if APPlace = ppRepeat then // fill whole ADstRect by repeating Raster
    begin
      TmpRect.Left  := 0;
      TmpRect.Right := ScaledRasterWidth-1;
      while TmpRect.Left <= ADstRect.Right do // Horizontal loop
      begin
        TmpRect.Top := 0;
        TmpRect.Bottom := ScaledRasterHeight-1;
        while TmpRect.Top <= ADstRect.Bottom do  // Vertical loop
        begin
          Draw( ADC, TmpRect, ASrcRect, ARScale, ppUpperLeft );
          TmpRect := N_RectShift( TmpRect, 0, ScaledRasterHeight );
        end; // while TmpRect.Top <= DstRect.Bottom do

        TmpRect := N_RectShift( TmpRect, ScaledRasterWidth, 0 );
      end; // while TmpRect.Left <= DstRect.Right do
      N_RasterChangedRect := ADstRect; // is needed in OCanvas.DrawPixRaster

      Exit; // all done
    end; // if Mode = rmRepeat then // fill whole DstRect by repeating Raster

    if APPlace = ppCenter then // place raster in the middle of ADstRect
    begin
      if ScaledRasterWidth < FullDstWidth then
        Inc( ADstRect.Left, (FullDstWidth-ScaledRasterWidth) div 2 );

      if ScaledRasterHeight < FullDstHeight then
        Inc( ADstRect.Top, (FullDstHeight-ScaledRasterHeight) div 2 );
    end; // if Mode = rmCenter then // place raster in the middle of DstRect

    with N_RasterChangedRect do // is needed in OCanvas.DrawPixRaster
    begin
      TopLeft := ADstRect.TopLeft;
      Right   := Left + DstWidth - 1;
      Bottom  := Top + DstHeight - 1;
    end;

    ROP := SRCCOPY;

    if RTranspColor <> N_EmptyColor then // Clear nontransparent pixels in ADC
    begin
      if RPixFmt <= pf8bit then // Raster with Palette, mask is not needed
      begin
        //*** prepare palette for Clearing nontransparent pixels
        FillChar( PalEntries[0], 1024, 0 );  // nontransparent pixels
        PalEntries[RTranspIndex] := $FFFFFF; // transparent pixels

        //*** error in y- coord!
        StretchDIBits( ADC, ADstRect.Left, ADstRect.Top, DstWidth, DstHeight,
             ASrcRect.Left, RHeight-ASrcRect.Top-SrcHeight, SrcWidth, SrcHeight,
                 PRasterBytes, PBitmapInfo(@RDIBInfo)^, DIB_RGB_COLORS, SRCAND );

        //*** prepare palette for drawing nontransparent pixels
        move( PPalColors^, PalEntries[0], RNumPalColors*Sizeof(Integer) );
        PalEntries[RTranspIndex] := $000000; // transparent pixels
      end // if RPixFmt <= pf8bit then // Raster with Palette, mask is not needed
      else // True or High Color Raster, mask is needed
      begin
        SavedbiBitCount    := biBitCount;     // mask is pf1bit raster
        SavedbiCompression := biCompression;

        biBitCount := 1;          // set temporary
        biCompression := BI_RGB;  // set temporary
        PalEntries[0] := $000000; // nontransparent pixels
        PalEntries[1] := $FFFFFF; // transparent pixels

        StretchDIBits( ADC, ADstRect.Left, ADstRect.Top, DstWidth, DstHeight,
               ASrcRect.Left, RHeight-ASrcRect.Top-SrcHeight, SrcWidth, SrcHeight,
                 PMaskBytes, PBitmapInfo(@RDIBInfo)^, DIB_RGB_COLORS, SRCAND );

        biBitCount    := SavedbiBitCount;    // restore
        biCompression := SavedbiCompression;
      end; // else // True or High Color Raster, mask is needed
      ROP := SRCINVERT; // for drawing nontransp pixels
    end; // if RTranspColor <> N_EmptyColor then // Clear nontransparent pixels

    //*** draw all pixels by SRCCOPY or nontransp pixels by SRCINVERT
    StretchDIBits( ADC, ADstRect.Left, ADstRect.Top, DstWidth, DstHeight,
             ASrcRect.Left, RHeight-ASrcRect.Top-SrcHeight, SrcWidth, SrcHeight,
                   PRasterBytes, PBitmapInfo(@RDIBInfo)^, DIB_RGB_COLORS, ROP );

  end; // with RR, RDIBInfo, RDIBInfo.bmi do
end; //*** end of procedure TN_RasterObj.Draw

//****************************************** TN_RasterObj.CalcBrighHistData ***
// Calculate in given ABrighHistValues Array Brightness Data:
// ABrighHistValues[i] is normalized number of pixels with Brightness=i (0<=i<=255),
// ( Max(ABrighHistValues[i],0<=i<=255) = 1.0 )
//
procedure TN_RasterObj.CalcBrighHistData( var ABrighHistValues: TN_FArray );
var
  i, iy, CurBrigh: integer;
  MaxValue: double;
  RowRGBValues: TN_BArray;
// PTmpp: PAnsiChar;
begin
  if Length(ABrighHistValues) < 256 then
    SetLength( ABrighHistValues, 256 );

  SetLength( RowRGBValues, 3*RR.RWidth );

  ZeroMemory( ABrighHistValues, 256 * SizeOf(Float) );
  MaxValue := -1;

  for iy := 0 to RR.RHeight-1 do // along all Pixel Rows
  begin
    GetPixRGBValuesRect( RowRGBValues, 0, iy, RR.RWidth-1, iy );

    for i := 0 to RR.RWidth-1 do // along one Row, add Data for current Row
    begin
      CurBrigh := Round( 0.59*RowRGBValues[3*i+1] +  // Green
                         0.30*RowRGBValues[3*i+2] +  // Red
                         0.11*RowRGBValues[3*i+0] ); // Blue
      ABrighHistValues[CurBrigh] := ABrighHistValues[CurBrigh] + 1;

      if ABrighHistValues[CurBrigh] > MaxValue then
        MaxValue := ABrighHistValues[CurBrigh];

    end; // for i := 0 to RR.RWidth-1 do // add Data for current Row

  end; // for iy := 0 to RR.RHeight-1 do // along all Pixel Rows

  for i := 0 to 255 do // Normalize ABrighHistValues
    ABrighHistValues[i] := ABrighHistValues[i] / MaxValue;

end; //*** end of procedure TN_RasterObj.CalcBrighHistData


//********************* TN_DIBObj class methods  **********************

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Create(Size)
//************************************************** TN_DIBObj.Create(Size) ***
// Object constructor by given size and pixel format
//
//     Parameters
// AWidth     - resulting DIB width
// AHeight    - resulting DIB height
// APixFmt    - resulting DIB Main pixel format
// AFillColor - resulting DIB all pixels color (not defined if -1)
// AExPixFmt  - resulting DIB Extended pixel format
// ANumBits   - resulting DIB DIBNumBits value (needed only for epfGray16 and 
//              epfColor48 formats)
//
constructor TN_DIBObj.Create( AWidth, AHeight: integer; APixFmt: TPixelFormat;
                              AFillColor: integer = -1; AExPixFmt: TN_ExPixFmt = epfBMP;
                              ANumBits: integer = 0 );
begin
  PrepEmptyDIBObj( AWidth, AHeight, APixFmt, AFillColor, AExPixFmt, ANumBits );

  if AFillColor <> -1 then // fill self by given AColor
  begin

    if DIBOCanv <> nil then // fill by GDI (by Drawing)
    begin
      DIBOCanv.SetBrushAttribs( AFillColor );
      DIBOCanv.DrawPixFilledRect( DIBRect );
    end else // DIBOCanv <> nil, fill by FillRectByPixValue
      FillRectByPixValue( DIBRect, AFillColor );

  end; // if AColor <> -1 then // fill self by given AColor
end; //*** end of Constructor TN_DIBObj.Create(Size)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Create(DIB3)
//************************************************** TN_DIBObj.Create(DIB3) ***
// Object constructor by given DIB rectangle fragment and pixel format
//
//     Parameters
// ASrcDIBObj - source DIB for initialization after creation
// ASrcRect   - source DIB rectangle fragment coordinates
// APixFmt    - resulting DIB Main Pixel Format
// AExPixFmt  - resulting DIB Extended Pixel Format
// ANumBits   - resulting DIB DIBNumBits value (needed only for epfGray16 and 
//              epfColor48 formats)
//
constructor TN_DIBObj.Create( ASrcDIBObj: TN_DIBObj; ASrcRect: TRect;
                              APixFmt: TPixelFormat; AExPixFmt: TN_ExPixFmt = epfBMP;
                              ANumBits: integer = 0 );
var
  AbsRect: TRect;
begin
  with ASrcDIBObj.DIBInfo.bmi do // conv possibly relative coords of ASrcRect to abs (real, normal) coords
    AbsRect := N_GetAbsRect( ASrcRect, Rect(0, 0, biWidth-1, biHeight-1) );

  if ANumBits = 0 then // use ASrcDIBObj.DIBNumBits
    ANumBits := ASrcDIBObj.DIBNumBits;

  PrepEmptyDIBObj( N_RectWidth( AbsRect ), N_RectHeight( AbsRect ), APixFmt, -1, AExPixFmt, ANumBits );
  Self.DIBInfo.bmi.biXPelsPerMeter := ASrcDIBObj.DIBInfo.bmi.biXPelsPerMeter;
  Self.DIBInfo.bmi.biYPelsPerMeter := ASrcDIBObj.DIBInfo.bmi.biYPelsPerMeter;

  CopyRectAuto( Point(0,0), ASrcDIBObj, AbsRect );
end; //*** end of Constructor TN_DIBObj.Create(DIB3)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Create(DIB1)
//************************************************** TN_DIBObj.Create(DIB1) ***
// Object constructor by given DIB (create source DIB copy)
//
//     Parameters
// ASrcDIBObj - source DIB for initialization after creation
//
constructor TN_DIBObj.Create( ASrcDIBObj: TN_DIBObj );
begin
  Create( ASrcDIBObj, Rect(0,0,-1,-1), ASrcDIBObj.DIBPixFmt, ASrcDIBObj.DIBExPixFmt, ASrcDIBObj.DIBNumBits );
end; //*** end of Constructor TN_DIBObj.Create(DIB1)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Create(DIB1Flags)
//********************************************* TN_DIBObj.Create(DIB1Flags) ***
// Object constructor by given DIB, Flip/Rotate Flags and Pixel Format
//
//     Parameters
// ASrcDIBObj       - source DIB, only ASrcDIBObj.DIBSize field is used
// AFlipRotateFlags - given Flip/Rotate Flags
// APixFmt          - resulting DIB Main pixel format
// AFillColor       - resulting DIB all pixels color (not defined if -1)
// AExPixFmt        - resulting DIB Extended pixel format
// ANumBits         - resulting DIB DIBNumBits value (needed only for epfGray16 
//                    and epfColor48 formats)
//
// Self content is filled by AFillColor or is not defined if AFillColor = -1
//
constructor TN_DIBObj.Create( ASrcDIBObj: TN_DIBObj; AFlipRotateFlags: integer;
                              APixFmt: TPixelFormat; AFillColor: integer = -1;
                              AExPixFmt: TN_ExPixFmt = epfBMP; ANumBits: integer = 0 );
var
  NeededSize: TPoint;
begin
  NeededSize := ASrcDIBObj.DIBSize;
  if (AFlipRotateFlags and N_FlipDiagBit) <> 0 then
    N_SwapTwoInts( @NeededSize.X, @NeededSize.Y );

  if ANumBits = 0 then // use ASrcDIBObj.DIBNumBits
    ANumBits := ASrcDIBObj.DIBNumBits;

  Create( NeededSize.X, NeededSize.Y, APixFmt, AFillColor, AExPixFmt, ANumBits );

  if (AFlipRotateFlags and N_FlipDiagBit) <> 0 then // Swap resolutions
  begin
    DIBInfo.bmi.biXPelsPerMeter := ASrcDIBObj.DIBInfo.bmi.biYPelsPerMeter;
    DIBInfo.bmi.biYPelsPerMeter := ASrcDIBObj.DIBInfo.bmi.biXPelsPerMeter;
  end else // set original Resolution (it was lost in previous Constructor)
  begin
    DIBInfo.bmi.biXPelsPerMeter := ASrcDIBObj.DIBInfo.bmi.biXPelsPerMeter;
    DIBInfo.bmi.biYPelsPerMeter := ASrcDIBObj.DIBInfo.bmi.biYPelsPerMeter;
  end;
end; //*** end of Constructor TN_DIBObj.Create(DIB1Flags)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Create(Bitmap)
//************************************************ TN_DIBObj.Create(Bitmap) ***
// Object constructor by given Bitmap and transparent color
//
//     Parameters
// ABitmap      - source Bitmap for initialization after creation
// ATranspColor - resulting DIB transparent color
//
constructor TN_DIBObj.Create( ABitmap: TBitmap; ATranspColor: integer = -1 );
begin
  LoadFromBitmap( ABitmap );
  DIBTranspColor := ATranspColor;
end; //*** end of Constructor TN_DIBObj.Create(Bitmap)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Create(OCanv)
//************************************************* TN_DIBObj.Create(OCanv) ***
// Object constructor by given Canvas rectangle fragment and pixel format
//
//     Parameters
// ASrcOCanv - canvas DIB for initialization after creation
// ASrcRect  - canvas DIB rectangle fragment coordinates
// APixFmt   - resulting DIB pixel format
//
// Resulting DIB has always epfBMP format!
//
constructor TN_DIBObj.Create( ASrcOCanv: TN_OCanvas; ASrcRect: TRect; APixFmt: TPixelFormat );
var
  AbsRect: TRect;
begin
  AbsRect := N_GetAbsRect( ASrcRect, ASrcOCanv.CurCRect );

  PrepEmptyDIBObj( N_RectWidth( AbsRect ), N_RectHeight( AbsRect ), APixFmt );

  N_CopyRect( DIBOCanv.HMDC, Point(0,0), ASrcOCanv.HMDC, AbsRect );
end; //*** end of Constructor TN_DIBObj.Create(OCanv)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Create(File)
//************************************************** TN_DIBObj.Create(File) ***
// Object constructor by file name (DIB type is defined by image format in given
// file)
//
//     Parameters
// AFileName - raster file name to initialized after creation
//
constructor TN_DIBObj.Create( AFileName: string );
begin
  LoadFromFile( AFileName );
end; //*** end of Constructor TN_DIBObj.Create(File)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Destroy
//******************************************************* TN_DIBObj.Destroy ***
//
//
destructor TN_DIBObj.Destroy;
begin
  ClearSelfObjects();
  Inherited;
end; //*** end of destructor TN_DIBObj.Destroy

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\ClearSelfObjects
//********************************************** TN_DIBObj.ClearSelfObjects ***
// Clear Self Objects (DIB and OCanv)
//
procedure TN_DIBObj.ClearSelfObjects();
begin
  if DIBOCanv <> nil then
  begin
    FreeAndNil( DIBOCanv );
  end;

  DIBPixels := nil;

  if DIBHandle <> 0 then
  begin
    N_b := Windows.DeleteObject( DIBHandle );

    if not N_b then
      raise Exception.Create( 'Bad DIBHandle in ClearSelfObjects!' );

    DIBHandle := 0;
  end; // if DIBHandle <> 0 then
end; // procedure TN_DIBObj.ClearSelfObjects

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CreateSelfOCanv
//*********************************************** TN_DIBObj.CreateSelfOCanv ***
// Create DIBOCanv for Drawing in Self using OCanv methods
//
// DIBInfo should be OK before DIBOCanv creation DIBOCanv is not the Owner of 
// DIBHandle and DIBHandle would not be freed in DIBOCanv.Destroy because 
// DIBOCanv.HMDS = 0 (DIBHandle is used instead of DIBOCanv.HMDS)
//
procedure TN_DIBObj.CreateSelfOCanv();
begin
  if DIBOCanv <> nil then Exit; // was already created, nothing todo

  if (DIBExPixFmt = epfGray16) or (DIBExPixFmt = epfColor48) then // no corresponding OCanv Format,
    Exit;                                                         // DIBOCanv should be nil

  DIBOCanv := TN_OCanvas.Create();
  with DIBOCanv, DIBInfo, DIBInfo.bmi do
  begin
    CCRSize.X := biWidth;
    CCRSize.Y := biHeight;
    CurCRect := Rect( 0, 0, biWidth-1, biHeight-1 );

    CPixFmt := DIBPixFmt;
    if DIBExPixFmt = epfGray8 then
      CPixFmt := pf8bit;

    if DIBHandle <> 0 then
    begin
      HMIniBMP := SelectObject( HMDC, DIBHandle );
      Assert( HMIniBMP <> 0, 'Bad DIBHandle' );
    end;
  end; // with DIBOCanv, DIBInfo, DIBInfo do
end; // procedure TN_DIBObj.CreateSelfOCanv

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\PrepSMatrDescr
//************************************************ TN_DIBObj.PrepSMatrDescr ***
// Prepare given TN_SMatrDescr record by Self attributes
//
//     Parameters
// APSMatrDescr - pointer to TN_SMatrDescr record to prepare
// PMatrSize    - if <> nil, pointer to Matrix Size in bytes (should be assigned
//                on output)
//
procedure TN_DIBObj.PrepSMatrDescr( APSMatrDescr: TN_PSMatrDescr; APMatrSize: PInteger = nil );
begin
  if APSMatrDescr = nil then Exit; // a precation

  with APSMatrDescr^ do
  begin
    SMDPBeg    := PRasterBytes;
    SMDNumX    := DIBSize.X;
    SMDNumY    := DIBSize.Y;
    SMDElSize  := GetElemSizeInBytes();
    SMDStepX   := SMDElSize;
    SMDStepY   := RRLineSize;
    SMDBegIX   := 0;
    SMDEndIX   := SMDNumX - 1;
    SMDBegIY   := 0;
    SMDEndIY   := SMDNumY - 1;
    SMDNumBits := DIBNumBits;

    if SMDElSize >= 6 then
      SMDSElemType := setInt64
    else
      SMDSElemType := setInteger;

    if APMatrSize <> nil then // assign Matrix Size in bytes
      APMatrSize^ := SMDNumY*SMDStepY;
  end; // with APSMatrDescr^ do
end; // procedure TN_DIBObj.PrepSMatrDescr

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\PrepSMatrDescrByFlags
//***************************************** TN_DIBObj.PrepSMatrDescrByFlags ***
// Prepare given TN_PSMatrDescr record by Self attributes and given Flip/Rotate 
// Flags
//
//     Parameters
// APSMatrDescr     - pointer to TN_SMatrDescr record to prepare
// AFlipRotateFlags - Flip/Rotate Flags
// PMatrSize        - if <> nil, pointer to resulting Rotated Matrix Size in 
//                    bytes
//
// Resulting APSMatrDescr^ may be used to Flip and Rotate Self by 
// AFlipRotateFlags, Self.DIBSize.X(Y) is always equal to 
// APSMatrDescr^.SMDNumX(Y) for any AFlipRotateFlags
//
procedure TN_DIBObj.PrepSMatrDescrByFlags( APSMatrDescr: TN_PSMatrDescr;
                         AFlipRotateFlags: integer; APMatrSize: PInteger = nil );
begin
  if APSMatrDescr = nil then Exit; // a precation
  PrepSMatrDescr( APSMatrDescr );

  with APSMatrDescr^ do
  begin
    if (AFlipRotateFlags and N_FlipDiagBit) <> 0 then // Swap all X and Y fields
    begin
      if (AFlipRotateFlags and N_FlipHorBit) <> 0 then
      begin
        N_SwapTwoInts( @SMDBegIY, @SMDEndIY );
      end;

      if (AFlipRotateFlags and N_FlipVertBit) <> 0 then
      begin
        N_SwapTwoInts( @SMDBegIX, @SMDEndIX );
      end;

      SMDStepY := SMDStepX;
      SMDStepX := ((SMDNumY*SMDElSize+3) shr 2) shl 2; // should be DWord aligned
      if APMatrSize <> nil then
        APMatrSize^ := SMDNumX*SMDStepX; // elements are along columns
    end else // Only Horizontal and/or Vertical Flip, X and Y fields should not be swaped
    begin
      if (AFlipRotateFlags and N_FlipHorBit) <> 0 then
      begin
        N_SwapTwoInts( @SMDBegIX, @SMDEndIX );
      end;

      if (AFlipRotateFlags and N_FlipVertBit) <> 0 then
      begin
        N_SwapTwoInts( @SMDBegIY, @SMDEndIY );
      end;

      if APMatrSize <> nil then
        APMatrSize^ := SMDNumY*SMDStepY; // elements are along rows
    end;

  end; // with APSMatrDescr^ do
end; // procedure TN_DIBObj.PrepSMatrDescrByFlags

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\PrepSMatrDescrByRect
//****************************************** TN_DIBObj.PrepSMatrDescrByRect ***
// Prepare given TN_PSMatrDescr record by given Self Rect
//
//     Parameters
// APSMatrDescr - pointer to TN_SMatrDescr record to prepare
// ASelfRect    - given Self Rect
//
procedure TN_DIBObj.PrepSMatrDescrByRect( APSMatrDescr: TN_PSMatrDescr; ASelfRect: TRect );
var
  Rect: TRect;
begin
  if APSMatrDescr = nil then Exit; // a precation

  Rect := ASelfRect;
  N_IRectAnd( Rect, DIBRect );

  PrepSMatrDescr( APSMatrDescr );

  with APSMatrDescr^, Rect do
  begin
    SMDBegIX   := Left;
    SMDEndIX   := Right;

    if DIBInfo.bmi.biHeight > 0 then // bottom-up DIB, origin is the lower left corner
    begin
      SMDBegIY   := DIBSize.Y - 1 - Bottom;
      SMDEndIY   := DIBSize.Y - 1 - Top;
    end else // DIBInfo.bmi.biHeight < 0, top-down DIB, origin is the upper left corner
    begin
      SMDBegIY   := Top;
      SMDEndIY   := Bottom;
    end;

  end; // with APSMatrDescr^ do
end; // procedure TN_DIBObj.PrepSMatrDescrByRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SetDIBNumBits
//************************************************* TN_DIBObj.SetDIBNumBits ***
// Set given ANumBits and update pixels if needed
//
procedure TN_DIBObj.SetDIBNumBits( ANumBits: integer );
var
  MinHistInd, MaxHistInd, MaxVal: Integer;
  BrighHistValues: TN_IArray;
  SMD: TN_SMatrDescr;
begin
  if DIBExPixFmt <> epfGray16 then Exit; // is needed only for 16 bit images
  Assert( (ANumBits >= 9) and (ANumBits <= 16), Format(
                          'SetDIBNumBits: Bad SetDIBNumBits=5d', [ANumBits] ) );

  MaxVal := (1 shl ANumBits) - 1;
  DIBNumBits := 16; // is needed for CalcBrighHistNData
  CalcBrighHistNData( BrighHistValues, nil, @MinHistInd, @MaxHistInd, nil, 16 );

  if MaxHistInd <= MaxVal then // no need to update pixels
  begin
    DIBNumBits := ANumBits;
    Exit; // all done
  end else // MaxHistInd > MaxVal, try to XOR pixels
  begin
    DIBNumBits := Ceil( Log2( MaxHistInd + 1 ) );
    XORPixels( $0FFFF ); // if DIBNumBits < 16 high bits remains to be zero
    CalcBrighHistNData( BrighHistValues, nil, @MinHistInd, @MaxHistInd, nil, 16 );

    if MaxHistInd <= MaxVal then // pixels will be OK after once more XOR (XOR back)
    begin
      DIBNumBits := ANumBits;
      XORPixels( $0FFFF ); // if DIBNumBits < 16 high bits remains to be zero
      Exit; // all done
    end else // MaxHistInd > MaxVal, XOR back and shift pixels right
    begin
      DIBNumBits := Ceil( Log2( MaxHistInd + 1 ) );
      XORPixels( $0FFFF ); // XOR back, if DIBNumBits < 16 high bits remains to be zero

      //***** Shift pixels right

      PrepSMatrDescr( @SMD );
      N_PixOpObj.PO_IntOperand := DIBNumBits - ANumBits; // Right Shift size
      N_Conv1SMProcObj( @SMD, N_PixOpObj.PO_SHRTwoBytes ); // Shift DIB Pixels by PO_SHRTwoBytes ProcObj

      DIBNumBits := ANumBits;
      Exit; // all done
    end; // else // MaxHistInd > MaxVal, shift pixels right and XOR back

  end; // else // MaxHistInd > MaxVal, try to XOR pixels
end; // procedure TN_DIBObj.SetDIBNumBits

{
//********************************************* TN_DIBObj.SetSelfDIBNumBits ***
// Set Self DIBNumBits field
//
procedure TN_DIBObj.SetSelfDIBNumBits();
var
  SelfSMD: TN_SMatrDescr;
begin
  if DIBNumBits >= 8 then Exit; // already OK, nothing todo

  with N_PixOpObj do
  begin

  if DIBExPixFmt = epfGray16 then
  begin
    DIBNumBits := 16; // set temporary, to avoid recursive call from PrepSMatrDescr
    PrepSMatrDescr( @SelfSMD );
    PO_MaxInt := -1; // set initial value
    N_Conv1SMProcObj( @SelfSMD, PO_CalcMaxWord );
    // PO_MaxInt is calculated
  end else if DIBExPixFmt = epfColor48 then
  begin
    raise Exception.Create( 'epfColor48 is not implemented!' );
  end else // DIBExPixFmt = epfBMP
  begin
    DIBNumBits := 8;
    Exit;
  end;

  //***** Here: PO_MaxInt is calculated, set DIBNumBits by it

  if PO_MaxInt <= 255 then
    DIBNumBits := 8
  else
    DIBNumBits := Ceil( Log2( PO_MaxInt+1 ));

  end; // with N_PixOpObj do
end; // procedure TN_DIBObj.SetSelfDIBNumBits

//************************************************* TN_DIBObj.ReduceNumBits ***
// Analize all pixels and set proper DIBNumBits
//
// For black (all pixels = 0) images DIBNumBits will be set to 16
//
// Add Later: if some least bits of all pixels are the same,
//            then shift aall pixels to the right by this number of pixels
//
procedure TN_DIBObj.ReduceNumBits();
var
  MinHistInd, MaxHistInd: Integer;
  BrighHistValues: TN_IArray;
begin
  if DIBExPixFmt <> epfGray16 then Exit; // now implemented only for Gray16
  DIBNumBits := 16; // set temporary, is needed for CalcBrighHistNData

  CalcBrighHistNData( BrighHistValues, nil, @MinHistInd, @MaxHistInd, nil, 16 );

//  SelfSMD: TN_SMatrDescr;
//  if MinHistInd > 500 then // Substract MinHistInd from all pixels (500 is rather arbitrary)
//  begin
//    PrepSMatrDescr( @SelfSMD );
//    N_PixOpObj.PO_IntOperand := -MinHistInd;
//    N_Conv1SMProcObj( @SelfSMD, N_PixOpObj.PO_AddTwoBytes );
//  end; // if MinHistInd > 500 then // Substract MinHistInd from all pixels (500 is rather arbitrary)

  DIBNumBits := max( 8, Ceil( Log2( MaxHistInd + 1 )) );
end; // procedure TN_DIBObj.ReduceNumBits
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\FillRectByPixValue
//******************************************** TN_DIBObj.FillRectByPixValue ***
// Fill given APixRect by given APixValue without using GDI drawing
//
//     Parameters
// APixRect  - given Rect to fill
// APixValue - given Value to fill all Pixels in APixRect for all formats except
//             epfColor48, Color48 is calculated as RRGGBB, where RGB is given 
//             APixValue
//
procedure TN_DIBObj.FillRectByPixValue( APixRect: TRect; APixValue: integer );
var
  Color48Value: array [0..5] of Byte;
  SelfSMD: TN_SMatrDescr;
begin
  if DIBExPixFmt = epfColor48 then // conv 24 bit RGB APixValue to 48 bit RRGGBB Value
  begin
    Color48Value[0] := APixValue and $FF;
    Color48Value[1] := Color48Value[0];
    Color48Value[2] := (APixValue shr 8) and $FF;
    Color48Value[3] := Color48Value[2];
    Color48Value[4] := (APixValue shr 16) and $FF;
    Color48Value[5] := Color48Value[4];
  end else
    PInteger(@Color48Value[0])^ := APixValue;

  with N_PixOpObj do
  begin
    PO_SetElemMode := GetElemSizeInBytes();
    Assert( PO_SetElemMode > 0, 'Not supported by FillRectByPixValue!' );

    PO_SetElemPValue := @Color48Value[0];

    PrepSMatrDescrByRect( @SelfSMD, APixRect );

    N_Conv1SMProcObj( @SelfSMD, PO_SetElem );
  end; // with N_PixOpObj do

end; // procedure TN_DIBObj.FillRectByPixValue

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\ReadAndConvBMPPixels
//****************************************** TN_DIBObj.ReadAndConvBMPPixels ***
// Read (and convert if needed) given Pixels in some BMP format, given by 
// APDIBInfo
//
//     Parameters
// APDIBInfo - pointer to DIBInfo with Pixels format description
// APPixels  - pointer to pixels values
//
// Temporary no convertions are implemented, later implement (if needed) the 
// following convertion types: - 4 bit paletted to 8 bit paletted - HighColor to
// TrueColor - any paletted to RGB - Colored to Gray - Gray to Colored - RGB8 to
// RGB16 - Gray8 to Gray16
//
procedure TN_DIBObj.ReadAndConvBMPPixels( APDIBInfo: TN_PDIBInfo; APPixels: Pointer );
begin
  if DIBInfo.bmi.biBitCount <> APDIBInfo^.bmi.biBitCount then // temporary
    raise Exception.Create( 'Not supporeted in ReadAndConvBMPPixels!' );

  Move( APPixels^, PRasterBytes^, DIBInfo.bmi.biSizeImage ); // Copy all pixels
end; // procedure TN_DIBObj.ReadAndConvBMPPixels

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\ReadPixelsFromStream
//****************************************** TN_DIBObj.ReadPixelsFromStream ***
// Read row pixels from given AStream
//
//     Parameters
// AStream - given Stream
//
// Read Pixels from given AStream without any convertion. There are no gaps 
// between Pixel Rows in AStream
//
procedure TN_DIBObj.ReadPixelsFromStream( AStream: TStream );
var
  iy: Integer;
  PCurRow: TN_BytesPtr;
begin
  PCurRow := PRasterBytes;

  for iy := 0 to DIBSize.Y-1 do // along all Pixel Rows
  begin
    AStream.Read( PCurRow^, RRBytesInLine );
    Inc( PCurRow, RRLineSize );
  end; // for iy := 0 to DIBSize.Y-1 do // along all Pixel Rows

end; // procedure TN_DIBObj.ReadPixelsFromStream

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\PrepSameDIBObj
//************************************************ TN_DIBObj.PrepSameDIBObj ***
// Prepare DIBObj with same size and type as Self
//
//     Parameters
// AResDIBObj - given DIBObj or nil
//
// If AResDIBObj=nil AResDIBObj will be created If AResDIBObj<>nil but has not 
// proper size of type it will be freed and recreated If AResDIBObj<>nil and has
// proper size and type it will not be changed
//
procedure TN_DIBObj.PrepSameDIBObj( var AResDIBObj: TN_DIBObj );
begin
  N_PrepDIBObj( AResDIBObj, DIBSize.X, DIBSize.Y, DIBPixFmt, DIBExPixFmt, DIBNumBits );

  AResDIBObj.DIBInfo.bmi.biXPelsPerMeter := Self.DIBInfo.bmi.biXPelsPerMeter;
  AResDIBObj.DIBInfo.bmi.biYPelsPerMeter := Self.DIBInfo.bmi.biYPelsPerMeter;
end; // procedure TN_DIBObj.PrepSameDIBObj

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\PrepEmptyDIBObj(5Par)
//***************************************** TN_DIBObj.PrepEmptyDIBObj(5Par) ***
// Prepare Self as empty DIB (with undefined Pix values or filled by given 
// Color) by given size and pixel format
//
//     Parameters
// AWidth     - new DIB width
// AHeight    - abs(AHeight) is new DIB height, AHeight < 0 means from Up to 
//              Bottom raster rows order
// APixFmt    - new DIB pixel format
// AFillColor - color for setting all pixels or -1 if setting pixels is not 
//              needed
// AExPixFmt  - new DIB Extended (own) pixel format
// ANumBits   - resulting DIB DIBNumBits value (needed only for epfGray16 and 
//              epfColor48 formats)
//
// Free previous DIB and Canvas, create new DIB and Canvas, prepare all Self 
// fields except Palette and biXPelsPerMeter,biYPelsPerMeter, fill all pixels by
// given AFillColor (if AFillColor <> -1).
//
procedure TN_DIBObj.PrepEmptyDIBObj( AWidth, AHeight: integer; APixFmt: TPixelFormat;
                                     AFillColor: integer = -1; AExPixFmt: TN_ExPixFmt = epfBMP;
                                     ANumBits: integer = 0 );
var
  i: integer;
begin
  ClearSelfObjects();
  FillChar( DIBInfo, Sizeof(DIBInfo), 0 );

  DIBPixFmt   := APixFmt;
  DIBExPixFmt := AExPixFmt;
  DIBSize   := Point( AWidth, abs(AHeight) ); // calc in advance frequently used structs
  DIBRect   := Rect( 0, 0, AWidth-1, abs(AHeight)-1 );

  with DIBInfo, DIBInfo.bmi do
  begin
    biSize   := Sizeof(TBitmapInfoHeader);
    biWidth  := AWidth;
    biHeight := AHeight; // AHeight may be < 0
    biPlanes := 1;
    biCompression := BI_RGB;

    case APixFmt of
      pf1bit:   biBitCount := 1;
      pf8bit:   biBitCount := 8;
      pf16bit:  begin biBitCount := 16; biCompression := BI_BITFIELDS;
                  RedMask := $F800; GreenMask := $07E0; BlueMask := $001F; end;
      pf24bit:  biBitCount := 24;
      pf32bit:  begin biBitCount := 32; biCompression := BI_BITFIELDS;
                  RedMask := $FF0000; GreenMask := $FF00; BlueMask := $FF; end;
      pfcustom: begin
                  case AExPixFmt of
                    epfGray8:   biBitCount := 8;
                    epfGray16:  biBitCount := 16;
                    epfColor48: biBitCount := 48;
                  else // AExPixFmt = epfUnknown or some corrupted value
                    raise Exception.Create( 'Bad AExPixFmt = ' + IntToStr(Integer(AExPixFmt)) + '!' );
                  end; // case AExPixFmt of
                end; // pfcustom: begin
      else // APixFmt = pfDevice or pf4bit or pf15bit or some corrupted value
        raise Exception.Create( 'Bad APixFmt = ' + IntToStr(Integer(APixFmt)) + '!' );
    end; // case APixFmt of

    N_PrepDIBLineSizes( biWidth, APixFmt, AExPixFmt, RRBytesInLine, RRLineSize );
    biSizeImage := RRLineSize * abs(biHeight);
    biClrUsed := 256; // is needed for Copy to clipboard (for compact DIB) (is OK for any biBitCount)

    if DIBExPixFmt = epfGray8 then // Create Gray Scale Palette for possible drawing
    begin
      for i := 0 to 255 do
        PalEntries[i] := (i shl 16) or (i shl 8) or i;
    end;

    biXPelsPerMeter := Round( 72*100/2.54 );
    biYPelsPerMeter := Round( 72*100/2.54 );

    CreateSelfOCanv(); // DIBHandle is not ready yet!

    if DIBOCanv <> nil then // DIBOCanv = nil if DIBExPixFmt = epfGray16 or epfColor48
    with DIBOCanv do // Create DIBSection and select it in DIBOCanv.HMDC
    begin
      DIBHandle := Windows.CreateDIBSection( HMDC, PBitmapInfo(@DIBInfo)^,
                                  DIB_RGB_COLORS, Pointer(PRasterBytes), 0, 0 );
//      if N_i2 = 123654 then // for debug
//        DIBHandle := 0;

      if (DIBHandle = 0) or (PRasterBytes = nil) then
      begin
        N_Dump1Str( Format( 'PrepEmptyDIBObj error x=%d, y=%d, PixFmt=%d, FC=%d, ExPixFmt=%d, NumBits=%d',
                    [AWidth,AHeight,Integer(APixFmt),AFillColor,Integer(AExPixFmt),ANumBits] ) );
        K_GetFreeSpaceProfile();
        N_Dump1Str( '!!!MemFreeSpace Profile: ' + K_GetFreeSpaceProfileStr('; ', '%.0n') );

        raise Exception.Create( 'CreateDIBSec Error1 ' + SysErrorMessage( GetLastError() ) );
      end;

      HMIniBMP := SelectObject( HMDC, DIBHandle ); // select created DIBSection in HMDC
      if HMIniBMP = 0 then
        raise Exception.Create( 'Bad HMIniBMP in PrepEmptyDIBObj ' + SysErrorMessage( GetLastError() ) );

      Windows.SetGraphicsMode( HMDC, GM_ADVANCED );

      if AFillColor <> -1 then // Fill Created DIB by AFillColor
      begin
        SetBrushAttribs( AFillColor );
        DrawPixFilledRect( DIBRect );
      end; // if AFillColor <> -1 then // Fill Created DIB

      DIBNumBits := 8;
    end else // DIBOCanv = nil, epfGray16 or epfColor48 format
    begin
      SetLength( DIBPixels, RRLineSize*DIBSize.Y );
      PRasterBytes := TN_BytesPtr(@DIBPixels[0]);

      if AFillColor <> -1 then
        FillRectByPixValue( DIBRect, AFillColor );

      if ANumBits = 0 then // not given, check DIBNumBits
      begin
        if DIBNumBits <= 8 then // current DIBNumBits is wrong
          DIBNumBits := 16
      end else // ANumBits is given
      begin
        if ANumBits <= 8 then // given ANumBits is wrong or not given (=0)
          DIBNumBits := 16
        else // ANumBits > 8, use given value
          DIBNumBits := ANumBits;
      end; // else // ANumBits is given

    end; // else // DIBOCanv = nil, epfGray16 format

 end; // with DIBInfo.bmi do
end; // procedure TN_DIBObj.PrepEmptyDIBObj(5Par)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\PrepEmptyDIBObj(PDIBInfo)
//************************************* TN_DIBObj.PrepEmptyDIBObj(PDIBInfo) ***
// Prepare Self as empty DIB (with unknown or filled by some Color Pix values) 
// by given Pointer to Bitmap Info Header, given AExPixFmt and ANumBits
//
//     Parameters
// ADIBInfo   - Pointer to Bitmap Info Header and 256-colors Palette or 
//              BitFieldsMasks
// AFillColor - color for setting all pixels or -1 if setting pixels is not 
//              needed
// AExPixFmt  - new DIB Extended (own) pixel format or epfAutoAny, epfAutoGray
// ANumBits   - resulting DIB DIBNumBits value (needed only for 16 bit formats)
//
// Free previous DIB and Canvas, create new DIB and Canvas, prepare all Self 
// fields, fill all pixels by given AFillColor (if AFillColor <> -1).
//
// If AExPixFmt = epfGray8 - gray palette is created
//
procedure TN_DIBObj.PrepEmptyDIBObj( APDIBInfo: TN_PDIBInfo; AFillColor: integer = -1;
                                     AExPixFmt: TN_ExPixFmt = epfBMP; ANumBits: integer = 0 );
var
  ClrUsed: integer;
  PixFmt: TPixelFormat;
begin
  PixFmt := pfDevice; // just to avoid warning

  if (AExPixFmt = epfGray8)   or (AExPixFmt = epfGray16) or
     (AExPixFmt = epfColor48) or (AExPixFmt = epfColor64)  then
    PixFmt := pfCustom;

  with APDIBInfo^, bmi do
  begin

    if AExPixFmt = epfAutoAny then // set any AExPixFmt by APDIBInfo^
    begin
      PixFmt := pfCustom; // for epfGray8, epfGray16, epfColor48, epfColor64

           if biBitCount = 64 then  AExPixFmt := epfColor64
      else if biBitCount = 48 then  AExPixFmt := epfColor48
      else if (biBitCount >= 9) and (biBitCount <= 16) then  AExPixFmt := epfGray16 // 16 bit HighColor format is not supported
      else if biBitCount = 8  then // additional analisys is required
      begin

        if biCompression = BI_BITFIELDS then // OWN GrayScale image flag, epfGray8 format, not legal for standart Bitmap
          begin
            AExPixFmt := epfGray8;
            PixFmt    := pfCustom;
          end else // BMP 8 bit paletted format
          begin
            AExPixFmt := epfBMP;
            PixFmt    := pf8bit;
          end;

      end else //***** biBitCount = 1,4,24,32 - one of legal Bitmap formats or error (checked later)
        AExPixFmt := epfBMP;

    end else if AExPixFmt = epfAutoGray then // set epfGray8 or epfGray16 by APDIBInfo^
    begin
      PixFmt := pfCustom; // for epfGray8 or epfGray16

      if (biBitCount = 64) or (biBitCount = 48) or
         ( (biBitCount >= 9) and (biBitCount <= 16) ) then
        AExPixFmt := epfGray16
      else
        AExPixFmt := epfGray8;
    end; // else if AExPixFmt = epfAutoGray then // set epfGray8 or epfGray16 by APDIBInfo^

    //***** Here AExPixFmt is one of: epfBMP, epfGray8, epfGray16, epfColor48, epfColor64

    if AExPixFmt = epfBMP then // set PixFmt by APDIBInfo^
    begin
      case biBitCount of
       1 : PixFmt := pf1bit;
       4 : PixFmt := pf8bit;  // ReadAndConvBMPPixels should be used for reading picels !!!
       8 : PixFmt := pf8bit;
      16 : PixFmt := pf24bit; // ReadAndConvBMPPixels should be used for reading picels !!!
      24 : PixFmt := pf24bit;
      32 : PixFmt := pf32bit;
      else
        raise Exception.Create( 'Bad biBitCount in PrepEmptyDIBObj by DIBInfo!' );
      end; // case biBitCount of
    end; // if AExPixFmt = epfBMP then // set PixFmt by APDIBInfo^

    if biPlanes <> 1 then
      raise Exception.Create( 'Bad biPlanes in PrepEmptyDIBObj by DIBInfo!' );

    //***** Here: PixFmt and AExPixFmt are OK, Prepare Empty DIBObj

    PrepEmptyDIBObj( biWidth, biHeight, PixFmt, AFillColor, AExPixFmt, ANumBits );

    DIBInfo.bmi.biXPelsPerMeter := APDIBInfo^.bmi.biXPelsPerMeter;
    DIBInfo.bmi.biYPelsPerMeter := APDIBInfo^.bmi.biYPelsPerMeter;

    if (AExPixFmt = epfBMP) and (biBitCount <= 8) then // copy Palette
    begin
      if biClrUsed = 0 then ClrUsed := 1 shl biBitCount // max possible value
                       else ClrUsed := biClrUsed;

      Move( APDIBInfo^.PalEntries[0], DIBInfo.PalEntries[0], ClrUsed*SizeOf(integer) );
    end; // if (AExPixFmt = epfBMP) and (biBitCount <= 8) then // copy Palette

  end // with APDIBInfo^, bmi do

end; // procedure TN_DIBObj.PrepEmptyDIBObj(PDIBInfo)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\PrepEDIBAndSMD
//************************************************ TN_DIBObj.PrepEDIBAndSMD ***
// Prepare empty ADstDIB and two SubMatr descriptions by AFlipRotateFlags
//
//     Parameters
// ADstDIB          - resulting DIBObj (on input ADstDIB may exists or may be 
//                    nil)
// AFlipRotateFlags - given Flip and Rotate Flags
// APSelfSMD        - Pointer to Self TN_SMatrDescr record to prepare
// APDstSMD         - Pointer to ADstDIB TN_SMatrDescr record to prepare
// APixFmt          - resulting DIBObj Main pixel format
// AExPixFmt        - resulting DIBObj Extended pixel format
// ANumBits         - resulting DIB DIBNumBits value (needed only for epfGray16 
//                    and epfColor48 formats)
//
// ADstDIB may be nil, it will be created. If ADstDIB exists (is given) but have
// not proper attributes (Size and Pixel format) it will be converted properly.
//
// APSelfSMD and APDstSMD may be nil if some SMatr Destriptions are not needed 
// Self.DIBSize.X(Y) is same as APSelfSMD^.SMDNumX(Y) and is always equal to 
// APDstSMD^.SMDNumX(Y) for any AFlipRotateFlags.
//
// APSelfSMD and APDstSMD may be used in N_Conv2SM... converting procedures
//
procedure TN_DIBObj.PrepEDIBAndSMD( var ADstDIB: TN_DIBObj; AFlipRotateFlags: integer;
                                    APSelfSMD, APDstSMD: TN_PSMatrDescr;
                                    APixFmt: TPixelFormat; AExPixFmt: TN_ExPixFmt = epfBMP;
                                    ANumBits: integer = 0 );
var
  DstSizeX, DstSizeY: integer;
begin
  //***** Prepare empty ADstDIB

  DstSizeX := DIBSize.X;
  DstSizeY := DIBSize.Y;

  if (AFlipRotateFlags and N_FlipDiagBit) <> 0 then
    N_SwapTwoInts( @DstSizeX, @DstSizeY );

  if ADstDIB = nil then // Create New DIBObj
    ADstDIB := TN_DIBObj.Create( DstSizeX, DstSizeY, APixFmt, -1, AExPixFmt, ANumBits )
  else // ADstDIB exists, check if it has proper fields
    with ADstDIB do
    begin
      if not ( (DIBSize.X = DstSizeX) and (DIBSize.Y = DstSizeY)    and
               (DIBPixFmt = APixFmt)  and (DIBExPixFmt = AExPixFmt) and
               (DIBNumBits = ANumBits) ) then
      PrepEmptyDIBObj( DstSizeX, DstSizeY, APixFmt, -1, AExPixFmt, ANumBits ); // Prepare ADstDIB
    end; // with ADstDIB do, else // ADstDIB exists

  ADstDIB.DIBInfo.bmi.biXPelsPerMeter := DIBInfo.bmi.biXPelsPerMeter;
  ADstDIB.DIBInfo.bmi.biYPelsPerMeter := DIBInfo.bmi.biYPelsPerMeter;

  //***** ADstDIB is OK, prepare APSelfSMD^ and APDstSMD^ if needed

  PrepSMatrDescr( APSelfSMD ); // APSelfSMD could be nil
  if APDstSMD = nil then Exit; // all done

  // Prepare all APDstSMD^ fields except SMDPBeg and SMDElSize related fields
  PrepSMatrDescrByFlags( APDstSMD, AFlipRotateFlags );

  // Prepare SMDPBeg and SMDElSize related fields by ADstDIB
  // (now they were set by Self in PrepSMatrDescrByFlags)

  with APDstSMD^ do
  begin
    SMDPBeg   := ADstDIB.PRasterBytes;
    SMDElSize := ADstDIB.GetElemSizeInBytes();

    if (AFlipRotateFlags and N_FlipDiagBit) <> 0 then // diagonal Flip
    begin
      SMDStepY := SMDElSize;
      SMDStepX := ((SMDNumY*SMDElSize+3) shr 2) shl 2; // should be DWord aligned
    end else //***************************************** no diagonal Flip
    begin
      SMDStepX  := SMDElSize;
      SMDStepY  := ADstDIB.RRLineSize;
    end;

  end; // with APDstSMD^ do

end; // procedure TN_DIBObj.PrepEDIBAndSMD

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetInfoString
//************************************************* TN_DIBObj.GetInfoString ***
// Get string with DIB main attributes
//
//     Parameters
// Result - Returns string with DIB main attributes:
//#F
//  <BitsPerPix>, <Width> x <Height>, <SerializedSize>
//#/F
//
function TN_DIBObj.GetInfoString(): string;
begin
  with DIBInfo.bmi do
  begin
    Result := Format( '%d bits, %d x %d Pix, %s',
      [biBitCount, biWidth, biHeight, N_DataSizeToString( SerializedSize() )] );
  end;
end; // function TN_DIBObj.GetInfoString

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetElemSizeInBytes
//******************************************** TN_DIBObj.GetElemSizeInBytes ***
// Get Self Element Size in Bytes
//
//     Parameters
// Result - Return Self Element Size in Bytes or, if less than one byte: 0 -
//          unknownw format (error) - 1 - pf4bit - 2 - pf1bit
//
function TN_DIBObj.GetElemSizeInBytes(): integer;
begin
  case DIBPixFmt of
    pf1bit:  Result := -2;
    pf4bit:  Result := -1;
    pf8bit:  Result := 1;
    pf15bit: Result := 2;
    pf16bit: Result := 2;
    pf24bit: Result := 3;
    pf32bit: Result := 4;
    pfcustom: begin
                if DIBExPixFmt = epfGray8 then Result := 1
                else if DIBExPixFmt = epfGray16  then Result := 2
                else if DIBExPixFmt = epfColor48 then Result := 6
                else Result := 0; // not defined
              end;
  else Result := 0; // not defined
  end; // case DIBPixFmt of
end; // function TN_DIBObj.GetElemSizeInBytes

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SerializedSize
//************************************************ TN_DIBObj.SerializedSize ***
// Get DIB serialized size in bytes (memory needed for SerializeSelf method)
//
//     Parameters
// Result - Returns DIB serialized size in bytes
//
function TN_DIBObj.SerializedSize(): integer;
begin
  with DIBInfo.bmi do
  begin
    Result := 3*SizeOf(integer) + biSize + biClrUsed*SizeOf(integer) + biSizeImage;

    if (DIBExPixFmt = epfGray16) or (DIBExPixFmt = epfColor48) then
      Inc( Result, SizeOf(integer) ); // place for DIBNumBits

//    if DIBExPixFmt <> epfBMP then
//      Result := Result + integer(biClrUsed)*SizeOf(integer); // integer( ) is used to avoid warning
  end;
end; // function TN_DIBObj.SerializedSize

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SerializeSelf
//************************************************* TN_DIBObj.SerializeSelf ***
// Serialize Self in given memory buffer in own format
//
//     Parameters
// AMemPtr  - pointer to memory buffer
// AMemSize - memory buffer available size in bytes (should not be less than 
//            SerializedSize() )
//
// DIB sirialized data contains all needed Self Content as serial bytes value. 
// Serialization format is same as used by Windows Clipboard for CF_DIB object: 
// TN_DIBInfo, Palette, RasterPixels.
//
procedure TN_DIBObj.SerializeSelf( AMemPtr: Pointer; AMemSize: integer );
var
  PalSize: integer;
  PCur: TN_BytesPtr;
begin
//  Assert( AMemSize >= SerializedSize(), 'DIBObj: Bad MemSize!' );
  if AMemSize < SerializedSize() then
    raise Exception.Create( 'Bad MemSize in DIBObj.SerializeSelf!' );

  PCur := TN_BytesPtr(AMemPtr);

  PInteger(PCur)^ := N_ADEPSignature;   Inc( PCur, SizeOf(integer) );
  PInteger(PCur)^ := Byte(DIBExPixFmt); Inc( PCur, SizeOf(integer) );
  PInteger(PCur)^ := DIBTranspColor;    Inc( PCur, SizeOf(integer) );

  if (DIBExPixFmt = epfGray16) or (DIBExPixFmt = epfColor48) then
  begin
    PInteger(PCur)^ := DIBNumBits; Inc( PCur, SizeOf(integer) );
  end;  

  with DIBInfo.bmi do
  begin
    Move( DIBInfo, PCur^, biSize ); // biSize is Size of DIBInfo.bmi

    if DIBExPixFmt = epfBMP then
    begin
      PalSize := biClrUsed*SizeOf(integer); // Palette Size

      if biCompression = BI_BITFIELDS then
        PalSize := 3*SizeOf(integer);

      if PalSize > 0 then
        Move( DIBInfo.PalEntries[0], (PCur+biSize)^, PalSize );
    end else // DIBExPixFmt <> epfBMP do not save Palette for GrayScale Images
      PalSize := 0;

    Move( PRasterBytes^, (PCur+biSize+PalSize)^, biSizeImage );
  end; // with DIBInfo.bmi do
end; // procedure TN_DIBObj.SerializeSelf

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\DeSerializeSelf
//*********************************************** TN_DIBObj.DeSerializeSelf ***
// Deserialize Self from given memory buffer (after SerializeSelf method)
//
//     Parameters
// AMemPtr - pointer to memory buffer, prepared by SerializeSelf method
//
// Free previous DIB and Canvas, create new DIB and prepare all Self fields 
// (including Palette) from given serialized DIB data.
//
procedure TN_DIBObj.DeSerializeSelf( AMemPtr: Pointer );
var
  PalSize, NumBits: integer;
  PCur: TN_BytesPtr;
  TmpDIBInfo: TN_DIBInfo;
begin
  PCur := TN_BytesPtr(AMemPtr);

  Assert( PInteger(PCur)^ = N_ADEPSignature, 'No ADEP!' ); Inc( PCur, SizeOf(integer) );
  DIBExPixFmt := TN_ExPixFmt(PCur^); Inc( PCur, SizeOf(integer) );
  DIBTranspColor := PInteger(PCur)^; Inc( PCur, SizeOf(integer) );

  if (DIBExPixFmt = epfGray16) or (DIBExPixFmt = epfColor48) then
  begin
    NumBits := PInteger(PCur)^; Inc( PCur, SizeOf(integer) );
  end else
    NumBits := 8;

  Move( PCur^, TmpDIBInfo, Sizeof(TBitmapInfoHeader) ); // fill TmpDIBInfo.bmi

  Inc( PCur, TmpDIBInfo.bmi.biSize ); // TmpDIBInfo.bmi.biSize may be > Sizeof(TBitmapInfoHeader)

  with TmpDIBInfo do
  begin
    if DIBExPixFmt = epfBMP then // restore Palette if needed
    begin
      PalSize := bmi.biClrUsed*SizeOf(integer); // Palette Size

      if bmi.biCompression = BI_BITFIELDS then
        PalSize := 3*SizeOf(integer);

      if PalSize > 0 then
        Move( PCur^, PalEntries[0], PalSize );
    end else // DIBExPixFmt <> epfBMP, no Palette for GrayScale Images
      PalSize := 0;

    PrepEmptyDIBObj( @TmpDIBInfo, -1, DIBExPixFmt, NumBits ); // prepare all self fields by TmpDIBInfo except RasterBytes

    Move( (PCur+PalSize)^, PRasterBytes^, bmi.biSizeImage ); // copy RasterBytes
  end; // with TmpDIBInfo do
end; // procedure TN_DIBObj.DeSerializeSelf

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SelfToStream
//************************************************** TN_DIBObj.SelfToStream ***
// Serialize Self to given stream
//
//     Parameters
// AStresm     - stream to serialize
// AComprLevel - data compression level
//
// DIB sirialized data contains all needed Self Content as serial bytes value. 
// Serialization format is same as used by Windows Clipboard for CF_DIB object: 
// TN_DIBInfo, Palette, RasterPixels.
//
// AComprLevel is TCompressionLevel = (clNone, clFastest, clDefault, clMax);
//
procedure TN_DIBObj.SelfToStream( AStream: TStream; AComprLevel : Integer );
var
  PalSize: integer;
  ZStream: TCompressionStream;
begin

  AStream.Write( N_ADEPSignature, Sizeof(N_ADEPSignature) );
  ZStream := TCompressionStream.Create( TCompressionLevel(AComprLevel), AStream );
  ZStream.Write( DIBExPixFmt, SizeOf(integer) );
  ZStream.Write( DIBTranspColor, SizeOf(integer) );

  if (DIBExPixFmt = epfGray16) or (DIBExPixFmt = epfColor48) then
    ZStream.Write( DIBNumBits, SizeOf(integer) );

  with DIBInfo.bmi do
  begin
    ZStream.Write( DIBInfo, biSize );

    if DIBExPixFmt = epfBMP then
    begin
      PalSize := biClrUsed*SizeOf(integer); // Palette Size

      if biCompression = BI_BITFIELDS then
        PalSize := 3*SizeOf(integer);

      if PalSize > 0 then
        ZStream.Write( DIBInfo.PalEntries[0], PalSize );
    end;

    ZStream.Write( PRasterBytes^, biSizeImage );

  end; // with DIBInfo.bmi do
  ZStream.Free;

end; // procedure TN_DIBObj.SelfToStream


//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SelfFromStream
//************************************************ TN_DIBObj.SelfFromStream ***
// Deserialize Self from given Stream (after SelfToStream method)
//
//     Parameters
// AStresm - stream to deserialize
// Result  - Returns 0 if Self is sucessfully deserialized from given stream, 1 
//           if wrong data signature, 2 if wrong stream size
// 
//
// Free previous DIB and Canvas, create new DIB and prepare all Self fields 
// (including Palette) from given serialized DIB data.
//
function TN_DIBObj.SelfFromStream( AStream: TStream ) : Integer;
var
  PalSize: integer;
  TmpDIBInfo: TN_DIBInfo;
  WSignature, NumBits: Integer;
  ZStream : TDecompressionStream;
  label LExit;
begin
  AStream.Read( WSignature, Sizeof(N_ADEPSignature) );
  Result := 1;
  if WSignature <> N_ADEPSignature then Exit;
  Result := 2;

  ZStream := TDecompressionStream.Create( AStream );

  if ZStream.Read( WSignature, SizeOf(integer) ) <> SizeOf(integer) then goto LExit;
  DIBExPixFmt := TN_ExPixFmt(WSignature); // WSignature is used as wrk integer variable

  if ZStream.Read( DIBTranspColor, SizeOf(integer) ) <> SizeOf(integer) then goto LExit;

  if (DIBExPixFmt = epfGray16) or (DIBExPixFmt = epfColor48) then
  begin
    if ZStream.Read( NumBits, SizeOf(integer) ) <> SizeOf(integer) then goto LExit;
  end else
    NumBits := 8;

  if ZStream.Read( TmpDIBInfo, Sizeof(TBitmapInfoHeader) ) <> Sizeof(TBitmapInfoHeader) then goto LExit;

  with TmpDIBInfo do
  begin
    if DIBExPixFmt = epfBMP then // restore Palette if needed
    begin
      PalSize := bmi.biClrUsed*SizeOf(integer); // Palette Size

      if bmi.biCompression = BI_BITFIELDS then
        PalSize := 3*SizeOf(integer);

      if PalSize > 0 then begin
        if ZStream.Read( PalEntries[0], PalSize ) <> PalSize then goto LExit;
      end;
    end;

    PrepEmptyDIBObj( @TmpDIBInfo, -1, DIBExPixFmt, NumBits ); // prepare all self fields by TmpDIBInfo except RasterBytes

    if ZStream.Read( PRasterBytes^, bmi.biSizeImage ) <> Integer(bmi.biSizeImage) then goto LExit;
  end;

  Result := 0;

LExit:
  ZStream.Free;
end; // procedure TN_DIBObj.SelfFromStream

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetPixColor
//*************************************************** TN_DIBObj.GetPixColor ***
// Get RGB8 Color of Pixel with given (AX, AY) coords for any DIB format
//
//     Parameters
// AXYCoords - given pixel (X,Y) coords
// Result    - RGB8 Color of Pixel with given (AX, AY) coords
//
// Temporary not implemented for DIBPixFmt < pf8bit!
//
// For epfGray8, epfGray16 images resulting Color is also RGB8 with R=G=B
//
// For epfColor48 images resulting Color is also RGB8 (8 bits are used counting 
// DIBNumBits)
//
// Note, that in DIB Pixels and in pf8bit Palette least byte is Blue, not Red! 
// (BGR8 format)
//
function TN_DIBObj.GetPixColor( AXYCoords: TPoint ): integer;
var
  BytesInPix: integer;
  PElem: TN_BytesPtr;
  PColor: PInteger;
begin
  BytesInPix := GetElemSizeInBytes();
  Assert( BytesInPix >= 1, 'GetPixColor error1!' ); // Temporary not implemented for DIBPixFmt < pf8bit !

  if DIBInfo.bmi.biHeight > 0 then  // Bottom Up Matrix
    PElem := PRasterBytes + (DIBSize.Y - AXYCoords.Y - 1)*RRLineSize +  AXYCoords.X*BytesInPix
  else // Top Down Matrix
    PElem := PRasterBytes + AXYCoords.Y*RRLineSize +  AXYCoords.X*BytesInPix;

  Result := -2; // to avoid warning
  case BytesInPix of // Temporary not implemented for DIBPixFmt < pf8bit !
    1:   Result := PByte(PElem)^;
    2:   Result := PWord(PElem)^;
    3,4: Result := PByte(PElem)^ or (PWord(PElem+1)^ shl 8);
  end; // case BytesInPix of // Temporary not implemented for DIBPixFmt < pf8bit !

  //***** Here: Result is Pixel Value - Palette index or BGR8 Color (least byte is Blue!)

  if DIBPixFmt = pfCustom then // DIBExPixFmt = epfGray8, epfGray16 or epfColor48
  begin
    if DIBExPixFmt = epfGray8 then
    begin
      Result := Result or (Result shl 8) or (Result shl 16); // prepare RGB8 with R=G=B
    end;

    if DIBExPixFmt = epfGray16 then
    begin
      Result := Result shr (DIBNumBits - 8); // use highest 8 bit of real Gray value
      Result := Result or (Result shl 8) or (Result shl 16); // prepare RGB8 with R=G=B
    end;

    if DIBExPixFmt = epfColor48 then // BBGGRR bytes, least two bytes is Blue, not Red!
    begin
      Result := (PWord(PElem)^ shr (DIBNumBits - 8)) shl 16;            // use highest 8 bit of real Blue
      Result := Result or (PWord(PElem+2)^ shr (DIBNumBits - 8)) shl 8; // use highest 8 bit of real Green
      Result := Result or (PWord(PElem+4)^ shr (DIBNumBits - 8));       // use highest 8 bit of real Red
    end;
  end else // DIBPixFmt <> pfCustom (DIBExPixFmt = epfBMP)
  begin
    //***** In DIB colored pixels and in Palette - least byte ($FF) is Blue, not Red!

    if DIBPixFmt = pf8bit then // Result is Palette index, Convert to BGR8 Color
    begin
      PColor := @DIBInfo.PalEntries[0];
      Inc( PColor, Result ); // Result here is Palette index
      Result := PColor^;
    end; // if DIBPixFmt = pf8bit then // Result is Palette index, Convert to Color

    Result := N_SwapRedBlueBytes( Result ); // convert from BGR8 to RGB8
  end;

end; //*** end of function TN_DIBObj.GetPixColor

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetPixGrayValue
//*********************************************** TN_DIBObj.GetPixGrayValue ***
// Get Pixel Gray value with given (AX, AY) coords for any DIB format
//
//     Parameters
// AXYCoords - given pixel (X,Y) coords
// Result    - Return Gray Pixel value with given (AX, AY) coords
//
// Temporary not implemented for DIBPixFmt < pf8bit!
//
function TN_DIBObj.GetPixGrayValue( AXYCoords: TPoint ): integer;
var
  BytesInPix: integer;
  PElem: TN_BytesPtr;
begin
  BytesInPix := GetElemSizeInBytes();
  Assert( BytesInPix >= 1, 'GetPixGrayValue error1!' ); // Temporary not implemented for DIBPixFmt < pf8bit !

  if DIBInfo.bmi.biHeight > 0 then  // Bottom Up Matrix
    PElem := PRasterBytes + (DIBSize.Y - AXYCoords.Y - 1)*RRLineSize +  AXYCoords.X*BytesInPix
  else // Top Down Matrix
    PElem := PRasterBytes + AXYCoords.Y*RRLineSize +  AXYCoords.X*BytesInPix;

  Result := -2; // to avoid warning

  case BytesInPix of // Temporary not implemented for DIBPixFmt < pf8bit !
    1:   Result := PByte(PElem)^; // pf8bit and epfGray8
    2:   Result := PWord(PElem)^; // epfGray16

    3,4: Result := Round( 0.114*PByte(PElem)^   +  // Blue (pf24bit, pf32bit)
                          0.587*PByte(PElem+1)^ +  // Green
                          0.299*PByte(PElem+2)^ ); // Red

    6,8: Result := Round( 0.114*PWORD(PElem)^   +  // Blue (epfColor48, ARGB16)
                          0.587*PWORD(PElem+2)^ +  // Green
                          0.299*PWORD(PElem+4)^ ); // Red
  end; // case BytesInPix of // Temporary not implemented for DIBPixFmt < pf8bit !

  if DIBPixFmt = pf8bit then //
    Result := N_RGB8ToGray8( GetPixColor( AXYCoords ) );

end; //*** end of function TN_DIBObj.GetPixGrayValue

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetPixValue
//*************************************************** TN_DIBObj.GetPixValue ***
// Get Value (see below) of Pixel with given (AX, AY) coords
//
//     Parameters
// AXYCoords - given pixel (X,Y) coords
// Result    - Return Value (see below) of Pixel with given (AX, AY) coords
//
// Temporary not implemented for DIBPixFmt < pf8bit !
//
// Pixel value is returned as is, without any convertions: For pf8bit images 
// return Palette Index. For pf24bit and pf32bit images return BGR8 Color (least
// byte Blue)! For epfColor48 images return Pointer to Pix Value (not Pix Value 
// itself) in native BGR16 format (first two bytes is Blue, not Red)!
//
function TN_DIBObj.GetPixValue( AXYCoords: TPoint ): integer;
var
  BytesInPix: integer;
  PElem: TN_BytesPtr;
begin
  BytesInPix := GetElemSizeInBytes();
  Assert( BytesInPix >= 1, 'GetPixColor error1!' ); // Temporary not implemented for DIBPixFmt < pf8bit !

  if DIBInfo.bmi.biHeight > 0 then  // Bottom Up Matrix
    PElem := PRasterBytes + (DIBSize.Y - AXYCoords.Y - 1)*RRLineSize +  AXYCoords.X*BytesInPix
  else // Top Down Matrix
    PElem := PRasterBytes + AXYCoords.Y*RRLineSize +  AXYCoords.X*BytesInPix;

  Result := -2; // to avoid warning
  case BytesInPix of // Temporary not implemented for DIBPixFmt < pf8bit !
    1: Result := PByte(PElem)^;
    2: Result := PWord(PElem)^;
    3: Result := PByte(PElem)^ or (PWord(PElem+1)^ shl 8);
    4: Result := PInteger(PElem)^;
    6: Result := Integer(PElem);
    8: Result := Integer(PElem);
  end; // case BytesInPix of // Temporary not implemented for DIBPixFmt < pf8bit !

end; //*** end of function TN_DIBObj.GetPixValue

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SetPixValue
//*************************************************** TN_DIBObj.SetPixValue ***
// Set Value of Pixel with given (AX, AY) coords (see GetPixValue and below)
//
//     Parameters
// AXYCoords - given pixel (X,Y) coords
// APixValue - given pixel Value (see GetPixValue and below)
//
// Temporary not implemented for DIBPixFmt < pf8bit !
//
// APixValue should be in same format as in DIB Pixels: For pf8bit images 
// APixValue is Palette Index. For pf24bit and pf32bit images APixValue is BGR8 
// Color (least byte Blue)! For epfColor48 images APixValue is Pointer to Pix 
// Value (not Pix Value itself) in native BGR16 format (first two bytes is Blue,
// not Red)!
//
procedure TN_DIBObj.SetPixValue( AXYCoords: TPoint; APixValue: integer );
var
  BytesInPix: integer;
  PElem: TN_BytesPtr;
begin
  BytesInPix := GetElemSizeInBytes();
  Assert( BytesInPix >= 1, 'SetPixValue error1!' ); // Temporary not implemented for DIBPixFmt < pf8bit !

  if DIBInfo.bmi.biHeight > 0 then  // Bottom Up Matrix
    PElem := PRasterBytes + (DIBSize.Y - AXYCoords.Y - 1)*RRLineSize +  AXYCoords.X*BytesInPix
  else // Top Down Matrix
    PElem := PRasterBytes + AXYCoords.Y*RRLineSize +  AXYCoords.X*BytesInPix;

  case BytesInPix of // Temporary not implemented for DIBPixFmt < pf8bit !
    1: PByte(PElem)^ := Byte(APixValue);

    2: PWord(PElem)^ := Word(APixValue);

    3: begin
         PByte(PElem)^   := Byte(APixValue);
         PWord(PElem+1)^ := Word(APixValue shr 8);
       end;

    4: PInteger(PElem)^ := APixValue;

    6: begin
         PInteger(PElem)^ := PInteger(APixValue)^; // APixValue is pointer!
         PWord(PElem+4)^  := PWord(TN_BytesPtr(APixValue)+4)^; // APixValue is pointer!
       end;

    8: begin
         PInteger(PElem)^   := PInteger(APixValue)^; // APixValue is pointer!
         PInteger(PElem+4)^ := PInteger(TN_BytesPtr(APixValue)+4)^; // APixValue is pointer!
       end;
  end; // case BytesInPix of // Temporary not implemented for DIBPixFmt < pf8bit !

end; //*** end of procedure TN_DIBObj.SetPixValue

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetPixValuesVector
//******************************************** TN_DIBObj.GetPixValuesVector ***
// Get Vector (horizontal or vertical) of pixel values (Colors or Color indexes)
//
//     Parameters
// APixValues - resulting array of pixel values
// AX1        - left pixel
// AY1        - upper pixel
// AX2        - right pixel
// AY2        - lower pixel
// Result     - Returns number of pixel values in APixValues.
//
// Returned number of pixels will be equal to AY2-AY1+1 (if AX2 is equal to AX1)
// or AX2-AX1+1 (in all other cases). APixValues resulting length will always be
// not less than function Result.
//
function TN_DIBObj.GetPixValuesVector( var APixValues: TN_IArray;
                                       AX1, AY1, AX2, AY2: integer ): integer;
var
  i, NumBytes: integer;
  PLine: TN_BytesPtr;
  Label NotImplemeneted;
begin
  if AX1 = AX2 then // vertical Vector
    Result := AY2 - AY1 + 1
  else //************* horizontal Vector
    Result := AX2 - AX1 + 1;

  if Length(APixValues) < Result then
    SetLength( APixValues, Result );

  PLine := PRasterBytes + AY1*RRLineSize; // Beg of Row of first pixel
  N_i1 := integer(PLine);

  NumBytes := GetElemSizeInBytes();

  case NumBytes of

  1: begin
    PLine := PLine + AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PByte(PLine)^;
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PByte(PLine)^;
        Inc( PLine );
      end;
  end; // 1: begin

  2: begin
    PLine := PLine + 2*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := TN_PUInt2(PLine)^;
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := TN_PUInt2(PLine)^;
        Inc( PLine, 2 );
      end;
  end; // 2: begin

  3: begin
    PLine := PLine + 3*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PByte(PLine)^ + (TN_PUInt2(PLine+1)^ shl 8);
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PByte(PLine)^ + (TN_PUInt2(PLine+1)^ shl 8);
        Inc( PLine, 3 );
      end;
  end; // 3: begin

  4: begin
    PLine := PLine + 4*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PInteger(PLine)^;
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        APixValues[i] := PInteger(PLine)^;
        Inc( PLine, 4 );
      end;
  end; // 4: begin

  else goto NotImplemeneted;
  end; // case RPixFmt of

  Exit;
  NotImplemeneted: Assert( False, 'GetPixValuesVector Not Implemeneted!' );
end; //*** end of function TN_DIBObj.GetPixValuesVector

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SetPixValuesVector
//******************************************** TN_DIBObj.SetPixValuesVector ***
// Set Vector (horizontal or vertical) of pixel values (Colors or Color indexes)
//
//     Parameters
// APixValues - given array of pixel values
// AX1        - left pixel
// AY1        - upper pixel
// AX2        - right pixel
// AY2        - lower pixel
// Result     - Returns number of pixel values get from APixValues.
//
// Returned number of pixels will be equal to AY2-AY1+1 (if AX2 is equal to AX1)
// or AX2-AX1+1 (in all other cases).
//
function TN_DIBObj.SetPixValuesVector( APixValues: TN_IArray;
                                          AX1, AY1, AX2, AY2: integer ): integer;
var
  i, WrkAY1, NumBytes: integer;
  PLine: TN_BytesPtr;
  Label NotImplemeneted;
begin
  WrkAY1 := AY1; // Debugger shows bad AY1 value!

  if AX1 = AX2 then // vertical array
    Result := AY2 - AY1 + 1
  else //************* horizontal array
    Result := AX2 - AX1 + 1;

  Assert( Length(APixValues) >= Result, 'Bad Size!' );

  PLine := PRasterBytes + WrkAY1*RRLineSize; // Beg of Row of first pixel
  N_i2 := integer(PLine);
  NumBytes := GetElemSizeInBytes();

  case NumBytes of

  1: begin
    PLine := PLine + AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        PByte(PLine)^ := APixValues[i];
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        PByte(PLine)^ := APixValues[i];
        Inc( PLine );
      end;
  end; // 1: begin

  2: begin
    PLine := PLine + 2*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        TN_PUInt2(PLine)^ := APixValues[i];
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        TN_PUInt2(PLine)^ := APixValues[i];
        Inc( PLine, 2 );
      end;
  end; // 2: begin

  3: begin
    PLine := PLine + 3*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        PByte(PLine)^ := APixValues[i] and $FF;
        Inc( PLine );
        TN_PUInt2(PLine)^ := APixValues[i] shr 8;
        Inc( PLine, RRLineSize-1 );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        PByte(PLine)^ := APixValues[i] and $FF;
        Inc( PLine );
        TN_PUInt2(PLine)^ := APixValues[i] shr 8;
        Inc( PLine, 2 );
      end;
  end; // 3: begin

  4: begin
    PLine := PLine + 4*AX1;
    if AX1 = AX2 then // vertical array
      for i := 0 to Result-1 do
      begin
        PInteger(PLine)^ := APixValues[i];
        Inc( PLine, RRLineSize );
      end
    else //************* horizontal array
      for i := 0 to Result-1 do
      begin
        PInteger(PLine)^ := APixValues[i];
        Inc( PLine, 4 );
      end;
  end; // 4: begin

  else goto NotImplemeneted;
  end; // case RPixFmt of

  Exit;
  NotImplemeneted: Assert( False, 'SetPixValuesVector - Not Implemeneted!' );
end; //*** end of function TN_DIBObj.SetPixValuesVector

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetPixValuesRect
//********************************************** TN_DIBObj.GetPixValuesRect ***
// Get DIB rectangle area pixel values (Colors or Color indexes)
//
//     Parameters
// APixValues - resulting integer array of pixel values
// AX1        - given area left pixel
// AY1        - given area upper pixel
// AX2        - given area right pixel
// AY2        - given area lower pixel
// Result     - Returns number of pixel in APixValues - (AX2-AX1+1)*(AY2-AY1+1).
//
// APixValues resulting length will always be not less than function Result.
//
function TN_DIBObj.GetPixValuesRect( var AValues: TN_IArray;
                                        AX1, AY1, AX2, AY2: integer ): integer;
var
  i, j, ind, NX, NY: integer;
  PixRow: TN_IArray;
begin
  NX := AX2-AX1+1;
  SetLength( PixRow, NX );
  NY := AY2-AY1+1;
  Result := NX*NY;
  if Length(AValues) < Result then
    SetLength( AValues, Result );

  ind := 0;
  for i := AY1 to AY2 do // along PixelRows
  begin
    GetPixValuesVector( PixRow, AX1, i, AX2, i );

    for j := 0 to NX-1 do // along Pixels in i-th PixelRow
    begin
      AValues[ind] := PixRow[j];
      Inc( ind );
    end; // for j := 0 to NX-1 do // along Pixels in i-th PixelRow

  end; // for i := AY1 to AY2 do // along PixelRows
end; //*** end of function TN_DIBObj.GetPixValuesRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SetPixValuesRect
//********************************************** TN_DIBObj.SetPixValuesRect ***
// Set DIB rectangle area pixel values (Colors or Color indexes)
//
//     Parameters
// APixValues - given integer array of pixel values
// AX1        - given area left pixel
// AY1        - given area upper pixel
// AX2        - given area right pixel
// AY2        - given area lower pixel
// Result     - Returns number of pixel values get from APixValues.
//
// APixValues resulting length will always be not less than function Result.
//
function TN_DIBObj.SetPixValuesRect( AValues: TN_IArray;
                                        AX1, AY1, AX2, AY2: integer ): integer;
var
  i, j, ind, NX, NY: integer;
  PixRow: TN_IArray;
begin
  NX := AX2-AX1+1;
  SetLength( PixRow, NX );
  NY := AY2-AY1+1;
  Result := NX*NY;

  ind := 0;
  for i := AY1 to AY2 do // along PixelRows
  begin

    for j := 0 to NX-1 do // along Pixels in i-th PixelRow
    begin
      PixRow[j] := AValues[ind];
      Inc( ind );
    end; // for j := 0 to NX-1 do // along Pixels in i-th PixelRow

    SetPixValuesVector( PixRow, AX1, i, AX2, i );
  end; // for i := AY1 to AY2 do // along PixelRows
end; //*** end of function TN_DIBObj.SetPixValuesRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetPixColorsVector
//******************************************** TN_DIBObj.GetPixColorsVector ***
// Get Vector (horizontal or vertical) of pixel Colors
//
//     Parameters
// APixValues - resulting array of pixel Colors
// AX1        - left pixel
// AY1        - upper pixel
// AX2        - right pixel
// AY2        - lower pixel
// Result     - Returns number of pixel Colors in APixValues.
//
// Returned number of pixels will be equal to AY2-AY1+1 (if AX2 is equal to AX1)
// or AX2-AX1+1 (in all other cases). APixValues resulting length will always be
// not less than function Result.
//
function TN_DIBObj.GetPixColorsVector( var APixColors: TN_IArray;
                                          AX1, AY1, AX2, AY2: integer ): integer;
var
  i: integer;
  PColor: PInteger;
begin
  Result := GetPixValuesVector( APixColors, AX1, AY1, AX2, AY2 );

  if DIBPixFmt > pf8bit then // not palette mode, Swap Red,Blue Bytes
  begin
    for i := 0 to High(APixColors) do
      APixColors[i] := N_SwapRedBlueBytes( APixColors[i] );

    Exit;
  end; // if DIBPixFmt > pf8bit then // not palette mode, Swap Red,Blue Bytes

  for i := 0 to Result-1 do // conv Color Index to Color
  begin
    PColor := @DIBInfo.PalEntries[0];
    Inc( PColor, APixColors[i] );
    APixColors[i] := N_SwapRedBlueBytes( PColor^ );
  end; // for i := 0 to Result-1 do // conv Color Index to Color

end; //*** end of function TN_DIBObj.GetPixColorsVector

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetPixRGBValuesRect
//******************************************* TN_DIBObj.GetPixRGBValuesRect ***
// Get DIB rectangle area pixel Colors as RGB triples
//
//     Parameters
// ARGBValues - resulting byte array of pixel RGB triples
// AX1        - given area left pixel
// AY1        - given area upper pixel
// AX2        - given area right pixel
// AY2        - given area lower pixel
// Result     - Returns number of RGB triples in ARGBValues - 
//              (AX2-AX1+1)*(AY2-AY1+1).
//
// ARGBValues byte array contains RGB triple as R,G,B,R,G,B, ... (first RGB 
// triple byte is Red!). ARGBValues resulting length will always be not less 
// than function Result*3.
//
function TN_DIBObj.GetPixRGBValuesRect( var ARGBValues: TN_BArray;
                                            AX1, AY1, AX2, AY2: integer ): integer;
var
  i, j, ind, NX, NY: integer;
  PixRow: TN_IArray;
begin
  NX := AX2-AX1+1;
  SetLength( PixRow, NX );
  NY := AY2-AY1+1;
  Result := NX*NY;
  if Length(ARGBValues) < 3*Result then
    SetLength( ARGBValues, 3*Result );

  ind := 0;
  for i := AY1 to AY2 do // along PixelRows
  begin
    GetPixColorsVector( PixRow, AX1, i, AX2, i );

    for j := 0 to NX-1 do // along Pixels in i-th PixelRow
    begin
      ARGBValues[ind]   := PixRow[j] and $FF;
      ARGBValues[ind+1] := (PixRow[j] shr 8)  and $FF;
      ARGBValues[ind+2] := (PixRow[j] shr 16) and $FF;
      Inc( ind, 3 );
    end; // for j := 0 to NX-1 do // along Pixels in i-th PixelRow

  end; // for i := AY1 to AY2 do // along PixelRows
end; //*** end of function TN_DIBObj.GetPixRGBValuesRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SetPixRGBValuesRect
//******************************************* TN_DIBObj.SetPixRGBValuesRect ***
// Set DIB rectangle area pixel Colors given as RGB triples
//
//     Parameters
// ARGBValues - given byte array of pixel RGB triples
// AX1        - given area left pixel
// AY1        - given area upper pixel
// AX2        - given area right pixel
// AY2        - given area lower pixel
// Result     - Returns number of RGB triples in ARGBValues - 
//              (AX2-AX1+1)*(AY2-AY1+1).
//
// ARGBValues byte array contains RGB triple as B,G,R,B,G,R, ... (first RGB 
// triple byte is Blue).
//
function TN_DIBObj.SetPixRGBValuesRect( ARGBValues: TN_BArray;
                                        AX1, AY1, AX2, AY2: integer ): integer;
var
  i, j, ind, NX, NY: integer;
  PixRow: TN_IArray;
begin
  NX := AX2-AX1+1;
  SetLength( PixRow, NX );
  NY := AY2-AY1+1;
  Result := NX*NY;

  ind := 0;
  for i := AY1 to AY2 do // along PixelRows
  begin

    for j := 0 to NX-1 do // along Pixels in i-th PixelRow
    begin
      PixRow[j] := ARGBValues[ind] or (ARGBValues[ind+1] shl 8) or
                                      (ARGBValues[ind+2] shl 16);
      Inc( ind, 3 );
    end; // for j := 0 to NX-1 do // along Pixels in i-th PixelRow

    SetPixValuesVector( PixRow, AX1, i, AX2, i );
  end; // for i := AY1 to AY2 do // along PixelRows
end; //*** end of function TN_DIBObj.SetPixRGBValuesRect

{
//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\ConvAndSetPixRGBValues
//**************************************** TN_DIBObj.ConvAndSetPixRGBValues ***
// Convert given RGB Values by given Convertion Table and set them to Self
//
//     Parameters
// AXLatTable - given XLat convertion Table or nil if convertion is not needed
// ARGBValues - given RGB Values to convert and set or nil if Self RGB values
//              should be converted
//
// Length(ARGBValues) should be equal to 3*DIBSize.X*DIBSize.Y Content of
// ARGBValues is not changed
//
procedure TN_DIBObj.ConvAndSetPixRGBValues( AXLatTable, ARGBValues: TN_BArray );
var
  iy, ix, ind: integer;
  PixRow: TN_IArray;
  LRGBValues: TN_BArray;
begin
  SetLength( PixRow, DIBSize.X );

  if ARGBValues = nil then // get Self RGB Values
    GetPixRGBValuesRect( LRGBValues, 0, 0, DIBSize.X-1, DIBSize.Y-1 )
  else // ARGBValues are given
  begin
    Assert( DIBSize.X*DIBSize.Y*3 <= Length(ARGBValues), 'ARGBValues array has not enough length!' );
    LRGBValues := ARGBValues;
  end;

  ind := 0;
  for iy := 0 to DIBSize.Y-1 do // along all PixelRows
  begin

    for ix := 0 to DIBSize.X-1 do // along all Pixels in i-th PixelRow
    begin
      if AXLatTable = nil then
        PixRow[ix] := LRGBValues[ind] or (LRGBValues[ind+1] shl 8) or
                                         (LRGBValues[ind+2] shl 16)
      else // AXLatTable is given
        PixRow[ix] :=  AXLatTable[LRGBValues[ind]] or
                      (AXLatTable[LRGBValues[ind+1]] shl 8) or
                      (AXLatTable[LRGBValues[ind+2]] shl 16);

      Inc( ind, 3 );
    end; // for ix := 0 to DIBSize.X-1 do // along Pixels in i-th PixelRow

    SetPixValuesVector( PixRow, 0, iy, DIBSize.X-1, iy );
  end; // for iy := 0 to DIBSize.Y-1 do // along PixelRows
end; // procedure TN_DIBObj.ConvAndSetPixRGBValues
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\AddDIBToSelf
//************************************************** TN_DIBObj.AddDIBToSelf ***
// Add given DIB to Self
//
//     Parameters
// ASrcDIB - given DIB
//
// The following algorithm is used: - ASrcDIB should have the same size as Self 
// - zero pixels in ASrcDIB remains the same in Self - nonzero pixels remains 
// the same or are set to 0 or $FFFFFF
//
procedure TN_DIBObj.AddDIBToSelf( ASrcDIB: TN_DIBObj );
var
  i, j, k, SrcPixColor: integer;
begin
  for j := 0 to DIBSize.Y-1 do // along Pix rows
  begin
    for i := 0 to DIBSize.X-1 do // along Pixels in j-th row
    begin
      SrcPixColor := ASrcDIB.GetPixColor( Point(i,j) );

      if SrcPixColor <> 0 then
      begin
        k := ( (j and $03) + i ) and $03;
        if k = 1 then SetPixValue( Point(i,j), $FFFFFF )
        else if k = 3 then SetPixValue( Point(i,j), $0 );
      end;

    end; // for i := 0 to DIBSize.X-1 do // along Pixels in j-th row

  end; // for j := 0 to DIBSize.Y-1 do // along Pix rows
end; //*** end of procedure TN_DIBObj.AddDIBToSelf

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CopyRectBy2SM
//************************************************* TN_DIBObj.CopyRectBy2SM ***
// Copy pixels in given Rect from given DIB Obj to Self using N_Conv2SMCopyConv
//
//     Parameters
// ASelfUpperLeft - given Upper Left Rect corner in Self
// ASrcDIB        - given DIB Obj to copy from
// ASrcRect       - given Rect in ASrcDIB to copy
//
// Self is Destination DIB, ASrcDIB is Source DIB
//
// GDI Drawing is not used even if it is possible
//
procedure TN_DIBObj.CopyRectBy2SM( ASelfUpperLeft: TPoint; ASrcDIB: TN_DIBObj;
                                   ASrcRect: TRect );
var
  SelfRect: TRect;
  SrcSMD, SelfSMD: TN_SMatrDescr;
begin
  SelfRect.TopLeft := ASelfUpperLeft;

  SelfRect.Right  := SelfRect.Left + ASrcRect.Right  - ASrcRect.Left;
  SelfRect.Bottom := SelfRect.Top  + ASrcRect.Bottom - ASrcRect.Top;

  PrepSMatrDescrByRect( @SelfSMD, SelfRect );
  ASrcDIB.PrepSMatrDescrByRect( @SrcSMD,  ASrcRect );

  N_Conv2SMCopyConv( @SrcSMD, @SelfSMD, 0, 0, csmShiftAuto1 );
end; //*** end of procedure TN_DIBObj.CopyRectBy2SM

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CopyRectAuto
//************************************************** TN_DIBObj.CopyRectAuto ***
// Copy pixels in given Rect from given DIB Obj to Self using fastes way - by 
// GDI (N_CopyRect) if possible or by CopyRectBy2SM
//
//     Parameters
// ASelfUpperLeft - given Upper Left Rect corner in Self
// ASrcDIB        - given DIB Obj to copy from
// ASrcRect       - given Rect in ASrcDIB to copy
//
// Self is Destination DIB, ASrcDIB is Source DIB
//
procedure TN_DIBObj.CopyRectAuto( ASelfUpperLeft: TPoint; ASrcDIB: TN_DIBObj; ASrcRect: TRect );
begin
  if ((ASrcDIB.DIBExPixFmt = epfBMP) or (ASrcDIB.DIBExPixFmt = epfGray8)) and
     ((Self.DIBExPixFmt = epfBMP) or (Self.DIBExPixFmt = epfGray8)) then // Use GDI
  begin
    N_CopyRect( DIBOCanv.HMDC, Point(0,0), ASrcDIB.DIBOCanv.HMDC, ASrcRect );
  end else // ASrcDIB or Self is epfGray16 or epfColor48, use CopyRectBy2SM
  begin
    CopyRectBy2SM( ASelfUpperLeft, ASrcDIB, ASrcRect );
  end;

end; //*** end of procedure TN_DIBObj.CopyRectAuto

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\LoadFromBitmap
//************************************************ TN_DIBObj.LoadFromBitmap ***
// Set DIB from given Delphi Bitmap
//
//     Parameters
// ABitmap - given Delphi Bitmap (TBitmap)
//
// Free previous DIB and Canvas, create new DIB and Canvas and fill it by given 
// Delphi Bitmap content.
//
procedure TN_DIBObj.LoadFromBitmap( ABitmap: TBitmap );
var
  i: integer;
begin
  PrepEmptyDIBObj( ABitmap.Width, ABitmap.Height, ABitmap.PixelFormat );

  with DIBInfo, DIBInfo.bmi do
  begin
    if biBitCount <= 8 then // Prepare Palette
    begin
      biClrUsed := GetPaletteEntries( ABitmap.Palette, 0, 256, PalEntries[0] );
      biClrImportant := biClrUsed;

      for i := 0 to biClrUsed-1 do // in DIB Palette least significant byte ($FF) is Blue
        PalEntries[i] := N_SwapRedBlueBytes( PalEntries[i] );
    end; // if biBitCount <= 8 then // Prepare Palette

    if DibOCanv <> nil then
      if (biBitCount <= 8) and (DibOCanv.HMDC <> 0) then // Set palette to HMDC
        N_i1 := Windows.SetDIBColorTable( DibOCanv.HMDC, 0, 256, PalEntries[0] );

    //!****** replace later by BitBlt for speed

    for i := 0 to biHeight-1 do // copy Raster pixels
      move( PByte(ABitmap.ScanLine[i])^,
                     (PRasterBytes+(biHeight-i-1)*RRLineSize)^, RRBytesInLine );

  end; // with DIBInfo.bmi do
end; // procedure TN_DIBObj.LoadFromBitmap

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CreateBitmap
//************************************************** TN_DIBObj.CreateBitmap ***
// Create Delphi Bitmap from given rectangle DIB area
//
//     Parameters
// ARect  - given rectangle area coordinates
// Result - Returns Delphi Bitmap TBitmap Object built form pixels of given 
//          rectangle area
//
function TN_DIBObj.CreateBitmap( ARect: TRect ): TBitmap;
begin
  Result := TBitmap.Create();

  with Result do
  begin
    Width  := N_RectWidth( ARect );
    Height := N_RectHeight( ARect );
    PixelFormat := DIBPixFmt;

    CreateSelfOCanv ();
    if DIBOCanv <> nil then
      N_CopyRect( Canvas.Handle, Point(0,0), DIBOCanv.HMDC, ARect );
  end; // with Result do
end; // function TN_DIBObj.CreateBitmap

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\LoadFromBMPFormat
//********************************************* TN_DIBObj.LoadFromBMPFormat ***
// Load Self from given AFileName (with any extension) in BMP Format Return 0 if
// OK, -1 - file not found
//
function TN_DIBObj.LoadFromBMPFormat( AFileName: string ): integer;
begin
  Result := 0;
  Assert( False, 'Not implemented!' );
end; // function TN_DIBObj.LoadFromBMPFormat

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SaveToBMPFormat
//*********************************************** TN_DIBObj.SaveToBMPFormat ***
// Save DIB to given file in BMP Format
//
//     Parameters
// AFileName - resulting file name
//
// File name is used as is (file extension doesn't changed to *.BMP).
//
procedure TN_DIBObj.SaveToBMPFormat( AFileName: string );
var
  DIBInfoSize, SavedNumBits: integer;
  TmpDIB: TN_DIBObj;
  FStream: TFileStream;
  BMPFHeader: TBitmapFileHeader;
begin
  FStream := nil; // to avoid warning

  if DIBExPixFmt = epfGray16 then // Convert to epfGray8 format before saving
  begin
    SavedNumBits := Self.DIBNumBits;

    if SavedNumBits = 0 then
      Self.DIBNumBits := 16; // for correct convertion from epfGray16 to epfGray8

    TmpDIB := TN_DIBObj.Create( Self, DIBRect, pfCustom, epfGray8 );

    if SavedNumBits = 0 then
      Self.DIBNumBits := 0; // restore
  end else if DIBExPixFmt = epfColor48 then // Convert to BMP pf24bit format before saving
  begin
    SavedNumBits := Self.DIBNumBits;

    if SavedNumBits = 0 then
      Self.DIBNumBits := 16; // for correct convertion from epfGray16 to epfGray8

    TmpDIB := TN_DIBObj.Create( Self, DIBRect, pf24bit );

    if SavedNumBits = 0 then
      Self.DIBNumBits := 0; // restore
  end else // save self as is, without convertion
    TmpDIB := Self;

  with TmpDIB, TmpDIB.DIBInfo.bmi, BMPFHeader do
  begin
    DIBInfoSize := Sizeof(DIBInfo.bmi) + biClrUsed*Sizeof(integer);

    try
      FStream := TFileStream.Create( AFileName, fmCreate );
      FillChar( BMPFHeader, Sizeof(BMPFHeader), 0 );
      bfType := $4D42; // 'BM' signature
      bfOffBits := Sizeof(BMPFHeader) + DIBInfoSize;
      bfSize := bfOffBits + biSizeImage;

      FStream.Write( BMPFHeader, Sizeof(BMPFHeader) );
      FStream.Write( DIBInfo, DIBInfoSize );
      FStream.Write( PRasterBytes^, biSizeImage );

    finally
      FStream.Free;
    end; // try

  end; // with TmpDIB.DIBInfo, TmpDIB.DIBInfo.bmi, BMPFHeader do

  if TmpDIB <> Self then // TmpDIB was created, fee it
    TmpDIB.Free;

end; // procedure TN_DIBObj.SaveToBMPFormat

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\LoadFromCMSIFormat
//******************************************** TN_DIBObj.LoadFromCMSIFormat ***
// Load Self from given AFileName (with any extension) in CMSI Format
//
//     Parameters
// AFileName - given file name (with any extension)
// Result    - Return 0 if OK, -1 if file not found, -2 if bad file, -3 some 
//             other error
//
// Brief CMSI Format description (only Gray rasters are supported): 3 bytes 
// Signature 'CMS', 1 byte 8 or 16, 4 bytes NX, 4 bytes NY, row pixels
//
function TN_DIBObj.LoadFromCMSIFormat( AFileName: string ): integer;
var
  i, j, NX, NY, itmp: integer;
  BitsPerPixel: byte;
  PCur0, PCur1: PByte;
  Signature: AnsiString;
  FStream: TFileStream;
begin
  FStream := nil; // to enable FStream.Free after goto Fin;
  SetLength( Signature, 3 );

  if not FileExists( AFileName ) then
  begin
    Result := -1; // file not found
    Exit;
  end;

  try
    FStream := TFileStream.Create( AFileName, fmOpenRead );
    FStream.Read( Signature[1], 3 );

    if Signature <> 'CMS' then
    begin
      Result := -2; // bad file
      FStream.Free;
      Exit;
    end;

    FStream.Read( BitsPerPixel, 1 );
    FStream.Read( NX, 4 );
    FStream.Read( NY, 4 );

    if (NX <= 0) or (NY <= 0) or (NX*NY > 4e8) then
    begin
      Result := -2; // bad file
      FStream.Free;
      Exit;
    end;

    if BitsPerPixel = 8 then
    begin
      PrepEmptyDIBObj( NX, NY, pfCustom, -1, epfGray8 );

      for i := NY-1 downto 0 do // along all pixel rows
        FStream.Read( (PRasterBytes + i*RRLineSize)^, NX ); // read i-th row (NX bytes)

      Result := 0; // all OK
      FStream.Free;
    end else if BitsPerPixel = 16 then
    begin
      PrepEmptyDIBObj( NX, NY, pfCustom, -1, epfGray16 );

      for i := NY-1 downto 0 do // along all pixel rows
      begin
        FStream.Read( (PRasterBytes + i*RRLineSize)^, 2*NX ); // read i-th row (2*NX bytes)

        //***** Swap high and low bytes in all i-th row pixels

        PCur0 := PByte(PRasterBytes + i*RRLineSize + 0);
        PCur1 := PByte(PRasterBytes + i*RRLineSize + 1);

        for j := 0 to NX-1 do // swap high and low bytes in all pixels of i-th row
        begin
          itmp := PCur0^;
          PCur0^ := PCur1^;
          PCur1^ := itmp;
          Inc( PCur0, 2 );
          Inc( PCur1, 2 );
        end; // for j := 0 to NX-1 do // swap high and low bytes

      end; // for i := NY-1 downto 0 do // along all pixel rows

      Result := 0; // all OK
      FStream.Free;
    end else // bad file, BitsPerPixel <> 8 or 16
    begin
      Result := -2;
      FStream.Free;
    end; // else // bad file, BitsPerPixel <> 8 or 16

  except
    on E: Exception do
    begin
      Result := -3; // some other error
      FStream.Free;
    end;
  end; // try
end; // function TN_DIBObj.LoadFromCMSIFormat

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SaveToCMSIFormat
//********************************************** TN_DIBObj.SaveToCMSIFormat ***
// Save Self (should be Gray) to given AFileName (with any extension) in CMSI 
// Format
//
//     Parameters
// AFileName - resulting file name (with any extension)
// Result    - Return 0 if OK or -1 if Self is not of epfGray8 or epfGray16 
//             Format
//
// Brief CMSI Format description (only Gray rasters are supported): 3 bytes 
// Signature 'CMS', 1 byte 8 or 16, 4 bytes NX, 4 bytes NY, row pixels
//
function TN_DIBObj.SaveToCMSIFormat( AFileName: string ): integer;
var
  i, j, itmp: integer;
  BitsPerPixel: byte;
  PCur0, PCur1: PByte;
  Signature: AnsiString;
  FStream: TFileStream;
  RowBuf: TN_BArray;
begin
       if (DIBExPixFmt = epfGray8)  then BitsPerPixel := 8
  else if (DIBExPixFmt = epfGray16) then BitsPerPixel := 16
  else // error
  begin
    Result := -1; // not epfGray8 or epfGray16 Self Format
    Exit;
  end;

  Signature := 'CMS';

  FStream := TFileStream.Create( AFileName, fmCreate );
  FStream.Write( Signature[1], 3 );

  FStream.Write( BitsPerPixel, 1 );
  FStream.Write( DIBSize.X, 4 );
  FStream.Write( DIBSize.Y, 4 );

  if BitsPerPixel = 8 then // epfGray8
  begin
    for i := DIBSize.Y-1 downto 0 do // along all pixel rows
      FStream.Write( (PRasterBytes + i*RRLineSize)^, DIBSize.X ); // write i-th row (DIBSize.X bytes)

  end else if BitsPerPixel = 16 then // epfGray16
  begin
    SetLength( RowBuf, 2*DIBSize.X );

    for i := DIBSize.Y-1 downto 0 do // along all pixel rows
    begin
      move( (PRasterBytes + i*RRLineSize)^, RowBuf[0], 2*DIBSize.X ); // copy i-th row to Buf

      //***** Swap high and low bytes in all RowBuf pixels

      PCur0 := @RowBuf[0];
      PCur1 := @RowBuf[1];

      for j := 0 to DIBSize.X-1 do // swap high and low bytes in all RowBuf pixels
      begin
        itmp := PCur0^;
        PCur0^ := PCur1^;
        PCur1^ := itmp;
        Inc( PCur0, 2 );
        Inc( PCur1, 2 );
      end; // for j := 0 to DIBSize.X-1 do // swap high and low bytes

      FStream.Write( RowBuf[0], 2*DIBSize.X ); // write i-th row (2*DIBSize.X bytes)
    end; // for i := NY-1 downto 0 do // along all pixel rows

  end; // else if BitsPerPixel = 16 then // epfGray16

  Result := 0; // all OK
  FStream.Free;
end; // function TN_DIBObj.SaveToCMSIFormat

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\LoadFromFile
//************************************************** TN_DIBObj.LoadFromFile ***
// Load DIB from given raster file
//
//     Parameters
// AFileName - given source file name
// Result    - Returns 0 if OK, -1 if file not found, -2 if unknown file format.
//
// Given file format is detected by file extension. Valid extensions are  *.BMP,
// *.GIF, *.JPG.
//
function TN_DIBObj.LoadFromFile( AFileName: string ): integer;
var
  VFile: TK_VFile;
  Stream: TStream;
  TmpBMPObj: TBitmap;
  VFName : string;
begin
  VFName := K_ExpandFileName( AFileName );

  K_VFAssignByPath( VFile, VFName );
  Result := K_VFOpen( VFile );
  if Result = -1 then Exit; // Open error

  Stream := K_VFStreamGetToRead( VFile );
  TmpBMPObj := N_CreateBMPObjFromStream( Stream );
  K_VFStreamFree(VFile);

  if TmpBMPObj = nil then

    raise Exception.Create( 'Unknown Stream format' );

  Result := 0;
//  TmpBMPObj := N_CreateBMPObjFromFile( AFileName );
//  TmpBMPObj.SaveToFile( N_TmpRoot + 'aa4.bmp' ); // debug
  LoadFromBitmap( TmpBMPObj );
  DIBNumBits := 0;
//  SetSelfDIBNumBits();
  TmpBMPObj.Free;
end; // function TN_DIBObj.LoadFromFile

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SaveToFile
//**************************************************** TN_DIBObj.SaveToFile ***
// Save Self to given raster File (with bmp, gif, jpg extensions)
//
//     Parameters
// AFileName - given source file name
// Result    - Returns 0 if OK
//
procedure TN_DIBObj.SaveToFile( AFileName: string; APImageFilePar: TN_PImageFilePar );
begin
  // not implemented
end; // procedure TN_DIBObj.SaveToFile

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\LoadFromStreamByGDIP
//****************************************** TN_DIBObj.LoadFromStreamByGDIP ***
// Load DIB from given Stream  using GDI+
//
//     Parameters
// AStream - source AStream
// Result  - Returns 0 if OK, TK_GPDIBCodecsWrapper error code as integer
//
// DIB format always remains the same (as it was on input)
//
function TN_DIBObj.LoadFromStreamByGDIP( AStream: TStream ): integer;
var
  GPCWrapper: TK_GPDIBCodecsWrapper;
begin
  GPCWrapper := TK_GPDIBCodecsWrapper.Create;
  Result := integer(GPCWrapper.GPLoadFromStream( AStream ));

  if Result <> 0 then
  begin
    GPCWrapper.Free;
    Exit;
  end;

  Result := integer(GPCWrapper.GPGetFrameToDIBObj( Self, 0 ));
  GPCWrapper.Free;
end; // function TN_DIBObj.LoadFromStreamByGDIP

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\LoadFromFileByGDIP
//******************************************** TN_DIBObj.LoadFromFileByGDIP ***
// Load DIB from given file using GDI+
//
//     Parameters
// AFileName - source file name
// Result    - Returns 0 if OK, -1 if K_VFOpen error or GDI+ error code
//
// DIB format always remains the same (as it was on input)
//
function TN_DIBObj.LoadFromFileByGDIP( AFileName: string ): integer;
var
  VFile: TK_VFile;
  Stream: TStream;
  VFName: string;
begin
  VFName := K_ExpandFileName( AFileName );

  K_VFAssignByPath( VFile, VFName );
  Result := K_VFOpen( VFile );
  if Result = -1 then Exit; // Open error

  Stream := K_VFStreamGetToRead( VFile );
  Result := LoadFromStreamByGDIP( Stream );

  K_VFStreamFree(VFile);
end; // function TN_DIBObj.LoadFromFileByGDIP

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SaveToFileByGDIP
//********************************************** TN_DIBObj.SaveToFileByGDIP ***
// Save Self to given raster File using GDI+
//
//     Parameters
// AFileName - resulting file name
//
procedure TN_DIBObj.SaveToFileByGDIP( AFileName: string );
var
  GPCWrapper: TK_GPDIBCodecsWrapper;
begin
  GPCWrapper := TK_GPDIBCodecsWrapper.Create;
  GPCWrapper.GPSaveDIBObjToFile( Self, AFileName );
  GPCWrapper.Free;
end; // procedure TN_DIBObj.SaveToFileByGDIP

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\LoadFromMemBMP
//************************************************ TN_DIBObj.LoadFromMemBMP ***
// Load DIB to Self from memory in Packed DIB Windows format (same as Clipboard 
// CF_DIB format)
//
//     Parameters
// AMemPtr - pointer to memory with raster in BMP format
//
// Free previous DIB and Canvas, create new DIB and Canvas and fill it by given 
// data. Pixels in memory with raster in BMP format are located just after 
// BITMAPINFO and Palette (same as Clipboard CF_DIB format).
//
procedure TN_DIBObj.LoadFromMemBMP( AMemPtr: Pointer );
var
  mybmiSize, ClrUsed: Integer;
  TmpDIBInfo: TN_DIBInfo;
  PPixels: TN_BytesPtr;
begin
  PrepEmptyDIBObj( AMemPtr, -1, epfAutoAny );

  // prepare TmpDIBInfo to simplify access to bmi fields

  FillChar( TmpDIBInfo, SizeOf(TmpDIBInfo), 0 );
  mybmiSize := SizeOf(TmpDIBInfo.bmi); //
  Move( AMemPtr^, TmpDIBInfo, mybmiSize ); // fill TmpDIBInfo.bmi fields

  with TmpDIBInfo.bmi do
  begin
    // Calc ClrUsed to get pointer to Pixels

    ClrUsed := 0;

    if biBitCount <= 8 then
    begin
      ClrUsed := biClrUsed;

      if ClrUsed = 0 then
        ClrUsed := 1 shl biBitCount; // max possible value
    end;

    if biCompression = BI_BITFIELDS then // three masks instead of palette
      ClrUsed := 3; // R, G, B Masks

    PPixels := TN_BytesPtr(AMemPtr) + biSize + ClrUsed*SizeOf(Integer);
    ReadAndConvBMPPixels( @TmpDIBInfo, PPixels );

  end; // with TmpDIBInfo.bmi do

  //***** Dump info of received Mem BMP
  with TmpDIBInfo.bmi do
    N_Dump1Str( Format( 'DIB from MemBMP:  x y=%d %d,  bitCount=%d, Size=%d, ClrUsed= %d',
                         [biWidth,biHeight,biBitCount,biSizeImage,biClrUsed] ) );

  // SaveToBMPFormat( 'C:\\aa4.bmp' ); // for debug only

//  if Assigned(N_BinaryDumpProcObj) then // Dump received Mem BMP
//    N_BinaryDumpProcObj( 'MemBMP', AMemPtr, inpbmiSize+inpPalSize+integer(DIBInfo.bmi.biSizeImage) );

end; // procedure TN_DIBObj.LoadFromMemBMP

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SaveToMemBmp
//************************************************** TN_DIBObj.SaveToMemBmp ***
// Save DIB to memory in compact DIB Windows format (same as Clipboard CF_DIB 
// format)
//
//     Parameters
// AMemPtr  - pointer to memory bufer where to save DIB
// AMemSize - given memory bufer size available
// Result   - Returns size of memory occupied by DIB in compact DIB Windows 
//            format or -1 if AMemSize is not enough.
//
// If APMem=nil or AMemSize=0 just return the number of needed memory size in 
// bytes
//
function TN_DIBObj.SaveToMemBmp( AMemPtr: Pointer; AMemSize: integer ): integer;
var
  DIBInfoSize: DWORD;
begin
  DIBInfoSize := SizeOf(DIBInfo);

  if DIBInfo.bmi.biBitCount > 8 then
  begin
    DIBInfoSize := DIBInfoSize - 256*4; // do not count Palette size
    DIBInfo.bmi.biClrUsed := 0; // is really needed (otherwise Paste in MSPaint failed)
  end;

  Result := DIBInfoSize + DIBInfo.bmi.biSizeImage;

  if (AMemPtr = nil) or (AMemSize = 0) then Exit; // just return Needed Size

  if AMemSize < Result then // Error, not enough AMemSize
  begin
    Result := -1;
    Exit;
  end;

  Move( DIBInfo, AMemPtr^, DIBInfoSize );
  Move( PRasterBytes^, (TN_BytesPtr(AMemPtr)+DIBInfoSize)^, DIBInfo.bmi.biSizeImage );
end; // function TN_DIBObj.SaveToMemBmp

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SaveToBArrayBMP
//*********************************************** TN_DIBObj.SaveToBArrayBMP ***
// Save DIB to given byte array bufer in BMP format (same as Clipboard CF_DIB 
// format)
//
//     Parameters
// ABArray - byte array bufer where to save DIB
// Result  - Returns size of memory occupied by DIB in BMP format.
//
function TN_DIBObj.SaveToBArrayBMP( var ABArray: TN_BArray ): integer;
begin
  Result := SaveToMemBmp( nil, 0 ); // Needed ABArray Size

  if Length(ABArray) < Result then
    SetLength( ABArray, Result );

  SaveToMemBmp( @ABArray[0], Result );
end; // function TN_DIBObj.SaveToBArrayBMP

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\LoadFromClipborad
//********************************************* TN_DIBObj.LoadFromClipborad ***
// Load DIB from Windows Clipborad (only in CF_DIB format)
//
//     Parameters
// Result - Returns 0 if OK, 1 if no Raster in Clipboard or 2 if some error 
//          occured.
//
function TN_DIBObj.LoadFromClipborad(): integer;
var
  ResultOK: LongBool;
  HMem: THandle;
  MemPtr: TN_BytesPtr;
begin
  Result := 2;
  ResultOK := Windows.OpenClipboard( 0 );

  if not ResultOK then // Clipboard is locked
  begin
    N_Dump1Str( 'Clipboard was locked in LoadFromClipborad!' );
    Exit;
  end;

  HMem := Windows.GetClipboardData( CF_DIB );
  Result := 1; // no Raster in Clipboard

  if HMem <> 0 then // data in CF_DIB format exist in Clipboard
  begin
    MemPtr := Windows.GlobalLock( HMem );
    if MemPtr = nil then
      raise Exception.Create( 'GlobalLock for CF_DIB Error in LoadFromClipborad!' + SysErrorMessage( GetLastError() ) );

    LoadFromMemBMP( MemPtr );
    Windows.GlobalUnlock( HMem );
    Result := 0; // Loaded OK flag
  end; // if HMem <> 0 then // data in CF_DIB format exist in Clipboard

  ResultOK := Windows.CloseClipboard();
  if not ResultOK then
    raise Exception.Create( 'CloseClipboard (CF_DIB) Error in LoadFromClipborad!' + SysErrorMessage( GetLastError() ) );
end; // function TN_DIBObj.LoadFromClipborad

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\SaveToClipborad
//*********************************************** TN_DIBObj.SaveToClipborad ***
// Save DIB to Windows Clipborad (in CF_DIB format)
//
//     Parameters
// Result - Returns TRUE if OK, FALSE if some error occured.
//
function TN_DIBObj.SaveToClipborad(): boolean;
var
  MemSize: Integer;
  ResultOK: LongBool;
  HMem, HMemTmp: THandle;
  MemPtr: TN_BytesPtr;
begin
  Result := False;
  MemSize := SaveToMemBmp( nil, 0 ); // get Needed Size

  HMem := Windows.GlobalAlloc( GMEM_MOVEABLE+GMEM_DDESHARE, MemSize );
  MemPtr := Windows.GlobalLock( HMem );
  if MemPtr = nil then
    raise Exception.Create( 'GlobalLock for CF_DIB Error ' + SysErrorMessage( GetLastError() ) );

  SaveToMemBmp( MemPtr, MemSize );

  Windows.GlobalUnlock( HMem );

  ResultOK := Windows.OpenClipboard( 0 );
  if not ResultOK then // Clipboard is locked
  begin
    Windows.GlobalFree( HMem );
    N_Dump1Str( 'Clipboard was locked in SaveToClipborad!' );
    Exit;
  end;

  Windows.EmptyClipboard();
  HMemTmp := Windows.SetClipboardData( CF_DIB, HMem );
  if HMemTmp = 0 then
    raise Exception.Create( 'SetClipboardData (CF_DIB) Error in SaveToClipborad!' + SysErrorMessage( GetLastError() ) );

  ResultOK := Windows.CloseClipboard();
  if not ResultOK then
    raise Exception.Create( 'CloseClipboard (CF_DIB) Error in SaveToClipborad!' + SysErrorMessage( GetLastError() ) );

  Result := True;
end; // function TN_DIBObj.SaveToClipborad

{
//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcBrighHistData
//******************************************** TN_DIBObj.CalcBrighHist8Data ***
// Obsolete, CalcBrighHistNData should be used!

// Calculate Brightness Histogram 8 bit Data for given ARect
//
//     Parameters
// ABrighHistValues - resulting integer array of Brightness 8 bit Data
// APRect           - Pointer to Pix Rect to process, nil means whole image
// APMinHistInd     - Pointer to resulting minimal index with non zero data
// APMaxHistInd     - Pointer to resulting maximal index with non zero data
// APMaxHistVal     - Pointer to resulting maximal data element value
//
// ABrighHistValues[i] is number of pixels in given ARect with brightness = i
//
// If ABrighHistValues Array has more than 256 elements it is not truncated
// (only first 256 elements are calculated)
//
// APMinHistInd, APMaxHistInd and APMaxHistVal may be nil. This means that
// appropriate resulting values are not caculated
//
// ABrighHistValues[i] = 0 for (i < APMinHistInd) and (i > APMaxHistInd)
// Max( ABrighHistValues[i], 0<=i<256 ) = APMaxHistVal^
//
// Is Self is epfGray16 only highest 8 bit are used for all calculations
//
procedure TN_DIBObj.CalcBrighHist8Data( var ABrighHistValues: TN_IArray; APRect: PRect = nil;
                                        APMinHistInd: PInteger = nil; APMaxHistInd: PInteger = nil;
                                        APMaxHistVal: PInteger = nil );
var
  i, ix, iy, CurBrigh, CurColor, NumInds, MaxInd: integer;
  PixRect: TRect;
begin
  NumInds := 256;
  MaxInd := NumInds - 1;

  if Length(ABrighHistValues) < NumInds then
    SetLength( ABrighHistValues, NumInds );

  ZeroMemory( ABrighHistValues, NumInds * SizeOf(Integer) );

  if APRect <> nil then PixRect := APRect^
                   else PixRect := DIBRect;

  N_IRectAnd( PixRect, DIBRect );

  for iy := PixRect.Top to PixRect.Bottom do // along all Pixel Rows
  begin

    for ix := PixRect.Left to PixRect.Right do // along one Row, add Data for current Row
    begin
      CurColor := GetPixColor( Point( ix, iy ) );

      case DIBExPixFmt of
        epfGray8, epfGray16,
        epfColor48: // not implemented
          CurBrigh := CurColor and $0FF;   // CurColor is RGB 24 bit Gray Value = R=G=B
      else
        CurBrigh := Round( 0.114*(CurColor and $FF) +           // Blue
                           0.587*((CurColor shr 8) and $FF) +   // Green
                           0.299*((CurColor shr 16) and $FF) ); // Red;
      end; // case DIBExPixFmt of

      ABrighHistValues[CurBrigh] := ABrighHistValues[CurBrigh] + 1;
    end; // for ix := PixRect.Left to PixRect.Right do

  end; // for iy := PixRect.Top to PixRect.Bottom do // along all Pixel Rows

  if APMaxHistVal <> nil then // Calc APMaxHistVal^
  begin
    APMaxHistVal^ := 0;
    for i := 0 to MaxInd do
      if APMaxHistVal^ < ABrighHistValues[i] then APMaxHistVal^ := ABrighHistValues[i];
  end; // if APMaxHistVal <> nil then // Calc APMaxHistVal^

  if APMinHistInd <> nil then // Calc APMinHistInd^
    for i := 0 to MaxInd do
      if ABrighHistValues[i] > 0 then
      begin
        APMinHistInd^ := i;
        Break;
      end;

  if APMaxHistInd <> nil then // Calc APMaxHistInd^
    for i := MaxInd downto 0 do
      if ABrighHistValues[i] > 0 then
      begin
        APMaxHistInd^ := i;
        Break;
      end;

end; //*** end of procedure TN_DIBObj.CalcBrighHist8Data

//******************************************* TN_DIBObj.CalcBrighHist16Data ***
// Obsolete, CalcBrighHistNData should be used!

// Calculate Brightness Histogram 16 bit Data for given ARect
//
//     Parameters
// ABrighHistValues - resulting integer array of Brightness 16 bit Data
// APRect           - Pointer to Pix Rect to process, nil means whole image
// APMinHistInd     - Pointer to resulting minimal index with non zero data
// APMaxHistInd     - Pointer to resulting maximal index with non zero data
// APMaxHistVal     - Pointer to resulting maximal data element value
//
// ABrighHistValues[i] is number of pixels in given ARect with brightness = i
//
// If ABrighHistValues Array has more than 256*256 elements it is not truncated
// (only first 256*256 elements are calculated)
//
// APMinHistInd, APMaxHistInd and APMaxHistVal may be nil. This means that
// appropriate resulting values are not caculated
//
// ABrighHistValues[i] = 0 for (i < APMinHistInd) and (i > APMaxHistInd)
// Max( ABrighHistValues[i], 0<=i<256*256 ) = APMaxHistVal^
//
// Only for epfGray16 DIB objects!
//
procedure TN_DIBObj.CalcBrighHist16Data( var ABrighHistValues: TN_IArray; APRect: PRect = nil;
                                         APMinHistInd: PInteger = nil; APMaxHistInd: PInteger = nil;
                                         APMaxHistVal: PInteger = nil );
var
  i, ix, iy, CurBrigh, NumInds, MaxInd: integer;
  PixRect: TRect;
begin
  Assert( DIBExPixFmt = epfGray16, 'DIBExPixFmt<>epfGray16!' );

  NumInds := 256*256;
  MaxInd := NumInds - 1;

  if Length(ABrighHistValues) < NumInds then
    SetLength( ABrighHistValues, NumInds );

  ZeroMemory( ABrighHistValues, NumInds * SizeOf(Integer) );

  if APRect <> nil then PixRect := APRect^
                   else PixRect := DIBRect;

  N_IRectAnd( PixRect, DIBRect );

  for iy := PixRect.Top to PixRect.Bottom do // along all Pixel Rows
  begin

    for ix := PixRect.Left to PixRect.Right do // along one Row, add Data for current Row
    begin
      CurBrigh := GetPixValue( Point( ix, iy ) );
      ABrighHistValues[CurBrigh] := ABrighHistValues[CurBrigh] + 1;
    end; // for ix := PixRect.Left to PixRect.Right do

  end; // for iy := PixRect.Top to PixRect.Bottom do // along all Pixel Rows

  if APMaxHistVal <> nil then // Calc APMaxHistVal^
  begin
    APMaxHistVal^ := 0;
    for i := 0 to MaxInd do
      if APMaxHistVal^ < ABrighHistValues[i] then APMaxHistVal^ := ABrighHistValues[i];
  end; // if APMaxHistVal <> nil then // Calc APMaxHistVal^

  if APMinHistInd <> nil then // Calc APMinHistInd^
    for i := 0 to MaxInd do
      if ABrighHistValues[i] > 0 then
      begin
        APMinHistInd^ := i;
        Break;
      end;

  if APMaxHistInd <> nil then // Calc APMaxHistInd^
    for i := MaxInd downto 0 do
      if ABrighHistValues[i] > 0 then
      begin
        APMaxHistInd^ := i;
        Break;
      end;

end; //*** end of procedure TN_DIBObj.CalcBrighHist16Data

//********************************************* TN_DIBObj.CalcBrighHistData ***
// Obsolete, CalcBrighHistNData should be used!

// Calculate Brightness Histogram Data for given ARect
//
//     Parameters
// ABrighHistValues - resulting integer array of Brightness
// APRect           - Pointer to Pix Rect to process, nil means whole image
// APMinHistInd     - Pointer to resulting minimal index with non zero data
// APMaxHistInd     - Pointer to resulting maximal index with non zero data
// APMaxHistVal     - Pointer to resulting maximal data element value
//
// Self can have any format, ABrighHistValues Length depends upon Self.DIBNumBits
//
// ABrighHistValues[i] is number of pixels in given ARect with brightness = i
//
// If ABrighHistValues Array has more elements than needed it is not truncated
// (only first needed elements are calculated)
//
// APMinHistInd, APMaxHistInd and APMaxHistVal may be nil. This means that
// appropriate resulting values are not caculated
//
// ABrighHistValues[i] = 0 for (i < APMinHistInd) and (i > APMaxHistInd)
// Max( ABrighHistValues[i], 0<=i<=MaxInd ) = APMaxHistVal^
//
procedure TN_DIBObj.CalcBrighHistData( var ABrighHistValues: TN_IArray; APRect: PRect = nil;
                                       APMinHistInd: PInteger = nil; APMaxHistInd: PInteger = nil;
                                       APMaxHistVal: PInteger = nil );
var
  i, ix, iy, CurGray, NumInds, MaxInd, Mask: integer;
  PixRect: TRect;
begin
  NumInds := $1 shl DIBNumBits; // Number of needed elements (256 for 8 bits DIBs)
  MaxInd  := NumInds - 1;
  Mask    := $FFFF shr (16 - DIBNumBits);

  if Length(ABrighHistValues) < NumInds then
    SetLength( ABrighHistValues, NumInds );

  ZeroMemory( ABrighHistValues, NumInds * SizeOf(Integer) );

  if APRect <> nil then PixRect := APRect^
                   else PixRect := DIBRect;

  N_IRectAnd( PixRect, DIBRect );

  for iy := PixRect.Top to PixRect.Bottom do // along all Pixel Rows
  begin

    for ix := PixRect.Left to PixRect.Right do // along one Row, add Data for current Row
    begin
      CurGray := GetPixGrayValue( Point( ix, iy ) ) and Mask; // and Mask is a precaution
      ABrighHistValues[CurGray] := ABrighHistValues[CurGray] + 1;
    end; // for ix := PixRect.Left to PixRect.Right do

  end; // for iy := PixRect.Top to PixRect.Bottom do // along all Pixel Rows

  if APMaxHistVal <> nil then // Calc APMaxHistVal^
  begin
    APMaxHistVal^ := 0;
    for i := 0 to MaxInd do
      if APMaxHistVal^ < ABrighHistValues[i] then APMaxHistVal^ := ABrighHistValues[i];
  end; // if APMaxHistVal <> nil then // Calc APMaxHistVal^

  if APMinHistInd <> nil then // Calc APMinHistInd^
    for i := 0 to MaxInd do
      if ABrighHistValues[i] > 0 then
      begin
        APMinHistInd^ := i;
        Break;
      end;

  if APMaxHistInd <> nil then // Calc APMaxHistInd^
    for i := MaxInd downto 0 do
      if ABrighHistValues[i] > 0 then
      begin
        APMaxHistInd^ := i;
        Break;
      end;

end; //*** end of procedure TN_DIBObj.CalcBrighHistData
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcBrighHistNData
//******************************************** TN_DIBObj.CalcBrighHistNData ***
// Calculate Brightness Histogram Data for given ARect and ANumBits
//
//     Parameters
// ABrighHistValues - resulting integer array of Brightness, 
//                    Length(ABrighHistValues) = 2**ANumBits
// APRect           - Pointer to Pix Rect to process, nil means whole image
// APMinHistInd     - Pointer to resulting minimal index with non zero data
// APMaxHistInd     - Pointer to resulting maximal index with non zero data
// APMaxHistVal     - Pointer to resulting maximal data element value
// ANumBits         - given number of bits to consider, 0 means Self.DIBNumBits,
//                    should be <= Self.DIBNumBits
//
// Self can have any format, ABrighHistValues Length depends upon ANumBits
//
// ABrighHistValues[i] is number of pixels in given ARect with brightness = i
//
// If ABrighHistValues Array has more elements than needed it is not truncated 
// (only first needed elements are calculated)
//
// APMinHistInd, APMaxHistInd and APMaxHistVal may be nil. This means that 
// appropriate resulting values are not caculated
//
// ABrighHistValues[i] = 0 for (i < APMinHistInd) and (i > APMaxHistInd) Max( 
// ABrighHistValues[i], 0<=i<=MaxInd ) = APMaxHistVal^, where 
// MaxInd=2**ANumBits-1
//
procedure TN_DIBObj.CalcBrighHistNData( var ABrighHistValues: TN_IArray; APRect: PRect = nil;
                                        APMinHistInd: PInteger = nil; APMaxHistInd: PInteger = nil;
                                        APMaxHistVal: PInteger = nil; ANumBits: integer = 8 );
var
  i, ix, iy, CurGray, NumInds, MaxInd, Mask, NumShiftR: integer;
  PixRect: TRect;
begin
  if ANumBits = 0 then
    ANumBits := DIBNumBits;

  Assert( (ANumBits >=1) and (ANumBits <= 16), 'Bad ANumBits = ' + IntToStr(ANumBits) );

  NumInds := $1 shl ANumBits; // Number of needed elements (256 for ANumBits=8)
  MaxInd  := NumInds - 1;
  Mask    := $FFFF shr (16 - ANumBits);
  NumShiftR := max( 0, DIBNumBits - ANumBits ); // number of bits to shift Right, always >= 0

  if Length(ABrighHistValues) < NumInds then
    SetLength( ABrighHistValues, NumInds );

  ZeroMemory( ABrighHistValues, NumInds * SizeOf(Integer) );

  if APRect <> nil then PixRect := APRect^
                   else PixRect := DIBRect;

  N_IRectAnd( PixRect, DIBRect );

  for iy := PixRect.Top to PixRect.Bottom do // along all Pixel Rows
  begin

    for ix := PixRect.Left to PixRect.Right do // along one Row, add Data for current Row
    begin
      CurGray := GetPixGrayValue( Point( ix, iy ) ); // Gray Pix Value, may be > 255
      CurGray := (CurGray shr NumShiftR) and Mask; // "and Mask" is a precaution
      ABrighHistValues[CurGray] := ABrighHistValues[CurGray] + 1;
    end; // for ix := PixRect.Left to PixRect.Right do

  end; // for iy := PixRect.Top to PixRect.Bottom do // along all Pixel Rows

  if APMaxHistVal <> nil then // Calc APMaxHistVal^
  begin
    APMaxHistVal^ := 0;
    for i := 0 to MaxInd do
      if APMaxHistVal^ < ABrighHistValues[i] then APMaxHistVal^ := ABrighHistValues[i];
  end; // if APMaxHistVal <> nil then // Calc APMaxHistVal^

  if APMinHistInd <> nil then // Calc APMinHistInd^
    for i := 0 to MaxInd do
      if ABrighHistValues[i] > 0 then
      begin
        APMinHistInd^ := i;
        Break;
      end;

  if APMaxHistInd <> nil then // Calc APMaxHistInd^
    for i := MaxInd downto 0 do
      if ABrighHistValues[i] > 0 then
      begin
        APMaxHistInd^ := i;
        Break;
      end;

end; //*** end of procedure TN_DIBObj.CalcBrighHistNData

{
//************************************************* TN_DIBObj.FlipAndRotate ***
// Flip and Rotate DIB by given flags
//
procedure TN_DIBObj.FlipAndRotate( AFlipRotateFlags: TN_FlipRotateFlags );
var
  ix, iy, NX, NY, NXY, FlipFlags: integer;
  PixRow, PixMatr: TN_IArray;
begin
  NX := DIBInfo.bmi.biWidth;
  NY := DIBInfo.bmi.biHeight;
  NXY := NX*NY;

  //***** Create PixMatr with resulting content
  SetLength( PixMatr, NXY );

  for iy := 0 to NY-1 do // Along source PixRows
  begin
    GetPixValuesVector( PixRow, 0, iy, NX-1, iy );
    FlipFlags := byte(AFlipRotateFlags);

    case FlipFlags of
     // 0 <= Flags <= 3, frfFlipDiag flag is OFF in AFlipRotateFlags
     //                  (Horizontal Rows remains Horizontal, Vertical remains Vertical)

      0: // identity transformation
         for ix := 0 to NX-1 do // along pixels in iy-th source Row
            PixMatr[ix + iy*NY] := PixRow[ix];

      1: // Flip relative to Vertical Axis (reverse resulting Horizontal rows)
         for ix := 0 to NX-1 do // along pixels in iy-th source Row
            PixMatr[NX-ix-1 + iy*NX] := PixRow[ix];

      2: // Flip relative to Horizontal Axis (reverse resulting Vertical columns)
         for ix := 0 to NX-1 do // along pixels in iy-th source Row
            PixMatr[ix + (NY-iy-1)*NX] := PixRow[ix];

      3: // Flip relative to both Axises (reverse resulting Horizontal rows and Vertical columns)
         for ix := 0 to NX-1 do // along pixels in iy-th source Row
            PixMatr[NX-ix-1 + (NY-iy-1)*NX] := PixRow[ix];

      // 4 <= Flags <= 7,  frfFlipDiag flag is ON in AFlipRotateFlags
      //                   (Horizontal Rows become Vertical and vica verse)

      4: // x and y are swaped, both resulting directions are the same
         for ix := 0 to NX-1 do // along pixels in iy-th source Row
            PixMatr[iy + ix*NY] := PixRow[ix]; // identity transformation

      5: // x and y are swaped, reverse resulting Horizontal rows
         for ix := 0 to NX-1 do // along pixels in iy-th source Row
            PixMatr[NY-iy-1 + ix*NY] := PixRow[ix];

      6: // x and y are swaped, reverse resulting Vertical columns
         for ix := 0 to NX-1 do // along pixels in iy-th source Row
            PixMatr[iy + (NX-ix-1)*NY] := PixRow[ix];

      7: // x and y are swaped, reverse resulting Horizontal rows and Vertical columns
         for ix := 0 to NX-1 do // along pixels in iy-th source Row
            PixMatr[NY-iy-1 + (NX-ix-1)*NY] := PixRow[ix];

    end; // case FlipFlags of

  end; // for iy := 0 to NY-1 do // Along source PixRows

  if frfFlipDiag in AFlipRotateFlags then // Horizontal Rows become Vertical and vica verse
  begin
    PrepEmptyDIBObj( NY, NX, pf24bit ); // swap dimensions
    SetPixValuesRect( PixMatr, 0, 0, NY-1, NX-1 ); // write PixMatr back
  end else // Horizontal Rows remains Horizontal, Vertical remains Vertical
  begin
    PrepEmptyDIBObj( NX, NY, pf24bit ); // same dimensions
    SetPixValuesRect( PixMatr, 0, 0, NX-1, NY-1 ); // write PixMatr back
  end; //  else // Horizontal Rows remains Horizontal, Vertical remains Vertical

end; //*** end of procedure TN_DIBObj.FlipAndRotate
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\FlipAndRotate
//************************************************* TN_DIBObj.FlipAndRotate ***
// Flip and Rotate DIB by given flags
//
procedure TN_DIBObj.FlipAndRotate( AFlipRotateFlags: integer );
var
  TmpMatrSize, XPPM, YPPM: integer;
  SrcSM, DstSM: TN_SMatrDescr;
  TmpMatr: TN_BArray;
begin
  PrepSMatrDescr( @SrcSM );
  PrepSMatrDescrByFlags( @DstSM, AFlipRotateFlags, @TmpMatrSize );

  SetLength( TmpMatr, TmpMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@TmpMatr[0]);

  N_Conv2SMCopy( @SrcSM, @DstSM, 0 ); // Convert (Flip and Rotate) Self to TmpMatr

  if (AFlipRotateFlags and N_FlipDiagBit) <> 0 then // Horizontal Rows become Vertical and vica verse
    with DstSM do // swap X,Y dimensions, preserve PelsPerMeter
    begin
      XPPM := DIBINFO.bmi.biXPelsPerMeter;
      YPPM := DIBINFO.bmi.biYPelsPerMeter;

      PrepEmptyDIBObj( SMDNumY, SMDNumX, DIBPixFmt, -1, DIBExPixFmt, DIBNumBits );

      DIBINFO.bmi.biXPelsPerMeter := YPPM;
      DIBINFO.bmi.biYPelsPerMeter := XPPM;
    end;

  move( TmpMatr[0], PRasterBytes^, TmpMatrSize ); // copy TmpMatr back to Self
end; //*** end of procedure TN_DIBObj.FlipAndRotate

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\RotateByAngle
//************************************************* TN_DIBObj.RotateByAngle ***
// Rotate Image by any Angle
//
//     Parameters
// AFlipRotateFlags - Flip/Rotate Flags
// AAngle           - given Rotation angle in degree
// AFillColor       - given Resulting DIB Background Color
// AResDIB          - Resulting Rotated TN_DIBObj
// APPixAffCoefs6   - Pointer to resulting AffCoefs6 coeficients for Pixels 
//                    coordinates transformation or nil
// APNormAffCoefs6  - Pointer to resulting AffCoefs6 coeficients for Normalized 
//                    coordinates transformation or nil
// AMaxPixelsSize   - Max resulting Image size in Pixels or 0 if size should not
//                    be restricted
//
// Resulting DIB size is defined by Envelope of Rotated Self Rectangle and 
// scaled (if needed) to AMaxMegaPixels. Resulting DIB is filled first by given 
// ABackColor and after it rotated pixels are drawn. Normalized coordinates 
// transformation (assuming that Self and Resulting DIB have both 
// (0,0)-(100,100) coordinates) can be used for User Coords transformation
//
// epfColor48 is not implemented
//
procedure TN_DIBObj.RotateByAngle( AFlipRotateFlags: integer; AAngle: double;
                                   AFillColor: integer; var AResDIB: TN_DIBObj;
                                   APPixAffCoefs6: TN_PAffCoefs6 = nil;
                                   APNormAffCoefs6:  TN_PAffCoefs6 = nil;
                                   AMaxPixelsSize: integer = 0 );
var
  ix, iy, MaxSize, TmpSizeX, TmpSizeY: integer;
  SizeCoef: double;
  ResSize: TPoint;
  ResEnvRect, ReducedDIBRect: TRect;
  CurRect: TRect;
  InpPixReper, InpPixReper2, OutPixReper, InpUCReper, OutUCReper: TN_3DPReper;
  PixAffCoefs6, BackPixAffCoefs6: TN_AffCoefs6;
begin
  //*** Calculate ResEnvRect, InpReper, OutReper
  N_CalcRotatedRectCoords( DIBRect, AAngle, ResEnvRect, InpPixReper, OutPixReper );
  ResSize := N_RectSize( ResEnvRect ); // Needed Resulting DIB Size in Pixels

  SizeCoef := 0.0;
  if AMaxPixelsSize > 0 then
    SizeCoef := sqrt( 1.0*ResSize.X*ResSize.Y / AMaxPixelsSize );

  if SizeCoef > 1.0 then // reduce resulting DIB size
  begin
    ReducedDIBRect := DIBRect; // TopLeft is always (0,0)
    ReducedDIBRect.Right  := Round( DIBRect.Right / SizeCoef );
    ReducedDIBRect.Bottom := Round( DIBRect.Bottom / SizeCoef );
    N_CalcRotatedRectCoords( ReducedDIBRect, AAngle, ResEnvRect, InpPixReper2, OutPixReper );
    ResSize := N_RectSize( ResEnvRect ); // Final Resulting DIB Size in Pixels
  end; // if SizeCoef > 1.0 then // reduce resulting DIB size

  //*** Create or prepare empty (filled by AFillColor) AResDIB

  if AResDIB = nil then // Create AResDIB
    AResDIB := TN_DIBObj.Create( ResSize.X, ResSize.Y, DIBPixFmt, AFillColor, DIBExPixFmt )
  else // AResDIB exists, prepare it
    AResDIB.PrepEmptyDIBObj( ResSize.X, ResSize.Y,  DIBPixFmt, AFillColor, DIBExPixFmt );

  if DIBExPixFmt = epfColor48 then
  begin
    //************** not implemented!
    N_Dump1Str( 'RotateByAngle is not implemented for epfColor48!' );
  end else if DIBExPixFmt = epfGray16 then // Use ImageLibrary, N_StretchRect will not work
  begin
    if N_ImageLib.ILInitAll() <> 0 then
    begin
      N_Dump1Str( 'N_ImageLib.ILInitAll failed!' );
    end else // N_ImageLib is OK
    begin
      PixAffCoefs6     := N_CalcAffCoefs6( InpPixReper, OutPixReper );
      BackPixAffCoefs6 := N_CalcAffCoefs6( OutPixReper, InpPixReper );
      N_i := N_ImageLib.ILSetRotateParams( PDouble(@PixAffCoefs6),
                                           PDouble(@BackPixAffCoefs6),
                                           N_ILNearest ); // N_ILNearest N_ILBiLinear N_ILBiCubic
      TmpSizeX := ResSize.X;
      TmpSizeY := ResSize.Y;
      MaxSize := 2000;

      N_T1.Start();
      for ix := 0 to TmpSizeX div MaxSize + 2 do
      for iy := 0 to TmpSizeY div MaxSize + 2 do
      begin
        CurRect := Rect( ix*MaxSize, iy*MaxSize, (ix+1)*MaxSize-1, (iy+1)*MaxSize-1 );
        if CurRect.Left >= TmpSizeX then Continue;
        if CurRect.Top  >= TmpSizeY then Continue;
        CurRect.Right  := min( CurRect.Right,  TmpSizeX-1 );
        CurRect.Bottom := min( CurRect.Bottom, TmpSizeY-1 );
        N_Dump1Str( Format( 'ILRotateRect PSrc=%u, PDst=%u',  [PRasterBytes, AResDIB.PRasterBytes] ) );
        N_i := N_ImageLib.ILRotateRect( @DIBInfo, PRasterBytes, @CurRect, @AResDIB.DIBInfo, AResDIB.PRasterBytes );
      end;
      N_T1.SSS( 'ImageLib RotateRect' );

    end; // else // N_ImageLib is OK

  end else // DIBExPixFmt = epfGray8 or epfBMP, Windows GDI can be used
  begin
    //*** Calc APixAffCoefs6 and Draw rotated Pixels using Windows.StretchBlt
    PixAffCoefs6 := N_CalcAffCoefs6( InpPixReper, OutPixReper );
    if APPixAffCoefs6 <> nil then APPixAffCoefs6^ := PixAffCoefs6;

    //*** Set Windows transformation in AResDIB.DIBOCanv.HMDC
    N_b := Windows.SetWorldTransform( AResDIB.DIBOCanv.HMDC, N_ConvToXForm( PixAffCoefs6 ) );

    //*** Draw transformed(rotated) Pixels
    //  N_StretchRect( AResDIB.DIBOCanv.HMDC, DIBRect, DIBOCanv.HMDC, DIBRect );

    TmpSizeX := ResSize.X;
    TmpSizeY := ResSize.Y;
    MaxSize := 2000;

    //  N_T1.Start();
    for ix := 0 to TmpSizeX div MaxSize + 2 do
    for iy := 0 to TmpSizeY div MaxSize + 2 do
    begin
      CurRect := Rect( ix*MaxSize, iy*MaxSize, (ix+1)*MaxSize-1, (iy+1)*MaxSize-1 );
      if CurRect.Left >= TmpSizeX then Continue;
      if CurRect.Top  >= TmpSizeY then Continue;
      CurRect.Right  := min( CurRect.Right,  TmpSizeX-1 );
      CurRect.Bottom := min( CurRect.Bottom, TmpSizeY-1 );
      N_StretchRect( AResDIB.DIBOCanv.HMDC, CurRect, DIBOCanv.HMDC, CurRect );
    end;
    //  N_T1.SSS( 'GDI StrechRect' );

    //*** Clear Windows transformation in AResDIB.DIBOCanv.HMDC (N_XForm is not used)
    Windows.ModifyWorldTransform( AResDIB.DIBOCanv.HMDC, N_XForm, MWT_IDENTITY );

  end; // else // DIBExPixFmt = epfGray8 or epfBMP, Windows GDI can be used

  if APNormAffCoefs6 <> nil then // Calc APNormAffCoefs6^ for Norm. Coords transformation
  begin
    InpUCReper.P1.X := 0;
    InpUCReper.P1.Y := 0;
    InpUCReper.P2.X := 100;
    InpUCReper.P2.Y := 0;
    InpUCReper.P3.X := 0;
    InpUCReper.P3.Y := 100;

    OutUCReper.P1.X := 100.0*OutPixReper.P1.X/ResEnvRect.Right;
    OutUCReper.P1.Y := 100.0*OutPixReper.P1.Y/ResEnvRect.Bottom;
    OutUCReper.P2.X := 100.0*OutPixReper.P2.X/ResEnvRect.Right;
    OutUCReper.P2.Y := 100.0*OutPixReper.P2.Y/ResEnvRect.Bottom;
    OutUCReper.P3.X := 100.0*OutPixReper.P3.X/ResEnvRect.Right;
    OutUCReper.P3.Y := 100.0*OutPixReper.P3.Y/ResEnvRect.Bottom;

    APNormAffCoefs6^ := N_CalcAffCoefs6( InpUCReper, OutUCReper );
  end; // if APNormAffCoefs6 <> nil then // Calc APNormAffCoefs6^ for Norm. Coords transformation

end; //*** end of procedure TN_DIBObj.RotateByAngle

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Rotate90CCW
//*************************************************** TN_DIBObj.Rotate90CCW ***
// Rotate DIB by 90 degree CounterClockwise
//
procedure TN_DIBObj.Rotate90CCW();
var
  ix, iy, NX, NY, NXY: integer;
  PixRow, PixMatr: TN_IArray;
begin
  NX := DIBInfo.bmi.biWidth;
  NY := DIBInfo.bmi.biHeight;
  NXY := NX*NY;

  //***** Create PixMatr with rotated content
  SetLength( PixMatr, NXY );

  for iy := 0 to NY-1 do // Along PixRows (iy=0 means lowest Row)
  begin
    GetPixValuesVector( PixRow, 0, iy, NX-1, iy );

    for ix := 0 to NX-1 do // Rotate PixRow to PixMatr Column
      PixMatr[NY-1-iy + ix*NY] := PixRow[ix];

  end; // for iy := 0 to NY-1 do // Along PixRows

  PrepEmptyDIBObj( NY, NX, pf24bit ); // change dimensions
  SetPixValuesRect( PixMatr, 0, 0, NY-1, NX-1 ); // write PixMatr back
end; //*** end of procedure TN_DIBObj.Rotate90CCW

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Rotate90CW
//**************************************************** TN_DIBObj.Rotate90CW ***
// Rotate DIB by 90 degree Clockwise
//
procedure TN_DIBObj.Rotate90CW();
var
  ix, iy, NX, NY, NXY: integer;
  PixRow, PixMatr: TN_IArray;
begin
  NX := DIBInfo.bmi.biWidth;
  NY := DIBInfo.bmi.biHeight;
  NXY := NX*NY;

  //***** Create PixMatr with rotated content
  SetLength( PixMatr, NXY );

  for iy := 0 to NY-1 do // Along PixRows (iy=0 means lowest Row)
  begin
    GetPixValuesVector( PixRow, 0, iy, NX-1, iy );

    for ix := 0 to NX-1 do // Rotate PixRow to PixMatr Column
      PixMatr[iy + (NX-1-ix)*NY] := PixRow[ix];

  end; // for iy := 0 to NY-1 do // Along PixRows

  PrepEmptyDIBObj( NY, NX, pf24bit ); // change dimensions
  SetPixValuesRect( PixMatr, 0, 0, NY-1, NX-1 ); // write PixMatr back
end; //*** end of procedure TN_DIBObj.Rotate90CW

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Rotate180
//***************************************************** TN_DIBObj.Rotate180 ***
// Rotate Image by 180 degree
//
procedure TN_DIBObj.Rotate180();
var
  iy, NX, NY: integer;
  PixRow1, PixRow2: TN_IArray;
begin
  NX := DIBInfo.bmi.biWidth;
  NY := DIBInfo.bmi.biHeight;

  for iy := 0 to (NY div 2)-1 do // Reverse Rows as whole and elements in them
  begin
    GetPixValuesVector( PixRow1, 0, iy, NX-1, iy );
    N_ReverseIntArray( PixRow1, NX );

    GetPixValuesVector( PixRow2, 0, NY-iy-1, NX-1, NY-iy-1 );
    N_ReverseIntArray( PixRow2, NX );

    SetPixValuesVector( PixRow2, 0, iy, NX-1, iy ); // write Reverse PixRow2
    SetPixValuesVector( PixRow1, 0, NY-iy-1, NX-1, NY-iy-1 ); // write Reverse PixRow1
  end; // for iy := 0 to (NY div 2)-1 do // Reverse Rows as whole and elements in them
end; //*** end of procedure TN_DIBObj.Rotate180

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\FlipHorizontal
//************************************************ TN_DIBObj.FlipHorizontal ***
// Flip DIB Horizontal
//
procedure TN_DIBObj.FlipHorizontal();
var
  iy, NX, NY: integer;
  PixRow: TN_IArray;
begin
  NX := DIBInfo.bmi.biWidth;
  NY := DIBInfo.bmi.biHeight;

  for iy := 0 to NY-1 do // Reverse Rows as whole
  begin
    GetPixValuesVector( PixRow, 0, iy, NX-1, iy );
    N_ReverseIntArray( PixRow, NX );
    SetPixValuesVector( PixRow, 0, iy, NX-1, iy ); // write Reverse PixRow
  end; // for iy := 0 to NY-1 do // Reverse Rows as whole
end; //*** end of procedure TN_DIBObj.FlipHorizontal

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\FlipVertical
//************************************************** TN_DIBObj.FlipVertical ***
// Flip DIB Vertical
//
procedure TN_DIBObj.FlipVertical();
var
  ix, NX, NY: integer;
  PixCol: TN_IArray;
begin
  NX := DIBInfo.bmi.biWidth;
  NY := DIBInfo.bmi.biHeight;

  for ix := 0 to NX-1 do // Along Pix Columns
  begin
    GetPixValuesVector( PixCol, ix, 0, ix, NY-1 );
    N_ReverseIntArray( PixCol, NY );
    SetPixValuesVector( PixCol, ix, 0, ix, NY-1 );
  end; // for ix := 0 to NX-1 do // Along Pix Columns
end; //*** end of procedure TN_DIBObj.FlipVertical

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\XORPixels
//***************************************************** TN_DIBObj.XORPixels ***
// XOR DIB Pixels with given Operand (Pix = Pix xor AOP)
//
//     Parameters
// AXOROP - XOR Operand
//
procedure TN_DIBObj.XORPixels( AXOROP: integer );
var
  SMD: TN_SMatrDescr;
  ProcObj: TN_OnePtrProcObj;
begin
  PrepSMatrDescr( @SMD );

  with SMD, N_PixOpObj do
  begin
    if DIBExPixFmt = epfGray16 then
      PO_IntOperand := AXOROP and ( $FFFF shr (16 - DIBNumBits) )
    else
      PO_IntOperand := AXOROP;

    case SMDElSize of // set needed ProcObj
      1: ProcObj := PO_XOROneByte;
      2: ProcObj := PO_XORTwoBytes;
      3: ProcObj := PO_XORThreeBytes;
      4: ProcObj := PO_XORFourBytes;
    else ProcObj := nil; // a precaution
    end; // case SMDElSize of

    N_Conv1SMProcObj( @SMD, ProcObj ); // XOR DIB Pixels by ProcObj
  end; // with SMD, N_PixOpObj do
end; // procedure TN_DIBObj.XORPixels

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcSmoothedMatr
//********************************************** TN_DIBObj.CalcSmoothedMatr ***
// Calculate Smoothed Matrix from Self Matrix by given coefficients Matrix
//
//     Parameters
// ADstMatr - resulting smoothed Matrix
// APCM     - Pointer to first element of Float coefficients Matrix
// ACMDim   - coefficients Matrix Dimension ( should be odd (3,5,7,...) )
//
procedure TN_DIBObj.CalcSmoothedMatr( var ADstMatr: TN_BArray;
                                      APCM: PFloat; ACMDim: integer );
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  PrepSMatrDescr( @SrcSM );
  PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMbyMatr( @SrcSM, @DstSM, APCM, ACMDim );
end; // procedure TN_DIBObj.CalcSmoothedMatr


//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcLinCombDIB
//************************************************ TN_DIBObj.CalcLinCombDIB ***
// Calculate Liner combination of Self Matrix and given Matrix
//
//     Parameters
// ADstDIB   - resulting DIB Object which is linear combination of Self DIB  and
//             APSrcMatr
// APSrcMatr - pointer to first element of Sorce Matrix
// AAlfa     - coefficient for calculating Linear Combination
//
// All three Matrixes (Self Matrix, APSrcMatr and ADstDIB) should have same 
// description (dimensions and element size). Any resulting Element calculate as
// ADstDIB[i] = Alfa*APSrcMatr[i] + (1 - Alfa)*Self[i]
//
procedure TN_DIBObj.CalcLinCombDIB( var ADstDIB: TN_DIBObj; APSrcMatr: Pointer; AAlfa: double );
var
  SMatrDescr: TN_SMatrDescr;
begin
  // Prepare ADstDIB size and format
  PrepEDIBAndSMD( ADstDIB, 0, @SMatrDescr, nil, DIBPixFmt, DIBExPixFmt, DIBNumBits );

//  N_AppShowString( Format( 'Alfa=%.2f', [AAlfa] )); // for Debug

  N_Conv3SMLinComb( @SMatrDescr, APSrcMatr, ADstDIB.PRasterBytes, AAlfa );
end; // procedure TN_DIBObj.CalcLinCombDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\XLATSelf
//****************************************************** TN_DIBObj.XLATSelf ***
// Convert Self by given XLAT Table
//
//     Parameters
// APXLAT    - pointer to first elelemnt of integer XLAT Table
// AXLATType - Number of used bytes in one XLAT element (1 or 3)
//
// If Self Element Size = 1,  XLAT Table should contain at least 2**8  elements 
// If Self Element Size = 2,  XLAT Table should contain at least 2**16 elements 
// If Self Element Size = 3,4 XLAT Table should contain at least 2**8  elements,
// all three Pixel bytes are converted by the same XLAT Table
//
procedure TN_DIBObj.XLATSelf( APXLAT: PInteger; AXLATType: integer );
var
  SelfSM: TN_SMatrDescr;
begin
  PrepSMatrDescr( @SelfSM );
  N_Conv2SMXLAT( @SelfSM, @SelfSM, APXLAT, AXLATType )
end; // procedure TN_DIBObj.XLATSelf

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcXLATDIB
//*************************************************** TN_DIBObj.CalcXLATDIB ***
// Convert Self to resulting DIB Object by given Flip/Rotate Flags and XLAT 
// Table
//
//     Parameters
// ADstDIB          - resulting DIB Object (on input ADstDIB may exists or may 
//                    be nil)
// AFlipRotateFlags - Flip and Rotate Flags
// APXLAT           - integer XLAT Table
// AXLATType        - Number of used bytes in one XLAT element (1 or 3)
// APixFmt          - resulting DIBObj Main pixel format
// AExPixFmt        - resulting DIBObj Extended pixel format
//
// If ADstDIB is nil, it will be created. If ADstDIB exists but have not proper 
// attributes (Size and Pixel format) it will be restructed properly. ADstDIB 
// cannot be the same object as Self.
//
// APXLAT may be nil (it will not be used, only AFlipRotateFlags will matter)
//
// If Self Element Size = 1,  XLAT Table should contain at least 2**8  elements 
// If Self Element Size = 2,  XLAT Table should contain at least 2**16 elements 
// If Self Element Size = 3,4 XLAT Table should contain at least 2**8  elements 
// all three Pixel bytes are converted by the same XLAT Table
//
procedure TN_DIBObj.CalcXLATDIB( var ADstDIB: TN_DIBObj; AFlipRotateFlags: integer;
                                 APXLAT: PInteger; AXLATType: integer;
                                 APixFmt: TPixelFormat; AExPixFmt: TN_ExPixFmt = epfBMP );
var
  SelfSM, DstSM: TN_SMatrDescr;
begin
  PrepEDIBAndSMD( ADstDIB, AFlipRotateFlags, @SelfSM, @DstSM, APixFmt, AExPixFmt, DIBNumBits );

  if APXLAT <> nil then
    N_Conv2SMXLAT( @SelfSM, @DstSM, APXLAT, AXLATType )
  else
    N_Conv2SMCopy( @SelfSM, @DstSM, 0 );
end; // procedure TN_DIBObj.CalcXLATDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcGrayDIB
//*************************************************** TN_DIBObj.CalcGrayDIB ***
// Calculate resulting Gray DIB from Self
//
//     Parameters
// AResDIB - given DIB Object which content should be calculated
//
// AResDIB should have same size as Self. AResDIB can have any pixel format 
// except pf1bit, pf4bit, pf16bit. For pf24bit and pf32bit resulting DIB will 
// have same RGB bytes in each pixel
//
procedure TN_DIBObj.CalcGrayDIB( AResDIB: TN_DIBObj );
var
  SrcSM, DstSM: TN_SMatrDescr;
begin
  PrepSMatrDescr( @SrcSM );
  AResDIB.PrepSMatrDescr( @DstSM );

  N_Conv2SMToGray( @SrcSM, @DstSM );
end; // procedure TN_DIBObj.CalcGrayDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\Convpf8BitToGray8
//********************************************* TN_DIBObj.Convpf8BitToGray8 ***
// Convert Self from pf8Bit format to epfGray8
//
// If Self is not pf8Bit, Self is not changed
//
procedure TN_DIBObj.Convpf8BitToGray8();
var
  i, ix, iy, ColorValue, GrayValue: integer;
  CurPByte: TN_BytesPtr;
begin
  if DIBPixFmt <> pf8Bit then Exit;

  for iy := 0 to DIBSize.Y-1 do
  begin
    for ix := 0 to DIBSize.X-1 do
    begin
      ColorValue := GetPixColor( Point(ix,iy) );
      CurPByte   := TN_BytesPtr(@ColorValue);
      GrayValue  := Round( 0.114*PByte(CurPByte)^   +  // Blue
                           0.587*PByte(CurPByte+1)^ +  // Green
                           0.299*PByte(CurPByte+2)^ ); // Red
      SetPixValue( Point(ix,iy), GrayValue );
    end; // for ix := 0 to DIBSize.X-1 do
  end; // for iy := 0 to DIBSize.Y-1 do

  for i := 0 to 255 do // Create Gray Palette
   DIBInfo.PalEntries[i] := (i shl 16) or (i shl 8) or i;

  DIBPixFmt   := pfCustom;
  DIBExPixFmt := epfGray8;
end; // procedure TN_DIBObj.Convpf8BitToGray8

{
//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcEmbossDIB(3)
//********************************************** TN_DIBObj.CalcEmbossDIB(3) ***
// Not used, should be excluded
// Calculate resulting DIB with Emboss effect from Self
//
//     Parameters
// AResDIB - given DIB Object which content should be calculated
//
// AResDIB should have same size as Self and should be Gray.
//
procedure TN_DIBObj.CalcEmbossDIB( AResDIB: TN_DIBObj; ADelta: TPoint; out AMin, AMax: integer );
var
  SrcSM, DstSM: TN_SMatrDescr;
begin
  PrepSMatrDescr( @SrcSM );
  AResDIB.PrepSMatrDescr( @DstSM );

  N_Conv2SMEmboss( @SrcSM, @DstSM, ADelta, AMin, AMax );
end; // procedure TN_DIBObj.CalcEmbossDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcEmbossDIB(1)
//********************************************** TN_DIBObj.CalcEmbossDIB(1) ***
// Not used, should be excluded
// Calculate resulting DIB with Emboss effect from Self
//
//     Parameters
// AResDIB   - DIB Object which content should be calculated
// ADelta    - given depth in X and Y direction (distance in pixels between
//             points to process)
// ABaseGray - intensity value in (0,255) range
// APXLAT    - integer XLAT Table to improve resulting DIB
// AMin      - resulting DIB minimal pixel intensity
// AMax      - resulting DIB maximal pixel intensity
//
// AResDIB should have same size as Self and should be Gray.
//
procedure TN_DIBObj.CalcEmbossDIB( AResDIB: TN_DIBObj; ADelta: TPoint;
                                   ABaseGray: integer; APXLAT: PInteger; out AMin, AMax: integer );
var
  SrcSM, DstSM: TN_SMatrDescr;
begin
  PrepSMatrDescr( @SrcSM );
  AResDIB.PrepSMatrDescr( @DstSM );

  N_Conv2SMEmboss( @SrcSM, @DstSM, ADelta, AMin, AMax );
end; // procedure TN_DIBObj.CalcEmbossDIB
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcEmbossDIB(2)
//********************************************** TN_DIBObj.CalcEmbossDIB(2) ***
// Calculate resulting DIB with Emboss effect from Self
//
//     Parameters
// AResDIB   - DIB Object which content should be calculated
// AAngle    - direction angle in degree (counterclockwise from X Axes)
// ACoef     - coefficient for nonlinear Intensity convertion in (-100.0, 100.0)
//             range
// ADepth    - depth (>0, distance in pixels between points to process)
// ABaseGray - intensity value in (0,255) range
//
// AResDIB should have same size as Self and should be epfGray8. If all pixels 
// of Self have same color, all AResDIB pixels will equal to ABaseGray. ACoef = 
// 0 means that there will be no nonlinear convertion. ACoef > 0 means that 
// pixels near ABaseGray will be more contrast than other pixels ACoef < 0 means
// that pixels near ABaseGray will be less contrast than other pixels
//
procedure TN_DIBObj.CalcEmbossDIB( AResDIB: TN_DIBObj; AAngle, ACoef: float;
                                   ADepth, ABaseGray: integer );
var
  Delta: TPoint;
  SrcSM, DstSM: TN_SMatrDescr;
  XLAT: TN_IArray;
begin
  PrepSMatrDescr( @SrcSM );
  AResDIB.PrepSMatrDescr( @DstSM );

  Delta.X := -round( ADepth * sin( AAngle * N_PI / 180 ) );
  Delta.Y :=  round( ADepth * cos( AAngle * N_PI / 180 ) );

  N_CreateArcTangXLAT( XLAT, 255, ABaseGray, 511, ACoef );

  N_Conv2SMEmboss2( @SrcSM, @DstSM, Delta, @XLAT[0] );
end; // procedure TN_DIBObj.CalcEmbossDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcMaxContrastDIB
//******************************************** TN_DIBObj.CalcMaxContrastDIB ***
// Calculate resulting Maximum Contrast DIB from Self
//
//     Parameters
// AResDIB - Resulting DIB Object which content should be calculated (may be 
//           nil)
//
// Now Self should be epfGray8 or epfGray16
//
// Self DIBNumBits is always preserved
//
procedure TN_DIBObj.CalcMaxContrastDIB( var AResDIB: TN_DIBObj );
var
  XLATLeng, MinHistInd, MaxHistInd, NewMaxVal: integer;
  XLAT, HistData: TN_IArray;
  SelfSM, DstSM: TN_SMatrDescr;
begin
  if (DIBExPixFmt <> epfGray8) and (DIBExPixFmt <> epfGray16) then // not implemented
    raise Exception.Create( 'CalcMaxContrastDIB not implemented for not grey images' );

  if DIBExPixFmt = epfGray16 then // self is Gray16, AResDIB will be Gray8 or Gray16
  begin
    CalcBrighHistNData( HistData, nil, @MinHistInd, @MaxHistInd, nil, 16 );
//    N_DumpIntegers( @HistData[0], 65535, $41, 'C:\a1.txt' ); // Dump Historgamm for debug
    XLATLeng := 256*256;
    PrepEDIBAndSMD( AResDIB, 0, @SelfSM, @DstSM, pfCustom, epfGray16, DIBNumBits );
  end else // self and AResDIB are Gray8
  begin
    CalcBrighHistNData( HistData, nil, @MinHistInd, @MaxHistInd, nil, 8 );
    XLATLeng := 256;
    PrepEDIBAndSMD( AResDIB, 0, @SelfSM, @DstSM, pfCustom, epfGray8 );
  end;

  SetLength( XLAT, XLATLeng );
  NewMaxVal := (1 shl DIBNumBits) - 1;

  // Convert (MinHistInd,MaxHistInd) pixels to (0,NewMaxVal)
  N_SetXLATFragm( @XLAT[0], MinHistInd, MaxHistInd, 0, NewMaxVal );
  N_Conv2SMXLAT( @SelfSM, @DstSM, @XLAT[0], 1 )
end; // procedure TN_DIBObj.CalcMaxContrastDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcIncrContrastDIB
//******************************************* TN_DIBObj.CalcIncrContrastDIB ***
// Calculate resulting DIB from Self with increased contrast
//
//     Parameters
// AResDIB - Resulting DIB Object with increased contrast (may be nil)
// ACoef   - in [0,1] Range
//
// AResDIB, if given, should be the same size and type as Self Now Self should 
// be epfGray8 or epfGray16 Self DIBNumBits is always preserved
//
procedure TN_DIBObj.CalcIncrContrastDIB( var AResDIB: TN_DIBObj; ACoef: double );
var
  ILL, IUL, ILL1, IUL1, ILL2, IUL2, XLATLength: Integer;
  HistValues, XLAT: TN_IArray;
  WrkLLFactor, WrkULFactor: FLoat;
  Alfa: Double;
begin
  CalcBrighHistNData( HistValues );
  N_HistFindLLULPar2( HistValues, 0, ILL1, IUL1 ); // aggressive (peaks  and valleys removed)
  N_HistFindLLULPar2( HistValues, 1, ILL2, IUL2 ); // not aggressive (only peaks removed)

  Alfa := max( 0, min( ACoef, 1.0 ) ); // a precation
  ILL := round( ILL1*Alfa + ILL2*(1.0-Alfa) );
  IUL := round( IUL1*Alfa + IUL2*(1.0-Alfa) );

  N_Dump1Str( Format( 'CalcIncrContrastDIB ILL1=%d, ILL2=%d, ILL=%d,  IUL1=%d, IUL2=%d, IUL=%d', [ILL1,ILL2,ILL,IUL1,IUL2,IUL] ) );

  WrkLLFactor := ILL / High(HistValues) * 100;
  WrkULFactor := IUL / High(HistValues) * 100;

// Correct LL/LU to Initial Values if needed
  if (WrkLLFactor = 0) and (WrkULFactor = 100) then
    WrkULFactor := 0;

  XLATLength := 1 shl DIBNumBits;
  SetLength( XLat, XLATLength );
  N_BCGImageXlatBuild( XLAT, XLATLength-1, 0, 0, 0, WrkLLFactor, WrkULFactor, FALSE );
  CalcXLATDIB( AResDIB, 0, @XLAT[0], 1, DIBPixFmt, DIBExPixFmt );

end; // procedure TN_DIBObj.CalcIncrContrastDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcEqualizedDIB
//********************************************** TN_DIBObj.CalcEqualizedDIB ***
// Calculate resulting Equalized DIB from Self
//
//     Parameters
// AResDIB    - Resulting DIB Object which content should be calculated (may be 
//              nil)
// ANumRanges - number of brightness ranges used in equalization algorithm
// AMaxCoef   - maximal coef. used in equalization algorithm (should be >= 1)
//
// Now Self should be epfGray8 or epfGray16
//
// Equalized DIB is DIB with Histogramm like constant
//
procedure TN_DIBObj.CalcEqualizedDIB( var AResDIB: TN_DIBObj; ANumRanges: integer;
                                      AMaxCoef: float );
var
  MinHistInd, MaxHistInd, MaxNumRanges: integer;
  XLAT, HistData, NIRs1, NIRs2: TN_IArray;
  GroupedData: TN_DArray;
  XLATLeng : Integer;
begin
  if (DIBExPixFmt <> epfGray8) and (DIBExPixFmt <> epfGray16) then // not implemented
    raise Exception.Create( 'CalcEqualizedDIB not implemented for not grey images' );

  CalcBrighHistNData( HistData, nil, @MinHistInd, @MaxHistInd, nil, DIBNumBits );
  XLATLeng := Length( HistData );

  MaxNumRanges := MaxHistInd - MinHistInd + 1;
  ANumRanges := min( ANumRanges, MaxNumRanges ); // otherwise divide by zero occures

  N_CalcUniformNIRs( NIRs1, ANumRanges, MinHistInd, MaxHistInd );
  N_GroupHistData( HistData, NIRs1, ANumRanges, GroupedData );
  N_UpdateNIRsByWCoefs( NIRs1, GroupedData, ANumRanges, NIRs2, 0, XLATLeng-1, AMaxCoef );
  N_CalcUniformXLAT( XLAT, XLATLeng );
  N_CalcXLATByTwoNIRs( XLAT, NIRs1, NIRs2, ANumRanges );
  CalcXLATDIB( AResDIB, 0, @XLAT[0], 1, pfCustom, DIBExPixFmt );
end; // procedure TN_DIBObj.CalcEqualizedDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcDeNoise1DIB
//*********************************************** TN_DIBObj.CalcDeNoise1DIB ***
// Calculate resulting DIB with reduced noise from Self, variant #1
//
//     Parameters
// AResDIB    - Resulting DIB Object which content should be calculated (may be 
//              nil)
//ANRDepth   - 
//ANRSigma   - 
//ANRThresh1 - 
//ANRThresh2 - 
//
// Now Self should be epfGray8 or epfGray16, resulting DIB will have same type
//
// Noise ruction variant #1 means using N_Conv3SMPrepNR1 and N_Conv3SMDoNR1
//
procedure TN_DIBObj.CalcDeNoise1DIB( var AResDIB: TN_DIBObj; ANRDepth: Integer;
                                     ANRSigma, ANRThresh1, ANRThresh2: Double );
var
  MeanMatr: TN_BArray;
  DeltaMatr: TN_BArray;
  NRCoefs: TN_FArray;
  MatrSize: Integer;
  SelfSMD: TN_SMatrDescr;
  SrcSMD, DstSMD: TN_SMatrDescr;
begin
  if (DIBExPixFmt <> epfGray8) and (DIBExPixFmt <> epfGray16) then // not implemented
    raise Exception.Create( Format( 'CalcDeNoise1DIB not implemented for DIBExPixFmt=%d', [integer(DIBExPixFmt)] ) );

  PrepSameDIBObj( AResDIB );

  N_CalcGaussMatr( NRCoefs, ANRDepth, ANRSigma, 1 );
  PrepSMatrDescr( @SelfSMD, @MatrSize );

  SetLength( MeanMatr, MatrSize );
  SetLength( DeltaMatr, MatrSize );

  N_Conv3SMPrepNR1( @SelfSMD, @MeanMatr[0], @DeltaMatr[0], @NRCoefs[0], ANRDepth );

  PrepSMatrDescr( @SrcSMD );
  AResDIB.PrepSMatrDescr( @DstSMD );

  N_Conv3SMDoNR1(@SrcSMD, @DstSMD, @MeanMatr[0], @DeltaMatr[0], @NRCoefs[0],
                                             ANRDepth, ANRThresh1, ANRThresh2 );
end; // procedure TN_DIBObj.CalcDeNoise1DIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcDeNoise2DIB
//*********************************************** TN_DIBObj.CalcDeNoise2DIB ***
// Calculate resulting DIB with reduced noise from Self, variant #2
//
//     Parameters
// AResDIB   - Resulting DIB Object which content should be calculated (may be 
//             nil)
//ANRDepth  - 
//ANRThresh - 
//
// Now Self should be epfGray8 or epfGray16, resulting DIB will have same type
//
// Noise ruction variant #2 means using N_Conv2SMby2DCleaner
//
procedure TN_DIBObj.CalcDeNoise2DIB( var AResDIB: TN_DIBObj; ANRDepth: Integer;
                                                            ANRThresh: Double );
var
  SrcSM, DstSM: TN_SMatrDescr;
begin
//  if (DIBExPixFmt <> epfGray8) and (DIBExPixFmt <> epfGray16) then // not implemented
//    raise Exception.Create( Format( 'CalcDeNoise2DIB not implemented for DIBExPixFmt=%d', [integer(DIBExPixFmt)] ) );

  PrepSameDIBObj( AResDIB );

  PrepSMatrDescr( @SrcSM );
  AResDIB.PrepSMatrDescr( @DstSM );

  N_Conv2SMby2DCleaner( @SrcSM, @DstSM, ANRDepth, ANRThresh );
end; // procedure TN_DIBObj.CalcDeNoise2DIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CalcDeNoise3DIB
//*********************************************** TN_DIBObj.CalcDeNoise3DIB ***
// Calculate resulting DIB with reduced noise from Self, variant #3
//
//     Parameters
// AResDIB  - Resulting DIB Object which content should be calculated (may be 
//            nil)
//ANRDepth - 
//
// Now Self should be epfGray8 or epfGray16, resulting DIB will have same type
//
// Noise ruction variant #2 means using N_Conv2SMMedianHuang
//
procedure TN_DIBObj.CalcDeNoise3DIB( var AResDIB: TN_DIBObj; ANRDepth: Integer );
var
  SrcSM, DstSM: TN_SMatrDescr;
begin
  if (DIBExPixFmt <> epfGray8) and (DIBExPixFmt <> epfGray16) then // not implemented
    raise Exception.Create( Format( 'CalcDeNoise2DIB not implemented for DIBExPixFmt=%d', [integer(DIBExPixFmt)] ) );

  PrepSameDIBObj( AResDIB );

  PrepSMatrDescr( @SrcSM );
  AResDIB.PrepSMatrDescr( @DstSM );

  N_Conv2SMMedianHuang( @SrcSM, @DstSM, ANRDepth );
end; // procedure TN_DIBObj.CalcDeNoise3DIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetMaxRGBDif
//************************************************** TN_DIBObj.GetMaxRGBDif ***
// Calculate maximal weighted difference between R,G,B values of all Self pixels
//
//     Parameters
// AMaxAllowedDif - Max Allowed difference between R,G,B values of all Pixels
//
function TN_DIBObj.GetMaxRGBDif( AMaxAllowedDif: double ): double;
var
  SelfSMD: TN_SMatrDescr;
begin
  if DIBPixFmt = pf8bit then // Analize Palette
  begin
    // not implemented!
  end; // if DIBPixFmt = pf8bit then // Analize Palette

  Result := 0;
  if DIBInfo.bmi.biBitCount < 24 then Exit; // a precaution

  PrepSMatrDescr( @SelfSMD );
  if SelfSMD.SMDElSize < 3 then Exit; // a precaution

  with N_PixOpObj do
  begin
    PO_MaxAllowedRGBDif := AMaxAllowedDif;
    PO_RealMaxRGBDif    := 0; // initial value, should be initialized!
    N_Conv1SMFuncObj( @SelfSMD, PO_RGBDifference );
    Result := PO_RealMaxRGBDif; // calculated value
  end; // with N_PixOpObj do
end; // function TN_DIBObj.GetMaxRGBDif

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\RectToStrings
//************************************************* TN_DIBObj.RectToStrings ***
// Add to Strings pixel values in given Arect using N_SMToText
//
//     Parameters
// ARect       - given Rect to convert (negative value A means Size+A)
// AFlags      - format flags (see N_SMToText)
// AName       - given Matrix Name to add in first string
// AResStrings - Strings Object, to which SubMatrix content will be added
// APMatrElems - pointer to first Matrix Element to convert, nil means Self
//
// Add to given Strings Object given rectangle fragment of Self or some other 
// Matrix (pointed by APMatrElems) with same description as Self. Used mainly 
// for debugging
//
procedure TN_DIBObj.RectToStrings( ARect: TRect; AFlags: integer; AName: string;
                                   AResStrings: TStrings; APUpperLeft: PPoint = nil; APMatrElems: TN_BytesPtr = nil );
var
  SM: TN_SMatrDescr;
begin
  PrepSMatrDescrByRect( @SM, ARect );

  N_SMToText( @SM, AFlags, AName, AResStrings, APUpperLeft, APMatrElems );
end; // procedure TN_DIBObj.RectToStrings

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\DIBPixToString
//************************************************ TN_DIBObj.DIBPixToString ***
// Obsolete, RectToStrings should be used instead
//
// Convert to Text given number of subsequent pixels
//
// Parameters AX, AY  - coords of start pixel ANumPix - given number of pixels 
// Result  - Return string with given number of subsequent pixels as Hex number
//
// Note: AX+ANumPix should be <= DIBSize.X Used mainly for debugging.
//
function TN_DIBObj.DIBPixToString( AX, AY, ANumPix: integer ): string;
var
  i: integer;
  AXY: TPoint;
begin
  if (AY >= 0) and (AY < DIBSize.Y) then AXY.Y := AY
                                    else AXY.Y := 0;

  if AX >= 0 then AXY.X := AX
             else AXY.X := 0;

  if (AXY.X+ANumPix) > DIBSize.X then AXY.X := DIBSize.X - ANumPix;

  Result := '';
  for i := 0 to ANumPix-1 do
  begin
    Result := Result + Format( '%.6X ', [GetPixColor(AXY)] );
    Inc( AXY.X );
  end;
end; // function TN_DIBObj.DIBPixToString

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\DIBCornersToStrings
//******************************************* TN_DIBObj.DIBCornersToStrings ***
// Add to given AResStrings DIBInfo and several Pixels in DIB corners
//
//     Parameters
// ADIBName    - DIBObj 'Name' (to simplify understanding which DIB is logged)
// AResStrings - Resulting Strings Object
//
// Convert to Text all self, self.DIBInfo fields and four DWords at image 
// corners. Used mainly for debugging.
//
procedure TN_DIBObj.DIBCornersToStrings( ADIBName: string; AResStrings: TStrings );
begin
  if AResStrings = nil then Exit; // a precaution

  N_DIBInfoToStrings( @DIBInfo, ADIBName, AResStrings );

  AResStrings.Add( DIBPixToString( 0, 0, 4 ) + '   ' + DIBPixToString( DIBSize.X-4, 0, 4 ) );
  AResStrings.Add( DIBPixToString( 0, 1, 4 ) + '   ' + DIBPixToString( DIBSize.X-4, 1, 4 ) );

  AResStrings.Add( DIBPixToString( 0, DIBSize.Y-2, 4 ) + '   ' + DIBPixToString( DIBSize.X-4, DIBSize.Y-2, 4 ) );
  AResStrings.Add( DIBPixToString( 0, DIBSize.Y-1, 4 ) + '   ' + DIBPixToString( DIBSize.X-4, DIBSize.Y-1, 4 ) );
end; // procedure TN_DIBObj.DIBCornersToStrings

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\DIBDump2Self
//************************************************** TN_DIBObj.DIBDump2Self ***
// Dump Self by N_Dump2Strings
//
//     Parameters
// ADIBName - DIBObj 'Name' (to simplify understanding which DIB is logged)
// AIndent  - number of spaces to add before all strings
//
procedure TN_DIBObj.DIBDump2Self( ADIBName: string; AIndent: integer );
begin
  N_SL.Clear();
  DIBCornersToStrings( ADIBName, N_SL );
  N_Dump2Strings( N_SL, AIndent );
end; // procedure TN_DIBObj.DIBDump2Self

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\DIBSelfToTextFile
//********************************************* TN_DIBObj.DIBSelfToTextFile ***
// Dump Self to Text file
//
//     Parameters
// AFName   - File Name
// ADIBName - DIBObj 'Name' (to simplify understanding which DIB is dumped)
// ARect    - all Pixels inside ARect will be dumped
// AFlags   - format flags, see N_IntToStr, bits 4-7 = 0 means auto format
//
procedure TN_DIBObj.DIBSelfToTextFile( AFName, ADIBName: string; ARect: TRect; AFlags: Integer );
begin
  N_SL.Clear;
  N_DIBInfoToStrings( @DIBInfo, ADIBName, N_SL );
//  N_SL.Add( '' );
  RectToStrings( ARect, AFlags, '', N_SL );
  N_SL.SaveToFile( AFName );
end; // procedure TN_DIBObj.DIBSelfToTextFile

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\DIBSelfToBothFiles
//******************************************** TN_DIBObj.DIBSelfToBothFiles ***
// Dump Self to Both - to BMP file and to Text file
//
//     Parameters
// AFName   - BMP File Name, Resulting Text file will have same name and .txt 
//            extention
// ADIBName - DIBObj 'Name' (to simplify understanding which DIB is dumped)
// ARect    - all Pixels inside ARect will be dumped
// AFlags   - format flags, see N_IntToStr, bits 4-7 = 0 means auto format
//
procedure TN_DIBObj.DIBSelfToBothFiles( AFName, ADIBName: string; ARect: TRect; AFlags: Integer );
begin
  SaveToBMPFormat( AFName );
  DIBSelfToTextFile( ChangeFileExt( AFName, '.txt' ), ADIBName, ARect, AFlags );
end; // procedure TN_DIBObj.DIBSelfToBothFiles

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\PixelsToStream
//************************************************ TN_DIBObj.PixelsToStream ***
// Write Pixels data to given AStream without any rows alignment
//
//     Parameters
// AStream - given Stream, where to write pixels
//
procedure TN_DIBObj.PixelsToStream( AStream: TStream );
var
  i,j,m: integer;
  PS: TN_BytesPtr;
  LBuf : TN_BArray;
  WB : TN_Byte;
begin
//  for i := 0 to DIBSize.Y-1 do // along all pixel rows
//    AStream.Write( (PRasterBytes + i*RRLineSize)^, RRBytesInLine );
  SetLength( LBuf, RRBytesInLine );
  m := RRBytesInLine div DIBSize.X;
  for i := DIBSize.Y-1 downto 0  do // along all pixel rows
  begin
    if m <> 3 then
      AStream.Write( (PRasterBytes + i*RRLineSize)^, RRBytesInLine )
    else
    begin
      Move( (PRasterBytes + i*RRLineSize)^, LBuf[0], RRBytesInLine );
      PS := TN_BytesPtr(@LBuf[0]);
      for j := 0 to DIBSize.X-1 do
      begin
        WB := PS^;
        PS^ := (PS + 2)^;
        (PS + 2)^ := WB;
        Inc( PS, 3 );
      end;
      AStream.Write( LBuf[0], RRBytesInLine )
    end;
  end;
end; // procedure TN_DIBObj.PixelsToStream

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\StreamToPixels
//************************************************ TN_DIBObj.StreamToPixels ***
// Read Pixels data from given AStream without any rows alignment
//
//     Parameters
// AStream - given Stream, where to write pixels
//
procedure TN_DIBObj.StreamToPixels( AStream: TStream );
var
  i,j,m: integer;
  PS: TN_BytesPtr;
  LBuf : TN_BArray;
  WB : TN_Byte;
begin
  SetLength( LBuf, RRBytesInLine );
  m := RRBytesInLine div DIBSize.X;
  for i := DIBSize.Y-1 downto 0  do // along all pixel rows
  begin
    if m <> 3 then
      AStream.Read( (PRasterBytes + i*RRLineSize)^, RRBytesInLine )
    else
    begin
      AStream.Read( LBuf[0], RRBytesInLine );
      PS := TN_BytesPtr(@LBuf[0]);
      for j := 0 to DIBSize.X-1 do
      begin
        WB := PS^;
        PS^ := (PS + 2)^;
        (PS + 2)^ := WB;
        Inc( PS, 3 );
      end;
      Move( LBuf[0], (PRasterBytes + i*RRLineSize)^, RRBytesInLine );
    end;
  end;
end; // procedure TN_DIBObj.StreamToPixels

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\AddAlfaBytes
//************************************************** TN_DIBObj.AddAlfaBytes ***
//
//
//     Parameters
// AAlfaDIBObj - TN_DIBObj object
//
procedure TN_DIBObj.AddAlfaBytes( AAlfaDIBObj: TN_DIBObj );
var
    DIBWidth, DIBHeight: Integer;
    SelfSMD, AlphaSM, ResSM: TN_SMatrDescr;
    tmpDIBObj: TN_DIBObj;
begin
  DIBWidth  := DIBInfo.bmi.biWidth;
  DIBHeight := DIBInfo.bmi.biHeight;

  AAlfaDIBObj.PrepSMatrDescr( @AlphaSM );

  if DIBInfo.bmi.biBitCount = 32 then
  begin
    PrepSMatrDescr( @ResSM );
    ResSM.SMDBegIX := ResSM.SMDBegIX + 3;
    N_Conv2SMCopy( @AlphaSM, @ResSM, 0 );
  end else
  begin
    tmpDIBObj := TN_DIBObj.Create(Self);
    PrepEmptyDIBObj( DIBWidth, DIBHeight, pf32bit );
    PrepSMatrDescr( @ResSM );
    tmpDIBObj.PrepSMatrDescr( @SelfSMD );
    N_Conv2SMCopy( @ResSM, @SelfSMD, 0 );

    ResSM.SMDBegIX := ResSM.SMDBegIX + 3;
    ResSM.SMDEndIX := ResSM.SMDEndIX + 3;
    N_Conv2SMCopy( @AlphaSM, @ResSM, 0 );

    FreeAndNil( tmpDIBObj );
    tmpDIBObj := nil;
  end;
end; // procedure TN_DIBObj.AddAlfaBytes

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\GetAlfaBytes
//************************************************** TN_DIBObj.GetAlfaBytes ***
//
//
//     Parameters
// AAlfaDIBObj - TN_DIBObj object
//
procedure TN_DIBObj.GetAlfaBytes( var AAlfaDIBObj: TN_DIBObj );
Var
  SelfSMD, AlphaSM: TN_SMatrDescr;
begin
  if DIBInfo.bmi.biBitCount <> 32 then Exit; // a precaution

  PrepSMatrDescr( @SelfSMD );
  if SelfSMD.SMDElSize <> 4 then Exit; // a precaution

  AAlfaDIBObj.PrepSMatrDescr( @AlphaSM );
  N_Conv2SMCopy( @SelfSMD, @AlphaSM, 0 );
end; // procedure TN_DIBObj.GetAlfaBytes

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\TN_DIBObj\CorrectResolution
//********************************************* TN_DIBObj.CorrectResolution ***
// Correct DIB bmi Resolution if biXPelsPerMeter, biYPelsPerMeter are not 
// correct
//
//     Parameters
// ADefPelsPerMeter - DIB PelsPerMeter default value (-1 means 72 DPI)
//
procedure TN_DIBObj.CorrectResolution( ADefPelsPerMeter: Integer );
var
  AbsRelDif: double;
begin
  if ADefPelsPerMeter = -1 then
    ADefPelsPerMeter := Round(72 * 100 / 2.54);

  with DIBInfo.bmi do
  begin
    AbsRelDif := abs( biXPelsPerMeter - biYPelsPerMeter ) /
                 max( 1.0, 1.0*max( biXPelsPerMeter, biYPelsPerMeter ) );

    if (AbsRelDif > 0.03) or
       (biXPelsPerMeter < Round(20 * 100 / 2.54)) or
       (biXPelsPerMeter > Round(200000 * 100 / 2.54)) then
      biXPelsPerMeter := ADefPelsPerMeter
    else
      biXPelsPerMeter := (biXPelsPerMeter + biYPelsPerMeter) div 2;

    biYPelsPerMeter := biXPelsPerMeter;
  end; // with DIBInfo.bmi do
end; // procedure TN_DIBObj.CorrectResolution

//************************************************ TN_DIBObj.CalcMaxGrayVal ***
// Calc max Gray value along all pixels
//
function TN_DIBObj.CalcMaxGrayVal(): Integer;
var
  ix, iy, PixGrayVal: Integer;
begin
  Result := -1;

  for ix := 0 to DIBSize.X-1 do
    for iy := 0 to DIBSize.Y-1 do
    begin
      PixGrayVal := GetPixGrayValue( Point( ix, iy ) );
      if PixGrayVal > Result then
        Result := PixGrayVal;
    end;

end; // function TN_DIBObj.CalcMaxGrayVal(): Integer;

//****************************************** TN_DIBObj.CalcMinNeededNumBits ***
// Calc min Needed NumBits (all pixels Gray values should be less than 2**Result)
//
function TN_DIBObj.CalcMinNeededNumBits(): Integer;
begin
  Result := Ceil( log2( CalcMaxGrayVal()+1 ) );
end; // function TN_DIBObj.function TN_DIBObj.CalcMinNeededNumBits(): Integer;


//************************** Global Procedures ***************************

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_PrepDIBObj
//************************************************************ N_PrepDIBObj ***
// Prepare AResDIBObj with given size and type
//
//     Parameters
// AResDIBObj - given any DIBObj or nil
// AWidth     - given needed Wdth
// AHeight    - given needed Height
// APixFmt    - given needed pixel format
// AExPixFmt  - given needed Extended (own) pixel format
// ANumBits   - given needed DIBNumBits value (needed only for epfGray16 and
//              epfColor48 formats)
//
// If AResDIBObj=nil AResDIBObj will be created If AResDIBObj<>nil but has not
// proper size of type it will be freed and recreated If AResDIBObj<>nil and has
// proper size and type it will not be changed
//
procedure N_PrepDIBObj( var AResDIBObj: TN_DIBObj; AWidth, AHeight: integer; APixFmt: TPixelFormat;
                        AExPixFmt: TN_ExPixFmt; ANumBits: integer = 0 );
begin
  if AResDIBObj = nil then // Create new DIBObj with needed params
  begin
    AResDIBObj := TN_DIBObj.Create( AWidth, AHeight, APixFmt, -1, AExPixFmt, ANumBits );
  end else // AResDIBObj <> nil
  begin

    if (AResDIBObj.DIBSize.X <> AWidth)  or (AResDIBObj.DIBSize.Y <> AHeight) or
       (AResDIBObj.DIBPixFmt <> APixFmt) or (AResDIBObj.DIBExPixFmt <> AExPixFmt) then
    begin // AResDIBObj should be free and recreated, otherwise AResDIBObj is OK
      AResDIBObj.Free;
      AResDIBObj := TN_DIBObj.Create( AWidth, AHeight, APixFmt, -1, AExPixFmt, ANumBits );
    end;

  end; // else // AResDIBObj <> nil
end; // procedure N_PrepDIBObj

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_DrawMonoRaster
//******************************************************** N_DrawMonoRaster ***
// copy bits of Monocrome Src Rect to pixels of DstBMP, changing Bits =1 by 
// given Color and Bits =0 remains the same (i.e. zero bits are tranparent) ONLY
// 16BIT OR 32BIT DstBMP ARE SUPPORTED! DstBMP      - Destination 16bit or 32bit
// color BitMap, DstULCorner - Upper Left Corner of Destination Rect, SrcPtr    
// - Pointer to Source UpperLeft pixel (if SrcBMP=nil) or nil SrcLineSize - 
// Source line Size IN BYTES (if SrcBMP=nil) or 0 SrcBMP      - Source 
// momochrome BitMap or nil if SrcPtr, SrcLineSize are given SrcRect     - 
// Source Rect, Color       - drawing Color (Dst Pixels Color where Src Pixels =
// 1)
//
procedure N_DrawMonoRaster( DstBMP: TBitMap; DstULCorner: TPoint;
                            SrcPtr: pointer; SrcLineSize: integer;
                            SrcBmp: TBitmap; SrcRect: TRect; Color: integer );
var
  i, j, k, kBeg, kEnd, Dx, Dy, SrcX1, SrcY1, SrcX2, SrcY2: integer;
  DstXByteOffset, SrcX1Full, SrcX2Full, SrcX1Part, SrcX2Part: integer;
  PDst, PSrc: TN_BytesPtr;
  SrcByte: Byte;
  FirstPartialByte, LastPartialByte: boolean;
  Label L16bit, L32bit;
begin
  if Color = -1 then Exit;
  Color := (Color and $00FF00)          or
           ((Color and $0000FF) shl 16) or
           ((Color and $FF0000) shr 16);   // conv RGB -> BGR

  //***** Clip Src(x1, y1, x2, y2) by Src and Dst BitMap sizes

//  Dec(SrcRect.Right);   // bottom side and right side are not
//  Dec(SrcRect.Bottom);  // considered (as in Windows API)

  Dx := DstULCorner.X - SrcRect.Left; // Dst = Src + Delta

  SrcX1 := SrcRect.Left;
  if SrcX1 < 0 then SrcX1 := 0;
  if (SrcX1+Dx) < 0 then Inc( SrcX1, -Dx );

  SrcX2 := SrcRect.Right;
//  if  SrcX2     >= SrcWidth then SrcX2 := SrcWidth - 1;
  if (SrcX2+Dx) >= DstBmp.Width then SrcX2 := DstBmp.Width - Dx - 1;

  //***** Now all x in (SrcX1<=x<=SrcX2) are inside SrcBMP and
  //          all x+Dx are inside DstBMP

  Dy := DstULCorner.Y - SrcRect.Top; // Dst = Src + Delta

  SrcY1 := SrcRect.Top;
  if SrcY1 < 0 then SrcY1 := 0;
  if (SrcY1+Dy) < 0 then Inc( SrcY1, -Dy );

  SrcY2 := SrcRect.Bottom;
//  if  SrcY2     >= SrcHeight then SrcY2 := SrcHeight - 1;
  if (SrcY2+Dy) >= DstBmp.Height then SrcY2 := DstBmp.Height - Dy - 1;

  //***** Now all y in (SrcY1<=y<=SrcY2) are inside SrcBMP and
  //          all y+Dy are inside DstBMP

  if (SrcX1 > SrcX2) or (SrcY1 > SrcY2) then Exit; // nothing to do

  SrcX1Full := SrcX1 shr 3; // first full    Src byte
  SrcX1Part := SrcX1 shr 3; // first partial Src byte
  SrcX2Full := SrcX2 shr 3; // last  full    Src byte
  SrcX2Part := SrcX2 shr 3; // last  partial Src byte

  kBeg := 0; // to avoid warning
  kEnd := 7; // to process only one byte

  FirstPartialByte := False;
  if (SrcX1 and $7) <> 0 then // first Src byte in partial (not full)
  begin
    FirstPartialByte := True;
    Inc(SrcX1Full);       // first full Src byte
    kBeg := SrcX1 and $7; // first bit in first byte (counting from zero)
  end;

  LastPartialByte := False;
  if (SrcX2 and $7) <> $7 then // last Src byte in partial (not full)
  begin
    LastPartialByte := True;
    kEnd := SrcX2 and $7; // first bit in last byte (counting from zero)
    Dec(SrcX2Full);       // last full Src byte
  end;

  case DstBMP.PixelFormat of // other pixel formats are not supported
  pf16bit: goto L16bit;
  pf32bit: goto L32bit;
  else Exit; // a precaution
  end;

L16bit: //***** High Color Dst BitMap

  Color := N_32To16BitColor( Color ); // conv to 16 bit High Color
  DstXByteOffset := (SrcX1 + Dx) shl 1; // first Dst pixel offset in bytes

  for i := SrcY1 to SrcY2 do // loop along pixel rows
  begin
    // PDst is pointer to first Dst pixel
    PDst := TN_BytesPtr(DstBMP.ScanLine[i+Dy]) + DstXByteOffset;
    if SrcBmp <> nil then
      PSrc := TN_BytesPtr(SrcBmp.ScanLine[i])
    else
      PSrc := TN_BytesPtr(SrcPtr) + i*SrcLineSize;

    if FirstPartialByte then  // process first partial byte
    begin
      SrcByte := TN_PByte(PSrc + SrcX1Part)^;

      if SrcX1Part = SrcX2Part then // first and last partial bytes are the same
      begin
        for k := kBeg to kEnd do
        begin
          if (SrcByte and ($80 shr k)) <> 0 then PInteger(PDst)^ := Short(Color);
          Inc( PDst, 2 ); // to next Dst pixel
        end;
        Continue; // to next Pixel row
      end else // first partial byte is not the only one byte
      begin
        for k := kBeg to 7 do
        begin
          if (SrcByte and ($80 shr k)) <> 0 then PInteger(PDst)^ := Short(Color);
          Inc( PDst, 2 ); // to next Dst pixel
        end;
      end;
    end; // if FirstPartialByte then  // process first partial byte

    for j := SrcX1Full to SrcX2Full do // loop along full Src bytes in one row
    begin                     // SrcX1Full may be > SrcX2Full if no full bytes
      SrcByte := TN_PByte(PSrc + j)^;
      if (SrcByte and $80) <> 0 then PInteger(PDst)^    := Short(Color);
      if (SrcByte and $40) <> 0 then PInteger(PDst+2)^  := Short(Color);
      if (SrcByte and $20) <> 0 then PInteger(PDst+4)^  := Short(Color);
      if (SrcByte and $10) <> 0 then PInteger(PDst+6)^  := Short(Color);
      if (SrcByte and $08) <> 0 then PInteger(PDst+8)^  := Short(Color);
      if (SrcByte and $04) <> 0 then PInteger(PDst+10)^ := Short(Color);
      if (SrcByte and $02) <> 0 then PInteger(PDst+12)^ := Short(Color);
      if (SrcByte and $01) <> 0 then PInteger(PDst+14)^ := Short(Color);
      Inc( PDst, 16 );
    end; // for j := SrcX1Full to SrcX2Full do

    if LastPartialByte then  // process last partial byte
    begin
      SrcByte := TN_PByte(PSrc + SrcX2Part)^;
      for k := 0 to kEnd do
      begin
        if (SrcByte and ($80 shr k)) <> 0 then PInteger(PDst)^ := Short(Color);
        Inc( PDst, 2 ); // to next Dst pixel
      end;
    end; // if LastPartialByte then  // process last partial byte

  end; // for i := SrcY1 to SrcY2 do // loop along pixel rows
  Exit; // all done for High Color Dst BitMap

L32bit:

  DstXByteOffset := (SrcX1 + Dx) shl 2; // first Dst pixel offset in bytes

  for i := SrcY1 to SrcY2 do // loop along pixel rows
  begin
    // PDst is pointer to first Dst pixel
    PDst := TN_BytesPtr(DstBMP.ScanLine[i+Dy]) + DstXByteOffset;
    if SrcBmp <> nil then
      PSrc := TN_BytesPtr(SrcBmp.ScanLine[i])
    else
      PSrc := TN_BytesPtr(SrcPtr) + i*SrcLineSize;

    if FirstPartialByte then  // process first partial byte
    begin
      SrcByte := TN_PByte(PSrc + SrcX1Part)^;

      if SrcX1Part = SrcX2Part then // first and last partial bytes are the same
      begin
        for k := kBeg to kEnd do
        begin
          if (SrcByte and ($80 shr k)) <> 0 then PInteger(PDst)^ := Color;
          Inc( PDst, 4 ); // to next Dst pixel
        end;
        Continue; // to next Pixel row
      end else // first partial byte is not the only one byte
      begin
        for k := kBeg to 7 do
        begin
          if (SrcByte and ($80 shr k)) <> 0 then PInteger(PDst)^ := Color;
          Inc( PDst, 4 ); // to next Dst pixel
        end;
      end;
    end; // if FirstPartialByte then  // process first partial byte

    for j := SrcX1Full to SrcX2Full do // loop along full Src bytes in one row
    begin                     // SrcX1Full may be > SrcX2Full if no full bytes
      SrcByte := TN_PByte(PSrc + j)^;
      if (SrcByte and $80) <> 0 then PInteger(PDst)^    := Color;
      if (SrcByte and $40) <> 0 then PInteger(PDst+4)^  := Color;
      if (SrcByte and $20) <> 0 then PInteger(PDst+8)^  := Color;
      if (SrcByte and $10) <> 0 then PInteger(PDst+12)^ := Color;
      if (SrcByte and $08) <> 0 then PInteger(PDst+16)^ := Color;
      if (SrcByte and $04) <> 0 then PInteger(PDst+20)^ := Color;
      if (SrcByte and $02) <> 0 then PInteger(PDst+24)^ := Color;
      if (SrcByte and $01) <> 0 then PInteger(PDst+28)^ := Color;
      Inc( PDst, 32 );
    end; // for j := SrcX1Full to SrcX2Full do

    if LastPartialByte then  // process last partial byte
    begin
      SrcByte := TN_PByte(PSrc + SrcX2Part)^;
      for k := 0 to kEnd do
      begin
        if (SrcByte and ($80 shr k)) <> 0 then PInteger(PDst)^ := Color;
        Inc( PDst, 4 ); // to next Dst pixel
      end;
    end; // if LastPartialByte then  // process last partial byte

  end; // for i := SrcY1 to SrcY2 do // loop along pixel rows
  Exit; // all done for High Color Dst BitMap

end; //*** end of procedure N_DrawMonoRaster

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_DrawFilledRect
//******************************************************** N_DrawFilledRect ***
// Fill given rectangle by given color
//
//     Parameters
// AHDC   - handle to graphic device context
// ARect  - given rectangle
// AColor - given fill color
//
// Fill including lower right rectangle's edge but without borders.
//
procedure N_DrawFilledRect( AHDC: HDC; ARect: TRect; AColor: integer );
var
  Brush, OldBrush: HBrush;
begin
  if AColor = N_EmptyColor then Exit;

  Brush := CreateSolidBrush( AColor );
  OldBrush := SelectObject( AHDC, Brush );

  Windows.FillRect( AHDC,
      Rect(ARect.Left, ARect.Top, ARect.Right+1, ARect.Bottom+1), Brush );

  SelectObject( AHDC, OldBrush );
  DeleteObject( Brush );
end; //*** end of procedure N_DrawFilledRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CopyRect
//************************************************************** N_CopyRect ***
// Copy one rectangle from source graphic device context to destination by 
// Windows.BitBlt function
//
//     Parameters
// AHDst         - handle to destination graphic device context
// ADstUpperLeft - destination rectangle upper left corner
// AHSrc         - handle to source graphic device context
// ASrcRect      - source rectangle
// AROp          - copy operation (OR, XOR, AND etc.)
//
// Copy one rectangle including lower right egdes!
//
procedure N_CopyRect( AHDst: HDC; ADstUpperLeft: TPoint; AHSrc: HDC; ASrcRect: TRect;
                                                        AROp: DWORD = SRCCOPY );
begin
  N_b := Windows.BitBlt( AHDst, ADstUpperLeft.X, ADstUpperLeft.Y,
          ASrcRect.Right-ASrcRect.Left+1, ASrcRect.Bottom-ASrcRect.Top+1,
          AHSrc, ASrcRect.Left, ASrcRect.Top, AROp );
          
  if N_b then // some error
  begin
//    Assert( N_b, 'BitBlt failed!' ); // may be it can be not a fatal error ???
//    N_Dump1Str( 'BitBlt failed! ' + SysErrorMessage( GetLastError() ) ); // it occured to many times!
  end;
end; //*** end of procedure N_CopyRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CopyRectByMask
//******************************************************** N_CopyRectByMask ***
// Copy one rectangle from source graphic device context to destination by 
// Windows.MaskBlt function
//
//     Parameters
// AHDst         - handle to destination graphic device context
// ADstUpperLeft - destination rectangle upper left corner
// AHSrc         - handle to source graphic device context
// ASrcRect      - source rectangle
// AHMask        - pf1bit Bitmap Handle
// AROP4         - Two Raster Operations (created by MakeROP4 macros)
//
// Copy one rectangle including lower right egdes!
//
procedure N_CopyRectByMask( AHDst: HDC; ADstUpperLeft: TPoint; AHSrc: HDC; ASrcRect: TRect;
                            AHMask: HBitMap; AROP4: DWORD );
begin
  N_b := Windows.MaskBlt( AHDst, ADstUpperLeft.X, ADstUpperLeft.Y,
               ASrcRect.Right-ASrcRect.Left+1, ASrcRect.Bottom-ASrcRect.Top+1,
               AHSrc, ASrcRect.Left, ASrcRect.Top, AHMask, 0, 0, AROP4 );

  Assert( N_b, 'MaskBlt failed!' );
end; //*** end of procedure N_CopyRectByMask

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CopyRects
//************************************************************* N_CopyRects ***
// Copy array of rectangles from source graphic device context to destination 
// with same coordinates shift
//
//     Parameters
// AHDst     - handle to destination graphic device context
// AHSrc     - handle to source graphic device context
// ASrcRects - array of source rectangles to copy from
// ANumRects - number of actual elements in ASrcRects
// AShiftX   - X shift of each source rectangle left side
// AShiftY   - Y shift of each source rectangle top side
//
procedure N_CopyRects( AHDst: HDC; AHSrc: HDC; ASrcRects: TN_IRArray;
                                      ANumRects, AShiftX, AShiftY: integer );
var
  i: integer;
begin
  for i := 0 to ANumRects-1 do
    N_CopyRect( AHDst, Point( ASrcRects[i].Left+AShiftX, ASrcRects[i].Top+AShiftY),
                                                         AHSrc, ASrcRects[i] );
end; //*** end of procedure N_CopyRects

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_StretchRect
//*********************************************************** N_StretchRect ***
// Copy one rectangle from source graphic device context to destination with 
// needed stretching
//
//     Parameters
// AHDst    - handle to destination graphic device context
// ADstRect - destination rectangle
// AHSrc    - handle to source graphic device context
// ASrcRect - source rectangle
// AROp     - copy operation (OR, XOR, AND etc.)
//
// Copy streched rectangle including lower right egdes! WinGDI function is used 
// if destination and source rectangles have different size (proper Delphi 
// function is absent).
//
procedure N_StretchRect( AHDst: HDC; ADstRect: TRect; AHSrc: HDC; ASrcRect: TRect;
                                                        AROp: DWORD = SRCCOPY );
begin
  if ( (ADstRect.Right-ADstRect.Left) = (ASrcRect.Right-ASrcRect.Left) ) and
     ( (ADstRect.Bottom-ADstRect.Top) = (ASrcRect.Bottom-ASrcRect.Top) ) then
    N_CopyRect( AHDst, ADstRect.TopLeft, AHSrc, ASrcRect, AROp )
  else
    N_b1 := StretchBlt( AHDst, ADstRect.Left, ADstRect.Top,
                ADstRect.Right  - ADstRect.Left + 1,
                ADstRect.Bottom - ADstRect.Top  + 1,
                AHSrc, ASrcRect.Left, ASrcRect.Top,
                ASrcRect.Right  - ASrcRect.Left + 1,
                ASrcRect.Bottom - ASrcRect.Top  + 1, AROp );
  N_d := N_i;              
end; //*** end of procedure N_StretchRect

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_DrawRectBorder
//******************************************************** N_DrawRectBorder ***
// Draw given rectangle border by given сolor and width
//
//     Parameters
// AHDC        - handle to graphic device context
// ARectBorder - given rectangle
// AColor      - border color
// AWidth      - border width in pixels
//
// ARectBorder is outer border, whole border width is inside it.
//
procedure N_DrawRectBorder( AHDC: HDC; const ARectBorder: TRect;
                                                      AColor, AWidth: integer );
var
  TmpRect: TRect;
begin
  with ARectBorder do
  begin
  TmpRect := Rect( Left, Top, Right, Top+AWidth-1 );
  N_DrawFilledRect( AHDC, TmpRect, AColor );
  TmpRect := Rect( Right-AWidth+1, Top, Right, Bottom );
  N_DrawFilledRect( AHDC, TmpRect, AColor );
  TmpRect := Rect( Left, Bottom-AWidth+1, Right, Bottom );
  N_DrawFilledRect( AHDC, TmpRect, AColor );
  TmpRect := Rect( Left, Top, Left+AWidth-1, Bottom );
  N_DrawFilledRect( AHDC, TmpRect, AColor );
  end; // with RectBorder do
end; //*** end of procedure N_DrawRectBorder

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_DrawDashRect
//********************************************************** N_DrawDashRect ***
// Draw dashed rectangle (mainly for animated rectangle outline)
//
//     Parameters
// ADrawDashPars - draw dashed rectangle parameters including rectangle 
//                 coordinates and handle to graphic device context
//
procedure N_DrawDashRect( const ADrawDashPars: TN_DrawDashRectPar );
var
  OutColor, InColor: integer;
begin
  with ADrawDashPars do
  begin
                               //***** temporary implementation
  if (Phase and $01) = 0 then
  begin
    OutColor := Color1;
    InColor  := Color2;
  end else
  begin
    OutColor := Color2;
    InColor  := Color1;
  end;

  N_DrawRectBorder( DstCanvas.Handle, OutRect, OutColor, 1 );
  DstCanvas.Refresh;
  N_DrawRectBorder( DstCanvas.Handle, InRect,  InColor,  1 );
  DstCanvas.Refresh;

  end; // with Params do
end; //*** end of procedure N_DrawDashRect

//************************************************** N_RGBColorsToColorInds ***
// should be redesigned: save indexes in Byte array and copy them
// to created 8bit BMP with needed palette
//
// Convert given Rect of HighColor or TrueColor Src BitMap to same size Rect
// in 256Color Dst BitMap, using given Palette (NumColors, RGBColors)
//
// ColorInd - Color index for RGB colors, absent in given palette
//            if ColorInd = -1 then add absent color to Palette
//                                  and increase NumColors (up to 256)
//
// Length(RGBColors) should be >= 256,
// DstRect and SrcRect dimensions should be the same,
// if RGB colors from Src Rect is absent in RGBColors, this Color will be
//      added RGBColors and NumColors will be increased
//
procedure N_RGBColorsToColorInds( DstBitMap: TBitMap; DstRect: TRect;
                                  SrcBitMap: TBitMap; SrcRect: TRect;
                                  ColorInd: integer; var NumColors: integer;
                                                      RGBColors: TN_IArray );
var
  i, ix, iy, dx, dy, CurColor: integer;
  WrkColors: TN_IArray;
  PSrcScanLine, PDstScanLine: TN_BytesPtr;
//  PSrcPChar, PDstPChar: PChar;
  label Found16, Found32;
begin
  dx := DstRect.Left - SrcRect.Left;
  dy := DstRect.Top  - SrcRect.Top;
  SetLength( WrkColors, 256 );

  if SrcBitMap.PixelFormat = pf32bit then // TrueColor SrcBitMap
  begin
    for i := 0 to NumColors-1 do
    begin
      WrkColors[i] := N_32ToR32BitColor( RGBColors[i] ) or (i shl 24);
    end;

    for iy := SrcRect.Top  to SrcRect.Bottom do
    begin
    PSrcScanLine := TN_BytesPtr(SrcBitMap.ScanLine[iy]);
    PDstScanLine := TN_BytesPtr(DstBitMap.ScanLine[iy+dy]);
    for ix := SrcRect.Left to SrcRect.Right do
    begin
  //    CurColor := $0000FF; // debug
  //    CurColor := SrcBitMap.Canvas.Pixels[ix,iy]; // too slow!!
      CurColor := TN_PUInt4(PSrcScanLine + (ix shl 2))^;

      //***** later reorder WrkColors to speed up searching

      for i := 0 to NumColors-1 do
      begin
        if CurColor = (WrkColors[i] and $FFFFFF) then goto Found32;
      end; // for i := 0 to NumColors-1 do

      //*** Here: RGBColor not found, add it to Palette
      Assert( NumColors < 255, 'Too many colors!' );
      i := NumColors;
      Inc(NumColors);
      WrkColors[i] := CurColor or (i shl 24);
      RGBColors[i] := N_32ToR32BitColor( CurColor );

      Found32: //*** Here: i is needed Color Index
  //  DstBitMap.Canvas.Pixels[ix+dx, iy+dy] := $01000000 + i; // too slow!!
  //  TN_PUInt1(TN_BytesPtr(DstBitMap.ScanLine[iy+dy])+ix+dx)^ := i; // also slow!
      TN_PUInt1(PDstScanLine+ix+dx)^ := i;
    end; // for ix
    end; // for iy

  end else //******************** High Color SrcBitMap
  begin
    Assert( SrcBitMap.PixelFormat = pf16bit, 'Only 32 or 16 bit BMP is allowed!' );
    for i := 0 to NumColors-1 do
    begin
      WrkColors[i] := N_32ToR16BitColor( RGBColors[i] ) or (i shl 24);
    end;

    for iy := SrcRect.Top  to SrcRect.Bottom do
    for ix := SrcRect.Left to SrcRect.Right do
    begin
  //    CurColor := $0000FF; // debug
  //    CurColor := SrcBitMap.Canvas.Pixels[ix,iy]; // too slow!!
      CurColor := TN_PUInt2(TN_BytesPtr(SrcBitMap.ScanLine[iy+dy])+((ix+dx) shl 1))^;

      //***** later reorder WrkColors to speed up searching

      for i := 0 to NumColors-1 do
      begin
        if CurColor = (WrkColors[i] and $FFFF) then goto Found16;
      end; // for i := 0 to NumColors-1 do

      //*** Here: RGBColor not found, add it to Palette
      Assert( NumColors < 255, 'Too many colors!' );
      i := NumColors;
      Inc(NumColors);
      WrkColors[i] := CurColor or (i shl 24);
      RGBColors[i] := N_16ToR32BitColor( CurColor );

      Found16: //*** Here: i is needed Color Index
  //  DstBitMap.Canvas.Pixels[ix+dx, iy+dy] := $01000000 + i; // too slow!!
      TN_PUInt1(TN_BytesPtr(DstBitMap.ScanLine[iy+dy])+ix+dx)^ := i;
    end; // for ix, for iy

  end; // else //******************** HighColor SrcBitMap

  WrkColors := nil;
end; //*** end of procedure N_RGBColorsToColorInds

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_DrawMesh
//************************************************************** N_DrawMesh ***
// Draw black and white Mesh in dot style inside given rectangle
//
//     Parameters
// ACanvas - abstract drawing space (TCanvas) where to draw
// ARect   - rectangle in pixel coords where mesh to draw
// AX0     - left mesh start crosspoint pixel coordinate
// AY0     - top mesh start crosspoint pixel coordinate
// AStepX  - X step in pixels between mesh lines
// AStepY  - Y step in pixels between mesh lines
//
// Routine is implemented not as OCanv method to be able to draw in 
// TPaintBox.Canvas
//
procedure N_DrawMesh( ACanvas: TCanvas; const ARect: TRect;
                                           AX0, AY0, AStepX, AStepY: integer );
var
  i, n, x, y: integer;
begin
  ACanvas.Pen.Color := $FFFFFF;
  ACanvas.Pen.Style := psDot;
  SetBkMode( ACanvas.Handle, OPAQUE );
  SetBkColor( ACanvas.Handle, $000000 );

  n := Round( Floor( (ARect.Right-ARect.Left+1) / AStepX ) );
  for i := 0 to n-1 do
  begin
    x := AX0 + i*AStepX;
    ACanvas.MoveTo( x, ARect.Top );
    ACanvas.LineTo( x, ARect.Bottom );
  end;

  n := Round( (ARect.Bottom-ARect.Top+1) / AStepY );
  for i := 0 to n-1 do
  begin
    y := AY0 + i*AStepY;
    ACanvas.MoveTo( ARect.Left, y );
    ACanvas.LineTo( ARect.Right, y );
  end;

end; //*** end of procedure N_DrawMesh

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CopyMetafileToClipBoard
//*********************************************** N_CopyMetafileToClipBoard ***
// Save copy of given Metafile to Windows Clipboard
//
//     Parameters
// AMF - Metafile object
//
procedure N_CopyMetafileToClipBoard( AMF: TMetafile );
var
  AFormat: Word;
  AData: THandle;
  APalette: HPALETTE;
begin
//??  TPicture.RegisterClipboardFormat( CF_ENHMETAFILE, TMetafile ); // not needed?
  // AFormat is CF_ENHMETAFILE, APalette = 0,
  // Adata is Windows handle of a COPY of given AMF, so AMF can be deleted
  AMF.SaveToClipboardFormat( AFormat, AData, APalette );
  ClipBoard.SetAsHandle( AFormat, AData );
end; //*** end of procedure N_CopyMetafileToClipBoard

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_LoadMetafileFromClipBoard
//********************************************* N_LoadMetafileFromClipBoard ***
// Set given Metafile by data in Windows Clipborad
//
//     Parameters
// AMF - Metafile object
//
procedure N_LoadMetafileFromClipBoard( var AMF: TMetafile );
var
  AFormat: Word;
  AData: THandle;
  APalette: HPALETTE;
begin
//  AFormat  := CF_METAFILEPICT; // = 3
  AFormat  := CF_ENHMETAFILE; // = 14
  AData    := 0; // to avoid warning
  APalette := 0; // to avoid warning
  if AMF = nil then AMF := TMetafile.Create();
// Error occured - "Format is not supported" ??????
  AMF.LoadFromClipboardFormat( AFormat, AData, APalette );
end; //*** end of procedure N_LoadMetafileFromClipBoard

{ not needed?
//*************************************** N_GetWinLogFont ***
// fill WinLogFont struct fields by current font selected in given HDC
//
procedure N_GetWinLogFont( HDC: integer; var WinLogFont: TLogFont );
var
  TextMetric: TTextMetric;
begin
  GetTextFace( HDC, 32, WinLogFont.lfFaceName );
  GetTextMetrics( HDC, TextMetric );
  with WinLogFont, TextMetric do
  begin
    lfHeight := tmHeight;
    lfWeight := tmWeight;
    lfItalic := tmItalic;
    lfUnderline := tmUnderlined;
  end;
end; //*** end of procedure N_GetWinLogFont
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_PrepDIBLineSizes
//****************************************************** N_PrepDIBLineSizes ***
// Calculate actual number of bytes and size in bytes for DIB line by given DIB 
// pixel format and width
//
//     Parameters
// AWidth       - DIB width in pixels
// APixFmt      - DIB pixel format or pfCustom for not Windows formats 
//                (epfGray8, epfGray16, epfColor48)
// AExPixFmt    - DIB extended pixel format
// ABytesInLine - resulting number of data bytes in DIB line
// ALineSize    - resulting DIB line size in bytes (>= ABytesInLine)
//
procedure N_PrepDIBLineSizes( AWidth: integer; APixFmt: TPixelFormat;
                              AExPixFmt: TN_ExPixFmt; out ABytesInLine, ALineSize: integer );
begin
  case APixFmt of
    pf1bit:   ABytesInLine := (AWidth-1) div 8 + 1;
    pf8bit:   ABytesInLine := AWidth;
    pf16bit:  ABytesInLine := AWidth * 2;
    pf24bit:  ABytesInLine := AWidth * 3;
    pf32bit:  ABytesInLine := AWidth * 4;

    pfcustom: case AExPixFmt of
                epfGray8:   ABytesInLine := AWidth;
                epfGray16:  ABytesInLine := AWidth*2;
                epfColor48: ABytesInLine := AWidth*6;
              else
                Assert( False, 'Bad AExPixFmt3' );
              end; // case AExPixFmt of
  else
    Assert( False, 'Bad APixFmt4!' );
  end; // case RPixFmt of

  ALineSize := ((ABytesInLine+3) shr 2) shl 2; // DIB Lines should be DWord aligned
end; // procedure N_PrepDIBLineSizes

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CreateDIBSection
//****************************************************** N_CreateDIBSection ***
// Delete given DIB Section and create new one
//
//     Parameters
// AHDS         - DIB Section handle
// AWidth       - DIB Section width
// AHeight      - DIB Section height
// APixelFormat - DIB Section pixel format
// APixPtr      - resulting pointer to created DIB pixels
//
procedure N_CreateDIBSection( var AHDS: HBitMap; AWidth, AHeight: integer;
                              APixelFormat: TPixelFormat; var APixPtr: Pointer );
var
  HScreenDC: LongWord;
  DIBInfo: TN_DIBInfo;
  ErrStr: string;
begin
  if AHDS <> 0 then // delete current DIB Section
  begin
   N_b := DeleteObject( AHDS );
   Assert( N_b, 'Bad AHDS' );
  end; // if AHDS <> 0 then // delete current DIB Section

  FillChar( DIBInfo, Sizeof(DIBInfo), 0 );
  with DIBInfo, DIBInfo.bmi do
  begin
    biSize := Sizeof(DIBInfo.bmi);
    biWidth  := AWidth;
    biHeight := AHeight;
    biPlanes := 1;
    biXPelsPerMeter := 3800;
    biYPelsPerMeter := 3800;

    case APixelFormat of
    pf1bit:  begin biBitCount := 1;   biCompression := BI_RGB; end;
    pf16bit: begin biBitCount := 16;  biCompression := BI_BITFIELDS;
               RedMask := $F800; GreenMask := $07E0; BlueMask := $001F; end;
    pf24bit: begin biBitCount := 24;  biCompression := BI_RGB; end;
    pf32bit: begin biBitCount := 32;  biCompression := BI_RGB; end;
//    pf32bit: begin biBitCount := 32;  biCompression := BI_BITFIELDS;
//               RedMask := $FF0000; GreenMask := $FF00; BlueMask := $FF; end;
    else
      Assert( False, 'Bad PixFmt' );
    end; // case PixelFormat of

  end; // with DIBInfo, DIBInfo.bmi do

  HScreenDC := GetDC( 0 );
  Assert( HScreenDC <> 0, 'Bad HScreenDC' );
  AHDS := Windows.CreateDIBSection( HScreenDC, PBitmapInfo(@DIBInfo)^,
                                               DIB_RGB_COLORS, APixPtr, 0, 0 );
  ErrStr := '???';
  if AHDS = 0 then ErrStr := SysErrorMessage( GetLastError() );
  Assert( AHDS <> 0, ErrStr );
  N_i := ReleaseDC( 0, HScreenDC );
  Assert( N_i = 1, '???' );

end; //*** end of procedure N_CreateDIBSection

//*************************************************************** N_DrawBMP ***
// draw given BMP in given HDC
//
// DC         - Windows Device Context
// APRaster   - Pointer to Raster
// ADstRect   - Destination Rect
//              ( Right, Bottom = -1 means SrcSizes * ARScale )
// ASrcRect   - Source Rect, (0,0) - UpperLeft Raster Pixel,
//              Right, Bottom < 0 means RRasterSizes + Right(Bottom)
// ARScale    - Raster Scale ( DstPixSize = ARScale*SrcPixSize)
// ARPlace    - Raster Place in ADstRect ( rpUpperLeft, rpCenter, rpRepeat )
// AMonoColor - Color for drawing =0 bits of monochrome Raster
//              (=1 monochrome Raster bits are always transparent)
//              and for drawing rest Dst pixels if it is not fully covered
//              by Raster
//
procedure N_DrawBMP( DC: HDC; ABMP: TBitmap; ADstRect, ASrcRect: TRect;
                                    ARScale: float; APPlace: TN_PictPlace );
begin
{ // not implemented
var
  DstWidth, DstHeight, ScaledRasterWidth, ScaledRasterHeight: integer;
  FullDstWidth, FullDstHeight, SrcWidth, SrcHeight: integer;
  ROP: DWord;
  PMaskBits, PRasterPix: TN_BytesPtr;
  TmpRect: TRect;
  DIBInfo: TN_DIBInfo;
  PTmpp0: PChar;
begin
  PMaskBits  := nil; // to avoid warning
  PRasterPix := nil; // to avoid warning
  FillChar( DIBInfo, Sizeof(DIBInfo), 0 );
  with APRaster^, DIBInfo, DIBInfo.bmi do
  begin
    if ASrcRect.Right  = -1 then ASrcRect.Right := RWidth - 1;
    if ASrcRect.Bottom = -1 then ASrcRect.Bottom := RHeight - 1;

    SrcWidth  := ASrcRect.Right - ASrcRect.Left + 1;
    SrcHeight := ASrcRect.Bottom - ASrcRect.Top + 1;

    biSize   := Sizeof(DIBInfo.bmi);
    biWidth  := RWidth;
    biHeight := -RHeight;
    biPlanes := 1;

    with ADstRect do
    begin
      if (Right = -1) or (Bottom = -1) then // set Dst size by Src size
      begin
        if ARScale = 0 then ARScale := 1.0; // a precaution
        APPlace := ppUpperLeft;              // a precaution
      end; // if (Right = -1) or (Bottom = -1) then

      ScaledRasterWidth  := Round(SrcWidth*ARScale);
      ScaledRasterHeight := Round(SrcHeight*ARScale);

      if Right  = -1 then Right  := Left + ScaledRasterWidth - 1;
      if Bottom = -1 then Bottom := Top + ScaledRasterHeight - 1;

      FullDstWidth  := Right - Left + 1;
      FullDstHeight := Bottom - Top + 1;

      if ARScale = 0 then // strech mode
      begin
        APPlace   := ppUpperLeft;   // a precaution
        DstWidth  := FullDstWidth;  // temporary value if RScale <> 0
        DstHeight := FullDstHeight; // temporary value if RScale <> 0
      end else // RScale is given
      begin
        DstWidth  := ScaledRasterWidth;
        DstHeight := ScaledRasterHeight;
      end;
    end; // with ADstRect do

    if APPlace = ppRepeat then // fill whole ADstRect by repeating Raster
    begin
      TmpRect.Left  := 0;
      TmpRect.Right := ScaledRasterWidth-1;
      while TmpRect.Left <= ADstRect.Right do // Horizontal loop
      begin
        TmpRect.Top := 0;
        TmpRect.Bottom := ScaledRasterHeight-1;
        while TmpRect.Top <= ADstRect.Bottom do  // Vertical loop
        begin
          N_DrawRaster( DC, APRaster, TmpRect, ASrcRect, ARScale, ppUpperLeft, AMonoColor );
          TmpRect := N_RectShift( TmpRect, 0, ScaledRasterHeight );
        end; // while TmpRect.Top <= DstRect.Bottom do

        TmpRect := N_RectShift( TmpRect, ScaledRasterWidth, 0 );
      end; // while TmpRect.Left <= DstRect.Right do
      N_RasterChangedRect := ADstRect;

      Exit; // all done
    end; // if Mode = rmRepeat then // fill whole DstRect by repeating Raster

    if APPlace = ppCenter then // place raster in the middle of ADstRect
    begin
      if ScaledRasterWidth < FullDstWidth then
        Inc( ADstRect.Left, (FullDstWidth-ScaledRasterWidth) div 2 );

      if ScaledRasterHeight < FullDstHeight then
        Inc( ADstRect.Top, (FullDstHeight-ScaledRasterHeight) div 2 );
    end; // if Mode = rmCenter then // place raster in the middle of DstRect

    with N_RasterChangedRect do
    begin
      TopLeft := ADstRect.TopLeft;
      Right   := Left + DstWidth - 1;
      Bottom  := Top + DstHeight - 1;
    end;

    ROP := SRCCOPY;

    if RPixFmt = pf1bit then // draw monochrome Raster
    begin
      biBitCount :=  1;
      biCompression := BI_RGB;
      PalEntry0 := $000000; // nontransparent pixels
      PalEntry1 := $FFFFFF; // transparent pixels

      if RType = rtRArray then
        PMaskBits := TN_BytesPtr(TK_RArray(RMaskRA).P)
      else if RType = rtBArray then
        PMaskBits := TN_BytesPtr(@RMaskBA[0])
      else
        Assert( False, 'Bad RType' );

      StretchDIBits( DC, ADstRect.Left, ADstRect.Top, DstWidth, DstHeight,
                    ASrcRect.Left, ASrcRect.Top, SrcWidth, SrcHeight,
                    PMaskBits, PBitmapInfo(@DIBInfo)^, DIB_RGB_COLORS, SRCAND );

      PalEntry0 := AMonoColor; // nontransparent pixels Color
      PalEntry1 := $000000;    // transparent pixels (for XOR operation)

      StretchDIBits( DC, ADstRect.Left, ADstRect.Top, DstWidth, DstHeight,
                 ASrcRect.Left, ASrcRect.Top, SrcWidth, SrcHeight,
                 PMaskBits, PBitmapInfo(@DIBInfo)^, DIB_RGB_COLORS, SRCINVERT );
      Exit;
    end; // if RPixFmt = pf1bit then // draw monochrome Raster

    if (RMaskRA <> nil) or (RMaskBA <> nil) then //***** raster with mask
    begin
      biBitCount := 1;
      biCompression := BI_RGB;
      PalEntry0 := $000000; // nontransparent pixels
      PalEntry1 := $FFFFFF; // transparent pixels

      if RType = rtRArray then
        PMaskBits := TN_BytesPtr(TK_RArray(RMaskRA).P)
      else if RType = rtBArray then
        PMaskBits := TN_BytesPtr(@RMaskBA[0]);

      // clear nontransparent pixels in destination
      StretchDIBits( DC, ADstRect.Left, ADstRect.Top, DstWidth, DstHeight,
                    ASrcRect.Left, ASrcRect.Top, SrcWidth, SrcHeight,
                    PMaskBits, PBitmapInfo(@DIBInfo)^, DIB_RGB_COLORS, SRCAND );
      ROP := SRCINVERT;
    end; // if RMaskBits <> nil then // raster with mask, clear nontransparent pixels

    case RPixFmt of
    pf16bit: begin biBitCount := 16;  biCompression := BI_BITFIELDS;
               RedMask := $F800; GreenMask := $07E0; BlueMask := $001F; end;
    pf24bit: begin biBitCount := 24;  biCompression := BI_RGB; end;
//               RedMask := $FF0000; GreenMask := $FF00; BlueMask := $FF; end;
    pf32bit: begin biBitCount := 32;  biCompression := BI_BITFIELDS;
               RedMask := $FF0000; GreenMask := $FF00; BlueMask := $FF; end;
    else
      Assert( False, 'not supported' );
    end; // case PixelFormat of

    if RType = rtRArray then
      PRasterPix := TN_BytesPtr(TK_RArray(RasterRA).P)
    else if RType = rtBArray then
      PRasterPix := TN_BytesPtr(@RasterBA[0])
    else
      Assert( False, 'Bad RType' );

// debug
    N_i := integer(PBits);
    N_i := Integer((PBits+2)^);
    N_s := Format( '%.8X   ', [DC] );
    if TK_RArray(RasterBits).ALength > 350000 then
      N_s := N_S + Format( '%.8X %.8X %.8X %.8X',
                      [PInteger(PBits+200000)^, PInteger(PBits+300000)^,
                       PInteger(PBits+310000)^, PInteger(PBits+320000)^] );
    N_Show1Str( N_s );
    N_StateString.ShowProtocol( nil );

//      PalEntry0 := $000000; // debug
//      PalEntry1 := $000000;
//    N_i := StretchDIBits( DC, 0, 0, 100, 50, 0, 0, 100, 50,
//                     PBits, PBitmapInfo(@DIBInfo)^, DIB_RGB_COLORS, SRCCOPY );


    // XOR (add) to destination nontransparent pixels or COPY all pixels
    N_i := StretchDIBits( DC, ADstRect.Left, ADstRect.Top, DstWidth, DstHeight,
                     ASrcRect.Left, ASrcRect.Top, SrcWidth, SrcHeight,
                     PRasterPix, PBitmapInfo(@DIBInfo)^, DIB_RGB_COLORS, ROP );

    if N_i = 0 then // debug
    begin
      N_s := SysErrorMessage( GetLastError() );
      N_i1 := 1;
    end;
  end;
}
end; //*** end of procedure N_DrawBMP

//************************************************** N_CreateBMPFragment ***
// create and return new TBitmap obj with given fragment of given Bitmap
//
function N_CreateBMPFragment( BMP: TBitmap; BMPRect: TRect ): TBitmap;
begin
  N_IRectAnd( BMPRect, Rect( 0, 0, BMP.Width-1, BMP.Height-1 ) );
  Result := Tbitmap.Create;
  with Result do
  begin
    Width  := N_RectWidth( BMPRect );
    Height := N_RectHeight( BMPRect );
    PixelFormat := BMP.PixelFormat;
    Canvas.Pixels[Width-1, Height-1] := 0; // a precaution
    N_StretchRect( Canvas.Handle, Rect(0, 0, Width-1, Height-1),
                   BMP.Canvas.Handle, BMPRect );
  end;
end; //*** end function N_CreateBMPFragment

//*************************************************** N_TestRectDraw(OCanv) ***
// Fill 30x30 pix Rect with given UpperLeft corner (AX,AY) by given AColor
//
procedure N_TestRectDraw( AOCanv: TN_OCanvas; AX, AY, AColor: integer );
var
  HBr: HBrush;
begin
//  SelectClipRgn( AOCanv.HMDC, 0 ); // Clear Clip Region

  HBr := Windows.CreateSolidBrush( AColor );
  Windows.FillRect( AOCanv.HMDC, Rect( AX, AY, AX+30, AY+30 ), HBr );
  DeleteObject( HBr );
end; //*** procedure N_TestRectDraw(OCanv)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_HDCRectDraw(1)
//******************************************************** N_HDCRectDraw(1) ***
// Fill 30x30 pixel rectangle in given Upper Left point by given color
//
//     Parameters
// AHDC   - handle to graphic device context
// AX     - rectangle left side pixel coordinate
// AY     - rectangle top side pixel coordinate
// AColor - fill color
//
procedure N_HDCRectDraw( AHDC: HDC; AX, AY, AColor: integer );
var
  HBr: HBrush;
begin
//  SelectClipRgn( AOCanv.HMDC, 0 ); // Clear Clip Region

  HBr := Windows.CreateSolidBrush( AColor );
  Windows.FillRect( AHDC, Rect( AX, AY, AX+30, AY+30 ), HBr );
  DeleteObject( HBr );
end; //*** procedure N_TestRectDraw(HDC,P)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_HDCRectDraw(2)
//******************************************************** N_HDCRectDraw(2) ***
// Fill given pixel rectangle by given color
//
//     Parameters
// AHDC   - handle to graphic device context
// ARect  - rectangle in pixel coordinates
// AColor - fill color
//
procedure N_HDCRectDraw( AHDC: HDC; ARect: TRect; AColor: integer );
var
  HBr: HBrush;
begin
//  SelectClipRgn( AOCanv.HMDC, 0 ); // Clear Clip Region
  if (AColor < 0) or (AColor > $FFFFFF) then Exit;

  HBr := Windows.CreateSolidBrush( AColor );
  Windows.FillRect( AHDC, ARect, HBr );
  DeleteObject( HBr );
end; //*** procedure N_TestRectDraw(HDC,R)

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_AddToImageList
//******************************************************** N_AddToImageList ***
// Add new images to given ImageList object
//
//     Parameters
// AImageList    - given TImageList to which new Images should be added
// AFileName     - BMP file Name with images to add
// APTranspColor - pointer to images transparent color (on output), may be nil
// Result        - Returns number of new added images
//
// If lower left pixel color of images is the same, write it by value from given
// APTranspColor, otherwise write -1. APTranspColor = nil means that caller is 
// not interested in images transparent color
//
function N_AddToImageList( AImageList: TImageList; AFileName: string;
                                                   APTranspColor: PInteger ): integer;
var
  ix, iy, x, y, NX, NY, OneWidth, OneHeight, TranspColor, CurColor: integer;
  CurRect: TRect;
  FName: string;
  DIBObj: TN_DIBObj;
  CurBitmap: TBitmap;
begin
  Result := -1;
  FName := K_ExpandFileName( AFileName );
//  if not FileExists( FName ) then Exit;
  if not K_VFileExists( FName ) then Exit;

  OneWidth  := AImageList.Width;
  OneHeight := AImageList.Height;

  DIBObj := TN_DIBObj.Create();

  with DIBObj do
  begin
    LoadFromFile( FName );
    NX := DIBSize.X div OneWidth;
    NY := DIBSize.Y div OneHeight;
    TranspColor := 0;

    for iy := 0 to NY-1 do
    for ix := 0 to NX-1 do
    begin
      x := OneWidth*ix;
      y := OneHeight*iy;
      CurRect := Rect( x, y, x+OneWidth-1, y+OneHeight-1 );
      CurBitmap := DIBObj.CreateBitmap( CurRect );
      CurColor := CurBitmap.Canvas.Pixels[0,OneHeight-1];

      if TranspColor <> -1 then // check if TranspColor is the same
      begin
        if (ix = 0) and (iy = 0) then
          TranspColor := CurColor
        else if TranspColor <> CurColor then
          TranspColor := -1;
      end; // if TranspColor <> -1 then

      Result := -2;
      if -1 = AImageList.AddMasked( CurBitmap, CurColor ) then Exit; // some Error
    end; // for ix, iy
    Free;
  end; // with DIBObj do

  Result := NX * NY;

  if APTranspColor <> nil then // Return TranspColor if needed
    APTranspColor^ := TranspColor;
end; // function procedure N_AddToImageList

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CreateTestDIB8
//******************************************************** N_CreateTestDIB8 ***
// Create DIB object for testing purposes (all formats except epf16, epf48)
//
//     Parameters
// AMode           - =0 - Create resulting DIB by given params =1 - just Fill 
//                   params (variant #1)
// APTestDIBParams - pointer to TN_TestDIBParams record with all needed params
// Result          - Returns resulting DIB object if AMode=0 or nil
//
function N_CreateTestDIB8( AMode: integer; APTestDIBParams: TN_PTestDIBParams ): TN_DIBObj;
begin
  Result := nil;
  if APTestDIBParams = nil then Exit; // a precaution

  with APTestDIBParams^ do
  begin

  case AMode of

  1: begin // fill params, Variant #1
    TDPWidth      := 400;
    TDPHeight     := 300;
    TDPPixFmt     := pf24bit;
    TDPNumCellsX  := 4;
    TDPNumCellsY  := 3;
    TDPFillColor1 := $FFFFFF;
    TDPFillColor2 := $BBBBBB;
    TDPBordSize   :=2;
    TDPBordColor  := 0;
    TDPIndsColor  := 0;
    TDPString       := 'Test string';
    TDPStringColor  := $777777;
    TDPStringHeight := 30;
  end; // 1: begin // fill params, Variant #1

  2: begin // fill params, Variant #2
    TDPWidth := 0;

  end; // 2: begin // fill params, Variant #2

  else // Create Test DIB
  begin
    if TDPWidth < 0 then // fill ATestDIBParams^
      N_CreateTestDIB8( abs(TDPWidth), APTestDIBParams );

    Result := TN_DIBObj.Create( TDPWidth, TDPHeight, TDPPixFmt, -1, epfBMP );

    with Result do
    begin
      if TDPNumCellsX <= 0 then TDPNumCellsX := 1;
      if TDPNumCellsY <= 0 then TDPNumCellsY := 1;

      DIBOCanv.DrawPixGrid( DIBRect, DIBSize.X div TDPNumCellsX, TDPBordSize, TDPNumCellsX,
                            DIBSize.Y div TDPNumCellsY, TDPBordSize, TDPNumCellsY,
                            TDPFillColor1, TDPFillColor2, TDPBordColor, TDPIndsColor );
      N_DebSetNFont( DIBOCanv, TDPStringHeight/DIBOCanv.CurLFHPixSize, 0 );
      DIBOCanv.SetFontAttribs( TDPStringColor );
      DIBOCanv.DrawPixString( Point(TDPStringHeight,TDPStringHeight), TDPString );
    end; // with Result do
  end; // else // Create Test DIB
  end; // case AMode of
  end; // with APTestDIBParams^ do

end; //*** end function N_CreateTestDIB8

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CreateTestDIB16
//******************************************************* N_CreateTestDIB16 ***
// Create epfGray16 DIB object for testing purposes
//
//     Parameters
// AMode           - =0 - Create resulting DIB by given params =1 - just Fill 
//                   params (variant #1)
// APTestDIBParams - pointer to TN_TestDIBParams record with all needed params
// Result          - Returns reulting DIB object
//
function N_CreateTestDIB16( AMode: integer; APTestDIBParams: TN_PTestDIBParams ): TN_DIBObj;
begin
  Result := nil;
  if APTestDIBParams = nil then Exit; // a precaution

  with APTestDIBParams^ do
  begin

  case AMode of

  1: begin // fill params, Variant #1
    // not implemented
  end; // 1: begin // fill params, Variant #1

  2: begin // fill params, Variant #2
    TDPWidth := 0;
  end; // 2: begin // fill params, Variant #2

  else // Create Test DIB
  begin
    // temporary 5x3 EpfGray16 raster, APTestDIBParams^ are not used

    Result := TN_DIBObj.Create( 5, 3, pfCustom, -1, epfGray16 );

    with Result do
    begin
      SetPixValue( Point(0, 0), $000 );
      SetPixValue( Point(1, 0), $001 );
      SetPixValue( Point(2, 0), $0FF );
      SetPixValue( Point(3, 0), $100 );
      SetPixValue( Point(4, 0), $101 );

      SetPixValue( Point(0, 1), $08FEF );
      SetPixValue( Point(1, 1), $08FFE );
      SetPixValue( Point(2, 1), $08FFF );
      SetPixValue( Point(3, 1), $09000 );
      SetPixValue( Point(4, 1), $09010 );

      SetPixValue( Point(0, 2), $0FEFF );
      SetPixValue( Point(1, 2), $0FF00 );
      SetPixValue( Point(2, 2), $0FF01 );
      SetPixValue( Point(3, 2), $0FFFE );
      SetPixValue( Point(4, 2), $0FFFF );
    end; // with Result do
  end; // else // Create Test DIB
  end; // case AMode of
  end; // with APTestDIBParams^ do

end; //*** end function N_CreateTestDIB16

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CreateTestDIB
//********************************************************* N_CreateTestDIB ***
// Create DIB object for testing purposes by given AParams string
//
//     Parameters
// AParams - string with resulting DIBObj Params (now one integer in [1..3])
// Result  - Returns reulting DIB object
//
// AParams = '1' - 400x300 epfGray8  Rect with horizontal gradient AParams = '2'
// - 400x300 pf24bit   Rect with four (YBGR) horizontal gradients AParams = '3' 
// - 400x300 epfGray16 Rect with horizontal gradient, NumBits=10 AParams = '4' -
// different 2x3 DIBs (see source code) AParams = '5' - 100x320 epfGray16 with 
// sequential PixValues from 0 t0 31999, NumBits=15
//
function N_CreateTestDIB( AParams: String ): TN_DIBObj;
var
  i, iMax, NeededDIBType, ColorMin, ColorMax, CurColor, NX, NY, BordWidth: Integer;
  QY: Integer;
  CurRect: TRect;

  procedure FillRectByPixValue( ARect: TREct; APixValue: integer );
  var
    ix, iy: Integer;
  begin
    for ix := ARect.Left to ARect.Right  do
    for iy := ARect.Top  to ARect.Bottom do
      Result.SetPixValue( Point(ix,iy), APixValue );
  end; // procedure FillRectByPixValue( ARect: TREct; APixValue: integer );

begin
  Result := nil;

  NeededDIBType := N_ScanInteger( AParams );

  if NeededDIBType = 1 then // epfGray8 Rect with horizontal gradient
  begin
    NX        := 400;
    NY        := 300;
    BordWidth :=  50;
    ColorMin  :=  30; // in 0-255 range
    ColorMax  := 220; // in 0-255 range

    Result := TN_DIBObj.Create( NX, NY, pfCustom, -1, epfGray8 );

    with Result do
    begin
      //***** Fill two background rects
      FillRectByPixValue( Rect( 0, 0, NX div 2, NY-1 ), ColorMax );
      FillRectByPixValue( Rect( NX div 2 +1, 0, NX-1, NY-1 ), ColorMin );

      iMax := NX - 2*BordWidth - 1;
      for i := 0 to iMax do // along one pix columns, fill by gradient
      begin
        CurColor := ColorMin + i*(ColorMax-ColorMin) div iMax;
        CurRect := Rect( 0, BordWidth, 0, NY - BordWidth - 1 );
        CurRect.Left  := BordWidth + i;
        CurRect.Right := CurRect.Left;
        FillRectByPixValue( CurRect, CurColor );
      end; // for i := 0 to NX-2*BordWidth-1 do // along one pix columns, fill by gradient
    end; // with Result do

  end else if NeededDIBType = 2 then // pf24bit Rect with four (YBGR) horizontal gradients
  begin
    NX        := 400;
    NY        := 300;
    BordWidth :=  50;
    ColorMin  :=  30; // in 0-255 range
    ColorMax  := 220; // in 0-255 range

    Result := TN_DIBObj.Create( NX, NY, pf24bit, -1 );
    QY := (NY - 2*BordWidth) div 4;

    with Result do
    begin
      //***** Fill two background rects
      FillRectByPixValue( Rect( 0, 0, NX div 2, NY-1 ), N_GrayToRGB8(ColorMax) );
      FillRectByPixValue( Rect( NX div 2 +1, 0, NX-1, NY-1 ), N_GrayToRGB8(ColorMin) );

      iMax := NX - 2*BordWidth - 1;
      for i := 0 to iMax do // along one pix columns, fill by four gradients
      begin
        CurColor := ColorMin + i*(ColorMax-ColorMin) div iMax; // Gray (same as Blue)
        CurRect := Rect( 0, BordWidth, 0, BordWidth + QY - 1 );
        CurRect.Left  := BordWidth + i;
        CurRect.Right := CurRect.Left;
        FillRectByPixValue( CurRect, N_GrayToRGB8(CurColor) ); // Gray Graddient

        CurColor := ColorMin + i*(ColorMax-ColorMin) div iMax; // Gray (same as Blue)
        CurRect := Rect( 0, BordWidth+QY, 0, BordWidth + 2*QY - 1 );
        CurRect.Left  := BordWidth + i;
        CurRect.Right := CurRect.Left;
        FillRectByPixValue( CurRect, CurColor ); // Blue Graddient

        CurColor := (ColorMin + i*(ColorMax-ColorMin) div iMax) shl 8;  // Green
        CurRect := Rect( 0, BordWidth + 2*QY, 0, BordWidth + 3*QY - 1 );
        CurRect.Left  := BordWidth + i;
        CurRect.Right := CurRect.Left;
        FillRectByPixValue( CurRect, CurColor ); // Green

        CurColor := (ColorMin + i*(ColorMax-ColorMin) div iMax) shl 16;  // Red
        CurRect := Rect( 0, BordWidth + 3*QY, 0, BordWidth + 4*QY - 1 );
        CurRect.Left  := BordWidth + i;
        CurRect.Right := CurRect.Left;
        FillRectByPixValue( CurRect, CurColor ); // Red
      end; // for i := 0 to NX-2*BordWidth-1 do // along one pix columns, fill by gradient
    end; // with Result do

  end else if NeededDIBType = 3 then // epfGray16 Rect with horizontal gradient
  begin
    NX        := 400;
    NY        := 300;
    BordWidth :=  50;
    ColorMin  := 120; // in 0-2**NumBits-1 range
    ColorMax  := 880; // in 0-2**NumBits-1 range

    Result := TN_DIBObj.Create( NX, NY, pfCustom, -1, epfGray16, 10 );

    with Result do
    begin
      //***** Fill two background rects
      FillRectByPixValue( Rect( 0, 0, NX div 2, NY-1 ), ColorMax );
      FillRectByPixValue( Rect( NX div 2 +1, 0, NX-1, NY-1 ), ColorMin );

      iMax := NX - 2*BordWidth - 1;
      for i := 0 to iMax do // along one pix columns, fill by gradient
      begin
        CurColor := ColorMin + i*(ColorMax-ColorMin) div iMax;
        CurRect := Rect( 0, BordWidth, 0, NY - BordWidth - 1 );
        CurRect.Left  := BordWidth + i;
        CurRect.Right := CurRect.Left;
        FillRectByPixValue( CurRect, CurColor );
      end; // for i := 0 to NX-2*BordWidth-1 do // along one pix columns, fill by gradient

    end; // with Result do

  end else if NeededDIBType = 4 then // 2x3 Gray8 DIB
  begin
//    Result := TN_DIBObj.Create( 2, 3, pfCustom, -1, epfGray8 );
//    Result := TN_DIBObj.Create( 2, 3, pfCustom, -1, epfGray16 );
    Result := TN_DIBObj.Create( 2, 3, pf24bit, -1, epfBMP );

    with Result do
    begin
{
      SetPixValue( Point(0,0),   0 );
      SetPixValue( Point(1,0),   1 );
      SetPixValue( Point(0,1), 100 );
      SetPixValue( Point(1,1), 200 );
      SetPixValue( Point(0,2), 254 );
      SetPixValue( Point(1,2), 255 );
}
      SetPixValue( Point(0,0), N_GrayToRGB8(   0 ) );
      SetPixValue( Point(1,0), N_GrayToRGB8(   1 ) );
      SetPixValue( Point(0,1), N_GrayToRGB8( 100 ) );
      SetPixValue( Point(1,1), N_GrayToRGB8( 200 ) );
      SetPixValue( Point(0,2), N_GrayToRGB8( 254 ) );
      SetPixValue( Point(1,2), N_GrayToRGB8( 255 ) );

//      SetSelfDIBNumBits();
    end; // with Result do

  end else if NeededDIBType = 5 then // AParams = '5' - 100x320 epfGray16 with sequential PixValues from 0 t0 31999, NumBits=15
  begin
    Result := TN_DIBObj.Create( 100, 320, pfCustom, -1, epfGray16, 15 );

    with Result do
    begin
      for i := 0 to 31999 do
      begin
        SetPixValue( Point( i mod 100, i div 100 ), i );
      end;

//      SetSelfDIBNumBits();
    end; // with Result do

  end; // else if NeededDIBType = 5 then // AParams = '5'

end; //*** end function N_CreateTestDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CreateTestDIBFromDIB
//************************************************** N_CreateTestDIBFromDIB ***
// Create new DIB object for testing purposes by given AParams string and given 
// source ASrcDIB
//
//     Parameters
// AParams - string with resulting DIBObj Params (now one integer in [1..8])
// ASrcDIB - given DIBObj to convert from
// Result  - Returns reulting DIB object
//
// AParams = '1'-'8' - conv to epfGray16 by shifting ASrcDIB pixels by 
// AParams[1] bits to the left
//
function N_CreateTestDIBFromDIB( AParams: String; ASrcDIB: TN_DIBObj ): TN_DIBObj;
var
  SrcSM, DstSM: TN_SMatrDescr;
  Char1Int: integer;
begin
  if Length(AParams) > 0 then
    Char1Int := integer(AParams[1]) - integer('0')
  else
    Char1Int := -1;

  if (1 <= Char1Int) and (Char1Int <= 8) then // conv to epfGray16 by shifting ASrcDIB pixels by AParams[1] bits to the left
  begin
    ASrcDIB.PrepSMatrDescr( @SrcSM );

    with ASrcDIB do
      Result := TN_DIBObj.Create( DIBSize.X, DIBSize.Y, pfCustom, -1, epfGray16 );

    Result.PrepSMatrDescr( @DstSM );

    N_Conv2SMCopyShift( @SrcSM, @DstSM, Char1Int, csmShiftLeftOr );
    Result.DIBNumBits := Char1Int + 8;

//    Result.DIBNumBits := 0; Result.SetSelfDIBNumBits();
  end else // Return ASrcDIB
    Result := ASrcDIB;

end; //*** end function N_CreateTestDIBFromDIB

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CreateDIBFromCMSI
//***************************************************** N_CreateDIBFromCMSI ***
// Create DIB object from given AFileName (with any extension) in cmsi Format
//
//     Parameters
// AFileName - given file name
// Result    - Returns resulting DIB object
//
function N_CreateDIBFromCMSI( AFileName: string ): TN_DIBObj;
var
  i, j, NX, NY, itmp: integer;
  BitsPerPixel: byte;
  PCur0, PCur1: PByte;
// PTmpp0, PTmpp1: PAnsiChar;
  SignStr: string;
  FStream: TFileStream;
begin
  FStream := nil; // to avoid warning
  Result := nil;
  try
    FStream := TFileStream.Create( AFileName, fmOpenRead );
    SetLength( SignStr, 3 );
    FStream.Read( SignStr[1], 3 );
    FStream.Read( BitsPerPixel, 1 );
    FStream.Read( NX, 4 );
    FStream.Read( NY, 4 );

    if BitsPerPixel = 8 then
    begin
     Result := TN_DIBObj.Create( NX, NY, pfCustom, -1, epfGray8 );

     for i := NY-1 downto 0 do // along all pixel rows
       FStream.Read( (Result.PRasterBytes + i*Result.RRLineSize)^, NX ); // read i-th row

    end else if BitsPerPixel = 16 then
    begin
      Result := TN_DIBObj.Create( NX, NY, pfCustom, -1, epfGray16 );

      for i := NY-1 downto 0 do // along all pixel rows
      begin
        FStream.Read( (Result.PRasterBytes + i*Result.RRLineSize)^, 2*NX ); // read i-th row

        //***** Swap high and low bytes

        PCur0 := PByte(Result.PRasterBytes + i*Result.RRLineSize + 0);
        PCur1 := PByte(Result.PRasterBytes + i*Result.RRLineSize + 1);

        for j := 0 to NX do // swap high and low bytes in all pixels of i-th row
        begin
          itmp := PCur0^;
          PCur0^ := PCur1^;
          PCur1^ := itmp;
          Inc( PCur0, 2 );
          Inc( PCur1, 2 );
        end; // for j := 0 to NX-1 do // swap high and low bytes

{
        //***** Reverse all pixels in row
        PCur0 := PByte(Result.PRasterBytes + i*Result.RRLineSize + 0); // first pixel
        PCur1 := PCur0;
        Inc( PCur1, Result.RRLineSize-2 ); // last pixel

        for j := 0 to NX div 2 do // Reverse pixels
        begin
          itmp := PWORD(PCur0)^;
          PWORD(PCur0)^ := PWORD(PCur1)^;
          PWORD(PCur1)^ := itmp;
          Inc( PCur0, 2 );
          Dec( PCur1, 2 );
        end; // for j := 0 to NX-1 do // Reverse pixels
}
      end; // for i := 0 to NY-1 do // along all pixel rows

    end;
    FStream.Free;
//    Result.ReduceNumBits();
  except
    on E: Exception do
    begin
      FStream.Free;
      Result.Free;
      raise Exception.Create(E.Message);
    end;
  end; // try
end; //*** end function N_CreateDIBFromCMSI

{
//********************************************** N_CreateGray8DIBFromGray16 ***
// Create epfGray8 DIB object from given epfGray16 DIB object with max contrast
//
//     Parameters
// AGray16DIB - given epfGray16 DIB object
// Result     - Returns resulting epfGray8 DIB object
//
// Min brightness in Resulting DIB is always 0, Max brightness - always 255
//
function N_CreateGray8DIBFromGray16( AGray16DIB: TN_DIBObj ): TN_DIBObj;
var
  i, MinHistInd, MaxHistInd, XLATLength, MaxInd: integer;
  BrighHistValues, XLAT: TN_IArray;
begin
  Assert( AGray16DIB.DIBExPixFmt = epfGray16, 'N_CreateGray8DIBFromGray16 error, Should be epfGray16!' );

  AGray16DIB.CalcBrighHistNData( BrighHistValues, nil, @MinHistInd, @MaxHistInd, nil, AGray16DIB.DIBNumBits );
  XLATLength := Length( BrighHistValues );
  MaxInd := XLATLength - 1;
  SetLength( XLAT, XLATLength );

  if MinHistInd = MaxHistInd then
    XLAT[MinHistInd] := 128 // all pixels has the same value, it should be converted to 128
  else // normal case, more han one brightness values
    for i := 0 to High(XLAT) do // XLAT: 0->0, MinHistInd->0, MaxHistInd->255, MaxInd->255
    begin
      if i < MinHistInd then XLAT[i] := 0
      else if i > MaxHistInd then XLAT[i] := MaxInd
      else // MinHistInd <= i <= MaxHistInd
        XLAT[i] := Round( (i-MinHistInd)*255/(MaxHistInd-MinHistInd) );
    end; // for i := MinHistInd to MaxHistInd do // XLAT: 0->0, MinHistInd->0, MaxHistInd->255, MaxInd->255

  Result := nil;
  AGray16DIB.CalcXLATDIB( Result, 0, @XLAT[0], 1, pfCustom, epfGray8 );

  Result.DIBInfo.bmi.biXPelsPerMeter := AGray16DIB.DIBInfo.bmi.biXPelsPerMeter;
  Result.DIBInfo.bmi.biYPelsPerMeter := AGray16DIB.DIBInfo.bmi.biYPelsPerMeter;
end; //*** end function N_CreateGray8DIBFromGray16
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CreateEmptyBMP
//******************************************************** N_CreateEmptyBMP ***
// Create empty TBitmap object
//
//     Parameters
// AWidth  - resulting bitmap width
// AHeight - resulting bitmap height
// APixFmt - resulting bitmap pixel format enumeration
// Result  - Returns Delphi TBitmap object
//
function N_CreateEmptyBMP( AWidth, AHeight: integer; APixFmt: TPixelFormat ): TBitmap;
begin
  Result := Tbitmap.Create;
  with Result do
  begin
    Width  := AWidth;
    Height := AHeight;
    PixelFormat := APixFmt;
    Canvas.Pixels[AWidth-1, AHeight-1] := 0; // a precaution
  end;
end; //*** end function N_CreateEmptyBMP

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CreateBMPObjFromFile
//************************************************** N_CreateBMPObjFromFile ***
// Create TBitmap object from given BMP, GIF or JPG file
//
//     Parameters
// AFileName - given source file name
// Result    - Returns Delphi TBitmap object
//
function N_CreateBMPObjFromFile( AFileName: string ): TBitmap;
var
  FExt: string;
  GifObj: TGifFile;
  JPEGObj: TJPEGImage;
begin
  FExt   := UpperCase( ExtractFileExt( AFileName ) );
  Result := TBitmap.Create;

  N_GlobObj.GOGifTranspColor    := -1;
  N_GlobObj.GOGifTranspColorInd := -1;

  if FExt = '.BMP' then //*********************************** *.bmp file
  begin
    Result.LoadFromFile( AFileName );
  end else if FExt = '.GIF' then //************************** *.gif file
  begin
    GifObj := TGifFile.Create;
    GifObj.LoadFromFile( AFileName );
    Result.Assign( GifObj.AsBitmap );

    with N_GlobObj, TGifSubImage(GifObj.SubImages[0]) do
    begin
      GOGifTranspColor    := TransparentColor();      // returns -1 if absent
      GOGifTranspColorInd := TransparentColorIndex(); // returns -1 if absent

      if GOGifTranspColor <> -1 then // Transparent Color Exists
      begin
        Result.TransparentMode := tmFixed;
        Result.TransparentColor := GOGifTranspColor;
      end; // if GOGifTranspColor <> -1 then // Transparent Color Exists
    end; // with N_GlobObj, TGifSubImage(GifObj.SubImages[0]) do

    GifObj.Free;
  end else if (FExt = '.JPG') or (FExt = '.JPE') then //***** *.jpeg file
  begin
    JPEGObj := TJPEGImage.Create;
    JPEGObj.LoadFromFile( AFileName );
    Result.Assign( JPEGObj );
    JPEGObj.Free;
  end else // error
  begin
    FreeAndNil( Result );
    raise Exception.Create( 'Unknown format: ' + FExt );
  end;

end; //*** end function N_CreateBMPObjFromFile

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CreateBMPObjFromStream
//************************************************ N_CreateBMPObjFromStream ***
// Create TBitmap object from given BMP, GIF or JPG stream
//
//     Parameters
// AStream - given source file name
// Result  - Returns Delphi TBitmap object
//
function N_CreateBMPObjFromStream( AStream: TStream ): TBitmap;
var
  BegPos: Integer;
  StreamFmt: TN_ImageFileFormat;
  Header: Array [0..9] of Byte;
// PTmpp: PAnsiChar;
  GifObj: TGifFile;
  JPEGObj: TJPEGImage;
begin
  BegPos := AStream.Seek( 0, soFromCurrent );
  AStream.Read( Header, 10 );
  AStream.Seek( BegPos, soFromBeginning );
  StreamFmt := N_GetFileFmtByHeader( @Header[0] );

  Result := TBitmap.Create;

  N_GlobObj.GOGifTranspColor := -1;
  N_GlobObj.GOGifTranspColorInd := -1;

  if StreamFmt = imffBMP then //****************** *.bmp file
  begin
    Result.LoadFromStream( AStream );
  end else if StreamFmt = imffGIF then //********* *.gif file
  begin
    GifObj := TGifFile.Create;
    GifObj.LoadFromStream( AStream );
    Result.Assign( GifObj.AsBitmap );

    with N_GlobObj, TGifSubImage(GifObj.SubImages[0]) do
    begin
      GOGifTranspColor    := TransparentColor();      // returns -1 if absent
      GOGifTranspColorInd := TransparentColorIndex(); // returns -1 if absent

      if GOGifTranspColor <> -1 then // Transparent Color Exists
      begin
        Result.TransparentMode := tmFixed;
        Result.TransparentColor := GOGifTranspColor;
      end; // if GOGifTranspColor <> -1 then // Transparent Color Exists
    end; // with N_GlobObj, TGifSubImage(GifObj.SubImages[0]) do

    GifObj.Free;
  end else if StreamFmt = imffJPEG then //******** *.jpeg file
  begin
    JPEGObj := TJPEGImage.Create;
    JPEGObj.LoadFromStream( AStream );
    Result.Assign( JPEGObj );
    JPEGObj.Free;
  end else // error
  begin
    FreeAndNil( Result );
//    raise Exception.Create( 'Unknown Stream format' );
  end;

end; //*** end function N_CreateBMPObjFromStream

{
//************************************************** N_SaveBMPObjToFile ***
// Save given TBitmap Object to BMP, GIF or JPG file
//
procedure N_SaveBMPObjToFile( ABMPObj: TBitmap; AFileName: string;
                        AFileFmt: TN_ImageFileFormat; APImFPar: TN_PImageFilePar );
begin
var
  GifObj: TGifFile;
  JPEGObj: TJPEGImage;
  TmpBMPObj: TBitmap;
  ImageFilePar: TN_PImageFilePar;
begin
  if APImFPar = nil then ImageFilePar := N_DefImageFilePar
                    else ImageFilePar := APImFPar^;

  if AFileFmt = imffByFileExt then
     AFileFmt := N_GetFileFmtByExt( AFileName );

  if AFileFmt = imffBMP then //***** *.bmp file
  begin
    ABMPObj.SaveToFile( AFileName );
  end else if AFileFmt = imffGIF then //***** GIF file
  begin
    TmpBMPObj := TBitmap.Create; // is needed because GIF desctructor
    TmpBMPObj.Assign( ABMPObj ); // destroys Bitmap objects, given
                                 //  in AddBitmap method!
    GifObj := TGifFile.Create;
    GifObj.Header.Version := '89a';
    GifObj.AddBitmap( TmpBMPObj );
    GifObj.SaveToFile( AFileName );
    GifObj.Free; // TmpBMPObj will be freed!
    N_SetTranspColorToGifFile( AFileName, ImageFilePar.IFPFTranspColor );
  end else if AFileFmt = imffJPEG then //***** JPEG file
  begin
    JPEGObj := TJPEGImage.Create;
    JPEGObj.CompressionQuality := ImageFilePar.IFPFQuality;
    JPEGObj.Assign( ABMPObj );
    JPEGObj.SaveToFile( AFileName );
    JPEGObj.Free;
  end else // error
    raise Exception.Create( 'Not supported format: ' + IntToStr(Ord(AFileFmt)) );

  N_SetResToRasterFile ( AFileName, AFileFmt, ImageFilePar.IFPFResDPI );
end; //*** end procedure N_SaveBMPObjToFile
}

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_SaveBMPObjToFile
//****************************************************** N_SaveBMPObjToFile ***
// Save given TBitmap Object to BMP, GIF or JPG file
//
//     Parameters
// ABMPObj  - source TBitmap Object
// AFName   - resulting file name
// APParams - resulting file raster parameters
//
// Resulting file format is defind by file name extension.
//
procedure N_SaveBMPObjToFile( ABMPObj: TBitmap; AFName: string;
                                                APParams: TN_PImageFilePar );
//                                                APFile1Params: TN_PFile1Params );
var
  GifObj: TGifFile;
  JPEGObj: TJPEGImage;
  TmpBMPObj: TBitmap;
begin
  with APParams^ do
  begin
    if IFPImFileFmt = imffByFileExt then
      IFPImFileFmt := N_GetFileFmtByExt( AFName );

    if IFPImFileFmt = imffBMP then //***** *.bmp file
    begin
      ABMPObj.SaveToFile( AFName );
    end else if IFPImFileFmt = imffGIF then //***** GIF file
    begin
      TmpBMPObj := TBitmap.Create; // is needed because GIF desctructor
      TmpBMPObj.Assign( ABMPObj ); // destroys Bitmap objects, given
                                   //  in AddBitmap method!
      GifObj := TGifFile.Create;
      GifObj.Header.Version := '89a';
      GifObj.AddBitmap( TmpBMPObj );
      GifObj.SaveToFile( AFName );
      GifObj.Free; // TmpBMPObj will be freed!
      N_SetTranspColorToGifFile( AFName, IFPTranspColor );
    end else if IFPImFileFmt = imffJPEG then //***** JPEG file
    begin
      JPEGObj := TJPEGImage.Create;
      JPEGObj.CompressionQuality := IFPJPEGQuality;
      JPEGObj.Assign( ABMPObj );
      JPEGObj.SaveToFile( AFName );
      JPEGObj.Free;
    end else // error
      raise Exception.Create( 'Not supported format: ' + IntToStr(Ord(IFPImFileFmt)) );

    N_SetResToRasterFile ( AFName, IFPImFileFmt, IFPResDPI );
  end; // with APParams^ do
end; //*** end procedure N_SaveBMPObjToFile

//##path N_Delphi\SF\N_Tree\N_Gra2.pas\N_CopyBMPToClipboard
//**************************************************** N_CopyBMPToClipboard ***
// Save given TBitmap Object to Windows Clipboard
//
//     Parameters
// ABMP - given TBitmap Object
//
procedure N_CopyBMPToClipboard( ABMP: TBitmap );
var
  AFormat: Word;
  AData: THandle;
  APalette: HPALETTE;
begin
  ABMP.SaveToClipboardFormat( AFormat, AData, APalette );
  ClipBoard.SetAsHandle( AFormat, AData );
end; //*** procedure N_CopyBMPToClipboard

//************************************************** N_ReplaceOneColorInDIB ***
// Replace given OldColor in given DIB by given NewColor
//
procedure N_ReplaceOneColorInDIB( PDIBInfo: TN_PDIBInfo; OldColor, NewColor: integer );
begin
  // not implemeneted
end; //*** procedure N_ReplaceOneColorInDIB

//************************************************ N_SetFontSmoothing ***
// Set Global Windows FontSmoothing mode
//
procedure N_SetFontSmoothing( AUseSmoothing: boolean );
begin
  // This call with False Param cleares Windows settings (CheckBox) in
  // Экран - Оформление - Эффекты ... - Применять следующий метод сглаживания
  //                                    экранных шрифтов
  SystemParametersInfo( SPI_SETFONTSMOOTHING, Cardinal(AUseSmoothing), nil, 0 );
end; //*** procedure N_SetFontSmoothing

//**************************************************** N_SetResToRasterFile ***
// Set given AResDPI to BMP or JPEG file with given AFileName
//
procedure N_SetResToRasterFile( AFileName: string; AFileFmt: TN_ImageFileFormat;
                                                             AResDPI: TFPoint );
var
  PelsPerMeterX, PelsPerMeterY, biXPelsPerMeterOfs, IntDPIX, IntDPIY: integer;
  Data: array [0..4] of byte;
  TmpDIBInfo: TN_DIBInfo;
  FStream: TFileStream;
begin
  if (AResDPI.X <= 0) or (AResDPI.Y <= 0) then Exit; // a precaution

  if AFileFmt = imffByFileExt then
    AFileFmt := N_GetFileFmtByExt( AFileName );

  //***** // only BMP and JPEG files are supported
  if (AFileFmt <> imffBMP) and (AFileFmt <> imffJPEG) then Exit;

  FStream := TFileStream.Create( AFileName, fmOpenReadWrite );

  case AFileFmt of
  imffBMP: begin //******************* BMP file
    PelsPerMeterX := Round( AResDPI.X * 1000 / 25.4 ); // AResDPI.X * 100 ???
    PelsPerMeterY := Round( AResDPI.Y * 1000 / 25.4 );
    biXPelsPerMeterOfs := Sizeof(TBitmapFileHeader) +
//      TN_BytesPtr(@TmpDIBInfo.bmi.biXPelsPerMeter) - TN_BytesPtr(@TmpDIBInfo);
      DWORD(@TmpDIBInfo.bmi.biXPelsPerMeter) - DWORD(@TmpDIBInfo);

    FStream.Seek( biXPelsPerMeterOfs, soFromBeginning );
    FStream.Write( PelsPerMeterX, SizeOf(integer) ); // biXPelsPerMeter
    FStream.Write( PelsPerMeterY, SizeOf(integer) ); // biYPelsPerMeter
  end; // imffBMP begin //******************* BMP file

  imffJPEG: begin //******************* JPEG file
    IntDPIX := Round( AResDPI.X );
    IntDPIY := Round( AResDPI.Y );
    FStream.Seek( 13, soFromBeginning );
    Data[0] := 1;  // set resolution units (=1 means DPI)
    Data[1] := IntDPIX shr 8;   // X resolution high byte
    Data[2] := IntDPIX and $FF; // X resolution low byte
    Data[3] := IntDPIY shr 8;   // Y resolution high byte
    Data[4] := IntDPIY and $FF; // Y resolution low byte
    FStream.Write( Data[0], 5 );
  end; // imffJPEG begin //******************* JPEG file

  end; // case AFileFmt of

  FStream.Free;
end; //*** procedure N_SetResToRasterFile

//*********************************************** N_SetTranspColorToGifFile ***
// Set given Transparent Color ATranspColor to GIF file with given File Name
// Now initial GIF File should not have TranspColor.
// Current version can not change or delete TranspColor in GIF File
//
procedure N_SetTranspColorToGifFile( AFileName: string; ATranspColor: integer );
var
  i, NumColors, GCTableSize, BeforeSize, AfterSize, CurColor, TranspInd: integer;
  FStream: TFileStream;
  MStream: TMemoryStream;
  Header: TGifheader;
  LSDescr: TLogicalScreenDescriptor;
  GCEHeader: WORD;
  GCE: TGraphicControlExtension;
// PTmpp: PAnsiChar;
  Label InsertExtension;
begin
  if ATranspColor = N_EmptyColor then Exit;

  FStream := TFileStream.Create( AFileName, fmOpenReadWrite );

  FStream.Read( Header, Sizeof(Header) );
  if ( Header.Signature <> 'GIF') or ( Header.Version <> '89a') then
  begin
    N_WarnByMessage( AFileName + ' is not a proper GIF file!' );
    FStream.Free;
    Exit;
  end;

  FStream.Read( LSDescr, Sizeof(LSDescr) );

  with LSDescr do
  begin
    if (PackedFields and $80) <> 0 then // Global Color Table exists
    begin
      NumColors := Round( Power( 2, (PackedFields and $7) + 1 ) );
      GCTableSize := 3 * NumColors;
      BeforeSize := FStream.Position + GCTableSize;

      for i := 0 to NumColors-1 do // found ColorIndex
      begin
        FStream.Read( CurColor, 3 );

        if CurColor = ATranspColor then
        begin
          TranspInd := i;
          goto InsertExtension;
        end;

      end; // for i := 0 to NumColors-1 do // found ColorIndex

//      N_WarnByMessage( AFileName + ' No Transparent Color!' );
      FStream.Free;
      Exit;

    end else // with LSDescr do
    begin
      N_WarnByMessage( AFileName + ' No Color Table!' );
      FStream.Free;
      Exit;
    end;// if (PackedFields and $80) <> 0 then // Global Color Table exists
  end;

  InsertExtension: //******************************

  FStream.Seek( 0, soFromEnd );
  AfterSize := FStream.Position - BeforeSize;
  FStream.Seek( 0, soFromBeginning );

  MStream := TMemoryStream.Create();
  MStream.CopyFrom( FStream, BeforeSize );

  GCEHeader := $F921;
  MStream.Write( GCEHeader, 2 );

  FillChar( GCE, Sizeof(GCE), 0 );
  GCE.BlockSize := 4;
  GCE.PackedFields := 9;
  GCE.TransparentColorIndex := TranspInd;
  MStream.Write( GCE, Sizeof(GCE) );

  MStream.CopyFrom( FStream, AfterSize );

  FStream.Seek( 0, soFromBeginning );
  MStream.Seek( 0, soFromBeginning );
  FStream.CopyFrom( MStream, 0 );

  FStream.Free;
  MStream.Free;
end; //*** procedure N_SetTranspColorToGifFile

//********************************************************** N_ParseGifFile ***
// Parse Gif File with given AFileName (now is used for Debug only)
//
procedure N_ParseGifFile( AFileName: string );
var
  i, NumColors, CurColor: integer;
  FStream: TFileStream;
  Header: TGifheader;
  GCEHeader: WORD;
  LSDescr: TLogicalScreenDescriptor;
  GCE: TGraphicControlExtension;
// PTmpp: PAnsiChar;
  Label InsertExtension;
begin
  FStream := TFileStream.Create( AFileName, fmOpenReadWrite );

  FStream.Read( Header, Sizeof(Header) );
  if ( Header.Signature <> 'GIF') or ( Header.Version <> '89a') then
  begin
    N_WarnByMessage( AFileName + ' is not a proper GIF file!' );
    FStream.Free;
    Exit;
  end;

  FStream.Read( LSDescr, Sizeof(LSDescr) );

  with LSDescr do
  begin
    if (PackedFields and $80) <> 0 then // Global Color Table exists
    begin
      NumColors := Round( Power( 2, (PackedFields and $7) + 1 ) );
//      GCTableSize := 3 * NumColors;

      for i := 0 to NumColors-1 do // found ColorIndex
      begin
        FStream.Read( CurColor, 3 );
      end; // for i := 0 to NumColors-1 do // found ColorIndex

    end else // with LSDescr do
    begin
      N_WarnByMessage( AFileName + ' No Color Table!' );
      FStream.Free;
      Exit;
    end;// if (PackedFields and $80) <> 0 then // Global Color Table exists
  end;

  FStream.Read( GCEHeader, 2 );
  FStream.Read( GCE, Sizeof(GCE) );
  FStream.Read( GCEHeader, 2 );

  FStream.Free;
end; //*** procedure N_ParseGifFile

//****************************************************** N_CreateScreenShot ***
// Create ScreenShot in given AFileName
//
procedure N_CreateScreenShot( AFileName: string );
var
  ScreenRect: TRect;
  ScreenDIB: TN_DIBObj;
  ScreenHDC: HDC;
begin
  ScreenDIB := TN_DIBObj.Create( Screen.Width, Screen.Height, pf24bit );
  ScreenHDC := windows.GetDC( 0 ); // windows Desktop handle
  ScreenRect := Rect( 0, 0, Screen.Width-1, Screen.Height-1 );
  N_CopyRect( ScreenDIB.DIBOCanv.HMDC, Point(0,0), ScreenHDC, ScreenRect ); // copy whole desktop
  ScreenDIB.SaveToFileByGDIP( AFileName );
  ScreenDIB.Free;
  N_Dump1Str( 'Screenshot created in ' + AFileName );
end; //*** procedure N_CreateScreenShot

//*********************************************** N_AddScreenShotToLogFiles ***
// Create ScreenShot in N_LogChannels[0] files folder
//
//     Parameters
// AFNamePrefix - given File Name prefix
//
procedure N_AddScreenShotToLogFiles( AFNamePrefix: string );
var
  FName, LogFilesFolder, FExt: string;
begin
  if Length(N_LogChannels) = 0 then Exit; // Log files folder not specified

  LogFilesFolder := ExtractFilePath( N_LogChannels[0].LCFullFName );

  if (N_UniqFilesCounter < 0) or (N_UniqFilesCounter > 9000) then
    N_UniqFilesCounter := 0; // a precaution

  if N_WinVista and not N_WinWin7 then // Windows Vista cannot work with png files
    FExt := '.bmp'
  else // Not Vista
    FExt := '.png';

  FName := K_BuildUniqFileName( LogFilesFolder, AFNamePrefix, FExt, N_UniqFilesCounter );
  N_CreateScreenShot( FName );
end; //*** procedure N_AddScreenShotToLogFiles

//***************************************************** N_CheckDIBFreeSpace ***
// Check Memory Free Space for creating DIB Section
//
//     Parameters
// ADIBSize - given DIB Section Size in bytes
// Result   - Returns TRUE if ADIBSize DIB Section can be created
//
function N_CheckDIBFreeSpace( ADIBSize: integer ) : Boolean;
var
  WDIB: TN_DIBObj;
begin
  Result := FALSE;

  try
    WDIB := TN_DIBObj.Create( ADIBSize, 1, pf8bit ); // ADIBSize x 1 pixels
    WDIB.Free;
  except
    Exit; // not enough space
  end;

  Result := TRUE;
end; // function N_CheckDIBFreeSpace

//****************************************************** N_TestPatternBrush ***
// Test PatternBrush
//
procedure N_TestPatternBrush();
//var
//  FName, LogFilesFolder, FExt: string;
begin

end; //*** procedure N_TestPatternBrush

//******************************************************* N_BrighHistToText ***
// Dump given ABrighHistValues to given AStrings ("Print" ABrighHistValues)
//
//     Parameters
// ABrighHistValues - given integer array of Brightness (for 8 or 16 bit pixels)
// AStrings         - given Strings with ABrighHistValues as Text
//
// If Length(ABrighHistValues) < 2**16 - 8 bit pixels assumed
//
procedure N_BrighHistToText( ABrighHistValues: TN_IArray; AStrings: TStrings );
var
  i, ix, iy, Ind, NumElems, MaxVal, CurVal, NumDigits, MinInd, MaxInd: integer;
  Str, Header, Spaces, FmtStr: string;
begin
  NumElems := Length( ABrighHistValues );

//       if NumElems <= 255 then Exit
//  else if NumElems <= N_MaxUInt2 then NumElems := 256
//  else NumElems := N_MaxUInt2 + 1;

  //***** Calc MinInd, MaxInd, MaxVal

  MinInd := -1;
  MaxInd := -1;
  MaxVal := -1;

  for i := 0 to NumElems-1 do
  begin
    CurVal := ABrighHistValues[i];
    MaxVal := max( MaxVal, CurVal );

    if (MinInd = -1) and (CurVal > 0) then MinInd := i;

    if CurVal > 0 then MaxInd := i;

  end; // for i := 0 to NumElems-1 do

  AStrings.Add( Format( '***** Brigh Hist Values (%d elems, MinInd=%d, MaxInd=%d, MaxVal=%d ):',
                                         [NumElems, MinInd, MaxInd, MaxVal] ) );

  NumDigits := N_CalcNumDigits( MaxVal );
  NumDigits := max( 3, NumDigits );

  if NumElems <= 256 then // 8 bit pixels
  begin
    //***** 8 columns, 32 rows

    FmtStr := Format( '%%%dd %%3d  ', [NumDigits] ); // main loop format

    //***** Prepare Columns Header string
    Spaces := DupeString( ' ', NumDigits - 3 );
    Header := '';

    for ix := 0 to 7 do // along columns,
      Header := Header + Spaces + 'Val Ind  ';

    AStrings.Add( Header ); // Columns Header

    for iy := 0 to 32-1 do // along rows
    begin
      Str := '';

      for ix := 0 to 7 do // along columns
      begin
        Ind := ix*32+iy;
        if Ind <= High(ABrighHistValues) then CurVal := ABrighHistValues[Ind]
                                         else CurVal := -1;

        Str := Str + Format( FmtStr, [CurVal, Ind] );
      end; // for ix := 0 to 7 do // along columns

      AStrings.Add( Str );
    end; // for iy := 0 to 32-1 do // along rows

    AStrings.Add( '' );
  end else // NumElems = N_MaxUInt2 + 1,  16 bit pixels
  begin
    //***** 8 columns, 32*256 rows

    for iy := 0 to 32*256-1 do // along rows
    begin
      Str := '';

      for ix := 0 to 7 do // along columns
      begin
        Ind := ix*32*256+iy;
        Str := Str + Format( '%05d %05d   ', [Ind, ABrighHistValues[Ind]] );
      end; // for ix := 0 to 7 do // along columns

      AStrings.Add( Str );
    end; // for iy := 0 to 32*256-1 do // along rows

    AStrings.Add( '' );
  end; // else // NumElems = N_MaxUInt2 + 1,  16 bit pixels

end; //*** procedure N_BrighHistToText

//******************************************************* N_BrighHistToFile ***
// Dump given ABrighHistValues to file ("Print to file" ABrighHistValues)
// using N_BrighHistToText
//
//     Parameters
// ABrighHistValues - given integer array of Brightness (for 8 or 16 bit pixels)
// AFName           - given File Name
// AHeader          - given Header (will be first string in file)
//
// N_BrighHistToText is used
//
procedure N_BrighHistToFile( ABrighHistValues: TN_IArray; AFName, AHeader: String );
begin
  N_SL.Clear();
  N_SL.Add( AHeader );
  N_SL.Add( '' );
  N_BrighHistToText( ABrighHistValues, N_SL );
  N_SL.SaveToFile( AFName );
end; //*** procedure N_BrighHistToFile

//*********************************************** N_Prepare1BitBMPby8BitDIB ***
// Prepare pf1bit AWrkBitmap (mask) by given pf8bit ASrcDIB8 DIBObj
//
//     Parameters
// ASrcDIB8    - given pf8bit DIBObj
// APWhiteInds - given Pointer to integer Palette indexes with resulting White Pixels
// ANumInds    - given number of indexes, pointed to by APWhiteInds
// AWrkBitmap  - on input - any Bitmap or nil, on output - resulting Mask
//
// On output in resulting AWrkBitmap all pixels with APWhiteInds pix values are White (=1),
// all other pixels are Black (=0).
//
// ASrcDIB8 Palette could be changed (do not remains the same!)
//
procedure N_Prepare1BitBMPby8BitDIB( ASrcDIB8: TN_DIBObj; APWhiteInds: PInteger;
                                     ANumInds: integer; var AWrkBitmap: TBitmap );
var
  i: integer;
  PInds: PInteger;
  CreateMask: boolean;
begin
  if ASrcDIB8.DIBPixFmt <> pf8bit then Exit; // a precaution

  CreateMask := True;

  if AWrkBitmap <> nil then
    with AWrkBitmap do
      if (AWrkBitmap.Width  = ASrcDIB8.DIBSize.X) and
         (AWrkBitmap.Height = ASrcDIB8.DIBSize.Y) and
         (AWrkBitmap.PixelFormat = pf1bit) then CreateMask := False;

  if CreateMask then
  begin
    AWrkBitmap.Free;
    AWrkBitmap := N_CreateEmptyBMP( ASrcDIB8.DIBSize.X, ASrcDIB8.DIBSize.Y, pf1bit );
  end;

  //***** Change ASrcDIB8 Palette

  FillChar( ASrcDIB8.DIBInfo.PalEntries[0], 256*SizeOf(Integer), 0 ); // all Black entries
  PInds := APWhiteInds;

  for i := 0 to ANumInds-1 do
  with ASrcDIB8.DIBInfo do
  begin
    PalEntries[PInds^] := $00FFFFFF; // White entries
    Inc( PInds );
  end;

  Windows.SetDIBColorTable( ASrcDIB8.DibOCanv.HMDC, 0, 256, ASrcDIB8.DIBInfo.PalEntries[0] );
//  ASrcDIB8.SaveToBMPFormat( '..\TestData\Mask1a.bmp' ); // debug

  //***** ASrcDIB8 is OK, prepare AWrkBitmap by drawing

  N_CopyRect( AWrkBitmap.Canvas.Handle, Point(0,0), ASrcDIB8.DIBOCanv.HMDC, ASrcDIB8.DIBRect );
//  AWrkBitmap.SaveToFile( '..\TestData\Mask1b.bmp' ); // debug

end; // procedure N_Prepare1BitBMPby8BitDIB

//************************************************** N_DrawGraphicMenuItems ***
// Draw Graphic Menu Items
//
//     Parameters
// ADstHDC     - Where to Draw HDC (e.g. Bitmap.Canvas.Handle)
// ADIBWhite   - DIBObj for White (1) Mask Pixels, given by APWhiteInds
// ADIBBlack   - DIBObj for Black (0) Mask Pixels, all other inds
// ADIB8Mask   - Mask DIBObj (pf8bit, i-th pixels are i-th Menu Item place, 0<=i<=255)
// APWhiteInds - Pointer to White Menu Items Inds (shown by ADIBWhite)
// ANumInds    - given number of indexes, pointed to by APWhiteInds
// AWrkBitmap  - any Bitmap used as temporary bitmask inside the procedure
//
// All menu Items listed in APWhiteInds will be shown by ADIBWhite image (Highlited),
// all other pixels will be shown by ADIBWhite image (Normal).
//
procedure N_DrawGraphicMenuItems( ADstHDC: HDC; ADIBWhite, ADIBBlack, ADIB8Mask: TN_DIBObj;
                      APWhiteInds: PInteger; ANumInds: integer; var AWrkBitmap: TBitmap );
var
  ROP4: DWORD;
begin
  //***** Copy whole Menu background (ADIBBlack) to ADstHDC
  N_CopyRect( ADstHDC, Point(0,0), ADIBBlack.DIBOCanv.HMDC, ADIBBlack.DIBRect );

  //***** Prepare pf1bit Mask in AWrkBitmap
  N_Prepare1BitBMPby8BitDIB( ADIB8Mask, APWhiteInds, ANumInds, AWrkBitmap );
//  AWrkBitmap.SaveToFile( '..\TestData\Mask1c.bmp' ); // debug

  //***** Copy only Menu foreground (ADIBWhite) Items to ADstHDC
  ROP4 := MakeROP4( SRCCOPY, $00AA0029 ); // Src is ADIBWhite, Dst is ADstHDC with drawn ADIBWhite
  N_CopyRectByMask( ADstHDC, Point(0,0), ADIBWhite.DIBOCanv.HMDC, ADIBWhite.DIBRect,
                                                     AWrkBitmap.Handle, ROP4 );
end; // procedure N_DrawGraphicMenuItems

procedure N_ConvDIBToArrAverageFast1( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; AApRadius: integer );
// Wrapper for N_Conv2SMAverageFast1 with TN_DIBObj and TN_BArray params
var
  DstMatrSize: integer;
  SrcSM, DstSM, SrcSM1, DstSM1: TN_SMatrDescr;
begin
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  if SrcSM.SMDElSize <= 2 then // monochrome pixels
    N_Conv2SMAverageFast1( @SrcSM, @DstSM, AApRadius, fbmNotFill )
  else // only Color RGB24 pixels, epfColor48 (RGB48 pixels) is not implemented
  begin
    N_ConvSMatrDescr( @SrcSM, @SrcSM1, 0 );
    N_ConvSMatrDescr( @DstSM, @DstSM1, 0 );
    N_Conv2SMAverageFast1( @SrcSM1, @DstSM1, AApRadius, fbmNotFill ); // conv Red bytes

    N_ConvSMatrDescr( @SrcSM, @SrcSM1, 1 );
    N_ConvSMatrDescr( @DstSM, @DstSM1, 1 );
    N_Conv2SMAverageFast1( @SrcSM1, @DstSM1, AApRadius, fbmNotFill ); // conv green bytes

    N_ConvSMatrDescr( @SrcSM, @SrcSM1, 2 );
    N_ConvSMatrDescr( @DstSM, @DstSM1, 2 );
    N_Conv2SMAverageFast1( @SrcSM1, @DstSM1, AApRadius, fbmNotFill ); // conv blue bytes
  end; // else // Color pixels

end; // procedure procedure N_ConvDIBToArrAverageFast1

procedure N_ConvDIBToArrMedianHuang( ADIB: TN_DIBObj; var ADstMatr: TN_BArray; AApRadius: integer );
// Wrapper for N_Conv2SMMedianHuang with TN_DIBObj and TN_BArray params
var
  DstMatrSize: integer;
  SrcSM, DstSM: TN_SMatrDescr;
begin
  ADIB.PrepSMatrDescr( @SrcSM );
  ADIB.PrepSMatrDescrByFlags( @DstSM, 0, @DstMatrSize );

  SetLength( ADstMatr, DstMatrSize );
  DstSM.SMDPBeg := TN_BytesPtr(@ADstMatr[0]);

  N_Conv2SMMedianHuang( @SrcSM, @DstSM, 2*AApRadius+1 );
end; // procedure procedure N_ConvDIBToArrMedianHuang

//******************************************************** N_ConvSMatrDescr ***
// Convert given Color APSrcSMatrDescr^ to monochrome APDstSMatrDescr^
//
//     Parameters
// APSrcSMatrDescr - pointer to Source SMatrDescr
// APDstSMatrDescr - pointer to Destination SMatrDescr
// AOffset         - needed color component offset (0-red, 1-green, 2-blue)
//
// Can be used for opertions with Color pixels matrixes by subsequent operations
// with monochrome pixels matrixes
//
procedure N_ConvSMatrDescr( APSrcSMatrDescr, APDstSMatrDescr: TN_PSMatrDescr; AOffset: integer );
begin
  move( APSrcSMatrDescr^, APDstSMatrDescr^, SizeOf(APSrcSMatrDescr^) );

  with APDstSMatrDescr^ do
  begin
    Inc( SMDPBeg, AOffset );
    SMDElSize := 1;
  end; // with APDstSMatrDescr^ do
end; // procedure N_ConvSMatrDescr

//*********************************************************** N_TestLoadDIB ***
// Load DIB using TK_RasterImage in given Test Mode
//
//     Parameters
// ADIB   - given DIBObj to load or nil, on output nil if error
// AFName - Image File Name
// AMode  - Loading mode: 0 - from File, 1 - from Stream, 2 - from Memory
// ALib   - Library used: 0 - GDI+, 1 - ImageLibrary
//
procedure N_TestLoadDIB( var ADIB: TN_DIBObj; AFName: string; AMode, ALib: integer );
var
  FileSize, IntErrorCode: Integer;
  RIObj: TK_RasterImage;
  ResCode: TK_RIResult;
  FStream: TFileStream;
  BArray: TN_BArray;

  procedure CheckResCode( AStr: String ); // local
  begin
    if ResCode <> rirOK then // error
    begin
      if RIObj <> nil then
        IntErrorCode := RIObj.RIGetLastNativeErrorCode()
      else
        IntErrorCode := 0;

      N_Dump1Str( Format( 'N_TestLoadDIB ErrCodes= %d %d, %s (Amode=%d, ALib=%d, %s)',
                       [integer(ResCode), IntErrorCode, AStr, AMode, ALib, AFName] ) );
      FreeAndNil( ADIB );
    end;
  end; // procedure CheckResCode(); // local

begin
  RIObj := nil;
  FStream := nil;

  if not FileExists( AFName ) then
  begin
    ResCode := rirFails;
    CheckResCode( 'File not found' );
    Exit;
  end;

  if ALib = 0 then // use GDI+
    RIObj := TK_RIGDIP.Create
  else // ALib = 1, use TN_RIImLib
    RIObj := TN_RIImLib.Create;

  if not RIObj.RIObjectReady() then
  begin
    ResCode := rirFails;
    CheckResCode( 'RIObjectReady' );
    RIObj.Free;
    Exit;
  end;

  if AMode = 0 then // load from File
  begin
    ResCode := RIObj.RIOpenFile( AFName );
    CheckResCode( 'RIOpenFile' );
  end else if AMode = 1 then // load from Stream
  begin
    FStream := TFileStream.Create( AFName, fmOpenRead );
    ResCode := RIObj.RIOpenStream( FStream );
    CheckResCode( 'RIOpenStream' );
  end else // AMode = 2, load from Memory
  begin
    FileSize := N_ReadBinFile( AFName, BArray ); // Read from Mem
    ResCode := RIObj.RIOpenMemory( @BArray[0], FileSize );
    CheckResCode( 'RIOpenMemory' );
  end;

  if ResCode <> rirOK then // Open error
  begin
    FStream.Free;
    RIObj.Free;
    Exit;
  end;

  ResCode := RIObj.RIGetDIB( 0, ADIB );
  CheckResCode( 'RIGetDIB' );

{ 2015-02-05 - this code not needed because all is done later
  if ResCode <> rirOK then
  begin
    RIObj.RIClose();
    FStream.Free;
    RIObj.Free;
    Exit;
  end;
}
  ResCode := RIObj.RIClose();
  CheckResCode( 'RIClose' );

  FStream.Free;
  RIObj.Free;
end; // procedure N_TestLoadDIB

//*********************************************************** N_TestSaveDIB ***
// Save DIB using TK_RasterImage in given Test Mode
//
//     Parameters
// ADIB   - given DIBObj to save
// AFName - Image File Name
// AMode  - Loading mode: 0 - from File, 1 - from Stream, 2 - from Memory
// ALib   - Library used: 0 - GDI+, 1 - ImageLibrary
//
procedure N_TestSaveDIB( ADIB: TN_DIBObj; AFName: string; AMode, ALib: integer );
var
  FileSize, IntErrorCode: Integer;
  RIObj: TK_RasterImage;
  FileEncInfo: TK_RIFileEncInfo;
  ResCode: TK_RIResult;
  FStream: TFileStream;
  PBuf: Pointer;

  procedure CheckResCode( AStr: String ); // local
  begin
    if ResCode <> rirOK then // error
    begin
      if RIObj <> nil then
        IntErrorCode := RIObj.RIGetLastNativeErrorCode()
      else
        IntErrorCode := 0;

      N_Dump1Str( Format( 'N_TestSaveDIB ErrCodes= %d %d, %s (Amode=%d, ALib=%d, %s)',
                       [integer(ResCode), IntErrorCode, AStr, AMode, ALib, AFName] ) );
    end;
  end; // procedure CheckResCode(); // local

begin
  if ADIB = nil then Exit; // nothing to do

  RIObj := nil;
  FStream := nil; // to avoid warning

  if ALib = 0 then // use GDI+
    RIObj := TK_RIGDIP.Create
  else // ALib = 1, use TN_RIImLib
    RIObj := TN_RIImLib.Create;

  if not RIObj.RIObjectReady() then
  begin
    ResCode := rirFails;
    CheckResCode( 'RIObjectReady' );
    RIObj.Free;
    Exit;
  end;

  with FileEncInfo do
  begin
    RIFileEncType   := RIObj.RIEncTypeByFileExt( AFName ); // set by FileName Extension
    RIFComprType    := rictDefByFileEncType;  // Defined by file format
    RIFComprQuality := 100; // Compresson Quality (used in JPEG)
  end;

  if AMode = 0 then // save to File
  begin
    ResCode := RIObj.RICreateFile( AFName, @FileEncInfo );
    CheckResCode( 'RICreateFile' );
  end else if AMode = 1 then // save to Stream
  begin
    FStream := TFileStream.Create( AFName, fmCreate );
    ResCode := RIObj.RICreateStream( FStream, @FileEncInfo );
    CheckResCode( 'RICreateStream' );
  end else // AMode = 2, save to Memory
  begin
    ResCode := RIObj.RICreateEncodeBuffer( @FileEncInfo );
    CheckResCode( 'RICreateEncodeBuffer' );
  end;

  if ResCode <> rirOK then // Create error
  begin
    FStream.Free;
    RIObj.Free;
    Exit;
  end;

  ResCode := RIObj.RIAddDIB( ADIB );
  CheckResCode( 'RIAddDIB' );

  if ResCode <> rirOK then
  begin
    RIObj.RIClose();
    FStream.Free;
    RIObj.Free;
    Exit;
  end;

  if AMode = 0 then // save to File
  begin
    // Nothing to do
  end else if AMode = 1 then // save to Stream
  begin
    // Nothing to do
  end else // AMode = 2, save to Memory
  begin
    ResCode := RIObj.RIGetEncodeBuffer( PBuf, FileSize );
    CheckResCode( 'RIGetEncodeBuffer' );

    if ResCode <> rirOK then
    begin
      RIObj.RIClose();
      FStream.Free;
      RIObj.Free;
      Exit;
    end else
      N_WriteBinFile( AFName, PBuf, FileSize );
  end;

  ResCode := RIObj.RIClose();
  CheckResCode( 'RIClose' );

  FStream.Free;
  RIObj.Free;
end; // procedure N_TestSaveDIB

//************************************************ N_LoadDIBFromFileByImLib ***
// Load given ADIB from given raster file using ImageLibrary
//
//     Parameters
// ADIB      - given DIBObj or nil
// AFileName - given source file name
// Result    - Returns 0 if OK, or TN_RIImLib.RIILNativeError
//
function N_LoadDIBFromFileByImLib( var ADIB: TN_DIBObj; AFileName: string ): integer;
var
  RIImLib: TN_RIImLib;
//  RIImLib: TK_CMRI;
  RIResult: TK_RIResult;
  Label Error;
begin
  RIImLib := TN_RIImLib.Create(); // use ImageLibrary only
//  RIImLib := TK_CMRI.Create();  // if ImageLibrary failed, use GDIPlus

  RIResult := RIImLib.RIOpenFile( AFileName );
  if RIResult <> rirOK then goto Error;

  RIResult := RIImLib.RIGetDIB( 0, ADIB );
  if RIResult <> rirOK then
  begin
    Result := RIImLib.RIGetLastNativeErrorCode();
    RIImLib.RIClose();
    RIImLib.Free;
    Exit;
  end;

  RIResult := RIImLib.RIClose();
  if RIResult <> rirOK then goto Error;

  Result := 0; // all OK
  RIImLib.Free;
  Exit;

  Error: //***********************
  Result := RIImLib.RIGetLastNativeErrorCode();
  RIImLib.Free;
end; // function N_LoadDIBFromFileByImLib

//************************************************ N_LoadDIBFromFileByImLib ***
// Load given ADIB from given raster file using Universal Raster Image Object
//
//     Parameters
// ADIB      - given DIBObj or nil
// AFileName - given source file name
// Result    - Returns 0 if OK, or TN_RIImLib.RIILNativeError
//
function N_LoadDIBFromFile( var ADIB: TN_DIBObj; AFileName: string ): integer;
var
  RIImLib: TK_URI;
  RIResult: TK_RIResult;
  Label Error;
begin
  RIImLib := TK_URI.Create();  // if ImageLibrary failed, use GDIPlus

  RIResult := RIImLib.RIOpenFile( AFileName );
  if RIResult <> rirOK then goto Error;

  RIResult := RIImLib.RIGetDIB( 0, ADIB );
  if RIResult <> rirOK then
  begin
    Result := RIImLib.RIGetLastNativeErrorCode();
    RIImLib.RIClose();
    RIImLib.Free;
    Exit;
  end;

  RIResult := RIImLib.RIClose();
  if RIResult <> rirOK then goto Error;

  Result := 0; // all OK
  RIImLib.Free;
  Exit;

  Error: //***********************
  Result := RIImLib.RIGetLastNativeErrorCode();
  RIImLib.Free;
end; // function N_LoadDIBFromFile

//************************************************** N_SaveDIBToFileByImLib ***
// Save given ADIB to given raster File (with bmp, jpg, png, tif extensions)
//
//     Parameters
// AFileName - given resulting file name
// Result    - Returns 0 if OK, or TN_RIImLib.RIILNativeError
//
function N_SaveDIBToFileByImLib( ADIB: TN_DIBObj; AFileName: string ): Integer;
var
  RIImLib: TN_RIImLib;
  RIResult: TK_RIResult;
  EncodingInfo: TK_RIFileEncInfo;
  Label Error;
begin
  RIImLib := TN_RIImLib.Create();

  RIImLib.RIClearFileEncInfo( @EncodingInfo );
  RIResult := RIImLib.RICreateFile( AFileName, @EncodingInfo );
  if RIResult <> rirOK then goto Error;

  RIResult := RIImLib.RIAddDIB( ADIB );
  if RIResult <> rirOK then goto Error;

  RIResult := RIImLib.RIClose();
  if RIResult <> rirOK then goto Error;

  Result := 0; // all OK
  Exit;

  Error: //***********************
  Result := RIImLib.RIILNativeError;
  RIImLib.Free;
end; // function N_SaveDIBToFileByImLib

//****************************************************** N_DIBInfoToStrings ***
// Add to Strings DIBInfo fields
//
//     Parameters
// APDIBInfo   - given pointer to DIBInfo
// AName       - DIBObj 'Name' (to simplify understanding which DIB is logged)
// AResStrings - Strings Object, to which DIBInfo fields would be added
//
// Convert to Strings all self DIBInfo fields. Used mainly for debugging.
//
procedure N_DIBInfoToStrings( APDIBInfo: TN_PDIBInfo; AName: string; AResStrings: TStrings );
var
  i, j: integer;
  Str: String;
begin
  if (APDIBInfo = nil) or (AResStrings = nil) then Exit; // a precaution

  with APDIBInfo^.bmi do
  begin
    AResStrings.Add( Format( '***** %s: X,Y=%dx%d, BitCount=%d,',
                                 [AName,biWidth,biHeight,biBitCount] ));
    AResStrings.Add( Format(
      'ImgSize=%d, XYPerMeter=%d,%d, ClrUsed=%d, Important=%d, InfoSize=%d, Planes=%d, Compr=%d',
      [biSizeImage,biXPelsPerMeter,biYPelsPerMeter,biClrUsed,biClrImportant,biSize,biPlanes,biCompression] ));

    if biBitCount <= 8 then // Palette exists
    begin
      AResStrings.Add( '          Palette (by rows):' );
      for i := 0 to 31 do
      begin
        Str := Format( '  %0.3d ', [i*8] ); // 8 elems per row

        for j := 0 to 7 do
          Str := Str + Format( '%0.8X ', [APDIBInfo^.PalEntries[i*8+j]] );

        AResStrings.Add( Str );
      end; // for i := 0 to 31 do
    end; // if biBitCount <= 8 then // Palette exists
  end; // with APDIBInfo^.bmi do

end; // procedure N_DIBInfoToStrings

//*************************************************** N_CMSTridentDIBAdjust ***
// Adjust Trident DIBObj
//
//     Parameters
// ADIBObj - given DIBObj to adjust (16 bit)
//
procedure N_CMSTridentDIBAdjust( var ADIBObj: TN_DIBObj );
begin
  ADIBObj.CalcMaxContrastDIB( ADIBObj );
end; // procedure N_CMSTridentDIBAdjust

//****************************************************** N_DICOMPixToDIBPix ***
// Convert DICOM raster pixels to DIB raster pixels
//
//     Parameters
// APDICOMPix - pointer to DICOM raster pixels (not DWORD aligned, BGR colors)
// ADIBObj    - given DIBObj with all fields set except of Raster Bytes
//              (DWORD aligned, RGB colors)
//
procedure N_DICOMPixToDIBPix( APDICOMPix: TN_BytesPtr; ADIBObj: TN_DIBObj );
var
  ix, iy, DIBHeight, DIBWidth, PixSize: integer;
  PCurDICOM, PCurDIB: TN_BytesPtr; // current pointers to DICOM or DIB Pixels
begin
  DIBHeight := ADIBObj.DIBInfo.bmi.biHeight; // is positive for bottom-up DIB, is negative for top-down DIB
  DIBWidth  := ADIBObj.DIBInfo.bmi.biWidth;

  if DIBHeight = 0 then Exit; // a precaution

  PixSize := ADIBObj.GetElemSizeInBytes();

  if DIBHeight > 0 then // bottom-up DIB
  begin

    for iy := 0 to DIBHeight-1 do // along Raster Rows
    begin
      PCurDIB := ADIBObj.PRasterBytes + (DIBHeight-1-iy) * ADIBObj.RRLineSize; // same for all pixel sizes

      case PixSize of

      1: begin // one byte pixels (8 bit monochrome)
           PCurDICOM := APDICOMPix + iy * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             PCurDIB^ := PCurDICOM^; // copy one byte
             Inc( PCurDIB );
             Inc( PCurDICOM );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row
         end; // 1: begin // one byte pixels (8 bit monochrome)

      2: begin // two bytes pixels (16 bit monochrome)
           PCurDICOM := APDICOMPix + iy * 2 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             PWord(PCurDIB)^ := PWord(PCurDICOM)^; // copy two bytes
             Inc( PCurDIB,   2 );
             Inc( PCurDICOM, 2 );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 2: begin // two bytes pixels (16 bit monochrome)

      3: begin // three bytes pixels (24 bit RGB)
           PCurDICOM := APDICOMPix + iy * 3 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             (PCurDIB+0)^ := (PCurDICOM+2)^; // copy Red byte
             (PCurDIB+1)^ := (PCurDICOM+1)^; // copy Green byte
             (PCurDIB+2)^ := (PCurDICOM+0)^; // copy Blue byte
             Inc( PCurDIB,   3 );
             Inc( PCurDICOM, 3 );

           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 3: begin // three bytes pixels (24 bit RGB)

      4: begin // four bytes pixels (32 bit RGB)
           PCurDICOM := APDICOMPix + iy * 3 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             (PCurDIB+0)^ := (PCurDICOM+2)^; // copy Red byte
             (PCurDIB+1)^ := (PCurDICOM+1)^; // copy Green byte
             (PCurDIB+2)^ := (PCurDICOM+0)^; // copy Blue byte
             Inc( PCurDIB,   4 );
             Inc( PCurDICOM, 3 );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 4: begin // four bytes pixels (32 bit RGB)

      end; // case PixSize of
    end; // for iy := 0 to -1 - DIBHeight do // along Raster Rows

  end else // top-down DIB (DIBHeight < 0)
  begin

    for iy := 0 to -1-DIBHeight do // along Raster Rows
    begin
      PCurDIB := ADIBObj.PRasterBytes + iy * ADIBObj.RRLineSize; // same for all pixel sizes

      case PixSize of

      1: begin // one byte pixels (8 bit monochrome)
           PCurDICOM := APDICOMPix + iy * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             PCurDIB^ := PCurDICOM^; // copy one byte
             Inc( PCurDIB );
             Inc( PCurDICOM );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row
         end; // 1: begin // one byte pixels (8 bit monochrome)

      2: begin // two bytes pixels (16 bit monochrome)
           PCurDICOM := APDICOMPix + iy * 2 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             PWord(PCurDIB)^ := PWord(PCurDICOM)^; // copy two bytes
             Inc( PCurDIB,   2 );
             Inc( PCurDICOM, 2 );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 2: begin // two bytes pixels (16 bit monochrome)

      3: begin // three bytes pixels (24 bit RGB)
           PCurDICOM := APDICOMPix + iy * 3 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             (PCurDIB+0)^ := (PCurDICOM+2)^; // copy Red byte
             (PCurDIB+1)^ := (PCurDICOM+1)^; // copy Green byte
             (PCurDIB+2)^ := (PCurDICOM+0)^; // copy Blue byte
             Inc( PCurDIB,   3 );
             Inc( PCurDICOM, 3 );

           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 3: begin // three bytes pixels (24 bit RGB)

      4: begin // four bytes pixels (32 bit RGB)
           PCurDICOM := APDICOMPix + iy * 3 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             (PCurDIB+0)^ := (PCurDICOM+2)^; // copy Red byte
             (PCurDIB+1)^ := (PCurDICOM+1)^; // copy Green byte
             (PCurDIB+2)^ := (PCurDICOM+0)^; // copy Blue byte
             Inc( PCurDIB,   4 );
             Inc( PCurDICOM, 3 );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 4: begin // four bytes pixels (32 bit RGB)

      end; // case PixSize of
    end; // for iy := 0 to -1 - DIBHeight do // along Raster Rows

  end; // else // top-down DIB (DIBHeight < 0)

end; // procedure N_DICOMPixToDIBPix( APDICOMPix: TN_BytesPtr; ADIBObj: TN_DIBObj );

//****************************************************** N_DIBPixToDICOMPix ***
// Convert DIB raster pixels to DICOM raster pixels
//
//     Parameters
// APDICOMPix - pointer to DICOM raster pixels (not DWORD aligned, BGR colors)
// ADIBObj    - given DIBObj with all fields set except of Raster Bytes
//              (DWORD aligned, RGB colors)
//
procedure N_DIBPixToDICOMPix( APDICOMPix: TN_BytesPtr; ADIBObj: TN_DIBObj );
var
  ix, iy, DIBHeight, DIBWidth, PixSize: integer;
  PCurDICOM, PCurDIB: TN_BytesPtr; // current pointers to DICOM or DIB Pixels
begin
  DIBHeight := ADIBObj.DIBInfo.bmi.biHeight; // is positive for bottom-up DIB, is negative for top-down DIB
  DIBWidth  := ADIBObj.DIBInfo.bmi.biWidth;

  if DIBHeight = 0 then Exit; // a precaution

  PixSize := ADIBObj.GetElemSizeInBytes();

  if DIBHeight > 0 then // bottom-up DIB
  begin

    for iy := 0 to DIBHeight-1 do // along Raster Rows
    begin
      PCurDIB := ADIBObj.PRasterBytes + (DIBHeight-1-iy) * ADIBObj.RRLineSize; // same for all pixel sizes

      case PixSize of

      1: begin // one byte pixels (8 bit monochrome)
           PCurDICOM := APDICOMPix + iy * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             PCurDICOM^ := PCurDIB^; // copy one byte
             Inc( PCurDIB );
             Inc( PCurDICOM );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row
         end; // 1: begin // one byte pixels (8 bit monochrome)

      2: begin // two bytes pixels (16 bit monochrome)
           PCurDICOM := APDICOMPix + iy * 2 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             PWord(PCurDICOM)^ := PWord(PCurDIB)^; // copy two bytes
             Inc( PCurDIB,   2 );
             Inc( PCurDICOM, 2 );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 2: begin // two bytes pixels (16 bit monochrome)

      3: begin // three bytes pixels (24 bit RGB)
           PCurDICOM := APDICOMPix + iy * 3 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             (PCurDICOM+0)^ := (PCurDIB+2)^; // copy Red byte
             (PCurDICOM+1)^ := (PCurDIB+1)^; // copy Green byte
             (PCurDICOM+2)^ := (PCurDIB+0)^; // copy Blue byte
             Inc( PCurDIB,   3 );
             Inc( PCurDICOM, 3 );

           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 3: begin // three bytes pixels (24 bit RGB)

      4: begin // four bytes pixels (32 bit RGB)
           PCurDICOM := APDICOMPix + iy * 3 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             (PCurDICOM+0)^ := (PCurDIB+2)^; // copy Red byte
             (PCurDICOM+1)^ := (PCurDIB+1)^; // copy Green byte
             (PCurDICOM+2)^ := (PCurDIB+0)^; // copy Blue byte
             Inc( PCurDIB,   4 );
             Inc( PCurDICOM, 3 );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 4: begin // four bytes pixels (32 bit RGB)

      end; // case PixSize of
    end; // for iy := 0 to -1 - DIBHeight do // along Raster Rows

  end else // top-down DIB (DIBHeight < 0)
  begin

    for iy := 0 to -1-DIBHeight do // along Raster Rows
    begin
      PCurDIB := ADIBObj.PRasterBytes + iy * ADIBObj.RRLineSize; // same for all pixel sizes

      case PixSize of

      1: begin // one byte pixels (8 bit monochrome)
           PCurDICOM := APDICOMPix + iy * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             PCurDICOM^ := PCurDIB^; // copy one byte
             Inc( PCurDIB );
             Inc( PCurDICOM );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row
         end; // 1: begin // one byte pixels (8 bit monochrome)

      2: begin // two bytes pixels (16 bit monochrome)
           PCurDICOM := APDICOMPix + iy * 2 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             PWord(PCurDICOM)^ := PWord(PCurDIB)^; // copy two bytes
             Inc( PCurDIB,   2 );
             Inc( PCurDICOM, 2 );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 2: begin // two bytes pixels (16 bit monochrome)

      3: begin // three bytes pixels (24 bit RGB)
           PCurDICOM := APDICOMPix + iy * 3 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             (PCurDICOM+0)^ := (PCurDIB+2)^; // copy Red byte
             (PCurDICOM+1)^ := (PCurDIB+1)^; // copy Green byte
             (PCurDICOM+2)^ := (PCurDIB+0)^; // copy Blue byte
             Inc( PCurDIB,   3 );
             Inc( PCurDICOM, 3 );

           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 3: begin // three bytes pixels (24 bit RGB)

      4: begin // four bytes pixels (32 bit RGB)
           PCurDICOM := APDICOMPix + iy * 3 * DIBWidth;

           for ix := 0 to DIBWidth-1 do // along pixels in one raster row
           begin
             (PCurDICOM+0)^ := (PCurDIB+2)^; // copy Red byte
             (PCurDICOM+1)^ := (PCurDIB+1)^; // copy Green byte
             (PCurDICOM+2)^ := (PCurDIB+0)^; // copy Blue byte
             Inc( PCurDIB,   4 );
             Inc( PCurDICOM, 3 );
           end; // for ix := 0 to DIBWidth-1 do // along pixels in one raster row

         end; // 4: begin // four bytes pixels (32 bit RGB)

      end; // case PixSize of
    end; // for iy := 0 to -1 - DIBHeight do // along Raster Rows

  end; // else // top-down DIB (DIBHeight < 0)
{
  // N_i = количество нулей перед первой значащей цифрой (N_i=2 для N_d=0.0033333)
  N_d := 0.00333;
  N_i := Integer(Floor( -Log10(N_d) ));
  // если нужно 5 значащих цифр, то можно использовать формат
  N_s := Format( '%*.*f', [2+N_i+5, N_i+5, N_d] ); // 2 это две позиции на 0.
}
end; // procedure N_DIBPixToDICOMPix( APDICOMPix: TN_BytesPtr; ADIBObj: TN_DIBObj );

//*********************************************************** N_PatternFunc ***
// Empty Pattern Function
//
//     Parameters
// APar   - given integer
// Result - Returns TRUE if ADIBSize DIB Section can be created
//
function N_PatternFunc( APar: integer ): integer;
begin

  Result := 0;
end; // function N_PatternFunc

//*********************************************************** N_PatternProc ***
// Empty Pattern Procedure
//
//     Parameters
// APar   - given integer
//
procedure N_PatternProc( APar: integer );
begin

end; // procedure N_PatternProc

Initialization
  N_AddStrToFile( 'N_Gra2 Initialization' );

//      if  then
//        raise Exception.Create( '' );

end.
