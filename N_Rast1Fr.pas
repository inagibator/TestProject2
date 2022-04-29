unit N_Rast1Fr;
// Raster Frame - Frame with PaintBox for showing OCanv content and searching in it

// TN_ShowCoordsType = ( sctNotDef, sctPixelCoords, sctUserCoords,
// TN_HandlerType    = ( htNotDef, htMouseDown, htMouseMove, htMouseUp,

// TN_Rast1Frame     = class( TFrame )  // Base Frame for working with OCanv
// TN_SGBase         = class( TObject ) // Search Group Base class
// TN_RFrameAction   = class( TObject ) // abstract RFrame Action object

// TN_RFAClass       = class of TN_RFrameAction;
// TN_RFAClassRefs   = array [0..N_RFAClassRefsMaxInd] of TN_RFAClass;
// TN_RFAShowAction  = class( TN_RFrameAction ) // Show Cursor Coords or InfoStrings
// TN_RFAMouseAction = class( TN_RFrameAction ) // Show Cursor Color or Scroll Image
// TN_RFAZoom        = class( TN_RFrameAction ) // Zoom User Coords or Raster Scale
// TN_RFAGetUPoint   = class( TN_RFrameAction ) // Get Point Coords

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ActnList, Menus, ComCtrls, Contnrs, Types,
  K_Script1,
  N_Types, N_Gra2, N_Lib1, N_Gra0, N_Gra1, N_Gra3, N_UDat4,
  N_BaseF, N_CompBase, N_GCont;

type TN_HandlerType = ( htNotDef, htMouseDown, htMouseMove, htMouseUp,
                        htMouseWheel, htDblClick, htKeyDown, htKeyUp,
                        htOthers );

type TN_RFrResizeFlags = Set Of ( rfrfScaleIfWhole, rfrfScaleIfWholeXorY,
                                  rfrfKeepAspect,   rfrfBufEqFrame, rfrfTmp1 );
// if no Flags Set  - do not Scale Image while Resize
// rfrfScaleIfWhole - Scale Image if Whole Image is visible
// rfrfKeepAspect   - Keep Frame Aspect if Whole Image is visible
// rfrfBufEqFrame   - BufSize is always Equal to Frame Size

type TN_RFrDrawFlags = Set Of ( rfdfDrawCorners );
// rfdfDrawCorners - (only if RFPaddings <> 0) - Buf Corner rects should be copied to PaintBox

//type TN_VecorScaleFlags = Set Of ( vsfFPAtCenter, vsfShiftInCenter );
// Rast1Frame.VectorScale method control Flags:
// vsfFPAtCenter    - FixedPoint is at RFSrcPRect Center (otherwise at Cursor)
// vsfShiftInCenter - if FixedPoint is at Cursor, shift Image so that
//                      this point appeared at RFSrcPRect Center

type TN_RFZoomFlags = Set Of ( rfzfUseCursor, rfzfShiftInCenter, rfzfUpperleft );
// rfzfUpperleft     - Object Point is the UpperLeft corner of LogFrameRect and RFSrcPRect
// rfzfUseCursor     - Object Point is under current Cursor Coords, otherwise
//                     Object Point is in the Center of RFSrcPRect
// rfzfShiftInCenter - Object Point is under Cursor should be Shifted in the Center of RFSrcPRect

type TN_RFZoomMode = ( // used in SetZoomLevel
  rfzmUpperleft,  // Upper Left corner of visible Rect remains the same while zooming
  rfzmCenter,     // visible Rect Center remains the same while zooming
  rfzmCursor,     // Pixel under Cursor  remains the same while zooming
                  // (if Cursor is not inside visible Rect, rfzmCenter mode is used)
  rfzmCursorShift // Pixel under Cursor (before zoom) will be shifted (if possible)
                  // with Cursor in visible Rect Center (after zoom)
                  // (if Cursor is not inside visible Rect, rfzmCenter mode is used)
  );

type TN_RFrActionFlags = Set Of ( rfafShowCoords,   rfafShowColor,
                                  rfafScrollCoords, rfafSmartUScale,
                                  rfafIncrBufSize,  rfafSearchInActive,
                                  rfafZoomByClick,  rfafZoomByPMKeys,
                                  rfafFScreenByDClick, rfafFScreenNotFit  );
// ($001)rfafShowColor       - Show Color under Cursor on MouseDown
// ($002)rfafShowCObjInfo    - Show CObj Info on MouseMove
// ($004)rfafScrollCoords    - Scroll Coords by Drugging Mouse
// ($008)rfafSmartUScale     - do not view area out of RFLogFramePRect while Zooming
// ($010)rfafIncrBufSize     - Increase BufSize to RFLogFramePRect while Zooming
// ($020)rfafSearchInActive  - Search only In ActiveRFrame
// ($040)rfafZoomByClick     - Zoom by Mouse Clicks (Left-In, Right-Out)
// ($080)rfafZoomByPMKeys    - Zoom by "+" and '-' keys ("+"-In, "-"-Out)
// ($100)rfafFScreenByDClick - Start "FullScreen mode" by DblClick
// ($200)rfafFScreenNotFit   - No FitToWindow Full Screen Mode


type TN_RFIPFlags = Set Of ( rfipFrameSizeByAspect1, rfipFrameSizeByAspect2,
                             rfipFrameSizeByComp, rfipBufSizeByComp, rfipLogFrameByComp,
                             rfipUseDefScrRes,    rfipUseDefPrnRes );
// rfipFrameSizeByAspect1 - adjust Frame Size by Comp. Aspect (mode 1 - aamSwapDec)
// rfipFrameSizeByAspect2 - adjust Frame Size by Comp. Aspect (mode 2 - aamDecRect)
// rfipFrameSizeByComp    - set Frame Size by Component Pix Size
// rfipBufSizeByComp      - Set RastrBuf Size by Component Pix Size
// rfipLogFrameByComp     - Set LogFrameRect by Component Pix Size
// rfipUseDefScrRes       - Use MEDefScrResDPI for calculating Component Pix Size
// rfipUseDefPrnRes       - Use MEDefPrnResDPI for calculating Component Pix Size

// Old var:
// rfipUseCurFrameSize - use current Frame Size as desired Frame Size
// rfipConsiderAspect1 - update Frame Size by Component Aspect (using aamSwapDec mode)
// rfipFrameSizeByComp - set Frame Size by Component Size (otherwise use given FrameSize)
// rfipBufSizeByComp   - Set RastrBuf Size by Component Size (otherwise use given BufSize)
// rfipLogFrameByComp  - Set LogFrameRect Size by Component Size (otherwise use given Size)
// rfipUseScreenRes    - Use Screen Resolution (not Component SrcResDPI field) for calculationg Comp Size in Pix
// rfipUsePrinterRes   - Use Printer Resolution (not Component SrcResDPI field) for calculationg Comp Size in Pix

type TN_RFInitParams = packed record // Rast1Frame Init Params
  RFIPFlags: TN_RFIPFlags; // Init Flags
  RFIPResolution: float;   // Desired Resolution
end; // type TN_RFIniParams
type TN_PRFInitParams = ^TN_RFInitParams;

type TN_RFCoordsState = packed record // Rast1Frame Coords State Params
  RFCSFrameSize:    TPoint; // Frame Size in Pixels (same as PaintBox Size if Scrollbars are invisible)
  RFCSBufSize:      TPoint; // Raster Buf Size in Pixels (OCanv.CCRSize)
  RFCSLogFramePRect: TRect; // LogFrameRect in Pixels
  RFCSSrcPRect:      TRect; // Normalized RFSrcPRect
  RFCSRastrScale:    float; // Raster Scale
end; // type TN_RFCoordsState
type TN_PRFCoordsState = ^TN_RFCoordsState;

type TN_RFInterfaceFlags = Set Of ( rfifShiftAtZoom );


type TN_Rast1Frame = class; // forward declaration

{type} TN_RFrameAction = class; // forvard declaration

{type} TN_RFrameProcObj = procedure( ARFrame: TN_Rast1Frame ) of object;

{type} TN_Rast1Frame = class( TFrame ) //*** Base Frame Frame with PaintBox for
                                     // showing OCanv content and searching in it
    PaintBox: TPaintBox;
    HScrollBar: TScrollBar;
    VScrollBar: TScrollBar;
    RFrame1ActionList: TActionList;
    RepeatMouseDown: TTimer;
    aShowOptionsForm: TAction;
    aInitFrame: TAction;
    aRedrawFrame: TAction;
    aShowCompBorders: TAction;
    aFitInWindow: TAction;
    aFitInCompSize: TAction;
    aCopyToClipboard: TAction;
    aZoomIn: TAction;
    aZoomOut: TAction;
    aFullScreen: TAction;

    //**************** RFrame1ActionList OnExecute event handlers *************

  procedure aShowOptionsFormExecute ( Sender: TObject );
  procedure aInitFrameExecute       ( Sender: TObject );
  procedure aRedrawFrameExecute     ( Sender: TObject );
  procedure aShowCompBordersExecute ( Sender: TObject );

  procedure aFitInWindowExecute     ( Sender: TObject );
  procedure aFitInCompSizeExecute   ( Sender: TObject );
  procedure aCopyToClipboardExecute ( Sender: TObject );
  procedure aZoomInExecute          ( Sender: TObject );
  procedure aZoomOutExecute         ( Sender: TObject );
  procedure aFullScreenExecute      ( Sender: TObject );
//  procedure aShowRubberRectExecute  ( Sender: TObject );

    //**************** Other event handlers *************
  procedure PBPaint           ( Sender: TObject = nil );
  procedure OnResizeFrame     ( Sender: TObject );
  procedure HVScrollBarChange ( Sender: TObject );
  procedure PaintBoxMouseDown ( Sender: TObject; Button: TMouseButton;
                                          Shift: TShiftState; X, Y: Integer );
  procedure PaintBoxMouseMove ( Sender: TObject; Shift: TShiftState;
                                                              X, Y: Integer );
  procedure PaintBoxMouseUp   ( Sender: TObject; Button: TMouseButton;
                                          Shift: TShiftState; X, Y: Integer );
  procedure PaintBoxDblClick  ( Sender: TObject );
  procedure FrameMouseWheel   ( Sender: TObject; Shift: TShiftState;
                WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean );
  procedure CallMouseDown     ( Sender: TObject );

    public
  RFObjSize:   TPoint; // Original Object (Component) X,Y Size in Pixels
  RFObjAspect: double; // needed Object Aspect (Aspect of RFLogFramePRect, =0 means any aspect is OK)
  RFDebName:   string; // RFrame Name for debug only

  //***** Visual Comps realated fields
  RVCTreeRoot: TN_UDCompVis; // VCTree Root Component (R prefix is used to
                             //   distinguish from TN_GlobCont.GVCTreeRoot field)
  NGlobCont: TN_GlobCont;    // VCTree.ExecSubTree Global Context
  RVCTreeRootOwner: boolean; // if True, RVCTreeRoot shuld be deleted in RFFreeObjects
  RFResereved1: boolean; //
  RFResereved2: boolean; //
  RFResereved3: boolean; //
  RFFullScreenMode: integer; // 0 - not FullScereen Mode, 1 - FullScereen Mode, 2 - Parent Form should be closed by MouseUp

  //***** OCanv related fields
  OCanv: TN_OCanvas;       // Own Canvas for drawing (Raster Bufer)
  OCanvBackColor: integer; // OCanv Background Color (used in RedrawAll)
  RFSrcPRect: TRect;       // Visible Rect (Source of RFDstPRect)
  RFDstPRect: TRect;  // Visible Pixel Rect in PaintBox with same content as in
          // RFSrcPRect, but not same size, it may be scaled by RFRasterScale coef.
  RFPaddings: TRect;  // Min Size in Pix between Paintbox and RFDstPRect
  RFRasterScale: float;  // Raster Scale coef. (DstSize = RFRasterScale*SrcSize)
  RFVectorScale: float;  // Vector Scale coef. (RFLogFramePRectSize = RFVectorScale*RFObjSize)
  RFMaxVectorScale: float; // Max possible Vector Scale coef.
  RFMinRelObjSize: float; // Min possible visible relative (to RFrameSize) ObjSize (defvalue=0.5)
  RFMaxRelObjSize: float; // Max possible visible relative (to RFrameSize) ObjSize (defvalue=20.0)
  RFMaxBufSizeMB:  float; // Max possible value for TN_Rast1Frame.OCanv Buf Size in Megabytes
  MinMeshStep:   integer; // Min One Pixel Size for Drawing Pix.Borders Mesh
  RFMaxBufSize:  integer; // Max Buf Size in bytes
  DstBackColor:  integer; // Dst Background Rects Color (Clear Self Color)
  RFInterfaceFlags: TN_RFInterfaceFlags; // Interface Flags

  DrawProcObj:     TN_ProcObj; // Redraw Self  Procedure of Object (used in Redraw method)
  RFResizeProcObj: TN_ProcObj; // Resize Self Procedure of Object (used in OnResizeFrame method)
  RFOnScaleProcObj:  TN_RFrameProcObj; // On Change Current Scale Procedure of Object
  RFOnScrollProcObj: TN_RFrameProcObj; // On Scroll Procedure of Object
  RFSGroups:  TObjectList; // list of TN_SGBase (Search Groups) objects

  RFLogFramePRect:  TRect; // Pixel analog of CompOuterPixRect for Root component (for zooming)
//  RFCompSizemm:  TFPoint; // VCTree Root Component Size in mm (used in InitializeCoords)
//  RFCompSizePix: TPoint;  // VCTree Root Component Size in Pixels (used in InitializeCoords)

  //***** User Interface settings for changing Self coords and size
  RFCenterInDst: boolean;  // center RFDstPRect in PaintBox
  RFCenterInSrc: boolean;  // center new RFSrcPRect relative to old RFSrcPRect
  RFFixedScale:  boolean;  // prohibit to change RFRasterScale and RFVectorScale
  RFDrawFlags: TN_RFrDrawFlags; // Drawing flags
  ResizeFlags: integer;  // used in OnResizeFrame (see RFResizeSelf)
  RFStretchBltMode: integer; // PaintBox.Canvas.Handle StretchBlt Mode
  //***** cooperation of Self and parent Form
//  ParentForm: TN_BaseForm;    // Self's Parent Form
//  ParentForm: TForm;    // Self's Parent Form
//  SelfAsControl: TWinControl; // Self as WinControl in ParentForm

  SomeStatusBar: TStatusBar;  // any StatusBar used in Actions
  FrU2A: TN_AffCoefs4;        // User to Application Affine Coefs.

  CCDst:  TPoint;      // current Cursor Coords in Dst(PaintBox) Pixels
  CCBuf:  TPoint;      // current Cursor Coords in Buf(OCanv) Pixels (integer)
  CCBufD: TDPoint;     // current Cursor Coords in Buf(OCanv) Pixels (double)
                       // ( CCBuf = Round(CCBufD) )
  CCUser: TDPoint;     // current Cursor Coords in User units, Snapped if needed
  CCUserNS: TDPoint;   // current Cursor Coords in User units, NOT Snapped
  CCAppl: TDPoint;     // current Cursor Coords in Application units

  CCUserSGridOrigin: TDPoint;  // Cursor User Coords Snap Grid Origin
  CCUserSGridStep:   TDPoint;  // Cursor User Coords Snap Grid Step

  MeshEnabled: boolean;      // Drawing one pixel mesh is enabled
  SkipMouseMove: boolean;    // used when moving cursor programmatically
  SkipMouseDown: boolean;    // used when moving cursor programmatically
  SkipOnPaint: boolean;      // OnPaint method should not work (used to
                             // avoid not needed Windows OnPaint messages)
  SkipOnResize: boolean;     // OnResize method should not work (used when
                             //         sizes are changed programmatically)
  SkipOnScrollBarChange: boolean; // OnChange ScrollBars method should not work
                                  // (used if theirs params are changed programmatically)
  RFExtSkipOnPaint: boolean;      // skip repainting from extrnal code

  ShowCoordsType: TN_CompCoordsType; // Component Coords to show in StatusBar
  ShowPixelColor: boolean; // show cur. Pixel color in StatusBar (before coords)
  ScrollByMouseWheel: boolean; // Scroll Image by MouseWheel (instead of Zooming)
  AnchorUC: TDPoint;       // Cursor coords in User units saved at MouseDown

  PointCoordsFmt: string;  // format strings for showing in StatusBar Point coords
  RectCoordsFmt:  string;  // format strings for showing in StatusBar Rect coords

//  PointUserCoordsFmt: string;  //   Point User  coords
//  PointApplCoordsFmt: string;  //   Point Application coords
//  RectPixCoordsFmt:   string;  //   Rect  Pixel coords
//  RectUserCoordsFmt:  string;  //   Rect  User  coords
//  RectApplCoordsFmt:  string;  //   Rect  Application coords

//  UCAccuracyFmt: integer; // User Coords Accuracy
//  ACAccuracyFmt: integer; // Application Coords Accuracy
                          // (number of decimal digits after comma separator)
  RFrOpForm: TForm;       // really TN_RFrameOptionsForm

  //***** Self handler context
  CHType: TN_HandlerType; // htMoseDown,Move,Up,DblClick,htKeyDown
  LastCHType: TN_HandlerType; // last htMoseDown,Move,Up,DblClick,htKeyDown
//  CShiftIsDown: boolean;  // Shift key is down
//  CCtrlIsDown:  boolean;  // Ctrl key is down
  CMPos:    TPoint;       // Current Mouse Position
  LastMDownPos : TPoint;  // Last Mouse Down Position
  CMButton: TMouseButton; // Current Mouse Button
  CMWheel:  integer;      // Current Mouse Wheel Delta
  CMKShift: TShiftState;  // Current Mouse and Keyboard Shift State
  CKey:     TWMKey;       // Current Key Pressed
  RFDebugFlags: integer;  // bit0($001)=1 - show whole Redrawing time
                          // bit1($002)=1 - set and show Timers in ...
                          // bit2($004)=1 - Add Deb Info to N_InfoForm
                          // bit4($010)=1 - Show Action Name
                          // bit30($40000000)=1 - Show KeyDown and KeyUp Info
  ActCounter: integer;    // action Counter, for debug

  RFClearFlags: integer;  // "clear StatusBar, N_MemoForm before MouseMove" Flags

  UCObjEdForm: TN_BaseForm; // RFrame is owner of UCObjEditorForm

  //***** used in RFActions to control Highlighting and permanent drawing
  RFSkipAnimation  : boolean; // always use permanent draw mode without any temporary Highlighting
  DoHighlight      : boolean; // ClearPrevPhase was executed, Highlighting is allowed
  ForceHighlighting: boolean; // Force Highlighting in all MouseMove
  PermanentDraw    : boolean; // permanent drawing is allowed
  OnlyRasterScale  : boolean; // Only Raster Zoom is allowed
  MouseDownTimerState: integer;

  InfoStrings: TN_SArray;     // Info Strings about CObjects under Cursor
  RFrActionFlags: TN_RFrActionFlags; // RFrameActions control Flags
  RFrResizeFlags: TN_RFrResizeFlags;
  RFVectorScaleStep: float; // RFVectorScale multiplier
  RFCRectSizeCoef:   float; // OCanv.CCRSize multiplier (>=1, =1 means min needed)

  RFOneGroup:         TObject; // really is TN_SGComp
  RFMouseAction:      TObject; // really is TN_RFAMouseAction
  RFRubberRectAction: TObject; // really is TN_RubberRectRFA
  RFRubberRectStr:     string; // string to show in N_ActShowAction (usually after cursor coords)
  OnMouseDownProcObj: TMouseEvent; // External OnMouseDown Procedure of Object
  OnMouseUpProcObj:   TMouseEvent; // External OnMouseUp Procedure of Object
  OnWMKeyDownProcObj: procedure ( var m: TWMKey ) of object;
  RFOnMaxVSProcObj:   procedure ( APRast1Frame: Pointer; AMaxVScale: float ) of object;

  RFEnableEvents:    boolean; // Enable Mouse and Keyboard events even if N_AppSkipEvents=True
  RFDumpEvents:      boolean; // Enable calling N_Dump2Str for Mouse (excluding MouseMove) and Keyboard events
  RFDumpMoveEvents:  boolean; // Enable calling N_Dump2Str for MouseMove events
  RFShowMarkedNames: boolean; // Show ObjName of Marked Component in TN_RFAMarkComps.Execute


  constructor Create ( AOwner: TComponent ); override;

  procedure WMEraseBkgnd ( var m: TWMEraseBkgnd ); message WM_ERASEBKGND;
  procedure WMKeyDown    ( var m: TWMKey );        message WM_KEYDOWN;
  procedure WMKeyUp      ( var m: TWMKey );        message WM_KEYUP;
//  procedure WndProc      ( var Msg: TMessage ); override;
  procedure OnActivateFrame  ();
  procedure RFFreeObjects    ();
  procedure ClearBufs        ();
  procedure ShowMainBuf      ();
  procedure ShowInvRects     ();
  procedure ShowNewPhase     ();
  procedure StartAnimPhase1  ();
  procedure FinAnimPhase1    ();
  procedure FinAnimation     ();
  procedure InitByFullURect  ( AFullURect: TFRect );
  function  PrepOCanv        ( const AWholePRect, AVisPRectR: TRect ): boolean;
  procedure ShiftRFSrcPRect  ( ANewTopLeftRel: TPoint );
  function  SetZoomLevel     ( AZoomMode: TN_RFZoomMode ): boolean;
  procedure VectorScale      ( AScaleCoef: float; AZoomFlags: TN_RFZoomFlags );
  procedure ResizeSelf       ( NewWidth, NewHeight: integer );
  procedure RecalcPRects     ();
  procedure RFResizeSelf     ();
  procedure Redraw           ();
  procedure RedrawAll        ();
  procedure RedrawAllAndShow ();
  function  RedrawAllToMetafile ( PixRect, MM01Rect: TRect ): TMetafile;
//  function  CoordsToStr ( const APoint: TPoint;
//                              SCType: TN_CompCoordsType ): string; virtual;
  procedure ShowString ( AFlags: integer; AStr: string );

  procedure RFExecAllSGroupsActions ();
  procedure RedrawAllSGroupsActions ();
  procedure SearchInAllGroups  ();
  procedure SearchInAllGroups2 ( AX, AY: integer );
  procedure StartPermanent     ();
  procedure StartHighlighting  ();
  function  GetGroupInd ( AGName: string ): integer;
  procedure DeleteGroup ( AGName: string );
//  procedure SetGroup    ( GroupDescr: TK_RArray; GroupInd: integer = -1 );
  procedure SetCursorByDPCoords ( const ABufD: TDPoint );
  procedure SetCursorByUcoords  ( const AUcoords: TDPoint );
  procedure StartMouseDownTimer ();

  procedure InitializeCoords  ( AWidth: integer = 0; AHeight: integer = 0 ); overload;
  procedure InitializeCoords  ( APRFInitParams: TN_PRFInitParams; APCoords: TN_PRFCoordsState ); overload;
  procedure RVCTFrInit        ( ARootComp: TN_UDCompVis; APixWidth: integer = 0; APixHeight: integer = 0 );
  procedure RVCTFrInit3       ( ARootComp: TN_UDCompVis; APRFInitParams: TN_PRFInitParams = nil; APCoords: TN_PRFCoordsState = nil );
  procedure RFrChangeRootComp ( ARootComp: TN_UDCompVis );
  procedure RFrShowComp       ( ARootComp: TN_UDCompVis );
  procedure RFrInitByComp     ( ARootComp: TN_UDCompVis );
  procedure RFrInitByPaintBox ( AAspect: double );
  procedure GetCoordsState    ( APCoords: TN_PRFCoordsState );
  function  RFGetCurRelObjSize (): double;
//  procedure UpdateCoordsStateByCompSize ( APCoords: TN_PRFCoordsState;
//                               const AOldmmSize: TFPoint; AComp: TN_UDCompVis );
  procedure DrawVCTree     ();
  procedure TestDrawGrid   ();
  procedure RFShowCurScale ( ARFrame: TN_Rast1Frame );
  function  RFGetActionByClass ( AClassInd: integer ): TN_RFrameAction;
  procedure RFAddCurState      ( AStrings: TStrings; AIndent: integer );
end; // type TN_Rast1Frame = class( TFrame )


{type} TN_RFAClass = class of TN_RFrameAction;

{type} TN_ActExtExecProcObj = procedure( ARFrameAction: TN_RFrameAction ) of object;

{type} TN_SGBase = class( TObject ) //***** Search Group Base class
                                  // (with no fields for search results)
  RFrame: TN_Rast1Frame;     // Parent RFrame
  GName: string;             // Group Name (mainly for debug)
  CursorPPoint: TPoint;      // Cursor Pixel Point (in Canvas Pixel Coords)

  GroupActList: TObjectList; // list of TN_RFrameAction ancestors
  SRChanged: boolean;        // Search Result Changed after MouseMove
  ForceAction: boolean;      // set in GExecOneAction
  SkipActions: boolean;      // Skip all ASelf Actions
//  ExtExecProcObj: TN_ActExtExecProcObj; // External Execute Procedure of Object

  constructor Create       ( ARFrame: TN_Rast1Frame );
  destructor  Destroy      (); override;
  function  SearchInAllComps (): boolean; virtual;
  function  GetActionByClass ( AClassInd: integer ): integer; overload;
  function  GetActionByRGInd ( ARGInd: integer  ): integer; overload;
  function  SetAction        ( AClassInd: integer; AActFlags: integer = 0;
                   ActInd: integer = -1; ARGInd: integer = 0 ): TN_RFrameAction;
  procedure GExecAllActions ();
  procedure GExecOneAction  ( AClassInd, AActFlags: integer );
end; // type TN_SGBase = class( TObject )

{type} TN_RFrameAction = class( TObject ) //***** abstract RFrame Action object
  ActName:  string;     // Action Name, mainly for debug
  ActGroup: TN_SGBase;  // Action Group
  ActFlags: integer;    // Action Flags
  ActRGInd: integer;    // Action RadioGroup Index (only one Action with same
                        //    ActRGInd>0 can be included in each GroupActList)
  ActEnabled: boolean;  // Action is Enabled
  ActMaxUrect: TFRect;  // Action Max User Coords Rect
  ActExtExecProcObj: TN_ActExtExecProcObj; // External Execute Procedure of Object

  constructor Create      (); virtual;
  procedure SetActParams  (); virtual;
  procedure Execute       (); virtual;
  procedure RedrawAction  (); virtual;
end; // type TN_RFrameAction = class( TObject )

Const N_RFAClassRefsMaxInd = 119;
type TN_RFAClassRefs = array [0..N_RFAClassRefsMaxInd] of TN_RFAClass;
var
  N_RFAClassRefs: TN_RFAClassRefs = ( //***** all TN_RFrameAction ancestors
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 00-09
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 10-19
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 20-29
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 30-39
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 40-49
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 50-59
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 60-69
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 70-79
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 80-89
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 90-99
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   // 100-109
       nil, nil, nil, nil, nil, nil, nil, nil, nil, nil ); // 110-119

  N_RFrameDeb:        TN_Rast1Frame;    // for debugging
  N_ActiveRFrame:     TN_Rast1Frame;    // Active (Last Activated) RFrame
  N_DefRFInitParams:  TN_RFInitParams;  // = ( RFIPFlags:[rfipUseCurFrameSize]; RFIPResolution:0 );
  N_DefRFCoordsState: TN_RFCoordsState; // = ( RFCSNLogFrameRect:(Right:1; Bottom:1);

//  N_RFMaxVectorScale: float =  1600; // Default value for TN_Rast1Frame.RFMaxVectorScale
//  N_RFMinRelObjSize:  float =   0.5; // Default value for TN_Rast1Frame.RFMinRelObjSize
//  N_RFMaxRelObjSize:  float = 256.0; // Default value for TN_Rast1Frame.RFMaxRelObjSize
//  N_RFMaxBufSizeMB:   float = 2000.0; // Default value for TN_Rast1Frame.RFMaxBufSizeMB

  N_RFMaxVectorScale: float =  10000; // Default value for TN_Rast1Frame.RFMaxVectorScale
  N_RFMinRelObjSize:  float =    0.5; // Default value for TN_Rast1Frame.RFMinRelObjSize
  N_RFMaxRelObjSize:  float = 1000.0; // Default value for TN_Rast1Frame.RFMaxRelObjSize
  N_RFMaxBufSizeMB:   float =  1.0e6; // Default value for TN_Rast1Frame.RFMaxBufSizeMB

  //******************** RFrame Actions objects ******************

type TN_RFAShowAction = class( TN_RFrameAction ) //*** Show Action:
                                                 //    Show Cursor Coords
  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAShowAction = class( TN_RFrameAction )

type TN_RFAShowColor = class( TN_RFrameAction ) //*** Show Cursor Color
  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAShowColor = class( TN_RFrameAction )

type TN_RFAMouseAction = class( TN_RFrameAction ) //*** Several Mouse Action:
         // Show Color or Scroll Image (Raster or Vector) by Drug or MouseWheel
  ScrollMode: boolean;
  SavedCCDst:   TPoint;
  SavedTopLeft: TPoint;
  SavedCursor: TCursor;
  RFADisable:  boolean;

  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure StartScrollMode ();
end; // type TN_RFAMouseAction = class( TN_RFrameAction )

type TN_RFAZoom = class( TN_RFrameAction ) //*** Zoom User Coords or Raster Scale
  ScaleCoef: double;

  procedure SetActParams (); override;
  procedure Execute (); override;
end; // type TN_RFAZoom = class( TN_RFrameAction )

type TN_RFAGetUPoint = class( TN_RFrameAction ) //*** Get Point Coords
  DPProcObj: TN_DPProcObj;

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAGetUPoint = class( TN_RFrameAction )


    //*********** Global Procedures  *****************************

procedure N_SetP2UAndRedraw ( const AP2U: TN_AffCoefs4; ARFrame: TN_Rast1Frame);
procedure N_ShowCompInFullScreen ( AComp: TN_UDCompVis );


    //*********** Global Constance and Variables  ****************

const // RFrame Actions Indexes:
  N_ActEmpty         = 0;
//  N_ActPattern       = ???;

  N_ActShowAction    = 4;
  N_ActMouseAction   = 5;
  N_ActZoom          = 6;
  N_ActGetUPoint     = 7;

  N_ActDebAction1    = 10;

  N_ActShowCObjInfo  = 13;
  N_ActShowUserInfo  = 14;

  N_ActHighPoint     = 16;
  N_ActMovePoint     = 17;
  N_ActAddPoint      = 18;
  N_ActDeletePoint   = 19;

  N_ActMoveLabel     = 21;
  N_ActAddLabel      = 22;
  N_ActDeleteLabel   = 23;
  N_ActEditLabel     = 24;

  N_ActHighLine      = 27;
  N_ActEditVertex    = 28;
  N_ActDeleteLine    = 29;
  N_ActSplitCombLine = 30;

  N_ActMarkCObjPart  = 33;
  N_ActMarkPoints    = 34;
  N_ActSetItemCodes  = 35;

  N_ActAffConvLine   = 37;
  N_ActEditItemCode  = 38;
  N_ActEditRegCodes  = 39;

  N_ActSetShapeCoords = 50;

  N_ActMoveComps      = 60;
  N_ActMarkComps      = 61;

  N_ActEd3Rects       = 63;
  N_ActRubberRect     = 65;
  N_ActRubberSegm     = 66;
  N_ActEditComps      = 67;

  N_ActDGridRFA       = 69;
  N_ActTst1RFA        = 70;

// Indexes 71 - 109 for Sasha:

  N_ActCMEAddVObj1      = 71;
  N_ActCMEAddVObj2      = 72;
  N_ActCMEGetSlideColor = 73; // will remain N_
  N_ActCMEMoveVObj      = 74;
  N_ActCorPict          = 75;

  N_ActCMEIsodensity    = 77;

// Indexes 110 - 119 for Nik CMS Actions:

  N_ActCMFlashLight     = 110;

// Current Last Action index in N_RFAClassRefs Array is N_RFAClassRefsMaxInd = 119;


implementation
uses Math, Clipbrd,
  K_CLib, K_UDT1,
  N_Lib0, N_Lib2, N_LibF, N_RastFrOpF, N_InfoF, N_MemoF, N_ClassRef, N_Deb1,
  N_ME1, N_SGComp, N_NVTreeFr, N_ButtonsF, N_CompCL, N_RVCTF, StrUtils;
{$R *.DFM}

//************ TN_Rast1Frame ActionList OnExecute event handlers *************

procedure TN_Rast1Frame.aShowOptionsFormExecute( Sender: TObject );
// View RFrameOptionsForm
begin
  RFrOpForm := N_CreateRFrameOptionsForm( Self, K_GetOwnerBaseForm( Owner ) );
//  N_PlaceTControl( RFrOpForm, K_GetOwnerForm( Owner ) );
  N_PlaceTControl( RFrOpForm, K_GetParentForm( Self ) );
  RFrOpForm.Show;
end; // procedure TN_Rast1Frame.aShowOptionsFormExecute

procedure TN_Rast1Frame.aInitFrameExecute( Sender: TObject );
// change FrameSize and LogFrameRect according to Shift and Ctrl keys
// or Integer(Sender) value:
//
// if Shift is down or Sender = 1 - set LogFrameRect to current Frame.PaintBox size
// if Ctrl  is down or Sender = 2 - set LogFrameRect to current Frame.PaintBox,
//                          decrease not used Frame size and set RFRasterScale = 1
var
  NewSizePix: TPoint;
//  NewSizemm: TFPoint;
  SizeType: TN_VCTSizeType;
begin
  NewSizePix := OCanv.CCRSize; // preserve current size if Shift and Ctrl are both UP

  if N_KeyIsDown( VK_SHIFT) or (Integer(Sender) = 1) then
    NewSizePix := Point( Width, Height );  // Set LogFrameRect to visible size

  if N_KeyIsDown( VK_CONTROL) or (Integer(Sender) = 2) then
  begin    // Set LogFrameRect to visible size and decrease not used Frame size
           // if Pixel Coords of RVCTreeRoot are given, set Frame Size to them
    RFRasterScale := 1;

    if RVCTreeRoot = nil then Exit; // a precaution
    SizeType := RVCTreeRoot.GetSize( nil, @NewSizePix );

    if SizeType <> vstPix then // Pixel Coords of RVCTreeRoot are NOT given
      NewSizePix := RVCTreeRoot.CalcRootCurPixRectSize( OCanv.CCRSize );

    ResizeSelf( NewSizePix.X, NewSizePix.Y );
  end; // if N_KeyIsDown( VK_CONTROL) then

  InitializeCoords( NewSizePix.X, NewSizePix.Y );
  RedrawAllAndShow();
end; // procedure TN_Rast1Frame.aInitFrameExecute

procedure TN_Rast1Frame.aRedrawFrameExecute( Sender: TObject );
begin
  N_RefreshCoords := True;
  RedrawAllAndShow();
  N_RefreshCoords := False;
end; // end of procedure TN_Rast1Frame.aRedrawFrameExecute

procedure TN_Rast1Frame.aShowCompBordersExecute( Sender: TObject );
// Toggle DrawContext dcdfShowBorder or dcdfShowMarked flags (if Shift pressed)
begin
  with NGlobCont do
  begin
    if N_KeyIsDown( VK_SHIFT ) then
    begin
      if gcdfShowMarked in GCDebFlags then
        GCDebFlags := GCDebFlags - [gcdfShowMarked]
      else
        GCDebFlags := GCDebFlags + [gcdfShowMarked];
    end else // Shift is Up
    begin
      if gcdfShowBorder in GCDebFlags then
        GCDebFlags := GCDebFlags - [gcdfShowBorder]
      else
        GCDebFlags := GCDebFlags + [gcdfShowBorder];
    end;
  end; // with NGlobCont do

  aRedrawFrameExecute( Sender );
end; // procedure TN_Rast1Frame.aShowCompBordersExecute


procedure TN_Rast1Frame.aFitInWindowExecute( Sender: TObject );
// Fit current Component to Window -  Show whole Component in current Frame
//   by setting LogFrameRect and BufSize by Frame Size.
// Adjust Frame Size by Component Aspect if needed.
//
var
  NeededMode, IntSender: integer;
  SkipShowing: boolean;
  RFInitParams: TN_RFInitParams;
  CoordsState: TN_RFCoordsState;
begin
  if RVCTreeRoot = nil then Exit;

  // Set needed Mode:
  //   0 - do not change Frame Size
  //   1 - change Frame Size by Component Aspect in aamSwapDec mode
  //         ( Max(FrameSize.X,FrameSize.Y) remains the same )
  //   2 - change Frame Size by Component Aspect in aamDecRect mode
  //         ( consequent showing components with different aspects in mode=2
  //           causes cosequent decreasing Frame size, which looks uplesant )
  //  >2 - depends upon Shift and Ctrl keys:
  //       Both UP    - Mode = 0
  //       Shift Down - Mode = 1
  //       Ctrl  Down - Mode = 2

  IntSender := Integer(Sender);
  SkipShowing := False;
  if IntSender = -1 then
  begin
    SkipShowing := True;
    IntSender := 0;
  end;

  if IntSender >= 3 then //*** Check Shift and Ctrl keys
  begin
    NeededMode := 0;
    if N_KeyIsDown(VK_SHIFT)   then NeededMode := 1;
    if N_KeyIsDown(VK_CONTROL) then NeededMode := 2;
  end else //***************** Set needed mode by IntSender
    NeededMode := IntSender;

  RFInitParams := N_DefRFInitParams;
  CoordsState := N_DefRFCoordsState;
  CoordsState.RFCSRastrScale := 1;
  RVCTreeRoot.PrepRootComp(); //??

  with RFInitParams do // set RFIPFlags
  begin
    if NeededMode = 1 then RFIPFlags := RFIPFlags + [rfipFrameSizeByAspect1];
    if NeededMode = 2 then RFIPFlags := RFIPFlags + [rfipFrameSizeByAspect2];
  end; // with RFInitParams do

//  if Assigned( N_StringDumpProcObj ) then N_StringDumpProcObj( 'Rast1Frame', // debug
//    Format( '*aFitInWindowExecute %s (%d) Cur=%d,%d', [RFDebName, NeededMode, integer(Sender), -1] ));

  N_Dump2Str( 'aFitInWindowExecute before InitializeCoords' );
  InitializeCoords( @RFInitParams, @CoordsState );
  N_Dump2Str( 'aFitInWindowExecute after InitializeCoords SkipShowing=' + N_B2S(SkipShowing) );

  if SkipShowing then
    RedrawAll()
  else
    RedrawAllAndShow();

  N_Dump2Str( 'aFitInWindowExecute after Redraw All' );
end; // procedure TN_Rast1Frame.aFitInWindowExecute

procedure TN_Rast1Frame.aFitInCompSizeExecute( Sender: TObject );
// Draw whole Component in Buffer with needed resolution and show upper left
// rect of it (Frame Size remains the same)
//
// Implemented modes:
//   bit0 = 0 - use Component or Default Screen Resolution
//   bit0 = 1 - use Default Printer Resolution
//   bit1 = 0 - Set Buf Size by Frame Size
//   bit1 = 1 - Set Buf Size by Component Pix Size
//
// Needed mode is given by Integer(Sender) or by Shit (bit0) and Ctrl (bit1) keys
//
var
  NeededMode, IntSender: integer;
  RFInitParams: TN_RFInitParams;
  CoordsState: TN_RFCoordsState;
begin
  IntSender := Integer(Sender);

  if IntSender >= 4 then //*** Check Shift and Ctrl keys
  begin
    NeededMode := 0;
    if N_KeyIsDown(VK_SHIFT)   then NeededMode := 1;
    if N_KeyIsDown(VK_CONTROL) then NeededMode := NeededMode + 2;
  end else //***************** Set needed mode by IntSender
    NeededMode := IntSender;

  RFInitParams := N_DefRFInitParams;
  CoordsState := N_DefRFCoordsState;
  CoordsState.RFCSRastrScale := 1;

  with RFInitParams, N_MEGlobObj do // set RFIPFlags and RFIPResolution
  begin
    RFIPFlags := [rfipLogFrameByComp];

    if (NeededMode and $02) <> 0 then RFIPFlags := RFIPFlags + [rfipBufSizeByComp];

    if (NeededMode and $01) = 0 then //*** Use Component or Default Screen Resolution
    begin
      RFIPResolution := MEScrResCoef*RVCTreeRoot.PCCD^.SrcResDPI;
      if RFIPResolution = 0 then // Resolution was not given in Component
        RFIPResolution := MEScrResCoef*MEDefScrResDPI;
    end else //*************************** Use Default Printer Resolution
      RFIPResolution := MEDefPrnResDPI;

  end; // with RFInitParams, N_MEGlobObj do // set RFIPFlags and RFIPResolution

  InitializeCoords( @RFInitParams, @CoordsState );
  RedrawAllAndShow();
  OnResizeFrame( Sender ); // temporary? to show scrollbars
end; // procedure TN_Rast1Frame.aFitInCompSizeExecute

procedure TN_Rast1Frame.aCopyToClipboardExecute( Sender: TObject );
// Copy current Component to Clipboard in BMP or EMF format
var
  TmpGCont: TN_GlobCont;
  ExpParams: TN_ExpParams;
begin
  TmpGCont := TN_GlobCont.Create();
  ExpParams := N_DefExpParams;
  ExpParams.EPMainFName := 'clipboard.emf';
//  ExpParams.EPMainFName := 'clipboard.bmp'; // copy to clipboard in bmp format (for debug only)
  TmpGCont.ExecuteRootComp( RVCTreeRoot, [], nil, K_GetOwnerBaseForm( Owner ), @ExpParams );
  TmpGCont.Free;
end; // procedure TN_Rast1Frame.aCopyToClipboardExecute

procedure TN_Rast1Frame.aZoomInExecute( Sender: TObject );
// Zoom In by RFVectorScaleStep
begin
  VectorScale( RFVectorScaleStep, [] );
end; // procedure TN_Rast1Frame.aZoomInExecute

procedure TN_Rast1Frame.aZoomOutExecute( Sender: TObject );
// Zoom Out by 1/RFVectorScaleStep
begin
  VectorScale( 1/RFVectorScaleStep, [] );
end; // procedure TN_Rast1Frame.aZoomOutExecute

procedure TN_Rast1Frame.aFullScreenExecute( Sender: TObject );
// Show Self Root Component over the Full Screen
begin
// flag rfafFScreenNotFit in RFrActionFlags is not implemented (may be not needed)
  N_ShowCompInFullScreen( RVCTreeRoot );
end; // procedure TN_Rast1Frame.aFullScreenExecute

{
procedure TN_Rast1Frame.aShowRubberRectExecute( Sender: TObject );
// Show Rubber Rect, now only for measuring needs

begin
  with TN_RubberRectRFA(RFRubberRectAction) do
  begin
    if aShowRubberRect.Checked then // Enable RFRubberRectAction
    begin
      RRConP2UComp := RVCTreeRoot;
      RRCurUserRect := N_RectScaleR( RRConP2UComp.PSP.CCoords.CompUCoords, 0.9, DPoint(0.5,0.5) );
      ActEnabled := True;
    end else //*********************** Disable RFRubberRectAction
    begin
      RRConP2UComp := nil;
      ActEnabled := False;
    end;
  end; // with TN_RubberRectRFA(RFRubberRectAction) do

  RedrawAllAndShow();
end; // procedure TN_Rast1Frame.aShowRubberRectExecute
}


//********** TN_Rast1Frame class methods  **************

//*************************************************** TN_Rast1Frame.PBPaint ***
// OnPaint event handler for PaintBox
// update ScrollBars, update PaintBox by MainBuf, Fill Boreder Rects (if any)
//
procedure TN_Rast1Frame.PBPaint( Sender: TObject );
begin
//  if Name = 'ThumbsRFrame' then // debug
//    N_i := 1;
//  if (N_AppSkipEvents and not RFEnableEvents) or SkipOnPaint or RFExtSkipOnPaint then Exit; // Skip event

  N_s := RFDebName; // debug

  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s PBPaint %d %d', [RFDebName,Integer(SkipOnPaint),Integer(RFExtSkipOnPaint)] ));
  if SkipOnPaint or RFExtSkipOnPaint then Exit; // Skip event

//  N_GC := NGlobCont; // for debug only
//  N_p1 := Pointer(NGlobCont);
//  N_OCanv := NGlobCont.DstOCanv;
//  N_p2 := Pointer(NGlobCont.DstOCanv);

  if Ocanv <> nil then
  begin
    if Ocanv.HMDC <> 0 then
      ShowMainBuf()
  end else // OCanv is Not Ready, clear whole Client Rect by DstBackColor
    N_DrawFilledRect( PaintBox.Canvas.Handle, PaintBox.ClientRect, DstBackColor);

  SkipOnResize := False; // Enable processing OnResize messages
  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s PBPaint Finished', [RFDebName] ));
end; // end of procedure TN_Rast1Frame.PBPaint

//********************************************* TN_Rast1Frame.OnResizeFrame ***
// OnResize Frame event handler
// ( Is called not only after Parent Form size was changed by mouse,
//   but also in Form constructors and after Form.Heigh, .Width assignments.
//   In these cases SkipOnResize flag should be set. )
//
procedure TN_Rast1Frame.OnResizeFrame( Sender: TObject );
var
  RFResizeProcObjAssigned: integer;
begin
//  if Name = 'ThumbsRFrame' then // debug
//    N_i := 1;
  if (N_AppSkipEvents and not RFEnableEvents) or SkipOnResize then Exit; // Skip event

  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s OnResize', [RFDebName] ));

  SkipOnPaint := True; // skip OnPaint messages,
                       // PaintBox would be painted by OnPaint message,
                       // generated by Windows AFTER OnResize

  RFResizeProcObjAssigned := 0;
  if Assigned(RFResizeProcObj) then
  begin
    RFResizeProcObj();
    RFResizeProcObjAssigned := 1;
  end;

  SkipOnPaint := False; // Enable processing OnPaint messages
  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s OnResize Finished, (RFResizeProcObjAssigned=%d)', [RFDebName, RFResizeProcObjAssigned] ));
end; // end of procedure TN_Rast1Frame.OnResizeFrame

//***************************************** TN_Rast1Frame.HVScrollBarChange ***
// OnChange event handler for both ScrollBars
//
procedure TN_Rast1Frame.HVScrollBarChange( Sender: TObject );
var
  RFOnScrollProcObjAssigned: integer;
  NewRect: TRect;
begin
//  if SkipOnScrollBarChange then Exit;
  if (N_AppSkipEvents and not RFEnableEvents) then Exit; // Skip event

  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s HVSBarChange', [RFDebName] ));

  NewRect := RFSrcPRect;
  N_ShiftIRectByScrollBars( RFLogFramePRect, NewRect, HScrollBar, VScrollBar );

//*** when in upper position, VScrollBar has not received event when UpArrow
//    VScrollBar is Clicked by Mouse but became Active Control and Thumb begind blinking
//    Setting VScrollBar.Position programmatical does not improve anything

//  SkipOnScrollBarChange := True;
//  if VScrollBar.Position = VScrollBar.Min then VScrollBar.Position := VScrollBar.Min + 100;
//  SkipOnScrollBarChange := False;

  ShiftRFSrcPRect( N_Substr2P( NewRect.TopLeft, RFLogFramePRect.TopLeft ) );
//  K_GetOwnerForm( Owner ).ActiveControl := Self; // to skip ScrollBar blinking
  K_GetParentForm( Self ).ActiveControl := Self; // to skip ScrollBar blinking

  RFOnScrollProcObjAssigned := 0;
  if Assigned( RFOnScrollProcObj ) then
  begin
    RFOnScrollProcObj( Self );
    RFOnScrollProcObjAssigned := 1;
  end;

  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s HVSBarChange RFOnScrollProcObjAssigned=%d', [RFDebName,RFOnScrollProcObjAssigned] ));
end; // procedure TN_Rast1Frame.HVScrollBarChange

//***************************************** TN_Rast1Frame.PaintBoxMouseDown ***
// OnMouseDown PaintBox event handler
//
procedure TN_Rast1Frame.PaintBoxMouseDown( Sender: TObject;
                      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  if Assigned( N_StringDumpProcObj ) then N_StringDumpProcObj( 'Rast1Frame', // debug
//    Format( '*MouseDown in Rast1Frame %s (%d) Cur=%d,%d', [RFDebName, N_MEGlobObj.GlobCounter, X, Y] ));

  if X = -1 then
  begin
    N_Dump1Str( Format( '!!!!! RFr=?? PBMDown %d,%d, %x', [X,Y,PByte(@Shift)^] ));
    Exit;
  end;

  if N_AppSkipEvents and not RFEnableEvents then Exit; // Skip event

  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s PBMDown %d,%d, %x', [RFDebName,X,Y,PByte(@Shift)^] ));


  if RFFullScreenMode = 1 then
  begin
//    if Assigned( N_StringDumpProcObj ) then N_StringDumpProcObj( 'Rast1Frame', '*MouseDown in RFFullScreenMode in ' + RFDebName );

//    if close Parent Form on MouseDown, then MouseUp event will be executed by
//    already destroyed Frame (Windows or Delphi error) and this cause (not always) errors
//    So, just set a flag (RFFullScreenMode=2), that Parent Form should be destroyed by next MouseUp

    RFFullScreenMode := 2;
    Exit;
  end;

  CMPos     := Point( X, Y ); // Current Mouse Position
  CMButton  := Button;        // Current Mouse Button
  CMKShift  := Shift;         // Current Shift State
  CHType    := htMouseDown;   // Handler Type
  LastCHType:= CHType;
  LastMDownPos := CMPos;      // Last Mouse Down Position

  if Assigned(OnMouseDownProcObj) then
    OnMouseDownProcObj( Sender, Button, Shift, X, Y );

  K_GetParentForm( Self ).ActiveControl := Self; // stop ScrollBars blinking
//  K_GetOwnerForm( Owner ).ActiveControl := Self; // stop ScrollBars blinking

  if SkipMouseDown then // nothing todo just after DblClick (?)
  begin
    SkipMouseDown := False;
    Exit;
  end;

  if N_MEGlobObj.UCoordsToClipbrd then // Copy User Coords to Clipboard
  begin
    Clipboard.SetTextBuf( PChar(Format( '%.3f %.3f', [CCUser.X, CCUser.Y] )));
  end;

  RFExecAllSGroupsActions();
  CHType := htNotDef;
  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s PBMDown Finished', [RFDebName] ));
end; // end of procedure TN_Rast1Frame.PaintBoxMouseDown

//***************************************** TN_Rast1Frame.PaintBoxMouseMove ***
// OnMouseMove PaintBox event handler
//
procedure TN_Rast1Frame.PaintBoxMouseMove( Sender: TObject;
                                           Shift: TShiftState; X,Y: Integer);
var
  TmpStr: string;
begin
//  N_IAdd( Format( '(%d,%d) Prev=%d,%d  Cur=%d,%d', [N_MEGlobObj.GlobCounter, // debug
//                     integer(SkipMouseMove), CCPrevCMPos.X, CCPrevCMPos.Y, X, Y] ));

  if X = -1 then
  begin
    N_Dump1Str( Format( '!!!!! RFr=?? PBMMove %d,%d, %x', [X,Y,PByte(@Shift)^] ));
    Exit;
  end;

  if OCanv = nil then
    TmpStr := '(OCanv = nil)'
  else
    TmpStr := '';

  if RFDumpMoveEvents then N_Dump2Str( Format( 'RFr %s PBMMove %d,%d, %x %s', [RFDebName,X,Y,PByte(@Shift)^,TmpStr] ));

  if N_AppSkipEvents and not RFEnableEvents then Exit; // Skip event


//  if Assigned( N_StringDumpProcObj ) then N_StringDumpProcObj( 'Rast1Frame',
//    Format( '*MouseMove in Rast1Frame %s (%d) Cur=%d,%d', [RFDebName, N_MEGlobObj.GlobCounter, X, Y] ));

  if (RVCTreeRoot <> nil) and  // already initialized (RVCTreeRoot can be nil if not set yet)
     (NGlobCont   <> nil) then // NGlobCont can be nil if drawing not a Component
      RVCTreeRoot.NGCont := NGlobCont;  // Same Component can be drawn in different frames with different GlobContexts!

  if SkipMouseMove then // nothing todo just after changing cursor coords programmaticaly
  begin
    SkipMouseMove := False;
    Exit;
  end;

  CMPos     := Point( X, Y ); // Current Mouse Position (in PaintBox Coords)
  CMKShift  := Shift;         // Current Mouse and keyboard Shift State
  CHType    := htMouseMove;   // Current Handler Type
  LastCHType:= CHType;

  CCDst := CMPos; // Destination PaintBox Pixel coords

  // CCBufD - MainBuf Pixel Double coords (0,0) is OCanv.CurCRect.TopLeft,
  //          not Visible Rect RFSrcPRect.TopLeft!,
  //          (0-1) CCBufD interval maps to CCBuf=0 pixel

  CCBufD.X := ( X - RFDstPRect.Left + 0.5 ) / RFRasterScale + RFSrcPRect.Left;
  CCBufD.Y := ( Y - RFDstPRect.Top  + 0.5 ) / RFRasterScale + RFSrcPRect.Top;

  if OCanv = nil then Exit; // some events may occure after call to RFFreeObjects

  // Not Snapped User Coords ( P2U works OK for integer -> float convertion)
  CCUserNS.X := OCanv.P2U.CX*(CCBufD.X-0.5) + OCanv.P2U.SX;
  CCUserNS.Y := OCanv.P2U.CY*(CCBufD.Y-0.5) + OCanv.P2U.SY;

  // CCUser is Snapped User Coords
  CCUser := N_SnapPointToGrid( CCUserSGridOrigin, CCUserSGridStep, CCUserNS );

  CCBufD.X := OCanv.U2P.CX * CCUser.X + OCanv.U2P.SX + 0.5;
  CCBufD.Y := OCanv.U2P.CY * CCUser.Y + OCanv.U2P.SY + 0.5;

  CCBuf.X := Round(Floor(CCBufD.X));
  CCBuf.Y := Round(Floor(CCBufD.Y));
{
  Inc(N_MEGlobObj.GlobCounter);
  N_IAdd( Format( '(%d) Dst=%d,%d  Buf=%d,%d  BufD=%.2f,%.2f DPL,SPL,U=%d, %d, %.2f',
         [N_MEGlobObj.GlobCounter, CCDst.X, CCDst.Y, CCBuf.X, CCBuf.Y,
          CCBufD.X, CCBufD.Y, RFDstPRect.Left, RFSrcPRect.Left, CCUser.X ]));
}

  if not (rfafSearchInActive in RFrActionFlags) or
     (N_ActiveRFrame = Self) then
  begin
    SearchInAllGroups();
  end;

  RFExecAllSGroupsActions();
  CHType := htNotDef;
  if RFDumpMoveEvents then N_Dump2Str( Format( 'RFr %s PBMMove Finished', [RFDebName] ));
end; // end of procedure TN_Rast1Frame.PaintBoxMouseMove

//******************************************* TN_Rast1Frame.PaintBoxMouseUp ***
// OnMouseUp PaintBox event handler
//
procedure TN_Rast1Frame.PaintBoxMouseUp( Sender: TObject;
                   Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  if Assigned( N_StringDumpProcObj ) then N_StringDumpProcObj( 'Rast1Frame',
//    Format( '*MouseUp in Rast1Frame %s (%d) Cur=%d,%d', [RFDebName, N_MEGlobObj.GlobCounter, X, Y] ));

  if X = -1 then
  begin
    N_Dump1Str( Format( '!!!!! RFr=?? PBMUp %d,%d, %x', [X,Y,PByte(@Shift)^] ));
    Exit;
  end;

  if N_AppSkipEvents and not RFEnableEvents then Exit; // Skip event

  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s PBMUp %d,%d, %x', [RFDebName,X,Y,PByte(@Shift)^] ));

  if RFFullScreenMode = 2 then // this value was set in OnMouseDown event
  begin
//    if Assigned( N_StringDumpProcObj ) then N_StringDumpProcObj( 'Rast1Frame', '*MouseUp in RFFullScreenMode in ' + RFDebName );
//    K_GetOwnerForm( Owner ).Close;
    K_GetParentForm( Self ).Close;
    Exit;
  end;

  if N_AppSkipEvents and not RFEnableEvents then Exit; // Skip event

//  if RBufIsNotReady then Exit; // needed in initialization
  MouseDownTimerState := 0;
  RepeatMouseDown.Enabled := False; // stop repeating MouseDown events

  K_GetParentForm( Self ).ActiveControl := Self; // stop ScrollBars blinking
  CMPos  := Point( X, Y ); // Current Mouse Position
  CMButton  := Button;     // Current Mouse Button
  CMKShift  := Shift;      // Current Shift State
  CHType    := htMouseUp;  // Handler Type
  LastCHType:= CHType;

  if Assigned(OnMouseUpProcObj) then
    OnMouseUpProcObj( Sender, Button, Shift, X, Y );

  RFExecAllSGroupsActions();
  CHType := htNotDef;
  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s PBMUp Finished', [RFDebName] ));
end; // end of procedure TN_Rast1Frame.PaintBoxMouseUp

//****************************************** TN_Rast1Frame.PaintBoxDblClick ***
// OnDblClick PaintBox event handler
//
procedure TN_Rast1Frame.PaintBoxDblClick( Sender: TObject );
begin
//  if Assigned( N_StringDumpProcObj ) then N_StringDumpProcObj( 'Rast1Frame',
//    Format( '*MouseDblClick in Rast1Frame %s (%d) Cur=%d,%d', [RFDebName, N_MEGlobObj.GlobCounter, CMPos.X, CMPos.Y] ));

  if N_AppSkipEvents and not RFEnableEvents then Exit; // Skip event

  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s PBDblClick', [RFDebName] ));

  CHType     := htDblClick;   // Handler Type
  LastCHType := CHType;

  if rfafFScreenByDClick in RFrActionFlags then
  begin
    aFullScreenExecute( Sender );
    Exit;
  end;

  RFExecAllSGroupsActions();
  CHType := htNotDef;
  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s PBDblClick Finished', [RFDebName] ));
end; // end of procedure TN_Rast1Frame.PaintBoxDblClick

//******************************************* TN_Rast1Frame.FrameMouseWheel ***
// OnMouseWheel Self(Frame) event handler (PaintBox has no such an event)
//
procedure TN_Rast1Frame.FrameMouseWheel( Sender: TObject; Shift: TShiftState;
                    WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean );
begin
{
var
  ScreenRect: TRect;
  ScreenRect := N_GetScreenRectOfControl( Self );
  if 0 <> N_PointInRect( Mouse.CursorPos, ScreenRect ) then Exit;
}
  if N_AppSkipEvents and not RFEnableEvents then Exit; // Skip event

  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s FrMWheel', [RFDebName] ));

  CMPos      := MousePos;     // Current Mouse Position
  CMWheel    := WheelDelta;   // Current Mouse WheelDelta
  CMKShift   := Shift;        // Current Shift State
  CHType     := htMouseWheel; // Handler Type
  LastCHType := CHType;
  Handled    := True;

  RFExecAllSGroupsActions();
  CHType := htNotDef;
  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s FrMWheel Finished', [RFDebName] ));
end; // procedure TN_Rast1Frame.FrameMouseWheel

//********************************************* TN_Rast1Frame.CallMouseDown ***
// Call PaintBoxMouseDown with same arguments except cursor position
// (RepeatMouseDown OnTimer Event Handler)
//
procedure TN_Rast1Frame.CallMouseDown( Sender: TObject );
begin
  RepeatMouseDown.Enabled := False; // disable Timer while long Drawing

  with PaintBox.ScreenToClient( Mouse.CursorPos ) do
    PaintBoxMouseDown( nil, CMButton, CMKShift, X, Y );

  RepeatMouseDown.Enabled := True;
  RepeatMouseDown.Interval := 70; // small interval between subsequent calls
end; // procedure TN_Rast1Frame.CallMouseDown


//********** TN_Rast1Frame class Public methods  **************

//**************************************************** TN_Rast1Frame.Create ***
//
constructor TN_Rast1Frame.Create( AOwner: TComponent );
var
  ZeroGroup: TN_SGBase;
begin
  Inherited;

//  RFPaddings := Rect( 10, 20, 30, 40 ); // debug
  OCanv := TN_OCanvas.Create();
  RFRasterScale := 1;
  RFVectorScale := 1;
  RFMaxVectorScale := N_RFMaxVectorScale; // set default value
  RFMinRelObjSize  := N_RFMinRelObjSize;  // set default value
  RFMaxRelObjSize  := N_RFMaxRelObjSize;  // set default value
  RFMaxBufSizeMB   := N_RFMaxBufSizeMB;   // set default value
  RFInterfaceFlags := [rfifShiftAtZoom]; // [];
  SkipOnResize := True;
  SkipOnPaint  := True;
  ShowPixelColor := False;
  PointCoordsFmt := 'X,Y= %.4f, %.4f';
  RectCoordsFmt := 'R= (%.2f,%.2f) (%.2f,%.2f)';

//  PointPixCoordsFmt  := 'X,Y(p)= %d, %d';
//  PointUserCoordsFmt := 'X,Y(u)= %.*f, %.*f';
//  PointApplCoordsFmt := 'X,Y(a)= %.*f, %.*f';
//  RectPixCoordsFmt   := 'R(p)= (%d, %d) - (%d, %d)   of   (%d, %d) - (%d, %d)';
//  RectUserCoordsFmt  := 'R(u)= (%.*f, %.*f) - (%.*f, %.*f)   of   (%.*f, %.*f) - (%.*f, %.*f)';
//  RectApplCoordsFmt  := 'R(a)= (%.*f, %.*f) - (%.*f, %.*f)   of   (%.*f, %.*f) - (%.*f, %.*f)';
//  ShowCoordsType := cctDstPix;
//  ShowCoordsType := cctUser;
  ShowCoordsType := cctmm;
//  UCAccuracyFmt := 2;
//  ACAccuracyFmt := 2;
  DstBackColor := $DDDDDD;
//  DstBackColor := $DD; // for debug
  RFStretchBltMode := COLORONCOLOR;
//  RFStretchBltMode := HALFTONE;
//  SetStretchBltMode( PaintBox.Canvas.Handle, RFStretchBltMode );

  OCanvBackColor := N_EmptyColor;
//  CenterInDst := True;
  ResizeFlags := 2;
  MeshEnabled := True;
//  RFDebugFlags := $04;
//  DebugFlags := $03; // debug
  RFClearFlags := $3;
  MinMeshStep := 5;
  RFSGroups := TObjectList.Create;

  //***** Create ZeroGroup for Showing Coords and Zooming

  ZeroGroup := TN_SGBase.Create( Self ); // would be destroyed RFFreeObjects method
  RFSGroups.Add( ZeroGroup );
  with ZeroGroup do
  begin
    GName := 'ZeroGroup';
    SetAction( N_ActDebAction1,  $04 );
//    SetAction( N_ActShowColor,   $02 );
    RFMouseAction := SetAction( N_ActMouseAction, $02 );
    RFRubberRectAction := SetAction( N_ActRubberRect, $00 );
    TN_RubberRectRFA(RFRubberRectAction).ActEnabled := False;

    SetAction( N_ActShowAction,  $01 );
    SetAction( N_ActZoom, $00 ).ActEnabled := False;
  end; // with ZeroGroup do

//  OCanv.NativeWidePen := True; //!! debug
  N_RFrameDeb := Self;
  FrU2A := N_DefAffCoefs4;
  RFrActionFlags := [rfafShowColor, rfafShowCoords, rfafSmartUScale]; // rfafScrollCoords,
//  RFrActionFlags := [rfafShowColor, rfafScrollCoords, rfafResizeOnlyPBox];

  RFrResizeFlags := [rfrfScaleIfWhole,rfrfBufEqFrame];
  RFVectorScaleStep := 1.05;
//  RFCRectSizeCoef   := 1.0;
//  RFCRectSizeCoef   := 1.5;
  RFCRectSizeCoef   := 1.5;

  RFResizeProcObj := RFResizeSelf; // Standard OnResize Handler
  RFDebName := Name;
end; //*** end of Constructor TN_Rast1Frame.Create

//********************************************** TN_Rast1Frame.WMEraseBkgnd ***
// prevent processing Windows message EraseBkgnd (Erase Background)
// ( can be used because whole Frame is redrawn manualy,
//   if absent - causes flicker while updating (redrawing) Frame )
//
procedure TN_Rast1Frame.WMEraseBkgnd( var m: TWMEraseBkgnd );
begin
  m.Result := LRESULT(False); // disable drawing background
//  m.Result := LRESULT(True); // enable drawing background (default value)
end; // end of procedure TN_Rast1Frame.WMEraseBkgnd

//************************************************* TN_Rast1Frame.WMKeyDown ***
// OnKeyDown Windows (not Delphi) event handler
// Remarks:
// 1) Delphi has no KeyDown event for PaintBox, so WMKeyDown should be used
// 2) Delphi does not generate any events on Arrow and Tab Keys (even for
//    TForm), so TForm.WndProc should be used to process Arrow and Tab Keys
//    (TForm.WndProc should call this handler for Arrow and Tab Keys)
//
procedure TN_Rast1Frame.WMKeyDown( var m: TWMKey );
var
  n1, n2: integer;
  CtrlIsDown: boolean;
  IChar: Word;
  Str1, Str2: string;
//  Keys: TKeyboardState;
begin
//  N_b := GetKeyboardState( Keys ); // debug (exec time about 5-8 mcsec., for GetKeyState - 0.1 mcsec/)

  if (N_AppSkipEvents and not RFEnableEvents) then Exit; // Skip event

  IChar := m.CharCode; // just to simplify code
  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s WMKeyDown: %s %d $%.4x', [RFDebName, Char(IChar), IChar, IChar] ));

  if Assigned(OnWMKeyDownProcObj) then
    OnWMKeyDownProcObj( m );

  if (RFDebugFlags and $40000000) <> 0 then
    N_IAdd( Format( 'RFrame WMKeyDown CharCode:(%s %d $%.4x), KeyData:%.8x',
                           [Char(IChar), IChar, IChar, m.KeyData] )); // debug

//    ShowMainBuf(); // Debug
//  N_IAdd( Format( 'CapsLock=%4X', [getKeyState( 20 )] )); // debug

  if ((m.KeyData and $40000000) <> 0) and // skip autorepeat events for all Keys
     (IChar < $28) and (IChar > $25) then // except four Arrow Keys
    Exit;

  CHType    := htKeyDown;  // Handler Type
  LastCHType:= CHType;
  CKey      := m;          // Current Key Pressed
  CMKShift  := [];         // it should be set by hands

  if (Windows.GetKeyState(VK_SHIFT)   and $8000) <> 0 then CMKShift := CMKShift + [ssShift];
  if (Windows.GetKeyState(VK_CONTROL) and $8000) <> 0 then CMKShift := CMKShift + [ssCtrl];
  if (Windows.GetKeyState(VK_MENU)    and $8000) <> 0 then CMKShift := CMKShift + [ssAlt];

//  if (IChar = 16) and   // Shift key is Down for the first time
//     ((m.KeyData and $40000000) = 0) then

//  if (IChar = 17) and   // Ctrl key is Down for the first time
//     ((m.KeyData and $40000000) = 0) then CMKShift := CMKShift + [ssCtrl];

  CtrlIsDown := ssCtrl in CMKShift; // to reduce code

  if RFFullScreenMode <> 0 then
  begin
//    K_GetOwnerForm( Owner ).Close;
    K_GetParentForm( Self ).Close;
    Exit;
  end;

//  if (Char(IChar) = 'F') and CtrlIsDown then // Ctrl+F
//    aInitFrameExecute( nil );

//  if (Char(IChar) = 'O') and CtrlIsDown then // Ctrl+O
//    ShowRFOpFormExecute( nil );

  if (Char(IChar) = 'T') and CtrlIsDown and (SomeStatusbar <> nil) then // Ctrl+T
    N_IAdd( SomeStatusbar.SimpleText );

  if (Char(IChar) = 'P') and CtrlIsDown and (SomeStatusbar <> nil) then // Ctrl+P
  // Copy to Clipboard current Cursor coords (space delimited)
  begin
    Str1 := SomeStatusbar.SimpleText; // like 'X,Y(u)= 0.4160, 0.3957'
    n1 := Pos( '=', Str1 );
    n2 := Pos( ', ', Str1 );
    Str2 := Copy( Str1, n1+1, n2-n1-1 ) + ' ' + Copy( Str1, n2+2, 100 );
    Clipboard.SetTextBuf( PChar(Str2) );
  end;

  if rfafZoomByPMKeys in RFrActionFlags then // Zoom by "+" and '-' keys
  begin
    if (IChar = $6B) or (IChar = $BB) then // '+' key (main or NumPad)
    begin
      aZoomInExecute( nil );
      Exit;
    end;

    if (IChar = $6D) or (IChar = $BD) then // '-' key (main or NumPad)
    begin
      aZoomOutExecute( nil );
      Exit;
    end;
  end; // if rfafZoomByPMKeys in RFrActionFlags then // Zoom by "+" and '-' keys

  if (IChar = 221) and CtrlIsDown then // Ctrl+} ( "}" is + "}]ú" key )
    RFDebugFlags := RFDebugFlags xor $40000000;

  RFExecAllSGroupsActions();
  CHType := htNotDef;
  // ShowMainBuf(); // debug
end; // end of procedure TN_Rast1Frame.WMKeyDown

//*************************************************** TN_Rast1Frame.WMKeyUp ***
// OnKeyUp Windows (not Delphi) event handler
// ( Delphi has no KeyUp event for PaintBox )
//
procedure TN_Rast1Frame.WMKeyUp( var m: TWMKey );
var
  IChar: Word;
begin
  if (N_AppSkipEvents and not RFEnableEvents) then Exit; // Skip event

  IChar := m.CharCode; // just to simplify code
  if RFDumpEvents then N_Dump2Str( Format( 'RFr %s WMKeyUp: %s %d $%.4x', [RFDebName, Char(IChar), IChar, IChar] ));

//  N_IAdd( Format ( 'WMKeyUp   CharCode:(%s) %d ($%.4x), KeyData:%.8x',
//        [Char(IChar), IChar, IChar, m.KeyData] )); // debug

  CHType    := htKeyUp;  // Handler Type
  LastCHType:= CHType;
  CKey      := m;        // Current Key Released
  CMKShift  := [];         // it should be set by hands

  if (Windows.GetKeyState(VK_SHIFT)   and $8000) <> 0 then CMKShift := CMKShift + [ssShift];
  if (Windows.GetKeyState(VK_CONTROL) and $8000) <> 0 then CMKShift := CMKShift + [ssCtrl];

//  if (IChar = 16) then CShiftIsDown := False; // Shift key is Up
//  if (IChar = 17) then CCtrlIsDown  := False; // Ctrl  key is Up

  RFExecAllSGroupsActions();

  CHType := htNotDef;
  CKey.CharCode := 0; // clear Key info ( CKey.CharCode <> 0 only between
                      // KeyDown and KeyUp events )
end; // end of procedure TN_Rast1Frame.WMKeyUp

{
//*************************************************** TN_Rast1Frame.WndProc ***
// Own Window Proc, needed for debug
//
procedure TN_Rast1Frame.WndProc( var Msg: TMessage );
begin
  if Msg.Msg = WM_KEYDOWN then
  begin
    N_IAdd( Format( 'RFrame WndProc KeyDown: %.8x,  %.8x', [Msg.WParam, Msg.LParam] ) );
  end else
  if Msg.Msg = WM_KEYUP then
  begin
    N_IAdd( Format( 'RFrame WndProc: KeyUp %.8x,  %.8x', [Msg.WParam, Msg.LParam] ) );
  end else
    Inherited WndProc( Msg );
end; // procedure TN_Rast1Frame.WndProc
}

//******************************************* TN_Rast1Frame.OnActivateFrame ***
// Set N_ActiveRFrame variable
// (should be called from ParentForm.OnActivate event handler)
//
procedure TN_Rast1Frame.OnActivateFrame();
begin
  N_ActiveRFrame := Self;
//  K_GetOwnerForm( Owner ).ActiveControl := Self;
  if Assigned(RFOnScaleProcObj) then RFOnScaleProcObj( Self );
end; //*** end of procedure TN_Rast1Frame.OnActivateFrame

//********************************************* TN_Rast1Frame.RFFreeObjects ***
// Free all owned by Self objects (instead of Self.Destructor)
// (should be called from ParentForm.OnClose event handler)
//
procedure TN_Rast1Frame.RFFreeObjects();
begin
//  N_IAdd( 'Close: ' + K_GetOwnerForm( Owner ).Caption ); // debug
//  N_IAdd( 'Close(NGlobCont): ' + IntToHex(integer(NGlobCont),6) ); // debug
  FreeAndNil( NGlobCont );

  if RVCTreeRoot <> nil then
  begin
    if RVCTreeRootOwner then RVCTreeRoot.UDDelete;
  end;

  RVCTreeRootOwner := False;
  RVCTreeRoot := nil;

  if OCanv <> nil then
  begin
    Dec(OCanv.RFrameCounter);
    if OCanv.RFrameCounter = 0 then FreeAndNil( OCanv ); // RFrames are OCanv Owners
  end;

  if UCObjEdForm <> nil then
  begin
    UCObjEdForm.Close();
    UCObjEdForm := nil;
  end;

  FreeAndNil( RFSGroups );

  // Clear N_ActiveRFrame variable if it points to self
  if N_ActiveRFrame = Self then N_ActiveRFrame := nil;
end; //*** end of procedure TN_Rast1Frame.RFFreeObjects

//************************************************* TN_Rast1Frame.ClearBufs ***
// Clear PaintBox and MainBuf by DstBackColor
//
procedure TN_Rast1Frame.ClearBufs();
begin
  if Self = nil then exit;

  N_DrawFilledRect( OCanv.HMDC, OCanv.CurCRect, OCanvBackColor );
  N_DrawFilledRect( PaintBox.Canvas.Handle, PaintBox.ClientRect, DstBackColor );
end; //*** end of procedure TN_Rast1Frame.ClearBufs

//*********************************************** TN_Rast1Frame.ShowMainBuf ***
// Copy MainBuf RFSrcPRect to PaintBox RFDstPRect
// (is called from PaintBox OnPaint event handler or after MainBuf changed)
//
procedure TN_Rast1Frame.ShowMainBuf();
var
  i, NDstBackRects: integer;
  ADstBackRects: TN_IRArray; // Dst Background Rects (DstMaxPRect-RFDstPRect)
begin
  if (RFSrcPRect.Right = 0) and (RFSrcPRect.Bottom = 0) then // not initialized
    N_DrawFilledRect( PaintBox.Canvas.Handle, PaintBox.ClientRect, DstBackColor )
  else // normal drawing
  begin
    N_StretchRect( PaintBox.Canvas.Handle, RFDstPRect, OCanv.HMDC, RFSrcPRect );

    SetLength( ADstBackRects, 4 );
    NDstBackRects := N_IRectSubstr( ADstBackRects, PaintBox.ClientRect, RFDstPRect );

    for i := 0 to NDstBackRects-1 do
      N_DrawFilledRect( PaintBox.Canvas.Handle, ADstBackRects[i], DstBackColor );
  end; // else // normal drawing
end; //*** end of procedure TN_Rast1Frame.ShowMainBuf

//********************************************** TN_Rast1Frame.ShowInvRects ***
// Show only Invalidated MainBuf Rects (instead of whole MainBuf),
// is called while animation to speedup normal ShowMainBuf procedure
//
procedure TN_Rast1Frame.ShowInvRects();
var
  DX, DY: integer;
begin
  if RFRasterScale = 1.0 then
  begin
    DX := RFDstPRect.Left - RFSrcPRect.Left; // shift between Dst and
    DY := RFDstPRect.Top  - RFSrcPRect.Top;  //   Self Pixel coords
    N_CopyRects( PaintBox.Canvas.Handle, OCanv.HMDC, OCanv.InvRects,
                                                OCanv.NumInvRects, DX, DY );
  end else
  begin // temporary copy whole RFSrcPRect
    N_StretchRect( PaintBox.Canvas.Handle, RFDstPRect, OCanv.HMDC, RFSrcPRect );
  end;
end; //*** end of procedure TN_Rast1Frame.ShowInvRects

//********************************************** TN_Rast1Frame.ShowNewPhase ***
// show new animation phase from MainBuf and
// remove first PrevNumInvRects Rects of InvRects
//
procedure TN_Rast1Frame.ShowNewPhase();
begin
  ShowInvRects();

  with OCanv do
  begin
    if PrevNumInvRects > 0 then
      N_RemoveRects( InvRects, NumInvRects, 0, PrevNumInvRects-1 );
    CollectInvRects := False;
  end;
end; //*** end of procedure TN_Rast1Frame.ShowNewPhase

//******************************************* TN_Rast1Frame.StartAnimPhase1 ***
// Start animation phase, variant 1
//
procedure TN_Rast1Frame.StartAnimPhase1();
begin
  with OCanv do
  begin
    if HBDC = 0 then
    begin
      CreateBackBuf();
      CopyWholeToBack();
    end;

    CollectInvRects := True;
  end;
end; //*** end of procedure TN_Rast1Frame.StartAnimPhase1

//********************************************* TN_Rast1Frame.FinAnimPhase1 ***
// Finish animation phase, variant 1
//
procedure TN_Rast1Frame.FinAnimPhase1();
begin
  ShowInvRects(); // clear previous phase and show new phase in PaintBox

  with OCanv do
  begin
    CopyInvRectsToMain(); // clear new phase in MainBuf

    if PrevNumInvRects > 0 then // remove previous phase Rects (from 0 to PrevNumInvRects-1)
      N_RemoveRects( InvRects, NumInvRects, 0, PrevNumInvRects-1 );

    CollectInvRects := False;
  end;
end; //*** end of procedure TN_Rast1Frame.FinAnimPhase1

//********************************************** TN_Rast1Frame.FinAnimation ***
// Finish animation
//
procedure TN_Rast1Frame.FinAnimation();
begin
  ShowMainBuf();

  with OCanv do
  begin
    NumInvRects     := 0;
    PrevNumInvRects := 0;
    CollectInvRects := False;
  end;
end; //*** end of procedure TN_Rast1Frame.FinAnimation

//******************************************* TN_Rast1Frame.InitByFullURect ***
// Init Self, OCanv for showing given AFullURect in current Self Size
//
procedure TN_Rast1Frame.InitByFullURect( AFullURect: TFRect );
var
  PixSize: TPoint;
begin
  RFRasterScale := 1;
  VScrollBar.Visible := False;
  HScrollBar.Visible := False;
  PixSize := Point( PaintBox.ClientWidth, PaintBox.ClientHeight );
  RFSrcPRect := IRect( PixSize );
  OCanv.SetCurCRectSize( PixSize.X, PixSize.Y );
  RFDstPRect := RFSrcPRect;
  OCanv.SetIncCoefsAndUCRect( AFullURect, RFSrcPRect );
//  OCanvMaxURect := AFullURect;
end; // procedure TN_Rast1Frame.InitByFullURect

//************************************************* TN_Rast1Frame.PrepOCanv ***
// Prepare Ocanv Raster Buffers by given AWholePRect and AVisPRectR,
// claculate and set RFLogFramePRect and RFSrcPRect,
// given AWholePRect can be decreased (by decreasing RFVectorScale) if it is too big
//
// AWholePRect - Whole Pix Rect - new RFLogFramePRect should have same Size
// AVisRectR   - Visible Rect in AWholePRect (in Relative Coords)
//                  ( AVisPRectR.TopLeft means RFLogFramePRect.TopLeft )
//
// OCanc.CurCRect, RFLogFramePRect, RFSrcPRect are calculated and set
// Current value of RFLogFramePRect is used to check if current OCanv.CurCRect
//   contains needed visible Rect
//
// Return True if Buf should be redrawn
//
function TN_Rast1Frame.PrepOCanv( const AWholePRect, AVisPRectR: TRect ): boolean;
var
  dx, dy: integer;
  WholePRectSize, NewCCRSize: TPoint;
  TmpVisRect, TmpCRect: TRect;
begin
  // Push AVisPRectR inside AWholePRect
  TmpVisRect := N_RectAdjustByMaxRect( AVisPRectR, AWholePRect );

  // Check if Redrawing can be avoided - Check if current RFLogFramePRect has
  // same size as given AWholePRect and given AVisRectRP (properly shifted)
  // is inside current OCanv.CurCRect

  WholePRectSize := IPoint( AWholePRect );
  if N_Same( IPoint(RFLogFramePRect), WholePRectSize ) then // Same Size, same RFVectorScale
  begin                      // Convert TmpVisRect to current RFLogFramePRect coords space
    RFSrcPRect := N_RectShift( TmpVisRect, RFLogFramePRect.Left - AWholePRect.Left,
                                           RFLogFramePRect.Top  - AWholePRect.Top );


    //*** Check if All done: OCanv and RFLogFramePRect remains the same, RFSrcPRect is set OK
    if $0F = ($0F and N_RectCheckPos( OCanv.CurCRect, RFSrcPRect )) then
    begin
      Result := False; // Redrawing is not needed
      Exit;
    end;
  end; // Same Size

  //***** Here: RFVectorScale changed or
  //            needed RFSrcPRect is not visible (inside OCanv.CurCRect)

  Result := True; // Redrawing is needed

  //*** Cacl new OCanv.CCRSize, all Rects coords below are relative to AWholePRect

  TmpCRect := N_RectScaleR( TmpVisRect, RFCRectSizeCoef, DPoint(0.5,0.5) );

  //*** Adjust TmpCRect: it should be inside AWholePRect
  TmpCRect := N_RectAdjustByMaxRect( TmpCRect, AWholePRect );

  NewCCRSize := IPoint( TmpCRect );
  OCanv.SetCurCRectSize( NewCCRSize.X, NewCCRSize.Y, pfDevice );

  dx := -TmpCRect.Left;
  dy := -TmpCRect.Top;

  RFSrcPRect      := N_RectShift( TmpVisRect,  dx, dy );
  RFLogFramePRect := N_RectShift( AWholePRect, dx, dy );
end; // function TN_Rast1Frame.PrepOCanv

//******************************************* TN_Rast1Frame.ShiftRFSrcPRect ***
// Shift (Set) RFSrcPRect by given ANewTopLeftRel
//
// ANewTopLeftRel - new RFSrcPRect.TopLeft coords, relative to current RFLogFramePRect
//                  ( =(0,0) means that upper left corner is visible )
//
procedure TN_Rast1Frame.ShiftRFSrcPRect( ANewTopLeftRel: TPoint );
var
  BufChanged: boolean;
  CurVisSize: TPoint;
  NewVisRect: TRect;
begin
//  N_ir := RFDstPRect; // debug
  CurVisSize := IPoint( RFSrcPRect );
  NewVisRect := N_RectMake( ANewTopLeftRel, CurVisSize, N_ZDPoint ); // in Relative coords
  NewVisRect := N_RectShift( NewVisRect, RFLogFramePRect.TopLeft );  // in Abs coords

  BufChanged := PrepOCanv( RFLogFramePRect, NewVisRect );
  if BufChanged then Redraw();

  N_SetScrollBarsByRects( RFLogFramePRect, RFSrcPRect, HScrollBar, VScrollBar );

  if Assigned( RFOnScrollProcObj ) then RFOnScrollProcObj( Self );

  SearchInAllGroups();
  RedrawAllSGroupsActions();
//  N_ir := RFDstPRect; // debug
  ShowMainBuf();
end; // procedure TN_Rast1Frame.ShiftRFSrcPRect

//********************************************** TN_Rast1Frame.SetZoomLevel ***
// Set Zoom Level by given params and current RFVectorScale, RFRasterScale
// Return True if Buf should be redrawn
//
// AZFlags     - Zoom Flags
//
function TN_Rast1Frame.SetZoomLevel( AZoomMode: TN_RFZoomMode ): boolean;
var
  DstWidth,  DstWidth1,  DstWidth2,  PBWidth: integer;
  DstHeight, DstHeight1, DstHeight2, PBHeight: integer;
  NeededDstWidth,  NeededDstHeight: Int64;
  BufPix, MinVScale, MaxVScale: double;
  HorVis, VertVis, RedrawNeeded: boolean;
  NewLFRPSize, NewSrcPRecSize, MouseClient: TPoint;
  NewCCBufD: TDPoint;
  Center, LFNormObjPoint, NewLFRelObjPoint, SPRNormObjPoint: TDPoint;
  PaintBoxRect, NewLFPRect, NewRelSrcPRect: TRect;
  CurZoomMode: TN_RFZoomMode;
begin
  Result := True; // temporary, not used now

  CurZoomMode := AZoomMode;

  MouseClient := ScreenToClient( Mouse.CursorPos );

  if 0 <> N_PointInRect( MouseClient, RFDstPRect ) then // Cursor is out of RFDstPRect
    if CurZoomMode <> rfzmUpperleft then
      CurZoomMode := rfzmCenter;

  // Calc max possible Dst (PaintBox) Size:
  //   if if both scrollbars are not visible - DstWidth1, DstHeight1
  //   if if both scrollbars are visible     - DstWidth2, DstHeight2

  DstWidth1  := Self.Width  - RFPaddings.Left - RFPaddings.Right;
  DstHeight1 := Self.Height - RFPaddings.Top  - RFPaddings.Bottom;

  DstWidth2  := DstWidth1  - VScrollBar.Width;
  DstHeight2 := DstHeight1 - HScrollBar.Height;

  // Correct RFVectorScale according to several restrictions
  // ( RFMaxVectorScale, RFMinRelObjSize, RFMaxRelObjSize, RFMaxBufSizeMB )

  if (RFObjSize.Y / RFObjSize.X) > (1.0*DstHeight1 / DstWidth1) then // Aspect(ObjSize) > ASpect(DstPRect)
  begin
    MaxVScale := (DstHeight1 * RFMaxRelObjSize) / (RFObjSize.Y * RFRasterScale);
    MinVScale := (DstHeight1 * RFMinRelObjSize) / (RFObjSize.Y * RFRasterScale);
  end else
  begin
    MaxVScale := (DstWidth1 * RFMaxRelObjSize) / (RFObjSize.X * RFRasterScale);
    MinVScale := (DstWidth1 * RFMinRelObjSize) / (RFObjSize.X * RFRasterScale);
  end;

  RFVectorScale := min( RFVectorScale, RFMaxVectorScale );
  RFVectorScale := min( RFVectorScale, MaxVScale );
  RFVectorScale := max( RFVectorScale, MinVScale );

  MaxVScale := Sqrt( 1.0*1024*1024*RFMaxBufSizeMB/(3*RFObjSize.X*RFObjSize.Y) );
  if RFVectorScale > MaxVScale then // too big RFVectorScale (too big OCanv BufSize)
  begin
    if Assigned(RFOnMaxVSProcObj) then
      RFOnMaxVSProcObj( @Self, MaxVScale ); // notify about too big RFVectorScale

    RFVectorScale := MaxVScale;
  end; // if RFVectorScale > MaxVScale then // too big RFVectorScale (too big OCanv BufSize)


  // RFVectorScale is now OK

  // NewLFRPSize - New LogFrame Rect Pixel Size
  NewLFRPSize.X := Round( RFObjSize.X * RFVectorScale );
  NewLFRPSize.Y := Round( RFObjSize.Y * RFVectorScale );
  NewLFPRect := IRect( NewLFRPSize ); // New LogFrameRect, temporary with UpperLeft = (0,0)

  if RFRasterScale >= MinMeshStep then RFRasterScale := Round( RFRasterScale );

  //*********** Calc max needed Dst size to contain full LogFrame Rect
  NeededDstWidth  := Round( NewLFRPSize.X * RFRasterScale );
  NeededDstHeight := Round( NewLFRPSize.Y * RFRasterScale );

  //**** Calc RFDstPRect's Width, Height and ScrollBars visibility (HorVis,VertVis)

  if ((NeededDstWidth > DstWidth1)  and (NeededDstHeight > DstHeight2)) or
     ((NeededDstWidth > DstWidth2)  and (NeededDstHeight > DstHeight1))   then
  begin
    HorVis  := True;
    VertVis := True;
  end else if (NeededDstWidth > DstWidth1) and (NeededDstHeight <= DstHeight2) then
  begin
    HorVis  := True;
    VertVis := False;
  end else if (NeededDstWidth <= DstWidth2) and (NeededDstHeight > DstHeight1) then
  begin
    HorVis  := False;
    VertVis := True;
  end else // both ScrollBars are not visible, Whole Image is visible
  begin
    HorVis  := False;
    VertVis := False;
  end; // else // both ScrollBars are not visible, Whole Image is visible

  if VertVis then PBWidth := DstWidth2
             else PBWidth := DstWidth1;

  if HorVis then PBHeight := DstHeight2
            else PBHeight := DstHeight1;

  DstWidth  := Min( NeededDstWidth,  PBWidth );   // Visible Fragment Size in PaintBox
  DstHeight := Min( NeededDstHeight, PBHeight );

  if RFRasterScale >= MinMeshStep then // decrease DstWidth, DstHeight if needed
  begin
    BufPix := Floor( DstWidth / RFRasterScale );
    DstWidth := Round( BufPix * RFRasterScale );

    BufPix := Floor( DstHeight / RFRasterScale );
    DstHeight := Round( BufPix * RFRasterScale );
  end; // if RFRasterScale >= MinMeshStep then // decrease DstWidth, DstHeight

  //*********** DstWidth and DstHeight are OK, calc RFDstPRect
  PaintBoxRect := Rect( RFPaddings.Left, RFPaddings.Top,
                        PBWidth-RFPaddings.Right-1, PBHeight-RFPaddings.Bottom-1 );
  RFDstPRect := N_IRectCreate1( PaintBoxRect, DstWidth, DstHeight, RFCenterInDst );

  //*********** Calc New SrcPRec Size
  NewSrcPRecSize := Point( Round( DstWidth/RFRasterScale ),
                           Round( DstHeight/RFRasterScale ) );

  //*********** Calc NewLFPRect, NewRelSrcPRect - New SrcPRec Position by NewSrcPRecSize

  //***** First Calc LFNormObjPoint - current LogFrameRect Normalized Object Point Coords,
  //               NewLFRelObjPoint - New LogFrameRect Relative Object Point Coords,
  //                SPRNormObjPoint - New SrcPRect Normalized Coords of NewLFRelObjPoint and
  //                 NewRelSrcPRect - New Relative SrcPRect (assuming that NewLFPRect.TopLeft=(0,0))

  if CurZoomMode = rfzmUpperleft then // Fixed Point is the UpperLeft RFSrcPRect
  begin
    LFNormObjPoint := N_RectNormCoords( DPoint(RFSrcPRect.TopLeft), RFLogFramePRect );
    SPRNormObjPoint := N_ZDPoint;
  end else if CurZoomMode = rfzmCenter then // Fixed Point is in the Center of RFSrcPRect
  begin
    Center.X := 0.5*(RFSrcPRect.Left + RFSrcPRect.Right);
    Center.Y := 0.5*(RFSrcPRect.Top  + RFSrcPRect.Bottom);
    LFNormObjPoint := N_RectNormCoords( Center, RFLogFramePRect );
    SPRNormObjPoint := DPoint( 0.5, 0.5 );
  end else if CurZoomMode = rfzmCursor then // Fixed Point is Cursor Position and it is inside RFSrcPRect
  begin
    LFNormObjPoint  := N_RectNormCoords( CCBufD, RFLogFramePRect );
    SPRNormObjPoint := N_RectNormCoords( CCBufD, RFSrcPRect );
  end else // No Fixed Point - Point under Cursor (before zoom) will be shifted
  begin    //                  with Cursor in visible Rect Center (after zoom)
    LFNormObjPoint  := N_RectNormCoords( CCBufD, RFLogFramePRect );
    SPRNormObjPoint := DPoint( 0.5, 0.5 );
  end;

  NewLFRelObjPoint := N_RectAbsCoords( LFNormObjPoint, NewLFPRect );

  NewRelSrcPRect := N_RectMake( NewLFRelObjPoint, NewSrcPRecSize, SPRNormObjPoint );
  NewRelSrcPRect := N_RectAdjustByMaxRect( NewRelSrcPRect, NewLFPRect );

  //***** Here NewLFPRect, NewRelSrcPRect, use it

  RedrawNeeded := PrepOCanv( NewLFPRect, NewRelSrcPRect );
  N_SetScrollBarsByRects( NewLFPRect, NewRelSrcPRect, HScrollBar, VScrollBar );

  if RedrawNeeded then Redraw();

  if CurZoomMode = rfzmCursorShift then // Set cursor in the middle of new SrcPRect
  begin
    NewCCBufD := N_RectAbsCoords( LFNormObjPoint, RFLogFramePRect );
    SetCursorByDPCoords( NewCCBufD );
  end;

  if Assigned(RFOnScaleProcObj) then RFOnScaleProcObj( Self );

  SearchInAllGroups(); // set proper (for Component under Cursor) User Coords
  RedrawAllSGroupsActions();
  ShowMainBuf();
end; // function TN_Rast1Frame.SetZoomLevel

//*********************************************** TN_Rast1Frame.VectorScale ***
// Scale current RFLogFramePRect by given AScaleCoef
// RedrawAll Image if needed
//
procedure TN_Rast1Frame.VectorScale( AScaleCoef: float; AZoomFlags: TN_RFZoomFlags );
var
  CurZoomMode: TN_RFZoomMode;
begin
  if (rfifShiftAtZoom in RFInterfaceFlags) and (rfzfUseCursor in AZoomFlags) then
    AZoomFlags := AZoomFlags + [rfzfShiftInCenter];

  CurZoomMode := rfzmCenter;

  if rfzfUpperleft     in AZoomFlags then CurZoomMode := rfzmUpperLeft;
  if rfzfUseCursor     in AZoomFlags then CurZoomMode := rfzmCursor;
  if rfzfShiftInCenter in AZoomFlags then CurZoomMode := rfzmCursorShift;

  RFVectorScale := RFVectorScale * AScaleCoef;
  SetZoomLevel( CurZoomMode );
end; // procedure TN_Rast1Frame.VectorScale

//************************************************ TN_Rast1Frame.ResizeSelf ***
// Resize self by changing ParentForm size
//
// NewWidth, NewHeight - New Self size
//
procedure TN_Rast1Frame.ResizeSelf( NewWidth, NewHeight: integer );
begin
//  N_ChangeFormSize( K_GetOwnerForm( Owner ), NewWidth-Width, NewHeight-Height );
  N_ChangeFormSize( K_GetParentForm( Self ), NewWidth-Width, NewHeight-Height );
end; //*** end of procedure TN_Rast1Frame.ResizeSelf

//********************************************** TN_Rast1Frame.RecalcPRects ***
// Recalculate all PRects, using following base values: Self.Size,
//   BufSize(OCanv.CCRSize), RFSrcPRect(on INput and Output), RFRasterScale.
//
// Just Rects coords calculating and Frame.ScrollBars updating is done
//    without any drawing, Rects copying or LogFrameRect changing.
//
// Should be called after any change of these base values.
//
procedure TN_Rast1Frame.RecalcPRects();
var
  DstWidth,  DstWidth1,  DstWidth2,  SrcWidth,  NeededDstWidth,  PBWidth: integer;
  DstHeight, DstHeight1, DstHeight2, SrcHeight, NeededDstHeight, PBHeight: integer;
  BufPix: double;
  HorVis, VertVis: boolean;
  PaintBoxRect: TRect;
begin
  Assert( RFRasterScale <> 0, 'RFRasterScale=0!' );

  //*********** adjust RFRasterScale
  if (RFRasterScale > 0.9999) and (RFRasterScale < 1.0001) then RFRasterScale := 1.0;
//  if RFRasterScale > 1.0 then RFRasterScale := Ceil(RFRasterScale); //N1??

  //*********** calc max needed Dst size
  NeededDstWidth  := Round( RFRasterScale * N_RectWidth(OCanv.CurCRect) );
  NeededDstHeight := Round( RFRasterScale * N_RectHeight(OCanv.CurCRect) );

  //*********** max possible Dst size without scrollbars (if scrollbars are not visible)
  DstWidth1  := Self.Width  - RFPaddings.Left - RFPaddings.Right;
  DstHeight1 := Self.Height - RFPaddings.Top  - RFPaddings.Bottom;

  DstWidth2  := DstWidth1  - VScrollBar.Width;   // max possible Dst size
  DstHeight2 := DstHeight1 - HScrollBar.Height;  //   if scrollbars are visible

  //**** calc RFDstPRect's Width, Height and ScrollBars visibility (HorVis,VertVis)

  if ((NeededDstWidth > DstWidth1)  and (NeededDstHeight > DstHeight2)) or
     ((NeededDstWidth > DstWidth2)  and (NeededDstHeight > DstHeight1))   then
  begin
    HorVis  := True;
    VertVis := True;
  end else if (NeededDstWidth > DstWidth1) and (NeededDstHeight <= DstHeight2) then
  begin
    HorVis  := True;
    VertVis := False;
  end else if (NeededDstWidth <= DstWidth2) and (NeededDstHeight > DstHeight1) then
  begin
    HorVis  := False;
    VertVis := True;
  end else
  begin
    HorVis  := False;
    VertVis := False;
  end;

  if VertVis then PBWidth := DstWidth2
             else PBWidth := DstWidth1;

  if HorVis then PBHeight := DstHeight2
            else PBHeight := DstHeight1;

  //***** final adjust DstWidth, DstHeight

  DstWidth := Min( NeededDstWidth, PBWidth );
  if HorVis and (RFRasterScale > 1) then
  begin
    BufPix := Floor( DstWidth / RFRasterScale );
    DstWidth := Round( BufPix * RFRasterScale );
  end;

  DstHeight := Min( NeededDstHeight, PBHeight );
  if VertVis and (RFRasterScale > 1) then
  begin
    BufPix := Floor( DstHeight / RFRasterScale );
    DstHeight := Round( BufPix * RFRasterScale );
  end;

  //*********** DstWidth and DstHeight are OK, calc RFDstPRect

  PaintBoxRect := Rect( RFPaddings.Left, RFPaddings.Top,
                        PBWidth-RFPaddings.Right-1, PBHeight-RFPaddings.Bottom-1 );
//  N_Dump2Str( 'PaintBoxRect: ' + N_IRectToStr( PaintBoxRect ) );

  RFDstPRect := N_IRectCreate1( PaintBoxRect, DstWidth, DstHeight, RFCenterInDst );
//  N_Dump2Str( 'RFDstPRect: ' + N_IRectToStr( RFDstPRect ) );

  //*********** Update SrcPRec

  SrcWidth  := Round( DstWidth  / RFRasterScale );
  SrcHeight := Round( DstHeight / RFRasterScale );

  RFSrcPRect := N_IRectCreate1( RFSrcPRect, SrcWidth, SrcHeight, RFCenterInSrc );
//  N_Dump2Str( 'RFSrcPRect1: ' + N_IRectToStr( RFSrcPRect ) );
  RFSrcPRect := N_RectAdjustByMaxRect( RFSrcPRect, OCanv.CurCRect ); // RFSrcPRect is OK
//  N_Dump2Str( 'RFSrcPRect2: ' + N_IRectToStr( RFSrcPRect ) );

  N_SetScrollBarsByRects ( OCanv.CurCRect, RFSrcPRect, HScrollBar, VScrollBar );

//  WholeImageVisible := N_Same( RFSrcPRect, IRect(LogFrameRect) ); // used in OnResize

  SelectClipRgn( OCanv.HMDC, 0 ); // clear OCanv ClipRect
  if Assigned(RFOnScaleProcObj) then RFOnScaleProcObj( Self );
//  N_Dump2Str( 'RFSrcPRect3: ' + N_IRectToStr( RFSrcPRect ) );
end; //*** end of procedure TN_Rast1Frame.RecalcPRects

//********************************************** TN_Rast1Frame.RFResizeSelf ***
// Resize Self according to RFrResizeFlags
//
procedure TN_Rast1Frame.RFResizeSelf();
var
  BufSize: TPoint;
  FrameParent: TForm;
//  Label Finish;
begin
//  if rfrfTmp1  in RFrResizeFlags then
//    goto Finish;

  BufSize := Point( Self.Width, Self.Height );
//  FrameParent := K_GetOwnerForm( Owner );
  FrameParent := K_GetParentForm( Self );

  if rfrfScaleIfWhole in RFrResizeFlags then // Scale Image if Whole Image is visible
  begin
    if 0 = N_EnvRectPos( RFLogFramePRect, RFSrcPRect ) then // Whole Image was visible before Resize
    begin                                               // RFLogFramePRect is inside RFSrcPRect
      if rfrfKeepAspect in RFrResizeFlags then // Decrease Self by RFObjAspect
      begin
        //******************Does not work correct!!!
        BufSize := N_AdjustSizeByAspect( aamDecRect, BufSize, RFObjAspect );

        SkipOnResize := True; // temporary for next two statenents to prevent
                              // calling RFResizeSelf while changing Form Size

        if Self.Width <> BufSize.X then
          FrameParent.Width := FrameParent.Width + BufSize.X - Self.Width;

        if Self.Height <> BufSize.Y then
          FrameParent.Height := FrameParent.Height + BufSize.Y - Self.Height;

        SkipOnResize := False; // restore normal state
      end; // if rfrfKeepAspect in RFrResizeFlags then // Decrease Self by RFObjAspect

      aFitInWindowExecute( nil );
      Exit;
{
      OCanv.SetCurCRectSize( BufSize.X, BufSize.Y );
      RFLogFramePRect := OCanv.CurCRect;
      N_AdjustRectAspect( aamDecRect, RFLogFramePRect, RFObjAspect );
      LogFrameFRect := FRect1(RFLogFramePRect);

      goto Finish;
}
    end; // if 0 = N_EnvRectPos( RFLogFramePRect, RFSrcPRect ) then // Whole Image was visible before Resize

  end; // if rfrfScaleIfWhole in RFrResizeFlags then // Scale Image if Whole Image is visible

  SetZoomLevel( rfzmUpperleft );
{
  if not (rfrfBufEqFrame in RFrResizeFlags) then // BufSize can only be increased
  begin
    BufSize.X := max( OCanv.CCRSize.X, BufSize.X );
    BufSize.Y := max( OCanv.CCRSize.Y, BufSize.Y );
  end; // if not (rfrfBufEqFrame in RFrResizeFlags) then // BufSize can only be increased

  if (BufSize.X <> OCanv.CCRSize.X) or (BufSize.Y <> OCanv.CCRSize.Y) then
    OCanv.SetCurCRectSize( BufSize.X, BufSize.Y );

  Finish: //***************

  RecalcPRects();
  Redraw();
  SearchInAllGroups(); // set proper (for Component under Cursor) User Coords
  RedrawAllSGroupsActions();
  ShowMainBuf();
}
end; // procedure TN_Rast1Frame.RFResizeSelf

//**************************************************** TN_Rast1Frame.Redraw ***
// Just clear background (if needed) and call DrawProcObj
//
// Dst PaintBox is NOT updated (use RedrawAllAndShow if it is needed)
// RedrawAllSGroupsActions() is not called
//
procedure TN_Rast1Frame.Redraw;
var
  TmpT1: TN_CPUTimer1;
begin
  TmpT1 := nil; // to avoid warning
  N_s := RFDebName;
//  OCanv.SetIncCoefsAndUCRect( OCanvCurURect, OCanv.CurCRect );

  if (RFDebugFlags and $01) <> 0 then
  begin
    TmpT1 := TN_CPUTimer1.Create;
    TmpT1.Start;
  end;

  if (RFDebugFlags and $02) <> 0 then
  begin
    N_T2.Clear(20); // for using N_T2 in UDat3
  end;

  // if DrawProcObj fills whole OCanv.CurCRect, OCanvBackColor may be N_EmptyColor
  N_OCanv := OCanv; // for debug
  OCanv.ClearSelfByColor( OCanvBackColor ); // clear background if needed

  if Assigned(DrawProcObj) then DrawProcObj();

  if (RFDebugFlags and $01) <> 0 then
  begin
    TmpT1.Stop;
    N_s := 'Redraw time = ' + N_TimeToString(
               (TmpT1.DeltaCounter/N_CPUFrequency)/N_SecondsInDay, 1);
    SomeStatusBar.SimpleText := N_s;
    if N_InfoForm <> nil then
      if N_InfoForm.Visible then N_IAdd( N_s );
    TmpT1.Free;
  end;

  if (RFDebugFlags and $02) <> 0 then
  begin
    N_T2.Show(20);
  end;

  with OCanv do if HBDC <> 0 then // copy updated MainBuf to BackBuf
    CopyWholeToBack();
//    BitBlt( HBDC, 0, 0, CCRSize.X, CCRSize.Y, HMDC, 0, 0, SRCCOPY );

  OCanv.PrevNumInvRects := 0;
  OCanv.NumInvRects := 0;
  SkipOnPaint := False; // MainBuf content is OK and can be shown
end; // end fo procedure TN_Rast1Frame.Redraw

//************************************************* TN_Rast1Frame.RedrawAll ***
// call Redraw and RedrawAllSGroupsActions
// Dst PaintBox is NOT updated (use RedrawAllAndShow if it is needed)
// OCanv coords are used for RedrawAllSGroupsActions
// (Redraw alone without RedrawAllSGroupsActions is used in Zoom proc)
//
procedure TN_Rast1Frame.RedrawAll;
begin
  if Self = nil then Exit;
  Redraw();
  N_Dump2Str( 'Rast1Frame.RedrawAll after Redraw' );
  RedrawAllSGroupsActions();
  N_Dump2Str( 'Rast1Frame.RedrawAll after RedrawAllSGroupsActions' );
end; // end fo procedure TN_Rast1Frame.RedrawAll

//****************************************** TN_Rast1Frame.RedrawAllAndShow ***
// RedrawAll and Show updated MainBuf in Dst PaintBox
//
procedure TN_Rast1Frame.RedrawAllAndShow;
begin
  if Self = nil then Exit;
  RedrawAll();
  ShowMainBuf();
end; // end fo procedure TN_Rast1Frame.RedrawAllAndShow

//*************************************** TN_Rast1Frame.RedrawAllToMetafile ***
// Create Delphi metafile and RedrawAll to it
// Return created metafile obj
//
// PixRect  -
// MM01Rect -
//
function TN_Rast1Frame.RedrawAllToMetafile( PixRect, MM01Rect: TRect ): TMetafile;
begin
// not implemented yet
  Result := nil;
end; // end fo procedure TN_Rast1Frame.RedrawAllToMetafile
{
//************************************** TN_Rast1Frame.CoordsToStr ***
// return needed (CoordsShowType) coords of APoint given in Buf Pixel Coords
// using given APCSData - pointer to Coords Scope Data
//
function TN_Rast1Frame.CoordsToStr( const APoint: TPoint;
                                          SCType: TN_CompCoordsType ): string;
var
  A: integer;
  UserPoint: TDPoint;
  AplPoint: TDPoint;
begin
  ResPoint :=
  Result := Format( PointCoordsFmt, [APoint.X, APoint.Y] );


  case SCType of

  cctDstPix: //***** Show APoint Pixel Coords
  begin
    Result := Format( PointPixCoordsFmt, [APoint.X, APoint.Y] );
  end;

  sctUserCoords: //***** show DPoint User Coords
  begin
    //***** FrP2U.CX is size of one pixel in User Coors
    //      A - needed number decimal digits after point separator
    A := Round(Ceil(Max( 0, -Log10(Abs(OCanv.P2U.CX)))))+1;
//    UserPoint := N_AffConvI2DPoint( APoint, OCanv.P2U );
    UserPoint := CCUser;
    Result := Format( PointUserCoordsFmt, [ A, UserPoint.X, A, UserPoint.Y, A] );
//    N_IAdd( Format( 'Pix = %d, %d', [APoint.X, APoint.Y] ) ); // debug
  end;

  sctApplCoords: //***** show DPoint Application Coords
  begin
    UserPoint := N_AffConvI2DPoint( APoint, OCanv.P2U );
    AplPoint := N_AffConvD2DPoint( UserPoint, FrU2A );
    //***** OCanv.P2U.CX*FrU2A.CX is size of one pixel in Application Coords
    //      A - needed number decimal digits after point separator
    A := Round(Ceil(Max( 0, -Log10(Abs(OCanv.P2U.CX*FrU2A.CX)))))+1;
    Result := Format( PointApplCoordsFmt, [ A, AplPoint.X, A, AplPoint.Y, A] );
  end;

  end; // case SCType of
end; // function TN_Rast1Frame.CoordsToStr
}

//************************************** TN_Rast1Frame.ShowString ***
// Show given string AStr according to bits0-7 of given AFlags:
// bits0-1($003) - what to Show in Statusbar
//    =0 - do not change Statusbar
//    =1 - show AStr in Statusbar
//    =2- add AStr to Statusbar and show in Statusbar
//    =3- add Statusbar to AStr and show in Statusbar
// bit2($004) - what to Show in N_InfoForm
//    =1 - add Astr to N_InfoForm (To Log File)
// bit3($008) - not used
// bits4-7($0F0) - what to Show in N_memoForm (StatusForm)
//    =0   - do not show anything
//    =1-6 - add Strings 1 to 6 of N_memoForm (counting from 1)
//    =7   - add to first empty string
//
procedure TN_Rast1Frame.ShowString( AFlags: integer; AStr: string );
begin
  if SomeStatusBar = nil then Exit; // StatusBar not defined

  if TN_RFrameAction(RFRubberRectAction).ActEnabled then
    AStr := AStr + RFRubberRectStr;

  case AFlags and $03 of
  01: SomeStatusBar.SimpleText := AStr;
  02: SomeStatusBar.SimpleText := SomeStatusBar.SimpleText + '  ' + AStr;
  03: SomeStatusBar.SimpleText := AStr + '  ' + SomeStatusBar.SimpleText;
  end;

  if (AFlags and $04) <> 0 then N_IAdd( AStr ); // add to N_InfoForm

  if (AFlags and $0F0) <> 0 then // add to N_memoForm
  begin
{
    N_GetMemoForm( '', nil );
    StrInd := (AFlags and $0F0) - $010;

    if (AFlags and $0F0) = $070 then // add to first empty string
    begin
      StrInd := N_MemoForm.Memo.Lines.Count; // new string
      for i := 0 to StrInd-1 do
        if N_MemoForm.Memo.Lines[i] = '' then
        begin
          StrInd := i;
          Break;
        end;
    end; // if (AFlags and $0F0) = $070 then // add to first empty string

    for i := 0 to StrInd do // add strings if needed
      if N_MemoForm.Memo.Lines[i] = '' then
        N_MemoForm.Memo.Lines.Add( '' );

    N_MemoForm.Memo.Lines[StrInd] := N_MemoForm.Memo.Lines[StrInd] + '  ' + Astr;
}    
  end; // if (AFlags and $0F0) <> 0 then // add to N_memoForm
end; // end fo procedure TN_Rast1Frame.ShowString


//******************************* TN_Rast1Frame.RFExecAllSGroupsActions ***
// Execute All Groups RFActions
// (cur CObjects in all groups are already updated)
//
procedure TN_Rast1Frame.RFExecAllSGroupsActions();
var
  i, OnePixelSize: integer;
  SomethingChanged: boolean;
begin
  if RFSGroups = nil then Exit; // may be after RFFreeObjects call

  Inc( ActCounter ); // used in debug Actions

  SomethingChanged := False;
  for i := 0 to RFSGroups.Count-1 do // set SomeDoSearch condition
  with TN_SGBase(RFSGroups.Items[i]) do
  begin
    SomethingChanged := SomethingChanged or SRChanged;
  end;

  if not RFSkipAnimation and
     (ForceHighlighting or SomethingChanged or (CHType <> htMouseMove)) then
  begin
    DoHighlight := True;
    PermanentDraw := True;
    OCanv.ClearPrevPhase();
    // ShowMainBuf(); // debug
  end;

  //***** clear SomeStatusBar if needed (for ShowCobjInfo action and others)
  if ((RFClearFlags and $001) <> 0) and (SomeStatusBar <> nil) then
    SomeStatusBar.SimpleText := '';

  //***** clear N_MemoForm.Memo.Lines if needed (mainly for showing debug info)
//  if (RFClearFlags and $002) <> 0 then
//    if N_MemoForm <> nil then N_MemoForm.Memo.Lines.Clear();

  for i := 0 to RFSGroups.Count-1 do //***** Execute Actions
  with TN_SGBase(RFSGroups.Items[i]) do
  begin
    N_s := GName; // for debug
    GExecAllActions();
  end;

  if DoHighlight then
  begin
    DoHighlight := False;
    ShowNewPhase();
  end;
//  N_IAdd( 'After all Actions' ); // debug

  OnePixelSize := Round( RFRasterScale );
  if (OnePixelSize >= MinMeshStep) and MeshEnabled then
    N_DrawMesh( PaintBox.Canvas, RFDstPRect, OnePixelSize-1, OnePixelSize-1,
                                               OnePixelSize, OnePixelSize );
end; // end fo procedure TN_Rast1Frame.RFExecAllSGroupsActions

//******************************* TN_Rast1Frame.RedrawAllSGroupsActions ***
// Redraw (all ActRedraw method) All Groups Actions
//
procedure TN_Rast1Frame.RedrawAllSGroupsActions();
var
  i, j, k: integer;
  SavedLLWPixSize: double;
  VisRect: Trect;
begin
  SavedLLWPixSize := OCanv.CurLLWPixSize;

  for i := 0 to RFSGroups.Count-1 do //***** loop along Groups of TN_SGComp type
  with TN_SGBase(RFSGroups.Items[i]) do
  begin
    if RFSGroups.Items[i] is TN_SGComp then
    with TN_SGComp(RFSGroups.Items[i]) do
    begin
      if (SGFlags and 4) = 0 then
        for j := 0 to High(SComps) do //***** loop along Components in i-th Group
        with SComps[j].SComp do       // (now always only one component)
        begin
          N_s1 := ObjName;
          // set OCanv coefs for correct drawing in RedrawActions
          OCanv.P2U := CompP2U;
          OCanv.U2P := CompU2P;
          VisRect := CompIntPixRect;
          N_IRectAnd( VisRect, OCanv.CurCRect );
          OCanv.SetUClipRect( VisRect );
          OCanv.CurLLWPixSize := RedrawLLWPixSize;

          for k := 0 to GroupActList.Count-1 do //***** loop along Actions in Group
          begin
            N_s := TN_RFrameAction(GroupActList[k]).ActName; // debug
            TN_RFrameAction(GroupActList.Items[k]).RedrawAction();
          end;

        end // for j := 0 to High(SComps) do with SComps[j].SComp do
      else
        for k := 0 to GroupActList.Count-1 do //***** loop along Actions in Group
        begin
          N_s := TN_RFrameAction(GroupActList[k]).ActName; // debug
          TN_RFrameAction(GroupActList.Items[k]).RedrawAction();
        end;
    end; // if RFSGroups.Items[i] is TN_SGComp then with TN_SGComp(RFSGroups.Items[i]) do
  end; // for i := 0 to RFSGroups.Count-1 do with TN_SGBase(RFSGroups.Items[i]) do

  OCanv.CurLLWPixSize := SavedLLWPixSize; // restore
end; // end fo procedure TN_Rast1Frame.RedrawAllSGroupsActions

//************************************* TN_Rast1Frame.SearchInAllGroups ***
// Update all Groups State (set Cur... and Prev... fields)
// by current Cursor position (beg phase of MouseMove handler)
//
procedure TN_Rast1Frame.SearchInAllGroups();
var
  gi: integer;
  SGBase: TN_SGBase;
begin
  for gi := RFSGroups.Count-1 downto 0 do //*** loop along Search Groups
  begin
    SGBase := TN_SGBase(RFSGroups.Items[gi]);
    if SGBase = nil then Continue; // skip empty pointers
    SGBase.SRChanged := SGBase.SearchInAllComps();
  end; // for gi := RFSGroups.Count-1 downto 0 do; // with ARFrame do
end; // procedure TN_Rast1Frame.SearchInAllGroups();

//************************************* TN_Rast1Frame.SearchInAllGroups2 ***
// Update all Groups State (set Cur... and Prev... fields)
// by given Cursor position AX, AY in Destination PaintBox Pixel coords
//
procedure TN_Rast1Frame.SearchInAllGroups2( AX, AY: integer );
var
  SavedCCBuf: TPoint;
begin
  SavedCCBuf := CCBuf; // save current value (a precaution, probably not needed)

  // Self CCBuf field is the only one used in SearchInAllGroups() method

  CCBuf.X := Round(Floor( ( AX - RFDstPRect.Left + 0.5 ) / RFRasterScale + RFSrcPRect.Left ));
  CCBuf.Y := Round(Floor( ( AY - RFDstPRect.Top  + 0.5 ) / RFRasterScale + RFSrcPRect.Top ));

  SearchInAllGroups();

  CCBuf := SavedCCBuf; // restore
end; // procedure TN_Rast1Frame.SearchInAllGroups2();

//************************************* TN_Rast1Frame.StartPermanent ***
// just check if PremanentDraw is set
// (should be called before all permanent drawing)
//
procedure TN_Rast1Frame.StartPermanent();
begin
  Assert( PermanentDraw, 'Premanent Drawing is not allowed!' );
end; // procedure TN_Rast1Frame.StartPermanent

//************************************* TN_Rast1Frame.StartHighlighting ***
// just clear PremanentDraw flag
// (should be called before all drawing for temporary highlighting)
//
procedure TN_Rast1Frame.StartHighlighting();
begin
  if not PermanentDraw then Exit;
  OCanv.FixPhase(); // end of permanent drawing
  PermanentDraw := False;
end; // procedure TN_Rast1Frame.StartHighlighting

//**************************************** TN_Rast1Frame.GetGroupInd ***
// Get Grop Index in RFSGroups list by it's Name
//
function TN_Rast1Frame.GetGroupInd( AGName: string ): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to RFSGroups.Count-1 do
  begin
    if TN_SGBase(RFSGroups.Items[i]).GName = AGName then
    begin
      Result := i;
      Exit;
    end;
  end;
end; // function TN_Rast1Frame.GetGroupInd

//**************************************** TN_Rast1Frame.DeleteGroup ***
// Delete Group with given Name from RFSGroups list
//
procedure TN_Rast1Frame.DeleteGroup( AGName: string );
var
  Ind: integer;
begin
  Ind := GetGroupInd( AGName );
  if Ind <> -1 then
    RFSGroups.Delete( Ind );
end; // procedure TN_Rast1Frame.DeleteGroup

{
//**************************************** TN_Rast1Frame.SetGroup ***
// if Group with given Name exists in RFSGroups, just move it to given
// GroupInd (to LastInd if Group=-1) and return it, if not,
// Create Group (by given RArray description) and Insert it into RFSGroups,
//
procedure TN_Rast1Frame.SetGroup( GroupDescr: TK_RArray; GroupInd: integer );
begin
var
  Ind: integer;
  NewGroup: TN_SGBase;
begin
  Ind := GetActionInd( ARFAName );

  if Ind >= 0 then // Action already in Self List
  begin
    if ActInd >= -1 then
    begin
      if ActInd = -1 then ActInd := GroupActList.Count-1; // move to last position
      GroupActList.Move( Ind, ActInd ); // move Ind to ActInd (ActInd>=0)
      Ind := ActInd;
    end;
  end else // Create new Action
  begin
    TmpRFAClass := GetActionClass( ARFAName );
    Ind := ActInd;
    if ActInd <= -1 then
      Ind := GroupActList.Add( TmpRFAClass.Create )
    else
      GroupActList.Insert( Ind, TmpRFAClass.Create );
  end;

  Result := TN_RFrameAction(GroupActList.Items[Ind]);
  Result.ActFlags := AActFlags;
  Result.ActGroup := Self;
end; // procedure TN_Rast1Frame.SetGroup
}

//*************************************** TN_Rast1Frame.SetCursorByDPCoords ***
// Set Cursor position in PaintBox by ABufD - given Ocanv.MainBuf Double Pixel Coords
//
procedure TN_Rast1Frame.SetCursorByDPCoords( const ABufD: TDPoint );
var
  ScreenMousePos, DstMousePos: TPoint;
begin
  DstMousePos.X := RFDstPRect.Left + Round(Floor((ABufD.X - RFSrcPRect.Left)*RFRasterScale));
  DstMousePos.Y := RFDstPRect.Top  + Round(Floor((ABufD.Y - RFSrcPRect.Top)*RFRasterScale));

  ScreenMousePos := PaintBox.ClientToScreen( DstMousePos );

  if not N_Same( ScreenMousePos, Mouse.CursorPos ) then
  begin
    SkipMouseMove := True;
    Mouse.CursorPos := ScreenMousePos;
    SkipMouseMove := False;
  end;
end; // procedure TN_Rast1Frame.SetCursorByPCoords

//*************************************** TN_Rast1Frame.SetCursorByUcoords ***
// Set Cursor Position by given User Coords
//
procedure TN_Rast1Frame.SetCursorByUcoords( const AUcoords: TDPoint );
begin
  SetCursorByDPCoords( N_AffConvD2DPoint( AUcoords, OCanv.U2P ) );
end; //*** end of procedure TN_Rast1Frame.SetCursorByUcoords

procedure TN_Rast1Frame.StartMouseDownTimer();
// Start repeating MouseDown Events
begin
  if MouseDownTimerState = 0 then
  begin
    MouseDownTimerState := 1;

    RepeatMouseDown.Enabled  := True;
    RepeatMouseDown.Interval := 200; // big interval before first Timer event
  end;
end; // procedure TN_Rast1Frame.StartMouseDownTimer

//************************************* TN_Rast1Frame.InitializeCoords(Old) ***
// Initialize OCanv Buf and Self Coords for drawing Visual Components Tree
//
// AWidth,  AHeight - needed OCanv X,Y size in Pixels, if not given ( =0 ),
// use curent Frame Size
//
procedure TN_Rast1Frame.InitializeCoords( AWidth, AHeight: integer );
var
  CompPixSize: TPoint;
//  CompmmSize: TFPoint;
  CompSizeType: TN_VCTSizeType;
begin
  Assert( RVCTreeRoot <> nil, 'RVCTreeRoot=nil' );

  with RVCTreeRoot do
  begin
    CompSizeType := GetSize( nil, @CompPixSize );

    if CompSizeType = vstNotGiven then // set CompPixSize by AWidth, AHeight if given
    begin
      if AWidth = 0 then AWidth := Self.Width;
      CompPixSize.X := AWidth;

      if AHeight = 0 then AHeight := Self.Height;
      CompPixSize.Y := AHeight;
    end;

//    OCanv.SetCurCRectSize( AWidth, AHeight, pf32bit ); // old var
    OCanv.SetCurCRectSize( CompPixSize.X, CompPixSize.Y, pfDevice );

    RFObjAspect := GetAspect(); // is used while zooming
//    CompPixSize := CalcRootCurPixRectSize( Point( AWidth, AHeight ) );  // old var
    CompPixSize := CalcRootCurPixRectSize( CompPixSize );

  end; // with RVCTreeRoot do

  RFObjSize := CompPixSize;
  RFLogFramePRect := IRect( CompPixSize );
  RFVectorScale := 1;
  RecalcPRects();
end; // procedure TN_Rast1Frame.InitializeCoords(Old)

//************************************* TN_Rast1Frame.InitializeCoords(New) ***
// Initialize OCanv Buf and Self Coords for drawing Visual Components Tree
// by given Params
//
procedure TN_Rast1Frame.InitializeCoords( APRFInitParams: TN_PRFInitParams;
                                          APCoords: TN_PRFCoordsState );
var
  NeededFormWidth, NeededFormHeight, MaxFormWidth, MaxFormHeight: integer;
  NeededResDPI: float;
  CompPixSize, FrameSize, BufSize: TPoint;
  CompmmSize: TFPoint;
  WrkInitParams: TN_RFInitParams;
  WrkCoords: TN_RFCoordsState;
  FrameParent: TForm;
begin
  WrkCoords := APCoords^;
  WrkInitParams := APRFInitParams^;
//  FrameParent := K_GetOwnerForm( Owner );
  FrameParent := K_GetParentForm( Self );

  with WrkInitParams, WrkCoords, N_MEGlobObj do
  begin
    Assert( RVCTreeRoot <> nil, 'RVCTreeRoot=nil' );

    //*** Set Needed Resolution:
    NeededResDPI := RFIPResolution;
    if NeededResDPI = 0 then // not given in APRFInitParams^, use Component Res or Default Screen Res
    begin
      NeededResDPI := MEScrResCoef*RVCTreeRoot.PCCD()^.SrcResDPI;

      if NeededResDPI = 0 then NeededResDPI := MEScrResCoef*MEDefScrResDPI;
    end; // if NeededResDPI = 0 then // not given in APRFInitParams^

    with RVCTreeRoot do //*** Get Component Aspect and Size (with given Resolution)
    begin
      RFObjAspect := GetAspect(); // Self.RFObjAspect field is used while zooming
      GetSize( @CompmmSize, @CompPixSize, NeededResDPI );
    end; // with RVCTreeRoot do

    RFObjSize := CompPixSize;

    //*** Set FrameSize variable by:
    //        - Self Size or
    //        - WrkCoords.RFCSFrameSize field or
    //        - Component size (with Component or Screen Resolution)

    FrameSize := RFCSFrameSize;

    //*** Remark: Frame Size should be used for setting PaintBox Size, because
    //            PaintBox Size could not be set by Delphi if Form is not visible!

    if FrameSize.X = 0 then // Frame Size is not given, use current Self size
      FrameSize := Point( Self.Width, Self.Height );

    if rfipFrameSizeByComp in RFIPFlags then // set FrameSize by CompPixSize
      FrameSize := CompPixSize;

    if rfipFrameSizeByAspect1 in RFIPFlags then // Adjust Frame Size using aamSwapDec mode
      FrameSize := N_AdjustSizeByAspect( aamSwapDec, FrameSize, RFObjAspect );

    if rfipFrameSizeByAspect2 in RFIPFlags then // Adjust Frame Size using aamDecRect mode
      FrameSize := N_AdjustSizeByAspect( aamDecRect, FrameSize, RFObjAspect );


    //***** Update Form Size by FrameSize variable if needed

    if Self.Width <> FrameSize.X then // Form Width should be changed
    begin
      NeededFormWidth := FrameParent.Width + FrameSize.X - Self.Width;
      MaxFormWidth := N_RectWidth(N_AppWAR );

      if NeededFormWidth > MaxFormWidth then NeededFormWidth := MaxFormWidth;

      FrameParent.Width := NeededFormWidth;
    end; // if Self.Width <> FrameSize.X then // Form Width should be changed

    if Self.Height <> FrameSize.Y then // Form Height should be changed
    begin
      NeededFormHeight := FrameParent.Height + FrameSize.Y - Self.Height;
      MaxFormHeight := N_RectHeight(N_AppWAR );

      if NeededFormHeight > MaxFormHeight then NeededFormHeight := MaxFormHeight;

      FrameParent.Height := NeededFormHeight;
    end; // if Self.Height <> FrameSize.Y then // Form Height should be changed


    //***** Define Raster Buf Size and Create Raster Buf

    BufSize := RFCSBufSize;

    if (BufSize.X = 0) then BufSize := FrameSize;

    if rfipBufSizeByComp in RFIPFlags then // set BufSize by CompPixSize
      BufSize := CompPixSize;

    BufSize := N_AdjustSizeByAspect( aamDecRect, BufSize, RFObjAspect );
    OCanv.SetCurCRectSize( BufSize.X, BufSize.Y, pfDevice );

    //***** Set fields, used in RecalcPRects:
    //      LogFrameRect, RFSrcPRect, RFRasterScale
    //      (set zoom level and visible Rect)

    if rfipLogFrameByComp in RFIPFlags then // Set RFLogFramePRect by CompPixSize
    begin
      RFLogFramePRect := IRect( CompPixSize );
    end else //*********************** Use given LogFrameRect or show whole Buf
    begin
      RFLogFramePRect := RFCSLogFramePRect;

      if RFLogFramePRect.Left = RFLogFramePRect.Right then // if not given - show whole Buf
      begin
        RFLogFramePRect := OCanv.CurCRect;
      end;
    end; // else // Use given LogFrameRect or show whole Buf

    N_AdjustRectAspect( aamDecRect, RFLogFramePRect, RFObjAspect );
    RFLogFramePRect := N_RectAdjustByMinRect( RFLogFramePRect, OCanv.CurCRect );
    RFVectorScale := N_RectWidth(RFLogFramePRect) / CompPixSize.X;

    RFSrcPRect := RFCSSrcPRect;
    if RFSrcPRect.Left = RFSrcPRect.Right then // if not given - show upper left rect
      RFSrcPRect := IRect( BufSize );

{
    if rfipLogFrameByComp in RFIPFlags then
      LogFrameRect := FRect(CompPixSize)
    else if RFCSNLogFrameRect.Left <> RFCSNLogFrameRect.Right then // RFCSNLogFrameRect is given
      LogFrameRect := N_FRectFAffConv2( FRect(OCanv.CurCRect), N_EFRect, RFCSNLogFrameRect )
    else if RFCSALogFrameRect.Left <> RFCSALogFrameRect.Right then // RFCSLogFrameRect is given
      LogFrameRect := RFCSALogFrameRect
    else // Show Whole Component
      LogFrameRect := FRect1(OCanv.CurCRect);

    if RFCSNSrcPRect.Left <> RFCSNSrcPRect.Right then // RFCSNSrcPRect is given
      SrcPRect := N_IRectFAffConv2( OCanv.CurCRect, N_EFRect, RFCSNSrcPRect );
}

    if RFCSRastrScale > 0 then RFRasterScale := RFCSRastrScale;

    RecalcPRects();
//    RFCSCompmmSize := CompmmSize; // update RFrame Comp size in mm (used in GetCoordState)
  end; // with WrkInitParams, WrkCoords, N_MEGlobObj do
end; // procedure TN_Rast1Frame.InitializeCoords(New)

//*************************************** TN_Rast1Frame.RVCTFrInit ***
// Init Self for drawing ARootComp (old var, use RVCTFrInit3)
// AWidth,  AHeight - OCanv X,Y size in Pixels,
//                    if not given ( =0 ), use curent Frame Size - NOT implemented!
//
procedure TN_Rast1Frame.RVCTFrInit( ARootComp: TN_UDCompVis;
                             APixWidth: integer = 0; APixHeight: integer = 0 );
begin
  RFrInitByComp( ARootComp );
  InitializeCoords( APixWidth, APixHeight );
end; // procedure TN_Rast1Frame.RVCTFrInit

//*********************************************** TN_Rast1Frame.RVCTFrInit3 ***
// Init Self for drawing ARootComp
//
procedure TN_Rast1Frame.RVCTFrInit3( ARootComp: TN_UDCompVis;
    APRFInitParams: TN_PRFInitParams = nil; APCoords: TN_PRFCoordsState = nil );
var
  RFInitParams: TN_RFInitParams;
  CoordsState: TN_RFCoordsState;
begin
  RFrInitByComp( ARootComp );

  if APRFInitParams = nil then // not given, use default
  begin
    RFInitParams := N_DefRFInitParams;
    APRFInitParams := @RFInitParams;
  end;

  if APCoords = nil then // not given, use default
  begin
    CoordsState := N_DefRFCoordsState;
    APCoords := @CoordsState;
  end;

  InitializeCoords( APRFInitParams, APCoords );
end; // procedure TN_Rast1Frame.RVCTFrInit3

//***************************************** TN_Rast1Frame.RFrChangeRootComp ***
// Change Self Root Component by given ARootComp
//
//    Parameter
// ARootComp - new root component with the same size that current RFrame root component
//
procedure TN_Rast1Frame.RFrChangeRootComp( ARootComp: TN_UDCompVis );
begin
  ARootComp.PrepRootComp();
  NGlobCont.SetRootComp( ARootComp );
  RVCTreeRoot := ARootComp;
end; // procedure TN_Rast1Frame.RFrChangeRootComp

//*********************************************** TN_Rast1Frame.RFrShowComp ***
// Change Self Root Component by given ARootComp and show it
//
//    Parameter
// ARootComp - root component to show
//
procedure TN_Rast1Frame.RFrShowComp( ARootComp: TN_UDCompVis );
begin
  RVCTreeRoot := ARootComp;
  RFrInitByComp( ARootComp );

  if RVCTreeRoot <> nil then
    aFitInWindowExecute( nil )
  else
    RedrawAllAndShow();
end; // procedure TN_Rast1Frame.RFrShowComp

//********************************************* TN_Rast1Frame.RFrInitByComp ***
// Init Self by given ARootComp
//
//    Parameter
// ARootComp - given root component, may be nil
//
// ARootComp = nil means reducing OCanv DIB Section size to 1 pixel to free memory
//
procedure TN_Rast1Frame.RFrInitByComp( ARootComp: TN_UDCompVis );
begin
  //  N_IAdd( K_GetOwnerForm( Owner ).Caption ); // debug
  if NGlobCont <> nil then NGlobCont.Free(); // may be it is not needed to create new NGlobCont each time!
  NGlobCont := TN_GlobCont.Create(); // Self is NGlobCont Owner
  //  N_IAdd( IntToHex(integer(NGlobCont),6) ); // debug

  if ARootComp <> nil then
  begin
    ARootComp.PrepRootComp();
    NGlobCont.SetRootComp( ARootComp );
  end else // ARootComp = nil
  begin
    NGlobCont.GCRootComp := nil;
    OCanv.SetCurCRectSize( 1, 1 );
    RFRasterScale := 1.0;
    RFVectorScale := 1.0;
    RFSrcPRect := N_ZIRect;
    RFObjSize  := Point( 1, 1 );
    RecalcPRects();
  end;

  with NGlobCont do // init NGlobCont
  begin
    DstOCanv      := OCanv; // Self is OCanv Owner
    StopExecFlag  := False;
    GCBFreeInd    := 0;
    GCNewFilesInd := 1;
    DstImageType  := ditWinGDI;
  end; // with NGlobCont do // init NGlobCont

  //*** Set Rast1Frame fields

  if RVCTreeRootOwner then // delete previous VCTree, if it was owned by Self
    RVCTreeRoot.UDDelete;

  RVCTreeRoot := ARootComp;
  if RVCTreeRoot = nil then  RVCTreeRootOwner := False
  else if RVCTreeRoot.RefCounter = 0 then RVCTreeRootOwner := True
                                     else RVCTreeRootOwner := False;
  DrawProcObj := DrawVCTree;
end; // procedure TN_Rast1Frame.RFrInitByComp

//***************************************** TN_Rast1Frame.RFrInitByPaintBox ***
// Init Self by Self PaintBox Size counting given Aspect
//
//     Parameters
// AAspect - given needed Aspect
//
// Set BufSize by PaintBox Size counting given Aspect.
// Prohibit any Scacaling.
//
procedure TN_Rast1Frame.RFrInitByPaintBox( AAspect: double );
begin
  DrawProcObj   := nil;
  RFCenterInDst := True;
  RFFixedScale  := True;

  RFObjSize := N_AdjustSizeByAspect( aamDecRect, Point( Self.Width, Self.Height ), AAspect );
  OCanv.SetCurCRectSize( RFObjSize.X, RFObjSize.Y, pfDevice );

  RecalcPRects();
end; // procedure TN_Rast1Frame.RFrInitByPaintBox

//******************************************** TN_Rast1Frame.GetCoordsState ***
// Save current coords, sizes and rects in given APCoords
//
procedure TN_Rast1Frame.GetCoordsState( APCoords: TN_PRFCoordsState );
begin
  with APCoords^ do
  begin
    RFCSFrameSize     := Point( Self.Width, Self.Height );
    RFCSBufSize       := OCanv.CCRSize;
    RFCSLogFramePRect := RFLogFramePRect;
    RFCSSrcPRect      := RFSrcPRect;
    RFCSRastrScale    := RFRasterScale;
  end; // with APCoords^ do
end; // procedure TN_Rast1Frame.GetCoordsState

//**************************************** TN_Rast1Frame.RFGetCurRelObjSize ***
// Get Curent value of RelObjSize
//
//    Parameter
// Result - Return Curent value of RelObjSize
//
// RelObjSize = 1 if whole Obj is visible and >1 if Obj is bigger than RFrame
//
function TN_Rast1Frame.RFGetCurRelObjSize(): double;
var
  DstWidth, DstHeight: double;
begin
  DstWidth  := Self.Width  - RFPaddings.Left - RFPaddings.Right;
  DstHeight := Self.Height - RFPaddings.Top  - RFPaddings.Bottom;

  if N_RectAspect( RFLogFramePRect ) > (DstHeight / DstWidth) then
     Result := RFRasterScale * N_RectHeight( RFLogFramePRect ) / DstHeight
  else
     Result := RFRasterScale * N_RectWidth( RFLogFramePRect ) / DstWidth;
end; // function TN_Rast1Frame.RFGetCurRelObjSize

{
//******************************* TN_Rast1Frame.UpdateCoordsStateByCompSize ***
// Update given Coords State By given Component mm Size
//
procedure TN_Rast1Frame.UpdateCoordsStateByCompSize( APCoords: TN_PRFCoordsState;
                               const AOldmmSize: TFPoint; AComp: TN_UDCompVis );
var
  Coef, CompmmSize: TFPoint;
begin
  with APCoords^ do
  begin
    AComp.GetSize( @CompmmSize, nil, 0 ); // CompPixSize is not used
    Coef.X := CompmmSize.X / AOldmmSize.X;
    Coef.Y := CompmmSize.Y / AOldmmSize.Y;

    RFCSBufSize.X := Round(Coef.X*RFCSBufSize.X);
    RFCSBufSize.Y := Round(Coef.Y*RFCSBufSize.Y);

    with RFCSLogFrameRect do
    begin
      Right  := Left + (Right - Left)*Coef.X;
      Bottom := Top  + (Bottom - Top)*Coef.Y;
    end;

//    N_RectScaleA ( RFCSLogFrameRect, Coef, DPoint(RFCSLogFrameRect.TopLeft) );
  end; // with APCoords^ do
end; // procedure TN_Rast1Frame.UpdateCoordsStateByCompSize
}

//************************************************ TN_Rast1Frame.DrawVCTree ***
// Draw VCTree, method can be used as RFrame.DrawProcObj
//
procedure TN_Rast1Frame.DrawVCTree();
var
  ErrStr: string;
begin
//  N_Dump2Str( Format( 'RFr %s DrawVCTree', [RFDebName] )); // for debug only
  N_s := RFDebName;

  if RVCTreeRoot = nil then // RVCTreeRoot is not given, just clear background
  begin
    N_Dump2Str( Format( 'RFr %s RVCTreeRoot = nil', [RFDebName] )); // for debug only
//    N_DrawFilledRect( OCanv.HMDC, OCanv.CurCRect, OCanvBackColor );
    OCanv.ClearSelfByColor( OCanvBackColor ); // clear background if needed
    Exit;
  end;

  if RVCTreeRoot.ObjLiveMark <> N_ObjLiveMark then // RVCTreeRoot was already destroyed!
  begin
    ErrStr := 'Consistency Error in RFr.DrawVCTree (bad RVCTreeRoot)';
    N_Dump1Str( Format( '  %s, RFrName=%s', [ErrStr,RFDebName] ));
    raise TK_UDBaseConsistency.Create( ErrStr ); // Abort execution
  end; // if RVCTreeRoot.ObjLiveMark <> N_ObjLiveMark then // RVCTreeRoot was already destroyed!

  // one component can be drawn in different frames with different GlobContexts!
  RVCTreeRoot.NGCont := NGlobCont;
  RVCTreeRoot.PrepRootComp();

//  InitializeCoords( @N_DefRFInitParams, @N_DefRFCoordsState );

  with NGlobCont do
  begin
    SetSizes( RFLogFramePRect, FPoint( 0, 0 ) );
    DrawRootComp( OCanv.CurCRect );
  end;
end; // procedure TN_Rast1Frame.DrawVCTree

//************************************************ TN_Rast1Frame.DrawVCTree ***
// Draw Grid with Cell Numbers, can is used as RFrame.DrawProcObj
// (mainly for testing)
//
procedure TN_Rast1Frame.TestDrawGrid();
var
  ix, iy, PixX, PixY: integer;
begin
  ix := -1;
  with OCanv do
  begin

  ClearSelfByColor( $FFCCFF );

  while True do // along X axis
  begin
    Inc( ix );
    PixX := ix*40;
    if PixX > CurCRect.Right then Exit;

    iy := -1;
    while True do // along Y axis
    begin
      Inc( iy );
      PixY := iy*20;
      if PixY > CurCRect.Bottom then Break;

      //***** Draw (ix,iy) Cell content at (PixX,PixY)
      DrawPixString( Point(PixX,PixY), Format( '%0.2d,%0.2d', [ix,iy] ) );

    end; // while True do // along Y axis
  end; // while True do // along X axis
  end; // with OCanv do

end; // procedure TN_Rast1Frame.TestDrawGrid

//******************************************** TN_Rast1Frame.RFShowCurScale ***
// Draw VCTree, method can be used as RFrame.DrawProcObj
//
procedure TN_Rast1Frame.RFShowCurScale( ARFrame: TN_Rast1Frame);
begin

end; // procedure TN_Rast1Frame.RFShowCurScale

//**************************************** TN_Rast1Frame.RFGetActionByClass ***
// Get Action (from all GroupActList) by given Action ClassInd or nil if not found
//
// Example: Act := RFGetActionByClass( N_ActZoom );
//
function TN_Rast1Frame.RFGetActionByClass( AClassInd: integer ): TN_RFrameAction;
var
  i, ActionInd: integer;
begin
  for i := 0 to RFSGroups.Count-1 do
  with TN_SGBase(RFSGroups.Items[i]) do
  begin
    ActionInd := GetActionByClass( AClassInd );

    if ActionInd >= 0 then // found
    begin
      Result := TN_RFrameAction(GroupActList.Items[ActionInd]);
      Exit;
    end;

  end; // with TN_SGBase(RFSGroups.Items[i]) do, for i := 0 to RFSGroups.Count-1 do

  Result := nil; // not found
end; // function TN_Rast1Frame.RFGetActionByClass

//********************************************* TN_Rast1Frame.RFAddCurState ***
// Add to given strings current state params
//
//     Parameters
// AStrings - given strings
// AIndent  - number of spaces to add before all strings
//
procedure TN_Rast1Frame.RFAddCurState( AStrings: TStrings; AIndent: integer );
var
  i, j: integer;
  Prefix: string;
begin
  Prefix := DupeString( ' ', AIndent+2 );
  with AStrings do
  begin
    if Self = nil then
    begin
      AStrings.Add( Prefix + 'Self = nil' );
      Exit;
    end;

    AStrings.Add( Prefix + '*** Rast1Frame ' + RFDebName );

    if RVCTreeRoot = nil then
      AStrings.Add( Prefix + '    RVCTreeRoot = nil' )
    else
    begin
      RVCTreeRoot.UDCompAddCurStateMain( AStrings, AIndent+2 );
    end;

    AStrings.Add( Format( 'Skip Flags: %d %d  %d %d  %d %d',
         [integer(SkipMouseMove),integer(SkipMouseDown),integer(SkipOnPaint),
       integer(RFExtSkipOnPaint),integer(SkipOnResize),integer(SkipOnScrollBarChange)] ));

    with RFObjSize do
      AStrings.Add( Format( '%sIsOwner=%s, RFS=%d,%d', [Prefix,BoolToStr(RVCTreeRootOwner),X,Y] ));

    AStrings.Add( 'Parent   ' + N_TControlToStr( Self.Parent ) );
    AStrings.Add( 'Self     ' + N_TControlToStr( Self ) );
    AStrings.Add( 'PaintBox ' + N_TControlToStr( PaintBox ) );

    AStrings.Add( Prefix + 'RFSrcPRect:' + N_IRectToStr(RFSrcPRect) +
                         ', RFDstPRect:' + N_IRectToStr(RFDstPRect) +
                         ', RFLFrPRect:' + N_IRectToStr(RFLogFramePRect)  );

    for i := 0 to RFSGroups.Count-1 do // along RastrFrame SearchGroups
    with TN_SGBase(RFSGroups.Items[i]) do
    begin
      AStrings.Add( Prefix + '  Group: ' + GName );

      for j := 0 to GroupActList.Count-1 do // along current Group RFActions
      with TN_RFrameAction(GroupActList.Items[j]) do
      begin
        AStrings.Add( Prefix + Format( 'RFAction: %s, Flags:%X, ActInd:%d, Enabled:%s',
                                             [ActName,ActFlags,ActRGInd,BoolToStr(ActEnabled)] ));
      end; // for j := 0 to GroupActList.Count-1 do // along current Group RFActions

      AStrings.Add( '' );
    end; // for i := 0 to RFSGroups.Count-1 do // along RastrFrame SearchGroups


    AStrings.Add( '' );
  end; // with AStrings do
end; // procedure TN_Rast1Frame.RFAddCurState


//********** TN_RFrameAction class methods  **************

//************************************************** TN_RFrameAction.Create ***
// empty Create is really needed for overloading Create in descendant calsses
//
constructor TN_RFrameAction.Create();
begin
// is needed, but may be empty
// SetActionFrame method is alwayes called just after creation and needed
// new objects can be construted in it
end; // end_of constructor TN_RFrameAction.Create

//******************************************** TN_RFrameAction.SetActParams ***
// Set ActParams Field by ActFlags, can be used for creating new needed objects
// instead of constructor. Unlike constructor, this method can be called
// several times.
//
procedure TN_RFrameAction.SetActParams();
begin
// empty in base class, can be overloaded and used instead of constructor
  if (ActGroup.RFrame.RFDebugFlags and $04) <> 0 then
    N_IAdd( 'Set Action=' + ActName );
end; // procedure TN_RFrameAction.SetActParams();

//************************************************* TN_RFrameAction.Execute ***
// Execute Action
//
procedure TN_RFrameAction.Execute();
begin
  if (ActGroup.RFrame.RFDebugFlags and $04) <> 0 then
    N_IAdd( 'Exec Action=' + ActName );
end; // procedure TN_RFrameAction.Execute

//******************************************** TN_RFrameAction.RedrawAction ***
// Redraw Temporary Action objects
// (should be called from RFrame.RedrawAll )
//
procedure TN_RFrameAction.RedrawAction();
begin
// empty in base class
end; // procedure TN_RFrameAction.RedrawAction


//********** TN_SGBase class methods  **************

//******************************************************** TN_SGBase.Create ***
//
constructor TN_SGBase.Create( ARFrame: TN_Rast1Frame );
begin
  GroupActList := TObjectList.Create;
  RFrame := ARFrame;
end; // end_of constructor TN_SGBase.Create

//******************************************************* TN_SGBase.Destroy ***
//
destructor TN_SGBase.Destroy();
begin
  GroupActList.Free;
  inherited;
end; // end_of destructor TN_SGBase.Destroy


//********************************************** TN_SGBase.SearchInAllComps ***
// empty in Base Class
//
function TN_SGBase.SearchInAllComps(): boolean;
begin
  Result := False;
end; // function TN_SGBase.SearchInAllComps

//********************************************** TN_SGBase.GetActionByClass ***
// Get Action Ind in GroupActList by given Action ClassInd or -1 if not found
//
function TN_SGBase.GetActionByClass( AClassInd: integer ): integer;
var
  i: integer;
  TmpRFAClass: TN_RFAClass;
begin
  Result := -1;
  Assert( (AClassInd >= 0) and (AClassInd <= N_RFAClassRefsMaxInd), 'Bad ClassInd' );
  TmpRFAClass := N_RFAClassRefs[AClassInd];
  Assert( TmpRFAClass <> nil, 'Bad ClassInd' );

  for i := 0 to GroupActList.Count-1 do
  begin
    if GroupActList.Items[i] is TmpRFAClass then
    begin
      Result := i;
      Break;
    end;
  end;
end; // function TN_SGBase.GetActionByClass

//********************************************** TN_SGBase.GetActionByRGInd ***
// Get Action Ind in GroupActList by given ARGInd>0
// or -1 if not found or ARGInd=0
//
function TN_SGBase.GetActionByRGInd( ARGInd: integer ): integer;
var
  i: integer;
begin
  Result := -1;
  if ARGInd = 0 then Exit;

  for i := 0 to GroupActList.Count-1 do
  begin
    if TN_RFrameAction(GroupActList[i]).ActRGInd = ARGInd then
    begin
      Result := i;
      Break;
    end;
  end;
end; // function TN_SGBase.GetActionByRGInd

//***************************************************** TN_SGBase.SetAction ***
// If Action with given Name exists in GroupActList,
// just move it to given ActInd or to LastInd if ActInd=-1 or
// do not move if ActInd=-2 (just set fields), return existed Action.
//
// If Action with given Name do not exists in GroupActList,
// create it by given Name and Insert into GroupActList,
// (Insert Action before given ActInd or add as last Action, if ActInd<=-1),
// return created Action.
//
// AClassInd - Action Class Index in N_RFAClassRefs
// AActFlags - new value of RFrameAction.ActFlags field
// ActInd    - new Action Index (=-1 for Last Action, =-2 for current Index)
// ARGInd    - Action RadioGroup Index (only one Action with same RGInd
//             (if RGInd>0) can be in GroupActList)
//
function TN_SGBase.SetAction( AClassInd, AActFlags: integer;
                                    ActInd, ARGInd: integer ): TN_RFrameAction;
var
  Ind, Ind2, NewInd, LastInd: integer;
  TmpRFAClass: TN_RFAClass;
begin
  LastInd := GroupActList.Count-1;
  Ind := GetActionByRGInd( ARGInd );

  if Ind >= 0 then // Action with same ARGN>0 exists
  begin
    if ActInd = -2 then NewInd := Ind
    else if ActInd = -1 then NewInd := LastInd
    else  NewInd := ActInd;

    Ind2 := GetActionByClass( AClassInd );
    if Ind2 <> -1 then // needed action already exists, just move it
      GroupActList.Move( Ind, NewInd ) // move Ind to NewInd
    else  // Ind2 = -1
    begin
      GroupActList.Delete( Ind );
      TmpRFAClass := N_RFAClassRefs[AClassInd];
      NewInd := ActInd;
      if NewInd <= -1 then
        NewInd := GroupActList.Add( TmpRFAClass.Create )
      else
        GroupActList.Insert( NewInd, TmpRFAClass.Create );
    end; // Ind <> Ind2
  end else //********* NO Action with same ARGN>0
  begin
    Ind := GetActionByClass( AClassInd );

    if Ind >= 0 then // Action with given Name already in Self List
    begin
      if ActInd = -2 then NewInd := Ind
      else if ActInd = -1 then NewInd := LastInd
      else  NewInd := ActInd;
      GroupActList.Move( Ind, NewInd ); // move Ind to NewInd
    end else //******** Create new Action with given Name
    begin
      TmpRFAClass := N_RFAClassRefs[AClassInd];
      NewInd := ActInd;
      if NewInd <= -1 then
        NewInd := GroupActList.Add( TmpRFAClass.Create )
      else
        GroupActList.Insert( NewInd, TmpRFAClass.Create );
    end; // else - Create new Action with given Name
  end; // else - NO Action with same ARGN>0

  Result := TN_RFrameAction(GroupActList.Items[NewInd]);
  with Result do
  begin
    ActFlags   := AActFlags;
    ActGroup   := Self;
    ActRGInd   := ARGInd;
    ActEnabled := True;
    SetActParams(); // can be used like constructor
  end; // with Result do
end; // function TN_SGBase.SetAction

//*********************************************** TN_SGBase.GExecAllActions ***
// Execute all actions from GroupActList
//
procedure TN_SGBase.GExecAllActions();
var
  i: integer;
  WasDeleted: boolean;
  CurAction: TN_RFrameAction;
begin
  if SkipActions then Exit;

  for i := 0 to GroupActList.Count-1 do // along All Self Actions
  begin
//    N_ADS( TN_RFrameAction(GroupActList.Items[i]).ActName, i ); // debug
//    N_s := TN_RFrameAction(GroupActList.Items[i]).ActName; // debug
//    N_d := N_ActiveRFrame.OCanv.P2U.CX; // debug
//    RFrame.ShowMainBuf(); // debug

    CurAction := TN_RFrameAction(GroupActList.Items[i]);
    with CurAction do
    begin
//      Execute();
      if ActEnabled then Execute();
      if Assigned(ActExtExecProcObj) then ActExtExecProcObj( CurAction );
    end; // with CurAction do

  end; // for i := 0 to GroupActList.Count-1 do // along All Self Actions

  //***** Free all actions marked with $01000 bit
  WasDeleted := False;
  for i := 0 to GroupActList.Count-1 do
    if (TN_RFrameAction(GroupActList.Items[i]).ActFlags and $01000) <> 0 then
    begin
      GroupActList.Items[i].Free;
      GroupActList.Items[i] := nil;
      WasDeleted := True;
    end;

  if WasDeleted then GroupActList.Pack(); // delete nil pointers from the list
end; // procedure TN_SGBase.GExecAllActions

//************************************************ TN_SGBase.GExecOneAction ***
// Temporary create given Action (if not yet), execute it and
// delete, if it was just created
//
procedure TN_SGBase.GExecOneAction( AClassInd, AActFlags: integer );
var
  Ind: integer;
  JustCreated: boolean;
  CurAction: TN_RFrameAction;
  TmpRFAClass: TN_RFAClass;
begin
  Ind := GetActionByClass( AClassInd );
  JustCreated := False;
  if Ind = -1 then
  begin
    JustCreated := True;
    TmpRFAClass := N_RFAClassRefs[AClassInd];
    Ind := GroupActList.Add( TmpRFAClass.Create );
    with TN_RFrameAction(GroupActList.Items[Ind]) do
    begin
      ActFlags := AActFlags;
      ActGroup := Self;
      SetActParams(); // can be used like constructor
    end;
  end;

  ForceAction := True;
  CurAction := TN_RFrameAction(GroupActList.Items[Ind]);
  with CurAction do
  begin
    Execute();
    if Assigned(ActExtExecProcObj) then ActExtExecProcObj( CurAction );
  end; // with CurAction do
  ForceAction := False;

  if JustCreated then
    GroupActList.Delete( Ind );

end; // procedure TN_SGBase.GExecOneAction


//********** TN_RFAShowAction class methods  **************

//******************************************* TN_RFAShowAction.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAShowAction.SetActParams();
begin
  ActName := 'RFShow';
  inherited;
end; // procedure TN_RFAShowAction.SetActParams();

//************************************************ TN_RFAShowAction.Execute ***
// Show Cursor Coords
//
procedure TN_RFAShowAction.Execute();
var
  Str: string;
  ResFPoint: TFPoint;
begin
  inherited;
  with ActGroup, ActGroup.RFrame do
  begin
    if rfafShowCoords in RFrActionFlags then // Show Cursor Coords
    begin
      if RVCTreeRoot = nil then Exit;
      ResFPoint := RVCTreeRoot.ConvFromPix( CCBuf, ShowCoordsType, [ccfRootScope] );

      with ResFPoint do
        Str := Format( PointCoordsFmt, [X,Y] );

      ShowString( ActFlags, Str );
    end; // if rfafShowCoords in RFrActionFlags then // Show Cursor Coords
  end; // with ARFrame do
end; // procedure TN_RFAShowAction.Execute


//********** TN_RFAShowColor class methods  **************

//******************************************** TN_RFAShowColor.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAShowColor.SetActParams();
begin
  ActName := 'RFShowColor';
  inherited;
end; // procedure TN_RFAShowColor.SetActParams();

//************************************************* TN_RFAShowColor.Execute ***
// Show Pixel Color under Cursor at MouseDown
//
procedure TN_RFAShowColor.Execute();
var
  Str: string;
begin
  inherited;
  with ActGroup, ActGroup.RFrame do
  begin
    if CHType <> htMouseDown then Exit;

    //*** Check if CCBuf is inside Raster!!!

    if 0 <> N_PointInRect( CCBuf, OCanv.CurCRect ) then
      Str := 'Out of Canvas'
    else // CCBuf is inside OCanv.CurCRect
    begin
      N_MEGlobObj.CurColor := GetPixel( OCanv.HMDC, CCBuf.X, CCBuf.Y );

      Str := 'Color = ' + N_ColorToHTMLHex(N_MEGlobObj.CurColor) + ' (' +
                             N_ColorToRGBDecimals(N_MEGlobObj.CurColor) + ')';
    end;

    ShowString( ActFlags, Str );
  end; // with ARFrame do
end; // procedure TN_RFAShowColor.Execute


//********** TN_RFAMouseAction class methods  **************

//****************************************** TN_RFAMouseAction.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAMouseAction.SetActParams();
begin
  ActName := 'RFMouse';
  inherited;
end; // procedure TN_RFAMouseAction.SetActParams();

//*********************************************** TN_RFAMouseAction.Execute ***
// Show Pixel Color under Cursor at MouseDown or
// Scroll Coords by Drugging Mouse or by MouseWheel
//
procedure TN_RFAMouseAction.Execute();
var
  Str: string;
  NewTopLeftRel, ShiftSize: TPoint;
begin
  if RFADisable then Exit;

  inherited;
  with ActGroup, ActGroup.RFrame do
  begin
    if (CHType = htMouseWheel) and ScrollByMouseWheel then // Scroll By Mouse Wheel
    begin
      if VScrollBar.Visible then // Scroll Vertically
      with VScrollBar do
      begin
        Position := Position - SmallChange*10*Round( CMWheel/120 );
        HVScrollBarChange( nil );
      end; // with VScrollBar do, if VScrollBar.Visible then // Scroll Vertically
    end; // if (CHType = htMouseWheel) and ScrollByMouseWheel then // Scroll By Mouse Wheel

    if CHType = htMouseDown then // Show Color or Start Scroll mode
    begin
      if rfafShowColor in RFrActionFlags then // Show Color under Cursor
      begin
        if 0 <> N_PointInRect( CCBuf, OCanv.CurCRect ) then // check if CCBuf is inside Rester!!!
          Str := 'Out of Canvas'
        else // CCBuf is inside OCanv.CurCRect
        begin
          N_MEGlobObj.CurColor := GetPixel( OCanv.HMDC, CCBuf.X, CCBuf.Y );

          Str := 'Color = ' + N_ColorToHTMLHex(N_MEGlobObj.CurColor) + ' (' +
                                 N_ColorToRGBDecimals(N_MEGlobObj.CurColor) + ')';
        end;

        ShowString( ActFlags, Str );
      end; // if rfafShowColor in RFrActionFlags then // Show Color under Cursor

      if rfafScrollCoords in RFrActionFlags then // Start Scroll mode
      begin
        StartScrollMode();
        Screen.Cursor := crDrag; // crHandPoint;
        Exit;
      end; // if rfafScrollCoords in RFrActionFlags then // Start Scroll mode

    end; // if CHType = htMouseDown then

    if (CHType = htMouseUp) and ScrollMode then // Stop Scroll mode
    begin
      Screen.Cursor := SavedCursor;
      ScrollMode := False;
    end; // if (CHType = htMouseUp) and ScrollMode then // Stop Scroll mode

    if (CHType = htMouseMove) and ScrollMode then // Do Scroll
    begin
       ShiftSize.X := Round( (SavedCCDst.X - CCDst.X) / RFRasterScale );
       ShiftSize.Y := Round( (SavedCCDst.Y - CCDst.Y) / RFRasterScale );
       NewTopLeftRel := N_Add2P( SavedTopLeft, ShiftSize );

       ShiftRFSrcPRect( NewTopLeftRel );
//       N_IAdd( Format( 'NewTopLeftRel=%d,%d', [NewTopLeftRel.X, NewTopLeftRel.Y] ) );
//       N_IAdd( Format( 'CCBuf=%d,%d', [CCBuf.X, CCBuf.Y] ) );
    end; // if (CHType = htMouseMove) and ScrollMode then // Do Scroll

  end; // with ARFrame do
end; // procedure TN_RFAMouseAction.Execute

//*********************************************** TN_RFAMouseAction.Execute ***
// Start Scroll Coords mode by Drugging cursor
//
procedure TN_RFAMouseAction.StartScrollMode();
begin
  with ActGroup, ActGroup.RFrame do
  begin
    ScrollMode   := True;
    SavedCCDst   := CCDst; // CCBuf can not be used, because CCBuf is not changed while drug!
    SavedTopLeft := N_Substr2P( RFSrcPRect.TopLeft, RFLogFRamePRect.TopLeft );
    SavedCursor  := Screen.Cursor;
  end;
end; // procedure TN_RFAMouseAction.StartScrollMode


//********** TN_RFAZoom class methods  **************

//************************************************* TN_RFAZoom.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAZoom.SetActParams();
begin
  ActName := 'RFZoom';
  inherited;
end; // procedure TN_RFAZoom.SetActParams();

//****************************************************** TN_RFAZoom.Execute ***
// MouseWheel and MouseDown handlers:
// Zoom User Coords if both Shift and Ctrl are UP
// Zoom Raster Scale if Shift is Down
//
procedure TN_RFAZoom.Execute();
var
  DX, DY: integer;
  PixCentr: TPoint;
  ScaleCoef: double;
  ZoomMode: TN_RFZoomMode;

  procedure RScale( ScaleCoef: double ); //***** local
  // Shift and Scale Raster by given Coef
  var
    NewRScale: float;
    NewSize: TPoint;
  begin
    with ActGroup.RFrame do
    begin
      NewRScale := RFRasterScale * ScaleCoef;
{  //N1??
      if NewRScale > 1 then // fine tune NewRScale
      begin
        NewRScale := Round(NewRScale);

        if NewRScale = RFRasterScale then
        begin
          if ScaleCoef > 1 then NewRScale := NewRScale + 1
                           else NewRScale := NewRScale - 1;
        end;
      end; // if NewRScale > 1 then // fine tune NewRScale
}
      RFRasterScale := NewRScale;

      NewSize.X := Round( (PaintBox.Width - VScrollBar.Width) / RFRasterScale );
      NewSize.Y := Round( (PaintBox.Height - HScrollBar.Height) / RFRasterScale );
      RFSrcPRect := N_RectMake( CCBuf, NewSize, DPoint( 0.5, 0.5 ) );
      RFSrcPRect := N_RectAdjustByMaxRect( RFSrcPRect, OCanv.CurCRect );
      RecalcPRects();
      SetCursorByDPCoords( CCBufD );
      ShowMainBuf();
    end; // with ARFrame, ARFrame.RFCurSGBase.PCurCS^ do
  end; // procedure RScale (local)

begin //********************************** body of TN_RFAZoom.Execute
  inherited;

  with ActGroup.RFrame do
  begin
   if RFFixedScale then Exit;

   if (CHType = htKeyDown) and ((Char(CKey.CharCode) = 'M')) then
    begin // toggle MeshEnabled
      MeshEnabled := not MeshEnabled;
      ShowMainBuf();
      Exit;
    end;

    if (ssShift in CMKShift) or (OnlyRasterScale) then //******** Raster Scale
    begin                // (same as UCoords Scale but may be with other coefs.)

      if (CHType = htKeyDown) and ((Char(CKey.CharCode) = 'A')) then // All
      begin                                          // Set RFRasterScaleCoef = 1
        RFRasterScale := 1;
        RecalcPRects();
        SetCursorByDPCoords( CCBufD );
        ShowMainBuf();
        Exit;
      end;

      if (CHType = htMouseDown) and ((Char(CKey.CharCode) = 'S')) then // Raster Shift
      begin      // Shift RFSrcPRect so, that current cursor pos will be in the Center
        StartMouseDownTimer();
        PixCentr := N_RectCenter( RFSrcPRect );
        DX := CCBuf.X - PixCentr.X;
        DY := CCBuf.Y - PixCentr.Y;

        RFSrcPRect := N_RectShift( RFSrcPRect, DX, DY );
        RFSrcPRect := N_RectAdjustByMaxRect( RFSrcPRect, OCanv.CurCRect );
        RecalcPRects();
        ShowMainBuf();
        Exit;
      end;

      if (CHType = htMouseDown) and ((Char(CKey.CharCode) = 'Z')) then // Raster Zoom
      begin                                      // by MouseDown while 'Z' is pressed
        StartMouseDownTimer();
        if CMButton = mbLeft  then RScale( 1.11 );
        if CMButton = mbRight then RScale( 1/1.11 );
      end;

      if CHType = htMouseWheel then // Raster Zoom by MouseWheel
      begin
        if CMWheel > 0 then
          RScale( 1.0 + 0.1*CMWheel/120 )
        else
          RScale( 1.0/(1.0 - 0.1*CMWheel/120) );
      end; // if CHType = htMouseWheel then
    end
    else //******************* User Coords Scale ******************************
    begin    // (same as Raster Scale but may be with other coefs.)

      if N_ActiveVTreeFrame <> nil then
        N_ActiveVTreeFrame.MarkedChanged := True; // Marked Comps CompIntPixRect changed

      if (CHType = htKeyDown) and ((Char(CKey.CharCode) = 'A')) then // All
      begin                           // View All(whole) Image in current Frame
        InitializeCoords();
        RedrawAllAndShow();
        Exit;
      end;

      if (CHType = htMouseDown) and ((Char(CKey.CharCode) = 'S')) then // Shift
      begin      // LogFrameRect so, that current cursor pos will be in the Center
        StartMouseDownTimer();
        PixCentr := N_RectCenter( RFSrcPRect );
        DX := CCBuf.X - PixCentr.X;
        DY := CCBuf.Y - PixCentr.Y;

        RFLogFramePRect := N_RectShift( RFLogFramePRect, -DX, -DY );
        RFLogFramePRect := N_RectAdjustByMinRect( RFLogFramePRect, OCanv.CurCRect );

        RecalcPRects();
        RedrawAllAndShow();
        Exit;
//        N_IAdd( Format( 'dx,dy:%d, %d', [DX,DY] )); // debug
      end;

      if (CHType = htMouseDown) and (rfafZoomByClick in RFrActionFlags) then // Zoom
      begin                                   // (same action as if MouseWheel)
        StartMouseDownTimer();
        if CMButton = mbLeft  then VectorScale( RFVectorScaleStep, [rfzfUseCursor] );
        if CMButton = mbRight then VectorScale( 1/RFVectorScaleStep, [rfzfUseCursor] );
      end;

      if CHType = htMouseWheel then // Zoom by MouseWheel
      begin
        ScaleCoef := 1.0 + 0.1*Abs(CMWheel)/120;

//        if CMWheel > 0 then VectorScale( ScaleCoef, N_ZFPoint, [vsfShiftInCenter] )        // Zoom In
//                       else VectorScale( 1.0 / ScaleCoef, N_ZFPoint, [vsfShiftInCenter] ); // Zoom Out

        ZoomMode := rfzmCursor;
        if rfifShiftAtZoom in RFInterfaceFlags then
          ZoomMode := rfzmCursorShift;

        if CMWheel > 0 then
        begin
          N_d1 := RFVectorScale;
          RFVectorScale := RFVectorScale * ScaleCoef;
          N_d2 := RFVectorScale;
          SetZoomLevel( ZoomMode );
          N_d1 := RFVectorScale;
        end else
        begin
          RFVectorScale := RFVectorScale / ScaleCoef;
          SetZoomLevel( ZoomMode );
        end;
      end; // if CHType = htMouseWheel then

    end; // else -- User Coords Scale
  end; // with ActGroup.RFrame do
end; // procedure TN_RFAZoom.Execute


//********** TN_RFAGetUPoint class methods  **************

//******************************************** TN_RFAGetUPoint.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAGetUPoint.SetActParams();
begin
  ActName := 'RFGetUPoint';
  inherited;
end; // procedure TN_RFAGetUPoint.SetActParams();

//************************************************* TN_RFAGetUPoint.Execute ***
// Call given ProcObj with Cursor Coords at MouseDown
//
procedure TN_RFAGetUPoint.Execute();
begin
  inherited;
  with ActGroup.RFrame do
  begin
    if CHType <> htMouseDown then Exit;
    if Assigned(DPProcObj) then DPProcObj( CCUser );
  end; // with ActGroup.RFrame do
end; // procedure TN_RFAGetUPoint.Execute


    //*********** Global Procedures  *****************************

//******************************************************* N_SetP2UAndRedraw ***
// Set new AffCoefs (by given AP2U coefs) to given ARFrame and Redraw it
//
procedure N_SetP2UAndRedraw( const AP2U: TN_AffCoefs4; ARFrame: TN_Rast1Frame );
var
  TmpURect: TFRect;
begin
  with ARFrame.OCanv do
  begin
    TmpURect := N_AffConvI2FRect1( CurCRect, AP2U );
    SetCoefsAndUCRect( TmpURect, CurCRect );
  end; // with ARFrame.RBuf do

  ARFrame.RedrawAllAndShow();
end; // procedure N_SetP2UAndRedraw

//************************************************** N_ShowCompInFullScreen ***
// Show given AComp In FullScreen mode
//
//     Parameters
// AComp - Component to show
//
// Create new TN_RastVCTForm (without Title and borders) with given AComp as
// Root Component and show it over the Full Screen.
// Close TN_RastVCTForm on any Key pressed or on MouseDown
//
procedure N_ShowCompInFullScreen( AComp: TN_UDCompVis );
var
  hTaskBar: THandle;
begin
  if AComp = nil then Exit; // a precaution

  with N_CreateRastVCTForm( nil ) do
  begin
    RVCTFToolBar1.Visible := False;
    StatusBar.Visible := False;
    BorderStyle := bsNone;
    Left   := N_CurMonWAR.Left;
    Top    := N_CurMonWAR.Top;
    Width  := N_RectWidth( N_CurMonWAR );
    Height := N_RectHeight( N_CurMonWAR );

    RFrame.RFDebName := 'FullScreen ';

    // Automatic realign does not work
    RFrame.Left   := 0;
    RFrame.Top    := 0;
    RFrame.Width  := Width;
    RFrame.Height := Height;

    RFrame.RVCTreeRootOwner := False;
    RFrame.RFFullScreenMode := 1;
    RFrame.RFCenterInDst    := True;
    RFrame.RFCenterInSrc    := True;
    RFrame.RFSkipAnimation  := True;

    hTaskbar := FindWindow( 'Shell_TrayWnd', nil );
    if hTaskbar <> 0 then
    begin
      EnableWindow( HTaskBar, FALSE ); // Disabled TaskBar
      ShowWindow( hTaskBar, SW_HIDE ); // Hide TaskBar
    end;

    //***** now always "fit in Window" mode is used
    InitVCTForm( AComp, mmfModal, @N_DefRFInitParams, @N_DefRFCoordsState );

    //***** possible variant - AComp Size in pixel is used
    //  InitVCTForm( AComp, mmfModal )

    if hTaskbar <> 0 then
    begin
      EnableWindow( HTaskBar, TRUE );        // Enabled TaskBar
      ShowWindow( hTaskBar, SW_SHOWNORMAL ); // Show TaskBar
    end;
  end; // with N_CreateRastVCTForm( nil ) do
end; // procedure N_ShowCompInFullScreen


{  RasterFrame Axtion Pattern
  Usage:
- add new RFrame Actions Index constant (N_ActPattern) in N_Rast1F[490 .. 557]
- copy TN_PatternRFA type definition below in Interface section
- copy TN_PatternRFA class methods below in Implementation section
- replace Pattern by real RFAction Name
- try to compile
- add statement
      N_RFAClassRefs[N_ActPattern] := TN_PatternRFA;
  in Initialization section or in spechial unit with initialization statements (like N_AVRInit)


//***  Interface section:
type TN_PatternRFA = class( TN_RFrameAction ) // PatternRFrame Action

  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure RedrawAction (); override;
end; // type TN_PatternRFA = class( TN_RFrameAction )
//***  end of Interface section

//***  Implementation section:
//****************  TN_PatternRFA class methods  *****************

//******************************************* TN_PatternRFA.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_PatternRFA.SetActParams();
begin
  ActName := 'Pattern';

  inherited;
end; // procedure TN_PatternRFA.SetActParams();

//************************************************ TN_PatternRFA.Execute ***
// Move or resize Self three Rects
//
procedure TN_PatternRFA.Execute();
begin

end; // procedure TN_PatternRFA.Execute

//******************************************* TN_PatternRFA.RedrawAction ***
// Redraw Temporary Action objects
// (should be called from RFrame.RedrawAll )
//
procedure TN_PatternRFA.RedrawAction();
begin
  with N_ActiveRFrame do
  begin
    OCanv.SetBrushAttribs( -1 );
    OCanv.SetPenAttribs( $999999, 1 );
//    OCanv.DrawUserRect( SRSelectionFRect );
    N_TestRectDraw( OCanv, 10, 20, $FF );
  end; // with N_ActiveRFrame, SRCMREdit2Form do

end; // procedure TN_PatternRFA.RedrawAction
//***  end of Implementation section

}

end.

