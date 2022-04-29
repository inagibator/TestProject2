unit K_UDT1;
{$ASSERTIONS ON}

interface
uses Windows, Forms, Controls, ComCtrls, Classes, ImgList, Inifiles,
     StdCtrls, ActnList, SysUtils, Graphics, Types,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND CompilerVersion >= 26.0}
     N_Types,
     K_CLib0, K_Types,
     K_VFunc, K_SBuf, K_STBuf, K_parse, K_BArrays, K_UDConst, K_IWatch;

//{$DEFINE N_DEBUG}
//##/*
type TK_VTreeVNodeDelFlags = set of ( // VTree/VNode deletion flags set
  K_fNTPDelVNode,    // VNode deletion is in progress
  K_fNTPDelVTree1,   // VTree1 deletion is in progress
  K_fNTPRebuildVTree // Rebuild Vtree Mode
);

type TK_TreeNodeAddMode = (  // TreeNode addition mode enumeration for given VNode
  K_tnmNodeInsert,        // insert before current TreeNode
  K_tnmNodeAddChild,      // add child TreeNode to current
  K_tnmNodeAdd,           // add TreeNode to current level
  K_tnmNodeAddChildFirst, // add first child TreeNode to current
  K_tnmNodeAddNone        // skip adding TreeNode
);

type  TK_PathListFlags = Set of (
  K_plfSorted,
  K_plfReversParh
);

type TK_CopySubTreeFlags = Set of ( // Copy IDB Subnet flags set
  K_mvcCopySelf,       // copy Object Self Fields
  K_mvcCopyChildRefs,  // copy Object Childs References
  K_mvcCopyChilds,     // copy Object Childs
  K_mvcCopyFolders,    // copy Object Childs if they are User Folders ()
  K_mvcCopyOwnedChilds // copy only Childs for which Object is Owner
);
type TK_PCopySubTreeFlags = ^TK_CopySubTreeFlags;
//##*/

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_LoadUDDataError
type TK_LoadUDDataError = class(Exception);
//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_LoadUDFileError
type TK_LoadUDFileError = class(Exception);

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDBaseConsistency
type TK_UDBaseConsistency = class(Exception);

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_VNodeStateFlags
type TK_VNodeStateFlags = Set of ( // IDB Object Visual Node representation (VNode) state flags set
  K_fVNodeStateMarked,     // VNode is marked
  K_fVNodeStateSelected,   // VNode is selected
  K_fVNodeStateCurrent,    // VNode is Current
  K_fVNodeStateDeleted,    // VNode deletion is in progress
  K_fVNodeStateNotExanded, // VNode was "virtually" expanded
  K_fVNodeStateSpecMark0,  // VNode was specialy marked 0
  K_fVNodeStateSpecMark1   // VNode was specialy marked 1
);

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDObjNameType
type  TK_UDObjNameType = ( // IDB Object Identifier enumeration for IDB Object designation
  K_ontObjName,   // use ObjName field
  K_ontObjAliase, // use ObjAliase field
  K_ontObjUName   // use ObjAliase field or ObjName field if ObjAliase is empty
);
//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_ClearRefInfoFlags
//**************************************************** TK_ClearRefInfoFlags ***
// Clear info "garbage" after serialization of IDB Subnet flags set
//
type  TK_ClearRefInfoFlags = Set of (
  K_criClearFullSubTree,    // Clear Full IDB Data Subnet (not only Ownership 
                            // Subtree)
  K_criClearMarker,         // Clear Marker fields in all Nodes in IDB Data 
                            // Subnet
  K_criClearChangedInfoFlag // Clear Changed Node Data FLags in all Nodes in IDB
                            // Data Subnet
);

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDOperateFlags
type  TK_UDOperateFlags = Set of ( // IDB Object miscellaneous processing flags set
  K_udoUNCDeletion, // unconditional deletion flag (remove reference to Child 
                    // Node from it's Owner Node even if other References to 
                    // Node exist in IDB Data Net
  K_udoDelWarning   // show warning during deletion Object from it's Owner 
                    // Object if other References to deleting Node remain in IDB
                    // Data Net
);

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_BuildUDNodeIDFlags
type  TK_BuildUDNodeIDFlags = Set of ( // IBD Object Build ID control flags set
  K_bnfUseObjAddr,   // use Object Memory Address
  K_bnfUseObjName,   // use ObjName field
  K_bnfUseObjUName,  // use ObjAliase field or ObjName field if ObjAliase is 
                     // empty
  K_bnfUseObjAliase, // use ObjAliase field
  K_bnfUseObjType,   // use Object Type Name
  K_bnfUseObjRType,  // use Object User Data Type Name (if TK_UDArray)
  K_bnfUseObjVType   // use Object Vector Element Data Type Name (if 
                     // TK_UDVector)
);

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_PathTrackingFlags
type TK_PathTrackingFlags = Set of ( // Path tracking to given IDB Object flags set
  K_ptfSkipScanOwners,     // skip scan IDB Owners Subtree only
  K_ptfScanRAFields,       // scan IDB Object User Data Records Array 
                           // (TK_UDRArray)
  K_ptfScanRAFieldsSubTree,// scan IDB Object User Data Records Array and 
                           // Subtnets of found IDB Objects References 
                           // (TK_UDRArray)
  K_ptfSkipOwnersAbsPath,  // skip abolute path if relative path building in IDB
                           // Owners Subtree is impossible
  K_ptfTryAltRelPath,      // try alternate relative path if relative path 
                           // building in IDB Owners Subtree is impossible
  K_ptfBreakByRefPath      // break relative path tracking by IDB object RefPath
                           // field
);

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_DEReplaceResult
type TK_DEReplaceResult = ( // IDB Node Directory Entry Replace Result enumeration
  K_DRisEqual,         // entry new data is equal to old data
  K_DRisOK,            // entry data replace is done
  K_DRisIndError,      // wrong entry index is given
  K_DRisObjProtected,  // entry referenced Object is protected
  K_DRisDEProtected    // entry it self is protected
); //*** end of TK_DEReplaceResult = enum
  {,
  K_DRisVCodeError, K_DRisNoChildToDelete,
  K_DRisChangeCodeError,
  K_DRisArrayTypeError, K_DRisArrayIndexError, K_DRisDataRefError,
  K_DRisDataTypeError, K_DRisDataArrayTypeError,
  K_DRisDataArrayClassError, K_DRisDataArrayRangeError,
  K_DRisDataVectorRangeError
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_DEFieldID
type TK_DEFieldID = ( // IDB Object Child Directory Entry Fields enumeration
//*** don't change enum elenments order
  K_DEFisCode,   // entry Integer Code
  K_DEFisFlags,  // entry miscellaneous Flags
  K_DEFisUFlags, // entry Update Flags
  K_DEFisVFlags, // entry Visual Flags
  K_DEFisName,   // entry Name
  K_DEFisChild,  // entry Child Node Reference
  K_DEFisVCode,  // entry runtime Visual Code
  K_DEFisVCounter// entry runtime Visualizations counter (for VCode use control)
); //*** end of TK_DEFieldID = enum

{
//***** all possible types of DirEntry data
type TK_DEDataType = (
  K_isChildRef,    // simple reference to child UDBase
  K_isVDataRef,    // reference to data vector
  K_isADataRef,    // reference to data array
  K_isIDataRef,    // reference to element of data array
  K_isFDataRef,    // fast reference to element of data vector
  K_isDataRef,     // reference to element of data vector
//*** don't change enum elenments order
  K_isDataInteger, // Integer element of data vector
  K_isDataString,  // String element of data vector
  K_isDataDouble,  // Double element of data vector
  K_isDataUInt1,   // Byte element of data vector
  K_isDataInt2,    // Short element of data vector
  K_isDataInt64,   // Int64 element of data vector
  K_isDataHex,     // Integer element of data vector Hex visualised
  K_isDataBool,    // Boolean element of data vector
  K_isDataInt1,    // SmallInt element of data vector
  K_isDataUInt2,   // Word element of data vector
  K_isDataUInt4,   // LongWord element of data vector
  K_isDataFloat,   // Single element of data vector
  K_isDataDate,    // Date value
  K_isDataUndef    // Undefined data
); //*** end of TK_DEDataType = enum
//type TK_DEDataTypeFlagSet = Set of TK_DEDataType;
}

type TK_VFlags       = Word;     // visual flags
type TK_UDFlags      = LongWord; // update Dir flags
type TK_UEFlags      = LongWord; // update Entry flags
type TK_UpdateFlags = record     // update tree routines flag
  case Integer of
    0: (DirFlags : TK_UDFlags; EntryFlags: TK_UEFlags);
    1: (AllBits: Int64);
end;  //*** end of type TK_UpdateFlags = record

type TK_DEUFlags   = array [0..0] of TK_UEFlags;     // update dir entry flags
type TK_DEVFlags   = array [0..1] of TK_VFlags;      // visual dir entry flags
type TK_ObjUFlags  = array [0..0] of TK_UpdateFlags; // update obj flags
type TK_ObjVFlags  = array [0..1] of TK_VFlags;      // visual obj flags

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDDir
type TK_UDDir = record   // IDB Object Directory runtime data
    UDDCapacity : Integer;  // capacity
    UDDCount    : Integer;  // used entries counter
    UDDMaxVCode : LongWord; // runtime maximal VCode (uniq VCode creation 
                            // parameter)
    UDDFields   : array [0..Ord(K_DEFisVCounter)] of TN_IArray; // synchronous
                                                                // arrays of 
                                                                // entries 
                                                                // fields
end; //*** end of type TK_UDDir = record

type  TN_UDBase    = class;  // forvard reference
{type}TN_VNode     = class;  // forvard reference
{type}TN_VTree     = class;  // forvard reference
{type} TK_NewUDNodeFunc = function( Index : Integer ) : TN_UDBase of object;
//{type} TK_TestUDNodeFunc = function( UDTest : TN_UDBase ) : Boolean;

{type} TK_TestUDChildFunc = function( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                  ChildInd : Integer; ChildLevel : Integer;
                                  const FieldName : string = '' ) : TK_ScanTreeResult of object;
{type} TN_VNArray = array of TN_VNode; // TN_UDBase.VNodes type

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_DirEntryPar
{type} TN_DirEntryPar = record // IDB Object Directory Entry parameters
    Child : TN_UDBase;         // Child Object Reference
    Parent: TN_UDBase;         // Parent Object Reference
    DirIndex: Integer;         // Index in Directory
    DEFlags: LongWord;         // Entry Application flags
    DEVFlags: TK_DEVFlags;     // Entry Visul flags
//##/*
    DEUFlags: TK_DEUFlags;     // Entry Update flags
//##*/
    DEName: string;            // Entry Name
    DECode: Integer;           // Entry Code
    VCode      : LongWord;     // Entry runtime unique Visual Code
end; //*** end of type TN_DirEntryPar = record
{type} TK_PDirEntryPar = ^TN_DirEntryPar;
{type} TK_DEArray = array of TN_DirEntryPar;

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDFilterItemExprCode
{type}  TK_UDFilterItemExprCode = ( // IDB Objects select filter items expression logical operations
  K_ifcAnd,    // logical AND
  K_ifcOr,     // logical OR
  K_ifcNotAnd, // logical NOT_AND
  K_ifcNotOr   // logical NOT_OR
  );
//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDFilterItem
{type}  TK_UDFilterItem = class( TObject ) // IDB Objects select filter items base class
  ExprCode : TK_UDFilterItemExprCode;  // filter expression code
      private
      public
//##/*
  constructor Create;
//##*/
  function    UDFITest( const DE : TN_DirEntryPar ) : Boolean; virtual; abstract;
end; //*** end of type TK_UDFilterItem = class( TObject )

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDFilter
{type}  TK_UDFilter = class( TList ) // IDB Objects select filters base class
      private
      public
//##/*
  destructor  Destroy; override;
//##*/
  procedure   AddItem( FilterItem : TK_UDFilterItem );
  procedure   FreeItems( Ind : Integer = 0; ACount : Integer = 0 );
  function    UDFTest( const DE : TN_DirEntryPar ) : Boolean;
end; //*** end of type TK_UDFilter = class( TObject )

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UniqChildNameFlagSet
{type} TK_UniqChildNameFlagSet = Set of ( // IDB Object Directory Build Uniq Child Object Name field flags set
  K_sunUseMarked,   // uniq Name field among marked Child Nodes
  K_sunUseOwnChilds // uniq Name field among Own Child Nodes ()
);

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase
//*************************************************************** TN_UDBase ***
// IDB Objects Base Class
//
// This class emplements a lot of methods needed for suitable access and 
// manipulation with IDB data. Some methods are virtual and are override in 
// subclasses.
//
{type} TN_UDBase = class( TObject )
    ObjLiveMark : Integer;  // Check Object Live Marker
      public
//*** Serialized Fields
    ObjFlags   : LongWord;  // miscellaneous flags
    ObjDateTime: TDateTime; // date field (application could use as Object last 
                            // modification date)
//##/*
    ObjUFlags  : TK_ObjUFlags; // Update Child Entry common flags
//##*/
    ObjVFlags  : TK_ObjVFlags; // Visul Child Entry common flags
    ObjName    : string;    // name usually uniq in Child Objects Directory
    ObjAliase  : string;    // caption usually used for IDB Subnet visual 
                            // represention
    ObjInfo    : string;    // additional text info, used as Hint text  for IDB 
                            // Subnet visual represention (for Separately Loaded
                            // Subnet Root Objects - Subtree serialization File 
                            // Name)
    ImgInd     : Integer;   // self Icon index
    RefPath    : string;    // self absolute path in IDB Data Net Ownership Tree
                            // (runtime field)
    RefIndex   : Integer;   // self index in Serialization References Table 
                            // (used for deserialization acceleration)
//*** end of Serialized Fields
//*** Runtime Fields
    ClassFlags: LongWord;   // runtime field for IDB Data Subnets special 
                            // processing
                            //#F
                            // bits0-7  - Class Index (index in N_ClassRefArray and N_ClassTagArray)
                            // bits8-31 - runtime flags for IDB Data Subnets special processing
                            //#/F
    RefCounter : integer;   // References Counter in IDB Data Net (runtime 
                            // field)
    NDir       : ^TK_UDDir; // Child Objects Directory data
    LastVNode  : TN_VNode;  // reference to last Object VNode in it's VNodes 
                            // list (runtime field)
    Marker     : Integer;   // runtime marker field for IDB Data Subnets 
                            // processing
    Owner      : TN_UDBase; // reference to Owner Object (runtime field)
      private
  function  RestoreDRefToChild( AInd : Integer; AChild : TN_UDBase ) : TN_UDBase;

//  procedure AddSubTreeToSbuf(  SBuf: TN_SerialBuf );
//  procedure GetSubTreeFromSBuf( SBuf: TN_SerialBuf );

  function  AddDEToText   ( ASBuf: TK_SerialTextBuf; var ADE : TN_DirEntryPar;
                out AChildTag : string ) : boolean;

  function  AddSelfToRefTable( ) : Boolean;
  function  PrepSerializedChildsScale( SInd, HInd : Integer;
                                         var AddChildsScale : TN_BArray ) : Integer;

  procedure RemoveChildVNodes( const ADE : TN_DirEntryPar );
  procedure SLSRListLoad( APrevSLSRList : TList );
  function  SLSRListBuildScan( UDParent: TN_UDBase;
                 var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                 const FieldName: string ) : TK_ScanTreeResult;
  function  AddLoadingToSLSRList : Boolean;
  procedure SLSRSetJoinArchFlag;
  procedure SLSRListPrepareToSave( ASLSRoots : TList = nil );
  function  ClearChangeSubTreeScan( UDParent: TN_UDBase;
                 var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                 const FieldName: string ) : TK_ScanTreeResult;
  function  SetChangeSubTreeScan( UDParent: TN_UDBase;
                 var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                 const FieldName: string ) : TK_ScanTreeResult;
  function  SetAbsentOwnersScan( UDParent: TN_UDBase;
                 var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                 const FieldName: string ) : TK_ScanTreeResult;
      protected
      public
//##/*
  constructor Create; virtual;
  destructor  Destroy; override;
//##*/
//  procedure   Delete( Parent : TN_UDBase = nil ); virtual;
  procedure UDDelete( AParent : TN_UDBase = nil );
//##/*
  procedure UDSafeDelete( AParent : TN_UDBase = nil );
//##*/

//*** virtual public methods
//##/*
  function  GetFieldPointer( const AFiledName : string ) : Pointer; virtual;
//##*/

//*** object directory managing routines
  function  DirHigh   : Integer;
  function  DirLength : Integer;
  procedure DirSetLength    ( ACount : Integer );
  function  DirChild        ( AInd : Integer; ADefChild : TN_UDBase = nil ) : TN_UDBase;
  function  PutDirChild     ( AInd : Integer; AChild : TN_UDBase) : Boolean;
  procedure PutDirChildSafe ( AInd : Integer; AChild : TN_UDBase );
  procedure PutDirChildV    ( AInd : Integer; AChild : TN_UDBase;
                              AVNodeFalgs : TK_VNodeStateFlags = [];
                              AVTree : TN_VTree = nil );
  procedure GetDirEntry     ( AInd : Integer; out   ADE : TN_DirEntryPar );
  function  PutDirEntry     ( AInd : Integer; const ADE : TN_DirEntryPar ) : TK_DEReplaceResult;
  function  AddDirEntry     ( const ADE : TN_DirEntryPar ) : Integer;
  function  IndexOfDEField  ( const AData;  AFieldID : TK_DEFieldID = K_DEFisChild;
                              AStartInd : Integer = 0  ) : Integer;
  function  ReplaceDirChild  ( AInd : Integer; ANewChild : TN_UDBase ) : TK_DEReplaceResult;

  function  RemoveDirEntry  ( AInd: Integer ) : TK_DEReplaceResult;

  procedure RemoveEqualChilds;

  function  GetDEFArrayPointer( AFieldID : TK_DEFieldID ) : Pointer;
  function  GetDEFieldPointer( AInd : Integer; AFieldID : TK_DEFieldID ) : Pointer;
  procedure GetDEField( AInd : Integer; var AValue; AFieldID : TK_DEFieldID );
  procedure PutDEField( AInd : Integer; AValue : Integer; AFieldID : TK_DEFieldID );

  function  IndexOfDECode( ADECode :Integer ) : Integer;

  procedure GetDirFieldArray( var AFieldsArray; AFieldID : TK_DEFieldID );
  function  InsertEmptyEntries( AInd : Integer; ACount: integer ): integer;
  function  RemoveEmptyEntries : integer;
  function  MoveEntries     ( ADInd, ASInd: Integer; ACount : Integer = 1 ) : Integer;

//*** owvner path routines
  function  BuildRefPath( ) : string;
  procedure ClearRefPath( UDRoot : TN_UDBase = nil );

//*** save/restore routines
  procedure AddFieldsToSBuf    ( ASBuf: TN_SerialBuf ); virtual;
  procedure GetFieldsFromSBuf  ( ASBuf: TN_SerialBuf ); virtual;
  procedure AddChildTreeToSBuf   ( ASBuf: TN_SerialBuf );
  procedure GetChildTreeFromSBuf ( ASBuf: TN_SerialBuf );

  procedure AddMetaFieldsToText    ( ASBuf: TK_SerialTextBuf;
                                     AAddObjFlags : Boolean = true );
  procedure GetMetaFieldsFromText  ( ASBuf: TK_SerialTextBuf );
  function  AddFieldsToText    ( ASBuf: TK_SerialTextBuf;
                                 AAddObjFlags : Boolean = true ) : Boolean; virtual;
  function  GetFieldsFromText  ( ASBuf: TK_SerialTextBuf ) : Integer; virtual;
  function  AddToText  ( ASBuf: TK_SerialTextBuf; ARefInfo : Boolean = true ) : boolean;
  function  GetFromText( ASBuf: TK_SerialTextBuf; AClass : TClass;
                                        out AUObj : TN_UDBase ) : Integer;

  procedure CopyMetaFields( ASrcObj: TN_UDBase );
  procedure CopyFields( ASrcObj: TN_UDBase ); virtual;
//  function  CopySubTree( SrcObj: TN_UDBase ) : TN_UDBase;
//  function  CopyChilds( SrcObj: TN_UDBase;
//                DirFlags : TK_UDFlags = K_fuDirMergeClearOld;
//                EntryFlags : TK_UEFlags = 0 ) : TN_UDBase;
//  procedure CopyChildsRefs( SrcObj: TN_UDBase );
//  procedure CopySubTree( SrcObj: TN_UDBase );
  procedure ReorderChilds( APIndex : PInteger; ACount : Integer;
                           AGetNewUDNode : TK_NewUDNodeFunc = nil );
  function  SameType( ACompObj: TN_UDBase ): boolean; virtual;
//##/*
  function  SameFields ( SrcObj: TN_UDBase; AFlags: integer ): boolean; virtual;
//##*/
  function  CompareFields ( ACompObj: TN_UDBase; AFlags: integer;
                            ANPath : string ) : Boolean; virtual;
  function  CompareTree   ( ACompObj: TN_UDBase; AFlags: integer = $FF;
                            ANPath : string = K_udpPathDelim ): Boolean;
//##/*
  procedure SaveToStrings ( Strings: TStrings; Mode: integer = 0 ); virtual;
//##*/
  function  IndexOfChildType( AClassFlags: Longword; AStart : Integer = 0;
                              ACount : Integer = 0 ): integer;
  function  IndexOfChildObjName ( AObjName: string;
                  AObjNameType : TK_UDObjNameType = K_ontObjName;
                  AStart : Integer = 0; ACount : Integer = 0 ): integer;
  function  DirChildByObjName( AObjName: string;
                  AObjNameType : TK_UDObjNameType = K_ontObjName;
                  AStart : Integer = 0; ACount : Integer = 0 ): TN_UDBase;
  function  IsDEProtected   ( const ADE: TN_DirEntryPar;
                              ACheckDE : Boolean = true ) : TK_DEReplaceResult;
  function  DeleteDirEntry  ( AInd : Integer; AVCode : Integer = 0;
                              ARemoveEntry : Boolean = true ) : TK_DEReplaceResult;
  function  DeleteOneChild  ( const AChild: TN_UDBase;
                              ARemoveEntry : Boolean = true ) : Integer;
  function  InsOneChild     ( AInd : Integer; AChild: TN_UDBase ) : Integer;
  function  GetEmptyDEInd   ( ASSInd : Integer = -1 ) : Integer;
  function  AddOneChild     ( AChild: TN_UDBase; ASSInd : Integer = -1 ) : TN_UDBase;
  function  AddOneChildV    ( AChild: TN_UDBase; AVNodeFalgs : TK_VNodeStateFlags = [];
                              AVTree : TN_VTree = nil; ASSind : Integer = -1 ) : TN_UDBase;
  procedure ClearChilds( ASInd : Integer = 0; ANewDirLength : Integer = -1;
                         AClearDir : Integer = 0 );
//##/*
  function  InsertOneChildBefore( APosChild, ANewChild: TN_UDBase ) : Integer; //*** may be not actual in future
  function  InsertOneChildAfter ( APosChild, ANewChild: TN_UDBase ) : Integer; //*** may be not actual in future
//##*/
  procedure PrepareObjName  ( ANameLength : Integer = 0; ASkipChars : string = '' );
  function  BuildUniqChildName( AName : string; AChild: TN_UDBase = nil;
                  AObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
  procedure SetUniqChildName( AChild: TN_UDBase;
                              AObjNameType : TK_UDObjNameType = K_ontObjName );
  procedure SetChildsUniqNames( AFlags : TK_UniqChildNameFlagSet = [];
                          AObjNameType : TK_UDObjNameType = K_ontObjName );
  procedure SetUniqDEName  ( AInd: integer );

  procedure AddChildsToText ( ASBuf: TK_SerialTextBuf; ATag : string = '';
                              AInd : Integer = 0; ACount : Integer = 0 );
  function  GetSubTreeFromText ( ASBuf: TK_SerialTextBuf; const AChildTag : string;
                                AChildInd: integer ) : boolean;
  procedure GetChildSubTreeFromText ( ASBuf: TK_SerialTextBuf; const ATag : string = '';
                                      ACheckStartTag : Boolean = true;
                                      AInd : Integer = 0; ACount : Integer = 0 );
  procedure SaveSubTreeSLSRToFile;
  procedure LoadSLSFromAnyFile;
  procedure SaveTreeToAnyFile( ARefsRootObj : TN_UDBase; const AFileName : string;
                               const AArchVersionInfo : string;
                               ASLSSaveFlags : TK_UDTreeLSFlagSet;
                               ATXTVersionFlag : Boolean );
  function  LoadTreeFromAnyFile ( const AFileName: string;
                                  ASLSLoadFlags : TK_UDTreeLSFlagSet = [];
                                  ALoadFromProtectedDFile : Boolean = false ) : Integer;
  procedure LoadTreeFromFile ( const AFileName : string;
                               ASLSLoadFlags : TK_UDTreeLSFlagSet = [];
                               ALoadFromProtectedDFile : Boolean = false );
  procedure SaveTreeToFile   ( const AFileName : string;
                               const AArchVersionInfo : string = '';
                               ASLSSaveFlags : TK_UDTreeLSFlagSet = [] );

  procedure LoadTreeFromTextFile ( const AFileName: string;
                                   ASLSLoadFlags : TK_UDTreeLSFlagSet = [] );
  procedure SaveTreeToTextFile ( const AFileName: string;
                                 ATextModeFlags : TK_TextModeFlags;
                                 const AArchVersionInfo : string = '';
                                 ASLSSaveFlags : TK_UDTreeLSFlagSet = [] );
  procedure SetDate (  );
//##/*
  function  GetDirUFlags ( DirFlags : TK_UDFLags;
                           FlagsNumber : Integer = 0 ) : TK_UDFLags;
  function  GetEntryUFlags( EntryFlags : TK_UEFLags;
                        FlagsNumber : Integer = 0 ) : TK_UEFLags;
  function  GetDEUFlags  ( const DE : TN_DirEntryPar; EntryFlags : TK_UEFLags;
                        FlagsNumber : Integer = 0 ) : TK_UEFLags;
//##*/
  function  Clone        ( ACopyFields : boolean = true ) : TN_UDBase; virtual;

  procedure ChangeVNodesState( AVNodeFalgs : TK_SetObjStateFlags = [];
                                       AVTree : TN_VTree = nil );
  procedure AddChildVNodes( AChildNum : Integer; AVNodeFalgs : TK_VNodeStateFlags = [];
                            AVTree : TN_VTree = nil );
  procedure RebuildVNodes( AMode : Integer = 0; AVCode : LongWord = 0 );
  procedure RebuildVTreeCheckedState( );
//  function  SearchObjByName( GlobalName: string ): TN_UDBase;
  function  GetDEByPathSegment( const APath : string; out ADE : TN_DirEntryPar;
                AObjNameType : TK_UDObjNameType = K_ontObjName ) : Boolean;
  function  GetDEByRPath( const ARPath : string; var ADE : TN_DirEntryPar;
                      AObjNameType : TK_UDObjNameType = K_ontObjName;
                      APathDepth : Integer = 0;
                      AContinue : Boolean = false ) : Integer;
  function  GetObjByRPath( const ARPath : string;
                AObjNameType : TK_UDObjNameType = K_ontObjName ) : TN_UDBase;
  function  GetPathToUDObj( ASrchObj : TN_UDBase;
                AObjNameType : TK_UDObjNameType = K_ontObjName ) : string; virtual;
{
  function  GetRefPathRoot : TN_UDBase;
  function  GetPathToObj( Node : TN_UDBase;
                          ObjNameType : TK_UDObjNameType = K_ontObjName;
                          PathTrackingFlags : TK_PathTrackingFlags = [] ) : string;
  function  GetOwnersPath( RootNode : TN_UDBase;
                           ObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
  function  GetRefPathToObj( Node : TN_UDBase; RetSelfPath : Boolean = false ) : string;
}
  function  GetMarker( AField : Integer = -1 ): Integer;
  procedure SetMarker( AValue : Integer; AField : Integer = -1 );
  function  IncMarker( AField : Integer = -1; AValue : Integer = 1 ): Integer;
  procedure MarkSubTree( AMarkType : Integer = 0; ADepth : Integer = -1;
                         AField : Integer = -1 ); virtual;
  procedure UnMarkSubTree( ADepth : Integer = -1; AField : Integer = -1 ); virtual;
  function  ScanSubTree( ATestNodeFunc : TK_TestUDChildFunc; ALevel : Integer = 0 ) : Boolean; virtual;
{
  procedure BuildSubTreeRelPaths( TestNodeFunc : TK_TestUDNode = nil;
              ObjNameType : TK_UDObjNameType = K_ontObjName );
  procedure ReplaceSubTreeRelPaths( CurPath : string = ''; SL : TStrings = nil;
        ObjNameType : TK_UDObjNameType = K_ontObjName ); virtual;
}
//##/*
  function  BuildID( BuildIDFlags : TK_BuildUDNodeIDFlags ) : string; virtual;
//##*/
//  procedure BuildSubTreeList( BuildIDFlags : TK_BuildUDNodeIDFlags; SL : TStrings;
//                    TestNodeFunc : TK_TestUDNodeFunc = nil );
  procedure ClearSubTreeRefInfo( ARoot : TN_UDBase = nil; AClearRefInfoFlags : TK_ClearRefInfoFlags = [] ); virtual;
  procedure ReplaceSubTreeRefObjs( ); virtual;
  function  BuildRefObj( ) : TN_UDBase;
  procedure BuildSubTreeRefObjs(  ); virtual;
  procedure ReplaceSubTreeNodes( ARepChildsArray : TK_BaseArray ); virtual;
  function  GetIconIndex(): Integer; virtual;
  function  CI(): Integer;
  function  GetUName( AObjNameType : TK_UDObjNameType = K_ontObjUName ) : string;
  procedure SetUName( AName : string; AObjNameType : TK_UDObjNameType = K_ontObjUName );
  procedure BuildChildsList( ASList : TStrings; AObjNameType : TK_UDObjNameType = K_ontObjUName );
//##/*
  function  IsSPLType( TypeName : string ) : Boolean; virtual;
//##*/
//*** High Level UDTree Modify Actions Interface
//##/*
  function  AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; virtual;
  function  RemoveSelfFromSubTree( PDE : TK_PDirEntryPar ) : Boolean; virtual;
  function  DeleteSubTreeChild( Index : Integer ) : Boolean; virtual;
  function  CanMoveChilds : Boolean; virtual;
  function  CanMoveDE( const DE : TN_DirEntryPar ): Boolean; virtual;
  function  GetSubTreeParent( const DE : TN_DirEntryPar ): TN_UDBase; virtual;
  procedure MoveSubTreeChilds( dInd, sInd: Integer; mcount : Integer = 1 ); virtual;
  function  CanAddChildByPar( AddPar : Integer = 0 ): Boolean; virtual;
  function  CanAddChild( Child : TN_UDBase ): Boolean; virtual;
  function  CanAddOwnChildByPar( CreatePar : Integer = 0 ): Boolean; virtual;
  function  SelfSubTreeCopy( CopyPar : TK_CopySubTreeFlags = [] ) : TN_UDBase; virtual;
  function  GetSubTreeChildDE( Ind : Integer; out DE : TN_DirEntryPar ) : Boolean; virtual;
  function  GetSubTreeChildHigh : Integer; virtual;
  function  CanCopyChild( PDE : TK_PDirEntryPar; var CopyPar : Integer ) : Boolean; virtual;
  function  CanCopySelf( CopyPar: TK_CopySubTreeFlags = [] ): Boolean; virtual;
  function  CountSubTreeReferences( Node : TN_UDBase ) : Integer; virtual;
  function  SelfCopy( CopyPar : TK_CopySubTreeFlags = [] ) : TN_UDBase; virtual;
  function  SelfSubTreeRemove : Boolean;
//  procedure SelfSubTreeList( BuildIDFlags : TK_BuildUDNodeIDFlags;
//                             SL : TStrings  );
  procedure SetSubTreeClassFlags( ASetFlags : LongWord );
//*** Code Space Interface
  function  CDimIndsConv( UDCD : TN_UDBase; PConvInds : PInteger;
                          RemoveUndefInds : Boolean ) : Boolean; virtual;
  procedure CDimLinkedDataReorder; virtual;
  procedure SLSRAddUses( var SLSRUsesList : TList );
  function  SLSRUsesListLoad( SLSRUsesList : TList ) : Boolean;
//##*/
  procedure SetChangedSubTreeFlag( ASetSLSRChange : Boolean = false );

end; //*** end of type TN_UDBase = class( TObject )
{type} TN_UDArray = array of TN_UDBase;
{type} TN_PUDBase = ^TN_UDBase;
{type} TN_PUDArray = array of TN_PUDBase;

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode
//**************************************************************** TN_VNode ***
// IDB Object visual representation (Visual Node - VNode) (each IDB Object 
// visual representation has own corresponding VNode )
//
{type} TN_VNode = class( TObject )
//##/*
      private
    VNLevel   : Integer; // visual representation level
    CID       : Int64;   // current time ID - to prevent second rebuilding
//    VNUDObjRC : Integer; // VNUDObj.RecCounter last value (for rebuild visual represention depended on RefCounter Value)
//##*/
  procedure GetTreeNodePos( const ADE : TN_DirEntryPar;
                            var ATreeNode : TTreeNode;
                            var ATreeNodeAddMode : TK_TreeNodeAddMode);
  function  IndexOfNextVisualisedChild( ASInd : Integer; var ADE : TN_DirEntryPar;
                                        ADir : Integer = 1 ) : Integer;
      public
    VNVFlags  : TK_VFlags;          // Self Visual Flags
    VNState   : TK_VNodeStateFlags; // Self State Flags
    VNTreeNode: TTreeNode;          // corresponding TreeView Node
    VNCode    : LongWord;           // corresponding Directory Entry VCode
    VNUDObj   : TN_UDBase;          // corresponding Directory Entry Child IDB
                                    // Object
    VNParent         : TN_VNode;    // reference to Self Parent VNode (VNode
                                    // corresponding to IDB Object Parent of
                                    // VNUDObj)
    LastVNChild      : TN_VNode;    // reference to Self Child VNode (VNode
                                    // corresponding to some IDB Object -
                                    // VNUDObj Child)
    PrevVNSibling    : TN_VNode;    // previous to Self Sibling VNode (VNode
                                    // corresponding to some IDB Object Sibling
                                    // to VNUDObj)
    PrevVNUDObjVNode : TN_VNode;    // previous VNode in the list of All VNodes
                                    // - visual representations of VNUDObj IDB
                                    // Object
    VNVTree          : TN_VTree;    // reference to VTree

  constructor Create ( const AVTree: TN_VTree; const AParent : TN_VNode;
                       const ADE: TN_DirEntryPar; var ATreeNode: TTreeNode;
                       ATreeNodeAddMode : TK_TreeNodeAddMode; AVLevel : integer;
                       AShowChilds : Boolean = true );

  procedure Delete ( ADeleteFlags: TK_VTreeVNodeDelFlags = [] );
  procedure Mark ();
  procedure UnMark ();
  procedure Toggle ( AMode : Integer = 0; AStateFlags : TK_VNodeStateFlags = [K_fVNodeStateMarked] );
  function  GetDirIndex : Integer;
  procedure GetDirEntry (var ADE : TN_DirEntryPar );
  function  GetParentUObj (): TN_UDBase;
  function  GetVParent () : TN_VNode;
  procedure UpdateTreeNodeCaption ();
  function  GetChildVNode( AChild : TN_UDBase; AVCode : LongWord ): TN_VNode;
  procedure CreateChildVNodes ( Ind : Integer = -1; AShowChilds : Boolean = true );
  procedure RebuildVNSubTree;
  procedure ReorderChildTreeNodes( AVFlags : Integer );
  function  GetSelfVTreePath( AObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
//##/*
  procedure SaveToStrings( Strings: TStrings; Mode: integer );
//##*/
end; //*** end of type TN_VNode = class( TObject )
{type} TK_TestDEFunc = function (const DE : TN_DirEntryPar ) : Boolean of object;

{type} TK_VNodeChangeStateFunc = procedure ( AVNode : TN_VNode; AChangedStateFlags : TK_SetObjStateFlags  ) of object;

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree
//**************************************************************** TN_VTree ***
// IDB Data Subnet visual representation (Visual Tree - VTree) (each IDB Data 
// Subnet visual representation has own corresponding VTree )
//
{type} TN_VTree = class( TObject )
      public
  TreeView   :  TTreeView; // TTreeView Pascal Object for IDB Data Subnet
                           // visualization

//*** add visual tree representation parameters
  VTDepth      : Integer;       // creating VTree depth (resulted Tree maximal 
                                // level number)
  VTFlagsNum   : Integer;       // IDB Objects individual visual flags set 
                                // number
  VTFlags      : TK_VFlags;     // visual flags common for all creating VNodes
  VTTestDEFunc : TK_TestDEFunc; // function of object for checking IDB directory
                                // entry before including to Visual Tree
  RootUObj   : TN_UDBase;       // root IDB Object

  VTCaptMaxLength : Integer;    // TreeNode Caption Max Length

//*** VTree Current selection state
  Selected   : TN_VNode;   // selected VNode (the only one in the VTree)
  Current    : TN_VNode;   // current  VNode (the only one in the VTree)
  MarkedVNodesList: TList; // list of VNodes, marked in this VTree
  CheckedUObjsList: TList; // list of Checked Nodes build in this VTree

  VTPrevHintTTNode: TTreeNode;  // last TreeNode for which hint was shown

  InsideOnVNodeChangeStateFunc : Boolean; // inside OnVNodeChangeState flag for 
                                          // preventing ChangeState cycling
  OnVNodeChangeStateFunc : TK_VNodeChangeStateFunc; // for respond to
                                                    // VNodeChangeState event

  constructor Create( ATreeView: TTreeView; ARootUObj: TN_UDBase;
                                        AViewFlags  : integer = 0;
                                        AVTDepth    : integer = 0;
                                        AVFlagsNum  : integer = 0;
                                        ATestDEFunc : TK_TestDEFunc = nil ); overload;

//  procedure Delete( DFlags: integer = 0 );
  procedure Delete( ADFlags: TK_VTreeVNodeDelFlags = [] );

  procedure UnMarkAllVNodes();
  procedure SetSelectedVNode( AVNode: TN_VNode );
  procedure SetCurrentVNode( AVNode: TN_VNode );
  procedure ChangeTreeViewUpdateMode( ASetUpdateMode : Boolean;
                                AUseUpdateCounter : boolean = false );
  function  GetVNodeByPath( out AVNode : TN_VNode; const APath : string = '';
                            AObjNameType : TK_UDObjNameType = K_ontObjName;
                            ARootVNode : TN_VNode = nil ) : Integer;
  function  SetPath0( out AVNode : TN_VNode; const APath : string;
                      AExpandLast, AMarkLast, ASelectLast : Boolean;
                      AObjNameType : TK_UDObjNameType ) : Integer;
  function  SetPath( const APath : string = ''; AExpandLast : Boolean = false;
                AMarkLast : Boolean = true; ASelectLast : Boolean = true;
                AObjNameType : TK_UDObjNameType = K_ontObjName ) : Integer;
  function  GetPathToVNode( AVNode : TN_VNode;
                   AObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
  function  GetCurState( AMarkedPathList, AExpandedPathList : TStrings ) : string;
  function  RebuildView( ARootUObj : TN_UDBase;
                  AMarkedPathList, AExpandedPathList : TStrings ) : TN_VNode;
  function  SetCurState( const ARootPath : string;
                         AMarkedPathList, AExpandedPathList : TStrings;
                         ADefaultRoot : TN_UDBase = nil ) : TN_VNode;
  procedure GetMarkedPathStrings( APList : TStrings;
                   AObjNameType : TK_UDObjNameType = K_ontObjName );
  procedure GetExpandedPathStrings( APList : TStrings;
               AObjNameType : TK_UDObjNameType = K_ontObjName );
  function  SetPathStrings( APList : TStrings;
                  AExpandedListFlag : Boolean;
                  AObjNameType : TK_UDObjNameType = K_ontObjName ) : TN_VNode;
  function  GetSelectedVNode( ) : TN_VNode;
  procedure MoveSelectedObject( ADir: Integer );
  procedure ToggleMarkedNodesPMark;
  procedure ClearNodesPMark;
        private
  RootVNode: TN_VNode;     // Root Visual Node (RootVNode.VNParent = nil)
  TreeViewUpdateCount: Integer; // counts TreeViewUpdateMode method call for
                                // proper TreeView update mode set
//##/*
  TreeViewClickTimeCount : Int64; // for Preventing Node Exapansion on MouseDoubleClick
//##*/
  procedure CreateVNodes;
  function  ClearNodesPMarkScanFunc( UDParent : TN_UDBase; var UDChild : TN_UDBase;
                                     ChildInd : Integer; ChildLevel : Integer;
                                     const FieldName : string = '' ) : TK_ScanTreeResult;
end; //*** end of type TN_VTree = class( TObject )

{
//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_VTreeDragObj
type TK_VTreeDragObj = class( TDragObjectEx )
  VTDragged : TN_VTree; // VTree Which State is dragged
end;
}
const
  K_CopyToClipboard = false;
  K_CutToClipboard  = true;

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboardPrepFlags
type TK_UDTreeClipboardPrepFlags = set of ( // Prepare IDB Objects Clipboard after Objects deletion flags
  K_ucpRemoveNodesWithAbsentParents, // remove from clipboard IDB Objects for 
                                     // which corresponding Directory Entry 
                                     // Parent Object was destroyed
  K_ucpRemoveNodesWithWrongDEInd     // remove from clipboard IDB Objects for 
                                     // which corresponding Directory Entry 
                                     // Index was changed
);

type TK_UDDelChildFunc = function ( UDParent : TN_UDBase; ChildInd : Integer ) : Boolean  of object;
type TK_UDInsChildFunc = function ( UDParent : TN_UDBase; ChildInd : Integer; const SrcDE : TN_DirEntryPar ) : Boolean  of object;

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard
type TK_UDTreeClipboard = class // IDB Data Subnet Clipboard
  SkipShowClipNodes : Boolean; // skip visual marking VNodes as copied to 
                               // Clipboard
  SkipShowCutNodes  : Boolean; // skip visual marking VNodes as cut to Clipboard
  DEClipboard : TK_DEArray;    // array of IDB objects directory entries data 
                               // put to Clipboard
  CutNodes : Boolean;          // cut after paste flag
  AddVNodeFalgs  : TK_VNodeStateFlags; // flags set for visual marking VNodes 
                                       // corresponding to paste IDB objects
  UDDelChildFunc : TK_UDDelChildFunc;  // application defind function for cut 
                                       // IDB Objects deletion
//##/*
  destructor Destroy(); override;
//##*/
  function  CopyVNodesToClipboard( AVNodesList : TList; ACutNodes : Boolean ) : Integer;
  function  PasteFromClipboard( AUDParent : TN_UDBase; APasteInd : Integer;
                                AUDInsChildFunc : TK_UDInsChildFunc;
                                ACBPrepFlags : TK_UDTreeClipboardPrepFlags ) : Integer;
  function  CheckParentForPaste( AUDParent : TN_UDBase ) : Boolean;
  function  PrepClipboard( ACBPrepFlags : TK_UDTreeClipboardPrepFlags ) : Integer;
  function  GetClipboardCount( ACBPrepFlags : TK_UDTreeClipboardPrepFlags =
                 [K_ucpRemoveNodesWithAbsentParents, K_ucpRemoveNodesWithWrongDEInd] ) : Integer;
  procedure ClearClipboard( );
  procedure PrepShowClipboard( AUseVCode : Boolean = true );
  procedure UpdateVTreesByClipboard( AUseVCode : Boolean = true );
  function  InsChildRef( AUDParent : TN_UDBase; AChildInd : Integer;
                         const ASrcDE : TN_DirEntryPar ) : Boolean;
  function  InsChildClone( AUDParent : TN_UDBase; AChildInd : Integer;
                           const ASrcDE : TN_DirEntryPar ) : Boolean;
  function  DeleteDEChild( AUDParent : TN_UDBase; AChildInd : Integer ) : Boolean;

end;

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeNodeRenameResult
type TN_VTreeNodeRenameResult = set of ( // Resulting flags set for IDB Objects interactive rename routine
  K_vrrObjName,  // IDB Object ObjName field was renamed
  K_vrrObjAliase // IDB Object ObjAliase field was renamed
);

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_VTreeStyle
type TK_VTreeStyle = record
   VTSTreeLinesColor      : Integer; // VTree Nodes Structure Lines color
   VTSButtonBorderColor   : Integer; // VTree Node Button Borders color
   VTSButtonSignColor     : Integer; // VTree Node Button +\- color
   VTSCheckBoxBorderColor : Integer; // VTree Node CheckBox Borders color
   VTSCheckBoxSignColor   : Integer; // VTree Node CheckBox Sign color
   VTSTextColor           : Integer; // VTree Node Text color
   VTSBGColor             : Integer; // VTree Node BackGround color
   VTSTextSBGColor        : Integer; // VTree Node Text Special BackGround color
   VTSFontStyles          : TFontStyles; // VTree Node Font Style
end;
var
  K_VTreeMainStyle     : TK_VTreeStyle =  (
    VTSTreeLinesColor      : clSilver;
    VTSButtonBorderColor   : clTeal;
    VTSButtonSignColor     : clNavy;
    VTSCheckBoxBorderColor : clTeal;
    VTSCheckBoxSignColor   : clNavy;
    VTSTextColor           : clBlack;
    VTSBGColor             : clWhite;
    VTSTextSBGColor        : $EEEEEE;
    VTSFontStyles          : [];
);  // VTree Ordinary Nodes Style

  K_VTreePermMark1Style    : TK_VTreeStyle =  (
    VTSTreeLinesColor      : clSilver;
    VTSButtonBorderColor   : clTeal;
    VTSButtonSignColor     : clNavy;
    VTSCheckBoxBorderColor : clTeal;
    VTSCheckBoxSignColor   : clNavy;
    VTSTextColor           : $0000A0;
    VTSBGColor             : clWhite;
    VTSTextSBGColor        : $EEEEEE;
    VTSFontStyles          : [fsBold];
);  // VTree Ordinary Nodes Style

  K_VTreeMarkedStyle     : TK_VTreeStyle =  (
    VTSTreeLinesColor      : clSilver;
    VTSButtonBorderColor   : clTeal;
    VTSButtonSignColor     : clNavy;
    VTSCheckBoxBorderColor : clTeal;
    VTSCheckBoxSignColor   : clNavy;
    VTSTextColor           : clBlack;
    VTSBGColor             : $FFEEDD;
    VTSTextSBGColor        : $EEEEEE;
    VTSFontStyles          : [];
);  // VTree Marked Nodes Style

  K_VTreeSelectedStyle     : TK_VTreeStyle =  (
    VTSTreeLinesColor      : clSilver;
    VTSButtonBorderColor   : clTeal;
    VTSButtonSignColor     : clNavy;
    VTSCheckBoxBorderColor : clTeal;
    VTSCheckBoxSignColor   : clNavy;
    VTSTextColor           : clBlack;
//    VTSBGColor             : clWhite;
    VTSBGColor             : $F8F8F8;
    VTSTextSBGColor        : $EEEEEE;
    VTSFontStyles          : [fsBold];
); // VTree Selected Nodes Style

  K_VTreeSelAndMarkStyle    : TK_VTreeStyle =  (
    VTSTreeLinesColor      : clSilver;
    VTSButtonBorderColor   : clTeal;
    VTSButtonSignColor     : clNavy;
    VTSCheckBoxBorderColor : clTeal;
    VTSCheckBoxSignColor   : clNavy;
    VTSTextColor           : clBlack;
    VTSBGColor             : $FFEEDD;
    VTSTextSBGColor        : $EEEEEE;
    VTSFontStyles          : [fsBold];
); // VTree Selected Nodes Style

  K_VTreeDisabledStyle : TK_VTreeStyle =  (
    VTSTreeLinesColor      : clSilver;
    VTSButtonBorderColor   : clTeal;
    VTSButtonSignColor     : clNavy;
    VTSCheckBoxBorderColor : clSilver;
    VTSCheckBoxSignColor   : clSilver;
    VTSTextColor           : clSilver;
    VTSBGColor             : clWhite;
    VTSTextSBGColor        : $EEEEEE;
    VTSFontStyles          : [];
); // VTree Disabled Nodes Style

  K_VTreeShortCutMarkSIInd   : Integer = 0;
  K_VTreeSLSRMarkSIInd       : Integer = 116;
  K_VTreeSLSRJoinedMarkSIInd : Integer = 117;
  K_VTreeSLSRChangedMarkSIInd: Integer = 118;
  K_VTreeDisabledMarkSIInd   : Integer = 119;

type TN_VTreeFrame = class;
{type} TN_VTFNodeSelectProcObj = procedure( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState ) of object;
{type} TN_VTFNodeActionProcObj = procedure( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState ) of object;
{type} TN_VTFMouseDownProcObj = procedure( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState ) of object;
{type} TN_VTFDoubleClickProcObj = procedure( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          Button: TMouseButton; Shift: TShiftState ) of object;
{type} TN_VTFNodeRenamingProcObj = procedure( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          var AllowEdit: Boolean ) of object;
{type} TN_VTFNodeRenameProcObj = procedure( AVTreeFrame: TN_VTreeFrame; AVNode: TN_VNode;
          RR : TN_VTreeNodeRenameResult ) of object;

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeFrame
{type} TN_VTreeFrame = class(TFrame)
//##/*
  TreeView: TTreeView;
  EdName: TEdit;

  ActionList: TActionList;
  RenameInline: TAction;
  StepUp      : TAction;
  StepDown    : TAction;
  RenameForm  : TAction;
  MoveNodeUP  : TAction;
  MoveNodeDown: TAction;
  ToggleNodesPMark: TAction;
  ClearNodesPMark: TAction;
  constructor Create( AOwner: TComponent ); override;
  destructor  Destroy(); override;
  procedure TVEditing( Sender: TObject; TNode: TTreeNode;
                             var AllowEdit: Boolean );
  procedure EdNameChange( Sender: TObject );
  procedure EdNameExit( Sender: TObject );
  procedure EdNameKeyDown( Sender: TObject; var Key: Word;
                           Shift: TShiftState );
  procedure RenameInlineExecute( Sender: TObject );
  procedure RenameFormExecute( Sender: TObject );
  procedure TVMouseMove( Sender: TObject; Shift: TShiftState;
                               X, Y: Integer );
  procedure StepUpExecute( Sender: TObject );
  procedure StepDownExecute( Sender: TObject );
  procedure MoveNodeUPExecute( Sender: TObject );
  procedure MoveNodeDownExecute( Sender: TObject );
  procedure ToggleNodesPMarkExecute( Sender: TObject );
  procedure ClearNodesPMarkExecute( Sender: TObject );
  procedure TVMouseDown( Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer );
  procedure TVItemExpanding(Sender: TObject; TNode: TTreeNode; var AllowExpansion: Boolean);
  procedure TVItemCollapsing(Sender: TObject; TNode: TTreeNode; var AllowCollapse: Boolean);
//  procedure OnChangeTreeViewItem( Sender: TObject; TNode: TTreeNode );
  procedure TVDrawItem ( Sender: TCustomTreeView; TNode: TTreeNode;
                            State: TCustomDrawState; var DefaultDraw: Boolean);
  procedure TVDeletion( Sender: TObject; TNode: TTreeNode );
  procedure TVStartDrag( Sender: TObject; var DragObject: TDragObject );
//##*/
        public
  VTree: TN_VTree;            // IDB Data Subnet visual representation 
                              // description
  MultiMark: Boolean;         // multi mark flag allows to mark more than one 
                              // Visual Node
  AllExpandingMode : Boolean; // expanding all VTree Nodes mode indicator (do 
                              // not set this field directly, it is used to 
                              // control VTree Nodes expanding)

  OnSelectProcObj     : TN_VTFNodeSelectProcObj;   // procedure of object for 
                                                   // respond to 
                                                   // TreeViewNodeSelect event
  OnActionProcObj     : TN_VTFNodeActionProcObj;   // procedure of object for 
                                                   // respond to 
                                                   // SelectedTreeViewNodeAtion 
                                                   // event
  OnMouseDownProcObj  : TN_VTFMouseDownProcObj;    // procedure of object for 
                                                   // respond to TVMouseDown 
                                                   // event
  OnDoubleClickProcObj: TN_VTFDoubleClickProcObj;  // procedure of object for 
                                                   // respond to 
                                                   // TreeViewNodeDoubleClick 
                                                   // event
  OnRenameProcObj     : TN_VTFNodeRenameProcObj;   // procedure of object for 
                                                   // respond to 
                                                   // TreeViewNodeRename event
  OnRenamingProcObj   : TN_VTFNodeRenamingProcObj; // procedure of object for 
                                                   // respond to 
                                                   // TreeViewNodeRenaming event

  procedure CreateVTree( ARootUObj: TN_UDBase = nil;
                         AViewFlags : integer = -1;
                         AVTDepth       : integer = 0;
                         AVFlagsNum    : integer = 0;
                         ATestDEFunc   : TK_TestDEFunc = nil );
  procedure RebuildVTree( ARootUObj : TN_UDBase; AMarkedList : TStrings = nil;
                         AExpandedList : TStrings = nil ); overload;
  procedure RebuildVTree( ARootUObj : TN_UDBase; AExpandedPath : string ); overload;
  procedure FrSetCurState( const ARootPath : string; AMarkedPathList,
              AExpandedPathList : TStrings; ADefaultRoot : TN_UDBase = nil;
              ARootUObj : TN_UDBase = nil );
  function  FrGetCurState( AMarkedPathList, AExpandedPathList : TStrings ) : string;
  procedure FrCurStateToMemIni( AIniNamePrefix : string = ''; ARootPath : string = '' );
  procedure FrMemIniToCurState( AIniNamePrefix : string = ''; ADefaultRoot : TN_UDBase = nil;
                                ARootUObj : TN_UDBase = nil );
//  function  MemIniToState( MarkedPathList, ExpandedPathList : TStrings;
//                                         IniNamePrefix : string = '' ) : string;
//##/*
  procedure RenameInlineByVNode( VNode: TN_VNode );
  procedure RenameUsingFormByVNode( VNode: TN_VNode );
        private
    RenamingObjName : string;
    RenamingObjAliase : string;
  procedure ObjNameEditFin( VNode : TN_VNode );
//##*/
end; // TN_VTreeFrame = class(TFrame)

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDMem
//**************************************************************** TN_UDMem ***
// IDB Object Class - application binary data container
//
// Compound Buffered Files Data Tree consists of TN_UDMem
//
type TN_UDMem = class( TN_UDBase )
  SelfMem: TN_BArray; // byte array for allocating application binary data

//##/*
  constructor Create;  override;
//##*/

  procedure AddFieldsToSBuf   ( ASBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( ASBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( ASTBuf: TK_SerialTextBuf;
                                AShowFlags : Boolean = true ): Boolean; override;
  function  GetFieldsFromText ( ASTBuf: TK_SerialTextBuf ): Integer; override;
  procedure CopyFields ( ASrcObj: TN_UDBase ); override;
  function  SameFields ( ASrcObj: TN_UDBase; AFlags: integer ): boolean; override;
  function  CompareFields( ASrcObj: TN_UDBase; AFlags: integer;
                           ANPath : string ) : Boolean; override;

  procedure GetStringsFromSelfBD ( AStrings: TStrings );
  function  LoadSelfBDFromDFile  ( AFileName : string;
                                   AOpenFlags: TK_DFOpenFlags = [];
                                   APassword : AnsiString = '' ): boolean;
end; // type TN_UDMem = class( TN_UDBase )

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDExtMem
//************************************************************* TN_UDExtMem ***
// IDB Object Class - application extened binary data container
//
// Compound Extended Buffered Files Data Tree consists of TN_UDExtMem
//
type TN_UDExtMem = class( TN_UDBase )
  FilePos:       Integer; // File Position of DataSegment with binary data
  FileDataSpace: Integer; // File Data Space (pure data) for file space control
  SelfMem: TN_BArray; // byte array for allocating application binary data
//##/*
  constructor Create;  override;
//##*/

  procedure AddFieldsToSBuf   ( ASBuf: TN_SerialBuf ); override;
  procedure GetFieldsFromSBuf ( ASBuf: TN_SerialBuf ); override;
  function  AddFieldsToText   ( ASTBuf: TK_SerialTextBuf;
                                AShowFlags : Boolean = true ): Boolean; override;
  function  GetFieldsFromText ( ASTBuf: TK_SerialTextBuf ): Integer; override;
  procedure CopyFields ( ASrcObj: TN_UDBase ); override;
  function  CompareSelfFields( ASrcObj: TN_UDBase ): boolean;
  function  SameFields ( ASrcObj: TN_UDBase; AFlags: integer ): boolean; override;
  function  CompareFields( ASrcObj: TN_UDBase; AFlags: integer;
                           ANPath : string ) : Boolean; override;
end; // type TN_UDExtMem = class( TN_UDMem )

//##/*
type TN_StatData = record  // all objects statistics
  NumUObj:  integer; // number of UObjects
  NumDir:   integer; // number of Directories (all UObjects, exept terminal)
  NumVNode: integer; // number of VNode
end; //*** end of type TN_StatData = record
//##*/

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDRefsRep
//************************************************************ TK_UDRefsRep ***
// Data structure for storing one element in IDB Subnet references replace info
//
type TK_UDRefsRep = record
    OldChild : TN_UDBase; // old IDB object reference
    NewChild : TN_UDBase; // new IDB object reference
end; //*** end of type TK_UDRefsRep = record

type TK_SaveUDSubTreeCopyProc = procedure ( UDObj : TN_UDBase;
                          NAliase : string = ''; NName : string = '' ) of object;

//****************** Global procedure **********************
function  K_BuildDEArrayFromVNodesList( AVNodesList : TList;
             AMarkClassFlags : LongWord; ASkipDuplicate : Boolean ) : TK_DEArray;
procedure K_TryToRepairDirIndex( var ADE : TN_DirEntryPar; AMarkClassFlags : Integer );
function  K_PrepDEArrayAfterDeletion( ADEArray : TK_DEArray; AMarkClassFlags : Integer;
                          APrepFlags : TK_UDTreeClipboardPrepFlags = [] ) : Integer;
function  K_DeleteDEChild( const ADE : TN_DirEntryPar; ADelChildFunc : TK_UDDelChildFunc = nil ) : Boolean;
function  K_DeleteDEArrayChilds( ADEArray : TK_DEArray; ADelChildFunc : TK_UDDelChildFunc = nil ) : Integer;
procedure K_ClearDEArrayChildsClassFlags( ADEArray : TK_DEArray; AMarkClassFlags : LongWord  );
function  K_DeleteUDNodesByVList( AVNodesList : TList; ADelChildFunc : TK_UDDelChildFunc = nil ) : Integer;
function  K_SelectUDNode( var ASelObj : TN_UDBase; ARootObj : TN_UDBase;
                          ASFilterFunc   : TK_TestDEFunc; ASelCaption : string;
                          ASelShowToolBarFlag : Boolean; AMultiSelectFlag : Boolean = false;
                          AVChildsFlags : Integer = 0  ) : Boolean;
function  K_AddDEToSBuf( ASBuf: TN_SerialBuf; var ADE : TN_DirEntryPar;
                                    out AAddChildSubtree: boolean ) : TN_UDBase;
procedure K_GetDEFromSBuf( ASBuf: TN_SerialBuf; var ADE: TN_DirEntryPar; out AGetChildSubtree : Boolean );
//procedure K_UDBaseDelete( UD : TN_UDBase );
procedure K_ClearDirEntry( var ADE : TN_DirEntryPar );
function  K_AddCompareErrInfo( AErrInfo : string ) : Boolean;
function  K_ReplaceNodeRef( Node : TN_UDBase; var NNode : TN_UDBase ) : Boolean;
procedure K_BuildDEChildRef( var DE : TN_DirEntryPar; CreateRefObj : Boolean = true );
function  K_BuildPathSegmentByDE( const ADE : TN_DirEntryPar;
            AObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
//procedure K_ClearRefList( RefList : TList);
function  K_CmpInt1(const APItem1, APItem2 : Pointer): Integer;
//function  K_CmpInt2(const item1, item2 : Pointer): Integer;
function  K_CompareDirEntries ( const ADE1, ADE2 : TN_DirEntryPar;
                                AVFlags : Integer ) : Boolean;
function  K_GetDEVFlags ( const ADE : TN_DirEntryPar;
                          AVFlags, AFlagsNum : Integer ) : Integer;
function  K_DERErrorInfoText( AErrCode : TK_DEReplaceResult; out AErrInfo : string ) : Boolean;
//function  K_CheckDirEntry( const DE : TN_DirEntryPar; const Child : TN_UDBase ) : Boolean;
procedure K_SetUDGControlFlags( ASetMode : Integer; AValue : TK_UDGControlFlags );
//procedure K_FreeDEArrayChilds( var ArrDE : TK_DEArray; FreeInstance : Boolean = true );
//procedure K_MarkVNodesListSubTrees( VList : TList; ALevel : Integer = 0;
//                                 ADepth : Integer = -1;
//                                 AField : Integer = -1 );
//procedure K_AddChildsFromDEArray( Root : TN_UDBase; const DEArray : TK_DEArray; Clear : Boolean = true );
procedure K_AddChildsFromVNodesList( ARootObj : TN_UDBase; AVList : TList; AClearFlag : Boolean = true );
procedure K_UnlinkDirectReferences( ARootObj : TN_UDBase; ARootCursorName : string = '';
                                    AClearRefInfoFlag : Boolean = false );

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_BuildDirectRefsFlags
type TK_BuildDirectRefsFlags  = set of ( // IDB Objects direct references recovery flags set
  K_bdrClearRefInfo,  // clear runtime info after IDB Objects direct references 
                      // recovery
  K_bdrClearURefCount // skip unresoved references accumulation (clear 
                      // unresolved references counter before each IDB Objects 
                      // direct references recovery)
);
function  K_BuildDirectReferences( ARootObj : TN_UDBase; ABuildDRefsFlags : TK_BuildDirectRefsFlags = [K_bdrClearURefCount] ) : Integer;

procedure K_ShowUnresRefsInfo( AShowRoot : TN_UDBase; AUnresCount : Integer = 0;
                                      AShowDetailsFlag : Boolean = false );
procedure K_ClearSubTreeRefInfo( ARootObj : TN_UDBase; AClearRefInfoFlags : TK_ClearRefInfoFlags = [] );
function  K_ReplaceRefsInSubTree( ABaseRoot, APrevTargetRoot, ANewTargetRoot : TN_UDBase;
                                  AShowErrorMesFlag : Boolean = true ) : Integer;
procedure K_ClearUObjsScannedFlag();

//procedure N_SaveHeaderToStrings ( Strings: TStrings;                               //???remove
//                                           UObj: TN_UDBase; Mode: integer );
//procedure N_CollectOneLevelStatistics ( UObj: TN_UDBase; Mode: integer );
//procedure N_CollectStatistics         ( UObj: TN_UDBase; Mode: integer;
//                                                     AStrings: TStrings = nil );
//procedure N_CompressVNodes ( var AVNodes: TN_VNArray );                            //???remove
procedure K_RSTNAddPair( AOldUObj, ANewUObj : TN_UDBase );
procedure K_RSTNExecute( ARootUObj : TN_UDBase );
procedure K_BuildSLSRList( ARootUObj : TN_UDBase; ASLSRList : TList;
                           ATestProc : TK_TestUDChildFunc = nil  );

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_SetChangeSubTreeFlags
type TK_SetChangeSubTreeFlags = set of ( // IDB Data Subnet Change Flag diffusion flags set
  K_cstfSetDown,           // mark as changed all objects in IDB Object 
                           // Ownership Subtree
  K_cstfSetSLSRChangeFlag, // set special changed mark to Separately Loaded 
                           // Subnet Root (SLSR) IDB Object
  K_cstfObjNameChanged     // mark as changed all Parent Objects to some given 
                           // IDB Object
);
procedure K_ClearChangeSubTreeFlags( ARootUObj : TN_UDBase  );
procedure K_SetChangeSubTreeFlags( ARootUObj : TN_UDBase; ASetFlags : TK_SetChangeSubTreeFlags = [] );
procedure K_SetAbsentOwners( ARootUObj : TN_UDBase );

function  K_AddSaveLoadFlagsToGlobalFlags( ASaveLoadFlags : TK_UDTreeLSFlagSet = [] ) : TK_UDGControlFlagSet;
procedure K_AddToPUDRefsTable( APUD : TN_PUDBase );

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_CheckAppArchVerResult
type TK_CheckAppArchVerResult = ( // Check IDB Archive and Application versions resulting code enumeration
  K_cavOK,     // IDB Archive version is proper for using by Application
  K_cavOlder,  // IDB Archive is too old for Application
  K_cavNewer   // Application is too old for IDB Archive
);
function  K_CompareAppArchVer( ABinaryArchFormatFlag : Boolean ) : TK_CheckAppArchVerResult;
procedure K_CheckAppArchVer( AFileName : string; ABinaryArchFormatFlag : Boolean );
function  K_GetVTreeStateFromMemIni( AMarkedPathList, AExpandedPathList : TStrings;
                                          AIniNamePrefix : string ) : string;
procedure K_SaveVTreeStateToMemIni( AMarkedPathList, AExpandedPathList : TStrings;
                                       const ARootPath, AIniNamePrefix : string );

function  K_GetPathToUObj( AUObj : TN_UDBase; ARootUObj : TN_UDBase = nil;
                           AObjNameType : TK_UDObjNameType = K_ontObjName;
                           APathTrackingFlags : TK_PathTrackingFlags =
                           [K_ptfSkipOwnersAbsPath, K_ptfTryAltRelPath] ) : string;

//****************** Global variables **********************
const
//K_LDataTypesSet = [K_isDataInt64, K_isDataDouble, K_isDataDate];

K_ClassTypeMask = $FFFFFF00;

//****** TN_UDBase save to binary file tag values
K_fTagObjAbsent = $0000;
K_fTagObjBody   = $0001;
K_fTagObjLink   = $0002;
K_fTagDEData    = $0003;
K_fTagSubTree   = $0008;
K_fTagFinTree   = $000F;

//****** visual parameters flag
// value for VNode.VFlags, UDBase.ObjVFlags and  DE.DEVFlags
K_fvUseCurrent               = $8000;
K_fvSkipCurrent              = $4000;
K_fvUseMask                  = $3FFF;
K_fvSkipDE                   = $3FFF;
K_fvTreeViewMask             = $0FF0;
K_fvSkipChildDir             = $0800;
K_fvTreeViewSkipLines        = $0400;
K_fvTreeViewSkipSeparators   = $0200;
K_fvTreeViewTextEdit         = $0100;
K_fvTreeViewObjNameAndAliase = $0080;
K_fvTreeViewObjDate          = $0040;
K_fvTreeViewSkipCaption      = $0020;
K_fvTreeViewSkipDEName       = $0010;
K_fvDirDescendingSorted      = $0008;
K_fvDirSortedMask            = $0007;
K_fvDirUnsorted              = $0000;
K_fvDirSortedByObjName       = $0001;
K_fvDirSortedByObjType       = $0002;
K_fvDirSortedByObjDate       = $0003;
K_fvDirSortedByDEName        = $0004;
K_fvDirSortedByDECode        = $0005;
K_fvDirSortedByObjUName      = $0006;

var
  K_UDGControlFlags : TK_UDGControlFlagSet = []; //
  K_UDGControlFlagsCounters :
     Array [0..(Ord(K_gcfMaxFlagNumber)-1)] of Integer;


  K_UDGControlRefPathInfoRoot : TN_UDBase;
  N_StatData     : TN_StatData;         // Collecting statistics Data Buffer
  N_EmptyObj     : TN_UDBase;           // Empty Object

  K_MainRootObj  : TN_UDBase;           // Global Root Obj
  K_ArchsRootObj : TN_UDBase;           // Data Archives Root Obj
  K_SPLRootObj   : TN_UDBase;           // SPL Root Obj
  K_FilesRootObj : TN_UDBase;           // Compound Buffered Files Root Obj

  N_VTrees: TList;                      // All Visual Trees
  N_ActiveVTree: TN_VTree = nil;        // Current Active VTree

  N_ActiveClipboard: TN_UDBase;         // TN_UDBase objects active Clipboard
  N_UObjAllClipboards: TN_UDArray;      // TN_UDBase objects Clipboards

  K_UDOperateFlags : TK_UDOperateFlags; // Control UDNodes Deletion
  K_TreeCurVersion  : Integer = 3;      //* Control Data Version
  K_TreeLoadVersion : Integer;          //* during Deserialization fields
  K_UDRefTable : TN_UDArray;            //*
  K_UDRefIndex1 : Integer;              //*

  K_UDFilter : TK_UDFilter;             // Select UD Filter Extern

  K_TreeNodeNameMaxLength : Integer = 75; // TreeView Node maximal length

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeBuildRefControl
//************************************************ TK_UDTreeBuildRefControl ***
// Data structure for control IDB Subnet references resolving during tree-walk 
// in TN_UDBase.BuildDirectReferences method
//
type TK_UDTreeBuildRefControl = record
  URefPFields : TN_PUDArray;            // array of pointers to fields with 
                                        // unresolved references
  URefCount   : Integer;                // number of unresolved references 
                                        // during tree-walk in 
                                        // TN_UDBase.BuildDirectReferences 
                                        // method
  RRefCount   : Integer;                // number of resolved references during 
                                        // tree-walk in 
                                        // TN_UDBase.BuildDirectReferences 
                                        // method
end;

var
  K_UDTreeBuildRefControl : TK_UDTreeBuildRefControl; // SubTree Build References Control

  K_UDPathTokenizer : TK_Tokenizer;     // Path sections analizing
  K_SysDateTime : TDateTime;            // DateTime constant during Mass UDNodes Creation

  K_CurArchive  : TN_UDBase;            // Current Data Archive

  K_CompareSList : TStringList;         //* Compare UDSubTrees Control Fields
  K_CompareMaxErrNum : Integer = 10;    //*
  K_CompareCurNum    : Integer;         //*
  K_CompareStopFlag  : Boolean;         //*
  K_CompareTreeFlags : Integer;         //*
  K_RSTNPairsArray   : TK_BaseArray;    // Array of UÂBase Pairs for Raplacing 1 to 2
  K_ErrFName         : string;          // Some Low Level Error FileName for EndUser Diagnostics


//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeChildsScanFlags
type TK_UDTreeChildsScanFlags = Set of ( // IDB Data Subnet scan Objects flags set
  K_udtsRAFieldsScan,               // scan IDB Objects referenses in UDRArray 
                                    // User Data fields
  K_udtsOwnerChildsOnlyScan,        // scan only IDB Objects belong to Ownership
                                    // Subtree of given Subnet
  K_udtsEmptyChildsScan,            // scan empty Childs (scan NILs)
  K_udtsLoopProtectedChildsScan,    // scan IDB Objects rejected by 
                                    // LoopProtected Tool (but not it's Subnet)
  K_udtsSkipRAFieldsSubTreeScan,    // skip scan IDB Objects referenses in 
                                    // UDRArray User Data fields
  K_udtsSkipOwnerChildsSubTreeScan, // skip scan Subnet of IDB Objects belong to
                                    // Ownership Subtree
  K_udtsSkipRefChildsSubTreeScan,   // skip scan Subnet of IDB Objects not 
                                    // belong to Ownership Subtree
  K_udtsSkipOwnerChildsScan,        // skip scan IDB Objects belong to Ownership
                                    // Subtree
  K_udtsSkipRefChildsScan           // skip scan IDB Objects not belong to 
                                    // Ownership Subtree
);

var
  K_UDTreeChildsScanFlags : TK_UDTreeChildsScanFlags = [K_udtsRAFieldsScan];
  K_UDLoopProtectionList : TList;      // Loop Protectoin Control for UDTree Iterators
  K_UDScannedUObjsList : TList;        // List of Scaned Nodes for UDTree Iterators

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_VTreeFrameShowFlags
type TK_VTreeFrameShowFlags = Set of ( // IDB Data Subnet visual representation global flags set
  K_vtfsShowChangedSubTree, // view special mark for IDB objects that contains 
                            // "changed" flag
  K_vtfsSkipNodeIcon,       // skip IDB object Icon
  K_vtfsSkipInlineEdit      // skip IDB Name Inline Edit 
                            // K_vtfsUseObjDisabledFlag // show|use IDB objects 
                            // Disabled staet for Objects that contains 
                            // K_fpObjTVDisabled in ObjFlags 
                            // K_vtfsUseObjAutoCheckFlag // show CheckBox for 
                            // IDB objects that contains K_fpObjTVChecked in 
                            // ObjFlags
);

var
  K_VTreeFrameShowFlags : TK_VTreeFrameShowFlags;

// SLSRoot Save Dialog routine returns
// =-2 if Don't Save All Sections of Specified Type
// =-1 if Don't Save Specified Section
// =0  if Save Specified Section
// =1  if Save All Sections of Specified Type
  K_SLSRSaveDialogFunc : function ( SLSRoot : TN_UDBase ) : Integer of object;

//*** Routine fore Quick Rebuild VTree View just after finish File Loading;
  K_LTFFVTreeRebuildRoutine : procedure of object;

  K_AppSaveUDSubTreeCopyProc : TK_SaveUDSubTreeCopyProc; // Applicaton Save UDObj SubTree copy Proc

//*** Data Format Version Control
  K_DFVCUDBaseToSPLTypesRefs : TN_UDArray; // References to SPL Types for UDBase Types for Data Format Version Control
procedure K_AddUObjToUsedTypesList( AUObj : TN_UDBase; AUsedTypesList : TList );
procedure K_ClearUsedTypesMarks( AUsedTypesList : TList );
procedure K_ShowFmtVerErrorMessageDlg( AFmtVerCode : Integer; ASourceName : string; AFmtErrInfo : TStrings );
function  K_PrepareUDFilterAllowed( var AUDFilter : TK_UDFilter;
                        AObjCTypes : array of LongWord ) : TK_UDFilter;
function  K_PrepareUDFilterNotAllowed( var AUDFilter : TK_UDFilter;
                        AObjCTypes : array of LongWord ) : TK_UDFilter;

implementation
{$R *.DFM}

uses Messages, Dialogs, Math, StrUtils,
     N_Lib0, N_Lib1, N_Lib2, N_Deb1, N_ClassRef, N_InfoF, N_ButtonsF,
     K_FSelectUDB, K_UDC, K_FUDRename,
     K_UDT2, K_Script1, K_FEText, K_Arch;

  {$IFDEF N_DEBUG}
var
  DebStr: string;
  {$ENDIF}

//********** Unit Local Variable
var
  K_CurSLSRList : TList; // Current List of Separately Loaded Subnet Roots in loading SubTree
  K_SLSLoadErrorsList : TStringList; // List of Separately Loaded Subnet Loading Errors

//********** end of Unit Local Variable

//********** TN_UDBase class local routines  **************
{
//******************************************** DataExchangeErrorAction ***
// convert TK_ParamType to corresponding TK_DEDataType
//
procedure DataExchangeErrorAction( ErrorCode : TK_DEReplaceResult;
                                        ErrorModeFlag : LongWord );
var ErrMesage : string;
begin
  if K_DERErrorInfoText( ErrorCode, ErrMesage ) then
  begin
    if (ErrorModeFlag and K_fuDEDTCollisionMessageNone) = 0 then
      K_ShowMessage(ErrMesage);
    if (ErrorModeFlag and K_fuDEDTCollisionStop) <> 0  then
      assert( false );
  end;
end; // end_of procedure DataExchangeErrorAction
}

//********** TK_UDFilterItem class methods  **************

//********************************************** TK_UDFilterItem.Create ***
//
constructor TK_UDFilterItem.Create;
begin
  inherited Create;
  ExprCode := K_ifcAnd;
end; // end_of constructor TK_UDFilterItem.Create

//********** end of TK_UDFilterItem class methods  **************

//********** TK_UDFilter class methods  **************

//********************************************** TK_UDFilter.Destroy ***
//
destructor TK_UDFilter.Destroy;
begin
  FreeItems(0);
  inherited;
end; // end_of destructor TK_UDFilter.Destroy

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDFilter\AddItem
//***************************************************** TK_UDFilter.AddItem ***
//
//
procedure TK_UDFilter.AddItem( FilterItem : TK_UDFilterItem );
begin
  Add(FilterItem);
end; // end_of procedure TK_UDFilter.AddItem

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDFilter\FreeItems
//*************************************************** TK_UDFilter.FreeItems ***
//
//
procedure TK_UDFilter.FreeItems( Ind : Integer = 0; ACount : Integer = 0 );
var i : Integer;
begin
  if ACount = 0 then
    ACount := Count
  else
    ACount := Min( Ind + ACount, Count );
  Dec(ACount);
  for i := ACount downto Ind do  begin
    TK_UDFilterItem(Items[i]).Free;
    Delete(i);
  end;
end; // end_of procedure TK_UDFilter.FreeItems

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDFilter\UDFTest
//***************************************************** TK_UDFilter.UDFTest ***
//
//
function  TK_UDFilter.UDFTest( const DE : TN_DirEntryPar ) : Boolean;
var i : Integer;
fitem : TK_UDFilterItem;
begin
//  Result := (LItems.Count = 0) or TK_UDFilterItem(LItems.Items[0]).Test(DE);
  Result := true;

  if(Self = nil) or (Count = 0) then Exit;
  Result := false;
  for i := 0 to Count - 1 do
  begin
    fitem := TK_UDFilterItem(Items[i]);
    case fitem.ExprCode of
      K_ifcOr   : begin
        if Result then Exit;
        Result := fitem.UDFITest(DE);
      end;
      K_ifcAnd   : if Result then Result := fitem.UDFITest(DE);
      K_ifcNotOr : begin
        if Result then Exit;
        Result := not fitem.UDFITest(DE);
      end;
      K_ifcNotAnd: if Result then Result := not fitem.UDFITest(DE);
    end;
  end;
end; // end_of function TK_UDFilter.UDFTest

//********** end of TK_UDFilter class methods  **************

//********** TN_UDBase class methods  **************

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\Create
//******************************************************** TN_UDBase.Create ***
//
//
constructor TN_UDBase.Create(  );
begin
  inherited;
  ObjLiveMark := N_ObjLiveMark;
  ClassFlags := N_UDBaseCI;
  ImgInd := 30;
  if K_gcfSysDateUse in K_UDGControlFlags then
    ObjDateTime := K_SysDateTime
  else
    SetDate;
  {$IFDEF N_DEBUG}
  N_AddDebString( 0, 'New UDB=$' + IntToHex( Integer(self), 8) );
  {$ENDIF}
end; // end_of constructor TN_UDBase.Create

//********************************************** TN_UDBase.Destroy ***
//
destructor TN_UDBase.Destroy;
  {$IFDEF N_DEBUG}
var    debInfo : string;
  {$ENDIF}
begin
  {$IFDEF N_DEBUG}
  debInfo := 'Dstr UDB=$' + IntToHex( Integer(self), 8);
  N_AddDebString( 1, debInfo );
  {$ENDIF}
//if Ndir <> nil then
//Ndir^.UDDCapacity := Ndir^.UDDCapacity + 0;
  if RefCounter = 0 then RefCounter := -1;
  if Ndir <> nil then// For Dir Memory Free
    Ndir^.UDDCapacity := 0;

  ClearChilds( 0, -1, -1 );
  while LastVNode <> nil do LastVNode.Delete;

  {$IFDEF N_DEBUG}
  N_AddDebString( 1, 'Fin '+ debInfo );
  {$ENDIF}
//  SetLength( ObjName, 0 );
  ObjLiveMark := 0;
  inherited destroy;
end; // end_of procedure TN_UDBase.Destroy

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\UDDelete
//****************************************************** TN_UDBase.UDDelete ***
// Delete self IDB object
//
//     Parameters
// AParent - IDB parent object which child is deleted (if given parent AParent 
//           is object Owner then object reference to Owner will be cleared)
//
// Is used while IDB object is removed from some IDB directory entry. IDB object
// references counter is decremented. If it is last object reference then it's 
// destructor is called
//
procedure TN_UDBase.UDDelete( AParent : TN_UDBase = nil );
  {$IFDEF N_DEBUG}
var    debInfo : string;
  {$ENDIF}
begin
  if (self = nil) then Exit;
  if ObjLiveMark <> N_ObjLiveMark then
    raise TK_UDBaseConsistency.Create( 'TN_UDBase.UDDelete Consistency Error' );
  {$IFDEF N_DEBUG}
  DebStr := 'Del '+' refC.=' + IntToStr(RefCounter)+' UDB=$' +
    IntToHex( Integer(self), 8) +  ' name="'+ObjName+'"';
  debInfo := DebStr;
  N_AddDebString( 3, DebStr );
  {$ENDIF}
  Dec(RefCounter);
  if Owner = AParent then Owner := nil; // Clear owner if delete from Owner Parent
//if (AParent <> nil) and (AParent.ObjName = 'RusE') and (ObjName = 'Data') then
//ObjInfo := '123456789';
  if RefCounter >= 1 then Exit;
//if (ObjInfo = '123456789') and (ObjName = 'Data') then
//ObjName := 'Data';
//  N_Dump1Str( format( '!!! Start UDDelete for N=%s A=%s I=%s', [ObjName, ObjAliase, ObjInfo] ) );
  if (ClassFlags and (K_SkipDestructBit or K_SkipDestructBitD)) <> 0 then
  begin
  // Remove Childs and VNodes
    if RefCounter < 0 then Exit;
    ClearChilds( 0, -1, -1 );
    while LastVNode <> nil do LastVNode.Delete;
    LastVNode := nil;
    Exit;
  end;

  Destroy;
  {$IFDEF N_DEBUG}
  N_AddDebString( 3, 'Fin ' +debInfo );
  {$ENDIF}
end; // end_of procedure TN_UDBase.UDDelete

//******************************************************* TN_UDBase.UDSafeDelete ***
//
//
procedure TN_UDBase.UDSafeDelete( AParent : TN_UDBase = nil );
//var

begin
end; // end_of procedure TN_UDBase.UDSafeDelete

//******************************************** TN_UDBase.GetFieldPointer ***
// virtual method for program and struct objects
//
function TN_UDBase.GetFieldPointer( const AFiledName : string ) : Pointer;
begin
  Result := nil;
end; // end_of procedure TN_UDBase.GetFieldPointer

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\DirHigh
//******************************************************* TN_UDBase.DirHigh ***
// Get index of last child object
//
//     Parameters
// Result - Returns index of last child object (directory entry)
//
function  TN_UDBase.DirHigh   : Integer;
begin
  Result := -1;
  if Self = nil then Exit;
  if ObjLiveMark <> N_ObjLiveMark then
    raise TK_UDBaseConsistency.Create( 'TN_UDBase.DirHigh Consistency Error' );
  if NDir <> nil then Result := Ndir^.UDDCount - 1;
end; // end_of procedure TN_UDBase.DirHigh

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\DirLength
//***************************************************** TN_UDBase.DirLength ***
// Get number of child objects
//
//     Parameters
// Result - Returns number of child objects (directory entries)
//
function  TN_UDBase.DirLength   : Integer;
begin
  Result := 0;
  if Self = nil then Exit;
  if ObjLiveMark <> N_ObjLiveMark then
    raise TK_UDBaseConsistency.Create( 'TN_UDBase.DirLength Consistency Error' );
  if NDir <> nil then Result := Ndir^.UDDCount;
end; // end_of procedure TN_UDBase.DirLength

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\DirSetLength
//************************************************** TN_UDBase.DirSetLength ***
// Set number of child objects
//
//     Parameters
// ACount - number of child objects (directory entries)
//
// Can be used only for directory enlargment or if directory tail is empty
//
procedure TN_UDBase.DirSetLength( ACount : Integer );
var i, FullLength : Integer;


begin
  if Ndir <> nil then  begin
    FullLength := Ndir^.UDDCapacity;
    if ((FullLength = 0) and (ACount = 0)) or // Free NDir During Object Destroy
       K_NewCapacity( ACount, FullLength ) then
    begin
      for i := 0 to High(Ndir^.UDDFields) do
        if Length(Ndir^.UDDFields[i]) > 0 then
          SetLength( Ndir^.UDDFields[i], FullLength );
    end;
    if FullLength = 0 then
      ReallocMem(Ndir, 0)
    else
    begin
      if ACount = 0 then Ndir^.UDDMaxVCode := 1; // clear Unique VCode param value
      Ndir^.UDDCapacity := FullLength;
    end;
  end
  else
  begin
    if ACount > 0 then
    begin
      ReallocMem( Ndir, SizeOf(TK_UDDir) );
      FillChar( Ndir^, SizeOf(TK_UDDir), 0 );
      Ndir^.UDDCapacity := ACount;
      Ndir^.UDDMaxVCode := 1;
    end;
  end;
  if Ndir <> nil then Ndir^.UDDCount := ACount;
end; // end_of procedure TN_UDBase.DirSetLength

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\DirChild
//****************************************************** TN_UDBase.DirChild ***
// Get IDB object child by entry index in directory
//
//     Parameters
// AInd      - index of directory entry
// ADefChild - resulting value (if child is absent)
// Result    - Returns child object
//
function  TN_UDBase.DirChild( AInd : Integer; ADefChild : TN_UDBase = nil ) : TN_UDBase;
begin
  Result := ADefChild;
  if (Self = nil)                   or
     (AInd < 0) or ( AInd > DirHigh) then Exit;
  if ObjLiveMark <> N_ObjLiveMark then
    raise TK_UDBaseConsistency.Create( 'TN_UDBase.DirChild Parent Consistency Error' );
  GetDEField( AInd, Result, K_DEFisChild );
  Result := RestoreDRefToChild( AInd, Result );
  if (Result <> nil)                 and
     (Result.ClassFlags = K_UDRefCI) and
     (K_gcfRefIgnore in K_UDGControlFlags) then
    Result := nil
{
  else if (Result <> nil) and (Result.ObjLiveMark <> N_ObjLiveMark) then
    raise TK_UDBaseConsistency.Create( 'TN_UDBase.DirChild Child Consistency Error' );
}
end; // end_of function TN_UDBase.DirChild

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\PutDirChild
//*************************************************** TN_UDBase.PutDirChild ***
// Put reference to new child in given directory entry
//
//     Parameters
// AInd   - index of in directory entry
// AChild - new child to link to directory entry
//
function TN_UDBase.PutDirChild( AInd : Integer; AChild : TN_UDBase ) : Boolean;
var
  PrevChild : TN_UDBase;
begin
  GetDEField( AInd, PrevChild, K_DEFisChild );
  PrevChild := RestoreDRefToChild( AInd, PrevChild );
  Result := PrevChild <> AChild;
  if not Result then Exit;

// needed to prevent AChild deletion
// during PrevChild SubTree Deletion
  if AChild <> nil then
    Inc(AChild.RefCounter);

  if PrevChild <> nil then
    PrevChild.UDDelete( Self );

  if AChild <> nil then
    Dec(AChild.RefCounter);

  PutDEField( AInd, Integer(AChild), K_DEFisChild );
end; // end_of procedure TN_UDBase.PutDirChild

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\PutDirChildSafe
//*********************************************** TN_UDBase.PutDirChildSafe ***
// Put reference to new child in given directory entry (enlarge directory length
// if needed)
//
//     Parameters
// AInd   - index of in directory entry
// AChild - new child to link to directory entry
//
procedure TN_UDBase.PutDirChildSafe( AInd : Integer; AChild : TN_UDBase );
begin
  if AInd >= DirLength then  DirSetLength( AInd + 1 );
  PutDirChild( AInd, AChild )
end; // end_of procedure TN_UDBase.PutDirChildSafe

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\PutDirChildV
//************************************************** TN_UDBase.PutDirChildV ***
// Put reference to new child in given directory entry, enlarge directory length
// if needed and build Visual Nodes for new child object
//
//     Parameters
// AInd        - index of in directory entry
// AChild      - new child to link to directory entry
// AVNodeFalgs - new Visual Nodes state flags
// AVTree      - Visual Tree for new VNode creating
//
// If AVTree = nil then new VNodes are created in all VTrees where self object 
// is visualized.
//
procedure TN_UDBase.PutDirChildV( AInd : Integer; AChild : TN_UDBase;
                          AVNodeFalgs : TK_VNodeStateFlags = [];
                          AVTree : TN_VTree = nil );
begin
  if AInd >= DirLength then  DirSetLength( AInd + 1 );
  if K_DRisOK = ReplaceDirChild( AInd, AChild ) then
    AddChildVNodes( AInd, AVNodeFalgs, AVTree );
end; // end_of procedure TN_UDBase.PutDirChildV

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\RestoreDRefToChild
//******************************************** TN_UDBase.RestoreDRefToChild ***
// Restore reference to proper IDB object for given child if needed
//
//     Parameters
// AInd   - index of given child object
// AChild - current child IDB object
// Result - Returns restored reference to IDB child object or existing child 
//          object AChild
//
// Do not call RestoreDRefToChild directly, it is used automatically in some 
// TN_UDBase methods for restore direct reference to proper child object.
//
function TN_UDBase.RestoreDRefToChild( AInd : Integer; AChild : TN_UDBase ) : TN_UDBase;
var
  PUDRef : TN_PUDBase;
begin
  Result := AChild;
  if AChild = nil then Exit;
  if K_ReplaceNodeRef( AChild, Result ) then begin
    assert( Result <> nil, 'Wrong node path:'+ObjName+'['+IntToStr(AInd)+'] ->' + AChild.RefPath );
    PUDRef := TN_PUDBase( @( TN_IArray(GetDEFArrayPointer( K_DEFisChild )^)[AInd] ) );
    if Result <> AChild then begin// Reference was replaced
//      PutDEField( Ind, Integer(Result), K_DEFisChild );
      PUDRef^ := nil; //*** clear UDRef field - because RefNode is already destroyed
      K_SetUDRefField( PUDRef^, Result, true );
      Inc( K_UDTreeBuildRefControl.RRefCount );
    end else begin
      K_AddToPUDRefsTable( PUDRef );
    end;
  end else begin
    if (Result.Owner = nil) and
       ((ObjFlags and K_fpObjOwnerLinkNon) = 0) then // set new owner for lost one
      Result.Owner := self;
  end;
end; // end_of function TN_UDBase.RestoreDRefToChild

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetDirEntry
//*************************************************** TN_UDBase.GetDirEntry ***
// Get IDB object directory entry data by entry index
//
//     Parameters
// AInd - index of directory entry
// ADE  - resulting directory entry data
//
procedure TN_UDBase.GetDirEntry( AInd : Integer; out ADE : TN_DirEntryPar );
var
  cfields : TN_IArray;
  i : Integer;
begin
  assert( AInd <> -1, 'Attempt to get Dir Entry from index=-1' );
  K_ClearDirEntry( ADE );
  ADE.DirIndex := AInd;
  ADE.Parent := self;
  for i := 0 to High(Ndir^.UDDFields) do begin
    cfields := Ndir^.UDDFields[i];
    if Length(cfields) > 0 then begin
      case i of
        Ord(K_DEFisCode)    : ADE.DECode := cfields[AInd];
        Ord(K_DEFisFlags)   : ADE.DEFlags := cfields[AInd];
//        Ord(K_DEFisUFlags)  : ADE.DEUFlags := TK_DEUFlags( cfields[AInd] );
        Ord(K_DEFisVFlags)  : ADE.DEVFlags := TK_DEVFlags( cfields[AInd] );
        Ord(K_DEFisName)    : ADE.DEName := string( cfields[AInd] );
        Ord(K_DEFisChild)   : ADE.Child := TN_UDBase(cfields[AInd]);
        Ord(K_DEFisVCode)   : ADE.VCode := cfields[AInd];
      end;
    end;
  end;

end; // end_of procedure TN_UDBase.GetDirEntry

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\PutDirEntry
//*************************************************** TN_UDBase.PutDirEntry ***
// Put directory entry data to IDB object entry given by index
//
//     Parameters
// AInd   - index of directory entry
// ADE    - directory entry data
// Result - Returns operation resulting code enumeration
//
function TN_UDBase.PutDirEntry( AInd : Integer; const ADE : TN_DirEntryPar ) : TK_DEReplaceResult;
begin
  Result := ReplaceDirChild( AInd, ADE.Child );
  if Result <= K_DRisOK then
  begin
    PutDEField( AInd, ADE.DEFlags, K_DEFisFlags );
    PutDEField( AInd, PInteger(@ADE.DEVFlags)^, K_DEFisVFlags );
//    PutDEField( AInd, PInteger(@ADE.DEUFlags)^, K_DEFisUFlags );
    PutDEField( AInd, LongWord(ADE.DEName), K_DEFisName );
    PutDEField( AInd, ADE.DECode, K_DEFisCode );
  end;
end; // end_of procedure TN_UDBase.PutDirEntry

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddDirEntry
//*************************************************** TN_UDBase.AddDirEntry ***
// Add IDB object directory entry and fill it by given data
//
//     Parameters
// ADE    - directory entry data
// Result - Returns index of added directory entry
//
function  TN_UDBase.AddDirEntry( const ADE : TN_DirEntryPar ) : Integer;
begin
  Result := InsertEmptyEntries( -1, 1 );
  PutDirEntry( Result, ADE );
end; // end_of procedure TN_UDBase.AddDirEntry

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\IndexOfDEField
//************************************************ TN_UDBase.IndexOfDEField ***
// Search IDB object directory entry index by given field value
//
//     Parameters
// AData     - field value
// AFieldID  - directory entry field ID
// AStartInd - start directory entry index for search
// Result    - Returns index of found directory entry
//
function  TN_UDBase.IndexOfDEField( const AData;  AFieldID : TK_DEFieldID = K_DEFisChild;
        AStartInd : Integer = 0  ) : Integer;

var
  pdata : pointer;
  HInd : Integer;
begin
  Result := -1;
  if Self = nil then Exit;
  pdata := GetDEFArrayPointer( AFieldID );
  if (pdata = nil) or (Pointer(pdata^) = nil) then Exit;
  HInd := DirHigh;
  if HInd = -1 then Exit;
  if AFieldID <> K_DEFisName then
    Result := K_SearchInIArray(  TN_IArray(pdata^), Integer(AData),
                                AStartInd, HInd )
  else
    Result := K_SearchInSArray(  TN_SArray(pdata^), PString(@AData)^,
                                AStartInd, HInd );
end; // end_of procedure TN_UDBase.IndexOfDEField

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\ReplaceDirChild
//*********************************************** TN_UDBase.ReplaceDirChild ***
// Replace IDB object child in directory entry given by index
//
//     Parameters
// AInd      - index of directory entry
// ANewChild - new child object
// Result    - Returns operation resulting code enumeration
//
function  TN_UDBase.ReplaceDirChild( AInd : Integer; ANewChild : TN_UDBase ) : TK_DEReplaceResult;
var
  DE : TN_DirEntryPar;

begin
  Result := K_DRisOK;
  if (AInd < 0) and (AInd >= DirLength ) then
  begin
    Result := K_DRisIndError;
    Exit;
  end;

//*** check data equivalence
  GetDirEntry( AInd, DE );
  if DE.Child = ANewChild then
//  if K_CheckDirEntry( DE, DataType, Data  ) then
  begin
    Result := K_DRisEqual;
    Exit;
  end;

// needed to prevent ANewChild deletion
// during DE.Child SubTree Deletion
  if ANewChild <> nil then
    Inc(ANewChild.RefCounter);

  RemoveChildVNodes( DE );
  if DE.Child <> nil then
    DE.Child.UDDelete( DE.Parent );

  if ANewChild <> nil then
    Dec(ANewChild.RefCounter);

  PutDEField( AInd, Integer(ANewChild), K_DEFisChild );
end; // end_of procedure TN_UDBase.ReplaceDirChild

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\RemoveDirEntry
//************************************************ TN_UDBase.RemoveDirEntry ***
// Remove IDB object directory entry given by index
//
//     Parameters
// AInd   - index of directory entry
// Result - Returns operation resulting code enumeration
//
function  TN_UDBase.RemoveDirEntry( AInd: Integer ) : TK_DEReplaceResult;
var
  Count : Integer;
  DE : TN_DirEntryPar;
begin

  Result := K_DRisOK;
  if AInd < 0 then Exit;
  Result := ReplaceDirChild( AInd, nil ); // clear DE
  if Result <= K_DRisOK then
  begin
    GetDirEntry( AInd, DE );
//*** not remove fixed entries
    if not (K_udoUNCDeletion in K_UDOperateFlags) and
       ((DE.DEFlags and K_fpDEProtected) <> 0)then Exit;
    if (DE.VCode > 0) and (DE.VCode = NDir^.UDDMaxVcode - 1) then
      Dec(NDir^.UDDMaxVcode); // correct Uniq Vcode param
//*** clear DEName by placing "clear" DE
    K_ClearDirEntry( DE );
    PutDirEntry( AInd, DE );
//*** remove DE record from Dir
    Count := DirLength - 1;
    MoveEntries( AInd, AInd + 1, Count - AInd );
    DirSetLength( Count );
  end;
end; // end procedure TN_UDBase.RemoveDirEntry

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\RemoveEqualChilds
//********************************************* TN_UDBase.RemoveEqualChilds ***
// Remove IDB object equal child objects
//
procedure TN_UDBase.RemoveEqualChilds;
var
  i, h : Integer;
  UDB : TN_UDBase;
begin
  h := DirHigh;
  for i := h - 1 downto 0 do begin
    UDB := DirChild( i );
    if IndexOfDEField( UDB, K_DEFisChild, i + 1 ) <> -1 then
      RemoveDirEntry( i );
  end
end; //*** end of procedure TN_UDBase.RemoveEqualChilds

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetDEFArrayPointer
//******************************************** TN_UDBase.GetDEFArrayPointer ***
// Get pointer to IDB object directory fields array
//
//     Parameters
// AFieldID - directory entry field ID
// Result   - Returns pointer to IDB object directory fields array
//
function TN_UDBase.GetDEFArrayPointer( AFieldID : TK_DEFieldID ) : Pointer;

var
fieldInd : Integer;
begin
  Result := nil;
  if NDir = nil then Exit;
  fieldInd := Ord( AFieldID );
  if (fieldInd >= 0) and
     (fieldInd <= Ord(K_DEFisVCounter)) then
    Result := @Ndir^.UDDFields[fieldInd]
  else
    assert( false, 'Wrong DE field type' );
end; // end_of procedure TN_UDBase.GetDEFArrayPointer

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetDEFieldPointer(2)
//****************************************** TN_UDBase.GetDEFieldPointer(2) ***
// Get pointer to IDB object directory fields array element
//
//     Parameters
// AInd     - index of directory entry
// AFieldID - directory entry field ID
// Result   - Returns pointer to IDB object directory fields array element
//
function TN_UDBase.GetDEFieldPointer( AInd : Integer; AFieldID : TK_DEFieldID ) : Pointer;
var
pdata : pointer;
begin
  Result := nil;
  if AInd < 0 then Exit;
  pdata := GetDEFArrayPointer(AFieldID);
  if (pdata = nil) or (Pointer(pdata^) = nil) then Exit;

  if AInd < Length( TN_IArray(pdata^) ) then
    Result := @TN_IArray(pdata^)[AInd];
end; // end_of procedure TN_UDBase.GetDEFieldPointer

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetDEFieldPointer(1)
//****************************************** TN_UDBase.GetDEFieldPointer(1) ***
// Get value of IDB object directory field
//
//     Parameters
// AInd     - index of directory entry
// AValue   - resulting value
// AFieldID - directory entry field ID
//
procedure TN_UDBase.GetDEField ( AInd : Integer; var AValue; AFieldID : TK_DEFieldID );

var
pdata : pointer;
begin
  pdata := GetDEFieldPointer( AInd, AFieldID );
  Integer(AValue) := 0;
  if pdata <> nil then
    if AFieldID = K_DEFisName then
      string(AValue) := string(pdata^)
    else
      Integer(AValue) := Integer(pdata^);
end; // end_of procedure TN_UDBase.GetDEField

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\PutDEField
//**************************************************** TN_UDBase.PutDEField ***
// Put value to IDB object directory field
//
//     Parameters
// AInd     - index of directory entry
// AValue   - resulting value
// AFieldID - directory entry field ID
//
procedure TN_UDBase.PutDEField ( AInd : Integer; AValue : Integer;
      AFieldID : TK_DEFieldID );
var
  pdata : pointer;
begin
  if Ndir = nil then DirSetLength( AInd + 1 );
  pdata := GetDEFArrayPointer( AFieldID );
  if Pointer(pdata^) = nil then
  begin
    if AValue <> 0 then
      SetLength(TN_IArray(pdata^), Ndir^.UDDCapacity )
    else Exit;
  end;
  if AFieldID = K_DEFisName then
  begin
    if Integer(AValue) = 0 then
      SetLength(TN_SArray(pdata^)[AInd], 0)
    else
      TN_SArray(pdata^)[AInd] := string(AValue);
  end else
  begin
    TN_IArray(pdata^)[AInd] := AValue;
    if (AFieldID = K_DEFisChild) and (AValue <> 0) then
    begin
      Inc(TN_UDBase(AValue).RefCounter);
      if (TN_UDBase(AValue).Owner = nil) then // main Owner filed set
        TN_UDBase(AValue).Owner := self;
    end;
  end;
end; // end_of procedure TN_UDBase.PutDEField

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\IndexOfDECode
//************************************************* TN_UDBase.IndexOfDECode ***
// Search IDB object directory entry index by given DECode field value
//
//     Parameters
// ADECode - directory entry code value
// Result  - Returns index of found directory entry
//
function TN_UDBase.IndexOfDECode( ADECode :Integer ) : Integer;
begin
  Result := -1;
  if ADECode <> 0 then
    Result := IndexOfDEField( ADECode, K_DEFisCode);
end; // end_of procedure TN_UDBase.IndexOfDECode

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetDirFieldArray
//********************************************** TN_UDBase.GetDirFieldArray ***
// Get IDB object directory fields array
//
//     Parameters
// AFieldsArray - resulting directory fields array
// AFieldID     - directory entry field ID
//
procedure TN_UDBase.GetDirFieldArray( var AFieldsArray; AFieldID : TK_DEFieldID );
var
pdata : pointer;
begin
  pdata := GetDEFArrayPointer( AFieldID );
  if AFieldID = K_DEFisName then
  begin
    if pdata = nil then
    begin
      SetLength(TN_SArray(AFieldsArray), 0);
      Exit;
    end;
    TN_SArray(AFieldsArray) := TN_SArray(pdata^);
    if Pointer(pdata^) = nil then
      SetLength(TN_SArray(AFieldsArray), NDir^.UDDCount);
  end
  else
  begin
    if pdata = nil then begin
      SetLength(TN_IArray(AFieldsArray), 0);
      Exit;
    end;
    TN_IArray(AFieldsArray) := TN_IArray(pdata^);
    if Pointer(pdata^) = nil then
      SetLength(TN_IArray(AFieldsArray), NDir^.UDDCount);
  end;
end; // end_of procedure TN_UDBase.GetDirFieldArray

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\InsertEmptyEntries
//******************************************** TN_UDBase.InsertEmptyEntries ***
// Insert IDB object directory entries before given
//
//     Parameters
// AInd   - index of directory entry, define insertion position
// ACount - number of new entries
// Result - Returns index of first new empty directory entry
//
function TN_UDBase.InsertEmptyEntries( AInd : Integer; ACount: integer ): integer;
begin
  Result := DirLength;
  if AInd < 0 then AInd := Result;
  DirSetLength( Result + ACount );
  if (AInd >= 0) and (AInd < Result) then
  begin
    MoveEntries( AInd, Result, ACount );
    Result := AInd;
  end;
end; // end function TN_UDBase.InsertEmptyEntries

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\RemoveEmptyEntries
//******************************************** TN_UDBase.RemoveEmptyEntries ***
// Remove IDB object directory empty entries
//
//     Parameters
// Result - Returns number of remooved empty directory entries
//
function TN_UDBase.RemoveEmptyEntries : integer;
var
  Ind, Leng : Integer;
  VDel : TN_UDBase;

begin
  Result := 0;
  Ind := 0;
  VDel := nil;
  repeat
    Ind := IndexOfDEField( VDel, K_DEFisChild, Ind );
    if Ind = -1 then break;
    Leng := DirLength - 1;
    MoveEntries( Ind, Ind + 1, Leng - Ind );
    DirSetLength( Leng );
    Inc(Result);
  until false;
end; // end function TN_UDBase.RemoveEmptyEntries

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\MoveEntries
//*************************************************** TN_UDBase.MoveEntries ***
// Move IDB object directory entries
//
//     Parameters
// ADInd  - destination directory index
// ASInd  - sourse directory index
// ACount - number of mooving entries
// Result - Returns number of mooved directory entries.
//
// Returns 0 if wrong move portion is given.
//
function TN_UDBase.MoveEntries( ADInd, ASInd: Integer; ACount : Integer = 1 ) : Integer;
var
  wcfields, cfields : TN_IArray;
  wdInd, bsize, msize, i, s, d : Integer;
begin
  wcfields := nil;
  cfields := nil;
  Result := 0;
  i := DirLength;
  s := ASInd + ACount;
  d := ADInd + ACount;
  if (ACount = 0)    or
     (ADInd = ASInd) or
     (ADInd < 0)     or
     (ASInd < 0)     or
     (d > i)         or
     (s > i) then Exit;

  Result := ACount;
  bsize := (ADInd - ASInd);
  if ADInd < ASInd then
  begin
    s := ADInd;
    bsize := -bsize;
  end
  else
    d := ASInd;

//  SetLength(ctypes, 0);
  msize := bsize * SizeOf(Integer);
  cfields := nil;
  for i := 0 to High(Ndir^.UDDFields) do
  begin
    wcfields := Ndir^.UDDFields[i];
    if Length(wcfields) > 0 then
    begin
      cfields := Copy( wcfields, ASInd, ACount );
      move( wcfields[s], wcfields[d], msize );
//**!! this line prevent compiler error in  optimization mode
      wdInd := ADInd + 0;
      move( cfields[0], wcfields[wdInd], ACount * SizeOf(Integer) );
    end;
  end;

end; // end_of function TN_UDBase.MoveEntries

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\BuildRefPath
//************************************************** TN_UDBase.BuildRefPath ***
// Build IDB object RefPath field
//
//     Parameters
// Result - Returns RefPath field value.
//
// Do not call BuildRefPath directly, it is used automatically in IDB Subnet 
// serialization routines.
//
function  TN_UDBase.BuildRefPath( ) : string;
var ind : Integer;
DE : TN_DirEntryPar;
begin
  Result := '';
  if Self = nil then Exit;
  Result := RefPath;
  if Result = '' then begin
    if Owner <> nil then begin //*** get owner path
      ind := Owner.IndexOfDEField( self, K_DEFisChild );
      Owner.GetDirEntry( ind, DE );
      Result := Owner.BuildRefPath() + K_udpPathDelim + K_BuildPathSegmentByDE( DE );
    end else begin             //*** get any path
      Result := K_UDAbsPathCursor.GetObjPath( self );
//      if Result <> '' then
      Result := K_UDAbsPathCursor.IncludeCursorName(  Result );
    end;
    RefPath := Result;
  end;
end; // end_of function TN_UDBase.BuildRefPath

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\ClearRefPath
//************************************************** TN_UDBase.ClearRefPath ***
// Clear IDB object RefPath field
//
//     Parameters
// Result - Returns RefPath field value.
//
// Do not call ClearRefPath directly, it is used automatically in IDB Subnet 
// serialization routines.
//
procedure TN_UDBase.ClearRefPath( UDRoot : TN_UDBase = nil );
begin
  if Self = K_MainRootObj then Exit; // Prevent Main Root RefPath clear
  RefPath := '';
  if (UDRoot = Owner) or
     (Owner = nil)    or
     (Owner.RefPath = '') then Exit;
  Owner.ClearRefPath( UDRoot );
end; // end_of procedure TN_UDBase.ClearRefPath

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddFieldsToSBuf
//*********************************************** TN_UDBase.AddFieldsToSBuf ***
// Add values of IDB object self fields to serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
// Only self fields are serialized (without any childs data)
//
procedure TN_UDBase.AddFieldsToSBuf( ASBuf: TN_SerialBuf );
begin

  ASBuf.AddRowInt( Integer(ObjFlags) );
  ASBuf.AddRowBytes( Sizeof(ObjDateTime), @ObjDateTime );
  ASBuf.AddRowBytes( Sizeof(ObjUFlags), @ObjUFlags );
  ASBuf.AddRowBytes( Sizeof(ObjVFlags), @ObjVFlags );
  ASBuf.AddRowString( ObjName );
  ASBuf.AddRowString( ObjAliase );
  ASBuf.AddRowInt( ImgInd );
  ASBuf.AddRowString( ObjInfo );

end; // end_of procedure TN_UDBase.AddFieldsToSBuf

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetFieldsFromSBuf
//********************************************* TN_UDBase.GetFieldsFromSBuf ***
// Get values of IDB object self fields from serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
// Only self fields are deserialized (without any childs data)
//
procedure TN_UDBase.GetFieldsFromSBuf( ASBuf: TN_SerialBuf );
begin
  ASBuf.GetRowInt( Integer(ObjFlags) );
  ASBuf.GetRowBytes( Sizeof(ObjDateTime), @ObjDateTime );
  ASBuf.GetRowBytes( Sizeof(ObjUFlags), @ObjUFlags );
  ASBuf.GetRowBytes( Sizeof(ObjVFlags), @ObjVFlags );
  ASBuf.GetRowString( ObjName );
//  if K_TreeLoadVersion > 0 then begin
  ASBuf.GetRowString( ObjAliase );
  ASBuf.GetRowInt( ImgInd );
//  end;
//  if K_TreeLoadVersion > 1 then
  ASBuf.GetRowString( ObjInfo );
end; // end_of procedure TN_UDBase.GetFieldsFromSBuf

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddChildTreeToSBuf
//******************************************** TN_UDBase.AddChildTreeToSBuf ***
// Add IDB object childs to serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
// IDB object full Subnet serialization (child objects directory entries data, 
// fields and childs Subnets). Do not call AddChildTreeToSBuf directly, it is 
// used automatically in IDB Subnet serialization routines.
//
procedure TN_UDBase.AddChildTreeToSBuf( ASBuf: TN_SerialBuf );
var
  AddChildTree: boolean;
  Count, h, i : integer;
//  Child : TN_UDBase;
  DE : TN_DirEntryPar;
  AddChildsScale : TN_BArray;
begin
  if ((ObjFlags and K_fpObjSkipChildsSave) = 0) or
     ((CI = K_UDUnitCI) and (K_gcfSaveUDUnitCompileData in K_UDGControlFlags)) then
    h := DirLength
  else
    h := 0;

//*** Build Saved Childs Scale
  Dec(h);
  Count := PrepSerializedChildsScale( 0, h, AddChildsScale );

  ASBuf.AddRowInt( Count );
  for i := 0 to h do  begin
//    Child := AddChildToSBuf( SBuf, i, AddChildTree );
    if AddChildsScale[i] <> 0 then Continue;
    GetDirEntry(i, DE);

    with DE, Child do begin

      if (Child <> nil) then begin
        if (ClassFlags and K_SkipSelfSaveBit) <> 0 then
          Child := nil
        else if ((ObjFlags and K_fpObjSLSRFlag) <> 0) and
                (K_gcfSetJoinToAllSLSR in K_UDGControlFlags) then
          ObjFlags := ObjFlags or K_fpObjSLSRJoin;
      end;

      K_AddDEToSBuf( ASBuf, DE, AddChildTree );

      if AddChildTree and
//         ( ((ObjFlags and K_fpObjSLSRFlag) =  0) or
//           ((ObjFlags and K_fpObjSLSRJoin) <> 0) or
         ( ((DE.Child.ObjFlags and K_fpObjSLSRFlag) =  0) or
           ((DE.Child.ObjFlags and K_fpObjSLSRJoin) <> 0) or
           (K_gcfJoinAllSLSR in K_UDGControlFlags) ) then begin
         if (ObjFlags and K_fpObjSLSRFlag) <>  0 then
           K_InfoWatch.AddInfoLine( 'Save "' + GetUName+ '" joined' );
         AddChildTreeToSBuf( ASBuf );
      end;
    end;
  end;
end; // end_of procedure TN_UDBase.AddChildTreeToSBuf

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetChildTreeFromSBuf
//****************************************** TN_UDBase.GetChildTreeFromSBuf ***
// Get IDB object childs from serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
// IDB object full Subnet deserialization (child objects directory entries data,
// fields and childs Subnets). Do not call GetChildTreeFromSBuf directly, it is 
// used automatically in IDB Subnet deserialization routines.
//
procedure TN_UDBase.GetChildTreeFromSBuf( ASBuf: TN_SerialBuf );
var
  i, NumChilds : integer;
  GetChildTree: boolean;
  DE : TN_DirEntryPar;
begin
  ASBuf.GetRowInt( NumChilds );
  DirSetLength( NumChilds );

  for i := 0 to NumChilds - 1 do
  begin
    K_GetDEFromSBuf( ASBuf, DE, GetChildTree );
    PutDirEntry( i, DE );
    with DE, Child do
     if GetChildTree and not AddLoadingToSLSRList() then begin
       GetChildTreeFromSBuf( ASBuf );
       if (ObjFlags and K_fpObjSLSRFlag) <> 0 then // Add Loaded Sections Uses
         SLSRAddUses( K_CurSLSRList );
     end;
    ASBuf.ShowProgress;
  end;
end; // end_of procedure TN_UDBase.GetChildTreeFromSBuf

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddMetaFieldsToText
//******************************************* TN_UDBase.AddMetaFieldsToText ***
// Add values of IDB base (TN_UDBase) object self fields to serial text buffer
//
//     Parameters
// ASBuf        - serial text buffer object
// AAddObjFlags - serialized self update (ObjUFlags) and view (ObjVFlags) fields
//
// Only self fields are serialized (without any childs data)
//
procedure TN_UDBase.AddMetaFieldsToText( ASBuf: TK_SerialTextBuf;
                                         AAddObjFlags : Boolean = true );
var
  i, ww : Integer;
  wwe : Longword;
begin
  if K_txtSkipMetaFields in K_TextModeFlags then Exit;
  if Length(ObjName) > 0 then ASBuf.AddTagAttr( K_tbObjName, ObjName );
  if Length(ObjAliase) > 0 then ASBuf.AddTagAttr( K_tbObjAliase, ObjAliase );
  if Length(ObjInfo) > 0 then ASBuf.AddTagAttr( K_tbObjInfo, ObjInfo );
  if ObjFlags <> 0 then ASBuf.AddTagAttr( K_tbObjFlags, ObjFlags, K_isHex );
  if (RefIndex <> 0)  and
     not (K_txtXMLMode in K_TextModeFlags) then
    ASBuf.AddTagAttr( K_tbObjRefInd, RefIndex, K_isInteger );
  if (ImgInd <> -1) and
     not (K_txtXMLMode in K_TextModeFlags) then
    ASBuf.AddTagAttr( K_tbObjImgInd, ImgInd, K_isInteger );

  if AAddObjFlags or
     (K_txtSysFormat in K_TextModeFlags) or
     (K_txtSaveUFlags in K_TextModeFlags) then
  begin
    for i := 0 to High(ObjUFlags) do
    begin
      wwe := ObjUFlags[i].DirFlags;
      if wwe <> 0 then ASBuf.AddTagAttr( K_tbObjUDFlags+IntToStr(i), wwe, K_isHex );
      wwe := ObjUFlags[i].EntryFlags;
      if wwe <> 0 then ASBuf.AddTagAttr( K_tbObjUEFlags+IntToStr(i), wwe, K_isHex );
    end;

    for i := 0 to High(ObjVFlags) do
    begin
      ww := ObjVFlags[i];
      if ww <> 0 then ASBuf.AddTagAttr( K_tbObjVFlags+IntToStr(i), ww, K_isHex );
    end;
  end;

  if K_txtSysFormat in K_TextModeFlags then
  begin
    ww := 1;
    ASBuf.AddTagAttr( K_tbObjTextFMT, ww, K_isInteger );
  end;

  if not (K_txtMetaFullMode in K_TextModeFlags) then Exit;
  ASBuf.AddTagAttr( K_tbObjDate, ObjDateTime, K_isDateTime );

end; // end_of procedure TN_UDBase.AddMetaFieldsToText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetMetaFieldsFromText
//***************************************** TN_UDBase.GetMetaFieldsFromText ***
// Get values of IDB base (TN_UDBase) object self fields from serial text buffer
//
//     Parameters
// ASBuf - serial text buffer object
//
// Only self fields are deserialized (without any childs data)
//
procedure TN_UDBase.GetMetaFieldsFromText( ASBuf: TK_SerialTextBuf );
var
i, ww : Integer;
wwe : Longword;
begin
  if K_txtSkipMetaFields in K_TextModeFlags then Exit;
  ASBuf.GetTagAttr( K_tbObjName, ObjName );
  ASBuf.GetTagAttr( K_tbObjAliase, ObjAliase );
  ASBuf.GetTagAttr( K_tbObjInfo, ObjInfo );
  ASBuf.GetTagAttr( K_tbObjFlags, ObjFlags, K_isInteger );
  ASBuf.GetTagAttr( K_tbObjRefInd, RefIndex, K_isInteger );
  ASBuf.GetTagAttr( K_tbObjImgInd, ImgInd, K_isInteger );
  for i := 0 to High(ObjUFlags) do
  begin
    if ASBuf.GetTagAttr( K_tbObjUDFlags+IntToStr(i), wwe, K_isInteger ) then
      ObjUFlags[i].DirFlags := wwe;
    if ASBuf.GetTagAttr( K_tbObjUEFlags+IntToStr(i), wwe, K_isInteger ) then
      ObjUFlags[i].EntryFlags := wwe;
  end;
  for i := 0 to High(ObjVFlags) do
  begin
    if ASBuf.GetTagAttr( K_tbObjVFlags+IntToStr(i), ww, K_isInteger ) then
      ObjVFlags[i] := ww;
  end;
  ASBuf.GetTagAttr( K_tbObjDate, ObjDateTime, K_isDate );
end; // end_of procedure TN_UDBase.GetMetaFieldsFromText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddFieldsToText
//*********************************************** TN_UDBase.AddFieldsToText ***
// Add values of IDB object self fields to serial text buffer
//
//     Parameters
// ASBuf        - serial text buffer object
// AAddObjFlags - serialized self update (ObjUFlags) and view (ObjVFlags) fields
// Result       - Returns TRUE if child objects serialization is needed, if self
//                fields and childs are serialized then resulting value is 
//                FALSE.
//
function  TN_UDBase.AddFieldsToText( ASBuf: TK_SerialTextBuf;
                                 AAddObjFlags : Boolean = true ) : Boolean;
begin
  AddMetaFieldsToText( ASBuf, AAddObjFlags );
  Result := true;
end; // end_of procedure TN_UDBase.AddFieldsToText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetFieldsFromText
//********************************************* TN_UDBase.GetFieldsFromText ***
// Get values of IDB object self fields from serial text buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// Result - Returns 0 if child objects deserialization is needed, if self fields
//          and childs are deserialized then resulting value is not 0.
//
function  TN_UDBase.GetFieldsFromText( ASBuf: TK_SerialTextBuf ) : Integer;
begin
  GetMetaFieldsFromText( ASBuf );
  Result := 0;
end; // end_of procedure TN_UDBase.GetFieldsFromText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddToText
//***************************************************** TN_UDBase.AddToText ***
// Add IDB object reference info or fields to serial text buffer
//
//     Parameters
// ASBuf    - serial text buffer object
// ARefInfo - add IDB object reference info flag
// Result   - Returns TRUE if IDB object self fields (not reference info) are 
//            serialized
//
// Do not call AddToText directly, it is used automatically in 
// TN_UDBase.AddDEToText and K_SaveTreeToText.
//
function TN_UDBase.AddToText( ASBuf: TK_SerialTextBuf; ARefInfo : Boolean = true ): boolean;
begin
  Result := false;
  if (Marker = 0) and                                        //* Node was not added yet
     ({RefAttr or }(Owner = nil) or (Owner.Marker <> 0)) and //* Node Owner was added
     (not ARefInfo or (ClassFlags <> K_UDRefCI))             //* Node is not Reference type
  then begin// add Node body

    SetMarker(1);                 // mark saved object
//    SBuf.SaveRefList.Add( self ); // for future clearing Marker field after saving

    if (RefCounter > 1) and
       (RefIndex = 0) then
    begin
      Inc( K_UDRefIndex1 );
      RefIndex := K_UDRefIndex1;
    end;

    Result := AddFieldsToText( ASBuf ); // add node obj fields (not children!)
  end else begin // node was already added (already in TextBuf)
    BuildRefPath();
    ASBuf.AddTagAttr( K_tbObjRefPath, RefPath );
    if RefIndex <> 0 then
      ASBuf.AddTagAttr( K_tbObjRefInd, RefIndex, K_isInteger );
  end;
end; // end_of procedure TN_UDBase.AddToText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetFromText
//*************************************************** TN_UDBase.GetFromText ***
// Get IDB object: create instance and get reference info or fields from serial 
// text buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// AClass - getting IDB object class type
// AUObj  - creating object
// Result - Returns 0 if child objects deserialization is needed, if self fields
//          and childs are deserialized then resulting value is not 0.
//
// Do not call GetFromText directly, it is used automatically in 
// TN_UDBase.GetSubTreeFromText.
//
function TN_UDBase.GetFromText( ASBuf: TK_SerialTextBuf; AClass : TClass;
                                        out AUObj : TN_UDBase ) : Integer;
var
  RPath : string;
begin
  Result := -1;
  AUObj := nil;
  if ASBuf.GetTagAttr( K_tbObjRefPath, RPath ) then begin
    AUObj := TK_UDRef.Create;
    AUObj.RefPath := RPath;
    AUObj.ObjAliase := RPath;
    AUObj.ObjName := ExtractFileName(RPath);
    ASBuf.GetTagAttr( K_tbObjRefInd, RefIndex, K_isInteger );
  end else if AClass <> nil then begin
//*** create obj instance and load fields
    AUObj := TN_UDBaseClass(AClass).Create;
//*** get Child obj fields (may be its subtree)
    Result := AUObj.GetFieldsFromText( ASBuf );
    AUObj.AddSelfToRefTable;
  end;
end; // end_of procedure TN_UDBase.GetFromText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\CopyMetaFields
//************************************************ TN_UDBase.CopyMetaFields ***
// Copy self fields values from given IDB base (TN_UDBase) object
//
//     Parameters
// ASrcObj - source IDB base (TN_UDBase) object
//
procedure TN_UDBase.CopyMetaFields( ASrcObj: TN_UDBase );
begin
  if (ASrcObj = nil) then Exit; // a precaution
  ObjName     := ASrcObj.ObjName;
  ObjFlags    := ASrcObj.ObjFlags;
  ObjDateTime := ASrcObj.ObjDateTime;
  ObjUFlags   := ASrcObj.ObjUFlags;
  ObjVFlags   := ASrcObj.ObjVFlags;
  ObjAliase   := ASrcObj.ObjAliase;
  ImgInd      := ASrcObj.ImgInd;
  ObjInfo     := ASrcObj.ObjInfo;
end; // end_of procedure TN_UDBase.CopyMetaFields

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\CopyFields
//**************************************************** TN_UDBase.CopyFields ***
// Copy self fields values from given IDB  object
//
//     Parameters
// ASrcObj - source IDB base (TN_UDBase) object
//
procedure TN_UDBase.CopyFields( ASrcObj: TN_UDBase );
begin
  CopyMetaFields( ASrcObj );
end; // end_of procedure TN_UDBase.CopyFields
{
//************************************** TN_UDBase.CopySubTree ***
// copy fields and SubTree from given SrcObj object
// to same fields of self, previous self SubTree is cleared
// (SrcObj must be of the same class as self)
//
function TN_UDBase.CopySubTree( SrcObj: TN_UDBase ) : TN_UDBase;
begin
  Result := self;
  if SrcObj = nil then Exit;
  assert( self.ClassFlags = SrcObj.ClassFlags, 'Objects "'+ObjName+
              '" and "'+SrcObj.ObjName+'" has different types' );
  self.CopyFields( SrcObj );
  K_DefaultTreeMerge.UpdateDir( self, SrcObj );
  K_ClearRefList( K_DefaultTreeMerge.RefList );
end; // end_of procedure TN_UDBase.CopySubTree

//************************************** TN_UDBase.CopyChilds ***
// copy Childs References from SrcObj
//
function TN_UDBase.CopyChilds( SrcObj: TN_UDBase;
                DirFlags : TK_UDFlags = K_fuDirMergeClearOld;
                EntryFlags : TK_UEFlags = 0 ) : TN_UDBase;
begin
  DirFlags := DirFlags or K_fuUseGlobal or K_fuDirMergeCorrespondingNone;
  K_DefaultTreeMerge.UpdateDir( self, SrcObj, 0, -1, 0, -1,
      DirFlags, EntryFlags or K_fuUseGlobal or K_fuDEDataReplace );
  Result := self;
end; // end_of procedure TN_UDBase.CopyChilds


//************************************** TN_UDBase.CopyChildsRefs ***
// copy Childs References from SrcObj
//
procedure TN_UDBase.CopyChildsRefs( SrcObj: TN_UDBase );
var
  i : Integer;
begin
  for i := 0 to SrcObj.DirHigh do
    AddOneChild( SrcObj.DirChild(i) );
end; // end_of procedure TN_UDBase.CopyChildsRefs

//************************************** TN_UDBase.CopySubTree ***
// copy Childs References from SrcObj
//
procedure TN_UDBase.CopySubTree( SrcObj: TN_UDBase );
var
  i : Integer;
  SrcChild : TN_UDBase;
begin
  for i := 0 to SrcObj.DirHigh do begin
    SrcChild := SrcObj.DirChild(i);
    AddOneChild( SrcChild.Clone ).CopySubTree( SrcChild );
  end;
end; // end_of procedure TN_UDBase.CopySubTree
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\ReorderChilds
//************************************************* TN_UDBase.ReorderChilds ***
// Reorder IDB object childs
//
//     Parameters
// APIndex       - pointer to first element of childs indexes array
// ACount        - indexes array length
// AGetNewUDNode - function of object for new childs creation if needed
//
procedure TN_UDBase.ReorderChilds( APIndex : PInteger; ACount : Integer;
                                   AGetNewUDNode : TK_NewUDNodeFunc = nil );
var
  h, i, j : Integer;
  WRoot, DChild : TN_UDBase;
  Owners : TN_UDArray;
begin
  h := ACount - 1;
  WRoot := TN_UDBase.Create;
  SetLength( Owners, ACount );
//*** Init Data Buffer
  for i := 0 to h do begin
    j := APIndex^;
    Inc(APIndex);
    DChild := DirChild( j );
    if (DChild = nil) and Assigned(AGetNewUDNode) then //*** Add new Child
      DChild := AGetNewUDNode( j );
    if DChild <> nil then Owners[i] := DChild.Owner;
    WRoot.AddOneChild(DChild);
  end;
  ClearChilds;
  DirSetLength( ACount );
  for i := 0 to h do begin
    DChild := WRoot.DirChild(i);
    if DChild <> nil then begin
      DChild.Owner := Owners[i];
      if DChild.Owner = nil then //*** Build Uniq Name for new
        DChild.ObjName := BuildUniqChildName( DChild.ObjName );
    end;
    PutDirChildV( i, DChild );
  end;
  WRoot.UDDelete();
end; // end_of procedure TN_UDBase.ReorderChilds

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SameType
//****************************************************** TN_UDBase.SameType ***
// Compare IDB object self data type and given IDB object data type
//
//     Parameters
// ACompObj - comparing IDB object
// Result   - Returns TRUE if IDB object self data type is equal to given IDB 
//            object data type
//
function TN_UDBase.SameType( ACompObj: TN_UDBase ): boolean;
begin

  if (Self = nil)   or
     (ACompObj = nil) or
     (CI <> ACompObj.CI) then
    Result := false
  else
    Result := true;
end; // end_of procedure TN_UDBase.SameType

//************************************** TN_UDBase.SameFields ***
// returns True if all self.fields are the same as given SrcObj.fields
// (SrcObj must be of the same class as self)
//
function TN_UDBase.SameFields( SrcObj: TN_UDBase; AFlags: integer ): boolean;
  Label NotSame;
begin
  Result := True;
  if (ClassFlags <> SrcObj.ClassFlags) then
    Result := false;
  if (((AFlags and $002) <> 0) and (ObjName <> SrcObj.ObjName)) then
    Result := false;
  if (((AFlags and $004) <> 0) and (ObjAliase <> SrcObj.ObjAliase)) then
    Result := false;
  if (((AFlags and $008) <> 0) and (ObjFlags <> SrcObj.ObjFlags)) then
    Result := false;
  if (((AFlags and $010) <> 0) and not CompareMem(@ObjUFlags, @SrcObj.ObjUFlags, sizeof(TK_ObjUFlags))) then
    Result := false;
  if (((AFlags and $020) <> 0) and not CompareMem(@ObjVFlags, @SrcObj.ObjVFlags, sizeof(TK_ObjVFlags))) then
    Result := false;
  if (((AFlags and $040) <> 0) and (RefCounter <> SrcObj.RefCounter)) then
    Result := false;
  if (((AFlags and $080) <> 0) and (Marker <> SrcObj.Marker)) then
    Result := false;
  if (((AFlags and $100) <> 0) and (ObjDateTime <> SrcObj.ObjDateTime)) then
    Result := false;
end; // end_of procedure TN_UDBase.SameFields

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\CompareFields
//************************************************* TN_UDBase.CompareFields ***
// Compare IDB object self fields and given IDB object fields
//
//     Parameters
// ACompObj - comparing IDB object
// AFlags   - base IDB object (TN_UDBase) compare fields
//#F
//   bit1($002) - compare ObjName field
//   bit1($004) - compare ObjAliase field
//   bit1($008) - compare ObjFlags field
//   bit1($010) - compare ObjUFlags field
//   bit1($020) - compare ObjVFlags field
//   bit1($040) - compare RefCounter field
//   bit1($080) - compare Marker field
//   bit1($100) - compare ObjDateTime field
//#/F
// ANPath   - path to self (in compared subnet) including trailing path 
//            delimiter
// Result   - Returns TRUE if IDB object self fields are equal to given IDB 
//            object fields
//
function TN_UDBase.CompareFields( ACompObj: TN_UDBase; AFlags: integer;
                                  ANPath : string ) : Boolean;
begin
  Result := true; // not yet
  if (CI <> ACompObj.CI) then begin
    Result := false;
    if K_AddCompareErrInfo( '"'+ANPath+'" ClassFlags' ) then exit
  end;
  if (((AFlags and $002) <> 0) and (ObjName <> ACompObj.ObjName)) then begin
    Result := false;
    if K_AddCompareErrInfo( '"'+ANPath+'" ObjName="'+ACompObj.ObjName+'"' ) then exit
  end;
  if (((AFlags and $004) <> 0) and (ObjAliase <> ACompObj.ObjAliase)) then begin
    Result := false;
    if K_AddCompareErrInfo( '"'+ANPath+'" ObjAliase="'+ACompObj.ObjAliase+'"' ) then exit
  end;
  if (((AFlags and $008) <> 0) and (ObjFlags <> ACompObj.ObjFlags)) then begin
    Result := false;
    if K_AddCompareErrInfo( '"'+ANPath+'" ObjFlags' ) then exit
  end;
  if (((AFlags and $010) <> 0) and not CompareMem(@ObjUFlags, @ACompObj.ObjUFlags, sizeof(TK_ObjUFlags))) then begin
    Result := false;
    if K_AddCompareErrInfo( '"'+ANPath+'" ObjUFlags' ) then exit
  end;
  if (((AFlags and $020) <> 0) and not CompareMem(@ObjVFlags, @ACompObj.ObjVFlags, sizeof(TK_ObjVFlags))) then begin
    Result := false;
    if K_AddCompareErrInfo( '"'+ANPath+'" ObjVFlags' ) then exit
  end;
  if (((AFlags and $040) <> 0) and (RefCounter <> ACompObj.RefCounter)) then begin
    Result := false;
    if K_AddCompareErrInfo( '"'+ANPath+'" RefCounter' ) then exit
  end;
  if (((AFlags and $080) <> 0) and (Marker <> ACompObj.Marker)) then begin
    Result := false;
    if K_AddCompareErrInfo( '"'+ANPath+'" Marker' ) then exit
  end;
  if (((AFlags and $100) <> 0) and (ObjDateTime <> ACompObj.ObjDateTime)) then begin
    Result := false;
    if K_AddCompareErrInfo( '"'+ANPath+'" ObjDateTime' ) then exit
  end;
end; // end_of procedure TN_UDBase.CompareFields

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\CompareTree
//*************************************************** TN_UDBase.CompareTree ***
// returns True if all self.fields are the same as given SrcObj.fields (SrcObj 
// must be of the same class as self) Compare IDB object self fields and childs 
// Subnet and given IDB object fields  and childs Subnet
//
//     Parameters
// ACompObj - comparing IDB object
// AFlags   - base IDB object (TN_UDBase) compare fields
//#F
//   bit0($001) - compare root level flag
//   bit1($002) - compare ObjName field
//   bit1($004) - compare ObjAliase field
//   bit1($008) - compare ObjFlags field
//   bit1($010) - compare ObjUFlags field
//   bit1($020) - compare ObjVFlags field
//   bit1($040) - compare RefCounter field
//   bit1($080) - compare Marker field
//   bit1($100) - compare ObjDateTime field
//#/F
// ANPath   - path to self (in compared IDB Subnet) including trailing path 
//            delimiter
// Result   - Returns TRUE if IDB object self fields and childs Subnet are equal
//            to given IDB object fields and childs Subnet
//
function TN_UDBase.CompareTree( ACompObj: TN_UDBase; AFlags: integer = $FF;
                                ANPath : string = K_udpPathDelim ): Boolean;
var
  i, h : Integer;
  DE, SDE : TN_DirEntryPar;
  mes1 : string;
begin
  K_CompareTreeFlags := AFlags and $FFFFFFFE;

  Result := true;
  if (ACompObj = Self) then Exit;
  if (AFlags and 1) <> 0 then
    K_AddCompareErrInfo( '' ) //*** Init Errors List
  else begin
    if ACompObj = nil then begin
      Result := false;
      K_AddCompareErrInfo( '"'+ANPath+'" compared object is empty' );
      Exit;
    end else if Self = nil then begin
      Result := false;
      K_AddCompareErrInfo( '"'+ANPath+ '" Self is empty' );
      Exit;
    end else begin
      ANPath := ANPath + ObjName + K_udpPathDelim;
      Result := CompareFields( ACompObj, K_CompareTreeFlags, ANPath );
      if not Result and K_CompareStopFlag then Exit;
    end;
  end;

  K_UDLoopProtectionList.Add(Self);
  h := DirHigh();
  for i := 0 to h do begin
    GetDirEntry( i, DE );
    ACompObj.GetDirEntry( i, SDE );
    mes1 := 'Entries at "'+ANPath + K_udpDEIndexDelim+IntToStr(i) + K_udpPathDelim +'" have not equal ';
    if DE.DEFlags <> SDE.DEFlags then begin
      Result := false;
      if K_AddCompareErrInfo( mes1 +'DEFlags' ) then break;
    end;
{
    if not CompareMem( @DE.DEUFlags, @SDE.DEUFlags, sizeof(TK_DEUFlags) ) then begin
      Result := false;
      if K_AddCompareErrInfo( mes1 +'DEUFlags' ) then break;
    end;
}
    if DE.DEName <> SDE.DEName then begin
      Result := false;
      if K_AddCompareErrInfo( mes1 +'DEName' ) then break;
    end;
    if DE.DECode <> SDE.DECode then begin
      Result := false;
      if K_AddCompareErrInfo( mes1 +'DECode' ) then break;
    end;

    if (K_UDLoopProtectionList.IndexOf(DE.Child) = -1) and
       not DE.Child.CompareTree( SDE.Child, K_CompareTreeFlags, ANPath ) then
      Result := false;

    if not Result and K_CompareStopFlag then break;

  end;

  with K_UDLoopProtectionList do Delete(Count - 1);

end; // end_of procedure TN_UDBase.CompareTree

//*************************************** TN_UDBase.SaveToStrings ***
// save text representation of self to TStrings obj
//
procedure TN_UDBase.SaveToStrings( Strings: TStrings; Mode : Integer = 0 );
var
  i, j, Ind, NumInCol, NumCols, NC: integer;
  Str: string;
begin
  if mode = 0 then
  begin
    Str := ' Name:' + ObjName + '   Aliase:"' + ObjAliase + '"';
    if RefPath <> '' then
      Str := Str + '   RefPath:' + RefPath;
    Strings.Add( Str );
    Strings.Add( Format( ' Type=%s  SelfAdr=$%.8X', [ClassName, Integer(self)] ));
    Strings.Add( Format( ' RefC=%d Owner=$%.8X ClassFlags=$%.8X ObjFlags=$%.8X',
                           [RefCounter, Integer(Owner), ClassFlags, ObjFlags] ));
//    Strings.Add( ' Path:' + K_CurArchive.GetRefPathToObj( Self ) );
    Strings.Add( ' Path:' + K_GetPathToUObj( Self, K_CurArchive ) );
    Str := ' Date: ' + DateTimeToStr( ObjDateTime );

    NC := DirLength();
    if NC > 0 then
    begin
      Strings.Add( Format ( '%s,  %d Children:',  [Str, NC] ));
      NumCols := Min( 6, NC );
      NumInCol := (NC-1) div NumCols + 1;

      for i := 0 to NumInCol-1 do // along Rows
      begin
        Str := '';
        for j := 0 to NumCols-1 do // along current Row
        begin
          Ind := j*NumInCol + i;
          Str := Str + Format( '  %.2d $%.8X', [Ind, Integer(DirChild(Ind))] );
        end; // for j := 0 to NumCols-1 do // along current Row
        Strings.Add( Str );
      end; // for i := 0 to NumInCol-1 do // along Rows
    end else
      Strings.Add( Format ( '%s,  No Children', [Str] ));
  end;
end; // end_of procedure TN_UDBase.SaveToStrings

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\IndexOfChildType
//********************************************** TN_UDBase.IndexOfChildType ***
// Search IDB object directory entry index by given IDB object ClassFlags field
//
//     Parameters
// AClassFlags - ClassFlags field value
// AStart      - start directory entry index for search
// ACount      - number of directory entries for search
// Result      - Returns index of found directory entry. If no proper child 
//               object found then resulting value is -1.
//
function TN_UDBase.IndexOfChildType( AClassFlags: Longword; AStart : Integer = 0;
                         ACount : Integer = 0 ): integer;
var
  i, h: integer;
  Childs : TN_UDArray;
begin
  Result := -1; // not found flag
  if Self = nil then Exit;
  h := DirHigh;
  GetDirFieldArray( Childs, K_DEFisChild );
  AClassFlags := AClassFlags and $FF;
  if ACount <> 0 then
    h := Min( h, ACount + AStart - 1 );
  for i := AStart to h do
  begin
    if (Childs[i] = nil) then Continue;
    if Childs[i].ClassFlags = K_UDRefCI then RestoreDRefToChild( i, Childs[i] );
    if AClassFlags = (Childs[i].ClassFlags and $FF) then
    begin
      Result := i;
      Exit;
    end;
  end;
end; // end_of function TN_UDBase.IndexOfChildType

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\IndexOfChildObjName
//******************************************* TN_UDBase.IndexOfChildObjName ***
// Search IDB object directory entry index by given IDB object ObjName field
//
//     Parameters
// AObjName     - ObjName field value
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
// AStart       - start directory entry index for search
// ACount       - number of directory entries for search
// Result       - Returns index of found directory entry. If no proper child 
//                object found then resulting value is -1.
//
function TN_UDBase.IndexOfChildObjName( AObjName: string;
                  AObjNameType : TK_UDObjNameType = K_ontObjName;
                  AStart : Integer = 0; ACount : Integer = 0 ): integer;
var
  i, h: integer;
  Childs : TN_UDArray;
  CName : string;
begin
  Result := -1; // not found flag
  if Self = nil then Exit;
  h := DirHigh();
  GetDirFieldArray( Childs, K_DEFisChild );
  if ACount <> 0 then
    h := Min( h, ACount + AStart - 1 );
  for i := AStart to h do
  begin
    if (Childs[i] = nil) then Continue;
//*** special code for fast UD Search Dupliacate
    if Childs[i].ClassFlags = K_UDRefCI then RestoreDRefToChild( i, Childs[i] );
    CName := Childs[i].ObjName;
    if (AObjNameType = K_ontObjAliase) or
       ( (AObjNameType = K_ontObjUName) and
         (Childs[i].ObjAliase <> '') )then
      CName := Childs[i].ObjAliase;
    if SameText(AObjName, CName) then
    begin
      Result := i;
      Exit;
    end;
  end; // for i := AStart to h do
end; // end_of function TN_UDBase.IndexOfChildObjName

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\DirChildByObjName
//********************************************* TN_UDBase.DirChildByObjName ***
// Get IDB object child by given IDB object ObjName field
//
//     Parameters
// AObjName     - ObjName field value
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
// AStart       - start directory entry index for search
// ACount       - number of directory entries for search
// Result       - Returns found child object. If no proper child object found 
//                then resulting value is nil.
//
function TN_UDBase.DirChildByObjName( AObjName: string;
                  AObjNameType : TK_UDObjNameType = K_ontObjName;
                  AStart : Integer = 0; ACount : Integer = 0 ): TN_UDBase;
begin
  Result := DirChild( IndexOfChildObjName( AObjName, AObjNameType,
                                            AStart, ACount ) );
end; // end_of function TN_UDBase.DirChildByObjName

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\IsDEProtected
//************************************************* TN_UDBase.IsDEProtected ***
// Ñheck if given directory entry is protected or corresponding child object is 
// protected
//
//     Parameters
// ADE      - directory entry data
// ACheckDE - check directory entry protection flag
// Result   - Returns:
//#F
//     K_DRisOK           - no data protection
//     K_DRisDEProtected  - directory entry is protected
//     K_DRisObjProtected - child IDB object is protected
//#/F
//
function  TN_UDBase.IsDEProtected( const ADE: TN_DirEntryPar;
                                   ACheckDE : Boolean = true ) : TK_DEReplaceResult;
begin
  Result := K_DRisOK;
  if ACheckDE and
     ((ADE.DEFlags and K_fpDEProtected) <> 0) then
    Result := K_DRisDEProtected
  else begin
    if ADE.Child = nil then Exit;
    if ((ADE.Child.ObjFlags and K_fpObjProtected) <> 0) or
       ((ADE.Parent <> nil)            and
        (ADE.Parent = ADE.Child.Owner) and
        (ADE.Child.RefCounter > 1)) then
      Result := K_DRisObjProtected;
  end;
end; // end procedure TN_UDBase.IsDEProtected

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\DeleteDirEntry
//************************************************ TN_UDBase.DeleteDirEntry ***
// Delete given directory entry by removing directory entry or removing child 
// only
//
//     Parameters
// AInd         - directory entry index
// AVCode       - directory entry visual code value (if AInd is -1 then AVCode 
//                is used to define index of directory entry fore deletion)
// ARemoveEntry - remove directory entry flag (if FALSE then directory entry 
//                child will be set to nil instead of remove)
// Result       - Returns:
//#F
//     K_DRisOK           - given directory entry is removed or child is niled
//     K_DRisDEProtected  - directory entry is protected
//     K_DRisObjProtected - child IDB object is protected
//#/F
//
function  TN_UDBase.DeleteDirEntry( AInd : Integer; AVCode : Integer = 0;
                          ARemoveEntry : Boolean = true ) : TK_DEReplaceResult;
var
  Child : TN_UDBase;
  DE : TN_DirEntryPar;
begin
  if AInd = -1 then
    AInd := IndexOfDEField( AVCode, K_DEFisVCode );
  assert( AInd <> -1, 'Cannot find Dir Entry index using VCode' );
  if not (K_udoUNCDeletion in K_UDOperateFlags) then begin
    GetDirEntry( AInd, DE );
    Result := IsDEProtected( DE, ARemoveEntry );
    if (Result <> K_DRisOK) and
       (K_udoDelWarning in K_UDOperateFlags) then begin
  // Show warning dialog
    end;
    if Result <> K_DRisOK then Exit;
  end;

  if ARemoveEntry then
    Result := RemoveDirEntry( AInd )
  else begin
    Child := nil;
    Result := ReplaceDirChild( AInd, Child );
  end;
  Result := TK_DEReplaceResult( Max( Ord(K_DRisOK), Ord(Result) ) );
end; // end procedure TN_UDBase.DeleteDirEntry

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\DeleteOneChild
//************************************************ TN_UDBase.DeleteOneChild ***
// Delete given child object by removing directory entry or removing child only
//
//     Parameters
// AChild       - deleteing child object
// ARemoveEntry - remove directory entry flag (if FALSE then directory entry 
//                child will be set to nil instead of remove)
// Result       - Returns index of deleting directory entry
//
function  TN_UDBase.DeleteOneChild ( const AChild: TN_UDBase;
                                     ARemoveEntry : Boolean = true ) : Integer;
begin
  Result := IndexOfDEField( AChild );
  if Result = -1 then Exit;
  if ( DeleteDirEntry( Result, 0, ARemoveEntry ) <> K_DRisOK ) then
    Result := -1;
end; // end procedure TN_UDBase.DeleteOneChild

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\InsOneChild
//*************************************************** TN_UDBase.InsOneChild ***
// Insert new child object before child given by directory entry index
//
//     Parameters
// AInd   - directory entry index for child insertion (if =-1 then add new entry
//          to the end of directory)
// AChild - inserting child object
// Result - Returns index of inserting directory entry
//
function TN_UDBase.InsOneChild( AInd : Integer; AChild: TN_UDBase ) : Integer;
begin
  Result := InsertEmptyEntries ( AInd, 1 );
  if AChild = nil then Exit;
  PutDirChild( Result, AChild );
end; // end function TN_UDBase.InsOneChild

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetEmptyDEInd
//************************************************* TN_UDBase.GetEmptyDEInd ***
// Get empty directory entry index
//
//     Parameters
// ASSInd - start directory entry index for empty entry seach (if -1 then add to
//          then end of childs directory)
// Result - Returns index of empty directory entry
//
function TN_UDBase.GetEmptyDEInd( ASSInd : Integer = -1 ) : Integer;
var
  SNode : TN_UDBase;
  Ind : Integer;
  DEFlags : Integer;
begin
  Result := -1;
  if ASSInd <> -1 then
  begin
    SNode := nil;
    Result := Self.IndexOfDEField( SNode, K_DEFisChild, ASSInd );
  end
  else
  begin
    Ind := DirHigh;
    if Ind >= 0 then
    begin
      GetDEField( Ind, DEFlags, K_DEFisChild );
      if DEFlags = 0 then begin
        GetDEField( Ind, DEFlags, K_DEFisFlags );
        if (DEFlags and K_fpDEProtected) = 0 then Result := Ind;
      end;
    end;
  end;
  if Result = -1 then Result := InsertEmptyEntries ( -1, 1 );
end; // end function TN_UDBase.GetEmptyDEInd

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddOneChild
//*************************************************** TN_UDBase.AddOneChild ***
// Add new child object to the childs directory
//
//     Parameters
// AChild - adding child object
// ASSInd - start directory entry index for empty entry seach (if -1 then add to
//          then end of childs directory)
// Result - Returns inserting child IDB object
//
function TN_UDBase.AddOneChild( AChild: TN_UDBase; ASSInd : Integer = -1 ) : TN_UDBase;
var Ind : Integer;
begin
  Ind := GetEmptyDEInd( ASSInd );
  PutDirChild( Ind, AChild );
  Result := DirChild( Ind );
end; // end function TN_UDBase.AddOneChild

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddOneChildV
//************************************************** TN_UDBase.AddOneChildV ***
// Add new child object to the childs directory and create Visual Nodes for 
// added child
//
//     Parameters
// AChild      - adding child object
// AVNodeFalgs - new Visual Nodes state flags
// AVTree      - Visual Tree for new VNode creating
// ASSInd      - start directory entry index for empty entry seach (if -1 then 
//               add to then end of childs directory)
// Result      - Returns inserting child IDB object
//
function TN_UDBase.AddOneChildV( AChild: TN_UDBase; AVNodeFalgs : TK_VNodeStateFlags = [];
                            AVTree : TN_VTree = nil; ASSInd : Integer = -1 ) : TN_UDBase;
var
  Ind : Integer;
begin
  Result := AChild;
  Ind := GetEmptyDEInd( ASSInd );
  PutDirChild( Ind, AChild );
//??  Result := DirChild( Ind );
  AddChildVNodes( Ind, AVNodeFalgs, AVTree );
end; // end function TN_UDBase.AddOneChildV

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\ClearChilds
//*************************************************** TN_UDBase.ClearChilds ***
// Clear given child objects from directory entries
//
//     Parameters
// ASInd         - start index of directory entry to clear
// ANewDirLength - resulting number of entries in IBD object directory
// AClearDir     - clear direction
//
// If AClearDir >= 0 then all child objects starting from given index to the end
// of directory will be cleared. If AClearDir < 0 then all child objects
// starting from given index to the begin of directory will be cleared.
//
procedure TN_UDBase.ClearChilds( ASInd : Integer = 0;
                                 ANewDirLength : Integer = -1;
                                 AClearDir : Integer = 0 );
var  {i,} h : Integer;
  DE : TN_DirEntryPar;
begin
  if self = nil then Exit;
  if (ANewDirLength < 0) or (ASInd > ANewDirLength) then ANewDirLength := ASInd;
  h := DirHigh;
  K_ClearDirEntry( DE );

  if AClearDir >= 0 then
  begin
    AClearDir := 1;
    Inc(h);
    ASInd := Min( ASInd, h );
  end
  else
  begin
    AClearDir := -1;
    ASInd := h;
    h := -1;
  end;

  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );
  while ASInd <> h do
  begin
    assert( PutDirEntry( ASInd, DE ) <= K_DRisOK, 'Attempt to clear used dir entry');
    ASInd := ASInd + AClearDir;
  end;
  K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );

  DirSetLength( ANewDirLength );
end; // end of procedure TN_UDBase.ClearChilds

//************************************** TN_UDBase.InsertOneChildBefore ***
// Insert NewChild to Self before PosChild
//
//     Parameters
// APosChild - child before which new child should be placed
// ANewChild - new child to insert
// Result    - Returns index of new child
//
function TN_UDBase.InsertOneChildBefore( APosChild, ANewChild: TN_UDBase ) : Integer;
begin
  Result := InsOneChild( IndexOfDEField( APosChild, K_DEFisChild), ANewChild );
end; // end procedure TN_UDBase.InsertOneChildBefore

//************************************** TN_UDBase.InsertOneChildAfter ***
// Insert NewChild to Self after PosChild
//
//     Parameters
// APosChild - child after which new child should be placed
// ANewChild - new child to insert
// Result    - Returns index of new child
//
function TN_UDBase.InsertOneChildAfter( APosChild, ANewChild: TN_UDBase ) : Integer;
var
  Ind : Integer;
begin
  Ind := IndexOfDEField(APosChild, K_DEFisChild);
  if Ind >= 0 then Inc(Ind);
  Result := InsOneChild( Ind, ANewChild );
end; // end procedure TN_UDBase.InsertOneChildAfter

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\PrepareObjName
//************************************************ TN_UDBase.PrepareObjName ***
// Replace given symbols in IDB object ObjName field and shorten it if needed
//
//     Parameters
// ANameLength - new IDB object ObjName field length
// ASkipChars  - string of chars which replacement is needed
//
// Build "correct" IDB object OBjname by relacing given chars to "_".
//
procedure TN_UDBase.PrepareObjName( ANameLength : Integer = 0;
                                    ASkipChars : string = '' );
var
  FChars : string;
begin
  FChars := K_udpPathDelim +
            K_udpDECodeDelim +
            K_udpDEIndexDelim +
            K_udpDENameDelim +
            K_udpDataArrayDelim +
            K_udpObjTypeNameDelim +
            K_udpCursorDelim +
            K_udpFieldDelim +
            ASkipChars;
    if (ANameLength > 0) and (ANameLength <= Length( ObjName )) then
      ObjName := Copy( ObjName, 1, ANameLength );

    K_ReplaceStringChars( ObjName, FChars, '_' );
end; // end procedure TN_UDBase.PrepareObjName

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\BuildUniqChildName
//******************************************** TN_UDBase.BuildUniqChildName ***
// Build given name field (ObjName, ObjAliase, etc.) uniq amoung all child 
// objects
//
//     Parameters
// AName        - uniq name start value
// AChild       - child object which uniq name have to be done
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns name uniq amoung self child objects
//
// If AChild is defined (AChild <> nil) then uniq name is generated for this 
// child object. If AChild is not defined (AChild = nil) then only uniq string 
// is generated. This string can be used to identify object that will be in 
// future added as a new child.
//
function TN_UDBase.BuildUniqChildName( AName : string; AChild: TN_UDBase = nil;
            AObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
var
  i, SameCount, MainSize, h: Integer;
  WChild: TN_UDBase;
  WName : string;

label Fin;
begin
  if AChild <> nil then AName := AChild.GetUName( AObjNameType );
  MainSize := K_GetPureNameSize( AName );
  Result := AName;
  if AChild <> nil then AChild.SetUName( '', AObjNameType );
  if (IndexOfChildObjName( Result, AObjNameType ) = -1) and
     (MainSize < Length(AName)) then goto Fin; // Name has Number suffix and is Unique

  SameCount := 0;
  h := DirHigh;
  for i := 0 to h do // calc SameCount - number of same Names
  begin
    WChild := DirChild(i);
    if (WChild <> nil) then begin
      WName := WChild.GetUName( AObjNameType );
      if (K_GetPureNameSize( WName ) = MainSize) and
         (StrLComp( PChar(AName), PChar(WName), MainSize ) = 0) then
        Inc(SameCount);
    end;
  end;
  if (SameCount > 0) or (Length(AName) = 0) then
  begin
    repeat
      Result := K_BuildUniqName(AName, MainSize, SameCount);
      Inc(SameCount);
    until IndexOfChildObjName( Result, AObjNameType ) = -1;
  end;
Fin:
  if AChild <> nil then AChild.SetUName( Result, AObjNameType );
end; // end procedure TN_UDBase.BuildUniqChildName

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SetUniqChildName
//********************************************** TN_UDBase.SetUniqChildName ***
// Set given name field (ObjName, ObjAliase, etc.) to given child object uniq 
// amoung all childs
//
//     Parameters
// AChild       - child object which uniq name have to be done
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
//
procedure TN_UDBase.SetUniqChildName ( AChild: TN_UDBase;
                      AObjNameType : TK_UDObjNameType = K_ontObjName );
begin
  if AChild = nil then Exit;
  BuildUniqChildName( '', AChild, AObjNameType );
end; // end procedure TN_UDBase.SetUniqChildName

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SetChildsUniqNames
//******************************************** TN_UDBase.SetChildsUniqNames ***
// Set given uniq name fields (ObjName, ObjAliase, etc.) to given child objects
//
//     Parameters
// AFlags       - flags that defines set of childs used to generate uniq names
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
//
procedure TN_UDBase.SetChildsUniqNames( AFlags : TK_UniqChildNameFlagSet = [];
                             AObjNameType : TK_UDObjNameType = K_ontObjName );
var
  i, h : Integer;
  DE : TN_DirEntryPar;
begin
  h := DirHigh;
  for i := 0 to h do begin
    GetDirEntry(i, DE );
    if (DE.Child <> nil)                                          and
       (not (K_sunUseMarked in AFlags) or (DE.Child.Marker <> 0)) and
       (not (K_sunUseOwnChilds in AFlags) or (DE.Child.Owner = Self)) then
      BuildUniqChildName( '', DirChild(i), AObjNameType );
  end;
end; // end procedure TN_UDBase.SetChildsUniqNames

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SetUniqDEName
//************************************************* TN_UDBase.SetUniqDEName ***
// Set uniq DEName field to given directory entry
//
//     Parameters
// AInd - given directory entry index
//
procedure TN_UDBase.SetUniqDEName ( AInd : Integer );
var
  si, i, h, SameCount, MainSize, WSize: integer;
  WName, ChildName: string;
begin
  GetDEField( AInd, ChildName, K_DEFisName );

  MainSize := K_GetPureNameSize( ChildName );
  SameCount := 0;
  h := DirHigh;

  si := 0;

  for i := si to h do // calc SameCount - number of same Names
  begin
    GetDEField( i, WName, K_DEFisName );
    if (i <> AInd) then begin
      WSize := K_GetPureNameSize( WName );
      if (WSize = MainSize) and
         (StrLComp( PChar(ChildName), PChar(WName),
                        MainSize ) = 0) then Inc(SameCount);
    end;
  end;

  if (SameCount > 0) or (Length(ChildName) = 0) then
  begin
    WName := '';
    PutDEField( AInd, Integer(WName), K_DEFisName );
    repeat
      WName := K_BuildUniqName(ChildName, MainSize, SameCount);
      Inc(SameCount);
    until IndexOfDEField( WName,  K_DEFisName ) = -1;

    PutDEField( AInd, Integer(WName), K_DEFisName );
  end;
end; // end of procedure TN_UDBase.SetUniqDEName

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddDEToText
//*************************************************** TN_UDBase.AddDEToText ***
// Add IDB child object tag, directory entry fields and self fields to serial 
// text buffer
//
//     Parameters
// ASBuf     - serial text buffer object
// ADE       - IDB object directory entry data
// AChildTag - resulting string with object tag for future adding close tag to 
//             serial text buffer
// Result    - Returns TRUE if child objects serialization is needed
//
// Do not call AddDEToText directly, it is used automatically in 
// TN_UDBase.AddChildsToText. Self fields to serial text buffer are adding by 
// TN_UDBase.AddToText method.
//
function TN_UDBase.AddDEToText( ASBuf: TK_SerialTextBuf; var ADE : TN_DirEntryPar;
                out AChildTag : string ) : Boolean;
var
  i, ww, ClassInd : Integer;
//  wwe : TK_UEFlags;
  AddChild : Boolean;
  Child : TN_UDBase;
begin
  Result := False;
  AddChild := false;
  Child := ADE.Child;
  ClassInd := 0;
  if (Child = nil) or (Child = N_EmptyObj) then
    AChildTag := K_tbEmptyTag
  else begin
    K_BuildDEChildRef( ADE );
    ClassInd := ADE.Child.CI;
    if not(ADE.Child is N_ClassRefArray[ClassInd]) then
    begin // error in obj Class Flags
      K_ShowMessage( 'Save to text -> Error in obj Class Flags  for ' + ADE.Child.ClassName );
      assert(false);
      Exit;
    end;
//    ChildTag := N_ClassTagArray[ClassInd];
    K_AddUObjToUsedTypesList( ADE.Child, ASBuf.SBUsedTypesList );
    AChildTag := K_GetUObjTagName(ADE.Child);

    AddChild := true;
  end;

  ASBuf.AddTag( AChildTag );

  if ADE.DECode <> 0 then ASBuf.AddTagAttr( K_tbDECode, ADE.DECode, K_isInteger );

  if Length(ADE.DEName) > 0 then ASBuf.AddTagAttr( K_tbDEName, ADE.DEName );

  if ADE.DEFlags <> 0 then ASBuf.AddTagAttr( K_tbDEFlags, ADE.DEFlags, K_isHex );
{
  if (K_txtSysFormat in K_TextModeFlags) or
     (K_txtSaveUFlags in K_TextModeFlags) then
  begin
    for i := 0 to High(ADE.DEUFlags) do
    begin
      wwe := ADE.DEUFlags[i];
      if wwe <> 0 then ASBuf.AddTagAttr( K_tbDEUFlags+IntToStr(i), wwe, K_isHex );
    end;
  end;
}
  if (K_txtSysFormat in K_TextModeFlags) or
     (K_txtSaveVFlags in K_TextModeFlags) then
  begin
    for i := 0 to High(ADE.DEVFlags) do
    begin
      ww := ADE.DEVFlags[i];
      if ww <> 0 then ASBuf.AddTagAttr( K_tbDEVFlags+IntToStr(i), ww, K_isHex );
    end;
  end;

  if not AddChild then Exit;

  if (ADE.Child.ObjName <> '') and
     not (K_txtXMLMode in K_TextModeFlags) and
     not (K_txtSkipCloseTagName in K_TextModeFlags) then
    AChildTag := AChildTag + ' ' + ADE.Child.ObjName;
  Result := ADE.Child.AddToText( ASBuf, false );

  if (ADE.Child.ObjFlags and K_fpObjSkipChildsSave) <> 0 then
    Result := false;

  if (ClassInd = K_UDRefCI) then
  begin
    if (Integer(Child.ClassFlags) <> ClassInd) then
      ADE.Child.UDDelete; // delete Node created only for data serialization (unload)
  end;

end; // end_of procedure TN_UDBase.AddDEToText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetSubTreeFromText
//******************************************** TN_UDBase.GetSubTreeFromText ***
// Get IDB child object directory entry fields, self object and its childs from 
// serial text buffer
//
//     Parameters
// ASBuf     - serial text buffer object
// AChildTag - object tag for parsing object close tag after getting all childs
// Result    - Returns TRUE if future close tag parsing is needed (childs are 
//             absent in serial text buffer)
//
// Do not call GetSubTreeFromText directly, it is used automatically in 
// TN_UDBase.GetChildSubTreeFromText. Self object fields are get from serial 
// text buffer by TN_UDBase.GetFromText method.
//
function TN_UDBase.GetSubTreeFromText( ASBuf: TK_SerialTextBuf;
                        const AChildTag : string; AChildInd: integer ) : boolean;
var
  i, ww, ClassRefInd: integer;
//  wwe : TK_UEFlags;
  DE : TN_DirEntryPar;
  LoadChild : Integer;
begin
  Result := true;
//*** load dir entry data - for future
  K_ClearDirEntry( DE );
  ASBuf.GetTagAttr( K_tbDEName, DE.DEName );
  ASBuf.GetTagAttr( K_tbDECode, DE.DECode, K_isInteger );
  ASBuf.GetTagAttr( K_tbDEFlags, DE.DEFlags, K_isInteger );
{
  for i := 0 to High(DE.DEUFlags) do
  begin
    if ASBuf.GetTagAttr( K_tbDEUFlags+IntToStr(i), wwe, K_isInteger ) then
      DE.DEUFlags[i] := wwe;
  end;
}
  for i := 0 to High(DE.DEVFlags) do
  begin
    if ASBuf.GetTagAttr( K_tbDEVFlags+IntToStr(i), ww, K_isInteger ) then
      DE.DEVFlags[i] := ww;
  end;

  if (AChildTag <> K_tbEmptyTag) then
  begin
    if not (K_txtParseXMLTree in K_TextModeFlags) then begin
      ClassRefInd := K_GetUObjCIByTagNameExt( AChildTag, ASBuf );
      LoadChild := GetFromText( ASBuf, N_ClassRefArray[ClassRefInd], DE.Child );
      if LoadChild >= 0 then
      begin
        with DE, Child do begin
          Result := AddLoadingToSLSRList();
          if not Result then begin
            GetChildSubTreeFromText( ASBuf, AChildTag, false, LoadChild );
            if (ObjFlags and K_fpObjSLSRFlag) <> 0 then // Add Loaded Sections Uses
              SLSRAddUses( K_CurSLSRList );
          end;
        end;
      end;
    end else begin
      DE.Child := TK_UDStringList.Create;
      DE.Child.ObjName := AChildTag;
      TK_UDStringList(DE.Child).SL.Assign( ASBuf.AttrsList );
      DE.Child.GetChildSubTreeFromText( ASBuf, AChildTag, false, 0 );
      Result := FALSE;
    end;
  end;

  PutDirEntry( AChildInd, DE );

end; // end_of procedure TN_UDBase.GetSubTreeFromText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddChildsToText
//*********************************************** TN_UDBase.AddChildsToText ***
// Add IDB object childs to serial text buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// ATag   - object XML tag value
// AInd   - start child index
// ACount - serialized childs count
//
// Do not call AddChildsToText directly, it is used automatically in 
// TN_UDBase.SaveTreeToTextFile and K_SaveTreeToText.
//
procedure TN_UDBase.AddChildsToText( ASBuf: TK_SerialTextBuf; ATag : string = '';
                                     AInd : Integer = 0; ACount : Integer = 0 );
var
  i, HInd : integer;
  ChildTag : string;
  DE : TN_DirEntryPar;
  AddChildsScale : TN_BArray;
begin
  if ATag <> '' then ASbuf.AddTag( ATag );
  AInd := Max( 0, AInd );

  if Marker = 0 then // Child obj was not added yet, add it
  begin
    SetMarker(1);                 // mark saved object
//    SBuf.SaveRefList.Add( self ); // for future clearing Marker field after saving
  end;

  HInd := DirHigh;
  if ACount <= 0 then
    ACount := HInd
  else
    Dec(ACount);
  HInd := Min( HInd, AInd + ACount );

  PrepSerializedChildsScale( AInd, HInd,  AddChildsScale );

  for i := AInd to HInd do  begin
//*** check current save flags
    if AddChildsScale[i - AInd] <> 0 then Continue;
    GetDirEntry( i, DE );
    with DE, Child do begin
      if (K_txtXMLMode in K_TextModeFlags) and
         ((ClassFlags and K_SkipSelfSaveBit) <> 0) then Continue;

      ASBuf.AddEOL( false );
      if (Child <> nil) then begin
        if (ClassFlags and K_SkipSelfSaveBit) <> 0 then
          Child := nil
        else if ((ObjFlags and K_fpObjSLSRFlag) <> 0) and
                (K_gcfSetJoinToAllSLSR in K_UDGControlFlags) then
          ObjFlags := ObjFlags or K_fpObjSLSRJoin;
      end;

      if AddDEToText( ASBuf, DE, ChildTag ) and
         ( ((ObjFlags and K_fpObjSLSRFlag) =  0) or
           ((ObjFlags and K_fpObjSLSRJoin) <> 0) or
           (K_gcfJoinAllSLSR in K_UDGControlFlags) ) then begin
         if (ObjFlags and K_fpObjSLSRFlag) <>  0 then
           K_InfoWatch.AddInfoLine( 'Save "' + GetUName+ '" joined' );
        AddChildsToText( ASBuf );
      end;
      ASBuf.AddTag( ChildTag, tgClose );
    end;
  end;
  if ATag <> '' then ASbuf.AddTag( ATag, tgClose );

end; // end_of procedure TN_UDBase.AddChildsToText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetChildSubTreeFromText
//*************************************** TN_UDBase.GetChildSubTreeFromText ***
// Get IDB object childs from serial text buffer
//
//     Parameters
// ASBuf          - serial text buffer object
// ATag           - object XML tag value (if not given then used object internal
//                  tag)
// ACheckStartTag - if TRUE then tag is parsed from text buffer first
// AInd           - start child index
// ACount         - serialized childs count
//
// Do not call AddChildsToText directly, it is used automatically in 
// TN_UDBase.LoadTreeFromTextFile and K_LoadTreeFromTextProc.
//
procedure TN_UDBase.GetChildSubTreeFromText( ASBuf: TK_SerialTextBuf; const ATag : string = '';
                                             ACheckStartTag : Boolean = true;
                                             AInd : Integer = 0; ACount : Integer = 0  );
var
  i, NumExist, NumLoad : integer;
  CTag, Tag, TTag : string;
  TagType : TK_STBufTagType;
label TagError;
begin

  TTag := ATag;
  if TTag = '' then
    TTag := N_ClassTagArray[ClassFlags and $FF];
  if ASBuf.CheckPrevParsedTagCloseFlag( TTag ) then Exit;
  if ACheckStartTag then begin
    ASBuf.GetTag( CTag, TagType );
    if (TTag <> Ctag) or (TagType <> tgOpen) then
      raise TK_LoadUDDataError.Create(
                  ASBuf.PrepErrorMessage( 'Wrong open data tag "'+Ctag+'" instead of "'+TTag+'" -> Error in line ' ) );
  end;

  NumExist := DirLength;
  i := AInd;
  NumLoad := i + ACount;
  repeat
    ASBuf.GetTag( Tag, TagType );
    if TagType <> tgOpen then begin// tgClolse or tgEOF
      if TTag <> Tag then
        raise TK_LoadUDDataError.Create(
                  ASBuf.PrepErrorMessage( 'Wrong close tag "'+TTag+'" for "'+Tag+'" -> Error in line ' ) );
      Exit;
    end;

    if i >= NumExist then begin // increase dir entries number
      Inc(NumExist);
      DirSetLength( NumExist );
    end;

    if GetSubTreeFromText( ASBuf, Tag, i ) then
      ASBuf.GetSpecTag( Tag, tgClose );

    Inc( i );
    ASBuf.ShowProgress;
  until (ACount > 0) and (i >= NumLoad);
end; // end_of procedure TN_UDBase.GetChildTreeFromText

{
//************************************** TN_UDBase.AddSubTreeToSbuf ***
// Add IDB object child objects to serial binary buffer during IDB Subnet serialization
//
//     Parameters
// ASBuf - serial binary buffer object
//
// Do not call AddSubTreeToSbuf directly, it is used automatically in some TN_UDBase
// methods for restore direct reference to proper child object.
//
procedure TN_UDBase.AddSubTreeToSbuf( ASBuf: TN_SerialBuf );
begin

//*** start subtree signature tag
  ASBuf.AddTag( K_fTagSubTree );

//*** save Integer for previous file format compatibility
  ASBuf.AddRowInt( 0 );
  Marker := 2;
  try
    AddChildTreeToSBuf( ASBuf );
  except
  end;
  Marker := 0;

end; // end_of procedure TN_UDBase.AddSubTreeToSbuf

//************************************** TN_UDBase.GetSubTreeFromSBuf ***
// restore from file in memory saved by AddSubTreeToSBuf method UObj tree
// and merge it with actual structure
// returns the node -  temporary root of loaded subtree
//
procedure TN_UDBase.GetSubTreeFromSBuf( ASBuf: TN_SerialBuf );
var
  i : integer;
  Tag : Byte;
begin
  ASBuf.GetTag( Tag );
  if tag <> K_fTagSubTree then Exit;
//*** load Integer for previous file format compatibility
  ASBuf.GetRowInt( i );
  ClearChilds();
  GetChildTreeFromSBuf( ASBuf );
end; // end_of procedure TN_UDBase.GetSubTreeFromSBuf
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\LoadSLSFromAnyFile
//******************************************** TN_UDBase.LoadSLSFromAnyFile ***
// Load Subnet of Separately Loaded Subnet root object from section file
//
// If try text (instead of binary) version of section file mode is set then age 
// of binary and text versions of section file are compared. If text version is 
// newer then binary version is used to load IDB Subnet, else dialogue is 
// activate to select file version.
//
procedure TN_UDBase.LoadSLSFromAnyFile;
var
  TXTFileName, FileName : string;
  DLGResult : Word;
  VFileCopyResult : TK_VFileCopyResultCode;
  BinVFile, TxtVFile: TK_VFile;
begin
  FileName := K_ExpandFileName( ObjInfo );
  if (K_gcfTrySLSRSDTFileLoad in K_UDGControlFlags) and
     ((K_fpObjSLSRFText and ObjFlags) = 0) then begin
    TXTFileName := ChangeFileExt( FileName, K_afTxtExt1 );
//    VFileCopyResult := K_VFCompareFilesAge( FileName, TXTFileName );
    K_VFAssignByPath( BinVFile, FileName );
    K_VFAssignByPath( TxtVFile, TXTFileName );
    VFileCopyResult := K_VFCompareFilesAge0( BinVFile, TxtVFile );

    if (VFileCopyResult = K_vfcrDestNewer) or
       (VFileCopyResult = K_vfcrSrcNotFound) then
      DLGResult := mrYes
    else
    if K_VFileExists( TXTFileName ) then
    begin
      DLGResult := mrYes;
      if K_VFileAge0( BinVFile ) > K_VFileAge0( TxtVFile ) then
        DLGResult := MessageDlg( 'Use old ' + TXTFileName + ' section version?',
                                  mtWarning, mbYesNoCancel, 0 );
      if DLGResult <> mrYes then
      begin
        DLGResult := MessageDlg( 'Load ' + FileName + '?' ,
                                 mtWarning, mbYesNoCancel, 0 );
        if DLGResult = mrYes then
          DLGResult := mrNo
        else
          DLGResult := mrCancel;
      end;
    end
    else
    begin
      if K_gcfArchSDTCopy in K_UDGControlFlags then
      begin
        DLGResult := MessageDlg( TXTFileName + ' section is absent. Load *.sdb?',
                                 mtWarning, mbYesNoCancel, 0 );
        if DLGResult = mrYes then
          DLGResult := mrNo
        else
          DLGResult := mrCancel;
      end
      else
        DLGResult := mrNo;
    end;

    case DLGResult of
      mrYes    : FileName := TXTFileName;
      mrCancel : Exit;
    end;
  end;
  K_InfoWatch.AddInfoLine( 'Load "' + GetUName + '" <- ' + FileName );
  LoadTreeFromAnyFile( FileName );
end; // end_of procedure TN_UDBase.LoadSLSFromAnyFile

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SaveTreeToAnyFile
//********************************************* TN_UDBase.SaveTreeToAnyFile ***
// Save object Subnet to file in binary or text format
//
//     Parameters
// ARefsRootObj     - root IDB object for building paths to IDB objects that not
//                    belong to Owners Subtree (is needed if both binary and 
//                    text format file versions are saved)
// AFileName        - file name
// AArchVersionInfo - information about format version
// ASLSSaveFlags    - Separately Loaded Subnets save modes set
// ATXTVersionFlag  - text format flag (if TRUE text version of Subnet will be 
//                    saved)
//
// In binary save mode (ATXTVersionFlag = FALSE) text version will be saved 
// moreover if save text copy global mode (K_gcfArchSDTCopy in 
// K_UDGControlFlags) is true.
//
procedure TN_UDBase.SaveTreeToAnyFile( ARefsRootObj : TN_UDBase;
                                       const AFileName : string;
                                       const AArchVersionInfo : string;
                                       ASLSSaveFlags : TK_UDTreeLSFlagSet;
                                       ATXTVersionFlag : Boolean );
var
  FName : string;
  RefsContext : string;
  Info : string;
begin
    K_RenameExistingFile( AFileName );
    K_ForceFilePath( AFileName );
    if AArchVersionInfo <> '' then // Archive
      Info := 'Save Archive'
    else
      Info := 'Save "' + GetUName + '"';
    Info := Info + ' -> ' + AFileName;
    if not ATXTVersionFlag then begin
      RefsContext := ARefsRootObj.RefPath;
      SaveTreeToFile( AFileName, AArchVersionInfo, ASLSSaveFlags );
      if K_gcfArchSDTCopy in K_UDGControlFlags then begin
        ARefsRootObj.RefPath := RefsContext;
        FName := ChangeFileExt( AFileName, K_afTxtExt1 );
        K_RenameExistingFile( FName );
        SaveTreeToTextFile( FName, K_TextModeFlags,
                            AArchVersionInfo, ASLSSaveFlags );
        Info := Info + ' (+sdt)'
      end;
    end else
      SaveTreeToTextFile( AFileName, K_TextModeFlags,
                                     AArchVersionInfo, ASLSSaveFlags );
    K_InfoWatch.AddInfoLine( Info );
end; // end_of procedure TN_UDBase.SaveTreeToAnyFile

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\LoadTreeFromAnyFile
//******************************************* TN_UDBase.LoadTreeFromAnyFile ***
// Load object Subnet from file in binary or text format
//
//     Parameters
// AFileName     - file name
// ASLSLoadFlags - Separately Loaded Subnets load modes set (only 
//                 [K_lsfSkipAllSLSR, K_lsfJoinAllSLSR] are used)
// Result        - Returns 0 if binary or 1 if text file is loaded
//
function TN_UDBase.LoadTreeFromAnyFile ( const AFileName: string;
                                         ASLSLoadFlags : TK_UDTreeLSFlagSet = [];
                                         ALoadFromProtectedDFile : Boolean = false ) : Integer;
var
  ErrStr : string;
  TestFileFlags : TN_TestFileFlags;
begin
  TestFileFlags := [];
  if ALoadFromProtectedDFile then
    TestFileFlags := [K_tffProtectedDFile];
  Result := N_SerialBuf.TestFile( AFileName, TestFileFlags );
  case Result of
  0 : LoadTreeFromFile( AFileName, ASLSLoadFlags );
  1 : LoadTreeFromTextFile( AFileName, ASLSLoadFlags );
  else
    Result := -1 - Result;
    ErrStr := K_DFGetErrorString(TK_DFErrorCode(Result));
    if ErrStr = '' then ErrStr := 'Unknown error';
    raise TK_LoadUDFileError.Create( 'Root node ' + ObjName + ' >> File ' + AFileName + ' : ' + ErrStr );
  end;
end; // end_of function TN_UDBase.LoadTreeFromAnyFile

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\LoadTreeFromFile
//********************************************** TN_UDBase.LoadTreeFromFile ***
// Load object Subnet from file in binary format
//
//     Parameters
// AFileName     - file name
// ASLSLoadFlags - Separately Loaded Subnets load modes set (only 
//                 [K_lsfSkipAllSLSR, K_lsfJoinAllSLSR] are used)
//
procedure TN_UDBase.LoadTreeFromFile( const AFileName : string;
                                     ASLSLoadFlags : TK_UDTreeLSFlagSet = [];
                                     ALoadFromProtectedDFile : Boolean = false );
var
  SBuf: TN_SerialBuf;
  PrevSLSRList : TList;
  ErrorFileMes : string;
  TmpUDGControlFlags : TK_UDGControlFlagSet;
  ArcInfo : string;
  i : integer;
  Tag : Byte;
  FEL : TStringList;
  FEC : Integer;
begin

  SBuf := N_SerialBuf;
  if not SBuf.LoadFromFile( AFileName, ALoadFromProtectedDFile ) then
  begin
    ErrorFileMes := K_DFGetErrorString( SBuf.SBDFile.DFErrorCode );
    if ErrorFileMes = '' then ErrorFileMes := 'bad data signature';
    raise TK_LoadUDFileError.Create( 'Root node ' + ObjName + ' >> Error while loading '+AFileName+' : ' + ErrorFileMes );
  end;

  FEL := nil;
  FEC := SBuf.CheckUsedTypesInfo( TStrings(FEL) );
  if (FEC = 1) or (FEC = -1) then
  begin
  //*** Show Format Version Errors
    if not (K_gcfSkipErrMessages in K_UDGControlFlags) then
    begin
      K_ShowFmtVerErrorMessageDlg( FEC,  AFileName,  FEL );
      FEL.Free;
    end;
    raise TK_LoadUDFileError.Create( 'Root node ' + ObjName + ' >> Error while loading '+AFileName+' : data format version errors' );
  end;

  SBuf.GetRowInt( K_TreeLoadVersion );
  if K_TreeLoadVersion >= 3 then
  begin
    SBuf.GetRowString( ArcInfo );
    if ArcInfo <> '' then
    begin // Init File Environment
      ObjInfo := K_InitArchInfo(ExtractFilePath(AFileName), ExtractFileName(AFileName), ArcInfo );
      if FEC = 2 then // check if Used Types Info is absent
        K_CheckAppArchVer( AFileName, true );
    end;
  end;

  K_UDCursorGet(K_udpLocalPathCursorName).SetRoot( self );
  K_UDRefTable := nil;

  TmpUDGControlFlags := K_AddSaveLoadFlagsToGlobalFlags( ASLSLoadFlags );
  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );
  K_SetUDGControlFlags( 1, K_gcfSysDateUse );
  K_SysDateTime := Now();

  PrevSLSRList := K_CurSLSRList;
  K_CurSLSRList := TList.Create;

  SBuf.GetTag( Tag );
  if tag <> K_fTagSubTree then Exit;
  //*** load Integer for previous file format compatibility
  SBuf.GetRowInt( i );
  ClearChilds();
  try
//    GetSubTreeFromSBuf( Sbuf );
    GetChildTreeFromSBuf( SBuf );
  except
    On E: Exception do
    begin
//!!!      K_ShowMessage(E.Message);
      raise Exception.Create( 'Root node ' + ObjName + ' >> Error while loading '+AFileName+' : ' + E.Message );
    end;
  end;
  K_SetUDGControlFlags( -1, K_gcfSysDateUse );
  K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );

  if (PrevSLSRList = nil) and  // Main Archive Finish Loading
     Assigned( K_LTFFVTreeRebuildRoutine ) then
    K_LTFFVTreeRebuildRoutine;

  with N_PBCaller do
//    Update(PBCMaxPBValue );
    if Assigned(PBCProcOfObj) then
      PBCProcOfObj( '100%', 100 );

  SLSRListLoad( PrevSLSRList );

  K_UDGControlFlags := TmpUDGControlFlags;
  SBuf.Init0();
end; // end_of procedure TN_UDBase.LoadTreeFromFile

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SaveTreeToFile
//************************************************ TN_UDBase.SaveTreeToFile ***
// Save object Subnet to file in binary format
//
//     Parameters
// AFileName        - file name
// AArchVersionInfo - information about format version
// ASLSSaveFlags    - Separately Loaded Subnets save modes set
//
procedure TN_UDBase.SaveTreeToFile( const AFileName : string; const
                                    AArchVersionInfo : string = '';
                                    ASLSSaveFlags : TK_UDTreeLSFlagSet = [] );
var
  SBuf: TN_SerialBuf;
  SavedRefPath : string;
  DFCreateParams: TK_DFCreateParams;
  TmpUDGControlFlags : TK_UDGControlFlagSet;
begin

  SavedRefPath := RefPath;
  RefPath := K_udpLocalPathCursorName;
  TmpUDGControlFlags := K_AddSaveLoadFlagsToGlobalFlags( ASLSSaveFlags );

  SaveSubTreeSLSRToFile;

  SBuf := N_SerialBuf;
  SBuf.SBMemSrcFileName := AFileName;
  SBuf.Init0( TRUE );
  SBuf.AddRowInt( K_TreeCurVersion );
  SBuf.AddRowString( AArchVersionInfo );


  K_UDRefIndex1 := 0;

  K_SysDateTime := Now();

  K_SetUDGControlFlags( 1, K_gcfSysDateUse );
  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );

//  AddSubTreeToSbuf(  SBuf );
//*** start subtree signature tag
  SBuf.AddTag( K_fTagSubTree );

//*** save Integer for previous file format compatibility
  SBuf.AddRowInt( 0 );
  Marker := 2; // Save Root node Child References as Own Childs flag
  if K_gcfSaveSLSRMode in K_UDGControlFlags then
    Marker := 3; // Save Root node Child References as References flag
  try
    AddChildTreeToSBuf( SBuf );
  except
  end;
  Marker := 0;


  K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );
  K_SetUDGControlFlags( -1, K_gcfSysDateUse );
  K_UDGControlFlags := TmpUDGControlFlags;

  K_ClearSubTreeRefInfo( Self, [K_criClearMarker,K_criClearChangedInfoFlag] );
  RefPath := SavedRefPath;
  SBuf.AddTag( K_fTagFinTree ); //*** set finish tree info flag

//  DFCreateParams := K_DFCreateProtected;
  DFCreateParams := K_DFCreateEncryptedSrc;
//  DFCreateParams := K_DFCreatePlain;

  SBuf.AddDataFormatInfo();
  K_ClearUsedTypesMarks( SBuf.SBUsedTypesList );

  SBuf.SaveToFile( AFileName, DFCreateParams );

  SBuf.Init0();

end; // end_of procedure TN_UDBase.SaveTreeToFile

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\LoadTreeFromTextFile
//****************************************** TN_UDBase.LoadTreeFromTextFile ***
// Load object Subnet from file in text format
//
//     Parameters
// AFileName     - file name
// ASLSLoadFlags - Separately Loaded Subnets load modes set (only 
//                 [K_lsfSkipAllSLSR, K_lsfJoinAllSLSR] are used)
//
procedure TN_UDBase.LoadTreeFromTextFile( const AFileName : string;
                                          ASLSLoadFlags : TK_UDTreeLSFlagSet = [] );
var
  SBuf: TK_SerialTextBuf;
  STag : string;
  ETag : TK_STBufTagType;
  PrevSLSRList : TList;
  TmpUDGControlFlags : TK_UDGControlFlagSet;
  ArchInfo : string;
  FEL : TStringList;
  FEC : Integer;
begin

//  if not FileExists( FName ) then
  if not K_VFileExists( AFileName )then
    raise TK_LoadUDFileError.Create( 'File '+AFileName+' not found' );

  SBuf := K_SerialTextBuf;
  SBuf.LoadFromFile( AFileName );

  FEL := nil;
  FEC := SBuf.CheckUsedTypesInfo( TStrings(FEL) );
  if (FEC = 1) or (FEC = -1) then begin
  //*** Show Format Version Errors
    K_ShowFmtVerErrorMessageDlg( FEC,  AFileName,  FEL );
    FEL.Free;
    raise TK_LoadUDFileError.Create( 'Error while loading '+AFileName+' : data format version errors' );
  end;

  TmpUDGControlFlags := K_AddSaveLoadFlagsToGlobalFlags( ASLSLoadFlags );
  SBuf.GetTag( STag, Etag );
  ArchInfo := '';
  SBuf.GetTagAttr( K_tbAIAttr, ArchInfo );
  if ArchInfo = '' then
    SBuf.GetTagAttr( K_tbFEnvID, ArchInfo );
  if ArchInfo <> '' then begin
    ObjInfo := K_InitArchInfo(ExtractFilePath(AFileName), ExtractFileName(AFileName), ArchInfo );
    if FEC = 2 then // check if Used Types Info is absent
      K_CheckAppArchVer( AFileName, false );
  end;


  K_UDCursorGet(K_udpLocalPathCursorName).SetRoot( self );
  K_UDRefTable := nil;

  K_SetUDGControlFlags( 1, K_gcfSysDateUse );
  K_SysDateTime := Now();
  ClearChilds();

  PrevSLSRList := K_CurSLSRList;
  K_CurSLSRList := TList.Create;

  try
    GetChildSubTreeFromText( SBuf, STag, false );
  except
    On E: Exception do begin
      if not (K_gcfSkipErrMessages in K_UDGControlFlags) then
        K_ShowMessage(E.Message);
    end
  end;

  K_SetUDGControlFlags( -1, K_gcfSysDateUse );

  if (PrevSLSRList = nil) and  // Main Archive Finish Loading
     Assigned( K_LTFFVTreeRebuildRoutine ) then
    K_LTFFVTreeRebuildRoutine;

  with N_PBCaller do
//    Update(PBCMaxPBValue );
    if Assigned(PBCProcOfObj) then
      PBCProcOfObj( '100%', 100 );

  SLSRListLoad( PrevSLSRList );

  K_UDGControlFlags := TmpUDGControlFlags;
  SBuf.SetCapacity( -1000 );
  N_PBCaller.Finish();

end; // end_of procedure TN_UDBase.LoadTreeFromTextFile

//************************************** TN_UDBase.SLSRAddUses ***
// Add Archive Section Uses info to given List
//
//     Parameters
// ASLSRUsesList - given List for accumulation SLSR from Uses
//
// If ASLSRUsesList = NIL then it is created in this method.
//
procedure TN_UDBase.SLSRAddUses( var SLSRUsesList : TList );
var
  i : Integer;
  SLSURoot : TN_UDBase;
  PSLSRAttrs : TK_PSLSRoot;
  function CheckInLoadErrList( UDCheck : TN_UDBase ) : Boolean;
  begin
    Result := (K_SLSLoadErrorsList <> nil) and
              (K_SLSLoadErrorsList.IndexOfObject(UDCheck) >= 0);
  end;
begin
  PSLSRAttrs := K_GetSLSRootPAttrs(Self);
  if (PSLSRAttrs = nil)                  or // Is not SLSRoot with Uses
     CheckInLoadErrList(Self) then Exit;    // Errors while section was Loaded
  with PSLSRAttrs.UDUses do
    for i := 0 to AHigh do begin
      SLSURoot := TN_PUDBase( P(i) )^;
      if CheckInLoadErrList(SLSURoot)                  or // Was already Loaded with Errors
         ((SLSURoot.ObjFlags and K_fpObjSLSRFlag) = 0) or // Is not SLSRoot
         (SLSURoot.DirLength <> 0) then Continue;         // Is not Empty

      if SLSRUsesList = nil then
        SLSRUsesList := TList.Create;

      SLSRUsesList.Add(SLSURoot); // Add to Uses and not Loaded List
    end;

end; // end_of procedure TN_UDBase.SLSRAddUses

//************************************** TN_UDBase.SLSRUsesListLoad ***
// Load Archive Sections from given List
//
//     Parameters
// ASLSRUsesList - Separately Loaded Subtree Roots List
// Result - Returns TRUE if given LIst is not empty
//
function TN_UDBase.SLSRUsesListLoad( SLSRUsesList : TList ) : Boolean;
var
  SavedSLSRList : TList;
begin
  Result := (SLSRUsesList <> nil) and (SLSRUsesList.Count > 0);
  if Result then begin
  // Load Unloaded Uses Sections
    SavedSLSRList := K_CurSLSRList;
    K_CurSLSRList := SLSRUsesList;
    SLSRListLoad( SavedSLSRList );
  end else
    SLSRUsesList.Free;
end; // end_of TN_UDBase.SLSRUsesListLoad

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SaveTreeToTextFile
//******************************************** TN_UDBase.SaveTreeToTextFile ***
// Save object Subnet to file in text format
//
//     Parameters
// AFileName        - file name
// ATextModeFlags   - set of modes to control text format variants
// AArchVersionInfo - information about format version
// ASLSSaveFlags    - Separately Loaded Subnets save modes set
//
procedure TN_UDBase.SaveTreeToTextFile( const AFileName: string;
                                        ATextModeFlags : TK_TextModeFlags;
                                        const AArchVersionInfo : string = '';
                                        ASLSSaveFlags : TK_UDTreeLSFlagSet = [] );
var
  STBuf: TK_SerialTextBuf;
  TempTextModeFlags : TK_TextModeFlags;
  SavedRefPath : string;
//  RootTag : string;
  TmpUDGControlFlags : TK_UDGControlFlagSet;
begin

  SavedRefPath := RefPath;
  RefPath := K_udpLocalPathCursorName;
  TmpUDGControlFlags := K_AddSaveLoadFlagsToGlobalFlags( ASLSSaveFlags );

  SaveSubTreeSLSRToFile;

  STBuf := K_SerialTextBuf;
  STBuf.InitSave();


  K_UDRefIndex1 := 0;

  TempTextModeFlags := K_TextModeFlags;
  K_TextModeFlags := ATextModeFlags;
  K_SysDateTime := Now();
  K_SetUDGControlFlags( 1, K_gcfSysDateUse );
  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );

  Marker := 2;
//  RootTag := K_tbRootTag;
//  if FileSavedContext <> '' then
//    RootTag := K_tbRootTag + ' '+ K_tbFEAttr + '=' + FileSavedContext;
  try
    STBuf.AddTag( K_tbRootTag );
    if AArchVersionInfo <> '' then
      STBuf.AddTagAttr( K_tbAIAttr, AArchVersionInfo );
    AddChildsToText( STBuf, '' );
    STBuf.AddTag( K_tbRootTag, tgClose );
//    AddChildsToText( SBuf, RootTag );
  except
  end;
  Marker := 0;

  K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );
  K_SetUDGControlFlags( -1, K_gcfSysDateUse );
  K_UDGControlFlags := TmpUDGControlFlags;

  K_TextModeFlags := TempTextModeFlags;

  K_ClearSubTreeRefInfo( Self, [K_criClearMarker,K_criClearChangedInfoFlag] );

  RefPath := SavedRefPath;

  STBuf.AddDataFormatInfo();
  K_ClearUsedTypesMarks( STBuf.SBUsedTypesList );

  STBuf.SaveToFile( AFileName );
end; // end_of procedure TN_UDBase.SaveTreeToTextFile

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\PrepSerializedChildsScale
//************************************* TN_UDBase.PrepSerializedChildsScale ***
// Prepare scale of serialized child objects
//
//     Parameters
// Result - Returns number of serialized child objects
//
// Do not call PrepSerializedChildsScale directly, it is used automatically in 
// TN_UDBase.AddChildTreeToSBuf and TN_UDBase.AddChildsToText.
//
function TN_UDBase.PrepSerializedChildsScale( SInd, HInd : Integer;
                                var AddChildsScale : TN_BArray ) : Integer;
var
  i, DEFlags : integer;
  Child : TN_UDBase;
begin
//*** Build Saved Childs Scale
  Result := HInd - SInd + 1;
  SetLength( AddChildsScale, Result );
  for i := HInd downto SInd do  begin
    GetDEField( i, Child, K_DEFisChild );
    if (Child = nil) or
       ((Child.ClassFlags and K_SkipSelfSaveBit) <> 0) then begin
      GetDEField( i, DEFlags, K_DEFisFlags );
      if (DEFlags and K_fpDEProtected) = 0 then begin
        AddChildsScale[i] := 1;
        Dec(Result);
      end;
    end;
    if AddChildsScale[i] = 0 then Break;
  end;
end; // end_of procedure TN_UDBase.PrepSerializedChildsScale

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\RemoveChildVNodes
//********************************************* TN_UDBase.RemoveChildVNodes ***
// Remove Visual Nodes of child object given by directiry entry data
//
//     Parameters
// ADE - IDB object directory entry data
//
procedure TN_UDBase.RemoveChildVNodes( const ADE : TN_DirEntryPar );
var
  WVNode, NVNode : TN_VNode;
label StartDeletion;
begin
  if ADE.Child = nil then Exit;

StartDeletion:
  NVNode := ADE.Child.LastVNode;
  while NVNode <> nil do begin
    WVNode := NVNode;
    NVNode := WVNode.PrevVNUDObjVNode;
    if (WVNode.VNParent <> nil) and
       (self = WVNode.GetParentUObj) and
       (WVNode.VNCode = ADE.VCode) then begin
      WVNode.Delete;
      goto StartDeletion;
    end;
  end;
end; // end of procedure TN_UDBase.RemoveChildVNodes

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SLSRListLoad
//************************************************** TN_UDBase.SLSRListLoad ***
// Load IDB Sections file using Separately Loaded Subnet Roots List
//
//     Parameters
// APrevSLSRList - previous level list of IDB objects which are roots of 
//                 separately loaded IDB Subnets
//
// Do not call SLSRListLoad directly, it is used automatically in 
// TN_UDBase.LoadTreeFromFile and TN_UDBase.LoadTreeFromTextFile.
//
procedure TN_UDBase.SLSRListLoad( APrevSLSRList : TList );
var
  i : Integer;
  StartLoadLevel : Boolean;
  ErrNodePath : string;
  NRefNode : TN_UDBase;
  PRefNode : TN_PUDBase;
  FURCounter : Integer;
  BuildFlags : TK_BuildDirectRefsFlags;
  SLSRUsesList : TList;
  SLSRoot : TN_UDBase;
begin
  StartLoadLevel := APrevSLSRList = nil;
  if StartLoadLevel then
    K_SLSLoadErrorsList := TStringList.Create;

//*** Build Unconditional Direct References
//??N_T1.Start;

  Include( K_UDGControlFlags, K_gcfUseOnlyRefInd );
  BuildFlags := [K_bdrClearRefInfo];
  if StartLoadLevel then
    BuildFlags := [K_bdrClearRefInfo, K_bdrClearURefCount];
  FURCounter := K_BuildDirectReferences( Self, BuildFlags );
  Exclude( K_UDGControlFlags, K_gcfUseOnlyRefInd );

//??N_T1.SS( 'DirectRefs ' );

  if not StartLoadLevel then FURCounter := 0; // Clear Local UnResolved Refs Counter for Not Root Level

  K_UDRefTable := nil;

//*** Load Separately Loaded Subnets
  for i := 0 to K_CurSLSRList.Count - 1 do
  begin
    SLSRoot := TN_UDBase(K_CurSLSRList[i]);
    try
      with SLSRoot do
        if DirLength = 0 then // Skip Loaded Sections
          LoadSLSFromAnyFile;
    except
      on E: Exception do
      begin
//        ErrNodePath := GetRefPathToObj( SLSRoot, true )  + ' --> ' + E.Message;
        ErrNodePath := K_GetPathToUObj( Self, SLSRoot, K_ontObjName, [K_ptfTryAltRelPath] ) + ' --> ' + E.Message;
        K_InfoWatch.AddInfoLine( ErrNodePath );
        K_SLSLoadErrorsList.AddObject( ErrNodePath, SLSRoot );
        if not (E is TK_LoadUDFileError) then
          raise E.Create( ErrNodePath );
      end; // on E: Exception do
    end; // except
  end; // for i := 0 to K_CurSLSRList.Count - 1 do

//*** Check for Uses Sections in Current loaded SLSRoots and Load Unloaded Sections
  SLSRUsesList := nil;
  // Create List Of Unloaded Uses Sections
  for i := 0 to K_CurSLSRList.Count - 1 do
    TN_UDBase(K_CurSLSRList[i]).SLSRAddUses( SLSRUsesList );
  // Load List Of Unloaded Uses Sections
  SLSRUsesListLoad( SLSRUsesList );

  if StartLoadLevel then
  begin
    if (K_SLSLoadErrorsList.Count > 0) then
    begin
  //*** Show Unresolved References
      if MessageDlg('Errors while loading Separately Loaded Subnets are detected. Show detailes?',
         mtWarning, mbOKCancel, 0 ) = mrOk then
        K_GetFormTextEdit.EditStrings( K_SLSLoadErrorsList, 'Loading Errors' );
    end;
    FreeAndNil(K_SLSLoadErrorsList);
  end;

  with K_UDTreeBuildRefControl do begin
    if K_CurSLSRList.Count > 0 then begin
  //*** Build Direct References after Loading Separate SubTrees
      K_UDCursorGet(K_udpLocalPathCursorName).SetRoot( self );
  //    K_BuildDirectReferences( Self, StartLoadLevel and not (K_gcfSkipUnResoledRefInfo in K_UDGControlFlags) );
  //*** Resolve UDRefs Using Pointers to Unresolved Refs Fields
      FURCounter := 0;
      for i := 0 to URefCount - 1 do begin
        PRefNode := URefPFields[i];
        if K_ReplaceNodeRef( PRefNode^, NRefNode ) then begin
          if NRefNode <> PRefNode^ then begin // Reference was replaced
            PRefNode^ := nil; //*** clear UDRef field - because RefNode is already destroyed
            K_SetUDRefField( PRefNode^, NRefNode, true );
          end else
            Inc( FURCounter );
        end;
      end;
    end;


    if StartLoadLevel then begin
      URefCount := 0;
      K_UDRefTable := nil;
      if FURCounter > 0 then begin // Build UnResolved Refs Errors List
//          K_InfoWatch.AddInfoLine( IntToStr( URCounter ) + ' unresolved references are detected' );
        K_ShowUnresRefsInfo( Self, FURCounter );
      end;
    end;
  end;


  K_CurSLSRList.Free;
  K_CurSLSRList := APrevSLSRList;

end; // end_of procedure TN_UDBase.SLSRListLoad

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SLSRListBuildScan
//********************************************* TN_UDBase.SLSRListBuildScan ***
// Scanning IBD object routine for Separately Loaded Subnet Roots search
//
// Do not call SLSRListBuildScan directly, it is used automatically in 
// K_BuildSLSRList.
//
function TN_UDBase.SLSRListBuildScan( UDParent: TN_UDBase;
                 var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                 const FieldName: string ) : TK_ScanTreeResult;
begin
  Result := K_tucOK;
  with UDChild do
    if (ObjFlags and K_fpObjSLSRFlag) <> 0 then K_CurSLSRList.Add( UDChild );
end; // end_of TN_UDBase.SLSRListBuildScan

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddLoadingToSLSRList
//****************************************** TN_UDBase.AddLoadingToSLSRList ***
// Add deserialized IDB object to separately loaded IDB Subnets list if needed
//
//     Parameters
// Result - Returns TRUE if IDB object is separately loaded IDB Subnet which is 
//          not joined to previous level IDB Subnet
//
// Do not call AddLoadingToSLSRList directly, it is used automatically in 
// TN_UDBase.GetChildTreeFromSBuf and TN_UDBase.GetSubTreeFromText.
//
function TN_UDBase.AddLoadingToSLSRList : Boolean;
begin
  Result := true;
  if ((ObjFlags and K_fpObjSLSRFlag) =  0) or
     ((ObjFlags and K_fpObjSLSRJoin) <> 0) or
     (K_gcfJoinAllSLSR in K_UDGControlFlags) then begin
    if (ObjFlags and K_fpObjSLSRFlag) <>  0 then
       K_InfoWatch.AddInfoLine( 'Load "' + GetUName + '" joined' );
    Result := false
  end else if (((ObjFlags and K_fpObjSLSRMLoad) = 0) or (K_gcfLoadAllSLSR in K_UDGControlFlags) ) and
          not (K_gcfSkipAllSLSR in K_UDGControlFlags) then
    K_CurSLSRList.Add( Self );
end; // end_of procedure TN_UDBase.AddLoadingToSLSRList

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SLSRSetJoinArchFlag
//******************************************* TN_UDBase.SLSRSetJoinArchFlag ***
// Set join to Archive flag to separately loaded Subnets root objects
//
// Do not call AddLoadingToSLSRList directly, it is used automatically in 
// TN_UDBase.SLSRListPrepareToSave.
//
procedure TN_UDBase.SLSRSetJoinArchFlag;
begin
  if (Self = nil) or
     ( K_IsUDRArray(Self) and
       (TK_UDRArray(Self).R.ElemSType = K_ArchiveDTCode.DTCode) ) then Exit;
  if (ObjFlags and K_fpObjSLSRFlag) <> 0 then begin
    //*** Node is SLSRoot - Check State
    if (ObjFlags and K_fpObjSLSRJoin) <> 0 then Exit; // Upper SLSRoots are already Joined
    ObjFlags := ObjFlags or K_fpObjSLSRJoin;
  end;
  Owner.SLSRSetJoinArchFlag;

end; //*** end of TN_UDBase.SLSRSetJoinArchFlag

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SLSRListPrepareToSave
//***************************************** TN_UDBase.SLSRListPrepareToSave ***
// Prepare Separately Loaded Subnets root objects list for saving to file
//
//     Parameters
// ASLSRoots - list of IDB objects which are roots of separately loaded IDB 
//             Subnets
//
// Do not call SLSRListPrepareToSave directly, it is used automatically in 
// TN_UDBase.SaveSubTreeSLSRToFile.
//
procedure TN_UDBase.SLSRListPrepareToSave( ASLSRoots : TList = nil );
var
  i : Integer;
  AddSLSRtoList : Boolean;
  ReadOnlyDialog : Boolean;
  UDChild: TN_UDBase;

  function InternalSLSRSaveDialogFunc : Integer;
  var
    res : word;
    ErrStr : string;
  begin
//    ErrStr := 'section ' + UDChild.GetOwnersPath( K_CurArchive ) +
    ErrStr := 'section ' + K_GetPathToUObj( UDChild,  K_CurArchive ) +
              ' to file ' + K_ExpandFileName( UDChild.ObjInfo ) + '?';
    if ReadOnlyDialog then
      ErrStr := 'Save read-only ' + ErrStr
    else
      ErrStr := 'Save empty ' + ErrStr;
    res := MessageDlg( ErrStr, mtConfirmation, [mbYes, mbNo, mbCancel, mbYesToAll, mbNoToAll], 0);
    Result := -1;
    case res of
      mrNoToAll  : Result := -2;
      mrNo       : Result := -1;
      mrYes      : Result := 0;
      mrYesToAll : Result := 1;
    end;
  end;

  procedure AskSaveSLSR( UDGCSkipFlag, UDGCSaveFlag : TK_UDGControlFlags );
  var
    R : Integer;
  begin
    if not (UDGCSaveFlag in K_UDGControlFlags) then begin
      AddSLSRtoList := false;
      ReadOnlyDialog := UDGCSkipFlag = K_gcfSkipReadOnlySLSR;
      if not (UDGCSkipFlag in K_UDGControlFlags) then begin
        if Assigned( K_SLSRSaveDialogFunc ) then
          R := K_SLSRSaveDialogFunc(UDChild)
        else
          R := InternalSLSRSaveDialogFunc;

        case R of
        -2: begin
            Include( K_UDGControlFlags, UDGCSkipFlag );
            AddSLSRtoList := false;
          end;
        -1: AddSLSRtoList := false;
         0: AddSLSRtoList := true;
         1: begin
            Include( K_UDGControlFlags, UDGCSaveFlag );
            AddSLSRtoList := true;
          end;
        end;
      end;
    end;
  end;

begin
  if ASLSRoots = nil then
    ASLSRoots := K_CurSLSRList;
  for i := ASLSRoots.Count - 1 downto 0 do
  begin
    UDChild := TN_UDBase( ASLSRoots[i] );
    with UDChild do
    begin
      AddSLSRtoList := true;
      if K_gcfDisjoinSLSR in K_UDGControlFlags then
      begin
        //*** Disjoin SLSRoot from Archive
        if (ObjFlags and K_fpObjSLSRJoin) <> 0 then
        begin
          ObjFlags := ObjFlags and not K_fpObjSLSRJoin;
          ClassFlags := ClassFlags or K_ChangedSLSRBit; // Set K_ChangedSLSRBit
        end;
      end
      else
      if not (K_gcfSkipJoinChangedSLSR in K_UDGControlFlags) then
      begin
        if (ClassFlags and K_ChangedSLSRBit) <> 0 then
        begin
          UDChild.SLSRSetJoinArchFlag; // Join Chaged Sections To Arch
          AddSLSRtoList := false;
        end;
      end;
      AddSLSRtoList := AddSLSRtoList and
                       ( ((ClassFlags and K_ChangedSLSRBit) <> 0) or
                         (K_gcfSaveNotChangedSLSR in K_UDGControlFlags));
      if AddSLSRtoList then begin
        if (ObjFlags and K_fpObjSLSRRead) <> 0 then // ReadOnly SLSRoot
          AskSaveSLSR( K_gcfSkipReadOnlySLSR, K_gcfSaveReadOnlySLSR )
        else if (DirLength = 0) then                // Empty SLSRoot
          AskSaveSLSR( K_gcfSkipEmptySLSR, K_gcfSaveEmptySLSR );
      end;
      if not AddSLSRtoList then  ASLSRoots.Delete(i);
    end; // with UDChild do
  end; // for i := ASLSRoots.Count - 1 downto 0 do
end; // end_of TN_UDBase.SLSRListPrepareToSave

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\ClearChangeSubTreeScan
//**************************************** TN_UDBase.ClearChangeSubTreeScan ***
// Scanning IBD object routine for ñlearing objects ChangedFlags
//
// Do not call ClearChangeSubTreeScan directly, it is used automatically in 
// K_ClearChangeSubTreeFlags.
//
function TN_UDBase.ClearChangeSubTreeScan( UDParent: TN_UDBase;
                 var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                 const FieldName: string ) : TK_ScanTreeResult;
begin
  with UDChild do begin
    if (ClassFlags and (K_ChangedSLSRBit or K_ChangedSubTreeBit)) <> 0 then begin
      ClassFlags := ClassFlags and not (K_ChangedSLSRBit or K_ChangedSubTreeBit);
      Result := K_tucOK;
    end else
      Result := K_tucSkipSubTree;
  end;
end; // end_of TN_UDBase.ClearChangeSubTreeScan

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SetChangeSubTreeScan
//****************************************** TN_UDBase.SetChangeSubTreeScan ***
// Scanning IBD object routine for seting objects ChangedFlags
//
// Do not call SetChangeSubTreeScan directly, it is used automatically in 
// K_SetChangeSubTreeFlags.
//
function TN_UDBase.SetChangeSubTreeScan( UDParent: TN_UDBase;
                 var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                 const FieldName: string ) : TK_ScanTreeResult;
begin
  Result := K_tucOK;
  UDChild.SetChangedSubTreeFlag;
end; // end_of TN_UDBase.SetChangeSubTreeScan

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SetAbsentOwnersScan
//******************************************* TN_UDBase.SetAbsentOwnersScan ***
// Scanning IBD object routine for seting objects absent owners
//
// Do not call SetAbsentOwnersScan directly, it is used automatically in 
// K_SetAbsentOwners.
//
function TN_UDBase.SetAbsentOwnersScan( UDParent: TN_UDBase;
                 var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
                 const FieldName: string ) : TK_ScanTreeResult;
begin
  Result := K_tucOK;
  if UDChild.Owner = nil then
    UDChild.Owner := UDParent;
end; // end_of TN_UDBase.SetAbsentOwnersScan

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SaveSubTreeSLSRToFile
//***************************************** TN_UDBase.SaveSubTreeSLSRToFile ***
// Save given IDB Subnet descendant Separately Loaded Subnets to files
//
procedure TN_UDBase.SaveSubTreeSLSRToFile;
var
  i : Integer;
  SavedRefPath : string;
  TmpUDGControlFlags : TK_UDGControlFlagSet;
//  FileName : string;
  SLSRoot : TN_UDBase;
begin

  if (K_gcfSkipAllSLSR in K_UDGControlFlags) or
     (K_gcfJoinAllSLSR in K_UDGControlFlags) or
     (K_gcfSetJoinToAllSLSR in K_UDGControlFlags) then Exit;
  Include(K_UDGControlFlags, K_gcfSkipAllSLSR);

  //*** Build SLSR List
  K_BuildSLSRList( Self, nil );
  TmpUDGControlFlags := K_UDGControlFlags;
  SLSRListPrepareToSave();
  K_UDGControlFlags := TmpUDGControlFlags;

  SavedRefPath := RefPath;

//*** Save SLSRs
  K_SetUDGControlFlags( 1, K_gcfSaveSLSRMode );
  for i := 0 to K_CurSLSRList.Count - 1 do begin
    SLSRoot := TN_UDBase(K_CurSLSRList[i]);
    with SLSRoot do
      if (ObjFlags and K_fpObjSLSRJoin) = 0 then
        SLSRoot.SaveTreeToAnyFile( Self, K_ExpandFileName(ObjInfo), '', [], (K_fpObjSLSRFText and ObjFlags) <> 0 );
    RefPath := SavedRefPath;
  end;
  K_SetUDGControlFlags( -1, K_gcfSaveSLSRMode );

  FreeAndNil( K_CurSLSRList );

  Exclude(K_UDGControlFlags, K_gcfSkipAllSLSR);

end; // end_of TN_UDBase.SaveSubTreeSLSRToFile

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SetDate
//******************************************************* TN_UDBase.SetDate ***
// Set current date and time to ObjDateTime field
//
procedure TN_UDBase.SetDate (  );
begin
  ObjDateTime := Now();
end; // end of procedure TN_UDBase.SetDate

//************************************** TN_UDBase.GetDirUFlags ***
// get directory update flags
//
function TN_UDBase.GetDirUFlags ( DirFlags : TK_UDFLags;
                                  FlagsNumber : Integer = 0 ) : TK_UDFLags;
begin
  Result := ObjUFlags[FlagsNumber].DirFlags;
  if (Result and K_fuUseOR) <> 0 then
    Result := Result or DirFlags //*** OR update flags
  else if ((DirFlags and (K_fuUseGlobal or K_fuUseCurrent)) <> 0) or
     ((Result and K_fuUseCurrent) = 0) then
    Result := DirFlags; //*** param update flags
  Result := Result and K_fuUseMask; //*** param update flags
end; // end of function TN_UDBase.GetDirUFlags


//************************************** TN_UDBase.GetEntryUFlags ***
// get dir entry update flags
//
function TN_UDBase.GetEntryUFlags ( EntryFlags : TK_UEFLags;
                                    FlagsNumber : Integer = 0 ) : TK_UEFLags;
var locEntryFlags : TK_UEFlags;
begin
  Result := EntryFlags;
//*** check if use directory update flags
  locEntryFlags := ObjUFlags[FlagsNumber].EntryFlags;
  if ( (EntryFlags and (K_fuUseGlobal or K_fuUseCurrent)) = 0 ) and
     ( (locEntryFlags and K_fuUseCurrent) <> 0 ) then
    Result := locEntryFlags
  else if (locEntryFlags and K_fuUseOR) <> 0  then
    Result := Result or locEntryFlags;
  Result := Result and K_fuUseMask; //*** param update flags
end; // end of function TN_UDBase.GetEntryUFlags


//************************************** TN_UDBase.GetDEUFlags ***
// get dir entry update flags
//
function TN_UDBase.GetDEUFlags ( const DE : TN_DirEntryPar; EntryFlags : TK_UEFlags;
                                 FlagsNumber : Integer = 0 ) : TK_UEFlags;
var locEntryFlags : TK_UEFlags;
begin
  Result := EntryFlags;
//*** check if use dir entry update flags
//  locEntryFlags := DE.DEUFlags[FlagsNumber];
  locEntryFlags := DE.DEUFlags[0];
  if ( (Result and (K_fuUseGlobal or K_fuUseCurrent)) = 0 ) and
     ( (locEntryFlags and K_fuUseCurrent) <> 0 ) then
    Result := locEntryFlags
  else if (locEntryFlags and K_fuUseOR) <> 0  then
    Result := Result or locEntryFlags;
  Result := Result and K_fuUseMask; //*** param update flags
end; // end of function TN_UDBase.GetDEUFlags

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\Clone
//********************************************************* TN_UDBase.Clone ***
// Clone IDB object
//
//     Parameters
// ACopyFields - copy source objet fields flag
// Result      - Returns self clone object
//
function TN_UDBase.Clone( ACopyFields : boolean = true ) : TN_UDBase;
begin
// Self can't be nil in virtual method
  Result := N_ClassRefArray[self.ClassFlags and $FF].Create;
  if ACopyFields then Result.CopyFields( Self );
end; // end of function TN_UDBase.Clone

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\ChangeVNodesState
//********************************************* TN_UDBase.ChangeVNodesState ***
// Change IDB Object Visual Nodes state
//
//     Parameters
// AVNodeFalgs - new object Visual Nodes state flags set (MARKED, SELECTED, 
//               CURRENT)
// AVTree      - Visual Tree object (if VTree is not given then state of VNodes 
//               in all VTrees will be changed)
//
procedure TN_UDBase.ChangeVNodesState( AVNodeFalgs : TK_SetObjStateFlags = [];
                                       AVTree : TN_VTree = nil );
var
  WVNode : TN_VNode;
  VNCount : Integer;

  procedure ChangeVNState();
  begin
    with WVNode do begin
      if K_ssfMarked in AVNodeFalgs then Mark()
      else UnMark();
      if K_ssfSelected in AVNodeFalgs then VNVTree.SetSelectedVNode( WVNode )
      else if K_ssfCurrent in AVNodeFalgs then VNVTree.SetCurrentVNode( WVNode )
    end;
  end;

begin

  if Self = nil then begin
    if AVTree = nil then Exit;
    if K_ssfSelected in AVNodeFalgs then AVTree.SetSelectedVNode( nil )
    else if K_ssfCurrent in AVNodeFalgs then AVTree.SetCurrentVNode( nil );
  end else begin
    VNCOunt := 0;
    WVNode := LastVNode;
    while WVNode <> nil do begin
      if (AVTree = nil) or (WVNode.VNVTree = AVTree) then
        ChangeVNState();
      WVNode := WVNode.PrevVNUDObjVNode;
    end;
    if (VNCOunt = 0)   and
       (AVTree <> nil) and
       (AVNodeFalgs <> []) then begin
      with AVTree do
//        GetVNodeByPath( WVNode, RootUObj.GetPathToObj(Self) );
        GetVNodeByPath( WVNode, K_GetPathToUObj( Self, RootUObj ) );
      if WVNode <> nil then ChangeVNState();
    end;
  end;
end; // end of procedure TN_UDBase.ChangeVNodesState

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddChildVNodes
//************************************************ TN_UDBase.AddChildVNodes ***
// Add Visual Nodes for child object given by directory entry index
//
//     Parameters
// AChildNum   - index of directory entry with child object
// AVNodeFalgs - new object Visual Nodes state flags set (MARKED, SELECTED, 
//               CURRENT)
// AVTree      - Visual Tree object (if VTree is not given then  VNodes to all 
//               VTrees will be added)
//
procedure TN_UDBase.AddChildVNodes( AChildNum : Integer; AVNodeFalgs : TK_VNodeStateFlags = [];
                                    AVTree : TN_VTree = nil );
var
  WVNode : TN_VNode;
  UDChild : TN_UDBase;
begin
  if (AChildNum < 0) or (AChildNum > DirHigh ) then Exit;
  UDChild := DirChild( AChildNum );
  WVNode := LastVNode;
  while WVNode <> nil do
  begin
    if (AVTree = nil) or (WVNode.VNVTree = AVTree) then begin
      WVNode.CreateChildVNodes( AChildNum );
      with UDChild, LastVNode do begin
//        if (VNodeFalgs and K_fVNodeStateMarked) <> 0 then Mark();
//        if (VNodeFalgs and K_fVNodeStateSelected) <> 0 then VTree.SetSelectedVNode( LastVNode );
        if K_fVNodeStateMarked in AVNodeFalgs then Mark();
        if K_fVNodeStateSelected in AVNodeFalgs then VNVTree.SetSelectedVNode( LastVNode )
        else if K_fVNodeStateCurrent in AVNodeFalgs then VNVTree.SetCurrentVNode( LastVNode )
      end;
    end;
    WVNode := WVNode.PrevVNUDObjVNode;
  end;
end; // end of procedure TN_UDBase.AddChildVNodes

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\RebuildVNodes
//************************************************* TN_UDBase.RebuildVNodes ***
// Rebuild self Visual Nodes
//
//     Parameters
// AMode  - rebuild mode (=0 - delete object Visual Nodes and create new, =1 - 
//          only rebuild caption in corresponding TreeNodes, <0 - clear VNode 
//          Special Marks)
// AVCode - VCode field value (if =0 then all VNodes rebuild, else rebuild 
//          VNodes with given VCode)
//
procedure TN_UDBase.RebuildVNodes( AMode : Integer = 0; AVCode : LongWord = 0 );
var
  WVNode, RVNode : TN_VNode;
  CID : Int64;
label StartRebuild;
begin
   if Self = nil then Exit;
   CID := N_CPUCounter;
StartRebuild:
   RVNode := LastVNode;
   while RVNode <> nil do
   begin
     WVNode := RVNode;
     RVNode := WVNode.PrevVNUDObjVNode;
     if (AVCode = 0) or (WVNode.VNCode = AVCode) then
       if AMode = 0 then
       begin
         //*** Use Time compare to prevent Node Subtree Rebuild for the second time
         if WVNode.CID >= CID then continue;
         WVNode.RebuildVNSubTree;
         goto StartRebuild; // tree rebuild can rebuild UDBase VNodes list
       end else if AMode > 0 then
         WVNode.UpdateTreeNodeCaption
       else
       begin
         WVNode.Toggle( -1, [K_fVNodeStateSpecMark0] );
         WVNode.Toggle( -1, [K_fVNodeStateSpecMark1] );
       end;
   end;
end; // end of procedure TN_UDBase.RebuildVNodes

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\RebuildVTreeCheckedState
//************************************** TN_UDBase.RebuildVTreeCheckedState ***
// Rebuild Visual Tree Checkek context by self Visual Nodes
//
procedure TN_UDBase.RebuildVTreeCheckedState( );
var
  WVNode, RVNode : TN_VNode;
begin
   if Self = nil then Exit;
   RVNode := LastVNode;
   while RVNode <> nil do
   begin
     WVNode := RVNode;
     if (ObjFlags and K_fpObjTVChecked) <> 0 then
       WVNode.VNVTree.CheckedUobjsList.Add( Self )
     else
       WVNode.VNVTree.CheckedUobjsList.Remove( Self );

     RVNode := WVNode.PrevVNUDObjVNode;
   end;
end; // end of procedure TN_UDBase.RebuildVTreeCheckedState

{
//************************************************ TN_UDBase.SearchObjByName ***
// get UData obj by given (unique) GlobalName,
//
function TN_UDBase.SearchObjByName( GlobalName: string ): TN_UDBase;
var
  i, h : integer;
  Child : TN_UDBase;
begin
  Result := nil; // as if not found
  if ObjName = GlobalName then
    Result := self
  else
  begin
    h := DirHigh;
    for i := 0 to h do
    begin
      Child := DirChild(i);
      if Child = nil then Continue;
      Result := Child.SearchObjByName( GlobalName );
      if Result <> nil then Exit; // found OK
    end;
  end; // end else
end; // end of function TN_UDBase.SearchObjByName
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetDEByPathSegment
//******************************************** TN_UDBase.GetDEByPathSegment ***
// Get directory entry data by given IDB path segment value
//
//     Parameters
// APath        - given IDB path segment
// ADE          - resulting directory entry data
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns TRUE if needed directory entry is found
//
function  TN_UDBase.GetDEByPathSegment( const APath : string; out ADE : TN_DirEntryPar;
              AObjNameType : TK_UDObjNameType = K_ontObjName ) : Boolean;
var
  Ind, h, SCode : Integer;
  Ext, NameSegment : string;
  CtrlChar : Char;
  UseName, UseNameExt : Boolean;
begin

  Result := false; // internal err flag
  CtrlChar := APath[1];
  NameSegment := APath;
  UseName := true;
  UseNameExt := false;
  SCode := -1;
  if AObjNameType = K_ontObjName then begin
    if (CtrlChar = K_udpDENameDelim) or
       (CtrlChar = K_udpDECodeDelim) or
       (CtrlChar = K_udpDEIndexDelim) or
       (CtrlChar = K_udpObjTypeNameDelim) then begin
      NameSegment := Copy( APath, 2, Length(NameSegment)- 1 );
      Ext := NameSegment;
      UseName := false;
    end else begin
      Ext := '';
      for Ind := Length(APath) downto 1 do
        if (APath[Ind] = K_udpDENameDelim) or
           (APath[Ind] = K_udpDECodeDelim) or
           (APath[Ind] = K_udpObjTypeNameDelim) then
        begin
          CtrlChar := APath[Ind];
          NameSegment := Copy(APath, 1, Ind - 1 );
          if Ind+1 <= Length(APath) then begin
            Ext := Copy(APath, Ind+1, Length(APath) );
            UseNameExt := true;
          end;
          break;
        end;
    end;

    if CtrlChar = K_udpDECodeDelim then
      SCode := StrToIntDef( Ext, -1 )
    else if CtrlChar = K_udpObjTypeNameDelim then begin
      SCode := K_GetUObjCIByTagName( Ext, false );
      if SCode = -1 then Exit;
    end;
  end;

  Ind := -1;
  h := DirHigh;
  if not UseName then
  begin
    case CtrlChar of
      K_udpDENameDelim      : Ind := IndexOfDEField( Ext, K_DEFisName );
      K_udpDECodeDelim      : Ind := IndexOfDECode( Scode );
      K_udpDEIndexDelim     : Ind := StrToIntDef( Ext, -1 );
      K_udpObjTypeNameDelim : Ind := IndexOfChildType( SCode );
    end;
    if (Ind >= 0) and (Ind <= h) then
      GetDirEntry( Ind, ADE )
    else
      Exit;
  end
  else
  begin
    repeat
      Inc(Ind);
      if Ind > h then Exit;
      Ind := IndexOfChildObjName( NameSegment, AObjNameType, Ind );
      if Ind < 0 then Exit;
      GetDirEntry( Ind, ADE );
    until
      not UseNameExt                                              or
      ((CtrlChar = K_udpDENameDelim)      and (Ext = ADE.DEName))   or
      ((CtrlChar = K_udpDECodeDelim)      and (SCode = ADE.DECode)) or
      ((CtrlChar = K_udpObjTypeNameDelim) and (SCode = Integer(ADE.Child.ClassFlags and $FF)));
  end;
  Result := true;
end; // end_of procedure TN_UDBase.GetDEByPathSegment

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetDEByRPath
//************************************************** TN_UDBase.GetDEByRPath ***
// Get directory entry data in IDB Subnet by given relative path
//
//     Parameters
// ARPath       - IDB relative path
// ADE          - resulting directory entry data
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
// APathDepth   - parsing path depth (number of parsing path segments)
// AContinue    - start level flag (set always FALSE)
// Result       - Returns path string position that was successfully parsed
//
// Resulting path string position less then 0 means that path tracking was break
// by error. Resulting positive value less then ARPath srting length means that 
// path was break by depth boundary (APathDepth).
//
function  TN_UDBase.GetDEByRPath( const ARPath : string; var ADE : TN_DirEntryPar;
                              AObjNameType : TK_UDObjNameType = K_ontObjName;
                              APathDepth : Integer = 0;
                              AContinue : Boolean = false ) : Integer;
var
  FDepth, NPos, WPos : Integer;
  CParent : TN_UDBase;
  CName : string;

label ErrPath, Cont;

begin
  if not AContinue then begin
    K_UDPathTokenizer.SetSource( ARPath );
    ADE.Child := self;
  end;
  if APathDepth < 0 then begin // calc Real Path Depth
    APathDepth := K_UDPathTokenizer.CalcTokens + APathDepth;
  end;

  if APathDepth = 0 then
    APathDepth := MaxInt;

  FDepth := 0;
  NPos := K_UDPathTokenizer.cpos;
  while K_UDPathTokenizer.hasMoreTokens do begin

    with K_UDPathTokenizer do begin
      if (FDepth >= APathDepth) or
         ( (cpos > 1) and
           (Text[cpos-1] = K_udpFieldDelim) ) then
         break;

      WPos := cpos;
      if (ADE.Child = nil) then
        goto ErrPath;

      CName := nextToken;
      if CName = K_udpStepUp then
        ADE.Child := ADE.Child.Owner
      else begin
        CParent := ADE.Child;
        if not CParent.GetDEByPathSegment( CName, ADE, AObjNameType ) then begin
  ErrPath:
          cpos := WPos;
          FDepth := -1;
          break;
        end;
      end;
    end;

    Inc( FDepth );

  end; // end of while path loop
  Result := K_UDPathTokenizer.cpos - NPos + 1;
  if FDepth < 0 then
    Result := -Result;
end; // end_of procedure TN_UDBase.GetDEByRPath

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetObjByRPath
//************************************************* TN_UDBase.GetObjByRPath ***
// Get IDB Subnet descendant object by given relative path
//
//     Parameters
// ARPath       - IDB relative path
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns found IDB object.
//
// Resulting value is nil if given path is wrong
//
function  TN_UDBase.GetObjByRPath( const ARPath : string;
            AObjNameType : TK_UDObjNameType = K_ontObjName ) : TN_UDBase;
var
  DE: TN_DirEntryPar;
  PathPos: Integer;
begin
  Result := nil;
  if Self = nil then Exit;
  PathPos := GetDEByRPath( ARPath, DE, AObjNameType );
  if PathPos < 0 then Exit; // Error!
  Result := DE.Child;
end; // end_of procedure TN_UDBase.GetObjByRPath

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetPathToUDObj
//************************************************ TN_UDBase.GetPathToUDObj ***
// Get relative path to given object in IDB Subnet
//
//     Parameters
// ASrchObj     - IDB object for search
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns IDB relative path
//
// Resulting value is empty string if given object is not found in given IDB 
// Subnet.
//
// Do not call GetPathToUDObj directly, it is used automatically in 
// K_GetPathToUObj.
//
function TN_UDBase.GetPathToUDObj( ASrchObj : TN_UDBase;
                AObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
var
  h, i : Integer;
  Childs : TN_UDArray;
  Child : TN_UDBase;
begin
  Result := '';
  if (Self.ClassFlags and K_MarkScanNodeBitD) <> 0 then Exit;
  K_UDScannedUObjsList.Add( Self );
  with Self do
    ClassFlags := ClassFlags or K_MarkScanNodeBitD;

  i := IndexOfDEField( ASrchObj, K_DEFisChild );
  if i >= 0 then begin
    Result := ASrchObj.GetUName( AObjNameType );
    Exit;
  end;
  GetDirFieldArray( Childs, K_DEFisChild );
  h := DirHigh;
  for i := 0 to h do begin
    Child := Childs[i];
    if (Child = nil)                                   or
       ((Child.ClassFlags and K_MarkScanNodeBitD) <> 0) then Continue;
    //*** continue search
    Result := Child.GetPathToUDObj( ASrchObj, AObjNameType );
    if Result = '' then Continue;
//    if ( (K_udtsRAFieldsScan in K_UDTreeChildsScanFlags) or
//         (K_udtsRAFieldsSubTreeScan in K_UDTreeChildsScanFlags) ) and
    if (Result[1] <> K_udpFieldDelim) then
      Result := K_udpPathDelim + Result;
    Result := Child.GetUName( AObjNameType ) + Result;
    Break;
  end;

end; // end_of procedure TN_UDBase.GetPathToUDObj

{
//******************************************** TN_UDBase.GetRefPathRoot ***
// Get Obj Reference path Root
//
function TN_UDBase.GetRefPathRoot : TN_UDBase;
begin
  if (Owner = nil) or (Owner.RefPath <> '') then
    Result := Owner
  else
    Result := Owner.GetRefPathRoot;
end; // end_of function TN_UDBase.GetRefPathRoot

//******************************************** TN_UDBase.GetPathToObj ***
// Build Path to specified UDObj
//
function  TN_UDBase.GetPathToObj( Node : TN_UDBase;
                                  ObjNameType : TK_UDObjNameType = K_ontObjName;
                                  PathTrackingFlags : TK_PathTrackingFlags = [] ) : string;
begin
  if  not (K_ptfScanRAFields in PathTrackingFlags) then
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
  if not (K_ptfScanRAFieldsSubTree in PathTrackingFlags) then
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsSkipRAFieldsSubTreeScan];

  K_UDScannedUObjsList := Tlist.Create;
  Result := Self.GetPathToUDObj( Node, ObjNameType );
  K_ClearUObjsScannedFlag;
  FreeAndNil( K_UDScannedUObjsList );

  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsSkipRAFieldsSubTreeScan];

end; // end_of procedure TN_UDBase.GetPathToObj

//******************************************** TN_UDBase.GetOwnersPath ***
// Get Obj Owners path
//
function  TN_UDBase.GetOwnersPath( RootNode : TN_UDBase;
        ObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
var
  Ind : Integer;
  DE : TN_DirEntryPar;
  RPath : string;
begin
  if Owner <> nil then begin //*** get owner path
    if ObjNameType = K_ontObjName then begin
      Ind := Owner.IndexOfDEField( self, K_DEFisChild );
      Owner.GetDirEntry( Ind, DE );
      Result := K_BuildPathSegmentByDE( DE )
    end else
      Result := GetUName( ObjNameType );

    if Owner <> RootNode then begin
      RPath := Owner.GetOwnersPath( RootNode, ObjNameType );
      if RPath <> '' then
        Result := RPath + K_udpPathDelim + Result
      else
        Result := '';
    end;

  end else
    Result := '';
end; // end_of function TN_UDBase.GetOwnersPath

//******************************************** TN_UDBase.GetRefPathToObj ***
// Build RefPath To Specified Object
//
function  TN_UDBase.GetRefPathToObj( Node : TN_UDBase; RetSelfPath : Boolean = false ) : string;
var
  NodeRefRoot : TN_UDBase;
  PrevRefPath : string;
  PrevNodeRefPath : string;
begin
  Result := '';
  if Node = nil then Exit;
  if Self = nil then Result := K_MainRootObj.GetRefPathToObj( Node, RetSelfPath )
  else begin
    NodeRefRoot := Node.GetRefPathRoot;
    PrevRefPath := RefPath;
    PrevNodeRefPath := Node.RefPath;
    RefPath := '#';
    Node.RefPath := '';
    Result := Node.BuildRefPath();
    if Result[1] = '#' then Result := Copy( Result, 2, Length(Result) )
    else if not RetSelfPath then Result := '';
    Node.ClearRefPath( NodeRefRoot );
    RefPath := PrevRefPath;
    Node.RefPath := PrevNodeRefPath;
  end;
end; // end_of procedure TN_UDBase.GetRefPathToObj
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetMarker
//***************************************************** TN_UDBase.GetMarker ***
// Get IDB Object Marker field value
//
//     Parameters
// AField - index of mark field (default value is -1)
// Result - Returns Self.Marker[AField] value
//
// If AField is equal -1 then Self.Marker is treated as simple integer value. If
// AField >= 0 then Self.Marker field is treated as array of integer. If AField 
// is out of Self.Marker array length then 0 is returned.
//
function TN_UDBase.GetMarker( AField : Integer = -1 ): Integer;
begin
  if AField = -1 then
  begin
    Result := Marker;
  end else
  begin
    Result := 0;
    if ((ClassFlags and K_MarkerArrayBit) <> 0)  and
       (Length(TN_IArray(Marker)) > AField)  then
      Result := TN_IArray(Marker)[AField];
  end;
end; // end of function TN_UDBase.GetMarker

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SetMarker
//***************************************************** TN_UDBase.SetMarker ***
// Set IDB Object Marker field value
//
//     Parameters
// AValue - new mark field value
// AField - index of mark field (default value is -1)
//
// If AField is equal -1 then Self.Marker is treated as simple integer value. If
// AField >= 0 then Self.Marker field is treated as array of integer. If AField 
// is out of Self.Marker array length then Self.Marker.Length is automatically 
// icreased to AField+1 value and new value is set to maker field 
// Self.Marker[AField]:=AValue
//
procedure TN_UDBase.SetMarker( AValue : Integer; AField : Integer = -1 );
var h : Integer;
begin
  if AField < 0 then
  begin
    if (ClassFlags and K_MarkerArrayBit) <> 0 then
    begin
      TN_IArray(Marker) := nil;
      ClassFlags := ClassFlags and not K_MarkerArrayBit;
    end;
    Marker := AValue
  end
  else
  begin
    if (ClassFlags and K_MarkerArrayBit) = 0 then
      Marker := 0;
    h := Length(TN_IArray(Marker));
    if K_NewCapacity( AField+1, h ) then
      SetLength(TN_IArray(Marker), h);
    TN_IArray(Marker)[AField] := AValue;
    ClassFlags := ClassFlags or K_MarkerArrayBit;
  end;
end; // end of procedure TN_UDBase.GetMarker

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\IncMarker
//***************************************************** TN_UDBase.IncMarker ***
// Increment IDB Object Marker field value
//
//     Parameters
// AField - index of mark field (default value is -1)
// AValue - increment mark field value (default value is 1)
//
// If AField is equal -1 then Self.Marker is treated as simple integer value. If
// AField >= 0 then Self.Marker field is treated as array of integer. If AField 
// is out of Self.Marker array length then Self.Marker.Length is automatically 
// icreased to AField+1 value and new value is set to maker field 
// Self.Marker[AField]:= Self.Marker[AField] + AValue
//
function TN_UDBase.IncMarker( AField : Integer = -1; AValue : Integer = 1 ) : Integer;
begin
  Result := GetMarker( AField );
  Inc(Result, AValue);
  SetMarker( Result, AField );
end; // end of procedure TN_UDBase.IncMarker

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\MarkSubTree
//*************************************************** TN_UDBase.MarkSubTree ***
// Mark all IDB Subnet Child Objects
//
//     Parameters
// AMarkType - IDB Subnet mark type code (deault value is 0):
//#F
//       -1  - set each IDB object Marker field to 1
//        0  - set each IDB object Marker field by Counter of IDB object references in marking Subnet
//       >0  - set each IDB object Marker field by Depth Level calculated during marking tree-walk
//#/F
// ADepth    - IDB Subnet marking tree-walk depth bound parameter (deault value 
//             is -1 - no depth control, if ADepth > 0 then tree-walk break 
//             when ADepth reach 0 value, ADepth decrements on each Subnet 
//             level)
// AField    - number of element in markers array (deault value is -1), if 
//             AField = -1 then IDB object Marker field treats as Integer, if 
//             AField >= 0 then IDB object Marker field treats as array of 
//             Integer markers where AField is mrkers array element index
//
// Global variable K_UDTreeChildsScanFlags contains flags set to control IDB 
// Subnet scanning.
//
procedure TN_UDBase.MarkSubTree( AMarkType : Integer = 0; ADepth : Integer = -1;
                                 AField : Integer = -1 );
var
  i, h : Integer;
  Child : TN_UDBase;
  MarkValue : Integer;
  CDepth : Integer;
  DEFlags: LongWord;
begin


  if AMarkType = -1 then      //*** marker = 1
    MarkValue := 1
  else if AMarkType = 0 then  //*** marker = references count
  begin
    MarkValue := GetMarker(AField);
    Inc(MarkValue)
  end
  else                        //*** marker = level number
  begin
    MarkValue := AMarkType;
    Inc(AMarkType);
  end;

  SetMarker(MarkValue, AField);

  if ADepth = 0 then Exit;
  if ADepth > 0 then Dec(ADepth);

  h := DirHigh;
  if h < 0 then Exit;
  // childs loop
  K_UDLoopProtectionList.Add(Self);
  for i := 0 to h do
  begin
    Child := DirChild(i);
    if (Child <> nil)                                    and
//       (not K_UDOwnerChildsScan or (Child.Owner = Self)) and
       ( not (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) or
         (Child.Owner = Self) ) and
       (K_UDLoopProtectionList.IndexOf(Child) = -1) then begin
      CDepth := ADepth;
      if AMarkType <> 0 then begin
        GetDEField ( i, DEFlags, K_DEFisFlags );
        if (DEFlags and K_fpDEParentAncestor) <> 0 then
          CDepth := 0; //*** mark child instead of childs subtree
      end;//*** marker = level number
      Child.MarkSubTree(AMarkType, CDepth, AField);
    end;
  end;
  with K_UDLoopProtectionList do Delete(Count - 1);
end; // end of procedure TN_UDBase.MarkSubTree

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\UnMarkSubTree
//************************************************* TN_UDBase.UnMarkSubTree ***
// Unmark all IDB Subnet Child Objects
//
//     Parameters
// ADepth - IDB Subnet unmarking tree-walk depth bound parameter (deault value 
//          is -1 - no depth control, if ADepth > 0 then tree-walk break when
//          ADepth reach 0 value, ADepth decrements on each Subnet level)
// AField - number of element in markers array (deault value is -1), if AField =
//          -1 then IDB object Marker field treats as Integer, if AField >= 0 
//          then IDB object Marker field treats as array of Integer markers 
//          where AField is mrkers array element index
//
// Global variable K_UDTreeChildsScanFlags contains flags set to control IDB 
// Subnet scanning.
//
procedure TN_UDBase.UnMarkSubTree( ADepth : Integer = -1; AField : Integer = -1 );
var i, h : Integer;
Child : TN_UDBase;
begin
  SetMarker(0, AField);

  if ADepth = 0 then Exit;  //?? add Code 10.08.2002
  if ADepth > 0 then Dec(ADepth);

  h := DirHigh;
  if h < 0 then Exit;
  // childs loop
  K_UDLoopProtectionList.Add(Self);
  for i := 0 to h do
  begin
    Child := DirChild(i);
    if (Child = nil)                                   or
//       (K_UDOwnerChildsScan and (Child.Owner <> Self)) or
       ( (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) and
         (Child.Owner <> Self) ) or
       (K_UDLoopProtectionList.IndexOf(Child) <> -1) then Continue;
    Child.UnMarkSubTree(ADepth, AField);
  end;
  with K_UDLoopProtectionList do Delete(Count - 1);
end; // end of procedure TN_UDBase.UnMarkSubTree

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\ScanSubTree
//*************************************************** TN_UDBase.ScanSubTree ***
// Scan Child IDB objects SubTree
//
//     Parameters
// ATestNodeFunc - IDB Object Test function
// ALevel        - IDB Object Subnet level (depth from start tree-walk root 
//                 object)
// Result        - Returns TRUE if IDB Objects Subnet tree-walk have to be 
//                 continued
//
// Global variable K_UDTreeChildsScanFlags contains flags set to control IDB 
// Subnet scanning.
//
function TN_UDBase.ScanSubTree( ATestNodeFunc : TK_TestUDChildFunc; ALevel : Integer = 0 ) : Boolean;
var
  i, h: integer;
  Childs : TN_UDArray;
  Child : TN_UDBase;
  LoopProtectedChild : Boolean;
begin
  Result := true;
  if (K_UDScannedUObjsList <> nil) and
     ((Self.ClassFlags and K_MarkScanNodeBitD) <> 0) then Exit;

  h := DirHigh;
  GetDirFieldArray( Childs, K_DEFisChild );
  K_UDLoopProtectionList.Add(Self);
  Inc(ALevel);
  for i := 0 to h do begin
    Child := Childs[i];

//    if (not K_UDEmptyChildsScan and (Child = nil))     or
//       (K_UDOwnerChildsScan and (Child.Owner <> Self)) or
    if ( (Child = nil) and
          not (K_udtsEmptyChildsScan in K_UDTreeChildsScanFlags) )
                   or
       ( (Child.Owner <> Self) and
         ( (K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) or
           (K_udtsSkipRefChildsScan in K_UDTreeChildsScanFlags) ) )
                   or
       ( (Child.Owner = Self) and
         (K_udtsSkipOwnerChildsScan in K_UDTreeChildsScanFlags) ) then Continue;

    LoopProtectedChild := K_UDLoopProtectionList.IndexOf(Child) <> -1;
    if LoopProtectedChild and
       not (K_udtsLoopProtectedChildsScan in K_UDTreeChildsScanFlags) then Continue;
    case ATestNodeFunc( Self, Child, i, ALevel ) of
      K_tucOK          :
        if (Child <> nil)                                                        and
           not LoopProtectedChild                                                and
           ( (Child.Owner <> Self) or
             not (K_udtsSkipOwnerChildsSubTreeScan in K_UDTreeChildsScanFlags) ) and
           ( (Child.Owner = Self) or
             not (K_udtsSkipRefChildsSubTreeScan in K_UDTreeChildsScanFlags) )  then begin
          Result := Child.ScanSubTree( ATestNodeFunc, ALevel );
          if not Result then Break;
        end;
      K_tucSkipSubTree : Continue;
      K_tucSkipSibling : Break;
      K_tucSkipScan    :
      begin
        Result := false; Break;
      end;
    end;
  end;
  with K_UDLoopProtectionList do Delete(Count - 1);

  if K_UDScannedUObjsList <> nil then
  begin
    K_UDScannedUObjsList.Add( Self );
    with Self do
      ClassFlags := ClassFlags or K_MarkScanNodeBitD;
  end
end; // end of function TN_UDBase.ScanSubTree

{
//************************************** TN_UDBase.BuildSubTreeRelPaths ***
// Build SubTree Relative Paths
//
procedure TN_UDBase.BuildSubTreeRelPaths( TestNodeFunc : TK_TestUDNode = nil;
              ObjNameType : TK_UDObjNameType = K_ontObjName );
var
  i, h: integer;
  Childs : TN_UDArray;
  PathStr : string;
  DE : TN_DirEntryPar;

begin
  if Assigned(TestNodeFunc) and
     not TestNodeFunc( self ) then Exit;
  h := DirHigh;
  GetDirFieldArray( Childs, K_DEFisChild );
  PathStr := Self.RefPath+K_udpPathDelim;
  K_UDLoopProtectionList.Add(Self);
  for i := 0 to h do
  begin
    if (Childs[i] = nil) or
       (K_UDLoopProtectionList.IndexOf(Childs[i]) <> -1) then Continue;
    with Childs[i] do
      if (ClassFlags <> K_UDRefCI) and
         (RefPath = '') then
      begin
        Self.GetDirEntry( i, DE );
        RefPath := PathStr + K_BuildPathSegmentByDE( DE, ObjNameType );
//        RefPath := PathStr + ObjName;
        BuildSubTreeRelPaths( TestNodeFunc, ObjNameType );
      end;
  end;
  with K_UDLoopProtectionList do Delete(Count - 1);
end; // end_of function TN_UDBase.BuildSubTreeRelPaths

//************************************** TN_UDBase.ReplaceSubTreeRelPaths ***
// Build SubTree Relative Paths
//
procedure TN_UDBase.ReplaceSubTreeRelPaths( CurPath : string = ''; SL : TStrings = nil;
        ObjNameType : TK_UDObjNameType = K_ontObjName );
var
  i, h: integer;
  Childs : TN_UDArray;
  UDRepObj : TN_UDBase;

begin
  h := DirHigh;
  GetDirFieldArray( Childs, K_DEFisChild );
  K_UDLoopProtectionList.Add(Self);
  for i := 0 to h do
  begin
    if (Childs[i] = nil) or
       (K_UDLoopProtectionList.IndexOf(Childs[i]) <> -1) then Continue;
    with Childs[i] do
      if (ClassFlags <> K_UDRefCI) then  begin
        if (RefPath <> '') then
          UDRepObj := K_UDCursorGetObj( RefPath )
        else
          UDRepObj := nil;
        if SameType(UDRepObj) then  // Replace
          Self.DirChild( i, UDRepObj )
        else begin
          if (RefPath <> '') and (SL <> nil) then
            SL.Add( RefPath );
          ReplaceSubTreeRelPaths( CurPath, SL, ObjNameType );
        end;
      end;
  end;
  with K_UDLoopProtectionList do Delete(Count - 1);
end; // end_of function TN_UDBase.ReplaceSubTreeRelPaths
}

//************************************** TN_UDBase.BuildID ***
// Build  List Name
//
function TN_UDBase.BuildID( BuildIDFlags : TK_BuildUDNodeIDFlags ) : string;
begin
//  Result := ObjName;
  if K_bnfUseObjAddr in BuildIDFlags then
    Result := IntToHex( Integer(Self), 8 )
  else if K_bnfUseObjUName in BuildIDFlags then
    Result := GetUName
  else if K_bnfUseObjName in BuildIDFlags then begin
    Result := ObjName;
    if K_bnfUseObjAliase in BuildIDFlags then
      Result := Result + ':' + ObjAliase;
  end;
  if (K_bnfUseObjType in BuildIDFlags) then
    Result := Result + ':' + N_ClassTagArray[CI];
end; // end_of function TN_UDBase.BuildID

{
//************************************** TN_UDBase.BuildSubTreeList ***
// Build SubTree ReferenceObjects List
//
procedure TN_UDBase.BuildSubTreeList( BuildIDFlags : TK_BuildUDNodeIDFlags;
                SL : TStrings; TestNodeFunc : TK_TestUDNodeFunc = nil );
var
  i, h, Ind: integer;
  Childs : TN_UDArray;
  SearchName : string;
begin
  if not Assigned(SL) or
     ( Assigned(TestNodeFunc) and
       not TestNodeFunc( self ) ) then Exit;
  h := DirHigh;
  GetDirFieldArray( Childs, K_DEFisChild );
  K_UDLoopProtectionList.Add(Self);
  for i := 0 to h do
  begin
    if (Childs[i] = nil)                                    or
       (ClassFlags = K_UDRefCI)                             or
//       (K_UDOwnerChildsScan and (Childs[i].Owner <> Self))  or
       ((K_udtsOwnerChildsOnlyScan in K_UDTreeChildsScanFlags) and (Childs[i].Owner <> Self))  or
       (K_UDLoopProtectionList.IndexOf(Childs[i]) <> -1) then Continue;
    with Childs[i] do begin
      SearchName := BuildID( BuildIDFlags );
      if K_udtsSkipListDupCheck in K_UDTreeChildsScanFlags then
        Ind := -1
      else
        Ind := SL.IndexOf( SearchName );
      if Ind = -1  then
        SL.AddObject( SearchName, Childs[i] );
      BuildSubTreeList( BuildIDFlags, SL, TestNodeFunc );
    end;
  end;
  with K_UDLoopProtectionList do Delete(Count - 1);

end; // end_of procedure TN_UDBase.BuildSubTreeList
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\ClearSubTreeRefInfo
//******************************************* TN_UDBase.ClearSubTreeRefInfo ***
// Clear IDB Subnet Reference Info (RefPath, RefIndex, Marker) after Subnet data
// serialization
//
//     Parameters
// ARoot              - IDB Subnet Root object from which clear reference info 
//                      tree-walk starts
// AClearRefInfoFlags - clear serialization reference info flags set
//
procedure TN_UDBase.ClearSubTreeRefInfo( ARoot : TN_UDBase = nil; AClearRefInfoFlags : TK_ClearRefInfoFlags = [] );
var
i, h  : integer;
Child : TN_UDBase;
begin
  if K_UDScannedUObjsList <> nil then begin
    if (Self.ClassFlags and K_MarkScanNodeBitD) <> 0 then Exit;
    K_UDScannedUObjsList.Add( Self );
    with Self do
      ClassFlags := ClassFlags or K_MarkScanNodeBitD;
  end;

//*** for Root Level CLear
  RefPath := '';
  RefIndex := 0;
  if K_criClearMarker in AClearRefInfoFlags then SetMarker( 0 );
  if K_criClearChangedInfoFlag in AClearRefInfoFlags then
    ClassFlags := ClassFlags and not (K_ChangedSubTreeBit or K_ChangedSLSRBit);
  h := DirHigh;
  for i := 0 to h do begin
    Child := DirChild(i);
    if (Child = nil) or (Child = self) then Continue;
    Child.RefIndex := 0;
    if K_criClearMarker in AClearRefInfoFlags then Child.SetMarker( 0 );
    if K_criClearChangedInfoFlag in AClearRefInfoFlags then
      Child.ClassFlags := Child.ClassFlags and not (K_ChangedSubTreeBit or K_ChangedSLSRBit);
    if Child.CI = K_UDRefCI then Continue;
    if Child.RefPath <> '' then Child.ClearRefPath( ARoot );
    if (Child.Owner = self) or (K_criClearFullSubTree in AClearRefInfoFlags) then
      Child.ClearSubTreeRefInfo( ARoot, AClearRefInfoFlags );
  end;

end; // end of procedure TN_UDBase.ClearSubTreeRefInfo

{ // version 1
//************************************************ TN_UDBase.ClearSubTreeRefInfo ***
// Clear  SubTree Reference info
//
procedure TN_UDBase.ClearSubTreeRefInfo( ClearLocal : Boolean = false );
var
i, h : integer;
node : TN_UDBase;
begin
  h := DirHigh;
  RefPath := '';
  RefIndex := 0;
  for i := 0 to h do
  begin
    node := DirChild(i);
    if (node <> nil)                            and
       ((node.ClassFlags and $FF) <> K_UDRefCI) and
       (  (not ClearLocal)   or
          (node.Owner = self)) then
    begin
//??      node.RefPath := '';
//??      node.RefIndex := 0;
      node.ClearSubTreeRefInfo( ClearLocal );
    end;
  end;
end; // end of procedure TN_UDBase.ClearSubTreeRefInfo
}

{ // version 0
//************************************************ TN_UDBase.ClearSubTreeRefInfo ***
// Clear  SubTree Reference info
//
procedure TN_UDBase.ClearSubTreeRefInfo( ClearLocal : Boolean = false );
var
All, Clear, NClear : integer;
UDIter : TK_UDIter;
WDE : TN_DirEntryPar;
begin
  All := 0; Clear := 0; NClear := 0;
  UDIter := TK_UDIter.Create( self  );
  Marker := 1;
  while UDIter.GetNext1( WDE ) do
  begin
Inc(All);
    with WDE.Child do
    begin
      if (Marker <> 0) or (ClassFlags = K_UDRefCI) then
        continue;
if RefPath = '' then Inc(NClear);
      if not ClearLocal or
         ((Owner <> nil) and (Owner.Marker <> 0)) then
      begin
        RefPath := '';
Inc(Clear);
      end;
      Marker := 1;
    end;
  end;
  UDIter.Free;
  UnMarkSubTree;
end; // end of procedure TN_UDBase.ClearSubTreeRefInfo
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\ReplaceSubTreeRefObjs
//***************************************** TN_UDBase.ReplaceSubTreeRefObjs ***
// Convert IDB Tree created after deserialization to Subnet (replace special 
// reference objects to direct references)
//
procedure TN_UDBase.ReplaceSubTreeRefObjs( );
var
  i, h: integer;
  Childs : TN_UDArray;
  Child : TN_UDBase;
begin

  if (Self.ClassFlags and K_MarkScanNodeBitD) <> 0 then Exit;
  K_UDScannedUObjsList.Add( Self );
  with Self do
    ClassFlags := ClassFlags or K_MarkScanNodeBitD;

  h := DirHigh;
  GetDirFieldArray( Childs, K_DEFisChild );
  for i := 0 to h do  begin
    Child := Childs[i];
    if Child = nil then Continue;
    if Child.ClassFlags = K_UDRefCI then begin
      RestoreDRefToChild( i, Child );
    end else
      Child.ReplaceSubTreeRefObjs( );
  end;

{
  if (K_UDScannedUObjsList <> nil) and
     ((Self.ClassFlags and K_MarkScanNodeBit) <> 0) then Exit;

  h := DirHigh;
  GetDirFieldArray( Childs, K_DEFisChild );
  K_UDLoopProtectionList.Add(Self);
  for i := 0 to h do
  begin
    Child := Childs[i];
    if (Child = nil)            or
       (K_UDLoopProtectionList.IndexOf(Child) <> -1) then Continue;
    if Child.ClassFlags = K_UDRefCI then begin
      RestoreDRefToChild( i, Child );
    end else
      Child.ReplaceSubTreeRefObjs( );
  end;
  with K_UDLoopProtectionList do Delete(Count - 1);

  if K_UDScannedUObjsList <> nil then begin
    K_UDScannedUObjsList.Add( Self );
    with Self do
      ClassFlags := ClassFlags or K_MarkScanNodeBit;
  end;
}
end; // end_of function TN_UDBase.ReplaceSubTreeRefObjs

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\BuildRefObj
//*************************************************** TN_UDBase.BuildRefObj ***
// Create Reference Object instead of direct reference to Self
//
//     Parameters
// Result - Returns created ReferenceObject.
//
// Reference Objects creating (instead of "not tree" direct reference) converts 
// IDB Subnet to SubTree needed for future IDB Subnet serialization.
//
function TN_UDBase.BuildRefObj( ) : TN_UDBase;
begin
  Result := TK_UDRef.Create(  );
  Result.RefPath := RefPath;
  Result.ObjName := ObjName;
  Result.ObjAliase := ObjAliase;
  Result.RefIndex := RefIndex;
  Result.ObjInfo  := ObjInfo;
  if K_gcfSaveMarkerToRefObj in K_UDGControlFlags then
    Result.Marker := Marker;
  if K_gcfRefInfoShow in K_UDGControlFlags then
    Result.ObjAliase := RefPath;
//    Result.ObjAliase := GetOwnersPath(  K_UDGControlRefPathInfoRoot,
//                      K_ontObjUName );
end; // end_of function TN_UDBase.BuildRefObj

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\BuildSubTreeRefObjs
//******************************************* TN_UDBase.BuildSubTreeRefObjs ***
// Convert IDB Subnet to SubTree due to replacing direct references to IDB 
// Objects to special Reference Objects
//
procedure TN_UDBase.BuildSubTreeRefObjs(  );
var
  i, h: integer;
  Childs : TN_UDArray;
  Child : TN_UDBase;
begin
  h := DirHigh;
  GetDirFieldArray( Childs, K_DEFisChild );
  for i := 0 to h do begin
    Child := Childs[i];
    if Child = nil then Continue;
//*** replace object to its ReferenceObject
    Child.BuildRefPath();
    if ( Child.Owner <> Self ) and
       ( Child.RefPath <> '' ) then
    begin //*** find Reference Path
      Child := Child.BuildRefObj;
      PutDirChild( i, Child )
    end else
      Child.BuildSubTreeRefObjs( );
  end;

end; // end_of TN_UDBase.BuildSubTreeRefObjs

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\ReplaceSubTreeNodes
//******************************************* TN_UDBase.ReplaceSubTreeNodes ***
// Replace IDB Subnet Child nodes references
//
//     Parameters
// ARepChildsArray - array of pairs (OldReference,NewReference)
//
procedure TN_UDBase.ReplaceSubTreeNodes( ARepChildsArray : TK_BaseArray );
var
  i, ind, h : Integer;
  refs : TK_UDRefsRep;
begin
  if (Self = nil) or
     (ARepChildsArray.Count = 0) then Exit;

  if ((Self.ClassFlags and K_MarkScanNodeBitD) <> 0) then Exit;
  K_UDScannedUObjsList.Add( Self );
  with Self do
    ClassFlags := ClassFlags or K_MarkScanNodeBitD;

  h := DirHigh;
  for i := 0 to h do
  begin
    refs.OldChild := DirChild(i, TN_UDBase(1));
    if (Integer(refs.OldChild) = 1) or (refs.OldChild = Self) then Continue;
    if ARepChildsArray.FindItem( ind, @refs ) then begin
      ARepChildsArray.GetItem( ind, refs );
      ReplaceDirChild( i, refs.NewChild );
      AddChildVNodes( i );
    end else if (refs.OldChild <> nil) then
      refs.OldChild.ReplaceSubTreeNodes( ARepChildsArray );
  end;

end; // end of procedure TN_UDBase.ReplaceSubTreeNodes

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetIconIndex
//************************************************** TN_UDBase.GetIconIndex ***
// Get Index of Self Icon in TreeView ImageList
//
//     Parameters
// Result - Returns index of Self Icon in TreeView ImageList
//
function TN_UDBase.GetIconIndex: Integer;
begin
  Result := ImgInd
end; // end_of function TN_UDBase.GetIconIndex

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\CI
//************************************************************ TN_UDBase.CI ***
// Get Self Class Index
//
//     Parameters
// Result - Returns Self Class Index in IDB Object Types (Classes) Array
//
function TN_UDBase.CI(): Integer;
begin
  Result := -1;
  if Self = nil then Exit;
  Result := ClassFlags and $FF;
end; // end_of function TN_UDBase.CI

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\GetUName
//****************************************************** TN_UDBase.GetUName ***
// Get IDB Object user name (Self.ObjName or Self.ObjAliase)
//
//     Parameters
// AObjNameType - IDB Object name type enumeration
// Result       - Returns user name value according to given AObjNameType
//
function TN_UDBase.GetUName( AObjNameType : TK_UDObjNameType = K_ontObjUName ) : string;
begin
  Result := '';
  if Self = nil then Exit;
  if (AObjNameType = K_ontObjAliase) or
     ( (ObjAliase <> '') and (AObjNameType <> K_ontObjName) ) then
    Result := ObjAliase
  else
    Result := ObjName;
end; // end_of function TN_UDBase.GetUName

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SetUName
//****************************************************** TN_UDBase.SetUName ***
// Set IDB Object user name (Self.ObjName or Self.ObjAliase)
//
//     Parameters
// AName        - given name value
// AObjNameType - IDB Object name type enumeration
//
// Sets Self.ObjName or Self.ObjAliase according to AObjNameType.
//
procedure TN_UDBase.SetUName( AName : string; AObjNameType : TK_UDObjNameType = K_ontObjUName );
begin
  if (ObjAliase = '') and (AObjNameType = K_ontObjUName) then
    AObjNameType := K_ontObjName;
  case AObjNameType of
    K_ontObjUName,
    K_ontObjAliase : ObjAliase := AName;
    K_ontObjName   : ObjName := AName;
  end;
end; // end_of procedure TN_UDBase.SetUName

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\BuildChildsList
//*********************************************** TN_UDBase.BuildChildsList ***
// Build IDB Object Childs List using Childs UserName
//
//     Parameters
// ASList       - Strings with resulting Childs List
// AObjNameType - included Child Objects name type enumeration
//
procedure TN_UDBase.BuildChildsList( ASList : TStrings; AObjNameType : TK_UDObjNameType = K_ontObjUName );
var
  i, h : Integer;
  Child : TN_UDBase;
begin
  ASlist.Clear;
  h := DirHigh;
  for i := 0 to h do begin
    Child := DirChild(i);
    if Child = nil then continue;
    ASList.AddObject( Child.GetUName( AObjNameType ), Child );
  end;
end; // end of procedure TN_UDBase.BuildChildsList

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\AddSelfToRefTable
//********************************************* TN_UDBase.AddSelfToRefTable ***
// Add deserialized object references table (RefTable) for IDB Subnet 
// deserialization acceleration
//
//     Parameters
// Result - Returns TRUE if self is added to RefTable
//
// Do not call AddSelfToRefTable directly, it is used automatically in 
// TN_UDBase.GetFromText and K_GetDEFromSBuf.
//
function TN_UDBase.AddSelfToRefTable( ) : Boolean;
var  PRefTabLeng, RefTabLeng : Integer;
begin
  Result := false;
  if (ClassFlags and $FF) <> K_UDRefCI then
  begin
    Result := true;
    if RefIndex <> 0 then
    begin  // put direct reference to Reference Table
      RefTabLeng := Length(K_UDRefTable);
      PRefTabLeng := RefTabLeng;
      if K_NewCapacity( RefIndex + 1, RefTabLeng ) then
      begin // Resize Table
        SetLength( K_UDRefTable, RefTabLeng );
        FillChar( K_UDRefTable[PRefTabLeng],
          (RefTabLeng - PRefTabLeng) * SizeOf(Integer), 0 );
      end;
      K_UDRefTable[RefIndex] := self;
    end;
  end;
end; // end_of procedure TN_UDBase.AddSelfToRefTable

//************************************** TN_UDBase.IsSPLType
// Test if object is UDRarray and it's SPL Type has specified name
//
function TN_UDBase.IsSPLType(TypeName: string): Boolean;
begin
  Result := false;
end; // end_of function TN_UDBase.IsSPLType

//************************************** TN_UDBase.AddChildToSubTree
// Add Child From DE to Self SubTree - High Level UDTree Modify Action
//  if Node support High Level UDTree Modify Action then
//     method results True if PDE = nil
//  Method results True if Node Add Child Specified by DirEntry
// to Self SubTree
//
function TN_UDBase.AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ): Boolean;
begin
  Result := false;
end; // end_of function TN_UDBase.AddChildToSubTree

//************************************** TN_UDBase.RemoveSelfFromSubTree
// Remove Self From SubTree Specified by DE - High Level UDTree Modify Action
//  if Node support this High Level UDTree Modify Action then
//     method results True if PDE = nil
//  Method results True if Node Remove Self From Specified DirEntry
//
function TN_UDBase.RemoveSelfFromSubTree(PDE: TK_PDirEntryPar): Boolean;
begin
  Result := false;
end; // end_of function TN_UDBase.RemoveSelfFromSubTree

//************************************** TN_UDBase.DeleteSubTreeChild
// Delete Specified by Index Child From SubTree  - High Level UDTree Modify Action
//  results True if Child Node Remove Self From Specified DirEntry
//
function TN_UDBase.DeleteSubTreeChild(Index: Integer): Boolean;
begin
  Result := false;
end; // end_of function TN_UDBase.DeleteSubTreeChild

//************************************** TN_UDBase.CanMoveChilds
//  returns True if Node Cane Move Childs
//
function TN_UDBase.CanMoveChilds( ): Boolean;
begin
  Result := false;
end; // end_of function TN_UDBase.CanMoveChilds

//************************************** TN_UDBase.CanMoveDE
//  returns True if Node Cane Move DE
//
function TN_UDBase.CanMoveDE( const DE : TN_DirEntryPar ): Boolean;
begin
  Result := false;
end; // end_of function TN_UDBase.CanMoveDE

//************************************** TN_UDBase.GetSubTreeParent
//  returns Application SubTree Parent Node
//
function TN_UDBase.GetSubTreeParent( const DE : TN_DirEntryPar ): TN_UDBase;
begin
  Result := DE.Parent;
end; // end_of function TN_UDBase.GetSubTreeParent

//************************************** TN_UDBase.MoveSubTreeChilds
//  Move Application SubTree Childs
//
procedure TN_UDBase.MoveSubTreeChilds( dInd, sInd: Integer; mcount : Integer = 1 );
begin
  MoveEntries( dInd, sInd, mcount );
end; // end_of function TN_UDBase.MoveSubTreeChilds

//************************************** TN_UDBase.CanAddChildByPar
//  returns True if Child specified by AddPar can be added to this Node
//
function TN_UDBase.CanAddChildByPar( AddPar : Integer = 0 ): Boolean;
begin
  Result := false;
end; // end_of function TN_UDBase.CanAddChildByPar

//************************************** TN_UDBase.CanAddChild
//  returns True if Child specified by AddPar can be added to this Node
//
function TN_UDBase.CanAddChild( Child : TN_UDBase ): Boolean;
begin
  Result := false;
end; // end_of function TN_UDBase.CanAddChild

//************************************** TN_UDBase.CanAddOwnChildByPar
//  returns True if Child specified by AddPar can be added to this Node
//
function TN_UDBase.CanAddOwnChildByPar( CreatePar : Integer = 0 ): Boolean;
begin
  Result := true;
end; // end_of function TN_UDBase.CanCreateChildByPar

//************************************** TN_UDBase.SelfSubTreeCopy
// Self Copy - High Level UDTree Modify Action
//
function TN_UDBase.SelfSubTreeCopy( CopyPar : TK_CopySubTreeFlags = [] ) : TN_UDBase;
begin
  Result := nil;
end; // end_of function TN_UDBase.SelfSubTreeCopy

//************************************** TN_UDBase.GetSubTreeChildDE
// Get Child DE for High Level UDTree Modify Action
//  if Node support High Level UDTree Modify Action then
//     method results true else false
//
function TN_UDBase.GetSubTreeChildDE( Ind : Integer; out DE : TN_DirEntryPar ) : Boolean;
begin
  Result := false;
  if (Ind < 0) or (Ind > DirHigh) then Exit;
  Result := true;
  GetDirEntry( Ind, DE );
end; // end_of function TN_UDBase.GetSubTreeChildDE

//************************************** TN_UDBase.GetSubTreeChildHigh
// Get Child High Index for High Level UDTree Modify Action
//
function TN_UDBase.GetSubTreeChildHigh : Integer;
begin
  Result := DirHigh;
end; // end_of function TN_UDBase.GetSubTreeChildHigh

//************************************** TN_UDBase.CanCopyChild
//  returns True if Child specified by PDE can be Copied using Copy Mode
//
function TN_UDBase.CanCopyChild( PDE: TK_PDirEntryPar; var CopyPar: Integer): Boolean;
begin
  Result := true;
end; // end_of function TN_UDBase.CanCopyChild

//************************************** TN_UDBase.CanCopySelf
//  returns True if Child specified by PDE and Copy Mode can be Copied
//
function TN_UDBase.CanCopySelf( CopyPar: TK_CopySubTreeFlags = [] ): Boolean;
begin
  Result := true;
end; // end_of function TN_UDBase.CanCopySelf

//************************************** TN_UDBase.CountSubTreeReferences
// Count Self SubTree References to specified Node Using High Level UDTree Rourines
//
function TN_UDBase.CountSubTreeReferences( Node : TN_UDBase ) : Integer;
var
  i, h : Integer;
  DE : TN_DirEntryPar;
begin
  Result := 0;
  if (K_UDLoopProtectionList.IndexOf(Self)  <> -1) or
     not AddChildToSubTree( nil ) then Exit;
  K_UDLoopProtectionList.Add(Self);
  h := GetSubTreeChildHigh;
  for i := 0 to h do begin
    GetSubTreeChildDE( i, DE );
    if DE.Child = Node then
      Inc(Result)
    else
      Result := Result + DE.Child.CountSubTreeReferences( Node );
  end;
  with K_UDLoopProtectionList do Delete(Count - 1);
end; // end_of function TN_UDBase.CountSubTreeReferences

//************************************** TN_UDBase.SelfCopy
// Self SubTree Copy Using High Level UDTree Modify Actions
//
function TN_UDBase.SelfCopy( CopyPar : TK_CopySubTreeFlags = [] ) : TN_UDBase;
var
  i, h : Integer;
  DE : TN_DirEntryPar;
begin
  Result := Self;
  if CopyPar = [] then Exit;
  Result := Clone;
  CopyPar := CopyPar - [K_mvcCopySelf];
  h := GetSubTreeChildHigh;
  for i := 0 to h do begin
    GetSubTreeChildDE( i, DE );
    Result.AddChildToSubTree( @DE, CopyPar );
  end;
end; // end_of function TN_UDBase.SelfCopy

//************************************** TN_UDBase.SelfSubTreeRemove
// Self SubTree Remone Using High Level UDTree Modify Actions
//
function TN_UDBase.SelfSubTreeRemove : Boolean;
var
  i, h : Integer;
  DE : TN_DirEntryPar;
begin
  h := GetSubTreeChildHigh;
  Result := true;
  for i := h downto 0 do begin
    GetSubTreeChildDE( i, DE );
//    Result := Result and RemoveSelfFromSubTree( @DE );
    Result := Result and DE.Child.RemoveSelfFromSubTree( @DE );
  end;
end; // end_of function TN_UDBase.SelfSubTreeRemove

{
//************************************** TN_UDBase.SelfSubTreeList
// Build Self SubTree Objects List using High Level SubTree Loop
//
procedure TN_UDBase.SelfSubTreeList( BuildIDFlags : TK_BuildUDNodeIDFlags;
                SL : TStrings  );
var
  i, h: integer;
  SearchName : string;
  DE : TN_DirEntryPar;
begin
  if not Assigned(SL)  then Exit;

//  SearchName := BuildID( BuildIDFlags );
//  Ind := SL.IndexOf( SearchName );
//  if Ind <> -1  then Exit;

  if Marker <> 0 then Exit;
  SearchName := BuildID( BuildIDFlags );
  SL.AddObject( SearchName, Self );
  Marker := 1;
  h := GetSubTreeChildHigh;
  for i := 0 to h do begin
    GetSubTreeChildDE( i, DE );
    with DE do begin
      if (Child = nil) or
         (Child.ClassFlags = K_UDRefCI) then Continue;
      Child.SelfSubTreeList( BuildIDFlags, SL );
    end;
  end;

end; // end_of procedure TN_UDBase.SelfSubTreeList
}

//************************************** TN_UDBase.CDimIndsConv
// Code Dimention Items Indexes Conversion
// This method must be override in UDObjects which contains CDim Indexes
// if i is old CDim Item Index then ConvInds[i] is new CDim Item Index
// if ConvInds[i] = -1 then CDim Item with Index i is now absent in CDim
//
function TN_UDBase.CDimIndsConv( UDCD: TN_UDBase; PConvInds: PInteger;
                                  RemoveUndefInds: Boolean) : Boolean;
begin
  Result := false;
end; // end_of procedure TN_UDBase.CDimIndsConv


//************************************** TN_UDBase.CDimLinkedDataReorder
// This method must be override in UDObjects which contains Data Vectors,
// which are linked to some Synchronizing UDObjects
// TK_UDCSDim or its descendants (TK_UDCDRel)
// Synchronizing UDObjects have some inteface fileds To Reorder Data Vectors
// GetConvDataInds method which returns TRUE if data conversion is needed
// and Pointers and Counters to Convertion Info:
//   Reoreder Indexes Counter - new Data Vector's Counter
//   Reoreder Indexes - ReorederInds[i] is Index of Data Vector Element which must be now in i position
//   Free Indexes    - Indexes of Data Vector Elements which must be Free before Reordering
//   Init Indexes    - Indexes of Data Vector Elements which must be Init after  Reordering
//
procedure TN_UDBase.CDimLinkedDataReorder;
begin

end; // end_of procedure TN_UDBase.CDimLinkedDataReorder

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDBase\SetChangedSubTreeFlag
//***************************************** TN_UDBase.SetChangedSubTreeFlag ***
// Mark given IDB Object and it's Owners as changed
//
//     Parameters
// ASetSLSRChange - if =TRUE then and Self is SLSR (Separately Loaded Subtree 
//                  Root) Self is marked by special mark atribute: 
//                  K_ChangedSLSRBit
//
// Each IDB Object can be marked as changed by special runtime bit attribute: 
// K_ChangedSubTreeBit. This method can spread this attribute starting from Self
// UP: to Owner, Owner.Owner and etc.
//
procedure TN_UDBase.SetChangedSubTreeFlag( ASetSLSRChange : Boolean = false );

begin
  if Self = nil then Exit;
  if ASetSLSRChange                        and
     ((ObjFlags and K_fpObjSLSRFlag) <> 0) and
     ((ObjFlags and K_fpObjSLSRJoin)  = 0) then begin // SLSR
    ClassFlags := ClassFlags or K_ChangedSLSRBit;
    Exit;
  end;

//if ObjInfo = '(#CMArchSections#)RF_00000205.cmi' then
//ObjInfo := '(#CMArchSections#)RF_00000205.cmi';
  if (ClassFlags and K_ChangedSubTreeBit) <> 0 then Exit;
  ClassFlags := ClassFlags or K_ChangedSubTreeBit;

  if K_IsUDRArray(Self) and
     (TK_UDRArray(Self).R.ElemSType = K_ArchiveDTCode.DTCode) then begin
    TK_PArchive(TK_UDRArray(Self).R.P).SelfArchDataWasChanged := true;
    Exit;
  end;

  if (Owner <> nil) then   // Not Global Root
    with Owner do
      SetChangedSubTreeFlag(
          ((ObjFlags and K_fpObjSLSRFlag) <> 0) and
          ((ObjFlags and K_fpObjSLSRJoin)  = 0) );
end; //*** end of TN_UDBase.SetChangedSubTreeFlag

//************************************************ TN_UDBase.SetSubTreeClassFlags
//  Set SubTree Class Flags to Node and it's Owners
//
procedure TN_UDBase.SetSubTreeClassFlags( ASetFlags : LongWord );

begin
  if (Self = nil) or ((ClassFlags and ASetFlags) <> 0) then Exit;
  ClassFlags := ClassFlags or ASetFlags;

  if (Owner <> nil) then
    with Owner do
      SetSubTreeClassFlags( ASetFlags );
end; //*** end of TN_UDBase.SetSubTreeClassFlags

//********** end of TN_UDBase class methods  **************

//********** TN_VNode class methods  **************

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\Create
//********************************************************* TN_VNode.Create ***
// IDB object Visual Node Class Constructor
//
//     Parameters
// AVTree           - Visual Tree where VNode will be created
// AParent          - parent VNode
// ADE              - IDB directory entry for corresponding IDB object
// ATreeNode        - on input base TreeNode (TreeView Node) (parent or sibling)
//                    for new TreeNode corresponding to creating VNode, on 
//                    output created TreeNode
// ATreeNodeAddMode - add new TreeNode to TreeView mode (add, insert, add child 
//                    etc.)
// AVLevel          - new VNode level in Visual Tree
// AShowChilds      - create child VNodes flag (if true and cooresponding IDB 
//                    object has child objects then corresponding child VNodes 
//                    will be created)
//
constructor TN_VNode.Create( const AVTree: TN_VTree; const AParent : TN_VNode;
                                const ADE: TN_DirEntryPar; var ATreeNode: TTreeNode;
                                ATreeNodeAddMode : TK_TreeNodeAddMode; AVLevel : integer;
                                AShowChilds : Boolean = true );
var Ind : Integer;
begin
//  VNUDObjRC := 0;
  if AVTree = nil then Exit; // only for creation of N_EmptySelected
  CID := N_CPUCounter;
  VNUDObj := ADE.Child;

//*** place to the VNUDObj VNodes list
  PrevVNUDObjVNode := VNUDObj.LastVNode;
  VNUDObj.LastVNode := Self;

  VNParent := AParent;
//*** place to the VParent VNodes list
  if VNParent <> nil then
  begin
    PrevVNSibling := VNParent.LastVNChild;
    VNParent.LastVNChild  := Self;
  end;
  LastVNChild  := nil;

  VNCode := ADE.VCode;
  VNLevel := AVLevel;
  VNVTree  := AVTree;

  if VNUDObj <> VNVTree.RootUObj then
  begin
    if ((VNUDObj.ObjFlags and K_fpObjTVAutoCheck) <> 0) and
      ((VNUDObj.ObjFlags and K_fpObjTVChecked) <> 0) then
      VNVTree.CheckedUobjsList.Add(VNUDObj);
  end;

  VNState := [];

  if VNVTree.TreeView <> nil then // TreeView exists - add TreeNode
  begin
    case ATreeNodeAddMode of
      K_tnmNodeAddNone :
      begin
        ATreeNode := nil;
      end;

      K_tnmNodeInsert       : ATreeNode := VNVTree.TreeView.Items.Insert(   ATreeNode, VNUDObj.ObjName );
      K_tnmNodeAddChild     : ATreeNode := VNVTree.TreeView.Items.AddChild( ATreeNode, VNUDObj.ObjName );
      K_tnmNodeAddChildFirst: ATreeNode := VNVTree.TreeView.Items.AddChildFirst( ATreeNode, VNUDObj.ObjName );
      K_tnmNodeAdd          : ATreeNode := VNVTree.TreeView.Items.Add( ATreeNode, VNUDObj.ObjName );

    end; // case WhereToAdd of
  end;
  VNTreeNode := ATreeNode;

//*** select node visual flags
  VNVFlags := K_GetDEVFlags( ADE,  VNVTree.VTFlags, VNVTree.VTFlagsNum ) and K_fvUseMask;

//*** select what child VNodes build - before UpdateTreeNodeName
  Ind := -1;
  if ATreeNode <> nil then
  begin
    ATreeNode.Data := Self;
    UpdateTreeNodeCaption();
  end;
  {$IFDEF N_DEBUG}
  DebStr := 'New VN=$' + IntToHex( Integer(self), 8);
  if VNTreeNode <> nil then DebStr := DebStr+
    ' VT=$'+ IntToHex( Integer(VNVTree), 8) +
    ' TN=$'+ IntToHex( Integer(VNTreeNode), 8) +
    ' name="'+VNTreeNode.Text+'"';
  N_AddDebString( 2, DebStr );
  {$ENDIF}
  VNUDObj.ClassFlags := VNUDObj.ClassFlags or K_MarkVizBitD; // to prevent VNode creation cycling
  CreateChildVNodes( Ind, AShowCHilds );
  VNUDObj.ClassFlags := VNUDObj.ClassFlags  and not K_MarkVizBitD;

end; // end_of constructor TN_VNode.Create

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\Delete
//********************************************************* TN_VNode.Delete ***
// Delete Visual Node and all its child Visual Subtree VNodes
//
//     Parameters
// ADeleteFlags - set of delete VNode modes
//
procedure TN_VNode.Delete( ADeleteFlags: TK_VTreeVNodeDelFlags = [] );

var
  NewDFlags : TK_VTreeVNodeDelFlags;
  WVNode : TN_VNode;
  PVNode : ^TN_VNode;
  UParent : TN_UDBase;
  Ind, VCount : Integer;
 {$IFDEF N_DEBUG}
    debInfo : string;
  {$ENDIF}
begin
  {$IFDEF N_DEBUG}
  DebStr := 'Del VN=$' + IntToHex( Integer(self), 8) + ' flags='+IntToStr(VNVFlags);
  if VNTreeNode <> nil then DebStr := DebStr +
    ' VT=$'+ IntToHex( Integer(VNVTree), 8)+
    ' TN=$'+ IntToHex( Integer(VNTreeNode), 8)+
    ' name="'+VNTreeNode.Text+'"';
  debInfo := DebStr;
  N_AddDebString( 2, DebStr );
  {$ENDIF}

{
  if (VNAttr and K_fVNodeStateDeleted) <> 0 then Exit; // self is already destroying
             // (Exit prevents infinite recursive call by OnDeletion event)
  VNAttr := VNAttr or K_fVNodeStateDeleted;    // set "is destroying" flag
}
  if K_fVNodeStateDeleted in VNState then Exit; // self is already destroying
             // (Exit prevents infinite recursive call by OnDeletion event)
  VNState := VNState + [K_fVNodeStateDeleted];    // set "is destroying" flag
//  NewDFlags := DFlags or K_fNTPDelVNode; // add VNode is destroying flag
  NewDFlags := ADeleteFlags + [K_fNTPDelVNode]; // add VNode is destroying flag


//*** Delete SubTree VNodes
  while Assigned(LastVNChild) do LastVNChild.Delete();

  with VNVTree do
  begin
    if Assigned(VNTreeNode) then
    begin
      VNTreeNode.Data := nil; // VNode is "deleting" flag
  //**??    TreeView.Items.BeginUpdate;
      ChangeTreeViewUpdateMode(true);
      VNTreeNode.Delete;
      ChangeTreeViewUpdateMode(false);
  //**??    TreeView.Items.EndUpdate;
    end;

    UParent := GetParentUObj;

    if VNParent <> nil then
    begin // VNode is not VTree root VNode
  //*** prepear VCount correction
      Ind := UParent.IndexOfDEField( VNCode, K_DEFisVCode );
      UParent.GetDEField( Ind, VCount, K_DEFisVCounter );

  //*** clear self in VParent VNodes
      PVNode := @VNParent.LastVNChild;
      while PVNode^ <> nil do begin
        WVNode := PVNode^;
        if WVNode = self then begin
          PVNode^ := WVNode.PrevVNSibling;
          break;
        end;
        PVNode := @WVNode.PrevVNSibling;
      end;
      if VNVTree.Selected = self then
        VNVTree.Selected := nil;
      VNVTree.MarkedVNodesList.Remove( Self );
      VNVTree.CheckedUobjsList.Remove( Self.VNUDObj );
    end else begin // VNode is VTree root VNode
      if K_gcfSkipVTreeDeletion in K_UDGControlFlags then begin
        RootUObj := nil;
        RootVNode := nil;
        Selected := nil;
        MarkedVNodesList.Remove( Self );
      end else begin
  //      if (DFlags and K_fNTPDelVTree1) = 0 then
        if not (K_fNTPDelVTree1 in ADeleteFlags) then
          VNVTree.Delete( NewDFlags ); // del Vtree1
      end;
      VCount := 0;
      Ind := -1;
    end;

  //*** clear self in Uobj VNodes
    PVNode := @VNUDObj.LastVNode;
    while PVNode^ <> nil do
    begin
      WVNode := PVNode^;
      if WVNode = self then
      begin
        PVNode^ := WVNode.PrevVNUDObjVNode;
        Dec(VCount);
        break;
      end;
      PVNode := @WVNode.PrevVNUDObjVNode;
    end;
  end;

  if UParent <> nil then
    UParent.PutDEField( Ind, VCount, K_DEFisVCounter );

  Destroy;
  {$IFDEF N_DEBUG}
  N_AddDebString( 2, 'Fin ' + debInfo );
  {$ENDIF}
end; // end of procedure TN_VNode.Delete

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\CreateChildVNodes
//********************************************** TN_VNode.CreateChildVNodes ***
// Create Visual Node child VNodes for corresponding IDB object child objects
//
//     Parameters
// AInd        - index of corresponding IDB child object (if =-1 then all child 
//               VNodes will be created)
// AShowChilds - real child VNodes creation flag (if =false then only special 
//               child TreeNode to corresponding TreeNode will be created for 
//               showing TreeView '+' button for manual TreeNode expanding)
//
procedure TN_VNode.CreateChildVNodes( Ind : Integer = -1;
                                      AShowChilds : Boolean = true );
var
  VCount : integer;
  i : integer;
  TNode: TTreeNode;
  AVlevel : integer;
  WhereToAdd: TK_TreeNodeAddMode;
  StartWhereToAdd: TK_TreeNodeAddMode;
  MaxVC: LongWord;
  WDE : TN_DirEntryPar;
begin
  AVlevel := VNLevel + 1;
  if (Ind = -2) or
     ((VNVFlags and K_fvSkipChildDir) = K_fvSkipChildDir) or
     ((VNVTree.VTDepth <> 0) and (AVlevel > VNVTree.VTDepth)) or
     (VNUDObj.DirLength = 0) or
     ((K_fVNodeStateNotExanded in VNState) and (Ind >= 0))
//     (((VNAttr and K_fVNodeStateNotExanded) <> 0) and (Ind >= 0))
     then Exit; // no children to show

  TNode := VNTreeNode;
  i := 0;
  StartWhereToAdd := K_tnmNodeAdd;
  if Ind >= 0 then //*** single child create
  begin
    i := Ind;
    StartWhereToAdd := K_tnmNodeInsert;
  end;

  repeat

    i := IndexOfNextVisualisedChild( i, WDE, 1 );
    if (i <> -1) and
       ((Ind = -1) or (Ind = i)) and
       (((WDE.Child.ClassFlags and K_MarkVizBitD) = $0)) then
    begin
//*************** add new VNUDObj **********
      MaxVC := VNUDObj.Ndir^.UDDMaxVCode;
      if not AShowChilds then
      begin //*** add special TreeNode for Exanding mode
        VNState := VNState + [K_fVNodeStateNotExanded];
        VNVTree.TreeView.Items.AddChild( TNode, '' );
        break;
      end else
      begin // add real Child VNode
        VNState := VNState - [K_fVNodeStateNotExanded];
        VNUDObj.GetDEField( i, VCount, K_DEFisVCounter );
        if VCount = 0 then
        begin
  //*** put unique VCode to corresponding DirEntry
          WDE.VCode := MaxVC;
          VNUDObj.PutDEField( i, WDE.VCode, K_DEFisVCode );
  //*** change unique VCode parameter
          Inc(VNUDObj.Ndir^.UDDMaxVCode);
        end;
        Inc(VCount);
        VNUDObj.PutDEField( i, VCount, K_DEFisVCounter );

  //**!!??      VNUDObj.GetDirEntry( i, WDE );

        WhereToAdd := StartWhereToAdd;
        GetTreeNodePos( WDE, TNode, WhereToAdd );
        TN_VNode.Create( VNVTree, Self, WDE, TNode, WhereToAdd, AVLevel, false );

        if Ind <> -1 then break; //*** stop loop if single entry add
      end;
    end else break;
    i := i + 1;
  until false;
end; // end_of procedure TN_VNode.CreateChildVNodes

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\GetTreeNodePos
//************************************************* TN_VNode.GetTreeNodePos ***
// Get Visual Node Base TreeNode and add new TreeNode mode for future TreeNode 
// adding
//
//     Parameters
// ADE              - IDB directory entry for corresponding IDB object
// ATreeNode        - on input - sometimes last added TreeNode, on output - the 
//                    TreeNode near which new TreeNode have to be added
// ATreeNodeAddMode - on input adding mode:
//#F
//              if <> K_fTreeNodeInsert - building new dir visual representation
//              if =  K_fTreeNodeInsert - adding new single child visual representation
//#/F
//  on output - future TreeNode adding flags (Add, AddChild, Insert)
//
procedure TN_VNode.GetTreeNodePos( const ADE : TN_DIrEntryPar;
                                   var ATreeNode : TTreeNode;
                                   var ATreeNodeAddMode : TK_TreeNodeAddMode);
var
  AVFlags, i : Integer;
  NextNode : TTreeNode;
  WDE1     : TN_DirEntryPar;
  WVNode   : TN_VNode;
//**VCode : LongWord;
//**ChildUObj : TN_UDBase;
//****Childs : TN_UDArray;
//****VCodes : TN_IArray;

label AddNode, SearchpreviousVisible, SearchSortedPosition,
 SearchInSibling, SearchInChilds, InsertNode, AddChildNode,
 SearchpreviousVisibleChild;
begin
  if VNVTree.TreeView = nil then Exit; // only VNodes creation
  AVFlags := VNVFlags and K_fvDirSortedMask;
  if VNVTree.TreeView.Items.Count = 0 then
    goto AddNode //*** empty tree view - first node add Node is already set
  else
    if VNParent = nil then  //**************** new TreeNode to root level
      if ATreeNodeAddMode <> K_tnmNodeInsert then //*** add while building new dir visual representation
        if (AVFlags = K_fvDirUnsorted) or
           ((ADE.DEFlags and K_fpDEProtected) <> 0) then goto AddNode
        else goto SearchInSibling
      else //*** insert single node to existing
        if ((ADE.DEFlags and K_fpDEProtected) <> 0 ) or
           (AVFlags = K_fvDirUnsorted) then goto SearchpreviousVisible
        else goto SearchInSibling
    else //***************** new TreeNode to not root level
      if not VNTreeNode.HasChildren then
        goto AddChildNode //*** empty tree level - first node in level
      else
        if ATreeNodeAddMode <> K_tnmNodeInsert then //*** add while building new dir visual representation
          if (AVFlags = K_fvDirUnsorted) or
           ((ADE.DEFlags and K_fpDEProtected) <> 0) then goto AddNode
          else goto SearchInChilds
        else begin //*** insert single node to existing
          ATreeNode := VNTreeNode.GetFirstChild;
          if (AVFlags = K_fvDirUnsorted) or
           ((ADE.DEFlags and K_fpDEProtected) <> 0) then goto SearchpreviousVisibleChild
          else goto SearchInChilds;
        end;

SearchInSibling:
  NextNode := VNVTree.TreeView.Items.GetFirstNode;
  goto SearchSortedPosition;

SearchInChilds:
  NextNode := VNTreeNode.GetFirstChild;
  goto SearchSortedPosition;

SearchSortedPosition:
  repeat
    ATreeNode := NextNode;
    TN_VNode(ATreeNode.Data).GetDirEntry( WDE1 );
    if (WDE1.DEFlags and K_fpDEProtected) = 0 then
    begin
      if K_CompareDirEntries( WDE1,
                              ADE, VNVFlags ) then
        goto InsertNode;
    end;
    NextNode := ATreeNode.GetNextSibling;
  until NextNode = nil;
  goto AddNode;

//*** common case for insert in unsorted mode and insert fixed
//  it is more complicated because of fixed case
SearchpreviousVisible:
  ATreeNode := VNTreeNode;
SearchpreviousVisibleChild:
  i := ADE.DirIndex - 1;
  repeat
    i := IndexOfNextVisualisedChild( i, WDE1, -1 );
    if i = -1 then break;
//**!!??    WVNode := GetChildVNode( VNUDObj.DirChild(i, VNUDObj), VCodes[i] );
    WVNode := GetChildVNode( WDE1.Child, WDE1.VCode );
    if WVNode <> nil then begin
      ATreeNode := WVNode.VNTreeNode.GetNextSibling;
      if ATreeNode <> nil then // visible is find insert
        goto InsertNode
      else begin          // visible is not find add last
        ATreeNode := VNTreeNode;
        if ATreeNode = nil then goto AddNode // add last sibling
        else goto AddChildNode;         // add last child
      end;
    end;
    Dec(i);
  until false;

  ATreeNode := VNTreeNode;
  if ATreeNode <> nil then
  begin // add first child
    ATreeNodeAddMode := K_tnmNodeAddChildFirst;
    Exit;
  end;
        // add first sibling in root level
  ATreeNode := VNVTree.TreeView.Items.GetFirstNode;

InsertNode:
  ATreeNodeAddMode := K_tnmNodeInsert;
  Exit;


AddChildNode:
  ATreeNodeAddMode := K_tnmNodeAddChild;
  Exit;

AddNode:
  ATreeNodeAddMode := K_tnmNodeAdd;

end; // end_of procedure TN_VNode.GetTreeNodePos

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\IndexOfNextVisualisedChild
//************************************* TN_VNode.IndexOfNextVisualisedChild ***
// Search next Visual child Node according to TreeView child Nodes order
//
//     Parameters
// ASInd  - start child VNode index
// ADE    - resulting IDB directory entry for corresponding IDB object
// ADir   - search direction (if >= 0 then forward search else backward search)
// Result - Returns index of next VNode
//
function TN_VNode.IndexOfNextVisualisedChild( ASInd : Integer; var ADE : TN_DirEntryPar;
                                              ADir : Integer = 1 ) : Integer;
var Fin, i : Integer;
begin

//*** search loop prepear
  if ADir >= 0 then
  begin
    Fin := VNUDObj.DirLength;
    ADir := 1;
  end else
  begin
    Fin := -1;
    ADir := -1;
  end;

  Result := -1;
  i := ASInd;
  while i <> Fin do
  begin
      VNUDObj.GetDirEntry( i, ADE );
      if (ADE.Child <> nil) and
         ((K_GetDEVFlags(ADE, VNVTree.VTFlags, VNVTree.VTFlagsNum) and K_fvUseMask) <> K_fvSkipDE) and
         ( not Assigned(VNVTree.VTTestDEFunc) or VNVTree.VTTestDEFunc(ADE)) then
//         ( Assigned(VTree.FFilter) and VTree.FFilter.Test(DE)) then
      begin
        Result := i;
        break;
      end;
    i := i + ADir;
  end;
end; // end of function TN_VNode.IndexOfNextVisualisedChild

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\Mark
//*********************************************************** TN_VNode.Mark ***
// Mark Visual Node
//
// Mark self - set VNode Marked flag and add to Marked VNodes List
//
procedure TN_VNode.Mark();
begin
  if not (K_fVNodeStateMarked in VNState) then // Self is not marked
  begin
    VNVTree.MarkedVNodesList.Add( Self );
    VNState := VNState + [K_fVNodeStateMarked];
    with  VNVTree do
      if not InsideOnVNodeChangeStateFunc and Assigned(OnVNodeChangeStateFunc) then begin
        InsideOnVNodeChangeStateFunc := true;
        OnVNodeChangeStateFunc( Self, [K_ssfMarked] );
        InsideOnVNodeChangeStateFunc := false;
      end;
  end;
end; // end of procedure TN_VNode.Mark

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\UnMark
//********************************************************* TN_VNode.UnMark ***
// Unmark Visual Node
//
// Unmark self - clear Marked flag and remove from Marked VNodes List
//
procedure TN_VNode.UnMark();
begin
  if Self = nil then Exit;
  if K_fVNodeStateMarked in VNState then // Self is marked
  begin
    VNVTree.MarkedVNodesList.Remove( Self );
    VNState := VNState - [K_fVNodeStateMarked];
    with VNVTree do
      if not InsideOnVNodeChangeStateFunc and
         Assigned(OnVNodeChangeStateFunc) then begin
        InsideOnVNodeChangeStateFunc := true;
        OnVNodeChangeStateFunc( Self, [] );
        InsideOnVNodeChangeStateFunc := false;
      end;
  end;
end; // end of procedure TN_VNode.UnMark


//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\Toggle
//********************************************************* TN_VNode.Toggle ***
// Toggle Visual Node given state flags
//
//     Parameters
// AToggleMode - toggle Visual Node state:
//#F
//   0 - toggle state flags
//   1 - set state flags
//  -1 - clear state flags
//#/F
// AStateFlags - given Visual Node state flags for toggling
//
procedure TN_VNode.Toggle( AMode : Integer = 0;
                           AStateFlags : TK_VNodeStateFlags = [K_fVNodeStateMarked] );
var
  ClearMode : Boolean;
begin
  if K_fVNodeStateMarked in AStateFlags then
  begin
    ClearMode := ((AMode = 0) and (K_fVNodeStateMarked in VNState)) or (AMode = -1);
    if ClearMode then
      UnMark() // Self was marked
    else
      Mark();  // Self was not marked
  end;

  if K_fVNodeStateSelected in AStateFlags then
  begin
    ClearMode := ((AMode = 0) and (K_fVNodeStateSelected in VNState)) or (AMode = -1);
    if not (K_fVNodeStateSelected in VNState) and not ClearMode then
      VNVTree.SetSelectedVNode( Self )
    else if (K_fVNodeStateSelected in VNState) and ClearMode then
      VNVTree.SetSelectedVNode( nil );
  end
  else if K_fVNodeStateCurrent in AStateFlags then
  begin
    ClearMode := ((AMode = 0) and (K_fVNodeStateCurrent in VNState)) or (AMode = -1);
    if not (K_fVNodeStateCurrent in VNState) and not ClearMode then
      VNVTree.SetCurrentVNode( Self )
    else if (K_fVNodeStateCurrent in VNState) and ClearMode then
      VNVTree.SetCurrentVNode( nil );
  end;

  if K_fVNodeStateSpecMark0 in AStateFlags then
  begin
    ClearMode := ((AMode = 0) and (K_fVNodeStateSpecMark0 in VNState)) or (AMode = -1);
    if ClearMode then
      VNState := VNState - [K_fVNodeStateSpecMark0] // Clear flags
    else
      VNState := VNState + [K_fVNodeStateSpecMark0];     // Set flags
  end;

  if K_fVNodeStateSpecMark1 in AStateFlags then begin
    ClearMode := ((AMode = 0) and (K_fVNodeStateSpecMark1 in VNState)) or (AMode = -1);
    if ClearMode then
      VNState := VNState - [K_fVNodeStateSpecMark1] // Clear flags
    else
      VNState := VNState + [K_fVNodeStateSpecMark1];// Set flags
  end;
end; // end of procedure TN_VNode.Toggle

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\GetDirIndex
//**************************************************** TN_VNode.GetDirIndex ***
// Get coresponding IDB object index in parent object directory
//
//     Parameters
// Result - Returns directory index of corresponding IDB object
//
function TN_VNode.GetDirIndex : Integer;
begin
  with GetParentUObj do
    Result := IndexOfDEField( VNCode, K_DEFisVCode );
end; // end of function TN_VNode.GetDirIndex

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\GetDirEntry
//**************************************************** TN_VNode.GetDirEntry ***
// Get coresponding IDB object direñtory entry parameters
//
//     Parameters
// ADE - resulting directory entry for corresponding IDB object
//
procedure TN_VNode.GetDirEntry ( var ADE : TN_DirEntryPar );
begin
  with GetParentUObj do
    GetDirEntry( IndexOfDEField( VNCode, K_DEFisVCode ), ADE );
end; // end of function TN_VNode.GetDirEntry

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\GetParentUObj
//************************************************** TN_VNode.GetParentUObj ***
// Get Parent TN_UDBase object
//
//     Parameters
// Result - returns parent object for corresponding IDB object
//
function TN_VNode.GetParentUObj : TN_UDBase;
begin
  if VNParent <> nil then
    Result := VNParent.VNUDObj
  else
    Result := nil;
end; // end of function TN_VNode.GetParentUObj

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\GetVParent
//***************************************************** TN_VNode.GetVParent ***
// Get parent Visual Node
//
//     Parameters
// Result - returns parent Visual Node
//
function TN_VNode.GetVParent : TN_VNode;
begin
  Result := VNParent
end; // end of function TN_VNode.GetVParent

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\UpdateTreeNodeCaption
//****************************************** TN_VNode.UpdateTreeNodeCaption ***
// Update TreeNode Text field (TTreeNode.Text) using IDB object attributes 
// (ObjName, ObjAliase etc.)
//
procedure TN_VNode.UpdateTreeNodeCaption;
var
  wname : string;
  DE : TN_DirEntryPar;
  strCode0 : string;
  placeCode : Boolean;

begin
  if VNTreeNode = nil then Exit;
  GetDirEntry( DE );
  wname := '';
  if (DE.DEName <> '') and
     ((VNVFlags and K_fvTreeViewSkipDEName) = 0 ) then
    wname := DE.DEName + ': ';

  if DE.DECode <> 0 then
    strCode0 := ' Code='+IntToStr(DE.DECode)
  else
    strCode0 := '';
  placeCode := true;

  if (VNVFlags and K_fvTreeViewSkipSeparators) = 0 then begin
{
    if DE.Child.Owner = DE.Parent then
      wname := wname + '-';
    wname := wname + '>';
    if DE.Child.RefCounter > VTree.ShowRefCounterValue then
      wname := wname + '>';
}
{
    if DE.Child.Owner = DE.Parent then begin
      if DE.Child.RefCounter > VTree.ShowRefCounterValue then
        wname := wname + '>';
    end;
}
  end;
  if ((VNVFlags and K_fvTreeViewSkipCaption) = 0 ) then begin
    if (DE.Child.ObjAliase <> '') and
       ((VNVFlags and K_fvTreeViewObjNameAndAliase) = 0) then begin
      wname := wname + DE.Child.ObjAliase;
    end else begin
      wname := wname + DE.Child.ObjName;
      if DE.Child.ObjAliase <> '' then
        wname := wname + '-> '+DE.Child.ObjAliase;
    end;
  end;

  if (VNVTree.VTCaptMaxLength > 0) and
     (Length(wname) > VNVTree.VTCaptMaxLength) then
    wname := Copy( wname, 1, VNVTree.VTCaptMaxLength ) + ' ...';
  if ((VNVFlags and K_fvTreeViewObjDate) <> 0 ) then
    wname := wname + ' {'+K_DateTimeToStr(DE.Child.ObjDateTime)+'}';

  if placeCode then wname := wname + StrCode0;

  VNTreeNode.Text := wname;
//  VNUDObjRC := VNUDObj.RefCounter;

end; // end of procedure TN_VNode.UpdateTreeNodeName

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\GetChildVNode
//************************************************** TN_VNode.GetChildVNode ***
// Search child Visual Node corresponding to given IBD object
//
//     Parameters
// AChild - IDB object corresponding to resulting VNode
// AVCode - visual code (child VNode uniq code, always >=1), if =0 then VCode 
//          doesn't use for proper VNode search
// Result - Returns corresponding VNode or nil if no proper VNode found
//
function TN_VNode.GetChildVNode( AChild : TN_UDBase; AVCode : LongWord ): TN_VNode;
var
WVNode : TN_VNode;
begin
  Result := nil;
  WVNode := AChild.LastVNode;
  while WVNode <> nil do begin
    if (WVNode.VNVTree = VNVTree)   and
       (WVNode.VNParent = self) and
       ((AVCode = 0) or (WVNode.VNCode = AVCode)) then  begin
      Result := WVNode;
      Exit;
    end;
    WVNode := WVNode.PrevVNUDObjVNode;
  end;
end; // end of function TN_VNode.GetChildVNode

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\RebuildVNSubTree
//*********************************************** TN_VNode.RebuildVNSubTree ***
// Rebuild VNode visual Subtree
//
procedure TN_VNode.RebuildVNSubTree;
var
  FParent : TN_VNode;
  FVCode : Integer;
begin
  if VNParent = nil then // root VNode
    VNVTree.Delete( [K_fNTPRebuildVTree] )
  else begin           // not root VNode
    VNVTree.ChangeTreeViewUpdateMode( true );
// save Parent and DE.VCode value because VNode will be destroyed
    FParent := VNParent;
    FVCode := VNCode;
    Self.Delete;
    FParent.CreateChildVNodes( FParent.VNUDObj.IndexOfDEField( FVCode, K_DEFisVCode ) );
    FParent.VNVTree.ChangeTreeViewUpdateMode( false );
  end;
end; // end of procedure TN_VNode.RebuildVNSubTree

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\ReorderChildTreeNodes
//****************************************** TN_VNode.ReorderChildTreeNodes ***
// Reorder child Treeview Nodes (TreeNodes)
//
//     Parameters
// AVFlags - order flags (separate bits control child TreeNodes order):
//#F
//  K_fvDirDescendingSorted      = $0008;
//  K_fvDirSortedMask            = $0007;
//  K_fvDirUnsorted              = $0000;
//  K_fvDirSortedByObjName       = $0001;
//  K_fvDirSortedByObjType       = $0002;
//  K_fvDirSortedByObjDate       = $0003;
//  K_fvDirSortedByDEName        = $0004;
//  K_fvDirSortedByDECode        = $0005;
//#/F
//
procedure TN_VNode.ReorderChildTreeNodes( AVFlags : Integer );
var
  wasNotMoved : boolean;
  TNode, NextNode : TTreeNode;
  i : Integer;
  moveMode : TNodeAttachMode;
  WVNode : TN_VNode;
//**Childs : TN_UDArray;
//**VCodes : TN_IArray;
  WDE1, WDE2 : TN_DirEntryPar;
begin
  VNVFlags := AVFlags and K_fvUseMask;
  repeat
    wasNotMoved := true;
    if VNParent = nil then
      NextNode := VNVTree.TreeView.Items.GetFirstNode
    else
      NextNode := VNTreeNode.GetFirstChild;
    if (VNVFlags and K_fvDirSortedMask) = K_fvDirUnsorted then
    begin    //*** unsorted
      i := VNUDObj.DirHigh;
      moveMode := naAdd;
      repeat
        i := IndexOfNextVisualisedChild( i, WDE1, -1 );
        if i = -1 then break;       // sorting is finished
//        assert( Childs[i] <> nil, 'Wrong Entry Data - Child Reference = nil' );
//**!!??        WVNode := GetChildVNode( VNUDObj.DirChild(i, VNUDObj), VCodes[i] );
        WVNode := GetChildVNode( WDE1.Child, WDE1.VCode );
        if WVNode <> nil then
        begin
          TNode := WVNode.VNTreeNode;
          if TNode = NextNode then NextNode := NextNode.GetNextSibling;
          if TNode = nil then break; // sorting is finished - single child case
          TNode.MoveTo( NextNode, moveMode );
          NextNode := TNode;
          moveMode := naInsert;
        end;
        Dec(i);
      until false;
    end else //*** sorted
      repeat
        TNode := NextNode;
        NextNode := TNode.GetNextSibling;
        if NextNode = nil then break;
        TN_VNode(TNode.Data).GetDirEntry( WDE1 );
        TN_VNode(NextNode.Data).GetDirEntry( WDE2 );
        if K_CompareDirEntries( WDE1, WDE2, VNVFlags ) then
        begin
          NextNode.MoveTo( TNode, naInsert );
          NextNode := TNode;
          wasNotMoved := false;
        end;
      until false;
  until wasNotMoved;
end; // end of procedure TN_VNode.ReorderChildTreeNodes

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VNode\GetSelfVTreePath
//*********************************************** TN_VNode.GetSelfVTreePath ***
// Get Visual Node self relative IDB path from VTree root
//
//     Parameters
// AObjNameType - path segments name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns VNode relative IDB path string from IDB object 
//                corresponding to VTree root VNode to IDB object corresponding 
//                to given VNode
//
function TN_VNode.GetSelfVTreePath( AObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
//var
//  DE : TN_DirEntryPar;
//  CVParent : TN_VNode;
begin
  Result := VNVTree.GetPathToVNode( Self, AObjNameType ) + K_udpPathDelim;
{
  CVParent := self;
  Result := '';
  repeat
    CVParent.GetDirEntry( DE );
    Result := K_BuildPathSegmentByDE( DE, AObjNameType ) + K_udpPathDelim + Result;
    CVParent := CVParent.VNParent;
  until CVParent.VNParent = nil;
}
end; // end_of procedure TN_VNode.GetSelfVTreePath

//*************************************** TN_VNode.SaveToStrings ***
// save text representation of self to TStrings obj
//
procedure TN_VNode.SaveToStrings( Strings: TStrings; Mode: integer );
var DE : TN_DirEntryPar;
begin
  if Mode = 0 then
  begin
    GetDirEntry( DE );
    Strings.Add( '********** Entry Control Data' );
    Strings.Add( Format ( 'VFlags= $%.4x $%.4x', [ DE.DEVFlags[0], DE.DEVFlags[1] ] ) );
//**Flags    Strings.Add( Format ( 'UFlags= $%.4x $%.4x', [ DE.DEUFlags[0], DE.DEUFlags[1] ] ) );
//    Strings.Add( Format ( 'UFlags= $%.8x', [ DE.DEUFlags[0] ] ) );
    Strings.Add( Format ( 'Flags= $%.8x   Name= "%s"', [ DE.DEFlags, DE.DEName  ] ) );
  end;
  DE.Child.SaveToStrings( Strings, Mode );
end; // end_of procedure TN_VNode.SaveToStrings

//********** end of TN_VNode class methods  **************

//********** TN_VTree class methods  **************

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\Create
//********************************************************* TN_VTree.Create ***
// Visual Tree Class constructor
//
//     Parameters
// ATreeView   - TreeView object for Visual Tree show
// ARootUObj   - root IDB object sets IDB Subnet for visualization
// AViewFlags  - view flags control future VNodes and corresponding TreeNodes 
//               creation and view
// AVTDepth    - Visual Tree depth (if =0 then no depth control done)
// AVFlagsNum  - index of IDB object individual view flags set (0 or 1)
// ATestDEFunc - function of object for checking IDB directory entry before 
//               including to Visual Tree
//
constructor TN_VTree.Create( ATreeView: TTreeView; ARootUObj: TN_UDBase;
                                        AViewFlags : integer = 0;
                                        AVTDepth     : integer = 0;
                                        AVFlagsNum   : integer = 0;
                                        ATestDEFunc  : TK_TestDEFunc = nil );
var
  VTreeInd: integer;
begin
  VTreeInd := N_VTrees.IndexOf( nil );
  if VTreeInd = -1 then
    N_VTrees.Add( self )
  else
    N_VTrees[VTreeInd] := self;

  TreeViewUpdateCount := 0;

  RootUObj   := ARootUObj;
  VTFlags    := AViewFlags;
  VTDepth    := AVTDepth;
  VTFlagsNum := AVFlagsNum;
  VTTestDEFunc := ATestDEFunc;
  TreeView := ATreeView;
  TreeView.ReadOnly := (VTFlags and K_fvTreeViewTextEdit) = 0;
  MarkedVNodesList := TList.Create;
  CheckedUobjsList := TList.Create;
  if RootUObj <> nil then
    CreateVNodes;
end; // end of constructor TN_VTree.Create

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\Delete
//********************************************************* TN_VTree.Delete ***
// Delete Visual Tree
//
//     Parameters
// ADFlags - delete mode
//
procedure TN_VTree.Delete( ADFlags: TK_VTreeVNodeDelFlags = [] );
var
  NewDFlags: TK_VTreeVNodeDelFlags;
begin
  if Self = nil then Exit;
{ //*** All tre nodes will be delete during VNode Tree deleting
  // because TreeView.Free does not raise OnDeletion event,
  // delete all root Nodes manualy
  if TreeView <> nil then //???
  begin
    if TreeView.Items <> nil then //???
    begin
      TreeView.Items.Clear;
    end;
  end;
}
//  NewDFlags := DFlags or K_fNTPDelVTree1;
//  if (RootVNode <> nil) and ((DFlags and K_fNTPDelVNode) = 0) then
  NewDFlags := ADFlags + [K_fNTPDelVTree1];
  if (RootVNode <> nil) and  not (K_fNTPDelVNode in ADFlags) then
  begin
    if TreeView <> nil then
    begin
      TreeView.Items.BeginUpdate;
      TreeView.Items.Clear;
    end;
//**    TreeViewUpdateMode(true);
    RootVNode.Delete( NewDFlags );
//**    TreeViewUpdateMode(false);
    if TreeView <> nil then
      TreeView.Items.EndUpdate;
  end;

//  if (DFlags and K_fNTPRebuildVTree) = 0 then
  if not (K_fNTPRebuildVTree in ADFlags) then
  begin // delete Vtree
//*** clear VTree place in N_VTrees
    MarkedVNodesList.Free;
    CheckedUobjsList.Free;
    if N_VTrees <> nil then // Because of Errors during form desruction after FinGlobals was done
      N_VTrees[N_VTrees.IndexOf( self)] := nil;
//*** mark VTreeFrame VTree as deleted
    if (TreeView <> nil) and //????
       (TreeView.Parent is TN_VTreeFrame) then
      TN_VTreeFrame(TreeView.Parent).VTree := nil;
    if TreeViewUpdateCount <> 0 then TreeView.Items.EndUpdate;
    Free;
  end else // only rebuild view
    CreateVNodes;

end; // end of procedure TN_VTree.Delete

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\CreateVNodes
//*************************************************** TN_VTree.CreateVNodes ***
// Create Visual Tree VNodes
//
procedure TN_VTree.CreateVNodes;
var
  TNode : TTreeNode;
  ADE : TN_DirEntryPar;
begin
  MarkedVNodesList.Clear;
  Selected := nil;
//Selected := N_EmptySelected;
  TNode := nil;
  K_ClearDirEntry( ADE );
  ADE.Child := RootUObj;
  ChangeTreeViewUpdateMode( true );
  if TreeView <> nil then
    TreeView.Items.Clear;

  RootVNode := TN_VNode.Create( Self, nil, ADE, TNode, K_tnmNodeAddNone, 0 );
  ChangeTreeViewUpdateMode( false );
end; // end of procedure TN_VTree.CreateVNodes

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\UnMarkAllVNodes
//************************************************ TN_VTree.UnMarkAllVNodes ***
// Unmark all marked VNodes
//
procedure TN_VTree.UnMarkAllVNodes();
begin
  while MarkedVNodesList.Count > 0 do
    TN_VNode(MarkedVNodesList.Items[0]).UnMark;
end; // end of procedure TN_VTree.UnMarkAllVNodes

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\SetSelectedVNode
//*********************************************** TN_VTree.SetSelectedVNode ***
// Set new selected Visual Node
//
//     Parameters
// AVNode - new selected Visual Node
//
procedure TN_VTree.SetSelectedVNode( AVNode: TN_VNode );
var
  ChangedStateFlags : TK_SetObjStateFlags;
begin
  if Selected <> nil then
    Selected.VNState := Selected.VNState - [K_fVNodeStateSelected,K_fVNodeStateCurrent]; // (clear bit1)
  Selected := AVNode;                    // new selected VNode;
  Current  := AVNode;                    // new current VNode;
  if AVNode <> nil then begin
    AVNode.VNState := AVNode.VNState + [K_fVNodeStateSelected,K_fVNodeStateCurrent]; // set "selected" flag (set bit1)
    if AVNode.VNTreeNode <> nil then
      AVNode.VNTreeNode.MakeVisible();
  end;
  if not InsideOnVNodeChangeStateFunc and
     Assigned(OnVNodeChangeStateFunc) then
  begin
    ChangedStateFlags := [K_ssfSelected];
    if (Selected <> nil) and (K_fVNodeStateMarked in Selected.VNState) then
      ChangedStateFlags := ChangedStateFlags + [K_ssfMarked];
    InsideOnVNodeChangeStateFunc := true;
    OnVNodeChangeStateFunc( Selected, ChangedStateFlags );
    InsideOnVNodeChangeStateFunc := false;
  end;
end; // end of procedure TN_VTree.SetSelectedVNode

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\SetCurrentVNode
//************************************************ TN_VTree.SetCurrentVNode ***
// Set new current Visual Node
//
//     Parameters
// AVNode - new current Visual Node
//
procedure TN_VTree.SetCurrentVNode( AVNode: TN_VNode );
var
  ChangedStateFlags : TK_SetObjStateFlags;
begin
  if AVNode = Current then Exit;
  if Current <> nil then
    Current.VNState := Current.VNState - [K_fVNodeStateCurrent]; // (clear bit1)
  if AVNode <> nil then //***
    AVNode.VNState := AVNode.VNState + [K_fVNodeStateCurrent]; // set "Current" flag (set bit1)
  Current := AVNode;                    // new selected VNode;
  if not InsideOnVNodeChangeStateFunc and
     Assigned(OnVNodeChangeStateFunc) then begin
    ChangedStateFlags := [K_ssfCurrent];
    if (Current <> nil) then
    begin
      if (K_fVNodeStateMarked in Current.VNState) then
        ChangedStateFlags := ChangedStateFlags + [K_ssfMarked];
      if (K_fVNodeStateSelected in Current.VNState) then
        ChangedStateFlags := ChangedStateFlags + [K_ssfSelected];
    end;
    InsideOnVNodeChangeStateFunc := true;
    OnVNodeChangeStateFunc( Current, ChangedStateFlags );
    InsideOnVNodeChangeStateFunc := false;
  end;
end; // end of procedure TN_VTree.SetCurrentVNode

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\ChangeTreeViewUpdateMode
//*************************************** TN_VTree.ChangeTreeViewUpdateMode ***
// Change TreeView udate mode
//
//     Parameters
// ASetUpdateMode    - set update TreeView mode flag, if =FALSE then decrement 
//                     update counter and clear TreeView update mode if cuonter 
//                     = 0
// AUseUpdateCounter - check udate counter while clear update counter mode
//
procedure TN_VTree.ChangeTreeViewUpdateMode( ASetUpdateMode : Boolean;
                                       AUseUpdateCounter : Boolean = false );
begin
  if TreeView = nil then Exit;
  if ASetUpdateMode then begin
    if TreeViewUpdateCount = 0 then
      TreeView.Items.BeginUpdate;
    Inc(TreeViewUpdateCount);
  end else begin
    if TreeViewUpdateCount > 0 then begin
      Dec(TreeViewUpdateCount);
      if TreeViewUpdateCount = 0 then begin
        TreeView.Items.EndUpdate;
      end;
      if AUseUpdateCounter and (TreeViewUpdateCount > 0) then begin
        K_ShowMessage( 'Wrong TreeView update counter '+IntToStr(TreeViewUpdateCount) );
        assert(false);
      end;
    end;
  end;
end; // end of procedure TN_VTree.TreeViewUpdateMode

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\GetVNodeByPath
//************************************************* TN_VTree.GetVNodeByPath ***
// Get Visual Node using relative path
//
//     Parameters
// AVNode       - resulting Visual Node
// APath        - relative path to corresponding IDB object
// AObjNameType - path segments name type (ObjName,ObjAliase etc.) enumeration
// ARootVNode   - Visual Node corresponding to root IDB object for given 
//                relative IDB path (if ARootVNode = nil then Visual Tree root 
//                is used)
// Result       - Returns path parsing position
//
// Absent VNodes (and corresponding TreeNodes) are created.
//
function TN_VTree.GetVNodeByPath( out AVNode : TN_VNode; const APath : string = '';
                                  AObjNameType : TK_UDObjNameType = K_ontObjName;
                                  ARootVNode : TN_VNode = nil ) : Integer;
var
  WDE : TN_DirEntryPar;
  AContinue : Boolean;
  WVNode : TN_VNode;
  LRootUobj : TN_UDBase;
begin
  AContinue := false;
  WDE.Child := nil;
  Result := 0;
  if ARootVNode = nil then begin
    LRootUobj := RootUobj;
    WVNode := nil;
  end else begin
    WVNode := ARootVNode;
    LRootUobj := WVNode.VNUDObj;
  end;
  ChangeTreeViewUpdateMode( true );
  if APath <> '' then begin
    while true do begin
      Result := LRootUobj.GetDEByRPath( APath, WDE, AObjNameType, 1, AContinue );
      if Result <= 1 then break;
      if WDE.Child = nil then begin
        WVNode := nil;
        break;
      end;

      if Assigned(WVNode) then begin
        WVNode.VNTreeNode.Expanded := true;
      end else
        WVNode := RootVNode;

      WVNode := WVNode.GetChildVNode( WDE.Child, 0 );

      if not Assigned(WVNode) or
         not Assigned(WVNode.VNTreeNode) then begin
        WVNode := nil;
        break;
      end;
      AContinue := true;
    end;
  end;
  AVNode := WVNode;
  ChangeTreeViewUpdateMode( false );
  TreeView.Invalidate;
end; // end of function TN_VTree.GetVNodeByPath

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\SetPath0
//******************************************************* TN_VTree.SetPath0 ***
// Expand VTree Nodes using given path
//
//     Parameters
// AVNode       - resulting Visual Node
// APath        - relative path to corresponding IDB object
// AExpandLast  - expand path terminating node flag
// AMarkLast    - mark path terminating node flag
// ASelectLast  - set selectaed path terminating node flag
// AObjNameType - path segments name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns path parsing position
//
function TN_VTree.SetPath0( out AVNode : TN_VNode; const APath : string;
                            AExpandLast, AMarkLast, ASelectLast : Boolean;
                            AObjNameType : TK_UDObjNameType ) : Integer;
var
  WVNode : TN_VNode;
begin
  Result := GetVNodeByPath( WVNode, APath, AObjNameType );
  if Assigned(WVNode) then begin
    if AExpandLast or
       (Result < 0) then begin
      WVNode.VNTreeNode.Expanded := true;
    end;
    if AMarkLast then WVNode.Mark;
    if ASelectLast then SetSelectedVNode(WVNode);
  end;
  AVNode := WVNode;
end; // end of function TN_VTree.SetPath0

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\SetPath
//******************************************************** TN_VTree.SetPath ***
// Expand VTree Nodes using given path
//
//     Parameters
// APath        - relative path to corresponding IDB object
// AExpandLast  - expand path terminating node flag
// AMarkLast    - mark path terminating node flag
// ASelectLast  - set selectaed path terminating node flag
// AObjNameType - path segments name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns path parsing position
//
function TN_VTree.SetPath( const APath : string = ''; AExpandLast : Boolean = false;
            AMarkLast : Boolean = true; ASelectLast : Boolean = true;
            AObjNameType : TK_UDObjNameType = K_ontObjName ) : Integer;
var
  VNode : TN_VNode;
begin
  UnMarkAllVNodes;
  Result := SetPath0( VNode, APath, AExpandLast, AMarkLast, ASelectLast, AObjNameType );
  TreeView.Invalidate;
end; // end of function TN_VTree.SetPath

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\GetPathToVNode
//************************************************* TN_VTree.GetPathToVNode ***
// Get path to given Visual Node
//
//     Parameters
// AVNode       - given Visual Node
// AObjNameType - path segments name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns relative path from IDB object corresponding to VTree 
//                root to IDB object corresponding to given VNode
//
function TN_VTree.GetPathToVNode( AVNode : TN_VNode;
            AObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
var
  DE : TN_DirEntryPar;
  PathList : TStringList;
//  i : Integer;
begin
  Result := '';
  if (AVNode = nil) or (AVNode.VNVTree <> Self) then Exit;
//  Result := ExcludeTrailingPathDelimiter( AVNode.GetSelfVTreePath( AObjNameType ) );

  PathList := TStringList.Create;
  while AVNode.VNParent <> nil do begin
    AVNode.GetDirEntry ( DE );
    PathList.Insert(0, K_BuildPathSegmentByDE( DE, AObjNameType ) );
    AVNode := AVNode.VNParent;
  end;
//  Result := PathList[0];
//  for i := 1 to PathList.Count - 1 do
//    Result := Result + K_udpPathDelim + PathList[i];
  PathList.Delimiter := K_udpPathDelim;
  Result := PathList.DelimitedText;
  PathList.Free;

end; // end of function TN_VTree.GetPathToVNode

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\GetCurState
//**************************************************** TN_VTree.GetCurState ***
// Get Visual Tree current state
//
//     Parameters
// AMarkedPathList   - list of paths to marked VNodes
// AExpandedPathList - list of paths to expanded VNodes
// Result            - Return global (from Application main root object) path to
//                     VTree root IDB object
//
function TN_VTree.GetCurState( AMarkedPathList, AExpandedPathList : TStrings ) : string;
begin
  GetMarkedPathStrings( AMarkedPathList );
  GetExpandedPathStrings( AExpandedPathList );
//  Result := RootUObj.GetOwnersPath( K_MainRootObj );
  Result := K_GetPathToUObj( RootUObj, K_MainRootObj );
end; //***** end of function TN_VTree.GetCurState

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\RebuildView
//**************************************************** TN_VTree.RebuildView ***
// Rebuild Visual Tree state
//
//     Parameters
// ARootUObj         - new VTree root IDB Object
// AMarkedPathList   - list of paths to marked VNodes
// AExpandedPathList - list of paths to expanded VNodes
// Result            - Returns resulting selected VNode, if no selected returns 
//                     nil.
//
function TN_VTree.RebuildView( ARootUObj : TN_UDBase;
                    AMarkedPathList, AExpandedPathList : TStrings ) : TN_VNode;
begin
  RootUObj := ARootUObj;
  Delete([K_fNTPRebuildVTree]);
  Result := nil;
  if AExpandedPathList <> nil then
    Result := SetPathStrings( AExpandedPathList, true );
  if AMarkedPathList <> nil then
    SetPathStrings( AMarkedPathList, false );
  TreeView.ReadOnly := (VTFlags and K_fvTreeViewTextEdit) = 0;
end; //***** end of function TN_VTree.RebuildView

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\SetCurState
//**************************************************** TN_VTree.SetCurState ***
// Set Visual Tree state
//
//     Parameters
// ARootPath         - global IDB path to new VTree root IDB Object
// AMarkedPathList   - list of paths to marked VNodes
// AExpandedPathList - list of paths to expanded VNodes
// ADefaultRoot      - default new VTree root IDB Object (use if root path is 
//                     not given or is wrong)
// Result            - Returns resulting selected VNode, if no selected returns 
//                     nil.
//
function TN_VTree.SetCurState( const ARootPath : string;
                               AMarkedPathList, AExpandedPathList : TStrings;
                               ADefaultRoot : TN_UDBase = nil ) : TN_VNode;
var
  RootNode : TN_UDBase;
begin
  RootNode := K_MainRootObj.GetObjByRPath(ARootPath);
  if (RootNode = nil) or (ARootPath = '') then
  begin
    RootNode := ADefaultRoot;
    if RootNode = nil then
      RootNode := K_MainRootObj;
  end;
  Result := RebuildView( RootNode, AMarkedPathList, AExpandedPathList );
end; //***** end of function TN_VTree.SetCurState

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\GetMarkedPathStrings
//******************************************* TN_VTree.GetMarkedPathStrings ***
// Get paths to marked Visual Nodes
//
//     Parameters
// APList       - in output list of paths to marked VNodes and marked VNodes
// AObjNameType - path segments name type (ObjName,ObjAliase etc.) enumeration
//
// Selected VNode is always last in the resulting list. If no selected VNode, 
// then last list element string is empty and list object is nil.
//
procedure TN_VTree.GetMarkedPathStrings( APList : TStrings;
            AObjNameType : TK_UDObjNameType = K_ontObjName );
var
  WVNode : TN_VNode;
  i : Integer;
begin
  APList.Clear;
  for i := 0 to MarkedVNodesList.Count - 1 do begin
    WVNode := TN_VNode(MarkedVNodesList[i]);
    APList.AddObject( GetPathToVNode( WVNode, AObjNameType ), WVNode );
  end;
  if Selected <> nil then // Save Selected
    APList.AddObject( GetPathToVNode( Selected, AObjNameType ), Selected )
  else
    APList.AddObject( '', nil );
end; // end of procedure TN_VTree.GetMarkedPathStrings

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\GetExpandedPathStrings
//***************************************** TN_VTree.GetExpandedPathStrings ***
// Get paths to expanded Visual Nodes
//
//     Parameters
// APList       - in output list of paths to expanded VNodes and expanded VNodes
// AObjNameType - path segments name type (ObjName,ObjAliase etc.) enumeration
//
// Top item VNode is always last in the resulting list. If no top item, then 
// last list element string is empty and list object is nil.
//
procedure TN_VTree.GetExpandedPathStrings( APList : TStrings;
            AObjNameType : TK_UDObjNameType = K_ontObjName );
var
  WVNode : TN_VNode;
  i, h : Integer;
  VNL : TList;
  TopNode : TTreeNode;

  procedure BuildVNodesList( RootTN : TTreeNode  );
  var
    ExpandedCount : Integer;
    ChildTN : TTreeNode;
  begin
    if not RootTN.Expanded then Exit;
    ExpandedCount := 0;
    ChildTN := RootTN.getFirstChild;
    while ChildTN <> nil do
    begin
      if ChildTN.Expanded then
      begin
        BuildVNodesList( ChildTN );
        Inc(ExpandedCount);
      end;
      ChildTN := RootTN.GetNextChild( ChildTN );
    end;
    if ExpandedCount = 0 then VNL.Add( RootTN.Data );
  end;

begin
  VNL := TList.Create;
  h := RootUObj.DirHigh;
  for i := 0 to h do begin
    WVNode := RootVNode.GetChildVNode( RootUObj.DirChild(i), 0 );
    if WVNode <> nil then BuildVNodesList( WVNode.VNTreeNode );
  end;
  APList.Clear;
  for i := 0 to VNL.Count - 1 do
    APList.AddObject( GetPathToVNode( TN_VNode(VNL[i]), AObjNameType ), VNL[i] );
  VNL.Free;
  TopNode := TreeView.TopItem;
  if Assigned(TopNode) then
    APList.AddObject( GetPathToVNode( TN_VNode(TopNode.Data), AObjNameType ), TopNode.Data )
  else
    APList.AddObject( '', nil );
end; // end of procedure TN_VTree.GetExpandedPathStrings

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\SetPathStrings
//************************************************* TN_VTree.SetPathStrings ***
// Set Visual Nodes paths list to change VTree state
//
//     Parameters
// APList            - list of paths to expanded or marked VNodes
// AExpandedListFlag - if TRUE then APList is list of paths to expanded VNodes 
//                     else to marked VNodes
// AObjNameType      - path segments type (ObjName,ObjAliase etc.)
// Result            - Returns resulting selected VNode, if no selected returns 
//                     nil.
//
function TN_VTree.SetPathStrings( APList : TStrings;
            AExpandedListFlag : Boolean;
            AObjNameType : TK_UDObjNameType = K_ontObjName  ) : TN_VNode;
var
  i, h : Integer;
  ExpandLast, MarkLast : Boolean;
begin
  h := APList.Count - 2;
  ExpandLast := AExpandedListFlag;
  MarkLast   := not AExpandedListFlag;
  Result := nil;
  if MarkLast then
    UnMarkAllVNodes;
  for i := 0 to h do
  begin
    SetPath0( Result, APList[i], ExpandLast, MarkLast, false, AObjNameType );
    APList.Objects[i] := Result;
  end;
  if (h >= -1) and ( APList[h + 1] <> '' ) then
  begin
    GetVNodeByPath( Result, APList[h + 1], AObjNameType );
    APList.Objects[h + 1] := Result;
    if Assigned( Result )then
    begin
      if MarkLast then
      begin
        Result.Mark;
        SetSelectedVNode(Result);
      end;
    end;
  end;
  TreeView.Invalidate;
end; // end of procedure TN_VTree.SetPathStrings

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\GetSelectedVNode
//*********************************************** TN_VTree.GetSelectedVNode ***
// Get Visual Tree selected VNode
//
//     Parameters
// Result - Returns resulting selected VNode, if no selected returns nil.
//
function TN_VTree.GetSelectedVNode(  ) : TN_VNode;
begin
  Result := nil;
  if Self = nil then Exit;
  Result := Selected;
  if (Result = nil) or
     (Result.VNUDObj = nil) or
     (Result.VNTreeNode = nil) then
    Result := nil;
end; //*** end of TN_VTree.GetSelectedVNode


//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\MoveSelectedObject
//********************************************* TN_VTree.MoveSelectedObject ***
// Move IDB object corresponding to selected VNode in corresponding parent IDB 
// object directory
//
//     Parameters
// ADir - move direction (1 - change with selected next, -1 change selected with
//        previous)
//
procedure TN_VTree.MoveSelectedObject( ADir: Integer );
// Move selected Node Up/Down
var
  NInd: integer;
  Path: String;
  VNode: TN_VNode;
  CurTopItem: TTreeNode;
  UDSParent: TN_UDBase;
  DE : TN_DirEntryPar;
  MarkedPathList, ExpandedPathList : TStringList;
begin
  VNode := GetSelectedVNode();
  if VNode = nil then Exit;

  MarkedPathList := TStringList.Create;
  ExpandedPathList := TStringList.Create;
  GetCurState( MarkedPathList, ExpandedPathList );

  VNode.GetDirEntry( DE );
  UDSParent := DE.Child.GetSubTreeParent( DE );
  with DE, Parent  do  begin
    K_SetChangeSubTreeFlags( Parent, [K_cstfSetSLSRChangeFlag] );
    NInd := DirIndex + ADir;
    if (NInd < 0) or (NInd > DirHigh) then Exit;
    Path := GetPathToVNode( VNode );
    CurTopItem := TreeView.TopItem;
    with TN_VNode(CurTopItem.Data) do
      if (VNUDObj = Parent) or (Parent.IndexOfDEField(VNUDObj) >= 0) then
        CurTopItem := nil;
    UDSParent.MoveSubTreeChilds( NInd, DirIndex );
    K_TreeViewsUpdateModeSet;
    RebuildVNodes();
    RebuildView( RootUObj, MarkedPathList, ExpandedPathList );
    TreeView.TopItem := CurTopItem;
    K_TreeViewsUpdateModeClear(false);
  end; // with UDRParent, VTree do
  K_SetArchiveChangeFlag;

  MarkedPathList.Free;
  ExpandedPathList.Free;
end; //*** end of procedure TN_VTree.MoveSelectedNode

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\ToggleMarkedNodesPMark
//***************************************** TN_VTree.ToggleMarkedNodesPMark ***
// Toggle IDB objects corresponding to marked VNodes special permanent mark flag
//
procedure TN_VTree.ToggleMarkedNodesPMark;
var
  i : Integer;
begin
//
  if (Self = nil)             or
     (MarkedVNodesList = nil) or
     (MarkedVNodesList.Count = 0) then Exit;
  K_TreeViewsUpdateModeSet;
  with MarkedVNodesList do
    for i := 0 to Count - 1 do begin
      with TN_VNode(MarkedVNodesList[i]).VNUDObj do
        ClassFlags := ClassFlags xor K_PermVizMarkBit;
    end;
  K_TreeViewsUpdateModeClear(false);

end; //*** end of procedure TN_VTree.ToggleMarkedNodesPMark

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\ClearNodesPMark
//************************************************ TN_VTree.ClearNodesPMark ***
// Toggle special permanent mark flag in all IDB objects corresponding VTree
//
procedure TN_VTree.ClearNodesPMark;
begin
  if (Self = nil) or (RootUObj = nil) then Exit;
  K_TreeViewsUpdateModeSet;

  K_UDScannedUObjsList := Tlist.Create;
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];

  RootUObj.ScanSubTree( ClearNodesPMarkScanFunc );

  K_ClearUObjsScannedFlag;
  FreeAndNil( K_UDScannedUObjsList );
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];

  K_TreeViewsUpdateModeClear(false);

end; //*** end of procedure TN_VTree.ClearNodesPMark

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTree\ClearNodesPMarkScanFunc
//**************************************** TN_VTree.ClearNodesPMarkScanFunc ***
// Scanning IBD Object routine
//
// Used for clearing IDB object special permanent mark flag during tree-walk in 
// ClearNodesPMark method
//
function TN_VTree.ClearNodesPMarkScanFunc(UDParent: TN_UDBase;
  var UDChild: TN_UDBase; ChildInd, ChildLevel: Integer;
  const FieldName: string): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  UDChild.ClassFlags := UDChild.ClassFlags and not K_PermVizMarkBit;
end; // end of procedure TN_VTree.ClearNodesPMarkScanFunc

//********** end of TN_VTree class methods  **************


//****************** Global procedures **********************

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_BuildDEArrayFromVNodesList
//******************************************** K_BuildDEArrayFromVNodesList ***
// Build Array of IDB Objects Directory Entry parameters (DEArray) from given 
// list of Visual Nodes
//
//     Parameters
// AVNodesList     - list of IDB Objects Visual Nodes
// AMarkClassFlags - bits for marking IDB objects which are put in resulting 
//                   DEArray and its Parent Objects by their ClassFlags field
// ASkipDuplicate  - if true then skip put IDB Object Directory Entry to 
//                   resulting DEArray if it already contains some Directory 
//                   Entry with the same IDB Object
// Result          - Returns Array of IDB Objects Directory Entry
//
// AMarkClassFlags usually contains bit flags needed to prevent destruction IDB 
// objects which are put to resulting DEArray. The function is used in 
// TK_UDTreeClipboard methods.
//
function K_BuildDEArrayFromVNodesList( AVNodesList : TList; AMarkClassFlags : LongWord;
                                       ASkipDuplicate : Boolean ) : TK_DEArray;
var
  i, j : Integer;
  PChild : PInteger;
begin
  SetLength( Result, AVNodesList.Count );
  PChild := PInteger(@(Result[0].Child));
  j := 0;
  for i := 0 to High(Result) do begin
    TN_VNode(AVNodesList[i]).GetDirEntry( Result[j] );
    with Result[j] do begin
      if not ASkipDuplicate or
        (K_IndexOfIntegerInRArray( Integer(Child), PChild, j - 1, Sizeof(TN_DirEntryPar) ) < 0) then begin
        Child.ClassFlags := Child.ClassFlags or AMarkClassFlags;
        Parent.ClassFlags := Parent.ClassFlags or AMarkClassFlags;
        Inc(j);
      end;
    end;
  end;
  SetLength( Result, j );
end; // end of K_BuildDEArrayFromVNodesList

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_TryToRepairDirIndex
//*************************************************** K_TryToRepairDirIndex ***
// Try to Repair IDB Object DirIndex field in given Directory Entry parameters
//
//     Parameters
// ADE             - Directory Entry parameters
// AMarkClassFlags - bits for searching IDB objects using ClassFlags field
//
// Repairing of IDB Object DirIndex field is needed after insertion/deletion 
// child objects. The function is used in TK_UDTreeClipboard methods.
//
procedure K_TryToRepairDirIndex( var ADE : TN_DirEntryPar; AMarkClassFlags : Integer );
begin
  with ADE do begin
    if Child <> Parent.DirChild(DirIndex) then
      DirIndex := Parent.IndexOfDEField( Child );
    while (DirIndex >= 0) and ((Child.ClassFlags and AMarkClassFlags) = 0) do
      DirIndex := Parent.IndexOfDEField( Child, K_DEFisChild, DirIndex + 1 );
  end;
end; // end of K_TryToRepairDirIndex

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_PrepDEArrayAfterDeletion
//********************************************** K_PrepDEArrayAfterDeletion ***
// Prepare Array of IDB Objects Directory Entry parameters (DEArray) after 
// Deletion
//
//     Parameters
// ADEArray        - Array of IDB Objects Directory Entry parameters
// AMarkClassFlags - bits for searching IDB objects using ClassFlags field
// APrepFlags      - set of flags for contol remove from DEArray elements with 
//                   desproyed parents and etc)
// Result          - Returns number of remained in DEArray after
//
// The function is used in TK_UDTreeClipboard methods.
//
function K_PrepDEArrayAfterDeletion( ADEArray : TK_DEArray; AMarkClassFlags : Integer;
                          APrepFlags : TK_UDTreeClipboardPrepFlags = [] ) : Integer;
var
  i : Integer;
  WCheckDestructMask : Integer;

  procedure ClearChild( var Child : TN_UDBase );
  begin
    Child.ClassFlags := Child.ClassFlags and not AMarkClassFlags;
    Child.RebuildVNodes( -1 );
    Child := nil;
  end;

begin
  Result := 0;
  WCheckDestructMask := AMarkClassFlags xor (K_SkipDestructBit or K_SkipDestructBitD);
  for i := 0 to High( ADEArray ) do
    with ADEArray[i] do begin
      if (Parent <> nil)          and
         (Parent.RefCounter <= 0) and
         ((Parent.ClassFlags and WCheckDestructMask) = 0) then begin
        FreeAndNil( Parent );
        if (Child.RefCounter > 0 ) and
           ( (K_ucpRemoveNodesWithAbsentParents in APrepFlags) or
             (K_ucpRemoveNodesWithWrongDEInd in APrepFlags) ) then
          ClearChild( Child );
      end;
      if (K_ucpRemoveNodesWithWrongDEInd in APrepFlags) and
         (Parent <> nil)                                and
         (Child <> nil)                                 and
         (Child.RefCounter > 0) then begin
        // Try to Repair Dir Index
          K_TryToRepairDirIndex( ADEArray[i], AMarkClassFlags );
          if  DirIndex < 0 then ClearChild( Child );
        end;

      if (Child <> nil)          and
         (Child.RefCounter <= 0) and
         ((Child.ClassFlags and WCheckDestructMask) = 0) then
        FreeAndNil( Child );
      if Child <> nil then Inc(Result);
    end;
end; //end of K_PrepDEArrayAfterDeletion

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_DeleteDEChild
//********************************************************* K_DeleteDEChild ***
// Delete IDB Child Object from the Parent given by Directory Entry parameters
//
//     Parameters
// ADE           - IDB Object Directory Entry parameters
// ADelChildFunc - function of object given for Child Object deletion
// Result        - Returns true if IDB Object was deleted from given IDB place
//
// The function is used in TK_UDTreeClipboard methods.
//
function  K_DeleteDEChild( const ADE : TN_DirEntryPar; ADelChildFunc : TK_UDDelChildFunc = nil ) : Boolean;
begin

  with ADE do begin
    if Assigned(ADelChildFunc) then
      Result := ADelChildFunc( Parent, DirIndex )
    else
      Result := Parent.RemoveDirEntry( DirIndex ) <= K_DRisOK;
    if Result  then K_SetChangeSubTreeFlags( Parent, [K_cstfSetSLSRChangeFlag] );
  end;

end; // end of K_DeleteDEChild

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_DeleteDEArrayChilds
//*************************************************** K_DeleteDEArrayChilds ***
// Delete Childs from IDB Subnet places given by Array of IDB Objects Directory 
// Entry parameters (DEArray)
//
//     Parameters
// ADEArray      - Array of IDB Objects Directory Entry parameters
// ADelChildFunc - function of object given for Child Object deletion
// Result        - Returns number of deleted Objects
//
function K_DeleteDEArrayChilds( ADEArray : TK_DEArray; ADelChildFunc : TK_UDDelChildFunc = nil  ) : Integer;
var
  i : Integer;
  DelChild : Boolean;
begin

  Result := 0;
  for i := 0 to High(ADEArray) do
    with ADEArray[i] do begin
      DelChild := false;
      if (Parent <> nil) and (Parent.RefCounter > 0) and
         (Child <> nil) and (Child.RefCounter > 0) then begin
        if Parent.DirChild( DirIndex ) <> Child then
          DirIndex := Parent.IndexOfDEField( Child );
        if DirIndex >= 0 then
          DelChild := K_DeleteDEChild( ADEArray[i], ADelChildFunc );
      end;
      if not DelChild then Continue;
      Inc(Result);
    end;
end; // end of K_DeleteDEArrayChilds

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ClearDEArrayChildsClassFlags
//****************************************** K_ClearDEArrayChildsClassFlags ***
// Clear Childs Class Flags field for objects given by Array of IDB Objects 
// Directory Entry parameters
//
//     Parameters
// ADEArray        - Array of IDB Objects Directory Entry parameters
// AMarkClassFlags - clear ClassFlags field bits for IDB given by DEArray
//
// The function is used in TK_UDTreeClipboard methods.
//
procedure K_ClearDEArrayChildsClassFlags( ADEArray : TK_DEArray; AMarkClassFlags : LongWord  );
var
  i : Integer;
begin
  AMarkClassFlags := not AMarkClassFlags;
  for i := 0 to High(ADEArray) do
    with ADEArray[i] do begin
      if (Parent <> nil) and (Parent.RefCounter > 0) then
        Parent.ClassFlags := Parent.ClassFlags and AMarkClassFlags;
      if (Child <> nil) and (Child.RefCounter > 0) then begin
        Child.ClassFlags := Child.ClassFlags and AMarkClassFlags;
        Child.RebuildVNodes( -1 );
      end;
      Child := nil;
      Parent := nil;
    end;
end; // end of K_ClearDEArrayChildsClassFlags

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_DeleteUDNodesByVList
//************************************************** K_DeleteUDNodesByVList ***
// Delete IDB objects given by list of Visual Nodes (VNodes)
//
//     Parameters
// AVNodesList   - list of IDB Objects Visual Nodes
// ADelChildFunc - function of object given for Child Object deletion
// Result        - Returns number of deleted Objects
//
function K_DeleteUDNodesByVList( AVNodesList : TList; ADelChildFunc : TK_UDDelChildFunc = nil  ) : Integer;
var
  DEArray : TK_DEArray;
begin
  DEArray := K_BuildDEArrayFromVNodesList( AVNodesList, K_SkipDestructBitD, false );
  Result := -1;
  if Length(DEArray) = 0 then Exit;
  K_TreeViewsUpdateModeSet;
  Result := K_DeleteDEArrayChilds( DEArray, ADelChildFunc );
  K_PrepDEArrayAfterDeletion( DEArray, K_SkipDestructBitD );
  K_ClearDEArrayChildsClassFlags( DEArray, K_SkipDestructBitD );
  K_TreeViewsUpdateModeClear;
  if Result > 0 then
    K_SetArchiveChangeFlag;
end; // end of K_DeleteUDNodesByVList

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_SelectUDNode
//********************************************************** K_SelectUDNode ***
// Brings up a dialog to allow the user to select IDB object from Subnet given 
// by root object
//
//     Parameters
// ASelObj             - selecting objet (on input initial object, on output 
//                       selected object)
// ARootObj            - given IDB Subnet root object
// ASFilterFunc        - IDB objects select filter function
// ASelCaption         - dialog window caption
// ASelShowToolBarFlag - show change IDB Subnet Toolbar flag
// AMultiSelectFlag    - allows to select more then one IDB Object
// AVChildsFlags       - value of TN_VTree.VTFlags which controls Visual nodes 
//                       creating
// Result              - Returns TRUE if proper IDB object was selected
//
function K_SelectUDNode( var ASelObj : TN_UDBase; ARootObj : TN_UDBase;
                                     ASFilterFunc : TK_TestDEFunc;
                                     ASelCaption : string;
                                     ASelShowToolBarFlag : Boolean;
                                     AMultiSelectFlag : Boolean = false;
                                     AVChildsFlags : Integer = 0  ) : Boolean;
var
  DE : TN_DirEntryPar;
  RootPath : string;
begin
//  RootPath := '';
//  if UDSelectObj <> nil then begin
//    RootPath := RootNode.GetRefPathToObj( UDSelectObj );
//    if RootPath = '' then
//      RootPath := RootNode.GetPathToObj( UDSelectObj );
//  end;
  RootPath := K_GetPathToUObj( ASelObj, ARootObj );

  FillChar(DE.Child, SizeOf(TN_DirEntryPar), 0);
  DE.Child := ASelObj;
  Result := K_SelectDEOpen( DE, ARootObj, RootPath, ASFilterFunc, ASelCaption,
                            ASelShowToolBarFlag, AMultiSelectFlag, AVChildsFlags );
  if Result then ASelObj := DE.Child;
end; // end of K_SelectUDNode

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_AddDEToSBuf
//*********************************************************** K_AddDEToSBuf ***
// Add serialized IDB Directory Entry parameters to Buffer for Binary Serialized
// Data
//
//     Parameters
// ASBuf            - Buffer for Binary Serialized Data
// ADE              - given IDB Directory Entry parameters
// AAddChildSubtree - returns TRUE if serialization of given Child object 
//                    Subtree data is needed
// Result           - Returns Directory Entry Child object
//
function K_AddDEToSBuf( ASBuf: TN_SerialBuf; var ADE : TN_DirEntryPar;
                                    out AAddChildSubtree: boolean ) : TN_UDBase;
var
  ClassInd : Integer;
//  DE : TN_DirEntryPar;
  Child : TN_UDBase;
begin
  AAddChildSubtree := false;
//*** save dir entry
//  GetDirEntry(ChildInd, DE);

  ASBuf.AddRowString( ADE.DEName );
  ASBuf.AddRowInt( ADE.DECode );
  ASBuf.AddRowInt( Integer(ADE.DEFlags) );
  ASBuf.AddRowBytes( SizeOf(TK_DEUFlags), @ADE.DEUFlags );
  ASBuf.AddRowBytes( SizeOf(TK_DEVFlags), @ADE.DEVFlags );

  Result := ADE.Child;
  if (Result = nil) or (Result = N_EmptyObj) then begin
   //*** no childe - save empty dir flag
    ASBuf.AddTag( K_fTagObjAbsent );
  end
  else
  begin// if DE.Child.Marker = 0 then // Child obj was not added yet, add it
    ASBuf.AddTag( K_fTagObjBody ); // "child.fields" tag
    Child := Result;
    K_BuildDEChildRef( ADE );
    ClassInd := ADE.Child.CI;
    if not(ADE.Child is N_ClassRefArray[ClassInd]) then
    begin
    // error in obj Class Flags
      K_ShowMessage( 'Save to file -> Error in obj Class Flags  for ' + ADE.Child.ClassName );
      assert(false);
      Exit;
    end;
    K_AddUObjToUsedTypesList( ADE.Child, ASBuf.SBUsedTypesList );
    ASBuf.AddRowInt( ClassInd ); // for future creating obj
    ADE.Child.AddFieldsToSBuf( ASBuf ); // add Child obj fields (not children!)
  {
    DE.Child.SetMarker(SBuf.OfsFree);       // SBuf offset for obj memory address
    SBuf.RefList.Add( DE.Child ); // for future clearing Marker field after saving
  }
//***!!! save for previous format
//    SBuf.AddRowInt( 0 ); // place for obj memory address (used later, while loading)
    ASBuf.AddRowInt( Child.RefIndex ); // for future Direct Reference Build
//***!!!
    if (ClassInd = K_UDRefCI) then
    begin
      if (Integer(Child.ClassFlags) <> ClassInd) then
        ADE.Child.UDDelete; // delete Node created only for data serialization (unload)
    end
    else
    begin
      Child.SetMarker(1);        // Mark Saved Obj
//      SBuf.RefList.Add( Child ); // for future clearing Marker field after saving
      AAddChildSubtree := true;
    end;
  end
{
  else // child was already added (already in SBuf)
  begin
    SBuf.AddTag( K_fTagObjLink ); // "reference to child.fields" tag
    SBuf.AddRowInt( DE.Child.Marker ); // save SBuf offset to child memory address
  end};

end; // end_of procedure K_AddDEToSBuf

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_GetDEFromSBuf
//********************************************************* K_GetDEFromSBuf ***
// Get IDB Directory Entry parameters from Buffer with Binary Serialized Data
//
//     Parameters
// ASBuf            - Buffer with Binary Serialized Data
// ADE              - IDB Directory Entry parameters get from ASBuf
// AGetChildSubtree - returns TRUE if deserialization of get Child object 
//                    Subtree data is needed
//
procedure K_GetDEFromSBuf( ASBuf: TN_SerialBuf; var ADE: TN_DirEntryPar; out AGetChildSubtree : Boolean );
var
  SbufOffset, ClassRefInd: integer;
  Tag: byte;

begin
  K_ClearDirEntry( ADE );
  AGetChildSubTree := false;
  ASBuf.GetRowString( ADE.DEName );
  ASBuf.GetRowInt( ADE.DECode );
  ASBuf.GetRowInt( Integer(ADE.DEFlags) );
  ASBuf.GetRowBytes( SizeOf(TK_DEUFlags), @ADE.DEUFlags );
  ASBuf.GetRowBytes( SizeOf(TK_DEVFlags), @ADE.DEVFlags );
  ASBuf.GetTag( Tag );

  if Tag = K_fTagObjBody then
  begin
//*** no child obj in memory, create it
    ASBuf.GetRowInt( ClassRefInd );
    try
      ADE.Child := N_ClassRefArray[ClassRefInd].Create;
    except
      On E: Exception do
        raise TK_LoadUDDataError.Create( 'Error in Class Reference Array index -> ' + IntToStr(ClassRefInd) );
//   begin
//      ShowMessage( 'Error in Class Reference Array index -> ' + IntToStr(ClassRefInd) );
//      assert(false);
//      Exit;
//   end;
    end;

    ADE.Child.GetFieldsFromSBuf( ASBuf ); // get Child obj fields (not children!)

//***!!! save for previous format
//*** place child (new or existed) obj memory addr in SBuf for future use
//    PInteger(SBuf.Poffset(SBuf.CurOfs))^ := integer(DE.Child);
//    SBuf.CurOfs := SBuf.CurOfs + SizeOf(integer); // skip place for obj addr
    ASBuf.GetRowInt( ADE.Child.RefIndex );
//***!!!
    AGetChildSubTree := ADE.Child.AddSelfToRefTable;
  end else

//***!!! save for previous format
  if Tag = K_fTagObjLink then
  begin
//*** Child obj is already in memory, use its addres, stored in SBuf
    ASBuf.GetRowInt( SbufOffset );
    ADE.Child := TN_UDBase(PInteger(ASBuf.POffset(SbufOffset))^);
//    DE.Child := TN_UDBase(PInteger(@SBuf.Buf[SbufOffset])^);
  end else
//***!!!

end; // end_of procedure K_GetDEFromSBuf

{
//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_UDBaseDelete
//********************************************************** K_UDBaseDelete ***
// Delete TN_UDBase (even not Assigned)
//
procedure K_UDBaseDelete( UD : TN_UDBase );
begin
  if UD <> nil then UD.Delete;
end; // end_of procedure K_UDBaseDelete
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ClearDirEntry
//********************************************************* K_ClearDirEntry ***
// Clear IDB Directory Entry parameters data
//
//     Parameters
// ADE - IDB Directory Entry parameters
//
procedure K_ClearDirEntry ( var ADE : TN_DirEntryPar );
begin
  ADE.DEName := '';
  FillChar(ADE.Child, SizeOf(TN_DirEntryPar), 0);
end; // end_of procedure K_ClearDirEntry

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_AddCompareErrInfo
//***************************************************** K_AddCompareErrInfo ***
// Add new compare IDB Subnets error info to global compare errors list
//
//     Parameters
// AErrInfo - new compare error info, if = '' then initialization of errors list
//            will be done
// Result   - Returns TRUE if Subnets compare loop break is needed
//
function K_AddCompareErrInfo( AErrInfo : string ) : Boolean;
begin
  if AErrInfo = '' then begin //*** init data
    if (K_CompareMaxErrNum <> 0) and
       (K_CompareSList = nil) then
      K_CompareSList := TStringList.Create;
    K_CompareSList.Clear;
    K_CompareCurNum := 0;
    K_CompareStopFlag := false;
  end else begin            //*** add message
    if K_CompareSList <> nil then
      K_CompareSList.Add( AErrInfo );
    Inc(K_CompareCurNum);
    if K_CompareCurNum >= K_CompareMaxErrNum then
      K_CompareStopFlag  := true;
  end;
  Result := K_CompareStopFlag;
end; // end_of procedure K_AddCompareErrInfo

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_BuildPathSegmentByDE
//************************************************** K_BuildPathSegmentByDE ***
// Build IDB path segment text for given Directory Entry parameters
//
//     Parameters
// ADE          - IDB Directory Entry parameters
// AObjNameType - name type (ObjName,ObjAliase etc.) enumeration
// Result       - Returns IDB path segment text for given Directory Entry 
//                parameters
//
function  K_BuildPathSegmentByDE( const ADE : TN_DirEntryPar;
            AObjNameType : TK_UDObjNameType = K_ontObjName ) : string;
var
ext : string;
begin
  Result := '';
  if (ADE.Child <> nil) and
     ((ADE.Parent.ObjFlags and K_fpObjPathNoName) = 0) then begin
    if ((ADE.Parent.ObjFlags and K_fpObjPathUCheck) = 0) or
       (ADE.DirIndex = -1)                               or
       (ADE.Parent.IndexOfChildObjName( ADE.Child.ObjName ) = ADE.DirIndex) then
      Result := ADE.Child.GetUName(AObjNameType)
{ else //*** add type name instead of obj name
   if (DE.PIndex <> -1) and
      (DE.Parent.IndexOfChildType( DE.Child.ClassFlags ) = DE.PIndex) then
     Result := K_udpObjTypeNameChar + N_ClassTagArray[DE.Child.ClassFlags and $FF];}
  end;
  ext := '';
  if ((ADE.Parent.ObjFlags and K_fpObjPathNoExt) = 0) then begin
    if (ADE.DEName <> '') and
       ( ((ADE.Parent.ObjFlags and K_fpObjPathUCheck) = 0) or
         (ADE.Parent.IndexOfDEField( ADE.DEName, K_DEFisName ) = ADE.DirIndex) ) then
      ext := K_udpDENameDelim + ADE.DEName
    else if (ADE.DECode <> 0) and
            ( ((ADE.Parent.ObjFlags and K_fpObjPathUCheck) = 0) or
              (ADE.Parent.IndexOfDECode( ADE.DECode ) = ADE.DirIndex) ) then
      ext := K_udpDECodeDelim + IntToStr( ADE.DECode );
  end;

// add K_udpDENameChar if ObjName contains it and extension is empty
  if (ext = '') and
     ( (Pos( K_udpDENameDelim, Result ) <> 0) or
       (Pos( K_udpDECodeDelim, Result ) <> 0) ) then
    ext := K_udpDENameDelim;

  Result := Result + ext;

  if Result = '' then
    Result := K_udpDEIndexDelim + IntToStr( ADE.DirIndex );
end; // end_of procedure K_BuildPathSegmentByDE

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ReplaceNodeRef
//******************************************************** K_ReplaceNodeRef ***
// if Node is Reference - get real Node if needed
//
function K_ReplaceNodeRef( Node : TN_UDBase; var NNode : TN_UDBase ) : Boolean;
begin
  if not (K_gcfSkipRefReplace in K_UDGControlFlags) and
    (Node <> nil)                                   and
    ((Node.ClassFlags and $FF) = K_UDRefCI) then  begin
    Result := true;
    if (Node.RefIndex <> 0)                         and
       (Node.RefIndex < Length(K_UDRefTable))       and
       (K_UDRefTable[Node.RefIndex] <> nil) then begin
      NNode := K_UDRefTable[Node.RefIndex];
      Node.UDDelete;
    end else if (Node.RefPath = K_udpLocalPathCursorName ) or
                not (K_gcfUseOnlyRefInd in K_UDGControlFlags) then begin
      K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );
      NNode := TK_UDRef(Node).GetRefObject;
      K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );
    end else
      NNode := Node;
  end else
    Result := false;
end; // end_of function K_ReplaceNodeRef

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_BuildDEChildRef
//******************************************************* K_BuildDEChildRef ***
// Build Reference to Dir Entry Child if needed
//
procedure K_BuildDEChildRef( var DE : TN_DirEntryPar; CreateRefObj : Boolean = true );
//var
//  Name, Aliase, RPath : string;
//  RIndex : Integer;

  procedure SetRefIndex;
  begin
{
    if (DE.Child.RefCounter > 1) and  // child has not only owner references AND
       (DE.Child.RefIndex = 0)   and  // child was not marked in RefTable    AND
       (  (DE.Parent = nil)      or        // saving field of UDRArray
          (DE.Parent.Marker <> 2) or       // parent is not saved root      OR
          (DE.Child.RefCounter > 2) ) then // parent is saved root then number of
    begin                                  // references must be > 2 because
      Inc( K_UDRefIndex );                 // in this case node 2 refs:
      DE.Child.RefIndex := K_UDRefIndex;   //  to real parent and to wrk root
    end;
}
    if (DE.Child.RefCounter > 1) and   // child has not only owner references AND
       (DE.Child.RefIndex = 0)    then // child was not marked in RefTable
    begin
      Inc( K_UDRefIndex1 );
      DE.Child.RefIndex := K_UDRefIndex1;
    end;
  end;

begin
  if (DE.Child.Marker <> 0) or            // was alredy saved  OR
     ( (  (DE.Parent = nil)    or         // saving field of UDRArray
          (DE.Parent.Marker <> 2) ) and   // parent is not saving root  AND
       (DE.Child.Owner <> nil)      and
       (DE.Child.Owner <> DE.Parent) ) then // owner is not parent
  begin //*** replace object by its ReferenceObject
    DE.Child.BuildRefPath();
    if Length(DE.Child.RefPath) <> 0 then
    begin //*** find Reference Path
      SetRefIndex;
//      RIndex := DE.Child.RefIndex;
//      RPath := DE.Child.RefPath;
      if CreateRefObj then
      begin
        DE.Child := DE.Child.BuildRefObj;
{
        Name := DE.Child.ObjName;
        Aliase := DE.Child.ObjAliase;
        DE.Child := TK_UDRef.Create(  );
        DE.Child.RefPath := RPath;
        DE.Child.RefIndex := RIndex;
        DE.Child.ObjName := Name;
        DE.Child.ObjAliase := Aliase;
}
      end;
    end;
  end
  else
  begin
    SetRefIndex;
    if (DE.Child.Owner = nil)     and
       (DE.Child.CI <> K_UDRefCI) and
       not (K_gcfSkipFreeObjsDump in K_UDGControlFlags)then
      K_InfoWatch.AddInfoLine( 'Reference to free object '+N_ClassTagArray[DE.Child.CI]+':'+DE.Child.GetUName );
  end;
end; // end_of procedure K_BuildDEChildRef

{
//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ClearRefList
//********************************************************** K_ClearRefList ***
// clear SysOfs field in all objects included in RefList
//
procedure K_ClearRefList( RefList : TList);
var i: integer;
begin
  for i := 0 to RefList.Count-1 do TN_UDBase(RefList.Items[i]).SetMarker(0);
  RefList.Clear;
end; //*** end of procedure K_ClearRefList
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_CmpInt1
//*************************************************************** K_CmpInt1 ***
// Compare integer items given by pointers
//
//     Parameters
// APItem1 - pointer to first interger item
// APItem2 - pointer to second interger item
// Result  - returns
//#F
//   0 - if items are equal
//   1 - if Item2 is less then Item2
//  -1 - if Item2 is less then Item1
//#/F
//
function K_CmpInt1(const APItem1, APItem2 : Pointer): Integer;
var
  i1: ^Integer absolute APItem1;
  i2: ^Integer absolute APItem2;
  r:  Integer;
begin
  r := i1^ - i2^;
  if r = 0 then
    Result := 0
  else if r < 0 then
    Result := -1
  else
    Result := 1;
end; // end_of procedure K_CmpInt1

{
//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_CmpInt2
//*************************************************************** K_CmpInt2 ***
// compare replacing links records routine
//
function K_CmpInt2(const item1, item2 : Pointer): Integer;
var
  i1: ^Int64 absolute item1;
  i2: ^Int64 absolute item2;
  r :  Int64;
begin
  r := i1^ - i2^;
  if r = 0 then
    Result := 0
  else if r < 0 then
    Result := -1
  else
    Result := 1;
end; // end_of procedure K_CmpInt2
}
//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_CompareDirEntries
//***************************************************** K_CompareDirEntries ***
// Compare IDB Directory Entries parameters
//
//     Parameters
// ADE1    - first IDB Directory Entry parameters
// ADE2    - second IDB Directory Entry parameters
// AVFlags - visual tree flags
// Result  - Returns TRUE if first Directory Entry is greater then second
//
// Used for Visual Tree nodes order creation.
//
function K_CompareDirEntries ( const ADE1, ADE2 : TN_DirEntryPar;
                               AVFlags : Integer ) : Boolean;
var cresult : Integer;
begin
  Result := False;
  cresult := -1;
  case (AVFlags and K_fvDirSortedMask) of
    K_fvDirSortedByObjUName:
      cresult := CompareStr( ADE1.Child.GetUName(), ADE2.Child.GetUName() );
    K_fvDirSortedByObjName :
      cresult := CompareStr( ADE1.Child.ObjName, ADE2.Child.ObjName );
    K_fvDirSortedByObjType :
      cresult := Integer((ADE1.Child.ClassFlags and $FF)) - Integer((ADE2.Child.ClassFlags and $FF));
    K_fvDirSortedByObjDate :
      if ADE1.Child.ObjDateTime > ADE2.Child.ObjDateTime then
        cresult := 1
      else if ADE1.Child.ObjDateTime = ADE2.Child.ObjDateTime then
        cresult := 0;
    K_fvDirSortedByDEName  :
      cresult := CompareStr( ADE1.DEName, ADE2.DEName );
    K_fvDirSortedByDECode  :
      cresult := ADE1.DECode - ADE2.DECode;
  end;
  if (AVFlags and K_fvDirDescendingSorted) <> 0 then cresult := - cresult;
  if cresult > 0 then Result := True;
end; // end_of function K_CompareDirEntries

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_GetDEVFlags
//*********************************************************** K_GetDEVFlags ***
// Get Visual Flags from given IDB Direcory Entry parameters
//
//     Parameters
// ADE       - first IDB Directory Entry parameters
// AVFlags   - default Visual Flags
// AFlagsNum - index of Visual Flags array elemennt (=0 or =1)
// Result    - Returns resulting visual flags
//
function K_GetDEVFlags ( const ADE : TN_DirEntryPar;
                         AVFlags, AFlagsNum : Integer ) : Integer;
begin
  Result := AVFlags;
  if (Result and K_fvSkipCurrent) = 0 then
  begin
    if (ADE.DEVFlags[AFlagsNum] and K_fvUseCurrent) <> 0 then
      Result := ADE.DEVFlags[AFlagsNum];
    if (Result and K_fvSkipCurrent) = 0 then
    begin
      if (ADE.Child.ObjVFlags[AFlagsNum] and K_fvUseCurrent) <> 0 then
        Result := ADE.Child.ObjVFlags[AFlagsNum];
    end;
  end;
end; // end_of function K_GetDEVFlags

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_DERErrorInfoText
//****************************************************** K_DERErrorInfoText ***
// Build Error Info text by Directory Entry Replace Error Code
//
//     Parameters
// AErrCode - IDB Directory Entry Repalce Error Code Enumeration
// AErrInfo - default Visual Flags
// Result   - Returns resulting visual flags
//
function K_DERErrorInfoText( AErrCode : TK_DEReplaceResult; out AErrInfo : string ) : Boolean;
begin
  Result := false;
  SetLength(AErrInfo, 0);
  if AErrCode <= K_DRisOK then Exit;
  Result := true;
  AErrInfo := 'Unknown data replace error';
  case AErrCode of
    K_DRisObjProtected   : AErrInfo := 'Replace protected Object error';
    K_DRisDEProtected    : AErrInfo := 'Remove protected Entry error';
{
    K_DRisDataRefError   : ErrMessage := 'Wrong Refernce Code Attribute';
    K_DRisChangeCodeError: ErrMessage := 'Change refernced Data Code error';
    K_DRisArrayTypeError : ErrMessage := 'Wrong Data Array type error';
    K_DRisArrayIndexError: ErrMessage := 'Wrong Data Array index error';
    K_DRisDataTypeError  : ErrMessage := 'Data Type collision';
    K_DRisDataArrayClassError : ErrMessage := 'Data Array Class collision';
    K_DRisDataArrayTypeError  : ErrMessage := 'Data Array Type collision';
    K_DRisDataArrayRangeError : ErrMessage := 'Data Array Range collision';
    K_DRisDataVectorRangeError: ErrMessage := 'Data Vector Range collision';
}
    K_DRisIndError{, K_DRisVCodeError} :
    begin
      AErrInfo := 'Internal Error - wrong Dir Entry VCODE or Index';
      assert( false, AErrInfo );
    end
  else
    Exit;
  end;
end;

{
//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_CheckDirEntry
//********************************************************* K_CheckDirEntry ***
// test if dir entry is equal to new entry params(type and child)
//
function K_CheckDirEntry( const DE : TN_DirEntryPar; const Child : TN_UDBase ) : Boolean;
begin
  Result := DE.Child = TN_UDBase(Child);
end;
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_SetUDGControlFlags
//**************************************************** K_SetUDGControlFlags ***
// Change global IDB Control Flags
//
//     Parameters
// ASetMode - set flags mode, if =1 then set given elements, if =-1 clear given 
//            elements
// AValue   - IDB Control Flags set elements to set or reset
//
procedure K_SetUDGControlFlags( ASetMode : Integer; AValue : TK_UDGControlFlags );
begin
  K_UDGControlFlagsCounters[Ord(AValue)] := K_UDGControlFlagsCounters[Ord(AValue)] + ASetMode;
  if ASetMode = 1 then // include
    Include( K_UDGControlFlags, AValue )
  else             // exclude
    if K_UDGControlFlagsCounters[Ord(AValue)] = 0 then
      Exclude( K_UDGControlFlags, AValue );
end;

{
//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_FreeDEArrayChilds
//***************************************************** K_FreeDEArrayChilds ***
// Free DEArray Childs
//
procedure K_FreeDEArrayChilds( var ArrDE : TK_DEArray; FreeInstance : Boolean = true );
var  i : Integer;
begin
  for i := 0 to High(ArrDE) do
    with ArrDE[i].Child do begin
      if RefCounter > 1 then
        RebuildVNodes( -1 );
      Delete();
    end;
  if FreeInstance then ArrDE := nil;
end; // end of procedure K_FreeDEArrayChilds


//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_MarkVNodesListSubTrees
//************************************************ K_MarkVNodesListSubTrees ***
// Mark VNodes List SubTrees
//
procedure K_MarkVNodesListSubTrees( VList : TList; ALevel : Integer = 0;
                                 ADepth : Integer = -1;
                                 AField : Integer = -1 );
var  i : Integer;
begin
//*** marked all nodes in selected SubTrees
  if Assigned( VList ) then
    for i := 0 to VList.Count - 1 do
      TN_VNode(VList[i]).VNUDObj.MarkSubTree( Alevel, ADepth, AField );
end; // end of procedure K_MarkVNodesListSubTrees


//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_AddChildsFromDEArray
//************************************************** K_AddChildsFromDEArray ***
// Add childs from VNodes list
//
procedure K_AddChildsFromDEArray( Root : TN_UDBase; const DEArray : TK_DEArray;
                                        Clear : Boolean = true );
var  leng, i : Integer;
DE : TN_DirEntryPar;
begin

  if Clear then begin
    Root.ClearChilds( 0, Length(DEArray) );
    leng := 0;
  end else begin
    leng := Root.DirLength;
    Root.DirSetLength( leng + Length(DEArray) );
  end;

  for i := 0 to High(DEArray) do begin
    DE := DEArray[i];
       // object was already added
    if (Root.IndexOfDEField( DE.Child, K_DEFisChild ) = -1) then begin // UObj is not added yet
      Root.PutDirEntry( leng, DE );
      Root.AddChildVNodes( leng );
      Inc(leng);
    end;
  end;
  Root.DirSetLength( leng );
end; // end of procedure K_AddChildsFromDEArray
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_AddChildsFromVNodesList
//*********************************************** K_AddChildsFromVNodesList ***
// Add New Child Objects to given IDB Root object from Visual Nodes list
//
//     Parameters
// ARootObj   - given IDB Subnet root object
// AVList     - Visual Nodes list
// AClearFlag - clear existing child objects before adding new objects flag
//
procedure K_AddChildsFromVNodesList( ARootObj : TN_UDBase; AVList : TList; AClearFlag : Boolean = true );
var  leng, i : Integer;
DE : TN_DirEntryPar;
VNode : TN_VNode;
begin

  if AClearFlag then
  begin
    ARootObj.ClearChilds( 0, AVList.Count );
    leng := 0;
  end else
  begin
    leng := ARootObj.DirLength;
    ARootObj.DirSetLength( leng + AVList.Count );
  end;
  for i := 0 to AVList.Count - 1 do
  begin
    VNode := TN_VNode(AVList.Items[i]);
       // object was already added
    if (ARootObj.IndexOfDEField( VNode.VNUDObj, K_DEFisChild ) = -1) and
       // object was not marked by SbufOfs field
       (VNode.VNUDObj.Marker = 0) then // UObj is not added yet
    begin
      VNode.GetDirEntry( DE );
      ARootObj.PutDirEntry( leng, DE );
      ARootObj.AddChildVNodes( leng );
      Inc(leng);
    end;
  end;
  ARootObj.DirSetLength( leng );
end; // end of procedure K_AddChildsFromVNodesList

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_UnlinkDirectReferences
//************************************************ K_UnlinkDirectReferences ***
// Convert given IDB Subnet to Subtree by replacing direct referenses to real 
// Objects
//
//     Parameters
// ARootObj          - given IDB Subnet root object
// ARootCursorName   - root object cursor name for IDB Subnet Objects relative 
//                     paths create
// AClearRefInfoFlag - clear given IDB Subnet references info before replacing 
//                     direct referenses
//
// Direct referenses to real Objects are replaced by references to specially 
// created Objects Reference Substitutes. Is used for preparing IDB Subnet to 
// serialization.
//
procedure K_UnlinkDirectReferences( ARootObj : TN_UDBase; ARootCursorName : string = '';
                                    AClearRefInfoFlag : Boolean = false );
begin
  if AClearRefInfoFlag then
    K_ClearSubTreeRefInfo( ARootObj );
  if ARootCursorName <> '' then
    ARootObj.RefPath := ARootCursorName;
  K_SysDateTime := Now();
  K_SetUDGControlFlags( 1, K_gcfSkipRefReplace );
  K_SetUDGControlFlags( 1, K_gcfSysDateUse );
  ARootObj.BuildSubTreeRefObjs( );
  K_SetUDGControlFlags( -1, K_gcfSkipRefReplace );
  K_SetUDGControlFlags( -1, K_gcfSysDateUse );
end; // end of procedure K_UnlinkDirectReferences

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_BuildDirectReferences
//************************************************* K_BuildDirectReferences ***
// Build Direct References in given IDB Subtree
//
//     Parameters
// ARootObj         - given IDB Subtree root object
// ABuildDRefsFlags - build direct references control flags
// Result           - Returns unresolved references counter
//
// Build direct referenses to real Objects by replacing references to specially 
// created Objects Reference Substitutes. Is used for preparing IDB Subtree 
// after deserialization.
//
function K_BuildDirectReferences( ARootObj : TN_UDBase; ABuildDRefsFlags : TK_BuildDirectRefsFlags = [K_bdrClearURefCount] ) : Integer;
var
  PrevCounter : Integer;
begin
  Exclude( K_UDGControlFlags, K_gcfSkipRefReplace );

  with K_UDTreeBuildRefControl do begin
    RRefCount := 0;
    if K_bdrClearURefCount in ABuildDRefsFlags then
      URefCount := 0;
    PrevCounter := URefCount;
    K_UDScannedUObjsList := Tlist.Create;
    ARootObj.ReplaceSubTreeRefObjs;
    K_ClearUObjsScannedFlag;
    FreeAndNil(K_UDScannedUObjsList);

    Result := URefCount - PrevCounter;
  end;
  if K_bdrClearRefInfo in ABuildDRefsFlags then
    K_ClearSubTreeRefInfo( ARootObj );
end; // end of procedure K_BuildDirectReferences

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ShowUnresRefsInfo
//***************************************************** K_ShowUnresRefsInfo ***
// Show Unresolved References Info
//
//     Parameters
// AShowRoot        - IDB Subnet root Object
// AUnresCount      - unresolved references counter
// AShowDetailsFlag - unconditional show details flag
//
procedure K_ShowUnresRefsInfo( AShowRoot : TN_UDBase; AUnresCount : Integer = 0;
                                      AShowDetailsFlag : Boolean = false );
var
  SL : TStringList;
  WNum : string;
begin
  if K_gcfSkipUnResoledRefInfo in K_UDGControlFlags then Exit;
  WNum := 'U';
  if AUnresCount > 0 then
    WNum := IntToStr(AUnresCount)+ ' u';
  if AShowDetailsFlag or
    (MessageDlg( WNum + 'nresolved references are detected. Show detailes?',
                 mtWarning, mbOKCancel, 0 ) = mrOk) then begin
    SL := TStringList.Create;
    N_GetUnresRefsInfo( SL, AShowRoot, [gifMaxInfo] );
    K_GetFormTextEdit.EditStrings( SL, 'Unresolved references' );
    SL.Free;
  end;
end; // end of procedure K_ShowUnresRefsInfo

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ClearSubTreeRefInfo
//*************************************************** K_ClearSubTreeRefInfo ***
// Clear IDB Subnet References Info after building direc references routine
//
//     Parameters
// ARootObj           - IDB Subnet Root Object
// AClearRefInfoFlags - control flags
//
procedure K_ClearSubTreeRefInfo( ARootObj : TN_UDBase; AClearRefInfoFlags : TK_ClearRefInfoFlags = [] );
begin

  if K_criClearFullSubTree in AClearRefInfoFlags then
    K_UDScannedUObjsList := Tlist.Create;

  ARootObj.ClearSubTreeRefInfo( ARootObj, AClearRefInfoFlags );

  if K_criClearFullSubTree in AClearRefInfoFlags then begin
    K_ClearUObjsScannedFlag;
    FreeAndNil(K_UDScannedUObjsList);
  end;

  if K_criClearChangedInfoFlag in AClearRefInfoFlags then
    K_TreeViewsInvalidate();

end; // end of procedure K_ClearSubTreeRefInfo

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ReplaceRefsInSubTree
//************************************************** K_ReplaceRefsInSubTree ***
// Replace References From Base IDB Subtree to previous Taget IDB Subtree by 
// corresponding References in new Target IDB Subtree
//
//     Parameters
// ABaseRoot         - Base IDB Subtree Root object
// APrevTargetRoot   - previous Target IDB Subtree Root object
// ANewTargetRoot    - new Target IDB Subtree Root object
// AShowErrorMesFlag - show detailed errors message flag
// Result            - Returns resulting number of unresolved references
//
function K_ReplaceRefsInSubTree( ABaseRoot, APrevTargetRoot, ANewTargetRoot : TN_UDBase;
                                 AShowErrorMesFlag : Boolean = true ) : Integer;
const ReplaceRefsCursor = '%%%:';
var
  PrevSTRefPath : string;
  NewSTRefPath : string;
begin
//*** Store SubTreeRoots RefPaths
  PrevSTRefPath := APrevTargetRoot.RefPath;
  NewSTRefPath  := ANewTargetRoot.RefPath;

//*** Set Special RefPath to Prev Root for Unlinking Direct References in RefsRoot
  APrevTargetRoot.RefPath := ReplaceRefsCursor;
  K_UnlinkDirectReferences( ABaseRoot );

//*** Set Special Cursor to New Root for Building Direct References in RefsRoot
  K_UDCursorGet( ReplaceRefsCursor ).SetRoot( ANewTargetRoot );
  Result := K_BuildDirectReferences( ABaseRoot, [K_bdrClearRefInfo, K_bdrClearURefCount] );

//*** Clear RefInfo for All Archive Tree
  K_ClearArchiveRefInfo;

//*** Restore SubTreeRoots RefPaths
  APrevTargetRoot.RefPath := PrevSTRefPath;
  ANewTargetRoot.RefPath := NewSTRefPath;

  if (Result > 0) and AShowErrorMesFlag then
    K_ShowUnresRefsInfo( ABaseRoot, Result );

end; // end of procedure K_ReplaceRefsInArchSubTree

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ClearUObjsScannedFlag
//************************************************* K_ClearUObjsScannedFlag ***
// Clear ScannedMarker Flag from objects in Scanned IDB Objects list
//
// Clear K_UDScannedUObjsList after all.
//
procedure K_ClearUObjsScannedFlag;
var i : Integer;
begin
  for i := 0 to K_UDScannedUObjsList.Count - 1 do
    with TN_UDBase( K_UDScannedUObjsList[i] ) do
      ClassFlags := ClassFlags and not K_MarkScanNodeBitD;
  K_UDScannedUObjsList.Clear;
end; // end of procedure K_ClearUObjsScannedFlag

{
//********************************************* N_SaveHeaderToStrings ***
// form strings header in TN_UDBase.SaveToStrings procedures
//
procedure N_SaveHeaderToStrings( Strings: TStrings;
                                      UObj: TN_UDBase; Mode: integer );
begin
  if Mode <> 0 then Exit;
  Strings.Add( '[' + UObj.ClassName + ']' );
  Strings.Add( '  $' + IntToHex( integer(UObj), 7 ) +
               '  RefC=' + IntToStr( UObj.RefCounter ) );
  Strings.Add( Format ( 'VFlags=  $%.2x  $%.2x', [ UObj.ObjVFlags[0], UObj.ObjVFlags[1] ] ) );
//**Flags  Strings.Add( Format ( 'UFlags=  $%.8x  $%.8x',
//**Flags    [ UObj.ObjUFlags[0].AllBits, UObj.ObjUFlags[1].AllBits ] ) );
  Strings.Add( Format ( 'UFlags=  $%.8x',
    [ UObj.ObjUFlags[0].AllBits ] ) );
  Strings.Add( Format ( '  $%.4x  %s', [ UObj.ObjFlags,
                                        N_QS(UObj.ObjName) ] ) );
  Strings.Add( '  ' + DateTimeToStr( UObj.ObjDateTime ) );
//  Strings.Add( Format ( 'VN[0] = %.7x', [ integer(Obj.VNodes[0].VNode) ] ) ); // debug
end; // end_of procedure N_SaveHeaderToStrings


//##path K_Delphi\SF\K_clib\K_UDT1.pas\N_CollectOneLevelStatistics
//********************************************* N_CollectOneLevelStatistics ***
// collect statistcs about given UObj and call himself for all childs
// bits0-7($0FF) of Mode - needed number of child levels: =0   - Ubj only, do
// not consider any childs =$FF - consider all levels childs
//
procedure N_CollectOneLevelStatistics( UObj: TN_UDBase; Mode: integer );
var
  i, h, Level: integer;
  Child : TN_UDBase;
  WVNode : TN_VNode;
begin
  Inc( N_StatData.NumUObj );
  WVNode := UObj.LastVNode;
  while WVNode <> nil do
  begin
    WVNode := WVNode.PrevVNUDObjVNode;
    Inc( N_StatData.NumVNode );
  end;

  Level := Mode and $FF;
  if Level = 0 then Exit;
  if Level <> $FF then Dec(Level); // $FF means all levels

  if UObj.DirLength <> 0 then
  begin
    Inc(N_StatData.NumDir);
    h := UObj.DirHigh;
    for i := 0 to h do
    begin
      Child := UObj.DirChild(i);
      if Child <> nil then
        N_CollectOneLevelStatistics( Child,
                               integer((Mode and $FFFFFF00)) + Level );
    end;
  end;
end; // end of procedure N_CollectOneLevelStatistics

//##path K_Delphi\SF\K_clib\K_UDT1.pas\N_CollectStatistics
//***************************************************** N_CollectStatistics ***
// collect statistics about given UObj and its childs, and show it in N_InfoForm
//
procedure N_CollectStatistics( UObj: TN_UDBase; Mode: integer;
                                                    AStrings: TStrings = nil );
var
  S: TStrings;
  i, NumVTree: integer;
begin
  if AStrings = nil then
  begin
    S := N_GetInfoForm.Memo.Lines;
    S.Clear;
  end else
    S := AStrings;

  S.Add( '  FULL STATISTCS ABOUT ' + UObj.ObjName + '(' + UObj.ObjAliase + ')' );

  NumVTree := 0;
  for i := 0 to N_VTrees.Count - 1 do
  begin
    if N_VTrees[i] <> nil then Inc(NumVTree);
  end;
  S.Add( Format( ' NumVTree = %d', [ NumVTree ] ) );

  N_StatData.NumUObj  := 0;
  N_StatData.NumVNode := 0;
  N_StatData.NumDir   := 0;

  N_CollectOneLevelStatistics( UObj, Mode );

  S.Add( Format( ' Number of objects  = %d', [ N_StatData.NumUObj ] ) );
  S.Add( Format( ' Number of Dirs     = %d', [ N_StatData.NumDir ] ) );
  S.Add( Format( ' Number of VNodes   = %d', [ N_StatData.NumVNode ] ) );

  S.Add( '   Memory used (in bytes) :' );
  N_PlatformInfo( S, $060 );
  S.Add( '' );

  if (AStrings = nil) and (N_InfoForm <> nil) then
    N_InfoForm.Show;

end; // end of procedure N_CollectStatistics

//************************************************* N_CompressVNodes ***
// Compress VNodes array (remove empty elements)
//
procedure N_CompressVNodes( var AVNodes: TN_VNArray );
var
  i, NRemoved: integer;
begin
  if AVNodes = nil then Exit; // a precaution
  NRemoved := 0;
  for i := 0 to High(AVNodes) do
  begin
    if AVNodes[i] = nil then // remove i-th element
    begin
      if i < High(AVNodes) then // just Inc(NRemoved) for last element
        move( AVNodes[i+1], AVNodes[i],
                                     (High(AVNodes)-i)*Sizeof(Pointer) );
// ???       move( AVNodes[i+1].VNType, AVNodes[i].VNType,
// ???                                    (High(AVNodes)-i)*Sizeof(Pointer) );
      Inc(NRemoved);
    end;
  end;
  SetLength( AVNodes, Length(AVNodes) - NRemoved );
end;  // end of procedure N_CompressVNodes
}

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_RSTNAddPair
//*********************************************************** K_RSTNAddPair ***
// Add new Pair of IDB Objects to objects replacements list
//
//     Parameters
// AOldUObj - old (replacing) IDB Object
// ANewUObj - new (substituting) IDB Object
//
procedure K_RSTNAddPair( AOldUObj, ANewUObj : TN_UDBase );
var
  ref : TK_UDRefsRep;

begin
  if K_RSTNPairsArray = nil then begin
    K_RSTNPairsArray := TK_BaseArray.Create( 10, SizeOf(TK_UDRefsRep) );
    K_RSTNPairsArray.CompareProc := K_CmpInt1;
    K_RSTNPairsArray.Duplicates := dupIgnore;
    K_RSTNPairsArray.SortOrder := tsAscending;
  end;
  ref.OldChild := AOldUObj;
  ref.NewChild := ANewUObj;
  K_RSTNPairsArray.Insert( ref );
end; //*** end of K_RSTNAddPair

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_RSTNExecute
//*********************************************************** K_RSTNExecute ***
// Replace References to Child Objects in given IDB Subnet using current 
// replacements list
//
//     Parameters
// ARootUObj - given IDB Subnet Root Object
//
// Current replacements list build by K_RSTNAddPair routine
//
procedure K_RSTNExecute( ARootUObj : TN_UDBase );
begin
  if K_RSTNPairsArray = nil then Exit;

  K_UDScannedUObjsList := TList.Create;

  ARootUObj.ReplaceSubTreeNodes( K_RSTNPairsArray );

  K_ClearUObjsScannedFlag( );
  FreeAndNil( K_UDScannedUObjsList );
  FreeAndNil( K_RSTNPairsArray );

end; //*** end of K_RSTNExecute

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_BuildSLSRList
//********************************************************* K_BuildSLSRList ***
// Build list of Separately Loaded Subnets Root Objects in given Subtree
//
//     Parameters
// ARootUObj - given IDB Subnet Root Object
// ASLSRList - list of found Separately Loaded Subnets Root Objects
// ATestProc - function for testing each Child Object in given IDB Subtree
//
procedure K_BuildSLSRList( ARootUObj : TN_UDBase; ASLSRList : TList;
                           ATestProc : TK_TestUDChildFunc = nil  );
begin
  K_CurSLSRList := TList.Create;

  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
  with ARootUObj do begin
    if not Assigned( ATestProc ) then ATestProc := SLSRListBuildScan;
    ScanSubTree( ATestProc );
  end;
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];

  if ASLSRList = nil then Exit;
  ASLSRList.Clear;
  ASLSRList.Assign( K_CurSLSRList );
  FreeAndNil( K_CurSLSRList );
end; //*** end of K_BuildSLSRList

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ClearChangeSubTreeFlags
//*********************************************** K_ClearChangeSubTreeFlags ***
// Clear Changed Flags From Child Object in given IDB SubTree
//
//     Parameters
// ARootUObj - given IDB Subnet Root Object
//
procedure K_ClearChangeSubTreeFlags( ARootUObj : TN_UDBase  );
begin
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
  with ARootUObj do begin
    ClassFlags := ClassFlags and not (K_ChangedSLSRBit or K_ChangedSubTreeBit);
    ScanSubTree( ClearChangeSubTreeScan );
  end;
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];
  K_TreeViewsInvalidate();
end; //*** end of K_ClearChangeSubTreeFlags

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_SetChangeSubTreeFlags
//************************************************* K_SetChangeSubTreeFlags ***
// Mark given IDB Subtree as changed starting from given Object
//
//     Parameters
// ARootUObj - starting IDB Object
// ASetFlags - flags set to control spreading of changed mark in IDB Subtree
//
// Each IDB Object can be marked as changed by special runtime bit atribute: 
// K_ChangedSLSRBit. This routine can spread this attribute in Current IDB 
// Archive starting from given Object. This Flag could be spreaded in various 
// directions:
//#F
//  - DOWN: to given Object Child Subtree
//  - UP: to Owner, Owner.Owner and etc.
//  - BY REFERNCES: UP to all IDB Objects, which contains references to given
//    Object both in Records Array Fields and as child (this feature is needed
//    when IDB Object ObjName field was changed)
//#/F
//
procedure K_SetChangeSubTreeFlags( ARootUObj : TN_UDBase; ASetFlags : TK_SetChangeSubTreeFlags = [] );
var
//  ScanObj: TK_ScanUDSubTree;
  i : Integer;
begin
  with ARootUObj do
  begin
    SetChangedSubTreeFlag( K_cstfSetSLSRChangeFlag in ASetFlags );
    if K_cstfSetDown in ASetFlags then
    begin
      K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsOwnerChildsOnlyScan];
      K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];
      ScanSubTree( SetChangeSubTreeScan );
      K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
      K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsOwnerChildsOnlyScan];
    end;
  end;
  if (ARootUObj.RefCounter > 1) and
     (K_cstfObjNameChanged in ASetFlags) then
  begin
//    ScanObj := TK_ScanUDSubTree.Create();
    with TK_ScanUDSubTree.Create() do
    begin
      BuildParentsList( K_CurArchive, ARootUObj, [K_udtsOwnerChildsOnlyScan, K_udtsRAFieldsScan] );
      for i := 0 to ParentNodes.Count - 1 do
        K_SetChangeSubTreeFlags( TN_UDBase(ParentNodes[i]), [K_cstfSetSLSRChangeFlag] );
      Free;
    end;
  end;
  K_TreeViewsInvalidate();
  
end; //*** end of K_SetChangeSubTreeFlags

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_SetAbsentOwners
//******************************************************* K_SetAbsentOwners ***
// Set references to absent Owners in given IDB Subtree
//
//     Parameters
// ARootUObj - given IDB Subnet Root Object
//
procedure K_SetAbsentOwners( ARootUObj : TN_UDBase );
begin
  K_UDScannedUObjsList := TList.Create;
  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan];

  with ARootUObj do
    ScanSubTree( SetAbsentOwnersScan );

  K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
  K_ClearUObjsScannedFlag();
  FreeAndNil(K_UDScannedUObjsList);
end; //*** end of K_SetAbsentOwners

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_AddSaveLoadFlagsToGlobalFlags
//***************************************** K_AddSaveLoadFlagsToGlobalFlags ***
// Add Save/Load IDB FLags to GLobal IDB Control Flags
//
//     Parameters
// ASaveLoadFlags - new value of save/load flags
// Result         - Returns previous value of GLobal IDB Control Flags for 
//                  future GLobal Flags restore
//
function K_AddSaveLoadFlagsToGlobalFlags( ASaveLoadFlags : TK_UDTreeLSFlagSet = [] ) : TK_UDGControlFlagSet;
begin
  Result := K_UDGControlFlags;
  if ASaveLoadFlags <> [] then
    LongWord(K_UDGControlFlags) :=
//      (LongWord(K_UDGControlFlags) and ($FFFFFFFF shr Ord(K_gcfSkipAllSLSR)))
      (LongWord(K_UDGControlFlags) and K_Masks32[Ord(K_gcfSkipAllSLSR)-1])
      or (Word(ASaveLoadFlags) shl Ord(K_gcfSkipAllSLSR));
end; //*** end of K_AddSaveLoadFlagsToGlobalFlags

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_AddToPUDRefsTable
//***************************************************** K_AddToPUDRefsTable ***
// Add New Pointer to Field with Unresolved Reference to global table
//
//     Parameters
// APUD - pointer to IBD Object references field including objects references in
//        child objects directory
//
procedure K_AddToPUDRefsTable( APUD : TN_PUDBase );
var
  RefTabLeng : Integer;
begin
  with K_UDTreeBuildRefControl do begin
    RefTabLeng := Length(URefPFields);
    Inc(URefCount);
    if RefTabLeng <= URefCount then begin
      // Resize Table
      K_NewCapacity( URefCount, RefTabLeng );
      SetLength( URefPFields, RefTabLeng );
    end;
    URefPFields[URefCount-1] := APUD;
  end;
end; // end_of procedure K_AddToPUDRefsTable

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_CompareAppArchVer
//***************************************************** K_CompareAppArchVer ***
// Compare Application Current Archives format Version with Archive data format 
// Version
//
//     Parameters
// ABinaryArchFormatFlag - Archive binary format flag
// Result                - Returns comparisson result code
//
function K_CompareAppArchVer( ABinaryArchFormatFlag : Boolean ) : TK_CheckAppArchVerResult;
var
//  CurAVer, MinAVer : string;
  ICurAVer, IMinAVer : Integer;
  CR : Integer;
begin
{
  CurAVer := K_ArchInfoList.Values[K_tbArchFmtCurVerID];
  MinAVer := K_ArchInfoList.Values[K_tbArchFmtMinVerID];
  Result := K_cavOK;
  CR := CompareStr( CurAVer, K_ArchCurVer );
  if CR = 0 then Exit
  else if CR > 0 then begin
  // Archive is Newer then Appplication
    if BinaryArchFormat or
       (CompareStr( MinAVer, K_ArchCurVer ) > 0) then
      Result := K_cavNewer;
  end else begin
  // Archive is Older then Appplication
    if BinaryArchFormat or
      (CompareStr( CurAVer, K_ArchMinVer ) < 0) then
      Result := K_cavOlder;
  end;
}
  ICurAVer := StrToIntDef( K_ArchInfoList.Values[K_tbArchFmtCurVerID], 0 );
  Result := K_cavOK;
  CR := ICurAVer - K_SPLDataCurFVer;
  if CR = 0 then Exit
  else if CR < 0 then begin
  // Archive is Older then Appplication
    if ABinaryArchFormatFlag or
      (ICurAVer < K_SPLDataPDNTVer) then
      Result := K_cavOlder;
  end else begin
  // Archive is Newer then Appplication
    IMinAVer := StrToIntDef( K_ArchInfoList.Values[K_tbArchFmtMinVerID], 0 );
    if ABinaryArchFormatFlag or
       (IMinAVer > K_SPLDataNDPTVer) then
      Result := K_cavNewer;
  end;
end; // end_of function K_CompareAppArchVer

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_CheckAppArchVer
//******************************************************* K_CheckAppArchVer ***
// Check Application Archive format version
//
//     Parameters
// AFileName             - Achive file name and path
// ABinaryArchFormatFlag - Archive file binary format flag
//
procedure K_CheckAppArchVer( AFileName : string; ABinaryArchFormatFlag : Boolean );
var
  Mes : string;
begin
  case K_CompareAppArchVer( ABinaryArchFormatFlag ) of
  K_cavOK    : Exit;
  K_cavOlder : Mes := 'old';
  K_cavNewer : Mes := 'new';
  end;
  Mes := 'File ' + AFileName + ' has too ' + Mes + ' format.';
  K_InfoWatch.AddInfoLine( Mes );
  if mrYes <> MessageDlg( Mes + ' Continue loading?',
                         mtConfirmation, [mbYes, mbNo], 0 ) then
    raise TK_LoadUDFileError.Create( Mes );
end; // end_of function K_CheckAppArchVer

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_GetVTreeStateFromMemIni
//*********************************************** K_GetVTreeStateFromMemIni ***
// Get IDB Subnet Visual Tree (VTree) state from aplication ini-file
//
//     Parameters
// AMarkedPathList   - list of relative paths to IDB Subnet Marked Visual Nodes
// AExpandedPathList - list of relative paths to IDB Subnet Expanded Visual 
//                     Nodes
// AIniNamePrefix    - prefix of ini-file sections VTree state info
// Result            - Returns path to IDB VTree Root object
//
function K_GetVTreeStateFromMemIni( AMarkedPathList, AExpandedPathList : TStrings;
                                    AIniNamePrefix : string ) : string;
begin
  N_MemIniToStrings( AIniNamePrefix+'_MPList', AMarkedPathList );
  N_MemIniToStrings( AIniNamePrefix+'_EPList', AExpandedPathList );
  Result := '';
  with AMarkedPathList do
  if Count >= 1 then begin
    Result := Strings[Count-1];
    Delete(Count-1);
  end;
end; //***** end of function K_GetVTreeStateFromMemIni

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_SaveVTreeStateToMemIni
//************************************************ K_SaveVTreeStateToMemIni ***
// Save IDB Subnet Visual Tree (VTree) state to aplication ini-file
//
//     Parameters
// AMarkedPathList   - list of relative paths to IDB Subnet Marked Visual Nodes
// AExpandedPathList - list of relative paths to IDB Subnet Expanded Visual 
//                     Nodes
// ARootPath         - path to IDB VTree Root object
// AIniNamePrefix    - prefix of ini-file sections VTree state info
//
procedure K_SaveVTreeStateToMemIni( AMarkedPathList, AExpandedPathList : TStrings;
                                    const ARootPath, AIniNamePrefix : string );
begin
  AMarkedPathList.Add( ARootPath );
  N_StringsToMemIni  ( AIniNamePrefix+'_MPList', AMarkedPathList );
  N_StringsToMemIni  ( AIniNamePrefix+'_EPList', AExpandedPathList );
end; //***** end of function K_SaveVTreeStateToMemIni

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_GetPathToUObj
//********************************************************* K_GetPathToUObj ***
// Get path to given IDB object
//
//     Parameters
// AUObj              - given IDB object path to which is needed
// ARootUObj          - root IDB object for relative path
// AObjNameType       - path segments name type (ObjName,ObjAliase etc.)
// APathTrackingFlags - flags set to control IDB path tracking
//
// If ARootUObj is nil then owners Subtree absolute (including IDB Cursor name) 
// IDB path will be build. Path tracking flags K_ptfScanRAFields and 
// K_ptfScanRAFieldsSubTree act only if K_ptfSkipScanOwners flag is given. If 
// try to track relative owners path to IDB object which is not in root object 
// Owners Subtree and K_ptfSkipOwnersAbsPath in APathTrackingFlags then empty 
// path returns.
//
function K_GetPathToUObj( AUObj : TN_UDBase; ARootUObj : TN_UDBase = nil;
                          AObjNameType : TK_UDObjNameType = K_ontObjName;
                          APathTrackingFlags : TK_PathTrackingFlags =
                          [K_ptfSkipOwnersAbsPath, K_ptfTryAltRelPath] ) : string;
var
  PathList : TStringList;
  PathPrefix : string;
  SkipAbsolutePath : Boolean;
  SrcUObj : TN_UDBase;

label AbsentOwner;
begin
  Result := '';
  if (ARootUObj <> nil) and (K_ptfSkipScanOwners in APathTrackingFlags) then
  begin
  //*** Not Owners path tracking
    if  not (K_ptfScanRAFields in APathTrackingFlags) then
      K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsRAFieldsScan]
    else if K_ptfScanRAFieldsSubTree in APathTrackingFlags then
      K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsSkipRAFieldsSubTreeScan];

    K_UDScannedUObjsList := Tlist.Create;
    Result := ARootUObj.GetPathToUDObj( AUObj, AObjNameType );
    K_ClearUObjsScannedFlag;
    FreeAndNil( K_UDScannedUObjsList );

    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags + [K_udtsRAFieldsScan];
    K_UDTreeChildsScanFlags := K_UDTreeChildsScanFlags - [K_udtsSkipRAFieldsSubTreeScan];
  //*** end of Not Owners path tracking
  end
  else
  begin
    if AUObj = nil then Exit;
    PathList := TStringList.Create;
    PathList.Delimiter := K_udpPathDelim;
    PathPrefix := '';
    SkipAbsolutePath := false;
    SrcUObj := AUObj;
    if ARootUObj = nil then
    begin
    //*** Absolute path build
      while (AUObj.RefPath = '') do
      begin
        PathList.Insert(0, AUObj.GetUName( AObjNameType ) );
        if AUObj.Owner = nil then
        begin
AbsentOwner:
          K_ShowMessage( 'Absent owner found in object "' + AUObj.ObjName +
            '" AbsPath Path="' +
             K_GetPathToUObj( AUObj, K_MainRootObj, K_ontObjName, [K_ptfSkipScanOwners]) + '"',
             Application.Title,  K_msError );
           SkipAbsolutePath := false;
           Break;
        end;
        AUObj := AUObj.Owner;
      end;
      PathPrefix := AUObj.RefPath;
    //*** end of Absolute path build
    end
    else
    begin
    //*** Relative Owners path
      SkipAbsolutePath := AUObj = ARootUObj;
      if not SkipAbsolutePath then
        repeat
          PathList.Insert(0, AUObj.GetUName( AObjNameType ) );
          if AUObj.Owner = nil then goto AbsentOwner;
          AUObj := AUObj.Owner;
          if (AUObj <> ARootUObj)  and
             (AUObj.RefPath <> '') and
             ( (AUObj = K_MainRootObj) or
               (K_ptfBreakByRefPath in APathTrackingFlags) ) then
          begin
            //*** Proper Owners path is not found
            if K_ptfTryAltRelPath in APathTrackingFlags then
            begin
            // Try to build path in full Subnet (not in Ownes Subtree)
              Result := K_GetPathToUObj( SrcUObj, ARootUObj, AObjNameType, [K_ptfSkipScanOwners] );
              SkipAbsolutePath := Result <> '';
              if SkipAbsolutePath then Break;
            end;
            SkipAbsolutePath := K_ptfSkipOwnersAbsPath in APathTrackingFlags;
            PathPrefix := AUObj.RefPath;
            Break;
          end;

        until AUObj = ARootUObj;
    //*** end of Relative Owners path
    end;
    if not SkipAbsolutePath then
      Result := PathPrefix + PathList.DelimitedText;
    PathList.Free;
  end;

  if (Result <> '') and (Result[Length(Result)] = K_udpPathDelim) then
    assert(false, 'Trailing path delimiter is found -> ' + Result );
end; //***** end of K_GetPathToUObj

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_AddUObjToUsedTypesList
//************************************************ K_AddUObjToUsedTypesList ***
// Add given IDB object Type to List of Types Used during data serialization
//
//     Parameters
// AUObj          - given IDB object
// AUsedTypesList - list of Data Types
//
// Do not call K_AddUObjToUsedTypesList directly, it is used automatically in 
// IDB Subnet serialization routines.
//
procedure K_AddUObjToUsedTypesList( AUObj : TN_UDBase; AUsedTypesList : TList );
var
  ObjTypeInd : Integer;
  SPLTypeUObj : TK_UDFieldsDescr;
begin
  if K_DFVCUDBaseToSPLTypesRefs = nil then
    SetLength( K_DFVCUDBaseToSPLTypesRefs, N_ClassRefArrayMaxInd + 1 );
  ObjTypeInd := AUObj.CI;
  SPLTypeUObj := TK_UDFieldsDescr( K_DFVCUDBaseToSPLTypesRefs[ObjTypeInd] );
  if SPLTypeUObj = nil then begin // ObjType is not checked
//    if (AUObj.ClassFlags and K_RArrayObjBit) = 0 then begin
    if not K_IsUDRArray( AUObj ) then begin
    // Object is not UDRarray - get referenced SPL Type
      SPLTypeUObj := K_GetTypeCode( AUObj.ClassName ).FD;
      if Integer(SPLTypeUObj) < Ord(nptNoData) then // TN_UDBase
        Integer(SPLTypeUObj) := -1;
    end else
    // Object is UDRArray type info will be added later
      Integer(SPLTypeUObj) := -1;
    K_DFVCUDBaseToSPLTypesRefs[ObjTypeInd] := SPLTypeUObj;
  end;

  if (Integer(SPLTypeUObj) = -1) or             // no reference to SPL Type
     (SPLTypeUObj.FDFUTListInd <> 0) then Exit; // SPLType is already added

  // Add SPL Type to UsedTypesList
  AUsedTypesList.Add( SPLTypeUObj );
  SPLTypeUObj.FDFUTListInd := AUsedTypesList.Count;

end; //***** end of K_AddUObjToUsedTypesList

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ClearUsedTypesMarks
//*************************************************** K_ClearUsedTypesMarks ***
// Clear Types Used Marks done during data serialization List Info
//
//     Parameters
// AUsedTypesList - list of Data Types
//
// Do not call K_ClearUsedTypesMarks directly, it is used automatically in IDB 
// Subnet serialization routines.
//
procedure K_ClearUsedTypesMarks( AUsedTypesList : TList );
var
  i : Integer;
begin
  for i := AUsedTypesList.Count - 1 downto 0 do begin
    TK_UDFieldsDescr(AUsedTypesList[i]).FDFUTListInd := 0;
    AUsedTypesList.Delete(i);
  end;
end; //*** end of K_ClearUsedTypesMarks

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_ShowFmtVerErrorMessageDlg
//********************************************* K_ShowFmtVerErrorMessageDlg ***
// Show data format version erorr dialogue
//
//     Parameters
// ASourceName - serialized data source name
// AFmtVerCode - data maximal format version code
// AFmtErrInfo - list data type names and format version codes
//
// Do not call K_ShowFmtVerErrorMessageDlg directly, it is used automatically in
// IDB Subnet serialization routines.
//
procedure K_ShowFmtVerErrorMessageDlg( AFmtVerCode : Integer; ASourceName : string; AFmtErrInfo : TStrings );
var
//  i : Integer;
  FmtVerComp : string;
begin
  if AFmtVerCode = 0 then Exit;
  FmtVerComp := 'too old';
  if AFmtVerCode > 0 then
    FmtVerComp := 'too new';
  AFmtErrInfo.Insert( 0, 'Source "' + ASourceName + '" --> Data Format Errors' );
//  K_InfoWatch.AddInfoLine( AFmtErrInfo.Text, 0 );
  N_Dump1Str( AFmtErrInfo.Text );
  if not (K_gcfSkipErrMessages in K_UDGControlFlags) then
  begin
    if MessageDlg( AFmtErrInfo[0] + #$D + #$A +
                   'Common format version is ' + FmtVerComp +
                   '. Show detailes?', mtWarning, mbOKCancel, 0 ) = mrOk then
      K_GetFormTextEdit.EditStrings( AFmtErrInfo, 'Data Format Errors' );
  end;
{
  for i := 0 to AFmtErrInfo.Count - 1 do begin
    FmtVerComp := 'older';
    case Integer(AFmtErrInfo.Objects[i]) of
      0: FmtVerComp := ' is absent';
      1: FmtVerComp := ' format is newer';
     -1: FmtVerComp := ' format is older';
    end;
    AFmtErrInfo[i] := 'Type ' + AFmtErrInfo[i] + FmtVerComp;
  end;
  K_GetFormTextEdit.EditStrings( AFmtErrInfo, 'Data Format Errors' );
}
end; //*** end of K_ShowFmtVerErrorMessageDlg

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_PrepareUDFilterAllowed
//************************************************ K_PrepareUDFilterAllowed ***
// Prepare UDFilter by IDB objects allowed Type Codes array
//
//     Parameters
// AUDFilter  - IDB Objects select filter to prepare
// AObjCTypes - array of IDB objects allowed Type Codes
// Result     - Returns rebuild IDB Objects select filter
//
// Create resulting filter if needed
//
function  K_PrepareUDFilterAllowed( var AUDFilter : TK_UDFilter;
                                    AObjCTypes : array of LongWord ) : TK_UDFilter;
var i : Integer;
begin

  if AUDFilter = nil then
    AUDFilter := TK_UDFilter.Create;

  for i := 0 to High(AObjCTypes) do
    if AObjCTypes[i] <> 0 then
      AUDFilter.AddItem( TK_UDFilterClassSect.Create( AObjCTypes[i] ) );
  Result := AUDFilter;
end; //*** end of K_PrepareUDFilterAllowed

//##path K_Delphi\SF\K_clib\K_UDT1.pas\K_PrepareUDFilterNotAllowed
//********************************************* K_PrepareUDFilterNotAllowed ***
// Prepare UDFilter by IDB objects not allowed Type Codes array
//
//     Parameters
// AUDFilter  - IDB Objects select filter to prepare
// AObjCTypes - array of IDB objects not allowed Type Codes
// Result     - Returns rebuild IDB Objects select filter
//
// Create resulting filter if needed
//
function  K_PrepareUDFilterNotAllowed( var AUDFilter : TK_UDFilter;
                                       AObjCTypes : array of LongWord ) : TK_UDFilter;
var i : Integer;
begin

  if AUDFilter = nil then
    AUDFilter := TK_UDFilter.Create;

  AUDFilter.AddItem( TK_UDFilterClassSect.Create( AObjCTypes[0], 0, K_ifcNotOr ) );
  for i := 1 to High(AObjCTypes) do
    if AObjCTypes[i] <> 0 then
      AUDFilter.AddItem( TK_UDFilterClassSect.Create( AObjCTypes[i], 0, K_ifcNotAnd ) );
  Result := AUDFilter;
end; //*** end of K_PrepareUDFilterNotAllowed

//********** TN_VTreeFrame class methods  **************

//********************************************** TN_VTreeFrame.Create ***
//
constructor TN_VTreeFrame.Create( AOwner: TComponent );
begin
  inherited Create( AOwner);
  MultiMark := true;
  Parent := TWinControl( AOwner );
  TreeView.DoubleBuffered := true;
  TreeView.OnCustomDrawItem := TVDrawItem;      // event handler
//  TreeView.OnCustomDraw := OnTVDraw1;          // event handler
  TreeView.OnDeletion := TVDeletion;             // event handler
//  TreeView.OnChange := OnChangeTreeViewItem;
  AllExpandingMode := false;
  ToggleNodesPMark.Enabled := false;
end; // end_of constructor TN_VTreeFrame.Create

//******************************************** TN_VTreeFrame.Destroy ***
//
destructor TN_VTreeFrame.Destroy;
begin
  if N_ActiveVTree = VTree then N_ActiveVtree := nil;
  if VTree <> nil then VTree.Delete( );
  VTree := nil;
  inherited Destroy;
end; // end_of destructor TN_VTreeFrame.Destroy

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeFrame\CreateVTree
//*********************************************** TN_VTreeFrame.CreateVTree ***
// Create Visual Tree
//
//     Parameters
// ARootUObj   - root IDB object sets IDB Subnet for visualization
// AViewFlags  - view flags control future VNodes and corresponding TreeNodes 
//               creation and view
// AVTDepth    - Visual Tree depth (if =0 then no depth control done)
// AVFlagsNum  - index of IDB object individual view flags set (0 or 1)
// ATestDEFunc - function of object for checking IDB directory entry before 
//               including to Visual Tree
//
procedure TN_VTreeFrame.CreateVTree(  ARootUObj: TN_UDBase = nil;
                                      AViewFlags : integer = -1;
                                      AVTDepth       : integer = 0;
                                      AVFlagsNum    : integer = 0;
                                      ATestDEFunc   : TK_TestDEFunc = nil );
begin
  if AViewFlags = -1 then
    AViewFlags := K_fvTreeViewTextEdit;
  if VTree <> nil then VTree.Delete();
  VTree := TN_VTree.Create( TreeView, ARootUObj, AViewFlags, AVTDepth,
                            AVFlagsNum, ATestDEFunc );
  ToggleNodesPMark.Enabled := true;

end; //***** end of procedure TN_VTreeFrame.CreateVTree

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeFrame\RebuildVTree(_full_)
//************************************** TN_VTreeFrame.RebuildVTree( full ) ***
// Rebuild frame Visual Tree state by given root IDB object, marked objects 
// paths list and expanded objects paths list
//
//     Parameters
// ARootUObj         - new VTree root IDB Object
// AMarkedPathList   - list of paths to marked VNodes
// AExpandedPathList - list of paths to expanded VNodes
//
procedure TN_VTreeFrame.RebuildVTree( ARootUObj : TN_UDBase; AMarkedList : TStrings = nil;
                                      AExpandedList : TStrings = nil );
var
  VNode : TN_VNode;
begin
  StepUp.Enabled := ARootUObj.Owner <> nil;
  K_TreeViewsUpdateModeSet;
  EdName.Visible := false;
  if VTree = nil then CreateVTree;
  VNode := VTree.RebuildView( ARootUObj, AMarkedList, AExpandedList );
  K_TreeViewsUpdateModeClear( false );
  if Assigned(VNode) then
    VTree.TreeView.TopItem := VNode.VNTreeNode;

end; //***** end of procedure TN_VTreeFrame.RebuildVTree

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeFrame\RebuildVTree(_brief_)
//************************************* TN_VTreeFrame.RebuildVTree( brief ) ***
// Rebuild frame Visual Tree state by given root IDB object and expanded path
//
//     Parameters
// ARootUObj     - new VTree root IDB Object
// AExpandedPath - expanded path string
//
procedure TN_VTreeFrame.RebuildVTree( ARootUObj : TN_UDBase; AExpandedPath : string );
//var
//  VNode : TN_VNode;
begin
  RebuildVTree( ARootUObj, nil, nil );
  if AExpandedPath <> '' then
    VTree.SetPath( AExpandedPath, true );
{
  StepUp.Enabled := UDRoot.Owner <> nil;
  K_TreeViewsUpdateModeSet;
  Init;
  VNode := VTree.RebuildView( UDRoot, nil, ExpandedList );
  if IniPath <> '' then
    VTree.SetPath( IniPath, true );
  K_TreeViewsUpdateModeClear( false );
  if Assigned(VNode) then
    VTree.TreeView.TopItem := VNode.TreeNode;
}
end; //***** end of procedure TN_VTreeFrame.RebuildVTree

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeFrame\FrSetCurState
//********************************************* TN_VTreeFrame.FrSetCurState ***
// Set frame state by given root IDB object or it's path, marked objects paths 
// list and expanded objects paths list
//
//     Parameters
// ARootPath         - path to new VTree root IDB Object
// AMarkedPathList   - list of paths to marked VNodes
// AExpandedPathList - list of paths to expanded VNodes
// ADefaultRoot      - default root VTree IDB Object if main root object is not 
//                     defined
// ARootUObj         - new VTree root IDB Object
//
procedure TN_VTreeFrame.FrSetCurState( const ARootPath : string; AMarkedPathList,
                  AExpandedPathList : TStrings; ADefaultRoot : TN_UDBase = nil;
                  ARootUObj : TN_UDBase = nil );
begin
  if ARootUObj = nil then
  begin
    ARootUObj := K_MainRootObj.GetObjByRPath(ARootPath);
    if (ARootUObj = nil) or (ARootPath = '') then
    begin
      ARootUObj := ADefaultRoot;
      if ARootUObj = nil then
        ARootUObj := K_MainRootObj;
    end;
  end;
  RebuildVTree( ARootUObj, AMarkedPathList, AExpandedPathList );
end; //***** end of procedure TN_VTreeFrame.FrSetCurState

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeFrame\FrGetCurState
//********************************************* TN_VTreeFrame.FrGetCurState ***
// Get frame current state
//
//     Parameters
// AMarkedPathList   - list for paths to marked VNodes
// AExpandedPathList - list for paths to expanded VNodes
//
function TN_VTreeFrame.FrGetCurState( AMarkedPathList, AExpandedPathList : TStrings ) : string;
//var
//  RPRoot : TN_UDBase;
begin
  Result := '';
  if VTree = nil then Exit;
  Result := VTree.GetCurState( AMarkedPathList, AExpandedPathList );
end; //***** end of function TN_VTreeFrame.FrGetCurState

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeFrame\FrCurStateToMemIni
//**************************************** TN_VTreeFrame.FrCurStateToMemIni ***
// Save frame current state to aplication ini-file
//
//     Parameters
// AIniNamePrefix - frame atributes name prefix in appplication ini-file
// ARootPath      - new path to frame VTRee root IDB object (can be used for 
//                  future restore frame state from ini-file)
//
// Frame Attributes ar stored in two ini-file sections. Paths to marked IDB 
// objects list and path to selected IDB object are stored in 
// [<NamePrefix>+'_MPList']. Paths to expanded IDB objects list and path to top 
// IDB object are stored in [<NamePrefix>+'_EPList'].
//
procedure TN_VTreeFrame.FrCurStateToMemIni( AIniNamePrefix : string = ''; ARootPath : string = '' );
var
  MarkedPathList, ExpandedPathList : TStrings;
  RPath : string;
begin
  MarkedPathList := TStringList.Create;
  ExpandedPathList := TStringList.Create;
  RPath := FrGetCurState( MarkedPathList, ExpandedPathList );
  if ARootPath = '' then ARootPath := RPath;
  if AIniNamePrefix = '' then AIniNamePrefix := Owner.Name;
  K_SaveVTreeStateToMemIni( MarkedPathList, ExpandedPathList,
                                ARootPath, AIniNamePrefix );
  MarkedPathList.Free;
  ExpandedPathList.Free;
end; //***** end of procedure TN_VTreeFrame.FrCurStateToMemIni

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeFrame\FrMemIniToCurState
//**************************************** TN_VTreeFrame.FrMemIniToCurState ***
// Restore frame current state from aplication ini-file
//
//     Parameters
// AIniNamePrefix - frame atributes name prefix in appplication ini-file
// ADefaultRoot   - default root VTree IDB Object if main root object is not 
//                  defined
// ARootUObj      - new VTree root IDB Object
//
// Frame Attributes ar stored in two ini-file sections. Paths to marked IDB 
// objects list and path to selected IDB object are stored in 
// [<NamePrefix>+'_MPList']. Paths to expanded IDB objects list and path to top 
// IDB object are stored in [<NamePrefix>+'_EPList'].
//
procedure TN_VTreeFrame.FrMemIniToCurState( AIniNamePrefix : string = '';
                                            ADefaultRoot : TN_UDBase = nil;
                                            ARootUObj : TN_UDBase = nil );
var
  MarkedPathList, ExpandedPathList : TStrings;
begin
  MarkedPathList := TStringList.Create;
  ExpandedPathList := TStringList.Create;

  if AIniNamePrefix = '' then AIniNamePrefix := Owner.Name;
  FrSetCurState( K_GetVTreeStateFromMemIni( MarkedPathList, ExpandedPathList, AIniNamePrefix ),
               MarkedPathList, ExpandedPathList, ADefaultRoot, ARootUObj );

//  MemIniToState( MarkedPathList, ExpandedPathList, IniNamePrefix ),
//               MarkedPathList, ExpandedPathList, DefaultRoot, UDRoot );

  MarkedPathList.Free;
  ExpandedPathList.Free;
end; //***** end of procedure TN_VTreeFrame.FrMemIniToCurState

{
//**************************************** TN_VTreeFrame.MemIniToState
// Get State from MemIni
//
function TN_VTreeFrame.MemIniToState( MarkedPathList, ExpandedPathList : TStrings;
                                         IniNamePrefix : string = '' ) : string;
begin
  if IniNamePrefix = '' then IniNamePrefix := Owner.Name;
  Result := K_GetVTreeStateFromMemIni( MarkedPathList, ExpandedPathList, IniNamePrefix );
end; //***** end of function TN_VTreeFrame.MemIniToState
}

//**************************************** TN_VTreeFrame.TVDeletion ***
// TreeView OnDeletion event handler
//
procedure TN_VTreeFrame.TVDeletion( Sender: TObject; TNode: TTreeNode );
begin
  {$IFDEF N_DEBUG}
  N_AddDebString( 2, 'onDeletion TN=$' + IntToHex( Integer(TNode), 8) +
   ' name="'+TNode.Text+'"' );
  {$ENDIF}
  if TNode.Data <> nil then
    TN_VNode(TNode.Data).VNTreeNode := nil; // "TreeNode is deleting" flag
end; //***** end of procedure TN_VTreeFrame.TVDeletion

//**************************************** TN_VTreeFrame.TVStartDrag ***
// TreeView OnStartDrag event handler
//
procedure TN_VTreeFrame.TVStartDrag( Sender: TObject; var DragObject: TDragObject );
begin
end; //***** end of procedure TN_VTreeFrame.TVStartDrag

//**************************************** TN_VTreeFrame.TVItemExpanding ***
// TreeView OnItemExpanding event handler
//
procedure TN_VTreeFrame.TVItemExpanding(Sender: TObject; TNode: TTreeNode; var AllowExpansion: Boolean);
var
  DE : TN_DirEntryPar;
  Ind : Integer;
label LExit;
begin
  if (N_CPUCounter - VTree.TreeViewClickTimeCount)/N_CPUFrequency < 1.0 then
  begin
    AllowExpansion := false;
    Exit;
  end;

  VTree.ChangeTreeViewUpdateMode(true);
  with TN_VNode(TNode.Data) do
  begin
    if not AllExpandingMode then
    begin
      if N_KeyIsDown(VK_MENU) and
         ( N_KeyIsDown(VK_SHIFT) or
           N_KeyIsDown(VK_CONTROL) ) then
      begin
        AllExpandingMode := true;
        K_UDLoopProtectionList.Clear;
        if N_KeyIsDown(VK_SHIFT) then
          VTree.TreeView.FullExpand
        else
          TNode.Expand(True);
        AllExpandingMode := false;
        K_UDLoopProtectionList.Clear;
        goto LExit;
      end;
    end;

//*** Build VChilds for expanding Node
    if (not TNode.Expanded) and
       (TNode.GetFirstChild.Data = nil) then
    begin //*** test if Real Child building needed
      GetDirEntry ( DE );
      if not AllExpandingMode or
         (K_UDLoopProtectionList.IndexOf(DE.Child) = -1) then begin
        if AllExpandingMode then
          K_UDLoopProtectionList.Add(DE.Child);
        TNode.DeleteChildren;
        Ind := -1;
//        VNAttr := VNAttr and not K_fVNodeStateNotExanded;
        VNState := VNState - [K_fVNodeStateNotExanded];
        CreateChildVNodes( Ind );
      end
      else
        AllowExpansion := false;
    end;
  end;
LExit:
  VTree.ChangeTreeViewUpdateMode(false);
end; // end of TN_VTreeFrame.TVItemExpanding


//**************************************** TN_VTreeFrame.TVItemCollapsing ***
// TreeView OnItemCollapsing event handler
//
procedure TN_VTreeFrame.TVItemCollapsing(Sender: TObject; TNode: TTreeNode; var AllowCollapse: Boolean);
begin
  if (N_CPUCounter - VTree.TreeViewClickTimeCount)/N_CPUFrequency < 1.0 then begin
    AllowCollapse := false;
    Exit;
  end;

  with TN_VNode(TNode.Data).VNVTree do begin
    if not AllExpandingMode then begin
      if N_KeyIsDown(VK_SHIFT) or
         N_KeyIsDown(VK_CONTROL) then begin
        ChangeTreeViewUpdateMode(true);
        AllExpandingMode := true;
        if N_KeyIsDown(VK_SHIFT) then
          TreeView.FullCollapse
        else
          TNode.Collapse(True);
        AllExpandingMode := false;
        ChangeTreeViewUpdateMode(false);
      end;
    end;
  end;
end; // end of TN_VTreeFrame.TVItemCollapsing

{
//**************************************** TN_VTreeFrame.OnChangeTreeViewItem ***
// TreeView OnItemChange event handler
//
procedure TN_VTreeFrame.OnChangeTreeViewItem( Sender: TObject; TNode: TTreeNode );
begin
  VTree.SetSelectedVNode( TN_VNode(TNode.Data) );
end; // end of TN_VTreeFrame.OnChangeTreeViewItem
}

//**************************************** TN_VTreeFrame.TVMouseMove
// TreeView MouseMove event handler
//
procedure TN_VTreeFrame.TVMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  CurMouseNode : TTreeNode;
begin
  CurMouseNode := TreeView.GetNodeAt( X, Y );
  if CurMouseNode = nil then
  begin
    TreeView.ShowHint := false;
    Exit;
  end;

  with TN_VNode(CurMouseNode.Data).VNUDObj do
    if (VTree.VTPrevHintTTNode = CurMouseNode) and (ObjInfo <> '') then
    begin
      TreeView.Hint := ObjInfo;
      TreeView.ShowHint := true;
    end
    else
      TreeView.ShowHint := false;

  VTree.VTPrevHintTTNode := CurMouseNode;
end; // end of TN_VTreeFrame.TVMouseMove

//*********************************************** TN_VTreeFrame.TVDrawItem ***
// change Node.Text font and color for normal, marked and selected nodes
// ( ONCustomDrawItem event handler in DefaultDraw = True mode )
//
procedure TN_VTreeFrame.TVDrawItem( Sender: TCustomTreeView; TNode: TTreeNode;
                            State: TCustomDrawState; var DefaultDraw: Boolean);
var
  Indent: integer;
  NodeRect: TRect;
  MRect: TRect;
  TextShift : Integer;
  FButtonSize : Integer;
  ImgInd, TextStart : Integer;
  DrawLines : Boolean;
  MarkedSelectedState : Integer;
  BrushSave : TBrushRecall;
  PenSave   : TPenRecall;
  x1, y1 : Integer;
  CurStyle : TK_VTreeStyle;

  procedure N_DrawButton(ARect: TRect; ATNode: TTreeNode);
  var
    hfin, cx, cy: Integer;
  begin
    cx := ARect.Left + Indent shr 1;
    cy := ARect.Top + (ARect.Bottom - ARect.Top) shr 1;
    with ATNode.TreeView.Canvas do
    begin
      //draw horizontal line.
      Pen.Color := CurStyle.VTSTreeLinesColor;
      hfin := cx + FButtonSize + TextStart - 2;
//      hfin := cx + FButtonSize + TextStart - 5;
      if DrawLines then
      begin
        if ATNode.HasChildren then
        begin
          PenPos := Point(cx+FButtonSize, cy);
          LineTo(hfin, cy);
        end else
        begin
          PenPos := Point(cx, cy);
          LineTo(hfin, cy);
        end;

        //draw half vertical line, top portion.
        if (ATNode.Parent <> nil) or
           (ATNode.GetPrevSibling <> nil) then
        begin
          PenPos := Point(cx, cy);
          LineTo(cx, ARect.Top-1);
        end;

        if ATNode.GetNextSibling <> nil then
        begin
        //draw bottom portion of half vertical line.
          PenPos := Point(cx, cy+FButtonSize);
          LineTo(cx, ARect.Bottom+1);
        end;
      end;

      if ATNode.HasChildren then
      begin
        //Let's try a circular button instead
        Pen.Color := CurStyle.VTSButtonBorderColor;
        Ellipse(cx-FButtonSize, cy-FButtonSize, cx+FButtonSize+1, cy+FButtonSize+1);
        Pen.Color := CurStyle.VTSTreeLinesColor;
//        Rectangle(cx-FButtonSize, cy-FButtonSize, cx+FButtonSize, cy+FButtonSize);

        //draw add vertical line,  top portion.
        if (ATNode.GetPrevSibling <> nil) and DrawLines then
        begin
          PenPos := Point(cx, cy-FButtonSize-1);
          LineTo(cx, ARect.Top);
        end;
        //draw the horizontal indicator.
        Pen.Color := CurStyle.VTSButtonSignColor;
        PenPos := Point(cx-FButtonSize+3, cy);
        LineTo(cx+FButtonSize-2, cy);
        //draw the vertical indicator if the node is collapsed
        if not ATNode.Expanded then
        begin
          PenPos := Point(cx, cy-FButtonSize+3);
          LineTo(cx, cy+FButtonSize-2);
          Pen.Color := CurStyle.VTSTreeLinesColor;
        end
        else
        if DrawLines then
        begin
          Pen.Color := CurStyle.VTSTreeLinesColor;
          //draw add vertical line,  botom portion.
          PenPos := Point(cx + Indent, cy);
          LineTo(cx + Indent, ARect.Bottom+1);
        end;
      end
      else
      if DrawLines then
      begin
        if (ATNode.GetNextSibling <> nil) then
        begin
        //draw bottom portion of half vertical line.
          PenPos := Point(cx, cy);
          LineTo(cx, ARect.Bottom+1);
        end;
        Pen.Color := CurStyle.VTSButtonBorderColor;
        Ellipse(cx-FButtonSize+3, cy-FButtonSize+3, cx+FButtonSize-2, cy+FButtonSize-2);
        Pen.Color := CurStyle.VTSTreeLinesColor;
      end;

      //now connect vertical lines of higher level nodes.
      if not DrawLines then Exit;
      ATNode := ATNode.Parent;
      while ATNode <> nil do
      begin
        cx := cx - Indent;
        if ATNode.GetNextSibling <> nil then
        begin
          PenPos := Point(cx, ARect.Top);
          LineTo(cx, ARect.Bottom);
        end;
        ATNode := ATNode.Parent;
      end;
    end;
  end;

begin
//    DefaultDraw := True;
  DefaultDraw := False;
  Indent := TTreeView(TNode.TreeView).Indent;
  FButtonSize := 6;
  TextStart := 8;

{error search debug code 18.07.2007}
if (TNode.Data = nil) then
begin
//*** Draw Node Temporary Mark
{
    NodeRect := TNode.DisplayRect(False);
    Sender.Canvas.FillRect(NodeRect);

    NodeRect := TNode.DisplayRect(true);
    NodeRect.Left := NodeRect.Left - (2 * Indent);
    DrawLines := true;
    N_DrawButton( NodeRect, TNode );
}
  Exit;
end;
{error search debug code}


  with Sender.Canvas, TN_VNode(TNode.Data) do
  begin
//*** set draw attributes
//    if (K_vtfsUseObjDisabledFlag in K_VTreeFrameShowFlags) and
    if ((VNUDObj.ObjFlags and K_fpObjTVDisabled) <> 0) then
    begin
      CurStyle := K_VTreeDisabledStyle;
    end
    else
    begin
      MarkedSelectedState := 0;
      if K_fVNodeStateMarked in VNState then
        MarkedSelectedState := 1;
      if K_fVNodeStateSelected in VNState then
        MarkedSelectedState := MarkedSelectedState + 2;
      case MarkedSelectedState of
        1: // K_fVNodeStateMarked
          CurStyle := K_VTreeMarkedStyle;
        2: // K_fVNodeStateSelected
          CurStyle := K_VTreeSelectedStyle;
        3: // [K_fVNodeStateMarked, K_fVNodeStateSelected]
          CurStyle := K_VTreeSelAndMarkStyle;
      else
        if ((VNUDObj.ObjFlags and K_fpObjTVSpecMark1) <> 0) then
          CurStyle := K_VTreePermMark1Style
        else
          CurStyle := K_VTreeMainStyle;
      end;
    end;

//*** normal (not marked, not selected)
    Brush.Color := CurStyle.VTSBGColor;
    Font.Color  := CurStyle.VTSTextColor;
    Font.Style  := CurStyle.VTSFontStyles;


//*** Draw Node Temporary Mark
    NodeRect := TNode.DisplayRect(False);
    FillRect(NodeRect);

    NodeRect := TNode.DisplayRect(true);
    NodeRect.Left := NodeRect.Left - (2 * Indent);

    TextShift := NodeRect.Left  + (FButtonSize shl 1) + 1 + TextStart;

//*** Draw Node Permanent Mark (not CheckBox)
    if (VNUDObj.ClassFlags and K_PermVizMarkBit) <> 0 then
    begin
      MRect := NodeRect;
      MRect.Top := MRect.Top + 1;
      MRect.Bottom := MRect.Bottom;
      MRect.Left := MRect.Left + 2;
      MRect.Right := MRect.Left + MRect.Bottom - MRect.Top;

      BrushSave := TBrushRecall.Create( Sender.Canvas.Brush );
      Brush.Color := CurStyle.VTSCheckBoxBorderColor;
      FrameRect(MRect);
      BrushSave.Free;
    end;

//*** Draw Node Button
    DrawLines := ((VNVFlags and K_fvTreeViewSkipLines) = 0);
    N_DrawButton( NodeRect, TNode );


//*** Draw Node Permanent Mark (CheckBox)
//    if (K_vtfsUseObjAutoCheckFlag in K_VTreeFrameShowFlags) and
    if ((VNUDObj.ObjFlags and K_fpObjTVAutoCheck) <> 0) then
    begin
      MRect := NodeRect;
      MRect.Top := MRect.Top + 2;
      MRect.Bottom := MRect.Bottom - 1;
      MRect.Left := MRect.Left + Indent + (Indent - MRect.Bottom + MRect.Top) shr 1;
      MRect.Right := MRect.Left + MRect.Bottom - MRect.Top;
      FillRect(MRect);

      BrushSave := TBrushRecall.Create( Brush );
      Brush.Color := CurStyle.VTSCheckBoxBorderColor;

      FrameRect(MRect);
      BrushSave.Free;

      if (VNUDObj.ObjFlags and K_fpObjTVChecked) <> 0 then
      begin
        PenSave := TPenRecall.Create( Pen );
        Pen.Width := 2;
        Pen.Color := CurStyle.VTSCheckBoxSignColor;

//        x1 := Round( (MRect.Left + MRect.Right)/2 );
        x1 := -1 + (MRect.Left + MRect.Right) shr 1;
        y1 := MRect.Bottom - 4;
        MoveTo(x1, y1);
        LineTo(x1 - 2, y1 - 4);
        LineTo(x1 - 3, y1 - 5);
//        MoveTo(x1, y1);
//        LineTo(x1 + 2, y1 - 4);
//        LineTo(x1 + 5, y1 - 7);
        MoveTo(x1, y1);
        LineTo(x1 + 3, y1 - 6);
        LineTo(x1 + 5, y1 - 8);
        PenSave.Free;
      end;
      TextShift := MRect.Right + 3;
    end;

//*** Draw Node Icon
    ImgInd := VNUDObj.GetIconIndex;
    with TTreeView(TNode.TreeView).Images do
    begin
      if not (K_vtfsSkipNodeIcon in K_VTreeFrameShowFlags) and
         (TTreeView(TNode.TreeView).Images <> nil) then
      begin
{
        if (ImgInd > 0) and (ImgInd < Count) then
          Draw( Sender.Canvas,
                    TextShift + 7, NodeRect.Top, ImgInd );

        if VNUDObj.Owner <> VNParent.VNUDObj then // Shortcart
          Draw( Sender.Canvas,
                TextShift - 5, NodeRect.Top, K_VTreeShortCutMarkSIInd)
        else if VNUDObj.RefCounter > 1 then       // Has References
          Draw( Sender.Canvas,
                TextShift - 7 + Width, NodeRect.Top - Height + 8, K_VTreeShortCutMarkSIInd );

        if (VNUDObj.ObjFlags and K_fpObjSLSRFlag) <> 0 then
        begin  // SLSR section
          Draw( Sender.Canvas,
                      TextShift + 7, NodeRect.Top, K_VTreeSLSRMarkSIInd );
          if ((VNUDObj.ClassFlags and K_ChangedSLSRBit) <> 0) then // Was Changed
            Draw( Sender.Canvas,
                      TextShift + 7, NodeRect.Top, K_VTreeSLSRChangedMarkSIInd );
          if (VNUDObj.ObjFlags and K_fpObjSLSRJoin) <> 0 then      // Is joined to Archive
            Draw( Sender.Canvas,
                      TextShift + 7, NodeRect.Top, K_VTreeSLSRJoinedMarkSIInd );
        end;

        if K_fVNodeStateSpecMark1 in VNState then  // VNode Runtime Special Mark
          Draw( Sender.Canvas,
                TextShift+6, NodeRect.Top, K_VTreeDisabledMarkSIInd );
        Inc(TextShift, Width + 13);
}
        if (ImgInd > 0) and (ImgInd < Count) then
          Draw( Sender.Canvas,
                    TextShift, NodeRect.Top, ImgInd );

        if VNUDObj.Owner <> VNParent.VNUDObj then // Shortcart
          Draw( Sender.Canvas,
                TextShift - 12, NodeRect.Top, K_VTreeShortCutMarkSIInd )
        else if VNUDObj.RefCounter > 1 then       // Has References
          Draw( Sender.Canvas,
                TextShift - 14 + Width, NodeRect.Top - Height + 8, K_VTreeShortCutMarkSIInd );

        if (VNUDObj.ObjFlags and K_fpObjSLSRFlag) <> 0 then
        begin  // SLSR section
          Draw( Sender.Canvas,
                      TextShift, NodeRect.Top, K_VTreeSLSRMarkSIInd );
          if ((VNUDObj.ClassFlags and K_ChangedSLSRBit) <> 0) then // Was Changed
            Draw( Sender.Canvas,
                      TextShift, NodeRect.Top, K_VTreeSLSRChangedMarkSIInd );
          if (VNUDObj.ObjFlags and K_fpObjSLSRJoin) <> 0 then      // Is joined to Archive
            Draw( Sender.Canvas,
                      TextShift, NodeRect.Top, K_VTreeSLSRJoinedMarkSIInd );
        end;

        if (K_fVNodeStateSpecMark1 in VNState) then   // VNode Runtime Special Mark
          Draw( Sender.Canvas,
                TextShift-1, NodeRect.Top, K_VTreeDisabledMarkSIInd );

//        if (K_vtfsUseObjDisabledFlag in K_VTreeFrameShowFlags) and // Disabled Marker
        if ((VNUDObj.ObjFlags and K_fpObjTVDisabled) <> 0) then
          Draw( Sender.Canvas,
                TextShift, NodeRect.Top, K_VTreeDisabledMarkSIInd );

        Inc(TextShift, Width + 3);
      end;
    end;

//*** Draw Node text field
//    if VNUDObjRC <> VNUDObj.RefCounter then UpdateTreeNodeCaption;

    if ( K_vtfsShowChangedSubTree in K_VTreeFrameShowFlags ) and
       ( (VNUDObj.ClassFlags and
          (K_ChangedSubTreeBit or K_ChangedSLSRBit)) <> 0 ) then
    begin
      SetBkMode( Handle, OPAQUE );
      SetBkColor( Handle, CurStyle.VTSTextSBGColor );
    end;

    TextOut(TextShift, NodeRect.Top + 2, TNode.Text);

//*** Draw Node Mark 0 as Currrent Parent Child
    if K_fVNodeStateSpecMark0 in VNState then
    begin
      Brush.Color := Pen.Color;
      NodeRect.Right := TextShift + TextWidth(TNode.Text) + 5 ;
      FrameRect(NodeRect);
    end;
  end; //*** end_with TV.Canvas do
end; //***** end of procedure TN_VTreeFrame.TVDrawItem

//**************************************** TN_VTreeFrame.TVEditing ***
// TreeView OnEditing event handler
//
procedure TN_VTreeFrame.TVEditing(Sender: TObject; TNode: TTreeNode;
  var AllowEdit: Boolean);
{
var
  DE : TN_DirEntryPar;
  NodeRect : TRect;
}
begin
  AllowEdit := false;
  if (TNode.Data = nil) or (K_vtfsSkipInlineEdit in K_VTreeFrameShowFlags) then Exit;
  RenameInlineExecute(Sender);
end; //***** end of procedure TN_VTreeFrame.TVEditing

//*********************************************** TN_VTreeFrame.EdNameChange ***
// change edited text event handler
//
procedure TN_VTreeFrame.EdNameChange(Sender: TObject);
begin
  EdName.TabOrder := 1;
end; //***** end of procedure TN_VTreeFrame.EdNameChange


//*********************************************** TN_VTreeFrame.ObjNameEditFin
//
procedure TN_VTreeFrame.ObjNameEditFin( VNode : TN_VNode );
var
  SetFlags : TK_SetChangeSubTreeFlags;
  RR : TN_VTreeNodeRenameResult;
begin
  with VNode, VNUDObj do begin
    RR := [];
    if (RenamingObjName <> ObjName) then
      Include(RR, K_vrrObjName );
    if (RenamingObjAliase <> ObjAliase) then
      Include(RR, K_vrrObjAliase );
    if Assigned(OnRenameProcObj) then OnRenameProcObj( Self, VNode, RR );
    VNode.UpdateTreeNodeCaption;
    SetFlags := [];
    if RR <> [] then
      SetFlags := [K_cstfObjNameChanged];
    K_SetChangeSubTreeFlags( VNUDObj, SetFlags );
  end;
end; //***** end of procedure TN_VTreeFrame.ObjNameEditFin

//*********************************************** TN_VTreeFrame.EdNameExit ***
//
procedure TN_VTreeFrame.EdNameExit(Sender: TObject);
var
  VNode : TN_VNode;

  procedure Compare( var Prev : string; New : string  );
  begin
    if New = Prev then Exit;
    Prev := New;
    ObjNameEditFin( VNode );
  end;

begin
  EdName.Visible := false;
  if (EdName.TabOrder = 1) and (EdName.Tag <> 0) then begin
    VNode := TN_VNode( TTreeNode(EdName.Tag).Data );
    with VNode do begin
      with VNode.VNUDObj do begin
        if (ObjAliase <> '') and
           ((VNVFlags and K_fvTreeViewObjNameAndAliase) = 0) then
          Compare( ObjAliase, EdName.Text )
        else
          Compare( ObjName, EdName.Text )
      end;
    end;
    EdName.Tag := 0;
  end;
end; //***** end of procedure TN_VTreeFrame.EdNameExit

//*********************************************** TN_VTreeFrame.EdNameKeyDown ***
//
procedure TN_VTreeFrame.EdNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  FinishEdit : Boolean;
begin
  FinishEdit := false;
  case Key of
  VK_RETURN:
  begin
    EdName.TabOrder := 1;
    FinishEdit := true;
  end;
  VK_ESCAPE:
  begin
    EdName.TabOrder := 0;
    FinishEdit := true;
  end;
  VK_DOWN, VK_UP :
    FinishEdit := true;
  end;
  if not FinishEdit then Exit;
  EdNameExit(Sender);
  TreeView.SetFocus;

end; //***** end of procedure TN_VTreeFrame.EdNameKeyDown

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeFrame\RenameInlineByVNode
//*************************************** TN_VTreeFrame.RenameInlineByVNode ***
//
//
procedure TN_VTreeFrame.RenameInlineByVNode( VNode: TN_VNode );
var
  NodeRect : TRect;
  AllowEdit : Boolean;

begin
  if VNode = nil then Exit;
  with VNode do begin
    AllowEdit := true;
    with VNUDObj do begin
      if Assigned(OnRenamingProcObj) then OnRenamingProcObj(Self, VNode, AllowEdit );
      if not AllowEdit then Exit;
      RenamingObjName := ObjName;
      RenamingObjAliase := ObjAliase;
      if (ObjAliase <> '') and
         ((VNVFlags and K_fvTreeViewObjNameAndAliase) = 0) then
        EdName.Text := ObjAliase
      else
        EdName.Text := ObjName;
    end;
    NodeRect := VNTreeNode.DisplayRect(true);
    EdName.Top := TreeView.Top + NodeRect.Top + 1;
    EdName.Height := NodeRect.Bottom - NodeRect.Top + 1;
    EdName.Left := TreeView.Left + NodeRect.Left;
    EdName.Width := VNTreeNode.TreeView.ClientWidth - NodeRect.Left;
    EdName.Visible := true;
    EdName.SetFocus;
    EdName.TabOrder := 0;
    EdName.Tag := Integer(VNTreeNode);
  end;
end; //***** end of TN_VTreeFrame.RenameInlineByVNode

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_VTreeFrame\RenameUsingFormByVNode
//************************************ TN_VTreeFrame.RenameUsingFormByVNode ***
//
//
procedure TN_VTreeFrame.RenameUsingFormByVNode( VNode: TN_VNode );
var
  AllowEdit : Boolean;
begin
//
  if VNode = nil then Exit;
  with VNode do begin
    AllowEdit := true;
    if Assigned(OnRenamingProcObj) then OnRenamingProcObj(Self, VNode, AllowEdit );
    if not AllowEdit then Exit;
    RenamingObjName := VNUDObj.ObjName;
    RenamingObjAliase := VNUDObj.ObjAliase;
    if K_EditUDNameAndAliase( VNUDObj ) then
      ObjNameEditFin( VNode );
  end;
end; //***** end of TN_VTreeFrame.RenameUsingFormByVNode

//*********************************************** TN_VTreeFrame.RenameInlineExecute
//
procedure TN_VTreeFrame.RenameInlineExecute(Sender: TObject);
begin
  RenameInlineByVNode( VTree.Selected );
end; //***** end of TN_VTreeFrame.RenameInlineExecute

//*********************************************** TN_VTreeFrame.RenameFormExecute
//
procedure TN_VTreeFrame.RenameFormExecute( Sender: TObject );
begin
  RenameUsingFormByVNode( VTree.Selected );
end; //***** end of TN_VTreeFrame.RenameFormExecute

//*********************************************** TN_VTreeFrame.StepUpExecute
//
procedure TN_VTreeFrame.StepUpExecute(Sender: TObject);
var
  NewRoot : TN_UDBase;
  MVNList, EVNList : TStrings;
  i : Integer;
begin
  NewRoot := VTree.RootUObj.Owner;
  if NewRoot = nil then Exit;
//*** Prepare Marked Nodes List
  MVNList := TStringList.Create;
  VTree.GetMarkedPathStrings(MVNList);
  for i := 0 to MVNList.Count - 1 do
    MVNList[i] := VTree.RootUObj.ObjName + K_udpPathDelim + MVNList[i];

//*** Prepare Expanded Nodes List
  EVNList := TStringList.Create;
  VTree.GetExpandedPathStrings( EVNList );
  for i := 0 to EVNList.Count - 1 do
    EVNList[i] := VTree.RootUObj.ObjName + K_udpPathDelim + EVNList[i];

  RebuildVTree( NewRoot, MVNList, EVNList );
  MVNList.Free;
  EVNList.Free;
end; //***** end of TN_VTreeFrame.StepUpExecute

//*********************************************** TN_VTreeFrame.StepDownExecute
//
procedure TN_VTreeFrame.StepDownExecute(Sender: TObject);
var
  MVNList, EVNList : TStrings;
  RootPathLength, h, j : Integer;
  RootPath, WPath : string;
  procedure PrepPathList( PathList : Tstrings );
  var
    i : Integer;
  begin
    j := 0;
    h := PathList.Count - 1;
    for i := 0 to h do begin
      WPath := PathList[i];
//      if (RootPath <> WPath) and AnsiStartsStr( RootPath, WPath ) then begin
      if (RootPath <> WPath) and K_StrStartsWith( RootPath, WPath, true ) then begin
        PathList[j] := Copy( WPath, RootPathLength, Length( WPath ) );
        Inc(j);
      end;
    end;
    for i := h downto j do
      PathList.Delete( i );
  end;

begin
  if VTree.Selected = nil then Exit;
  MVNList := TStringList.Create;
  EVNList := TStringList.Create;
  VTree.GetMarkedPathStrings( MVNList );
  VTree.GetExpandedPathStrings( EVNList );
//*** Get Root Path
  j := MVNList.Count - 1;
  RootPath := MVNList[j];
  RootPathLength := Length( RootPath ) + 2;
  MVNList.Delete( j );
//*** Prepare Marked Paths List
  PrepPathList( MVNList );
  j := MVNList.Count - 1;
  if( j >= 0 ) then MVNList.Add( MVNList[j] ); // Doubled Last Path for Selected

//*** Prepare Expanded Paths List
  PrepPathList( EVNList );

  RebuildVTree( VTree.Selected.VNUDObj, MVNList, EVNList );
  MVNList.Free;
  EVNList.Free;
end; //***** end of TN_VTreeFrame.StepDownExecute

//************************************************ TN_VTreeFrame.MoveNodeUPExecute
//
procedure TN_VTreeFrame.MoveNodeUPExecute(Sender: TObject);
begin
  VTree.MoveSelectedObject( -1 );
end; //*** end of procedure TK_FormMVDar.MoveNodeUPExecute

//************************************************ TN_VTreeFrame.MoveNodeDownExecute
//
procedure TN_VTreeFrame.MoveNodeDownExecute(Sender: TObject);
begin
  VTree.MoveSelectedObject( 1 );
end; //*** end of procedure TN_VTreeFrame.MoveNodeDownExecute

//************************************************ TN_VTreeFrame.ToggleNodesPMarkExecute
//
procedure TN_VTreeFrame.ToggleNodesPMarkExecute(Sender: TObject);
begin
  VTree.ToggleMarkedNodesPMark;
end; //*** end of procedure TN_VTreeFrame.ToggleNodesPMarkExecute

//************************************************ TN_VTreeFrame.ClearNodesPMarkExecute
//
procedure TN_VTreeFrame.ClearNodesPMarkExecute(Sender: TObject);
begin
  VTree.ClearNodesPMark;
end; //*** end of procedure TN_VTreeFrame.ClearNodesPMarkExecute

//************************************************ TN_VTreeFrame.TVMouseDown
//
procedure TN_VTreeFrame.TVMouseDown( Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HitNode, LoopNode, PrevNode: TTreeNode;
  HitTests: THitTests;
  MarkOnlyCurrent: boolean;
  ToggleMode: Integer;
  HitNodeAbovePrev, PrevSelectedFound, HitNodeWasSelected: boolean;
  CVN : TN_VNode;

  procedure GetHitNodeVNode();
  begin
    HitNode := TreeView.GetNodeAt( X, Y );
    CVN := nil;
    if HitNode <> nil then CVN := TN_VNode(HitNode.Data);
  end;

label FinActs, SExit;
begin
  EdName.Visible := false;
  if VTree = nil then Exit;
  GetHitNodeVNode();

//  if (K_vtfsUseObjDisabledFlag in K_VTreeFrameShowFlags) and
  if (CVN <> nil) and ((CVN.VNUDObj.ObjFlags and K_fpObjTVDisabled) <> 0) then Exit; // Skip  Disabled

  if Button <> mbLeft then
  begin
    VTree.SetCurrentVNode( CVN );
    if Assigned(OnMouseDownProcObj) then
      OnMouseDownProcObj( Self, CVN, Button, Shift );
    Exit;
  end;

  HitTests := VTree.TreeView.GetHitTestInfoAt( X, Y );

  VTree.TreeViewClickTimeCount := 0;

  if htOnButton in HitTests then Exit;

  if not (htOnItem in HitTests) then
  begin
    if not (ssCtrl in Shift) and       // Ctrl Key
       not (ssShift in Shift) then     // Shift Key
    begin
      VTree.UnMarkAllVNodes();
      VTree.SetSelectedVNode( nil );
      TreeView.Repaint;
    end;
    HitNodeWasSelected := FALSE;
    goto FinActs;
{
    if Assigned(OnMouseDownProcObj) then
      OnMouseDownProcObj( Self, CVN, Button, Shift );
    Exit;
}
  end;


  if (HitNode = nil) then Exit;

  VTree.TreeViewClickTimeCount := N_CPUCounter;

//  if (K_vtfsUseObjAutoCheckFlag in K_VTreeFrameShowFlags)     and
  if ((CVN.VNUDObj.ObjFlags and K_fpObjTVAutoCheck) <> 0) and
     (htOnIcon in HitTests) then
  begin
  // Toggle Item CheckBox
    CVN.VNUDObj.ObjFlags := CVN.VNUDObj.ObjFlags xor K_fpObjTVChecked;

    CVN.VNUDObj.RebuildVTreeCheckedState( );

    if Assigned(OnMouseDownProcObj) then
      OnMouseDownProcObj( Self, CVN, Button, Shift );
    TreeView.Repaint;
    Exit;
  end;

  HitNodeWasSelected := K_fVNodeStateMarked in CVN.VNState;

  MarkOnlyCurrent := False;
  if MultiMark then
  begin
    if (ssCtrl in Shift) then // Ctrl Key is down, add or delete
      ToggleMode := 0  // Toggle Nodes
    else
    begin
      MarkOnlyCurrent := True;
      ToggleMode := 1; // Mark Nodes
    end;

    if (ssShift in Shift)      and  // Shift Key
       (VTree.Selected <> nil) and  // Some Node was selected
       (VTree.Selected <> CVN) then // New Node is selected
    begin
  //*** Shift Key is down - operate with nodes section
  //    from previosly selected to last selected
      MarkOnlyCurrent := False;
      if HitNode.Parent <> nil then
        LoopNode := HitNode.Parent.Item[0]
      else
        LoopNode := TreeView.Items[0];

      HitNodeAbovePrev := False;
      PrevSelectedFound := False;
      PrevNode := VTree.Selected.VNTreeNode;

      repeat
        if LoopNode = HitNode then HitNodeAbovePrev := True;
        if (LoopNode <> nil) and (LoopNode = PrevNode) then
        begin
          PrevSelectedFound := True;
          Break;
        end;
        LoopNode := LoopNode.GetNextSibling;
      until LoopNode = nil;

      if PrevSelectedFound then
      begin// previously selected exists in same dir
  //*** toggle all nodes between prev selected and current selected
        repeat
          TN_VNode(LoopNode.Data).Toggle( ToggleMode );
          if HitNodeAbovePrev then
            LoopNode := LoopNode.GetPrevSibling
          else
            LoopNode := LoopNode.GetNextSibling;
        until LoopNode = HitNode;
        TN_VNode(LoopNode.Data).Toggle( ToggleMode );
      end // if PrevSelectedFound then
      else  // previously selected not found in same dir as HitNode
        MarkOnlyCurrent := True;

    // end if - Shift Key is down
    end
    else
    begin
    // no Ctrl neither Shift Key is down, toggle selected node mark status
      CVN.Toggle( ToggleMode );
    end;
  end; // if MultiMark then

  VTree.SetSelectedVNode( CVN );

  if MarkOnlyCurrent or not MultiMark then // mark only one selected node
  begin
    VTree.UnMarkAllVNodes();
    CVN.Mark();
  end;

FinActs:
  if Assigned(OnMouseDownProcObj) then
  begin
    OnMouseDownProcObj( Self, CVN, Button, Shift );
    if CVN <> nil then
      GetHitNodeVNode(); // Rebuild CVN after OnMouseDownProcObj
  end;

  if (not HitNodeWasSelected) and
     (CVN <> nil)             and
     (K_fVNodeStateMarked in CVN.VNState) then
  begin
    if Assigned(OnSelectProcObj) then
    begin
      OnSelectProcObj( Self, CVN, Button, Shift );
      if CVN <> nil then
        GetHitNodeVNode(); // Rebuild CVN after OnSelectProcObj
    end;
  end;

  if HitNodeWasSelected       and
     (CVN <> nil)             and
     (K_fVNodeStateMarked in CVN.VNState) then
  begin
    if Assigned(OnActionProcObj) then
    begin
      OnActionProcObj( Self, CVN, Button, Shift );
      if CVN <> nil then
        GetHitNodeVNode(); // Rebuild CVN after OnActionProcObj
    end;
  end;

  if (ssDouble in Shift) then
  begin// doubleclick
    if Assigned(OnDoubleClickProcObj) then
      OnDoubleClickProcObj( Self, CVN, Button, Shift );
  end;

  TreeView.Repaint;
end; //*** end of procedure TN_VTreeFrame.TVMouseDown

//********** end of TN_VTreeFrame class methods  **************

//********** TN_UDMem class methods  **************

//********************************************************* TN_UDMem.Create ***
//
//
constructor TN_UDMem.Create;
begin
  inherited Create;
  ClassFlags := N_UDMemCI;
  ImgInd := 39;
end; // end_of constructor TN_UDMem.Create

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDMem\AddFieldsToSBuf
//************************************************ TN_UDMem.AddFieldsToSBuf ***
// Add self fields serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
procedure TN_UDMem.AddFieldsToSBuf( ASBuf: TN_SerialBuf );
var
  Size: integer;
begin
  Inherited;
  Size := Length(SelfMem);
  ASBuf.AddRowInt( Size );
  if Size > 0 then
    ASBuf.AddRowBytes( Size, @SelfMem[0] );
end; // end_of procedure TN_UDMem.AddFieldsToSBuf

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDMem\GetFieldsFromSBuf
//********************************************** TN_UDMem.GetFieldsFromSBuf ***
// Get self fields from serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
procedure TN_UDMem.GetFieldsFromSBuf( ASBuf: TN_SerialBuf );
var
  Size: integer;
begin
  Inherited;
  ASBuf.GetRowInt( Size );
  SetLength( SelfMem, Size );
  if Size > 0 then
    ASBuf.GetRowBytes( Size, @SelfMem[0] );
end; // end_of procedure TN_UDMem.GetFieldsFromSBuf

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDMem\AddFieldsToText
//************************************************ TN_UDMem.AddFieldsToText ***
// Add self fields serial text buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// Result - Returns TRUE if all self child IDB object serialization is needed.
//
function TN_UDMem.AddFieldsToText( ASTBuf: TK_SerialTextBuf;
                                  AShowFlags : Boolean = true ): Boolean;
var
  Size: integer;
begin
  inherited AddFieldsToText( ASTBuf, AShowFlags );

  Size := Length(SelfMem);
  if Size > 0 then
  begin
    ASTBuf.AddTagAttr( 'Size', Size, K_isInteger );
    if not (K_txtSkipUDMemData in K_TextModeFlags) then
      ASTBuf.AddRowBytes( Size, @SelfMem[0] );
  end;

  Result := True;
end; // end_of procedure TN_UDMem.AddFieldsToText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDMem\GetFieldsFromText
//********************************************** TN_UDMem.GetFieldsFromText ***
// Get self fields from serial text buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// Result - Returns number of self child IDB object from which childs 
//          serialization have to be continued.
//
function TN_UDMem.GetFieldsFromText( ASTBuf: TK_SerialTextBuf ): Integer;
var
  Size: integer;
begin
  inherited GetFieldsFromText(ASTBuf);

  if ASTBuf.GetTagAttr( 'Size', Size, K_isInteger ) then
  begin
    SetLength( SelfMem, Size );
    ASTBuf.GetRowBytes( Size, @SelfMem[0] );
  end else
    SelfMem := nil;

  Result := 0;
end; // end_of procedure TN_UDMem.GetFieldsFromText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDMem\CopyFields
//***************************************************** TN_UDMem.CopyFields ***
// Copy to all fields from given IDB TN_UDMem object to self fields
//
//     Parameters
// ASrcObj - source IDB object which fields are copied to self
//
procedure TN_UDMem.CopyFields( ASrcObj: TN_UDBase );
begin
  if ASrcObj = nil then Exit; // a precaution
//  Assert( ASrcObj.CI() = N_UDMemCI, 'Not UDMem!' );
  inherited;
  SelfMem := Copy( TN_UDMem(ASrcObj).SelfMem );
end; // end_of procedure TN_UDMem.CopyFields

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDMem\SameFields
//***************************************************** TN_UDMem.SameFields ***
// Compare All self fields and fields of given IDB TN_UDMem object
//
//     Parameters
// ASrcObj - IDB object which fields are compared with self
// AFlags  - control comparing of fields inherited from TN_UDBase
// Result  - Returns TRUE if all self fields are the same as given IDB object 
//           fields
//
function TN_UDMem.SameFields( ASrcObj: TN_UDBase; AFlags: integer ): boolean;
begin
  Result := Inherited SameFields( ASrcObj, AFlags );
  if Result = False then Exit; // not same
//  Assert( ASrcObj.CI() = N_UDMemCI, 'Not UDMem!' );
  Result := (Length(SelfMem) = Length(TN_UDMem(ASrcObj).SelfMem))
    and CompareMem( @SelfMem[0], @TN_UDMem(ASrcObj).SelfMem[0], Length(SelfMem) );
end; // end_of procedure TN_UDMem.SameFields

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDMem\CompareFields
//************************************************** TN_UDMem.CompareFields ***
// Compare All self fields and fields of given IDB TN_UDMem for IDB Subnet 
// compare routine
//
//     Parameters
// ASrcObj - IDB object which fields are compared with self
// AFlags  - control comparing of fields inherited from TN_UDBase
// ANPath  - current path to object in compared IDB Subnet
// Result  - Returns TRUE if all self fields are the same as given IDB object 
//           fields
//
// Raise exception if some unequal fields are found.
//
function TN_UDMem.CompareFields( ASrcObj: TN_UDBase; AFlags: integer;
                                 ANPath : string ) : Boolean;
begin
  Result := Inherited CompareFields( ASrcObj, AFlags, ANPath );
  if Result = False then Exit; // not same
//  Assert( ASrcObj.CI() = N_UDMemCI, 'Not UDMem!' );
  Result := (Length(SelfMem) = Length(TN_UDMem(ASrcObj).SelfMem))
    and CompareMem( @SelfMem[0], @TN_UDMem(ASrcObj).SelfMem[0], Length(SelfMem) );
end; // end_of procedure TN_UDMem.CompareFields

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDMem\GetStringsFromSelfBD
//******************************************* TN_UDMem.GetStringsFromSelfBD ***
// Get strings from self Binary Data buffer to given TStrings object
//
//     Parameters
// AStrings - given TStrings object
//
procedure TN_UDMem.GetStringsFromSelfBD( AStrings: TStrings );
var
  BufStr: string;
begin
  SetString( BufStr, PChar(SelfMem), Length(SelfMem) );
  AStrings.Text := BufStr;
end; // procedure TN_UDMem.GetStringsFromSelfBD

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDMem\LoadSelfBDFromDFile
//******************************************** TN_UDMem.LoadSelfBDFromDFile ***
// Load content of given Data File to self Binary Data buffer
//
//     Parameters
// AFileName  - Data File name and path
// AOpenFlags - Data File file open flags
// APassword  - file password for encrypted file
// Result     - Returns TRUE Data File is successfully read
//
function TN_UDMem.LoadSelfBDFromDFile( AFileName : string;
                                    AOpenFlags: TK_DFOpenFlags;
                                    APassword : AnsiString ): boolean;
var
  DFile: TK_DFile;
begin
  Result := K_DFOpen( AFileName, DFile, AOpenFlags );
  if not Result then Exit; // Error while opening

  SetLength( SelfMem, DFile.DFPlainDataSize );
  Result := K_DFReadAll( Pointer(SelfMem), DFile, APassword );
end; // function TN_UDMem.LoadSelfBDFromDFile

//********** end of TN_UDMem class methods  **************

{*** TN_UDExtMem ***}

//****************************************************** TN_UDExtMem.Create ***
//
//
constructor TN_UDExtMem.Create;
begin
  inherited Create;
  ClassFlags := N_UDExtMemCI;
  ImgInd := 39;
end; // end_of constructor TN_UDExtMem.Create

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDExtMem\AddFieldsToSBuf
//********************************************* TN_UDExtMem.AddFieldsToSBuf ***
// Add self fields serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
procedure TN_UDExtMem.AddFieldsToSBuf( ASBuf: TN_SerialBuf );
var
  DSize: integer;
  PData : Pointer;
  DFile: TK_DFile;
  WFilePos : Integer;
  NewFSize : Integer;
begin
  Inherited;
  if ASBuf.SBMemDstStream = nil then  // Create Stream to store Compound file Data Segments
    ASBuf.SBMemDstStream := TMemoryStream.Create;
//    raise TK_LoadUDDataError.Create( 'TN_UDExtMem Dest Stream is absent' );

  DSize := Length(SelfMem);
  WFilePos := ASBuf.SBMemDstStream.Position;
  if DSize = 0 then
  begin
    if ASBuf.SBMemSrcStream = nil then
    begin // Create Stream to Read from Prevoiuse File
      if ASBuf.SBMemSrcFileName <> '' then
        ASBuf.SBMemSrcStream := TFileStream.Create( ASBuf.SBMemSrcFileName, fmOpenRead)
      else
        raise TK_LoadUDDataError.Create( 'TN_UDExtMem Src Stream file name is absent' );
//      raise TK_LoadUDDataError.Create( 'TN_UDExtMem Src Stream is absent' );
    end;
{
      // Try to Rename Existing Compound File
        PrevFileName := K_RenameExistingFile( ObjInfo );

      // Open Stream to Existing Compound File for possible Data Read for not buffered Items
        if PrevFileName <> '' then
          N_SerialBuf.SBMemSrcStream := TFileStream.Create( PrevFileName, fmOpenRead);

}

    // Load Data from Source File
    if not K_DFStreamOpen( ASBuf.SBMemSrcStream, DFile, [K_dfoProtected], nil,
                           FilePos ) then
      raise TK_LoadUDDataError.Create( 'TN_UDExtMem Src Stream open error >> ' +
                                       K_DFGetErrorString( DFile.DFErrorCode ) );

    DSize := DFile.DFPlainDataSize;
    ASBuf.SBMemSrcStream.Seek( DFile.DFCurSegmPos, soBeginning );
    ASBuf.SBMemDstStream.CopyFrom( ASBuf.SBMemSrcStream,
                                   DFile.DFNextSegmPos - DFile.DFCurSegmPos )
  end
  else
  begin
    PData := @SelfMem[0];
    K_DFStreamWriteAll( ASBuf.SBMemDstStream,  K_DFCreateEncrypted2,
                        PData, DSize, WFilePos, ObjDateTime );
    SelfMem := nil;
  end;
  FilePos := WFilePos;

  // Correct Dst Stream Position (reserve space) if needed
  if DSize >= FileDataSpace then
  // Data Length >= Item File Space
    FileDataSpace := DSize
  else
  begin
  // Data Length < Item File Space - Shift Dst Stream to needed position
    NewFSize := ASBuf.SBMemDstStream.Position + FileDataSpace - DSize;
    if ASBuf.SBMemDstStream.Size < NewFSize then
      ASBuf.SBMemDstStream.Size := NewFSize;
    ASBuf.SBMemDstStream.Seek( NewFSize, soBeginning );
  end;

  ASBuf.AddRowInt( FilePos );
  ASBuf.AddRowInt( FileDataSpace );
  
end; // end_of procedure TN_UDExtMem.AddFieldsToSBuf

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDExtMem\GetFieldsFromSBuf
//******************************************* TN_UDExtMem.GetFieldsFromSBuf ***
// Get self fields from serial binary buffer
//
//     Parameters
// ASBuf - serial binary buffer object
//
procedure TN_UDExtMem.GetFieldsFromSBuf( ASBuf: TN_SerialBuf );
begin
  Inherited;
  ASBuf.GetRowInt( FilePos );
  ASBuf.GetRowInt( FileDataSpace );
end; // end_of procedure TN_UDExtMem.GetFieldsFromSBuf

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDExtMem\AddFieldsToText
//********************************************* TN_UDExtMem.AddFieldsToText ***
// Add self fields serial text buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// Result - Returns TRUE if all self child IDB object serialization is needed.
//
function TN_UDExtMem.AddFieldsToText( ASTBuf: TK_SerialTextBuf;
                                  AShowFlags : Boolean = true ): Boolean;
var
  Size: integer;
begin
  inherited AddFieldsToText( ASTBuf, AShowFlags );

  ASTBuf.AddTagAttr( 'FilePos', FilePos, K_isInteger );
  ASTBuf.AddTagAttr( 'FileSpace', FileDataSpace, K_isInteger );
  Size := Length(SelfMem);
  if Size > 0 then
  begin
    ASTBuf.AddTagAttr( 'Size', Size, K_isInteger );
    if not (K_txtSkipUDMemData in K_TextModeFlags) then
      ASTBuf.AddRowBytes( Size, @SelfMem[0] );
  end;

  Result := True;
end; // end_of procedure TN_UDExtMem.AddFieldsToText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDExtMem\GetFieldsFromText
//******************************************* TN_UDExtMem.GetFieldsFromText ***
// Get self fields from serial text buffer
//
//     Parameters
// ASBuf  - serial text buffer object
// Result - Returns number of self child IDB object from which childs 
//          serialization have to be continued.
//
function TN_UDExtMem.GetFieldsFromText( ASTBuf: TK_SerialTextBuf ): Integer;
var
  Size: integer;
begin
  inherited GetFieldsFromText(ASTBuf);

  ASTBuf.AddTagAttr( 'FilePos', FilePos, K_isInteger );
  ASTBuf.AddTagAttr( 'FileSpace', FileDataSpace, K_isInteger );

  if ASTBuf.GetTagAttr( 'Size', Size, K_isInteger ) then
  begin
    SetLength( SelfMem, Size );
    ASTBuf.GetRowBytes( Size, @SelfMem[0] );
  end else
    SelfMem := nil;

  Result := 0;
end; // end_of procedure TN_UDExtMem.GetFieldsFromText

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDExtMem\CopyFields
//************************************************** TN_UDExtMem.CopyFields ***
// Copy to all fields from given IDB TN_UDMem object to self fields
//
//     Parameters
// ASrcObj - source IDB object which fields are copied to self
//
procedure TN_UDExtMem.CopyFields( ASrcObj: TN_UDBase );
begin
  if ASrcObj = nil then Exit; // a precaution
  inherited;
  FilePos := TN_UDExtMem(ASrcObj).FilePos;
  FileDataSpace := TN_UDExtMem(ASrcObj).FileDataSpace;
  SelfMem := Copy( TN_UDExtMem(ASrcObj).SelfMem );

end; // end_of procedure TN_UDExtMem.CopyFields

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDExtMem\CompareSelfFields
//******************************************* TN_UDExtMem.CompareSelfFields ***
// Compare All self fields and fields of given IDB TN_UDMem object
//
//     Parameters
// ASrcObj - IDB object which fields are compared with self
// Result  - Returns TRUE if all self fields are the same as given IDB object 
//           fields
//
function TN_UDExtMem.CompareSelfFields( ASrcObj: TN_UDBase ): boolean;
begin
  Result := (FilePos = TN_UDExtMem(ASrcObj).FilePos)                 and
            (FileDataSpace = TN_UDExtMem(ASrcObj).FileDataSpace)     and
            (Length(SelfMem) = Length(TN_UDExtMem(ASrcObj).SelfMem)) and
            ((Length(SelfMem) = 0) or
             CompareMem( @SelfMem[0], @TN_UDExtMem(ASrcObj).SelfMem[0], Length(SelfMem) ) );
end; // end_of procedure TN_UDExtMem.CompareSelfFields

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDExtMem\SameFields
//************************************************** TN_UDExtMem.SameFields ***
// Compare All self fields and fields of given IDB TN_UDMem object
//
//     Parameters
// ASrcObj - IDB object which fields are compared with self
// AFlags  - control comparing of fields inherited from TN_UDBase
// Result  - Returns TRUE if all self fields are the same as given IDB object 
//           fields
//
function TN_UDExtMem.SameFields( ASrcObj: TN_UDBase; AFlags: integer ): boolean;
begin
  Result := Inherited SameFields( ASrcObj, AFlags );
  if Result = False then Exit; // not same
  Result := CompareSelfFields( ASrcObj );
end; // end_of procedure TN_UDExtMem.SameFields

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TN_UDExtMem\CompareFields
//*********************************************** TN_UDExtMem.CompareFields ***
// Compare All self fields and fields of given IDB TN_UDMem for IDB Subnet 
// compare routine
//
//     Parameters
// ASrcObj - IDB object which fields are compared with self
// AFlags  - control comparing of fields inherited from TN_UDBase
// ANPath  - current path to object in compared IDB Subnet
// Result  - Returns TRUE if all self fields are the same as given IDB object 
//           fields
//
// Raise exception if some unequal fields are found.
//
function TN_UDExtMem.CompareFields( ASrcObj: TN_UDBase; AFlags: integer;
                                 ANPath : string ) : Boolean;
begin
  Result := Inherited CompareFields( ASrcObj, AFlags, ANPath );
  if Result = False then Exit; // not same
  Result := CompareSelfFields( ASrcObj );
end; // end_of procedure TN_UDExtMem.CompareFields

{*** end of TN_UDExtMem ***}


{*** TK_UDTreeClipboard ***}

//********************************************* TK_UDTreeClipboard.Destroy
//
destructor TK_UDTreeClipboard.Destroy;
begin
  ClearClipboard( );
  inherited;
end; //end of TK_UDTreeClipboard.Destroy

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\CopyVNodesToClipboard
//******************************** TK_UDTreeClipboard.CopyVNodesToClipboard ***
// Copy IDB objects directory entries given by list of corresponding VNodes to 
// Clipboard
//
//     Parameters
// AVNodesList - list of VNodes
// ACutNodes   - cut IDB objects flags
//
function TK_UDTreeClipboard.CopyVNodesToClipboard( AVNodesList : TList; ACutNodes : Boolean ) : Integer;
begin
  Result := 0;
  if (AVNodesList = nil) or (AVNodesList.Count = 0) then Exit;
  CutNodes := ACutNodes;
  ClearClipboard();
  DEClipboard := K_BuildDEArrayFromVNodesList( AVNodesList, K_SkipDestructBit, true );
  UpdateVTreesByClipboard( );
  Result := Length(DEClipboard);
end; //end of TK_UDTreeClipboard.CopyVNodesToClipboard

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\PasteFromClipboard
//*********************************** TK_UDTreeClipboard.PasteFromClipboard ***
// Paste IDB objects from Clipboard as childs to given parent IDB object
//
//     Parameters
// AUDParent       - given parent IDB object
// APasteInd       - index of child object (if =-1 then add to the end of childs
//                   list)
// AUDInsChildFunc - function of object for pasting IDB objects
// ACBPrepFlags    - prepare Clipboard before and after pasting flags set
//
function TK_UDTreeClipboard.PasteFromClipboard( AUDParent : TN_UDBase; APasteInd : Integer;
                                                AUDInsChildFunc : TK_UDInsChildFunc;
                                                ACBPrepFlags : TK_UDTreeClipboardPrepFlags ) : Integer;
var
  i : Integer;
  InsChildFlag : Boolean;
  DelCout : Integer;
begin
  Result := PrepClipboard( ACBPrepFlags );
  if Result = 0 then Exit;

  K_TreeViewsUpdateModeSet;

//  PasteInd := UDParent.InsertEmptyEntries( PasteInd, Result );
  // Culc Real Clip Count
  if APasteInd < 0 then APasteInd := AUDParent.DirLength();

  DelCout := 0;
  Result := 0;

  for i := 0 to High(DEClipboard) do begin
    with DEClipboard[i] do begin
      if (Child = nil) or (Child.RefCounter <= 0) then Continue;
      if (Parent <> nil) and (Parent.RefCounter > 0) then
        K_TryToRepairDirIndex( DEClipboard[i], K_SkipDestructBit );

      InsChildFlag := false;
      if Assigned( AUDInsChildFunc ) then begin
        InsChildFlag := AUDInsChildFunc( AUDParent, APasteInd, DEClipboard[i] );
        K_SetChangeSubTreeFlags( AUDParent, [K_cstfSetSLSRChangeFlag] );
      end;

      if InsChildFlag then begin
        Inc(Result);
        if CutNodes then begin
          if (Parent <> nil)         and
             (Parent.RefCounter > 0) and
             (DirIndex >= 0) then begin
            if (Parent = AUDParent) and (APasteInd <= DirIndex ) then
              Inc(DirIndex);
            if K_DeleteDEChild( DEClipboard[i], UDDelChildFunc ) then begin
              Inc(DelCout);
              if Child.Owner = nil then Child.Owner := AUDParent;
            end;
          end;
          Parent := AUDParent;
          DirIndex := APasteInd;
        end;
        Inc(APasteInd);
      end;
    end;
  end;
  K_TreeViewsUpdateModeClear;

  if CutNodes then begin
    CutNodes := false;
    PrepClipboard( ACBPrepFlags );
    UpdateVTreesByClipboard();
  end;

//  if (Result > 0) and (DelCout > 0) then
  if (Result > 0) or (DelCout > 0) then
    K_SetArchiveChangeFlag;

end; //end of TK_UDTreeClipboard.PasteFromClipboard

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\CheckParentForPaste
//********************************** TK_UDTreeClipboard.CheckParentForPaste ***
// Check if IDB object is proper parent for paste from Clipboard
//
//     Parameters
// AUDParent - given IDB object
// Result    - Returns TRUE if given IDB object is not marked as "Skip object 
//             destruction" and is not in Clipboard
//
function TK_UDTreeClipboard.CheckParentForPaste( AUDParent : TN_UDBase ) : Boolean;
begin
  Result := true;
  while Result and (AUDParent.Owner <> nil) do begin
    Result := (AUDParent.ClassFlags and K_SkipDestructBit) = 0;
    if not Result then // Check if Object is in Clipboard
      Result := -1 = K_IndexOfIntegerInRArray( Integer(AUDParent),
                                   PInteger(@DEClipboard[0].Child),
                                   Length(DEClipboard), SizeOf(TN_DirEntryPar) );
    AUDParent := AUDParent.Owner;
  end;
end; //end of TK_UDTreeClipboard.CheckParentForPaste

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\PrepClipboard
//**************************************** TK_UDTreeClipboard.PrepClipboard ***
// Prepare Clipboard before paste operation
//
//     Parameters
// ACBPrepFlags - prepare Clipboard before pasting flags set
//
// If Clipboard has "Cut after paste" mode then mark IDB objects as "Skip object
// destruction" before paste operation finishing.
//
function TK_UDTreeClipboard.PrepClipboard( ACBPrepFlags : TK_UDTreeClipboardPrepFlags ) : Integer;
begin
  K_TreeViewsUpdateModeSet;
  Result := K_PrepDEArrayAfterDeletion( DEClipboard, K_SkipDestructBit, ACBPrepFlags );
  K_TreeViewsUpdateModeClear(false);
end; //end of TK_UDTreeClipboard.PrepClipboard

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\GetClipboardCount
//************************************ TK_UDTreeClipboard.GetClipboardCount ***
// Prepare clipboard after external deletion
//
//     Parameters
// ACBPrepFlags - prepare Clipboard after pasting flags set
// Result       - Returns number of elements remained in CLipboard
//
// Destruct all IDB objects in Clipboard which were marked as "Skip object 
// destruction" and have to be destructed and clear from Clipboard elements with
// IDB Objects with destructed parents and wrong directory entries indexes
//
function TK_UDTreeClipboard.GetClipboardCount( ACBPrepFlags : TK_UDTreeClipboardPrepFlags =
                 [K_ucpRemoveNodesWithAbsentParents, K_ucpRemoveNodesWithWrongDEInd] ) : Integer;
begin
  K_TreeViewsUpdateModeSet;
  Result := K_PrepDEArrayAfterDeletion( DEClipboard,
               K_SkipDestructBit or K_SkipDestructBitD, ACBPrepFlags );
  K_TreeViewsUpdateModeClear(false);
end; //end of TK_UDTreeClipboard.GetClipboardCount

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\ClearClipboard
//*************************************** TK_UDTreeClipboard.ClearClipboard ***
// Clear all elements from Clipboard
//
procedure TK_UDTreeClipboard.ClearClipboard( );
begin
  K_TreeViewsUpdateModeSet;
  PrepClipboard( [] );
  K_ClearDEArrayChildsClassFlags( DEClipboard, K_SkipDestructBit );
  K_TreeViewsUpdateModeClear(false);
end; //end of TK_UDTreeClipboard.ClearClipboard

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\PrepShowClipboard
//************************************ TK_UDTreeClipboard.PrepShowClipboard ***
// Update all Visual Nodes using Clipboard state
//
//     Parameters
// AUseVCode - use VCode field for search corresponding VNodes
//
procedure TK_UDTreeClipboard.PrepShowClipboard( AUseVCode : Boolean = true );
var
  i : Integer;
  WVNode : TN_VNode;
begin
  for i := 0 to High(DEClipboard) do
    with DEClipboard[i] do begin
      if Child = nil then Continue;
      WVNode := Child.LastVNode;
      while WVNode <> nil do begin
        WVNode.Toggle( -1, [K_fVNodeStateSpecMark0] );
        WVNode.Toggle( -1, [K_fVNodeStateSpecMark1] );
        if (WVNode.VNParent.VNUDObj = Parent) and
           (not AUseVCode or (WVNode.VNCode = VCode)) then begin
          if not SkipShowClipNodes then
            WVNode.Toggle( 1, [K_fVNodeStateSpecMark0] );
          if CutNodes and not SkipShowCutNodes then
            WVNode.Toggle( 1, [K_fVNodeStateSpecMark1] );
        end;
        WVNode := WVNode.PrevVNUDObjVNode;
      end;
    end;
end; //end of TK_UDTreeClipboard.PrepShowClipboard

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\UpdateVTreesByClipboard
//****************************** TK_UDTreeClipboard.UpdateVTreesByClipboard ***
// Update all open Visual Trees Nodes using Clipboard state
//
//     Parameters
// AUseVCode - use VCode field for search corresponding VNodes
//
procedure TK_UDTreeClipboard.UpdateVTreesByClipboard( AUseVCode : Boolean = true );
begin
  K_TreeViewsUpdateModeSet;
  PrepShowClipboard( AUseVCode );
  K_TreeViewsUpdateModeClear;
end; //end of TK_UDTreeClipboard.UpdateVTreesByClipboard

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\InsChildRef
//****************************************** TK_UDTreeClipboard.InsChildRef ***
// Build in Clipboard paste from Clipboard function which paste IDB objects 
// references
//
//     Parameters
// AUDParent - parent IDB object for pasting from Clipboard
// AChildInd - index of child in parent IDB object directory before which object
//             from Clipboard will be paste
// ASrcDE    - source directory entry data about pasting IDB object
// Result    - Returns TRUE if IDB object insertion is done
//
function  TK_UDTreeClipboard.InsChildRef( AUDParent : TN_UDBase; AChildInd : Integer;
                                          const ASrcDE : TN_DirEntryPar ) : Boolean;
begin
  Result := true;
  with ASrcDE, AUDParent do begin
    InsOneChild( AChildInd, Child );
    AddChildVNodes( AChildInd, AddVNodeFalgs );
  end;
end; //end of TK_UDTreeClipboard.InsChildRef

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\InsChildClone
//**************************************** TK_UDTreeClipboard.InsChildClone ***
// Build in Clipboard paste from Clipboard function which paste IDB objects 
// clones
//
//     Parameters
// AUDParent - parent IDB object for pasting from Clipboard
// AChildInd - index of child in parent IDB object directory before which object
//             from Clipboard will be paste
// ASrcDE    - source directory entry data about pasting IDB object
// Result    - Returns TRUE if IDB object insertion is done
//
function  TK_UDTreeClipboard.InsChildClone( AUDParent : TN_UDBase; AChildInd : Integer;
                                            const ASrcDE : TN_DirEntryPar ) : Boolean;
begin
  Result := true;
  with ASrcDE, AUDParent do begin
    InsOneChild( AChildInd, Child.Clone );
    AddChildVNodes( AChildInd, AddVNodeFalgs );
  end;
end; //end of TK_UDTreeClipboard.InsChildClone

//##path K_Delphi\SF\K_clib\K_UDT1.pas\TK_UDTreeClipboard\DeleteDEChild
//**************************************** TK_UDTreeClipboard.DeleteDEChild ***
// Build in Clipboard delete child function for delete cut IDB objects after 
// paste from Clipboard
//
//     Parameters
// AUDParent - parent IDB object for pasting from Clipboard
// AChildInd - index of child in parent IDB object directory before which object
//             from Clipboard will be paste
// Result    - Returns TRUE if IDB object deletion is done
//
function TK_UDTreeClipboard.DeleteDEChild( AUDParent : TN_UDBase; AChildInd : Integer ) : Boolean;
begin
  Result := (AUDParent.DeleteDirEntry( AChildInd ) <= K_DRisOK);
end; //*** end of TK_UDTreeClipboard.DeleteDEChild

{*** end of TK_UDTreeClipboard ***}

Initialization

  K_UDFilter := nil;

end.
