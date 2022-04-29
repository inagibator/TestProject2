unit N_UDCMap;
// TN_UDMapLayer Component, SearchGroup for MapLayers and related objects

// TN_MLType         = ( mltNotDef, mltPoints1, mltLines1, mltConts1,
// TN_MLSubType      = ( mlstNotDef, mlstUTF16, mlstUTF8 );
// TN_MLVisible      = ( mlvNone, mlvNormal, mlvHidden, mlvAll );
// TN_CMapLayer      = packed record            // Map Layer Component Params
// TN_RMapLayer      = packed record // TN_UDMapLayer RArray Record type
// TN_UDMapLayer     = class( TN_UDCompVis ) // Map Layer Component
// TN_MarkedCObjPart = record //
// TN_SGMLayers      = class( TN_SGComp )       // Search Group for CMapLayers

interface
uses
     Windows, Graphics, Classes, Contnrs, Types,
     K_Script1, K_UDT1,
     N_Types, N_Lib1, N_Lib2, N_Gra0, N_Gra1, N_UDat4, N_Gra2, N_Rast1Fr, N_SGComp,
     N_CompCL, N_CompBase;


type TN_MLType = ( mltNotDef, mltPoints1, mltComponents,
                   mltLines1, mltConts1,
                   mltHorLabels, mltLineLabels, mltCurveLabels );

type TN_MLSubType = ( mlstNotDef, mlstUTF16, mlstUTF8 );

type TN_MLVisible = ( mlvNone, mlvNormal, mlvHidden, mlvAll );
  // mlvNone   - all Items invisible;        mlvNormal - Hidden Items invisible;
  // mlvHidden - only Hidden Items visible;  mlvAll    - all Items visible;

type TN_MLCoordsType = ( mlctUser, mlctAbsPix, mlctRelPix );

type TN_MLSizeUnits = ( mlsuLLW, mlsuPix );

type TN_CMapLayer = packed record // Map Layer Component Params
  MLComment: string;
  MLType: TN_MLType;
  MLSubType: TN_MLSubType;
  MLWrkFlags: byte; // not used now
  MLVisible: TN_MLVisible; // =0 - all Items not visible;     =1 - not hidden Items visible,
                           // =2 - only hidden Items visible; =3 - all Items visible;
  MLCDimInd: integer; // Used Codes Dimension Index
  MLFlags:   integer; // Data (attributes) indexing Flags (Index Mode):
        // bits0,1($03) - Data Vectors Indexing mode:
        //   =0 - typical mode, depends upon Data Vector type:
        //          - no Data Vectors - indexing does not matter
        //          - UDArray (not UDVector) - ItemInd is used, (Data elems synchro to CObj Items)
        //          - UDVector - use Item First Code for calculating UDVector Index
        //   =1 - not used
        //   =2 - treat UDVector as UDArray (not UDVector), ItemInd is always used,
        //          (Data elems should be synchro to CObj Items even for UDVector)
        //   =3 - treat UDVector as UDArray (not UDVector),
        //          Item First Code is used as Data Vector Index without any reindexing
        //
        // Other (equivalent) Bit0 and Bit1 description:
        // bit0($01) - Data Vectors source Index type, only if bit1($02)=1
        //             (if bit1($02)=0 then bit0 is not used):
        //   =0 - use ItemInd,
        //   =1 - use first code in MLCDimInd CS (obtained by CObj.GetItemFirstCode),
        //        Data Vectors final Index can be this code (Bit1=1) or code,
        //        converted by ReIndVectors (Bit1=0)
        //
        // bit1($02) - use reindexing or not:
        //   =0 - use ReIndVectors if possible for calculating final Data Vectors Index by Code
        //   =1 - do not use ReIndVectors, use ItemInd or first code in MLCDimInd CS
        //        as Data Vectors Index (see bit0($01)) and set all ReIndVectors to nil
        //
        // bit2($04) - update ReInd Vectors mode:
        //   =0 - ReInd Vectors are calculated only once (when they are nil at first call)
        //   =1 - ReInd Vectors are calculated before each drawing
        //                (may be needed after changing MLDVect(1-5) objects)
        //
        // bit4($010) - how to use MLVAVisBytes vector:
        //   =0 - use index according to bits0,1 and only first code in MLCDimInd CS,
        //          if MLVAVisBytes[index] = 0 then Item is not visible
        //   =1 - use all codes in MLCDimInd, Item is not visible if all bytes
        //          (for all codes in MLCDimInd) in MLVAVisBytes are zero
        //   (if Item has only one code in MLCDimInd, both cases (Bit4 =0 and =1) are the same)
        //
  MLDrawMode: integer; // Low level drawing mode (Draw Mode):
        // bits0-3($00F) - line mode (used if bits4-5 = 0):
        //    =0 - draw Norm lines by Windows.Polyline (without filling interior)
        //    =1 - draw Norm lines by Windows.Polygon
        //    =2 - draw System lines (with vertexes)
        //    =3 - draw Dash lines
        // bits4-5($030) - path mode:
        //    =0 - do not use paths (see bits0-3)
        //    =1 - draw by Windows.StrokePath (see bits0-3 ure not used)
        //    =2 - draw by Windows.FillPath (see bits0-3 ure not used)
        //    =3 - draw by Windows.StrokeAndFillPath (see bits0-3 ure not used)
        // bit6($040) - draw whole Layer as a single Path
        // bit7($080)  =1 - ShapeCoords Mode, =0 - Old Mode
        // bit8($0100) =1 - use PixRects array for labels and signs,
        //                  smooth line by quadratic Bezier splain
        // bit9($0200) =0 - use Components self Size (for mltComponents)
        //             =1 - use sizes from MLSSizeXY of from MLDVect3
        // bits12-13($03000) - Coords Mode:
        //             =0 - User Coords
        //             =1 - Abs Pixel Coords
        //             =2 - Relative (to CompIntPixRec) Pixel Coords
        //
  MLColorMode: integer; // color changing inside Layer mode (Color Mode):
        // bits0-3($000F) - :
        //    =0 - draw all Layer Items with same attributes
        //    =1 - check Color vectors
        //    =2 - change color before each Item
        //    =3 - change color before each ItemPart
        // bit4($0010) - index in N_SystemColor (0 or 1 for debug):
        // bit5($0020) - =0 change Pen Color, =1 - change Brush Color (for debug)
        // bit6($0040) - =0 R2_COPYPEN mode,  =1 - R2_XORPEN mode
        //
  MLPenColor:   integer;
  MLPenWidth:   float;
  MLPenStyle:   integer; // Windows Path drawing Flags
  MLBrushColor: integer;
  MLTextColor:  integer;
  MLAuxColor1:  integer;
  MLAuxColor2:  integer;
  MLExpParStr:  string;  // Export Params String

  MLReservedInt2: TN_Int2;
  MLSShape: TN_StandartShape; // Sign Shape
  MLSSizeXY:  TFPoint;    // Sign Size along X,Y in LSU
  MLShiftXY:  TFPoint;    // Shift along X,Y in LLW (for Signs and labels)
  MLHotPoint: TFPoint;    // Hot Point Norm. coords ( (1,0) - upper right corner)
//  MLMinScale:  float;     // Layer should be drawn only if P2U.CX/LLWSize > MLMinScale
//  MLFSCoef:    float;     // Font Scale Coef
  MLContAttr: TK_RArray;  // Drawing Attributes (RArray of TN_ContAttr)
  MLCAArray:  TK_RArray;  // Array Drawing Attributes (RArray of TN_ContAttrArray)

  MLCObj: TN_UCObjLayer;  // CoordsObj Layer to draw

  MLVAVisBytes: TObject;  // VArray of Visibility bytes (now only TK_UDVector!)
  MLDVect1: TK_UDRArray;  // Data Vector 1 (see comments just below)
  MLDVect2: TK_UDRArray;  // Data Vector 2
  MLDVect3: TK_UDRArray;  // Data Vector 3
  MLDVect4: TK_UDRArray;  // Data Vector 4
  MLDVect5: TK_UDRArray;  // Data Vector 5
  MLAux1:   TK_UDRArray;  // Aux data 1
  MLAux2:   TK_UDRArray;  // Aux data 2
  MLAux3:   TK_UDRArray;  // Aux data 3

  MLVArray1: TObject;     // New VArray 1 (instead of MLDVect1)
  MLVArray2: TObject;     // New VArray 1 (instead of MLDVect1)
  MLVArray3: TObject;     // New VArray 1 (instead of MLDVect1)
  MLVArray4: TObject;     // New VArray 1 (instead of MLDVect1)
  MLVArray5: TObject;     // New VArray 1 (instead of MLDVect1)
  MLVAux1:   TObject;     // VArray Aux data 1
  MLVAux2:   TObject;     // VArray Aux data 2
  MLVAux3:   TObject;     // VArray Aux data 3
end; // type TN_CMapLayer = packed record
type TN_PCMapLayer = ^TN_CMapLayer;

//type TN_MLType = ( mltNotDef, mltPoints1, mltComponents, mltLines1, mltConts1,
//                   mltHorLabels, mltLineLabels, mltCurveLabels );
//***** Maplayer types, Data vectors and Aux data usage:
//
// For all MLTypes:
//   MLVAVisBytes - VArray of Visibility bytes (temporary only TK_UDVector!),
//                  =0 - invisible, =1 - visible
//
// MLType = mltPoints1, mltComponents - Points Map Layer:
//                       (see TN_PointAttr1 for group attributes)
//   MLDVect1 - individual BrushColor
//   MLDVect2 - individual SShiftXY
//   MLDVect3 - individual SSize
//   MLDVect4 - individual Component (if MLType = mltComponents)
//   MLAux2   - CodeSubSpace for MLCSCode
//
// MLType = mltLines1 - Lines Map Layer:
//   MLDVect1 - individual BrushColor
//   MLDVect2 - individual PenColor
//   MLDVect3 - individual ContAttr
//
// MLType = mltConts1 - Contours Map Layer:
//   MLDVect1 - individual BrushColor
//   MLDVect2 - individual PenColor
//   MLDVect3 - individual ContAttr
//
// MLType = mltHorLabels - Horizontal Labels Map Layer:
//   MLDVect1 - individual Text ( or MLVArray1)
//   MLDVect2 - individual SShiftXY
//   MLDVect3 - individual FontRef (Font and ScaleCoef)
//   MLAux1   - common Font (or MLVAux1)
//
// MLType = mltCurveLabels - Curve Labels Map Layer:
//   MLDVect1 - individual Text
//   MLAux1   - common Font

type TN_RMapLayer = packed record // TN_UDMapLayer RArray Record type
  CSetParams: TK_RArray;     // component's SetParams Array
  CCompBase:  TN_CCompBase;  // Component Base Params
  CLayout:    TK_RArray;     // component Layout
  CCoords:    TN_CompCoords; // component Coords and Position
  CPanel:     TK_RArray;     // Component Panel
  CMapLayer:  TN_CMapLayer;  // Individual attributes
end; // type TN_RMapLayer = packed record
type TN_PRMapLayer = ^TN_RMapLayer;

type TN_UDMapLayer = class( TN_UDCompVis ) // Map Layer Component
  PCMapLayer: TN_PCMapLayer; // points to Dyn Params in VisualTree environment
                             // or to Stat Params in "standalone" environment
  MLVisPtrs:    TN_APBArray; // Pointers to Items Visibility bytes (<>0 - visible)
                             // (Pointers to MLVAVisBytes elements or nil)
  MLReIndVectVis: TN_IArray; // ReIndexing vector for Data MLVAVisBytes
  MLReIndVect1:   TN_IArray; // ReIndexing vector for Data Vector1
  MLReIndVect2:   TN_IArray; // ReIndexing vector for Data Vector2
  MLReIndVect3:   TN_IArray; // ReIndexing vector for Data Vector3
  MLReIndVect4:   TN_IArray; // ReIndexing vector for Data Vector4
  MLReIndVect5:   TN_IArray; // ReIndexing vector for Data Vector5
  MLPRects:      TN_IRArray; // Pixel Rects Array (for serching and highlighting)
  MLItemsSCodes:  TN_SArray; // Items Codes as Strings (used only if
//  MLScriptFunc1: TK_UDProgramItem; // Function1 from precompiled MLScript

  constructor Create; override;
  destructor  Destroy; override;

  function  PSP  (): TN_PRMapLayer;
  function  PDP  (): TN_PRMapLayer;
  function  PISP (): TN_PCMapLayer;
  function  PIDP (): TN_PCMapLayer;
  procedure PascalInit   (); override;
  procedure SetIconIndex ();
  procedure BeforeAction (); override;
  procedure ClearReIndVectors ();
  procedure SetReIndVectors   ();
  function  CreateAPUDRefs    (): TN_PUDArray;

  function  PDVE1   ( AInd: integer ): Pointer;
  function  PDVE2   ( AInd: integer ): Pointer;
  function  PDVE3   ( AInd: integer ): Pointer;
  function  PDVE4   ( AInd: integer ): Pointer;
  function  PDVE5   ( AInd: integer ): Pointer;
  function  InitMLParams  ( AMLType: TN_MLType ): TN_PCMapLayer;
  function  ItemInvisible ( AItemInd: integer ): boolean;

  procedure DrawLayer  ( BegItem: integer = 0; EndItem: integer = -1 );
  procedure DrawPoints ( BegItem, EndItem: integer );
  procedure DrawLines  ( BegItem, EndItem: integer );
  procedure DrawConts  ( BegItem, EndItem: integer );
  procedure DrawLabels ( BegItem, EndItem: integer );
  procedure AddHTMLMapAttribs ( AItemInd: integer );
  procedure AddPixCoords      ( APFCoords: PFPoint; APDCoords: PDPoint; ANumPoints: integer ); overload;
  procedure AddPixCoords      ( AFPArray: TN_FPArray; ADPArray: TN_DPArray ); overload;
//  procedure DrawTextBoxes  ( BegItem, EndItem: integer );
//  procedure CreateTBLayers ( BegItem, EndItem: integer );
  procedure DrawPointsToSVG ();
  procedure DrawPointsToVML ();
  procedure DrawLinesToSVG  ();
  procedure DrawContsToSVG  ();
  procedure DrawHorLabelsToSVG ();
  procedure DrawLayerToText ();
end; // type TN_UDMapLayer = class( TN_UDCompVis )

type TN_MarkedCObjPart = record //
  MCObj: TN_UCObjLayer;
  MItem: integer;
  MPart: integer;
end; // type TN_MarkedCObjPart = record
type TN_MarkedCObjParts = array of TN_MarkedCObjPart;

type TN_SGMLayers = class( TN_SGComp ) //***** Search Group for MapLayers
  CurMapLayer:  TN_UDMapLayer; // same as CurSComp if it is TN_UDMapLayer
  CurMLCObj:    TN_UCObjLayer; // MLCobj in CurMapLayer
  PCMapLayer:   TN_PCMapLayer; // same as CurCMapLayer.PISP^
  PosInfo: TN_PointInContInfo; // set in SearchInConts()
  SpecialCObjPtr: Pointer;
  MarkedCObjParts: TN_MarkedCObjParts;

  constructor Create  ( ARFrame: TN_Rast1Frame );
  destructor  Destroy (); override;
  function  SearchInCurComp (): boolean; override;
  function  SearchInPoints  (): boolean;
  function  SearchInLines   (): boolean;
  function  SearchInConts   (): boolean;
  function  SnapToCurCObj   ( ASnapMode: integer; const InpPoint: TDPoint;
                                              out OutPoint: TDPoint ): integer;
  procedure SplitByPoint    ( ASplitMode: integer; const SplitPoint: TDPoint );
end; // type TN_SGMLayers = class( TN_SGComp )

type TN_RFAShowUserInfo = class( TN_RFrameAction ) //*** Show User Info about CObj
  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAShowUserInfo = class( TN_RFrameAction )


//****************** Global procedures **********************

function  N_CreateUDMapLayer ( ACObjLayer: TN_UCObjLayer;
                               AMLType: TN_MLType = mltNotDef ): TN_UDMapLayer;
function  N_CalcMapEnvRect   ( AMapRoot: TN_UDCompVis; ACoef: double; AMapLayer: TN_UDMapLayer = nil ): TFRect;
procedure N_PrepareMap1      ( ASrcUObjDir, ADstUObjDir, AMapRoot: TN_UDBase );
procedure N_AddCompsToSearch ( ARFrame: TN_Rast1Frame; APFirstComp: TN_PUDCompVis;
                                                       ANumComps: integer );
procedure N_AddCompToSearch  ( ARFrame: TN_Rast1Frame; AComp: TN_UDCompVis;
                   ASearchFlags, APixSearchSize: integer; AUserSearchSize: float );


var
  N_DefLabel: string = 'NotDef';
  N_ML: TN_CMapLayer;

const
       // Child Indexes in PainTextBoxes and Legend DataRoot:
  N_TBTokens     =  0; // TBTokens     - UDRArray with Tokens (RArray of strings)
  N_TBTFonts     =  1; // TBTFonts     - UDRArray with Token Fonts (TN_UDLogFont)
  N_TBTPoints    =  2; // TBTPoints    - UDPoints with Tokens Base Points Coords
  N_MTBTokens    =  3; // MTBTokens    - UDMapLayer for drawing Tokens

  N_ULegColors   =  4; // ULegColors   - UDRArray with Sign Rect Colors
  N_ULegRects    =  5; // ULegRects    - ULines with Filled Sign Rects
  N_ULegDashes   =  6; // ULegDashes   - ULines with Sign Dashes
  N_MLegRects    =  7; // MLegRects    - UDMapLayer for Sign Rects
  N_MLegDashes   =  8; // MLegDashes   - UDMapLayer for Sign Dashes

implementation
uses SysUtils, StrUtils, math,
     K_DCSpace, K_VFunc,
     N_Lib0, N_ClassRef, N_ME1, N_Comp1, N_GCont,
     N_MemoF, N_InfoF;

{
//*************************************** TN_UDCMapLayer.DrawPointsToSVG ***
// Draw Points To SVG
//
procedure TN_UDCMapLayer.DrawPointsToSVG();
var
  iItem, j, FirstInd, NumInds: integer;
  PDVE: Pointer;
  CL: TN_UDPoints;
  LLWUSize: float;
  FillAttr, SSizeAttr: string;
  IndividualColor: boolean;
  SVGUC: TDPoint;
begin
  with SetPCMapLayer()^, MLGC.DrawContext do
  begin
    CL := TN_UDPoints(MLCObj);
    Assert( CL.CI = N_UDPointsCI, 'Bad CL' );
    IdPref := ObjName;
    LLWUSize := MLSSizeXY.X*LLWU;

    if MLDVect1 <> nil then // Individual Fill Colors
    begin
      IndividualColor := True;
      FillAttr := '>';
    end else // Group Fill Color
    begin
      IndividualColor := False;
      FillAttr := SVGFillColor + '>';
    end;

    if MLSSizeXY.X <> -1 then // not Individual Sign Sizes
      SSizeAttr := Format( ' r="%.*f"', [OutAccuracy, LLWUSize] );

    GCOutSL.Add( '  <g' + SVGIdObjName + SVGPenColor + SVGPenWidth + FillAttr );

  for iItem := 0 to CL.WNumItems-1 do //***** loop along all Points Groups in Layer
  begin

    if ItemInvisible( iItem ) then Continue; // skip Invisible Items

    CL.GetItemInds( iItem, FirstInd, NumInds ); // NumInds is Num Elems in Group
    if NumInds = 0 then Continue; // skip empty items

    for j := FirstInd to FirstInd+NumInds-1 do // along Points in Group
    begin

      FillAttr := '';
      if IndividualColor then // BrushColors are given in MLDVect1
      begin
        PDVE := PDVE1( iItem );
        if PDVE <> nil then
          FillAttr := ' fill=' + N_ColorToQHTMLHex( PInteger(PDVE)^ );
      end;

      if LLWUSize < 0 then // Individual Sign Sizes are given in MLDVect3
      begin
        PDVE := PDVE3( iItem );
        if PDVE = nil then
          SSizeAttr := Format( ' r="%.*f"', [ OutAccuracy, 5 ] ) // 5 is def value
        else
          SSizeAttr := Format( ' r="%.*f"', [ OutAccuracy, PFloat(PDVE)^*LLWU ]);
      end;

      SVGUC := N_AffConvD2DPoint( CL.CCoords[j], AffCoefs ); // SVG User Coords
      GCOutSL.Add( Format( '    <circle id="%s" cx="%.*f" cy="%.*f" %s %s />',
                    [ IdPref+IntToStr(iItem), OutAccuracy, SVGUC.X,
                      OutAccuracy, SVGUC.Y, SSizeAttr, FillAttr ] ));

    end; // for j := FirstInd to FirstInd+NumInds-1 do

    GCOutSLBuf.Flash();
  end; // for iItem := 0 to CL.WNumItems-1 do // loop along all Points in Layer

  GCOutSL.Add( '  </g>' );
  end; // SetPCMapLayer()^, MLGC.DrawContext do
end; // end of procedure TN_UDCMapLayer.DrawPointsToSVG

//*************************************** TN_UDCMapLayer.DrawLinesToSVG ***
// Draw Lines To SVG
//
procedure TN_UDCMapLayer.DrawLinesToSVG();
var
  iItem, iPart, FirstInd, NumInds, NumParts: integer;
  PDVE: Pointer;
  CL: TN_ULines;
  MemPtr: TN_BytesPtr;
  IndPenColorS: string;
begin
  with SetPCMapLayer()^, MLGC.DrawContext do
  begin
  CL := TN_ULines(MLCObj);
  Assert( CL.CI = N_ULinesCI, 'Bad CL' );
  IdPref := ObjName;

  GCOutSL.Add( '  <g id="' + ObjName +
    '" fill="none"' + SVGPenWidth + SVGPenColor + '>' );

  for iItem := 0 to CL.WNumItems-1 do //***** loop along all Lines in Layer
  begin

    if ItemInvisible( iItem ) then Continue; // skip Invisible Items
    CL.GetNumParts( iItem, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    if MLDVect2 <> nil then // Individual PenColors in MLDVect2
    begin
      PDVE := PDVE2( iItem );
      if PDVE = nil then
        IndPenColorS := ''
      else
        IndPenColorS := ' stroke=' + N_ColorToQHTMLHex( PInteger(PDVE)^ );
    end;

    GCOutSL.Add( '    <path id="'+IdPref+IntToStr(iItem) + IndPenColorS + '" d="' );

    for iPart := 0 to NumParts-1 do //***** loop along all Line Parts
    begin
      CL.GetPartInds( MemPtr, iPart, FirstInd, NumInds );

//      if CL.WLCType = N_FloatCoords then
//        N_AddFLineToSvg( GCOutSLBuf, @CL.LFCoords[FirstInd], AffCoefs, NumInds, OutAccuracy )
//      else
//        N_AddDLineToSvg( GCOutSLBuf, @CL.LDCoords[FirstInd], AffCoefs, NumInds, OutAccuracy )

    end; // for iPart := 0 to NumParts-1 do //***** loop along all Line Parts

    GCOutSLBuf.AddToken( '"/>'); // close d attribute and path tag
    GCOutSLBuf.Flash();
  end; // for iItem := 0 to CL.WNumItems-1 do // loop along all contours in Layer

  GCOutSL.Add( '  </g>' );
  end; // with SetPCMapLayer()^, MLGC.DrawContext do
end; // end of procedure TN_UDCMapLayer.DrawLinesToSVG

//*************************************** TN_UDCMapLayer.DrawContsToSVG ***
// Draw Conts To SVG
//
procedure TN_UDCMapLayer.DrawContsToSVG();
var
  iItem, iRing, FRInd, NumRings: integer;
  PDVE: Pointer;
  FillAttr: string;
  CL: TN_UContours;
  IndividualColor: boolean;
begin
  with SetPCMapLayer()^, MLGC.DrawContext do
  begin

  if MLType <> mltConts1 then Exit;

  CL := TN_UContours(MLCObj);
  Assert( CL.CI = N_UContoursCI, 'Bad CL' );
  CL.MakeRingsCoords();
  IdPref := ObjName;

  if MLDVect1 <> nil then // Individual Fill Colors
  begin
    IndividualColor := True;
    FillAttr := '>';
  end else // Group Fill Color
  begin
    IndividualColor := False;
    FillAttr := SVGFillColor + '>';
  end;

  GCOutSL.Add( '  <g id="' + ObjName + '"' +
                                     SVGPenWidth + SVGPenColor + FillAttr );

  for iItem := 0 to CL.WNumItems-1 do //***** loop along all contours in Layer
  begin

    if ItemInvisible( iItem ) then Continue; // skip Invisible Items
    CL.GetItemInds( iItem, FRInd, NumRings );
    if NumRings = 0 then Continue; // skip empty items

    FillAttr := '';
    if IndividualColor then // BrushColors are given in MLDVect1
    begin
      PDVE := PDVE1( iItem );
      if PDVE <> nil then
        FillAttr := ' fill=' + N_ColorToQHTMLHex( PInteger(PDVE)^ );
    end;

    GCOutSL.Add( '    <path id="'+IdPref+IntToStr(iItem) + '"' +
                                                    FillAttr + ' d="' );

    for iRing := FRInd to FRInd+NumRings-1 do //***** loop along all Rings
    with CL.CRings[iRing] do
    begin
//      if RFCoords <> nil then
//        N_AddFLineToSvg( GCOutSLBuf, @RFCoords[0], AffCoefs, Length(RFCoords), OutAccuracy )
//      else
//        N_AddDLineToSvg( GCOutSLBuf, @RDCoords[0], AffCoefs, Length(RDCoords), OutAccuracy )
    end; // for iRing := FRInd to FRInd+NumRings-1 do //***** loop along all Rings

    GCOutSLBuf.AddToken( 'z"/>'); // close d attribute and path tag (z is needed for Corel!)
    GCOutSLBuf.Flash();
  end; // for iItem := 0 to CL.WNumItems-1 do // loop along all contours in Layer

  GCOutSL.Add( '  </g>' );
  end; // with SetPCMapLayer()^, MLGC.DrawContext do
end; // end of procedure TN_UDCMapLayer.DrawContsToSVG

//*************************************** TN_UDCMapLayer.DrawHorLabelsToSVG ***
// Draw Horizontal Labels To SVG
//
procedure TN_UDCMapLayer.DrawHorLabelsToSVG();
var
  iItem, j, FirstInd, NumInds, Dx, Dy: integer;
  PDVE: Pointer;
  CL: TN_UDPoints;
  Str, SVGStr, FDescr: string;
  SVGUC: TDPoint;
  ShiftXY: TFPoint;
  LogFont: TN_UDLogFont;
  FontSize: float;
begin
  with SetPCMapLayer()^, MLGC.DrawContext do
  begin

  if MLType <> mltHorLabels then Exit;

  CL := TN_UDPoints(MLCObj);
  Assert( CL.CI = N_UDPointsCI, 'Bad CL' );
  IdPref := ObjName;

  if MLAux1 = nil then
    LogFont := TN_UDLogFont(N_GetUObj( N_LogFontsDir, 'DefFont' ))
  else
    LogFont := TN_UDLogFont(MLAux1);

    with TN_PLogFont(LogFont.R.P)^ do
  begin
    FDescr := '';
    if lfsBold in LFStyle then FDescr := ' font-weight="bold"';
    if lfsItalic in LFStyle then FDescr := FDescr + ' font-style="italic"';

    FontSize := LFHeight*LLWU;
    GCOutSL.Add( '  <g' + SVGIdObjName + SVGFillColor +
               Format( ' font-family="%s" font-size="%.*f" %s>',
               [LFFaceName, OutAccuracy, FontSize, FDescr] ) );
  end;

  LogFont.SetFont( DstOCanv );

  for iItem := 0 to CL.WNumItems-1 do //***** loop along all Points Groups in Layer
  begin

    if ItemInvisible( iItem ) then Continue; // skip Invisible Items
    CL.GetItemInds( iItem, FirstInd, NumInds ); // NumInds is Num Elems in Group
    if NumInds = 0 then Continue; // skip empty items

    PDVE := PDVE1( iItem ); // get Labels text
    if PDVE = nil then PDVE := @N_DefLabel;
    Str := PString(PDVE)^;

    if TextEncoding = 'utf-8' then
      SVGStr := N_UTF8( Str );

    PDVE := PDVE2( iItem ); // get Labels Shift in LLW
    if PDVE = nil then
      ShiftXY := N_ZFPoint // Zero Shifts
    else
      ShiftXY := PFPoint(PDVE)^;

    for j := FirstInd to FirstInd+NumInds-1 do // along Points in Group
    begin
      DstOCanv.GetStringSize( Str, Dx, Dy );
      SVGUC := N_AffConvD2DPoint( CL.CCoords[j], AffCoefs ); // SVG User Coords

      SVGUC.X := SVGUC.X + ShiftXY.X*LLWU - MLHotPoint.X*Dx/DstOCanv.LLWPixSize;
      SVGUC.Y := SVGUC.Y + ShiftXY.Y*LLWU - MLHotPoint.Y*FontSize + 0.75*FontSize;

      GCOutSL.Add( Format( '    <text id="%s" x="%.*f" y="%.*f">%s</text>',
                         [ IdPref+IntToStr(iItem), OutAccuracy, SVGUC.X,
                                             OutAccuracy, SVGUC.Y, SVGStr ] ));
    end; // for j := FirstInd to FirstInd+NumInds-1 do

    GCOutSLBuf.Flash();
  end; // for iItem := 0 to CL.WNumItems-1 do // loop along all Points in Layer

  GCOutSL.Add( '  </g>' );
  end; // with SetPCMapLayer()^, MLGC.DrawContext do
end; // end of procedure TN_UDCMapLayer.DrawHorLabelsToSVG

//************************************ TN_UDCMapLayer.DrawLayerToText ***
// Draw Self To Text (to StringList in SVG Context)
//
procedure TN_UDCMapLayer.DrawLayerToText();
var
  i, CSInd: integer;
  idName: string;
  CS: TK_UDDCSpace;
  BP: TFPoint;
begin
  with SetPCMapLayer()^ do
  begin
    if (MLType = mltPoints1) or (MLType = mltHorLabels) then
    with  MLGC.DrawContext do
    begin
      GCOutSL.Add( '***** Map Layer ' + ObjName );
      GCOutSL.Add( 'MLType=' + IntToStr(ord(MLType)) );
      GCOutSL.Add( 'NumItems=' + IntToStr(MLCObj.WNumItems) );
      GCOutSL.Add( 'MLCObjName=' + MLCObj.ObjName );
      GCOutSL.Add( 'MLCObjEnvRect=' + N_RectToStr( MLCObj.WEnvRect, 0 ) );

      BP := MLCObj.WEnvRect.TopLeft;
      BP.X := BP.X - 20; // debug for SocDemPrint Map
      BP.Y := BP.Y - 40; // debug
      GCOutSL.Add( 'TmpBP=' + N_PointToStr( BP, 0 ) );
      BP := FPoint(0,0);

      GCOutSL.Add( Format( 'TmpWidth=%.0f  TmpHeight=%.0f',
                        [ N_RectWidth(MLCObj.WEnvRect)+40,
                          N_RectHeight(MLCObj.WEnvRect)+40 ] ));

      GCOutSL.Add( '' );
      CS := MLCObj.GetCS();

      for i := 0 to MLCObj.WNumItems-1 do // along all Items
      with TN_UDPoints(MLCObj) do
      begin
        idName := '';
        if CS <> nil then
        begin
          CSInd := MLCObj.GetCSInd( i, 0 );
          idName := PString(TK_PDCSpace(CS.R.P)^.Names.P(CSInd))^;
        end;

        GCOutSL.Add( Format( 'ind=%d id=%d X=%.0f Y=%.0f idName=%s',
                            [i, Items[i].CCode, CCoords[i].X-BP.X,
                                                CCoords[i].Y-BP.Y, idName] ));

        if MLType = mltHorLabels then
          GCOutSL.Add( 'Label="' + PString(TK_UDRArray(MLDVect1).DP(i))^ + '"' );

      end; // for i := 0 to MLCObj.WNumItems do // along Items

      GCOutSL.Add( '' );
    end; // with  MLGC.DrawContext do, if (MLType = mltPoints1) or (MLType = mltHorLabels) then
  end; // with SetPCMapLayer()^ do
end; // end_of procedure TN_UDCMapLayer.DrawLayerToText
}


//********** TN_UDMapLayer class methods  **************

//**************************************************** TN_UDMapLayer.Create ***
//
constructor TN_UDMapLayer.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDMapLayerCI;
  ImgInd := 39;
end; // end_of constructor TN_UDMapLayer.Create

//*************************************************** TN_UDMapLayer.Destroy ***
//
destructor TN_UDMapLayer.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDMapLayer.Destroy

//******************************************************* TN_UDMapLayer.PSP ***
// Return typed pointer to all Static Params
//
function TN_UDMapLayer.PSP(): TN_PRMapLayer;
begin
  Result := TN_PRMapLayer(R.P());
end; // end_of function TN_UDMapLayer.PSP

//******************************************************* TN_UDMapLayer.PDP ***
// Return typed pointer to all Dynamic Params if they exist,
// otherwise Return typed pointer to all Static params
//
function TN_UDMapLayer.PDP(): TN_PRMapLayer;
begin
  if DynPar <> nil then Result := TN_PRMapLayer(DynPar.P())
                   else Result := TN_PRMapLayer(R.P());
end; // end_of function TN_UDMapLayer.PDP

//****************************************************** TN_UDMapLayer.PISP ***
// return typed pointer to Individual Static MapLayer Params
//
function TN_UDMapLayer.PISP(): TN_PCMapLayer;
begin
  Result := @(TN_PRMapLayer(R.P())^.CMapLayer);
end; // function TN_UDMapLayer.PISP

//****************************************************** TN_UDMapLayer.PIDP ***
// return typed pointer to Individual Dynamic MapLayer Params
// and set PCMapLayer field to it
//
function TN_UDMapLayer.PIDP(): TN_PCMapLayer;
begin
  PCMapLayer := @PDP()^.CMapLayer;
  Result := PCMapLayer;
end; // function TN_UDMapLayer.PIDP

//************************************************ TN_UDMapLayer.PascalInit ***
// Init self (is called from K_CreateUDComp)
//
procedure TN_UDMapLayer.PascalInit();
begin
  inherited;

  with PISP()^ do
  begin
    MLVisible := mlvNormal;
//    MLFSCoef  := 1;
  end;

  with PCCS()^ do
  begin
    BPXCoordsType := cbpPercent;
    BPYCoordsType := cbpPercent;

    SRSize := FPoint( 100, 100 );
    SRSizeXType := cstPercentP;
    SRSizeYType := cstPercentP;

    UCoordsType := cutParent;
  end;
end; // procedure TN_UDMapLayer.PascalInit

//********************************************** TN_UDMapLayer.SetIconIndex ***
// Set Icon Index by MLType
//
procedure TN_UDMapLayer.SetIconIndex();
begin
  case PISP()^.MLType of
  mltNotDef:       ImgInd := 39;
  mltPoints1:      ImgInd := 4;
  mltLines1:       ImgInd := 5;
  mltConts1:       ImgInd := 6;
  mltHorLabels:    ImgInd := 7;
  mltLineLabels:   ImgInd := 45;
  mltCurveLabels:  ImgInd := 8;
  mltComponents:   ImgInd := 43;
  end;
end; // procedure TN_UDMapLayer.SetIconIndex

//********************************************** TN_UDMapLayer.BeforeAction ***
// Draw Self, is called from VCTree interpreter
// (Component method which will be called just before childrens ExecSubtree method)
//
procedure TN_UDMapLayer.BeforeAction();
begin
//  N_s := ObjName;  // debug
//  N_ML := PIDP()^; // debug
  PCMapLayer := PIDP();
  DrawLayer();
end; // end_of procedure TN_UDMapLayer.BeforeAction

//***************************************** TN_UDMapLayer.ClearReIndVectors ***
// Clear all ReIndexing Vectors (MLReIndVect1-5, MLReIndVectVis) and
// MLVisPtrs - array of Pointers to Visibility Bytes in Data Vector
//
procedure TN_UDMapLayer.ClearReIndVectors();
begin
  MLItemsSCodes := nil;
  MLVisPtrs     := nil;

  MLReIndVectVis := nil;
  MLReIndVect1   := nil;
  MLReIndVect2   := nil;
  MLReIndVect3   := nil;
  MLReIndVect4   := nil;
  MLReIndVect5   := nil;
end; // procedure TN_UDMapLayer.ClearReIndVectors

//******************************************* TN_UDMapLayer.SetReIndVectors ***
// Set ReIndexing vectors (MLReIndVect(1-5)) and
// array of Pointers to Visibility Bytes in Data Vector
// if they are not already set.
//
// SetReIndVectors is called before each drawing.
//
procedure TN_UDMapLayer.SetReIndVectors();
var
  i, j, ICode, DataInd, NumItems, NumCodes,MinCode, MaxCode: Integer;
  IndOrCode, WrkCDimInd, WrkCode, NumRestCodes: integer;
  ItemIsVisible, AllItemsVisible: boolean;
  PIntCode: PInteger;
  PVisByte: PByte;
  TmpReIndVector: TN_IArray;
  TmpSCodes: TN_SArray;

  procedure SetOneReIndVect( var AReIndVect: TN_IArray; ADVect: TK_UDRArray ); // local
  // create if needed given ReIndex Vector for given Data Vector
  begin
    if ADVect = nil then Exit; // not needed
    if not (ADVect is TK_UDVector) then  Exit; // not needed
    if (AReIndVect <> nil) then Exit; // is already OK

    SetLength( AReIndVect, NumItems );
    K_BuildDataProjectionBySCodes( @AReIndVect[0], TK_UDVector(ADVect),
              @MLItemsSCodes[0], NumItems );

  end; // procedure SetOneReIndVect (local)

  function GetVisPtr( AIndOrCode: integer ): PByte; // (local)
  // Return Pointer to "Item is Visible" byte in MLVAVisBytes VArray
  // using given AIndOrCode (Item Index or Item Code) or
  // return pointer to N_ByteAllOnes if there is no element in MLVAVisBytes for given code

  begin
    with PCMapLayer^ do
    begin
      if TmpReIndVector = nil then // use AIndOrCode as direct Index of MLVAVisBytes vector
      begin
        DataInd := AIndOrCode
      end else // TmpReIndVector <> nil, AIndOrCode is Code, convert Code to UDVector Index
      begin
        if AIndOrCode = -1 then // Item has no codes, return pointer to N_ByteAllOnes
          DataInd := -1
        else // noraml Code, AIndOrCode-MinCode should be always in TmpReIndVector range
          DataInd := TmpReIndVector[AIndOrCode-MinCode];
      end;

      Result := PByte(N_PVAE( MLVAVisBytes, DataInd ));

      if Result = nil then // DataInd may be -1 or out of MLVAVisBytes range, treat as "Visible"
        Result := @N_ByteAllOnes;
    end; // with PCMapLayer^ do
  end; // function GetVisPtr (local)

begin //************************ main body of TN_UDMapLayer.SetReIndVectors
  with PCMapLayer^ do
  begin
//    N_s1 := Self.ObjName;   // debug
//    N_s2 := MLCObj.ObjName; // debug
//    N_s  := MLCObj.WItemsCSName; // debug

    if (MLFlags and $06) <> 0 then ClearReIndVectors(); // for recalculating ReIndVectors
    if (MLFlags and $02) = 0 then MLFlags := MLFlags and $FFFFFFFE; // clear bit0 if bit1=0

    NumItems := MLCObj.WNumItems;

    if MLCObj.WItemsCSObj = nil then // try to define MLCObj.WItemsCSObj, it can be not given
      MLCObj.WItemsCSObj := MLCObj.GetCS( MLCDimInd );

    //*** build MLItemsSCodes if not yet (do it only once and if WItemsCSObj <> nil)

    if (MLCObj.WItemsCSObj <> nil) and (MLItemsSCodes = nil) then
    begin
      SetLength( MLItemsSCodes, NumItems );

      for i := 0 to NumItems-1 do
      begin
        ICode := MLCObj.GetItemFirstCode( i, MLCDimInd );
        if ICode <> -1 then
          MLItemsSCodes[i] := IntToStr( ICode );
      end; // for i := 0 to NumItems-1 do
    end; // if (MLCObj.WItemsCS <> nil) and (MLItemsSCodes = nil) then // build MLItemsSCodes only once


    //***** MLCObj.WItemsCSObj and MLItemsSCodes are OK,
    //      Create MLVisPtrs if needed

    if MLVisPtrs = nil then // not Created yet, create MLVisPtrs if needed
    begin
      AllItemsVisible := False;

      if MLVAVisBytes <> nil then // MLVAVisBytes exists, creating MLVisPtrs is needed
      begin
        SetLength( MLVisPtrs, NumItems );

        //*** Check if TmpReIndVector should be calculated and used
        //    TmpReIndVector is parallel to Code Values with MinCode base,
        //    all other ReindVectors are parallel to Items!

        TmpReIndVector := nil;

        if (MLVAVisBytes is TK_UDVector) and
           (MLCObj.WItemsCSObj <> nil)   and
           ((MLFlags and $02) = 0)         then // TmpReIndVector is needed, calculate it
        begin
          //*** Prepare TmpCodesStr - all possible Codes as Strings

          MLCObj.GetCDimMinMaxCodes( MLCDimInd, MinCode, MaxCode );
          NumCodes := MaxCode - MinCode + 1;

          if (NumCodes > 0) and (MinCode <> N_MaxInteger) and (MaxCode <> -1) then // at least one code exists
          begin
            SetLength( TmpSCodes, NumCodes );
            SetLength( TmpReIndVector, NumCodes );

            for i := 0 to High(TmpSCodes) do
              TmpSCodes[i] := IntToStr( i + MinCode );

            K_BuildDataProjectionBySCodes( @TmpReIndVector[0], TK_UDVector(MLVAVisBytes),
                                           @TmpSCodes[0], NumCodes );
          end else // all Items do not have codes, show all Items
            AllItemsVisible := True;
        end; // if ... then // calc TmpReIndVector

        if not (MLVAVisBytes is TK_UDVector) or (MLCObj.WItemsCSObj = nil) then
          MLFlags := MLFlags and $FFFFFFEF; // clear bit4($010), a precaution

        N_i := MLFlags;

        if ((MLFlags and $010) = 0) then // check only one elem of MLVAVisBytes
        begin //    obtained by Item Index or Item's first code in MLCDimInd CS
          IndOrCode := -1; // to avoid warning

          for i := 0 to NumItems-1 do // set MLVisPtrs Pointers for all Items
            begin
              if AllItemsVisible then
              begin
                MLVisPtrs[i] := @N_ByteAllOnes; // Item is Visible
                Continue;
              end else if TmpReIndVector <> nil then // always use First Code
                IndOrCode := MLCObj.GetItemFirstCode( i, MLCDimInd )
              else // TmpReIndVector = nil, check Bit0 of MLFlags
              begin
                if (MLFlags and $01) = 0 then
                  IndOrCode := i // use Item Index, not use First Code
                else //************ use First Code as Index, without reindexing
                  IndOrCode := MLCObj.GetItemFirstCode( i, MLCDimInd );
              end; // else // TmpReIndVector = nil, check Bit0 of MLFlags

            MLVisPtrs[i] := TN_PByte(GetVisPtr( IndOrCode )); // GetVisPtr never returns nil
          end; // for i := 0 to NumItems-1 do // set MLVisPtrs Pointers for all Items

        end else // bit4($010) is set, check MLVAVisBytes elems for all codes in MLCDimInd
        begin    // (may be this functionality is not needed!)

          for i := 0 to NumItems-1 do // set MLVisPtrs Pointers for all Items
          begin
            PIntCode := MLCObj.GetPtrToFirstCode( i, MLCDimInd, NumRestCodes );

            if NumRestCodes = 0 then // Item has no codes in all CDims, treat as "should be Visible"
              ItemIsVisible := True
            else //******************** Set initial value as Invisible
              ItemIsVisible := False;

            for j := 1 to NumRestCodes do // Along all Rest IntCodes
            begin
              N_DecodeCObjCodeInt( PIntCode^, WrkCDimInd, WrkCode );
              if WrkCDimInd <> MLCDimInd then // no more Codes in MLCDimInd
              begin
                if j = 1 then // Item has no codes in MLCDimInd, treat as "should be Visible"
                  ItemIsVisible := True;
                Break; // final value of ItemIsVisible is OK
              end;

              PVisByte := GetVisPtr( WrkCode ); // GetVisPtr never returns nil
              if PVisByte^ <> 0 then // PVisByte^ <> 0 means "should be Visible"
                ItemIsVisible := True;
            end; // for j := 1 to NumRestCodes do // Along all Rest IntCodes

            if ItemIsVisible then MLVisPtrs[i] := @N_ByteAllOnes
                             else MLVisPtrs[i] := @N_ByteAllZeros;
          end; // for i := 0 to NumItems-1 do // set MLVisPtrs Pointers for all Items

        end; // else // check MLVAVisBytes elems for all codes in MLCDimInd

      end; // if MLVAVisBytes <> nil then // MLVAVisBytes exists, creating MLVisPtrs is needed
    end; // if MLVisPtrs = nil then // not Created yet, create MLVisPtrs if needed


    //***** MLVisPtrs was created if needed,
    //      Create (if needed) MLReIndVect(1-5)

    if MLCObj.WItemsCSObj = nil then Exit; // Setting MLReIndVect(1-5) is not needed

    SetOneReIndVect( MLReIndVect1, MLDVect1 );
    SetOneReIndVect( MLReIndVect2, MLDVect2 );
    SetOneReIndVect( MLReIndVect3, MLDVect3 );
    SetOneReIndVect( MLReIndVect4, MLDVect4 );
    SetOneReIndVect( MLReIndVect5, MLDVect5 );

  end; // with PCMapLayer^ do
end; // end_of procedure TN_UDMapLayer.SetReIndVectors

//******************************************** TN_UDMapLayer.CreateAUPDRefs ***
// Create and Return Array of Pointers to all Self <> nil TN_UDBase fields
// and, if MLCObj is UContours, MLCObj's ULines child (not pointer to it!)
//
function TN_UDMapLayer.CreateAPUDRefs(): TN_PUDArray;
var
  Ind: integer;
begin
  SetLength( Result, 20 ); // 18 is max possible value
  Ind := 0;

  with PISP()^ do
  begin
    if MLCObj <> nil then
    begin
      Result[Ind] := TN_PUDBase(@MLCObj);
      Inc( Ind );

      if MLCObj is TN_UContours then // add Ref to ULines
      begin
        Result[Ind] := TN_PUDBase(MLCObj.DirChild( N_CObjLinesChildInd )); // UObj, not Pointer to UObj!
        Inc( Ind );
      end; // if MLCObj is TN_UDContours then // add Ref to ULines
    end; // if MLCObj <> nil then

    if MLDVect1 <> nil then begin Result[Ind] := TN_PUDBase(@MLDVect1); Inc( Ind ); end;
    if MLDVect2 <> nil then begin Result[Ind] := TN_PUDBase(@MLDVect2); Inc( Ind ); end;
    if MLDVect3 <> nil then begin Result[Ind] := TN_PUDBase(@MLDVect3); Inc( Ind ); end;
    if MLDVect4 <> nil then begin Result[Ind] := TN_PUDBase(@MLDVect4); Inc( Ind ); end;
    if MLDVect5 <> nil then begin Result[Ind] := TN_PUDBase(@MLDVect5); Inc( Ind ); end;

    if MLAux1   <> nil then begin Result[Ind] := TN_PUDBase(@MLAux1);   Inc( Ind ); end;
    if MLAux2   <> nil then begin Result[Ind] := TN_PUDBase(@MLAux2);   Inc( Ind ); end;
    if MLAux3   <> nil then begin Result[Ind] := TN_PUDBase(@MLAux3);   Inc( Ind ); end;

    if MLVArray1 is TN_UDBase then begin Result[Ind] := TN_PUDBase(@MLVArray1); Inc( Ind ); end;
    if MLVArray2 is TN_UDBase then begin Result[Ind] := TN_PUDBase(@MLVArray2); Inc( Ind ); end;
    if MLVArray3 is TN_UDBase then begin Result[Ind] := TN_PUDBase(@MLVArray3); Inc( Ind ); end;
    if MLVArray4 is TN_UDBase then begin Result[Ind] := TN_PUDBase(@MLVArray4); Inc( Ind ); end;
    if MLVArray5 is TN_UDBase then begin Result[Ind] := TN_PUDBase(@MLVArray5); Inc( Ind ); end;

    if MLVAux1   is TN_UDBase then begin Result[Ind] := TN_PUDBase(@MLVAux1);   Inc( Ind ); end;
    if MLVAux2   is TN_UDBase then begin Result[Ind] := TN_PUDBase(@MLVAux2);   Inc( Ind ); end;
    if MLVAux3   is TN_UDBase then begin Result[Ind] := TN_PUDBase(@MLVAux3);   Inc( Ind ); end;
  end; // with PISP()^ do

  SetLength( Result, Ind ); // real value
end; // end_of function TN_UDMapLayer.CreateAPUDRefs

//***************************************************** TN_UDMapLayer.PDVE1 ***
// Return untyped Pointer to AInd-th MLDVect1 Element or nil
//
function TN_UDMapLayer.PDVE1( AInd: integer ): Pointer;
var
  ReInd: integer;
begin
  Result := nil;
  with PCMapLayer^ do
  begin
    if (MLDVect1 = nil) or (AInd = -1) then Exit; // no Data Vector or no Index

    if (MLReIndVect1 = nil) or ((MLFlags and $02) <> 0) then // use Item Index
    begin // do not use ReIndVector, use ItemInd or first code in MLCDimInd CS
      if ((MLFlags and $01) <> 0) then
//        ReInd := MLCObj.Items[AInd].CCode
//        MLCObj.GetItemTwoCodes( AInd, 0, ReInd, N_i )
        ReInd := MLCObj.GetItemFirstCode( AInd, MLCDimInd )
      else
        ReInd := AInd;
    end else // use ReIndVector
      ReInd := MLReIndVect1[AInd];

    if ReInd = -1 then Exit; // no Element in Data Vector
    Result := MLDVect1.PDE( ReInd );

  end; // with SetPCMapLayer()^ do
end; // function TN_UDMapLayer.PDVE1

//***************************************************** TN_UDMapLayer.PDVE2 ***
// Return untyped Pointer to AInd-th MLDVect2 Element or nil
//
function TN_UDMapLayer.PDVE2( AInd: integer ): Pointer;
var
  ReInd: integer;
begin
  Result := nil;
  with PCMapLayer^ do
  begin
    if (MLDVect2 = nil) or (AInd = -1) then Exit; // no Data Vector or no Index

    if (MLReIndVect2 = nil) or ((MLFlags and $02) <> 0) then // use Item Index
    begin // do not use ReIndVector, use ItemInd or first code in MLCDimInd CS
      if ((MLFlags and $01) <> 0) then
//        ReInd := MLCObj.Items[AInd].CCode
//        MLCObj.GetItemTwoCodes( AInd, 0, ReInd, N_i )
        ReInd := MLCObj.GetItemFirstCode( AInd, MLCDimInd )
      else
        ReInd := AInd;
    end else // use ReIndVector
      ReInd := MLReIndVect2[AInd];

    if ReInd = -1 then Exit; // no Element in Data Vector
    Result := MLDVect2.PDE( ReInd );

  end; // with SetPCMapLayer()^ do
end; // function TN_UDMapLayer.PDVE2

//***************************************************** TN_UDMapLayer.PDVE3 ***
// Return untyped Pointer to AInd-th MLDVect3 Element or nil
//
function TN_UDMapLayer.PDVE3( AInd: integer ): Pointer;
var
  ReInd: integer;
begin
  Result := nil;
  with PCMapLayer^ do
  begin
    if (MLDVect3 = nil) or (AInd = -1) then Exit; // no Data Vector or no Index

    if (MLReIndVect3 = nil) or ((MLFlags and $02) <> 0) then // use Item Index
    begin // do not use ReIndVector, use ItemInd or first code in MLCDimInd CS
      if ((MLFlags and $01) <> 0) then
//        ReInd := MLCObj.Items[AInd].CCode
//        MLCObj.GetItemTwoCodes( AInd, 0, ReInd, N_i )
        ReInd := MLCObj.GetItemFirstCode( AInd, MLCDimInd )
      else
        ReInd := AInd;
    end else // use ReIndVector
      ReInd := MLReIndVect3[AInd];

    if ReInd = -1 then Exit; // no Element in Data Vector
    Result := MLDVect3.PDE( ReInd );

  end; // with SetPCMapLayer()^ do
end; // function TN_UDMapLayer.PDVE3

//***************************************************** TN_UDMapLayer.PDVE4 ***
// Return untyped Pointer to AInd-th MLDVect4 Element or nil
//
function TN_UDMapLayer.PDVE4( AInd: integer ): Pointer;
var
  ReInd: integer;
begin
  Result := nil;
  with PCMapLayer^ do
  begin
    if (MLDVect4 = nil) or (AInd = -1) then Exit; // no Data Vector or no Index

    if (MLReIndVect4 = nil) or ((MLFlags and $02) <> 0) then // use Item Index
    begin // do not use ReIndVector, use ItemInd or first code in MLCDimInd CS
      if ((MLFlags and $01) <> 0) then
//        ReInd := MLCObj.Items[AInd].CCode
//        MLCObj.GetItemTwoCodes( AInd, 0, ReInd, N_i )
        ReInd := MLCObj.GetItemFirstCode( AInd, MLCDimInd )
      else
        ReInd := AInd;
    end else // use ReIndVector
      ReInd := MLReIndVect4[AInd];

    if ReInd = -1 then Exit; // no Element in Data Vector
    Result := MLDVect4.PDE( ReInd );

  end; // with SetPCMapLayer()^ do
end; // function TN_UDMapLayer.PDVE4

//***************************************************** TN_UDMapLayer.PDVE5 ***
// Return untyped Pointer to AInd-th MLDVect5 Element or nil
//
function TN_UDMapLayer.PDVE5( AInd: integer ): Pointer;
var
  ReInd: integer;
begin
  Result := nil;
  with PCMapLayer^ do
  begin
    if (MLDVect5 = nil) or (AInd = -1) then Exit; // no Data Vector or no Index

    if (MLReIndVect5 = nil) or ((MLFlags and $02) <> 0) then // use Item Index
    begin // do not use ReIndVector, use ItemInd or first code in MLCDimInd CS
      if ((MLFlags and $01) <> 0) then
//        ReInd := MLCObj.Items[AInd].CCode
//        MLCObj.GetItemTwoCodes( AInd, 0, ReInd, N_i )
        ReInd := MLCObj.GetItemFirstCode( AInd, MLCDimInd )
      else
        ReInd := AInd;
    end else // use ReIndVector
      ReInd := MLReIndVect5[AInd];

    if ReInd = -1 then Exit; // no Element in Data Vector
    Result := MLDVect5.PDE( ReInd );

  end; // with SetPCMapLayer()^ do
end; // function TN_UDMapLayer.PDVE5

//********************************************** TN_UDMapLayer.InitMLParams ***
// Clear all UDRef fields and init Self Static Params by given AMLType ,
// return PCMapLayer to Static Params
//
function TN_UDMapLayer.InitMLParams( AMLType: TN_MLType ): TN_PCMapLayer;
begin
  Result := PISP();
  FillChar( Result^, Sizeof(TN_CMapLayer), 0 ); // temporary

  with Result^ do
  begin
    MLType     := AMLType;
    MLComment  := '';
    MLVisible  := mlvNormal;
    MLPenColor := 0;
    MLPenWidth := 1;
    ClearReIndVectors();

    case AMLType of

      mltNotDef: begin
      end;

      mltPoints1: begin
        MLSSizeXY  := FPoint(9,9);
        MLSShape   := [sshRomb];
        MLHotPoint := FPoint(0.5,0.5);
        MLBrushColor := N_ClLtGray;
      end;

      mltLines1: begin
        MLBrushColor := N_EmptyColor;
      end;

      mltConts1: begin
        MLBrushColor := $DD9999;
        MLDrawMode  := $30; // draw by Windows.StrokeAndFillPath
        MLColorMode := $22; // change Brush Color before each Item
      end;

      mltHorLabels: begin
        MLDrawMode := MLDrawMode or $0100; // use PixRects array
        MLHotPoint := FPoint(0,0);
      end;

      mltLineLabels: begin
      end;

      mltComponents: begin
      end;

    end; // case AMLType of
  end; // with Result^ do

  SetIconIndex();
end; // function TN_UDMapLayer.InitMLParams

//********************************************* TN_UDMapLayer.ItemInvisible ***
// Return True if given Item is Invisible (False means Visible)
//
function TN_UDMapLayer.ItemInvisible( AItemInd: integer ): boolean;
var
  SysBits: integer;
begin
  if MLVisPtrs <> nil then // Check Visibility Bytes in Data Vector
  begin
    if MLVisPtrs[AItemInd] <> nil then // Pointer is given (a precaution)
    begin
      if MLVisPtrs[AItemInd]^ = 0 then // Item is not Visible
      begin
        Result := True; // Item is not Visible
        Exit;
      end; // if MLVisPtrs[AItemInd]^ = 0 then // Item is not Visible
    end; // if MLVisPtrs[AItemInd] <> nil then // Pointer is given
  end; // if MLVisPtrs <> nil then // Check Visibility Bytes in Data Vector

  //***** Checking MLVisPtrs failed, Check Item SysBits

  with PCMapLayer^ do
  begin
    SysBits := MLCObj.Items[AItemInd].CFInd;

    if ( (SysBits and N_EmptyItemBit) = 0 ) and // not empty Item
       ( ( MLVisible = mlvAll ) or // both Normal and Hidden Items are Visible
         ( (MLVisible = mlvNormal) and ( (SysBits and N_HiddenItemBit) = 0 ) ) or
         ( (MLVisible = mlvHidden) and ( (SysBits and N_HiddenItemBit) <> 0 ) )
                                                                   ) then Result := False
                                                                     else Result := True;
  end; // with SetPCMapLayer()^ do
end; // function TN_UDMapLayer.ItemInvisible

//************************************************* TN_UDMapLayer.DrawLayer ***
// Draw Self on given Canvas
//
procedure TN_UDMapLayer.DrawLayer( BegItem, EndItem: integer );
var
  DebCML: TN_CMapLayer;
begin
  N_s := ObjName; // debug
  if N_s = 'MLFOkrBordersOld' then
    N_i := 1;
  N_i := integer(PCMapLayer); // debug
  DebCML := PCMapLayer^; // debug

  with PCMapLayer^ do
  begin
    if MLVisible = mlvNone then Exit; // whole layer not visible

    SetReIndVectors(); //*** Set ReIndexing Vectors if needed

//    N_TestRectDraw( NGCont.DstOcanv, 10, 10, $FF ); // debug

    DrawPoints( BegItem, EndItem );
    DrawLines ( BegItem, EndItem );
    DrawConts ( BegItem, EndItem );
    DrawLabels( BegItem, EndItem );
//    DrawTextBoxes( BegItem, EndItem );
  end;
end; // end_of procedure TN_UDMapLayer.DrawLayer

//************************************************ TN_UDMapLayer.DrawPoints ***
//   MLDVect1 - individual BrushColors
//   MLDVect2 - individual SShiftXYs
//   MLDVect3 - individual SSizes
//   MLDVect4 - individual Components (if MLType = mltComponents)
//
procedure TN_UDMapLayer.DrawPoints( BegItem, EndItem: integer );
var
  i, j, FirstInd, NumInds: integer;
//  CurNumParams2: integer;
  DTypeName, CoordsStr: string;
  OneSize: boolean;
  OneSizeValue: Float;
  PDVE: Pointer;
  CL: TN_UDPoints;
  PixCoords: TPoint;
//  PointAttr: TN_PointAttr1;
  CurComp: TN_UDCompVis;
  TmpGC: TN_GlobCont;
//  PCurParams2: TN_PPointAttr2;
  SelfContAttr, CurContAttr: TK_RArray;
  PSelfContAttr: TN_PContAttr;
  PPA: TN_PPointAttr2;
  ShapeCoords: TN_ShapeCoords;
  PointSegm: Array [0..1] of TDPoint;
begin
  CurComp := nil; // to avoid warning
  TmpGC   := nil; // to avoid warning

  N_IA := MLReIndVect1; // debug
  N_s := ObjName;

  with PCMapLayer^, NGCont.DstOCanv do
  begin

  if (MLType <> mltPoints1) and (MLType <> mltComponents) then Exit;

  if not (MLCObj is TN_UDPoints) then
  begin
    N_WarnByMessage( 'Not Points!' );
    Exit;
  end;

  CL := TN_UDPoints(MLCObj);
  Assert( (CL.ClassFlags and $FF) = N_UDPointsCI, 'Bad CL' );

  if MLType = mltComponents then // Create new GlobCont for drawing Components
    TmpGC := TN_GlobCont.CreateByGCont( NGCont );

{
  if MLAux1 = nil then // Point Attributes2 are not given
  begin
    PCurParams2   := nil;
    CurNumParams2 := 0;
  end else
  begin //*************** Point Attributes2 are given (MLAux1 <> nil)
    PCurParams2   := MLAux1.PDE( 0 );
    CurNumParams2 := MLAux1.Alength();
  end;
}

  OneSize := False; // MLDVect3 (Sign Sizes) may have one or two Sizes
  if MLDVect3 <> nil then
  begin
    DTypeName := TK_UDRArray(MLDVect3).R.ElemType.FD.ObjName;
    if DTypeName = 'Float' then
      OneSize := True
    else if DTypeName <> 'FPoint' then
    begin
      N_WarnByMessage( 'Not FPoints!' );
      Exit;
    end;
  end; // if MLDVect3 <> nil then

  //***** using MLContAttr and MLCAArray is not implemented yet!

  SelfContAttr := nil;
  K_RFreeAndCopy( SelfContAttr, N_DefContAttr, [K_mdfCopyRArray] );
  PSelfContAttr := TN_PContAttr(SelfContAttr.P(0));
//  CurContAttr := MLContAttr; // not implemented!
  CurContAttr := SelfContAttr;

  with PSelfContAttr^ do // initialize attributes
  begin
    CAFlags     := [cafSkipMainPath];
    CAMarkerFlags := [mafBegLine];
    CABrushColor := MLBrushColor;
    CAPenColor  := MLPenColor;
    CAPenWidth  := MLPenWidth;

    CAMarkers   := K_RCreateByTypeName( 'TN_PointAttr2', 1 );
    PPA := TN_PPointAttr2(CAMarkers.P());

    with PPA^ do
    begin
      PAShape      := MLSShape;
      PABrushColor := MLBrushColor;
      PAPenColor   := MLPenColor;
      PAPenWidth   := MLPenWidth;
      PASizeXY     := MLSSizeXY;
      PAShiftXY    := MLShiftXY;
      PAHotPoint   := MLHotPoint;
    end;
  end; // with PSelfContAttr^ do // initialize attributes

  ShapeCoords := TN_ShapeCoords.Create();

  if EndItem = -1 then EndItem := CL.WNumItems-1; // draw all Items

  for i := BegItem to EndItem do // loop along Items (Points Groups)
  begin

    if ItemInvisible( i ) then Continue; // skip Invisible Items

    //***** Update some PointAttr fields by given Data Vectors if needed

    PDVE := PDVE1( i ); // MLDVect1 - individual BrushColors
    if PDVE = nil then
      PPA^.PABrushColor := MLBrushColor
    else
      PPA^.PABrushColor := PInteger(PDVE)^;

    PDVE := PDVE2( i ); // MLDVect2 - individual SShiftXYs
    if PDVE = nil then
      PPA^.PAShiftXY := MLShiftXY
    else
      PPA^.PAShiftXY := PFPoint(PDVE)^;

    PDVE := PDVE3( i ); // MLDVect3 - individual SSizes
    if PDVE = nil then
      PPA^.PASizeXY := MLSSizeXY
    else // get individual SSize(s)
    begin
      if OneSize then
      begin
        OneSizeValue := PFloat(PDVE)^; // MLDVect3 is vector of Floats
        PPA^.PASizeXY := FPoint( OneSizeValue, OneSizeValue );
      end else
        PPA^.PASizeXY := PFPoint(PDVE)^; // MLDVect3 is vector of FPoints
    end; // else // get individual SSize(s)

    if MLType = mltComponents then // Get individual Component CurComp
    begin
      PDVE := PDVE4( i ); // MLDVect4 - individual Components
      if PDVE = nil then
        CurComp := nil
      else
        CurComp := TN_PUDCompVis(PDVE)^;
    end; // if MLType = mltComponents then // Get individual Component CurComp

    //***** Here: PointAttr (and CurComp if needed) are OK

    CL.GetItemInds( i, FirstInd, NumInds ); // NumInds - Points group size (usually=1)

    for j := FirstInd to FirstInd+NumInds-1 do // along Points in group
    begin
      if MLType = mltPoints1 then // Draw Sign
      begin
        if NGCont.GCExpParams.EPImageExpMode = iemHTMLMap then
        begin
          PixCoords := N_AffConvD2IPoint( CL.CCoords[j], NGCont.DstOCanv.U2P );
          CoordsStr := Format( '"%d,%d,%.0f"', [PixCoords.X, PixCoords.Y, 0.5*PPA^.PASizeXY.X+1] );
          NGCont.GCOutSL.Add( '<AREA SHAPE=CIRCLE COORDS=' + CoordsStr );
          AddHTMLMapAttribs( i );
        end else // normal Draw
        begin
  //        NGCont.DrawUserPoint( CL.CCoords[j], @PointAttr, PCurParams2, CurNumParams2 ); // old var
          ShapeCoords.Clear();
          // now Shape should have at least two points (one point path Windows treats as empty path)
          PointSegm[0] := CL.CCoords[j];
          PointSegm[1] := CL.CCoords[j];
          ShapeCoords.AddUserPolyLine( PDPoint(@PointSegm[0]), 2, TN_PAffCoefs4(@NGCont.DstOCanv.U2P) );
          NGCont.DrawShape( ShapeCoords, CurContAttr, N_ZFPoint );
        end; // normal Draw
      end else // MLType = mltComponents, Draw Component
      with CurComp.PCCD()^ do
      begin
{                  Not implemented! (may be not needed)
        if (MLDrawMode and $200) <> 0 then // Set Component Sizes
        begin                              // by PointAttr.SSizeXY
          SRSize := PointAttr.SSizeXY;
          SRSizeXType := cstLSU;
          SRSizeYType := cstLSU;
        end;

        BPCoords := FPoint(CL.CCoords[j]);
        BPXCoordsType := cbpUser;
        BPYCoordsType := cbpUser;
//??        CurComp.InternalRoot := 1; // "Self was started from UDCMap.DrawPoints" flag
//??        N_SetCompCoords( NGCont.DstOCanv, CurComp, nil, @PrevCoords );

        TmpGC.GCRootComp := CurComp;
//!!        TmpGC.StartCompTree; // draw CurComp
//??        CurComp.InternalRoot := 0; // a precaution
}
      end; // else // MLType = mltComponents, Draw Component

    end; // for j := FirstInd to FirstInd+NumInds-1 do // along Points in group
  end; // for i := BegInd to EndInd do // loop along Items (Points ODLGroups)

  ShapeCoords.Free;
  SelfContAttr.Free;

  if TmpGC <> nil then // Temporary NGlobCont was created
  begin
    NGCont.GCUpdateSelf( TmpGC );
    TmpGC.Free;
  end; // if TmpGC <> nil then

  end; // with SetPCMapLayer()^, NGCont.DstOCanv do
end; // end of procedure TN_UDMapLayer.DrawPoints

//******************************************* TN_UDMapLayer.DrawLines ***
//   MLDVect1 - individual BrushColor
//   MLDVect2 - individual PenColor
//   MLDVect3 - individual ContAttr
//
procedure TN_UDMapLayer.DrawLines( BegItem, EndItem: integer );
var
  i, j, k1, k2, Ind, NumParts, FirstInd, LastInd, NumInds: integer;
  RBH: HDC;
  PartCounter, NP2, NewMLPenColor, NewMLBrushColor, CAALeng: integer;
  DCoords1, DCoords2: TN_DPArray;
  PDPoints: PDPoint;
  CL: TN_ULines;
  PEnvRect: PFRect;
  SkipElem, SetDebItemColor, SetDebPartColor: boolean;
  PDVE, PAuxAttr1: Pointer;
  MemPtr, PItemEnv, PMinClip: TN_BytesPtr;
  ContAttrMode, ShapeCoordsMode: boolean;
  CoordsType: TN_MLCoordsType;
  ShapeCoords: TN_ShapeCoords;
  CurContAttr, TmpContAttr, SelfContAttr: TK_RArray;
  PSelfContAttr: TN_PContAttr;
  BasePoint, BegPoint: TDPoint;
begin
  PAuxAttr1     := nil; // to avoid warning
  ShapeCoords   := nil; // to avoid warning
  CurContAttr   := nil; // to avoid warning
  PSelfContAttr := nil; // to avoid warning
  PEnvRect      := nil; // to avoid warning

  SelfContAttr := nil;

  PartCounter := 0;
  SetDebItemColor := False;
  SetDebPartColor := False;
  ContAttrMode    := False;

  with PCMapLayer^, NGCont.DstOCanv do
  begin

  if MLType <> mltLines1 then Exit;

  if not (MLCObj is TN_ULines) then
  begin
    N_WarnByMessage( 'Not Lines!' );
    Exit;
  end;

  CL := TN_ULines(MLCObj);

  ShapeCoordsMode := (MLDrawMode and $080) <> 0 ;
  CoordsType := TN_MLCoordsType( (MLDrawMode shr 12) and $03 );

  if CoordsType = mlctRelPix then BasePoint := DPoint( CompIntPixRect.TopLeft )
                             else BasePoint := N_ZDPoint;

  //***** CurContAttr and TmpContAttr always point to existing Objects and never Freed or Created
  if (MLDVect3 <> nil) or (MLContAttr <> nil) or (MLCAArray <> nil) then // Set ContAttr Mode
  begin
    ContAttrMode := True;
    if MLContAttr <> nil then
      CurContAttr := MLContAttr
    else
      CurContAttr := N_DefContAttr;
  end; // if ... then // Set ContAttr Mode

  if ShapeCoordsMode and (not ContAttrMode) then // Create SelfContAttr and Set PSelfContAttr
  begin
    K_RFreeAndCopy( SelfContAttr, N_DefContAttr, [K_mdfCopyRArray] );
    PSelfContAttr := TN_PContAttr(SelfContAttr.P(0));
  end; // if ShapeCoordsMode and (not ContAttrMode) then // Create SelfContAttr

  if ShapeCoordsMode then ShapeCoords := TN_ShapeCoords.Create();

  if EndItem = -1 then EndItem := CL.WNumItems - 1;

  if CL.CI = N_UCObjRefsCI then // Ref to Lines
  begin
    MLCObj := TN_UCObjLayer(CL.DirChild( N_CObjRefsChildInd )); // temporary

    for i := BegItem to EndItem do
    begin
      if (CL.WFlags and N_ChildIndsBit) <> 0 then
        MLCObj := TN_UCObjLayer(CL.DirChild(TN_UCObjRefs(CL).ChildInds[i]));

      FirstInd := CL.Items[i].CFInd;
      LastInd  := CL.Items[i+1].CFInd - 1;
      SkipElem := False;

      for j := FirstInd to LastInd do
      begin
        if SkipElem then
        begin
          SkipElem := False;
          Continue;
        end;
        k1 := TN_UCObjRefs(CL).CObjInds[j];
        if j < LastInd then
          k2 := TN_UCObjRefs(CL).CObjInds[j+1]
        else
          K2 := 0;

        if k2 < 0 then // Range of indexes is given
        begin
          DrawLines( k1, -k2 ); // recursive call
          SkipElem := True;
        end else
          DrawLines( k1, k1 ); // recursive call

      end; // for j := FirstInd to LastInd do

    end; // for i := BegItem to EndItem do
    MLCObj := Cl; // restore
    Exit;

  end else // real lines, not references
    Assert( CL.CI = N_ULinesCI, 'Bad CL' );

  RBH := NGCont.DstOCanv.HMDC;

  if (MLDrawMode and $00F) = $02 then // Sytem Lines
  begin
    if MLAux1 = nil then
      MLAux1 := TK_UDRArray(N_DefObjectsDir.DirChildByObjName( 'DefSysLines' ));
//      MLAux1 := TK_UDRArray(N_GetUObj( N_DefObjectsDir, 'DefSysLines' ));
    PAuxAttr1 := MLAux1.R.P;
  end;

  NewMLPenColor   := MLPenColor;
  NewMLBrushColor := MLBrushColor;

  if not ContAttrMode then
  begin
    SetPenAttribs( NewMLPenColor, MLPenWidth, MLPenStyle );
    SetBrushAttribs( NewMLBrushColor );

    case (MLColorMode and $0F) of
    2: SetDebItemColor := True;
    3: SetDebPartColor := True;
    end;
  end; // if not ContAttrMode then

  if not ShapeCoordsMode then
  begin
    if ((MLDrawMode and $00F) = $001) or
       ((MLDrawMode and $030) = $020) or
       ((MLDrawMode and $030) = $030)    then
      ConClipPolyline := False // clip lines as rings borders
    else
      ConClipPolyline := True; // clip lines as lines

    if (MLDrawMode and $00F) = $001 then
      ConWinPolyline := False // draw lines using Windows.Polygon
    else
      ConWinPolyline := True; // draw lines using Windows.Polyline

    if ((MLDrawMode and $040) <> 0) and // Draw all Items as a Single Path
       ((MLDrawMode and $030) <> 0)   then BeginPath( RBH );
  end; // if not ShapeCoordsMode then

  if (MLColorMode and $040) <> 0 then SetRop2( RBH, R2_XORPEN );

  PMinClip := TN_BytesPtr(@MinUClipRect.Left);

  N_fr1 := PFRect(PMinClip)^;

  for i := BegItem to EndItem do
  begin

    if ItemInvisible( i ) then Continue; // skip Invisible Items

    CL.GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    if not ShapeCoordsMode then
    begin
      //*****  Check if  Item EnvRect is stricly outside MinUClipRect
      PItemEnv := TN_BytesPtr(@CL.Items[i].EnvRect.Left);
      N_fr2 := PFRect(PItemEnv)^;
      if ( (PFloat(PItemEnv+ 8))^ < (PFloat(PMinClip+0))^ ) or
         ( (PFloat(PItemEnv+12))^ < (PFloat(PMinClip+4))^ ) or
         ( (PFloat(PItemEnv+ 0))^ > (PFloat(PMinClip+8))^ ) or
         ( (PFloat(PItemEnv+ 4))^ > (PFloat(PMinClip+12))^ ) then Continue;

      if 0 = N_EnvRectPos( PFRect(PItemEnv)^, MaxUClipRect ) then
        integer(PEnvRect) := 1 // "clipping is not needed" flag
      else
        PEnvRect := nil; // "clipping is needed" flag
    end; // if not ShapeCoordsMode then

//    N_i := MLDrawMode; // debug

    if not ContAttrMode then
    begin
      PDVE := PDVE1( i ); // Pointer to individual Brush Color
      if PDVE = nil then
        SetBrushAttribs( MLBrushColor )
      else
        SetBrushAttribs( PInteger(PDVE)^ );

      if MLDVect2 <> nil then  // individual Pen Color is given
      begin
        PDVE := PDVE2( i );
        if PDVE = nil then
          SetPenAttribs( MLPenColor, MLPenWidth, MLPenStyle )
        else
          SetPenAttribs( PInteger(PDVE)^, MLPenWidth );
      end;

      if SetDebItemColor then // set individual color for each Item (debug mode)
      begin
        if (MLColorMode and $020) = 0 then
          SetPenAttribs( N_GetDebColor( i, MLColorMode ), MLPenWidth )
        else
          SetBrushAttribs( N_GetDebColor( i, MLColorMode ) );
      end;

    end else // ContAttr Mode
    begin

      if MLDVect3 <> nil then // UDRarray or UDVector of individual ContAttr is given
      begin
        PDVE := PDVE3( i );
        if PDVE <> nil then
          CurContAttr := TK_PRArray(PDVE)^;
      end else if MLCAArray <> nil then // RArray of individual ContAttr is given
      begin
        CAALeng := MLCAArray.ALength();

        if CAALeng = 0 then
          TmpContAttr := nil
        else if CAALeng = 1 then
          TmpContAttr := TK_PRArray(MLCAArray.P(0))^
        else if i <= (CAALeng-1) then
          TmpContAttr := TK_PRArray(MLCAArray.P(i))^
        else
          TmpContAttr := TK_PRArray(MLCAArray.P( i mod CAALeng ))^;

        if TmpContAttr <> nil then CurContAttr := TmpContAttr;
      end; // else if MLCAArray <> nil then // RArray of individual ContAttr is given

    end; // else // ContAttr Mode

    if not ShapeCoordsMode then
    begin
      if ((MLDrawMode and $040)  = 0) and // Draw all Parts of each Item as a Single Path
         ((MLDrawMode and $030) <> 0)   then
            BeginPath( RBH );
    end else // ShapeCordsMode
    begin
      if (MLDrawMode and $040) = 0 then // Draw all Parts of each Item as a Single Path
        ShapeCoords.Clear();
    end; // else // ShapeCordsMode

//    N_i := CL.Items[i].CCode; // debug

    for j := 0 to NumParts-1 do
    begin
      CL.GetPartInds( MemPtr, j, FirstInd, NumInds );

      if SetDebPartColor then // set individual color for each ItemPart
      begin
        if (MLColorMode and $020) = 0 then
          SetPenAttribs( N_GetDebColor( PartCounter, MLColorMode ), MLPenWidth )
        else
          SetBrushAttribs( N_GetDebColor( PartCounter, MLColorMode ) );
        Inc(PartCounter);
      end;

      if ShapeCoordsMode and (not ContAttrMode) then // Set CurContAttr by ML attribs
      with PSelfContAttr^ do
      begin
        CAPenColor  := MLPenColor;
        CAPenWidth  := MLPenWidth;
        CAPenStyle  := MLPenStyle;
        CABrushColor := MLBrushColor;

        CurContAttr := SelfContAttr;
      end; // if ShapeCoordsMode and (not ContAttrMode) then // Set SelfContAttr

      if (not ShapeCoordsMode) and ContAttrMode then // Set ML attribs by CurContAttr
      with TN_PContAttr(CurContAttr.P(0))^ do
      begin
        MLPenColor   := CAPenColor;
        MLPenWidth   := CAPenWidth;
        MLPenStyle   := CAPenStyle;
        MLBrushColor := CABrushColor;

        SetPenAttribs( MLPenColor, MLPenWidth, MLPenStyle );
        SetBrushAttribs( MLBrushColor );
      end; // if ShapeCoordsMode and (not ContAttrMode) then // Set SelfContAttr

      if CL.WLCType = N_FloatCoords then
      begin
        if Length(DCoords1) < NumInds then
          SetLength( DCoords1, N_NewLength(NumInds) );
        PDPoints := @DCoords1[0];
        N_FcoordsToDCoords( @CL.LFCoords[FirstInd], PDPoints, NumInds );
      end
      else
        PDPoints := @CL.LDCoords[FirstInd];

      if (MLDrawMode and $0100) <> 0 then // smooth by quadratic Bezier splain
      begin
        N_Calc2BSplineCoords( PDPoints, NumInds, 5, 0, 0, DCoords2, NP2 );
        NumInds := NP2;
        PDPoints := @DCoords2[0];
      end;

      //***** Here: PDPoints (Coords to draw) are OK

      if not ShapeCoordsMode then
      begin
        Assert( CoordsType = mlctUser, 'Bad CoordsType!' );
        case MLDrawMode and $00F of
        0,1: DrawUserDPoly( PEnvRect, PDPoints, NumInds );
        2: NGCont.DrawUserSysPolyline( PDPoints, NumInds, TN_PSysLineAttr(PAuxAttr1) );
        else
          Assert( False, 'Bad DrawMode' );
        end;
      end else // ShapeCoordsMode
      begin
        ShapeCoords.SCNewPenPos := True; // Each Part is new Line

        case CoordsType of
        mlctUser:   if (CL.WFlags and N_BezierBit) = 0 then
                      ShapeCoords.AddUserPolyLine( PDPoints, NumInds, TN_PAffCoefs4(@U2P) )
                    else
                      ShapeCoords.AddUserPolyBezier( PDPoints, NumInds, @U2P );

        mlctAbsPix,
        mlctRelPix: if (CL.WFlags and N_BezierBit) = 0 then
                      ShapeCoords.AddPixPolyLine( PDPoints, NumInds )
                    else
                      ShapeCoords.AddPixPolyBezier( PDPoints, NumInds );
        end; // case CoordsType of

        BegPoint := PDPoints^;
        Inc( PDPoints, NumInds-1 );
        if N_Same( BegPoint, PDPoints^ ) then
          ShapeCoords.CloseShape();
      end; // else // ShapeCoordsMode

    end; // for j := 0 to NumParts-1 do

    if (MLDrawMode and $040) = 0 then // Draw all Parts of each Item as a Single Path
    begin
      if not ShapeCoordsMode then
      begin
        if (MLDrawMode and $030) <> 0 then EndPath( RBH );

        case (MLDrawMode and $030) of
        $010: StrokePath( RBH );
        $020: FillPath( RBH );
        $030: StrokeAndFillPath( RBH );
        end;
      end else // ShapeCoordsMode
      begin
        NGCont.DrawShape( ShapeCoords, CurContAttr, N_ZFPoint );
      end; // else // ContAttrMode
    end; // if (MLDrawMode and $040) = 0 then // Draw all Parts of each Item as a Single Path

  end; // for i := BegItem to EndItem do

  if (MLDrawMode and $040) <> 0 then // Draw all Items as a Single Path
  begin
    if not ShapeCoordsMode then
    begin
      if (MLDrawMode and $030) <> 0 then EndPath( RBH );

      case (MLDrawMode and $030) of
      $010: StrokePath( RBH );
      $020: FillPath( RBH );
      $030: StrokeAndFillPath( RBH );
      end;

    end else // ShapeCoordsMode
    begin
      NGCont.DrawShape( ShapeCoords, CurContAttr, N_ZFPoint );
    end; // else // ContAttrMode
  end; // if (MLDrawMode and $040) = 0 then

  if (MLColorMode and $040) <> 0 then SetRop2( RBH, R2_COPYPEN );

  SelfContAttr.Free;
  ShapeCoords.Free;

  end; // with SetPCMapLayer()^, NGCont.DstOCanv do
end; // end of procedure TN_UDMapLayer.DrawLines

//******************************************* TN_UDMapLayer.DrawConts ***
//   MLDVect1 - individual BrushColor
//   MLDVect2 - individual PenColor
//   MLDVect3 - individual ContAttr
//
procedure TN_UDMapLayer.DrawConts( BegItem, EndItem: integer );
var
  i, j, k1, k2, FirstInd, LastInd, FRInd, NumRings, ItemCode: integer;
  RingCounter, CAALeng: integer;
  RBH: HDC;
  PDVE: Pointer;
  CL: TN_UContours;
  PEnvRect: PFRect;
  SkipElem, SetDebItemColor, SetDebPartColor: boolean;
  PItemEnv, PMinClip: TN_BytesPtr;
  ContAttrMode, ShapeCoordsMode: boolean;
  CoordsType: TN_MLCoordsType;
  ShapeCoords: TN_ShapeCoords;
  CurContAttr, TmpContAttr, SelfContAttr: TK_RArray;
  PSelfContAttr: TN_PContAttr;
  BasePoint, BegPoint: TDPoint;
begin
  ShapeCoords   := nil; // to avoid warning
  CurContAttr   := nil; // to avoid warning
  PSelfContAttr := nil; // to avoid warning
  PEnvRect      := nil; // to avoid warning

  RingCounter := 0;
  SetDebItemColor := False;
  SetDebPartColor := False;
  ContAttrMode    := False;

  with PCMapLayer^, NGCont.DstOCanv do
  begin

  if MLType <> mltConts1 then Exit;

  if not (MLCObj is TN_UContours) then
  begin
    N_WarnByMessage( 'Not Contours!' );
    Exit;
  end;

  CL := TN_UContours(MLCObj);

  ShapeCoordsMode := (MLDrawMode and $080) <> 0 ;
  CoordsType := TN_MLCoordsType( (MLDrawMode shr 12) and $03 );

  if CoordsType = mlctRelPix then BasePoint := DPoint( CompIntPixRect.TopLeft )
                             else BasePoint := N_ZDPoint;

  //***** CurContAttr and TmpContAttr always point to existing Objects and never Freed or Created
  if (MLDVect3 <> nil) or (MLContAttr <> nil) or (MLCAArray <> nil) then // Set ContAttr Mode
  begin
    ContAttrMode := True;
    if MLContAttr <> nil then
      CurContAttr := MLContAttr
    else
      CurContAttr := N_DefContAttr;
  end; // if ... then // Set ContAttr Mode

  if ShapeCoordsMode and (not ContAttrMode) then // Create SelfContAttr and Set PSelfContAttr
  begin
    K_RFreeAndCopy( SelfContAttr, N_DefContAttr );
    PSelfContAttr := TN_PContAttr(SelfContAttr.P(0));
  end; // if ShapeCoordsMode and (not ContAttrMode) then // Create SelfContAttr

  if ShapeCoordsMode then ShapeCoords := TN_ShapeCoords.Create();

  if EndItem = -1 then EndItem := CL.WNumItems - 1;

  if CL.CI = N_UCObjRefsCI then // Ref to Contours
  begin
    MLCObj := TN_UCObjLayer(CL.DirChild( N_CObjRefsChildInd )); // temporary

    for i := BegItem to EndItem do
    begin
      if (CL.WFlags and N_ChildIndsBit) <> 0 then
        MLCObj := TN_UCObjLayer(CL.DirChild(TN_UCObjRefs(CL).ChildInds[i]));

      FirstInd := CL.Items[i].CFInd;
      LastInd  := CL.Items[i+1].CFInd - 1;
      SkipElem := False;

      for j := FirstInd to LastInd do
      begin
        if SkipElem then
        begin
          SkipElem := False;
          Continue;
        end;
        k1 := TN_UCObjRefs(CL).CObjInds[j];
        if j < LastInd then
          k2 := TN_UCObjRefs(CL).CObjInds[j+1]
        else
          K2 := 0;

        if k2 < 0 then // Range of indexes is given
        begin
          DrawConts( k1, -k2 );
          SkipElem := True;
        end else
          DrawConts( k1, k1 );

      end; // for j := FirstInd to LastInd do

    MLCObj := Cl; // restore
    Exit;
    end; // for i := BegItem to EndItem do

  end else // real contours, not references
    Assert( CL.CI = N_UContoursCI, 'Bad CL' );

  CL.MakeRingsCoords();
  if CL.WEnvRect.Left = N_NotAFloat then Exit; // Lines are not ready yet

  RBH := NGCont.DstOCanv.HMDC;

  if not ContAttrMode then
  begin
    SetPenAttribs( MLPenColor, MLPenWidth );
    SetBrushAttribs( MLBrushColor );

    if ((MLDrawMode and $00F) = $001) or
       ((MLDrawMode and $0F0) = $020) or
       ((MLDrawMode and $0F0) = $030)   then
      ConClipPolyline := False // clip lines as rings borders
    else
      ConClipPolyline := True; // clip lines as lines
  end; // if not ContAttrMode then

  if not ShapeCoordsMode then
  begin
    if (MLDrawMode and $00F) = $001 then
      ConWinPolyline := False // draw lines using Windows.Polygon
    else
      ConWinPolyline := True; // draw lines using Windows.Polyline

    case (MLColorMode and $0F) of
    2: SetDebItemColor := True;
    3: SetDebPartColor := True;
    end;
  end; // if not ShapeCoordsMode then

  PMinClip := TN_BytesPtr(@MinUClipRect.Left);
  N_FR := MinUClipRect;

  for i := BegItem to EndItem do
  begin
    if ItemInvisible( i ) then Continue; // skip Invisible Items

    CL.GetItemInds( i, FRInd, NumRings );
    if NumRings = 0 then Continue; // skip empty items

    if not ShapeCoordsMode then
    begin
      //*****  Check if  Item EnvRect is stricly outside MinUClipRect
      PItemEnv := TN_BytesPtr(@CL.Items[i].EnvRect.Left);
      if ( (PFloat(PItemEnv+ 8))^ < (PFloat(PMinClip+0))^ ) or
         ( (PFloat(PItemEnv+12))^ < (PFloat(PMinClip+4))^ ) or
         ( (PFloat(PItemEnv+ 0))^ > (PFloat(PMinClip+8))^ ) or
         ( (PFloat(PItemEnv+ 4))^ > (PFloat(PMinClip+12))^ ) then Continue;

      if 0 = N_EnvRectPos( PFRect(PItemEnv)^, MaxUClipRect ) then
        integer(PEnvRect) := 1 // "clipping is not needed" flag
      else
        PEnvRect := nil; // "clipping is needed" flag
    end; // if not ShapeCoordsMode then

    if not ContAttrMode then
    begin
      if SetDebItemColor then // set individual color for each Item
      begin
        if (MLColorMode and $020) = 0 then
          SetPenAttribs( N_GetDebColor( i, MLColorMode ), MLPenWidth )
        else
          SetBrushAttribs( N_GetDebColor( i, MLColorMode ) );
      end;

      if (MLDrawMode and $0F0) <> 0 then BeginPath( RBH );

    end else // ContAttr Mode
    begin

      if MLDVect3 <> nil then // UDRarray or UDVector of individual ContAttr is given
      begin
        PDVE := PDVE3( i );
        if PDVE <> nil then
          CurContAttr := TK_PRArray(PDVE)^;
      end else if MLCAArray <> nil then // RArray of individual ContAttr is given
      begin
        CAALeng := MLCAArray.ALength();

        if CAALeng = 0 then
          TmpContAttr := nil
        else if CAALeng = 1 then
          TmpContAttr := TK_PRArray(MLCAArray.P(0))^
        else if i <= (CAALeng-1) then
          TmpContAttr := TK_PRArray(MLCAArray.P(i))^
        else
          TmpContAttr := TK_PRArray(MLCAArray.P( i mod CAALeng ))^;

        if TmpContAttr <> nil then CurContAttr := TmpContAttr;
      end; // else if MLCAArray <> nil then // RArray of individual ContAttr is given

      if (MLDrawMode and $040) = 0 then // Draw all Parts of each Item as a Single Path
        ShapeCoords.Clear();

    end; // else // ContAttr Mode

//    N_i := CL.Items[i].CCode; // debug

    for j := FRInd to FRInd+NumRings-1 do // draw all Rings
    with CL.CRings[j] do
    begin
      if SetDebPartColor then // set individual color for each ItemPart
      begin
        if (MLColorMode and $020) = 0 then
          SetPenAttribs( N_GetDebColor( RingCounter, MLColorMode ), MLPenWidth )
        else
          SetBrushAttribs( N_GetDebColor( RingCounter, MLColorMode ) );
        Inc(RingCounter);
      end;

      if ShapeCoordsMode and (not ContAttrMode) then // Set CurContAttr by ML attribs
      with PSelfContAttr^ do
      begin
        CAPenColor  := MLPenColor;
        CAPenWidth  := MLPenWidth;
        CAPenStyle  := MLPenStyle;
        CABrushColor := MLBrushColor;

        CurContAttr := SelfContAttr;
      end; // if ShapeCoordsMode and (not ContAttrMode) then // Set SelfContAttr

      if (not ShapeCoordsMode) and ContAttrMode then // Set ML attribs by CurContAttr
      with TN_PContAttr(CurContAttr.P(0))^ do
      begin
        MLPenColor   := CAPenColor;
        MLPenWidth   := CAPenWidth;
        MLPenStyle   := CAPenStyle;
        MLBrushColor := CABrushColor;

        SetPenAttribs( MLPenColor, MLPenWidth, MLPenStyle );
        SetBrushAttribs( MLBrushColor );
      end; // if ShapeCoordsMode and (not ContAttrMode) then // Set SelfContAttr

      if NGCont.GCExpParams.EPImageExpMode = iemHTMLMap then
      begin
        if (RFlags and $FF) > 0 then // export only Level 0 Rings
          Continue;

        NGCont.GCOutSLBuf.AddToken( '<AREA SHAPE=POLY COORDS="' );
        AddPixCoords( RFCoords, RDCoords );
        NGCont.GCOutSLBuf.Flash( '" ' );
        AddHTMLMapAttribs( i );
        Continue; // to next ring
      end; // if NGCont.GCExpParams.EPImageExpMode = iemHTMLMap then

      if not ShapeCoordsMode then
      begin
        if RFCoords <> nil then
          DrawUserFPoly( PEnvRect, @RFCoords[0], Length(RFCoords) )
        else // use RDCoords
          DrawUserDPoly( PEnvRect, @RDCoords[0], Length(RDCoords) );
      end else // ShapeCoordsMode
      begin
        ShapeCoords.SCNewPenPos := True; // Each Ring is new Line

        if RFCoords <> nil then
        begin
          case CoordsType of
          mlctUser:   if (CL.WFlags and N_BezierBit) = 0 then
                        ShapeCoords.AddUserPolyLine( PFPoint(@RFCoords[0]), Length(RFCoords), TN_PAffCoefs4(@U2P) )
                      else
                        ShapeCoords.AddUserPolyBezier( PFPoint(@RFCoords[0]), Length(RFCoords), TN_PAffCoefs4(@U2P) );

          mlctAbsPix,
          mlctRelPix: if (CL.WFlags and N_BezierBit) = 0 then
                        ShapeCoords.AddPixPolyLine( PFPoint(@RFCoords[0]), Length(RFCoords) )
                      else
                        ShapeCoords.AddPixPolyBezier( PFPoint(@RFCoords[0]), Length(RFCoords) );
          end; // case CoordsType of
        end else // use RDCoords
        begin
          case CoordsType of
          mlctUser:   if (CL.WFlags and N_BezierBit) = 0 then
                        ShapeCoords.AddUserPolyLine( PDPoint(@RDCoords[0]), Length(RDCoords), TN_PAffCoefs4(@U2P) )
                      else
                        ShapeCoords.AddUserPolyBezier( PDPoint(@RDCoords[0]), Length(RDCoords), TN_PAffCoefs4(@U2P) );

          mlctAbsPix,
          mlctRelPix: if (CL.WFlags and N_BezierBit) = 0 then
                        ShapeCoords.AddPixPolyLine( PDPoint(@RDCoords[0]), Length(RDCoords) )
                      else
                        ShapeCoords.AddPixPolyBezier( PDPoint(@RDCoords[0]), Length(RDCoords) );
          end; // case CoordsType of
        end;

        ShapeCoords.CloseShape(); // all Rings are closed
      end; // else // ContAttrMode

    end; // for j := FRInd to FRInd+NumRings-1 do // draw all Rings

    if not ShapeCoordsMode then
    begin
      if (MLDrawMode and $0F0) <> 0 then EndPath( RBH );

      if SetDebItemColor then // set individual color for each Item (debug mode)
      begin
        if (MLColorMode and $020) = 0 then
          SetPenAttribs( N_GetDebColor( i, MLColorMode ), MLPenWidth )
        else
          SetBrushAttribs( N_GetDebColor( i, MLColorMode ) );
      end else // set individual color for each Item by PDVE1, PDVE2
      begin
        PDVE := PDVE1( i );
        if PDVE = nil then
          SetBrushAttribs( MLBrushColor )
        else
          SetBrushAttribs( PInteger(PDVE)^ );

        PDVE := PDVE2( i );
        if PDVE = nil then
          SetPenAttribs( MLPenColor, MLPenWidth )
        else
          SetPenAttribs( PInteger(PDVE)^, MLPenWidth );
      end;

      case (MLDrawMode and $0F0) of
      $010: StrokePath( RBH );
      $020: FillPath( RBH );
      $030: StrokeAndFillPath( RBH );
      end;

    end else // ShapeCoordsMode
    begin
      NGCont.DrawShape( ShapeCoords, CurContAttr, N_ZFPoint );
    end; // else // ShapeCoordsMode

  end; // for i := BegItem to EndItem do
  end; // with PCMapLayer^, NGCont.DstOCanv do
end; // end of procedure TN_UDMapLayer.DrawConts

//******************************************* TN_UDMapLayer.DrawLabels ***
//   MLDVect1 - individual Text (or MLVArray1)
//   MLDVect2 - individual SShiftXY
//   MLDVect3 - individual Font
//   MLAux1   - common Font (or MLVAux1)
//
procedure TN_UDMapLayer.DrawLabels( BegItem, EndItem: integer );
var
  i, j, FirstInd, NumInds: integer;
  LabelText: string;
  PDVE: Pointer;
  CLP: TN_UDPoints;
  CLL: TN_ULines;
  ShiftXY: TFPoint;
  DC: TN_DPArray;
  IsNFont: boolean;
  LayersFont: TN_UDLogFont; // , DefFont
  DefNFont: TK_UDRArray;
  LayersNFont: TK_RArray;
  PCurFont: TN_PLogFontRef;
begin
  with PCMapLayer^, NGCont.DstOCanv do
  begin

  if (MLType <> mltHorLabels)  and
     (MLType <> mltLineLabels) and (MLType <> mltCurveLabels) then Exit;

  IsNFont := False;
//  DefFont  := TN_UDLogFont(N_GetUObj( N_DefObjectsDir, 'DefFont' ));
  DefNFont := TK_UDRArray(N_DefObjectsDir.DirChildByObjName( N_DefNFontName ));
//  DefNFont := TK_UDRArray(N_GetUObj( N_DefObjectsDir, N_DefNFontName ));
  LayersFont  := nil;
  LayersNFont := nil;

  if MLAux1 = nil then
  begin
    IsNFont := True;
    LayersNFont := DefNFont.R;
    if MLVAux1 <> nil then
    begin
      if MLVAux1 is TK_UDRArray then // MLVAux1 is UDRArray
        LayersNFont := TK_UDRArray(MLVAux1).R
      else //********************* ANFont is RArray
        LayersNFont := TK_RArray(MLVAux1);

      if LayersNFont.ElemSType <> N_SPLTC_NFont then
        LayersNFont := DefNFont.R
    end;
  end else // MLAux1 <> nil
    LayersFont := TN_UDLogFont(MLAux1);

  if MLTextColor <> N_EmptyColor then
    SetTextColor( HMDC, MLTextColor ) // WinGDI function
  else
    Exit; // nothing todo

  if MLType = mltHorLabels then
  begin
    CLP := TN_UDPoints(MLCObj);
    Assert( (CLP.ClassFlags and $FF) = N_UDPointsCI, 'Bad CL' );

    if (MLDrawMode and $0100) <> 0 then
      SetLength( MLPRects, CLP.Items[CLP.WNumItems].CFInd);

    if EndItem = -1 then EndItem := CLP.WNumItems-1;

    for i := BegItem to EndItem do // loop along Items (Points groups)
    begin

      if ItemInvisible( i ) then Continue; // skip Invisible Items

      CLP.GetItemInds( i, FirstInd, NumInds );
      if NumInds = 0 then Continue; // skip Empty Items

      PDVE := PDVE1( i );
      if PDVE = nil then
      begin
        PDVE := N_PVAE( MLVArray1, i );
        if PDVE = nil then
          LabelText := N_DefLabel
        else
          LabelText := PString(PDVE)^;
      end else
        LabelText := PString(PDVE)^;

      PDVE := PDVE2( i );
      if PDVE = nil then
        ShiftXY := MLShiftXY
      else
        ShiftXY := PFPoint(PDVE)^;

      PDVE := PDVE3( i );
      if PDVE = nil then  // set Current Font for DrawUserString
      begin
        if IsNFont then
          N_SetNFont( LayersNFont, NGCont.DstOCanv, 0 )
        else
          LayersFont.SetFont( NGCont.DstOCanv, 0 )
      end else // PDVE <> nil
      begin
        PCurFont := TN_PLogFontRef(PDVE);
        if PCurFont^.LFRUDFont <> nil then
          PCurFont^.LFRUDFont.SetFont( NGCont.DstOCanv, PCurFont^.LFRFSCoef )
        else
          LayersFont.SetFont( NGCont.DstOCanv, 1 );
      end;

      for j := FirstInd to FirstInd+NumInds-1 do
      begin
        if Abs(CLP.CCoords[j].X) > 10.0e10 then
          N_i := 1;
        DrawUserString( CLP.CCoords[j], ShiftXY, MLHotPoint, LabelText );
        if (MLDrawMode and $0100) <> 0 then
        begin
          MLPRects[j] := WrkStrPixRect;
        end;
      end; // for j := FirstInd to FirstInd+NumInds-1 do

      end; // for i := BegInd to EndInd do
  end else if MLType = mltLineLabels then
  begin
    // not yet
  end else if MLType = mltCurveLabels then
  begin
    CLL := TN_ULines(MLCObj);
    Assert( CLL.CI = N_ULinesCI, 'Bad CL' );
    if EndItem = -1 then EndItem := CLL.WNumItems-1;

    for i := BegItem to EndItem do
    begin
      if ItemInvisible( i ) then Continue; // skip Invisible Items

      PDVE := PDVE1( i );
      if PDVE = nil then PDVE := @N_DefLabel;

      CLL.GetPartDCoords( i, 0, DC );
      DrawCurveString( @DC[0], Length(DC), PString(PDVE)^ );
    end; // for i := BegInd to EndInd do
  end else
    Assert( False, 'Not Yet' );

  end; // with SetPCMapLayer()^, NGCont.DstOCanv do
end; // end of procedure TN_UDMapLayer.DrawLabels

//**************************************** TN_UDMapLayer.AddHTMLMapAttribs ***
// Add to GCOutSL text attributes with replacing "#Code#" token by
// CDim Ind for zero CDim and given AItemInd
//
procedure TN_UDMapLayer.AddHTMLMapAttribs( AItemInd: integer );
var
  ItemCode: integer;
  Pattern, ResStr: string;
begin
  with PCMapLayer^, NGCont do
  begin
    ItemCode := MLCObj.GetItemFirstCode( AItemInd, 0 ); // may be -1
    if ItemCode <> -1 then Dec( ItemCode ); // temporary convert Code to Index

    Pattern := MLExpParStr;
    if Pattern = '' then Pattern := GCExpParams.EPTextFPar.TFPStr1;

    if Pattern = '' then Exit; // No HTMLMap Attribs
    ResStr := AnsiReplaceStr( Pattern, '#Code#', IntToStr( ItemCode ) );
    GCOutSL.Add( ResStr+'>' );
  end; // with PCMapLayer^, NGCont do
end; // procedure TN_UDMapLayer.AddHTMLMapAttribs

//**************************************** TN_UDMapLayer.AddPixCoords(Ptrs) ***
// Add to GCOutSLBuf User Coords (Float or Double) given as pointers
//
//  APFCoords  - Pointer to Float Coords of first point
//  APDCoords  - Pointer to Double Coords of first point
//               (one of Pointers should be nil)
//  ANumPoints - Number of Points to Add
//
procedure TN_UDMapLayer.AddPixCoords( APFCoords: PFPoint; APDCoords: PDPoint;
                                                          ANumPoints: integer );
var
  i, NPixPoints: integer;
begin
  with NGCont, NGCont.DstOCanv do
  begin
    NPixPoints := 0; // Number of points in WrkCILine

    if APFCoords <> nil then
      NPixPoints := N_ConvFLineToILine2( U2P, ANumPoints, APFCoords, @WrkCILine[0] )
    else if APDCoords <> nil then
      NPixPoints := N_ConvDLineToILine2( U2P, ANumPoints, APDCoords, @WrkCILine[0] );

    for i := 0 to NPixPoints-1 do
    begin
      GCOutSLBuf.AddCSToken( Format( '%d,%d', [WrkCILine[i].X,WrkCILine[i].Y] ) );
    end; // for i := 0 to NPixPoints-1 do

  end; // with NGCont, NGCont.DstOCanv do
end; // procedure TN_UDMapLayer.AddPixCoords(Ptrs)

//************************************** TN_UDMapLayer.AddPixCoords(Arrays) ***
// Add to GCOutSLBuf User Coords (Float or Double) in two Arrays
//
//  AFPCoords  - Array of Float Coords
//  ADPCoords  - Array of Double Coords
//  (one of params should be nil)
//
procedure TN_UDMapLayer.AddPixCoords( AFPArray: TN_FPArray; ADPArray: TN_DPArray );
var
  NumPoints: integer;
begin
  NumPoints := Length( AFPArray );

  if NumPoints > 0 then
    AddPixCoords( @AFPArray[0], nil, NumPoints )
  else
  begin
    NumPoints := Length( ADPArray );
    
    if NumPoints > 0 then
      AddPixCoords( nil, @ADPArray[0], NumPoints )
  end;

end; // procedure TN_UDMapLayer.AddPixCoords(Arrays)

//*************************************** TN_UDMapLayer.DrawPointsToSVG ***
// Draw Points To SVG
//
procedure TN_UDMapLayer.DrawPointsToSVG();
var
  iItem, j, FirstInd, NumInds: integer;
  PDVE: Pointer;
  CL: TN_UDPoints;
  SignSize: float;
  FillAttr, SSizeAttr: string;
  IndividualColor: boolean;
  SVGUC: TDPoint;
begin
  with PCMapLayer^, NGCont, NGCont.DstOCanv do
  begin
    CL := TN_UDPoints(MLCObj);
    Assert( CL.CI = N_UDPointsCI, 'Bad CL' );
    SVGIdPref := ObjName;
    SignSize := MLSSizeXY.X*CurLSUPixSize;

    if MLDVect1 <> nil then // Individual Fill Colors
    begin
      IndividualColor := True;
      FillAttr := '>';
    end else // Group Fill Color
    begin
      IndividualColor := False;
      FillAttr := SVGFillColor + '>';
    end;

    if MLSSizeXY.X <> -1 then // not Individual Sign Sizes
      SSizeAttr := Format( ' r="%.0f"', [SignSize] );

    GCOutSL.Add( '  <g' + SVGIdObjName + SVGPenColor + SVGPenWidth + FillAttr );

  for iItem := 0 to CL.WNumItems-1 do //***** loop along all Points Groups in Layer
  begin

    if ItemInvisible( iItem ) then Continue; // skip Invisible Items

    CL.GetItemInds( iItem, FirstInd, NumInds ); // NumInds is Num Elems in Group
    if NumInds = 0 then Continue; // skip empty items

    for j := FirstInd to FirstInd+NumInds-1 do // along Points in Group
    begin

      FillAttr := '';
      if IndividualColor then // BrushColors are given in MLDVect1
      begin
        PDVE := PDVE1( iItem );
        if PDVE <> nil then
          FillAttr := ' fill=' + N_ColorToQHTMLHex( PInteger(PDVE)^ );
      end;

      if SignSize < 0 then // Individual Sign Sizes are given in MLDVect3
      begin
        PDVE := PDVE3( iItem );
        if PDVE = nil then
          SSizeAttr := Format( ' r="%.0f"', [5] ) // 5 is def value
        else
          SSizeAttr := Format( ' r="%.0f"', [PFloat(PDVE)^*CurLSUPixSize ]);
      end;

      SVGUC := N_AffConvD2DPoint( CL.CCoords[j], DstOCanv.U2P ); // SVG User Coords
      GCOutSL.Add( Format( '    <circle id="%s" cx="%.0f" cy="%.0f" %s %s />',
                    [ SVGIdPref+IntToStr(iItem), SVGUC.X,
                      SVGUC.Y, SSizeAttr, FillAttr ] ));

    end; // for j := FirstInd to FirstInd+NumInds-1 do

    GCOutSLBuf.Flash();
  end; // for iItem := 0 to CL.WNumItems-1 do // loop along all Points in Layer

  GCOutSL.Add( '  </g>' );
  end; // SetPCMapLayer()^, NGCont.DrawContext do
end; // end of procedure TN_UDMapLayer.DrawPointsToSVG

//*************************************** TN_UDMapLayer.DrawPointsToVML ***
// Draw Points To VML
//
procedure TN_UDMapLayer.DrawPointsToVML();
var
  iItem, j, FirstInd, NumInds: integer;
  PDVE: Pointer;
  CL: TN_UDPoints;
  SignSize: float;
  FillAttr, SSizeAttr: string;
  IndividualColor: boolean;
  SVGUC: TDPoint;
begin
  with PCMapLayer^, NGCont, NGCont.DstOcanv do
  begin
    CL := TN_UDPoints(MLCObj);
    Assert( CL.CI = N_UDPointsCI, 'Bad CL' );
    SVGIdPref := ObjName;
    SignSize := MLSSizeXY.X*CurLSUPixSize;

    if MLDVect1 <> nil then // Individual Fill Colors
    begin
      IndividualColor := True;
      FillAttr := '>';
    end else // Group Fill Color
    begin
      IndividualColor := False;
      FillAttr := SVGFillColor + '>';
    end;

    if MLSSizeXY.X <> -1 then // not Individual Sign Sizes
      SSizeAttr := Format( ' r="%.0f"', [SignSize] );

    GCOutSL.Add( '  <g' + SVGIdObjName + SVGPenColor + SVGPenWidth + FillAttr );

  for iItem := 0 to CL.WNumItems-1 do //***** loop along all Points Groups in Layer
  begin

    if ItemInvisible( iItem ) then Continue; // skip Invisible Items

    CL.GetItemInds( iItem, FirstInd, NumInds ); // NumInds is Num Elems in Group
    if NumInds = 0 then Continue; // skip empty items

    for j := FirstInd to FirstInd+NumInds-1 do // along Points in Group
    begin

      FillAttr := '';
      if IndividualColor then // BrushColors are given in MLDVect1
      begin
        PDVE := PDVE1( iItem );
        if PDVE <> nil then
          FillAttr := ' fill=' + N_ColorToQHTMLHex( PInteger(PDVE)^ );
      end;

      if SignSize < 0 then // Individual Sign Sizes are given in MLDVect3
      begin
        PDVE := PDVE3( iItem );
        if PDVE = nil then
          SSizeAttr := Format( ' r="%.0f"', [5] ) // 5 is def value
        else
          SSizeAttr := Format( ' r="%.0f"', [PFloat(PDVE)^*CurLSUPixSize ]);
      end;

      SVGUC := N_AffConvD2DPoint( CL.CCoords[j], DstOCanv.U2P ); // SVG User Coords
      GCOutSL.Add( Format( '    <circle id="%s" cx="%.0f" cy="%.0f" %s %s />',
                    [ SVGIdPref+IntToStr(iItem), SVGUC.X,
                      SVGUC.Y, SSizeAttr, FillAttr ] ));

    end; // for j := FirstInd to FirstInd+NumInds-1 do

    GCOutSLBuf.Flash();
  end; // for iItem := 0 to CL.WNumItems-1 do // loop along all Points in Layer

  GCOutSL.Add( '  </g>' );
  end; // SetPCMapLayer()^, NGCont.DrawContext do
end; // end of procedure TN_UDMapLayer.DrawPointsToVML

//*************************************** TN_UDMapLayer.DrawLinesToSVG ***
// Draw Lines To SVG
//
procedure TN_UDMapLayer.DrawLinesToSVG();
var
  iItem, iPart, FirstInd, NumInds, NumParts: integer;
  PDVE: Pointer;
  CL: TN_ULines;
  MemPtr: TN_BytesPtr;
  IndPenColorS: string;
begin
  with PCMapLayer^, NGCont do
  begin
  CL := TN_ULines(MLCObj);
  Assert( CL.CI = N_ULinesCI, 'Bad CL' );
  SVGIdPref := ObjName;

  GCOutSL.Add( '  <g id="' + ObjName +
    '" fill="none"' + SVGPenWidth + SVGPenColor + '>' );

  for iItem := 0 to CL.WNumItems-1 do //***** loop along all Lines in Layer
  begin

    if ItemInvisible( iItem ) then Continue; // skip Invisible Items
    CL.GetNumParts( iItem, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    if MLDVect2 <> nil then // Individual PenColors in MLDVect2
    begin
      PDVE := PDVE2( iItem );
      if PDVE = nil then
        IndPenColorS := ''
      else
        IndPenColorS := ' stroke=' + N_ColorToQHTMLHex( PInteger(PDVE)^ );
    end;

    GCOutSL.Add( '    <path id="'+SVGIdPref+IntToStr(iItem) + IndPenColorS + '" d="' );

    for iPart := 0 to NumParts-1 do //***** loop along all Line Parts
    begin
      CL.GetPartInds( MemPtr, iPart, FirstInd, NumInds );

//      if CL.WLCType = N_FloatCoords then
//        N_AddFLineToSvg( GCOutSLBuf, @CL.LFCoords[FirstInd], AffCoefs, NumInds, OutAccuracy )
//      else
//        N_AddDLineToSvg( GCOutSLBuf, @CL.LDCoords[FirstInd], AffCoefs, NumInds, OutAccuracy )

    end; // for iPart := 0 to NumParts-1 do //***** loop along all Line Parts

    GCOutSLBuf.AddToken( '"/>'); // close d attribute and path tag
    GCOutSLBuf.Flash();
  end; // for iItem := 0 to CL.WNumItems-1 do // loop along all contours in Layer

  GCOutSL.Add( '  </g>' );
  end; // with SetPCMapLayer()^, NGCont do
end; // end of procedure TN_UDMapLayer.DrawLinesToSVG

//*************************************** TN_UDMapLayer.DrawContsToSVG ***
// Draw Conts To SVG
//
procedure TN_UDMapLayer.DrawContsToSVG();
var
  iItem, iRing, FRInd, NumRings: integer;
  PDVE: Pointer;
  FillAttr: string;
  CL: TN_UContours;
  IndividualColor: boolean;
begin
  with PCMapLayer^, NGCont do
  begin

  if MLType <> mltConts1 then Exit;

  CL := TN_UContours(MLCObj);
  Assert( CL.CI = N_UContoursCI, 'Bad CL' );
  CL.MakeRingsCoords();
  SVGIdPref := ObjName;

  if MLDVect1 <> nil then // Individual Fill Colors
  begin
    IndividualColor := True;
    FillAttr := '>';
  end else // Group Fill Color
  begin
    IndividualColor := False;
    FillAttr := SVGFillColor + '>';
  end;

  GCOutSL.Add( '  <g id="' + ObjName + '"' +
                                     SVGPenWidth + SVGPenColor + FillAttr );

  for iItem := 0 to CL.WNumItems-1 do //***** loop along all contours in Layer
  begin

    if ItemInvisible( iItem ) then Continue; // skip Invisible Items
    CL.GetItemInds( iItem, FRInd, NumRings );
    if NumRings = 0 then Continue; // skip empty items

    FillAttr := '';
    if IndividualColor then // BrushColors are given in MLDVect1
    begin
      PDVE := PDVE1( iItem );
      if PDVE <> nil then
        FillAttr := ' fill=' + N_ColorToQHTMLHex( PInteger(PDVE)^ );
    end;

    GCOutSL.Add( '    <path id="'+SVGIdPref+IntToStr(iItem) + '"' +
                                                    FillAttr + ' d="' );

    for iRing := FRInd to FRInd+NumRings-1 do //***** loop along all Rings
    with CL.CRings[iRing] do
    begin
//      if RFCoords <> nil then
//        N_AddFLineToSvg( GCOutSLBuf, @RFCoords[0], AffCoefs, Length(RFCoords), OutAccuracy )
//      else
//        N_AddDLineToSvg( GCOutSLBuf, @RDCoords[0], AffCoefs, Length(RDCoords), OutAccuracy )
    end; // for iRing := FRInd to FRInd+NumRings-1 do //***** loop along all Rings

    GCOutSLBuf.AddToken( 'z"/>'); // close d attribute and path tag (z is needed for Corel!)
    GCOutSLBuf.Flash();
  end; // for iItem := 0 to CL.WNumItems-1 do // loop along all contours in Layer

  GCOutSL.Add( '  </g>' );
  end; // with SetPCMapLayer()^, NGCont do
end; // end of procedure TN_UDMapLayer.DrawContsToSVG

//*************************************** TN_UDMapLayer.DrawHorLabelsToSVG ***
// Draw Horizontal Labels To SVG
//
procedure TN_UDMapLayer.DrawHorLabelsToSVG();
var
  iItem, j, FirstInd, NumInds, Dx, Dy: integer;
  PDVE: Pointer;
  CL: TN_UDPoints;
  Str, SVGStr, FDescr: string;
  SVGUC: TDPoint;
  ShiftXY: TFPoint;
  LogFont: TN_UDLogFont;
  FontSize: float;
begin
  with PCMapLayer^, NGCont, NGCont.DstOcanv do
  begin

  if MLType <> mltHorLabels then Exit;

  CL := TN_UDPoints(MLCObj);
  Assert( CL.CI = N_UDPointsCI, 'Bad CL' );
  SVGIdPref := ObjName;

  if MLAux1 = nil then
    LogFont := TN_UDLogFont(N_DefObjectsDir.DirChildByObjName( 'DefFont' ))
//    LogFont := TN_UDLogFont(N_GetUObj( N_DefObjectsDir, 'DefFont' ))
  else
    LogFont := TN_UDLogFont(MLAux1);

    with TN_PLogFont(LogFont.R.P)^ do
  begin
    FDescr := '';
    if lfsBold in LFStyle then FDescr := ' font-weight="bold"';
    if lfsItalic in LFStyle then FDescr := FDescr + ' font-style="italic"';

    FontSize := LFHeight*DstOCanv.CurLFHPixSize;
    GCOutSL.Add( '  <g' + SVGIdObjName + SVGFillColor +
               Format( ' font-family="%s" font-size="%.0f" %s>',
               [LFFaceName, FontSize, FDescr] ) );
  end;

  LogFont.SetFont( DstOCanv );

  for iItem := 0 to CL.WNumItems-1 do //***** loop along all Points Groups in Layer
  begin

    if ItemInvisible( iItem ) then Continue; // skip Invisible Items
    CL.GetItemInds( iItem, FirstInd, NumInds ); // NumInds is Num Elems in Group
    if NumInds = 0 then Continue; // skip empty items

    PDVE := PDVE1( iItem ); // get Labels text
    if PDVE = nil then PDVE := @N_DefLabel;
    Str := PString(PDVE)^;

//    if TextEncoding = tfeUTF8 then // use ExpParams.TextEncoding
//      SVGStr := N_UTF8( Str );

    PDVE := PDVE2( iItem ); // get Labels Shift in LSU
    if PDVE = nil then
      ShiftXY := N_ZFPoint // Zero Shifts
    else
      ShiftXY := PFPoint(PDVE)^;

    for j := FirstInd to FirstInd+NumInds-1 do // along Points in Group
    begin
      DstOCanv.GetStringSize( Str, Dx, Dy );
      SVGUC := N_AffConvD2DPoint( CL.CCoords[j], DstOCanv.U2P ); // SVG User Coords

      SVGUC.X := SVGUC.X + ShiftXY.X*CurLSUPixSize - MLHotPoint.X*Dx/DstOCanv.CurLSUPixSize;
      SVGUC.Y := SVGUC.Y + ShiftXY.Y*CurLSUPixSize - MLHotPoint.Y*FontSize + 0.75*FontSize;

      GCOutSL.Add( Format( '    <text id="%s" x="%.0f" y="%.0f">%s</text>',
                         [ SVGIdPref+IntToStr(iItem), SVGUC.X,
                                             SVGUC.Y, SVGStr ] ));
    end; // for j := FirstInd to FirstInd+NumInds-1 do

    GCOutSLBuf.Flash();
  end; // for iItem := 0 to CL.WNumItems-1 do // loop along all Points in Layer

  GCOutSL.Add( '  </g>' );
  end; // with SetPCMapLayer()^, NGCont do
end; // end of procedure TN_UDMapLayer.DrawHorLabelsToSVG

//************************************ TN_UDMapLayer.DrawLayerToText ***
// Draw Self To Text (to StringList in SVG Context)
//
procedure TN_UDMapLayer.DrawLayerToText();
var
  i, id, CSInd: integer;
  idName: string;
  CS: TK_UDDCSpace;
  BP: TFPoint;
begin
  with PCMapLayer^ do
  begin
    if (MLType = mltPoints1) or (MLType = mltHorLabels) then
    with  NGCont do
    begin
      GCOutSL.Add( '***** Map Layer ' + ObjName );
      GCOutSL.Add( 'MLType=' + IntToStr(ord(MLType)) );
      GCOutSL.Add( 'NumItems=' + IntToStr(MLCObj.WNumItems) );
      GCOutSL.Add( 'MLCObjName=' + MLCObj.ObjName );
      GCOutSL.Add( 'MLCObjEnvRect=' + N_RectToStr( MLCObj.WEnvRect, 0 ) );

      BP := MLCObj.WEnvRect.TopLeft;
      BP.X := BP.X - 20; // debug for SocDemPrint Map
      BP.Y := BP.Y - 40; // debug
      GCOutSL.Add( 'TmpBP=' + N_PointToStr( BP, 0 ) );
      BP := FPoint(0,0);

      GCOutSL.Add( Format( 'TmpWidth=%.0f  TmpHeight=%.0f',
                        [ N_RectWidth(MLCObj.WEnvRect)+40,
                          N_RectHeight(MLCObj.WEnvRect)+40 ] ));

      GCOutSL.Add( '' );
      CS := MLCObj.GetCS();

      for i := 0 to MLCObj.WNumItems-1 do // along all Items
      with TN_UDPoints(MLCObj) do
      begin
        idName := '';
        if CS <> nil then
        begin
          CSInd := MLCObj.GetCSInd( i, 0 ); // temporary CDimInd = 0
          idName := PString(TK_PDCSpace(CS.R.P)^.Names.P(CSInd))^;
        end;

//        MLCObj.GetItemTwoCodes( i, 0, Id, N_i );
        Id := MLCObj.GetItemFirstCode( i, MLCDimInd );
        GCOutSL.Add( Format( 'ind=%d id=%d X=%.0f Y=%.0f idName=%s',
                            [i, Id, CCoords[i].X-BP.X,
                                                CCoords[i].Y-BP.Y, idName] ));

        if MLType = mltHorLabels then
        GCOutSL.Add( 'Label="' + PString(MLDVect1.PDE(i))^ + '"' )

      end; // for i := 0 to MLCObj.WNumItems do // along Items

      GCOutSL.Add( '' );
    end; // with  NGCont do, if (MLType = mltPoints1) or (MLType = mltHorLabels) then
  end; // with SetPCMapLayer()^ do
end; // end_of procedure TN_UDMapLayer.DrawLayerToText


//********** TN_SGMLayers class methods  **************

//******************************************** TN_SGMLayers.Create ***
//
constructor TN_SGMLayers.Create( ARFrame: TN_Rast1Frame );
begin
  Inherited;
end; // end_of constructor TN_SGMLayers.Create

//******************************************** TN_SGMLayers.Destroy ***
//
destructor TN_SGMLayers.Destroy();
begin
  inherited;
end; // end_of destructor TN_SGMLayers.Destroy

//**************************************** TN_SGMLayers.SearchInCurComp ***
// Search Inside Component with given Index
//
function TN_SGMLayers.SearchInCurComp(): boolean;
var
  InitialNCurSR: integer;
begin
  Result := False;
  CurMapLayer := TN_UDMapLayer(CurSComp);
  Assert( CurMapLayer.CI = N_UDMapLayerCI, 'Bad CMapLayer' );
  PCMapLayer := CurMapLayer.PISP();
  CurMLCObj := PCMapLayer^.MLCObj;
  Assert( CurMLCObj <> nil, 'Bad CurMLCObj' );
  SpecialCObjPtr := nil; // temporary not used

  InitialNCurSR := NCurSR; // before search in cur component
  if CurMLCObj.CI = N_UDPointsCI then SearchInPoints()
  else if CurMLCObj.CI = N_ULinesCI then SearchInLines()
  else if CurMLCObj.CI = N_UContoursCI then SearchInConts()
  else Assert( False, 'Bad CurMLCObj' );

  if NCurSR > InitialNCurSR then Result := True; // something was found
end; // function TN_SGMLayers.SearchInCurComp

//********************************************* TN_SGMLayers.SearchInPoints ***
// Search in TN_UDPoints
// CurSFlags - bit0($01) <>0 - use BasePoint, bit1($02) is ignored
//             bit1($02) <>0 - use sign (Label) PixRect (created while Drawing), bit0($01) should be 0
//             bit2($04) <>0 - use circle (real distance to BasePoint), otherwise check rect, bit0($01) should be <>0
//             bit3($08) <>0 - use MapLayer sign size (MLSSizeXY.X) otherwise use UserSearchSize
//
function TN_SGMLayers.SearchInPoints(): boolean;
var
  i, CurItemInd, FPInd, NumPoints: integer;
  Found: boolean;
  BDist: Double;
begin
  Result := False;
  with TN_UDPoints(CurMLCObj), PCMapLayer^ do
  begin

    BDist := 0.5 * UserSearchSize; // radius in User Units

    if (CurSFlags and $08) <> 0 then // use MapLayer sign size
    begin
      BDist := 0.5 * CurMapLayer.PIDP().MLSSizeXY.X; // radius in LLW
      BDist := BDist * RFrame.OCanv.CurLLWPixSize;   // radius in Pixels
      BDist := BDist * RFrame.OCanv.P2U.CX;          // radius in User Units
    end; // if (CurSFlags and $08) <> 0 then // use MapLayer sign size

    for CurItemInd := WNumItems-1 downto 0 do // loop along Items
    begin
      GetItemInds( CurItemInd, FPInd, NumPoints );

      if (CurSFlags and $01) <> 0 then //***** check BasePoint
      for i := NumPoints-1 downto 0 do
      begin
        if (CurSFlags and $04) <> 0 then // Check Circle, not Rect
//          Found := ( 0.5 * UserSearchSize >=
          Found := (BDist >= N_P2PDistance( CCoords[FPInd+i], CursorUPoint ))
        else // (CurSFlags and $04) = 0, Check Rect, not Circle
          Found := (0 = N_PointInRect( CCoords[FPInd+i], CursorURect ));

        if Found then
        with OneSR do
        begin
          SRCompInd := CurSCompInd;
          SRType := srtPoint;
          ItemInd := CurItemInd;
          PartInd := i;
          AddOneSR();
          Result := True;
          if (SGFlags and $01) = 0 then Exit;
        end;
      end; // if check BasePoint, for i := NumPoints-1 downto 0 do

      if ((CurSFlags and $02) <> 0) and
        (TN_UDMapLayer(CurSComp).MLPRects <> nil) then //***** check SearchRect
      for i := NumPoints-1 downto 0 do
      begin
        if 0 = N_PointInRect( CursorPPoint,
                              TN_UDMapLayer(CurSComp).MLPRects[FPInd+i] ) then
        with OneSR do
        begin
          SRCompInd := CurSCompInd;
          SRType := srtPixRect;
          ItemInd := CurItemInd;
          PartInd := i;
          AddOneSR();
          Result := True;
          if (SGFlags and $01) = 0 then Exit;
        end;
      end; // if check SearchRect, for i := NumPoints-1 downto 0 do

    end; // for CurItemInd := WNumItems-1 downto 0 do // loop along Items
  end; // with TN_UDPoints(CurMLCObj) do
end; // function TN_SGMLayers.SearchInPoints

//********************************************** TN_SGMLayers.SearchInLines ***
// Search in TN_ULines
//
// CurSFlags - bits 0,1 - see N_RectOverLine
//  bit0($01) <>0  check Polyline Segments
//  bit1($02) <>0  check only Polyline Vertexes
//  bit2($04) <>0  check if inside closed Line, otherwise check if over the Line only (see bits0,1)
//
function TN_SGMLayers.SearchInLines(): boolean;
var
  i, FPInd, NumInds, NumParts: integer;
  CurItemInd, CurItemSegmInd, CurItemVertInd: integer;
  MemPtr: TN_BytesPtr;
  CurCObjPtr: Pointer;
begin
  Result := False;
  N_s := CurMLCObj.ObjName; // for debug
  N_i := CurSFlags; // for debug

  with TN_ULines(CurMLCObj) do
  begin
    for CurItemInd := WNumItems-1 downto 0 do // loop along Items
    begin
    CurItemSegmInd := -1; // not defined flag
    CurItemVertInd := -1; // not defined flag

    if not N_FRectsCross( Items[CurItemInd].EnvRect, CursorURect ) then Continue;
    GetNumParts( CurItemInd, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty item

    for i := 0 to NumParts-1 do
    begin
      GetPartInds( MemPtr, i, FPInd, NumInds );

      if WLCType = N_FloatCoords then //***** Float Line coords
      begin
        CurCObjPtr := @LFCoords[FPInd];
        Result := N_RectOverLine( LFCoords, FPInd, NumInds, CursorURect,
                        CurSFlags and $3, CurItemSegmInd, CurItemVertInd );

        if (not Result) and ((CurSFlags and $04) <> 0) and
                        N_Same( LFCoords[FPInd], LFCoords[FPInd+NumInds-1] ) then
          Result := (0 = N_DPointInsideFRing( @LFCoords[FPInd], NumInds,
                                    Items[CurItemInd].EnvRect, CursorUPoint ));
      end else //***************************** Double Line coords
      begin
        CurCObjPtr := @LDCoords[FPInd];
        Result := N_RectOverLine( LDCoords, FPInd, NumInds, CursorURect,
                          CurSFlags and $3, CurItemSegmInd, CurItemVertInd );

        if (not Result) and ((CurSFlags and $04) <> 0) and
                        N_Same( LDCoords[FPInd], LDCoords[FPInd+NumInds-1] ) then
          Result := (0 = N_DPointInsideDRing( @LDCoords[FPInd], NumInds,
                                    Items[CurItemInd].EnvRect, CursorUPoint ));
      end;

      if Result and
         (SpecialCObjPtr = CurCObjPtr) and
         (CurItemVertInd <> FPInd) and
         (CurItemVertInd <> (FPInd+NumInds-1)) then Result := False;

      if Result then
      with OneSR do
      begin
        SRCompInd := CurSCompInd;
        SRType  := srtLine;
        ItemInd := CurItemInd;
        PartInd := i;
        VertInd := CurItemVertInd;
        SegmInd := CurItemSegmInd;

        AddOneSR();
        if (SGFlags and $01) = 0 then Exit;
      end;

    end; // for i := 0 to NumParts-1 do
    end; // for CurItemInd := WNumItems-1 downto 0 do // loop along Items
  end; // with TN_ULines(CurMLCObj) do
end; // function TN_SGMLayers.SearchInLines

//**************************************** TN_SGMLayers.SearchInConts ***
// Search in TN_UContours
//
function TN_SGMLayers.SearchInConts(): boolean;
var
  CurItemInd: integer;
  PosType: TN_PointPosType;
begin
  Result := False;
//  N_IAdd( Format( 'UC=(%.3f, %.3f) - %s', [CursorUPoint.X,CursorUPoint.Y,CurMLCObj.WComment] ));
  with TN_UContours(CurMLCObj) do
  begin
    for CurItemInd := WNumItems-1 downto 0 do // loop along Items
    begin
      PosType := DPointInsideItem( CurItemInd, CursorUPoint, @PosInfo );
      if PosType <> pptOutside then with OneSR do
      begin
        if PosType = pptInside   then SRType := srtContour;
        if PosType = pptOnBorder then SRType := srtBorder;

        Result := True;
        SRCompInd := CurSCompInd;
        ItemInd := CurItemInd;
        PartInd := PosInfo.RingInd;
        VertInd := PosInfo.RingLevel;
        AddOneSR();

        if (SGFlags and $01) = 0 then Exit;

      end; // if PosType <> pptOutside then with OneSR do
    end; // for CurItemInd := WNumItems-1 downto 0 do // loop along Items
  end; // with TN_UContours(CurMLCObj) do
end; // function TN_SGMLayers.SearchInConts

//**************************************** TN_SGMLayers.SnapToCurCObj ***
//  Snap given InpPoint to CurCObj if applicable, split CurCObj if needed
//  OutPoint - resulting coords (snapped or not)
//  return:
// 0 - not snapped
// 1 - snapped to external Vertex (with CurItemVertInd)
// 2 - snapped to internal Vertex (with CurItemVertInd)
// 3 - snapped to Segment         (with CurItemSegmInd)
//
function TN_SGMLayers.SnapToCurCObj( ASnapMode: integer; const InpPoint: TDPoint;
                                               out OutPoint: TDPoint ): integer;

var
  DC: TN_DPArray;
  CurCLine: TN_ULines;
begin
  DC := nil;
  Result := 0;
  OutPoint := InpPoint;

  with OneSR do
  begin

  if SRType <> srtLine then Exit;
  if CurMLCObj = nil then Exit;

  if ((CurMLCObj.ClassFlags and $FF) <> N_ULinesCI) or
     (ItemInd = -1) then Exit; // no CObj to snap

  CurCLine := TN_ULines(CurMLCObj); // to reduce code size
  CurCLine.GetPartDCoords( ItemInd, PartInd, DC );

  if ASnapMode = 2 then // snap only to external Vertexes
  begin
    if (VertInd = 0) or
       (VertInd = High(DC)) then // snap to CurItemVertInd
    begin
      OutPoint := DC[VertInd]; // snapped Vertex coords
      Result := 1;
    end;
  end; // if ASnapMode = 2 then // snap only to external Vertexes

  if (ASnapMode = 3) or (ASnapMode = 5) then // snap to all
  begin                               // Vertexes, including internal ones
    if VertInd >= 0 then // snap to any CurItemVertInd
    begin
      OutPoint := DC[VertInd]; // snapped Vertex coords

      if (VertInd = 0) or
         (VertInd = High(DC)) then // snap to CurItemVertInd
        Result := 1
      else
        Result := 2;
    end;
  end; // if (ASnapMode = 3) or (ASnapMode = 5) then // snap to all

  if (ASnapMode = 4) or (ASnapMode = 5) then // snap to Segment
  begin
    if SegmInd >= 0 then // snap to CurItemSegmInd
    begin
      OutPoint := N_ProjectPointOnSegm( InpPoint, DC[SegmInd], DC[SegmInd+1] );
      Result := 3;
    end;
  end; // if (ASnapMode = 4) or (ASnapMode = 5) then // snap to Segment

  end; // with OneSR do

end; // function TN_SGMLayers.SnapToCurCObj

//**************************************** TN_SGMLayers.SplitByPoint ***
// Split all (not ReadOnly) CObjLayers by given SplitPoint Coords
//
// if ASplitMode >= 1 and SegmInd >= 0 then add SplitPoint to SegmInd as new Vertex
// if ASplitMode = 2 then split all lines at SplitPoint
//
procedure TN_SGMLayers.SplitByPoint( ASplitMode: integer;
                                     const SplitPoint: TDPoint );

var
  i, j: integer;
  DC, TmpDLine: TN_DPArray;
  CurCLine: TN_ULines;
  VertexRefs: TN_VertexRefs;
begin
  DC := nil;

  with OneSR do
  begin
    if SRType <> srtLine then Exit;
    if CurMLCObj = nil then Exit;
    if CurMLCObj.CI() <> N_ULinesCI then Exit;

    CurCLine := TN_ULines(CurMLCObj); // to reduce code size
    CurCLine.GetPartDCoords( ItemInd, PartInd, DC );

    if (ASplitMode >= 1) and(SegmInd >= 0) then // Insert new Vertex into CurSegment
    begin
      SetLength( TmpDLine, 1 );
      TmpDLine[0] := SplitPoint;
      N_InsertArrayElems( DC, SegmInd+1, TmpDLine, 0, 1 );
      CurCLine.SetPartDCoords( ItemInd, PartInd, DC );
    end;

  end; // with OneSR do

  if ASplitMode <> 2 then Exit; // Splitting is not needed

  for i := 0 to High(SComps) do // loop along all search components (MapLayers)
  with SComps[i] do
  begin
    if SCReadOnly then Continue; // skip ReadOnly Components
    if SComp = nil then Continue; // a precaution
    CurCLine := TN_ULines(TN_UDMapLayer(SComp).PISP()^.MLCObj); // to reduce code size
    if CurCLine.CI() <> N_ULinesCI then Continue; // skip not ULines CObjLayers

    CurCLine.GetVertexRefs( SplitPoint, 2, VertexRefs ); // collect only internal Vertexes

    for j := 0 to High(VertexRefs) do // split lines at internal vertexes
    with VertexRefs[j] do
    begin
      CurCLine.SplitAuto( ItemInd, PartInd, VertInd );
    end; // for j := 0 to High(VertexRefs) do

  end; // for i := 0 to High(SComps) do // loop along all search components (MapLayers)

end; // function TN_SGMLayers.SplitByPoint

{
//***************************************** TN_UDCMap.GetAllCObjInds ***
// Get Array of All used in Self (even indirect) Cobj Inedexes in N_CObjectsDir
//
function TN_UDCMap.GetAllCObjInds(): TN_IArray;
  function GetInd( ACObj: TN_UDBase ): integer;
  // Return Index in N_CObjectsDir of given ACObj
  begin
    Result := N_CObjectsDir.IndexOfDEField( ACObj );
  end; // function GetInd

  procedure GetCObjInds( ACObj: TN_UDBase; var Inds: TN_IArray ); // local
  // Add (by OR) Indexes of ACObj child CObjects
  var
    i: integer;
  begin
    N_ORToIArray( Inds, GetInd( ACObj ) ); // add ACObj Index

    case ACObj.CI of // add Child CObjects if any

    N_UCObjRefsCI:
      for i:=N_CObjRefsChildInd to ACObj.DirHigh() do // loop along Refs to other Cobjects
        GetCObjInds( ACObj.DirChild( i ), Inds );

    N_UContoursCI:
      N_ORToIArray( Inds, GetInd( ACObj.DirChild(N_CObjLinesChildInd) ) );

    end; // case ACObj.CI of
  end; // procedure GetCObjInds (local)

var
  i: integer;
  ChildsRoot: TN_UDBase;
  CObjLayer: TN_UCObjLayer;
  UDCMapLayer: TN_UDCMapLayer;
  SA: TN_SArray;
begin                            // main body of GetAllCObjInds
  ChildsRoot := DirChild( K_cmpChildsInd );
  Result := nil;
  SA := nil;
  Result := TN_IArray(SA);
  N_ORToIArray( TN_IArray(SA), Integer(SA) );


  for i:=0 to ChildsRoot.DirHigh() do // loop along  Map Layers
  begin
    UDCMapLayer := TN_UDCMapLayer(ChildsRoot.DirChild(i));
    CObjLayer := TN_PCMapLayer(UDCMapLayer.PStat)^.MLCObj;
    GetCObjInds( CObjLayer, Result );
  end; // for i:=0 to ChildsRoot.DirLength()-1 do // loop along  Map Layers
end; // function TN_UDCMap.GetAllCObjInds

//***************************************** TN_UDCMap.GetAllCObjects ***
// Return Array of All used in Self (even indirect) CObjects
//
function TN_UDCMap.GetAllCObjects(): TN_UCObjLayerArray;

  procedure AddCObjects( ACObj: TN_UDBase; var Ptrs: TN_IArray ); // local
  // Add (by OR) Pointer to ACObj and it's child CObjects (if needed) to Ptrs
  var
    i: integer;
  begin
    N_ORToIArray( Ptrs, Integer(ACObj) ); // add Pointer to ACObj

    case ACObj.CI of // add Child CObjects if any

    N_UCObjRefsCI:
      for i:=N_CObjRefsChildInd to ACObj.DirHigh() do // loop along Refs to other Cobjects
        AddCObjects( ACObj.DirChild( i ), Ptrs );

    N_UContoursCI:
      N_ORToIArray( Ptrs, Integer(ACObj.DirChild(N_CObjLinesChildInd)) );

    end; // case ACObj.CI of
  end; // procedure AddCObjects (local)

var
  i: integer;
  ChildsRoot: TN_UDBase;
  CObjLayer: TN_UCObjLayer;
  UDCMapLayer: TN_UDCMapLayer;
begin                            // main body of GetAllCObjInds
  ChildsRoot := DirChild( K_cmpChildsInd );
  Result := nil;

  for i:=0 to ChildsRoot.DirHigh() do // loop along  Map Layers
  begin
    UDCMapLayer := TN_UDCMapLayer(ChildsRoot.DirChild(i));
    CObjLayer := TN_PCMapLayer(UDCMapLayer.PStat)^.MLCObj;
    AddCObjects( CObjLayer, TN_IArray(Result) );
  end; // for i:=0 to ChildsRoot.DirLength()-1 do // loop along  Map Layers
end; // function TN_UDCMap.GetAllCObjects

//********************************************* TN_UDCMap.DeleteAllObjects ***
// Delete All Map Objects (including Self) except Data Vectors
//
procedure TN_UDCMap.DeleteAllObjects();
var
  i: integer;
  CObjects: TN_UCObjLayerArray;
  CObj: TN_UCObjLayer;
begin
  CObjects := GetAllCObjects();
  N_MapsDir.DeleteOneChild( Self ); // delete Self subtree

  for i := 0 to N_CObjectsDir.DirHigh() do // delete CObjects from N_CObjectsDir
  begin
    CObj := TN_UCObjLayer(N_CObjectsDir.DirChild( i ));
    if (CObj.RefCounter = 1) and
       (-1 <> N_SearchInIArray( Integer(CObj), TN_IArray(CObjects) ) ) then
      N_CObjectsDir.DeleteOneChild( CObj ); // CObj was only in Self
  end;

  N_CObjectsDir.DeleteOneChild( nil ); // remove all empty entries
end; // end of procedure TN_UDCMap.DeleteAllObjects

//********************************************* TN_UDCMap.CopyAllObjects ***
// Copy All Map Objects (including Self) except Data Vectors,
// return created UDCMap (full copy of Self)
//
//   How to change Self and CObjects ObjNames (Layers Names remain the same):
// ANewLC - New Last Characters (new ASrcName postfix)
// ANumLC - Number of Last Characters to delete from ASrcName
//
function TN_UDCMap.CopyAllObjects( ANewLC: string; ANumLC: integer ): TN_UDCMap;
  function GetCopy( ACObj: TN_UDBase ): TN_UDBase; // local
  // create and return a Copy of given ACObj if not yet
  var
    i: integer;
    NewName: string;
  begin
    NewName := N_ChangeName( ACObj.ObjName, ANewLC, ANumLC );
    Result := N_GetUObj( N_CObjectsDir, NewName );
    if Result <> nil then Exit; // already exists

    Result := N_CreateCObjCopy( TN_UCObjLayer(ACObj) );
    Result.ObjName := NewName;
    N_CObjectsDir.AddOneChildV( Result );

    N_ReplaceChildRefs1( ACObj, Result );

    case ACObj.CI of

    N_UCObjRefsCI:
      for i:=N_CObjRefsChildInd to ACObj.DirHigh() do // loop along Refs to other Cobjects
        Result.PutDirChildV( i, GetCopy( ACObj.DirChild( i ) ) );

    N_UContoursCI:
    begin
      i := N_CObjLinesChildInd;
      Result.PutDirChildV( i, GetCopy( ACObj.DirChild( i ) ) );
    end;

    end; // case ACObj.CI of

  end; // function GetCopy - local

var               // main body of TN_UDCMap.CopyAllObjects
  i: integer;
  UDCMapLayer, UDCMapLayerN: TN_UDCMapLayer;
  ChildsRoot: TN_UDBase;
  CObjLayer: TN_UCObjLayer;
begin
  Result := TN_UDCMap(CloneSubTree( K_cmpCloneSelf )); // copy self
  Result.ObjName := N_ChangeName( ObjName, ANewLC, ANumLC );
  N_ReplaceChildRefs1( GetDataRoot(), Result.GetDataRoot( True ) );

  ChildsRoot  := DirChild( K_cmpChildsInd );

  for i:=0 to ChildsRoot.DirHigh() do // copy Map Layers with new CObjLayers
  begin
    UDCMapLayer := TN_UDCMapLayer(ChildsRoot.DirChild(i));
    UDCMapLayerN := TN_UDCMapLayer(UDCMapLayer.CloneSubTree( K_cmpCloneSelf ));

    CObjLayer := TN_PCMapLayer(UDCMapLayer.PStat)^.MLCObj;
    K_SetUDRefField( TN_UDBase(TN_PCMapLayer(UDCMapLayerN.PStat)^.MLCObj),
                                                         GetCopy( CObjLayer ) );
    Result.InsertChildComp( UDCMapLayerN ); // add new MapLayer to New map
  end; // for i:=0 to ChildsRoot.DirHigh() do // copy Map Layers with new CObjLayers

end; // end of function TN_UDCMap.CopyAllObjects
}


//********************************* TN_RFAShowUserInfo.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAShowUserInfo.SetActParams();
begin
  ActName := 'ShowUserInfo';
  inherited;
end; // procedure TN_RFAShowUserInfo.SetActParams();

//********************************* TN_RFAShowUserInfo.Execute ***
// Show User Info about CurCObj (CObj under Cursor) in MouseMove
//
procedure TN_RFAShowUserInfo.Execute();
var
  Ind: integer;
  Str: string;
begin
  inherited;

  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
  begin

  if CHType <> htMouseMove then Exit;

  if SRType = srtNone then
  begin
    ShowString( ActFlags, '' );
    Exit;
  end;

{  // debug
  N_ADS( Format( '%d %d %d %d', [SRCompInd, ItemInd,
              PInteger(ReIndVects[0].R.P)^, PInteger(ReIndVects[1].R.P)^ ] ));
  N_i := SRCompInd;
  N_i := ItemInd;
  N_i := PInteger(ReIndVects[0].R.P)^;
}
  Ind := TN_UDMapLayer(SComps[SRCompInd].SComp).PCMapLayer^.MLCObj.GetItemFirstCode( ItemInd, 0 ) - 1;

  if (Ind >= 0) and (Ind <= High(InfoStrings)) then
    Str := InfoStrings[Ind]
  else
    Str := '';

  ShowString( ActFlags, Str );

  end; // with ActGroup, ActGroup.RFrame do
end; // procedure TN_RFAShowUserInfo.Execute


//****************** Global procedures **********************

//****************************************  N_CreateUDMapLayer  ******
// Create and return UDMapLayer based on given CobjLayer
// AMLType - Map Layer Type:
//           =0 - Default; =1 - Horizontal Labels; =2 - Line Labels;
//           =3 - Curve Labels; =4 - Plain TextBoxes;
//
function N_CreateUDMapLayer( ACObjLayer: TN_UCObjLayer; AMLType: TN_MLType ): TN_UDMapLayer;
var
  ClassInd: integer;
  PCMapLayer: TN_PCMapLayer;
begin
  Assert( ACObjLayer <> nil, N_SError );
  Result := TN_UDMapLayer(K_CreateUDByRTypeName( 'TN_RMapLayer', 1, N_UDMapLayerCI ));
  ClassInd := ACObjLayer.CI;
  if ClassInd = N_UCObjRefsCI then
    ClassInd := ACObjLayer.DirChild( N_CObjRefsChildInd ).CI;

  if AMLType = mltNotDef then
  begin
    case ClassInd of
      N_UDPointsCI:  AMLType := mltPoints1;
      N_ULinesCI:    AMLType := mltLines1;
      N_UContoursCI: AMLType := mltConts1;
    end; // case ClassInd of
  end;

  Result.ObjName := 'ML' + ACObjLayer.ObjName;

  PCMapLayer := Result.InitMLParams( AMLType );
  K_SetUDRefField( TN_UDBase(PCMapLayer^.MLCObj), ACObjLayer );
end; // end of function N_CreateUDMapLayer

//******************************************************** N_CalcMapEnvRect ***
// Calc User Coords EnvRect for all or given child MapLayers and set it to MapRoot CompUCoords
//
//     Parameters
// AMapRoot  - Given Map Root Component (usually TN_UDPanel)
// ACoef     - How to increase EnvRect of all child MapLayers
// AMapLayer - given MapLayer with needed MLCObj.WEnvRect
// Result    - Returns calculated EnvRect (increased by ACoef)
//
function N_CalcMapEnvRect( AMapRoot: TN_UDCompVis; ACoef: double; AMapLayer: TN_UDMapLayer = nil ): TFRect;
var
  i: integer;
  MapEnvRect, CObjEnvRect: TFRect;
  CurUDBase: TN_UDBase;
begin
  MapEnvRect.Left := N_NotAFloat;
  Result := MapEnvRect;
  if AMapRoot = nil then Exit; // a precaution
  if ACoef <= 0 then ACoef := 1.0;

  if AMapLayer = nil then // use all MapLayers
  begin
    for i := 0 to AMapRoot.DirHigh() do // along all child Components (along all MapLayers)
    begin
      CurUDBase := AMapRoot.DirChild( i );
      if not (CurUDBase is TN_UDMapLayer) then Continue; // skip if not MapLayer

      //*** Skip if CBSkipSelf flag is set
      if TN_UDMapLayer(CurUDBase).PSP()^.CCompBase.CBSkipSelf <> 0 then Continue;

      CObjEnvRect := TN_UDMapLayer(CurUDBase).PISP()^.MLCObj.WEnvRect;
      N_FRectOr( MapEnvRect, CObjEnvRect );
    end; // for i := 0 to AMapRoot.DirHigh() do // along all child Components
  end else // AMapLayer <> nil, get MapEnvRect from it
  begin
    MapEnvRect := AMapLayer.PISP()^.MLCObj.WEnvRect;
  end;

  MapEnvRect := N_RectScaleR( MapEnvRect, ACoef, N_05DPoint );

  AMapRoot.PCCS()^.CompUCoords := MapEnvRect;
  Result := MapEnvRect;
end; // function N_CalcMapEnvRect

//*********************************************************** N_PrepareMap1 ***
// Clone CObjects if they are not exists and create MapLayers if not yet
//
//     Parameters
// ASrcUObjDir - given Source CObjects Dir
// ADstUObjDir - given Destination CObjects Dir
// AMapRoot    - Given Map Root Component (usually TN_UDPanel)
// ACoef       - How to increase EnvRect of all child MapLayers
//
// Clone all CObjects in ASrcUObjDir to ADstUObjDir if not yet and create
// MapLayers (for all copied CObjects) in AMapRoot Dir if not yet
//
procedure N_PrepareMap1( ASrcUObjDir, ADstUObjDir, AMapRoot: TN_UDBase );
var
  i: integer;
  CurSrcUObj, DstUObj, UDMapLayer: TN_UDBase;
begin
  if (ASrcUObjDir = nil) or (ADstUObjDir = nil) then Exit; // a precaution

  for i := 0 to ASrcUObjDir.DirHigh() do // along all UObjects in ASrcUObjDir
  begin
    //*** Check if CObj already exists in ADstUObjDir

    CurSrcUObj := ASrcUObjDir.DirChild( i );
    if not (CurSrcUObj is TN_UCObjLayer) then Continue; // copy only CObjLayer

    DstUObj := ADstUObjDir.DirChildByObjName( CurSrcUObj.ObjName );

    if DstUObj <> nil then Continue; // already exists, skip copiing

    //***** Create CurSrcUObj clone and add it to ADstUObjDir

    DstUObj := CurSrcUObj.Clone( True ); // Create new CObj
    ADstUObjDir.AddOneChildV( DstUObj );

    //*** Check if appropriate UDMapLayer already exists in AMapRoot

    if AMapRoot = nil then Continue;
    UDMapLayer := AMapRoot.DirChildByObjName( 'ML' + DstUObj.ObjName );
    if UDMapLayer <> nil then Continue; // already exists, skip creating

    //***** Create appropriate UDMapLayer and add it to AMapRoot

    UDMapLayer := N_CreateUDMapLayer( TN_UCObjLayer(DstUObj) );
    AMapRoot.AddOneChildV( UDMapLayer );

  end; // for i := 0 to ASrcUObjDir.DirHigh() do // along all UObjects in ASrcUObjDir

end; // procedure N_PrepareMap1

const N_UserInfoGName = 'UserInfoGName';

//****************************************************** N_AddCompsToSearch ***
// Add to given ARFrame Components to Search on MouseMove
//
procedure N_AddCompsToSearch( ARFrame: TN_Rast1Frame; APFirstComp: TN_PUDCompVis;
                                                      ANumComps: integer );
var
  i, Ind: integer;
  SearchGroup: TN_SGMLayers;
  SCompCObj: TN_UCObjLayer;
begin
  with ARFrame do
  begin

  Ind := GetGroupInd( N_UserInfoGName );
  if Ind >= 0 then with RFSGroups do Remove( Items[Ind] ); // remove prev. group

  SearchGroup := TN_SGMLayers.Create( ARFrame );
  RFSGroups.Add( SearchGroup );

  with SearchGroup do
  begin
    GName := N_UserInfoGName;
    SetLength( SComps, ANumComps );

    for i := 0 to ANumComps-1 do
    with SComps[i] do
    begin
      SComp  := APFirstComp^;
      Inc( APFirstComp );

      SCompCObj := TN_UDMapLayer(SComp).PISP()^.MLCObj;

      if SCompCObj is TN_UDPoints then
      begin
        SFlags := $8 + $4 + $1;
      end;

      if SCompCObj is TN_ULines then
      begin
        SFlags := $4;
      end;

      if SCompCObj is TN_UContours then
      begin
        SFlags := $0; // not used for TN_UContours
      end;

    end; // with SComps[i] do, for i := 0 to ANumComps-1 do

    SetAction( N_ActShowUserInfo, $01, -1, 0 );
  end; // with SearchGroup do

  end; // with ARFrame do
end; // end of procedure N_AddCompsToSearch

//****************************************************** N_AddCompToSearch ***
// Add to given ARFrame one given AComp to Search on MouseMove with given Params
// AComp = nil means removing all previously added Components
// Components should be added in same order as in Map Tree
//
// ARFrame         - TN_Rast1Frame to which AComp shoud be added
// AComp           - UDMapLayer to search for User objects
// ASearchFlags    - Search Flags:
//
// APixSearchSize  - SearchSize in Pixels
// AUserSearchSize - SearchSize in User Units
//
procedure N_AddCompToSearch( ARFrame: TN_Rast1Frame; AComp: TN_UDCompVis;
                   ASearchFlags, APixSearchSize: integer; AUserSearchSize: float );
var
  Ind: integer;
  SearchGroup: TN_SGMLayers;
begin
  if ARFrame = nil then Exit; // a preaution

  with ARFrame do
  begin

  Ind := GetGroupInd( N_UserInfoGName );

  if AComp = nil then // remove Group with all previously added Components
  begin
    if Ind >= 0 then
      with RFSGroups do
        Remove( Items[Ind] ); // remove prev. group

    Exit; // all done
  end; // if AComp = nil then // remove all previously added Components

  if Ind = -1 then // Group not found, Create it
  begin
    SearchGroup := TN_SGMLayers.Create( ARFrame );
    SearchGroup.GName := N_UserInfoGName;
    SearchGroup.SetAction( N_ActShowUserInfo, $01, -1, 0 );

    RFSGroups.Add( SearchGroup );
  end else // Ind >= 0, Group already exists
    SearchGroup := TN_SGMLayers(RFSGroups.Items[Ind]);

  with SearchGroup do
  begin
    Ind := Length(SComps);
    SetLength( SComps, Ind+1 );

    with SComps[Ind] do
    begin
      SFlags := ASearchFlags;
      PixSearchSize  := APixSearchSize;
      UserSearchSize := AUserSearchSize;
      SComp  := AComp;
    end; // with SComps[Ind] do

  end; // with SearchGroup do

  end; // with ARFrame do
end; // end of procedure N_AddCompToSearch

{
Initialization
  N_ClassRefArray[N_UDMapLayerCI]  := TN_UDMapLayer;
  N_ClassTagArray[N_UDMapLayerCI]  := 'MapLayer';

  N_RFAClassRefs[N_ActShowUserInfo] := TN_RFAShowUserInfo;
}
end.
