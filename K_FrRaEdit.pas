unit K_FrRaEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, Dialogs,
  ActnList, Grids, StdCtrls, Controls, inifiles, ImgList, Menus,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  N_BaseF, N_Types, N_Lib1,
  K_CLib0, K_UDT1, K_IFunc, K_Script1, K_parse, K_Types, ExtCtrls;

type TK_RAFPasteFromClipboardMode = set of (
   K_sdmInsBeforeSelectedRows,
   K_sdmReplaceSelectedRowsOnly,
   K_sdmFixSelectedRowsNumber,
   K_sdmFillSelectedRows,
   K_sdmInsBeforeSelectedCols,
   K_sdmReplaceSelectedColsOnly,
   K_sdmFixSelectedColsNumber,
   K_sdmFillSelectedCols );

type TK_RAFBuffer = record
  Flags : TK_RAFPasteFromClipboardMode;
  BBuf  : TK_RAArray;
  Text  : string;
end;

type TK_RAFSetDataFunc = procedure ( var Data; DataType : TK_ExprExtType;
                            Arow,  ACol : Integer; var DataSource ) of object;

type TK_RAFSetFromClipboardResult = (K_sdrNothingToDo, K_sdrOK );
type TK_FrameRAEdit = class;
{type} TK_RAFEditor = class;
{type} TK_RAFEArray = array of TK_RAFEditor;
{type} TK_RAFViewer = class;
{type} TK_RAFVArray = array of TK_RAFViewer;
{type} TK_RAColResizeMode = (
         K_crmDataBased,   //ColumnWidth = DataWidth
//variant K_crmOptimal, //ColumnWidth = Min( HeaderWidth, DataWidth ), LeftColWidth = Min( CDescr.HColWidth, MaxHeadersWidth )
         K_crmHeaderBased, //ColumnWidth = HeaderWidth
         K_crmNormal,  //ColumnWidth = Max( HeaderWidth, DataWidth ), LeftColWidth = Max( CDescr.HColWidth, MaxHeadersWidth )
         K_crmCompact  //ColumnWidth = MinWidth                       LeftColWidth = Min( CDescr.HColWidth, MinWidth )
          );
{type} // TK_RAColumnFlags = (         //*** All Flags for Logical Column
       TK_RAColumnFlagSet = Set of (   //*** All Flags for Logical Column
         K_racReadOnly,             // ReadOnly Mode Flag
         K_racEnumSwitch,           // Allows Enum Switch while Mouse Down
         K_racShowCheckBox,         // Show CheckBox if (Field and Mask) <> 0
         K_racNoText,               // Prevent Field Text Value Drawing
         K_racUseFillColor,         // Fill Cells with bgcolor
         K_racUseRowFillColor,      // Allows Use Rows Color Controls (Even/Odd or RowsPalette etc)
         K_racUseMixFillColor,      // Allows to Use Mixed Palette (ColorMatrix)
         K_racNotUsePalette,        // Use ColorIndex Value as Color but not as Palette Index
         K_racUseFDFillColor,       // Use FormDescr Fill Color instead of (ColorMatrix)
         K_racExternalEditor,       // Use External Editor Flag
         K_racShowExtEditButton,    // Show External Editor Button obsolete flag
         K_racCDisabled,            // ReadOnly and Draw in Disabled Mode
         K_racRebuildAfterEdit,     // Invalidate All Grid Cell after Editing Cell
         K_racShowRecValue,         // View Field Value (instead of "...")
         K_racShowRecType,          // Add Filed Type Name to "..."
         K_racSkipRowChangeNum,     // Clear K_ramRowChangeNum flag to Next Level Frame
         K_racSkipRowEditing,       // Clear K_ramRowEditing flag to Next Level Frame
         K_racStopExtEditApply,     // Stop ApplyAction on this level in MultiLevel Editing
         K_racUseExtEditArchChange, // Set K_ramUseExtEditArchChange flag to Next Level Frame
         K_racAutoApply,            // Allows to Call OnDataApply Frame procedure of object
         K_racSeparator,            // This Logical Column is Data Separator
         K_racSkipColMark,          // Skip Column Mark
         K_racSkipFieldMove,        // Skip Field Move in GetRowData, GetFrameData and GetDataToRArray
         K_racNotModalShow,         // Set Not Modal Next Level Form Show Mode
         K_racFieldRenameEnable,    // Field Rename Action is Enable
         K_racUseOpenedChildForm,   // Use Opened Child Form for View/Edit Column Data
         K_racSkipDataPaste         // Skip Data Paste from Clipboard
          );
{type} //TK_RAColumnFlagSet = Set of TK_RAColumnFlags;

//{type} TK_RAModeFlags = (
{type} TK_RAModeFlagSet = Set of (
         K_ramReadOnly,               // ReadOnly Mode Flag for for All Cells
         K_ramColVertical,            // View Logical Columns as Frame Columns
         K_ramManualColOrient,        // Prevent Logical Columns Auto Oriention in DefaultEditor in Next Level Form
         K_ramShowLRowNumbers,        // Show Logical Rows Numbers
         K_ramUseEvenOddColors,       // Use Different Colors for Even and Odd Logical/Physical Rows
         K_ramUsePhysRowNumberColors, // Use Different Colors for Even and Odd Physical Rows
         K_ramUseFillColor,           // Fill All Cells with bgcolor
         K_ramNotUsePalette,          // Use ColorIndex Value as Color but not as Palette Index
         K_ramRowChangeOrder,         // Allows Logical Rows Change Order - (Set Change Data Flag while Logical Rows Moving)
         K_ramRowChangeNum,           // Allows Logical Rows Deletion And Addition
         K_ramRowAutoChangeNum,       // Allows Auto Change Logical Rows Number while paste from Clipboard
         K_ramSkipResizeHeight,       // Prevents Form Heighy Auto Resize while RebuildFrameSize
         K_ramSkipResizeWidth,        // Prevents Form Width Auto Resize while RebuildFrameSize
         K_ramOnlyEnlargeSize,        // Prevents Form Size Minimization while RebuildFrameSize
         K_ramFillFrameWidth,         // Last Physical Column always Fill all Frame Width
         K_ramSkipRowMoving,          // Prevents Logical Rows Moving
         K_ramShowLColNumbers,        // Show Logical Columns Numbers
         K_ramColChangeOrder,         // Allows Logical Columns Change Order - (Set Change Data Flag while Logical Columns Moving)
         K_ramColChangeNum,           // Allows Logical Columns Deletion And Addition
         K_ramColAutoChangeNum,       // Allows Auto Change Logical Columns Number while paste from Clipboard
         K_ramSkipColMoving,          // Prevents Logical Columns Moving
         K_ramSkipInfoRow,            // Hides Top Logical Row
// variant K_ramSkipRowsInfo,           // Hides Top Physical Row
         K_ramSkipInfoCol,            // Hides Left Logical Column
// variant K_ramSkipColsInfo,           // Hides Left Physical Column
         K_ramCDisabled,              // Prevents Cells Edition and Draw All Cells in Disabled Mode
         K_ramUseExtEditArchChange,   // FraControl.StoreToSData Set Archive "WasChanged" for Current Archive
         K_ramAutoApply,              // Allows to Call OnDataApply Frame procedure of object
         K_ramSkipColsMark,           // Prevent Logical Columns Marking
         K_ramSingleColMark,          // Single Logical Column Marking Permission
         K_ramMarkRowsByHeader,       // Prevent Logical Rows Marking
         K_ramSingleRowMark,          // Single Logical Row Marking Permission
         K_ramShowSingleRecord,       // Show Single Record if Multi Records Array
         K_ramSkipAutoMatrix,         // Skip Auto Matrix ShowEdit Mode
         K_ramShowCheckBox,           // Show CheckBox for Simple Type RArray
         K_ramAutoEnlargeSelectedCol, // Auto Enlarge Selected Column Width
         K_ramUseOpenedChildForm,     // Use Opened Child Form for View/Edit Column Data
         K_ramNotModalShow,           // Set Not Modal Next Level Form Show Mode
         K_ramSkipDataPaste           // Skip Data Paste from Clipboard
          );
//{type} TK_RAModeFlagSet = Set of TK_RAModeFlags;

{type} TK_RAFrameSearchFlags = Set of (K_sgfCaseSensitive, K_sgfUseCell);

{type} TK_RAFDisabled = (
         K_rfdEnabled,
         K_rfdCellDisabled,
         K_rfdRowDisabled,
         K_rfdColDisabled,
         K_rfdAllDisabled
          );

{type} TK_RAFColVEAttrs = packed record // Runtime Column View Edit Attributes
  EObj    : TK_RAFEditor; // Column Editor Object
  EParams : string;       // Column Edtor Params
  SEInds  : TN_IArray;    // Column Set/Enum Ordered SubSet (Elements Names)
  EEID    : string;       // Column External Editor ID param
  VObj    : TK_RAFViewer; // Column Viewer Object
  VParams : string;       // Column Viewer Params
end;
{type} TK_RAFCVEArray = array of TK_RAFColVEAttrs;

{type} TK_RAFColumn = packed record  // Field Column Description
  Name          : string;         // Column Data Field Name
  Path          : string;         // Column Data Field Path
  Caption       : string;         // Column Data Caption
  Fmt           : string;         // Simple Data Format
//*** Width Attributes for all Cells for this Logic Column
  DataAddCWidth : Integer;        // Additional Width to Column Data Width for Dynamic Column Resize
  MaxCWidth     : Integer;        // Max Columnn Width
//  MinCWidth     : Integer;        // Min Columnn Width
//***
  TextPos       : Byte;           // Column Text Position
  CDType        : TK_ExprExtType; // Field Type
  ShowEditFlags : TK_RAColumnFlagSet; // Show/Edit Flags
  CFillColorInd : Integer;        // Columns Color Palette Index
  CFillColor    : Integer;        // Row Fill Color
  CFontColor    : Integer;        // Row Font Color
  BorderWidth   : Integer;        // Column Additional Border Width
  BorderColor   : Integer;        // Column Border Color
  BitMask       : LongWord;       // Row Bit Mask for Check Box Case
  FieldPos      : Integer;        // Field Position in Record
  Hint          : string;         // Column Hint
  CVEInd        : Integer;        // View Edit Attributes Current Ind
  VEArray       : TK_RAFCVEArray; // View Edit Attributes
  Marked        : Boolean;        // Mark Field Flag
  DataTextWidth : Integer;        // Special field for enum Column Width Calculation optimisation
  MVHelpTopicID : string;         // MV Show help Topic ID
  CUDR          : TN_UDBase;      // Column UDRArray Field container
  RUDInfo       : Integer;        // Runtime User Defined Info
end;

{type} TK_PRAFColumn = ^TK_RAFColumn;  // Pointer to Field Column Description
{type} TK_RAFCArray = array of TK_RAFColumn;

//{type} TK_RAMFlags = packed record  // Show/Edit Mode Flags
//  case Integer of
//  0 : ( PasFlags     : TK_RAModeFlagSet; );
//  1 : ( SPLFlags     : Integer; );
//end;

{type} TK_RAFrDescr = packed record  // Frame Commom fields Description
  ModeFlags     : TK_RAModeFlagSet; // Show/Edit Mode Flags
  DataCapt      : string;   // Data Caption
  NameCapt      : string;   // Field Names Caption
  ValueCapt     : string;   // Field Values Caption
  CellPadding   : Integer;  // Text Cell Padding
  MinHColWidth  : Integer;  // Headers Column Min Width
  HRowHeight    : Integer;  // Headers Row Height
  DataAddCWidth : Integer;  // Additional Width to Column Data Width for Dynamic Column Resize
  MaxCWidth     : Integer;  // Max Columnn Width for Dynamic Column Resize
  MinCWidth     : Integer;  // Min Columnn Width for Dynamic Column Resize
  DSeparatorSize: Integer;  // Data Separator Size
  DefRColWidth  : Integer;  // Default Real Column Width
  SelFillColor  : Integer;  // Fill Color in Selected Cells
  SelFontColor  : Integer;  // Font Color in Selected Cells
  DisFillColor  : Integer;  // Fill Color in Disabled Cells
  DisFontColor  : Integer;  // Font Color in Disabled Cells
  RowColorInd1  : Integer;  // Palette Index of Color in Rows Color Pallete for  odd rows
  RowColorInd2  : Integer;  // Palette Index of Color in Rows Color Pallete for even rows
  ColumnsPalette: TK_RArray;// Columns Color Palette
  RowsPalette   : TK_RArray;// Rows Color Palette
  MixedPalette  : TK_RArray;// Mixed Columns/Rows Color Palette - matrix
  ColResizeMode : TK_RAColResizeMode; // Columns Resize Mode
end;
{type} TK_RAPFrDescr = ^TK_RAFrDescr;

{type} TK_RAEditFuncCont = record
//*** Root Level Source Data Decription
   FRLSData   : TK_RLSData;   // Root Level Source Data

//*** Current Level Data Info
   FDType     : TK_ExprExtType;  // Current Level SPL Data Type
   FDataPath  : string;          // Current Level Data Path
   FDataCapt  : string;          // Current Level Data Caption

//*** Auxilary Edit Attribs
   FOnGlobalAction : TK_RAFGlobalActionProc; // Application Global Action Procedure of Object
   FRAFrame : TK_FrameRAEdit;                // previous Level RAFrame

//*** RAFrame Data Edit Context Prepare Params
   //*** Common Control
   FSetModeFlags   : TK_RAModeFlagSet;
   FClearModeFlags : TK_RAModeFlagSet;
   FPCDescr    : TK_RAPFrDescr;
//   FSkipDataBuf : Boolean;        // No Data Buffering while Edit

   //*** Fields Description  Context
   FGEDataID  : string;          // Current Level Data Description ID        - for AutoFrDescrName Building
   FGEDataIDPrefix : string;     // Current Level Data Description ID Prefix - for AutoFrDescrName Building
   FSEInds    : TN_IArray;       // Enum/Set Ordered SubSet (Elements indexes)
   FGrFlagsMask : LongWord;      // Fields Group Selected flags (Select from Set of Columns in FrDescr)
   FFFLags    : Integer;         // Fields Type Flags
   FFMask     : Integer;         // Fields Type Flags Mask
   FFormDescr : TK_UDRarray;     // FormDescr for UDTree Data Edit;

//*** Current Level Form Attribs
   FOwner     : TN_BaseForm;     // Owner Form
   FormCapt   : string;          // Form Caption
   FNotModalShow : Boolean;      // Show Mode
   FSelfName  : string;          // BaseForm Save Context ID
   FUseOpenedChildForm : Boolean; // Use Already Opened Child Form
end;
{type} TK_PRAEditFuncCont = ^TK_RAEditFuncCont;

{type} TK_RAFViewer = class( TObject ) // ***** Base class for Records Array Field Viewer
  RAFrame : TK_FrameRAEdit;
  UseTextVal : Boolean;
  TextVal : string;
  TextShift : Integer;
  IconInd : Integer;
  constructor Create; virtual;
  procedure DrawCell( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
                Rect: TRect; State: TGridDrawState; ACanvas : TCanvas ); virtual;
  procedure SetTextShift;
  function  GetText( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
                 PHTextPos : Pointer = nil ): string; virtual;
  procedure SetContext( const Data ); virtual;
  function  IfUseViewer( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; virtual;
end; //*** type TK_RAFViewer = class( TObject )
{type} TK_RAFViewerClass = Class of TK_RAFViewer;

//{type} TK_RAFEditor = class( TObject ) // ***** Base class for Records Array Field Editor
//  RAFrame : TK_FrameRAEdit;
//  constructor Create; virtual;
//  procedure SetContext( const Data ); virtual;
{type} TK_RAFEditor = class( TK_RAFViewer ) // ***** Base class for Records Array Field Editor
  constructor Create; override;
  procedure SetContext( const Data ); override;
  function  Edit( var Data ) : Boolean; virtual;
  function  CanUseEditor( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; virtual;
  procedure Hide; virtual;
end; //*** type TK_RAFEditor = class( TObject )
{type} TK_RAFEditorClass = Class of TK_RAFEditor;

{type} TK_RAFEditor1 = class( TK_RAFEditor ) // ***** Base class for Records Array Field Editor which can be disabled
  function  CanUseEditor( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean; override;
end; //*** type TK_RAFEditor1 = class( TK_RAFEditor )

{type} TK_FrameRAEdit = class( TFrame )
    SGrid: TStringGrid;
    BtExtEditor_1: TButton;

    ActList: TActionList;
    AddCol             : TAction;
    InsCol             : TAction;
    DelCol             : TAction;
    AddRow             : TAction;
    InsRow             : TAction;
    DelRow             : TAction;
    CallEditor         : TAction;
    ClearSelected      : TAction;
    CopyToClipboardA   : TAction;
    CopyToClipBoard    : TAction;
    CopyToClipBoardE   : TAction;
    PasteFromClipBoard : TAction;
    RebuildGrid        : TAction;
    Replace            : TAction;
    RenameCol          : TAction;
    SetColResizeByData : TAction;
    SetColResizeCompact: TAction;
    SetColResizeNormal : TAction;
    Search             : TAction;
    SendFVals          : TAction;
    ShowHelp           : TAction;
    ScrollToNextRow    : TAction;
    ScrollToPrevRow    : TAction;
    ScrollToFirstRow   : TAction;
    ScrollToLastRow    : TAction;
    SwitchSRecordMode  : TAction;
    TranspGrid         : TAction;
    MarkAllRows        : TAction;
    MarkAllCols        : TAction;
    ReverseRowsMark    : TAction;
    ReverseColsMark    : TAction;
    PopupCallEditor      : TAction;
    PopupCallInlineEditor: TAction;
    PopupCallAttrsEditor : TAction;
    SetColResizeByHeader : TAction;
    SetPasteFromClipboardMode: TAction;

    PUEditMenu: TPopupMenu;

    PURebuildViewMenu: TPopupMenu;
    PUMItemCompact: TMenuItem;
    PUMItemByHeader: TMenuItem;
    PUMItemNormal : TMenuItem;

    PUCopyToClipboardMenu: TPopupMenu;
    PUMItemCopy: TMenuItem;
    PUMItemECopy: TMenuItem;
    PUMItemByData: TMenuItem;
    Timer: TTimer;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure SGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SGridDrawCell0(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure SGridGetEditMask(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    function  GetDataPointer( ACol, ARow: Integer) : Pointer;
    procedure SGridGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure SGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure SGridColumnMoved(Sender: TObject; FromIndex,
      ToIndex: Integer);
    procedure SGridRowMoved(Sender: TObject; FromIndex, ToIndex: Integer);
    procedure BtExtEditor_1Click(Sender: TObject);
    procedure AddRowExecute(Sender: TObject);
    procedure InsRowExecute(Sender: TObject);
    procedure DelRowExecute(Sender: TObject);
    procedure AddColExecute(Sender: TObject);
    procedure InsColExecute(Sender: TObject);
    procedure DelColExecute(Sender: TObject);
    procedure CopyToClipBoardExecute(Sender: TObject);
    procedure CopyToClipBoardEExecute(Sender: TObject);
    procedure ClearSelectedExecute(Sender: TObject);
    procedure SGridDblClick(Sender: TObject);
    procedure SGridKeyDown( Sender: TObject; var Key: Word;
                            Shift: TShiftState );
    procedure SGridMouseDown( Sender: TObject; Button: TMouseButton;
                              Shift: TShiftState; X, Y: Integer );
    procedure TranspGridExecute(Sender: TObject);
    procedure PasteFromClipBoardExecute(Sender: TObject);
    procedure PopUpRebuildGridInfoMenu(Sender: TObject);
    procedure RebuildGridExecute(Sender: TObject);
    procedure CallEditorExecute(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure SearchExecute(Sender: TObject);
    procedure ReplaceExecute(Sender: TObject);
    procedure SGridKeyUp( Sender: TObject; var Key: Word;
                          Shift: TShiftState );
    procedure SGridMouseMove( Sender: TObject; Shift: TShiftState; X,
                              Y: Integer );
    procedure SetPasteFromClipboardModeExecute(Sender: TObject);
    procedure SendFValsExecute(Sender: TObject);
    procedure ScrollToNextRowExecute(Sender: TObject);
    procedure ScrollToPrevRowExecute(Sender: TObject);
    procedure ScrollToFirstRowExecute(Sender: TObject);
    procedure ScrollToLastRowExecute(Sender: TObject);
    procedure SwitchSRecordModeExecute(Sender: TObject);
    procedure ShowHelpExecute(Sender: TObject);
    procedure PUEditMenuPopup(Sender: TObject);
    procedure SetColResizeByDataExecute(Sender: TObject);
    procedure SetColResizeByHeaderExecute(Sender: TObject);
    procedure SetColResizeNormalExecute(Sender: TObject);
    procedure SetColResizeCompactExecute(Sender: TObject);
    procedure RenameColExecute(Sender: TObject);
    procedure CopyToClipBoardAExecute(Sender: TObject);
    procedure PopUpCopyToClipBoardMenu(Sender: TObject);
    procedure MarkAllRowsExecute(Sender: TObject);
    procedure MarkAllColsExecute(Sender: TObject);
    procedure ReverseRowsMarkExecute(Sender: TObject);
    procedure ReverseColsMarkExecute(Sender: TObject);
  protected
  private
    { Private declarations }
    ResizeBeforeFirstShowMode  : Boolean; // AutoResizeMode - Resize Before First First
    FormResizeMode  : Boolean; // FormResizeMode - Frame Resize by Form Resize
    GetFullFrameSize : Boolean; // Control SelfWidth and SelfHeight properties Result
//    SkipSetLastColumnWidth : Boolean; // Skip Set Last Column Width During Resize
    CellWasSelected : Boolean;
    InvertMode      : Boolean;
    CurLPos         : TK_GridPos;
    CurGPos         : TK_GridPos;
    PEditData       : Pointer;

    MaxRowNum   : Integer;         // Max Row Number
    MaxColNum   : Integer;         // Max Column Number
    CViewerInd  : Integer;         // Current Viewer Index
    GLCNumbers  : TN_IArray;      // Array of columns numbers grid to logic
    GLRNumbers  : TN_IArray;      // Array of rows numbers grid to logic

    PRowColorInds      : TN_BytesPtr; // Pointer to Individual Row Color Indexes
    PColColorIndsMatrix: TN_BytesPtr; // Pointer to Individual Colomn Color Indexes Matrix

    PRowPalette    : TN_BytesPtr;  // Pointer to Row Colors Palette
    PColPalette    : TN_BytesPtr;     // Pointer to Column Colors Palette
    ColPalLength   : Integer;
    PMixPaletteMatrix : TN_BytesPtr;  // Pointer to Mixed Colors Palette Matrix

    BeforeEditTextValue : string;
    SearchArea : TGridRect;
    SearchPos : TK_GridPos;
    SearchContext : string;
    SearchFlags   : TK_RAFrameSearchFlags;
    SearchCellPos : Integer;
    HintGridPos : TK_GridPos;

    FixCurEditorInd   : Integer;
    CurFieldEActions : TK_ObjectArray;
    CurFieldRAFEditors : TK_ObjectArray;

    CurOrderedLCol     : Integer;          // Current Ordered Logical Column
    CurOrderedLRow     : Integer;          // Current Ordered Logical Row
    CurDataCompareFunc : TN_CompFuncOfObj; // Compare Frame Data Element Values FUnction of Object

    CurDataDescOrder   : Boolean; // for auto ordering by data text
    CurOrderedLColViewer : TK_RAFViewer; // for auto ordering column by data text

    function  GetCellViewer( LCol, LRow :Integer ) : TK_RAFViewer;
    function  CallExtEditor( OnlyCheckInlineTextEditorCall : Boolean = false ) : Boolean;
    procedure RCMove( Arr : TN_IArray; FromIndex, ToIndex: Integer);
    function  ShowHideExtEditButton( ACol, ARow: Integer;
                                     const RAFC : TK_RAFColumn ) : Boolean;
    procedure PlaceExtControl( ACol, ARow: Integer; ExtControl : TControl );
    function  GetSelfWidth : Integer;
    function  GetSelfHeight : Integer;
    function  GetExtEdit( NCol, NRow : Integer ) : TK_RAFEditor;
    function  SGridColExtEditMode( LPosCol, LPosRow : Integer;
                                   CheckReadOnly : Boolean ) : Boolean;
//    procedure SGridCheckEditMode;
    function  GetEditMask: string;
    function  GetDataText( const Data; const CDType : TK_ExprExtType;
                           fmt : string = '';
                           ValueToStrFlags : TK_ValueToStrFlags = [] ) : string;
    function  GetEditText( const Data ): string;
    procedure SetEditText( AText : string; var Data );
    procedure SetLastColumnWidth;
    function  GetCellEnableState( ALCol, ALRow: Integer ) : TK_RAFDisabled;
    procedure ResizeFrame;
    function  GetRect( LCol : Integer = -1; TRow : Integer = -1;
                       RCol : Integer = -1; BRow : Integer = -1 ) : TGridRect;
    procedure DefTEditExit( Sender: TObject );
    procedure DefTEditKeyDown( Sender: TObject; var Key: Word;
                               Shift: TShiftState );
    procedure SetCellFromText( var Data; DataType : TK_ExprExtType;
                                           LRow,  LCol : Integer; var DataSource );
    procedure SetCellFromBData( var Data; DataType : TK_ExprExtType;
                                           LRow,  LCol : Integer; var DataSource );
    procedure BuildCurFieldEditActions;
    procedure CallEditorFromPopupExecute(Sender: TObject);
    procedure CopyToClipBoardExec( CopyCaptions : Boolean );
    procedure FillArrayByCount( var Arr : TN_IArray; ArrLeng : Integer; StartNum : Integer = -1 );

    function  CompareColElemTexts( Ptr1, Ptr2 : Pointer ) : Integer;
    function  CompareRowElemTexts( Ptr1, Ptr2 : Pointer ) : Integer;
    function  CompareColElems( Ptr1, Ptr2 : Pointer ) : Integer; // Compare Ordered Column Elements
    function  CompareRowElems( Ptr1, Ptr2 : Pointer ) : Integer; // Compare Ordered Row Elements

  public
    { Public declarations }
    ExtendedCopyToClipboardMode : Boolean;
    SkipResizeFlag : Boolean;  // Skip Frame Resize mode Flag
    PopupActionGroups : array of TK_ObjectArray;
    RLSData      : TK_RLSData;   // Root Level Source Data
    DataPath : string;           // Path To Current Level Data

    DataDeliveryForm : TN_BaseForm; // Cur Level Data Delivery Form
    MatrixModeDataPath, SkipCellDataPathName, SkipCellDataPathInd : Boolean;
    PasteFromClipboardFlags : TK_RAFPasteFromClipboardMode;
    LRPadding    : Integer;
    RNumFormat   : string;
    CNumFormat   : string;
    CurShift     : TShiftState;
    CDescr       : TK_RAFrDescr;    // Frame Common Descriptions
    RAFCArray    : TK_RAFCArray;    // Array of Column Descriptions
    RowCaptions  : TN_SArray;
    RowsOrder    : TN_IArray;
    ColsOrder    : TN_IArray;
    RowMarks     : array of Boolean;
    DefaultRAFViewer : TK_RAFViewer;
    DefaultRAFUDViewer : TK_RAFViewer;
    DefaultRAFEditor : TK_RAFEditor;
    AutoInvalidate : Boolean;
    DataPointers : array of TN_PArray; // Array of Data Pointers
    FormDescr    : TK_UDRArray; // FormDescription Object
    DefaultTEdit : TEdit;
    MarkedLColsList : TList; // List of Marked LColumns
    MarkedLRowsList : TList; // List of Marked LRows

    OnBeforeFramePopup : TK_NotifyProc;
    OnInlineEditorExit : procedure ( ResultText : string; var AData ) of object;
    OnColMarkToggle    : procedure ( AChangedCol : Integer ) of object;
    OnRowMarkToggle    : procedure ( AChangedRow : Integer ) of object;
    OnDataChange       : TK_NotifyProc;
    OnDataApply        : TK_NotifyProc;
    OnCancelToAll      : TK_NotifyProc;
    OnOKToAll          : TK_NotifyProc;
    OnLColChange       : TK_NotifyProc;
    OnLRowChange       : TK_NotifyProc;

    OnCellExtEditing   : procedure ( PGCont : Pointer ) of object;
    OnCellSelecting    : procedure ( var CanSelected : Boolean ) of object;
    OnCellCheckDisable : procedure ( var Disable : TK_RAFDisabled; ACol, ARow : Integer ) of object;

    OnRowsAdd           : procedure ( ACount : Integer  ) of object;
    OnRowsDel           : procedure ( FromIndex, Number : Integer ) of object;
    OnRowMoved          : procedure ( FromIndex, ToIndex : Integer ) of object;

    OnColsAdding        : procedure ( var ACount : Integer ) of object;
    OnColsAdd           : procedure ( ACount : Integer ) of object;
    OnColsDel           : procedure ( FromIndex, Number : Integer ) of object;
    OnColMoved          : procedure ( FromIndex, ToIndex : Integer ) of object;
    OnColRenamed        : procedure ( var Name, Caption : string ) of object;

    OnKeyDown           : function  ( var Key: Word; Shift: TShiftState) : Boolean of object;
    OnMouseDown         : function  ( Button: TMouseButton; Shift: TShiftState; X, Y: Integer) : Boolean of object;
    OnEnableDataMatrixEnlargeDlg : function  ( ColNumEnlarge : Boolean ) : Boolean of object;


    procedure GetSelectionToRAArray( var RABuffer: TK_RAArray );
    function  PasteRAArrayToSelection( PasteMode : TK_RAFPasteFromClipboardMode;
                       RABuffer: TK_RAArray ) : TK_RAFSetFromClipboardResult;
    function  PasteTextToSelection( PasteMode : TK_RAFPasteFromClipboardMode;
                       Text: string ) : TK_RAFSetFromClipboardResult;
    function  PasteDataToSelection( PasteMode : TK_RAFPasteFromClipboardMode;
                       DColCount, DRowCount : Integer; var DataSource;
                       SetDataFunc : TK_RAFSetDataFunc  ) : TK_RAFSetFromClipboardResult;
    procedure FrInsertCols( Ind, ICount : Integer );
    procedure FrInsertRows( Ind, ICount : Integer );
    procedure GetFieldsList( FL : TStrings; GetCaptions : Boolean = true;
                             FieldsIndexes : TN_IArray = nil );
    procedure SelectRect( LCol : Integer = -1; TRow : Integer = -1;
                           RCol : Integer = -1; BRow : Integer = -1 );
    procedure SelectLRect( LCol : Integer = -1; TRow : Integer = -1;
                           RCol : Integer = -1; BRow : Integer = -1 );
    procedure SetCurLPos( ACol, ARow: Integer );
    procedure ScrollToLPos( ALCol, ALRow: Integer );
    procedure ScrollToLRowPos( NCol, NRow : Integer );
    procedure RebuildGridInfo;
    procedure InitActionsState;
    procedure SetGridInfo( AModeFlags : TK_RAModeFlagSet;
        ARAFCArray : TK_RAFCArray;
        const ACDescr: TK_RAFrDescr;
        ARowsCount : Integer = 1;
        PRName : PString = nil; APRowColorInds : PInteger = nil;
        APColColorIndsMatrix : PInteger = nil
         );
    function  IndexOfColumn( CName : string ) : Integer;
    procedure SetGridLRowsNumber(  ARowsCount : Integer = 1; SetOriginalColsOrder : Boolean = true );
    procedure SetCellsColors( APRowColorInds : PInteger = nil;
                              APColColorIndsMatrix : PInteger = nil );
    procedure FreeContext; virtual;
    procedure HideEdControls;
    procedure ClearDataPointers( StartCol : Integer = 0; StartRow : Integer = 0;
                                 ColNumber : Integer = 0; RowNumber : Integer = 0 );
    procedure SetDataPointersColumn( var Data; DataStep : Integer;
      Col : Integer; StartRow : Integer = 0;
      PIndex : PInteger = nil; ILength : Integer = -1 );
    procedure SetDataPointersFromColumnRArrays( var Data : TK_RArray;
      PIndex : PInteger = nil; ILength : Integer = -1;
      StartRow : Integer = 0; StartCol : Integer = 0; ColNumber : Integer = 0 );
    function  SetDataPointersFromRArray( const Data; DDType : TK_ExprExtType;
                  StartRow : Integer = 0; StartCol : Integer = 0 ) : Integer;
    procedure SetDataPointersFromRAMatrix( RAM : TK_RArray );
    procedure GetRowData( LRow : Integer; var Data;
                          MDFlags : TK_MoveDataFlags = []  );
    procedure GetFrameData( var Data; RArrayData : Boolean;
                            MDFlags : TK_MoveDataFlags = []  );
    function  GetDataToRArray( const Data; DDType : TK_ExprExtType;
                  StartCol : Integer = 0; ColNum : Integer = 0 ) : Integer;
    procedure GetDataToRAMatrix( var Data; DDType : TK_ExprExtType  );
    procedure GetDataToRAMatrixRArray( RAM : TK_RArray  );
    function  SetDataFromRArray( const Data; DDType : TK_ExprExtType;
                  StartCol : Integer = 0; ColNum : Integer = 0  ) : Integer;
    procedure GetLRowPData( PData : TN_PPointer; RowNum : Integer;
                         PDataInds : PInteger = nil; IndsCount : Integer = -1 );
    procedure GetLColPData( PData : TN_PPointer; ColNum : Integer;
                         PDataInds : PInteger = nil; IndsCount : Integer = -1 );
    procedure GetLColData( PData : Pointer; ElemStep, ColNum : Integer );
    procedure GetDataToColumnRArrays( const Data : TK_RArray );
    function  GetPRowIndex : PInteger;
    function  GetPColIndex : PInteger;
    function  GetDataBufRow( ARow : Integer = -1 ) : Integer;
    function  GetDataBufCol( ACol : Integer = -1 ) : Integer;
    function  ToLogicRow( ARow : Integer): Integer;
    function  ToLogicCol( ACol : Integer): Integer;
    function  ToLogicPos( ACol, ARow : Integer ) : TK_GridPos;
    function  ToGridPos( ACol, ARow : Integer): TK_GridPos;

    function  NextSearchCol : Boolean;
    function  SetSearchContext( ASearchFlags : TK_RAFrameSearchFlags;
      AContext : string;
      ALCol : Integer = 1; ATRow : Integer = -1;
      ARCol : Integer = 1; ABRow : Integer = -1 ) : TGridRect;

    function  NextSearch( out ACol, ARow : Integer ) : Boolean;
    procedure ReplaceSearchResult( NewValue : string );
    procedure AddChangeDataFlag;
//    procedure RAFGlobalActionProc( Sender : TObject; ActionType : TK_RAFGlobalAction );
    function  RAFGlobalActionProc( Sender : TObject; ActionType : TK_RAFGlobalAction ) : Boolean;
    procedure GetPointerToCellData;
    procedure PrepEditFuncContext( PRFC : TK_PRAEditFuncCont );
    function  CallCellEditor : Boolean;
    procedure CallInlineTextEditor; overload;
    procedure CallInlineTextEditor( EditText : string ); overload;
    procedure PrepareColumnControls( Col : Integer);
    procedure GetSelectSection( GetRowSect : Boolean;
                  var StartInd, IndLength : Integer );

    procedure FrDeleteRows( Ind, DCount : Integer );
    procedure FrDeleteCols( Ind, DCount : Integer );
    function  GetCellDataPath(  LCol, LRow : Integer ) : string;
    function  GetCurCellDataPath : string;
    function  GetCellDataType(  LCol, LRow : Integer ) : TK_ExprExtType;
    function  GetCurCellDataType : TK_ExprExtType;
    procedure ToggleLColMark( LCol : Integer );
    procedure ToggleLRowMark( LRow : Integer );
    procedure FrOrderData( ACount : Integer; var AIArray : TN_IArray;
                           AComFunc : TN_CompFuncOfObj );
    procedure FrOrderRows0( ALCol : Integer; AComFunc : TN_CompFuncOfObj );
    procedure FrOrderCols0( ALRow : Integer; AComFunc : TN_CompFuncOfObj );
    function  FrGetColDataCompFunc( ALCol : Integer; ADescOrderFLag : Boolean ) : TN_CompFuncOfObj;
    procedure FrOrderRows( ALCol : Integer; ADescOrderFLag : Boolean );


    property  SelfWidth  : Integer read GetSelfWidth;
    property  SelfHeight : Integer read GetSelfHeight;
    property  CurLRow : Integer read CurLPos.Row;
    property  CurLCol : Integer read CurLPos.Col;
    property  CurGRow : Integer read CurGPos.Row;
    property  CurGCol : Integer read CurGPos.Col;
    property  ModeFlags : TK_RAModeFlagSet read  CDescr.ModeFlags
                                           write CDescr.ModeFlags;

end; //*** TK_FrameRAEdit = class(TFrame)

type TK_RAFDColVEAttrs = packed record // SPL Column View Edit Attributes
  CEName   : string;    // Column Editor Name
  CEParams : string;    // Column Edtor Params
  CSENames : TK_RArray; // Column Set/Enum Ordered SubSet (Elements Names)
  CEEID    : string;    // Column External Editor ID param
  CVName   : string;    // Column Viewer Name
  CVParams : string;    // Column Viewer Params
end;
type TK_PRAFDColVEAttrs = ^TK_RAFDColVEAttrs;

type TK_RAFColumnDescr = packed record
  FName          : string;   // Field Name
  CName          : string;   // Column Name
  CCaption       : string;   // Column Caption
  CGrFlagsSet    : LongWord; // Columns Group Flags Set
  CWidth         : Integer;  // Max Columnn Width
  CDataAddCWidth : Integer;  // Additional Width to Column Data Width for Dynamic Column Resize
  CTextPos       : Byte;     // Column Text Position
  CFormat        : string;   // String Data Format
  CShowEditFlags : LongWord; // Show/Edit Flags - TK_RAColumnFlagSet;
  CCFillColorInd : Integer;  // Column Additional Fill Color
  CBorderWidth   : Integer;  // Column Additional Border Width
  CBorderColor   : Integer;  // Column Border Color
  CBitMask       : LongWord; // Row Bit Mask for Check Box Case
  CHint          : string;   // Column Hint
  CViewers       : TK_RArray;// Column Field Viewer Names
  CEditors       : TK_RArray;// Column Field Editor Names
  CGEDataID      : string;   // Column Global Edit Field ID
  CEdUserPar     : string;   // Column Editor User Param
  CSENames       : TK_RArray;// Column Set/Enum Ordered SubSet (Elements Names)
  CVEAttrs       : TK_RArray;// Column View Edit Attributes for Shift/Control Keys
  CMVHelpTopicID : string;   // Column Show help topic ID
// Fields for DB SubTree Fields and TK_RAList Edit
  FPath         : string;   // Column Field DB Path
  FPData        : Pointer;  // runtime DB Field Data Pointer
  FType         : TK_ExprExtType;  // runtime DB Field Data TypeCode
  FUDR          : TN_UDBase;       // runtime DB Field UDRArray Container
end;
type TK_PRAFColumnDescr = ^TK_RAFColumnDescr;

type
  TK_FRAData = class(TObject)

    ElemCount : Integer;
    BufData   : TK_RArray;
    PSrcData  : Pointer;
    PSrcEData : Pointer;

    UDTreeBufData : TN_BArray;
    UDTreePFields : TN_PArray;

    ModeFlags : TK_RAModeFlagSet;
    CDataCapt : string;

    DDType : TK_ExprExtType; // Source Data Base Type
    BDType : TK_ExprExtType; // Buffer Data Type

    CDescr: TK_RAFrDescr;

    RAFCArray : TK_RAFCArray;
    FrRAEdit  : TK_FrameRAEdit;
    FOnClearDataChange : TK_NotifyProc;
    PRowColors : PInteger;
    PRowNames  : PString;
    PColNames  : PString;
    FFSkipDataBuf : Boolean;
    FFullDataBuf  : Boolean;
    FFreeFormDescr: Boolean;
    FSkipClearEmptyRArrays : Boolean;
    FClearUndefEmptyRArrays: Boolean;
    FSkipAddToEmpty  : Boolean;
    FRAListFDColInd  : Integer; // RAList FD Columns Index for New Item
    FRAListFDColInds : TList;
    FRAListSelectItemCaption : string;

  private
    FRAListTVSelect  : TK_TreeViewSelect;
    FRAListRowCount  : Integer;
    FRAListMatrixMode: Boolean;
    FRAListFDColumns : TK_RArray;// RAList FD Columns
//    FRAListStrings   : TStrings; // RAList FD Columns
    FRAListMode     : Boolean;  // Edit RAList Items
    FUDTreeDataMode : Boolean; // Edit UDTree Data by Form Descr
    FRAAttrsMode    : Boolean; // Edit RArray Attributes
    FUndefRAType    : Boolean; // Source RArray type is Undefined
    FUseSelfCDescr  : Boolean; // Use Self CDescr
    FRAMatrixMode   : Boolean; // Edit Rarray is Matrix
    FVRAUDRef       : Boolean; // VArray is not RArray

    RAFCPat         : TK_RAFColumn; // Column Pattern for RAMatrix Show/Edit

  public
    constructor Create( AFrameRAEdit: TK_FrameRAEdit );
    destructor  Destroy; override;
    procedure FreeContext;
//    procedure PrepFrameByFDTypeName( AClearModeFlags : TK_RAModeFlagSet;
//                    ASetModeFlags : TK_RAModeFlagSet;
    procedure PrepFrameByFDTypeName( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                    var Data; ADDType : TK_ExprExtType; const ADataCapt : string;
                    FDTypeName : string = ''; GrFlagsMask : LongWord = 0;
                    FFLags : Integer = 0; FMask : Integer = K_efcFlagsMask0 );
    procedure PrepFrameByFormDescr( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                    var Data; ADDType : TK_ExprExtType;
                    const ADataCapt : string; FormDescr : TK_UDRArray = nil;
                    GrFlagsMask : LongWord = 0;
                    FFLags : Integer = 0; FMask : Integer = K_efcFlagsMask0 ); overload;
    procedure PrepFrameByRAList( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                      var RAList : TK_RArray; const ADataCapt : string = '';
                      ARAListRowsCount : Integer = 1;
                      FDUDType : TK_UDFieldsDescr = nil );
    procedure PrepFrameByUDTreeFormDescr( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                    UDRoot : TN_UDBase; const ADataCapt : string;
                    FormDescr : TK_UDRArray = nil; GrFlagsMask : LongWord = 0 );
    procedure PrepFrameMatrixByFDTypeName( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                    var RA: TK_RArray; ADDType : TK_ExprExtType;
                    const ADataCapt : string; FDTypeName : string = '' );
    procedure PrepFrameMatrixByFormDescr( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                    var RA: TK_RArray; ADDType : TK_ExprExtType;
                    const ADataCapt : string; FormDescr : TK_UDRArray = nil );
{
    procedure  PrepFrameByFormDescr( AModeFlags : TK_RAModeFlagSet;
          RA: TK_RArray; FormDescr : TK_UDRArray = nil;
          GrFlagsMask : LongWord = 0;
          FFLags : Integer = 0;
          FMask : Integer = K_efcFlagsMask0 ); overload;
}
    procedure PrepFrame1( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                    var Data; ADDType : TK_ExprExtType; const ADataCapt : string;
                    const AValueCapt : string = ''; PCDescr: TK_RAPFrDescr = nil;
                    ASEInds : TN_IArray = nil; FFLags : Integer = 0;
                    FMask : Integer = K_efcFlagsMask0 );
    procedure PrepMatrixFrame1( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet; var RA: TK_RArray;
                    ADDType : TK_ExprExtType; const ADataCapt : string;
                    PCDescr: TK_RAPFrDescr = nil );
    procedure SetNewData( var Data );
    procedure SetCommonDescr( PCDescr : TK_RAPFrDescr );

    procedure SetOnDataChange( OnDataChange : TK_NotifyProc );
    procedure SetOnClearDataChange( OnClearDataChange : TK_NotifyProc );

    function  GetSrcRecPointer( ) : Pointer;
    function  GetSrcFieldPointer( ) : Pointer;
    function  GetBufRecPointer( ) : Pointer;
    function  GetBufFieldPointer( ) : Pointer;
    procedure OnAddingRAListItem( var ACount : Integer );
    procedure OnAddRAListItem( ACount : Integer );
    procedure OnDelRAListItem( Ind, DCount : Integer );
    procedure OnAddRAListRow( ACount : Integer );
    procedure OnAddDataRow( ACount : Integer );
    procedure OnAddMatrixRow( ACount : Integer );
    procedure OnAddMatrixCol( ACount : Integer );
    function  StoreToUDTreeData : Boolean;
    function  StoreToSData( OnlyFieldsCopy : Boolean = false ) : Boolean;
    function  StoreToRAListData : Boolean;
    function  StoreToMatrixSData : Boolean;

    property  SkipDataBuf : Boolean read FFSkipDataBuf write FFSkipDataBuf;
    property  FullBufData : Boolean read FFullDataBuf write FFullDataBuf;
    property  ClearUndefEmptyRArrays : Boolean read FClearUndefEmptyRArrays write FClearUndefEmptyRArrays;
    property  SkipClearEmptyRArrays : Boolean read FSkipClearEmptyRArrays write FSkipClearEmptyRArrays;
    property  SkipAddToEmpty : Boolean read FSkipAddToEmpty write FSkipAddToEmpty;
    property  RAListFDColInd : Integer read FRAListFDColInd write FRAListFDColInd;
    property  RAListFDColInds : TList  read FRAListFDColInds write FRAListFDColInds;
    property  RAListMatrixMode : Boolean read FRAListMatrixMode;
    property  RAListSelectItemCaption : string read FRAListSelectItemCaption write FRAListSelectItemCaption;

  private
//    function  GetRecPointer( RA : TK_RArray; RNum : Integer ) : Pointer;
    function  GetFieldPointer( PData : Pointer ) : Pointer;
    procedure InitCapts( const ADataCapt : string; const AValueCapt : string );
    procedure InitParams( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                   var Data; ADDType : TK_ExprExtType; const ADataCapt : string;
                   const AValueCapt : string );
    procedure PrepFrameData;
    procedure CreateSrcRArray( ColCount, RowCount : Integer );
    function  PrepBufData( DCount : Integer; out PData : Pointer ) : Boolean;
    procedure PrepColCFlags;
    procedure InitCDescr( PCDescr: TK_RAPFrDescr = nil );
    procedure SetRAListPointers( RAList : TK_RArray; RCount : Integer );

end;

//****************** Global procedures **********************
procedure K_RAFColPrepByDataType( var RAFC : TK_RAFColumn;
                         ModeFlags : TK_RAModeFlagSet; DDType : TK_ExprExtType );
procedure K_RAFColsPrepByDataType( var RAFCArray : TK_RAFCArray; StartNum : Integer;
                         ModeFlags : TK_RAModeFlagSet; DDType : TK_ExprExtType;
                         RFInds : TN_IArray = nil;
                         FFlags : Integer = 0;
                         FMask : Integer = K_efcFlagsMask0 );

procedure K_RAFLColsPrepByDataType( var RAFCArray : TK_RAFCArray; StartNum : Integer;
                         ModeFlags : TK_RAModeFlagSet; DDType : TK_ExprExtType;
                         var ColumnTypePat : TK_RAFCArray );
procedure K_SetRAFColByColDescr( ModeFlags : TK_RAModeFlagSet;
                                 PRAFC : TK_PRAFColumn; PCD : TK_PRAFColumnDescr;
                                 ColumnID : string; SingleFieldMode : Boolean;
                                 FormDescr : TK_UDRArray  );
function  K_GetFormDescrDataCaption( FormDescr : TK_UDRArray ) : string;
function  K_IndexOfColDescrByFieldAttrs( ColDescrs : TK_RArray;
                                    AFieldName : string;
                                    UsedInds : TList ) : Integer;
function  K_InitUDTreeFormDescrColFieldsInfo( UDRoot : TN_UDBase;
                                        FormDescr : TK_UDRArray;
                                        GrFlagsMask : LongWord = 0 ) : Integer;
procedure K_GetUDTreeFormDescrsList( UDRoot : TN_UDBase; FDList : TStrings );
function  K_GetRAListItemType( PRAListItem : TK_PRAListItem; PCD : TK_PRAFColumnDescr ) : TK_ExprExtType;
procedure K_SetRAFColByRAListColDescr( SynchroRAItems : Boolean;
                                       AModeFlags : TK_RAModeFlagSet;
                                       PRAListItem : TK_PRAListItem;
                                       PRAFC : TK_PRAFColumn;
                                       PCD : TK_PRAFColumnDescr;
                                       FormDescr : TK_UDRArray );
function K_RAFColsPrepByRAListFormDescr( var RAFCArray : TK_RAFCArray;
                      var RAListElemCount : Integer;
                      AClearModeFlags : TK_RAModeFlagSet;
                      ASetModeFlags : TK_RAModeFlagSet;
                      RAList : TK_RArray; PRAFrDescr : TK_RAPFrDescr;
                      FormDescr : TK_UDRArray;
                      UsedFDColInds : TList ) : Boolean;
procedure K_RAFColsPrepByUDTreeFormDescr( var RAFCArray : TK_RAFCArray;
        var PFields : TN_PArray; PRAFrDescr : TK_RAPFrDescr;
        AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet; UDRoot : TN_UDBase;
        FormDescr : TK_UDRArray; GrFlagsMask : LongWord = 0 );
procedure K_RAFColsPrepByRADataFormDescr( var RAFCArray : TK_RAFCArray;
        PRAFrDescr : TK_RAPFrDescr;
        ModeFlags : TK_RAModeFlagSet; ADataType : TK_ExprExtType;
        FormDescr : TK_UDRArray; GrFlagsMask : LongWord = 0 );

procedure K_FreeColDescr( var RAFC : TK_RAFColumn );
procedure K_FreeColumnsDescr( RAFCArray : TK_RAFCArray );
function  K_GetDefaultFDTypeName( DType : Int64;
                                  GEID : string = ''; GEIDPrefix : string = '';
                                  PFDType : TK_PExprExtType = nil ) : string;
function  K_GetFormCDescrDType() : TK_ExprExtType;
procedure K_RegRAFViewer( Name : string; RAFViewer : TClass );
procedure K_RegRAFEditor( Name : string; RAFEditor : TClass );
procedure K_RegRAFrDescription( Name : string; DescrName : string );
function  K_GetRAFrDescrTypeName( Name : string; Prefix : string = ''  ) : string;
procedure K_BuildValidRecTypesList( TypesList : TStrings );
procedure K_ClearRAEditFuncCont( PData : TK_PRAEditFuncCont );
procedure K_PutVNodesListToClipBoard( VList : TList );
function  K_EditAppUDNode( UDNode, UDParent : TN_UDBase;  AFOwner : TN_BaseForm;
                           AGAProc : TK_RAFGlobalActionProc; ANotModalShow : Boolean ) : Boolean;
function  K_EditAppUDTreeData( UDNode, UDParent : TN_UDBase; FormDescr : TK_UDRArray;
                               AFOwner : TN_BaseForm; AGAProc : TK_RAFGlobalActionProc;
                               ANotModalShow : Boolean ) : Boolean;
procedure K_BuildAscIndsOrder( var PInds : PInteger; IndsCount : Integer;
                               FullCount : Integer; var FullInds : TN_IArray );

var
  K_RAFViewers : THashedStringList;
  K_RAFEditors : THashedStringList;
  K_RAFrDecriptions : THashedStringList;
  K_RAFEDParsTokenizer : TK_Tokenizer;
  K_RAFGlobContList : THashedStringList;
  K_RAFClipBoard : TK_RAFBuffer;

const
  K_RAFUDRootCursor = 'CR:';


implementation

uses
  StrUtils, Math, Clipbrd,
  K_FRASearch, {K_FSDeb,} K_Sparse1, K_FRAEdit, K_UDConst, K_UDC, K_FUDRename,
  K_CLib, K_FSFCombo, K_UDT2, K_Arch, K_FRADD, K_VFunc, K_RAEdit, K_IWatch,
  N_Lib0, N_ClassRef, N_HelpF, N_Lib2, N_ButtonsF, N_Gra2;

{$R *.dfm}
var
  K_FormCDescrDType : TK_ExprExtType;

const
  K_RAFrameRNumFormat = '%.3d) ';
  K_RAFrameCNumFormat = '#%.3d ';

{*** TK_FrameRAEdit ***}

//**************************************** TK_FrameRAEdit.Create
//
constructor TK_FrameRAEdit.Create(AOwner: TComponent);
begin
  inherited;
  LRPadding := 4;
  DefaultTEdit := nil;
  PasteFromClipboardFlags := K_RAFClipBoard.Flags;
  SetLength( PopupActionGroups, 1 );
end;//*** end of TK_FrameRAEdit.Create

//**************************************** TK_FrameRAEdit.Destroy
//
destructor TK_FrameRAEdit.Destroy;
begin
  FreeContext;
  inherited;
end;//*** end of TK_FrameRAEdit.Destroy

//**************************************** TK_FrameRAEdit.FillArrayByCount
// Init Logical Columns data
//
procedure TK_FrameRAEdit.FillArrayByCount( var Arr : TN_IArray; ArrLeng : Integer; StartNum : Integer = -1 );
begin
  SetLength( Arr, ArrLeng );
  K_FillIntArrayByCounter( @Arr[0], ArrLeng, SizeOf(Integer), StartNum, 1 );
end;//*** end of procedure TK_FrameRAEdit.FillArrayByCount

//**************************************** TK_FrameRAEdit.CompareColElemTexts
// Compare Frame Ordered Column Element Texts
//
function TK_FrameRAEdit.CompareColElemTexts( Ptr1, Ptr2 : Pointer ) : Integer;
var
  Str1, Str2 : string;
  ARow : Integer;
begin
  ARow := PInteger(Ptr1)^;
  Str1 := CurOrderedLColViewer.GetText(
    DataPointers[GLRNumbers[ARow + 1]][CurOrderedLCol]^,
    RAFCArray[CurOrderedLCol], 0, ARow );

  ARow := PInteger(Ptr2)^;
  Str2 := CurOrderedLColViewer.GetText(
    DataPointers[GLRNumbers[ARow + 1]][CurOrderedLCol]^,
    RAFCArray[CurOrderedLCol], 0, ARow );

  Result :=  CompareStr( Str1, Str2 );
  if CurDataDescOrder then Result := -Result;

end;//*** end of procedure TK_FrameRAEdit.CompareColElemTexts

//**************************************** TK_FrameRAEdit.CompareRowElemTexts
// Compare Frame Ordered Row Element Texts
//
function TK_FrameRAEdit.CompareRowElemTexts( Ptr1, Ptr2 : Pointer ) : Integer;
var
  Str1, Str2 : string;
  ACol, LCol : Integer;
  CurViewer : TK_RAFViewer;

begin

  ACol := PInteger(Ptr1)^;
  LCol := GLCNumbers[ACol + 1];
  CurViewer := GetCellViewer( LCol, CurOrderedLRow );

  Str1 := CurViewer.GetText(
    DataPointers[CurOrderedLRow][LCol]^,
    RAFCArray[LCol], ACol, 0);


  ACol := PInteger(Ptr2)^;
  LCol := GLCNumbers[ACol + 1];
  CurViewer := GetCellViewer( LCol, CurOrderedLRow );

  Str2 := CurViewer.GetText(
    DataPointers[CurOrderedLRow][LCol]^,
    RAFCArray[LCol], ACol, 0);

  Result :=  CompareStr( Str1, Str2 );
  if CurDataDescOrder then Result := -Result;

end;//*** end of procedure TK_FrameRAEdit.CompareRowElemTexts

//**************************************** TK_FrameRAEdit.CompareColElems
// Compare Frame Ordered Column Elements
//
function TK_FrameRAEdit.CompareColElems( Ptr1, Ptr2 : Pointer ) : Integer;
begin
  Result := CurDataCompareFunc(
       DataPointers[GLRNumbers[PInteger(Ptr1)^ + 1]][CurOrderedLCol],
       DataPointers[GLRNumbers[PInteger(Ptr2)^ + 1]][CurOrderedLCol] );
end;//*** end of procedure TK_FrameRAEdit.CompareColElems

//**************************************** TK_FrameRAEdit.CompareRowElems
// Compare Frame Ordered Row Elements
//
function TK_FrameRAEdit.CompareRowElems( Ptr1, Ptr2 : Pointer ) : Integer;
begin
  Result := CurDataCompareFunc(
       DataPointers[CurOrderedLRow][GLCNumbers[PInteger(Ptr1)^ + 1]],
       DataPointers[CurOrderedLRow][GLCNumbers[PInteger(Ptr2)^ + 1]] );
end;//*** end of procedure TK_FrameRAEdit.CompareRowElems

//**************************************** TK_FrameRAEdit.ResizeFrame
// Init Logical Columns data
//
procedure TK_FrameRAEdit.ResizeFrame;
var
  FWidth, FHeight, SHeight, SWidth : Integer;
  PlaceTControl : Boolean;
  OwnerForm : TForm;
begin
//Exit;
  if FormResizeMode or SkipResizeFlag then Exit;
  OwnerForm := K_GetOwnerForm( Self );
  SkipResizeFlag := true;
//  SkipSetLastColumnWidth := true;
  PlaceTControl := false;
  SHeight := SelfHeight;
  SWidth  := SelfWidth;
  FHeight := OwnerForm.ClientHeight - Self.ClientHeight + SHeight;
  FWidth  := OwnerForm.ClientWidth  - Self.ClientWidth  + SWidth;
  if not (K_ramSkipResizeHeight in CDescr.ModeFlags) and
     ( not (K_ramOnlyEnlargeSize in CDescr.ModeFlags) or
       (OwnerForm.ClientHeight  <= FHeight) ) then begin
    OwnerForm.ClientHeight := FHeight;
    if not (akTop in Self.Anchors) or not (akBottom in Self.Anchors) then begin
      Self.ClientHeight := SHeight;
    end;
    PlaceTControl := true;
  end;
  if not (K_ramSkipResizeWidth in CDescr.ModeFlags) and
     ( not (K_ramOnlyEnlargeSize in CDescr.ModeFlags) or
       (OwnerForm.ClientWidth  <= FWidth) ) then begin
    OwnerForm.ClientWidth  := FWidth;
    if not (akLeft in Self.Anchors) or not (akRight in Self.Anchors) then begin
      Self.ClientWidth := SWidth;
    end;
    PlaceTControl := true;
  end;
  if PlaceTControl then
    N_PlaceTControl( OwnerForm, nil );
  PlaceTControl := false;
  GetFullFrameSize := true;
  if not (K_ramSkipResizeHeight in CDescr.ModeFlags) and
     ( ((Self.ClientWidth < SWidth) and (SGrid.ColCount <> 2)) or
       ((SGrid.ColCount > 2)                        and
        (K_ramShowSingleRecord in CDescr.ModeFlags) and
         not (K_ramColVertical in CDescr.ModeFlags)) ) then begin
    OwnerForm.ClientHeight := OwnerForm.ClientHeight + 16; // Add Height for ScrollBar
    if not (akTop in Self.Anchors) or not (akBottom in Self.Anchors) then
      Self.Height := Self.Height + 16;
    PlaceTControl := true;
  end;
  GetFullFrameSize := false;
  if not (K_ramSkipResizeWidth in CDescr.ModeFlags) and
     (Self.ClientHeight < SHeight) then begin
    OwnerForm.ClientWidth := OwnerForm.ClientWidth + 16; // Add Height for ScrollBar
    if not (akLeft in Self.Anchors) or not (akRight in Self.Anchors) then
      Self.Width := Self.Width + 16;
    PlaceTControl := true;
  end;
  if PlaceTControl then
    N_PlaceTControl( OwnerForm, nil );
//  SkipSetLastColumnWidth := false;
  SkipResizeFlag := false;
{
//  K_InfoWatch.AddInfoLine(Self.Owner.Name+'.'+Self.Name + ' Before '+IntToStr(Self.ClientWidth)+ ',' + IntToStr(Self.ClientHeight) + ' ** ' + IntToStr(SWidth)+ ',' + IntToStr(SHeight));
  FHeight := TControl(Self.Owner).ClientHeight - Self.ClientHeight + SHeight;
  FWidth  := TControl(Self.Owner).ClientWidth  - Self.ClientWidth  + SWidth;
  if not (K_ramSkipResizeHeight in CDescr.ModeFlags) and
     ( not (K_ramOnlyEnlargeSize in CDescr.ModeFlags) or
       (TControl(Self.Owner).ClientHeight  <= FHeight) ) then begin
    TControl(Self.Owner).ClientHeight := FHeight;
    if not (akTop in Self.Anchors) or not (akBottom in Self.Anchors) then begin
      Self.ClientHeight := SHeight;
    end;
    PlaceTControl := true;
  end;
  if not (K_ramSkipResizeWidth in CDescr.ModeFlags) and
     ( not (K_ramOnlyEnlargeSize in CDescr.ModeFlags) or
       (TControl(Self.Owner).ClientWidth  <= FWidth) ) then begin
    TControl(Self.Owner).ClientWidth  := FWidth;
    if not (akLeft in Self.Anchors) or not (akRight in Self.Anchors) then begin
      Self.ClientWidth := SWidth;
    end;
    PlaceTControl := true;
  end;
  if PlaceTControl then
    N_PlaceTControl( TForm(Self.Owner), nil );
  PlaceTControl := false;
  GetFullFrameSize := true;
  if not (K_ramSkipResizeHeight in CDescr.ModeFlags) and
     ( (Self.ClientWidth < SWidth) or
       ((SGrid.ColCount > 2)                                 and
        (K_ramShowSingleRecord in CDescr.ModeFlags) and
         not (K_ramColVertical in CDescr.ModeFlags)) ) then begin
    TControl(Self.Owner).ClientHeight := TControl(Self.Owner).ClientHeight + 16; // Add Height for ScrollBar
    if not (akTop in Self.Anchors) or not (akBottom in Self.Anchors) then
      Self.Height := Self.Height + 16;
    PlaceTControl := true;
  end;
  GetFullFrameSize := false;
  if not (K_ramSkipResizeWidth in CDescr.ModeFlags) and
     (Self.ClientHeight < SHeight) then begin
    TControl(Self.Owner).ClientWidth := TControl(Self.Owner).ClientWidth + 16; // Add Height for ScrollBar
    if not (akLeft in Self.Anchors) or not (akRight in Self.Anchors) then
      Self.Width := Self.Width + 16;
    PlaceTControl := true;
  end;
  if PlaceTControl then
    N_PlaceTControl( TControl(Self.Owner), nil );
//  SkipSetLastColumnWidth := false;
  SkipResizeFlag := false;
//  K_InfoWatch.AddInfoLine(Self.Owner.Name+'.'+Self.Name + ' After '+IntToStr(Self.ClientWidth)+ ',' + IntToStr(Self.ClientHeight));
}
end;//*** end of procedure TK_FrameRAEdit.ResizeFrame

//**************************************** TK_FrameRAEdit.InitActionsState
// Init Logical Columns data
//
procedure TK_FrameRAEdit.InitActionsState;
begin
  AddCol.Enabled := (K_ramColChangeNum in CDescr.ModeFlags);
  InsCol.Enabled := AddCol.Enabled  and (K_ramColChangeOrder in CDescr.ModeFlags);
  AddRow.Enabled := (K_ramRowChangeNum in CDescr.ModeFlags);
  InsRow.Enabled := AddRow.Enabled and (K_ramRowChangeOrder in CDescr.ModeFlags);
  DelCol.Enabled := ( (MaxColNum > 0) and AddCol.Enabled );
  DelRow.Enabled := ( (MaxRowNum > 0) and AddRow.Enabled );
  ScrollToNextRow.Enabled := (MaxRowNum > 1);
  ScrollToNextRow.Visible := (AddRow.Enabled);
  ScrollToPrevRow.Enabled := (MaxRowNum > 1);
  ScrollToPrevRow.Visible := (AddRow.Enabled);
  ScrollToFirstRow.Enabled := (MaxRowNum > 1);
  ScrollToFirstRow.Visible := (AddRow.Enabled);
  ScrollToLastRow.Enabled := (MaxRowNum > 1);
  ScrollToLastRow.Visible := (AddRow.Enabled);
  SwitchSRecordMode.Enabled := (MaxRowNum > 1);
  SwitchSRecordMode.Visible := (AddRow.Enabled);
end;//*** end of procedure TK_FrameRAEdit.InitActionsState

//**************************************** TK_FrameRAEdit.SetGridInfo
// Init Logical Columns data
//
procedure TK_FrameRAEdit.SetGridInfo( AModeFlags : TK_RAModeFlagSet;
        ARAFCArray : TK_RAFCArray;
        const ACDescr: TK_RAFrDescr;
        ARowsCount : Integer = 1;
        PRName : PString = nil; APRowColorInds : PInteger = nil;
        APColColorIndsMatrix : PInteger = nil
         );
var
  MaxWidth, MinWidth, AWidth, i, ri, CWidth, AColCount, ARowCount : Integer;
  CWidth0 : Integer;
  SelRect: TGridRect;
  TGO : TGridOptions;
  LRPadding2 :  Integer;
  MinRowHeight : Boolean;
  UDRefParams : string;
  MaxColWidths : TN_IArray;
  DataColWidths : TN_IArray;
  FrRowWidths  : TN_IArray;
  FrColWidths  : TN_IArray;
  WidthDeltas : TN_IArray;
  MaxHColWidth, MaxHRowWidth : Integer;
//  MinHRowWidth : Integer;
  EnlargedCol, EnlargedColPermit : Boolean;
  SelColWidth : Integer;

  procedure ClearCells;
  var i, j : Integer;
  begin
    with SGrid do
      for i := 0 to ColCount - 1 do
        for j := 0 to RowCount - 1 do
          Cells[i, j] := '';
  end;

  function EnumMaxLColDataWidth( RAFViewer : TK_RAFViewer; Canvas : TCanvas;
             RAFC : TK_RAFColumn; GridPos : TK_GridPos; AddWidth : Integer ) : Integer;
  var
    h, i, WW : Integer;
    PData : Pointer;
    UseSEInds : Boolean;

  begin
    Result := 0;
    with RAFC, CDType, VEArray[CVEInd] do begin
      if (DTCode < Ord(nptNoData)) or
       (FD.FDObjType <> K_fdtEnum) then  Exit;
      if DataTextWidth <> 0 then
        Result := DataTextWidth
      else begin
        UseSEInds := SEInds <> nil;
        if not UseSEInds then
          h := FD.FDFieldsCount - 1
        else
          h := High(SEInds);
        for i := 0 to h do begin
          if UseSEInds then
            PData := @SEInds[i]
          else
            PData := @i;
          WW := AddWidth + RAFViewer.TextShift + Canvas.TextWidth(
            RAFViewer.GetText( PData^, RAFC, GridPos.Col, GridPos.Row ) );
          Result := Max( WW, Result );
        end;
        DataTextWidth := Result;
      end;
    end;
  end;

  function GetMaxLColDataWidth( ACol : Integer; DefColWidth : Integer = 0 ) : Integer;
  var
    LCol, ri, i, WW, WWS : Integer;
    RAFViewer : TK_RAFViewer;
    GridPos : TK_GridPos;
    PData : Pointer;

  begin
    Result := DefColWidth;
    if DataPointers = nil then Exit;
    LCol := GLCNumbers[ACol];
    with RAFCArray[LCol] do begin
      WWS := CDescr.DataAddCWidth;
      if DataAddCWidth <> 0 then
        WWS := DataAddCWidth;
      RAFViewer := VEArray[0].VObj;
      if not Assigned(RAFViewer) or
         not RAFViewer.IfUseViewer( LCol, 0, RAFCArray[LCol] ) then
          RAFViewer := DefaultRAFViewer;
    //*** Calc width of Enum Field
      Result := EnumMaxLColDataWidth( RAFViewer, SGrid.Canvas, RAFCArray[LCol],
                                       ToGridPos( ACol, 1 ), WWS );
      if Result > 0 then Exit;
    end;

    for i := 1 to ARowCount - 1 do begin
      ri := GLRNumbers[i];
      PData := DataPointers[ri][LCol];
      if PData = nil then Continue;
      GridPos := ToGridPos( ACol, i );
      WW := WWS + RAFViewer.TextShift + SGrid.Canvas.TextWidth(
        RAFViewer.GetText( PData^, RAFCArray[LCol], GridPos.Col, GridPos.Row ) );
      Result := Max( WW, Result );
    end;
  end;

  function GetMaxLRowDataWidth( ARow : Integer; DefRowWidth : Integer = 0 ) : Integer;
  var
    ci, LRow, i, WW, WWS : Integer;
    RAFViewer : TK_RAFViewer;
    PData : Pointer;
    GridPos : TK_GridPos;

  begin
    LRow := GLRNumbers[ARow];
    Result := DefRowWidth;
    if DataPointers = nil then Exit;
    RAFViewer := DefaultRAFViewer;
    for i := 1 to AColCount - 1 do  begin
      ci := GLCNumbers[i];
      PData := DataPointers[LRow][ci];
      if PData = nil then Continue;
      with RAFCArray[ci] do begin
        WWS := CDescr.DataAddCWidth;
        if DataAddCWidth <> 0 then
          WWS := DataAddCWidth;
        if (K_racSeparator in ShowEditFlags) then Continue;
        RAFViewer := VEArray[0].VObj;
        if not Assigned(RAFViewer) or
           not RAFViewer.IfUseViewer( ci, LRow, RAFCArray[ci] ) then
          RAFViewer := DefaultRAFViewer;
      end;
      GridPos := ToGridPos( i, ARow );
      WW := EnumMaxLColDataWidth( RAFViewer, SGrid.Canvas, RAFCArray[ci],
                                                               GridPos, WWS );
      if WW = 0 then
        WW := WWS + RAFViewer.TextShift + SGrid.Canvas.TextWidth(
          RAFViewer.GetText( PData^, RAFCArray[ci], GridPos.Col, GridPos.Row ) );
      Result := Max( WW, Result );
    end;
  end;

  procedure PrepareGridResize1( const HColWidths : TN_IArray );
  var
    CWidth0 : Integer;
    i, wd : Integer;
    WDPart : Double;
    HWidth : Integer;
    LD : Integer;

  begin
    with SGrid do begin
      ClearCells;
      Cells[0, 0] := CDescr.NameCapt;

      if ((K_ramSkipInfoCol in CDescr.ModeFlags) and
          not (K_ramColVertical in CDescr.ModeFlags))
                             or
         ((K_ramSkipInfoRow in CDescr.ModeFlags) and
          (K_ramColVertical in CDescr.ModeFlags)) then
        RowHeights[0] := 0;

      if ((K_ramSkipInfoRow in CDescr.ModeFlags) and
          not (K_ramColVertical in CDescr.ModeFlags))
                             or
         ((K_ramSkipInfoCol in CDescr.ModeFlags) and
          (K_ramColVertical in CDescr.ModeFlags)) then begin
        MaxColWidths[0] := 0;
        DataColWidths[0]:= 0;
      end;

      if CDescr.ColResizeMode = K_crmCompact then begin
      //*** Calc Data Columns Width
        wd := Self.ClientWidth - 3 - ColCount;
        if SelfHeight > Height then Dec(wd, 17); // reserve space for ScrollBar
        HWidth := 0;
        for i := 0 to High(DataColWidths) do begin
          if WidthDeltas[i] = -2 then begin // it is Selected Column
            CWidth0 := SelColWidth;
          end else begin
            CWidth0 := Min( DataColWidths[i], HColWidths[i] );
          end;
          DataColWidths[i] := CWidth0;
          if WidthDeltas[i] >= 0 then Inc( HWidth, CWidth0 );
          wd := wd - CWidth0;
        end;

        if wd >= 0 then begin
          FillChar( WidthDeltas[0], SizeOf(Integer) * Length(WidthDeltas), 0 );
          Exit;
        end;
        LD := -wd;
//        HWidth := Self.ClientWidth + LD;
        for i := 0 to High(DataColWidths) - 1 do
          if (WidthDeltas[i] >= 0) and (HWidth > 0) then begin
            WDPart := DataColWidths[i] / HWidth;
            CWidth0 := Round( LD * WDPart );
            LD := LD - CWidth0;
            HWidth := HWidth - DataColWidths[i];
//            wd := wd + CWidth0;
            DataColWidths[i] := DataColWidths[i] - CWidth0;
          end;
        i := High(DataColWidths);
        if WidthDeltas[i] >= 0 then
          DataColWidths[High(DataColWidths)] := DataColWidths[High(DataColWidths)] - LD;
      end;
    end;

  end;

  procedure SwitchRowColIcons;
  begin
    K_InterchangeTActionsFields( AddCol, AddRow );
    K_InterchangeTActionsFields( DelCol, DelRow );
    K_InterchangeTActionsFields( InsCol, InsRow );
  end;

begin

  SkipResizeFlag := true; //##??
  SGrid.Visible := true;
  HintGridPos.Col := -1;
  MaxRowNum := ARowsCount;

  CDescr := ACDescr;
  if CDescr.CellPadding <> 0 then
    LRPadding := CDescr.CellPadding;

  LRPadding2 := LRPadding + LRPadding;
  with SGrid do begin

    if not InvertMode  then begin
//*** This code is used to avoid SGrid Error Double Top Fixed Row
//*** if in prev SGrig State was Selected Column which is absent in new SGrig State
      SGrid.FixedCols := 1;
      SelRect.Left := 0;
      SelRect.Right := 1;
      SelRect.Top := 0;
      SelRect.Bottom := 1;
      Selection := SelRect;
//*** end of This code

      SendFVals.Visible := (RLSData.RUDRArray <> nil);
      CDescr.ModeFlags := AModeFlags + CDescr.ModeFlags;
      RAFCArray := ARAFCArray;
      MaxColNum := Length( RAFCArray );
      AColCount := MaxColNum + 1;
      ARowCount := MaxRowNum + 1;
//*** Create Row and Column Indexes
      FillArrayByCount( GLCNumbers, AColCount );
      FillArrayByCount( GLRNumbers, ARowCount );
      if RNumFormat = '' then RNumFormat := K_RAFrameRNumFormat;
      if CNumFormat = '' then CNumFormat := K_RAFrameCNumFormat;
    end else begin
      AColCount := Length( GLCNumbers );
      ARowCount := Length( GLRNumbers );
    end;

//*********************************************
//*** Init Frame Control Data
//*********************************************
//##??    InitActionsState;
//1    AddCol.Enabled := (K_ramColChangeNum in CDescr.ModeFlags);
//1    InsCol.Enabled := AddCol.Enabled;

//1    AddRow.Enabled := (K_ramRowChangeNum in CDescr.ModeFlags);
//1    InsRow.Enabled := AddRow.Enabled;
    if not InvertMode  then begin
//      CDescr.ModeFlags := AModeFlags + CDescr.ModeFlags;
//1      DelCol.Enabled := ( (MaxColNum > 0) and AddCol.Enabled );
//1      DelRow.Enabled := ( (MaxRowNum > 0) and AddRow.Enabled );

      InitActionsState;
      OnRowsAdd := nil;

      PColPalette := CDescr.ColumnsPalette.P;
      ColPalLength := CDescr.ColumnsPalette.ALength;
      PRowPalette := CDescr.RowsPalette.P;
      PMixPaletteMatrix := CDescr.MixedPalette.P;


//*** Create Data Pointers Array
      SetLength( DataPointers, MaxRowNum );
      for i := 0 to MaxRowNum - 1 do
        SetLength( DataPointers[i], AColCount - 1 );

//*** Create Defaulte Viewer and Editor
      if DefaultRAFViewer = nil then begin
        DefaultRAFViewer := TK_RAFViewer.Create;
        DefaultRAFViewer.RAFrame := Self;
        DefaultRAFUDViewer := TK_RAFUDRefViewer1.Create;
        DefaultRAFUDViewer.RAFrame := Self;
        UDRefParams := K_udpAbsPathCursorName;
        DefaultRAFUDViewer.SetContext( UDRefParams );
      end;
      if DefaultRAFEditor = nil then begin
        DefaultRAFEditor := TK_RAFEditor.Create;
        DefaultRAFEditor.RAFrame := Self;
      end;

//*** Create Special Controls (ComboBoxes)
     //*** Create ComboBoxes/External Editors context/Show CheckBoxes
//##??      SkipResizeFlag := true;
      for i := 0 to High(RAFCArray) do
        PrepareColumnControls(i);
     //*** Create Default TEdit
      if DefaultTEdit = nil then begin
        DefaultTEdit := TEdit.Create(Self);
        DefaultTEdit.Visible := false;
        DefaultTEdit.OnExit := DefTEditExit;
        DefaultTEdit.OnKeyDown := DefTEditKeyDown;
        DefaultTEdit.Parent := Self;
      end;
//##??      SkipResizeFlag := false;

      FixedRows := 1;
      FixedCols := 1;

      if PRName = nil then RowCaptions := nil;
      SetLength( RowCaptions, Max(MaxRowNum, 1) );
      SetLength( RowMarks, Length( RowCaptions ) );

      if PRName <> nil then
        for i := 0 to MaxRowNum - 1 do begin
          RowCaptions[i] := PRName^;
          Inc( TN_BytesPtr(PRName), SizeOf(string) );
        end;

      SetCellsColors( APRowColorInds, APColColorIndsMatrix );
    end;

    PasteFromClipBoard.Enabled := not (K_ramSkipDataPaste in CDescr.ModeFlags);

//*********************************************
//*** Set StringGrid Row/Column actions Icons
//*********************************************
    if K_ramColVertical in CDescr.ModeFlags then begin
      if AddCol.ImageIndex <> 77 then SwitchRowColIcons;
    end else begin
      if AddCol.ImageIndex <> 69 then SwitchRowColIcons;
    end;
//*********************************************
//*** Set StringGrid Row/Column moving options
//*********************************************
    TGO := Options;
    if K_ramColVertical in CDescr.ModeFlags then begin
      if not (K_ramSkipRowMoving in CDescr.ModeFlags) then
        Include( TGO, goRowMoving )
      else
        Exclude( TGO, goRowMoving );
      if not (K_ramSkipColMoving in CDescr.ModeFlags) then
        Include( TGO, goColMoving )
      else
        Exclude( TGO, goColMoving );
    end else begin
      if not (K_ramSkipColMoving in CDescr.ModeFlags) then
        Include( TGO, goRowMoving )
      else
        Exclude( TGO, goRowMoving );
      if not (K_ramSkipRowMoving in CDescr.ModeFlags) then
        Include( TGO, goColMoving )
      else
        Exclude( TGO, goColMoving );
    end;
    Options := TGO;

//*********************************************
//*** Set StringGrid Columns Width
//*********************************************
    Cells[0, 0] := CDescr.NameCapt;
    AWidth := Canvas.TextWidth( CDescr.NameCapt )  + LRPadding2;
    SetLength( FrColWidths, Max(AColCount,1) );
    MaxHColWidth := AWidth;
//    FrColWidths[0] := AWidth;
    if K_ramShowLColNumbers in CDescr.ModeFlags then
      CWidth0 := Canvas.TextWidth( format( CNumFormat, [AColCount]) )
    else
      CWidth0 := 0;
    for i := 1 to High(FrColWidths) do begin
      with RAFCArray[GLCNumbers[i]] do
        if (K_racSeparator in ShowEditFlags) then
          CWidth := CDescr.DSeparatorSize
        else
          CWidth := Canvas.TextWidth( Caption ) + CWidth0 + LRPadding2;
      MaxHColWidth := Max( MaxHColWidth, CWidth );
      FrColWidths[i] := CWidth;
    end;
    SetLength( FrRowWidths, Max(ARowCount,1) );
    MaxHRowWidth := AWidth;
//    FrRowWidths[0] := AWidth;
    if K_ramShowLRowNumbers in CDescr.ModeFlags then
      CWidth0 := Canvas.TextWidth( format( RNumFormat, [ARowCount]) )
    else
      CWidth0 := 0;
//    MinHRowWidth := CWidth0 + LRPadding2;
    for i := 1 to High(FrRowWidths) do
    begin
      CWidth := Canvas.TextWidth( RowCaptions[GLRNumbers[i]] ) + CWidth0 + LRPadding2;
      MaxHRowWidth := Max( MaxHRowWidth, CWidth );
      FrRowWidths[i] := CWidth;
    end;

    RowHeights[0] := DefaultRowHeight;
    EnlargedColPermit := (K_ramAutoEnlargeSelectedCol in CDescr.ModeFlags) and
                         (CDescr.ColResizeMode <> K_crmNormal);
    if K_ramColVertical in CDescr.ModeFlags then
    begin
//*** Vertical Logic Columns

      ColCount := Max( AColCount, 2 );
      RowCount := Max( ARowCount, 2 );

      for i := 1 to RowCount - 1 do
        RowHeights[i] := DefaultRowHeight;

      // Calc Selected Col Width in Compact Mode
      SetLength( MaxColWidths, AColCount );
      SetLength( DataColWidths, AColCount );
      SetLength( WidthDeltas, AColCount );
      MaxColWidths[0] := MaxHRowWidth;
      DataColWidths[0] := MaxHRowWidth;
//??      if FrColWidths[0] = 0 then
//??        FrColWidths[0] := MaxHRowWidth;
//??      FrColWidths[0] := Max( FrColWidths[0], MinHRowWidth );
      FrColWidths[0] := MaxHRowWidth;
      for i := 1 to AColCount - 1 do begin
        ri := GLCNumbers[i];
        if (K_racSeparator in RAFCArray[ri].ShowEditFlags) then begin
          MaxColWidths[i] := CDescr.DSeparatorSize;
          DataColWidths[i]:= CDescr.DSeparatorSize;
          WidthDeltas[i] := -1;
        end else begin
          DataColWidths[i]:= GetMaxLColDataWidth( i, 0 )+ LRPadding2;
          MaxColWidths[i] := Max( FrColWidths[i], DataColWidths[i] );
//!!Error          MaxColWidths[i] := Max( FrColWidths[ri + 1], DataColWidths[i] );
          MaxWidth := CDescr.MaxCWidth;
          if RAFCArray[ri].MaxCWidth <> 0 then
            MaxWidth := RAFCArray[ri].MaxCWidth;
          if MaxWidth <> 0 then begin
            MaxColWidths[i] := Min( MaxColWidths[i], MaxWidth );
            DataColWidths[i]:= Min( DataColWidths[i], MaxWidth );
          end;
        end;
      end;

      SelColWidth := 0;
      if EnlargedColPermit then begin
        ri := CurLPos.Col;
        if ((CurGPos.Col <> 0) or (CurGPos.Row <> 0)) and
           (GLCNumbers[CurGPos.Col] = ri) then begin
         WidthDeltas[CurGPos.Col] := -2; // Selected Column Flag
         if CurLPos.Row >= 0 then
           SelColWidth := DataColWidths[CurGPos.Col]
         else
           SelColWidth := FrColWidths[CurGPos.Col]
        end;
      end;

      PrepareGridResize1( FrColWidths );

  //    MinWidth := CDescr.MinHColWidth;
      MinWidth := 0;
      for i := 0 to AColCount - 1 do begin

        if EnlargedColPermit then begin
          ri := CurLPos.Col;
          EnlargedCol := (ri >= 0) and
                         (GLCNumbers[i] = ri);
        end else
          EnlargedCol := false;
        if EnlargedCol then
          ColWidths[i] := SelColWidth
        else begin
          if CDescr.ColResizeMode = K_crmNormal then
            ColWidths[i] := MaxColWidths[i]
          else begin
            case CDescr.ColResizeMode of
              K_crmCompact, K_crmDataBased: CWidth0 := DataColWidths[i];
              K_crmHeaderBased: CWidth0 := FrColWidths[i];
            end;
            ColWidths[i] := Max( CWidth0, Max( MinWidth, CDescr.DSeparatorSize ));
          end;
        end;
        MinWidth := CDescr.MinCWidth;
      end;

    end else begin
//*** Horizontal Logic Columns
      ColCount := Max( ARowCount, 2 );
      RowCount := Max( AColCount, 2 );

      for i := 1 to High( GLCNumbers) do begin
        ri := GLCNumbers[i];
        with RAFCArray[ri] do
          if K_racSeparator in ShowEditFlags then begin
            if Caption = '' then
              RowHeights[i] := CDescr.DSeparatorSize
            else
              RowHeights[i] := DefaultRowHeight - 2;
          end else
            RowHeights[i] := DefaultRowHeight;
      end;
//*** Check 0-row height
      MinRowHeight := false;
      if (Trim(Cells[0, 0]) = '') and not (K_ramShowLRowNumbers in CDescr.ModeFlags) then begin
        MinRowHeight := true;
        for i := 1 to ARowCount - 1 do
          if RowCaptions[GLRNumbers[i]] <> '' then begin
            MinRowHeight := false;
            Break;
          end;
        if MinRowHeight then
          RowHeights[0] := 0;
      end;

      MaxWidth := CDescr.MaxCWidth;
      for i := 0 to High(RAFCArray) do
        with RAFCArray[i] do
          if MaxCWidth <> 0 then
            MaxWidth := Max( MaxWidth, MaxCWidth );

      SetLength( MaxColWidths, ARowCount );
      SetLength( DataColWidths, ARowCount );
      SetLength( WidthDeltas, ARowCount );
      if ARowCount > 0 then begin
        MaxColWidths[0] := MaxHColWidth;
        DataColWidths[0] := MaxHColWidth;
//??        if FrRowWidths[0] = 0 then
//??          FrRowWidths[0] := MaxHColWidth;
        FrRowWidths[0] := MaxHColWidth;
        for i := 1 to ARowCount - 1 do begin
//          ri := GLRNumbers[i];
          DataColWidths[i] := GetMaxLRowDataWidth( i, 0 )+ LRPadding2;

          if MinRowHeight then
            CWidth0 := 0
          else
            CWidth0 := FrRowWidths[i];
//!!Error            CWidth0 := FrRowWidths[ri + 1];

          MaxColWidths[i] := Max( CWidth0, DataColWidths[i] );

          if MaxWidth <> 0 then begin
            MaxColWidths[i] := Min( MaxColWidths[i], MaxWidth );
            DataColWidths[i]:= Min( DataColWidths[i], MaxWidth );
          end;
        end;

        SelColWidth := 0;
        if EnlargedColPermit then begin
          ri := CurLPos.Row;
//          if ((CurGPos.Col <> 0) or (CurGPos.Row <> 0)) and
          if ((CurGPos.Col > 0) or (CurGPos.Row > 0)) and
             (GLRNumbers[CurGPos.Col] = ri) then begin
            WidthDeltas[CurGPos.Col] := -2; // Selected Column Flag
            if CurLPos.Col >= 0 then
              SelColWidth := DataColWidths[CurGPos.Col]
            else
              SelColWidth := FrRowWidths[CurGPos.Col]
          end;
        end;

        PrepareGridResize1( FrRowWidths );

        CWidth := 0;
        MinWidth := CDescr.MinHColWidth;
        for i := 0 to ARowCount - 1 do begin
          if EnlargedColPermit then begin
            ri := CurLPos.Row;
            EnlargedCol := (ri >= 0) and
                           (GLRNumbers[i] = ri);
          end else
            EnlargedCol := false;

          if EnlargedCol then
            ColWidths[i] := DataColWidths[i]
          else begin
            if CDescr.ColResizeMode = K_crmNormal then
              ColWidths[i] := MaxColWidths[i]
            else begin
              case CDescr.ColResizeMode of
                K_crmCompact, K_crmDataBased: CWidth0 := DataColWidths[i];
                K_crmHeaderBased: CWidth0 := FrRowWidths[i];
              end;
              ColWidths[i] := Max( CWidth0, Max( MinWidth, CDescr.DSeparatorSize ) );
            end;
          end;
          MinWidth := CDescr.MinCWidth;
          CWidth := Max(ColWidths[i], CWidth);
        end;

        if K_ramShowSingleRecord in CDescr.ModeFlags then begin
          for i := 1 to ARowCount - 1 do
            ColWidths[i] := CWidth;
        end;
      end;
    end;

//    SelRect := Selection;
    SelRect.Left := 0;
    SelRect.Right := 0;
    SelRect.Top := 0;
    SelRect.Bottom := 0;
    Selection := SelRect;
    CurLPos.Col := -1;
    CurLPos.Row := -1;
  end;

  SkipResizeFlag := false; //##??
  ResizeFrame;
//*** Set last column width
  SetLastColumnWidth;
  if not InvertMode then ResizeBeforeFirstShowMode := true;

  BtExtEditor_1.Visible := false;

end;//*** end of procedure TK_FrameRAEdit.SetGridInfo

//**************************************** TK_FrameRAEdit.PopUpRebuildGridInfoMenu
//
procedure TK_FrameRAEdit.PopUpRebuildGridInfoMenu(Sender: TObject);
begin
  case CDescr.ColResizeMode of
  K_crmCompact     : PUMItemCompact.Checked := true;
  K_crmHeaderBased : PUMItemByHeader.Checked := true;
  K_crmDataBased   : PUMItemByData.Checked := true;
  K_crmNormal      : PUMItemNormal.Checked := true;
  end;
end; // end of TK_FrameRAEdit.PopUpRebuildGridInfoMenu

//**************************************** TK_FrameRAEdit.RebuildGridInfo
// Rebuild Grid and Resize if needed
//
procedure TK_FrameRAEdit.RebuildGridInfo();
var
  WColResizeMode : TK_RAColResizeMode;
begin
  InvertMode := true;
  WColResizeMode := CDescr.ColResizeMode;
  if N_KeyIsDown(VK_SHIFT) then
    CDescr.ColResizeMode := K_crmNormal;
  if N_KeyIsDown(VK_CONTROL) then
  begin
    CDescr.ColResizeMode := K_crmCompact;
    if N_KeyIsDown(VK_SHIFT) then
      CDescr.ColResizeMode := K_crmDataBased;
  end;

  PopUpRebuildGridInfoMenu( nil );

  SetGridInfo( [], RAFCArray, CDescr, MaxRowNum );
  CDescr.ColResizeMode := WColResizeMode;
  InvertMode := false;
end;//*** end of procedure TK_FrameRAEdit.RebuildGridInfo

//**************************************** TK_FrameRAEdit.GetRect
// Get Grig Rectangle
//
function TK_FrameRAEdit.GetRect( LCol : Integer = -1;
                                 TRow : Integer = -1;
                                 RCol : Integer = -1;
                                 BRow : Integer = -1 ) : TGridRect;
var
  RMax : Integer;
  CMax : Integer;

  procedure GSect( var RMin, RMax : Integer; SMin, SMax, AMax : Integer );
  begin
    RMin := SMin;
    if RMin < 0 then
      RMin := 0
    else
      RMin := Min( RMin, AMax );

    RMax := SMax;
    if RMax <= 0 then
      RMax := AMax
    else begin
      RMax := Max( RMax, RMin );
      RMax := Min( RMax, AMax );
    end;
  end;

begin
  if K_ramColVertical in CDescr.ModeFlags then begin
    RMax := Length(GLRNumbers) - 1;
    CMax := Length(GLCNumbers) - 1;
  end else begin
    RMax := Length(GLCNumbers) - 1;
    CMax := Length(GLRNumbers) - 1;
  end;
  GSect( Result.Left, Result.Right, LCol, RCol, CMax );
  GSect( Result.Top, Result.Bottom, TRow, BRow, RMax );
end;//*** end of procedure TK_FrameRAEdit.GetRect

//**************************************** TK_FrameRAEdit.GetFieldsList
// Get Frame Fields List
//
procedure TK_FrameRAEdit.GetFieldsList( FL : TStrings; GetCaptions : Boolean = true;
                             FieldsIndexes : TN_IArray = nil );
var
  i, j, h : Integer;
  WStr : string;
begin
  if FieldsIndexes <> nil then
    h := High(FieldsIndexes)
  else
    h := High(RAFCArray);
  FL.Clear;
  for i := 0 to h do begin
    if FieldsIndexes <> nil then
      j := FieldsIndexes[i]
    else
      j := i;
    if RAFCArray[j].Name = '' then continue;
    if GetCaptions then
      WStr := RAFCArray[i].Caption
    else
      WStr := RAFCArray[j].Name;

    FL.Add( WStr );
  end;

end;//*** end of procedure TK_FrameRAEdit.GetFieldsList

//**************************************** TK_FrameRAEdit.SelectRect
// Select Grig Phisycal Rectagle
//
procedure TK_FrameRAEdit.SelectRect( LCol : Integer = -1;
                           TRow : Integer = -1;
                           RCol : Integer = -1;
                           BRow : Integer = -1 );
var
 GR : TGridRect;
 FLCol, FLRow : Boolean;
begin
  if (Length(GLRNumbers) = 0) or (Length(GLCNumbers)= 0) then Exit;

  if LCol= -3 then begin
    FLCol := (CurLPos.Col >= 0) and (CurLPos.Row = -1);
    FLRow := (CurLPos.Row >= 0) and (CurLPos.Col = -1);
    if FLCol then begin
      if K_ramColVertical in CDescr.ModeFlags then
        with GR do begin
          Left := CurLPos.Col + 1;
          Top := 0;
          Right := CurLPos.Col + 1;
          Bottom := 0;
        end
      else
        with GR do begin
          Left := 0;
          Top := CurLPos.Col + 1;
          Right := 0;
          Bottom := CurLPos.Col + 1;
        end;
    end else if FLRow then begin
      if K_ramColVertical in CDescr.ModeFlags then
        with GR do begin
          Left := 0;
          Top := CurLPos.Row + 1;
          Right := 0;
          Bottom := CurLPos.Row + 1;
        end
      else
        with GR do begin
          Left := CurLPos.Row + 1;
          Top := 0;
          Right := CurLPos.Row + 1;
          Bottom := 0;
        end;
    end else
      with GR do begin
        Left := 0;
        Top := 0;
        Right := 0;
        Bottom := 0;
      end;
    SGrid.Selection := GR;
    Exit;
  end else if LCol= -2 then begin
  // Clear Grid Selection Context
    CurGPos.Col := 0;
    CurGPos.Row := 0;
    CurLPos.Col := -1;
    CurLPos.Row := -1;
    with GR do begin
      Left := 0;
      Top := 0;
      Right := 0;
      Bottom := 0;
    end;
    SGrid.Selection := GR;
    Exit;
  end else begin
  // Select Given Rectangle, Set UpperLeft Edge as Current Cell, Make UpperLeft Visible
    GR := GetRect( LCol, TRow, RCol, BRow );

    with SGrid do begin
      Selection := GR;
      GR.Left := Max( 1, GR.Left );
      GR.Top := Max( 1, GR.Top );
      SetCurLPos( GR.Left, GR.Top );
      if (LeftCol > 0) and
         ( (LeftCol > GR.Left) or
           (LeftCol + VisibleColCount < GR.Right ) ) then begin
        if LeftCol + VisibleColCount < GR.Right then
           LeftCol := GR.Right - VisibleColCount + 1;
         if LeftCol > GR.Left then LeftCol := GR.Left;
      end;
      if (TopRow > 0) and
         ( (TopRow > GR.Top) or
           (TopRow + VisibleRowCount < GR.Bottom ) ) then begin
        if TopRow + VisibleRowCount < GR.Bottom then
           TopRow := GR.Bottom - VisibleRowCount + 1;
        if TopRow > GR.Top then TopRow := GR.Top;
      end;
    end;
  end;
end;//*** end of procedure TK_FrameRAEdit.SelectRect

//**************************************** TK_FrameRAEdit.SelectLRect
// Select Grig Logic Rectagle
//
procedure TK_FrameRAEdit.SelectLRect( LCol : Integer = -1;
                           TRow : Integer = -1;
                           RCol : Integer = -1;
                           BRow : Integer = -1 );
begin
  Inc( LCol );
  Inc( RCol );
  Inc( TRow );
  Inc( BRow );
  if K_ramColVertical in CDescr.ModeFlags then
    SelectRect( LCol, TRow, RCol, BRow )
  else
    SelectRect( TRow, LCol, BRow, RCol );
end;//*** end of procedure TK_FrameRAEdit.SelectLRect

//*************************************** TK_FrameRAEdit.IndexOfColumn
// Search for column by Name
//
function TK_FrameRAEdit.IndexOfColumn( CName : string ) : Integer;
var
  i : Integer;
begin
  Result := -1;
  for i := 0 to High(RAFCArray) do
    if RAFCArray[i].Name = CName then begin
      Result := i;
      break;
    end;
end;//*** end of function TK_FrameRAEdit.IndexOfColumn

//**************************************** TK_FrameRAEdit.SetGridLRowsNumber
// Init Logical Columns data
//
procedure TK_FrameRAEdit.SetGridLRowsNumber(  ARowsCount : Integer = 1; SetOriginalColsOrder : Boolean = true );
var
  i, CWidth, AColCount, ARowCount : Integer;
//  FWidth, FHeight : Integer;

begin

  MaxRowNum := ARowsCount;
  ARowCount := ARowsCount + 1;
  with SGrid do begin

    MaxColNum := Length( RAFCArray );
    AColCount := MaxColNum + 1;
    if SetOriginalColsOrder then
      FillArrayByCount( GLCNumbers, AColCount );

//????    SetLength( FrColWidth, AColCount - 1 );


//*** Create Row  Indexes
    FillArrayByCount( GLRNumbers, ARowCount );

//*** Clear Current Selection Context
    SelectRect( -2 );

//*** Create Data Pointers Array
    SetLength( DataPointers, MaxRowNum );
    for i := 0 to MaxRowNum - 1 do
      SetLength( DataPointers[i], AColCount - 1 );


    SetLength( RowCaptions, Max(MaxRowNum, 1) );
    SetLength( RowMarks, Length(RowCaptions) );
    i := Max( ARowCount, 2 );
    if K_ramColVertical in CDescr.ModeFlags then begin
      RowCount := i;
    end else begin
      ColCount := i;

      if CDescr.DefRColWidth = 0 then
        CWidth := DefaultColWidth
      else
        CWidth := CDescr.DefRColWidth;

      for i := 1 to ARowCount - 1 do begin
        ColWidths[i] := CWidth;
      end;

    end;
//*** set last column width
    SetLastColumnWidth;
  end;

//!!!  SelectRect( -2 );
  ResizeFrame;

  DelCol.Enabled := ( (MaxColNum > 0) and AddCol.Enabled );
  DelRow.Enabled := ( (MaxRowNum > 0) and AddRow.Enabled );

end;//*** end of procedure TK_FrameRAEdit.SetGridLRowsNumber

//**************************************** TK_FrameRAEdit.SetCellsColors
// Set Individual Cell Color Indexes
//
procedure TK_FrameRAEdit.SetCellsColors( APRowColorInds : PInteger = nil;
        APColColorIndsMatrix : PInteger = nil );
begin
  PRowColorInds := TN_BytesPtr(APRowColorInds);
  PColColorIndsMatrix := TN_BytesPtr(APColColorIndsMatrix);
end;//*** end of procedure TK_FrameRAEdit.SetCellsColors

//**************************************** TK_FrameRAEdit.FreeContext
// Free Frame Context
//
procedure TK_FrameRAEdit.FreeContext;
//var
//  i : Integer;
begin
  SGrid.Invalidate;
  SGrid.Visible := false;

  GLCNumbers := nil;
  GLRNumbers := nil;
  RowCaptions := nil;
  RowMarks := nil;
  if (DefaultTEdit <> nil) and
     DefaultTEdit.Visible then DefaultTEdit.Visible := false;
//  for i := 0 to High( TCMBArray ) do
//    TCMBArray[i].Free;
//  TCMBArray := nil;

  DataPointers := nil;
  FreeAndNil(DefaultRAFViewer);
  FreeAndNil(DefaultRAFUDViewer);
  FreeAndNil(DefaultRAFEditor);
  FreeAndNil(MarkedLColsList);
  FreeAndNil(MarkedLRowsList);

  K_FreeArrayObjects(CurFieldEActions);
  K_FreeArrayObjects(CurFieldRAFEditors);


end;//*** end of procedure TK_FrameRAEdit.FreeContext

//**************************************** TK_FrameRAEdit.HideEdControls
// Hide all Cells Editors Controls
//
procedure TK_FrameRAEdit.HideEdControls;
begin
  if (Length(RAFCArray) = 0) or
     (CurLPos.Col < 0)       or
     (CurLPos.Row < 0) then Exit;
  if Assigned(DefaultTEdit) then
    DefaultTEdit.Visible := false;

  with RAFCArray[CurLPos.Col] do
    if (CVEInd >= 0) and (CVEInd < Length(VEArray)) then
      with VEArray[CVEInd] do
       if Integer(EObj) > 100 then EObj.Hide;
end;//*** end of procedure TK_FrameRAEdit.HideEdControls

//**************************************** TK_FrameRAEdit.ClearDataPointers
// Convert Logic Cell Coords to Grid Coords
//
procedure TK_FrameRAEdit.ClearDataPointers(StartCol, StartRow, ColNumber,
                                                  RowNumber: Integer);
var
  i, j, h, k : Integer;
begin
  h := ColNumber;
  if h < 1 then
    h := MaxColNum
  else
    Inc(h, StartCol);
  h := Min(h, MaxColNum);
  Dec(h);

  k := RowNumber;
  if k < 1 then
    k := MaxRowNum
  else
    Inc(k, StartRow);
  k := Min(k, MaxRowNum);
  Dec(k);

  for j := Max(0, StartCol) to h do
    for i := Max(0, StartRow) to k do
      DataPointers[i][j] := nil;

end;//*** end of procedure TK_FrameRAEdit.ClearDataPointers

//**************************************** TK_FrameRAEdit.SetDataPointersColumn
// Set Data Pointers Column Array
//
procedure TK_FrameRAEdit.SetDataPointersColumn( var Data; DataStep : Integer;
      Col : Integer; StartRow : Integer = 0;
      PIndex : PInteger = nil; ILength : Integer = -1 );
var
  i, h, n, k : Integer;
  PData : TN_BytesPtr;
begin
  if (ILength < 0) or (PIndex = nil) then
    n := High( DataPointers )
  else
    n := ILength - 1;
  if n >= 0 then
    h := High( DataPointers[0] )
  else
    h := -1;
  if (Col < 0) or (Col > h) then Exit;
  PData := @Data;
  for i := StartRow to n do begin
    if PIndex <> nil then begin
      k := PIndex^;
      Inc( TN_BytesPtr(PIndex), SizeOf(Integer) );
    end else
      k := i;
    if k < 0 then
      DataPointers[i][Col] := nil
    else
      DataPointers[i][Col] := PData + k*DataStep;
  end;
end; //*** end of function TK_FrameRAEdit.SetDataPointersColumn

//**************************************** TK_FrameRAEdit.SetDataPointersFromColumnRArrays
// Set Data Pointers from Column RArrays
//
procedure TK_FrameRAEdit.SetDataPointersFromColumnRArrays( var Data : TK_RArray;
      PIndex : PInteger = nil; ILength : Integer = -1;
      StartRow : Integer = 0; StartCol : Integer = 0; ColNumber : Integer = 0 );
var
  n, h, j : Integer;
  PCRArray : TK_PRArray;
begin


  PCRArray := @Data;
  if ILength < 0 then
    n := High( DataPointers )
  else
    n := ILength - 1;
  if n >= 0 then
    h := High( DataPointers[0] )
  else
    h := -1;
  if ColNumber = 0 then ColNumber := h + 1;
  Inc(ColNumber, StartCol);
  h := Min( h, ColNumber - 1 );

  for j := StartCol to h do begin
    SetDataPointersColumn( (PCRArray.P)^, PCRArray^.ElemSize, j,
                             StartRow, PIndex, ILength );
//*** Get Column Data Pointer
    Inc( TN_BytesPtr(PCRArray), SizeOf(Pointer) );
  end;
end; //*** end of function TK_FrameRAEdit.SetDataPointersFromColumnRArrays

//**************************************** TK_FrameRAEdit.SetDataPointersFromRArray
// Set Data Pointers from RArray
//
function TK_FrameRAEdit.SetDataPointersFromRArray( const Data; DDType : TK_ExprExtType;
                  StartRow : Integer = 0; StartCol : Integer = 0 ) : Integer;
var
  i, k, j, m : Integer;
  RPData : TN_BytesPtr;
  DataStep : Integer;
begin

  Result := StartCol;

  if (DDType.D.TFlags and K_ffFlagsMask) <> 0 then Exit;

  k := High(RAFCArray) - StartCol;
  if DDType.DTCode < Ord( nptNoData ) then
    k := 0;

  RPData := @Data;
  Result := StartCol + k + 1;
  DataStep := K_GetExecTypeSize( DDType.All );
  for j := StartRow to High(DataPointers) do begin
    if (DDType.D.TFlags and K_ffArray) <> 0 then
      RPData := TK_RArray(Data).P(j);
    m := StartCol;
    for i := 0 to k do begin
      DataPointers[j][m] := RPData + RAFCArray[m].FieldPos;
      Inc( m );
    end;
//*** Get Row Data Pointer
    if (DDType.D.TFlags and K_ffArray) = 0 then
      RPData := RPData + DataStep;
  end;


end; //*** end of function TK_FrameRAEdit.SetDataPointersFromRArray

//**************************************** TK_FrameRAEdit.SetDataPointersFromRAMatrix
// Set Data Pointers from RArray
//
procedure TK_FrameRAEdit.SetDataPointersFromRAMatrix( RAM : TK_RArray );
var
  RowLength, ColLength, ICol, IRow, m : Integer;
begin

  with RAM do begin
    ALength( RowLength, ColLength );
    SetLength( DataPointers, ColLength );
    m := 0;
    for IRow := 0 to High(DataPointers) do begin
      SetLength( DataPointers[IRow], RowLength );
      for ICol := 0 to RowLength - 1 do begin
        DataPointers[IRow][ICol] := P(m);
        Inc( m );
      end;
    end;
  end;
end; //*** end of procedure TK_FrameRAEdit.SetDataPointersFromRAMatrix

//*************************************** TK_FrameRAEdit.GetRowData
// Copy Data by RAFrame Columns Descr Records Array
//
procedure TK_FrameRAEdit.GetRowData( LRow : Integer; var Data;
                                     MDFlags : TK_MoveDataFlags = [] );
var
  i, h, j : Integer;
  RPData : TN_BytesPtr;
begin
  if K_ramReadOnly in CDescr.ModeFlags then Exit;
  RPData := @Data;
  j := GetDataBufRow(LRow);
  h := High(RAFCArray);
  for i := 0 to h do begin
    with RAFCArray[i] do
      if not (K_racReadOnly in ShowEditFlags)  and
         not (K_racSeparator in ShowEditFlags) and
         not (K_racSkipFieldMove in ShowEditFlags) then
        K_MoveSPLData( DataPointers[j][i]^,(RPData + FieldPos)^,
                      CDType, MDFlags );
  end;
end; //*** end of procedure TK_FrameRAEdit.GetRowData

//*************************************** TK_FrameRAEdit.GetFrameData
// Copy Data by RAFrame Columns Descr Records Array
//
procedure TK_FrameRAEdit.GetFrameData( var Data; RArrayData : Boolean;
                                     MDFlags : TK_MoveDataFlags = []  );
var
  i, h : Integer;
  RPData : Pointer;
begin
  if K_ramReadOnly in CDescr.ModeFlags then Exit;
  h := GetDataBufRow - 1;
  for i := 0 to h do begin
    if RArrayData then
      RPData := TK_RArray(Data).P(i)
    else
      RPData := @Data;
    GetRowData( i, RPData^, MDFlags );
  end;
end; //*** end of procedure TK_FrameRAEdit.GetFrameData

//**************************************** TK_FrameRAEdit.GetDataToRArray
//
//
function TK_FrameRAEdit.GetDataToRArray( const Data; DDType : TK_ExprExtType;
                  StartCol : Integer = 0; ColNum : Integer = 0  ) : Integer;
var
  ESize, i, k, j, m, h, n : Integer;
  RPData : TN_BytesPtr;
  MDFlags : TK_MoveDataFlags;
begin
//
  Result := StartCol;
  if (K_ramReadOnly in CDescr.ModeFlags) or
     ((DDType.D.TFlags and K_ffFlagsMask) <> 0) then Exit;

  if ColNum = 0 then ColNum := High(RAFCArray) - StartCol;

  if DDType.DTCode > Ord( nptNoData ) then begin
    k := High(RAFCArray) - StartCol;
  end else begin
    k := 0;
  end;

  k := Min( ColNum, k );

  Result := StartCol + k + 1;
  RPData := @Data;
  h := GetDataBufRow - 1;
  if (((DDType.EFlags.CFlags and K_ccCountUDRef) <> 0) and
      ((DDType.EFlags.CFlags and K_ccStopCountUDRef) = 0)) then
    MDFlags := [K_mdfCountUDRef]
  else
    MDFlags := [];
  MDFlags := MDFlags + [K_mdfFreeDest,K_mdfCopyRArray];
  ESize := K_GetExecTypeSize( DDType.All );
  for j := 0 to h do begin
    if (DDType.D.TFlags and K_ffArray) <> 0 then
      RPData := TK_RArray(Data).P(j);
    m := StartCol;
    n := GetDataBufRow(j);
    for i := 0 to k do begin
      with RAFCArray[m] do
        if not (K_racReadOnly in ShowEditFlags)   and
           not (K_racSeparator in ShowEditFlags) and
           not (K_racSkipFieldMove in ShowEditFlags) then
//?? 27.05.2004        K_FreeSPLData( (RPData + FieldPos)^, CDType.All, K_mdfCountUDRef in MDFlags );
          K_MoveSPLData( DataPointers[n][m]^,
                      (RPData + FieldPos)^,
                      CDType, MDFlags );
      Inc( m );
    end;

//*** Get Row Data Pointer
    if (DDType.D.TFlags and K_ffArray) = 0 then
      RPData := RPData + ESize;
  end;

end; //*** end of function TK_FrameRAEdit.GetDataToRArray

//**************************************** TK_FrameRAEdit.GetDataToRAMatrix
//
//
procedure TK_FrameRAEdit.GetDataToRAMatrix( var Data; DDType : TK_ExprExtType  );
var
  i, j, m, n : Integer;
  MDFlags : TK_MoveDataFlags;
  NCol, NRow, ESize : Integer;
  PData : TN_BytesPtr;
  PRInds, PCInds, CurPCInds : PInteger;
  FullRInds, FullCInds : TN_IArray;
begin
  if (((DDType.EFlags.CFlags and K_ccCountUDRef) <> 0) and
      ((DDType.EFlags.CFlags and K_ccStopCountUDRef) = 0)) then
    MDFlags := [K_mdfCountUDRef]
  else
    MDFlags := [];
  MDFlags := MDFlags + [K_mdfCopyRArray];
  PData := @Data;
  ESize := K_GetExecTypeSize( DDType.All );
  NRow := GetDataBufRow;
  PRInds := GetPRowIndex;
  if not (K_ramRowChangeOrder in ModeFlags) and
     not (K_ramSkipRowMoving in ModeFlags) then
    K_BuildAscIndsOrder( PRInds, NRow, -1, FullRInds );
  NCol := GetDataBufCol;
  PCInds := GetPColIndex;
  if not (K_ramColChangeOrder in ModeFlags) and
     not (K_ramSkipColMoving in ModeFlags) then
    K_BuildAscIndsOrder( PCInds, NCol, -1, FullCInds );
  for j := 0 to NRow - 1 do begin
    n := PRInds^;
    Inc(PRInds);
    CurPCInds := PCInds;
    for i := 0 to NCol - 1 do begin
      m := CurPCInds^;
      K_MoveSPLData( DataPointers[n][m]^, (PData)^, DDType, MDFlags );
      Inc(PData, ESize);
      Inc(CurPCInds);
    end;
  end;

end; //*** end of function TK_FrameRAEdit.GetDataToRAMatrix

//**************************************** TK_FrameRAEdit.GetDataToRAMatrixRArray
//
//
procedure TK_FrameRAEdit.GetDataToRAMatrixRArray( RAM : TK_RArray  );
var
  NCol, NRow : Integer;
begin
  NRow := GetDataBufRow;
  NCol := GetDataBufCol;
  with RAM do begin
    ASetLength( NCol, NRow );
    GetDataToRAMatrix( P^, ElemType  );
  end;
end; //*** end of function TK_FrameRAEdit.GetDataToRAMatrixRArray

//**************************************** TK_FrameRAEdit.SetDataFromRArray
//
//
function TK_FrameRAEdit.SetDataFromRArray( const Data; DDType : TK_ExprExtType;
                  StartCol : Integer = 0; ColNum : Integer = 0  ) : Integer;
var
  i, k, j, m, h : Integer;
  RPData : TN_BytesPtr;
  MDFlags : TK_MoveDataFlags;
begin

  Result := StartCol;

  if (DDType.D.TFlags and K_ffFlagsMask) <> 0 then Exit;

  if ColNum = 0 then ColNum := High(RAFCArray) - StartCol;

  if DDType.DTCode > Ord( nptNoData ) then begin
    k := High(RAFCArray) - StartCol;
  end else begin
    k := 0;
  end;

  k := Min( ColNum, k );

  Result := StartCol + k + 1;
  RPData := @Data;
  h := GetDataBufRow - 1;
  if ((DDType.EFlags.CFlags and K_ccCountUDRef) <> 0) and
     ((DDType.EFlags.CFlags and K_ccStopCountUDRef) = 0) then
    MDFlags := [K_mdfCountUDRef]
  else
    MDFlags := [];
  MDFlags := MDFlags + [K_mdfFreeDest];
  for j := 0 to h do begin
    if (DDType.D.TFlags and K_ffArray) <> 0 then
      RPData := TK_RArray(Data).P(j);
    m := StartCol;
    if not (K_ramReadOnly in CDescr.ModeFlags) then
      for i := 0 to k do begin
        with RAFCArray[m] do
        if not (K_racReadOnly in ShowEditFlags) then
          K_MoveSPLData( (RPData + FieldPos)^,
                      DataPointers[GetDataBufRow(j)][m]^,
                      CDType, MDFlags );
        Inc( m );
      end;

//*** Get Row Data Pointer
    if (DDType.D.TFlags and K_ffArray) = 0 then
      RPData := RPData + K_GetExecTypeSize( DDType.All );
  end;

end; //*** end of function TK_FrameRAEdit.SetDataFromRArray

//**************************************** TK_FrameRAEdit.GetLRowPData
//
//
procedure TK_FrameRAEdit.GetLRowPData( PData : TN_PPointer; RowNum : Integer;
                         PDataInds : PInteger = nil; IndsCount : Integer = -1 );
var
  i, h, j : Integer;
begin

  h := GetDataBufCol;
  if IndsCount >= 0 then h := IndsCount;
  for i := 0 to h - 1 do begin
    j := i;
    if PDataInds <> nil then begin
      j := PDataInds^;
      Inc(PDataInds);
    end;
    PData^ := DataPointers[RowNum][GetDataBufCol(j)];
    Inc(PData);
  end;

end; //*** end of function TK_FrameRAEdit.GetLRowPData

//**************************************** TK_FrameRAEdit.GetLColPData
//
//
procedure TK_FrameRAEdit.GetLColPData( PData : TN_PPointer; ColNum : Integer;
                         PDataInds : PInteger = nil; IndsCount : Integer = -1 );
var
  i, h, j : Integer;
begin

 h := GetDataBufRow;
  if IndsCount >= 0 then h := IndsCount;
  for i := 0 to h - 1 do begin
    j := i;
    if PDataInds <> nil then begin
      j := PDataInds^;
      Inc(PDataInds);
    end;
    PData^ := DataPointers[GetDataBufRow(j)][ColNum];
    Inc(PData);
  end;

end; //*** end of function TK_FrameRAEdit.GetLColPData

//**************************************** TK_FrameRAEdit.GetLColData
//
//
procedure TK_FrameRAEdit.GetLColData( PData : Pointer; ElemStep, ColNum : Integer );
var
  i, h : Integer;
begin

  h := GetDataBufRow - 1;
  for i := 0 to h do begin
    K_MoveSPLData( DataPointers[GetDataBufRow(i)][ColNum]^,
                PData^, RAFCArray[ColNum].CDType );
    Inc(TN_BytesPtr(PData), ElemStep);
  end;

end; //*** end of function TK_FrameRAEdit.GetLColData

//**************************************** TK_FrameRAEdit.GetDataToColumnRArrays
//
//
procedure TK_FrameRAEdit.GetDataToColumnRArrays( const Data : TK_RArray );
var
  j, n, ic : Integer;
  PCRArray : TK_PRArray;
begin

  PCRArray := @Data;
  n := GetDataBufCol - 1;
  for j := 0 to n do begin
    ic := GetDataBufCol(j);
    if not (K_racReadOnly in RAFCArray[ic].ShowEditFlags) and
       not (K_ramReadOnly in CDescr.ModeFlags) then
       GetLColData( PCRArray.P, PCRArray^.ElemSize, ic );
//*** Get Column Data Pointer
    Inc( TN_BytesPtr(PCRArray), SizeOf(Pointer) );
  end;

end; //*** end of function TK_FrameRAEdit.GetDataToColumnRArrays

//**************************************** TK_FrameRAEdit.GetPRowIndex
// get pointer to Row Buffer Index Array
//
function TK_FrameRAEdit.GetPRowIndex : PInteger;
begin
  if Length(GLRNumbers) < 2 then
    Result := nil
  else
    Result := @GLRNumbers[1];
end; //*** end of function TK_FrameRAEdit.GetPRowIndex

//**************************************** TK_FrameRAEdit.GetDataBufRow
// Convert Logic Row Number to Data Bufer Row Number
//
function TK_FrameRAEdit.GetDataBufRow( ARow : Integer = -1 ) : Integer;
begin
  if High(GLRNumbers) <= ARow then
    ARow := Arow - 1;
  if ARow < 0 then
    Result := Length(GLRNumbers) - 1
  else
    Result := GLRNumbers[ARow + 1];
end; //*** end of function TK_FrameRAEdit.GetDataBufRow

//**************************************** TK_FrameRAEdit.GetPColIndex
// get pointer to Col Buffer Index Array
//
function TK_FrameRAEdit.GetPColIndex : PInteger;
begin
  if Length(GLCNumbers) < 2 then
    Result := nil
  else
    Result := @GLCNumbers[1];
end; //*** end of function TK_FrameRAEdit.GetPColIndex

//**************************************** TK_FrameRAEdit.GetDataBufCol
// Convert Logic Col Number to Data Bufer Col Number
//
function TK_FrameRAEdit.GetDataBufCol( ACol : Integer = -1 ) : Integer;
begin
  if ACol < 0 then
    Result := Length(GLCNumbers) - 1
  else
    Result := GLCNumbers[ACol + 1];
end; //*** end of function TK_FrameRAEdit.GetDataBufCol

//**************************************** TK_FrameRAEdit.ToLogicRow
// Convert Grid Cell Row to Logic Row
//
function TK_FrameRAEdit.ToLogicRow( ARow : Integer ): Integer;
begin
//  if (Length(RowsOrder) > 0) and
//     (ARow > 0)             and
//     (ARow <= Length(RowsOrder)) then
  if (ARow > 0)             and
     (ARow <= Length(RowsOrder)) then
    ARow := RowsOrder[ARow - 1] + 1;
  if (ARow < Length(GLRNumbers))  and (ARow >=0) then
    Result := GLRNumbers[ARow]
  else if Length(GLRNumbers) = 1 then
    Result := -3
  else
    Result := -2;
end; //*** end of function TK_FrameRAEdit.ToLogicRow

//**************************************** TK_FrameRAEdit.ToLogicCol
// Convert Grid Cell Col to Logic Col
//
function TK_FrameRAEdit.ToLogicCol( ACol : Integer ): Integer;
begin
  if (Length(ColsOrder) > 0) and
     (ACol > 0)             and
     (ACol <= Length(ColsOrder)) then
    ACol := ColsOrder[ACol - 1] + 1;
  if (ACol < Length(GLCNumbers)) and (ACol >=0) then
    Result := GLCNumbers[ACol]
  else if Length(GLCNumbers) = 1 then
    Result := -3
  else
    Result := -2;
end; //*** end of function TK_FrameRAEdit.ToLogicCol

//**************************************** TK_FrameRAEdit.ToLogicPos
// Convert Grid Cell Coords to Logic Coords
//
function TK_FrameRAEdit.ToLogicPos( ACol, ARow : Integer ): TK_GridPos;
begin
  if K_ramColVertical in CDescr.ModeFlags then begin
    Result.Col := ToLogicCol( ACol );
    Result.Row := ToLogicRow( ARow );
  end else begin
    Result.Col := ToLogicCol( ARow );
    Result.Row := ToLogicRow( ACol );
  end;
end; //*** end of function TK_FrameRAEdit.ToLogicPos

//**************************************** TK_FrameRAEdit.ToGridPos
// Convert Grid Cell Coords to Logic Coords
//
function TK_FrameRAEdit.ToGridPos( ACol, ARow : Integer ): TK_GridPos;
begin
  if K_ramColVertical in CDescr.ModeFlags then
  begin
    Result.Col := ACol;
    Result.Row := ARow;
  end else begin
    Result.Col := ARow;
    Result.Row := ACol;
  end;
end; //*** end of function TK_FrameRAEdit.ToGridPos

//**************************************** TK_FrameRAEdit.NextSearchCol
// Search for Next Search Column
//
function TK_FrameRAEdit.NextSearchCol : Boolean;
var
  CLPos : TK_GridPos;
begin
  Result := false;
  repeat
    if K_ramColVertical in CDescr.ModeFlags then begin
      Inc(SearchPos.Col);
      if SearchPos.Col > SearchArea.Right then Exit;
    end else begin
      Inc(SearchPos.Row);
      if SearchPos.Row > SearchArea.Bottom then Exit;
    end;
    CLPos := ToLogicPos( SearchPos.Col, SearchPos.Row );
  until SGridColExtEditMode( CLPos.Col, CLPos.Row, false );
  Result := true;
end; //*** end of function TK_FrameRAEdit.NextSearchCol

//**************************************** TK_FrameRAEdit.SetSearchContext
// Set search context
//
function TK_FrameRAEdit.SetSearchContext( ASearchFlags : TK_RAFrameSearchFlags;
      AContext : string;
      ALCol : Integer = 1; ATRow : Integer = -1;
      ARCol : Integer = 1; ABRow : Integer = -1 ) : TGridRect;
begin
  SearchArea := GetRect( ALCol, ATRow, ARCol, ABRow );
  SearchArea.Top := Max( SearchArea.Top, 1 );
  SearchArea.Left := Max( SearchArea.Left, 1 );
  SearchPos.Row := SearchArea.Top - 1;
  SearchPos.Col := SearchArea.Left - 1;
  Result := SearchArea;
  NextSearchCol;
  SearchContext := AContext;
  SearchFlags   := ASearchFlags;

end; //*** end of procedure TK_FrameRAEdit.SetSearchContext

//**************************************** TK_FrameRAEdit.NextSearch
// continue seach
//
function  TK_FrameRAEdit.NextSearch( out ACol, ARow : Integer ) : Boolean;
var
  WStr, SStr : string;

  function NextPos : Boolean;
  begin
    Result := true;
    if K_ramColVertical in CDescr.ModeFlags then begin
      Inc(SearchPos.Row);
      if SearchPos.Row > SearchArea.Bottom then begin
        Result := false;
        SearchPos.Row := SearchArea.Top;
      end;
    end else begin
      Inc(SearchPos.Col);
      if SearchPos.Col > SearchArea.Right then begin
        Result := false;
        SearchPos.Col := SearchArea.Left;
      end;
    end;
  end;

begin
  Result := false;
  if not (K_sgfCaseSensitive in SearchFlags) then
    WStr := AnsiUpperCase(SearchContext)
  else
    WStr := SearchContext;
  while not Result do begin
//*** Step to next Cell
    if not NextPos then begin
      if not NextSearchCol then Exit;
    end;
//*** Check Current Cell
    SGridGetEditText( nil, SearchPos.Col, SearchPos.Row, SStr );
//    SStr := SGrid.Cells[SearchPos.Col, SearchPos.Row];
    if not (K_sgfCaseSensitive in SearchFlags) then
      SStr := AnsiUpperCase( SStr );
    if K_sgfUseCell in SearchFlags then begin
      Result := ( WStr = SStr );
      SearchCellPos := 1;
    end else begin
      SearchCellPos := Pos(WStr,  SStr);
      Result := ( SearchCellPos <> 0 );
    end;
  end;

  ACol := SearchPos.Col;
  ARoW := SearchPos.Row;

end; //*** end of procedure TK_FrameRAEdit.NextSearch

//**************************************** TK_FrameRAEdit.ReplaceSearchResult
// Set search context
//
procedure TK_FrameRAEdit.ReplaceSearchResult( NewValue : string );
var
  SStr : string;
  RightLength : Integer;
  CLPos : TK_GridPos;
begin
  CLPos := ToLogicPos( SearchPos.Col, SearchPos.Row );
  if not SGridColExtEditMode( CLPos.Col, CLPos.Row, true ) then Exit;
  SGridGetEditText( nil, SearchPos.Col, SearchPos.Row, SStr );
  if K_sgfUseCell in SearchFlags then
    SStr := NewValue
  else begin
    RightLength := Length(SStr) - SearchCellPos - Length(SearchContext) + 1;
    SStr := LeftStr( SStr, SearchCellPos - 1 ) + NewValue + RightStr( SStr, RightLength );
  end;
  SGridSetEditText( nil, SearchPos.Col, SearchPos.Row, SStr );
end; //*** end of procedure TK_FrameRAEdit.ReplaceSearchResult

//**************************************** TK_FrameRAEdit.RCMove
// Move Grid Column
//
procedure TK_FrameRAEdit.RCMove( Arr : TN_IArray; FromIndex, ToIndex: Integer);
var Leng, WInd : Integer;

  procedure DMove(  ); // FromIndex > ToIndex
  begin
    WInd := Arr[FromIndex];
    move( Arr[ToIndex], Arr[ToIndex+1], Leng );
    Arr[ToIndex] := WInd;
  end;

  procedure BMove(  ); // FromIndex < ToIndex
  begin
    WInd := Arr[FromIndex];
    move( Arr[FromIndex+1], Arr[FromIndex], Leng );
    Arr[ToIndex] := WInd;
  end;

begin
  Leng := Abs( FromIndex - ToIndex ) * SizeOf(Integer);
  if FromIndex < ToIndex  then
    BMove(  )
  else
    DMove(  );
end; //*** end of procedure TK_FrameRAEdit.RCMove

//**************************************** TK_FrameRAEdit.ShowHideExtEditButton
// Show/Hide External Edit Button
//
function  TK_FrameRAEdit.ShowHideExtEditButton( ACol, ARow: Integer;
                                        const RAFC : TK_RAFColumn ) : Boolean;
var
  GRect : TRect;
begin

  with BtExtEditor_1 do begin
    if (K_racExternalEditor in RAFC.ShowEditFlags) and
       (K_racShowExtEditButton in RAFC.ShowEditFlags) then begin
      GRect := SGrid.CellRect(ACol, ARow);
      Top := Self.Top + 1 + Round((GRect.top + GRect.bottom - BtExtEditor_1.Height)/2);
      Left := GRect.Right - Width;
      Visible := true;
      Result := true;
    end else begin
      Result := false;
      Visible := false;
    end;
  end;
end; //*** end of procedure TK_FrameRAEdit.ShowHideExtEditButton

//**************************************** TK_FrameRAEdit.PlaceExtControl
// Place External Control
//
procedure TK_FrameRAEdit.PlaceExtControl( ACol, ARow: Integer; ExtControl : TControl );
var
  GRect : TRect;
begin
  with ExtControl do begin
    GRect := SGrid.CellRect(ACol, ARow);
    Top := GRect.top + 2;
    Left := GRect.Left + 3;
    Width := GRect.Right - GRect.Left;
    Visible := true;
    Enabled := true;
  end;
end; //*** end of procedure TK_FrameRAEdit.PlaceExtControl

//**************************************** TK_FrameRAEdit.GetSelfHeight
// Calculate Self Height
//
function TK_FrameRAEdit.GetSelfHeight: Integer;
var
  i : Integer;
  WCount : Integer;
begin
  Result := 4;
  with SGrid do begin
    if not GetFullFrameSize                                 and
       (K_ramShowSingleRecord in CDescr.ModeFlags) and
       (K_ramColVertical in CDescr.ModeFlags) then
      WCount := 1
    else
      WCount := RowCount - 1;
    for i := 0 to WCount do
      Result := Result + RowHeights[i] + 1;
  end;
  GetFullFrameSize := false;
end; //*** end of function TK_FrameRAEdit.GetSelfHeight

//**************************************** TK_FrameRAEdit.GetSelfWidth
// Calculate Self Width
//
function TK_FrameRAEdit.GetSelfWidth: Integer;
var
  i : Integer;
  WCount : Integer;
begin
  Result := 3;
  with SGrid do begin
    if not GetFullFrameSize                                 and
       (K_ramShowSingleRecord in CDescr.ModeFlags) and
       not (K_ramColVertical in CDescr.ModeFlags) then
      WCount := 1
    else
      WCount := ColCount - 1;
    for i := 0 to WCount do
      Result := Result + ColWidths[i] + 1;
  end;
  GetFullFrameSize := false;
end; //*** end of function TK_FrameRAEdit.GetSelfWidth

//**************************************** TK_FrameRAEdit.SetLastColumnWidth
// Set last column width
//
procedure TK_FrameRAEdit.SetLastColumnWidth;
var
  i, N1, NCol, j, ri : Integer;
  MDWidth : Integer;
  DWidth : Integer;
  CWidth : Integer;
//  Str : string;

begin
//  if SkipSetLastColumnWidth then Exit;
  CWidth := SelfWidth;
  DWidth := CWidth - Self.ClientWidth;
  with SGrid do
{
    if K_ramFillFrameWidth in CDescr.ModeFlags then begin
}
    if (K_ramFillFrameWidth in CDescr.ModeFlags) and
       ( (CDescr.ColResizeMode <> K_crmNormal) or
         (DWidth < 0)   or
         (ColCount = 2) or
         ( (DWidth > 0) and
           (DWidth <= (ColWidths[ColCount-1] - Width) ) ) ) then begin
      GetFullFrameSize := true;
      if SelfHeight > Height then Inc(CWidth, 17); // reserve space for ScrollBar
      DWidth := Self.ClientWidth - CWidth;
      if DWidth = 0 then Exit;
      if DWidth < 0 then begin
        if ((CDescr.ColResizeMode = K_crmCompact) or (ColCount = 2)) and
           ( 0 < ColWidths[ColCount-1] - Max(CDescr.MinCWidth, CDescr.DSeparatorSize) + DWidth) then
          ColWidths[ColCount-1] := ColWidths[ColCount-1] + DWidth
      end else begin
        if (K_ramShowSingleRecord in CDescr.ModeFlags) and
           not (K_ramColVertical in CDescr.ModeFlags) then begin
          for i := 1 to ColCount - 1 do
            ColWidths[i] := ColWidths[i] + DWidth;
        end else begin
          NCol := ColCount - 1;
          if (K_ramColVertical in CDescr.ModeFlags) then
            for i := 1 to High(GLCNumbers) do
              if (K_racSeparator in RAFCArray[GLCNumbers[i]].ShowEditFlags) then  Dec(NCol);

          MDWidth := 0;
          N1 := 0;
          if NCol <> 0 then begin
            MDWidth := Floor( DWidth/NCol );
            N1 := DWidth - MDWidth * NCol;
          end;
{
          Str := 'ClientWidth='+IntToStr(Self.ClientWidth)+',Width='+IntToStr(SelfWidth)+
                 ',CWidth='+IntToStr(CWidth)+',DWidth='+IntToStr(DWidth)+
                 ',MDWidth='+IntToStr(MDWidth)+',N1='+IntToStr(N1);
          K_InfoWatch.AddInfoLine(Str);
          Str := '';
          for i := 0 to ColCount-1 do
            Str := Str + ' ['+IntToStr(i)+']='+IntToStr(ColWidths[i]);
          K_InfoWatch.AddInfoLine( Str );
}
          if (MDWidth <> 0) or (N1 <> 0) then begin
            ri := 1;
            j := 0;
            for i := 1 to ColCount - 1 do begin
              if ri > N1 then break;
              j := i;
              if (K_ramColVertical in CDescr.ModeFlags) and
                 (K_racSeparator in RAFCArray[GLCNumbers[i]].ShowEditFlags) then Continue;
              ColWidths[i] := ColWidths[i] + MDWidth + 1;
              Inc( ri );
            end;

            if MDWidth <> 0 then
              for i := j + 1 to ColCount-1 do
                if not (K_ramColVertical in CDescr.ModeFlags) or
                   ( (i < Length(GLCNumbers)) and
                     not (K_racSeparator in RAFCArray[GLCNumbers[i]].ShowEditFlags) ) then
                  ColWidths[i] := ColWidths[i] + MDWidth;
          end;
        end;
      end;
    end;
end; //*** end of procedure  TK_FrameRAEdit.SetLastColumnWidth

//**************************************** TK_FrameRAEdit.GetCellEnableState
// Get Cell Enable State
//
function TK_FrameRAEdit.GetCellEnableState( ALCol, ALRow: Integer ) : TK_RAFDisabled;
begin
  if K_ramCDisabled in CDescr.ModeFlags then begin
    Result := K_rfdAllDisabled;
  end else begin
    if (ALCol >= 0) and (K_racCDisabled in RAFCArray[ALCol].ShowEditFlags) then
      Result := K_rfdColDisabled
    else
      Result := K_rfdEnabled;

    if Assigned(OnCellCheckDisable) then
      OnCellCheckDisable( Result, ALCol, ALRow );
  end;
end; //*** end of function TK_FrameRAEdit.GetCellEnableState

//*********************************
//**************** Event Handlers
//*********************************

//**************************************** TK_FrameRAEdit.SGridDrawCell
//
procedure TK_FrameRAEdit.SGridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  LPos : TK_GridPos;
//  GPos : TK_GridPos;
//  CEVN : Integer;
  RAFViewer : TK_RAFViewer;
  PData : Pointer;
  CellPos : TK_CellPos;
  wstr : string;
  CColorInd, CRowNum, RCInd, RNum, CNum : Integer;
  SelectedDraw : Boolean;
  FontColor : TColor;
  DisabledDraw : TK_RAFDisabled;
  FS : TFontStyles;
  BS : TBrushStyle;
  PRAFColumn : TK_PRAFColumn;

  procedure MarkHeaderCell;
{
  var

    BrushSave : TBrushRecall;
    PenSave   : TPenRecall;
    x1, y1, x2, y2 : Integer;
}
  begin
    SGrid.Canvas.Brush.Color := clAppWorkSpace;
    FS := [fsUnderline];

{
    BrushSave := TBrushRecall.Create( SGrid.Canvas.Brush );
    SGrid.Canvas.Brush.Color := clBlack;
    PenSave := TPenRecall.Create( SGrid.Canvas.Pen );
    SGrid.Canvas.Pen.Width := 1;
    SGrid.Canvas.Pen.Color := clBlack;
    x1 := Rect.Left;
    y1 := Rect.Top;
    x2 := x1 + 10;
    y2 := y1 + 10;
    SGrid.Canvas.MoveTo(x1, y1);
    SGrid.Canvas.LineTo(x2, y1);
    SGrid.Canvas.LineTo(x1, y2);
    SGrid.Canvas.LineTo(x1, y1);
    SGrid.Canvas.FloodFill(x1+1, y1+1, clBlack, fsBorder);
    BrushSave.Free;
    PenSave.Free;
}
  end;

begin
  ResizeBeforeFirstShowMode := false;
  LPos := ToLogicPos( ACol, ARow );
  PRAFColumn := nil;
  if LPos.Col >= 0 then
    PRAFColumn := @RAFCArray[LPos.Col];
  with PRAFColumn^ do begin
    if (LPos.Col >= 0) and
       (K_racSeparator in ShowEditFlags) then begin
      if not (K_ramColVertical in CDescr.ModeFlags) then begin
        Rect.Left := 0;
        Rect.Right := SGrid.ClientRect.Right
      end else begin
        Rect.Top := 0;
        Rect.Bottom := SGrid.ClientRect.Bottom;
      end;
      DrawFrameControl( SGrid.Canvas.Handle, Rect, 0, 0 );
      if not (K_ramColVertical in CDescr.ModeFlags) and
        (Caption <> '') then begin
        BS := SGrid.Canvas.Brush.Style;
        SGrid.Canvas.Brush.Style := bsClear;
        K_CellDrawString( Caption, Rect, K_ppCenter, K_ppCenter, SGrid.Canvas, LRPadding, 0, 0 );
        SGrid.Canvas.Brush.Style := BS;
      end;
      Exit;
    end;

//    SGrid.Canvas.FillRect(Rect);
    if (ARow = 0) or (ACol = 0) then
    begin//*** Grid Headers
      CellPos := K_ppUpLeft;
      Byte(FS) := $FF;
      if (ARow = 0) and (ACol = 0) then
        wstr := SGrid.Cells[0, 0]
      else if (LPos.Col = -1) and (LPos.Row >= 0) then
      begin
      //*** Row Caption
        if K_ramShowLRowNumbers in CDescr.ModeFlags then
        begin
          if K_ramColVertical in CDescr.ModeFlags then
            RNum := ARow
          else
            RNum := ACol;
          wstr := format(RNumFormat, [RNum - 1]);
        end;
        wstr := wstr + RowCaptions[LPos.Row];
        if RowMarks[LPos.Row] then
          MarkHeaderCell;
      end else if LPos.Col >= 0 then
      begin
      //*** Col Caption
        if K_ramShowLColNumbers in CDescr.ModeFlags then  begin
          if K_ramColVertical in CDescr.ModeFlags then
            CNum := ACol
          else
            CNum := ARow;
          wstr := format(CNumFormat, [CNum - 1]);
        end;
        wstr := wstr + Caption;
        if Marked then
          MarkHeaderCell;
{
        if Marked then begin
//          wstr := '*' + ' ' +wstr;
//**          wstr := '*'+wstr;
//**            FS := [fsBold];
          SGrid.Canvas.Brush.Color := clAppWorkSpace;
        end else
          FS := [];
}
      end else
        Exit;

      if (ACol > 0) and
         (SGrid.Canvas.TextWidth(wstr) < SGrid.ColWidths[ACol]) then
        CellPos := K_ppCenter;

      DisabledDraw := GetCellEnableState( LPos.Col, LPos.Row );

      FontColor := -1;
      if ( (LPos.Col >= 0) and
           ( (DisabledDraw = K_rfdColDisabled) or
             (DisabledDraw = K_rfdAllDisabled) ) ) or
         ( (LPos.Row >= 0) and
           ( (DisabledDraw = K_rfdRowDisabled) or
             (DisabledDraw = K_rfdAllDisabled) ) ) then begin
        if (CDescr.DisFontColor <> -1) then
          FontColor := CDescr.DisFontColor
        else
          FontColor := clGrayText;
      end;
      K_CellDrawString( wstr, Rect, CellPos, K_ppCenter, SGrid.Canvas, LRPadding, FontColor, Byte(FS) );

    end else begin
      if (LPos.Row < 0) or (LPos.Col < 0) then Exit;

      if DefaultTEdit.Visible then
        PlaceExtControl(CurGPos.Col, CurGPos.Row, DefaultTEdit);

      SelectedDraw := (gdSelected in State);

      if DataPointers = nil then
        PData := nil
      else
        PData := DataPointers[LPos.Row][LPos.Col];

      RAFViewer := GetCellViewer( LPos.Col, LPos.Row );
{
      RAFViewer := nil;
      if VEArray <> nil then // to avoid exception while add new column
        RAFViewer := VEArray[CViewerInd].VObj;

      if not Assigned(RAFViewer) or
         not RAFViewer.IfUseViewer( LPos.Col, LPos.Row, RAFCArray[LPos.Col] ) then
        RAFViewer := DefaultRAFViewer;
}
      DisabledDraw := GetCellEnableState( LPos.Col, LPos.Row );

  //********** Cell Color Definition
      CFontColor := -1;
      CFillColor := -1;
      if DisabledDraw <> K_rfdEnabled then begin
        if (CDescr.DisFontColor <> -1) then
          CFontColor := CDescr.DisFontColor
        else
          CFontColor := clGrayText;
        if (CDescr.DisFillColor <> -1) then
          CFillColor := CDescr.DisFillColor
        else
          CFillColor := ColorToRGB( SGrid.Canvas.Brush.Color );
      end else begin
        if not SelectedDraw then begin
          if (K_ramUseFillColor in CDescr.ModeFlags) or
             (K_racUseFillColor in ShowEditFlags) then begin
            CColorInd := -1;
            if PColColorIndsMatrix <> nil then begin
            //*** Use Individual Field Color Index
              CColorInd := PInteger(PColColorIndsMatrix +
                             ((MaxRowNum * LPos.Col + LPos.Row) shl 2))^;
//                             ((MaxColNum * LPos.Row + LPos.Col) shl 2))^;
            end;
            if (CColorInd = -1) or
               (K_racUseFDFillColor in ShowEditFlags) then CColorInd := CFillColorInd;
            if (K_racUseRowFillColor in ShowEditFlags) then begin
              RCInd := 0;
              if (K_ramUseEvenOddColors in CDescr.ModeFlags) then begin
              //*** Use Even/Odd Row Color Indexes
                if (K_ramUsePhysRowNumberColors in CDescr.ModeFlags) then
                  CRowNum := ARow      //*** Use phis  Row Number
                else
                  CRowNum := LPos.Row; //*** Use logic Row Number
                if (CRowNum and 1) = 1 then
                  RCInd := CDescr.RowColorInd1
                else
                  RCInd := CDescr.RowColorInd2;
              end else begin
              //*** Use Individual Row Color Indexes
                if PRowColorInds <> nil then
                  RCInd := PInteger(PRowColorInds + (LPos.Row shl 2))^;
              end;
              if RCInd = -1 then RCInd := 0;
              if (K_racUseMixFillColor in ShowEditFlags) and
                 (PMixPaletteMatrix <> nil) then begin
              //*** Use Mixed Colors Palette
                RCInd := ColPalLength * RCInd + CColorInd;
                CFillColor := PInteger( PMixPaletteMatrix + (RCInd shl 2) )^;
              end else if PRowPalette <> nil then begin
              //*** Use Row Colors Palette
                CFillColor := PInteger( PRowPalette + (RCInd shl 2) )^;
              end;
            end else begin
              if (K_racNotUsePalette in ShowEditFlags) or
                 (K_ramNotUsePalette in CDescr.ModeFlags) then
                CFillColor := CColorInd
              else if PColPalette <> nil then
                CFillColor := PInteger( PColPalette + (CColorInd shl 2) )^
              else
                CFillColor := $FFFFFF;
            end;
          end;
        end else begin
          if (CDescr.SelFontColor <> -1) then
            CFontColor := CDescr.SelFontColor;
          if (CDescr.SelFillColor <> -1) then
            CFillColor := CDescr.SelFillColor;
        end;
      end;
  //********** end of Cell Color Definition

      RAFViewer.DrawCell( PData^, RAFCArray[LPos.Col], ACol, ARow, Rect, State, SGrid.Canvas );

    end;
  end;
end; // end of TK_FrameRAEdit.SGridDrawCell

//!! previous version - error in Delphi 2010

//**************************************** TK_FrameRAEdit.SGridDrawCell
//
procedure TK_FrameRAEdit.SGridDrawCell0(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  LPos : TK_GridPos;
//  GPos : TK_GridPos;
//  CEVN : Integer;
  RAFViewer : TK_RAFViewer;
  PData : Pointer;
  CellPos : TK_CellPos;
  wstr : string;
  CColorInd, CRowNum, RCInd, RNum, CNum : Integer;
  SelectedDraw : Boolean;
  FontColor : TColor;
  DisabledDraw : TK_RAFDisabled;
  FS : TFontStyles;
  BS : TBrushStyle;

  procedure MarkHeaderCell;
{
  var

    BrushSave : TBrushRecall;
    PenSave   : TPenRecall;
    x1, y1, x2, y2 : Integer;
}
  begin
    SGrid.Canvas.Brush.Color := clAppWorkSpace;
    FS := [fsUnderline];

{
    BrushSave := TBrushRecall.Create( SGrid.Canvas.Brush );
    SGrid.Canvas.Brush.Color := clBlack;
    PenSave := TPenRecall.Create( SGrid.Canvas.Pen );
    SGrid.Canvas.Pen.Width := 1;
    SGrid.Canvas.Pen.Color := clBlack;
    x1 := Rect.Left;
    y1 := Rect.Top;
    x2 := x1 + 10;
    y2 := y1 + 10;
    SGrid.Canvas.MoveTo(x1, y1);
    SGrid.Canvas.LineTo(x2, y1);
    SGrid.Canvas.LineTo(x1, y2);
    SGrid.Canvas.LineTo(x1, y1);
    SGrid.Canvas.FloodFill(x1+1, y1+1, clBlack, fsBorder);
    BrushSave.Free;
    PenSave.Free;
}
  end;

begin
  ResizeBeforeFirstShowMode := false;
  LPos := ToLogicPos( ACol, ARow );
  with RAFCArray[LPos.Col] do begin
    if (LPos.Col >= 0) and
       (K_racSeparator in ShowEditFlags) then begin
      if not (K_ramColVertical in CDescr.ModeFlags) then begin
        Rect.Left := 0;
        Rect.Right := SGrid.ClientRect.Right
      end else begin
        Rect.Top := 0;
        Rect.Bottom := SGrid.ClientRect.Bottom;
      end;
      DrawFrameControl( SGrid.Canvas.Handle, Rect, 0, 0 );
      if not (K_ramColVertical in CDescr.ModeFlags) and
        (Caption <> '') then begin
        BS := SGrid.Canvas.Brush.Style;
        SGrid.Canvas.Brush.Style := bsClear;
        K_CellDrawString( Caption, Rect, K_ppCenter, K_ppCenter, SGrid.Canvas, LRPadding, 0, 0 );
        SGrid.Canvas.Brush.Style := BS;
      end;
      Exit;
    end;

//    SGrid.Canvas.FillRect(Rect);
    if (ARow = 0) or (ACol = 0) then begin//*** Grid Headers
      CellPos := K_ppUpLeft;
      Byte(FS) := $FF;
      if (ARow = 0) and (ACol = 0) then
        wstr := SGrid.Cells[0, 0]
      else if (LPos.Col = -1) and (LPos.Row >= 0) then
      begin
      //*** Row Caption
        if K_ramShowLRowNumbers in CDescr.ModeFlags then
        begin
          if K_ramColVertical in CDescr.ModeFlags then
            RNum := ARow
          else
            RNum := ACol;
          wstr := format(RNumFormat, [RNum - 1]);
        end;
        wstr := wstr + RowCaptions[LPos.Row];
        if RowMarks[LPos.Row] then
          MarkHeaderCell;
      end else if LPos.Col >= 0 then
      begin
      //*** Col Caption
        if K_ramShowLColNumbers in CDescr.ModeFlags then  begin
          if K_ramColVertical in CDescr.ModeFlags then
            CNum := ACol
          else
            CNum := ARow;
          wstr := format(CNumFormat, [CNum - 1]);
        end;
        wstr := wstr + Caption;
        if Marked then
          MarkHeaderCell;
{
        if Marked then begin
//          wstr := '*' + ' ' +wstr;
//**          wstr := '*'+wstr;
//**            FS := [fsBold];
          SGrid.Canvas.Brush.Color := clAppWorkSpace;
        end else
          FS := [];
}
      end else
        Exit;

      if (ACol > 0) and
         (SGrid.Canvas.TextWidth(wstr) < SGrid.ColWidths[ACol]) then
        CellPos := K_ppCenter;

      DisabledDraw := GetCellEnableState( LPos.Col, LPos.Row );

      FontColor := -1;
      if ( (LPos.Col >= 0) and
           ( (DisabledDraw = K_rfdColDisabled) or
             (DisabledDraw = K_rfdAllDisabled) ) ) or
         ( (LPos.Row >= 0) and
           ( (DisabledDraw = K_rfdRowDisabled) or
             (DisabledDraw = K_rfdAllDisabled) ) ) then begin
        if (CDescr.DisFontColor <> -1) then
          FontColor := CDescr.DisFontColor
        else
          FontColor := clGrayText;
      end;
      K_CellDrawString( wstr, Rect, CellPos, K_ppCenter, SGrid.Canvas, LRPadding, FontColor, Byte(FS) );

    end else begin
      if (LPos.Row < 0) or (LPos.Col < 0) then Exit;

      if DefaultTEdit.Visible then
        PlaceExtControl(CurGPos.Col, CurGPos.Row, DefaultTEdit);

      SelectedDraw := (gdSelected in State);

      if DataPointers = nil then
        PData := nil
      else
        PData := DataPointers[LPos.Row][LPos.Col];

      RAFViewer := GetCellViewer( LPos.Col, LPos.Row );
{
      RAFViewer := nil;
      if VEArray <> nil then // to avoid exception while add new column
        RAFViewer := VEArray[CViewerInd].VObj;

      if not Assigned(RAFViewer) or
         not RAFViewer.IfUseViewer( LPos.Col, LPos.Row, RAFCArray[LPos.Col] ) then
        RAFViewer := DefaultRAFViewer;
}
      DisabledDraw := GetCellEnableState( LPos.Col, LPos.Row );

  //********** Cell Color Definition
      CFontColor := -1;
      CFillColor := -1;
      if DisabledDraw <> K_rfdEnabled then begin
        if (CDescr.DisFontColor <> -1) then
          CFontColor := CDescr.DisFontColor
        else
          CFontColor := clGrayText;
        if (CDescr.DisFillColor <> -1) then
          CFillColor := CDescr.DisFillColor
        else
          CFillColor := ColorToRGB( SGrid.Canvas.Brush.Color );
      end else begin
        if not SelectedDraw then begin
          if (K_ramUseFillColor in CDescr.ModeFlags) or
             (K_racUseFillColor in ShowEditFlags) then begin
            CColorInd := -1;
            if PColColorIndsMatrix <> nil then begin
            //*** Use Individual Field Color Index
              CColorInd := PInteger(PColColorIndsMatrix +
                             ((MaxRowNum * LPos.Col + LPos.Row) shl 2))^;
//                             ((MaxColNum * LPos.Row + LPos.Col) shl 2))^;
            end;
            if (CColorInd = -1) or
               (K_racUseFDFillColor in ShowEditFlags) then CColorInd := CFillColorInd;
            if (K_racUseRowFillColor in ShowEditFlags) then begin
              RCInd := 0;
              if (K_ramUseEvenOddColors in CDescr.ModeFlags) then begin
              //*** Use Even/Odd Row Color Indexes
                if (K_ramUsePhysRowNumberColors in CDescr.ModeFlags) then
                  CRowNum := ARow      //*** Use phis  Row Number
                else
                  CRowNum := LPos.Row; //*** Use logic Row Number
                if (CRowNum and 1) = 1 then
                  RCInd := CDescr.RowColorInd1
                else
                  RCInd := CDescr.RowColorInd2;
              end else begin
              //*** Use Individual Row Color Indexes
                if PRowColorInds <> nil then
                  RCInd := PInteger(PRowColorInds + (LPos.Row shl 2))^;
              end;
              if RCInd = -1 then RCInd := 0;
              if (K_racUseMixFillColor in ShowEditFlags) and
                 (PMixPaletteMatrix <> nil) then begin
              //*** Use Mixed Colors Palette
                RCInd := ColPalLength * RCInd + CColorInd;
                CFillColor := PInteger( PMixPaletteMatrix + (RCInd shl 2) )^;
              end else if PRowPalette <> nil then begin
              //*** Use Row Colors Palette
                CFillColor := PInteger( PRowPalette + (RCInd shl 2) )^;
              end;
            end else begin
              if (K_racNotUsePalette in ShowEditFlags) or
                 (K_ramNotUsePalette in CDescr.ModeFlags) then
                CFillColor := CColorInd
              else if PColPalette <> nil then
                CFillColor := PInteger( PColPalette + (CColorInd shl 2) )^
              else
                CFillColor := $FFFFFF;
            end;
          end;
        end else begin
          if (CDescr.SelFontColor <> -1) then
            CFontColor := CDescr.SelFontColor;
          if (CDescr.SelFillColor <> -1) then
            CFillColor := CDescr.SelFillColor;
        end;
      end;
  //********** end of Cell Color Definition

      RAFViewer.DrawCell( PData^, RAFCArray[LPos.Col], ACol, ARow, Rect, State, SGrid.Canvas );

    end;
  end;
end; // end of TK_FrameRAEdit.SGridDrawCell

//**************************************** TK_FrameRAEdit.SGridSelectCell
//
procedure TK_FrameRAEdit.SGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  SetCurLPos( ACol, ARow );
  CanSelect := false;

  CellWasSelected := false;

  if (CurLPos.Col < 0) or (CurLPos.Row < 0) then Exit;

  CanSelect := true;
  if Assigned(OnCellSelecting) then
    OnCellSelecting(CanSelect);
  if not CanSelect then Exit;
//  SGridCheckEditMode;
  with RAFCArray[CurLPos.Col] do
    RenameCol.Enabled := K_racFieldRenameEnable in ShowEditFlags;

  CellWasSelected := true;

end; // end of TK_FrameRAEdit.SGridSelectCell

//**************************************** TK_FrameRAEdit.GetExtEdit
//
function TK_FrameRAEdit.GetExtEdit( NCol, NRow : Integer ) : TK_RAFEditor;
begin
  with RAFCArray[NCol] do begin
    if FixCurEditorInd = -1 then begin
      CVEInd := 0;
      if ssShift in CurShift then
        CVEInd := CVEInd + 1;
      if ssCtrl in CurShift then
        CVEInd := CVEInd + 2;
    end else
      CVEInd := FixCurEditorInd;
    if (CVEInd >= 100) and ((CVEInd - 100) <= High(CurFieldRAFEditors)) then begin
      Result := TK_RAFEditor(CurFieldRAFEditors[CVEInd - 100]);
    end else if CVEInd > High(VEArray) then begin
      Result := nil;
      CVEInd := High(VEArray);
    end else
      Result := VEArray[CVEInd].EObj;

    if not Assigned(Result) then begin
      if (K_racExternalEditor in ShowEditFlags) then
        Result := DefaultRAFEditor;
    end else if (Integer(Result) > 10) and
                 not Result.CanUseEditor( NCol, NRow, RAFCArray[NCol] ) then
      Result := nil;
  end;

end; // end of TK_FrameRAEdit.GetExtEdit

//**************************************** TK_FrameRAEdit.SetCurLPos
//
procedure TK_FrameRAEdit.SetCurLPos( ACol, ARow: Integer );
var
  WP : TK_GridPos;
  ColWasChanged : Boolean;
  RowWasChanged : Boolean;
begin
  WP := CurLPos;
  CurLPos := ToLogicPos( ACol, ARow );

  ColWasChanged := WP.Col <> CurLPos.Col;
  if ColWasChanged and
     Assigned( OnLColChange ) then OnLColChange;

  RowWasChanged := WP.Row <> CurLPos.Row;
  if RowWasChanged and
     Assigned( OnLRowChange ) then OnLRowChange;
  CurGPos.Col := ACol;
  CurGPos.Row := ARow;

// Col Rebuild Grid in compact mode

  with CDescr do
    if (K_ramAutoEnlargeSelectedCol in ModeFlags) and
       (ColResizeMode <> K_crmNormal)             and
       ( ((CurGPos.Col = 0) {and (CurGPos.Row = 0)})
                      or
         ((K_ramColVertical in ModeFlags) and ColWasChanged)
                      or
         (not (K_ramColVertical in ModeFlags) and RowWasChanged) ) then begin
      WP := CurLPos;
      RebuildGridInfo( );
      CurLPos := WP;
    end;

end; // end of TK_FrameRAEdit.SetCurLPos

//**************************************** TK_FrameRAEdit.ScrollToLPos
//
procedure TK_FrameRAEdit.ScrollToLPos( ALCol, ALRow: Integer );
var
  WP : TK_GridPos;
begin
  WP := ToGridPos( ALCol, ALRow );
  WP.Row := Min( High(GLRNumbers), WP.Row );
  WP.Col := Min( High(GLCNumbers), WP.Col );
  WP := ToGridPos( WP.Col, WP.Row );
  if WP.Row > 0 then begin
    SGrid.Row := WP.Row;
  end;
  if WP.Col > 0 then begin
    SGrid.Col := WP.Col;
  end;
end; // end of TK_FrameRAEdit.ScrollToLPos

//**************************************** TK_FrameRAEdit.ScrollToLRowPos
//
procedure TK_FrameRAEdit.ScrollToLRowPos( NCol, NRow : Integer );
begin
  NCol := Max( 1, NCol );
  NRow := Max( 1, NRow );
  if K_ramColVertical in CDescr.ModeFlags then begin
    NCol := -1;
  end else begin
    NRow := -1;
  end;
  ScrollToLPos( NCol, NRow );
end; // end of TK_FrameRAEdit.ScrollToLRowPos

//**************************************** TK_FrameRAEdit.SGridColExtEditMode
//
function TK_FrameRAEdit.SGridColExtEditMode( LPosCol, LPosRow : Integer;
                                 CheckReadOnly : Boolean ) : Boolean;
var
  CellDisabled : TK_RAFDisabled;
begin

    with RAFCArray[LPosCol] do begin
      CellDisabled := GetCellEnableState( LPosCol, LPosRow );
{!!! Some data edit action are blocked may be because of K_racExternalEditor in ShowEditFlags
      if ( not CheckReadOnly                    or
           not (K_racReadOnly in ShowEditFlags) )               and
           not (K_ramReadOnly in CDescr.ModeFlags)              and
         (CellDisabled = K_rfdEnabled)                          and
         (
           ( ([K_racExternalEditor,K_racShowCheckBox] * ShowEditFlags = []) and
             (GetExtEdit(LPosCol, LPosRow) = nil)                           and
             not (RAFCArray[LPosCol].CDType.All = Ord(nptUDRef)) )                  or
           N_KeyIsDown(VK_MENU)
         ) then
}

      if ( not CheckReadOnly                    or
           not (K_racReadOnly in ShowEditFlags) )               and
           not (K_ramReadOnly in CDescr.ModeFlags)              and
         (CellDisabled = K_rfdEnabled)  then
        Result := true
      else
        Result := false;
    end;
end; // end of TK_FrameRAEdit.SGridColExtEditMode

{
//**************************************** TK_FrameRAEdit.SGridCheckEditMode
//
procedure TK_FrameRAEdit.SGridCheckEditMode(  );
var
  TGO : TGridOptions;
begin
  TGO := SGrid.Options;
  if (CurLPos.Col >= 0) and (CurLPos.Row >= 0) then
    if SGridColExtEditMode( CurLPos.Col, CurLPos.Row, true ) then
      Include(TGO, goEditing)
    else
      Exclude(TGO, goEditing);
  SGrid.Options := TGO;
end; // end of TK_FrameRAEdit.SGridCheckEditMode
}

//**************************************** TK_FrameRAEdit.GetEditMask
//
function TK_FrameRAEdit.GetEditMask: string;
begin
{
  with RAFCArray[CurLCol] do begin
    if ( CDType.DTCode = Ord(nptHex) ) or
       ( (CDType.D.TFlags and (K_ffFlagsMask)) <> 0 ) then
      Result := '$aaaaaaaa;1;_'
    else if ( CDType.DTCode = Ord(nptColor) ) then
      Result := '$AAAAAA;1;_'
    else
      Result := '';
  end;
}
  Result := '';
end; // end of TK_FrameRAEdit.GetEditMask

//**************************************** TK_FrameRAEdit.SGridGetEditMask
//
procedure TK_FrameRAEdit.SGridGetEditMask(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
  SetCurLPos( ACol, ARow );
  if (CurLPos.Col < 0) or
     (CurLPos.Row < 0) then Exit;
  Value := GetEditMask(  );
end; // end of TK_FrameRAEdit.SGridGetEditMask

//**************************************** TK_FrameRAEdit.GetDataText
//
function TK_FrameRAEdit.GetDataText( const Data;
                                     const CDType : TK_ExprExtType;
                                     fmt : string = '';
                                     ValueToStrFlags : TK_ValueToStrFlags = [] ) : string;
var
  AStrLen : Integer;
begin
  if (CDType.DTCode < Ord(nptNoData)) or
     (CDType.FD.FDObjType = K_fdtSet) then
    AStrLen := 0
  else
    AStrLen := 100;
  Result := K_SPLValueToString( Data, CDType, ValueToStrFlags, Fmt, nil, AStrLen );
end; // end of TK_FrameRAEdit.GetDataText

//**************************************** TK_FrameRAEdit.GetEditText
//
function TK_FrameRAEdit.GetEditText( const Data ): string;
begin
  with RAFCArray[CurLCol] do
    Result := GetDataText( Data, CDType, Fmt );
end; // end of TK_FrameRAEdit.GetEditText

//**************************************** TK_FrameRAEdit.GetDataPointer
//
function TK_FrameRAEdit.GetDataPointer( ACol, ARow: Integer) : Pointer;
begin
  SetCurLPos( ACol, ARow );
  Result := nil;
  if (CurLPos.Col < 0) or
     (CurLPos.Row < 0) or
     (DataPointers = nil) then Exit;
  Result := DataPointers[CurLPos.Row][CurLPos.Col];
end; // end of TK_FrameRAEdit.GetDataPointer

//**************************************** TK_FrameRAEdit.SGridGetEditText
//
procedure TK_FrameRAEdit.SGridGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
var
  PData : Pointer;
begin
  PData := GetDataPointer( ACol, ARow );
  if PData = nil then Exit;
  Value := GetEditText( PData^ );
  BeforeEditTextValue := Value;
end; // end of TK_FrameRAEdit.SGridGetEditText

//**************************************** TK_FrameRAEdit.SGridSetEditText
//
procedure TK_FrameRAEdit.SGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
var
  PData : Pointer;
begin
  PData := GetDataPointer( ACol, ARow );
  if PData = nil then Exit;
  if BeforeEditTextValue <> Value then
    SetEditText( Value, PData^ );
end; // end of TK_FrameRAEdit.SGridSetEditText

//**************************************** TK_FrameRAEdit.SetEditText
//
procedure TK_FrameRAEdit.SetEditText( AText : string; var Data );
var
  ErrorStr : string;
begin
  with RAFCArray[CurLCol] do begin
    ErrorStr := K_SPLValueFromString( Data, CDType.All, AText );
//    if (ErrorStr <> '') and
//       ((CDType.D.TFlags and K_ffEnumSet) = 0) then
    if (ErrorStr <> '') and
       ( ( CDType.DTCode < Ord(nptNoData) )            or
         ( (CDType.D.TFlags and K_ffFlagsMask) <> 0 )  or
         ( Ord(CDType.FD.FDObjType) < Ord(K_fdtEnum) ) ) then
//      ShowMessage( 'Wrong type "'+K_GetExecTypeName(CDType.All)+
//                                                  '" data value - ' + ErrorStr )
      K_ShowMessage( 'Wrong type "'+K_GetExecTypeName(CDType.All)+
                     '" data value - ' + ErrorStr  )
     else
       AddChangeDataFlag;
  end;
end; // end of TK_FrameRAEdit.SetEditText

//**************************************** TK_FrameRAEdit.BtExtEditorClick
//
procedure TK_FrameRAEdit.BtExtEditor_1Click(Sender: TObject);
begin
  CallEditorExecute( Sender );
end; // end of TK_FrameRAEdit.BtExtEditorClick

//**************************************** TK_FrameRAEdit.SGridColumnMoved
//
procedure TK_FrameRAEdit.SGridColumnMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
var ChangeData : Boolean;
begin
  if K_ramColVertical in CDescr.ModeFlags then begin
    RCMove( GLCNumbers, FromIndex, ToIndex);
    ChangeData := (K_ramColChangeOrder in CDescr.ModeFlags);
    if Assigned(OnColMoved) then OnColMoved( FromIndex, ToIndex );
  end else begin
    RCMove( GLRNumbers, FromIndex, ToIndex);
    ChangeData := (K_ramRowChangeOrder in CDescr.ModeFlags);
    if Assigned(OnRowMoved) then OnRowMoved( FromIndex, ToIndex );
  end;

  if ChangeData then AddChangeDataFlag();

end; // end of TK_FrameRAEdit.SGridColumnMoved

//**************************************** TK_FrameRAEdit.SGridRowMoved
//
procedure TK_FrameRAEdit.SGridRowMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
var ChangeData : Boolean;
begin

  if K_ramColVertical in CDescr.ModeFlags then begin
    RCMove( GLRNumbers, FromIndex, ToIndex);
    ChangeData := (K_ramRowChangeOrder in CDescr.ModeFlags);
    if Assigned(OnRowMoved) then OnRowMoved( FromIndex, ToIndex );
  end else begin
    RCMove( GLCNumbers, FromIndex, ToIndex);
    ChangeData := (K_ramColChangeOrder in CDescr.ModeFlags);
    if Assigned(OnColMoved) then OnColMoved( FromIndex, ToIndex );
  end;
  if ChangeData then AddChangeDataFlag();

end; // end of TK_FrameRAEdit.SGridRowMoved

//**************************************** TK_FrameRAEdit.DefTEditExit
//
procedure TK_FrameRAEdit.DefTEditExit(Sender: TObject);
begin
  DefaultTEdit.Visible := false;
  if BeforeEditTextValue <> DefaultTEdit.Text then begin
    if Assigned(OnInlineEditorExit) then
      OnInlineEditorExit( DefaultTEdit.Text, PEditData^ )
    else
      SetEditText( DefaultTEdit.Text, PEditData^ );
  end;
  OnInlineEditorExit := nil;
end; // end of TK_FrameRAEdit.DefTEditExit

//**************************************** TK_FrameRAEdit.DefTEditKeyDown
//
procedure TK_FrameRAEdit.DefTEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
begin
  if ( (Key <> VK_RETURN) or
       (ssCtrl in Shift)  or
       (ssShift in Shift) ) and
     (Key <> VK_UP)         and
     (Key <> VK_DOWN)       and
     (Key <> VK_ESCAPE)     then Exit;
  if (Key = VK_ESCAPE) then
    DefaultTEdit.Text := BeforeEditTextValue;
//  DefTEditExit( Sender );
  SGrid.SetFocus;
end; // end of TK_FrameRAEdit.DefTEditKeyDown

//**************************************** TK_FrameRAEdit.SGridDblClick
//
procedure TK_FrameRAEdit.SGridDblClick(Sender: TObject);
begin
  CallEditorExecute( Sender );
end; // end of TK_FrameRAEdit.SGridDblClick

//**************************************** TK_FrameRAEdit.SGridKeyDown
//
procedure TK_FrameRAEdit.SGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  GR : TGridRect;

begin
  CurShift := Shift;

  if Assigned(OnKeyDown) and
     OnKeyDown( Key, Shift ) then Exit;

  case Key of
{
    VK_SHIFT, VK_CONTROL :
      if not AutoInvalidate then begin
        SGrid.Invalidate;
        AutoInvalidate := true;
      end;
}
    VK_RETURN : //*** enter
      CallEditorExecute( Sender );

    VK_DELETE : //*** enter
      ClearSelectedExecute( Sender );

    VK_INSERT : //*** insert
    begin
      if ssCtrl in Shift then
        CopyToClipBoardExecute( nil )
      else if (ssShift in Shift) and
              not (K_ramSkipDataPaste in CDescr.ModeFlags) then begin
        PasteFromClipBoardExecute( nil );
        AddChangeDataFlag;
      end;
    end;
    else
      if (Key = $41) and (ssCtrl in Shift) then
      begin
        GR.Top := 0;
        GR.Bottom := SGrid.RowCount - 1;
        GR.Left := 0;
        GR.Right := SGrid.ColCount - 1;
        SGrid.Selection := GR;
      end;
      if CallExtEditor( true ) and
         ( ((Key >= $30) and (Key <= $39)) or
           ((Key >= $41) and (Key <= $5A)) ) then begin
// VK_0 thru VK_9 are the same as ASCII '0' thru '9' ($30 - $39)
// VK_A thru VK_Z are the same as ASCII 'A' thru 'Z' ($41 - $5A)
        CallInlineTextEditor;
        DefaultTEdit.Text := LowerCase(Char(Key));
        if ssShift in Shift then
          DefaultTEdit.Text := UpperCase(DefaultTEdit.Text);
        DefaultTEdit.SelStart := 1;
      end;
  end;
end; // end of TK_FrameRAEdit.SGridKeyDown

//**************************************** TK_FrameRAEdit.SGridKeyUp
//
procedure TK_FrameRAEdit.SGridKeyUp( Sender: TObject; var Key: Word;
                                     Shift: TShiftState );
begin
//  AutoInvalidate := false;
end; // end of TK_FrameRAEdit.SGridKeyUp

//**************************************** TK_FrameRAEdit.SGridMouseDown
//
procedure TK_FrameRAEdit.SGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
type TK_BBuf = record
  IBuf : LongWord;
  case Integer of
  0 : ( IData     : LongWord; );
  1 : ( Bytes     : Array [0..3] of Byte; );
end;
var
  PData : PInteger;
  ARow, ACol : Integer;
  GR : TGridRect;
  BData : TK_BBuf;
  TypeSize : Integer;
//  CellDisabled : TK_RAFDisabled;

  procedure StoreBitOrEnum( BitMask : LongWord );
  begin
    BData.IData := (BData.IData and not BitMask) or BData.IBuf;
    Move( BData.Bytes[0], PData^, TypeSize );
    AddChangeDataFlag;
  end;

begin
  CurShift := Shift;
  SGrid.MouseToCell(X, Y, ACol, ARow );
  SetCurLPos( ACol, ARow );

  if Assigned(OnMouseDown) and
     OnMouseDown(Button, Shift, X, Y) then Exit;

  if CurLPos.Row <> -3 then
    if ((ARow = 0) or (ACol = 0)) then begin
      if (Button = mbLeft) then begin//*** Grid Select
      //Left, Top, Right, Bottom
        if ARow = 0 then begin
          GR.Top := 0;
          GR.Bottom := SGrid.RowCount - 1;
          GR.Left := ACol;
          GR.Right := ACol;
        end;
        if ACol = 0 then begin
          GR.Left := 0;
          GR.Right := SGrid.ColCount - 1;
          if ARow <> 0 then  begin
            GR.Top := ARow;
            GR.Bottom := ARow;
          end;
        end;
        SGrid.Selection := GR;
      end;
    end else if CellWasSelected and
               (CurLPos.Col >= 0) and
               (CurLPos.Row >= 0) and
               not (DataPointers = nil) then
      with RAFCArray[CurLPos.Col] do
        if not ShowHideExtEditButton( CurGPos.Col, CurGPos.Row, RAFCArray[CurLPos.Col] ) then begin
          PData := PInteger(DataPointers[CurLPos.Row][CurLPos.Col]);
//          CellDisabled := GetCellEnableState( CurLPos.Col, CurLPos.Row );
          if (PData <> nil)                          and
             not (K_racReadOnly in ShowEditFlags)    and
             not (K_ramReadOnly in CDescr.ModeFlags) and
             (GetCellEnableState( CurLPos.Col, CurLPos.Row ) = K_rfdEnabled) then begin
            TypeSize := Min( K_GetExecTypeSize( CDType.All ), SizeOf(BData.IBuf) );
            if K_racShowCheckBox in ShowEditFlags then begin
              Move( PData^, BData.Bytes[0], TypeSize );
              BData.IBuf := BData.IData and BitMask;
              BData.IBuf := BData.IBuf xor BitMask;
              StoreBitOrEnum( BitMask );
            end else if K_racEnumSwitch in ShowEditFlags then begin
              Move( PData^, BData.Bytes[0], TypeSize );
              BData.IBuf := BData.IData and BitMask;
              if Integer(BData.IBuf) < CDType.FD.FDFieldsCount - 1 then
                BData.IBuf := BData.IBuf + 1
              else
                BData.IBuf := 0;
              StoreBitOrEnum( BitMask );
            end;
          end;
        end;

  if (ARow = 0) or (ACol = 0) then begin
    if (CurLPos.Col >= 0) and
       not (K_ramSkipColsMark in CDescr.ModeFlags) then
      ToggleLColMark( CurLPos.Col );
    if (CurLPos.Row >= 0) and
       (K_ramMarkRowsByHeader in CDescr.ModeFlags) then
      ToggleLRowMark( CurLPos.Row );
  end;
end; // end of TK_FrameRAEdit.SGridMouseDown

//**************************************** TK_FrameRAEdit.SGridMouseMove
//
procedure TK_FrameRAEdit.SGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  ARow, ACol : Integer;
  LPos : TK_GridPos;
begin
  SGrid.MouseToCell(X, Y, ACol, ARow );
  LPos := ToLogicPos( ACol, ARow );
  if LPos.Col < 0 then begin
    SGrid.ShowHint := false;
    Exit;
  end;

  with RAFCArray[LPos.Col] do
    if (HintGridPos.Col = LPos.Col) and
       (HintGridPos.Row = LPos.Row) and
       (Hint <> '') then begin
      SGrid.Hint := Hint;
      SGrid.ShowHint := true;
    end else
      SGrid.ShowHint := false;

  HintGridPos := LPos;

end; // end of TK_FrameRAEdit.SGridMouseMove

//**************************************** TK_FrameRAEdit.FrameResize
//
procedure TK_FrameRAEdit.FrameResize(Sender: TObject);
begin
  if SkipResizeFlag then Exit;
  FormResizeMode := not ResizeBeforeFirstShowMode;
  RebuildGridInfo();
  SetLastColumnWidth;
  FormResizeMode := false;
end; // end of TK_FrameRAEdit.FrameResize

//*********************************
//**************** Actions Execute
//*********************************

//**************************************** TK_FrameRAEdit.GetPointerToCellData
//
procedure TK_FrameRAEdit.GetPointerToCellData;
begin
  PEditData := nil;
  if not CellWasSelected  or
     (DataPointers = nil) or
     (K_racReadOnly in RAFCArray[CurLPos.Col].ShowEditFlags) or
     (K_ramReadOnly in CDescr.ModeFlags) or
//     not (K_racExternalEditor in RAFCArray[CurLPos.Col].ShowEditFlags) or
     (CurLPos.Row < 0)    or
     (CurLPos.Col < 0)    or
     N_KeyIsDown(VK_MENU) then Exit;
  PEditData := DataPointers[CurLPos.Row][CurLPos.Col];
end; // end of TK_FrameRAEdit.GetPointerToCellData

//**************************************** TK_FrameRAEdit.PrepEditFuncContext
//
procedure TK_FrameRAEdit.PrepEditFuncContext( PRFC : TK_PRAEditFuncCont );
begin
  with PRFC^, RAFCArray[CurLCol] do begin
    FRLSData   := RLSData;
    FDataPath  := GetCurCellDataPath;
    FDType     := CDType;
    FDataCapt  := Caption;
    FSetModeFlags := ModeFlags;
    FPCDescr   := @CDescr;
    FRAFrame   := Self;
    FOnGlobalAction := RAFGlobalActionProc;
    FOwner := K_GetOwnerBaseForm( Self );
    FGEDataIDPrefix := Name;
    FUseOpenedChildForm := (K_racUseOpenedChildForm in ShowEditFlags) or
                          (K_ramUseOpenedChildForm in ModeFlags);
//    K_racUseOpenedChildForm
    with VEArray[CVEInd] do begin
      FSEInds := SEInds;
      FGEDataID := EEID;
    end;
    FNotModalShow := (K_racNotModalShow in ShowEditFlags) or
                     (K_ramNotModalShow in ModeFlags);
  end;
end; // end of TK_FrameRAEdit.PrepEditFuncContext

//**************************************** TK_FrameRAEdit.CallCellEditor
//
function  TK_FrameRAEdit.CallCellEditor : Boolean;
begin
  FixCurEditorInd := -1;
  Result := CallExtEditor;
end; // end of TK_FrameRAEdit.CallCellEditor

//**************************************** TK_FrameRAEdit.GetCellViewer
//
function  TK_FrameRAEdit.GetCellViewer( LCol, LRow :Integer ) : TK_RAFViewer;
begin
  Result := nil;
  with RAFCArray[LCol] do
    if VEArray <> nil then // to avoid exception while add new column
      Result := VEArray[CViewerInd].VObj;

  if not Assigned(Result) or
     not Result.IfUseViewer( LCol, LRow, RAFCArray[LCol] ) then
    Result := DefaultRAFViewer;
end; // end of TK_FrameRAEdit.GetCellViewer

//**************************************** TK_FrameRAEdit.CallExtEditor
//
function  TK_FrameRAEdit.CallExtEditor( OnlyCheckInlineTextEditorCall : Boolean = false ) : Boolean;
var
  EE : TK_RAFEditor;
  CellDisabled : TK_RAFDisabled;
begin
  Result := false;
  GetPointerToCellData();
  if (PEditData = nil) or
     (K_racShowCheckBox in RAFCArray[CurLPos.Col].ShowEditFlags) then Exit;
  CellDisabled := GetCellEnableState( CurLPos.Col, CurLPos.Row );
  if (K_racExternalEditor in RAFCArray[CurLPos.Col].ShowEditFlags) then
    EE := GetExtEdit( CurLPos.Col, CurLPos.Row )
  else
    EE := TK_RAFEditor(1);

  if Integer(EE) < 10 then begin
    if CellDisabled <> K_rfdEnabled then Exit;
    if Integer(EE) = 1  then begin
      if OnlyCheckInlineTextEditorCall then begin
        Result := true;
      end else
        CallInlineTextEditor;
    end;

    Exit;
  end else if (EE <> DefaultRAFEditor) and
              (CellDisabled <> K_rfdEnabled) then Exit;

  if OnlyCheckInlineTextEditorCall then Exit;
  Result := EE.Edit( PEditData^ );
  if Result then AddChangeDataFlag;
end; // end of TK_FrameRAEdit.CallExtEditor

//**************************************** TK_FrameRAEdit.CallInlineTextEditor
//
procedure  TK_FrameRAEdit.CallInlineTextEditor;
var
  PData : Pointer;
begin
  PData := DataPointers[CurLPos.Row][CurLPos.Col];
  if PData = nil then Exit;
  BeforeEditTextValue := GetEditText( PData^ );
  DefaultTEdit.Text := BeforeEditTextValue;
  PlaceExtControl(CurGPos.Col, CurGPos.Row, DefaultTEdit);
  DefaultTEdit.SetFocus;
end; // end of TK_FrameRAEdit.CallInlineTextEditor

//**************************************** TK_FrameRAEdit.CallInlineTextEditor
//
procedure  TK_FrameRAEdit.CallInlineTextEditor( EditText : string );
begin
  if (CurLPos.Row < 0) or (CurLPos.Col < 0) then Exit;
  BeforeEditTextValue := EditText;
  DefaultTEdit.Text := BeforeEditTextValue;
  PlaceExtControl(CurGPos.Col, CurGPos.Row, DefaultTEdit);
  DefaultTEdit.SetFocus;
end; // end of TK_FrameRAEdit.CallInlineTextEditor

//**************************************** TK_FrameRAEdit.CallEditorExecute
//
procedure TK_FrameRAEdit.CallEditorExecute(Sender: TObject);
begin
  CallCellEditor;
end; // end of TK_FrameRAEdit.CallEditorExecute

//**************************************** TK_FrameRAEdit.GetSelectSection
//
procedure TK_FrameRAEdit.GetSelectSection( GetRowSect : Boolean;
                     var StartInd, IndLength : Integer );
var
  GR : TGridRect;
  FinInd : Integer;
begin
  GR := SGrid.Selection;
  GR.Top := Max( GR.Top, 1 );
  GR.Left := Max( GR.Left, 1 );
  GetRowSect := not ( GetRowSect xor (K_ramColVertical in CDescr.ModeFlags) );
  if GetRowSect then begin
    FinInd := GR.Bottom;
    StartInd := GR.Top;
  end else begin
    FinInd := GR.Right;
    StartInd := GR.Left;
  end;
  IndLength := FinInd - StartInd + 1;
end; // end of TK_FrameRAEdit.GetSelectSection

//************************************************* TK_FrameRAEdit.FrDeleteRows
// Delete Frame Rows
//  Ind - SGrid Row Index (First Index = 1)
//
procedure TK_FrameRAEdit.FrDeleteRows( Ind, DCount : Integer );
var
  i : Integer;
//  DelEnabled : Boolean;
  SelRect: TGridRect;
  EmptyGrid : Boolean;
  RealDelete : Boolean;
begin
  if not(K_ramRowChangeNum in CDescr.ModeFlags) or
     (Length(GLRNumbers) <= 1) then  Exit;

  RealDelete := DCount <> 0;
  if Assigned(OnRowsDel) then OnRowsDel(Ind, DCount);

  for i := Ind + DCount to High(GLRNumbers) do
    GLRNumbers[i - DCount] := GLRNumbers[i];
  SetLength( GLRNumbers, Length(GLRNumbers) - DCount );

  DelRow.Enabled := (Length(GLRNumbers) > 1);

  EmptyGrid := Length(GLRNumbers) = 1;

  if EmptyGrid then
    DCount := 2
  else
    DCount := Length(GLRNumbers);

  if K_ramColVertical in CDescr.ModeFlags then
    SGrid.RowCount := DCount
  else
    SGrid.ColCount := DCount;

  if EmptyGrid then
    SelRect := TGridRect(Rect(1,1,1,1))
  else
    SelRect := SGrid.Selection;
  RebuildGridInfo( );

  if RealDelete then
    SelectRect( SelRect.Left, SelRect.Top, SelRect.Right, SelRect.Bottom );

  AddChangeDataFlag;
  SGrid.Invalidate;

end; // end of TK_FrameRAEdit.FrDeleteRows

//**************************************** TK_FrameRAEdit.DelRowExecute
//
procedure TK_FrameRAEdit.DelRowExecute(Sender: TObject);
var
  DelSect, DelStart : Integer;
begin
  GetSelectSection( true, DelStart, DelSect );
  FrDeleteRows(DelStart, DelSect);
end; // end of TK_FrameRAEdit.DelRowExecute

//**************************************** TK_FrameRAEdit.AddRowExecute
//
procedure TK_FrameRAEdit.AddRowExecute(Sender: TObject);
begin
  FrInsertRows( 0, 1 );
end; // end of TK_FrameRAEdit.AddRowExecute

//**************************************** TK_FrameRAEdit.InsRowExecute
//
procedure TK_FrameRAEdit.InsRowExecute(Sender: TObject);
var StartRow, RowCount : Integer;
begin
  GetSelectSection( true, StartRow, RowCount );
  FrInsertRows( StartRow, 1 );
end; // end of TK_FrameRAEdit.InsRowExecute

//**************************************** TK_FrameRAEdit.AddColExecute
//
procedure TK_FrameRAEdit.AddColExecute(Sender: TObject);

begin
  FrInsertCols( 0, 1 );
end; // end of TK_FrameRAEdit.AddColExecute

//**************************************** TK_FrameRAEdit.InsColExecute
//
procedure TK_FrameRAEdit.InsColExecute(Sender: TObject);
var StartCol, ColCount : Integer;
begin
  GetSelectSection( false, StartCol, ColCount );
  FrInsertCols( StartCol, 1  );
end; // end of TK_FrameRAEdit.InsColExecute

//**************************************** TK_FrameRAEdit.DelColExecut
//
procedure TK_FrameRAEdit.DelColExecute(Sender: TObject);
var
//  i, DelCol, DelSect, DelStart : Integer;
  DelSect, DelStart : Integer;
begin
  GetSelectSection( false, DelStart, DelSect );
  FrDeleteCols( DelStart, DelSect );
end; // end of TK_FrameRAEdit.DelColExecut

//**************************************** TK_FrameRAEdit.CopyToClipBoardExec
//
procedure TK_FrameRAEdit.CopyToClipBoardExec( CopyCaptions : Boolean );
var
  i, j : Integer;
  buf : string;
  LPos : TK_GridPos;
  PData : Pointer;
  GR : TGridRect;
  BufList : TStringList;

  function AddCell( Col, Row : Integer ) : WideString;
  begin
    LPos := ToLogicPos( Col, Row );
    PData := DataPointers[LPos.Row][LPos.Col];
    with RAFCArray[LPos.Col] do
      if not (K_racSeparator in ShowEditFlags)  then
        Result := K_SPLValueToString( PData^, CDType, [], Fmt );
  end;

  function AddCaptionCell( Col, Row : Integer ) : WideString;
  var
    Num : Integer;
  begin
    LPos := ToLogicPos( Col, Row );
    Result := '';
    with RAFCArray[LPos.Col] do begin
      if LPos.Row >= 0 then begin
        //*** Row Caption
        if K_ramShowLRowNumbers in CDescr.ModeFlags then
        begin
          if K_ramColVertical in CDescr.ModeFlags then
            Num := Row
          else
            Num := Col;
          Result := format(RNumFormat, [Num - 1]);
        end;
        Result := Result + RowCaptions[LPos.Row];
      end else if LPos.Col >= 0 then
      begin
        //*** Col Caption
        if K_ramShowLColNumbers in CDescr.ModeFlags then
        begin
          if K_ramColVertical in CDescr.ModeFlags then
            Num := Col
          else
            Num := Row;
          Result := format(CNumFormat, [Num - 1]);
        end;
        Result := Result + Caption;
      end;
    end;
  end;

begin
  GR := SGrid.Selection;
  GR.Top  := Max( GR.Top, 1 );
  GR.Left := Max( GR.Left, 1 );
  BufList := TStringList.Create();
  if CopyCaptions then begin
// Add Col Captions
    buf := SGrid.Cells[0, 0] + #9;
    for i := GR.Left to GR.Right - 1 do
      buf := buf + AddCaptionCell( i, 0 ) + #9;
    BufList.Add(buf + AddCaptionCell( GR.Right, 0 ));
  end;
// Add Selection
  for j := GR.Top to GR.Bottom do
  begin
    if CopyCaptions then
      buf := AddCaptionCell( 0, j ) + #9
    else
      buf := '';
    for i := GR.Left to GR.Right - 1 do
      buf := buf + AddCell( i, j ) + #9;
    BufList.Add(buf + AddCell( GR.Right, j ));
  end;
  K_PutTextToClipboard( BufList.Text );
  K_RAFClipBoard.Text := BufList.Text;
  GetSelectionToRAArray( K_RAFClipBoard.BBuf );
  BufList.Free;
end; // end of TK_FrameRAEdit.CopyToClipBoardExec

//**************************************** TK_FrameRAEdit.PopUpCopyToClipBoardMenu
//
procedure TK_FrameRAEdit.PopUpCopyToClipBoardMenu(Sender: TObject);
begin
  PUMItemCopy.Checked := not ExtendedCopyToClipboardMode;
  PUMItemECopy.Checked := ExtendedCopyToClipboardMode;
end; // end of TK_FrameRAEdit.PopUpCopyToClipBoardMenu

//**************************************** TK_FrameRAEdit.CopyToClipBoardAExecute
//
procedure TK_FrameRAEdit.CopyToClipBoardAExecute(Sender: TObject);
begin
  ExtendedCopyToClipboardMode := N_KeyIsDown(VK_SHIFT);
  CopyToClipBoardExec( ExtendedCopyToClipboardMode );
end; // end of TK_FrameRAEdit.CopyToClipBoardAExecute

//**************************************** TK_FrameRAEdit.CopyToClipBoardExecute
//
procedure TK_FrameRAEdit.CopyToClipBoardExecute(Sender: TObject);
begin
  ExtendedCopyToClipboardMode := false;
  CopyToClipBoardExec( false );
end; // end of TK_FrameRAEdit.CopyToClipBoardExecute

//**************************************** TK_FrameRAEdit.CopyToClipBoardEExecute
//
procedure TK_FrameRAEdit.CopyToClipBoardEExecute(Sender: TObject);
begin
  ExtendedCopyToClipboardMode := true;
  CopyToClipBoardExec( true );
end; // end of TK_FrameRAEdit.CopyToClipBoardEExecute

//**************************************** TK_FrameRAEdit.ClearSelectedExecute
//
procedure TK_FrameRAEdit.ClearSelectedExecute(Sender: TObject);
var
  i, j : Integer;
  LPos : TK_GridPos;
  GR : TGridRect;
  ClearCounter : Integer;
begin
  GR := SGrid.Selection;
  GR.Top := Max( GR.Top, 1 );
  GR.Left := Max( GR.Left, 1 );
  ClearCounter := 0;
  for j := GR.Top to GR.Bottom do
    for i := GR.Left to GR.Right do
    begin
      LPos := ToLogicPos( i, j );
      if not SGridColExtEditMode( LPos.Col, LPos.Row, true ) then Continue;
      with RAFCArray[LPos.Col] do
        K_FreeSPLData( DataPointers[LPos.Row][LPos.Col]^, CDType.All );
      SGrid.Cells[i, j] := '';
      Inc(ClearCounter);
    end;
  if ClearCounter = 0 then Exit;
  AddChangeDataFlag;
  SGrid.Invalidate;
end; // end of TK_FrameRAEdit.ClearSelectedExecute

//**************************************** TK_FrameRAEdit.RebuildGridExecute
//
procedure TK_FrameRAEdit.RebuildGridExecute(Sender: TObject);
begin
  RebuildGridInfo( );
end; // end of TK_FrameRAEdit.RebuildGridExecute

//**************************************** TK_FrameRAEdit.TranspGridExecute
//
procedure TK_FrameRAEdit.TranspGridExecute(Sender: TObject);
begin
  SetCurLPos( 0, 0 );
  ModeFlags := (ModeFlags - [K_ramColVertical]) +
       ([K_ramColVertical] - ModeFlags);

  RebuildGridInfo(  );
end; // end of TK_FrameRAEdit.TranspGridExecute

//**************************************** TK_FrameRAEdit.SetPasteFromClipboardModeExecute
//
procedure TK_FrameRAEdit.SetPasteFromClipboardModeExecute(Sender: TObject);
begin
  K_RAShowEdit( [], [K_ramFillFrameWidth], PasteFromClipboardFlags,
    K_GetTypeCodeSafe( 'TK_RAFPasteFromClipboardMode'),
    'Режим вставки из буфера' );
end; // end of TK_FrameRAEdit.SetPasteFromClipboardModeExecute

//**************************************** TK_FrameRAEdit.SendFValsExecute
//
procedure TK_FrameRAEdit.SendFValsExecute(Sender: TObject);
begin
   if DataDeliveryForm = nil then DataDeliveryForm := TK_FRADataDeliveryForm.Create( Application );
   TK_FRADataDeliveryForm(DataDeliveryForm).RAFrame := Self;
   DataDeliveryForm.Show;
end; // end of TK_FrameRAEdit.SendFValsExecute

//**************************************** TK_FrameRAEdit.ScrollToNextRowExecute
//
procedure TK_FrameRAEdit.ScrollToNextRowExecute(Sender: TObject);
begin
  ScrollToLRowPos( CurGCol + 1, CurGRow + 1 );
end; // end of TK_FrameRAEdit.ScrollToNextRowExecute

//**************************************** TK_FrameRAEdit.ScrollToPrevRowExecute
//
procedure TK_FrameRAEdit.ScrollToPrevRowExecute(Sender: TObject);
begin
  ScrollToLRowPos( CurGCol - 1, CurGRow - 1 );
end; // end of TK_FrameRAEdit.ScrollToPrevRowExecute

//**************************************** TK_FrameRAEdit.ScrollToFirstRowExecute
//
procedure TK_FrameRAEdit.ScrollToFirstRowExecute(Sender: TObject);
begin
  ScrollToLRowPos( -1, -1 );
end; // end of TK_FrameRAEdit.ScrollToFirstRowExecute

//**************************************** TK_FrameRAEdit.ScrollToLastRowExecute
//
procedure TK_FrameRAEdit.ScrollToLastRowExecute(Sender: TObject);
begin
  ScrollToLRowPos( MaxInt, MaxInt );
end; // end of TK_FrameRAEdit.ScrollToLastRowExecute

//**************************************** TK_FrameRAEdit.SwitchSRecordModeExecute
//
procedure TK_FrameRAEdit.SwitchSRecordModeExecute(Sender: TObject);
begin
  ModeFlags := (ModeFlags - [K_ramShowSingleRecord]) +
       ([K_ramShowSingleRecord] - ModeFlags);

  RebuildGridInfo(  );
end; // end of TK_FrameRAEdit.SwitchSRecordModeExecute

//**************************************** TK_FrameRAEdit.ShowHelpExecute
//
procedure TK_FrameRAEdit.ShowHelpExecute(Sender: TObject);
begin
  with RAFCArray[CurLPos.Col] do
    N_ShowHelp( MVHelpTopicID, K_GetOwnerBaseForm(Self) );
end; // end of TK_FrameRAEdit.ShowHelpExecute

//**************************************** TK_FrameRAEdit.SetColResizeByDataExecute
//
procedure TK_FrameRAEdit.SetColResizeByDataExecute(Sender: TObject);
begin
  CDescr.ColResizeMode := K_crmDataBased;
  RebuildGridExecute( Sender );
end; // end of TK_FrameRAEdit.SetColResizeByDataExecute

//**************************************** TK_FrameRAEdit.SetColResizeByHeaderExecute
//
procedure TK_FrameRAEdit.SetColResizeByHeaderExecute(Sender: TObject);
begin
  CDescr.ColResizeMode := K_crmHeaderBased;
  RebuildGridExecute( Sender );
end; // end of TK_FrameRAEdit.SetColResizeByHeaderExecute

//**************************************** TK_FrameRAEdit.SetColResizeCompactExecute
//
procedure TK_FrameRAEdit.SetColResizeCompactExecute(Sender: TObject);
begin
  CDescr.ColResizeMode := K_crmCompact;
  RebuildGridExecute( Sender );
end; // end of TK_FrameRAEdit.SetColResizeCompactExecute

//**************************************** TK_FrameRAEdit.SetColResizeNormalExecute
//
procedure TK_FrameRAEdit.SetColResizeNormalExecute(Sender: TObject);
begin
  CDescr.ColResizeMode := K_crmNormal;
  RebuildGridExecute( Sender );
end; // end of TK_FrameRAEdit.SetColResizeNormalExecute

//**************************************** TK_FrameRAEdit.PasteFromClipBoardExecute
//
procedure TK_FrameRAEdit.PasteFromClipBoardExecute(Sender: TObject);
var

  BText : string;
begin

  BText := K_GetTextFromClipboard;
  if K_RAFClipBoard.Text = BText then begin
    // Paste Binary Data
    PasteRAArrayToSelection( PasteFromClipboardFlags, K_RAFClipBoard.BBuf );
  end else begin
    // Paste Text
    PasteTextToSelection( PasteFromClipboardFlags, BText );
  end;
  AddChangeDataFlag;
  SGrid.Invalidate;
end; // end of TK_FrameRAEdit.PasteFromClipBoardExecute

//**************************************** TK_FrameRAEdit.PUEditMenuPopup
//
procedure TK_FrameRAEdit.PUEditMenuPopup(Sender: TObject);
var
  NewItem : TMenuItem;
  i, j : Integer;
  CA : TK_ObjectArray;
begin
  CA := nil;
  PUEditMenu.Items.Clear;
  if (CurLPos.Col < 0) or
     (K_racCDisabled in RAFCArray[CurLPos.Col].ShowEditFlags) then Exit;

  if Assigned(OnBeforeFramePopup) then OnBeforeFramePopup;
  for i := 0 to High(PopupActionGroups) do begin
    CA := PopupActionGroups[i];
    if Length(CA) = 0 then begin
      BuildCurFieldEditActions();
      CA := CurFieldEActions;
    end;
    for j := 0 to High(CA) do begin
      NewItem := TMenuItem.Create(PUEditMenu); // create the new item
      PUEditMenu.Items.Add(NewItem);// add it to the Popupmenu
      NewItem.Action := TAction(CA[j]);
{
      if CA = CurFieldEActions then begin
        NewItem.OnClick := DeleteColExecute;
        NewItem.Enabled := true;
      end;
}
    end;
    PUEditMenu.Items.NewBottomLine;
  end;

  with RAFCArray[CurLPos.Col] do
    //*** Add Call Help Index Action
    if (CurLPos.Col >= 0) and (MVHelpTopicID <> '') then begin
      NewItem := TMenuItem.Create(PUEditMenu); // create the new item
      PUEditMenu.Items.Add(NewItem);// add it to the Popupmenu
      NewItem.Action := ShowHelp;
    end;

end; // end of TK_FrameRAEdit.PUEditMenuPopup

//**************************************** TK_FrameRAEdit.AddChangeDataFlag
//
procedure TK_FrameRAEdit.AddChangeDataFlag;
begin
  if Assigned(OnDataChange) then
    OnDataChange;
  if Assigned(OnDataApply) and
     ( (K_ramAutoApply in CDescr.ModeFlags) or
       (K_racAutoApply in RAFCArray[CurLCol].ShowEditFlags) ) then
    OnDataApply;

  if (CurLPos.Col >= 0) and
     (K_racRebuildAfterEdit in RAFCArray[CurLPos.Col].ShowEditFlags) then
    SGrid.Invalidate;
end; // end of TK_FrameRAEdit.AddChangeDataFlag

//**************************************** TK_FrameRAEdit.RAFGlobalAction
//
//procedure TK_FrameRAEdit.RAFGlobalActionProc( Sender : TObject; ActionType : TK_RAFGlobalAction );
function TK_FrameRAEdit.RAFGlobalActionProc( Sender : TObject; ActionType : TK_RAFGlobalAction ) : Boolean;
begin
  Result := true;
  case ActionType of
    K_fgaApplyToAll : begin
      Result := Assigned(OnDataApply) and
         not (K_racStopExtEditApply in RAFCArray[CurLCol].ShowEditFlags);
      if Result then
        OnDataApply
      else
        AddChangeDataFlag;
      SGrid.Invalidate;
    end;
    K_fgaCancelToAll : begin
      if Assigned(OnCancelToAll) then OnCancelToAll;
    end;
    K_fgaOKToAll : begin
      if Assigned(OnOKToAll) then OnOKToAll;
    end;
    K_fgaOK : begin
      AddChangeDataFlag;
      SGrid.Invalidate;
    end;
  end;
end; // end of TK_FrameRAEdit.RAFGlobalAction

//**************************************** TK_FrameRAEdit.PrepareColumnControls
//
procedure TK_FrameRAEdit.PrepareColumnControls( Col : Integer);
var
  i : Integer;
  WMask : LongWord;
begin
  with RAFCArray[Col] do begin
    DataTextWidth := 0;
    for i := 0 to High(VEArray) do
      with VEArray[i] do begin
        if Assigned(VObj) then VObj.RAFrame := Self;
        if (Integer(EObj) > 10) then EObj.RAFrame := Self;
      end;

    if K_racShowCheckBox in ShowEditFlags then begin
    //*** Clear ShowCheckBox Flag if incompatible field type
      if ( CDType.All <> Ord(nptByte) ) and
         ( CDType.All <> Ord(nptInt) )  and
         ( CDType.All <> Ord(nptHex) )  and
         ( CDType.All <> Ord(nptInt2) ) and
         ( CDType.All <> Ord(nptInt1) ) and
         ( CDType.All <> Ord(nptUInt2) )and
         ( CDType.All <> Ord(nptUInt4) )and
         ( ( CDType.DTCode <= Ord(nptNoData) ) or
           ( CDType.FD.FDObjType <> K_fdtSet ) ) then
        Exclude( ShowEditFlags, K_racShowCheckBox )
      else begin
        WMask := $FFFFFFFF;
        if BitMask = 0 then //BitMask := Integer($FFFFFFFF);
          K_MoveSPLData( WMask, BitMask, CDType );
      end;
    end;
  end;
end; // end of TK_FrameRAEdit.PrepareColumnControls

//**************************************** TK_FrameRAEdit.GetCellDataPath
//
function TK_FrameRAEdit.GetCellDataPath( LCol, LRow : Integer ): string;
var
  SkipPathName : Boolean;
begin
    //***** Set following variables:
  Result := '';
  if (LCol < 0) then Exit;
  Result := DataPath;
  SkipPathName := SkipCellDataPathName or (RAFCArray[LCol].Name = '');

  if MatrixModeDataPath then
    LRow := LRow * Length(RAFCArray) + LCol;

  if (LRow >= 0) and
     ( (LRow >= 1) or
       ( SkipPathName and
         not SkipCellDataPathInd
       )
     ) then
    Result := Result + Format( '[%d]', [LRow] );

  if not SkipPathName then begin
    if (Result <> '') and (Result <> K_sccRecFieldDelim + K_sccVarFieldDelim) then
      Result := Result + K_sccRecFieldDelim;
//  Result := Result + RAFCArray[LCol].Name;
    Result := Result + RAFCArray[LCol].Path;
  end;
end; // end of TK_FrameRAEdit.GetCellDataPath

//**************************************** TK_FrameRAEdit.GetCurCellDataPath
//
function TK_FrameRAEdit.GetCurCellDataPath : string;
begin
  Result := GetCellDataPath( CurLCol, CurLRow );
end; // end of TK_FrameRAEdit.GetCurCellDataPath

//**************************************** TK_FrameRAEdit.GetCellDataType
//
function TK_FrameRAEdit.GetCellDataType( LCol, LRow : Integer ): TK_ExprExtType;
var
  DP : Pointer;
begin
    //***** Set following variables:
  if (LCol < 0 ) then Exit;
  with RAFCArray[LCol] do begin
    Result := CDType;
    if ((CDType.D.TFlags and K_ffArray) <> 0) and
       (CDType.DTCode <> Ord(nptNoData))      and
       (DataPointers <> nil)                  and
       (LRow >= 0)                            then begin
      DP := DataPointers[LRow][LCol];
      if (DP <> nil) and (TK_PRArray(DP)^ <> nil) then
        Result := TK_PRArray(DP).ArrayType;
    end;
  end;
end; // end of TK_FrameRAEdit.GetCellDataType

//**************************************** TK_FrameRAEdit.GetCurCellDataType
//
function TK_FrameRAEdit.GetCurCellDataType : TK_ExprExtType;
begin
  Result := GetCellDataType( CurLCol, CurLRow );
end; // end of TK_FrameRAEdit.GetCurCellDataType

//************************************************* TK_FrameRAEdit.ToggleLColMark
// Toggle Mark State of Logical Column
//  LRow - Frame Logical Column Index
//
procedure TK_FrameRAEdit.ToggleLColMark( LCol: Integer );
var
  i : Integer;
  LInd : Integer;
begin
  if (LCol < 0) or (LCol >= Length(RAFCArray)) then Exit;
  with RAFCArray[LCol] do begin
    Marked := not Marked;
    if Marked then begin // Add To MarkedColsList
      if (MarkedLColsList <> nil) and
         (K_ramSingleColMark in CDescr.ModeFlags) then begin
      // Clear all previously Marked
        for i := MarkedLColsList.Count - 1 downto 0 do
          RAFCArray[Integer(MarkedLColsList[i])].Marked := false;
        MarkedLColsList.Clear;
      end;
      if MarkedLColsList = nil then
        MarkedLColsList := TList.Create;
      MarkedLColsList.Add( Pointer(LCol) );
    end else            // Clear Self From MarkedColsList
      with MarkedLColsList do begin
        LInd := IndexOf( Pointer(LCol) );
        if LInd >= 0 then Delete( LInd );
      end;
  end;

  if Assigned( OnColMarkToggle ) then OnColMarkToggle( LCol );

  SGrid.Invalidate;
end; // end of TK_FrameRAEdit.ToggleLColMark

//************************************************* TK_FrameRAEdit.ToggleLRowMark
// Toggle Mark State of Logical Row
//  LRow - Frame Logical Row Index
//
procedure TK_FrameRAEdit.ToggleLRowMark( LRow: Integer );
var
  i : Integer;
  LInd : Integer;
begin

  if (LRow < 0) or (LRow >= Length(RowMarks)) then
    Exit;
  RowMarks[LRow] := not RowMarks[LRow];
  if RowMarks[LRow] then begin // Add To MarkedRowsList
    if (MarkedLRowsList <> nil) and
       (K_ramSingleRowMark in CDescr.ModeFlags) then
    begin
    // Clear all previously Marked
      for i := MarkedLRowsList.Count - 1 downto 0 do
        RowMarks[Integer(MarkedLRowsList[i])] := false;
      MarkedLRowsList.Clear;
    end;
    if MarkedLRowsList = nil then
      MarkedLRowsList := TList.Create;
    MarkedLRowsList.Add( Pointer(LRow) );
  end
  else            // Clear Self From MarkedRowsList
    with MarkedLRowsList do begin
      LInd := IndexOf( Pointer(LRow) );
      if LInd >= 0 then Delete( LInd );
    end;

  if Assigned( OnRowMarkToggle ) then OnRowMarkToggle( LRow );

  SGrid.Invalidate;
end; // end of TK_FrameRAEdit.ToggleLRowMark

//************************************************* TK_FrameRAEdit.FrDeleteCols
// Delete Frame Cols
//  Ind - SGrid Col Index (First Index = 1)
//
procedure TK_FrameRAEdit.FrDeleteCols( Ind, DCount : Integer );
var
  i : Integer;
  SelRect: TGridRect;
  EmptyGrid : Boolean;
  RealDelete : Boolean;
begin
  if not(K_ramColChangeNum in CDescr.ModeFlags) or
     (Length(GLRNumbers) <= 1) then  Exit;

  RealDelete := DCount <> 0;
  if Assigned(OnColsDel) then OnColsDel(Ind, DCount);

  for i := Ind + DCount to High(GLCNumbers) do
    GLCNumbers[i - DCount] := GLCNumbers[i];
  SetLength( GLCNumbers, Length(GLCNumbers) - DCount );

  DelCol.Enabled := (Length(GLCNumbers) > 1);

  EmptyGrid := Length(GLCNumbers) = 1;
  if EmptyGrid then
    DCount := 2
  else
    DCount := Length(GLCNumbers);

  if K_ramColVertical in CDescr.ModeFlags then
    SGrid.ColCount := DCount
  else
    SGrid.RowCount := DCount;

  if EmptyGrid then
    SelRect := TGridRect(Rect(1,1,1,1))
  else
    SelRect := SGrid.Selection;
  RebuildGridInfo( );

  if RealDelete then
    SelectRect( SelRect.Left, SelRect.Top, SelRect.Right, SelRect.Bottom );

  AddChangeDataFlag;
  SGrid.Invalidate;

end; // end of TK_FrameRAEdit.FrDeleteCols

//************************************************* TK_FrameRAEdit.FrOrderData
// Order Frame Data Rows or Columns by given Data compare function
//
//     Parameters
// ACount   - ordered elements conter
// AIArray  - array of indexes (RowsOrder or ColsOrder)
// AComFunc - compare data function of object
//
procedure TK_FrameRAEdit.FrOrderData( ACount : Integer; var AIArray : TN_IArray;
                                      AComFunc : TN_CompFuncOfObj );
var
  PtrsArray: TN_PArray;

begin
  if ACount <= 0 then Exit;
  SetLength( PtrsArray, ACount );
  SetLength( AIArray, ACount );
  K_FillIntArrayByCounter( PInteger(@PtrsArray[0]), ACount, SizeOf(Integer),
                           Integer(@AIArray[0]), SizeOf(Integer) );
  K_FillIntArrayByCounter( PtrsArray[0], ACount );
  N_SortPointers( PtrsArray, AComFunc );
  N_PtrsArrayToElemInds( @AIArray[0], PtrsArray,
                         @AIArray[0], SizeOf(Integer) );

  SGrid.Invalidate;

end; // end of TK_FrameRAEdit.FrOrderData

//************************************************* TK_FrameRAEdit.FrOrderRows0
// Order Frame Rows by given Column Elements and Data compare function
//
//     Parameters
// ALCol    - logical column number
// AComFunc - compare data function of object
//
procedure TK_FrameRAEdit.FrOrderRows0( ALCol : Integer; AComFunc : TN_CompFuncOfObj );
var
  CompElemsByInds : TN_CompFuncOfObj;
begin

  CurOrderedLCol := ALCol;
  CurDataCompareFunc := AComFunc;
  if Assigned(AComFunc) then
    CompElemsByInds := CompareColElems
  else begin
    CompElemsByInds := CompareColElemTexts;
    CurOrderedLColViewer := GetCellViewer( ALCol, 0 );
  end;
  FrOrderData( GetDataBufRow, RowsOrder, CompElemsByInds );

end; // end of TK_FrameRAEdit.FrOrderRows0

//************************************************* TK_FrameRAEdit.FrOrderCols0
// Order Frame Columns by given Row Elements and Data compare function
//
//     Parameters
// ALRow    - logical row number
// AComFunc - compare data function of object
//
procedure TK_FrameRAEdit.FrOrderCols0( ALRow : Integer; AComFunc : TN_CompFuncOfObj );
var
  CompElemsByInds : TN_CompFuncOfObj;
begin

  CurOrderedLRow := ALRow;
  CurDataCompareFunc := AComFunc;

  if Assigned(AComFunc) then
    CompElemsByInds := CompareRowElems
  else
    CompElemsByInds := CompareRowElemTexts;

  FrOrderData( GetDataBufCol, ColsOrder, CompElemsByInds );

end; // end of TK_FrameRAEdit.FrOrderCols0


//************************************************* TK_FrameRAEdit.FrGetColDataCompFunc
// Get compare data function of object for given logical Column
//
//     Parameters
// ALCol    - logical column number
// ADescOrderFLag - if =TRUE then function for descending ordering will be returned
// Result - Returns compare data function of object
//
function TK_FrameRAEdit.FrGetColDataCompFunc( ALCol : Integer; ADescOrderFLag : Boolean ) : TN_CompFuncOfObj;
var
  WDType : Int64;
begin
  Result := nil;

  with RAFCArray[ALCol] do
    WDType := CDType.All and K_ffCompareTypesMask;

  case WDType of
    Ord(nptByte)     : Result := N_CFuncs.CompOneByte;
    Ord(nptInt)      : Result := N_CFuncs.CompOneInt;
    Ord(nptHex),
    Ord(nptColor),
    Ord(nptUInt4)    : Result := N_CFuncs.CompOneUInt;
    Ord(nptString)   : Result := N_CFuncs.CompOneStr;
    Ord(nptDouble),
    Ord(nptTDate),
    Ord(nptTDateTime): Result := N_CFuncs.CompOneDouble;
  end;
  CurDataDescOrder := ADescOrderFLag;
  if not Assigned(Result) then Exit;
  N_CFuncs.Offset := 0;
  N_CFuncs.DescOrder := ADescOrderFLag;
end; // end of TK_FrameRAEdit.FrGetColDataCompFunc

//************************************************* TK_FrameRAEdit.FrOrderRows
// Order Frame Rows by given Column Elements and Data compare function
//
//     Parameters
// ALCol    - logical column number
// ADescOrderFLag - if =TRUE then function for descending ordering will be returned
//
procedure TK_FrameRAEdit.FrOrderRows( ALCol : Integer; ADescOrderFLag : Boolean );
begin
  FrOrderRows0( ALCol, FrGetColDataCompFunc( ALCol, ADescOrderFLag ) );
end; // end of TK_FrameRAEdit.FrOrderRows

//**************************************** TK_FrameRAEdit.RenameColExecute
//
procedure TK_FrameRAEdit.RenameColExecute(Sender: TObject);
begin
  if CurLPos.Col >= 0 then
    with RAFCArray[CurLPos.Col] do
      if K_EditNameAndAliase( Name, Caption ) then
        if Assigned(OnColRenamed) then OnColRenamed( Name, Caption );
end; // end of TK_FrameRAEdit.RenameColExecute

//**************************************** TK_FrameRAEdit.SearchExecute
//
procedure TK_FrameRAEdit.SearchExecute(Sender: TObject);
begin
  K_RASearchReplace( Self, false );
end; // end of TK_FrameRAEdit.SearchExecute

//**************************************** TK_FrameRAEdit.ReplaceExecute
//
procedure TK_FrameRAEdit.ReplaceExecute(Sender: TObject);
begin
  K_RASearchReplace( Self, true );
end; // end of TK_FrameRAEdit.ReplaceExecute

//**************************************** TK_FrameRAEdit.FrInsertRows
//
procedure TK_FrameRAEdit.FrInsertRows( Ind, ICount : Integer );
var
  j, i, NewGridLeng : Integer;

begin
  if not Assigned(OnRowsAdd) or
     not(K_ramRowChangeNum in CDescr.ModeFlags) then  Exit;
//*** Add new elements to Data Pointers Array Row
  SetLength( DataPointers, MaxRowNum + ICount );
  for i := MaxRowNum to High( DataPointers ) do
    SetLength( DataPointers[i], MaxColNum );
//*** Add new element to Rows ReIndex Array
  j := Length(GLRNumbers);
  NewGridLeng := j + ICount;
  SetLength( GLRNumbers, NewGridLeng );
  if (Ind > 0) and (Ind < j) then begin
    Move( GLRNumbers[Ind], GLRNumbers[Ind+ICount], SizeOf(Integer) * (j - Ind) );
    j := Ind;
  end;
  for i := j to j + ICount - 1 do begin
    GLRNumbers[i] := MaxRowNum;
    Inc(MaxRowNum);
  end;
//*** Add new elements to Rows Captions Array
  SetLength(RowCaptions, MaxRowNum);
  SetLength(RowMarks, MaxRowNum);
//  RColors[High(RColors)] :=

  OnRowsAdd( ICount );

//*** Init DataPointers and Buffer Data
  if K_ramColVertical in CDescr.ModeFlags then
    SGrid.RowCount := NewGridLeng
  else begin
    SGrid.ColCount := NewGridLeng;
//    RebuildGridInfo( );
  end;

  SelectLRect(  -1, j - 1, -1, j + ICount - 2 );
  SetCurLPos( 1, j );

  DelRow.Enabled := true;
  AddChangeDataFlag;

//??  if not (K_ramColVertical in CDescr.ModeFlags) then
  RebuildGridInfo( );
  SelectLRect(  -1, j - 1, -1, j + ICount - 2 );

  SGrid.Invalidate;
end; // end of TK_FrameRAEdit.FrInsertRows

//**************************************** TK_FrameRAEdit.FrInsertCols
//
procedure TK_FrameRAEdit.FrInsertCols( Ind, ICount : Integer );
var
  j, i, NewGridLeng : Integer;

begin
  if not(K_ramColChangeNum in CDescr.ModeFlags) or
     not Assigned(OnColsAdd) then  Exit;
  if Assigned(OnColsAdding) then OnColsAdding( ICount );
  if ICount = 0 then  Exit;
//*** Add new element to Columns ReIndex Array
  j := Length(GLCNumbers);
  NewGridLeng := j + ICount;
  SetLength( GLCNumbers, NewGridLeng );
  if (Ind > 0) and (Ind <= j) then begin
    Move( GLCNumbers[Ind], GLCNumbers[Ind+ICount], SizeOf(Integer) * (j - Ind) );
    j := Ind;
  end;

  for i := j to j + ICount - 1 do begin
    GLCNumbers[i] := MaxColNum;
    Inc(MaxColNum);
  end;

//*** Add new elements to Data Pointers Array Column
  for i := 0 to High(DataPointers) do
    SetLength( DataPointers[i], MaxColNum );

{
//*** Add new element to ComboBoxArray
  SetLength( TCMBArray, MaxColNum );
}

//*** Add new element to Columns Descriptions Array
  SetLength( RAFCArray, MaxColNum );


//??  SelectLRect(  j - 1, -1, j + ICount - 2, -1 );
//??  SetCurLPos( j, 1 );

  OnColsAdd( ICount );

  if K_ramColVertical in CDescr.ModeFlags then
    SGrid.ColCount := NewGridLeng
  else
    SGrid.RowCount := NewGridLeng;

  DelCol.Enabled := true;

  SelectLRect(  j - 1, -1, j + ICount - 2, -1 );
  SetCurLPos( j, 1 );

  AddChangeDataFlag;
//??  if (K_ramColVertical in CDescr.ModeFlags) then //??
    RebuildGridInfo( );
//  RebuildGridInfo;
  SelectLRect(  j - 1, -1, j + ICount - 2, -1 );

  SGrid.Invalidate;
end; // end of TK_FrameRAEdit.FrInsertCols

//**************************************** TK_FrameRAEdit.GetSelectionToRAArray
// Get Grid Selection To Data Pointers Matrix
//
procedure TK_FrameRAEdit.GetSelectionToRAArray( var RABuffer: TK_RAArray );
var
  StartRow, RowCount, StartCol, ColCount : Integer;
  i, j, iw, k : Integer;
begin
  GetSelectSection( true, StartRow, RowCount );
  if RowCount = 0 then Exit;
  GetSelectSection( false, StartCol, ColCount );
  if ColCount = 0 then Exit;
// Prepare Buffer
  for j := 0 to High(RABuffer) do
    RABuffer[j].ARelease;
  SetLength( RABuffer, ColCount );

  k := 0;
  for j := 0 to High(RABuffer) do
    with RAFCArray[ToLogicCol(StartCol+j)] do
      if not (K_racSeparator in ShowEditFlags) then begin
        RABuffer[k] := K_RCreateByTypeCode( CDType.All, RowCount, [K_crfSaveElemTypeRAFlag] );
        Inc(k);
      end;
  SetLength( RABuffer, k );

  for i := 0 to RowCount - 1 do begin
    iw := ToLogicRow(StartRow+i);
    k := 0;
    for j := 0 to ColCount - 1 do
      if not (K_racSeparator in RAFCArray[GLCNumbers[StartCol+j]].ShowEditFlags) then begin
        if RABuffer[k].ElemType.All > Ord(nptNotDef) then
          with RABuffer[k] do
            K_MoveSPLData(DataPointers[iw][ToLogicCol(StartCol+j)]^,
              P(i)^, ElemType, [K_mdfCopyRArray, K_mdfFreeDest] );
        Inc(k);
      end;
  end;
end; //*** end of function TK_FrameRAEdit.GetSelectionToRAArray

//**************************************** TK_FrameRAEdit.SetCellFromBData
// Set Grid Selection Data
//
procedure TK_FrameRAEdit.SetCellFromBData( var Data; DataType : TK_ExprExtType;
                                           LRow,  LCol : Integer; var DataSource );
var WDType : TK_ExprExtType;
begin
  with TK_RAArray(DataSource)[LCol] do begin
    WDType := ElemType;
//    if (WDType.All = DataType.All) then
    if ((WDType.All xor DataType.All) and K_ffCompareTypesMask ) = 0 then
      K_MoveSPLData( P(LRow)^, Data,
             WDType, [K_mdfCopyRArray, K_mdfFreeDest] );
  end;
end; //*** end of procedure TK_FrameRAEdit.SetCellFromBData

//**************************************** TK_FrameRAEdit.PasteRAArrayToSelection
// Set Grid Selection Data
//
function TK_FrameRAEdit.PasteRAArrayToSelection( PasteMode : TK_RAFPasteFromClipboardMode;
                     RABuffer: TK_RAArray ) : TK_RAFSetFromClipboardResult;
var
  DColCount, DRowCount : Integer;
begin
  Result := K_sdrNothingToDo;
  if K_ramReadOnly in CDescr.ModeFlags then Exit;
  DColCount := Length(RABuffer);
  if DColCount = 0 then Exit;
  DRowCount := RABuffer[0].ALength;
  Result := PasteDataToSelection( PasteMode, DColCount, DRowCount, RABuffer,
                       SetCellFromBData );
end; //*** end of function TK_FrameRAEdit.PasteRAArrayToSelection

//**************************************** TK_FrameRAEdit.SetCellFromText
// Set Grid Selection Data
//
procedure TK_FrameRAEdit.SetCellFromText( var Data; DataType : TK_ExprExtType;
                                           LRow,  LCol : Integer; var DataSource );
begin
  K_FreeSPLData( Data, DataType.All );
  K_SPLValueFromString( Data, DataType.All, TN_ASArray(DataSource)[LRow][LCol] );
end; //*** end of procedure TK_FrameRAEdit.SetCellFromText

//**************************************** TK_FrameRAEdit.PasteTextToSelection
// Set Grid Selection Data
//
function TK_FrameRAEdit.PasteTextToSelection( PasteMode : TK_RAFPasteFromClipboardMode;
                       Text: string ) : TK_RAFSetFromClipboardResult;
var
  DColCount, DRowCount : Integer;
  StrMatr: TN_ASArray;
  SL : TStrings;
begin
  Result := K_sdrNothingToDo;
  if K_ramReadOnly in CDescr.ModeFlags then Exit;

  SL := TStringList.Create;
  SL.Text := Text;
//  K_LoadSMatrFromStrings( StrMatr, SL, smfClip );
  K_LoadSMatrFromStrings( StrMatr, SL, smfTab );
  SL.Free;
  DRowCount := Length(StrMatr);
  if DRowCount = 0 then Exit;
  DColCount := Length(StrMatr[0]);
  Result := PasteDataToSelection( PasteMode, DColCount, DRowCount, StrMatr,
                       SetCellFromText );
end; //*** end of function TK_FrameRAEdit.PasteTextToSelection

//**************************************** TK_FrameRAEdit.PasteDataToSelection
// Set Grid Selection Data
//
function TK_FrameRAEdit.PasteDataToSelection( PasteMode : TK_RAFPasteFromClipboardMode;
                       DColCount, DRowCount : Integer; var DataSource;
                       SetDataFunc : TK_RAFSetDataFunc  ) : TK_RAFSetFromClipboardResult;
var
  StartRow, RowCount, StartCol, ColCount : Integer;
  RColCount, RRowCount : Integer;
  i, id, j, jd, iw, jw : Integer;
  PData : Pointer;
begin
  Result := K_sdrNothingToDo;
  if (K_ramReadOnly in CDescr.ModeFlags) or
     (DRowCount = 0) or
     (DColCount = 0) then Exit;
  Result := K_sdrOK;
  GetSelectSection( true, StartRow, RowCount );
  if RowCount = 0 then begin
    StartRow := 1;
    RowCount := Length(GLRNumbers) - 1;
  end;
  GetSelectSection( false, StartCol, ColCount );
  if ColCount = 0 then begin
    StartCol := 1;
    ColCount := Length(GLCNumbers) - 1;
  end;
  if K_sdmInsBeforeSelectedCols in PasteMode then begin
    if not (K_ramColAutoChangeNum in ModeFlags) then Exit;
    ColCount := DColCount;
    FrInsertCols( StartCol, ColCount );
  end else if not (K_sdmReplaceSelectedColsOnly in PasteMode) then begin
    ColCount := Length(GLCNumbers) - StartCol;
    if (DColCount > ColCount) then begin
      if (K_ramColAutoChangeNum in ModeFlags) and
         ( not Assigned(OnEnableDataMatrixEnlargeDlg) or
           OnEnableDataMatrixEnlargeDlg( true ) ) then begin
        FrInsertCols( 0, DColCount - ColCount );
        ColCount := DColCount;
      end else
        DColCount := ColCount;
    end else
      ColCount := DColCount;
  end else begin
    if not (K_sdmFillSelectedCols in PasteMode) then begin
      if not (K_ramColAutoChangeNum in ModeFlags) or
         (K_sdmFixSelectedColsNumber in PasteMode) then begin
        if DColCount < ColCount then
          ColCount := DColCount
      end else begin
        RColCount := DColCount - ColCount;
        if RColCount < 0 then
          FrDeleteCols( StartCol, -RColCount )
        else if RColCount > 0 then
          FrInsertCols( StartCol, RColCount );
        ColCount := DColCount;
      end;
    end;
  end;
  if K_sdmInsBeforeSelectedRows in PasteMode then begin
    if not (K_ramRowAutoChangeNum in ModeFlags) then Exit;
    RowCount := DRowCount;
    FrInsertRows( StartRow, RowCount );
  end else if not (K_sdmReplaceSelectedRowsOnly in PasteMode) then begin
    RowCount := Length(GLRNumbers) - StartRow;
    if (DRowCount > RowCount) then begin
      if (K_ramRowAutoChangeNum in ModeFlags) and
         ( not Assigned(OnEnableDataMatrixEnlargeDlg) or
           OnEnableDataMatrixEnlargeDlg( false ) ) then begin
        FrInsertRows( 0, DRowCount - RowCount );
        RowCount := DRowCount;
      end else
        DRowCount := RowCount;
    end else
      RowCount := DRowCount;
  end else begin
    if not (K_sdmFillSelectedRows in PasteMode) then begin
      if not (K_ramRowAutoChangeNum in ModeFlags) or
         (K_sdmFixSelectedRowsNumber in PasteMode) then begin
        if DRowCount < RowCount then
          RowCount := DRowCount;
      end else begin
        RRowCount := DRowCount - RowCount;
        if RRowCount < 0 then
          FrDeleteRows( StartRow, -RRowCount )
        else if RRowCount > 0 then
          FrInsertRows( StartRow, RRowCount );
        RowCount := DRowCount;
      end;
    end;
  end;
  id := 0;
  for i := StartRow to StartRow + RowCount - 1 do begin
    jd := 0;
//    iw := GLRNumbers[i];
    iw := ToLogicRow(i);
    for j := StartCol to StartCol + ColCount - 1 do begin
//      jw := GLCNumbers[j];
      jw := ToLogicCol(j);

      with RAFCArray[jw] do begin
        PData := DataPointers[iw][jw];
        if (PData <> nil)                       and
           not (K_racReadOnly in ShowEditFlags) and
           not (K_racSeparator in ShowEditFlags)and
           not (K_racSkipDataPaste in ShowEditFlags) then
          SetDataFunc( PData^, CDType, id, jd, DataSource );
      end;

      Inc(jd);
      if jd >= DColCount then jd :=0;
    end;
    Inc(id);
    if id >= DRowCount then id :=0;
  end;
  SelectLRect(  StartCol - 1, StartRow -1, StartCol + ColCount - 2, StartRow + RowCount - 2 );

end; //*** end of function TK_FrameRAEdit.PasteDataToSelection

//**************************************** TK_FrameRAEdit.CallEditorFromPopupExecute
// Set Grid Selection Data
//
procedure TK_FrameRAEdit.CallEditorFromPopupExecute(Sender: TObject);
begin
  FixCurEditorInd := TMenuItem(Sender).Tag;
  CallExtEditor;
end; //*** end of function TK_FrameRAEdit.CallEditorFromPopupExecute

//**************************************** TK_FrameRAEdit.BuildCurFieldEditActions
// Build Current Field Edit Actions
//
procedure TK_FrameRAEdit.BuildCurFieldEditActions;
var
  WA : TAction;
  SA : TAction;
  i, j, k : Integer;
  RAFE : TK_RAFEditor;
  DefaultEditorWasAddedFlag : Boolean;
  InlineEditorWasAddedFlag : Boolean;
  EditorClassName : string;
  PData : Pointer;
//  WDType : TK_ExprExtType;
  CurVEArray : TK_RAFCVEArray;

  //*******************
  //*** Create Actions
  //*******************
  procedure CreateAction( EditRuntimeIndex : Integer; HotKeyCode : Integer = -1 );
  var
    AddStr : string;
  begin
    WA := TAction.Create(Self);
    WA.Assign( SA );
    if (Integer(RAFE) > 10) and (SA = PopupCallEditor) then
      WA.Caption := EditorClassName;
    case HotKeyCode of
    0: AddStr := '   (Enter)';
    1: AddStr := '   (Shift+Enter )';
    2: AddStr := '   (Ctrl+Enter)';
    3: AddStr := '   (Shift+Ctrl+Enter)';
    else
      AddStr := '';
    end;
    WA.Caption := WA.Caption + AddStr;
    WA.OnExecute := CallEditorFromPopupExecute;
    WA.Tag := EditRuntimeIndex;
    CurFieldEActions[j] := WA;
    Inc(j);
  end;

  //******************************************
  //*** Add Editors Current Field Editors Array
  //******************************************
  procedure AddEditors( const RAFC : TK_RAFColumn; PData : Pointer );
  var
    kk : Integer;
    AddLength : Integer;
    Params : string;
    RAFEClass : TK_RAFEditorClass;
    CurEditor : TK_RAFEditor;
    DTCode : Integer;

    function IfEditorIsUsedInVEArray : Boolean;
    var i : Integer;
    begin
      Result := true;
      for i := 0 to High(CurVEArray) do
        with CurVEArray[i] do
          if (Integer(RAFEClass) <= 10) then begin
             if Integer(EObj) = Integer(RAFEClass) then Exit;
          end else if (Integer(EObj) > 10) and
             (EObj is RAFEClass) then Exit;
      Result := false;
    end;

    procedure AddEditor( EName : string );
    begin
      CurEditor := nil;
      if EName <> 'InlineEditor' then begin
        kk := K_RAFEditors.IndexOfName( EName );
        if kk <> -1 then
          RAFEClass := TK_RAFEditorClass(K_RAFEditors.Objects[kk]);
      end else
        Integer(RAFEClass) := 1;
      if not IfEditorIsUsedInVEArray then begin
        if Integer(RAFEClass) > 10 then begin
          CurEditor := RAFEClass.Create;
          CurEditor.RAFrame := Self;
        end else
          Integer(CurEditor) := Integer(RAFEClass);
        CurFieldRAFEditors[AddLength] := CurEditor;
        Inc(AddLength);
      end;
    end;

  begin
    K_FreeArrayObjects(CurFieldRAFEditors);
    AddLength := 0;
    SetLength( CurFieldRAFEditors, 5 );
    with RAFC do begin
      if (CDType.D.TFlags and K_ffArray) = 0 then begin
        if ( CDType.DTCode > Ord( nptNoData ) )        and
           ( CDType.FD.FDObjType = K_fdtEnum ) then begin
//          SetLength( CurFieldRAFEditors, 1 );
          AddEditor( 'RAFExtCmB' );
//          SetLength( CurFieldRAFEditors, AddLength );
        end else
          if CDType.D.TFlags = K_ffVArray then begin
//            SetLength( CurFieldRAFEditors, 2 );
            AddEditor( 'RAFVArrayEditor' );
            AddEditor( 'RAFUDRARef' );
            if CurEditor <> nil then begin
              Params := K_udpAbsPathCursorName;
              if (TN_PUDBase(PData)^ <> nil) and
                 not (TN_PUDBase(PData)^ is TN_UDBase) then
                DTCode := TK_PRArray(PData)^.ElemSType
              else
                DTCode := CDType.DTCode;
              if DTCode > 0 then
                Params := Params + ' ' + K_GetExecTypeName( DTCode );
              CurEditor.SetContext( Params );
            end;
            if (TN_PUDBase(PData)^ <> nil) and
               (TN_PUDBase(PData)^ is TN_UDBase) then
              AddEditor( 'NRAFUDRefEditor' );
          end else
          case CDType.DTCode of
            Ord(nptInt),  // Scalar Visual Editor
            Ord(nptFloat),
            Ord(nptDouble) : begin
//              SetLength( CurFieldRAFEditors, 2 );
              AddEditor( 'InlineEditor' );
              AddEditor( 'NScalVEditor' );
            end; // Scalar Visual Editor

            Ord(nptIPoint), // Point Visual Editor
            Ord(nptFPoint),
            Ord(nptDPoint) : begin
//              SetLength( CurFieldRAFEditors, 2 );
              AddEditor( 'InlineEditor' );
              AddEditor( 'NPointVEditor' );
            end; // Point Visual Editor

            Ord(nptIRect), // Rect Visual Editor
            Ord(nptFRect),
            Ord(nptDRect) : begin
//              SetLength( CurFieldRAFEditors, 2 );
              AddEditor( 'InlineEditor' );
              AddEditor( 'NRectVEditor' );
            end; // Rect Visual Editor

            Ord(nptColor) : begin // Color Visual Editor
//              SetLength( CurFieldRAFEditors, 2 );
              AddEditor( 'NRAFColorVEditor' );
              AddEditor( 'RAFColorEditor' );
            end; // Color Visual Editor

            Ord(nptString) : begin // String Visual Editor
//              SetLength( CurFieldRAFEditors, 2 );
              AddEditor( 'InlineEditor' );
              AddEditor( 'RAFSArrEditor' );
            end; // String Visual Editor

            Ord(nptUDRef) : begin // Select UDReference Visual Editor
//              SetLength( CurFieldRAFEditors, 2 );
              AddEditor( 'RAFUDRef' );
              if CurEditor <> nil then begin
                Params := K_udpAbsPathCursorName;
                CurEditor.SetContext( Params );
              end;
              AddEditor( 'NRAFUDRefEditor' );
            end; // Select UDReference Visual Editor
          end;
      end;
    end;
    SetLength( CurFieldRAFEditors, AddLength );
 end;


begin

  K_FreeArrayObjects(CurFieldEActions);

  GetPointerToCellData();
  if PEditData = nil then
    CurFieldEActions := nil
  else
    with RAFCArray[CurLPos.Col] do begin
      CurVEArray := VEArray;
    //*** Add Actions according to VEArray
      SetLength( CurFieldEActions, Length(CurVEArray) );
      j := 0;
      DefaultEditorWasAddedFlag := false;
      InlineEditorWasAddedFlag := false;
      for i := 0 to High(CurVEArray) do begin
        RAFE := CurVEArray[i].EObj;
        SA := PopupCallEditor;
        if not Assigned(RAFE) then begin
          if not (K_racExternalEditor in ShowEditFlags) or
            DefaultEditorWasAddedFlag or
            InlineEditorWasAddedFlag then Continue;
          DefaultEditorWasAddedFlag := true;
        end else if Integer(RAFE) = 1 then begin
          if InlineEditorWasAddedFlag then Continue;
          InlineEditorWasAddedFlag := true;
          SA := PopupCallInlineEditor;
        end else if Integer(RAFE) = 2 then Continue
        else begin
          EditorClassName := RAFE.ClassName;
          with N_ButtonsForm.RAFEditorsActionList do
            for k := 0 to ActionCount - 1 do begin
              if Actions[k].Name <> EditorClassName then Continue;
              SA := TAction(Actions[k]);
              break;
            end;
        end;
        CreateAction(i,i);
      end;

      PData := DataPointers[CurLPos.Row][CurLPos.Col];
     //*** Add Additional Default Edit Actions
      AddEditors( RAFCArray[CurLPos.Col], PData );
      i := j + Length(CurFieldRAFEditors) - Length(CurFieldEActions);
      if i > 0 then
        SetLength( CurFieldEActions, Length(CurFieldEActions) + i );
      for i := 0 to High(CurFieldRAFEditors) do begin
        SA := PopupCallEditor;
        RAFE := TK_RAFEditor(CurFieldRAFEditors[i]);
        if Integer(RAFE) = 1 then
          SA := PopupCallInlineEditor
        else begin
          EditorClassName := RAFE.ClassName;
          with N_ButtonsForm.RAFEditorsActionList do
            for k := 0 to ActionCount - 1 do begin
              if Actions[k].Name <> EditorClassName then Continue;
              SA := TAction(Actions[k]);
              break;
            end;
        end;
        CreateAction(i + 100);
      end;

      //*** Add Default Attributes Edit Action
      if ((CDType.D.TFlags and K_ffArray) <> 0) and
         (CurLPos.Row >= 0) then begin
        if (TK_PRArray(PData)^ <> nil) then begin
//          WDType := TK_PRArray(PData)^.AttrsType;
//          if WDType.DTCode > 0 then begin
          if TK_PRArray(PData)^.AttrsSType > 0 then begin
            SA := PopupCallAttrsEditor;
            i := Length(CurVEArray);
            CreateAction( i );
          end;
        end;
      end;


      SetLength( CurFieldEActions, j );
    end;
end; //*** end of procedure TK_FrameRAEdit.BuildCurFieldEditActions

//**************************************** TK_FrameRAEdit.MarkAllRowsExecute
//
procedure TK_FrameRAEdit.MarkAllRowsExecute(Sender: TObject);
var
  LRow, i : Integer;
begin
  if MarkedLRowsList = nil then
    MarkedLRowsList := TList.Create;
  for i := 1 to High(GLRNumbers) do begin
    LRow := GLRNumbers[i];
    if not RowMarks[LRow] then
      ToggleLRowMark( LRow );
  end;
end; //*** end of procedure TK_FrameRAEdit.MarkAllRowsExecute

//**************************************** TK_FrameRAEdit.ReverseRowsMarkExecute
//
procedure TK_FrameRAEdit.ReverseRowsMarkExecute(Sender: TObject);
var
 i : Integer;
begin
  if MarkedLRowsList = nil then
    MarkedLRowsList := TList.Create;
  for i := 1 to High(GLRNumbers) do
    ToggleLRowMark( GLRNumbers[i] );
end; //*** end of procedure TK_FrameRAEdit.ReverseRowsMarkExecute

//**************************************** TK_FrameRAEdit.MarkAllColsExecute
//
procedure TK_FrameRAEdit.MarkAllColsExecute(Sender: TObject);
var
  LCol, i : Integer;
begin
  if MarkedLColsList = nil then
    MarkedLColsList := TList.Create;
  MarkedLColsList.Clear;
  for i := 1 to High(GLCNumbers) do begin
    LCol := GLCNumbers[i];
    if not RAFCArray[LCol].Marked then
      ToggleLColMark( LCol );
  end;
end; //*** end of procedure TK_FrameRAEdit.MarkAllColsExecute

//**************************************** TK_FrameRAEdit.ReverseColsMarkExecute
//
procedure TK_FrameRAEdit.ReverseColsMarkExecute(Sender: TObject);
var
  i : Integer;
begin
  if MarkedLColsList = nil then
    MarkedLColsList := TList.Create;
  for i := 1 to High(GLCNumbers) do begin
    ToggleLColMark( GLCNumbers[i] );
  end;
end; //*** end of procedure TK_FrameRAEdit.ReverseColsMarkExecute

{*** end of TK_FrameRAEdit ***}


{*** TK_RAFEditor ***}

constructor TK_RAFEditor.Create;
begin
end;

//**************************************** TK_RAFEditor.SetContext
//
//
procedure TK_RAFEditor.SetContext( const Data );
begin
end; //*** procedure TK_RAFEditor.SetContext

//**************************************** TK_RAFEditor.Edit
//  External Editor Call
//
function TK_RAFEditor.Edit( var Data ) : Boolean;
var
  AModeFlags : TK_RAModeFlagSet;
  WCDescr : TK_RAFrDescr;
  GEInd : Integer;
  GEName : string;
  CellDisabled : TK_RAFDisabled;
  PGCont : Pointer;
  RFC : TK_RAEditFuncCont;
  WDType : TK_ExprExtType;
  PData : Pointer;
  EditRAAttrs : Boolean;
{
  procedure PrepRFC( PRFC : TK_PRAEditFuncCont );
  begin
    with TK_PRAEditFuncCont(PRFC)^, RAFrame, RAFCArray[CurLCol] do begin
      FRLSData   := RLSData;
      FDataPath  := GetCurCellDataPath;
      FDType     := WDType;
      FDataCapt  := Caption;
      if EditRAAttrs then begin
        FDataCapt := FDataCapt + K_sccRecFieldDelim + K_sccVarFieldDelim;
        FDataPath := FDataPath + K_sccRecFieldDelim + K_sccVarFieldDelim;
      end;
      FModeFlags := AModeFlags;
      FPCDescr   := @WCDescr;
      FRAFrame   := RAFrame;
      FOnGlobalAction := RAFGlobalAction;
      FOwner := AOwner;
      FGEDataIDPrefix := Name;
      with VEArray[CVEInd] do begin
        FSEInds := SEInds;
        FGEDataID := EEID;
      end;
      FNotModalShow := K_racNotModalShow in ShowEditFlags;
      if Assigned(OnCellExtEditing) then OnCellExtEditing( PRFC );
    end;
  end;
}
  procedure PrepRFC( PRFC : TK_PRAEditFuncCont );
  begin
    with TK_PRAEditFuncCont(PRFC)^, RAFrame, RAFCArray[CurLCol] do begin
      PrepEditFuncContext( PRFC );
      FDType     := WDType;
      if EditRAAttrs then begin
        FDataCapt := FDataCapt + K_sccRecFieldDelim + K_sccVarFieldDelim;
        FDataPath := FDataPath + K_sccRecFieldDelim + K_sccVarFieldDelim;
      end;
      FSetModeFlags := AModeFlags;
      FPCDescr   := @WCDescr;
      if Assigned(OnCellExtEditing) then OnCellExtEditing( PRFC );
    end;
  end;

begin
  PData := @Data;
  EditRAAttrs := false;
  with RAFrame, RAFCArray[CurLCol] do begin
//      WDType := K_GetExecTypeBaseCode(CDType);
    WDType := CDType;
    if (WDType.D.TFlags and K_ffVArray) <> 0 then begin
      PData := K_GetPVRArray( Data );
      if PData = @Data then
        WDType.D.TFlags := WDType.D.TFlags xor (K_ffVArray or K_ffArray)
      else
        PData := @Data
    end;
    // Check if only attributes in RArray;
    if (WDType.D.TFlags and K_ffArray) <> 0 then begin
      if  (TK_PRArray(PData)^ <> nil) then begin
        WDType := TK_PRArray(PData).ArrayType;
        if (FixCurEditorInd = Length(VEArray)) then begin
          WDType := TK_PRArray(PData)^.AttrsType;
          PData :=  TK_PRArray(PData)^.PA;
          EditRAAttrs := true;
        end;
      end;
      if WDType.DTCode = Ord(nptNotDef) then begin
        WDType.DTCode := Ord(nptByte);
        K_SelectRecordTypeCode( WDType.DTCode, 'Select Data Type' );
      end;
    end;

    CellDisabled := GetCellEnableState( CurLCol, CurLRow );
    K_MoveSPLData( CDescr, WCDescr, K_GetFormCDescrDType );
    WCDescr.ModeFlags := WCDescr.ModeFlags - [K_ramColChangeNum,K_ramColAutoChangeNum];
    AModeFlags := ModeFlags + [K_ramFillFrameWidth] - [K_ramColChangeNum,K_ramColAutoChangeNum];
    if MatrixModeDataPath then begin
      AModeFlags := ModeFlags - [K_ramShowLColNumbers];
      WCDescr.ModeFlags := WCDescr.ModeFlags - [K_ramShowLColNumbers];
    end;
    if (WDType.D.TFlags and K_ffArray) <> 0 then
    begin
      AModeFlags := AModeFlags + [K_ramShowLRowNumbers,K_ramRowChangeOrder,K_ramRowChangeNum,K_ramRowAutoChangeNum];
      if not (K_ramManualColOrient in AModeFlags) then
      begin
        if (TK_PRArray(PData)^.ALength > 1) or
           ( (TK_PRArray(PData)^ <> nil)        and
             (TK_PRArray(PData)^.AttrsSize > 0) and
             (TK_PRArray(PData)^.ElemSize > 0) ) then
        begin
          AModeFlags := AModeFlags + [K_ramColVertical];
          WCDescr.ModeFlags := WCDescr.ModeFlags + [K_ramColVertical];
        end else
        begin
          AModeFlags := AModeFlags - [K_ramColVertical];
          WCDescr.ModeFlags := WCDescr.ModeFlags - [K_ramColVertical];
        end;
      end;
    end else
    begin
      AModeFlags := AModeFlags - [K_ramShowLRowNumbers];
      WCDescr.ModeFlags := WCDescr.ModeFlags - [K_ramShowLRowNumbers];
      if not (K_ramManualColOrient in AModeFlags) then
      begin
        AModeFlags := AModeFlags - [K_ramColVertical];
        WCDescr.ModeFlags := WCDescr.ModeFlags - [K_ramColVertical];
      end;
    end;
    if CellDisabled <> K_rfdEnabled then
    begin
      AModeFlags := AModeFlags + [K_ramCDisabled,K_ramSkipRowMoving];
      AModeFlags := AModeFlags - [K_ramRowChangeOrder,K_ramRowChangeNum,K_ramRowAutoChangeNum];
      WCDescr.ModeFlags := WCDescr.ModeFlags -
                          [K_ramRowChangeOrder,K_ramRowChangeNum,K_ramRowAutoChangeNum];
    end;

    if K_racSkipRowChangeNum in ShowEditFlags then begin
      AModeFlags := AModeFlags - [K_ramRowChangeNum,K_ramRowAutoChangeNum];
      WCDescr.ModeFlags := WCDescr.ModeFlags -
                          [K_ramRowChangeNum,K_ramRowAutoChangeNum];
    end;

    if K_racSkipRowEditing in ShowEditFlags then
    begin
      AModeFlags := AModeFlags - [K_ramRowChangeOrder];
      WCDescr.ModeFlags := WCDescr.ModeFlags - [K_ramRowChangeOrder];
    end;

    if K_racUseExtEditArchChange in ShowEditFlags then
      AModeFlags := AModeFlags + [K_ramUseExtEditArchChange];

// Define GE Name
    with VEArray[CVEInd] do begin
      GEName := VEArray[0].EEID;
      if EEID = '' then begin
        if GEName = '' then
          GEName := K_GetExecTypeName(WDType.All);
        if CVEInd > 0 then
          GEName := GEName + IntToStr(CVEInd);
      end else
        GEName := EEID;
    end;
    GEInd := K_GetGEFuncIndex( GEName, Name );

    if GEInd >= 0 then begin
      PGCont := K_GEFPConts.Items[GEInd];
      if PGCont <> nil then PrepRFC( PGCont );
      K_EditByGEFuncInd( GEInd, PData^, Result );
    end else begin
      K_ClearRAEditFuncCont( @RFC );
      PrepRFC( @RFC );
      Result := K_EditRADataFunc( PData^, @RFC );
    end;
  end;
end; //*** procedure TK_RAFEditor.Edit


//**************************************** TK_RAFEditor.CanUseEditor
//  Test if External Editor will edit Cell Data
//
function TK_RAFEditor.CanUseEditor( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean;
begin
 Result := false;
 if Self <> nil then Result := true;
end; //*** procedure TK_RAFEditor.CanUseEditor

//**************************************** TK_RAFEditor.Hide
//  Hide Editor Controls
//
procedure TK_RAFEditor.Hide;
begin
end; //*** procedure TK_RAFEditor.Hide;

{*** end of TK_RAFEditor ***}

{*** TK_RAFViewer ***}

//**************************************** TK_RAFViewer.Create
//
constructor TK_RAFViewer.Create;
begin

end; //*** TK_RAFViewer.Create

//**************************************** TK_RAFViewer.DrawCell
//
//
procedure TK_RAFViewer.DrawCell( var Data; var RAFC : TK_RAFColumn;
                                ACol, ARow : Integer; Rect: TRect;
                                State: TGridDrawState; ACanvas : TCanvas );
var
  wstr : string;
  x1, y1, x2, y2 : Integer;
  BrushSave : TBrushRecall;
  PenSave   : TPenRecall;
  FontSave  : TFontRecall;
  ShowCheckBox : Boolean;
  w2 : Integer;
//  EnumBuf : Integer;
//  WC : Integer;
//  RC : Double;
  HTextPos, VTextPos : TK_CellPos;
  FFillColor : Integer;
  FFrontColor : Integer;
begin

  with RAFC do begin

    BrushSave := nil;
    PenSave   := nil;
    FontSave  := nil;

    FFillColor := ACanvas.Brush.Color;
    if ( (K_ramUseFillColor in RAFrame.CDescr.ModeFlags) or
         (K_racUseFillColor in ShowEditFlags) ) and
       (CFillColor >= 0) then begin
      BrushSave := TBrushRecall.Create( ACanvas.Brush );
      ACanvas.Brush.Color := CFillColor;
      FFillColor := CFillColor;
    end;

//!!!
    FFrontColor := CFontColor;
    if CFontColor = -1 then begin
      FFrontColor := K_GetContrastColor( CFillColor );
{
      WC := Integer(CFillColor) and $FF;
      WC := WC + ((Integer(CFillColor) shr 8) and $FF);
      WC := WC + ((Integer(CFillColor) shr 16) and $FF);
      RC := WC/(255*3);
      if RC > 0.66 then
        FFrontColor := 0
      else
        FFrontColor := $FFFFFF;
}
    end;

    N_HDCRectDraw( ACanvas.Handle, Rect, ColorToRGB(FFillColor) );
    ShowCheckBox := (K_racShowCheckBox in ShowEditFlags) and
                    ( @Data <> nil ) and
                    ( (Integer(Data) and BitMask) <> 0 );
    if ShowCheckBox or ( BorderWidth <> 0 ) then
      PenSave := TPenRecall.Create( ACanvas.Pen );

    if BorderWidth <> 0 then begin
    // Column Border
      w2 := Round( BorderWidth / 2 );
      x2 := Rect.Right - w2;
      y2 := Rect.Bottom - w2;
      if K_ramColVertical in RAFrame.CDescr.ModeFlags then begin
        x1 := x2;
        y1 := Rect.Top;
      end else begin
        x1 := Rect.Left;
        y1 := y2;
      end;
      ACanvas.Pen.Width := BorderWidth;
      ACanvas.Pen.Color := BorderColor;
      ACanvas.MoveTo(x1, y1);
      ACanvas.LineTo(x2, y1);
    end;

    if K_racShowCheckBox in ShowEditFlags then begin
      if ShowCheckBox then begin //*** Show Check Box
{!!!
        FFrontColor := ACanvas.Font.Color;
        if CFontColor <> -1 then
          FFrontColor := CFontColor;
}
        x1 := Round( (Rect.Left + Rect.Right)/2 );
        y1 := Rect.Bottom - 4;
        ACanvas.Pen.Width := 2;
        ACanvas.Pen.Color := FFrontColor;
        ACanvas.MoveTo(x1, y1);
        ACanvas.LineTo(x1 - 3, y1 - 6);
        ACanvas.MoveTo(x1, y1);
        ACanvas.LineTo(x1 + 5, y1 - 10);
      end;
    end else begin
      HTextPos := TK_CellPos(TextPos and $F);
      VTextPos := TK_CellPos(TextPos shr 4);
      if VTextPos = K_ppUndef then
        VTextPos := K_ppCenter;
      if HTextPos = K_ppUndef then begin
        if ( (CDType.D.TFlags and (K_ffFlagsMask)) <> 0 ) or
           ( CDType.DTCode = Ord(nptInt) )   or
           ( CDType.DTCode = Ord(nptByte) )  or
           ( CDType.DTCode = Ord(nptHex) )   or
           ( CDType.DTCode = Ord(nptColor) ) or
           ( CDType.DTCode = Ord(nptInt1) )  or
           ( CDType.DTCode = Ord(nptInt2) )  or
           ( CDType.DTCode = Ord(nptUInt2) ) or
           ( CDType.DTCode = Ord(nptUInt4) ) or
           ( CDType.DTCode = Ord(nptInt64) ) or
           ( CDType.DTCode = Ord(nptDouble) )or
           ( CDType.DTCode = Ord(nptFloat) ) then
          HTextPos := K_ppDownRight
        else
          HTextPos := K_ppUpLeft;
      end;

      wstr := GetText(Data, RAFC, ACol, ARow, @HTextPos );
      if (CFontColor <> -1) or
         ( not (K_racNoText in RAFC.ShowEditFlags) and
         (BrushSave <> nil) ) then begin
        FontSave := TFontRecall.Create( ACanvas.Font );
        if (CFontColor <> -1) and not (gdSelected in State) then
          ACanvas.Font.Color := CFontColor
        else begin
          ACanvas.Font.Color := FFrontColor;
{!!!
          WC := Integer(CFillColor) and $FF;
          WC := WC + ((Integer(CFillColor) shr 8) and $FF);
          WC := WC + ((Integer(CFillColor) shr 16) and $FF);
          RC := WC/(255*3);
          if RC > 0.66 then
            ACanvas.Font.Color := 0
          else
            ACanvas.Font.Color := $FFFFFF;
}
        end;
      end;
      with N_ButtonsForm do
        if TextShift <> 0 then
          IconsList.Draw( ACanvas, Rect.Left + 1,
              Rect.Top + (Rect.Bottom - Rect.Top - IconsList.Height) shr 1, IconInd);
      Rect.Left := Rect.Left + TextShift;
      K_CellDrawString( WStr, Rect, HTextPos, VTextPos, ACanvas, RAFrame.LRPadding );
    end;
  end;
  BrushSave.Free;
  PenSave.Free;
  FontSave.Free;

end; //*** procedure TK_RAFViewer.DrawCell

//**************************************** TK_RAFViewer.GetText
//
//
function TK_RAFViewer.GetText( var Data; var RAFC : TK_RAFColumn;
           ACol, ARow : Integer; PHTextPos : Pointer = nil ): string;
var
  EnumBuf : Integer;
  wstr : string;
  PData : Pointer;

  function PrepareUDrefShow : string;
  begin
    Result := RAFrame.DefaultRAFUDViewer.GetText( Data, RAFC,
                                        ACol, ARow, PHTextPos );
//    TextShift := RAFrame.DefaultRAFUDViewer.TextShift;
    IconInd := RAFrame.DefaultRAFUDViewer.IconInd;
  end;

begin
  TextShift := 0;
  IconInd := 0;
  with RAFC do begin
    if (K_racSeparator in ShowEditFlags)    or
       (K_racShowCheckBox in ShowEditFlags) or
       (K_racNoText in ShowEditFlags)       or
       (@Data = nil) then
      Result := ''
    else begin
      if UseTextVal then
        Result := TextVal
      else begin
        if ( CDType.DTCode > Ord(nptNoData) )          and
           ( (CDType.D.TFlags and K_ffFlagsMask) = 0 ) and
           ( Ord(CDType.FD.FDObjType) >= Ord(K_fdtEnum) ) then begin
          EnumBuf := 0;
          with CDType.FD do begin
            Move( Data, EnumBuf, FDRecSize );
            if FDObjType = K_fdtEnum then
              Result := GetFieldUName(EnumBuf) //V[EnumBuf].FieldDefValue
            else begin // Set
//              Result := RAFrame.GetDataText( Data, CDType );
              if K_FieldIsEmpty( @Data, FDRecSize ) then
                Result := '[]'
              else
                Result := '[...]';
            end;
          end;
        end else begin
          if ( (CDType.DTCode < Ord(nptNoData)) and
               ((CDType.D.TFlags and (K_ffArray or K_ffVArray)) = 0) ) or
             (K_racShowRecValue in ShowEditFlags) then
            if (CDType.DTCode = Ord(nptUDRef)) and
               not (K_racShowRecValue in ShowEditFlags) then
              Result := PrepareUDRefShow
            else
              Result := RAFrame.GetDataText( Data, CDType, Fmt )
          else begin
            if PHTextPos <> nil then
              TK_CellPos((PHTextPos)^) := K_ppDownRight;
            if K_racShowRecType in ShowEditFlags then
              Result := '('+(K_GetExecTypeName(CDType.All))+')';
            Result := Result + ' ...';
            PData := @Data;
            if CDType.D.TFlags = K_ffVArray then
              PData := K_GetPVRArray( Data );
            if (CDType.D.TFlags and (K_ffArray or K_ffVArray)) <> 0 then begin
              if (PData <> nil) and (TK_PRArray(PData)^ <> nil) then
                with TK_PRArray(PData)^ do begin
                  if HCol = 0 then
                    wstr := IntToStr( ALength )
                  else
                    wstr := IntToStr( HCol + 1 )+','+IntToStr( ARowCount );
                end
              else
                wstr := ' ';
              Result := Result + ' ('+ wstr +')';
              if CDType.D.TFlags = K_ffVArray then begin
                Result := Result + ' ^';
                if PData <> @Data then
                  Result := PrepareUDrefShow  + ' -> ' + Result;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  SetTextShift;
end; //*** function TK_RAFViewer.GetText

//**************************************** TK_RAFViewer.SetTextShift
//
//
procedure TK_RAFViewer.SetTextShift;
begin
  with N_ButtonsForm do begin
    TextShift := 0;
    if (IconInd > 0)        and
       (IconsList <> nil)  and
       (IconInd < IconsList.Count) then
      TextShift := IconsList.Width + 2
  end;
end; //*** function TK_RAFViewer.SetTextShift

//**************************************** TK_RAFViewer.SetContext
//
//
procedure TK_RAFViewer.SetContext( const Data );
begin
  UseTextVal := false;
end; //*** procedure TK_RAFViewer.SetContext

//**************************************** TK_RAFViewer.IfUseViewer
//  Test if External Editor will edit Cell Data
//
function TK_RAFViewer.IfUseViewer( ACol, ARow : Integer; var RAFC : TK_RAFColumn ) : Boolean;
begin
 if Self = nil then Result := false
 else               Result := true;
end; //*** procedure TK_RAFViewer.IfUseViewer

{*** end of TK_RAFViewer ***}


//*************************************** K_PrepColumnVEAttrs
//
function K_PrepColumnVEAttrs( UseDefEditor : Boolean ) : TK_RAFCVEArray;
var
 VEAttrs : TK_RAFColVEAttrs;
 i : Integer;
begin
  SetLength( Result, 4 );
  FillChar( VEAttrs, SizeOf(TK_RAFColVEAttrs), 0 );
  with VEAttrs do begin
    EObj := nil;
    if not UseDefEditor then // Set Inline Editor Flag
      Integer(EObj) := 1;
  end;
  for i := 0 to 3 do
    Result[i] := VEAttrs;
  Integer(Result[3].EObj) := 1;
end; //*** end of function K_PrepColumnVEAttrs


//*************************************** K_RAFColumnEditDefInit ***
// RAF Column Editors Default Init
//
procedure K_RAFColumnEditDefInit( var RAFC : TK_RAFColumn );
var
  kk : Integer;
  AddExtEDFlags : Boolean;
  Params : string;
  Ind : Integer;

begin
  AddExtEDFlags := false;
  with RAFC do begin
    if (CDType.D.TFlags and K_ffArray) = 0 then begin
      if ( CDType.DTCode > Ord( nptNoData ) )        and
         ( CDType.FD.FDObjType = K_fdtEnum ) then begin
        kk := K_RAFEditors.IndexOfName( 'RAFExtCmB' );
        if kk = -1 then Exit;
        AddExtEDFlags := true;
        VEArray[0].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
      end else
        if CDType.D.TFlags = K_ffVArray then begin
          kk := K_RAFEditors.IndexOfName( 'RAFUDRARef' );
          if kk = -1 then Exit;
          VEArray[0].EObj := nil;
          AddExtEDFlags := true;
          VEArray[1].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
          Params := K_udpAbsPathCursorName;
          if CDType.DTCode > 0 then
            Params := Params + ' ' + K_GetExecTypeName( CDType.DTCode );
          VEArray[1].EObj.SetContext( Params );
        end else
        case CDType.DTCode of
          Ord(nptInt),  // Scalar Visual Editor
          Ord(nptFloat),
          Ord(nptDouble) : begin
            VEArray[0].EObj := TK_RAFEditor(1);
            kk := K_RAFEditors.IndexOfName( 'NScalVEditor' );
            if kk = -1 then Exit;
            AddExtEDFlags := true;
            VEArray[1].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
          end; // Scalar Visual Editor

          Ord(nptIPoint), // Point Visual Editor
          Ord(nptFPoint),
          Ord(nptDPoint) : begin
            VEArray[0].EObj := TK_RAFEditor(1);
            kk := K_RAFEditors.IndexOfName( 'NPointVEditor' );
            if kk = -1 then Exit;
            AddExtEDFlags := true;
            VEArray[1].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
          end; // Point Visual Editor

          Ord(nptIRect), // Rect Visual Editor
          Ord(nptFRect),
          Ord(nptDRect) : begin
            VEArray[0].EObj := TK_RAFEditor(1);
            kk := K_RAFEditors.IndexOfName( 'NRectVEditor' );
            if kk = -1 then Exit;
            AddExtEDFlags := true;
            VEArray[1].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
          end; // Rect Visual Editor

          Ord(nptColor) : begin // Color Visual Editor
            Ind := 0;
            kk := K_RAFEditors.IndexOfName( 'NRAFColorVEditor' );
            if kk <> -1 then begin
              VEArray[0].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
              AddExtEDFlags := true;
              Ind := 1;
            end;
            kk := K_RAFEditors.IndexOfName( 'RAFColorEditor' );
            if kk <> -1 then begin
              AddExtEDFlags := true;
              VEArray[Ind].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
            end;
          end; // Color Visual Editor

          Ord(nptString) : begin // String Visual Editor
            Ind := 1;
            kk := K_RAFEditors.IndexOfName( 'RAFSArrEditor' );
            if kk <> -1 then begin
              VEArray[Ind].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
              Inc(Ind);
              AddExtEDFlags := true;
            end;

            kk := K_RAFEditors.IndexOfName( 'NRAFCharCodesEditor' );
            if kk <> -1 then begin
              VEArray[Ind].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
              AddExtEDFlags := true;
            end;
          end; // String Visual Editor

          Ord(nptUDRef) : begin // Select UDReference Visual Editor
            Ind := 0;
            kk := K_RAFEditors.IndexOfName( 'RAFUDRef' );
            if kk <> -1 then begin
              AddExtEDFlags := true;
              VEArray[0].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
              Params := K_udpAbsPathCursorName;
              VEArray[0].EObj.SetContext( Params );
              Ind := 1;
            end;
            kk := K_RAFEditors.IndexOfName( 'NRAFUDRefEditor' );
            if kk <> -1 then
              VEArray[Ind].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
          end; // Select UDReference Visual Editor

          Ord(nptTDateTime),
          Ord(nptTDate) : begin // Select TDate Visual Editor
            kk := K_RAFEditors.IndexOfName( 'RAFDateTimePicEditor' );
            if kk <> -1 then begin
              AddExtEDFlags := true;
              VEArray[0].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
              VEArray[1].EObj := TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create;
              Params := 'DateMode=0';
              VEArray[1].EObj.SetContext( Params );
            end;
          end; // Select TDate Visual Editor
        end;
    end;
    if AddExtEDFlags then
      Include( ShowEditFlags, K_racExternalEditor ); // External Flags
  end;
end;

//*************************************** K_RAFColumnViewDefInit ***
// RAF Column Viewrs Default Init
//
procedure K_RAFColumnViewDefInit( var RAFC : TK_RAFColumn );
var
  kk : Integer;
  Params : string;

  procedure SetFontViewerIfNeeded;
  begin
    with RAFC do
      if CDType.DTCode = N_SPLTC_NFont then begin
        kk := K_RAFViewers.IndexOfName( 'RAFNFontViewer' );
        if kk = -1 then Exit;
        VEArray[0].VObj := TK_RAFViewerClass(K_RAFViewers.Objects[kk]).Create;
      end;
  end;
begin
// RAFNFontViewer
  with RAFC do begin
    if (CDType.D.TFlags and K_ffArray) <> 0 then
      case CDType.DTCode of
          Ord(nptColor) : begin
          kk := K_RAFViewers.IndexOfName( 'RAFColorArray' );
          if kk = -1 then Exit;
          VEArray[0].VObj := TK_RAFViewerClass(K_RAFViewers.Objects[kk]).Create;
        end;
      else
        SetFontViewerIfNeeded();
      end // end of Case
    else if (CDType.D.TFlags and K_ffArray) <> 0 then
      SetFontViewerIfNeeded()
    else
      case CDType.DTCode of
          Ord(nptColor) : begin
          kk := K_RAFViewers.IndexOfName( 'RAFColorViewer' );
          if kk = -1 then Exit;
          VEArray[0].VObj := TK_RAFViewerClass(K_RAFViewers.Objects[kk]).Create;
        end;
        Ord(nptUDRef) : begin
          kk := K_RAFViewers.IndexOfName( 'RAFUDRefV1' );
          if kk = -1 then Exit;
          VEArray[0].VObj := TK_RAFViewerClass(K_RAFViewers.Objects[kk]).Create;
          Params := K_udpAbsPathCursorName;
          VEArray[0].VObj.SetContext( Params );
        end;
      end; // end of Case
  end;
end;

//*************************************** K_RAFColumnDefInit ***
// RAF Column Default Init
//
procedure K_RAFColumnDefInit( var RAFC : TK_RAFColumn; DataType : TK_ExprExtType;
                              ModeFlags : TK_RAModeFlagSet; SingleColum : Boolean );
begin
  with RAFC do begin
    MaxCWidth := 0;
    BorderWidth := 0;
    CFillColor := -1;
    BitMask := 0;
    CFontColor := -1;
    CDType := DataType;
//    if ( (CDType.D.TFlags and K_ffArray) <> 0 ) or
//       ( (CDType.DTCode > Ord(nptNoData)) and
//         ((CDType.D.TFlags and not K_ffEnumSet) = 0) ) then
    if ( (CDType.D.TFlags and K_ffArray) <> 0 ) or
         ( (CDType.DTCode > Ord(nptNoData)) and
           ((CDType.D.TFlags and (K_ffFlagsMask or K_ffArray)) = 0) ) then
      Include( ShowEditFlags, K_racExternalEditor ); // External Flags    end;
    VEArray := K_PrepColumnVEAttrs( K_racExternalEditor in ShowEditFlags  );
    if SingleColum                         and
       (DataType.DTCode < Ord(nptNoData))  and
       (DataType.D.TFlags = 0)             and
       (K_ramShowCheckBox in ModeFlags) then
      Include( ShowEditFlags, K_racShowCheckBox ); // Show/Edit Flags
    K_RAFColumnViewDefInit( RAFC );
    if (K_ramReadOnly in ModeFlags)               or
       ((CDType.D.TFlags and K_ffFlagsMask) <> 0) then
      Include( ShowEditFlags, K_racReadOnly ) // Show/Edit Flags
    else begin
      K_RAFColumnEditDefInit( RAFC );
    end;
  end;
end;

//*************************************** K_RAFColPrepByDataType ***
// RAF Prepare Self Type Column
//
procedure K_RAFColPrepByDataType( var RAFC : TK_RAFColumn;
                     ModeFlags : TK_RAModeFlagSet; DDType : TK_ExprExtType );
begin
  with RAFC do begin
    MaxCWidth := 0;
    CDType := DDType;
    CDType.D.TFlags := CDType.D.TFlags and not K_ffArray;
    CDType := K_GetExecTypeBaseCode( CDType );
    Name := K_GetExecTypeName(CDType.All);
//    Caption := Name;
    VEArray := K_PrepColumnVEAttrs( DDType.DTCode > Ord( nptNoData ) );
    K_RAFColumnViewDefInit( RAFC );
    K_RAFColumnEditDefInit( RAFC );
    if (CDType.DTCode < Ord(nptNoData))  and
       (CDType.D.TFlags = 0)             and
       (K_ramShowCheckBox in ModeFlags) then
      Include( ShowEditFlags, K_racShowCheckBox ); // Show/Edit Flags
//    if ((CDType.D.TFlags and (K_ffArray or K_ffVArray )) <> 0) or
    if ((CDType.D.TFlags and K_ffArray ) <> 0) or
       (CDType.DTCode > Ord( nptNoData )) then
      Include( ShowEditFlags, K_racExternalEditor ); // Show/Edit Flags
    if (K_ramReadOnly in ModeFlags)               or
       ((CDType.D.TFlags and K_ffFlagsMask) <> 0) then
      Include( ShowEditFlags, K_racReadOnly ); // Show/Edit Flags
    if (K_ramCDisabled in ModeFlags)  then
      Include( ShowEditFlags, K_racCDisabled ); // Show/Edit Flags
  end;
end; //*** end of function K_RAFColumnsPrepare

//*************************************** K_RAFColumnsPrepare ***
// RAF Columns Prepare
//
procedure K_RAFColsPrepByDataType( var RAFCArray : TK_RAFCArray; StartNum : Integer;
                         ModeFlags : TK_RAModeFlagSet; DDType : TK_ExprExtType;
                         RFInds : TN_IArray = nil;
                         FFlags : Integer = 0;
                         FMask : Integer = K_efcFlagsMask0 );

var
  i, k, j : Integer;
  PFD : TK_POneFieldExecDescr;
//  UDRefPar : string;
  kk : Integer;
  WDataType : TK_ExprExtType;
  WDDType : TK_ExprExtType;
begin

  j := StartNum;
  WDDType := K_GetExecTypeBaseCode( DDType );
  if (WDDType.DTCode > Ord( nptNoData )) and
     ( (WDDType.FD.FDObjType = K_fdtRecord) or
       (WDDType.FD.FDObjType = K_fdtSet) ) and
     ((WDDType.D.TFlags and K_ffFlagsMask) = 0) then begin
    with WDDType.FD do begin
      k := Min( FDFieldsCount, Length(FDV) ) - 1;
      if RFInds <> nil then k := Min( k, High(RFInds) );
      SetLength( RAFCArray, j + k + 1 );
      for i := 0 to k do begin
        kk := i;
        if RFInds <> nil then  kk := RFInds[i];
        PFD := GetFieldDescrByInd( kk );
        with RAFCArray[j], PFD^ do begin
          WDataType := K_GetExecTypeBaseCode( DataType );
          if ((WDataType.D.CFlags and (K_ccObsolete or K_ccVariant)) <> 0) or
             ((WDataType.D.TFlags and K_ffRoutineMask) <> 0)               or
             (((WDataType.EFLags.All xor FFlags) and FMask) <> 0) then continue;
          K_RAFColumnDefInit( RAFCArray[j], WDataType, ModeFlags, (k = 0) );
          Caption := DataName;
          Name := DataName;
          Path := DataName;
          FieldPos := DataPos;
          if FDObjType = K_fdtSet then begin
            FieldPos := 0;
            Caption := GetFieldUName(kk);
            CDType.All := Ord(nptInt);
            BitMask := 1 shl kk;
            Include( RAFCArray[j].ShowEditFlags, K_racShowCheckBox );
          end;
          Inc( j );
        end;
      end;
    end;
    SetLength( RAFCArray, j );
  end else begin
    Inc(j);
    SetLength( RAFCArray, j );
    K_RAFColPrepByDataType( RAFCArray[j-1], ModeFlags, WDDType );
  end;
end; //*** end of function K_RAFColumnsPrepare

//*************************************** K_RAFLColsPrepByDataType
// Prepare Leave Types Column Descriptions from Data Type
//
procedure K_RAFLColsPrepByDataType( var RAFCArray : TK_RAFCArray; StartNum : Integer;
                         ModeFlags : TK_RAModeFlagSet; DDType : TK_ExprExtType;
                         var ColumnTypePat : TK_RAFCArray );

var
  i, k, j : Integer;
  PFD : TK_POneFieldExecDescr;
  FindTypeColumn : Boolean;
  WDataType : TK_ExprExtType;
  WDDType : TK_ExprExtType;
//  UDRefPar : string;
//  kk : Integer;

  function SearchColumnPattern( var RAFC : TK_RAFColumn; DTCode : Integer ) : Boolean;
  var mm : Integer;
  begin
    Result := false;
    for mm := 0 to High(ColumnTypePat) do begin
      if ColumnTypePat[mm].CDType.DTCode <> DTCode then continue;
      RAFC := ColumnTypePat[mm];
      Result := true;
      break;
    end;
  end;

begin
  j := StartNum;
  WDDType := K_GetExecTypeBaseCode( DDType );
  if (WDDType.DTCode > Ord( nptNoData )) and
     ((WDDType.D.TFlags and K_ffFlagsMask) = 0) then begin
    with WDDType.FD do begin
      k := High( GetFieldsExecDescr );
      SetLength( RAFCArray, j + k + 2 );
      for i := 0 to k do begin
        PFD := GetFieldDescrByInd( i );
        with RAFCArray[j], PFD^ do begin
// search for pattern column
          if (DataType.DTCode = Ord(nptNotDef)) or
             ((DataType.D.CFlags and (K_ccObsolete or K_ccVariant)) <> 0) then Continue;
          FindTypeColumn := SearchColumnPattern( RAFCArray[j], DataType.DTCode );
          Caption := GetFieldFullNameByInd( i );
          Name := DataName;
          Path := DataName;
          FieldPos := DataPos;
//          if not FindTypeColumn and
//            ( (DataType.DTCode < Ord(nptNoData)) or
//              ((DataType.D.TFlags and K_ffEnumSet) <> 0) ) then
          WDataType := K_GetExecTypeBaseCode( DataType );
          if not FindTypeColumn and
            ( (WDataType.DTCode < Ord(nptNoData)) or
              (Ord(WDataType.FD.FDObjType) < Ord(K_fdtEnum)) ) then begin
// init if pattern column was not found
            K_RAFColumnDefInit( RAFCArray[j], WDataType, ModeFlags, (k = 0) );
          end;
          Inc( j );
        end;
      end;
    end;
    SetLength( RAFCArray, j );
  end else begin
    Inc(j);
    SetLength( RAFCArray, j );

    with RAFCArray[j-1] do begin
      FindTypeColumn := SearchColumnPattern( RAFCArray[j-1], DDType.DTCode );
      if not FindTypeColumn then 
        FindTypeColumn := SearchColumnPattern( RAFCArray[j-1], WDDType.DTCode );

      MaxCWidth := 0;
      CDType := WDDType;
      CDType.D.TFlags := CDType.D.TFlags and not K_ffArray;
      Caption := K_GetExecTypeName(CDType.All);
      Name := Caption;
      FieldPos := 0;
      if not FindTypeColumn then begin
       // init if pattern column was not found
        if (WDataType.DTCode < Ord(nptNoData)) or
           (Ord(WDataType.FD.FDObjType) < Ord(K_fdtEnum)) then begin
          K_RAFColumnDefInit( RAFCArray[j-1], WDataType, ModeFlags, true );
        end;

        if (K_ramReadOnly in ModeFlags)               or
           ((CDType.D.TFlags and K_ffFlagsMask) <> 0)  then
          Include( ShowEditFlags, K_racReadOnly ); // Show/Edit Flags

        if (K_ramCDisabled in ModeFlags)  then
          Include( ShowEditFlags, K_racCDisabled ); // Show/Edit Flags

      end;
    end;
  end;
end; //*** end of procedure K_RAFLColsPrepByDataType

//*************************************** K_SetRAFColByColDescr
// Set RunTime RAFColumn By Column Form Descr
//
procedure K_SetRAFColByColDescr( ModeFlags : TK_RAModeFlagSet;
                                 PRAFC : TK_PRAFColumn; PCD : TK_PRAFColumnDescr;
                                 ColumnID : string; SingleFieldMode : Boolean;
                                 FormDescr : TK_UDRArray  );
var
  kk, ii, jj : Integer;
  NeededSEInds : Boolean;
  VECount : Integer;
  AddExEdFlag : Boolean;
  PP : Pointer;

  function BuildSEInds( Count : Integer; FD : TK_UDFieldsDescr; CSENames : TK_RArray ) : TN_IArray;
  var
    jj,ii : Integer;
  begin
    SetLength( Result, Count );
    ii := 0;
    for jj := 0 to High(Result) do begin
      kk := FD.IndexOfFieldDescr( PString(CSENames.P(jj))^ );
      if kk = -1 then Continue;
      Result[ii] := kk;
      Inc(ii);
    end;
    SetLength( Result, ii );
  end;

  procedure SetObj( var Obj : TObject; NewVal : TObject );
  begin
    if Integer(Obj) > 10 then Obj.Free;
    Obj := NewVal;
  end;

  procedure SetEditor( ColumnID, EName : string; var VE : TK_RAFColVEAttrs );
  begin
    with VE do begin
      if EName = 'InlineEditor' then
        SetObj( TObject(EObj), TK_RAFEditor(1) ) // Inline Editor Flag
      else if EName = 'NoEditor' then
        SetObj( TObject(EObj), TK_RAFEditor(2) ) // No Editor Flag
      else begin
        kk := K_RAFEditors.IndexOfName( EName );
        if kk = -1 then Exit;
        AddExEdFlag := true;
        SetObj( TObject(EObj), TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create );
        PP := FormDescr.GetFieldPointer( ColumnID+'_'+EName );
        if PP <> nil then // Init Ext Editor Context
          EObj.SetContext( (PP)^ )
        else if EParams <> '' then
          EObj.SetContext( EParams );
      end;
    end;
  end;

  procedure SetViewer( ColumnID, VName : string; var VE : TK_RAFColVEAttrs );
  begin
    with VE do begin
      kk := K_RAFViewers.IndexOfName( VName );
      if kk = -1 then Exit;
      SetObj( TObject(VObj), TK_RAFViewerClass(K_RAFViewers.Objects[kk]).Create );
      PP := FormDescr.GetFieldPointer( ColumnID+'_'+VName );
      if PP <> nil then // Init Viewer Context
        VObj.SetContext( (PP)^ )
      else if VParams <> '' then
        VObj.SetContext( VParams );
    end;
  end;

begin
  with PCD^, PRAFC^ do begin
    Caption := CCaption;
    Name := FName;
    Path := FName;
    if CName <> '' then begin
      Name := CName;
      ColumnID := CName;
    end;
    MaxCWidth := CWidth;
    TextPos := CTextPos;
    Fmt := CFormat;
    CFillColorInd := CCFillColorInd;
    BorderWidth := CBorderWidth;
    BorderColor := CBorderColor;
    BitMask := CBitMask;
    Hint := CHint;
    MVHelpTopicID := CMVHelpTopicID;
    DataAddCWidth := CDataAddCWidth;
    Move( CShowEditFlags, ShowEditFlags, SizeOf(ShowEditFlags) );
    if (K_ramCDisabled in ModeFlags)  then
      Include( ShowEditFlags, K_racCDisabled ); // Show/Edit Flags
    if SingleFieldMode                   and
       (CDType.DTCode < Ord(nptNoData))  and
       (CDType.D.TFlags = 0)             and
       (K_ramShowCheckBox in ModeFlags) then
      Include( ShowEditFlags, K_racShowCheckBox ); // Show/Edit Flags
    if (K_ramReadOnly in ModeFlags)      or
       (K_racSeparator in ShowEditFlags) or
       ((CDType.D.TFlags and K_ffFlagsMask) <> 0) then
      Include( ShowEditFlags, K_racReadOnly ); // Show/Edit Flags
    if K_racSeparator in ShowEditFlags then begin
      CDType.All := 0;
      Exit;
    end;
//        if ( CDType.DTCode > Ord(nptNoData) ) and
//           ( (CDType.D.TFlags and not K_ffEnumSet) = 0 ) and
//           ( (CDType.FD.ObjType <> K_fdtSet) or
//             not (K_racShowCheckBox in ShowEditFlags) ) then
    if ( CDType.DTCode > Ord(nptNoData) )                         and
       ( (CDType.D.TFlags and (K_ffArray or K_ffFlagsMask)) = 0 ) and
       ( (CDType.FD.FDObjType <> K_fdtSet) ) then
//           ( (CDType.D.TFlags = 0) or
//             (CDType.FD.ObjType = K_fdtSet) ) then
      Include( ShowEditFlags, K_racExternalEditor ); // External Flags

    VEArray := K_PrepColumnVEAttrs( K_racExternalEditor in ShowEditFlags  );
    with VEArray[0] do begin
      EEID := CGEDataID;
      EParams := CEdUserPar;
    end;

  //*** Create External Viewers By CViewers
    VECount := Min( CViewers.ALength, 4 );
    if VECount = 0 then
      K_RAFColumnViewDefInit( PRAFC^ )
    else
      for jj := 0 to VECount - 1 do
        SetViewer( ColumnID, PString(CViewers.P(jj))^, VEArray[jj] );

    NeededSEInds := (CDType.DTCode > Ord(nptNoData)) and
       ((CDType.FD.FDObjType = K_fdtEnum) or (CDType.FD.FDObjType = K_fdtSet));
    VECount := Min( CVEAttrs.ALength, 4 );
    if VECount = 0 then begin
  //*** Create External Editors By CEditors
      VECount := Min( CEditors.ALength, 4 );
      AddExEdFlag := false;
      if VECount = 0 then
        K_RAFColumnEditDefInit( PRAFC^ )
      else
        for jj := 0 to VECount - 1 do
          SetEditor( ColumnID, PString(CEditors.P(jj))^, VEArray[jj] );

  //*** Set VEArray with Old SEInds
      VECount := CSENames.ALength;
      if (VECount > 0) and NeededSEInds then
        VEArray[0].SEInds := BuildSEInds( VECount, CDType.FD, CSENames );
    end;
//*** Set VEArray from CVEAttrs
//    VECount := Min( CVEAttrs.ALength, 4 );
    if VECount > Length(VEArray) then
      SetLength( VEArray, VECount );
    for jj := 0 to VECount - 1 do begin
      with VEArray[jj], TK_PRAFDColVEAttrs(CVEAttrs.P(jj))^ do begin
        VParams := CVParams;
        SetViewer( ColumnID, CVName, VEArray[jj] );
        EParams := CEParams;
        SetEditor( ColumnID, CEName, VEArray[jj] );
        EEID := CEEID;
        ii := CSENames.ALength;
        if (ii > 0) and NeededSEInds then
          SEInds := BuildSEInds( ii, CDType.FD, CSENames );
      end;
    end;
    if AddExEdFlag then
      Include( ShowEditFlags, K_racExternalEditor ); // External Flags
  end;
end; //*** end of procedure K_SetRAFColByColDescr

//*************************************** K_GetFormDescrDataCaption
// returns FormDescr Data Caption Field
//
function K_GetFormDescrDataCaption( FormDescr : TK_UDRArray ) : string;
var
  PP : Pointer;
begin
  Result := '';
  PP := FormDescr.GetFieldPointer( 'Common' );
  if PP = nil then Exit;
  Result := TK_RAPFrDescr( PP ).DataCapt;
end; //*** end of procedure K_GetFormDescrDataCaption

//*************************************** K_IndexOfColDescrByFieldAttrs
// returns Index of Field in Columns Description Array By Field Attrs
//
function K_IndexOfColDescrByFieldAttrs( ColDescrs : TK_RArray;
                                    AFieldName : string;
                                    UsedInds : TList ) : Integer;
var
  i, j : Integer;
  Count : Integer;
begin
  Result := -1;
  if UsedInds = nil then
    Count := ColDescrs.Alength
  else
    Count := UsedInds.Count;
  for i := Count - 1 downto 0 do  begin
    if UsedInds = nil then
      j := i
    else
      j := Integer(UsedInds[i]);
    with TK_PRAFColumnDescr( ColDescrs.P(j) )^ do
      if ( (UsedInds <> nil) or
           not (K_racSeparator in TK_RAColumnFlagSet(CShowEditFlags)) ) and
         (FName = AFieldName) then begin
        if UsedInds <> nil then
          UsedInds.Delete(i);
        Result := j;
        Break;
      end;
  end;

end; //*** end of procedure K_IndexOfColDescrByFieldAttrs

//*************************************** K_InitUDTreeFormDescrOneColFieldsInfo
// Init Form Description Column Fields Info
//
function  K_InitUDTreeFormDescrOneColFieldsInfo( PCD : TK_PRAFColumnDescr;
                                           GrFlagsMask : LongWord = 0 ) : Boolean;
var Ind : Integer;
begin
//*** prepare self type field description
  with PCD^ do begin
// Set Fields Info
    if (FPath <> '') and
       not (K_racSeparator in TK_RAColumnFlagSet(CShowEditFlags)) then begin
      FType := K_UDCursorGetFieldPointer( FPath, FPData, @FUDR, @Ind );
      Result := (FPData <> nil) and (FType.DTCode <> -1);
    end else
      Result := false;
    if not Result then
      FPData := nil
    else begin
      Dec( FType.D.TFlags, K_ffPointer );
      if (GrFlagsMask <> 0) and
         (CGrFlagsSet <> 0) and
         ((GrFlagsMask and CGrFlagsSet) = 0) then Result := false;
    end;
  end;
end; //*** end of procedure K_InitUDTreeFormDescrOneColFieldsInfo

//*************************************** K_InitUDTreeFormDescrColFieldsInfo
// Init Form Description Column Fields Info
// returns actual columns number
function  K_InitUDTreeFormDescrColFieldsInfo( UDRoot : TN_UDBase;
                                        FormDescr : TK_UDRArray;
                                        GrFlagsMask : LongWord = 0 ) : Integer;
var
  i, k, j : Integer;
  Columns : TK_RArray;
  PP : Pointer;

begin
  Result := -1;
  PP := FormDescr.GetFieldPointer( 'Common' );
  if PP = nil then Exit;
  PP := FormDescr.GetFieldPointer( 'Columns' );
  if PP = nil then Exit;

  K_UDCursorGet( K_RAFUDRootCursor ).SetRoot( UDRoot );
  j := 0;
  Columns := TK_RArray(PP^);
  k := Columns.AHigh;
//*** prepare self type field description
  for i := 0 to k do begin
    if K_InitUDTreeFormDescrOneColFieldsInfo( TK_PRAFColumnDescr(Columns.P(i)), GrFlagsMask ) then
      Inc( j );
  end;
  Result := j;
end; //*** end of procedure K_InitUDTreeFormDescrColFieldsInfo

{
    N_MemIniFile.ReadString( 'Dump', 'DumpFlags', '' ) );
}
var K_UDTReeFDArray : TN_UDArray;

//*************************************** K_GetUDTreeFormDescrsList
// Fill List of UDTree FormDescriptions proper for UDRoot
//
procedure K_GetUDTreeFormDescrsList( UDRoot : TN_UDBase; FDList : TStrings );
var
  i, j, n : Integer;
  UnitName : string;
  UDUnit, UDFD : TN_UDBase;
  UDForm : TK_UDRArray;
begin
  FDList.Clear;

//******************************
//* Prepare All FormDescrs Array
//******************************
  if Length(K_UDTReeFDArray) = 0 then begin
    UnitName := N_MemIniToString( 'Application', 'UDTreeFormDescrs', '' );
    if UnitName = '' then Exit;
    i := K_SPLRootObj.IndexOfChildObjName( UnitName );
    if i = -1 then Exit;

    UDUnit := K_SPLRootObj.DirChild( i );
    n := UDUnit.DirLength;
    SetLength( K_UDTReeFDArray, n );
    j := 0;
    for i := 0 to n - 1 do begin
      UDFD := UDUnit.DirChild( i );
      if UDFD.CI <> K_UDFieldsDescrCI then Continue;
      if (TK_UDFieldsDescr(UDFD).IndexOfFieldDescr( 'Common' ) = -1) or
         (TK_UDFieldsDescr(UDFD).IndexOfFieldDescr( 'Columns' ) = -1) then Continue;
      K_UDTReeFDArray[j] := K_CreateSPLClassByType( TK_UDFieldsDescr(UDFD), [] );
      K_UDTReeFDArray[j].ObjName := UDFD.ObjName;
      Inc(j)
    end;
    SetLength( K_UDTReeFDArray, j );
  end;

//******************************
//* Build Proper FormDescrs List
//******************************
  for i := 0 to High(K_UDTReeFDArray) do begin
    UDForm := TK_UDRArray(K_UDTReeFDArray[i]);
    if K_InitUDTreeFormDescrColFieldsInfo( UDRoot, UDForm ) = 0 then Continue;
    FDList.AddObject( K_GetFormDescrDataCaption( UDForm ), UDForm )
  end;

end; //*** end of K_GetUDTreeFormDescrsList

{
//*************************************** K_GetRAListItemPValue
//
function K_GetRAListItemPValue( PRAListItem : TK_PRAListItem; out PData : Pointer ) : TK_ExprExtType;
var
  ElemCount : Integer;
begin
  with PRAListItem^, RAValue do begin
    ElemCount := ALength;
    if (AttrsSize > 0) and (ElemCount = 0) then begin
      Result := AttrsType;
      PData := PA;
    end else if ElemCount > 1 then begin
      Result := ArrayType;
      PData := RAValue;
    end else begin
      Result := ElemType;
      PData := P(0);
    end;
  end;
end; //*** end of procedure K_GetRAListItemPValue
}

//*************************************** K_GetRAListItemType
//
function K_GetRAListItemType( PRAListItem : TK_PRAListItem; PCD : TK_PRAFColumnDescr ) : TK_ExprExtType;
var
  ArrayItem : Boolean;
begin
  ArrayItem := ((PCD.FType.D.TFlags and K_ffArray) <> 0);
  with PRAListItem^, PCD^ do begin
    if ArrayItem then
      Include( TK_RAColumnFlagSet(CShowEditFlags), K_racExternalEditor );
    if (RAValue.AttrsSize > 0) and (RAValue.ALength = 0) then
      Result := RAValue.AttrsType
    else if (RAValue.ALength = 1) and not ArrayItem then
      Result := RAValue.ElemType
    else
      Result := RAValue.ArrayType;
    Result.All := Result.All and K_ffCompareTypesMask;
  end;
end; //*** end of procedure K_GetRAListItemType

//*************************************** K_SetRAFColByRAListColDescr ***
//
procedure K_SetRAFColByRAListColDescr( SynchroRAItems : Boolean;
                                       AModeFlags : TK_RAModeFlagSet;
                                       PRAListItem : TK_PRAListItem;
                                       PRAFC : TK_PRAFColumn;
                                       PCD : TK_PRAFColumnDescr;
                                       FormDescr : TK_UDRArray );
var
  ArrayItem : Boolean;
begin
  with PRAListItem^, PCD^, PRAFC^ do begin
    if SynchroRAItems then
      CDType := RAValue.ElemType
    else begin
      ArrayItem := ((PCD.FType.D.TFlags and K_ffArray) <> 0);
      if ArrayItem then
        Include( TK_RAColumnFlagSet(CShowEditFlags), K_racExternalEditor );
      if CDType.All = 0 then begin
        if (RAValue.AttrsSize > 0) and (RAValue.ALength = 0) then
          CDType := RAValue.AttrsType
        else if (RAValue.ALength = 1) and not ArrayItem then
          CDType := RAValue.ElemType
        else
          CDType := RAValue.ArrayType;
      end;
    end;
    CDType.All := CDType.All and K_ffCompareTypesMask;
    K_SetRAFColByColDescr( AModeFlags, PRAFC, PCD,
                           FName, false, FormDescr );
    Name := RAName;
  end;
end; //*** end of procedure K_SetRAFColByRAListColDescr

//*************************************** K_RAFColsPrepByRAListFormDescr ***
// Prepare Show/Edit Records
//
function K_RAFColsPrepByRAListFormDescr( var RAFCArray : TK_RAFCArray;
                      var RAListElemCount : Integer;
                      AClearModeFlags : TK_RAModeFlagSet;
                      ASetModeFlags : TK_RAModeFlagSet;
                      RAList : TK_RArray; PRAFrDescr : TK_RAPFrDescr;
                      FormDescr : TK_UDRArray;
                      UsedFDColInds : TList ) : Boolean;
var
  i, j : Integer;
  Columns : TK_RArray;
  PP : Pointer;
  PCD : TK_PRAFColumnDescr;
  Ind, ColsCount, ItemsCount : Integer;
  PRAListItem : TK_PRAListItem;
  ExtCDescr : Boolean;
  AModeFlags : TK_RAModeFlagSet;
begin
  Result := false;
  RAFCArray := nil;
  RAListElemCount := 0;
  PP := FormDescr.GetFieldPointer( 'Common' );
  if PP = nil then Exit;
  ExtCDescr := PRAFrDescr <> nil;
  if ExtCDescr then //*** Columns Common Descr Copy
    K_MoveSPLData( PP^, PRAFrDescr^, K_GetTypeCodeSafe('TK_RAFrDescr') )
  else
    PRAFrDescr := PP;
  AModeFlags := ASetModeFlags + PRAFrDescr.ModeFlags - AClearModeFlags;
  PP := FormDescr.GetFieldPointer( 'Columns' );
  if PP = nil then Exit;

  j := 0;
  Columns := TK_RArray(PP^);
  ColsCount := Columns.ALength;
  ItemsCount := RAList.ALength;
//*** prepare self type field description
  SetLength( RAFCArray, ItemsCount );
  PCD := Columns.P;
  with PRAFrDescr^ do
  Result := (K_ramRowChangeNum in ModeFlags) or
            (K_ramRowAutoChangeNum in ModeFlags);
  for i := 0 to ColsCount - 1 do begin
    with PCD^ do
      if not (K_racSeparator in TK_RAColumnFlagSet(CShowEditFlags)) then begin
        Result := Result and ((FType.D.TFlags and K_ffArray) <> 0);
        UsedFDColInds.Add( Pointer(i) );
      end;
    Inc( PCD );
  end;
  if Result then
    Include( AModeFlags, K_ramShowLRowNumbers );

  for i := 0 to ItemsCount - 1 do begin
    PRAListItem := RAList.P(i);
    with PRAListItem^ do begin
      Ind := K_IndexOfColDescrByFieldAttrs( Columns, RAName, UsedFDColInds );
      if Ind < 0 then Continue;
      K_SetRAFColByRAListColDescr( Result, AModeFlags, PRAListItem, @RAFCArray[j],
                                   TK_PRAFColumnDescr(Columns.P(Ind)), FormDescr );
    end;
    Inc( j );
  end;
  if ExtCDescr then //*** Columns Common Descr Copy
    PRAFrDescr^.ModeFlags := AModeFlags;
  RAListElemCount := j;
  SetLength( RAFCArray, j );
end; //*** end of procedure K_RAFColsPrepByRAListFormDescr

//*************************************** K_RAFColsPrepByUDTreeFormDescr ***
// Prepare Show/Edit Records
//
procedure K_RAFColsPrepByUDTreeFormDescr( var RAFCArray : TK_RAFCArray;
        var PFields : TN_PArray; PRAFrDescr : TK_RAPFrDescr;
        AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet; UDRoot : TN_UDBase;
        FormDescr : TK_UDRArray; GrFlagsMask : LongWord = 0 );
var
  i, k, j, n : Integer;
  Columns : TK_RArray;
  PP : Pointer;
  PCD : TK_PRAFColumnDescr;
  CurFieldPos : Integer;
  AModeFlags : TK_RAModeFlagSet;
begin
  PP := FormDescr.GetFieldPointer( 'Common' );
  if PP = nil then Exit;
  if PRAFrDescr <> nil then //*** Columns Common Descr Copy
    K_MoveSPLData( TK_RAPFrDescr( PP )^, PRAFrDescr^, K_GetTypeCodeSafe('TK_RAFrDescr') );
  AModeFlags := TK_RAPFrDescr( PP ).ModeFlags + ASetModeFlags - AClearModeFlags;
  PP := FormDescr.GetFieldPointer( 'Columns' );
  if PP = nil then Exit;
  K_UDCursorGet( K_RAFUDRootCursor ).SetRoot( UDRoot );

  j := 0;
  Columns := TK_RArray(PP^);
  k := Columns.ALength;
//*** prepare self type field description
  SetLength( RAFCArray, k );
  SetLength( PFields, k );
  CurFieldPos := 0;
  for i := 0 to k - 1 do begin
    PCD := Columns.P( i );
    with PCD^ do begin
      if (GrFlagsMask <> 0) and
         (CGrFlagsSet <> 0) and
         ((GrFlagsMask and CGrFlagsSet) = 0) then Continue;
      if not (K_racSeparator in TK_RAColumnFlagSet(CShowEditFlags)) then begin
      //*** Data Column
        if (FPData = nil) and
           not K_InitUDTreeFormDescrOneColFieldsInfo( PCD ) then Continue;

        PFields[j] := FPData;

        with RAFCArray[j] do begin
          if FName = '' then
          // Search fro field if needed
            for n := Length(FPath) downto 1 do
              if (FPath[n] = K_sccRecFieldDelim) or
                 (FPath[n] = K_sccVarFieldDelim) then begin
                FName := Copy( FPath, n + 1, Length(FPath) );
                break;
              end;
          CDType := FType;
          FieldPos := CurFieldPos;
          K_SetRAFColByColDescr( AModeFlags, @RAFCArray[j], PCD,
                                 FName, k = 1, FormDescr );
          CurFieldPos := CurFieldPos + K_GetExecTypeSize(FType.All);
          Path := FPath;
          CUDR := FUDR;
        end;
      end else
      //*** Separator Column
        K_SetRAFColByColDescr( AModeFlags, @RAFCArray[j], PCD,
                               FName, k = 1, FormDescr );
      Inc( j );
    end;
  end;
  SetLength( RAFCArray, j );
  SetLength( PFields, j );
end; //*** end of procedure K_RAFColsPrepByUDTreeFormDescr

//*************************************** K_RAFColsPrepByRADataFormDescr ***
// Prepare Show/Edit Records
//
procedure K_RAFColsPrepByRADataFormDescr( var RAFCArray : TK_RAFCArray;
        PRAFrDescr : TK_RAPFrDescr;
        ModeFlags : TK_RAModeFlagSet; ADataType : TK_ExprExtType;
        FormDescr : TK_UDRArray; GrFlagsMask : LongWord = 0 );
var
  i, k, j, Ind : Integer;
  PFD : TK_POneFieldExecDescr;
  FD : TK_OneFieldExecDescr;
  Columns : TK_RArray;
  PP : Pointer;
//  ExtName : string;
  PCD : TK_PRAFColumnDescr;
  WDataType : TK_ExprExtType;

  procedure SetRAFColByTypeDescr;
  begin
    with PFD^, RAFCArray[j] do begin
      FieldPos := DataPos;
      CDType := DataType;
    end;
  end;

begin
  PP := FormDescr.GetFieldPointer( 'Common' );
  if PP = nil then Exit;
  if PRAFrDescr <> nil then //*** Columns Common Descr Copy
    K_MoveSPLData( TK_RAPFrDescr( PP )^, PRAFrDescr^, K_GetTypeCodeSafe('TK_RAFrDescr') );
  PP := FormDescr.GetFieldPointer( 'Columns' );
  if PP = nil then Exit;

  j := 0;
  Columns := TK_RArray(PP^);
  k := Columns.AHigh;
//*** prepare self type field description
  WDataType := K_GetExecTypeBaseCode( ADataType );
  FD.DataPos := 0;
  FD.DataType := WDataType;
  FD.DataType.D.TFlags := FD.DataType.D.TFlags and (not K_ffArray);
  FD.DataName := K_GetElemTypeName( WDataType.All );
  FD.DataSize := K_GetExecTypeSize( WDataType.All );

  if (WDataType.DTCode > Ord( nptNoData )) and
     ((WDataType.D.TFlags and K_ffFlagsMask) = 0) then begin
    with WDataType.FD do begin
      SetLength( RAFCArray, k + 1 );
      for i := 0 to k do begin
        PCD := Columns.P( i );
        with PCD^ do begin
          if (GrFlagsMask <> 0) and
             (CGrFlagsSet <> 0) and
             ((GrFlagsMask and CGrFlagsSet) = 0) then Continue;
          if FName = '' then
            PFD := @FD
          else begin
            Ind := IndexOfFieldDescr( FName );
            if Ind = -1 then continue;
            PFD := GetFieldDescrByInd( Ind );
            if ((PFD.DataType.D.CFlags and (K_ccObsolete or K_ccVariant)) <> 0) then Continue;
          end;
          SetRAFColByTypeDescr();
          K_SetRAFColByColDescr( ModeFlags, @RAFCArray[j], PCD,
                                 PFD.DataName, k = 0, FormDescr );
          Inc( j );
        end;
      end;
    end;
    SetLength( RAFCArray, j );
  end else begin
    SetLength( RAFCArray, 1 );
    PCD := Columns.P( 0 );
    PFD := @FD;
    SetRAFColByTypeDescr();
    K_SetRAFColByColDescr( ModeFlags, @RAFCArray[0], PCD,
                           PFD.DataName, k = 0, FormDescr );
  end;
end; //*** end of procedure K_RAFColsPrepByRADataFormDescr

{
//*************************************** K_RAFColsPrepByRADataFormDescr ***
// Prepare Show/Edit Records
//
procedure K_RAFColsPrepByRADataFormDescr( var RAFCArray : TK_RAFCArray;
        PRAFrDescr : TK_RAPFrDescr;
        ModeFlags : TK_RAModeFlagSet; ADataType : TK_ExprExtType;
        FormDescr : TK_UDRArray; GrFlagsMask : LongWord = 0 );
var
  kk, i, k, j, Ind : Integer;
  PFD : TK_POneFieldExecDescr;
  FD : TK_OneFieldExecDescr;
  Columns : TK_RArray;
  PP : Pointer;
//  ExtName : string;
  ColumnID : string;
  PCD : TK_PRAFColumnDescr;
  VECount : Integer;
  AddExEdFlag : Boolean;
  WDataType : TK_ExprExtType;

  function BuildSEInds( Count : Integer; FD : TK_UDFieldsDescr; CSENames : TK_RArray ) : TN_IArray;
  var
    jj,ii : Integer;
  begin
    SetLength( Result, Count );
    ii := 0;
    for jj := 0 to High(Result) do begin
      kk := FD.IndexOf( PString(CSENames.P(jj))^ );
      if kk = -1 then Continue;
      Result[ii] := kk;
      Inc(ii);
    end;
    SetLength( Result, ii );
  end;

  procedure SetObj( var Obj : TObject; NewVal : TObject );
  begin
    if Integer(Obj) > 10 then Obj.Free;
    Obj := NewVal;
  end;

  procedure SetEditor( ColumnID, EName : string; var VE : TK_RAFColVEAttrs );
  begin
    with VE do begin
      if EName = 'InlineEditor' then
        SetObj( TObject(EObj), TK_RAFEditor(1) ) // Inline Editor Flag
      else if EName = 'NoEditor' then
        SetObj( TObject(EObj), TK_RAFEditor(2) ) // No Editor Flag
      else begin
        kk := K_RAFEditors.IndexOfName( EName );
        if kk = -1 then Exit;
        AddExEdFlag := true;
        SetObj( TObject(EObj), TK_RAFEditorClass(K_RAFEditors.Objects[kk]).Create );
        PP := FormDescr.GetFieldPointer( ColumnID+'_'+EName );
        if PP <> nil then // Init Ext Editor Context
          EObj.SetContext( (PP)^ )
        else if EParams <> '' then
          EObj.SetContext( EParams );
      end;
    end;
  end;

  procedure SetViewer( ColumnID, VName : string; var VE : TK_RAFColVEAttrs );
  begin
    with VE do begin
      kk := K_RAFViewers.IndexOfName( VName );
      if kk = -1 then Exit;
      SetObj( TObject(VObj), TK_RAFViewerClass(K_RAFViewers.Objects[kk]).Create );
      PP := FormDescr.GetFieldPointer( ColumnID+'_'+VName );
      if PP <> nil then // Init Viewer Context
        VObj.SetContext( (PP)^ )
      else if VParams <> '' then
        VObj.SetContext( VParams );
    end;
  end;

  procedure SetOneColumn;
  var
    ii, jj : Integer;
    NeededSEInds : Boolean;
  begin
    with PCD^, RAFCArray[j] do begin
      with PFD^ do begin
        ColumnID := DataName;
        FieldPos := DataPos;
        CDType := DataType;
      end;
      Caption := CCaption;
      Name := FName;
      Path := FName;
      if CName <> '' then begin
        Name := CName;
        ColumnID := CName;
      end;
      MaxCWidth := CWidth;
      TextPos := CTextPos;
      Fmt := CFormat;
      CFillColorInd := CCFillColorInd;
      BorderWidth := CBorderWidth;
      BorderColor := CBorderColor;
      BitMask := CBitMask;
      Hint := CHint;
      MVHelpTopicID := CMVHelpTopicID;
      DataAddCWidth := CDataAddCWidth;
      Move( CShowEditFlags, ShowEditFlags, SizeOf(ShowEditFlags) );
      if (K_ramCDisabled in ModeFlags)  then
        Include( ShowEditFlags, K_racCDisabled ); // Show/Edit Flags
      if (k = 0)                           and
         (CDType.DTCode < Ord(nptNoData))  and
         (CDType.D.TFlags = 0)             and
         (K_ramShowCheckBox in ModeFlags) then
        Include( ShowEditFlags, K_racShowCheckBox ); // Show/Edit Flags
      if (K_ramReadOnly in ModeFlags)      or
         (K_racSeparator in ShowEditFlags) or
         ((CDType.D.TFlags and K_ffFlagsMask) <> 0) then
        Include( ShowEditFlags, K_racReadOnly ); // Show/Edit Flags
//        if ( CDType.DTCode > Ord(nptNoData) ) and
//           ( (CDType.D.TFlags and not K_ffEnumSet) = 0 ) and
//           ( (CDType.FD.ObjType <> K_fdtSet) or
//             not (K_racShowCheckBox in ShowEditFlags) ) then
      if ( CDType.DTCode > Ord(nptNoData) )                         and
         ( (CDType.D.TFlags and (K_ffArray or K_ffFlagsMask)) = 0 ) and
         ( (CDType.FD.ObjType <> K_fdtSet) ) then
//           ( (CDType.D.TFlags = 0) or
//             (CDType.FD.ObjType = K_fdtSet) ) then
        Include( ShowEditFlags, K_racExternalEditor ); // External Flags

      VEArray := K_PrepColumnVEAttrs( K_racExternalEditor in ShowEditFlags  );
      with VEArray[0] do begin
        EEID := CGEDataID;
        EParams := CEdUserPar;
      end;

//*** Create External Viewers
      VECount := Min( CViewers.ALength, 4 );
      if VECount = 0 then
        K_RAFColumnViewDefInit( RAFCArray[j] )
      else
        for jj := 0 to VECount - 1 do
          SetViewer( ColumnID, PString(CViewers.P(jj))^, VEArray[jj] );
//*** Create External Editors
      VECount := Min( CEditors.ALength, 4 );
      AddExEdFlag := false;
      if VECount = 0 then
        K_RAFColumnEditDefInit( RAFCArray[j] )
      else
        for jj := 0 to VECount - 1 do
          SetEditor( ColumnID, PString(CEditors.P(jj))^, VEArray[jj] );

//*** Set VEArray with Old SEInds
      NeededSEInds := (CDType.DTCode > Ord(nptNoData)) and
         ((CDType.FD.ObjType = K_fdtEnum) or (CDType.FD.ObjType = K_fdtSet));
      VECount := CSENames.ALength;
      if (VECount > 0) and NeededSEInds then
        VEArray[0].SEInds := BuildSEInds( VECount, CDType.FD, CSENames );

//*** Set VEArray from CVEAttrs
      VECount := Min( CVEAttrs.ALength, 4 );
      if VECount > Length(VEArray) then
        SetLength( VEArray, VECount );
      for jj := 0 to VECount - 1 do begin
        with VEArray[jj], TK_PRAFDColVEAttrs(CVEAttrs.P(jj))^ do begin
          VParams := CVParams;
          SetViewer( ColumnID, CVName, VEArray[jj] );
          EParams := CEParams;
          SetEditor( ColumnID, CEName, VEArray[jj] );
          EEID := CEEID;
          ii := CSENames.ALength;
          if (ii > 0) and NeededSEInds then
            SEInds := BuildSEInds( ii, CDType.FD, CSENames );
        end;
      end;
      if AddExEdFlag then
        Include( ShowEditFlags, K_racExternalEditor ); // External Flags
    end;
  end;

begin
  PP := FormDescr.GetFieldPointer( 'Common' );
  if PP = nil then Exit;
  if PRAFrDescr <> nil then //*** Columns Common Descr Copy
    K_MoveSPLData( TK_RAPFrDescr( PP )^, PRAFrDescr^, K_GetTypeCodeSafe('TK_RAFrDescr') );
  PP := FormDescr.GetFieldPointer( 'Columns' );
  if PP = nil then Exit;

  j := 0;
  Columns := TK_RArray(PP^);
  k := Columns.AHigh;
//*** prepare self type field description
  WDataType := K_GetExecTypeBaseCode( ADataType );
  FD.DataPos := 0;
  FD.DataType := WDataType;
  FD.DataType.D.TFlags := FD.DataType.D.TFlags and (not K_ffArray);
  FD.DataName := K_GetElemTypeName( WDataType.All );
  FD.DataSize := K_GetExecTypeSize( WDataType.All );

  if (WDataType.DTCode > Ord( nptNoData )) and
     ((WDataType.D.TFlags and K_ffFlagsMask) = 0) then begin
    with WDataType.FD do begin
      SetLength( RAFCArray, k + 1 );
      for i := 0 to k do begin
        PCD := Columns.P( i );
        with PCD^ do begin
          if (GrFlagsMask <> 0) and
             (CGrFlagsSet <> 0) and
             ((GrFlagsMask and CGrFlagsSet) = 0) then continue;
          if FName = '' then
            PFD := @FD
          else begin
            Ind := IndexOf( FName );
            if Ind = -1 then continue;
            PFD := GetFieldDescrByInd( Ind );
            if ((PFD.DataType.D.CFlags and (K_ccObsolete or K_ccVariant)) <> 0) then Continue;
          end;
          SetOneColumn;
          Inc( j );
        end;
      end;
    end;
    SetLength( RAFCArray, j );
  end else begin
    SetLength( RAFCArray, 1 );
    PCD := Columns.P( 0 );
    PFD := @FD;
    SetOneColumn;
  end;
end; //*** end of procedure K_RAFColsPrepByRADataFormDescr
}
//*************************************** K_FreeColDescr
// Copy Records Array Field Column Description
//
procedure K_FreeColDescr( var RAFC : TK_RAFColumn );
var
  i : Integer;
  EVObj : TObject;
begin
  with RAFC do begin
    for i := 0 to High(VEArray) do
      with VEArray[i] do begin
        EVObj := VObj;
        FreeAndNil(VObj);
        if (EVObj <> EObj) and (Integer(EObj) > 10) then FreeAndNil(EObj);
      end;
  end;
end; //*** end of function K_FreeColDescr

//*************************************** K_FreeColumnsDescr
// Show/Edit Records Array
//
procedure K_FreeColumnsDescr( RAFCArray : TK_RAFCArray );
var
  i : Integer;
begin
  for i := 0 to High(RAFCArray) do
    K_FreeColDescr( RAFCArray[i] );
end; //*** end of function K_FreeColumnsDescr

//*************************************** K_GetDefaultFDTypeName
// Get default form description class type name
//
function K_GetDefaultFDTypeName( DType : Int64;
                                 GEID : string = ''; GEIDPrefix : string = '';
                                 PFDType : TK_PExprExtType = nil ) : string;
var
  TypeName : string;
  Ind : Integer;
  CGEName : string;
  CheckTypeCode : Boolean;
begin
  TypeName := K_GetElemTypeName( DType );
  Result := '';
  CheckTypeCode := PFDType <> nil;
  Ind := 0;
  if GEID = '' then begin
    CGEName := TypeName;
    if N_KeyIsDown(VK_SHIFT) then Inc(Ind);
    if N_KeyIsDown(VK_CONTROL) then Inc(Ind, 2);
    if Ind > 0 then
      CGEName := CGEName + IntToStr( Ind );
    Result := K_GetRAFrDescrTypeName( CGEName, GEIDPrefix );
  end else
    Result := GEID;
  if CheckTypeCode then
     PFDType^ := K_GetTypeCode( Result );
  if (Result = '') or
     (CheckTypeCode and (PFDType.DTCode = -1)) then begin
    if Ind = 0 then
      Result := TypeName + 'Form';
    if CheckTypeCode then
      PFDType^ := K_GetTypeCode( Result );
  end;
end; //*** end of function K_GetDefaultFDTypeName

//*************************************** K_GetFormCDescrDType
// Get Common Form description record Type Code
//
function  K_GetFormCDescrDType() : TK_ExprExtType;
begin
  if K_FormCDescrDType.All = 0 then
    K_FormCDescrDType := K_GetTypeCodeSafe('TK_RAFrDescr');
  Result := K_FormCDescrDType;
end; //*** end of function K_GetFormCDescrDType

//*************************************** K_RegRAFViewer
// Register RAF Viewer
//
procedure K_RegRAFViewer( Name : string; RAFViewer : TClass );
begin
  K_RegListObject( TStrings(K_RAFViewers), Name, TObject(RAFViewer) );
end; //*** end of function K_RegRAFViewer

//*************************************** K_RegRAFEditor
// Register RAF Editor
//
procedure K_RegRAFEditor( Name : string; RAFEditor : TClass );
begin
  K_RegListObject( TStrings(K_RAFEditors), Name, TObject(RAFEditor) );
end; //*** end of function K_RegRAFEditor

//*************************************** K_RegRAFrDescription
// Register RAFrame Description
//
procedure K_RegRAFrDescription( Name : string; DescrName : string );
begin
  K_RegListObject( TStrings(K_RAFrDecriptions), Name + '=' + DescrName, nil );
end; //*** end of function K_RegRAFrDescription

//******************************************** K_GetRAFrDescrTypeName
// Get GE FUnction index by Type Name and Prefix
//
function  K_GetRAFrDescrTypeName( Name : string; Prefix : string = ''  ) : string;
//var
//  Ind : Integer;
begin
  if Prefix <> '' then
    Result := K_RAFrDecriptions.Values[ Prefix + ':' + Name ];
  if Result = '' then
    Result := K_RAFrDecriptions.Values[ Name ];
  if Result <> '' then
    Result := Copy(Result, 1, Length(Result) - 1 ); // Skip Last Char in Result Name
end; // end_of function K_GetRAFrDescrTypeName

//*************************************** K_BuildValidRecTypesList
//
procedure K_BuildValidRecTypesList( TypesList : TStrings );
var
  i : Integer;
  DTCode : Integer;
  SL : TStringList;
begin
  SL := TStringList.Create;
  for i := 0 to K_TypeDescrsList.Count - 1 do begin
    DTCode := Integer(K_TypeDescrsList.Objects[i]);
    if (DTCode > Ord(nptNoData)) and
       ( (TK_UDFieldsDescr(DTCode).FDObjType = K_fdtTypeDef) or
         (TK_UDFieldsDescr(DTCode).FDObjType = K_fdtRecord)  or
         (TK_UDFieldsDescr(DTCode).FDObjType = K_fdtClass) ) then
      SL.AddObject(TN_UDBase(DTCode).GetUName, TObject(DTCode) );
//      SL.AddObject(K_RecDescrList.Strings[i], TObject(DTCode) );
  end;
  SL.Sort;
  SL.Sorted := false;
  for i := 0 to K_SHBaseTypesList.Count - 2 do
    SL.InsertObject(i, K_SPLTypeAliases[i], TObject(i) );
//    SL.InsertObject(i, K_SHBaseTypesList.Strings[i], TObject(i) );
  TypesList.Clear;
  TypesList.AddStrings(SL);
  SL.Free;

end; //*** end of function K_BuildValidRecTypesList

//*************************************** K_ClearRAEditFuncCont
//
procedure K_ClearRAEditFuncCont( PData : TK_PRAEditFuncCont );
begin
  FillChar( PData^, SizeOf( TK_RAEditFuncCont ), 0 );
  with PData^ do begin
    FFMask   := K_efcFlagsMask0;
  end;
end; //*** end of function K_ClearRAEditFuncCont

//*************************************** K_PutVNodesListToClipBoard
//  Put UDBases from VNodes List to RAClipBoard
//
procedure K_PutVNodesListToClipBoard( VList : TList );
var
  BufList : TStringList;
  i : Integer;
  DType : TK_ExprExtType;
  ListCount : Integer;
begin
//*** Clear previous RAClipBoard State
  for i := 0 to High(K_RAFClipBoard.BBuf) do
    K_RAFClipBoard.BBuf[i].ARelease;

//*** Prepare Data Text Represantion
  DType.All := Ord(nptUDRef);
  BufList := TStringList.Create();
  ListCount := VList.Count;
  for i := 0 to ListCount - 1 do
    BufList.Add( K_SPLValueToString( TN_VNode(VList[i]).VNUDObj, DType ) );

//*** Put Text to System ClipBoard and to RAClipBoard
  K_PutTextToClipboard( BufList.Text );
  K_RAFClipBoard.Text := BufList.Text;

//*** Put Data to  RAClipBoard
  SetLength( K_RAFClipBoard.BBuf, 1 );
  K_RAFClipBoard.BBuf[0] := K_RCreateByTypeCode( DType.All, ListCount );
  for i := 0 to ListCount - 1 do
    TN_PUDBase(K_RAFClipBoard.BBuf[0].P(i))^ := TN_VNode(VList[i]).VNUDObj;

end; //*** end of procedure K_PutVNodesListToClipBoard

//**************************************** K_EditAppUDNode
// Edit UDNode
//
function K_EditAppUDNode( UDNode, UDParent : TN_UDBase; AFOwner : TN_BaseForm;
                          AGAProc : TK_RAFGlobalActionProc; ANotModalShow : Boolean ) : Boolean;
var
  RFC : TK_RAEditFuncCont;

begin

  Result := false;
  if not K_EditUDByGEFunc( UDNode, UDParent, Result, AFOwner, AGAProc, ANotModalShow ) then begin
    if K_IsUDRArray(UDNode) then begin
      K_ClearRAEditFuncCont( @RFC );
      with RFC do begin
        FSetModeFlags := [K_ramSkipResizeWidth, K_ramFillFrameWidth];
        FOwner := AFOwner;
        FOnGlobalAction := AGAProc;
        FRLSData.RUDParent := UDParent;
        FNotModalShow := ANotModalShow;
      end;
      Result := K_EditUDRAFunc0( UDNode, @RFC );
    end;
  end;
end; // end of procedure K_EditAppUDNode

//**************************************** K_EditAppUDTreeData
// Edit UDNode
//
function K_EditAppUDTreeData( UDNode, UDParent : TN_UDBase; FormDescr : TK_UDRArray;
                              AFOwner : TN_BaseForm; AGAProc : TK_RAFGlobalActionProc;
                              ANotModalShow : Boolean ) : Boolean;
var
  RFC : TK_RAEditFuncCont;

begin

  Result := false;
  if not K_EditUDTreeDataByGEFunc( UDNode, UDParent, FormDescr, Result, AFOwner, AGAProc, ANotModalShow ) then begin
    K_ClearRAEditFuncCont( @RFC );
    with RFC do begin
      FSetModeFlags := [K_ramFillFrameWidth];
      FOwner := AFOwner;
      FOnGlobalAction := AGAProc;
      FillChar( FRLSData, SizeOf(FRLSData), 0 );
      FRLSData.RUDParent := UDParent;
      FNotModalShow := ANotModalShow;
      FDataCapt := K_GetFormDescrDataCaption( FormDescr );
      if FDataCapt = '' then UDNode.GetUName;
      FFormDescr := FormDescr;
    end;
    Result := K_EditUDTreeDataFunc( UDNode, @RFC );
  end;
end; // end of procedure K_EditAppUDTreeData

//*************************************** K_BuildAscIndsOrder
//  Order Actual (>=0) Inds
procedure K_BuildAscIndsOrder( var PInds : PInteger; IndsCount : Integer;
                               FullCount : Integer; var FullInds : TN_IArray );
begin
  if FullCount < 0 then begin
    SetLength( FullInds, IndsCount );
    Move( PInds^, FullInds[0], SizeOf(Integer) * IndsCount );
    FullCount := MaxIntValue( FullInds ) + 1;
  end;
  SetLength( FullInds, FullCount );
  K_BuildFullIndex( PInds, IndsCount, @FullInds[0], FullCount, K_BuildFullActualIndexes );
//  IndsCount := K_BuildActIndicesAndCompress( nil, nil, @FullInds[0], @FullInds[0], Length(FullCount) );
//  SetLength( FullInds, IndsCount );
  K_BuildActIndicesAndCompress(
          nil, nil, @FullInds[0], @FullInds[0], FullCount );
  PInds := @FullInds[0];
end; //*** end of procedure K_BuildAscIndsOrder

{*** TK_FRAData ***}

//*************************************** TK_FRAData.Create
//
constructor TK_FRAData.Create( AFrameRAEdit: TK_FrameRAEdit );
begin
  inherited Create;
  FrRAEdit := AFrameRAEdit;
  FFreeFormDescr := false;
  FullBufData := true;
end; //*** end of constructor TK_FRAData.Create

//*************************************** TK_FRAData.Destroy
//
destructor TK_FRAData.Destroy;
begin
  FreeContext;
  inherited;
end; //*** end of destructor TK_FRAData.Destroy

//*************************************** TK_FRAData.FreeContext
//
procedure TK_FRAData.FreeContext;
var
  i : Integer;
begin
  if FUDTreeDataMode and
     not (K_ramReadOnly in ModeFlags) and
     not FFSkipDataBuf then begin
    FUDTreeDataMode := false;
    for i := 0 to High(RAFCArray) do
      with RAFCArray[i] do
        if not (K_racSeparator in ShowEditFlags) and
           not (K_racReadOnly in ShowEditFlags) then
        K_FreeSPLData( UDTreeBufData[FieldPos], CDType.All );
    UDTreeBufData := nil;
  end;
  K_FreeColumnsDescr( RAFCArray );
  RAFCArray := nil;
  K_FreeColDescr( RAFCPat );
  if FFreeFormDescr then FrRAEdit.FormDescr.UDDelete;
  FFreeFormDescr := false;
  FrRAEdit.FreeContext;
  FreeAndNil( BufData );
//  FreeAndNil( FRAListStrings );
  FreeAndNil( FRAListFDColInds );
  FreeAndNil( FRAListTVSelect );

//  if not FUseSelfCDescr then
  K_FreeSPLData( CDescr, K_GetFormCDescrDType.All );
  FRAListMode := false;
  FUDTreeDataMode := false;
  FRAAttrsMode := false;
  FRAMatrixMode := false;

end; //*** end of procedure TK_FRAData.FreeContext



//*************************************** TK_FRAData.OnAddingRAListItem
//
procedure TK_FRAData.OnAddingRAListItem( var ACount : Integer );
var
//  FSForm : TK_FormSelectFromCombo;
  i, j : Integer;
  ListCapt : string;
  Ind : Integer;
begin
  if FRAListTVSelect = nil then begin
    FRAListTVSelect := TK_TreeViewSelect.Create;
    FRAListTVSelect.SetItemsDataType( Ord(nptInt) );
//    FRAListTVSelect.ItemsDataType.All := Ord(nptInt);
    if RAListSelectItemCaption = '' then
      RAListSelectItemCaption := 'Выбор элемента для добавления';
    FRAListTVSelect.SCaption := RAListSelectItemCaption;
    for i := 0 to FRAListFDColInds.Count - 1 do begin
      j := Integer(FRAListFDColInds[i]);
      with TK_PRAFColumnDescr(FRAListFDColumns.P(j))^ do
        if not (K_racSeparator in TK_RAColumnFlagSet(CShowEditFlags)) then begin
          ListCapt := CCaption;
          if ListCapt = '' then begin
            if (FType.DTCode > Ord(nptNoData)) then
              ListCapt := FType.FD.ObjAliase;
            if ListCapt = '' then
              ListCapt := K_GetExecTypeName( FType.All );
          end;
          FRAListTVSelect.AddItem( @j, IntToStr(j), ListCapt, CHint, 94 );
        end;
    end;
  end;

  ListCapt := FRAListTVSelect.SelectItem;
  if ListCapt = '' then
    ACount := 0 // Skip Adding
  else begin
    RAListFDColInd := PInteger(FRAListTVSelect.GetSelectedPData)^;
    Ind := FRAListFDColInds.IndexOf( Pointer(RAListFDColInd) );
    FRAListFDColInds.Delete( Ind );
    FRAListTVSelect.RootNode.DeleteDirEntry( Ind );
    FrRAEdit.AddCol.Enabled := FRAListFDColInds.Count <> 0;
    FrRAEdit.InsCol.Enabled := FrRAEdit.AddCol.Enabled;
  end;
{
  Exit;

  FSForm := K_GetFormSelectFromCombo( nil );
  if FRAListStrings = nil then begin
    FRAListStrings := TStringList.Create;
    with FRAListStrings do begin
      for i := 0 to FRAListFDColInds.Count - 1 do begin
        j := Integer(FRAListFDColInds[i]);
        with TK_PRAFColumnDescr(FRAListFDColumns.P(j))^ do
          if not (K_racSeparator in TK_RAColumnFlagSet(CShowEditFlags)) then begin
            ListCapt := CHint;
            if ListCapt = '' then
              ListCapt := CCaption;
            if ListCapt = '' then begin
              if (FType.DTCode > Ord(nptNoData)) then
                ListCapt := FType.FD.ObjAliase;
              if ListCapt = '' then
                ListCapt := K_GetExecTypeName( FType.All );
            end;
            AddObject( ListCapt, TObject(j) );
          end;
      end;
    end;
  end;

  FSForm.GetSList.Assign( FRAListStrings );
  Ind := 0;
  K_SelectFromCombo( FSForm, Ind, 'Выбор нового элемента' );

  if FSForm.ModalResult <> mrOK then
    ACount := 0 // Skip Adding
  else begin
    RAListFDColInd := Integer( FRAListStrings.Objects[Ind] );
    FRAListStrings.Delete( Ind );
    FRAListFDColInds.Delete( Ind );
  end;
}
end; //*** end of procedure TK_FRAData.OnAddingRAListItem

//*************************************** TK_FRAData.OnAddRAListItem
//
procedure TK_FRAData.OnAddRAListItem( ACount : Integer );
var
 WData : TK_RArray;
 i, RACount : Integer;
 PCD : TK_PRAFColumnDescr;
 PRAFColumn : TK_PRAFColumn;
 ItemType, ElemsType, AttrsType : TK_ExprExtType;
 RAFCInd : Integer;
 PRAListItem : TK_PRAListItem;
begin
//  RAListNewItemInd
  if BufData <> nil then
    WData := BufData
  else
    WData := TK_PRArray(PSrcData)^;
  ElemCount := WData.ALength + ACount;
  WData.ASetLengthI( WData.ALength + ACount );
  PCD := FRAListFDColumns.P(RAListFDColInd);
  with FrRAEdit do begin
    RAFCInd := Length(RAFCArray) - ACount;
  end;

  for i := ElemCount - ACount to ElemCount - 1 do begin
    PRAListItem := TK_PRAListItem(WData.P(i));
    PRAFColumn := @FrRAEdit.RAFCArray[RAFCInd];
    with PRAListItem^, PCD^, PRAFColumn^ do begin

      ItemType := K_GetExecTypeBaseCode( FType );
      ItemType.D.TFlags := ItemType.D.TFlags and not K_ffArray;
      AttrsType := K_GetRArrayTypes( ItemType, ElemsType );
      RACount := FRAListRowCount;
      if not FRAListMatrixMode then begin
        RACount := 1;
        if (AttrsType.DTCode > Ord(nptNotDef)) and (ElemsType.DTCode = Ord(nptNotDef)) then
          RACount := 0;
      end;
      RAValue := K_RCreateByTypeCode( ItemType.All, RACount, [] );
      RAValue.FEType.D.CFlags := WData.FEType.D.CFlags;
      RAName := FName;
      K_SetRAFColByRAListColDescr( FRAListMatrixMode, ModeFlags, PRAListItem,
                                   PRAFColumn, PCD, FrRAEdit.FormDescr );

      FrRAEdit.PrepareColumnControls(RAFCInd);
      Inc(RAFCInd);
    end;
  end;
  SetRAListPointers( WData, FRAListRowCount );

end; //*** end of procedure TK_FRAData.OnAddRAListItem

//*************************************** TK_FRAData.OnDelRAListItem
//
procedure TK_FRAData.OnDelRAListItem( Ind, DCount : Integer );
var
  WData : TK_RArray;
  i : Integer;
  j, k : Integer;
begin
  if BufData <> nil then
    WData := BufData
  else
    WData := TK_PRArray(PSrcData)^;

  for i := Ind - 1 to Ind - 2 + DCount do begin
    j := FrRAEdit.GetDataBufCol( i );
    with TK_PRAListItem(WData.P(j))^ do
      k := K_IndexOfColDescrByFieldAttrs( FRAListFDColumns, RAName,  nil );
    FRAListFDColInds.Add( Pointer(k) );
  end;
  FrRAEdit.AddCol.Enabled := FRAListFDColInds.Count <> 0;
  FrRAEdit.InsCol.Enabled := FrRAEdit.AddCol.Enabled;
  FreeAndNil( FRAListTVSelect );
{
  Exit;
  FreeAndNil( FRAListStrings );
}
end; //*** end of procedure TK_FRAData.OnDelRAListItem

//*************************************** TK_FRAData.OnAddRAListRow
//
procedure TK_FRAData.OnAddRAListRow( ACount : Integer );
var
 WData : TK_RArray;
 i : Integer;
begin
  if BufData <> nil then
    WData := BufData
  else
    WData := TK_PRArray(PSrcData)^;

  for i := 0 to ElemCount - 1 do
    with TK_PRAListItem(WData.P(i))^ do
      RAValue.ASetLengthI( FRAListRowCount + ACount );
  Inc( FRAListRowCount, ACount );

  SetRAListPointers( WData, FRAListRowCount );

end; //*** end of procedure TK_FRAData.OnAddRAListRow

//*************************************** TK_FRAData.OnAddDataRow
//
procedure TK_FRAData.OnAddDataRow( ACount : Integer );
var
 WData : TK_RArray;
begin
  if BufData <> nil then
    WData := BufData
  else
    WData := TK_PRArray(PSrcData)^;
  WData.ASetLengthI( WData.ALength + ACount );
  FrRAEdit.SetDataPointersFromRArray( WData.P^, WData.ElemType, 0 );
end; //*** end of procedure TK_FRAData.OnAddDataRow

//*************************************** TK_FRAData.OnAddMatrixRow
//
procedure TK_FRAData.OnAddMatrixRow( ACount : Integer );
var
  WData : TK_RArray;
  j : Integer;
begin
  if BufData <> nil then
    WData := BufData
  else
    WData := TK_PRArray(PSrcData)^;
  with WData do begin
    j := ARowCount;
    InsertRows( j, ACount );
    InitRows( j, ACount );
  end;
  FrRAEdit.SetDataPointersFromRAMatrix(WData );
end; //*** end of procedure TK_FRAData.OnAddMatrixRow

//*************************************** TK_FRAData.OnAddMatrixCol
//
procedure TK_FRAData.OnAddMatrixCol( ACount : Integer );
var
  WData : TK_RArray;
  i : Integer;
begin
  if BufData <> nil then
    WData := BufData
  else
    WData := TK_PRArray(PSrcData)^;
  with WData do begin
    i := AColCount;
    InsertCols( i, ACount );
    InitCols( i, ACount );
  end;
  with FrRAEdit do begin
    for i := Length(RAFCArray) - ACount to High(RAFCArray) do
      RAFCArray[i] := RAFCPat;
    SetDataPointersFromRAMatrix( WData );
  end;
end; //*** end of procedure TK_FRAData.OnAddMatrixCol

//*************************************** TK_FRAData.GetFieldPointer
//
function TK_FRAData.GetFieldPointer( PData : Pointer ) : Pointer;
begin
  Result := PData;
  if Result = nil then Exit;
  with FrRAEdit do begin
    if (DDType.DTCode < Ord(nptNoData)) or
       (CurLCol < 0) then Exit;
    Result := TN_BytesPtr(Result) + RAFCArray[CurLCol].FieldPos;
  end;
end; //*** end of function TK_FRAData.GetFieldPointer

{
//*************************************** TK_FRAData.GetRecPointer
//
function TK_FRAData.GetRecPointer( RA : TK_RArray; RNum : Integer ) : Pointer;
begin
  Result := nil;
  if RNum < 0 then Exit;
  Result := RA.P( RNum )
end; //*** end of function TK_FRAData.GetRecPointer
}

//*************************************** TK_FRAData.GetBufFieldPointer
//
function TK_FRAData.GetBufFieldPointer: Pointer;
begin
  with FrRAEdit do
    Result := GetFieldPointer( GetBufRecPointer );
end; //*** end of function TK_FRAData.GetBufFieldPointer

//*************************************** TK_FRAData.GetBufRecPointer
//
function TK_FRAData.GetBufRecPointer: Pointer;
var
  CRow : Integer;
begin
  with FrRAEdit do
    if BufData <> nil then begin
      CRow := CurLRow;
      if CRow >= 0 then
        Result := BufData.P( GetDataBufRow(CRow) )
      else
        Result := nil;
//      Result := GetRecPointer(BufData, GetDataBufRow(CurLRow) )
    end else
      Result := PSrcEData;
end; //*** end of function TK_FRAData.GetBufRecPointer

//*************************************** TK_FRAData.GetSrcFieldPointer
//
function TK_FRAData.GetSrcFieldPointer: Pointer;
begin
  Result := GetFieldPointer( GetSrcRecPointer );
end; //*** end of function TK_FRAData.GetSrcFieldPointer

//*************************************** TK_FRAData.GetSrcRecPointer
//
function TK_FRAData.GetSrcRecPointer: Pointer;
begin
  if (DDType.D.TFlags and K_ffArray) <> 0 then
    Result := TK_PRArray(PSrcData)^.P( FrRAEdit.CurLRow  )
//    Result := GetRecPointer(TK_PRArray(PSrcData)^, FrameRAEdit.CurLRow )
  else
    Result := PSrcEData;
end; //*** end of function TK_FRAData.GetSrcRecPointer

//*************************************** TK_FRAData.PrepFrameByFDTypeName
//
procedure  TK_FRAData.PrepFrameByFDTypeName(
      AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
      var Data; ADDType : TK_ExprExtType;
      const ADataCapt : string;
      FDTypeName : string = ''; GrFlagsMask : LongWord = 0;
      FFLags : Integer = 0;
      FMask : Integer = K_efcFlagsMask0 );
var
  FormDescr : TK_UDRArray;
  CCaption : string;
begin
  if FDTypeName = '' then
    FDTypeName := K_GetDefaultFDTypeName(ADDType.All);

  CCaption := ADataCapt;
  if K_GetTypeCode( FDTypeName ).DTCode = -1 then
    FormDescr := nil
  else begin
    FormDescr := K_CreateSPLClassByName( FDTypeName, [] );
    if CCaption = '' then
      CCaption := K_GetFormDescrDataCaption( FormDescr );

    FFreeFormDescr := true;
  end;
  PrepFrameByFormDescr( AClearModeFlags, ASetModeFlags, Data, ADDType, CCaption, FormDescr, GrFlagsMask,
                          FFlags, FMask );
//  FormDescr.Free;
end; //*** end of procedure TK_FRAData.PrepFrameByFDTypeName

//*************************************** TK_FRAData.PrepFrameByFormDescr
//
procedure  TK_FRAData.PrepFrameByFormDescr( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                    var Data; ADDType : TK_ExprExtType;
                    const ADataCapt : string;
                    FormDescr : TK_UDRArray = nil; GrFlagsMask : LongWord = 0;
                    FFLags : Integer = 0; FMask : Integer = K_efcFlagsMask0 );
var
  PCDescr : TK_RAPFrDescr;
begin
  if not (K_ramSkipAutoMatrix in ASetModeFlags) and
     (ADDType.D.TFlags = K_ffArray)          and
     (@Data <> nil)                          and
     (TK_RArray(Data) <> nil)                and
     (TK_RArray(Data).FEType.DTCode < Ord(nptNoData)) and
     (TK_RArray(Data).HCol > 0) then begin
    PrepFrameMatrixByFormDescr( AClearModeFlags, ASetModeFlags, TK_RArray(Data), ADDType,
                                ADataCapt, FormDescr );
  end else begin
    FRAMatrixMode := false;
    InitParams( AClearModeFlags, ASetModeFlags, Data, ADDType, ADataCapt, '' );
    if (FormDescr = nil) or FRAAttrsMode then
      PrepFrame1( [], ModeFlags, Data, DDType, CDataCapt, '', nil, nil, FFlags, FMask )
    else begin
       if FUseSelfCDescr then
        PCDescr := nil
      else
        PCDescr := @CDescr;

      K_RAFColsPrepByRADataFormDescr( RAFCArray, PCDescr,
                          ModeFlags, DDType, FormDescr, GrFlagsMask );
      InitParams( [], ModeFlags, Data, DDType, ADataCapt, '' );
      FrRAEdit.FormDescr := FormDescr;
      PrepFrameData(  );
    end;
  end;

end; //*** end of procedure TK_FRAData.PrepFrameByFormDescr

//*************************************** TK_FRAData.PrepFrameByRAList
//  if K_ramRowChangeNum in ModeFLags and all ArrayTypes in Columns Decriptions
//  then it means that All RAList Items are Synchronized RArrays
//
procedure  TK_FRAData.PrepFrameByRAList( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                      var RAList : TK_RArray; const ADataCapt : string = '';
                      ARAListRowsCount : Integer = 1;
                      FDUDType : TK_UDFieldsDescr = nil );
var
  PCDescr : TK_RAPFrDescr;
  FormDescr : TK_UDRArray;
  PData : Pointer;
//  FDUDType : TK_UDFieldsDescr;
  FRAListFDTypeName : string;
label ShowSimpleData;
begin
  FRAListFDTypeName := '';
  if RAList <> nil then begin
    FRAListFDTypeName := TK_PRAListAttrs(RAList.PA).FDTypeName;
    if FRAListFDTypeName = '' then begin
ShowSimpleData:
      PrepFrameByFDTypeName( AClearModeFlags, ASetModeFlags, RAList, RAList.ArrayType, ADataCapt );
      Exit;
    end;
  end else begin
    K_ShowMessage( 'Не задан объект для просмотра и редактирования', 'TK_FRAData' );
    Exit;
  end;
  if (FDUDType = nil) or (FDUDType.ObjName <> FRAListFDTypeName) then
    FDUDType := K_GetTypeCode( FRAListFDTypeName ).FD;
  if Integer(FDUDType) = -1 then goto ShowSimpleData;

  if FUseSelfCDescr then
    PCDescr := nil
  else
    PCDescr := @CDescr;

  FRAListMode := true;
  FormDescr := K_CreateSPLClassByType( FDUDType, [], 'Create' );

  SkipAddToEmpty := true;
  SkipClearEmptyRArrays := true;
  FFreeFormDescr := true;
//##??  InitParams( AModeFlags, RAList, RAList.ArrayType, ADataCapt, '' );

  FRAListFDColumns := TK_PRArray(FormDescr.GetFieldPointer( 'Columns' ))^;
  FRAListFDColInds := TList.Create;
  FRAListMatrixMode := K_RAFColsPrepByRAListFormDescr( RAFCArray, ElemCount,
                                               AClearModeFlags, ASetModeFlags,
                                               RAList, PCDescr, FormDescr, FRAListFDColInds );
  if Length(RAFCArray) < RAList.ALength then begin
//
    K_ShowMessage(
      'Несоответствие реального состава объекта и его описателя ' +
      FRAListFDTypeName + Chr($0D)+Chr($0A)+Chr($09)+Chr($09)+
      'Редактирование запрещено.', 'TK_FRAData' );
    ASetModeFlags := ASetModeFlags + [K_ramReadOnly];
  end;
  InitParams( AClearModeFlags, ASetModeFlags, RAList, RAList.ArrayType, ADataCapt, '' );
//##??  ModeFlags := ModeFlags + CDescr.ModeFlags;
  ElemCount := Length(RAFCArray);

  BufData := nil;
  SkipAddToEmpty := true;
  PrepBufData( ElemCount, PData );

  FRAListRowCount := ARAListRowsCount;
  if FRAListMatrixMode then begin
    if ElemCount > 0 then
      FRAListRowCount := TK_PRAListItem(TK_PRArray(PData).P(0)).RAValue.ALength;
  end else
    FRAListRowCount := Max( 1, FRAListRowCount );

  FrRAEdit.SetGridInfo( ModeFlags, RAFCArray, CDescr, FRAListRowCount );

  FrRAEdit.AddCol.Enabled := FRAListFDColInds.Count <> 0;
  FrRAEdit.InsCol.Enabled := FrRAEdit.AddCol.Enabled;

  SetRAListPointers( TK_PRArray(PData)^, FRAListRowCount );

  if not (K_ramReadOnly in ModeFlags) then begin
    if (K_ramColChangeNum in ModeFlags) or
       (K_ramColAutoChangeNum in ModeFlags) then
      FrRAEdit.OnColsAdd := OnAddRAListItem;
      FrRAEdit.OnColsAdding := OnAddingRAListItem;
      FrRAEdit.OnColsDel := OnDelRAListItem;
      if FRAListMatrixMode then
        FrRAEdit.OnRowsAdd  := OnAddRAListRow;
  end;

  FrRAEdit.FormDescr := FormDescr;
end; //*** end of procedure TK_FRAData.PrepFrameByRAList

//*************************************** TK_FRAData.PrepFrameByUDTreeFormDescr
//
procedure  TK_FRAData.PrepFrameByUDTreeFormDescr( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                      UDRoot : TN_UDBase; const ADataCapt : string;
                      FormDescr : TK_UDRArray = nil; GrFlagsMask : LongWord = 0 );
var
  PCDescr : TK_RAPFrDescr;
  i : Integer;
  ColsCount : Integer;
begin
  FRAMatrixMode := false;
  if FUseSelfCDescr then
    PCDescr := nil
  else
    PCDescr := @CDescr;
  K_RAFColsPrepByUDTreeFormDescr( RAFCArray, UDTreePFields, PCDescr,
                                  AClearModeFlags, ASetModeFlags,
                                  UDRoot, FormDescr, GrFlagsMask );
  ColsCount := Length(UDTreePFields);
  if ColsCount = 0 then Exit;

  BDType.All := 0;
  FUDTreeDataMode := true;
  ModeFlags := ASetModeFlags + CDescr.ModeFlags + [K_ramSkipInfoCol] - AClearModeFlags;
  ModeFlags := ModeFlags - [K_ramShowLRowNumbers,K_ramRowChangeOrder,K_ramRowChangeNum,K_ramRowAutoChangeNum];
  InitCapts( ADataCapt, '' );
  FrRAEdit.SetGridInfo( ModeFlags, RAFCArray, CDescr );

  if not (K_ramReadOnly in ModeFlags) and not FFSkipDataBuf then begin
    with RAFCArray[High(RAFCArray)] do
      SetLength( UDTreeBufData, FieldPos + K_GetExecTypeSize(CDType.All) );
    for i := 0 to ColsCount - 1 do
      with RAFCArray[i] do begin
        if not (K_racSeparator in ShowEditFlags) then begin
          if not (K_racReadOnly in ShowEditFlags) then begin
            K_MoveSPLData( UDTreePFields[i]^, UDTreeBufData[FieldPos], CDType, [K_mdfCopyRArray] );
            FrRAEdit.DataPointers[0][i] := @UDTreeBufData[FieldPos];
          end else
            FrRAEdit.DataPointers[0][i] := UDTreePFields[i];
        end;
      end;
    PrepColCFlags;
  end else
    FrRAEdit.DataPointers[0] := Copy( UDTreePFields, 0, ColsCount );
  FrRAEdit.FormDescr := FormDescr;

end; //*** end of procedure TK_FRAData.PrepFrameByUDTreeFormDescr

//*************************************** TK_FRAData.PrepFrameMatrixByFDTypeName
//
procedure  TK_FRAData.PrepFrameMatrixByFDTypeName(
      AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
      var RA: TK_RArray; ADDType : TK_ExprExtType;
      const ADataCapt : string;
      FDTypeName : string = '' );
var
  FormDescr : TK_UDRArray;
begin
  if RA <> nil then ADDType := RA.ArrayType;
  if FDTypeName = '' then
    FDTypeName := K_GetDefaultFDTypeName(ADDType.All);

  if K_GetTypeCode( FDTypeName ).DTCode = -1 then
    FormDescr := nil
  else begin
    FormDescr := K_CreateSPLClassByName( FDTypeName, [] );
    FFreeFormDescr := true;
  end;
  PrepFrameMatrixByFormDescr( AClearModeFlags, ASetModeFlags, RA, ADDType, ADataCapt, FormDescr );
end; //*** end of procedure TK_FRAData.PrepFrameMatrixByFDTypeName

//*************************************** TK_FRAData.PrepFrameMatrixByFormDescr
//
procedure  TK_FRAData.PrepFrameMatrixByFormDescr(
    AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
    var RA: TK_RArray; ADDType : TK_ExprExtType;
    const ADataCapt : string;
    FormDescr : TK_UDRArray = nil );
var
  PCDescr : TK_RAPFrDescr;
  ColCount, i : Integer;

begin
  if (FormDescr = nil) then
    PrepMatrixFrame1( AClearModeFlags, ASetModeFlags, RA, ADDType, CDataCapt, nil )
  else begin
    FRAMatrixMode := true;
    K_FreeSPLData( CDescr, K_GetFormCDescrDType.All );
    InitParams( AClearModeFlags, ASetModeFlags, RA, ADDType, ADataCapt, '' );
    if FUseSelfCDescr then
      PCDescr := nil
    else
      PCDescr := @CDescr;

    K_FreeColumnsDescr( RAFCArray );
    K_FreeColDescr( RAFCPat );
    K_RAFColsPrepByRADataFormDescr( RAFCArray, PCDescr,
                        ModeFlags, BDType, FormDescr );
    for i := 1 to High(RAFCArray) do K_FreeColDescr( RAFCArray[i] );
    FreeAndNil(BufData);
    ColCount := RA.AColCount;
    SetLength( RAFCArray, ColCount );
    RAFCPat := RAFCArray[0];
    for i := 1 to High( RAFCArray ) do  RAFCArray[i] := RAFCArray[0];
    PrepFrameData;
  end;
end; //*** end of procedure TK_FRAData.PrepFrameMatrixByFormDescr
{
//*************************************** TK_FRAData.PrepFrameByFormDescr
//
procedure  TK_FRAData.PrepFrameByFormDescr( AModeFlags: TK_RAModeFlagSet;
        RA: TK_RArray; FormDescr : TK_UDRArray = nil;
        GrFlagsMask : LongWord = 0; FFLags : Integer = 0;
        FMask : Integer = K_efcFlagsMask0 );
begin
  PrepFrameByFormDescr( AModeFlags, RA.P^, RA.DType, '', FormDescr, FFLags, FMask );
end; //*** end of procedure TK_FRAData.PrepFrameByFormDescr
}
//*************************************** TK_FRAData.PrepFrame1
//
procedure TK_FRAData.PrepFrame1(
        AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
        var Data; ADDType : TK_ExprExtType;
        const ADataCapt : string;
        const AValueCapt : string = '';
        PCDescr: TK_RAPFrDescr = nil;
        ASEInds : TN_IArray = nil;
        FFLags : Integer = 0;
        FMask : Integer = K_efcFlagsMask0 );
begin
  if not (K_ramSkipAutoMatrix in ASetModeFlags) and
     (ADDType.D.TFlags = K_ffArray)          and
     (TK_RArray(Data) <> nil)                and
     (TK_RArray(Data).FEType.DTCode < Ord(nptNoData)) and
     (TK_RArray(Data).HCol > 0) then begin
    PrepMatrixFrame1( AClearModeFlags, ASetModeFlags, TK_RArray(Data), ADDType,
                          ADataCapt, PCDescr );
  end else begin
    FRAMatrixMode := false;
    InitCDescr( PCDescr );
  {
    if PCDescr <> nil then
      K_MoveSPLData( PCDescr^, CDescr, K_GetFormCDescrDType, [K_mdfFreeDest] )
    else
      with CDescr do begin
        ModeFlags.PasFlags := [K_ramUseFillColor];
        SelFillColor  := $808080;  // Fill Color in Selected Cells
        SelFontColor  := $FFFFFF;  // Font Color in Selected Cells
        DisFillColor  := -1;       // Fill Color in Disabled Cells
        DisFontColor  := -1;       // Font Color in Disabled Cells
  //      ColumnsPalette: TK_RArray;// Columns Color Palette
      end;
  }
    InitParams( AClearModeFlags, ASetModeFlags, Data, ADDType, ADataCapt, AValueCapt );

    if FRAAttrsMode then begin
      ModeFlags := ModeFlags - [K_ramShowLRowNumbers];
      CDescr.ModeFlags := CDescr.ModeFlags - [K_ramShowLRowNumbers];
      if not (K_ramManualColOrient in ModeFlags) then begin
        ModeFlags := ModeFlags - [K_ramColVertical];
        CDescr.ModeFlags := CDescr.ModeFlags - [K_ramColVertical];
      end;
    end;

    K_RAFColsPrepByDataType( RAFCArray, 0, ModeFlags, BDType, ASEInds, FFlags, FMask );
    PrepFrameData;
  end;
end; //*** end of procedure TK_FRAData.PrepFrame1

//*************************************** TK_FRAData.PrepMatrixFrame1
//
procedure TK_FRAData.PrepMatrixFrame1( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
                          var RA: TK_RArray; ADDType : TK_ExprExtType;
                          const ADataCapt : string;
                          PCDescr: TK_RAPFrDescr = nil );
var
  i : Integer;
  ColCount : Integer;
begin
  FRAMatrixMode := true;
  InitCDescr( PCDescr );
  FreeAndNil(BufData);
  if RA <> nil then ADDType := RA.ArrayType;
  InitParams( AClearModeFlags, ASetModeFlags, RA, RA.ArrayType, ADataCapt, '' );

  K_FreeColDescr( RAFCPat );
  K_RAFColPrepByDataType( RAFCPat, ModeFlags, BDType );
//  if not FUseSelfCDescr then
//  K_FreeSPLData( CDescr, K_GetFormCDescrDType.All );

  K_FreeColumnsDescr( RAFCArray );
  ColCount := RA.AColCount;
  SetLength( RAFCArray, ColCount );
  for i := 0 to High( RAFCArray ) do  RAFCArray[i] := RAFCPat;
  PrepFrameData;
end; //*** end of procedure TK_FRAData.PrepMatrixFrame1

//*************************************** TK_FRAData.InitCapts
//
procedure TK_FRAData.InitCapts( const ADataCapt : string;
                                const AValueCapt : string );
var
  WDataCapt : string;
begin
  WDataCapt := ADataCapt;
  if WDataCapt = '' then WDataCapt := CDescr.DataCapt;

  if WDataCapt <> '' then CDescr.NameCapt := WDataCapt;
  CDataCapt := CDescr.NameCapt;
  if AValueCapt <> '' then CDescr.ValueCapt := AValueCapt;
end; //*** end of procedure TK_FRAData.InitCapts

//*************************************** TK_FRAData.InitParams
//
procedure TK_FRAData.InitParams( AClearModeFlags, ASetModeFlags : TK_RAModeFlagSet;
        var Data; ADDType : TK_ExprExtType; const ADataCapt : string;
        const AValueCapt : string );
begin
  DDType := K_GetExecTypeBaseCode( ADDType );
  if FRAMatrixMode or
     ((DDType.DTCode > Ord(nptNoData)) and (DDType.FD.FDObjType = K_fdtSet)) then
    ASetModeFlags := ASetModeFlags + [K_ramSkipColsMark];
  ModeFlags := ASetModeFlags + CDescr.ModeFlags - AClearModeFlags;

  PSrcData := @Data;
  FVRAUDRef := false;
  if DDType.D.TFlags = K_ffVArray then begin
    PSrcData := K_GetPVRArray(Data);
    DDType := K_GetExecDataTypeCode( Data, DDType );
    FVRAUDRef := (@Data <> PSrcData) and (PSrcData <> nil);
    if FVRAUDRef then
      DDType := TK_PRArray(PSrcData).ArrayType;
  end;

  FUndefRAType := ( DDType.DTCode = Ord(nptNotDef) );
  FRAAttrsMode := false;
  BDType := DDType;
  PSrcEData := PSrcData;
  if ((DDType.D.TFlags and K_ffArray) <> 0) and (PSrcData <> nil) then begin
    if TK_PRArray(PSrcData)^ <> nil then DDType := TK_PRArray(PSrcData)^.ArrayType;

    // Select Array Type for Undef Array
    if DDType.DTCode = Ord(nptNotDef) then begin
      DDType.DTCode := Ord(nptByte);
      K_SelectRecordTypeCode( DDType.DTCode, 'Select Element Type' );
    end;
    // Get Real Element Type
    BDType := TK_PRArray(PSrcData)^.GetAllTypes( DDType, ADDType );  // get real array types
    if (BDType.DTCode <= Ord(nptNotDef)) or
       (ADDType.DTCode > Ord(nptNotDef)) then begin
      BDType := ADDType;
      BDType.D.TFlags := BDType.D.TFlags or K_ffArray;
    end else begin
      FRAAttrsMode := true;
      PSrcEData := TK_PRArray(PSrcData)^.PA;
    end;
  end;
  FrRAEdit.MatrixModeDataPath := FRAMatrixMode;
  FrRAEdit.SkipCellDataPathInd  := (BDType.D.TFlags and K_ffArray) = 0;
  FrRAEdit.SkipCellDataPathName := (BDType.DTCode < Ord(nptNoData)) or
                                   (DDType.FD.FDObjType = K_fdtSet);
  InitCapts( ADataCapt, AValueCapt );
end; //*** end of procedure TK_FRAData.InitParams

//*************************************** TK_FRAData.SetNewData
//
procedure TK_FRAData.SetNewData( var Data );
var
  PData : Pointer;
//  NCount : Integer;
  EmptyRowWasAdded : Boolean;
  i, RowCount : Integer;
  PWNames : PString;
begin
//  NCount := FrameRAEdit.GetDataBufRow;
  PSrcData := @Data;
  PSrcEData := PSrcData;
  ElemCount := 1;
  if ((BDType.D.TFlags and K_ffArray) <> 0) then
    ElemCount := 0;
  if (PSrcData <> nil) then begin
    if ((BDType.D.TFlags and K_ffArray) <> 0) then
      ElemCount := TK_PRArray(PSrcData)^.ALength;
    if FRAAttrsMode then
      PSrcEData := TK_PRArray(PSrcData)^.PA;
  end;

  EmptyRowWasAdded := PrepBufData( ElemCount, PData );
  RowCount := ElemCount;
  if ((BDType.D.TFlags and K_ffArray) <> 0) and FRAMatrixMode and (PData <> nil) then
    RowCount := TK_PRArray(PData)^.ARowCount;

//  if not FRAMatrixMode then RowCount := ElemCount;

  with FrRAEdit do begin
    SetGridLRowsNumber(  RowCount );

    if PColNames <> nil then begin
      PWNames := PColNames;
      for i := 0 to High( RAFCArray ) do begin
        RAFCArray[i].Caption := PWNames^;
        Inc( PWNames );
      end;
    end;

    if PRowNames <> nil then begin
      PWNames := PRowNames;
      for i := 0 to RowCount - 1 do begin
        RowCaptions[i] := PWNames^;
        Inc( PWNames );
      end;
    end;

    if PData <> nil then begin
      if FRAMatrixMode then
        SetDataPointersFromRAMatrix( TK_RArray(PData^) )
      else
        SetDataPointersFromRArray( PData^, BDType, 0 );
    end;
    SGrid.Invalidate;
  end;

  if EmptyRowWasAdded then
    FrRAEdit.AddChangeDataFlag;
end; //*** end of procedure TK_FRAData.SetNewData

//*************************************** TK_FRAData.SetCommonDescr
//
procedure TK_FRAData.SetCommonDescr( PCDescr : TK_RAPFrDescr );
begin
  K_MoveSPLData( PCDescr^, CDescr, K_GetFormCDescrDType, [K_mdfFreeDest] );
  FUseSelfCDescr := true;
end; //*** end of procedure TK_FRAData.SetCommonDescr

//*************************************** TK_FRAData.PrepFrameData
//
procedure TK_FRAData.PrepFrameData(  );
var
  PData : Pointer;
  EmptyRowWasAdded : Boolean;
  ColCount, RowCount : Integer;
  PWColNames : PString;
  i : Integer;
begin
//*** Prepare Grid Data
  if (BDType.D.TFlags and K_ffArray) <> 0 then begin
    if PSrcData <> nil then begin
      ElemCount := TK_PRArray(PSrcData)^.ALength;
      if (BDType.DTCode < Ord( nptNoData )) and (CDescr.ValueCapt <> '') then
        RAFCArray[0].Caption := CDescr.ValueCapt;

      TK_PRArray(PSrcData)^.ALength( ColCount, RowCount );

      if ( (RowCount > 1) or
           ([K_ramRowChangeOrder, K_ramRowChangeNum] * ModeFlags <> []) ) and
          not ( [K_ramColVertical,K_ramSkipInfoCol] * ModeFlags =
                [K_ramColVertical,K_ramSkipInfoCol] )  then begin
        Include( ModeFlags, K_ramShowLRowNumbers );
        Exclude( ModeFlags, K_ramSkipInfoCol );
        Exclude( CDescr.ModeFlags, K_ramSkipInfoCol );
      end;
    end;
  end else begin
    ElemCount := 1;
    ColCount := 1;
    if BDType.DTCode < Ord( nptNoData ) then
      RAFCArray[0].Caption := CDataCapt;
  end;

  if PColNames <> nil then begin
    PWColNames := PColNames;
    for i := 0 to High( RAFCArray ) do begin
      RAFCArray[i].Caption := PWColNames^;
      Inc( PWColNames );
    end;
  end;

  BufData := nil;

  if SkipDataBuf and (K_ramAutoApply in ModeFlags) then
    Include( FrRAEdit.RLSData.RDFlags, K_rlsdSkipBuffering );
  EmptyRowWasAdded := PrepBufData( ElemCount, PData );

  if ((BDType.D.TFlags and K_ffArray) <> 0) and (PData <> nil) then
    TK_PRArray(PData)^.ALength( ColCount, RowCount );

  if not FRAMatrixMode then RowCount := ElemCount;
{ code before FrRAEdit.SetGridInfo duplication
  FrRAEdit.SetGridInfo( ModeFlags, RAFCArray, CDescr, RowCount,
                                                  PRowNames, PRowColors, nil );
  if FRAMatrixMode then begin
    if not (K_ramReadOnly in ModeFlags) then begin
      if (K_ramRowChangeNum in ModeFlags) or
         (K_ramRowAutoChangeNum in ModeFlags) then
        FrRAEdit.OnRowsAdd := OnAddMatrixRow;
      if (K_ramColChangeNum in ModeFlags) or
         (K_ramColAutoChangeNum in ModeFlags) then
        FrRAEdit.OnColsAdd := OnAddMatrixCol;
    end;
    FrRAEdit.SetDataPointersFromRAMatrix( TK_RArray(PData^) )
  end else begin
    FrRAEdit.SetDataPointersFromRArray( PData^, BDType );
    if not (K_ramReadOnly in ModeFlags)          and
       ( (K_ramRowChangeNum in ModeFlags) or
         (K_ramRowAutoChangeNum in ModeFlags) )  and
       ((BDType.D.TFlags and K_ffArray) <> 0) then
      FrRAEdit.OnRowsAdd := OnAddDataRow;
  end;
}
//!!! duplicate code was added because of some error in Frame Size calculations
// during first SetGridInfo without data 
  FrRAEdit.SetGridInfo( ModeFlags, RAFCArray, CDescr, RowCount,
                                                  PRowNames, PRowColors, nil );
  if FRAMatrixMode then
    FrRAEdit.SetDataPointersFromRAMatrix( TK_RArray(PData^) )
  else
    FrRAEdit.SetDataPointersFromRArray( PData^, BDType );

  FrRAEdit.SetGridInfo( ModeFlags, RAFCArray, CDescr, RowCount,
                                                  PRowNames, PRowColors, nil );
  // duplication of Frame OnRowsAdd and OnColsAdd setting is needed
  if not (K_ramReadOnly in ModeFlags) then begin
    if FRAMatrixMode then begin
      if (K_ramRowChangeNum in ModeFlags) or
         (K_ramRowAutoChangeNum in ModeFlags) then
        FrRAEdit.OnRowsAdd := OnAddMatrixRow;
      if (K_ramColChangeNum in ModeFlags) or
         (K_ramColAutoChangeNum in ModeFlags) then
        FrRAEdit.OnColsAdd := OnAddMatrixCol;
    end else if ( (K_ramRowChangeNum in ModeFlags) or
                  (K_ramRowAutoChangeNum in ModeFlags) )  and
                ((BDType.D.TFlags and K_ffArray) <> 0) then
      FrRAEdit.OnRowsAdd := OnAddDataRow;
  end;

  if EmptyRowWasAdded then
    FrRAEdit.AddChangeDataFlag;
end; //*** end of procedure TK_FRAData.PrepFrameData

//*************************************** TK_FRAData.CreateSrcRArray
//
procedure TK_FRAData.CreateSrcRArray( ColCount, RowCount : Integer );
begin
  if TK_PRArray(PSrcData)^ = nil then begin
    TK_PRArray(PSrcData)^ := K_RCreateByTypeCode( DDType.All );
    if ((DDType.EFlags.CFlags and K_ccCountUDRef) <> 0) and
       ((DDType.EFlags.CFlags and K_ccStopCountUDRef) = 0) then
      TK_PRArray(PSrcData)^.SetCountUDRef;
  end;
  with TK_PRArray(PSrcData)^ do
    if ColCount = 0 then
      ASetLength( RowCount )
    else
      ASetLength( ColCount, RowCount );
end; //*** end of procedure TK_FRAData.CreateSrcRArray

//*************************************** TK_FRAData.PrepBufData
//
function TK_FRAData.PrepBufData( DCount : Integer; out PData : Pointer  ) : Boolean;
var
  MDFlags : TK_MoveDataFlags;
  NewCount : Integer;
begin
//*** Prepare Grid Data
  ElemCount := DCount;
  Result := false;
  if not (K_ramReadOnly in ModeFlags) and not FFSkipDataBuf then begin
  //*** Create Data Buffer Structure
    if BufData = nil then
      BufData := K_RCreateByTypeCode( BDType.All, ElemCount )
    else
      BufData.ASetLength( ElemCount );

    if (BDType.D.TFlags and K_ffArray) = 0 then begin
    //*** Simple Record Case
      PData := BufData.P;
      if FullBufData then
//        MDFlags := [K_mdfCopyRArray, K_mdfCopyRAElems]
        MDFlags := [K_mdfCopyRArray]
      else
        MDFlags := [];

      K_MoveSPLData( PSrcEData^, PData^, BDType, MDFlags );

    end else begin
    //*** Records Array Case
      PData := @BufData;
      if ElemCount > 0 then
        BufData.SetElems( TK_PRArray(PSrcData)^.P^, false, 0, -1, FullBufData );
      if TK_PRArray(PSrcData)^ <> nil then
        BufData.HCol := TK_PRArray(PSrcData)^.HCol;
      if (ElemCount = 0) and  not SkipAddToEmpty then begin
        Result := true;
        with BufData do begin
          ASetLength( HCol + 1, 1 );
          InitElems;
          ElemCount := ALength;
        end;
      end;
    end;
    PrepColCFlags;
  end else begin
    // Correct ModeFlags for SkipDataBuf Mode
    if FFSkipDataBuf and not (K_ramReadOnly in ModeFlags) then begin
      if not (K_ramSkipRowMoving in ModeFlags) then
        ModeFlags := ModeFlags + [K_ramRowChangeOrder];
      if not (K_ramSkipColMoving in ModeFlags) then
        ModeFlags := ModeFlags + [K_ramColChangeOrder];
    end;

    if ((DDType.D.TFlags and K_ffArray) <> 0) and
       (ElemCount = 0)                        and
       (PSrcData <> nil)                      and
       (TK_PRArray(PSrcData)^ = nil) then begin
      NewCount := 0;
      if not SkipAddToEmpty then NewCount := 1;
      CreateSrcRArray( 0, NewCount );
      if not FRAAttrsMode then
        ElemCount := TK_PRArray(PSrcData)^.ALength;
      Result := true;
    end;
    PData := PSrcEData;
  end;
end; //*** end of function TK_FRAData.PrepBufData

//*************************************** TK_FRAData.PrepColCFlags
//
procedure TK_FRAData.PrepColCFlags;
var
  i : Integer;
begin
  for i := 0 to High( RAFCArray ) do
    with RAFCArray[i].CDType.D do
      CFlags := CFlags and not (K_ccCountUDRef or K_ccStopCountUDRef);

end; //*** end of function TK_FRAData.PrepColCFlags

//*************************************** TK_FRAData.InitCDescr
//
procedure TK_FRAData.InitCDescr( PCDescr: TK_RAPFrDescr = nil );
begin
  if PCDescr <> nil then begin
   if @CDescr <> PCDescr then
     K_MoveSPLData( PCDescr^, CDescr, K_GetFormCDescrDType, [K_mdfFreeDest] )
  end else
    with CDescr do begin
      ColResizeMode := K_crmCompact;
      ModeFlags := [K_ramUseFillColor];
      SelFillColor  := $808080;  // Fill Color in Selected Cells
      SelFontColor  := $FFFFFF;  // Font Color in Selected Cells
      DisFillColor  := -1;       // Fill Color in Disabled Cells
      DisFontColor  := -1;       // Font Color in Disabled Cells
//      ColumnsPalette: TK_RArray;// Columns Color Palette
    end;
end; //*** end of procedure TK_FRAData.InitCDescr

//*************************************** TK_FRAData.PrepFrameByRAList
//
procedure  TK_FRAData.SetRAListPointers( RAList : TK_RArray; RCount : Integer );
var
  j, i : Integer;
  PI : Pointer;
begin
  for j := 0 to RCount - 1 do begin
    for i := 0 to ElemCount - 1 do
      with FrRAEdit.RAFCArray[i], TK_PRAListItem(RAList.P(i))^ do begin
        if ((RAValue.ArrayType.All xor CDType.All) and K_ffCompareTypesMask) = 0 then
          PI := @RAValue
        else begin
          if (RAValue.AttrsSize > 0) and (RAValue.ALength = 0) then
            PI := RAValue.PA
          else
            PI := RAValue.P(j);
        end;

        FrRAEdit.DataPointers[j][i] := PI;
      end;
  end;
end; //*** end of procedure TK_FRAData.SetRAListPointers

//*************************************** TK_FRAData.SetOnClearDataChange
//
procedure TK_FRAData.SetOnClearDataChange( OnClearDataChange: TK_NotifyProc);
begin
  FOnClearDataChange := OnClearDataChange;
end; //*** end of procedure TK_FRAData.SetOnClearDataChange

//*************************************** TK_FRAData.SetOnDataChange
//
procedure TK_FRAData.SetOnDataChange( OnDataChange: TK_NotifyProc);
begin
  FrRAEdit.OnDataChange := OnDataChange;
end; //*** end of procedure TK_FRAData.SetOnDataChange

//*************************************** TK_FRAData.StoreToUDTreeData
//
function TK_FRAData.StoreToUDTreeData: Boolean;
var
  i : Integer;
  SetChangedUDFlag : Boolean;
  SetChangedArchFlag : Boolean;
begin
  Result := true;
  if not (K_ramReadOnly in ModeFlags) then begin
    SetChangedArchFlag := false;
    for i := 0 to High(UDTreePFields) do
      with RAFCArray[i] do
        if not (K_racSeparator in ShowEditFlags) and
           not (K_racReadOnly in ShowEditFlags) then begin
          SetChangedUDFlag := true;
          if not FFSkipDataBuf then begin
            if not K_CompareSPLData( UDTreeBufData[FieldPos], UDTreePFields[i]^, CDType, '', [] ) then
              K_MoveSPLData( UDTreeBufData[FieldPos], UDTreePFields[i]^, CDType, [K_mdfCopyRArray] )
            else
              SetChangedUDFlag := false;
          end;
          if SetChangedUDFlag then begin
            SetChangedArchFlag := true;
            K_SetChangeSubTreeFlags( CUDR );
          end;
        end;
    if SetChangedArchFlag then K_SetArchiveChangeFlag;
  end;
  if Assigned(FOnClearDataChange) then FOnClearDataChange;
end; //*** end of procedure TK_FRAData.StoreToUDTreeData

//*************************************** TK_FRAData.StoreToSData
//
function TK_FRAData.StoreToSData( OnlyFieldsCopy : Boolean = false ) : Boolean;
var
  MDFlags : TK_MoveDataFlags;
  CountUDRefFlag : Boolean;
  PData : Pointer;
//  Buf : TN_BArray;
//  BufSize : Integer;
  NCount : Integer;
  SkipClearRArray : Boolean;
  ConvDataInds, FreeDataInds, InitDataInds : TN_IArray;
  PInds : PInteger;
  FullInds : TN_IArray;
begin
  if FRAListMode then begin
    Result := StoreToRAListData;
    Exit;
  end else if FUDTreeDataMode then begin
    Result := StoreToUDTreeData;
    Exit;
  end else if FRAMatrixMode then begin
    Result := StoreToMatrixSData;
    Exit;
  end;
  Result := true;
  SkipClearRArray := FVRAUDRef or
                     SkipClearEmptyRArrays or
                     (not ClearUndefEmptyRArrays and FUndefRAType);
  NCount := FrRAEdit.GetDataBufRow;
  PInds := FrRAEdit.GetPRowIndex;

  if not (K_ramReadOnly in ModeFlags) then begin
    CountUDRefFlag := ((DDType.EFlags.CFlags and K_ccCountUDRef) <> 0) and
           ((DDType.EFlags.CFlags and K_ccStopCountUDRef) = 0);
    if not SkipDataBuf then begin
    //*** Store from Buffer
      MDFlags := [K_mdfFreeDest];
      if CountUDRefFlag then
        MDFlags := MDFlags + [K_mdfCountUDRef];
      if FullBufData then
        MDFlags := MDFlags + [K_mdfCopyRArray];
      PData := BufData.P;
      if (BDType.D.TFlags and K_ffArray) <> 0 then begin

        if (NCount > 0) or SkipClearRArray then begin
        //*** Prepare RArray
          ElemCount := TK_PRArray(PSrcData)^.ALength;
          CreateSrcRArray( 0, NCount );
          if NCount > 0 then begin
            if OnlyFieldsCopy then
              FrRAEdit.GetFrameData( PSrcData^, true, MDFlags )
            else begin
              if not (K_ramRowChangeOrder in FrRAEdit.ModeFlags) and
                 not (K_ramSkipRowMoving in FrRAEdit.ModeFlags) then
                K_BuildAscIndsOrder( PInds, NCount, BufData.Alength, FullInds );

              K_MoveSPLVectorBySIndex( TK_PRArray(PSrcData).P^, BufData.ElemSize,
                                PData^, BufData.ElemSize,
                                NCount, BufData.ElemType.All, MDFlags,
                                PInds, SizeOf(Integer) );
            end;
          end;
        end else
        //*** Clear RA field
          K_FreeSPLData( PSrcEData^, DDType.All, CountUDRefFlag );

      end else begin
        if OnlyFieldsCopy then
          FrRAEdit.GetFrameData( PSrcEData^, false, MDFlags )
        else
          K_MoveSPLData( PData^, PSrcEData^, BDType, MDFlags );
      end;
    end else begin
    //*** No Buf Mode - Reorder and Free Elements in Src Data
      if (BDType.D.TFlags and K_ffArray) <> 0 then begin
        if (NCount = 0) and not SkipClearRArray then
          K_FreeSPLData( PSrcData^, DDType.All, CountUDRefFlag )
        else begin
          K_BuildConvFreeInitInds( TK_PRArray(PSrcData).ALength, PInds, NCount,
                                   ConvDataInds, FreeDataInds, InitDataInds );
          TK_PRArray(PSrcData).ReorderElems( K_GetPIArray0(ConvDataInds), Length(ConvDataInds),
                         K_GetPIArray0(FreeDataInds), Length(FreeDataInds), nil, 0 );
        end;
      end;
    end;
    if FVRAUDRef or (K_ramUseExtEditArchChange in ModeFlags) then begin
      K_SetArchiveChangeFlag;
      Result := false;
    end;
  end;

  if Assigned(FOnClearDataChange) then FOnClearDataChange;
end; //*** end of procedure TK_FRAData.StoreToSData

//*************************************** TK_FRAData.StoreToRAListData
//
function TK_FRAData.StoreToRAListData : Boolean;
var
  MDFlags : TK_MoveDataFlags;
  CountUDRefFlag : Boolean;
  PData : Pointer;
  NCount : Integer;
  ConvColInds, FreeColInds, InitColInds : TN_IArray;
  PInds : PInteger;
  FullInds : TN_IArray;

  procedure ReorderRAListElems( RAItems : TK_RArray );
  var
    i, j : Integer;
    ConvRowInds, FreeRowInds, InitRowInds : TN_IArray;
    PConvInds, PFreeInds : PInteger;
    ConvIndsCount, FreeIndsCount : Integer;
    ItemInds : PInteger;
    FullRowInd : TN_IArray;
    RowCount : Integer;
    PRowInds : PInteger;
  begin
    PRowInds := FrRAEdit.GetPRowIndex;
    RowCount := FrRAEdit.GetDataBufRow;
    if (NCount > 0)                                    and
       not (K_ramRowChangeOrder in FrRAEdit.ModeFlags) and
       not (K_ramSkipRowMoving in FrRAEdit.ModeFlags) then
      K_BuildAscIndsOrder( PRowInds, RowCount, FRAListRowCount, FullRowInd );
    K_BuildConvFreeInitInds( FRAListRowCount, PRowInds, RowCount,
                             ConvRowInds, FreeRowInds, InitRowInds );
    PConvInds := K_GetPIArray0(ConvRowInds);
    ConvIndsCount := Length(ConvRowInds);
    PFreeInds := K_GetPIArray0(FreeRowInds);
    FreeIndsCount := Length(FreeRowInds);

    ItemInds := PInds;
    for i := 0 to NCount - 1 do begin
      j := ItemInds^;
      Inc(ItemInds);
      with TK_PRAListItem( RAItems.P(j))^ do
        RAValue.ReorderElems( PConvInds, ConvIndsCount, PFreeInds, FreeIndsCount, nil, 0 );
    end;

  end;

begin
  Result := true;
  if not (K_ramReadOnly in ModeFlags) then begin
    CountUDRefFlag := ((DDType.EFlags.CFlags and K_ccCountUDRef) <> 0) and
           ((DDType.EFlags.CFlags and K_ccStopCountUDRef) = 0);
    PInds := FrRAEdit.GetPColIndex;
    NCount := FrRAEdit.GetDataBufCol;
    if not SkipDataBuf then begin
      if not (K_ramColChangeOrder in FrRAEdit.ModeFlags) and
         not (K_ramSkipColMoving in FrRAEdit.ModeFlags) then
        K_BuildAscIndsOrder( PInds, NCount, BufData.Alength, FullInds );
    //*** Store from Buffer
      TK_PRArray(PSrcData).ASetLength( NCount );
      if NCount > 0 then begin
        MDFlags := [K_mdfFreeDest,K_mdfCopyRArray];
        if CountUDRefFlag then
          MDFlags := MDFlags + [K_mdfCountUDRef];

        //*** Reorder RAItems Synchro Rows
        if FRAListRowCount > 1 then
          ReorderRAListElems( BufData );

        //*** Copy Buffer Items Data to Source
        PData := BufData.P;
        K_MoveSPLVectorBySIndex( TK_PRArray(PSrcData).P^, BufData.ElemSize,
                          PData^, BufData.ElemSize,
                          NCount, BufData.ElemType.All, MDFlags,
                          PInds, SizeOf(Integer) );
      end;
    end else begin
        //*** Reorder RAItems Synchro Rows
      if FRAListRowCount > 1 then
        ReorderRAListElems( TK_PRArray(PSrcData)^ );

        //*** Reorder RAItems in Source
      K_BuildConvFreeInitInds( TK_PRArray(PSrcData).ALength,
                               PInds, NCount,
                               ConvColInds, FreeColInds, InitColInds );
      TK_PRArray(PSrcData).ReorderElems( K_GetPIArray0(ConvColInds), Length(ConvColInds),
                     K_GetPIArray0(FreeColInds), Length(FreeColInds), nil, 0 );
    end;
  end;

  if Assigned(FOnClearDataChange) then FOnClearDataChange;
end; //*** end of procedure TK_FRAData.StoreToSData

//*************************************** TK_FRAData.StoreToMatrixSData
//
function TK_FRAData.StoreToMatrixSData : Boolean;
var
  SkipClearRArray, CountUDRefFlag : Boolean;
  Buf : TN_BArray;
  BufSize : Integer;
  NRCount, NCCount : Integer;
begin
  Result := true;
  SkipClearRArray := FVRAUDRef or
                     SkipClearEmptyRArrays or
                     (not ClearUndefEmptyRArrays and FUndefRAType);
  if not (K_ramReadOnly in ModeFlags) then begin
    CountUDRefFlag := ((DDType.EFlags.CFlags and K_ccCountUDRef) <> 0) and
           ((DDType.EFlags.CFlags and K_ccStopCountUDRef) = 0);
    NRCount := FrRAEdit.GetDataBufRow;
    NCCount := FrRAEdit.GetDataBufCol;
    if not SkipDataBuf then begin
    //*** Store from Buffer
      if ((DDType.D.TFlags and K_ffArray) <> 0) then begin
//        NLeng := NRCount * NCCount;
        if ((NRCount > 0) and (NCCount > 0)) or SkipClearRArray then begin
        //*** Prepare RArray
          CreateSrcRArray( NCCount, NRCount );
{
          if TK_PRArray(PSrcData)^ = nil then begin
            TK_PRArray(PSrcData)^ := K_RCreateByTypeCode( DDType.All );
            if CountUDRefFlag then
              TK_PRArray(PSrcData)^.SetCountUDRef;
          end;
          TK_PRArray(PSrcData)^.ASetLength( NCCount, NRCount );
}
          if NRCount > 0 then
            FrRAEdit.GetDataToRAMatrixRArray( TK_PRArray(PSrcData)^ );
        end else
        //*** Clear RA field
          K_FreeSPLData( PSrcData^, DDType.All, CountUDRefFlag );
      end;
    end else begin
      if ((BDType.D.TFlags and K_ffArray) <> 0) then begin
        with TK_PRArray(PSrcData)^ do
          if (NRCount > 0) and (NCCount > 0) then begin
          //*** Reorder data if needed
            // Prep Buffer
            BufSize := NCCount * NRCount * ElemSize;
            SetLength( Buf, BufSize );
            // Correct Copy to Buffer with Reordering
            FrRAEdit.GetDataToRAMatrix( Buf[0], ElemType );
            ASetLength( NCCount, NRCount );
            // Simple Move from Buffer to Src RArray
            Move( Buf[0], P^, BufSize );
          end else if not SkipClearRArray then
          //*** Clear RA field
            K_FreeSPLData( PSrcData^, DDType.All, CountUDRefFlag )
          else
            ASetLength( NCCount, NRCount );
      end;
    end;
    if FVRAUDRef or (K_ramUseExtEditArchChange in ModeFlags) then begin
      K_SetArchiveChangeFlag;
      Result := false;
    end;
  end;
  if Assigned(FOnClearDataChange) then FOnClearDataChange;
end; //*** end of procedure TK_FRAData.StoreToMatrixSData

{*** end of TK_FRAData ***}


{*** TK_RAFEditor1 ***}
function TK_RAFEditor1.CanUseEditor(ACol, ARow: Integer;
  var RAFC: TK_RAFColumn): Boolean;
begin
  Result := not (K_racCDisabled in RAFC.ShowEditFlags);
end;
{*** end of TK_RAFEditor1 ***}

end.
