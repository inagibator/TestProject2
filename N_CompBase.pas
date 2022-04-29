unit N_CompBase;
// Base and Visual Component class

// TN_CompParType    = ( cptStatic, cptDynamic ); // Component Params Type
// TN_SetParamsPhase = ( sppBBAction, sppABAction, sppBAAction, sppAAAction );
// TN_SetParamFlags  = set of ( spfNotDef );
// TN_SPOperandFlags = set of ( spofStat );
// TN_SetParamsFunc  = function(): integer;
// TN_SPFuncType     = ( spftAssign, spftSPL, spftTest1 );

// TN_OneSetParam    = packed record // data for Setting One Param

// TN_CompBaseFlags1 = set of ( cbfDummy1, cbfL1Macros, cbfL2Macros,
// TN_Main1ExpMode   = ( mem1Default, mem1Image, mem1HTMLPure, mem1HTMLMS,
// TN_Image1ExpMode  = ( iem1ScreenRaster, iem1ScreenEMF, iem1FileEMF,
// TN_MainExpMode    = ( memDefault, memImage, memHTMLPure, memHTMLMS,
// TN_ImageExpMode   = ( iemScreenRaster, iemScreenEMF, iemFileEMF,
// TN_ExpParams      = packed record // Component Export Params
// TN_CCompBase      = packed record // Base Component Params
// TN_RCompBase      = packed record // Base Component RArray Record type
// TN_UDCompBase     = class( TK_UDRArray ) // Base Component

// TN_RCompVis       = packed record // Visual Component RArray Record type
// TN_UDCompVis      = class( TN_UDCompBase ) // Visual Component


interface
uses  Windows, Classes, Graphics, IniFiles, Types,
  K_UDT1, K_CLib0, K_Script1,
  N_Types, N_BaseF, N_Lib1, N_Lib2, N_Gra2, N_CompCL, N_GCont;

//***************************  CompBase Component  ************************

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_CompParType
type TN_CompParType = ( // Component Parameters Type
  cptStatic, // Component Static parameters (set by user or program that creates
             // Components Tree)
  cptDynamic // Component Dynamic parameters (build by Components Tree 
             // Interpreter during tree-walk)
  );

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_SetParamsPhase
//******************************************************* TN_SetParamsPhase ***
// Component Parameter Set Command Execution Phase
//
// Usually Parameter Set Command is done before BeforeComponentExecution Action 
// (=sppBBActio)
//
type TN_SetParamsPhase = (
  sppBBAction,  // do Parameter Set Command before BeforeComponentExecution 
                // Action
  sppABAction,  // do Parameter Set Command after  BeforeComponentExecution 
                // Action
  sppBAAction,  // do Parameter Set Command before AfterComponentExecution 
                // Action
  sppAAAction,  // do Parameter Set Command after  AfterComponentExecution 
                // Action
//##/*
  sppSkipAction // uncoditional skip Parameter Set Command
//##*/
  );

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_SetParamFlags
type TN_SetParamFlags  = set of ( // Skip Component Set Parameters Command Flags Set
  spfSkipIfZeroSrcUP, // skip set parameter command if given Source Component 
                      // User Parameter is zero
  spfSkipIfZeroSelfUP // skip set parameter command if given Self Component User
                      // Parameter is zero
  );

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_SPOperandFlags
type TN_SPOperandFlags = set of ( // Component Set Parameter Command Operand Flags Set
  spofStat,      // Operand is element of Static Parameters
  spofUserParam, // Operand is element of User Parameters
  spofUPArray    // Operand is Array element of User Parameters
  );

type TN_SetParamsFunc  = function(): integer;

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_SPFuncType
//*********************************************************** TN_SPFuncType ***
// Component Set Parameter Command function type
//
// Usually set parameter function type is spftAssign
//
type TN_SPFuncType     = (
  spftAssign,       // assign given Component Parameter
  spftSPL,          // SPL Macro (used during Office documents generation)
  spftInitGVars,    // Init SPL GlobVars (used during Office documents 
                    // generation)
  spftSkip,         // Skip Function
  spftIfAssign,     // If 1 Assign Const
  spftIfSetFlags,   // If 1 Set Flags
  spftIfClearFlags, // If 1 Clear Flags
  spftOther,        // Other Functions
  spftXORAssign     // XOR and Assign Field
  );

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_OneSetParam
//********************************************************** TN_OneSetParam ***
// Component Set Parameter Command Record
//
type TN_OneSetParam = packed record
  SPPhase: TN_SetParamsPhase;    // set parameter Command Phase
  SPFlags: TN_SetParamFlags;     // skip parameter flags set
  SPFunc:     TN_SPFuncType;     // set parameter function type
  SPFReserved1: byte;
  SPSrcFlags: TN_SPOperandFlags; // Source Operand flags
  SPDstFlags: TN_SPOperandFlags; // Destination Operand flags
  SPFReserved2: byte;
  SPFReserved3: byte;
  SPTxtPar:    string;           // set parameter function string parameter

  SPSrcUObj: TN_UDBase;          // Source Operand IDB Base Object
  SPSrcPath:  string;            // Source Operand Componenet IDB path from Base
                                 // Object
  SPSrcField: string;            // Source Operand field path in given Component

  SPDstUObj: TN_UDBase;          // Destination Operand IDB Base Object
  SPDstPath:  string;            // Destination Operand Componenet IDB path from
                                 // Base Object
  SPDstField: string;            // Destination Operand field path in given 
                                 // Component

//##/*
  SPSPLCode:  string;            //
//##*/
end; // type TN_OneSetParam = packed record
type TN_POneSetParam = ^TN_OneSetParam;


//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UserParamType
type TN_UserParamType = ( // User Parameter Info Type
  uptNotDef,     //
  uptBase,       //
  uptTimeSeries, //
  uptDataBlock,  //
  uptCSDim,      //
  uptBoolean4    //
  );

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_CompBaseFlags1
type TN_CompBaseFlags1 = set of ( // Component Execution Parameters Processing flags set
  cbfNewExpPar,    // process New Export Parameters (export SubTree in New 
                   // GCont)
  cbfUPMacros,     // User Parameters Macroses should be expanded
  cbfL1Macros,     // Level 1 Macroses should be expanded
  cbfL2Macros,     // Level 2 Macroses should be expanded
  cbfDoClipping,   // do Clipping by CompIntPixRect (for Visual Components only)
  cbfVariableSize, // Component Size is defined only in BeforeAction method
  cbfStandAlone,   // Root of StandAlone VCTree Fragment (usually Image)
  cbfInitSubTree,  // Self SubTree should be initialized for each time (for 
                   // StandAlone Components)
  cbfSetRTFName,   // set RTFileName field after exporting to File
  cbfSkipResponse, // skip calling GCShowResponse in NGCont.FinishExport
  cbfSelfSizeUnits // Self (not Root) Size Units should be used for drawing self
                   // children
); // two bytes

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_CompBaseFlags2
type TN_CompBaseFlags2 = set of ( // Show Execution Time of different fragments flags set
  cbfTimeWhole,     // Whole Time
  cbfTimeBefore,    // Before Time
  cbfTimeChildren,  // Children Time
  cbfTimeEachChild, // Each Child Time
  cbfTimeAfter      // After Time
  );

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_CCompBase
type TN_CCompBase = packed record // Component Base Parameters Record
  CBSkipSelf: Byte; // Skip Component Exection flag (=0 - do not skip Component 
                    // Exection)
  CBStopExec: Byte; // Stop all Components Execution
  CBFlags1: TN_CompBaseFlags1; // Component Flags #1 (two bytes)
  CBFlags2: TN_CompBaseFlags2; // Component Flags #2 (one byte)
  CBReserved1: byte;
  CBReserved2: byte;
  CBReserved3: byte;
  CBUserParams: TK_RArray; // Component User Parameters (RArray of TN_UserParam)
  CBSPLGlobals: string;    // Global varaibles and procedures for Component SPL 
                           // Unit
  CBTextAttr:   string;    // Text Attributes for exporting in Text mode
  CBComment:    string;    // Component description
  CBComp_8: TN_UDBase;     // Component with '_8' prefix User Parameters
  CBComp_9: TN_UDBase;     // Component with '_9' prefix User Parameters
  CBUDBase_1: TN_UDBase;   // Any UDBase, which will be assigned to _1UDBase SPL
                           // varaible
  CBExpParams: TK_RArray;  // Export Parameters (nil or RArray with one 
                           // TN_ExpParams record)
end; // type TN_CCompBase = packed record
type TN_PCCompBase = ^TN_CCompBase;

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_RCompBase
type TN_RCompBase = packed record // Base Component Records Array Element Structure
  CSetParams: TK_RArray;    // Component's set parameter Commands Array
  CCompBase : TN_CCompBase; // Component Base Parameters
end; // type TN_RCompBase = packed record
type TN_PRCompBase = ^TN_RCompBase;

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_CompRTFlags
type TN_CompRTFlags    = set of ( // Component RunTime Flags
  crtfRootComp  // Component is Root object of executed Components SubTree
  );

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_CompStatFlags
type TN_CompStatFlags  = set of ( // Component Static Flags, set in Component Pascal Constructor
  csfCoords,    // can be Executed in GCCoordsMode (using Parent.CompIntPixRect 
                // and so on)
  csfNonCoords, // can be Executed if GCCoordsMode=False (wihout 
                // Parent.CompIntPixRect and so on)
  csfVarSize,   // Component Size is calculated only in BeforeAction method (can
                // have Variable Size)
  csfExecAfter, // AfterAction method is not Empty and should be executed
  csfForceExec  // can be executed without any Export Params (Execute option 
                // should be always visible)
  );

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase
//*********************************************************** TN_UDCompBase ***
// Component IDB Objects Base Class
//
// Component Base Class instances can be used for SetParams and UserParams 
// funtionality
//
type TN_UDCompBase = class( TK_UDRArray ) // Base Component, it's instances can be
    public                          // used for SetParams and UserParams funtionality
  CStatFlags:  TN_CompStatFlags; // Component Static Flags, set in Pascal 
                                 // Constructor
  CRTFlags:    TN_CompRTFlags;   // Component RunTime Flags
  DynPar:      TK_RArray;        // Dynamic Params (always same type as Self.R)
  DynParent:   TN_UDCompBase;    // Dynamic Parent Component
  CurChildInd: integer;          // Current Child Component Index (wrk variable 
                                 // used in GetNextChild)
  NGCont:      TN_GlobCont;      // Global Execution Context object for 
                                 // Components SubTree Exectution
  SPLUnit:     TK_UDUnit;        // reference to Component SPL Unit IDB Object
  RTFileName:  string;           // Export File Run Time Name

  //*********************************** Virtual methods
//##/*
  constructor Create;  override;
  destructor  Destroy; override;
  procedure PascalInit    (); override;
//##*/
  procedure CopyFields    ( ASrcObj: TN_UDBase ); override;

  procedure InitRunTimeFields ( AInitFlags: TN_CompInitFlags ); virtual;
  procedure PrepRootComp      (); virtual;

  procedure PrepMacroPointers (); virtual;
  procedure CalcParams1       (); virtual;
  procedure BeforeAction  (); virtual;
  procedure AfterAction   (); virtual;
//##/*
  procedure DebAction     ( ADebExecPhase: integer ); virtual;
  procedure ShowSelfHelp  ( AOwner: TN_BaseForm = nil ); virtual;
//##*/

  //*********************************** Type specific methods
  function  PSP           (): TN_PRCompBase;
  function  PDP           (): TN_PRCompBase;

  //*********************************** User Params Related methods
  function  GetDUserParRArray ( AUPName: string ): TK_RArray; overload;
  function  GetDUserParRArray ( AUPName: string; AUPTypeCode: integer ): TK_RArray; overload;
  function  GetSUserParRArray ( AUPName: string ): TK_RArray;
  function  CGetDUserParPtr   ( AUPName, AUPDescr: string; AUPTypeCode: TK_ExprExtType;
                                      ANumElems: integer ): TN_POneUserParam;
  function  CGetSUserParPtr   ( AUPName, AUPDescr: string; AUPTypeCode: TK_ExprExtType;
                                      ANumElems: integer ): TN_POneUserParam;

  function  GetDUserParBool   ( AUPName: string ): Boolean;
  function  GetDUserParInt    ( AUPName: string ): integer;
  function  GetDUserParDbl    ( AUPName: string ): double;
  function  GetDUserParStr    ( AUPName: string ): string;
  function  GetDUserParUDBase ( AUPName: string ): TN_UDBase;

  procedure SetDUserParUDBase ( AUPName: string; AUDBase: TN_UDBase );

  procedure SetSUserParInt    ( AUPName: string; AInt: integer );
  procedure SetSUserParDbl    ( AUPName: string; ADbl: double );
  procedure SetSUserParStr    ( AUPName: string; AStr: string );
  procedure SetSUserParUDBase ( AUPName: string; AUDBase: TN_UDBase );

  procedure CSetSUserParInt   ( AUPName, AUPDescr: string; AInt: integer );
  procedure CSetSUserParBool4 ( AUPName, AUPDescr: string; AInt: integer );
  procedure CSetSUserParDbl   ( AUPName, AUPDescr: string; ADbl: double );
  procedure CSetSUserParUDBase( AUPName, AUPDescr: string; AUDBase: TN_UDBase );
  procedure CSetSUserParStr   ( AUPName, AUPDescr: string; AStr: String );

  //*********************************** Macro and SPL processing methods
  procedure AddUParamsToSPL ( AComp: TN_UDBase; APrefix: string; ASL: TStrings );
  procedure InitSPLUnitText ( AUPComp5: TN_UDCompBase = nil; AUPComp6: TN_UDCompBase = nil );
  procedure ExpandUPMacros  ( var AStr: string );
  procedure FinSPLUnit      ();
  procedure InitGVars       ();
  function  AddOneMacroToSPL    ( AMacroSrc: string; var AMacroDest: string ): TK_MRResult;
  function  ExpandOneMacroBySPL ( AMacroSPLName: string; var AMacroResult: string ): TK_MRResult;
//##/*
  procedure PrepL1Macros        ();
  function  ProcessOneL1Macro   ( AMacro: string ): string;
  procedure ExpandAllMacros     ();
  procedure UpdateBySPLMCont    (); // is not needed?
//##*/

  //*********************************** Execute SubTree related methods
  procedure ExecSetParams  ( ASPPhase: TN_SetParamsPhase );
//##/*
  procedure SetParamsProc  ( APSetParam: TN_POneSetParam; APSrcField, APDstField: Pointer;
                                         ASrcFTCode, ADstFTCode: TK_ExprExtType );
//##*/
  function  GetNextChild   (): TN_UDCompBase;
  function  GetPrevChild   (): TN_UDCompBase;
  function  GetPExpParams  ( APExpParams: TN_PExpParams = nil ): TN_PExpParams;
  function  GetExpFlags    ( APExpParams: TN_PExpParams = nil ): TN_CompExpFlags;
  procedure ExpImageTag    ( AImgAttr: string; ANGCont: TN_GlobCont = nil );
  procedure ExecSubTree    ();
  procedure InitSubTree    ( AInitFlags: TN_CompInitFlags );
  procedure FinSubTree     ();
  procedure ExecInNewGCont ( AInitFlags: TN_CompInitFlags = [];
                             AShowResponse: TN_OneStrProcObj = nil;
                             AOwner: TN_BaseForm = nil;
                             APExpParams: TN_PExpParams = nil );

  //****************************** Methods used in GCont and descendant Before(After)Action methods
  function  GetDataRoot      ( ACreate: boolean ): TN_UDBase;
  function  GetTmpDataRoot   ( ACreate: boolean ): TN_UDBase;
//##/*
  procedure DrawAllMapLayers ( ARoot: TN_UDBase );
//##*/

//##/*
  //*********************************** Obsolete methods *****************
  //*** (should be removed after removing theirs usage in obsolete code)
  procedure ClearSelfRTI  (); virtual;
  procedure AddMacrosToSPL    ( var AStr: string; var ANum: integer; AProcPref: string );
  procedure ExpandMacrosBySPL ( ASrcStr, AProcPref: string; var AResStr: string; AExpand: boolean = True );
//##*/
  procedure UDCompAddCurStateMain ( AStrings: TStrings; AIndent: integer );
end; // type TN_UDCompBase = class( TK_UDRArray )
type TN_PUDCompBase = ^TN_UDCompBase;
type TN_UDCompBaseArray = array of TN_UDCompBase;


//***************************  CompVis Base Component  ************************

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_RCompVis
type TN_RCompVis = packed record // Visual Component Records Array Element Structure
  CSetParams: TK_RArray;    // Component's set parameter Commands Array
  CCompBase : TN_CCompBase; // Component Base Parameters
  CLayout   : TK_RArray;    // Component Layout
  CCoords   : TN_CompCoords;// Component Coordinates and Position
  CPanel    : TK_RArray;    // Component Panel Attributes (may be nil)
  OtherParams: byte;        // First byte of Other Parametes
end; // type TN_RCompVis = packed record
type TN_PRCompVis = ^TN_RCompVis;

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_CompCoordsFlags
//****************************************************** TN_CompCoordsFlags ***
// Component Coordinates Transformation Flags Set
//
type TN_CompCoordsFlags = set of ( ccfAffCoefs6, ccfPixTransf );

//##fmt PELSize=80,PELPos=0,PELShift=2

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis
type TN_UDCompVis = class( TN_UDCompBase ) // Visual Component (base class)
    public
  CurFreeRects: TN_IRArray; // Array of Currently Free Rectangles in OCanv 
                            //   Pixels for Layout
  CompOuterPixRect: TRect;  // whole Comp. Outer Pixel Rectangle (may be out of 
                            //   OCanv)
  CompIntPixRect:   TRect;  // whole Comp. Internal Pixel Rectangle (may be out 
                            //   of OCanv)
  CompIntUserRect: TFRect;  // whole Comp. Internal User Rectangle (may be out 
                            //   of OCanv)
  ScopePixRect:     TRect;  // Comp. Scope Rectangle (for editing, usually 
                            //   Parent.CompIntPixRect)
  SavedOCanvCoords: TN_OCanvCoords;
  SavedOCanvFields: TN_SavedOCanvFields;
  CompP2U:  TN_AffCoefs4; // Component Pixel to User Affine Coefs4 (used e.g. 
                          //   for searching)
  CompU2P:  TN_AffCoefs4; // Component User to Pixel Affine Coefs4 (used e.g. 
                          //   for snapping to grid)
  CompP2U6: TN_AffCoefs6; // Component Pixel to User Affine Coefs6 (used e.g. 
                          //   for searching)
  CompU2P6: TN_AffCoefs6; // Component User to Pixel Affine Coefs6 (used e.g. 
                          //   for snapping to grid)
  CompP2PWin:  TXForm;    // Component Pixel to Pixel WinGDI World 
                          //   Transformation Coefs (used e.g. for searching and
                          //   snapping)
  CompCoordsFlags: TN_CompCoordsFlags; // if CompP2PWin or CompU2P6 should be 
                                       //   used

  //*********************************** Virtual methods
//##/*
  constructor Create;  override;
  destructor  Destroy; override;
  procedure PascalInit      (); override;
//##*/
  procedure CopyFields      ( ASrcObj: TN_UDBase ); override;
  procedure InitRunTimeFields ( AInitFlags: TN_CompInitFlags ); override;
  procedure BeforeAction    (); override;
  procedure AfterAction     (); override;
  function  IsInternalPoint ( const APoint: TPoint ): boolean; virtual;

  //*********************************** Type specific methods
  function  PSP          (): TN_PRCompVis;
  function  PDP          (): TN_PRCompVis;
  function  PCCS         (): TN_PCompCoords;
  function  PCCD         (): TN_PCompCoords;
  function  PCPanelS     (): TN_PCPanel;
  function  PCPanelD     (): TN_PCPanel;

  //*********************************** Coords related methods
  procedure UpdateCurFreeRect ( AUpdateFlags: TN_CurFreeFlags );
  function  GetAspect         (): double;
  function  CalcRootCurPixRectSize ( const AMaxPixSize: TPoint ): TPoint;
  function  GetSize  ( APSrcmm: PFPoint; APSrcPix: PPoint;
                                            AGivenRes: float = 0 ): TN_VCTSizeType;
  procedure SetSizeUnitsCoefs ();
  procedure SetNewPClipRect   ( AClipRect: TRect );
  procedure SetOuterPixCoords ();
  procedure SetCompUCoords    ();
  procedure ChangeCompCoords  ( ANewCurPixRect, AScopePixRect: TRect );
  function  ConvToPix   ( const APoint: TFPoint; ACoordsType: TN_CompCoordsType;
                                        AConvFlags: TN_CoordsConvFlags ): TPoint;
  function  ConvFromPix ( const APoint: TPoint; ACoordsType: TN_CompCoordsType;
                                        AConvFlags: TN_CoordsConvFlags ): TFPoint;
  procedure SetSelfPosByURect ( const AURect: TFRect );
  procedure SetSelfAngle ( APixTransfType: TN_CTransfType; ARotateAngle: float = 0 );


  //*********************************** Draw methods
  procedure DebView     ();
  procedure DrawAuxLine ( AAuxLine: TK_RArray );

  //*********************************** Other methods
  function  AddCompsUnderPoint ( const APoint: TPoint;
                                 var ACompsArray: TN_UDCompBaseArray ): boolean;

  //*********************************** Obsolete methods *****************
  //*** (should be removed after removing theirs usage in obsolete code)

end; // type TN_UDCompVis = class( TN_UDCompBase )
type TN_PUDCompVis = ^TN_UDCompVis;
type TN_UDCompVisArray = array of TN_UDCompVis;
type TN_UDCVArray = array of TN_UDCompVis;
//##fmt

var
  N_CurCreateRAFlags: TK_CreateRAFlags;  // used in N_AddNewUserPar
  N_SetParamsFuncs:   THashedStringList; // used for registering SetParams functions
  N_DefExpParams:     TN_ExpParams;      // Default Export Params
  N_GlobUserParams:   TN_UDCompBase;     // Component with Global User Params

//********************************  Global procedures  ********************

//##/*
procedure N_RegSetParamsFunc ( AFuncName: string; ASPFunc: TN_SetParamsFunc );
function  N_SetParamsFunc1   (): integer;
//##*/

procedure N_GetUserParInfo ( AUPValue: TK_RArray; out AUPType: TN_UserParamType;
                                                    out ANumElems: integer );
function  N_GetUserParPtr  ( ACompRArray: TK_RArray; AUPName: string ): TN_POneUserParam;
function  N_GetUserParBoolValue ( ACompRArray: TK_RArray; AUPName: string ): Boolean;
function  N_CGetUserParPtr ( ACompRArray: TK_RArray; AUPName, AUPDescr, AUPTypeName: string;
                                        ANumElems: integer ): TN_POneUserParam; overload;
function  N_CGetUserParPtr ( ACompRArray: TK_RArray; AUPName, AUPDescr: string;
             AUPTypeCode: TK_ExprExtType; ANumElems: integer ): TN_POneUserParam; overload;
function  N_AddNewUserPar  ( ACompRArray: TK_RArray; AUPName, AUPDescr, AUPTypeName: string;
                                        ANumElems: integer ): TN_POneUserParam; overload;
function  N_AddNewUserPar  ( ACompRArray: TK_RArray; AUPName, AUPDescr: string;
             AUPTypeCode: TK_ExprExtType; ANumElems: integer ): TN_POneUserParam; overload;

procedure N_CreateExpParams ( AComp: TN_UDCompBase );
procedure N_PrepExpParams   ( APInpEP, APOutEP: TN_PExpParams );

//##/*
procedure N_CreateRasterByComp ( AComp: TN_UDCompVis; APixSize: TPoint;
                                        AURect: TFRect; AFileName: string );
//##*/

implementation
uses Math, SysUtils, StrUtils,
  K_UDConst, K_DCSpace, K_SParse1,
  N_Comp1, N_Comp3, N_HelpF,
  N_Lib0, N_ClassRef, N_UDCMap, N_ME1, N_Gra0, N_Gra1, N_NVTreeFr, N_InfoF;


//***********************  TN_UDCompBase Class  ***************************

//************************* Virtual methods ********************

//**************************************************** TN_UDCompBase.Create ***
//
//
constructor TN_UDCompBase.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDCompBaseCI or N_CompBaseBit;
  CStatFlags := [csfNonCoords];
  ImgInd := 80;
end; // end_of constructor TN_UDCompBase.Create

//*************************************************** TN_UDCompBase.Destroy ***
//
//
destructor TN_UDCompBase.Destroy;
begin
  DynPar.ARelease;
  inherited Destroy;
end; // end_of destructor TN_UDCompBase.Destroy

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\CopyFields
//************************************************ TN_UDCompBase.CopyFields ***
// Copy to Self Static Parameters Records Array from given TN_UDCompBase IDB 
// Object
//
//     Parameters
// ASrcObj - given source Base Component IDB Object to copy Static Parameters
//
procedure TN_UDCompBase.CopyFields( ASrcObj: TN_UDBase );
var
  SavedImgInd: integer;
begin
//!!! this methd may be not used now
  if not (ASrcObj is TN_UDCompBase) then Exit;

  //***** Copy All UDBase Fields exept ImgInd
  SavedImgInd := ImgInd;
  CopyMetaFields( ASrcObj );
  ImgInd := SavedImgInd;

  K_MoveSPLData( TN_UDCompBase(ASrcObj).PSP()^,
                 PSP()^,
                 K_GetExecTypeCodeSafe( 'TN_RCompBase' ),
                 [K_mdfFreeAndFullCopy] );
{
  K_RFreeAndCopy( PSP()^.CSetParams, TN_UDCompBase(SrcObj).PSP()^.CSetParams,
                                           [K_mdfCopyRArray,K_mdfCountUDRef] );
  !! Error
  PSP()^.CCompBase := TN_UDCompBase(SrcObj).PSP()^.CCompBase;
}

end; // end_of procedure TN_UDCompBase.CopyFields

//************************************************ TN_UDCompBase.PascalInit ***
//
//
procedure TN_UDCompBase.PascalInit();
begin
  // empty in BaseComp
end; // end_of procedure TN_UDCompBase.PascalInit

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\InitRunTimeFields
//***************************************** TN_UDCompBase.InitRunTimeFields ***
// Clear Component all RunTime fields
//
//     Parameters
// AInitFlags - runtime fields initialization flags
//
// Clear such Self RunTime fields as Font Handels, ReInd Vectors, 
// 2DSpace.Coefs6, Pascal Objects and so on.
//
procedure TN_UDCompBase.InitRunTimeFields( AInitFlags: TN_CompInitFlags );
begin
  CRTFlags := []; // clear RunTime Flags
  if not (cifSkipRTFName in AInitFlags) then RTFileName := '';
end; // end_of procedure TN_UDCompBase.InitRunTimeFields

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\PrepRootComp
//********************************************** TN_UDCompBase.PrepRootComp ***
// Prepare Executed SubTree Root Component
//
// In TN_UDCompBase class Component Dynamic Parameters are created as a copy of 
// Static Parameters, and Set Parameters Commands List is executed to change 
// Component Dynamic Parameters
//
// In descendant clases oveloaded method can change component fields (Size and 
// so on)
//
procedure TN_UDCompBase.PrepRootComp();
begin
  K_RFreeAndCopy( DynPar, R, [K_mdfCopyRArray], 0, -2 ); // create Dyn Params
  InitRunTimeFields( [] );
  CRTFlags := [crtfRootComp];
  ExecSetParams( sppBBAction );
end; // procedure TN_UDCompBase.PrepRootComp

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\PrepMacroPointers
//***************************************** TN_UDCompBase.PrepMacroPointers ***
// Prepare Pointers to all Self Strings, that can contain Macroses Should be 
// overloaded in Descendant Components that uses Macros
//
procedure TN_UDCompBase.PrepMacroPointers();
begin
  NGCont.GCMPtrsNum := 0;
end; // end_of procedure TN_UDCompBase.PrepMacroPointers

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\CalcParams1
//*********************************************** TN_UDCompBase.CalcParams1 ***
// Calculate several Self Params just after end of Settings
//
procedure TN_UDCompBase.CalcParams1( );
begin
  // now empty in BaseComp
end; // procedure TN_UDCompBase.CalcParams1

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\BeforeAction
//********************************************** TN_UDCompBase.BeforeAction ***
// Component Action, executed before Child Components Execution
//
procedure TN_UDCompBase.BeforeAction();
begin
  // empty in BaseComp
end; // end_of procedure TN_UDCompBase.BeforeAction

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\AfterAction
//*********************************************** TN_UDCompBase.AfterAction ***
// Component Action, executed after Child Components Execution
//
procedure TN_UDCompBase.AfterAction();
begin
  // empty in BaseComp
end; // end_of procedure TN_UDCompBase.AfterAction

//************************************************* TN_UDCompBase.DebAction ***
// Component Action, called from ExecSubTree for debug
//
procedure TN_UDCompBase.DebAction( ADebExecPhase: integer );
begin
end; // end_of procedure TN_UDCompBase.DebAction

//********************************************** TN_UDCompBase.ShowSelfHelp ***
// Show Help about Self Class, may be overloaded
//
procedure TN_UDCompBase.ShowSelfHelp( AOwner: TN_BaseForm );
var
  HelpTopicName: string;
begin
  HelpTopicName := Self.ClassName;
  N_ShowHelp( 'HelpComponents.txt', HelpTopicName, AOwner );
end; // end_of procedure TN_UDCompBase.ShowSelfHelp


  //*********************************** Type specific methods

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\PSP
//******************************************************* TN_UDCompBase.PSP ***
// Get typed pointer to Component Static Parameters
//
//     Parameters
// Result - Returns typed pointer to Component Static Parameters
//
function TN_UDCompBase.PSP(): TN_PRCompBase;
begin
  Result := R.P();
//  Result := TN_PRCompBase(R.P());
end; // end_of function TN_UDCompBase.PSP

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\PDP
//******************************************************* TN_UDCompBase.PDP ***
// Get typed pointer to Component Dynamic Parameters
//
//     Parameters
// Result    - Returns typed pointer to Component Dynamic Parameters if they 
//             exist, otherwise to Static
//Parameter - 
//
function TN_UDCompBase.PDP(): TN_PRCompBase;
begin
  if DynPar <> nil then Result := DynPar.P()
                   else Result := R.P();
{
  if DynPar <> nil then Result := TN_PRCompBase(DynPar.P())
                   else Result := TN_PRCompBase(R.P());
}
end; // end_of function TN_UDCompBase.PDP


  //*********************************** Macro and SPL processing methods

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\AddUParamsToSPL
//******************************************* TN_UDCompBase.AddUParamsToSPL ***
// Add User Parameters of given Component as SPL global variables to Component 
// SPL Unit
//
//     Parameters
// AComp   - given Component
// APrefix - SPL global variables Name prefix
// ASL     - strings list to add SPL global variables initialization statements
//
// Add User Params of given Component as SPL global variables with given 
// APrefix. Variables definitions are added to N_MEGlobObj.MECompSPLText, 
// variables initialization statements are added to given ASL.
//
procedure TN_UDCompBase.AddUParamsToSPL( AComp: TN_UDBase; APrefix: string;
                                                                ASL: TStrings );
var
  i: integer;
  ValTName, OrigValTName, VarName, PVarName, PointerPrefix, CompName: string;
  CompRArray: TK_RArray;
  ValueTCode: TK_ExprExtType;
begin
  with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
  begin
    if not (AComp is TN_UDCompBase) then Exit;
    CompRArray := TN_UDCompBase(AComp).PDP()^.CCompBase.CBUserParams;
    if CompRArray = nil then Exit; // no User Params

    CompName := APrefix + 'UPComp';
    Add( CompName + ': TN_UDBase;' );
    PointerPrefix := '=UDFPDyn(' + CompName + ', "CCompBase.CBUserParams[';

    for i := 0 to CompRArray.AHigh() do // along User Params
    with TN_POneUserParam(CompRArray.P(i))^ do
    begin
      if (UPName = '') or (UPValue = nil) then Continue; // skip empty Params

      ValueTCode := UPValue.ElemType;
      if UPValue.Alength() = 0 then Continue; // skip empty Params

      if UPValue.Alength() = 1 then // User Parameter is Scalar
      begin
        // add definition of global variable and pointer to it
        OrigValTName := K_GetExecTypeName( ValueTCode.All );

        ValTName := OrigValTName; // Value Type Name used in SPL unit
        if ValTName = 'TN_TimeSeriesUP'  then ValTName := 'TN_TimeSeriesUPR'; // Rus type
        if ValTName = 'TN_CodeSpaceItem' then ValTName := 'String'; // only CSItemKey

        VarName := APrefix + UPName;
        Add( VarName + ': ' + ValTName + ';' );  // UPValue itself

        PVarName := 'P' + VarName;
        Add( PVarName + ': ^' + ValTName + ';' ); // pointer to UPValue

        // add global variable initialization
//        ASL.Add( 'ShowDump( "Comp = "+ToString(Adr(' + CompName + ')), 0 );' ); // for debug

         if OrigValTName = 'TN_CodeSpaceItem' then // Item Key String instead of whole TN_CodeSpaceItem
          ASL.Add( PVarName + '=CSItemKeyPDyn(' + CompName + ', "CCompBase.CBUserParams[' +
                              IntToStr(i) + '].UPValue[0]" );' )
        else
          ASL.Add( PVarName + PointerPrefix + IntToStr(i) + '].UPValue[0]" );' );

//        ASL.Add( 'ShowDump( "Ptr = "+String(' + PVarName + '), 0 );' );  // for debug

        ASL.Add( VarName + '=Value(' + PVarName + ');' );
//        ASL.Add( 'ShowDump( "Value = "+String(' + VarName + '), 0 );' ); // for debug

//        if (VarName = '_2Год') or (VarName = '_9Год') then // debug
//          ASL.Add( 'ShowDump( "' + VarName + '+ = "+ Format( "%g", ' + VarName + '), 0 );' );
//        ASL.Add( 'ShowDump( "Comp9 = "+ToString(Adr( _9UPComp )), 0 );' ); // for debug

      end else //********************* User Parameter is Vector
      begin
        // add definitions of global variable and pointer to it
        ValueTCode.D.TFlags := ValueTCode.D.TFlags or K_ffArray;
        ValTName := K_GetExecTypeName( ValueTCode.All );
        VarName := APrefix + UPName;
        Add( VarName + ': ' + ValTName + ';' );  // UPValue itself

        PVarName := 'P' + VarName;
        Add( PVarName + ': ^' + ValTName + ';' ); // pointer to UPValue

        // add global variable initialization
        ASL.Add( PVarName + PointerPrefix + IntToStr(i) + '].UPValue" );' );
        ASL.Add( VarName + '=Value(' + PVarName + ');' );
      end;

    end; // for i := 0 to CompRArray.AHigh() do // along User Params

    Add( '' );
    ASL.Add( '' );
  end; // with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
end; // end_of procedure TN_UDCompBase.AddUParamsToSPL

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\InitSPLUnitText
//******************************************* TN_UDCompBase.InitSPLUnitText ***
// Initialize SPL Unit Text
//
//     Parameters
// AUPComp5 - Component which User Parameters should be added to SLP Unit global
//            variables with prefix '_5'
// AUPComp6 - Component which User Parameters should be added to SLP Unit global
//            variables with prefix '_6'
//
// Clear N_MEGlobObj.MECompSPLText and add to it all needed SPL Text before 
// Component type specific procedures including User Parameters from two given 
// Components
//
procedure TN_UDCompBase.InitSPLUnitText( AUPComp5: TN_UDCompBase;
                                                      AUPComp6: TN_UDCompBase );
var
  i: integer;
  Str, DummyStr: string;
  InitProcs, GlobalsSL: TStringList;
  PCCompBase: TN_PCCompBase;
  SetParams: TK_RArray;
  NextParent: TN_UDCompBase;
begin
  with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
  begin
    Clear();

    Add( 'unit #CompUnit;' );
    Add( 'uses @:\SPL\syslib, @:\SPL\N_Types, @:\SPL\N_Comps, @:\SPL\N_Macros1;' );
    Add( '' );
    Add( 'var' );
    Add( '_ResStr: string;' );
    Add( '_ResInt: integer;' );
    Add( '_SP: TN_OneSetParam;' );
    Add( '_G:  TN_SPLMacroContext;' );

    PCCompBase := @(PDP()^.CCompBase);

    with PCCompBase^ do
    begin
      if CBUDBase_1 <> nil then Add( '_1UDBase: TN_UDBase;' );
    end;
    Add( '' );

    //***** Add _?UP?, P_?UP? variable definitions to MECompSPLText
    //      and theirs initialization code to InitProcs

    InitProcs := TStringList.Create;
    InitProcs.Add( 'Procedure SPLInitGVars();' );
    InitProcs.Add( 'begin' );
//    InitProcs.Add( 'Deb($21);' ); // for SPL Debug
//    InitProcs.Add( 'ShowDump( "Comp9 = "+ToString(Adr( _9UPComp )), 0 );' ); // for debug

    AddUParamsToSPL( Self, '_1', InitProcs ); // Self User Params

    NextParent := DynParent;
    if NextParent <> nil then
    begin
      AddUParamsToSPL( NextParent, '_2', InitProcs );  // Self.Parent User Params
      NextParent := NextParent.DynParent;

      if NextParent <> nil then
      begin
        AddUParamsToSPL( NextParent, '_3', InitProcs );  // Self.Parent.Parent User Params
        NextParent := NextParent.DynParent;

        if NextParent <> nil then
        begin
          AddUParamsToSPL( NextParent, '_4', InitProcs );  // Self.Parent.Parent.Parent User Params
        end; // if NextParent <> nil then

      end; // if NextParent <> nil then

    end; // if NextParent <> nil then

    if AUPComp5 <> nil then AddUParamsToSPL( AUPComp5, '_5', InitProcs );
    if AUPComp6 <> nil then AddUParamsToSPL( AUPComp6, '_6', InitProcs );

    with PCCompBase^ do
    begin
      if CBComp_8 <> nil then AddUParamsToSPL( CBComp_8, '_8', InitProcs );
      if CBComp_9 <> nil then AddUParamsToSPL( CBComp_9, '_9', InitProcs );
    end;

    InitProcs.Add( 'end;' );
    InitProcs.Add( '' );

    Str := PCCompBase^.CBSPLGlobals;
    if Str <> '' then
    begin
      GlobalsSL := TStringList.Create;
      GlobalsSL.Text := Str;
      AddStrings( GlobalsSL );
      GlobalsSL.Free;
      Add( '' );
    end; // if Str <> '' then

    AddStrings( InitProcs ); // add Init Procedures to main MECompSPLText
    InitProcs.Free;

    //***** Add SetParams SPL Code

//    SetParams := TK_PRArray(DynPar.P())^;
    SetParams := TK_PRArray(PDP())^;

    for i := 0 to SetParams.AHigh() do
    with TN_POneSetParam(SetParams.P(i))^ do
    begin
      if SPFunc = spftSPL then // add macro
      begin
        MacroProcNumber := i+1;
        MacroProcPrefix := 'SPProc'; // Set Params SPL procedure
        AddOneMacroToSPL( SPSPLCode, DummyStr );
      end;
    end; // with ... do, for i := 0 to SetParams.AHigh() do

    MacroProcNumber := 1; // initialize for use in AddOneMacroToSPL
  end; // with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
end; // end_of procedure TN_UDCompBase.InitSPLUnitText

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\ExpandUPMacros
//******************************************** TN_UDCompBase.ExpandUPMacros ***
// Expand User Parameters Macroses in given string
//
//     Parameters
// AStr - string to exapnd Macroses (on input source string on uotput resulting 
//        string after Macroses expansion)
//
// User Parameters Macroses are tokens like _UPx_<name>, where <name> is User 
// Parameter Name in Component, specified by x (character x means following: =1 
// - Self Component, =2 - Parent Component, =8 - Component from Self field 
// CBComp_8, =9 - Component from Self field CBComp_9). These tokens are replaced
// by User Parameter value (User Parameters which type is 'string' should be 
// used as macroses values).
//
procedure TN_UDCompBase.ExpandUPMacros( var AStr: string );
var
  i, iEnd, CurInd, NewInd, SavedInd: integer;
  BeforeLeng, MinLeng, RestLeng, AStrLeng, CResLeng: integer;
  NumParams, NumParams1, NumParams2, NumParams8, NumParams9: integer;
  CurRes, UPStr, CurUPName: string;
  x: Char;
  PCCompBase: TN_PCCompBase;
  PUParams, PUParams1, PUParams2, PUParams8, PUParams9: TN_POneUserParam;
  Label FinCurRes, ContSearch, CurUPNameIsOK;
begin
  if AStr = '' then Exit;
  PCCompBase := @(PDP()^.CCompBase);
  if not (cbfUPMacros in PCCompBase^.CBFlags1) then Exit;

  NumParams  := 0;
  PUParams  := nil;
  PUParams1 := nil;
  PUParams2 := nil;
  PUParams8 := nil;
  PUParams9 := nil;

  NumParams1 := -1; // initial value
  NumParams2 := -1;
  NumParams8 := -1;
  NumParams9 := -1;

  AStrLeng := Length( AStr );
  SetLength( CurRes, AStrLeng + 100 );
  CResLeng := 0;
  CurRes   := '';
  CurInd   := 1;
  SavedInd := 1;

  while True do
  with PCCompBase^ do
  begin
    NewInd := PosEx( '_UP', AStr, CurInd );

    if NewInd = 0 then // not found (no more UP Macros) Add Rest of AStr to ResStr
    begin
      FinCurRes: // Finish creating CurRes

      if CResLeng = 0 then Exit; // CurRes is Empty, AStr remains the same

      RestLeng := AStrLeng - SavedInd + 1;
      SetLength( CurRes, CResLeng + RestLeng );
      move( AStr[SavedInd], CurRes[CResLeng+1], RestLeng );
      AStr := CurRes;
      Exit; // all done
    end else // NewInd >= 1, '_UP' found
    begin
      CurInd := NewInd + 3; // Beg of next search

      if AStrLeng < (NewInd+4) then goto FinCurRes; // same action as if NewInd = 0
      if AStr[NewInd+4] <> '_' then Continue;

      x := AStr[NewInd+3]; // Component "Number" Character (1,2,8,9)

      iEnd := min( NewInd+30, AStrLeng );
      for i := NewInd+5 to iEnd do // search for UPName delimeter ('_')
      begin
        if AStr[i] = '_' then // UPName delimeter found
        begin
          CurUPName := Copy( AStr, NewInd+5, i-(NewInd+5) );
          CurInd := i+1; // Beg Index for next search
          goto CurUPNameIsOK;
        end; // if AStr[i] = '_' then // UPName delimeter found
      end; // for i := Ind+5 to iEnd do // search for UPName delimeter ('_')

      //***** Error: UPName delimeter not found

      CurInd := iEnd;
      Continue;

      CurUPNameIsOK: // CurInd, CurUPName are OK, set PUParams, NumParams and seacrh it

      case x of // x is a Component "Number" Character (1,2,8,9)

      '1': begin // Self User Params

        if NumParams1 = -1 then // Set PUParams1 and NumParams1
        begin
          NumParams1 := 0;

          if CBUserParams = nil then goto ContSearch;

          NumParams1 := CBUserParams.ALength();
          PUParams1  := TN_POneUserParam(CBUserParams.P());
        end; // if NumParams1 = -1 then // Set PUParams1 and NumParams1

        NumParams := NumParams1;
        PUParams  := PUParams1;
      end; // '1': begin // Self User Params

      '2': begin // Parent User Params

        if NumParams2 = -1 then // Set PUParams2 and NumParams2
        begin
          NumParams2 := 0;

          if DynParent = nil then goto ContSearch;

          with DynParent.PDP()^.CCompBase do
          begin
            if CBUserParams = nil then goto ContSearch;

            NumParams2 := CBUserParams.ALength();
            PUParams2  := TN_POneUserParam(CBUserParams.P());
          end; // with DynParent.PDP()^.CCompBase do
        end; // if NumParams2 = -1 then // Set PUParams2 and NumParams2

        NumParams := NumParams2;
        PUParams  := PUParams2;
      end; // '2': begin // Parent User Params

      '8': begin // CBComp_8 User Params

        if NumParams8 = -1 then // Set PUParams8 and NumParams8
        begin
          NumParams8 := 0;

          if not (CBComp_8 is TN_UDCompBase) then goto ContSearch;

          with TN_UDCompBase(CBComp_8).PDP()^.CCompBase do
          begin
            if CBUserParams = nil then goto ContSearch;

            PUParams8  := TN_POneUserParam(CBUserParams.P());
            NumParams8 := CBUserParams.ALength();
          end; // with TN_UDCompBase(CBComp_8).PDP()^.CCompBase do
        end; // if NumParams8 = -1 then // Set PUParams8 and NumParams8

        NumParams := NumParams8;
        PUParams  := PUParams8;
      end; // '8': begin // CBComp_8 User Params

      '9': begin // CBComp_9 User Params

        if NumParams9 = -1 then // Set PUParams9 and NumParams9
        begin
          NumParams9 := 0;

          if not (CBComp_9 is TN_UDCompBase) then goto ContSearch;

          with TN_UDCompBase(CBComp_9).PDP()^.CCompBase do
          begin
            if CBUserParams = nil then goto ContSearch;

            PUParams9  := TN_POneUserParam(CBUserParams.P());
            NumParams9 := CBUserParams.ALength();
          end; // with TN_UDCompBase(CBComp_9).PDP()^.CCompBase do
        end; // if NumParams9 = -1 then // Set PUParams9 and NumParams9

        NumParams := NumParams9;
        PUParams  := PUParams9;
      end; // '9': begin // CBComp_9 User Params

      else // x <> 1, 2, 8 or 9
        goto ContSearch;

      end; // case x of

      if NumParams = 0 then goto ContSearch;

      //***** Search for UPName from PUParams

      for i := 1 to NumParams do // along all UserParams
      begin
        if PUParams^.UPName = CurUPName then // CurUPName found
        begin
          if PUParams^.UPValue.GetElemType.DTCode <> Ord(nptString) then goto ContSearch; // not a string

          // CurUPName is found and is a string, replace it by CurUPName content

          UPStr := PString(PUParams^.UPValue.P())^; // User Param Content

          BeforeLeng := NewInd - SavedInd;
          MinLeng := CResLeng + BeforeLeng + Length(UPStr);

          if Length(CurRes) < MinLeng then // increase CurRes Length
          begin
            if Length(CurRes) = 0 then
              SetLength( CurRes, Max( MinLeng, AStrLeng+100 ) )
            else
              SetLength( CurRes, MinLeng+100 );
          end;

          move( AStr[SavedInd], CurRes[CResLeng+1], BeforeLeng ); // Before Macro

          Inc( CResLeng, BeforeLeng );
          move( UPStr[1], CurRes[CResLeng+1], Length(UPStr) ); // Macro Content

          Inc( CResLeng, Length(UPStr) );
          SavedInd := CurInd;

          Break;
        end; // if PUParams^.UPName = CurUPName then // CurUPName found

        Inc( PUParams ); // to next User Param
      end; // for i := 1 to NumParams do // along all UserParams

    end; // else - Ind >= 1

    ContSearch: //************ Continue Search

//    CurInd := NewInd + 1;
  end; // with PCCompBase^ do, while True do
end; // end_of procedure TN_UDCompBase.ExpandUPMacros

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\FinSPLUnit
//************************************************ TN_UDCompBase.FinSPLUnit ***
// Finalize SPL Unit Text if needed and compile
//
procedure TN_UDCompBase.FinSPLUnit();
begin
  with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
  begin

    if SPLUnit <> nil then SPLUnit.UDDelete;
    SPLUnit := nil;
    if not K_CompileUnit( MECompSPLText.Text, SPLUnit ) then
    begin
      SPLUnit.UDDelete;
      SPLUnit := nil;
    end;

  end; // with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
end; // end_of procedure TN_UDCompBase.FinSPLUnit

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\InitGVars
//************************************************* TN_UDCompBase.InitGVars ***
// Initialize User Parameters SPL global variables (_xUPComp)
//
// Initialize  _xUPComp variables by appropriate UDBase objects and call 
// SPLInitGVars
//
procedure TN_UDCompBase.InitGVars();
var
  UDPI: TK_UDProgramItem;
  UDRGlobData: TK_UDRArray;
  PField: Pointer;
  FieldTCode: TK_ExprExtType;
  PCCompBase: TN_PCCompBase;
  NextParent: TN_UDCompBase;
begin
  if SPLUnit = nil then Exit;
//  N_s := ObjName; // debug

  UDRGlobData := SPLUnit.GetGlobalData();

  N_GetRAFieldInfo( UDRGlobData.R, '_G', FieldTCode, PField ); // same as UpdateBySPLMCont();
  if PField <> nil then
    TN_PSPLMacroContext(PField)^ := NGCont.SPLMCont;

  N_GetRAFieldInfo( UDRGlobData.R, '_1UPComp', FieldTCode, PField );
  if PField <> nil then
    TN_PUDBase(PField)^ := Self;

  N_GetRAFieldInfo( UDRGlobData.R, '_2UPComp', FieldTCode, PField );
  if PField <> nil then
    TN_PUDBase(PField)^ := DynParent;

  if DynParent <> nil then
    NextParent := DynParent.DynParent
  else
    NextParent := nil;

  N_GetRAFieldInfo( UDRGlobData.R, '_3UPComp', FieldTCode, PField );
  if PField <> nil then
    TN_PUDBase(PField)^ := NextParent;

  if NextParent <> nil then
    NextParent := NextParent.DynParent
  else
    NextParent := nil;

  N_GetRAFieldInfo( UDRGlobData.R, '_4UPComp', FieldTCode, PField );
  if PField <> nil then
    TN_PUDBase(PField)^ := NextParent;

  PCCompBase := @(PDP()^.CCompBase);

  N_GetRAFieldInfo( UDRGlobData.R, '_8UPComp', FieldTCode, PField );
  if PField <> nil then
    TN_PUDBase(PField)^ := PCCompBase^.CBComp_8;

  N_GetRAFieldInfo( UDRGlobData.R, '_9UPComp', FieldTCode, PField );
  if PField <> nil then
    TN_PUDBase(PField)^ := PCCompBase^.CBComp_9;

//  if PCCompBase^.CBComp_9 <> nil then
//    N_s := PCCompBase^.CBComp_9.ObjName; // debug

  N_GetRAFieldInfo( UDRGlobData.R, '_1UDBase', FieldTCode, PField );
  if PField <> nil then
    TN_PUDBase(PField)^ := PCCompBase^.CBUDBase_1;

  UDPI := TK_UDProgramItem(SPLUnit.DirChildByObjName( 'SPLInitGVars' ));
  UDPI.CallSPLRoutine( [] );

end; // end_of procedure TN_UDCompBase.InitGVars

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\AddOneMacroToSPL
//****************************************** TN_UDCompBase.AddOneMacroToSPL ***
// Add procedure to SPL Unit by given source Macro string
//
//     Parameters
// AMacroSrc  - source Macro string
// AMacroDest - resulting string needed for future Macro Replace
//
// Add procedure to SPL Unit build by given source Macro string (AMacroSrc) and 
// set in resulting string (AMacroDest) SPL Procedure Name (for use in 
// MacroReplaceObj)
//
function TN_UDCompBase.AddOneMacroToSPL( AMacroSrc: string;
                                         var AMacroDest: string ): TK_MRResult;
var
  i, NumChars: integer;
  FirstToken, ProcName: string;
  CurChar: Char;
begin
  Result := K_mrrOK;
  NumChars := Length(AMacroSrc);

  with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
  begin
    ProcName := MacroProcPrefix + IntToStr(MacroProcNumber);
    AMacroDest := '(#' + ProcName + '#)';
    Add( 'procedure ' + ProcName + '();' );
    Inc( MacroProcNumber );

    for i := 1 to NumChars do // seek for first not white char and check FirstToken
    begin
      if i = NumChars then // EmptyMacro
      begin
        Add( 'begin _ResStr=""; end;' );
        Break;
      end;

      CurChar := Char( AMacroSrc[i] );
      if (CurChar = ' ') or (CurChar = #$0A) or (CurChar = #$0D) then Continue;

      FirstToken := UpperCase(Copy( AMacroSrc, i, 3 ));

      if (FirstToken = 'VAR') or (FirstToken = 'BEG') then // full macro, not expression
        Add( AMacroSrc + '; end;' )
      else //*********** macro is expression
        Add( 'begin _ResStr=' + AMacroSrc + '; end;' );

      Break;
    end; // for i := 1 to NumChars do // seek for first not white char and check FirstToken

    Add( '' );
  end; // with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
end; // end_of procedure TN_UDCompBase.AddOneMacroToSPL

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\ExpandOneMacroBySPL
//*************************************** TN_UDCompBase.ExpandOneMacroBySPL ***
// Expand given Macro name to Macro result
//
//     Parameters
// AMacroSPLName - name of SPL Unit procedure to call for Macro Result building
// AMacroResult  - resulting string build by corresponding SPL Unit procedure
//
// Is used in MacroReplace Object
//
function TN_UDCompBase.ExpandOneMacroBySPL( AMacroSPLName: string;
                                        var AMacroResult: string ): TK_MRResult;
var
  UDPI: TK_UDProgramItem;
  UDRGlobData : TK_UDRArray;
  PField: Pointer;
  FieldTCode: TK_ExprExtType;
begin
  Result := K_mrrUndef;
  AMacroResult := '';
  if SPLUnit = nil then Exit;

  UDRGlobData := SPLUnit.GetGlobalData();

  with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
  begin

//    UDPI := TK_UDProgramItem(SPLUnit.DirChildByObjName( MacroProcPrefix +
//                                                  IntToStr(MacroProcNumber) ));
    UDPI := TK_UDProgramItem(SPLUnit.DirChildByObjName( AMacroSPLName ));

    if UDPI <> nil then
    begin
      NGCont.GCNKGCont.SPLComp := Self; // for using in SPL funcs, implemented in Pascal
      UDPI.CallSPLRoutine( [], NGCont.GCNKGCont );
      N_GetRAFieldInfo( UDRGlobData.R, '_ResStr', FieldTCode, PField );
      if PField <> nil then
        AMacroResult := PString(PField)^
      else
        Exit;
    end; // if UDPI <> nil then

  end; // with N_MEGlobObj, N_MEGlobObj.MECompSPLText do

  Result := K_mrrOK;
end; // end_of procedure TN_UDCompBase.ExpandOneMacroBySPL

//********************************************** TN_UDCompBase.PrepL1Macros ***
// Prepare L1 Macros: Create and Initialize SPL Unit by SPL code in GCMPtrsNum
// strings, pointed to by GCMacroPtrs pointers (now not used, can be used in
// Processing Office macros)
//
procedure TN_UDCompBase.PrepL1Macros();
var
  i: integer;
  ResStr: string;
begin
//  N_s := ObjName; // debug

  with N_MEGlobObj, NGCont, PDP()^.CCompBase do
  begin
    InitSPLUnitText();

    for i := 0 to GCMPtrsNum-1 do // along all collected strings, create SPL procedures for L1 Macroses
    begin
      AddOneMacroToSPL( GCMacroPtrs[i]^, ResStr );
    end; // for i := 0 to GCMPtrsNum-1 do // along all collected strings

    FinSPLUnit();
    InitGVars();
  end; // with N_MEGlobObj, NGCont, PDP()^.CCompBase do
end; // end_of procedure TN_UDCompBase.PrepL1Macros

//***************************************** TN_UDCompBase.ProcessOneL1Macro ***
// Process one given L1 Macro: Create and Initialize SPL Unit by SPL code in
// given AMacro, execute created SPL code and return SPL _ResStr variable
// content (is used in Processing Office macros)
//
function TN_UDCompBase.ProcessOneL1Macro( AMacro: string ): string;
var
  ProcName: string;
  UDPI: TK_UDProgramItem;
  UDRGlobData : TK_UDRArray;
  PField: Pointer;
  FieldTCode: TK_ExprExtType;
begin
//  N_s := ObjName; // debug

  with N_MEGlobObj, NGCont, PDP()^.CCompBase do
  begin
    InitSPLUnitText();
    MacroProcNumber := 1; // initial L1 Macros index
    MacroProcPrefix := 'MSOProc';
    AddOneMacroToSPL( AMacro, ProcName );
    FinSPLUnit();
    if SPLUnit = nil then Exit;

    InitGVars();

    UDRGlobData := SPLUnit.GetGlobalData();
    UDPI := TK_UDProgramItem(SPLUnit.DirChildByObjName( 'MSOProc1' ));

    if UDPI <> nil then
    begin
      GCNKGCont.SPLComp := Self; // for using in SPL funcs, implemented in Pascal
      UDPI.CallSPLRoutine( [], GCNKGCont );
      N_GetRAFieldInfo( UDRGlobData.R, '_ResStr', FieldTCode, PField );
      if PField <> nil then
        Result := PString(PField)^
      else
        Result := '';
    end; // if UDPI <> nil then

  end; // with N_MEGlobObj, NGCont, PDP()^.CCompBase do
end; // end_of function TN_UDCompBase.ProcessOneL1Macro

//******************************************* TN_UDCompBase.ExpandAllMacros ***
// Expand all types (UP, L1, L2) of Self Macroses
//
procedure TN_UDCompBase.ExpandAllMacros();
var
  i, ResStrLeng: integer;
  ResStr: string;
begin
  N_s := ObjName; // debug

  with N_MEGlobObj, NGCont, PDP()^.CCompBase do
  begin
    if [cbfUPMacros,cbfL1Macros,cbfL2Macros]*CBFlags1 = [] then Exit;

    PrepMacroPointers(); // Prepare GCMacroPtrs and GCMPtrsNum

    if GCMPtrsNum = 0 then Exit; // nothing to do

    if cbfUPMacros in CBFlags1 then // Expand UP Macroses
      for i := 0 to GCMPtrsNum-1 do // along all collected strings
        ExpandUPMacros( GCMacroPtrs[i]^ );

    if cbfL1Macros in CBFlags1 then // Create SPL Unit and Expand L1 Macroses
    begin
      InitSPLUnitText();
      MacroProcNumber := 1; // initial L1 Macros index
      MacroProcPrefix := 'MProc';
      MacroReplaceObj.SetParsingContext( '(#', '#)', AddOneMacroToSPL );
      MacroReplaceObj.MacroFlags := [];

      for i := 0 to GCMPtrsNum-1 do // along all collected strings, create SPL procedures for L1 Macroses
      begin
        ResStrLeng := MacroReplaceObj.StringMacroReplace( ResStr, GCMacroPtrs[i]^ );

        if ResStrLeng > 0 then
        begin
          SetLength( ResStr, ResStrLeng );
          GCMacroPtrs[i]^ := ResStr;
        end;
      end; // for i := 0 to GCMPtrsNum-1 do // along all collected strings

      FinSPLUnit();
      InitGVars();
      MacroProcNumber := 1; // initial L1 Macros index
      MacroReplaceObj.SetParsingContext( '(#', '#)', ExpandOneMacroBySPL );
      MacroReplaceObj.MacroFlags := [];

      for i := 0 to GCMPtrsNum-1 do // along all collected strings, expand L1 macroses
      begin
        ResStrLeng := MacroReplaceObj.StringMacroReplace( ResStr, GCMacroPtrs[i]^ );

        if ResStrLeng > 0 then
        begin
          SetLength( ResStr, ResStrLeng );
          GCMacroPtrs[i]^ := ResStr;
        end;
      end; // for i := 0 to GCMPtrsNum-1 do // along all collected strings

    end; // if cbfL1Macros in CBFlags1 then // Create SPL Unit and Expand L1 Macroses

    if cbfL2Macros in CBFlags1 then // Process L2 Macroses
    begin
      MacroReplaceObj.SetParsingContext( '(##', '##)', MacroReplaceObj.TextAssemblingMRFunc );
      MacroReplaceObj.MacroFlags := [];

      for i := 0 to GCMPtrsNum-1 do // along all collected strings
      begin
        MacroReplaceObj.InitTextAssemblingContext();
        ResStrLeng := MacroReplaceObj.StringMacroReplace( ResStr, GCMacroPtrs[i]^ );

        if ResStrLeng > 0 then
        begin
          SetLength( ResStr, ResStrLeng );
          GCMacroPtrs[i]^ := ResStr;
        end;
      end; // for i := 0 to GCMPtrsNum-1 do
    end; // if cbfL2Macros in CBFlags1 then // Process L2 Macroses

  end; // with N_MEGlobObj, NGCont, PDP()^.CCompBase do
end; // end_of procedure TN_UDCompBase.ExpandAllMacros

//****************************************** TN_UDCompBase.UpdateBySPLMCont ***
// Update SPL _G variable by SPLMCont
//
procedure TN_UDCompBase.UpdateBySPLMCont();
var
  UDRGlobData: TK_UDRArray;
  PField: Pointer;
  FieldTCode: TK_ExprExtType;
begin
  if SPLUnit = nil then Exit;

  UDRGlobData := SPLUnit.GetGlobalData();
  N_GetRAFieldInfo( UDRGlobData.R, '_G', FieldTCode, PField );
  if PField <> nil then
    TN_PSPLMacroContext(PField)^ := NGCont.SPLMCont;
end; // procedure TN_UDCompBase.UpdateBySPLMCont


  //*********************************** Execute SubTree related methods

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\ExecSetParams
//********************************************* TN_UDCompBase.ExecSetParams ***
// Execute Component Set Parameter Commands corresponding to given Component 
// Execution phase
//
//     Parameters
// ASPPhase - given Execution phase
//
// Execute Component Set Parameter Commands Array stored in Component Dynamic 
// Parameters
//
procedure TN_UDCompBase.ExecSetParams( ASPPhase: TN_SetParamsPhase );
var
  i, j, Ind, NumBytes, NumElems: integer;
  Str, ResStr, MacroResult, UPName, UPDescr: string;
  SetParams, SrcRA, DstRA: TK_RArray;
  UDRGlobData: TK_UDRArray;
  PSrcField, PDstField, PField, PSetBytes: Pointer;
  SrcFTCode, DstFTCode, FieldTCode: TK_ExprExtType;
  SrcUObj, DstUObj: TN_UDBase;
  DE: TN_DirEntryPar;
  UDPI: TK_UDProgramItem;
  PUserParam: TN_POneUserParam;
  MoveDataFlags: TK_MoveDataFlags;
  AnyData: Array [0..31] of Byte;
  XORDataSize : Integer;
  XORAssignData : Int64;
  XORAssignDType : TK_ExprExtType;


  function VarIsTrue( APSrcField: Pointer; ASrcFTCode: TK_ExprExtType ): boolean; // local
  // Return True if SrcField is <> 0
  begin
    Result := False;

    if (ASrcFTCode.DTCode = ord(nptInt)) or (ASrcFTCode.DTCode = ord(nptHex)) then
      Result := (PInteger(APSrcField)^ <> 0);

    if ASrcFTCode.DTCode = ord(nptByte) then
      Result := (PByte(APSrcField)^ <> 0);

  end; // function VarIsTrue - local
{
  function GetNumBytes( AInt: integer ): integer; // local
  // Return number of Bytes in AInt that contain all flags
  begin
    Result := 1;
    if (AInt and $0000FF00) <> 0 then Result := 2;
    if (AInt and $00FF0000) <> 0 then Result := 3;
    if (AInt and $FF000000) <> 0 then Result := 4;
  end; // function GetNumBytes - local
}
begin //**************************** main body of TN_UDCompBase.ExecSetParams
  N_s := ObjName; // debug
  if N_s = 'РеспbrКарелия' then // debug
    N_i := 1;

//  if N_s = 'Straight Arrow' then // debug
//    N_i := 1;

  SetParams := TK_PRArray(PDP())^;

  for i := 0 to SetParams.AHigh() do // main loop along all SetParams elements
  with TN_POneSetParam(SetParams.P(i))^ do
  begin
    if SPPhase <> ASPPhase then Continue; // not proper phase
    if SPFunc  =  spftSkip then Continue; // skip SetParams element

    if SPFunc = spftInitGVars then // just Init SPL Global Variables
    begin
      InitGVars();
      Continue;
    end;

    //************************ Set SrcUObj and SrcRA
 
    if SPSrcUObj = nil then
    begin
      SrcUObj := Self;
    end else
    begin
      SPSrcUObj.GetDEByRPath( SPSrcPath, DE );
      SrcUObj := DE.Child;
    end;
 
    if SrcUObj is TK_UDRArray then
    begin
      if SrcUObj is TN_UDCompBase then
      begin
        if spofStat in SPSrcFlags then
          SrcRA := TN_UDCompBase(SrcUObj).R
        else
        begin
          SrcRA := TN_UDCompBase(SrcUObj).DynPar;
          if SrcRA = nil then SrcRA := TN_UDCompBase(SrcUObj).R;
        end
      end else
        SrcRA := TK_UDRArray(SrcUObj).R;
    end else
      SrcRA := nil;

    //******************* SrcUObj and SrcRA are OK, Set DstUObj and DstRA

    if SPDstUObj = nil then
    begin
      DstUObj := Self;
    end else
    begin
      SPDstUObj.GetDEByRPath( SPDstPath, DE );
      DstUObj := DE.Child;
    end;

    if DstUObj is TK_UDRArray then
    begin
      if DstUObj is TN_UDCompBase then
      begin
        if spofStat in SPDstFlags then
          DstRA := TN_UDCompBase(DstUObj).R
        else
        begin
          DstRA := TN_UDCompBase(DstUObj).DynPar;
          if DstRA = nil then DstRA := TN_UDCompBase(DstUObj).R;
        end;
      end else
        DstRA := TK_UDRArray(DstUObj).R;
    end else
      DstRA := nil;

    //******** SrcUObj,SrcRA, DstUObj,DstRA are OK, check Assignment condition

    if spfSkipIfZeroSrcUP in SPFlags then // in SPTxtPar is Name of boolean Src UserParam,
    begin                       // if it is False (=0), skip current SetParams element
      if not N_GetUserParBoolValue( SrcRA, SPTxtPar ) then Continue; // Skip if False
    end; // if spfSkipIfZeroSrcUP in SPFlags then // in SPTxtPar is boolean UserParam Name

    if spfSkipIfZeroSelfUP in SPFlags then // in SPTxtPar is Name of boolean Self UserParam,
    begin                       // if it is False (=0), skip current SetParams element
      if not N_GetUserParBoolValue( DynPar, SPTxtPar ) then Continue; // Skip if False
    end; // if spfSkipIfZeroSelfUP in SPFlags then // in SPTxtPar is boolean UserParam Name

    //********  Set SrcFTCode and PSrcField

    PSrcField := nil;
    SrcFTCode.All := 0;
 
    if SPSrcField <> '' then
    begin
      if SPSrcField[1] = '#' then // CS Code is given (SrcUObj should be TK_UDVector)
      begin // e.g. #79 for Code=79 
        if SrcUObj is TK_UDVector then
        with TK_UDVector(SrcUObj) do
        begin
          Ind := GetDCSSpace().IndexByCode( Copy( SPSrcField, 2, Length(SPSrcField) ) );
          PSrcField := DP( Ind );
          SrcFTCode := PDRA().ElemType;
          SrcFTCode.D.TFlags := SrcFTCode.D.TFlags and (not K_ffArray);
        end; // if ... with TK_UDVector(SrcUObj) do
      end else //******************* direct Field Name is given
      begin
        N_s := SPSrcField; // debug
//        if N_s = 'MaxFunc' then
//          N_i := 1;

        if spofUserParam in SPSrcFlags then // SPSrcField is User Parameter Name
        begin
          PUserParam := N_GetUserParPtr( SrcRA, SPSrcField );

          if PUserParam <> nil then // User Parameter exists
          begin
            NumElems := PUserParam^.UPValue.ALength();

            if (NumElems > 1) or (spofUPArray in SPSrcFlags) then
            begin              // Vector User param, PSrcField points to RArray
              PSrcField := @(PUserParam^.UPValue);
              SrcFTCode := PUserParam^.UPValue.ArrayType;
            end else if NumElems = 1 then // Scalar User param, PSrcField points to it
            begin
              PSrcField := PUserParam^.UPValue.P();
              SrcFTCode := PUserParam^.UPValue.ElemType
            end;
          end; // if PUserParam <> nil then

        end else //*************************** SPSrcField is RArray field Name
        begin
          if SrcRA <> nil then
          begin
            N_s := K_GetExecTypeName( SrcRA.ElemType.All ); // debug
            N_GetRAFieldInfo( SrcRA, SPSrcField, SrcFTCode, PSrcField );
          end;
        end; // else - SPSrcField is RArray field Name

      end; // else - Field Name is given
    end; // if SPSrcField <> '' then

    //***************** SrcFTCode,PSrcField are OK, Set DstFTCode and PDstField

    N_s := K_GetExecTypeName( DstRA.ElemType.All ); // debug
    PDstField := nil;
    if DstRA <> nil then
    begin
      N_s := K_GetExecTypeName( DstRA.ElemType.All ); // debug

      if (spofUserParam in SPDstFlags) or (SPDstField = '#UP') then // Dst is UserParam, it may be not created yet
      begin
        if spofUserParam in SPDstFlags then
        begin
          UPName  := SPDstField;
          UPDescr := '';
        end else
        begin
          Str := SPTxtPar;
          UPName  := N_ScanToken( Str );
          UPDescr := N_ScanToken( Str );
        end;

        N_CurCreateRAFlags := []; // is needed for N_GetUserParPtr function
        if spofStat in SPDstFlags then // Static Dst Params
          N_CurCreateRAFlags := N_CurCreateRAFlags + [K_crfCountUDRef];

        PUserParam := N_CGetUserParPtr( DstRA, UPName, UPDescr, SrcFTCode, 1 );

        DstFTCode := SrcFTCode;
//        PDstField := @(PUserParam^.UPValue);
        PDstField := PUserParam^.UPValue.P();
      end else // not UserParam (existing Field)
        N_GetRAFieldInfo( DstRA, SPDstField, DstFTCode, PDstField );
    end;

    //***** Here: PSrcField, PDstField, SrcFTCode, DstFTCode are OK,
    //            check if they are correct and execute needed action

    case SPFunc of

    spftAssign: begin // assign needed field by K_MoveSPLData
      if (PSrcField = nil) or (PDstField = nil) or
         not N_SameDTCodes( K_GetExecTypeBaseCode( SrcFTCode ),
                            K_GetExecTypeBaseCode( DstFTCode ) ) then Continue;

//      N_d1 := PDouble(PSrcField)^; // debug
//      N_d2 := PDouble(PDstField)^; // debug
 
      if PSrcField <> PDstField then // some times is needed
      begin
        MoveDataFlags := [K_mdfCopyRArray,K_mdfFreeDest];
        if spofStat in SPDstFlags then // Static Dst Params
          MoveDataFlags := MoveDataFlags + [K_mdfCountUDRef];
 
        K_MoveSPLData( PSrcField^, PDstField^, SrcFTCode, MoveDataFlags );
//      N_d := PDouble(PDstField)^; // debug
      end; // // if PSrcField <> PDstField then // some times is needed
    end; // spftAssign: begin
 
    spftSPL: begin // Execute SPL Macro
      if SPLUnit = nil then Continue;
      UDRGlobData := SPLUnit.GetGlobalData();
      N_GetRAFieldInfo( UDRGlobData.R, '_SP', FieldTCode, PField );
      if PField <> nil then
        TN_POneSetParam(PField)^ := TN_POneSetParam(SetParams.P(i))^; // init _SP var
 
      UDPI := TK_UDProgramItem(SPLUnit.DirChildByObjName( 'SPProc' + IntToStr(i+1) ));
      if UDPI <> nil then
      begin
        UDPI.CallSPLRoutine([]);
        N_GetRAFieldInfo( UDRGlobData.R, '_ResStr', FieldTCode, PField );
        if PField <> nil then
        begin
          MacroResult := PString(PField)^;
          if PDstField <> nil then
            K_SPLValueFromString( PDstField^, DstFTCode.All, MacroResult );
        end;
      end; // if UDPI <> nil then
    end; // spftSPL: begin

    spftIfAssign: begin // if SrcField <> 0, assign SPL Const, given in SPTxtPar
      if VarIsTrue( PSrcField, SrcFTCode ) then // Do assign Const
      begin
        if PDstField = nil then Continue;
        NumBytes := K_GetExecTypeSize( DstFTCode.All );
        Assert( NumBytes <= 32, '> 32 bytes' );
        ResStr := K_SPLValueFromString( PDstField^, DstFTCode.All, SPTxtPar );
//        if ResStr <> '' then Continue; // some Error
      end; // if VarIsTrue( PSrcField, SrcFTCode ) then // Do assign Const
    end; // spftIfAssign: begin

    spftIfSetFlags: begin // if SrcField <> 0, Set Flags, given in SPTxtPar
                          // field in SPL format in DstField
      if VarIsTrue( PSrcField, SrcFTCode ) then // Do Set Flags
      begin
        NumBytes := K_GetExecTypeSize( DstFTCode.All );
        Assert( NumBytes <= 32, '> 32 bytes' );
        ResStr := K_SPLValueFromString( AnyData[0], DstFTCode.All, SPTxtPar );
        if ResStr <> '' then Continue; // some Error
        PSetBytes := @AnyData[0];
 
        for j := 1 to NumBytes do // Set flags Byte by Byte
        begin
          (PByte(PDstField))^ := (PByte(PDstField))^ or (PByte(PSetBytes))^;
          Inc( PByte(PDstField) );
          Inc( PByte(PSetBytes) );
        end; // for j := 1 to NumBytes do // Set flags Byte by Byte
      end; // if VarIsTrue( PSrcField, SrcFTCode ) then // Do Set Flags
    end; // spftIfSetFlags: begin
 
    spftIfClearFlags: begin // if SrcField <> 0, Clear Flags, given in SPTxtPar
                            // field in SPL format in DstField
      if VarIsTrue( PSrcField, SrcFTCode ) then // Do Clear Flags
      begin
        NumBytes := K_GetExecTypeSize( DstFTCode.All );
        Assert( NumBytes <= 32, '> 32 bytes' );
        ResStr := K_SPLValueFromString( AnyData[0], DstFTCode.All, SPTxtPar );
        if ResStr <> '' then Continue; // some Error
        PSetBytes := @AnyData[0];
 
        for j := 1 to NumBytes do // Clear flags Byte by Byte
        begin
          (PByte(PDstField))^ := (PByte(PDstField))^ and (not (PByte(PSetBytes))^);
          Inc( PByte(PDstField) );
          Inc( PByte(PSetBytes) );
        end; // for j := 1 to NumBytes do // Clear flags Byte by Byte
      end; // if VarIsTrue( PSrcField, SrcFTCode ) then // Do Clear Flags
 
    end; // spftIfClearFlags: begin
 
    spftOther: begin // Other Actions, implemented in SetParamsProc
      SetParamsProc( TN_POneSetParam(SetParams.P(i)),
                                PSrcField, PDstField, SrcFTCode, DstFTCode );
    end; // spftOther: begin
 
    spftXORAssign: begin // Special assign - XOR integer value before assign
 
      if (PSrcField = nil) or
         (PDstField = nil) or
         (PSrcField = PDstField) then Continue;
 
        XORAssignDType := K_GetExecTypeBaseCode( SrcFTCode );
        if not N_SameDTCodes( XORAssignDType,
                              K_GetExecTypeBaseCode( DstFTCode ) ) or
           (XORAssignDType.DTCode > Ord(nptInt64)) then Continue;
        XORDataSize := K_GetExecTypeSize( XORAssignDType.All );
        Move( PSrcField^, XORAssignData, XORDataSize );
        XORAssignData := XORAssignData xor $FFFFFFFFFFFFFFFF;
        Move( XORAssignData, PDstField^, XORDataSize );
    end; // spftXORAssign: begin

    end; // case SPFunc of

  end; // for i := 0 to SetParams.AHigh() do - main loop along all SetParams elements

end; // end_of procedure TN_UDCompBase.ExecSetParams

//********************************************* TN_UDCompBase.SetParamsProc ***
// Execute Action, given in SPTxtPar ( is called by ExecSetParams if SPTxtPar <>
// '' )
//
//     Parameters
//
procedure TN_UDCompBase.SetParamsProc( APSetParam: TN_POneSetParam;
     APSrcField, APDstField: Pointer; ASrcFTCode, ADstFTCode: TK_ExprExtType );
var
  Str, FuncName, FmtStr: string;
begin
  with APSetParam^ do
  begin
    Str := SPTxtPar;
    FuncName := UpperCase( N_ScanToken( Str ) );

    if FuncName = 'CONVINT' then // Conv Int value to string by given format
    begin
      if ASrcFTCode.DTCode <> ord(nptInt) then
      begin
        N_AddToProtocol( 'ASrcFTCode is not nptInt' );
        Exit;
      end;

      if ADstFTCode.DTCode <> ord(nptString) then
      begin
        N_AddToProtocol( 'ADstFTCode is not nptString' );
        Exit;
      end;

      FmtStr := N_ScanToken( Str );

      PString(APDstField)^ := Format( FmtStr, [PInteger(APSrcField)^] );
      Exit;
    end; // if FuncName = 'CONVINT' then // Conv Int value to string by given format

  end; // with APSetParam^ do
end; // end_of procedure TN_UDCompBase.SetParamsProc

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetNextChild
//********************************************** TN_UDCompBase.GetNextChild ***
// Get next Child Component
//
//     Parameters
// Result - Returns next Child Component or nil if no more Components.
//
function TN_UDCompBase.GetNextChild(): TN_UDCompBase;
var
  NextChild: TN_UDBase;
begin
  Result := nil;
  while True do
  begin
    Inc(CurChildInd);
    if CurChildInd > DirHigh() then Exit; // no more children
    NextChild := DirChild( CurChildInd );
    if NextChild = nil then Continue; // a precaution
    if (N_CompBaseBit and NextChild.ClassFlags) = 0 then Continue; // Not a Component

    Result := TN_UDCompBase(NextChild);
    Exit;
  end;
end; // end_of function TN_UDCompBase.GetNextChild

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetPrevChild
//********************************************** TN_UDCompBase.GetPrevChild ***
// Get previous Child Component
//
//     Parameters
// Result - Returns previous Child Component or nil if no more Components.
//
function TN_UDCompBase.GetPrevChild(): TN_UDCompBase;
var
  PrevChild: TN_UDBase;
begin
  Result := nil;
  while True do
  begin
    Dec(CurChildInd);
    if CurChildInd < 0 then Exit; // no more children
    PrevChild := DirChild( CurChildInd );
    if PrevChild = nil then Continue; // a precaution
    if (PrevChild.ClassFlags and N_CompBaseBit) = 0 then Continue; // Not a Component

    Result := TN_UDCompBase(PrevChild);
    Exit;
  end;
end; // end_of function TN_UDCompBase.GetPrevChild

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetPExpParams
//********************************************* TN_UDCompBase.GetPExpParams ***
// Get pointer to needed Export Parameters
//
//     Parameters
// APExpParams - Export Parameters source pointer
// Result      - Returns pointer to needed Export Parameters:
//#L
//     - given pointer APExpParams if not nil, to
//     - pointer to component Self individual Dynamic Export Parameters
//     - //     (CCompBase.CBExpParams) if given,  or - pointer to global
//     - //     default Export Parameters (@N_DefExpParams)
//#/L
//
// In previous routine version Component Static Export Parameters are used 
// instead of Dynamic
//
function TN_UDCompBase.GetPExpParams( APExpParams: TN_PExpParams ): TN_PExpParams;
var
  WrkRArray: TK_RArray;
begin
  Result := APExpParams;
  if Result <> nil then Exit;

  WrkRArray := PDP()^.CCompBase.CBExpParams;
  if WrkRArray <> nil then
  begin
    Result := TN_PExpParams(WrkRArray.P());
    Exit;
  end;

  Result := @N_DefExpParams;
end; // end of function TN_UDCompBase.GetPExpParams

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetExpFlags
//*********************************************** TN_UDCompBase.GetExpFlags ***
// Get component Export Flags
//
//     Parameters
// APExpParams - Export Parameters source pointer
// Result      - Returns Self Export Flags
//
// Is used mainly in:
//#F
// 1) user interface, while checking if Root Component can be executed and what
//    kind of viewer can be used;
// 2) in Global Execution Context PrepForExport and FinishExport methods
//#/F
//
function TN_UDCompBase.GetExpFlags( APExpParams: TN_PExpParams ): TN_CompExpFlags;
var
  FName: string;
  PExpParams: TN_PExpParams;
  FileFlags: TN_FileExtFlags;
begin
//  N_s := ObjName; // debug
  Result := [cefExec];
  PExpParams := GetPExpParams( APExpParams );

  with PExpParams^ do
  begin

  if CI() = N_UDExpCompCI then Exit; // temporary

  if (PExpParams = @N_DefExpParams) and     // Component has no Export Params,
      not (csfForceExec in CStatFlags) then // it cannot be executed
    Result := Result - [cefExec];

  FileFlags := N_GetFileFlagsByExt( EPMainFName );

  //***** add [cefTextFile] flag if needed

  if (fefText in FileFlags) or // export to Text, GCOutSL and related fields are used
     (EPImageExpMode = iemSVG) or (EPImageExpMode = iemHTMLVML) or (EPImageExpMode = iemHTMLMap) then
    Result := Result + [cefTextFile];

  if csfCoords in CStatFlags then // Visual Component, it uses coords and can be rendered by GDI
  begin
    Result := Result + [cefCoords];

    //***** add [cefGDIFile] flag if needed (it is used in checking View menu items visibility)
    if     (fefGDIPict in FileFlags)  and      // FileName with extension is given and
       not (EPImageExpMode = iemJustDraw) then // not just draw to DstOCanv
    begin // DstOCanv content (raster or emf) should be saved to file to Clipboard or to Printer
      FName := UpperCase( ExtractFileName( EPMainFName ) );
      if (FName <> 'CLIPBOARD') and (FName <> 'PRINTER') then
        Result := Result + [cefGDIFile]; // cefGDIFile
    end; // check if [cefGDIFile] flag should be set

    if not ( (EPImageExpMode = iemSVG) or
             (EPImageExpMode = iemHTMLVML) or
             (EPImageExpMode = iemHTMLMap) ) then
    Result := Result + [cefGDI]; // should be rendered by GDI (drawn to raster or emf OCanv)

  end; // if csfCoords in CStatFlags then // Visual Component, it can be rendered by GDI

  //**** set cefWordDoc and cefExcelDoc flags by Self type

  if CI() = N_UDWordFragmCI then //*********** Word Document
    Result := Result + [cefWordDoc]
  else if CI() = N_UDExcelFragmCI then //***** Excel Document
    Result := Result + [cefExcelDoc];

  end; // with PExpParams^ do

end; // end of function TN_UDCompBase.GetExpFlags

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\ExpImageTag
//*********************************************** TN_UDCompBase.ExpImageTag ***
// Export Self to Image File and put corresponding HTML Tag to given Global 
// Execution Context resulting Strings
//
//     Parameters
// AImgAttr - Image Tag attributes
// ANGCont  - given Global Execution Context
//
procedure TN_UDCompBase.ExpImageTag( AImgAttr: string; ANGCont: TN_GlobCont );
//
// Export Image Tag (for VisualComponent in GCTextMode): export Self to
// ImageFile an add to TextBodySL <Img src=ImageFile ... > tag Export Params
// (FileName, ...) are taken from given ANGCont or from Self.NGCont if ANGCont =
// nil
//
var
  Str, NewFileName, NewFileExt, DirLastToken: string;
  CurGCont, NewGCont:  TN_GlobCont;
  NewExpPar: TN_ExpParams;
  PCompEP:   TN_PExpParams;
begin
  CurGCont := ANGCont;
  if CurGCont = nil then CurGCont := NGCont;
  Assert( CurGCont <> nil, 'GCont=nil!' );

  with CurGCont do
  begin
    //***** Prepare New Export Params (NewExpPar) with New FileName (NewExpPar.EPMainFName)

    DirLastToken := ChangeFileExt( ExtractFileName( GCMainFileName ), '' );

    NewExpPar := N_DefExpParams;

    PCompEP := GetPExpParams(); // pointer to Self ExpParams
    NewFileName := ExtractFileName( PCompEP^.EPMainFName );

    if NewFileName = '' then // Self has no EPMainFName, create it
    begin
      NewFileExt := GCExpParams.EPFilesExt;
      if NewFileExt = '' then NewFileExt := '.emf';
      NewFileName := 'Image_' + IntToStr(GCNewFilesInd) + NewFileExt;
      Inc( GCNewFilesInd );
    end;

    GCNewFilesDir := GetNewFilesDir( True ); // create if not yet
    NewExpPar.EPMainFName := GCNewFilesDir + '\' + NewFileName;

    if not (crtfRootComp in CRTFlags) then
      NewExpPar.EPExecFlags := [epefInitByComp];

    //***** NewExpPar are OK, Export Self (Create New Image File)

    NewGCont := TN_GlobCont.Create();
    NewGCont.ExecuteRootComp( Self, [], GCShowResponse, GCOwnerForm, @NewExpPar );
    NewGCont.Free;

    //***** Image File was created, add <img> tag

    Str := '<img src=' + DirLastToken + '/' + NewFileName + ' ' + AImgAttr + '>';
    GCOutSL.Add( Str );
  end; // with CurGCont do
end; // end_of procedure TN_UDCompBase.ExpImageTag

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\ExecSubTree
//*********************************************** TN_UDCompBase.ExecSubTree ***
// Execute Component SubTree (by recursive self calls)
//
// Component SubTree execution (for both Visual and NonVisual Components) 
// consists of several steps:
//#L
// - Calculate Component Coordinates,
// - Execute Component Self.BeforeAction,
// - Execute Child Components by ExecSubTree(),
// - Execute Component Self.AfterAction.
//#/L
//
procedure TN_UDCompBase.ExecSubTree();
var
  NextChild: TN_UDCompBase;
  PCCompBase: TN_PCCompBase;
  PRComp: TN_PRCompVis;
  VisualSelf: TN_UDCompVis;
  SavedCurSrcPixSize, SavedCurDstPixSize: TPoint;
  SavedCurSrcmmSize: TFPoint;
  SavedXFORM: TXFORM;
  T1, T2, T3: TN_CPUTimer1;
  Label Fin;
begin
  T1 := nil; // to avoid warnings
  T2 := nil;
  T3 := nil;

  PRComp := TN_PRCompVis(PDP()); // acceptable for both Visual and NonVisual Components
  PCCompBase := @(PRComp^.CCompBase);

  if PCCompBase^.CBSkipSelf <> 0 then Exit; // Skip Self with all children

  if cbfTimeWhole in PCCompBase^.CBFlags2 then // Create Whole (Self and Children) Execution Timer if needed
  begin
    T1 := TN_CPUTimer1.Create;
    T1.Start();
  end;

  N_s := ObjName; // debug
//  if N_s = 'MapRoot' then // debug
//    N_i := 1;

{ // temporary not implemented
  //***** Check if Self should be exported as <img> tag

  if NGCont.GCTextMode and
     ( (cbfStandAlone in PCCompBase^.CBFlags1) and (DynParent <> nil) or
       ((csfCoords in CStatFlags) and not (csfNonCoords in CStatFlags)) ) then
  begin
    ExpImageTag( PCCompBase^.CBTextAttr );
    Exit;
  end;
}

  VisualSelf := TN_UDCompVis(Self); // to reduce source code
  DebAction( 1 ); // for debug

  with NGCont do // Check if execution in New GCont is needed and if StopExecFlag is set
  begin
    if (cbfNewExpPar in PCCompBase^.CBFlags1) and not (crtfRootComp in CRTFlags) then
    begin
      ExecInNewGCont( [cifSeparateGCont], GCShowResponseProc, GCOwnerForm, nil );
      Exit;
    end; // if (cbfNewExpPar in PCCompBase^.CBFlags1) and not (crtfRootComp in CRTFlags) then

    if StopExecFlag then Exit;
    StopExecFlag := PCCompBase^.CBStopExec <> 0;
    if StopExecFlag then Exit;
  end; // with NGCont do // Check if execution in New GCont is needed and if StopExecFlag is set

  ExpandAllMacros();


  ExecSetParams( sppBBAction ); // call always, even if CBSkipSelf flag is set
  if PCCompBase^.CBSkipSelf <> 0 then Exit; // Skip Self with all children

  if NGCont.GCCoordsMode then with VisualSelf do // Calculate Coords for Visual Components
  with NGCont.DstOCanv, SavedOCanvFields do
  begin
    N_b := Windows.GetWorldTransform( HMDC, SavedXFORM ); // save current XFORM
    SetOuterPixCoords();
    SavedPClipRect := ConPClipRect; // always save current PClipRect

    if cbfVariableSize in PCCompBase^.CBFlags1 then // CPanel would be Drawn in BeforeAction method
    begin
      // CompIntPixRect would be calculated and PClipRect set in BeforeAction method
      CompIntPixRect := CompOuterPixRect;
    end else // Draw Self.Panel, set CompIntPixRect and PClipRect
    begin
      CompIntPixRect := NGCont.DrawCPanel( PRComp^.CPanel, CompOuterPixRect );

      //***** Set PClipRect if needed (later change flag to cbfClippingIsNeeded)

      if cbfDoClipping in PDP()^.CCompBase.CBFlags1 then // set new PClipRect
        SetNewPClipRect( CompIntPixRect );
    end; // with NGCont.DstOCanv, SavedOCanvFields do, else // Draw Self.Panel (and calculate CompIntPixRect)

    //***** Save UCoords Related fields
    SavedU2P  := U2P;
    SavedP2U  := P2U;
    SavedU2P6 := U2P6;
    SavedP2U6 := P2U6;
    SavedMaxUClipRect := MaxUClipRect;
    SavedMinUClipRect := MinUClipRect;
    SavedUserAspect   := OCUserAspect;
    SavedUseAffCoefs6 := UseAffCoefs6;

    SetCompUCoords();

    SetLength( CurFreeRects, 1 );
    CurFreeRects[0] := CompIntPixRect; // initialize CurFreeRects used for Layout

    if cbfSelfSizeUnits in PCCompBase^.CBFlags1 then // set new values to GCCurSrcmmSize, GCCurSrcPixSize
    with NGCont do
    begin
      SavedCurSrcmmSize  := GCCurSrcmmSize; // save current values
      SavedCurSrcPixSize := GCCurSrcPixSize;
      SavedCurDstPixSize := GCCurDstPixSize;

      GetSize( @GCCurSrcmmSize, @GCCurSrcPixSize ); // set new values
      GCCurDstPixSize := N_RectSize( CompIntPixRect );
      SetSizeUnitsCoefs();
    end; // with NGCont do, if cbfSelfSizeUnits in PCCompBase^.CBFlags1 then

  end; // with NGCont.DstOCanv, SavedOCanvFields do, if NGCont.GCCoordsMode then with VisualSelf do // Calculate Coords for Visual Components

  if cbfTimeBefore in PCCompBase^.CBFlags2 then // Create BeforeAction execution Timer if needed
  begin
    T2 := TN_CPUTimer1.Create;
    T2.Start();
  end;

  BeforeAction(); // execute Self.BeforeAction (different for each component type)

  if T2 <> nil then // Show BeforeAction execution Time
    T2.SS( ObjName + ' Before' );

  ExecSetParams( sppABAction );

  if NGCont.GCCoordsMode then with VisualSelf do
    UpdateCurFreeRect( [cffAABefore] );

  if CI() = N_UDIteratorCI then goto Fin; // skip executing Iterator children

  if cbfTimeChildren in PCCompBase^.CBFlags2 then // Create all Children execution Timer
  begin
    if T2 = nil then T2 := TN_CPUTimer1.Create;
    T2.Start();
  end;

  if cbfTimeEachChild in PCCompBase^.CBFlags2 then // Create each Child execution Timer
  begin
    T3 := TN_CPUTimer1.Create;
    T3.Start();
  end;


  Self.CurChildInd := -1;
  while True do //********************** loop along all Children
  begin
    NextChild := GetNextChild();
    if NextChild = nil then Break; // no more children
    NextChild.DynParent := Self;
    NextChild.NGCont := Self.NGCont;
    NextChild.ExecSubTree();

    if T3 <> nil then // Show each Child execution Time
    begin
      T3.SS( ObjName + '.' + NextChild.ObjName + ' Child' );
      T3.Start();
    end; // if T3 <> nil then

    if NGCont.StopExecFlag then Exit;
  end; // while True do // loop along all Children


  if cbfTimeChildren in PCCompBase^.CBFlags2 then // Show all Children execution Time
    T2.SS( ObjName + ' Children' );

  if NGCont.GCCoordsMode then with VisualSelf do
    DebView();

  if csfExecAfter in CStatFlags then // Component AfterAction exists and should be executed
  begin

    ExecSetParams( sppBAAction );

    if NGCont.GCCoordsMode then with VisualSelf do
    begin
      UpdateCurFreeRect( [cffABAfter] );
      SetSizeUnitsCoefs(); // SizeUnitsCoefs were changed by last child
    end;

    if cbfTimeAfter in PCCompBase^.CBFlags2 then // Create (if needed) AfterAction execution Timer
    begin
      if T2 = nil then T2 := TN_CPUTimer1.Create;
      T2.Start();
    end;

    AfterAction(); // execute Self.BeforeAction (different for each component type)

    if cbfTimeAfter in PCCompBase^.CBFlags2 then // Show AfterAction execution Time
      T2.SS( ObjName + ' After' );

    if NGCont.GCCoordsMode then with VisualSelf do
      UpdateCurFreeRect( [cffAAAfter] );

    ExecSetParams( sppAAAction );

  end; // if (CStatFlags and N_CompExecAfter) <> 0 then // Component AfterAction exists and should be executed

  Fin: //***************** finish executing Subtree

  if NGCont.GCCoordsMode then with VisualSelf do
  begin
    //***** Restore UCoords Related fields
    with NGCont.DstOcanv, SavedOCanvFields do
    begin
      U2P := SavedU2P;
      P2U := SavedP2U;
      U2P6 := SavedU2P6;
      P2U6 := SavedP2U6;
      MaxUClipRect := SavedMaxUClipRect;
      MinUClipRect := SavedMinUClipRect;
      OCUserAspect := SavedUserAspect;
      UseAffCoefs6 := SavedUseAffCoefs6;

{
      //***** Restore P2PWin if needed
      if P2PWinChanged then // P2PWin was changed and need to be restored
      begin
        if SavedUseP2PWin then // restore saved P2PWin in HMDC
        begin
          P2PWin := SavedP2PWin;
          Windows.SetWorldTransform( HMDC, P2PWin );
        end else //************** clear P2PWin in HMDC
        begin
          Windows.ModifyWorldTransform( HMDC, N_XForm, MWT_IDENTITY );
          UseP2PWin := False;
          P2PWin := N_ConvToXForm( N_DefAffCoefs6 ); // a precaution
        end;
      end; // if P2PWinChanged then // P2PWin was changed and need to be restored
}

    if PCCD()^.PixTransfType <> ctfNoTransform then // Transformation was changed and should be restored
      Windows.SetWorldTransform( HMDC, SavedXFORM );


      //***** Restore PClipRect if needed
      if ClipRectChanged then // restore PClipRect (it was saved in SetOuterPixCoords method)
        SetPClipRect( SavedPClipRect );


      //***** Restore GCCurSrcmmSize, GCCurSrcPixSize if needed
      if cbfSelfSizeUnits in PCCompBase^.CBFlags1 then // restoring is needed
      with NGCont do
      begin
        GCCurSrcPixSize := SavedCurSrcPixSize;
        GCCurSrcmmSize  := SavedCurSrcmmSize;
        GCCurDstPixSize := SavedCurDstPixSize;
      end;

    end; // with NGCont.DstOcanv, SavedOCanvFields do

  end; // if NGCont.GCCoordsMode then with VisualSelf do

  if T2 <> nil then T2.Free;
  if T3 <> nil then T3.Free;

  if T1 <> nil then // Show whole (Self and Children) execution time
  begin
    T1.SS( ObjName + ' Whole' );
    
    T1.Free;
  end;

end; // end_of procedure TN_UDCompBase.ExecSubTree();

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\InitSubTree
//*********************************************** TN_UDCompBase.InitSubTree ***
// Initialize Component SubTree
//
//     Parameters
// AInitFlags - Component SubTree Intialization flags set
//
procedure TN_UDCompBase.InitSubTree( AInitFlags: TN_CompInitFlags );
var
  NextChild: TN_UDCompBase;
begin
  if not (crtfRootComp in CRTFlags) then // Root Comp should be already initialised
  begin
    K_RFreeAndCopy( DynPar, R, [K_mdfCopyRArray] ); // create Dyn Params
    InitRunTimeFields( AInitFlags );
  end; // if not (crtfRootComp in CRTFlags) then // Root Comp should be already initialised

  
  if CI() = N_UDIteratorCI then // skip Initializing Iterator children,
  begin                         // just set CIInitFlags
    TN_UDIterator(Self).CIInitFlags := AInitFlags;
    Exit;
  end;

  CurChildInd := -1;
  while True do // loop along all Children
  begin
    NextChild := GetNextChild();
    if NextChild = nil then Break;
    NextChild.InitSubTree( AInitFlags );
  end;

end; // end_of procedure TN_UDCompBase.InitSubTree

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\FinSubTree
//************************************************ TN_UDCompBase.FinSubTree ***
// Finalize Component SubTree after execution
//
// Clear Child IDB Objects in Self TmpData and so on.
//
procedure TN_UDCompBase.FinSubTree();
var
  NextChild: TN_UDCompBase;
  TmpUObj: TN_UDBase;
begin
//  TmpUObj := N_GetUObj( Self, 'TmpData' );
  TmpUObj := DirChildByObjName( 'TmpData' );
  if TmpUObj <> nil then TmpUObj.ClearChilds();

  if CI() <> N_UDIteratorCI then // Finalize all components children except Iterator
  begin
    CurChildInd := -1;
    while True do // loop along all Children
    begin
      NextChild := GetNextChild();
      if NextChild = nil then Break;
      NextChild.FinSubTree();
    end;
  end;

  if crtfRootComp in CRTFlags then // Root Component
    NGCont.StopExecFlag := False; // clear flag

  CRTFlags  := [];  // Clear RunTime Flags
  DynParent := nil; // Clear DynParent
end; // end_of procedure TN_UDCompBase.FinSubTree

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\ExecInNewGCont
//******************************************** TN_UDCompBase.ExecInNewGCont ***
// Execute Component in new Global Execution Context
//
//     Parameters
// AInitFlags    - Component SubTree Intialization flags set before execution in
//                 new context
// AShowResponse - show response routine
// AOwner        - owner form (neede for execution of some nonvisual conponents)
// APExpParams   - pointer to needed Export Parameters
//
// New Global Execution Context should be prepared by Self.NGCont
//
procedure TN_UDCompBase.ExecInNewGCont( AInitFlags: TN_CompInitFlags;
                                        AShowResponse: TN_OneStrProcObj;
                                        AOwner: TN_BaseForm;
                                        APExpParams: TN_PExpParams );
var
  NumShapes: integer;
  UseClipboard: boolean;
  SavedGCont, NewNGCont: TN_GlobCont;
  TmpRange: variant;
begin
  SavedGCont := NGCont;

  if (cifSeparateGCont in AInitFlags) or (NGCont = nil) then
    NewNGCont := TN_GlobCont.Create()
  else
    NewNGCont := TN_GlobCont.CreateByGCont( NGCont );

  NewNGCont.ExecuteRootComp( Self, AInitFlags, AShowResponse, AOwner, APExpParams );

  UseClipboard := N_UseClipboard( NewNGCont.GCMainFileName ) or
                  (NewNGCont.GCExpParams.EPImageExpMode = iemToClb);

  if UseClipboard then // Export to Clipboard
  begin
    if mewfUseVBA in SavedGCont.GCWSVBAFlags then      // add Image in Clipboard to
      SavedGCont.RunWordMacro( 'N_AddClipboardToMainDoc' ) // GCWSMainDoc using VBA
    else // add Image in Clipboard to GCWSMainDoc without using VBA
    begin
      if SavedGCont.GCWSMajorVersion = 8 then // Word 97
      begin
        SavedGCont.GCWSMainDoc.ActiveWindow.View.Type := wdPageView;

        TmpRange := SavedGCont.GCWSMainDoc.Content;
        TmpRange.InsertParagraphAfter;
        TmpRange.Collapse( wdCollapseEnd );
        TmpRange.Select;
//                             DataType:=wdPasteMetafilePicture,
//                             DataType:=wdPasteEnhancedMetafile,

        SavedGCont.GCWordServer.Selection.PasteSpecial( Link:=False,
                             DataType:=wdPasteMetafilePicture,
                             Placement:=wdFloatOverText, DisplayAsIcon:=False );
        NumShapes := SavedGCont.GCWSMainDoc.Shapes.Count;

        if NumShapes > 0 then
          SavedGCont.GCWSMainDoc.Shapes.Item(NumShapes).ConvertToInlineShape;
      end else //******************************* Word 2000 or higher
      begin
        TmpRange := SavedGCont.GCWSMainDoc.Content;
        TmpRange.Collapse( wdCollapseEnd );
        TmpRange.PasteSpecial( Placement:=wdInLine );
      end; // else // Word 2000 or higher
    end; // else // add Image in Clipboard to GCWSMainDoc without using VBA

//    SavedGCont.GCWSMainDoc.Activate;
//    Range := SavedGCont.GCWordServer.ActiveDocument.Content;
//    Range := SavedGCont.GCWSMainDoc.Content;
//    Range.Collapse( wdCollapseEnd );
//    Range.PasteSpecial;
  end; // if N_UseClipboard( NewNGCont.GCMainFileName ) then // Export to Clipboard

  if (not (cifSeparateGCont in AInitFlags)) and (SavedGCont <> nil) then
    SavedGCont.GCUpdateSelf( NewNGCont );

  NewNGCont.Free;
  NGCont := SavedGCont; // restore
end; // end_of procedure TN_UDCompBase.ExecInNewGCont


  //*********************************** User Params Related methods

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetDUserParRArray(2)
//************************************** TN_UDCompBase.GetDUserParRArray(2) ***
// Get Component Dynamic User Parameter Value Records Array Object
//
//     Parameters
// AUPName - User Parameter Name
// Result  - Returns Dynamic User Parameter Value Records Array Object
//
// If corresponding User Parameter is absent then resulting value is NIL.
//
function TN_UDCompBase.GetDUserParRArray( AUPName: string ): TK_RArray;
var
  CompRArray: TK_RArray;
  PUPPar: TN_POneUserParam;
begin
  Result := nil;

  CompRArray := DynPar;
//  if CompRArray = nil then CompRArray := R;
  Assert( CompRArray <> nil, 'No DynParams!');

  PUPPar := N_GetUserParPtr( CompRArray, AUPName );
  if PUPPar = nil then Exit; // not found

  Result := PUPPar^.UPValue;
end; // end_of function TN_UDCompBase.GetDUserParRArray

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetDUserParRArray(1)
//************************************** TN_UDCompBase.GetDUserParRArray(1) ***
// Get Component Dynamic User Parameter Value Records Array Object controled by 
// Type
//
//     Parameters
// AUPName     - User Parameter Name
// AUPTypeCode - User Parameter Value Records Array Elements Type Code
// Result      - Returns Dynamic User Parameter Value Records Array Object
//
// If corresponding User Parameter is absent or it type is not equal to 
// AElemType then resulting value is NIL.
//
function TN_UDCompBase.GetDUserParRArray( AUPName: string; AUPTypeCode: integer ): TK_RArray;
begin
  Result := GetDUserParRArray( AUPName );

  if Result <> nil then
    if Result.ElemType.DTCode <> AUPTypeCode then Result := nil;

end; // end_of function TN_UDCompBase.GetDUserParRArray

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetSUserParRArray
//***************************************** TN_UDCompBase.GetSUserParRArray ***
// Get Component Static User Parameter Value Records Array Object
//
//     Parameters
// AUPName - User Parameter Name
// Result  - Returns User Parameter Value Records Array Object
//
// If corresponding User Parameter is absent then resulting value is NIL.
//
function TN_UDCompBase.GetSUserParRArray( AUPName: string ): TK_RArray;
var
  PUPPar: TN_POneUserParam;
begin
  Result := nil;

  PUPPar := N_GetUserParPtr( R, AUPName );
  if PUPPar = nil then Exit; // not found

  Result := PUPPar^.UPValue;
end; // end_of function TN_UDCompBase.GetSUserParRArray

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\CGetDUserParPtr
//******************************************* TN_UDCompBase.CGetDUserParPtr ***
// Create new or get existing Component Dynamic User Parameter Data Structure
//
//     Parameters
// AUPName     - User Parameter Name
// AUPDescr    - User Parameter description
// AUPTypeCode - User Parameter Value Records Array Elements Type Code
// ANumElems   - number of Elements in User Parameter Value Records Array
// Result      - Returns pointer to Dynamic User Parameter Data Structure
//
// If Component Dynamic Parameters are absent then Static parameters are used.
//
function TN_UDCompBase.CGetDUserParPtr( AUPName, AUPDescr: string;
           AUPTypeCode: TK_ExprExtType; ANumElems: integer ): TN_POneUserParam;
var
  CompRArray: TK_RArray;
begin
  CompRArray := DynPar;
  if CompRArray = nil then CompRArray := R;

  Result := N_CGetUserParPtr( CompRArray, AUPName, AUPDescr,
                                                      AUPTypeCode, ANumElems );
end; // end_of function TN_UDCompBase.CGetDUserParPtr

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\CGetSUserParPtr
//******************************************* TN_UDCompBase.CGetSUserParPtr ***
// Create new or get existing Component Static User Parameter Data Structure
//
//     Parameters
// AUPName     - User Parameter Name
// AUPDescr    - User Parameter description
// AUPTypeCode - User Parameter Value Records Array Elements Type Code
// ANumElems   - number of Elements in User Parameter Value Records Array
// Result      - Returns pointer to Static User Parameter Data Structure
//
function TN_UDCompBase.CGetSUserParPtr( AUPName, AUPDescr: string;
           AUPTypeCode: TK_ExprExtType; ANumElems: integer ): TN_POneUserParam;
begin
  Result := N_CGetUserParPtr( R, AUPName, AUPDescr, AUPTypeCode, ANumElems );
end; // end_of function TN_UDCompBase.CGetSUserParPtr

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetDUserParBool
//******************************************* TN_UDCompBase.GetDUserParBool ***
// Get Component Dynamic User Parameter Boolean Value
//
//     Parameters
// AUPName - User Parameter Name
// Result  - Returns TRUE if User Parameter exists, it's Type is Byte or Integer
//           (number of appropriate "Integer" Types may be extpanded) and it's 
//           Value is not equal to zero, otherwise FALSE should be returned.
//
function TN_UDCompBase.GetDUserParBool( AUPName: string ): Boolean;
var
  CompRArray: TK_RArray;
begin
  CompRArray := DynPar;
  if CompRArray = nil then CompRArray := R;

  Result := N_GetUserParBoolValue( CompRArray, AUPName );
end; // end_of function TN_UDCompBase.GetDUserParBool

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetDUserParInt
//******************************************** TN_UDCompBase.GetDUserParInt ***
// Get Component Dynamic User Parameter Integer Value
//
//     Parameters
// AUPName - User Parameter Name
// Result  - Returns User Parameter Integer Value if User Parameter exists and 
//           it's Type is Integer otherwise N_NotAnInteger should be returned.
//
function TN_UDCompBase.GetDUserParInt( AUPName: string ): integer;
var
  UPRArray: TK_RArray;
begin
  Result := N_NotAnInteger;

  UPRArray := GetDUserParRArray( AUPName );
  if UPRArray = nil then Exit;
  if UPRArray.ALength() < 1 then Exit;
  if UPRArray.ElemSType <> ord(nptInt) then Exit;

  Result := PInteger(UPRArray.P())^;
end; // end_of function TN_UDCompBase.GetDUserParInt

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetDUserParDbl
//******************************************** TN_UDCompBase.GetDUserParDbl ***
// Get Component Dynamic User Parameter Double Value
//
//     Parameters
// AUPName - User Parameter Name
// Result  - Returns User Parameter Double Value if User Parameter exists and 
//           it's Type is Integer otherwise N_NotADouble should be returned.
//
function TN_UDCompBase.GetDUserParDbl( AUPName: string ): double;
var
  UPRArray: TK_RArray;
begin
  Result := N_NotADouble;

  UPRArray := GetDUserParRArray( AUPName );
  if UPRArray = nil then Exit;
  if UPRArray.ALength() < 1 then Exit;

  if UPRArray.ElemSType = ord(nptDouble) then
    Result := PDouble(UPRArray.P())^
  else if UPRArray.ElemSType = ord(nptFloat) then
    Result := PFloat(UPRArray.P())^
  else if UPRArray.ElemSType = ord(nptInt) then
    Result := PInteger(UPRArray.P())^;

end; // end_of function TN_UDCompBase.GetDUserParDbl

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetDUserParStr
//******************************************** TN_UDCompBase.GetDUserParStr ***
// Get Component Dynamic User Parameter String Value
//
//     Parameters
// AUPName - User Parameter Name
// Result  - Returns User Parameter String Value if User Parameter exists and 
//           it's Type is String otherwise N_NotAString should be returned.
//
function TN_UDCompBase.GetDUserParStr( AUPName: string ): string;
var
  UPRArray: TK_RArray;
begin
  Result := N_NotAString;

  UPRArray := GetDUserParRArray( AUPName );
  if UPRArray = nil then Exit;
  if UPRArray.ALength() < 1 then Exit;
  if UPRArray.ElemSType <> ord(nptString) then Exit;

  Result := PString(UPRArray.P())^;
end; // end_of function TN_UDCompBase.GetDUserParStr

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetDUserParUDBase
//***************************************** TN_UDCompBase.GetDUserParUDBase ***
// Get Component Dynamic User Parameter IDB Object Reference Value
//
//     Parameters
// AUPName - User Parameter Name
// Result  - Returns User Parameter IDB Object Reference Value if User Parameter
//           exists and it's Type is TN_UDBase otherwise NIL should be returned.
//
function TN_UDCompBase.GetDUserParUDBase( AUPName: string ): TN_UDBase;
var
  UPRArray: TK_RArray;
begin
  Result := nil;

  UPRArray := GetDUserParRArray( AUPName );
  if UPRArray = nil then Exit;
  if UPRArray.ALength() < 1 then Exit;
  if UPRArray.ElemSType <> ord(nptUDRef) then Exit;

  Result := TN_PUDBase(UPRArray.P())^;
end; // end_of function TN_UDCompBase.GetDUserParUDBase

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\SetDUserParUDBase
//***************************************** TN_UDCompBase.SetDUserParUDBase ***
// Set Component Dynamic User Parameter IDB Object Reference Value
//
//     Parameters
// AUPName - User Parameter Name
// AUDBase - new IDB Object Reference Value to set
//
// Do nothing if no User Parameter with given Name and TN_UDBase Type was found.
//
procedure TN_UDCompBase.SetDUserParUDBase( AUPName: string; AUDBase: TN_UDBase );
var
  UPRArray: TK_RArray;
begin
  UPRArray := GetDUserParRArray( AUPName );
  if UPRArray = nil then Exit;
  if UPRArray.ALength() < 1 then Exit;
  if UPRArray.ElemSType <> ord(nptUDRef) then Exit;

  TN_PUDBase(UPRArray.P())^ := AUDBase;
end; // end_of procedure TN_UDCompBase.SetDUserParUDBase

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\SetSUserParInt
//******************************************** TN_UDCompBase.SetSUserParInt ***
// Set Component Static User Parameter Integer Value
//
//     Parameters
// AUPName - User Parameter Name
// AInt    - new Integer Value to set
//
// Do nothing if no User Parameter with given Name and Integer, Hex, Color or 
// TN_Boolean4 Type was found.
//
procedure TN_UDCompBase.SetSUserParInt( AUPName: string; AInt: integer );
var
  UPRArray: TK_RArray;
begin
  UPRArray := GetSUserParRArray( AUPName );

  if UPRArray = nil then Exit;
  if UPRArray.ALength() < 1 then Exit;
  if (UPRArray.ElemSType <> ord(nptInt))   or
     (UPRArray.ElemSType <> ord(nptHex))   or
     (UPRArray.ElemSType <> ord(nptColor)) or
     (UPRArray.ElemSType <> N_SPLTC_Boolean4) then Exit;

  PInteger(UPRArray.P())^ := AInt;
end; // end_of procedure TN_UDCompBase.SetSUserParInt

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\SetSUserParDbl
//******************************************** TN_UDCompBase.SetSUserParDbl ***
// Set Component Static User Parameter Double Value
//
//     Parameters
// AUPName - User Parameter Name
// ADbl    - new Double Value to set
//
// Do nothing if no User Parameter with given Name and Double Type was found.
//
procedure TN_UDCompBase.SetSUserParDbl( AUPName: string; ADbl: double );
var
  UPRArray: TK_RArray;
begin
  UPRArray := GetSUserParRArray( AUPName );

  if UPRArray = nil then Exit;
  if UPRArray.ALength() < 1 then Exit;
  if UPRArray.ElemSType <> ord(nptDouble) then Exit;

  PDouble(UPRArray.P())^ := ADbl;
end; // end_of procedure TN_UDCompBase.SetSUserParDbl

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\SetSUserParStr
//******************************************** TN_UDCompBase.SetSUserParStr ***
// Set Component Static User Parameter String Value
//
//     Parameters
// AUPName - User Parameter Name
// AStr    - new String Value to set
//
// Do nothing if no User Parameter with given Name and String Type was found.
//
procedure TN_UDCompBase.SetSUserParStr( AUPName: string; AStr: string );
var
  UPRArray: TK_RArray;
begin
  UPRArray := GetSUserParRArray( AUPName );

  if UPRArray = nil then Exit;
  if UPRArray.ALength() < 1 then Exit;
  if UPRArray.ElemSType <> ord(nptString) then Exit;

  PString(UPRArray.P())^ := AStr;
end; // end_of procedure TN_UDCompBase.SetSUserParStr

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\SetSUserParUDBase
//***************************************** TN_UDCompBase.SetSUserParUDBase ***
// Set Component Static User Parameter IDB Object Reference Value
//
//     Parameters
// AUPName - User Parameter Name
// AUDBase - new IDB Object Reference Value to set
//
// Do nothing if no User Parameter with given Name and TN_UDBase Type was found.
//
procedure TN_UDCompBase.SetSUserParUDBase( AUPName: string; AUDBase: TN_UDBase );
var
  UPRArray: TK_RArray;
begin
  UPRArray := GetSUserParRArray( AUPName );

  if UPRArray = nil then Exit;
  if UPRArray.ALength() < 1 then Exit;
  if UPRArray.ElemSType <> ord(nptUDRef) then Exit;

  K_SetUDRefField( TN_PUDBase(UPRArray.P())^, AUDBase, true );
end; // end_of procedure TN_UDCompBase.SetSUserParUDBase

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\CSetSUserParInt
//******************************************* TN_UDCompBase.CSetSUserParInt ***
// Create if needed and set Component Static User Parameter Integer Value
//
//     Parameters
// AUPName  - User Parameter Name
// AUPDescr - User Parameter Description
// AInt     - new Integer Value to set
//
procedure TN_UDCompBase.CSetSUserParInt( AUPName, AUPDescr: string; AInt: integer );
var
  TypeCode: TK_ExprExtType;
begin
  TypeCode.All := Ord(nptInt);
  PInteger(CGetSUserParPtr( AUPName, AUPDescr, TypeCode, 1 )^.UPValue.P())^ := AInt;
end; // end_of procedure TN_UDCompBase.CSetSUserParInt

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\CSetSUserParBool4
//***************************************** TN_UDCompBase.CSetSUserParBool4 ***
// Create if needed and set Component Static User Parameter TN_Boolean4 Value
//
//     Parameters
// AUPName  - User Parameter Name
// AUPDescr - User Parameter Description
// AInt     - new Value to set
//
// Existing User Parameter could be of any 4 byte Integer Type (Integer, Hex, 
// Color or TN_Boolean4). New User Parameter should be of TN_Boolean4 Type.
//
procedure TN_UDCompBase.CSetSUserParBool4( AUPName, AUPDescr: string; AInt: integer );
var
  TypeCode: TK_ExprExtType;
  PUParam: TN_POneUserParam;
begin
  PUParam := N_GetUserParPtr( R, AUPName );

  if PUParam <> nil then // check UserPar Element Type
    with PUParam^.UPValue do
      Assert( (ElemSType = ord(nptInt))   or
              (ElemSType = ord(nptHex))   or
              (ElemSType = ord(nptColor)) or
              (ElemSType = N_SPLTC_Boolean4), 'Bad UP Type!' )

  else // Result = nil, needed User Param was not created, create it
  begin
    TypeCode.All := N_SPLTC_Boolean4;
    PUParam := N_AddNewUserPar( R, AUPName, AUPDescr, TypeCode, 1 );
  end;

  PInteger(PUParam^.UPValue.P())^ := AInt;
end; // end_of procedure TN_UDCompBase.CSetSUserParBool4

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\CSetSUserParDbl
//******************************************* TN_UDCompBase.CSetSUserParDbl ***
// Create if needed and set Component Static User Parameter Double Value
//
//     Parameters
// AUPName  - User Parameter Name
// AUPDescr - User Parameter Description
// ADbl     - new Double Value to set
//
procedure TN_UDCompBase.CSetSUserParDbl( AUPName, AUPDescr: string; ADbl: double );
var
  TypeCode: TK_ExprExtType;
begin
  TypeCode.All := Ord(nptDouble);
  PDouble(CGetSUserParPtr( AUPName, AUPDescr, TypeCode, 1 )^.UPValue.P())^ := ADbl;
end; // end_of procedure TN_UDCompBase.CSetSUserParDbl

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\CSetSUserParStr
//******************************************* TN_UDCompBase.CSetSUserParStr ***
// Create if needed and set Component Static User Parameter String Value
//
//     Parameters
// AUPName  - User Parameter Name
// AUPDescr - User Parameter Description
// AStr     - new String Value to set
//
procedure TN_UDCompBase.CSetSUserParStr( AUPName, AUPDescr: string; AStr: String );
var
  TypeCode: TK_ExprExtType;
begin
  TypeCode.All := Ord(nptString);
  PString(CGetSUserParPtr( AUPName, AUPDescr, TypeCode, 1 )^.UPValue.P())^ := AStr;
end; // end_of procedure TN_UDCompBase.CSetSUserParStr

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\CSetSUserParUDBase
//**************************************** TN_UDCompBase.CSetSUserParUDBase ***
// Create if needed and set Component Static User Parameter IDB Object Reference
// Value
//
//     Parameters
// AUPName  - User Parameter Name
// AUPDescr - User Parameter Description
// AUDBase  - new IDB Object Reference Value to set
//
procedure TN_UDCompBase.CSetSUserParUDBase( AUPName, AUPDescr: string; AUDBase: TN_UDBase );
var
  TypeCode: TK_ExprExtType;
begin
  TypeCode.All := Ord(nptUDRef);
  TN_PUDBase(CGetSUserParPtr( AUPName, AUPDescr, TypeCode, 1 )^.UPValue.P())^ := AUDBase;
end; // end_of procedure TN_UDCompBase.CSetSUserParUDBase



  //********** Methods used in GCont and descendant Before(After)Action methods

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetDataRoot
//*********************************************** TN_UDCompBase.GetDataRoot ***
// Get Component's Data Root IDB Object
//
//     Parameters
// ACreate - if =TRUE new Component's Data Root IDB Object should be created if 
//           not exist
// Result  - Returns existing Component's Data Root or create it if not yet and 
//           ACreate = True.
//
function TN_UDCompBase.GetDataRoot( ACreate: boolean ): TN_UDBase;
begin
  Result := DirChild( 0 );
  if Result <> nil then
    if Result.ObjName = 'RunTimeData' then Exit;

  if not ACreate then
  begin
    Result := nil;
    Exit;
  end;

  Result := TN_UDBase.Create;
  Result.ObjName := 'RunTimeData';
  Result.ClassFlags := Result.ClassFlags or K_SkipSelfSaveBit;
  InsOneChild( 0, Result );
end; // end_of function TN_UDCompBase.GetDataRoot

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\GetTmpDataRoot
//******************************************** TN_UDCompBase.GetTmpDataRoot ***
// Get Component's Temporary Data Root IDB Object
//
//     Parameters
// ACreate - if =TRUE new Component's Temporary Data Root IDB Object should be 
//           created if not exist
// Result  - Returns existing Component's Temporary Data Root or create it if 
//           not yet and ACreate = True.
//
function TN_UDCompBase.GetTmpDataRoot( ACreate: boolean ): TN_UDBase;
begin
  Result := DirChildByObjName( 'TmpData' );
//  Result := N_GetUObj( Self, 'TmpData' );

  if Result <> nil then
    if Result.ObjName = 'TmpData' then Exit;

  if not ACreate then
  begin
    Result := nil;
    Exit;
  end;

  Result := TN_UDBase.Create;
  Result.ObjName := 'TmpData';
  AddOneChild( Result );
end; // end_of function TN_UDCompBase.GetTmpDataRoot

//****************************************** TN_UDCompBase.DrawAllMapLayers ***
// Draw all UDMapLayer Components in given ARoot (may be nil)
//
procedure TN_UDCompBase.DrawAllMapLayers( ARoot: TN_UDBase );
var
  i: integer;
  AChild: TN_UDBase;
begin
  for i := 0 to ARoot.DirHigh() do // loop along all children
  begin
    AChild := ARoot.DirChild( i );
    if not (AChild is TN_UDMapLayer) then Continue; // skip not Map Layers

    with TN_UDMapLayer(AChild) do
    begin
      NGCont := Self.NGCont;
      K_RFreeAndCopy( DynPar, R, [K_mdfCopyRArray] );
      BeforeAction(); // draw MapLayer
    end;

  end; // for i := 0 to ARoot.DirHigh() do // loop along all children
end; // end_of procedure TN_UDCompBase.DrawAllMapLayers

  //*********************************** Obsolete methods *****************
  //*** (should be removed after removing theirs usage in obsolete code

//********************************************** TN_UDCompBase.ClearSelfRTI ***
// Clear Self Run Time Info
//
procedure TN_UDCompBase.ClearSelfRTI();
begin
  FreeAndNil( SPLUnit );
end; // end_of procedure TN_UDCompBase.ClearSelfRTI

//******************************************** TN_UDCompBase.AddMacrosToSPL ***
// Expand UP Macros in AStr(on input and output), Parse it for L1 macros,
// replacing them by SPL ProcNames and add appropriate procedures to
// N_MEGlobObj.MECompSPLText ( one procedure with given AProcPref for each L1
// macro ) ( processing of L1 Macros is done in AddOneMacroToSPL method )
//
// On output: in AStr expanded UP Macros, ANum is incremented by number of L1
// Macros
//
procedure TN_UDCompBase.AddMacrosToSPL( var AStr: string; var ANum: integer;
                                                              AProcPref: string );
var
  ResStrLeng: integer;
  ResStr: string;
begin
  if AStr = '' then Exit;

  ExpandUPMacros( AStr );

  with N_MEGlobObj do
  begin
    MacroProcNumber := ANum; // initial L1 Macros index
    MacroProcPrefix := AProcPref;

    MacroReplaceObj.SetParsingContext( '(#', '#)', AddOneMacroToSPL );
    MacroReplaceObj.MacroFlags := [];
    ResStrLeng := MacroReplaceObj.StringMacroReplace( ResStr, AStr );

    if ResStrLeng > 0 then
    begin
      SetLength( ResStr, ResStrLeng );
      AStr := ResStr;
    end;

    ANum := MacroProcNumber; // final L1 Macros index
  end; // with N_MEGlobObj do
end; // end_of procedure TN_UDCompBase.AddMacrosToSPL

//***************************************** TN_UDCompBase.ExpandMacrosBySPL ***
// Used only in obsolete UDTextBox Component
//
// Expand given ASrcStr with macros to Resulting string AResStr using SPL
// procedures (UDProgramItems) with AProcPref Prefix. If (AExpand = False) or
// (SPLUnit = nil) then Skip expanding
//
procedure TN_UDCompBase.ExpandMacrosBySPL( ASrcStr, AProcPref: string;
                                        var AResStr: string; AExpand: boolean );
var
  TmpResStr: string;
  ResStrSize: integer;
  PCCompBase: TN_PCCompBase;
begin
  with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
  begin
    MacroProcNumber := 1;
    MacroProcPrefix := AProcPref;

    MacroReplaceObj.SetParsingContext( '(#', '#)', ExpandOneMacroBySPL );
    MacroReplaceObj.MacroFlags := [];

    if (AExpand = False) or (SPLUnit = nil) then // Skip expanding
      TmpResStr := ASrcStr
    else
    begin //*********************************** Expand L1 macros (normal mode)
      ResStrSize := MacroReplaceObj.StringMacroReplace( TmpResStr, ASrcStr );
      if (ResStrSize = 0) and (ASrcStr <> '') then // no macros in ASrcStr
        TmpResStr := ASrcStr
      else
        SetLength( TmpResStr, ResStrSize );
    end;

    PCCompBase := @(PDP()^.CCompBase);
    if cbfL2Macros in PCCompBase^.CBFlags1 then // Expand Level 2 macros
    begin
      MacroReplaceObj.SetParsingContext( '(##', '##)', MacroReplaceObj.TextAssemblingMRFunc );
      MacroReplaceObj.MacroFlags := [];
      MacroReplaceObj.InitTextAssemblingContext(  );
      ResStrSize := MacroReplaceObj.StringMacroReplace( AResStr, TmpResStr );
      if (ResStrSize = 0) and (ASrcStr <> '') then // no macros in TmpResStr
        AResStr := TmpResStr
      else
        SetLength( AResStr, ResStrSize );
    end else //********************************** Skip Level 2 macros
      AResStr := TmpResStr;
  end; // with N_MEGlobObj, N_MEGlobObj.MECompSPLText do
end; // end_of procedure TN_UDCompBase.ExpandMacrosBySPL

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompBase\UDCompAddCurStateMain
//************************************* TN_UDCompBase.UDCompAddCurStateMain ***
// Add to given strings current state params
//
//     Parameters
// AStrings - given strings
// AIndent  - number of spaces to add before all strings
//
procedure TN_UDCompBase.UDCompAddCurStateMain( AStrings: TStrings; AIndent: integer );
var
  Prefix: string;
begin
  Prefix := DupeString( ' ', AIndent+2 );
  with AStrings do
  begin
    if Self = nil then begin
      AStrings.Add( Prefix + 'Self = nil' );
      Exit;
    end else if ObjLiveMark <> N_ObjLiveMark then begin
      Add( Prefix + 'UDComp is not alive' );
      Exit;
    end;

    Add( Prefix + 'Name,Info: ' + ObjName + ', ' + ObjInfo );
  end; // with AStrings do
end; // procedure TN_UDCompBase.UDCompAddCurStateMain


//***********************  TN_UDCompVis Class  ***************************

  //*********************************** Virtual methods

//***************************************************** TN_UDCompVis.Create ***
// is an abstract class, instances of TN_UDCompVis type should not be created!
//
constructor TN_UDCompVis.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or N_UDCompVisCI or N_CompBaseBit;
  // in some descendant constructors N_CompBaseFlag can be added to CStatFlags
  CStatFlags := [csfCoords];
end; // end_of constructor TN_UDCompVis.Create

//**************************************************** TN_UDCompVis.Destroy ***
//
//
destructor TN_UDCompVis.Destroy;
begin
  inherited Destroy;
end; // end_of destructor TN_UDCompVis.Destroy

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\CopyFields
//************************************************* TN_UDCompVis.CopyFields ***
// Copy to Self Static Parameters Records Array from given TN_UDCompVis IDB 
// Object
//
//     Parameters
// ASrcObj - given source Visual Component IDB Object to copy Static Parameters
//
procedure TN_UDCompVis.CopyFields( ASrcObj: TN_UDBase );
begin
  if not (ASrcObj is TN_UDCompBase) then Exit;

  Inherited; // call TN_UDCompBase.CopyFields

  if not (ASrcObj is TN_UDCompVis) then Exit;

  K_RFreeAndCopy( PSP()^.CLayout, TN_UDCompVis(ASrcObj).PSP()^.CLayout,
                                          [K_mdfCopyRArray,K_mdfCountUDRef] );

  PSP()^.CCoords := TN_UDCompVis(ASrcObj).PSP()^.CCoords;

  K_RFreeAndCopy( PSP()^.CPanel, TN_UDCompVis(ASrcObj).PSP()^.CPanel,
                                          [K_mdfCopyRArray,K_mdfCountUDRef] );
end; // end_of procedure TN_UDCompVis.CopyFields

//************************************************* TN_UDCompVis.PascalInit ***
//
//
procedure TN_UDCompVis.PascalInit();
begin
  with PCCS()^ do
  begin
    BPCoords := N_ZFPoint;
    BPXCoordsType := cbpPercent;
    BPYCoordsType := cbpPercent;

    LRCoords := FPoint( 100, 100 );
    LRXCoordsType := cbpNotGiven;
    LRYCoordsType := cbpNotGiven;

    SRSize   := FPoint( 100, 100 );
    SRSizeXType := cstPercentS;
    SRSizeYType := cstPercentS;
    SRSizeAspType := catAnyOK;

    BPPos    := N_ZFPoint;
    BPShift  := N_ZFPoint;
    CoordsScope := ccsParent;

    CompUCoords  := FRect( 0, 0, 100, 100 );
    UCoordsType := cutParent;
    UCoordsAspect := 0;
  end;
end; // end_of procedure TN_UDCompVis.PascalInit

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\InitRunTimeFields
//****************************************** TN_UDCompVis.InitRunTimeFields ***
// Clear Component all RunTime fields
//
//     Parameters
// AInitFlags - init flags set to control Component runtime fields
//
// Clear such Self RunTime fields as Font Handels, ReInd Vectors, 
// 2DSpace.Coefs6, Pascal Objects and so on.
//
procedure TN_UDCompVis.InitRunTimeFields( AInitFlags: TN_CompInitFlags );
begin
  // empty in TN_UDCompVis Class
end; // end_of procedure TN_UDCompVis.InitRunTimeFields

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\BeforeAction
//*********************************************** TN_UDCompVis.BeforeAction ***
// Component Action, executed before Before Children
//
procedure TN_UDCompVis.BeforeAction();
begin
  // empty in TN_UDCompVis Class
end; // end_of procedure TN_UDCompVis.BeforeAction

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\AfterAction
//************************************************ TN_UDCompVis.AfterAction ***
// Component Action, executed before After Children
//
procedure TN_UDCompVis.AfterAction();
begin
  // empty in TN_UDCompVis Class
end; // end_of procedure TN_UDCompVis.AfterAction

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\IsInternalPoint
//******************************************** TN_UDCompVis.IsInternalPoint ***
// Check given Point is inside Component
//
//     Parameters
// APoint - given point in Pixel Bufer Coordinates
// Result - Returns TRUE if given Point is inside Component Pixel Rectangle
//
function TN_UDCompVis.IsInternalPoint( const APoint: TPoint ): boolean;
begin
  Result := 0 = N_PointInRect( APoint, CompIntPixRect );
{
  Result := false;
  if 0 = N_PointInRect( APoint, CompIntPixRect ) then // APoint is inside CompIntPixRect
    Result := True;
}
end; // end_of function TN_UDCompVis.IsInternalPoint

  //*********************************** Type specific methods

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\PSP
//******************************************************** TN_UDCompVis.PSP ***
// Get typed pointer to Component Static Parameters
//
//     Parameters
// Result - Returns typed pointer to Component Static Parameters.
//
function TN_UDCompVis.PSP(): TN_PRCompVis;
begin
  Result := TN_PRCompVis(R.P());
end; // end_of function TN_UDCompVis.PSP

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\PDP
//******************************************************** TN_UDCompVis.PDP ***
// Get typed pointer to Component Dynamic Parameters
//
//     Parameters
// Result - Returns typed pointer to Component Dynamic Parameters if they exist,
//          otherwise to Static Parameters.
//
function TN_UDCompVis.PDP(): TN_PRCompVis;
begin
  if DynPar <> nil then Result := TN_PRCompVis(DynPar.P())
                   else Result := TN_PRCompVis(R.P());
end; // end_of function TN_UDCompVis.PDP

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\PCCS
//******************************************************* TN_UDCompVis.PCCS ***
// Get pointer to Visual Component Static Parameters Coordinates field
//
//     Parameters
// Result - Returns pointer to Visual Component Static Parameters Coordinates 
//          field.
//
function TN_UDCompVis.PCCS(): TN_PCompCoords;
begin
  Result := @(TN_PRCompVis(R.P())^.CCoords);
end; // function TN_UDCompVis.PCCS

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\PCCD
//******************************************************* TN_UDCompVis.PCCD ***
// Get pointer to Visual Component Dynamic Parameters Coordinates field
//
//     Parameters
// Result - Returns pointer to Visual Component Dynamic Parameters Coordinates 
//          field if Dynamic Parameters exist, otherwise to pointer to 
//          Coordinates field in Static Parameters.
//
function TN_UDCompVis.PCCD(): TN_PCompCoords;
begin
  if DynPar <> nil then
    Result := @(TN_PRCompVis(DynPar.P())^.CCoords)
  else
    Result := @(TN_PRCompVis(R.P())^.CCoords);
end; // function TN_UDCompVis.PCCD

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\PCPanelS
//*************************************************** TN_UDCompVis.PCPanelS ***
// Get pointer to Visual Component Static Parameters Panel attributes field
//
//     Parameters
// Result - Returns pointer to Visual Component Static Parameters Panel 
//          attributes field (create Panel attributes Records Array if not yet).
//
function TN_UDCompVis.PCPanelS(): TN_PCPanel;
var
  PRCompVis: TN_PRCompVis;
begin
  PRCompVis := TN_PRCompVis(R.P());

  if PRCompVis^.CPanel = nil then // not created yet
  begin
    PRCompVis^.CPanel := K_RCreateByTypeName( 'TN_CPanel', 1 );

    with TN_PCPanel(PRCompVis^.CPanel.P())^ do // Initialize CPanel Params
    begin
      PaBackColor := $FFFFFF;
    end; // with TN_PCPanel(PRCompVis^.CPanel.P())^ do
  end; // if PRCompVis^.CPanel = nil then // not created yet

  Result := TN_PCPanel(PRCompVis^.CPanel.P());
end; // function TN_UDCompVis.PCPanelS

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\PCPanelD
//*************************************************** TN_UDCompVis.PCPanelD ***
// Get pointer to Visual Component Dynamic Parameters Panel attributes field
//
//     Parameters
// Result - Returns pointer to Visual Component Dynamic Parameters Panel 
//          attributes field or nil if Panel attributes Records Array is absent
//
function TN_UDCompVis.PCPanelD(): TN_PCPanel;
begin
  Result := TN_PCPanel(PDP()^.CPanel.P());
end; // function TN_UDCompVis.PCPanelD

  //*********************************** Coords related methods

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\UpdateCurFreeRect
//****************************************** TN_UDCompVis.UpdateCurFreeRect ***
// Update Dynamic Parent Component Current Free Rectangle by Self Inner Pixel 
// Rectangle
//
//     Parameters
// AUpdateFlags - Current Free Rectangle Update Flags
//
// Update Dynamic Parent Component Current Free Rectangle by Self CompIntPixRect
// field.
//
procedure TN_UDCompVis.UpdateCurFreeRect( AUpdateFlags: TN_CurFreeFlags );
var
  CurLeng: integer;
  CFFlags: TN_CurFreeFlags;
  CurFree, PrevRect: TRect;
  PCompCoords: TN_PCompCoords;
  DP: TN_UDCompVis;
begin
  if crtfRootComp in CRTFlags then Exit; // nothing to do (Self is Root Component)

  PCompCoords := PCCD();
  CFFlags := PCompCoords^.CurFreeFlags;

  //***** check if call at needed phase
  if not ( ((cffAABefore in CFFlags) and (cffAABefore in AUpdateFlags)) or
           ((cffABAfter  in CFFlags) and (cffABAfter  in AUpdateFlags)) or
           ((cffAAAfter  in CFFlags) and (cffAAAfter  in AUpdateFlags)) or
           ( not (cffABAfter in CFFlags) and not (cffAAAfter in CFFlags)
                                   and (cffAABefore in AUpdateFlags))  ) then Exit;

  DP := TN_UDCompVis(DynParent); // to reduce code size
{
  if cffSetLeft in CFFlags then // debug
  begin
    CurLeng := Length(DP.CurFreeRects);
    N_ir := DP.CurFreeRects[CurLeng-1];
    N_ir := DP.CompIntPixRect;
    N_s := ObjName;
  end;
}
  // change DynParent CurFreeRects Before updating (if needed)

  CurLeng := Length(DP.CurFreeRects);

  if cffPushBefore  in CFFlags then  // Save Current FreeRect (Push to CurFreeRects Stack)
  begin
    SetLength( DP.CurFreeRects, CurLeng + 1 );
    DP.CurFreeRects[CurLeng] := DP.CurFreeRects[CurLeng-1];
    Inc( CurLeng );
  end; // if cffPushBefore  in CurFreeFlags then  // Save Current FreeRect

  if cffPopBefore  in CFFlags then  // Restore Current FreeRect (Pop from CurFreeRects Stack)
  begin
    Dec( CurLeng );
    SetLength( DP.CurFreeRects, CurLeng );
  end; // if cffPopBefore  in CurFreeFlags then  // Restore Current FreeRect

  CurFree := DP.CurFreeRects[CurLeng-1]; // CurFree is temporary variable to reduce code size

  //***** PrevRect is Previous Rect in CurFreeRects Stack
  if CurLeng = 1 then PrevRect := DP.CompIntPixRect
                 else PrevRect := DP.CurFreeRects[CurLeng-2];

  //***** Reset some sides of CurFree by PrevRect if needed
  if cffResetLeft   in CFFlags then CurFree.Left   := PrevRect.Left;
  if cffResetRight  in CFFlags then CurFree.Right  := PrevRect.Right;
  if cffResetTop    in CFFlags then CurFree.Top    := PrevRect.Top;
  if cffResetBottom in CFFlags then CurFree.Bottom := PrevRect.Bottom;

  // update CurFree by Self.CompIntPixRect if needed
  if cffSetLeft   in CFFlags then CurFree.Left   := Max( CurFree.Left,   CompIntPixRect.Right );
  if cffSetRight  in CFFlags then CurFree.Right  := Min( CurFree.Right,  CompIntPixRect.Left );
  if cffSetTop    in CFFlags then CurFree.Top    := Max( CurFree.Top,    CompIntPixRect.Bottom );
  if cffSetBottom in CFFlags then CurFree.Bottom := Min( CurFree.Bottom, CompIntPixRect.Top );

  // store calculated CurFree in CurFreeRects (CurFree is temporary variable)
  DP.CurFreeRects[CurLeng-1] := CurFree;

  // change DynParent CurFreeRects After updating (if needed)
  if cffPushAfter  in CFFlags then // Save FreeRect
  begin
    SetLength( DP.CurFreeRects, CurLeng + 1 );
    DP.CurFreeRects[CurLeng] := DP.CurFreeRects[CurLeng-1];
  end; // if cffPushAfter  in CFFlags then // Save FreeRect

end; // end_of procedure TN_UDCompVis.UpdateCurFreeRect

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\GetAspect
//************************************************** TN_UDCompVis.GetAspect ***
// Get Component Aspect by Component Dynamic coordinates
//
//     Parameters
// Result - Returns Component current aspect or -1 if Component X size or Y size
//          is 0.
//
function TN_UDCompVis.GetAspect(): double;
begin
  with PCCD^ do
  begin
    if SRSizeAspect = -1 then SRSizeAspType := catSize;    // temporary

    if SRSizeAspect = -2 then SRSizeAspType := catUCoords; // temporary

    if SRSizeAspect = -3 then // temporary ?
    begin
      CalcParams1(); // calc SRSizeAspect field and may be some others
      SRSizeAspType := catGiven;
    end;

    case SRSizeAspType of
      catSize: begin
          if (SRSize.Y = 0 ) or (SRSize.X = 0) then
            Result := -1
          else
            Result := SRSize.Y / SRSize.X;
        end;

      catUCoords: Result := N_RectAspect( CompUCoords );
      else
        Result := SRSizeAspect;
    end; // case SRSizeAspType of
  end; // with PCCD^ do
end; // end_of function TN_UDCompVis.GetAspect

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\CalcRootCurPixRectSize
//************************************* TN_UDCompVis.CalcRootCurPixRectSize ***
// Calculate Root Component Internal Pixel Rectangle Width and Height using 
// given maximal Pixel Width and Height
//
//     Parameters
// AMaxPixSize - maximal component pixel Width and Height as Integer Point 
//               record
// Result      - Component Internal Pixel Rectangle Width and Height as Integer 
//               Point record
//
// Resulting Width and Height should be calculated using Component Self aspect
//
function TN_UDCompVis.CalcRootCurPixRectSize( const AMaxPixSize: TPoint ): TPoint;
begin
  Result := N_AdjustSizeByAspect( aamDecRect, AMaxPixSize, GetAspect() );
end; // function TN_UDCompVis.CalcRootCurPixRectSize

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\GetSize
//**************************************************** TN_UDCompVis.GetSize ***
// Get Component Size Value and Units from Dynamic Parameters
//
//     Parameters
// APSrcmm   - pointer to resulting Self X,Y Sizes in mm
// APSrcPix  - pointer to resulting Self X,Y Sizes in Pixels
// AGivenRes - given Resolution in DPI (if = 0, Self.SrcResDPI is used)
// Result    - Returns resulting size coordinates units (pixel or mm)
//
// Returned Width and Height is always > 0.
//
function TN_UDCompVis.GetSize( APSrcmm: PFPoint; APSrcPix: PPoint;
                                           AGivenRes: float ): TN_VCTSizeType;
var
  Asp, SrcRes: double;
  TmpSrcmm: TFPoint;
  TmpSrcPix: TPoint;
  Label SetBymm;
begin
  Asp := GetAspect();

  // Add later Parent checking!

  with PCCD()^ do
  begin
    SrcRes := SrcResDPI;
    if AGivenRes <> 0 then SrcRes := AGivenRes;
    if SrcRes = 0 then SrcRes := 72;

    if (SRSizeXType = cstmm) or (SRSizeYType = cstmm) then // Size in mm
    begin
      Result := vstmm;
      TmpSrcmm := SRSize;

      SetBymm : //******* common part for Size in mm and Size is not given

      if SRSizeXType = cstAspect then
        TmpSrcmm.X := TmpSrcmm.Y / Asp;

      if SRSizeYType = cstAspect then
        TmpSrcmm.Y := TmpSrcmm.X * Asp;

      TmpSrcPix.X := Round(TmpSrcmm.X * SrcRes / 25.4);
      TmpSrcPix.Y := Round(TmpSrcmm.Y * SrcRes / 25.4);

    end else if (SRSizeXType = cstPixel) or (SRSizeYType = cstPixel) then // Size in Pix
    begin
      Result := vstPix;
      TmpSrcPix.X := Round(SRSize.X);
      TmpSrcPix.Y := Round(SRSize.Y);

      if SRSizeXType = cstAspect then
        TmpSrcPix.X := Round(TmpSrcPix.Y / Asp);

      if SRSizeYType = cstAspect then
        TmpSrcPix.Y := Round(TmpSrcPix.X * Asp);

      TmpSrcmm.X := 25.4 * TmpSrcPix.X / SrcRes;
      TmpSrcmm.Y := 25.4 * TmpSrcPix.Y / SrcRes;

    end else // Component Size is not avaliable, set default size (100 x 100 mm)
    begin
      Result  := vstNotGiven;
      TmpSrcmm  := FPoint(100,100);
      goto SetBymm;
    end;
  end; // with PCCD()^ do

  if APSrcmm  <> nil then APSrcmm^  := TmpSrcmm;
  if APSrcPix <> nil then APSrcPix^ := TmpSrcPix;
end; // function TN_UDCompVis.GetSize

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\SetSizeUnitsCoefs
//****************************************** TN_UDCompVis.SetSizeUnitsCoefs ***
// Set Coeficients for Size Units convertions
//
// Coeficients for Size Units convertions are individual for each Component.
//
procedure TN_UDCompVis.SetSizeUnitsCoefs();
begin
  with NGCont, NGCont.DstOCanv, PCCD()^ do
  begin
    N_CC := PCCD()^; // debug
    if ObjName = 'RF' then  // debug
      N_i := 1;

    if (CoordsScope = ccsDstImage) then // use Destination based Size Units
    begin
      PixPixSize.X := 1;
      PixPixSize.Y := 1;

      mmPixSize.X  := DstPixSize.X / DstmmSize.X;
      mmPixSize.Y  := DstPixSize.Y / DstmmSize.Y;
    end else //*************************** use normal (Src based) Size Units
    begin
      PixPixSize.X := GCCurDstPixSize.X / GCCurSrcPixSize.X;
      PixPixSize.Y := GCCurDstPixSize.Y / GCCurSrcPixSize.Y;

      mmPixSize.X  := GCCurDstPixSize.X / GCCurSrcmmSize.X;
      mmPixSize.Y  := GCCurDstPixSize.Y / GCCurSrcmmSize.Y;
    end;

    N_i1 := DstPixSize.X; // debug
    N_f1 := SrcmmSize.X;
    N_f2 := mmPixSize.X;

    CurLSUPixSize := (25.4/72)*Min( mmPixSize.X, mmPixSize.Y );
    CurLLWPixSize := CurLSUPixSize;
    N_d := CurLSUPixSize; // debug
    CurLFHPixSize := CurLSUPixSize;

    if ObjName = 'RF' then  // debug
      N_i := 1;
//    if ObjName = 'RF' then  // debug
//      CurLFHPixSize := 2*CurLSUPixSize;

  end; // with NGCont, NGCont.DstOCanv, PCCD()^ do
end; // procedure TN_UDCompVis.SetSizeUnitsCoefs

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\SetNewPClipRect
//******************************************** TN_UDCompVis.SetNewPClipRect ***
// Set New Clipping Rectangle by given Rectangle in logical pixels
//
//     Parameters
// AClipRect - source Clipping Rectangle in logical pixels
//
procedure TN_UDCompVis.SetNewPClipRect( AClipRect: TRect );
var
  NewClipRect: TRect;
begin
  with NGCont, NGCont.DstOCanv, SavedOCanvFields do
  begin
    ClipRectChanged := True;

    // convert given AClipRect from logical to Page coords using current Transformation

    NewClipRect := AClipRect;
    Windows.LPtoDP( HMDC, NewClipRect, 2 );
    NewClipRect := N_IRectOrder( NewClipRect );

    SetPClipRect( NewClipRect ); // set new Clipping Rect
  end; // with NGCont, NGCont.DstOCanv, SavedOCanvFields do
end; // procedure TN_UDCompVis.SetNewPClipRect

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\SetOuterPixCoords
//****************************************** TN_UDCompVis.SetOuterPixCoords ***
// Set Component Outer Pixel Rectangle (called from TN_UDCompBase.ExecSubTree)
//
// Parent Component Inner Pixel Rectangle should be OK. Coordinates Scope cases 
// ccsRoot and ccsVisible are not implemented.
//
procedure TN_UDCompVis.SetOuterPixCoords();
var
  ScopeWidth, ScopeHeight: integer;
  BPPix, LRPix, SizePix: TPoint;
  ParentCurPix, ParentCurFree, TmpOuterPixRect: TRect; // VisibleRect,
  SizeAspect: double;
  Parent: TN_UDCompBase;
  TmpXFORM: TXFORM;
  AC6Params: Array [0..2] of double;
  TmpAffCoefs6: TN_AffCoefs6;
  label SetWinTransforms;
begin
//  N_CC := PCCD^; // debug
  N_s := ObjName; // debug
//  if ObjName = 'Reg_1' then // debug
//    N_i := 0;

  with NGCont, NGCont.DstOCanv, PCCD^ do
  begin

  SetSizeUnitsCoefs();

  if crtfRootComp in CRTFlags then // Self is VCTree Root
  begin
    ScopePixRect.Left := N_NotAnInteger;
    // CompOuterPixRect should be already OK, but may be not transformed
    TmpOuterPixRect := CompOuterPixRect;
    goto SetWinTransforms;
  end else //************************ not Root Component
  begin
    Parent := Self; // initial value
    while True do // search for first Visual Parent and set Parent field
    begin
      Parent := Parent.DynParent;
      Assert( Parent <> nil, 'NoVisualParent!' );

      if csfCoords in Parent.CStatFlags then // found
      with TN_UDCompVis(Parent) do
      begin
        ParentCurPix  := CompIntPixRect;
        ParentCurFree := CurFreeRects[High(CurFreeRects)];
        Break;
      end; // with ParentComp do
    end; // while True do // search for first Visual Parent or nil
  end; // else // Parent Component exists

  //***** ScopePixRect is Pixel Rect, in which Self Position is calculated

  case CoordsScope of
    ccsParent:   ScopePixRect := ParentCurPix;
    ccsCurFree:  ScopePixRect := ParentCurFree;
    ccsRoot:     ScopePixRect := ParentCurPix; // temporary not implemented !!!
    ccsVisible:  ScopePixRect := ParentCurPix; // temporary not implemented !!!
    ccsDstImage: ScopePixRect := IRect( DstPixSize );
  end; // case CoordsScope of

  ScopeWidth  := Max( 2, N_RectWidth(  ScopePixRect ) ); // to avoid dividing by zero
  ScopeHeight := Max( 2, N_RectHeight( ScopePixRect ) ); // to avoid dividing by zero

  // Calc BasePoint Pixel coords (BPPix) with zero shift

  case BPXCoordsType of //******************************** Base Point X Coord
  cbpPix:      BPPix.X := ScopePixRect.Left  + Round( BPCoords.X*PixPixSize.X );
  cbpPix_LR:   BPPix.X := ScopePixRect.Right - Round( BPCoords.X*PixPixSize.X );
  cbpLSU:      BPPix.X := ScopePixRect.Left  + Round( BPCoords.X*CurLSUPixSize );
  cbpLSU_LR:   BPPix.X := ScopePixRect.Right - Round( BPCoords.X*CurLSUPixSize );
  cbpUser:     BPPix.X := Round( U2P.CX * BPCoords.X + U2P.SX );
  cbpPercent:  BPPix.X := ScopePixRect.Left  + Round( BPCoords.X*(ScopeWidth-1)/100 );
  cbpmm:       BPPix.X := ScopePixRect.Left  + Round( BPCoords.X*mmPixSize.X );
  cbpmm_LR:    BPPix.X := ScopePixRect.Right - Round( BPCoords.X*mmPixSize.X );
  cbpNotGiven: begin
                 BPPix.X   := 0; // to avoid range checking error
                 BPShift.X := 0; // to avoid range checking error
                 BPPos.X   := 0; // is used later
               end;
  end; // case BPXCoordsType of

  case BPYCoordsType of //******************************** Base Point Y Coord
  cbpPix:      BPPix.Y := ScopePixRect.Top    + Round( BPCoords.Y*PixPixSize.Y );
  cbpPix_LR:   BPPix.Y := ScopePixRect.Bottom - Round( BPCoords.Y*PixPixSize.Y );
  cbpLSU:      BPPix.Y := ScopePixRect.Top    + Round( BPCoords.Y*CurLSUPixSize );
  cbpLSU_LR:   BPPix.Y := ScopePixRect.Bottom - Round( BPCoords.Y*CurLSUPixSize );
  cbpUser:     BPPix.Y := Round( U2P.CY * BPCoords.Y + U2P.SY );
  cbpPercent:  BPPix.Y := ScopePixRect.Top    + Round( BPCoords.Y*(ScopeHeight-1)/100 );
  cbpmm:       BPPix.Y := ScopePixRect.Top    + Round( BPCoords.Y*mmPixSize.Y );
  cbpmm_LR:    BPPix.Y := ScopePixRect.Bottom - Round( BPCoords.Y*mmPixSize.Y );
  cbpNotGiven: begin
                 BPPix.Y   := 0; // to avoid range checking error
                 BPShift.Y := 0; // to avoid range checking error
                 BPPos.Y   := 0; // is used later
               end;
  end; // case BPYCoordsType of

  // Update BPPix by BPShift
  BPPix.X := BPPix.X + Round( CurLSUPixSize*BPShift.X );
  BPPix.Y := BPPix.Y + Round( CurLSUPixSize*BPShift.Y );

  // Calc LowerRight corner Pixel coords (LRPix)

  case LRXCoordsType of //************************* Lower RightCorner X Coord
  cbpPix:      LRPix.X := ScopePixRect.Left  + Round( LRCoords.X*PixPixSize.X );
  cbpPix_LR:   LRPix.X := ScopePixRect.Right - Round( LRCoords.X*PixPixSize.X );
  cbpLSU:      LRPix.X := ScopePixRect.Left  + Round( LRCoords.X*CurLSUPixSize );
  cbpLSU_LR:   LRPix.X := ScopePixRect.Right - Round( LRCoords.X*CurLSUPixSize );
  cbpUser:     LRPix.X := Round( U2P.CX * LRCoords.X + U2P.SX );
  cbpPercent:  LRPix.X := ScopePixRect.Left  + Round( LRCoords.X*(ScopeWidth-1)/100 );
  cbpmm:       LRPix.X := ScopePixRect.Left  + Round( LRCoords.X*mmPixSize.X );
  cbpmm_LR:    LRPix.X := ScopePixRect.Right - Round( LRCoords.X*mmPixSize.X );
  cbpNotGiven: LRPix.X := ScopePixRect.Right; // a precaution
  end; // case LRXCoordsType of

  case LRYCoordsType of //************************* Lower RightCorner Y Coord
  cbpPix:      LRPix.Y := ScopePixRect.Top    + Round( LRCoords.Y*PixPixSize.Y );
  cbpPix_LR:   LRPix.Y := ScopePixRect.Bottom - Round( LRCoords.Y*PixPixSize.Y );
  cbpLSU:      LRPix.Y := ScopePixRect.Top    + Round( LRCoords.Y*CurLSUPixSize );
  cbpLSU_LR:   LRPix.Y := ScopePixRect.Bottom - Round( LRCoords.Y*CurLSUPixSize );
  cbpUser:     LRPix.Y := Round( U2P.CY * LRCoords.Y + U2P.SY );
  cbpPercent:  LRPix.Y := ScopePixRect.Top    + Round( LRCoords.Y*(ScopeHeight-1)/100 );
  cbpmm:       LRPix.Y := ScopePixRect.Top    + Round( LRCoords.Y*mmPixSize.Y );
  cbpmm_LR:    LRPix.Y := ScopePixRect.Bottom - Round( LRCoords.Y*mmPixSize.Y );
  cbpNotGiven: LRPix.Y := ScopePixRect.Bottom; // a precaution
  end; // case LRYCoordsType of

  // Calc Size by UL and LR corners as if SRSizeX,YType = cstNotGiven
  // ( Size IS given it would be recalculated)

  if LRXCoordsType <> cbpNotGiven then SizePix.X := LRPix.X - BPPix.X + 1;
  if LRYCoordsType <> cbpNotGiven then SizePix.Y := LRPix.Y - BPPix.Y + 1;

  case SRSizeXType of //********************************* SelfRect X Size
  cstUser:     SizePix.X := Round( SRSize.X*U2P.CX );
  cstPixel:    SizePix.X := Round( SRSize.X*PixPixSize.X );
  cstLSU:      SizePix.X := Round( SRSize.X*CurLSUPixSize );
  cstmm:       SizePix.X := Round( SRSize.X*mmPixSize.X );
  cstPercentS: SizePix.X := Round( SRSize.X*ScopeWidth/100 );
  cstPercentP: SizePix.X := Round( SRSize.X*N_RectWidth(ParentCurPix)/100 );
  cstNotGiven: begin
      if (0 <= BPPos.X) and (BPPos.X <0.99) then // to avoid div by zero
        SizePix.X := Round( (LRPix.X - BPPos.X - BPPix.X + 1)/(1-BPPos.X) )
      else
        SizePix.X := Round( (LRPix.X - 100) );
    end;
  end; // case SRSizeXType of

  case SRSizeYType of //********************************* SelfRect Y Size
  cstUser:     SizePix.Y := Round( SRSize.Y*U2P.CY );
  cstPixel:    SizePix.Y := Round( SRSize.Y*PixPixSize.Y );
  cstLSU:      SizePix.Y := Round( SRSize.Y*CurLSUPixSize );
  cstmm:       SizePix.Y := Round( SRSize.Y*mmPixSize.Y );
  cstPercentS: SizePix.Y := Round( SRSize.Y*ScopeHeight/100 );
  cstPercentP: SizePix.Y := Round( SRSize.Y*N_RectHeight(ParentCurPix)/100 );
  cstNotGiven: begin
      if (0 <= BPPos.Y) and (BPPos.Y <0.99) then // to avoid div by zero
        SizePix.Y := Round( (LRPix.Y - BPPos.Y - BPPix.Y + 1)/(1-BPPos.Y) )
      else
        SizePix.Y := Round( (LRPix.Y - 100) );
    end;
  end; // case SRSizeYType of

  // Update SizePix by SRSizeAspect if needed

  case SRSizeAspType of
    catUCoords: SizeAspect := N_RectAspect( CompUCoords );
    else
      SizeAspect := SRSizeAspect;
  end; // case SRSizeAspType of

  if SizeAspect > 0 then
  begin
    if SRSizeXType = cstAspect then SizePix.X := Round( SizePix.Y / SizeAspect );
    if SRSizeYType = cstAspect then SizePix.Y := Round( SizePix.X * SizeAspect );
  end; // if SizeAspect <> -1 then

  // Calculate UL corenr by LR corner and Size if BasePoint was not given
  // (BPPix in this case case is same as UL corner coords)

  if BPXCoordsType = cbpNotGiven then BPPix.X := LRPix.X - SizePix.X + 1;
  if BPYCoordsType = cbpNotGiven then BPPix.Y := LRPix.Y - SizePix.Y + 1;

  //***** Here: BPPix, SizePix, BPPos are OK, calc CompOuterPixRect

  if cffFullAspSize in CurFreeFlags then // use ScopePixRect instead of Component Size
  begin
    TmpOuterPixRect := N_DecRectbyAspect( ScopePixRect, GetAspect() );
  end else // normal case (use Component Size)
  begin
    TmpOuterPixRect := N_RectMake( BPPix, SizePix, DPoint(BPPos) );
  end;

  SetWinTransforms: //***** TmpOuterPixRect is OK, Transform it to CompOuterPixRect

  with NGCont.DstOcanv, SavedOCanvFields do
  begin
    if PixTransfType = ctfNoTransform then // no Transformation is needed,
    begin                  // UseP2PWin field can have any value (True or False)
      P2PWinChanged := False;
      CompOuterPixRect := TmpOuterPixRect;
    end else //****** PixTransfType <> ctfNoTransform, Set needed Transformation
    begin
      P2PWinChanged  := True;
      SavedP2PWin    := P2PWin;
      SavedUseP2PWin := UseP2PWin;
      UseP2PWin      := True;

      AdvancedMode( True ); // set Advanced mode if not yet

      if CCRotateAngle <> 0.0 then // Rotate by CCRotateAngle using Windows Trsform
      begin
        AC6Params[0] := CCRotateAngle;        // Rotation Angle in degree
        AC6Params[1] := TmpOuterPixRect.Left; // Center X Coord
        AC6Params[2] := TmpOuterPixRect.Top;  // Center Y Coord
        N_CalcAffCoefs6( 3, TmpAffCoefs6, @AC6Params[0] );
        TmpXFORM := N_ConvToXForm( TmpAffCoefs6 );
        CompOuterPixRect := TmpOuterPixRect; // temporary. later improve!
      end else // Use PixTransfType to define Windows Trsform
      begin
        N_CalcAffCoefs6( PixTransfType, TmpOuterPixRect, @TmpXFORM, @CompOuterPixRect );
      end;

      N_b := Windows.ModifyWorldTransform( HMDC, TmpXFORM, MWT_LEFTMULTIPLY );
      Assert( N_b, 'BadXForm1' ); // a precaution
      N_b := Windows.GetWorldTransform( HMDC, CompP2PWin ); // is used while searching
      Assert( N_b, 'BadXForm2' ); // a precaution
    end; // Set needed Tranformation

  end; // with NGCont.DstOcanv, SavedOCanvFields do

  end; // with NGCont, NGCont.DstOCanv, PCCD^ do
end; // end_of procedure TN_UDCompVis.SetOuterPixCoords

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\SetCompUCoords
//********************************************* TN_UDCompVis.SetCompUCoords ***
// Set Component User Coordinates using Self Inner Pixel Rectangle
//
// Coordinates Scope cases ccsRoot and ccsVisible are not implemented.
//
procedure TN_UDCompVis.SetCompUCoords();
var
  SizePix: TPoint;
  NewCompUCoords: TFRect;
//  VisibleRect: TRect;
  label SetUserClipRect;
begin
//  N_CC := PCCD^; // debug
  N_s := ObjName; // debug

//  if ObjName = 'Reg_1' then // debug
//    N_i := 0;
//  if ObjName = 'Elem_2' then // debug
//  if ObjName = 'MapLegend' then // debug
//  if ObjName = 'MapHeader' then // debug
//    N_i := 0;

  with NGCont, NGCont.DstOCanv, PCCD^ do
  begin

  OCUserAspect := UCoordsAspect;
  if OCUserAspect > 600 then OCUserAspect := 0;

  SizePix := N_RectSize( CompIntPixRect );

  case UCoordsType of //************************* set NewCompUCoords variable

  cutLLW: NewCompUCoords := FRect( -0.5/CurLLWPixSize, -0.5/CurLLWPixSize,
                     (SizePix.X-0.5)/CurLLWPixSize, (SizePix.Y-0.5)/CurLLWPixSize );

  cutmm:  NewCompUCoords := FRect( (-0.5*25.4/72)/CurLLWPixSize, (-0.5*25.4/72)/CurLLWPixSize,
            ((SizePix.X-0.5)*25.4/72)/CurLLWPixSize, ((SizePix.Y-0.5)*25.4/72)/CurLLWPixSize );

  cutGiven: begin
    NewCompUCoords := CompUCoords;
    N_AdjustRectAspect( aamIncRect, NewCompUCoords, UCoordsAspect*N_RectAspect(CompIntPixRect) );
  end;

  cutGivenAnyAsp: begin
    NewCompUCoords := CompUCoords;
  end;

  cutParent: begin
    if crtfRootComp in CRTFlags then // is Root Component - set UCoords in same way as in CutGiven case
    begin
      NewCompUCoords := CompUCoords;
//      N_AdjustRectAspect( aamIncRect, NewCompUCoords, UCoordsAspect*N_RectAspect(CompIntPixRect));
    end else // not Root component
      goto SetUserClipRect;
  end;

  cutNotGiven: goto SetUserClipRect; // skip CalcAffCoefs

  cutPercent: NewCompUCoords := FRect( 0, 0, 100, 100 ); // temporary

  end; // case UCoordsType of

  SetCoefs( NewCompUCoords, CompIntPixRect );

  SetUserClipRect : //*************************

  CompP2U := P2U;
  CompU2P := U2P;
  CompIntUserRect := N_AffConvI2FRect1( CompIntPixRect, CompP2U );

  SetUClipRect( CompIntPixRect );
{
  if cbfSkipClipping in PDP()^.CCompBase.CBFlags1 then
    SetUClipRect( CompIntPixRect )
  else
  begin
    VisibleRect := CompIntPixRect;
    N_IRectAnd( VisibleRect, CurCRect );
//    SetPClipRect( VisibleRect );
    SetUClipRect( VisibleRect );
  end;
}
  end; // with NGCont, NGCont.DstOCanv, PCCD^ do
end; // end_of procedure TN_UDCompVis.SetCompUCoords

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\ChangeCompCoords
//******************************************* TN_UDCompVis.ChangeCompCoords ***
// Change Component Coordinates by given Inner and Scope Pixel Rectangles
//
//     Parameters
// ANewCurPixRect - value of new Component Inner Pixel Rectangle
// AScopePixRect  - component Pixel Scope Rectangle
//
// If given new Component Inner Pixel Rectangle is equal to Component current 
// Inner Pixel Rectangle coordinates are not changed.
//
procedure TN_UDCompVis.ChangeCompCoords( ANewCurPixRect, AScopePixRect: TRect );
//
// Change Component Coordinates by given ANewCurPixRect (new value of CompIntPixRect) and
// AScopePixRect (saved in SetOuterPixCoords) if ANewCurPixRect = CompIntPixRect
// coords are not changed
//
var
  Delta: integer;
  BPPix: TDPoint;
  ScopeWidth, ScopeHeight, DDelta: double;
  ScopeRect: TRect;
begin
//  N_s := ObjName; // debug
  if AScopePixRect.Left = N_NotAnInteger then Exit; // not aplicable
  if N_Same( ANewCurPixRect, CompIntPixRect ) then Exit; // Coords should remain the same

  //*** Calculating any float coords by new ANewCurPixRect may be not
  //    precise because of rounding while calculating CompIntPixRect!

  ScopeRect   := AScopePixRect;
  ScopeWidth  := N_RectWidth( ScopeRect );
  ScopeHeight := N_RectHeight( ScopeRect );

  with NGCont, NGCont.DstOCanv, PCCS()^, N_MEGlobObj do
  begin
    SetSizeUnitsCoefs();
    //***** Calc BPPix - BasePoint PixelCoords by BPPos and BPShift

    BPPix.X := ANewCurPixRect.Left +
               BPPos.X*(N_RectWidth(ANewCurPixRect)-1)  - CurLSUPixSize*BPShift.X;
    BPPix.Y := ANewCurPixRect.Top +
               BPPos.Y*(N_RectHeight(ANewCurPixRect)-1) - CurLSUPixSize*BPShift.Y;

    //***** Calc BPCoords (Base Point Coords in given units) by BPPix

    DDelta := BPPix.X - ScopeRect.Left; // relative to Left side
    case BPXCoordsType of
      cbpUser:    BPCoords.X := N_SnapToGrid( GridStepUser.X, CompP2U.CX * BPPix.X + CompP2U.SX );
      cbpPix:     BPCoords.X := N_SnapToGrid( 1, DDelta / PixPixSize.X );
      cbpLSU:     BPCoords.X := N_SnapToGrid( GridStepLSU.X, DDelta / CurLSUPixSize );
      cbpmm:      BPCoords.X := N_SnapToGrid( GridStepmm.X,  DDelta / mmPixSize.X );
      cbpPercent: BPCoords.X := N_SnapToGrid( GridStepPrc.X, DDelta * 100 / (ScopeWidth-1) );
    end; // case BPXCoordsType of

    DDelta := ScopeRect.Right - BPPix.X; // relative to Right side
    case BPXCoordsType of
      cbpPix_LR: BPCoords.X := N_SnapToGrid( 1, DDelta / PixPixSize.X );
      cbpLSU_LR: BPCoords.X := N_SnapToGrid( GridStepLSU.X, DDelta / CurLSUPixSize );
      cbpmm_LR:  BPCoords.X := N_SnapToGrid( GridStepmm.X,  DDelta / mmPixSize.X );
    end; // case BPXCoordsType of

    DDelta := BPPix.Y - ScopeRect.Top; // relative to Top side
    case BPYCoordsType of
      cbpUser:    BPCoords.Y := N_SnapToGrid( GridStepUser.Y, CompP2U.CY * BPPix.Y + CompP2U.SY );
      cbpPix:     BPCoords.Y := N_SnapToGrid( 1, DDelta / PixPixSize.Y );
      cbpLSU:     BPCoords.Y := N_SnapToGrid( GridStepLSU.Y, DDelta / CurLSUPixSize );
      cbpmm:      BPCoords.Y := N_SnapToGrid( GridStepmm.Y,  DDelta / mmPixSize.Y );
      cbpPercent: BPCoords.Y := N_SnapToGrid( GridStepPrc.Y, DDelta * 100 / (ScopeHeight-1) );
    end; // case BPYCoordsType of

    DDelta := ScopeRect.Bottom - BPPix.Y; // relative to Bottom Side
    case BPYCoordsType of
      cbpPix_LR: BPCoords.Y := N_SnapToGrid( 1, DDelta / PixPixSize.Y );
      cbpLSU_LR: BPCoords.Y := N_SnapToGrid( GridStepLSU.Y, DDelta / CurLSUPixSize );
      cbpmm_LR:  BPCoords.Y := N_SnapToGrid( GridStepmm.Y,  DDelta / mmPixSize.Y );
    end; // case BPYCoordsType of

    //***** Calc LRCoords (LowerRight corner Coords in given units)

    Delta := ANewCurPixRect.Right - ScopeRect.Left; // relative to UL corner
    case LRXCoordsType of
      cbpUser:    LRCoords.X := N_SnapToGrid( GridStepUser.X, CompP2U.CX * ANewCurPixRect.Right + CompP2U.SX );
      cbpPix:     LRCoords.X := N_SnapToGrid( 1, Delta / PixPixSize.X );
      cbpLSU:     LRCoords.X := N_SnapToGrid( GridStepLSU.X, Delta / CurLSUPixSize );
      cbpmm:      LRCoords.X := N_SnapToGrid( GridStepmm.X,  Delta / mmPixSize.X );
      cbpPercent: LRCoords.X := N_SnapToGrid( GridStepPrc.X, Delta * 100 / (ScopeWidth-1) );
    end; // case LRXCoordsType of

    Delta := ScopeRect.Right - ANewCurPixRect.Right; // relative to LR corner
    case LRXCoordsType of
      cbpPix_LR: LRCoords.X := N_SnapToGrid( 1, Delta / PixPixSize.X );
      cbpLSU_LR: LRCoords.X := N_SnapToGrid( GridStepLSU.X, Delta / CurLSUPixSize );
      cbpmm_LR:  LRCoords.X := N_SnapToGrid( GridStepmm.X,  Delta / mmPixSize.X );
    end; // case LRXCoordsType of

    Delta := ANewCurPixRect.Bottom - ScopeRect.Top; // relative to UL corner
    case LRYCoordsType of
      cbpUser:    LRCoords.Y := N_SnapToGrid( GridStepUser.Y, CompP2U.CY * ANewCurPixRect.Bottom + CompP2U.SY );
      cbpPix:     LRCoords.Y := N_SnapToGrid( 1, Delta / PixPixSize.Y );
      cbpLSU:     LRCoords.Y := N_SnapToGrid( GridStepLSU.Y, Delta / CurLSUPixSize );
      cbpmm:      LRCoords.Y := N_SnapToGrid( GridStepmm.Y,  Delta / mmPixSize.Y );
      cbpPercent: LRCoords.Y := N_SnapToGrid( GridStepPrc.Y, Delta * 100 / (ScopeHeight-1) );
    end; // case LRYCoordsType of

    Delta := ScopeRect.Bottom - ANewCurPixRect.Bottom; // relative to LR corner
    case LRYCoordsType of
      cbpPix_LR: LRCoords.Y := N_SnapToGrid( 1, Delta / PixPixSize.Y );
      cbpLSU_LR: LRCoords.Y := N_SnapToGrid( GridStepLSU.Y, Delta / CurLSUPixSize );
      cbpmm_LR:  LRCoords.Y := N_SnapToGrid( GridStepmm.Y,  Delta / mmPixSize.Y );
    end; // case LRYCoordsType of

    //***** Calc SRSize in given units

    Delta := N_RectWidth( ANewCurPixRect );
    case SRSizeXType of
      cstUser:     SRSize.X := N_SnapToGrid( GridStepUser.X, Delta / CompU2P.CX );
      cstPixel:    SRSize.X := N_SnapToGrid( 1, Delta / PixPixSize.X );
      cstLSU:      SRSize.X := N_SnapToGrid( GridStepLSU.X, Delta / CurLSUPixSize );
      cstmm:       SRSize.X := N_SnapToGrid( GridStepmm.X,  Delta / mmPixSize.X );
      cstPercentS: SRSize.X := N_SnapToGrid( GridStepPrc.X, Delta * 100 / ScopeWidth );
      cstPercentP: SRSize.X := N_SnapToGrid( GridStepPrc.X, Delta * 100 / ScopeWidth );
    end; // case SRSizeXType of

    Delta := N_RectHeight( ANewCurPixRect );
    case SRSizeYType of
      cstUser:     SRSize.Y := N_SnapToGrid( GridStepUser.Y, Delta / CompU2P.CY );
      cstPixel:    SRSize.Y := N_SnapToGrid( 1, Delta / PixPixSize.Y );
      cstLSU:      SRSize.Y := N_SnapToGrid( GridStepLSU.Y, Delta / CurLSUPixSize );
      cstmm:       SRSize.Y := N_SnapToGrid( GridStepmm.Y,  Delta / mmPixSize.Y );
      cstPercentS: SRSize.Y := N_SnapToGrid( GridStepPrc.Y, Delta * 100 / ScopeHeight );
      cstPercentP: SRSize.Y := N_SnapToGrid( GridStepPrc.Y, Delta * 100 / ScopeHeight );
    end; // case SRSizeYType of

  end; // with AOCanv, PCCS()^ do
end; // end_of procedure TN_UDCompVis.ChangeCompCoords

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\ConvToPix
//************************************************** TN_UDCompVis.ConvToPix ***
// Convert given Float Point in given Coordinates to Integer Point in 
// destination Canvas Pixel Coordinates
//
//     Parameters
// APoint      - given Float Point
// ACoordsType - given Point Coordinates type
// AConvFlags  - convertion flags (coordinates scope type)
// Result      - Returns converted Point in destination Canvas Pixel Coordinates
//
function TN_UDCompVis.ConvToPix( const APoint: TFPoint;
                                       ACoordsType: TN_CompCoordsType;
                                       AConvFlags: TN_CoordsConvFlags ): TPoint;
var
  dx, dy: double;
  ScopeRect: TRect;
begin
  Result := Point( N_NotAnInteger, 0 );
  with NGCont, NGCont.DstOcanv do
  begin

  if ACoordsType = cctUser then // Self User Coords
  begin
    Result := N_AffConvF2IPoint( APoint, CompU2P )
  end else //********************* Some Coords relative to given Coords Scope
  begin
    if ccfSelfScope in AConvFlags then
      ScopeRect := CompIntPixRect
    else if ccfRootScope in AConvFlags then
      ScopeRect := DstPixRect
    else if ccfParentScope in AConvFlags then
    begin
      if crtfRootComp in CRTFlags then Exit; // Root component
      ScopeRect := TN_UDCompVis(DynParent).CompIntPixRect;
    end else
      Assert( False, 'Scope not given!' );

    case ACoordsType of

      cctLSU: begin
        dx := APoint.X * CurLSUPixSize;
        dy := APoint.Y * CurLSUPixSize;
      end; // cctLSU: begin

      cctmm: begin
        dx := APoint.X * mmPixSize.X;
        dy := APoint.Y * mmPixSize.Y;
      end; // cctmm: begin

      cctPix: begin
        dx := APoint.X * PixPixSize.X;
        dy := APoint.Y * PixPixSize.Y;
      end; // cctPix: begin

      cctPercent: begin
        dx := APoint.X * (ScopeRect.Right  - ScopeRect.Left) / 100;
        dy := APoint.Y * (ScopeRect.Bottom - ScopeRect.Top) / 100;
      end; // cctPercent: begin

      else begin // just to avoid warning
        dx := 0;
        dy := 0;
      end; // else begin // to avoid warning

    end; // case ACoordsType of

    if ccfConvSize in AConvFlags then // APoint is size in given Units
    begin
      Result.X := Round( dx );
      Result.Y := Round( dy );
    end else  //************************ APoint is coords in given Units
    begin
      Result.X := Round( ScopeRect.Left + dx );
      Result.Y := Round( ScopeRect.Top  + dy );
    end;

  end; // end else // some Coords relative to DynParent.CompIntPixRect

  end; // with NGCont do
end; // function TN_UDCompVis.ConvToPix

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\ConvFromPix
//************************************************ TN_UDCompVis.ConvFromPix ***
// Convert given Integer Point in destination Canvas Pixel Coordinates to Float 
// Point in given Coordinates
//
//     Parameters
// APoint      - given Integer Point in destination Canvas Pixel Coordinates
// ACoordsType - resulting Point Coordinates type
// AConvFlags  - convertion flags (coordinates scope type)
// Result      - Returns converted Point in given Coordinates
//
function TN_UDCompVis.ConvFromPix( const APoint: TPoint;
                                      ACoordsType: TN_CompCoordsType;
                                      AConvFlags: TN_CoordsConvFlags ): TFPoint;
//
// Conv given integer DstOCanv Pixel point coords to float point coords of given
// type ( inverse convertion of ConvToPix with AConvType=cctPos )
//
var
  Size: integer;
  dx, dy: double;
  ScopeRect: TRect;
begin
  Result := FPoint( N_NotAFloat, 0 );
//  N_IAdd( 'CFP(NGCont): ' + IntToHex(integer(NGCont),6) ); // debug

  with NGCont, NGCont.DstOcanv do
  begin

  if ACoordsType = cctUser then // Self User Coords
  begin
    Result := N_AffConvI2FPoint( APoint, CompP2U );
  end else //********************* Some Coords relative to given Coords Scope
  begin
    if ccfSelfScope in AConvFlags then
      ScopeRect := CompIntPixRect
    else if ccfRootScope in AConvFlags then
      ScopeRect := DstPixRect
    else if ccfParentScope in AConvFlags then
    begin
      if crtfRootComp in CRTFlags then Exit; // Root Component
      ScopeRect := TN_UDCompVis(DynParent).CompIntPixRect;
    end else
      Assert( False, 'Scope not given!' );

    if ccfConvSize in AConvFlags then // APoint is size in given Units
    begin
      dx := APoint.X;
      dy := APoint.Y;
    end else  //************************ APoint is coords in given Units
    begin
      dx := APoint.X - ScopeRect.Left;
      dy := APoint.Y - ScopeRect.Top;
    end;

    case ACoordsType of

      cctLSU: begin
        Result.X := dx / CurLSUPixSize;
        Result.Y := dy / CurLSUPixSize;
      end; // cctLSU: begin

      cctmm: begin
        Result.X := dx / mmPixSize.X;
        Result.Y := dy / mmPixSize.Y;
      end; // cctmm: begin

      cctPix: begin
        Result.X := dx / PixPixSize.X;
        Result.Y := dy / PixPixSize.Y;
      end; // cctPix: begin

      cctPercent: begin
        Size := ScopeRect.Right  - ScopeRect.Left;
        if Size = 0 then
          Result.X := 50
        else
          Result.X := 100 * dx / Size;

        Size := ScopeRect.Bottom - ScopeRect.Top;
        if Size = 0 then
          Result.Y := 50
        else
          Result.Y := 100 * dy / Size;
      end; // cctPercent: begin

    end; // case ACoordsType of

  end; // end else // some Coords relative to DynParent.CompIntPixRect

  end; // with NGCont do
end; // function TN_UDCompVis.ConvFromPix

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\SetSelfPosByURect
//****************************************** TN_UDCompVis.SetSelfPosByURect ***
// Set Component Positionin User Coordinates
//
//     Parameters
// AURect - component new Rectangle in User Coordinates
//
// Component Static Coordinates should be changed.
//
procedure TN_UDCompVis.SetSelfPosByURect( const AURect: TFRect );
begin
  with PCCS()^ do
  begin
    BPCoords := AURect.TopLeft;
    LRCoords := AURect.BottomRight;
    BPXCoordsType := cbpUser;
    BPYCoordsType := cbpUser;
    LRXCoordsType := cbpUser;
    LRYCoordsType := cbpUser;

    SRSizeXType := cstNotGiven;
    SRSizeYType := cstNotGiven;
  end; // with PCCS()^ do
end; // procedure TN_UDCompVis.SetSelfPosByURect

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\SetSelfAngle
//*********************************************** TN_UDCompVis.SetSelfAngle ***
// Set Self Angle
//
//     Parameters
// APixTransfType - Pixel coords Transform Type
// ARotateAngle   - Component Rotate Angle in degree
//
// Component Static Coordinates should be changed.
//
procedure TN_UDCompVis.SetSelfAngle( APixTransfType: TN_CTransfType; ARotateAngle: float = 0 );
var
  TmpSize: float;
begin
  with PCCS()^ do
  begin

    if (PixTransfType <> ctfRotate90CCW) and (APixTransfType = ctfRotate90CCW) or
       (PixTransfType <> ctfRotate90CW)  and (APixTransfType = ctfRotate90CW) then
    begin // Swap X,Y Size
      TmpSize  := SRSize.X;
      SRSize.X := SRSize.Y;
      SRSize.Y := TmpSize;
    end;

    PixTransfType := APixTransfType;
    CCRotateAngle := ARotateAngle;
  end; // with PCCS()^ do
end; // procedure TN_UDCompVis.SetSelfAngle


  //*********************************** Draw methods

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\DebView
//**************************************************** TN_UDCompVis.DebView ***
// View Self in Debug Mode
//
procedure TN_UDCompVis.DebView();
var
  BordLineWidth: float;
  MarkRect: TRect;
begin
  with NGCont do
  begin

  if gcdfShowBorder in GCDebFlags then // draw borders in debug mode
//      DstOCanv.DrawPixRoundRect( CompOuterPixRect, Point(0,0), N_EmptyColor, 0, 0.001 );
      DstOCanv.DrawDashedRect( CompOuterPixRect, 2, $0, $00FFFF );

  if gcdfShowMarked in GCDebFlags then // draw Marked in debug mode
  begin
    if N_ActiveVTreeFrame.IsMarked( Self ) then
    begin
      MarkRect := CompIntPixRect;
      BordLineWidth := 2/DstOCanv.CurLLWPixSize;
      DstOCanv.DrawPixRoundRect( MarkRect, Point(0,0), N_EmptyColor, $CC, BordLineWidth );
      MarkRect := N_RectIncr( MarkRect, -3, -3 );
      DstOCanv.DrawPixRoundRect( MarkRect, Point(0,0), N_EmptyColor, $990000, BordLineWidth );
    end;
  end;

  end;
end; // end_of procedure TN_UDCompVis.DebView();

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\DrawAuxLine
//************************************************ TN_UDCompVis.DrawAuxLine ***
// Draw given auxiliary line using Component Coordinates Context
//
//     Parameters
// AAuxLine - records array (RArray) with auxiliary line parameters
//
procedure TN_UDCompVis.DrawAuxLine( AAuxLine: TK_RArray );
var
  i: integer;
  ParentRect: TRect;
  PixLine: TN_IPArray;
  CurPoint: TFPoint;
  PAttribs: TN_PPointAttr1;
begin
  if AAuxLine = nil then Exit;
  if AAuxLine.Alength() = 0 then Exit;
  if crtfRootComp in CRTFlags then Exit; // Root Component  // temporary?

  ParentRect := TN_UDCompVis(DynParent).CompIntPixRect;
  SetLength( PixLine, 6 ); // AuxLine can contain up to 6 points

  with TN_PAuxLine(AAuxLine.P)^ do
  begin
  //***** Calc PixLine - AuxLine Vertices Pixel Coords

  for i := 0 to ALNumPoints-1 do // along AuxLine Vertices
  begin
    CurPoint := PFPoint( TN_BytesPtr(@ALP1P2) + i*Sizeof(TFPoint) )^;
    PixLine[i] := ConvToPix( CurPoint, ALCType, [ccfParentScope] );
    if PixLine[i].X = N_NotAnInteger then Exit; // coords can not be calculated
  end;

  NGCont.DrawIntPolygon( @PixLine[0], ALNumPoints, N_EmptyColor, ALColor, ALWidth ); // Draw AuxLine

  //***** Draw Point Sign at first AuxLine Point
  PAttribs := TN_PPointAttr1(ALBPAttribs.P);
  if PAttribs <> nil then // Attribs are given
    NGCont.DrawPixPoint( PixLine[0], PAttribs );

  end; // with TN_PAuxLine(TBAuxLine.P)^ do

end; // end_of procedure TN_UDCompVis.DrawAuxLine

  //*********************************** Other methods

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\TN_UDCompVis\AddCompsUnderPoint
//***************************************** TN_UDCompVis.AddCompsUnderPoint ***
// Add Component to given Array if given Point is Component Internal point
//
//     Parameters
// APoint      - Point in Pixel Bufer Coordinates
// ACompsArray - Components Array to add
// Result      - Returns TRUE if Component was added to Components Array
//
function TN_UDCompVis.AddCompsUnderPoint( const APoint: TPoint;
                                var ACompsArray: TN_UDCompBaseArray ): boolean;
//
// Add Self to given ACompsArray if given APoint is Internal point of Self and
// APoint is not Inernal point of any children Return True, if Self was added to
// ACompsArray
//
var
  Leng: integer;
  PrevChild: TN_UDCompBase;
  InsideAnyChild, InsideCurChild: boolean;
begin
  Result := False;
  if PDP()^.CCompBase.CBSkipSelf <> 0 then Exit; // Skip Self with all children

//  N_s := ObjName; // debug
  CurChildInd := DirLength();
  InsideAnyChild := False;

  while True do // loop along all Children from Bottom Up
  begin
    PrevChild := GetPrevChild();
    if PrevChild = nil then Break;
    if not (PrevChild is TN_UDCompVis) then Continue; // skip not Visual Comps

    InsideCurChild := TN_UDCompVis(PrevChild).AddCompsUnderPoint( APoint, ACompsArray );
    InsideAnyChild := InsideAnyChild or InsideCurChild;
  end; // while True do // loop along all Children from Bottom Up

  Result := InsideAnyChild;

  if not InsideAnyChild then // APoint is not Inernal point of any children
  begin
    if IsInternalPoint( APoint ) then // add self to ACompsArray
    begin
      Leng := Length(ACompsArray);
      SetLength( ACompsArray, Leng+1 );
      ACompsArray[Leng] := Self;
      Result := True;
    end; // if IsInternalPoint( APoint ) then
  end; // if not InsideSomeChild then // APoint is not Inernal point of any children
end; // end_of function TN_UDCompVis.AddCompsUnderPoint


  //*********************************** Obsolete methods *****************
  //*** (should be removed after removing theirs usage in obsolete code)



//********************************  Global procedures  ********************

//****************************************************** N_RegSetParamsFunc ***
// Register SetParams Function
//
procedure N_RegSetParamsFunc( AFuncName: string; ASPFunc: TN_SetParamsFunc );
begin
  K_RegListObject( TStrings(N_SetParamsFuncs), AFuncName, TObject(ASPFunc) );
end; //*** end of procedure N_RegSetParamsFunc

//******************************************************** N_SetParamsFunc1 ***
// Test SetParams Function
//
function N_SetParamsFunc1(): integer;
begin
  Result := 0;
end; //*** end of function N_SetParamsFunc1

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\N_GetUserParInfo
//******************************************************** N_GetUserParInfo ***
// Get User Parameter Info by given Value Records Array field
//
//     Parameters
// AUPValue  - User Parameter Value Records Array Object
// AUPType   - resulting User Parameter Value type enumeration
// ANumElems - resulting User Parameter Value number of elements
//
procedure N_GetUserParInfo( AUPValue: TK_RArray; out AUPType: TN_UserParamType;
                                                   out ANumElems: integer );
var
  AttrsTypeName, ElemTypeName: string;
begin
  AUPType := uptNotDef;
  ANumElems := -1;
  if AUPValue = nil then Exit;

  ANumElems := AUPValue.ALength();

  if AUPValue.AttrsSize > 0 then // some special type
  begin
    AttrsTypeName := K_GetExecTypeName( AUPValue.AttrsType.All );
    if AttrsTypeName = 'TK_CSDBAttrs' then // Data Block
      AUPType := uptDataBlock
    else if AttrsTypeName = 'TK_CSDimAttrs' then // Codes SubDimension
      AUPType := uptCSDim;
  end else // AUPValue.AttrsSize = 0
  begin
    ElemTypeName := K_GetExecTypeName( AUPValue.ElemType.All );
    if ElemTypeName = 'TN_TimeSeriesUP' then
      AUPType := uptTimeSeries
    else if ElemTypeName = 'TN_Boolean4' then
      AUPType := uptBoolean4
    else
      AUPType := uptBase;
  end;
end; //*** end of procedure N_GetUserParInfo

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\N_GetUserParPtr
//********************************************************* N_GetUserParPtr ***
// Get pointer to User Parameter Data Structure by given Name and Component 
// Records Array
//
//     Parameters
// ACompRArray - Component Static or Dynamic Records Array
// AUPName     - User Parameter Name
// Result      - Returns pointer to User Parameter Data Structure or nil if User
//               Parameter not found.
//
// ACompRArray is Component Records Array with Static (Component.R) or Dynamic 
// (Component.DynPar) Parameters.
//
function N_GetUserParPtr( ACompRArray: TK_RArray; AUPName: string ): TN_POneUserParam;
var
  i: integer;
  UserParams: TK_RArray;
  POneUP: TN_POneUserParam;
begin
  Result := nil;
  if ACompRArray = nil then Exit;

  UserParams := TN_PRCompBase(ACompRArray.P())^.CCompBase.CBUserParams;

  for i := 0 to UserParams.AHigh() do // loop along all User Params
  begin
    POneUP := TN_POneUserParam(UserParams.P( i ));
    if POneUP^.UPName = AUPName then // found
    begin
      Result := POneUP;
      Exit;
    end;
  end; // for i := 0 to UserParams.AHigh() do // loop along all User Params
end; // end_of function N_GetUserParPtr

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\N_GetUserParBoolValue
//*************************************************** N_GetUserParBoolValue ***
// Get Component User Parameter Boolean Value
//
//     Parameters
// ACompRArray - Component Static or Dynamic Records Array
// AUPName     - User Parameter Name
// Result      - Returns TRUE if User Parameter exists, it's Type is Byte or 
//               Integer (number of appropriate "Integer" Types may be 
//               extpanded) and it's Value is not equal to zero, otherwise FALSE
//               should be returned.
//
// ACompRArray is Component Records Array with Static (Component.R) or Dynamic 
// (Component.DynPar) Parameters.
//
function N_GetUserParBoolValue( ACompRArray: TK_RArray; AUPName: string ): Boolean;
var
  UPRArray: TK_RArray;
  POneUserParam: TN_POneUserParam;
begin
  Result := False;
  POneUserParam := N_GetUserParPtr( ACompRArray, AUPName );
  if POneUserParam = nil then Exit;

  UPRArray := POneUserParam^.UPValue;
  if UPRArray = nil then Exit;

  if UPRArray.ALength() < 1 then Exit;

  if UPRArray.ElemSType = ord(nptByte) then
  begin
    if PByte(UPRArray.P())^ = 0 then Exit;
  end else if (UPRArray.ElemSType = ord(nptInt)) or
              (UPRArray.ElemSType = N_SPLTC_Boolean4) then
  begin
    if PInteger(UPRArray.P())^ = 0 then Exit;
  end else // some other type (not Byte or Integer)
    Exit;

  Result := True; // Byte or Integer type and <> 0
end; // end_of function N_GetUserParBoolValue

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\N_CGetUserParPtr(TypeName)
//********************************************** N_CGetUserParPtr(TypeName) ***
// Create new or get existing Component User Parameter Data Structure
//
//     Parameters
// ACompRArray - Component Static or Dynamic Records Array
// AUPName     - User Parameter Name
// AUPDescr    - User Parameter description
// AUPTypeName - User Parameter Value Records Array Elements Type Name
// ANumElems   - number of Elements in User Parameter Value Records Array
// Result      - Returns pointer to User Parameter Data Structure
//
// ACompRArray is Component Records Array with Static (Component.R) or Dynamic 
// (Component.DynPar) Parameters.
//
function N_CGetUserParPtr( ACompRArray: TK_RArray; AUPName, AUPDescr, AUPTypeName: string;
                                        ANumElems: integer ): TN_POneUserParam;
begin
  Result := N_CGetUserParPtr( ACompRArray, AUPName, AUPDescr,
                                K_GetTypeCodeSafe( AUPTypeName ), ANumElems );
end; // end_of function N_CGetUserParPtr(TypeName)

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\N_CGetUserParPtr(TypeCode)
//********************************************** N_CGetUserParPtr(TypeCode) ***
// Create new or get existing Component User Parameter Data Structure
//
//     Parameters
// ACompRArray - Component Static or Dynamic Records Array
// AUPName     - User Parameter Name
// AUPDescr    - User Parameter description
// AUPTypeCode - User Parameter Value Records Array Elements Type Code
// ANumElems   - number of Elements in User Parameter Value Records Array
// Result      - Returns pointer to User Parameter Data Structure
//
// ACompRArray is Component Records Array with Static (Component.R) or Dynamic 
// (Component.DynPar) Parameters.
//
function N_CGetUserParPtr( ACompRArray: TK_RArray; AUPName, AUPDescr: string;
             AUPTypeCode: TK_ExprExtType; ANumElems: integer ): TN_POneUserParam;
begin
  Result := N_GetUserParPtr( ACompRArray, AUPName );

  if Result <> nil then // check UserPar Element Type
    Assert( Result^.UPValue.ElemSType = AUPTypeCode.DTCode, 'Bad UP Type!' )
  else // Result = nil, needed User Param was not created, create it
    Result := N_AddNewUserPar( ACompRArray, AUPName, AUPDescr, AUPTypeCode, ANumElems );
end; // end_of function N_CGetUserParPtr(TypeCode)

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\N_AddNewUserPar(TypeName)
//*********************************************** N_AddNewUserPar(TypeName) ***
// Add new Component User Parameter Data Structure
//
//     Parameters
// ACompRArray - Component Static or Dynamic Records Array
// AUPName     - User Parameter Name
// AUPDescr    - User Parameter description
// AUPTypeName - User Parameter Value Records Array Elements Type Name
// ANumElems   - number of Elements in User Parameter Value Records Array
// Result      - Returns pointer to added User Parameter Data Structure
//
// ACompRArray is Component Records Array with Static (Component.R) or Dynamic 
// (Component.DynPar) Parameters.
//
function N_AddNewUserPar( ACompRArray: TK_RArray; AUPName, AUPDescr, AUPTypeName: string;
                                        ANumElems: integer ): TN_POneUserParam;
begin
  Result := N_AddNewUserPar( ACompRArray, AUPName, AUPDescr,
                                K_GetTypeCodeSafe( AUPTypeName ), ANumElems );
end; // end_of function N_AddNewUserPar(TypeName)

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\N_AddNewUserPar(TypeCode)
//*********************************************** N_AddNewUserPar(TypeCode) ***
// Add new Component User Parameter Data Structure
//
//     Parameters
// ACompRArray - Component Static or Dynamic Records Array
// AUPName     - User Parameter Name
// AUPDescr    - User Parameter description
// AUPTypeCode - User Parameter Value Records Array Elements Type Code
// ANumElems   - number of Elements in User Parameter Value Records Array
// Result      - Returns pointer to added User Parameter Data Structure
//
// ACompRArray is Component Records Array with Static (Component.R) or Dynamic 
// (Component.DynPar) Parameters.
//
function N_AddNewUserPar( ACompRArray: TK_RArray; AUPName, AUPDescr: string;
             AUPTypeCode: TK_ExprExtType; ANumElems: integer ): TN_POneUserParam;
var
  NewInd: integer;
  PUserParams: TK_PRArray;
begin
  Result := nil;
  if ACompRArray = nil then Exit;

  PUserParams := @(TN_PRCompBase(ACompRArray.P())^.CCompBase.CBUserParams);
  if PUserParams^ = nil then // create UserParam
  begin
    PUserParams^ := K_RCreateByTypeName( 'TN_OneUserParam', 0, N_CurCreateRAFlags );
  end;

  NewInd := PUserParams^.ALength();
  PUserParams^.ASetLength( NewInd + 1 );
  Result := TN_POneUserParam(PUserParams^.P( NewInd ));

  with Result^ do
  begin
    UPName  := AUPName;
    UPDescr := AUPDescr;
    UPValue := K_RCreateByTypeCode( AUPTypeCode.All, ANumElems, N_CurCreateRAFlags );
    UPValue.InitElems( 0, ANumElems );
  end; // with Result^ do
end; // end_of function N_AddNewUserPar(TypeCode)

//##path N_Delphi\SF\N_Tree\N_CompBase.pas\N_CreateExpParams
//******************************************************* N_CreateExpParams ***
// Create and initialize Export Parameters
//
//     Parameters
// AComp - Component to Export Parameters create
//
procedure N_CreateExpParams( AComp: TN_UDCompBase );
var
  PCCompBase: TN_PCCompBase;
begin
  PCCompBase := @(TN_PRCompBase(AComp.R.P())^.CCompBase);
  PCCompBase^.CBExpParams := K_RCreateByTypeName( 'TN_ExpParams', 1 );

  with TN_PExpParams(PCCompBase^.CBExpParams.P)^ do // Initialize Export Params
  begin
    if AComp is TN_UDCompVis then
      EPMainFName := '(#OutFiles#)Result.emf';

    if AComp is TN_UDWordFragm then
      EPMainFName := '(#OutFiles#)Result.doc';

  end; // with TN_PExpParams(PCCompBase^.CBExpParams.P)^ do
end; // end of procedure N_CreateExpParams


//##path N_Delphi\SF\N_Tree\N_CompBase.pas\N_PrepExpParams
//********************************************************* N_PrepExpParams ***
// Prepare Export Parameters by given source Export Parameters
//
//     Parameters
// APInpEP - pointer to source Export Parameters
// APOutEP - pointer to resulting Export Parameters
//
// All defined (non zero) fields are copied from source Export Parameters.
//
procedure N_PrepExpParams( APInpEP, APOutEP: TN_PExpParams );
begin
  if APInpEP = nil then Exit; // nothing to do

//  if APInpEP^.EPCompExpMode  <> cemDefault  then APOutEP^.EPCompExpMode  := APInpEP^.EPCompExpMode;
  APOutEP^.EPImageExpMode  := APInpEP^.EPImageExpMode;
  APOutEP^.EPImageExpFlags := APInpEP^.EPImageExpFlags;

  if APInpEP^.EPExecFlags <> [] then APOutEP^.EPExecFlags := APInpEP^.EPExecFlags;
  if APInpEP^.EPMainFName <> '' then APOutEP^.EPMainFName := APInpEP^.EPMainFName;
  if APInpEP^.EPFilesExt  <> '' then APOutEP^.EPFilesExt  := APInpEP^.EPFilesExt;

  N_PrepImageFilePar( @APInpEP^.EPImageFPar, @APOutEP^.EPImageFPar );
  N_PrepTextFilePar ( @APInpEP^.EPTextFPar,  @APOutEP^.EPTextFPar );
//  N_PrepFile1Params ( @APInpEP^.EPFile1Par,  @APOutEP^.EPFile1Par );
end; // end of procedure N_PrepExpParams

//**************************************************** N_CreateRasterByComp ***
// Create Raster file with given AFileName and APixSize by the component
// fragment given by AURect in User Coords
//
procedure N_CreateRasterByComp( AComp: TN_UDCompVis; APixSize: TPoint;
                                       AURect: TFRect; AFileName: string );
var
  NeededAspect: double;
  ExpParams: TN_ExpParams;
  SavedCCoords: TN_CompCoords;
  FinalURect: TFREct;
begin
  //***** Calc FinalURect and ClipURect by given params
  NeededAspect := APixSize.Y / APixSize.X;
  FinalURect := N_IncRectByAspect( AURect, NeededAspect );

  //***** Prepare ACompCoords
  SavedCCoords := AComp.PCCS^; // save for restoring after Execute
  with AComp.PCCS^ do
  begin
    SRSize       := FPoint( APixSize );
    SRSizeAspect := 0;
    CompUCoords  := FinalURect;
    SRSizeXType  := cstPixel;
    SRSizeYType  := cstPixel;
    UCoordsType  := cutGivenAnyAsp;
  end; // with AComp.PCCS^ do

{
  //***** Prepare Map Clip coords if ClipURect component exists
  ClipComp := AComp.DirChild( 0 );
  if (ClipComp is TN_UDPanel) then
    with TN_UDPanel(ClipComp) do
    begin
      SavedCCoords2 := PCCS^; // save for restoring after Execute
      with PCCS^ do
      begin
        BPCoords      := ClipURect.TopLeft;
        BPXCoordsType := cbpUser;
        BPYCoordsType := cbpUser;
        LRCoords      := ClipURect.BottomRight;
        LRXCoordsType := cbpUser;
        LRYCoordsType := cbpUser;
        SRSizeXType   := cstNotGiven;
        SRSizeYType   := cstNotGiven;
        CompUCoords   := ClipURect;
        UCoordsType   := cutGivenAnyAsp;
      end; // with PCCS^ do
    end; // if (ClipComp is TN_UDPanel) then
}
  //***** Prepare Export Params
  FillChar( ExpParams, Sizeof(ExpParams), 0 );
  with ExpParams do
  begin
    EPMainFName := AFileName;
    EPImageFPar.IFPJPEGQuality := 100;
  end; // with ExpParams do

  N_MEGlobObj.NVGlobCont.ExecuteRootComp( AComp, [], nil, nil, @ExpParams );

  AComp.PCCS^ := SavedCCoords; // restore

//  if (ClipComp is TN_UDPanel) then
//    TN_UDPanel(ClipComp).PCCS^ := SavedCCoords2; // restore
end; // end of procedure N_CreateRasterByComp


{
Initialization
  N_DefExpParams.EPImageFPar := N_DefImageFilePar;

  N_ClassRefArray[N_UDCompBaseCI] := TN_UDCompBase;
  N_ClassTagArray[N_UDCompBaseCI] := 'BaseComp';

  N_ClassRefArray[N_UDCompVisCI]  := TN_UDCompVis;
  N_ClassTagArray[N_UDCompVisCI]  := 'VisualComp';

  N_RegSetParamsFunc( 'TestFunc1', N_SetParamsFunc1 );
}

end.
