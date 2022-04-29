unit N_UDat4;
// Layers of Coords Objects
//
// type TN_UCObjLayer  = class( TN_UDBase )     // abstract CObjects Layer
// type TN_UCObjRefs   = class( TN_UCObjLayer ) // CObj subsets layer
// type TN_UDPoints    = class( TN_UCObjLayer ) // Double Points layer
// type TN_LinesItem   = class( TObject )       // one Lines Item
// type TN_ULines      = class( TN_UCObjLayer ) // Lines layer
// type TN_UContours   = class( TN_UCObjLayer ) // Contours layer

// type TN_UDBaseLib  = class( TN_UDBase ) // Base Binary Items Library
// type TN_UDOwnFont  = class( TN_UDBase ) // Own Phisical Font (Raster or Vector)

interface
uses Windows, Classes, Types,
     K_UDT1, K_VFunc, K_SBuf, K_STBuf, K_DCSpace, K_CSpace,
     N_Types, N_Lib1, N_Gra0, N_Gra1;

const
  N_CFIndMask    = $00FFFFFF; // Index bits (bits $3F000000 are not used now)
  N_CFIndShift   = 24;        // number of bits in N_CFIndMask

                          // CFInd cpecial bits (out of N_CFIndMask):
  N_MultiPartBit  = $01000000; // <> 0 for MultiPart Items
  N_EmptyItemBit  = $02000000; // <> 0 for Empty Items
  N_HiddenItemBit = $04000000; // <> 0 for Hidden Items

                          // WFlags bits (bit0 is not used):
  N_RunTimeContent = $001;  // Items should NOT be saved to Archive
  N_ChildIndsBit   = $002;  // ChildInds array  exists
  N_RCXYBit        = $004;  // RCXY      array  exists
  N_BezierBit      = $008;  // Line Coords are Bezier Spline
  N_TmpObjBit      = $020;  // CObj is Temporary Object and may be deleted
                            //   from N_CObjectsDir if RefCounter <= 1
  N_IgnoreIndsBit = $040;   // Ignore Item Indexes while loading from Text

                    // fixed Child indexes:
  N_CObjLinesChildInd = 1; // for Border Lines (for Contours only)
  N_CObjRefsChildInd  = 1; // for first base CObj (for CObjRefs only)


type TN_CItem = record //***** one Coords Obj Item
                       // (Subset, FPoint, DPoint, FLine, DLine, Contour)
  CFInd:  integer; // Item First Index (see N_CFIndMask, N_CCTypeMask)
  CCInd:  integer; // Item Code First Index in BCodes Array
  EnvRect: TFRect; // Item EnvRect
end; // type TN_CItem = record
type TN_CItems = array of TN_CItem;

// type TK_UDCDims = Array of TK_UDCDim;

type TN_ItemsCodesOpFlags = Set Of // Items by Codes Operation Flags
  (
    icofCopy,   // Copy Items from Self to DstCObj
    icofMove,   // Move Items from Self to DstCObj
    icofDelete  // Delete Items from Self
  );

type TN_ItemsCodesCondFlags = Set Of // Items Codes Condition Flags
  (
    iccfFirstCode, // First Code should be checked
    iccfIsInside,  // Is inside given Set of Codes
    iccfIsOutside  // Is outside (not inside) given Set of Codes
  );

type TN_UCObjLayer = class( TN_UDBase ) // abstract CObjects Layer
  Public
  WComment:  string;   // Whole layer Comment string
  WFlags:    integer;  // Whole CObjects Layer Flags:
         // bit0 ($001) =1 - (N_RunTimeContent) Items should NOT be saved to Archive
         // bit1 ($002) =1 - (N_ChildIndsBit) ChildInds array exists
         // bit2 ($004) =1 - (N_RCXYBit)      RCXY      array exists
         // bit3 ($008) =1 - (N_BezierBit)    Line Coords are Bezier Spline
         // bit4 ($010)    - not used
         // bit5 ($020) =1 - (N_TmpObjBit)    CObj is Temporary Object
         // bit6 ($040) =1 - (N_IgnoreIndsBit) Ignore Item Indexes while loading from Text
  WAccuracy:   integer;  // Whole layer Accuracy (Number of decimal digits)
  WLCType:     integer;  // Whole Layer Coords Type (0-float, 1-double)
  WItemsCSName: string;  // Items Codes Space UObjName (for setting WItemsCSObj)
  WItemsCSObj: TK_UDDCSpace; // Items Codes Space Object (WItemsCS.ObjName=WItemsCSName, runtime field)
  WCDimNames: TN_SArray; // Codes Dimension Names (Runtime Array, filled by WCDimNames string tag attribute)
  WUDCDims:  TK_UDCDims; // not used and not needed? Codes Dimension Objects (without increasing RefCounter!)
  WEnvRect:     TFRect;  // Whole layer EnvRect
  WNumItems:   integer;  // Whole Number of Items ( WNumItems <= High(Items) )
  WIsSparse:   boolean;  // Layer has empty or sparse Items

  Items:     TN_CItems;  // array of Items
  BCodes:    TN_IArray;  // Items pairs of CDimInd, Code (one pair in one Int, CDimInd in high byte)
  WrkFlags:  TN_IArray;  // Working Flags (RunTime field, may be used by
                         // application, syncronized with Items, not used now)
  constructor Create;  override;
  destructor  Destroy; override;

    //************* TN_UDBase methods of TN_UCObjLayer
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( SBuf: TK_SerialTextBuf; AShowFlags : Boolean = true ): Boolean; override;
  function  GetFieldsFromText ( SBuf: TK_SerialTextBuf ): Integer; override;
  procedure CopyFields ( SrcObj: TN_UDBase ); override;
  function  SameFields ( SrcObj: TN_UDBase; AFlags: integer ): boolean; override;
  function  CDimIndsConv ( UDCD: TN_UDBase; PConvInds: PInteger; RemoveUndefInds: Boolean ): Boolean; override;

    //************* TN_UCObjLayer methods
  procedure InitItems       ( ANumItems: integer );
  function  AddItemsSys     (): integer;
  procedure AddCItem        ( SBuf: TK_SerialTextBuf; Ind: Integer; AStr: string = '*' ); virtual;
  function  GetCItem        ( SBuf: TK_SerialTextBuf; var NumInds: Integer;
                                           APItemStr: PString = nil  ): integer;
  procedure CopyScalarFields ( SrcObj: TN_UDBase );
  procedure CopyBaseFields   ( SrcObj: TN_UDBase );
  procedure MoveFields       ( SrcObj: TN_UDBase ); virtual;
  procedure SetEmptyFlag     ( BegItemInd: integer; NumItems: integer = 1 );
  procedure ClearEmptyFlag   ( BegItemInd: integer; NumItems: integer = 1 );
  function  ItemIsEmpty      ( AItemInd: integer ): boolean;
  procedure GetItemInds      ( ItemInd: integer; out AFirstInd, ANumInds: integer);
  procedure CompactSelf      (); virtual;
  procedure UnSparseSelf     (); virtual; abstract;
  function  GetSizeInBytes   (): integer; virtual;
  procedure GetSelfInfo      ( SL: TStrings; Mode: integer ); overload; virtual;
  procedure CalcItemEnvRect  ( ItemInd: integer ); virtual; abstract;
  procedure CalcEnvRects     ();
  function  GetItemCenter    ( ItemInd: integer ): TDPoint;

  procedure ClearAllCodes   ();
  procedure SetItemAllCodes ( AItemInd: integer; APCodes: PInteger; ANumInts: integer ); overload;
  procedure SetItemAllCodes ( ASelfItemInd: integer; ASrcCObj: TN_UCObjLayer; ASrcItemInd: integer ); overload;
  procedure GetItemAllCodes ( AItemInd: integer; out APCodes: PInteger; out ANumInts: integer ); overload;
  procedure GetItemAllCodes ( AItemInd: integer; var AIArray: TN_IArray; out ANumInts: integer ); overload;
  function  GetItemAllCodes ( AItemInd: integer ): string; overload;
  procedure AddXORItemCode  ( AItemInd: integer; APCodes: PInteger; ANumCodes: integer; AMode: integer );
  procedure SetCCode        ( AItemInd, ACode: integer );
  function  GetCCode        ( AItemInd: integer ): integer;
  function  GetItemFirstCode  ( AItemInd, ACDimInd: integer ): integer;
  procedure SetItemTwoCodes ( AItemInd, ACDimInd, ACode1, ACode2: integer );
  procedure GetItemTwoCodes ( AItemInd, ACDimInd: integer; out ACode1, ACode2: integer );
  procedure SetItemThreeCodes ( AItemInd, ACDim0Code1, ACDim1Code1, ACDim1ACode2: integer );
  procedure GetItemThreeCodes ( AItemInd: integer; out ACDim0Code1, ACDim1Code1, ACDim1ACode2: integer );
  function  ItemHasCode       ( AItemInd, ACodeInt: integer ): boolean;
  function  GetPtrToFirstCode ( AItemInd, ACDimInd: integer; out ANumRestCodes: integer ): PInteger;
  procedure GetCDimMinMaxCodes( ACDimInd: integer; out AMinCode, AMaxCode: integer );
  procedure ItemsByCodesOp ( ADstCObj: TN_UCObjLayer; AOpFlags: TN_ItemsCodesOpFlags;
                             ACondFlags: TN_ItemsCodesCondFlags; ACDimInd: integer; APSetOfCodes: TN_PSetOfIntegers );

  procedure ConvSelfCoords ( AFunc: TN_ConvDPFuncObj; APAuxPar: Pointer = nil ); virtual; abstract;
  procedure AffConvSelf    ( AAffCoefs: TN_AffCoefs4 );  overload; virtual; abstract;
  procedure AffConvSelf    ( AAffCoefs: TN_AffCoefs6 );  overload; virtual; abstract;
  procedure AffConvSelf    ( AAffCoefs: TN_AffCoefs8 );  overload; virtual; abstract;
  procedure GeoProjSelf    ( var AGeoProjPar: TN_GeoProjPar; AConvMode: integer ); virtual; abstract;

  procedure CopyContent    ( SrcObj: TN_UDBase );
  function  GetCS          ( ACDimInd: integer = 0 ): TK_UDDCSpace;
  function  GetCSInd       ( AItemInd, ACDimInd: integer ): integer;
  procedure SetCodesByUDPoints ( AUDPoints: TN_UCObjLayer );

{
  function  GetCSS         (): TK_UDDCSSpace;
  procedure SetCSS         ( ACSS: TK_UDDCSSpace );
  procedure UpdateCSS      ();
  function  CreateCSS      ( ACS: TK_UDDCSpace ): TK_UDDCSSpace;
  procedure CCodesToCsInds ( ACS: TK_UDDCSpace );
  procedure CsIndsToCCodes ();
  procedure ReplaceCCodesByCSInds ( IntCodes: TK_UDVector );
  function  ReplaceCCodesCS       ( NewCS: TK_UDDCSpace ): TK_UDDCSSpace;
}
end; // type TN_UCObjLayer = class( TN_UDBase );
type TN_UCObjLayerArray = Array of TN_UCObjLayer;

type TN_UCObjRefs = class( TN_UCObjLayer ) // layer of CObj subsets
                                            // CFInd - index of CObjInds array
  Public
  ChildInds: TN_IArray;  // base CObjects Layers indexes  (syncr. with Items)
  CObjInds:  TN_IArray;  // indexes of elements of subsets (Item's elements)
  WRefsReservedInt1: Integer; // reserved
  WRefsReservedInt2: Integer; // reserved

  constructor Create;  override;
  destructor  Destroy; override;

    //************* TN_UDBase methods of TN_UCObjRefs
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( SBuf: TK_SerialTextBuf;
                            AShowFlags : Boolean = true ) : Boolean; override;
  function  GetFieldsFromText ( SBuf: TK_SerialTextBuf ) : Integer; override;
  procedure CopyFields ( SrcObj: TN_UDBase ); override;
  function  SameFields ( SrcObj: TN_UDBase; AFlags: integer ): boolean; override;

    //************* TN_UCObjLayer methods of TN_UCObjRefs
  procedure CompactSelf     (); override;
  procedure UnSparseSelf    (); override;
  function  GetSizeInBytes  (): integer; override;
  procedure GetSelfInfo     ( SL: TStrings; Mode: integer ); override;
  procedure CalcItemEnvRect ( ItemInd: integer ); override;
  procedure InitItems       ( ANumItems, ANumRefs: integer );
  procedure ConvSelfCoords  ( AFunc: TN_ConvDPFuncObj; APAuxPar: Pointer = nil ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs4 ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs6 ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs8 ); override;
  procedure GeoProjSelf     ( var AGeoProjPar: TN_GeoProjPar; AConvMode: integer ); override;
//  procedure AffConv ( SrcCObjLayer: TN_UCObjLayer; AAffCoefs: TN_AffCoefs4 ); override;

    //************* TN_UCObjRefs methods
  procedure AddLastEmptyItem ();
  procedure AddRef ( RefItemInd: integer; BaseCLayer: TN_UCObjLayer = nil );
  // Should have some UDBase children (TN_UDPoints, TN_ULines or TN_UContours)
end; // type TN_UCObjRefs = class( TN_UCObjLayer )

type TN_UDPoints = class( TN_UCObjLayer ) //***** Double Points Layer
                                        // CFInd - index of first Point in Group
  Public
  CCoords: TN_DPArray;   // Double Points Coords
  WrkFPInd: integer;     // index in CCoords, used in GetPointCoords
  WPointsReservedInt1: Integer; // reserved
  WPointsReservedInt2: Integer; // reserved
  constructor Create;  override;
  destructor  Destroy; override;

    //************* TN_UDBase methods of TN_UDPoints
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( SBuf: TK_SerialTextBuf;
                                AShowFlags: Boolean = true ): Boolean; override;
  function  GetFieldsFromText ( SBuf: TK_SerialTextBuf ): Integer; override;
  procedure CopyFields ( SrcObj: TN_UDBase ); override;
  function  SameFields ( SrcObj: TN_UDBase; AFlags: integer ): boolean; override;

    //************* TN_UCObjLayer methods of TN_UDPoints
  procedure CompactSelf     (); override;
  procedure UnSparseSelf    (); override;
  function  GetSizeInBytes  (): integer; override;
  procedure GetSelfInfo     ( SL: TStrings; Mode: integer ); override;
  procedure CalcItemEnvRect ( ItemInd: integer ); override;
  procedure InitItems       ( ANumItems, ANumPoints: integer );
  procedure ConvSelfCoords  ( AFunc: TN_ConvDPFuncObj; APAuxPar: Pointer = nil ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs4 ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs6 ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs8 ); override;
  procedure GeoProjSelf     ( var AGeoProjPar: TN_GeoProjPar; AConvMode: integer ); override;

    //************* TN_UDPoints methods
  procedure DeleteOnePoint  ( ItemInd, PartInd: integer );
  procedure AddOnePointItem ( ADPoint: TDPoint; ACode: integer = -1 );
  procedure AddOnePointItems( ANumPoints: integer; APPoint: PDPoint; APCode: PInteger = nil );
  function  GetPointCoords  ( ItemInd, PartInd: integer ): TDPoint;
  function  ReplaceItem     ( PFirstPoint: PDPoint; NumPoints: integer;
                                             ItemInd: integer = -1 ): integer;
  procedure SnapToGrid      ( const Origin, Step: TDPoint );
  procedure AddGridNodes    ( const ARect: TFRect; const AOrigin, AStep: TDPoint;
                                                   const APNXNY: PPoint = nil );
  // Can have Self Codes SubSpace as UDBase child
end; // type TN_UDPoints = class( TN_UDPoints )

type TN_ULinesItem = class; // forvard reference
     TN_ULines     = class; // forvard reference

     TN_ULinesItem = class( TObject ) //***** one ULines Item (contains no Codes)
  Public
  INumParts:    integer;    // Number of Parts in Item
  INumPoints:   integer;    // Number of Points in IPartCoords
  ICType:       integer;    // Item's Coords Type (0-float, 1-double)
  IPartFCoords: TN_FPArray; // all Item's Parts Float Coords
  IPartDCoords: TN_DPArray; // all Item's Parts Double Coords
  IPartRInds:   TN_IArray;  // first Part point Relative Indexes
                            // (IPartRInds[INumParts] = INumPoints)

  constructor Create( CoordsType: integer );
  destructor  Destroy; override;
  procedure Init ();
  procedure AddPartCoords ( const SrcCoords: TN_FPArray; SrcInd, NumInds: integer); overload;
  procedure AddPartCoords ( const SrcCoords: TN_DPArray; SrcInd, NumInds: integer); overload;
  procedure AddParts      ( ULines: TN_ULines; ItemInd: integer;
                                              ABegPartInd, ANumParts: integer );
  procedure CreateSegmItem ( const P1, P2: TFPoint; Mode: integer ); overload;
  procedure CreateSegmItem ( const P1, P2: TDPoint; Mode: integer ); overload;
end; // type TN_ULinesItem = class( TObject )


     TN_ULines = class( TN_UCObjLayer ) //***** Lines Layer (Float or Double)
                        // CFInd - index of first Vertex in CCoords array
    Public
  WrkFPInd:     integer;  // used in GetNumParts, GetPartInds procedures
  WrkNumInds:   integer;  // used in GetNumParts, GetPartInds procedures
  WrkFPointPtr: Pointer;  // = @CCoords[WrkFPInd], used in Get/SetPartDCoords
  WrkRegCodes: TN_IArray; // used in GetRegCodes as temporary storage

  LFCoords:  TN_FPArray; // Line Vertexes Float Coords (and Lists Info)
  LDCoords:  TN_DPArray; // Line Vertexes Float Coords (and Lists Info)

  constructor Create  (); override; // for use in loading DTree
  constructor Create1 ( CoordsType: integer; AObjName: string = 'New'; AAccuracy: integer = 4; ACSName: string = '' );
  constructor Create2 ( SrcULines: TN_ULines );
  destructor  Destroy; override;

    //************* TN_UDBase methods of TN_ULines
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( SBuf: TK_SerialTextBuf;
                                AShowFlags: Boolean = true ): Boolean; override;
  function  GetFieldsFromText ( SBuf: TK_SerialTextBuf ): Integer; override;
  procedure CopyFields ( SrcObj: TN_UDBase ); override;
  procedure CopyCoords ( SrcObj: TN_UDBase );
  function  SameFields ( SrcObj: TN_UDBase; AFlags: integer ): boolean; override;
  function  GetIconIndex (): Integer; override;

    //************* TN_UCObjLayer methods of TN_ULines
  procedure AddCItem ( SBuf: TK_SerialTextBuf; Ind: Integer; AStr: string ); override;
  procedure MoveFields      ( SrcObj: TN_UDBase ); override;
  procedure CompactSelf     (); override;
  procedure UnSparseSelf    (); override;
  function  GetSizeInBytes  (): integer; override;
  procedure GetSelfInfo     ( SL: TStrings; Mode: integer ); override;
  procedure CalcItemEnvRect ( ItemInd: integer ); override;
  procedure InitItems       ( ANumItems, ANumPoints: integer ); overload;
  procedure InitItems       ( AULines: TN_ULines; ACoef: float = 1.0 ); overload;
  procedure ConvSelfCoords  ( AFunc: TN_ConvDPFuncObj; APAuxPar: Pointer = nil ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs4 ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs6 ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs8 ); override;
  procedure GeoProjSelf     ( var AGeoProjPar: TN_GeoProjPar; AConvMode: integer ); override;
//  procedure AffConv ( SrcCObjLayer: TN_UCObjLayer; AAffCoefs: TN_AffCoefs4 ); override;

    //************* TN_ULines methods
  procedure GetPartInds ( AMemPtr: TN_BytesPtr; PartInd: integer;
                      out AFirstInd: integer; out ANumInds: integer ); overload;
  procedure GetPartInds ( ItemInd, PartInd: integer;
                      out AFirstInd: integer; out ANumInds: integer ); overload;
  function  GetWNumParts (): integer;
  procedure GetNextPart( var ItemInd, PartInd: integer;
                              out AFirstInd: integer; out ANumInds: integer );
  procedure GetNumParts ( ItemInd: integer; out AMemPtr: TN_BytesPtr;
                                            out ANumParts: integer ); overload;
  function  GetNumParts ( ItemInd: integer): integer; overload;
  procedure DeleteParts ( ItemInd, BegPartInd, ANumParts: integer );
  procedure GetPartDCoords ( ItemInd, PartInd: integer;
                                                    var DCoords: TN_DPArray );
  procedure SetPartDCoords ( var ItemInd, PartInd: integer;
                          const DCoords: TN_DPArray; ANumPoints: integer = -1 );
  procedure GetOneDPoint  ( CCInd: integer;  out  DVertex: TDPoint );
  procedure SetOneDPoint  ( CCInd: integer; const DVertex: TDPoint );
  procedure GetVertexRefs ( const DVertex: TDPoint; Mode: integer;
                                              var VertexRefs: TN_VertexRefs );
  procedure CangeVertexCoords ( const DVertex: TDPoint;
                                            const VertexRefs: TN_VertexRefs );
  function  AddULItem    ( InpULines: TN_ULines; InpItemInd, InpPartInd,
                 NumParts: integer; WrkLineItem: TN_ULinesItem = nil ): integer;
  procedure AddULItems   ( InpULines: TN_ULines; BegItemInd, NumItems: integer );
  procedure AddConvertedItems ( ASrcUlines: TN_ULines; AConvProc: TN_2DPAProcObj;
                                ABegItem: integer = 0; ANumItems: integer = -1;
                                             WrkLineItem: TN_ULinesItem = nil );
  procedure SplitItem    ( ItemInd, PartInd, VertexInd: integer );
  procedure SplitPart    ( ItemInd, PartInd, VertexInd: integer );
  procedure SplitAuto    ( ItemInd, PartInd, VertexInd: integer );
  function  CombineItems ( const VertexRefs: TN_VertexRefs ): integer;
  function  AutoCombineItems (): integer;
  function  ReplaceItemCoords ( ULinesItem: TN_ULinesItem; ItemInd: integer ): integer; overload;
  function  ReplaceItemCoords ( ULinesItem: TN_ULinesItem; ItemInd: integer;
                                      ACDim0C1: integer; ACDim1C1: integer = -2;
                                      ACDim1C2: integer = -2 ): integer; overload;
  function  ReplaceItemCoords ( ULinesItem: TN_ULinesItem; ItemInd: integer;
                                ASrcULines: TN_ULines; ASrcItemInd: integer ): integer; overload;
  procedure SmoothSelf ( Mode: integer; MinDelta, MaxDelta, DeltaCoef: double );
  function  FindByEndPoints  ( const P1, P2: TDPoint ): integer;
  procedure SetCodesByULines ( SrcULines: TN_ULines );
  procedure SnapToGrid       ( const Origin, Step: TDPoint );
  procedure DeleteSameVertexes ();
  procedure AddSegmentItem ( const P1, P2: TFPoint ); overload;
  procedure AddSegmentItem ( const P1, P2: TDPoint ); overload;
  procedure AddRectItem    ( const ARect: TFRect );
  procedure AddSimpleItem  ( const DCoords: TN_DPArray; ANumPoints: integer = -1;
                                                        AOneCode: integer = -1 );
//  procedure AddRoundRectItem ( const ARect: TFRect; APCPanel: TN_PCPanel;
//                                 ALLWUSize: float; NumCornerPoints: integer;
//                                                         ABorderWidth: float );
  procedure AddGridSegments ( const ARect: TFRect; const Origin, Step: TDPoint );
  procedure AddHorLines     ( const ARect: TFRect; const Origin, Step: TDPoint );
  procedure AddVertLines    ( const ARect: TFRect; const Origin, Step: TDPoint );
end; // type TN_ULines = class( TN_UCObjLayer )
type TN_AULines = array of TN_ULines;

type TN_PointInContInfo = record // Info about Point position inside UContour
  BLines: TN_ULines;     // Border ULines (CObj with UContour Borders)
  BLineInd: integer;     // Border Line Index (in BorderLines)
  BLineSegmInd: integer; // Border Line Segment Index (in BorderLine)
  RingInd: integer;      // Ring Index in current contour
  RingLevel: integer;    // Ring Level (>= 0)
end; // type TN_PointInContInfo = record
type TN_PPointInContInfo = ^TN_PointInContInfo;

type TN_CRing = record // one Countour's Ring attributes
  REnvRect: TFRect; // Ring's Envelope Rect
  RFlags: integer;  // binary Ring flags:
     // bits0-7 ($00FF) - Ring's Level (0-255)
     // bit8    ($0100) - first ring's Line direction (=0-straight, =1-reversed)
  RLInd: integer; // initial Ring's line index in LinesInds array
                  // ( NumberOfLines = CRings[J+1].RLInd - CRings[J].RLInd )
  RFCoords: TN_FPArray; // whole Ring's Float border coords
  RDCoords: TN_DPArray; // whole Ring's Double border coords
end; // type TN_CRing = record
type TN_CRings = array of TN_CRing;

type TN_UContours = class( TN_UCObjLayer ) //***** Contours Layer
                      // CFInd - index of first Ring in CRings array
    Public
  CRings:    TN_CRings;
  LinesInds: TN_IArray;

  constructor Create;  override;
  destructor  Destroy; override;

    //************* TN_UDBase methods of TN_UContours
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( SBuf: TK_SerialTextBuf;
                                AShowFlags: Boolean = true ): Boolean; override;
  function  GetFieldsFromText ( SBuf: TK_SerialTextBuf ): Integer; override;
  procedure CopyFields ( SrcObj: TN_UDBase ); override;
  function  SameFields ( SrcObj: TN_UDBase; AFlags: integer ): boolean; override;

    //************* TN_UCObjLayer methods of UContours
  procedure CompactSelf     (); override;
  procedure UnSparseSelf    (); override;
  function  GetSizeInBytes  (): integer; override;
  procedure GetSelfInfo     ( SL: TStrings; Mode: integer ); override;
  procedure CalcItemEnvRect ( ItemInd: integer ); override;
  procedure InitItems       ( ANumItems, ANumRings, ANumLines: integer );
  procedure ConvSelfCoords  ( AFunc: TN_ConvDPFuncObj; APAuxPar: Pointer = nil ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs4 ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs6 ); override;
  procedure AffConvSelf     ( AAffCoefs: TN_AffCoefs8 ); override;
  procedure GeoProjSelf     ( var AGeoProjPar: TN_GeoProjPar; AConvMode: integer ); override;
//  procedure AffConv ( SrcCObjLayer: TN_UCObjLayer; AAffCoefs: TN_AffCoefs4 ); override;

    //************* TN_UContours methods
  procedure ClearCoordsOKFlags ();
  procedure SetSelfULines    ( AULines: TN_ULines );
  function  GetSelfULines    (): TN_ULines;
  function  AddUCItem        ( InpUConts: TN_UContours; InpItemInd: integer ): integer;
  procedure MakeRingsCoords  ();
  function  DPointInsideItem ( ItemInd: integer; DPoint: TDPoint;
                            PInfo: TN_PPointInContInfo = nil ): TN_PointPosType;
  // Should have UDBase child with index=N_CObjLinesChildInd of TN_ULines type
end; // type TN_UContours = class( TN_UCObjLayer )

TN_LibItemType = (litNotdef, litRaster, litMetafile, LitDashAttr, LitHatchAttr );

type TN_LibItem = record //***** one Sign Element Attributes
  LIName:   string;
  LICode:   integer;
  FirstByte: integer; // First Index
  NumBytes:  integer; // Number of Indexes
end; // type TN_LibItem = record
type TN_LibItems = array of TN_LibItem;

type TN_UDBaseLib = class( TN_UDBase ) //***** Base Items Library
      public
  LIComment: string;       // Comment string
  LIType: TN_LibItemType;  // Items Type
  LINumItems: integer;     // Number of Items in Library
  Items: TN_LibItems;      // Items attributes (see TN_LibItem)
  LIData: TN_BArray;       // Items binary data
  constructor Create;  override;
  destructor  Destroy; override;

    //************* TN_UDBase methods of TN_UDBaseLib
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  procedure SaveToStrings     ( Strings: TStrings; Mode: integer ); override;
  function  AddFieldsToText   ( SBuf: TK_SerialTextBuf;
                            AShowFlags : Boolean = true ) : Boolean; override;
  function  GetFieldsFromText ( SBuf: TK_SerialTextBuf ) : Integer; override;
  procedure CopyFields  ( SrcObj: TN_UDBase ); override;
  function  SameFields  ( SrcObj: TN_UDBase; AFlags: integer ): boolean; override;

    //************* TN_UDBaseLib methods
  procedure CompactSelf ();
  function  GetSizeInBytes (): integer;

  function  GetItemInd ( ACode: integer ): Integer; overload;
  function  GetItemInd ( AName: string ): Integer; overload;
  function  AddItem    ( ACode: integer; AName: string;
                              AData: TN_BArray; ADataSize: integer ): Integer;
  procedure ReplaceItem( AInd, ACode: integer; AName: string;
                                        AData: TN_BArray; ADataSize: integer );
  procedure DeleteItem ( AInd: integer );
  procedure MoveItem   ( AOldInd, ANewInd: integer );
end; // type TN_UDBaseLib = class( TN_UDBase )

type TN_CharCodeRange = record // Characters Code Range (for TN_UDOwnFont)
  MinCode: integer; // Min Character Code in Range
  MaxCode: integer; // Max Character Code in Range
  MinInd:  integer; // index of Character with MinCode
end; // end of type TN_CharRangePar = record
type TN_CharCodeRanges = array of TN_CharCodeRange;

type TN_UDOwnFont = class( TN_UDBase ) // Own Phisical Font (Raster or Vector)
                                       // Font Data are in child UDBaseLib obj
                                       // Not used now
  FaceName:     string;
  FontType:     integer; // =1 - Raster, =2 - vector,
  BreakChar:    integer;
  DefCharInd:   integer;
  CharHeight:   integer;
  CharMaxWidth: integer;
  BaseLineOfs:  integer;
  CharCodeRanges: TN_CharCodeRanges;
  CharWidths: TN_IArray;
      public
  constructor Create; override;
  destructor  Destroy; override;

    //************* TN_UDBase methods of TN_UDOwnFont
  procedure AddFieldsToSBuf   ( SBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( SBuf: TN_SerialBuf ); override;
  procedure SaveToStrings   ( Strings: TStrings; Mode: integer ); override;
  function  AddFieldsToText   ( SBuf: TK_SerialTextBuf;
                             AShowFlags : Boolean = true ) : Boolean; override;
  function  GetFieldsFromText ( SBuf: TK_SerialTextBuf ) : Integer; override;
  procedure CopyFields ( SrcObj: TN_UDBase ); override;
  function  SameFields ( SrcObj: TN_UDBase; AFlags: integer ): boolean; override;

    //************* TN_UDOwnFont methods
  function  GetCharIndex ( CharCode: integer ): Integer;
  function  GetDefaultChar (): integer;
end; // type TN_UDOwnFont = class( TN_UDBase )

type TN_TestCObjectsA = record
  MainRect: TFRect;
  NSubRectX: integer;
  NSubRectY: integer;
  SubRectXCoef: double;
  SubRectYCoef: double;

  ShapeType: integer;
  ShapeElems: integer;
  ShapeCoef1: double;
  ShapeCoef2: double;

  CreateFlags: integer;
  ItemCode: integer;

  SubRect: TFRect;
end; // TN_TestCObjectsA = record


//****************** Global procedures **********************

function  N_CreateCObjCopy ( ASrcCObj: TN_UCObjLayer ): TN_UCObjLayer;
function  N_PrepSameCObj   ( ASrcCObj: TN_UCObjLayer; ADstCobjParent: TN_UDBase; ADstCObjName: string ): TN_UCObjLayer;
function  N_PrepEmptyCObj  ( ACobjParent: TN_UDBase; ACObjName: string;  AClassInd, AAccuracy, ACType: integer; ACSName: string = '' ): TN_UCObjLayer;
procedure N_SetPartsInfo   ( AMemPtr: TN_BytesPtr; APartRInds: TN_IArray;
                             ANumParts, APointSize: integer; out RFPInd: integer );
procedure N_ConvFLinesToDLines ( const FLines: TN_ULines; var DLines: TN_ULines );
procedure N_ConvDLinesToFLines ( const DLines: TN_ULines; var FLines: TN_ULines );

procedure N_MakeRingCoords ( AULines: TN_ULines; LinesInds: TN_IArray;
          BegLineInd, NumLines: integer; var RingCoords: TN_FPArray ); overload;
procedure N_MakeRingCoords ( AULines: TN_ULines; LinesInds: TN_IArray;
          BegLineInd, NumLines: integer; var RingCoords: TN_DPArray ); overload;

procedure N_AddTestCObjects1 ( UALines: TN_ULines; var Params: TN_TestCObjectsA );
procedure N_AddTestCObjects2 ( UALines: TN_ULines; Params: TN_TestCObjectsA );

function  N_EncodeCObjCodeInt ( ACDimInd, ACode: integer ): integer;
procedure N_DecodeCObjCodeInt ( ACObjCodeInt: integer; out ACDimInd, ACode: integer );
procedure N_GetNextCObjCodes  ( APCodes: PInteger; ANumAllInts: integer;
                      var ABegInd: integer; out ACDimInd, ANumDimInts: integer );
procedure N_GetCDimCObjCodes  ( APAllCodes: PInteger; ANumAllInts, ACDimInd: integer;
                                       out ACDimOffset, ANumCDimInts: integer );
function  N_CObjCodesToString ( APCodes: PInteger; ANumInts: integer ): string;
procedure N_StringToCObjCodes ( AStrCodes: string; var AIArray: TN_IArray;
                                                   out ANumInts: integer );


procedure N_AddTagAttrDef ( ASTBuf: TK_SerialTextBuf; AttrName: string;
                     const AttrValue; AType: TK_ParamType; ADefValue: integer );
procedure N_GetTagAttrDef ( ASTBuf: TK_SerialTextBuf; AttrName: string;
                     out AttrValue; AType : TK_ParamType; ADefValue : integer );
var
  N_Items: TN_CItems; // array of Items for view in debugger
  N_Item:  TN_CItem;  // one Item for view in debugger

implementation
uses SysUtils, StrUtils, Math,
     K_CLib0, K_UDConst, K_Parse,
     N_Lib0, N_ClassRef, N_Deb1, N_Lib2, N_ME1, N_InfoF;


//********** TN_UCObjLayer class methods  **************

//**************************************************** TN_UCObjLayer.Create ***
//
constructor TN_UCObjLayer.Create;
begin
  inherited Create;
  InitItems( 0 );
end; // end_of constructor TN_UCObjLayer.Create

//*************************************************** TN_UCObjLayer.Destroy ***
//
destructor TN_UCObjLayer.Destroy;
begin
  Items      := nil;
  WrkFlags   := nil;
  WCDimNames := nil;
  WUDCDims   := nil;
  BCodes     := nil;

  inherited Destroy;
end; // end_of destructor TN_UCObjLayer.Destroy

//******************************************* TN_UCObjLayer.AddFieldsToSBuf ***
// save self to Serial Binary Buf
//
procedure TN_UCObjLayer.AddFieldsToSBuf( SBuf: TN_SerialBuf );
var
  BCodesSize: integer;
begin
  Inherited;
  SBuf.AddRowInt   ( WFlags );
  SBuf.AddRowString( WComment );
  SBuf.AddRowInt   ( WAccuracy );
  SBuf.AddRowInt   ( WLCType );
  SBuf.AddRowString( WItemsCSName );
  SBuf.AddRowBytes ( sizeof(WEnvRect), @WEnvRect );

  SBuf.AddRowInt   ( WNumItems );
  SBuf.AddRowBytes ( (WNumItems+1)*SizeOf(Items[0]), @Items[0] );

  BCodesSize := Items[WNumItems].CCInd;
  SBuf.AddRowInt( BCodesSize );
  if BCodesSize > 0 then
    SBuf.AddRowBytes ( BCodesSize*Sizeof(BCodes[0]), @BCodes[0] );

  SBuf.AddStringArray( WCDimNames );

  N_i := integer(WIsSparse);
  SBuf.AddRowInt( N_i );
end; // end_of procedure TN_UCObjLayer.AddFieldsToSBuf

//***************************************** TN_UCObjLayer.GetFieldsFromSBuf ***
// load self from Serial Binary Buf
//
procedure TN_UCObjLayer.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
var
  BCodesSize: integer;
begin
  Inherited;
  SBuf.GetRowInt   ( WFlags );
  SBuf.GetRowString( WComment );
  SBuf.GetRowInt   ( WAccuracy );
  SBuf.GetRowInt   ( WLCType );
  SBuf.GetRowString( WItemsCSName );
  SBuf.GetRowBytes ( sizeof(WEnvRect), @WEnvRect );

  SBuf.GetRowInt( WNumItems );
  SetLength( Items, WNumItems+1 );
  SBuf.GetRowBytes( (WNumItems+1)*SizeOf(Items[0]), @Items[0] );

  SBuf.GetRowInt( BCodesSize );
  SetLength( BCodes, BCodesSize );
  if BCodesSize > 0 then
    SBuf.GetRowBytes( BCodesSize*Sizeof(BCodes[0]), @BCodes[0] );

  SBuf.GetStringArray( WCDimNames );

  WrkFlags    := nil; // RunTime field
  WItemsCSObj := nil; // RunTime field

  SBuf.GetRowInt( N_i );
  WIsSparse := boolean(N_i);
end; // end_of procedure TN_UCObjLayer.GetFieldsFromSBuf

//******************************************* TN_UCObjLayer.AddFieldsToText ***
// save self to Serial Text Buf
//
function TN_UCObjLayer.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ): Boolean;
var
  i: integer;
  Str, Fmt: string;
begin
  inherited AddFieldsToText( SBuf, AShowFlags );

  N_AddTagAttrDef( SBuf, 'WFlags',       WFlags,    K_isHex, 0 );
  N_AddTagAttrDef( SBuf, 'WComment',     WComment,  K_isString, 0 );
  N_AddTagAttrDef( SBuf, 'WAccuracy',    WAccuracy, K_isInteger, 0 );
  N_AddTagAttrDef( SBuf, 'WLCType',      WLCType,   K_isInteger, 0 );
  N_AddTagAttrDef( SBuf, 'WrkNumItems',  WNumItems, K_isInteger, 0 ); // used in descendants GetFieldsFromText methods
  N_AddTagAttrDef( SBuf, 'WrkIsSparse',  WIsSparse, K_isBoolean, 0 ); // may be changed in descendants GetFieldsFromText methods
  N_AddTagAttrDef( SBuf, 'WItemsCSName', WItemsCSName, K_isString, 0 );

  if Length(WCDimNames) > 0 then // assemble all CDimNames into one string
  begin
    Str := '';

    for i := 0 to High(WCDimNames) do
    begin
      if WCDimNames[i] <> '' then
        Str := Format( '%s %d %s', [Str, i, WCDimNames[i]] );
    end; // for i := 0 to High(WCDimNames) do

    SBuf.AddTagAttr( 'WCDimNamesStr', Str, K_isString );
  end; // if Length(WCDimNames) > 0 then  // assemble all CDimNames into one string

  if WEnvRect.Left <> N_NotAFloat then
  begin
    Fmt := '%' + Format( '.%df ', [WAccuracy] );
    Str := Format( Fmt+Fmt+Fmt+Fmt, [WEnvRect.Left,  WEnvRect.Top,
                                     WEnvRect.Right, WEnvRect.Bottom] );
    SBuf.AddTagAttr( 'WEnvRect', Str, K_isString );
  end;

  Result := True;
end; // end_of procedure TN_UCObjLayer.AddFieldsToText

//***************************************** TN_UCObjLayer.GetFieldsFromText ***
// load self from Serial Text Buf
//
function TN_UCObjLayer.GetFieldsFromText( SBuf: TK_SerialTextBuf ): Integer;
var
  i, NumTokens, NumCDims, CDimInd: integer;
  Str: string;
  WrkSArray: TN_SArray;
begin
  inherited GetFieldsFromText(SBuf);

  N_GetTagAttrDef( SBuf, 'WFlags',       WFlags,    K_isHex,     0 );
  N_GetTagAttrDef( SBuf, 'WComment',     WComment,  K_isString,  0 );
  N_GetTagAttrDef( SBuf, 'WAccuracy',    WAccuracy, K_isInteger, 0 );
  N_GetTagAttrDef( SBuf, 'WLCType',      WLCType,   K_isInteger, 0 );
  // Note: WrkNumItems Tag is used in TN_UCObjLayer descendants GetFieldsFromText method
  N_GetTagAttrDef( SBuf, 'WrkIsSparse',  WIsSparse, K_isBoolean, 0 ); // may be changed in descendants GetFieldsFromText methods
  N_GetTagAttrDef( SBuf, 'WItemsCSName', WItemsCSName, K_isString, 0 );

  WItemsCSObj := nil; // WItemsCSObj is RunTime field

  Str := '';
  SBuf.GetTagAttr( 'WCDimNamesStr', Str, K_isString );
  if Str <> '' then // fill WCDimNames array by tokens in WCDimNamesStr String
  begin             // Str example: "0 Rus89 4 DCS 2 Rus89" (Int Name Int Name ...)
    WrkSArray := nil;
    NumTokens := N_ScanSArray( Str, WrkSArray );
    NumCDims := NumTokens div 2;

    for i := 0 to NumCDims-1 do // along all given CDim Names (tokens pairs)
    begin
      CDimInd := N_ScanInteger( WrkSArray[2*i] );
      if (CDimInd >= 0) and (CDimInd <= 255) then
      begin
        if High(WCDimNames) < CDimInd then
          SetLength( WCDimNames, CDimInd+1 );

        WCDimNames[CDimInd] := WrkSArray[2*i + 1];
      end;
    end; // for i := 0 to NumCDims-1 do

  end else // Str = ''
    WCDimNames := nil;

  Str := '';
  SBuf.GetTagAttr( 'WEnvRect', Str, K_isString );
  if Str = '' then WEnvRect := N_NotAFRect
              else WEnvRect := N_ScanFRect( Str );

  WrkFlags := nil; // RunTime field

  Result := 0;
end; // end_of procedure TN_UCObjLayer.GetFieldsFromText

//************************************************ TN_UCObjLayer.CopyFields ***
// copy to self given TN_UCObjLayer object (including Obj Name,Aliase,Info)
//
procedure TN_UCObjLayer.CopyFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution
  Assert( SrcObj is TN_UCObjLayer, 'Not CObj!' );

//  call inherited is not needed, because it is called inside CopyScalarFields
  CopyScalarFields( SrcObj );

  Items    := Copy( TN_UCObjLayer(SrcObj).Items );
  BCodes   := Copy( TN_UCObjLayer(SrcObj).BCodes );
  WrkFlags := Copy( TN_UCObjLayer(SrcObj).WrkFlags );
end; // end_of procedure TN_UCObjLayer.CopyFields

//************************************************ TN_UCObjLayer.SameFields ***
// returns True if all self.fields are the same as given SrcObj.fields
// (SrcObj must be of the same class as self)
//
function TN_UCObjLayer.SameFields( SrcObj: TN_UDBase; AFlags: integer ): boolean;
var
  N1, N2: integer;
  Label NotSame;
begin
  Result := Inherited SameFields( SrcObj, AFlags ); // prelimenary value
  if Result = False then Exit; // not same

  if (WComment     <> TN_UCObjLayer(SrcObj).WComment) or
     (WFlags       <> TN_UCObjLayer(SrcObj).WFlags) or
     (WAccuracy    <> TN_UCObjLayer(SrcObj).WAccuracy) or
     (WLCType      <> TN_UCObjLayer(SrcObj).WLCType) or
     (WItemsCSName <> TN_UCObjLayer(SrcObj).WItemsCSName) or
     (WNumItems    <> TN_UCObjLayer(SrcObj).WNumItems) then goto NotSame;
  // WrkFlags should not be compared

  if not N_Same( WEnvRect, TN_UCObjLayer(SrcObj).WEnvRect ) then goto NotSame;

  N1 := (WNumItems+1)*Sizeof(Items[0]);

  with TN_UCObjLayer(SrcObj) do
    N2 := (WNumItems+1)*Sizeof(Items[0]);

  if not N_SameBytes( @Items[0], N1, @TN_UCObjLayer(SrcObj).Items[0], N2 ) then goto NotSame;

  N1 := Items[WNumItems].CCInd;

  with TN_UCObjLayer(SrcObj) do
    N2 := Items[WNumItems].CCInd;

  if not N_SameInts( @BCodes[0], N1, @TN_UCObjLayer(SrcObj).BCodes[0], N2 ) then goto NotSame;

  Exit; // Self and Src obj have same fields values

  NotSame: // Self and Src obj do NOT have same fields values
    Result := False;
end; // end_of procedure TN_UCObjLayer.SameFields

//********************************************** TN_UCObjLayer.CDimIndsConv ***
// Conv self CDim Codes (Indexes)
//
function TN_UCObjLayer.CDimIndsConv( UDCD: TN_UDBase; PConvInds: PInteger;
                                           RemoveUndefInds: Boolean ): Boolean;
begin
  Result := True;
  // not yet
end; // end_of function TN_UCObjLayer.CDimIndsConv


    //************* TN_UCObjLayer methods

//************************************************* TN_UCObjLayer.InitItems ***
// Set WNumItems = 0, clear all Self Arrays except WCDimNames
// ( it is set in TN_UCObjLayer.GetFieldsFromText method )
// and increase Items array size if needed
//
procedure TN_UCObjLayer.InitItems( ANumItems: integer );
begin
  WNumItems := 0;

  WUDCDims  := nil;
  BCodes    := nil;
  WrkFlags  := nil;

  if ANumItems < 0 then ANumItems := 0; // a precaution

  if Length(Items) <= (ANumItems+1)  then // Length(Items) should be >= WNumItems+1
  begin
    Items := nil; // to avoid moving data
    SetLength( Items, ANumItems+1 );
  end;

  Items[0].CFInd := 0;
  Items[0].CCInd := 0;
end; // end_of procedure TN_UCObjLayer.InitItems

//*********************************************** TN_UCObjLayer.AddItemsSys ***
// Add one last Element to Items Array, Inc WNumItems and
// return just added Item index
// Note: Items[WNumItems].CFInd has no system bits (can be used without N_CFIndMask)
//
function TN_UCObjLayer.AddItemsSys(): integer;
begin
  Result := WNumItems;

  if High(Items) < (Result+1) then
    SetLength( Items, N_NewLength( Result+1 ));

  Items[Result+1] := Items[Result]; // Copy CFInd and CCInd fields

  // clear all possible flags in last Items to enable using
  // Items[WNumItems].CFInd as number of elements without using N_CFIndMask

  Items[Result+1].CFInd := Items[Result+1].CFInd and N_CFIndMask;

  Inc( WNumItems );
end; // function TN_UCObjLayer.AddItemsSys

//************************************************** TN_UCObjLayer.AddCItem ***
// Add: Item's Index, Codes, Flags, Size(NumInds) and given AStr to Serial Text Buf
//
// Remarks:
// - AStr is used only for ULines (as NumParts value)
// - temporary Codes Token should begin with Space
// - This method is used in AddFieldsToText method of TN_UCObjLayer descendant objects
//
procedure TN_UCObjLayer.AddCItem( SBuf: TK_SerialTextBuf; Ind: Integer;
                                                          AStr: string = '*' );
var
  NumInds: integer;
  CodesStr: string;
begin
  NumInds := Items[Ind].CFInd and N_CFIndMask;
  NumInds := (Items[Ind+1].CFInd and N_CFIndMask) - NumInds;
  CodesStr := GetItemAllCodes( Ind );

  SBuf.AddToken( Format( '%.6d  " %s"  $%.2x  %d %s', [Ind, CodesStr,
             (Items[Ind].CFInd shr N_CFIndShift), NumInds, AStr] ), K_ttString );
  SBuf.AddEOL();
end; // end of procedure TN_UCObjLayer.AddCItem

//************************************************** TN_UCObjLayer.GetCItem ***
// Check end of Items and Get from Serial Text Buf Item's Codes, NumInds and Flags,
// increase Items length if needed
// Return Last added Item Index or -1 if no more items
//
// If N_IgnoreIndsBit of WFlags is set, ignore Item's Inds, otherwise add empty Items if needed
//
// ( Used in GetFieldsToText method of TN_UCObjLayer descendant objects )
//
function TN_UCObjLayer.GetCItem( SBuf: TK_SerialTextBuf; var NumInds: Integer;
                                                 APItemStr: PString ): integer;
var
  ItemInd, CCSys, NumInts: integer;
  Str, CodesStr: string;
  WrkIArray: TN_IArray;
begin
//  N_i := SBuf.GetRowNumber( 0 );


  WrkIArray := nil; // to avoid warning
  N_T2b.Start( 16 );
  SBuf.GetToken( Str ); // Str is Item Index or N_EndOfArray token
  N_T2b.Stop( 16 );
  if (Str = N_EndOfArray) then // end of items
  begin
    Result := -1;
  N_T2b.Stop( 16 );
    Exit;
  end;

  if (WFlags and N_IgnoreIndsBit) = 0 then // Check Item Index, Add Empty Items if needed
  begin
    ItemInd := StrToInt( Str );
    if WNumItems > ItemInd then
      N_i1 := SBuf.GetRowNumber( 0 );

    Assert( WNumItems <= ItemInd, 'Inds not ordered!' ); // Items Inds should be ordered

    while WNumItems < ItemInd do // add needed number of Empty Items
      SetEmptyFlag( AddItemsSys() );
  end; // if (WFlags and N_IgnoreIndsBit) = 0 then // Check Item Index, Add Empty Items if needed

  Result := AddItemsSys(); // create new last Item
  N_T2b.Start( 17 );
  SBuf.GetScalar( CodesStr, K_isString ); // Item's Codes
  N_T2b.Stop( 17 );

//  N_s := CodesStr; // debug
//  N_AddStr( 0, Format( '%s %d %s', [ObjName, Result, CodesStr] ) ); // debug

  N_T2b.Start( 4 );
  N_StringToCObjCodes( CodesStr, WrkIArray, NumInts );
  N_T2b.Stop( 4 );

  N_T2b.Start( 18 );
  if NumInts > 0 then
    SetItemAllCodes( Result, @WrkIArray[0], NumInts );
  N_T2b.Stop( 18 );

  N_T2b.Start( 19 );
  SBuf.GetScalar( CCSys, K_isInteger ); // Item's Flags
  N_T2b.Stop( 19 );

  with Items[Result] do
  begin
    CFInd := CFInd or (CCSys shl N_CFIndShift);
    EnvRect.Left := N_NotAFloat;
  end;

  N_T2b.Start( 20 );
  SBuf.GetScalar( NumInds, K_isInteger ); // Item's NumInds
  N_T2b.Stop( 20 );

// this token is absent in old formats of Points and Contours objects
// in new format always CodesStr[1] = ' ' (temporary)

  Str := '';
  if (CodesStr[1] = ' ') or (CI = N_ULinesCI) or (CI = N_UContoursCI) then
    SBuf.GetScalar( Str, K_isString ); // Token not used while loading

  if APItemStr <> nil then APItemStr^ := Str;
end; // end of function TN_UCObjLayer.GetCItem

//****************************************** TN_UCObjLayer.CopyScalarFields ***
// Copy to self given TN_UCObjLayer object Scalar fields
//
procedure TN_UCObjLayer.CopyScalarFields( SrcObj: TN_UDBase );
begin
  inherited CopyFields( SrcObj ); // TN_UDBase.CopyFields is called!
  WComment     := TN_UCObjLayer(SrcObj).WComment;
  WFlags       := TN_UCObjLayer(SrcObj).WFlags;
  WAccuracy    := TN_UCObjLayer(SrcObj).WAccuracy;
  WLCType      := TN_UCObjLayer(SrcObj).WLCType;
  WItemsCSName := TN_UCObjLayer(SrcObj).WItemsCSName;

  WEnvRect  := TN_UCObjLayer(SrcObj).WEnvRect;
  WNumItems := TN_UCObjLayer(SrcObj).WNumItems;
  WIsSparse := TN_UCObjLayer(SrcObj).WIsSparse;
end; // end_of procedure TN_UCObjLayer.CopyScalarFields

//******************************************** TN_UCObjLayer.CopyBaseFields ***
// copy to self given TN_UCObjLayer object fields (same as CopyFields)
// (is needed if SrcObj is TN_UCObjLayer descendant,
//  and has overriden CopyFields procedure)
//
procedure TN_UCObjLayer.CopyBaseFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution
//  CopyFields( SrcObj ); // does not work, TN_ULines.CopyFields is called!

    //************************* same code as in CopyFields :
  CopyScalarFields( SrcObj );

  Items    := Copy( TN_UCObjLayer(SrcObj).Items );
  BCodes   := Copy( TN_UCObjLayer(SrcObj).BCodes );
  WrkFlags := Copy( TN_UCObjLayer(SrcObj).WrkFlags );

  WCDimNames := Copy( TN_UCObjLayer(SrcObj).WCDimNames );
  WUDCDims   := Copy( TN_UCObjLayer(SrcObj).WUDCDims );
end; // end_of procedure TN_UCObjLayer.CopyBaseFields

//************************************************ TN_UCObjLayer.MoveFields ***
// Move to self given TN_UCObjLayer object fields
// ( copy only pointers to array objects to self,
//   no additional memory for Array fields are allocated)
//
procedure TN_UCObjLayer.MoveFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution
  CopyScalarFields( SrcObj );

  Items    := TN_UCObjLayer(SrcObj).Items;
  BCodes   := TN_UCObjLayer(SrcObj).BCodes;
  WrkFlags := TN_UCObjLayer(SrcObj).WrkFlags;

  WCDimNames := TN_UCObjLayer(SrcObj).WCDimNames;
  WUDCDims   := TN_UCObjLayer(SrcObj).WUDCDims;
end; // end_of procedure TN_UCObjLayer.MoveFields

//********************************************** TN_UCObjLayer.SetEmptyFlag ***
// Set N_EmptyItemBit to given number of Items, begining from BegItemInd,
// NumItems = -1 means deleeting all Items from BegItemInd,
// all array lengths remains the same
//
procedure TN_UCObjLayer.SetEmptyFlag( BegItemInd: integer; NumItems: integer );
var
  i, LastItemInd: integer;
begin
  Assert( (BegItemInd >= 0) and (BegItemInd < WNumItems), 'Bad BegItemInd' );
  if NumItems < 0 then NumItems := WNumItems - BegItemInd;
  LastItemInd := BegItemInd + NumItems - 1;
  if LastItemInd >= WNumItems then LastItemInd := WNumItems-1;

  for i := BegItemInd to LastItemInd do // set N_EmptyItemBit
    Items[i].CFInd := Items[i].CFInd or N_EmptyItemBit;

end; // end_of procedure TN_UCObjLayer.SetEmptyFlag

//******************************************** TN_UCObjLayer.ClearEmptyFlag ***
// Clear N_EmptyItemBit from given number of Items, begining from BegItemInd,
// (restore hidden Items)
// NumItems = -1 means Clearing bit for all Items from BegItemInd
//
procedure TN_UCObjLayer.ClearEmptyFlag( BegItemInd: integer; NumItems: integer );
var
  i, LastItemInd: integer;
begin
  Assert( (BegItemInd >= 0) and (BegItemInd < WNumItems), 'Bad BegItemInd' );
  if NumItems < 0 then NumItems := WNumItems - BegItemInd;
  LastItemInd := BegItemInd + NumItems - 1;
  if LastItemInd >= WNumItems then LastItemInd := WNumItems-1;

  for i := BegItemInd to LastItemInd do // Clear N_EmptyItemBit
    Items[i].CFInd := Items[i].CFInd and (not N_EmptyItemBit);
end; // end_of procedure TN_UCObjLayer.ClearEmptyFlag

//*********************************************** TN_UCObjLayer.ItemIsEmpty ***
// Check if given Item is empty
//
function TN_UCObjLayer.ItemIsEmpty( AItemInd: integer ): boolean;
begin
  Assert( (AItemInd >= 0) and (AItemInd < WNumItems), 'Bad AItemInd' );

  Result := (Items[AItemInd].CFInd and N_EmptyItemBit) <> 0;
end; // end_of procedure TN_UCObjLayer.ItemIsEmpty

//********************************************** TN_UCObjLayer.GetItemInds  ***
// Get First Index and Number of Indexes ("Item Size") for given ItemInd Item,
// set AFirstInd, ANumInds = 0 for Empty Items
//
procedure TN_UCObjLayer.GetItemInds( ItemInd: integer;
                                          out AFirstInd, ANumInds: integer );
var
  TmpInd: integer;
begin
  Assert( (ItemInd >= 0) and (ItemInd < WNumItems), 'Bad ItemInd' );
  AFirstInd := 0; // not really needed
  ANumInds := 0;
  TmpInd := Items[ItemInd].CFInd;
  if (TmpInd and N_EmptyItemBit) <> 0 then Exit; // empty Item
  AFirstInd := TmpInd and N_CFIndMask;
  ANumInds  := (Items[ItemInd+1].CFInd and N_CFIndMask) - AFirstInd;
end; // end_of function TN_UCObjLayer.GetItemInds

//*********************************************** TN_UCObjLayer.CompactSelf ***
// Just set needed length for Items, BCodes and WrkFlags arrays,
// all other actions should be done in descendant's CompactSelf methods
//
procedure TN_UCObjLayer.CompactSelf();
begin
  SetLength( Items,    WNumItems+1 );
  SetLength( BCodes,   Items[WNumItems].CCInd );

  if Length(WrkFlags) > WNumItems then
    SetLength( WrkFlags, WNumItems );
end; // procedure TN_UCObjLayer.CompactSelf

//******************************************** TN_UCObjLayer.GetSizeInBytes ***
// Get Size in Bytes of Self fields,
// descendant fields size should be calculated and added to result in
// descendant's GetSizeInBytes methods
//
function TN_UCObjLayer.GetSizeInBytes(): integer;
var
  i: integer;
begin
  Result := InstanceSize + // real size of descendant object
            Length(Items)*Sizeof(Items[0]) +
            Length(WrkFlags)*Sizeof(WrkFlags[0]) +
            Length(BCodes) +
            Length(WUDCDims)*Sizeof(WUDCDims[0]) +
            Length(WItemsCSName) +
            5*8; // additional 8 bytes for each Array and String

  for i := 0 to High(WCDimNames) do
    Inc( Result, Length(WCDimNames[i]) + 8 );

end; // end_of function TN_UCObjLayer.GetSizeInBytes

//*********************************************** TN_UCObjLayer.GetSelfInfo ***
// Add Text Info strings about Self to given TStrings obj
// Mode - what Info is needed:
//
procedure TN_UCObjLayer.GetSelfInfo( SL: TStrings; Mode: integer );
var
  i, j, CDimInd, SelfCI, CurInd, NumItemCodes, NumDimCodes, Code, MaxDimInd: integer;
  DTStr, DimName: string;
  PCodes, DimPCodes: PInteger;
  MinMaxCodes: TN_IRArray;
begin
  DTStr := K_DateTimeToStr( Self.ObjDateTime );
  SelfCI := ClassFlags and $FF;
  SL.Add( '' );
  SL.Add( '***** CLayer type ' + N_ClassTagArray[SelfCI] + '(' +
                         ClassName + '), ' + N_TextCoordsType[WLCType] );
  SL.Add( '     ObjName: ' + ObjName );
  if ObjAliase <> '' then SL.Add( ' ObjAliase: ' + ObjAliase );
  if ObjInfo   <> '' then SL.Add( ' ObjInfo: ' + ObjInfo );
  if WComment  <> '' then SL.Add( ' Comment: ' + WComment );
  SL.Add( ' WItemsCSName: "' + WItemsCSName + '",  WFlags: ' + Format('%x', [WFlags]) );
  SL.Add( ' WAccuracy: ' + Format('%d,  ', [WAccuracy]) + 'WNumItems: ' + Format('%.0n', [1.0*WNumItems]));
  SL.Add( ' WIsSparse: ' + Format('%d,  ', [integer(WIsSparse)]) + 'Size(bytes): ' + Format('%.0n', [1.0*GetSizeInBytes()]));
  SL.Add( ' Created at: ' + DTStr );

  with WEnvRect do
    SL.Add( ' WEnvRect: ' + Format( '(%.3g, %.3g) (%.3g, %.3g) ',
                                      [Left, Top, Right, Bottom] ) );
  MaxDimInd := -1;

  SetLength( MinMaxCodes, 256 );  // initialize MinMaxCodes Array
  for i := 0 to 255 do
  with MinMaxCodes[i] do
  begin
    Left   := MaxInt;  // MinCode
    Top    := -MaxInt; // MaxCode
    Right  := MaxInt;  // MinNumCodes
    Bottom := -MaxInt; // MaxNumCodes
  end;

  for i := 0 to WNumItems-1 do // collect info about Codes for all Items
  begin
    GetItemAllCodes( i, PCodes, NumItemCodes );
    CurInd := 0;

    while True do // along all Dim Inds for i-th Item, collect info about them
    begin
      DimPCodes := PCodes;
      Inc( DimPCodes, CurInd );
      N_GetNextCObjCodes( PCodes, NumItemCodes, CurInd, CDimInd, NumDimCodes );

      //***** MinMaxCodes.Right (MinNumCodes) is not clculated fully accurate:
      //      if all Items has some codes then MinNumCodes can be > 0
      //      for some CDim even if there are Items with no codes in this CDim!

      if CDimInd = 256 then // no more Codes
      begin
        if CurInd = 0 then // Item with no codes
          for j := 0 to 255 do
            MinMaxCodes[j].Right := 0; // MinNumCodes

        Break;
      end; // if CDimInd = 256 then // no more Codes

      if MaxDimInd < CDimInd then MaxDimInd := CDimInd;

      for j := 0 to NumDimCodes-1 do // along codes for current CDimInd
      begin
        Code := DimPCodes^ and $FFFFFF;
        if Code < MinMaxCodes[CDimInd].Left then MinMaxCodes[CDimInd].Left := Code; // MinCode
        if Code > MinMaxCodes[CDimInd].Top  then MinMaxCodes[CDimInd].Top  := Code; // MaxCode
        Inc( DimPCodes );
      end; // for j := 0 to NumDimCodes-1 do // along codes for current CDimInd

      if NumDimCodes < MinMaxCodes[CDimInd].Right  then MinMaxCodes[CDimInd].Right  := NumDimCodes; // MinNumCodes
      if NumDimCodes > MinMaxCodes[CDimInd].Bottom then MinMaxCodes[CDimInd].Bottom := NumDimCodes; // MaxNumCodes

    end; // while True do // along all Dim Inds for i-th Item
  end; // for i := 0 to WNumItems-1 do // collect info about Codes for all Items

  if MaxDimInd >= 0 then
  begin
    SL.Add( '' );
    SL.Add( 'CDimInd  MinCode MaxCode   MinNumCodes MaxNumCodes  DimName' );

    for j := 0 to MaxDimInd do // show collected MinMax Codes
    with MinMaxCodes[j] do
    begin
      DimName := '""';
      if j <= High(WCDimNames) then
        DimName := WCDimNames[j];

      SL.Add( Format( '   %.2d     %.5d   %.5d        %.2d          %.2d       %s',
                           [j,      Left,  Top,       Right,      Bottom,  DimName] ));
    end; // for j := 0 to High(MinMaxCodes) do // show collected MinMax Codes

  end else // Length(MinMaxCodes) = 0
    SL.Add( 'No CObj Codes' );

  if WComment <> '' then
    SL.Add( 'Comment: ' + WComment );

  SL.Add( '' );
end; // procedure TN_UCObjLayer.GetSelfInfo

//********************************************** TN_UCObjLayer.CalcEnvRects ***
// Calc WEnvRect - Envelope Rect for all Items EnvRects
//
procedure TN_UCObjLayer.CalcEnvRects();
var
  i: integer;
begin
  WEnvRect.Left := N_NotAFloat;

  for i := 0 to WNumItems-1 do
  begin
    CalcItemEnvRect( i );
    N_FRectOR( WEnvRect, Items[i].EnvRect );
  end;

  if WEnvRect.Left = WEnvRect.Right then
    WEnvRect.Right := WEnvRect.Right + Abs(1.0e-4*WEnvRect.Right) + 1.0e-7;

  if WEnvRect.Top = WEnvRect.Bottom then
    WEnvRect.Bottom := WEnvRect.Bottom + Abs(1.0e-4*WEnvRect.Bottom) + 1.0e-7;
end; // end_of procedure TN_UCObjLayer.CalcEnvRects

//********************************************* TN_UCObjLayer.GetItemCenter ***
// Get Item's Center Point
// (temporary version - just return Item's EnvRect Center)
//
function TN_UCObjLayer.GetItemCenter( ItemInd: integer ): TDPoint;
begin
  with Items[ItemInd].EnvRect do
  begin
    Result.X := 0.5*( Left + Right );
    Result.Y := 0.5*( Top + Bottom );
  end;
end; // function TN_UCObjLayer.GetItemCenter

//********************************************* TN_UCObjLayer.ClearAllCodes ***
// Clear All Codes for All Items
//
procedure TN_UCObjLayer.ClearAllCodes();
var
  i: integer;
begin
  for i := 0 to WNumItems do
    Items[i].CCInd := 0;
end; // end_of procedure TN_UCObjLayer.ClearAllCodes

//************************************** TN_UCObjLayer.SetItemAllCodes(Bin) ***
// Set All Codes for given Item,
// APCodes points to ANumBytes of Codes in needed internal format
//
procedure TN_UCObjLayer.SetItemAllCodes( AItemInd: integer; APCodes: PInteger;
                                                            ANumInts: integer );
var
  i, CurCodesSize, Delta, AllCodesSize: integer;
begin
  if AItemInd < 0 then Exit; //

  AllCodesSize := Items[WNumItems].CCInd;
  CurCodesSize := Items[AItemInd+1].CCInd - Items[AItemInd].CCInd;

  N_ReplaceArrayElems( BCodes, Items[AItemInd].CCInd, CurCodesSize,
                               AllCodesSize, APCodes, ANumInts );

  Delta := ANumInts - CurCodesSize;

  if Delta <> 0 then // update Items[i].CCInd field
  begin
    for i := AItemInd+1 to WNumItems do
      Inc( Items[i].CCInd, Delta );
  end;

end; // end_of procedure TN_UCObjLayer.SetItemAllCodes(Bin)

//************************************* TN_UCObjLayer.SetItemAllCodes(CObj) ***
// Set All Codes for given Self Item,
// Get Source Codes from given ASrcCObj Item
//
procedure TN_UCObjLayer.SetItemAllCodes( ASelfItemInd: integer;
                                ASrcCObj: TN_UCObjLayer; ASrcItemInd: integer );
var
  NumInts: integer;
  PCodes: PInteger;
begin
  ASrcCObj.GetItemAllCodes( ASrcItemInd, PCodes, NumInts );
  SetItemAllCodes( ASelfItemInd, PCodes, NumInts );
end; // end_of procedure TN_UCObjLayer.SetItemAllCodes(CObj)

//************************************* TN_UCObjLayer.GetItemAllCodes(PInt) ***
// Get All Codes for given Item as Pointer to binary Codes
//
procedure TN_UCObjLayer.GetItemAllCodes( AItemInd: integer; out APCodes: PInteger;
                                                            out ANumInts: integer );
begin
  APCodes := nil;
  ANumInts := 0;
  if AItemInd < 0 then Exit; // some times, ItemInd = -1 means no Item

  if (Items[AItemInd].CFInd and N_EmptyItemBit) <> 0 then Exit; // empty Item

  ANumInts := Items[AItemInd+1].CCInd - Items[AItemInd].CCInd;
  if ANumInts > 0 then
    APCodes   := @BCodes[Items[AItemInd].CCInd];
end; // end_of procedure TN_UCObjLayer.GetItemAllCodes(PInt)

//*********************************** TN_UCObjLayer.GetItemAllCodes(IArray) ***
// Get All Codes for given Item in given Integer Array
//
procedure TN_UCObjLayer.GetItemAllCodes( AItemInd: integer; var AIArray: TN_IArray;
                                                            out ANumInts: integer );
var
  PCodes: PInteger;
begin
  GetItemAllCodes( AItemInd, PCodes, ANumInts );
  if ANumInts <= 0 then
  begin
    if Length(AIArray) = 0 then SetLength( AIArray, 1 ); // to enable using @AIArray[0]
    Exit;
  end;

  if Length(AIArray) < ANumInts then
    SetLength( AIArray, ANumInts );

  move( PCodes^, AIArray[0], ANumInts*Sizeof(Integer) );
end; // end_of procedure TN_UCObjLayer.GetItemAllCodes(IArray)

//************************************** TN_UCObjLayer.GetItemAllCodes(Str) ***
// Get All Codes for given Item as Result String
//
function TN_UCObjLayer.GetItemAllCodes( AItemInd: integer ): string;
var
  NumInts: integer;
  PCodes: PInteger;
begin
  GetItemAllCodes( AItemInd, PCodes, NumInts );
  Result := N_CObjCodesToString( PCodes, NumInts );
end; // end_of function TN_UCObjLayer.GetItemAllCodes(Str)

//******************************************* TN_UCObjLayer.AddXORItemCode ***
// Add (Amode=0) or XOR (Amode=1) All Codes for given Item and given
// Integers (given by Pointer to first Integer - APCodes)
// ANumCodes - Number of Code Ints pointed to by APCodes
//
procedure TN_UCObjLayer.AddXORItemCode( AItemInd: integer; APCodes: PInteger;
                                            ANumCodes: integer; AMode: integer );
var
  SelfNumInts: integer;
  WrkIArray: TN_IArray;
begin
  if AItemInd < 0 then Exit;

  GetItemAllCodes( AItemInd, WrkIArray, SelfNumInts );
  N_AddOrderedInts( WrkIArray, SelfNumInts, APCodes, ANumCodes, AMode );
  if SelfNumInts > 0 then
    SetItemAllCodes( AItemInd, @WrkIArray[0], SelfNumInts );
end; // end_of procedure TN_UCObjLayer.AddXORItemCode

//************************************************** TN_UCObjLayer.SetCCode ***
// Set One Old Item Code for given Item (temporary)
//
procedure TN_UCObjLayer.SetCCode( AItemInd, ACode: integer );
begin
  SetItemTwoCodes( AItemInd, 0, ACode, -1 );
end; // end_of procedure TN_UCObjLayer.SetCCode

//************************************************** TN_UCObjLayer.GetCCode ***
// Get One Old Item Code for given Item (temporary)
//
function TN_UCObjLayer.GetCCode( AItemInd: integer ): integer;
begin
  GetItemTwoCodes( AItemInd, 0, Result, N_i );
end; // end_of function TN_UCObjLayer.GetCCode

//****************************************** TN_UCObjLayer.GetItemFirstCode ***
// Get One (first) Code for given Item and for given Codes Dimension Index
// or -1 if absent
//
function TN_UCObjLayer.GetItemFirstCode( AItemInd, ACDimInd: integer ): integer;
var
  i, NumItemInts, CurCDimInd, CurCode: integer;
  PItemCodes: PInteger;
begin
  GetItemAllCodes( AItemInd, PItemCodes, NumItemInts );
  Result := -1;

  for i := 0 to NumItemInts-1 do // search for first code with given ACDimInd
  begin
    N_DecodeCObjCodeInt( PItemCodes^, CurCDimInd, CurCode );

    if CurCDimInd = ACdimInd then // needed ACDimInd found
    begin
      Result := CurCode;
      Exit;
    end;

    Inc( PItemCodes ); // to next code
  end; // for i := 0 to NumItemInts-1 do // search for first code with given ACDimInd

end; // end_of procedure TN_UCObjLayer.GetItemFirstCode

//******************************************* TN_UCObjLayer.SetItemTwoCodes ***
// Set Two Codes for given Item and for given Codes Dimension Index
// (clear all other Codes for given ACDimInd)
//
procedure TN_UCObjLayer.SetItemTwoCodes( AItemInd, ACDimInd, ACode1, ACode2: integer );
var
  CurInd, PrevInd, CurCDimInd: integer;
  NumItemInts, NumCurDimInts, NewNumDimInts: integer;
  NewCodes: Array [0..1] of integer;
  WrkIArray: TN_IArray;
  Label Fin;
begin
  NewNumDimInts := 0;

  if ACode1 > ACode2 then // swap ACode1 and ACode2
  begin
    N_i := ACode1;
    ACode1 := ACode2;
    ACode2 := N_i;
  end;

  if ACode1 <> -1 then
  begin
    NewCodes[0] := N_EncodeCObjCodeInt( ACDimInd, ACode1 );
    Inc( NewNumDimInts );
  end;

  if ACode2 <> -1 then
  begin
    NewCodes[NewNumDimInts] := N_EncodeCObjCodeInt( ACDimInd, ACode2 );
    Inc( NewNumDimInts );
  end;

  GetItemAllCodes( AItemInd, WrkIArray, NumItemInts );
  CurInd := 0;
  PrevInd := 0;

  if NumItemInts = 0 then // no codes for given ACDimInd
  begin
    NumCurDimInts := 0;
    SetItemAllCodes( AItemInd, @NewCodes[0], NewNumDimInts );
    Exit;
  end;

  while True do // along Codes Dimensions in given Item
  begin
    N_GetNextCObjCodes( @WrkIArray[0], NumItemInts, CurInd, CurCDimInd, NumCurDimInts );

    if CurCDimInd < ACDimInd then
    begin
      PrevInd := CurInd;
      Continue; // to next Dimension
    end;

    //*** Here: CurCDimInd >= ACDimInd

    if CurCDimInd = ACDimInd then // Codes for given ACDimInd exists
      goto Fin;

    //*** Here:  no Codes for given ACDimInd

    NumCurDimInts := 0;
    goto Fin;
  end; // while True do // along Codes Dimensions

  Assert( False, 'Error!' );

  Fin: //*** Replace existing Codes by NewCodes

  N_ReplaceArrayElems( WrkIArray, PrevInd, NumCurDimInts, NumItemInts,
                       @NewCodes[0], NewNumDimInts );

  SetItemAllCodes( AItemInd, @WrkIArray[0], NumItemInts+NewNumDimInts-NumCurDimInts );
end; // end_of procedure TN_UCObjLayer.SetItemTwoCodes

//******************************************* TN_UCObjLayer.GetItemTwoCodes ***
// Get Two Codes for given Item and for given Codes Dimension Index
//
procedure TN_UCObjLayer.GetItemTwoCodes( AItemInd, ACDimInd: integer;
                                                   out ACode1, ACode2: integer );
var
  CurInd, NumItemInts, CurCDimInd, NumDimCodes: integer;
  PItemCodes: PInteger;
begin
  GetItemAllCodes( AItemInd, PItemCodes, NumItemInts );
  CurInd := 0;
  ACode1 := -1;
  ACode2 := -1;

  while True do // along Codes Dimensions for given Item
  begin
    N_GetNextCObjCodes( PItemCodes, NumItemInts, CurInd, CurCDimInd, NumDimCodes );

    if CurCDimInd = ACDimInd then // Codes for given ACDimInd exists
    begin
      Inc( PItemCodes, CurInd-NumDimCodes );
      N_DecodeCObjCodeInt( PItemCodes^, CurCDimInd, ACode1 );

      if NumDimCodes > 1 then
      begin
        Inc( PItemCodes );
        N_DecodeCObjCodeInt( PItemCodes^, CurCDimInd, ACode2 );
      end;

      Exit;
    end; // if CurCDimInd = ACDimInd then // Codes for given ACDimInd exists

    if CurCDimInd > ACDimInd then // no Codes for given ACDimInd
      Exit;

  end; // while True do // along Codes Dimensions

end; // end_of procedure TN_UCObjLayer.GetItemTwoCodes

//***************************************** TN_UCObjLayer.SetItemThreeCodes ***
// Set Three Codes for given Item
//
procedure TN_UCObjLayer.SetItemThreeCodes( AItemInd, ACDim0Code1,
                                           ACDim1Code1, ACDim1ACode2: integer );
begin
  SetItemTwoCodes( AItemInd, 0, ACDim0Code1, -1 );
  SetItemTwoCodes( AItemInd, 1, ACDim1Code1, ACDim1ACode2 );
end; // end_of procedure TN_UCObjLayer.SetItemThreeCodes

//***************************************** TN_UCObjLayer.GetItemThreeCodes ***
// Get Three Codes for given Item
//
procedure TN_UCObjLayer.GetItemThreeCodes( AItemInd: integer; out ACDim0Code1,
                                             ACDim1Code1, ACDim1ACode2: integer );
begin
  GetItemTwoCodes( AItemInd, 0, ACDim0Code1, N_i );
  GetItemTwoCodes( AItemInd, 1, ACDim1Code1, ACDim1ACode2 );
end; // end_of procedure TN_UCObjLayer.GetItemThreeCodes

//*********************************************** TN_UCObjLayer.ItemHasCode ***
// Return True if Item Has given ACodeInt (Encodeded CDimInd and Code)
//
function TN_UCObjLayer.ItemHasCode( AItemInd, ACodeInt: integer ): boolean;
var
  NumItemInts: integer;
  PItemCodes: PInteger;
begin
  GetItemAllCodes( AItemInd, PItemCodes, NumItemInts );
  Result := False;
  if -1 <> N_SearchInteger( ACodeInt, PItemCodes, 0, NumItemInts-1 ) then
    Result := True;
end; // end_of procedure TN_UCObjLayer.ItemHasCode

//***************************************** TN_UCObjLayer.GetPtrToFirstCode ***
// Get Pointer To First IntCode (CDimInd+Code) for given Item and CDim
//
//     Parameters
// AItemInd  - given Item Index
// ACDimInd  - given CDim Index
// ANumRestCodes - number of Rest IntCodes in given Item (including Result^)
// Result    - Return pointer to First IntCode (CDimInd+Code) for given AItemInd and ACDimInd
//
function TN_UCObjLayer.GetPtrToFirstCode( AItemInd, ACDimInd: integer;
                                          out ANumRestCodes: integer ): PInteger;
var
  i, NumItemInts, WrkCDimInd, WrkCode: integer;
begin
  GetItemAllCodes( AItemInd, Result, NumItemInts );

  for i := 0 to NumItemInts-1 do // along all IntCodes in AItemInd
  begin
    N_DecodeCObjCodeInt( Result^, WrkCDimInd, WrkCode );

    if WrkCDimInd = ACDimInd then // needed IntCode found
    begin
      ANumRestCodes := NumItemInts - i;
      Exit;
    end else
      Inc( Result );
  end; // for i := 1 to NumItemInts do // along all IntCodes in AItemInd

  // No one Code with given ACDimInd

  ANumRestCodes := 0;
  Result := nil;
end; // end_of procedure TN_UCObjLayer.GetPtrToFirstCode

//**************************************** TN_UCObjLayer.GetCDimMinMaxCodes ***
// Get Min and Max Codes for all Items in given CDim
//
//     Parameters
// ACDimInd  - given CDim Index
// AMinCode  - calculated Minimal code (for all Items and given ACDimInd)
// AMaxCode  - calculated Maximal code (for all Items and given ACDimInd)
//
procedure TN_UCObjLayer.GetCDimMinMaxCodes( ACDimInd: integer; out AMinCode, AMaxCode: integer );
var
  i, WrkCDimInd, WrkCode: integer;
begin
  AMinCode := N_MaxInteger;
  AMaxCode := -1;

  for i := 0 to Items[WNumItems].CCInd-1 do // along all elems of BCodes Array
  begin
    N_DecodeCObjCodeInt( BCodes[i], WrkCDimInd, WrkCode );
    if WrkCDimInd <> ACDimInd then Continue; // not needed CDim

    if AMinCode > WrkCode then AMinCode := WrkCode;
    if AMaxCode < WrkCode then AMaxCode := WrkCode;
  end; // for i := 0 to Items[WNumItems].CCInd-1 do // along all elems of BCodes Array
end; // end_of procedure TN_UCObjLayer.GetCDimMinMaxCodes

//******************************************** TN_UCObjLayer.ItemsByCodesOp ***
// Peform given Operation on Self Items whose codes fulfill given condition
//
//     Parameters
// ADstCObj     - Destination CObj (for Copy and Move operations)
// AOpFlags     - Needed Operation
// ACondFlags   - Needed Condition
// AFlags       - condition flags, temporary not used
// ACDimInd     - given ASrcCObj CDim Index
// APSetOfCodes - given set of Codes
//
procedure TN_UCObjLayer.ItemsByCodesOp( ADstCObj: TN_UCObjLayer; AOpFlags: TN_ItemsCodesOpFlags;
                                        ACondFlags: TN_ItemsCodesCondFlags; ACDimInd: integer;
                                        APSetOfCodes: TN_PSetOfIntegers );
var
  SelfItemInd, DstItemInd, Code: integer;
  IsInside, CondTrue: boolean;
  UDPoints: TN_UDPoints;
  ULines: TN_ULines;
  OneDPoint: TDPoint;
  LItem: TN_ULinesItem;
begin
  LItem := nil;
  
  if Self is TN_UDPoints then
  begin
    UDPoints := TN_UDPoints(Self);
    if ADstCObj <> nil then
      Assert( ADstCObj is TN_UDPoints, 'ADstCObj is not Not TN_UDPoints' );
  end else
    UDPoints := nil;

  if Self is TN_ULines then
  begin
    ULines := TN_ULines(Self);
    LItem := TN_ULinesItem.Create( ADstCObj.WLCType );
    if ADstCObj <> nil then
      Assert( ADstCObj is TN_ULines, 'ADstCObj is not Not TN_ULines' );
  end else
    ULines := nil;

  for SelfItemInd := 0 to WNumItems-1 do // along all Self Items
  begin
    if ItemIsEmpty( SelfItemInd ) then Continue; // skip empty items

    Code := GetItemFirstCode( SelfItemInd, ACDimInd );
    IsInside := N_IntInSet( Code, APSetOfCodes );

    if IsInside then
      CondTrue := iccfIsInside in ACondFlags
    else
      CondTrue := iccfIsOutside in ACondFlags;

    if CondTrue then // Condition is True, Peform given Operation
    begin
      if (icofCopy in AOpFlags) or (icofMove in AOpFlags) then // Add Item to ADstCObj
      begin
        if UDPoints <> nil then // Self is TN_UDPoints
        begin
          OneDPoint := UDPoints.GetPointCoords( SelfItemInd, 0 ); // Only One Point Items are implemented
          TN_UDPoints(ADstCObj).AddOnePointItem( OneDPoint );
        end; // if UDPoints <> nil then // Self is TN_UDPoints

        if ULines <> nil then // Self is TN_ULines
        begin
          TN_ULines(ADstCObj).AddULItem( ULines, SelfItemInd, 0, -1, LItem );
        end; // if ULines <> nil then // Self is TN_ULines

        DstItemInd := ADstCObj.WNumItems - 1; // last added Item
        ADstCObj.SetItemAllCodes( DstItemInd, Self, SelfItemInd );
      end; // if (icofCopy in AOpFlags) or (icofMove in AOpFlags) then // Add Item to ADstCObj

      if (icofDelete in AOpFlags) or (icofMove in AOpFlags) then // Delete Item from Self
        SetEmptyFlag( SelfItemInd );

    end; // if CondTrue then // Condition is True, Peform given Operation

  end; // for SelfItemInd := 0 to WNumItems-1 do // along all Self Items

  if (icofDelete in AOpFlags) or (icofMove in AOpFlags) then // Compact Self
    CompactSelf();

  CalcEnvRects();
  ADstCObj.CalcEnvRects();

  if ULines <> nil then
    LItem.Free;
end; // end of procedure TN_UCObjLayer.ItemsByCodesOp


//*********************************************** TN_UCObjLayer.CopyContent ***
// Copy SrcObj Content to Self:
// Copy all fields except ObjName, ObjAliase and ObjInfo,
// can be used for all descendant objects, because descendant object CopyFields
// method will work
//
procedure TN_UCObjLayer.CopyContent( SrcObj: TN_UDBase );
var
  RunTimeContent: integer;
  AName, AAliase, Info: string;
begin
  AName   := ObjName;
  AAliase := ObjAliase;
  Info    := ObjInfo;
  RunTimeContent := WFlags and N_RunTimeContent;

  CopyFields( SrcObj );

  ObjName   := AName;
  ObjAliase := AAliase;
  ObjInfo   := Info;
  WFlags    := (WFlags and (not N_RunTimeContent)) or RunTimeContent;
end; // end_of procedure TN_UCObjLayer.CopyContent

//***************************************************** TN_UCObjLayer.GetCS ***
// return Self Items CS or nil if absent
//
function TN_UCObjLayer.GetCS( ACDimInd: integer = 0 ): TK_UDDCSpace;
begin
  Result := nil;
  if Self = nil then Exit;

  if WItemsCSName <> '' then // old, absolete, but still widely used field
    Result := TK_UDDCSpace(K_CurSpacesRoot.DirChildByObjName( WItemsCSName ))
//    Result := TK_UDDCSpace(N_GetUObj( K_CurSpacesRoot, WItemsCSName ))
  else // modern style, WCDimNames should be used instead of WItemsCSName
  begin
    if (ACDimInd >= 0) and (ACDimInd <= High(WCDimNames)) then
      Result := TK_UDDCSpace(K_CurSpacesRoot.DirChildByObjName( WCDimNames[ACDimInd] ))
//      Result := TK_UDDCSpace(N_GetUObj( K_CurSpacesRoot, WCDimNames[ACDimInd] ));
  end;
end; // function TN_UCObjLayer.GetCS

//************************************************** TN_UCObjLayer.GetCSInd ***
// return CS Ind for given ItemInd or -1 if absent:
// 1) Get needed CS Code (first code in given ACDimInd or use
//                        AItemInd as code if ACDimInd = -1)
// 2) Get and return CS Ind by this CS Code or -1 if not found
//
function TN_UCObjLayer.GetCSInd( AItemInd, ACDimInd: integer ): integer;
var
  i, NumCodesInCS, WCode: integer;
  SCode: string;
  CS: TK_UDDCSpace;
begin
  Result := -1;
  CS := GetCS();
  if CS = nil then Exit;

  if (0 <= ACDimInd) and (255 >= ACDimInd) then
    GetItemTwoCodes( AItemInd, ACDimInd, WCode, N_i )
  else
    WCode := AItemInd;

  SCode := IntToStr( WCode ); // conv WCode to string

  with TK_PDCSpace(CS.R.P)^ do
  begin
    NumCodesInCS := Codes.ALength;

    for i := 0 to NumCodesInCS-1 do
    begin
      if SCode = PString(Codes.P(i))^ then
      begin
        Result := i;
        Exit; // found
      end;
    end; // for i := 0 to NumCodesInCS-1 do

  end; // with TK_PDCSpace(ACS.R.P)^ do
end; // function TN_UCObjLayer.GetCSInd

//**************************************** TN_UCObjLayer.SetCodesByUDPoints ***
// Set Codes to Self Items by given AUDPoints
// (Assign to Self Item codes of all Points inside ItemEnvRect)
//
procedure TN_UCObjLayer.SetCodesByUDPoints( AUDPoints: TN_UCObjLayer );
var
  SelfItemInd, PointsItemInd, NumPointCodes, NumSelfParts, SelfPartInd: integer;
  FPInd, NumPointsInPart, PosCode: integer;
  PPointCodes: PInteger;
  CurDPointInsideItem: boolean;
  CurDPoint: TDPoint;
  UDPoints: TN_UDPoints;
  SelfAsULines: TN_ULines;
  SelfAsUContours: TN_UContours;
  PointPosType: TN_PointPosType;
begin
  if not (AUDPoints is TN_UDPoints) then Exit;

  UDPoints := TN_UDPoints(AUDPoints);
  ClearAllCodes();

  if Self is TN_ULines then SelfAsULines := TN_ULines(Self)
                       else SelfAsULines := nil;

  if Self is TN_UContours then SelfAsUContours := TN_UContours(Self)
                          else SelfAsUContours := nil;

  for SelfItemInd := 0 to Self.WNumItems-1 do
  begin
    for PointsItemInd := 0 to AUDPoints.WNumItems-1 do
    begin
      CurDPoint := UDPoints.GetPointCoords( PointsItemInd, 0 );
//      N_Dump1Str( N_DPointToStr( CurDPoint ) );
      CurDPointInsideItem := False;
      
      if SelfAsULines <> nil then
      begin
        NumSelfParts := SelfAsULines.GetNumParts( SelfItemInd );
        PosCode := 2; // as if outside

        for SelfPartInd := 0 to NumSelfParts-1 do
        begin
          SelfAsULines.GetPartInds( SelfItemInd, SelfPartInd, FPInd, NumPointsInPart );

          if WLCType = N_FloatCoords then
            PosCode := N_DPointInsideFRing( @SelfAsULines.LFCoords[FPInd], NumPointsInPart,
                                            Self.Items[SelfItemInd].EnvRect, CurDPoint )
          else
            PosCode := N_DPointInsideDRing( @SelfAsULines.LDCoords[FPInd], NumPointsInPart,
                                            Self.Items[SelfItemInd].EnvRect, CurDPoint );
          if PosCode <= 1 then // CurDPoint inside current Part
            Break;
        end; // for SelfPartInd := 0 to NumSelfParts-1 do

        CurDPointInsideItem := (PosCode <= 1);
      end; // if Self is TN_ULines then

      if SelfAsUContours <> nil then
      begin
        PointPosType := SelfAsUContours.DPointInsideItem( SelfItemInd, CurDPoint );
        CurDPointInsideItem := PointPosType <> pptOutside;
      end; // if SelfAsUContours <> nil then

      if CurDPointInsideItem then // add all PointsItemInd Item Codes to SelfItemInd Item
      begin
        UDPoints.GetItemAllCodes( PointsItemInd, PPointCodes, NumPointCodes );
        Self.AddXORItemCode( SelfItemInd, PPointCodes, NumPointCodes, 0 );
      end; // if CurDPointInsideItem then // add all PointsItemInd Item Codes to SelfItemInd Item

    end; // for PointsItemInd := 0 to AUDPoints.WNumItems-1 do

  end; // for SelfItemInd := 0 to WNumItems-1 do
end; // procedure TN_UCObjLayer.SetCodesByUDPoints


{
//******************************************** TN_UCObjLayer.GetCSS ***
// return Self CSS or nil if absent
//
function TN_UCObjLayer.GetCSS(): TK_UDDCSSpace;
begin
  Result := nil;
  if (WFlags and N_CSSBit) = 0 then Exit;

  Result := TK_UDDCSSpace(DirChild( N_CObjCSSChildInd ));
end; // function TN_UCObjLayer.GetCSS

//************************************** TN_UCObjLayer.SetCSS ***
// Set given ACSS to self
//
procedure TN_UCObjLayer.SetCSS( ACSS: TK_UDDCSSpace );
begin
  Assert( ACSS <> nil, 'CSS not given' );
  // previous CSS should be deleted!
  PutDirChildSafe( N_CObjCSSChildInd, ACSS ); // set new CSS
  WFlags := WFlags or N_CSSBit;
end; // end_of procedure TN_UCObjLayer.SetCSS

//************************************** TN_UCObjLayer.UpdateCSS ***
// Update Self CSS by CCodes as CS indexes
//
procedure TN_UCObjLayer.UpdateCSS();
var
  i: integer;
  CSS: TK_UDDCSSpace;
begin
  CSS := GetCSS();
  if CSS = nil then Exit; // nothig to update

  CSS.PDRA^.ASetLength( WNumItems );

  for i := 0 to WNumItems-1 do // set new CSS content
    PInteger(CSS.DP(i))^ := Items[i].CCode;
end; // end_of procedure TN_UCObjLayer.UpdateCSS

//************************************** TN_UCObjLayer.CreateCSS ***
// Create Self CSS in given CodesSpace ACS, if not already,
// and Update it (by CCodes as CS indexes)
// return updated CSS
//
function TN_UCObjLayer.CreateCSS( ACS: TK_UDDCSpace ): TK_UDDCSSpace;
var
  CurCS: TK_UDDCSpace;
begin
  Result := GetCSS();

  if Result <> nil then // check current CS
  begin
    CurCS := Result.GetDCSpace();
    if CurCS <> ACS then Result := nil;
  end;

  if Result = nil then // create CSS
  begin
    Result := ACS.CreateDCSSpace( ObjName + 'CSS' );
    SetCSS( Result );
  end;

  UpdateCSS(); // Update CSS by CCodes, used as CS indexes
end; // end_of function TN_UCObjLayer.CreateCSS

//************************************** TN_UCObjLayer.CCodesToCsInds ***
// Convert CCodes To Indexes by given ACS, Self CSS is not used
// (on input CCodes assumed to be integer codes, same as in given ACS)
//
procedure TN_UCObjLayer.CCodesToCsInds( ACS: TK_UDDCSpace );
var
  i: integer;
  ItemSCodes: TN_SArray;
  ItemInds: TN_IArray;
begin
  SetLength( ItemInds, WNumItems );
  SetLength( ItemSCodes, WNumItems );

  for i := 0 to WNumItems-1 do // Convert Item Codes to Array of strings
    ItemSCodes[i] := IntToStr( Items[i].CCode );

  with TK_PDCSpace(ACS.R.P)^ do // calculate indexes in ItemInds
    K_SCIndexFromSCodes( @ItemInds[0], @ItemSCodes[0], WNumItems,
                                        PString(Codes.P), Codes.ALength() );

  for i := 0 to WNumItems-1 do // Set CCodes to calculated indexes
    Items[i].CCode := ItemInds[i];
end; // end_of procedure TN_UCObjLayer.CCodesToCsInds

//************************************** TN_UCObjLayer.CsIndsToCCodes ***
// Convert Items[i].CCode fields as CS Indexes to CS Codes
// (CS Codes should be integer!)
//
procedure TN_UCObjLayer.CsIndsToCCodes();
var
  i, CSInd, CSCode: integer;
  CSS: TK_UDDCSSpace;
begin
  CSS := GetCSS();
  Assert( CSS <> nil, 'no CSS!' );

  with TK_PDCSpace(CSS.GetDCSpace().R.P)^ do
  for i := 0 to WNumItems-1 do // Convert CCode fields value
  begin
    CSInd := Items[i].CCode;
    N_s := PString(Codes.P(CSInd))^;
    CSCode := StrToInt( PString(Codes.P(CSInd))^ );
    Items[i].CCode := CSCode;
  end; // for i := 0 to WNumItems-1 do // Convert CCode fields value
end; // end_of procedure TN_UCObjLayer.CsIndsToCCodes

//********************************** TN_UCObjLayer.ReplaceCCodesByCSInds ***
// Replace CCodes To CS Indexes using given IntCodes integer TK_UDVector
// (replace existing CCode by index Ind, where IntCodes[Ind]=CCode)
// ( same as CCodesToCsInds, but given UDVector of integer is used instead
//   of CS Codes, that may be not integers. May be not really needed, because
//   CObjects should be used only with CS with true integer Codes. Using
//   special integer UDVector is nearly the same as using special Codes Space! )
//
procedure TN_UCObjLayer.ReplaceCCodesByCSInds( IntCodes: TK_UDVector );
var
  i, IntCodesLeng: integer;
  PIntCodes: PInteger;
begin
  IntCodesLeng := IntCodes.PDRA.ALength;
  PIntCodes := IntCodes.DP();

  for i := 0 to WNumItems-1 do // Replace Item Codes by calculated Indexes
    Items[i].CCode := K_SearchInIArray( PIntCodes, IntCodesLeng,
                                            SizeOf(integer), Items[i].CCode );
end; // end_of procedure TN_UCObjLayer.ReplaceCCodesByCSInds

//********************************** TN_UCObjLayer.ReplaceCCodesCS ***
// Replace CCodes CodeSpace by new given NewCS
// (on input CCodes are CS Indexes of current CS, on output - Indexes of NewCS)
//
function TN_UCObjLayer.ReplaceCCodesCS( NewCS: TK_UDDCSpace ): TK_UDDCSSpace;
var
  i: integer;
  CurCS: TK_UDDCSpace;
  DCProj : TK_UDVector;
begin
  CurCS := GetCSS.GetDCSpace();
  DCProj := K_DCSpaceProjectionGet( NewCS, CurCS );

  if DCProj = nil then
  begin
    N_WarnByMessage( 'Projection from ' + NewCS.ObjName + ' to ' +
                                          CurCS.ObjName + ' is absent!' );
    Result := nil;
    Exit;
  end;

  for i := 0 to WNumItems-1 do // Replace cur CS indexes by new calculated NewCS indexes
  begin
    Items[i].CCode := PInteger( DCProj.DP( Items[i].CCode ) )^;
  end;

  Result := CreateCSS( NewCS );
end; // end_of function TN_UCObjLayer.ReplaceCCodesCS
}


//********** TN_UCObjRefs class methods  **************

//********************************************** TN_UCObjRefs.Create ***
//
constructor TN_UCObjRefs.Create;
begin
  inherited Create;
  ClassFlags := N_UCObjRefsCI;
  ImgInd := 29;
end; // end_of constructor TN_UCObjRefs.Create

//********************************************* TN_UCObjRefs.Destroy ***
//
destructor TN_UCObjRefs.Destroy;
begin
  ChildInds := nil;
  CObjInds  := nil;
  inherited Destroy;
end; // end_of destructor TN_UCObjRefs.Destroy

//***************************************** TN_UCObjRefs.AddFieldsToSBuf ***
// save self to Serial Buf
//
procedure TN_UCObjRefs.AddFieldsToSBuf( SBuf: TN_SerialBuf );
begin
  CompactSelf();
  Inherited;
  SBuf.AddIntegerArray( CObjInds );
  SBuf.AddIntegerArray( ChildInds );
end; // end_of procedure TN_UCObjRefs.AddFieldsToSBuf

//**************************************** TN_UCObjRefs.GetFieldsFromSBuf ***
// load self from Serial Buf
//
procedure TN_UCObjRefs.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
begin
  Inherited;
  SBuf.GetIntegerArray( CObjInds );
  SBuf.GetIntegerArray( ChildInds );
end; // end_of procedure TN_UCObjRefs.GetFieldsFromSBuf

//***************************************** TN_UCObjRefs.AddFieldsToText ***
// save self to Serial Text Buf
//
function TN_UCObjRefs.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ): Boolean;
var
  i, FirstInd, NumInds, ChildInd: integer;
begin
  Assert( False, 'Not implemented!' ); //***************

  CompactSelf();
  inherited AddFieldsToText( SBuf, AShowFlags );

  if Length(Items) = 1 then // empty layer
  begin
    SBuf.AddToken( N_EndOfArray, K_ttString );
    SBuf.AddEOL();
  end else
  begin
    for i := 0 to WNumItems-1 do
    begin
      AddCItem( SBuf, i );
      GetItemInds( i, FirstInd, NumInds );

      if (WFlags and N_ChildIndsBit) <> 0 then
      begin
        ChildInd := ChildInds[i];
        SBuf.AddToken( Format( '%d', [ChildInd] ), K_ttString );
      end;

      SBuf.AddRowScalars( CObjInds[FirstInd], NumInds, Sizeof(integer), K_isInteger );
      SBuf.AddEOL();
    end; // for i := 0 to WNumItems-1 do
    SBuf.AddToken( N_EndOfArray, K_ttString );
  end;
  SBuf.AddEOL();

  Result := True;
end; // end_of procedure TN_UCObjRefs.AddFieldsToText

//**************************************** TN_UCObjRefs.GetFieldsFromText ***
// load self from Serial Text Buf
//
function TN_UCObjRefs.GetFieldsFromText( SBuf: TK_SerialTextBuf ): Integer;
begin
  Assert( False, 'Not implemented!' ); //***************
{
var
  LastItemInd, FreeInd, FreeRefInd, NumInds, FirstInd, ChildInd: integer;
begin
  Assert( False, 'Not implemented!' ); //***************
  inherited GetFieldsFromText(SBuf);

  while True do
  begin
    LastItemInd := GetCItem( SBuf, NumInds );
    if LastItemInd = -1 then Break; // end of items

    if (WFlags and N_ChildIndsBit) <> 0 then
    begin
      SBuf.GetScalar( ChildInd, K_isInteger );
      if Length(ChildInds) < Length(Items) then
        SetLength( ChildInds, Length(Items) );
      ChildInds[ItemInd] := ChildInd;
    end;

    Inc( FreeRefInd, NumInds );

    if Length(CObjInds) < FreeRefInd then
      Setlength( CObjInds, N_NewLength( FreeRefInd ) );

    SBuf.GetRowScalars( CObjInds[FirstInd], NumInds, Sizeof(integer), K_isInteger );
  end; // while True do

  SetSize( Items, WNumItems+1 ); // free previously allocated memory
  CompactSelf();
}
  Result := 0;
end; // end_of procedure TN_UCObjRefs.GetFieldsFromText

//************************************** TN_UCObjRefs.CopyFields ***
// copy to self given TN_UCObjRefs object
//
procedure TN_UCObjRefs.CopyFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution
  inherited;
  ChildInds := Copy( TN_UCObjRefs(SrcObj).ChildInds );
  CObjInds  := Copy( TN_UCObjRefs(SrcObj).CObjInds );
end; // end_of procedure TN_UCObjRefs.CopyFields

//************************************** TN_UCObjRefs.SameFields ***
// returns True if all self.fields are the same as given SrcObj.fields
// (SrcObj must be of the same class as self)
//
function TN_UCObjRefs.SameFields( SrcObj: TN_UDBase; AFlags: integer ): boolean;
  Label NotSame;
begin
  if not (SrcObj is TN_UCObjRefs) then goto NotSame;

  Result := Inherited SameFields( SrcObj, AFlags ); // prelimenary value
  if Result = False then Exit; // not same

  if (Length(ChildInds) <> Length(TN_UCObjRefs(SrcObj).ChildInds)) or
     (Length(CObjInds)  <> Length(TN_UCObjRefs(SrcObj).CObjInds)) then goto NotSame;

  if Length(ChildInds) > 0 then
    if not CompareMem( @ChildInds[0], @TN_UCObjRefs(SrcObj).ChildInds[0],
                    Length(ChildInds)*Sizeof(ChildInds[0]) ) then goto NotSame;

  if Length(CObjInds) > 0 then
    if not CompareMem( @CObjInds[0], @TN_UCObjRefs(SrcObj).CObjInds[0],
                    Length(CObjInds)*Sizeof(CObjInds[0]) ) then goto NotSame;
  Exit; // Self and Src obj have same fields values

  NotSame: // Self and Src obj do NOT have same fields values
  Result := False;
end; // end_of procedure TN_UCObjRefs.SameFields

//************************************** TN_UCObjRefs.CompactSelf ***
// Compact Self
//
procedure TN_UCObjRefs.CompactSelf();
var
  NumCObjInds: integer;
begin
  inherited;
  NumCObjInds := Items[WNumItems].CFInd;
  if Length(CObjInds) > NumCObjInds then
    SetLength( CObjInds, NumCObjInds );

  if ((WFlags and N_ChildIndsBit) <> 0 ) and
     (Length(ChildInds) > WNumItems)    then
    SetLength( ChildInds, WNumItems );

end; // procedure TN_UCObjRefs.CompactSelf

//******************************************* TN_UCObjRefs.UnSparseSelf ***
// Remove Empty Items and set needed length for all Self arrays
//
procedure TN_UCObjRefs.UnSparseSelf();
begin
  // temporary not implemented!
end; // procedure TN_UCObjRefs.UnSparseSelf

//************************************** TN_UCObjRefs.GetSizeInBytes ***
// Get Self Size in Bytes
//
function TN_UCObjRefs.GetSizeInBytes(): integer;
begin
  Result := inherited GetSizeInBytes() + Length(ChildInds)*Sizeof(ChildInds[0]) + 8;
end; // end_of function TN_UCObjRefs.GetSizeInBytes

//************************************** TN_UCObjRefs.GetSelfInfo ***
// create Text Info strings about self
// Mode - what Info is needed:
//
procedure TN_UCObjRefs.GetSelfInfo( SL: TStrings; Mode: integer );
var
  i, CFInd, NumElems, SumItems, SumNumElems, MaxNumElems, MinNumElems: integer;
  AvrNumElems: double;
begin
  inherited;
  SumItems := 0;
  SumNumElems := 0;
  if WNumItems = 0 then
    MinNumElems := 0
  else
    MinNumElems := N_MaxInteger;
  MaxNumElems := 0;
  AvrNumElems := 0;

  for i := 0 to WNumItems-1 do
  begin
    GetItemInds( i, CFInd, NumElems );
    if NumElems = 0 then Continue; // skip empty items
    Inc(SumItems);
    Inc(SumNumElems, NumElems );
    AvrNumElems := (AvrNumElems*(SumItems-1) + NumElems)/SumItems;
    if (MaxNumElems < NumElems) then MaxNumElems := NumElems;
    if (MinNumElems > NumElems) then MinNumElems := NumElems;

  end; // for i := 0 to WNumItems-1 do

  SL.Add( Format( '  Number of Non empty Items: %.0n', [1.0*SumItems] ));
  SL.Add( Format( '      Whole Number of Elems: %.0n', [1.0*SumNumElems] ));
  SL.Add( Format( '          Min Elems in Item: %.0n', [1.0*MinNumElems] ));
  SL.Add( Format( '          Max Elems in Item: %.0n', [1.0*MaxNumElems] ));
  SL.Add( Format( '          Avr.Elems in Item: %.1n', [AvrNumElems] ));
end; // procedure TN_UCObjRefs.GetSelfInfo

//************************************** TN_UCObjRefs.CalcItemEnvRect ***
// Calc EnvRect for given Item
//
procedure TN_UCObjRefs.CalcItemEnvRect( ItemInd: integer );
var
  i, FirstInd, NumInds, ChildInd: integer;
  UCObjLayer: TN_UCObjLayer;
begin
  Items[ItemInd].EnvRect.Left := N_NotAFloat;
  GetItemInds( ItemInd, FirstInd, NumInds );
  UCObjLayer := TN_UCObjLayer(DirChild( N_CObjRefsChildInd ));
  Assert( UCObjLayer <> nil, '1' );

  for i := FirstInd to FirstInd+NumInds-1 do
  with Items[ItemInd] do
  begin
    if (WFlags and N_ChildIndsBit) <> 0 then
    begin
      ChildInd := ChildInds[ItemInd];
      UCObjLayer := TN_UCObjLayer(DirChild( ChildInd ));
    end;
    N_FRectOR( EnvRect, UCObjLayer.Items[i].EnvRect );
  end;
end; // end_of procedure TN_UCObjRefs.CalcItemEnvRect

//********************************************** TN_UCObjRefs.InitItems ***
// set WNumItems = 0 and set initial array sizes by given values
//
// ANumItems - initial Items size
// ANumRefs  - initial ChildInds size (Number of references)
//
procedure TN_UCObjRefs.InitItems( ANumItems, ANumRefs: integer );
begin
  Inherited InitItems( ANumItems );

  ChildInds := nil;
  if (WFlags and N_ChildIndsBit) <> 0 then
    SetLength( ChildInds, ANumItems );

  if Length(CObjInds) < ANumRefs then
  begin
    CObjInds := nil;
    SetLength( CObjInds, ANumRefs );
  end;
end; // end_of procedure TN_UCObjRefs.InitItems

//************************************** TN_UCObjRefs.ConvSelfCoords ***
// Convert Self Coords using given AFunc with PParams
//
procedure TN_UCObjRefs.ConvSelfCoords( AFunc: TN_ConvDPFuncObj; APAuxPar: Pointer );
begin
  Assert( False, 'Cannot convert CObjRefs!' );
end; // end_of procedure TN_UCObjRefs.ConvSelfCoords

//************************************** TN_UCObjRefs.AffConvSelf(4) ***
// Affine Convert Self by given AffCoefs4 Coefs
//
procedure TN_UCObjRefs.AffConvSelf( AAffCoefs: TN_AffCoefs4 );
begin
  Assert( False, 'Cannot convert CObjRefs!' );
end; // end_of procedure TN_UCObjRefs.AffConvSelf(4)

//************************************** TN_UCObjRefs.AffConvSelf(6) ***
// Affine Convert Self by given AffCoefs6 Coefs
//
procedure TN_UCObjRefs.AffConvSelf( AAffCoefs: TN_AffCoefs6 );
begin
  Assert( False, 'Cannot convert CObjRefs!' );
end; // end_of procedure TN_UCObjRefs.AffConvSelf(6)

//************************************** TN_UCObjRefs.AffConvSelf(8) ***
// Affine Convert Self by given AffCoefs8 Coefs
//
procedure TN_UCObjRefs.AffConvSelf( AAffCoefs: TN_AffCoefs8 );
begin
  Assert( False, 'Cannot convert CObjRefs!' );
end; // end_of procedure TN_UCObjRefs.AffConvSelf(8)

//************************************** TN_UCObjRefs.GeoProjSelf ***
// Convert Self by given GeoProj Params
//
procedure TN_UCObjRefs.GeoProjSelf( var AGeoProjPar: TN_GeoProjPar; AConvMode: integer );
begin
  Assert( False, 'Cannot convert UContours!' );
end; // end_of procedure TN_UCObjRefs.GeoProjSelf

{
//************************************** TN_UCObjRefs.RoundSelf ***
// Round Self by given Coefs
//
procedure TN_UCObjRefs.RoundSelf( AAffCoefs: TN_AffCoefs4 );
begin
  Assert( False, 'Cannot convert CObjRefs!' );
end; // end_of procedure TN_UCObjRefs.RoundSelf
}

{
//************************************** TN_UCObjRefs.AffConv ***
// Affine Convert given SrcCObjLayer to self by given Coefs
//
procedure TN_UCObjRefs.AffConv( SrcCObjLayer: TN_UCObjLayer; AAffCoefs: TN_AffCoefs4 );
begin
  Assert( False, 'Cannot convert CObjRefs!' );
end; // end_of procedure TN_UCObjRefs.AffConv
}

//************************************** TN_UCObjRefs.AddLastEmptyItem ***
// Add Last Empty Item
//
procedure TN_UCObjRefs.AddLastEmptyItem();
var
  NeededLength: integer;
begin
  NeededLength := WNumItems + 2;
  if Length(Items) < NeededLength then
    SetLength( Items, N_NewLength( NeededLength ) );

  if (WFlags and N_ChildIndsBit) <> 0 then
    if Length(ChildInds) < NeededLength then
      SetLength( ChildInds, Length(Items) );

  Items[WNumItems+1] := Items[WNumItems];
  Items[WNumItems].EnvRect.Left := N_NotAFloat;
  Inc(WNumItems);
end; // end_of procedure TN_UCObjRefs.AddLastEmptyItem

//************************************** TN_UCObjRefs.AddRef ***
// Add new Reference as last element of last Item
//
// RefItemInd - Item Index in BaseCLayer
// BaseCLayer - Base CObjLayer (may be nil)
//
procedure TN_UCObjRefs.AddRef( RefItemInd: integer; BaseCLayer: TN_UCObjLayer );
var
  ItemInd, FirstInd, NumInds, ChildInd, NeededLength: integer;
begin
  ItemInd := WNumItems - 1;
  GetItemInds( ItemInd, FirstInd, NumInds );

  NeededLength := FirstInd + NumInds + 1;
  if Length(CObjInds) < NeededLength then
    SetLength( CObjInds, N_NewLength( NeededLength ) );

  CObjInds[FirstInd + NumInds] := RefItemInd;
  Inc( Items[ItemInd+1].CFInd );

  if (NumInds = 0) and ((WFlags and N_ChildIndsBit) <> 0) then // set ChildInd
  begin
    ChildInd := IndexOfDEField( BaseCLayer );
    Assert( ChildInd >= 0, N_SError );
    ChildInds[ItemInd] := ChildInd;
  end;
end; // end_of procedure TN_UCObjRefs.AddRef


//********** TN_UDPoints class methods  **************

//****************************************************** TN_UDPoints.Create ***
//
constructor TN_UDPoints.Create;
begin
  inherited Create;
  ClassFlags := N_UDPointsCI;
  WLCType := N_DoubleCoords;
  InitItems( 2, 2 );
  ImgInd := 1;
end; // end_of constructor TN_UDPoints.Create

//***************************************************** TN_UDPoints.Destroy ***
//
destructor TN_UDPoints.Destroy;
begin
  CCoords := nil;
  inherited Destroy;
end; // end_of destructor TN_UDPoints.Destroy

//********************************************* TN_UDPoints.AddFieldsToSBuf ***
// save self to Serial Buf
//
procedure TN_UDPoints.AddFieldsToSBuf( SBuf: TN_SerialBuf );
begin
  if (WFlags and N_RunTimeContent) <> 0 then // Clear Self Items
    InitItems( 0, 0 );

  CompactSelf();
  Inherited;
  SBuf.AddDPArray( CCoords, WAccuracy );
end; // end_of procedure TN_UDPoints.AddFieldsToSBuf

//******************************************* TN_UDPoints.GetFieldsFromSBuf ***
// load self from Serial Buf
//
procedure TN_UDPoints.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
begin
  Inherited;
  SBuf.GetDPArray( CCoords );
end; // end_of procedure TN_UDPoints.GetFieldsFromSBuf

//********************************************* TN_UDPoints.AddFieldsToText ***
// save self to Serial Text Buf
//
function TN_UDPoints.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ): Boolean;
var
  i, j, FirstInd, NumInds: integer;
  Str, Fmt: string;
begin
  N_s := ObjName; // debug
  if (WFlags and N_RunTimeContent) <> 0 then // Clear Self Items
    InitItems( 0, 0 );

  inherited AddFieldsToText( SBuf, AShowFlags );

  N_AddTagAttrDef( SBuf, 'WrkNumPoints', Items[WNumItems].CFInd, K_isInteger, 0 ); // mainly for speed
  SBuf.AddEOL( False );

  Fmt := N_DPointFmt( WEnvRect, WAccuracy );

  for i := 0 to WNumItems-1 do
  begin
    GetItemInds( i, FirstInd, NumInds );
    AddCItem( SBuf, i );

    for j := FirstInd to FirstInd+NumInds-1 do
    begin
      Str := Format( '   %.2d ', [j-FirstInd] );
      SBuf.AddToken( Str + N_PointToStr( CCoords[j], Fmt ), K_ttString );
      SBuf.AddEOL();
    end;

    if NumInds > 1 then
      SBuf.AddToken( N_EndOfArray, K_ttString );

    SBuf.AddEOL();

  end; // for i := 0 to WNumItems-1 do

  SBuf.AddToken( N_EndOfArray, K_ttString );
  SBuf.AddEOL();

  Result := True;
end; // end_of procedure TN_UDPoints.AddFieldsToText

//******************************************* TN_UDPoints.GetFieldsFromText ***
// load self from Serial Text Buf
//
function TN_UDPoints.GetFieldsFromText( SBuf: TK_SerialTextBuf ): Integer;
var
  ItemInd, NumInds, FreePInd, RetCode, WrkNumItems, WrkNumPoints: integer;
  Str: string;
begin
  inherited GetFieldsFromText( SBuf );
//  N_s := ObjName; // debug
//  N_AddStr( 1, 'Begin Loading: ' + ObjName ); // debug

  N_GetTagAttrDef( SBuf, 'WrkNumItems',  WrkNumItems,  K_isInteger, 0 );
  N_GetTagAttrDef( SBuf, 'WrkNumPoints', WrkNumPoints, K_isInteger, 0 );
  InitItems( WrkNumItems, WrkNumPoints );

  while True do // loop along Point Groups
  begin
    ItemInd := GetCItem( SBuf, NumInds );
    if ItemInd = -1 then Break; // end of items (Point Groups)

    FreePInd := Items[ItemInd].CFInd and N_CFIndMask; // Free Point Index

    if (Items[ItemInd].CFInd and N_EmptyItemBit) <> 0 then // Empty Item
      Continue; // all done for Empty Item

    while True do // loop along Points in Group
    begin
      SBuf.GetToken( Str ); // Point Index or End_Of_Array marker
//      N_AddStr( 1, ObjName + ' Ind=' + IntToStr(FreeInd) ); // debug

      if Str = N_EndOfArray then Break; // end of Points in Group

      if High(CCoords) < FreePInd then
        Setlength( CCoords, N_NewLength(FreePInd) );

      SBuf.GetToken( Str ); // X coord
      Val( Str, CCoords[FreePInd].X, RetCode );
      if RetCode <> 0 then
      with SBuf.St do
      begin
        N_i := 1;
        N_i2 := CPos;
        N_s := MidStr( Text, CPos-100, 200 );
      end;

      Assert( RetCode = 0, 'Bad Coord X' );

      SBuf.GetToken( Str ); // Y coord
      Val( Str, CCoords[FreePInd].Y, RetCode );
      Assert( RetCode = 0, 'Bad Coord Y' );
      Inc(FreePInd);

      if NumInds = 1 then Break; // one Point in Group
    end; // while True do // loop along Points in Group

    Items[ItemInd+1].CFInd := FreePInd; // Free Point Index in last (system) Item

  end; // while True do // loop along Point Groups

  CalcEnvRects();
//  WIsSparse := False; // debug
  CompactSelf();

  if (WFlags and N_IgnoreIndsBit) <> 0 then // Inds from SBuf were ignored, Self is not Sparse
  begin
    WIsSparse := False;
    WFlags := WFlags xor N_IgnoreIndsBit; // clear N_IgnoreIndsBit
  end;

  Result := 0;
end; // end_of procedure TN_UDPoints.GetFieldsFromText

//************************************************** TN_UDPoints.CopyFields ***
// copy to self given TN_UDPoints object
//
procedure TN_UDPoints.CopyFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution
  inherited;
  CCoords := Copy( TN_UDPoints(SrcObj).CCoords );
end; // end_of procedure TN_UDPoints.CopyFields

//************************************** TN_UDPoints.SameFields ***
// returns True if all self.fields are the same as given SrcObj.fields
// (SrcObj must be of the same class as self)
//
function TN_UDPoints.SameFields( SrcObj: TN_UDBase; AFlags: integer ): boolean;
var
  N1, N2: integer;
  Label NotSame;
begin
  if not (SrcObj is TN_UDPoints) then goto NotSame;

  Result := Inherited SameFields( SrcObj, AFlags ); // prelimenary value
  if Result = False then Exit; // not same

  N1 := Items[WNumItems].CFInd*SizeOf(CCoords[0]);

  with TN_UDPoints(SrcObj) do
    N2 := Items[WNumItems].CFInd*SizeOf(CCoords[0]);

  if not N_SameBytes( @CCoords[0], N1, @TN_UDPoints(SrcObj).CCoords[0], N2 ) then goto NotSame;

  Exit; // Self and Src obj have same fields values

  NotSame: // Self and Src obj do NOT have same fields values
  Result := False;
end; // end_of procedure TN_UDPoints.SameFields

//************************************************* TN_UDPoints.CompactSelf ***
// Just set needed length for all Self arrays, all Indexes remains the same
//
procedure TN_UDPoints.CompactSelf();
var
  NumPoints: integer;
begin
  inherited; // set needed Length to all Self Arrays except CCoords

  NumPoints := Items[WNumItems].CFInd;

  if Length(CCoords) > NumPoints then
    SetLength( CCoords, NumPoints );
end; // procedure TN_UDPoints.CompactSelf

//************************************************ TN_UDPoints.UnSparseSelf ***
// Remove Empty Items and set needed length for all Self arrays
//
procedure TN_UDPoints.UnSparseSelf();
var
  i, ItemInd, FPInd, NumPoints, NumCodesInts: integer;
  PCodes: PInteger;
  TmpCopy: TN_UDPoints;
begin
  if not WIsSparse then
  begin
    CompactSelf();
    Exit; // all done
  end; // if not WIsSparse then

  NumPoints := Items[WNumItems].CFInd;

  TmpCopy := TN_UDPoints.Create();
  TmpCopy.CopyFields( Self );
  TmpCopy.InitItems( WNumItems, NumPoints );

  for i := 0 to WNumItems-1 do
  begin
    GetItemInds( i, FPInd, NumPoints );
    if NumPoints = 0 then Continue; // skip empty items

    ItemInd := TmpCopy.ReplaceItem( @CCoords[FPInd], NumPoints );
    GetItemAllCodes ( i, PCodes, NumCodesInts );
    TmpCopy.SetItemAllCodes ( ItemInd, PCodes, NumCodesInts );
  end; // for i := 0 to WNumItems-1 do

  TmpCopy.WIsSparse := False;
  TmpCopy.CompactSelf(); // decrease array lengths if needed
  MoveFields( TmpCopy );

  TmpCopy.Free;
end; // procedure TN_UDPoints.UnSparseSelf

//********************************************** TN_UDPoints.GetSizeInBytes ***
// Get Self Size in Bytes
//
function TN_UDPoints.GetSizeInBytes(): integer;
begin
  Result := inherited GetSizeInBytes() +
                      Length(CCoords)*Sizeof(CCoords[0]) + 8;
end; // end_of function TN_UDPoints.GetSizeInBytes

//*************************************************** TN_ULines.GetSelfInfo ***
// create Text Info strings about self
// Mode - what Info is needed: (not used yet)
//
procedure TN_UDPoints.GetSelfInfo( SL: TStrings; Mode: integer );
var
  i, NumPoints, SumItems, SumNumPoints, MaxNumPoints, MinNumPoints: integer;
  FirstInd: integer;
  AvrNumPoints: double;
begin
  inherited;
  SumItems := 0;
  SumNumPoints := 0;

  if WNumItems = 0 then MinNumPoints := 0
                   else MinNumPoints := N_MaxInteger;

  MaxNumPoints := 0;
  AvrNumPoints := 0;

  for i := 0 to WNumItems-1 do
  begin
    GetItemInds( i, FirstInd, NumPoints );
    if NumPoints = 0 then Continue; // skip empty items
    Inc(SumItems);
    Inc(SumNumPoints, NumPoints );
    AvrNumPoints := (AvrNumPoints*(SumItems-1) + NumPoints)/SumItems;
    if (MaxNumPoints < NumPoints) then MaxNumPoints := NumPoints;
    if (MinNumPoints > NumPoints) then MinNumPoints := NumPoints;
  end; // for i := 0 to WNumItems-1 do

  SL.Add( Format( '   Number of Non empty Items: %.0n', [1.0*SumItems] ));
  SL.Add( Format( '      Whole Number of Points: %.0n', [1.0*SumNumPoints] ));
  SL.Add( Format( '          Min Points in Item: %.0n', [1.0*MinNumPoints] ));
  SL.Add( Format( '          Max Points in Item: %.0n', [1.0*MaxNumPoints] ));
  SL.Add( Format( '          Avr.Points in Item: %.1n', [AvrNumPoints] ));
end; // procedure TN_UDPoints.GetSelfInfo

//********************************************* TN_UDPoints.CalcItemEnvRect ***
// Calc EnvRect for given Item
//
procedure TN_UDPoints.CalcItemEnvRect( ItemInd: integer );
var
  FirstInd, NumInds: integer;
begin
  GetItemInds( ItemInd, FirstInd, NumInds );
  Items[ItemInd].EnvRect := N_CalcLineEnvRect( CCoords, FirstInd, NumInds );
end; // end_of procedure TN_UDPoints.CalcItemEnvRect

//*************************************************** TN_UDPoints.InitItems ***
// init Self and set given sizes to Items and CCoords arrays
//
procedure TN_UDPoints.InitItems( ANumItems, ANumPoints: integer );
begin
  if ANumItems < 2 then ANumItems := 2;

  Inherited InitItems( ANumItems );

  if Length(CCoords) < ANumPoints then
  begin
    CCoords := nil;
    SetLength( CCoords, ANumPoints );
  end;

end; // end_of procedure TN_UDPoints.InitItems

//********************************************** TN_UDPoints.ConvSelfCoords ***
// Convert Self Coords using given AFunc with PParams
//
procedure TN_UDPoints.ConvSelfCoords( AFunc: TN_ConvDPFuncObj; APAuxPar: Pointer );
var
  i, NumPoints: integer;
begin
  NumPoints := Items[WNumItems].CFInd;

  for i := 0 to NumPoints-1 do
    CCoords[i] := AFunc( CCoords[i], APAuxPar );

  CalcEnvRects();
end; // end_of procedure TN_UDPoints.ConvSelfCoords

//********************************************** TN_UDPoints.AffConvSelf(4) ***
// Affine Convert Self by given Coefs
//
procedure TN_UDPoints.AffConvSelf( AAffCoefs: TN_AffCoefs4 );
var
  NewDCoords: TN_DPArray;
begin
  N_AffConvCoords( AAffCoefs, CCoords, NewDCoords );
  move( NewDCoords[0], CCoords[0], Length(CCoords)*Sizeof(CCoords[0]) );
  CalcEnvRects();
end; // end_of procedure TN_UDPoints.AffConvSelf(4)

//********************************************** TN_UDPoints.AffConvSelf(6) ***
// Affine Convert Self by given Coefs
//
procedure TN_UDPoints.AffConvSelf( AAffCoefs: TN_AffCoefs6 );
var
  NewDCoords: TN_DPArray;
begin
  N_AffConvCoords( AAffCoefs, CCoords, NewDCoords );
  move( NewDCoords[0], CCoords[0], Length(CCoords)*Sizeof(CCoords[0]) );
  CalcEnvRects();
end; // end_of procedure TN_UDPoints.AffConvSelf(6)

//********************************************** TN_UDPoints.AffConvSelf(8) ***
// Affine Convert Self by given Coefs
//
procedure TN_UDPoints.AffConvSelf( AAffCoefs: TN_AffCoefs8 );
var
  NewDCoords: TN_DPArray;
begin
  N_AffConvCoords( AAffCoefs, CCoords, NewDCoords );
  move( NewDCoords[0], CCoords[0], Length(CCoords)*Sizeof(CCoords[0]) );
  CalcEnvRects();
end; // end_of procedure TN_UDPoints.AffConvSelf(8)

//************************************************* TN_UDPoints.GeoProjSelf ***
// Convert Self by given GeoProj Params
//
procedure TN_UDPoints.GeoProjSelf( var AGeoProjPar: TN_GeoProjPar; AConvMode: integer );
var
  NumPoints: integer;
begin
  NumPoints := Items[WNumItems].CFInd;

  if Length(CCoords) > NumPoints then // ConvertLine method uses Length(CCoords)
    SetLength( CCoords, NumPoints );

  AGeoProjPar.ConvertLine( CCoords, CCoords, AConvMode );
end; // end_of procedure TN_UDPoints.GeoProjSelf

//********************************************** TN_UDPoints.DeleteOnePoint ***
// Delete one Point from Group with given ItemInd, PartInd
//
procedure TN_UDPoints.DeleteOnePoint( ItemInd, PartInd: integer );
begin
  Assert( False, 'Not implemented!' );
end; // end_of procedure TN_UDPoints.DeleteOnePoint

//********************************************* TN_UDPoints.AddOnePointItem ***
// add new last Item with one given ADPoint with it's ACode
//
procedure TN_UDPoints.AddOnePointItem( ADPoint: TDPoint; ACode: integer );
var
  PInd: integer;
begin
  PInd := Items[WNumItems].CFInd; // first free place

  if High(CCoords) < PInd then
    SetLength( CCoords, N_NewLength( PInd ) );

  CCoords[PInd] := ADPoint;

  if Length(Items) < WNumItems+2 then
    SetLength( Items, N_NewLength( WNumItems+2 ) );

  with Items[WNumItems] do
  begin
    EnvRect.TopLeft := FPoint( ADPoint );
    EnvRect.BottomRight := FPoint( ADPoint );
  end;

  N_FRectOr( WEnvRect, ADPoint );

  Inc(WNumItems);
  Items[WNumItems].CFInd := PInd + 1;
  Items[WNumItems].CCInd := Items[WNumItems-1].CCInd; // as if no RegCodes

  SetCCode( WNumItems-1, ACode ); // WNumItems should be already OK
end; // end_of procedure TN_UDPoints.AddOnePointItem

//******************************************** TN_UDPoints.AddOnePointItems ***
// add new last one point Items with given coords and Codes
//
procedure TN_UDPoints.AddOnePointItems( ANumPoints: integer; APPoint: PDPoint; APCode: PInteger );
var
  i, CoordsInd: integer;
  WrkPPoint: PDPoint;
begin
  CoordsInd := Items[WNumItems].CFInd; // first free place in CCoords array

  if High(CCoords) < (CoordsInd+ANumPoints-1) then
    SetLength( CCoords, N_NewLength( CoordsInd+ANumPoints ) );

  WrkPPoint := APPoint;
  for i := CoordsInd to CoordsInd+ANumPoints-1 do
  begin
    CCoords[i] := WrkPPoint^;
    Inc(WrkPPoint);
  end;

  if Length(Items) < WNumItems+ANumPoints+1 then
    SetLength( Items, N_NewLength( WNumItems+ANumPoints+1 ) );

  WrkPPoint := APPoint;
  for i := WNumItems to WNumItems+ANumPoints-1 do
  with Items[i] do
  begin
    CFInd := CoordsInd + i - WNumItems;
    EnvRect.TopLeft := FPoint( WrkPPoint^ );
    EnvRect.BottomRight := FPoint( WrkPPoint^ );
    Inc(WrkPPoint);

    if APCode <> nil then
    begin
      SetCCode( i, APCode^ );
      Inc(APCode);
    end else
      SetCCode( i, -1 );
  end;

  WNumItems := WNumItems + ANumPoints;
  Items[WNumItems].CFInd := CoordsInd + ANumPoints;
end; // end_of procedure TN_UDPoints.AddOnePointItems

//********************************************** TN_UDPoints.GetPointCoords ***
// Return given Point coords and Point's index in CCords array in WrkFPInd
//
function TN_UDPoints.GetPointCoords( ItemInd, PartInd: integer ): TDPoint;
var
  FPInd, NumPoints: integer;
begin
  Assert( (ItemInd >= 0) and (ItemInd < WNumItems), 'Bad ItemInd!' );
  GetItemInds( ItemInd, FPInd, NumPoints );
  Assert( (PartInd >= 0) and (PartInd < NumPoints), 'Bad PartInd!' );

  WrkFPInd := FPInd + PartInd; // can be used in caller procedure
  Result := CCoords[WrkFPInd];
end; // function TN_UDPoints.GetPointCoords

//************************************************* TN_UDPoints.ReplaceItem ***
// Empty given Item and add new one with given Coords and same CObj Codes
// ItemInd = -1 means adding new Item with no Codes
//
// Return index of new Item
//
function TN_UDPoints.ReplaceItem( PFirstPoint: PDPoint; NumPoints: integer;
                                                   ItemInd: integer ): integer;
var
  DstBegInd, NewItemInd: integer;
begin
  if NumPoints <= 0 then // just Empty given Item
  begin
    SetEmptyFlag( ItemInd );
    Result := -1;
    Exit;
  end; // if NumPoints <= 0 then // just Empty given Item

  NewItemInd := AddItemsSys();

  DstBegInd := Items[NewItemInd].CFInd and N_CFIndMask;

  if High(CCoords) < DstBegInd+NumPoints then // increase in advance
    SetLength( CCoords, N_NewLength(DstBegInd+NumPoints) );

  move( PFirstPoint^, CCoords[DstBegInd], NumPoints*Sizeof(CCoords[0]) );

  with Items[NewItemInd] do // set New Item attributes
  begin
    CFInd := DstBegInd;
    EnvRect := N_CalcDLineEnvRect( PFirstPoint, NumPoints );
    N_FRectOr( WEnvRect, EnvRect );
  end;

  if ItemInd > 0 then // Copy CObj Codes and Empty ItemInd
  begin
    SetItemAllCodes( NewItemInd, Self, ItemInd );
    SetEmptyFlag( ItemInd );
  end; // if ItemInd > 0 then // Copy CObj Codes and Empty ItemInd

  Items[NewItemInd+1].CFInd := DstBegInd + NumPoints;
  Result := NewItemInd;
end; // function TN_UDPoints.ReplaceItem

//************************************************** TN_UDPoints.SnapToGrid ***
// Snap all Coords to given Grid without deleting same points
//
procedure TN_UDPoints.SnapToGrid( const Origin, Step: TDPoint );
var
  i, NSteps: integer;
begin
  for i := 0 to High(CCoords) do
  begin
    if Step.X <> 0.0 then
    begin
      NSteps := Round( ( CCoords[i].X - Origin.X ) / Step.X );
      CCoords[i].X := Origin.X + NSteps*Step.X;
    end;

    if Step.Y <> 0.0 then
    begin
      NSteps := Round( ( CCoords[i].Y - Origin.Y ) / Step.Y );
      CCoords[i].Y := Origin.Y + NSteps*Step.Y;
    end;
  end; // for i := 0 to High(CCoords) do

  CalcEnvRects();
end; // end_of procedure TN_UDPoints.SnapToGrid

//************************************************ TN_UDPoints.AddGridNodes ***
// Add To Self Nodes of given Grid (by Rows!) that are inside given ARect
// If APNXNY is given (<> nil) return number created points along X and Y
//
procedure TN_UDPoints.AddGridNodes( const ARect: TFRect; const AOrigin, AStep: TDPoint;
                                                         const APNXNY: PPoint );
var
  DCInd, NY: integer;
  UL, P: TDPoint;
  DC: TN_DPArray;
begin
  //***** create Nodes coords in DC array

  UL := N_SnapPointToGrid( AOrigin, AStep, DPoint(ARect.TopLeft) );
  SetLength( DC, 100 ); // initial value

  if UL.X < ARect.Left then UL.X := UL.X + AStep.X;
  if UL.Y < ARect.Top  then UL.Y := UL.Y + AStep.Y;

  P.Y := UL.Y; // initial Row Y Coords
  DCInd := 0;
  NY := 0;

  while True do // loop along Y-axis (along Point Rows)
  begin
    P.X := UL.X; // initial Point in Row X Coord
    Inc( NY );

    while True do // loop along X-axis (along Points in current Row)
    begin
      if High(DC) < DCInd then
        SetLength( DC, N_NewLength( DCInd+1) );

      DC[DCInd] := P;
      Inc(DCInd);

      P.X := P.X + AStep.X; // to next Point in Row
      if P.X > ARect.Right then Break;
    end; // while True do // loop along X-axis (along Points in current Row)

    P.Y := P.Y + AStep.Y; // to next Row
    if P.Y > ARect.Bottom then Break;
  end; // while True do // loop along X-axis, add array of vertical points

  AddOnePointItems( DCInd, @DC[0] ); // add created coords to Self

  if APNXNY <> nil then // return NX, NY
    APNXNY^ := Point( DCInd div NY, NY );
end; // end_of procedure TN_UDPoints.AddGridNodes


//********** TN_ULinesItem class methods  **************

//********************************************** TN_ULinesItem.Create ***
//
constructor TN_ULinesItem.Create( CoordsType: integer );
begin
  inherited Create();
  ICType := CoordsType;
  Init();
end; // end_of constructor TN_ULinesItem.Create

//********************************************* TN_ULinesItem.Destroy ***
//
destructor TN_ULinesItem.Destroy;
begin
  IPartFCoords := nil;
  IPartDCoords := nil;
  IPartRInds   := nil;
  inherited Destroy;
end; // end_of destructor TN_ULinesItem.Destroy

//***************************************** TN_ULinesItem.Init ***
// Init Self (prepare for adding first Part)
//
procedure TN_ULinesItem.Init();
begin
  INumParts := 0;
  INumPoints := 0;
  if Length(IPartRInds) = 0 then SetLength( IPartRInds, 4 );
  IPartRInds[0] := 0;
end; // procedure TN_ULinesItem.Init

//******************************** TN_ULinesItem.AddPartCoords(float) ***
// Add to Self given Coords as new Last Part
//
procedure TN_ULinesItem.AddPartCoords( const SrcCoords: TN_FPArray;
                                                    SrcInd, NumInds: integer );
var
  RDstInd: integer;
begin
  if High(IPartRInds) <= INumParts then
    SetLength( IPartRInds, N_NewLength(INumParts) );

  RDstInd := INumPoints;
  Inc( INumPoints, NumInds );
  Inc(INumParts);
  IPartRInds[INumParts] := INumPoints;

  if ICType = N_FloatCoords then // float Self Coords
  begin
    if Length(IPartFCoords) < INumPoints then
      SetLength( IPartFCoords, N_NewLength(INumPoints) );

    move( SrcCoords[SrcInd], IPartFCoords[RDstInd], NumInds*Sizeof(IPartFCoords[0]));
  end else //********************** double Self coords
  begin
    if Length(IPartDCoords) < INumPoints then
      SetLength( IPartDCoords, N_NewLength(INumPoints) );

    N_FCoordsToDCoords( SrcCoords, SrcInd,
                         IPartDCoords, RDstInd, NumInds );
  end;
end; // end_of procedure TN_ULinesItem.AddPartCoords(float)

//******************************** TN_ULinesItem.AddPartCoords(double) ***
// Add to Self given Coords as new Last Part
//
procedure TN_ULinesItem.AddPartCoords( const SrcCoords: TN_DPArray;
                                                    SrcInd, NumInds: integer );
var
  RDstInd: integer;
begin
  if High(IPartRInds) <= INumParts then
    SetLength( IPartRInds, N_NewLength(INumParts) );

  RDstInd := INumPoints;
  Inc( INumPoints, NumInds );
  Inc(INumParts);
  IPartRInds[INumParts] := INumPoints;

  if ICType = N_FloatCoords then // float Self Coords
  begin
    if Length(IPartFCoords) < INumPoints then
      SetLength( IPartFCoords, N_NewLength(INumPoints) );

    N_DCoordsToFCoords( SrcCoords, SrcInd,
                         IPartFCoords, RDstInd, NumInds );
  end else //********************** double Self coords
  begin
    if Length(IPartDCoords) < INumPoints then
      SetLength( IPartDCoords, N_NewLength(INumPoints) );

    move( SrcCoords[SrcInd], IPartDCoords[RDstInd], NumInds*Sizeof(IPartDCoords[0]));
  end;
end; // end_of procedure TN_ULinesItem.AddPartCoords(double)

//***************************************** TN_ULinesItem.AddParts ***
// Add to Self some Parts of given Item of ULines with float or double coords,
// set ICode, IRegCodes by Item's values
//
procedure TN_ULinesItem.AddParts( ULines: TN_ULines; ItemInd: integer;
                                             ABegPartInd, ANumParts: integer );
var
  i, WNumParts, FPInd, NumPoints: integer;
  MemPtr: TN_BytesPtr;
begin
  if ANumParts <= 0 then Exit; // (there are needed calls with ANumParts = 0)

  with ULines do
    begin
    GetNumParts( ItemInd, MemPtr, WNumParts );
    if WNumParts = 0 then Exit; // empty item

    for i := ABegPartInd to ABegPartInd+ANumParts-1 do
    begin
      GetPartInds( MemPtr, i, FPInd, NumPoints );
      if WLCType = N_FloatCoords then
        AddPartCoords( LFCoords, FPInd, NumPoints )
      else
        AddPartCoords( LDCoords, FPInd, NumPoints );
    end;
  end; // with UFLines do
end; // end_of procedure TN_ULinesItem.AddParts

//*********************************** TN_ULinesItem.CreateSegmItem(float) ***
// Creat Item with one Part, based on given segment (given two points):
// Mode = 0 - Part consists of two points segment
//      = 1 - Part consists of five points envelope rect
//
procedure TN_ULinesItem.CreateSegmItem( const P1, P2: TFPoint; Mode: integer );
var
  Coords: TN_FPArray;
begin
  Init();

  case Mode of
  0: begin // two points segment
       SetLength( Coords, 2 );
       Coords[0] := P1;
       Coords[1] := P2;
     end;

  1: begin // envelope rect
       SetLength( Coords, 5 );
       Coords[0]   := P1;
       Coords[1].X := P2.X;
       Coords[1].Y := P1.Y;
       Coords[2]   := P2;
       Coords[3].X := P1.X;
       Coords[3].Y := P2.Y;
       Coords[4]   := P1;
     end;
  end; // case Mode of

  AddPartCoords( Coords, 0, Length(Coords) );
end; // end_of procedure TN_ULinesItem.CreateSegmItem(float)

//********************************** TN_ULinesItem.CreateSegmItem(double) ***
// Creat Item with one Part, based on given segment (given two points):
// Mode = 0 - Part consists of two points segment
//      = 1 - Part consists of five points envelope rect
//
procedure TN_ULinesItem.CreateSegmItem( const P1, P2: TDPoint; Mode: integer );
var
  Coords: TN_DPArray;
begin
  Init();

  case Mode of
  0: begin // two points segment
       SetLength( Coords, 2 );
       Coords[0] := P1;
       Coords[1] := P2;
     end;

  1: begin // envelope rect
       SetLength( Coords, 5 );
       Coords[0]   := P1;
       Coords[1].X := P2.X;
       Coords[1].Y := P1.Y;
       Coords[2]   := P2;
       Coords[3].X := P1.X;
       Coords[3].Y := P2.Y;
       Coords[4]   := P1;
     end;
  end; // case Mode of

  AddPartCoords( Coords, 0, Length(Coords) );
end; // end_of procedure TN_ULinesItem.CreateSegmItem(double)


//********** TN_ULines class methods  **************

//******************************************************** TN_ULines.Create ***
//
constructor TN_ULines.Create();
begin
  inherited Create();
  ClassFlags := N_ULinesCI;
//  ImgInd is defined in GetImgInd function
end; // end_of constructor TN_ULines.Create

//******************************************************* TN_ULines.Create1 ***
// Create ULines with given CoordsType
//
constructor TN_ULines.Create1( CoordsType: integer; AObjName: string = 'New'; AAccuracy: integer = 4; ACSName: string = '' );
begin
  Create();
  WLCType   := CoordsType;
  ObjName   := AObjName;
  WAccuracy := AAccuracy;
  WItemsCSName := ACSName;
//  ImgInd is defined in GetImgInd function
end; // end_of constructor TN_ULines.Create1

//******************************************************* TN_ULines.Create2 ***
// Create ULines with given CoordsType and initialize arrays
// getting number of objects from SrcULines
//
constructor TN_ULines.Create2( SrcULines: TN_ULines );
begin
  Create();
  ObjName   := SrcULines.ObjName;
  ObjAliase := SrcULines.ObjAliase;
  WLCType   := SrcULines.WLCType;

  InitItems( SrcULines.WNumItems+10,
             Max( Length(SrcULines.LFCoords), Length(SrcULines.LDCoords) ) );
end; // end_of constructor TN_ULines.Create2

//******************************************************* TN_ULines.Destroy ***
//
destructor TN_ULines.Destroy;
begin
  LFCoords := nil;
  LDCoords := nil;
  BCodes   := nil;
  inherited Destroy;
end; // end_of destructor TN_ULines.Destroy

//*********************************************** TN_ULines.AddFieldsToSBuf ***
// save self to Serial Buf
//
procedure TN_ULines.AddFieldsToSBuf( SBuf: TN_SerialBuf );
begin
  if (WFlags and N_RunTimeContent) <> 0 then // Clear Self Items
    InitItems( 0, 0 );

  CompactSelf();

  Inherited;

  SBuf.AddFPArray( LFCoords, WAccuracy );
  SBuf.AddDPArray( LDCoords, WAccuracy );
end; // end_of procedure TN_ULines.AddFieldsToSBuf

//********************************************* TN_ULines.GetFieldsFromSBuf ***
// load self from Serial Buf
//
procedure TN_ULines.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
begin
  Inherited;

  SBuf.GetFPArray( LFCoords );
  SBuf.GetDPArray( LDCoords );
end; // end_of procedure TN_ULines.GetFieldsFromSBuf

//*********************************************** TN_ULines.AddFieldsToText ***
// save self to Serial Text Buf
//
function TN_ULines.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ): Boolean;
var
  i, j, FirstInd, NumParts, NumInds, CoordsFmtMode, ItemCFmtMode, MaxChars: integer;
  MemPtr: TN_BytesPtr;
begin
//  N_s := ObjName; // debug
  if (WFlags and N_RunTimeContent) <> 0 then // Clear Self Items
    InitItems( 0, 0 );

  inherited AddFieldsToText( SBuf, AShowFlags );

  N_AddTagAttrDef( SBuf, 'WrkNumPoints', Items[WNumItems].CFInd, K_isInteger, 0 ); // mainly for speed

  CoordsFmtMode := 0;
//  if K_txtCompDblCoords in K_TextModeFlags then CoordsFmtMode := 1; // CoordsFmtMode = 1 has error for mulipart Items
  if K_txtCompIntCoords in K_TextModeFlags then CoordsFmtMode := 2;
  N_AddTagAttrDef( SBuf, 'WrkCoordsFmt', CoordsFmtMode, K_isInteger, 0 );
  SBuf.AddEOL( False );

  MaxChars := N_MaxCoordsChars( WEnvRect, WAccuracy );

  if WNumItems = 0 then
  begin
    SBuf.AddToken( N_EndOfArray, K_ttString );
    SBuf.AddEOL();
  end else // WNumItems > 0
  begin
    for i := 0 to WNumItems-1 do
    begin
      GetNumParts( i, MemPtr, NumParts );
      if NumParts = 0 then Continue;

      AddCItem( SBuf, i, IntToStr( NumParts )  );
      ItemCFmtMode := CoordsFmtMode;
      if NumParts > 1 then ItemCFmtMode := 0;

      for j := 0 to NumParts-1 do
      begin
        GetPartInds( MemPtr, j, FirstInd, NumInds );
        if WLCType = N_FloatCoords then
          SBuf.AddFPoints( LFCoords, FirstInd, NumInds, ItemCFmtMode, MaxChars, WAccuracy )
        else
          SBuf.AddDPoints( LDCoords, FirstInd, NumInds, ItemCFmtMode, MaxChars, WAccuracy );
        SBuf.AddEOL( False );
      end; // for j := 0 to NumParts-1 do

//      if (ItemCFmtMode = 0) or (WLCType = N_FloatCoords) then
      if ItemCFmtMode = 0 then
      begin
        SBuf.AddToken( N_EndOfArray, K_ttString );
        SBuf.AddEOL( False );
      end;

    end; // for i := 0 to WNumItems-1 do
    SBuf.AddToken( N_EndOfArray, K_ttString );
  end;
  SBuf.AddEOL();

  Result := True;
end; // end_of procedure TN_ULines.AddFieldsToText

//********************************************* TN_ULines.GetFieldsFromText ***
// load self from Serial Text Buf
//
function TN_ULines.GetFieldsFromText( SBuf: TK_SerialTextBuf ): Integer;
var
  NumPointsInPart, ItemInd, NumInds, NumCodes, WCode1, WCode2: integer;
  WrkNumItems, WrkNumPoints, CoordsFmtMode: integer;
  NumPartsStr: string;
  TmpFCoords: TN_FPArray;
  TmpDCoords: TN_DPArray;
  LItem: TN_ULinesItem;
begin
  N_s := ObjName; // debug
  N_T2b.Start( 0 );
  N_T2b.Start( 2 );
  inherited GetFieldsFromText( SBuf );
//  N_AddStr( 1, 'Begin Loading: ' + ObjName ); // debug

  N_GetTagAttrDef( SBuf, 'WrkNumItems',  WrkNumItems,   K_isInteger, 0 );
  N_GetTagAttrDef( SBuf, 'WrkNumPoints', WrkNumPoints,  K_isInteger, 0 );
  N_GetTagAttrDef( SBuf, 'WrkCoordsFmt', CoordsFmtMode, K_isInteger, 0 );

  InitItems( WrkNumItems, WrkNumPoints );

  LItem := TN_ULinesItem.Create( WLCType );
  N_T2b.Stop( 2 );

  while True do // loop along Items (Lines)
  begin
  N_T2b.Start( 3 );
    ItemInd := GetCItem( SBuf, NumInds, @NumPartsStr );
  N_T2b.Stop( 3 );
    if ItemInd = -1 then Break; // end of items

    N_Dump1Str( Format( 'AAA ItemInd=%d', [ItemInd] ) );

    if (WFlags and N_RCXYBit) <> 0 then // ULines with old RegCodes
    begin
      WCode1 := -1;
      WCode2 := -1;
      SBuf.GetScalar( NumCodes, K_isInteger );
      Assert( NumCodes <= 2, 'Temporary!' );

      if NumCodes >= 1 then
        SBuf.GetScalar( WCode1, K_isInteger );

      if NumCodes = 2 then
        SBuf.GetScalar( WCode2, K_isInteger );

      if NumCodes >= 1 then
        SetItemTwoCodes( ItemInd, 1, WCode1, WCode2 );
    end; // if (WFlags and N_RCXYBit) <> 0 then // ULines with RegCodes

  N_T2b.Start( 5 );
    while True do // Get Item's Parts (one or many)
    begin
      NumPointsInPart := 0;
      if WLCType = N_FloatCoords then
      begin
        if -1 = SBuf.GetFPoints( TmpFCoords, NumPointsInPart,
                           NumInds, CoordsFmtMode, WAccuracy ) then Break; // end of Parts
        LItem.AddPartCoords( TmpFCoords, 0, NumPointsInPart );
      end else
      begin
        if -1 = SBuf.GetDPoints( TmpDCoords, NumPointsInPart,
                           NumInds, CoordsFmtMode, WAccuracy ) then Break; // end of Parts
  N_T2b.Start( 7 );
        LItem.AddPartCoords( TmpDCoords, 0, NumPointsInPart );
  N_T2b.Stop( 7 );
      end;
      if CoordsFmtMode >= 1 then Break; // now only one part is allowed for CoordsFmtMode >= 1
    end; // while True do // Get Item's Parts (one or many)
  N_T2b.Stop( 5 );

  N_T2b.Start( 6 );
    ReplaceItemCoords( LItem, ItemInd );
    LItem.Init();
  N_T2b.Stop( 6 );

  end; // while True do // loop along Items (Lines)

  N_T2b.Start( 7 );
  CalcEnvRects();
  CompactSelf();

  if (WFlags and N_IgnoreIndsBit) <> 0 then // Inds from SBuf were ignored, Self is not Sparse
  begin
    WIsSparse := False;
    WFlags := WFlags xor N_IgnoreIndsBit; // clear N_IgnoreIndsBit
  end;

  LItem.Free;
  TmpFCoords := nil;
  TmpDCoords := nil;

  Result := 0;

  if (WFlags and N_RCXYBit) <> 0 then // ULines with old RegCodes
    WFlags := WFlags xor N_RCXYBit; // N_RCXYBit flag is no more needed, Temporary

  N_T2b.Stop( 7 );
  N_T2b.Stop( 0 );
end; // end_of procedure TN_ULines.GetFieldsFromText

//**************************************************** TN_ULines.CopyFields ***
// copy to self given TN_ULines object fields
//
procedure TN_ULines.CopyFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution

  inherited;

  LFCoords := Copy( TN_ULines(SrcObj).LFCoords );
  LDCoords := Copy( TN_ULines(SrcObj).LDCoords );
end; // end_of procedure TN_ULines.CopyFields

//**************************************************** TN_ULines.CopyCoords ***
// copy to self given TN_ULines fields except WLCType and ObjName,
// coords are properly converted if needed.
// Except for Coords Type and preserving ObjName, CopyCoords method
// does the same as CopyFields method
//
procedure TN_ULines.CopyCoords( SrcObj: TN_UDBase );
var
  SrcType: integer;
  AName, AAliase, Info: string;
begin
  if SrcObj = nil then Exit; // a precaution

  AName   := ObjName;    // save Names
  AAliase := ObjAliase;
  Info    := ObjInfo;

  CopyBaseFields( SrcObj ); // copy all UCObjLayer fields

  ObjName   := AName;       // Restore Names
  ObjAliase := AAliase;
  ObjInfo   := Info;

  //***** Copy coords, same or changed type

  SrcType := TN_ULines(SrcObj).WLCType;

  if SrcType = Self.WLCType then
  begin
    LFCoords := Copy( TN_ULines(SrcObj).LFCoords );
    LDCoords := Copy( TN_ULines(SrcObj).LDCoords );
  end else // not same type
  begin
    if SrcType = N_FloatCoords then // convert from Float to Double
    begin
      LFCoords := nil;
      N_FCoordsToDCoords( TN_ULines(SrcObj).LFCoords, LDCoords );
    end else // convert from Double to Float
    begin
      LDCoords := nil;
      N_DCoordsToFCoords( TN_ULines(SrcObj).LDCoords, LFCoords );
    end;
  end; // else // not same type
end; // end_of procedure TN_ULines.CopyCoords

//**************************************************** TN_ULines.SameFields ***
// returns True if all Self.fields are the same to the given SrcObj.fields
// (SrcObj must be of the same class as self)
//
function TN_ULines.SameFields( SrcObj: TN_UDBase; AFlags: integer ): boolean;
var
  N1, N2: integer;
  Label NotSame;
begin
  if not (SrcObj is TN_ULines) then goto NotSame;

  Result := Inherited SameFields( SrcObj, AFlags ); // prelimenary value
  if Result = False then Exit; // not same

  if WLCType = N_FloatCoords then
  begin
    N1 := Items[WNumItems].CFInd*SizeOf(LFCoords[0]);

    with TN_ULines(SrcObj) do
      N2 := Items[WNumItems].CFInd*SizeOf(LFCoords[0]);

    if not N_SameBytes( @LFCoords[0], N1, @TN_ULines(SrcObj).LFCoords[0], N2 ) then goto NotSame;
  end else // Double Coords
  begin
    N1 := Items[WNumItems].CFInd*SizeOf(LDCoords[0]);

    with TN_ULines(SrcObj) do
      N2 := Items[WNumItems].CFInd*SizeOf(LDCoords[0]);

    if not N_SameBytes( @LDCoords[0], N1, @TN_ULines(SrcObj).LDCoords[0], N2 ) then goto NotSame;
  end;

  Exit; // Self and Src obj have same fields values

  NotSame: // Self and Src obj do NOT have same fields values
  Result := False;
end; // end_of procedure TN_ULines.SameFields

//************************************************** TN_ULines.GetIconIndex ***
// Get Icon Index in TreeView ImageList
//
function TN_ULines.GetIconIndex: Integer;
begin
  if WLCType = N_FloatCoords then Result := 2
                             else Result := 18;
end; // end_of function TN_ULines.GetIconIndex

//****************************************************** TN_ULines.AddCItem ***
// Add: Item's Index, Codes, Flags, Size(NumInds) and given AStr to Serial Text Buf
//
// Exactly the same code as in TN_UCObjLayer, except clearing Multipart
// bit in Items Flags for Single Part Items
//
procedure TN_ULines.AddCItem( SBuf: TK_SerialTextBuf; Ind: Integer;
                                                                AStr: string );
var
  NumInds, Flags: integer;
  CodesStr: string;
begin
  NumInds := Items[Ind].CFInd and N_CFIndMask;
  NumInds := (Items[Ind+1].CFInd and N_CFIndMask) - NumInds;
  CodesStr := GetItemAllCodes( Ind );

  Flags := Items[Ind].CFInd;
  if AStr = '1' then // Single Part Item, clear N_MultiPartBit
    Flags := Flags and (not N_MultiPartBit);

  SBuf.AddToken( Format( '%.6d  " %s"  $%.2x  %d %s', [Ind, CodesStr,
             (Flags shr N_CFIndShift), NumInds, AStr] ), K_ttString );
  SBuf.AddEOL();
end; // end of procedure TN_ULines.AddCItem

//**************************************************** TN_ULines.MoveFields ***
// Move to self given TN_UCObjLayer object fields
// (copy pointers to array objects to self and clear them in SrcObj)
//
procedure TN_ULines.MoveFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution

  inherited;

  LFCoords := TN_ULines(SrcObj).LFCoords;
  LDCoords := TN_ULines(SrcObj).LDCoords;
end; // end_of procedure TN_ULines.MoveFields

//*************************************************** TN_ULines.CompactSelf ***
// Just set needed length for all Self arrays, all Indexes remains the same
//
procedure TN_ULines.CompactSelf();
var
  NumPoints: integer;
begin
  inherited; // set needed Length to all Self Arrays except LFCoords, LDCoords

  NumPoints := Items[WNumItems].CFInd;

  if Length(LFCoords) > NumPoints then
    SetLength( LFCoords, NumPoints );

  if Length(LDCoords) > NumPoints then
    SetLength( LDCoords, NumPoints );
end; // procedure TN_ULines.CompactSelf

//************************************************** TN_ULines.UnSparseSelf ***
// Remove Empty and spars Items, set needed length for all Self arrays
//
procedure TN_ULines.UnSparseSelf();
var
  i, NumParts, NumPoints: integer;
  MemPtr: TN_BytesPtr;
  TmpCopy: TN_ULines;
  LItem: TN_ULinesItem;
begin
  if not WIsSparse then
  begin
    CompactSelf();
    Exit; // all done
  end; // if not WIsSparse then

  NumPoints := Items[WNumItems].CFInd;

  TmpCopy := TN_ULines.Create();
  TmpCopy.CopyFields( Self );
  TmpCopy.InitItems( WNumItems, NumPoints );

  LItem := TN_ULinesItem.Create( WLCType );

  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items
    LItem.Init();
    LItem.AddParts( Self, i, 0, NumParts );
    TmpCopy.ReplaceItemCoords( LItem, -1, Self, i );
  end; // for i := 0 to WNumItems-1 do

  TmpCopy.WIsSparse := False;
  TmpCopy.CompactSelf(); // decrease array lengths if needed
  MoveFields( TmpCopy );

  LItem.Free;
  TmpCopy.Free;
end; // procedure TN_ULines.UnSparseSelf

//************************************************ TN_ULines.GetSizeInBytes ***
// Get Self Size in Bytes
//
function TN_ULines.GetSizeInBytes(): integer;
begin
  Result := inherited GetSizeInBytes() +
                              Length(LFCoords)*Sizeof(LFCoords[0]) +
                              Length(LDCoords)*Sizeof(LDCoords[0]) + 2*8;
end; // end_of function TN_ULines.GetSizeInBytes

//*************************************************** TN_ULines.GetSelfInfo ***
// create Text Info strings about self
// Mode - what Info is needed:
//
procedure TN_ULines.GetSelfInfo( SL: TStrings; Mode: integer );
var
  i, j, NumParts: integer;
  MemPtr: TN_BytesPtr;
  DCoords: TN_DPArray;
begin
  DCoords := nil; // to avoid warning
  inherited;
  N_LineInfo.Clear;
  if WNumItems = 0 then N_LineInfo.MinNumPoints := 0;

  with N_LineInfo do
  begin

  for i := 0 to WNumItems-1 do
  with Items[i] do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items
    Inc(SumItems);

    if NumParts > 1 then
    begin
      Inc(SumMPItems);
      AvrNumParts := (AvrNumParts*(SumMPItems-1) + NumParts)/SumMPItems;
    end;
    if (MaxNumParts < NumParts) then MaxNumParts := NumParts;

    for j := 0 to NumParts-1 do
    begin
      GetPartDCoords( i, j, DCoords );
      CollectInfo( DCoords );
    end; // for j := 0 to NumParts-1 do

  end; // for i := 0 to WNumItems-1 do

  ConvToStrings( SL, 0 );
  end; // with N_LineInfo do
end; // procedure TN_ULines.GetSelfInfo

//*********************************************** TN_ULines.CalcItemEnvRect ***
// Calc EnvRect for given Item
//
procedure TN_ULines.CalcItemEnvRect( ItemInd: integer );
var
  i, NumParts, FirstInd, NumInds: integer;
  MemPtr: TN_BytesPtr;
  PartEnvRect: TFRect;
begin
  Items[ItemInd].EnvRect.Left := N_NotAFloat;
  GetNumParts( ItemInd, MemPtr, NumParts );
  if NumParts = 0 then Exit;

  for i := 0 to NumParts-1 do
  begin
    GetPartInds( MemPtr, i, FirstInd, NumInds );
    if WLCType = N_FloatCoords then
      PartEnvRect := N_CalcLineEnvRect( LFCoords, FirstInd, NumInds )
    else
      PartEnvRect := N_CalcLineEnvRect( LDCoords, FirstInd, NumInds );

    N_FRectOR( Items[ItemInd].EnvRect, PartEnvRect );
  end;
  N_FRectOR( WEnvRect, Items[ItemInd].EnvRect );
end; // end_of procedure TN_ULines.CalcItemEnvRect

//****************************************** TN_ULines.GetPartInds(MemPtr)  ***
// Get First Index and Number of Indexes (NumPoints) in given Part
// (version with given MemPtr, calculated by GetNumParts procedure)
//
procedure TN_ULines.GetPartInds( AMemPtr: TN_BytesPtr; PartInd: integer;
                              out AFirstInd: integer; out ANumInds: integer );
var
  IntType, ByteOfs, NumParts: integer;
begin
  if AMemPtr = nil then // single Part Item
  begin
    AFirstInd := WrkFPInd; // were set in GetNumParts procedure
    ANumInds  := WrkNumInds;
  end else //************* multi Part Item
  begin
    IntType := integer(AMemPtr^);

    if IntType = 1 then // one byte format
    begin
      NumParts := integer((AMemPtr+1)^);
      Assert( (PartInd >= 0) and (PartInd < NumParts), 'Bad PartInd' );
      ByteOfs := PartInd + 2;
      AFirstInd := integer((AMemPtr+ByteOfs)^);
      ANumInds  := integer((AMemPtr+ByteOfs+1)^) - AFirstInd;
      Inc( AFirstInd, WrkFPInd );
    end
    else if IntType = 2 then  // two bytes format
    begin
      NumParts := integer((TN_PUInt2(AMemPtr+1))^);
      Assert( (PartInd >= 0) and (PartInd < NumParts), 'Bad PartInd' );
      ByteOfs := (PartInd shl 1) + 3;
      AFirstInd := integer((TN_PUInt2(AMemPtr+ByteOfs))^);
      ANumInds  := integer((TN_PUInt2(AMemPtr+ByteOfs+2))^) - AFirstInd;
      Inc( AFirstInd, WrkFPInd );
    end
    else if IntType = 4 then // four bytes format
    begin
      NumParts := (PInteger(AMemPtr+1))^;
      Assert( (PartInd >= 0) and (PartInd < NumParts), 'Bad PartInd' );
      ByteOfs := (PartInd shl 2) + 5;
      AFirstInd := (PInteger(AMemPtr+ByteOfs))^;
      ANumInds  := (PInteger(AMemPtr+ByteOfs+4))^ - AFirstInd;
      Inc( AFirstInd, WrkFPInd );
    end
    else
      Assert( False, 'Bad IntType' );
  end;
end; // procedure TN_ULines.GetPartInds((MemPtr)

//****************************************** TN_ULines.GetPartInds(ItemInd) ***
// Get First Index and Number of Indexes (NumPoints) in given Part
// (version with given ItemInd)
//
procedure TN_ULines.GetPartInds( ItemInd, PartInd: integer;
                              out AFirstInd: integer; out ANumInds: integer );
var
  NumParts: integer;
  MemPtr: TN_BytesPtr;
begin
  GetNumParts( ItemInd, MemPtr, NumParts );

  if NumParts = 0 then
  begin
    AFirstInd := -1; // "empty item" flag
    ANumInds := 0;
    Exit;
  end;

  GetPartInds( MemPtr, PartInd, AFirstInd, ANumInds );
end; // procedure TN_ULines.GetPartInds(ItemInd)

//************************************************* TN_ULines.GetWNumParts  ***
// Get Whole Number of Parts in Self
//
function TN_ULines.GetWNumParts(): integer;
var
  i, NumParts: integer;
  MemPtr: TN_BytesPtr;
begin
  Result := 0;
  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    Inc( Result, NumParts );
  end;
end; // function TN_ULines.GetWNumParts

//************************************************** TN_ULines.GetNextPart  ***
// Get First Index and Number of Indexes (NumPoints) in given Part,
// increase ItemInd and PartInd to the Next Part (prepare for next call of self),
// ItemInd = -1 on output means end of Items,
// if ItemInd >= 0 then  AFirstInd and ANumInds are always OK
//
procedure TN_ULines.GetNextPart( var ItemInd, PartInd: integer;
                              out AFirstInd: integer; out ANumInds: integer );
var
  NumParts: integer;
  MemPtr: TN_BytesPtr;
  Label GetNext;
begin
  GetNext:

  if ItemInd >= WNumItems then // end of Items
  begin
    ItemInd := -1;
    Exit;
  end;

  GetNumParts( ItemInd, MemPtr, NumParts );

  if NumParts > 0 then
    GetPartInds( MemPtr, PartInd, AFirstInd, ANumInds )
  else
  begin
    Inc(ItemInd);
    PartInd := 0;
    goto GetNext;
  end;

  if PartInd = (NumParts-1) then // last Part
  begin
    Inc(ItemInd);
    PartInd := 0;
  end else
    Inc(PartInd);

end; // procedure TN_ULines.GetNextPart

//************************************************** TN_ULines.GetNumParts  ***
// Get Number of Parts in given Item and pointer AMemPtr to
// First CCoords element for MultiPart Items (pointer to LineList info)
// (for not MultiPart Items  AMemPtr=nil).
// WrkFPInd and WrkNumInds Self fields are set for given Item and
// can be used as output params.
//
procedure TN_ULines.GetNumParts( ItemInd: integer;
                              out AMemPtr: TN_BytesPtr; out ANumParts: integer );
var
  TmpInd, IntType: integer;
begin
  AMemPtr   := nil;
  ANumParts := 0;
  Assert( (ItemInd >= 0) and (ItemInd < WNumItems), 'Bad ItemInd' );

  TmpInd := Items[ItemInd].CFInd;
  if (TmpInd and N_EmptyItemBit) <> 0 then Exit; // empty Item

  WrkFPInd := TmpInd and N_CFIndMask;
  WrkNumInds  := (Items[ItemInd+1].CFInd and N_CFIndMask) - WrkFPInd;

  if (TmpInd and N_MultiPartBit) = 0 then // single Part Item
  begin
    ANumParts  := 1;
  end else //******************************* MultiPart Item
  begin
    if WLCType = N_FloatCoords then
      AMemPtr := TN_BytesPtr(@LFCoords[WrkFPInd])
    else
      AMemPtr := TN_BytesPtr(@LDCoords[WrkFPInd]);

    IntType := integer(AMemPtr^);

    if IntType = 1 then // one byte format
      ANumParts := integer((AMemPtr+1)^)
    else if IntType = 2 then  // two bytes format
      ANumParts := integer((TN_PUInt2(AMemPtr+1))^)
    else if IntType = 4 then  // four bytes format
      ANumParts := (PInteger(AMemPtr+1))^
    else
      Assert( False, 'Bad IntType' );
  end;
end; // end_of function TN_ULines.GetNumParts

//*************************************************** TN_ULines.GetNumParts ***
// Get Number of Parts in given Item using full version of GetNumParts
// WrkFPInd and WrkNumInds Self fields are set for given Item and
// can be used as output params.
//
function TN_ULines.GetNumParts( ItemInd: integer): integer;
var
  MemPtr: TN_BytesPtr;
begin
  GetNumParts( ItemInd, MemPtr, Result );
end; // end_of function TN_ULines.GetNumParts

//*************************************************** TN_ULines.DeleteParts ***
// delete given number (ANumParts) of Parts, beginning from BegPartInd,
// NumParts = -1 means deleteing all Parts from BegPartInd
// all arrays lengths remain the same, just relative offsets are changed
// if all parts should be deleted, whole Item is set Empty
// (by setting N_EmptyItemBit)
//
procedure TN_ULines.DeleteParts( ItemInd, BegPartInd, ANumParts: integer );
var
  i, LastPartInd, WNumParts, MoveSize, NewNumParts: integer;
  IntType, NumDelInds: integer;
  FPInd0, NumInds0, FPInd1, NumInds1: integer;
  FPIndBeg, NumIndsBeg, FPIndLast, NumIndsLast: integer;
  MemPtr: TN_BytesPtr;
begin
  GetNumParts( ItemInd, MemPtr, WNumParts ); // Whole Number of Parts
  if WNumParts = 0 then Exit; // whole Item is already empty

  Assert( (BegPartInd >= 0) and (BegPartInd < WNumParts), 'Bad BegPartInd' );
  if ANumParts < 0 then ANumParts := WNumParts - BegPartInd;
  if ANumParts > (WNumParts-BegPartInd) then
    ANumParts := WNumParts - BegPartInd;

  NewNumParts := WNumParts - ANumParts;

  if NewNumParts = 0 then // delete whole Item
  begin
    SetEmptyFlag( ItemInd );
    Exit;
  end;

  WIsSparse := True;
  LastPartInd := BegPartInd + ANumParts - 1;
  if LastPartInd >= WNumParts then LastPartInd := WNumParts - 1;

  GetPartInds( MemPtr, 0,           FPInd0,    NumInds0 );
  GetPartInds( MemPtr, BegPartInd,  FPIndBeg,  NumIndsBeg );
  GetPartInds( MemPtr, LastPartInd, FPIndLast, NumIndsLast );
  GetPartInds( MemPtr, WNumParts-1, FPInd1,    NumInds1 );

  if WLCType = N_FloatCoords then
  begin
    MoveSize := ((FPInd1+NumInds1) - (FPIndLast+NumIndsLast))*Sizeof(LFCoords[0]);
    if MoveSize > 0 then
      move( LFCoords[FPIndLast+NumIndsLast], LFCoords[FPIndBeg], MoveSize );
  end else
  begin
    MoveSize := ((FPInd1+NumInds1) - (FPIndLast+NumIndsLast))*Sizeof(LDCoords[0]);
    if MoveSize > 0 then
      move( LDCoords[FPIndLast+NumIndsLast], LDCoords[FPIndBeg], MoveSize );
  end;

  IntType    := integer(MemPtr^);
  NumDelInds := FPIndLast + NumIndsLast - FPIndBeg; // number of deleted Inds

  if IntType = 1 then // one byte format
  begin
    (MemPtr+1)^ := TN_Byte(NewNumParts);
    for i := BegPartInd+3 to NewNumParts+2 do
      (MemPtr+i)^ := TN_Byte( integer((MemPtr+i+ANumParts)^) - NumDelInds );
  end
  else if IntType = 2 then  // two bytes format
  begin
    (TN_PUInt2(MemPtr+1))^ := NewNumParts;
    for i := BegPartInd+3 to NewNumParts+2 do
      (TN_PUInt2(MemPtr+i))^ := (TN_PUInt2(MemPtr+i+ANumParts))^ - NumDelInds;
  end
  else if IntType = 4 then // four bytes format
  begin
    (PInteger(MemPtr+1))^ := NewNumParts;
    for i := BegPartInd+3 to NewNumParts+2 do
      (PInteger(MemPtr+i))^ := (PInteger(MemPtr+i+ANumParts))^ - NumDelInds;
  end
  else
    Assert( False, 'Bad IntType' );
end; // end_of procedure TN_ULines.DeleteParts

//************************************************ TN_ULines.GetPartDCoords ***
// Get double Coords of given Part in given Item,
// WrkFPInd, WrkNumInds, WrkFPointPtr  Self fields are set for given Part
// and can be used as output params
//
procedure TN_ULines.GetPartDCoords( ItemInd, PartInd: integer;
                                                     var DCoords: TN_DPArray );
var
  FPInd, NumInds: integer;
begin
  GetPartInds( ItemInd, PartInd, FPInd, NumInds );
  WrkFPInd  := FPInd;   // can be used as output params
  WrkNumInds   := NumInds;
  WrkFPointPtr := nil;
  DCoords := nil;

  if FPInd >= 0 then // there are some coords
  begin
    if WLCType = N_FloatCoords then
    begin
      N_FCoordsToDCoords( LFCoords, FPInd, DCoords, 0, NumInds );
      SetLength( DCoords, NumInds );
      WrkFPointPtr := @LFCoords[FPInd];
    end else
    begin
      DCoords := Copy( LDCoords, FPInd, NumInds );
      WrkFPointPtr := @LDCoords[FPInd];
    end;
  end; // if FPInd >= 0 then // there are some coords
end; // procedure TN_ULines.GetPartDCoords

//************************************************ TN_ULines.SetPartDCoords ***
// Set new Coords of given Part in given Item by given DCoords (DPArray),
// ItemInd = -1 means creating new Item (PartInd should be = 0 or -1),
// PartInd = -1 means creating new Part in given Item,
// if ItemInd or PartInd are -1 on input, on output the have created values.
//
// If changed (with new Coords) Item is not bigger then existed one,
// it is repalced by changed Item, otherwise existed Item is set Empty
// and new changed Item is added as last Item to Self
//
procedure TN_ULines.SetPartDCoords( var ItemInd, PartInd: integer;
                              const DCoords: TN_DPArray; ANumPoints: integer );
var
  NumParts, FPInd, NumPoints: integer;
  MemPtr: TN_BytesPtr;
  LinesItem: TN_ULinesItem;
  Label Fin;
begin
  if ANumPoints = -1 then ANumPoints := Length(DCoords);
  LinesItem := TN_ULinesItem.Create( WLCType );

  if (ItemInd = -1) or (ItemInd = WNumItems) then // add new Item (single Part)
  begin
    LinesItem.AddPartCoords( DCoords, 0, ANumPoints );
    ItemInd := WNumItems; // created ItemInd
    ReplaceItemCoords( LinesItem, -1 );
    PartInd := 0;
    Goto Fin;
  end;

  //***** Here: change Part Coords of given Part of given Item,
  //            create new Item if needed (if not enough place)

  GetNumParts( ItemInd, MemPtr, NumParts ); // NumParts = 0 is OK

  if (PartInd = -1) or (PartInd > NumParts) then // add new last Part
    PartInd := NumParts;

  if PartInd > 0 then // copy Parts before given PartInd
    LinesItem.AddParts( Self, ItemInd, 0, PartInd );

  LinesItem.AddPartCoords( DCoords, 0, ANumPoints ); // add given PartInd

  if PartInd < (NumParts-1) then // copy Parts after given PartInd
    LinesItem.AddParts( Self, ItemInd, PartInd+1, NumParts-PartInd-1 );

  ItemInd := ReplaceItemCoords( LinesItem, ItemInd ); // replace or add

  Fin: //***************** set WrkFPInd, WrkNumInds, WrkFPointPtr
  CalcItemEnvRect( ItemInd );
  GetPartInds( ItemInd, PartInd, FPInd, NumPoints );

  //***** Wrk... variables may be used as output params:

  WrkFPInd   := FPInd;
  WrkNumInds := NumPoints;

  if WLCType = N_FloatCoords then
    WrkFPointPtr := @LFCoords[FPInd]
  else
    WrkFPointPtr := @LDCoords[FPInd];

  LinesItem.Free;
end; // procedure TN_ULines.SetPartDCoords

//************************************************** TN_ULines.GetOneDPoint ***
// just Get double Coords of one Point ( CCInd - index in Coords array)
// (just to make source code slightly more plesant)
//
procedure TN_ULines.GetOneDPoint( CCInd: integer; out DVertex: TDPoint );
begin
  if WLCType = N_FloatCoords then
    DVertex := DPoint( LFCoords[CCInd] )
  else
    DVertex := LDCoords[CCInd];
end; // procedure TN_ULines.GetOneDPoint

//************************************************** TN_ULines.SetOneDPoint ***
// just set Coords of one Point ( CCInd - index in Coords array)
// (just to make source code slightly more plesant)
//
procedure TN_ULines.SetOneDPoint( CCInd: integer; const DVertex: TDPoint );
begin
  if WLCType = N_FloatCoords then
    LFCoords[CCInd] := FPoint( DVertex )
  else
    LDCoords[CCInd] := DVertex;
end; // procedure TN_ULines.SetOneDPoint

//************************************************* TN_ULines.GetVertexRefs ***
// collect all references to vertexes with same given double coords
//
// DVertex    - Vertex double coords
// VertexRefs - collected references to given vertex (on output)
// Mode       - what vertexes to check:
//              =0 - only Beg and End Vertexes
//              =1 - all Vertexes
//              =2 - only Internal Vertexes
//
procedure TN_ULines.GetVertexRefs( const DVertex: TDPoint; Mode: integer;
                                              var VertexRefs: TN_VertexRefs );
var
  i, j, k, NumParts, FPInd, LPInd, NumInds, RefsInd, TmpVFlags: integer;
  FVertex: TFPoint;
  MemPtr: TN_BytesPtr;
  IsSame: boolean;
begin
  RefsInd := 0;
  FVertex := FPoint( DVertex );

  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    for j := 0 to NumParts-1 do
    begin
      GetPartInds( MemPtr, j, FPInd, NumInds );
      LPInd := FPInd + NumInds - 1;
      k := FPInd;

      if Mode = 2 then // collect only Internal Vertexes
      begin
        Inc(k);
        Dec(LPInd);
      end;

      TmpVFlags := 0;

      while k <= LPInd do
      begin
        if k = LPInd then TmpVFlags := 2;

        if WLCType = N_FloatCoords then
          IsSame := (LFCoords[k].X = FVertex.X) and (LFCoords[k].Y = FVertex.Y)
        else
          IsSame := (LDCoords[k].X = DVertex.X) and (LDCoords[k].Y = DVertex.Y);

        if IsSame then
        begin
          if RefsInd > High(VertexRefs) then
            SetLength( VertexRefs, N_NewLength(RefsInd) );

          with VertexRefs[RefsInd] do
          begin
            ItemInd := i;
            PartInd := j;
            VertInd := k - FPInd;
            CCInd   := k;
            VFlags  := TmpVFlags;
          end;
          Inc(RefsInd);
        end; // if IsSame then

        TmpVFlags := 1; // all but first or last vertexes
        Inc(k);

        if Mode = 0 then // check only Beg and End Vertexes
        begin
          if k = FPInd+1 then k := LPInd
                         else Break;
        end; // if Mode = 0 then // check only Beg and End Vertexes

      end; //  while k <= LPInd do
    end; // for j := 0 to NumParts-1 do
  end; // for i := 0 to WNumItems-1 do
  SetLength( VertexRefs, RefsInd ); // final value
end; // end_of procedure TN_ULines.GetVertexRefs

//********************************************* TN_ULines.CangeVertexCoords ***
// set new given coords to all vertexes, referenced by VertexRefs array,
// update EnvRect of all changed items
//
// DVertex    - new Vertex double coords
// VertexRefs - collected references to given vertex (on input)
//
procedure TN_ULines.CangeVertexCoords( const DVertex: TDPoint;
                                             const VertexRefs: TN_VertexRefs );
var
  i: integer;
begin
  for i := 0 to High(VertexRefs) do // loop along all elems of VertexRefs
  with VertexRefs[i] do
  begin
    SetOneDPoint( CCInd, DVertex );
    N_IncEnvRect( Items[ItemInd].EnvRect, DVertex );
  end; // for i := 0 to High(VertexRefs) do
end; // procedure TN_ULines.CangeVertexCoords

//**************************************************** TN_ULines.AddULItem ***
// Add to Self some Parts and CObj Codes of given Item of given InpULines and
// return its Self ItemIndex
// Result = -1 means, that Item was not added (Empty input Item)
//
// WrkLineItem is used as temporary object and can be passed for
// saving construction/destruction time
//
function TN_ULines.AddULItem( InpULines: TN_ULines; InpItemInd, InpPartInd,
                 NumParts: integer; WrkLineItem: TN_ULinesItem = nil ): integer;
var
  TmpLineItem: TN_ULinesItem;
begin
  Result := -1; // as if Item was not added
  if WrkLineItem = nil then TmpLineItem := TN_ULinesItem.Create( WLCType )
                       else TmpLineItem := WrkLineItem;

  if NumParts = -1 then NumParts := InpULines.GetNumParts( InpItemInd )
  else if NumParts <= 0 then Exit; // skip empty items

  TmpLineItem.Init();
  TmpLineItem.AddParts( InpULines, InpItemInd, InpPartInd, NumParts );
  Result := ReplaceItemCoords( TmpLineItem, -1, InpULines, InpItemInd );

  if WrkLineItem = nil then TmpLineItem.Free;
end; // function TN_ULines.AddULItem

//**************************************************** TN_ULines.AddULItems ***
// Add to Self some Items of given InpULines
//
procedure TN_ULines.AddULItems( InpULines: TN_ULines; BegItemInd, NumItems: integer );
var
  i: integer;
  TmpLineItem: TN_ULinesItem;
begin
  if InpULines = nil then Exit;

  TmpLineItem := TN_ULinesItem.Create( WLCType );

  if NumItems = -1 then NumItems := InpULines.WNumItems - BegItemInd;

  for i := BegItemInd to NumItems-1 do
    AddULItem( InpULines, i, 0, -1, TmpLineItem );

  TmpLineItem.Free;
end; // procedure TN_ULines.AddULItems

//************************************************** TN_ULines.AddConvItems ***
// Add to Self given Items, Converted from given AULines by
// given procedure of Object AConvProc
//
procedure TN_ULines.AddConvertedItems( ASrcUlines: TN_ULines;
                                 AConvProc: TN_2DPAProcObj; ABegItem: integer;
                               ANumItems: integer; WrkLineItem: TN_ULinesItem );
var
  i, iend, j, NumParts: integer;
  MemPtr: TN_BytesPtr;
  DCoords1, DCoords2: TN_DPArray;
  TmpLineItem: TN_ULinesItem;
begin
  if WrkLineItem = nil then TmpLineItem := TN_ULinesItem.Create( WLCType )
                       else TmpLineItem := WrkLineItem;

  if ANumItems < 0 then iend := ASrcUlines.WNumItems - 1
                   else iend := ABegItem + ANumItems - 1;

  for i := ABegItem to iend do // along ASrcUlines to Convert and Add
  begin
    ASrcUlines.GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty Src Items

    TmpLineItem.Init();

    for j := 0 to NumParts-1 do
    begin
      ASrcUlines.GetPartDCoords( i, j, DCoords1 );
      AConvProc( DCoords1, DCoords2 ); // convert Part Coords
      TmpLineItem.AddPartCoords( DCoords2, 0, Length(DCoords2) );
    end; // for j := 0 to NumParts-1 do

    ReplaceItemCoords( TmpLineItem, -1, ASrcUlines, i );
  end; // for i := 0 to WNumItems-1 do

  CalcEnvRects();
  if WrkLineItem = nil then TmpLineItem.Free;
end; // procedure TN_ULines.AddConvItems

//***************************************************** TN_ULines.SplitItem ***
// split given Part of given Item at given Vertex
// all parts before splitted and first portion of splitted Part became one Item,
// second Portion and Parts afters splitted became another Item,
// VertexInd=0 and VertexInd=(NumInds-1) are OK
//
procedure TN_ULines.SplitItem( ItemInd, PartInd, VertexInd: integer );
var
  FPInd, NumInds, NumParts: integer;
  MemPtr: TN_BytesPtr;
  ULItem1, ULItem2: TN_ULinesItem;
begin
  GetNumParts( ItemInd, MemPtr, NumParts );
  GetPartInds( MemPtr, PartInd, FPInd, NumInds );

  //***** check if splitting is not needed
  if ((PartInd = 0) and (VertexInd = 0)) or
     ((PartInd = (NumParts-1)) and (VertexInd = (NumInds-1))) then Exit;

  ULItem1 := TN_ULinesItem.Create( WLCType );
  ULItem1.AddParts( Self, ItemInd, 0, PartInd ); // add all parts before given

  if VertexInd > 0 then // add beg potrion of splitted Part
  begin
    if WLCType = N_FloatCoords then
      ULItem1.AddPartCoords( LFCoords, FPInd, VertexInd+1 )
    else
      ULItem1.AddPartCoords( LDCoords, FPInd, VertexInd+1 );
  end;

  ULItem2 := TN_ULinesItem.Create( WLCType );

  if VertexInd < NumInds-1 then // add end potrion of splitted Part
  begin
    if WLCType = N_FloatCoords then
      ULItem2.AddPartCoords( LFCoords, FPInd+VertexInd, NumInds-VertexInd )
    else
      ULItem2.AddPartCoords( LDCoords, FPInd+VertexInd, NumInds-VertexInd );
  end;

  ULItem2.AddParts( Self, ItemInd, PartInd+1, NumParts-PartInd-1 ); //all after

  //***** replace Original Item by First new Item
  ReplaceItemCoords( ULItem1, ItemInd, Self, ItemInd ); // CObj Codes remains the same
  ReplaceItemCoords( ULItem2, -1, Self, ItemInd ); // add second new Item with same CObj Codes

  ULItem1.Free;
  ULItem2.Free;
end; // procedure TN_ULines.SplitItem

//***************************************************** TN_ULines.SplitPart ***
// split given Part of given Item at given Vertex
// new two parts are added to given Item instead of splitted part
//
procedure TN_ULines.SplitPart( ItemInd, PartInd, VertexInd: integer );
var
  FPInd, NumInds, NumParts: integer;
  MemPtr: TN_BytesPtr;
  ULItem: TN_ULinesItem;
begin
  GetPartInds( ItemInd, PartInd, FPInd, NumInds );
  if (VertexInd = 0) or (VertexInd = (NumInds-1)) then Exit; // nothing todo

  ULItem := TN_ULinesItem.Create( WLCType );
  ULItem.AddParts( Self, ItemInd, 0, PartInd ); // add all parts before given

  //***** add beg potrion of splitted Part (first new Part)
  if WLCType = N_FloatCoords then
    ULItem.AddPartCoords( LFCoords, FPInd, VertexInd+1 )
  else
    ULItem.AddPartCoords( LDCoords, FPInd, VertexInd+1 );

  //***** add end potrion of splitted Part (second new Part)
  if WLCType = N_FloatCoords then
    ULItem.AddPartCoords( LFCoords, FPInd+VertexInd, NumInds-VertexInd )
  else
    ULItem.AddPartCoords( LDCoords, FPInd+VertexInd, NumInds-VertexInd );

  GetNumParts( ItemInd, MemPtr, NumParts );
  ULItem.AddParts( Self, ItemInd, PartInd+1, NumParts-PartInd-1 ); // all after

  ReplaceItemCoords( ULItem, ItemInd, Self, ItemInd );
  ULItem.Free;
end; // procedure TN_ULines.SplitPart

//***************************************************** TN_ULines.SplitAuto ***
// call to SplitPart or SpliItem
//
procedure TN_ULines.SplitAuto( ItemInd, PartInd, VertexInd: integer );
begin
  Assert( (ItemInd >= 0) and (PartInd >= 0) and (VertexInd >= 0), 'Bad Ind!' );

  if GetNumParts( ItemInd ) = 1 then
    SplitItem( ItemInd, PartInd, VertexInd )
  else
    SplitPart( ItemInd, PartInd, VertexInd );
end; // procedure TN_ULines.SplitAuto

//************************************************** TN_ULines.CombineItems ***
// combine two given Items into one new one part Item;
// both source Items should have exactly one Part and same CObj Codes,
// if given VertexRefs could not be combined nothing happened,
// return -1 if Items cannot be combined or resulting ItemInd with combined Items
//
function TN_ULines.CombineItems( const VertexRefs: TN_VertexRefs ): integer;
var
  IInd1, IInd2, FPInd, NumInds, NumInts1, NumInts2, NumParts: integer;
  PCodes1, PCodes2: PInteger;
  CombinedFCoords: TN_FPArray;
  CombinedDCoords: TN_DPArray;
  LinesItem: TN_ULinesItem;
begin
  Result := -1;
  if Length(VertexRefs) <> 2 then Exit; // not TWO Lines
  if VertexRefs[0].ItemInd = VertexRefs[1].ItemInd then Exit; // same closed Line

  CombinedFCoords := nil;
  CombinedDCoords := nil;
  IInd1 := VertexRefs[0].ItemInd; // to reduce code size
  IInd2 := VertexRefs[1].ItemInd; // to reduce code size

  NumParts := GetNumParts( IInd1 );
  if NumParts = 0 then Exit; // Skip empty Item
  Assert( NumParts = 1, 'Not yet1!' );

  NumParts := GetNumParts( IInd2 );
  if NumParts = 0 then Exit; // Skip empty Item
  Assert( NumParts = 1, 'Not yet2!' );

  GetItemAllCodes( IInd1, PCodes1, NumInts1 );
  GetItemAllCodes( IInd2, PCodes2, NumInts2 );

  if not N_SameInts( PCodes1, NumInts1, PCodes2, NumInts2 ) then Exit; // Codes are not same

  if VertexRefs[0].VertInd <> 0 then // Item1 is beg of resulting line
  begin
    if WLCType = N_FloatCoords then
    begin
      GetPartInds( IInd1, 0, FPInd, NumInds );
      CombinedFCoords := Copy( LFCoords, FPInd, NumInds );
      GetPartInds( IInd2, 0, FPInd, NumInds );
      N_AddFcoordsToFCoords( CombinedFCoords, Copy( LFCoords, FPInd, NumInds ),
                                                        VertexRefs[1].VertInd );
    end else
    begin
      GetPartInds( IInd1, 0, FPInd, NumInds );
      CombinedDCoords := Copy( LDCoords, FPInd, NumInds );
      GetPartInds( IInd2, 0, FPInd, NumInds );
      N_AddDcoordsToDCoords( CombinedDCoords, Copy( LDCoords, FPInd, NumInds ),
                                                        VertexRefs[1].VertInd );
    end;
  end else if VertexRefs[1].VertInd <> 0 then // Item2 is beg of resulting line
  begin
    if WLCType = N_FloatCoords then
    begin
      GetPartInds( IInd2, 0, FPInd, NumInds );
      CombinedFCoords := Copy( LFCoords, FPInd, NumInds );
      GetPartInds( IInd1, 0, FPInd, NumInds );
      N_AddFcoordsToFCoords( CombinedFCoords, Copy( LFCoords, FPInd, NumInds ),
                                                        VertexRefs[0].VertInd );
    end else
    begin
      GetPartInds( IInd2, 0, FPInd, NumInds );
      CombinedDCoords := Copy( LDCoords, FPInd, NumInds );
      GetPartInds( IInd1, 0, FPInd, NumInds );
      N_AddDcoordsToDCoords( CombinedDCoords, Copy( LDCoords, FPInd, NumInds ),
                                                        VertexRefs[0].VertInd );
    end;
  end else // reversed Item1 is beg of resulting line
  begin
    if WLCType = N_FloatCoords then
    begin
      GetPartInds( IInd1, 0, FPInd, NumInds );
      N_AddFcoordsToFCoords( CombinedFCoords, Copy( LFCoords, FPInd, NumInds ), 1 );
      GetPartInds( IInd2, 0, FPInd, NumInds );
      N_AddFcoordsToFCoords( CombinedFCoords, Copy( LFCoords, FPInd, NumInds ), 0 );
    end else
    begin
      GetPartInds( IInd1, 0, FPInd, NumInds );
//      if N_i = 137 then N_AddArray( 0, 'I1 ', @LDCoords[FPInd], NumInds );
      N_AddDcoordsToDCoords( CombinedDCoords, Copy( LDCoords, FPInd, NumInds ), 1 );
//      if N_i = 137 then N_AddArray( 0, 'CDa ', @CombinedDCoords[0], NumInds );
      GetPartInds( IInd2, 0, FPInd, NumInds );
      N_AddDcoordsToDCoords( CombinedDCoords, Copy( LDCoords, FPInd, NumInds ), 0 );
//      if N_i = 137 then N_AddArray( 0, 'CDb ', @CombinedDCoords[0], Length(CombinedDCoords) );
    end;
  end;

  LinesItem := TN_ULinesItem.Create( WLCType );
  with LinesItem do
  begin
    if WLCType = N_FloatCoords then
      AddPartCoords( CombinedFCoords, 0, Length(CombinedFCoords) )
    else
      AddPartCoords( CombinedDCoords, 0, Length(CombinedDCoords) );
  end;

  SetEmptyFlag( IInd1 ); // make Item empty
  SetEmptyFlag( IInd2 ); // make Item empty
//  if N_i = 137 then N_AddArray( 0, 'Li ', @LinesItem.IPartDCoords[0], LinesItem.INumPoints ); // debug
  Result := ReplaceItemCoords( LinesItem, -1 );
  SetItemAllCodes( Result, PCodes1, NumInts1 );

  LinesItem.Free;
end; // procedure TN_ULines.CombineItems

//********************************************** TN_ULines.AutoCombineItems ***
// Try to Combine all adjacent Items with same Region Codes
// (temporary all Items should have one Part)
// return number of Combined Items
//
function TN_ULines.AutoCombineItems(): integer;
var
  i, NumParts, FPInd, NumInds: integer;
  P1, P2: TDPoint;
  VertexRefs: TN_VertexRefs;
  Label Nexti;
begin
  Result := 0;

  i := 0;
  while i < WNumItems do // WNumItems may be changed inside loop!
  begin
    NumParts := GetNumParts( i );
    if NumParts = 0 then goto Nexti; // Continue;
    Assert( NumParts = 1, 'Temporary!' );

    GetPartInds( i, 0, FPInd, NumInds );

    if FPInd >= 0 then // there are some coords
    begin
      if WLCType = N_FloatCoords then
      begin
        P1 := DPoint(LFCoords[FPInd]);
        P2 := DPoint(LFCoords[FPInd+NumInds-1]);
      end else
      begin
        P1 := LDCoords[FPInd];
        P2 := LDCoords[FPInd+NumInds-1];
      end;
    end else // no coords
      goto Nexti; // Continue;

    if N_Same( P1, P2 ) then goto Nexti; // (Continue) - skip closed lines

    GetVertexRefs ( P1, 0, VertexRefs );
    if 0 <= CombineItems( VertexRefs ) then // Items were combined
    begin
      Inc(Result);
      goto Nexti; // Continue;
    end;

    GetVertexRefs ( P2, 0, VertexRefs );
    if 0 <= CombineItems( VertexRefs ) then // Items were combined
      Inc(Result);

    Nexti: //**************
    Inc(i);
  end; // while i < WNumItems do // WNumItems may be changed inside loop!

end; // function TN_ULines.AutoCombineItems

//*********************************************** TN_ULines.InitItems(2Int) ***
// set WNumItems = 0 and set initial array sizes by given values
//
// ANumItems  - initial Items size
// ANumPoints - initial CCoords size
//
procedure TN_ULines.InitItems( ANumItems, ANumPoints: integer );
begin
  Inherited InitItems( ANumItems );

  if WLCType = N_FloatCoords then // Float Coords
  begin
    LDCoords := nil;
    if Length(LFCoords) < ANumPoints then
    begin
      LFCoords := nil;
      SetLength( LFCoords, ANumPoints );
    end;
  end else //*********************** Double Coords
  begin
    LFCoords := nil;
    if Length(LDCoords) < ANumPoints then
    begin
      LDCoords := nil;
      SetLength( LDCoords, ANumPoints );
    end;
  end;
end; // end_of procedure TN_ULines.InitItems(2Int)

//********************************************* TN_ULines.InitItems(ULines) ***
// set WNumItems = 0 and set initial array sizes by given ULines
//
procedure TN_ULines.InitItems( AULines: TN_ULines; ACoef: float );
begin
  InitItems( Round(AULines.WNumItems*ACoef), Round(ACoef*
                   Max( Length(AULines.LFCoords), Length(AULines.LDCoords))) );
end; // end_of procedure TN_ULines.InitItems(ULines)

//************************************************ TN_ULines.ConvSelfCoords ***
// Convert Self Coords using given AFunc with PParams
//
procedure TN_ULines.ConvSelfCoords( AFunc: TN_ConvDPFuncObj; APAuxPar: Pointer );
var
  i, iout, j, jout, k, NumParts: integer;
  MemPtr: TN_BytesPtr;
  DCoords: TN_DPArray;
begin
  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    for j := 0 to NumParts-1 do
    begin
      GetPartDCoords( i, j, DCoords );

      for k := 0 to High(DCoords) do
        DCoords[k] := AFunc( DCoords[k], APAuxPar );

      iout := i;
      jout := j;
      SetPartDCoords( iout, jout, DCoords );
    end; // for j := 0 to NumParts-1 do

  end; // for i := 0 to WNumItems-1 do
  
  CalcEnvRects();
end; // end_of procedure TN_ULines.ConvSelfCoords

//************************************************ TN_ULines.AffConvSelf(4) ***
// Affine Convert Self by given Coefs
//
procedure TN_ULines.AffConvSelf( AAffCoefs: TN_AffCoefs4 );
var
  i, iout, j, jout, NumParts: integer;
  MemPtr: TN_BytesPtr;
  DCoords1, DCoords2: TN_DPArray;
begin
  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    for j := 0 to NumParts-1 do
    begin
      GetPartDCoords( i, j, DCoords1 );
      N_AffConvCoords( AAffCoefs, DCoords1, DCoords2 );
      iout := i;
      jout := j;
      SetPartDCoords( iout, jout, DCoords2 );
    end; // for j := 0 to NumParts-1 do

  end; // for i := 0 to WNumItems-1 do

  CalcEnvRects();
end; // end_of procedure TN_ULines.AffConvSelf(4)

//************************************************ TN_ULines.AffConvSelf(6) ***
// Affine Convert Self by given Coefs
//
procedure TN_ULines.AffConvSelf( AAffCoefs: TN_AffCoefs6 );
var
  i, iout, j, jout, NumParts: integer;
  MemPtr: TN_BytesPtr;
  DCoords1, DCoords2: TN_DPArray;
begin
  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    for j := 0 to NumParts-1 do
    begin
      GetPartDCoords( i, j, DCoords1 );
      N_AffConvCoords( AAffCoefs, DCoords1, DCoords2 );
      iout := i;
      jout := j;
      SetPartDCoords( iout, jout, DCoords2 );
    end; // for j := 0 to NumParts-1 do

  end; // for i := 0 to WNumItems-1 do

  CalcEnvRects();
end; // end_of procedure TN_ULines.AffConvSelf(6)

//************************************************ TN_ULines.AffConvSelf(8) ***
// Affine Convert Self by given Coefs
//
procedure TN_ULines.AffConvSelf( AAffCoefs: TN_AffCoefs8 );
var
  i, iout, j, jout, NumParts: integer;
  MemPtr: TN_BytesPtr;
  DCoords1, DCoords2: TN_DPArray;
begin
  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    for j := 0 to NumParts-1 do
    begin
      GetPartDCoords( i, j, DCoords1 );
      N_AffConvCoords( AAffCoefs, DCoords1, DCoords2 );
      iout := i;
      jout := j;
      SetPartDCoords( iout, jout, DCoords2 );
    end; // for j := 0 to NumParts-1 do

  end; // for i := 0 to WNumItems-1 do

  CalcEnvRects();
end; // end_of procedure TN_ULines.AffConvSelf(8)

//*************************************************** TN_ULines.GeoProjSelf ***
// Convert Self by given GeoProj Params
//
procedure TN_ULines.GeoProjSelf( var AGeoProjPar: TN_GeoProjPar; AConvMode: integer );
var
  i, iout, j, jout, NumParts: integer;
  MemPtr: TN_BytesPtr;
  DCoords1, DCoords2: TN_DPArray;
begin
  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    for j := 0 to NumParts-1 do
    begin
      GetPartDCoords( i, j, DCoords1 );
      AGeoProjPar.ConvertLine( DCoords1, DCoords2, AConvMode );
      iout := i;
      jout := j;
      SetPartDCoords( iout, jout, DCoords2 );
    end; // for j := 0 to NumParts-1 do

  end; // for i := 0 to WNumItems-1 do
  CalcEnvRects();
end; // end_of procedure TN_ULines.GeoProjSelf

{
//************************************** TN_ULines.AffConv ***
// Affine Convert given SrcCObjLayer to self by given Coefs
//
procedure TN_ULines.AffConv( SrcCObjLayer: TN_UCObjLayer; AAffCoefs: TN_AffCoefs4 );
var
  i, iout, j, jout, NumParts, NumCodes, NewItemInd: integer;
  PFRegCode: PInteger;
  MemPtr: TN_BytesPtr;
  DCoords1, DCoords2: TN_DPArray;
begin
  Assert( (SrcCObjLayer.CI = CI) and
          (SrcCObjLayer.WNumItems = WNumItems) and
          (Length(TN_ULines(SrcCObjLayer).LFCoords) = Length(LFCoords)) and
          (Length(TN_ULines(SrcCObjLayer).LDCoords) = Length(LDCoords)), 'Bad ULines' );

  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items
    GetRegCodes( i, PFRegCode, NumCodes );

    for j := 0 to NumParts-1 do
    begin
      TN_ULines(SrcCObjLayer).GetPartDCoords( i, j, DCoords1 );
      N_AffConvCoords( AAffCoefs, DCoords1, DCoords2 );
      iout := i;
      jout := j;
      SetPartDCoords( iout, jout, DCoords2 );
    end; // for j := 0 to NumParts-1 do

  end; // for i := 0 to WNumItems-1 do
  CalcEnvRects();
end; // end_of procedure TN_ULines.AffConv

//********************************************* TN_ULines.InitRCXY ***
// Set N_RCXYBit, create RCXY array (if not yet) and fill it by -1
// (RCXY[i].X,Y = -1 means no Region Codes)
//
procedure TN_ULines.InitRCXY();
var
  i: integer;
begin
  WFlags := WFlags or N_RCXYBit;
  if Length(RCXY) <> WNumItems then
    SetLength( RCXY, WNumItems );

  for i := 0 to WNumItems-1 do
  begin
    RCXY[i].X := -1;
    RCXY[i].Y := -1;
  end;
end; // end_of procedure TN_ULines.InitRCXY
}

//************************************ TN_ULines.ReplaceItemCoords(NoCodes) ***
// Replace given Item of Self by given ULinesItem if there is enough place
// for it in LCoords Array (last Item is always replaced). If not enough
// place, Empty given Item and add new one.
// ItemInd = -1 means adding new Item.
// Region codes are not changed, new Item has no Region Codes
//
// Return index of changed Item (Replaced or new)
//
function TN_ULines.ReplaceItemCoords( ULinesItem: TN_ULinesItem;
                                                  ItemInd: integer ): integer;
var
  RFPInd, DstBegInd, FIInd, NumIInds, PointSize, NeededCoordsSize: integer;
  TmpPartsInfo: TN_IArray;
begin
  with ULinesItem do
  begin

  if INumParts <= 0 then // Empty ULinesItem
  begin
    if ItemInd <> -1 then
      SetEmptyFlag( ItemInd );

    Result := -1;
    Exit; // all done
  end; // if INumParts <= 0 then // Empty ULinesItem

  SetLength( TmpPartsInfo, INumParts+4 );

  if WLCType = N_FloatCoords then
    PointSize := Sizeof(LFCoords[0])
  else
    PointSize := Sizeof(LDCoords[0]);

  N_SetPartsInfo( TN_BytesPtr(@TmpPartsInfo[0]), IPartRInds, INumParts, PointSize, RFPInd );

  if ItemInd <> -1 then // just check if given Item has enough place and
  begin                 // set ItemInd = -1 if not

    if ItemInd = (WNumItems-1) then // last Item, it can be easily resized
    begin
      NeededCoordsSize := (Items[ItemInd].CFInd and N_CFIndMask) + INumPoints;
      if INumParts > 1 then Inc( NeededCoordsSize, RFPInd );
      Items[ItemInd+1].CFInd := NeededCoordsSize; // first free

      if WLCType = N_FloatCoords then
      begin
        if High(LFCoords) < NeededCoordsSize then // increase in advance
          SetLength( LFCoords, N_NewLength(NeededCoordsSize) );
      end else
      begin
        if High(LDCoords) < NeededCoordsSize then // increase in advance
          SetLength( LDCoords, N_NewLength(NeededCoordsSize) );
      end;

    end; // if ItemInd = (WNumItems-1) then // last Item, it can be easily resized

    GetItemInds( ItemInd, FIInd, NumIInds );

    if (NumIInds < (RFPInd + INumPoints)) and
       ((INumParts <> 1) or (NumIInds <> INumPoints)) then
    begin // INumParts=1 and NumIInds=INumPoints  - special case
      SetEmptyFlag( ItemInd );
      ItemInd := -1;
    end;
  end;

  if ItemInd = -1 then //********** create new Item
  begin

  if INumParts = 1 then RFPInd := 0;

  ItemInd := AddItemsSys(); // add new Items Array element
  DstBegInd := Items[ItemInd].CFInd and N_CFIndMask;

  if WLCType = N_FloatCoords then
  begin
    if High(LFCoords) < DstBegInd+RFPInd+INumPoints then // increase in advance
      SetLength( LFCoords, N_NewLength(DstBegInd+RFPInd+INumPoints) );

    if RFPInd > 0 then
      move( TmpPartsInfo[0], LFCoords[DstBegInd], RFPInd*Sizeof(LFCoords[0]) );
  end else
  begin
    if High(LDCoords) < DstBegInd+RFPInd+INumPoints then // increase in advance
      SetLength( LDCoords, N_NewLength(DstBegInd+RFPInd+INumPoints) );

    if RFPInd > 0 then
      move( TmpPartsInfo[0], LDCoords[DstBegInd], RFPInd*Sizeof(LDCoords[0]) );
  end;

  with Items[ItemInd] do // set Item attributes
  begin
    CFInd := DstBegInd;

    if INumPoints > 0 then
    begin
      if ICType = N_FloatCoords then
        EnvRect := N_CalcLineEnvRect( IPartFCoords, 0, INumPoints )
      else
        EnvRect := N_CalcLineEnvRect( IPartDCoords, 0, INumPoints );

      N_FRectOr( WEnvRect, EnvRect );
    end else
      EnvRect.Left := N_NotAFloat;

    if INumParts > 1 then
      CFInd := CFInd or N_MultiPartBit;
  end;

  Inc( DstBegInd, RFPInd );
  Items[ItemInd+1].CFInd := DstBegInd + INumPoints;
//  Items[ItemInd+1].CCInd := Items[ItemInd].CCInd;

  end else //*********************** replace given Item (ItemInd is given)
  begin

  if (INumParts=1) and (NumIInds=INumPoints) then
    RFPInd := 0
  else
  begin
    if RFPInd > 0 then // MultiPart Item (SysInfo exists)
    begin
      if WLCType = N_FloatCoords then
        move( TmpPartsInfo[0], LFCoords[FIInd], RFPInd*Sizeof(LFCoords[0]) )
      else
        move( TmpPartsInfo[0], LDCoords[FIInd], RFPInd*Sizeof(LDCoords[0]) );
    end;
  end;

  with Items[ItemInd] do // set Item attributes
  begin
    CFInd := FIInd;

    if INumPoints > 0 then
    begin
      if ICType = N_FloatCoords then
        EnvRect := N_CalcLineEnvRect( IPartFCoords, 0, INumPoints )
      else
        EnvRect := N_CalcLineEnvRect( IPartDCoords, 0, INumPoints );

      N_FRectOr( WEnvRect, EnvRect );
    end else
      EnvRect.Left := N_NotAFloat;

    if RFPInd > 0 then
      CFInd := CFInd or N_MultiPartBit;
  end;

  DstBegInd := FIInd + RFPInd;

  end; // else //************* replace given Item

  //***** Common part for Replace and Add cases

  if INumPoints > 0 then
  begin
    if WLCType = N_FloatCoords then
    begin
      if ICType = N_FloatCoords then
        move( IPartFCoords[0], LFCoords[DstBegInd], INumPoints*Sizeof(LFCoords[0]))
      else
        N_DCoordsToFCoords( IPartDCoords, 0, LFCoords, DstBegInd, INumPoints );
    end else //******************** WLCType = N_DoubleCoords
    begin
      if ICType = N_FloatCoords then
        N_FCoordsToDCoords( IPartFCoords, 0, LDCoords, DstBegInd, INumPoints )
      else
        move( IPartDCoords[0], LDCoords[DstBegInd], INumPoints*Sizeof(LDCoords[0]));
    end;
  end; // if INumPoints > 0 then

  end; // with ULinesItem do

  Result := ItemInd;
end; // function TN_ULines.ReplaceItemCoords(NoCodes)

//********************************* TN_ULines.ReplaceItemCoords(ThreeCodes) ***
// Replace given Item of Self by given ULinesItem and set given Three Codes
// Return index of changed Item (Replaced or new)
//
function TN_ULines.ReplaceItemCoords( ULinesItem: TN_ULinesItem; ItemInd: integer;
                                      ACDim0C1: integer; ACDim1C1: integer = -2;
                                      ACDim1C2: integer = -2 ): integer;
begin
  Result := ReplaceItemCoords( ULinesItem, ItemInd );
  SetItemThreeCodes( Result, ACDim0C1, ACDim1C1, ACDim1C2 );
end; // function TN_ULines.ReplaceItemCoords(ThreeCodes)

//*********************************** TN_ULines.ReplaceItemCoords(AllCodes) ***
// Replace given Item of Self by given ULinesItem and set all CObj Codes of
// some other given ASrcItemInd of ASrcULines
// (Self can be the same Object as ASrcULines)
// Return index of changed Item (Replaced or new)
//
function TN_ULines.ReplaceItemCoords( ULinesItem: TN_ULinesItem; ItemInd: integer;
                                ASrcULines: TN_ULines; ASrcItemInd: integer ): integer;
var
  NumCodesInts: integer;
  PCodes: PInteger;
begin
  ASrcULines.GetItemAllCodes( ASrcItemInd, PCodes, NumCodesInts );
  Result := ReplaceItemCoords( ULinesItem, ItemInd );
  SetItemAllCodes( Result, PCodes, NumCodesInts );
end; // function TN_ULines.ReplaceItemCoords(AllCodes)

//**************************************************** TN_ULines.SmoothSelf ***
// Smooth Self
//
// Mode      - not used now
// Coef      - Coef by wich Delta param increases
// MinDelta  - initial Delta param of N_DecNumberOfLinePoints2
// MaxDelta  - final Delta param of N_DecNumberOfLinePoints2
//
procedure TN_ULines.SmoothSelf( Mode: integer;
                                MinDelta, MaxDelta, DeltaCoef: double );
var
  i, iout, j, jout, NumParts: integer;
  MemPtr: TN_BytesPtr;
  DCoords1, DCoords2: TN_DPArray;
  TmpUL: TN_ULines;
begin
  TmpUL := TN_ULines.Create2( Self);
  TmpUL.InitItems( WNumItems, Length(LFCoords) + Length(LDCoords) );

  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then
    begin
//      TmpUL.AddEmptyItem(); // to preserve Item indexes
      TmpUL.SetEmptyFlag( TmpUL.AddItemsSys() );
      Continue;
    end;

    for j := 0 to NumParts-1 do
    begin
      GetPartDCoords( i, j, DCoords1 );
      N_DecNumberOfLinePoints3( DCoords1, DCoords2, Mode,
                                              MinDelta, MaxDelta, DeltaCoef );
      iout := i;
      jout := j;
      TmpUL.SetPartDCoords( iout, jout, DCoords2 );
    end; // for j := 0 to NumParts-1 do

    TmpUL.SetItemAllCodes( i, Self, i );

  end; // for i := 0 to WNumItems-1 do

  MoveFields( TmpUL );
  TmpUL.Free;
end; // end_of procedure TN_ULines.SmoothSelf

//*********************************************** TN_ULines.FindByEndPoints ***
// Find Item (PartInd=0) with given EndPoints
// Return it's index or -1 if not found
//
function TN_ULines.FindByEndPoints( const P1, P2: TDPoint ): integer;
var
  i, k: integer;
  DC: TN_DPArray;
begin
  for i := 0 to WNumItems-1 do
  begin
    GetPartDCoords( i, 0, DC );
    k := High(DC);

    if ( N_Same( P1, DC[0] ) and N_Same( P2, DC[k] ) ) or
       ( N_Same( P1, DC[k] ) and N_Same( P2, DC[0] ) )   then
    begin
      Result := i; // found
      Exit;
    end;
  end; // for i := 0 to WNumItems-1 do

  Result := -1; // not found
end; // function TN_ULines.FindByEndPoints

//********************************************** TN_ULines.SetCodesByULines ***
// Set All Self Codes by given SrcULines
// ( copy All Codes from SrcULines Items with same EndPoints )
//
procedure TN_ULines.SetCodesByULines( SrcULines: TN_ULines );
var
  i, k, Ind: integer;
  DC: TN_DPArray;
begin
  ClearAllCodes();

  for i := 0 to WNumItems-1 do
  begin
    GetPartDCoords( i, 0, DC );
    k := High(DC);
    Ind := SrcULines.FindByEndPoints( DC[0], DC[k] );

    if Ind >= 0 then
      SetItemAllCodes( i, SrcULines, Ind );

  end; // for i := 0 to WNumItems-1 do
end; // procedure TN_ULines.SetCodesByULines

//**************************************************** TN_ULines.SnapToGrid ***
// Snap all Vertex Coords to given Grid without deleting same points
//
procedure TN_ULines.SnapToGrid( const Origin, Step: TDPoint );
var
  i, j, k, NumParts, FirstInd, NumInds: integer;
  NSteps: Int64;
  MemPtr: TN_BytesPtr;
begin
  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    for j := 0 to NumParts-1 do
    begin
      GetPartInds( MemPtr, j, FirstInd, NumInds );

      for k := FirstInd to FirstInd+NumInds-1 do
      begin

        if WLCType = N_FloatCoords then //***** Float Coords
        begin
          if Step.X <> 0.0 then
          begin
            NSteps := Round( ( LFCoords[k].X - Origin.X ) / Step.X );
            LFCoords[k].X := Origin.X + NSteps*Step.X;
          end;

          if Step.Y <> 0.0 then
          begin
            NSteps := Round( ( LFCoords[k].Y - Origin.Y ) / Step.Y );
            LFCoords[k].Y := Origin.Y + NSteps*Step.Y;
          end;
        end else //**************************** Double Coords
        begin
          if Step.X <> 0.0 then
          begin
            NSteps := Round( ( LDCoords[k].X - Origin.X ) / Step.X );
            LDCoords[k].X := Origin.X + NSteps*Step.X;
          end;

          if Step.Y <> 0.0 then
          begin
            NSteps := Round( ( LDCoords[k].Y - Origin.Y ) / Step.Y );
            LDCoords[k].Y := Origin.Y + NSteps*Step.Y;
          end;
        end; // else - Double Coords

      end; // for k := FirstInd to FirstInd+NumInds-1 do
    end; // for j := 0 to NumParts-1 do
  end; // for i := 0 to WNumItems-1 do

  CalcEnvRects();
end; // end_of procedure TN_ULines.SnapToGrid

//******************************************** TN_ULines.DeleteSameVertexes ***
// Delete all vertexes with same coords and one Vertex Lines
// (now for single Part Items only)
//
procedure TN_ULines.DeleteSameVertexes();
var
  i, ItemInd, PartInd, NumParts, Curleng, NewLeng: integer;
  DC1, DC2: TN_DPArray;
begin
  for i := 0 to WNumItems-1 do
  begin
    NumParts := GetNumParts( i );
    if NumParts = 0 then Continue; // skip empty items
    Assert( NumParts = 1, 'Not yet!' ); // implement later

    ItemInd := i;
    PartInd := 0;
    GetPartDCoords( ItemInd, PartInd, DC1 );
    CurLeng := Length(DC1);
    NewLeng := N_DeleteSameDVertexes( @DC1[0], CurLeng, DC2 );
    if NewLeng = CurLeng then Continue; // Part was not changed

    if NewLeng >= 2 then // change Item coords
    begin
      SetLength( DC2, NewLeng );
      SetPartDCoords( ItemInd, PartInd, DC2 );
    end else // clear Item
      SetEmptyFlag( ItemInd );

  end; // for i := 0 to WNumItems-1 do
end; // end_of procedure TN_ULines.DeleteSameVertexes

//***************************************** TN_ULines.AddSegmentItem(float) ***
// Add to Self given float Segment (P1,P2) as new Item
//
procedure TN_ULines.AddSegmentItem( const P1, P2: TFPoint );
var
  ItemInd, PartInd: integer;
  DC: TN_DPArray;
begin
  SetLength( DC, 2 );
  DC[0] := DPoint(P1);
  DC[1] := DPoint(P2);
  ItemInd := -1;
  PartInd := 0;
  SetPartDCoords( ItemInd, PartInd, DC );
end; // procedure TN_ULines.AddSegmentItem(float)

//**************************************** TN_ULines.AddSegmentItem(double) ***
// Add to Self given double Segment (P1,P2) as new Item
//
procedure TN_ULines.AddSegmentItem( const P1, P2: TDPoint );
var
  ItemInd, PartInd: integer;
  DC: TN_DPArray;
begin
  SetLength( DC, 2 );
  DC[0] := P1;
  DC[1] := P2;
  ItemInd := -1;
  PartInd := 0;
  SetPartDCoords( ItemInd, PartInd, DC );
end; // procedure TN_ULines.AddSegmentItem(double)

//******************************************** TN_ULines.AddRectItem(float) ***
// Add to Self given float Rect as new Item
//
procedure TN_ULines.AddRectItem( const ARect: TFRect );
var
  ItemInd, PartInd: integer;
  DC: TN_DPArray;
begin
  SetLength( DC, 5 );
  DC[0] := DPoint(ARect.TopLeft);
  DC[1].X := ARect.Right;
  DC[1].Y := ARect.Top;
  DC[2] := DPoint(ARect.BottomRight);
  DC[3].X := ARect.Left;
  DC[3].Y := ARect.Bottom;
  DC[4] := DPoint(ARect.TopLeft);
  ItemInd := -1;
  PartInd := 0;
  SetPartDCoords( ItemInd, PartInd, DC );
end; // procedure TN_ULines.AddRectItem(float)

//************************************************* TN_ULines.AddSimpleItem ***
// Add given DCoords as last new Item with possible one CObj Code to CDimInd=0
// (just to slightly reduce code size)
//
procedure TN_ULines.AddSimpleItem( const DCoords: TN_DPArray;
                                               ANumPoints, AOneCode: integer );
var
  ItemInd, PartInd: integer;
begin
  ItemInd := -1;
  PartInd := -1;
  SetPartDCoords( ItemInd, PartInd, DCoords, ANumPoints );

  if AOneCode <> -1 then
    SetCCode( ItemInd, AOneCode );

end; // procedure TN_ULines.AddSimpleItem

{
//********************************** TN_ULines.AddRoundRectItem ***
// Add to Self border of given float ARect as new Item
// (whole border width is inside ARect)
//
// ARect     - outer envelope of RoundRect with given UserBorderWidth
// APCPanel  - Pointer to Panel params (only radiuses and RadUnits fields are used)
//             (Radiuses = -1 means that UpperLeft corenr radiuses are used)
// ALLWUSize - One LLW Size in User Units (used if radiuses are given in LLW)
// NumCornerPoints - number of points in each corner arc if RX,RY <> 0
// ABorderWidth    - Border Width in LLW
//
procedure TN_ULines.AddRoundRectItem( const ARect: TFRect; APCPanel: TN_PCPanel;
                                 ALLWUSize: float; NumCornerPoints: integer;
                                                     ABorderWidth: float );
var
  NumPoints, ItemInd, PartInd: integer;
  HW: float;
  CenterLineRect: TFRect;
  DC: TN_DPArray;
begin
  HW := 0.5*(ABorderWidth-1)*ALLWUSize;
  with ARect do
    CenterLineRect := FRect( Left+HW, Top+HW, Right-HW, Bottom-HW );

  SetLength( DC, 1+(1+NumCornerPoints)*4 );
  NumPoints := N_CalcRoundRectDCoords( @DC[0], APCPanel, ALLWUSize,
                                             CenterLineRect, NumCornerPoints );
  SetLength( DC, NumPoints );
  ItemInd := -1;
  PartInd := 0;
  SetPartDCoords( ItemInd, PartInd, DC );
end; // procedure TN_ULines.AddRoundRectItem
}

//*********************************************** TN_ULines.AddGridSegments ***
// Add to Self lines of given grid in given ARect,
// each grid line is one segment with ARect Width or Height length,
// ARect should be ordered, Step > 0
//
procedure TN_ULines.AddGridSegments( const ARect: TFRect; const Origin, Step: TDPoint );
var
  UL, P1, P2: TDPoint;
begin
  if N_RectOrder( ARect ) <> 0 then Exit; // a precaution
  UL := N_SnapPointToGrid( Origin, Step, DPoint(ARect.TopLeft) );

  if UL.X < ARect.Left then UL.X := UL.X + Step.X;
  if UL.Y < ARect.Top  then UL.Y := UL.Y + Step.Y;

  P1.X := UL.X;
  P1.Y := ARect.Top;
  P2.X := P1.X;
  P2.Y := ARect.Bottom;

  if Step.X > 0 then
    while True do // draw vertical lines, loop along X-axis
    begin
      AddSegmentItem( P1, P2 );
      P1.X := P1.X + Step.X;
      P2.X := P1.X;
      if P1.X > ARect.Right then Break;
    end; // while True do // draw vertical lines, loop along X-axis

  P1.X := ARect.Left;
  P1.Y := UL.Y;
  P2.X := ARect.Right;
  P2.Y := P1.Y;

  if Step.Y > 0 then
    while True do // draw horizontal lines, loop along Y-axis
    begin
      AddSegmentItem( P1, P2 );
      P1.Y := P1.Y + Step.Y;
      P2.Y := P1.Y;
      if P1.Y > ARect.Bottom then Break;
    end; // while True do // draw horizontal lines, loop along Y-axis

end; // procedure TN_ULines.AddGridSegments

//*************************************************** TN_ULines.AddHorLines ***
// Add to Self Horizontal lines in given ARect
// Step.Y > 0 is Step between Lines
// Step.X > 0 is Step between internal Vertexes in one Line
// ARect should be ordered
//
procedure TN_ULines.AddHorLines( const ARect: TFRect; const Origin, Step: TDPoint );
var
  i, NX: integer;
  UL: TDPoint;
  DC: TN_DPArray;
begin
  if N_RectOrder( ARect ) <> 0 then Exit; // a precaution
  if (Step.X <= 0) or (Step.Y <= 0) then Exit; // a precaution

  UL := N_SnapPointToGrid( Origin, Step, DPoint(ARect.TopLeft) );
  if UL.X <= ARect.Left  then UL.X := UL.X + Step.X;

  // NX - number of vertexes stricly between ARect.Left and ARect.Right
  // whole line has NX+2 points

  if UL.X >= ARect.Right then
    NX := 0
  else
    NX := Round(Floor( (ARect.Right-UL.X)/Step.X ));

  if UL.Y < ARect.Top  then UL.Y := UL.Y + Step.Y;

  SetLength( DC, NX+2 );

  while True do // draw horizontal lines, loop along Y-axis
  begin
    DC[0].X := ARect.Left;
    DC[0].Y := UL.Y;

    for i := 0 to NX-1 do // along all internal Points
    begin
      DC[i+1].X := UL.X + i*Step.X;
      DC[i+1].Y := UL.Y;
    end; // for i := 0 to NX-1 do // along all internal Points

    DC[NX+1].X := ARect.Right;
    DC[NX+1].Y := UL.Y;

    AddSimpleItem( DC, NX+2 );

    UL.Y := UL.Y + Step.Y;
    if UL.Y > ARect.Bottom then Break;
  end; // while True do // draw horizontal lines, loop along Y-axis

end; // procedure TN_ULines.AddHorLines

//************************************************** TN_ULines.AddVertLines ***
// Add to Self Vertical lines in given ARect
// Step.X > 0 is Step between Lines
// Step.Y > 0 is Step between internal Vertexes in one Line
// ARect should be ordered
//
procedure TN_ULines.AddVertLines( const ARect: TFRect; const Origin, Step: TDPoint );
var
  i, NY: integer;
  UL: TDPoint;
  DC: TN_DPArray;
begin
  if N_RectOrder( ARect ) <> 0 then Exit; // a precaution
  if (Step.X <= 0) or (Step.Y <= 0) then Exit; // a precaution

  UL := N_SnapPointToGrid( Origin, Step, DPoint(ARect.TopLeft) );
  if UL.Y <= ARect.Top then UL.Y := UL.Y + Step.Y;

  // NY - number of vertexes stricly between ARect.Top and ARect.Bottom,
  // whole line has NY+2 points

  if UL.Y >= ARect.Bottom then
    NY := 0
  else
    NY := Round(Floor( (ARect.Bottom-UL.Y)/Step.Y ));

  if UL.X < ARect.Left then UL.X := UL.X + Step.X;

  SetLength( DC, NY+2 );

  while True do // draw Vertical lines, loop along X-axis
  begin
    DC[0].X := UL.X;
    DC[0].Y := ARect.Top;

    for i := 0 to NY-1 do // along all internal Points
    begin
      DC[i+1].X := UL.X;
      DC[i+1].Y := UL.Y + i*Step.Y;
    end; // for i := 0 to NY-1 do // along all internal Points

    DC[NY+1].X := UL.X;
    DC[NY+1].Y := ARect.Bottom;

    AddSimpleItem( DC, NY+2 );

    UL.X := UL.X + Step.X;
    if UL.X > ARect.Right then Break;
  end; // while True do // draw Vertical lines, loop along X-axis

end; // procedure TN_ULines.AddVertLines


//********** TN_UContours class methods  **************

//***************************************************** TN_UContours.Create ***
//
constructor TN_UContours.Create;
begin
  inherited Create;
  ClassFlags := N_UContoursCI;
  InitItems( 0, 0, 0 );
  ImgInd := 3;
{
  SetLength( CRings, 1 );

  with CRings[0] do // fill last "dummy" Ring
  begin
    REnvRect := N_NotAFRect; // a precaution, not really needed
    RFlags := 0;             // a precaution, not really needed
    RLInd  := 0;             // the only field that is needed
    RFCoords := nil;         // a precaution, not really needed
    RDCoords := nil;         // a precaution, not really needed
  end;
}
end; // end_of constructor TN_UContours.Create

//**************************************************** TN_UContours.Destroy ***
//
destructor TN_UContours.Destroy;
begin
  CRings    := nil;
  LinesInds := nil;

  inherited Destroy;
end; // end_of destructor TN_UContours.Destroy

//******************************************** TN_UContours.AddFieldsToSBuf ***
// save self to Serial Buf
//
procedure TN_UContours.AddFieldsToSBuf( SBuf: TN_SerialBuf );
var
  NRings: integer;
begin
  CompactSelf();

  Inherited;

  NRings := Length( CRings );
  SBuf.AddRowInt( NRings );
  SBuf.AddRowBytes( NRings*SizeOf(CRings[0]), @CRings[0] );
  SBuf.AddIntegerArray( LinesInds );
end; // end_of procedure TN_UContours.AddFieldsToSBuf

//**************************************** TN_UContours.GetFieldsFromSBuf ***
// load self from Serial Buf
//
procedure TN_UContours.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
var
  i, NRings: integer;
begin
  Inherited;

  SBuf.GetRowInt( NRings );
  SetLength( CRings, NRings );
  SBuf.GetRowBytes( NRings*SizeOf(CRings[0]), @CRings[0] );
  SBuf.GetIntegerArray( LinesInds );

  // because Rings Coords were not saved, clear them
  for i := 0 to NRings-1 do with CRings[i] do
  begin
    integer(RFCoords) := 0;
    integer(RDCoords) := 0;
  end;
end; // end_of procedure TN_UContours.GetFieldsFromSBuf

//******************************************** TN_UContours.AddFieldsToText ***
// save self to Serial Text Buf
//
function TN_UContours.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ): Boolean;
var
  i, j, LastInd, NumLines, FirstRing, NumRings: integer;
  Str: string;
begin
//  N_s := ObjName; // debug

  inherited AddFieldsToText( SBuf, AShowFlags );

  N_AddTagAttrDef( SBuf, 'WrkNumRings', Items[WNumItems].CFInd, K_isInteger, 0 ); // mainly for speed
  SBuf.AddEOL( False );

  if Length(Items) = 0 then
  begin
    SBuf.AddToken( N_EndOfArray, K_ttString );
    SBuf.AddEOL();
  end else
  begin
    for i := 0 to WNumItems-1 do
    with Items[i] do
    begin
      AddCItem( SBuf, i );
      GetItemInds( i, FirstRing, NumRings );
      LastInd := FirstRing + NumRings - 1; // last Ring Ind

      for j := FirstRing to LastInd do // along all CRings of cur Item (Contour)
      with CRings[j] do
      begin
        NumLines := CRings[j+1].RLInd - RLInd;
        Str := Format( ' $%.4x %d', [RFlags, NumLines] );
        SBuf.AddToken( Str, K_ttString );
        SBuf.AddEOL( False );
        SBuf.AddRowScalars( LinesInds[RLInd], NumLines, Sizeof(integer), K_isInteger );
        SBuf.AddEOL( False );
      end; // for j := CFInd to LastInd do
    end; // for i := 0 to WNumItems-1 do

    SBuf.AddToken( N_EndOfArray, K_ttString );
  end;
  SBuf.AddEOL();

  Result := True;
end; // end_of procedure TN_UContours.AddFieldsToText

//**************************************** TN_UContours.GetFieldsFromText ***
// load self from Serial Text Buf
//
function TN_UContours.GetFieldsFromText( SBuf: TK_SerialTextBuf ): Integer;
var
  i, ItemInd, FirstRing, NumRings, NumLines: integer;
  WrkNumItems, WrkNumRings: integer;
  FreeRingsInd, FreeLinesInd: integer;
begin
  inherited GetFieldsFromText( SBuf );
//  N_s := ObjName; // debug
//  N_AddStr( 1, 'Begin Loading: ' + ObjName ); // debug

  N_i := SBuf.GetRowNumber( 0 );
  N_GetTagAttrDef( SBuf, 'WrkNumItems', WrkNumItems, K_isInteger, 0 );
  N_GetTagAttrDef( SBuf, 'WrkNumRings', WrkNumRings, K_isInteger, 0 );
  InitItems( WrkNumItems, WrkNumRings, 3*WrkNumRings );

  FreeRingsInd := 0; // to avoid warning
  FreeLinesInd := 0;

  while True do // along all SBuf Content
  begin

  ItemInd := GetCItem( SBuf, NumRings );
  if ItemInd = -1 then Break; // end of items

  with Items[ItemInd] do
  begin
    FirstRing := Items[ItemInd].CFInd and N_CFIndMask; // First Ring Index
    FreeRingsInd := FirstRing + NumRings;
    Items[ItemInd+1].CFInd := FreeRingsInd;

    if High(CRings) < FreeRingsInd then
      SetLength( CRings, N_NewLength( FreeRingsInd ) );

    for i := FirstRing to FreeRingsInd-1 do // loop along Contour's CRings
    with CRings[i] do
    begin
      REnvRect := N_NotAFRect;
      RFCoords := nil;
      RDCoords := nil;
      SBuf.GetScalar( RFlags, K_isInteger );
      SBuf.GetScalar( NumLines, K_isInteger );
      RLInd := FreeLinesInd;
      Inc( FreeLinesInd, NumLines );
      if High(LinesInds) < FreeLinesInd then
        SetLength( LinesInds, N_NewLength( FreeLinesInd ) );
      SBuf.GetRowScalars( LinesInds[RLInd], NumLines, Sizeof(integer), K_isInteger );
    end; // for i := CFInd to CFInd+NumRings-1 do

  end; // with Items[Ind] do
  end; // while True do // along all SBuf Content

  with CRings[FreeRingsInd] do // fill last "dummy" Ring
  begin
    REnvRect := N_NotAFRect; // a precaution, not really needed
    RFlags := 0;             // a precaution, not really needed
    RLInd := FreeLinesInd;   // the only field that is needed
    RFCoords := nil;         // a precaution, not really needed
    RDCoords := nil;         // a precaution, not really needed
  end;

  // CalcEnvRects() should not be called because ULines child is not loaded yet!
  WEnvRect.Left := N_NotAFloat; // set "EnvRects were not not calculated" flag
  CompactSelf();

  if (WFlags and N_IgnoreIndsBit) <> 0 then // Inds from SBuf were ignored, Self is not Sparse
  begin
    WIsSparse := False;
    WFlags := WFlags xor N_IgnoreIndsBit; // clear N_IgnoreIndsBit
  end;

  Result := 0;
end; // end_of procedure TN_UContours.GetFieldsFromText

//************************************************* TN_UContours.CopyFields ***
// copy to self given TN_UContours object
//
procedure TN_UContours.CopyFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution

  inherited;

  CRings    := Copy( TN_UContours(SrcObj).CRings );
  LinesInds := Copy( TN_UContours(SrcObj).LinesInds );
end; // end_of procedure TN_UContours.CopyFields

//************************************************* TN_UContours.SameFields ***
// returns True if all self.fields are the same as given SrcObj.fields
// (SrcObj must be of the same class as self)
//
function TN_UContours.SameFields( SrcObj: TN_UDBase; AFlags: integer ): boolean;
var
  N1, N2: integer;
  Label NotSame;
begin
  if not (SrcObj is TN_UContours) then goto NotSame;

  Result := Inherited SameFields( SrcObj, AFlags ); // prelimenary value
  if Result = False then Exit; // not same

  N1 := Items[WNumItems].CFInd*Sizeof(CRings[0]);

  with TN_UContours(SrcObj) do
    N2 := Items[WNumItems].CFInd*Sizeof(CRings[0]);

  if not N_SameBytes( @CRings[0], N1, @TN_UContours(SrcObj).CRings[0], N2 ) then goto NotSame;

  N1 := CRings[Items[WNumItems].CFInd].RLInd;

  with TN_UContours(SrcObj) do
    N2 := CRings[Items[WNumItems].CFInd].RLInd;

  if not N_SameInts( @LinesInds[0], N1, @TN_UContours(SrcObj).LinesInds[0], N2 ) then goto NotSame;

  Exit; // Self and Src obj have same fields values

  NotSame: // Self and Src obj do NOT have same fields values
  Result := False;
end; // end_of procedure TN_UContours.SameFields

//************************************************ TN_UContours.CompactSelf ***
// Just set needed length for all Self arrays, all Indexes remains the same
//
procedure TN_UContours.CompactSelf();
var
  NumRings, NumLines: integer;
begin
  inherited; // set needed Length to all Self Arrays except CRings and LinesInds

  NumRings := Items[WNumItems].CFInd;

  // Note: number of elements in CRings is NumRings+1

  if Length(CRings) > (NumRings+1) then
    SetLength( CRings, NumRings+1 );

  NumLines := CRings[NumRings].RLInd;

  if Length(LinesInds) > NumLines then
    SetLength( LinesInds, NumLines );

end; // procedure TN_UContours.CompactSelf

//*********************************************** TN_UContours.UnSparseSelf ***
// Remove Empty Items and set needed length for all Self arrays
//
procedure TN_UContours.UnSparseSelf();
begin
  CompactSelf;
//!! not yet
end; // procedure TN_UContours.UnSparseSelf

//********************************************* TN_UContours.GetSizeInBytes ***
// Get Self Size in Bytes
//
function TN_UContours.GetSizeInBytes(): integer;
begin
  Result := inherited GetSizeInBytes() + Length(CRings)*Sizeof(CRings[0]) +
                                   Length(LinesInds)*Sizeof(LinesInds[0]) + 2*8;
end; // end_of function TN_UContours.GetSizeInBytes

//************************************************ TN_UContours.GetSelfInfo ***
// create Text Info strings about self
// Mode - what Info is needed:
//
procedure TN_UContours.GetSelfInfo( SL: TStrings; Mode: integer );
var
  i, j, NumRings, MaxRingLevel, RingLevel: integer;
  NumLevel0Rings, NumLevel1Rings, NumLevel2Rings, NumLevelGE3Rings: integer;
  DCoords: TN_DPArray;
begin
  DCoords := nil; // to avoid warning
  inherited;
  N_LineInfo.Clear;
  if WNumItems = 0 then N_LineInfo.MinNumPoints := 0;
  WEnvRect.Left := N_NotAFloat;
  CalcEnvRects();
  MaxRingLevel   := 0;
  NumLevel0Rings := 0;
  NumLevel1Rings := 0;
  NumLevel2Rings := 0;
  NumLevelGE3Rings := 0;

  with N_LineInfo do
  begin

  for i := 0 to WNumItems-1 do
  begin
    NumRings := Items[i+1].CFInd - Items[i].CFInd;
    if NumRings = 0 then Continue; // skip empty items
    Inc(SumItems);
    if NumRings > 1 then
    begin
      Inc(SumMPItems);
      AvrNumParts := (AvrNumParts*(SumMPItems-1) + NumRings)/SumMPItems;
    end;
    if (MaxNumParts < NumRings) then MaxNumParts := NumRings;

    for j := 0 to NumRings-1 do
    begin
      if CRings[j].RDCoords <> nil then CollectInfo( CRings[j].RDCoords )
      else
      begin
        N_FcoordsToDCoords( CRings[j].RFCoords, DCoords );
        CollectInfo( DCoords );
      end;

      RingLevel := CRings[j].RFlags and $FF;
      if (MaxRingLevel < RingLevel) then MaxRingLevel := RingLevel;
      case RingLevel of
        0: Inc(NumLevel0Rings);
        1: Inc(NumLevel1Rings);
        2: Inc(NumLevel2Rings);
      else
        Inc(NumLevelGE3Rings);
      end; // case RingLevel of
    end; // for j := 0 to NumRings-1 do

  end; // for i := 0 to WNumItems-1 do

  ConvToStrings( SL, 0 );
  SL.Add( '' );
  SL.Add( Format( '              Max Ring Level: %d', [MaxRingLevel] ));
  SL.Add( Format( '     Number of Level 0 Rings: %d', [NumLevel0Rings] ));
  SL.Add( Format( '     Number of Level 1 Rings: %d', [NumLevel1Rings] ));
  SL.Add( Format( '     Number of Level 2 Rings: %d', [NumLevel2Rings] ));
  SL.Add( Format( '   Number of Level >=3 Rings: %d', [NumLevelGE3Rings] ));
  end; // with N_LineInfo do
end; // procedure TN_UContours.GetSelfInfo

//******************************************** TN_UContours.CalcItemEnvRect ***
// Calc EnvRect for given Item
//
procedure TN_UContours.CalcItemEnvRect( ItemInd: integer );
var
  i, FirstInd, NumInds, FLineInd, NumLines: integer;
  ULines: TN_ULines;
begin
  Items[ItemInd].EnvRect.Left := N_NotAFloat;
  ULines := GetSelfULines();
  GetItemInds( ItemInd, FirstInd, NumInds );

  for i := FirstInd to FirstInd+NumInds-1 do
  begin
    FLineInd := CRings[i].RLInd;
    NumLines := CRings[i+1].RLInd - FLineInd;

    if ULines.WLCType = N_FloatCoords then
    begin
      N_MakeRingCoords( ULines, LinesInds, FLineInd, NumLines, CRings[i].RFCoords );
      CRings[i].REnvRect := N_CalcLineEnvRect( CRings[i].RFCoords, 0,
                                                Length(CRings[i].RFCoords) );
    end else // double coords lines
    begin
      N_MakeRingCoords( ULines, LinesInds, FLineInd, NumLines, CRings[i].RDCoords );
      CRings[i].REnvRect := N_CalcLineEnvRect( CRings[i].RDCoords, 0,
                                                Length(CRings[i].RDCoords) );
    end;

    N_FRectOR( Items[ItemInd].EnvRect, CRings[i].REnvRect );
  end; // for i := FirstInd to FirstInd+NumInds-1 do
end; // end_of procedure TN_UContours.CalcItemEnvRect

//************************************************** TN_UContours.InitItems ***
// set WNumItems = 0 and set initial array sizes by given values
//
// ANumItems - initial Items size
// ANumRings - initial CRings size
// ANumLines - initial LinesInds size
//
procedure TN_UContours.InitItems( ANumItems, ANumRings, ANumLines: integer );
begin
  Inherited InitItems( ANumItems );

  if ANumRings < 0 then ANumRings := 0; // a precaution

  if Length(CRings) < (ANumRings+1)  then
  begin
    CRings := nil;
    SetLength( CRings, (ANumRings+1) );
  end;

  with CRings[0] do // fill last "dummy" Ring
  begin
    REnvRect := N_NotAFRect; // a precaution, not really needed
    RFlags := 0;             // a precaution, not really needed
    RLInd  := 0;             // the only field that is needed
    RFCoords := nil;         // a precaution, not really needed
    RDCoords := nil;         // a precaution, not really needed
  end;

  if ANumLines < 0 then ANumLines := 0; // a precaution

  if Length(LinesInds) < ANumLines  then
  begin
    LinesInds := nil;
    SetLength( LinesInds, ANumLines );
  end;
end; // end_of procedure TN_UContours.InitItems

//********************************************* TN_UContours.ConvSelfCoords ***
// Convert Self Coords using given AFunc with PParams
//
procedure TN_UContours.ConvSelfCoords( AFunc: TN_ConvDPFuncObj; APAuxPar: Pointer );
begin
  Assert( False, 'Cannot convert CObjRefs!' );
end; // end_of procedure TN_UContours.ConvSelfCoords

//********************************************* TN_UContours.AffConvSelf(4) ***
// Affine Convert Self by given AffCoefs4 Coefs
//
procedure TN_UContours.AffConvSelf( AAffCoefs: TN_AffCoefs4 );
begin
  Assert( False, 'Cannot convert UContours!' );
end; // end_of procedure TN_UContours.AffConvSelf(4)

//********************************************* TN_UContours.AffConvSelf(6) ***
// Affine Convert Self by given AffCoefs6 Coefs
//
procedure TN_UContours.AffConvSelf( AAffCoefs: TN_AffCoefs6 );
begin
  Assert( False, 'Cannot convert UContours!' );
end; // end_of procedure TN_UContours.AffConvSelf(6)

//********************************************* TN_UContours.AffConvSelf(8) ***
// Affine Convert Self by given AffCoefs8 Coefs
//
procedure TN_UContours.AffConvSelf( AAffCoefs: TN_AffCoefs8 );
begin
  Assert( False, 'Cannot convert UContours!' );
end; // end_of procedure TN_UContours.AffConvSelf(8)

//************************************************ TN_UContours.GeoProjSelf ***
// Convert Self by given GeoProj Params
//
procedure TN_UContours.GeoProjSelf( var AGeoProjPar: TN_GeoProjPar; AConvMode: integer );
begin
  Assert( False, 'Cannot convert UContours!' );
end; // end_of procedure TN_UContours.GeoProjSelf

{
//************************************** TN_UContours.AffConv ***
// Affine Convert given SrcCObjLayer to self by given Coefs
//
procedure TN_UContours.AffConv( SrcCObjLayer: TN_UCObjLayer; AAffCoefs: TN_AffCoefs4 );
begin
  Assert( False, 'Cannot convert UContours!' );
end; // end_of procedure TN_UContours.AffConv
}

//***************************************** TN_UContours.ClearCoordsOKFlags ***
// Clear all "Coords are OK" Flags.
// Should be called after Self ULines Coords changing or
//   changing any Self CRings Fields
//
procedure TN_UContours.ClearCoordsOKFlags();
begin
  WEnvRect.Left := N_NotAFloat;

  if Length(CRings) >= 1 then
    with CRings[0] do
    begin
      RFCoords := nil;
      RDCoords := nil;
    end;
end; // end_of procedure TN_UContours.ClearCoordsOKFlags

//********************************************** TN_UContours.SetSelfULines ***
// Set Self ULines with border coords
//
procedure TN_UContours.SetSelfULines( AULines: TN_ULines );
begin
  PutDirChildV( N_CObjLinesChildInd, AULines );
  ClearCoordsOKFlags();
end; // end_of procedure TN_UContours.SetSelfULines

//********************************************** TN_UContours.GetSelfULines ***
// Return Self ULines with border coords
//
function TN_UContours.GetSelfULines(): TN_ULines;
begin
  Result := TN_ULines( DirChild( N_CObjLinesChildInd ) );
end; // end_of procedure TN_UContours.SetSelfULines

//************************************************** TN_UContours.AddUCItem ***
// Add to Self given Item of given InpUConts and return its Self ItemIndex
// Result = -1 means, that Item was not added
// (Empty input Item or not same ULines)
//
function TN_UContours.AddUCItem( InpUConts: TN_UContours; InpItemInd: integer ): integer;
var
  i, Delta, NumLines, NumRings, InpFRingInd, InpFLineInd: integer;
  SelfFRingInd, SelfItemInd, SelfFLineInd: integer;
  InpULines: TN_ULines;
begin
  InpULines := InpUConts.GetSelfULines();

  if (WNumItems = 0) and (GetSelfULines() = nil) then
    SetSelfULines( InpULines );

  Result := -1;
  if GetSelfULines() <> InpULines then Exit; // Not same ULines

  InpUConts.GetItemInds( InpItemInd, InpFRingInd, NumRings );
  if NumRings = 0 then Exit; // Empty InpItem

  InpFLineInd := InpUConts.CRings[InpFRingInd].RLInd;
  NumLines    := InpUConts.CRings[InpFRingInd+NumRings].RLInd - InpFLineInd;

  SelfItemInd  := Self.AddItemsSys();
  SelfFRingInd := Items[SelfItemInd].CFInd;

  if SelfFRingInd+NumRings < Length(CRings) then
    SetLength( CRings, N_NewLength(SelfFRingInd+NumRings) );

  if SelfFRingInd = 0 then SelfFLineInd := 0
                      else SelfFLineInd := CRings[SelfFRingInd].RLInd;

  if SelfFLineInd+NumLines < Length(LinesInds) then
    SetLength( LinesInds, N_NewLength(SelfFLineInd+NumLines) );

  for i := 0 to NumLines-1 do // copy Lines Inds for all Rings
    LinesInds[SelfFLineInd+i] := InpUConts.LinesInds[InpFLineInd+i];

  Delta := SelfFLineInd - InpFLineInd;
  for i := 0 to NumRings-1 do // copy Rings
  begin
    CRings[SelfFRingInd+i] := InpUConts.CRings[InpFRingInd+i];
    Inc( CRings[SelfFRingInd+i].RLInd, Delta ); // correct Line Ind
  end; // for i := 0 to NumRings-1 do // copy Rings

  SetItemAllCodes( SelfItemInd, InpUConts, InpItemInd );
  CalcItemEnvRect( SelfItemInd );
  WEnvRect.Left := N_NotAFloat; // set "WEnvRect not OK" flag

  Result := SelfItemInd;
end; // end_of procedure TN_UContours.AddUCItem

//************************************** TN_UContours.MakeRingsCoords ***
// Calc Rings Coords (RF(D)Coords) if they are not already calculated
//
procedure TN_UContours.MakeRingsCoords();
var
  i, j, FRingInd, LRingInd, FLineInd, NumLines: integer;
  ULines: TN_ULines;
begin
  ULines := GetSelfULines();
  if ULines.WNumItems = 0 then
  begin
    WEnvRect.Left := N_NotAFloat;
    Exit; // lines are not created yet
  end;

  if WEnvRect.Left = N_NotAFloat then CalcEnvRects();

  if WNumItems = 0 then Exit;
  with CRings[0] do
    if (RFCoords <> nil) or (RDCoords <> nil) then Exit; // already OK

  if ULines.WLCType = N_FloatCoords then
    Self.WLCType := N_FloatCoords
  else
    Self.WLCType := N_DoubleCoords;

  for i := 0 to WNumItems-1 do
  begin
    FRingInd := Items[i].CFInd;       // FirstRing Index
    LRingInd := Items[i+1].CFInd - 1; // LastRing Index

    for j := FRingInd to LRingInd do
    begin
      FLineInd := CRings[j].RLInd;
      NumLines := CRings[j+1].RLInd - FLineInd;

      if ULines.WLCType = N_FloatCoords then
        N_MakeRingCoords( ULines, LinesInds, FLineInd, NumLines, CRings[j].RFCoords )
      else // double lines
        N_MakeRingCoords( ULines, LinesInds, FLineInd, NumLines, CRings[j].RDCoords );
    end;

  end;
end; // end_of procedure TN_UContours.MakeRingsCoords

//******************************************* TN_UContours.DPointInsideItem ***
// check, if given DPoint is inside of given Item of self:
// - return 0 if given DPoint is stricly inside self
// - return 1 if Dpoint is on the any Ring border (with N_Eps*Max(RingEnv) accuracy),
// - return 2 if DPoint is stricly outside of self
//
// RingRelInd - minimal Ring Relative Index in which DPoint is inside
//              (for single Ring contours RingRelInd=0)
//
function  TN_UContours.DPointInsideItem( ItemInd: integer; DPoint: TDPoint;
                           PInfo: TN_PPointInContInfo = nil ): TN_PointPosType;
var
  i, Pos, MaxNeededLevel, FoundLevel, FRingInd, NumRings: integer;
  RingRelInd, RLevel: integer;
  Label SetPInfo;
begin
  Result := pptOutside; // as if stricly outside, PInfo is not defined
  RingRelInd := -1;
  RLevel := -1; // to avoid warning

  // EnvRects should be OK!
  //  CalcEnvRects(); // calc RCoords and all EnvRects if needed

  if 0 <> N_PointInRect( DPoint, Items[ItemInd].EnvRect ) then
    Exit; // DPoint is stricly outside

  MaxNeededLevel := 0; // consider all levels
  FoundLevel := -1;    // "not found" value

  GetItemInds( ItemInd, FRingInd, NumRings );
  for i := FRingInd to FRingInd+NumRings-1 do with CRings[i] do
  begin
    RLevel := RFlags and $FF;
    if RLevel > MaxNeededLevel then Continue;

    if (RLevel <= FoundLevel)  and
       ((FoundLevel and $01) = 0) then
    begin
      Result := pptInside; // DPoint is stricly inside self
      goto SetPInfo;
    end;

    MaxNeededLevel := RLevel;
    if RFCoords <> nil then
      Pos := N_DPointInsideFRing( @RFCoords[0], Length(RFCoords), REnvRect, DPoint )
    else
      Pos := N_DPointInsideDRing( @RDCoords[0], Length(RDCoords), REnvRect, DPoint );

//    if Pos <= 1 then
//      N_IAdd( Format( '  ri=%d, [0].X=%.3f', [i,RDCoords[0].X] ));

    if Pos = 1 then
    begin
      RingRelInd := i - FRingInd;
      Result := pptOnBorder; // DPoint is on the Ring border
      goto SetPInfo;
    end;

    if Pos = 2 then Continue;

    //***** Here: DPoint is stricly inside current (i-th) Ring ( CRings[i] )

    RingRelInd := i - FRingInd;
    FoundLevel := RLevel;
    Inc(MaxNeededLevel);
  end; // for i := FRingInd to FRingInd+NumRings-1 do with CRings[i] do

  if (FoundLevel and $01) = 0 then Result := pptInside; // DPoint is stricly inside self

  SetPInfo: //************************************

  with PInfo^ do
  begin
  if Result = pptInside then // DPoint is stricly inside RingRelInd Ring
  begin
    RingInd := RingRelInd; // Ring Relative Index
    RingLevel := RLevel;   // Ring Level (>= 0)
  end else if Result = pptOnBorder then // DPoint is on the Ring Border
  begin
    RingInd := RingRelInd; // Ring Relative Index
    RingLevel := RLevel;   // Ring Level (>= 0)
    BLines := TN_ULines(DirChild(0)); // ULines CObj with UContour borders

         //******* NOT YET!!!

    BLineInd := 123;     // Line Index (in BorderLines)
    BLineSegmInd := 123; // Border Line Segment Index (in BorderLine)
  end;
  end; // with PInfo^ do
end; // end of function TN_UContours.DPointInsideItem


//********** TN_UDBaseLib class methods  **************

//********************************************** TN_UDBaseLib.Create ***
//
constructor TN_UDBaseLib.Create;
begin
  inherited Create;
  ClassFlags := N_UDBaseLibCI;
  ImgInd := 39;
end; // end_of constructor TN_UDBaseLib.Create

//********************************************* TN_UDBaseLib.Destroy ***
//
destructor TN_UDBaseLib.Destroy;
begin
  Items := nil;
  LIData := nil;
  inherited Destroy;
end; // end_of destructor TN_UDBaseLib.Destroy

//***************************************** TN_UDBaseLib.AddFieldsToSBuf ***
// save self to Serial Buf
//
procedure TN_UDBaseLib.AddFieldsToSBuf( SBuf: TN_SerialBuf );
var
  i: integer;
begin
  Inherited;
  SBuf.AddRowString( LIComment );
  SBuf.AddRowInt( Ord(LIType) );
  SBuf.AddRowInt( LINumItems );
  SBuf.AddRowBytes( LINumItems*SizeOf(Items[0]), @Items[0] );
  for i := 0 to LINumItems-1 do
    SBuf.AddRowString( Items[i].LIName );
  SBuf.AddByteArray( LIData );
end; // end_of procedure TN_UDBaseLib.AddFieldsToSBuf

//**************************************** TN_UDBaseLib.GetFieldsFromSBuf ***
// load self from Serial Buf
//
procedure TN_UDBaseLib.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
var
  i, IntType: integer;
begin
  Inherited;
  SBuf.GetRowString( LIComment );
  SBuf.GetRowInt( IntType );
  LIType := TN_LibItemType(IntType);
  SBuf.GetRowInt( LINumItems );
  SetLength( Items, LINumItems );
  SBuf.GetRowBytes( LINumItems*SizeOf(Items[0]), @Items[0] );
  for i := 0 to LINumItems-1 do
    SBuf.GetRowString( Items[i].LIName );

  SBuf.GetByteArray( LIData );
end; // end_of procedure TN_UDBaseLib.GetFieldsFromSBuf

//*************************************** TN_UDBaseLib.SaveToStrings ***
// save self to TStrings obj
//
procedure TN_UDBaseLib.SaveToStrings( Strings: TStrings; Mode: integer );
begin
  inherited;
  Strings.Add( Format( ' %d %d %s', [Length(Items), integer(LIType), LIComment] ) );
end; // end_of procedure TN_UDBaseLib.SaveToStrings

//************************************** TN_UDBaseLib.AddFieldsToText ***
// save self to Serial Text Buf
//
function TN_UDBaseLib.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ): Boolean;
var
  i, IntType: integer;
begin
  inherited AddFieldsToText( SBuf, AShowFlags );
  if LIComment <> '' then SBuf.AddTagAttr( 'Comment', LIComment, K_isString );
  IntType := Ord(LIType);
  SBuf.AddTagAttr( 'Type', IntType,  K_isInteger );
  SBuf.AddTagAttr( 'NumItems', LINumItems, K_isInteger );
  if LINumItems = 0 then
  begin
    SBuf.AddToken( N_EndOfArray, K_ttString );
    SBuf.AddEOL();
  end else
  begin
    for i := 0 to LINumItems-1 do
    with Items[i] do
    begin
      SBuf.AddToken( Format( '%.3d %d', [i, LICode]), K_ttString );
      SBuf.AddToken( LIName, K_ttString );
      SBuf.AddEOL();
      SBuf.AddToken( Format( '%d ', [NumBytes] ), K_ttString );
      SBuf.AddRowScalars( LIData[FirstByte], NumBytes, Sizeof(Byte), K_isUInt1 );
      SBuf.AddEOL();
    end; // for i := 0 to High(Items) do

    SBuf.AddToken( N_EndOfArray, K_ttString );
  end;
  SBuf.AddEOL();

  Result := True;
end; // end_of function TN_UDBaseLib.AddFieldsToText

//**************************************** TN_UDBaseLib.GetFieldsFromText ***
// load self from Serial Text Buf
//
function TN_UDBaseLib.GetFieldsFromText( SBuf: TK_SerialTextBuf ): Integer;
var
  IntType, FreeInd, FreeRefInd: integer;
  Str: string;
begin
  inherited GetFieldsFromText(SBuf);
  SBuf.GetTagAttr( 'Comment',  LIComment,  K_isString );
  SBuf.GetTagAttr( 'Type', IntType,  K_isInteger );
  LIType := TN_LibItemType(IntType);
  SBuf.GetTagAttr( 'NumItems', LINumItems, K_isInteger ); // prelimenary value!
  SetLength( Items, LINumItems );
  SetLength( LIData, LINumItems*100 ); // prelimenary value

  FreeInd := 0;
  FreeRefInd := 0;

  while True do
  begin
    SBuf.GetToken( Str ); // N_EndOfArray or Item Ind (should be skipped)
    if (Str = N_EndOfArray) then Break; // end of items

    if High(Items) < FreeInd then SetLength( Items, N_NewLength( FreeInd ));
    FillChar( Items[FreeInd], sizeof(Items[0]), 0 ); // clear whole item

    with Items[FreeInd] do
    begin
      SBuf.GetToken( Str );
      LICode := N_ScanInteger( Str );
      SBuf.GetToken( LIName );
      FirstByte := FreeRefInd;

      SBuf.GetToken( Str );
      NumBytes := StrToInt( Str );
      Inc( FreeRefInd, NumBytes );
      if Length(LIData) < FreeRefInd then
        Setlength( LIData, N_NewLength( FreeRefInd ) );
      SBuf.GetRowScalars( LIData[FirstByte], NumBytes, Sizeof(byte), K_isUInt1 );
    end;
    Inc(FreeInd);
  end; // while True do
  LINumItems := FreeInd;
  Setlength( Items, LINumItems );
  Setlength( LIData, FreeRefInd );

  Result := 0;
end; // end_of function TN_UDBaseLib.GetFieldsFromText

//************************************** TN_UDBaseLib.CopyFields ***
// copy to self given TN_UDBaseLib object
//
procedure TN_UDBaseLib.CopyFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution
  inherited;
  LIComment  := TN_UDBaseLib(SrcObj).LIComment;
  LINumItems := TN_UDBaseLib(SrcObj).LINumItems;
  LIType     := TN_UDBaseLib(SrcObj).LIType;
  Items  := Copy( TN_UDBaseLib(SrcObj).Items );
  LIData := Copy( TN_UDBaseLib(SrcObj).LIData );
end; // end_of procedure TN_UDBaseLib.CopyFields

//************************************** TN_UDBaseLib.SameFields ***
// returns True if all self.fields are the same as given SrcObj.fields
// (SrcObj must be of the same class as self)
//
function TN_UDBaseLib.SameFields( SrcObj: TN_UDBase; AFlags: integer ): boolean;
var
  i: integer;
  Label NotSame;
begin
  Result := Inherited SameFields( SrcObj, AFlags ); // prelimenary value
  if Result = False then Exit; // not same

  if (LIComment  <> TN_UDBaseLib(SrcObj).LIComment) or
     (LIType     <> TN_UDBaseLib(SrcObj).LIType) or
     (LINumItems <> TN_UDBaseLib(SrcObj).LINumItems) or
     (Length(LIData) <> Length(TN_UDBaseLib(SrcObj).LIData)) then goto NotSame;

  if not CompareMem( @LiData[0], @TN_UDBaseLib(SrcObj).LiData[0],
                                          Length(LIData) ) then goto NotSame;

  for i := 0 to LINumItems-1 do
  with Items[i] do
  begin
    if (LIName    <> TN_UDBaseLib(SrcObj).Items[i].LIName) or
       (LICode    <> TN_UDBaseLib(SrcObj).Items[i].LICode) or
       (FirstByte <> TN_UDBaseLib(SrcObj).Items[i].FirstByte) or
       (NumBytes  <> TN_UDBaseLib(SrcObj).Items[i].NumBytes) then goto NotSame;
  end;

  Exit; // Self and Src obj have same fields values

  NotSame: // Self and Src obj do NOT have same fields values
  Result := False;
end; // end_of procedure TN_UDBaseLib.SameFields

//************************************** TN_UDBaseLib.CompactSelf ***
// Just set needed length for Items and LIData arrays
//
procedure TN_UDBaseLib.CompactSelf();
var
  NeededSize: integer;
begin
  if Length(Items) > LINumItems then
    SetLength( Items, LINumItems );

  with Items[LINumItems-1] do
    NeededSize := FirstByte + NumBytes;
  if Length(LIData) > NeededSize then
    SetLength( LIData, NeededSize );
end; // procedure TN_UDBaseLib.CompactSelf

//************************************** TN_UDBaseLib.GetSizeInBytes ***
// Get Self Size in Bytes
//
function TN_UDBaseLib.GetSizeInBytes(): integer;
begin
  Result := InstanceSize +
            Length(Items)*Sizeof(Items[0]) +
            Length(LIData);
end; // end_of function TN_UDBaseLib.GetSizeInBytes


//**************************************** TN_UDBaseLib.GetItemInd(Code) ***
// Get Item Index by Item Code
//
function TN_UDBaseLib.GetItemInd( ACode: integer ): Integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to LINumItems-1 do
  begin
    if Items[i].LICode = ACode then
    begin
      Result := i;
      Exit;
    end;
  end;
end; // end_of function TN_UDBaseLib.GetItemInd(Code)

//**************************************** TN_UDBaseLib.GetItemInd(Name) ***
// Get Item Index by Item Name
//
function TN_UDBaseLib.GetItemInd( AName: string ): Integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to LINumItems-1 do
  begin
    if Items[i].LIName = AName then
    begin
      Result := i;
      Exit;
    end;
  end;
end; // end_of function TN_UDBaseLib.GetItemInd(Name)

//**************************************** TN_UDBaseLib.AddItem ***
// Add new (last) Item, return new Item Index (LINumItems-1)
//
function TN_UDBaseLib.AddItem( ACode: integer; AName: string;
                             AData: TN_BArray; ADataSize: integer ): Integer;
var
  FreeInd, NeededSize: integer;
begin
  Assert( (ADataSize >= 0) and (ADataSize <= Length(AData)), 'Bad ADataSize' );
  // set Items size
  if Length(Items) < (LINumItems+1) then
    SetLength( Items, N_NewLength(LINumItems+1) );

  // set LIData size
  with Items[LINumItems-1] do
    FreeInd := FirstByte + NumBytes;

  NeededSize := FreeInd + ADataSize;

  if Length(LIData) < NeededSize then
    SetLength( LIData, N_NewLength(NeededSize) );

  with Items[LINumItems] do // set new Item attributes
  begin
    LICode := ACode;
    LIName := AName;
    FirstByte := FreeInd;
    NumBytes  := ADataSize;
  end;

  move( AData[0], LIData[FreeInd], ADataSize ); // copy Item Data

  Result := LINumItems;
  Inc(LINumItems);
end; // end_of function TN_UDBaseLib.AddItem

//**************************************** TN_UDBaseLib.ReplaceItem ***
// Replace Item with given Index
//
procedure TN_UDBaseLib.ReplaceItem( AInd, ACode: integer; AName: string;
                                     AData: TN_BArray; ADataSize: integer );
var
  OldSize, NewSize: integer;
begin
  Assert( (AInd >= 0) and (AInd < LINumItems), 'Bad AInd' );
  Assert( (ADataSize >= 0) and (ADataSize <= Length(AData)), 'Bad ADataSize' );

  with Items[LINumItems-1] do
    OldSize := FirstByte + NumBytes;

  NewSize := OldSize + ADataSize - Items[AInd].NumBytes;

  if Length(LIData) < NewSize then
    SetLength( LIData, N_NewLength(NewSize) );

  //***** shift Data for Items from AInd+1 to LINumItems-1
  if ((AInd+1) <= (LINumItems-1)) and (NewSize <> OldSize) then
    with Items[AInd+1] do
      move( LIData[FirstByte],
            LIData[FirstByte+NewSize-OldSize], OldSize-FirstByte );

  //***** copy new Item Data
  with Items[AInd] do
  begin
    LICode := ACode;
    LIName := AName;
    NumBytes := ADataSize; // FirstByte remains the same
    move( AData[0], LIData[FirstByte], ADataSize );
  end;
end; // end_of procedure TN_UDBaseLib.ReplaceItem

//**************************************** TN_UDBaseLib.DeleteItem ***
// Delete Item with given Index
//
procedure TN_UDBaseLib.DeleteItem( AInd: integer );
var
  i, OldSize: integer;
begin
  Assert( (AInd >= 0) and (AInd < LINumItems), 'Bad AInd' );

  with Items[LINumItems-1] do
    OldSize := FirstByte + NumBytes;

  //***** shift Data for Items from AInd+1 to LINumItems-1
  if (AInd+1) <= (LINumItems-1) then
    with Items[AInd+1] do
      move( LIData[FirstByte],
            LIData[FirstByte-Items[AInd].NumBytes], OldSize-FirstByte );

  //***** shift Item attributes from AInd+1 to LINumItems-1
  for i := AInd to LINumItems-2 do
    Items[i] := Items[i+1];

  Items[LINumItems-1].LIName := '';
  Dec(LINumItems);
end; // end_of procedure TN_UDBaseLib.DeleteItem

//**************************************** TN_UDBaseLib.MoveItem ***
// Move Item with AOldInd index to ANewInd index
//
procedure TN_UDBaseLib.MoveItem( AOldInd, ANewInd: integer );
var
  i: integer;
  AOldData: TN_BArray;
  AOldItem: TN_LibItem;
begin
  Assert( (AOldInd >= 0) and (AOldInd < LINumItems), 'Bad AOldInd' );
  Assert( (ANewInd >= 0) and (ANewInd < LINumItems), 'Bad ANewInd' );

  if AOldInd = ANewInd then Exit; // nothing to do

  // save AOldInd Data
  AOldItem := Items[AOldInd];
  with AOldItem do
  begin
    SetLength( AOldData, NumBytes );
    move( LIData[FirstByte], AOldData[0], NumBytes );
  end;

  if AOldInd < ANewInd then
  begin
    //***** shift down Data for Items from AOldInd+1 to ANewInd
    with Items[AOldInd+1] do
      move( LIData[FirstByte],
            LIData[FirstByte - AOldItem.NumBytes],
            Items[ANewInd].FirstByte + Items[ANewInd].NumBytes - FirstByte );

    //***** shift Item attributes from AOldInd+1 to ANewInd
    for i := AOldInd to ANewInd-1 do
    begin
      Items[i] := Items[i+1];
      Dec( Items[i].FirstByte, AOldItem.NumBytes );
    end;

    // replace ANewInd item with AOldItem
    AOldItem.FirstByte := Items[ANewInd].FirstByte;
    Inc( AOldItem.FirstByte, Items[ANewInd].NumBytes - Items[AOldInd].NumBytes );
    Items[ANewInd] := AOldItem;

    with Items[ANewInd] do
      move( AOldData[0], LIData[FirstByte], NumBytes );

  end else // AOldInd > ANewInd
  begin
    //***** shift up Data for Items from ANewInd+1 to AOldInd
    with Items[ANewInd+1] do
      move( LIData[FirstByte],
            LIData[FirstByte + AOldItem.NumBytes],
            Items[AOldInd].FirstByte + Items[AOldInd].NumBytes - FirstByte );

    //***** shift Item attributes from ANewInd+1 to AOldInd
    for i := AOldInd downto ANewInd+1 do
    begin
      Items[i] := Items[i-1];
      Inc( Items[i].FirstByte, AOldItem.NumBytes );
    end;

    // replace ANewInd item with AOldItem
    AOldItem.FirstByte := Items[ANewInd].FirstByte;
    Items[ANewInd] := AOldItem;

    with Items[ANewInd] do
      move( AOldData[0], LIData[FirstByte], NumBytes );

  end;
end; // end_of procedure TN_UDBaseLib.MoveItem


//********** TN_UDOwnFont class methods  **************

//********************************************** TN_UDOwnFont.Create ***
//
constructor TN_UDOwnFont.Create;
begin
  inherited Create;
  ClassFlags := N_UDOwnFontCI;
  ImgInd := 39;
end; // constructor TN_UDOwnFont.Create

//********************************************* TN_UDOwnFont.Destroy ***
//
destructor TN_UDOwnFont.Destroy;
begin
  CharCodeRanges := nil;
  CharWidths := nil;
  inherited Destroy;
end; // destructor TN_UDOwnFont.Destroy

//***************************************** TN_UDOwnFont.AddFieldsToSBuf ***
// save self to Serial Buf
//
procedure TN_UDOwnFont.AddFieldsToSBuf( SBuf: TN_SerialBuf );
var
  NRanges: integer;
begin
  inherited;
  SBuf.AddRowString( FaceName );
  SBuf.AddRowInt( FontType );
  SBuf.AddRowInt( BreakChar );
  SBuf.AddRowInt( DefCharInd );
  SBuf.AddRowInt( CharHeight );
  SBuf.AddRowInt( CharMaxWidth );
  SBuf.AddRowInt( BaseLineOfs );
  NRanges := Length( CharCodeRanges );
  SBuf.AddRowInt( NRanges );
  SBuf.AddRowBytes( NRanges*SizeOf(CharCodeRanges[0]), @CharCodeRanges[0] );
  SBuf.AddIntegerArray( CharWidths );
end; // procedure TN_UDOwnFont.AddFieldsToSBuf

//**************************************** TN_UDOwnFont.GetFieldsFromSBuf ***
// load self from Serial Buf
//
procedure TN_UDOwnFont.GetFieldsFromSBuf( SBuf: TN_SerialBuf );
var
  NRanges: integer;
begin
  inherited;
  SBuf.GetRowString( FaceName );
  SBuf.GetRowInt( FontType );
  SBuf.GetRowInt( BreakChar );
  SBuf.GetRowInt( DefCharInd );
  SBuf.GetRowInt( CharHeight );
  SBuf.GetRowInt( CharMaxWidth );
  SBuf.GetRowInt( BaseLineOfs );
  SBuf.GetRowInt( NRanges );
  SetLength( CharCodeRanges, NRanges );
  SBuf.GetRowBytes( NRanges*SizeOf(CharCodeRanges[0]), @CharCodeRanges[0] );
  SBuf.GetIntegerArray( CharWidths );
end; // procedure TN_UDOwnFont.GetFieldsFromSBuf

//*************************************** TN_UDOwnFont.SaveToStrings ***
// save self to TStrings obj
//
procedure TN_UDOwnFont.SaveToStrings( Strings: TStrings; Mode: integer );
begin
  inherited;
  Strings.Add( Format( ' %d %d %s', [FontType, CharHeight, FaceName] ) );
end; // procedure TN_UDOwnFont.SaveToStrings

//***************************************** TN_UDOwnFont.AddFieldsToText ***
// save self to Serial Text Buf
//
function TN_UDOwnFont.AddFieldsToText( SBuf: TK_SerialTextBuf;
                                 AShowFlags : Boolean = true ): Boolean;
var
  NumRanges, i: integer;
begin
  inherited AddFieldsToText( SBuf, AShowFlags );
  SBuf.AddTagAttr( 'FaceName',     FaceName,      K_isString );
  SBuf.AddTagAttr( 'BreakChar',    BreakChar,     K_isInteger );
  SBuf.AddTagAttr( 'DefCharInd',   DefCharInd,    K_isInteger );
  SBuf.AddTagAttr( 'CharHeight',   CharHeight,    K_isInteger );
  SBuf.AddTagAttr( 'CharMaxWidth', BreakChar,     K_isInteger );
  SBuf.AddTagAttr( 'BaseLineOfs',  BaseLineOfs,   K_isInteger );
  NumRanges := Length(CharCodeRanges);
  SBuf.AddTagAttr( 'NumRanges',    NumRanges,     K_isInteger );
  SBuf.AddEOl( False );

  for i := 0 to NumRanges-1 do
  begin
    SBuf.AddScalar( CharCodeRanges[i].MinCode, K_isInteger );
    SBuf.AddScalar( CharCodeRanges[i].MaxCode, K_isInteger );
    SBuf.AddEOL( False );
  end; // for i := 0 to NumRanges-1 do

  SBuf.AddArray( CharWidths, K_isIntegerArray );

  Result := true;
end; // procedure TN_UDOwnFont.AddFieldsToText

//**************************************** TN_UDOwnFont.GetFieldsFromText ***
// load self from Serial Text Buf
//
function TN_UDOwnFont.GetFieldsFromText( SBuf: TK_SerialTextBuf ): Integer;
var
  i, NumRanges, NumChars: integer;
begin
  inherited GetFieldsFromText(SBuf);
  SBuf.GetTagAttr( 'FaceName',     FaceName,      K_isString );
  SBuf.GetTagAttr( 'BreakChar',    BreakChar,     K_isInteger );
  SBuf.GetTagAttr( 'DefCharInd',   DefCharInd,    K_isInteger );
  SBuf.GetTagAttr( 'CharHeight',   CharHeight,    K_isInteger );
  SBuf.GetTagAttr( 'CharMaxWidth', BreakChar,     K_isInteger );
  SBuf.GetTagAttr( 'BaseLineOfs',  BaseLineOfs,   K_isInteger );
  SBuf.GetTagAttr( 'NumRanges',    NumRanges,     K_isInteger );
  SetLength( CharCodeRanges, NumRanges );

  for i := 0 to NumRanges-1 do
  begin
    SBuf.GetScalar( CharCodeRanges[i].MinCode, K_isInteger );
    SBuf.GetScalar( CharCodeRanges[i].MaxCode, K_isInteger );
  end; // for i := 0 to NumRanges-1 do

  NumChars := 0;
  for i := 0 to High(CharCodeRanges) do
    with CharCodeRanges[i] do
    begin
      MinInd := NumChars; // restore MinInd
      NumChars := NumChars + MaxCode - MinCode + 1;
    end;

  SBuf.GetArray( CharWidths, K_isIntegerArray );

  Result := 0;
end; // procedure TN_UDOwnFont.GetFieldsFromText

//************************************** TN_UDOwnFont.CopyFields ***
// copy to self given TN_UDOwnFont object
//
procedure TN_UDOwnFont.CopyFields( SrcObj: TN_UDBase );
begin
  if SrcObj = nil then Exit; // a precaution
  inherited;
  FaceName     := TN_UDOwnFont(SrcObj).FaceName;
  FontType     := TN_UDOwnFont(SrcObj).FontType;
  BreakChar    := TN_UDOwnFont(SrcObj).BreakChar;
  DefCharInd   := TN_UDOwnFont(SrcObj).DefCharInd;
  CharHeight   := TN_UDOwnFont(SrcObj).CharHeight;
  CharMaxWidth := TN_UDOwnFont(SrcObj).CharMaxWidth;
  BaseLineOfs  := TN_UDOwnFont(SrcObj).BaseLineOfs;

  CharCodeRanges := Copy( TN_UDOwnFont(SrcObj).CharCodeRanges );
  CharWidths     := Copy( TN_UDOwnFont(SrcObj).CharWidths );
end; // procedure TN_UDOwnFont.CopyFields

//************************************** TN_UDOwnFont.SameFields ***
// returns True if all self.fields are the same as given SrcObj.fields
// (SrcObj must be of the same class as self)
//
function TN_UDOwnFont.SameFields( SrcObj: TN_UDBase; AFlags: integer ): boolean;
  Label NotSame;
begin
  Result := Inherited SameFields( SrcObj, AFlags ); // prelimenary value
  if Result = False then Exit; // not same

  if (FaceName     <> TN_UDOwnFont(SrcObj).FaceName) or
     (FontType     <> TN_UDOwnFont(SrcObj).FontType) or
     (BreakChar    <> TN_UDOwnFont(SrcObj).BreakChar) or
     (DefCharInd   <> TN_UDOwnFont(SrcObj).DefCharInd) or
     (CharHeight   <> TN_UDOwnFont(SrcObj).CharHeight) or
     (CharMaxWidth <> TN_UDOwnFont(SrcObj).CharMaxWidth) or
     (BaseLineOfs  <> TN_UDOwnFont(SrcObj).BaseLineOfs) then goto NotSame;

  if not CompareMem( @CharCodeRanges[0], @TN_UDOwnFont(SrcObj).CharCodeRanges[0],
           Length(CharCodeRanges)*Sizeof(CharCodeRanges[0]) ) then goto NotSame;
  if not CompareMem( @CharWidths[0], @TN_UDOwnFont(SrcObj).CharWidths[0],
           Length(CharWidths)*Sizeof(CharWidths[0]) ) then goto NotSame;
  Exit; // Self and Src obj have same fields values

  NotSame: // Self and Src obj do NOT have same fields values
  Result := False;
end; // end_of procedure TN_UDOwnFont.SameFields

//**************************************** TN_UDOwnFont.GetCharIndex ***
// get Char index (in Widths and CMOffsets array) by given CharCode
//
function TN_UDOwnFont.GetCharIndex( CharCode: integer ): Integer;
var
  i: integer;
begin
  for i := 0 to High(CharCodeRanges) do
  begin
    if (CharCode >= CharCodeRanges[i].MinCode) and
       (CharCode <= CharCodeRanges[i].MaxCode)   then // CharCode in i-th range
    begin
      Result := CharCode - CharCodeRanges[i].MinCode + CharCodeRanges[i].MinInd;
      Exit;
    end;
  end;
  Result := DefCharInd; // no such CharCode in font
end; // procedure TN_UDOwnFont.GetCharIndex

//************************************** TN_UDOwnFont.GetDefaultChar ***
// Return Default CharCode
//
function TN_UDOwnFont.GetDefaultChar(): Integer;
var
  i, MaxInd: integer;
begin
  Result := 0;
  for i := 0 to High(CharCodeRanges) do
  with CharCodeRanges[i] do
  begin
    MaxInd := MinInd + MaxCode - MinCode;

    if (DefCharInd < MinInd) or (DefCharInd > MaxInd) then Continue;//next Range

    Result := MinCode + DefCharInd - MinInd;
  end; // for, with
end; // procedure TN_UDOwnFont.GetDefaultChar


//****************** Global procedures **********************

//******************************************************* N_CreateCObjCopy ***
// Create and return a Copy of given CObj
//
function N_CreateCObjCopy( ASrcCObj: TN_UCObjLayer ): TN_UCObjLayer;
begin
  Result := TN_UCObjLayer(N_ClassRefArray[ASrcCObj.CI].Create());
  Result.CopyFields( ASrcCObj );
  N_ReplaceChildRefs1( ASrcCObj, Result ); // copy refs to CSS, and other CObjects
end; // function N_CreateCObjCopy

//********************************************************** N_PrepSameCObj ***
// Prepare (find or create) and return a Copy of given CObj
//
function N_PrepSameCObj( ASrcCObj: TN_UCObjLayer; ADstCobjParent: TN_UDBase; ADstCObjName: string ): TN_UCObjLayer;
var
  TmpUDBase: TN_UDBase;
begin
  Assert( ADstCobjParent <> nil, 'ADstCobjParent is not given!' );
   TmpUDBase := N_GetUObjByPath( ADstCobjParent, ADstCObjName );

  if TmpUDBase = nil then // Create New CObj
  begin
    Assert( ASrcCObj <> nil,       'ASrcCObj is not given!' );
    Result := N_CreateCObjCopy( ASrcCObj );
    Result.ObjName := ADstCObjName;
    ADstCobjParent.AddOneChildV( Result );
  end  else // TmpUDBase <> nil
  begin
    Assert( TmpUDBase is TN_UCObjLayer, ADstCObjName + ' is not TN_UCObjLayer!' );
    Result := TN_UCObjLayer( TmpUDBase );
    if ASrcCObj <> nil then // ASrcCObj may be nil, it means that it should not be used
    begin
      Result.CopyFields( ASrcCObj );
      Result.ObjName := ADstCObjName; // Result.CopyFields will change ObjName by ASrcCObj.ObjName
      N_ReplaceChildRefs1( ASrcCObj, Result ); // copy refs to CSS, and other CObjects
    end; // if ASrcCObj <> nil then
  end;
end; // function N_PrepSameCObj

//********************************************************* N_PrepEmptyCObj ***
// Prepare (find or create) and return empty CObj of given type
//
function N_PrepEmptyCObj( ACobjParent: TN_UDBase; ACObjName: string;
                        AClassInd, AAccuracy, ACType: integer; ACSName: string = '' ): TN_UCObjLayer;
var
  TmpUDBase: TN_UDBase;
begin
  TmpUDBase := ACobjParent.DirChildByObjName( ACObjName );

  if TmpUDBase = nil then // Create New CObj
  begin
    Result := TN_UCObjLayer(N_ClassRefArray[AClassInd].Create());
    Result.ObjName := ACObjName;
    ACobjParent.AddOneChildV( Result );
    Result.WAccuracy := AAccuracy;
    Result.WItemsCSName := ACSName;

    if AClassInd = N_ULinesCI then
      Result.WLCType := ACType;
  end else // Result <> nil, just check Type
  begin
    Result := nil; // to avoid warning
    Assert( TmpUDBase.CI = AClassInd, 'CObj has not needed type' );
  end;
end; // function N_PrepEmptyCObj

//********************************************************* N_SetPartsInfo ***
// Set Parts Info beginning from given AMemPtr
//
// AMemPtr    - pointer to beg of PartsInfo
// APartRInds - array of relative Parts Coords Indexes
// ANumParts  - Number of Parts in Item
// APointSize - Sizeof(TDPoint) or Sizeof(TFPoint)
// RFPInd     - Relative First Point Index (on output)
//
procedure N_SetPartsInfo( AMemPtr: TN_BytesPtr; APartRInds: TN_IArray;
                          ANumParts, APointSize: integer; out RFPInd: integer );
var
  i, IntType, ANumPoints: integer;
begin
  RFPInd := 0;
  if ANumParts <= 0 then Exit; // a precaution

  ANumPoints := APartRInds[ANumParts];

  if ANumPoints < ($FC - (ANumParts+2) div APointSize) then
  begin
    IntType := 1;
    AMemPtr^ := TN_Byte(IntType); Inc(AMemPtr);
    AMemPtr^ := TN_Byte(ANumParts); Inc(AMemPtr);
    RFPInd := (1+ANumParts+2) div APointSize + 1;

    for i := 0 to ANumParts do
    begin
      AMemPtr^ := TN_Byte( APartRInds[i] + RFPInd );
      Inc(AMemPtr);
    end;
  end
  else if ANumPoints < ($FFFC - ((ANumParts+2)*2) div APointSize) then
  begin
    IntType := 2;
    AMemPtr^ := TN_Byte(IntType); Inc(AMemPtr);
    TN_PUInt2(AMemPtr)^ := TN_UInt2(ANumParts);  Inc( AMemPtr, 2 );
    RFPInd := (1+(ANumParts+2)*2) div APointSize + 1;

    for i := 0 to ANumParts do
    begin
      TN_PUInt2(AMemPtr)^ := TN_UInt2( APartRInds[i] + RFPInd );
      Inc( AMemPtr, 2 );
    end;
  end
  else // Four byte format
  begin
    IntType := 4;
    AMemPtr^ := TN_Byte(IntType); Inc(AMemPtr);
    PInteger(AMemPtr)^ := ANumParts;  Inc( AMemPtr, 4 );
    RFPInd := (1+(ANumParts+2)*4) div APointSize + 1;

    for i := 0 to ANumParts do
    begin
      PInteger(AMemPtr)^ := APartRInds[i] + RFPInd;
      Inc( AMemPtr, 4 );
    end;
  end;

end; // end_of procedure N_SetPartsInfo

//************************************** N_ConvFLinesToDLines ***
// Convert FLines To DLines
//
procedure N_ConvFLinesToDLines( const FLines: TN_ULines; var DLines: TN_ULines );
var
  i, j, NParts, SrcFirstInd, NumInds: integer;
  MemPtr: TN_BytesPtr;
  DLItem: TN_ULinesItem;
  TmpDstCoords: TN_DPArray;
begin
  if DLines = nil then DLines := TN_ULInes.Create();
//  TN_UCObjLayer(DLines).CopyFields( FLines ); //does not work!
  DLines.CopyBaseFields( FLines );
  DLines.WLCType := N_DoubleCoords;
  DLItem := TN_ULinesItem.Create( N_DoubleCoords );
  DLines.InitItems( FLines.WNumItems, Length(FLines.LFCoords) );

  for i := 0 to FLines.WNumItems-1 do
  begin
    FLines.GetNumParts( i, MemPtr, NParts );
    if NParts = 0 then Continue;
    DLItem.Init();

    for j := 0 to NParts-1 do
    begin
      FLines.GetPartInds( MemPtr, j, SrcFirstInd, NumInds );
      N_FCoordsToDCoords( FLines.LFCoords, SrcFirstInd, TmpDstCoords, 0, NumInds );
      DLItem.AddPartCoords( TmpDstCoords, 0, NumInds );
    end;

//    DLItem.ICode := FLines.Items[i].CCode;
    DLines.ReplaceItemCoords( DLItem, -1, FLines, i );
  end;

//  DLines.RCXY := Copy( FLines.RCXY );
  DLItem.Free;
end; // end_of procedure N_ConvFLinesToDLines

//************************************** N_ConvDLinesToFLines ***
// Convert DLines To FLines
//
procedure N_ConvDLinesToFLines( const DLines: TN_ULines; var FLines: TN_ULines);
var
  i, j, NParts, SrcFirstInd, NumInds: integer;
  MemPtr: TN_BytesPtr;
  FLItem: TN_ULinesItem;
  TmpDstCoords: TN_FPArray;
begin
  if FLines = nil then FLines := TN_ULInes.Create1( N_FloatCoords );
  FLines.CopyBaseFields( DLines );
  FLItem := TN_ULinesItem.Create( N_FloatCoords );
  FLines.InitItems( DLines.WNumItems, Length(DLines.LDCoords) );

  for i := 0 to DLines.WNumItems-1 do
  begin
    DLines.GetNumParts( i, MemPtr, NParts );
    if NParts = 0 then Continue;
    FLItem.Init();

    for j := 0 to NParts-1 do
    begin
      DLines.GetPartInds( MemPtr, j, SrcFirstInd, NumInds );
      N_DCoordsToFCoords( DLines.LDCoords, SrcFirstInd, TmpDstCoords, 0, NumInds );
      FLItem.AddPartCoords( TmpDstCoords, 0, NumInds );
    end;

//    FLItem.ICode := DLines.Items[i].CCode;
    FLines.ReplaceItemCoords( FLItem, -1, DLines, i );
//    FLines.SetItemAllCodes( i, DLines, i );
  end;

//  FLines.RCXY := Copy( DLines.RCXY );
  FLItem.Free;
end; // end_of procedure N_ConvDLinesToFLines

//*********************************************** N_MakeRingCoords(float) ***
// make RingCoords from given list Line indexes
//
// AUFLines   - TN_UFLines CObj with Line Coords
// LinesInds  - Array with Line Indexes
// BegLineInd - Beg Line Index in LinesInds array (Ring's first fragment)
// NumLines   - Number of Lines in Ring
//
procedure N_MakeRingCoords( AULines: TN_ULines; LinesInds: TN_IArray;
                   BegLineInd, NumLines: integer; var RingCoords: TN_FPArray );
var
  i, DFlag, FPind, NumInds: integer;
  PLastPoint: TFPoint; // Prev line Last Point
  Coords1, Coords2: TN_FPArray;
begin
  Assert( NumLines >= 1, 'Bad Ring' ); // a precaution
  Assert( AULines.WLCType = N_FloatCoords, 'Bad Coords Type' ); // a precaution

  RingCoords := nil;
  Coords1 := nil; // to avoid warning
  Coords2 := nil; // to avoid warning

  with AULines do
  for i := BegLineInd to BegLineInd+NumLines-1 do
  begin
    GetItemInds( LinesInds[i], FPind, NumInds );
    Coords1 := Copy( LFCoords, FPind, NumInds );

    if i = BegLineInd then // first Line in Ring
    begin
      if NumLines <= 2 then
        DFlag := 0
      else // NumLines > 2
      begin
        GetItemInds( LinesInds[i+1], FPind, NumInds );
        Coords2 := Copy( LFCoords, FPind, NumInds );
        if ( (Coords2[0].X = Coords1[0].X) and
             (Coords2[0].Y = Coords1[0].Y) ) or
           ( (Coords2[High(Coords2)].X = Coords1[0].X) and
             (Coords2[High(Coords2)].Y = Coords1[0].Y) ) then
          DFlag := 1
        else
          DFlag := 0;
      end;
    end else //****************** not first Line
      if (Coords1[0].X <> PLastPoint.X) or
         (Coords1[0].Y <> PLastPoint.Y)  then DFlag := 1
                                         else DFlag := 0;
    if DFlag = 0 then
      PLastPoint := Coords1[High(Coords1)]
    else
      PLastPoint := Coords1[0];

    N_AddFcoordsToFCoords( RingCoords, Coords1, DFlag );
  end; // for i := BegLineInd to BegLineInd+NumLines-1 do
end; // end_of procedure N_MakeRingCoords(float)

//************************************************* N_MakeRingCoords(double) ***
// make RingCoords from given list Line indexes
//
// AULines    - TN_UDLines CObj with Line Coords
// LinesInds  - Array with Line Indexes
// BegLineInd - Beg Line Index in LinesInds array (Ring's first fragment)
// NumLines   - Number of Lines in Ring
//
procedure N_MakeRingCoords( AULines: TN_ULines; LinesInds: TN_IArray;
                   BegLineInd, NumLines: integer; var RingCoords: TN_DPArray );
var
  i, DFlag, FPind, NumInds: integer;
  PLastPoint: TDPoint; // Prev line Last Point
  Coords1, Coords2: TN_DPArray;
begin
  Assert( NumLines >= 1, 'Bad Ring' ); // a precaution
  Assert( AULines.WLCType = N_DoubleCoords, 'Bad Coords Type' ); // a precaution
  RingCoords := nil;
  Coords1 := nil; // to avoid warning
  Coords2 := nil; // to avoid warning
  N_s := AULines.ObjName;
  if NumLines = 3 then
    N_i := LinesInds[BegLineInd];

  with AULines do
  for i := BegLineInd to BegLineInd+NumLines-1 do
  begin
    GetItemInds( LinesInds[i], FPind, NumInds );
    Coords1 := Copy( LDCoords, FPind, NumInds );

    if i = BegLineInd then // first Line in Ring
    begin
      if NumLines <= 2 then
        DFlag := 0
      else // NumLines > 2
      begin
        GetItemInds( LinesInds[i+1], FPind, NumInds );
        Coords2 := Copy( LDCoords, FPind, NumInds );
        if ( (Coords2[0].X = Coords1[0].X) and
             (Coords2[0].Y = Coords1[0].Y) ) or
           ( (Coords2[High(Coords2)].X = Coords1[0].X) and
             (Coords2[High(Coords2)].Y = Coords1[0].Y) ) then
          DFlag := 1
        else
          DFlag := 0;
      end;
    end else //****************** not first Line
      if (Coords1[0].X <> PLastPoint.X) or
         (Coords1[0].Y <> PLastPoint.Y)  then DFlag := 1
                                         else DFlag := 0;
    if DFlag = 0 then
      PLastPoint := Coords1[High(Coords1)]
    else
      PLastPoint := Coords1[0];

    N_AddDcoordsToDCoords( RingCoords, Coords1, DFlag );
  end; // for i := BegLineInd to BegLineInd+NumLines-1 do
end; // end_of procedure N_MakeRingCoords(double)

{ see CObjLayer method
//**************************************************** N_AddCItem ***
// Add Item's index (not CFInd!) and CCode to SBuf
//
procedure N_AddCItem( SBuf: TK_SerialTextBuf; Items: TN_CItems;
                                                      Ind, NumParts: Integer );
var
  NumInds: integer;
begin
  NumInds := Items[Ind].CFInd and N_CFIndMask;
  NumInds := (Items[Ind+1].CFInd and N_CFIndMask) - NumInds;

  SBuf.AddToken( Format( '%.3d  %d  $%.2x  %d %d', [Ind, Items[Ind].CCode,
     (Items[Ind].CFInd shr N_CFIndShift), NumInds, NumParts] ), True );
  SBuf.AddEOL();
end; // end of procedure N_AddCItem

 see CObjLayer method:
//**************************************************** N_GetCItem ***
// check end of Items and Get from SBuf Items[FreeInd].CCode
// increase Itmes length if needed
// Return -1 if no more items
//
function N_GetCItem( SBuf: TK_SerialTextBuf; var Items: TN_CItems;
                                     var FreeInd, NumInds: Integer ): integer;
var
  CCSys, NumParts: integer;
  Str: string;
begin
  SBuf.GetToken( Str );
  if (Str = N_EndOfArray) then // end of items
  begin
    Result := -1;
    Exit;
  end;

  if High(Items) < (FreeInd+1) then
    SetLength( Items, N_NewLength( FreeInd+1 ));

  SBuf.GetScalar( Items[FreeInd].CCode, K_isInteger );
  SBuf.GetScalar( CCSys, K_isInteger );
  Items[FreeInd].CFInd := CCSys shl N_CFIndShift;
  Items[FreeInd].EnvRect.Left := N_NotAFloat;

  SBuf.GetScalar( NumInds, K_isInteger ); // used in UCObjRefs, UContours
  SBuf.GetScalar( NumParts, K_isInteger ); // not used while loading
  Inc(FreeInd);

  Result := 0;
end; // end of function N_GetCItem
}

//**************************************************** N_GetLineItem ***
// check end of Items and Get from SBuf CCode (used instead of N_GetCItem)
// (Items are not created an added)
//
function N_GetLineItem( SBuf: TK_SerialTextBuf; var AItemCode: Integer ): integer;
var
  CCSys, NumInds, NumParts: integer;
  Str: string;
begin
  SBuf.GetToken( Str );
  if (Str = N_EndOfArray) then // end of items
  begin
    Result := -1;
    Exit;
  end;

  N_ScanInteger( Str ); // skip Index
  SBuf.GetScalar( AItemCode, K_isInteger );
  SBuf.GetScalar( CCSys, K_isInteger );    // not used while loading
  SBuf.GetScalar( NumInds, K_isInteger );  // not used while loading
  SBuf.GetScalar( NumParts, K_isInteger ); // not used while loading

  Result := 0;
end; // end of function N_GetLineItem

//**************************************************** N_AddTestCObjects1 ***
// Add to given UALines some CObjects, created by N_AddTestCObjects2 procedure
//
procedure N_AddTestCObjects1( UALines: TN_ULines;
                                           var Params: TN_TestCObjectsA );
var
  i, j: integer;
  GapX, GapY, ObjX, ObjY: double;
begin
  with Params do
  begin
    GapX := (N_RectWidth(MainRect)*SubRectXCoef)  / (NSubRectX + SubRectXCoef);
    GapY := (N_RectHeight(MainRect)*SubRectYCoef) / (NSubRectY + SubRectYCoef);
    ObjX := (1.0 - SubRectXCoef)*GapX/SubRectXCoef;
    ObjY := (1.0 - SubRectYCoef)*GapY/SubRectYCoef;

    for i := 0 to NSubRectX-1 do // palce CObjects in MainRect
    for j := 0 to NSubRectY-1 do
    begin
      SubRect.Left   := MainRect.Left + GapX + (GapX + ObjX)*i;
      SubRect.Top    := MainRect.Top  + GapY + (GapY + ObjY)*j;
      SubRect.Right  := SubRect.Left + ObjX;
      SubRect.Bottom := SubRect.Top  + ObjY;

      N_AddTestCObjects2( UALines, Params );
    end;
    UALines.CompactSelf;
  end; // with UALines, Params do
end; // end of procedure N_AddTestCObjects1

//**************************************************** N_AddTestCObjects2 ***
// Add to given UALines some CObjects
//
procedure N_AddTestCObjects2( UALines: TN_ULines; Params: TN_TestCObjectsA );
var
  ItemInd, PartInd, NestLevel, NumRects: integer;
  MeandrCoef, MeandrPeriod, MeandrShift: double;
  RMinC, NRot, MinR, RectShift, dAlfa: double;
  TmpRect: TFRect;
  DC, DC2: TN_DPArray;
  LI: TN_ULinesItem;

  procedure CreateOneLevelRects( AFRect: TFRect; ALevel: integer ); // local
  var
    i, j: integer;
    C1, GapX, GapY, RectX, RectY: double;
    WrkFRect: TFRect;
  begin
      N_CalcFRectDCoords( DC, AFRect, 0 ); // main Rect
      LI.AddPartCoords( DC, 0, 5 );
//      Inc(PartInd); // not used
      if ALevel <= 0 then Exit; // all done
      C1 := Params.ShapeCoef1;
      GapX  := (N_RectWidth(AFRect)*C1)  / (NumRects + C1);
      GapY  := (N_RectHeight(AFRect)*C1) / (NumRects + C1);
      RectX := (1 - C1)*GapX/C1;
      RectY := (1 - C1)*GapY/C1;

      for i := 0 to NumRects-1 do // create nested Rects
      for j := 0 to NumRects-1 do
      begin
        with WrkFRect do
        begin
          Left   := AFRect.Left + GapX + (GapX + RectX)*i;
          Top    := AFRect.Top  + GapY + (GapY + RectY)*j;
          Right  := Left + RectX;
          Bottom := Top  + RectY;
        end;
        CreateOneLevelRects( WrkFRect, ALevel-1 );
      end;

  end; // local procedure CreateOneLevelRects

begin
  with Params, UALines do
  begin
  ItemInd := -1;
  PartInd := -1;
  case ShapeType of

  0: begin //***************************** Meandr as Line
    //***** ShapeElems - Number of Meandr periods
    N_CalcMeanderDCoords( DC, SubRect, ShapeElems, 0.5 );
    SetPartDCoords( ItemInd, PartInd, DC );
//    Items[ItemInd].CCode := ItemCode;
  end; // 0: begin // Meandr as Line

  1: begin //************* Meandr as Polygon (like snake)
    //***** ShapeElems - Number of Meandr periods
    //***** ShapeCoef1 - Meandr Shape (=0.5 - simmetrical Meandr)
    if (ShapeCoef1 <= 0) or (ShapeCoef1 >=1) then ShapeCoef1 := 0.5;
    MeandrPeriod := N_RectWidth( SubRect ) / ShapeElems;
    MeandrShift  := 0.5*ShapeCoef1*MeandrPeriod;
    MeandrCoef   := 0.5 + 0.5*ShapeCoef1;

    TmpRect := SubRect;
    N_CalcMeanderDCoords( DC, TmpRect, ShapeElems, MeandrCoef );
    TmpRect := N_RectShift( TmpRect, MeandrShift, MeandrShift );
    MeandrCoef := 0.5 - 0.5*ShapeCoef1;
    N_CalcMeanderDCoords( DC2, TmpRect, ShapeElems, MeandrCoef );
    N_AddDcoordsToDCoords( DC, DC2, 1 );
    N_AddDcoordsToDCoords( DC, Copy( DC, 0, 1), 1 ); // add Last Vertex

    SetPartDCoords( ItemInd, PartInd, DC );
//    Items[ItemInd].CCode := ItemCode;
  end; // 1: begin // Meandr as Polygon (like snake)

  2: begin //******* Meandr as Polygon (same as in 1) with one meandr hole
    //***** ShapeElems - Number of Meandr periods
    //***** ShapeCoef1 - Meandr Shape (=0.5 - simmetrical Meandr)
    if (ShapeCoef1 <= 0) or (ShapeCoef1 >=1) then ShapeCoef1 := 0.5;
    MeandrPeriod := N_RectWidth( SubRect ) / ShapeElems;
    MeandrShift  := 0.5*ShapeCoef1*MeandrPeriod;
    MeandrCoef   := 0.5 + 0.5*ShapeCoef1;

    //***** create Main Meandr
    TmpRect := SubRect;
    N_CalcMeanderDCoords( DC, TmpRect, ShapeElems, MeandrCoef );
    SetLength( DC, Length(DC)+1 );
    DC[High(DC)] := DPoint( TmpRect.Right+MeandrShift, TmpRect.Bottom );
    TmpRect := N_RectShift( TmpRect, MeandrShift, MeandrShift );
    MeandrCoef := 0.5 - 0.5*ShapeCoef1;
    N_CalcMeanderDCoords( DC2, TmpRect, ShapeElems, MeandrCoef );
    N_AddDcoordsToDCoords( DC, DC2, 1 );
    SetLength( DC, Length(DC)+2 );
    DC[High(DC)-1] := DPoint( TmpRect.Left-MeandrShift, TmpRect.Top );
    DC[High(DC)] := DC[0];
    SetPartDCoords( ItemInd, PartInd, DC );
    PartInd := -1;

    //***** create Hole Meandr
    MeandrShift := MeandrShift / 3;
    TmpRect := N_RectShift( TmpRect, -2*MeandrShift, -2*MeandrShift );
    MeandrCoef   := 0.5 + 0.5*ShapeCoef1/3;
    N_CalcMeanderDCoords( DC, TmpRect, ShapeElems, MeandrCoef );
    TmpRect := N_RectShift( TmpRect, MeandrShift, MeandrShift );
    MeandrCoef := 0.5 - 0.5*ShapeCoef1/3;
    N_CalcMeanderDCoords( DC2, TmpRect, ShapeElems, MeandrCoef );
    N_AddDcoordsToDCoords( DC, DC2, 1 );
    N_AddDcoordsToDCoords( DC, Copy( DC, 0, 1), 1 ); // add Last Vertex

    SetPartDCoords( ItemInd, PartInd, DC );
//    Items[ItemInd].CCode := ItemCode;
  end; // 2: begin // Meandr as Polygon (same as in 1) with one meandr hole

  3: begin //********************************* Spiral as Line
    //***** ShapeElems - Number of Points in Spiral
    //***** ShapeCoef1 - Number of Rotations
    RMinC := 0.3; // RMin = RMax * RMinC
    TmpRect := SubRect;
    N_CalcSpiralDCoords( DC, TmpRect, 0, ShapeCoef1*360, RMinC, ShapeElems );

    SetPartDCoords( ItemInd, PartInd, DC );
//    Items[ItemInd].CCode := ItemCode;
  end; // 3: begin // Spiral as Line

  4: begin // Spiral as as Polygon
    //***** ShapeElems - Number of Points in Spiral
    //***** ShapeCoef1 - Number of Rotations
    //***** ShapeCoef2 - Spiral Polygon Shape (0.1 - narrow, 0.9 - thick)
    if (ShapeCoef2 <= 0) or (ShapeCoef2 >=1) then ShapeCoef2 := 0.5;
    RMinC := 0.3; // RMin = RMax * RMinC
    TmpRect := SubRect;
    N_CalcSpiralDCoords( DC, TmpRect, 0, ShapeCoef1*360, RMinC, ShapeElems );

    NRot := Max( 1, ShapeCoef1 );
    MinR := 0.5*Min( N_RectWidth( TmpRect ), N_RectHeight( TmpRect ) );
    //***** Coef 0.95 is a precaution
    RectShift := 0.95*(1 - RMinC)*ShapeCoef2*MinR/NRot;
    with TmpRect do
      TmpRect := FRect( Left+RectShift,  Top+RectShift,
                        Right-RectShift, Bottom-RectShift );
    N_CalcSpiralDCoords( DC2, TmpRect, 0, ShapeCoef1*360, RMinC, ShapeElems );

    N_AddDcoordsToDCoords( DC, DC2, 1 );
    N_AddDcoordsToDCoords( DC, Copy( DC, 0, 1), 1 ); // add Last Vertex

    SetPartDCoords( ItemInd, PartInd, DC );
//    Items[ItemInd].CCode := ItemCode;
  end; // 4: begin // Spiral as as Polygon

  5: begin // Spiral as as Polygon (same as in 1) with one Spiral hole
    //***** ShapeElems - Number of Points in Spiral
    //***** ShapeCoef1 - Number of Rotations
    //***** ShapeCoef2 - Spiral Polygon Shape (0.1 - narrow, 0.9 - thick)
    if (ShapeCoef2 <= 0) or (ShapeCoef2 >=1) then ShapeCoef2 := 0.5;
    RMinC := 0.3; // RMin = RMax * RMinC
    TmpRect := SubRect;
    N_CalcSpiralDCoords( DC, TmpRect, 0, ShapeCoef1*360, RMinC, ShapeElems );

    NRot := Max( 1, ShapeCoef1 );
    MinR := 0.5*Min( N_RectWidth( SubRect ), N_RectHeight( SubRect ) );
    //***** Coef 0.95 is a precaution
    RectShift := 0.95*(1 - RMinC)*ShapeCoef2*MinR/NRot;
    with TmpRect do
      TmpRect := FRect( Left+RectShift,  Top+RectShift,
                        Right-RectShift, Bottom-RectShift );
    N_CalcSpiralDCoords( DC2, TmpRect, 0, ShapeCoef1*360, RMinC, ShapeElems );

    N_AddDcoordsToDCoords( DC, DC2, 1 );
    N_AddDcoordsToDCoords( DC, Copy( DC, 0, 1), 1 ); // add Last Vertex

    SetPartDCoords( ItemInd, PartInd, DC );
    PartInd := -1;

    RectShift := RectShift/3.0;
    dAlfa := (180/Pi)*RectShift / MinR;
    with TmpRect do
      TmpRect := FRect( Left-2*RectShift,  Top-2*RectShift,
                        Right+2*RectShift, Bottom+2*RectShift );

    N_CalcSpiralDCoords( DC, TmpRect, dAlfa, ShapeCoef1*360-dAlfa, RMinC, ShapeElems );
    with TmpRect do
      TmpRect := FRect( Left+RectShift,  Top+RectShift,
                        Right-RectShift, Bottom-RectShift );
    N_CalcSpiralDCoords( DC2, TmpRect, dAlfa, ShapeCoef1*360-dAlfa, RMinC, ShapeElems );

    N_AddDcoordsToDCoords( DC, DC2, 1 );
    N_AddDcoordsToDCoords( DC, Copy( DC, 0, 1), 1 ); // add Last Vertex

    SetPartDCoords( ItemInd, PartInd, DC );
  end; // 5: begin // Spiral as as Polygon (same as in 1) with one Spiral hole

  6: begin //************************* Rectangles with nested Holes
    //***** ShapeElems - Number of one level Rects in one dimension
    //                   (NumRectX = NumRectY, whole num. of Rects = ShapeElems**2)
    //***** ShapeCoef1 - Rectangles shape (0 - 1)
    //***** ShapeCoef2 - Number of Nested levels (integer, >= 0)
    if (ShapeCoef1 <= 0) or (ShapeCoef1 >=1) then ShapeCoef1 := 0.5;
    NumRects := ShapeElems;
    NestLevel := Max( 0, Round(ShapeCoef2) );
    if NestLevel > 11 then NestLevel := 2; // for NestLevel=10 - 100 MB is used!

    //***** using SetPartDCoords is not possible because of time consuming!
    LI := TN_ULinesItem.Create( WLCType );
    CreateOneLevelRects( SubRect, NestLevel );
    ItemInd := ReplaceItemCoords( LI, -1 );
    LI.Free;
  end; // 6: begin // Rectangles with nested Holes

  end; // case ShapeType of

  SetCCode( ItemInd, ItemCode );

  end; // with UALines, Params do
end; // end of procedure N_AddTestCObjects2

{
//********************************************************** N_SetCObjCodes ***
// Set given Codes for one Dimension in given ABArray
// (Encode given ACDimInd, ACode1, ACode2 into internal binary format)
//
// ABArray - Byte Array with resulting encoded codes
// AInd    - on input  - index of first resulting byte in ABArray,
//           on output - index of first free byte in ABArray
// ACDimInd        - given Dimension Index
// ACode1, ACode2 - two given Codes for given ACDimInd
//
procedure N_SetCObjCodes( var ABArray: TN_BArray; var AInd: integer;
                                            ACDimInd, ACode1, ACode2: integer );
begin
  Inc(ACode1); //***** in internal binary format all codes are incremented by 1
  Inc(ACode2); //                 to enable storing -1 in one byte

  if Length(ABArray) < (AInd+9) then
    SetLength( ABArray, AInd+9 ); // max needed size

  if (ACode1 = 0) and (ACode2 = 0) then // clear codes
  begin
    // nothing should be done
  end else if (ACode1 <= $FF) and (ACode2 <= $FF) then // one Byte format
  begin
    if ACode2 = 0 then // one code
    begin
      ABArray[AInd+0] := ACDimInd shl 3;
      ABArray[AInd+1] := Byte(ACode1);
      Inc( AInd, 2 );
    end else //********** two codes
    begin
      ABArray[AInd+0] := (ACDimInd shl 3) or 1;
      ABArray[AInd+1] := Byte(ACode1);
      ABArray[AInd+2] := Byte(ACode2);
      Inc( AInd, 3 );
    end;
  end else if (ACode1 <= $FFFF) and (ACode2 <= $FFFF) then // two bytes format
  begin
    if ACode2 = 0 then // one code
    begin
      ABArray[AInd+0] := (ACDimInd shl 3) or 2;
      TN_PUInt2(@ABArray[AInd+1])^ := TN_UInt2(ACode1);
      Inc( AInd, 3 );
    end else //********** two codes
    begin
      ABArray[AInd+0] := (ACDimInd shl 3) or 3;
      TN_PUInt2(@ABArray[AInd+1])^ := TN_UInt2(ACode1);
      TN_PUInt2(@ABArray[AInd+3])^ := TN_UInt2(ACode2);
      Inc( AInd, 5 );
    end;
  end else // four Bytes format
  begin
    if ACode2 = 0 then // one code
    begin
      ABArray[AInd+0] := (ACDimInd shl 3) or 6;
      PInteger(@ABArray[AInd+1])^ := ACode1;
      Inc( AInd, 5 );
    end else //********** two codes
    begin
      ABArray[AInd+0] := (ACDimInd shl 3) or 7;
      PInteger(@ABArray[AInd+1])^ := ACode1;
      PInteger(@ABArray[AInd+5])^ := ACode2;
      Inc( AInd, 9 );
    end;
  end;

end; // end of procedure N_SetCObjCodes

//********************************************************** N_GetCObjCodes ***
// Get Info about Codes for one Dimension and update APCodes and ANumBytes
// for next Dimension
//
// APCodes    - Pointer to all Codes to analize
// ANumBytes  - Number of all Codes Bytes (from APCodes)
// AOffset    - Offset (relative to APCodes) of one Dimension codes to analize
//              (on output - offset of next Dimension)
// ACDimInd    - Resulting Dimension Index (on output only)
// ACode1, ACode2 - Resulting Codes for ACDimInd (on output)
//
// On output, (AOffset = ANumBytes) or (ACDimInd = 256) means no more codes
//
procedure N_GetCObjCodes( APCodes: PByte; ANumBytes: integer;
                  var ABegInd: integer; out ACDimInd, ACode1, ACode2: integer );
var
  NumCodes, OneCodeSize: integer;
  FirstByte: Byte;
  CurPCodes: PByte;
begin
  ACDimInd := 256; // bigger then any possible ACDimInd value
  ACode1 := -1;
  ACode2 := -1;

  if ABegInd >= ANumBytes then Exit;

  CurPCodes := APCodes;
  Inc( CurPCodes, ABegInd );
  FirstByte := CurPCodes^;
  Inc( CurPCodes );

  NumCodes    := (FirstByte and $01) + 1;
  OneCodeSize := ((FirstByte shr 1) and $03) + 1;
  ACDimInd     := FirstByte shr 3;

  case OneCodeSize of

  1: begin // One byte Code
       ACode1 := CurPCodes^ - 1;
       Inc( CurPCodes );
       if NumCodes = 2 then
       begin
         ACode2 := CurPCodes^ - 1;
         Inc( CurPCodes );
       end;
     end; // 1: begin // One byte Code

  2: begin // Two bytes Code
       ACode1 := TN_PUInt2(CurPCodes)^ - 1;
       Inc( CurPCodes, 2 );
       if NumCodes = 2 then
       begin
         ACode2 := TN_PUInt2(CurPCodes)^ - 1;
         Inc( CurPCodes, 2 );
       end;
     end; // 2: begin // Two bytes Code

  4: begin // Four bytes Code
       ACode1 := PInteger(CurPCodes)^ - 1;
       Inc( CurPCodes, 4 );
       if NumCodes = 2 then
       begin
         ACode2 := PInteger(CurPCodes)^ - 1;
         Inc( CurPCodes, 4 );
       end;
     end; // 4: begin // Four bytes Code

  end; // case OneCodeSize of

  ABegInd := ULong(CurPCodes) - ULong(APCodes);
end; // end of procedure N_GetCObjCodes

//**************************************************** N_StringToCObjCodes ***
// Convert given CObjItem Codes from String into given BArray
//
procedure N_StringToCObjCodes( AStrCodes: string; var ABArray: TN_BArray;
                                                  out ANumBytes: integer );
var
  i, NumInts, CurInd: integer;
begin
  //***** Get in N_WrkIArray (CDimInd, Code1, Code2) triples
  NumInts := N_ScanIArray( AStrCodes, N_WrkIArray );
  CurInd := 0;
  i := 0;

  if NumInts = 0 then // special case for one code in Dim0
  begin
    ANumBytes := 0;
    if Length(ABArray) = 0 then SetLength( ABArray, 1 ); // to enable using @ABArray[0] pointer
    Exit;
  end; // if NumInts = 1 then // special case for one code in Dim0

  if NumInts = 1 then // special case for one code in Dim0
  begin
    N_SetCObjCodes( ABArray, CurInd, 0, N_WrkIArray[0], -1 );
    ANumBytes := CurInd;
    Exit;
  end; // if NumInts = 1 then // special case for one code in Dim0

  while True do // along (CDimInd, Code1, Code2) triples
  begin
    if i >= NumInts then Break; // end of Ints in N_WrkIArray

    N_SetCObjCodes( ABArray, CurInd, N_WrkIArray[i],
                                     N_WrkIArray[i+1], N_WrkIArray[i+2] );
    Inc( i, 3 ); // to next triple
  end; // while True do // along (CDimInd, Code1, Code2) triples

  ANumBytes := CurInd;

end; // end of procedure N_StringToCObjCodes
}

//***************************************************** N_EncodeCObjCodeInt ***
// Encode and return one CObj Integer by given ACDimInd and ACode
//
function N_EncodeCObjCodeInt( ACDimInd, ACode: integer ): integer;
begin
  Assert( (ACDimInd and $FFFFFFE0) = 0, 'Bad CDimInd!' );
  Assert( (ACode and $FF000000) = 0, 'Bad Code!' );

  Result := (ACDimInd shl 24) or (ACode and $FFFFFF);
end; // end of procedure N_GetCObjCodeInt

//***************************************************** N_DecodeCObjCodeInt ***
// Decode given CObj Integer (conv given CObj Code Integer to ACDimInd and ACode)
//
procedure N_DecodeCObjCodeInt( ACObjCodeInt: integer; out ACDimInd, ACode: integer );
begin
  ACDimInd := (ACObjCodeInt shr 24) and $01F;
  ACode    := ACObjCodeInt and $FFFFFF;
end; // end of procedure N_DecodeCObjCodeInt

//****************************************************** N_GetNextCObjCodes ***
// Get Info about CObj Codes for Next CDim
//
// APCodes     - Pointer to all Codes to analize (to All Codes of one CObj Item)
// ANumAllInts - Number of all integers (from APCodes)
// ABegInd     - Offset (relative to APCodes) of one CDim codes to analize
//               (on output - offset of next CDim codes)
// ACDimInd     - Resulting CDim Index, =256 if no more codes (on output)
// ANumDimInts - Number of Integers for one ACDimInd (on output)
//
procedure N_GetNextCObjCodes( APCodes: PInteger; ANumAllInts: integer;
                      var ABegInd: integer; out ACDimInd, ANumDimInts: integer );
var
  i, NumRestInts, CurCDimInd: integer;
  CurPCodes: PInteger;
begin
  ACDimInd  := 256; // bigger then any possible ACDimInd value
  ANumDimInts := 0;

  NumRestInts := ANumAllInts - ABegInd;
  if NumRestInts <= 0 then Exit;

  CurPCodes := APCodes;
  Inc( CurPCodes, ABegInd );
  ACDimInd := (CurPCodes^ shr 24) and $01F;
  ANumDimInts := 0;

  for i := 0 to NumRestInts-1 do // along all existing codes
  begin
    CurCDimInd := (CurPCodes^ shr 24) and $01F;
    if CurCDimInd <> ACDimInd then // no more codes for needed ACDimInd
    begin
      ANumDimInts := i;
      Inc( AbegInd, ANumDimInts );
      Exit;
    end;

    Inc( CurPCodes ); // to next code
  end; // for i := 0 to NumPairs-1 do // along all existing codes

  ANumDimInts := NumRestInts;
  Inc( AbegInd, ANumDimInts );
end; // end of procedure N_GetNextCObjCodes

//****************************************************** N_GetCDimCObjCodes ***
// Get Info about CObj Codes for one given ACDimInd
//
// APAllCodes   - Pointer to all Codes to analize (to All Codes of one CObj Item)
// ANumAllInts  - Number of all integers (from APCodes)
// ACDimInd     - given CDim Index (on input)
// ACDimOffset  - Offset in All Codes to given ACDimInd codes, -1 if not found (on output)
// ANumCDimInts - Number of Integers (Codes) for given ACDimInd (on output)
//
procedure N_GetCDimCObjCodes( APAllCodes: PInteger; ANumAllInts, ACDimInd: integer;
                                      out ACDimOffset, ANumCDimInts: integer );
var
  CurCDimInd, NextCDimOffset: integer;
begin
  ACDimOffset    := 0;
  NextCDimOffset := 0;

  while True do // along CDimInds in given Codes
  begin
    N_GetNextCObjCodes( APAllCodes, ANumAllInts, NextCDimOffset,
                                                 CurCDimInd, ANumCDimInts );
    if CurCDimInd = ACDimInd then Exit; // found, all done

    if (CurCDimInd > ACDimInd) or   // not found, return current offset
       (CurCDimInd = 256)     then  // no more codes
    begin
      ANumCDimInts := 0;
      Exit;
    end; // if CurCDimInd > ACDimInd then // not found, return current offset

    ACDimOffset := NextCDimOffset;
  end; // while True do // along CDimInds in given Codes

end; // end of procedure N_GetCDimCObjCodes

//***************************************************** N_CObjCodesToString ***
// Return given CObjItem Codes as Resulting String
//
function N_CObjCodesToString( APCodes: PInteger; ANumInts: integer ): string;
var
  i, Code, BegInd, CDimInd, NumCodes: integer;
  CurPCodes: PInteger;
begin
  Result := '';
  BegInd := 0;
  CurPCodes := APCodes;

  while True do // along existed Codes Dimensions
  begin

    N_GetNextCObjCodes( APCodes, ANumInts, BegInd, CDimInd, NumCodes );

    if CDimInd <> 256 then
    begin
      for i := 0 to NumCodes-1 do
      begin
        Code := CurPCodes^ and $FFFFFF;
        Result := Result + Format( '%d %d ', [CDimInd, Code] );
        Inc( CurPCodes );
      end;
    end else // CDimInd = 256, end of codes
      Exit;

  end; // while True do // along existed Codes Dimensions

end; // end of function N_CObjCodesToString

//***************************************************** N_StringToCObjCodes ***
// Convert given CObjItem Codes from String into given IArray
//
procedure N_StringToCObjCodes( AStrCodes: string; var AIArray: TN_IArray;
                                                  out ANumInts: integer );
var
  CDimInd, Code: integer;
begin
  ANumInts := 0;

  while True do // along all tokens in AStrCodes
  begin
    CDimInd := N_ScanInteger( AStrCodes ); // CDimInd

    if CDimInd = N_NotAnInteger then // no more codes
      Exit;

    if High(AIArray) < ANumInts then
      SetLength( AIArray, N_NewLength( ANumInts+1 ) );

    Code := N_ScanInteger( AStrCodes ); // Code

    if (Code = N_NotAnInteger) and (AnumInts = 0) then // code without CdimInd (old archives)
    begin
      if CDimInd = -1 then Break; // -1 means that code is not given
      Code := CDimInd;
      CDimInd := 0;
    end;
//    Assert( Code <> N_NotAnInteger, 'Bad Codes!' );

    AIArray[ANumInts] := N_EncodeCObjCodeInt( CDimInd, Code );
    Inc( ANumInts ); // to next Code
  end; // while True do // along all tokens in AStrCodes

end; // end of procedure N_StringToCObjCodes

//********************************************************* N_AddTagAttrDef ***
// Add Tag Attribute (Integer, Hex, Boolean or String) with checking it's default value
// (for K_IsString type default value should always be '' and ADefValue=0 !)
//
procedure N_AddTagAttrDef( ASTBuf: TK_SerialTextBuf; AttrName: string;
                     const AttrValue; AType: TK_ParamType; ADefValue: integer );
var
  GivenValue: integer;
begin
  GivenValue := 0;
  if (AType = K_IsInteger) or (AType = K_IsHex) then
    GivenValue := Integer(AttrValue)
  else if AType = K_IsBoolean then
  begin
    if Boolean(AttrValue) then
      GivenValue := 1;
  end else if AType = K_IsString then
  begin
    if String(AttrValue) <> '' then
      GivenValue := 1;
  end else
    Assert( False, 'Bad AType!' );

  if GivenValue = ADefValue then Exit; // skip adding default value

  ASTBuf.AddTagAttr( AttrName, AttrValue, AType );
end; //*** end of procedure N_AddTagAttrDef

//********************************************************* N_GetTagAttrDef ***
// Get Tag Attribute (Integer, Hex, Boolean or String) with checking it's default value
// (for K_IsString type default value should always be '' and ADefValue=0 !)
//
procedure N_GetTagAttrDef( ASTBuf: TK_SerialTextBuf; AttrName: string;
                     out AttrValue; AType : TK_ParamType; ADefValue : integer );
begin
  if not ASTBuf.GetTagAttr( AttrName, AttrValue, AType ) then // Attribute was not found
  begin

    if (AType = K_IsInteger) or (AType = K_IsHex) then
      Integer(AttrValue) := ADefValue
    else if AType = K_IsBoolean then
    begin
      if ADefValue = 0 then Boolean(AttrValue) := False
                       else Boolean(AttrValue) := True;
    end else if AType = K_IsString then
    begin
      String(AttrValue) := '';
    end else
      Assert( False, 'Bad AType!' );

  end; // if not ASTBuf.GetTagAttr( AttrName, AttrValue, AType ) then
end; //*** end of procedure N_GetTagAttrDef

{****************** Pattern Code: loop along items pattern
  MemPtr: TN_BytesPtr;
  i, j, NumParts, FPInd, NumInds: integer;

  for i := 0 to WNumItems-1 do
  begin
    GetNumParts( i, MemPtr, NumParts );
    if NumParts = 0 then Continue; // skip empty items

    for j := 0 to NumParts-1 do
    begin
      GetPartInds( MemPtr, j, FPInd, NumInds );
      Copy( CCoords, FirstInd, NumInds )
    end; // for j := 0 to NumParts-1 do

  end; // for i := 0 to WNumItems-1 do

  if WLCType = N_FloatCoords then
  begin
  end else
  begin
  end;

      if WLCType = N_FloatCoords then
      begin
      end else
      begin
      end;

  if WLCType = N_FloatCoords then
  else
}

end.
