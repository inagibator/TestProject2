unit N_VRE3;
// low lewel classes and procedures for Vector Editor

     //**************** Params Record types  *************************
// TN_HighPointParams  = packed record // HighLight Point (Label) Params
// TN_EditPointParams  = packed record // Edit (move,add,delete) Point Params
// TN_EditLabelParams  = packed record // Edit (move,EditText) Label Params
// TN_HighLineParams   = packed record // HighLight Line Params
// TN_EditVertexParams = packed record // Edit(move,add,delete Line,Vertex) Params
// TN_EditCodesParams  = packed record // Edit any CObj Codes Params

     //**************** RFAction handlers  *************************
// TN_RFDebAction1     = class( TN_RFrameAction ) // Debug Action #1
// TN_RFAShowCObjInfo  = class( TN_RFrameAction ) // Show CObj Info
// TN_RFAShowUserInfo  = class( TN_RFrameAction ) // Show User Info about CObj
// TN_RFAMarkCObjPart  = class( TN_RFrameAction ) // Mark CObj Part
// TN_RFAHighPoint     = class( TN_RFrameAction ) // HighLight Point
// TN_RFAMovePoint     = class( TN_RFrameAction ) // Edit(move,add,delete) Point
// TN_RFAAddPoint      = class( TN_RFrameAction ) // Add new Point
// TN_RFADeletePoint   = class( TN_RFrameAction ) // Delete Point
// TN_RFAMoveLabel     = class( TN_RFrameAction ) // Move Label (change Shift)
// TN_RFAEditLabel     = class( TN_RFrameAction ) // Edit Label's Text
// TN_RFAHighLine      = class( TN_RFrameAction ) // HighLight Line
// TN_RFAEditVertex    = class( TN_RFrameAction ) // Edit(all actions) Vertex
// TN_RFADeleteLine    = class( TN_RFrameAction ) // Delete Line
// TN_RFASplitCombLine = class( TN_RFrameAction ) // Delete Split, CombLine Line
// TN_RFAAffConvLine   = class( TN_RFrameAction ) // Aff Conv Line
// TN_RFAEditItemCode  = class( TN_RFrameAction ) // Edit any CObj codes
// TN_RFAEditRegCodes  = class( TN_RFrameAction ) // Edit ULines RegCodes
// TN_RFASnapToCObj    = class( TN_RFrameAction ) // Snap Vertex to CObj
// TN_RFASetShapeCoords= class( TN_RFrameAction ) // Set Shape Center

interface
uses Windows, Classes, Contnrs, StdCtrls, Menus, Forms, Types,
     N_Types, N_Lib1, K_UDT1, N_UDat4, N_Gra0, N_Gra1, N_Rast1Fr, K_Script1,
     N_SGComp, N_UDCMap, N_ME1;

type TN_CobjCodes = packed record // Cobj Code and RC1, RC2
  LCItemCode: integer;
  LCRC1: integer;
  LCRC2: integer;
end; // type TN_CobjCodes
type TN_PCobjCodes = ^TN_CobjCodes;

     //**************** Params Record types  *************************
type TN_HighPointParams = packed record //***** HighLight Point (Label) Params
  HPointMode: integer; // HighLight Point Mode:
    // =0 - do not HighLight Point
    // =1 - HighLight BasePoint by HBPAttr
    // =2 - HighLight Label by HLabelAttr
    // =3 - HighLight both BasePoint and Label
  HBPAttr:    TN_PointAttr1;   // BasePoint highlighting attributes
  HLabelAttr: TN_PixRectAttr1; // Label highlighting attributes
end; // type TN_HighPointParams = record
type TN_PHighPointParams = ^TN_HighPointParams;

type TN_EditPointParams = packed record //***** Edit(move,add,del) Point Params
  EPMode: integer; // Move Point Mode:
    // =0 - move with Left Button Down (drug) (Finish at Button Up)
    // =1 - move with Left Button Up (Finish at next Button Down)
  EPStartMode: integer; // Start Moving Mode:
    // =0 - do nothing
    // =1 - draw by EPStartAttr attributes
  EPFinMode: integer; // Finish Moving Mode:
    // =0 - redraw whole Map
    // =1 - draw by EPFinAttr attributes
  EPStartAttr: TN_PointAttr1; // Start  Drawing Attributes
  EPMoveAttr:  TN_PointAttr1; // Move   Drawing Attributes
  EPFinAttr:   TN_PointAttr1; // Finish Drawing Attributes
  EPNewPointsCL: TN_UDPoints; // CObjLayer for New Points
end; // type TN_EditPointParams = record
type TN_PEditPointParams = ^TN_EditPointParams;

type TN_EditLabelParams = packed record //***** Edit (move,EditText) Label Params
  ELMode: integer; // Move Label Mode:
    // =0 - move with Left Button Down (drug) (Finish at Button Up)
    // =1 - move with Left Button Up (Finish at next Button Down)
  ELStartMode: integer; // Start Moving Mode:
    // =0 - do nothing
    // =1 - draw by ELStartAttr attributes
  ELFinMode: integer; // Finish Moving Mode:
    // =0 - redraw whole Map
    // =1 - draw by ELFinAttr attributes
  ELStartAttr: TN_PixRectAttr1; // Start  Drawing Attributes
  ELMoveAttr:  TN_PixRectAttr1; // Move   Drawing Attributes
  ELFinAttr:   TN_PixRectAttr1; // Finish Drawing Attributes
end; // type TN_EditLabelParams = record
type TN_PEditLabelParams = ^TN_EditLabelParams;

type TN_HighLineParams = packed record //***** HighLight Line Params
  HLineMode: integer; // HighLight whole current Line Mode:
    // =0 - do not HighLight whole Line
    // =1 - HighLight as Simple Line by SimpleLineAttr attributes
    // =2 - HighLight as SysLine by TN_SysLineAttr attributes
  HSegmVertMode: integer; // HighLight current Segment and Vertex:
    // =0 - HighLight None
    // =1 - HighLight only Segment
    // =2 - HighLight only Vertex
    // =3 - HighLight both Segment and Vertex
  HNormLineAttr: TN_NormLineAttr; // Normal Line highlighting attributes
  HSysLineAttr: TN_SysLineAttr;   // SysLine highlighting attributes
  HSegmAttr: TN_NormLineAttr;     // current Segment highlighting attributes
  HVertAttr: TN_PointAttr1;       // current Vertex highlighting attributes
end; // type TN_HighLineParams = record
type TN_PHighLineParams = ^TN_HighLineParams;

type TN_EditVertexParams = packed record // Edit(move,add,delete Line,Vertex) Params
  EVMode: integer; // Move Vertex Mode:
    // =0 - move with Left Button Down (drug) (Finish at Button Up)
    // =1 - move with Left Button Up (Finish at next Button Down)
  EVStartMode: integer; // Start Moving Mode:
    // =0 - do nothing
    // =1 - draw by EVStartAttr attributes
  EVFinMode: integer; // Finish Moving Mode:
    // =0 - redraw whole Map
    // =1 - draw by EVFinAttr attributes
  EVComVertMode: integer; // Move Common Vertex Mode:
    // =0 - move all Vertexes with same coords (belonging to several lines)
    // =1 - move only one Vertex that belongs to current line
    // =2 - move all if Ctrl Key is Up, move only one if Ctrl Key is Down
  EVSnapMode: integer; // Snap mode while moving Vertex:
    // =0 - do not snap to any CObj near Cursor, do not highlight it
    // =1 - do not snap, only highlight CObj near Cursor
    // =2 - snap to beg or last Vertexes only
    // =3 - snap to all Vertexes including internal ones
    // =4 - snap to segments only (do not snap to any Vertexes)
    // =5 - snap to segments or to any Vertexes
  EVSplitMode: integer; // Split Mode for current and snapped CObj:
    // =0 - do not change current or snapped CObj
    // =1 - add new Vertex if snapped to Segment, do not split
    // =2 - split both current and snapped Lines
  EVStartSegmAttr: TN_NormLineAttr; // Start Segment Drawing Attributes
  EVStartVertAttr: TN_PointAttr1;   // Start Vertex  Drawing Attributes
  EVMoveSegmAttr:  TN_NormLineAttr; // Move  Segment Drawing Attributes
  EVMoveVertAttr:  TN_PointAttr1;   // Move  Vertex  Drawing Attributes
  EVFinSegmAttr:   TN_NormLineAttr; // Finish Segment Drawing Attributes
  EVFinVertAttr:   TN_PointAttr1;   // Finish Vertex  Drawing Attributes
  EVHighVertAttr:  TN_PointAttr1;   // Highlight Vertex  Drawing Attributes
  EVNewLinesCL:    TN_ULines;       // CObjLayer for New Lines
//  EVNewContoursCL: TN_UContours;    // CObjLayer for New Contours
end; // type TN_EditVertexParams = record
type TN_PEditVertexParams = ^TN_EditVertexParams;

type TN_EditCodesParams = packed record //***** Edit any CObj Codes Params
  Mode: integer; // not used now
end; // type TN_EditCodesParams = record
type TN_PEditCodesParams = ^TN_EditCodesParams;

type TN_MarkCObjParams = packed record // Mark CObj Params
  P:  TN_PointAttr1;   // Point highlighting attributes
  Li: TN_SysLineAttr;  // SysLine highlighting attributes
  La: TN_PixRectAttr1; // Label highlighting attributes
end; // type TN_MarkCObjParams
type TN_PMarkCObjParams = ^TN_MarkCObjParams;

type TN_MarkPointsFlags = set of ( mpfShowInds );

type TN_MarkPointsParams = packed record // Mark CObj Params
  MarkPointsFlags: TN_MarkPointsFlags;
  MarkPointsAttr:  TN_PointAttr1;  // marking attributes
end; // type TN_MarkPointsParams
type TN_PMarkPointsParams = ^TN_MarkPointsParams;

     //**************** RFAction handlers  *************************

type TN_RFDebAction1 = class( TN_RFrameAction ) //*** Debug Action
  DebugFlags: integer;

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFDebAction1 = class( TN_RFrameAction )

type TN_RFAShowCObjInfo = class( TN_RFrameAction ) //*** Show CObj Info
  CDimInd: integer;

  procedure SetActParams (); override;
  procedure Execute (); override;
end; // type TN_RFAShowCObjInfo = class( TN_RFrameAction )

type TN_RFAMarkCObjPart = class( TN_RFrameAction ) //*** AMarkCObjPart
  PActParams: TN_PMarkCObjParams; // Ptr to all MarkCObj Params

  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure RedrawAction (); override;
end; // type TN_RFAMarkCObjPart = class( TN_RFrameAction )

type TN_RFAMarkPoints = class( TN_RFrameAction ) //*** Mark Points Action
  PActParams: TN_PMarkPointsParams; // Ptr to all Mark Points Params
  DPoints: TN_DPArray;
  NumPoints: integer;

  procedure SetActParams (); override;
  procedure RedrawAction (); override;
end; // type TN_RFAMarkPoints = class( TN_RFrameAction )

type TN_RFASetItemCodes = class( TN_RFrameAction ) //*** Set Sequential Items CCodes
  FirstClick: boolean;
  CurCCode:   integer;
  CDimInd:    integer;

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFASetItemCodes = class( TN_RFrameAction )

type TN_RFAHighPoint = class( TN_RFrameAction ) //*** HighLight Point
  PActParams: TN_PHighPointParams; // Ptr to all Highlighting Point Params

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAHighPoint = class( TN_RFrameAction )

type TN_RFAMovePoint = class( TN_RFrameAction ) //*** Edit(move,add,del) Point
  PParams: TN_PEditPointParams; // Ptr to all needed params
  MoveState: boolean;    // moving with Left Button Up
  DrugState: boolean;    // moving with Left Button Down (Drugging)
  EdCL: TN_UDPoints;     // CObj layer being edited
  InitialBP: TDPoint;    // initial BasePoint coords

  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure FinishMoving ( FinPos: TDPoint );
end; // type TN_RFAMovePoint = class( TN_RFrameAction )

type TN_RFAAddPoint = class( TN_RFrameAction ) //*** Add new Point
  PParams: TN_PEditPointParams; // Ptr to all needed params
  AutoCode: integer;      // New Points Code

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAAddPoint = class( TN_RFrameAction )

type TN_RFADeletePoint = class( TN_RFrameAction ) //*** Delete Point
  PParams: TN_PEditPointParams; // Ptr to all needed params
  EdCL: TN_UDPoints;          // CObj layer being edited (for Undo)
  DeletedItemInds: TN_IArray; // Deletes Items (Points goups) Indexes (for Undo)

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFADeletePoint = class( TN_RFrameAction )

type TN_RFAMoveLabel = class( TN_RFrameAction ) //*** Move Label (change Shift)
  PParams: TN_PEditLabelParams; // Ptr to all needed params
  MoveState: boolean;    // moving with Left Button Up
  DrugState: boolean;    // moving with Left Button Down (Drugging)
  InitialPRect: TRect;   // initial Label Pixel Rect coords
  InitialCP: TPoint;     // initial Cursor Position (in pixels)
  ClearFillBMP: boolean; // Params.FillBMP should be cleared (Free TBitmap)
  PCLShift: PFPoint;     // Pointer to Current (moving) Label Shift

  procedure SetActParams (); override;
  procedure Execute      (); override;
  procedure FinishMoving ( FinPos: TPoint );
end; // type TN_RFAMoveLabel = class( TN_RFrameAction )

type TN_RFAAddLabel = class( TN_RFrameAction ) //*** Add new Point and Label

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAAddLabel = class( TN_RFrameAction )

type TN_RFADeleteLabel = class( TN_RFrameAction ) //*** Delete Point and Label

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFADeleteLabel = class( TN_RFrameAction )

type TN_RFAEditLabel = class( TN_RFrameAction ) //*** Edit Label's Text
  PParams: TN_PEditLabelParams; // Ptr to all needed params

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAEditLabel = class( TN_RFrameAction )

type TN_RFAHighLine = class( TN_RFrameAction ) //*** HighLight Line
  PActParams: TN_PHighLineParams; // Ptr to all needed params

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAHighLine = class( TN_RFrameAction )

type TN_RFAEditVertex = class( TN_RFrameAction ) //*** Edit Vertex ( all operations)
  PParams: TN_PEditVertexParams; // Ptr to all needed params
  EVMenu: TPopupMenu;    // EditVertex Popup menu
  MoveState: boolean;    // moving with Left Button Up
  DrugState: boolean;    // moving with Left Button Down (Drugging)
  EVMenuState: boolean;  // Action is called from EVMenuHandler
  ContLineState: boolean;// Continue Line (add new beg or end Vertexes) state
  EdCL: TN_ULines;       // CObj layer being edited
  NewVertsDC: TN_DPArray; // New Vertexes Double Coords
  EdItemInd: integer;    // Edited Line Item Index
  EdItemPartInd: integer;// Edited Line ItemPart Index
  EdVertInd: integer;    // Edited Line Vertex Index
  EDFPInd: integer;      // index of moving Vertex in Coords
  VertexRefs: TN_VertexRefs;  // references to moving Vertex
  RubberLine: TN_DPArray;     // for drawing moving segments
  InitialVertCoords: TDPoint; // saved Coords for Undo
//  InitialLineSize: integer;   // for deleteing only newelly added Vertexes
  SubAction: integer;     // SubAction Code (one of ngsEV... constants)

  procedure SetActParams   (); override;
  procedure Execute        (); override;
  procedure RedrawAction   (); override;
  procedure EVMenuShow     ();
  procedure EVMenuHandler  ( Sender: TObject );
  procedure DrawRubberSegments  ( PAttribs: TN_PNormLineAttr );
  procedure DrawNewVertsDC      ( PAttribs: TN_PNormLineAttr );
  procedure StartMoveCurVertex  ();
  procedure FinishMoveCurVertex ();
  procedure AddVertOnSegm  ();
  procedure DeleteCurVert  ();
  procedure StartNewLine   ();
  procedure EnlargeLine    ();
  procedure AddVertToLine  ();
  procedure DeleteLastVert ();
  procedure DeleteNewVerts ();
  procedure FinishLine     ();
end; // type TN_RFAEditVertex = class( TN_RFrameAction )

type TN_RFADeleteLine = class( TN_RFrameAction ) //*** Delete Line
  PParams: TN_PEditVertexParams; // Ptr to all needed params
  EdCL: TN_ULines;        // CObj layer being edited (for Undo)
  EdItemInd: integer;     // Deleted ItemInd
  EdItemPartInd: integer; // Deleted ItemPartInd
  EdDC: TN_DPArray;       // Deleted Line Coords
  DeletedItemInds: TN_IArray; // Deletes Items (Line) Indexes (for Undo)

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFADeleteLine = class( TN_RFrameAction )

type TN_RFASplitCombLine = class( TN_RFrameAction ) //*** Delete Line
  PParams: TN_PEditVertexParams; // Ptr to all needed params
  EdCL: TN_ULines;        // CObj layer being edited (for Undo)
  EdItemInd: integer;     // Deleted ItemInd
  EdItemPartInd: integer; // Deleted ItemPartInd
  EdDC: TN_DPArray;       // Deleted Line Coords

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFASplitCombLine = class( TN_RFrameAction )

type TN_RFAAffConvLine = class( TN_RFrameAction ) //*** Delete Line
  PParams: TN_PEditVertexParams; // Ptr to all needed params
  ACLMenu: TPopupMenu;    // AffConvLine Popup menu
  MoveState: boolean;     // moving with Left Button Up
  DrugState: boolean;     // moving with Left Button Down (Drugging)
  ACLMenuState: boolean;  // Action is called from ACLMenuHandler
  ConvMode: integer;      // Aff. Convertion mode:
        // = 1 - one point is fixed, another is moving and aff. converting line
        // = 2 - line can only be shifted
  EdCL: TN_ULines;        // CObj layer being edited (for Undo)
  EdItemInd: integer;     // Edited ItemInd
  EdItemPartInd: integer; // Edited ItemPartInd
  EdVertInd: integer;     // Edited Vertex Ind
  EdDC: TN_DPArray;       // Edited Line Coords
  InitialDC: TN_DPArray;  // Initial Line Coords (for Undo)
  FixedPoint: TDPoint;    // Fixed Point coords
  InitialCPoint: TDPoint; // Initial Cursor Point coords
  AnyFixedPoint: boolean; // if True, FixedPoint is set by DoubleClick, otherwise
                          // it is Beg or End Line Point
                          // ( DoubleClick toggles AnyFixedPoint )
  procedure SetActParams   (); override;
  procedure Execute        (); override;
  procedure DrawEdDC       ( PAttribs: TN_PNormLineAttr );
  procedure StartConvLine1 ();
  procedure ConvLine1      ();
  procedure FinishConvLine ();
end; // type TN_RFAAffConvLine = class( TN_RFrameAction )

type TN_RFAEditItemCode = class( TN_RFrameAction ) //*** Edit any CObj Item code
  PParams: TN_PEditCodesParams; // Ptr to all needed params

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAEditItemCode = class( TN_RFrameAction )

type TN_RFAEditRegCodes = class( TN_RFrameAction ) //*** Edit ULines RegCodes
  PParams: TN_PEditCodesParams; // Ptr to all needed params

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFAEditRegCodes = class( TN_RFrameAction )

{
type TN_RFASnapToCObj = class( TN_RFrameAction ) //*** Snap Vertex to CObj
  PParams: TN_PEditVertexParams; // Ptr to all needed params
  SnapState: integer;
  SelCObj: TN_ULines;
  PrevVCoords: TDPoint;
  NewVCoords: TDPoint;
  VertexRefs: TN_VertexRefs;
  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFASnapToCObj = class( TN_RFrameAction )
}

type TN_RFASetShapeCoords = class( TN_RFrameAction ) //*** Set Shape Center

  procedure SetActParams (); override;
  procedure Execute      (); override;
end; // type TN_RFASetShapeCoords = class( TN_RFrameAction )


    //*********** RFrameActions Params  *****************************

var
  N_TmpMarkCObjParams: TN_MarkCObjParams = ( //******** MarkCObj Params
    P: (SShape:[sshPlus,sshCornerMult]; SBrushColor:-1; SPenColor:$FF00FF; SPenWidth:1; SSizeXY:(X:11;Y:11); SHotPoint:(X:0.5;Y:0.5));
    Li: ( AtLASColor: -1; AtLASWidth: 1;
          AtLBSColor: -1; AtLBSWidth: 1;
      AtLAV: (SShape:[sshRect]; SBrushColor:-1; SPenColor:$00FF00; SPenWidth:1; SSizeXY:(X:5;Y:5); SHotPoint:(X:0.5;Y:0.5));
      AtLBV: (SShape:[sshRect]; SBrushColor:-1; SPenColor:$00FF00; SPenWidth:1; SSizeXY:(X:5;Y:5); SHotPoint:(X:0.5;Y:0.5)); );
    La: (ModeFlags:$03; Border: (Color:$00FF00; Size:1); ABShift:0; FillColor:-1; FillBMP:nil); );

  N_TmpHighPointParams: TN_HighPointParams = ( // Highlight BasePoint and Label
    HPointMode:3;
    HBPAttr: (SShape:[sshPlus,sshCornerMult]; SBrushColor:-1; SPenColor:$00FF00; SPenWidth:1; SSizeXY:(X:11;Y:11); SHotPoint:(X:0.5;Y:0.5));
    HLabelAttr: (ModeFlags:$03; Border: (Color:$00FF00; Size:1); ABShift:0; FillColor:-1; FillBMP:nil); );

  N_TmpEditPointParams: TN_EditPointParams = (
    EPMode:0; EPStartMode:0; EPFinMode:0;
    EPStartAttr:(SShape:[sshRect]; SBrushColor:-1; SPenColor:$FFFFFF; SPenWidth:1; SSizeXY:(X:7;Y:7); SHotPoint:(X:0.5;Y:0.5));
    EPMoveAttr: (SShape:[sshPlus,sshCornerMult]; SBrushColor:-1; SPenColor:$00FF00; SPenWidth:1; SSizeXY:(X:11;Y:11); SHotPoint:(X:0.5;Y:0.5));
    EPFinAttr:  (SShape:[sshRect]; SBrushColor:-1; SPenColor:$880000; SPenWidth:1; SSizeXY:(X:7;Y:7); SHotPoint:(X:0.5;Y:0.5));
    EPNewPointsCL:nil );

  N_TmpEditLabelParams: TN_EditLabelParams = (
    ELMode:0; ELStartMode:0; ELFinMode:0;
    ELStartAttr:(ModeFlags:$23; Border: (Color:$00FF00; Size:1); ABShift:0; FillColor:-1; FillBMP:nil);
    ELMoveAttr: (ModeFlags:$23; Border: (Color:$00FF00; Size:1); ABShift:0; FillColor:-1; FillBMP:nil);
    ELFinAttr:  (ModeFlags:$23; Border: (Color:$00FF00; Size:1); ABShift:0; FillColor:-1; FillBMP:nil); );

  N_TmpHighLineParams1: TN_HighLineParams = (
    HLineMode:2; HSegmVertMode:3;
    HNormLineAttr: (Color:$FFDD00; Size:1);
    HSysLineAttr: (
      AtLASColor: $000088; AtLASWidth: 1;
      AtLBSColor: $0000FF; AtLBSWidth: 3;
      AtLAV: (SShape:[sshRect]; SBrushColor:-1; SPenColor:$000088; SPenWidth:1; SSizeXY:(X:3;Y:3); SHotPoint:(X:0.5;Y:0.5); );
      AtLBV: (SShape:[sshRect]; SBrushColor:-1; SPenColor:$000088; SPenWidth:1; SSizeXY:(X:5;Y:5); SHotPoint:(X:0.5;Y:0.5)); );
    HSegmAttr: (Color:$FF00FF; Size:1);
    HVertAttr: (SShape:[sshRect]; SBrushColor:-1; SPenColor:$FF00FF; SPenWidth:1; SSizeXY:(X:9;Y:9); SHotPoint:(X:0.5;Y:0.5)); );

  N_TmpEditVertexParams: TN_EditVertexParams = (
    EVMode:0;         EVStartMode:0;  EVFinMode:0;
    EVComVertMode:0;  EVSnapMode:0;   EVSplitMode:0;
    EVStartSegmAttr:(Color:$FFFFFF; Size:1);
    EVStartVertAttr:(SShape:[sshRect]; SBrushColor:-1; SPenColor:$FFFFFF; SPenWidth:1; SSizeXY:(X:7;Y:7); SHotPoint:(X:0.5;Y:0.5));
    EVMoveSegmAttr: (Color:$00FF00; Size:1);
    EVMoveVertAttr: (SShape:[sshPlus,sshCornerMult]; SBrushColor:-1; SPenColor:$00FF00; SPenWidth:1; SSizeXY:(X:11;Y:11); SHotPoint:(X:0.5;Y:0.5));
    EVFinSegmAttr:  (Color:$000000; Size:1);
    EVFinVertAttr:  (SShape:[sshRect]; SBrushColor:-1; SPenColor:$880000; SPenWidth:1; SSizeXY:(X:7;Y:7); SHotPoint:(X:0.5;Y:0.5));
    EVHighVertAttr: (SShape:[sshRect]; SBrushColor:-1; SPenColor:$880000; SPenWidth:1; SSizeXY:(X:3;Y:3); SHotPoint:(X:0.5;Y:0.5));
    EVNewLinesCL:nil );

  N_TmpEditCodesParams: TN_EditCodesParams = (Mode:0);

  N_TmpLabels1:      TK_UDRArray;
  N_TmpLabelsPRects: TK_UDRArray;
  N_TmpLabelsShifts: TK_UDRArray;

    //*********** Global Procedures  *****************************

function  N_SetEditGroup ( ARFrame: TN_Rast1Frame; AUDMapLayer: TN_UDMapLayer;
                                                AMode: integer ): TN_SGMLayers;
function  N_SetEditAction ( AClassInd, AFlags, ARGInd: integer ): TN_RFrameAction;
procedure N_FillSRArray ( var AnRArray: TK_RArray; Prefix: string;
               BegValue, Step, NumVals: integer; FirstInd: integer = 0 );
procedure N_FillFPRArray ( var AnRArray: TK_RArray; BegValue, Step: TFPoint;
                                     NumVals: integer; FirstInd: integer = 0 );
procedure N_FillFRArray  ( var AnRArray: TK_RArray; MinValue, MaxValue: Float;
                                     NumVals: integer; FirstInd: integer = 0 );
procedure N_FillDRArray  ( var AnRArray: TK_RArray; MinValue, MaxValue: double;
                                     NumVals: integer; FirstInd: integer = 0 );

var
  N_TmpGroupsDescrs: TK_UDRArray;

implementation
uses SysUtils, Math, Controls, Clipbrd,
     K_FrRaEdit, K_DCSpace,
     N_Lib0, N_Gra3, N_LibF, N_Lib2, N_ClassRef, N_InfoF, N_Deb1,
     N_EdStrF, N_CObjVectEdF, N_GS1; //

//****************************** TN_RFA... objects methods **********

//********************************* TN_RFDebAction1.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFDebAction1.SetActParams();
begin
  ActName := 'DebAction1';
  inherited;
end; // procedure TN_RFDebAction1.SetActParams();

//********************************* TN_RFDebAction1.Execute ***
// Show debug info in N_MemoForm
//
procedure TN_RFDebAction1.Execute();
var
  Str: string;
begin
  with ActGroup.RFrame do
  begin

    if (RFDebugFlags and $010) <> 0 then
    begin
      case CHType of
      htMouseDown:  Str := 'MouseDown';
      htMouseMove:  Str := 'MouseMove';
      htMouseUp  :  Str := 'MouseUp';
      htMouseWheel: Str := 'MouseWheel';
      htDblClick :  Str := 'DblClick';
      htKeyDown  :  Str := 'KeyDown';
      htKeyUp    :  Str := 'KeyUp';
      htOthers   :  Str := 'Others';
      end;

      Str := Str + '(' + IntToStr(ActCounter) + ')';
      ShowString( ActFlags, Str );
    end; // if (RFDebugFlags and $010) <> 0 then

    if (CHType = htKeyDown) and           //***** Edit Debug Flags
       (ssShift in CMKShift) and (ssCtrl in CMKShift) and
       (Char(CKey.CharCode) = 'D')  then
    begin
      Str := '$' + IntToHex(RFDebugFlags, 8);
      N_EditString( Str, 'Debug Flags:' );
      RFDebugFlags := StrToInt( Str );
    end;

  end; // with RFrame do
end; // procedure TN_RFDebAction1.Execute


//***************************************** TN_RFAShowCObjInfo.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAShowCObjInfo.SetActParams();
begin
  ActName := 'ShowCObjInfo';
  inherited;
end; // procedure TN_RFAShowCObjInfo.SetActParams();

//********************************************** TN_RFAShowCObjInfo.Execute ***
// ShowInfo about CurCObj (CObj under Cursor) in MouseMove
//
// ActFlags - where and what to Show:
//   bits0-7 ($00FF) - where to Show (see TN_Rast1Frame.ShowString)
//   bits8-11($0F00) - what Info to Show (can be combined by OR):
//     =$0000 - nothing
//     =$0100 - not used now
//     =$0200 - Name, Index and Code (RC1,RC2 for lines)
//     =$0400 - InfoStrings
//
procedure TN_RFAShowCObjInfo.Execute();
var
  CSInd: integer;
  Str, Str2: string;
  CS: TK_UDDCSpace;
  DCoords: TN_DPArray;
  CurDPoint: TDPoint;
  AddToSavedStrings: boolean;
begin
  inherited;
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
  begin

  if SRType =  srtNone then Exit;
  if CurMLCObj = nil    then Exit;

  AddToSavedStrings := False;
  if CHType = htKeyDown then
  begin
    if (Char(CKey.CharCode) = 'c') or (Char(CKey.CharCode) = 'C') or   // Latin C
       (Char(CKey.CharCode) = 'ñ') or (Char(CKey.CharCode) = 'Ñ') then // Cyrillic C
      AddToSavedStrings := True;
  end;

  if (CHType <> htMouseMove) and not AddToSavedStrings then Exit;

  if NCurSR > 1 then // more than one selected objects
  begin
    ShowString( ActFlags, Format( '*** %d Selected Objects! ***', [NCurSR] ) );
    Exit;
  end; // if NCurSR > 1 then

  case CurMLCObj.CI() of
    N_UDPointsCI: Str := 'DP';
    N_ULinesCI:
      if TN_ULines(CurMLCObj).WLCType = N_FloatCoords then  Str  := 'FL'
                                                      else  Str  := 'DL';
    N_UContoursCI: Str := 'UC';
  else
    Str := '?';
  end; // case CurMLCObj.CI() of

  if ResultInd >= 0 then
    Str := Str + Format( '(SR=%d)', [ResultInd] );

  if (ActFlags and $0200) <> 0 then // show LayerName, ItemInd, Code (PartInd)
  with CurMLCObj do                 // and RC1,RC2 if needed
  begin

    //******************* create Str with LayerName, ItemInd, Code
    Str2 := '';
    if PartInd > 0 then
      Str2 := Format( '(%d)', [PartInd] );

    Str := Str + Format( ',  %s Ii=%d%s, C=(%s)',
                           [ObjName, ItemInd, Str2, GetItemAllCodes(ItemInd)] );

    if SRType = srtPoint then // additional info forPoints
    with TN_UDPoints(CurMLCObj) do
    begin
      CurDPoint := GetPointCoords( ItemInd, PartInd );
      with CurDPoint do
        Str := Str + Format( ' (X=%f, Y=%f)', [X,Y] );
    end; // with TN_UDPoints(CurMLCObj) do, if SRType = srtPoint then // additional info forPoints

    if SRType = srtLine then // additional info for Lines
    with TN_ULines(CurMLCObj) do
    begin
      GetPartDCoords( ItemInd, PartInd, DCoords );

      if SegmInd >= 0 then
      begin
        with DCoords[SegmInd] do
          Str := Str + Format( ', Si=%d (X1=%f, Y1=%f; ', [SegmInd,X,Y] );

        with DCoords[SegmInd+1] do
          Str := Str + Format( 'X2=%f, Y2=%f)', [X,Y] );
      end; // if SegmInd >= 0 then

      if VertInd >= 0 then
      begin
        with DCoords[VertInd] do
          Str := Str + Format( ', Vi=%d (X=%f, Y=%f)', [VertInd,X,Y] );
      end; // if VertInd >= 0 then
    end; // with TN_ULines(CurMLCObj) do, if SRType = srtLine then // additional info for Lines

    if SRType = srtContour then // additional info for Contours
    begin
      Str := Str + Format( ', R i(l)=%d(%d)', [PartInd, VertInd] ); // index, level
    end; // if SRType = srtContour then

    //***** Show Code Name if CurMLCObj has some CodesSubSpace

    CS := CurMLCObj.GetCS;
    CSInd := CurMLCObj.GetCSInd( ItemInd, CDimInd );
    if (CS <> nil) and (CSInd <> -1) then
      with TK_PDCSpace(CS.R.P)^ do
        Str := Str + ', ' + PString(Names.P(CSInd))^;

{ // old var
    CSS := CurMLCObj.GetCSS();
    if CSS <> nil then
    begin
      CS := CSS.GetDCSpace();
      CSInd := PInteger(CSS.DP(ItemInd))^;
      if CSInd <> -1 then
        with TK_PDCSpace(CS.R.P)^ do
          Str := Str + ', ' + PString(Names.P(CSInd))^;
    end; // if CSS <> nil then
}
  end; // with CurMLCObj do // if (ActFlags and $0200) <> 0 then

  ShowString( ActFlags, Str );

  if AddToSavedStrings then
    SavedStrings.Add(Str);

  end; // with ActGroup, ActGroup.RFrame do
end; // procedure TN_RFAShowCObjInfo.Execute

{
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

  // debug
  N_ADS( Format( '%d %d %d %d', [SRCompInd, ItemInd,
              PInteger(ReIndVects[0].R.P)^, PInteger(ReIndVects[1].R.P)^ ] ));
  N_i := SRCompInd;
  N_i := ItemInd;
  N_i := PInteger(ReIndVects[0].R.P)^;
  Ind := TN_UDMapLayer(SComps[SRCompInd].SComp).PCMapLayer^.MLCObj.GetItemFirstCode( ItemInd, 0 );

  if (Ind >= 0) and (Ind <= High(InfoStrings)) then
    Str := InfoStrings[Ind]
  else
    Str := '';

  ShowString( ActFlags, Str );

  end; // with ActGroup, ActGroup.RFrame do
end; // procedure TN_RFAShowUserInfo.Execute
}


//********************************* TN_RFAMarkCObjPart.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAMarkCObjPart.SetActParams();
begin
  PActParams := @N_TmpMarkCObjParams;
  ActName    := 'MarkCObjPart';
  inherited;
end; // procedure TN_RFAMarkCObjPart.SetActParams();

//********************************* TN_RFAMarkCObjPart.Execute ***
// Mark, Unmark or clear MarkedCObjParts
//
procedure TN_RFAMarkCObjPart.Execute();
var
  i, MaxInd: integer;
begin
  inherited;
  with TN_SGMLayers(ActGroup), OneSR, PCMapLayer^, ActGroup.RFrame, PActParams^ do
  begin
    if CHType <> htMouseDown then Exit;

    if NCurSR = 0 then // no highlited Coords Object, clear All MarkedCObjParts
    begin
      MarkedCObjParts := nil;
      RedrawAllAndShow();
    end else //********** toggle CObjPart under Cursor
    begin
      MaxInd := High(MarkedCObjParts);
      for i := 0 to MaxInd do // check if already marked
      with MarkedCObjParts[i] do
      begin
        if (MCObj <> CurMLCObj) or (MItem <> OneSR.ItemInd) or
           (MPart <> OneSR.PartInd) then Continue; // check next element

        //***** UnMark - exclude i-th element from MarkedCObjParts
        if i < MaxInd then
          move( MarkedCObjParts[i+1], MarkedCObjParts[i],
                                      (MaxInd-i)*SizeOf(MarkedCObjParts[0]) );
        SetLength( MarkedCObjParts, MaxInd ); // decrease array
        RedrawAllAndShow();
        Exit;
      end; // for i := 0 to MaxInd do // check if already marked

      //***** Mark CObjPart under Cursor - add it to MarkedCObjParts

      SetLength( MarkedCObjParts, MaxInd+2);
      with MarkedCObjParts[MaxInd+1] do
      begin
        MCObj := CurMLCObj;
        MItem := OneSR.ItemInd;
        MPart := OneSR.PartInd;
      end;

      RedrawAction(); // full redrawing is not needed
    end; // else //********** toggle CObjPart under Cursor

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAMarkCObjPart.Execute

//********************************* TN_RFAMarkCObjPart.RedrawAction ***
// Mark MarkedCObjParts objects
//
procedure TN_RFAMarkCObjPart.RedrawAction();
var
  i: integer;
  DC: TN_DPArray;
  DP: TDPoint;
begin
  with TN_SGMLayers(ActGroup), OneSR, PCMapLayer^, ActGroup.RFrame, PActParams^ do
  begin

  // skip temporary redrawing while MarkedCObjParts are Aff. converted
  // (SkipRedrawing is a Pointer to be able to use AddNewClearVarAction( @SkipRedrawing ) )
  if TN_CObjVectEditorForm(UCObjEdForm).SkipRedrawing <> nil then Exit;

  for i := 0 to High(MarkedCObjParts) do
  with MarkedCObjParts[i] do
  begin

    if MCObj.CI = N_UDPointsCI then //**************** Mark Points
    begin
      DP := TN_UDPoints(MCObj).GetPointCoords( MItem, MPart );
      NGlobCont.DrawUserPoint( DP, @PActParams.P );
    end else if MCObj.CI = N_ULinesCI then //******** Mark Lines
    begin
      TN_ULines(MCObj).GetPartDCoords( MItem, MPart, DC );
      NGlobCont.DrawUserSysPolyline( @DC[0], Length(DC), @PActParams.Li );
    end;

  end; // for i := 0 to High(MarkedCObjParts) do

  end; // with TN_SGMLayers(ActGroup), OneSR, PCMapLayer^, ActGroup.RFrame, PActParams^ do
end; // procedure TN_RFAMarkCObjPart.RedrawAction


//********************************* TN_RFAMarkPoints.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAMarkPoints.SetActParams();
begin
//  PActParams := @N_TmpMarkCObjParams;
  ActName    := 'MarkPoints';
  inherited;
end; // procedure TN_RFAMarkPoints.SetActParams();

//********************************* TN_RFAMarkPoints.RedrawAction ***
// Mark MarkedCObjParts objects
//
procedure TN_RFAMarkPoints.RedrawAction();
var
  i: integer;
begin
  with ActGroup.RFrame, PActParams^ do
  begin

  for i := 0 to NumPoints-1 do
  begin
    if i = 0  then
    begin
      MarkPointsAttr.SShape := MarkPointsAttr.SShape - [sshPlus];
      MarkPointsAttr.SShape := MarkPointsAttr.SShape + [sshCornerMult];
    end else
      MarkPointsAttr.SShape := MarkPointsAttr.SShape + [sshPlus,sshCornerMult];

    NGlobCont.DrawUserPoint( DPoints[i], @MarkPointsAttr );
//    Clipboard.AsText := N_PointToStr( DPoints[i], '%.8g %.8g' );

  end; // for i := 0 to NumPoints-1 do

  end; // with TN_SGMLayers(ActGroup), OneSR, PCMapLayer^, ActGroup.RFrame, PActParams^ do
end; // procedure TN_RFAMarkPoints.RedrawAction


//********************************* TN_RFASetItemCodes.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFASetItemCodes.SetActParams();
begin
  ActName    := 'SetItemCodes';
  FirstClick := True;
  CurCCode   := 0;
  ActGroup.RFrame.ShowString( 1, 'Click on initial CObj Item' );
  inherited;
end; // procedure TN_RFASetItemCodes.SetActParams();

//********************************* TN_RFASetItemCodes.Execute ***
// Set sequential Items Codes (each Click sets next CCode), initial CCode
// is defined by first Clicked Item
//
procedure TN_RFASetItemCodes.Execute();
var
  CurCC: integer;
begin
  inherited;
  with TN_SGMLayers(ActGroup), OneSR, PCMapLayer^, ActGroup.RFrame do
  begin
    if CHType <> htMouseDown then Exit;
    if NCurSR = 0 then  Exit;

    if FirstClick then // initialize CurCCode
    begin
//      CurCC := CurMLCObj.Items[OneSR.ItemInd].CCode;
      CurMLCObj.GetItemTwoCodes( OneSR.ItemInd, CDimInd, CurCC, N_i ); // get CurCC
      FirstClick := False;
      if CurCC = -1 then // use CurCCode as initial CCode value
      begin
//        CurMLCObj.Items[OneSR.ItemInd].CCode := CurCCode
        CurMLCObj.SetItemTwoCodes( OneSR.ItemInd, CDimInd, CurCCode, -1 );
      end else
      begin
//        CurCCode := CurMLCObj.Items[OneSR.ItemInd].CCode;
        CurCCode := CurCC;
      end
    end else // not first Click, assign next CurCCode
    begin
      Inc( CurCCode );
//      CurMLCObj.Items[OneSR.ItemInd].CCode := CurCCode;
        CurMLCObj.SetItemTwoCodes( OneSR.ItemInd, CDimInd, CurCCode, -1 );
    end;
    ShowString( 1, 'CCode = ' + IntToStr( CurCCode ) );
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do

  RedrawAction();
end; // procedure TN_RFASetItemCodes.Execute


//********************************* TN_RFAHighPoint.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAHighPoint.SetActParams();
begin
  PActParams := @N_TmpHighPointParams;
  ActName := 'HighPoint';
  inherited;
end; // procedure TN_RFAHighPoint.SetActParams();

//********************************* TN_RFAHighPoint.Execute ***
// Highlight Point (and Point's Label) CObj under Cursor (in MouseMove handler)
//
procedure TN_RFAHighPoint.Execute();
var
  FPInd, NumPoints: integer;
  BP: TDPoint;
begin
  inherited;
  with TN_SGMLayers(ActGroup), OneSR, PCMapLayer^, ActGroup.RFrame, PActParams^ do
  begin
    // try to skip not needed drawing
    if not DoHighlight then Exit;
    if (SRType <> srtPoint) and (SRType <> srtPixRect) then Exit;
    StartHighlighting();

    if ((HPointMode = 1) or (HPointMode = 3)) and
       (SRType = srtPoint) then // Highlight Base Point
    begin
      BP := TN_UDPoints(CurMLCObj).GetPointCoords( ItemInd, PartInd );
      NGlobCont.DrawUserPoint( BP, @HBPAttr );
    end;

    if ((HPointMode = 2) or (HPointMode = 3)) and
       (SRType = srtPixRect) then // Highlight PixRect (Sign or Label)
    begin
      if TN_UDMapLayer(CurSComp).MLPRects <> nil then
      begin
        CurMLCObj.GetItemInds( ItemInd, FPInd, NumPoints );
        OCanv.DrawPixRect( TN_UDMapLayer(CurSComp).MLPRects[FPInd+PartInd], 1, @HLabelAttr );
      end;
    end;

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAHighPoint.Execute


//********************************* TN_RFAMovePoint.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAMovePoint.SetActParams();
begin
  PParams  := @N_TmpEditPointParams;
  ActName  := 'MovePoint';
  ActRGInd := 1; // CObj Edit Action
end; // procedure TN_RFAMovePoint.SetActParams();

//********************************* TN_RFAMovePoint.Execute ***
// 1) Begin moving Point under Cursor by MouseDown
// 2) Move Point with LeftButton Down or not
// 3) Cancel moving by Escape
//
procedure TN_RFAMovePoint.Execute();
  label HighInNewPos;
begin
  inherited;
  if PParams = nil then Exit; // a precaution

  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin

    if CHType = htMouseDown then //**** Start or Finish moving
    begin
      if SRType <> srtPoint then Exit;
      if CurMLCObj.CI() <> N_UDPointsCI then Exit;

      EdCL  := TN_UDPoints(CurMLCObj);
      InitialBP := EdCL.GetPointCoords( ItemInd, PartInd );

      if MoveState then // Finish moving
        FinishMoving( CursorUPoint )
      else //************* Start moving
      begin
        ForceHighlighting := True;

        if EPMode = 0 then
          DrugState := True
        else
          MoveState := True;

        StartPermanent();
        if EPStartMode = 1 then // Clear Point in initial position
          NGlobCont.DrawUserPoint( InitialBP, @EPStartAttr );

        goto HighInNewPos;
      end;
    end; // if CHType = htMouseDown then //**** Start or Finish moving

    if (CHType = htMouseMove) and (MoveState or DrugState) then // move Point
    begin
      HighInNewPos : //**************
      StartHighlighting();
      NGlobCont.DrawUserPoint( CursorUPoint, @EPMoveAttr ); // high in new pos.
      Exit;
    end; // if CHType = htMouseMove and (MoveState or DrugState) then // move Point

    if (CHType = htMouseUp) and (DrugState) then // Finish moving
    begin
      FinishMoving( CursorUPoint );
      Exit;
    end; // Finish moving

    if (CHType = htKeyDown) and          // Cancel moving by Escape
       (CKey.CharCode = VK_ESCAPE) and
       (MoveState or DrugState) then
    begin
      FinishMoving( InitialBP );
    end; // Cancel moving by Escape

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAMovePoint.Execute

//********************************* TN_RFAMovePoint.FinishMoving ***
// Finish Moving Point
//
procedure TN_RFAMovePoint.FinishMoving( FinPos: TDPoint );
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin

    with EdCL do // set new points coords
      N_ChangePointsCoords( InitialBP, FinPos, @CCoords[0], Length(CCoords) );

    StartPermanent();

    if EPFinMode = 0 then
      RedrawAllAndShow()
    else if EPFinMode = 1 then // Draw Point in final position
      NGlobCont.DrawUserPoint( InitialBP, @EPFinAttr );

    DrugState := False;
    MoveState := False;
    ForceHighlighting := False;
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAMovePoint.FinishMoving


//********************************* TN_RFAAddPoint.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAAddPoint.SetActParams();
begin
  PParams := @N_TmpEditPointParams;
  ActRGInd := 1; // CObj Edit Action
  ActName := 'AddPoint';
  inherited;
end; // procedure TN_RFAAddPoint.SetActParams();

//********************************* TN_RFAAddPoint.Execute ***
// Add new Point ar cursor position by MouseDown
//
procedure TN_RFAAddPoint.Execute();
var
  TmpCL: TN_UDPoints;
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin

    if (CHType <> htMouseDown) then Exit;
    TmpCL := EPNewPointsCL; // Params field
    Assert(TmpCL <> nil, 'No CLayer' );

    with TmpCL do
    begin
      AddOnePointItem( CursorUPoint, -1 );
      CalcEnvRects();
    end;

    CurMapLayer.ClearReIndVectors();

    StartPermanent();
    if EPFinMode = 0 then
      RedrawAllAndShow()
    else if (EPFinMode = 1) then
      NGlobCont.DrawUserPoint( CursorUPoint, @EPFinAttr );

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAAddPoint.Execute


//********************************* TN_RFADeletePoint.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFADeletePoint.SetActParams();
begin
  PParams  := @N_TmpEditPointParams;
  ActRGInd := 1; // CObj Edit Action
  ActName  := 'DeletePoint';
  DeletedItemInds := nil; // clear all previously saved info
  inherited;
end; // procedure TN_RFADeletePoint.SetActParams();

//********************************* TN_RFADeletePoint.Execute ***
// Delete Point under Cursor by MouseDown,
// restore one last deletede Point by Escape
//
procedure TN_RFADeletePoint.Execute();
var
  IInd: integer;
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if (CHType = htMouseDown) then //********************* Delete Point
    begin
      if CurMLCObj.CI() <> N_UDPointsCI then Exit;
      if SRType <> srtPoint then Exit;
      EdCL := TN_UDPoints(CurMLCObj);

      with EdCL do
      begin
        N_PushInt( DeletedItemInds, ItemInd ); // save, to enable Undo
        SetEmptyFlag( ItemInd );
        SRType := srtNone; // to prevent showing deleted point

        StartPermanent();
        RedrawAllAndShow()
      end; // with EdCL do
    end; // Delete Point

    if (CHType = htKeyDown) and //****** Restore last deleted point by Escape
       (CKey.CharCode = VK_ESCAPE) then // Restore last Point
    begin
      IInd := N_PopInt( DeletedItemInds );
      if IInd >= 0 then
      begin
        EdCL.ClearEmptyFlag( IInd );
        StartPermanent();
        RedrawAllAndShow()
      end; // if IInd >= 0 then
    end; // Restore last deleted point by Escape
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFADeletePoint.Execute


//********************************* TN_RFAMoveLabel.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAMoveLabel.SetActParams();
begin
  PParams  := @N_TmpEditLabelParams;
  ActName  := 'MoveLabel';
  ActRGInd := 1; // CObj Edit Action
end; // procedure TN_RFAMoveLabel.SetActParams();

//********************************* TN_RFAMoveLabel.Execute ***
// Begin moving Label under cursor by MouseDown
// Move Point with LeftButton Down or not
// Cancel moving by Escape
//
procedure TN_RFAMoveLabel.Execute();
var
  DX, DY, FPInd, NumPoints: integer;
  CurPRect: TRect;
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, PCMapLayer^, ActGroup.RFrame, PParams^ do
  begin
    N_i := CurSFlags;
    if CHType = htMouseDown then //**** Start or Finish moving
    begin
      if MoveState then // Finish moving
      begin
        FinishMoving( CursorPPoint );
      end else //********* Start moving
      begin
        if SRType <> srtPixRect then Exit;
        if MLType <> mltHorLabels then Exit;

        CurMLCObj.GetItemInds( ItemInd, FPInd, NumPoints ); // only for NumPoints=1
        InitialPRect := TN_UDMapLayer(CurSComp).MLPRects[FPInd];

        PCLShift := PFPoint(CurMaplayer.PDVE2( FPInd ));
        if PCLShift = nil then Exit; // ShiftsXY is not given

        ForceHighlighting := True;
        if ELMode = 0 then
          DrugState := True
        else
          MoveState := True;

        InitialCP := CursorPPoint; // save Initial Cursor Position

        ClearFillBMP := False;
        with ELMoveAttr do // create FillBMP for moving if needed
          if ((ModeFlags and $020) <> 0) and
             (FillBMP = nil) then // FillBMP should be created
          begin
            OCanv.DrawPixRect( InitialPRect, 1, @ELMoveAttr ); // just create FillBMP
            ClearFillBMP := True;
          end;

        Assert( ELFinAttr.FillBMP = nil, 'Bad FillBMP' );
        ELFinAttr.FillBMP := ELMoveAttr.FillBMP;

        StartPermanent();
        if ELStartMode = 1 then // Clear Label in initial position
          OCanv.DrawPixRect( InitialPRect, 1, @ELStartAttr );

        StartHighlighting();
        OCanv.DrawPixRect( InitialPRect, 1, @ELMoveAttr ); // high in initial pos.
      end;
    end; // Start or Finish moving

    if (CHType = htMouseMove) and (MoveState or DrugState) then // move Point
    begin
      StartHighlighting();
      DX := CursorPPoint.X-InitialCP.X;
      DY := CursorPPoint.Y-InitialCP.Y;
      CurPRect := N_RectShift( InitialPRect, DX, DY );
      OCanv.DrawPixRect( CurPRect, 1, @ELMoveAttr ); // high in new pos.
    end; // move Point

    if (CHType = htMouseUp) and (DrugState) then // Finish moving
      FinishMoving( CursorPPoint );

    if (CHType = htKeyDown) and            // Cancel moving by Escape
       (CKey.CharCode = VK_ESCAPE)  and
       (MoveState or DrugState) then
    begin
      FinishMoving( InitialCP );
    end; // if (CHType = htMouseUp) and (not MoveSate) then // Finish moving
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAMoveLabel.Execute

//********************************* TN_RFAMoveLabel.FinishMoving ***
// Finish Moving Point
//
procedure TN_RFAMoveLabel.FinishMoving( FinPos: TPoint );
var
  DX, DY: integer;
  CurPRect: TRect;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    //***** Set new Label Shift (position)
    DX := FinPos.X-InitialCP.X;
    DY := FinPos.Y-InitialCP.Y;
    PCLShift^.X := PCLShift^.X + DX/OCanv.CurLSUPixSize; // update Label Shift
    PCLShift^.Y := PCLShift^.Y + DY/OCanv.CurLSUPixSize;

    StartPermanent();
    if ELFinMode = 0 then
      RedrawAllAndShow()
    else if ELFinMode = 1 then // Draw Label in final position
    begin
      CurPRect := N_RectShift( InitialPRect, DX, DY );
      OCanv.DrawPixRect( CurPRect, 1, @ELFinAttr );
    end;

    if ClearFillBMP then FreeAndNil( ELMoveAttr.FillBMP );
    ELFinAttr.FillBMP := nil;

    DrugState := False;
    MoveState := False;
    ForceHighlighting := False;
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAMoveLabel.FinishMoving

//********************************* TN_RFAAddLabel.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAAddLabel.SetActParams();
begin
  ActRGInd := 1; // CObj Edit Action
  ActName  := 'AddLabel';
  inherited;
end; // procedure TN_RFAAddLabel.SetActParams();

//********************************* TN_RFAAddLabel.Execute ***
// Add new Point and Label
//
procedure TN_RFAAddLabel.Execute();
var
  Leng: integer;
  UDLabels: TK_UDRArray;
  NewPointsML: TN_UDMapLayer;
begin
  inherited;
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
  begin
    // NewPointsML - Map Layer with UDPoints to edit
    //               (crrent Map Layer, beeing edited)

    if (CHType <> htMouseDown) then Exit;

    NewPointsML := TN_UDMapLayer(SComps[0].SComp);
    Assert(NewPointsML <> nil, 'No MapLayer for New Points!' );

    with NewPointsML.PISP^ do
    begin
      with TN_UDPoints(MLCObj) do
      begin
        Assert( CI = N_UDPointsCI, 'Not Points!' );
        AddOnePointItem( CursorUPoint, -1 );
        CalcEnvRects();

        UDLabels := MLDVect1;
        Assert( UDLabels <> nil, 'No Labels!' );
        
        if not (UDLabels is TK_UDVector) then
        begin
          Leng := UDLabels.PDRA^.ALength;
          if Leng < WNumItems then
            UDLabels.PDRA^.ASetLengthI( WNumItems );
        end; // if not UDLabels is TK_UDVector then
      end; // with TN_UDPoints(MLCObj) do
    end; // with ALNewPointsML.PSP^ do

    StartPermanent();
    RedrawAllAndShow();

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAAddLabel.Execute

//********************************* TN_RFADeleteLabel.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFADeleteLabel.SetActParams();
begin
  ActRGInd := 1; // CObj Edit Action
  ActName  := 'DeleteLabel';
  inherited;
end; // procedure TN_RFADeleteLabel.SetActParams();

//********************************* TN_RFADeleteLabel.Execute ***
// Delete Point and Label
//
procedure TN_RFADeleteLabel.Execute();
var
  UDLabels: TK_UDRArray;
begin
  inherited;
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
  begin
    if (CHType = htMouseDown) then //****************** Delete Point and Label
    begin
      if CurMLCObj.CI() <> N_UDPointsCI then Exit;
      if SRType <> srtPoint then Exit;

      with TN_UDPoints(CurMLCObj) do
      begin
        SetEmptyFlag( ItemInd );
        WIsSparse := True;
        CompactSelf();

        UDLabels := PCMapLayer^.MLDVect1;
        if not (UDLabels is TK_UDVector) then
          UDLabels.PDRA^.DeleteElems( ItemInd, 1 );

        SRType := srtNone; // to prevent showing deleted point
        StartPermanent();
        RedrawAllAndShow()
      end; // with TN_UDPoints(CurMLCObj) do
    end; // Delete Point and Label
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFADeleteLabel.Execute


//********************************* TN_RFAEditLabel.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAEditLabel.SetActParams();
begin
  PParams  := @N_TmpEditLabelParams;
  ActRGInd := 1; // CObj Edit Action
  ActName  := 'EditLabel';
  inherited;
end; // procedure TN_RFAEditLabel.SetActParams();

//********************************* TN_RFAEditLabel.Execute ***
// Edit Label's Text by MouseDown in TN_EditStringForm
// Enter key finishes editing
// Escape key cancels editing
//
procedure TN_RFAEditLabel.Execute();
var
  PLabel: Pointer;
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, PCMapLayer^, ActGroup.RFrame, PParams^ do
  begin
    if SRType =  srtNone     then Exit;
    if CHType <> htMouseDown then Exit;

    PLabel := TN_UDMaplayer(CurSComp).PDVE1( ItemInd ); // Pointer to Label or nil
    if PLabel = nil then Exit; // no Label to Edit

    if not N_EditString( PString(PLabel)^,
                                     'Edit Label', 250 ) then Exit; // Canceled
    RedrawAllAndShow();
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditLabel.Execute


//********************************* TN_RFAHighLine.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAHighLine.SetActParams();
begin
  PActParams := @N_TmpHighLineParams1;
  ActName := 'HighLine';
  inherited;
end; // procedure TN_RFAHighLine.SetActParams();

//********************************* TN_RFAHighLine.Execute ***
// HighLight Line CObj under Cursor (MouseMove handler)
//
procedure TN_RFAHighLine.Execute();
var
  i: integer;
  DCoords: TN_DPArray;
  CurCLine: TN_ULines;
begin
  inherited;
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PActParams^ do
  begin

    if (CHType = htKeyDown) and (CKey.CharCode = VK_CONTROL) and
       (RealNCurSR > 1) then
    begin // change ResultInd
      Inc(ResultInd);
      if ResultInd >= RealNCurSR then ResultInd := -1;

      //***** force searchig once again, only one object would be found
      PaintBoxMouseMove( nil, CMKShift, CMPos.X, CMPos.Y );
      Exit;
    end;

    // try to skip not needed drawing
    if not DoHighlight  then Exit;
    if SRType = srtNone then Exit; // to prevent highliting with old indexes

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do

//    N_IAdd( 'Before Highlight Line' ); // debug

  with TN_SGMLayers(ActGroup), ActGroup.RFrame, PActParams^ do
  begin
  StartHighlighting();

  for i := 0 to RealNCurSR-1 do // loop along all search components (MapLayers)
  with CurSR[i] do
  begin
    if CurSComp = nil then Continue; // a precaution

    //***** Highlight only ResultInd Search result (if >= 0)
    if (ResultInd >= 0) and (i <> ResultInd) then Continue;

    CurCLine := TN_ULines(CurMLCObj);
    if CurCLine.CI() <> N_ULinesCI then Continue; // skip not ULines CObjLayers

    CurCLine.GetPartDCoords( ItemInd, PartInd, DCoords );
{
    if Length(DCoords) = 0 then // debug
    begin
      N_i1 := ItemInd;
      N_i2 := PartInd;
      N_i1 := SRCompInd;
    end;
}

    if HLineMode = 1 then // Highlight whole Line as SimpleLine
      OCanv.DrawUserDPoly( @DCoords[0], Length(DCoords), @HNormLineAttr );

    if HLineMode = 2 then // Highlight whole Line as SysLine
      NGlobCont.DrawUserSysPolyline( @DCoords[0], Length(DCoords),
                                                             @HSysLineAttr );
    if (HSegmVertMode = 1) or (HSegmVertMode = 3) then // High cur Segment
    begin
      if SegmInd >= 0 then
        OCanv.DrawUserDPoly( @DCoords[SegmInd], 2, @HSegmAttr );
    end;

    if (HSegmVertMode = 2) or (HSegmVertMode = 3) then // High cur Vertex
    begin
      if VertInd >= 0 then
      begin
        NGlobCont.DrawUserPoint( DCoords[VertInd], @HVertAttr );
        if N_KeyIsDown( VK_SHIFT ) then
          Clipboard.AsText := N_PointToStr( DCoords[VertInd], '%.10g %.10g' );
      end;
    end;

  end; // for i := 0 to High(CurSR) do

  end; // with TN_SGMLayers(ActGroup), ActGroup.RFrame, PActParams^ do
end; // procedure TN_RFAHighLine.Execute


//********************************* TN_RFAEditVertex.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAEditVertex.SetActParams();
begin
  PParams   := @N_TmpEditVertexParams;
  ActRGInd  := 1; // CObj Edit Action
  ActName   := 'EditVertex';
  SubAction := ngsEVMChooseSubAct; // default initial SubAction

  if EVMenu = nil then // Create EVMenu
  begin
    EVMenu := TPopupMenu.Create( ActGroup.RFrame.Owner );
    EVMenu.Alignment := paCenter;
    N_CurrentMenu  := EVMenu;
    N_CurMIHandler := EVMenuHandler;

    N_CreateMenuItem( ngsEVMChooseSubAct );
    N_CreateMenuItem( ngsEVMMoveCurVert );
    N_CreateMenuItem( ngsEVMAddVertOnSegm  );
    N_CreateMenuItem( ngsEVMAddVertToLine );
//    N_CreateMenuItem( ngsMenuSeparator1 );
    N_CreateMenuItem( ngsEVMEnlargeLine );
    N_CreateMenuItem( ngsEVMStartNewLine );
    N_CreateMenuItem( ngsEVMFinishLine, VK_SPACE );
    N_CreateMenuItem( ngsEVMDelCurVert );
    N_CreateMenuItem( ngsEVMDelLastVert, VK_ESCAPE );
    N_CreateMenuItem( ngsEVMDelNewVerts );
  end; // if AVMenu = nil then
  ActName := 'EditVertex';
  inherited;
end; // procedure TN_RFAEditVertex.SetActParams();

//********************************* TN_RFAEditVertex.Execute ***
// call needed SubAction
//
procedure TN_RFAEditVertex.Execute();
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin

    if (CHType = htMouseDown) and (ssRight in CMKShift) then //*** Right Click
    begin
      if SRType = srtNone  then Exit;
      EVMenuShow();
      Exit;
    end; //*** Right Click

    if (CHType = htMouseMove) and (MoveState or DrugState) then // move Cur Vertex
    begin
      RubberLine[0] := CursorUPoint;
      DrawRubberSegments( @EVMoveSegmAttr );
      Exit;
    end; //***** move Cur Vertex

    if (CHType = htMouseMove) and ContLineState then // move New Segm
    begin
      NewVertsDC[High(NewVertsDC)] := CursorUPoint;
      StartHighlighting();
      DrawNewVertsDC( @EVMoveSegmAttr );
      Exit;
    end; //***** move New Segm

    if ((CHType = htMouseUp)   and (DrugState)) or
       ((CHType = htMouseDown) and (MoveState)) then //***** Finish moving
    begin
      FinishMoveCurVertex();
      Exit;
    end; //***** Finish moving

    if (CHType = htKeyDown) and //************** Cancel moving by Escape
       (CKey.CharCode = VK_ESCAPE) and
       (MoveState or DrugState) then
    begin
      RubberLine[0] := InitialVertCoords;
      FinishMoveCurVertex();
      Exit;
    end; // Cancel moving by Escape

    if (CHType = htKeyDown) and //************** Finish Line by Space
       (CKey.CharCode = VK_SPACE) and ContLineState then
    begin
      FinishLine();
      Exit;
    end; // Finish Line by Space

    if (CHType = htKeyDown) and //************** Delete Last vertex by Escape
       (CKey.CharCode = VK_ESCAPE) and ContLineState then
    begin
      DeleteLastVert();
      Exit;
    end; // Delete Last vertex by Escape

    if (CHType = htKeyUP) and //**** restore Highlighting in KeyUp
       (CKey.CharCode = VK_ESCAPE) and ContLineState then
    begin
      StartHighlighting();
      DrawNewVertsDC( @EVMoveSegmAttr );
      Exit;
    end; // Delete Last vertex by Escape

    if (CHType = htMouseDown) and (SubAction <> -1) then //*** Exec cur SubAction
    begin
      if SubAction = ngsEVMAddVertOnSegm then
        AddVertOnSegm()
      else if SubAction = ngsEVMMoveCurVert then
        StartMoveCurVertex()
      else if SubAction = ngsEVMDelCurVert then
        DeleteCurVert()
      else if SubAction = ngsEVMEnlargeLine then
        EnlargeLine()
      else if SubAction = ngsEVMStartNewLine then
        StartNewLine()
      else if SubAction = ngsEVMAddVertToLine then
        AddVertToLine()
      else
        Assert( False, 'Bad SubAction' );
    end; //***** Execute current SubAction

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.Execute

//********************************* TN_RFAEditVertex.RedrawAction ***
// Redraw
// (should be called from RFrame.RedrawAll )
//
procedure TN_RFAEditVertex.RedrawAction();
begin
  if ContLineState then
    DrawNewVertsDC( @(PParams^.EVMoveSegmAttr) );
end; // procedure TN_RFAEditVertex.RedrawAction

//********************************* TN_RFAEditVertex.EVMenuShow ***
// Enable proper EVMenu Options and show it
//
procedure TN_RFAEditVertex.EVMenuShow();
var
  DC: TN_DPArray;
  ScreenPos: TPoint;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
  begin
    N_SetMenuItems( EVMenu, [N_MIHide or ngsAllMenuItems] ); // Hide all
    if ContLineState then
      N_SetMenuItems( EVMenu, [ngsEVMAddVertToLine, ngsEVMFinishLine,
                               ngsEVMDelLastVert,   ngsEVMDelnewVerts] )
    else //************** not ContLineState
    begin
      N_SetMenuItems( EVMenu, [ngsEVMStartNewLine] );

      if CurMLCObj.CI() = N_ULinesCI then
      begin
        if VertInd >= 0 then
        begin
          N_SetMenuItems( EVMenu, [ngsEVMMoveCurVert, ngsEVMDelCurVert] );

          TN_ULines(CurMLCObj).GetPartDCoords( ItemInd, PartInd, DC );
          if (VertInd = 0) or (VertInd = High(DC)) then
          begin  // first or last Line Vertex
            N_SetMenuItems( EVMenu, [ngsEVMAddVertToLine] );
          end;

//          TN_ULines(CurMLCObj).GetVertexRefs( DC[VertInd], 0, VertexRefs );
//          if Length(VertexRefs) <= 1 then // internal

        end; // if VertInd >= 0 then

        if SegmInd >= 0 then
          N_SetMenuItems( EVMenu, [ngsEVMAddVertOnSegm] );
      end; // if CurMLCObj.CI() = N_ULinesCI then

    end; // else // not ContLineState

    ScreenPos := PaintBox.ClientToScreen( Point( CCDST.X, CCDST.Y ));
    // AVMenuHandler handler will be called inside AVMenu.Popup
    EVMenu.Popup( ScreenPos.X, ScreenPos.Y+5 );
//    N_IAdd( 'After Menu Popup' ); // debug
    SkipMouseMove := True;
    Mouse.CursorPos := ScreenPos; // set cursor back (at RighClick position)
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.EVMenuShow

//********************************* TN_RFAEditVertex.EVMenuHandler ***
// EVMenu OnClick event handler for all menu items
// (is called just after exit from RFrame.MouseDown handler)
//
procedure TN_RFAEditVertex.EVMenuHandler( Sender: TObject );
var
  MICode, Ind: integer;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
  begin
    EVMenuState := True;
    MICode := TMenuItem(Sender).Tag and $FFFF;

    //***** Prepare for drawing after all Actions
    DoHighlight := True;
    PermanentDraw := True;
    OCanv.ClearPrevPhase();
//    N_IAdd( 'From Menu Handler' ); // for debug

    if MICode = ngsEVMAddVertOnSegm then
      AddVertOnSegm()
    else if MICode = ngsEVMDelCurVert then
      DeleteCurVert()
    else if MICode = ngsEVMMoveCurVert then
      StartMoveCurVertex()
    else if MICode = ngsEVMEnlargeLine then
      EnlargeLine()
    else if MICode = ngsEVMStartNewLine then
      StartNewLine()
    else if MICode = ngsEVMFinishLine then
      FinishLine()
    else if MICode = ngsEVMAddVertToLine then
      AddVertToLine()
    else if MICode = ngsEVMDelLastVert then
      DeleteLastVert()
    else if MICode = ngsEVMDelNewVerts then
      DeleteNewVerts()
    else
      Assert( False, 'Bad MICode' );

    Ind := GetActionByClass( N_ActHighLine );
    if Ind <> -1 then
      TN_RFrameAction(GroupActList.Items[Ind]).Execute(); // Highlight Line

    //***** Finish drawing
    DoHighlight := False;
    ShowNewPhase();
    EVMenuState := False;
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.EVMenuHandler

//********************************* TN_RFAEditVertex.DrawRubberSegments ***
// Draw RubberSegments (while moving Vertex) by given attributes
//
procedure TN_RFAEditVertex.DrawRubberSegments( PAttribs: TN_PNormLineAttr );
var
  i: integer;
  Segm: Array [0..1] of TDPoint;
begin
  with TN_SGMLayers(ActGroup), RFrame do
  begin
    StartHighlighting();
    Segm[0] := RubberLine[0];
    for i := 1 to High(RubberLine) do
    begin
      Segm[1] := RubberLine[i];
      OCanv.DrawUserDPoly( @Segm[0], 2, PAttribs );
//      ShowMainBuf();(); // debug
    end;
  end;
end; // procedure TN_RFAEditVertex.DrawRubberSegments

//********************************* TN_RFAEditVertex.DrawNewVertsDC ***
// Draw NewVertsDC (in ContLineState) by given attributes
//
procedure TN_RFAEditVertex.DrawNewVertsDC( PAttribs: TN_PNormLineAttr );
begin
  with TN_SGMLayers(ActGroup), RFrame, PParams^ do
    OCanv.DrawUserDPoly( @NewVertsDC[0], Length(NewVertsDC), PAttribs );
end; // procedure TN_RFAEditVertex.DrawNewVertsDC

//********************************* TN_RFAEditVertex.StartMoveCurVertex ***
// Start Moving Current Vertex
//
procedure TN_RFAEditVertex.StartMoveCurVertex();
var
  i: integer;
  DC, TmpDLine: TN_DPArray;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if SRType <> srtLine then Exit;
    if CurMLCObj.CI() <> N_ULinesCI then Exit;
    if VertInd = -1 then Exit;

    ForceHighlighting := True; // highlight on all MouseMoves
    if (EVMode = 0) and not EVMenuState then
      DrugState := True
    else
      MoveState := True;

    //***** Create RubberLine and VertexRefs

    EdCL := TN_ULines(CurMLCObj);
    EdCL.GetPartDCoords( ItemInd, PartInd, DC );
    InitialVertCoords := DC[VertInd]; // for Undo
    EDFPInd := EdCL.WrkFPInd;
    SetLength( TmpDLine, 3 );
    EdCL.GetVertexRefs( DC[VertInd], 1, VertexRefs );

    if (VertInd > 0) and
       (VertInd < High(DC)) then // internal Vertex
    begin
      SetLength( RubberLine, 3 );

      if ((EVComVertMode = 1) or
          (EVComVertMode = 2) and (ssCtrl in CMKShift)) and
         (Length(VertexRefs) > 1) then // several Vertexes are highlited, choose
      begin
        SetLength( VertexRefs, 1 ); // force only one Vertex to move
      end;

      RubberLine[0] := DC[VertInd];
      RubberLine[1] := DC[VertInd-1];
      RubberLine[2] := DC[VertInd+1];
    end else // external vertex, may be common to several lines
    begin
      SetLength( RubberLine, Length(VertexRefs)+1 );
      RubberLine[0] := DC[VertInd];

      //***** check if move only one vertex (from current Line Segment)

      if ((EVComVertMode = 1) or
          (EVComVertMode = 2) and (ssCtrl in CMKShift)) and
         (Length(VertexRefs) > 1) then // several Vertexes are highlited, choose
      begin                       // one of them by ItemInd and PrevSegmInd
        SetLength( VertexRefs, 1 ); // force only one Vertex
        VertexRefs[0].ItemInd := ItemInd;
        SetLength( RubberLine, 2 ); // one Segment

        if Length(DC) = 2 then // Line consists of one Segment and
        begin                  // PrevSegmInd is always = 0, set it
          if N_Same( RubberLine[0], DC[1] ) then PrevSegmInd := 1;
        end;

        if PrevSegmInd = 0 then // move beg Line Vertex (with Ind=0)
        begin
          VertexRefs[0].CCInd := EDFPInd;
          RubberLine[1] := DC[1]
        end else //************** move last Line Vertex
        begin
          VertexRefs[0].CCInd := EDFPInd + High(DC);
          RubberLine[1] := DC[High(DC)-1];
        end;

      end; // if ((EVComVertMode = 1) or ...

      if (EVComVertMode = 3) and
         (Length(VertexRefs) > 1) then // several Vertexes are highlited, choose
      begin                            // one of them that is in OneSR
        // not implemented, may be not needed
      end; // if (EVComVertMode = 3) and

      //***** temporary delete moving segments
      //      to prevent highliting them while moving

      for i := 0 to High(VertexRefs) do // along all references to Vertex
      with EdCL, VertexRefs[i] do
      begin
        if VFlags = 0 then // first Vertex
        begin
          GetOneDPoint( CCInd+1, RubberLine[i+1] );
          SetOneDPoint( CCInd,   RubberLine[i+1] );
        end else //********** last Vertex
        begin
          GetOneDPoint( CCInd-1, RubberLine[i+1] );
          SetOneDPoint( CCInd,   RubberLine[i+1] );
        end;
      end; // for i := 0 to High(VertexRefs) do

    end; // else // external vertex, may be common to several lines

      //***** Here: RubberLine and VertexRefs created

    if EVStartMode = 1 then // Clear Moving Segments in initial position
    begin
      StartPermanent();
      DrawRubberSegments( @EVStartSegmAttr );
    end;

    // Highlight Moving Segments in initial position
    DrawRubberSegments( @EVMoveSegmAttr );

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.StartMoveCurVertex

//********************************* TN_RFAEditVertex.FinishMoveCurVertex ***
// snap RubberLine[0] if needed,
// Update Coords in EdCL by RubberLine[0] and VertexRefs,
// Split lines if needed,
// Draw RubberLine with Final attributes if needed,
// clear all states and arrayes
// (used in MouseUP, in second MouseDown and in cancell by Escape)
//
procedure TN_RFAEditVertex.FinishMoveCurVertex();
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    //***** just set new (snapped) value to RubberLine[0]
    SnapToCurCObj( EVSnapMode, RubberLine[0], RubberLine[0] );

    //***** change all needed coords in Layer
    EdCL.CangeVertexCoords( RubberLine[0], VertexRefs );

    //***** split all layers at RubberLine[0] Point
    SplitByPoint( EVSplitMode, RubberLine[0] );

    //***** indexes in CurSR are no more valid!

    StartPermanent();
    if EVFinMode = 0 then
      RedrawAllAndShow()
    else if EVFinMode = 1 then // Draw DrawRubberSegments in final position
      DrawRubberSegments( @EVFinSegmAttr );

    DrugState  := False;
    MoveState  := False;
    ForceHighlighting := False;

    SRType := srtNone; // to prevent highliting with old indexes in CurSR

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.FinishMoveCurVertex

//********************************* TN_RFAEditVertex.AddVertOnSegm ***
// Add new Vertex near cursor on current Segment
//
procedure TN_RFAEditVertex.AddVertOnSegm();
var
  NewVertex: TDPoint;
  TmpCL: TN_ULines;
  DC, TmpDLine: TN_DPArray;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if SRType <> srtLine then Exit;
    if CurMLCObj.CI() <> N_ULinesCI then Exit;
    if SegmInd = -1 then Exit;

    TmpCL := TN_ULines(CurMLCObj);
    TmpCL.GetPartDCoords( ItemInd, PartInd, DC );

    SetLength( TmpDLine, 3 );
    TmpDLine[0] := DC[SegmInd];
    TmpDLine[1] := DC[SegmInd+1];

    if EVStartMode = 1 then // Clear current Segment
    begin
      StartPermanent();
      OCanv.DrawUserDPoly( @TmpDLine[0], 2, @EVStartSegmAttr );
    end;

    NewVertex := N_ProjectPointOnSegm( CursorUPoint,
                                 DC[SegmInd], DC[SegmInd+1] );

    TmpDLine[2] := TmpDLine[1];
    TmpDLine[1] := NewVertex;
    if EVFinMode = 1 then // Draw two new Segments
    begin
      StartPermanent();
      OCanv.DrawUserDPoly( @TmpDLine[0], 3, @EVFinSegmAttr );
      NGlobCont.DrawUserPoint( NewVertex, @EVFinVertAttr );
    end;

//    ShowMainBuf();(); // for debug

    //************************ update Line Coords
    TmpDLine[0] := NewVertex; // to be able to use N_InsertArrayElems
    N_InsertArrayElems( DC, SegmInd+1, TmpDLine, 0, 1 );
    TmpCL.SetPartDCoords( ItemInd, PartInd, DC ); // Item Inds changed!

    if EVFinMode = 0 then
    begin
      StartPermanent();
      RedrawAllAndShow();
    end;

  SRType := srtNone; // for proper Highlighting (Item Inds were changed!)

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.AddVertOnSegm

//********************************* TN_RFAEditVertex.DeleteCurVert ***
// Delete Vertex near cursor on existed (not new) line
//
procedure TN_RFAEditVertex.DeleteCurVert();
var
  TmpCL: TN_ULines;
  DC, TmpDLine: TN_DPArray;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if SRType <> srtLine then Exit;
    if CurMLCObj.CI() <> N_ULinesCI then Exit;
    if VertInd = -1 then Exit;

    TmpCL := TN_ULines(CurMLCObj);
    TmpCL.GetPartDCoords( ItemInd, PartInd, DC );
    SetLength( TmpDLine, 3 );

    if (VertInd <> 0) and
       (VertInd <> High(DC)) then // internal line vertex
    begin
      TmpDLine[0] := DC[VertInd-1];
      TmpDLine[1] := DC[VertInd];
      TmpDLine[2] := DC[VertInd+1];

      if EVStartMode = 1 then // clear permanently adjacent segments
      begin
        StartPermanent();
        OCanv.DrawUserDPoly( @TmpDLine[0], 3, @EVStartSegmAttr );
      end;

      TmpDLine[1] := TmpDLine[2]; // new segment coords

      if EVFinMode = 1 then // draw permanently new segment
      begin
        StartPermanent();
        OCanv.DrawUserDPoly( @TmpDLine[0], 2, @EVFinSegmAttr );
      end;

    end else // beg or last vertex, may be common to several lines
    begin
      TmpCL.GetVertexRefs( DC[VertInd], 0, VertexRefs );

      if Length(VertexRefs) > 1 then Exit; // do not delete VertInd
      if Length(DC) <= 2 then Exit;

      TmpDLine[0] := DC[VertInd]; // get beg or last Line segment coords
      if VertInd = 0 then // beg segment
        TmpDLine[1] := DC[1]
      else //********************** last segment
        TmpDLine[1] := DC[High(DC)-1];

      if EVStartMode = 1 then // clear permanently beg or last Line segment
      begin
        StartPermanent();
        OCanv.DrawUserDPoly( @TmpDLine[0], 2, @EVStartSegmAttr );
      end;
    end; // else // beg or last vertex, may be common to several lines

    //***** delete VertInd Point from DC
    N_DeleteArrayElems( DC, VertInd, 1 );
    TmpCL.SetPartDCoords( ItemInd, PartInd, DC );

    if EVFinMode = 0 then
    begin
      StartPermanent();
      RedrawAllAndShow();
    end;

  SegmInd := VertInd-1; // for more nice, but not correct, Highlighting
  VertInd := -1;

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.DeleteCurVert

//********************************* TN_RFAEditVertex.StartNewLine ***
// Start new Line and set ContLine State
//
procedure TN_RFAEditVertex.StartNewLine();
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    ContLineState := True;
    ForceHighlighting := True; // highlight on all MouseMoves
    SubAction := ngsEVMAddVertToLine;
    EdCL := nil; // used as "New Line" flag
    SetLength( NewVertsDC, 2 );

    SnapToCurCObj( EVSnapMode, CursorUPoint, NewVertsDC[0] );
    NewVertsDC[1] := NewVertsDC[0];
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.StartNewLine

//********************************* TN_RFAEditVertex.EnlargeLine ***
// Start enlarging (add new first or last vertexes) current Line
// and set ContLine State
//
procedure TN_RFAEditVertex.EnlargeLine();
var
  DC: TN_DPArray;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if SRType <> srtLine then Exit;
    if CurMLCObj.CI() <> N_ULinesCI then Exit;
    if VertInd = -1 then Exit;

    StartNewLine();

    EdVertInd := VertInd;
    EdItemInd := ItemInd;
    EdItemPartInd := PartInd;
    EdCL := TN_ULines(CurMLCObj);
    EdCL.GetPartDCoords( EdItemInd, EdItemPartInd, DC );
    NewVertsDC[0] := DC[VertInd];
    NewVertsDC[1] := NewVertsDC[0];
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.EnlargeLine

//********************************* TN_RFAEditVertex.AddVertToLine ***
// Add new Vertex to NewVertsDC
//
procedure TN_RFAEditVertex.AddVertToLine();
var
  LastInd: integer;
  UDelta: double;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if not ContLineState then Exit; // a precaution
    LastInd := High(NewVertsDC);
    SetLength( NewVertsDC, LastInd+2 );
    UDelta := CursorURect.Right - CursorURect.Left;

    if (EVSnapMode >= 2) and
       (N_P2PDistance( NewVertsDC[LastInd], NewVertsDC[0] ) < UDelta) then
      NewVertsDC[LastInd] := NewVertsDC[0]
    else
      //***** just set new (snapped if needed) value to NewVertsDC[LastInd]
      SnapToCurCObj( EVSnapMode, NewVertsDC[LastInd], NewVertsDC[LastInd] );

    NewVertsDC[LastInd+1] := NewVertsDC[LastInd];

    StartHighlighting();
    DrawNewVertsDC( @EVMoveSegmAttr );
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.AddVertToLine

//********************************* TN_RFAEditVertex.DeleteLastVert ***
// Delete last new vertex (only in ContLine State)
// (restore initial line or delete newly created line for last vertex)
//
procedure TN_RFAEditVertex.DeleteLastVert();
var
  LastInd: integer;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if not ContLineState then Exit; // a precaution
    LastInd := High(NewVertsDC);
    if LastInd <= 1 then // no more Vertexes to delete, Cancel ContLineState
      DeleteNewVerts()
    else
    begin
      NewVertsDC[LastInd-1] := NewVertsDC[LastInd];
      SetLength( NewVertsDC, LastInd ); // delete last point
      StartHighlighting();
      DrawNewVertsDC( @EVMoveSegmAttr );
    end
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.DeleteLastVert

//********************************* TN_RFAEditVertex.DeleteNewVerts ***
// Delete all new (added to Line) vertexes (only in ContLine State)
// (restore initial line or delete newly created line)
//
procedure TN_RFAEditVertex.DeleteNewVerts();
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if not ContLineState then Exit; // a precaution
    ContLineState := False;
    ForceHighlighting := False; // do not highlight on all MouseMoves

    if EdCL = nil then
      SubAction := ngsEVMStartNewLine // restore SubAction
    else
      SubAction := ngsEVMEnlargeLine; // restore SubAction
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.DeleteNewVerts

//********************************* TN_RFAEditVertex.FinishLine ***
// Finish New or Current Line
//
procedure TN_RFAEditVertex.FinishLine();
var
  LastInd: integer;
  TmpCL: TN_ULines;
  TmpDLine, DC: TN_DPArray;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if not ContLineState then Exit; // a precaution
    LastInd := High(NewVertsDC);
    if LastInd = 1 then // empty Line
      DeleteNewVerts()
    else
      SetLength( NewVertsDC, LastInd ); // always delete last point

    if EdCL = nil then // Add New Line to NewLayer (may be CurMLCObj)
    begin
      TmpCL := EVNewLinesCL; // Params field
      Assert(TmpCL <> nil, 'No CLayer' );
      EdItemInd := -1;
      EdItemPartInd := -1;
      TmpCL.SetPartDCoords( EdItemInd, EdItemPartInd, NewVertsDC );
      CurMapLayer.ClearReIndVectors();
      SubAction := ngsEVMStartNewLine; // restore SubAction
    end else // Add new segments to Current Line
    begin
      EdCL.GetPartDCoords( EdItemInd, EdItemPartInd, DC );
      if EdVertInd = 0 then // add NewVertsDC as First vertexes
      begin
        N_AddDcoordsToDCoords( TmpDLine, NewVertsDC, 1 ); // reverse order
        N_AddDcoordsToDCoords( TmpDLine, DC, 0 ); // add in straight order
        EdCL.SetPartDCoords( EdItemInd, EdItemPartInd, TmpDLine ); // set coords
      end else //************* add NewVertsDC as Last vertexes
      begin
        N_AddDcoordsToDCoords( DC, NewVertsDC, 0 ); // add in straight order
        EdCL.SetPartDCoords( EdItemInd, EdItemPartInd, DC ); // set coords
      end;
      SubAction := ngsEVMEnlargeLine; // restore SubAction
    end;

    ContLineState := False; // affects RedrawAllAndShow()
    StartPermanent();
    if EVFinMode = 0 then
      RedrawAllAndShow()
    else if (EVFinMode = 1) then
      DrawNewVertsDC( @EVFinSegmAttr );

    ForceHighlighting := False; // do not highlight on all MouseMoves

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditVertex.FinishLine


//********************************* TN_RFADeleteLine.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFADeleteLine.SetActParams();
begin
  PParams  := @N_TmpEditVertexParams;
  ActRGInd := 1; // CObj Edit Action
  ActName  := 'DeleteLine';
  DeletedItemInds := nil; // clear all previously saved info
  inherited;
end; // procedure TN_RFADeleteLine.SetActParams();

//********************************* TN_RFADeleteLine.Execute ***
// Delete Line under Cursor by MouseDown,
// restore one last deleted Line by Escape
//
procedure TN_RFADeleteLine.Execute();
var
  NumParts, IInd: integer;
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin

    if (CHType <> htMouseDown) and
       (CHType <> htKeyDown) then Exit;

    if (CHType = htMouseDown) then //************************* MouseDown
    begin
      if SRType <> srtLine then Exit;
      if CurMLCObj.CI() <> N_ULinesCI then Exit;

      EdCL := TN_ULines(CurMLCObj); // for Undo capability
      with EdCL do
      begin
        NumParts := EdCL.GetNumParts( ItemInd );
        if NumParts = 1 then // Single Part Line, delete by setting Empty Flag
        begin
          N_PushInt( DeletedItemInds, ItemInd ); // save, to enable Undo
          SetEmptyFlag( ItemInd );
        end else //************ MultyPart Line, Really delete current Part
        begin
          N_PushInt( DeletedItemInds, -2 ); // save "not whole Item" flag
          //*** save info about deleted Part
          EdItemInd := ItemInd;
          EdItemPartInd := PartInd;
          GetPartDCoords( ItemInd, PartInd, EdDC );

          DeleteParts( ItemInd, PartInd, 1 );
        end;

        SRType := srtNone; // to prevent highlighting deleted Line

        StartPermanent();
        if EVStartMode = 0 then
          RedrawAllAndShow()
        else if (EVStartMode = 1) then
          OCanv.DrawUserDPoly( @EdDC[0], Length(EdDC), @EVStartSegmAttr );

      end; // with EdCL do
    end; // if (CHType = htMouseDown) then

    if (CHType = htKeyDown) and //******************************* Escape
       (CKey.CharCode = VK_ESCAPE) then // Restore last deleted Line
    begin
      IInd := N_PopInt( DeletedItemInds );
      if IInd = -1 then Exit; // nothing to restore

      if IInd >= 0 then // restore whole Item by clearing EmptyFlag
      begin
        EdCL.ClearEmptyFlag( IInd );
      end else // IInd = -2, restore deleted Item Part
      begin
        EdItemPartInd := -1; // force adding (not replacing)
        EdCL.SetPartDCoords( EdItemInd, EdItemPartInd, EdDC );
      end;

      StartPermanent();
      if EVFinMode = 0 then
        RedrawAllAndShow()
      else if (EVFinMode = 1) then
        OCanv.DrawUserDPoly( @EdDC[0], Length(EdDC), @EVFinSegmAttr );

    end; // Restore last deleted Line

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFADeleteLine.Execute


//********************************* TN_RFASplitCombLine.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFASplitCombLine.SetActParams();
begin
  PParams  := @N_TmpEditVertexParams;
  ActRGInd := 1; // CObj Edit Action
  ActName  := 'SplitCombLine';
  inherited;
end; // procedure TN_RFASplitCombLine.SetActParams();

//********************************* TN_RFASplitCombLine.Execute ***
// Split Line at Vertex under Cursor by MouseDown,
// or Combine two lines with common Vertex under Cursor by MouseDown,
//
procedure TN_RFASplitCombLine.Execute();
var
  DC: TN_DPArray;
  TmpCL: TN_ULines;
  TmpVertexRefs: TN_VertexRefs;
//  TmpOneSR:  TN_SearchResult;
//  TmpSRs:   TN_SearchResults;
  Label Fin;
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if (CHType <> htMouseDown) then Exit;

    if SRType <> srtLine then Exit;
    if CurMLCObj.CI() <> N_ULinesCI then Exit;
    TmpCL := TN_ULines(CurMLCObj);
    TmpCL.GetPartDCoords( ItemInd, PartInd, DC );

//    Move( OneSR, TmpOneSR, SizeOf(OneSR) );
//    TmpSRs := Copy( CurSR );

//    TmpCL.GetVertexRefs( DC[VertInd], 0, TmpVertexRefs );
//    goto Fin;

    if (VertInd > 0) and (VertInd < High(DC)) then //***** Split
    begin // internal Vertex, Split is possible
      TmpCL.SplitAuto( ItemInd, PartInd, VertInd );
    end else // external Vertex, check number of connected Lines
    begin
      TmpCL.GetVertexRefs( DC[VertInd], 0, TmpVertexRefs );
//      if (TmpVertexRefs[0].ItemInd = TmpVertexRefs[1].ItemInd) then Exit; // same Line
//      if Length(TmpVertexRefs) <> 2 then Exit; // not TWO lines

      // now only single part Items can be combined!
      TmpCL.CombineItems( TmpVertexRefs );
    end;
    CurMapLayer.ClearReIndVectors();

    Fin: //*********
    SRType := srtNone; // to prevent unproper highlighting
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFASplitCombLine.Execute


//********************************* TN_RFAAffConvLine.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAAffConvLine.SetActParams();
begin
  PParams  := @N_TmpEditVertexParams;
  ActRGInd := 1; // CObj Edit Action
  ActName  := 'AffConvLine';
  inherited;
end; // procedure TN_RFAAffConvLine.SetActParams();

//********************************* TN_RFAAffConvLine.Execute ***
// Affine convert whole Line by moving one of it's endpoints or
// move whole Line (if cursor is over internal Vertex) or
// restore initial Line Coords by Escape
//
procedure TN_RFAAffConvLine.Execute();
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin

    if CHType = htDblClick then //*** Left DoubleClick
    begin
      AnyFixedPoint := not AnyFixedPoint;
      if AnyFixedPoint then
      begin
        FixedPoint := CursorUPoint;
        TN_CObjVectEditorForm(UCObjEdForm).StatusBar.SimpleText := 'Fixed mode ON';
      end;
      Exit; // all done
    end; // if CHType = htDblClick then //*** Left DoubleClick


    if (CHType = htMouseDown) and (ssRight in CMKShift) then //*** Right Click
    begin
    if SRType = srtNone then Exit;
//      ACLMenuShow();
      Exit;
    end; //*** Right Click

    if (CHType = htMouseMove) and (MoveState or DrugState) then // Convert Line
    begin
      ConvLine1();
      StartHighlighting();
      DrawEdDC( @EVMoveSegmAttr );
      Exit;
    end; //***** Convert Line

    if (CHType = htMouseDown) and not MoveState then //***** Start Converting
    begin
      StartConvLine1();
      Exit;
    end; //***** Start Converting

    if ((CHType = htMouseUp)   and (DrugState)) or
       ((CHType = htMouseDown) and (MoveState)) then //***** Finish Converting
    begin
      FinishConvLine();
      Exit;
    end; //***** Finish Converting

    if (CHType = htKeyDown) and //************** Cancel moving by Escape
       (CKey.CharCode = VK_ESCAPE) and
       (MoveState or DrugState) then
    begin
      EdDC := InitialDC;
      FinishConvLine();
      Exit;
    end; // Cancel moving by Escape

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAAffConvLine.Execute

//********************************* TN_RFAAffConvLine.DrawEdDC ***
// Draw EdDC by given attributes
//
procedure TN_RFAAffConvLine.DrawEdDC( PAttribs: TN_PNormLineAttr );
begin
  with TN_SGMLayers(ActGroup), RFrame, PParams^ do
    OCanv.DrawUserDPoly( @EdDC[0], Length(EdDC), PAttribs );
end; // procedure TN_RFAAffConvLine.DrawEdDC

//********************************* TN_RFAAffConvLine.StartConvLine1 ***
// Start current Line convertion (algorithm #1)
//
procedure TN_RFAAffConvLine.StartConvLine1();
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if SRType <> srtLine then Exit;
    if CurMLCObj.CI() <> N_ULinesCI then Exit;

    EdCL := TN_ULines(CurMLCObj);
    EdCL.GetPartDCoords( ItemInd, PartInd, EdDC );

    if AnyFixedPoint or
      ((VertInd = 0) or (VertInd = High(EdDC))) and
       not N_Same( EdDC[0], EdDC[High(EdDC)] ) then
      ConvMode := 1
    else
      ConvMode := 2;

    ForceHighlighting := True; // highlight on all MouseMoves
    EdVertInd := VertInd;
    EdItemInd := ItemInd;
    EdItemPartInd := PartInd;
    InitialDC := nil;
    N_AddDcoordsToDCoords( InitialDC, EdDC, 0 ); // just copy
    InitialCPoint := CursorUPoint;

    if not AnyFixedPoint then // FixedPoint is one of Line Ends, otherwise
    begin                     // it is already OK
      if VertInd = 0 then
      begin
        FixedPoint := EdDC[High(EdDC)];
      end else
      begin
        FixedPoint := EdDC[0];
      end;
    end;

    if (EVMode = 0) and not ACLMenuState then
      DrugState := True
    else
      MoveState := True;

    if EVStartMode = 1 then // Clear Line in initial position
    begin
      StartPermanent();
      DrawEdDC( @EVStartSegmAttr );
    end;

    // Highlight Line in initial position
    DrawEdDC( @EVMoveSegmAttr );

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAAffConvLine.StartConvLine1

//********************************* TN_RFAAffConvLine.ConvLine1 ***
// Convert EdDC by algorithm #1
//
procedure TN_RFAAffConvLine.ConvLine1();
var
  Shift: TDPoint;
  ConvParams: Array [0..5] of TDPoint;
  AffCoefs6: TN_AffCoefs6;
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    Shift := N_Substr2P( CursorUPoint, InitialCPoint );

    if N_KeyIsDown( VK_Shift ) then // move stricly along Axis
    begin
      if Abs(Shift.X) > Abs(Shift.Y) then Shift.Y := 0
                                     else Shift.X := 0;
      CursorUPoint := N_Add2P( InitialCPoint, Shift );
    end; // if N_KeyIsDown( VK_Shift ) ...

    case ConvMode of
    1: begin // one line end is fixed, another is moving
      ConvParams[0] := FixedPoint;
      ConvParams[1] := InitialCPoint;
      ConvParams[2] := FixedPoint;
      ConvParams[3] := CursorUPoint;
      N_CalcAffCoefs6( $05, AffCoefs6, PDouble(@ConvParams[0]) );
    end;
    2: begin // line can only be shifted
      ConvParams[0]:= Shift;
      N_CalcAffCoefs6( $01, AffCoefs6, PDouble(@ConvParams[0]) );
    end;
    end; // case ConvMode of

    N_AffConv6D2DPoints( @InitialDC[0], @EdDC[0], Length(EdDC), AffCoefs6 );
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAAffConvLine.ConvLine1

//********************************* TN_RFAAffConvLine.FinishConvLine ***
// Finish Current Line convertion
//
procedure TN_RFAAffConvLine.FinishConvLine();
begin
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if not (MoveState or DrugState) then Exit; // a precaution
    EdCL.SetPartDCoords( EdItemInd, EdItemPartInd, EdDC ); // set coords

    MoveState := False; // affects RedrawAllAndShow()
    DrugState := False; // affects RedrawAllAndShow()
    AnyFixedPoint := False; // clear AnyFixedPoint mode
    TN_CObjVectEditorForm(UCObjEdForm).StatusBar.SimpleText := '';
    StartPermanent();
    if EVFinMode = 0 then
      RedrawAllAndShow()
    else if (EVFinMode = 1) then
      DrawEdDC( @EVFinSegmAttr );

    ForceHighlighting := False; // do not highlight on all MouseMoves

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAAffConvLine.FinishConvLine

//********************************* TN_RFAEditItemCode.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAEditItemCode.SetActParams();
begin
  PParams  := @N_TmpEditCodesParams;
  ActRGInd := 1; // CObj Edit Action
  ActName  := 'EditItemCode';
  inherited;
end; // procedure TN_RFAEditItemCode.SetActParams();

//********************************* TN_RFAEditItemCode.Execute ***
// Edit any Cobj Item Code
// Enter  - finishes editing
// Escape - cancels editing
//
procedure TN_RFAEditItemCode.Execute();
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if SRType = srtNone then Exit;
    if (CHType <> htMouseDown) then Exit;
    N_EditItemsCodes( CurMLCObj, ItemInd, 1, 'Edit Item Code :' );
    CurMapLayer.ClearReIndVectors();
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditItemCode.Execute

//********************************* TN_RFAEditRegCodes.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFAEditRegCodes.SetActParams();
begin
  PParams  := @N_TmpEditCodesParams;
  ActRGInd := 1; // CObj Edit Action
  ActName  := 'EditRegCodes';
  inherited;
end; // procedure TN_RFAEditRegCodes.SetActParams();

//********************************* TN_RFAEditRegCodes.Execute ***
// Edit ULines RegCodes
// Enter  - finishes editing
// Escape - cancels editing
//
procedure TN_RFAEditRegCodes.Execute();
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if SRType <> srtLine then Exit;
    if (CHType <> htMouseDown) then Exit;
    if CurMLCObj.CI() <> N_ULinesCI then Exit;
    
    N_EditItemsCodes( TN_ULines(CurMLCObj), ItemInd, 1, 'Edit Region Codes :' );
  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFAEditRegCodes.Execute

{
//********************************* TN_RFASnapToCObj.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFASnapToCObj.SetActParams();
begin
  PParams := @N_TmpEditVertexParams;
  ActRGInd := 1; // CObj Edit Action
  ActName := 'SnapToCObj';
  inherited;
end; // procedure TN_RFASnapToCObj.SetActParams();

//********************************* TN_RFASnapToCObj.Execute ***
// Snap Line Vertex to CObj (later implement Points snapping)
// First Click select Vertex to Snap, second click selects CObj on which
// selected Vertex shoud be snapped to
// Escape is used for Undo selection and snapping
//
procedure TN_RFASnapToCObj.Execute();
var
  DC: TN_DPArray;
begin
  inherited;
  if PParams = nil then Exit; // a precaution
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame, PParams^ do
  begin
    if (CHType = htKeyDown) and (CKey.CharCode = N_VKEscape) then
    begin
      if SnapState = 2 then // Undo is possible, do it
        SelCObj.CangeVertexCoords( PrevVCoords, VertexRefs );

      SnapState := 0; // initial State
      Exit;
    end; // if (CHType = htKeyDown) and (CKey.CharCode = N_VKEscape) then

    if (CHType <> htMouseDown) then Exit;

    if (SnapState = 0) or (SnapState = 2) then // select Vertex to Snap
    begin
      if VertInd = -1 then Exit; // Vertex not selected
      if CurMLCObj.CI() <> N_ULinesCI then Exit;

      SelCObj := TN_ULines(CurMLCObj);
      SelCObj.GetPartDCoords( ItemInd, PartInd, DC );
      PrevVCoords := DC[VertInd];
      SnapState := 1; // SelCObj and PrevVCoords are selected
    end else if SnapState = 1 then // select CObj to Snap to
    begin
      if CurMLCObj = nil then Exit; // CObj is not selected
      SnapToCurCObj( EVSnapMode, EVSplitMode, CCUser, NewVCoords );
      SelCObj.GetVertexRefs( PrevVCoords, 1, VertexRefs );
      SelCObj.CangeVertexCoords( NewVCoords, VertexRefs );
      SnapState := 2; // Vertex was snapped and Undo is possible

      //***** Redraw if needed
      if EVFinMode = 0 then
      begin
        StartPermanent();
        RedrawAllAndShow();
        ForceHighlighting := False;
      end else if EVFinMode = 1 then
      begin
        // now empty
      end;

    end; // else if SnapState = 1 then // select CObj to Snap to

    TN_CObjVectEditorForm(UCObjEdForm).StatusBar.SimpleText := IntToStr(SnapState);

  end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFASnapToCObj.Execute
}

//********************************* TN_RFASetShapeCoords.SetActParams ***
// Set ActParams Field by ActFlags
//
procedure TN_RFASetShapeCoords.SetActParams();
begin
  ActRGInd := 1; // CObj Edit Action
  ActName  := 'SetShapeCoords';
  inherited;
end; // procedure TN_RFASetShapeCoords.SetActParams();

//********************************* TN_RFASetShapeCoords.Execute ***
// Set one of Shape Coords:
//  Shape Center    (ActFlags = 0)
//  Shape R1, Angle (ActFlags = 1)
//  Shape R2        (ActFlags = 2)
//
procedure TN_RFASetShapeCoords.Execute();
var
  Radius, Angle: double;
  Center: TDPoint;
  Str: string;
begin
  inherited;
  with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
  begin
    if (CHType = htMouseDown) then //*** Set one of Shape Coords (Center,R1,R2)
    begin
      with TN_CObjVectEditorForm(UCObjEdForm) do
      case ActFlags of

      0: begin // Shape Center
           edShapeCenter.Text :=
                    Format( ' %.3f   %.3f', [CursorUPoint.X, CursorUPoint.Y] );
           edShapeCenter.Invalidate();
         end; // 0: begin // Shape Center

      1: begin // Shape R1, Angle
           Str := edShapeCenter.Text;
           Center := N_ScanDPoint( Str );
           Radius := N_P2PDistance( Center, CursorUPoint );
           edShapeR1.Text := Format( ' %.3f', [Radius] );
           edShapeR1.Invalidate();

           Angle := 180*ArcTan2( Center.Y-CursorUPoint.Y, CursorUPoint.X-Center.X )/N_PI;
           edShapeAngle.Text := Format( '%.1f', [Angle] );
           edShapeAngle.Invalidate();
         end; // 1: begin // Shape R1, Angle

      2: begin // Shape R2
           Str := edShapeCenter.Text;
           Center := N_ScanDPoint( Str );
           Radius := N_P2PDistance( Center, CursorUPoint );
           edShapeR2.Text := Format( ' %.3f', [Radius] );
           edShapeR2.Invalidate();
         end; // 2: begin // Shape R2

      end; // case ActFlags of, with TN_CObjVectEditorForm(UCObjEdForm) do
   end; // if (CHType = htMouseDown)
 end; // with TN_SGMLayers(ActGroup), OneSR, ActGroup.RFrame do
end; // procedure TN_RFASetShapeCoords.Execute



    //*********** Global Procedures  *****************************

//*************************************************** N_SetEditGroup ***
// Set given ACObjLayer to SGBase with GName = N_SEditGroupName
// (if N_SEditGroupName was already created, it is previously destroyed)
// AMode is not used now
// Return EditGroup
//
function N_SetEditGroup( ARFrame: TN_Rast1Frame; AUDMapLayer: TN_UDMapLayer;
                                                 AMode: integer ): TN_SGMLayers;
var
  Ind: integer;
  ACObjLayer: TN_UCObjLayer;
//  SysLineParams: TN_UDBase;
begin
  with ARFrame do
  begin

  Ind := GetGroupInd( N_SVectEditGName );
  if Ind >= 0 then with RFSGroups do Remove( Items[Ind] ); // remove prev. group

  Result := TN_SGMLayers.Create( ARFrame );
  RFSGroups.Add( Result );
  Result.GName := N_SVectEditGName;

  with Result do
  begin
    SetLength( SComps, 1 );
    SComps[0].SComp := AUDMapLayer;

//    with SComps[0] do
//    begin
//      SFlags := $3;
//      SFlags := $7;
//      SComp  := AUDMapLayer;
//    end; // with SComps[0] do

    Ind := GetActionByClass( N_ActHighPoint );
    if Ind >= 0 then GroupActList.Delete( Ind );

    Ind := GetActionByClass( N_ActHighLine );
    if Ind >= 0 then GroupActList.Delete( Ind );

    ACObjLayer := AUDMapLayer.PISP()^.MLCObj;

    if ACObjLayer.CI = N_UDPointsCI then
    begin
      SComps[0].SFlags := $3;
      N_TmpEditPointParams.EPNewPointsCL := TN_UDPoints(ACObjLayer);
      SetAction( N_ActHighPoint, $01, -1, 0 );
      SetAction( N_ActShowCObjInfo, $602, 0, 0 );
    end;

    if ACObjLayer.CI = N_ULinesCI then
    begin
      SComps[0].SFlags := $7;
      N_TmpEditVertexParams.EVNewLinesCL := TN_ULines(ACObjLayer);
      SetAction( N_ActHighLine, $002, -1, 0 );
      SetAction( N_ActShowCObjInfo, $602, 0, 0 );
    end;

    if ACObjLayer.CI = N_UContoursCI then
    begin
      SComps[0].SFlags := $3;
//      N_TmpEditVertexParams.EVNewContoursCL := TN_UContours(ACObjLayer);
      SetAction( N_ActHighLine, $002, -1, 0 );
      SetAction( N_ActShowCObjInfo, $602, 0, 0 );
    end;

//    SysLineParams := N_GetUObj( N_DefObjectsDir, 'DefSysLines' );
//    if SysLineParams is TK_UDRArray then
//      move( TK_UDRArray(SysLineParams).R.P^, N_TmpEditVertexParams, Sizeof(N_SysLineAttr1) );

  end; // with Result do

{
  var //************* Button creating example
  DummyVREOpForm: TN_VREOpForm;
  AButton: TButton;

    DummyVREOpForm := nil; // to avoid warning
    AButton := TButton.Create( ParentForm );
    with AButton do
    begin
      Parent := TN_Rast3Frame(ARFrame).ToolBar1;
      Caption := 'VRE Opt.';
      Show();
      Left := 300;
      Width := 55;
      OnClick := DummyVREOpForm.ShowSelf;
      Tag := integer(ARFrame); // save ARFrame in Tag field
    end;
    AButton.OnClick( AButton );
}
  end; // with ARFrame do
end; // procedure N_SetEditGroup

//*************************************************** N_SetEditAction ***
//
function N_SetEditAction( AClassInd, AFlags, ARGInd: integer ): TN_RFrameAction;
var
  Ind, GroupInd: integer;
  ARFrame: TN_Rast1Frame;
  UCObjEdF: TN_CObjVectEditorForm;
begin
  Result := nil;
  if N_ApplicationTerminated then Exit; // really needed, can be called from
                                  // VREOpForm RadioButtons OnClick handlers
  ARFrame := N_ActiveRFrame;
  if ARFrame = nil then Exit;

  UCObjEdF := TN_CObjVectEditorForm(ARFrame.UCObjEdForm);
  if UCObjEdF <> nil then
    UCObjEdF.StatusBar.SimpleText := '';

  GroupInd := ARFrame.GetGroupInd( N_SVectEditGName );
  Assert( GroupInd >= 0, 'No TmpEditGroup' );

  with TN_SGBase(ARFrame.RFSGroups[GroupInd]) do
  begin
    if AClassInd = N_ActEmpty then
    begin
      Ind := GetActionByRGInd( ARGInd );
      if Ind >= 0 then GroupActList.Delete( Ind );
    end else
      Result := SetAction( AClassInd, AFlags, 0, ARGInd ); // before Highlight Action!
  end; // with TN_SGBase(RFrame.RFSGroups[1]) do
end; // function N_SetEditAction

//********************************************** N_FillSRArray ***
// Fill String Array by values of arithmetic progression with Prefix
//
// AnRArray - RArray to fill
// Prefix   - rezulting strings: Prefix + IntToStr(BegValue + i*Step);
// BegValue - initial value (AnArray[FirstInd] = BegValue)
// Step     - Step between values (AnArray[FirstInd+1] = BegValue + Step)
// NumVals  - Number of Values (AnArray size will be increased if needed)
// FirstInd - first AnArray index to fill
//
procedure N_FillSRArray( var AnRArray: TK_RArray; Prefix: string;
               BegValue, Step, NumVals: integer; FirstInd: integer = 0 );
var
  i, NeededSize: integer;
begin
  NeededSize := FirstInd+NumVals;
  if AnRArray.ALength < NeededSize then AnRArray.ASetLength( NeededSize );

  for i := 0 to NumVals-1 do
  begin
    PString(AnRArray.P(FirstInd+i))^ := Prefix + IntToStr(BegValue + i*Step);
  end;
end; // procedure N_FillSRArray

//********************************************** N_FillFPRArray ***
// Fill FPoint Array by values of arithmetic progression
//
// AnRArray - RArray to fill
// BegValue - initial value (AnArray[FirstInd] = BegValue)
// Step     - Step between values (AnArray[FirstInd+1] = BegValue + Step)
// NumVals  - Number of Values (AnArray size will be increased if needed)
// FirstInd - first AnArray index to fill
//
procedure N_FillFPRArray( var AnRArray: TK_RArray; BegValue, Step: TFPoint;
                                     NumVals: integer; FirstInd: integer = 0 );
var
  i, NeededSize: integer;
begin
  NeededSize := FirstInd+NumVals;
  if AnRArray.ALength < NeededSize then
    AnRArray.ASetLength( NeededSize );

  for i := 0 to NumVals-1 do
    PFPoint(AnRArray.P(FirstInd+i))^ := FPoint( BegValue.X + i*Step.X,
                                                BegValue.Y + i*Step.Y );
end; // procedure N_FillFPRArray

//********************************************** N_FillFRArray ***
// Fill Float RArray by values of arithmetic progression from MinValue to MaxValue
//
// AnRArray - RArray to fill
// MinValue - Minimal Value (AnArray[FirstInd] = MinValue)
// MaxValue - Maximal Value (AnArray[LastInd] = MaxValue)
// NumVals  - Number of Values (AnArray size will be increased if needed)
// FirstInd - first AnArray index to fill
//
procedure N_FillFRArray( var AnRArray: TK_RArray; MinValue, MaxValue: Float;
                                     NumVals: integer; FirstInd: integer = 0 );
var
  i, NeededSize: integer;
  Step: Float;
begin
  NeededSize := FirstInd+NumVals;
  if AnRArray.ALength < NeededSize then
    AnRArray.ASetLength( NeededSize );

  Step := 0;
  if NumVals >= 2 then
    Step := (MaxValue - MinValue) / (NumVals-1);

  for i := 0 to NumVals-1 do
    PFloat(AnRArray.P(FirstInd+i))^ := MinValue + i*Step;

end; // procedure N_FillFRArray

//********************************************** N_FillDRArray ***
// Fill Double RArray by values of arithmetic progression from MinValue to MaxValue
//
// AnRArray - RArray to fill
// MinValue - Minimal Value (AnArray[FirstInd] = MinValue)
// MaxValue - Maximal Value (AnArray[LastInd] = MaxValue)
// NumVals  - Number of Values (AnArray size will be increased if needed)
// FirstInd - first AnArray index to fill
//
procedure N_FillDRArray( var AnRArray: TK_RArray; MinValue, MaxValue: double;
                                     NumVals: integer; FirstInd: integer = 0 );
var
  i, NeededSize: integer;
  Step: double;
begin
  NeededSize := FirstInd+NumVals;
  if AnRArray.ALength < NeededSize then
    AnRArray.ASetLength( NeededSize );

  Step := 0;
  if NumVals >= 2 then
    Step := (MaxValue - MinValue) / (NumVals-1);

  for i := 0 to NumVals-1 do
    PDouble(AnRArray.P(FirstInd+i))^ := MinValue + i*Step;

end; // procedure N_FillDRArray

{
Initialization
  N_RFAClassRefs[N_ActDebAction1]    := TN_RFDebAction1;

  N_RFAClassRefs[N_ActShowCObjInfo]  := TN_RFAShowCObjInfo;

  N_RFAClassRefs[N_ActHighPoint]     := TN_RFAHighPoint;
  N_RFAClassRefs[N_ActMovePoint]     := TN_RFAMovePoint;
  N_RFAClassRefs[N_ActAddPoint]      := TN_RFAAddPoint;
  N_RFAClassRefs[N_ActDeletePoint]   := TN_RFADeletePoint;

  N_RFAClassRefs[N_ActMoveLabel]     := TN_RFAMoveLabel;
  N_RFAClassRefs[N_ActAddLabel]      := TN_RFAAddLabel;
  N_RFAClassRefs[N_ActDeleteLabel]   := TN_RFADeleteLabel;
  N_RFAClassRefs[N_ActEditLabel]     := TN_RFAEditLabel;

  N_RFAClassRefs[N_ActHighLine]      := TN_RFAHighLine;
  N_RFAClassRefs[N_ActEditVertex]    := TN_RFAEditVertex;
  N_RFAClassRefs[N_ActDeleteLine]    := TN_RFADeleteLine;
  N_RFAClassRefs[N_ActSplitCombLine] := TN_RFASplitCombLine;
  N_RFAClassRefs[N_ActAffConvLine]   := TN_RFAAffConvLine;

  N_RFAClassRefs[N_ActMarkCObjPart]  := TN_RFAMarkCObjPart;
  N_RFAClassRefs[N_ActMarkPoints]    := TN_RFAMarkPoints;
  N_RFAClassRefs[N_ActSetItemCodes]  := TN_RFASetItemCodes;
  N_RFAClassRefs[N_ActEditItemCode]  := TN_RFAEditItemCode;
  N_RFAClassRefs[N_ActEditRegCodes]  := TN_RFAEditRegCodes;

  N_RFAClassRefs[N_ActSetShapeCoords] := TN_RFASetShapeCoords;

Finalization
}

end.

