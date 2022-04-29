unit N_ME1;
//***** Low level Map Editor types and functions

interface
uses
  Windows, Classes, Graphics, Forms, IniFiles, ActnList, Comctrls, Contnrs, Types,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
  K_UDT1, K_Arch, K_CLib0, K_DCSpace, K_Script1, K_FrRAEdit, K_UDConst,
  N_Types, N_Lib0,   N_BaseF, N_Gra0, N_Gra1, N_Gra2, N_Lib1, N_Lib2,
  N_UDat4, N_UDCMap, N_RVCTF, N_RAEditF, N_PlainEdF, N_RichEdF, N_AlignF,
  N_CompBase, N_Comp1, N_CObjVectEdF, N_WebBrF, N_GCont;


type TN_MEGlobObj = class( TObject ) //********************* ME Global Object
    public
  IsProj_VRE:       boolean;   // current Application was Is Proj_VRE
  NVGlobCont:   TN_GlobCont;   // New Visual Global Context
  ImpAffCoefs4: TN_AffCoefs4;  // Import AffCoefs4
  ImpAffCoefs6: TN_AffCoefs6;  // Import AffCoefs6
  ExpAffCoefs4: TN_AffCoefs4;  // Export AffCoefs4
  ExpAffCoefs6: TN_AffCoefs6;  // Export AffCoefs6
  ScriptMode:       integer;   // if ScriptMode > 0 then Script, not Dialog mode
  GlobCounter:      integer;   // it should be never decreased! (for debug)
  CompPictViewerInd: integer;  // Picture Viewer Index (by N_CompPictViewerActions)
  CompTextViewerInd: integer;  // Text Document Viewer Index (by N_CompTextViewerActions)
  AllOkMode:        boolean;   // Answer OK to all dialog prompts
  AutoViewMap:      boolean;   // Auto View Map before Editing if N_ActiveRFRame = nil
  NewEdWindow:      boolean;   // Create new Window for Each Editor instance
  AutoNewEdWindow:  boolean;   // Create new Window for Each Editor instance if Shift pressed
  UCoordsToClipbrd: boolean;   // Copy User Coords to Clipboard by MouseDown
  AddUObjSysInfo:   boolean;   // Add UObj Sys Info in View Info about UObj
  AutoIncCSCodes:   boolean;   // AutoIncrement CSCodes while Pasting SubTree Clones
  NotUseRefInds:    boolean;   // Do not use RefInds while loading from *.sdt
//  MEModalMode:      boolean;   // Show some Forms (mainly Editors) in modal mode
  MEModalResult:    integer;   // Saved ModalResult of these Forms
  MEDefScrResDPI:   float;     // Default Screen resolution in DPI (for calculatind PixSize by mmSize)
  MEDefPrnResDPI:   float;     // Default Printer resolution in DPI (for calculatind PixSize by mmSize)
  MEScrResCoef:     float;     // Screen resolution Coef. (for adjusting Screen Resolution)
  AutoViewReport:   boolean;   // Auto View just created Report (Raster or HTML File)
  AliasesInPaths:   boolean;   // Use Aliases In Paths (mainly in Debug Actions)
  NewDrawMode:      boolean;   // Use New Draw mode (with TN_ContAttr)
  VEdFieldsAsTextAll: boolean; // View or Edit Fields As Text - All Fields Mode (not only nonzero fields)
  MEDebFlags:  TN_MEDebFlags;  // Debug Flags

  RastVCTForm: TN_RastVCTForm;     // Form for viewing VCTree
  RastVCTFormTmp: TN_RastVCTForm;  // Tmp Form for viewing VCTree
  TextEdForm:  TN_BaseForm;        // Form for viewing and editing Texts
  PlainEdForm: TN_PlainEditorForm; // Form for viewing and editing Plain Texts
  RichEdForm:  TN_RichEditorForm;  // Form for viewing and editing Rich Texts (txt,rtf)
  RAEdForm1:   TN_RAEditForm;      // RArray Editor Form #1
  RAEdForm2:   TN_RAEditForm;      // RArray Editor Form #2
  WebBrForm:   TN_WebBrForm;       // Web Browser Form
  AlignForm:   TN_AlignForm;       // Align, Move, Resize Components Form

  MEAffCoefsStr: string;       // Aff Coefs 4, 6 or 8 as String

  ClbdDir: TN_UDBase; // temporary Dir for Copy, Cut, Paste operations (include in DTree later!)
  UObjToUpdate: TN_UDBase;      // UObj To Update in UpdateUObjAndRedraw method
  PStringToUpdate: PString;     // Pointer to String To Update in UpdateString method
  PSPLUnitToUpdate: TK_PUDUnit; // Pointer to SPL Unit to Update (to Recompile) in UpdateSPLUnit method
  CurColor: integer;  // set by last Click in Rast1Frame (in TN_RFAShowColor.Execute())

                 // Grid steps, mainly for TN_UDCompVis.ChangeCompCoords method:
  GridStepmm:   TDPoint; // Grid Step in mm   for Pixel --> mm convertion
  GridStepLSU:  TDPoint; // Grid Step in LSU  for Pixel --> LSU convertion
  GridStepPrc:  TDPoint; // Grid Step in Prc  for Pixel --> Percents convertion
  GridStepUser: TDPoint; // Grid Step in User for Pixel --> User convertion

  MECompSPLText: TStringList; // Wrk variable for creating Component SPL Unit Text
  MEProtocolSL:  TStringList; // Map Editor Log Info
  RAFillNumParams: TN_RAFillNumParams; // params for Filling RArray of Numbers
  RAFillColParams: TN_RAFillColParams; // params for Filling RArray of Colors
  RAFillStrParams: TN_RAFillStrParams; // params for Filling RArray of Strings
  RAFill2DNumParams: TN_2DRAFillNumParams; // params for Filling 2D RArray of Numbers

  MacroProcPrefix: string;  // used in TN_UDCompBase.AddMacrosToSPL
  MacroProcNumber: integer; // used in TN_UDCompBase.AddMacrosToSPL
  MacroReplaceObj: TK_MRProcess; // for Macro Replacing

  SclonTableIndex: THashedStringList;
  MERecompFlags: TK_RecompileGSPLFlags;

  MEAlwCreateServ:  boolean;   // Always Create new copy of OLE Server even it is running
  MEWordServerName:  string;
  MEExcelServerName: string;
  MEEMFBuf: TN_BArray;
  MEEMFBufSize: integer;
  MEHelpFiles: TStringList; // HelpFiles Names and theirs contents as StringLists
  MEShowStrProcObj: procedure ( AStr: string ) of object;
  MECurFormOwner: TN_BaseForm;

  MEWordFlags:  TN_MEWordFlags;  // Creating Word Documents mode Flags
  MEWordPSMode: TN_MEWordPSMode; // Passing StrParams Delphi <--> VBA Mode
  MEWordMinVersion: integer;     // Minimal Word major Version number (8-97, 11-2003)
  MEPrevMouseUpPoint: TPoint;    // Previous Point coods used in MECopyCoordsAndColor

  constructor Create ();
  destructor  Destroy; override;
  procedure TestGlobalAction    ( AnActionType: TK_RAFGlobalAction );
  function  RedrawActiveRFrame( Sender : TObject; AActionType: TK_RAFGlobalAction ) : Boolean;
  procedure UpdateUObjAndRedraw ( AText: string );
  procedure UpdateString        ( AText: string );
  procedure UpdateSPLUnit       ( AText: string );
  procedure AddTmpUObj          ( ATmpUObj: TN_UDBase );
  procedure MEShowStrInStatusBar( AStr: string );
  procedure CreateSclonTableIndex ();
  function  GetSclonedToken   ( AKey12: string; ACaseInd: integer ): string;
  procedure VBAParamsToMemIni ();
  procedure MemIniToVBAParams ();
  procedure MECopyCoordsAndColor ( AX, AY, AColor: integer );
end; // type TN_MEGlobObj = class( TObject )

type TN_MEGOParams = packed record //***** Global Options for manual editing
  EDebFlags:       TN_MEDebFlags;    // Debug Flags
  ESDTUnloadFlags: TK_TextModeFlags; // SDT Unload Format Flags
  EPathFlags:      TN_UObjPathFlags; // Path Flags used for Showing Paths to UObjects

  EWordFlags:  TN_MEWordFlags;  // Creating Word Documents mode Flags
  EWordPSMode: TN_MEWordPSMode; // Passing StrParams Delphi <--> VBA Mode
  EWordMinVersion: integer;     // Minimal Word major Version number (8-97, 11-2003)

  EDefScrResDPI: float; // Default Screen resolution in DPI (for calculatind PixSize by mmSize)
  EDefPrnResDPI: float; // Default Printer resolution in DPI (for calculatind PixSize by mmSize)
  EScrResCoef:   float; // Screen resolution Coef. (for adjusting Screen Resolution)

  EGridStepmm:   TDPoint; // Grid Step in mm   for Pixel --> mm convertion
  EGridStepLSU:  TDPoint; // Grid Step in LSU  for Pixel --> LSU convertion
  EGridStepPrc:  TDPoint; // Grid Step in Prc  for Pixel --> Percents convertion
  EGridStepUser: TDPoint; // Grid Step in User for Pixel --> User convertion

  ERecompFlags: TK_RecompileGSPLFlags; // All Archives Reload Flags after SPL Recompile
  ELogChannels: TK_RArray;   // Log Channels Info (RArray of TN_LogChannelInfo)
end; // type TN_MEGOParams packed record

type TN_ShowStateString = class( TObject ) // base class for showing current State
    public
  procedure ShowState ( AStr: string ); virtual;
end; // type TN_ShowStateString = class( TObject )

type TN_StateString = class( TObject ) // base class for showing current
    public                             // State, Log Info and progress bar
  Flags: integer; // bit0=1 means skip adding all messages to log file
  Protocol: TStringList; // List of all messages, added by Add method
  Prefix: String; // global Prefix, added before AStr in Show methods
  ShowStringProc: procedure( AStr: string ) of object; // used for showing
                                            // current message in Show methods
  ProgressTimer: TN_CPUTimer1; // used for showing Progres percents
  ShowProtocolForm: TN_BaseForm; // Really TN_PlainEditorForm

  constructor Create();
  destructor  Destroy(); override;
  procedure Show ( AStr: string ); overload;
  procedure Show ( AStr: string; Ratio: double ); overload;
  procedure Add  ( AStr: string );
  procedure ShowProtocol ( AOwner: TN_BaseForm; AMode: integer = 0 );
  procedure AddAndShowProtocol( AStrings: TStrings; AOwner: TN_BaseForm;
                                                AMode: integer = 0 );
end; // type TN_StateString = class( TObject )

procedure N_AddStr       ( AChanel: integer; AStr: string );
procedure N_AddArray     ( AChanel: integer; AStr: string; APDPoint: PDPoint; ANumPoints: integer );

type TN_CTLVar1 = packed record
  V1LegendHeaderText: string;
  V1LegendFooterText: string;
  V1LegElemTexts:  TK_RArray;   // Legend Elements Texts
  V1LegElemColors: TK_RArray;   // Legend Elements Colors (to fill SignRect)
end; // type TN_CTLVar1 = packed record
type TN_PCTLVar1 = ^TN_CTLVar1;

type TN_VCTreeLayer = packed record
  VCTLName: string;
  VCTLParams: TK_RArray; // RArray with one record with Layer specific Params
end; // type TN_VCTreeLayer = packed record
type TN_PVCTreeLayer = ^TN_VCTreeLayer;

type TN_VCTreeParams = packed record
  VCTName: string;
  VCTHeaderText: string;
  VCTPageNumber: integer;
  VCTLayers: TK_RArray; // RArray of TN_CompTreeLayer records
end; // type TN_VCTreeParams = packed record
type TN_PVCTreeParams = ^TN_VCTreeParams;

type TN_RAFRAFontEditor = class( TK_RAFEditor ) // Own (RaEditF) LogFont Editor
  function Edit( var AData ) : Boolean; override;
end; //*** type TN_RAFRAFontEditor = class( TK_RAFEditor )

type TN_RAFWinFontEditor = class( TK_RAFEditor ) // Windows LogFont Editor
  function Edit( var AData ) : Boolean; override;
end; //*** type TN_RAFWinFontEditor = class( TK_RAFEditor )

type TN_RAFWinNFontEditor = class( TK_RAFEditor ) // Windows NFont Editor
  function Edit( var AData ) : Boolean; override;
end; //*** type TN_RAFWinNFontEditor = class( TK_RAFEditor )

type TN_RAFMLCoordsEditor = class( TK_RAFEditor ) // MapLayer.MLCObj Editor
  function Edit( var AData ) : Boolean; override;
end; //*** type TN_RAFMLCoordsEditor = class( TK_RAFEditor )

// VCTHeaderText
// VCTLayers![0]!VCTLName
// CLegend.LegHeaderText  VCTLayers![0]!VCTLParams![0]!V1LegendHeaderText
// CLegend.LegElemTexts   VCTLayers![0]!VCTLParams![0]!V1LegElemTexts
// CLegend.LegElemColors  VCTLayers![0]!VCTLParams![0]!V1LegElemColors


//****************** Global procedures **********************

function  N_GetPCurArchAttr (): TK_PArchive;

procedure N_InitVREArchGCont  ( UDArchive : TN_UDBase = nil );
procedure N_InitVRCMArchGCont ( UDArchive : TN_UDBase = nil );
procedure N_InitVREArchive    ( UDArchive: TN_UDBase );

function  N_GetCObjR ( CObjName: string; AClassInd: integer ): TN_UCObjLayer;
function  N_GetCObjW ( CObjName: string; AClassInd: integer;
                                      AWLCType: integer = 0 ): TN_UCObjLayer;
//function  N_SetFormDescrVar (): integer;
function  N_CreateMapPanel ( AUDMapLayer: TN_UDMapLayer ): TN_UDPanel; overload;
function  N_CreateMapPanel ( ACObjLayer: TN_UCObjLayer ): TN_UDPanel; overload;

procedure N_ViewCObjLayer  ( ACObjLayer: TN_UCObjLayer; PRForm: TN_PRastVCTForm;
                                                         AOwner: TN_BaseForm );
procedure N_ViewPicture    ( AFileName: string; PRForm: TN_PRastVCTForm;
                                                          AOwner: TN_BaseForm );
function  N_ViewMapLayer   ( AMapLayer: TN_UDMapLayer; PRForm: TN_PRastVCTForm;
                                        AOwner: TN_BaseForm ): TN_UDCompVis;
procedure N_ViewUObjAsMap  ( UObj: TN_UDBase; PRForm: TN_PRastVCTForm;
                                                         AOwner: TN_BaseForm );
procedure N_ViewCompMain   ( AUObj: TN_UDBase; AShowResponse: TN_OneStrProcObj = nil;
                                                           AOwner: TN_BaseForm = nil );
procedure N_GetTextEditorForm ( var APForm: TN_PBaseForm; AOwner: TN_BaseForm;
                                        out EditorStrings: TStrings ); overload;
procedure N_GetTextEditorForm ( AOwner: TN_BaseForm;
                                        out EditorStrings: TStrings ); overload;

function  N_GetMEPlainEditorForm ( AOwner: TN_BaseForm ): TN_PlainEditorForm; overload;
procedure N_GetMEPlainEditorForm ( var APForm: TN_PPlainEditorForm; AOwner: TN_BaseForm ); overload;
function  N_GetMERichEditorForm  ( AOwner: TN_BaseForm ): TN_RichEditorForm; overload;
procedure N_GetMERichEditorForm  ( var APForm: TN_PRichEditorForm; AOwner: TN_BaseForm ); overload;
function  N_GetMERastVCTForm     ( AOwner: TN_BaseForm ): TN_RastVCTForm; overload;
procedure N_GetMERastVCTForm     ( var APForm: TN_PRastVCTForm; AOwner: TN_BaseForm ); overload;
function  N_GetMEWebBrForm       ( AOwner: TN_BaseForm ): TN_WebBrForm; overload;
procedure N_GetMEWebBrForm       ( var APForm: TN_PWebBrForm; AOwner: TN_BaseForm ); overload;

procedure N_AddUObjSysInfo     ( UObj: TN_UDBase; AStrings: TStrings );
procedure N_ViewUObjInfo       ( UObj: TN_UDBase; APForm: TN_PBaseForm;
                                                         AOwner: TN_BaseForm );
procedure N_ViewUObjFields     ( UObj: TN_UDBase; APForm: TN_PBaseForm;
                                                         AOwner: TN_BaseForm );
procedure N_ViewUObjSysFields  ( UObj: TN_UDBase; APForm: TN_PBaseForm;
                                                         AOwner: TN_BaseForm );
procedure N_ViewPathsToUObj     ( UObj: TN_UDBase; APForm: TN_PBaseForm;
                                                         AOwner: TN_BaseForm );
procedure N_CreateActiveRFrame  ( UObj: TN_UDBase; PRForm: TN_PRastVCTForm;
                                                         AOwner: TN_BaseForm );
function  N_EditText            ( var AText: string; AOwner: TN_BaseForm ): boolean;
procedure N_EditUObjFields      ( UObj: TN_UDBase; APForm: TN_PBaseForm;
                                                         AOwner: TN_BaseForm );
function  N_EditMapLayerCoords  ( AUDMapLayer: TN_UDMapLayer;
                                  AOwner: TN_BaseForm ): TN_CObjVectEditorForm;
function  N_EditCObjLayerCoords ( ACObjLayer: TN_UCObjLayer;
                                  AOwner: TN_BaseForm ): TN_CObjVectEditorForm;
function  N_EditParams ( AUObj: TK_UDRArray; AModalModeFlag: TN_ModalModeFlag; AOwner: TN_BaseForm ): TN_RAEditForm;
//function  N_EditUserParams (  APUserParams: TK_PRArray; AUObj: TK_UDRArray;
//                                           AOwner: TN_BaseForm ): TN_RAEditForm;

function  N_EditRecord ( AFlags: TN_RAEditFlags; var ARecord; ATypeName, ACaption: string;
                      AFormDescrName: string; PRAEditForm: TN_PRAEditForm;
                   AUDObj: TK_UDRArray; AOwner: TN_BaseForm; AModalModeFlag: TN_ModalModeFlag = mmfNotModal ): TN_RAEditForm; overload;
function  N_EditRecord ( AFlags: TN_RAEditFlags; var ARecord; ATypeName, ACaption: string;
                   AUDObj: TK_UDRArray; AOwner: TN_BaseForm; AModalModeFlag: TN_ModalModeFlag = mmfNotModal ): TN_RAEditForm; overload;

function  N_EditUDLogFont ( UDLogFont: TN_UDLogFont; AOwner: TN_BaseForm ): boolean;
function  N_EditNFont     ( APNFont: TN_PNFont; AOwner: TN_BaseForm; APColor : PColor = nil ): boolean;
// procedure N_EditUDText    ( AUDText: TN_UDText; AOwner: TN_BaseForm );
function  N_EditArchSectionParams ( ASection: TN_UDBase; AOwner: TN_BaseForm = nil ): boolean;
function  N_LoadArchSection    ( ASection: TN_UDBase ): boolean;

procedure N_SaveCSToTxtFile    ( CS:  TK_UDDCSpace;  FName: string );
procedure N_LoadCSFromTxtFile  ( CS:  TK_UDDCSpace;  FName: string ); overload;
function  N_LoadCSFromTxtFile  ( ACSObjName, AFName: string ): TK_UDDCSpace; overload;
procedure N_SaveCSSToTxtFile   ( CSS: TK_UDDCSSpace; FName: string );
procedure N_LoadCSSFromTxtFile ( CSS: TK_UDDCSSpace; FName: string );
function  N_LoadUDVectFromTxtFile ( FName: string; CS : TStrings = nil ): TK_UDVector;

procedure N_FillReIndVect ( var ReIndVect: TK_RArray; SrcCSS, DstCSS: TK_UDDCSSpace );
//function  N_CreateUlines  ( CoordsType: integer; AObjName: string ): TN_ULines;
function  N_StringCodeBelongsToCS ( ASCode: string; ACS: TK_UDDCSpace;
                                                   ASL: TStringList): boolean;
procedure N_SaveCurStateToMemIni ();
procedure N_AddToProtocol ( AStr: string );
procedure N_ShowProtocol  ( ACaption: string; AOwner: TN_BaseForm );
procedure N_CurShowStr    ( AStr: string );
procedure N_ViewFileInMSWord ( AFileName: string );

//******************** Global Objects ******************************
var
  N_StateString: TN_StateString; // Obj for Showing current State and Progres
  N_MEGlobObj: TN_MEGlobObj;     // Obj for updating UObj after editing as Text
                                 // and for runtime global variables
  N_CompPictViewerNames:   Array [0..0] of string = ( ' View Picture from File' );
  N_CompPictViewerActions: Array [0..0] of TAction; // parallel to N_CompPictViewerNames

  N_CompTextViewerNames:   Array [0..2] of string = ( ' View in Ext. Browser ',
                              ' View in MS Word ',  ' View Source Text ' );

  N_CompTextViewerActions: Array [0..2] of TAction; // parallel to N_CompTextViewerNames

  //***** Archive System Directories
  N_MapEditorDir:   TN_UDBase;
//  N_CObjectsDir:    TN_UDBase;
//  N_DVectorsDir:    TN_UDBase;
  N_SysDir:         TN_UDBase;
  N_SclonTablesDir: TN_UDBase;
  N_TmpObjectsDir:  TN_UDBase;
  N_DefObjectsDir:  TN_UDBase;

  N_InitAppArchProc: procedure ( CurArchive : TN_UDBase = nil );

implementation
uses SysUtils, Controls, Dialogs,
     K_CLib, K_VFunc, K_STBuf, K_UDC, K_CSpace,
     K_UDT2, K_SParse1, K_MVObjs, K_IMVDAR, K_Parse, N_EdStrF,
     N_ClassRef, N_CompCL, N_InfoF, N_Rast1Fr, N_VRE3, N_MsgDialF,
     N_NVtreeFr, N_NVTreeF, N_Deb1; // , N_CM1;

//****************** TN_MEGlobObj class methods  **********************

var GANames: array [0..4] of string = ('ApplyToAll', 'CancelToAll',
                                       'OKToAll', 'OK', 'None' );

//***************************************************** TN_MEGlobObj.Create ***
//
constructor TN_MEGlobObj.Create();
begin
  NVGlobCont   := TN_GlobCont.Create();
  ImpAffCoefs4 := N_IYAffCoefs4;
  ExpAffCoefs4 := N_IYAffCoefs4;

  ScriptMode   := 0;
  AllOKMode    := False;
  AutoViewMap  := True;
  NewDrawMode  := True;
  AutoNewEdWindow := True;

  GridStepmm   := DPoint( 0.1, 0.1 );
  GridStepLSU  := DPoint( 0.1, 0.1 );
  GridStepPrc  := DPoint( 0.1, 0.1 );
  GridStepUser := DPoint( 0.001, 0.001 );
  MECompSPLText := TStringList.Create();

  MEProtocolSL  := TStringList.Create();
  MEProtocolSL.Add( 'Application Started at ' + K_DateTimeToStr( Date+Time ) );
  MEProtocolSL.Add( '' );

  RAFillNumParams.FNREndFunc   := 10;
  RAFillNumParams.FNRNumDigits := 3;
  RAFillNumParams.FNRMultCoef  := 1;
  RAFillNumParams.FNRPowerCoef := 1;

  RAFillColParams.FCRMaxColor := $FFFFFF;

  RAFillStrParams.FSRFormat := '%3d';

  RAFill2DNumParams.FNRVX0Y0   := 1.0;
  RAFill2DNumParams.FNRVXMaxY0 := 10.0;
  RAFill2DNumParams.FNRVX0YMax := 1.01;
  RAFill2DNumParams.FNRFormat  := '* %f *';

  MacroReplaceObj := TK_MRProcess.Create();

  ClbdDir := TN_UDBase.Create(); // used for copy/paste
  ClbdDir.ObjName := 'ClipboardDir';

  MEWordServerName  := 'Word.Application';
//  MEWordServerName  := 'Word.Application.10';
  MEWordFlags  := [mewfUseVBA,mewfUseWin32API];
  MEWordPSMode := psmDelphiMem;

  MEWordMinVersion  := 8; // Word 97
  MEExcelServerName := 'Excel.Application';

  MEHelpFiles := TStringList.Create();
  MEHelpFiles.Sorted := True;

  MEShowStrProcObj := MEShowStrInStatusBar;
end; //*** end of Constructor TN_MEGlobObj.Create

//**************************************** TN_MEGlobObj.Destroy ***
destructor TN_MEGlobObj.Destroy;
var
  i: integer;
begin
  MECompSPLText.Free;
  MEProtocolSL.Free;
  NVGlobCont.Free;
  MacroReplaceObj.Free;
  SclonTableIndex.Free;
  ClbdDir.UDDelete();

  for i := 0 to MEHelpFiles.Count-1 do
    MEHelpFiles.Objects[i].Free();

  MEHelpFiles.Free;

  Inherited;
end; //*** end of destructor TN_MEGlobObj.Destroy

//***********************************  TN_MEGlobObj.TestGlobalAction  ******
// just dump all Self calls (for debug)
//
procedure TN_MEGlobObj.TestGlobalAction( AnActionType: TK_RAFGlobalAction );
var
  Str: string;
begin
  Str := GANames[Ord(AnActionType)];
//  K_ValueToString( AnActionType, K_GetTypeCodeSafe( 'TK_RAFGlobalAction' ));
  N_IAdd( Format( '(%.4d) TestGA %s', [N_MEGlobObj.GlobCounter, Str] ));
  Inc(N_MEGlobObj.GlobCounter);
end; // end of procedure TN_MEGlobObj.TestGlobalAction

//************************************** TN_MEGlobObj.RedrawActiveRFrame ***
// Redraw N_ActiveRFrame by K_fgaApply AAction
//
function TN_MEGlobObj.RedrawActiveRFrame( Sender : TObject; AActionType: TK_RAFGlobalAction ) : Boolean;
begin
//  TestGlobalAction( AActionType ); // for debug
  Result := True;
  if AActionType <> K_fgaCancelToAll then
    N_ActiveRFrame.RedrawAllAndShow();
end; //*** end of procedure TN_MEGlobObj.RedrawActiveRFrame

//**************************************** TN_MEGlobObj.UpdateUObjAndRedraw ***
// Update UObjToUpdate by given AText and Redraw N_ActiveRFrame
//
procedure TN_MEGlobObj.UpdateUObjAndRedraw( AText: string );
begin
  K_SerialTextBuf.TextStrings.Text := AText; // UObjAsStrings.Text;
  K_CurArchive.RefPath := K_ArchiveCursor; // Restore Archive RefPath
  K_LoadFieldsFromText( UObjToUpdate, K_SerialTextBuf );
  UObjToUpdate.RebuildVNodes();
//  UObjToUpdate.SetChangedSubTreeFlag();
  K_SetChangeSubTreeFlags( UObjToUpdate );

  if N_ActiveRFrame <> nil then
    N_ActiveRFrame.RedrawAllAndShow();
end; // end of procedure TN_MEGlobObj.UpdateUObjAndRedraw

//**************************************** TN_MEGlobObj.UpdateString ***
// Update PStringToUpdate^ by given AText
//
procedure TN_MEGlobObj.UpdateString( AText: string );
begin
  PStringToUpdate^ := AText;
end; // end of procedure TN_MEGlobObj.UpdateString

//**************************************** TN_MEGlobObj.UpdateSPLUnit ***
// Update (Recompile) PSPLUnitToUpdate^ by given AText
//
procedure TN_MEGlobObj.UpdateSPLUnit( AText: string );
begin
  if PSPLUnitToUpdate^ <> nil then PSPLUnitToUpdate^.UDDelete;
  PSPLUnitToUpdate^ := nil;
  if not K_CompileUnit( AText, PSPLUnitToUpdate^ ) then begin
    PSPLUnitToUpdate^.UDDelete;
    PSPLUnitToUpdate^ := nil;
  end;
end; // end of procedure TN_MEGlobObj.UpdateSPLUnit

//**************************************** TN_MEGlobObj.AddTmpUObj ***
// Delete all UObjects from N_TmpObjectsDir with RefCounter = 1 and
// add given ATmpUObj to N_TmpObjectsDir,
//
procedure TN_MEGlobObj.AddTmpUObj( ATmpUObj: TN_UDBase );
var
  i, Maxi: integer;
  UObj: TN_UDBase;
begin
  Maxi := N_TmpObjectsDir.DirHigh();
  for i := 0 to Maxi do
  begin
    UObj := N_TmpObjectsDir.DirChild( i );
    if UObj = nil then
    begin
      N_TmpObjectsDir.PutDirChildSafe( i, ATmpUObj );
      Exit; // all done
    end else if UObj.RefCounter <= 1 then
    begin
      N_TmpObjectsDir.PutDirChildSafe( i, ATmpUObj );
      Exit; // all done
    end;
  end; // for i := 0 to Maxi do

  //***** Here: all N_TmpObjectsDir enties are <> nil and have RefCounter > 1

  N_TmpObjectsDir.AddOneChild( ATmpUObj );
end; // end of procedure TN_MEGlobObj.AddTmpUObj

//************************************** TN_MEGlobObj.MEShowStrInStatusBar ***
// Show given string AStr in appropriate Status Bar
//
procedure TN_MEGlobObj.MEShowStrInStatusBar( AStr: string );
var
  NeededStatusBar: TStatusBar;
begin
  NeededStatusBar := nil;

  if RAEdForm1 <> nil then // use RAEdForm1 StatusBar
    NeededStatusBar := RAEdForm1.StatusBar
  else if N_NVTreeForm <> nil then
    NeededStatusBar := N_NVTreeForm.StatusBar;

  if NeededStatusBar <> nil then
    NeededStatusBar.SimpleText := AStr;

end; // procedure TN_MEGlobObj.MEShowStrInStatusBar

//************************************** TN_MEGlobObj.CreateSclonTableIndex ***
// Create SclonTableIndex form all Tables in N_SclonTablesDir
//
procedure TN_MEGlobObj.CreateSclonTableIndex();
var
  i, j, Ind, Maxi: integer;
  UObj: TN_UDBase;
  Table: TK_UDRArray;
begin
  if SclonTableIndex = nil then
    SclonTableIndex := THashedStringList.Create;

  SclonTableIndex.Clear();

  Maxi := N_SclonTablesDir.DirHigh();
  for i := 0 to Maxi do // loop along all all SclonTables
  begin
    UObj := N_SclonTablesDir.DirChild( i );
    if not (UObj is TK_UDRArray) then Continue; // is not a SclonTable
    Table := TK_UDRArray(UObj);

    if K_GetExecTypeName( Table.R.ElemType.All ) <> 'TN_SclonOneToken' then
      Continue; //  is not a SclonTable

    for j := 0 to Table.AHigh() do // along all rows of current Table
    with TN_PSclonOneToken(Table.PDE(j))^ do
    begin
      Ind := SclonTableIndex.Add( STKey1 + STKey2 );
      SclonTableIndex.Objects[Ind] := Table.PDE(j);
    end; // for j := 0 to Table.AHigh() do // along all rows of current Table

  end; // for i := 0 to Maxi do // loop along all all SclonTables

end; // end of procedure TN_MEGlobObj.CreateSclonTableIndex

//**************************************** TN_MEGlobObj.GetSclonedToken ***
// Update PStringToUpdate^ by given AText
//
function TN_MEGlobObj.GetSclonedToken( AKey12: string; ACaseInd: integer ): string;
var
  Ind: integer;
  PTableRow: TN_PSclonOneToken;
begin
  Result := 'Not Found';
  Ind := SclonTableIndex.IndexOf( AKey12 );
  if Ind = -1 then Exit;

  PTableRow := TN_PSclonOneToken(SclonTableIndex.Objects[Ind]);

  case ACaseInd of
  0: Result := PTableRow^.STGender;
  1: Result := PTableRow^.STImenit;
  2: Result := PTableRow^.STRodit;
  3: Result := PTableRow^.STDatel;
  4: Result := PTableRow^.STVinit;
  5: Result := PTableRow^.STTvorit;
  6: Result := PTableRow^.STPredl;
  7: Result := PTableRow^.STSearchKeys;
  end; // case ACase of

end; // end of function TN_MEGlobObj.GetSclonedToken

//****************************************** TN_MEGlobObj.VBAParamsToMemIni ***
// Save VBA related Params to [VBAParams] section of N_MemIni
//
procedure TN_MEGlobObj.VBAParamsToMemIni();
begin
  N_SPLValToMemIni( 'VBAParams', 'WordFlags',  MEWordFlags,  N_SPLTC_MEWordFlags );
  N_SPLValToMemIni( 'VBAParams', 'WordPSMode', MEWordPSMode, N_SPLTC_MEWordPSMode );
  N_IntToMemIni( 'VBAParams', 'WordMinVersion', MEWordMinVersion );
end; // procedure TN_MEGlobObj.VBAParamsToMemIni();

//****************************************** TN_MEGlobObj.MemIniToVBAParams ***
// Restore VBA related Params from [VBAParams] section of N_MemIni
//
procedure TN_MEGlobObj.MemIniToVBAParams();
begin
  MEWordFlags := [mewfUseVBA, mewfUseWin32API];
  N_MemIniToSPLVal( 'VBAParams', 'WordFlags',  MEWordFlags,   N_SPLTC_MEWordFlags );
  MEWordPSMode := psmDelphiMem;
  N_MemIniToSPLVal( 'VBAParams', 'WordPSMode', MEWordPSMode,  N_SPLTC_MEWordPSMode );
  MEWordMinVersion := N_MemIniToInt( 'VBAParams', 'WordMinVersion', 8 );
end; // procedure TN_MEGlobObj.MemIniToVBAParams

//*************************************** TN_MEGlobObj.MECopyCoordsAndColor ***
// Copy given Coords And Color to clipboard and show them by N_Show1Str
//
procedure TN_MEGlobObj.MECopyCoordsAndColor( AX, AY, AColor: integer );
var
  Str, Comment: string;
begin
  with MEPrevMouseUpPoint do
    Str := Format( 'x,y=%d,%d  dx,dy=%d,%d C=$%6X', [AX, AY, AX-X, AY-Y, AColor] );

  if N_KeyIsDown( VK_LSHIFT ) then
  begin
    N_EditString( Comment, 'Comment:', 300 );
    Str := Str + ' ' + Comment;
  end;

//  N_ShowResponse( Str );
  N_Show1Str( Str );
  K_AddTextToClipboard( Str );

  MEPrevMouseUpPoint := Point( AX,AY );
end; // procedure TN_MEGlobObj.MECopyCoordsAndColor



//****************** TN_ShowStateString class methods  **********************

//**************************************** TN_ShowStateString.ShowState ***
// show given string by ShowStateProc procedure
//
procedure TN_ShowStateString.ShowState( AStr: string );
begin
  // empty procedure, should be overloaded
end; // end of procedure TN_ShowStateString.ShowState


//****************** TN_StateString class methods  **********************

//********************************************** TN_StateString.Create ***
//
constructor TN_StateString.Create;
begin
  Inherited;
  Flags := 0;
  Prefix := '';
  Protocol := TStringList.Create();
  ProgressTimer := TN_CPUTimer1.Create;
  ProgressTimer.Start();
end; //*** end of Constructor TN_StateString.Create

//********************************************** TN_StateString.Destroy ***
//
destructor TN_StateString.Destroy;
begin
  Protocol.Free;
  ProgressTimer.Free;
  //***** ShowProtocolForm is owned by Delphi and shoud be destroyd by Delphi
  //      or by User (closing it manually)
//  if ShowProtocolForm <> nil then
//    ShowProtocolForm.Close;
  Inherited;
end; //*** end of destructor TN_StateString.Destroy

//**************************************** TN_StateString.Show(1) ***
// show given string by ShowProc procedure (without adding to Protocol)
//
procedure TN_StateString.Show( AStr: string );
begin
  if Assigned(ShowStringProc) then ShowStringProc( Prefix + AStr );
end; // end of procedure TN_StateString.Show(1)

//**************************************** TN_StateString.Show(2) ***
// show given string and given Ratio in percents by ShowStringProc
// if more then 0.2 seconds passed from previous call
// (without adding to Protocol)
//
procedure TN_StateString.Show( AStr: string; Ratio: double );
begin
  ProgressTimer.Stop();
  if (ProgressTimer.DeltaCounter / N_CPUFrequency) > 0.2 then
  begin
    if Assigned(ShowStringProc) then ShowStringProc(  Prefix + AStr +
                                   Format( ' %.1f%1s', [100*Ratio, '%'] ));
    ProgressTimer.Start();
  end;
end; // end of procedure TN_StateString.Show(2)

//**************************************** TN_StateString.Add ***
// Show given message Astr and add it to Protocol StringList
//
procedure TN_StateString.Add( Astr: string );
begin
  ProgressTimer.BegCounter := 0;
  Show( AStr );
  if ((Flags and $01) <> 0) or (AStr = '') then Exit;
  Protocol.Add( Prefix + AStr );
end; // end of procedure TN_StateString.Add

//**************************************** TN_StateString.ShowProtocol ***
// Show Protocol in PlainEditorForm
//
procedure TN_StateString.ShowProtocol( AOwner: TN_BaseForm; AMode: integer );
begin
  if ShowProtocolForm = nil then // create Form if not yet
  begin
    ShowProtocolForm := N_CreatePlainEditorForm( AOwner );

    // add action that clears ShowProtocolForm field in OnClose event handler
    ShowProtocolForm.AddClearVarAction( @ShowProtocolForm, nil, 'ShowProtocolForm' );
  end;
//  Exit; // debug

  Assert( ShowProtocolForm is TN_PlainEditorForm, 'Bad Form Type' );

  with TN_PlainEditorForm(ShowProtocolForm) do
  begin
//    Memo.Lines.Text := Memo.Lines.Text + Protocol.Text;
    Memo.Lines.Text := Protocol.Text;
    Show();
    SetFocus();

    if AMode <> 0 then // show last portion of protocol
    with Memo do
    begin
      SelStart  := Length(Lines.Text)-1; // works only after Show() method
      SelLength := 0;                    // for Memo scrolling!
    end;
  end;
  Application.ProcessMessages; // to update screen
end; // end of procedure TN_StateString.ShowProtocol

//**************************************** TN_StateString.AddAndShowProtocol ***
// Add given ASrings to Protocol and Show it using ShowProtocol method
//
procedure TN_StateString.AddAndShowProtocol( AStrings: TStrings;
                                         AOwner: TN_BaseForm; AMode: integer );
begin
  Protocol.AddStrings( AStrings );
  ShowProtocol( AOwner, AMode );
end; // end of procedure TN_StateString.AddAndShowProtocol

var
  N_AddStrNumTimes: integer = 0; // bit0 for Chanel0, bit1 for Chanel1, ...

//**************************************************************** N_AddStr ***
// Add given AStr to file Chn#.txt (where # is given AChanel)
// in (#DebOutFiles#) dir and
// 1) before first (in session) string add Header with time stamp
// 2) if AStr = '##CURTIME' then add time stamp instead of AStr
//
procedure N_AddStr( AChanel: integer; AStr: string );
var
  Mask: integer;
  FName, WrkStr: string;
  FStream: TFileStream;
begin
  FName := K_ExpandFileName( '(#DebOutFiles#)Chn' +
                               IntToStr( AChanel ) + '.txt' );
  if FileExists( FName ) then
    FStream := TFileStream.Create( FName, fmOpenReadWrite )
  else
    FStream := TFileStream.Create( FName, fmCreate );

  FStream.Seek( 0, soFromEnd );

  Mask := 1 shl AChanel;

  if (N_AddStrNumTimes and Mask) = 0 then //*** Add additional header before first call
  begin
    N_AddStrNumTimes := N_AddStrNumTimes or Mask;
    FStream.Write( N_IntCRLF, 2*SizeOf(Char) );
    WrkStr := '### New Session: ***  ' + K_DateTimeToStr( Now() ) + '  ***';
    FStream.Write( WrkStr[1], Length(WrkStr) );
    FStream.Write( N_IntCRLF, 2*SizeOf(Char) );
  end; // if (N_AddStrNumTimes and Mask) = 0 then //*** Add additional header before first call

  if UpperCase(Trim(AStr)) = '##CURTIME' then // Show Cur Time instead of given AStr
    AStr := '   ***  ' + K_DateTimeToStr( Now() ) + '  ***';

  if Length(AStr) > 0 then
    FStream.Write( AStr[1], Length(AStr) );

  FStream.Write( N_IntCRLF, 2*SizeOf(Char) );

  FStream.Free;
end; // end of procedure N_AddStr

//**************************************** N_AddArray ***
// Add given string AStr to given AChanel
//
procedure N_AddArray( AChanel: integer; AStr: string; APDPoint: PDPoint; ANumPoints: integer );
var
  i: integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  SL.Add( AStr );

  for i := 0 to ANumPoints-1 do
  begin
    SL.Add( N_PointToStr( APDPoint^ ) );
    Inc( APDPoint );
  end;

  N_AddStr( AChanel, SL.Text );

  SL.Free;
end; // end of procedure N_AddArray


//****************  TN_RAFRAFontEditor class methods  ******************

//**************************************** TN_RAFRAFontEditor.Edit
// Own (by RaFrame) UDLogFont Editor (Old Font Format)
//
function TN_RAFRAFontEditor.Edit( var AData ) : Boolean;
var
  PRAFC: TK_PRAFColumn;
  OwnerForm:  TN_BaseForm;
  UObj: TN_UDBase;
begin
  Result := False;
  if RAFrame.Owner is TN_BaseForm then OwnerForm := TN_BaseForm( RAFrame.Owner )
                                  else OwnerForm := nil;
  with RAFrame do
  begin
    PRAFC := @RAFCArray[CurLCol];
    if PRAFC^.CDType.DTCode <> Ord(nptUDRef) then Exit;
  end; // with ARAFrame do

  UObj := TN_UDBase(AData);
  if not (UObj is TN_UDLogFont) then Exit; // a precaution

  N_EditParams( TN_UDLogFont(UObj), mmfNotModal, OwnerForm );

end; //*** procedure TN_RAFRAFontEditor.Edit

//****************  TN_RAFWinFontEditor class methods  ******************

//**************************************** TN_RAFWinFontEditor.Edit
// Windows LogFont Editor (Old Font Format)
//
function TN_RAFWinFontEditor.Edit( var AData ): Boolean;
var
  PRAFC: TK_PRAFColumn;
  OwnerForm:  TN_BaseForm;
  UObj: TN_UDBase;
begin
  Result := False;
  if RAFrame.Owner is TN_BaseForm then OwnerForm := TN_BaseForm( RAFrame.Owner )
                                  else OwnerForm := nil;
  with RAFrame do
  begin
    PRAFC := @RAFCArray[CurLCol];
    if PRAFC^.CDType.DTCode <> Ord(nptUDRef) then Exit;
  end; // with ARAFrame do

  UObj := TN_UDBase(AData);
  if not (UObj is TN_UDLogFont) then Exit; // a precaution

  Result := N_EditUDLogFont ( TN_UDLogFont(UObj), OwnerForm );
end; //*** procedure TN_RAFWinFontEditor.Edit

//****************  TN_RAFWinNFontEditor class methods  ******************

//**************************************** TN_RAFWinNFontEditor.Edit
// Windows NFont Editor
//
function TN_RAFWinNFontEditor.Edit( var AData ): Boolean;
var
  PRAFC: TK_PRAFColumn;
  OwnerForm:  TN_BaseForm;
  WasCreated : Boolean;
begin
  Result := False;
  if RAFrame.Owner is TN_BaseForm then OwnerForm := TN_BaseForm( RAFrame.Owner )
                                  else OwnerForm := nil;
  with RAFrame do
  begin
    PRAFC := @RAFCArray[CurLCol];
    if PRAFC^.CDType.DTCode <> N_SPLTC_NFont then Exit; // a precaution
  end; // with ARAFrame do

  WasCreated := TK_RArray(AData) = nil;
  if WasCreated then
    TK_RArray(AData) := K_RCreateByTypeName( 'TN_NFont', 1 );

  Result := N_EditNFont( N_GetPVArrayData( TObject(AData) ), OwnerForm );
  Result := WasCreated or Result;
end; //*** procedure TN_RAFWinNFontEditor.Edit


//****************  TN_RAFMLCoordsEditor class methods  ******************

//**************************************** TN_RAFMLCoordsEditor.Edit
// MapLayer.MLCObj Editor
//
function TN_RAFMLCoordsEditor.Edit( var AData ) : Boolean;
var
  PRAFC: TK_PRAFColumn;
  OwnerForm:  TN_BaseForm;
  UObj: TN_UDBase;
  UDMapLayer: TN_UDMapLayer;
  RAFrameForm: TComponent;
begin
  Result := False;
  if RAFrame.Owner is TN_BaseForm then OwnerForm := TN_BaseForm( RAFrame.Owner )
                                  else OwnerForm := nil;
  with RAFrame do
  begin
    RAFrameForm := Owner;
    PRAFC := @RAFCArray[CurLCol];
    if PRAFC^.CDType.DTCode <> Ord(nptUDRef) then Exit;
    if not (RAFrameForm is TN_RAEditForm) then Exit;
  end; // with ARAFrame do

  UObj := TN_UDBase(AData);
  if not (UObj is TN_UCObjLayer) then Exit; // a precaution

  UDMapLayer := TN_UDMapLayer(TN_RAEditForm(RAFrameForm).RecordUObj);

  N_EditMapLayerCoords( UDMapLayer, OwnerForm );
end; //*** procedure TN_RAFMLCoordsEditor.Edit


//****************** Global procedures **********************

function N_GetPCurArchAttr(): TK_PArchive;
// Get Pointer to Current Archive Attributes
begin
  Result := TK_PArchive(TK_UDRArray(K_CurArchive).R.P);
end; // function N_GetPCurArchAttr

//************************************************ N_InitVREArchGCont
//
procedure N_InitVREArchGCont( UDArchive : TN_UDBase = nil );
begin
//*** create new archive if needed
  if UDArchive = nil then UDArchive := K_CurArchive;

  K_InitMVDarGCont0( UDArchive );
  N_InitVREArchive( UDArchive );
  K_InitMVDarGCont1( UDArchive );
end; //*** end of procedure N_InitVREArchGCont

//************************************************ N_InitVRCMArchGCont
//
procedure N_InitVRCMArchGCont( UDArchive : TN_UDBase = nil );
begin
//*** create new archive if needed
  if UDArchive = nil then UDArchive := K_CurArchive;

  K_InitMVDarGCont0( UDArchive );
  N_InitVREArchive( UDArchive );
//  N_InitCMSArchive( UDArchive );
  K_InitMVDarGCont1( UDArchive );
end; //*** end of procedure N_InitVRCMArchGCont

procedure  N_InitVREArchive( UDArchive: TN_UDBase );
// Initialize Archive for VRE Project
// (create needed UDBase and global objects, set needed global variables)
var
  UDRArray: TK_UDRArray;
begin
  //***** Create standard Archive UObjects and set global pointers to them
  //      (N_MapEditorDir,N_SysDir,N_DefObjectsDir,DefFont,DefSysLines)

  N_MapEditorDir := UDArchive.DirChildByObjName( 'MapEditor' );
//  N_MapEditorDir := N_GetUObj( UDArchive, 'MapEditor' );
  if N_MapEditorDir = nil then
    N_MapEditorDir := UDArchive.DirChildByObjName( 'ME' );
//    N_MapEditorDir := N_GetUObj( UDArchive, 'ME' );
  if N_MapEditorDir = nil then
    N_MapEditorDir := K_AddArchiveSysDir( 'ME', K_sftSkipAll, UDArchive );

  //************************* System  N_SysDir and it's SubDirs and UObjects

  N_SysDir := N_MapEditorDir.DirChildByObjName( 'System' );
//  N_SysDir := N_GetUObj( N_MapEditorDir, 'System' );
  if N_SysDir = nil then
    N_SysDir := N_MapEditorDir.DirChildByObjName( 'Sys' );
//    N_SysDir := N_GetUObj( N_MapEditorDir, 'Sys' );
  if N_SysDir = nil then
    N_SysDir := K_AddArchiveSysDir( 'Sys', K_sftSkipAll, N_MapEditorDir );

{
  N_SclonTablesDir := N_GetUObj( N_SysDir, 'SclonTables' );
  if N_SclonTablesDir = nil then
    N_SclonTablesDir := K_AddArchiveSysDir( 'SclonTables', K_sftReplace, N_SysDir );
  N_MEGlobObj.CreateSclonTableIndex();
}
  N_DefObjectsDir := N_SysDir.DirChildByObjName( 'DefObjects' );
//  N_DefObjectsDir := N_GetUObj( N_SysDir, 'DefObjects' );
  if N_DefObjectsDir = nil then
    N_DefObjectsDir := N_SysDir.DirChildByObjName( 'Def' );
//    N_DefObjectsDir := N_GetUObj( N_SysDir, 'Def' );
  if N_DefObjectsDir = nil then
    N_DefObjectsDir := K_AddArchiveSysDir( 'Def', K_sftReplace, N_SysDir );

  with N_DefObjectsDir do
  begin
    UDRArray := TK_UDRArray(N_DefObjectsDir.DirChildByObjName( 'DefFont' ));
//    UDRArray := TK_UDRArray(N_GetUObj( N_DefObjectsDir, 'DefFont' ));
    if UDRArray = nil then
      AddOneChild( N_CreateUDFont( 'DefFont', 'Arial', 16, [] ) );

    UDRArray := TK_UDRArray(N_DefObjectsDir.DirChildByObjName( N_DefNFontName ));
//    UDRArray := TK_UDRArray(N_GetUObj( N_DefObjectsDir, N_DefNFontName ));
    if UDRArray = nil then // create new NFont
    begin
      UDRArray := TN_UDNFont.Create2( 16, 'Arial' );
      AddOneChild( UDRArray );
      UDRArray.ObjName := N_DefNFontName;
    end; // if UDRArray = nil then // create new NFont

    UDRArray := TK_UDRArray(N_DefObjectsDir.DirChildByObjName( N_DefSysLinesName ));
//    UDRArray := TK_UDRArray(N_GetUObj( N_DefObjectsDir, N_DefSysLinesName ));
    if UDRArray = nil then // create new SysLineAttr
    begin
      UDRArray := K_CreateUDByRTypeName( 'TN_SysLineAttr', 1 );
      AddOneChild( UDRArray );
      UDRArray.ObjName := N_DefSysLinesName;
    end; // if UDRArray = nil then // create new SysLineAttr
  end; // with N_DefObjectsDir do

  N_TmpObjectsDir := N_SysDir.DirChildByObjName( 'TmpObjects' );
//  N_TmpObjectsDir := N_GetUObj( N_SysDir, 'TmpObjects' );
  if N_TmpObjectsDir = nil then
    N_TmpObjectsDir := N_SysDir.DirChildByObjName( 'Tmp' );
//    N_TmpObjectsDir := N_GetUObj( N_SysDir, 'Tmp' );
  if N_TmpObjectsDir = nil then
    N_TmpObjectsDir := K_AddArchiveSysDir( 'Tmp', K_sftReplace, N_SysDir );

  N_GlobUserParams := TN_UDCompBase(N_SysDir.DirChildByObjName( 'GlobUserParams' ));
//  N_GlobUserParams := TN_UDCompBase(N_GetUObj( N_SysDir, 'GlobUserParams' ));
  if N_GlobUserParams = nil then
  begin
    N_GlobUserParams := TN_UDCompBase(K_CreateUDByRTypeName( 'TN_RCompBase', 1, N_UDCompBaseCI ));
    N_GlobUserParams.ObjName := 'GlobUserParams';
    N_SysDir.AddOneChildV( N_GlobUserParams );
  end;

  //***** Create Global objects not represented in Archive

  if N_DefContAttr = nil then
    N_DefContAttr := K_RCreateByTypeName( 'TN_ContAttr', 1 );

  if N_DefStrokeContAttr = nil then
  begin
    N_DefStrokeContAttr := K_RCreateByTypeName( 'TN_ContAttr', 1 );
    with TN_PContAttr(N_DefStrokeContAttr.P(0))^ do
      CABrushColor := N_EmptyColor; // no fill for drawing by StrokePath
  end;

end; // procedure  N_InitVREArchive

//*******************************************  N_GetCObjR  ******
// find and return CObj by given Name(Path) in Read mode
// raise exception if not found (and AClassInd <> -2) or it's ClassFlags
// are not AClassInd (and AClassInd <> -1)
//
function N_GetCObjR( CObjName: string; AClassInd: integer ): TN_UCObjLayer;
begin
  Result := TN_UCObjLayer(N_MapEditorDir.DirChildByObjName( CObjName ));
//  Result := TN_UCObjLayer(N_GetUObj( N_MapEditorDir, CObjName ));
  if AClassInd = -2 then Exit; // any Result is OK

  if Result <> nil then
  begin
    if (Result.CI = AClassInd) or (AClassInd  = -1 ) then Exit;

    //*** Cobj exists, but is not of needed type
    raise Exception.Create( 'CObj  "' + CObjName + '" is not of needed Type!' );
  end else // not found
    raise Exception.Create( 'CObj  "' + CObjName + '"  not found!' );
end; // end of function N_GetCObjR

//*******************************************  N_GetCObjW  ******
// find and return CObj by given Name in Write mode
// create or change Cobj type if needed
// ask if CObj with given Name already exists and return nil if it
// should not be overwritten
//
function N_GetCObjW( CObjName: string; AClassInd: integer;
                                          AWLCType: integer ): TN_UCObjLayer;
var
  RootDir: TN_UDBase;
begin
  Assert( AClassInd <> -1, 'Bad ClassInd' );
  RootDir := N_MapEditorDir;
  if AClassInd = K_UDRArrayCI then RootDir := N_MapEditorDir;

  Result := TN_UCObjLayer(RootDir.DirChildByObjName( CObjName ));
//  Result := TN_UCObjLayer(N_GetUObj( RootDir, CObjName ));

  if Result <> nil then
  begin
    if mrCancel = N_MessageDlg( 'OBject "' + CObjName + '" already exists.' +
                        #13#10' Overwrite it? ', mtWarning, mbOKCancel, 0 ) then
    begin
      Result := nil;
      Exit;
    end;

    if AClassInd = N_ULinesCI then
    begin
      if (Result.CI = AClassInd) and (Result.WLCType = AWLCType) then Exit;
    end else // not Lines, WCLType does not matter
      if Result.CI = AClassInd  then Exit;

    //*** Cobj exists, but is not of needed type, delete it
    RootDir.DeleteOneChild( Result );
  end;

  //***** Create New CObj with given Name and type

  if AClassInd = K_UDRArrayCI then
    Result := TN_UCObjLayer(K_CreateUDByRTypeName( 'strings', 1 )) // temporary
  else
    Result := TN_UCObjLayer(N_ClassRefArray[AClassInd].Create());

  Result.ObjName := CObjName;
//  N_CObjectsDir.AddOneChild( Result );
  N_MapEditorDir.AddOneChildV( Result ); // OK??
  if AClassInd = N_ULinesCI then Result.WLCType := AWLCType;
end; // end of function N_GetCObjW

{
//*******************************************  N_SetFormDescrVar  ******
// Set Form Description Variant by Shift and Control keys
//
function N_SetFormDescrVar(): integer;
begin
  Result := 0;
  if N_KeyIsDown( N_VKShift ) then Result := 1;
  if N_KeyIsDown( N_VKControl ) then Result := Result + 2;
end; // function N_SetFormDescrVar
}

//******************************************** N_CreateMapPanel(UDMapLayer) ***
// Create and return MapPanel with one given AUDMapLayer
//
//     Parameters
// AUDMapLayer - Given Map Layer
//
// Set MapPanel CompUCoords by AUDMapLayer.Owner or by AUDMapLayer.MLCObj EnvRect
//
function N_CreateMapPanel( AUDMapLayer: TN_UDMapLayer ): TN_UDPanel;
var
  U: TN_UDbase;
  CObj: TN_UCObjLayer;
  EnvRect: TFRect;
  CC: TN_CompCoords;
  CalcUCoords: boolean;
begin
  Result := TN_UDPanel(K_CreateUDByRTypeName( 'TN_RPanel', 1, N_UDPanelCI ));
  Result.ObjName := 'TmpMap_' + AUDMapLayer.ObjName;
  Result.AddOneChild( AUDMapLayer );

  CC := AUDMapLayer.PCCS()^;

  if CC.UCoordsType <> cutParent then // given AUDMapLayer has own CompUCoords of some type, all done
    Exit
  else //*** CC.UCoordsType = cutParent, given AUDMapLayer uses it's Parent User coords
  begin
    // First try to use AUDMapLayer.Owner User Coords, if they are not given,
    // use AUDMapLayer MLCObj EnvRect

    CalcUCoords := True;
    U := AUDMapLayer.Owner;

    if U is TN_UDCompVis then // Owner has TN_CompCoords field
    begin
      CC := TN_UDCompVis(U).PCCS()^;

      if CC.UCoordsType <> cutParent then // Owner has own CompUCoords, use it
      begin
        EnvRect := CC.CompUCoords;
        CalcUCoords := False;
      end else // try next level Owner
      begin
        U := U.Owner;

        if U is TN_UDCompVis then // Owner.Owner has TN_CompCoords field
        begin
          CC := TN_UDCompVis(U).PCCS()^;
          if CC.UCoordsType <> cutParent then // Owner.Owner has own CompUCoords, use it
          begin
            EnvRect := CC.CompUCoords;
            CalcUCoords := False;
          end;
        end; // if U is TN_UDCompVis then
      end; // else // try next Owner
    end; // if U is TN_UDCompVis then // Owner has TN_CompCoords field

    if CalcUCoords then // Use AUDMapLayer MLCObj EnvRect
    begin
      CObj := TN_PRMapLayer(AUDMapLayer.R.P())^.CMapLayer.MLCObj;
      EnvRect := N_RectScaleR ( CObj.WEnvRect, 1.1, DPoint(0.5,0.5) );
    end;

    with Result.PCCS()^ do // Set Resulting Panel CompUCoords by just calculated EnvRect variable
    begin
      CompUCoords   := EnvRect;
      UCoordsType   := cutGiven;
      UCoordsAspect := 1;
    end; // with Result.PCCS()^ do // Set Resulting Panel CompUCoords by just calculated EnvRect variable

    Result.PCPanelS()^.PaBackColor := $BFBFBF; // Set Created Map Panel Backgroung to Gray
  end; // else //*** CC.UCoordsType = cutParent, given AUDMapLayer uses it's Parent User coords

end; // end of function N_CreateMapPanel(By UDMapLayer)

//****************************************  N_CreateMapPanel(By CObjLayer)  ******
// Create and return Map Panel with one created UDMapLayer based on given ACobjLayer
//
function N_CreateMapPanel( ACObjLayer: TN_UCObjLayer ): TN_UDPanel;
var
  UDML: TN_UDMapLayer;
begin
  Assert( ACObjLayer <> nil, N_SError );

  UDML := N_CreateUDMapLayer( ACObjLayer, mltNotDef );
  Result := N_CreateMapPanel( UDML );
end; // end of function N_CreateMapPanel(By CObjLayer)

//*******************************************  N_ViewCObjLayer  ******
// create new temporary UDCMap with given ACObjLayer and View it (not modal)
// in new or given RastVCTForm
//
procedure N_ViewCObjLayer( ACObjLayer: TN_UCObjLayer; PRForm: TN_PRastVCTForm;
                                                          AOwner: TN_BaseForm );
var
  UDMap: TN_UDPanel;
begin
  // contours may have WEnvRect not set just after loading from text (*.sdt)
  if ACObjLayer.WEnvRect.Left = N_NotAFloat then ACObjLayer.CalcEnvRects();
  UDMap := N_CreateMapPanel( ACObjLayer );
//  ACObjLayer.AddOneChildV( UDMap ); // debug!!!
  N_ViewCompFull( UDMap, PRForm, AOwner, 'CObjLayer - ' + ACObjLayer.ObjName );
end; // procedure N_ViewCObjLayer

//*******************************************  N_ViewPicture  ******
// create new temporary UDPicture by given File Name and View it (not modal)
// in new or given RastVCTForm
//
procedure N_ViewPicture( AFileName: string; PRForm: TN_PRastVCTForm;
                                                          AOwner: TN_BaseForm );
var
  UDPict: TN_UDPicture;
begin
  UDPict := N_CreateUDPicture( cptFile, rtBArray, AFileName );
  N_ViewCompFull( UDPict, PRForm, AOwner, 'Picture - ' );
end; // procedure N_ViewPicture

//*******************************************  N_ViewMapLayer  ******
// if given MapLayer has self UserCoords, show it and return it,
// otherwise create and return new temporary Map Panel with given AMapLayer
// and Show it (not modal) in new or given RastVCTForm
//
function N_ViewMapLayer( AMapLayer: TN_UDMapLayer; PRForm: TN_PRastVCTForm;
                                         AOwner: TN_BaseForm ): TN_UDCompVis;
begin
  with AMapLayer.PCCS()^ do
  begin
    if UCoordsType <> cutParent then // use self CompUCoords
    begin
      N_ViewCompFull( AMapLayer, PRForm, AOwner, 'AMapLayer - ' );
      Result := AMapLayer;
    end else // Self UCoords are absent, try to use MapLayer Owner CompUCoords
    begin
      Result := N_CreateMapPanel( AMapLayer );
      N_ViewCompFull( Result, PRForm, AOwner, 'AMapLayer - ' + AMapLayer.ObjName );
    end;
  end; // with AMapLayer.PCCD()^ do
end; // function N_ViewMapLayer

//*******************************************  N_ViewUObjAsMap  ******
// View given UObj as Map
//
var
  Ind: integer;
  MarkGroup: TN_SGBase;
  MarkCompAction: TN_RFAMarkComps;
procedure N_ViewUObjAsMap( UObj: TN_UDBase; PRForm: TN_PRastVCTForm;
                                                        AOwner: TN_BaseForm );
begin
  if UObj is TN_UCObjLayer then //****************** CoordsObj Layer
  begin
    N_ViewCObjLayer( TN_UCObjLayer(UObj), PRForm, AOwner  );
  end else if UObj is TN_UDMapLayer then //********* Map Layer
  begin
    N_ViewMapLayer( TN_UDMapLayer(UObj), PRForm, AOwner );
  end else if UObj is TN_UDCompVis then //********** Visual Component
  begin
    N_ViewCompFull( TN_UDCompVis(UObj), PRForm, AOwner, UObj.ObjName );
  end;

  if N_ActiveVTreeFrame <> nil then // create MarkComp RFrame Group and Action
  begin
    Application.ProcessMessages(); // Is really needed?
    if N_ActiveRFrame <> nil then
    with N_ActiveRFrame do
    begin
      Ind := GetGroupInd( N_SMarkCompGName );

      if Ind >= 0 then // Group was already created, set Result.MCAction field
      begin
        MarkGroup := TN_SGBase(RFSGroups.Items[Ind]);
        MarkCompAction := TN_RFAMarkComps(MarkGroup.GroupActList.Items[0]);
      end else // create new Group and MoveComps RFrame Action in it
      begin
        MarkGroup := TN_SGBase.Create( N_ActiveRFrame );
        RFSGroups.Add( MarkGroup );
        MarkGroup.GName := N_SMarkCompGName;
        MarkCompAction := TN_RFAMarkComps(MarkGroup.SetAction( N_ActMarkComps, 0, -1, 0 ));
      end;

      MarkCompAction.RFANVTreeFrame := N_ActiveVTreeFrame;
      N_ActiveVTreeFrame.MarkedChanged := True;
    end; // with N_ActiveRFrame do
  end;
end; // procedure N_ViewUObjAsMap

//*******************************************  N_ViewCompMain  ******
// View the result of given Component (UObj) By Main Viewer, using N_MEGlobObj.NVGlobCont
// ( View GDI Pict in Memory, HTML File by Delphi Browser, MS Office Document by MS Office )
//
procedure N_ViewCompMain( AUObj: TN_UDBase; AShowResponse: TN_OneStrProcObj = nil;
                                                        AOwner: TN_BaseForm = nil );
var
  FName: string;
  ExpFlags: TN_CompExpFlags;
  WrkExpParams: TN_ExpParams;
  AComp: TN_UDCompBase;
begin
  if not (AUObj is TN_UDCompBase) then Exit; // not a Component
  AComp := TN_UDCompBase(AUObj);

  if Assigned(AShowResponse) then AShowResponse( '' );

  ExpFlags := AComp.GetExpFlags();

  if cefWordDoc in ExpFlags then //**************** View MS Word Document
  begin

    WrkExpParams := AComp.GetPExpParams()^;
    WrkExpParams.EPExecFlags := WrkExpParams.EPExecFlags; // + [epefNotCloseDoc,epefShowAfter];

    N_MEGlobObj.NVGlobCont.ExecuteRootComp( AComp, [], AShowResponse,
                                                       AOwner, @WrkExpParams );

  end else if cefExcelDoc in ExpFlags then //****** View MS Excel Document
  begin

    WrkExpParams := AComp.GetPExpParams()^;
    WrkExpParams.EPExecFlags := WrkExpParams.EPExecFlags; // + [epefNotCloseDoc,epefShowAfter];

    N_MEGlobObj.NVGlobCont.ExecuteRootComp( AComp, [], AShowResponse,
                                                       AOwner, @WrkExpParams );

  end else if cefGDI in ExpFlags then //*** View as in memory GDI Picture
  begin
    N_MEGlobObj.NVGlobCont.GCShowResponseProc := AShowResponse;

    if N_KeyIsDown( N_VKShift ) then // View in separate Window
      N_ViewUObjAsMap( AUObj, nil, AOwner )
    else // View in already opened Window (if any) or create new Window
      N_ViewUObjAsMap( AUObj, @N_MEGlobObj.RastVCTForm, AOwner );

    N_MEGlobObj.NVGlobCont.GCShowResponseProc := nil;

  end else if cefTextFile in ExpFlags then //**** View by Delphi HTML Browser
  begin
    //***** AUObj should Executed (exported to File) before Viewing

    with N_MEGlobObj.NVGlobCont do
    begin
      ExecuteRootComp( AComp, [], AShowResponse, AOwner );
      FName := GCMainFileName;
    end; // with N_MEGlobObj.NVGlobCont do

    if FName <> '' then // a precaution
      with N_GetMEWebBrForm( AOwner ) do
      begin
        Show(); // Show should be called before Navigate !
        WebBr.Navigate( 'file://' + FName );
      end;

  end; //  else if cefTextFile in ExpFlags then // View by Delphi HTML Browser

end; // procedure N_ViewCompMain

//*******************************************  N_GetTextEditorForm(full)  ******
// Get existed or create new Editor form and
// return TStrings obj of this Form
//
// APForm - Pointer to some EditorForm or nil, if new Form should be created
// AOwner  - Owner of new Editor Form (is used only if APForm=nil or APForm^=nil)
// EditorStrings - TStrings property of used Editor
//
// In EditorForm.FormClose APForm^ will be cleared (if APForm <> nil) so APForm^
// variable should exists at the moment when EditorForm.FormClose is executed.
// If APForm^ <> nil just return EditorStrings
//
// now PlainEditor is used as Text Editor
//
procedure N_GetTextEditorForm( var APForm: TN_PBaseForm; AOwner: TN_BaseForm;
                                                  out EditorStrings: TStrings );
var
  TmpForm: TN_PlainEditorForm;
  NewForm: boolean;
begin
  NewForm := False;

  if APForm = nil then // new temporary PlainEditorForm should be created
  begin
    TmpForm := N_CreatePlainEditorForm( AOwner );
    N_PlaceTControl( TmpForm, AOwner );
    APForm := @TN_BaseForm(TmpForm);
    NewForm := True;
  end else if APForm^ = nil then // new PlainEditorForm should be created in
  begin                           // given variable, pointed to by APForm
    APForm^ := N_CreatePlainEditorForm( AOwner );
    APForm^.BFOnCloseActions.AddNewClearVarAction( APForm );
    N_PlaceTControl( APForm^, AOwner );
    NewForm := True;
  end;

  with TN_PlainEditorForm(APForm^) do
  begin
    if NewForm then Show();
    EditorStrings := Memo.Lines;
  end;

end; // end of procedure N_GetTextEditorForm(full)

//*****************************************  N_GetTextEditorForm(short)  ******
// Call full version of N_GetTextEditorForm with @N_MEGlobObj.TextEdForm
//
procedure N_GetTextEditorForm( AOwner: TN_BaseForm; out EditorStrings: TStrings );
var
  PEditorForm: TN_PBaseForm;
begin
  PEditorForm := @N_MEGlobObj.TextEdForm;
  N_GetTextEditorForm( PEditorForm, AOwner, EditorStrings );
end; // end of procedure N_GetTextEditorForm(short)

//******************************************  N_GetMEPlainEditorForm(1)  ******
// Get existed or create new PlainEditor form using N_MEGlobObj flags
//
function N_GetMEPlainEditorForm( AOwner: TN_BaseForm ): TN_PlainEditorForm;
var
  PForm: TN_PPlainEditorForm;
begin
  with N_MEGlobObj do
  begin
    PForm := @PlainEdForm; // use same window for all PlainEditor instancies

    if   NewEdWindow or
       ( AutoNewEdWindow and N_KeyIsDown(VK_Shift) ) then
    PForm := nil; // create new separate window
  end; // with N_MEGlobObj do

  N_GetMEPlainEditorForm( PForm, AOwner );
  Result := PForm^;
end; // end of procedure N_GetMEPlainEditorForm(1)

//******************************************  N_GetMEPlainEditorForm(2)  ******
// Get existed or create new PlainEditor form
//
// APForm - Pointer to some PlainEditorForm or nil, if new Form should be created
// AOwner - Owner of new Editor Form (is used only if APForm=nil or APForm^=nil)
//
// In EditorForm.FormClose APForm^ will be cleared (if APForm <> nil), so APForm^
// variable should exists at the moment when EditorForm.FormClose is executed.
// If APForm^ <> nil nothing should be done
//
procedure N_GetMEPlainEditorForm( var APForm: TN_PPlainEditorForm; AOwner: TN_BaseForm );
var
  TmpForm: TN_PlainEditorForm;
begin
  if APForm = nil then // new PlainEditorForm should be created
  begin
    TmpForm := N_CreatePlainEditorForm( AOwner );
    N_PlaceTControl( TmpForm, AOwner );
    APForm := @TmpForm;
  end else if APForm^ = nil then // new PlainEditorForm should be created in
  begin                           // given variable, pointed to by APForm
    APForm^ := N_CreatePlainEditorForm( AOwner );
    APForm^.BFOnCloseActions.AddNewClearVarAction( APForm );
    N_PlaceTControl( APForm^, AOwner );
  end;
end; // end of procedure N_GetMEPlainEditorForm(2)

//*******************************************  N_GetMERichEditorForm(1)  ******
// Get existed or create new RichEditor form using N_MEGlobObj flags
//
function N_GetMERichEditorForm( AOwner: TN_BaseForm ): TN_RichEditorForm;
var
  PForm: TN_PRichEditorForm;
begin
  with N_MEGlobObj do
  begin
    PForm := @RichEdForm; // use same window for all instancies

    if   NewEdWindow or
       ( AutoNewEdWindow and N_KeyIsDown(VK_Shift) ) then
    PForm := nil; // create separate window
  end; // with N_MEGlobObj do

  N_GetMERichEditorForm( PForm, AOwner );
  Result := PForm^;
end; // end of procedure N_GetMERichEditorForm(1)

//*******************************************  N_GetMERichEditorForm(2)  ******
// Get existed or create new RichEditor form
//
// APForm - Pointer to some RichEditorForm or nil, if new Form should be created
// AOwner  - Owner of new Editor Form (is used only if APForm=nil or APForm^=nil)
//
// in EditorForm.FormClose APForm^ will be cleared (if APForm <> nil)
//
procedure N_GetMERichEditorForm( var APForm: TN_PRichEditorForm; AOwner: TN_BaseForm );
var
  TmpForm: TN_RichEditorForm;
begin
  if APForm = nil then // new RichEditorForm should be created
  begin
    TmpForm := N_CreateRichEditorForm( AOwner );
    N_PlaceTControl( TmpForm, AOwner );
    APForm := @TmpForm;
  end else if APForm^ = nil then // new RichEditorForm should be created in
  begin                           // given variable, pointed to by APForm
    APForm^ := N_CreateRichEditorForm( AOwner );
    APForm^.BFOnCloseActions.AddNewClearVarAction( APForm );
    N_PlaceTControl( APForm^, AOwner );
  end;
end; // end of procedure N_GetMERichEditorForm(2)

//*******************************************  N_GetMERastVCTForm(1)  ******
// Get existed or create new RVCT form using N_MEGlobObj flags
//
function N_GetMERastVCTForm( AOwner: TN_BaseForm ): TN_RastVCTForm;
var
  PForm: TN_PRastVCTForm;
begin
  with N_MEGlobObj do
  begin
    PForm := @RastVCTForm; // use same window for all instancies

    if   NewEdWindow or
       ( AutoNewEdWindow and N_KeyIsDown(VK_Shift) ) then
    PForm := nil; // create separate window
  end; // with N_MEGlobObj do

  N_GetMERastVCTForm( PForm, AOwner );
  Result := PForm^;
end; // end of procedure N_GetMERastVCTForm(1)

//*******************************************  N_GetMERastVCTForm(2)  ******
// Get existed or create new RVCT form
//
// APForm - Pointer to some RastVCTForm or nil, if new Form should be created
// AOwner  - Owner of new Editor Form (is used only if APForm=nil or APForm^=nil)
//
// in EditorForm.FormClose APForm^ will be cleared (if APForm <> nil)
//
procedure N_GetMERastVCTForm( var APForm: TN_PRastVCTForm; AOwner: TN_BaseForm );
var
  TmpForm: TN_RastVCTForm;
begin
  if APForm = nil then // new RastVCTForm should be created
  begin
    TmpForm := N_CreateRastVCTForm( AOwner );
    N_PlaceTControl( TmpForm, AOwner );
    APForm := @TmpForm;
  end else if APForm^ = nil then // new RastVCTForm should be created in
  begin                           // given variable, pointed to by APForm
    APForm^ := N_CreateRastVCTForm( AOwner );
    APForm^.BFOnCloseActions.AddNewClearVarAction( APForm );
    N_PlaceTControl( APForm^, AOwner );
  end;
end; // end of procedure N_GetMERastVCTForm(2)

//*******************************************  N_GetMEWebBrForm(1)  ******
// Get existed or create new RVCT form using N_MEGlobObj flags
//
function N_GetMEWebBrForm( AOwner: TN_BaseForm ): TN_WebBrForm;
var
  PForm: TN_PWebBrForm;
begin
  with N_MEGlobObj do
  begin
    PForm := @WebBrForm; // use same window for all instancies

    if   NewEdWindow or
       ( AutoNewEdWindow and N_KeyIsDown(VK_Shift) ) then
    PForm := nil; // create separate window
  end; // with N_MEGlobObj do

  N_GetMEWebBrForm( PForm, AOwner );
  Result := PForm^;
end; // end of procedure N_GetMEWebBrForm(1)

//*******************************************  N_GetMEWebBrForm(2)  ******
// Get existed or create new RVCT form
//
// APForm - Pointer to some WebBrForm or nil, if new Form should be created
// AOwner  - Owner of new Editor Form (is used only if APForm=nil or APForm^=nil)
//
// in EditorForm.FormClose APForm^ will be cleared (if APForm <> nil)
//
procedure N_GetMEWebBrForm( var APForm: TN_PWebBrForm; AOwner: TN_BaseForm );
var
  TmpForm: TN_WebBrForm;
begin
  if APForm = nil then // new WebBrForm should be created
  begin
    TmpForm := N_CreateWebBrForm( AOwner );
    N_PlaceTControl( TmpForm, AOwner );
    APForm := @TmpForm;
  end else if APForm^ = nil then // new WebBrForm should be created in
  begin                           // given variable, pointed to by APForm
    APForm^ := N_CreateWebBrForm( AOwner );
    APForm^.BFOnCloseActions.AddNewClearVarAction( APForm );
    N_PlaceTControl( APForm^, AOwner );
  end;
end; // end of procedure N_GetMEWebBrForm(2)

//*******************************************  N_AddUObjSysInfo  ******
// Add Sys info about given UObj to given AStrings
//
procedure N_AddUObjSysInfo( UObj: TN_UDBase; AStrings: TStrings );
begin
  if UObj = nil then
  begin
    AStrings.Add( '  UObj is nil' );
    Exit; // a precaution
  end;

  UObj.SaveToStrings( AStrings, 0 );
  AStrings.Add( '' );
end; // procedure N_AddUObjSysInfo

//*******************************************  N_ViewUObjInfo  ******
// View Info about given UObj
//
procedure N_ViewUObjInfo( UObj: TN_UDBase; APForm: TN_PBaseForm;
                                                       AOwner: TN_BaseForm );
var
  Str: string;
  SL: TStrings;
  PCMapLayer: TN_PCMapLayer;
  RACSD: TK_RArray;

  procedure AddCSDimInfo( AR: TK_RArray ); // local
  begin
    SL.Add( ' Number of Elements:   ' + IntToStr( AR.ALength() ) );
    SL.Add( ' Codes Dimension Name: ' + K_GetRACSDimCDim( AR ).ObjName );
  end; // procedure AddCSDimInfo - local

begin
  if UObj = nil then Exit; // a precaution
  N_GetTextEditorForm( APForm, AOwner, SL );
  SL.Clear();
  SL.Add( '' );

  if UObj is TN_UCObjLayer then           //******************* CoordsObj Layer
  begin
    SL.Add( '***** Info about CoordsObj Layer "' + UObj.ObjName + '":' );
    TN_UCObjLayer(UObj).GetSelfInfo( SL, 0 );
  end else if UObj is TN_UDMapLayer then //**************** Map Layer Component
  begin
    PCMapLayer := TN_UDMapLayer(UObj).PISP();
    K_CurArchive.RefPath := K_ArchiveCursor; // Restore Archive RefPath
    K_SaveSPLDataToSTBuf( PCMapLayer^, K_GetTypeCodeSafe( 'TN_CMapLayer' ),
                                    K_SerialTextBuf, UObj, UObj.ObjName );
    SL.Text := K_SerialTextBuf.TextStrings.Text;
    SL.Insert( 0, '***** Info about Map Layer "' + UObj.ObjName + '":' );
  end else if UObj is TN_UDCompBase then //**************** any other Component
  begin
    SL.Add( '***** Info about Component "' + UObj.ObjName + '":' );
    SL.Add( '  Component Type is  ' + N_ClassTagArray[UObj.CI] + ' (' +
                                                      UObj.ClassName  + ')' );
    Str := TN_UDCompBase(UObj).PDP()^.CCompBase.CBComment;
    if Str <> '' then
    begin
      SL.Add( Str );
      SL.Add( '' );
    end;
  end else if (UObj is TK_UDCDim) then //********************** Codes Dimension
  begin
    with TK_UDCDim(UObj) do
    begin
      SL.Add( '***** Info about Codes Dimension Obj "' + UObj.ObjName + '":' );
      SL.Add( ' Number of Elements:  ' + IntToStr( GetCDimCount() ) );
    end
  end else if (UObj is TK_UDCSDim) then //****************** Codes SubDimension
  begin
    with TK_UDCSDim(UObj) do
    begin
      SL.Add( '***** Info about Codes SubDimension Obj "' + UObj.ObjName + '":' );
      AddCSDimInfo( R );
    end
  end else if (UObj is TK_UDCDCor) then //********* SubDimensions Relation
  begin
    with TK_UDCDCor(UObj) do
    begin
      SL.Add( '***** Info about Codes SubDimensions Relation Obj "' + UObj.ObjName + '":' );
      SL.Add( '  Primary SubDimension:' );
      AddCSDimInfo( GetPrimRACSDim() );
      SL.Add( '  Secondary SubDimension:' );
      AddCSDimInfo( GetSecRACSDim() );
    end
  end else if (UObj is TK_UDCSDBlock) then //*********************** Data Block
  begin
    with TK_UDCSDBlock(UObj) do
    begin
      SL.Add( '***** Info about Data Block Obj "' + UObj.ObjName + '":' );
      RACSD := GetRowRACDRel();
      if RACSD <> nil then
      begin
        SL.Add( '  Rows Codes SubDimension:' );
        AddCSDimInfo( RACSD );
      end;
      RACSD := GetColRACDRel();
      if RACSD <> nil then
      begin
        SL.Add( '  Columns Codes SubDimension:' );
        AddCSDimInfo( RACSD );
      end;
      N_AddRArrayInfo( R, SL );
    end
  end else if (UObj is TK_UDVector) and not (UObj is TK_UDDCSSpace) then // UDVector
  begin
    with TK_UDVector(UObj) do
    begin
    SL.Add( '***** Info about UDVector "' + UObj.ObjName + '":' );
    SL.Add( ' Elements Type:  ' + K_GetExecTypeName( PDRA^.ElemType.All ) );
    SL.Add( ' Number of Elements:  ' + IntToStr(PDRA.ALength) );
//    SL.Add( ' Codes SubSpace Aliase: ' + GetDCSSpace().ObjAliase + '  (' +
//                                         GetDCSSpace().GetRefPath() + ')' );
//    SL.Add( ' Codes   Space  Aliase: ' + GetDCSSpace().GetDCSpace().ObjAliase + '  (' +
//                                         GetDCSSpace().GetDCSpace().GetRefPath() + ')' );
    SL.Add( ' Codes SubSpace Aliase: ' + GetDCSSpace().ObjAliase + '  (' +
                                         K_GetPathToUObj( GetDCSSpace() ) + ')' );
    SL.Add( ' Codes   Space  Aliase: ' + GetDCSSpace().GetDCSpace().ObjAliase + '  (' +
                                         K_GetPathToUObj( GetDCSSpace().GetDCSpace() ) + ')' );
    end
  end else if (UObj is TK_UDRArray) then // UDRArray
  begin
    with TK_UDRArray(UObj) do
    begin
      SL.Add( '***** Info about UDRArray "' + UObj.ObjName + '":' );
      N_AddRArrayInfo( R, SL );
    end
  end else if UObj.CI() = N_UDBaseCI then // Directory UDBase
  begin
    with TK_UDRArray(UObj) do
    begin
      SL.Add( '***** Info about directory "' + UObj.ObjName + '":' );
      SL.Add( Format( '      %d Child Object(s)', [UObj.DirLength()] ) );
    end
  end else
  begin
    SL.Add( '***** Info about unknown object "' + UObj.ObjName + '":' );
    SL.Add( 'Class Name = ' + UObj.ClassName );
  end;

  if UObj.ObjInfo <> '' then
    SL.Add( 'ObjInfo: ' + UObj.ObjInfo );

  SL.Add( '' );
  if N_MEGlobObj.AddUObjSysInfo then
    N_AddUObjSysInfo( UObj, SL );

end; // end of procedure N_ViewUObjInfo

//*******************************************  N_ViewUObjFields  ******
// View UObj Fields as Text (in DTree Text (*.sdt) format)
//
procedure N_ViewUObjFields( UObj: TN_UDBase; APForm: TN_PBaseForm;
                                                       AOwner: TN_BaseForm );
var
  SL: TStrings;
begin
  if UObj = nil then Exit; // a precaution
  N_GetTextEditorForm( APForm, AOwner, SL );
  K_CurArchive.RefPath := K_ArchiveCursor; // Restore Archive RefPath

  with N_MEGlobObj do
    if VEdFieldsAsTextAll then
      K_TextModeFlags := K_TextModeFlags - [K_txtRACompact]
    else
      K_TextModeFlags := K_TextModeFlags + [K_txtRACompact];

  K_SaveFieldsToText( UObj, K_SerialTextBuf );
  SL.Text := K_SerialTextBuf.TextStrings.Text;

  if not (APForm^ is TN_PlainEditorForm) then Exit;

  with TN_PlainEditorForm(APForm^) do
  begin
    actButtonsExecute( nil );
    Buttons1.Checked := False;
    Memo.ReadOnly := True;
  end;
end; // end of procedure N_ViewUObjFields

//*******************************************  N_ViewUObjSysFields  ******
// View UObj Sys Fields (as in low level DTree Editor)
//
procedure N_ViewUObjSysFields( UObj: TN_UDBase; APForm: TN_PBaseForm;
                                                       AOwner: TN_BaseForm );
var
  SL: TStrings;
begin
  if UObj = nil then Exit; // a precaution
  N_GetTextEditorForm( APForm, AOwner, SL );
  N_AddUObjSysInfo( UObj, SL );
  if UObj.ObjInfo <> '' then
    SL.Add( 'Info: ' + UObj.ObjInfo );

  if not (APForm^ is TN_PlainEditorForm) then Exit;

  with TN_PlainEditorForm(APForm^) do
  begin
    actButtonsExecute( nil );
    Buttons1.Checked := False;
    Memo.ReadOnly := True;
  end;
end; // end of procedure N_ViewUObjSysFields

//*******************************************  N_ViewPathsToUObj  ******
// View all Paths to given UObj
//
procedure N_ViewPathsToUObj( UObj: TN_UDBase; APForm: TN_PBaseForm;
                                                       AOwner: TN_BaseForm );
var
  SL: TStrings;
  SaveCursor : TCursor;
begin
  N_GetTextEditorForm( APForm, AOwner, SL );
  SL.Clear();

  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

//  K_MainRootObj.GetPathsListToObj( [K_plfSorted], UObj, SL );

  Screen.Cursor := SaveCursor;
end; // end of procedure N_ViewPathsToUObj

//*******************************************  N_CreateActiveRFrame  ******
// Create N_ActiveRFrame if not yet
// (create, if needed, and view proper Map)
//
//  UObj may be CObjLayer, MapLayer or Component(Map)
//
procedure N_CreateActiveRFrame( UObj: TN_UDBase; PRForm: TN_PRastVCTForm;
                                                        AOwner: TN_BaseForm );
begin
  if N_ActiveRFrame <> nil then Exit;         // already created
  if not N_MEGlobObj.AutoViewMap then Exit; // not needed

  N_ViewUObjAsMap( UObj, PRForm, AOwner ); // create N_ActiveRFrame
end; // end of procedure N_CreateActiveRFrame

//*********************************************************  N_EditText  ******
// Edit given string AText in PlainTextEditor in Modal mode
// return True if AText was changed
//
function N_EditText( var AText: string; AOwner: TN_BaseForm ): boolean;
var
  PlainEditor: TN_PlainEditorForm;
begin
  PlainEditor := N_CreatePlainEditorForm( AOwner );
  N_PlaceTControl( PlainEditor, AOwner );
  PlainEditor.Memo.Lines.Text := AText;
  PlainEditor.ShowModal();

  Result := False;
  if PlainEditor.ModalResult = mrOK then // Text was changed
  begin
    AText := PlainEditor.Memo.Lines.Text;
    Result := True;
  end; // if PlainEditor.ModalResult = mrOK then // Text was changed
end; // function N_EditText

//*******************************************  N_EditUObjFields  ******
// Edit UObj Fields as Text (in DTree Text (*.sdt) format)
//
procedure N_EditUObjFields( UObj: TN_UDBase; APForm: TN_PBaseForm;
                                                       AOwner: TN_BaseForm );
var
  SL: TStrings;
begin
  N_CreateActiveRFrame( UObj, nil, AOwner );
  N_GetTextEditorForm( APForm, AOwner, SL );
  K_CurArchive.RefPath := K_ArchiveCursor; // Restore Archive RefPath

  with N_MEGlobObj do
    if VEdFieldsAsTextAll then
      K_TextModeFlags := K_TextModeFlags - [K_txtRACompact]
    else
      K_TextModeFlags := K_TextModeFlags + [K_txtRACompact];

  K_SaveFieldsToText( UObj, K_SerialTextBuf );
  SL.Text := K_SerialTextBuf.TextStrings.Text;

  if not (APForm^ is TN_PlainEditorForm) then Exit;

  N_MEGlobObj.UObjToUpdate := UObj;
//  N_MEGlobObj.UObjAsStrings := SL;

  with TN_PlainEditorForm(APForm^) do
  begin
    ApplyProcObj := N_MEGlobObj.UpdateUObjAndRedraw;
  end;
end; // end of procedure N_EditUObjFields

//*******************************************  N_EditMapLayerCoords  ******
// Edit Coords of given AUDCMapLayer.MLCObj in N_ActiveRFrame (if it is not
// already used by another CObjVectEditor) or in new RFrame.
// Return created TN_CObjVectEditorForm
//
function N_EditMapLayerCoords( AUDMapLayer: TN_UDMapLayer;
                               AOwner: TN_BaseForm ): TN_CObjVectEditorForm;
var
  FrameParent: TN_BaseForm;
begin
  if N_ActiveRFrame = nil then // no Active RFrame
    N_ViewMapLayer( AUDMapLayer, nil, AOwner ); // create new RFrame with new or existed Map

  if N_ActiveRFrame.UCObjEdForm <> nil then // already used by another CObjVectEditor
    N_ViewMapLayer( AUDMapLayer, nil, AOwner ); // create new RFrame with new or existed Map

  with N_ActiveRFrame do // create UCObjEditorForm that use N_ActiveRFrame
  begin
    ShowCoordsType := cctUser;
    PointCoordsFmt := 'X,Y= %.4f, %.4f';

    FrameParent := K_GetOwnerBaseForm( Owner );
    Assert( FrameParent <> nil, 'Not BaseForm!' );

    // Owner of CObjVectEditorForm should be nil,
    // it will be closed manualy in RFrame.OnClose method

    Result := N_CreateCObjVectEditorForm( nil );
    with Result do
    begin
      CVEdFInit( N_ActiveRFrame, AUDMapLayer );
//      EdCObjLayer.SetChangedSubTreeFlag();
      K_SetChangeSubTreeFlags( EdCObjLayer );
      AddClearVarAction( @UCObjEdForm, FrameParent, 'UCObjEdForm' );
      Show();
//      rgSnapMode.ItemIndex := 5;    // debug
//      rbMoveVertex.Checked := True; // debug
    end; // with UCObjEdForm do
    UCObjEdForm := Result;

  end; // with N_ActiveRFrame do
end; // end of procedure N_EditMapLayerCoords

//*******************************************  N_EditCObjLayerCoords  ******
// Edit Coords of given ACObjLayer in N_ActiveRFrame (if it is not
// already used by another CObjVectEditor) or in new RFrame.
// Return created TN_CObjVectEditorForm
//
function  N_EditCObjLayerCoords( ACObjLayer: TN_UCObjLayer;
                                 AOwner: TN_BaseForm ): TN_CObjVectEditorForm;
var
  UDMapLayer: TN_UDMapLayer;
begin
  UDMapLayer := N_CreateUDMapLayer( ACObjLayer, mltNotDef );
  Result := N_EditMapLayerCoords( UDMapLayer, AOwner );
end; // end of procedure N_EditCObjLayerCoords

//************************************************************ N_EditParams ***
// Edit UObj Params: Edit Params of TN_UDCompBase or UDRArray using N_RaEditForm
//
// AUObj          - component or UDRArray to edit
// ACaption       - Editor Form Caption
// AModalModeFlag - RAEditForm Mode Flag (Modal or Not)
// AOwner         - Owner of new RAEditForm (is needed only if new
//                    PRAEditForm would be created inside)
//
function N_EditParams( AUObj: TK_UDRArray; AModalModeFlag: TN_ModalModeFlag; AOwner: TN_BaseForm ): TN_RAEditForm;
var
  SParsTypeName: string;
begin
  SParsTypeName := K_GetExecTypeName( AUObj.R.ElemType.All );
//  if AUObj.R.ALength() <> 1 then
    SParsTypeName := K_sccArray + ' ' + SParsTypeName;

  Result := N_EditRecord( N_GetRAFlags( AUObj.R.ElemType ), AUObj.R, SParsTypeName,
                                                AUObj.ObjName, AUObj, AOwner, AModalModeFlag );
end; // function N_EditParams

{
//**************************************************  N_EditUserParams  ******
// Edit given User Params using N_RaEditForm
//
// AUserParams - RArray of TN_UserParam to Edit
// AUDObj      - UDRArray or UDComponent with User Params to Edit
// AOwner      - Owner of RAEditForm
//
function N_EditUserParams( APUserParams: TK_PRArray; AUObj: TK_UDRArray;
                                           AOwner: TN_BaseForm ): TN_RAEditForm;
var
  UPTypeName: string;
begin
  Result := nil;
  UPTypeName := 'TN_UserParam';
  if APUserParams^ <> nil then
    if UPTypeName <> K_GetExecTypeName( APUserParams^.DType.All ) then Exit; // not proper type

  // if function parameter is AUserParams: TK_RArray, then it should not be
  // passed as first N_EditRecord parameter, because Delphi passes to
  // N_EditRecord addres in Stack! (address of copy of AUserParams in Stack)

  Result := N_EditRecord( APUserParams^, 'arrayof ' + UPTypeName,
                 'User Params', 'TN_UserParamsFormDescr', nil, AUObj, AOwner, mmfNotModal );
end; // function N_EditUserParams
}

//****************************************************** N_EditRecord(Full) ***
// Edit any Record (given by pointer to it) of given ATypeName
// (Full version with AFormDescrVar and PRAEditForm params)
//
// APRecord       - pointer to Record to be Edited
// ATypeName      - Pascal (same as SPL) Type Name (e.g. 'TN_CPanel')
// ACaption       - Editor Form Caption
// AFormDescrName - string with Form Description Name (may be empty)
// PRAEditForm    - pointer to existing RAEditForm or nil (it will be created)
// AUDObj         - UDRArray or UDComponent with ARecord to Edit
// AOwner         - Owner of new RAEditForm (is needed only if PRAEditForm = nil)
// AModalModeFlag - RAEditForm Mode Flag (Modal or Not)
//
function N_EditRecord( AFlags: TN_RAEditFlags; var ARecord; ATypeName, ACaption: string;
                       AFormDescrName: string; PRAEditForm: TN_PRAEditForm;
                       AUDObj: TK_UDRArray; AOwner: TN_BaseForm;
                       AModalModeFlag: TN_ModalModeFlag = mmfNotModal ): TN_RAEditForm;
begin
  Result := N_GetRAEditForm( AFlags, PRAEditForm, ARecord, ATypeName,
                AFormDescrName, N_MEGlobObj.RedrawActiveRFrame, AUDObj, AOwner );
  with Result do
  begin
    Caption := ACaption;

//    if N_MEGlobObj.MEModalMode then // Olad var
//      N_MEGlobObj.MEModalResult := ShowModal()
//    else
//    begin
//      Show();
//      SetFocus();
//    end;

    if AModalModeFlag = mmfModal then
      N_MEGlobObj.MEModalResult := ShowModal()
    else
    begin
      Show();
      SetFocus();
    end;
  end;
end; // end of function N_EditRecord(Full)

//****************************************************** N_EditRecord(Auto) ***
// Edit any Record (given by pointer to it) of given ATypeName
// ( PRAEditForm is set automatically, AFormDescrName = '' )
//
// APRecord      - pointer to Record to be Edited
// ATypeName     - Pascal (same as SPL) Type Name (e.g. 'TN_CPanel')
// ACaption      - Editor Form Caption
// AUDObj        - UDRArray or UDComponent with ARecord to Edit
// AOwner        - Owner of new RAEditForm ( is needed only if new
//                   RAEditForm would be created inside )
// AModalModeFlag - RAEditForm Mode Flag (Modal or Not)
//
function N_EditRecord( AFlags: TN_RAEditFlags; var ARecord; ATypeName, ACaption: string;
                       AUDObj: TK_UDRArray; AOwner: TN_BaseForm;
                       AModalModeFlag: TN_ModalModeFlag = mmfNotModal ): TN_RAEditForm;
var
  PRAEditForm: TN_PRAEditForm;
begin
  with N_MEGlobObj do
  begin
    PRAEditForm := @RAEdForm1; // use same window for all editor instancies

    if   NewEdWindow or
       ( AutoNewEdWindow and N_KeyIsDown(VK_Shift) ) then
    PRAEditForm := nil; // create separate window
  end;

  Result := N_EditRecord( AFlags, ARecord, ATypeName, ACaption, '',
                                  PRAEditForm, AUDObj, AOwner, AModalModeFlag );
end; // end of function N_EditRecord(Auto)

//***************************************************  N_EditUDLogFont  ******
// Edit TN_UDLogFont using Windows FontDialog
//
function N_EditUDLogFont( UDLogFont: TN_UDLogFont; AOwner: TN_BaseForm ): boolean;
var
  FontDialog: TFontDialog;
  PLogFont: TN_PLogFont;
begin
  Result := False;
  if UDLogFont = nil then Exit; // a precaution

  PLogFont := TN_PLogFont(UDLogFont.R.P());
  FontDialog := TFontDialog.Create( AOwner );

  with PLogFont^, FontDialog.Font do
  begin
//  PixelsperInch := 200;
//  Height := Round(LFHeight);
  Size := Round(LFHeight); // Windows FontDialog shows Size(points), not Height(pixels)
    Name   := LFFaceName;
    Style  := [];
    if lfsBold in LFStyle then Style := Style + [fsBold];
    if lfsItalic in LFStyle then Style := Style + [fsItalic];
    if lfsUnderline in LFStyle then Style := Style + [fsUnderline];
  end;

  if FontDialog.Execute then
  with PLogFont^, FontDialog.Font do
  begin
//    LFHeight    := Height;
    LFHeight    := Size;
    LFFaceName  := Name;
    LFStyle := [];
    if fsBold in Style then LFStyle := LFStyle + [lfsBold];
    if fsItalic in Style then LFStyle := LFStyle + [lfsItalic];
    if fsUnderline in Style then LFStyle := LFStyle + [lfsUnderline];

    UDLogFont.ClearWinHandle();
//    UDLogFont.SetChangedSubTreeFlag();
    K_SetChangeSubTreeFlags( UDLogFont );
    Result := True;
  end;

  FontDialog.Free;
end; // end of procedure N_EditUDLogFont

//********************************************************  N_EditNFont  ******
// Edit TN_NFont record using Windows FontDialog
//
function N_EditNFont( APNFont: TN_PNFont; AOwner: TN_BaseForm; APColor : PColor = nil ): boolean;
var
  FontDialog: TFontDialog;
begin
  Result := False;
  if APNFont = nil then Exit; // a precaution

  FontDialog := TFontDialog.Create( AOwner );
  with APNFont^, FontDialog, Font do // prepare FontDialog.Font fields
  begin
    Size   := Round(NFLLWHeight);
    Name   := NFFaceName;
    Charset := NFWin.lfCharSet;
    Style  := [];
    if (NFWeight = 0) and (NFBold <> 0) then Style := Style + [fsBold];
    if NFWin.lfItalic    <> 0 then Style := Style + [fsItalic];
    if NFWin.lfUnderline <> 0 then Style := Style + [fsUnderline];
    if NFWin.lfStrikeOut <> 0 then Style := Style + [fsStrikeOut];
    if APColor <> nil then
      Color := APColor^
    else
      Options := Options - [fdEffects]; // Remove Color Control from Dialog

  end; // with APNFont^, FontDialog.Font do // prepare FontDialog.Font fields

  if FontDialog.Execute then // Font Was choosen
  with APNFont^, FontDialog.Font do
  begin
    NFLLWHeight := Size;
    NFFaceName  := Name;
    NFWin.lfCharSet := Charset;

    if fsBold in Style then
    begin
      NFWeight := 0;
      NFBold   := 1;
    end else
      NFBold   := 0;

    if fsItalic in Style then NFWin.lfItalic := 1
                         else NFWin.lfItalic := 0;

    if fsUnderline in Style then NFWin.lfUnderline := 1
                            else NFWin.lfUnderline := 0;

    if fsStrikeOut in Style then NFWin.lfStrikeOut := 1
                            else NFWin.lfStrikeOut := 0;

    if APColor <> nil then APColor^ := Color;

    DeleteObject( NFHandle );

    if N_ActiveRFrame <> nil then // redarw with new Font
      N_ActiveRFrame.RedrawAllAndShow();

    Result := True;
  end; // with APNFont^, FontDialog.Font do, if FontDialog.Execute then // Font Was choosen

  FontDialog.Free;
end; // end of procedure N_EditNFont

{
//***************************************************  N_EditUDText  ******
// Edit UDText using TN_MemoForm
//
procedure N_EditUDText( AUDText: TN_UDText; AOwner: TN_BaseForm );
var
  EdForm: TN_PlainEditorForm;
begin
  if AUDText = nil then Exit; // a precaution

  EdForm := N_CreatePlainEditorForm( AOwner );
  N_PlaceTControl( EdForm, AOwner );

  with EdForm do
  begin
    Memo.Lines.Text := PString( AUDText.R.P)^;
    ShowModal();
    if ModalResult = mrOK then
      PString( AUDText.R.P)^ := Memo.Lines.Text;
  end; // with EdForm do
end; // end of procedure N_EditUDText
}

//type TN_ArchSectionType = ( astNotSeparate, astSepReadOnly, astSepBinary, astSepText );

type TN_ArchSectionParams = packed record // Archive Section Params for Editing
  ASPIsASection:    byte;
  ASPSectionFormat: byte;
  ASPIsReadOnly:    byte;
  ASPManualLoad:    byte;
  ASPWasChanged:    byte;
  ASPIsJoined:      byte;
  ASPFileName:    string; // Section File Name
  ASPUDUses:   TK_RArray; // RArray of TN_UDBase that should be loaded before lodaing Self
end; // type TN_ArchSectionParams = packed record

//***********************************************  N_EditArchSectionParams  ***
// Edit given Archive Section Params
//
function N_EditArchSectionParams( ASection: TN_UDBase; AOwner: TN_BaseForm ): boolean;
var
  ArchSectionParams: TN_ArchSectionParams;
  PSLSRoot: TK_PSLSRoot;
begin
  Result := False;
  if ASection = nil then Exit;

  with ArchSectionParams, ASection do
  begin
    //***** fill record to Edit

    ASPIsASection    := Byte((ObjFlags and K_fpObjSLSRFlag)  <> 0);
    ASPSectionFormat := Byte((ObjFlags and K_fpObjSLSRFText) <> 0);
    ASPIsReadOnly    := Byte((ObjFlags and K_fpObjSLSRRead)  <> 0);
    ASPManualLoad    := Byte((ObjFlags and K_fpObjSLSRMLoad) <> 0);
    ASPIsJoined      := Byte((ObjFlags and K_fpObjSLSRJoin)  <> 0);
    ASPWasChanged    := Byte((ClassFlags and K_ChangedSLSRBit) <> 0);
    ASPFileName      := ObjInfo;

    ASPUDUses := nil;
    PSLSRoot := K_GetSLSRootPAttrs( ASection );

    ASPUDUses := nil;
    if PSLSRoot <> nil then  // Arch Section with Uses
    begin
      ASPUDUses := PSLSRoot.UDUses;
    end; // if PSLSRoot <> nil then  // Arch Section with Uses

    N_EditRecord( [raefCountUDRefs], ArchSectionParams, 'TN_ArchSectionParams', 'Global Settings',
                            'TN_ArchSectionParFormDescr', nil, nil, AOwner, mmfModal );

    if N_MEGlobObj.MEModalResult = mrOK then // ArchSectionParams fields changed
    begin
      //***** Set Archive Section Params in ASection by resulting ArchSectionParams

      ObjFlags := ObjFlags and ( not K_fpObjSLSRFMask ); // clear all Section flags
      if ASPIsASection    <> 0 then ObjFlags := ObjFlags or K_fpObjSLSRFlag;
      if ASPSectionFormat <> 0 then ObjFlags := ObjFlags or K_fpObjSLSRFText;
      if ASPIsReadOnly    <> 0 then ObjFlags := ObjFlags or K_fpObjSLSRRead;
      if ASPManualLoad    <> 0 then ObjFlags := ObjFlags or K_fpObjSLSRMLoad;
      if ASPIsJoined      <> 0 then ObjFlags := ObjFlags or K_fpObjSLSRJoin;

      ClassFlags := ClassFlags and (not K_ChangedSLSRBit);
      if ASPWasChanged <> 0 then ClassFlags := ClassFlags or K_ChangedSLSRBit;

      ObjInfo := ASPFileName;
{
      if (ImgInd = 30) or (ImgInd = 100) then // set Image index
      begin
        if ASPIsASection = 0 then ImgInd := 30   // UDBase Dir (Not a Section)
                             else ImgInd := 100; // Is a Section
      end; // if (ImgInd = 30) or (ImgInd = 100) then // set Image index
}

      if PSLSRoot <> nil then  // Arch Section with Uses
      begin
        PSLSRoot.UDUses := ASPUDUses;
      end else
      begin // if PSLSRoot <> nil then  // Arch Section with Uses
        ASPUDUses.ARelease;
      end;


      K_SetChangeSubTreeFlags( ASection );
      Result := True;
    end; // if N_MEGlobObj.MEModalResult = mrOK then

  end; // with ArchSectionParams, ASection  do
end; // end of procedure N_EditArchSectionParams

//*****************************************************  N_LoadArchSection  ***
// Load Archive Section (Show confirmation dialog for Section reload)
//
function N_LoadArchSection( ASection: TN_UDBase ): boolean;
begin
  Result := True;

  if ASection.DirLength() > 0 then
    Result := N_MessageDlg( 'Section "' + ASection.ObjName +
                            '" is not empty. Reload it ?',
                                       mtConfirmation, mbOKCancel, 0 ) = mrOK;
  if Result then
    Result := K_LoadCurArchiveSection( ASection );
end; // function N_LoadArchSection

//*******************************************  N_SaveCSToTxtFile  ******
// Save given Code Space to Text file (with space separated tokens)
//
procedure N_SaveCSToTxtFile( CS: TK_UDDCSpace; FName: string );
var
  i, NumRows: integer;
  StrMatr: TN_ASArray;
begin
  Assert( CS <> nil, N_SError );

  with TK_PDCSpace(CS.R.P)^ do
  begin
    NumRows := Codes.ALength();
    SetLength( StrMatr, NumRows );

    for i := 0 to NumRows-1 do
    begin
      SetLength( StrMatr[i], 3 );
      StrMatr[i,0] := PString(Codes.P(i))^;
      StrMatr[i,1] := PString(Names.P(i))^;
      StrMatr[i,2] := PString(Keys.P(i))^;
    end; // for i := 0 to NumRows-1 do

  end; // with TK_PDCSpace(CS.R.P)^ do
  N_SaveSMatrToFile( StrMatr, FName, smfSpace3 );
end; // end of procedure N_SaveCSToTxtFile

//**************************************  N_LoadCSFromTxtFile(GivenCS)  ******
// Load content of given Codes Space from Text file
//
// first row:  *Names CSName CSAliase
// other rows: Code Name Keys (space separated tokens)
//
procedure N_LoadCSFromTxtFile( CS: TK_UDDCSpace; FName: string );
var
  i, NumRows: integer;
  Str: string;
  StrMatr: TN_ASArray;
begin
//  K_LoadSMatrFromFile( StrMatr, FName, smfSpace3 );  // error!
  N_LoadSMatrFromTxt( StrMatr, FName, '', '' ); // temporary, old var
  Str := Trim(StrMatr[0,0]);
  N_RemoveSMatrRows( StrMatr, '*' ); // remove comments and Rows with empty first element

  N_AdjustStrMatr( StrMatr, 3 );
  Assert( CS <> nil, N_SError );

  NumRows := Length( StrMatr );
  with TK_PDCSpace(CS.R.P)^ do
  begin
    Codes.ASetLength( NumRows );
    Names.ASetLength( NumRows );
    Keys.ASetLength( NumRows );

    for i := 0 to NumRows-1 do
    begin
      PString(Codes.P(i))^ := StrMatr[i,0];
      PString(Names.P(i))^ := StrMatr[i,1];
      PString(Keys.P(i))^  := StrMatr[i,2];
    end; // for i := 0 to NumRows-1 do

  end; // with TK_PDCSpace(CS.R.P)^ do

  if Str[1] = '*' then // CSName and CSAliase
  begin
    N_ScanToken( Str );  // skip comment token '*Names'
    CS.ObjName := N_ScanToken( Str );
    CS.ObjAliase := N_ScanToken( Str );
  end;
end; // end of procedure N_LoadCSFromTxtFile(GivenCS)

//*************************************  N_LoadCSFromTxtFile(GivenName)  ******
// Load content of Codes Space with given ObjName from Text file
//
// first row:  *Names CSName CSAliase
// other rows: Code Name Keys (space separated tokens)
//
function N_LoadCSFromTxtFile( ACSObjName, AFName: string ): TK_UDDCSpace;
begin
  Result := TK_UDDCSpace(K_CurSpacesRoot.DirChildByObjName( ACSObjName ));
//  Result := TK_UDDCSpace(N_GetUObj( K_CurSpacesRoot, ACSObjName ));
  if Result = nil then
    Result := K_DCSpaceCreate( ACSObjName );

  N_LoadCSFromTxtFile( Result, AFName );
end; // end of function N_LoadCSFromTxtFile(GivenName)

//*******************************************  N_SaveCSSToTxtFile  ******
// Save given Code SubSpace to Text file
// (as Codes Space items in proper order)
//
procedure N_SaveCSSToTxtFile( CSS: TK_UDDCSSpace; FName: string );
var
  i, CSInd, NumRows: integer;
  StrMatr: TN_ASArray;
  CS: TK_UDDCSpace;
begin
  NumRows := CSS.PDRA^.ALength();
  SetLength( StrMatr, NumRows );

  CS := CSS.GetDCSpace();

  with TK_PDCSpace(CS.R.P)^ do
  for i := 0 to NumRows-1 do
  begin
    SetLength( StrMatr[i], 3 );
    StrMatr[i,0] := IntToStr( i );
    CSInd := PInteger(CSS.DP(i))^;

    if CSInd >= 0 then
    begin
      StrMatr[i,1] := PString(Codes.P(CSInd))^;
      StrMatr[i,2] := PString(Names.P(CSInd))^;
    end
    else
      StrMatr[i,1] := '-1';

  end; // with TK_PDCSpace(CS.R.P)^ do for i := 0 to NumRows-1 do

  N_SaveSMatrToFile( StrMatr, FName, smfSpace3 );
end; // end of procedure N_SaveCSSToTxtFile

//*******************************************  N_LoadCSSFromTxtFile  ******
// Load given Code Space from Text file (with space separated tokens)
//
procedure N_LoadCSSFromTxtFile( CSS: TK_UDDCSSpace; FName: string );
var
  i, NumRows: integer;
  SCodes: TN_SArray;
  StrMatr: TN_ASArray;
  CS: TK_UDDCSpace;
begin
  Assert( CSS <> nil, N_SError );
  K_LoadSMatrFromFile( StrMatr, FName, smfSpace3 );
//  N_LoadStrMatrFromTxt( StrMatr, FName, '', '' ); // temporary
  N_RemoveSMatrRows( StrMatr ); // remove all Rows with empty first element

  NumRows := Length( StrMatr );
  CS := CSS.GetDCSpace();

  CSS.PDRA^.ASetLength( NumRows );
  SetLength( SCodes, NumRows );

  for i := 0 to NumRows-1 do // Create Codes as Array of strings
    SCodes[i] := StrMatr[i,1];

  with TK_PDCSpace(CS.R.P)^ do
    K_SCIndexFromSCodes( PInteger(CSS.DP), @SCodes[0], NumRows,
                                        PString(Codes.P), Codes.ALength() );
end; // end of procedure N_LoadCSSFromTxtFile

//**************************************  N_LoadCSFromTxtFile(GivenCS)  ******
// Load and return UDVector from Text file
// in CS Strings may be some params, that are absent in FName
//
function N_LoadUDVectFromTxtFile( FName: string; CS : TStrings ): TK_UDVector;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  K_LoadStringsFromDFile( SL, FName );
  Result := K_CreateUDVector( SL, CS );
  SL.Free;
end; // function N_LoadUDVectFromTxtFile

//************************************** N_RefsToCObjects ***
// Create and return new CObj Layer with given ACObjName,
// that consists of all ACObjRefs elements
//
function N_RefsToCObjects( ACObjName: string; ACObjRefs: TN_UCObjRefs ): TN_UCObjLayer;
var
//  i, j: integer;
  BaseCLayer: TN_UCObjLayer;
begin
  BaseCLayer := TN_UCObjLayer(ACObjRefs.DirChild( N_CObjRefsChildInd ));
  Result := N_GetCObjW( ACObjName, BaseCLayer.CI, BaseCLayer.WLCType );

  //NOT YET!!!

end; // end_of function N_RefsToCObjects

//*************************************************** N_FillReIndVect ***
// Create (if not yet) and Fill ReIndexing Vector
//
// ReIndVect   - ReIndexing Vector
// SrcCSS      - Sorce Codes SubSpace (DataVector SubSpace)
// DstCSS      - Destination Codes SubSpace (CObj Layer SubSpace)
//               ( SrcInd = ReIndVect[DstInd] )
// VObjName    - ReIndVect.ObjName if new ReIndVect was created
//
procedure N_FillReIndVect( var ReIndVect: TK_RArray;
                        SrcCSS, DstCSS: TK_UDDCSSpace );
var
  NP : Integer;
begin
  if (SrcCSS = nil) or (DstCSS = nil) then Exit;

  if ReIndVect = nil then // create new ReIndexing Vector
    ReIndVect := K_RCreateByTypeName( 'integer', DstCSS.PDRA.ALength() )
  else // use given ReIndexing Vector
    ReIndVect.ASetLength( DstCSS.PDRA.ALength() );

  K_BuildDataProjection( SrcCSS, DstCSS, ReIndVect.P, NP );
end; // procedure N_FillReIndVect

//*************************************  N_StringCodeBelongsToCS  ******
// Check if given String ASCode belongs to given ACS Codes
// return True if Yes, if No - add info string to given ASL (if ASL <> nil)
//
function N_StringCodeBelongsToCS( ASCode: string; ACS: TK_UDDCSpace;
                                                   ASL: TStringList): boolean;
var
  i, NumCodesInCS: integer;
begin
  Result := True;
  if ASCode = '-1' then Exit; // Code -1 is always OK

  with TK_PDCSpace(ACS.R.P)^ do
  begin
    NumCodesInCS := Codes.ALength;

    for i := 0 to NumCodesInCS-1 do
    begin
      if ASCode = PString(Codes.P(i))^ then Exit; // found
    end;

    //***** Here: ASCode Not Found

    if ASL <> nil then
      ASL.Add( 'Code  "' + ASCode + '" is absent!' );

    Result := False;
  end; // with TK_PDCSpace(ACS.R.P)^ do
end; // end of function N_StringCodeBelongsToCS

//************************************************ N_SaveCurStateToMemIni ***
// Save To MemIni current state for all currently opened forms
//
procedure N_SaveCurStateToMemIni();
begin
//  N_DebGroups[7].DSInd := 0;                     // switch ON debug!!
//  N_PCAdd( 7, '' );
//  N_PCAdd( 7, K_DateTimeToStr( Now() ) + ' N_SaveCurStateToMemIni :' );

//  N_PCAdd( 7, '' ); // debug
//  N_PCAdd( 7, 'inside N_SaveCurStateToMemIni' ); // debug
//  N_PCAdd( 7, 'From N_SaveCurStateToMemIni'#$0D#$0A + N_SaveAllToMemIni.ALOToStr() ); // debug

  N_SaveAllToMemIni.ExecActions();
  N_CurMemIni.UpdateFile;
end; // procedure N_SaveCurStateToMemIni

//************************************************ N_AddToProtocol ***
// Add given string to protocol
//
procedure N_AddToProtocol( AStr: string );
begin
  with N_MEGlobObj do
  begin
    MEProtocolSL.Add( AStr );
    if TextEdForm <> nil then
      TN_PlainEditorForm(TextEdForm).Memo.Lines.Add( Astr );
  end; // with N_MEGlobObj do
end; // procedure N_AddToProtocol

//************************************************ N_ShowProtocol ***
// Show protocol
//
procedure N_ShowProtocol( ACaption: string; AOwner: TN_BaseForm );
var
  APForm: TN_PBaseForm;
  SL: TStrings;
begin
  APForm := @N_MEGlobObj.TextEdForm;

  N_GetTextEditorForm( APForm, AOwner, SL );
  APForm^.Caption := ACaption;
  SL.Text := N_MEGlobObj.MEProtocolSL.Text;
end; // procedure N_ShowProtocol

//************************************************ N_CurShowStr ***
// Show given string AStr by MEShowStrProcObj
//
procedure N_CurShowStr( AStr: string );
begin
  with N_MEGlobObj do
  begin
    if Assigned( MEShowStrProcObj ) then
      MEShowStrProcObj( AStr );
  end;
end; // procedure N_CurShowStr

//************************************************  N_ViewFileInMSWord  ******
// View given AFileName in MS Word
//
procedure N_ViewFileInMSWord( AFileName: string );
var
  OLEServer: Variant;
begin
  OLEServer := N_GetOLEServer( N_MEGlobObj.MEWordServerName );
  OLEServer.Documents.Open( AFileName );
  OLEServer.Visible := True;
end; // procedure N_ViewFileInMSWord

{
Initialization
  N_StateString := TN_StateString.Create; // Obj for Showing State and Progres
  N_MEGlobObj := TN_MEGlobObj.Create;     // ME Global Object

  K_RegRAFEditor( 'NRAFontEditor',   TN_RAFRAFontEditor );
  K_RegRAFEditor( 'NWinFontEditor',  TN_RAFWinFontEditor );
  K_RegRAFEditor( 'NWinNFontEditor', TN_RAFWinNFontEditor );
  K_RegRAFEditor( 'NMLCoordsEditor', TN_RAFMLCoordsEditor );

  K_RegRAFrDescription( 'TN_VCTreeParams',  'TN_VCTreeParamsFormDescr' );
  K_RegRAFrDescription( 'TN_VCTreeLayer',   'TN_VCTreeLayerFormDescr' );
  K_RegRAFrDescription( 'TN_CTLVar1',       'TN_CTLVar1FormDescr' );
  K_RegRAFrDescription( 'TN_SclonOneToken', 'TN_SclonOneTokenFormDescr' );

  K_RegRAFrDescription( 'TN_TaCell',  'TN_CellFormDescr' );

Finalization
  N_StateString.Free;
  N_MEGlobObj.Free;
}
end.
